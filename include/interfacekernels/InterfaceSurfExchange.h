#ifndef INTERFACESURFEXCHANGE_H
#define INTERFACESURFEXCHANGE_H

#include "InterfaceKernel.h"

//Forward Declarations
class InterfaceSurfExchange;

template<>
InputParameters validParams<InterfaceSurfExchange>();

/**
 * DG kernel for surface exchange of oxygen across LSM/pore
 */
class InterfaceSurfExchange : public InterfaceKernel
{
public:
  InterfaceSurfExchange(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual(Moose::DGResidualType type);
  virtual Real computeQpJacobian(Moose::DGJacobianType type);

  Real _k;             // exchange coefficient
  Real _c_infinity;    // equilibrium concentration
};

#endif
