[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
  nx = 40
  ny = 40
[]

[GlobalParams]
  pO2_CE  = 1e-1   # (atm)
  function_phi_LSM = 'funcPotentialLSM' # (V)
  s0 = 0.5 # (A/cm^3)
  z = 1.0
  F = 1.0
  R = 1.0
  T = 1.0
[../]

[Functions]
  [./funcPotentialLSM]
    type = ParsedFunction
    value = 'phi_LSM'
    vars = 'phi_LSM'
    vals = '-0.425'
  [../]

  # [./funcOverpotential]
  #   type = ParsedFunction
  #   value = 'eta*t'
  #   vars  = 'eta'
  #   vals  = '0.4'
  # [../]

  # [./funcTimeStepper]
  #   type = PiecewiseLinear
  #   x = '0.0  0.1 0.5 1.0' # time_t
  #   y = '0.01 0.1 0.1 0.2' # time_dt
  # [../]
[]

[Materials]
  # phase1 = pore
  # phase2 = LSM
  # phase3 = YSZ
  # phase4 = TPB
  [./gasDiffFluxCoefficient]
    type = GenericConstantMaterial
    prop_names  = 'D_O2' # (S/cm)
    prop_values = '1'
  [../]

  [./vacancyDriftFluxCoefficient]
    type = GenericConstantMaterial
    prop_names  = 'sigma_YSZ' # (S/cm)
    prop_values = '1'
  [../]

  [./thermalConductivityYSZ]
    type = GenericConstantMaterial
    prop_names  = 'k_YSZ'
    prop_values = '1' # (W/K/cm)
  [../]
[]

#==========================================================================#

[Variables]
  [./const_pO2]
    initial_condition = 1.0
  [../]

  [./const_phi]
    initial_condition = 0.0
  [../]

  [./T]
    initial_condition = 0.0 # (K)
    # scaling = 1e4
  [../]
[]

#==========================================================================#

[Kernels]
  [./const_pO2_diffusion]
    type  = Diffusion
    variable  = const_pO2
  [../]

  [./const_phi_diffusion]
    type  = Diffusion
    variable  = const_phi
  [../]

  [./thermalTransportYSZ]
    type = HeatConduction
    variable = T
    diffusion_coefficient = 'k_YSZ' # (W/K/cm)
  [../]

  [./tpbHeating]
    type = OverpotentialHeatingTPB
    variable = T
    p_O2 = const_pO2
    phi_YSZ = const_phi
  [../]
[]

#==========================================================================#

[BCs]
  [./pO2_left]
    type = DirichletBC
    variable = const_pO2
    boundary = 'left'
    value = 1.0 # (atm)
  [../]
  [./pO2_right]
    type = DirichletBC
    variable = const_pO2
    boundary = 'right'
    value = 1.0 # (atm)
  [../]

  [./phi_left]
    type = DirichletBC
    variable = const_phi
    boundary = 'left'
    value = 0.00000 # (V)
  [../]
  [./phi_right]
    type = DirichletBC
    variable = const_phi
    boundary = 'right'
    value = 0.00000 # (V)
  [../]

  [./T_left]
    type = DirichletBC
    variable = T
    boundary = 'left'
    value = 0.0 # (K)
  [../]

  [./T_right]
    type = DirichletBC
    variable = T
    boundary = 'right'
    value = 0.0 # (K)
  [../]
[]

#==========================================================================#


[Preconditioning]
  [./smp]
    type = SMP
    full = true
    #off_diag_column = p_O2
    #off_diag_row = phi_YSZ
    petsc_options = '-snes_converged_reason -ksp_converged_reason'
    #petsc_options_iname = '-pc_type -mat_fd_coloring_err -mat_fd_type -snes_type'
    #petsc_options_value = 'lu       1e-6                 ds           test'
    #petsc_options_iname = '-snes_type'
    #petsc_options_value = 'test'
  [../]
[]

#==========================================================================#

[Executioner]
  type = Steady
  nl_rel_tol = 1e-20
  nl_rel_step_tol = 1e-14
  # nl_abs_tol = 1e-10
  # l_tol = 1e-04
  # l_abs_step_tol = -1
  l_max_its = 1000

  solve_type = 'NEWTON'
  #petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  #petsc_options_value = 'hypre boomeramg 50'
  petsc_options_iname = '-ksp_gmres_restart -pc_type'
  petsc_options_value = '101 bjacobi'
[]

#==========================================================================#

[Outputs]
  exodus = true
  file_base = outputs/tests/tpb-eta-heating
  append_date = true
  append_date_format = '%Y-%m-%d'
  #print_perf_log = true
[]

[Debug]
  show_var_residual_norms = true
[]
