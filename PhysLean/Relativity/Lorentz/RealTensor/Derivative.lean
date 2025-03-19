/-
Copyright (c) 2025 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import PhysLean.Relativity.Tensors.Tree.Dot
import PhysLean.Relativity.Lorentz.Weyl.Metric
import PhysLean.Relativity.Lorentz.RealTensor.Basic
import PhysLean.Relativity.Lorentz.RealTensor.Vector.Pre.Basic
import PhysLean.Relativity.Lorentz.PauliMatrices.AsTensor
/-!

## Derivative of Real Lorentz tensors

-/
open Matrix
open MatrixGroups
open Complex
open TensorProduct
open IndexNotation
open CategoryTheory
open MonoidalCategory
open TensorSpecies
namespace realLorentzTensor
open TensorBasis

/-- The map between coordinates given a map ` ℝT(d, cm) → ℝT(d, cn)`. -/
noncomputable def mapToBasis {d n m : ℕ} {cm : Fin m → (realLorentzTensor d).C}
    {cn : Fin n → (realLorentzTensor d).C} (f : ℝT(d, cm) → ℝT(d, cn)) :
    (((j : Fin m) → Fin ((realLorentzTensor d).repDim (cm j))) → ℝ) →
    ((j : Fin n) → Fin ((realLorentzTensor d).repDim (cn j))) → ℝ :=
  Finsupp.equivFunOnFinite ∘ ((realLorentzTensor d).tensorBasis cn).repr.toEquiv.toFun ∘
  f ∘ ((realLorentzTensor d).tensorBasis cm).repr.symm.toEquiv.toFun
  ∘ Finsupp.equivFunOnFinite.symm

/-- The derivative of a function `f : ℝT(d, cm) → ℝT(d, cn)`, giving a function
    `ℝT(d, cm) → ℝT(d, (Sum.elim cm cn) ∘ finSumFinEquiv.symm)`. -/
noncomputable def derivative {d n m : ℕ} {cm : Fin m → (realLorentzTensor d).C}
    {cn : Fin n → (realLorentzTensor d).C} (f : ℝT(d, cm) → ℝT(d, cn)) :
    ℝT(d, cm) → ℝT(d, (Sum.elim cm cn) ∘ finSumFinEquiv.symm) := fun y =>
      ((realLorentzTensor d).tensorBasis _).repr.toEquiv.symm <|
      Finsupp.equivFunOnFinite.symm <| fun b =>
  /- The `b` componenet of the derivative of `f` evaluated at `y` is: -/
  /- The derivative of `mapToBasis f` -/
  fderiv ℝ (mapToBasis f)
  /- evaluated at the point `y` in `ℝT(d, cm)` -/
    (Finsupp.equivFunOnFinite (((realLorentzTensor d).tensorBasis cm).repr y))
  /- In the direction of `(prodEquiv b).1` -/
    (Finsupp.single (prodEquiv b).1 (1 : ℝ))
  /- The `(prodEquiv b).2` component of that derivative. -/
    (prodEquiv b).2

@[inherit_doc realLorentzTensor.derivative]
scoped[realLorentzTensor] notation "∂" => realLorentzTensor.derivative

open TensorBasis in
lemma derivative_repr {d n m : ℕ} {cm : Fin m → (realLorentzTensor d).C}
    {cn : Fin n → (realLorentzTensor d).C} (f : ℝT(d, cm) → ℝT(d, cn))
    (y : ℝT(d, cm))
    (b : (j : Fin (m + n)) →
      Fin ((realLorentzTensor d).repDim (((cm ⊕ᵥ cn) ∘ ⇑finSumFinEquiv.symm) j)))
    (h1 : DifferentiableAt ℝ (mapToBasis f)
      (Finsupp.equivFunOnFinite (((realLorentzTensor d).tensorBasis cm).repr y))) :
    ((realLorentzTensor d).tensorBasis _).repr (∂ f y) b =
    fderiv ℝ (fun y => mapToBasis f y (prodEquiv b).2)
      (((realLorentzTensor d).tensorBasis cm).repr y)
      (Finsupp.single (prodEquiv b).1 (1 : ℝ)) := by
  simp [derivative]
  rw [fderiv_pi]
  · simp
    rfl
  · rw [← differentiableAt_pi]
    exact h1

end realLorentzTensor
