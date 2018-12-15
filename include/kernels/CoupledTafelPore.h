#ifndef COUPLEDTAFELPORE_H
#define COUPLEDTAFELPORE_H

#include "Kernel.h"

// Forward Declaration
class CoupledTafelPore;

template<>
InputParameters validParams<CoupledTafelPore>();

/**
 * Coupled Tafel source for oxygen concentration in pore.
 */

class CoupledTafelPore : public Kernel
{
public:
  CoupledTafelPore(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

private:
  Real _j0;       // exchange (equilibrium) current density
  Real _alpha;
  Real _z;
  Real _F;
  Real _cO2_ref;
  Real _R;
  Real _T;
  Real _E_rev;    // reversible voltage (V)
  Real _phi_LSM;

  unsigned int _num_phi_YSZ;
  const VariableValue & _phi_YSZ;
};

#endif //COUPLEDTAFELPORE_H
