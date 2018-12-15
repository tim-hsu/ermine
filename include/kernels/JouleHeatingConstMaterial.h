#ifndef JOULEHEATINGCONSTMATERIAL_H
#define JOULEHEATINGCONSTMATERIAL_H

#include "Kernel.h"

// Forward Declarations
class JouleHeatingConstMaterial;

template <>
InputParameters validParams<JouleHeatingConstMaterial>();

/**
 * This kernel calculates the heat source term corresponding to joule heating,
 * Q = J * E = elec_cond * grad_phi * grad_phi, where phi is the electrical potenstial.
 */
class JouleHeatingConstMaterial : public Kernel
{
public:
  JouleHeatingConstMaterial(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

private:
  const VariableGradient & _grad_elec;
  const unsigned int _elec_var;

  const MaterialProperty<Real> & _elec_cond;
};

#endif // JOULEHEATINGCONSTMATERIAL_H
