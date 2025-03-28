/-
Copyright (c) 2024 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import PhysLean.Relativity.Tensors.TensorSpecies.DualRepIso
/-!

# Contraction of vectors

This file is down stream of `TensorTree`.
There are other files in `TensorSpecies.Contractions` which are up-stream of `TensorTree`.

-/

open IndexNotation
open CategoryTheory
open MonoidalCategory

noncomputable section

namespace TensorSpecies
open TensorTree
variable {k : Type} [CommRing k] (S : TensorSpecies k)

/-- The equivariant map from ` S.FD.obj (Discrete.mk c) ⊗ S.FD.obj (Discrete.mk c)` to
  the underlying field obtained by contracting. -/
def contractSelfHom (c : S.C) : S.FD.obj (Discrete.mk c) ⊗ S.FD.obj (Discrete.mk c) ⟶
    𝟙_ (Rep k S.G) :=
  (S.FD.obj (Discrete.mk c) ◁ (S.dualRepIsoDiscrete c).hom) ≫ S.contr.app (Discrete.mk c)

open TensorProduct

/-- The contraction of two vectors in a tensor species of the same color, as a linear
  map to the underlying field. -/
def contractSelfField {S : TensorSpecies k} {c : S.C} :
    S.FD.obj (Discrete.mk c) ⊗[k] S.FD.obj (Discrete.mk c) →ₗ[k] k :=
  (S.contractSelfHom c).hom.hom

/-- Notation for `coCoContract` acting on a tmul. -/
scoped[TensorSpecies] notation "⟪" ψ "," φ "⟫ₜₛ" => contractSelfField (ψ ⊗ₜ φ)

/-- The map `contractSelfField` is equivariant with respect to the group action. -/
@[simp]
lemma contractSelfField_equivariant {S : TensorSpecies k} {c : S.C} {g : S.G}
    (ψ : S.FD.obj (Discrete.mk c)) (φ : S.FD.obj (Discrete.mk c)) :
    ⟪(S.FD.obj (Discrete.mk c)).ρ g ψ, (S.FD.obj (Discrete.mk c)).ρ g φ⟫ₜₛ = ⟪ψ, φ⟫ₜₛ := by
  simpa using congrFun (congrArg (fun x => x.hom.toFun)
    ((S.contractSelfHom c).comm g)) (ψ ⊗ₜ[k] φ)

/-- The contraction of two vectors of the same color is non-degenerate, i.e., `⟪ψ, φ⟫ₜₛ = 0` for all
`φ` implies `ψ = 0`.

Proof: the basic idea is that being degenerate contradicts the assumption of having a
unit in the tensor species.
-/
informal_lemma contractSelfField_non_degenerate where
  deps := [``contractSelfField]

/-- The contraction `⟪ψ, φ⟫ₜₛ` is related to the tensor tree
`{ψ | μ ⊗ (S.dualRepIsoDiscrete c).hom φ | μ}ᵀ`. -/
informal_lemma contractSelfField_tensorTree where
  deps := [``contractSelfField, ``TensorTree]

/-!

## IsNormOne

-/

/-- A vector satisfies `IsNormOne` if it has norm equal to one, i.e. if `⟪ψ, ψ⟫ₜₛ = 1`. -/
def IsNormOne {c : S.C} (ψ : S.FD.obj (Discrete.mk c)) : Prop := ⟪ψ, ψ⟫ₜₛ = 1

/-- If a vector is norm-one, then any vector in the orbit of that vector is also norm-one. -/
@[simp]
lemma action_isNormOne_of_isNormOne {c : S.C} {ψ : S.FD.obj (Discrete.mk c)} (g : S.G) :
    S.IsNormOne ((S.FD.obj (Discrete.mk c)).ρ g ψ) ↔ S.IsNormOne ψ := by
  simp only [IsNormOne, contractSelfField_equivariant]

/-!

## IsNormZero

-/

/-- A vector satisfies `IsNormZero` if it has norm equal to zero, i.e. if `⟪ψ, ψ⟫ₜₛ = 0`. -/
def IsNormZero {c : S.C} (ψ : S.FD.obj (Discrete.mk c)) : Prop := ⟪ψ, ψ⟫ₜₛ = 0

/-- The zero vector has norm equal to zero. -/
@[simp]
lemma zero_isNormZero {c : S.C} : @IsNormZero _ _ S c 0 := by
  simp only [IsNormZero, tmul_zero, map_zero]

/-- If a vector is norm-zero, then any scalar multiple of that vector is also norm-zero. -/
lemma smul_isNormZero_of_isNormZero {c : S.C} {ψ : S.FD.obj (Discrete.mk c)}
    (h : S.IsNormZero ψ) (a : k) : S.IsNormZero (a • ψ) := by
  simp only [IsNormZero, tmul_smul, map_smul, smul_tmul]
  rw [h]
  simp only [smul_eq_mul, mul_zero]

/-- If a vector is norm-zero, then any vector in the orbit of that vector is also norm-zero. -/
@[simp]
lemma action_isNormZero_iff_isNormZero {c : S.C} {ψ : S.FD.obj (Discrete.mk c)} (g : S.G) :
    S.IsNormZero ((S.FD.obj (Discrete.mk c)).ρ g ψ) ↔ S.IsNormZero ψ := by
  simp only [IsNormZero, contractSelfField_equivariant]

end TensorSpecies

end
