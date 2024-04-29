--------------------------------------------------------
--  DDL for Package Body XLA_EVT_CLASS_ACCT_ATTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_EVT_CLASS_ACCT_ATTRS_PKG" AS
/* $Header: xlaamaaa.pkb 120.13 2006/09/29 18:03:35 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         ALL rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_evt_class_acct_attrs_pkg                                       |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Event CLASS Acct Attrs PACKAGE                                 |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|    01-Mar-05 W. Shen        CHANGE THE FUNCTION insert_jlt_assignment |
|                               don't insert certain attributes for     |
|                               gain/loss line TYPES                    |
|                                                                       |
+======================================================================*/

-------------------------------------------------------------------------------
-- declaring private package variables
-------------------------------------------------------------------------------
g_creation_date                   DATE;
g_last_update_date                DATE;
g_created_by                      INTEGER;
g_last_update_login               INTEGER;
g_last_updated_by                 INTEGER;

-------------------------------------------------------------------------------
-- Debug constants
-------------------------------------------------------------------------------
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_evt_class_acct_attrs_pkg';

-------------------------------------------------------------------------------
-- Debug variables
-------------------------------------------------------------------------------
g_log_level     PLS_INTEGER  :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_log_enabled   BOOLEAN :=  fnd_log.test
                               (log_level  => g_log_level
                               ,MODULE     => C_DEFAULT_MODULE);
-------------------------------------------------------------------------------
-- declaring private package arrays
-------------------------------------------------------------------------------
TYPE t_array_codes         IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_array_type_codes    IS TABLE OF VARCHAR2(1)  INDEX BY BINARY_INTEGER;

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
         (p_location   => 'xla_evt_class_acct_attrs_pkg.trace');
END trace;

/*======================================================================+
|                                                                       |
| PRIVATE FUNCTION                                                      |
|                                                                       |
| uncompile_defn_with_line                                              |
|                                                                       |
| Returns TRUE IF ALL THE application accounting definitions AND        |
| journal line definitions using ANY JLTare uncompiled                  |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_defn_with_line
  (p_application_id                  IN  NUMBER
  ,p_event_class_code                IN  VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN := TRUE;
   l_exist    VARCHAR2(1);

   l_application_name     VARCHAR2(240) := NULL;
   l_product_rule_name    VARCHAR2(80)  := NULL;
   l_product_rule_type    VARCHAR2(80)  := NULL;
   l_event_class_name     VARCHAR2(80)  := NULL;
   l_event_type_name      VARCHAR2(80)  := NULL;
   l_locking_status_flag  VARCHAR2(1)   := NULL;

   CURSOR c_lock_aads IS
    SELECT xpa.entity_code
          ,xpa.event_class_code
          ,xpa.event_type_code
          ,xpa.amb_context_code
          ,xpa.product_rule_type_code
          ,xpa.product_rule_code
         , xpa.validation_status_code
         , xpa.locking_status_flag
      FROM xla_prod_acct_headers    xpa
     WHERE xpa.application_id             = p_application_id
       AND xpa.event_class_code           = p_event_class_code
       AND EXISTS (SELECT 'x'
                     FROM xla_aad_line_defn_assgns xal
                        , xla_line_defn_jlt_assgns xld
                    WHERE xld.application_id             = xal.application_id
                      AND xld.amb_context_code           = xal.amb_context_code
                      AND xld.event_class_code           = xal.event_class_code
                      AND xld.event_type_code            = xal.event_type_code
                      AND xld.line_definition_owner_code = xal.line_definition_owner_code
                      AND xld.line_definition_code       = xal.line_definition_code
                      AND xal.application_id             = xpa.application_id
                      AND xal.amb_context_code           = xpa.amb_context_code
                      AND xal.event_class_code           = xpa.event_class_code
                      AND xal.event_type_code            = xpa.event_type_code
                      AND xal.product_rule_type_code     = xpa.product_rule_type_code
                      AND xal.product_rule_code          = xpa.product_rule_code)
      FOR UPDATE NOWAIT;

BEGIN

   xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.uncompile_defn_with_line'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('event_class_code    = '||p_event_class_code     , 20);

   l_return := TRUE;

   FOR l_lock_aad IN c_lock_aads LOOP
     IF (l_lock_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
         l_lock_aad.locking_status_flag    = 'Y') THEN

       xla_validations_pkg.get_product_rule_info
           (p_application_id          => p_application_id
           ,p_amb_context_code        => l_lock_aad.amb_context_code
           ,p_product_rule_type_code  => l_lock_aad.product_rule_type_code
           ,p_product_rule_code       => l_lock_aad.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

       xla_validations_pkg.get_event_class_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_class_name        => l_event_class_name);

       xla_validations_pkg.get_event_type_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_type_code         => l_lock_aad.event_type_code
           ,p_event_type_name         => l_event_type_name);

      l_locking_status_flag := l_lock_aad.locking_status_flag;

       l_return := FALSE;

       EXIT;
     END IF;
   END LOOP;

   IF (l_return) THEN

      UPDATE xla_line_definitions_b     xld
         SET validation_status_code     = 'N'
       WHERE xld.application_id         = p_application_id
         AND xld.event_class_code       = p_event_class_code
         AND xld.validation_status_code <> 'N'
         AND EXISTS (SELECT 'X'
                       FROM xla_line_defn_jlt_assgns xja
                      WHERE xld.application_id             = xja.application_id
                        AND xld.amb_context_code           = xja.amb_context_code
                        AND xld.event_class_code           = xja.event_class_code
                        AND xld.event_type_code            = xja.event_type_code
                        AND xld.line_definition_owner_code = xja.line_definition_owner_code
                        AND xld.line_definition_code       = xja.line_definition_code);

      UPDATE xla_prod_acct_headers      xpa
         SET validation_status_code     = 'N'
       WHERE xpa.application_id         = p_application_id
         AND xpa.event_class_code       = p_event_class_code
         AND xpa.validation_status_code <> 'N'
         AND EXISTS (SELECT 'x'
                       FROM xla_aad_line_defn_assgns xal
                          , xla_line_defn_jlt_assgns xja
                      WHERE xja.application_id             = xal.application_id
                        AND xja.amb_context_code           = xal.amb_context_code
                        AND xja.event_class_code           = xal.event_class_code
                        AND xja.event_type_code            = xal.event_type_code
                        AND xja.line_definition_owner_code = xal.line_definition_owner_code
                        AND xja.line_definition_code       = xal.line_definition_code
                        AND xal.application_id             = xpa.application_id
                        AND xal.amb_context_code           = xpa.amb_context_code
                        AND xal.event_class_code           = xpa.event_class_code
                        AND xal.event_type_code            = xpa.event_type_code
                        AND xal.product_rule_type_code     = xpa.product_rule_type_code
                        AND xal.product_rule_code          = xpa.product_rule_code);

      UPDATE xla_product_rules_b        xpr
         SET compile_status_code        = 'N'
       WHERE xpr.application_id         = p_application_id
         AND xpr.compile_status_code    <> 'N'
         AND EXISTS (SELECT 'x'
                       FROM xla_aad_line_defn_assgns xal
                          , xla_line_defn_jlt_assgns xja
                      WHERE xja.application_id             = xal.application_id
                        AND xja.amb_context_code           = xal.amb_context_code
                        AND xja.event_class_code           = xal.event_class_code
                        AND xja.event_type_code            = xal.event_type_code
                        AND xja.line_definition_owner_code = xal.line_definition_owner_code
                        AND xja.line_definition_code       = xal.line_definition_code
                        AND xal.application_id             = xpr.application_id
                        AND xal.amb_context_code           = xpr.amb_context_code
                        AND xal.product_rule_type_code     = xpr.product_rule_type_code
                        AND xal.product_rule_code          = xpr.product_rule_code);

   END IF;

   x_product_rule_name   := l_product_rule_name;
   x_product_rule_type   := l_product_rule_type;
   x_event_class_name    := l_event_class_name;
   x_event_type_name     := l_event_type_name;
   x_locking_status_flag := l_locking_status_flag;

   xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.uncompile_defn_with_line'    , 10);

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_evt_class_acct_attrs_pkg.uncompile_defn_with_line');

END uncompile_defn_with_line;


/*======================================================================+
|                                                                       |
| PRIVATE FUNCTION                                                      |
|                                                                       |
| uncompile_defn_with_line_acct                                         |
|                                                                       |
| Returns TRUE IF ALL THE application accounting definitions AND        |
| journal line definitions using ANY JLTare uncompiled                  |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_defn_with_line_acct
  (p_application_id                  IN  NUMBER
  ,p_event_class_code                IN  VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN := TRUE;
   l_exist    VARCHAR2(1);

   l_application_name     VARCHAR2(240) := NULL;
   l_product_rule_name    VARCHAR2(80)  := NULL;
   l_product_rule_type    VARCHAR2(80)  := NULL;
   l_event_class_name     VARCHAR2(80)  := NULL;
   l_event_type_name      VARCHAR2(80)  := NULL;
   l_locking_status_flag  VARCHAR2(1)   := NULL;

   CURSOR c_lock_aads IS
    SELECT xpa.entity_code
          ,xpa.event_class_code
          ,xpa.event_type_code
          ,xpa.amb_context_code
          ,xpa.product_rule_type_code
          ,xpa.product_rule_code
         , xpa.validation_status_code
         , xpa.locking_status_flag
      FROM xla_prod_acct_headers    xpa
     WHERE xpa.application_id             = p_application_id
       AND xpa.event_class_code           = p_event_class_code
       AND xpa.accounting_required_flag   = 'Y'
       AND EXISTS (SELECT 'x'
                     FROM xla_aad_line_defn_assgns xal
                        , xla_line_defn_jlt_assgns xld
                    WHERE xld.application_id             = xal.application_id
                      AND xld.amb_context_code           = xal.amb_context_code
                      AND xld.event_class_code           = xal.event_class_code
                      AND xld.event_type_code            = xal.event_type_code
                      AND xld.line_definition_owner_code = xal.line_definition_owner_code
                      AND xld.line_definition_code       = xal.line_definition_code
                      AND xal.application_id             = xpa.application_id
                      AND xal.amb_context_code           = xpa.amb_context_code
                      AND xal.event_class_code           = xpa.event_class_code
                      AND xal.event_type_code            = xpa.event_type_code
                      AND xal.product_rule_type_code     = xpa.product_rule_type_code
                      AND xal.product_rule_code          = xpa.product_rule_code)
      FOR UPDATE NOWAIT;

BEGIN

   xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.uncompile_defn_with_line_acct'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('event_class_code    = '||p_event_class_code     , 20);

   l_return := TRUE;

   FOR l_lock_aad IN c_lock_aads LOOP
     IF (l_lock_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
         l_lock_aad.locking_status_flag    = 'Y') THEN

       xla_validations_pkg.get_product_rule_info
           (p_application_id          => p_application_id
           ,p_amb_context_code        => l_lock_aad.amb_context_code
           ,p_product_rule_type_code  => l_lock_aad.product_rule_type_code
           ,p_product_rule_code       => l_lock_aad.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

       xla_validations_pkg.get_event_class_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_class_name        => l_event_class_name);

       xla_validations_pkg.get_event_type_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_type_code         => l_lock_aad.event_type_code
           ,p_event_type_name         => l_event_type_name);

      l_locking_status_flag := l_lock_aad.locking_status_flag;

       l_return := FALSE;

       EXIT;
     END IF;
   END LOOP;

   IF (l_return) THEN

      UPDATE xla_line_definitions_b     xld
         SET validation_status_code     = 'N'
       WHERE xld.application_id         = p_application_id
         AND xld.event_class_code       = p_event_class_code
         AND xld.validation_status_code <> 'N'
         AND EXISTS (SELECT 'x'
                       FROM xla_prod_acct_headers    xpa
                          , xla_aad_line_defn_assgns xal
                          , xla_line_defn_jlt_assgns xja
                      WHERE xld.application_id             = xja.application_id
                        AND xld.amb_context_code           = xja.amb_context_code
                        AND xld.event_class_code           = xja.event_class_code
                        AND xld.event_type_code            = xja.event_type_code
                        AND xld.line_definition_owner_code = xja.line_definition_owner_code
                        AND xld.line_definition_code       = xja.line_definition_code
                        AND xld.application_id             = xal.application_id
                        AND xld.amb_context_code           = xal.amb_context_code
                        AND xld.event_class_code           = xal.event_class_code
                        AND xld.event_type_code            = xal.event_type_code
                        AND xld.line_definition_owner_code = xal.line_definition_owner_code
                        AND xld.line_definition_code       = xal.line_definition_code
                        AND xal.application_id             = xpa.application_id
                        AND xal.amb_context_code           = xpa.amb_context_code
                        AND xal.event_class_code           = xpa.event_class_code
                        AND xal.event_type_code            = xpa.event_type_code
                        AND xal.product_rule_type_code     = xpa.product_rule_type_code
                        AND xal.product_rule_code          = xpa.product_rule_code
                        AND xpa.accounting_required_flag   = 'Y');

      UPDATE xla_prod_acct_headers        xpa
         SET validation_status_code       = 'N'
       WHERE xpa.application_id           = p_application_id
         AND xpa.event_class_code         = p_event_class_code
         AND xpa.accounting_required_flag = 'Y'
         AND xpa.validation_status_code   <> 'N'
         AND EXISTS (SELECT 'x'
                       FROM xla_aad_line_defn_assgns xal
                          , xla_line_defn_jlt_assgns xld
                      WHERE xld.application_id             = xal.application_id
                        AND xld.amb_context_code           = xal.amb_context_code
                        AND xld.event_class_code           = xal.event_class_code
                        AND xld.event_type_code            = xal.event_type_code
                        AND xld.line_definition_owner_code = xal.line_definition_owner_code
                        AND xld.line_definition_code       = xal.line_definition_code
                        AND xal.application_id             = xpa.application_id
                        AND xal.amb_context_code           = xpa.amb_context_code
                        AND xal.event_class_code           = xpa.event_class_code
                        AND xal.event_type_code            = xpa.event_type_code
                        AND xal.product_rule_type_code     = xpa.product_rule_type_code
                        AND xal.product_rule_code          = xpa.product_rule_code);

      UPDATE xla_product_rules_b        xpr
         SET compile_status_code        = 'N'
       WHERE xpr.application_id         = p_application_id
         AND xpr.compile_status_code    <> 'N'
         AND EXISTS (SELECT 'x'
                       FROM xla_prod_acct_headers    xpa
                          , xla_aad_line_defn_assgns xal
                          , xla_line_defn_jlt_assgns xja
                      WHERE xja.application_id             = xal.application_id
                        AND xja.amb_context_code           = xal.amb_context_code
                        AND xja.event_class_code           = xal.event_class_code
                        AND xja.event_type_code            = xal.event_type_code
                        AND xja.line_definition_owner_code = xal.line_definition_owner_code
                        AND xja.line_definition_code       = xal.line_definition_code
                        AND xal.application_id             = xpa.application_id
                        AND xal.amb_context_code           = xpa.amb_context_code
                        AND xal.event_class_code           = xpa.event_class_code
                        AND xal.event_type_code            = xpa.event_type_code
                        AND xal.product_rule_type_code     = xpa.product_rule_type_code
                        AND xal.product_rule_code          = xpa.product_rule_code
                        AND xpa.accounting_required_flag   = 'Y'
                        AND xal.application_id             = xpr.application_id
                        AND xal.amb_context_code           = xpr.amb_context_code
                        AND xal.product_rule_type_code     = xpr.product_rule_type_code
                        AND xal.product_rule_code          = xpr.product_rule_code);

   END IF;

   x_product_rule_name   := l_product_rule_name;
   x_product_rule_type   := l_product_rule_type;
   x_event_class_name    := l_event_class_name;
   x_event_type_name     := l_event_type_name;
   x_locking_status_flag := l_locking_status_flag;

   xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.uncompile_defn_with_line_acct'    , 10);

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_evt_class_acct_attrs_pkg.uncompile_defn_with_line_acct');

END uncompile_defn_with_line_acct;


/*======================================================================+
|                                                                       |
| PRIVATE FUNCTION                                                      |
|                                                                       |
| uncompile_defn_with_jlt                                              |
|                                                                       |
| Returns TRUE IF ALL THE application accounting definitions AND        |
| journal line definitions using ANY JLTare uncompiled                  |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_defn_with_jlt
  (p_application_id                  IN  NUMBER
  ,p_event_class_code                IN  VARCHAR2
  ,p_accounting_attribute_code       IN VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN := TRUE;
   l_exist    VARCHAR2(1);

   l_application_name     VARCHAR2(240) := NULL;
   l_product_rule_name    VARCHAR2(80)  := NULL;
   l_product_rule_type    VARCHAR2(80)  := NULL;
   l_event_class_name     VARCHAR2(80)  := NULL;
   l_event_type_name      VARCHAR2(80)  := NULL;
   l_locking_status_flag  VARCHAR2(1)   := NULL;

   CURSOR c_lock_aads IS
    SELECT xpa.entity_code
          ,xpa.event_class_code
          ,xpa.event_type_code
          ,xpa.amb_context_code
          ,xpa.product_rule_type_code
          ,xpa.product_rule_code
         , xpa.validation_status_code
         , xpa.locking_status_flag
      FROM xla_prod_acct_headers    xpa
     WHERE xpa.application_id             = p_application_id
       AND xpa.event_class_code           = p_event_class_code
       AND EXISTS (SELECT 'x'
                     FROM xla_aad_line_defn_assgns xal
                        , xla_line_defn_jlt_assgns xld
                        , xla_jlt_acct_attrs       xja
                    WHERE xja.application_id             = p_application_id
                      AND xja.event_class_code           = p_event_class_code
                      AND xja.accounting_attribute_code  = p_accounting_attribute_code
                      AND xja.event_class_default_flag   = 'Y'
                      AND xja.application_id             = xld.application_id
                      AND xja.amb_context_code           = xld.amb_context_code
                      AND xja.event_class_code           = xld.event_class_code
                      AND xja.accounting_line_type_code  = xld.accounting_line_type_code
                      AND xja.accounting_line_code       = xld.accounting_line_code
                      AND xld.application_id             = xal.application_id
                      AND xld.amb_context_code           = xal.amb_context_code
                      AND xld.event_class_code           = xal.event_class_code
                      AND xld.event_type_code            = xal.event_type_code
                      AND xld.line_definition_owner_code = xal.line_definition_owner_code
                      AND xld.line_definition_code       = xal.line_definition_code
                      AND xal.application_id             = xpa.application_id
                      AND xal.amb_context_code           = xpa.amb_context_code
                      AND xal.event_class_code           = xpa.event_class_code
                      AND xal.event_type_code            = xpa.event_type_code
                      AND xal.product_rule_type_code     = xpa.product_rule_type_code
                      AND xal.product_rule_code          = xpa.product_rule_code)
      FOR UPDATE NOWAIT;

BEGIN

   xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.uncompile_defn_with_jlt'   , 10);

   xla_utility_pkg.trace('application_id            = '||p_application_id  , 20);
   xla_utility_pkg.trace('event_class_code          = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('accounting_attribute_code = '||p_accounting_attribute_code     , 20);

   l_return := TRUE;

   FOR l_lock_aad IN c_lock_aads LOOP
     IF (l_lock_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
         l_lock_aad.locking_status_flag    = 'Y') THEN

       xla_validations_pkg.get_product_rule_info
           (p_application_id          => p_application_id
           ,p_amb_context_code        => l_lock_aad.amb_context_code
           ,p_product_rule_type_code  => l_lock_aad.product_rule_type_code
           ,p_product_rule_code       => l_lock_aad.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

       xla_validations_pkg.get_event_class_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_class_name        => l_event_class_name);

       xla_validations_pkg.get_event_type_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_type_code         => l_lock_aad.event_type_code
           ,p_event_type_name         => l_event_type_name);

       l_locking_status_flag := l_lock_aad.locking_status_flag;

       l_return := FALSE;

       EXIT;
     END IF;
   END LOOP;

   IF (l_return) THEN

      UPDATE xla_line_definitions_b     xpa
         SET validation_status_code     = 'N'
       WHERE xpa.application_id         = p_application_id
         AND xpa.event_class_code       = p_event_class_code
         AND xpa.validation_status_code <> 'N'
         AND EXISTS (SELECT 'X'
                       FROM xla_line_defn_jlt_assgns       xld
                          , xla_jlt_acct_attrs       xja
                      WHERE xja.application_id             = p_application_id
                        AND xja.event_class_code           = p_event_class_code
                        AND xja.accounting_attribute_code  = p_accounting_attribute_code
                        AND xja.event_class_default_flag   = 'Y'
                        AND xja.application_id             = xld.application_id
                        AND xja.amb_context_code           = xld.amb_context_code
                        AND xja.event_class_code           = xld.event_class_code
                        AND xja.accounting_line_type_code  = xld.accounting_line_type_code
                        AND xja.accounting_line_code       = xld.accounting_line_code
                        AND xld.application_id             = xpa.application_id
                        AND xld.amb_context_code           = xpa.amb_context_code
                        AND xld.event_class_code           = xpa.event_class_code
                        AND xld.event_type_code            = xpa.event_type_code
                        AND xld.line_definition_owner_code = xpa.line_definition_owner_code
                        AND xld.line_definition_code       = xpa.line_definition_code);

      UPDATE xla_prod_acct_headers      xpa
         SET validation_status_code     = 'N'
       WHERE xpa.application_id         = p_application_id
         AND xpa.event_class_code       = p_event_class_code
         AND xpa.validation_status_code <> 'N'
         AND EXISTS (SELECT 'X'
                       FROM xla_aad_line_defn_assgns       xal
                          , xla_line_defn_jlt_assgns       xld
                          , xla_jlt_acct_attrs             xja
                      WHERE xja.application_id             = p_application_id
                        AND xja.event_class_code           = p_event_class_code
                        AND xja.accounting_attribute_code  = p_accounting_attribute_code
                        AND xja.event_class_default_flag   = 'Y'
                        AND xja.application_id             = xld.application_id
                        AND xja.amb_context_code           = xld.amb_context_code
                        AND xja.event_class_code           = xld.event_class_code
                        AND xja.accounting_line_type_code  = xld.accounting_line_type_code
                        AND xja.accounting_line_code       = xld.accounting_line_code
                        AND xld.application_id             = xal.application_id
                        AND xld.amb_context_code           = xal.amb_context_code
                        AND xld.event_class_code           = xal.event_class_code
                        AND xld.event_type_code            = xal.event_type_code
                        AND xld.line_definition_owner_code = xal.line_definition_owner_code
                        AND xld.line_definition_code       = xal.line_definition_code
                        AND xal.application_id             = xpa.application_id
                        AND xal.amb_context_code           = xpa.amb_context_code
                        AND xal.event_class_code           = xpa.event_class_code
                        AND xal.event_type_code            = xpa.event_type_code
                        AND xal.product_rule_type_code     = xpa.product_rule_type_code
                        AND xal.product_rule_code          = xpa.product_rule_code);

      UPDATE xla_product_rules_b        xpr
         SET compile_status_code        = 'N'
       WHERE xpr.application_id         = p_application_id
         AND xpr.compile_status_code    <> 'N'
         AND EXISTS (SELECT 'X'
                       FROM xla_aad_line_defn_assgns       xal
                          , xla_line_defn_jlt_assgns       xld
                          , xla_jlt_acct_attrs             xja
                      WHERE xja.application_id             = p_application_id
                        AND xja.event_class_code           = p_event_class_code
                        AND xja.accounting_attribute_code  = p_accounting_attribute_code
                        AND xja.event_class_default_flag   = 'Y'
                        AND xja.application_id             = xld.application_id
                        AND xja.amb_context_code           = xld.amb_context_code
                        AND xja.event_class_code           = xld.event_class_code
                        AND xja.accounting_line_type_code  = xld.accounting_line_type_code
                        AND xja.accounting_line_code       = xld.accounting_line_code
                        AND xld.application_id             = xal.application_id
                        AND xld.amb_context_code           = xal.amb_context_code
                        AND xld.event_class_code           = xal.event_class_code
                        AND xld.event_type_code            = xal.event_type_code
                        AND xld.line_definition_owner_code = xal.line_definition_owner_code
                        AND xld.line_definition_code       = xal.line_definition_code
                        AND xal.application_id             = xpr.application_id
                        AND xal.amb_context_code           = xpr.amb_context_code
                        AND xal.product_rule_type_code     = xpr.product_rule_type_code
                        AND xal.product_rule_code          = xpr.product_rule_code);
   END IF;

   x_product_rule_name   := l_product_rule_name;
   x_product_rule_type   := l_product_rule_type;
   x_event_class_name    := l_event_class_name;
   x_event_type_name     := l_event_type_name;
   x_locking_status_flag := l_locking_status_flag;

   xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.uncompile_defn_with_jlt'    , 10);

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_evt_class_acct_attrs_pkg.uncompile_defn_with_jlt');

END uncompile_defn_with_jlt;

/*======================================================================+
|                                                                       |
| PRIVATE FUNCTION                                                      |
|                                                                       |
| uncompile_defn_with_default                                              |
|                                                                       |
| Returns TRUE IF ALL THE application accounting definitions AND        |
| journal line definitions using ANY JLTare uncompiled                  |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_defn_with_default
  (x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN := TRUE;
   l_exist    VARCHAR2(1);

   l_application_name     VARCHAR2(240) := NULL;
   l_product_rule_name    VARCHAR2(80)  := NULL;
   l_product_rule_type    VARCHAR2(80)  := NULL;
   l_event_class_name     VARCHAR2(80)  := NULL;
   l_event_type_name      VARCHAR2(80)  := NULL;
   l_locking_status_flag  VARCHAR2(1)   := NULL;

   CURSOR c_lock_aads IS
    SELECT xpa.application_id
          ,xpa.entity_code
          ,xpa.event_class_code
          ,xpa.event_type_code
          ,xpa.amb_context_code
          ,xpa.product_rule_type_code
          ,xpa.product_rule_code
         , xpa.validation_status_code
         , xpa.locking_status_flag
      FROM xla_prod_acct_headers    xpa
         , xla_aad_hdr_acct_attrs   xah
     WHERE xpa.application_id             = xah.application_id
       AND xpa.amb_context_code           = xah.amb_context_code
       AND xpa.event_class_code           = xah.event_class_code
       AND xpa.event_type_code            = xah.event_type_code
       AND xpa.product_rule_type_code     = xah.product_rule_type_code
       AND xpa.product_rule_code          = xah.product_rule_code
       AND xah.event_class_default_flag   = 'Y'
       AND xpa.accounting_required_flag   = 'Y'
      FOR UPDATE NOWAIT;

BEGIN

   xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.uncompile_defn_with_default'   , 10);

   l_return := TRUE;

   FOR l_lock_aad IN c_lock_aads LOOP
     IF (l_lock_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
         l_lock_aad.locking_status_flag    = 'Y') THEN

       xla_validations_pkg.get_product_rule_info
           (p_application_id          => l_lock_aad.application_id
           ,p_amb_context_code        => l_lock_aad.amb_context_code
           ,p_product_rule_type_code  => l_lock_aad.product_rule_type_code
           ,p_product_rule_code       => l_lock_aad.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

       xla_validations_pkg.get_event_class_info
           (p_application_id          => l_lock_aad.application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_class_name        => l_event_class_name);

       xla_validations_pkg.get_event_type_info
           (p_application_id          => l_lock_aad.application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_type_code         => l_lock_aad.event_type_code
           ,p_event_type_name         => l_event_type_name);

      l_locking_status_flag := l_lock_aad.locking_status_flag;

       l_return := FALSE;

       EXIT;
     END IF;
   END LOOP;

   IF (l_return) THEN

      UPDATE xla_prod_acct_headers      xpa
         SET validation_status_code     = 'N'
       WHERE xpa.accounting_required_flag = 'Y'
         AND EXISTS (SELECT 'x'
                       FROM xla_aad_hdr_acct_attrs xah
                      WHERE xpa.application_id             = xah.application_id
                        AND xpa.amb_context_code           = xah.amb_context_code
                        AND xpa.event_class_code           = xah.event_class_code
                        AND xpa.event_type_code            = xah.event_type_code
                        AND xpa.product_rule_type_code     = xah.product_rule_type_code
                        AND xpa.product_rule_code          = xah.product_rule_code
                        AND xah.event_class_default_flag   = 'Y');

      UPDATE xla_product_rules_b        xpr
         SET compile_status_code        = 'N'
       WHERE xpr.compile_status_code    <> 'N'
         AND EXISTS (SELECT 'x'
                       FROM xla_prod_acct_headers    xpa
                          , xla_aad_hdr_acct_attrs   xah
                      WHERE xpa.application_id             = xah.application_id
                        AND xpa.amb_context_code           = xah.amb_context_code
                        AND xpa.event_class_code           = xah.event_class_code
                        AND xpa.event_type_code            = xah.event_type_code
                        AND xpa.product_rule_type_code     = xah.product_rule_type_code
                        AND xpa.product_rule_code          = xah.product_rule_code
                        AND xah.event_class_default_flag   = 'Y'
                        AND xpr.application_id             = xpa.application_id
                        AND xpr.amb_context_code           = xpa.amb_context_code
                        AND xpr.product_rule_type_code     = xpa.product_rule_type_code
                        AND xpr.product_rule_code          = xpa.product_rule_code
                        AND xpa.accounting_required_flag   = 'Y');

   END IF;

   x_product_rule_name   := l_product_rule_name;
   x_product_rule_type   := l_product_rule_type;
   x_event_class_name    := l_event_class_name;
   x_event_type_name     := l_event_type_name;
   x_locking_status_flag := l_locking_status_flag;

   xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.uncompile_defn_with_default'    , 10);

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_evt_class_acct_attrs_pkg.uncompile_defn_with_default');

END uncompile_defn_with_default;


/*======================================================================+
|                                                                       |
| PRIVATE FUNCTION                                                      |
|                                                                       |
| uncompile_defn_with_jlt_source                                        |
|                                                                       |
| Returns TRUE IF ALL THE application accounting definitions AND        |
| journal line definitions using ANY JLTare uncompiled                  |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_defn_with_jlt_source
  (p_application_id                  IN NUMBER
  ,p_event_class_code                IN VARCHAR2
  ,p_accounting_attribute_code       IN VARCHAR2
  ,p_source_application_id           IN NUMBER
  ,p_source_code                     IN VARCHAR2
  ,p_source_type_code                IN VARCHAR2
  ,p_event_class_default_flag        IN VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN := TRUE;
   l_exist    VARCHAR2(1);

   l_application_name     VARCHAR2(240) := NULL;
   l_product_rule_name    VARCHAR2(80)  := NULL;
   l_product_rule_type    VARCHAR2(80)  := NULL;
   l_event_class_name     VARCHAR2(80)  := NULL;
   l_event_type_name      VARCHAR2(80)  := NULL;
   l_locking_status_flag  VARCHAR2(1)   := NULL;

   CURSOR c_lock_aads IS
    SELECT xpa.entity_code
          ,xpa.event_class_code
          ,xpa.event_type_code
          ,xpa.amb_context_code
          ,xpa.product_rule_type_code
          ,xpa.product_rule_code
         , xpa.validation_status_code
         , xpa.locking_status_flag
      FROM xla_prod_acct_headers    xpa
     WHERE xpa.application_id             = p_application_id
       AND xpa.event_class_code           = p_event_class_code
       AND EXISTS (SELECT 'x'
                     FROM xla_aad_line_defn_assgns xal
                        , xla_line_defn_jlt_assgns xja
                        , xla_jlt_acct_attrs       xaa
                    WHERE xaa.application_id             = p_application_id
                      AND xaa.event_class_code           = p_event_class_code
                      AND xaa.accounting_attribute_code  = p_accounting_attribute_code
                      AND xaa.event_class_default_flag   = NVL(p_event_class_default_flag,
                                                               xaa.event_class_default_flag)
                      AND xaa.source_application_id      = p_source_application_id
                      AND xaa.source_type_code           = p_source_type_code
                      AND xaa.source_code                = p_source_code
                      AND xja.application_id             = xaa.application_id
                      AND xja.amb_context_code           = xaa.amb_context_code
                      AND xja.event_class_code           = xaa.event_class_code
                      AND xja.accounting_line_type_code  = xaa.accounting_line_type_code
                      AND xja.accounting_line_code       = xaa.accounting_line_code
                      AND xal.application_id             = xja.application_id
                      AND xal.amb_context_code           = xja.amb_context_code
                      AND xal.event_class_code           = xja.event_class_code
                      AND xal.event_type_code            = xja.event_type_code
                      AND xal.line_definition_owner_code = xja.line_definition_owner_code
                      AND xal.line_definition_code       = xja.line_definition_code
                      AND xal.application_id             = xpa.application_id
                      AND xal.amb_context_code           = xpa.amb_context_code
                      AND xal.event_class_code           = xpa.event_class_code
                      AND xal.event_type_code            = xpa.event_type_code
                      AND xal.product_rule_type_code     = xpa.product_rule_type_code
                      AND xal.product_rule_code          = xpa.product_rule_code)
      FOR UPDATE NOWAIT;

BEGIN

   xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.uncompile_defn_with_jlt_source'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('event_class_code    = '||p_event_class_code     , 20);

   l_return := TRUE;

   FOR l_lock_aad IN c_lock_aads LOOP
     IF (l_lock_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
         l_lock_aad.locking_status_flag    = 'Y') THEN

       xla_validations_pkg.get_product_rule_info
           (p_application_id          => p_application_id
           ,p_amb_context_code        => l_lock_aad.amb_context_code
           ,p_product_rule_type_code  => l_lock_aad.product_rule_type_code
           ,p_product_rule_code       => l_lock_aad.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

       xla_validations_pkg.get_event_class_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_class_name        => l_event_class_name);

       xla_validations_pkg.get_event_type_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_type_code         => l_lock_aad.event_type_code
           ,p_event_type_name         => l_event_type_name);

      l_locking_status_flag := l_lock_aad.locking_status_flag;

       l_return := FALSE;

       EXIT;
     END IF;
   END LOOP;

   IF (l_return) THEN

      UPDATE xla_line_definitions_b     xld
         SET validation_status_code     = 'N'
       WHERE xld.application_id         = p_application_id
         AND xld.event_class_code       = p_event_class_code
         AND xld.validation_status_code <> 'N'
         AND EXISTS (SELECT 'X'
                       FROM xla_line_defn_jlt_assgns xja
                          , xla_jlt_acct_attrs       xaa
                      WHERE xaa.application_id             = p_application_id
                        AND xaa.event_class_code           = p_event_class_code
                        AND xaa.accounting_attribute_code  = p_accounting_attribute_code
                        AND xaa.event_class_default_flag   = NVL(p_event_class_default_flag,
                                                                 xaa.event_class_default_flag)
                        AND xaa.source_application_id      = p_source_application_id
                        AND xaa.source_type_code           = p_source_type_code
                        AND xaa.source_code                = p_source_code
                        AND xja.application_id             = xaa.application_id
                        AND xja.amb_context_code           = xaa.amb_context_code
                        AND xja.event_class_code           = xaa.event_class_code
                        AND xja.accounting_line_type_code  = xaa.accounting_line_type_code
                        AND xja.accounting_line_code       = xaa.accounting_line_code
                        AND xld.application_id             = xja.application_id
                        AND xld.amb_context_code           = xja.amb_context_code
                        AND xld.event_class_code           = xja.event_class_code
                        AND xld.event_type_code            = xja.event_type_code
                        AND xld.line_definition_owner_code = xja.line_definition_owner_code
                        AND xld.line_definition_code       = xja.line_definition_code);

      UPDATE xla_prod_acct_headers      xpa
         SET validation_status_code     = 'N'
       WHERE xpa.application_id         = p_application_id
         AND xpa.event_class_code       = p_event_class_code
         AND xpa.validation_status_code <> 'N'
         AND EXISTS (SELECT 'x'
                       FROM xla_aad_line_defn_assgns xal
                          , xla_line_defn_jlt_assgns xja
                          , xla_jlt_acct_attrs       xaa
                      WHERE xaa.application_id             = p_application_id
                        AND xaa.event_class_code           = p_event_class_code
                        AND xaa.accounting_attribute_code  = p_accounting_attribute_code
                        AND xaa.event_class_default_flag   = NVL(p_event_class_default_flag,
                                                                 xaa.event_class_default_flag)
                        AND xaa.source_application_id      = p_source_application_id
                        AND xaa.source_type_code           = p_source_type_code
                        AND xaa.source_code                = p_source_code
                        AND xja.application_id             = xaa.application_id
                        AND xja.amb_context_code           = xaa.amb_context_code
                        AND xja.event_class_code           = xaa.event_class_code
                        AND xja.accounting_line_type_code  = xaa.accounting_line_type_code
                        AND xja.accounting_line_code       = xaa.accounting_line_code
                        AND xal.application_id             = xja.application_id
                        AND xal.amb_context_code           = xja.amb_context_code
                        AND xal.event_class_code           = xja.event_class_code
                        AND xal.event_type_code            = xja.event_type_code
                        AND xal.line_definition_owner_code = xja.line_definition_owner_code
                        AND xal.line_definition_code       = xja.line_definition_code
                        AND xal.application_id             = xpa.application_id
                        AND xal.amb_context_code           = xpa.amb_context_code
                        AND xal.event_class_code           = xpa.event_class_code
                        AND xal.event_type_code            = xpa.event_type_code
                        AND xal.product_rule_type_code     = xpa.product_rule_type_code
                        AND xal.product_rule_code          = xpa.product_rule_code);

      UPDATE xla_product_rules_b        xpr
         SET compile_status_code        = 'N'
       WHERE xpr.application_id         = p_application_id
         AND xpr.compile_status_code    <> 'N'
         AND EXISTS (SELECT 'x'
                       FROM xla_aad_line_defn_assgns xal
                          , xla_line_defn_jlt_assgns xja
                          , xla_jlt_acct_attrs       xaa
                      WHERE xaa.application_id             = p_application_id
                        AND xaa.event_class_code           = p_event_class_code
                        AND xaa.accounting_attribute_code  = p_accounting_attribute_code
                        AND xaa.event_class_default_flag   = NVL(p_event_class_default_flag,
                                                                 xaa.event_class_default_flag)
                        AND xaa.source_application_id      = p_source_application_id
                        AND xaa.source_type_code           = p_source_type_code
                        AND xaa.source_code                = p_source_code
                        AND xja.application_id             = xaa.application_id
                        AND xja.amb_context_code           = xaa.amb_context_code
                        AND xja.event_class_code           = xaa.event_class_code
                        AND xja.accounting_line_type_code  = xaa.accounting_line_type_code
                        AND xja.accounting_line_code       = xaa.accounting_line_code
                        AND xal.application_id             = xja.application_id
                        AND xal.amb_context_code           = xja.amb_context_code
                        AND xal.event_class_code           = xja.event_class_code
                        AND xal.event_type_code            = xja.event_type_code
                        AND xal.line_definition_owner_code = xja.line_definition_owner_code
                        AND xal.line_definition_code       = xja.line_definition_code
                        AND xal.application_id             = xpr.application_id
                        AND xal.amb_context_code           = xpr.amb_context_code
                        AND xal.product_rule_type_code     = xpr.product_rule_type_code
                        AND xal.product_rule_code          = xpr.product_rule_code);

   END IF;

   x_product_rule_name   := l_product_rule_name;
   x_product_rule_type   := l_product_rule_type;
   x_event_class_name    := l_event_class_name;
   x_event_type_name     := l_event_type_name;
   x_locking_status_flag := l_locking_status_flag;

   xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.uncompile_defn_with_jlt_source'    , 10);

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_evt_class_acct_attrs_pkg.uncompile_defn_with_jlt_source');

END uncompile_defn_with_jlt_source;
/*======================================================================+
|                                                                       |
| PRIVATE FUNCTION                                                      |
|                                                                       |
| uncompile_evt_class_aads                                              |
|                                                                       |
| Uncompile AADs using event CLASS.                                     |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_evt_class_aads
  (p_application_id                  IN NUMBER
  ,p_event_class_code                IN VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2
  ,x_validation_status_code          IN OUT NOCOPY VARCHAR2
  )
RETURN BOOLEAN
IS
  l_log_module             VARCHAR2(240);
  l_return                 BOOLEAN;
  l_application_name       VARCHAR2(240);
  l_product_rule_name      VARCHAR2(80);
  l_product_rule_type      VARCHAR2(80);
  l_event_class_name       VARCHAR2(80);
  l_event_type_name        VARCHAR2(80);
  l_locking_status_flag    VARCHAR2(1);
  l_validation_status_code VARCHAR2(30);


   CURSOR c_lock_aads IS
    SELECT xpa.entity_code
          ,xpa.event_class_code
          ,xpa.event_type_code
          ,xpa.amb_context_code
          ,xpa.product_rule_type_code
          ,xpa.product_rule_code
         , xpa.validation_status_code
         , xpa.locking_status_flag
      FROM xla_prod_acct_headers    xpa
     WHERE xpa.application_id             = p_application_id
       AND xpa.event_class_code           = p_event_class_code
       AND (xpa.locking_status_flag       = 'Y'
          OR xpa.validation_status_code NOT IN ('E', 'Y', 'N'))
       AND ROWNUM = 1;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.uncompile_evt_class_aads';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('uncompile_evt_class_aads.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      -- Print all input parameters
      trace('---------------------------------------------------',C_LEVEL_STATEMENT,l_log_module);
      trace('p_application_id        = ' || p_application_id     ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_event_class_code      = ' || p_event_class_code   ,C_LEVEL_STATEMENT,l_log_module);
      trace('---------------------------------------------------',C_LEVEL_STATEMENT,l_log_module);
   END IF;

   -- Check if any AAD for the event class is locked.
    FOR l_lock_aad IN c_lock_aads LOOP
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace('inside loop',C_LEVEL_STATEMENT,l_log_module);
       END IF;
       xla_validations_pkg.get_product_rule_info
           (p_application_id          => p_application_id
           ,p_amb_context_code        => l_lock_aad.amb_context_code
           ,p_product_rule_type_code  => l_lock_aad.product_rule_type_code
           ,p_product_rule_code       => l_lock_aad.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

       xla_validations_pkg.get_event_class_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_class_name        => l_event_class_name);

       xla_validations_pkg.get_event_type_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_type_code         => l_lock_aad.event_type_code
           ,p_event_type_name         => l_event_type_name);

      x_validation_status_code := l_lock_aad.validation_status_code;
      x_locking_status_flag    := l_lock_aad.locking_status_flag;
      x_product_rule_name   := l_product_rule_name;
      x_product_rule_type   := l_product_rule_type;
      x_event_class_name    := l_event_class_name;
      x_event_type_name     := l_event_type_name;
      l_return := FALSE;
      RETURN(l_return);
   END LOOP;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Updating AAD status.',C_LEVEL_STATEMENT,l_log_module);
   END IF;

   UPDATE xla_prod_acct_headers      pah
      SET validation_status_code     = 'N'
    WHERE pah.application_id         = p_application_id
      AND pah.event_class_code       = p_event_class_code
      AND pah.validation_status_code <> 'N';

   l_return := TRUE;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Number of Application Accounting Defintion Headers updated = ' || SQL%ROWCOUNT,C_LEVEL_STATEMENT,l_Log_module);
   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('uncompile_evt_class_aads.End',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   RETURN(l_return);
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_evt_class_acct_attrs_pkg.uncompile_evt_class_aads');
END uncompile_evt_class_aads;

/*======================================================================+
|                                                                       |
| PRIVATE FUNCTION                                                      |
|                                                                       |
| uncompile_aads                                                        |
|                                                                       |
| Returns TRUE IF ALL THE application accounting definitions AND        |
| journal line definitions using ANY JLTare uncompiled                  |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_aads
  (x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN := TRUE;
   l_exist    VARCHAR2(1);

   l_application_name     VARCHAR2(240) := NULL;
   l_product_rule_name    VARCHAR2(80)  := NULL;
   l_product_rule_type    VARCHAR2(80)  := NULL;
   l_event_class_name     VARCHAR2(80)  := NULL;
   l_event_type_name      VARCHAR2(80)  := NULL;
   l_locking_status_flag  VARCHAR2(1)   := NULL;

   CURSOR c_lock_aads IS
    SELECT xpa.application_id
          ,xpa.amb_context_code
          ,xpa.entity_code
          ,xpa.event_class_code
          ,xpa.event_type_code
          ,xpa.product_rule_type_code
          ,xpa.product_rule_code
         , xpa.validation_status_code
         , xpa.locking_status_flag
      FROM xla_prod_acct_headers    xpa
     WHERE xpa.accounting_required_flag   = 'Y'
     FOR UPDATE NOWAIT;

BEGIN

   xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.uncompile_aads'   , 10);

   l_return := TRUE;

   FOR l_lock_aad IN c_lock_aads LOOP
     IF (l_lock_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
         l_lock_aad.locking_status_flag    = 'Y') THEN

       xla_validations_pkg.get_product_rule_info
           (p_application_id          => l_lock_aad.application_id
           ,p_amb_context_code        => l_lock_aad.amb_context_code
           ,p_product_rule_type_code  => l_lock_aad.product_rule_type_code
           ,p_product_rule_code       => l_lock_aad.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

       xla_validations_pkg.get_event_class_info
           (p_application_id          => l_lock_aad.application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_class_name        => l_event_class_name);

       xla_validations_pkg.get_event_type_info
           (p_application_id          => l_lock_aad.application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_type_code         => l_lock_aad.event_type_code
           ,p_event_type_name         => l_event_type_name);

       l_locking_status_flag := l_lock_aad.locking_status_flag;

       l_return := FALSE;

       EXIT;
     END IF;
   END LOOP;

   IF (l_return) THEN

      UPDATE xla_prod_acct_headers      xpa
         SET validation_status_code     = 'N'
       WHERE xpa.accounting_required_flag   = 'Y';

      UPDATE xla_product_rules_b        xpr
         SET compile_status_code        = 'N'
       WHERE xpr.compile_status_code    <> 'N'
         AND EXISTS (SELECT 'x'
                       FROM xla_prod_acct_headers xal
                      WHERE xal.application_id           = xpr.application_id
                        AND xal.amb_context_code         = xpr.amb_context_code
                        AND xal.product_rule_type_code   = xpr.product_rule_type_code
                        AND xal.product_rule_code        = xpr.product_rule_code
                        AND xal.accounting_required_flag = 'Y');

   END IF;

   x_product_rule_name   := l_product_rule_name;
   x_product_rule_type   := l_product_rule_type;
   x_event_class_name    := l_event_class_name;
   x_event_type_name     := l_event_type_name;
   x_locking_status_flag := l_locking_status_flag;

   xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.uncompile_aads'    , 10);

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_evt_class_acct_attrs_pkg.uncompile_aads');

END uncompile_aads;




/*======================================================================+
|                                                                       |
| PRIVATE FUNCTION                                                      |
|                                                                       |
| uncompile_aads_with_source                                            |
|                                                                       |
| Returns TRUE IF ALL THE application accounting definitions AND        |
| journal line definitions using ANY JLTare uncompiled                  |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_aads_with_source
  (p_source_application_id           IN NUMBER
  ,p_source_code                     IN VARCHAR2
  ,p_source_type_code                IN VARCHAR2
  ,p_event_class_default_flag        IN VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN := TRUE;
   l_exist    VARCHAR2(1);

   l_application_name     VARCHAR2(240) := NULL;
   l_product_rule_name    VARCHAR2(80)  := NULL;
   l_product_rule_type    VARCHAR2(80)  := NULL;
   l_event_class_name     VARCHAR2(80)  := NULL;
   l_event_type_name      VARCHAR2(80)  := NULL;
   l_locking_status_flag  VARCHAR2(1)   := NULL;

   CURSOR c_lock_aads IS
    SELECT xpa.entity_code
          ,xpa.event_class_code
          ,xpa.event_type_code
          ,xpa.application_id
          ,xpa.amb_context_code
          ,xpa.product_rule_type_code
          ,xpa.product_rule_code
         , xpa.validation_status_code
         , xpa.locking_status_flag
      FROM xla_prod_acct_headers    xpa
         , xla_aad_hdr_acct_attrs   xah
     WHERE xpa.application_id            = xah.application_id
       AND xpa.amb_context_code          = xah.amb_context_code
       AND xpa.product_rule_type_code    = xah.product_rule_type_code
       AND xpa.product_rule_code         = xah.product_rule_code
       AND xpa.event_class_code          = xah.event_class_code
       AND xpa.event_type_code           = xah.event_type_code
       AND xpa.accounting_required_flag  = 'Y'
       AND xah.event_class_default_flag  = NVL(p_event_class_default_flag,
                                               xah.event_class_default_flag)
       AND xah.source_application_id     = p_source_application_id
       AND xah.source_type_code          = p_source_type_code
       AND xah.source_code               = p_source_code
     FOR UPDATE NOWAIT;

BEGIN

   xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.uncompile_aads_with_source'   , 10);

   l_return := TRUE;

   FOR l_lock_aad IN c_lock_aads LOOP
     IF (l_lock_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
         l_lock_aad.locking_status_flag    = 'Y') THEN

       xla_validations_pkg.get_product_rule_info
           (p_application_id          => l_lock_aad.application_id
           ,p_amb_context_code        => l_lock_aad.amb_context_code
           ,p_product_rule_type_code  => l_lock_aad.product_rule_type_code
           ,p_product_rule_code       => l_lock_aad.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

       xla_validations_pkg.get_event_class_info
           (p_application_id          => l_lock_aad.application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_class_name        => l_event_class_name);

       xla_validations_pkg.get_event_type_info
           (p_application_id          => l_lock_aad.application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_type_code         => l_lock_aad.event_type_code
           ,p_event_type_name         => l_event_type_name);

       l_locking_status_flag := l_lock_aad.locking_status_flag;

       l_return := FALSE;

       EXIT;
     END IF;
   END LOOP;

   IF (l_return) THEN

      UPDATE xla_prod_acct_headers      xpa
         SET validation_status_code     = 'N'
       WHERE xpa.accounting_required_flag  = 'Y'
         AND EXISTS (SELECT 'X'
                       FROM xla_aad_hdr_acct_attrs xah
                      WHERE xpa.application_id            = xah.application_id
                        AND xpa.amb_context_code          = xah.amb_context_code
                        AND xpa.product_rule_type_code    = xah.product_rule_type_code
                        AND xpa.product_rule_code         = xah.product_rule_code
                        AND xpa.event_class_code          = xah.event_class_code
                        AND xpa.event_type_code           = xah.event_type_code
                        AND xah.event_class_default_flag  = NVL(p_event_class_default_flag,
                                                                xah.event_class_default_flag)
                        AND xah.source_application_id     = p_source_application_id
                        AND xah.source_type_code          = p_source_type_code
                        AND xah.source_code               = p_source_code);

      UPDATE xla_product_rules_b        xpr
         SET compile_status_code        = 'N'
       WHERE xpr.compile_status_code    <> 'N'
         AND EXISTS (SELECT 'x'
                       FROM xla_prod_acct_headers  xpa
                          , xla_aad_hdr_acct_attrs xah
                      WHERE xpa.application_id           = xpr.application_id
                        AND xpa.amb_context_code         = xpr.amb_context_code
                        AND xpa.product_rule_type_code   = xpr.product_rule_type_code
                        AND xpa.product_rule_code        = xpr.product_rule_code
                        AND xpa.accounting_required_flag = 'Y'
                        AND xpa.application_id            = xah.application_id
                        AND xpa.amb_context_code          = xah.amb_context_code
                        AND xpa.product_rule_type_code    = xah.product_rule_type_code
                        AND xpa.product_rule_code         = xah.product_rule_code
                        AND xpa.event_class_code          = xah.event_class_code
                        AND xpa.event_type_code           = xah.event_type_code
                        AND xah.event_class_default_flag  = NVL(p_event_class_default_flag,
                                                                xah.event_class_default_flag)
                        AND xah.source_application_id     = p_source_application_id
                        AND xah.source_type_code          = p_source_type_code
                        AND xah.source_code               = p_source_code);

   END IF;

   x_product_rule_name   := l_product_rule_name;
   x_product_rule_type   := l_product_rule_type;
   x_event_class_name    := l_event_class_name;
   x_event_type_name     := l_event_type_name;
   x_locking_status_flag := l_locking_status_flag;

   xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.uncompile_aads_with_source'    , 10);

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_evt_class_acct_attrs_pkg.uncompile_aads_with_source');

END uncompile_aads_with_source;



/*======================================================================+
|                                                                       |
| PUBLIC FUNCTION                                                       |
|                                                                       |
| insert_jlt_assignments                                                |
|                                                                       |
| Inserts accounting accounting ATTRIBUTES                              |
| IN THE line TYPES FOR THE event CLASS                                 |
|                                                                       |
+======================================================================*/
FUNCTION insert_jlt_assignments
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_default_flag                     IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,p_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,p_event_type_name                  IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS

   -- Array Declaration
   l_arr_amb_context_code         t_array_codes;
   l_arr_acct_line_type_code      t_array_type_codes;
   l_arr_acct_line_code           t_array_codes;

   l_arr_p_amb_context_code         t_array_codes;
   l_arr_p_acct_line_type_code      t_array_type_codes;
   l_arr_p_acct_line_code           t_array_codes;

   --
   -- Private variables
   --
   l_exist                 VARCHAR2(1);
   l_return                BOOLEAN  := TRUE;
   l_application_name      VARCHAR2(240);
   l_product_rule_name     VARCHAR2(80);
   l_product_rule_type     VARCHAR2(80);
   l_event_class_name      VARCHAR2(80);
   l_event_type_name       VARCHAR2(80);
   l_locking_status_flag   VARCHAR2(80);
   l_inherited_flag        VARCHAR2(1);

   --
   -- Cursor declarations
   --

   CURSOR c_inherited_acct_attr
   IS
   SELECT inherited_flag
     FROM xla_acct_attributes_b
    WHERE accounting_attribute_code = p_accounting_attribute_code;

   CURSOR c_jlt_assgn_exist
   IS
   SELECT 'x'
     FROM xla_jlt_acct_attrs
    WHERE application_id            = p_application_id
      AND event_class_code          = p_event_class_code
      AND accounting_attribute_code = p_accounting_attribute_code;

   CURSOR c_class_line_types
   IS
   SELECT amb_context_code, accounting_line_type_code, accounting_line_code
     FROM xla_acct_line_types_b
    WHERE application_id   = p_application_id
      AND event_class_code = p_event_class_code;

   CURSOR c_class_line_types_nogain
   IS
   SELECT amb_context_code, accounting_line_type_code, accounting_line_code
     FROM xla_acct_line_types_b
    WHERE application_id   = p_application_id
      AND event_class_code = p_event_class_code
      AND natural_side_code <> 'G';


   CURSOR c_prior_entry_line_types
   IS
   SELECT amb_context_code, accounting_line_type_code, accounting_line_code
     FROM xla_acct_line_types_b b
    WHERE application_id   = p_application_id
      AND event_class_code = p_event_class_code
      AND business_method_code = 'PRIOR_ENTRY'
      AND EXISTS (SELECT 'x'
                    FROM xla_jlt_acct_attrs a
                   WHERE a.application_id = b.application_id
                     AND a.event_class_code = b.event_class_code
                     AND a.amb_context_code = b.amb_context_code
                     AND a.accounting_line_type_code = b.accounting_line_type_code
                     AND a.accounting_line_code      = b.accounting_line_code
                     AND a.accounting_attribute_code = p_accounting_attribute_code
                     AND a.source_code               IS NOT NULL);

   l_prior_entry_line_types  c_prior_entry_line_types%ROWTYPE;

BEGIN
   xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.insert_jlt_assignments'                       , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code         = '||p_event_class_code     , 20);


   IF p_default_flag = 'Y' THEN

      OPEN c_jlt_assgn_exist;
      FETCH c_jlt_assgn_exist INTO l_exist;

      IF c_jlt_assgn_exist%NOTFOUND THEN

         IF p_accounting_attribute_code IN
                                     ('ENTERED_CURRENCY_AMOUNT'
                                     ,'ENTERED_CURRENCY_CODE'
                                     ,'EXCHANGE_RATE_TYPE'
                                     ,'EXCHANGE_DATE'
                                     ,'EXCHANGE_RATE'
                                      ) THEN
           -- Insert assignments for All JLTs for the event class
           -- with default source mapping and natural side code is not
           -- gain or loss
           OPEN c_class_line_types_nogain;
           FETCH c_class_line_types_nogain
           BULK COLLECT INTO l_arr_amb_context_code
                           , l_arr_acct_line_type_code
                           , l_arr_acct_line_code;
           CLOSE c_class_line_types_nogain;
         ELSE
           -- Insert assignments for All JLTs for the event class
           -- with default source mapping
           OPEN c_class_line_types;
           FETCH c_class_line_types
           BULK COLLECT INTO l_arr_amb_context_code
                           , l_arr_acct_line_type_code
                           , l_arr_acct_line_code;
           CLOSE c_class_line_types;
         END IF;

         IF l_arr_acct_line_code.COUNT > 0 THEN
            FORALL i IN l_arr_acct_line_code.FIRST..l_arr_acct_line_code.LAST
               INSERT INTO xla_jlt_acct_attrs
                 (application_id
                 ,amb_context_code
                 ,event_class_code
                 ,accounting_line_type_code
                 ,accounting_line_code
                 ,accounting_attribute_code
                 ,source_application_id
                 ,source_code
                 ,source_type_code
                 ,event_class_default_flag
                 ,creation_date
                 ,created_by
                 ,last_update_date
                 ,last_updated_by
                 ,last_update_login)
               VALUES
                (p_application_id
                ,l_arr_amb_context_code(i)
                ,p_event_class_code
                ,l_arr_acct_line_type_code(i)
                ,l_arr_acct_line_code(i)
                ,p_accounting_attribute_code
                ,p_source_application_id
                ,p_source_code
                ,p_source_type_code
                ,'Y'
                ,g_creation_date
                ,g_created_by
                ,g_last_update_date
                ,g_last_updated_by
                ,g_last_update_login);

         END IF;

         -- Uncompile all AADs having atleast one line assignment
         l_return := uncompile_defn_with_line
                       (p_application_id         => p_application_id
                       ,p_event_class_code       => p_event_class_code
                       ,x_product_rule_type      => l_product_rule_type
                       ,x_product_rule_name      => l_product_rule_name
                       ,x_event_class_name       => l_event_class_name
                       ,x_event_type_name        => l_event_type_name
                       ,x_locking_status_flag    => l_locking_status_flag);

       ELSE

          -- Update default assignments for JLTs
         UPDATE xla_jlt_acct_attrs
            SET source_application_id     = p_source_application_id
               ,source_type_code          = p_source_type_code
               ,source_code               = p_source_code
          WHERE application_id            = p_application_id
            AND event_class_code          = p_event_class_code
            AND accounting_attribute_code = p_accounting_attribute_code
            AND event_class_default_flag  = 'Y';

         -- Uncompile all AADs having atleast one jlt assignment
         l_return := uncompile_defn_with_jlt
                       (p_application_id            => p_application_id
                       ,p_event_class_code          => p_event_class_code
                       ,p_accounting_attribute_code => p_accounting_attribute_code
                       ,x_product_rule_type         => l_product_rule_type
                       ,x_product_rule_name         => l_product_rule_name
                       ,x_event_class_name          => l_event_class_name
                       ,x_event_type_name           => l_event_type_name
                       ,x_locking_status_flag       => l_locking_status_flag);
      END IF;

    ELSIF p_default_flag = 'N' THEN

       OPEN c_jlt_assgn_exist;
       FETCH c_jlt_assgn_exist
          INTO l_exist;

       IF c_jlt_assgn_exist%NOTFOUND THEN

          IF p_accounting_attribute_code IN
                                     ('ENTERED_CURRENCY_AMOUNT'
                                     ,'ENTERED_CURRENCY_CODE'
                                     ,'EXCHANGE_RATE_TYPE'
                                     ,'EXCHANGE_DATE'
                                     ,'EXCHANGE_RATE'
                                      ) THEN
            -- Insert assignments for All JLTs for the event class
            -- with null source mapping and natural side code is not
            -- gain or loss
            OPEN c_class_line_types_nogain;
            FETCH c_class_line_types_nogain
            BULK COLLECT INTO l_arr_amb_context_code
                           , l_arr_acct_line_type_code
                           , l_arr_acct_line_code;
            CLOSE c_class_line_types_nogain;
          ELSE
            -- Insert assignments for All JLTs for the event class
            -- with null source mapping
            OPEN c_class_line_types;
            FETCH c_class_line_types
            BULK COLLECT INTO l_arr_amb_context_code
                            , l_arr_acct_line_type_code
                            , l_arr_acct_line_code;
            CLOSE c_class_line_types;
          END IF;

          IF l_arr_acct_line_code.COUNT > 0 THEN
             FORALL i IN l_arr_acct_line_code.FIRST..l_arr_acct_line_code.LAST
                INSERT INTO xla_jlt_acct_attrs
                 (application_id
                 ,amb_context_code
                 ,event_class_code
                 ,accounting_line_type_code
                 ,accounting_line_code
                 ,accounting_attribute_code
                 ,source_application_id
                 ,source_code
                 ,source_type_code
                 ,event_class_default_flag
                 ,creation_date
                 ,created_by
                 ,last_update_date
                 ,last_updated_by
                 ,last_update_login)
               VALUES
                (p_application_id
                ,l_arr_amb_context_code(i)
                ,p_event_class_code
                ,l_arr_acct_line_type_code(i)
                ,l_arr_acct_line_code(i)
                ,p_accounting_attribute_code
                ,NULL
                ,NULL
                ,NULL
                ,'Y'
                ,g_creation_date
                ,g_created_by
                ,g_last_update_date
                ,g_last_updated_by
                ,g_last_update_login);

          END IF;

       END IF;
       CLOSE c_jlt_assgn_exist;

   END IF;

   OPEN c_inherited_acct_attr;
   FETCH c_inherited_acct_attr
    INTO l_inherited_flag;
   CLOSE c_inherited_acct_attr;

   IF l_inherited_flag = 'Y' THEN
       OPEN c_prior_entry_line_types;
       LOOP
         FETCH c_prior_entry_line_types
          INTO l_prior_entry_line_types;
         EXIT WHEN c_prior_entry_line_types%NOTFOUND;

             -- Update default assignments for JLTs to null for the prior entry JLTs
             UPDATE xla_jlt_acct_attrs
               SET source_application_id     = NULL
                  ,source_type_code          = NULL
                  ,source_code               = NULL
             WHERE application_id            = p_application_id
               AND event_class_code          = p_event_class_code
               AND accounting_attribute_code = p_accounting_attribute_code
               AND amb_context_code          = l_prior_entry_line_types.amb_context_code
               AND accounting_line_type_code = l_prior_entry_line_types.accounting_line_type_code
               AND accounting_line_code      = l_prior_entry_line_types.accounting_line_code;
       END LOOP;
       CLOSE c_prior_entry_line_types;

   END IF;

   xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.insert_jlt_assignments'                       , 10);

   p_product_rule_name     := l_product_rule_name;
   p_product_rule_type     := l_product_rule_type;
   p_event_class_name      := l_event_class_name;
   p_event_type_name       := l_event_type_name;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_evt_class_acct_attrs_pkg.insert_jlt_assignments');

END insert_jlt_assignments;

/*======================================================================+
|                                                                       |
| PUBLIC FUNCTION                                                      |
|                                                                       |
| update_jlt_assignments                                                |
|                                                                       |
| Updates accounting accounting ATTRIBUTES                              |
| IN THE line TYPES FOR THE event CLASS                                 |
|                                                                       |
+======================================================================*/
FUNCTION update_jlt_assignments
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_default_flag                     IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,p_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,p_event_type_name                  IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS

   --
   -- Private variables
   --
   l_exist  VARCHAR2(1);
   l_return                BOOLEAN  := TRUE;
   l_application_name      VARCHAR2(240);
   l_product_rule_name     VARCHAR2(80);
   l_product_rule_type     VARCHAR2(80);
   l_event_class_name     VARCHAR2(80)  := NULL;
   l_event_type_name      VARCHAR2(80)  := NULL;
   l_locking_status_flag  VARCHAR2(1)   := NULL;
   l_inherited_flag       VARCHAR2(1);

   CURSOR c_inherited_acct_attr
   IS
   SELECT inherited_flag
     FROM xla_acct_attributes_b
    WHERE accounting_attribute_code = p_accounting_attribute_code;

   CURSOR c_line_types
   IS
   SELECT amb_context_code, accounting_line_type_code, accounting_line_code
     FROM xla_acct_line_types_b b
    WHERE application_id   = p_application_id
      AND event_class_code = p_event_class_code
      AND EXISTS (SELECT 'x'
                    FROM xla_jlt_acct_attrs a
                   WHERE a.application_id = b.application_id
                     AND a.event_class_code = b.event_class_code
                     AND a.amb_context_code = b.amb_context_code
                     AND a.accounting_line_type_code = b.accounting_line_type_code
                     AND a.accounting_line_code      = b.accounting_line_code
                     AND a.accounting_attribute_code = p_accounting_attribute_code);

   l_line_types  c_line_types%ROWTYPE;

   CURSOR c_non_pe_line_types
   IS
   SELECT amb_context_code, accounting_line_type_code, accounting_line_code
     FROM xla_acct_line_types_b b
    WHERE application_id   = p_application_id
      AND event_class_code = p_event_class_code
      AND business_method_code <> 'PRIOR_ENTRY'
      AND EXISTS (SELECT 'x'
                    FROM xla_jlt_acct_attrs a
                   WHERE a.application_id = b.application_id
                     AND a.event_class_code = b.event_class_code
                     AND a.amb_context_code = b.amb_context_code
                     AND a.accounting_line_type_code = b.accounting_line_type_code
                     AND a.accounting_line_code      = b.accounting_line_code
                     AND a.accounting_attribute_code = p_accounting_attribute_code);

   l_non_pe_line_types  c_non_pe_line_types%ROWTYPE;

BEGIN
  xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.update_jlt_assignments'                       , 10);

  xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
  xla_utility_pkg.trace('entity_code         = '||p_event_class_code     , 20);

  IF p_default_flag = 'Y' THEN

     -- Check if accounting attribute is inherited
     OPEN c_inherited_acct_attr;
     FETCH c_inherited_acct_attr
      INTO l_inherited_flag;
     CLOSE c_inherited_acct_attr;

     IF l_inherited_flag = 'Y' THEN
        OPEN c_non_pe_line_types;
        LOOP
          FETCH c_non_pe_line_types
           INTO l_non_pe_line_types;
          EXIT WHEN c_non_pe_line_types%NOTFOUND;

             -- Update default assignments for JLTs which are not prior entry JLTs
             UPDATE xla_jlt_acct_attrs
               SET source_application_id     = p_source_application_id
                  ,source_type_code          = p_source_type_code
                  ,source_code               = p_source_code
             WHERE application_id            = p_application_id
               AND event_class_code          = p_event_class_code
               AND accounting_attribute_code = p_accounting_attribute_code
               AND event_class_default_flag  = 'Y'
               AND amb_context_code          = l_non_pe_line_types.amb_context_code
               AND accounting_line_type_code = l_non_pe_line_types.accounting_line_type_code
               AND accounting_line_code      = l_non_pe_line_types.accounting_line_code;
       END LOOP;
       CLOSE c_non_pe_line_types;

    ELSE
        OPEN c_line_types;
        LOOP
          FETCH c_line_types
           INTO l_line_types;
          EXIT WHEN c_line_types%NOTFOUND;

             -- Update default assignments for JLTs which are not prior entry JLTs
             UPDATE xla_jlt_acct_attrs
               SET source_application_id     = p_source_application_id
                  ,source_type_code          = p_source_type_code
                  ,source_code               = p_source_code
             WHERE application_id            = p_application_id
               AND event_class_code          = p_event_class_code
               AND accounting_attribute_code = p_accounting_attribute_code
               AND event_class_default_flag  = 'Y'
               AND amb_context_code          = l_line_types.amb_context_code
               AND accounting_line_type_code = l_line_types.accounting_line_type_code
               AND accounting_line_code      = l_line_types.accounting_line_code;
       END LOOP;
       CLOSE c_line_types;
    END IF;

     -- Uncompile all AADs using the JLT

    l_return := uncompile_defn_with_jlt
                       (p_application_id            => p_application_id
                       ,p_event_class_code          => p_event_class_code
                       ,p_accounting_attribute_code => p_accounting_attribute_code
                       ,x_product_rule_type         => l_product_rule_type
                       ,x_product_rule_name         => l_product_rule_name
                       ,x_event_class_name          => l_event_class_name
                       ,x_event_type_name           => l_event_type_name
                       ,x_locking_status_flag       => l_locking_status_flag);

  ELSIF p_default_flag = 'N' THEN

    -- Uncompile all AADs using the JLT

    l_return := uncompile_defn_with_jlt_source
                       (p_application_id            => p_application_id
                       ,p_event_class_code          => p_event_class_code
                       ,p_accounting_attribute_code => p_accounting_attribute_code
                       ,p_source_application_id     => p_source_application_id
                       ,p_source_code               => p_source_code
                       ,p_source_type_code          => p_source_type_code
                       ,p_event_class_default_flag  => 'Y'
                       ,x_product_rule_type         => l_product_rule_type
                       ,x_product_rule_name         => l_product_rule_name
                       ,x_event_class_name          => l_event_class_name
                       ,x_event_type_name           => l_event_type_name
                       ,x_locking_status_flag       => l_locking_status_flag);

    -- Update default assignments for JLTs with the null source mapping
    UPDATE xla_jlt_acct_attrs
       SET source_application_id     = NULL
          ,source_type_code          = NULL
          ,source_code               = NULL
     WHERE application_id            = p_application_id
       AND event_class_code          = p_event_class_code
       AND accounting_attribute_code = p_accounting_attribute_code
       AND event_class_default_flag  = 'Y'
       AND source_application_id     = p_source_application_id
       AND source_type_code          = p_source_type_code
       AND source_code               = p_source_code;

  END IF;

  xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.update_jlt_assignments'                       , 10);

  p_product_rule_name     := l_product_rule_name;
  p_product_rule_type     := l_product_rule_type;
   p_event_class_name      := l_event_class_name;
   p_event_type_name       := l_event_type_name;

  RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_evt_class_acct_attrs_pkg.update_jlt_assignments');

END update_jlt_assignments;

/*======================================================================+
|                                                                       |
| PUBLIC FUNCTION                                                       |
|                                                                       |
| delete_jlt_assignments                                                |
|                                                                       |
| Deletes accounting accounting ATTRIBUTES                              |
| IN THE line TYPES FOR THE event CLASS                                 |
|                                                                       |
+======================================================================*/
FUNCTION delete_jlt_assignments
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,p_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,p_event_type_name                  IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS

   --
   -- Private variables
   --
   l_exist  VARCHAR2(1);
   l_return                BOOLEAN  := TRUE;
   l_application_name      VARCHAR2(240);
   l_product_rule_name     VARCHAR2(80);
   l_product_rule_type     VARCHAR2(80);
   l_event_class_name     VARCHAR2(80)  := NULL;
   l_event_type_name      VARCHAR2(80)  := NULL;
   l_locking_status_flag  VARCHAR2(1)   := NULL;
   l_count                 NUMBER(10);

   --
   -- Cursor declarations
   --

   CURSOR c_last_assignment
   IS
   SELECT count(1)
     FROM xla_evt_class_acct_attrs
    WHERE application_id            = p_application_id
      AND event_class_code          = p_event_class_code
      AND accounting_attribute_code = p_accounting_attribute_code;

BEGIN
   xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.delete_jlt_assignments'                       , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code         = '||p_event_class_code     , 20);

   OPEN c_last_assignment;
   FETCH c_last_assignment
    INTO l_count;

   IF l_count = 1 THEN
      -- it is the last assignment, so delete from JLT

      DELETE
        FROM xla_jlt_acct_attrs
       WHERE application_id            = p_application_id
         AND event_class_code          = p_event_class_code
         AND accounting_attribute_code = p_accounting_attribute_code;

      -- Uncompile all AADs having atleast one line assignment
      l_return := uncompile_defn_with_line
                       (p_application_id         => p_application_id
                       ,p_event_class_code       => p_event_class_code
                       ,x_product_rule_type      => l_product_rule_type
                       ,x_product_rule_name      => l_product_rule_name
                       ,x_event_class_name       => l_event_class_name
                       ,x_event_type_name        => l_event_type_name
                       ,x_locking_status_flag    => l_locking_status_flag);
   ELSE
      -- it is not the last assignment

      -- Uncompile all AADs using the JLT

    l_return := uncompile_defn_with_jlt_source
                       (p_application_id            => p_application_id
                       ,p_event_class_code          => p_event_class_code
                       ,p_accounting_attribute_code => p_accounting_attribute_code
                       ,p_source_application_id     => p_source_application_id
                       ,p_source_code               => p_source_code
                       ,p_source_type_code          => p_source_type_code
                       ,p_event_class_default_flag  => NULL
                       ,x_product_rule_type         => l_product_rule_type
                       ,x_product_rule_name         => l_product_rule_name
                       ,x_event_class_name          => l_event_class_name
                       ,x_event_type_name           => l_event_type_name
                       ,x_locking_status_flag       => l_locking_status_flag);

      -- Update default assignments for JLTs with the null source mapping
      UPDATE xla_jlt_acct_attrs
         SET source_application_id     = NULL
            ,source_type_code          = NULL
            ,source_code               = NULL
       WHERE application_id            = p_application_id
         AND event_class_code          = p_event_class_code
         AND accounting_attribute_code = p_accounting_attribute_code
         AND source_application_id     = p_source_application_id
         AND source_type_code          = p_source_type_code
         AND source_code               = p_source_code;

   END IF;
   CLOSE c_last_assignment;
   xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.delete_jlt_assignments'                       , 10);

   p_product_rule_name     := l_product_rule_name;
   p_product_rule_type     := l_product_rule_type;
   p_event_class_name      := l_event_class_name;
   p_event_type_name       := l_event_type_name;
   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_evt_class_acct_attrs_pkg.delete_jlt_assignments');

END delete_jlt_assignments;

/*======================================================================+
|                                                                       |
| PUBLIC FUNCTION                                                       |
|                                                                       |
| insert_aad_assignments                                                |
|                                                                       |
| Inserts accounting accounting ATTRIBUTES                              |
| IN THE AADs FOR THE event CLASS                                       |
|                                                                       |
+======================================================================*/
FUNCTION insert_aad_assignments
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_default_flag                     IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,p_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,p_event_type_name                  IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS
   -- Array Declaration
   l_arr_amb_context_code         t_array_codes;
   l_arr_product_rule_type_code   t_array_type_codes;
   l_arr_product_rule_code        t_array_codes;
   l_arr_event_type_code          t_array_codes;
   l_application_id               NUMBER(15);
   l_event_class_code             VARCHAR2(30);
   l_validation_status_code VARCHAR2(30);

   --
   -- Private variables
   --
   l_exist                 VARCHAR2(1);
   l_return                BOOLEAN  := TRUE;
   l_application_name      VARCHAR2(240);
   l_product_rule_name     VARCHAR2(80);
   l_product_rule_type     VARCHAR2(80);
   l_event_class_name     VARCHAR2(80)  := NULL;
   l_event_type_name      VARCHAR2(80)  := NULL;
   l_locking_status_flag  VARCHAR2(1)   := NULL;


   --
   -- Cursor declarations
   --

   CURSOR c_aad_assgn_exist
   IS
   SELECT 'x'
     FROM xla_aad_hdr_acct_attrs
    WHERE application_id            = p_application_id
      AND event_class_code          = p_event_class_code
      AND accounting_attribute_code = p_accounting_attribute_code;

   CURSOR c_class_aad
   IS
   SELECT amb_context_code, product_rule_type_code, product_rule_code,
          event_type_code
     FROM xla_prod_acct_headers
    WHERE application_id   = p_application_id
      AND event_class_code = p_event_class_code;

BEGIN
   xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.insert_aad_assignments'                       , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code         = '||p_event_class_code     , 20);

      l_application_id := p_application_id;
      l_event_class_code := p_event_class_code;

      IF p_default_flag = 'Y' THEN

         OPEN c_aad_assgn_exist;
         FETCH c_aad_assgn_exist
          INTO l_exist;

         IF c_aad_assgn_exist%NOTFOUND THEN

            -- Insert assignments for All AADs for the event class
            -- with a source mapping
            OPEN c_class_aad;
            FETCH c_class_aad
            BULK COLLECT INTO l_arr_amb_context_code, l_arr_product_rule_type_code,
                              l_arr_product_rule_code, l_arr_event_type_code;

            IF l_arr_product_rule_code.COUNT > 0 THEN
               FORALL i IN l_arr_product_rule_code.FIRST..l_arr_product_rule_code.LAST
                INSERT INTO xla_aad_hdr_acct_attrs
                 (application_id
                 ,amb_context_code
                 ,product_rule_type_code
                 ,product_rule_code
                 ,event_class_code
                 ,event_type_code
                 ,accounting_attribute_code
                 ,source_application_id
                 ,source_code
                 ,source_type_code
                 ,event_class_default_flag
                 ,creation_date
                 ,created_by
                 ,last_update_date
                 ,last_updated_by
                 ,last_update_login)
               VALUES
                (p_application_id
                ,l_arr_amb_context_code(i)
                ,l_arr_product_rule_type_code(i)
                ,l_arr_product_rule_code(i)
                ,p_event_class_code
                ,l_arr_event_type_code(i)
                ,p_accounting_attribute_code
                ,p_source_application_id
                ,p_source_code
                ,p_source_type_code
                ,'Y'
                ,g_creation_date
                ,g_created_by
                ,g_last_update_date
                ,g_last_updated_by
                ,g_last_update_login);

            END IF;
            CLOSE c_class_aad;

             -- Uncompile all AADs for that event class.
            l_return := uncompile_evt_class_aads
                          (p_application_id         => l_application_id
                          ,p_event_class_code       => l_event_class_code
                          ,x_product_rule_type      => l_product_rule_type
                          ,x_product_rule_name      => l_product_rule_name
                          ,x_event_class_name       => l_event_class_name
                          ,x_event_type_name        => l_event_type_name
                          ,x_locking_status_flag    => l_locking_status_flag
                          ,x_validation_status_code => l_validation_status_code);

         ELSE

            -- Update default assignments for AADs
            UPDATE xla_aad_hdr_acct_attrs
               SET source_application_id     = p_source_application_id
                  ,source_type_code          = p_source_type_code
                  ,source_code               = p_source_code
             WHERE application_id            = p_application_id
               AND event_class_code          = p_event_class_code
               AND accounting_attribute_code = p_accounting_attribute_code
               AND event_class_default_flag  = 'Y';

            -- Uncompile all AADs that have been updated
            l_return := uncompile_evt_class_aads
                          (p_application_id         => l_application_id
                          ,p_event_class_code       => l_event_class_code
                          ,x_product_rule_type      => l_product_rule_type
                          ,x_product_rule_name      => l_product_rule_name
                          ,x_event_class_name       => l_event_class_name
                          ,x_event_type_name        => l_event_type_name
                          ,x_locking_status_flag    => l_locking_status_flag
                          ,x_validation_status_code => l_validation_status_code);

/*         l_return := uncompile_defn_with_default
                       (x_product_rule_type      => l_product_rule_type
                       ,x_product_rule_name      => l_product_rule_name
                       ,x_event_class_name       => l_event_class_name
                       ,x_event_type_name        => l_event_type_name
                       ,x_locking_status_flag    => l_locking_status_flag);   */

         END IF;
         CLOSE c_aad_assgn_exist;

      ELSIF p_default_flag = 'N' THEN

         OPEN c_aad_assgn_exist;
         FETCH c_aad_assgn_exist
          INTO l_exist;

         IF c_aad_assgn_exist%NOTFOUND THEN

            -- Insert assignments for All AADs for the event class
            -- with null source mapping
            OPEN c_class_aad;
            FETCH c_class_aad
            BULK COLLECT INTO l_arr_amb_context_code, l_arr_product_rule_type_code,
                              l_arr_product_rule_code, l_arr_event_type_code;

            IF l_arr_product_rule_code.COUNT > 0 THEN
               FORALL i IN l_arr_product_rule_code.FIRST..l_arr_product_rule_code.LAST
                INSERT INTO xla_aad_hdr_acct_attrs
                 (application_id
                 ,amb_context_code
                 ,product_rule_type_code
                 ,product_rule_code
                 ,event_class_code
                 ,event_type_code
                 ,accounting_attribute_code
                 ,source_application_id
                 ,source_code
                 ,source_type_code
                 ,event_class_default_flag
                 ,creation_date
                 ,created_by
                 ,last_update_date
                 ,last_updated_by
                 ,last_update_login)
               VALUES
                (p_application_id
                ,l_arr_amb_context_code(i)
                ,l_arr_product_rule_type_code(i)
                ,l_arr_product_rule_code(i)
                ,p_event_class_code
                ,l_arr_event_type_code(i)
                ,p_accounting_attribute_code
                ,NULL
                ,NULL
                ,NULL
                ,'Y'
                ,g_creation_date
                ,g_created_by
                ,g_last_update_date
                ,g_last_updated_by
                ,g_last_update_login);

            END IF;
            CLOSE c_class_aad;

         END IF;
         CLOSE c_aad_assgn_exist;

      END IF;

   xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.insert_aad_assignments'                       , 10);

   p_product_rule_name     := l_product_rule_name;
   p_product_rule_type     := l_product_rule_type;
   p_event_class_name      := l_event_class_name;
   p_event_type_name       := l_event_type_name;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_evt_class_acct_attrs_pkg.insert_aad_assignments');

END insert_aad_assignments;

/*======================================================================+
|                                                                       |
| PUBLIC FUNCTION                                                      |
|                                                                       |
| update_aad_assignments                                                |
|                                                                       |
| Updates accounting accounting ATTRIBUTES                              |
| IN THE AADs FOR THE event CLASS                                       |
|                                                                       |
+======================================================================*/
FUNCTION update_aad_assignments
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_default_flag                     IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,p_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,p_event_type_name                  IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS
   --
   -- Private variables
   --
   l_exist  VARCHAR2(1);
   l_return                BOOLEAN  := TRUE;
   l_application_name      VARCHAR2(240);
   l_product_rule_name     VARCHAR2(80);
   l_product_rule_type     VARCHAR2(80);
   l_event_class_name     VARCHAR2(80)  := NULL;
   l_event_type_name      VARCHAR2(80)  := NULL;
   l_locking_status_flag  VARCHAR2(1)   := NULL;

   l_application_id               NUMBER(15);
   l_event_class_code             VARCHAR2(30);
   l_validation_status_code VARCHAR2(30);

BEGIN
   xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.update_aad_assignments'                       , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code         = '||p_event_class_code     , 20);

      l_application_id := p_application_id;
      l_event_class_code := p_event_class_code;

      IF p_default_flag = 'Y' THEN

         -- Update default assignments for AADs with the new source mapping
         UPDATE xla_aad_hdr_acct_attrs
            SET source_application_id     = p_source_application_id
               ,source_type_code          = p_source_type_code
               ,source_code               = p_source_code
          WHERE application_id            = p_application_id
            AND event_class_code          = p_event_class_code
            AND accounting_attribute_code = p_accounting_attribute_code
            AND event_class_default_flag  = 'Y';


            -- Uncompile all AADs that have been updated
            l_return := uncompile_evt_class_aads
                          (p_application_id         => l_application_id
                          ,p_event_class_code       => l_event_class_code
                          ,x_product_rule_type      => l_product_rule_type
                          ,x_product_rule_name      => l_product_rule_name
                          ,x_event_class_name       => l_event_class_name
                          ,x_event_type_name        => l_event_type_name
                          ,x_locking_status_flag    => l_locking_status_flag
                          ,x_validation_status_code => l_validation_status_code);

      ELSIF p_default_flag = 'N' THEN

         -- Uncompile all AADs with default assignment and same source mapping

            -- Uncompile all AADs that have been updated
            l_return := uncompile_evt_class_aads
                          (p_application_id         => l_application_id
                          ,p_event_class_code       => l_event_class_code
                          ,x_product_rule_type      => l_product_rule_type
                          ,x_product_rule_name      => l_product_rule_name
                          ,x_event_class_name       => l_event_class_name
                          ,x_event_type_name        => l_event_type_name
                          ,x_locking_status_flag    => l_locking_status_flag
                          ,x_validation_status_code => l_validation_status_code);

         -- Update default assignments for AADs with the null source mapping
         UPDATE xla_aad_hdr_acct_attrs
            SET source_application_id     = NULL
               ,source_type_code          = NULL
               ,source_code               = NULL
          WHERE application_id            = p_application_id
            AND event_class_code          = p_event_class_code
            AND accounting_attribute_code = p_accounting_attribute_code
            AND event_class_default_flag  = 'Y'
            AND source_application_id     = p_source_application_id
            AND source_type_code          = p_source_type_code
            AND source_code               = p_source_code;

      END IF;

   xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.update_aad_assignments'                       , 10);

   p_product_rule_name     := l_product_rule_name;
   p_product_rule_type     := l_product_rule_type;
   p_event_class_name     := l_event_class_name;
   p_event_type_name     := l_event_type_name;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_evt_class_acct_attrs_pkg.update_aad_assignments');

END update_aad_assignments;

/*======================================================================+
|                                                                       |
| PUBLIC FUNCTION                                                       |
|                                                                       |
| delete_aad_assignments                                                |
|                                                                       |
| Deletes accounting accounting ATTRIBUTES                              |
| IN THE AADs FOR THE event CLASS                                       |
|                                                                       |
+======================================================================*/
FUNCTION delete_aad_assignments
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,p_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,p_event_type_name                  IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS
   --
   -- Private variables
   --
   l_exist  VARCHAR2(1);
   l_return                BOOLEAN  := TRUE;
   l_application_name      VARCHAR2(240);
   l_product_rule_name     VARCHAR2(80);
   l_product_rule_type     VARCHAR2(80);
   l_event_class_name     VARCHAR2(80)  := NULL;
   l_event_type_name      VARCHAR2(80)  := NULL;
   l_locking_status_flag  VARCHAR2(1)   := NULL;
   l_count                 NUMBER(10);

   --
   -- Cursor declarations
   --

   CURSOR c_last_assignment
   IS
   SELECT count(1)
     FROM xla_evt_class_acct_attrs
    WHERE application_id            = p_application_id
      AND event_class_code          = p_event_class_code
      AND accounting_attribute_code = p_accounting_attribute_code;

BEGIN
   xla_utility_pkg.trace('> xla_evt_class_acct_attrs_pkg.delete_aad_assignments'                       , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code         = '||p_event_class_code     , 20);

   OPEN c_last_assignment;
   FETCH c_last_assignment
    INTO l_count;

   IF l_count = 1 THEN
      -- it is the last assignment, so delete from AAD

      DELETE
        FROM xla_aad_hdr_acct_attrs
       WHERE application_id            = p_application_id
         AND event_class_code          = p_event_class_code
         AND accounting_attribute_code = p_accounting_attribute_code;

      -- Uncompile all AADs having create accounting flag 'Y'
      l_return := uncompile_defn_with_line_acct
                       (p_application_id         => p_application_id
                       ,p_event_class_code       => p_event_class_code
                       ,x_product_rule_type      => l_product_rule_type
                       ,x_product_rule_name      => l_product_rule_name
                       ,x_event_class_name       => l_event_class_name
                       ,x_event_type_name        => l_event_type_name
                       ,x_locking_status_flag    => l_locking_status_flag);

   ELSE
      -- it is not the last assignment

      -- Uncompile all AADs having the same source mapping for the
      -- accounting attribute

      l_return := uncompile_aads_with_source
                       (p_source_application_id     => p_source_application_id
                       ,p_source_code               => p_source_code
                       ,p_source_type_code          => p_source_type_code
                       ,p_event_class_default_flag  => NULL
                       ,x_product_rule_type         => l_product_rule_type
                       ,x_product_rule_name         => l_product_rule_name
                       ,x_event_class_name          => l_event_class_name
                       ,x_event_type_name           => l_event_type_name
                       ,x_locking_status_flag       => l_locking_status_flag);

      -- Update assignments for AADs with the null source mapping
      UPDATE xla_aad_hdr_acct_attrs
         SET source_application_id     = NULL
            ,source_type_code          = NULL
            ,source_code               = NULL
       WHERE application_id            = p_application_id
         AND event_class_code          = p_event_class_code
         AND accounting_attribute_code = p_accounting_attribute_code
         AND source_application_id     = p_source_application_id
         AND source_type_code          = p_source_type_code
         AND source_code               = p_source_code;

   END IF;
   CLOSE c_last_assignment;
   xla_utility_pkg.trace('< xla_evt_class_acct_attrs_pkg.delete_aad_assignments'                       , 10);

   p_product_rule_name     := l_product_rule_name;
   p_product_rule_type     := l_product_rule_type;
   p_event_class_name      := l_event_class_name;
   p_event_type_name       := l_event_type_name;
   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_evt_class_acct_attrs_pkg.delete_aad_assignments');

END delete_aad_assignments;
--=============================================================================
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--=============================================================================
BEGIN

g_creation_date      := sysdate;
g_last_update_date   := sysdate;
g_created_by         := xla_environment_pkg.g_usr_id;
g_last_update_login  := xla_environment_pkg.g_login_id;
g_last_updated_by    := xla_environment_pkg.g_usr_id;


g_log_level          := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_log_enabled        := fnd_log.test
                       (log_level  => g_log_level
                       ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;
END xla_evt_class_acct_attrs_pkg;

/
