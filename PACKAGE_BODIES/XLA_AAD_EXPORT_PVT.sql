--------------------------------------------------------
--  DDL for Package Body XLA_AAD_EXPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AAD_EXPORT_PVT" AS
/* $Header: xlaalexp.pkb 120.18 2006/05/04 18:57:18 wychan ship $ */

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------
TYPE t_array_varchar2 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_array_int      IS TABLE OF INTEGER      INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
C_CHAR CONSTANT VARCHAR2(1) := '
';

G_EXC_WARNING   EXCEPTION;

------------------------------------------------------------------------------
-- declaring global variables
------------------------------------------------------------------------------
g_aad_groups                  xla_aad_group_tbl_type;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_aad_export_pvt';

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
      (p_location   => 'xla_aad_export_pvt.trace');
END trace;


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================

--=============================================================================
--
-- Name: lock_context
--
--
--=============================================================================
FUNCTION lock_context
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c IS
    SELECT *
      FROM xla_appli_amb_contexts
     WHERE application_id   = p_application_id
       AND amb_context_code = p_amb_context_code
    FOR UPDATE OF application_id NOWAIT;

  l_lock_error    BOOLEAN;
  l_retcode       VARCHAR2(30);
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.lock_context';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function lock_context',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := 'SUCCESS';

  -- Lock the staging area of the AMB context
  l_lock_error := TRUE;
  OPEN c;
  CLOSE c;
  l_lock_error := FALSE;

  IF (l_retcode = 'SUCCESS') THEN
    l_retcode := xla_aad_loader_util_pvt.lock_area
                   (p_application_id   => p_application_id
                   ,p_amb_context_code => p_amb_context_code);

    IF (l_retcode <> 'SUCCESS') THEN
      xla_aad_loader_util_pvt.stack_error
        (p_appli_s_name  => 'XLA'
        ,p_msg_name      => 'XLA_AAD_EXP_LOCK_FAILED');
      l_retcode := 'WARNING';
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function lock_context - Return value = '||l_retcode,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION
WHEN OTHERS THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;

  IF (l_lock_error) THEN
    l_retcode := 'WARNING';
    xla_aad_loader_util_pvt.stack_error
        (p_appli_s_name  => 'XLA'
        ,p_msg_name      => 'XLA_AAD_EXP_LOCK_FAILED');

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'END of function lock_context - Return value = '||l_retcode,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    return l_retcode;
  ELSE
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.lock_context'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
    RAISE;
  END IF;
END lock_context;



--=============================================================================
--
-- Name: validate_standard_mode
-- Description: This API validate the AADs and components
-- Return codes:
--   SUCCESS - completed sucessfully
--   WARNING - completed with warning
--   ERROR   - completed with error
--
--=============================================================================
FUNCTION validate_standard_mode
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2
,p_owner_type       IN VARCHAR2)
RETURN VARCHAR2
IS
  -- Ensure the AAD to be exported is modified from
  -- one with the latest non-leapfrog version
  -- (h.version_num > b.version_num and leapfrog_flag = 'N')
  -- Ensure the AAD to be exported is not modified from a leapfrog version
  -- (h.version_num = b.version_num and leapfrog_flag = 'Y')
  CURSOR c_aad IS
    SELECT distinct t.name
      FROM xla_aads_h             h
          ,xla_product_rules_b    b
          ,xla_product_rules_tl   t
     WHERE t.application_id            = b.application_id
       AND t.amb_context_code          = b.amb_context_code
       AND t.product_rule_type_code    = b.product_rule_type_code
       AND t.product_rule_code         = b.product_rule_code
       AND t.language                  = USERENV('LANG')
       AND ((h.version_num             > b.version_num AND
             h.leapfrog_flag           = 'N') OR
            (h.version_num             = b.version_num AND
             h.leapfrog_flag           = 'Y'))
       AND h.application_id            = b.application_id
       AND h.product_rule_type_code    = b.product_rule_type_code
       AND h.product_rule_code         = b.product_rule_code
       AND b.application_id            = p_application_id
       AND b.amb_context_code          = p_amb_context_code;

  -- Ensure the ADR to be exported is modified from one with the
  -- latest non-leapfrog version
  -- (h.version_num > b.version_num and leapfrog_flag = 'N')
  -- Ensure the ADR to be exported is not modified from a leapfrog version
  -- (h.version_num = b.version_num and leapfrog_flag = 'Y')
  CURSOR c_adr IS
    SELECT distinct t.name
      FROM xla_amb_components_h   h
          ,xla_seg_rules_b        b
          ,xla_seg_rules_tl       t
     WHERE t.amb_context_code       = b.amb_context_code
       AND t.application_id         = b.application_id
       AND t.segment_rule_type_code = b.segment_rule_type_code
       AND t.segment_rule_code      = b.segment_rule_code
       AND t.language               = USERENV('LANG')
       AND ((h.version_num          > b.version_num AND
             h.leapfrog_flag        = 'N') OR
            (h.version_num          = b.version_num AND
             h.leapfrog_flag        = 'Y'))
       AND h.component_type_code    = 'AMB_ADR'
       AND h.application_id         = b.application_id
       AND h.component_owner_code   = b.segment_rule_type_code
       AND h.component_code         = b.segment_rule_code
       AND b.application_id         = p_application_id
       AND b.amb_context_code       = p_amb_context_code;

  -- Ensure the AC to be exported is modified from one with the
  -- latest non-leapfrog version
  -- (h.version_num > b.version_num and leapfrog_flag = 'N')
  -- Ensure the AC to be exported is not modified from a leapfrog version
  -- (h.version_num = b.version_num and leapfrog_flag = 'Y')
/*
  CURSOR c_ac IS
    SELECT distinct t.name
      FROM xla_amb_components_h   h
          ,xla_analytical_hdrs_b  b
          ,xla_analytical_hdrs_tl t
     WHERE t.amb_context_code               = b.amb_context_code
       AND t.analytical_criterion_type_code = b.analytical_criterion_type_code
       AND t.analytical_criterion_code      = b.analytical_criterion_code
       AND t.language                       = USERENV('LANG')
       AND ((h.version_num                  > b.version_num AND
             h.leapfrog_flag                = 'N') OR
            (h.version_num                  = b.version_num AND
             h.leapfrog_flag                = 'Y'))
       AND h.component_type_code            = 'ANALYTICAL_CRITERION'
       AND h.component_owner_code           = b.analytical_criterion_type_code
       AND h.component_code                 = b.analytical_criterion_code
       AND b.amb_context_code               = p_amb_context_code
       AND (EXISTS (SELECT 1
                      FROM xla_aad_header_ac_assgns ac
                     WHERE b.amb_context_code               = ac.amb_context_code
                       AND b.analytical_criterion_type_code = ac.analytical_criterion_type_code
                       AND b.analytical_criterion_code      = ac.analytical_criterion_code
                       AND ac.amb_context_code              = p_amb_context_code
                       AND ac.application_id                = p_application_id) OR
            EXISTS (SELECT 1
                      FROM xla_line_defn_ac_assgns ac
                         , xla_aad_line_defn_assgns xal
                     WHERE b.amb_context_code               = ac.amb_context_code
                       AND b.analytical_criterion_type_code = ac.analytical_criterion_type_code
                       AND b.analytical_criterion_code      = ac.analytical_criterion_code
                       AND ac.application_id                = xal.application_id
                       AND ac.amb_context_code              = xal.amb_context_code
                       AND ac.event_class_code              = xal.event_class_code
                       AND ac.event_type_code               = xal.event_type_code
                       AND ac.line_definition_owner_code    = xal.line_definition_owner_code
                       AND ac.line_definition_code          = xal.line_definition_code
                       AND xal.amb_context_code             = p_amb_context_code
                       AND xal.application_id               = p_application_id));
*/

  -- Ensure the MS to be exported is modified from one with the
  -- latest non-leapfrog version
  -- (h.version_num > b.version_num and leapfrog_flag = 'N')
  -- Ensure the MS to be exported is not modified from a leapfrog version
  -- (h.version_num = b.version_num and leapfrog_flag = 'Y')
  CURSOR c_ms IS
    SELECT distinct t.name
      FROM xla_amb_components_h h
          ,xla_mapping_sets_b   b
          ,xla_mapping_sets_tl  t
     WHERE t.amb_context_code      = b.amb_context_code
       AND t.mapping_set_code      = b.mapping_set_code
       AND t.language              = USERENV('LANG')
       AND ((h.version_num         > b.version_num AND
             h.leapfrog_flag       = 'N') OR
            (h.version_num         = b.version_num AND
             h.leapfrog_flag       = 'Y'))
       AND h.component_type_code   = 'MAPPING_SET'
       AND h.component_code        = b.mapping_set_code
       AND b.amb_context_code      = p_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_seg_rule_details     dtl
                        , xla_line_defn_adr_assgns adr
                        , xla_aad_line_defn_assgns xal
                    WHERE b.mapping_set_code             = dtl.value_mapping_set_code
                      AND dtl.amb_context_code           = adr.amb_context_code
                      AND dtl.application_id             = adr.segment_rule_appl_id
                      AND dtl.segment_rule_type_code     = adr.segment_rule_type_code
                      AND dtl.segment_rule_code          = adr.segment_rule_code
                      AND adr.application_id             = xal.application_id
                      AND adr.amb_context_code           = xal.amb_context_code
                      AND adr.event_class_code           = xal.event_class_code
                      AND adr.event_type_code            = xal.event_type_code
                      AND adr.line_definition_owner_code = xal.line_definition_owner_code
                      AND adr.line_definition_code       = xal.line_definition_code
                      AND xal.amb_context_code           = p_amb_context_code
                      AND xal.application_id             = p_application_id);

  l_retcode       VARCHAR2(30);
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_standard_mode';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_standard_mode',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := 'SUCCESS';

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid AAD versions (base version is not latest)',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_aad IN c_aad LOOP
    l_retcode := 'WARNING';
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - invalid AAD version: '||l_aad.name,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_aad_loader_util_pvt.stack_error
             (p_appli_s_name    => 'XLA'
             ,p_msg_name        => 'XLA_AAD_EXP_INV_LEAPFROG'
             ,p_token_1         => 'PROD_RULE_NAME'
             ,p_value_1         => l_aad.name);
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid AAD versions (base version is not latest)',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

/*
  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid AC versions',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_ac IN c_ac LOOP
    l_retcode := 'WARNING';
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - invalid AC version: '||l_ac.name,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_aad_loader_util_pvt.stack_error
             (p_appli_s_name    => 'XLA'
             ,p_msg_name        => 'XLA_AAD_EXP_INV_LEAPFROG_AC'
             ,p_token_1         => 'ANALYTICAL_CRITERION_NAME'
             ,p_value_1         => l_ac.name);
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid AC versions (base version is not latest)',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;
*/

  FOR l_adr IN c_adr LOOP
    l_retcode := 'WARNING';
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - invalid ADR version: '||l_adr.name,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_aad_loader_util_pvt.stack_error
             (p_appli_s_name    => 'XLA'
             ,p_msg_name        => 'XLA_AAD_EXP_INV_LEAPFROG_ADR'
             ,p_token_1         => 'SEGMENT_RULE_NAME'
             ,p_value_1         => l_adr.name);
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid ADR versions',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (p_owner_type = 'C') THEN
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'BEGIN LOOP - invalid export versions (MS)',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    FOR l_ms IN c_ms LOOP
      l_retcode := 'WARNING';
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'LOOP - invalid export version (MS): '||l_ms.name,
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_EXP_INV_LEAPFROG_MS'
               ,p_token_1         => 'MAPPING_SET_NAME'
               ,p_value_1         => l_ms.name);
    END LOOP;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'END LOOP - invalid export versions (MS)',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function validate_standard_mode - Return value = '||l_retcode,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  return l_retcode;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.validate_standard_mode'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END validate_standard_mode;

--=============================================================================
--
-- Name: validate_leapfrog_mode
-- Description: This API validate the AADs and components
-- Return codes:
--   SUCCESS - completed sucessfully
--   WARNING - completed with warning
--   ERROR   - completed with error
--
--=============================================================================
FUNCTION validate_leapfrog_mode
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2
,p_owner_type       IN VARCHAR2)
RETURN VARCHAR2
IS
  -- Ensure at least one AAD to be exported is not the latest non-leapfrog version
  -- (h.version_num > b.version_num and leapfrog_flag = 'N')
  -- or is modified from a leapfrog version
  -- (h.version_num = b.version_num and leapfrog_flag = 'Y')
  CURSOR c_aad IS
    SELECT 1
      FROM xla_aads_h             h
          ,xla_product_rules_b    b
     WHERE h.application_id            = b.application_id
       AND h.product_rule_type_code    = b.product_rule_type_code
       AND h.product_rule_code         = b.product_rule_code
       AND ((h.version_num             > b.version_num AND
             h.leapfrog_flag           = 'N') OR
            (h.version_num             = b.version_num AND
             h.leapfrog_flag           = 'Y'))
       AND b.application_id            = p_application_id
       AND b.amb_context_code          = p_amb_context_code;

  -- Ensure at least one ADR to be exported is not the latest non-leapfrog version
  -- (h.version_num > b.version_num and leapfrog_flag = 'N')
  -- or is modified from a leapfrog version
  -- (h.version_num = b.version_num and leapfrog_flag = 'Y')
  CURSOR c_adr IS
    SELECT 1
      FROM xla_amb_components_h   h
          ,xla_seg_rules_b        b
     WHERE h.component_type_code    = 'AMB_ADR'
       AND h.application_id         = b.application_id
       AND h.component_owner_code   = b.segment_rule_type_code
       AND h.component_code         = b.segment_rule_code
       AND ((h.version_num          > b.version_num AND
             h.leapfrog_flag        = 'N') OR
            (h.version_num          = b.version_num AND
             h.leapfrog_flag        = 'Y'))
       AND b.application_id         = p_application_id
       AND b.amb_context_code       = p_amb_context_code;

  -- Ensure at least one MS to be exported is not the latest non-leapfrog version
  -- (h.version_num > b.version_num and leapfrog_flag = 'N')
  -- or is modified from a leapfrog version
  -- (h.version_num = b.version_num and leapfrog_flag = 'Y')
  CURSOR c_ms IS
    SELECT 1
      FROM xla_amb_components_h h
          ,xla_mapping_sets_b   b
     WHERE h.component_type_code   = 'MAPPING_SET'
       AND h.component_code        = b.mapping_set_code
       AND ((h.version_num         > b.version_num AND
             h.leapfrog_flag       = 'N') OR
            (h.version_num         = b.version_num AND
             h.leapfrog_flag       = 'Y'))
       AND b.amb_context_code      = p_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_seg_rule_details     dtl
                        , xla_line_defn_adr_assgns adr
                        , xla_aad_line_defn_assgns xal
                    WHERE b.mapping_set_code             = dtl.value_mapping_set_code
                      AND dtl.amb_context_code           = adr.amb_context_code
                      AND dtl.application_id             = adr.segment_rule_appl_id
                      AND dtl.segment_rule_type_code     = adr.segment_rule_type_code
                      AND dtl.segment_rule_code          = adr.segment_rule_code
                      AND adr.application_id             = xal.application_id
                      AND adr.amb_context_code           = xal.amb_context_code
                      AND adr.event_class_code           = xal.event_class_code
                      AND adr.event_type_code            = xal.event_type_code
                      AND adr.line_definition_owner_code = xal.line_definition_owner_code
                      AND adr.line_definition_code       = xal.line_definition_code
                      AND xal.amb_context_code           = p_amb_context_code
                      AND xal.application_id             = p_application_id);

  l_exists        INTEGER;
  l_retcode       VARCHAR2(30);
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_leapfrog_mode';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_leapfrog_mode',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := 'SUCCESS';

  l_exists := NULL;
  OPEN c_aad;
  FETCH c_aad INTO l_exists;
  CLOSE c_aad;

  IF (l_exists IS NULL) THEN
    OPEN c_adr;
    FETCH c_adr INTO l_exists;
    CLOSE c_adr;
  END IF;

  IF (l_exists IS NULL) THEN
    OPEN c_ms;
    FETCH c_ms INTO l_exists;
    CLOSE c_ms;
  END IF;

  -- If none of the AMB objects is based on a leapfrog version, or based on a
  -- not-the-latest version, LEAPFROG mode should not be used.  It is a STANDARD case.
  IF (l_exists IS NULL) THEN
    l_retcode := 'WARNING';
    xla_aad_loader_util_pvt.stack_error
             (p_appli_s_name    => 'XLA'
             ,p_msg_name        => 'XLA_AAD_EXP_INV_NON_LEAPFROG');

  END IF;

  return l_retcode;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.validate_leapfrog_mode'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END validate_leapfrog_mode;

--=============================================================================
--
-- Name: validate_supersede_mode
-- Description: This API validate the AADs and components
-- Return codes:
--   SUCCESS - completed sucessfully
--   WARNING - completed with warning
--   ERROR   - completed with error
--
--=============================================================================
FUNCTION validate_supersede_mode
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2
,p_owner_type       IN VARCHAR2)
RETURN VARCHAR2
IS
  l_retcode       VARCHAR2(30);
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_supersede_mode';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_supersede_mode',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := 'SUCCESS';

  return l_retcode;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.validate_supersede_mode'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END validate_supersede_mode;

--=============================================================================
--
-- Name: validation
-- Description: This API validate the AADs and components
-- Return codes:
--   SUCCESS - completed sucessfully
--   WARNING - completed with warning
--   ERROR   - completed with error
--
--=============================================================================
FUNCTION validation
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2
,p_owner_type       IN VARCHAR2
,p_versioning_mode  IN VARCHAR2)
RETURN VARCHAR2
IS
  l_retcode       VARCHAR2(30);
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validation';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validation',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (p_versioning_mode = 'STANDARD') THEN
    l_retcode := validate_standard_mode
                     (p_application_id   => p_application_id
                     ,p_amb_context_code => p_amb_context_code
                     ,p_owner_type       => p_owner_type);
  ELSIF (p_versioning_mode = 'LEAPFROG') THEN
    l_retcode := validate_leapfrog_mode
                     (p_application_id   => p_application_id
                     ,p_amb_context_code => p_amb_context_code
                     ,p_owner_type       => p_owner_type);
  ELSE  -- p_versioning_mode = 'SUPERSEDE'
    l_retcode := validate_supersede_mode
                     (p_application_id   => p_application_id
                     ,p_amb_context_code => p_amb_context_code
                     ,p_owner_type       => p_owner_type);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function validation - Return value = '||l_retcode,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  return l_retcode;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.validation'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END validation;

--=============================================================================
--
-- Name: update_group_number
-- Description: This API update the product rule in global aad group arry with
--              the group number
-- Return Code:
--   TRUE: group number is updated
--   FALSE: group number is not updated
--
--=============================================================================
FUNCTION update_group_number
(p_product_rule_code       VARCHAR2
,p_group_number            INTEGER)
RETURN BOOLEAN
IS
  l_retcode       BOOLEAN;
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_group_number';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function update_group_number: '||
                      p_product_rule_code||','||p_group_number,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := FALSE;

  FOR i IN 1 .. g_aad_groups.COUNT LOOP
    IF (g_aad_groups(i).product_rule_code = p_product_rule_code) THEN
      IF (g_aad_groups(i).group_num <> p_group_number) THEN
        g_aad_groups(i).group_num := p_group_number;
        l_retcode := TRUE;
      END IF;
      EXIT;
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function update_group_number : '||
                      'l_retcode = '||CASE WHEN l_retcode THEN 'TRUE'
                                           ELSE 'FALSE' END,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  return l_retcode;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.update_group_number'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END update_group_number;

--=============================================================================
--
-- Name: group_aads
-- Description: This API groups the AAD with the same group number if they
--              shares any commom components.  The group number information is
--              stored in the g_aad_groups global array.
--
--=============================================================================
PROCEDURE group_aads
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2
,p_owner_type       IN VARCHAR2)
IS
  l_curr_group_num     INTEGER;

  -- Cursor to return all AADs to be grouped
  CURSOR c_aad IS
    SELECT distinct
           b.product_rule_code
          ,b.version_num
          ,b.updated_flag
          ,NVL(h.leapfrog_flag,'N') leapfrog_flag
      FROM xla_product_rules_b b
           JOIN xla_aads_h h
             ON h.product_rule_code        = b.product_rule_code
            AND h.application_id           = p_application_id
            AND h.product_rule_type_code   = p_owner_type
           JOIN (SELECT product_rule_code, max(version_num) max_version_num
                   FROM xla_aads_h
                  WHERE application_id         = p_application_id
                    AND product_rule_type_code = p_owner_type
                  GROUP BY product_rule_code) h2
             ON h.product_rule_code        = h2.product_rule_code
            AND h.version_num              = h2.max_version_num
     WHERE b.application_id           = p_application_id
       AND b.amb_context_code         = p_amb_context_code
       AND b.product_rule_type_code   = p_owner_type
     UNION
    SELECT distinct
           b.product_rule_code
          ,b.version_num
          ,b.updated_flag
          ,NVL(h.leapfrog_flag,'N') leapfrog_flag
      FROM xla_product_rules_b b
           LEFT OUTER JOIN  xla_aads_h h
             ON h.product_rule_code        = b.product_rule_code
            AND h.application_id           = p_application_id
            AND h.product_rule_type_code   = p_owner_type
     WHERE b.application_id           = p_application_id
       AND b.amb_context_code         = p_amb_context_code
       AND b.product_rule_type_code   = p_owner_type
       AND h.product_rule_code        IS NULL;

  -- Cursor to return AADs that shares any common component with the AADs that
  -- was assigned with the group l_curr_group_num
  CURSOR c_aad_group IS
  SELECT xal.product_rule_code
    FROM xla_aad_line_defn_assgns xal
   WHERE xal.application_id           = p_application_id
     AND xal.amb_context_code         = p_amb_context_code
     AND xal.product_rule_type_code   = p_owner_type
     AND EXISTS (SELECT 1
                   FROM xla_aad_line_defn_assgns xal2
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xal2.application_id              = xal.application_id
                    AND xal2.amb_context_code            = xal.amb_context_code
                    AND xal2.event_class_code            = xal.event_class_code
                    AND xal2.event_type_code             = xal.event_type_code
                    AND xal2.line_definition_owner_code  = xal.line_definition_owner_code
                    AND xal2.line_definition_code        = xal.line_definition_code
                    AND xal2.product_rule_type_code      = p_owner_type
                    AND xal2.product_rule_code           = grp.product_rule_code
                    AND grp.group_num                    = l_curr_group_num)
   UNION
  SELECT h.product_rule_code  -- header description
    FROM xla_prod_acct_headers h
   WHERE h.application_id          = p_application_id
     AND h.amb_context_code        = p_amb_context_code
     AND h.product_rule_type_code  = p_owner_type
     AND EXISTS (SELECT 1
                   FROM xla_prod_acct_headers pah
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE pah.application_id         = p_application_id
                    AND pah.amb_context_code       = p_amb_context_code
                    AND pah.description_type_code  = h.description_type_code
                    AND pah.description_code       = h.description_code
                    AND pah.product_rule_type_code = p_owner_type
                    AND pah.product_rule_code      = grp.product_rule_code
                    AND grp.group_num              = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xal
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.description_type_code      = h.description_type_code
                    AND xjl.description_code           = h.description_code
                    AND xal.application_id             = p_application_id
                    AND xal.amb_context_code           = p_amb_context_code
                    AND xal.product_rule_type_code     = p_owner_type
                    AND xal.product_rule_code          = grp.product_rule_code
                    AND xal.event_class_code           = xjl.event_class_code
                    AND xal.event_type_code            = xjl.event_type_code
                    AND xal.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xal.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xal
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.mpa_header_desc_type_code  = h.description_type_code
                    AND xjl.mpa_header_desc_code       = h.description_code
                    AND xal.application_id             = p_application_id
                    AND xal.amb_context_code           = p_amb_context_code
                    AND xal.product_rule_type_code     = p_owner_type
                    AND xal.product_rule_code          = grp.product_rule_code
                    AND xal.event_class_code           = xjl.event_class_code
                    AND xal.event_type_code            = xjl.event_type_code
                    AND xal.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xal.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xal
                       ,xla_mpa_jlt_assgns       xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.description_type_code      = h.description_type_code
                    AND xjl.description_code           = h.description_code
                    AND xal.application_id             = p_application_id
                    AND xal.amb_context_code           = p_amb_context_code
                    AND xal.product_rule_type_code     = p_owner_type
                    AND xal.product_rule_code          = grp.product_rule_code
                    AND xal.event_class_code           = xjl.event_class_code
                    AND xal.event_type_code            = xjl.event_type_code
                    AND xal.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xal.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num)
   UNION
  SELECT xal.product_rule_code
    FROM xla_line_defn_jlt_assgns h  -- line description
        ,xla_aad_line_defn_assgns xal
   WHERE h.application_id             = xal.application_id
     AND h.amb_context_code           = xal.amb_context_code
     AND h.event_class_code           = xal.event_class_code
     AND h.event_type_code            = xal.event_type_code
     AND h.line_definition_owner_code = xal.line_definition_owner_code
     AND h.line_definition_code       = xal.line_definition_code
     AND xal.application_id           = p_application_id
     AND xal.amb_context_code         = p_amb_context_code
     AND xal.product_rule_type_code   = p_owner_type
     AND EXISTS (SELECT 1
                   FROM xla_prod_acct_headers pah
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE pah.application_id         = p_application_id
                    AND pah.amb_context_code       = p_amb_context_code
                    AND pah.description_type_code  = h.description_type_code
                    AND pah.description_code       = h.description_code
                    AND pah.product_rule_type_code = p_owner_type
                    AND pah.product_rule_code      = grp.product_rule_code
                    AND grp.group_num              = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xad
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.description_type_code      = h.description_type_code
                    AND xjl.description_code           = h.description_code
                    AND xad.application_id             = p_application_id
                    AND xad.amb_context_code           = p_amb_context_code
                    AND xad.product_rule_type_code     = p_owner_type
                    AND xad.product_rule_code          = grp.product_rule_code
                    AND xad.event_class_code           = xjl.event_class_code
                    AND xad.event_type_code            = xjl.event_type_code
                    AND xad.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xad.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xal
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.mpa_header_desc_type_code  = h.description_type_code
                    AND xjl.mpa_header_desc_code       = h.description_code
                    AND xal.application_id             = p_application_id
                    AND xal.amb_context_code           = p_amb_context_code
                    AND xal.product_rule_type_code     = p_owner_type
                    AND xal.product_rule_code          = grp.product_rule_code
                    AND xal.event_class_code           = xjl.event_class_code
                    AND xal.event_type_code            = xjl.event_type_code
                    AND xal.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xal.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xal
                       ,xla_mpa_jlt_assgns       xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.description_type_code      = h.description_type_code
                    AND xjl.description_code           = h.description_code
                    AND xal.application_id             = p_application_id
                    AND xal.amb_context_code           = p_amb_context_code
                    AND xal.product_rule_type_code     = p_owner_type
                    AND xal.product_rule_code          = grp.product_rule_code
                    AND xal.event_class_code           = xjl.event_class_code
                    AND xal.event_type_code            = xjl.event_type_code
                    AND xal.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xal.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num)
   UNION
  SELECT xal.product_rule_code
    FROM xla_line_defn_jlt_assgns h  -- MPA header description
        ,xla_aad_line_defn_assgns xal
   WHERE h.application_id             = xal.application_id
     AND h.amb_context_code           = xal.amb_context_code
     AND h.event_class_code           = xal.event_class_code
     AND h.event_type_code            = xal.event_type_code
     AND h.line_definition_owner_code = xal.line_definition_owner_code
     AND h.line_definition_code       = xal.line_definition_code
     AND xal.application_id           = p_application_id
     AND xal.amb_context_code         = p_amb_context_code
     AND xal.product_rule_type_code   = p_owner_type
     AND EXISTS (SELECT 1
                   FROM xla_prod_acct_headers pah
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE pah.application_id         = p_application_id
                    AND pah.amb_context_code       = p_amb_context_code
                    AND pah.description_type_code  = h.mpa_header_desc_type_code
                    AND pah.description_code       = h.mpa_header_desc_code
                    AND pah.product_rule_type_code = p_owner_type
                    AND pah.product_rule_code      = grp.product_rule_code
                    AND grp.group_num              = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xad
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.description_type_code      = h.mpa_header_desc_type_code
                    AND xjl.description_code           = h.mpa_header_desc_code
                    AND xad.application_id             = p_application_id
                    AND xad.amb_context_code           = p_amb_context_code
                    AND xad.product_rule_type_code     = p_owner_type
                    AND xad.product_rule_code          = grp.product_rule_code
                    AND xad.event_class_code           = xjl.event_class_code
                    AND xad.event_type_code            = xjl.event_type_code
                    AND xad.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xad.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xal
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.mpa_header_desc_type_code  = h.mpa_header_desc_type_code
                    AND xjl.mpa_header_desc_code       = h.mpa_header_desc_code
                    AND xal.application_id             = p_application_id
                    AND xal.amb_context_code           = p_amb_context_code
                    AND xal.product_rule_type_code     = p_owner_type
                    AND xal.product_rule_code          = grp.product_rule_code
                    AND xal.event_class_code           = xjl.event_class_code
                    AND xal.event_type_code            = xjl.event_type_code
                    AND xal.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xal.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xal
                       ,xla_mpa_jlt_assgns       xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.description_type_code      = h.mpa_header_desc_type_code
                    AND xjl.description_code           = h.mpa_header_desc_code
                    AND xal.application_id             = p_application_id
                    AND xal.amb_context_code           = p_amb_context_code
                    AND xal.product_rule_type_code     = p_owner_type
                    AND xal.product_rule_code          = grp.product_rule_code
                    AND xal.event_class_code           = xjl.event_class_code
                    AND xal.event_type_code            = xjl.event_type_code
                    AND xal.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xal.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num)
   UNION
  SELECT xal.product_rule_code
    FROM xla_mpa_jlt_assgns       h  -- MPA line description
        ,xla_aad_line_defn_assgns xal
   WHERE h.application_id             = xal.application_id
     AND h.amb_context_code           = xal.amb_context_code
     AND h.event_class_code           = xal.event_class_code
     AND h.event_type_code            = xal.event_type_code
     AND h.line_definition_owner_code = xal.line_definition_owner_code
     AND h.line_definition_code       = xal.line_definition_code
     AND xal.application_id           = p_application_id
     AND xal.amb_context_code         = p_amb_context_code
     AND xal.product_rule_type_code   = p_owner_type
     AND EXISTS (SELECT 1
                   FROM xla_prod_acct_headers pah
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE pah.application_id         = p_application_id
                    AND pah.amb_context_code       = p_amb_context_code
                    AND pah.description_type_code  = h.description_type_code
                    AND pah.description_code       = h.description_code
                    AND pah.product_rule_type_code = p_owner_type
                    AND pah.product_rule_code      = grp.product_rule_code
                    AND grp.group_num              = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xad
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.description_type_code      = h.description_type_code
                    AND xjl.description_code           = h.description_code
                    AND xad.application_id             = p_application_id
                    AND xad.amb_context_code           = p_amb_context_code
                    AND xad.product_rule_type_code     = p_owner_type
                    AND xad.product_rule_code          = grp.product_rule_code
                    AND xad.event_class_code           = xjl.event_class_code
                    AND xad.event_type_code            = xjl.event_type_code
                    AND xad.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xad.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xal
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.mpa_header_desc_type_code  = h.description_type_code
                    AND xjl.mpa_header_desc_code       = h.description_code
                    AND xal.application_id             = p_application_id
                    AND xal.amb_context_code           = p_amb_context_code
                    AND xal.product_rule_type_code     = p_owner_type
                    AND xal.product_rule_code          = grp.product_rule_code
                    AND xal.event_class_code           = xjl.event_class_code
                    AND xal.event_type_code            = xjl.event_type_code
                    AND xal.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xal.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xal
                       ,xla_mpa_jlt_assgns       xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.description_type_code      = h.description_type_code
                    AND xjl.description_code           = h.description_code
                    AND xal.application_id             = p_application_id
                    AND xal.amb_context_code           = p_amb_context_code
                    AND xal.product_rule_type_code     = p_owner_type
                    AND xal.product_rule_code          = grp.product_rule_code
                    AND xal.event_class_code           = xjl.event_class_code
                    AND xal.event_type_code            = xjl.event_type_code
                    AND xal.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xal.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num)
  UNION
  SELECT xal.product_rule_code
    FROM xla_line_defn_jlt_assgns h  -- JLT
        ,xla_aad_line_defn_assgns xal
   WHERE h.application_id             = xal.application_id
     AND h.amb_context_code           = xal.amb_context_code
     AND h.event_class_code           = xal.event_class_code
     AND h.event_type_code            = xal.event_type_code
     AND h.line_definition_owner_code = xal.line_definition_owner_code
     AND h.line_definition_code       = xal.line_definition_code
     AND xal.application_id           = p_application_id
     AND xal.amb_context_code         = p_amb_context_code
     AND xal.product_rule_type_code   = p_owner_type
     AND EXISTS (SELECT 1
                   FROM xla_aad_line_defn_assgns xad
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.event_class_code           = h.event_class_code
                    AND xjl.accounting_line_type_code  = h.accounting_line_type_code
                    AND xjl.accounting_line_code       = h.accounting_line_code
                    AND xad.event_class_code           = xjl.event_class_code
                    AND xad.event_type_code            = xjl.event_type_code
                    AND xad.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xad.line_definition_code       = xjl.line_definition_code
                    AND xad.application_id             = p_application_id
                    AND xad.amb_context_code           = p_amb_context_code
                    AND xad.product_rule_type_code     = p_owner_type
                    AND xad.product_rule_code          = grp.product_rule_code
                    AND grp.group_num                  = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xad
                       ,xla_mpa_jlt_assgns       xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id                 = p_application_id
                    AND xjl.amb_context_code               = p_amb_context_code
                    AND xjl.event_class_code               = h.event_class_code
                    AND xjl.mpa_accounting_line_type_code  = h.accounting_line_type_code
                    AND xjl.mpa_accounting_line_code       = h.accounting_line_code
                    AND xad.event_class_code               = xjl.event_class_code
                    AND xad.event_type_code                = xjl.event_type_code
                    AND xad.line_definition_owner_code     = xjl.line_definition_owner_code
                    AND xad.line_definition_code           = xjl.line_definition_code
                    AND xad.application_id                 = p_application_id
                    AND xad.amb_context_code               = p_amb_context_code
                    AND xad.product_rule_type_code         = p_owner_type
                    AND xad.product_rule_code              = grp.product_rule_code
                    AND grp.group_num                      = l_curr_group_num)
  UNION
  SELECT xal.product_rule_code
    FROM xla_mpa_jlt_assgns       h  -- MPA JLT
        ,xla_aad_line_defn_assgns xal
   WHERE h.application_id             = xal.application_id
     AND h.amb_context_code           = xal.amb_context_code
     AND h.event_class_code           = xal.event_class_code
     AND h.event_type_code            = xal.event_type_code
     AND h.line_definition_owner_code = xal.line_definition_owner_code
     AND h.line_definition_code       = xal.line_definition_code
     AND xal.application_id           = p_application_id
     AND xal.amb_context_code         = p_amb_context_code
     AND xal.product_rule_type_code   = p_owner_type
     AND EXISTS (SELECT 1
                   FROM xla_aad_line_defn_assgns xad
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = p_application_id
                    AND xjl.amb_context_code           = p_amb_context_code
                    AND xjl.event_class_code           = h.event_class_code
                    AND xjl.accounting_line_type_code  = h.accounting_line_type_code
                    AND xjl.accounting_line_code       = h.accounting_line_code
                    AND xad.event_class_code           = xjl.event_class_code
                    AND xad.event_type_code            = xjl.event_type_code
                    AND xad.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xad.line_definition_code       = xjl.line_definition_code
                    AND xad.application_id             = p_application_id
                    AND xad.amb_context_code           = p_amb_context_code
                    AND xad.product_rule_type_code     = p_owner_type
                    AND xad.product_rule_code          = grp.product_rule_code
                    AND grp.group_num                  = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xad
                       ,xla_mpa_jlt_assgns       xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id                 = p_application_id
                    AND xjl.amb_context_code               = p_amb_context_code
                    AND xjl.event_class_code               = h.event_class_code
                    AND xjl.mpa_accounting_line_type_code  = h.accounting_line_type_code
                    AND xjl.mpa_accounting_line_code       = h.accounting_line_code
                    AND xad.event_class_code               = xjl.event_class_code
                    AND xad.event_type_code                = xjl.event_type_code
                    AND xad.line_definition_owner_code     = xjl.line_definition_owner_code
                    AND xad.line_definition_code           = xjl.line_definition_code
                    AND xad.application_id                 = p_application_id
                    AND xad.amb_context_code               = p_amb_context_code
                    AND xad.product_rule_type_code         = p_owner_type
                    AND xad.product_rule_code              = grp.product_rule_code
                    AND grp.group_num                      = l_curr_group_num);

  -- Cursor to return the next AAD that is not grouped
  CURSOR c_next_aad IS
    SELECT product_rule_code
      FROM TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type))
     WHERE group_num = 0;

  l_aad_group        xla_aad_group_rec_type;
  l_updated          BOOLEAN;
  l_code             VARCHAR2(30);
  l_count            INTEGER;
  l_log_module       VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.group_aads';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg      => 'BEGIN of procedure group_aads'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  g_aad_groups := xla_aad_group_tbl_type();

  l_count := 0;

  -- Initialize the AAD array
  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - retrieve AADs',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  -- Insert all AADs to be grouped in the the g_aad_groups array
  FOR l_aad IN c_aad LOOP
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - AAD: '||
                        'product_rule_code='||l_aad.product_rule_code||
                        ',version_num='||l_aad.version_num||
                        ',updated_flag='||l_aad.updated_flag||
                        ',leapfrog_flag='||l_aad.leapfrog_flag
           ,p_module => l_log_module
           ,p_level  => C_LEVEL_ERROR);
    END IF;

    l_aad_group := xla_aad_group_rec_type
                      (p_owner_type
                      ,l_aad.product_rule_code
                      ,0
                      ,l_aad.version_num
                      ,l_aad.updated_flag
                      ,l_aad.leapfrog_flag
                      ,NULL);

    l_count := l_count + 1;
    g_aad_groups.EXTEND;
    g_aad_groups(l_count) := l_aad_group;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - retrieve AADs',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  l_curr_group_num := 1;
  IF (g_aad_groups.COUNT > 0) THEN
    g_aad_groups(1).group_num := l_curr_group_num;
  END IF;

  --
  -- Loop until all application accounting definitions are assigned
  -- with a group number
  --
  LOOP
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'BEGIN LOOP - current group number = '||l_curr_group_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;
    --
    -- Loop until no more new application accounting definitions is
    -- found to be sharing any journal entry setups with the
    -- definitions in the current group.
    --
    LOOP
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'BEGIN LOOP - Retrieve group = '||l_curr_group_num,
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      OPEN c_aad_group;
      l_updated := FALSE;

      --
      -- Loop until all application accounting definitions that
      -- shares journal entry sets with the definitions in the
      -- current group are marked with the current group number.
      LOOP
        FETCH c_aad_group INTO l_code;
        EXIT WHEN c_aad_group%NOTFOUND;

        IF (C_LEVEL_ERROR >= g_log_level) THEN
          trace(p_msg    => 'LOOP - group = '||l_curr_group_num||
                            ', aad = '||l_code,
                p_module => l_log_module,
                p_level  => C_LEVEL_ERROR);
        END IF;

        IF (update_group_number(l_code
                               ,l_curr_group_num)) THEN
          l_updated := TRUE;
        END IF;
      END LOOP;
      CLOSE c_aad_group;
      --
      IF (NOT l_updated) THEN
        IF (C_LEVEL_ERROR >= g_log_level) THEN
          trace(p_msg    => 'l_updated = FALSE, EXIT',
                p_module => l_log_module,
                p_level  => C_LEVEL_ERROR);
        END IF;

        EXIT;
      END IF;
    END LOOP;

    OPEN c_next_aad;
    FETCH c_next_aad INTO l_code;
    EXIT WHEN c_next_aad%NOTFOUND;

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Next AAD = '||l_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    CLOSE c_next_aad;
    l_curr_group_num := l_curr_group_num + 1;
    l_updated := update_group_number(l_code
                                    ,l_curr_group_num);
  END LOOP;
  CLOSE c_next_aad;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    FOR i IN 1 .. g_aad_groups.COUNT LOOP
      trace(p_msg    => 'group='||g_aad_groups(i).group_num||
                        ' '||g_aad_groups(i).product_rule_code
           ,p_module => l_log_module
           ,p_level  => C_LEVEL_PROCEDURE);
    END LOOP;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure group_aads'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.group_aads'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END group_aads;


--=============================================================================
--
-- Name: update_aad_version
-- Description: This API updates the veresion of the AAD
--
--=============================================================================
PROCEDURE update_aad_version
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2
,p_owner_type       IN VARCHAR2
,p_versioning_mode  IN VARCHAR2
,p_user_version     IN VARCHAR2
,p_version_comment  IN VARCHAR2)
IS
  CURSOR c_aad_version IS
    SELECT distinct
           grp.product_rule_code
          ,grp.version_num version_from
          ,(MAX(NVL(h.version_num,0)) OVER (PARTITION BY grp.group_num))+1 version_to
      FROM TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
         , xla_aads_h                    h
     WHERE h.application_id(+)             = p_application_id
       AND h.product_rule_type_code(+)     = p_owner_type
       AND h.product_rule_code(+)          = grp.product_rule_code
       AND grp.group_num IN
           (SELECT grp2.group_num
              FROM TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp2
             WHERE grp2.updated_flag       = 'Y'
                OR grp2.leapfrog_flag      = 'Y');

  CURSOR c_aad_unchanged IS
    SELECT grp.product_rule_code
         , max(h.version_num) version_to
      FROM TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
         , xla_aads_h                    h
     WHERE h.application_id             = p_application_id
       AND h.product_rule_type_code     = p_owner_type
       AND h.product_rule_code          = grp.product_rule_code
       AND NOT EXISTS
           (SELECT 1
              FROM TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp2
             WHERE (grp2.updated_flag       = 'Y' OR
                    grp2.leapfrog_flag      = 'Y')
               AND grp2.group_num          = grp.group_num)
     GROUP BY grp.product_rule_code;

  l_aad_codes      t_array_varchar2;
  l_versions_from  t_array_int;
  l_versions_to    t_array_int;
  i                INTEGER;

  l_log_module     VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_aad_version';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_aad_version',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  group_aads
           (p_application_id   => p_application_id
           ,p_amb_context_code => p_amb_context_code
           ,p_owner_type       => p_owner_type);

  i := 0;
  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - AAD versions',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_aad IN c_aad_version LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - AAD version: '||
                        'product_rule_code='||l_aad.product_rule_code||
                        ',version_from='||l_aad.version_from||
                        ',version_to='||l_aad.version_to
           ,p_module => l_log_module
           ,p_level  => C_LEVEL_EVENT);
    END IF;

    i := i + 1;
    l_aad_codes(i)     := l_aad.product_rule_code;
    l_versions_from(i) := l_aad.version_from;
    l_versions_to(i)   := l_aad.version_to;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - AAD versions',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FORALL i IN 1 .. l_aad_codes.COUNT
    INSERT INTO xla_aads_h
    (application_id
    ,product_rule_type_code
    ,product_rule_code
    ,version_num
    ,base_version_num
    ,user_version
    ,version_comment
    ,leapfrog_flag
    ,object_version_number
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,program_update_date
    ,program_application_id
    ,program_id
    ,request_id)
    VALUES
    (p_application_id
    ,p_owner_type
    ,l_aad_codes(i)
    ,l_versions_to(i)
    ,l_versions_from(i)
    ,p_user_version
    ,p_version_comment
    ,DECODE(p_versioning_mode,'LEAPFROG','Y','N')
    ,1
    ,sysdate
    ,xla_environment_pkg.g_usr_id
    ,sysdate
    ,xla_environment_pkg.g_usr_id
    ,xla_environment_pkg.g_login_id
    ,sysdate
    ,xla_environment_pkg.g_prog_appl_id
    ,xla_environment_pkg.g_prog_id
    ,xla_environment_pkg.g_req_Id);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row inserted in xla_aads_h = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - unchanged AAD',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_aad IN c_aad_unchanged LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - unchanged AAD: '||
                        'product_rule_code='||l_aad.product_rule_code
           ,p_module => l_log_module
           ,p_level  => C_LEVEL_EVENT);
    END IF;

    i := i + 1;
    l_aad_codes(i)     := l_aad.product_rule_code;
    l_versions_from(i) := -1;
    l_versions_to(i)   := l_aad.version_to;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - unchanged AAD',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FORALL i IN 1 .. l_aad_codes.COUNT
    UPDATE xla_product_rules_b
       SET version_num            = l_versions_to(i)
          ,updated_flag           = 'N'
          ,product_rule_version   = p_user_version
          ,creation_date          = sysdate
          ,created_by             = xla_environment_pkg.g_usr_id
          ,last_update_date       = sysdate
          ,last_updated_by        = xla_environment_pkg.g_usr_id
          ,last_update_login      = xla_environment_pkg.g_login_id
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
       AND product_rule_type_code = p_owner_type
       AND product_rule_code      = l_aad_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row updated in xla_product_rules_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1 .. l_aad_codes.COUNT
    UPDATE xla_aads_h
       SET user_version           = p_user_version
         , version_comment        = p_version_comment
         , program_update_date    = sysdate
         , program_application_id = xla_environment_pkg.g_prog_appl_id
         , program_id             = xla_environment_pkg.g_prog_id
         , request_id             = xla_environment_pkg.g_req_Id
     WHERE application_id                = p_application_id
       AND product_rule_type_code        = p_owner_type
       AND product_rule_code             = l_aad_codes(i)
       AND version_num                   = l_versions_to(i)
       AND (NVL(user_version,C_CHAR)    <> NVL(p_user_version,C_CHAR) OR
            NVL(version_comment,C_CHAR) <> NVL(p_version_comment,C_CHAR));

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row updated in xla_aads_h = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure update_aad_version',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.update_aad_version'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END update_aad_version;

--=============================================================================
--
-- Name: update_ac_version
-- Description: This API updates the version of the analytical criteria
--
--=============================================================================
PROCEDURE update_ac_version
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2
,p_versioning_mode  IN VARCHAR2)
IS
  CURSOR c_ac IS
    SELECT b.analytical_criterion_type_code
          ,b.analytical_criterion_code
          ,b.version_num                 version_from
          ,MAX(NVL(h.version_num,0))+1   version_to
      FROM xla_analytical_hdrs_b     b
          ,xla_amb_components_h      h
     WHERE h.component_owner_code(+)        = b.analytical_criterion_type_code
       AND h.component_code(+)              = b.analytical_criterion_code
       AND h.component_type_code(+)         = 'ANALYTICAL_CRITERION'
       AND b.updated_flag                   = 'Y'
       AND EXISTS
           (SELECT 1
              FROM xla_aad_header_ac_assgns a
             WHERE a.application_id                 = p_application_id
               AND a.amb_context_code               = p_amb_context_code
               AND b.amb_context_code               = a.amb_context_code
               AND b.analytical_criterion_type_code = a.analytical_criterion_type_code
               AND b.analytical_criterion_code      = a.analytical_criterion_code
             UNION
            SELECT 1
              FROM xla_aad_line_defn_assgns l
                 , xla_line_defn_ac_assgns a
             WHERE l.application_id                 = p_application_id
               AND l.amb_context_code               = p_amb_context_code
               AND a.application_id                 = l.application_id
               AND a.amb_context_code               = l.amb_context_code
               AND a.event_class_code               = l.event_class_code
               AND a.event_type_code                = l.event_type_code
               AND a.line_definition_owner_code     = l.line_definition_owner_code
               AND a.line_definition_code           = l.line_definition_code
               AND b.amb_context_code               = a.amb_context_code
               AND b.analytical_criterion_type_code = a.analytical_criterion_type_code
               AND b.analytical_criterion_code      = a.analytical_criterion_code)
     GROUP BY b.analytical_criterion_type_code, b.analytical_criterion_code, b.version_num;

  l_ac_owner_codes   t_array_varchar2;
  l_ac_codes         t_array_varchar2;
  l_ac_version_from  t_array_int;
  l_ac_version_to    t_array_int;
  i                  INTEGER;

  l_log_module      VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_ac_version';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_ac_version',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  i := 0;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - retrieve analytical criteria',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_ac in c_ac LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - analytical criterion = '||
                        l_ac.analytical_criterion_type_code||','||
                        l_ac.analytical_criterion_code||','||
                        l_ac.version_from||','||
                        l_ac.version_to,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    i := i + 1;
    l_ac_owner_codes(i)  := l_ac.analytical_criterion_type_code;
    l_ac_codes(i)        := l_ac.analytical_criterion_code;
    l_ac_version_from(i) := l_ac.version_from;
    l_ac_version_to(i)   := l_ac.version_to;
  END LOOP;

  FORALL i IN 1 .. l_ac_codes.COUNT
    INSERT INTO xla_amb_components_h
    (component_type_code
    ,component_owner_code
    ,component_code
    ,application_id
    ,version_num
    ,base_version_num
    ,leapfrog_flag
    ,object_version_number
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,program_update_date
    ,program_application_id
    ,program_id
    ,request_id)
    VALUES
    ('ANALYTICAL_CRITERION'
    ,l_ac_owner_codes(i)
    ,l_ac_codes(i)
    ,-1
    ,l_ac_version_to(i)
    ,l_ac_version_from(i)
    ,DECODE(p_versioning_mode,'LEAPFROG','Y','N')
    ,1
    ,sysdate
    ,xla_environment_pkg.g_usr_id
    ,sysdate
    ,xla_environment_pkg.g_usr_id
    ,xla_environment_pkg.g_login_id
    ,sysdate
    ,xla_environment_pkg.g_prog_appl_id
    ,xla_environment_pkg.g_prog_id
    ,xla_environment_pkg.g_req_Id);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row inserted in xla_amb_components_h = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1 .. l_ac_codes.COUNT
    UPDATE xla_analytical_hdrs_b
       SET version_num       = l_ac_version_to(i)
          ,updated_flag      = 'N'
          ,creation_date     = sysdate
          ,created_by        = xla_environment_pkg.g_usr_id
          ,last_update_date  = sysdate
          ,last_updated_by   = xla_environment_pkg.g_usr_id
          ,last_update_login = xla_environment_pkg.g_login_id
     WHERE analytical_criterion_type_code = l_ac_owner_codes(i)
       AND analytical_criterion_code      = l_ac_codes(i)
       AND amb_context_code               = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row updated in xla_analytical_hdrs_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - retrieve analytical criteria',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure update_ac_version',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.update_ac_version'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END update_ac_version;

--=============================================================================
--
-- Name: update_adr_version
-- Description: This API updates the version of the adr of the exporting
--              application that is used by any application
--
--=============================================================================
PROCEDURE update_adr_version
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2
,p_versioning_mode  IN VARCHAR2)
IS
  CURSOR c_adr IS
    SELECT b.segment_rule_type_code
          ,b.segment_rule_code
          ,b.version_num                 version_from
          ,MAX(NVL(h.version_num,0))+1   version_to
      FROM xla_seg_rules_b           b
          ,xla_amb_components_h      h
     WHERE h.application_id(+)              = b.application_id
       AND h.component_owner_code(+)        = b.segment_rule_type_code
       AND h.component_code(+)              = b.segment_rule_code
       AND h.component_type_code(+)         = 'AMB_ADR'
       AND b.amb_context_code               = p_amb_context_code
       AND b.application_id                 = p_application_id
       AND b.updated_flag                   = 'Y'
     GROUP BY b.segment_rule_type_code, b.segment_rule_code, b.version_num;

  l_adr_owner_codes   t_array_varchar2;
  l_adr_codes         t_array_varchar2;
  l_adr_version_from  t_array_int;
  l_adr_version_to    t_array_int;
  i                  INTEGER;

  l_log_module      VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_adr_version';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_adr_version',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  i := 0;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - retrieve adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_adr in c_adr LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - adr = '||
                        l_adr.segment_rule_type_code||','||
                        l_adr.segment_rule_code||','||
                        l_adr.version_from||','||
                        l_adr.version_to,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    i := i + 1;
    l_adr_owner_codes(i)  := l_adr.segment_rule_type_code;
    l_adr_codes(i)        := l_adr.segment_rule_code;
    l_adr_version_from(i) := l_adr.version_from;
    l_adr_version_to(i)   := l_adr.version_to;
  END LOOP;

  FORALL i IN 1 .. l_adr_codes.COUNT
    INSERT INTO xla_amb_components_h
    (application_id
    ,component_type_code
    ,component_owner_code
    ,component_code
    ,version_num
    ,base_version_num
    ,leapfrog_flag
    ,object_version_number
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,program_update_date
    ,program_application_id
    ,program_id
    ,request_id)
    VALUES
    (p_application_id
    ,'AMB_ADR'
    ,l_adr_owner_codes(i)
    ,l_adr_codes(i)
    ,l_adr_version_to(i)
    ,l_adr_version_from(i)
    ,DECODE(p_versioning_mode,'LEAPFROG','Y','N')
    ,1
    ,sysdate
    ,xla_environment_pkg.g_usr_id
    ,sysdate
    ,xla_environment_pkg.g_usr_id
    ,xla_environment_pkg.g_login_id
    ,sysdate
    ,xla_environment_pkg.g_prog_appl_id
    ,xla_environment_pkg.g_prog_id
    ,xla_environment_pkg.g_req_Id);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row inserted in xla_amb_components_h = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1 .. l_adr_codes.COUNT
    UPDATE xla_seg_rules_b
       SET version_num       = l_adr_version_to(i)
          ,updated_flag      = 'N'
          ,creation_date     = sysdate
          ,created_by        = xla_environment_pkg.g_usr_id
          ,last_update_date  = sysdate
          ,last_updated_by   = xla_environment_pkg.g_usr_id
          ,last_update_login = xla_environment_pkg.g_login_id
     WHERE segment_rule_type_code = l_adr_owner_codes(i)
       AND segment_rule_code      = l_adr_codes(i)
       AND application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row updated in xla_seg_rules_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - retrieve adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure update_adr_version',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.update_adr_version'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END update_adr_version;

--=============================================================================
--
-- Name: update_ms_version
-- Description: This API updates the version of the mapping sets
--
--=============================================================================
PROCEDURE update_ms_version
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2
,p_versioning_mode  IN VARCHAR2)
IS
  CURSOR c_ms IS
    SELECT b.mapping_set_code
          ,b.version_num                version_from
          ,MAX(NVL(h.version_num,0))+1  version_to
      FROM xla_mapping_sets_b       b
          ,xla_amb_components_h     h
     WHERE h.component_code(+)      = b.mapping_set_code
       AND h.component_type_code(+) = 'MAPPING_SET'
       AND b.updated_flag           = 'Y'
       AND b.amb_context_code       = p_amb_context_code
     GROUP BY b.mapping_set_code, b.version_num;

  l_ms_codes        t_array_varchar2;
  l_ms_version_from t_array_int;
  l_ms_version_to   t_array_int;
  i                 INTEGER;

  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_ms_version';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_ms_version',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  i := 0;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - retrieve mapping set',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_ms in c_ms LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - mapping set = '||
                        l_ms.mapping_set_code||','||
                        l_ms.version_from||','||
                        l_ms.version_to,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    i := i + 1;
    l_ms_codes(i)        := l_ms.mapping_set_code;
    l_ms_version_from(i) := l_ms.version_from;
    l_ms_version_to(i)   := l_ms.version_to;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - retrieve mapping set',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FORALL i IN 1 .. l_ms_codes.COUNT
    INSERT INTO xla_amb_components_h
    (component_type_code
    ,component_owner_code
    ,component_code
    ,application_id
    ,version_num
    ,base_version_num
    ,leapfrog_flag
    ,object_version_number
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,program_update_date
    ,program_application_id
    ,program_id
    ,request_id)
    VALUES
    ('MAPPING_SET'
    ,'X'
    ,l_ms_codes(i)
    ,-1
    ,l_ms_version_to(i)
    ,l_ms_version_from(i)
    ,DECODE(p_versioning_mode,'LEAPFROG','Y','N')
    ,1
    ,sysdate
    ,xla_environment_pkg.g_usr_id
    ,sysdate
    ,xla_environment_pkg.g_usr_id
    ,xla_environment_pkg.g_login_id
    ,sysdate
    ,xla_environment_pkg.g_prog_appl_id
    ,xla_environment_pkg.g_prog_id
    ,xla_environment_pkg.g_req_Id);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row inserted in xla_amb_components_h = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1 .. l_ms_codes.COUNT
    UPDATE xla_mapping_sets_b
       SET version_num       = l_ms_version_to(i)
          ,updated_flag      = 'N'
          ,creation_date     = sysdate
          ,created_by        = xla_environment_pkg.g_usr_id
          ,last_update_date  = sysdate
          ,last_updated_by   = xla_environment_pkg.g_usr_id
          ,last_update_login = xla_environment_pkg.g_login_id
     WHERE mapping_set_code = l_ms_codes(i)
       AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row updated in xla_mapping_sets_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure update_ms_version',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.update_ms_version'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END update_ms_version;

--=============================================================================
--
-- Name: record_log
-- Description: This API records the log information to the log table
--
--=============================================================================
PROCEDURE record_log
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2)
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_log';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure record_log',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  INSERT INTO xla_aad_loader_logs
  (aad_loader_log_id
  ,amb_context_code
  ,application_id
  ,request_code
  ,log_type_code
  ,aad_application_id
  ,product_rule_code
  ,product_rule_type_code
  ,version_to
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,program_update_date
  ,program_application_id
  ,program_id
  ,request_id)
  SELECT xla_aad_loader_logs_s.nextval
        ,p_amb_context_code
        ,p_application_id
        ,'EXPORT'
        ,'EXPORTED_AAD'
        ,application_id
        ,product_rule_code
        ,product_rule_type_code
        ,version_num
        ,1
        ,sysdate
        ,xla_environment_pkg.g_usr_id
        ,sysdate
        ,xla_environment_pkg.g_usr_id
        ,xla_environment_pkg.g_login_id
        ,sysdate
        ,xla_environment_pkg.g_prog_appl_id
        ,xla_environment_pkg.g_prog_id
        ,xla_environment_pkg.g_req_Id
   FROM xla_product_rules_b
  WHERE application_id         = p_application_id
    AND amb_context_code       = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row inserted in xla_aad_loader_logs = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure record_log',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.record_log'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END record_log;


--=============================================================================
--
-- Name: pre_export
-- Description: This API prepares the environment for export
--
--=============================================================================
FUNCTION pre_export
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2
,p_versioning_mode  IN VARCHAR2
,p_user_version     IN VARCHAR2
,p_version_comment  IN VARCHAR2
,p_owner_type       IN VARCHAR2)
RETURN VARCHAR2
IS
  l_recinfo       xla_appli_amb_contexts%ROWTYPE;
  l_retcode       VARCHAR2(30);
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.pre_export';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function pre_export',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := 'SUCCESS';

  -- Lock the staging area of the AMB context
  l_retcode := lock_context
                   (p_application_id   => p_application_id
                   ,p_amb_context_code => p_amb_context_code);
  IF (l_retcode = 'WARNING') THEN
    RAISE G_EXC_WARNING;
  ELSIF (l_retcode = 'ERROR') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_retcode := validation
           (p_application_id   => p_application_id
           ,p_amb_context_code => p_amb_context_code
           ,p_owner_type       => p_owner_type
           ,p_versioning_mode  => p_versioning_mode);

  IF (l_retcode = 'WARNING') THEN
    RAISE G_EXC_WARNING;
  ELSIF (l_retcode = 'ERROR') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  update_aad_version
           (p_application_id   => p_application_id
           ,p_amb_context_code => p_amb_context_code
           ,p_owner_type       => p_owner_type
           ,p_versioning_mode  => p_versioning_mode
           ,p_user_version     => p_user_version
           ,p_version_comment  => p_version_comment);

  update_ac_version
           (p_application_id   => p_application_id
           ,p_amb_context_code => p_amb_context_code
           ,p_versioning_mode  => p_versioning_mode);

  update_adr_version
           (p_application_id   => p_application_id
           ,p_amb_context_code => p_amb_context_code
           ,p_versioning_mode  => p_versioning_mode);

  IF (p_owner_type = 'C') THEN
    update_ms_version
           (p_application_id   => p_application_id
           ,p_amb_context_code => p_amb_context_code
           ,p_versioning_mode  => p_versioning_mode);
  END IF;

  record_log
           (p_application_id   => p_application_id
           ,p_amb_context_code => p_amb_context_code);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function pre_export - Return value = '||l_retcode,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION
WHEN G_EXC_WARNING THEN
  RETURN 'WARNING';

WHEN FND_API.G_EXC_ERROR THEN
  RETURN 'ERROR';

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  RETURN 'ERROR';

WHEN OTHERS THEN
  ROLLBACK;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.pre_export'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;
END pre_export;


--=============================================================================
--
--
--
--
--
--          *********** public procedures and functions **********
--
--
--
--
--
--=============================================================================


--=============================================================================
--
-- Name: export
-- Description: This API exports the AADs and the components from the AMB
--              context to the data file
--
--=============================================================================
PROCEDURE export
(p_api_version          IN NUMBER
,x_return_status        IN OUT NOCOPY VARCHAR2
,p_application_id       IN VARCHAR2
,p_amb_context_code     IN VARCHAR2
,p_destination_pathname IN VARCHAR2
,p_versioning_mode      IN VARCHAR2
,p_user_version         IN VARCHAR2
,p_version_comment      IN VARCHAR2
,x_export_status        IN OUT NOCOPY VARCHAR2)
IS
  CURSOR c_app_short_name IS
    SELECT application_short_name
      FROM fnd_application
     WHERE application_id = p_application_id;

  l_api_name          CONSTANT VARCHAR2(30) := 'export';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_destination_file  VARCHAR2(300);
  l_app_short_name    VARCHAR2(30);
  l_owner_type        VARCHAR2(1);
  l_log_module        VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.export';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function export',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (NOT xla_aad_loader_util_pvt.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => C_DEFAULT_MODULE))
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --  Initialize global variables
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API Logic
  IF (NVL(fnd_profile.value('XLA_SETUP_USER_MODE'),'C') = 'C') THEN
    l_owner_type := 'C';
  ELSE
    l_owner_type := 'S';
  END IF;

  x_export_status := pre_export
                     (p_application_id   => p_application_id
                     ,p_amb_context_code => p_amb_context_code
                     ,p_versioning_mode  => p_versioning_mode
                     ,p_user_version     => p_user_version
                     ,p_version_comment  => p_version_comment
                     ,p_owner_type       => l_owner_type);

  IF (x_export_status = 'WARNING') THEN
    RAISE G_EXC_WARNING;
  END IF;

  xla_aad_download_pvt.download
                     (p_api_version      => 1.0
                     ,x_return_status    => x_return_status
                     ,p_application_id   => p_application_id
                     ,p_amb_context_code => p_amb_context_code
                     ,p_destination_file => p_destination_pathname
                     ,x_download_status  => x_export_status);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function export - Return value = '||x_export_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN G_EXC_WARNING THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  x_export_status := 'WARNING';

WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  x_export_status := 'ERROR';

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_export_status := 'ERROR';

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_export_status := 'ERROR';

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_export_pvt.export'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;
END export;

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

END xla_aad_export_pvt;

/
