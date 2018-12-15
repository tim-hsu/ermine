#include "JouleHeatingConstMaterial.h"

registerMooseObject("ermineApp", JouleHeatingConstMaterial);

template <>
InputParameters
validParams<JouleHeatingConstMaterial>()
{
  InputParameters params = validParams<Kernel>();
  params.addCoupledVar("elec", "Electric potential for joule heating.");
  params.addRequiredParam<MaterialPropertyName>("conductivity", "Material property providing electrical/ionic conductivity of the material.");
  return params;
}

JouleHeatingConstMaterial::JouleHeatingConstMaterial(const InputParameters & parameters)
  : Kernel(parameters),
    _grad_elec(coupledGradient("elec")),
    _elec_var(coupled("elec")),
    _elec_cond(getMaterialProperty<Real>("conductivity"))
{
}

Real
JouleHeatingConstMaterial::computeQpResidual()
{
  return -_elec_cond[_qp] * _grad_elec[_qp] * _grad_elec[_qp] * _test[_i][_qp];
}

Real
JouleHeatingConstMaterial::computeQpJacobian()
{
  // return -_elec_cond[_qp] * _grad_elec[_qp] * _grad_elec[_qp] * _phi[_j][_qp] * _test[_i][_qp];
  return 0.0;
}

Real
JouleHeatingConstMaterial::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _elec_var)
    return -2 * _elec_cond[_qp] * _grad_elec[_qp] * _grad_phi[_j][_qp] * _test[_i][_qp];
  else return 0.0;
}
