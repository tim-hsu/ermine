#include "InterfaceSurfExchangeFullyCoupled.h"
#include <cmath>

registerMooseObject("ermineApp", InterfaceSurfExchangeFullyCoupled);


template<>
InputParameters validParams<InterfaceSurfExchangeFullyCoupled>()
{
  InputParameters params = validParams<InterfaceKernel>();
  params.addClassDescription("InterfaceKernel that sets the flux of u as J = k * (neighbor_value_inf - neighbor_value)");
  params.addRequiredParam<Real>("k","Exchange coefficient (cm/s)");
  params.addParam<Real>("R", 8.3144598, "Gas constant (J/K/mol)");
  params.addParam<Real>("T", 1073.0, "Temperature (T)");
  return params;
}

InterfaceSurfExchangeFullyCoupled::InterfaceSurfExchangeFullyCoupled(const InputParameters & parameters) :
    InterfaceKernel(parameters),
    _k(getParam<Real>("k")),
    _R(getParam<Real>("R")),
    _T(getParam<Real>("T"))
{
  if (!parameters.isParamValid("boundary"))
  {
    mooseError("In order to use the InterfaceSurfExchange dgkernel, you must specify a boundary where it will live.");
  }
}

Real
InterfaceSurfExchangeFullyCoupled::computeQpResidual(Moose::DGResidualType type)
{
  Real a    = 3.893e-8;   // LSM unit cell edge lenth (cm)
  Real NA   = 6.022e23;   // Avogadro number (1/mol)
  Real logP = log10(_u[_qp]);
  Real logV = -0.46*logP - 7.9;
  Real V_p  = pow(10.0,logV);

  Real res = 1e6 / pow(a,3.0) / NA * _k * (_neighbor_value[_qp] - V_p);

  switch (type)
  {
    case Moose::Element:
      res *= 0.5 * _test[_i][_qp];        // flux outwards of phase1
      break;

    case Moose::Neighbor:
      res *= _test_neighbor[_i][_qp];    // flux inwards into phase2
      break;
  }

  return res;
}

Real
InterfaceSurfExchangeFullyCoupled::computeQpJacobian(Moose::DGJacobianType type)
{
  Real a    = 3.893e-8;   // LSM unit cell edge lenth (cm)
  Real NA   = 6.022e23;   // Avogadro number (1/mol)
  Real logP = log10(_u[_qp]);
  Real logV = -0.46*logP - 7.9;

  Real logV_prime = -0.46;

  Real jac = 0.0;

  switch (type)
  {
    case Moose::ElementElement:
      jac = -1e6 / pow(a,3.0) / NA * _k * pow(10,logV) * logV_prime / _u[_qp]
            * 0.5 * _test[_i][_qp] * _phi[_j][_qp];

    case Moose::ElementNeighbor:
      jac = 1e6 / pow(a,3.0) / NA * _k
            * 0.5 * _test[_i][_qp] * _phi_neighbor[_j][_qp];
      break;

    case Moose::NeighborNeighbor:
      jac = 1e6 / pow(a,3.0) / NA * _k
            * _test_neighbor[_i][_qp] * _phi_neighbor[_j][_qp];
      break;

    case Moose::NeighborElement:
      jac = -1e6 / pow(a,3.0) / NA * _k * pow(10,logV) * logV_prime / _u[_qp]
            * _test_neighbor[_i][_qp] * _phi[_j][_qp];
      break;
  }

  return jac;
}
