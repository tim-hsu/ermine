[Mesh]
  # file = meshes/micro/russiandoll/s4/MSRI_CAT_box10_shrink4.inp
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
    master_block = 'PT_MASK_1_TET4'
    paired_block = 'PT_MASK_2_TET4'
    new_boundary = 'interface_12'
  [../]
  [./phase_21_interface]
    type = SideSetsBetweenSubdomains
    depends_on = meshScale
    master_block = 'PT_MASK_2_TET4'
    paired_block = 'PT_MASK_1_TET4'
    new_boundary = 'interface_21'
  [../]

  [./phase_23_interface]
    type = SideSetsBetweenSubdomains
    depends_on = meshScale
    master_block = 'PT_MASK_2_TET4'
    paired_block = 'PT_MASK_3_TET4'
    new_boundary = 'interface_23'
  [../]

  [./phase_32_interface]
    type = SideSetsBetweenSubdomains
    depends_on = meshScale
    master_block = 'PT_MASK_3_TET4'
    paired_block = 'PT_MASK_2_TET4'
    new_boundary = 'interface_32'
  [../]
[]

#==========================================================================#

[GlobalParams]
  pO2_CE  = 1e-20   # (atm)
  function_phi_LSM = 'funcPotentialLSM' # (V)
  # source activity = lineal activity * tpb density * inverse volume fraction
  # s0      = 8138.3  # (A/cm^3)
[../]

[Functions]
  [./funcPotentialLSM]
    type = ParsedFunction
    value = 'E_rev - eta*t'
    vars = 'E_rev   eta'
    vals = '1.02845 0.4'
  [../]

  [./funcOverpotential]
    type = ParsedFunction
    value = 'eta*t'
    vars  = 'eta'
    vals  = '0.4'
  [../]

  [./funcTimeStepper]
    type = PiecewiseLinear
    x = '0.0  0.1 0.5 1.0' # time_t
    y = '0.01 0.1 0.1 0.2' # time_dt
  [../]
[]

[Materials]
  # PT_MASK_1_TET4 = pore
  # PT_MASK_2_TET4 = LSM
  # PT_MASK_3_TET4 = YSZ
  # PT_MASK_4_TET4 = TPB
  [./gasDiffFluxCoefficient]
    type  = ParsedMaterial
    block = 'PT_MASK_1_TET4 PT_MASK_4_TET4'
    f_name = 'gasDiffFluxCoef'
    constant_names        = 'D_O2  R          T'        # (cm^2/s), (J/K/mol), (K)
    constant_expressions  = '0.64  8.3144598  1073.0'
    function = 'D_O2/R/T*101325'
  [../]

  [./vacancyDiffFluxCoefficient]
    type  = ParsedMaterial
    block = 'PT_MASK_2_TET4 PT_MASK_4_TET4'
    f_name = 'vacDiffFluxCoef'
    constant_names        = 'D_O      a         NA'     # (cm^2/s), (cm), (1/mol)
    constant_expressions  = '7.5e-7   3.893e-8  6.022e23'
    function = 'D_O/(a^3)/NA*1e6'
  [../]

  [./vacancyDriftFluxCoefficient]
    type  = GenericConstantMaterial
    block = 'PT_MASK_3_TET4 PT_MASK_4_TET4'
    prop_names  = 'sigma_YSZ' # (S/cm)
    prop_values = '4e-2'
  [../]

  [./thermalConductivityLSM]
    type = GenericConstantMaterial
    block = 'PT_MASK_2_TET4'
    prop_names  = 'k_LSM'
    prop_values = '2e-2' # (W/K/cm)
  [../]

  [./thermalConductivityYSZ]
    type = GenericConstantMaterial
    block = 'PT_MASK_3_TET4 PT_MASK_4_TET4'
    prop_names  = 'k_YSZ'
    prop_values = '2e-2' # (W/K/cm)
  [../]
[]

#==========================================================================#

[Variables]
  [./p_O2]
    block = 'PT_MASK_1_TET4 PT_MASK_4_TET4'
    initial_condition = 0.21 # (atm)
    scaling = 1e4
  [../]

  [./V_O]
    block = 'PT_MASK_2_TET4 PT_MASK_4_TET4'
    initial_condition = 2.580947226225166e-08 # (.) pO2 = 0.21 atm
    scaling = 1e8
  [../]

  [./phi_YSZ]
    block = 'PT_MASK_3_TET4 PT_MASK_4_TET4'
    initial_condition = -0.00000 # (V)
    scaling = 1e7
  [../]

  [./T]
    block = 'PT_MASK_2_TET4 PT_MASK_3_TET4 PT_MASK_4_TET4'
    initial_condition = 1073.0 # (K)
    scaling = 1e2
  [../]
[]

#==========================================================================#

[Kernels]
  [./gasDiffusion]
    type  = DiffMatKernel
    block = 'PT_MASK_1_TET4 PT_MASK_4_TET4'
    variable  = p_O2
    diff_coef = 'gasDiffFluxCoef'
  [../]

  [./vacancyDiffusion]
    type  = DiffMatKernel
    block = 'PT_MASK_2_TET4 PT_MASK_4_TET4'
    variable  = V_O
    diff_coef = 'vacDiffFluxCoef'
  [../]

  [./vacancyIonicDrift]
    type  = DiffMatKernel
    block = 'PT_MASK_3_TET4 PT_MASK_4_TET4'
    variable  = phi_YSZ
    diff_coef = 'sigma_YSZ'
  [../]

  [./tpbReactionOxygenPore]
    type = CoupledTPBOxygenPressurePoreQS
    block = 'PT_MASK_4_TET4'
    variable = p_O2
    phi_YSZ = phi_YSZ
  [../]

  [./tpbReactionPotentialYSZ]
    type = CoupledTPBPotentialYSZQS
    block = 'PT_MASK_4_TET4'
    variable = phi_YSZ
    p_O2 = p_O2
  [../]

  [./thermalTransportLSM]
    type = HeatConduction
    block = 'PT_MASK_2_TET4'
    variable = T
    diffusion_coefficient = 'k_LSM' # (W/K/cm)
  [../]

  [./thermalTransportYSZ]
    type = HeatConduction
    block = 'PT_MASK_3_TET4 PT_MASK_4_TET4'
    variable = T
    diffusion_coefficient = 'k_YSZ' # (W/K/cm)
  [../]

  [./jouleHeatingYSZ]
    type = JouleHeatingConstMaterial
    block = 'PT_MASK_3_TET4 PT_MASK_4_TET4'
    variable = T
    elec = phi_YSZ
    conductivity = 'sigma_YSZ' # (S/cm)
  [../]

  [./tpbHeating]
    type = OverpotentialHeatingTPB
    block = 'PT_MASK_4_TET4'
    variable = T
    p_O2 = p_O2
    phi_YSZ = phi_YSZ
  [../]
[]

#==========================================================================#

[InterfaceKernels]
  [./interfaceSurfaceExchangeFullyCoupled]
    type = InterfaceSurfExchangeFullyCoupled
    variable = p_O2
    neighbor_var = V_O
    boundary = 'interface_12'
    k = 6.14e-6 # (cm/s)
  [../]

  [./interfaceChargeTransferFullyCoupled]
    type = InterfaceChargeTransferFullyCoupledQS
    variable = V_O
    neighbor_var = phi_YSZ
    boundary = 'interface_23'
    j0 = 0.193  # (A/cm^2)
  [../]
[]

#==========================================================================#

[BCs]
  [./oxygenPartialPressure_top]
    type = DirichletBC
    variable = p_O2
    boundary = 'SF_MASK_1_WITH_ZMIN'
    value = 0.21 # (atm)
  [../]

  [./potentialYSZ_bottom]
    type = DirichletBC
    variable = phi_YSZ
    boundary = 'SF_MASK_3_WITH_ZMAX'
    value = 0.00000 # (V)
  [../]

  [./temperature_top]
    type = DirichletBC
    variable = T
    boundary = 'SF_MASK_2_WITH_ZMIN SF_MASK_3_WITH_ZMIN'
    value = 1073.0 # (K)
  [../]

  [./temperature_bottom]
    type = DirichletBC
    variable = T
    boundary = 'SF_MASK_3_WITH_ZMAX'
    value = 1073.0 # (K)
  [../]
[]

#==========================================================================#

[AuxVariables]
  [./aux_pO2_LSM]
    block = 'PT_MASK_2_TET4 PT_MASK_4_TET4'
  [../]

  [./aux_Erev_LSM]
    block = 'PT_MASK_2_TET4 PT_MASK_4_TET4'
  [../]
[]

[AuxKernels]
  [./pO2_LSM]
    type = ParsedAux
    variable = aux_pO2_LSM
    block = 'PT_MASK_2_TET4 PT_MASK_4_TET4'
    function = '10^(-2.173913*log10(V_O) - 17.173913)'
    args = 'V_O'
  [../]

  [./Erev_LSM]
    type = ParsedAux
    variable = aux_Erev_LSM
    block = 'PT_MASK_2_TET4 PT_MASK_4_TET4'
    function = '-R*T/4/F * log(1e-20 / aux_pO2_LSM)'
    constant_names = 'R T F'
    constant_expressions = '8.3144598 1073 96485.33289' # (J/K/mol), (K), (C/mol)
    args = 'aux_pO2_LSM'
  [../]
[]

#==========================================================================#

[Postprocessors]
  [./I_YSZ_bottom]
    type = SideFluxIntegral
    variable = phi_YSZ
    diffusivity = 'sigma_YSZ'
    boundary = 'SF_MASK_3_WITH_ZMAX'
    outputs = 'console csv'
  [../]

  [./j_YSZ_bottom]
    type = SideFluxAverage
    variable = phi_YSZ
    diffusivity = 'sigma_YSZ'
    boundary = 'SF_MASK_3_WITH_ZMAX'
    outputs = 'console csv'
  [../]

  [./phi_LSM]
    type = FunctionValuePostprocessor
    function = 'funcPotentialLSM'
    outputs = 'console csv'
  [../]

  [./eta_total]
    type = FunctionValuePostprocessor
    function = 'funcOverpotential'
    outputs = 'console csv'
  [../]
[]

#==========================================================================#

[Preconditioning]
  [./smp]
    type = SMP
    full = true
    petsc_options = '-snes_converged_reason -ksp_converged_reason'
  [../]
[]

#==========================================================================#

[Executioner]
  type = Transient
  start_time = 0.0
  end_time = 1.0
  dtmin = 1e-4
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-10
  l_tol = 1e-3
  l_max_its = 20000

  [./TimeStepper]
    type = FunctionDT
    function = funcTimeStepper
  [../]
  solve_type = 'NEWTON'
  #petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  #petsc_options_value = 'hypre boomeramg 101'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -sub_pc_type'
  petsc_options_value = '101 bjacobi ilu'
[]

#==========================================================================#

[Outputs]
  #exodus = true
  csv = true
  # file_base = outputs/micro/russiandoll/s4/MSRI_CAT_box10_shrink4
  append_date = true
  append_date_format = '%Y-%m-%d'
  #print_perf_log = true
[]

[Debug]
  show_var_residual_norms = true
[]
