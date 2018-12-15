#include "CoupledTPBPotentialYSZ.h"
#include <cmath>

registerMooseObject("ermineApp", CoupledTPBPotentialYSZ);


template<>
InputParameters validParams<CoupledTPBPotentialYSZ>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription("Fully Coupled TPB reaction source kernel in Butler-Volmer sinh() form for potential in YSZ. j = 2 * j0 * sinh(coef * eta)");
  params.addRequiredParam<Real>("s0", "Exchange volumetric current density rate (A/cm^3)");
  params.addParam<Real>("z", 4.0, "electron number (num of electrons transferred)");
  params.addParam<Real>("F", 96485.33289, "Faraday constant (C/mol)");
  params.addParam<Real>("R", 8.3144598, "Gas constant (J/K/mol)");
  params.addParam<Real>("T", 1073.0, "Temperature (T)");
  params.addRequiredParam<Real>("phi_LSM", "Potential in LSM (V)");
  params.addRequiredParam<Real>("pO2_CE", "Oxygen partial pressure at the counter electrode (atm)");
  params.addRequiredCoupledVar("p_O2", "The coupled oxygen partial pressure variable in pore");
  return params;
}

CoupledTPBPotentialYSZ::CoupledTPBPotentialYSZ(const InputParameters & parameters) :
    Kernel(parameters),
    _s0(getParam<Real>("s0")),
    _z(getParam<Real>("z")),
    _F(getParam<Real>("F")),
    _R(getParam<Real>("R")),
    _T(getParam<Real>("T")),
    _phi_LSM(getParam<Real>("phi_LSM")),
    _pO2_CE(getParam<Real>("pO2_CE")),
    _num_p_O2(coupled("p_O2")),
    _p_O2(coupledValue("p_O2"))
{
}

Real
CoupledTPBPotentialYSZ::computeQpResidual()
{
  Real b    = _z * _F / _R / _T;
  Real E_conc = - _R * _T / _z / _F * log(_pO2_CE / _p_O2[_qp]);
  Real eta  = E_conc - (_phi_LSM - _u[_qp]);

  Real res  = 2 * _s0 * sinh(0.5 * b * eta);

  return res * _test[_i][_qp];
}

Real
CoupledTPBPotentialYSZ::computeQpJacobian()
{
  Real b    = _z * _F / _R / _T;
  Real E_conc = - _R * _T / _z / _F * log(_pO2_CE / _p_O2[_qp]);
  Real eta  = E_conc - (_phi_LSM - _u[_qp]);

  Real jac  = b * _s0 * cosh(0.5 * b * eta);

  return jac * _test[_i][_qp] * _phi[_j][_qp];
}

Real
CoupledTPBPotentialYSZ::computeQpOffDiagJacobian(unsigned int jvar)
{
  Real b    = _z * _F / _R / _T;
  Real E_conc = - _R * _T / _z / _F * log(_pO2_CE / _p_O2[_qp]);
  Real eta  = E_conc - (_phi_LSM - _u[_qp]);

  Real jac  = _s0 * cosh(0.5 * b * eta) / _p_O2[_qp];

  if (jvar == _num_p_O2)
    return jac * _test[_i][_qp] * _phi[_j][_qp];
  else return 0.0;
}
