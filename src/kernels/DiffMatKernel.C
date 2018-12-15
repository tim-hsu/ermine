#include "DiffMatKernel.h"

registerMooseObject("ermineApp", DiffMatKernel);


template<>
InputParameters validParams<DiffMatKernel>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredParam<MaterialPropertyName>("diff_coef", "the name of the diffusion coefficient (material property)");
  return params;
}


DiffMatKernel::DiffMatKernel(const InputParameters & parameters) :
    Kernel(parameters),
    _diff_coef(getMaterialProperty<Real>("diff_coef"))
{
}

Real
DiffMatKernel::computeQpResidual()
{
  return _diff_coef[_qp] * _grad_test[_i][_qp] * _grad_u[_qp];
}

Real
DiffMatKernel::computeQpJacobian()
{
  return _diff_coef[_qp] * _grad_test[_i][_qp] * _grad_phi[_j][_qp];
}
