[Mesh]
  #file = mesh_files/tpb_vol_cyl.msh
  type = GeneratedMesh
  dim = 2
  xmax = 1.0
  xmin = 0.0
  ymax = 1.0
  ymin = 0.0
  #zmax = 0.1
  #zmin = 0
  nx = 20
  ny = 20
  #nz = 2
[]

#==========================================================================#

[Variables]
  [./concentration]
    order = FIRST
    family = LAGRANGE
  [../]

  [./potential]
    order = FIRST
    family = LAGRANGE
  [../]
[]

#==========================================================================#

[Kernels]
  active = 'poissonDrift nernstDiffusion nernstDrift nernstButlerVolmer'

  [./poissonDrift]
    type = CoefDiffusion
    variable = potential
    coef = 1.0
  [../]

  [./nernstDiffusion]
    type = CoefDiffusion
    variable = concentration
    coef = 1.0
  [../]

  [./nernstDrift]
    type = CoupledNernstDrift
    variable = concentration
    z = 1.0
    F = 1.0
    R = 1.0
    T = 1.0
    D = 1.0
    coupled_variable = potential
  [../]

  [./nernstButlerVolmer]
    type = ButlerVolmerConstantEta
    variable = concentration
    exchange_rate = -10.0
    transfer_coefficient = 0.5
    z_number = 1.0
    faraday_constant = 1.0
    gas_constant = 1.0
    temperature = 1.0
    eta = 3.0
  [../]

  [./timeDerivativeConcentration]
    type = TimeDerivative
    variable = concentration
  [../]

  [./timeDerivativePotential]
    type = TimeDerivative
    variable = potential
  [../]
[]

#==========================================================================#

[BCs]
  [./concentrationRight]
    type = DirichletBC
    variable = concentration
    boundary = 'right'
    value = 1.0
  [../]

  [./concentrationLeft]
    type = DirichletBC
    variable = concentration
    boundary = 'left'
    value = 0.0
  [../]

  [./potentialRight]
    type = DirichletBC
    variable = potential
    boundary = 'right'
    value = 1.0
  [../]

  [./potentialLeft]
    type = DirichletBC
    variable = potential
    boundary = 'left'
    value = 0.0
  [../]
[]

#==========================================================================#

[Executioner]
  type = Steady
  #type = Transient
  #dt = 0.04
  #end_time = 2.0
  #trans_ss_check = true
  #ss_check_tol = 1e-07

  #[./TimeStepper]
  #  type = FunctionDT
  #  time_t = '0 1e10'
  #  time_dt = '0.1 0.1'
  #[../]

  solve_type = 'PJFNK'
  l_tol = 1e-07
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

#==========================================================================#

[Adaptivity]
  marker = errorfrac
  steps = 2

  [./Indicators]
    [./error]
      type = GradientJumpIndicator
      variable = concentration
    [../]
  [../]

  [./Markers]
    [./errorfrac]
      type = ErrorFractionMarker
      refine = 0.5
      coarsen = 0
      indicator = error
    [../]
  [../]
[]

#==========================================================================#

[Outputs]
  execute_on = 'timestep_end'
  exodus = true
  file_base = output_files/test_BV
[]
