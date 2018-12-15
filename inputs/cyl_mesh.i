[Mesh]
  file = ../../gmsh/tpb_vol_cyl.msh
  # file = ../../gmsh/tpb_vol_cyl_10um_debug.msh
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

  [./phase_23_interface]
    type = SideSetsBetweenSubdomains
    depends_on = meshScale
    master_block = 'phase2'
    paired_block = 'phase3'
    new_boundary = 'interface_23'
  [../]

  [./phase_32_interface]
    type = SideSetsBetweenSubdomains
    depends_on = meshScale
    master_block = 'phase3'
    paired_block = 'phase2'
    new_boundary = 'interface_32'
  [../]
[]

#==========================================================================#

[GlobalParams]
  pO2_CE  = 1e-20   # (atm)
  function_phi_LSM = 'funcPotentialLSM' # (V)
  s0 = 1e3 # (A/cm^3) (6.8 * 20)
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
  # phase1 = pore
  # phase2 = LSM
  # phase3 = YSZ
  # phase4 = TPB
  [./gasDiffFluxCoefficient]
    type  = ParsedMaterial
    block = 'phase1 phase4'
    f_name = 'gasDiffFluxCoef'
    constant_names        = 'D_O2  R          T'        # (cm^2/s), (J/K/mol), (K)
    constant_expressions  = '0.64  8.3144598  1073.0'
    function = 'D_O2/R/T*101325'
  [../]

  [./vacancyDiffFluxCoefficient]
    type  = ParsedMaterial
    block = 'phase2 phase4'
    f_name = 'vacDiffFluxCoef'
    constant_names        = 'D_O      a         NA'     # (cm^2/s), (cm), (1/mol), .
    constant_expressions  = '7.5e-7   3.893e-8  6.022e23'
    function = 'D_O/(a^3)/NA*1e6'
  [../]

  [./vacancyDriftFluxCoefficient]
    type  = GenericConstantMaterial
    block = 'phase3 phase4'
    prop_names  = 'sigma_YSZ' # (S/cm)
    prop_values = '4e-2'
  [../]

  [./thermalConductivityLSM]
    type = GenericConstantMaterial
    block = 'phase2'
    prop_names  = 'k_LSM'
    prop_values = '2e-2' # (W/K/cm)
  [../]

  [./thermalConductivityYSZ]
    type = GenericConstantMaterial
    block = 'phase3 phase4'
    prop_names  = 'k_YSZ'
    prop_values = '2e-2' # (W/K/cm)
  [../]
[]

#==========================================================================#

[Variables]
  [./p_O2]
    block = 'phase1 phase4'
    initial_condition = 0.21 # (atm)
    scaling = 1e4
  [../]

  [./V_O]
    block = 'phase2 phase4'
    initial_condition = 2.580947226225166e-08 # (.) pO2 = 0.21 atm
    scaling = 1e8
  [../]

  [./phi_YSZ]
    block = 'phase3 phase4'
    initial_condition = -0.00000 # (V)
    scaling = 1e7
  [../]

  [./T]
    block = 'phase2 phase3 phase4'
    initial_condition = 1073 # (K)
    scaling = 1e4
  [../]
[]

#==========================================================================#

[Kernels]
  [./gasDiffusion]
    type  = DiffMatKernel
    block = 'phase1 phase4'
    variable  = p_O2
    diff_coef = 'gasDiffFluxCoef'
  [../]

  [./vacancyDiffusion]
    type  = DiffMatKernel
    block = 'phase2 phase4'
    variable  = V_O
    diff_coef = 'vacDiffFluxCoef'
  [../]

  [./vacancyIonicDrift]
    type  = DiffMatKernel
    block = 'phase3 phase4'
    variable  = phi_YSZ
    diff_coef = 'sigma_YSZ'
  [../]

  [./tpbReactionOxygenPore]
    type = CoupledTPBOxygenPressurePoreQS
    block = 'phase4'
    variable = p_O2
    phi_YSZ = phi_YSZ
  [../]

  [./tpbReactionPotentialYSZ]
    type = CoupledTPBPotentialYSZQS
    block = 'phase4'
    variable = phi_YSZ
    p_O2 = p_O2
  [../]

  [./thermalTransportLSM]
    type = HeatConduction
    block = 'phase2'
    variable = T
    diffusion_coefficient = 'k_LSM' # (W/K/cm)
  [../]

  [./thermalTransportYSZ]
    type = HeatConduction
    block = 'phase3 phase4'
    variable = T
    diffusion_coefficient = 'k_YSZ' # (W/K/cm)
  [../]

  # [./jouleHeatingYSZ]
  #   type = JouleHeatingConstMaterial
  #   block = 'phase3 phase4'
  #   variable = T
  #   elec = phi_YSZ
  #   conductivity = 'sigma_YSZ' # (S/cm)
  # [../]

  [./tpbHeating]
    type = OverpotentialHeatingTPB
    block = 'phase4'
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
    function_phi_LSM = 'funcPotentialLSM'
  [../]
[]

#==========================================================================#

[BCs]
  [./oxygenPartialPressure_top]
    type = DirichletBC
    variable = p_O2
    boundary = 'phase1_top'
    value = 0.21 # (atm)
  [../]

  [./potentialYSZ_bottom]
    type = DirichletBC
    variable = phi_YSZ
    boundary = 'phase3_bottom'
    value = 0.00000 # (V)
  [../]

  [./temperature_top]
    type = DirichletBC
    variable = T
    boundary = 'phase2_top phase3_top'
    value = 1073.0 # (K)
  [../]

  [./temperature_bottom]
    type = DirichletBC
    variable = T
    boundary = 'phase2_bottom phase3_bottom'
    value = 1073.0 # (K)
  [../]
[]

#==========================================================================#

[AuxVariables]
  [./aux_pO2_LSM]
    block = 'phase2 phase4'
  [../]

  [./aux_Erev_LSM]
    block = 'phase2 phase4'
  [../]
[]

[AuxKernels]
  [./pO2_LSM]
    type = ParsedAux
    variable = aux_pO2_LSM
    block = 'phase2 phase4'
    function = '10^(-2.173913*log10(V_O) - 17.173913)'
    args = 'V_O'
  [../]

  [./Erev_LSM]
    type = ParsedAux
    variable = aux_Erev_LSM
    block = 'phase2 phase4'
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
    boundary = 'phase3_bottom'
    outputs = 'console csv'
  [../]

  [./j_YSZ_bottom]
    type = SideFluxAverage
    variable = phi_YSZ
    diffusivity = 'sigma_YSZ'
    boundary = 'phase3_bottom'
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
  type = Transient
  start_time = 0.0
  end_time = 1.0
  dtmin = 1e-5
  nl_rel_tol = 1e-20
  nl_rel_step_tol = 1e-14
  # nl_abs_tol = 1e-10
  # l_tol = 1e-04
  # l_abs_step_tol = -1
  l_max_its = 1000

  [./TimeStepper]
    type = FunctionDT
    function = funcTimeStepper
  [../]

  solve_type = 'NEWTON'
  #petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  #petsc_options_value = 'hypre boomeramg 50'
  petsc_options_iname = '-ksp_gmres_restart -pc_type'
  petsc_options_value = '101 bjacobi'
[]

#==========================================================================#

[Outputs]
  exodus = true
  csv = true
  file_base = outputs/toy/cyl-cat-23PB
  append_date = true
  append_date_format = '%Y-%m-%d'
  #print_perf_log = true
[]

[Debug]
  show_var_residual_norms = true
[]
