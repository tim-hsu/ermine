#include "CoupledTafelYSZ.h"
#include <math.h>

registerMooseObject("ermineApp", CoupledTafelYSZ);


template<>
InputParameters validParams<CoupledTafelYSZ>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription("Coupled Tafel source kernel for potential in YSZ. j = j0 * c_O2 * exp(coef * eta)");
  params.addRequiredParam<Real>("j0", "Exchange (equilibrium) current density");
  params.addParam<Real>("alpha", 0.5, "charge transfer coefficient");
  params.addParam<Real>("F", 96485.33, "Faraday constant");
  params.addRequiredParam<Real>("cO2_ref", "Reference oxygen concentration");
  params.addParam<Real>("R", 8.31446, "Gas constant");
  params.addRequiredParam<Real>("T", "Temperature");
  params.addRequiredParam<Real>("E_rev", "Reversible Nernst potential of the reaction");
  params.addRequiredParam<Real>("phi_LSM", "Potential in LSM");
  params.addRequiredCoupledVar("c_O2", "The coupled oxygen concentraiton variable in pore");
  return params;
}

CoupledTafelYSZ::CoupledTafelYSZ(const InputParameters & parameters) :
    Kernel(parameters),
    _j0(getParam<Real>("j0")),
    _alpha(getParam<Real>("alpha")),
    _F(getParam<Real>("F")),
    _cO2_ref(getParam<Real>("cO2_ref")),
    _R(getParam<Real>("R")),
    _T(getParam<Real>("T")),
    _E_rev(getParam<Real>("E_rev")),
    _phi_LSM(getParam<Real>("phi_LSM")),
    _num_c_O2(coupled("c_O2")),
    _c_O2(coupledValue("c_O2"))
{
}

Real
CoupledTafelYSZ::computeQpResidual()
{
  Real coef = _alpha * _F / _R / _T;
  return _test[_i][_qp] * _j0 * _c_O2[_qp] / _cO2_ref * exp(coef * (_E_rev - (_phi_LSM - _u[_qp])));
}

Real
CoupledTafelYSZ::computeQpJacobian()
{
  Real coef = _alpha * _F / _R / _T;
  return _test[_i][_qp] * _j0 * _c_O2[_qp] / _cO2_ref * coef * exp(coef * (_E_rev - (_phi_LSM - _u[_qp]))) * _phi[_j][_qp];
}

Real
CoupledTafelYSZ::computeQpOffDiagJacobian(unsigned int jvar)
{
  Real coef = _alpha * _F / _R / _T;
  if (jvar == _num_c_O2)
    return _test[_i][_qp] * _j0 * _phi[_j][_qp] / _cO2_ref * exp(coef * (_E_rev - (_phi_LSM - _u[_qp])));
  else return 0.0;
}
