/-
Copyright (c) 2025 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import HepLean.Mathematics.List.InsertionSort
import HepLean.PerturbationTheory.Algebras.StateAlgebra.Basic
import HepLean.PerturbationTheory.Koszul.KoszulSign
/-!

# Time ordering of states

-/

namespace FieldSpecification
variable {𝓕 : FieldSpecification}

/-- The time ordering relation on states. We have that `timeOrderRel φ0 φ1` is true
  if and only if `φ1` has a time less-then or equal to `φ0`, or `φ1` is a negative
  asymptotic state, or `φ0` is a positive asymptotic state. -/
def timeOrderRel : 𝓕.States → 𝓕.States → Prop
  | States.outAsymp _, _ => True
  | States.position φ0, States.position φ1 => φ1.2 0 ≤ φ0.2 0
  | States.position _, States.inAsymp _ => True
  | States.position _, States.outAsymp _ => False
  | States.inAsymp _, States.outAsymp _ => False
  | States.inAsymp _, States.position _ => False
  | States.inAsymp _, States.inAsymp _ => True

/-- The relation `timeOrderRel` is decidable, but not computablly so due to
  `Real.decidableLE`. -/
noncomputable instance : (φ φ' : 𝓕.States) → Decidable (timeOrderRel φ φ')
  | States.outAsymp _, _ => isTrue True.intro
  | States.position φ0, States.position φ1 => inferInstanceAs (Decidable (φ1.2 0 ≤ φ0.2 0))
  | States.position _, States.inAsymp _ => isTrue True.intro
  | States.position _, States.outAsymp _ => isFalse (fun a => a)
  | States.inAsymp _, States.outAsymp _ => isFalse (fun a => a)
  | States.inAsymp _, States.position _ => isFalse (fun a => a)
  | States.inAsymp _, States.inAsymp _ => isTrue True.intro

/-- Time ordering is total. -/
instance : IsTotal 𝓕.States 𝓕.timeOrderRel where
  total a b := by
    cases a <;> cases b <;>
      simp only [or_self, or_false, or_true, timeOrderRel, Fin.isValue, implies_true, imp_self,
        IsEmpty.forall_iff]
    exact LinearOrder.le_total _ _

/-- Time ordering is transitive. -/
instance : IsTrans 𝓕.States 𝓕.timeOrderRel where
  trans a b c := by
    cases a <;> cases b <;> cases c <;>
      simp only [timeOrderRel, Fin.isValue, implies_true, imp_self, IsEmpty.forall_iff]
    exact fun h1 h2 => Preorder.le_trans _ _ _ h2 h1

noncomputable section

open FieldStatistic
open HepLean.List

/-- Given a list `φ :: φs` of states, the (zero-based) position of the state which is
  of maximum time. For example
  - for the list `[φ1(t = 4), φ2(t = 5), φ3(t = 3), φ4(t = 5)]` this would return `1`.
  This is defined for a list `φ :: φs` instead of `φs` to ensure that such a position exists.
-/
def maxTimeFieldPos (φ : 𝓕.States) (φs : List 𝓕.States) : ℕ :=
  insertionSortMinPos timeOrderRel φ φs

lemma maxTimeFieldPos_lt_length (φ : 𝓕.States) (φs : List 𝓕.States) :
    maxTimeFieldPos φ φs < (φ :: φs).length := by
  simp [maxTimeFieldPos]

/-- Given a list `φ :: φs` of states, the left-most state of maximum time, if there are more.
  As an example:
  - for the list `[φ1(t = 4), φ2(t = 5), φ3(t = 3), φ4(t = 5)]` this would return `φ2(t = 5)`.
  It is the state at the position `maxTimeFieldPos φ φs`.
-/
def maxTimeField (φ : 𝓕.States) (φs : List 𝓕.States) : 𝓕.States :=
  insertionSortMin timeOrderRel φ φs

/-- Given a list `φ :: φs` of states, the list with the left-most state of maximum
  time removed.
  As an example:
  - for the list `[φ1(t = 4), φ2(t = 5), φ3(t = 3), φ4(t = 5)]` this would return
    `[φ1(t = 4), φ3(t = 3), φ4(t = 5)]`.
-/
def eraseMaxTimeField (φ : 𝓕.States) (φs : List 𝓕.States) : List 𝓕.States :=
  insertionSortDropMinPos timeOrderRel φ φs

@[simp]
lemma eraseMaxTimeField_length (φ : 𝓕.States) (φs : List 𝓕.States) :
    (eraseMaxTimeField φ φs).length = φs.length := by
  simp [eraseMaxTimeField, insertionSortDropMinPos, eraseIdx_length']

lemma maxTimeFieldPos_lt_eraseMaxTimeField_length_succ (φ : 𝓕.States) (φs : List 𝓕.States) :
    maxTimeFieldPos φ φs < (eraseMaxTimeField φ φs).length.succ := by
  simp only [eraseMaxTimeField_length, Nat.succ_eq_add_one]
  exact maxTimeFieldPos_lt_length φ φs

/-- Given a list `φ :: φs` of states, the position of the left-most state of maximum
  time as an eement of `Fin (eraseMaxTimeField φ φs).length.succ`.
  As an example:
  - for the list `[φ1(t = 4), φ2(t = 5), φ3(t = 3), φ4(t = 5)]` this would return `⟨1,...⟩`.
-/
def maxTimeFieldPosFin (φ : 𝓕.States) (φs : List 𝓕.States) :
    Fin (eraseMaxTimeField φ φs).length.succ :=
  insertionSortMinPosFin timeOrderRel φ φs

lemma lt_maxTimeFieldPosFin_not_timeOrder (φ : 𝓕.States) (φs : List 𝓕.States)
    (i : Fin (eraseMaxTimeField φ φs).length)
    (hi : (maxTimeFieldPosFin φ φs).succAbove i < maxTimeFieldPosFin φ φs) :
    ¬ timeOrderRel ((eraseMaxTimeField φ φs)[i.val]) (maxTimeField φ φs) := by
  exact insertionSortMin_lt_mem_insertionSortDropMinPos_of_lt timeOrderRel φ φs i hi

lemma timeOrder_maxTimeField (φ : 𝓕.States) (φs : List 𝓕.States)
    (i : Fin (eraseMaxTimeField φ φs).length) :
    timeOrderRel (maxTimeField φ φs) ((eraseMaxTimeField φ φs)[i.val]) := by
  exact insertionSortMin_lt_mem_insertionSortDropMinPos timeOrderRel φ φs _

/-- The sign associated with putting a list of states into time order (with
  the state of greatest time to the left).
  We pick up a minus sign for every fermion paired crossed. -/
def timeOrderSign (φs : List 𝓕.States) : ℂ :=
  Wick.koszulSign 𝓕.statesStatistic 𝓕.timeOrderRel φs

lemma timeOrderSign_pair_ordered {φ ψ : 𝓕.States} (h : timeOrderRel φ ψ) :
    timeOrderSign [φ, ψ] = 1 := by
  simp only [timeOrderSign, Wick.koszulSign, Wick.koszulSignInsert, mul_one, ite_eq_left_iff,
    ite_eq_right_iff, and_imp]
  exact fun h' => False.elim (h' h)

lemma timeOrderSign_pair_not_ordered {φ ψ : 𝓕.States} (h : ¬ timeOrderRel φ ψ) :
    timeOrderSign [φ, ψ] = 𝓢(𝓕 |>ₛ φ, 𝓕 |>ₛ ψ) := by
  simp only [timeOrderSign, Wick.koszulSign, Wick.koszulSignInsert, mul_one, instCommGroup.eq_1]
  rw [if_neg h]
  simp [FieldStatistic.exchangeSign_eq_if]

lemma timerOrderSign_of_eraseMaxTimeField (φ : 𝓕.States) (φs : List 𝓕.States) :
    timeOrderSign (eraseMaxTimeField φ φs) = timeOrderSign (φ :: φs) *
    𝓢(𝓕 |>ₛ maxTimeField φ φs, 𝓕 |>ₛ (φ :: φs).take (maxTimeFieldPos φ φs)) := by
  rw [eraseMaxTimeField, insertionSortDropMinPos, timeOrderSign,
    Wick.koszulSign_eraseIdx_insertionSortMinPos]
  rw [← timeOrderSign, ← maxTimeField]
  rfl

/-- The time ordering of a list of states. A schematic example is:
  - `normalOrderList [φ1(t = 4), φ2(t = 5), φ3(t = 3), φ4(t = 5)]` is equal to
    `[φ2(t = 5), φ4(t = 5), φ1(t = 4), φ3(t = 3)]` -/
def timeOrderList (φs : List 𝓕.States) : List 𝓕.States :=
  List.insertionSort 𝓕.timeOrderRel φs

lemma timeOrderList_pair_ordered {φ ψ : 𝓕.States} (h : timeOrderRel φ ψ) :
    timeOrderList [φ, ψ] = [φ, ψ] := by
  simp only [timeOrderList, List.insertionSort, List.orderedInsert, ite_eq_left_iff,
    List.cons.injEq, and_true]
  exact fun h' => False.elim (h' h)

lemma timeOrderList_pair_not_ordered {φ ψ : 𝓕.States} (h : ¬ timeOrderRel φ ψ) :
    timeOrderList [φ, ψ] = [ψ, φ] := by
  simp only [timeOrderList, List.insertionSort, List.orderedInsert, ite_eq_right_iff,
    List.cons.injEq, and_true]
  exact fun h' => False.elim (h h')

@[simp]
lemma timeOrderList_nil : timeOrderList (𝓕 := 𝓕) [] = [] := by
  simp [timeOrderList]

lemma timeOrderList_eq_maxTimeField_timeOrderList (φ : 𝓕.States) (φs : List 𝓕.States) :
    timeOrderList (φ :: φs) = maxTimeField φ φs :: timeOrderList (eraseMaxTimeField φ φs) := by
  exact insertionSort_eq_insertionSortMin_cons timeOrderRel φ φs

end
end FieldSpecification
