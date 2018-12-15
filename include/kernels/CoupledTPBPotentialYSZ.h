#ifndef COUPLEDTPBPOTENTIALYSZ_H
#define COUPLEDTPBPOTENTIALYSZ_H

#include "Kernel.h"

// Forward Declaration
class CoupledTPBPotentialYSZ;

template<>
InputParameters validParams<CoupledTPBPotentialYSZ>();

/**
 * Coupled Butler-Volmer TPB kernel in sinh() form for potential in YSZ.
 */

class CoupledTPBPotentialYSZ : public Kernel
{
public:
  CoupledTPBPotentialYSZ(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

private:
  const Real _s0;       // exchange (equilibrium) current rate
  const Real _z;
  const Real _F;
  const Real _R;
  const Real _T;
  const Real _phi_LSM;
  const Real _pO2_CE;

  unsigned int _num_p_O2;
  const VariableValue & _p_O2;
};

#endif //COUPLEDTPBPOTENTIALYSZ_H
