[Mesh]
  file = meshes/test_isolated_circle_phase.msh
[]

[MeshModifiers]
  [./meshScale]
    type = Transform
    transform = SCALE
    vector_value = '1e-4 1e-4 1e-4' # from um to cm
  [../]

  [./phase_12_interface]
    type = SideSetsBetweenSubdomains
    depends_on = meshScale
    master_block = 'phase1'
    paired_block = 'phase2'
    new_boundary = 'interface_12'
  [../]

  [./phase_21_interface]
    type = SideSetsBetweenSubdomains
    depends_on = meshScale
    master_block = 'phase2'
    paired_block = 'phase1'
    new_boundary = 'interface_21'
  [../]
[]

#==========================================================================#

[GlobalParams]
# E_rev   = 1.028   # (V)
# phi_LSM = 0.928   # (V)
  pO2_CE  = 1e-20   # (atm)
[../]

[Materials]
  # phase1 = pore
  # phase2 = LSM
  #[./gasDiffFluxCoefficient]
  #  type  = ParsedMaterial
  #  block = 'phase1'
  #  f_name = 'gasDiffFluxCoef'
  #  constant_names        = 'D_O2  R          T'        # (cm^2/s), (J/K/mol), (K)
  #  constant_expressions  = '0.64  8.3144598  1073.0'
  #  function = 'D_O2/R/T*101325'
  #[../]

  [./vacancyDiffFluxCoefficient]
    type  = ParsedMaterial
    block = 'phase1'
    f_name = 'vacDiffFluxCoef'
    constant_names        = 'D_O      a         NA'     # (cm^2/s), (cm), (1/mol), .
    constant_expressions  = '7.5e-7   3.893e-8  6.022e23'
    function = 'D_O/(a^3)/NA*1e6'
  [../]

  [./vacancyDriftFluxCoefficient]
    type  = GenericConstantMaterial
    block = 'phase2'
    prop_names  = 'sigma_YSZ' # (S/cm)
    prop_values = '4e-2'
  [../]
[]

#==========================================================================#

[Variables]
  #[./p_O2]
  #  block = 'phase1'
  #  initial_condition = 0.21 # (atm)
  #  #scaling = 1e1
  #[../]

  [./V_O]
    block = 'phase1'
    initial_condition = 2.580947226225166e-08 # (.) pO2 = 0.21 atm
    scaling = 1e8
  [../]

  [./phi_YSZ]
    block = 'phase2'
    initial_condition = -0.00000 # (V)
    scaling = 1e8
  [../]
[]

#==========================================================================#

[Kernels]
  #[./gasDiffusion]
  #  type  = DiffMatKernel
  #  block = 'phase1'
  #  variable  = p_O2
  #  diff_coef = 'gasDiffFluxCoef'
  #[../]

  [./vacancyDiffusion]
    type  = DiffMatKernel
    block = 'phase1'
    variable  = V_O
    diff_coef = 'vacDiffFluxCoef'
  [../]

  [./vacancyIonicDrift]
    type  = DiffMatKernel
    block = 'phase2'
    variable  = phi_YSZ
    diff_coef = 'sigma_YSZ'
  [../]
[]

#==========================================================================#

[InterfaceKernels]
  #[./interfaceSurfaceExchangeFullyCoupled]
  #  type = InterfaceSurfExchangeFullyCoupled
  #  variable = p_O2
  #  neighbor_var = V_O
  #  boundary = 'interface_12'
  #  k = 6.14e-6 # (cm/s)
  #[../]

  [./interfaceChargeTransferFullyCoupled]
    type = InterfaceChargeTransferFullyCoupled
    variable = V_O
    neighbor_var = phi_YSZ
    boundary = 'interface_12'
    j0 = 0.193  # (A/cm^2)
  [../]
[]

#==========================================================================#

[BCs]
  #[./oxygenPoreTop]
  #  type = DirichletBC
  #  variable = oxygenConcPore
  #  boundary = 'phase1_top'
  #  value = 2.385075588176694e-06 # (mol/cm^3)
  #[../]

  #[./vacancySiteFractionTop]
  #  type = DirichletBC
  #  variable = V_O
  #  boundary = 'phase2_top'
  #  value = 2.580947226225166e-08 # (.) pO2 = 0.21 atm
  #  #value = 3.019951720402013e-07 # pO2 = 1e-3 atm
  #  #value = 2.63953e-8 # pO2 = 0.20 atm
  #[../]
  #
  #[./vacancySiteFractionBottom]
  #  type = DirichletBC
  #  variable = V_O
  #  boundary = 'phase2_bottom'
  #  value = 3.019951720402013e-07 # pO2 = 1e-3 atm
  #  #value = 3.630780547701010e-08 # pO2 = 0.1 atm
  #  #value = 2.63953e-8 # pO2 = 0.20 atm
  #[../]

  [./potentialYSZTop]
    type = DirichletBC
    variable = phi_YSZ
    boundary = 'phase2_top'
    value = -0.01 # (V)
  [../]

  [./potentialYSZBottom]
    type = DirichletBC
    variable = phi_YSZ
    boundary = 'phase2_bottom'
    value = 0.0 # (V)
  [../]
[]

#==========================================================================#

[AuxVariables]
  [./aux_pO2_LSM]
    block = 'phase1'
  [../]

  [./aux_Erev_LSM]
    block = 'phase1'
  [../]
[]

[AuxKernels]
  [./pO2_LSM]
    type = ParsedAux
    variable = aux_pO2_LSM
    block = 'phase1'
    function = '10^(-2.173913*log10(V_O) - 17.173913)'
    args = 'V_O'
  [../]

  [./Erev_LSM]
    type = ParsedAux
    variable = aux_Erev_LSM
    block = 'phase1'
    function = '-R*T/4/F * log(1e-20 / aux_pO2_LSM)'
    constant_names = 'R T F'
    constant_expressions = '8.3144598 1073 96485.33289' # (J/K/mol), (K), (C/mol)
    args = 'aux_pO2_LSM'
  [../]
[]

#==========================================================================#

[Postprocessors]
  [./isoPoreSurfFluxIntegral]
    type = SideFluxIntegral
    variable = p_O2
    diffusivity = 'gasDiffFluxCoef'
    boundary = 'interface_12'
    outputs = 'console'
  [../]

  [./topFluxIntegral]
    type = SideFluxIntegral
    variable = V_O
    diffusivity = 'vacDiffFluxCoef'
    boundary = 'phase2_top'
    outputs = 'console'
  [../]

  [./bottomFluxIntegral]
    type = SideFluxIntegral
    variable = V_O
    diffusivity = 'vacDiffFluxCoef'
    boundary = 'phase2_bottom'
    outputs = 'console'
  [../]

  #[./J_interface23]
  #  type = SideFluxAverage
  #  variable = oxygenConcLSM
  #  diffusivity = 'D_O'
  #  boundary = 'interface_23'
  #  outputs = 'console'
  #[../]
  #
  #[./j_interface32]
  #  type = SideFluxAverage
  #  variable = potentialYSZ
  #  diffusivity = 'sigma_YSZ'
  #  boundary = 'interface_32'
  #  outputs = 'console'
  #[../]

  #[./I_YSZ_bottom]
  #  type = SideFluxIntegral
  #  variable = potentialYSZ
  #  diffusivity = 'sigma_YSZ'
  #  boundary = 'phase3_bottom'
  #  outputs = 'console'
  #[../]
  #
  #[./j_YSZ_bottom]
  #  type = SideFluxAverage
  #  variable = potentialYSZ
  #  diffusivity = 'sigma_YSZ'
  #  boundary = 'phase3_bottom'
  #  outputs = 'console'
  #[../]
[]

#==========================================================================#

[Executioner]
  type = Steady

  #nl_rel_tol = 1e-16

  type = Transient
  start_time = 0.1
  dt = 0.1
  end_time = 1.0

  #[./TimeStepper]
  #  type = FunctionDT
  #  time_t = '3600 3700'
  #  time_dt = '0.01 1'
  #[../]

  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

#==========================================================================#

[Outputs]
  exodus = true
  file_base = outputs/test_isoLSM_YSZ
  append_date = true
  append_date_format = '%Y-%m-%d'
  #print_perf_log = true
[]

[Debug]
  show_var_residual_norms = true
[]
