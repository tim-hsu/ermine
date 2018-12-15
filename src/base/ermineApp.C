#include "ermineApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

template <>
InputParameters
validParams<ermineApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

ermineApp::ermineApp(InputParameters parameters) : MooseApp(parameters)
{
  Moose::registerObjects(_factory);
  ModulesApp::registerObjects(_factory);
  ermineApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  ModulesApp::associateSyntax(_syntax, _action_factory);
  ermineApp::associateSyntax(_syntax, _action_factory);

  Moose::registerExecFlags(_factory);
  ModulesApp::registerExecFlags(_factory);
  ermineApp::registerExecFlags(_factory);
}

ermineApp::~ermineApp() {}

void
ermineApp::registerApps()
{
  registerApp(ermineApp);
}

void
ermineApp::registerObjects(Factory & factory)
{
    Registry::registerObjectsTo(factory, {"ermineApp"});
}

void
ermineApp::associateSyntax(Syntax & /*syntax*/, ActionFactory & action_factory)
{
  Registry::registerActionsTo(action_factory, {"ermineApp"});

  /* Uncomment Syntax parameter and register your new production objects here! */
}

void
ermineApp::registerObjectDepends(Factory & /*factory*/)
{
}

void
ermineApp::associateSyntaxDepends(Syntax & /*syntax*/, ActionFactory & /*action_factory*/)
{
}

void
ermineApp::registerExecFlags(Factory & /*factory*/)
{
  /* Uncomment Factory parameter and register your new execution flags here! */
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
ermineApp__registerApps()
{
  ermineApp::registerApps();
}

extern "C" void
ermineApp__registerObjects(Factory & factory)
{
  ermineApp::registerObjects(factory);
}

extern "C" void
ermineApp__associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
  ermineApp::associateSyntax(syntax, action_factory);
}

extern "C" void
ermineApp__registerExecFlags(Factory & factory)
{
  ermineApp::registerExecFlags(factory);
}
