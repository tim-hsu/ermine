#include "InterfaceSurfExchange.h"
#include <cmath>

registerMooseObject("ermineApp", InterfaceSurfExchange);


template<>
InputParameters validParams<InterfaceSurfExchange>()
{
  InputParameters params = validParams<InterfaceKernel>();
  params.addClassDescription("InterfaceKernel that sets the flux of u as J = -k(neighbor_value_inf - neighbor_value)");
  params.addRequiredParam<Real>("k","Exchange coefficient");
  params.addRequiredParam<Real>("c_infinity","Final equilibrium concentration of _neighbor_value");
  return params;
}

InterfaceSurfExchange::InterfaceSurfExchange(const InputParameters & parameters) :
    InterfaceKernel(parameters),
    _k(getParam<Real>("k")),
    _c_infinity(getParam<Real>("c_infinity"))
{
  if (!parameters.isParamValid("boundary"))
  {
    mooseError("In order to use the InterfaceSurfExchange dgkernel, you must specify a boundary where it will live.");
  }
}

Real
InterfaceSurfExchange::computeQpResidual(Moose::DGResidualType type)
{
  Real r = _k * (_neighbor_value[_qp] - _c_infinity);

  switch (type)
  {
  case Moose::Element:
    r *= _test[_i][_qp];
    break;

  case Moose::Neighbor:
    r *= 0;
    break;
  }

  return r;
}

Real
InterfaceSurfExchange::computeQpJacobian(Moose::DGJacobianType type)
{
  Real jac = 0;

  switch (type)
  {

    case Moose::ElementNeighbor:
      jac += _k * _phi_neighbor[_j][_qp] * _test[_i][_qp];
      break;

    default:
      break;
  }

  return jac;
}
