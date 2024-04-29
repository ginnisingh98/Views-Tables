--------------------------------------------------------
--  DDL for Package Body XLA_AMB_AAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AMB_AAD_PKG" AS
/* $Header: xlaamaad.pkb 120.27 2006/05/09 21:42:05 wychan ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_amb_aad_pkg                                                    |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Application Accounting Definition Validations Package          |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring private package variables
-------------------------------------------------------------------------------
g_creation_date                   DATE;
g_last_update_date                DATE;
g_created_by                      INTEGER;
g_last_update_login               INTEGER;
g_last_updated_by                 INTEGER;

-------------------------------------------------------------------------------
-- declaring private package arrays
-------------------------------------------------------------------------------
TYPE t_array_codes         IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_array_type_codes    IS TABLE OF VARCHAR2(1)  INDEX BY BINARY_INTEGER;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_amb_aad_pkg';

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
      (p_location   => 'xla_amb_aad_pkg.trace');
END trace;

--=============================================================================
--
--
--
--
--          *********** private procedures and functions **********
--
--
--
--
--=============================================================================

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| is_reversal                                                           |
|                                                                       |
| Returns true if accounting reversal or transaction reversal sources   |
| are assigned to the event class                                       |
|                                                                       |
+======================================================================*/

FUNCTION is_reversal
  (p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2)
RETURN BOOLEAN
IS

   l_return                  BOOLEAN := TRUE;
   l_exist                   VARCHAR2(1);

   -- Check if the accounting reversal option is set for the event class
   CURSOR c_event_sources
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs e
    WHERE e.application_id            = p_application_id
      AND e.event_class_code          = p_event_class_code
      AND e.accounting_attribute_code IN ('ACCOUNTING_REVERSAL_OPTION','TRX_ACCT_REVERSAL_OPTION');

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.is_reversal';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure is_reversal'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',entity_code = '||p_entity_code||
                      ',event_class_code = '||p_event_class_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Check if the accounting reversal option is set for the event class
  OPEN c_event_sources;
  FETCH c_event_sources INTO l_exist;
  IF c_event_sources%found then
    l_return := TRUE;
  ELSE
    l_return := FALSE;
  END IF;
  CLOSE c_event_sources;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure - return: '
                      ||case when l_return then 'TRUE' else 'FALSE' end
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_amb_aad_pkg.is_reversal');

END is_reversal;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| chk_hdr_accting_sources                                               |
|                                                                       |
| Returns false if header accounting sources are invalid                |
|                                                                       |
+======================================================================*/

FUNCTION chk_hdr_accting_sources
          (p_application_id              IN  NUMBER
          ,p_amb_context_code            IN  VARCHAR2
          ,p_product_rule_type_code      IN  VARCHAR2
          ,p_product_rule_code           IN  VARCHAR2
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2
          ,p_event_type_code             IN  VARCHAR2)
RETURN BOOLEAN
IS
  l_return                     BOOLEAN;
  l_exist                      VARCHAR2(1);
  l_accounting_attribute_code  VARCHAR2(30);

   -- Get all required accounting attributes that are not mapped to the event class

   CURSOR c_reqd_acct_attr
   IS
   SELECT a.accounting_attribute_code
     FROM xla_acct_attributes_b a
    WHERE a.assignment_required_code   = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_evt_class_acct_attrs e
                       WHERE e.application_id             = p_application_id
                         AND e.event_class_code           = p_event_class_code
                         AND e.accounting_attribute_code  = a.accounting_attribute_code
                         AND e.default_flag               = 'Y');

   l_reqd_acct_attr    c_reqd_acct_attr%rowtype;

   -- Get all accounting groups that have accounting attributes
   -- mapped for the event class
   CURSOR c_mapping_group
   IS
   SELECT distinct a.assignment_group_code
     FROM xla_acct_attributes_b a
    WHERE assignment_group_code is NOT NULL
      AND EXISTS (SELECT 'x'
                    FROM xla_evt_class_acct_attrs e
                   WHERE e.application_id             = p_application_id
                     AND e.event_class_code           = p_event_class_code
                     AND e.accounting_attribute_code  = a.accounting_attribute_code
                     AND e.default_flag               = 'Y');

   --l_mapping_group    c_mapping_group%rowtype;

   -- Get all required accounting attributes for the above group
   -- which have not been mapped to the event class
   CURSOR c_accting_sources (p_assignment_group_code VARCHAR2)
   IS
   SELECT accounting_attribute_code
     FROM xla_acct_attributes_b s
    WHERE assignment_required_code    = 'G'
      AND assignment_group_code       = p_assignment_group_code
      AND not exists (SELECT 'x'
                        FROM xla_evt_class_acct_attrs e
                       WHERE e.application_id             = p_application_id
                         AND e.event_class_code           = p_event_class_code
                         AND e.accounting_attribute_code  = s.accounting_attribute_code
                         AND e.default_flag               = 'Y');

   l_accting_sources    c_accting_sources%rowtype;

   -- Check if event class has budget or encumbrance enabled
   CURSOR c_ec_attrs
   IS
   SELECT allow_budgets_flag, allow_encumbrance_flag
     FROM xla_event_class_attrs e
    WHERE e.application_id              = p_application_id
      AND e.entity_code                 = p_entity_code
      AND e.event_class_code            = p_event_class_code;

   l_ec_attrs   c_ec_attrs%rowtype;

   -- Check if event class has budget version id accounting attribute mapped
   CURSOR c_budget
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs e
    WHERE e.application_id              = p_application_id
      AND e.event_class_code            = p_event_class_code
      AND e.accounting_attribute_code   = 'BUDGET_VERSION_ID'
      AND e.default_flag = 'Y';

   -- Check if event class has encumbrance type id accounting attribute mapped
/*4458381
   CURSOR c_enc
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs e
    WHERE e.application_id              = p_application_id
      AND e.event_class_code            = p_event_class_code
      AND e.accounting_attribute_code   = 'ENCUMBRANCE_TYPE_ID'
      AND e.default_flag = 'Y';
*/

   -- Check if reversed distribution id 2 is mapped for the event class
   CURSOR c_rev_dist_2
   IS
   SELECT a.accounting_attribute_code, a.assignment_group_code
     FROM xla_evt_class_acct_attrs_fvl a
    WHERE a.application_id               = p_application_id
      AND a.event_class_code             = p_event_class_code
      AND a.accounting_attribute_code    = 'REVERSED_DISTRIBUTION_ID2'
      AND default_flag                   = 'Y';

   l_rev_dist_2    c_rev_dist_2%rowtype;

   -- Check if distribution id 2 is mapped for the event class
   CURSOR c_dist_2
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'DISTRIBUTION_IDENTIFIER_2'
      AND default_flag                = 'Y';

   -- Check if reversed distribution id 3 is mapped for the event class
   CURSOR c_rev_dist_3
   IS
   SELECT a.accounting_attribute_code, a.assignment_group_code
     FROM xla_evt_class_acct_attrs_fvl a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'REVERSED_DISTRIBUTION_ID3'
      AND default_flag                = 'Y';

   l_rev_dist_3    c_rev_dist_3%rowtype;

   -- Check if distribution id 3 is mapped for the event class
   CURSOR c_dist_3
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'DISTRIBUTION_IDENTIFIER_3'
      AND a.default_flag              = 'Y';

   -- Check if reversed distribution id 4 is mapped for the event class
   CURSOR c_rev_dist_4
   IS
   SELECT a.accounting_attribute_code, a.assignment_group_code
     FROM xla_evt_class_acct_attrs_fvl a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'REVERSED_DISTRIBUTION_ID4'
      AND default_flag                = 'Y';

   l_rev_dist_4    c_rev_dist_4%rowtype;

   -- Check if distribution id 4 is mapped for the event class
   CURSOR c_dist_4
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'DISTRIBUTION_IDENTIFIER_4'
      AND default_flag                = 'Y';

   -- Check if reversed distribution id 5 is mapped for the event class
   CURSOR c_rev_dist_5
   IS
   SELECT a.accounting_attribute_code, a.assignment_group_code
     FROM xla_evt_class_acct_attrs_fvl a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'REVERSED_DISTRIBUTION_ID5'
      AND a.default_flag              = 'Y';

   l_rev_dist_5    c_rev_dist_5%rowtype;

   -- Check if distribution id 5 is mapped for the event class
   CURSOR c_dist_5
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'DISTRIBUTION_IDENTIFIER_5'
      AND a.default_flag              = 'Y';

   -- Get all accounting attributes assignments that have sources that are
   -- not mapped to the event class

   CURSOR c_sources
   IS
   SELECT s.accounting_attribute_code, s.source_application_id,
          s.source_type_code, s.source_code
     FROM xla_evt_class_acct_attrs s
    WHERE s.application_id        = p_application_id
      AND s.event_class_code      = p_event_class_code
      AND s.source_application_id = p_application_id
      AND s.source_type_code      = 'S'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_event_sources e
                       WHERE e.application_id             = s.application_id
                         AND e.event_class_code           = s.event_class_code
                         AND e.source_application_id      = s.source_application_id
                         AND e.source_type_code           = s.source_type_code
                         AND e.source_code                = s.source_code
                         AND e.active_flag                = 'Y');

   l_sources    c_sources%rowtype;

   -- Get all accounting attributes assignments that have derived sources that are
   -- not mapped to the event class

   CURSOR c_der_sources
   IS
   SELECT s.accounting_attribute_code, s.source_application_id,
          s.source_type_code, s.source_code
     FROM xla_evt_class_acct_attrs s
    WHERE s.application_id        = p_application_id
      AND s.event_class_code      = p_event_class_code
      AND s.source_application_id = p_application_id
      AND s.source_type_code      = 'D';

   l_der_sources    c_der_sources%rowtype;

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_hdr_accting_sources';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_hdr_accting_sources'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',entity_code = '||p_entity_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',product_rule_type_code = '||p_product_rule_type_code||
                      ',product_rule_code = '||p_product_rule_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;
  l_exist  := NULL;

  -- Check if every event class has all required accounting
  -- attributes mapped to a default source
  FOR l_reqd_acct_attr IN c_reqd_acct_attr LOOP
    xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_EC_REQUIRED_SOURCE'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => p_entity_code
              ,p_event_class_code          => p_event_class_code
              ,p_accounting_source_code    => l_reqd_acct_attr.accounting_attribute_code);

    l_return := FALSE;
  END LOOP;

  -- Check if every event class has either all or none of the accounting
  -- attributes that have a group code
  FOR l_mapping_group IN c_mapping_group LOOP

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'Loop c_mapping_group: assignment_group_code = '||l_mapping_group.assignment_group_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
    END IF;

    FOR l_accting_sources IN c_accting_sources (l_mapping_group.assignment_group_code) LOOP

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace(p_msg    => 'Loop c_accting_sources: accounting_attribute_code = '||l_accting_sources.accounting_attribute_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
      END IF;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_EC_GROUP_SOURCE'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => p_entity_code
              ,p_event_class_code          => p_event_class_code
              ,p_accounting_group_code     => l_mapping_group.assignment_group_code
              ,p_accounting_source_code    => l_accting_sources.accounting_attribute_code);

      l_return := FALSE;
    END LOOP;
  END LOOP;

  -- Get budget and encumbrance flag for the event class
   OPEN c_ec_attrs;
   FETCH c_ec_attrs
    INTO l_ec_attrs;

       IF l_ec_attrs.allow_budgets_flag = 'Y' THEN

          -- Check if Budget Version Identifier is mapped for the
          -- event class
          OPEN c_budget;
          FETCH c_budget
           INTO l_exist;
          IF c_budget%NOTFOUND THEN
             Xla_amb_setup_err_pkg.stack_error
                  (p_message_name             => 'XLA_AB_EC_BUDGET_ACCTG_SRC'
                  ,p_message_type             => 'E'
                  ,p_message_category         => 'ACCOUNTING_SOURCE'
                  ,p_category_sequence        => 5
                  ,p_application_id           => p_application_id
                  ,p_amb_context_code         => p_amb_context_code
                  ,p_product_rule_type_code   => p_product_rule_type_code
                  ,p_product_rule_code        => p_product_rule_code
                  ,p_entity_code              => p_entity_code
                  ,p_event_class_code         => p_event_class_code
                  ,p_accounting_source_code   => 'BUDGET_VERSION_ID');

             l_return := FALSE;
          END IF;
          CLOSE c_budget;
       END IF;

/* 4458381
       IF l_ec_attrs.allow_encumbrance_flag = 'Y' THEN

          -- Check if Encumbrance Type Identifier is mapped for the
          -- event class
          OPEN c_enc;
          FETCH c_enc
           INTO l_exist;
          IF c_enc%NOTFOUND THEN
             Xla_amb_setup_err_pkg.stack_error
                  (p_message_name             => 'XLA_AB_EC_ENC_ACCTG_SRC'
                  ,p_message_type             => 'E'
                  ,p_message_category         => 'ACCOUNTING_SOURCE'
                  ,p_category_sequence        => 5
                  ,p_application_id           => p_application_id
                  ,p_amb_context_code         => p_amb_context_code
                  ,p_product_rule_type_code   => p_product_rule_type_code
                  ,p_product_rule_code        => p_product_rule_code
                  ,p_entity_code              => p_entity_code
                  ,p_event_class_code         => p_event_class_code
                  ,p_accounting_source_code   => 'ENCUMBRANCE_TYPE_ID');

             l_return := FALSE;
          END IF;
          CLOSE c_enc;
   END IF;
   CLOSE c_ec_attrs;
*/

   --
   -- Check if reversed distribution ids are mapped for a line type
   -- then the corresponding distribution ids are also mapped
   --
   OPEN c_rev_dist_2;
   FETCH c_rev_dist_2
    INTO l_rev_dist_2;
   IF c_rev_dist_2%found THEN

         OPEN c_dist_2;
         FETCH c_dist_2
          INTO l_exist;
         IF c_dist_2%notfound THEN

            Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_LT_ACCT_REV_DIST_ID'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => p_entity_code
              ,p_event_class_code          => p_event_class_code
              ,p_accounting_source_code    => l_rev_dist_2.accounting_attribute_code
              ,p_accounting_group_code     => l_rev_dist_2.assignment_group_code);

            l_return := FALSE;
         END IF;
         CLOSE c_dist_2;
   END IF;
   CLOSE c_rev_dist_2;

   OPEN c_rev_dist_3;
   FETCH c_rev_dist_3
    INTO l_rev_dist_3;
   IF c_rev_dist_3%found THEN

         OPEN c_dist_3;
         FETCH c_dist_3
          INTO l_exist;
         IF c_dist_3%notfound THEN

            Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_LT_ACCT_REV_DIST_ID'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => p_entity_code
              ,p_event_class_code          => p_event_class_code
              ,p_accounting_source_code    => l_rev_dist_3.accounting_attribute_code
              ,p_accounting_group_code     => l_rev_dist_3.assignment_group_code);

            l_return := FALSE;
         END IF;
         CLOSE c_dist_3;
   END IF;
   CLOSE c_rev_dist_3;

   OPEN c_rev_dist_4;
   FETCH c_rev_dist_4
    INTO l_rev_dist_4;
   IF c_rev_dist_4%found THEN

         OPEN c_dist_4;
         FETCH c_dist_4
          INTO l_exist;
         IF c_dist_4%notfound THEN

            Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_LT_ACCT_REV_DIST_ID'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => p_entity_code
              ,p_event_class_code          => p_event_class_code
              ,p_accounting_source_code    => l_rev_dist_4.accounting_attribute_code
              ,p_accounting_group_code     => l_rev_dist_4.assignment_group_code);

            l_return := FALSE;
         END IF;
         CLOSE c_dist_4;
   END IF;
   CLOSE c_rev_dist_4;

   OPEN c_rev_dist_5;
   FETCH c_rev_dist_5
    INTO l_rev_dist_5;
   IF c_rev_dist_5%found THEN

         OPEN c_dist_5;
         FETCH c_dist_5
          INTO l_exist;
         IF c_dist_5%notfound THEN

            Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_LT_ACCT_REV_DIST_ID'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => p_entity_code
              ,p_event_class_code          => p_event_class_code
              ,p_accounting_source_code    => l_rev_dist_5.accounting_attribute_code
              ,p_accounting_group_code     => l_rev_dist_5.assignment_group_code);

            l_return := FALSE;
         END IF;
         CLOSE c_dist_5;
   END IF;
   CLOSE c_rev_dist_5;

   -- check accounting attribute assignments that have derived sources
   -- that do not belong to the event class
   OPEN c_sources;
   LOOP
      FETCH c_sources
       INTO l_sources;
      EXIT WHEN c_sources%notfound;

            Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_INVALID_ACCT_ATTR_SRCE' -- new message?
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => p_entity_code
              ,p_event_class_code          => p_event_class_code
              ,p_accounting_source_code    => l_sources.accounting_attribute_code
              ,p_source_type_code          => l_sources.source_type_code
              ,p_source_code               => l_sources.source_code);

            l_return := FALSE;

   END LOOP;
   CLOSE c_sources;

      -- check accounting attribute assignments that have derived sources
      -- that do not belong to the event class
      OPEN c_der_sources;
      LOOP
         FETCH c_der_sources
          INTO l_der_sources;
         EXIT WHEN c_der_sources%notfound;

         IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_der_sources.source_code
              ,p_derived_source_type_code => 'D'
              ,p_entity_code              => p_entity_code
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L')  = 'TRUE' THEN

            Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_INVALID_ACCT_ATTR_SRCE'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => p_entity_code
              ,p_event_class_code          => p_event_class_code
              ,p_accounting_source_code    => l_der_sources.accounting_attribute_code
              ,p_source_type_code          => l_der_sources.source_type_code
              ,p_source_code               => l_der_sources.source_code);

           l_return := FALSE;
         END IF;
      END LOOP;
      CLOSE c_der_sources;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure - return: '
                      ||case when l_return then 'TRUE' else 'FALSE' end
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_amb_aad_pkg.chk_hdr_accting_sources');

END chk_hdr_accting_sources;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| chk_descriptions_are_valid                                            |
|                                                                       |
| Returns false if header or line descriptions are invalid              |
|                                                                       |
+======================================================================*/
FUNCTION chk_descriptions_are_valid
  (p_application_id              IN  NUMBER
  ,p_amb_context_code            IN  VARCHAR2
  ,p_product_rule_type_code      IN  VARCHAR2
  ,p_product_rule_code           IN  VARCHAR2
  ,p_err_count                   IN OUT NOCOPY INTEGER
  ,p_inv_event_class_codes       IN OUT NOCOPY t_array_codes)
RETURN BOOLEAN
IS

  -- Get all disabled header descriptions for the AAD
  CURSOR c_enabled_hdr_desc IS
   SELECT distinct d.entity_code, d.event_class_code, d.event_type_code,
          d.description_type_code, d.description_code
     FROM xla_prod_acct_headers d
    WHERE d.application_id            = p_application_id
      AND d.amb_context_code          = p_amb_context_code
      AND d.product_rule_type_code    = p_product_rule_type_code
      AND d.product_rule_code         = p_product_rule_code
      AND d.description_type_code     IS NOT NULL
      AND d.accounting_required_flag  = 'Y'
      AND d.validation_status_code    = 'R'
      AND NOT EXISTS (SELECT 'y'
                        FROM xla_descriptions_b s
                       WHERE s.application_id              = d.application_id
                         AND s.amb_context_code            = d.amb_context_code
                         AND s.description_type_code       = d.description_type_code
                         AND s.description_code            = d.description_code
                         AND s.enabled_flag                = 'Y');

  -- Get all header descriptions for the AAD that have seeded sources in their
  -- details which do not belong to the event class
  CURSOR c_hdr_desc_detail_sources IS
   SELECT distinct l.entity_code, l.event_class_code, l.event_type_code,
          l.description_type_code, l.description_code, d.source_type_code, d.source_code
     FROM xla_descript_details_b d, xla_desc_priorities p, xla_prod_acct_headers l
    WHERE d.description_prio_id       = p.description_prio_id
      AND p.application_id            = l.application_id
      AND p.amb_context_code          = l.amb_context_code
      AND p.description_type_code     = l.description_type_code
      AND p.description_code          = l.description_code
      AND l.application_id            = p_application_id
      AND l.amb_context_code          = p_amb_context_code
      AND l.product_rule_type_code    = p_product_rule_type_code
      AND l.product_rule_code         = p_product_rule_code
      AND l.accounting_required_flag  = 'Y'
      AND l.validation_status_code    = 'R'
      AND d.source_type_code          = 'S'
      AND NOT EXISTS (SELECT 'y'
                        FROM xla_event_sources s
                       WHERE s.source_application_id = d.source_application_id
                         AND s.source_type_code      = d.source_type_code
                         AND s.source_code           = d.source_code
                         AND s.application_id        = l.application_id
                         AND s.entity_code           = l.entity_code
                         AND s.event_class_code      = l.event_class_code
                         AND s.active_flag           = 'Y'
                         AND s.level_code            = 'H');

  -- Get all header descriptions for the AAD that have seeded sources in their
  -- conditions which do not belong to the event class
  CURSOR c_hdr_desc_con_sources IS
   SELECT distinct l.entity_code, l.event_class_code, l.event_type_code,
          l.description_type_code, l.description_code,
          c.source_type_code source_type_code, c.source_code source_code
     FROM xla_conditions c, xla_desc_priorities p, xla_prod_acct_headers l
    WHERE c.description_prio_id   = p.description_prio_id
      AND p.application_id        = l.application_id
      AND p.amb_context_code      = l.amb_context_code
      AND p.description_type_code = l.description_type_code
      AND p.description_code      = l.description_code
      AND l.application_id        = p_application_id
      AND l.amb_context_code      = p_amb_context_code
      AND l.product_rule_type_code= p_product_rule_type_code
      AND l.product_rule_code     = p_product_rule_code
      AND l.accounting_required_flag  = 'Y'
      AND l.validation_status_code    = 'R'
      AND c.source_type_code      = 'S'
      AND NOT EXISTS (SELECT 'y'
                        FROM xla_event_sources s
                       WHERE s.source_application_id = c.source_application_id
                         AND s.source_type_code      = c.source_type_code
                         AND s.source_code           = c.source_code
                         AND s.application_id        = l.application_id
                         AND s.entity_code           = l.entity_code
                         AND s.event_class_code      = l.event_class_code
                         AND s.active_flag          = 'Y'
                         AND s.level_code            = 'H')
   UNION
   SELECT distinct l.entity_code, l.event_class_code, l.event_type_code,
          l.description_type_code, l.description_code,
          c.value_source_type_code source_type_code, c.value_source_code source_code
     FROM xla_conditions c, xla_desc_priorities p, xla_prod_acct_headers l
    WHERE c.description_prio_id   = p.description_prio_id
      AND p.application_id        = l.application_id
      AND p.amb_context_code      = l.amb_context_code
      AND p.description_type_code = l.description_type_code
      AND p.description_code      = l.description_code
      AND l.application_id        = p_application_id
      AND l.amb_context_code      = p_amb_context_code
      AND l.product_rule_type_code= p_product_rule_type_code
      AND l.product_rule_code     = p_product_rule_code
      AND l.accounting_required_flag  = 'Y'
      AND l.validation_status_code    = 'R'
      AND c.value_source_type_code  = 'S'
      AND NOT EXISTS (SELECT 'y'
                        FROM xla_event_sources s
                       WHERE s.source_application_id = c.value_source_application_id
                         AND s.source_type_code      = c.value_source_type_code
                         AND s.source_code           = c.value_source_code
                         AND s.application_id        = l.application_id
                         AND s.entity_code           = l.entity_code
                         AND s.event_class_code      = l.event_class_code
                         AND s.active_flag          = 'Y'
                         AND s.level_code            = 'H');

  -- Get all header descriptions for the AAD that have derived sources in their
  -- details which do not belong to the event class
  CURSOR c_hdr_desc_det_der_sources IS
   SELECT distinct l.entity_code, l.event_class_code, l.event_type_code,
          l.description_type_code, l.description_code, d.source_type_code, d.source_code
     FROM xla_descript_details_b d, xla_desc_priorities p, xla_prod_acct_headers l
    WHERE d.description_prio_id   = p.description_prio_id
      AND p.application_id        = l.application_id
      AND p.amb_context_code      = l.amb_context_code
      AND p.description_type_code = l.description_type_code
      AND p.description_code      = l.description_code
      AND l.application_id        = p_application_id
      AND l.amb_context_code      = p_amb_context_code
      AND l.product_rule_type_code= p_product_rule_type_code
      AND l.product_rule_code     = p_product_rule_code
      AND l.accounting_required_flag  = 'Y'
      AND l.validation_status_code    = 'R'
      AND d.source_type_code      = 'D';

  -- Get all header descriptions for the AAD that have derived sources in their
  -- conditions which do not belong to the event class
  CURSOR c_hdr_desc_con_der_sources IS
   SELECT distinct l.entity_code, l.event_class_code, l.event_type_code,
          l.description_type_code, l.description_code,
          c.source_type_code source_type_code, c.source_code source_code
     FROM xla_conditions c, xla_desc_priorities p, xla_prod_acct_headers l
    WHERE c.description_prio_id   = p.description_prio_id
      AND p.application_id        = l.application_id
      AND p.amb_context_code      = l.amb_context_code
      AND p.description_type_code = l.description_type_code
      AND p.description_code      = l.description_code
      AND l.application_id        = p_application_id
      AND l.amb_context_code      = p_amb_context_code
      AND l.product_rule_type_code= p_product_rule_type_code
      AND l.product_rule_code     = p_product_rule_code
      AND l.accounting_required_flag  = 'Y'
      AND l.validation_status_code    = 'R'
      AND c.source_type_code      = 'D'
   UNION
   SELECT distinct l.entity_code, l.event_class_code, l.event_type_code,
          l.description_type_code, l.description_code,
          c.value_source_type_code source_type_code, c.value_source_code source_code
     FROM xla_conditions c, xla_desc_priorities p, xla_prod_acct_headers l
    WHERE c.description_prio_id   = p.description_prio_id
      AND p.application_id        = l.application_id
      AND p.amb_context_code      = l.amb_context_code
      AND p.description_type_code = l.description_type_code
      AND p.description_code      = l.description_code
      AND l.application_id        = p_application_id
      AND l.amb_context_code      = p_amb_context_code
      AND l.product_rule_type_code= p_product_rule_type_code
      AND l.product_rule_code     = p_product_rule_code
      AND l.accounting_required_flag  = 'Y'
      AND l.validation_status_code    = 'R'
      AND c.value_source_type_code  = 'D';

  l_return       BOOLEAN;
  l_log_module   VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_descriptions_are_valid';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_descriptions_are_valid'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',product_rule_type_code = '||p_product_rule_type_code||
                      ',product_rule_code = '||p_product_rule_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  -- Check if header descriptions are disabled
  FOR l_enabled_hdr_desc IN c_enabled_hdr_desc LOOP
    xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_DISABLD_HDR_DESC'
              ,p_message_type              => 'E'
              ,p_message_category          => 'HDR_DESCRIPTION'
              ,p_category_sequence         => 7
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_entity_code               => l_enabled_hdr_desc.entity_code
              ,p_event_class_code          => l_enabled_hdr_desc.event_class_code
              ,p_event_type_code           => l_enabled_hdr_desc.event_type_code
              ,p_description_type_code     => l_enabled_hdr_desc.description_type_code
              ,p_description_code          => l_enabled_hdr_desc.description_code);

    p_err_count := p_err_count + 1;
    p_inv_event_class_codes(p_err_count) := l_enabled_hdr_desc.event_class_code;
    l_return := FALSE;
  END LOOP;

  -- check header description has seeded sources in details
  -- that do not belong to the event class
  FOR l_hdr_desc_detail_sources IN c_hdr_desc_detail_sources LOOP
    xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_HDR_DES_DET_SRC'
              ,p_message_type              => 'E'
              ,p_message_category          => 'HDR_DESCRIPTION'
              ,p_category_sequence         => 7
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => l_hdr_desc_detail_sources.entity_code
              ,p_event_class_code          => l_hdr_desc_detail_sources.event_class_code
              ,p_event_type_code           => l_hdr_desc_detail_sources.event_type_code
              ,p_description_type_code     => l_hdr_desc_detail_sources.description_type_code
              ,p_description_code          => l_hdr_desc_detail_sources.description_code
              ,p_source_type_code          => l_hdr_desc_detail_sources.source_type_code
              ,p_source_code               => l_hdr_desc_detail_sources.source_code);

    p_err_count := p_err_count + 1;
    p_inv_event_class_codes(p_err_count) := l_hdr_desc_detail_sources.event_class_code;
    l_return := FALSE;
  END LOOP;

  -- check header description has seeded sources in conditions
  -- that do not belong to the event class
  FOR l_hdr_desc_con_sources IN c_hdr_desc_con_sources LOOP
    xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_HDR_DES_CON_SRC'
              ,p_message_type              => 'E'
              ,p_message_category          => 'HDR_DESCRIPTION'
              ,p_category_sequence         => 7
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => l_hdr_desc_con_sources.entity_code
              ,p_event_class_code          => l_hdr_desc_con_sources.event_class_code
              ,p_event_type_code           => l_hdr_desc_con_sources.event_type_code
              ,p_description_type_code     => l_hdr_desc_con_sources.description_type_code
              ,p_description_code          => l_hdr_desc_con_sources.description_code
              ,p_source_type_code          => l_hdr_desc_con_sources.source_type_code
              ,p_source_code               => l_hdr_desc_con_sources.source_code);

    p_err_count := p_err_count + 1;
    p_inv_event_class_codes(p_err_count) := l_hdr_desc_con_sources.event_class_code;
    l_return := FALSE;
  END LOOP;

  -- check header description has derived sources in details
  -- that do not belong to the event class
  FOR l_hdr_desc_det_der_sources IN c_hdr_desc_det_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_hdr_desc_det_der_sources.source_code
              ,p_derived_source_type_code => 'D'
              ,p_entity_code              => l_hdr_desc_det_der_sources.entity_code
              ,p_event_class_code         => l_hdr_desc_det_der_sources.event_class_code
              ,p_level                    => 'H')  = 'TRUE' THEN

      xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_HDR_DES_DET_SRC'
              ,p_message_type              => 'E'
              ,p_message_category          => 'HDR_DESCRIPTION'
              ,p_category_sequence         => 7
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => l_hdr_desc_det_der_sources.entity_code
              ,p_event_class_code          => l_hdr_desc_det_der_sources.event_class_code
              ,p_event_type_code           => l_hdr_desc_det_der_sources.event_type_code
              ,p_description_type_code     => l_hdr_desc_det_der_sources.description_type_code
              ,p_description_code          => l_hdr_desc_det_der_sources.description_code
              ,p_source_type_code          => l_hdr_desc_det_der_sources.source_type_code
              ,p_source_code               => l_hdr_desc_det_der_sources.source_code);

      p_err_count := p_err_count + 1;
      p_inv_event_class_codes(p_err_count) := l_hdr_desc_det_der_sources.event_class_code;
      l_return := FALSE;
    END IF;
  END LOOP;

  -- check header description has derived sources in conditions
  -- that do not belong to the event class
  FOR l_hdr_desc_con_der_sources IN c_hdr_desc_con_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_hdr_desc_con_der_sources.source_code
              ,p_derived_source_type_code => 'D'
              ,p_entity_code              => l_hdr_desc_con_der_sources.entity_code
              ,p_event_class_code         => l_hdr_desc_con_der_sources.event_class_code
              ,p_level                    => 'H') = 'TRUE' THEN

      xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_HDR_DES_CON_SRC'
              ,p_message_type              => 'E'
              ,p_message_category          => 'HDR_DESCRIPTION'
              ,p_category_sequence         => 7
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => l_hdr_desc_con_der_sources.entity_code
              ,p_event_class_code          => l_hdr_desc_con_der_sources.event_class_code
              ,p_event_type_code           => l_hdr_desc_con_der_sources.event_type_code
              ,p_description_type_code     => l_hdr_desc_con_der_sources.description_type_code
              ,p_description_code          => l_hdr_desc_con_der_sources.description_code
              ,p_source_type_code          => l_hdr_desc_con_der_sources.source_type_code
              ,p_source_code               => l_hdr_desc_con_der_sources.source_code);

      p_err_count := p_err_count + 1;
      p_inv_event_class_codes(p_err_count) := l_hdr_desc_con_der_sources.event_class_code;
      l_return := FALSE;
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure - return: '
                      ||case when l_return then 'TRUE' else 'FALSE' end
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_amb_aad_pkg.chk_descriptions_are_valid');

END chk_descriptions_are_valid;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| chk_ana_cri_are_valid                                                 |
|                                                                       |
| Returns false if header or line analytical criteria are invalid       |
|                                                                       |
+======================================================================*/
FUNCTION chk_ana_cri_are_valid
  (p_application_id              IN NUMBER
  ,p_amb_context_code            IN VARCHAR2
  ,p_product_rule_type_code      IN VARCHAR2
  ,p_product_rule_code           IN VARCHAR2
  ,p_err_count                   IN OUT NOCOPY INTEGER
  ,p_inv_event_class_codes       IN OUT NOCOPY t_array_codes)
RETURN BOOLEAN
IS

  -- Get all header analytical criteria for the AAD that are disabled
  CURSOR c_enabled_hdr_anal IS
   SELECT distinct s.event_class_code, s.event_type_code,
          s.analytical_criterion_type_code, s.analytical_criterion_code
     FROM xla_aad_header_ac_assgns s
    WHERE s.application_id                 = p_application_id
      AND s.amb_context_code               = p_amb_context_code
      AND s.product_rule_type_code         = p_product_rule_type_code
      AND s.product_rule_code              = p_product_rule_code
      AND NOT EXISTS ( SELECT 'x'
                         FROM xla_analytical_hdrs_b a
                        WHERE a.amb_context_code               = s.amb_context_code
                          AND a.analytical_criterion_code      = s.analytical_criterion_code
                          AND a.analytical_criterion_type_code = s.analytical_criterion_type_code
                          AND a.enabled_flag                   = 'Y');

  -- Get all header analytical criteria for the AAD that have balancing flag set
  CURSOR c_hdr_anal IS
   SELECT distinct s.event_class_code, s.event_type_code,
          s.analytical_criterion_type_code, s.analytical_criterion_code
     FROM xla_aad_header_ac_assgns s
    WHERE s.application_id                 = p_application_id
      AND s.amb_context_code               = p_amb_context_code
      AND s.product_rule_type_code         = p_product_rule_type_code
      AND s.product_rule_code              = p_product_rule_code
      AND EXISTS     ( SELECT 'x'
                         FROM xla_analytical_hdrs_b a
                        WHERE a.amb_context_code               = s.amb_context_code
                          AND a.analytical_criterion_code      = s.analytical_criterion_code
                          AND a.analytical_criterion_type_code = s.analytical_criterion_type_code
                          AND a.balancing_flag                 = 'Y');

  -- Get all header analytical criteria for the AAD that have no details
  -- for the event class
  CURSOR c_hdr_event_sources IS
   SELECT distinct s.event_class_code, s.event_type_code,
          s.analytical_criterion_type_code, s.analytical_criterion_code
     FROM xla_aad_header_ac_assgns s
    WHERE s.application_id                 = p_application_id
      AND s.amb_context_code               = p_amb_context_code
      AND s.product_rule_type_code         = p_product_rule_type_code
      AND s.product_rule_code              = p_product_rule_code
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_analytical_sources  a
                       WHERE a.application_id                 = s.application_id
                         AND a.amb_context_code               = s.amb_context_code
                         AND a.event_class_code               = s.event_class_code
                         AND a.analytical_criterion_code      = s.analytical_criterion_code
                         AND a.analytical_criterion_type_code = s.analytical_criterion_type_code);

  -- Get all header analytical criteria for the AAD that have sources assigned
  -- at line level to the event class
  CURSOR c_hdr_anal_sources IS
   SELECT distinct n.event_class_code, n.event_type_code,
          n.analytical_criterion_type_code, n.analytical_criterion_code,
          a.source_code, a.source_type_code
     FROM xla_analytical_sources  a, xla_aad_header_ac_assgns n
    WHERE a.application_id                 = n.application_id
      AND a.amb_context_code               = n.amb_context_code
      AND a.event_class_code               = n.event_class_code
      AND a.analytical_criterion_code      = n.analytical_criterion_code
      AND a.analytical_criterion_type_code = n.analytical_criterion_type_code
      AND a.source_type_code               = 'S'
      AND n.application_id                 = p_application_id
      AND n.amb_context_code               = p_amb_context_code
      AND n.product_rule_type_code         = p_product_rule_type_code
      AND n.product_rule_code              = p_product_rule_code
      AND not exists (SELECT 'y'
                        FROM xla_event_sources s
                       WHERE s.source_application_id = a.source_application_id
                         AND s.source_type_code      = a.source_type_code
                         AND s.source_code           = a.source_code
                         AND s.application_id        = a.application_id
                         AND s.entity_code           = a.entity_code
                         AND s.event_class_code      = a.event_class_code
                         AND s.active_flag           = 'Y'
                         AND s.level_code            = 'H');

  -- Get all header analytical criteria for the AAD that have derived sources assigned
  -- at line level to the event class or do not belong to the event class
  CURSOR c_hdr_anal_der_sources IS
   SELECT distinct n.event_class_code, n.event_type_code,
          n.analytical_criterion_type_code, n.analytical_criterion_code,
          a.source_code, a.source_type_code
     FROM xla_analytical_sources  a, xla_aad_header_ac_assgns n
    WHERE a.application_id                 = n.application_id
      AND a.amb_context_code               = n.amb_context_code
      AND a.event_class_code               = n.event_class_code
      AND a.analytical_criterion_code      = n.analytical_criterion_code
      AND a.analytical_criterion_type_code = n.analytical_criterion_type_code
      AND a.source_type_code               = 'D'
      AND n.application_id                 = p_application_id
      AND n.amb_context_code               = p_amb_context_code
      AND n.product_rule_type_code         = p_product_rule_type_code
      AND n.product_rule_code              = p_product_rule_code;

  l_return         BOOLEAN;
  l_log_module     VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_ana_cri_are_valid';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_ana_cri_are_valid'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',product_rule_type_code = '||p_product_rule_type_code||
                      ',product_rule_code = '||p_product_rule_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

   -- Error all header analytical criteria that are assigned to the AAD and disabled
   FOR l_enabled_hdr_anal IN c_enabled_hdr_anal LOOP
     xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_DISABLD_HDR_AC'
              ,p_message_type              => 'E'
              ,p_message_category          => 'HDR_AC'
              ,p_category_sequence         => 8
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_event_class_code          => l_enabled_hdr_anal.event_class_code
              ,p_event_type_code           => l_enabled_hdr_anal.event_type_code
              ,p_anal_criterion_type_code  => l_enabled_hdr_anal.analytical_criterion_type_code
              ,p_anal_criterion_code       => l_enabled_hdr_anal.analytical_criterion_code);

     p_err_count := p_err_count + 1;
     p_inv_event_class_codes(p_err_count) := l_enabled_hdr_anal.event_class_code;
     l_return := FALSE;
   END LOOP;

   -- Error all header analytical criteria that are assigned to the AAD
   -- and have balancing flag set
   FOR l_hdr_anal IN c_hdr_anal LOOP
     xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_ANC_MAINTAIN_BAL'
              ,p_message_type              => 'E'
              ,p_message_category          => 'HDR_AC'
              ,p_category_sequence         => 8
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_event_class_code          => l_hdr_anal.event_class_code
              ,p_event_type_code           => l_hdr_anal.event_type_code
              ,p_anal_criterion_type_code  => l_hdr_anal.analytical_criterion_type_code
              ,p_anal_criterion_code       => l_hdr_anal.analytical_criterion_code);

     p_err_count := p_err_count + 1;
     p_inv_event_class_codes(p_err_count) := l_hdr_anal.event_class_code;
     l_return := FALSE;
   END LOOP;

   -- Error all header analytical criteria that have no details for the event class
   FOR l_hdr_event_sources IN c_hdr_event_sources LOOP
     xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_HDR_ANC_NO_DETAIL'
              ,p_message_type              => 'E'
              ,p_message_category          => 'HDR_AC'
              ,p_category_sequence         => 8
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_event_class_code          => l_hdr_event_sources.event_class_code
              ,p_event_type_code           => l_hdr_event_sources.event_type_code
              ,p_anal_criterion_type_code  => l_hdr_event_sources.analytical_criterion_type_code
              ,p_anal_criterion_code       => l_hdr_event_sources.analytical_criterion_code);

     p_err_count := p_err_count + 1;
     p_inv_event_class_codes(p_err_count) := l_hdr_event_sources.event_class_code;
     l_return := FALSE;
   END LOOP;

   -- Error all header analytical criteria that have sources that
   -- do not belong to the event class
   FOR l_hdr_anal_sources IN c_hdr_anal_sources LOOP
     xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_HDR_ANC_SOURCE'
              ,p_message_type              => 'E'
              ,p_message_category          => 'HDR_AC'
              ,p_category_sequence         => 8
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_event_class_code          => l_hdr_anal_sources.event_class_code
              ,p_event_type_code           => l_hdr_anal_sources.event_type_code
              ,p_anal_criterion_type_code  => l_hdr_anal_sources.analytical_criterion_type_code
              ,p_anal_criterion_code       => l_hdr_anal_sources.analytical_criterion_code
              ,p_source_code               => l_hdr_anal_sources.source_code
              ,p_source_type_code          => l_hdr_anal_sources.source_type_code);

     p_err_count := p_err_count + 1;
     p_inv_event_class_codes(p_err_count) := l_hdr_anal_sources.event_class_code;
     l_return := FALSE;
   END LOOP;

   -- Error all header analytical criteria that have derived sources that
   -- do not belong to the event class
   FOR l_hdr_anal_der_sources IN c_hdr_anal_der_sources LOOP
     IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_hdr_anal_der_sources.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => l_hdr_anal_der_sources.event_class_code
              ,p_level                    => 'H')  = 'TRUE' THEN

       xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_HDR_ANC_SOURCE'
              ,p_message_type              => 'E'
              ,p_message_category          => 'HDR_AC'
              ,p_category_sequence         => 8
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_event_class_code          => l_hdr_anal_der_sources.event_class_code
              ,p_event_type_code           => l_hdr_anal_der_sources.event_type_code
              ,p_anal_criterion_type_code  => l_hdr_anal_der_sources.analytical_criterion_type_code
              ,p_anal_criterion_code       => l_hdr_anal_der_sources.analytical_criterion_code
              ,p_source_code               => l_hdr_anal_der_sources.source_code
              ,p_source_type_code          => l_hdr_anal_der_sources.source_type_code);

       p_err_count := p_err_count + 1;
       p_inv_event_class_codes(p_err_count) := l_hdr_anal_der_sources.event_class_code;
       l_return := FALSE;
     END IF;
   END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure - return: '
                      ||case when l_return then 'TRUE' else 'FALSE' end
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_amb_aad_pkg.chk_ana_cri_are_valid');

END chk_ana_cri_are_valid;


--======================================================================+
--
-- Name: validate_header_assignments
-- Description: Validate the journal entry setups for an AAD
--
--======================================================================+
FUNCTION validate_header_assignments
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2
  ,p_err_count                        IN OUT NOCOPY INTEGER
  ,p_inv_event_class_codes            IN OUT NOCOPY t_array_codes)
RETURN BOOLEAN
IS

   -- Get all event classes that are assigned to the AAD and disabled
   CURSOR c_enabled_classes
   IS
   SELECT entity_code, event_class_code
     FROM xla_prod_acct_headers d
    WHERE d.application_id            = p_application_id
      AND d.amb_context_code          = p_amb_context_code
      AND d.product_rule_type_code    = p_product_rule_type_code
      AND d.product_rule_code         = p_product_rule_code
      AND EXISTS (SELECT 'y'
                    FROM xla_event_classes_b s
                   WHERE s.application_id         = d.application_id
                     AND s.entity_code            = d.entity_code
                     AND s.event_class_code       = d.event_class_code
                     AND s.enabled_flag           = 'N');

   -- Get all event classes that have circular references
   CURSOR c_ec_predecs
   IS
   SELECT entity_code, event_class_code
     FROM xla_prod_acct_headers d
    WHERE d.application_id            = p_application_id
      AND d.amb_context_code          = p_amb_context_code
      AND d.product_rule_type_code    = p_product_rule_type_code
      AND d.product_rule_code         = p_product_rule_code
      AND EXISTS (SELECT  'x'
                    FROM xla_event_class_predecs p
                   WHERE p.application_id     = d.application_id
                     AND p.event_class_code   = d.event_class_code
                     AND CONNECT_BY_ISCYCLE = 1
                 CONNECT BY NOCYCLE prior event_class_code = prior_event_class_code);

   -- Check if atleast one event type is being accounting for the AAD
   CURSOR c_accting_required
   IS
   SELECT 'x'
     FROM xla_prod_acct_headers d
    WHERE d.application_id            = p_application_id
      AND d.amb_context_code          = p_amb_context_code
      AND d.product_rule_type_code    = p_product_rule_type_code
      AND d.product_rule_code         = p_product_rule_code
      AND d.accounting_required_flag  = 'Y';

   -- Get all event classes that are assigned to the AAD and do not
   -- have atleast one enabled accounting event class
   CURSOR c_class_enabled_types
   IS
   SELECT entity_code, event_class_code
     FROM xla_prod_acct_headers d
    WHERE d.application_id            = p_application_id
      AND d.amb_context_code          = p_amb_context_code
      AND d.product_rule_type_code    = p_product_rule_type_code
      AND d.product_rule_code         = p_product_rule_code
      AND d.event_type_code           = d.event_class_code||'_ALL'
      AND NOT EXISTS (SELECT 'y'
                        FROM xla_event_types_b et
                       WHERE et.application_id         = d.application_id
                         AND et.entity_code            = d.entity_code
                         AND et.event_class_code       = d.event_class_code
                         AND et.event_type_code       <> d.event_class_code||'_ALL'
                         AND et.enabled_flag           = 'Y'
                         AND et.accounting_flag        = 'Y');

   -- Get all event types that are assigned to the AAD and are not enabled accounting event types
   CURSOR c_enabled_types
   IS
   SELECT application_id, entity_code, event_class_code, event_type_code
     FROM xla_prod_acct_headers d
    WHERE d.application_id            = p_application_id
      AND d.amb_context_code          = p_amb_context_code
      AND d.product_rule_type_code    = p_product_rule_type_code
      AND d.product_rule_code         = p_product_rule_code
      AND d.event_type_code           <> d.event_class_code||'_ALL'
      AND d.validation_status_code    = 'R'
      AND NOT EXISTS (SELECT 'y'
                       FROM xla_event_types_b s
                      WHERE s.application_id         = d.application_id
                        AND s.entity_code            = d.entity_code
                        AND s.event_class_code       = d.event_class_code
                        AND s.event_type_code        = d.event_type_code
                        AND s.enabled_flag           = 'Y'
                        AND s.accounting_flag        = 'Y');

   -- Get all event types to be accounted for which do not have any lines assigned to them
   CURSOR c_acct_headers
   IS
   SELECT xpa.entity_code, xpa.event_class_code, xpa.event_type_code
     FROM xla_prod_acct_headers xpa
    WHERE xpa.application_id            = p_application_id
      AND xpa.amb_context_code          = p_amb_context_code
      AND xpa.product_rule_type_code    = p_product_rule_type_code
      AND xpa.product_rule_code         = p_product_rule_code
      AND xpa.accounting_required_flag  = 'Y'
      AND xpa.validation_status_code    = 'R'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_aad_line_defn_assgns       xal
                           , xla_line_definitions_b         xld
                       WHERE xal.application_id             = xpa.application_id
                         AND xal.amb_context_code           = xpa.amb_context_code
                         AND xal.product_rule_type_code     = xpa.product_rule_type_code
                         AND xal.product_rule_code          = xpa.product_rule_code
                         AND xal.event_class_code           = xpa.event_class_code
                         AND xal.event_type_code            = xpa.event_type_code
                         AND xld.application_id             = xal.application_id
                         AND xld.amb_context_code           = xal.amb_context_code
                         AND xld.event_class_code           = xal.event_class_code
                         AND xld.event_type_code            = xal.event_type_code
                         AND xld.line_definition_owner_code = xal.line_definition_owner_code
                         AND xld.line_definition_code       = xal.line_definition_code
                         AND xld.enabled_flag               = 'Y');

   -- Get all event classes to be accounted for the AAD
   CURSOR c_prod_acct_headers
   IS
   SELECT distinct entity_code, event_class_code, event_type_code
     FROM xla_prod_acct_headers d
    WHERE d.application_id            = p_application_id
      AND d.amb_context_code          = p_amb_context_code
      AND d.product_rule_type_code    = p_product_rule_type_code
      AND d.product_rule_code         = p_product_rule_code
      AND d.accounting_required_flag  = 'Y'
      AND d.validation_status_code    = 'R';

  l_return             BOOLEAN;
  l_exist              VARCHAR2(1);
  l_log_module         VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_header_assignments';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_header_assignments'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',product_rule_type_code = '||p_product_rule_type_code||
                      ',product_rule_code = '||p_product_rule_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  -- Check if atleast one event class or event type assignment is being accounted for
  OPEN c_accting_required;
  FETCH c_accting_required INTO l_exist;
  IF c_accting_required%notfound THEN

      Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_NO_EVENT_TYPE_ACCTED'
              ,p_message_type              => 'E'
              ,p_message_category          => 'AAD'
              ,p_category_sequence         => 1
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code);

          l_return := FALSE;
  END IF;
  CLOSE c_accting_required;

  -- check if assigned event classes are disabled
  FOR l_enabled_classes IN c_enabled_classes LOOP
    xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_DISABLD_EVT_CLASS'
              ,p_message_type              => 'E'
              ,p_message_category          => 'EVENT_CLASS'
              ,p_category_sequence         => 2
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => l_enabled_classes.entity_code
              ,p_event_class_code          => l_enabled_classes.event_class_code);

    p_err_count := p_err_count + 1;
    p_inv_event_class_codes(p_err_count) := l_enabled_classes.event_class_code;
    l_return := FALSE;
  END LOOP;

  -- check if assigned event classes have circular references
  FOR l_ec_predecs IN c_ec_predecs LOOP
    xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_EC_PREDECS_LOOP'
              ,p_message_type              => 'E'
              ,p_message_category          => 'EVENT_CLASS'
              ,p_category_sequence         => 2
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => l_ec_predecs.entity_code
              ,p_event_class_code          => l_ec_predecs.event_class_code);

    p_err_count := p_err_count + 1;
    p_inv_event_class_codes(p_err_count) := l_ec_predecs.event_class_code;
    l_return := FALSE;
  END LOOP;

  -- check if assigned event classes have atleast one accounting event type that is enabled
  FOR l_class_enabled_types IN c_class_enabled_types LOOP
    xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_EC_DISABLED_ET'
              ,p_message_type              => 'E'
              ,p_message_category          => 'EVENT_CLASS'
              ,p_category_sequence         => 2
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => l_class_enabled_types.entity_code
              ,p_event_class_code          => l_class_enabled_types.event_class_code);

    p_err_count := p_err_count + 1;
    p_inv_event_class_codes(p_err_count) := l_class_enabled_types.event_class_code;
    l_return := FALSE;
  END LOOP;

  -- check if assigned event types are disabled
  FOR l_enabled_types IN c_enabled_types LOOP
    xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_DISABLD_EVENT_TYP'
              ,p_message_type              => 'E'
              ,p_message_category          => 'EVENT_TYPE'
              ,p_category_sequence         => 6
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => l_enabled_types.entity_code
              ,p_event_class_code          => l_enabled_types.event_class_code
              ,p_event_type_code           => l_enabled_types.event_type_code);

    p_err_count := p_err_count + 1;
    p_inv_event_class_codes(p_err_count) := l_enabled_types.event_class_code;
    l_return := FALSE;
  END LOOP;

  -- Validate every event type to be accounted for has lines assigned to it
  -- or is an accounting reversal event class
  FOR l_acct_header IN c_acct_headers LOOP
    -- Check if event class is an accounting reversal event class
    IF not is_reversal
                (p_application_id   => p_application_id
                ,p_entity_code      => l_acct_header.entity_code
                ,p_event_class_code => l_acct_header.event_class_code) THEN

      xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_LESS_LINE_TYPES'
              ,p_message_type              => 'E'
              ,p_message_category          => 'EVENT_TYPE'
              ,p_category_sequence         => 6
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code
              ,p_entity_code               => l_acct_header.entity_code
              ,p_event_class_code          => l_acct_header.event_class_code
              ,p_event_type_code           => l_acct_header.event_type_code);

      p_err_count := p_err_count + 1;
      p_inv_event_class_codes(p_err_count) := l_acct_header.event_class_code;
      l_return := FALSE;
    END IF;
  END LOOP;

  -- Validate Header descriptions
  IF NOT chk_descriptions_are_valid
            (p_application_id         => p_application_id
            ,p_amb_context_code       => p_amb_context_code
            ,p_product_rule_type_code => p_product_rule_type_code
            ,p_product_rule_code      => p_product_rule_code
            ,p_err_count              => p_err_count
            ,p_inv_event_class_codes  => p_inv_event_class_codes) THEN
    l_return := FALSE;
  END IF;

  -- Validate Header Analytical Criteria
  IF NOT chk_ana_cri_are_valid
            (p_application_id         => p_application_id
            ,p_amb_context_code       => p_amb_context_code
            ,p_product_rule_type_code => p_product_rule_type_code
            ,p_product_rule_code      => p_product_rule_code
            ,p_err_count              => p_err_count
            ,p_inv_event_class_codes  => p_inv_event_class_codes) THEN
    l_return := FALSE;
  END IF;

  -- Get all event classes to be accounted for
  FOR l_prod_acct_header IN c_prod_acct_headers LOOP
    -- Validate header accounting sources
    IF NOT chk_hdr_accting_sources
              (p_application_id         => p_application_id
              ,p_amb_context_code       => p_amb_context_code
              ,p_product_rule_type_code => p_product_rule_type_code
              ,p_product_rule_code      => p_product_rule_code
              ,p_entity_code            => l_prod_acct_header.entity_code
              ,p_event_class_code       => l_prod_acct_header.event_class_code
              ,p_event_type_code        => l_prod_acct_header.event_type_code) THEN

      p_err_count := p_err_count + 1;
      p_inv_event_class_codes(p_err_count) := l_prod_acct_header.event_class_code;
      l_return := FALSE;
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure - return: '
                      ||case when l_return then 'TRUE' else 'FALSE' end
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_amb_aad_pkg.validate_header_assignments');

END validate_header_assignments;

FUNCTION validate_jld
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_jld';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_jld'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := xla_line_definitions_pvt.validate_line_definition
                 (p_application_id             => p_application_id
                 ,p_amb_context_code           => p_amb_context_code
                 ,p_event_class_code           => p_event_class_code
                 ,p_event_type_code            => p_event_type_code
                 ,p_line_definition_owner_code => p_line_definition_owner_code
                 ,p_line_definition_code       => p_line_definition_code);

  IF (l_return) THEN
    UPDATE xla_line_definitions_b
       SET validation_status_code = 'Y'  -- Valid
     WHERE application_id             = p_application_id
       AND amb_context_code           = p_amb_context_code
       AND event_class_code           = p_event_class_code
       AND event_type_code            = p_event_type_code
       AND line_definition_owner_code = p_line_definition_owner_code
       AND line_definition_code       = p_line_definition_code;
  ELSE
    UPDATE xla_line_definitions_b
       SET validation_status_code = 'E'  -- Invalid
     WHERE application_id             = p_application_id
       AND amb_context_code           = p_amb_context_code
       AND event_class_code           = p_event_class_code
       AND event_type_code            = p_event_type_code
       AND line_definition_owner_code = p_line_definition_owner_code
       AND line_definition_code       = p_line_definition_code;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_jld: return - '||
                      CASE WHEN l_return THEN 'TRUE' ELSE 'FALSE' END
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_amb_aad_pkg.validate_jld');

END validate_jld;


--======================================================================
--
-- Name: validate_aad
-- Description: Validate an AAD.  Only event class/type assignments that
--              have status Validating are validated in this API
--
--======================================================================
PROCEDURE validate_aad
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2
  ,x_validation_status_code           IN OUT NOCOPY VARCHAR2
  ,x_hash_id                          IN OUT NOCOPY INTEGER)
IS
  --
  -- Retrieve all journal lines definitions of the AAD that are not validated
  --
  CURSOR c_line_definitions IS
   SELECT distinct xld.event_class_code, xld.event_type_code,
          xld.line_definition_owner_code, xld.line_definition_code
     FROM xla_aad_line_defn_assgns xal
         ,xla_line_definitions_b   xld
    WHERE xld.application_id             = xal.application_id
      AND xld.amb_context_code           = xal.amb_context_code
      AND xld.event_class_code           = xal.event_class_code
      AND xld.event_type_code            = xal.event_type_code
      AND xld.line_definition_owner_code = xal.line_definition_owner_code
      AND xld.line_definition_code       = xal.line_definition_code
      AND xld.validation_status_code     <> 'Y'
      AND xal.application_id             = p_application_id
      AND xal.amb_context_code           = p_amb_context_code
      AND xal.product_rule_type_code     = p_product_rule_type_code
      AND xal.product_rule_code          = p_product_rule_code;

  l_inv_event_class_codes      t_array_codes;
  l_err_count                  INTEGER;
  l_return                     BOOLEAN;
  l_warning                    BOOLEAN;

  j                            INTEGER;

  l_log_module                 VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_aad';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_aad'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',product_rule_type_code = '||p_product_rule_type_code||
                      ',product_rule_code = '||p_product_rule_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return  := TRUE;
  l_warning := TRUE;

  -- Set environment settings
  xla_environment_pkg.refresh;

  -- Delete the error table for the event class
  DELETE FROM xla_amb_setup_errors
   WHERE application_id              = p_application_id
     AND amb_context_code            = p_amb_context_code
     AND product_rule_type_code      = p_product_rule_type_code
     AND product_rule_code           = p_product_rule_code;

  -- Initialize the error package
  Xla_amb_setup_err_pkg.initialize;

  -- Get the extract object owner for all extract objects for AAD
  -- and store in GT table
/*
  xla_extract_integrity_pkg.set_extract_object_owner
    (p_application_id         => p_application_id
    ,p_amb_context_code       => p_amb_context_code
    ,p_product_rule_type_code => p_product_rule_type_code
    ,p_product_rule_code      => p_product_rule_code);
*/

  -- Validate all extract objects for the AAD
  l_warning := xla_extract_integrity_pkg.validate_extract_objects
                 (p_application_id         => p_application_id
                 ,p_amb_context_code       => p_amb_context_code
                 ,p_product_rule_type_code => p_product_rule_type_code
                 ,p_product_rule_code      => p_product_rule_code);

  -- Validate journal line definitions for all event class/type assignments
  -- that are not validated
  l_err_count := 0;
  FOR l_line_definition IN c_line_definitions LOOP
    IF (NOT validate_jld
                 (p_application_id             => p_application_id
                 ,p_amb_context_code           => p_amb_context_code
                 ,p_event_class_code           => l_line_definition.event_class_code
                 ,p_event_type_code            => l_line_definition.event_type_code
                 ,p_line_definition_owner_code => l_line_definition.line_definition_owner_code
                 ,p_line_definition_code       => l_line_definition.line_definition_code)) THEN
      l_err_count := l_err_count + 1;
      l_inv_event_class_codes(l_err_count) := l_line_definition.event_class_code;
      l_return := FALSE;
    END IF;
  END LOOP;

  -- Validate header assignment
  l_return := validate_header_assignments
                 (p_application_id         => p_application_id
                 ,p_amb_context_code       => p_amb_context_code
                 ,p_product_rule_type_code => p_product_rule_type_code
                 ,p_product_rule_code      => p_product_rule_code
                 ,p_err_count              => l_err_count
                 ,p_inv_event_class_codes  => l_inv_event_class_codes)
              AND l_return;

  -- For all event class assignment of the invalid line definition or invalid
  -- header assignment of the eventclass, mark the event class assignment to Error
  IF (NOT l_return) THEN
    FORALL j IN 1..l_err_count
      UPDATE xla_prod_acct_headers xpa
         SET validation_status_code = 'E'
       WHERE application_id         = p_application_id
         AND amb_context_code       = p_amb_context_code
         AND product_rule_type_code = p_product_rule_type_code
         AND product_rule_code      = p_product_rule_code
         AND event_class_code       = l_inv_event_class_codes(j);
  END IF;

  -- Get the hash id for the AAD
  x_hash_id := XLA_CMP_HASH_PKG.GetPadHashId
                     (p_product_rule_code      => p_product_rule_code
                     ,p_amb_context_code       => p_amb_context_code
                     ,p_application_id         => p_application_id
                     ,p_product_rule_type_code => p_product_rule_type_code);

  IF x_hash_id is null then
    xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_HASH_ID_NOT_CREATED'
              ,p_message_type              => 'E'
              ,p_message_category          => 'AAD'
              ,p_category_sequence         => 1
              ,p_application_id            => p_application_id
              ,p_amb_context_code          => p_amb_context_code
              ,p_product_rule_type_code    => p_product_rule_type_code
              ,p_product_rule_code         => p_product_rule_code);

    l_return := FALSE;

  END IF;

  -- Insert errors into the error table from the plsql array
  xla_amb_setup_err_pkg.insert_errors;

  IF (l_return) THEN
    x_validation_status_code := 'Y';
  ELSE
    x_validation_status_code := 'E';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure - return: '
                      ||case when l_return then 'TRUE' else 'FALSE' end
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_amb_aad_pkg.validate_aad');

END validate_aad;


--=============================================================================
--
--
--
--
--          *********** public procedures and functions **********
--
--
--
--
--=============================================================================

--======================================================================+
--
-- Name: validate_and_compile_aad
-- Description: Validate and compile and AAD
--
--======================================================================+

PROCEDURE validate_and_compile_aad
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2
  ,x_validation_status_code           IN OUT NOCOPY VARCHAR2
  ,x_compilation_status_code          IN OUT NOCOPY VARCHAR2
  ,x_hash_id                          IN OUT NOCOPY INTEGER)
IS
  l_count           INTEGER;
  l_log_module      VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_and_compile_aad';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_and_compile_aad'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '         ||p_application_id||
                      ',amb_context_code = '      ||p_amb_context_code||
                      ',product_rule_type_code = '||p_product_rule_type_code||
                      ',product_rule_code = '     ||p_product_rule_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  x_validation_status_code  := 'N';
  x_compilation_status_code := 'N';
  x_hash_id := NULL;

  -- Get the extract object owner for all extract objects for AAD
  -- and store in GT table
  xla_extract_integrity_pkg.set_extract_object_owner
      (p_application_id         => p_application_id
      ,p_amb_context_code       => p_amb_context_code
      ,p_product_rule_type_code => p_product_rule_type_code
      ,p_product_rule_code      => p_product_rule_code);

  -- All event class/type assignment that are not Valid are eligiable for
  -- validation
  UPDATE xla_prod_acct_headers
     SET validation_status_code = 'R'
   WHERE application_id         = p_application_id
     AND amb_context_code       = p_amb_context_code
     AND product_rule_type_code = p_product_rule_type_code
     AND product_rule_code      = p_product_rule_code
     AND validation_status_code <> 'Y';

  -- If no validation is necessary, return
  l_count := SQL%ROWCOUNT;
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# rows updated to Validating = '||l_count
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (l_count = 0) THEN

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'No validation for any event class/type assignment - RETURN'
           ,p_module => l_log_module
           ,p_level  => C_LEVEL_STATEMENT);
    END IF;

    x_validation_status_code  := 'Y';

  ELSE
    -- Validate journal entry setups
    validate_aad
           (p_application_id         => p_application_id
           ,p_amb_context_code       => p_amb_context_code
           ,p_product_rule_type_code => p_product_rule_type_code
           ,p_product_rule_code      => p_product_rule_code
           ,x_validation_status_code => x_validation_status_code
           ,x_hash_id                => x_hash_id);
  END IF;

  -- For assignments that are valid (and does not marked for validation),
  -- change the validation status to R so they are eligiable for compilation.
  UPDATE xla_prod_acct_headers
     SET validation_status_code = 'R'
   WHERE application_id         = p_application_id
     AND amb_context_code       = p_amb_context_code
     AND product_rule_type_code = p_product_rule_type_code
     AND product_rule_code      = p_product_rule_code
     AND validation_status_code = 'Y';

  -- Check if the compilation succeeds
  IF xla_compile_pad_pkg.compile
          (p_application_id         => p_application_id
          ,p_amb_context_code       => p_amb_context_code
          ,p_product_rule_type_code => p_product_rule_type_code
          ,p_product_rule_code      => p_product_rule_code) THEN

     x_compilation_status_code := 'Y';

     -- Call product API for dynamic extract.
     BEGIN
       IF p_application_id = 140 THEN
         xla_fa_extract_pkg.COMPILE
             (p_application_id         => p_application_id
             ,p_amb_context_code       => p_amb_context_code
             ,p_product_rule_type_code => p_product_rule_type_code
             ,p_product_rule_code      => p_product_rule_code);
       END IF;
     EXCEPTION
        WHEN OTHERS THEN
   		XLA_AMB_SETUP_ERR_PKG.stack_error
           (p_message_name              => 'XLA_CMP_TECHNICAL_ERROR'
           ,p_message_type              => 'E'
           ,p_message_category          => 'AAD'
           ,p_category_sequence         => 1
           ,p_application_id            => p_application_id
           ,p_amb_context_code          => p_amb_context_code
           ,p_product_rule_type_code    => p_product_rule_type_code
           ,p_product_rule_code         => p_product_rule_code);

          -- Set AAD status to Invalid
          x_compilation_status_code := 'E';
          -- Insert errors into the error table from the plsql array
          xla_amb_setup_err_pkg.insert_errors;
     END;
  ELSE
    x_compilation_status_code := 'E';
  END IF;

  UPDATE xla_prod_acct_headers
     SET validation_status_code    = x_compilation_status_code
       , last_update_date          = sysdate
       , last_updated_by           = xla_environment_pkg.g_usr_id
       , last_update_login         = xla_environment_pkg.g_login_id
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND product_rule_type_code    = p_product_rule_type_code
     AND product_rule_code         = p_product_rule_code
     AND validation_status_code    = 'R';

  UPDATE xla_product_rules_b
     SET compile_status_code       = x_compilation_status_code
       , product_rule_hash_id      = NVL(x_hash_id,product_rule_hash_id)
       , last_update_date          = sysdate
       , last_updated_by           = xla_environment_pkg.g_usr_id
       , last_update_login         = xla_environment_pkg.g_login_id
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND product_rule_type_code    = p_product_rule_type_code
     AND product_rule_code         = p_product_rule_code
     RETURNING product_rule_hash_id INTO x_hash_id;

  COMMIT;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure : x_validation_status = '
                     ||x_validation_status_code
                     ||', x_compilation_status = '
                     ||x_compilation_status_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_amb_aad_pkg.Validate_and_compile_aad');

END validate_and_compile_aad;

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

g_creation_date                   := sysdate;
g_last_update_date                := sysdate;
g_created_by                      := xla_environment_pkg.g_usr_id;
g_last_update_login               := xla_environment_pkg.g_login_id;
g_last_updated_by                 := xla_environment_pkg.g_usr_id;

END xla_amb_aad_pkg;

/
