//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "ermineTestApp.h"
#include "ermineApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

template <>
InputParameters
validParams<ermineTestApp>()
{
  InputParameters params = validParams<ermineApp>();
  return params;
}

ermineTestApp::ermineTestApp(InputParameters parameters) : MooseApp(parameters)
{
  Moose::registerObjects(_factory);
  ModulesApp::registerObjects(_factory);
  ermineApp::registerObjectDepends(_factory);
  ermineApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  ModulesApp::associateSyntax(_syntax, _action_factory);
  ermineApp::associateSyntaxDepends(_syntax, _action_factory);
  ermineApp::associateSyntax(_syntax, _action_factory);

  Moose::registerExecFlags(_factory);
  ModulesApp::registerExecFlags(_factory);
  ermineApp::registerExecFlags(_factory);

  bool use_test_objs = getParam<bool>("allow_test_objects");
  if (use_test_objs)
  {
    ermineTestApp::registerObjects(_factory);
    ermineTestApp::associateSyntax(_syntax, _action_factory);
    ermineTestApp::registerExecFlags(_factory);
  }
}

ermineTestApp::~ermineTestApp() {}

void
ermineTestApp::registerApps()
{
  registerApp(ermineApp);
  registerApp(ermineTestApp);
}

void
ermineTestApp::registerObjects(Factory & /*factory*/)
{
  /* Uncomment Factory parameter and register your new test objects here! */
}

void
ermineTestApp::associateSyntax(Syntax & /*syntax*/, ActionFactory & /*action_factory*/)
{
  /* Uncomment Syntax and ActionFactory parameters and register your new test objects here! */
}

void
ermineTestApp::registerExecFlags(Factory & /*factory*/)
{
  /* Uncomment Factory parameter and register your new execute flags here! */
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
ermineTestApp__registerApps()
{
  ermineTestApp::registerApps();
}

// External entry point for dynamic object registration
extern "C" void
ermineTestApp__registerObjects(Factory & factory)
{
  ermineTestApp::registerObjects(factory);
}

// External entry point for dynamic syntax association
extern "C" void
ermineTestApp__associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
  ermineTestApp::associateSyntax(syntax, action_factory);
}

// External entry point for dynamic execute flag loading
extern "C" void
ermineTestApp__registerExecFlags(Factory & factory)
{
  ermineTestApp::registerExecFlags(factory);
}
