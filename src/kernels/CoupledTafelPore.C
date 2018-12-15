#include "CoupledTafelPore.h"
#include <math.h>

registerMooseObject("ermineApp", CoupledTafelPore);


template<>
InputParameters validParams<CoupledTafelPore>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription("Coupled Tafel source kernel for oxygen concentration in pore. j = j0 * c_O2 * exp(coef * eta)");
  params.addRequiredParam<Real>("j0", "Exchange (equilibrium) current density");
  params.addParam<Real>("alpha", 0.5, "charge transfer coefficient");
  params.addParam<Real>("z", 2, "Number of electrons involved in the reaction");
  params.addParam<Real>("F", 96485.33, "Faraday constant");
  params.addRequiredParam<Real>("cO2_ref", "Reference oxygen concentration");
  params.addParam<Real>("R", 8.31446, "Gas constant");
  params.addRequiredParam<Real>("T", "Temperature");
  params.addRequiredParam<Real>("E_rev", "Reversible Nernst potential of the reaction");
  params.addRequiredParam<Real>("phi_LSM", "Potential in LSM");
  params.addRequiredCoupledVar("phi_YSZ", "The coupled potential variable in eta = potential_rev - (phi_LSM - phi_YSZ)");
  return params;
}

CoupledTafelPore::CoupledTafelPore(const InputParameters & parameters) :
    Kernel(parameters),
    _j0(getParam<Real>("j0")),
    _alpha(getParam<Real>("alpha")),
    _z(getParam<Real>("z")),
    _F(getParam<Real>("F")),
    _cO2_ref(getParam<Real>("cO2_ref")),
    _R(getParam<Real>("R")),
    _T(getParam<Real>("T")),
    _E_rev(getParam<Real>("E_rev")),
    _phi_LSM(getParam<Real>("phi_LSM")),
    _num_phi_YSZ(coupled("phi_YSZ")),
    _phi_YSZ(coupledValue("phi_YSZ"))
{
}

Real
CoupledTafelPore::computeQpResidual()
{
  Real coef = _alpha * _F / _R / _T;
  // return _test[_i][_qp] * _j0 / _z / _F * pow(_u[_qp], 0.5) * exp(coef * (_E_rev - (_phi_LSM - _phi_YSZ[_qp])));
  return _test[_i][_qp] * _j0 / _z / _F * _u[_qp] / _cO2_ref * exp(coef * (_E_rev - (_phi_LSM - _phi_YSZ[_qp])));
}

Real
CoupledTafelPore::computeQpJacobian()
{
  Real coef = _alpha * _F / _R / _T;
  // return _test[_i][_qp] * _j0 / _z / _F * 0.5 * pow(_u[_qp], -0.5) * _phi[_j][_qp] * exp(coef * (_E_rev - (_phi_LSM - _phi_YSZ[_qp])));
  return _test[_i][_qp] * _j0 / _z / _F * _phi[_j][_qp] / _cO2_ref * exp(coef * (_E_rev - (_phi_LSM - _phi_YSZ[_qp])));
}

Real
CoupledTafelPore::computeQpOffDiagJacobian(unsigned int jvar)
{
  Real coef = _alpha * _F / _R / _T;
  if (jvar == _num_phi_YSZ)
    // return _test[_i][_qp] * _j0 / _z / _F * pow(_u[_qp], 0.5) * coef * exp(coef * (_E_rev - (_phi_LSM - _phi_YSZ[_qp]))) * _phi[_j][_qp];
    return _test[_i][_qp] * _j0 / _z / _F * _u[_qp] / _cO2_ref * coef * exp(coef * (_E_rev - (_phi_LSM - _phi_YSZ[_qp]))) * _phi[_j][_qp];
  else return 0.0;
}
