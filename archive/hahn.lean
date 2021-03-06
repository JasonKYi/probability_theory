import signed_measure
import order.symm_diff

/- 
This file contains the definition of positive and negative sets and 
the Hahn decomposition theorem.
-/

noncomputable theory
open_locale classical big_operators nnreal ennreal

variables {α β : Type*} [measurable_space α]

namespace signed_measure

open filter measure_theory

/-- A set `i` is positive with respect to a signed measure if for all 
measurable set `j`, `j ⊆ i`, `j` has non-negative measure. -/
def positive (s : signed_measure α) (i : set α) : Prop := 
∀ j ⊆ i, measurable_set j → 0 ≤ s j

/-- A set `i` is negative with respect to a signed measure if for all 
measurable set `j`, `j ⊆ i`, `j` has non-positive measure. -/
def negative (s : signed_measure α) (i : set α) : Prop := 
∀ j ⊆ i, measurable_set j → s j ≤ 0

variables {s : signed_measure α} {i j : set α}

lemma empty_positive : s.positive ∅ :=
begin
  intros j hj _,
  rw [set.subset_eq_empty hj rfl, s.measure_of_empty],
end

lemma empty_negative : s.negative ∅ :=
begin
  intros j hj _,
  rw [set.subset_eq_empty hj rfl, s.measure_of_empty],
end

lemma positive_nonneg_measure (hi₁ : measurable_set i) (hi₂ : s.positive i) : 
  0 ≤ s i := 
hi₂ i set.subset.rfl hi₁

lemma negative_nonpos_measure (hi₁ : measurable_set i) (hi₂ : s.negative i) : 
  s i ≤ 0 := 
hi₂ i set.subset.rfl hi₁

lemma positive_subset_positive (hi : s.positive i) (hij : j ⊆ i) : 
  s.positive j :=
begin
  intros k hk,
  exact hi _ (set.subset.trans hk hij),
end

lemma negative_subset_negative (hi : s.negative i) (hij : j ⊆ i) : 
  s.negative j :=
begin
  intros k hk,
  exact hi _ (set.subset.trans hk hij),
end

lemma positive_union_positive 
  (hi₁ : measurable_set i) (hi₂ : s.positive i)
  (hj₁ : measurable_set j) (hj₂ : s.positive j) : s.positive (i ∪ j) :=
begin
  intros a ha₁ ha₂,
  have h₁ := measurable_set.inter ha₂ hi₁,
  have h₂ := measurable_set.diff (measurable_set.inter ha₂ hj₁) h₁,
  rw [← set.union_inter_diff_eq ha₁, 
      measure_of_union set.union_inter_diff_disjoint h₁ h₂],
  refine add_nonneg (hi₂ _ (a.inter_subset_right i) h₁) _,
  exact hj₂ _ (set.subset.trans ((a ∩ j).diff_subset (a ∩ i)) (a.inter_subset_right j)) h₂,
end

lemma positive_Union_negative {f : ℕ → set α} 
  (hf₁ : ∀ n, measurable_set (f n)) (hf₂ : ∀ n, s.positive (f n)) : 
  s.positive ⋃ n, f n :=
begin
  intros a ha₁ ha₂,
  rw [← set.Union_inter_diff_eq ha₁, s.measure_of_disjoint_Union _ set.Union_inter_diff_disjoint],
  refine tsum_nonneg (λ n, hf₂ n _ _ _),
  { exact set.subset.trans (set.diff_subset _ _) (set.inter_subset_right _ _) },
  { refine measurable_set.diff (measurable_set.inter ha₂ (hf₁ n)) _,
    exact measurable_set.Union (λ m, measurable_set.Union_Prop (λ _, hf₁ m)) }, 
  { intro n,
    refine measurable_set.diff (measurable_set.inter ha₂ (hf₁ n)) _,
    exact measurable_set.Union (λ m, measurable_set.Union_Prop (λ _, hf₁ m)) }
end

lemma negative_union_negative
  (hi₁ : measurable_set i) (hi₂ : s.negative i)
  (hj₁ : measurable_set j) (hj₂ : s.negative j) : s.negative (i ∪ j) :=
begin
  intros a ha₁ ha₂,
  have h₁ := measurable_set.inter ha₂ hi₁,
  have h₂ := measurable_set.diff (measurable_set.inter ha₂ hj₁) h₁,
  rw [← set.union_inter_diff_eq ha₁, 
      measure_of_union set.union_inter_diff_disjoint h₁ h₂],
  refine add_nonpos (hi₂ _ (a.inter_subset_right i) h₁) _,
  exact hj₂ _ (set.subset.trans ((a ∩ j).diff_subset (a ∩ i)) (a.inter_subset_right j)) h₂,
end

lemma negative_Union_negative {f : ℕ → set α} 
  (hf₁ : ∀ n, measurable_set (f n)) (hf₂ : ∀ n, s.negative (f n)) : 
  s.negative ⋃ n, f n :=
begin
  intros a ha₁ ha₂,
  rw [← set.Union_inter_diff_eq ha₁, s.measure_of_disjoint_Union _ set.Union_inter_diff_disjoint],
  refine tsum_nonpos (λ n, hf₂ n _ _ _),
  { exact set.subset.trans (set.diff_subset _ _) (set.inter_subset_right _ _) },
  { refine measurable_set.diff (measurable_set.inter ha₂ (hf₁ n)) _,
    exact measurable_set.Union (λ m, measurable_set.Union_Prop (λ _, hf₁ m)) }, 
  { intro n,
    refine measurable_set.diff (measurable_set.inter ha₂ (hf₁ n)) _,
    exact measurable_set.Union (λ m, measurable_set.Union_Prop (λ _, hf₁ m)) }
end

lemma exists_pos_measure_of_not_negative (hi : ¬ s.negative i) : 
  ∃ (j : set α) (hj₁ : j ⊆ i) (hj₂ : measurable_set j), 0 < s j :=
begin
  rw negative at hi,
  push_neg at hi,
  obtain ⟨j, hj₁, hj₂, hj⟩ := hi,
  exact ⟨j, hj₁, hj₂, hj⟩,
end

/-- The underlying function for `signed_measure.positive_to_measure`. -/
def positive_to_measure_of_measure (s : signed_measure α) 
  (i : set α) (hi₁ : measurable_set i) (hi₂ : s.positive i) 
  (j : set α) (hj₁ : measurable_set j) : ℝ≥0∞ :=
some ⟨s (i ∩ j), positive_nonneg_measure (measurable_set.inter hi₁ hj₁) 
  (positive_subset_positive hi₂ $ set.inter_subset_left _ _)⟩

/-- Given a signed measure `s` and a positive measurable set `i`, `positive_to_measure` 
provides the measure mapping measurable sets `j` to `s (i ∩ j)`. -/
def positive_to_measure (s : signed_measure α) 
  (i : set α) (hi₁ : measurable_set i) (hi₂ : s.positive i) : measure α := 
measure.of_measurable (s.positive_to_measure_of_measure i hi₁ hi₂) 
  (by { simp_rw [positive_to_measure_of_measure, set.inter_empty i, s.measure_of_empty], refl })
  begin
    intros f hf₁ hf₂,
    simp_rw [positive_to_measure_of_measure, set.inter_Union],
    have h₁ : ∀ n, measurable_set (i ∩ f n) := λ n, hi₁.inter (hf₁ n),
    have h₂ : pairwise (disjoint on λ (n : ℕ), i ∩ f n),
    { rintro n m hnm x ⟨⟨_, hx₁⟩, _, hx₂⟩,
      exact hf₂ n m hnm ⟨hx₁, hx₂⟩ },
    simp_rw [s.measure_of_disjoint_Union h₁ h₂, ennreal.some_eq_coe, 
      ← ennreal.coe_tsum (nnreal.summable_coe_of_summable _ (summable_measure_of h₁ h₂))],
    rw ← nnreal.tsum_coe_eq_of_nonneg,
  end

lemma positive_to_measure_apply (hi₁ : measurable_set i) (hi₂ : s.positive i) 
  {j : set α} (hj₁ : measurable_set j) : 
  s.positive_to_measure i hi₁ hi₂ j = 
  some ⟨s (i ∩ j), positive_nonneg_measure (measurable_set.inter hi₁ hj₁) 
  (positive_subset_positive hi₂ $ set.inter_subset_left _ _)⟩ :=
by { rw [positive_to_measure, measure.of_measurable_apply _ hj₁], refl }

/-- `signed_measure.positive_to_measure` is a finite measure (this is a def since it 
takes arguments). -/
def positive_to_measure_finite (hi₁ : measurable_set i) (hi₂ : s.positive i) : 
  finite_measure (s.positive_to_measure i hi₁ hi₂) := 
{ measure_univ_lt_top := 
  begin
    rw [positive_to_measure_apply hi₁ hi₂ measurable_set.univ, ennreal.some_eq_coe],
    exact ennreal.coe_lt_top,
  end }

/-- The underlying function for `signed_measure.negative_to_measure`. -/
def negative_to_measure_of_measure (s : signed_measure α) 
  (i : set α) (hi₁ : measurable_set i) (hi₂ : s.negative i) 
  (j : set α) (hj₁ : measurable_set j) : ℝ≥0∞ :=
some ⟨-s (i ∩ j), le_neg.1 $ (@neg_zero ℝ _).symm ▸ 
  negative_nonpos_measure (measurable_set.inter hi₁ hj₁) 
    (negative_subset_negative hi₂ $ set.inter_subset_left _ _)⟩

/-- Given a signed measure `s` and a positive measurable set `i`, `positive_to_measure` 
provides the measure mapping measurable sets `j` to `s (i ∩ j)`. -/
def negative_to_measure (s : signed_measure α) 
  (i : set α) (hi₁ : measurable_set i) (hi₂ : s.negative i) : measure α := 
measure.of_measurable (s.negative_to_measure_of_measure i hi₁ hi₂) 
  (by { simp_rw [negative_to_measure_of_measure, set.inter_empty i, s.measure_of_empty, neg_zero], refl })
  begin
    intros f hf₁ hf₂,
    simp_rw [negative_to_measure_of_measure, set.inter_Union],
    have h₁ : ∀ n, measurable_set (i ∩ f n) := λ n, hi₁.inter (hf₁ n),
    have h₂ : pairwise (disjoint on λ (n : ℕ), i ∩ f n),
    { rintro n m hnm x ⟨⟨_, hx₁⟩, _, hx₂⟩,
      exact hf₂ n m hnm ⟨hx₁, hx₂⟩ },
    simp_rw [s.measure_of_disjoint_Union h₁ h₂, ennreal.some_eq_coe], 
    rw ← ennreal.coe_tsum,
    simp_rw [← tsum_neg (summable_measure_of h₁ h₂)],
    { rw [ennreal.coe_eq_coe, ← nnreal.tsum_coe_eq_of_nonneg] },
    exact nnreal.summable_coe_of_summable _ (summable_neg_iff.2 (summable_measure_of h₁ h₂))
  end

lemma negative_to_measure_apply (hi₁ : measurable_set i) (hi₂ : s.negative i) 
  {j : set α} (hj₁ : measurable_set j) : 
  s.negative_to_measure i hi₁ hi₂ j = 
  some ⟨-s (i ∩ j), le_neg.1 $ (@neg_zero ℝ _).symm ▸ 
  negative_nonpos_measure (measurable_set.inter hi₁ hj₁) 
    (negative_subset_negative hi₂ $ set.inter_subset_left _ _)⟩ :=
by { rw [negative_to_measure, measure.of_measurable_apply _ hj₁], refl }

/-- `signed_measure.negative_to_measure` is a finite measure (this is a def since it 
takes arguments). -/
def negative_to_measure_finite (hi₁ : measurable_set i) (hi₂ : s.negative i) : 
  finite_measure (s.negative_to_measure i hi₁ hi₂) := 
{ measure_univ_lt_top := 
  begin
    rw [negative_to_measure_apply hi₁ hi₂ measurable_set.univ, ennreal.some_eq_coe],
    exact ennreal.coe_lt_top,
  end }

section exists_negative_set

def p (s : signed_measure α) (i j : set α) (n : ℕ) : Prop := 
∃ (k : set α) (hj₁ : k ⊆ i \ j) (hj₂ : measurable_set k), (1 / (n + 1) : ℝ) < s k

lemma exists_nat_one_div_lt_measure_of_not_negative (hi : ¬ s.negative (i \ j)) :
  ∃ (n : ℕ), s.p i j n := 
let ⟨k, hj₁, hj₂, hj⟩ := exists_pos_measure_of_not_negative hi in
let ⟨n, hn⟩ := exists_nat_one_div_lt hj in ⟨n, k, hj₁, hj₂, hn⟩

def aux₀ (s : signed_measure α) (i j : set α) : ℕ :=
if hi : ¬ s.negative (i \ j) then nat.find (exists_nat_one_div_lt_measure_of_not_negative hi) 
                       else 0
                       
lemma aux₀_spec (hi : ¬ s.negative (i \ j)) : s.p i j (s.aux₀ i j) := 
begin
  rw [aux₀, dif_pos hi],
  convert nat.find_spec _,
end

lemma aux₀_min (hi : ¬ s.negative (i \ j)) {m : ℕ} (hm : m < s.aux₀ i j) : ¬ s.p i j m := 
begin
  rw [aux₀, dif_pos hi] at hm,
  exact nat.find_min _ hm
end

def aux₁ (s : signed_measure α) (i j : set α) : set α := 
if hi : ¬ s.negative (i \ j) then classical.some (aux₀_spec hi) else ∅

lemma aux₁_spec (hi : ¬ s.negative (i \ j)) : 
  ∃ (hj₁ : (s.aux₁ i j) ⊆ i \ j) (hj₂ : measurable_set (s.aux₁ i j)), 
  (1 / (s.aux₀ i j + 1) : ℝ) < s (s.aux₁ i j) :=
begin
  rw [aux₁, dif_pos hi],
  exact classical.some_spec (aux₀_spec hi),
end

lemma aux₁_subset : s.aux₁ i j ⊆ i \ j := 
begin
  by_cases hi : ¬ s.negative (i \ j),
  { exact let ⟨h, _⟩ := aux₁_spec hi in h },
  { rw [aux₁, dif_neg hi],
    exact set.empty_subset _ },
end

lemma aux₁_subset'' : s.aux₁ i j ⊆ i := 
set.subset.trans aux₁_subset (set.diff_subset _ _)

lemma aux₁_subset' {k : set α} (hk : i \ k ⊆ i \ j) : s.aux₁ i k ⊆ i \ j := 
begin
  by_cases hi : ¬ s.negative (i \ k),
  { exact let ⟨h, _⟩ := aux₁_spec hi in set.subset.trans h hk },
  { rw [aux₁, dif_neg hi],
    exact set.empty_subset _ },
end

lemma aux₁_measurable_set : measurable_set (s.aux₁ i j) := 
begin
  by_cases hi : ¬ s.negative (i \ j),
  { exact let ⟨_, h, _⟩ := aux₁_spec hi in h },
  { rw [aux₁, dif_neg hi],
    exact measurable_set.empty }
end

lemma aux₁_lt (hi : ¬ s.negative (i \ j)) : 
  (1 / (s.aux₀ i j + 1) : ℝ) < s (s.aux₁ i j) :=
let ⟨_, _, h⟩ := aux₁_spec hi in h

noncomputable
def aux (s : signed_measure α) (i : set α) : ℕ → set α 
| 0 := s.aux₁ i ∅
| (n + 1) := s.aux₁ i ⋃ k ≤ n, 
  have k < n + 1 := nat.lt_succ_iff.mpr H,
  aux k

lemma aux_succ (n : ℕ) : s.aux i n.succ = s.aux₁ i ⋃ k ≤ n, s.aux i k := 
by rw aux

lemma aux_subset (n : ℕ) : 
  s.aux i n ⊆ i := 
begin
  cases n;
  { rw aux, exact aux₁_subset'' }
end

lemma aux_spec (n : ℕ) (h : ¬ s.negative (i \ ⋃ k ≤ n, s.aux i k)) : 
  s.p i (s.aux i n) (s.aux₀ i (⋃ k ≤ n, s.aux i k)) := 
begin
  rcases aux₀_spec h with ⟨k, hk₁, hk₂, hk₃⟩,
  refine ⟨k, set.subset.trans hk₁ _, hk₂, hk₃⟩,
  apply set.diff_subset_diff_right,
  intros x hx,
  simp only [exists_prop, set.mem_Union],
  exact ⟨n, le_rfl, hx⟩,
end

lemma aux_lt (n : ℕ) (hn :¬ s.negative (i \ ⋃ l ≤ n, s.aux i l)) : 
  (1 / (s.aux₀ i (⋃ k ≤ n, s.aux i k) + 1) : ℝ) < s (s.aux i n.succ) :=
begin
  rw aux_succ,
  apply aux₁_lt hn,
end

lemma not_negative_subset (hi : ¬ s.negative i) (h : i ⊆ j) : ¬ s.negative j := 
λ h', hi $ negative_subset_negative h' h

lemma measure_of_aux (hi₂ : ¬ s.negative i)
  (n : ℕ) (hn : ¬ s.negative (i \ ⋃ k < n, s.aux i k)) : 
  0 < s (s.aux i n) :=
begin
  cases n,
  { rw aux, rw ← @set.diff_empty _ i at hi₂,
    rcases aux₁_spec hi₂ with ⟨_, _, h⟩,
    exact (lt_trans nat.one_div_pos_of_nat h) },
  { rw aux_succ,
    have h₁ : ¬ s.negative (i \ ⋃ (k : ℕ) (H : k ≤ n), s.aux i k),
    { apply not_negative_subset hn,
      apply set.diff_subset_diff_right,
      intros x,
      simp_rw [set.mem_Union],
      rintro ⟨n, hn₁, hn₂⟩,
      refine ⟨n, nat.lt_succ_iff.mpr hn₁, hn₂⟩ },
    rcases aux₁_spec h₁ with ⟨_, _, h⟩,
    exact (lt_trans nat.one_div_pos_of_nat h) }
end

lemma aux_measurable_set (n : ℕ) : 
  measurable_set (s.aux i n) := 
begin
  cases n,
  { rw aux,
    exact aux₁_measurable_set },
  { rw aux,
    exact aux₁_measurable_set }
end

lemma aux_lt' (hi : ¬ s.negative i) :
  (1 / (s.aux₀ i ∅ + 1) : ℝ) < s (s.aux i 0) := 
begin 
  rw aux, 
  rw ← @set.diff_empty _ i at hi,
  exact aux₁_lt hi,
end

lemma aux_disjoint' {n m : ℕ} (h : n < m) : s.aux i n ∩ s.aux i m = ∅ :=
begin
  rw set.eq_empty_iff_forall_not_mem,
  rintro x ⟨hx₁, hx₂⟩,
  cases m, linarith,
  { rw aux at hx₂,
    exact (aux₁_subset hx₂).2 
      (set.mem_Union.2 ⟨n, set.mem_Union.2 ⟨nat.lt_succ_iff.mp h, hx₁⟩⟩) }
end

lemma aux_disjoint : pairwise (disjoint on (s.aux i)) :=
begin
  intros n m h,
  rcases lt_or_gt_of_ne h with (h | h),
  { intro x, 
    rw [set.inf_eq_inter, aux_disjoint' h],
    exact id },
  { intro x, 
    rw [set.inf_eq_inter, set.inter_comm, aux_disjoint' h],
    exact id }
end

private lemma exists_negative_set' (hi₁ : measurable_set i) (hi₂ : s i < 0) 
  (hn : ¬ ∀ n : ℕ, ¬ s.negative (i \ ⋃ l < n, s.aux i l)) : 
  ∃ (j : set α) (hj₁ : measurable_set j) (hj₂ : j ⊆ i), s.negative j ∧ s j < 0 :=
begin
  by_cases s.negative i,
  { exact ⟨i, hi₁, set.subset.refl _, h, hi₂⟩ },
  { push_neg at hn,
    set k := nat.find hn with hk₁,
    have hk₂ : s.negative (i \ ⋃ l < k, s.aux i l) := nat.find_spec hn,
    have hmeas : measurable_set (⋃ (l : ℕ) (H : l < k), s.aux i l), 
      exact (measurable_set.Union $ λ _, 
        measurable_set.Union_Prop (λ _, aux_measurable_set _)),
    refine ⟨i \ ⋃ l < k, s.aux i l, measurable_set.diff hi₁ hmeas, 
            set.diff_subset _ _, hk₂, _⟩,
    rw measure_of_diff' hmeas hi₁,
    rw s.measure_of_disjoint_Union,
    { have h₁ : ∀ l < k, 0 ≤ s (s.aux i l),
      { intros l hl,
        exact le_of_lt (measure_of_aux h _ 
          (not_negative_subset (nat.find_min hn hl) (set.subset.refl _))) },
      suffices : 0 ≤ ∑' (l : ℕ), s (⋃ (H : l < k), s.aux i l),
        linarith,
      refine tsum_nonneg _,
      intro l, by_cases l < k,
      { convert h₁ _ h,
        ext, 
        rw [set.mem_Union, exists_prop, and_iff_right_iff_imp],
        exact λ _, h },
      { convert le_of_eq s.measure_of_empty.symm,
        ext, simp only [exists_prop, set.mem_empty_eq, set.mem_Union, not_and, iff_false],
        exact λ h', false.elim (h h') } },
    { intro, exact measurable_set.Union_Prop (λ _, aux_measurable_set _) },
    { intros a b hab x hx,
      simp only [exists_prop, set.mem_Union, set.mem_inter_eq, set.inf_eq_inter] at hx,
      exact let ⟨⟨_, hx₁⟩, _, hx₂⟩ := hx in aux_disjoint a b hab ⟨hx₁, hx₂⟩ },
    { apply set.Union_subset,
      intros a x, 
      simp only [and_imp, exists_prop, set.mem_Union],
      intros _ hx,
      exact aux_subset _ hx } }
end .

/-- A measurable set of negative measure has a negative subset of negative measure. -/
theorem exists_negative_set (hi₁ : measurable_set i) (hi₂ : s i < 0) : 
  ∃ (j : set α) (hj₁ : measurable_set j) (hj₂ : j ⊆ i), s.negative j ∧ s j < 0 :=
begin
  by_cases s.negative i,
  { exact ⟨i, hi₁, set.subset.refl _, h, hi₂⟩ },
  { by_cases hn : ∀ n : ℕ, ¬ s.negative (i \ ⋃ l < n, s.aux i l),
    { set A := i \ ⋃ l, s.aux i l with hA,
      set bdd : ℕ → ℕ := λ n, s.aux₀ i (⋃ k ≤ n, s.aux i k) with hbdd,

      have hn' : ∀ n : ℕ, ¬ s.negative (i \ ⋃ l ≤ n, s.aux i l),
      { intro n, 
        convert hn (n + 1), ext l,
        simp only [exists_prop, set.mem_Union, and.congr_left_iff],
        exact λ _, nat.lt_succ_iff.symm },
      have h₁ : s i = s A + ∑' l, s (s.aux i l),
      { rw [hA, ← s.measure_of_disjoint_Union, add_comm, measure_of_diff],
        exact measurable_set.Union (λ _, aux_measurable_set _),
        exacts [hi₁, set.Union_subset (λ _, aux_subset _), λ _, 
                aux_measurable_set _, aux_disjoint] },
      have h₂ : s A ≤ s i,
      { rw h₁,
        apply le_add_of_nonneg_right,
        exact tsum_nonneg (λ n, le_of_lt (measure_of_aux h _ (hn n))) },
      have h₃' : summable (λ n, (1 / (bdd n + 1) : ℝ)),
      { have : summable (λ l, s (s.aux i l)),
          exact summable_measure_of (λ _, aux_measurable_set _) aux_disjoint,
        refine summable_of_nonneg_of_le_succ _ _ this,
        { intro _, exact le_of_lt nat.one_div_pos_of_nat },
        { intro n, exact le_of_lt (aux_lt n (hn' n)) } },
      have h₃ : tendsto (λ n, (bdd n : ℝ) + 1) at_top at_top,
      { simp only [one_div] at h₃',
        exact tendsto_top_of_pos_summable_inv h₃' (λ n, nat.cast_add_one_pos (bdd n)) },
      have h₄ : tendsto (λ n, (bdd n : ℝ)) at_top at_top,
      { convert at_top.tendsto_at_top_add_const_right (-1) h₃, simp },

      refine ⟨A, _, _, _, _⟩,
      { exact measurable_set.diff hi₁ (measurable_set.Union (λ _, aux_measurable_set _)) },
      { exact set.diff_subset _ _ },
      { by_contra hnn,
        rw negative at hnn, push_neg at hnn,
        obtain ⟨E, hE₁, hE₂, hE₃⟩ := hnn,
        have : ∃ k, 1 ≤ bdd k ∧ 1 / (bdd k : ℝ) < s E,
        { rw tendsto_at_top_at_top at h₄,
          obtain ⟨k, hk⟩ := h₄ (max (1 / s E + 1) 1),
          refine ⟨k, _, _⟩,
          { have hle := le_of_max_le_right (hk k le_rfl),
            norm_cast at hle,
            exact hle },
          { have : 1 / s E < bdd k, linarith [le_of_max_le_left (hk k le_rfl)],
            rw one_div at this ⊢,
            rwa inv_lt (lt_trans (inv_pos.2 hE₃) this) hE₃,
          } },
        obtain ⟨k, hk₁, hk₂⟩ := this,
        have hA' : A ⊆ i \ ⋃ l ≤ k, s.aux i l,
        { rw hA,
          apply set.diff_subset_diff_right,
          intro x, simp only [set.mem_Union],
          rintro ⟨n, _, hn₂⟩,
          exact ⟨n, hn₂⟩ },
        refine aux₀_min (hn' k) (nat.sub_one_lt hk₁) _,
        refine ⟨E, set.subset.trans hE₁ hA', hE₂, _⟩,
        convert hk₂, norm_cast,
        exact nat.sub_add_cancel hk₁ },
      { exact lt_of_le_of_lt h₂ hi₂ } },
    { exact exists_negative_set' hi₁ hi₂ hn } }
end .

end exists_negative_set

/-- The set of measurable negative sets. -/
def negatives (s : signed_measure α) : set (set α) := 
  { B | ∃ (hB₁ : measurable_set B), s.negative B }

/-- The set of measures of the set of measurable negative sets. -/
def measure_of_negatives (s : signed_measure α) : set ℝ := 
  s '' s.negatives

lemma zero_mem_measure_of_negatives : (0 : ℝ) ∈ s.measure_of_negatives :=
⟨∅, ⟨measurable_set.empty, empty_negative⟩, s.measure_of_empty⟩

lemma measure_of_negatives_bdd_below : 
  ∃ x, ∀ y ∈ s.measure_of_negatives, x ≤ y :=
begin
  by_contra, push_neg at h,
  have h' : ∀ n : ℕ, ∃ y : ℝ, y ∈ s.measure_of_negatives ∧ y < -n := λ n, h (-n),
  choose f hf using h',
  have hf' : ∀ n : ℕ, ∃ B ∈ s.negatives, s B < -n,
  { intro n,
    rcases hf n with ⟨⟨B, hB₁, hB₂⟩, hlt⟩,
    exact ⟨B, hB₁, hB₂.symm ▸ hlt⟩ },
  choose B hB using hf',
  have hmeas : ∀ n, measurable_set (B n) := λ n, let ⟨h, _⟩ := (hB n).1 in h,
  set A := ⋃ n, B n with hA,
  refine not_forall_le_neg_nat (s A) (λ n, _),
  refine le_trans _ (le_of_lt (hB n).2),
  rw [hA, ← set.diff_union_of_subset (set.subset_Union _ n), 
      measure_of_union (disjoint.comm.1 set.disjoint_diff) _ (hmeas n)],
  { refine add_le_of_nonpos_left _,
    have : s.negative A := negative_Union_negative hmeas (λ m, let ⟨_, h⟩ := (hB m).1 in h),
    refine negative_nonpos_measure _ (negative_subset_negative this (set.diff_subset _ _)),
    refine measurable_set.diff (measurable_set.Union hmeas) (hmeas n) },
  { exact measurable_set.diff (measurable_set.Union hmeas) (hmeas n) },
end

/-- The Hahn decomposition thoerem: Given the signed measure `s`, there exists 
disjoint measurable sets `i`, `j` such that `i` is positive, `j` is negative 
and `i ∪ j = set.univ`.  -/
theorem exists_disjoint_positive_negative_union_eq (s : signed_measure α) :
  ∃ (i j : set α) (hi₁ : measurable_set i) (hi₂ : s.positive i) 
                  (hj₁ : measurable_set j) (hj₂ : s.negative j), 
  disjoint i j ∧ i ∪ j = set.univ :=
begin
  obtain ⟨f, hf₁, hf₂⟩ := exists_tendsto_Inf 
    ⟨0, @zero_mem_measure_of_negatives _ _ s⟩ measure_of_negatives_bdd_below,

  choose B hB using hf₁,
  have hB₁ : ∀ n, measurable_set (B n) := λ n, let ⟨h, _⟩ := (hB n).1 in h,
  have hB₂ : ∀ n, s.negative (B n) := λ n, let ⟨_, h⟩ := (hB n).1 in h,

  set A := ⋃ n, B n with hA,
  have hA₁ : measurable_set A := measurable_set.Union hB₁,
  have hA₂ : s.negative A := negative_Union_negative hB₁ hB₂,
  have hA₃ : s A = Inf s.measure_of_negatives,
  { apply has_le.le.antisymm,
    { refine le_of_tendsto_of_tendsto tendsto_const_nhds hf₂ (eventually_of_forall _),
      intro n,
      rw [← (hB n).2, hA, ← set.diff_union_of_subset (set.subset_Union _ n), 
      measure_of_union (disjoint.comm.1 set.disjoint_diff) _ (hB₁ n)],
      { refine add_le_of_nonpos_left _,
        have : s.negative A := negative_Union_negative hB₁ (λ m, let ⟨_, h⟩ := (hB m).1 in h),
        refine negative_nonpos_measure _ (negative_subset_negative this (set.diff_subset _ _)),
        refine measurable_set.diff (measurable_set.Union hB₁) (hB₁ n) },
      { exact measurable_set.diff (measurable_set.Union hB₁) (hB₁ n) } },
    { exact real.Inf_le _ measure_of_negatives_bdd_below ⟨A, ⟨hA₁, hA₂⟩, rfl⟩ } },

  refine ⟨Aᶜ, A, measurable_set.compl hA₁, _, hA₁, hA₂, 
          disjoint_compl_left, (set.union_comm A Aᶜ) ▸ set.union_compl_self A⟩,
  intros C hC hC₁, 
  by_contra hC₂, push_neg at hC₂,
  rcases exists_negative_set hC₁ hC₂ with ⟨D, hD₁, hD, hD₂, hD₃⟩,

  have : s (A ∪ D) < Inf s.measure_of_negatives,
  { rw [← hA₃, measure_of_union (set.disjoint_of_subset_right (set.subset.trans hD hC) 
        disjoint_compl_right) hA₁ hD₁], 
    linarith },
  refine not_le.2 this _,
  refine real.Inf_le _ measure_of_negatives_bdd_below ⟨A ∪ D, ⟨_, _⟩, rfl⟩,
  { exact measurable_set.union hA₁ hD₁ },
  { exact negative_union_negative hA₁ hA₂ hD₁ hD₂ }
end

/-- Alternative formulation of `exists_disjoint_positive_negative_union_eq`. -/
lemma exists_compl_positive_negative (s : signed_measure α) :
  ∃ (i : set α) (hi₁ : measurable_set i), s.positive i ∧ s.negative iᶜ :=
begin
  obtain ⟨i, j, hi₁, hi₂, _, hj₂, hdisj, huniv⟩ := 
    s.exists_disjoint_positive_negative_union_eq,
  refine ⟨i, hi₁, hi₂, _⟩,
  rw [set.compl_eq_univ_diff, ← huniv, 
      set.union_diff_cancel_left (set.disjoint_iff.mp hdisj)],
  exact hj₂,
end

/-- The symmetric difference of two Hahn decompositions is a null-set. -/
lemma of_symm_diff_compl_positive_negative {s : signed_measure α} 
  {i j : set α} (hi : measurable_set i) (hj : measurable_set j) 
  (hi' : s.positive i ∧ s.negative iᶜ) (hj' : s.positive j ∧ s.negative jᶜ) : 
  s (i Δ j) = 0 ∧ s (iᶜ Δ jᶜ) = 0 :=
begin
  split,
  { rw [symm_diff_def, set.diff_eq_compl_inter, set.diff_eq_compl_inter, 
        set.sup_eq_union, measure_of_union, 
        le_antisymm (hi'.2 _ (set.inter_subset_left _ _) 
          (measurable_set.inter (measurable_set.compl hi) hj)) 
          (hj'.1 _ ( set.inter_subset_right _ _) 
          (measurable_set.inter (measurable_set.compl hi) hj)), 
        le_antisymm (hj'.2 _ (set.inter_subset_left _ _) 
          (measurable_set.inter (measurable_set.compl hj) hi)) 
          (hi'.1 _ (set.inter_subset_right _ _) 
          (measurable_set.inter (measurable_set.compl hj) hi)), add_zero],
    { exact set.disjoint_of_subset_left (set.inter_subset_left _ _) 
        (set.disjoint_of_subset_right (set.inter_subset_right _ _) 
        (disjoint.comm.1 j.disjoint_compl)) },
    { exact measurable_set.inter (measurable_set.compl hj) hi },
    { exact measurable_set.inter (measurable_set.compl hi) hj } },
  { rw [symm_diff_def, set.diff_eq_compl_inter, set.diff_eq_compl_inter,
        compl_compl, compl_compl, set.sup_eq_union, measure_of_union, 
        le_antisymm (hi'.2 _ (set.inter_subset_right _ _) 
          (measurable_set.inter hj (measurable_set.compl hi))) 
          (hj'.1 _ (set.inter_subset_left _ _) 
          (measurable_set.inter hj (measurable_set.compl hi))),
        le_antisymm (hj'.2 _ (set.inter_subset_right _ _) 
          (measurable_set.inter hi (measurable_set.compl hj))) 
          (hi'.1 _ (set.inter_subset_left _ _) 
          (measurable_set.inter hi (measurable_set.compl hj))), add_zero],
    { exact set.disjoint_of_subset_left (set.inter_subset_left _ _) 
        (set.disjoint_of_subset_right (set.inter_subset_right _ _) j.disjoint_compl) },
    { exact measurable_set.inter hj hi.compl },
    { exact measurable_set.inter hi hj.compl } }
end

end signed_measure