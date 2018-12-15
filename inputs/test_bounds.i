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

[Variables]
  [./u]
    order = FIRST
    family = LAGRANGE
  [../]

  [./v]
    order = FIRST
    family = LAGRANGE
  [../]

  [./f]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables]
  [./bounds_dummy]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
  [./diff_u]
    type = Diffusion
    variable = u
  [../]

  [./force_u]
    type = CoupledForce
    variable = u
    v = f
  [../]

  [./diff_f]
    type = Diffusion
    variable = f
  [../]

  [./diff_v]
    type = Diffusion
    variable = v
  [../]

  [./force_v]
    type = CoupledForce
    variable = v
    v = f
  [../]
[]

[BCs]
  [./left_f]
    type = DirichletBC
    variable = f
    boundary = 'left'
    value = 1
  [../]

  [./right_f]
    type = DirichletBC
    variable = f
    boundary = 'right'
    value = 1
  [../]

  [./left_u]
    type = DirichletBC
    variable = u
    boundary = 'left'
    value = 0
  [../]

  [./right_u]
    type = DirichletBC
    variable = u
    boundary = 'right'
    value = 0
  [../]

  [./top_u]
    type = DirichletBC
    variable = u
    boundary = 'top'
    value = 0
  [../]

  [./bottom_u]
    type = DirichletBC
    variable = u
    boundary = 'bottom'
    value = 0
  [../]

  [./left_v]
    type = DirichletBC
    variable = v
    boundary = 'left'
    value = 0
  [../]

  [./right_v]
    type = DirichletBC
    variable = v
    boundary = 'right'
    value = 0
  [../]

  [./top_v]
    type = DirichletBC
    variable = v
    boundary = 'top'
    value = 0
  [../]

  [./bottom_v]
    type = DirichletBC
    variable = v
    boundary = 'bottom'
    value = 0
  [../]
[]

[Bounds]
  # must use --use-petsc-dm command line argument
  [./u_bounds]
    type = BoundsAux
    variable = bounds_dummy
    bounded_variable = u
    upper = 0.03
    lower = 0.0
  [../]
[]

[Executioner]
  type = Steady

  # Preconditioned JFNK (default)
  solve_type = 'PJFNK'
  petsc_options_iname = '-snes_type'
  petsc_options_value = 'vinewtonrsls'
[]

[Outputs]
  execute_on = 'TIMESTEP_END'
  file_base = outputs/tests/test_bounds
  exodus = true
  append_date = true
  append_date_format = '%Y-%m-%d'
[]
