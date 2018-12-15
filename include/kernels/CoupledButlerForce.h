#ifndef COUPLEDBUTLERFORCE_H
#define COUPLEDBUTLERFORCE_H

#include "Kernel.h"

// Forward Declaration
class CoupledButlerForce;

template<>
InputParameters validParams<CoupledButlerForce>();

/**
 * Coupled Butler-Volmer kernel in sinh (empirical) form that acts on non-potential terms.
 */

class CoupledButlerForce : public Kernel
{
public:
  CoupledButlerForce(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

private:
  Real _r;    // exchange (equilibrium) reaction rate
  Real _F;    // Faraday constant (96485.33289 C/mol)
  Real _R;    // gas constant (8.3144598 J/mol/K)
  Real _T;    // temperature
  Real _Erev; // reversible voltage (V)
  Real _c;    // concentration/coefficent

  unsigned int _num_phi_lsm;
  unsigned int _num_phi_ysz;
  const VariableValue & _phi_lsm;
  const VariableValue & _phi_ysz;
};

#endif //COUPLEDBUTLERFORCE_H
