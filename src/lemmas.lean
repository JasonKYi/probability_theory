import measure_theory.integration
import data.real.ereal

/-
This file contains some lemmas that were used elsewhere but did not fit in that 
file.
-/

noncomputable theory
open_locale classical big_operators nnreal ennreal

variables {α β : Type*}

open ennreal set

section tsum

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

open filter

lemma tsum_nonneg_coe_eq_top_of_not_summable (f : ℕ → ℝ≥0)
  (h : ¬ summable (λ (i : ℕ), (f i : ℝ))) :
  ∑' (a : ℕ), (f a : ℝ≥0∞) = ⊤ :=
begin
  by_contra h',
  rw [← ne.def, ennreal.tsum_coe_ne_top_iff_summable] at h',
  exact h (nnreal.summable_coe.mpr h'), 
end

lemma tsum_to_real_of_not_summable {f : ℕ → ℝ≥0∞} (hf : ∀ a, f a ≠ ⊤) 
  (h : ¬ summable (ennreal.to_real ∘ f)) : 
  (∑' a, f a).to_real = ∑' a, (f a).to_real :=
begin
  lift f to ℕ → ℝ≥0 using hf,
  change ¬ summable (λ i, (f i : ℝ≥0∞).to_real) at h, 
  simp_rw [coe_to_real] at h ⊢,
  rw [tsum_eq_zero_of_not_summable h, 
      tsum_nonneg_coe_eq_top_of_not_summable _ h, top_to_real],
end

lemma tsum_to_real (f : ℕ → ℝ≥0∞) (hf : ∀ a, f a ≠ ⊤) : 
  (∑' a, f a).to_real = ∑' a, (f a).to_real :=
begin
  by_cases summable (ennreal.to_real ∘ f),
  exact tsum_to_real_of_summable hf h,
  exact tsum_to_real_of_not_summable hf h,
end

lemma summable_of_nonneg_of_le_succ {f g : ℕ → ℝ}
  (hg : ∀ n, 0 ≤ g n) (hgf : ∀ n, g n ≤ f n.succ) (hf : summable f) : summable g :=
summable_of_nonneg_of_le hg hgf $ summable.comp_injective hf nat.succ_injective

lemma nnreal.summable_coe_of_summable {f : ℕ → ℝ} 
  (hf₁ : ∀ n, 0 ≤ f n) (hf₂ : summable f) : 
  @summable (ℝ≥0) _ _ _ (λ n, ⟨f n, hf₁ n⟩) :=
begin
  lift f to ℕ → ℝ≥0, -- using hf₁ doesn't work here
  { exact nnreal.summable_coe.mp hf₂ },
  { exact hf₁ }
end

lemma nnreal.tsum_coe_eq_of_nonneg {f : ℕ → ℝ} (hf₁ : ∀ n, 0 ≤ f n) :
  (∑' n, ⟨f n, hf₁ n⟩ : ℝ≥0) = ⟨∑' n, f n, tsum_nonneg hf₁⟩ :=
begin
  lift f to ℕ → ℝ≥0,
  { simp_rw [← nnreal.coe_tsum, subtype.coe_eta] },
  { exact hf₁ }
end

end tsum

section filter

open filter

lemma tendsto_top_of_pos_summable_inv {f : ℕ → ℝ} 
  (hf : summable f⁻¹) (hf' : ∀ n, 0 < f n) : tendsto f at_top at_top :=
begin
  rw [show  f = f⁻¹⁻¹, by { ext, simp }],
  apply filter.tendsto.inv_tendsto_zero,
  apply tendsto_nhds_within_of_tendsto_nhds_of_eventually_within _ 
    (summable.tendsto_at_top_zero hf),
  rw eventually_iff_exists_mem,
  refine ⟨set.Ioi 0, Ioi_mem_at_top _, λ _ _, _⟩,
  rw [set.mem_Ioi, inv_eq_one_div, one_div, pi.inv_apply, _root_.inv_pos],
  exact hf' _,
end

lemma exists_tendsto_Inf {S : set ℝ} (hS : ∃ x, x ∈ S) (hS' : ∃ x, ∀ y ∈ S, x ≤ y) : 
  ∃ (f : ℕ → ℝ) (hf : ∀ n, f n ∈ S), tendsto f at_top (nhds (Inf S)) :=
begin
  have : ∀ n : ℕ, ∃ t ∈ S, t < Inf S + 1 / (n + 1 : ℝ),
  { exact λ n, (real.Inf_lt _ hS hS').1 ((lt_add_iff_pos_right _).2 nat.one_div_pos_of_nat) }, 
  choose f hf using this,
  refine ⟨f,λ n, (hf n).1, _⟩,
  rw tendsto_iff_dist_tendsto_zero,
  refine squeeze_zero_norm _ tendsto_one_div_add_at_top_nhds_0_nat, 
  intro n,
  obtain ⟨hf₁, hf₂⟩ := hf n,
  rw [real.dist_eq, real.norm_eq_abs, abs_abs, 
      abs_of_nonneg (sub_nonneg.2 (real.Inf_le S hS' hf₁))], 
  linarith,
end

lemma tendsto_le_of_forall_le {f g : ℕ → ℝ} {a b : ℝ} (hfg : ∀ n, f n ≤ g n)
  (hf : tendsto f at_top (nhds a)) (hg : tendsto g at_top (nhds b)) :
  a ≤ b :=
begin
  apply le_of_tendsto_of_tendsto hf hg,
  rw [eventually_le, eventually_iff_exists_mem],
  exact ⟨set.Ioi 0, Ioi_mem_at_top _, λ n _, hfg n⟩,
end

lemma le_of_le_tendsto {f : ℕ → ℝ} {a b : ℝ}
  (hf₁ : tendsto f at_top (nhds b)) (hf₂ : ∀ n, a ≤ f n) : a ≤ b :=
tendsto_le_of_forall_le hf₂ tendsto_const_nhds hf₁


end filter

section nat

lemma nat.sub_one_lt {n : ℕ} (hn : 1 ≤ n) : n - 1 < n :=
begin
  induction n with k hk,
  { norm_num at hn },
  { rw [nat.succ_sub_succ_eq_sub, nat.sub_zero], exact lt_add_one k }
end

lemma not_forall_le_neg_nat (a : ℝ) (ha : ∀ n : ℕ, a ≤ -n) : false :=
begin
  suffices : ¬ ∀ n : ℕ, a ≤ -n,
  { exact this ha },
  push_neg, 
  rcases exists_nat_gt (-a) with ⟨n, hn⟩,
  exact ⟨n, neg_lt.1 hn⟩,
end

end nat

section set

lemma set.Union_eq_union {ι} (f : ι → set α) (j : ι) : 
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

lemma set.union_inter_diff_eq {a b c : set α} (habc : a ⊆ b ∪ c) : 
  a ∩ b ∪ a ∩ c \ (a ∩ b) = a :=
begin
  ext x, split,
  { rintro (h | h),
    exacts [h.1, h.1.1] },
  { intro ha,
    by_cases x ∈ b,
    { left, exact ⟨ha, h⟩ },
    { right, 
      obtain (ha' | ha') := habc ha,
      exacts [false.elim (h  ha'), ⟨⟨ha, ha'⟩, not_and.2 (λ _, h)⟩] } }
end

lemma set.union_inter_diff_disjoint {a b c : set α} : 
  disjoint (a ∩ b) (a ∩ c \ (a ∩ b)) := 
begin
  rintro x ⟨⟨hxa, hxb⟩, _, hxab⟩,
  exact hxab ⟨hxa, hxb⟩,
end

lemma set.Union_inter_diff_eq {f : ℕ → set α} {a : set α} (ha : a ⊆ ⋃ n, f n) : 
  (⋃ n, a ∩ f n \ ⋃ k < n, f k) = a :=
begin
  ext x, 
  simp only [not_exists, exists_prop, mem_Union, mem_inter_eq, not_and, mem_diff],
  split,
  { rintro ⟨_, ⟨_, _⟩, _⟩, assumption },
  { intro hx,
    let n := nat.find (mem_Union.1 (ha hx)),
    exact ⟨n, ⟨hx, nat.find_spec (mem_Union.1 (ha hx))⟩, λ m hm, nat.find_min _ hm⟩ }
end

lemma set.Union_inter_diff_disjoint {f : ℕ → set α} {a : set α} : 
  pairwise $ disjoint on (λ n,  a ∩ f n \ ⋃ k < n, f k) :=
begin
  rintro n m hnm x ⟨⟨hxn₁, hxn₂⟩, hxm₁, hxm₂⟩,
  simp only [not_exists, exists_prop, mem_Union, mem_empty_eq, mem_inter_eq, 
             not_and, bot_eq_empty, ne.def] at *,
  rcases lt_or_gt_of_ne hnm with (h | h),
  { exact hxm₂ _ h hxn₁.2 },
  { exact hxn₂ _ h hxm₁.2 }
end

end set

section real

lemma real.norm_of_neg {x : ℝ} (hx : x < 0) : ∥x∥ = -x :=
abs_of_neg hx

end real