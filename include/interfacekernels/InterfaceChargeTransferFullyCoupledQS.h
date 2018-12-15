#ifndef INTERFACECHARGETRANSFERFULLYCOUPLEDQS_H
#define INTERFACECHARGETRANSFERFULLYCOUPLEDQS_H

#include "InterfaceKernel.h"

//Forward Declarations
class InterfaceChargeTransferFullyCoupledQS;
class Function;

template<>
InputParameters validParams<InterfaceChargeTransferFullyCoupledQS>();

/**
 * DG kernel for charge trasnfer of oxygen ions/vacancies across LSM/YSZ interface
 */
class InterfaceChargeTransferFullyCoupledQS : public InterfaceKernel
{
public:
  InterfaceChargeTransferFullyCoupledQS(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual(Moose::DGResidualType type);
  virtual Real computeQpJacobian(Moose::DGJacobianType type);

  const Real _j0;
  const Real _z;
  const Real _F;
  const Real _R;
  const Real _T;
  Function & _func_phi_LSM;
  const Real _pO2_CE;
};

#endif
