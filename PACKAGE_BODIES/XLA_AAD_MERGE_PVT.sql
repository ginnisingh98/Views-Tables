--------------------------------------------------------
--  DDL for Package Body XLA_AAD_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AAD_MERGE_PVT" AS
/* $Header: xlaalmer.pkb 120.20.12010000.7 2010/02/22 11:02:57 krsankar ship $ */

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------
TYPE t_array_varchar30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_array_varchar80 IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE t_array_int       IS TABLE OF INTEGER      INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- declaring global variables
------------------------------------------------------------------------------
g_amb_context_code     VARCHAR2(30);
g_staging_context_code VARCHAR2(30);
g_application_id       INTEGER;
g_user_type_code       VARCHAR2(30);
g_analyzed_flag        VARCHAR2(1);
g_compile_flag         VARCHAR2(1);
g_usr_id               INTEGER;
g_login_id             INTEGER;

C_OWNER_SYSTEM        CONSTANT VARCHAR2(1) := 'S';
C_DATE                CONSTANT DATE        := TO_DATE('1','j');
C_NUM                 CONSTANT NUMBER      := 9.99E125;
C_CHAR                CONSTANT VARCHAR2(1) := '
';

G_EXC_WARNING         EXCEPTION;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_aad_merge_pvt';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS
l_time varchar2(300);
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
WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
    (p_location   => 'xla_aad_merge_pvt.trace');

END trace;


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================

--=============================================================================
--
-- Name: pre_merge
-- Description: This API prepares the environment for merge
--
--=============================================================================
FUNCTION pre_merge
RETURN VARCHAR2
IS
  CURSOR c IS
    SELECT *
      FROM xla_appli_amb_contexts
     WHERE application_id   = g_application_id
       AND amb_context_code = g_amb_context_code
    FOR UPDATE OF application_id NOWAIT;

  l_lock_error    BOOLEAN;
  l_recinfo       xla_appli_amb_contexts%ROWTYPE;
  l_retcode       VARCHAR2(30);
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.pre_merge';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function pre_merge',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := 'SUCCESS';

  -- Begin API Logic

  -- Lock the staging area of the AMB context
  l_lock_error := TRUE;
  OPEN c;
  CLOSE c;
  l_lock_error := FALSE;

  IF (l_retcode = 'SUCCESS') THEN
    l_retcode := xla_aad_loader_util_pvt.lock_area
                   (p_application_id   => g_application_id
                   ,p_amb_context_code => g_amb_context_code);

    IF (l_retcode <> 'SUCCESS') THEN
      xla_aad_loader_util_pvt.stack_error
        (p_appli_s_name  => 'XLA'
        ,p_msg_name      => 'XLA_AAD_MGR_LOCK_FAILED');
      l_retcode := 'WARNING';
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function pre_merge - Return value = '||l_retcode,
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

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'END of function pre_merge - Return value = '||l_retcode,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    xla_aad_loader_util_pvt.stack_error
          (p_appli_s_name  => 'XLA'
          ,p_msg_name      => 'XLA_AAD_MGR_LOCK_FAILED');

    RETURN l_retcode;
  ELSE
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.pre_merge'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
    RAISE;
  END IF;

END pre_merge;


--=============================================================================
--
-- Name: validation
-- Description: This API validate the AADs and components
-- Return codes:
--   SUCCESS - completed sucessfully
--   ERROR   - completed with error
--
--=============================================================================
FUNCTION validation
RETURN VARCHAR2
IS

  CURSOR c_updated IS
    SELECT 1
      FROM xla_appli_amb_contexts
     WHERE amb_context_code = g_amb_context_code
       AND application_id   = g_application_id
       AND updated_flag     = 'N';

  -- Return if any AAD has a higher version in the working area then the
  -- original version of the one in the staging area
  CURSOR c_invalid_versions IS
    SELECT distinct t.name
      FROM xla_product_rules_b           w
         , xla_product_rules_b           s
         , xla_staging_components_h      h
         , xla_product_rules_tl          t
     WHERE w.version_num              > h.version_num
       AND w.amb_context_code         = g_amb_context_code
       AND w.application_id           = g_application_id
       AND w.product_rule_type_code   = s.product_rule_type_code
       AND w.product_rule_code        = s.product_rule_code
       --
       AND t.application_id           = w.application_id
       AND t.amb_context_code         = w.amb_context_code
       AND t.product_rule_type_code   = w.product_rule_type_code
       AND t.product_rule_code        = w.product_rule_code
       AND t.language                 = USERENV('LANG')
       --
       AND h.staging_amb_context_code = g_staging_context_code
       AND h.application_id           = g_application_id
       AND h.component_owner_code     = s.product_rule_type_code
       AND h.component_code           = s.product_rule_code
       AND h.component_type_code      = 'AAD'
       AND h.version_num              = s.version_num
       --
       AND s.amb_context_code        = g_staging_context_code
       AND s.application_id          = g_application_id;

  l_exists        INTEGER;
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

  l_retcode := 'SUCCESS';

  l_retcode := xla_aad_loader_util_pvt.validate_adr_compatibility
      (p_application_id               => g_application_id
      ,p_amb_context_code             => g_amb_context_code
      ,p_staging_context_code         => g_staging_context_code);

  IF (g_analyzed_flag = 'Y') THEN

    -- If merge analysis was run and the AAD/setups are modified since merge
    -- analysis, return FALSE
    OPEN c_updated;
    FETCH c_updated INTO l_exists;
    IF (c_updated%NOTFOUND) THEN
      l_retcode := 'WARNING';
      xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_MER_AMB_UPDATED');
    END IF;
    CLOSE c_updated;
  ELSE

    -- If merge analysis is not run, make sure no AAD has a higher version in
    -- working area than the original version of the one in the staging area
    FOR l_err in c_invalid_versions LOOP
      l_retcode := 'WARNING';
      xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_MER_INVALID_AAD_VERS'
               ,p_token_1         => 'PROD_RULE_NAME'
               ,p_value_1         => l_err.name);
    END LOOP;
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
               ,p_value_1         => 'xla_aad_merge_pvt.validation'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'Unhandled exception');
  RAISE;

END validation;

--=============================================================================
--
-- Name: clean_oracle_aads
-- Description:
--
--=============================================================================
PROCEDURE clean_oracle_aads
IS
  CURSOR c_all_comps IS
    SELECT w.product_rule_code, w.version_num
      FROM xla_product_rules_b w
     WHERE w.application_id         = g_application_id
       AND w.amb_context_code       = g_amb_context_code
       AND w.product_rule_type_code = C_OWNER_SYSTEM
       AND NOT EXISTS ( SELECT 1
                          FROM xla_product_rules_b s
                         WHERE s.application_id         = g_application_id
                           AND s.amb_context_code       = g_staging_context_code
                           AND s.product_rule_type_code = C_OWNER_SYSTEM
                           AND s.product_rule_code      = w.product_rule_code);

  l_codes              t_array_varchar30;
  l_version_nums       t_array_int;

  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.clean_oracle_aads';
  END IF;

  IF (g_analyzed_flag = 'Y') THEN
    null;
  ELSE
    OPEN c_all_comps;
    FETCH c_all_comps BULK COLLECT INTO l_codes, l_version_nums;
    CLOSE c_all_comps;

  END IF;

  -- Insert log
  FORALL i IN 1..l_codes.COUNT
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
    VALUES
          (xla_aad_loader_logs_s.nextval
          ,g_amb_context_code
          ,g_application_id
          ,'IMPORT'
          ,'DELETED_AAD'
          ,g_application_id
          ,l_codes(i)
          ,C_OWNER_SYSTEM
          ,l_version_nums(i)
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

  -- Delete JLD aasignment that is no longer assigned to the header
  DELETE FROM xla_aad_line_defn_assgns w
   WHERE application_id         = g_application_id
     AND amb_context_code       = g_amb_context_code
     AND product_rule_type_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_aad_line_defn_assgns s
           WHERE s.application_id             = g_application_id
             AND s.amb_context_code           = g_staging_context_code
             AND s.product_rule_type_code     = C_OWNER_SYSTEM
             AND s.product_rule_code          = w.product_rule_code
             AND s.event_class_code           = w.event_class_code
             AND s.event_type_code            = w.event_type_code
             AND s.line_definition_owner_code = w.line_definition_owner_code
             AND s.line_definition_code       = w.line_definition_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_aad_line_defn_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Delete AC assignment that is no longer assigned to the header
  DELETE FROM xla_aad_header_ac_assgns w
   WHERE application_id         = g_application_id
     AND amb_context_code       = g_amb_context_code
     AND product_rule_type_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_aad_header_ac_assgns s
           WHERE s.application_id                 = g_application_id
             AND s.amb_context_code               = g_staging_context_code
             AND s.product_rule_type_code         = C_OWNER_SYSTEM
             AND s.product_rule_code              = w.product_rule_code
             AND s.event_class_code               = w.event_class_code
             AND s.event_type_code                = w.event_type_code
             AND s.analytical_criterion_type_code = w.analytical_criterion_type_code
             AND s.analytical_criterion_code      = w.analytical_criterion_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_aad_header_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_aad_hdr_acct_attrs w
   WHERE application_id         = g_application_id
     AND amb_context_code       = g_amb_context_code
     AND product_rule_type_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_aad_hdr_acct_attrs s
           WHERE s.application_id            = g_application_id
             AND s.amb_context_code          = g_staging_context_code
             AND s.product_rule_type_code    = C_OWNER_SYSTEM
             AND s.product_rule_code         = w.product_rule_code
             AND s.event_class_code          = w.event_class_code
             AND s.event_type_code           = w.event_type_code
             AND s.accounting_attribute_code = w.accounting_attribute_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_aad_hdr_acct_attrs deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_prod_acct_headers w
   WHERE application_id         = g_application_id
     AND amb_context_code       = g_amb_context_code
     AND product_rule_type_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_prod_acct_headers s
           WHERE s.application_id         = g_application_id
             AND s.amb_context_code       = g_staging_context_code
             AND s.product_rule_type_code = C_OWNER_SYSTEM
             AND s.product_rule_code      = w.product_rule_code
             AND s.event_class_code       = w.event_class_code
             AND s.event_type_code        = w.event_type_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_prod_acct_headers deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Delete AAD that is not in the staging area
  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_product_rules_tl w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND product_rule_type_code = C_OWNER_SYSTEM
       AND product_rule_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_product_rules_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_product_rules_b w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND product_rule_type_code = C_OWNER_SYSTEM
       AND product_rule_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_product_rules_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure clean_oracle_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure clean_oracle_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.clean_oracle_aads'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END clean_oracle_aads;


--=============================================================================
--
-- Name: clean_oracle_jlds
-- Description:
--
--=============================================================================
PROCEDURE clean_oracle_jlds
IS
  CURSOR c_all_comps IS
    SELECT w.event_class_code
         , w.event_type_code
         , w.line_definition_code
      FROM xla_line_definitions_b w
     WHERE w.application_id             = g_application_id
       AND w.amb_context_code           = g_amb_context_code
       AND w.line_definition_owner_code = C_OWNER_SYSTEM
       AND NOT EXISTS ( SELECT 1
                          FROM xla_line_definitions_b s
                         WHERE s.application_id             = g_application_id
                           AND s.amb_context_code           = g_staging_context_code
                           AND s.event_class_code           = w.event_class_code
                           AND s.event_type_code            = w.event_type_code
                           AND s.line_definition_owner_code = C_OWNER_SYSTEM
                           AND s.line_definition_code       = w.line_definition_code);

  l_event_class_codes  t_array_varchar30;
  l_event_type_codes   t_array_varchar30;
  l_codes              t_array_varchar30;

  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.clean_oracle_jlds';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure clean_oracle_jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_analyzed_flag = 'Y') THEN
    null;
  ELSE
    OPEN c_all_comps;
    FETCH c_all_comps BULK COLLECT INTO l_event_class_codes
                                      , l_event_type_codes
                                      , l_codes;
    CLOSE c_all_comps;

  END IF;

  -- Delete JLD assignment for those JLD no longer exist
  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_aad_line_defn_assgns w
     WHERE application_id             = g_application_id
       AND amb_context_code           = g_amb_context_code
       AND event_class_code           = l_event_class_codes(i)
       AND event_type_code            = l_event_type_codes(i)
       AND line_definition_owner_code = C_OWNER_SYSTEM
       AND line_definition_code       = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_aad_line_defn_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_line_defn_ac_assgns w
   WHERE application_id             = g_application_id
     AND amb_context_code           = g_amb_context_code
     AND line_definition_owner_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_line_defn_ac_assgns s
           WHERE s.application_id                 = g_application_id
             AND s.amb_context_code               = g_staging_context_code
             AND s.event_class_code               = w.event_class_code
             AND s.event_type_code                = w.event_type_code
             AND s.line_definition_owner_code     = C_OWNER_SYSTEM
             AND s.line_definition_code           = w.line_definition_code
             AND s.accounting_line_type_code      = w.accounting_line_type_code
             AND s.accounting_line_code           = w.accounting_line_code
             AND s.analytical_criterion_type_code = w.analytical_criterion_type_code
             AND s.analytical_criterion_code      = w.analytical_criterion_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_line_defn_adr_assgns w
   WHERE application_id             = g_application_id
     AND amb_context_code           = g_amb_context_code
     AND line_definition_owner_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_line_defn_adr_assgns s
           WHERE s.application_id             = g_application_id
             AND s.amb_context_code           = g_staging_context_code
             AND s.event_class_code           = w.event_class_code
             AND s.event_type_code            = w.event_type_code
             AND s.line_definition_owner_code = C_OWNER_SYSTEM
             AND s.line_definition_code       = w.line_definition_code
             AND s.accounting_line_type_code  = w.accounting_line_type_code
             AND s.accounting_line_code       = w.accounting_line_code
             AND s.flexfield_segment_code     = w.flexfield_segment_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_adr_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_line_defn_jlt_assgns w
   WHERE application_id             = g_application_id
     AND amb_context_code           = g_amb_context_code
     AND line_definition_owner_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_line_defn_jlt_assgns s
           WHERE s.application_id             = g_application_id
             AND s.amb_context_code           = g_staging_context_code
             AND s.event_class_code           = w.event_class_code
             AND s.event_type_code            = w.event_type_code
             AND s.line_definition_owner_code = C_OWNER_SYSTEM
             AND s.line_definition_code       = w.line_definition_code
             AND s.accounting_line_type_code  = w.accounting_line_type_code
             AND s.accounting_line_code       = w.accounting_line_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_jlt_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_mpa_jlt_assgns w
   WHERE application_id             = g_application_id
     AND amb_context_code           = g_amb_context_code
     AND line_definition_owner_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_mpa_jlt_assgns s
           WHERE s.application_id                 = g_application_id
             AND s.amb_context_code               = g_staging_context_code
             AND s.event_class_code               = w.event_class_code
             AND s.event_type_code                = w.event_type_code
             AND s.line_definition_owner_code     = C_OWNER_SYSTEM
             AND s.line_definition_code           = w.line_definition_code
             AND s.accounting_line_type_code      = w.accounting_line_type_code
             AND s.accounting_line_code           = w.accounting_line_code
             AND s.mpa_accounting_line_type_code  = w.mpa_accounting_line_type_code
             AND s.mpa_accounting_line_code       = w.mpa_accounting_line_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_mpa_header_ac_assgns w
   WHERE application_id             = g_application_id
     AND amb_context_code           = g_amb_context_code
     AND line_definition_owner_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_mpa_header_ac_assgns s
           WHERE s.application_id                 = g_application_id
             AND s.amb_context_code               = g_staging_context_code
             AND s.event_class_code               = w.event_class_code
             AND s.event_type_code                = w.event_type_code
             AND s.line_definition_owner_code     = C_OWNER_SYSTEM
             AND s.line_definition_code           = w.line_definition_code
             AND s.accounting_line_type_code      = w.accounting_line_type_code
             AND s.accounting_line_code           = w.accounting_line_code
             AND s.analytical_criterion_type_code = w.analytical_criterion_type_code
             AND s.analytical_criterion_code      = w.analytical_criterion_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_header_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_mpa_jlt_adr_assgns w
   WHERE application_id             = g_application_id
     AND amb_context_code           = g_amb_context_code
     AND line_definition_owner_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_mpa_jlt_adr_assgns s
           WHERE s.application_id                 = g_application_id
             AND s.amb_context_code               = g_staging_context_code
             AND s.event_class_code               = w.event_class_code
             AND s.event_type_code                = w.event_type_code
             AND s.line_definition_owner_code     = C_OWNER_SYSTEM
             AND s.line_definition_code           = w.line_definition_code
             AND s.accounting_line_type_code      = w.accounting_line_type_code
             AND s.accounting_line_code           = w.accounting_line_code
             AND s.mpa_accounting_line_type_code  = w.mpa_accounting_line_type_code
             AND s.mpa_accounting_line_code       = w.mpa_accounting_line_code
             AND s.flexfield_segment_code         = w.flexfield_segment_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_adr_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_mpa_jlt_ac_assgns w
   WHERE application_id             = g_application_id
     AND amb_context_code           = g_amb_context_code
     AND line_definition_owner_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_mpa_jlt_ac_assgns s
           WHERE s.application_id                 = g_application_id
             AND s.amb_context_code               = g_staging_context_code
             AND s.event_class_code               = w.event_class_code
             AND s.event_type_code                = w.event_type_code
             AND s.line_definition_owner_code     = C_OWNER_SYSTEM
             AND s.line_definition_code           = w.line_definition_code
             AND s.accounting_line_type_code      = w.accounting_line_type_code
             AND s.accounting_line_code           = w.accounting_line_code
             AND s.mpa_accounting_line_type_code  = w.mpa_accounting_line_type_code
             AND s.mpa_accounting_line_code       = w.mpa_accounting_line_code
             AND s.analytical_criterion_type_code = w.analytical_criterion_type_code
             AND s.analytical_criterion_code      = w.analytical_criterion_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_line_definitions_tl w
     WHERE application_id             = g_application_id
       AND amb_context_code           = g_amb_context_code
       AND event_class_code           = l_event_class_codes(i)
       AND event_type_code            = l_event_type_codes(i)
       AND line_definition_owner_code = C_OWNER_SYSTEM
       AND line_definition_code       = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_definitions_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_line_definitions_b w
     WHERE application_id             = g_application_id
       AND amb_context_code           = g_amb_context_code
       AND event_class_code           = l_event_class_codes(i)
       AND event_type_code            = l_event_type_codes(i)
       AND line_definition_owner_code = C_OWNER_SYSTEM
       AND line_definition_code       = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_definitions_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure clean_oracle_jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.clean_oracle_jlds'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END clean_oracle_jlds;


--=============================================================================
--
-- Name: clean_oracle_jlts
-- Description:
--
--=============================================================================
PROCEDURE clean_oracle_jlts
IS
  CURSOR c_all_comps IS
    SELECT work.event_class_code
         , work.accounting_line_code
      FROM xla_acct_line_types_b work
     WHERE work.application_id            = g_application_id
       AND work.amb_context_code          = g_amb_context_code
       AND work.accounting_line_type_code = C_OWNER_SYSTEM
       AND NOT EXISTS ( SELECT 1
                          FROM xla_acct_line_types_b stage
                         WHERE stage.application_id            = g_application_id
                           AND stage.amb_context_code          = g_staging_context_code
                           AND stage.event_class_code          = work.event_class_code
                           AND stage.accounting_line_type_code = C_OWNER_SYSTEM
                           AND stage.accounting_line_code      = work.accounting_line_code);

  l_event_class_codes  t_array_varchar30;
  l_codes              t_array_varchar30;

  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.clean_oracle_jlts';
  END IF;

  IF (g_analyzed_flag = 'Y') THEN
    null;
  ELSE
    OPEN c_all_comps;
    FETCH c_all_comps BULK COLLECT INTO l_event_class_codes
                                      , l_codes;
    CLOSE c_all_comps;

  END IF;

  IF (l_codes.COUNT > 0) THEN

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_mpa_jlt_adr_assgns w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND event_class_code          = l_event_class_codes(i)
       AND accounting_line_type_code = C_OWNER_SYSTEM
       AND accounting_line_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_adr_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_mpa_jlt_ac_assgns w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND event_class_code          = l_event_class_codes(i)
       AND accounting_line_type_code = C_OWNER_SYSTEM
       AND accounting_line_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_mpa_header_ac_assgns w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND event_class_code          = l_event_class_codes(i)
       AND accounting_line_type_code = C_OWNER_SYSTEM
       AND accounting_line_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_header_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_mpa_jlt_assgns w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND event_class_code          = l_event_class_codes(i)
       AND accounting_line_type_code = C_OWNER_SYSTEM
       AND accounting_line_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_line_defn_adr_assgns w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND event_class_code          = l_event_class_codes(i)
       AND accounting_line_type_code = C_OWNER_SYSTEM
       AND accounting_line_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_adr_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_line_defn_ac_assgns w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND event_class_code          = l_event_class_codes(i)
       AND accounting_line_type_code = C_OWNER_SYSTEM
       AND accounting_line_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_line_defn_jlt_assgns w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND event_class_code          = l_event_class_codes(i)
       AND accounting_line_type_code = C_OWNER_SYSTEM
       AND accounting_line_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_jlt_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_jlt_acct_attrs w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND event_class_code          = l_event_class_codes(i)
       AND accounting_line_type_code = C_OWNER_SYSTEM
       AND accounting_line_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_jlt_acct_attrs deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_acct_line_types_b w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND event_class_code          = l_event_class_codes(i)
       AND accounting_line_type_code = C_OWNER_SYSTEM
       AND accounting_line_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_acct_line_types_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_acct_line_types_tl w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND event_class_code          = l_event_class_codes(i)
       AND accounting_line_type_code = C_OWNER_SYSTEM
       AND accounting_line_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_acct_line_types_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure clean_oracle_jlts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure clean_oracle_jlts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.clean_oracle_jlts'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END clean_oracle_jlts;


--=============================================================================
--
-- Name: clean_oracle_descriptions
-- Description:
--
--=============================================================================
PROCEDURE clean_oracle_descriptions
IS
  CURSOR c_all_comps IS
    SELECT work.description_code
      FROM xla_descriptions_b work
     WHERE work.application_id         = g_application_id
       AND work.amb_context_code       = g_amb_context_code
       AND work.description_type_code  = C_OWNER_SYSTEM
       AND NOT EXISTS ( SELECT 1
                          FROM xla_descriptions_b stage
                         WHERE stage.application_id        = g_application_id
                           AND stage.amb_context_code      = g_staging_context_code
                           AND stage.description_type_code = C_OWNER_SYSTEM
                           AND stage.description_code      = work.description_code);

  l_codes              t_array_varchar30;

  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.clean_oracle_descriptions';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure clean_oracle_descriptions',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_analyzed_flag = 'Y') THEN
    null;
  ELSE
    OPEN c_all_comps;
    FETCH c_all_comps BULK COLLECT INTO l_codes;
    CLOSE c_all_comps;

  END IF;

  IF (l_codes.COUNT > 0) THEN
  FORALL i IN 1..l_codes.COUNT
    UPDATE xla_line_defn_jlt_assgns
       SET description_type_code = NULL
         , description_code      = NULL
     WHERE application_id        = g_application_id
       AND amb_context_code      = g_amb_context_code
       AND description_type_code = C_OWNER_SYSTEM
       AND description_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_jlt_assgns clear description = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    UPDATE xla_prod_acct_headers
       SET description_type_code = NULL
         , description_code      = NULL
     WHERE application_id        = g_application_id
       AND amb_context_code      = g_amb_context_code
       AND description_type_code = C_OWNER_SYSTEM
       AND description_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_prod_acct_headers clear description = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_descript_details_tl w
     WHERE description_detail_id IN
           (SELECT description_detail_id
              FROM xla_descript_details_b d
                 , xla_desc_priorities p
             WHERE d.description_prio_id   = p.description_prio_id
               AND p.application_id        = g_application_id
               AND p.amb_context_code      = g_amb_context_code
               AND p.description_type_code = C_OWNER_SYSTEM
               AND p.description_code      = l_codes(i));

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_descript_details_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_descript_details_b w
     WHERE description_prio_id IN
           (SELECT description_prio_id
              FROM xla_desc_priorities p
             WHERE p.application_id        = g_application_id
               AND p.amb_context_code      = g_amb_context_code
               AND p.description_type_code = C_OWNER_SYSTEM
               AND p.description_code      = l_codes(i));

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_descript_details_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_desc_priorities w
     WHERE application_id        = g_application_id
       AND amb_context_code      = g_amb_context_code
       AND description_type_code = C_OWNER_SYSTEM
       AND description_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_desc_priorities deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_descriptions_tl w
     WHERE application_id        = g_application_id
       AND amb_context_code      = g_amb_context_code
       AND description_type_code = C_OWNER_SYSTEM
       AND description_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_descriptions_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_descriptions_b w
     WHERE application_id        = g_application_id
       AND amb_context_code      = g_amb_context_code
       AND description_type_code = C_OWNER_SYSTEM
       AND description_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_descriptions_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure clean_oracle_descriptions',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.clean_oracle_descriptions'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END clean_oracle_descriptions;


--=============================================================================
--
-- Name: clean_oracle_adrs
-- Description:
--
--=============================================================================
PROCEDURE clean_oracle_adrs
IS
  -- Retrieve the Oracle adr to be deleted
  CURSOR c_all_comps IS
    SELECT work.segment_rule_code
      FROM xla_seg_rules_b work
     WHERE work.application_id         = g_application_id
       AND work.amb_context_code       = g_amb_context_code
       AND work.segment_rule_type_code = C_OWNER_SYSTEM
       AND NOT EXISTS
           (SELECT 1
              FROM xla_seg_rules_b stage
             WHERE stage.application_id         = g_application_id
               AND stage.amb_context_code       = g_staging_context_code
               AND stage.segment_rule_type_code = C_OWNER_SYSTEM
               AND stage.segment_rule_code      = work.segment_rule_code);

  l_codes         t_array_varchar30;
  i               INTEGER;

  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.clean_oracle_adrs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure clean_oracle_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_analyzed_flag = 'Y') THEN
    null;
  ELSE
    OPEN c_all_comps;
    FETCH c_all_comps BULK COLLECT INTO l_codes;
    CLOSE c_all_comps;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# ADRs to be deleted = '||l_codes.COUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Record if the deleted AAD is used by any other application
  IF (l_codes.COUNT > 0) THEN

  FORALL i IN 1..l_codes.COUNT
  INSERT INTO xla_aad_loader_logs
  (aad_loader_log_id
  ,amb_context_code
  ,application_id
  ,request_code
  ,log_type_code
  ,aad_application_id
  ,component_type_code
  ,component_owner_code
  ,component_code
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
        ,g_amb_context_code
        ,g_application_id
        ,'IMPORT'
        ,'DELETED_SETUP'
        ,application_id
        ,'AMB_ADR'
        ,C_OWNER_SYSTEM
        ,l_codes(i)
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
   FROM (SELECT application_id
           FROM xla_seg_rule_details s
          WHERE application_id              <> g_application_id
            AND amb_context_code             = g_amb_context_code
            AND value_segment_rule_appl_id   = g_application_id
            AND value_segment_rule_type_code = C_OWNER_SYSTEM
            AND value_segment_rule_code      = l_codes(i)
          UNION
         SELECT application_id
           FROM xla_line_defn_adr_assgns
          WHERE application_id              <> g_application_id
            AND amb_context_code             = g_amb_context_code
            AND segment_rule_appl_id         = g_application_id
            AND segment_rule_type_code       = C_OWNER_SYSTEM
            AND segment_rule_code            = l_codes(i)
          UNION
         SELECT application_id
           FROM xla_mpa_jlt_adr_assgns
          WHERE application_id              <> g_application_id
            AND amb_context_code             = g_amb_context_code
            AND segment_rule_appl_id         = g_application_id
            AND segment_rule_type_code       = C_OWNER_SYSTEM
            AND segment_rule_code            = l_codes(i));

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_aad_loader_logs inserted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Delete the reference to Oracle ADR to be deleted
  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_seg_rule_details d
     WHERE amb_context_code             = g_amb_context_code
       AND value_segment_rule_appl_id   = g_application_id
       AND value_segment_rule_type_code = C_OWNER_SYSTEM
       AND value_segment_rule_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rules_details (value) deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_mpa_jlt_adr_assgns w
     WHERE amb_context_code       = g_amb_context_code
       AND segment_rule_appl_id   = g_application_id
       AND segment_rule_type_code = C_OWNER_SYSTEM
       AND segment_rule_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_adr_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_line_defn_adr_assgns w
     WHERE amb_context_code       = g_amb_context_code
       AND segment_rule_appl_id   = g_application_id
       AND segment_rule_type_code = C_OWNER_SYSTEM
       AND segment_rule_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_adr_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Delete the ADR
  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_seg_rule_details w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND segment_rule_type_code = C_OWNER_SYSTEM
       AND segment_rule_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rule_details deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_seg_rules_tl w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND segment_rule_type_code = C_OWNER_SYSTEM
       AND segment_rule_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rules_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_seg_rules_b w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND segment_rule_type_code = C_OWNER_SYSTEM
       AND segment_rule_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '#xla_seg_rules_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure clean_oracle_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.clean_oracle_adrs'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END clean_oracle_adrs;


--=============================================================================
--
-- Name: clean_oracle_acs
-- Description:
--
--=============================================================================
PROCEDURE clean_oracle_acs
IS
  /*CURSOR c_all_comps IS
    SELECT w.analytical_criterion_code
      FROM xla_analytical_hdrs_b w
     WHERE w.amb_context_code               = g_amb_context_code
       AND w.application_id                 = g_application_id
       AND w.analytical_criterion_type_code = C_OWNER_SYSTEM
       AND NOT EXISTS ( SELECT 1
                          FROM xla_analytical_hdrs_b s
                         WHERE s.amb_context_code               = g_staging_context_code
                           AND s.application_id                 = g_application_id
                           AND s.analytical_criterion_type_code = C_OWNER_SYSTEM
                           AND s.analytical_criterion_code      = w.analytical_criterion_code);

  l_codes              t_array_varchar30;*/  -- commented bug6696939

  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.clean_oracle_acs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure clean_oracle_acs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  /*IF (g_analyzed_flag = 'Y') THEN
    null;
  ELSE
    OPEN c_all_comps;
    FETCH c_all_comps BULK COLLECT INTO l_codes;
    CLOSE c_all_comps;

  END IF;

  -- Delete reference to the AC
  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_aad_header_ac_assgns w
     WHERE application_id                 = g_application_id
       AND amb_context_code               = g_amb_context_code
       AND analytical_criterion_type_code = C_OWNER_SYSTEM
       AND analytical_criterion_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_aad_header_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_line_defn_ac_assgns w
     WHERE amb_context_code               = g_amb_context_code
       AND analytical_criterion_type_code = C_OWNER_SYSTEM
       AND analytical_criterion_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_mpa_header_ac_assgns w
     WHERE amb_context_code               = g_amb_context_code
       AND analytical_criterion_type_code = C_OWNER_SYSTEM
       AND analytical_criterion_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_header_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_mpa_jlt_ac_assgns w
     WHERE amb_context_code               = g_amb_context_code
       AND analytical_criterion_type_code = C_OWNER_SYSTEM
       AND analytical_criterion_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;*/ -- commented bug6696939

  -- Delete the AC
  DELETE FROM xla_analytical_sources w
   WHERE amb_context_code               = g_amb_context_code
     AND analytical_criterion_type_code = C_OWNER_SYSTEM
     AND application_id = g_application_id -- added bug6696939
     AND NOT EXISTS
         (SELECT 1
            FROM xla_analytical_sources s
           WHERE s.amb_context_code               = g_staging_context_code
             AND s.application_id                 = g_application_id
             AND s.entity_code                    = w.entity_code
             AND s.event_class_code               = w.event_class_code
             AND s.source_application_id          = w.source_application_id
             AND s.source_type_code               = w.source_type_code
             AND s.source_code                    = w.source_code
             AND s.analytical_criterion_type_code = C_OWNER_SYSTEM
             AND s.analytical_criterion_code      = w.analytical_criterion_code
             AND s.analytical_detail_code         = w.analytical_detail_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_sources deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  /*DELETE FROM xla_analytical_dtls_tl w
   WHERE amb_context_code               = g_amb_context_code
     AND analytical_criterion_type_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_analytical_dtls_b s
           WHERE s.amb_context_code               = g_staging_context_code
             AND s.analytical_criterion_type_code = C_OWNER_SYSTEM
             AND s.analytical_criterion_code      = w.analytical_criterion_code
             AND s.analytical_detail_code         = w.analytical_detail_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_dtls_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_analytical_dtls_b w
   WHERE amb_context_code               = g_amb_context_code
     AND analytical_criterion_type_code = C_OWNER_SYSTEM
     AND NOT EXISTS
         (SELECT 1
            FROM xla_analytical_dtls_b s
           WHERE s.amb_context_code               = g_staging_context_code
             AND s.analytical_criterion_type_code = C_OWNER_SYSTEM
             AND s.analytical_criterion_code      = w.analytical_criterion_code
             AND s.analytical_detail_code         = w.analytical_detail_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_dtls_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_analytical_hdrs_tl w
     WHERE amb_context_code               = g_amb_context_code
       AND analytical_criterion_type_code = C_OWNER_SYSTEM
       AND analytical_criterion_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_hdrs_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_codes.COUNT
    DELETE FROM xla_analytical_hdrs_b w
     WHERE amb_context_code               = g_amb_context_code
       AND analytical_criterion_type_code = C_OWNER_SYSTEM
       AND analytical_criterion_code      = l_codes(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_hdrs_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;*/ -- commented bug6696939

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure clean_oracle_acs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.clean_oracle_acs'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END clean_oracle_acs;


--=============================================================================
--
-- Name: clean_oracle_components
-- Description:
--
--=============================================================================
PROCEDURE clean_oracle_components
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.clean_oracle_components';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure clean_oracle_components',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  clean_oracle_aads;
  clean_oracle_jlds;
  clean_oracle_jlts;
  clean_oracle_descriptions;
  clean_oracle_adrs;
  clean_oracle_acs;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure clean_oracle_components',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.clean_oracle_components'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END clean_oracle_components;

--=============================================================================
--
-- Name: merge_aads
-- Description: Merge AADs from staging to working area
--
--=============================================================================
PROCEDURE merge_aads
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.merge_aads';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure merge_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_analyzed_flag = 'Y') THEN
    null;
  ELSE
    -- record log
    INSERT INTO xla_aad_loader_logs
         (aad_loader_log_id
         ,amb_context_code
         ,application_id
         ,request_code
         ,log_type_code
         ,aad_application_id
         ,product_rule_code
         ,product_rule_type_code
         ,version_from
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
               ,g_amb_context_code
               ,g_application_id
               ,'IMPORT'
               ,'MERGED_AAD'
               ,g_application_id
               ,w.product_rule_code
               ,w.product_rule_type_code
               ,w.version_num
               ,s.version_num
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
          FROM xla_product_rules_b s
             , xla_product_rules_b w
         WHERE s.application_id         = g_application_id
           AND s.amb_context_code       = g_staging_context_code
           AND w.application_id         = g_application_id
           AND w.amb_context_code       = g_amb_context_code
           AND w.product_rule_type_code = s.product_rule_type_code
           AND w.product_rule_code      = s.product_rule_code;


   /*******************************************/
   /** Added by krsankar for AAD Perf Issue  **/
   /*******************************************/

   INSERT INTO xla_aads_gt
        ( product_rule_code,
          event_class_code,
          event_type_code,
          line_definition_code,
          table_name
        )
   select product_rule_code  ,
          event_class_code   ,
          event_type_code    ,
          line_definition_code ,
          'XLA_AAD_LINE_DEFN_ASSGNS'
   from (select   product_rule_code ,
                  event_class_code        ,
                  event_type_code         ,
                  line_definition_code    ,
                  'XLA_AAD_LINE_DEFN_ASSGNS' ,
                  amb_context_code,
                  last_update_date ,
                  nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
         from
            (select product_rule_code ,
                    event_class_code        ,
                    event_type_code         ,
                    line_definition_code    ,
                   'XLA_AAD_LINE_DEFN_ASSGNS' ,
                    amb_context_code,
                    last_update_date ,
                    lag(last_update_date) over (PARTITION by application_id,
                                                            product_rule_code,
							    product_rule_type_code,
                                                            event_class_code,
                                                            event_type_code,
                                                            line_definition_code,
							    line_definition_owner_code
                                               order by     amb_context_code
                                               ) lag_date
             from XLA_AAD_LINE_DEFN_ASSGNS
             order by amb_context_code
            ) x
         where x.amb_context_code =g_staging_context_code
        )
  where flag = 'False';

	   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
             trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_aad_line_defn_assgns is :'||SQL%ROWCOUNT,
                   p_module => l_log_module,
                   p_level  => C_LEVEL_PROCEDURE);
           END IF;


    INSERT INTO xla_aads_gt
        ( product_rule_code,
          event_class_code,
          accounting_attribute_code,
          source_code,
          table_name
     )
    select product_rule_code  ,
           event_class_code   ,
           accounting_attribute_code,
           source_code,
          'XLA_AAD_HDR_ACCT_ATTRS'
    from
    (select product_rule_code
          ,event_class_code
          ,accounting_attribute_code
          ,source_code
	      ,'XLA_AAD_HDR_ACCT_ATTRS'
          ,amb_context_code
          ,last_update_date
          ,nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
     from
           (select product_rule_code
                  ,event_class_code
                  ,accounting_attribute_code
                  ,source_code
	              ,'XLA_AAD_HDR_ACCT_ATTRS'
                  ,amb_context_code
                  ,last_update_date
                  ,lag(last_update_date) over (PARTITION by application_id
                                                           ,product_rule_code
							   ,product_rule_type_code
                                                           ,event_class_code
                                                           ,accounting_attribute_code
                                                           ,event_type_code
                                               order by    amb_context_code
                                               ) lag_date
            from XLA_AAD_HDR_ACCT_ATTRS
            order by amb_context_code
            ) x
     where x.amb_context_code =g_staging_context_code
    )
    where flag = 'False';


   	   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
             trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_aad_hdr_acct_attrs is :'||SQL%ROWCOUNT,
                   p_module => l_log_module,
                   p_level  => C_LEVEL_PROCEDURE);
           END IF;


    INSERT INTO xla_aads_gt
        (  product_rule_code,
           event_class_code,
           event_type_code,
           analytical_criterion_code,
           table_name
        )
    select product_rule_code,
           event_class_code,
           event_type_code,
           analytical_criterion_code,
	       'XLA_AAD_HEADER_AC_ASSGNS'
    from (select product_rule_code,
                 event_class_code,
                 event_type_code,
                 analytical_criterion_code,
	             'XLA_AAD_HEADER_AC_ASSGNS',
                 amb_context_code,
                 last_update_date ,
                 nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
          from
             (select product_rule_code,
                     event_class_code,
                     event_type_code,
                     analytical_criterion_code,
	                 'XLA_AAD_HEADER_AC_ASSGNS',
                     amb_context_code,
                     last_update_date ,
                     lag(last_update_date) over (PARTITION by application_id,
                                                              product_rule_code,
							      product_rule_type_code,
                                                              event_class_code,
                                                              event_type_code,
                                                              analytical_criterion_code,
							      analytical_criterion_type_code
                                                 order by     amb_context_code
                                                ) lag_date
              from XLA_AAD_HEADER_AC_ASSGNS
              order by amb_context_code
              ) x
          where x.amb_context_code =g_staging_context_code
         )
    where flag = 'False';


	   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
             trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_aad_header_ac_assgns is :'||SQL%ROWCOUNT,
                   p_module => l_log_module,
                   p_level  => C_LEVEL_PROCEDURE);
           END IF;



      UPDATE xla_product_rules_b pr
      SET compile_status_code=(select compile_status_code
                               from  xla_product_rules_b pr1
                               where pr1.product_rule_code      = pr.product_rule_code
                               and   pr1.product_rule_type_code = pr.product_rule_type_code
                               and   pr1.amb_context_code       = g_amb_context_code
		    	               and   pr1.application_id         = g_application_id
                               )
      WHERE amb_context_code = g_staging_context_code
      AND   application_id   = g_application_id;


       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
           trace(p_msg    => 'Number of Rows updated in PRODUCT_RULES to original status is :'||SQL%ROWCOUNT,
                 p_module => l_log_module,
                 p_level  => C_LEVEL_PROCEDURE);
       END IF;


    -- Delete the AAD from the working area if it already exists in the
    -- staging area
    DELETE FROM xla_product_rules_b w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_product_rules_b s
                    WHERE s.application_id         = g_application_id
                      AND s.amb_context_code       = g_staging_context_code
                      AND s.product_rule_type_code = w.product_rule_type_code
                      AND s.product_rule_code      = w.product_rule_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_product_rules_b deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_product_rules_tl w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_product_rules_tl s
                    WHERE s.application_id         = g_application_id
                      AND s.amb_context_code       = g_staging_context_code
                      AND s.product_rule_type_code = w.product_rule_type_code
                      AND s.product_rule_code      = w.product_rule_code
                      AND s.language               = w.language);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_product_rules_tl deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_prod_acct_headers w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_prod_acct_headers s
                    WHERE s.application_id         = g_application_id
                      AND s.amb_context_code       = g_staging_context_code
                      AND s.product_rule_type_code = w.product_rule_type_code
                      AND s.product_rule_code      = w.product_rule_code
                      AND s.event_class_code       = w.event_class_code
                      AND s.event_type_code        = w.event_type_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_prod_acct_headers deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_aad_line_defn_assgns w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_aad_line_defn_assgns s
                    WHERE s.application_id             = g_application_id
                      AND s.amb_context_code           = g_staging_context_code
                      AND s.product_rule_type_code     = w.product_rule_type_code
                      AND s.product_rule_code          = w.product_rule_code
                      AND s.event_class_code           = w.event_class_code
                      AND s.event_type_code            = w.event_type_code
                      AND s.line_definition_owner_code = w.line_definition_owner_code
                      AND s.line_definition_code       = w.line_definition_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_aad_line_defn_assgns deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_aad_hdr_acct_attrs w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_aad_hdr_acct_attrs s
                    WHERE s.application_id            = g_application_id
                      AND s.amb_context_code          = g_staging_context_code
                      AND s.product_rule_type_code    = w.product_rule_type_code
                      AND s.product_rule_code         = w.product_rule_code
                      AND s.event_class_code          = w.event_class_code
                      AND s.event_type_code           = w.event_type_code
                      AND s.accounting_attribute_code = w.accounting_attribute_code);

    DELETE FROM xla_aad_header_ac_assgns w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_aad_header_ac_assgns s
                    WHERE s.application_id                 = g_application_id
                      AND s.amb_context_code               = g_staging_context_code
                      AND s.event_class_code               = w.event_class_code
                      AND s.event_type_code                = w.event_type_code
                      AND s.product_rule_type_code         = w.product_rule_type_code
                      AND s.product_rule_code              = w.product_rule_code
                      AND s.analytical_criterion_type_code = w.analytical_criterion_type_code
                      AND s.analytical_criterion_code      = w.analytical_criterion_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_aad_header_ac_assgns deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

  END IF;

  -- Move the AAD from staging area to working area
  UPDATE xla_product_rules_b
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_product_rules_b updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_product_rules_tl w
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code
     AND NOT EXISTS (SELECT 1
                       FROM xla_product_rules_tl s
                      WHERE s.application_id         = g_application_id
                        AND s.amb_context_code       = g_amb_context_code
                        AND s.product_rule_type_code = w.product_rule_type_code
                        AND s.name                   = w.name
                        AND s.language               = w.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_product_rules_tl 1 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_product_rules_tl w
     SET amb_context_code  = g_amb_context_code
       , name              = substr('('||product_rule_code||') '||name,1,80)
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code
     AND EXISTS (SELECT 1
                   FROM xla_product_rules_tl s
                  WHERE s.application_id         = g_application_id
                    AND s.amb_context_code       = g_amb_context_code
                    AND s.product_rule_type_code = w.product_rule_type_code
                    AND s.name                   = w.name
                    AND s.language               = w.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_product_rules_tl 2 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_prod_acct_headers
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_prod_acct_headers updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_aad_line_defn_assgns
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_aad_line_defn_assgns updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_aad_hdr_acct_attrs
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_aad_hdr_acct_attrs updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_aad_header_ac_assgns
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_aad_header_ac_assgns updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure merge_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.merge_aads'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END merge_aads;


--=============================================================================
--
-- Name: merge_journal_line_defns
-- Description: Merge journal line definitions from staging to working area
--
--=============================================================================
PROCEDURE merge_journal_line_defns
IS
  l_log_module    VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.merge_journal_line_defns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure merge_journal_line_defns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  /*************************************************/
  /**** Added by krsankar for Performance changes **/
  /*************************************************/

    INSERT INTO xla_aads_gt
     (  event_class_code,
        event_type_code,
        line_definition_code,
        table_name
     )
    select event_class_code,
           event_type_code,
           line_definition_code,
	       'XLA_LINE_DEFINITIONS_B'
    from
        (select event_class_code,
                event_type_code,
                line_definition_code,
	            'XLA_LINE_DEFINITIONS_B',
                amb_context_code,
                last_update_date ,
                nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
         from
            (select event_class_code,
                    event_type_code,
                    line_definition_code,
	                'XLA_LINE_DEFINITIONS_B',
                    amb_context_code,
                    last_update_date ,
                    lag(last_update_date) over (PARTITION by application_id,
                                                             event_class_code,
                                                             event_type_code,
                                                             line_definition_code,
							     line_definition_owner_code
                                                order by     amb_context_code
                                                ) lag_date
             from xla_line_definitions_b
             order by amb_context_code
            ) x
         where x.amb_context_code =g_staging_context_code
        )
    where flag = 'False';


       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
                trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_line_definitions_b is :'||SQL%ROWCOUNT,
                      p_module => l_log_module,
                      p_level  => C_LEVEL_PROCEDURE);
       END IF;

    INSERT INTO xla_aads_gt
    (   event_class_code,
        event_type_code,
	    line_definition_code,
	    accounting_line_code,
	    table_name
    )
    select  event_class_code,
            event_type_code,
            line_definition_code,
            accounting_line_code,
	        'XLA_LINE_DEFN_JLT_ASSGNS'
    from
     (select event_class_code,
             event_type_code,
             line_definition_code,
             accounting_line_code,
	         'XLA_LINE_DEFN_JLT_ASSGNS',
             amb_context_code,
             last_update_date ,
             nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
      from
        (select event_class_code,
                event_type_code,
                line_definition_code,
                accounting_line_code,
	            'XLA_LINE_DEFN_JLT_ASSGNS',
                amb_context_code,
                last_update_date ,
                lag(last_update_date) over (PARTITION by application_id,
                                                         event_class_code,
                                                         event_type_code,
                                                         line_definition_code,
							 line_definition_owner_code,
                                                         accounting_line_code,
							 accounting_line_type_code
                                            order by     amb_context_code
                                            ) lag_date
         from XLA_LINE_DEFN_JLT_ASSGNS
         order by amb_context_code
        ) x
      where x.amb_context_code =g_staging_context_code
      )
    where flag = 'False';


       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
                trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_line_defn_jlt_assgns is :'||SQL%ROWCOUNT,
                      p_module => l_log_module,
                      p_level  => C_LEVEL_PROCEDURE);
       END IF;


    INSERT INTO xla_aads_gt
       (  event_class_code,
          event_type_code,
          line_definition_code,
          accounting_line_code,
          segment_rule_code,
          table_name
        )
    select event_class_code,
           event_type_code,
           line_definition_code,
           accounting_line_code,
           segment_rule_code,
           'XLA_LINE_DEFN_ADR_ASSGNS'
    from
      (select event_class_code,
              event_type_code,
              line_definition_code,
              accounting_line_code,
              segment_rule_code,
              'XLA_LINE_DEFN_ADR_ASSGNS',
              amb_context_code,
              last_update_date ,
              nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
       from
          (select event_class_code,
                  event_type_code,
                  line_definition_code,
                  accounting_line_code,
                  segment_rule_code,
                  'XLA_LINE_DEFN_ADR_ASSGNS',
                  amb_context_code,
                  last_update_date,
                  lag(last_update_date) over (PARTITION by application_id,
                                                           event_class_code,
                                                           event_type_code,
                                                           line_definition_code,
							   line_definition_owner_code,
                                                           accounting_line_code,
							   accounting_line_type_code,
                                                           segment_rule_code,
							   segment_rule_type_code
                                              order by     amb_context_code
                                              ) lag_date
           from XLA_LINE_DEFN_ADR_ASSGNS
           order by amb_context_code
           ) x
       where x.amb_context_code = g_staging_context_code
       )
    where flag = 'False';

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
                trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_line_defn_adr_assgns is :'||SQL%ROWCOUNT,
                      p_module => l_log_module,
                      p_level  => C_LEVEL_PROCEDURE);
       END IF;


      INSERT INTO xla_aads_gt
        ( event_class_code,
          event_type_code,
          line_definition_code,
          accounting_line_code,
          analytical_criterion_code,
          table_name
        )
      select  event_class_code,
              event_type_code,
              line_definition_code,
              accounting_line_code,
              analytical_criterion_code,
              'XLA_LINE_DEFN_AC_ASSGNS'
      from
         (select event_class_code,
                 event_type_code,
                 line_definition_code,
                 accounting_line_code,
                 analytical_criterion_code,
                 'XLA_LINE_DEFN_AC_ASSGNS',
                 amb_context_code,
                 last_update_date ,
                 nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
          from
            (select event_class_code,
                    event_type_code,
                    line_definition_code,
                    accounting_line_code,
                    analytical_criterion_code,
                   'XLA_LINE_DEFN_AC_ASSGNS',
                    amb_context_code,
                    last_update_date ,
                    lag(last_update_date) over (PARTITION by application_id,
                                                             event_class_code,
                                                             event_type_code,
                                                             line_definition_code,
							     line_definition_owner_code,
                                                             accounting_line_code,
							     accounting_line_type_code,
                                                             analytical_criterion_code,
							     analytical_criterion_type_code
                                                order by     amb_context_code
                                                ) lag_date
             from XLA_LINE_DEFN_AC_ASSGNS
             order by amb_context_code
             ) x
          where x.amb_context_code = g_staging_context_code
          )
      where flag = 'False';


	  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
               trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_line_defn_ac_assgns is :'||SQL%ROWCOUNT,
                     p_module => l_log_module,
                     p_level  => C_LEVEL_PROCEDURE);
          END IF;


    INSERT INTO xla_aads_gt
       (   event_class_code
          ,event_type_code
	  ,line_definition_code
	  ,accounting_line_code
	  ,mpa_accounting_line_code
	  ,table_name
	)
   select  mpa_jlt_assgns.event_class_code
          ,mpa_jlt_assgns.event_type_code
          ,mpa_jlt_assgns.line_definition_code
          ,mpa_jlt_assgns.accounting_line_code
          ,mpa_jlt_assgns.mpa_accounting_line_code
	  ,'XLA_MPA_JLT_ASSGNS'
    from   XLA_MPA_JLT_ASSGNS     mpa_jlt_assgns
    where  mpa_jlt_assgns.application_id   = g_application_id
    and    mpa_jlt_assgns.amb_context_code = g_staging_context_code
	AND EXISTS (
            SELECT 1
              FROM xla_acct_line_types_b xal
             WHERE xal.application_id            = g_application_id
               AND xal.amb_context_code          = g_staging_context_code
               AND xal.event_class_code          = mpa_jlt_assgns.event_class_code
               AND xal.accounting_line_type_code = mpa_jlt_assgns.accounting_line_type_code
               AND xal.accounting_line_code      = mpa_jlt_assgns.accounting_line_code
               AND xal.mpa_option_code           = 'ACCRUAL')
    AND    (EXISTS (SELECT 1
                   FROM   XLA_MPA_JLT_ASSGNS     mpa_jlt_assgns1
                   WHERE  mpa_jlt_assgns.event_class_code           = mpa_jlt_assgns1.event_class_code
                   and    mpa_jlt_assgns.event_type_code            = mpa_jlt_assgns1.event_type_code
                   and    mpa_jlt_assgns.line_definition_code       = mpa_jlt_assgns1.line_definition_code
                   and    mpa_jlt_assgns.line_definition_owner_code = mpa_jlt_assgns1.line_definition_owner_code
                   and    mpa_jlt_assgns.accounting_line_code       = mpa_jlt_assgns1.accounting_line_code
                   and    mpa_jlt_assgns.accounting_line_type_code  = mpa_jlt_assgns1.accounting_line_type_code
                   and    mpa_jlt_assgns.mpa_accounting_line_code   = mpa_jlt_assgns1.mpa_accounting_line_code
                   and    mpa_jlt_assgns.mpa_accounting_line_type_code = mpa_jlt_assgns1.mpa_accounting_line_type_code
                   and    mpa_jlt_assgns.application_id             = mpa_jlt_assgns1.application_id
                   and    mpa_jlt_assgns1.amb_context_code          = g_amb_context_code
                   and    to_char(mpa_jlt_assgns.last_update_date,'DD-MON-YYYY') <> to_char(mpa_jlt_assgns1.last_update_date,'DD-MON-YYYY')
                   )
	    OR
	    NOT EXISTS (SELECT 1
                   FROM   XLA_MPA_JLT_ASSGNS     mpa_jlt_assgns1
                   WHERE  mpa_jlt_assgns.event_class_code           = mpa_jlt_assgns1.event_class_code
                   and    mpa_jlt_assgns.event_type_code            = mpa_jlt_assgns1.event_type_code
                   and    mpa_jlt_assgns.line_definition_code       = mpa_jlt_assgns1.line_definition_code
                   and    mpa_jlt_assgns.line_definition_owner_code = mpa_jlt_assgns1.line_definition_owner_code
                   and    mpa_jlt_assgns.accounting_line_code       = mpa_jlt_assgns1.accounting_line_code
                   and    mpa_jlt_assgns.accounting_line_type_code  = mpa_jlt_assgns1.accounting_line_type_code
                   and    mpa_jlt_assgns.mpa_accounting_line_code   = mpa_jlt_assgns1.mpa_accounting_line_code
                   and    mpa_jlt_assgns.mpa_accounting_line_type_code = mpa_jlt_assgns1.mpa_accounting_line_type_code
                   and    mpa_jlt_assgns.application_id             = mpa_jlt_assgns1.application_id
                   and    mpa_jlt_assgns1.amb_context_code          = g_amb_context_code
                   )
	    );

          IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
                trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_mpa_jlt_assgns is :'||SQL%ROWCOUNT,
                      p_module => l_log_module,
                      p_level  => C_LEVEL_PROCEDURE);
          END IF;


      INSERT INTO xla_aads_gt
       (   event_class_code
          ,event_type_code
	  ,line_definition_code
	  ,accounting_line_code
	  ,analytical_criterion_code
	  ,table_name
	)
   select  mpa_hdr_ac_assgns.event_class_code
          ,mpa_hdr_ac_assgns.event_type_code
          ,mpa_hdr_ac_assgns.line_definition_code
          ,mpa_hdr_ac_assgns.accounting_line_code
          ,mpa_hdr_ac_assgns.analytical_criterion_code
	  ,'XLA_MPA_HEADER_AC_ASSGNS'
    from   XLA_MPA_HEADER_AC_ASSGNS mpa_hdr_ac_assgns
    where  mpa_hdr_ac_assgns.application_id    = g_application_id
    and    mpa_hdr_ac_assgns.amb_context_code  = g_staging_context_code
    and    (EXISTS(SELECT 1
                  FROM   XLA_MPA_HEADER_AC_ASSGNS mpa_hdr_ac_assgns1
                  WHERE  mpa_hdr_ac_assgns.event_class_code               = mpa_hdr_ac_assgns1.event_class_code
                  and    mpa_hdr_ac_assgns.event_type_code                = mpa_hdr_ac_assgns1.event_type_code
                  and    mpa_hdr_ac_assgns.line_definition_code           = mpa_hdr_ac_assgns1.line_definition_code
                  and    mpa_hdr_ac_assgns.line_definition_owner_code     = mpa_hdr_ac_assgns1.line_definition_owner_code
                  and    mpa_hdr_ac_assgns.accounting_line_code           = mpa_hdr_ac_assgns1.accounting_line_code
                  and    mpa_hdr_ac_assgns.accounting_line_type_code      = mpa_hdr_ac_assgns1.accounting_line_type_code
                  and    mpa_hdr_ac_assgns.analytical_criterion_code      = mpa_hdr_ac_assgns1.analytical_criterion_code
                  and    mpa_hdr_ac_assgns.analytical_criterion_type_code = mpa_hdr_ac_assgns1.analytical_criterion_type_code
                  and    mpa_hdr_ac_assgns.application_id                 = mpa_hdr_ac_assgns1.application_id
                  and    mpa_hdr_ac_assgns1.amb_context_code              = g_amb_context_code
                  and    to_char(mpa_hdr_ac_assgns.last_update_date,'DD-MON-YYYY') <> to_char(mpa_hdr_ac_assgns1.last_update_date,'DD-MON-YYYY')
	          UNION
                  SELECT 1
                  FROM xla_acct_line_types_b s
                  WHERE s.application_id          = g_application_id
                  and s.amb_context_code          = g_staging_context_code
                  and s.event_class_code          = mpa_hdr_ac_assgns.event_class_code
                  and s.accounting_line_type_code = mpa_hdr_ac_assgns.accounting_line_type_code
                  and s.accounting_line_code      = mpa_hdr_ac_assgns.accounting_line_code
                  and s.mpa_option_code           = 'NONE'
                  )
	    OR
	    NOT EXISTS(SELECT 1
                  FROM   XLA_MPA_HEADER_AC_ASSGNS mpa_hdr_ac_assgns1
                  WHERE  mpa_hdr_ac_assgns.event_class_code               = mpa_hdr_ac_assgns1.event_class_code
                  and    mpa_hdr_ac_assgns.event_type_code                = mpa_hdr_ac_assgns1.event_type_code
                  and    mpa_hdr_ac_assgns.line_definition_code           = mpa_hdr_ac_assgns1.line_definition_code
                  and    mpa_hdr_ac_assgns.line_definition_owner_code     = mpa_hdr_ac_assgns1.line_definition_owner_code
                  and    mpa_hdr_ac_assgns.accounting_line_code           = mpa_hdr_ac_assgns1.accounting_line_code
                  and    mpa_hdr_ac_assgns.accounting_line_type_code      = mpa_hdr_ac_assgns1.accounting_line_type_code
                  and    mpa_hdr_ac_assgns.analytical_criterion_code      = mpa_hdr_ac_assgns1.analytical_criterion_code
                  and    mpa_hdr_ac_assgns.analytical_criterion_type_code = mpa_hdr_ac_assgns1.analytical_criterion_type_code
                  and    mpa_hdr_ac_assgns.application_id                 = mpa_hdr_ac_assgns1.application_id
                  and    mpa_hdr_ac_assgns1.amb_context_code              = g_amb_context_code
	          UNION
                  SELECT 1
                  FROM xla_acct_line_types_b s
                  WHERE s.application_id          = g_application_id
                  and s.amb_context_code          = g_staging_context_code
                  and s.event_class_code          = mpa_hdr_ac_assgns.event_class_code
                  and s.accounting_line_type_code = mpa_hdr_ac_assgns.accounting_line_type_code
                  and s.accounting_line_code      = mpa_hdr_ac_assgns.accounting_line_code
                  and s.mpa_option_code           = 'NONE'
                 )
	    );

	    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
                trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_mpa_header_ac_assgns is :'||SQL%ROWCOUNT,
                      p_module => l_log_module,
                      p_level  => C_LEVEL_PROCEDURE);
            END IF;


     INSERT INTO xla_aads_gt
         (
 	   event_class_code
	  ,event_type_code
	  ,line_definition_code
	  ,accounting_line_code
	  ,mpa_accounting_line_code
	  ,segment_rule_code
	  ,table_name
	 )
   select  mpa_jlt_adr_assgns.event_class_code
          ,mpa_jlt_adr_assgns.event_type_code
          ,mpa_jlt_adr_assgns.line_definition_code
          ,mpa_jlt_adr_assgns.accounting_line_code
          ,mpa_jlt_adr_assgns.mpa_accounting_line_code
	  ,mpa_jlt_adr_assgns.segment_rule_code
	  ,'XLA_MPA_JLT_ADR_ASSGNS'
    from   XLA_MPA_JLT_ADR_ASSGNS mpa_jlt_adr_assgns
    where  mpa_jlt_adr_assgns.application_id   = g_application_id
    and    mpa_jlt_adr_assgns.amb_context_code = g_staging_context_code
    and    EXISTS ( SELECT 1
                 FROM xla_mpa_jlt_assgns s
                 WHERE s.application_id               = g_application_id
                  AND s.amb_context_code              = g_staging_context_code
                  AND s.event_class_code              = mpa_jlt_adr_assgns.event_class_code
                  AND s.event_type_code               = mpa_jlt_adr_assgns.event_type_code
                  AND s.line_definition_owner_code    = mpa_jlt_adr_assgns.line_definition_owner_code
                  AND s.line_definition_code          = mpa_jlt_adr_assgns.line_definition_code
                  AND s.accounting_line_type_code     = mpa_jlt_adr_assgns.accounting_line_type_code
                  AND s.accounting_line_code          = mpa_jlt_adr_assgns.accounting_line_code
                  AND s.mpa_accounting_line_type_code = mpa_jlt_adr_assgns.mpa_accounting_line_type_code
                  AND s.mpa_accounting_line_code      = mpa_jlt_adr_assgns.mpa_accounting_line_code
                UNION
                 SELECT 1
                 FROM xla_acct_line_types_b s
                 WHERE s.application_id           = g_application_id
                  AND s.amb_context_code          = g_staging_context_code
                  AND s.event_class_code          = mpa_jlt_adr_assgns.event_class_code
                  AND s.accounting_line_type_code = mpa_jlt_adr_assgns.accounting_line_type_code
                  AND s.accounting_line_code      = mpa_jlt_adr_assgns.accounting_line_code
                  AND s.mpa_option_code           = 'NONE')
    and    (EXISTS(SELECT 1
                  FROM   XLA_MPA_JLT_ADR_ASSGNS mpa_jlt_adr_assgns1
                  WHERE  mpa_jlt_adr_assgns.event_class_code              = mpa_jlt_adr_assgns1.event_class_code
                  and    mpa_jlt_adr_assgns.event_type_code               = mpa_jlt_adr_assgns1.event_type_code
                  and    mpa_jlt_adr_assgns.line_definition_code          = mpa_jlt_adr_assgns1.line_definition_code
                  and    mpa_jlt_adr_assgns.line_definition_owner_code    = mpa_jlt_adr_assgns1.line_definition_owner_code
                  and    mpa_jlt_adr_assgns.accounting_line_code          = mpa_jlt_adr_assgns1.accounting_line_code
                  and    mpa_jlt_adr_assgns.accounting_line_type_code     = mpa_jlt_adr_assgns1.accounting_line_type_code
                  and    mpa_jlt_adr_assgns.mpa_accounting_line_code      = mpa_jlt_adr_assgns1.mpa_accounting_line_code
                  and    mpa_jlt_adr_assgns.mpa_accounting_line_type_code = mpa_jlt_adr_assgns1.mpa_accounting_line_type_code
                  and    mpa_jlt_adr_assgns.segment_rule_code             = mpa_jlt_adr_assgns1.segment_rule_code
                  and    mpa_jlt_adr_assgns.segment_rule_type_code        = mpa_jlt_adr_assgns1.segment_rule_type_code
                  and    mpa_jlt_adr_assgns.application_id                = mpa_jlt_adr_assgns1.application_id
                  and    mpa_jlt_adr_assgns1.amb_context_code             = g_amb_context_code
                  and    to_char(mpa_jlt_adr_assgns.last_update_date,'DD-MON-YYYY') <> to_char(mpa_jlt_adr_assgns1.last_update_date,'DD-MON-YYYY')
                  )
	    OR
	    NOT EXISTS(SELECT 1
                  FROM   XLA_MPA_JLT_ADR_ASSGNS mpa_jlt_adr_assgns1
                  WHERE  mpa_jlt_adr_assgns.event_class_code              = mpa_jlt_adr_assgns1.event_class_code
                  and    mpa_jlt_adr_assgns.event_type_code               = mpa_jlt_adr_assgns1.event_type_code
                  and    mpa_jlt_adr_assgns.line_definition_code          = mpa_jlt_adr_assgns1.line_definition_code
                  and    mpa_jlt_adr_assgns.line_definition_owner_code    = mpa_jlt_adr_assgns1.line_definition_owner_code
                  and    mpa_jlt_adr_assgns.accounting_line_code          = mpa_jlt_adr_assgns1.accounting_line_code
                  and    mpa_jlt_adr_assgns.accounting_line_type_code     = mpa_jlt_adr_assgns1.accounting_line_type_code
                  and    mpa_jlt_adr_assgns.mpa_accounting_line_code      = mpa_jlt_adr_assgns1.mpa_accounting_line_code
                  and    mpa_jlt_adr_assgns.mpa_accounting_line_type_code = mpa_jlt_adr_assgns1.mpa_accounting_line_type_code
                  and    mpa_jlt_adr_assgns.segment_rule_code             = mpa_jlt_adr_assgns1.segment_rule_code
                  and    mpa_jlt_adr_assgns.segment_rule_type_code        = mpa_jlt_adr_assgns1.segment_rule_type_code
                  and    mpa_jlt_adr_assgns.application_id                = mpa_jlt_adr_assgns1.application_id
                  and    mpa_jlt_adr_assgns1.amb_context_code             = g_amb_context_code
                  )
	    );

	    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
                trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_mpa_jlt_adr_assgns is :'||SQL%ROWCOUNT,
                      p_module => l_log_module,
                      p_level  => C_LEVEL_PROCEDURE);
            END IF;


   INSERT INTO xla_aads_gt
        (  event_class_code
	  ,event_type_code
	  ,line_definition_code
	  ,accounting_line_code
	  ,mpa_accounting_line_code
	  ,analytical_criterion_code
	  ,table_name
	)
   select  mpa_jlt_ac_assgns.event_class_code
          ,mpa_jlt_ac_assgns.event_type_code
          ,mpa_jlt_ac_assgns.line_definition_code
          ,mpa_jlt_ac_assgns.accounting_line_code
          ,mpa_jlt_ac_assgns.mpa_accounting_line_code
          ,mpa_jlt_ac_assgns.analytical_criterion_code
	  ,'XLA_MPA_JLT_AC_ASSGNS'
    from   XLA_MPA_JLT_AC_ASSGNS  mpa_jlt_ac_assgns
    where  mpa_jlt_ac_assgns.application_id   = g_application_id
    and    mpa_jlt_ac_assgns.amb_context_code = g_staging_context_code
    and    (EXISTS(SELECT 1
                  FROM   XLA_MPA_JLT_AC_ASSGNS  mpa_jlt_ac_assgns1
                  WHERE  mpa_jlt_ac_assgns.event_class_code               = mpa_jlt_ac_assgns1.event_class_code
                  and    mpa_jlt_ac_assgns.event_type_code                = mpa_jlt_ac_assgns1.event_type_code
                  and    mpa_jlt_ac_assgns.line_definition_code           = mpa_jlt_ac_assgns1.line_definition_code
                  and    mpa_jlt_ac_assgns.line_definition_owner_code     = mpa_jlt_ac_assgns1.line_definition_owner_code
                  and    mpa_jlt_ac_assgns.accounting_line_code           = mpa_jlt_ac_assgns1.accounting_line_code
                  and    mpa_jlt_ac_assgns.accounting_line_type_code      = mpa_jlt_ac_assgns1.accounting_line_type_code
                  and    mpa_jlt_ac_assgns.mpa_accounting_line_code       = mpa_jlt_ac_assgns1.mpa_accounting_line_code
                  and    mpa_jlt_ac_assgns.mpa_accounting_line_type_code  = mpa_jlt_ac_assgns1.mpa_accounting_line_type_code
                  and    mpa_jlt_ac_assgns.analytical_criterion_code      = mpa_jlt_ac_assgns1.analytical_criterion_code
                  and    mpa_jlt_ac_assgns.analytical_criterion_type_code = mpa_jlt_ac_assgns1.analytical_criterion_type_code
                  and    mpa_jlt_ac_assgns.application_id                 = mpa_jlt_ac_assgns1.application_id
                  and    mpa_jlt_ac_assgns1.amb_context_code              = g_amb_context_code
                  and    to_char(mpa_jlt_ac_assgns.last_update_date,'DD-MON-YYYY') <> to_char(mpa_jlt_ac_assgns1.last_update_date,'DD-MON-YYYY')
		  UNION
                  SELECT 1
                  FROM xla_acct_line_types_b s
                  WHERE s.application_id           = g_application_id
                  and s.amb_context_code           = g_staging_context_code
                  and s.event_class_code           = mpa_jlt_ac_assgns.event_class_code
                  and s.accounting_line_type_code  = mpa_jlt_ac_assgns.accounting_line_type_code
                  and s.accounting_line_code       = mpa_jlt_ac_assgns.accounting_line_code
                  and s.mpa_option_code            = 'NONE'
                  )
	    OR
	    NOT EXISTS(SELECT 1
                  FROM   XLA_MPA_JLT_AC_ASSGNS  mpa_jlt_ac_assgns1
                  WHERE  mpa_jlt_ac_assgns.event_class_code               = mpa_jlt_ac_assgns1.event_class_code
                  and    mpa_jlt_ac_assgns.event_type_code                = mpa_jlt_ac_assgns1.event_type_code
                  and    mpa_jlt_ac_assgns.line_definition_code           = mpa_jlt_ac_assgns1.line_definition_code
                  and    mpa_jlt_ac_assgns.line_definition_owner_code     = mpa_jlt_ac_assgns1.line_definition_owner_code
                  and    mpa_jlt_ac_assgns.accounting_line_code           = mpa_jlt_ac_assgns1.accounting_line_code
                  and    mpa_jlt_ac_assgns.accounting_line_type_code      = mpa_jlt_ac_assgns1.accounting_line_type_code
                  and    mpa_jlt_ac_assgns.mpa_accounting_line_code       = mpa_jlt_ac_assgns1.mpa_accounting_line_code
                  and    mpa_jlt_ac_assgns.mpa_accounting_line_type_code  = mpa_jlt_ac_assgns1.mpa_accounting_line_type_code
                  and    mpa_jlt_ac_assgns.analytical_criterion_code      = mpa_jlt_ac_assgns1.analytical_criterion_code
                  and    mpa_jlt_ac_assgns.analytical_criterion_type_code = mpa_jlt_ac_assgns1.analytical_criterion_type_code
                  and    mpa_jlt_ac_assgns.application_id                 = mpa_jlt_ac_assgns1.application_id
                  and    mpa_jlt_ac_assgns1.amb_context_code              = g_amb_context_code
		  UNION
                  SELECT 1
                  FROM xla_acct_line_types_b s
                  WHERE s.application_id           = g_application_id
                  and s.amb_context_code           = g_staging_context_code
                  and s.event_class_code           = mpa_jlt_ac_assgns.event_class_code
                  and s.accounting_line_type_code  = mpa_jlt_ac_assgns.accounting_line_type_code
                  and s.accounting_line_code       = mpa_jlt_ac_assgns.accounting_line_code
                  and s.mpa_option_code            = 'NONE'
                  )
	    );

	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_mpa_jlt_ac_assgns is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
         END IF;


  IF (g_analyzed_flag = 'Y') THEN
    null;

  ELSE

    -- Delete the journal line definitions from the working area if it already
    -- exists in the staging area
    DELETE FROM xla_line_definitions_b w
     WHERE application_id             = g_application_id
       AND amb_context_code           = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_line_definitions_b s
                    WHERE s.application_id             = g_application_id
                      AND s.amb_context_code           = g_staging_context_code
                      AND s.event_class_code           = w.event_class_code
                      AND s.event_type_code            = w.event_type_code
                      AND s.line_definition_owner_code = w.line_definition_owner_code
                      AND s.line_definition_code       = w.line_definition_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_line_definitions_b deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_line_definitions_tl w
     WHERE application_id             = g_application_id
       AND amb_context_code           = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_line_definitions_tl s
                    WHERE s.application_id             = g_application_id
                      AND s.amb_context_code           = g_staging_context_code
                      AND s.event_class_code           = w.event_class_code
                      AND s.event_type_code            = w.event_type_code
                      AND s.line_definition_owner_code = w.line_definition_owner_code
                      AND s.line_definition_code       = w.line_definition_code
                      AND s.language                   = w.language);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_line_definitions_tl deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_line_defn_jlt_assgns w
     WHERE application_id             = g_application_id
       AND amb_context_code           = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_line_defn_jlt_assgns s
                    WHERE s.application_id             = g_application_id
                      AND s.amb_context_code           = g_staging_context_code
                      AND s.event_class_code           = w.event_class_code
                      AND s.event_type_code            = w.event_type_code
                      AND s.line_definition_owner_code = w.line_definition_owner_code
                      AND s.line_definition_code       = w.line_definition_code
                      AND s.accounting_line_type_code  = w.accounting_line_type_code
                      AND s.accounting_line_code       = w.accounting_line_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_line_defn_jlt_assgns deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    -- ADR assignment is not merged, but overwritten, if the JLD exists in the
    -- staging area.
    DELETE FROM xla_line_defn_adr_assgns w
     WHERE application_id             = g_application_id
       AND amb_context_code           = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_line_defn_jlt_assgns s
                    WHERE s.application_id             = g_application_id
                      AND s.amb_context_code           = g_staging_context_code
                      AND s.event_class_code           = w.event_class_code
                      AND s.event_type_code            = w.event_type_code
                      AND s.line_definition_owner_code = w.line_definition_owner_code
                      AND s.line_definition_code       = w.line_definition_code
                      AND s.accounting_line_type_code  = w.accounting_line_type_code
                      AND s.accounting_line_code       = w.accounting_line_code);
                      --AND s.flexfield_segment_code     = w.flexfield_segment_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_line_defn_adr_assgns deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_line_defn_ac_assgns w
     WHERE application_id             = g_application_id
       AND amb_context_code           = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_line_defn_ac_assgns s
                    WHERE s.application_id                 = g_application_id
                      AND s.amb_context_code               = g_staging_context_code
                      AND s.event_class_code               = w.event_class_code
                      AND s.event_type_code                = w.event_type_code
                      AND s.line_definition_owner_code     = w.line_definition_owner_code
                      AND s.line_definition_code           = w.line_definition_code
                      AND s.accounting_line_type_code      = w.accounting_line_type_code
                      AND s.accounting_line_code           = w.accounting_line_code
                      AND s.analytical_criterion_type_code = w.analytical_criterion_type_code
                      AND s.analytical_criterion_code      = w.analytical_criterion_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_line_defn_ac_assgns deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

-- bug8635648 MPA JLT's deleted even when no data for JLT's in Staging Table
    DELETE FROM xla_mpa_jlt_assgns w
     WHERE application_id             = g_application_id
       AND amb_context_code           = g_amb_context_code
       AND EXISTS (
            SELECT 1
              FROM xla_acct_line_types_b xal
             WHERE xal.application_id            = g_application_id -- w.application_id -- changed for bug8635648
               AND xal.amb_context_code          = g_staging_context_code -- w.amb_context_code  -- changed for bug8635648
               AND xal.event_class_code          = w.event_class_code
               AND xal.accounting_line_type_code = w.accounting_line_type_code
               AND xal.accounting_line_code      = w.accounting_line_code
               AND xal.mpa_option_code           = 'ACCRUAL');

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_mpa_jlt_assgns deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_mpa_header_ac_assgns w
     WHERE application_id             = g_application_id
       AND amb_context_code           = g_amb_context_code
       AND EXISTS (
            SELECT 1
              FROM xla_mpa_header_ac_assgns s
             WHERE s.application_id                 = g_application_id
               AND s.amb_context_code               = g_staging_context_code
               AND s.event_class_code               = w.event_class_code
               AND s.event_type_code                = w.event_type_code
               AND s.line_definition_owner_code     = w.line_definition_owner_code
               AND s.line_definition_code           = w.line_definition_code
               AND s.accounting_line_type_code      = w.accounting_line_type_code
               AND s.accounting_line_code           = w.accounting_line_code
               AND s.analytical_criterion_type_code = w.analytical_criterion_type_code
               AND s.analytical_criterion_code      = w.analytical_criterion_code
             UNION
            SELECT 1
              FROM xla_acct_line_types_b s
             WHERE s.application_id            = g_application_id
               AND s.amb_context_code          = g_staging_context_code
               AND s.event_class_code          = w.event_class_code
               AND s.accounting_line_type_code = w.accounting_line_type_code
               AND s.accounting_line_code      = w.accounting_line_code
               AND s.mpa_option_code           = 'NONE');

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_mpa_header_ac_assgns deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    -- ADR assignments are not merged, but overwritten, if the MPA JLT exists in
    -- the staging area
    DELETE FROM xla_mpa_jlt_adr_assgns w
     WHERE application_id             = g_application_id
       AND amb_context_code           = g_amb_context_code
       AND EXISTS (
            SELECT 1
              FROM xla_mpa_jlt_assgns s
             WHERE s.application_id                = g_application_id
               AND s.amb_context_code              = g_staging_context_code
               AND s.event_class_code              = w.event_class_code
               AND s.event_type_code               = w.event_type_code
               AND s.line_definition_owner_code    = w.line_definition_owner_code
               AND s.line_definition_code          = w.line_definition_code
               AND s.accounting_line_type_code     = w.accounting_line_type_code
               AND s.accounting_line_code          = w.accounting_line_code
               AND s.mpa_accounting_line_type_code = w.mpa_accounting_line_type_code
               AND s.mpa_accounting_line_code      = w.mpa_accounting_line_code
             UNION
            SELECT 1
              FROM xla_acct_line_types_b s
             WHERE s.application_id            = g_application_id
               AND s.amb_context_code          = g_staging_context_code
               AND s.event_class_code          = w.event_class_code
               AND s.accounting_line_type_code = w.accounting_line_type_code
               AND s.accounting_line_code      = w.accounting_line_code
               AND s.mpa_option_code           = 'NONE');

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_mpa_jlt_adr_assgns deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_mpa_jlt_ac_assgns w
     WHERE application_id             = g_application_id
       AND amb_context_code           = g_amb_context_code
       AND EXISTS (
            SELECT 1
              FROM xla_mpa_jlt_ac_assgns s
             WHERE s.application_id               = g_application_id
             AND s.amb_context_code               = g_staging_context_code
             AND s.event_class_code               = w.event_class_code
             AND s.event_type_code                = w.event_type_code
             AND s.line_definition_owner_code     = w.line_definition_owner_code
             AND s.line_definition_code           = w.line_definition_code
             AND s.accounting_line_type_code      = w.accounting_line_type_code
             AND s.accounting_line_code           = w.accounting_line_code
             AND s.mpa_accounting_line_type_code  = w.mpa_accounting_line_type_code
             AND s.mpa_accounting_line_code       = w.mpa_accounting_line_code
             AND s.analytical_criterion_type_code = w.analytical_criterion_type_code
             AND s.analytical_criterion_code      = w.analytical_criterion_code
           UNION
          SELECT 1
            FROM xla_acct_line_types_b s
           WHERE s.application_id             = g_application_id
             AND s.amb_context_code           = g_staging_context_code
             AND s.event_class_code           = w.event_class_code
             AND s.accounting_line_type_code  = w.accounting_line_type_code
             AND s.accounting_line_code       = w.accounting_line_code
             AND s.mpa_option_code            = 'NONE');

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_mpa_jlt_ac_assgns deleted : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

  END IF;

  -- Move the journal line definitions from staging area to working area
  UPDATE xla_line_definitions_b
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_definitions_b updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_line_definitions_tl w
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code
     AND NOT EXISTS (SELECT 1
                       FROM xla_line_definitions_tl s
                      WHERE s.application_id             = g_application_id
                        AND s.amb_context_code           = g_amb_context_code
                        AND s.event_class_code           = w.event_class_code
                        AND s.event_type_code            = w.event_type_code
                        AND s.line_definition_owner_code = w.line_definition_owner_code
                        AND s.name                       = w.name
                        AND s.language                   = w.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_definitions_tl 1 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_line_definitions_tl w
     SET amb_context_code  = g_amb_context_code
       , name              = substr('('||line_definition_code||') '||name,1,80)
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code
     AND EXISTS (SELECT 1
                   FROM xla_line_definitions_tl s
                  WHERE s.application_id             = g_application_id
                    AND s.amb_context_code           = g_amb_context_code
                    AND s.event_class_code           = w.event_class_code
                    AND s.event_type_code            = w.event_type_code
                    AND s.line_definition_owner_code = w.line_definition_owner_code
                    AND s.name                       = w.name
                    AND s.language                   = w.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_definitions_tl 2 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_line_defn_jlt_assgns
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_jlt_assgns updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_line_defn_adr_assgns
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_adr_assgns updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_line_defn_ac_assgns
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_ac_assgns updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_mpa_jlt_assgns
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_assgns updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_mpa_header_ac_assgns
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_header_ac_assgns updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_mpa_jlt_adr_assgns
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_adr_assgns updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- For AC that is not going to be overwritten by those in staging area, it
  -- must not exist in the staging area.  Therefore, it must not be inherited.
  UPDATE xla_mpa_jlt_ac_assgns
     SET mpa_inherit_ac_flag = 'N'
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_amb_context_code;

  UPDATE xla_mpa_jlt_ac_assgns
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_ac_assgns updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure merge_journal_line_defns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.merge_journal_line_defns'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END merge_journal_line_defns;


--=============================================================================
--
-- Name: merge_journal_line_types
-- Description: Merge journal line types from staging to working area
--
--=============================================================================
PROCEDURE merge_journal_line_types
IS

  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.merge_journal_line_types';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure merge_journal_line_types',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  /*************************************************/
  /**** Added by krsankar for Performance changes **/
  /*************************************************/

    INSERT INTO xla_aads_gt
      ( entity_code,
        event_class_code,
        accounting_line_code,
        accounting_class_code,
        table_name
      )
    select  entity_code,
            event_class_code,
            accounting_line_code,
            accounting_class_code,
	        'XLA_ACCT_LINE_TYPES_B'
    from
        (select entity_code,
                event_class_code,
                accounting_line_code,
                accounting_class_code,
	           'XLA_ACCT_LINE_TYPES_B',
                amb_context_code,
                last_update_date ,
                nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
         from
            (select entity_code,
                    event_class_code,
                    accounting_line_code,
                    accounting_class_code,
	                'XLA_ACCT_LINE_TYPES_B',
                    amb_context_code,
                    last_update_date,
                    lag(last_update_date) over (PARTITION by application_id,
                                                             event_class_code,
                                                             accounting_line_code,
                                                             accounting_line_type_code
                                                order by     amb_context_code
                                                ) lag_date
             from xla_acct_line_types_b
             order by amb_context_code
            ) x
         where x.amb_context_code = g_staging_context_code
        )
    where flag = 'False';


 	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_acct_line_types_b is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
         END IF;


   INSERT INTO xla_aads_gt
        ( event_class_code
	 ,accounting_line_code
	 ,accounting_attribute_code
	 ,source_code
	 ,table_name
         )
   select jlt_acct_attrs.event_class_code
         ,jlt_acct_attrs.accounting_line_code
         ,jlt_acct_attrs.accounting_attribute_code
         ,jlt_acct_attrs.source_code
	 ,'xla_jlt_acct_attrs'
   from  xla_jlt_acct_attrs     jlt_acct_attrs
   where jlt_acct_attrs.application_id   = g_application_id
   and   jlt_acct_attrs.amb_context_code = g_staging_context_code
   and  (EXISTS(SELECT 1
                FROM   xla_jlt_acct_attrs     jlt_acct_attrs1
                WHERE  jlt_acct_attrs.event_class_code          = jlt_acct_attrs1.event_class_code
                 and   jlt_acct_attrs.accounting_line_code      = jlt_acct_attrs1.accounting_line_code
                 and   jlt_acct_attrs.accounting_line_type_code = jlt_acct_attrs1.accounting_line_type_code
		         and   nvl(jlt_acct_attrs.accounting_attribute_code,' ') = nvl(jlt_acct_attrs1.accounting_attribute_code,' ')
                 and   nvl(jlt_acct_attrs.source_code,' ')      = nvl(jlt_acct_attrs1.source_code,' ')
                 and   jlt_acct_attrs.application_id            = jlt_acct_attrs1.application_id
                 and   jlt_acct_attrs1.amb_context_code         = g_amb_context_code
                 and   to_char(jlt_acct_attrs.last_update_date,'DD-MON-YYYY') <> to_char(jlt_acct_attrs1.last_update_date,'DD-MON-YYYY')
                )
	 OR
	 NOT EXISTS(SELECT 1
                FROM   xla_jlt_acct_attrs     jlt_acct_attrs1
                WHERE  jlt_acct_attrs.event_class_code          = jlt_acct_attrs1.event_class_code
                 and   jlt_acct_attrs.accounting_line_code      = jlt_acct_attrs1.accounting_line_code
                 and   jlt_acct_attrs.accounting_line_type_code = jlt_acct_attrs1.accounting_line_type_code
		         and   nvl(jlt_acct_attrs.accounting_attribute_code,' ') = nvl(jlt_acct_attrs1.accounting_attribute_code,' ')
                 and   nvl(jlt_acct_attrs.source_code,' ')      = nvl(jlt_acct_attrs1.source_code,' ')
                 and   jlt_acct_attrs.application_id            = jlt_acct_attrs1.application_id
                 and   jlt_acct_attrs1.amb_context_code         = g_amb_context_code
                )
	 );

	  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_jlt_acct_attrs is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
          END IF;


   INSERT INTO xla_aads_gt
        ( entity_code
	 ,event_class_code
	 ,accounting_line_code
	 ,source_code
	 ,table_name
         )
   select condn.entity_code
         ,condn.event_class_code
         ,condn.accounting_line_code
         ,condn.source_code
	 ,'xla_conditions'
   from  xla_conditions         condn
   where condn.application_id           = g_application_id
   and   condn.amb_context_code         = g_staging_context_code
   and EXISTS (SELECT 1
               FROM xla_acct_line_types_b s
               WHERE s.application_id          = g_application_id
               and s.amb_context_code          = g_staging_context_code
               and s.event_class_code          = condn.event_class_code
               and s.accounting_line_type_code = condn.accounting_line_type_code
               and s.accounting_line_code      = condn.accounting_line_code)
   and  (EXISTS(SELECT 1
                FROM   xla_conditions condn1
                WHERE  condn.entity_code               = condn1.entity_code
                 and   condn.event_class_code          = condn1.event_class_code
                 and   condn.accounting_line_code      = condn1.accounting_line_code
                 and   condn.accounting_line_type_code = condn1.accounting_line_type_code
                 and   nvl(condn.source_code,' ')      = nvl(condn1.source_code,' ')
                 and   nvl(condn.source_type_code,' ') = nvl(condn1.source_type_code,' ')
                 and   condn.user_sequence             = condn1.user_sequence
                 and   condn.application_id            = condn1.application_id
                 and   condn1.amb_context_code         = g_amb_context_code
                 and   to_char(condn.last_update_date,'DD-MON-YYYY') <> to_char(condn1.last_update_date,'DD-MON-YYYY')
                )
	 OR
	 NOT EXISTS(SELECT 1
                FROM   xla_conditions condn1
                WHERE  nvl(condn.entity_code,' ')               = nvl(condn1.entity_code,' ')
                 and   nvl(condn.event_class_code,' ')          = nvl(condn1.event_class_code,' ')
                 and   nvl(condn.accounting_line_code,' ')      = nvl(condn1.accounting_line_code,' ')
                 and   nvl(condn.accounting_line_type_code,' ') = nvl(condn1.accounting_line_type_code,' ')
                 and   nvl(condn.source_code,' ')      = nvl(condn1.source_code,' ')
                 and   nvl(condn.source_type_code,' ') = nvl(condn1.source_type_code,' ')
                 and   condn.user_sequence             = condn1.user_sequence
                 and   condn.application_id            = condn1.application_id
                 and   condn1.amb_context_code         = g_amb_context_code
                )
	 );

	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_conditions is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
          END IF;


  IF (g_analyzed_flag = 'Y') THEN
    null;

  ELSE

    -- Delete the journal line types from the working area if it already
    -- exists in the staging area
    DELETE FROM xla_acct_line_types_b w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_acct_line_types_b s
                    WHERE s.application_id            = g_application_id
                      AND s.amb_context_code          = g_staging_context_code
                      AND s.event_class_code          = w.event_class_code
                      AND s.accounting_line_type_code = w.accounting_line_type_code
                      AND s.accounting_line_code      = w.accounting_line_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_acct_line_types_b delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_acct_line_types_tl w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_acct_line_types_tl s
                    WHERE s.application_id            = g_application_id
                      AND s.amb_context_code          = g_staging_context_code
                      AND s.event_class_code          = w.event_class_code
                      AND s.accounting_line_type_code = w.accounting_line_type_code
                      AND s.accounting_line_code      = w.accounting_line_code
                      AND s.language                  = w.language);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_acct_line_types_tl delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_jlt_acct_attrs w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_jlt_acct_attrs s
                    WHERE s.application_id            = g_application_id
                      AND s.amb_context_code          = g_staging_context_code
                      AND s.event_class_code          = w.event_class_code
                      AND s.accounting_line_type_code = w.accounting_line_type_code
                      AND s.accounting_line_code      = w.accounting_line_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_jlt_acct_attrs delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_conditions w
     WHERE application_id            = g_application_id
       AND amb_context_code          = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_acct_line_types_b s
                    WHERE s.application_id            = g_application_id
                      AND s.amb_context_code          = g_staging_context_code
                      AND s.event_class_code          = w.event_class_code
                      AND s.accounting_line_type_code = w.accounting_line_type_code
                      AND s.accounting_line_code      = w.accounting_line_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_jlt_acct_attrs delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

  END IF;

  -- Move the journal line types from staging area to working area
  UPDATE xla_acct_line_types_b
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_acct_line_types_b updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_acct_line_types_tl w
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code
     AND NOT EXISTS (SELECT 1
                       FROM xla_acct_line_types_tl s
                      WHERE s.application_id            = g_application_id
                        AND s.amb_context_code          = g_amb_context_code
                        AND s.event_class_code          = w.event_class_code
                        AND s.accounting_line_type_code = w.accounting_line_type_code
                        AND s.name                      = w.name
                        AND s.language                  = w.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_acct_line_types_tl 1 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_acct_line_types_tl w
     SET amb_context_code  = g_amb_context_code
       , name              = substr('('||w.accounting_line_code||') '||name,1,80)
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code
     AND EXISTS (SELECT 1
                   FROM xla_acct_line_types_tl s
                  WHERE s.application_id            = g_application_id
                    AND s.amb_context_code          = g_amb_context_code
                    AND s.event_class_code          = w.event_class_code
                    AND s.accounting_line_type_code = w.accounting_line_type_code
                    AND s.name                      = w.name
                    AND s.language                  = w.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_acct_line_types_tl 2 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_jlt_acct_attrs
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_jlt_acct_attrs updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_conditions
     SET amb_context_code     = g_amb_context_code
   WHERE amb_context_code     = g_staging_context_code
     AND application_id       = g_application_id
     AND accounting_line_code IS NOT NULL;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_conditions updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure merge_journal_line_types',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.merge_journal_line_types'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END merge_journal_line_types;


--=============================================================================
--
-- Name: merge_descriptions
-- Description: Merge descriptions from staging to working area
--
--=============================================================================
PROCEDURE merge_descriptions
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.merge_descriptions';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure merge_descriptions',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  /*************************************************/
  /**** Added by krsankar for Performance changes **/
  /*************************************************/

    INSERT INTO xla_aads_gt
        (description_code,
	     table_name
        )
    select description_code,
           'XLA_DESCRIPTIONS_B'
    from
       (select description_code,
              'XLA_DESCRIPTIONS_B',
               amb_context_code,
               last_update_date ,
               nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
        from
          (select description_code,
                  'XLA_DESCRIPTIONS_B',
                  amb_context_code,
                  last_update_date ,
                  lag(last_update_date) over (PARTITION by application_id,
                                                           description_code,
                                                           description_type_code
                                              order by     amb_context_code
                                              ) lag_date
           from xla_descriptions_b
           order by amb_context_code
           ) x
        where x.amb_context_code = g_staging_context_code
        )
    where flag = 'False';


	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_descriptions_b is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
         END IF;


    INSERT INTO xla_aads_gt
      ( description_code,
	    table_name
      )
    select description_code,
          'XLA_DESC_PRIORITIES'
    from
       (select description_code,
              'XLA_DESC_PRIORITIES',
               amb_context_code,
               last_update_date ,
               nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
        from
           (select description_code,
                   'XLA_DESC_PRIORITIES',
                   amb_context_code,
                   last_update_date ,
                   lag(last_update_date) over (PARTITION by application_id,
                                                            description_code,
                                                            description_type_code
                                               order by     amb_context_code
                                               ) lag_date
            from xla_desc_priorities
            order by amb_context_code
            ) x
        where x.amb_context_code = g_staging_context_code
        )
    where flag = 'False';

	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_desc_priorities is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
         END IF;


    INSERT INTO xla_aads_gt
   (  source_code,
      table_name
    )
   SELECT desc_details.source_code,
          'xla_descript_details_b'
   FROM   xla_descript_details_b desc_details
   WHERE  desc_details.amb_context_code = g_staging_context_code
   AND    desc_details.description_prio_id IN
           (SELECT w.description_prio_id
            FROM   xla_desc_priorities w
                  ,xla_desc_priorities s
            WHERE s.application_id      = g_application_id
            AND s.amb_context_code      = g_staging_context_code
            AND w.application_id        = g_application_id
            AND w.amb_context_code      = g_amb_context_code
            AND w.description_type_code = s.description_type_code
            AND w.description_code      = s.description_code)
   AND (EXISTS (SELECT 1
               FROM   xla_descript_details_b desc_details1
               WHERE  desc_details1.amb_context_code   = g_amb_context_code
               AND    desc_details.description_prio_id = desc_details1.description_prio_id
               AND    to_char(desc_details.last_update_date,'DD-MON-YYYY') <> to_char(desc_details1.last_update_date,'DD-MON-YYYY')
               )
	OR
	NOT EXISTS (SELECT 1
                  FROM   xla_descript_details_b desc_details1
                  WHERE  desc_details1.amb_context_code   = g_amb_context_code
                  AND    desc_details.description_prio_id = desc_details1.description_prio_id
                  )
	);

	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_descript_details_b is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
         END IF;


  IF (g_analyzed_flag = 'Y') THEN
    null;

  ELSE

    -- Delete the descriptions from the working area if it already
    -- exists in the staging area
    DELETE FROM xla_descriptions_b w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_descriptions_b s
                    WHERE s.application_id        = g_application_id
                      AND s.amb_context_code      = g_staging_context_code
                      AND s.description_type_code = w.description_type_code
                      AND s.description_code      = w.description_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_descriptions_b delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_descriptions_tl w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_descriptions_tl s
                    WHERE s.application_id        = g_application_id
                      AND s.amb_context_code      = g_staging_context_code
                      AND s.description_type_code = w.description_type_code
                      AND s.description_code      = w.description_code
                      AND s.language              = w.language);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_descriptions_tl delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_desc_priorities w
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_desc_priorities s
                    WHERE s.application_id        = g_application_id
                      AND s.amb_context_code      = g_staging_context_code
                      AND s.description_type_code = w.description_type_code
                      AND s.description_code      = w.description_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_desc_priorities delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_conditions
     WHERE description_prio_id IN
           (SELECT w.description_prio_id
              FROM xla_desc_priorities w
                 , xla_desc_priorities s
             WHERE s.application_id        = g_application_id
               AND s.amb_context_code      = g_staging_context_code
               AND w.application_id        = g_application_id
               AND w.amb_context_code      = g_amb_context_code
               AND w.description_type_code = s.description_type_code
               AND w.description_code      = s.description_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_conditions delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_descript_details_b
     WHERE description_prio_id IN
           (SELECT w.description_prio_id
              FROM xla_desc_priorities w
                 , xla_desc_priorities s
             WHERE s.application_id        = g_application_id
               AND s.amb_context_code      = g_staging_context_code
               AND w.application_id        = g_application_id
               AND w.amb_context_code      = g_amb_context_code
               AND w.description_type_code = s.description_type_code
               AND w.description_code      = s.description_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_descript_details_b delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    DELETE FROM xla_descript_details_tl w
     WHERE description_detail_id IN
           (SELECT description_detail_id
              FROM xla_descript_details_b d
                 , xla_desc_priorities    w
                 , xla_desc_priorities    s
             WHERE d.description_prio_id   = w.description_prio_id
               AND s.application_id        = g_application_id
               AND s.amb_context_code      = g_staging_context_code
               AND s.application_id        = g_application_id
               AND s.amb_context_code      = g_amb_context_code
               AND w.description_type_code = s.description_type_code
               AND w.description_code      = s.description_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_descript_details_tl delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

  END IF;

  -- Move the descriptions from staging area to working area
  UPDATE xla_descriptions_b
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_descriptions_b updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_descriptions_tl w
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code
     AND NOT EXISTS (SELECT 1
                       FROM xla_descriptions_tl s
                      WHERE s.application_id        = g_application_id
                        AND s.amb_context_code      = g_amb_context_code
                        AND s.description_type_code = w.description_type_code
                        AND s.name                  = w.name
                        AND s.language              = w.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_descriptions_tl 1 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_descriptions_tl w
     SET amb_context_code  = g_amb_context_code
       , name              = substr('('||w.description_code||') '||name,1,80)
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code
     AND EXISTS (SELECT 1
                   FROM xla_descriptions_tl s
                  WHERE s.application_id        = g_application_id
                    AND s.amb_context_code      = g_amb_context_code
                    AND s.description_type_code = w.description_type_code
                    AND s.name                  = w.name
                    AND s.language              = w.language);


  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_descriptions_tl 2 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_desc_priorities
     SET amb_context_code  = g_amb_context_code
   WHERE application_id    = g_application_id
     AND amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_desc_priorities updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_conditions
     SET amb_context_code    = g_amb_context_code
   WHERE amb_context_code    = g_staging_context_code
     AND application_id      = g_application_id
     AND description_prio_id IS NOT NULL;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_conditions updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_descript_details_b
     SET amb_context_code  = g_amb_context_code
   WHERE amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_descript_details_b updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_descript_details_tl
     SET amb_context_code  = g_amb_context_code
   WHERE amb_context_code  = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_descript_details_tl updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure merge_descriptions',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.merge_descriptions'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END merge_descriptions;


--=============================================================================
--
-- Name: merge_analytical_criteria
-- Description: Merge analytical criteria from staging to working area
-- Changes:
-- 8230704 and 7692291 Simran: overriding the changes done as part of bug 7243326
--=============================================================================
PROCEDURE merge_analytical_criteria
IS
 -- Retrieve the AC to be merged
  CURSOR c_ac IS
    SELECT s.analytical_criterion_type_code, s.analytical_criterion_code
      FROM xla_analytical_hdrs_b s
         , xla_analytical_hdrs_b w
     WHERE s.amb_context_code               = g_staging_context_code
       AND w.amb_context_code(+)            = g_amb_context_code
       AND s.analytical_criterion_type_code = w.analytical_criterion_type_code(+)
       AND s.analytical_criterion_code      = w.analytical_criterion_code(+)
       AND s.version_num                    >= w.version_num(+);

    -- Added cursor for DTLs as part of bug 7243326 - This is mainly for AR where AR does not have a HDR and following DELETES and UPDATES dont loop

    CURSOR c_ac_dtls IS
    SELECT s.analytical_criterion_type_code, s.analytical_criterion_code,s.ANALYTICAL_DETAIL_CODE
      FROM xla_analytical_dtls_b s
         , xla_analytical_dtls_b w
     WHERE s.amb_context_code               = g_staging_context_code
       AND w.amb_context_code(+)            = g_amb_context_code
       AND s.analytical_criterion_type_code = w.analytical_criterion_type_code(+)
       AND s.analytical_criterion_code      = w.analytical_criterion_code(+)
       AND s.ANALYTICAL_DETAIL_CODE         = w.ANALYTICAL_DETAIL_CODE(+) ;

    CURSOR c_ac_src IS
    SELECT s.analytical_criterion_type_code, s.analytical_criterion_code,s.ANALYTICAL_DETAIL_CODE,
    s.event_class_code,s.entity_code,s.source_code,s.source_type_code
      FROM xla_analytical_sources s
         , xla_analytical_sources w
     WHERE s.amb_context_code               = g_staging_context_code
       AND w.amb_context_code(+)            = g_amb_context_code
       AND s.analytical_criterion_type_code = w.analytical_criterion_type_code(+)
       AND s.analytical_criterion_code      = w.analytical_criterion_code(+)
       AND s.ANALYTICAL_DETAIL_CODE         = w.ANALYTICAL_DETAIL_CODE(+)
       AND s.event_class_code               = w.event_class_code(+)
       AND s.entity_code                    = w.entity_code(+)
       AND s.source_code                    = w.source_code(+)
       AND s.source_type_code               = w.source_type_code(+);


  l_ac_detail_code    t_array_varchar30;
  l_ac_dtl_type_codes t_array_varchar30;
  l_ac_dtl_codes      t_array_varchar30;
  l_ac_src_event_class     t_array_varchar30;
  l_ac_src_entity_code     t_array_varchar30;
  l_ac_src_source_code     t_array_varchar30;
  l_ac_src_source_type_code     t_array_varchar30;

  l_ac_type_codes t_array_varchar30;
  l_ac_codes      t_array_varchar30;
  l_log_module    VARCHAR2(240);
  l_num_rows      NUMBER;
  l_exception     VARCHAR2(240);
  l_excp_code     VARCHAR2(100);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.merge_analytical_criteria';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure merge_analytical_criteria',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

   /*************************************************/
   /**** Added by krsankar for Performance changes **/
   /*************************************************/

    INSERT INTO xla_aads_gt
      ( analytical_criterion_code,
        table_name
      )
    select analytical_criterion_code,
          'XLA_ANALYTICAL_HDRS_B'
    from
     (select analytical_criterion_code,
            'XLA_ANALYTICAL_HDRS_B',
             amb_context_code,
             last_update_date ,
             nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
      from
         (select analytical_criterion_code,
                 'XLA_ANALYTICAL_HDRS_B',
                 amb_context_code,
                 last_update_date ,
                 lag(last_update_date) over (PARTITION by application_id,
                                                          analytical_criterion_code,
                                                          analytical_criterion_type_code
                                             order by     amb_context_code
                                            ) lag_date
          from xla_analytical_hdrs_b
          order by amb_context_code
          ) x
      where x.amb_context_code = g_staging_context_code
      )
    where flag = 'False';


	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_analytical_hdrs_b is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
        END IF;


    INSERT INTO xla_aads_gt
      ( analytical_criterion_code,
        analytical_detail_code,
        table_name
      )
    select analytical_criterion_code,
           analytical_detail_code,
           'XLA_ANALYTICAL_DTLS_B'
    from
        (select analytical_criterion_code,
                analytical_detail_code,
	            'XLA_ANALYTICAL_DTLS_B',
                amb_context_code,
                last_update_date ,
                nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
        from
              (select analytical_criterion_code,
                      analytical_detail_code,
	                  'XLA_ANALYTICAL_DTLS_B',
                      amb_context_code,
                      last_update_date ,
                      lag(last_update_date) over (PARTITION by analytical_criterion_code,
                                                               analytical_criterion_type_code,
                                                               analytical_detail_code
                                                  order by     amb_context_code
                                                  ) lag_date
               from xla_analytical_dtls_b
               order by amb_context_code
               ) x
        where x.amb_context_code = g_staging_context_code
        )
    where flag = 'False';


	  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_analytical_dtls_b is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
          END IF;

    INSERT INTO xla_aads_gt
       ( analytical_criterion_code,
         analytical_detail_code,
         entity_code,
         event_class_code,
         source_code,
         table_name
        )
    select   analytical_criterion_code,
             analytical_detail_code,
             entity_code,
             event_class_code,
             source_code,
             'XLA_ANALYTICAL_SOURCES'
    from
         (select analytical_criterion_code,
                 analytical_detail_code,
                 entity_code,
                 event_class_code,
                 source_code,
                 'XLA_ANALYTICAL_SOURCES',
                 amb_context_code,
                 last_update_date ,
                 nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
          from
              (select analytical_criterion_code,
                      analytical_detail_code,
                      entity_code,
                      event_class_code,
                      source_code,
	                  'XLA_ANALYTICAL_SOURCES',
                      amb_context_code,
                      last_update_date ,
                      lag(last_update_date) over (PARTITION by application_id,
                                                               analytical_criterion_code,
                                                               analytical_criterion_type_code,
                                                               analytical_detail_code,
                                                               entity_code,
                                                               event_class_code,
                                                               source_code,
							       source_type_code
                                                  order by     amb_context_code
                                                  ) lag_date
               from xla_analytical_sources
               order by amb_context_code
               ) x
          where x.amb_context_code = g_staging_context_code
          )
    where flag = 'False';




	   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_analytical_sources is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
           END IF;


  IF (g_analyzed_flag = 'Y') THEN
    null;

  ELSE

  /* 8230704 and 7692291: all the 3 tables are independant of each other. AR ldt wouldnt load any header as all headers
  r right now with 200 application_id. But AR ldt would load details and would load all sources.
  Need to keep sources separate, as the delete should remove only those sources that r in the ldt NOT sources that
  belong to a header/dtl loaded.
  */

    OPEN c_ac;
    FETCH c_ac BULK COLLECT INTO l_ac_type_codes, l_ac_codes;
    CLOSE c_ac;

    OPEN c_ac_dtls ;
    FETCH c_ac_dtls BULK COLLECT INTO l_ac_dtl_type_codes, l_ac_dtl_codes, l_ac_detail_code;
    CLOSE c_ac_dtls ;

    OPEN c_ac_src ;
    FETCH c_ac_src BULK COLLECT INTO l_ac_dtl_type_codes, l_ac_dtl_codes,
    l_ac_detail_code, l_ac_src_event_class,l_ac_src_entity_code,
    l_ac_src_source_code,l_ac_src_source_type_code;
    CLOSE c_ac_src ;

    -- Delete the ACs from the working area for the AC to be merged
    FORALL i IN 1..l_ac_codes.COUNT
      DELETE FROM xla_analytical_hdrs_b w
       WHERE amb_context_code                = g_amb_context_code
         AND analytical_criterion_type_code = l_ac_type_codes(i)
         AND analytical_criterion_code      = l_ac_codes(i)
	 AND EXISTS
	 ( SELECT 1
	   FROM xla_analytical_hdrs_b s
           WHERE s.amb_context_code                = g_staging_context_code
           AND   s.analytical_criterion_type_code  = w.analytical_criterion_type_code
           AND   s.analytical_criterion_code       = w.analytical_criterion_code );

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_analytical_hdrs_b delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1..l_ac_codes.COUNT
       DELETE FROM xla_analytical_hdrs_tl w
       WHERE amb_context_code                = g_amb_context_code
         AND analytical_criterion_type_code = l_ac_type_codes(i)
         AND analytical_criterion_code      = l_ac_codes(i)
	 AND EXISTS
	 ( SELECT 1
	   FROM xla_analytical_hdrs_tl s
           WHERE s.amb_context_code                = g_staging_context_code
           AND   s.analytical_criterion_type_code  = w.analytical_criterion_type_code
           AND   s.analytical_criterion_code       = w.analytical_criterion_code
	   AND   s.language              = w.language);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_analytical_hdrs_tl delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      END IF;

   -- Delete the AC dtlss from the working area for the AC dtls to be merged
    FORALL i IN 1..l_ac_dtl_codes.COUNT
    DELETE FROM xla_analytical_dtls_b w
     WHERE amb_context_code                 = g_amb_context_code
         AND analytical_criterion_type_code = l_ac_dtl_type_codes(i)
         AND analytical_criterion_code      = l_ac_dtl_codes(i)
	 AND analytical_detail_code         = l_ac_detail_code(i)
	 AND EXISTS
	 ( SELECT 1
	   FROM xla_analytical_dtls_b s
           WHERE s.amb_context_code                = g_staging_context_code
           AND   s.analytical_criterion_type_code  = w.analytical_criterion_type_code
           AND   s.analytical_criterion_code       = w.analytical_criterion_code
	   AND   s.analytical_detail_code          = w.analytical_detail_code);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_analytical_dtls_b delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1..l_ac_dtl_codes.COUNT
    DELETE FROM xla_analytical_dtls_tl w
     WHERE amb_context_code                = g_amb_context_code
         AND analytical_criterion_type_code = l_ac_dtl_type_codes(i)
         AND analytical_criterion_code      = l_ac_dtl_codes(i)
         AND analytical_detail_code         = l_ac_detail_code(i)
	 AND EXISTS
	 ( SELECT 1
	   FROM xla_analytical_dtls_tl s
           WHERE s.amb_context_code                = g_staging_context_code
           AND   s.analytical_criterion_type_code  = w.analytical_criterion_type_code
           AND   s.analytical_criterion_code       = w.analytical_criterion_code
	   AND   s.analytical_detail_code          = w.analytical_detail_code
	   AND   s.language              = w.language);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_analytical_dtls_tl delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1..l_ac_src_event_class.COUNT
    DELETE FROM xla_analytical_sources w
     WHERE amb_context_code                = g_amb_context_code
         AND analytical_criterion_type_code = l_ac_dtl_type_codes(i)
         AND analytical_criterion_code      = l_ac_dtl_codes(i)
	 AND analytical_detail_code         = l_ac_detail_code(i) -- Added for bug 8268819
	 AND event_class_code =l_ac_src_event_class(i)
         AND ENTITY_CODE =l_ac_src_entity_code(i)
	 AND SOURCE_CODE =l_ac_src_source_code(i)
	 AND SOURCE_TYPE_CODE =l_ac_src_source_type_code(i)
	 AND EXISTS
	 ( SELECT 1
	   FROM xla_analytical_sources s
           WHERE s.amb_context_code                = g_staging_context_code
           AND   s.analytical_criterion_type_code  = w.analytical_criterion_type_code
           AND   s.analytical_criterion_code       = w.analytical_criterion_code
	   AND   s.analytical_detail_code          = w.analytical_detail_code  -- Added for bug 8268819
	   AND   s.entity_code                     = w.entity_code
	   AND   s.event_class_code                = w.event_class_code
	   AND   s.source_code                     = w.source_code
	   AND   s.source_type_code                = w.source_type_code);
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_analytical_sources delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
       END IF;

  END IF;

  -- Move the analytical criteria from staging area to working area
  FORALL i IN 1..l_ac_codes.COUNT
  UPDATE xla_analytical_hdrs_b
     SET amb_context_code               = g_amb_context_code
   WHERE amb_context_code               = g_staging_context_code
     AND analytical_criterion_type_code = l_ac_type_codes(i)
     AND analytical_criterion_code      = l_ac_codes(i);


  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_hdrs_b updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_ac_codes.COUNT
  UPDATE xla_analytical_hdrs_tl s
     SET amb_context_code               = g_amb_context_code
   WHERE amb_context_code               = g_staging_context_code
     AND analytical_criterion_type_code = l_ac_type_codes(i)
     AND analytical_criterion_code      = l_ac_codes(i)
     AND NOT EXISTS (SELECT 1
                       FROM xla_analytical_hdrs_tl w
                      WHERE w.amb_context_code               = g_amb_context_code
                        AND w.analytical_criterion_type_code = s.analytical_criterion_type_code
                        AND w.name                           = s.name
                        AND w.language                       = s.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_hdrs_tl 1 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_ac_codes.COUNT
  UPDATE xla_analytical_hdrs_tl s
     SET amb_context_code               = g_amb_context_code
       , name                           = substr('('||s.analytical_criterion_code||') '||name,1,80)
   WHERE amb_context_code               = g_staging_context_code
     AND analytical_criterion_type_code = l_ac_type_codes(i)
     AND analytical_criterion_code      = l_ac_codes(i)
     AND EXISTS (SELECT 1
                   FROM xla_analytical_hdrs_tl w
                  WHERE w.amb_context_code               = g_amb_context_code
                    AND w.analytical_criterion_type_code = s.analytical_criterion_type_code
                    AND w.name                           = s.name
                    AND w.language                       = s.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_hdrs_tl 2 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_ac_dtl_codes.COUNT
  UPDATE xla_analytical_dtls_b
     SET amb_context_code  = g_amb_context_code
   WHERE amb_context_code  = g_staging_context_code
     AND analytical_criterion_type_code = l_ac_dtl_type_codes(i)
     AND analytical_criterion_code      = l_ac_dtl_codes(i)
     AND analytical_detail_code         = l_ac_detail_code(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_dtls_b updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_ac_dtl_codes.COUNT
  UPDATE xla_analytical_dtls_tl s
     SET amb_context_code  = g_amb_context_code
   WHERE amb_context_code  = g_staging_context_code
     AND analytical_criterion_type_code = l_ac_dtl_type_codes(i)
     AND analytical_criterion_code      = l_ac_dtl_codes(i)
     AND analytical_detail_code         = l_ac_detail_code(i)
     AND NOT EXISTS (SELECT 1
                       FROM xla_analytical_dtls_tl w
                      WHERE w.amb_context_code               = g_amb_context_code
                        AND   w.analytical_criterion_type_code  = s.analytical_criterion_type_code
			AND   s.analytical_criterion_code       = s.analytical_criterion_code
			AND   s.analytical_detail_code          = s.analytical_detail_code
                        AND w.name                           = s.name
                        AND w.language                       = s.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_dtls_tl 1 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_ac_dtl_codes.COUNT
  UPDATE xla_analytical_dtls_tl w
     SET amb_context_code  = g_amb_context_code
       , name              = substr('('||w.analytical_detail_code||') '||name,1,80)
   WHERE amb_context_code  = g_staging_context_code
     AND analytical_criterion_type_code = l_ac_dtl_type_codes(i)
     AND analytical_criterion_code      = l_ac_dtl_codes(i)
     AND analytical_detail_code         = l_ac_detail_code(i)
     AND EXISTS (SELECT 1
                   FROM xla_analytical_dtls_tl s
                  WHERE s.amb_context_code               = g_amb_context_code
                    AND   w.analytical_criterion_type_code  = s.analytical_criterion_type_code
		    AND   s.analytical_criterion_code       = s.analytical_criterion_code
		    AND   s.analytical_detail_code          = s.analytical_detail_code
                    AND s.name                           = w.name
                    AND s.language                       = w.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_dtls_tl 2 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i IN 1..l_ac_src_event_class.COUNT
  UPDATE xla_analytical_sources
     SET amb_context_code  = g_amb_context_code
   WHERE amb_context_code  = g_staging_context_code
     AND analytical_criterion_type_code = l_ac_dtl_type_codes(i)
     AND analytical_criterion_code      = l_ac_dtl_codes(i)
     AND analytical_detail_code         = l_ac_detail_code(i) -- Added for bug 8268819
     AND event_class_code =l_ac_src_event_class(i)
     AND ENTITY_CODE =l_ac_src_entity_code(i)
     AND SOURCE_CODE =l_ac_src_source_code(i)
     AND SOURCE_TYPE_CODE =l_ac_src_source_type_code(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_sources updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure merge_analytical_criteria',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'In exception of xla_aad_merge_pvt.merge_analytical_criteria',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Error in merge_analytical_criteria is : '||l_excp_code||' - '||l_exception,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

 xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.merge_analytical_criteria'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');

 RAISE;

END merge_analytical_criteria;


--=============================================================================
--
-- Name: merge_adrs
-- Description: Merge ADRs from staging to working area
--
--=============================================================================
PROCEDURE merge_adrs
IS
  CURSOR c_adr IS
    SELECT s.segment_rule_type_code, s.segment_rule_code
      FROM xla_seg_rules_b w
         , xla_seg_rules_b s
     WHERE s.application_id         = g_application_id
       AND s.amb_context_code       = g_staging_context_code
       AND s.segment_rule_type_code = w.segment_rule_type_code
       AND s.segment_rule_code      = w.segment_rule_code
       AND w.application_id         = g_application_id
       AND w.amb_context_code       = g_amb_context_code;

  l_adr_type_codes t_array_varchar30;
  l_adr_codes      t_array_varchar30;
  l_log_module     VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.merge_adrs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure merge_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  /*************************************************/
  /**** Added by krsankar for Performance changes **/
  /*************************************************/

    INSERT INTO xla_aads_gt
      ( segment_rule_code,
        table_name
      )
    select segment_rule_code,
       'XLA_SEG_RULE_DETAILS'
    from
      (select segment_rule_code,
              'XLA_SEG_RULE_DETAILS',
              amb_context_code,
              last_update_date ,
              nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
       from
          (select segment_rule_code,
                  'XLA_SEG_RULE_DETAILS',
                  amb_context_code,
                  last_update_date ,
                  lag(last_update_date) over (PARTITION by application_id,
                                                           segment_rule_code,
                                                           segment_rule_type_code,
                                                           user_sequence
                                              order by     amb_context_code
                                              ) lag_date
           from xla_seg_rule_details
           order by amb_context_code
           ) x
       where x.amb_context_code = g_staging_context_code
       )
    where flag = 'False';



	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_seg_rule_details is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
         END IF;


    INSERT INTO xla_aads_gt
      ( segment_rule_code,
        table_name
      )
    select  segment_rule_code,
            'XLA_SEG_RULES_B'
    from
      (select  segment_rule_code,
              'XLA_SEG_RULES_B',
               amb_context_code,
               last_update_date ,
               nvl2(lag_date, decode(last_update_date,lag_date, 'True','False'),'False') flag
       from
           (select segment_rule_code,
                   'XLA_SEG_RULES_B',
                   amb_context_code,
                   last_update_date ,
                   lag(last_update_date) over (PARTITION by application_id,
                                                            segment_rule_code,
                                                            segment_rule_type_code
                                               order by     amb_context_code
                                               ) lag_date
            from xla_seg_rules_b
            order by amb_context_code
            ) x
       where x.amb_context_code = g_staging_context_code
       )
    where flag = 'False';

	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows inserted into aads_gt from xla_seg_rules_b is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
        END IF;


  IF (g_analyzed_flag = 'Y') THEN
    null;

  ELSE

    OPEN c_adr;
    FETCH c_adr BULK COLLECT INTO l_adr_type_codes, l_adr_codes;
    CLOSE c_adr;

    IF (l_adr_codes.COUNT > 0) THEN
    -- Delete the ADRs from the working area to be merged
    FORALL i IN 1..l_adr_codes.COUNT
      DELETE FROM xla_conditions c
       WHERE amb_context_code        = g_amb_context_code
         AND application_id          = g_application_id
         AND EXISTS (SELECT 1
                       FROM xla_seg_rule_details w
                      WHERE c.segment_rule_detail_id = w.segment_rule_detail_id
                        AND w.application_id         = g_application_id
                        AND w.amb_context_code       = g_amb_context_code
                        AND w.segment_rule_type_code = l_adr_type_codes(i)
                        AND w.segment_rule_code      = l_adr_codes(i));

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_conditions delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1..l_adr_codes.COUNT
      DELETE FROM xla_seg_rule_details w
       WHERE amb_context_code        = g_amb_context_code
         AND application_id          = g_application_id
         AND segment_rule_type_code  = l_adr_type_codes(i)
         AND segment_rule_code       = l_adr_codes(i);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_seg_rule_details delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1..l_adr_codes.COUNT
      DELETE FROM xla_seg_rules_tl w
       WHERE amb_context_code        = g_amb_context_code
         AND application_id          = g_application_id
         AND segment_rule_type_code  = l_adr_type_codes(i)
         AND segment_rule_code       = l_adr_codes(i);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_seg_rules_tl delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1..l_adr_codes.COUNT
      DELETE FROM xla_seg_rules_b w
       WHERE amb_context_code        = g_amb_context_code
         AND application_id          = g_application_id
         AND segment_rule_type_code  = l_adr_type_codes(i)
         AND segment_rule_code       = l_adr_codes(i);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_seg_rules_b delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    END IF;

  END IF;

  -- Move the ADRs from staging area to working area
  UPDATE xla_seg_rules_b
     SET amb_context_code  = g_amb_context_code
   WHERE amb_context_code  = g_staging_context_code
     AND application_id    = g_application_id;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rules_b updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_seg_rules_tl w
     SET amb_context_code  = g_amb_context_code
   WHERE amb_context_code  = g_staging_context_code
     AND application_id    = g_application_id
     AND NOT EXISTS (SELECT 1
                       FROM xla_seg_rules_tl s
                      WHERE s.amb_context_code       = g_amb_context_code
                        AND s.segment_rule_type_code = w.segment_rule_type_code
                        AND s.name                   = w.name
                        AND s.language               = w.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rules_tl 1 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_seg_rules_tl w
     SET amb_context_code  = g_amb_context_code
       , name              = substr('('||w.segment_rule_code||') '||name,1,80)
   WHERE amb_context_code  = g_staging_context_code
     AND application_id    = g_application_id
     AND EXISTS (SELECT 1
                   FROM xla_seg_rules_tl s
                  WHERE s.amb_context_code       = g_amb_context_code
                    AND s.segment_rule_type_code = w.segment_rule_type_code
                    AND s.name                   = w.name
                    AND s.language               = w.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rules_tl 1 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_seg_rule_details
     SET amb_context_code  = g_amb_context_code
   WHERE amb_context_code  = g_staging_context_code
     AND application_id    = g_application_id;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rule_details updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_conditions
     SET amb_context_code       = g_amb_context_code
   WHERE amb_context_code       = g_staging_context_code
     AND application_id         = g_application_id
     AND segment_rule_detail_id IS NOT NULL;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_conditions updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure merge_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.merge_adrs'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END merge_adrs;


--=============================================================================
--
-- Name: merge_mapping_sets
-- Description: Merge mapping sets from staging area to the working area
--              if the version number of the one in the staging area is higher
--              or equal to the one in the working area
--
--=============================================================================
PROCEDURE merge_mapping_sets
IS
  -- Retrieve the mapping sets to be merged
  CURSOR c_ms IS
    SELECT s.mapping_set_code
      FROM xla_mapping_sets_b s
         , xla_mapping_sets_b w
     WHERE s.amb_context_code    = g_staging_context_code
       AND w.amb_context_code(+) = g_amb_context_code
       AND s.mapping_set_code    = w.mapping_set_code(+)
       AND s.version_num        >= w.version_num(+);

  l_ms                     t_array_varchar30;
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.merge_mapping_sets';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure merge_mapping_sets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;



  IF (g_analyzed_flag = 'Y') THEN
    null;

  ELSE

    OPEN c_ms;
    FETCH c_ms BULK COLLECT INTO l_ms;
    CLOSE c_ms;

    -- Delete the MSs from the working area to be merged
    FORALL i in 1 .. l_ms.count
    DELETE FROM xla_mapping_sets_b w
     WHERE amb_context_code       = g_amb_context_code
       AND mapping_set_code       = l_ms(i);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_mapping_sets_b delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i in 1 .. l_ms.count
    DELETE FROM xla_mapping_sets_tl w
     WHERE amb_context_code       = g_amb_context_code
       AND mapping_set_code       = l_ms(i)
       AND EXISTS (SELECT 1
                     FROM xla_mapping_sets_tl s
                    WHERE s.amb_context_code      = g_staging_context_code
                      AND s.mapping_set_code      = w.mapping_set_code
                      AND s.language              = w.language);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_mapping_sets_tl delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i in 1 .. l_ms.count
    DELETE FROM xla_mapping_set_values w
     WHERE amb_context_code       = g_amb_context_code
       AND mapping_set_code       = l_ms(i);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# xla_mapping_set_values delete : '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

  END IF;

  -- Move the mapping sets from staging area to working area
  FORALL i in 1 .. l_ms.count
  UPDATE xla_mapping_sets_b
     SET amb_context_code  = g_amb_context_code
   WHERE amb_context_code  = g_staging_context_code
     AND mapping_set_code  = l_ms(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mapping_sets_b updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i in 1 .. l_ms.count
  UPDATE xla_mapping_sets_tl s
     SET amb_context_code  = g_amb_context_code
   WHERE amb_context_code  = g_staging_context_code
     AND mapping_set_code  = l_ms(i)
     AND NOT EXISTS (SELECT 1
                       FROM xla_mapping_sets_tl w
                      WHERE w.amb_context_code       = g_amb_context_code
                        AND w.name                   = s.name
                        AND w.language               = s.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mapping_sets_tl 1 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i in 1 .. l_ms.count
  UPDATE xla_mapping_sets_tl s
     SET amb_context_code  = g_amb_context_code
       , name              = substr('('||s.mapping_set_code||') '||name,1,80)
   WHERE amb_context_code  = g_staging_context_code
     AND mapping_set_code  = l_ms(i)
     AND EXISTS (SELECT 1
                   FROM xla_mapping_sets_tl w
                  WHERE w.amb_context_code       = g_amb_context_code
                    AND w.name                   = s.name
                    AND w.language               = s.language);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mapping_sets_tl 2 updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FORALL i in 1 .. l_ms.count
  UPDATE xla_mapping_set_values
     SET amb_context_code  = g_amb_context_code
   WHERE amb_context_code  = g_staging_context_code
     AND mapping_set_code  = l_ms(i);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mapping_set_values updated : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure merge_mapping_sets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.merge_mapping_sets'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END merge_mapping_sets;


--=============================================================================
--
-- Bug 4685287 addition.
-- Name: merge_acctg_methods
-- Description: This API copies the accounting methods from the staging to the
--              working area if not already exists.  Then it moves the
--              accounting method rules from the staging to the working area
--              if no other accounting method rules have been assigned to the
--              method for the application and destination context.
--
--=============================================================================
PROCEDURE merge_acctg_methods
IS
  l_log_module    VARCHAR2(240);
  v_count         NUMBER;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.merge_acctg_methods';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure merge_acctg_methods',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  INSERT INTO xla_acctg_methods_b
     (accounting_method_type_code
     ,accounting_method_code
     ,transaction_coa_id
     ,accounting_coa_id
     ,enabled_flag
     ,creation_date
     ,created_by
     ,last_update_date
     ,last_updated_by
     ,last_update_login)
     SELECT s.accounting_method_type_code
           ,s.accounting_method_code
           ,s.transaction_coa_id
           ,s.accounting_coa_id
           ,s.enabled_flag
           ,sysdate
           ,xla_environment_pkg.g_usr_id
           ,sysdate
           ,xla_environment_pkg.g_usr_id
           ,xla_environment_pkg.g_login_id
       FROM xla_stage_acctg_methods s
            LEFT OUTER JOIN xla_acctg_methods_b w
            ON  w.accounting_method_type_code = s.accounting_method_type_code
            AND w.accounting_method_code      = s.accounting_method_code
      WHERE s.staging_amb_context_code        = g_staging_context_code
        AND w.accounting_method_type_code     IS NULL;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace(p_msg    => '# row inserted in xla_acctg_methods_b = '||SQL%ROWCOUNT,
           p_module => l_log_module,
           p_level  => C_LEVEL_STATEMENT);
  END IF;

  INSERT INTO xla_acctg_methods_tl
     (accounting_method_type_code
     ,accounting_method_code
     ,language
     ,name
     ,description
     ,source_lang
     ,creation_date
     ,created_by
     ,last_update_date
     ,last_updated_by
     ,last_update_login)
     SELECT s.accounting_method_type_code
           ,s.accounting_method_code
           ,fl.language_code
           ,s.name
           ,s.description
           ,USERENV('LANG')
           ,sysdate
           ,xla_environment_pkg.g_usr_id
           ,sysdate
           ,xla_environment_pkg.g_usr_id
           ,xla_environment_pkg.g_login_id
      FROM xla_stage_acctg_methods s
           JOIN fnd_languages fl
           ON  fl.installed_flag                IN ('I', 'B')
           LEFT OUTER JOIN xla_acctg_methods_tl w
           ON  w.accounting_method_type_code = s.accounting_method_type_code
           AND w.accounting_method_code      = s.accounting_method_code
           AND w.language                    = fl.language_code
     WHERE s.staging_amb_context_code        = g_staging_context_code
       AND w.accounting_method_type_code     IS NULL;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace(p_msg    => '# row inserted in xla_acctg_methods_tl = '||SQL%ROWCOUNT,
           p_module => l_log_module,
           p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_acctg_method_rules xamr
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code
     AND NOT EXISTS (SELECT 1
                       FROM xla_acctg_method_rules xamr2
                      WHERE xamr2.amb_context_code            = g_amb_context_code
                        AND xamr2.accounting_method_type_code = xamr.accounting_method_type_code
                        AND xamr2.accounting_method_code      = xamr.accounting_method_code
                        AND xamr2.application_id              = g_application_id);

  INSERT INTO xla_aad_loader_logs
    (aad_loader_log_id
    ,amb_context_code
    ,application_id
    ,request_code
    ,log_type_code
    ,encoded_message
    ,aad_application_id
    ,product_rule_code
    ,product_rule_type_code
    ,component_owner_code
    ,component_code
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
          ,g_amb_context_code
          ,g_application_id
          ,'IMPORT'
          ,'UNMERGE_AAD_IN_SLAM'
	  ,'Rows inserted in xla_acctg_methods_b for staging context code : '||g_staging_context_code||
	    ', ' ||'application_id : '||g_application_id||' is : '||v_count
          ,g_application_id
          ,product_rule_code
          ,product_rule_type_code
          ,accounting_method_type_code
          ,accounting_method_code
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
     FROM (SELECT distinct product_rule_type_code
                         , product_rule_code
                         , accounting_method_type_code
                         , accounting_method_code
             FROM xla_acctg_method_rules
            WHERE amb_context_code = g_staging_context_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row inserted in xla_acctg_method_rules = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure merge_acctg_methods',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.merge_acctg_methods'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END merge_acctg_methods;


--=============================================================================
--
-- Name: merge_aads_and_setups
-- Description: This API merge the AADs and journal entry setups
--
--=============================================================================
PROCEDURE merge_aads_and_setups
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.merge_aads_and_setups';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure merge_aads_and_setups',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_analyzed_flag = 'Y') THEN
    null;
/*
    duplicate_journal_line_defns;
    duplicate_journal_line_types;
    duplicate_descriptions;
    duplicate_analytical_criteria;
    duplicate_mapping_sets;
    duplicate_adrs;
*/
  END IF;

  IF (g_user_type_code = 'C') THEN
    clean_oracle_components;
  END IF;

  -- Merge AADs and journal entry setups
  merge_aads;
  merge_journal_line_defns;
  merge_journal_line_types;
  merge_descriptions;
  merge_analytical_criteria;
  merge_mapping_sets;
  merge_adrs;
  merge_acctg_methods;     -- Bug 4685287 addition.

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure merge_aads_and_setups',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.merge_aads_and_setups'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'Unhandled exception');
  RAISE;

END merge_aads_and_setups;


--=============================================================================
--
-- Name: purge_mapping_sets
-- Description:
--
--=============================================================================
PROCEDURE purge_mapping_sets
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.purge_mapping_sets';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure purge_mapping_sets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_mapping_set_values
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mapping_set_values delete : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_mapping_sets_tl
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mapping_sets_tl delete : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_mapping_sets_b
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_mapping_sets_b delete : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure purge_mapping_sets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.purge_mapping_sets'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END purge_mapping_sets;


--=============================================================================
--
-- Name: purge_analytical_criteria
-- Description:
--
--=============================================================================
PROCEDURE purge_analytical_criteria
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.purge_analytical_criteria';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure purge_analytical_criteria',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_analytical_sources
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_sources delete : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_analytical_dtls_tl
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_dtls_tl delete : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_analytical_dtls_b
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_dtls_b delete : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_analytical_hdrs_tl
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_hdrs_tl delete : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_analytical_hdrs_b
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_hdrs_b delete : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure purge_analytical_criteria',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.purge_analytical_criteria'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END purge_analytical_criteria;


--=============================================================================
--
-- Name: purge_adrs
-- Description:
--
--=============================================================================
PROCEDURE purge_adrs
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.purge_adrs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure purge_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_conditions
   WHERE amb_context_code       = g_staging_context_code
     AND segment_rule_detail_id IS NOT NULl;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_conditions delete : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_seg_rule_details
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rules_details delete : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_seg_rules_tl
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rules_tl delete : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_seg_rules_b
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rules_b delete : '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure purge_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.purge_adrs'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END purge_adrs;


--=============================================================================
--
-- Name: purge_staging_area
-- Description:
--
--=============================================================================
PROCEDURE purge_staging_area
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.purge_staging_area';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure purge_staging_area',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.purge
              (p_application_id   => g_application_id
              ,p_amb_context_code => g_staging_context_code);

  purge_mapping_sets;
  purge_analytical_criteria;
  purge_adrs;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure purge_staging_area',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.purge_staging_area'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END purge_staging_area;


--=============================================================================
--
-- Name: template_api
-- Description:
--
--=============================================================================
PROCEDURE template_api
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.template_api';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure template_api',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure template_api',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.template_api'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END template_api;



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

PROCEDURE merge
(p_api_version        IN NUMBER
,x_return_status      IN OUT NOCOPY VARCHAR2
,p_application_id     IN INTEGER
,p_amb_context_code   IN VARCHAR2
,p_analyzed_flag      IN VARCHAR2
,p_compile_flag       IN VARCHAR2
,x_merge_status       IN OUT NOCOPY VARCHAR2)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'merge';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_staging_context_code VARCHAR2(30);
  l_retcode              VARCHAR2(30);
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.merge';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function merge: '||
                      'p_application_id = '||p_application_id||
                      ', p_amb_context_code = '||p_amb_context_code||
                      ', p_analyzed_flag = '||p_analyzed_flag||
                      ', p_compile_flag = '||p_compile_flag,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_staging_context_code := xla_aad_loader_util_pvt.get_staging_context_code
                                (p_application_id   => p_application_id
                                ,p_amb_context_code => p_amb_context_code);

  xla_aad_merge_pvt.merge
             (p_api_version          => p_api_version
             ,x_return_status        => x_return_status
             ,p_application_id       => p_application_id
             ,p_amb_context_code     => p_amb_context_code
             ,p_staging_context_code => l_staging_context_code
             ,p_analyzed_flag        => p_analyzed_flag
             ,p_compile_flag         => p_compile_flag
             ,x_merge_status         => x_merge_status);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function merge - Return value = '||x_merge_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN G_EXC_WARNING THEN
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  x_merge_status := 'ERROR';

WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  x_merge_status := 'ERROR';

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_merge_status := 'ERROR';

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_merge_status := 'ERROR';

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.merge'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');

  --RAISE;

END merge;


--=============================================================================
--
-- Name: merge
-- Description: This API merges the AADs and its components from the
--              staging area to the working area of an AMB context
--
--=============================================================================
PROCEDURE merge
(p_api_version          IN NUMBER
,x_return_status        IN OUT NOCOPY VARCHAR2
,p_application_id       IN INTEGER
,p_amb_context_code     IN VARCHAR2
,p_staging_context_code IN VARCHAR2
,p_analyzed_flag        IN VARCHAR2
,p_compile_flag         IN VARCHAR2
,x_merge_status         IN OUT NOCOPY VARCHAR2)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'merge';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_retcode           VARCHAR2(30);
  l_log_module        VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.merge';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function merge: '||
                      'p_application_id = '||p_application_id||
                      ', p_amb_context_code = '||p_amb_context_code||
                      ', p_analyzed_flag = '||p_analyzed_flag||
                      ', p_compile_flag = '||p_compile_flag,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Standard call to check for call compatibility.
  IF (NOT xla_aad_loader_util_pvt.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => C_DEFAULT_MODULE))
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --  Initialize global variables
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

  g_usr_id               := xla_environment_pkg.g_usr_id;
  g_login_id             := xla_environment_pkg.g_login_id;
  g_application_id       := p_application_id;
  g_amb_context_code     := p_amb_context_code;
  g_analyzed_flag        := p_analyzed_flag;
  g_compile_flag         := p_compile_flag;
  g_staging_context_code := p_staging_context_code;
  g_user_type_code       := NVL(fnd_profile.value('XLA_SETUP_USER_MODE'),'C');

  -- API Logic
  x_merge_status := pre_merge;
  IF (x_merge_status = 'WARNING') THEN
    RAISE G_EXC_WARNING;
  END IF;

  x_merge_status := validation;
  IF (x_merge_status = 'WARNING') THEN
    RAISE G_EXC_WARNING;
  END IF;

  merge_aads_and_setups;


  xla_aad_loader_util_pvt.merge_history
        (p_application_id       => g_application_id
        ,p_staging_context_code => g_staging_context_code);


  purge_staging_area;

  xla_aad_loader_util_pvt.rebuild_ac_views;

  IF (p_compile_flag = 'Y') THEN
    IF (NOT xla_aad_loader_util_pvt.compile
                        (p_application_id    => g_application_id
                        ,p_amb_context_code  => g_amb_context_code)) THEN
      RAISE G_EXC_WARNING;
    END IF;
  END IF;



  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function merge - Return value = '||x_merge_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN G_EXC_WARNING THEN
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  x_merge_status := 'ERROR';

WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  x_merge_status := 'ERROR';

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_merge_status := 'ERROR';

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_merge_status := 'ERROR';

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_pvt.merge'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');

  --RAISE;

END merge;

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

END xla_aad_merge_pvt;

/
