#include "InterfaceChargeTransferFullyCoupledQS.h"
#include "Function.h"
#include <cmath>

registerMooseObject("ermineApp", InterfaceChargeTransferFullyCoupledQS);


template<>
InputParameters validParams<InterfaceChargeTransferFullyCoupledQS>()
{
  InputParameters params = validParams<InterfaceKernel>();
  params.addClassDescription("InterfaceKernel that sets the charge transfer flux as j = 2 * j0 * sinh(0.5 * beta * eta_ct). Master block is phase2 (LSM)");
  params.addRequiredParam<Real>("j0", "Charge transfer exchange current density (A/cm^2)");
  params.addParam<Real>("z", 4.0, "electron number (num of electrons transferred)");
  params.addParam<Real>("F", 96485.33289, "Faraday constant (C/mol)");
  params.addParam<Real>("R", 8.3144598, "Gas constant (J/K/mol)");
  params.addParam<Real>("T", 1073.0, "Temperature (T)");
  params.addRequiredParam<FunctionName>("function_phi_LSM", "Function for the LSM potential");
  params.addRequiredParam<Real>("pO2_CE", "Oxygen Partial Pressure at the Counter Electrode (atm)");
  return params;
}

InterfaceChargeTransferFullyCoupledQS::InterfaceChargeTransferFullyCoupledQS(const InputParameters & parameters) :
    InterfaceKernel(parameters),
    _j0(getParam<Real>("j0")),
    _z(getParam<Real>("z")),
    _F(getParam<Real>("F")),
    _R(getParam<Real>("R")),
    _T(getParam<Real>("T")),
    _func_phi_LSM(getFunction("function_phi_LSM")),
    _pO2_CE(getParam<Real>("pO2_CE"))
{
  if (!parameters.isParamValid("boundary"))
  {
    mooseError("In order to use the InterfaceChargeTransfer dgkernel, you must specify a boundary where it will live.");
  }
}

Real
InterfaceChargeTransferFullyCoupledQS::computeQpResidual(Moose::DGResidualType type)
{
  Real b    = _z * _F / _R / _T;
  Real logV = log10(_u[_qp]);
  Real logP = -2.173913*logV - 17.173913;
  Real pO2  = pow(10.0,logP);
  Real E_conc = - _R * _T / _z / _F * log(_pO2_CE / pO2);
  Real phi_LSM = _func_phi_LSM.value(_t, _q_point[_qp]);
  Real eta_ct = E_conc - (phi_LSM - _neighbor_value[_qp]);

  Real res  = 2.0 * _j0 * sinh(0.5*b*eta_ct);

  switch (type)
  {
    case Moose::Element:
      res *= -1e6 / _z / _F * _test[_i][_qp];   // vacancy flux inwards of phase2 (master)
      break;

    case Moose::Neighbor:
      res *= _test_neighbor[_i][_qp];           // electric flux outwards of phase3 (paired)
      break;
  }

  return res;
}

Real
InterfaceChargeTransferFullyCoupledQS::computeQpJacobian(Moose::DGJacobianType type)
{
  Real b    = _z * _F / _R / _T;
  Real logV = log10(_u[_qp]);
  Real logP = -2.173913*logV - 17.173913;
  Real pO2  = pow(10.0,logP);
  Real E_conc = - _R * _T / _z / _F * log(_pO2_CE / pO2);
  Real phi_LSM = _func_phi_LSM.value(_t, _q_point[_qp]);
  Real eta_ct = E_conc - (phi_LSM - _neighbor_value[_qp]);

  Real logP_prime = -2.173913;

  Real jac = 0.0;

  switch (type)
  {
    case Moose::ElementElement:
      jac = _j0 * cosh(0.5*b*eta_ct) * logP_prime / _u[_qp]
            * -1e6 / _z / _F * _phi[_j][_qp] * _test[_i][_qp];
      break;

    case Moose::ElementNeighbor:
      jac = b * _j0 * cosh(0.5*b*eta_ct)
            * -1e6 / _z / _F * _phi_neighbor[_j][_qp] * _test[_i][_qp];
      break;

    case Moose::NeighborNeighbor:
      jac = b * _j0 * cosh(0.5*b*eta_ct)
            * _phi_neighbor[_j][_qp] * _test_neighbor[_i][_qp];
      break;

    case Moose::NeighborElement:
      jac = _j0 * cosh(0.5*b*eta_ct) * logP_prime / _u[_qp]
            * _phi[_j][_qp] * _test_neighbor[_i][_qp];
      break;
  }

  return jac;
}
