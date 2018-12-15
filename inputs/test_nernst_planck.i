[Mesh]
  #file = mesh_files/tpb_vol_cyl.msh
  type = GeneratedMesh
  dim = 2
  xmax = 1
  xmin = 0
  ymax = 1
  ymin = 0
  nx = 20
  ny = 20
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
  active = 'diffusion nernstDrift drift'
  [./diffusion]
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
    diffusivity = 5.0
    coupled_variable = potential
  [../]

  [./drift]
    type = CoefDiffusion
    variable = potential
    coef = 1.0
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
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

#==========================================================================#

[Outputs]
  exodus = true
  file_base = outputs/tests/nernst-planck
[]
