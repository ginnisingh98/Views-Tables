--------------------------------------------------------
--  DDL for Package Body XLA_ANALYTICAL_HDRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ANALYTICAL_HDRS_PKG" AS
/* $Header: xlaamanc.pkb 120.8 2005/04/28 18:42:31 masada ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_analytical_hdrs_pkg                                            |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Analytical Criteria Package                                    |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|    22-Oct-04 Wynne Chan     Changes for Journal Lines Definition      |
|                                                                       |
+======================================================================*/

TYPE t_array_codes         IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_array_type_codes    IS TABLE OF VARCHAR2(1)  INDEX BY BINARY_INTEGER;
TYPE t_array_int           IS TABLE OF INTEGER      INDEX BY BINARY_INTEGER;


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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_analytical_hdrs_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS
BEGIN
  ----------------------------------------------------------------------------
  -- Following is for FND log.
  ----------------------------------------------------------------------------
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
      (p_location   => 'xla_analytical_hdrs_pkg.trace');
END trace;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Returns true if all the product rules are uncompiled for this         |
| analytical criteria                                                   |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_amb_context_code                 IN VARCHAR2
  ,p_analytical_criterion_code        IN VARCHAR2
  ,p_anal_criterion_type_code         IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                  IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag              IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

  l_return   BOOLEAN := TRUE;

  l_application_name     varchar2(240) := null;
  l_product_rule_name    varchar2(80)  := null;
  l_product_rule_type    varchar2(80)  := null;
  l_event_class_name     varchar2(80)  := null;
  l_event_type_name      varchar2(80)  := null;
  l_locking_status_flag  varchar2(1)   := null;

  CURSOR c_lock_line_aads IS
    SELECT xpa.application_id
         , xpa.entity_code
         , xpa.event_class_code
         , xpa.event_type_code
         , xpa.product_rule_type_code
         , xpa.product_rule_code
         , xpa.locking_status_flag
         , xpa.validation_status_code
      FROM xla_line_defn_ac_assgns  xld
          ,xla_aad_line_defn_assgns xal
          ,xla_prod_acct_headers    xpa
     WHERE xpa.application_id                 = xal.application_id
       AND xpa.amb_context_code               = xal.amb_context_code
       AND xpa.product_rule_type_code         = xal.product_rule_type_code
       AND xpa.product_rule_code              = xal.product_rule_code
       AND xpa.event_class_code               = xal.event_class_code
       AND xpa.event_type_code                = xal.event_type_code
       AND xal.application_id                 = xld.application_id
       AND xal.amb_context_code               = xld.amb_context_code
       AND xal.event_class_code               = xld.event_class_code
       AND xal.event_type_code                = xld.event_type_code
       AND xal.line_definition_owner_code     = xld.line_definition_owner_code
       AND xal.line_definition_code           = xld.line_definition_code
       AND xld.amb_context_code               = p_amb_context_code
       AND xld.analytical_criterion_type_code = p_anal_criterion_type_code
       AND xld.analytical_criterion_code      = p_analytical_criterion_code
     FOR UPDATE NOWAIT;

   CURSOR c_lock_header_aads IS
    SELECT xpa.application_id
         , xpa.entity_code
         , xpa.event_class_code
         , xpa.event_type_code
         , xpa.product_rule_type_code
         , xpa.product_rule_code
         , xpa.locking_status_flag
         , xpa.validation_status_code
      FROM xla_aad_header_ac_assgns xah
          ,xla_prod_acct_headers    xpa
     WHERE xpa.application_id                 = xah.application_id
       AND xpa.amb_context_code               = xah.amb_context_code
       AND xpa.product_rule_type_code         = xah.product_rule_type_code
       AND xpa.product_rule_code              = xah.product_rule_code
       AND xpa.event_class_code               = xah.event_class_code
       AND xpa.event_type_code                = xah.event_type_code
       AND xah.amb_context_code               = p_amb_context_code
       AND xah.analytical_criterion_type_code = p_anal_criterion_type_code
       AND xah.analytical_criterion_code      = p_analytical_criterion_code
     FOR UPDATE NOWAIT;

   CURSOR c_update_aads IS
    SELECT xpa.application_id, xpa.event_class_code,
           xpa.product_rule_type_code, xpa.product_rule_code
      FROM xla_aad_header_ac_assgns xah
          ,xla_prod_acct_headers    xpa
     WHERE xpa.application_id                 = xah.application_id
       AND xpa.amb_context_code               = xah.amb_context_code
       AND xpa.product_rule_type_code         = xah.product_rule_type_code
       AND xpa.product_rule_code              = xah.product_rule_code
       AND xpa.event_class_code               = xah.event_class_code
       AND xpa.event_type_code                = xah.event_type_code
       AND xah.amb_context_code               = p_amb_context_code
       AND xah.analytical_criterion_type_code = p_anal_criterion_type_code
       AND xah.analytical_criterion_code      = p_analytical_criterion_code
     UNION
    SELECT xpa.application_id, xpa.event_class_code,
           xpa.product_rule_type_code, xpa.product_rule_code
      FROM xla_prod_acct_headers        xpa
          ,xla_aad_line_defn_assgns     xal
          ,xla_line_defn_ac_assgns      xac
     WHERE xpa.application_id                 = xal.application_id
       AND xpa.amb_context_code               = xal.amb_context_code
       AND xpa.product_rule_type_code         = xal.product_rule_type_code
       AND xpa.product_rule_code              = xal.product_rule_code
       AND xpa.event_class_code               = xal.event_class_code
       AND xpa.event_type_code                = xal.event_type_code
       AND xal.application_id                 = xac.application_id
       AND xal.amb_context_code               = xac.amb_context_code
       AND xal.event_class_code               = xac.event_class_code
       AND xal.event_type_code                = xac.event_type_code
       AND xal.line_definition_owner_code     = xac.line_definition_owner_code
       AND xal.line_definition_code           = xac.line_definition_code
       AND xac.amb_context_code               = p_amb_context_code
       AND xac.analytical_criterion_type_code = p_anal_criterion_type_code
       AND xac.analytical_criterion_code      = p_analytical_criterion_code;

  l_locked_application_id         INTEGER;
  l_locked_entity_code            VARCHAR2(30);
  l_locked_event_class_code       VARCHAR2(30);
  l_locked_event_type_code        VARCHAR2(30);
  l_locked_aad_type_code          VARCHAR2(30);
  l_locked_aad_code               VARCHAR2(30);

  l_application_ids         t_array_int;
  l_event_class_codes       t_array_codes;
  l_product_rule_type_codes t_array_type_codes;
  l_product_rule_codes      t_array_codes;

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.uncompile_definitions';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure uncompile_definitions'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'amb_context_code = '||p_amb_context_code||
                      ',analytical_criterion_type_code = '||p_anal_criterion_type_code||
                      ',analytical_criterion_code = '||p_analytical_criterion_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_lock_aad IN c_lock_header_aads LOOP
     IF (l_lock_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
         l_lock_aad.locking_status_flag    = 'Y') THEN

       l_locked_application_id      := l_lock_aad.application_id;
       l_locked_entity_code         := l_lock_aad.entity_code;
       l_locked_event_class_code    := l_lock_aad.event_class_code;
       l_locked_event_type_code     := l_lock_aad.event_type_code;
       l_locked_aad_type_code       := l_lock_aad.product_rule_type_code;
       l_locked_aad_code            := l_lock_aad.product_rule_code;
       l_locking_status_flag        := l_lock_aad.locking_status_flag;

       l_return := FALSE;
       EXIT;
     END IF;
  END LOOP;

  IF (l_return) THEN
    FOR l_lock_aad IN c_lock_line_aads LOOP
       IF (l_lock_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
           l_lock_aad.locking_status_flag    = 'Y') THEN

         l_locked_application_id      := l_lock_aad.application_id;
         l_locked_entity_code         := l_lock_aad.entity_code;
         l_locked_event_class_code    := l_lock_aad.event_class_code;
         l_locked_event_type_code     := l_lock_aad.event_type_code;
         l_locked_aad_type_code       := l_lock_aad.product_rule_type_code;
         l_locked_aad_code            := l_lock_aad.product_rule_code;
         l_locking_status_flag        := l_lock_aad.locking_status_flag;

         l_return := FALSE;
         EXIT;
       END IF;
    END LOOP;
  END IF;

  IF (NOT l_return) THEN

    xla_validations_pkg.get_product_rule_info
           (p_application_id          => l_locked_application_id
           ,p_amb_context_code        => p_amb_context_code
           ,p_product_rule_type_code  => l_locked_aad_type_code
           ,p_product_rule_code       => l_locked_aad_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

    xla_validations_pkg.get_event_class_info
           (p_application_id          => l_locked_application_id
           ,p_entity_code             => l_locked_entity_code
           ,p_event_class_code        => l_locked_event_class_code
           ,p_event_class_name        => l_event_class_name);

    xla_validations_pkg.get_event_type_info
           (p_application_id          => l_locked_application_id
           ,p_entity_code             => l_locked_entity_code
           ,p_event_class_code        => l_locked_event_class_code
           ,p_event_type_code         => l_locked_event_type_code
           ,p_event_type_name         => l_event_type_name);

  ELSE

    UPDATE xla_line_definitions_b xld
       SET validation_status_code = 'N'
         , last_update_date  = sysdate
         , last_updated_by   = xla_environment_pkg.g_usr_id
         , last_update_login = xla_environment_pkg.g_login_id
     WHERE xld.amb_context_code       = p_amb_context_code
       AND xld.validation_status_code <> 'N'
       AND EXISTS
           (SELECT 'X'
              FROM xla_line_defn_ac_assgns xac
             WHERE xac.amb_context_code               = p_amb_context_code
               AND xac.analytical_criterion_type_code = p_anal_criterion_type_code
               AND xac.analytical_criterion_code      = p_analytical_criterion_code
               AND xac.application_id                 = xld.application_id
               AND xac.event_class_code               = xld.event_class_code
               AND xac.event_type_code                = xld.event_type_code
               AND xac.line_definition_owner_code     = xld.line_definition_owner_code
               AND xac.line_definition_code           = xld.line_definition_code);

    OPEN c_update_aads;
    FETCH c_update_aads BULK COLLECT INTO l_application_ids
                                         ,l_event_class_codes
                                         ,l_product_rule_type_codes
                                         ,l_product_rule_codes;
    CLOSE c_update_aads;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'l_event_class_codes.count = '||l_event_class_codes.count,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF (l_event_class_codes.count > 0) THEN

      FORALL i IN 1..l_event_class_codes.LAST
        UPDATE xla_product_rules_b
           SET compile_status_code    = 'N'
             , updated_flag           = 'Y'
             , last_update_date       = sysdate
             , last_updated_by        = xla_environment_pkg.g_usr_id
             , last_update_login      = xla_environment_pkg.g_login_id
         WHERE application_id         = l_application_ids(i)
           AND amb_context_code       = p_amb_context_code
           AND product_rule_type_code = l_product_rule_type_codes(i)
           AND product_rule_code      = l_product_rule_codes(i)
           AND (compile_status_code   <> 'N' OR
                updated_flag          <> 'Y');

      FORALL i IN 1..l_event_class_codes.LAST
        UPDATE xla_prod_acct_headers
           SET validation_status_code = 'N'
             , last_update_date       = sysdate
             , last_updated_by        = xla_environment_pkg.g_usr_id
             , last_update_login      = xla_environment_pkg.g_login_id
         WHERE application_id         = l_application_ids(i)
           AND amb_context_code       = p_amb_context_code
           AND event_class_code       = l_event_class_codes(i)
           AND product_rule_type_code = l_product_rule_type_codes(i)
           AND product_rule_code      = l_product_rule_codes(i)
           AND validation_status_code <> 'N';

      FORALL i IN 1..l_application_ids.LAST
        UPDATE xla_appli_amb_contexts
           SET updated_flag      = 'Y'
             , last_update_date  = sysdate
             , last_updated_by   = xla_environment_pkg.g_usr_id
             , last_update_login = xla_environment_pkg.g_login_id
         WHERE application_id    = l_application_ids(i)
           AND amb_context_code  = p_amb_context_code
           AND updated_flag      <> 'Y';

    END IF;
    l_return := TRUE;
  END IF;

  x_product_rule_name   := l_product_rule_name;
  x_product_rule_type   := l_product_rule_type;
  x_event_class_name    := l_event_class_name;
  x_event_type_name     := l_event_type_name;
  x_locking_status_flag := l_locking_status_flag;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure uncompile_definitions'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_update_aads%ISOPEN THEN
      CLOSE c_update_aads;
    END IF;
    IF c_lock_line_aads%ISOPEN THEN
      CLOSE c_lock_line_aads;
    END IF;
    IF c_lock_header_aads%ISOPEN THEN
      CLOSE c_lock_header_aads;
    END IF;

    RAISE;
  WHEN OTHERS THEN
    IF c_update_aads%ISOPEN THEN
      CLOSE c_update_aads;
    END IF;
    IF c_lock_line_aads%ISOPEN THEN
      CLOSE c_lock_line_aads;
    END IF;
    IF c_lock_header_aads%ISOPEN THEN
      CLOSE c_lock_header_aads;
    END IF;

    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_analytical_hdrs_pkg.uncompile_definitions');

END uncompile_definitions;

--=============================================================================
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--=============================================================================
BEGIN
   g_log_level          := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled        := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_analytical_hdrs_pkg;

/
