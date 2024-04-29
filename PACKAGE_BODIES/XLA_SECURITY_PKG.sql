--------------------------------------------------------
--  DDL for Package Body XLA_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_SECURITY_PKG" AS
-- $Header: xlacmsec.pkb 120.24 2006/08/11 17:53:46 wychan ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlacmsec.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_security_pkg                                                        |
|                                                                            |
| DESCRIPTION                                                                |
|    XLA security package that contains code related to implementation of    |
|    'Transaction Security' on accounting events.                            |
|                                                                            |
| HISTORY                                                                    |
|    08-Feb-01  G. Gu           Created                                      |
|    10-Mar-01  P. Labrevois    Reviewed                                     |
|    08-Apr-02  S. Singhania    Removed the set_security_context API with the|
|                                change in security approach and added APIs  |
|                                'set_context' and 'set_product_security'.   |
|                                Changed the approach based on oracle 9i.    |
|    15-Nov-02  S. Singhania    Reworked on the package to make it a working |
|                               package.                                     |
|    27-Nov-02  S. Singhania    Made changes to 'set_subledger_security'.    |
|                                Added 'install_security' procedure          |
|    11-Feb-03  S. Singhania    Removed 'install_security' and               |
|                                'xla_security_policy' from this package.    |
|    19-Aug-03  S. Singhania    Renamed the profile option code for          |
|                                'SLA: Use Transaction Security'             |
|    02-Oct-03  S. Singhania    Implemented change in implementation arch.   |
|                                 (see bug # 3173884)                        |
|    28-Feb-04  S. Singhania    Bug 3416534. Added local trace procedure and |
|                                 added FND_LOG messages.                    |
|    23-Mar-04  S. Singhania    Added a parameter p_module to the TRACE calls|
|                                 and the procedure.                         |
+===========================================================================*/

--=============================================================================
--                       *********** Declarations **********
--=============================================================================
TYPE t_array_policy_name IS TABLE OF VARCHAR2(80);

--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_security_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
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
         (p_location   => 'xla_security_pkg.trace');
END trace;

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
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
-- Following are the routines on which "single event/entity" public APIs
-- are based.
--
--    1.    set_security_context
--    2.    set_subledger_security
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
-- Changes maded as described in bug # 3173884
--
-- IF the user responsibility is GL THEN
--  IF SLA: Use Transaction Security = "Yes" THEN
--     IF p_application.SECURITY_FUNCTION_NAME is NOT NULL THEN
--       Transaction security is enabled based on the <appl_short_name> group
--     END IF
--  ELSE
--   Transaction security is enabled based on the XLA group
--  END IF
-- ELSE
--  IF p_application.SECURITY_FUNCTION_NAME is NOT NULL THEN
--   Transaction security is enabled based on the <appl_short_name> group
--  ELSE
--   Transaction security is enabled based on the XLA group
--  END IF
-- END IF
--
-- bug 5438150: Added parameter p_always_do_mo_init_flag to allow mo_init to be
-- called regardless of the is_mo_init_done.  This is used when calling from OAF
-- page when is_mo_init_done incorrectly return 'Y' (due to cache/session-reuse)
-- even mo_init was not called from the current session.
--
--=============================================================================
PROCEDURE set_security_context
       (p_application_id             IN  NUMBER) IS
BEGIN
  set_security_context
          (p_application_id         => p_application_id
          ,p_always_do_mo_init_flag => 'N');
END;

PROCEDURE set_security_context
       (p_application_id             IN  NUMBER
       ,p_always_do_mo_init_flag     IN  VARCHAR2) IS
l_appl_short_name           VARCHAR2(30);
l_appl_name                 VARCHAR2(240);
l_security_group            VARCHAR2(30);
l_policy_function           VARCHAR2(80);

l_resp_appl_short_name      VARCHAR2(30);
l_use_trx_security          VARCHAR2(30);
l_log_module                VARCHAR2(240);
l_access_ctrl_enabled       varchar2(1);
l_mo_initialized            PLS_INTEGER;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.set_security_context';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure SET_SECURITY_CONTEXT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
   ----------------------------------------------------------------------------
   -- Check to see if application is a defined subledger
   ----------------------------------------------------------------------------


   -- Bypass the security if it's SLA.

   IF p_application_id <> 602 THEN
      BEGIN
       SELECT fap.application_short_name
             ,xsv.security_function_name
         INTO l_appl_short_name
             ,l_policy_function
         FROM xla_subledgers_fvl     xsv
             ,fnd_application        fap
        WHERE xsv.application_id = p_application_id
          AND fap.application_id = xsv.application_id;
      EXCEPTION
           WHEN NO_DATA_FOUND THEN
                xla_exceptions_pkg.raise_message
                   (p_appli_s_name   => 'XLA'
                   ,p_msg_name       => 'XLA_COMMON_ERROR'
                   ,p_token_1        => 'ERROR'
                   ,p_value_1        => 'Invalid Subledger Applcation. Application_ID = ' || p_application_id
                   );

     END;
   END IF;

   -- Bug 4628909
   -- Check if an application is MO enbaled.
   BEGIN
     SELECT nvl(mpi.status, 'N')
       INTO l_access_ctrl_enabled
       FROM fnd_mo_product_init mpi
      WHERE mpi.application_short_name = l_appl_short_name;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
         l_access_ctrl_enabled := 'N';
     WHEN OTHERS THEN
         l_access_ctrl_enabled := 'N';
   END;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_access_ctrl_enabled = ' || l_access_ctrl_enabled
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'MO_GLOBAL.is_mo_init_done = ' || MO_GLOBAL.is_mo_init_done
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   -- Call MO_Global if an application is MO enabled and MO is not initialized.
   IF nvl(l_access_ctrl_enabled,'N') = 'Y' AND
      (p_always_do_mo_init_flag = 'Y' OR MO_GLOBAL.is_mo_init_done = 'N')
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
         (p_msg      => 'calling MO_GLOBAL.init '
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      END IF;

      mo_global.init(l_appl_short_name);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'after calling MO_GLOBAL.init '
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

   END IF;


   l_resp_appl_short_name := fnd_profile.value('RESP_APPL_SHORT_NAME');
   l_use_trx_security     := fnd_profile.value('XLA_USE_TRANSACTION_SECURITY');

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_appl_short_name = '||l_appl_short_name
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'l_policy_function = '||l_policy_function
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'l_resp_appl_short_name = '||l_resp_appl_short_name
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'l_use_trx_security = '||l_use_trx_security
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- If the calling responsibility is a GL responsibility then the transaction
   -- security for the application is enabled only if the profile option
   -- 'XLA_USE_TRANSACTION_SECURITY' is set to 'Yes'. If this value is 'No',
   -- the standard 'XLA' security group is enabled for that session.
   -- But if the calling responsibility belongs to any other application,
   -- transaction security is enabled for the application (passed in as the
   -- parameter).
   ----------------------------------------------------------------------------
   IF l_resp_appl_short_name = 'SQLGL' THEN
      IF l_use_trx_security = 'Y' THEN
         IF l_policy_function IS NOT NULL THEN
            l_security_group := l_appl_short_name;
         END IF;
      ELSE
         l_security_group := 'XLA';
      END IF;
   ELSE
      IF l_policy_function IS NOT NULL THEN
         l_security_group := l_appl_short_name;
      ELSE
         l_security_group := 'XLA';
      END IF;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_security_group = '||l_security_group
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Call the package that is responsible for setting the application contexts
   ----------------------------------------------------------------------------
   xla_context_pkg.set_security_context
      (p_security_group         => l_security_group);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure SET_SECURITY_CONTEXT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN NO_DATA_FOUND THEN
   ----------------------------------------------------------------------------
   -- Get more information about the application to make the error message
   -- more clear to the user.
   ----------------------------------------------------------------------------
   BEGIN
      SELECT fav.application_name
        INTO l_appl_name
        FROM fnd_application_vl        fav
       WHERE fav.application_id = p_application_id;

      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'xla_security_pkgset_security_context'
         ,p_token_2       => 'APPLICATION_NAME'
         ,p_value_2       => l_appl_name);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'xla_security_pkgset_security_context'
         ,p_token_2       => 'APPLICATION_ID'
         ,p_value_2       => TO_CHAR(p_application_id));
   END;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_security_pkgset_security_context');
END set_security_context;


--=============================================================================
--
-- Changes maded as described in bug # 3173884
--
-- IF xla_subledgers.SECURITY_FUNCTION_NAME is null
-- THEN
--   do nothing
-- ELSE
--  a policy group <appl_short_name> is created
--  and SECURITY_FUNCTION_NAME security policy is attached to this group
-- END IF.
--
--=============================================================================
PROCEDURE set_subledger_security
       (p_application_id             IN NUMBER
       ,p_security_function_name     IN VARCHAR2) IS
l_appl_short_name           VARCHAR2(30);
l_object_owner              VARCHAR2(30);
l_group_count               NUMBER;
l_object_name               VARCHAR2(30):='XLA_TRANSACTION_ENTITIES';
l_array_policy_name         t_array_policy_name;
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.set_subledger_security';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure SET_SUBLEDGER_SECURITY'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_function_name = '||p_security_function_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   SELECT fap.application_short_name, USER
    INTO l_appl_short_name, l_object_owner
    FROM fnd_application    fap
   WHERE fap.application_id = p_application_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_appl_short_name = '||l_appl_short_name
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   SELECT COUNT(policy_group)
     INTO l_group_count
     FROM dba_policy_groups
    WHERE object_owner = l_object_owner
      AND object_name  = l_object_name
      AND policy_group = l_appl_short_name;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_group_count = '||l_group_count
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF p_security_function_name IS NULL THEN
      IF l_group_count = 0 THEN
         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'Doing nothing'
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;
         -- Do Nothing
         NULL;
      ELSE
         SELECT policy_name BULK COLLECT
           INTO l_array_policy_name
           FROM dba_policies
          WHERE object_owner = l_object_owner
            AND object_name  = l_object_name
            AND policy_group = l_appl_short_name;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'Number of policies found = '||l_array_policy_name.COUNT
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;

         FOR i IN 1 .. l_array_policy_name.COUNT LOOP
            IF (C_LEVEL_EVENT >= g_log_level) THEN
               trace
                  (p_msg      => 'Dropping policy  = '||l_array_policy_name(i)
                  ,p_level    => C_LEVEL_EVENT
                  ,p_module   => l_log_module);
            END IF;

            dbms_rls.drop_grouped_policy
               (object_schema         => l_object_owner
               ,object_name           => l_object_name
               ,policy_group          => l_appl_short_name
               ,policy_name           => l_array_policy_name(i));
         END LOOP;

         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'Dropping policy group = '||l_appl_short_name
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;

         dbms_rls.delete_policy_group
            (object_schema         => l_object_owner
            ,object_name           => l_object_name
            ,policy_group          => l_appl_short_name);
      END IF;
   ELSE
      IF l_group_count = 0 THEN
         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'Creating policy group = '||l_appl_short_name
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;

         dbms_rls.create_policy_group
            (object_schema         => l_object_owner
            ,object_name           => l_object_name
            ,policy_group          => l_appl_short_name);
      ELSE
         SELECT policy_name BULK COLLECT
           INTO l_array_policy_name
           FROM dba_policies
          WHERE object_owner = l_object_owner
            AND object_name  = l_object_name
            AND policy_group = l_appl_short_name;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'Number of policies found = '||l_array_policy_name.COUNT
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;

         FOR i IN 1 .. l_array_policy_name.COUNT LOOP
            IF (C_LEVEL_EVENT >= g_log_level) THEN
               trace
                  (p_msg      => 'Dropping policy  = '||l_array_policy_name(i)
                  ,p_level    => C_LEVEL_EVENT
                  ,p_module   => l_log_module);
            END IF;

            dbms_rls.drop_grouped_policy
               (object_schema         => l_object_owner
               ,object_name           => 'XLA_TRANSACTION_ENTITIES'
               ,policy_group          => l_appl_short_name
               ,policy_name           => l_array_policy_name(i));
         END LOOP;
      END IF;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Creating policy = '||l_appl_short_name||'_SECURITY_POLICY'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      dbms_rls.add_grouped_policy
         (object_schema         => l_object_owner
         ,object_name           => 'XLA_TRANSACTION_ENTITIES'
         ,policy_group          => l_appl_short_name
         ,policy_name           => l_appl_short_name||'_SECURITY_POLICY'
         ,policy_type           => dbms_rls.SHARED_CONTEXT_SENSITIVE
         ,function_schema       => l_object_owner
         ,policy_function       => p_security_function_name
         ,statement_types       => 'UPDATE, SELECT, DELETE'
         ,update_check          => FALSE
         ,enable                => TRUE);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure SET_SUBLEDGER_SECURITY'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN NO_DATA_FOUND THEN
   xla_exceptions_pkg.raise_message
      (p_appli_s_name  => 'XLA'
      ,p_msg_name      => 'XLA_COMMON_ERROR'
      ,p_token_1       => 'LOCATION'
      ,p_value_1       => 'xla_security_pkgset_subledger_security'
      ,p_token_2       => 'APPLICATION_ID'
      ,p_value_2       => TO_CHAR(p_application_id));
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_security_pkgset_subledger_security');
END set_subledger_security;


--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

--=============================================================================
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
-- Following code is executed when the package body is referenced for the first
-- time
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

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_security_pkg;

/
