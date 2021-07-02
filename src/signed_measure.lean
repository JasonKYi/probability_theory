import measure_theory.integration
import data.real.ereal

noncomputable theory
open_locale classical big_operators nnreal ennreal

variables {α β : Type*}
variables [measurable_space α] [measurable_space β] 

namespace measure_theory

def absolutely_continuous (ν μ : measure α) : Prop := 
  ∀ (A : set α) (hA₁ : measurable_set A) (hA₂ : μ A = 0), ν A = 0 

variables {μ : measure α}

local infix ` << `:60 := absolutely_continuous
local infix ` . `:max := measure.with_density

lemma lintegral_in_eq_zero {f : α → ℝ≥0∞} (hf : measurable f) 
  {A : set α} (hA : μ A = 0) : ∫⁻ a in A, f a ∂μ = 0 :=
begin
  rw lintegral_eq_zero_iff hf,
  ext, 
  rw measure.restrict_zero_set hA, 
  refl,
end  

lemma map_absolutely_continuous (f : α → ℝ≥0∞) (hf : measurable f) (μ : measure α) : 
  μ . f << μ :=
begin
  intros A hA₁ hA₂,
  rw with_density_apply _ hA₁,
  exact lintegral_in_eq_zero hf hA₂
end 

-- We note that a signed measure cannot achieve both `±∞` at the same time since 
-- we want to avoid the case of `∞ - ∞`.
structure signed_measure (α : Type*) [measurable_space α] :=
(measure_of : set α → ℝ)
(empty : measure_of ∅ = 0)
(m_Union ⦃f : ℕ → set α⦄ :
  (∀ i, measurable_set (f i)) → pairwise (disjoint on f) → --summable (measure_of ∘ f) →
  measure_of (⋃ i, f i) = ∑' i, measure_of (f i))

open ennreal set

lemma tsum_to_real_of_summable {f : α → ℝ≥0∞} (hf : ∀ a, f a ≠ ⊤) 
  (h : summable (ennreal.to_real ∘ f)) : 
  (∑' a, f a).to_real = ∑' a, (f a).to_real :=
begin
  obtain ⟨r, hr⟩ := h,
  rw has_sum.tsum_eq hr,
  have hr' : (ennreal.of_real r).to_real = r,
  { rw ennreal.to_real_of_real,
    rw ← has_sum.tsum_eq hr,
    apply tsum_nonneg,
    intro x,
    exact to_real_nonneg }, 
  suffices : has_sum f (ennreal.of_real r),
  { rw has_sum.tsum_eq this,
    exact hr' },
  rw has_sum at *,
  rw ← tendsto_to_real_iff,
  { convert hr, ext s,
    { rw to_real_sum,
      intros a _,
      exact lt_top_iff_ne_top.2 (hf a) } },
  { intros s hs,
    rw sum_eq_top_iff at hs,
    obtain ⟨x, _, hx⟩ := hs,
    exact (hf x) hx },
  { exact ennreal.of_real_ne_top } 
end

lemma tsum_to_real_of_not_summable {f : α → ℝ≥0∞} (hf : ∀ a, f a ≠ ⊤) 
  (h : ¬ summable (ennreal.to_real ∘ f)) : 
  (∑' a, f a).to_real = ∑' a, (f a).to_real :=
begin
  rw [tsum_eq_zero_of_not_summable h, to_real_eq_zero_iff],
  apply or.inr,
  suffices : has_sum f ⊤,
  { rw has_sum.tsum_eq this },
  rw has_sum,
  sorry
end

lemma tsum_to_real (f : α → ℝ≥0∞) (hf : ∀ a, f a ≠ ⊤) : 
  (∑' a, f a).to_real = ∑' a, (f a).to_real :=
begin
  by_cases summable (ennreal.to_real ∘ f),
  exact tsum_to_real_of_summable hf h,
  exact tsum_to_real_of_not_summable hf h,
end

namespace signed_measure

variables {s : signed_measure α} {f : ℕ → set α}

lemma measure_Union [encodable β] {f : β → set α}
  (hn : pairwise (disjoint on f)) (h : ∀ i, measurable_set (f i)) :
  s.measure_of (⋃ i, f i) = ∑' i, s.measure_of (f i) :=
begin
  -- rw [← encodable.Union_decode₂, ← tsum_Union_decode₂],
  sorry
end

lemma measure_of_union {s : signed_measure α} {A B : set α} 
  (h : disjoint A B) (hA : measurable_set A) (hB : measurable_set B) : 
  s.measure_of (A ∪ B) = s.measure_of A + s.measure_of B :=
begin
  rw [union_eq_Union, measure_Union, tsum_fintype, fintype.sum_bool, cond, cond],
  exacts [pairwise_disjoint_on_bool.2 h, λ b, bool.cases_on b hB hA]
end

lemma measure_of_nonneg_disjoint_union_eq_zero {s : signed_measure α} {A B : set α}
  (h : disjoint A B) (hA₁ : measurable_set A) (hB₁ : measurable_set B)
  (hA₂ : 0 ≤ s.measure_of A) (hB₂ : 0 ≤ s.measure_of B) 
  (hAB : s.measure_of (A ∪ B) = 0) : s.measure_of A = 0 := 
begin
  rw measure_of_union h hA₁ hB₁ at hAB,
  linarith,
end

lemma measure_of_nonpos_disjoint_union_eq_zero {s : signed_measure α} {A B : set α}
  (h : disjoint A B) (hA₁ : measurable_set A) (hB₁ : measurable_set B)
  (hA₂ : s.measure_of A ≤ 0) (hB₂ : s.measure_of B ≤ 0) 
  (hAB : s.measure_of (A ∪ B) = 0) : s.measure_of A = 0 := 
begin
  rw measure_of_union h hA₁ hB₁ at hAB,
  linarith,
end

lemma Union_eq_union {ι} (f : ι → set α) (j : ι) : 
  (⋃ i, f i) = f j ∪ ⋃ (i : ι) (hi : i ≠ j), f i :=
begin
  ext x, 
  simp only [exists_prop, mem_Union, mem_union_eq], 
  split,
  { rintro ⟨i, hi⟩,
    by_cases i = j,
    { exact or.inl (h ▸ hi) },
    { exact or.inr ⟨i, h, hi⟩ } },
  { rintro (hj | ⟨i, hij, hi⟩),
    { exact ⟨j, hj⟩ },
    { exact ⟨i, hi⟩ } }
end

lemma measure_of_Union_nonneg (hf₁ : ∀ i, measurable_set (f i)) 
  (hf₂ : pairwise (disjoint on f)) (hf₃ : ∀ i, 0 ≤ s.measure_of (f i)) :
  0 ≤ s.measure_of (⋃ i, f i) := 
(s.m_Union hf₁ hf₂).symm ▸ tsum_nonneg hf₃

lemma measure_of_Union_nonpos (hf₁ : ∀ i, measurable_set (f i)) 
  (hf₂ : pairwise (disjoint on f)) (hf₃ : ∀ i, s.measure_of (f i) ≤ 0) :
  s.measure_of (⋃ i, f i) ≤ 0 := 
(s.m_Union hf₁ hf₂).symm ▸ tsum_nonpos hf₃

lemma summable_measure_of_nonneg 
  (hf₁ : ∀ i, measurable_set (f i)) 
  (hf₂ : pairwise (disjoint on f)) 
  (hf₃ : ∀ i, 0 ≤ s.measure_of (f i)) : 
  summable (s.measure_of ∘ f) :=
begin
  have := s.m_Union hf₁ hf₂,
  by_cases s.measure_of (⋃ (i : ℕ), (λ (i : ℕ), f i) i) = 0,
  { suffices : ∀ i, s.measure_of (f i) = 0,
    { convert summable_zero, ext i, exact this i },
    intro i, rw Union_eq_union f i at h,
    refine measure_of_nonneg_disjoint_union_eq_zero _ (hf₁ i) _ (hf₃ i) _ h,
    { intros x hx,
      simp only [exists_prop, mem_Union, mem_inter_eq, inf_eq_inter] at hx,
      exact let ⟨hfi, j, hij, hfj⟩ := hx in hf₂ j i hij ⟨hfj, hfi⟩ },
    { refine measurable_set.Union (λ j, _),
      by_cases i = j,
      { convert measurable_set.empty, 
        rw Union_eq_empty,
        exact λ hij, false.elim (hij h.symm) },
      { convert hf₁ j,
        ext x, rw [mem_Union, exists_prop, and_iff_right_iff_imp],
        exact λ _, ne.symm h } },
    { refine measure_of_Union_nonneg _ _ _,
      { intro j,
        by_cases i = j,
        { convert measurable_set.empty, 
          rw Union_eq_empty,
          exact λ hij, false.elim (hij h.symm) },
        { convert hf₁ j,
          ext x, rw [mem_Union, exists_prop, and_iff_right_iff_imp],
         exact λ _, ne.symm h } },
      { intros l m hlm x hx,
        simp only [exists_prop, mem_Union, mem_inter_eq, inf_eq_inter] at hx,
        exact hf₂ l m hlm (let ⟨⟨_, h₁⟩, _, h₂⟩ := hx in ⟨h₁, h₂⟩) },
      { intro j,
        by_cases i = j,
        { apply le_of_eq,
          convert s.empty.symm,
          rw Union_eq_empty,
          exact λ hij, false.elim (hij h.symm) },
        { convert hf₃ j,
          ext, rw [mem_Union, exists_prop, and_iff_right_iff_imp],
          exact λ _, ne.symm h } } } },
  { revert h,
    contrapose,
    intro h,
    rw [not_not, this, tsum_eq_zero_of_not_summable h] },
end

lemma summable_measure_of_nonpos  
  (hf₁ : ∀ i, measurable_set (f i)) 
  (hf₂ : pairwise (disjoint on f)) 
  (hf₃ : ∀ i, s.measure_of (f i) ≤ 0) : 
  summable (s.measure_of ∘ f) :=
begin
  have := s.m_Union hf₁ hf₂,
  by_cases s.measure_of (⋃ (i : ℕ), (λ (i : ℕ), f i) i) = 0,
  { suffices : ∀ i, s.measure_of (f i) = 0,
    { convert summable_zero, ext i, exact this i },
    intro i, rw Union_eq_union f i at h,
    refine measure_of_nonpos_disjoint_union_eq_zero _ (hf₁ i) _ (hf₃ i) _ h,
    { intros x hx,
      simp only [exists_prop, mem_Union, mem_inter_eq, inf_eq_inter] at hx,
      exact let ⟨hfi, j, hij, hfj⟩ := hx in hf₂ j i hij ⟨hfj, hfi⟩ },
    { refine measurable_set.Union (λ j, _),
      by_cases i = j,
      { convert measurable_set.empty, 
        rw Union_eq_empty,
        exact λ hij, false.elim (hij h.symm) },
      { convert hf₁ j,
        ext x, rw [mem_Union, exists_prop, and_iff_right_iff_imp],
        exact λ _, ne.symm h } },
    { refine measure_of_Union_nonpos _ _ _,
      { intro j,
        by_cases i = j,
        { convert measurable_set.empty, 
          rw Union_eq_empty,
          exact λ hij, false.elim (hij h.symm) },
        { convert hf₁ j,
          ext x, rw [mem_Union, exists_prop, and_iff_right_iff_imp],
         exact λ _, ne.symm h } },
      { intros l m hlm x hx,
        simp only [exists_prop, mem_Union, mem_inter_eq, inf_eq_inter] at hx,
        exact hf₂ l m hlm (let ⟨⟨_, h₁⟩, _, h₂⟩ := hx in ⟨h₁, h₂⟩) },
      { intro j,
        by_cases i = j,
        { apply le_of_eq,
          convert s.empty,
          rw Union_eq_empty,
          exact λ hij, false.elim (hij h.symm) },
        { convert hf₃ j,
          ext, rw [mem_Union, exists_prop, and_iff_right_iff_imp],
          exact λ _, ne.symm h } } } },
  { revert h,
    contrapose,
    intro h,
    rw [not_not, this, tsum_eq_zero_of_not_summable h] },
end

lemma real.norm_of_neg {x : ℝ} (hx : x < 0) : ∥x∥ = -x :=
abs_of_neg hx

def measure_of_nonneg_seq (s : signed_measure α) (f : ℕ → set α) : ℕ → set α := 
λ i, if 0 ≤ (s.measure_of ∘ f) i then f i else ∅

lemma measure_of_nonneg_seq_nonneg (i : ℕ) : 
  0 ≤ s.measure_of (s.measure_of_nonneg_seq f i) := 
begin
  by_cases 0 ≤ (s.measure_of ∘ f) i,
  { simp_rw [measure_of_nonneg_seq, if_pos h],
    exact h },
  { simp_rw [measure_of_nonneg_seq, if_neg h, s.empty] }
end

lemma measure_of_nonneg_seq_of_measurable_set (hf : ∀ i, measurable_set (f i)) 
  (i : ℕ) : measurable_set $ measure_of_nonneg_seq s f i :=
begin
  by_cases 0 ≤ (s.measure_of ∘ f) i,
  { simp_rw [measure_of_nonneg_seq, if_pos h],
    exact hf i },
  { simp_rw [measure_of_nonneg_seq, if_neg h],
    exact measurable_set.empty }
end

lemma measure_of_nonneg_seq_of_disjoint (hf : pairwise (disjoint on f)) : 
  pairwise $ disjoint on (s.measure_of_nonneg_seq f) :=
begin
  rintro i j hij x ⟨hx₁, hx₂⟩,
  by_cases hi : 0 ≤ (s.measure_of ∘ f) i,
  { by_cases hj : 0 ≤ (s.measure_of ∘ f) j,
    { simp_rw [measure_of_nonneg_seq, if_pos hi] at hx₁,
      simp_rw [measure_of_nonneg_seq, if_pos hj] at hx₂,
      exact hf i j hij ⟨hx₁, hx₂⟩ },
    { simp_rw [measure_of_nonneg_seq, if_neg hj] at hx₂,
      exact false.elim hx₂ } },
  { simp_rw [measure_of_nonneg_seq, if_neg hi] at hx₁,
    exact false.elim hx₁ }
end

def measure_of_nonpos_seq (s : signed_measure α) (f : ℕ → set α) : ℕ → set α := 
λ i, if ¬ 0 ≤ (s.measure_of ∘ f) i then f i else ∅

lemma measure_of_nonpos_seq_nonpos (i : ℕ) : 
  s.measure_of (s.measure_of_nonpos_seq f i) ≤ 0 := 
begin
  by_cases ¬ 0 ≤ (s.measure_of ∘ f) i,
  { simp_rw [measure_of_nonpos_seq, if_pos h],
    exact le_of_not_ge h },
  { simp_rw [measure_of_nonpos_seq, if_neg h, s.empty] }
end

lemma measure_of_nonpos_seq_of_measurable_set (hf : ∀ i, measurable_set (f i)) 
  (i : ℕ) : measurable_set $ measure_of_nonpos_seq s f i :=
begin
  by_cases ¬ 0 ≤ (s.measure_of ∘ f) i,
  { simp_rw [measure_of_nonpos_seq, if_pos h],
    exact hf i },
  { simp_rw [measure_of_nonpos_seq, if_neg h],
    exact measurable_set.empty }
end

lemma measure_of_nonpos_seq_of_disjoint (hf : pairwise (disjoint on f)) : 
  pairwise $ disjoint on (s.measure_of_nonpos_seq f) :=
begin
  rintro i j hij x ⟨hx₁, hx₂⟩,
  by_cases hi : ¬ 0 ≤ (s.measure_of ∘ f) i,
  { by_cases hj : ¬ 0 ≤ (s.measure_of ∘ f) j,
    { simp_rw [measure_of_nonpos_seq, if_pos hi] at hx₁,
      simp_rw [measure_of_nonpos_seq, if_pos hj] at hx₂,
      exact hf i j hij ⟨hx₁, hx₂⟩ },
    { simp_rw [measure_of_nonpos_seq, if_neg hj] at hx₂,
      exact false.elim hx₂ } },
  { simp_rw [measure_of_nonpos_seq, if_neg hi] at hx₁,
    exact false.elim hx₁ }
end

lemma measure_of_seq_eq (i : ℕ) : 
  ∥s.measure_of (f i)∥ = 
    s.measure_of (s.measure_of_nonneg_seq f i) - 
    s.measure_of (s.measure_of_nonpos_seq f i) :=
begin
  rw [measure_of_nonneg_seq, measure_of_nonpos_seq],
  by_cases 0 ≤ (s.measure_of ∘ f) i,
  { have : ¬¬0 ≤ (s.measure_of ∘ f) i := not_not.2 h,
    simp_rw [real.norm_of_nonneg h, if_pos h, if_neg this, 
             s.empty, _root_.sub_zero] },
  { simp_rw [real.norm_of_neg (lt_of_not_ge h), if_pos h, if_neg h,
             s.empty, _root_.zero_sub] }
end

  -- { ext i,
  --   by_cases 0 ≤ (s.measure_of ∘ f) i,
  --   { rw [real.norm_of_nonneg h, if_pos h] },
  --   { rw [real.norm_of_neg (lt_of_not_ge h), if_neg h] } },

lemma summable_measure_of 
  (hf₁ : ∀ i, measurable_set (f i)) (hf₂ : pairwise (disjoint on f)) : 
  summable (s.measure_of ∘ f) :=
begin
  /- 
    It suffices to show `∑ |s.measure_of ∘ f| < ∞`.
    Let `N+ := { i | s(f i) ≥ 0 }`
    and `N- := { i | s(f i) < 0 }`
    Then, `Σ i, |s ∘ f i| = ∑ i ∈ N+, s ∘ f i - ∑ i ∈ N-, s ∘ f i`
    Clearly, both sum are finite since `s.range = ℝ`.  
  -/
  apply summable_of_summable_norm,
  simp_rw measure_of_seq_eq,
  apply summable.sub,
  { apply summable_measure_of_nonneg,
    exact measure_of_nonneg_seq_of_measurable_set hf₁,
    exact measure_of_nonneg_seq_of_disjoint hf₂,
    exact measure_of_nonneg_seq_nonneg },
  { apply summable_measure_of_nonpos,
    exact measure_of_nonpos_seq_of_measurable_set hf₁,
    exact measure_of_nonpos_seq_of_disjoint hf₂,
    exact measure_of_nonpos_seq_nonpos },
end

def of_measure (μ : measure α) [hμ : finite_measure μ] : signed_measure α := 
{ measure_of := ennreal.to_real ∘ μ.measure_of,
  empty := by simp [μ.empty],
  m_Union := 
  begin
    intros _ hf₁ hf₂,
    rw [function.comp_apply, μ.m_Union hf₁ hf₂, tsum_to_real],
    intros a ha,
    apply ne_of_lt hμ.measure_univ_lt_top,
    rw [eq_top_iff, ← ha, outer_measure.measure_of_eq_coe, 
        coe_to_outer_measure],
    exact measure_mono (set.subset_univ _),
  end }

def neg (s : signed_measure α) : signed_measure α := 
{ measure_of := - s.measure_of,
  empty := by simp [s.empty],
  m_Union := 
  begin
    intros f hf₁ hf₂,
    change - _ = _,
    rw [s.m_Union hf₁ hf₂, ← tsum_neg], refl,
    exact summable_measure_of hf₁ hf₂
  end }

def add (s t : signed_measure α) : signed_measure α := 
{ measure_of := s.measure_of + t.measure_of,
  empty := by simp [s.empty, t.empty],
  m_Union := 
  begin
    intros f hf₁ hf₂,
    simp only [pi.add_apply],
    rw [tsum_add, s.m_Union hf₁ hf₂, t.m_Union hf₁ hf₂];
    exact summable_measure_of hf₁ hf₂
  end }

instance : has_add (signed_measure α) := ⟨add⟩
instance : has_neg (signed_measure α) := ⟨neg⟩

def of_sub_measure (μ ν : measure α) [hμ : finite_measure μ] [hν : finite_measure ν] : 
  signed_measure α := 
of_measure μ + - of_measure ν

end signed_measure


end measure_theory