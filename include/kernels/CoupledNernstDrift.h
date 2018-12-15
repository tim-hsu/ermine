#ifndef COUPLEDNERNSTDRIFT_H
#define COUPLEDNERNSTDRIFT_H

#include "Kernel.h"
#include "Function.h"

//Forward Declarations
class CoupledNernstDrift;

// This kernel computes the drift term of Nernst-Planck equation
// The term is -zF/(RT)*D*c*grad(phi)



template<>
InputParameters validParams<CoupledNernstDrift>();

class CoupledNernstDrift : public Kernel
{
public:
  CoupledNernstDrift(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

private:
  const Real _z;  // charge number (-1 for electrons, +2 for oxygen vacancies)
  const Real _F;  // Faraday constant (coulumb/mol)
  const Real _R;  // gas constant (J/mol/K)
  const Real _T;  // temperature (K)
  const Real _D; // diffusivity (cm^2/s)

  unsigned int _num_coupled_var;
  const VariableGradient & _grad_coupled_var;
};

#endif //COUPLEDNERNSTDRIFT_H
