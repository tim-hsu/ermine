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
  [./phi]
  [../]

  [./T]
  [../]
[]

[Materials]
  [./electricConductivity]
    type = GenericConstantMaterial
    prop_names  = 'sigma'
    prop_values = '1.0'
  [../]

  [./thermalConductivity]
    type = GenericConstantMaterial
    prop_names  = 'k'
    prop_values = '0.1'
  [../]
[]

[Kernels]
  [./electricDrift]
    type = DiffMatKernel
    variable = phi
    diff_coef = 'sigma'
  [../]

  [./heatConduction]
    type = DiffMatKernel
    variable = T
    diff_coef = 'k'
  [../]

  [./jouleHeating]
    type = JouleHeatingConstMaterial
    variable = T
    elec = phi
    conductivity = 'sigma'
  [../]
[]

[BCs]
  [./left_phi]
    type = DirichletBC
    variable = phi
    boundary = 'left'
    value = 0
  [../]

  [./right_phi]
    type = DirichletBC
    variable = phi
    boundary = 'right'
    value = 2
  [../]

  [./left_T]
    type = DirichletBC
    variable = T
    boundary = 'left'
    value = 0
  [../]

  [./right_T]
    type = DirichletBC
    variable = T
    boundary = 'right'
    value = 1
  [../]
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -sub_pc_type'
  petsc_options_value = '101 bjacobi ilu'
  # petsc_options_iname = '-pc_type -pc_hypre_type'
  # petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  file_base = outputs/tests/test-electro-thermo
  exodus = true
  append_date = true
  append_date_format = '%Y-%m-%d'
[]
