import Mathlib.Data.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

structure NonTrivialZero where
  sigma : ℝ
  t : ℝ
  t_ne_zero : t ≠ 0

noncomputable def D (z : NonTrivialZero) : ℂ :=
  let rho : ℂ := ⟨z.sigma, z.t⟩
  rho * (1 - rho)

lemma D_expansion (z : NonTrivialZero) :
  D z = ⟨z.sigma * (1 - z.sigma) + z.t ^ 2, z.t * (1 - 2 * z.sigma)⟩ := by
  dsimp [D]
  apply Complex.ext
  · simp only [Complex.mul_re, Complex.sub_re, Complex.one_re, Complex.sub_im, Complex.one_im]
    ring
  · simp only [Complex.mul_im, Complex.sub_re, Complex.one_re, Complex.sub_im, Complex.one_im]
    ring

noncomputable def inverse_zero_sum (z : NonTrivialZero) : ℂ :=
  let rho : ℂ := ⟨z.sigma, z.t⟩
  let d := rho * (1 - rho)
  1 / d + 1 / (starRingEnd ℂ d)

lemma C_always_real (z : NonTrivialZero) : (inverse_zero_sum z).im = 0 := by
  dsimp [inverse_zero_sum]
  set rho : ℂ := ⟨z.sigma, z.t⟩
  set d := rho * (1 - rho)
  have h_conj_inv : 1 / (starRingEnd ℂ d) = starRingEnd ℂ (1 / d) := by
    rw [map_div₀, map_one]
  rw [h_conj_inv, add_comm]
  rw [Complex.conj_im]
  ring

theorem offline_zero_incompatible (z : NonTrivialZero) (h_offline : z.sigma ≠ 1 / 2) : (D z).im ≠ 0 := by
  rw [D_expansion]
  intro h_im_zero
  dsimp at h_im_zero
  have h_imag : z.t * (1 - 2 * z.sigma) = 0 := h_im_zero
  cases mul_eq_zero.mp h_imag with
  | inl h1 => 
    exact z.t_ne_zero h1
  | inr h2 => 
    exact h_offline (by linarith)

theorem minimal_entropy_collapse (z : NonTrivialZero) (h_mandate : (D z).im = 0) : z.sigma = 1 / 2 := by
  by_contra h_offline
  have h_torsion := offline_zero_incompatible z h_offline
  exact h_torsion h_mandate

noncomputable def spectral_eigenvalue (z : NonTrivialZero) : ℂ :=
  let rho : ℂ := ⟨z.sigma, z.t⟩
  rho - (1 / 2 : ℂ)

theorem spectral_rigidity_law (z : NonTrivialZero) (h_mandate : (D z).im = 0) : 
  (spectral_eigenvalue z).re = 0 := by
  have h_sigma := minimal_entropy_collapse z h_mandate
  dsimp [spectral_eigenvalue]
  have h_half_re : ((1 / 2 : ℂ)).re = 1 / 2 := by simp
  rw [h_half_re]
  linarith