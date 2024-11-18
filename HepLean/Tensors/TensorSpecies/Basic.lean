/-
Copyright (c) 2024 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import HepLean.Tensors.OverColor.Iso
import HepLean.Tensors.OverColor.Discrete
import HepLean.Tensors.OverColor.Lift
import Mathlib.CategoryTheory.Monoidal.NaturalTransformation
/-!

# Tensor species

- A tensor species is a structure including all of the ingredients needed to define a type of
  tensor.
- Examples of tensor species will include real Lorentz tensors, complex Lorentz tensors, and
  Einstien tensors.
- Tensor species are built upon symmetric monoidal categories.

-/

open IndexNotation
open CategoryTheory
open MonoidalCategory

/-- The structure of a type of tensors e.g. Lorentz tensors, ordinary tensors
  (vectors and matrices), complex Lorentz tensors. -/
structure TensorSpecies where
  /-- The commutative ring over which we want to consider the tensors to live in,
    usually `ℝ` or `ℂ`. -/
  k : Type
  /-- An instance of `k` as a commutative ring. -/
  k_commRing : CommRing k
  /-- The symmetry group acting on these tensor e.g. the Lorentz group or SL(2,ℂ). -/
  G : Type
  /-- An instance of `G` as a group. -/
  G_group : Group G
  /-- The colors of indices e.g. up or down. -/
  C : Type
  /-- A functor from `C` to `Rep k G` giving our building block representations.
    Equivalently a function `C → Re k G`. -/
  FD : Discrete C ⥤ Rep k G
  /-- A specification of the dimension of each color in C. This will be used for explicit
    evaluation of tensors. -/
  repDim : C → ℕ
  /-- repDim is not zero for any color. This allows casting of `ℕ` to `Fin (S.repDim c)`. -/
  repDim_neZero (c : C) : NeZero (repDim c)
  /-- A basis for each Module, determined by the evaluation map. -/
  basis : (c : C) → Basis (Fin (repDim c)) k (FD.obj (Discrete.mk c)).V
  /-- A map from `C` to `C`. An involution. -/
  τ : C → C
  /-- The condition that `τ` is an involution. -/
  τ_involution : Function.Involutive τ
  /-- The natural transformation describing contraction. -/
  contr : OverColor.Discrete.pairτ FD τ ⟶ 𝟙_ (Discrete C ⥤ Rep k G)
  /-- Contraction is symmetric with respect to duals. -/
  contr_tmul_symm (c : C) (x : FD.obj (Discrete.mk c))
      (y : FD.obj (Discrete.mk (τ c))) :
    (contr.app (Discrete.mk c)).hom (x ⊗ₜ[k] y) = (contr.app (Discrete.mk (τ c))).hom
    (y ⊗ₜ (FD.map (Discrete.eqToHom (τ_involution c).symm)).hom x)
  /-- The natural transformation describing the unit. -/
  unit : 𝟙_ (Discrete C ⥤ Rep k G) ⟶ OverColor.Discrete.τPair FD τ
  /-- The unit is symmetric. -/
  unit_symm (c : C) :
    ((unit.app (Discrete.mk c)).hom (1 : k)) =
    ((FD.obj (Discrete.mk (τ (c)))) ◁
      (FD.map (Discrete.eqToHom (τ_involution c)))).hom
    ((β_ (FD.obj (Discrete.mk (τ (τ c)))) (FD.obj (Discrete.mk (τ (c))))).hom.hom
    ((unit.app (Discrete.mk (τ c))).hom (1 : k)))
  /-- Contraction with unit leaves invariant. -/
  contr_unit (c : C) (x : FD.obj (Discrete.mk (c))) :
    (λ_ (FD.obj (Discrete.mk (c)))).hom.hom
    (((contr.app (Discrete.mk c)) ▷ (FD.obj (Discrete.mk (c)))).hom
    ((α_ _ _ (FD.obj (Discrete.mk (c)))).inv.hom
    (x ⊗ₜ[k] (unit.app (Discrete.mk c)).hom (1 : k)))) = x
  /-- The natural transformation describing the metric. -/
  metric : 𝟙_ (Discrete C ⥤ Rep k G) ⟶ OverColor.Discrete.pair FD
  /-- On contracting metrics we get back the unit. -/
  contr_metric (c : C) :
    (β_ (FD.obj (Discrete.mk c)) (FD.obj (Discrete.mk (τ c)))).hom.hom
    (((FD.obj (Discrete.mk c)) ◁ (λ_ (FD.obj (Discrete.mk (τ c)))).hom).hom
    (((FD.obj (Discrete.mk c)) ◁ ((contr.app (Discrete.mk c)) ▷
    (FD.obj (Discrete.mk (τ c))))).hom
    (((FD.obj (Discrete.mk c)) ◁ (α_ (FD.obj (Discrete.mk (c)))
      (FD.obj (Discrete.mk (τ c))) (FD.obj (Discrete.mk (τ c)))).inv).hom
    ((α_ (FD.obj (Discrete.mk (c))) (FD.obj (Discrete.mk (c)))
      (FD.obj (Discrete.mk (τ c)) ⊗ FD.obj (Discrete.mk (τ c)))).hom.hom
    ((metric.app (Discrete.mk c)).hom (1 : k) ⊗ₜ[k]
      (metric.app (Discrete.mk (τ c))).hom (1 : k))))))
    = (unit.app (Discrete.mk c)).hom (1 : k)

noncomputable section

namespace TensorSpecies
open OverColor

variable (S : TensorSpecies)

/-- The field `k` of a TensorSpecies has the instance of a commuative ring. -/
instance : CommRing S.k := S.k_commRing

/-- The field `G` of a TensorSpecies has the instance of a group. -/
instance : Group S.G := S.G_group

/-- The field `repDim` of a TensorSpecies is non-zero for all colors. -/
instance (c : S.C) : NeZero (S.repDim c) := S.repDim_neZero c

/-- The lift of the functor `S.F` to a monoidal functor. -/
def F : BraidedFunctor (OverColor S.C) (Rep S.k S.G) := (OverColor.lift).obj S.FD

/- The definition of `F` as a lemma. -/
lemma F_def : F S = (OverColor.lift).obj S.FD := rfl

lemma perm_contr_cond {n : ℕ} {c : Fin n.succ.succ → S.C} {c1 : Fin n.succ.succ → S.C}
    {i : Fin n.succ.succ} {j : Fin n.succ}
    (h : c1 (i.succAbove j) = S.τ (c1 i)) (σ : (OverColor.mk c) ⟶ (OverColor.mk c1)) :
    c (Fin.succAbove ((Hom.toEquiv σ).symm i) ((Hom.toEquiv (extractOne i σ)).symm j)) =
    S.τ (c ((Hom.toEquiv σ).symm i)) := by
  have h1 := Hom.toEquiv_comp_apply σ
  simp only [Nat.succ_eq_add_one, Functor.const_obj_obj, mk_hom] at h1
  rw [h1, h1]
  simp only [Nat.succ_eq_add_one, extractOne_homToEquiv, Equiv.apply_symm_apply]
  rw [← h]
  congr
  simp only [Nat.succ_eq_add_one, HepLean.Fin.finExtractOnePerm, HepLean.Fin.finExtractOnPermHom,
    HepLean.Fin.finExtractOne_symm_inr_apply, Equiv.symm_apply_apply, Equiv.coe_fn_symm_mk]
  erw [Equiv.apply_symm_apply]
  rw [HepLean.Fin.succsAbove_predAboveI]
  erw [Equiv.apply_symm_apply]
  simp only [Nat.succ_eq_add_one, ne_eq]
  erw [Equiv.apply_eq_iff_eq]
  exact (Fin.succAbove_ne i j).symm

/-- The isomorphism between the image of a map `Fin 1 ⊕ Fin 1 → S.C` contructed by `finExtractTwo`
  under `S.F.obj`, and an object in the image of `OverColor.Discrete.pairτ S.FD`. -/
def contrFin1Fin1 {n : ℕ} (c : Fin n.succ.succ → S.C)
    (i : Fin n.succ.succ) (j : Fin n.succ) (h : c (i.succAbove j) = S.τ (c i)) :
    S.F.obj (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inl)) ≅
    (OverColor.Discrete.pairτ S.FD S.τ).obj { as := c i } := by
  apply (S.F.mapIso
    (OverColor.mkSum (((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inl)))).trans
  apply (S.F.μIso _ _).symm.trans
  apply tensorIso ?_ ?_
  · symm
    apply (OverColor.forgetLiftApp S.FD (c i)).symm.trans
    apply S.F.mapIso
    apply OverColor.mkIso
    funext x
    fin_cases x
    rfl
  · symm
    apply (OverColor.forgetLiftApp S.FD (S.τ (c i))).symm.trans
    apply S.F.mapIso
    apply OverColor.mkIso
    funext x
    fin_cases x
    simp [h]

lemma contrFin1Fin1_inv_tmul {n : ℕ} (c : Fin n.succ.succ → S.C)
    (i : Fin n.succ.succ) (j : Fin n.succ) (h : c (i.succAbove j) = S.τ (c i))
    (x : S.FD.obj { as := c i })
    (y : S.FD.obj { as := S.τ (c i) }) :
    (S.contrFin1Fin1 c i j h).inv.hom (x ⊗ₜ[S.k] y) =
    PiTensorProduct.tprod S.k (fun k =>
    match k with | Sum.inl 0 => x | Sum.inr 0 => (S.FD.map
    (eqToHom (by simp [h]))).hom y) := by
  simp only [Nat.succ_eq_add_one, contrFin1Fin1, Functor.comp_obj, Discrete.functor_obj_eq_as,
    Function.comp_apply, Iso.trans_symm, Iso.symm_symm_eq, Iso.trans_inv, tensorIso_inv,
    Iso.symm_inv, Functor.mapIso_hom, tensor_comp, MonoidalFunctor.μIso_hom, Category.assoc,
    LaxMonoidalFunctor.μ_natural, Functor.mapIso_inv, Action.comp_hom,
    Action.instMonoidalCategory_tensorObj_V, Action.instMonoidalCategory_tensorHom_hom,
    Equivalence.symm_inverse, Action.functorCategoryEquivalence_functor,
    Action.FunctorCategoryEquivalence.functor_obj_obj, ModuleCat.coe_comp, Functor.id_obj, mk_hom,
    Fin.isValue]
  change (S.F.map (OverColor.mkSum ((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inl)).inv).hom
    ((S.F.map ((OverColor.mkIso _).hom ⊗ (OverColor.mkIso _).hom)).hom
      ((S.F.μ (OverColor.mk fun _ => c i) (OverColor.mk fun _ => S.τ (c i))).hom
        ((((OverColor.forgetLiftApp S.FD (c i)).inv.hom x) ⊗ₜ[S.k]
        ((OverColor.forgetLiftApp S.FD (S.τ (c i))).inv.hom y))))) = _
  simp only [Nat.succ_eq_add_one, Action.instMonoidalCategory_tensorObj_V, Equivalence.symm_inverse,
    Action.functorCategoryEquivalence_functor, Action.FunctorCategoryEquivalence.functor_obj_obj,
    forgetLiftApp, Action.mkIso_inv_hom, LinearEquiv.toModuleIso_inv, Fin.isValue]
  erw [OverColor.forgetLiftAppV_symm_apply,
    OverColor.forgetLiftAppV_symm_apply S.FD (S.τ (c i))]
  change ((OverColor.lift.obj S.FD).map (OverColor.mkSum
    ((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inl)).inv).hom
    (((OverColor.lift.obj S.FD).map ((OverColor.mkIso _).hom ⊗ (OverColor.mkIso _).hom)).hom
    (((OverColor.lift.obj S.FD).μ (OverColor.mk fun _ => c i)
    (OverColor.mk fun _ => S.τ (c i))).hom
    (((PiTensorProduct.tprod S.k) fun _ => x) ⊗ₜ[S.k] (PiTensorProduct.tprod S.k) fun _ => y))) = _
  rw [OverColor.lift.obj_μ_tprod_tmul S.FD]
  change ((OverColor.lift.obj S.FD).map
    (OverColor.mkSum ((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inl)).inv).hom
    (((OverColor.lift.obj S.FD).map ((OverColor.mkIso _).hom ⊗ (OverColor.mkIso _).hom)).hom
    ((PiTensorProduct.tprod S.k) _)) = _
  rw [OverColor.lift.map_tprod S.FD]
  change ((OverColor.lift.obj S.FD).map
    (OverColor.mkSum ((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inl)).inv).hom
    ((PiTensorProduct.tprod S.k _)) = _
  rw [OverColor.lift.map_tprod S.FD]
  apply congrArg
  funext r
  match r with
  | Sum.inl 0 =>
    simp only [Nat.succ_eq_add_one, mk_hom, Fin.isValue, Function.comp_apply,
      instMonoidalCategoryStruct_tensorObj_left, mkSum_inv_homToEquiv, Equiv.refl_symm,
      instMonoidalCategoryStruct_tensorObj_hom, Functor.id_obj, lift.discreteSumEquiv, Sum.elim_inl,
      Sum.elim_inr, HepLean.PiTensorProduct.elimPureTensor]
    simp only [Fin.isValue, lift.discreteFunctorMapEqIso, eqToIso_refl, Functor.mapIso_refl,
      Iso.refl_hom, Action.id_hom, Iso.refl_inv, LinearEquiv.ofLinear_apply]
    rfl
  | Sum.inr 0 =>
    simp only [Nat.succ_eq_add_one, mk_hom, Fin.isValue, Function.comp_apply,
      instMonoidalCategoryStruct_tensorObj_left, mkSum_inv_homToEquiv, Equiv.refl_symm,
      instMonoidalCategoryStruct_tensorObj_hom, lift.discreteFunctorMapEqIso, eqToIso_refl,
      Functor.mapIso_refl, Iso.refl_hom, Action.id_hom, Iso.refl_inv, Functor.mapIso_hom,
      eqToIso.hom, Functor.mapIso_inv, eqToIso.inv, Functor.id_obj, lift.discreteSumEquiv,
      Sum.elim_inl, Sum.elim_inr, HepLean.PiTensorProduct.elimPureTensor,
      LinearEquiv.ofLinear_apply]
    rfl

lemma contrFin1Fin1_hom_hom_tprod {n : ℕ} (c : Fin n.succ.succ → S.C)
    (i : Fin n.succ.succ) (j : Fin n.succ) (h : c (i.succAbove j) = S.τ (c i))
    (x : (k : Fin 1 ⊕ Fin 1) → (S.FD.obj
      { as := (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inl)).hom k })) :
    (S.contrFin1Fin1 c i j h).hom.hom (PiTensorProduct.tprod S.k x) =
    x (Sum.inl 0) ⊗ₜ[S.k] ((S.FD.map (eqToHom (by simp [h]))).hom (x (Sum.inr 0))) := by
  change ((Action.forget _ _).mapIso (S.contrFin1Fin1 c i j h)).hom _ = _
  trans ((Action.forget _ _).mapIso (S.contrFin1Fin1 c i j h)).toLinearEquiv
    (PiTensorProduct.tprod S.k x)
  · rfl
  erw [← LinearEquiv.eq_symm_apply]
  erw [contrFin1Fin1_inv_tmul]
  congr
  funext i
  match i with
  | Sum.inl 0 =>
    rfl
  | Sum.inr 0 =>
    simp only [Nat.succ_eq_add_one, Fin.isValue, mk_hom, Function.comp_apply,
      Discrete.functor_obj_eq_as]
    change _ = ((S.FD.map (eqToHom _)) ≫ (S.FD.map (eqToHom _))).hom (x (Sum.inr 0))
    rw [← Functor.map_comp]
    simp
  exact h

/-- The isomorphism of objects in `Rep S.k S.G` given an `i` in `Fin n.succ.succ` and
  a `j` in `Fin n.succ` allowing us to undertake contraction. -/
def contrIso {n : ℕ} (c : Fin n.succ.succ → S.C)
    (i : Fin n.succ.succ) (j : Fin n.succ) (h : c (i.succAbove j) = S.τ (c i)) :
    S.F.obj (OverColor.mk c) ≅ ((OverColor.Discrete.pairτ S.FD S.τ).obj
      (Discrete.mk (c i))) ⊗
      (OverColor.lift.obj S.FD).obj (OverColor.mk (c ∘ i.succAbove ∘ j.succAbove)) :=
  (S.F.mapIso (OverColor.equivToIso (HepLean.Fin.finExtractTwo i j))).trans <|
  (S.F.mapIso (OverColor.mkSum (c ∘ (HepLean.Fin.finExtractTwo i j).symm))).trans <|
  (S.F.μIso _ _).symm.trans <| by
  refine tensorIso (S.contrFin1Fin1 c i j h) (S.F.mapIso (OverColor.mkIso (by ext x; simp)))

lemma contrIso_hom_hom {n : ℕ} {c1 : Fin n.succ.succ → S.C}
    {i : Fin n.succ.succ} {j : Fin n.succ} {h : c1 (i.succAbove j) = S.τ (c1 i)} :
    (S.contrIso c1 i j h).hom.hom =
    (S.F.map (equivToIso (HepLean.Fin.finExtractTwo i j)).hom).hom ≫
    (S.F.map (mkSum (c1 ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm)).hom).hom ≫
    (S.F.μIso (OverColor.mk ((c1 ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inl))
    (OverColor.mk ((c1 ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inr))).inv.hom ≫
    ((S.contrFin1Fin1 c1 i j h).hom.hom ⊗
    (S.F.map (mkIso (contrIso.proof_1 S c1 i j)).hom).hom) := by
  rfl

/-- `contrMap` is a function that takes a natural number `n`, a function `c` from
`Fin n.succ.succ` to `S.C`, an index `i` of type `Fin n.succ.succ`, an index `j` of type
`Fin n.succ`, and a proof `h` that `c (i.succAbove j) = S.τ (c i)`. It returns a morphism
corresponding to the contraction of the `i`th index with the `i.succAbove j` index.
--/
def contrMap {n : ℕ} (c : Fin n.succ.succ → S.C)
    (i : Fin n.succ.succ) (j : Fin n.succ) (h : c (i.succAbove j) = S.τ (c i)) :
    S.F.obj (OverColor.mk c) ⟶
    S.F.obj (OverColor.mk (c ∘ i.succAbove ∘ j.succAbove)) :=
  (S.contrIso c i j h).hom ≫
  (tensorHom (S.contr.app (Discrete.mk (c i))) (𝟙 _)) ≫
  (MonoidalCategory.leftUnitor _).hom

/-- Casts an element of the monoidal unit of `Rep S.k S.G` to the field `S.k`. -/
def castToField (v : (↑((𝟙_ (Discrete S.C ⥤ Rep S.k S.G)).obj { as := c }).V)) : S.k := v

/-- Casts an element of `(S.F.obj (OverColor.mk c)).V` for `c` a map from `Fin 0` to an
  element of the field. -/
def castFin0ToField {c : Fin 0 → S.C} : (S.F.obj (OverColor.mk c)).V →ₗ[S.k] S.k :=
  (PiTensorProduct.isEmptyEquiv (Fin 0)).toLinearMap

lemma castFin0ToField_tprod {c : Fin 0 → S.C}
    (x : (i : Fin 0) → S.FD.obj (Discrete.mk (c i))) :
    castFin0ToField S (PiTensorProduct.tprod S.k x) = 1 := by
  simp only [castFin0ToField, mk_hom, Functor.id_obj, LinearEquiv.coe_coe]
  erw [PiTensorProduct.isEmptyEquiv_apply_tprod]

lemma contrMap_tprod {n : ℕ} (c : Fin n.succ.succ → S.C)
    (i : Fin n.succ.succ) (j : Fin n.succ) (h : c (i.succAbove j) = S.τ (c i))
    (x : (i : Fin n.succ.succ) → S.FD.obj (Discrete.mk (c i))) :
    (S.contrMap c i j h).hom (PiTensorProduct.tprod S.k x) =
    (S.castToField ((S.contr.app (Discrete.mk (c i))).hom ((x i) ⊗ₜ[S.k]
    (S.FD.map (Discrete.eqToHom h)).hom (x (i.succAbove j)))) : S.k)
    • (PiTensorProduct.tprod S.k (fun k => x (i.succAbove (j.succAbove k))) :
    S.F.obj (OverColor.mk (c ∘ i.succAbove ∘ j.succAbove))) := by
  rw [contrMap, contrIso]
  simp only [Nat.succ_eq_add_one, S.F_def, Iso.trans_hom, Functor.mapIso_hom, Iso.symm_hom,
    tensorIso_hom, Monoidal.tensorUnit_obj, tensorHom_id,
    Category.assoc, Action.comp_hom, Action.instMonoidalCategory_tensorObj_V,
    Action.instMonoidalCategory_tensorHom_hom, Action.instMonoidalCategory_tensorUnit_V,
    Action.instMonoidalCategory_whiskerRight_hom, Functor.id_obj, mk_hom, ModuleCat.coe_comp,
    Function.comp_apply, Equivalence.symm_inverse, Action.functorCategoryEquivalence_functor,
    Action.FunctorCategoryEquivalence.functor_obj_obj, Functor.comp_obj, Discrete.functor_obj_eq_as]
  change (λ_ ((lift.obj S.FD).obj _)).hom.hom
    (((S.contr.app { as := c i }).hom ▷ ((lift.obj S.FD).obj
    (OverColor.mk (c ∘ i.succAbove ∘ j.succAbove))).V)
    (((S.contrFin1Fin1 c i j h).hom.hom ⊗ ((lift.obj S.FD).map (mkIso _).hom).hom)
    (((lift.obj S.FD).μIso (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm)
    ∘ Sum.inl))
    (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inr))).inv.hom
    (((lift.obj S.FD).map (mkSum (c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm)).hom).hom
    (((lift.obj S.FD).map (equivToIso (HepLean.Fin.finExtractTwo i j)).hom).hom
    ((PiTensorProduct.tprod S.k) x)))))) = _
  rw [lift.map_tprod]
  change (λ_ ((lift.obj S.FD).obj (OverColor.mk (c ∘ i.succAbove ∘ j.succAbove)))).hom.hom
    (((S.contr.app { as := c i }).hom ▷
    ((lift.obj S.FD).obj (OverColor.mk (c ∘ i.succAbove ∘ j.succAbove))).V)
    (((S.contrFin1Fin1 c i j h).hom.hom ⊗ ((lift.obj S.FD).map (mkIso _).hom).hom)
    (((lift.obj S.FD).μIso (OverColor.mk
    ((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inl))
    (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inr))).inv.hom
    (((lift.obj S.FD).map (mkSum (c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm)).hom).hom
    ((PiTensorProduct.tprod S.k) fun i_1 =>
    (lift.discreteFunctorMapEqIso S.FD _)
    (x ((Hom.toEquiv (equivToIso (HepLean.Fin.finExtractTwo i j)).hom).symm i_1))))))) = _
  rw [lift.map_tprod]
  change (λ_ ((lift.obj S.FD).obj (OverColor.mk (c ∘ i.succAbove ∘ j.succAbove)))).hom.hom
    (((S.contr.app { as := c i }).hom ▷ ((lift.obj S.FD).obj
    (OverColor.mk (c ∘ i.succAbove ∘ j.succAbove))).V)
    (((S.contrFin1Fin1 c i j h).hom.hom ⊗ ((lift.obj S.FD).map (mkIso _).hom).hom)
    (((lift.obj S.FD).μIso
    (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inl))
    (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm) ∘ Sum.inr))).inv.hom
    ((PiTensorProduct.tprod S.k) fun i_1 =>
    (lift.discreteFunctorMapEqIso S.FD _)
    ((lift.discreteFunctorMapEqIso S.FD _)
    (x ((Hom.toEquiv (equivToIso (HepLean.Fin.finExtractTwo i j)).hom).symm
    ((Hom.toEquiv (mkSum (c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm)).hom).symm i_1)))))))) = _
  rw [lift.μIso_inv_tprod]
  change (λ_ ((lift.obj S.FD).obj (OverColor.mk (c ∘ i.succAbove ∘ j.succAbove)))).hom.hom
    (((S.contr.app { as := c i }).hom ▷ ((lift.obj S.FD).obj
    (OverColor.mk (c ∘ i.succAbove ∘ j.succAbove))).V)
    ((TensorProduct.map (S.contrFin1Fin1 c i j h).hom.hom
    ((lift.obj S.FD).map (mkIso _).hom).hom)
    (((PiTensorProduct.tprod S.k) fun i_1 =>
    (lift.discreteFunctorMapEqIso S.FD _)
    ((lift.discreteFunctorMapEqIso S.FD _) (x
    ((Hom.toEquiv (equivToIso (HepLean.Fin.finExtractTwo i j)).hom).symm
    ((Hom.toEquiv (mkSum (c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm)).hom).symm
    (Sum.inl i_1)))))) ⊗ₜ[S.k] (PiTensorProduct.tprod S.k) fun i_1 =>
    (lift.discreteFunctorMapEqIso S.FD _) ((lift.discreteFunctorMapEqIso S.FD _)
    (x ((Hom.toEquiv (equivToIso (HepLean.Fin.finExtractTwo i j)).hom).symm
    ((Hom.toEquiv
    (mkSum (c ∘ ⇑(HepLean.Fin.finExtractTwo i j).symm)).hom).symm (Sum.inr i_1)))))))) = _
  rw [TensorProduct.map_tmul]
  rw [contrFin1Fin1_hom_hom_tprod]
  simp only [Nat.succ_eq_add_one, Action.instMonoidalCategory_tensorObj_V,
    Action.instMonoidalCategory_tensorUnit_V, Fin.isValue, mk_hom, Function.comp_apply,
    Discrete.functor_obj_eq_as, instMonoidalCategoryStruct_tensorObj_left, mkSum_homToEquiv,
    Equiv.refl_symm, Functor.id_obj, ModuleCat.MonoidalCategory.whiskerRight_apply]
  rw [Action.instMonoidalCategory_leftUnitor_hom_hom]
  simp only [Monoidal.tensorUnit_obj, Action.instMonoidalCategory_tensorUnit_V, Fin.isValue,
    ModuleCat.MonoidalCategory.leftUnitor_hom_apply]
  congr 1
  /- The contraction. -/
  · simp only [Fin.isValue, castToField]
    congr 2
    · simp only [Fin.isValue, lift.discreteFunctorMapEqIso, eqToIso_refl, Functor.mapIso_refl,
      Iso.refl_hom, Action.id_hom, Iso.refl_inv, LinearEquiv.ofLinear_apply]
      rfl
    · simp only [Fin.isValue, lift.discreteFunctorMapEqIso, eqToIso_refl, Functor.mapIso_refl,
      Iso.refl_hom, Action.id_hom, Iso.refl_inv, LinearEquiv.ofLinear_apply]
      change (S.FD.map (eqToHom _)).hom
        (x (((HepLean.Fin.finExtractTwo i j)).symm ((Sum.inl (Sum.inr 0))))) = _
      simp only [Nat.succ_eq_add_one, Fin.isValue]
      have h1' {a b d: Fin n.succ.succ} (hbd : b =d) (h : c d = S.τ (c a)) (h' : c b = S.τ (c a)) :
          (S.FD.map (Discrete.eqToHom (h))).hom (x d) =
          (S.FD.map (Discrete.eqToHom h')).hom (x b) := by
        subst hbd
        rfl
      refine h1' ?_ ?_ ?_
      simp only [Nat.succ_eq_add_one, Fin.isValue, HepLean.Fin.finExtractTwo_symm_inl_inr_apply]
      simp [h]
  /- The tensor. -/
  · erw [lift.map_tprod]
    apply congrArg
    funext d
    simp only [mk_hom, Function.comp_apply, lift.discreteFunctorMapEqIso, Functor.mapIso_hom,
      eqToIso.hom, Functor.mapIso_inv, eqToIso.inv, eqToIso_refl, Functor.mapIso_refl, Iso.refl_hom,
      Action.id_hom, Iso.refl_inv, LinearEquiv.ofLinear_apply]
    change (S.FD.map (eqToHom _)).hom
        ((x ((HepLean.Fin.finExtractTwo i j).symm (Sum.inr (d))))) = _
    simp only [Nat.succ_eq_add_one]
    have h1 : ((HepLean.Fin.finExtractTwo i j).symm (Sum.inr d))
      = (i.succAbove (j.succAbove d)) := HepLean.Fin.finExtractTwo_symm_inr_apply i j d
    have h1' {a b : Fin n.succ.succ} (h : a = b) :
      (S.FD.map (eqToHom (by rw [h]))).hom (x a) = x b := by
      subst h
      simp
    exact h1' h1

/-!

## Evalutation of indices.

-/

/-- The isomorphism of objects in `Rep S.k S.G` given an `i` in `Fin n.succ`
  allowing us to undertake evaluation. -/
def evalIso {n : ℕ} (c : Fin n.succ → S.C)
    (i : Fin n.succ) : S.F.obj (OverColor.mk c) ≅ (S.FD.obj (Discrete.mk (c i))) ⊗
      (OverColor.lift.obj S.FD).obj (OverColor.mk (c ∘ i.succAbove)) :=
  (S.F.mapIso (OverColor.equivToIso (HepLean.Fin.finExtractOne i))).trans <|
  (S.F.mapIso (OverColor.mkSum (c ∘ (HepLean.Fin.finExtractOne i).symm))).trans <|
  (S.F.μIso _ _).symm.trans <|
  tensorIso
    ((S.F.mapIso (OverColor.mkIso (by ext x; fin_cases x; rfl))).trans
    (OverColor.forgetLiftApp S.FD (c i))) (S.F.mapIso (OverColor.mkIso (by ext x; simp)))

lemma evalIso_tprod {n : ℕ} {c : Fin n.succ → S.C} (i : Fin n.succ)
    (x : (i : Fin n.succ) → S.FD.obj (Discrete.mk (c i))) :
    (S.evalIso c i).hom.hom (PiTensorProduct.tprod S.k x) =
    x i ⊗ₜ[S.k] (PiTensorProduct.tprod S.k (fun k => x (i.succAbove k))) := by
  simp only [Nat.succ_eq_add_one, Action.instMonoidalCategory_tensorObj_V, F_def, evalIso,
    Iso.trans_hom, Functor.mapIso_hom, Iso.symm_hom, tensorIso_hom, Action.comp_hom,
    Action.instMonoidalCategory_tensorHom_hom, Functor.id_obj, mk_hom, ModuleCat.coe_comp,
    Function.comp_apply]
  change (((lift.obj S.FD).map (mkIso _).hom).hom ≫
    (forgetLiftApp S.FD (c i)).hom.hom ⊗
    ((lift.obj S.FD).map (mkIso _).hom).hom)
    (((lift.obj S.FD).μIso
    (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractOne i).symm) ∘ Sum.inl))
    (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractOne i).symm) ∘ Sum.inr))).inv.hom
    (((lift.obj S.FD).map (mkSum (c ∘ ⇑(HepLean.Fin.finExtractOne i).symm)).hom).hom
    (((lift.obj S.FD).map (equivToIso (HepLean.Fin.finExtractOne i)).hom).hom
    ((PiTensorProduct.tprod S.k) _)))) =_
  rw [lift.map_tprod]
  change (((lift.obj S.FD).map (mkIso _).hom).hom ≫
    (forgetLiftApp S.FD (c i)).hom.hom ⊗
    ((lift.obj S.FD).map (mkIso _).hom).hom)
    (((lift.obj S.FD).μIso
    (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractOne i).symm) ∘ Sum.inl))
    (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractOne i).symm) ∘ Sum.inr))).inv.hom
    (((lift.obj S.FD).map (mkSum (c ∘ ⇑(HepLean.Fin.finExtractOne i).symm)).hom).hom
    (((PiTensorProduct.tprod S.k) _)))) =_
  rw [lift.map_tprod]
  change ((TensorProduct.map (((lift.obj S.FD).map (mkIso _).hom).hom ≫
    (forgetLiftApp S.FD (c i)).hom.hom)
    ((lift.obj S.FD).map (mkIso _).hom).hom))
    (((lift.obj S.FD).μIso
    (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractOne i).symm) ∘ Sum.inl))
    (OverColor.mk ((c ∘ ⇑(HepLean.Fin.finExtractOne i).symm) ∘ Sum.inr))).inv.hom
    ((((PiTensorProduct.tprod S.k) _)))) =_
  rw [lift.μIso_inv_tprod]
  rw [TensorProduct.map_tmul]
  erw [lift.map_tprod]
  simp only [Nat.succ_eq_add_one, CategoryStruct.comp, Functor.id_obj,
    instMonoidalCategoryStruct_tensorObj_hom, mk_hom, Sum.elim_inl, Function.comp_apply,
    instMonoidalCategoryStruct_tensorObj_left, mkSum_homToEquiv, Equiv.refl_symm,
    LinearMap.coe_comp, Sum.elim_inr]
  congr 1
  · change (forgetLiftApp S.FD (c i)).hom.hom
      (((lift.obj S.FD).map (mkIso _).hom).hom
      ((PiTensorProduct.tprod S.k) _)) = _
    rw [lift.map_tprod]
    rw [forgetLiftApp_hom_hom_apply_eq]
    apply congrArg
    funext i
    match i with
    | (0 : Fin 1) =>
      simp only [mk_hom, Fin.isValue, Function.comp_apply, lift.discreteFunctorMapEqIso,
        eqToIso_refl, Functor.mapIso_refl, Iso.refl_hom, Action.id_hom, Iso.refl_inv,
        LinearEquiv.ofLinear_apply]
      rfl
  · apply congrArg
    funext k
    simp only [lift.discreteFunctorMapEqIso, Functor.mapIso_hom, eqToIso.hom, Functor.mapIso_inv,
      eqToIso.inv, eqToIso_refl, Functor.mapIso_refl, Iso.refl_hom, Action.id_hom, Iso.refl_inv,
      LinearEquiv.ofLinear_apply]
    change (S.FD.map (eqToHom _)).hom
      (x ((HepLean.Fin.finExtractOne i).symm ((Sum.inr k)))) = _
    have h1' {a b : Fin n.succ} (h : a = b) :
      (S.FD.map (eqToHom (by rw [h]))).hom (x a) = x b := by
      subst h
      simp
    refine h1' ?_
    exact HepLean.Fin.finExtractOne_symm_inr_apply i k

/-- The linear map giving the coordinate of a vector with respect to the given basis.
  Important Note: This is not a morphism in the category of representations. In general,
  it cannot be lifted thereto. -/
def evalLinearMap {n : ℕ} {c : Fin n.succ → S.C} (i : Fin n.succ) (e : Fin (S.repDim (c i))) :
    S.FD.obj { as := c i } →ₗ[S.k] S.k where
  toFun := fun v => (S.basis (c i)).repr v e
  map_add' := by simp
  map_smul' := by simp

/-- The evaluation map, used to evaluate indices of tensors.
  Important Note: The evaluation map is in general, not equivariant with respect to
  group actions. It is a morphism in the underlying module category, not the category
  of representations. -/
def evalMap {n : ℕ} {c : Fin n.succ → S.C} (i : Fin n.succ) (e : Fin (S.repDim (c i))) :
    (S.F.obj (OverColor.mk c)).V ⟶ (S.F.obj (OverColor.mk (c ∘ i.succAbove))).V :=
  (S.evalIso c i).hom.hom ≫ ((Action.forgetMonoidal _ _).μIso _ _).inv
  ≫ ModuleCat.asHom (TensorProduct.map (S.evalLinearMap i e) LinearMap.id) ≫
  ModuleCat.asHom (TensorProduct.lid S.k _).toLinearMap

lemma evalMap_tprod {n : ℕ} {c : Fin n.succ → S.C} (i : Fin n.succ) (e : Fin (S.repDim (c i)))
    (x : (i : Fin n.succ) → S.FD.obj (Discrete.mk (c i))) :
    (S.evalMap i e) (PiTensorProduct.tprod S.k x) =
    (((S.basis (c i)).repr (x i) e) : S.k) •
    (PiTensorProduct.tprod S.k
    (fun k => x (i.succAbove k)) : S.F.obj (OverColor.mk (c ∘ i.succAbove))) := by
  rw [evalMap]
  simp only [Nat.succ_eq_add_one, Action.instMonoidalCategory_tensorObj_V,
    Action.forgetMonoidal_toLaxMonoidalFunctor_toFunctor, Action.forget_obj, Functor.id_obj, mk_hom,
    Function.comp_apply, ModuleCat.coe_comp]
  erw [evalIso_tprod]
  change ((TensorProduct.lid S.k ↑((lift.obj S.FD).obj (OverColor.mk (c ∘ i.succAbove))).V))
    (((TensorProduct.map (S.evalLinearMap i e) LinearMap.id))
    (((Action.forgetMonoidal (ModuleCat S.k) (MonCat.of S.G)).μIso (S.FD.obj { as := c i })
    ((lift.obj S.FD).obj (OverColor.mk (c ∘ i.succAbove)))).inv
    (x i ⊗ₜ[S.k] (PiTensorProduct.tprod S.k) fun k => x (i.succAbove k)))) = _
  simp only [Nat.succ_eq_add_one, Action.forgetMonoidal_toLaxMonoidalFunctor_toFunctor,
    Action.forget_obj, Action.instMonoidalCategory_tensorObj_V, MonoidalFunctor.μIso,
    Action.forgetMonoidal_toLaxMonoidalFunctor_μ, asIso_inv, IsIso.inv_id, Equivalence.symm_inverse,
    Action.functorCategoryEquivalence_functor, Action.FunctorCategoryEquivalence.functor_obj_obj,
    Functor.id_obj, mk_hom, Function.comp_apply, ModuleCat.id_apply, TensorProduct.map_tmul,
    LinearMap.id_coe, id_eq, TensorProduct.lid_tmul]
  rfl

/-!

## The equivalence turning vecs into tensors

-/

/-- The equivaelcne between tensors based on `![c]` and vectros in ` S.FD.obj (Discrete.mk c)`. -/
def tensorToVec (c : S.C) : S.F.obj (OverColor.mk ![c]) ≅ S.FD.obj (Discrete.mk c) :=
  OverColor.forgetLiftAppCon S.FD c

lemma tensorToVec_inv_apply_expand (c : S.C) (x : S.FD.obj (Discrete.mk c)) :
    (S.tensorToVec c).inv.hom x =
    ((lift.obj S.FD).map (OverColor.mkIso (by
    funext i
    fin_cases i
    rfl)).hom).hom ((OverColor.forgetLiftApp S.FD c).inv.hom x) :=
  forgetLiftAppCon_inv_apply_expand S.FD c x

lemma tensorToVec_naturality_eqToHom (c c1 : S.C) (h : c = c1):
    (S.tensorToVec c).hom ≫ S.FD.map (Discrete.eqToHom h) =
    S.F.map (OverColor.mkIso (by rw [h])).hom ≫ (S.tensorToVec c1).hom :=
  OverColor.forgetLiftAppCon_naturality_eqToHom S.FD c c1 h

lemma tensorToVec_naturality_eqToHom_apply (c c1 : S.C) (h : c = c1)
    (x : S.F.obj (OverColor.mk ![c])) :
    (S.FD.map (Discrete.eqToHom h)).hom ((S.tensorToVec c).hom.hom x) =
    (S.tensorToVec c1).hom.hom (((S.F.map (OverColor.mkIso (by rw [h])).hom).hom x)) :=
  forgetLiftAppCon_naturality_eqToHom_apply S.FD c c1 h x

end TensorSpecies

end
