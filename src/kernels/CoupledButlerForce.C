#include "CoupledButlerForce.h"
#include "math.h"

registerMooseObject("ermineApp", CoupledButlerForce);


template<>
InputParameters validParams<CoupledButlerForce>()
{
  InputParameters params = validParams<Kernel>();
  params.addParam<Real>("r", 1, "Exchange (equilibrium) reaction rate (conc/time)");
  params.addParam<Real>("F", 96485.3328959, "Faraday constant (C/mol)");
  params.addParam<Real>("R", 8.314459848, "Gas constant (J/mol/K)");
  params.addParam<Real>("T", 298, "Temperature (K)");
  params.addParam<Real>("E_rev", 1.2, "Reversible voltage (V)");
  params.addParam<Real>("c", 1.0, "The reactant concentration, or coefficent in 2 * r * c * sinh(b * eta)");
  params.addRequiredCoupledVar("phi_lsm", "The coupled potential variable in eta = E_rev - (phi_LSM - phi_YSZ)");
  params.addRequiredCoupledVar("phi_ysz", "The coupled potential variable in eta = E_rev - (phi_LSM - phi_YSZ)");
  params.addClassDescription("Coupled Butler-Volmer kernel in sinh (empirical) form for non-potential terms");
  return params;
}

CoupledButlerForce::CoupledButlerForce(const InputParameters & parameters) :
    Kernel(parameters),
    _r(getParam<Real>("r")),
    _F(getParam<Real>("F")),
    _R(getParam<Real>("R")),
    _T(getParam<Real>("T")),
    _Erev(getParam<Real>("E_rev")),
    _c(getParam<Real>("c")),
    _num_phi_lsm(coupled("phi_lsm")),
    _num_phi_ysz(coupled("phi_ysz")),
    _phi_lsm(coupledValue("phi_lsm")),
    _phi_ysz(coupledValue("phi_ysz"))
{
}

Real
CoupledButlerForce::computeQpResidual()
{
  Real b = 0.5 * _F / _R / _T;
  return _test[_i][_qp] * 2 * _r * _c * sinh(b * (_Erev - (_phi_lsm[_qp] - _phi_ysz[_qp])));
}

Real
CoupledButlerForce::computeQpJacobian()
{
  return 0.0;
}

Real
CoupledButlerForce::computeQpOffDiagJacobian(unsigned int jvar)
{
  Real b = 0.5 * _F / _R / _T;
  if (jvar == _num_phi_lsm)
    return _test[_i][_qp] * -2 * _r * _c * b * cosh(b * (_Erev - (_phi_lsm[_qp] - _phi_ysz[_qp]))) * _phi[_j][_qp];
  if (jvar == _num_phi_ysz)
    return _test[_i][_qp] * 2 * _r * _c * b * cosh(b * (_Erev - (_phi_lsm[_qp] - _phi_ysz[_qp]))) * _phi[_j][_qp];
  else return 0.0;
}
