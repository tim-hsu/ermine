#ifndef DIFFMATKERNEL_H
#define DIFFMATKERNEL_H

#include "Kernel.h"
#include "MaterialProperty.h"

// Forward Declaration
class DiffMatKernel;

template<>
InputParameters validParams<DiffMatKernel>();


class DiffMatKernel : public Kernel
{
public:
  DiffMatKernel(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();

  const MaterialProperty<Real> & _diff_coef;
};
#endif //DIFFMATKERNEL_H
