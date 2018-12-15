#include "CoupledTPBOxygenPressurePore.h"
#include <cmath>

registerMooseObject("ermineApp", CoupledTPBOxygenPressurePore);


template<>
InputParameters validParams<CoupledTPBOxygenPressurePore>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription("Fully Coupled TPB reaction source kernel in sinh() form for oxygen concentration in pore. j = 2 * j0 * sinh(coef * eta)");
  params.addRequiredParam<Real>("s0", "Exchange volumetric current density rate (A/cm^3)");
  params.addParam<Real>("z", 4.0, "electron number (num of electrons transferred)");
  params.addParam<Real>("F", 96485.33289, "Faraday constant (C/mol)");
  params.addParam<Real>("R", 8.3144598, "Gas constant (J/K/mol)");
  params.addParam<Real>("T", 1073.0, "Temperature (T)");
  params.addRequiredParam<Real>("phi_LSM", "Potential in LSM (V)");
  params.addRequiredParam<Real>("pO2_CE", "Oxygen partial pressure at the counter electrode (atm)");
  params.addRequiredCoupledVar("phi_YSZ", "The coupled potential variable in eta = potential_rev - (phi_LSM - phi_YSZ)");
  return params;
}

CoupledTPBOxygenPressurePore::CoupledTPBOxygenPressurePore(const InputParameters & parameters) :
    Kernel(parameters),
    _s0(getParam<Real>("s0")),
    _z(getParam<Real>("z")),
    _F(getParam<Real>("F")),
    _R(getParam<Real>("R")),
    _T(getParam<Real>("T")),
    _phi_LSM(getParam<Real>("phi_LSM")),
    _pO2_CE(getParam<Real>("pO2_CE")),
    _num_phi_YSZ(coupled("phi_YSZ")),
    _phi_YSZ(coupledValue("phi_YSZ"))
{
}

Real
CoupledTPBOxygenPressurePore::computeQpResidual()
{
  Real b    = _z * _F / _R / _T;
  Real E_conc = - _R * _T / _z / _F * log(_pO2_CE / _u[_qp]);
  Real eta  = E_conc - (_phi_LSM - _phi_YSZ[_qp]);

  Real res  = 1e6 / _z / _F * 2 * _s0 * sinh(0.5 * b * eta);

  return  res * _test[_i][_qp];
}

Real
CoupledTPBOxygenPressurePore::computeQpJacobian()
{
  Real b    = _z * _F / _R / _T;
  Real E_conc = - _R * _T / _z / _F * log(_pO2_CE / _u[_qp]);
  Real eta  = E_conc - (_phi_LSM - _phi_YSZ[_qp]);

  Real jac  = 1e6 / _z / _F * _s0 * cosh(0.5 * b * eta) / _u[_qp];

  return jac * _test[_i][_qp] * _phi[_j][_qp];
}

Real
CoupledTPBOxygenPressurePore::computeQpOffDiagJacobian(unsigned int jvar)
{
  Real b    = _z * _F / _R / _T;
  Real E_conc = - _R * _T / _z / _F * log(_pO2_CE / _u[_qp]);
  Real eta  = E_conc - (_phi_LSM - _phi_YSZ[_qp]);

  Real jac  = 1e6 / _z / _F * b * _s0 * cosh(0.5 * b * eta);

  if (jvar == _num_phi_YSZ)
    return jac * _test[_i][_qp] * _phi[_j][_qp];
  else return 0.0;
}
