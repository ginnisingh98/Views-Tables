--------------------------------------------------------
--  DDL for Package Body XLA_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_SOURCES_PKG" AS
/* $Header: xlaamdss.pkb 120.27 2006/01/09 14:24:00 vkasina ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_sources_pkg                                                    |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Sources Package                                                |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|    19-Oct-04 Wynne Chan     Changes for Journal Lines Definitions     |
|                                                                       |
+======================================================================*/

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_sources_pkg';

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
      (p_location   => 'xla_sources_pkg.trace');
END trace;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| uncompile_tad_for_der_source                                          |
|                                                                       |
| Sets status of assigned transaction account definition to uncompiled  |
| for a derived source                                                  |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_tad_for_der_source
  (p_der_application_id                   IN NUMBER
  ,p_der_source_code                      IN VARCHAR2
  ,p_der_source_type_code                 IN VARCHAR2
  ,p_trx_acct_def                         IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def_type                    IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS
   --
   -- Private variables
   --
   l_exist   VARCHAR2(1) ;
   l_return  BOOLEAN := TRUE;

   l_application_name     varchar2(240) := null;
   l_trx_acct_def         varchar2(80)  := null;
   l_trx_acct_def_type    varchar2(80)  := null;

   --
   -- Cursor declarations
   --
   CURSOR c_seg_rules
   IS
   SELECT a.application_id, a.amb_context_code, a.segment_rule_type_code, a.segment_rule_code
     FROM xla_seg_rules_b a
    WHERE exists (SELECT 'x'
                    FROM xla_seg_rule_details sd
                   WHERE ((value_source_application_id      = p_der_application_id
                     AND  value_source_type_code            = p_der_source_type_code
                     AND  value_source_code                 = p_der_source_code)
                      OR (input_source_application_id       = p_der_application_id
                     AND  input_source_type_code            = p_der_source_type_code
                     AND  input_source_code                 = p_der_source_code
                     AND  input_source_code IS NOT NULL))
                     AND sd.application_id                  = a.application_id
                     AND sd.amb_context_code                = a.amb_context_code
                     AND sd.segment_rule_type_code          = a.segment_rule_type_code
                     AND sd.segment_rule_code               = a.segment_rule_code
                  UNION
                  SELECT 'x'
                    FROM xla_conditions c, xla_seg_rule_details sd
                   WHERE ((c.source_application_id      = p_der_application_id
                     AND  c.source_code                 = p_der_source_code
                     AND  c.source_type_code            = p_der_source_type_code)
                      OR (c.value_source_application_id = p_der_application_id
                     AND  c.value_source_type_code      = p_der_source_type_code
                     AND  c.value_source_code           = p_der_source_code
                     AND  c.value_source_code IS NOT NULL))
                     AND c.segment_rule_detail_id       = sd.segment_rule_detail_id
                     AND sd.application_id              = a.application_id
                     AND sd.amb_context_code            = a.amb_context_code
                     AND sd.segment_rule_type_code      = a.segment_rule_type_code
                     AND sd.segment_rule_code           = a.segment_rule_code);

   l_seg_rule   c_seg_rules%rowtype;

   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.uncompile_tad_for_der_source';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure uncompile_tad_for_der_source'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_der_application_id||
                      ',source_code = '||p_der_source_code||
                      ',source_type_code = '||p_der_source_type_code||
                      ',trx_acct_def = '||p_trx_acct_def||
                      ',trx_acct_def_type = '||p_trx_acct_def_type
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

      OPEN c_seg_rules;
      LOOP
      FETCH c_seg_rules
       INTO l_seg_rule;
      EXIT WHEN c_seg_rules%NOTFOUND or l_return=FALSE;

         IF xla_seg_rules_pkg.uncompile_tran_acct_def
              (p_application_id         => l_seg_rule.application_id
              ,p_amb_context_code       => l_seg_rule.amb_context_code
              ,p_segment_rule_type_code => l_seg_rule.segment_rule_type_code
              ,p_segment_rule_code      => l_seg_rule.segment_rule_code
              ,p_application_name       => l_application_name
              ,p_trx_acct_def           => l_trx_acct_def
              ,p_trx_acct_def_type      => l_trx_acct_def_type) THEN

            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
      END LOOP;
      CLOSE c_seg_rules;

   p_trx_acct_def      := l_trx_acct_def;
   p_trx_acct_def_type := l_trx_acct_def_type;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure uncompile_tad_for_der_source'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;


   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.uncompile_tad_for_der_source');

END uncompile_tad_for_der_source;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| derived_source_locked_by_tab                                          |
|                                                                       |
| Returns true if the derived source is being used by a locked          |
| transaction account definition                                        |
|                                                                       |
+======================================================================*/
FUNCTION derived_source_locked_by_tab
  (p_der_application_id                   IN NUMBER
  ,p_der_source_code                      IN VARCHAR2
  ,p_der_source_type_code                 IN VARCHAR2)
RETURN BOOLEAN

IS

   --
   -- Private variables
   --
   l_exist   VARCHAR2(1) ;
   l_return  BOOLEAN;

   --
   -- Cursor declarations
   --

   CURSOR check_sr_conditions
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE ((source_application_id       = p_der_application_id
      AND  source_code                 = p_der_source_code
      AND  source_type_code            = p_der_source_type_code)
       OR (value_source_application_id = p_der_application_id
      AND  value_source_type_code      = p_der_source_type_code
      AND  value_source_code           = p_der_source_code
      AND  value_source_code IS NOT NULL))
      AND  exists (SELECT 'x'
                    FROM xla_seg_rule_details sd,
                         xla_tab_acct_def_details pl, xla_tab_acct_defs_b p
                   WHERE sd.segment_rule_detail_id  = c.segment_rule_detail_id
                     AND pl.application_id          = sd.application_id
                     AND pl.amb_context_code        = sd.amb_context_code
                     AND pl.segment_rule_type_code  = sd.segment_rule_type_code
                     AND pl.segment_rule_code       = sd.segment_rule_code
                     AND pl.application_id          = p.application_id
                     AND pl.amb_context_code        = p.amb_context_code
                     AND pl.account_definition_type_code  = p.account_definition_type_code
                     AND pl.account_definition_code  = p.account_definition_code
                     AND p.locking_status_flag       = 'Y');


   CURSOR check_sr_details
   IS
   SELECT 'x'
     FROM xla_seg_rule_details sd
    WHERE ((value_source_application_id       = p_der_application_id
      AND  value_source_type_code            = p_der_source_type_code
      AND  value_source_code                 = p_der_source_code)
       OR (input_source_application_id       = p_der_application_id
      AND  input_source_type_code            = p_der_source_type_code
      AND  input_source_code                 = p_der_source_code
      AND  input_source_code IS NOT NULL))
      AND  exists (SELECT 'x'
                    FROM xla_tab_acct_def_details pl, xla_tab_acct_defs_b p
                   WHERE pl.application_id          = sd.application_id
                     AND pl.amb_context_code        = sd.amb_context_code
                     AND pl.segment_rule_type_code  = sd.segment_rule_type_code
                     AND pl.segment_rule_code       = sd.segment_rule_code
                     AND pl.application_id          = p.application_id
                     AND pl.amb_context_code        = p.amb_context_code
                     AND pl.account_definition_type_code  = p.account_definition_type_code
                     AND pl.account_definition_code  = p.account_definition_code
                     AND p.locking_status_flag       = 'Y');

   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.derived_source_locked_by_tab';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure derived_source_locked_by_tab'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_der_application_id||
                      ',source_code = '||p_der_source_code||
                      ',source_type_code = '||p_der_source_type_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   IF p_der_source_type_code = 'D' THEN

         OPEN check_sr_conditions;
         FETCH check_sr_conditions
          INTO l_exist;
         IF check_sr_conditions%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_sr_conditions;

      IF l_return = FALSE THEN

         OPEN check_sr_details;
         FETCH check_sr_details
          INTO l_exist;
         IF check_sr_details%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_sr_details;
      END IF;
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure derived_source_locked_by_tab'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN

      IF check_sr_details%ISOPEN THEN
         CLOSE check_sr_details;
      END IF;
      IF check_sr_conditions%ISOPEN THEN
         CLOSE check_sr_conditions;
      END IF;

      RAISE;

WHEN OTHERS                                   THEN

      IF check_sr_details%ISOPEN THEN
         CLOSE check_sr_details;
      END IF;
      IF check_sr_conditions%ISOPEN THEN
         CLOSE check_sr_conditions;
      END IF;

   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.derived_source_locked_by_tab');

END derived_source_locked_by_tab;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| uncompile_pad_for_der_source                                          |
|                                                                       |
| Sets status of assigned product rule to uncompiled for a              |
| derived source                                                        |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_pad_for_der_source
  (p_der_application_id                   IN NUMBER
  ,p_der_source_code                      IN VARCHAR2
  ,p_der_source_type_code                 IN VARCHAR2
  ,x_product_rule_name                    IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                    IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                     IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                      IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag                  IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS

   --
   -- Private variables
   --
   l_exist   VARCHAR2(1) ;
   l_return  BOOLEAN := TRUE;

   l_application_name       varchar2(240) := null;
   l_product_rule_name      varchar2(80)  := null;
   l_product_rule_type      varchar2(80)  := null;
   l_event_class_name       varchar2(80)  := null;
   l_event_type_name        varchar2(80)  := null;
   l_line_definition_name   varchar2(80)  := null;
   l_line_definition_owner  varchar2(80)  := NULL;
   l_locking_status_flag    varchar2(1)   := NULL;

   --
   -- Cursor declarations
   --

   CURSOR c_analytical
   IS
   SELECT amb_context_code, analytical_criterion_code, analytical_criterion_type_code
     FROM xla_analytical_hdrs_b a
    WHERE exists (SELECT 'x'
                    FROM xla_analytical_sources r
                   WHERE source_application_id            = p_der_application_id
                     AND source_code                      = p_der_source_code
                     AND source_type_code                 = p_der_source_type_code
                     AND r.analytical_criterion_code      = a.analytical_criterion_code
                     AND r.analytical_criterion_type_code = a.analytical_criterion_type_code);

   l_analytical   c_analytical%rowtype;


   CURSOR c_descriptions
   IS
   SELECT x.application_id, x.amb_context_code,
          x.description_type_code, x.description_code
     FROM xla_descriptions_b x
    WHERE exists (SELECT 'x'
                    FROM xla_descript_details_b d, xla_desc_priorities dp
                   WHERE d.source_application_id   = p_der_application_id
                     AND d.source_code             = p_der_source_code
                     AND d.source_type_code        = p_der_source_type_code
                     AND d.source_code is not null
                     AND dp.description_prio_id    = d.description_prio_id
                     AND dp.application_id         = x.application_id
                     AND dp.amb_context_code       = x.amb_context_code
                     AND dp.description_type_code  = x.description_type_code
                     AND dp.description_code       = x.description_code
                  UNION
                  SELECT 'x'
                    FROM xla_conditions c, xla_desc_priorities dp
                   WHERE ((c.source_application_id      = p_der_application_id
                     AND  c.source_code                 = p_der_source_code
                     AND  c.source_type_code            = p_der_source_type_code)
                      OR (c.value_source_application_id = p_der_application_id
                     AND  c.value_source_type_code      = p_der_source_type_code
                     AND  c.value_source_code           = p_der_source_code
                     AND  c.value_source_code IS NOT NULL))
                     AND dp.description_prio_id         = c.description_prio_id
                     AND dp.application_id              = x.application_id
                     AND dp.amb_context_code            = x.amb_context_code
                     AND dp.description_type_code       = x.description_type_code
                     AND dp.description_code            = x.description_code);

   l_description   c_descriptions%rowtype;

   CURSOR c_seg_rules
   IS
   SELECT a.application_id, a.amb_context_code, a.segment_rule_type_code, a.segment_rule_code
     FROM xla_seg_rules_b a
    WHERE exists (SELECT 'x'
                    FROM xla_seg_rule_details sd
                   WHERE ((value_source_application_id      = p_der_application_id
                     AND  value_source_type_code            = p_der_source_type_code
                     AND  value_source_code                 = p_der_source_code)
                      OR (input_source_application_id       = p_der_application_id
                     AND  input_source_type_code            = p_der_source_type_code
                     AND  input_source_code                 = p_der_source_code
                     AND  input_source_code IS NOT NULL))
                     AND sd.application_id                  = a.application_id
                     AND sd.amb_context_code                = a.amb_context_code
                     AND sd.segment_rule_type_code          = a.segment_rule_type_code
                     AND sd.segment_rule_code               = a.segment_rule_code
                  UNION
                  SELECT 'x'
                    FROM xla_conditions c, xla_seg_rule_details sd
                   WHERE ((c.source_application_id      = p_der_application_id
                     AND  c.source_code                 = p_der_source_code
                     AND  c.source_type_code            = p_der_source_type_code)
                      OR (c.value_source_application_id = p_der_application_id
                     AND  c.value_source_type_code      = p_der_source_type_code
                     AND  c.value_source_code           = p_der_source_code
                     AND  c.value_source_code IS NOT NULL))
                     AND c.segment_rule_detail_id       = sd.segment_rule_detail_id
                     AND sd.application_id              = a.application_id
                     AND sd.amb_context_code            = a.amb_context_code
                     AND sd.segment_rule_type_code      = a.segment_rule_type_code
                     AND sd.segment_rule_code           = a.segment_rule_code);

   l_seg_rule   c_seg_rules%rowtype;

   CURSOR c_line_types
   IS
   SELECT a.application_id, a.amb_context_code, a.entity_code, a.event_class_code,
          a.accounting_line_type_code, a.accounting_line_code
     FROM xla_acct_line_types_b a
         ,xla_conditions        c
    WHERE a.application_id               = c.application_id
      AND a.amb_context_code             = c.amb_context_code
      AND a.entity_code                  = c.entity_code
      AND a.event_class_code             = c.event_class_code
      AND a.accounting_line_type_code    = c.accounting_line_type_code
      AND a.accounting_line_code         = c.accounting_line_code
  	  AND ((c.source_application_id      = p_der_application_id
      AND c.source_code                  = p_der_source_code
      AND c.source_type_code             = p_der_source_type_code)
       OR (c.value_source_application_id = p_der_application_id
	  AND c.value_source_type_code       = p_der_source_type_code
      AND c.value_source_code            = p_der_source_code
      AND c.value_source_code IS NOT NULL))
    UNION
   SELECT a.application_id, a.amb_context_code, a.entity_code, a.event_class_code,
          a.accounting_line_type_code, a.accounting_line_code
     FROM xla_acct_line_types_b a
         ,xla_jlt_acct_attrs    r
    WHERE a.application_id               = r.application_id
      AND a.amb_context_code             = r.amb_context_code
      AND a.event_class_code             = r.event_class_code
      AND a.accounting_line_type_code    = r.accounting_line_type_code
      AND a.accounting_line_code         = r.accounting_line_code
      AND r.source_application_id        = p_der_application_id
      AND r.source_code                  = p_der_source_code
      AND r.source_type_code             = p_der_source_type_code
      AND r.source_code IS NOT NULL;

   l_line_type   c_line_types%rowtype;

   CURSOR c_aad
   IS
   SELECT application_id, amb_context_code, product_rule_type_code, product_rule_code
     FROM xla_product_rules_b a
    WHERE exists (SELECT 'x'
                    FROM xla_aad_hdr_acct_attrs r
                   WHERE source_application_id        = p_der_application_id
                     AND source_code                  = p_der_source_code
                     AND source_type_code             = p_der_source_type_code
                     AND source_code is not null
                     AND r.application_id             = a.application_id
                     AND r.amb_context_code           = a.amb_context_code
                     AND r.product_rule_type_code     = a.product_rule_type_code
                     AND r.product_rule_code          = a.product_rule_code);

   l_aad   c_aad%rowtype;


   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.uncompile_pad_for_der_source';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure uncompile_pad_for_der_source'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_der_application_id||
                      ',source_code = '||p_der_source_code||
                      ',source_type_code = '||p_der_source_type_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   OPEN c_analytical;
   LOOP
   FETCH c_analytical
    INTO l_analytical;
   EXIT WHEN c_analytical%NOTFOUND or l_return=FALSE;


      IF xla_analytical_hdrs_pkg.uncompile_definitions
           (p_amb_context_code           => l_analytical.amb_context_code
           ,p_analytical_criterion_code  => l_analytical.analytical_criterion_code
           ,p_anal_criterion_type_code   => l_analytical.analytical_criterion_type_code
           ,x_product_rule_name          => l_product_rule_name
           ,x_product_rule_type          => l_product_rule_type
           ,x_event_class_name           => l_event_class_name
           ,x_event_type_name            => l_event_type_name
           ,x_locking_status_flag        => l_locking_status_flag) THEN

         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
   END LOOP;
   CLOSE c_analytical;

   IF l_return = TRUE THEN
      OPEN c_descriptions;
      LOOP
      FETCH c_descriptions
       INTO l_description;
      EXIT WHEN c_descriptions%NOTFOUND or l_return=FALSE;

         IF xla_descriptions_pkg.uncompile_definitions
              (p_application_id        => l_description.application_id
              ,p_amb_context_code      => l_description.amb_context_code
              ,p_description_type_code => l_description.description_type_code
              ,p_description_code      => l_description.description_code
              ,x_product_rule_name     => l_product_rule_name
              ,x_product_rule_type     => l_product_rule_type
              ,x_event_class_name      => l_event_class_name
              ,x_event_type_name       => l_event_type_name
              ,x_locking_status_flag   => l_locking_status_flag) THEN

            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
      END LOOP;

      CLOSE c_descriptions;
   END IF;


   IF l_return = TRUE THEN
      OPEN c_seg_rules;
      LOOP
      FETCH c_seg_rules
       INTO l_seg_rule;
      EXIT WHEN c_seg_rules%NOTFOUND or l_return=FALSE;

         IF xla_seg_rules_pkg.uncompile_definitions
              (p_application_id         => l_seg_rule.application_id
              ,p_amb_context_code       => l_seg_rule.amb_context_code
              ,p_segment_rule_type_code => l_seg_rule.segment_rule_type_code
              ,p_segment_rule_code      => l_seg_rule.segment_rule_code
              ,x_product_rule_name      => l_product_rule_name
              ,x_product_rule_type      => l_product_rule_type
              ,x_event_class_name       => l_event_class_name
              ,x_event_type_name        => l_event_type_name
              ,x_locking_status_flag    => l_locking_status_flag) THEN

            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
      END LOOP;
      CLOSE c_seg_rules;
   END IF;


   IF l_return = TRUE THEN
      OPEN c_line_types;
      LOOP
      FETCH c_line_types
       INTO l_line_type;
      EXIT WHEN c_line_types%NOTFOUND or l_return=FALSE;

         IF xla_line_types_pkg.uncompile_definitions
              (p_application_id            => l_line_type.application_id
              ,p_amb_context_code          => l_line_type.amb_context_code
              ,p_event_class_code          => l_line_type.event_class_code
              ,p_accounting_line_type_code => l_line_type.accounting_line_type_code
              ,p_accounting_line_code      => l_line_type.accounting_line_code
              ,x_product_rule_name         => l_product_rule_name
              ,x_product_rule_type         => l_product_rule_type
              ,x_event_class_name          => l_event_class_name
              ,x_event_type_name           => l_event_type_name
              ,x_locking_status_flag       => l_locking_status_flag) THEN

            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
      END LOOP;
      CLOSE c_line_types;
   END IF;

   IF l_return = TRUE THEN
      OPEN c_aad;
      LOOP
      FETCH c_aad
       INTO l_aad;
      EXIT WHEN c_aad%NOTFOUND or l_return=FALSE;

         IF xla_product_rules_pkg.uncompile_product_rule
              (p_application_id            => l_aad.application_id
              ,p_amb_context_code          => l_aad.amb_context_code
              ,p_product_rule_type_code    => l_aad.product_rule_type_code
              ,p_product_rule_code         => l_aad.product_rule_code) THEN

            l_return := TRUE;
         ELSE
            xla_validations_pkg.get_product_rule_info
              (p_application_id          => l_aad.application_id
              ,p_amb_context_code        => l_aad.amb_context_code
              ,p_product_rule_type_code  => l_aad.product_rule_type_code
              ,p_product_rule_code       => l_aad.product_rule_code
              ,p_application_name        => l_application_name
              ,p_product_rule_name       => l_product_rule_name
              ,p_product_rule_type       => l_product_rule_type);
            l_return := FALSE;
         END IF;
      END LOOP;
      CLOSE c_aad;
   END IF;

   x_product_rule_name     := l_product_rule_name;
   x_product_rule_type     := l_product_rule_type;
   x_event_class_name      := l_event_class_name;
   x_event_type_name       := l_event_type_name;
   x_locking_status_flag   := l_locking_status_flag;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure uncompile_pad_for_der_source'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.uncompile_pad_for_der_source');

END uncompile_pad_for_der_source;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| derived_source_is_locked                                              |
|                                                                       |
| Returns true if the derived source is being used by a locked          |
| product rule                                                          |
|                                                                       |
+======================================================================*/
FUNCTION derived_source_is_locked
  (p_der_application_id                   IN NUMBER
  ,p_der_source_code                      IN VARCHAR2
  ,p_der_source_type_code                 IN VARCHAR2)
RETURN BOOLEAN

IS

   --
   -- Private variables
   --
   l_exist   VARCHAR2(1) ;
   l_return  BOOLEAN;

   --
   -- Cursor declarations
   --
   CURSOR check_analytical
   IS
   SELECT 'x'
     FROM xla_analytical_sources xas
    WHERE source_application_id   = p_der_application_id
      AND source_code             = p_der_source_code
      AND source_type_code        = p_der_source_type_code
      AND exists (SELECT 'x'
                    FROM xla_aad_header_ac_assgns xah
                       , xla_prod_acct_headers    xpa
                   WHERE xah.amb_context_code               = xas.amb_context_code
                     AND xah.analytical_criterion_code      = xas.analytical_criterion_code
                     AND xah.analytical_criterion_type_code = xas.analytical_criterion_type_code
                     AND xpa.application_id                 = xah.application_id
                     AND xpa.amb_context_code               = xah.amb_context_code
                     AND xpa.product_rule_type_code         = xah.product_rule_type_code
                     AND xpa.product_rule_code              = xah.product_rule_code
                     AND xpa.event_class_code               = xah.event_class_code
                     AND xpa.event_type_code                = xah.event_type_code
                     AND xpa.locking_status_flag            = 'Y'
                   UNION
                  SELECT 'x'
                    FROM xla_line_defn_ac_assgns  xld
                       , xla_aad_line_defn_assgns xal
                       , xla_prod_acct_headers    xpa
                   WHERE xld.amb_context_code               = xas.amb_context_code
                     AND xld.analytical_criterion_code      = xas.analytical_criterion_code
                     AND xld.analytical_criterion_type_code = xas.analytical_criterion_type_code
                     AND xal.application_id                 = xld.application_id
                     AND xal.amb_context_code               = xld.amb_context_code
                     AND xal.event_class_code               = xld.event_class_code
                     AND xal.event_type_code                = xld.event_type_code
                     AND xal.line_definition_owner_code     = xld.line_definition_owner_code
                     AND xal.line_definition_code           = xld.line_definition_code
                     AND xpa.application_id                 = xal.application_id
                     AND xpa.amb_context_code               = xal.amb_context_code
                     AND xpa.product_rule_type_code         = xal.product_rule_type_code
                     AND xpa.product_rule_code              = xal.product_rule_code
                     AND xpa.event_class_code               = xal.event_class_code
                     AND xpa.event_type_code                = xal.event_type_code
                     AND xpa.locking_status_flag            = 'Y');

   CURSOR check_descript_details
   IS
   SELECT 'x'
     FROM xla_descript_details_b xdd
    WHERE source_application_id   = p_der_application_id
      AND source_code             = p_der_source_code
      AND source_type_code        = p_der_source_type_code
      AND source_code is not null
      AND exists (SELECT 'x'
                    FROM xla_desc_priorities      xdp
                       , xla_line_defn_jlt_assgns xld
                       , xla_aad_line_defn_assgns xal
                       , xla_prod_acct_headers    xpa
                   WHERE xdp.description_prio_id        = xdd.description_prio_id
                     AND xld.application_id             = xdp.application_id
                     AND xld.amb_context_code           = xdp.amb_context_code
                     AND xld.description_type_code      = xdp.description_type_code
                     AND xld.description_code           = xdp.description_code
                     AND xal.application_id             = xld.application_id
                     AND xal.amb_context_code           = xld.amb_context_code
                     AND xal.event_class_code           = xld.event_class_code
                     AND xal.event_type_code            = xld.event_type_code
                     AND xal.line_definition_owner_code = xld.line_definition_owner_code
                     AND xal.line_definition_code       = xld.line_definition_code
                     AND xpa.application_id             = xal.application_id
                     AND xpa.amb_context_code           = xal.amb_context_code
                     AND xpa.product_rule_type_code     = xal.product_rule_type_code
                     AND xpa.product_rule_code          = xal.product_rule_code
                     AND xpa.event_class_code           = xal.event_class_code
                     AND xpa.event_type_code            = xal.event_type_code
                     AND xpa.locking_status_flag        = 'Y'
                   UNION
                  SELECT 'x'
                    FROM xla_desc_priorities   xdp
                       , xla_prod_acct_headers xpa
                   WHERE xdp.description_prio_id     = xdd.description_prio_id
                     AND xpa.application_id          = xdp.application_id
                     AND xpa.amb_context_code        = xdp.amb_context_code
                     AND xpa.description_type_code   = xdp.description_type_code
                     AND xpa.description_code        = xdp.description_code
                     AND xpa.locking_status_flag     = 'Y');

   CURSOR check_desc_conditions
   IS
   SELECT 'x'
     FROM xla_conditions xco
    WHERE ((source_application_id      = p_der_application_id
      AND  source_code                 = p_der_source_code
      AND  source_type_code            = p_der_source_type_code)
       OR (value_source_application_id = p_der_application_id
      AND  value_source_type_code      = p_der_source_type_code
      AND  value_source_code           = p_der_source_code
      AND  value_source_code IS NOT NULL))
      AND  exists (SELECT 'x'
                    FROM xla_desc_priorities      xdp,
                         xla_line_defn_jlt_assgns xld,
                         xla_aad_line_defn_assgns xal,
                         xla_prod_acct_headers    xpa
                   WHERE xdp.description_prio_id        = xco.description_prio_id
                     AND xld.application_id             = xdp.application_id
                     AND xld.amb_context_code           = xdp.amb_context_code
                     AND xld.description_type_code      = xdp.description_type_code
                     AND xld.description_code           = xdp.description_code
                     AND xal.application_id             = xld.application_id
                     AND xal.amb_context_code           = xld.amb_context_code
                     AND xal.event_class_code           = xld.event_class_code
                     AND xal.event_type_code            = xld.event_type_code
                     AND xal.line_definition_owner_code = xld.line_definition_owner_code
                     AND xal.line_definition_code       = xld.line_definition_code
                     AND xpa.application_id             = xal.application_id
                     AND xpa.amb_context_code           = xal.amb_context_code
                     AND xpa.product_rule_type_code     = xal.product_rule_type_code
                     AND xpa.product_rule_code          = xal.product_rule_code
                     AND xpa.event_class_code           = xal.event_class_code
                     AND xpa.event_type_code            = xal.event_type_code
                     AND xpa.locking_status_flag        = 'Y');

   CURSOR check_sr_conditions
   IS
   SELECT 'x'
     FROM xla_conditions xco
    WHERE ((source_application_id      = p_der_application_id
      AND  source_code                 = p_der_source_code
      AND  source_type_code            = p_der_source_type_code)
       OR (value_source_application_id = p_der_application_id
      AND  value_source_type_code      = p_der_source_type_code
      AND  value_source_code           = p_der_source_code
      AND  value_source_code IS NOT NULL))
      AND  exists (SELECT 'x'
                    FROM xla_seg_rule_details     xsd,
                         xla_line_defn_adr_assgns xld,
                         xla_aad_line_defn_assgns xal,
                         xla_prod_acct_headers    xpa
                   WHERE xsd.segment_rule_detail_id     = xco.segment_rule_detail_id
                     AND xld.application_id             = xsd.application_id
                     AND xld.amb_context_code           = xsd.amb_context_code
                     AND xld.segment_rule_type_code     = xsd.segment_rule_type_code
                     AND xld.segment_rule_code          = xsd.segment_rule_code
                     AND xal.application_id             = xld.application_id
                     AND xal.amb_context_code           = xld.amb_context_code
                     AND xal.event_class_code           = xld.event_class_code
                     AND xal.event_type_code            = xld.event_type_code
                     AND xal.line_definition_owner_code = xld.line_definition_owner_code
                     AND xal.line_definition_code       = xld.line_definition_code
                     AND xpa.application_id             = xal.application_id
                     AND xpa.amb_context_code           = xal.amb_context_code
                     AND xpa.product_rule_type_code     = xal.product_rule_type_code
                     AND xpa.product_rule_code          = xal.product_rule_code
                     AND xpa.event_class_code           = xal.event_class_code
                     AND xpa.event_type_code            = xal.event_type_code
                     AND xpa.locking_status_flag        = 'Y');

   CURSOR check_lt_conditions
   IS
   SELECT 'x'
     FROM xla_conditions xco
    WHERE ((source_application_id      = p_der_application_id
      AND  source_code                 = p_der_source_code
      AND  source_type_code            = p_der_source_type_code)
       OR (value_source_application_id = p_der_application_id
      AND  value_source_type_code      = p_der_source_type_code
      AND  value_source_code           = p_der_source_code
      AND  value_source_code IS NOT NULL))
      AND  exists (SELECT 'x'
                    FROM xla_line_defn_jlt_assgns xld,
                         xla_aad_line_defn_assgns xal,
                         xla_prod_acct_headers    xpa
                   WHERE xld.application_id             = xco.application_id
                     AND xld.amb_context_code           = xco.amb_context_code
                     AND xld.event_class_code           = xco.event_class_code
                     AND xld.accounting_line_type_code  = xco.accounting_line_type_code
                     AND xld.accounting_line_code       = xco.accounting_line_code
                     AND xal.application_id             = xld.application_id
                     AND xal.amb_context_code           = xld.amb_context_code
                     AND xal.event_class_code           = xld.event_class_code
                     AND xal.event_type_code            = xld.event_type_code
                     AND xal.line_definition_owner_code = xld.line_definition_owner_code
                     AND xal.line_definition_code       = xld.line_definition_code
                     AND xpa.application_id             = xal.application_id
                     AND xpa.amb_context_code           = xal.amb_context_code
                     AND xpa.product_rule_type_code     = xal.product_rule_type_code
                     AND xpa.product_rule_code          = xal.product_rule_code
                     AND xpa.event_class_code           = xal.event_class_code
                     AND xpa.event_type_code            = xal.event_type_code
                     AND xpa.locking_status_flag        = 'Y');

   CURSOR check_sr_details
   IS
   SELECT 'x'
     FROM xla_seg_rule_details xsr
    WHERE ((value_source_application_id      = p_der_application_id
      AND  value_source_type_code            = p_der_source_type_code
      AND  value_source_code                 = p_der_source_code)
       OR (input_source_application_id       = p_der_application_id
      AND  input_source_type_code            = p_der_source_type_code
      AND  input_source_code                 = p_der_source_code
      AND  input_source_code IS NOT NULL))
      AND  exists (SELECT 'x'
                    FROM xla_line_defn_adr_assgns xld,
                         xla_aad_line_defn_assgns xal,
                         xla_prod_acct_headers    xpa
                   WHERE xld.application_id             = xsr.application_id
                     AND xld.amb_context_code           = xsr.amb_context_code
                     AND xld.segment_rule_type_code     = xsr.segment_rule_type_code
                     AND xld.segment_rule_code          = xsr.segment_rule_code
                     AND xal.application_id             = xld.application_id
                     AND xal.amb_context_code           = xld.amb_context_code
                     AND xal.event_class_code           = xld.event_class_code
                     AND xal.event_type_code            = xld.event_type_code
                     AND xal.line_definition_owner_code = xld.line_definition_owner_code
                     AND xal.line_definition_code       = xld.line_definition_code
                     AND xpa.application_id             = xal.application_id
                     AND xpa.amb_context_code           = xal.amb_context_code
                     AND xpa.product_rule_type_code     = xal.product_rule_type_code
                     AND xpa.product_rule_code          = xal.product_rule_code
                     AND xpa.event_class_code           = xal.event_class_code
                     AND xpa.event_type_code            = xal.event_type_code
                     AND xpa.locking_status_flag        = 'Y');



   CURSOR check_line_types
   IS
   SELECT 'x'
     FROM xla_jlt_acct_attrs xja
    WHERE source_application_id   = p_der_application_id
      AND source_code             = p_der_source_code
      AND source_type_code        = p_der_source_type_code
      AND  exists (SELECT 'x'
                    FROM xla_line_defn_jlt_assgns xld,
                         xla_aad_line_defn_assgns xal,
                         xla_prod_acct_headers    xpa
                   WHERE xld.application_id             = xja.application_id
                     AND xld.amb_context_code           = xja.amb_context_code
                     AND xld.event_class_code           = xja.event_class_code
                     AND xld.accounting_line_type_code  = xja.accounting_line_type_code
                     AND xld.accounting_line_code       = xja.accounting_line_code
                     AND xal.application_id             = xld.application_id
                     AND xal.amb_context_code           = xld.amb_context_code
                     AND xal.event_class_code           = xld.event_class_code
                     AND xal.event_type_code            = xld.event_type_code
                     AND xal.line_definition_owner_code = xld.line_definition_owner_code
                     AND xal.line_definition_code       = xld.line_definition_code
                     AND xpa.application_id             = xal.application_id
                     AND xpa.amb_context_code           = xal.amb_context_code
                     AND xpa.product_rule_type_code     = xal.product_rule_type_code
                     AND xpa.product_rule_code          = xal.product_rule_code
                     AND xpa.event_class_code           = xal.event_class_code
                     AND xpa.event_type_code            = xal.event_type_code
                     AND xpa.locking_status_flag        = 'Y');

   CURSOR check_aad
   IS
   SELECT 'x'
     FROM DUAL
    WHERE EXISTS (SELECT 'x'
                    FROM xla_aad_hdr_acct_attrs xah, xla_prod_acct_headers xpa
                   WHERE xah.source_application_id   = p_der_application_id
                     AND xah.source_code             = p_der_source_code
                     AND xah.source_type_code        = p_der_source_type_code
                     AND xah.source_type_code        IS NOT NULL
                     AND xpa.application_id          = xah.application_id
                     AND xpa.amb_context_code        = xah.amb_context_code
                     AND xpa.product_rule_type_code  = xah.product_rule_type_code
                     AND xpa.product_rule_code       = xah.product_rule_code
                     AND xpa.event_class_code        = xah.event_class_code
                     AND xpa.event_type_code         = xah.event_type_code
                     AND xpa.locking_status_flag     = 'Y');


   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.derived_source_is_locked';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure derived_source_is_locked'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_der_application_id||
                      ',source_code = '||p_der_source_code||
                      ',source_type_code = '||p_der_source_type_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   IF p_der_source_type_code = 'D' THEN

      OPEN check_analytical;
      FETCH check_analytical
       INTO l_exist;
      IF check_analytical%found THEN
         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE check_analytical;

      IF l_return = FALSE THEN

         OPEN check_descript_details;
         FETCH check_descript_details
          INTO l_exist;
         IF check_descript_details%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_descript_details;
      END IF;

      IF l_return = FALSE THEN

         OPEN check_desc_conditions;
         FETCH check_desc_conditions
          INTO l_exist;
         IF check_desc_conditions%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_desc_conditions;
      END IF;

      IF l_return = FALSE THEN

         OPEN check_sr_conditions;
         FETCH check_sr_conditions
          INTO l_exist;
         IF check_sr_conditions%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_sr_conditions;
      END IF;


      IF l_return = FALSE THEN

         OPEN check_lt_conditions;
         FETCH check_lt_conditions
          INTO l_exist;
         IF check_lt_conditions%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_lt_conditions;
      END IF;

      IF l_return = FALSE THEN

         OPEN check_sr_details;
         FETCH check_sr_details
          INTO l_exist;
         IF check_sr_details%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_sr_details;
      END IF;


      IF l_return = FALSE THEN

         OPEN check_line_types;
         FETCH check_line_types
          INTO l_exist;
         IF check_line_types%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_line_types;
      END IF;

      IF l_return = FALSE THEN

         OPEN check_aad;
         FETCH check_aad
          INTO l_exist;
         IF check_aad%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_aad;
      END IF;

   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure derived_source_is_locked'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN

      IF check_analytical%ISOPEN THEN
         CLOSE check_analytical;
      END IF;
      IF check_descript_details%ISOPEN THEN
         CLOSE check_descript_details;
      END IF;
      IF check_sr_details%ISOPEN THEN
         CLOSE check_sr_details;
      END IF;
      IF check_lt_conditions%ISOPEN THEN
         CLOSE check_lt_conditions;
      END IF;
      IF check_sr_conditions%ISOPEN THEN
         CLOSE check_sr_conditions;
      END IF;
      IF check_desc_conditions%ISOPEN THEN
         CLOSE check_desc_conditions;
      END IF;
      IF check_line_types%ISOPEN THEN
         CLOSE check_line_types;
      END IF;

      RAISE;

WHEN OTHERS                                   THEN

      IF check_analytical%ISOPEN THEN
         CLOSE check_analytical;
      END IF;
      IF check_sr_details%ISOPEN THEN
         CLOSE check_sr_details;
      END IF;
      IF check_lt_conditions%ISOPEN THEN
         CLOSE check_lt_conditions;
      END IF;
      IF check_sr_conditions%ISOPEN THEN
         CLOSE check_sr_conditions;
      END IF;
      IF check_desc_conditions%ISOPEN THEN
         CLOSE check_desc_conditions;
      END IF;
      IF check_descript_details%ISOPEN THEN
         CLOSE check_descript_details;
      END IF;
      IF check_line_types%ISOPEN THEN
         CLOSE check_line_types;
      END IF;

   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.derived_source_is_locked');

END derived_source_is_locked;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| source_in_use                                                         |
|                                                                       |
| Returns true if the source is being used                              |
|                                                                       |
+======================================================================*/
FUNCTION source_in_use
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_source_msg                       OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS

   --
   -- Private variables
   --
   l_exist   VARCHAR2(1) ;
   l_return  BOOLEAN;

   --
   -- Cursor declarations
   --
   CURSOR check_entity_sources
   IS
   SELECT 'x'
     FROM xla_event_sources
    WHERE source_application_id   = p_application_id
      AND source_code             = p_source_code
      AND source_type_code        = p_source_type_code;

   CURSOR check_ssa_acctg_sources
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs
    WHERE source_application_id   = p_application_id
      AND source_code             = p_source_code
      AND source_type_code        = p_source_type_code;

   CURSOR check_source_params
   IS
   SELECT 'x'
     FROM xla_source_params
    WHERE ref_source_application_id   = p_application_id
      AND ref_source_code             = p_source_code
      AND ref_source_type_code        = p_source_type_code;

   CURSOR check_analytical
   IS
   SELECT 'x'
     FROM xla_analytical_sources
    WHERE source_application_id   = p_application_id
      AND source_code             = p_source_code
      AND source_type_code        = p_source_type_code;

   CURSOR check_acct_line_sources
   IS
   SELECT 'x'
     FROM xla_jlt_acct_attrs
    WHERE source_application_id   = p_application_id
      AND source_code             = p_source_code
      AND source_type_code        = p_source_type_code;

   CURSOR check_aad_acct_attr
   IS
   SELECT 'x'
     FROM xla_aad_hdr_acct_attrs
    WHERE source_application_id   = p_application_id
      AND source_code             = p_source_code
      AND source_type_code        = p_source_type_code;

   CURSOR check_descript_details
   IS
   SELECT 'x'
     FROM xla_descript_details_b
    WHERE source_application_id   = p_application_id
      AND source_code             = p_source_code
      AND source_type_code        = p_source_type_code
      AND source_code is not null;

   CURSOR check_seg_rule_details
   IS
   SELECT 'x'
     FROM DUAL
    WHERE EXISTS
          (SELECT 'x'
             FROM xla_seg_rule_details
            WHERE value_source_application_id = p_application_id
              AND value_source_code           = p_source_code
              AND value_source_type_code      = p_source_type_code
              AND value_source_code is not null
           UNION
           SELECT 'x'
             FROM xla_seg_rule_details
            WHERE input_source_application_id = p_application_id
              AND input_source_code           = p_source_code
              AND input_source_type_code      = p_source_type_code
              AND input_source_code is not null);

   CURSOR check_conditions
   IS
   SELECT 'x'
     FROM DUAL
    WHERE EXISTS
          (SELECT 'x'
             FROM xla_conditions
            WHERE source_application_id = p_application_id
              AND source_code           = p_source_code
              AND source_type_code      = p_source_type_code
           UNION
           SELECT 'x'
             FROM xla_conditions
            WHERE value_source_application_id = p_application_id
              AND value_source_code           = p_source_code
              AND value_source_type_code      = p_source_type_code
              AND value_source_code is not null);

   CURSOR check_input_source
   IS
   SELECT 'x'
     FROM xla_seg_rule_details
    WHERE input_source_application_id   = p_application_id
      AND input_source_code             = p_source_code
      AND input_source_type_code        = p_source_type_code
      AND input_source_code is not null;

   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.source_in_use';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure source_in_use'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'event = '||p_event||
                      ',application_id = '||p_application_id||
                      ',source_code = '||p_source_code||
                      ',source_type_code = '||p_source_type_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   IF p_source_type_code = 'S' THEN

      IF p_event in ('DELETE', 'DISABLE') THEN

         OPEN check_entity_sources;
         FETCH check_entity_sources
          INTO l_exist;
         IF check_entity_sources%found THEN
            l_return := TRUE;
            p_source_msg := 'XLA_AB_SOURCE_IN_ENTITIES';
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_entity_sources;

         IF l_return = FALSE THEN

            OPEN check_source_params;
            FETCH check_source_params
             INTO l_exist;
            IF check_source_params%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_CUSTOM_PARAMS';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_source_params;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_acct_line_sources;
            FETCH check_acct_line_sources
             INTO l_exist;
            IF check_acct_line_sources%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_JOURNAL_TYPE';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_acct_line_sources;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_aad_acct_attr;
            FETCH check_aad_acct_attr
             INTO l_exist;
            IF check_aad_acct_attr%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_HEADER_ASSGN';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_aad_acct_attr;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_analytical;
            FETCH check_analytical
             INTO l_exist;
            IF check_analytical%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_ANALYTICAL';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_analytical;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_descript_details;
            FETCH check_descript_details
             INTO l_exist;
            IF check_descript_details%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_DESCRIPTIONS';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_descript_details;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_seg_rule_details;
            FETCH check_seg_rule_details
             INTO l_exist;
            IF check_seg_rule_details%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_ADR';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_seg_rule_details;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_conditions;
            FETCH check_conditions
             INTO l_exist;
            IF check_conditions%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_CONDITIONS';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_conditions;
         END IF;

      ELSIF p_event  = 'UPDATE_DT' THEN

         OPEN check_ssa_acctg_sources;
         FETCH check_ssa_acctg_sources
          INTO l_exist;
         IF check_ssa_acctg_sources%found THEN
            l_return := TRUE;
            p_source_msg := 'XLA_AB_SOURCE_IN_EVENT_CLASS';
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_ssa_acctg_sources;

         IF l_return = FALSE THEN

            OPEN check_source_params;
            FETCH check_source_params
             INTO l_exist;
            IF check_source_params%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_CUSTOM_PARAMS';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_source_params;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_acct_line_sources;
            FETCH check_acct_line_sources
             INTO l_exist;
            IF check_acct_line_sources%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_JOURNAL_TYPE';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_acct_line_sources;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_aad_acct_attr;
            FETCH check_aad_acct_attr
             INTO l_exist;
            IF check_aad_acct_attr%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_HEADER_ASSGN';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_aad_acct_attr;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_analytical;
            FETCH check_analytical
             INTO l_exist;
            IF check_analytical%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_ANALYTICAL';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_analytical;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_descript_details;
            FETCH check_descript_details
             INTO l_exist;
            IF check_descript_details%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_DESCRIPTIONS';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_descript_details;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_seg_rule_details;
            FETCH check_seg_rule_details
             INTO l_exist;
            IF check_seg_rule_details%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_ADR';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_seg_rule_details;
         END IF;
         IF l_return = FALSE THEN

            OPEN check_conditions;
            FETCH check_conditions
             INTO l_exist;
            IF check_conditions%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_CONDITIONS';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_conditions;
         END IF;

      ELSIF p_event = ('UPDATE_VS') THEN

         OPEN check_input_source;
         FETCH check_input_source
          INTO l_exist;
         IF check_input_source%found THEN
            l_return := TRUE;
            p_source_msg := 'XLA_AB_SOURCE_IN_DESCRIPTIONS';
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_input_source;

         IF l_return = FALSE THEN

            OPEN check_conditions;
            FETCH check_conditions
             INTO l_exist;
            IF check_conditions%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_CONDITIONS';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_conditions;
         END IF;

      END IF;

   ELSIF p_source_type_code = 'D' THEN

      IF p_event in ('DELETE', 'DISABLE', 'UPDATE_DT') THEN

         OPEN check_acct_line_sources;
         FETCH check_acct_line_sources
          INTO l_exist;
         IF check_acct_line_sources%found THEN
            l_return := TRUE;
            p_source_msg := 'XLA_AB_SOURCE_IN_JOURNAL_TYPE';
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_acct_line_sources;

         IF l_return = FALSE THEN

            OPEN check_aad_acct_attr;
            FETCH check_aad_acct_attr
             INTO l_exist;
            IF check_aad_acct_attr%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_HEADER_ASSGN';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_aad_acct_attr;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_ssa_acctg_sources;
            FETCH check_ssa_acctg_sources
             INTO l_exist;
            IF check_ssa_acctg_sources%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_EVENT_CLASS';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_ssa_acctg_sources;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_analytical;
            FETCH check_analytical
             INTO l_exist;
            IF check_analytical%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_ANALYTICAL';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_analytical;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_descript_details;
            FETCH check_descript_details
             INTO l_exist;
            IF check_descript_details%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_DESCRIPTIONS';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_descript_details;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_seg_rule_details;
            FETCH check_seg_rule_details
             INTO l_exist;
            IF check_seg_rule_details%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_ADR';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_seg_rule_details;
         END IF;

         IF l_return = FALSE THEN

            OPEN check_conditions;
            FETCH check_conditions
             INTO l_exist;
            IF check_conditions%found THEN
               l_return := TRUE;
               p_source_msg := 'XLA_AB_SOURCE_IN_CONDITIONS';
            ELSE
               l_return := FALSE;
            END IF;
            CLOSE check_conditions;
         END IF;

      END IF;
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure source_in_use'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF check_acct_line_sources%ISOPEN THEN
         CLOSE check_acct_line_sources;
      END IF;
      IF check_analytical%ISOPEN THEN
         CLOSE check_analytical;
      END IF;
      IF check_conditions%ISOPEN THEN
         CLOSE check_conditions;
      END IF;
      IF check_input_source%ISOPEN THEN
         CLOSE check_input_source;
      END IF;
      IF check_seg_rule_details%ISOPEN THEN
         CLOSE check_seg_rule_details;
      END IF;
      IF check_descript_details%ISOPEN THEN
         CLOSE check_descript_details;
      END IF;
      IF check_source_params%ISOPEN THEN
         CLOSE check_source_params;
      END IF;
      IF check_entity_sources%ISOPEN THEN
         CLOSE check_entity_sources;
      END IF;

      RAISE;

WHEN OTHERS                                   THEN
      IF check_acct_line_sources%ISOPEN THEN
         CLOSE check_acct_line_sources;
      END IF;
      IF check_analytical%ISOPEN THEN
         CLOSE check_analytical;
      END IF;
      IF check_conditions%ISOPEN THEN
         CLOSE check_conditions;
      END IF;
      IF check_input_source%ISOPEN THEN
         CLOSE check_input_source;
      END IF;
      IF check_seg_rule_details%ISOPEN THEN
         CLOSE check_seg_rule_details;
      END IF;
      IF check_descript_details%ISOPEN THEN
         CLOSE check_descript_details;
      END IF;
      IF check_source_params%ISOPEN THEN
         CLOSE check_source_params;
      END IF;
      IF check_entity_sources%ISOPEN THEN
         CLOSE check_entity_sources;
      END IF;

   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.source_in_use');

END source_in_use;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| source_is_locked                                                      |
|                                                                       |
| Returns true if the source is being used by a locked product rule     |
|                                                                       |
+======================================================================*/
FUNCTION source_is_locked
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2)
RETURN BOOLEAN

IS

   --
   -- Private variables
   --
   l_exist   VARCHAR2(1);
   l_return  BOOLEAN;

   --
   -- Cursor declarations
   --

   CURSOR check_analytical
   IS
   SELECT 'x'
     FROM xla_analytical_sources xas
    WHERE source_application_id   = p_application_id
      AND source_code             = p_source_code
      AND source_type_code        = p_source_type_code
      AND exists (SELECT 'x'
                    FROM xla_aad_header_ac_assgns xah
                       , xla_prod_acct_headers    xpa
                   WHERE xah.amb_context_code               = xas.amb_context_code
                     AND xah.analytical_criterion_code      = xas.analytical_criterion_code
                     AND xah.analytical_criterion_type_code = xas.analytical_criterion_type_code
                     AND xpa.application_id                 = xah.application_id
                     AND xpa.amb_context_code               = xah.amb_context_code
                     AND xpa.product_rule_type_code         = xah.product_rule_type_code
                     AND xpa.product_rule_code              = xah.product_rule_code
                     AND xpa.event_class_code               = xah.event_class_code
                     AND xpa.event_type_code                = xah.event_type_code
                     AND xpa.locking_status_flag            = 'Y'
                   UNION
                  SELECT 'x'
                    FROM xla_line_defn_ac_assgns  xad
                       , xla_aad_line_defn_assgns xal
                       , xla_prod_acct_headers    xpa
                   WHERE xad.amb_context_code               = xas.amb_context_code
                     AND xad.analytical_criterion_code      = xas.analytical_criterion_code
                     AND xad.analytical_criterion_type_code = xas.analytical_criterion_type_code
                     AND xal.application_id                 = xad.application_id
                     AND xal.amb_context_code               = xad.amb_context_code
                     AND xal.event_class_code               = xad.event_class_code
                     AND xal.event_type_code                = xad.event_type_code
                     AND xal.line_definition_owner_code     = xad.line_definition_owner_code
                     AND xal.line_definition_code           = xad.line_definition_code
                     AND xpa.application_id                 = xal.application_id
                     AND xpa.amb_context_code               = xal.amb_context_code
                     AND xpa.event_class_code               = xal.event_class_code
                     AND xpa.event_type_code                = xal.event_type_code
                     AND xpa.product_rule_type_code         = xal.product_rule_type_code
                     AND xpa.product_rule_code              = xal.product_rule_code
                     AND xpa.locking_status_flag            = 'Y');

   CURSOR check_descript_details
   IS
   SELECT 'x'
     FROM xla_descript_details_b  xdd
    WHERE source_application_id   = p_application_id
      AND source_code             = p_source_code
      AND source_type_code        = p_source_type_code
      AND source_code is not null
      AND exists (SELECT 'x'
                    FROM xla_desc_priorities      xdp
                        ,xla_line_defn_jlt_assgns xjl
                        ,xla_aad_line_defn_assgns xal
                        ,xla_prod_acct_headers    xpa
                   WHERE xdp.description_prio_id        = xdd.description_prio_id
                     AND xjl.application_id             = xdp.application_id
                     AND xjl.amb_context_code           = xdp.amb_context_code
                     AND xjl.description_type_code      = xdp.description_type_code
                     AND xjl.description_code           = xdp.description_code
                     AND xal.application_id             = xjl.application_id
                     AND xal.amb_context_code           = xjl.amb_context_code
                     AND xal.event_class_code           = xjl.event_class_code
                     AND xal.event_type_code            = xjl.event_type_code
                     AND xal.line_definition_owner_code = xjl.line_definition_owner_code
                     AND xal.line_definition_code       = xjl.line_definition_code
                     AND xpa.application_id             = xal.application_id
                     AND xpa.amb_context_code           = xal.amb_context_code
                     AND xpa.event_class_code           = xal.event_class_code
                     AND xpa.event_type_code            = xal.event_type_code
                     AND xpa.product_rule_type_code     = xal.product_rule_type_code
                     AND xpa.product_rule_code          = xal.product_rule_code
                     AND xpa.locking_status_flag        = 'Y'
                   UNION
                  SELECT 'x'
                    FROM xla_desc_priorities   xdp
                       , xla_prod_acct_headers xpa
                   WHERE xdp.description_prio_id     = xdd.description_prio_id
                     AND xpa.application_id          = xdp.application_id
                     AND xpa.amb_context_code        = xdp.amb_context_code
                     AND xpa.description_type_code   = xdp.description_type_code
                     AND xpa.description_code        = xdp.description_code
                     AND xpa.locking_status_flag     = 'Y');

   CURSOR check_desc_conditions
   IS
   SELECT 'x'
     FROM xla_conditions xco
    WHERE ((source_application_id      = p_application_id
      AND  source_code                 = p_source_code
      AND  source_type_code            = p_source_type_code)
       OR (value_source_application_id = p_application_id
      AND  value_source_type_code      = p_source_type_code
      AND  value_source_code           = p_source_code
      AND  value_source_code IS NOT NULL))
      AND  exists (SELECT 'x'
                    FROM xla_desc_priorities      xdp
                        ,xla_line_defn_jlt_assgns xld
                        ,xla_aad_line_defn_assgns xal
                        ,xla_prod_acct_headers    xpa
                   WHERE xdp.description_prio_id        = xco.description_prio_id
                     AND xld.application_id             = xdp.application_id
                     AND xld.amb_context_code           = xdp.amb_context_code
                     AND xld.description_type_code      = xdp.description_type_code
                     AND xld.description_code           = xdp.description_code
                     AND xal.application_id             = xld.application_id
                     AND xal.amb_context_code           = xld.amb_context_code
                     AND xal.event_class_code           = xld.event_class_code
                     AND xal.event_type_code            = xld.event_type_code
                     AND xal.line_definition_owner_code = xld.line_definition_owner_code
                     AND xal.line_definition_code       = xld.line_definition_code
                     AND xpa.application_id             = xal.application_id
                     AND xpa.amb_context_code           = xal.amb_context_code
                     AND xpa.event_class_code           = xal.event_class_code
                     AND xpa.event_type_code            = xal.event_type_code
                     AND xpa.product_rule_type_code     = xal.product_rule_type_code
                     AND xpa.product_rule_code          = xal.product_rule_code
                     AND xpa.locking_status_flag        = 'Y');


   CURSOR check_sr_conditions
   IS
   SELECT 'x'
     FROM xla_conditions xco
    WHERE ((source_application_id       = p_application_id
      AND  source_code                 = p_source_code
      AND  source_type_code            = p_source_type_code)
       OR (value_source_application_id = p_application_id
      AND  value_source_type_code      = p_source_type_code
      AND  value_source_code           = p_source_code
      AND  value_source_code IS NOT NULL))
      AND  exists (SELECT 'x'
                    FROM xla_seg_rule_details     xsr
                        ,xla_line_defn_adr_assgns xld
                        ,xla_aad_line_defn_assgns xal
                        ,xla_prod_acct_headers    xpa
                   WHERE xsr.segment_rule_detail_id     = xco.segment_rule_detail_id
                     AND xld.application_id             = xsr.application_id
                     AND xld.amb_context_code           = xsr.amb_context_code
                     AND xld.segment_rule_type_code     = xsr.segment_rule_type_code
                     AND xld.segment_rule_code          = xsr.segment_rule_code
                     AND xal.application_id             = xld.application_id
                     AND xal.amb_context_code           = xld.amb_context_code
                     AND xal.event_class_code           = xld.event_class_code
                     AND xal.event_type_code            = xld.event_type_code
                     AND xal.line_definition_owner_code = xld.line_definition_owner_code
                     AND xal.line_definition_code       = xld.line_definition_code
                     AND xpa.application_id             = xal.application_id
                     AND xpa.amb_context_code           = xal.amb_context_code
                     AND xpa.event_class_code           = xal.event_class_code
                     AND xpa.event_type_code            = xal.event_type_code
                     AND xpa.product_rule_type_code     = xal.product_rule_type_code
                     AND xpa.product_rule_code          = xal.product_rule_code
                     AND xpa.locking_status_flag        = 'Y');


   CURSOR check_lt_conditions
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE ((source_application_id       = p_application_id
      AND  source_code                 = p_source_code
      AND  source_type_code            = p_source_type_code)
       OR (value_source_application_id = p_application_id
      AND  value_source_type_code      = p_source_type_code
      AND  value_source_code           = p_source_code
      AND  value_source_code IS NOT NULL))
      AND  exists (SELECT 'x'
                    FROM xla_line_defn_jlt_assgns pl
                        ,xla_aad_line_defn_assgns p
                        ,xla_prod_acct_headers    xpa
                   WHERE pl.application_id             = c.application_id
                     AND pl.amb_context_code           = c.amb_context_code
                     AND pl.event_class_code           = c.event_class_code
                     AND pl.accounting_line_type_code  = c.accounting_line_type_code
                     AND pl.accounting_line_code       = c.accounting_line_code
                     AND pl.application_id             = p.application_id
                     AND pl.amb_context_code           = p.amb_context_code
                     AND pl.event_class_code           = p.event_class_code
                     AND pl.event_type_code            = p.event_type_code
                     AND pl.line_definition_owner_code = p.line_definition_owner_code
                     AND pl.line_definition_code       = p.line_definition_code
                     AND xpa.application_id            = p.application_id
                     AND xpa.amb_context_code          = p.amb_context_code
                     AND xpa.event_class_code          = p.event_class_code
                     AND xpa.event_type_code           = p.event_type_code
                     AND xpa.product_rule_type_code    = p.product_rule_type_code
                     AND xpa.product_rule_code         = p.product_rule_code
                     AND xpa.locking_status_flag       = 'Y');

   CURSOR check_sr_details
   IS
   SELECT 'x'
     FROM xla_seg_rule_details sd
    WHERE ((value_source_application_id       = p_application_id
      AND  value_source_type_code            = p_source_type_code
      AND  value_source_code                 = p_source_code)
       OR (input_source_application_id       = p_application_id
      AND  input_source_type_code            = p_source_type_code
      AND  input_source_code                 = p_source_code
      AND  input_source_code IS NOT NULL))
      AND  exists (SELECT 'x'
                    FROM xla_line_defn_adr_assgns pl
                        ,xla_aad_line_defn_assgns p
                        ,xla_prod_acct_headers    xpa
                   WHERE pl.application_id             = sd.application_id
                     AND pl.amb_context_code           = sd.amb_context_code
                     AND pl.segment_rule_type_code     = sd.segment_rule_type_code
                     AND pl.segment_rule_code          = sd.segment_rule_code
                     AND pl.application_id             = p.application_id
                     AND pl.amb_context_code           = p.amb_context_code
                     AND pl.event_class_code           = p.event_class_code
                     AND pl.event_type_code            = p.event_type_code
                     AND pl.line_definition_owner_code = p.line_definition_owner_code
                     AND pl.line_definition_code       = p.line_definition_code
                     AND xpa.application_id            = p.application_id
                     AND xpa.amb_context_code          = p.amb_context_code
                     AND xpa.event_class_code          = p.event_class_code
                     AND xpa.event_type_code           = p.event_type_code
                     AND xpa.product_rule_type_code    = p.product_rule_type_code
                     AND xpa.product_rule_code         = p.product_rule_code
                     AND xpa.locking_status_flag       = 'Y');

   CURSOR check_line_types
   IS
   SELECT 'x'
     FROM xla_jlt_acct_attrs r
    WHERE source_application_id   = p_application_id
      AND source_code             = p_source_code
      AND source_type_code        = p_source_type_code
      AND exists (SELECT 'x'
                    FROM xla_line_defn_jlt_assgns pl
                        ,xla_aad_line_defn_assgns p
                        ,xla_prod_acct_headers    xpa
                   WHERE pl.application_id             = r.application_id
                     AND pl.amb_context_code           = r.amb_context_code
                     AND pl.event_class_code           = r.event_class_code
                     AND pl.accounting_line_type_code  = r.accounting_line_type_code
                     AND pl.accounting_line_code       = r.accounting_line_code
                     AND pl.application_id             = p.application_id
                     AND pl.amb_context_code           = p.amb_context_code
                     AND pl.event_class_code           = p.event_class_code
                     AND pl.event_type_code            = p.event_type_code
                     AND pl.line_definition_owner_code = p.line_definition_owner_code
                     AND pl.line_definition_code       = p.line_definition_code
                     AND xpa.application_id            = p.application_id
                     AND xpa.amb_context_code          = p.amb_context_code
                     AND xpa.event_class_code          = p.event_class_code
                     AND xpa.event_type_code           = p.event_type_code
                     AND xpa.product_rule_type_code    = p.product_rule_type_code
                     AND xpa.product_rule_code         = p.product_rule_code
                     AND xpa.locking_status_flag       = 'Y');

   CURSOR check_aad
   IS
   SELECT 'x'
     FROM DUAL
    WHERE EXISTS (SELECT 'x'
                    FROM xla_aad_hdr_acct_attrs r, xla_prod_acct_headers p
                   WHERE r.source_application_id   = p_application_id
                     AND r.source_code             = p_source_code
                     AND r.source_type_code        = p_source_type_code
                     AND r.source_type_code        IS NOT NULL
                     AND p.application_id          = r.application_id
                     AND p.amb_context_code        = r.amb_context_code
                     AND p.product_rule_type_code  = r.product_rule_type_code
                     AND p.product_rule_code       = r.product_rule_code
                     AND p.event_class_code        = r.event_class_code
                     AND p.event_type_code         = r.event_type_code
                     AND p.locking_status_flag     = 'Y');

   CURSOR c_check_derived_sources
   IS
   SELECT application_id, source_type_code, source_code
     FROM xla_sources_b r
    WHERE exists (SELECT 'x'
                    FROM xla_source_params p
                   WHERE p.ref_source_application_id   = p_application_id
                     AND p.ref_source_code             = p_source_code
                     AND p.ref_source_type_code        = p_source_type_code
                     AND p.application_id              = r.application_id
                     AND p.source_type_code            = r.source_type_code
                     AND p.source_code                 = r.source_code);

   l_check_derived_sources    c_check_derived_sources%rowtype;

   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.source_is_locked';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure source_is_locked'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',source_code = '||p_source_code||
                      ',source_type_code = '||p_source_type_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   IF p_source_type_code = 'S' THEN

      OPEN check_analytical;
      FETCH check_analytical
       INTO l_exist;
      IF check_analytical%found THEN
         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE check_analytical;

      IF l_return = FALSE THEN

         OPEN check_descript_details;
         FETCH check_descript_details
          INTO l_exist;
         IF check_descript_details%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_descript_details;
      END IF;

      IF l_return = FALSE THEN

         OPEN check_desc_conditions;
         FETCH check_desc_conditions
          INTO l_exist;
         IF check_desc_conditions%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_desc_conditions;
      END IF;

      IF l_return = FALSE THEN

         OPEN check_sr_conditions;
         FETCH check_sr_conditions
          INTO l_exist;
         IF check_sr_conditions%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_sr_conditions;
      END IF;

      IF l_return = FALSE THEN

         OPEN check_lt_conditions;
         FETCH check_lt_conditions
          INTO l_exist;
         IF check_lt_conditions%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_lt_conditions;
      END IF;

      IF l_return = FALSE THEN

         OPEN check_sr_details;
         FETCH check_sr_details
          INTO l_exist;
         IF check_sr_details%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_sr_details;
      END IF;

      IF l_return = FALSE THEN

         OPEN check_line_types;
         FETCH check_line_types
          INTO l_exist;
         IF check_line_types%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_line_types;
      END IF;

      IF l_return = FALSE THEN

         OPEN check_aad;
         FETCH check_aad
          INTO l_exist;
         IF check_aad%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_aad;
      END IF;

      IF l_return = FALSE THEN

         OPEN c_check_derived_sources;
         LOOP
         FETCH c_check_derived_sources
          INTO l_check_derived_sources;
         EXIT WHEN c_check_derived_sources%notfound or l_return = TRUE;

         IF derived_source_is_locked
              (p_der_application_id      => l_check_derived_sources.application_id
              ,p_der_source_type_code    => l_check_derived_sources.source_type_code
              ,p_der_source_code         => l_check_derived_sources.source_code) THEN

            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         END LOOP;
         CLOSE c_check_derived_sources;
      END IF;

   ELSIF p_source_type_code = 'D' THEN

      IF derived_source_is_locked
           (p_der_application_id      => p_application_id
           ,p_der_source_type_code    => p_source_type_code
           ,p_der_source_code         => p_source_code) THEN

         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure source_is_locked'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN

      IF check_analytical%ISOPEN THEN
         CLOSE check_analytical;
      END IF;
      IF check_descript_details%ISOPEN THEN
         CLOSE check_descript_details;
      END IF;
      IF check_sr_details%ISOPEN THEN
         CLOSE check_sr_details;
      END IF;
      IF check_lt_conditions%ISOPEN THEN
         CLOSE check_lt_conditions;
      END IF;
      IF check_sr_conditions%ISOPEN THEN
         CLOSE check_sr_conditions;
      END IF;
      IF check_desc_conditions%ISOPEN THEN
         CLOSE check_desc_conditions;
      END IF;
      IF check_line_types%ISOPEN THEN
         CLOSE check_line_types;
      END IF;

      RAISE;

WHEN OTHERS                                   THEN

      IF check_analytical%ISOPEN THEN
         CLOSE check_analytical;
      END IF;
      IF check_sr_details%ISOPEN THEN
         CLOSE check_sr_details;
      END IF;
      IF check_lt_conditions%ISOPEN THEN
         CLOSE check_lt_conditions;
      END IF;
      IF check_sr_conditions%ISOPEN THEN
         CLOSE check_sr_conditions;
      END IF;
      IF check_desc_conditions%ISOPEN THEN
         CLOSE check_desc_conditions;
      END IF;
      IF check_descript_details%ISOPEN THEN
         CLOSE check_descript_details;
      END IF;
      IF check_line_types%ISOPEN THEN
         CLOSE check_line_types;
      END IF;

   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.source_is_locked');

END source_is_locked;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| uncompile_prod_rule                                                   |
|                                                                       |
| Wrapper for uncompile_definitions                                     |
| Provided for backward-compatibility, to be obsoleted                  |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_prod_rule
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS
   l_event_class_name       varchar2(80)  := NULL;
   l_event_type_name        varchar2(80)  := NULL;
   l_locking_status_flag    varchar2(1)   := NULL;
   l_return                 BOOLEAN := TRUE;

   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.uncompile_prod_rule';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure uncompile_prod_rule'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',source_code = '||p_source_code||
                      ',source_type_code = '||p_source_type_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := uncompile_definitions
                         (p_application_id        => p_application_id
                         ,p_source_code           => p_source_code
                         ,p_source_type_code      => p_source_type_code
                         ,x_product_rule_name     => p_product_rule_name
                         ,x_product_rule_type     => p_product_rule_type
                         ,x_event_class_name      => l_event_class_name
                         ,x_event_type_name       => l_event_type_name
                         ,x_locking_status_flag   => l_locking_status_flag);


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure uncompile_prod_rule'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.uncompile_prod_rule');

END uncompile_prod_rule;



/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Sets status of assigned application accounting definitions and journ  |
| lines definitions to uncompiled                                       |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                  IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag              IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS

   --
   -- Private variables
   --
   l_exist   VARCHAR2(1) ;
   l_return  BOOLEAN := TRUE;

   l_application_name       varchar2(240) := null;
   l_line_definition_name   varchar2(80)  := null;
   l_line_definition_owner  varchar2(80)  := NULL;
   l_product_rule_name      varchar2(80)  := null;
   l_product_rule_type      varchar2(80)  := NULL;
   l_event_class_name       varchar2(80)  := NULL;
   l_event_type_name        varchar2(80)  := NULL;
   l_locking_status_flag    varchar2(1)   := NULL;
   --
   -- Cursor declarations
   --

   CURSOR c_analytical
   IS
   SELECT amb_context_code, analytical_criterion_code, analytical_criterion_type_code
     FROM xla_analytical_hdrs_b a
    WHERE exists (SELECT 'x'
                    FROM xla_analytical_sources r
                   WHERE source_application_id            = p_application_id
                     AND source_code                      = p_source_code
                     AND source_type_code                 = p_source_type_code
                     AND r.amb_context_code               = a.amb_context_code
                     AND r.analytical_criterion_code      = a.analytical_criterion_code
                     AND r.analytical_criterion_type_code = a.analytical_criterion_type_code);

   l_analytical   c_analytical%rowtype;

   CURSOR c_descriptions
   IS
   SELECT x.application_id, x.amb_context_code,
          x.description_type_code, x.description_code
     FROM xla_descriptions_b x
    WHERE exists (SELECT 'x'
                    FROM xla_descript_details_b d, xla_desc_priorities dp
                   WHERE d.source_application_id   = p_application_id
                     AND d.source_code             = p_source_code
                     AND d.source_type_code        = p_source_type_code
                     AND d.source_code is not null
                     AND dp.description_prio_id    = d.description_prio_id
                     AND dp.application_id         = x.application_id
                     AND dp.amb_context_code       = x.amb_context_code
                     AND dp.description_type_code  = x.description_type_code
                     AND dp.description_code       = x.description_code
                  UNION
                  SELECT 'x'
                    FROM xla_conditions c, xla_desc_priorities dp
                   WHERE ((c.source_application_id      = p_application_id
                     AND  c.source_code                 = p_source_code
                     AND  c.source_type_code            = p_source_type_code)
                      OR (c.value_source_application_id = p_application_id
                     AND  c.value_source_type_code      = p_source_type_code
                     AND  c.value_source_code           = p_source_code
                     AND  c.value_source_code IS NOT NULL))
                     AND dp.description_prio_id         = c.description_prio_id
                     AND dp.application_id         = x.application_id
                     AND dp.amb_context_code       = x.amb_context_code
                     AND dp.description_type_code  = x.description_type_code
                     AND dp.description_code       = x.description_code);

   l_description   c_descriptions%rowtype;

   CURSOR c_seg_rules
   IS
   SELECT a.application_id, a.amb_context_code, a.segment_rule_type_code, a.segment_rule_code
     FROM xla_seg_rules_b a
    WHERE exists (SELECT 'x'
                    FROM xla_seg_rule_details sd
                   WHERE ((value_source_application_id      = p_application_id
                     AND  value_source_type_code            = p_source_type_code
                     AND  value_source_code                 = p_source_code)
                      OR (input_source_application_id       = p_application_id
                     AND  input_source_type_code            = p_source_type_code
                     AND  input_source_code                 = p_source_code
                     AND  input_source_code IS NOT NULL))
                     AND sd.application_id                  = a.application_id
                     AND sd.amb_context_code                = a.amb_context_code
                     AND sd.segment_rule_type_code          = a.segment_rule_type_code
                     AND sd.segment_rule_code               = a.segment_rule_code
                  UNION
                  SELECT 'x'
                    FROM xla_conditions c, xla_seg_rule_details sd
                   WHERE ((c.source_application_id      = p_application_id
                     AND  c.source_code                 = p_source_code
                     AND  c.source_type_code            = p_source_type_code)
                      OR (c.value_source_application_id = p_application_id
                     AND  c.value_source_type_code      = p_source_type_code
                     AND  c.value_source_code           = p_source_code
                     AND  c.value_source_code IS NOT NULL))
                     AND c.segment_rule_detail_id       = sd.segment_rule_detail_id
                     AND sd.application_id              = a.application_id
                     AND sd.amb_context_code            = a.amb_context_code
                     AND sd.segment_rule_type_code      = a.segment_rule_type_code
                     AND sd.segment_rule_code           = a.segment_rule_code);

   l_seg_rule   c_seg_rules%rowtype;

   CURSOR c_line_types
   IS
   SELECT application_id, a.amb_context_code, entity_code, event_class_code,
          accounting_line_type_code, accounting_line_code
     FROM xla_acct_line_types_b a
    WHERE exists (SELECT 'x'
                    FROM xla_conditions c
                   WHERE ((source_application_id      = p_application_id
                     AND  source_code                 = p_source_code
                     AND  source_type_code            = p_source_type_code)
                      OR (value_source_application_id = p_application_id
                     AND  value_source_type_code      = p_source_type_code
                     AND  value_source_code           = p_source_code
                     AND  value_source_code IS NOT NULL))
                     AND c.application_id             = a.application_id
                     AND c.amb_context_code           = a.amb_context_code
                     AND c.entity_code                = a.entity_code
                     AND c.event_class_code           = a.event_class_code
                     AND c.accounting_line_type_code  = a.accounting_line_type_code
                     AND c.accounting_line_code       = a.accounting_line_code
                  UNION
                  SELECT 'x'
                    FROM xla_jlt_acct_attrs r
                   WHERE source_application_id        = p_application_id
                     AND source_code                  = p_source_code
                     AND source_type_code             = p_source_type_code
                     AND r.application_id             = a.application_id
                     AND r.amb_context_code           = a.amb_context_code
                     AND r.event_class_code           = a.event_class_code
                     AND r.accounting_line_type_code  = a.accounting_line_type_code
                     AND r.accounting_line_code       = a.accounting_line_code);

   l_line_type   c_line_types%rowtype;

   CURSOR c_aad
   IS
   SELECT application_id, amb_context_code,
          product_rule_type_code, product_rule_code
     FROM xla_product_rules_b a
    WHERE exists (SELECT 'x'
                    FROM xla_aad_hdr_acct_attrs r
                   WHERE source_application_id        = p_application_id
                     AND source_code                  = p_source_code
                     AND source_type_code             = p_source_type_code
                     AND source_code is not null
                     AND r.application_id             = a.application_id
                     AND r.amb_context_code           = a.amb_context_code
                     AND r.product_rule_type_code     = a.product_rule_type_code
                     AND r.product_rule_code          = a.product_rule_code);

   l_aad   c_aad%rowtype;

   CURSOR c_check_derived_sources
   IS
   SELECT application_id, source_type_code, source_code
     FROM xla_sources_b r
    WHERE exists (SELECT 'x'
                    FROM xla_source_params p
                   WHERE p.ref_source_application_id   = p_application_id
                     AND p.ref_source_code             = p_source_code
                     AND p.ref_source_type_code        = p_source_type_code
                     AND p.application_id              = r.application_id
                     AND p.source_type_code            = r.source_type_code
                     AND p.source_code                 = r.source_code);

   l_check_derived_sources    c_check_derived_sources%rowtype;

   l_log_module VARCHAR2(240);
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
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',source_code = '||p_source_code||
                      ',source_type_code = '||p_source_type_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   IF p_source_type_code = 'S' THEN

      OPEN c_analytical;
      LOOP
      FETCH c_analytical
       INTO l_analytical;
      EXIT WHEN c_analytical%NOTFOUND or l_return=FALSE;

         IF xla_analytical_hdrs_pkg.uncompile_definitions
              (p_amb_context_code           => l_analytical.amb_context_code
              ,p_analytical_criterion_code  => l_analytical.analytical_criterion_code
              ,p_anal_criterion_type_code   => l_analytical.analytical_criterion_type_code
              ,x_product_rule_name          => l_product_rule_name
              ,x_product_rule_type          => l_product_rule_type
              ,x_event_class_name           => l_event_class_name
              ,x_event_type_name            => l_event_type_name
              ,x_locking_status_flag        => l_locking_status_flag) THEN

            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
      END LOOP;
      CLOSE c_analytical;

      IF l_return = TRUE THEN
         OPEN c_descriptions;
         LOOP
         FETCH c_descriptions
          INTO l_description;
         EXIT WHEN c_descriptions%NOTFOUND or l_return=FALSE;

            IF xla_descriptions_pkg.uncompile_definitions
                 (p_application_id        => l_description.application_id
                 ,p_amb_context_code      => l_description.amb_context_code
                 ,p_description_type_code => l_description.description_type_code
                 ,p_description_code      => l_description.description_code
                 ,x_product_rule_name     => l_product_rule_name
                 ,x_product_rule_type     => l_product_rule_type
                 ,x_event_class_name      => l_event_class_name
                 ,x_event_type_name       => l_event_type_name
                 ,x_locking_status_flag   => l_locking_status_flag) THEN

               l_return := TRUE;
            ELSE
            l_return := FALSE;
            END IF;
         END LOOP;
         CLOSE c_descriptions;
      END IF;


      IF l_return = TRUE THEN
         OPEN c_seg_rules;
         LOOP
         FETCH c_seg_rules
          INTO l_seg_rule;
         EXIT WHEN c_seg_rules%NOTFOUND or l_return=FALSE;

            IF xla_seg_rules_pkg.uncompile_definitions
                 (p_application_id         => l_seg_rule.application_id
                 ,p_amb_context_code       => l_seg_rule.amb_context_code
                 ,p_segment_rule_type_code => l_seg_rule.segment_rule_type_code
                 ,p_segment_rule_code      => l_seg_rule.segment_rule_code
                 ,x_product_rule_name      => l_product_rule_name
                 ,x_product_rule_type      => l_product_rule_type
                 ,x_event_class_name       => l_event_class_name
                 ,x_event_type_name        => l_event_type_name
                 ,x_locking_status_flag    => l_locking_status_flag) THEN

               l_return := TRUE;
            ELSE
               l_return := FALSE;
            END IF;
         END LOOP;
         CLOSE c_seg_rules;
      END IF;


      IF l_return = TRUE THEN
         OPEN c_line_types;
         LOOP
         FETCH c_line_types
          INTO l_line_type;
         EXIT WHEN c_line_types%NOTFOUND or l_return=FALSE;

            IF xla_line_types_pkg.uncompile_definitions
                 (p_application_id            => l_line_type.application_id
                 ,p_amb_context_code          => l_line_type.amb_context_code
                 ,p_event_class_code          => l_line_type.event_class_code
                 ,p_accounting_line_type_code => l_line_type.accounting_line_type_code
                 ,p_accounting_line_code      => l_line_type.accounting_line_code
                 ,x_product_rule_name         => l_product_rule_name
                 ,x_product_rule_type         => l_product_rule_type
                 ,x_event_class_name          => l_event_class_name
                 ,x_event_type_name           => l_event_type_name
                 ,x_locking_status_flag       => l_locking_status_flag) THEN

               l_return := TRUE;
            ELSE
               l_return := FALSE;
            END IF;
         END LOOP;
         CLOSE c_line_types;
      END IF;

   IF l_return = TRUE THEN
      OPEN c_aad;
      LOOP
      FETCH c_aad
       INTO l_aad;
      EXIT WHEN c_aad%NOTFOUND or l_return=FALSE;

         IF xla_product_rules_pkg.uncompile_product_rule
              (p_application_id            => l_aad.application_id
              ,p_amb_context_code          => l_aad.amb_context_code
              ,p_product_rule_type_code    => l_aad.product_rule_type_code
              ,p_product_rule_code         => l_aad.product_rule_code) THEN

            l_return := TRUE;
         ELSE
            xla_validations_pkg.get_product_rule_info
              (p_application_id          => l_aad.application_id
              ,p_amb_context_code        => l_aad.amb_context_code
              ,p_product_rule_type_code  => l_aad.product_rule_type_code
              ,p_product_rule_code       => l_aad.product_rule_code
              ,p_application_name        => l_application_name
              ,p_product_rule_name       => l_product_rule_name
              ,p_product_rule_type       => l_product_rule_type);

            l_return := FALSE;
         END IF;
      END LOOP;
      CLOSE c_aad;
   END IF;

      IF l_return = TRUE THEN

         OPEN c_check_derived_sources;
         LOOP
         FETCH c_check_derived_sources
          INTO l_check_derived_sources;
         EXIT WHEN c_check_derived_sources%notfound or l_return = FALSE;

           IF uncompile_pad_for_der_source
                (p_der_application_id    => l_check_derived_sources.application_id
                ,p_der_source_type_code  => l_check_derived_sources.source_type_code
                ,p_der_source_code       => l_check_derived_sources.source_code
                ,x_product_rule_name     => l_product_rule_name
                ,x_product_rule_type     => l_product_rule_type
                ,x_event_class_name      => l_event_class_name
                ,x_event_type_name       => l_event_type_name
                ,x_locking_status_flag   => l_locking_status_flag) THEN

               l_return := TRUE;
            ELSE
               l_return := FALSE;
            END IF;
         END LOOP;
         CLOSE c_check_derived_sources;
     END IF;

   ELSIF p_source_type_code = 'D' THEN

      IF uncompile_pad_for_der_source
           (p_der_application_id    => p_application_id
           ,p_der_source_type_code  => p_source_type_code
           ,p_der_source_code       => p_source_code
           ,x_product_rule_name     => l_product_rule_name
           ,x_product_rule_type     => l_product_rule_type
           ,x_event_class_name      => l_event_class_name
           ,x_event_type_name       => l_event_type_name
           ,x_locking_status_flag   => l_locking_status_flag) THEN

         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;

   END IF;

   x_product_rule_name     := l_product_rule_name;
   x_product_rule_type     := l_product_rule_type;
   x_event_class_name      := l_event_class_name;
   x_event_type_name       := l_event_type_name;
   x_locking_status_flag   := l_locking_status_flag;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure uncompile_definitions'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.uncompile_definitions');

END uncompile_definitions;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_derived_source_details                                         |
|                                                                       |
| Deletes details of the derived source when the source is deleted      |
|                                                                       |
+======================================================================*/
PROCEDURE delete_derived_source_details
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2)

IS

   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_derived_source_details';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure delete_derived_source_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',source_code = '||p_source_code||
                      ',source_type_code = '||p_source_type_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   DELETE
     FROM xla_source_params
    WHERE application_id      = p_application_id
      AND source_type_code    = p_source_type_code
      AND source_code         = p_source_code;

   DELETE
     FROM xla_event_sources
    WHERE source_application_id = p_application_id
      AND source_type_code      = p_source_type_code
      AND source_code           = p_source_code;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure delete_derived_source_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;


EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.delete_derived_source_details');

END delete_derived_source_details;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| derived_source_is_invalid                                             |
|                                                                       |
| Returns true if the derived source has seeded sources that do not     |
| belong to the entity or event class                                   |
|                                                                       |
+======================================================================*/
FUNCTION derived_source_is_invalid
  (p_application_id                   IN NUMBER
  ,p_derived_source_code              IN VARCHAR2
  ,p_derived_source_type_code         IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_level                            IN VARCHAR2)
RETURN VARCHAR2

IS

   --
   -- Private variables
   --
   l_exist   VARCHAR2(1) ;
   l_return  VARCHAR2(30);

   --
   -- Cursor declarations
   --

   CURSOR check_header_source
   IS
   SELECT 'x'
     FROM xla_source_params r
    WHERE application_id       = p_application_id
      AND source_code          = p_derived_source_code
      AND source_type_code     = p_derived_source_type_code
      AND ref_source_code is not null
      AND ref_source_type_code = 'S'
      AND not exists (SELECT 'x'
                        FROM xla_event_sources s
                       WHERE s.source_application_id   = r.ref_source_application_id
                         AND s.source_type_code        = r.ref_source_type_code
                         AND s.source_code             = r.ref_source_code
                         AND s.application_id          = p_application_id
                         AND s.event_class_code        = p_event_class_code
                         AND s.active_flag            = 'Y'
                         AND s.level_code              = 'H');

   CURSOR check_line_source
   IS
   SELECT 'x'
     FROM xla_source_params r
    WHERE application_id       = p_application_id
      AND source_code          = p_derived_source_code
      AND source_type_code     = p_derived_source_type_code
      AND ref_source_code is not null
      AND ref_source_type_code = 'S'
      AND not exists (SELECT 'x'
                        FROM xla_event_sources s
                       WHERE s.source_application_id   = r.ref_source_application_id
                         AND s.source_type_code        = r.ref_source_type_code
                         AND s.source_code             = r.ref_source_code
                         AND s.application_id          = p_application_id
                         AND s.event_class_code        = p_event_class_code
                         AND s.active_flag            = 'Y');

   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.derived_source_is_invalid';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure derived_source_is_invalid'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',source_code = '||p_derived_source_code||
                      ',source_type_code = '||p_derived_source_type_code||
                      ',event_class_code = '||p_event_class_code||
                      ',level = '||p_event_class_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   IF p_level = 'H' THEN

      OPEN check_header_source;
      FETCH check_header_source
       INTO l_exist;
      IF check_header_source%found THEN
         l_return := 'TRUE';
      ELSE
         l_return := 'FALSE';
      END IF;
      CLOSE check_header_source;

   ELSE

      OPEN check_line_source;
      FETCH check_line_source
       INTO l_exist;
      IF check_line_source%found THEN
         l_return := 'TRUE';
      ELSE
         l_return := 'FALSE';
      END IF;
      CLOSE check_line_source;

   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure derived_source_is_invalid'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;


   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN

      IF check_header_source%ISOPEN THEN
         CLOSE check_header_source;
      END IF;
      IF check_line_source%ISOPEN THEN
         CLOSE check_line_source;
      END IF;

      RAISE;

WHEN OTHERS                                   THEN

      IF check_header_source%ISOPEN THEN
         CLOSE check_header_source;
      END IF;
      IF check_line_source%ISOPEN THEN
         CLOSE check_line_source;
      END IF;

   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.derived_source_is_invalid');

END derived_source_is_invalid;


FUNCTION derived_source_is_invalid
  (p_application_id                   IN NUMBER
  ,p_derived_source_code              IN VARCHAR2
  ,p_derived_source_type_code         IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_level                            IN VARCHAR2)
RETURN VARCHAR2
IS
   l_return  VARCHAR2(30);

   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.derived_source_is_invalid';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure derived_source_is_invalid'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',source_code = '||p_derived_source_code||
                      ',source_type_code = '||p_derived_source_type_code||
                      ',event_class_code = '||p_event_class_code||
                      ',entity_code = '||p_entity_code||
                      ',level = '||p_event_class_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   l_return := derived_source_is_invalid
                (p_application_id             => p_application_id
                ,p_derived_source_code        => p_derived_source_code
                ,p_derived_source_type_code   => p_derived_source_type_code
                ,p_event_class_code           => p_event_class_code
                ,p_level                      => p_level);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure derived_source_is_invalid'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN

      RAISE;

WHEN OTHERS                                   THEN

   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.derived_source_is_invalid');

END derived_source_is_invalid;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| source_in_use_by_tab                                                  |
|                                                                       |
| Returns true if the source is being used                              |
|                                                                       |
+======================================================================*/
FUNCTION source_in_use_by_tab
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2)
RETURN BOOLEAN
IS

   --
   -- Private variables
   --
   l_exist   VARCHAR2(1) ;
   l_return  BOOLEAN := FALSE;

   --
   -- Cursor declarations
   --
   CURSOR check_trx_acct_type
   IS
   SELECT 'x'
     FROM xla_tab_acct_type_srcs
    WHERE source_application_id   = p_application_id
      AND source_code             = p_source_code
      AND source_type_code        = p_source_type_code;

   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.source_in_use_by_tab';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure source_in_use_by_tab'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',source_code = '||p_source_code||
                      ',source_type_code = '||p_source_type_code||
                      ',event = '||p_event
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   IF p_source_type_code = 'S' THEN

      IF p_event in ('DELETE', 'DISABLE') THEN

         OPEN check_trx_acct_type;
         FETCH check_trx_acct_type
          INTO l_exist;
         IF check_trx_acct_type%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_trx_acct_type;
      END IF;
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure source_in_use_by_tab'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF check_trx_acct_type%ISOPEN THEN
         CLOSE check_trx_acct_type;
      END IF;
      RAISE;

WHEN OTHERS                                   THEN
      IF check_trx_acct_type%ISOPEN THEN
         CLOSE check_trx_acct_type;
      END IF;

   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.source_in_use_by_tab');

END source_in_use_by_tab;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| source_is_locked_by_tab                                               |
|                                                                       |
| Returns true if the source is being used by a locked TAD              |
|                                                                       |
+======================================================================*/
FUNCTION source_is_locked_by_tab
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2)
RETURN BOOLEAN

IS

   --
   -- Private variables
   --
   l_exist   VARCHAR2(1) ;
   l_return  BOOLEAN;

   --
   -- Cursor declarations
   --

   CURSOR check_sr_conditions
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE ((source_application_id       = p_application_id
      AND  source_code                 = p_source_code
      AND  source_type_code            = p_source_type_code)
       OR (value_source_application_id = p_application_id
      AND  value_source_type_code      = p_source_type_code
      AND  value_source_code           = p_source_code
      AND  value_source_code IS NOT NULL))
      AND  exists (SELECT 'x'
                    FROM xla_seg_rule_details sd,
                         xla_tab_acct_def_details pl, xla_tab_acct_defs_b p
                   WHERE sd.segment_rule_detail_id  = c.segment_rule_detail_id
                     AND pl.application_id          = sd.application_id
                     AND pl.amb_context_code        = sd.amb_context_code
                     AND pl.segment_rule_type_code  = sd.segment_rule_type_code
                     AND pl.segment_rule_code       = sd.segment_rule_code
                     AND pl.application_id          = p.application_id
                     AND pl.amb_context_code        = p.amb_context_code
                     AND pl.account_definition_type_code  = p.account_definition_type_code
                     AND pl.account_definition_code  = p.account_definition_code
                     AND p.locking_status_flag       = 'Y');

   CURSOR check_sr_details
   IS
   SELECT 'x'
     FROM xla_seg_rule_details sd
    WHERE ((value_source_application_id       = p_application_id
      AND  value_source_type_code            = p_source_type_code
      AND  value_source_code                 = p_source_code)
       OR (input_source_application_id       = p_application_id
      AND  input_source_type_code            = p_source_type_code
      AND  input_source_code                 = p_source_code
      AND  input_source_code IS NOT NULL))
      AND  exists (SELECT 'x'
                    FROM xla_tab_acct_def_details pl, xla_tab_acct_defs_b p
                   WHERE pl.application_id          = sd.application_id
                     AND pl.amb_context_code        = sd.amb_context_code
                     AND pl.segment_rule_type_code  = sd.segment_rule_type_code
                     AND pl.segment_rule_code       = sd.segment_rule_code
                     AND pl.application_id          = p.application_id
                     AND pl.amb_context_code        = p.amb_context_code
                     AND pl.account_definition_type_code  = p.account_definition_type_code
                     AND pl.account_definition_code  = p.account_definition_code
                     AND p.locking_status_flag       = 'Y');

   CURSOR c_check_derived_sources
   IS
   SELECT application_id, source_type_code, source_code
     FROM xla_sources_b r
    WHERE exists (SELECT 'x'
                    FROM xla_source_params p
                   WHERE p.ref_source_application_id   = p_application_id
                     AND p.ref_source_code             = p_source_code
                     AND p.ref_source_type_code        = p_source_type_code
                     AND p.application_id              = r.application_id
                     AND p.source_type_code            = r.source_type_code
                     AND p.source_code                 = r.source_code);

   l_check_derived_sources    c_check_derived_sources%rowtype;

   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.source_is_locked_by_tab';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure source_is_locked_by_tab'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',source_code = '||p_source_code||
                      ',source_type_code = '||p_source_type_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   IF p_source_type_code = 'S' THEN

         OPEN check_sr_conditions;
         FETCH check_sr_conditions
          INTO l_exist;
         IF check_sr_conditions%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_sr_conditions;

      IF l_return = FALSE THEN

         OPEN check_sr_details;
         FETCH check_sr_details
          INTO l_exist;
         IF check_sr_details%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_sr_details;
      END IF;

      IF l_return = FALSE THEN

         OPEN c_check_derived_sources;
         LOOP
         FETCH c_check_derived_sources
          INTO l_check_derived_sources;
         EXIT WHEN c_check_derived_sources%notfound or l_return = TRUE;

         IF derived_source_locked_by_tab
              (p_der_application_id      => l_check_derived_sources.application_id
              ,p_der_source_type_code    => l_check_derived_sources.source_type_code
              ,p_der_source_code         => l_check_derived_sources.source_code)
 THEN

            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         END LOOP;
         CLOSE c_check_derived_sources;
      END IF;

   ELSIF p_source_type_code = 'D' THEN

      IF derived_source_locked_by_tab
           (p_der_application_id      => p_application_id
           ,p_der_source_type_code    => p_source_type_code
           ,p_der_source_code         => p_source_code) THEN

         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure source_is_locked_by_tab'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN

      IF check_sr_conditions%ISOPEN THEN
         CLOSE check_sr_conditions;
      END IF;
      IF check_sr_details%ISOPEN THEN
         CLOSE check_sr_details;
      END IF;
      IF c_check_derived_sources%ISOPEN THEN
         CLOSE c_check_derived_sources;
      END IF;

      RAISE;

   WHEN OTHERS                                   THEN
      IF check_sr_conditions%ISOPEN THEN
         CLOSE check_sr_conditions;
      END IF;
      IF check_sr_details%ISOPEN THEN
         CLOSE check_sr_details;
      END IF;
      IF c_check_derived_sources%ISOPEN THEN
         CLOSE c_check_derived_sources;
      END IF;

   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.source_is_locked_by_tab');

END source_is_locked_by_tab;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_tran_acct_def                                               |
|                                                                       |
| Sets status of the assigned transaction account definition            |
| to uncompiled                                                         |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_tran_acct_def
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_trx_acct_def                     IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def_type                IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS

   --
   -- Private variables
   --
   l_exist   VARCHAR2(1) ;
   l_return  BOOLEAN := TRUE;

   l_application_name   varchar2(240) := null;
   l_trx_acct_def  varchar2(80)  := null;
   l_trx_acct_def_type  varchar2(80)  := NULL;
   --
   -- Cursor declarations
   --
   CURSOR c_seg_rules
   IS
   SELECT a.application_id, a.amb_context_code, a.segment_rule_type_code, a.segment_rule_code
     FROM xla_seg_rules_b a
    WHERE exists (SELECT 'x'
                    FROM xla_seg_rule_details sd
                   WHERE ((value_source_application_id      = p_application_id
                     AND  value_source_type_code            = p_source_type_code
                     AND  value_source_code                 = p_source_code)
                      OR (input_source_application_id       = p_application_id
                     AND  input_source_type_code            = p_source_type_code
                     AND  input_source_code                 = p_source_code
                     AND  input_source_code IS NOT NULL))
                     AND sd.application_id                  = a.application_id
                     AND sd.amb_context_code                = a.amb_context_code
                     AND sd.segment_rule_type_code          = a.segment_rule_type_code
                     AND sd.segment_rule_code               = a.segment_rule_code
                  UNION
                  SELECT 'x'
                    FROM xla_conditions c, xla_seg_rule_details sd
                   WHERE ((c.source_application_id      = p_application_id
                     AND  c.source_code                 = p_source_code
                     AND  c.source_type_code            = p_source_type_code)
                      OR (c.value_source_application_id = p_application_id
                     AND  c.value_source_type_code      = p_source_type_code
                     AND  c.value_source_code           = p_source_code
                     AND  c.value_source_code IS NOT NULL))
                     AND c.segment_rule_detail_id       = sd.segment_rule_detail_id
                     AND sd.application_id              = a.application_id
                     AND sd.amb_context_code            = a.amb_context_code
                     AND sd.segment_rule_type_code      = a.segment_rule_type_code
                     AND sd.segment_rule_code           = a.segment_rule_code);

   l_seg_rule   c_seg_rules%rowtype;

   CURSOR c_check_derived_sources
   IS
   SELECT application_id, source_type_code, source_code
     FROM xla_sources_b r
    WHERE exists (SELECT 'x'
                    FROM xla_source_params p
                   WHERE p.ref_source_application_id   = p_application_id
                     AND p.ref_source_code             = p_source_code
                     AND p.ref_source_type_code        = p_source_type_code
                     AND p.application_id              = r.application_id
                     AND p.source_type_code            = r.source_type_code
                     AND p.source_code                 = r.source_code);

   l_check_derived_sources    c_check_derived_sources%rowtype;


   l_log_module VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.uncompile_tran_acct_def';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure uncompile_tran_acct_def'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',source_code = '||p_source_code||
                      ',source_type_code = '||p_source_type_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   IF p_source_type_code = 'S' THEN

         OPEN c_seg_rules;
         LOOP
         FETCH c_seg_rules
          INTO l_seg_rule;
         EXIT WHEN c_seg_rules%NOTFOUND or l_return=FALSE;

            IF xla_seg_rules_pkg.uncompile_tran_acct_def
                 (p_application_id         => l_seg_rule.application_id
                 ,p_amb_context_code       => l_seg_rule.amb_context_code
                 ,p_segment_rule_type_code => l_seg_rule.segment_rule_type_code
                 ,p_segment_rule_code      => l_seg_rule.segment_rule_code
                 ,p_application_name       => l_application_name
                 ,p_trx_acct_def           => l_trx_acct_def
                 ,p_trx_acct_def_type      => l_trx_acct_def_type) THEN

               l_return := TRUE;
            ELSE
               l_return := FALSE;
            END IF;
         END LOOP;
         CLOSE c_seg_rules;

      IF l_return = TRUE THEN

         OPEN c_check_derived_sources;
         LOOP
         FETCH c_check_derived_sources
          INTO l_check_derived_sources;
         EXIT WHEN c_check_derived_sources%notfound or l_return = FALSE;

           IF uncompile_tad_for_der_source
                (p_der_application_id    => l_check_derived_sources.application_id
                ,p_der_source_type_code  => l_check_derived_sources.source_type_code
                ,p_der_source_code       => l_check_derived_sources.source_code
                ,p_trx_acct_def           => l_trx_acct_def
                ,p_trx_acct_def_type      => l_trx_acct_def_type) THEN

               l_return := TRUE;
            ELSE
               l_return := FALSE;
            END IF;
         END LOOP;

         CLOSE c_check_derived_sources;
     END IF;

   ELSIF p_source_type_code = 'D' THEN

      IF uncompile_tad_for_der_source
           (p_der_application_id    => p_application_id
           ,p_der_source_type_code  => p_source_type_code
           ,p_der_source_code       => p_source_code
           ,p_trx_acct_def           => l_trx_acct_def
           ,p_trx_acct_def_type      => l_trx_acct_def_type) THEN

         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;

   END IF;

   p_trx_acct_def := l_trx_acct_def;
   p_trx_acct_def_type := l_trx_acct_def_type;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure uncompile_tran_acct_def'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.uncompile_tran_acct_def');

END uncompile_tran_acct_def;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| source_in_use_by_tad                                                  |
|                                                                       |
| Returns true if the source is being used by a transaction account     |
| definition                                                            |
|                                                                       |
+======================================================================*/
FUNCTION source_in_use_by_tad
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_account_type_code                IN VARCHAR2)
RETURN VARCHAR2

IS

   CURSOR check_det_value_source
   IS
   SELECT 'x'
     FROM xla_seg_rule_details s
    WHERE s.value_source_application_id = p_application_id
      AND s.value_source_code           = p_source_code
      AND s.value_source_type_code      = p_source_type_code
      AND s.value_source_code is not null
      AND exists (SELECT 'x'
                    FROM xla_tab_acct_def_details d
                   WHERE s.application_id              = d.application_id
                     AND d.account_type_code           = p_account_type_code
                     AND s.amb_context_code            = d.amb_context_code
                     AND s.segment_rule_code           = d.segment_rule_code
                     AND s.segment_rule_type_code      = d.segment_rule_type_code);

   CURSOR check_det_input_source
   IS
   SELECT 'x'
     FROM xla_seg_rule_details s
    WHERE s.input_source_application_id = p_application_id
      AND s.input_source_code           = p_source_code
      AND s.input_source_type_code      = p_source_type_code
      AND s.input_source_code is not null
      AND exists (SELECT 'x'
                    FROM xla_tab_acct_def_details d
                   WHERE s.application_id              = d.application_id
                     AND d.account_type_code           = p_account_type_code
                     AND s.amb_context_code            = d.amb_context_code
                     AND s.segment_rule_code           = d.segment_rule_code
                     AND s.segment_rule_type_code      = d.segment_rule_type_code);



   CURSOR check_con_source
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.source_application_id = p_application_id
      AND c.source_code           = p_source_code
      AND c.source_type_code      = p_source_type_code
      AND exists (SELECT 'x'
                    FROM xla_tab_acct_def_details d, xla_seg_rule_details s
                   WHERE s.application_id              = d.application_id
                     AND d.account_type_code           = p_account_type_code
                     AND s.amb_context_code            = d.amb_context_code
                     AND s.segment_rule_code           = d.segment_rule_code
                     AND s.segment_rule_type_code      = d.segment_rule_type_code
                     AND s.segment_rule_detail_id = c.segment_rule_detail_id);

   CURSOR check_con_value_source
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE value_source_application_id = p_application_id
      AND value_source_code           = p_source_code
      AND value_source_type_code      = p_source_type_code
      AND value_source_code is not null
      AND exists (SELECT 'x'
                    FROM xla_tab_acct_def_details d, xla_seg_rule_details s
                   WHERE s.application_id              = d.application_id
                     AND d.account_type_code           = p_account_type_code
                     AND s.amb_context_code            = d.amb_context_code
                     AND s.segment_rule_code           = d.segment_rule_code
                     AND s.segment_rule_type_code      = d.segment_rule_type_code
                     AND s.segment_rule_detail_id = c.segment_rule_detail_id);


   l_exist    VARCHAR2(1);
   l_return   VARCHAR2(30);

   l_log_module VARCHAR2(240);
BEGIN

  l_return	:= 'FALSE';

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.source_in_use_by_tad';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure source_in_use_by_tad'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',source_code = '||p_source_code||
                      ',source_type_code = '||p_source_type_code||
                      ',account_type_code = '||p_account_type_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   OPEN check_det_value_source;
   FETCH check_det_value_source
    INTO l_exist;
   IF check_det_value_source%found THEN
      l_return := 'TRUE';
   ELSE
      l_return := 'FALSE';
   END IF;
   CLOSE check_det_value_source;

   IF l_return = 'FALSE' THEN

      OPEN check_det_input_source;
      FETCH check_det_input_source
       INTO l_exist;
      IF check_det_input_source%found THEN
         l_return := 'TRUE';
      ELSE
         l_return := 'FALSE';
      END IF;
      CLOSE check_det_input_source;
   END IF;

   IF l_return = 'FALSE' THEN

      OPEN check_con_source;
      FETCH check_con_source
       INTO l_exist;
      IF check_con_source%found THEN
         l_return := 'TRUE';
      ELSE
         l_return := 'FALSE';
      END IF;
      CLOSE check_con_source;
   END IF;

   IF l_return = 'FALSE' THEN

      OPEN check_con_value_source;
      FETCH check_con_value_source
       INTO l_exist;
      IF check_con_value_source%found THEN
         l_return := 'TRUE';
      ELSE
         l_return := 'FALSE';
      END IF;
      CLOSE check_con_value_source;
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure source_in_use_by_tad'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_sources_pkg.source_in_use_by_tad');

END source_in_use_by_tad;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_derived_source_level                                              |
|                                                                       |
| Gets the level of derived source if the source belongs to the event   |
| class                                                                 |
|                                                                       |
+======================================================================*/
FUNCTION get_derived_source_level
  (p_application_id                   IN NUMBER
  ,p_derived_source_type_code         IN VARCHAR2
  ,p_derived_source_code              IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2)
RETURN VARCHAR2

IS

   --
   -- Private variables
   --
   l_exist   VARCHAR2(1) ;
   l_level   VARCHAR2(30);

   --
   -- Cursor declarations
   --

   CURSOR class_source
   IS
   SELECT 'x'
     FROM xla_source_params r
    WHERE application_id       = p_application_id
      AND source_code          = p_derived_source_code
      AND source_type_code     = p_derived_source_type_code
      AND ref_source_code is not null
      AND ref_source_type_code = 'S'
      AND not exists (SELECT 'x'
                        FROM xla_event_sources s
                       WHERE s.source_application_id   = r.ref_source_application_id
                         AND s.source_type_code        = r.ref_source_type_code
                         AND s.source_code             = r.ref_source_code
                         AND s.application_id          = p_application_id
                         AND s.event_class_code        = p_event_class_code
                         AND s.active_flag            = 'Y');

   CURSOR lc_source
   IS
   SELECT 'x'
     FROM xla_source_params r
    WHERE application_id       = p_application_id
      AND source_code          = p_derived_source_code
      AND source_type_code     = p_derived_source_type_code
      AND ref_source_code is not null
      AND ref_source_type_code = 'S'
      AND exists (SELECT 'x'
                    FROM xla_event_sources s
                   WHERE s.source_application_id   = r.ref_source_application_id
                     AND s.source_type_code        = r.ref_source_type_code
                     AND s.source_code             = r.ref_source_code
                     AND s.application_id          = p_application_id
                     AND s.event_class_code        = p_event_class_code
                     AND s.active_flag             = 'Y'
                     AND s.level_code              = 'C');

   CURSOR line_source
   IS
   SELECT 'x'
     FROM xla_source_params r
    WHERE application_id       = p_application_id
      AND source_code          = p_derived_source_code
      AND source_type_code     = p_derived_source_type_code
      AND ref_source_code is not null
      AND ref_source_type_code = 'S'
      AND exists (SELECT 'x'
                    FROM xla_event_sources s
                   WHERE s.source_application_id   = r.ref_source_application_id
                     AND s.source_type_code        = r.ref_source_type_code
                     AND s.source_code             = r.ref_source_code
                     AND s.application_id          = p_application_id
                     AND s.event_class_code        = p_event_class_code
                     AND s.active_flag             = 'Y'
                     AND s.level_code              = 'L');

   l_log_module VARCHAR2(240);
BEGIN

  l_level	:= 'H';

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_derived_source_level';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure get_derived_source_level'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',source_code = '||p_derived_source_code||
                      ',source_type_code = '||p_derived_source_type_code||
                      ',event_class_code = '||p_event_class_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   OPEN class_source;
   FETCH class_source
    INTO l_exist;
   IF class_source%found THEN
      l_level := 'X';
   END IF;
   CLOSE class_source;

   IF l_level <> 'X' THEN

      OPEN lc_source;
      FETCH lc_source
       INTO l_exist;
      IF lc_source%found THEN
         l_level := 'C';
      ELSE
         OPEN line_source;
         FETCH line_source
          INTO l_exist;
         IF line_source%found THEN
            l_level := 'L';
         END IF;
         CLOSE line_source;
      END IF;
      CLOSE lc_source;
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure get_derived_source_level'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;


   RETURN l_level;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_pkg.get_derived_source_level');

END get_derived_source_level;

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

END xla_sources_pkg;

/
