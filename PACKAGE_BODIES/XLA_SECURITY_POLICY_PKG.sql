--------------------------------------------------------
--  DDL for Package Body XLA_SECURITY_POLICY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_SECURITY_POLICY_PKG" AS
-- $Header: xlacmpol.pkb 120.5 2005/11/10 20:13:35 weshen ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlacmpol.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_security_policy_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|    Security policy package that contains standard XLA security policy      |
|    attatched to the events                                                 |
|                                                                            |
| HISTORY                                                                    |
|    11-Feb-02  S. Singhania    Created from the package XLA_SECURITY_PKG    |
|    25-Aug-05  Shishir Joshi   Added MO_Policy.                             |
|    10-Nov-05  W. Shen         fix bug 4717192.                             |
|                                                                            |
+===========================================================================*/

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
--
--
--
--
-- Following are the public routines.
--
--    1.    xla_standard_policy
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================
--=============================================================================
--
--
--
--=============================================================================

-- Constants

C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_security_policy_pkg';


-- Global variables for debugging
g_log_level     PLS_INTEGER  :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_log_enabled   BOOLEAN :=  fnd_log.test
                               (log_level  => g_log_level
                               ,module     => C_DEFAULT_MODULE);



/*===================================================================
print DEBUG messages

=====================================================================*/

PROCEDURE trace (p_msg          IN VARCHAR2
                ,p_level        IN NUMBER
                ,p_module       IN VARCHAR2) IS
BEGIN

   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_security_policy_pkg.trace');
END trace;


FUNCTION xla_standard_policy
       (p_obj_schema                 IN VARCHAR2
       ,p_obj_name                   IN VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
   RETURN '1 = 1';
END xla_standard_policy;


/*===================================================================

Derived MO Policy

=====================================================================*/


FUNCTION MO_Policy
       (p_obj_schema                 IN VARCHAR2
       ,p_obj_name                   IN VARCHAR2)
RETURN VARCHAR2 IS

  l_mo_policy   VARCHAR2(4000);
  l_log_module  VARCHAR2(240);
BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.MO_Policy';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('MO_Policy.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

  l_mo_policy := mo_global.org_security
     ( obj_schema => null
      ,obj_name   => null
     );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('l_mo_policy after calling  mo_global.org_security = ' || l_mo_policy,C_LEVEL_STATEMENT,l_log_module);
   END IF;

  l_mo_policy := REGEXP_REPLACE(l_mo_policy, 'org_id', 'security_id_int_1',1,1);

  -- Security identifiers are not populated. In case of, manual journal entires
  -- or third party merge events.
  -- bug 4717192, add the if condition
  IF(l_mo_policy is not null) THEN
    l_mo_policy := l_mo_policy || ' OR security_id_int_1 IS NULL ';
  END IF;

   xla_utility_pkg.print_logfile
      ('l_mo_policy after replace = ' || l_mo_policy);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('MO_Policy.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
   RETURN(l_mo_policy);
END MO_Policy;

END xla_security_policy_pkg;

/
