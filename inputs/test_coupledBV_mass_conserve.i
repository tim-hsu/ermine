[Mesh]
   file = mesh_files/tpb_vol_cyl_small.msh
[]

#==========================================================================#

[Variables]
  ## phase1 = pore, phase2 = LSM, phase3 = YSZ, phase4 = TPB
  [./oxygenConcPore]
    order = FIRST
    family = LAGRANGE
    block = 'phase1 phase4'
    initial_condition = 0.0
  [../]

  [./vacancyConcLSM]
    order = FIRST
    family = LAGRANGE
    block = 'phase2 phase4'
    initial_condition = 1.0
    scaling = 1e14
  [../]

  [./dummyVarYSZ]
    order = FIRST
    family = LAGRANGE
    block = 'phase3 phase4'
    initial_condition = 0.0
    scaling = 1e14
  [../]

  [./potentialLSM]
    order = FIRST
    family = LAGRANGE
    block = 'phase2 phase4'
    initial_condition = 1.0
    #scaling = 1e-8
  [../]

  [./potentialYSZ]
    order = FIRST
    family = LAGRANGE
    block = 'phase3 phase4'
    initial_condition = 0.5
    #scaling = 1e-8
  [../]
[]

#==========================================================================#

[Kernels]
  #active  = 'oxygenDiffPore vacancyDiffLSM vacancyNernstDriftLSM potentialDriftLSM potentialDriftYSZ'
  [./oxygenDiffPore]
    type = CoefDiffusion
    variable = oxygenConcPore
    block = 'phase1 phase4'
    coef = 1
  [../]

  [./vacancyDiffLSM]
    type = CoefDiffusion
    variable = vacancyConcLSM
    block = 'phase2 phase4'
    coef = 1
  [../]

  [./dummyVarDiffYSZ]
    type = CoefDiffusion
    variable = dummyVarYSZ
    block = 'phase3 phase4'
    coef = 1
  [../]

  [./vacancySourceLSM]
    type = CoupledButlerVacancyLSM
    variable = vacancyConcLSM
    block = 'phase4'
    phi_lsm = potentialLSM
    phi_ysz = potentialYSZ
    r = 0.5
    F = 1
    R = 1
    T = 1
    E_rev = 1.0
  [../]

  [./dummaryVarSourceYSZ]
    type = CoupledButlerForce
    variable = dummyVarYSZ
    block = 'phase4'
    c = vacancyConcLSM
    phi_lsm = potentialLSM
    phi_ysz = potentialYSZ
    r = -0.5
    F = 1
    R = 1
    T = 1
    E_rev = 1.0
  [../]

  [./potentialDriftLSM]
    type = CoefDiffusion
    variable = potentialLSM
    block = 'phase2 phase4'
    coef = 1
  [../]

  [./potentialDriftYSZ]
    type = CoefDiffusion
    variable = potentialYSZ
    block = 'phase3 phase4'
    coef = 1
  [../]

  [./timeDerivativeOxygenPore]
    type = TimeDerivative
    variable = oxygenConcPore
    block = 'phase1 phase4'
  [../]

  [./timeDerivativeVacancyLSM]
    type = TimeDerivative
    variable = vacancyConcLSM
    block = 'phase2 phase4'
  [../]

  [./timeDerivativeDummyVarYSZ]
    type = TimeDerivative
    variable = dummyVarYSZ
    block = 'phase3 phase4'
  [../]

  [./timeDerivativePotentialLSM]
    type = TimeDerivative
    variable = potentialLSM
    block = 'phase2 phase4'
  [../]

  [./timeDerivativePotentialYSZ]
    type = TimeDerivative
    variable = potentialYSZ
    block = 'phase3 phase4'
  [../]
[]

#==========================================================================#

[BCs]
  [./oxygenTop]
    type = DirichletBC
    variable = oxygenConcPore
    boundary = 'phase1_top'
    value = 0
  [../]

  [./oxygenBottom]
    type = DirichletBC
    variable = oxygenConcPore
    boundary = 'phase1_bottom'
    value = 0
  [../]

  #[./vacancyLSMTop]
  #  type = DirichletBC
  #  variable = vacancyConcLSM
  #  boundary = 'phase2_top'
  #  value = 0
  #[../]
  #
  #[./vacancyLSMBottom]
  #  type = DirichletBC
  #  variable = vacancyConcLSM
  #  boundary = 'phase2_bottom'
  #  value = 1
  #[../]

  [./potentialLSMTop]
    type = DirichletBC
    variable = potentialLSM
    boundary = 'phase2_top'
    value = 1.0
  [../]

  [./potentialLSMBottom]
    type = DirichletBC
    variable = potentialLSM
    boundary = 'phase2_bottom'
    value = 1.0
  [../]

  [./potentialYSZTop]
    type = DirichletBC
    variable = potentialYSZ
    boundary = 'phase3_top'
    value = 0.5
  [../]

  [./potentialYSZBottom]
    type = DirichletBC
    variable = potentialYSZ
    boundary = 'phase3_bottom'
    value = 0.5
  [../]
[]

#==========================================================================#

#[Adaptivity]
#  marker = errorfrac
#  steps = 2
#
#  [./Indicators]
#    [./error]
#      type = GradientJumpIndicator
#      variable = vacancyConcLSM
#    [../]
#  [../]
#
#  [./Markers]
#    [./errorfrac]
#      type = ErrorFractionMarker
#      refine = 0.5
#      coarsen = 0
#      indicator = error
#    [../]
#  [../]
#[]

#==========================================================================#

#[Preconditioning]
#  [./smp]
#    type = SMP
#    full = true
#    petsc_options_iname = '-snes_type'
#    petsc_options_value = 'test'
#  [../]
#[]

#==========================================================================#

#[Postprocessors]
#  [./vacancyLSMAvgValuePhase4]
#    type = ElementAverageValue
#    variable = vacancyConcLSM
#    block = 'phase4'
#    outputs = csv
#    execute_on = 'timestep_begin'
#  [../]
#[]

#==========================================================================#

[Executioner]
  #type = Steady
  type = Transient
  #dt = 1.0
  #end_time = 20.0
  trans_ss_check = true
  ss_check_tol = 1e-04

  [./TimeStepper]
    type = FunctionDT
    time_t = '0 1e10'
    time_dt = '0.5 0.5'
  [../]

  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

#==========================================================================#

[Outputs]
  execute_on = 'timestep_begin'
  exodus = true
  csv = true
  file_base = output_files/test_coupledBV
  append_date = true
  append_date_format = '%Y-%m-%d'
[]
