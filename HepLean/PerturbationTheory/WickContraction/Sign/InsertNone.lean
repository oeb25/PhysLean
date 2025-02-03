/-
Copyright (c) 2025 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import HepLean.PerturbationTheory.WickContraction.Sign.Basic

/-!

# Sign on inserting and not contracting

-/

open FieldSpecification
variable {𝓕 : FieldSpecification}

namespace WickContraction
variable {n : ℕ} (c : WickContraction n)
open HepLean.List
open FieldStatistic

lemma signFinset_insertAndContract_none (φ : 𝓕.States) (φs : List 𝓕.States)
    (φsΛ : WickContraction φs.length)
    (i : Fin φs.length.succ) (i1 i2 : Fin φs.length) :
      (φsΛ ↩Λ φ i none).signFinset (finCongr (insertIdx_length_fin φ φs i).symm
      (i.succAbove i1)) (finCongr (insertIdx_length_fin φ φs i).symm (i.succAbove i2)) =
    if i.succAbove i1 < i ∧ i < i.succAbove i2 then
      Insert.insert (finCongr (insertIdx_length_fin φ φs i).symm i)
      (insertAndContractLiftFinset φ i (φsΛ.signFinset i1 i2))
    else
      (insertAndContractLiftFinset φ i (φsΛ.signFinset i1 i2)) := by
  ext k
  rcases insert_fin_eq_self φ i k with hk | hk
  · subst hk
    conv_lhs => simp only [Nat.succ_eq_add_one, signFinset, finCongr_apply, Finset.mem_filter,
      Finset.mem_univ, insertAndContract_none_getDual?_self, Option.isSome_none, Bool.false_eq_true,
      IsEmpty.forall_iff, or_self, and_true, true_and]
    by_cases h : i.succAbove i1 < i ∧ i < i.succAbove i2
    · simp [h, Fin.lt_def]
    · simp only [Nat.succ_eq_add_one, h, ↓reduceIte, self_not_mem_insertAndContractLiftFinset,
      iff_false]
      rw [Fin.lt_def, Fin.lt_def] at h ⊢
      simp_all
  · obtain ⟨k, hk⟩ := hk
    subst hk
    have h1 : Fin.cast (insertIdx_length_fin φ φs i).symm (i.succAbove k) ∈
      (if i.succAbove i1 < i ∧ i < i.succAbove i2 then
        Insert.insert ((finCongr (insertIdx_length_fin φ φs i).symm) i)
        (insertAndContractLiftFinset φ i (φsΛ.signFinset i1 i2))
      else insertAndContractLiftFinset φ i (φsΛ.signFinset i1 i2)) ↔
      Fin.cast (insertIdx_length_fin φ φs i).symm (i.succAbove k) ∈
        insertAndContractLiftFinset φ i (φsΛ.signFinset i1 i2) := by
      split
      · simp only [Nat.succ_eq_add_one, finCongr_apply, Finset.mem_insert, Fin.ext_iff,
        Fin.coe_cast, or_iff_right_iff_imp]
        intro h
        have h1 : i.succAbove k ≠ i := by
          exact Fin.succAbove_ne i k
        omega
      · simp
    rw [h1]
    rw [succAbove_mem_insertAndContractLiftFinset]
    simp only [Nat.succ_eq_add_one, signFinset, finCongr_apply, Finset.mem_filter, Finset.mem_univ,
      insertAndContract_none_succAbove_getDual?_eq_none_iff, true_and,
      insertAndContract_none_succAbove_getDual?_isSome_iff, insertAndContract_none_getDual?_get_eq]
    rw [Fin.lt_def, Fin.lt_def, Fin.lt_def, Fin.lt_def]
    simp only [Fin.coe_cast, Fin.val_fin_lt]
    rw [Fin.succAbove_lt_succAbove_iff, Fin.succAbove_lt_succAbove_iff]
    simp only [and_congr_right_iff]
    intro h1 h2
    conv_lhs =>
      rhs
      enter [h]
      rw [Fin.lt_def]
      simp only [Fin.coe_cast, Fin.val_fin_lt]
      rw [Fin.succAbove_lt_succAbove_iff]

/-- Given a Wick contraction `φsΛ` associated with a list of states `φs`
  and an `i : Fin φs.length.succ`, the change in sign of the contraction associated with
  inserting `φ` into `φs` at position `i` without contracting it.

  For each contracted pair `{a1, a2}` in `φsΛ` if `a1 < a2` such that `i` is within the range
  `a1 < i < a2` we pick up a sign equal to `𝓢(φ, φs[a2])`. -/
def signInsertNone (φ : 𝓕.States) (φs : List 𝓕.States) (φsΛ : WickContraction φs.length)
    (i : Fin φs.length.succ) : ℂ :=
  ∏ (a : φsΛ.1),
    if i.succAbove (φsΛ.fstFieldOfContract a) < i ∧ i < i.succAbove (φsΛ.sndFieldOfContract a) then
      𝓢(𝓕 |>ₛ φ, 𝓕 |>ₛ φs[φsΛ.sndFieldOfContract a])
    else 1

lemma sign_insert_none (φ : 𝓕.States) (φs : List 𝓕.States) (φsΛ : WickContraction φs.length)
    (i : Fin φs.length.succ) :
    (φsΛ ↩Λ φ i none).sign = (φsΛ.signInsertNone φ φs i) * φsΛ.sign := by
  rw [sign]
  rw [signInsertNone, sign, ← Finset.prod_mul_distrib]
  rw [insertAndContract_none_prod_contractions]
  congr
  funext a
  simp only [instCommGroup, Nat.succ_eq_add_one, insertAndContract_sndFieldOfContract,
    finCongr_apply, Fin.getElem_fin, Fin.coe_cast, insertIdx_getElem_fin,
    insertAndContract_fstFieldOfContract, ite_mul, one_mul]
  erw [signFinset_insertAndContract_none]
  split
  · rw [ofFinset_insert]
    simp only [instCommGroup, Nat.succ_eq_add_one, finCongr_apply, Fin.getElem_fin, Fin.coe_cast,
      List.getElem_insertIdx_self, map_mul]
    rw [stat_ofFinset_of_insertAndContractLiftFinset]
    simp only [exchangeSign_symm, instCommGroup.eq_1]
    simp
  · rw [stat_ofFinset_of_insertAndContractLiftFinset]

lemma signInsertNone_eq_mul_fst_snd (φ : 𝓕.States) (φs : List 𝓕.States)
    (φsΛ : WickContraction φs.length) (i : Fin φs.length.succ) :
  φsΛ.signInsertNone φ φs i = ∏ (a : φsΛ.1),
    (if i.succAbove (φsΛ.fstFieldOfContract a) < i then
      𝓢(𝓕 |>ₛ φ, 𝓕 |>ₛ φs[φsΛ.sndFieldOfContract a])
    else 1) *
    (if i.succAbove (φsΛ.sndFieldOfContract a) < i then
      𝓢(𝓕 |>ₛ φ, 𝓕 |>ₛ φs[φsΛ.sndFieldOfContract a])
    else 1) := by
  rw [signInsertNone]
  congr
  funext a
  split
  · rename_i h
    simp only [instCommGroup.eq_1, Fin.getElem_fin, h.1, ↓reduceIte, mul_ite, exchangeSign_mul_self,
      mul_one]
    rw [if_neg]
    omega
  · rename_i h
    simp only [Nat.succ_eq_add_one, not_and, not_lt] at h
    split <;> rename_i h1
    · simp_all only [forall_const, instCommGroup.eq_1, Fin.getElem_fin, mul_ite,
      exchangeSign_mul_self, mul_one]
      rw [if_pos]
      have h1 :i.succAbove (φsΛ.sndFieldOfContract a) ≠ i :=
        Fin.succAbove_ne i (φsΛ.sndFieldOfContract a)
      omega
    · simp only [not_lt] at h1
      rw [if_neg]
      simp only [mul_one]
      have hn := fstFieldOfContract_lt_sndFieldOfContract φsΛ a
      have hx := (Fin.succAbove_lt_succAbove_iff (p := i)).mpr hn
      omega

lemma signInsertNone_eq_prod_prod (φ : 𝓕.States) (φs : List 𝓕.States)
    (φsΛ : WickContraction φs.length) (i : Fin φs.length.succ) (hG : GradingCompliant φs φsΛ) :
    φsΛ.signInsertNone φ φs i = ∏ (a : φsΛ.1), ∏ (x : a),
      (if i.succAbove x < i then 𝓢(𝓕 |>ₛ φ, 𝓕 |>ₛ φs[x.1]) else 1) := by
  rw [signInsertNone_eq_mul_fst_snd]
  congr
  funext a
  rw [prod_finset_eq_mul_fst_snd]
  congr 1
  congr 1
  congr 1
  simp only [Fin.getElem_fin]
  erw [hG a]
  rfl

lemma sign_insert_none_zero (φ : 𝓕.States) (φs : List 𝓕.States) (φsΛ : WickContraction φs.length) :
    (φsΛ ↩Λ φ 0 none).sign = φsΛ.sign := by
  rw [sign_insert_none]
  simp [signInsertNone]

lemma signInsertNone_eq_prod_getDual?_Some (φ : 𝓕.States) (φs : List 𝓕.States)
    (φsΛ : WickContraction φs.length) (i : Fin φs.length.succ) (hG : GradingCompliant φs φsΛ) :
    φsΛ.signInsertNone φ φs i = ∏ (x : Fin φs.length),
      if (φsΛ.getDual? x).isSome then
        (if i.succAbove x < i then 𝓢(𝓕 |>ₛ φ, 𝓕 |>ₛ φs[x.1]) else 1)
      else 1 := by
  rw [signInsertNone_eq_prod_prod]
  trans ∏ (x : (a : φsΛ.1) × a), (if i.succAbove x.2 < i then 𝓢(𝓕 |>ₛ φ, 𝓕 |>ₛ φs[x.2.1]) else 1)
  · rw [Finset.prod_sigma']
    rfl
  rw [← φsΛ.sigmaContractedEquiv.symm.prod_comp]
  let e2 : Fin φs.length ≃ {x // (φsΛ.getDual? x).isSome} ⊕ {x // ¬ (φsΛ.getDual? x).isSome} := by
    exact (Equiv.sumCompl fun a => (φsΛ.getDual? a).isSome = true).symm
  rw [← e2.symm.prod_comp]
  simp only [instCommGroup.eq_1, Fin.getElem_fin, Fintype.prod_sum_type]
  conv_rhs =>
    rhs
    enter [2, a]
    rw [if_neg (by simpa [e2] using a.2)]
  conv_rhs =>
    lhs
    enter [2, a]
    rw [if_pos (by simpa [e2] using a.2)]
  simp only [Equiv.symm_symm, Equiv.sumCompl_apply_inl, Finset.prod_const_one, mul_one, e2]
  rfl
  exact hG

lemma signInsertNone_eq_filter_map (φ : 𝓕.States) (φs : List 𝓕.States)
    (φsΛ : WickContraction φs.length) (i : Fin φs.length.succ) (hG : GradingCompliant φs φsΛ) :
    φsΛ.signInsertNone φ φs i =
    𝓢(𝓕 |>ₛ φ, 𝓕 |>ₛ ((List.filter (fun x => (φsΛ.getDual? x).isSome ∧ i.succAbove x < i)
    (List.finRange φs.length)).map φs.get)) := by
  rw [signInsertNone_eq_prod_getDual?_Some]
  rw [FieldStatistic.ofList_map_eq_finset_prod]
  rw [map_prod]
  congr
  funext a
  simp only [instCommGroup.eq_1, Bool.decide_and, Bool.decide_eq_true, List.mem_filter,
    List.mem_finRange, Bool.and_eq_true, decide_eq_true_eq, true_and, Fin.getElem_fin]
  split
  · rename_i h
    simp only [h, true_and]
    split
    · rfl
    · simp only [map_one]
  · rename_i h
    simp [h]
  · refine List.Nodup.filter _ ?_
    exact List.nodup_finRange φs.length
  · exact hG

/-- The change in sign when inserting a field `φ` at `i` into `φsΛ` is equal
  to the sign got by moving `φ` through each field `φ₀…φᵢ₋₁` which has a dual. -/
lemma signInsertNone_eq_filterset (φ : 𝓕.States) (φs : List 𝓕.States)
    (φsΛ : WickContraction φs.length) (i : Fin φs.length.succ) (hG : GradingCompliant φs φsΛ) :
    φsΛ.signInsertNone φ φs i = 𝓢(𝓕 |>ₛ φ, 𝓕 |>ₛ ⟨φs.get, Finset.univ.filter
    (fun x => (φsΛ.getDual? x).isSome ∧ i.succAbove x < i)⟩) := by
  rw [ofFinset_eq_prod, signInsertNone_eq_prod_getDual?_Some, map_prod]
  congr
  funext a
  simp only [instCommGroup.eq_1, Finset.mem_filter, Finset.mem_univ, true_and, Fin.getElem_fin]
  split
  · rename_i h
    simp only [h, true_and]
    split
    · rfl
    · simp only [map_one]
  · rename_i h
    simp [h]
  · exact hG

end WickContraction
