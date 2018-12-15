#include "OverpotentialHeatingTPB.h"
#include "Function.h"
#include <cmath>

registerMooseObject("ermineApp", OverpotentialHeatingTPB);


template<>
InputParameters validParams<OverpotentialHeatingTPB>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription("Overpotential heating at the TPBs."
  "In general, the heating rate is P = jV. In our context here, P = s_tpb * eta_act");
  params.addRequiredParam<Real>("s0", "Exchange volumetric current density rate (A/cm^3)");
  params.addParam<Real>("z", 4.0, "electron number (num of electrons transferred)");
  params.addParam<Real>("F", 96485.33289, "Faraday constant (C/mol)");
  params.addParam<Real>("R", 8.3144598, "Gas constant (J/K/mol)");
  params.addParam<Real>("T", 1073.0, "Temperature (T)");
  params.addRequiredParam<FunctionName>("function_phi_LSM", "Function for the LSM potential");
  params.addRequiredParam<Real>("pO2_CE", "Oxygen partial pressure at the counter electrode (atm)");
  params.addRequiredCoupledVar("p_O2", "The coupled oxygen partial pressure variable in pore");
  params.addRequiredCoupledVar("phi_YSZ", "The coupled potential in YSZ");
  return params;
}

OverpotentialHeatingTPB::OverpotentialHeatingTPB(const InputParameters & parameters) :
    Kernel(parameters),
    _s0(getParam<Real>("s0")),
    _z(getParam<Real>("z")),
    _F(getParam<Real>("F")),
    _R(getParam<Real>("R")),
    _T(getParam<Real>("T")),
    _func_phi_LSM(getFunction("function_phi_LSM")),
    _pO2_CE(getParam<Real>("pO2_CE")),
    _num_p_O2(coupled("p_O2")),
    _num_phi_YSZ(coupled("phi_YSZ")),
    _p_O2(coupledValue("p_O2")),
    _phi_YSZ(coupledValue("phi_YSZ"))
{
}

Real
OverpotentialHeatingTPB::computeQpResidual()
{
  Real b       = _z * _F / _R / _T;
  Real E_conc  = - _R * _T / 4 / _F * log(_pO2_CE / _p_O2[_qp]);
  Real phi_LSM = _func_phi_LSM.value(_t, _q_point[_qp]);
  Real eta     = E_conc - (phi_LSM - _phi_YSZ[_qp]);
  Real s       = 2 * _s0 * sinh(0.5 * b * eta);

  Real res     = s * eta;
  return -res * _test[_i][_qp];
}

Real
OverpotentialHeatingTPB::computeQpJacobian()
{
  return 0.0;
}

Real
OverpotentialHeatingTPB::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _num_p_O2)
  {
    Real b       = _z * _F / _R / _T;
    Real E_conc  = - _R * _T / 4 / _F * log(_pO2_CE / _p_O2[_qp]);
    Real phi_LSM = _func_phi_LSM.value(_t, _q_point[_qp]);
    Real eta     = E_conc - (phi_LSM - _phi_YSZ[_qp]);
    Real s       = 2 * _s0 * sinh(0.5 * b * eta);

    Real ds_deta = b * _s0 * cosh(0.5 * b * eta);
    Real deta_dE = 1;
    Real dE_dpO2 = _R * _T / 4 / _F / _p_O2[_qp];

    Real jac     = ds_deta * deta_dE * dE_dpO2 * eta + s * deta_dE * dE_dpO2;
    return -jac * _test[_i][_qp] * _phi[_j][_qp];
  }
  else if (jvar == _num_phi_YSZ)
  {
    Real b         = _z * _F / _R / _T;
    Real E_conc    = - _R * _T / 4 / _F * log(_pO2_CE / _p_O2[_qp]);
    Real phi_LSM   = _func_phi_LSM.value(_t, _q_point[_qp]);
    Real eta       = E_conc - (phi_LSM - _phi_YSZ[_qp]);
    Real s         = 2 * _s0 * sinh(0.5 * b * eta);

    Real ds_deta   = b * _s0 * cosh(0.5 * b * eta);
    Real deta_dphi = 1;

    Real jac       = ds_deta * deta_dphi * eta + s * deta_dphi;
    return -jac * _test[_i][_qp] * _phi[_j][_qp];
  }
  else return 0.0;
}
