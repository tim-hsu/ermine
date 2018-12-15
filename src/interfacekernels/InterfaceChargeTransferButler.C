#include "InterfaceChargeTransferButler.h"
#include <cmath>

registerMooseObject("ermineApp", InterfaceChargeTransferButler);


template<>
InputParameters validParams<InterfaceChargeTransferButler>()
{
  InputParameters params = validParams<InterfaceKernel>();
  params.addClassDescription("InterfaceKernel that sets the molecular flux of oxygen in LSM as J = 2 * j0 / zF * sinh(coef * eta_ct), where eta_ct = E_rev - (E_LSM - E_YSZ)");
  params.addRequiredParam<Real>("E_rev", "Reversible potential");
  params.addRequiredParam<Real>("phi_LSM", "Potential in LSM");
  params.addRequiredParam<Real>("j0", "Exchange current density w.r.t. charge trasnfer");
  params.addParam<Real>("R", 8.31446, "Gas constant");
  params.addParam<Real>("T", 1073, "Temperature");
  params.addParam<Real>("z", 4.0, "electron number (num of electrons transferred)");
  params.addParam<Real>("F", 96485.33, "Faraday constant (C/mol)");
  return params;
}

InterfaceChargeTransferButler::InterfaceChargeTransferButler(const InputParameters & parameters) :
    InterfaceKernel(parameters),
    _E_rev(getParam<Real>("E_rev")),
    _phi_LSM(getParam<Real>("phi_LSM")),
    _j0(getParam<Real>("j0")),
    _R(getParam<Real>("R")),
    _T(getParam<Real>("T")),
    _z(getParam<Real>("z")),
    _F(getParam<Real>("F"))
{
  if (!parameters.isParamValid("boundary"))
  {
    mooseError("In order to use the InterfaceChargeTransfer dgkernel, you must specify a boundary where it will live.");
  }
}

Real
InterfaceChargeTransferButler::computeQpResidual(Moose::DGResidualType type)
{

  Real b    = _z * _F / _R / _T;
  Real eta  = _E_rev - (_phi_LSM - _neighbor_value[_qp]);
  Real res  = 2 * _j0 * sinh(0.5 * b * eta) / _z / _F;

  switch (type)
  {
  case Moose::Element:
    res *= _test[_i][_qp];
    break;

  case Moose::Neighbor:
    res *= 0;
    break;
  }

  return res;
}

Real
InterfaceChargeTransferButler::computeQpJacobian(Moose::DGJacobianType type)
{
  Real b    = _z * _F / _R / _T;
  Real eta  = _E_rev - (_phi_LSM - _neighbor_value[_qp]);
  Real jac  = 0;

  switch (type)
  {

    case Moose::ElementNeighbor:
      jac += _test[_i][_qp] * _phi_neighbor[_j][_qp] * b * _j0 * cosh(0.5 * b * eta) / _z / _F;
      break;

    default:
      break;
  }

  return jac;
}
