#include "CoupledNernstDrift.h"

registerMooseObject("ermineApp", CoupledNernstDrift);


template<>
InputParameters validParams<CoupledNernstDrift>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredParam<Real>("z", "Charge number");
  params.addParam<Real>("F", 96485, "Faraday constant (C/mol)");
  params.addParam<Real>("R", 8.314, "Gas constant (J/mol/K)");
  params.addParam<Real>("T", 1073, "Temperature (K)");
  params.addRequiredParam<Real>("D", "Diffusivity (cm^2/s)");
  params.addRequiredCoupledVar("coupled_variable", "The gradient of which (electric potential) is multiplied with the kernel");
  params.addClassDescription("This kernel applies the coupled drift term in general Nernst-Planck equation");
  return params;
}

CoupledNernstDrift::CoupledNernstDrift(const InputParameters & parameters) :
    Kernel(parameters),
    _z(getParam<Real>("z")),
    _F(getParam<Real>("F")),
    _R(getParam<Real>("R")),
    _T(getParam<Real>("T")),
    _D(getParam<Real>("D")),
    _num_coupled_var(coupled("coupled_variable")),
    _grad_coupled_var(coupledGradient("coupled_variable"))
{
}

Real
CoupledNernstDrift::computeQpResidual()
{
  return _z * _F / (_R * _T) * _D * _u[_qp] * _grad_coupled_var[_qp] * _grad_test[_i][_qp];
}

Real
CoupledNernstDrift::computeQpJacobian()
{
  return _z * _F / (_R * _T) * _D * _grad_coupled_var[_qp] * _grad_test[_i][_qp] * _phi[_j][_qp];
}

Real
CoupledNernstDrift::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _num_coupled_var)
    return _z * _F / (_R * _T) * _D * _u[_qp] * _grad_phi[_j][_qp] * _grad_test[_i][_qp];
  return 0.0;
}
