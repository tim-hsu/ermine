#ifndef COUPLEDTPBOXYGENPRESSUREPORE_H
#define COUPLEDTPBOXYGENPRESSUREPORE_H

#include "Kernel.h"

// Forward Declaration
class CoupledTPBOxygenPressurePore;

template<>
InputParameters validParams<CoupledTPBOxygenPressurePore>();

/**
 * Coupled Butler-Volmer kernel in sinh (empirical) form for oxygen concentration in pore.
 */

class CoupledTPBOxygenPressurePore : public Kernel
{
public:
  CoupledTPBOxygenPressurePore(const InputParameters & parameters);

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

  unsigned int _num_phi_YSZ;
  const VariableValue & _phi_YSZ;
};

#endif //COUPLEDTPBOXYGENPRESSUREPORE_H
