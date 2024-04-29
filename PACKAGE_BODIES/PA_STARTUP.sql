--------------------------------------------------------
--  DDL for Package Body PA_STARTUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STARTUP" AS
/* $Header: PARSTUPB.pls 115.5 2002/03/12 00:44:16 pkm ship     $ */

-- ----------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--              Initialize
--  PURPOSE
--              This procedure should be called as part of initialization
--              Note: 1. p_calling_application parameter is always required
--                    2. This procedure would not initialize the error stack
--                       nor would set the error stack as this is an
--                       Initialization procedure.
--                    3. The input parameters for this procedure correspond
--                       to the Global Variables specified in this package
--                       Unless specified:
--                          p_debug_level  --> For Enabling Debug
--  HISTORY
--   19-Jul-2000      nchouhan  Created
-- ----------------------------------------------------------------------------
procedure Initialize (
  p_calling_application          IN  VARCHAR2,
  p_calling_module               IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  p_check_id_flag                IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  p_check_role_security_flag     IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  p_check_resource_Security_flag IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  p_debug_level                  IN  NUMBER   DEFAULT FND_API.G_MISS_NUM
                     ) IS
  l_calling_module               PA_STARTUP.G_Calling_Module%TYPE;
  l_check_id_flag                PA_STARTUP.G_Check_ID_Flag%TYPE;
  l_check_role_security_flag     PA_STARTUP.G_Check_Role_Security_Flag%TYPE;
  l_check_resource_security_flag PA_STARTUP.G_Check_Resource_Security_Flag%TYPE;
  l_debug_level                  PA_DEBUG.debug_level%TYPE;

BEGIN
  -- Set global variable for calling application as this is a required
  -- parameter required for this procedure.
  PA_STARTUP.G_Calling_Application  := p_calling_application;

  l_calling_module                  := p_calling_module;
  l_check_id_flag                   := p_check_id_flag;
  l_check_role_security_flag        := p_check_role_security_flag;
  l_check_resource_security_flag    := p_check_resource_security_flag;
  l_debug_level                     := p_debug_level;

  IF PA_STARTUP.G_Calling_Application = 'SELF_SERVICE' THEN
    -- Calling Application is Self Service

    -- Set Check ID Flag if not passed
    IF l_check_id_flag = FND_API.G_MISS_CHAR THEN
      l_check_id_flag := 'N';
    END IF;

    -- Set Check project role security Flag if not passed
    IF l_check_role_security_flag = FND_API.G_MISS_CHAR THEN
      l_check_role_security_flag := 'N';
    END IF;

    -- Set Check resource security Flag if not passed
    IF l_check_resource_security_flag = FND_API.G_MISS_CHAR THEN
      l_check_resource_security_flag := 'N';
    END IF;

    -- Set Check ID Flag if not passed
    IF l_check_id_flag = FND_API.G_MISS_CHAR THEN
      l_check_id_flag := 'N';
    END IF;

  ELSIF PA_STARTUP.G_Calling_Application = 'FORMS' THEN
    -- Calling Application is Oracle Forms
    null;

  ELSIF PA_STARTUP.G_Calling_application = 'REPORTS' THEN
    -- Calling Application is Oracle Reports
    null;

  ELSIF PA_STARTUP.G_Calling_Application = 'PLSQL' THEN
    -- Calling Application is PLSQL
    null;

  ELSE
    null;

  END IF;

  -- set global variables if input parameter passed or if value changed in the
  -- above logic. If no input parameter passed or value changed then the Global
  -- variable gets defaulted to its default value
  IF l_calling_module <> FND_API.G_MISS_CHAR THEN
    PA_STARTUP.G_Calling_Module := l_calling_module;
  END IF;

  IF l_check_id_flag <> FND_API.G_MISS_CHAR THEN
    PA_STARTUP.G_Check_ID_Flag := l_check_id_flag;
  END IF;

  IF l_check_role_security_flag <> FND_API.G_MISS_CHAR THEN
    PA_STARTUP.G_Check_Role_Security_Flag := l_check_role_security_flag;
  END IF;

  IF l_check_resource_security_flag <> FND_API.G_MISS_CHAR THEN
    PA_STARTUP.G_Check_Resource_Security_Flag := l_check_resource_security_flag;
  END IF;

  IF l_debug_level <> FND_API.G_MISS_NUM THEN
    pa_debug.enable_debug(l_debug_level);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
       Raise;

END Initialize;

END PA_STARTUP ;

/
