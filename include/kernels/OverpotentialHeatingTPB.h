#ifndef OVERPOTENTIALHEATINGTPB_H
#define OVERPOTENTIALHEATINGTPB_H

#include "Kernel.h"

// Forward Declaration
class OverpotentialHeatingTPB;
class Function;

template<>
InputParameters validParams<OverpotentialHeatingTPB>();

/**
 * Overpotential heating at the TPBs
 */

class OverpotentialHeatingTPB : public Kernel
{
public:
  OverpotentialHeatingTPB(const InputParameters & parameters);

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
  Function & _func_phi_LSM;
  const Real _pO2_CE;

  unsigned int _num_p_O2;
  unsigned int _num_phi_YSZ;

  const VariableValue & _p_O2;
  const VariableValue & _phi_YSZ;
};

#endif //OVERPOTENTIALHEATINGTPB_H
