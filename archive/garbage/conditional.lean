import probability_theory.independence
import singular

/- In this file we define the conditional expectation of a random variable 
with respect to some sub-Ï-algebra. -/

noncomputable theory
open_locale classical big_operators nnreal ennreal

variables {Î± Î² : Type*}

namespace measure_theory

local infix ` . `:max := measure.with_density

local notation Ï ` .[`:25 ð:25 `] `:0 f := @measure.with_density _ ð Ï f
local notation Î¼ ` âª[`:25 ð:25 `] `:0 Î½ := @measure.absolutely_continuous _ ð Î¼ Î½ 

local notation `â«â»[`:25 ð:25 `]` binders `, ` r:(scoped:60 f, f) ` â` Î¼:70 := 
  @lintegral _ ð Î¼ r
local notation `â«â»[`:25 ð:25 `]` binders ` in ` s `, ` r:(scoped:60 f, f) ` â` Î¼:70 :=
  @lintegral _ ð (@measure.restrict _ ð Î¼ s) r

section

variables [measurable_space Î±] {Î¼ : measure Î±}

lemma lintegral_add_lt_top {f g : Î± â ââ¥0â} (hfâ : measurable f) (hgâ : measurable g)
  (hfâ : â«â» a, f a âÎ¼ < â) (hgâ : â«â» a, g a âÎ¼ < â) : â«â» a, f a + g a âÎ¼ < â :=
begin
  rw lintegral_add hfâ hgâ,
  exact ennreal.add_lt_top.2 â¨hfâ, hgââ©,
end

#check lintegral_eq_zero_iff

lemma ae_eq_of_abs_sub_ae_eq {f g : Î± â â} 
  (hf : measurable f) (hg : measurable g) : 
  f - g =áµ[Î¼] 0 â f =áµ[Î¼] g :=
begin
  sorry
end

lemma ae_eq_of_with_density_eq {f g : Î± â ââ¥0â} 
  (hf : measurable f) (hg : measurable g) (h : Î¼ . f = Î¼ . g) : 
  f =áµ[Î¼] g :=
begin
  sorry,
end

section

variables {ð ð : measurable_space Î±} (h : ð â¤ ð) {Ï : @measure Î± ð}

-- Note `f` is measurable w.r.t. to `ð` (which is stronger than measurable w.r.t. to `ð`).
lemma lintegral_in_trim {f : Î± â ââ¥0â} (hf : measurable f) 
  {s : set Î±} (hs : measurable_set s) : 
  â«â» x in s, f x â(Ï.trim h) = â«â»[ð] x in s, f x âÏ :=
by rw [restrict_trim h _ hs, lintegral_trim h hf]

-- same here
lemma trim_with_density_eq {f : Î± â ââ¥0â} (hf : measurable f) :
  (Ï.trim h) . f = (Ï .[ð] f).trim h :=
begin
  refine measure.ext (Î» s hs, _),
  rw [with_density_apply _ hs, trim_measurable_set_eq _ hs, 
      lintegral_in_trim h hf hs, with_density_apply],
  exact h _ hs,
end

end

end

open measure_theory.measure probability_theory

lemma measure.trim_absolutely_continuous {ð ð : measurable_space Î±} {Î¼ Î½ : @measure Î± ð} 
  (h : ð â¤ ð) (hÎ¼Î½ : Î¼ âª[ð] Î½) : Î¼.trim h âª[ð] Î½.trim h :=
begin
  refine absolutely_continuous.mk (Î» s hsâ hsâ, _),
  rw [measure.trim, to_measure_apply _ _ hsâ, to_outer_measure_apply, 
      hÎ¼Î½ (nonpos_iff_eq_zero.1 (hsâ â¸ le_trim h) : Î½ s = 0)],
end

lemma measure.with_density_trim_absolutely_continuous
  {ð ð : measurable_space Î±} (Î¼ : @measure Î± ð) (h : ð â¤ ð) (f : Î± â ââ¥0â) : 
  (Î¼ .[ð] f).trim h âª Î¼.trim h :=
measure.trim_absolutely_continuous h $ @with_density_absolutely_continuous _ ð Î¼ f

/- 
Perhaps it would make more sense to define conditional probability using `fact`. 

I am worried that when applying lemmas such as `condition_on_add`, Lean will find 
two different proofs for the arguments, and so won't be able to apply. 
-/

/-- Given a real-valued random `f` variable with finite expectation, its conditional 
expectation with respect to some sub-Ï-algebra `ð`, is a `ð`-random variable `g` 
such that for all `ð`-measurable sets `s`, `â«â» x in s, f x âÏ = â«â» x in s, g x âÏ`. 

This definition of contional expectation allow us to define the usual notion of 
contional probability. In particular, for all events `A â ð`, `ð¼(A | ð)` is the 
condition of `ð` on the indicator function on `A`; and for all random variables 
`h`, the expectation of `f` with respect to `h` is the condition of `f` on `Ï(h)`. -/
def condition_on {ð ð : measurable_space Î±} (h : ð â¤ ð) 
  (Ï : @measure Î± ð) [@finite_measure Î± ð Ï] (f : Î± â ââ¥0â) 
  (hfâ : @measurable _ _ ð _ f) (hfâ : â«â»[ð] x, f x âÏ < â) : Î± â ââ¥0â :=
classical.some 
  (@signed_measure.exists_with_density_of_absolute_continuous _ _ 
    (Ï.trim h) ((Ï .[ð] f).trim h) _ 
    (@measure_theory.finite_measure_trim _ _ _ _ h $ 
      @finite_measure_with_density Î± ð _ _ hfâ)
    (measure.trim_absolutely_continuous h $ 
      @with_density_absolutely_continuous Î± ð Ï f)) 

namespace condition_on

variables {ð ð : measurable_space Î±} (h : ð â¤ ð) 
  (Ï : @measure Î± ð) [@finite_measure Î± ð Ï] (f g : Î± â ââ¥0â) 
  (hfâ : @measurable _ _ ð _ f) (hfâ : â«â»[ð] x, f x âÏ < â)
  (hgâ : @measurable _ _ ð _ g) (hgâ : â«â»[ð] x, g x âÏ < â)

lemma condition_on_measurable : measurable (condition_on h Ï f hfâ hfâ) :=
(exists_prop.1 (classical.some_spec 
  (@signed_measure.exists_with_density_of_absolute_continuous _ _ 
    (Ï.trim h) ((Ï .[ð] f).trim h) _ 
    (@measure_theory.finite_measure_trim _ _ _ _ h $ 
      @finite_measure_with_density Î± ð _ _ hfâ)
    (measure.trim_absolutely_continuous h $ 
      @with_density_absolutely_continuous Î± ð Ï f)))).1

lemma condition_on_spec : 
  Ï.trim h . (condition_on h Ï f hfâ hfâ) = (Ï .[ð] f).trim h :=
(exists_prop.1 (classical.some_spec 
  (@signed_measure.exists_with_density_of_absolute_continuous _ _ 
    (Ï.trim h) ((Ï .[ð] f).trim h) _ 
    (@measure_theory.finite_measure_trim _ _ _ _ h $ 
      @finite_measure_with_density Î± ð _ _ hfâ)
    (measure.trim_absolutely_continuous h $ 
      @with_density_absolutely_continuous Î± ð Ï f)))).2.symm

instance : partial_order (measurable_space Î±) := measurable_space.partial_order

/-- Alternate formualtion of `condition_on_spec` which is more useful most of the time. 
This lemma works better with `erw` than `rw`. -/
lemma condition_on_spec' {s : set Î±} (hs : @measurable_set Î± ð s) : 
  â«â» x in s, condition_on h Ï f hfâ hfâ x â(Ï.trim h) = â«â»[ð] x in s, f x âÏ :=
begin
  rw [â with_density_apply _ hs, condition_on_spec, trim_measurable_set_eq h hs, 
      with_density_apply],
  exact h _ hs
end

/-- The condition of a random variable `f` with respect to a sub-Ï-algebra `ð` is 
*essentially unique*.

Note that in this lemma, `g` is measurable with respect to `ð` instead of `ð` 
(which is stronger than measurable w.r.t.`ð`). -/
lemma condition_on_essentially_unique (hgâ : measurable g)
  (hg : â â¦s : set Î±â¦ (hs : @measurable_set Î± ð s), 
    â«â» x in s, condition_on h Ï f hfâ hfâ x â(Ï.trim h) = â«â»[ð] x in s, g x âÏ) : 
  g =áµ[Ï.trim h] condition_on h Ï f hfâ hfâ :=
begin
  refine ae_eq_of_with_density_eq hgâ (condition_on_measurable h Ï f hfâ hfâ) _,
  refine measure.ext (Î» s hs, _),
  rw [with_density_apply _ hs, with_density_apply _ hs, hg hs, 
      lintegral_in_trim h hgâ hs]
end 

lemma condition_on_add : 
  condition_on h Ï (f + g) 
    (@measurable.add _ Î± _ _ ð _ _ _ hfâ hgâ) 
    (@lintegral_add_lt_top Î± ð _ _ _ hfâ hgâ hfâ hgâ)
  =áµ[Ï.trim h] condition_on h Ï f hfâ hfâ + condition_on h Ï g hgâ hgâ :=
begin
  refine filter.eventually_eq.symm (condition_on_essentially_unique _ _ _ _ _ _ _ _),
  { exact (condition_on_measurable h Ï f hfâ hfâ).add 
      (condition_on_measurable h Ï g hgâ hgâ) },
  { intros s hs,
    erw [condition_on_spec', @lintegral_add Î± ð _ _ _ hfâ hgâ],
    rw [â condition_on_spec' h Ï f hfâ hfâ, â condition_on_spec' h Ï g hgâ hgâ, 
        â lintegral_add, lintegral_in_trim],
    refl,
    all_goals { try { exact hs } },
    { exact (condition_on_measurable h Ï f hfâ hfâ).add 
        (condition_on_measurable h Ï g hgâ hgâ) },
    { exact condition_on_measurable h Ï f hfâ hfâ },
    { exact condition_on_measurable h Ï g hgâ hgâ } }
end

example {f : Î± â ââ¥0â} (hf : @measurable _ _ ð _ f) (h : ð â¤ ð) : 
  @measurable _ _ ð _ f := Î» s hs, h _ (hf hs)

lemma condition_on_smul (r : ââ¥0â) (hr : r < â) : 
  condition_on h Ï (r â¢ f) 
    (@measurable.const_smul _ _ _ _ _ _ ð _ _ hfâ r)
    (by { erw @lintegral_const_mul Î± ð _ _ _ hfâ, exact ennreal.mul_lt_top hr hfâ })
  =áµ[Ï.trim h] r â¢ condition_on h Ï f hfâ hfâ := 
begin
  refine filter.eventually_eq.symm (condition_on_essentially_unique _ _ _ _ _ _ _ _),
  { exact (condition_on_measurable h Ï f hfâ hfâ).const_smul r },
  { intros s hs,
    erw [condition_on_spec', lintegral_const_mul, lintegral_const_mul],
    rw [â condition_on_spec' h Ï f hfâ hfâ hs, lintegral_in_trim],
    all_goals { try { exact hs } },
    { exact condition_on_measurable h Ï f hfâ hfâ },
    { exact Î» s hs, h _ (condition_on_measurable h Ï f hfâ hfâ hs) },
    { exact hfâ } }
end

/-- **Law of total expectation** -/
lemma lintegral_condition_on_eq : 
  â«â» x, condition_on h Ï f hfâ hfâ x â(Ï.trim h) = 
  â«â»[ð] x, f x âÏ :=
begin
  rw [â lintegral_univ_eq, condition_on_spec', lintegral_univ_eq],
  exact measurable_set.univ,
end

#exit

lemma condition_on_indep 
  (hf : indep (measurable_space.comap f ennreal.measurable_space) ð (Ï.trim h)) :
  condition_on h Ï f hfâ hfâ =áµ[Ï.trim h] f :=
begin
  sorry,
  -- refine ae_eq_of_with_density_eq (condition_on_measurable _ _ _ hfâ _) hfâ _,
  -- have := condition_on_measurable h Ï _ hfâ hfâ,
  -- symmetry,
  -- apply condition_on_spec,
end

end condition_on

end measure_theory
