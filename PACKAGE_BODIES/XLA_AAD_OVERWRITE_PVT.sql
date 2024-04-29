--------------------------------------------------------
--  DDL for Package Body XLA_AAD_OVERWRITE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AAD_OVERWRITE_PVT" AS
/* $Header: xlaalovw.pkb 120.14 2006/06/28 19:36:32 wychan ship $ */

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------
TYPE t_array_varchar2 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- declaring global variables
------------------------------------------------------------------------------
g_amb_context_code     VARCHAR2(30);
g_staging_context_code VARCHAR2(30);
g_application_id       INTEGER;
g_force_flag           VARCHAR2(1);
g_ac_updated           BOOLEAN;

G_EXC_WARNING EXCEPTION;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_aad_overwrite_pvt';

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
    (p_location   => 'xla_aad_overwrite_pvt.trace');

END trace;


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================

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
RETURN VARCHAR2
IS
  CURSOR c_aad IS
    SELECT t.name
      FROM xla_product_rules_b  w
          ,xla_product_rules_b  s
          ,xla_product_rules_tl t
     WHERE s.version_num            < w.version_num
       AND t.language               = USERENV('LANG')
       AND t.application_id         = w.application_id
       AND t.amb_context_code       = w.amb_context_code
       AND t.product_rule_type_code = w.product_rule_type_code
       AND t.product_rule_code      = w.product_rule_code
       AND w.application_id         = s.application_id
       AND w.product_rule_type_code = s.product_rule_type_code
       AND w.product_rule_code      = s.product_rule_code
       AND w.amb_context_code       = g_amb_context_code
       AND s.application_id         = g_application_id
       AND s.amb_context_code       = g_staging_context_code;

  CURSOR c_ms IS
    SELECT t.name
      FROM xla_mapping_sets_b  w
          ,xla_mapping_sets_b  s
          ,xla_mapping_sets_tl t
     WHERE s.version_num            < w.version_num
       AND t.language               = USERENV('LANG')
       AND t.amb_context_code       = w.amb_context_code
       AND t.mapping_set_code       = w.mapping_set_code
       AND s.mapping_set_code       = w.mapping_set_code
       AND w.amb_context_code       = g_amb_context_code
       AND s.amb_context_code       = g_staging_context_code;

  CURSOR c_adr IS
    SELECT t.name
      FROM xla_seg_rules_b  w
          ,xla_seg_rules_b  s
          ,xla_seg_rules_tl t
     WHERE s.version_num            < w.version_num
       AND t.language               = USERENV('LANG')
       AND t.amb_context_code       = w.amb_context_code
       AND t.application_id         = w.application_id
       AND t.segment_rule_type_code = w.segment_rule_type_code
       AND t.segment_rule_code      = w.segment_rule_code
       AND s.application_id         = w.application_id
       AND s.segment_rule_type_code = w.segment_rule_type_code
       AND s.segment_rule_code      = w.segment_rule_code
       AND w.amb_context_code       = g_amb_context_code
       AND w.application_id         = g_application_id
       AND s.amb_context_code       = g_staging_context_code;

  CURSOR c_ac IS
    SELECT t.name
      FROM xla_analytical_hdrs_b  w
          ,xla_analytical_hdrs_b  s
          ,xla_analytical_hdrs_tl t
     WHERE s.version_num                    < w.version_num
       AND t.language                       = USERENV('LANG')
       AND t.amb_context_code               = w.amb_context_code
       AND t.analytical_criterion_type_code = w.analytical_criterion_type_code
       AND t.analytical_criterion_code      = w.analytical_criterion_code
       AND s.analytical_criterion_type_code = w.analytical_criterion_type_code
       AND s.analytical_criterion_code      = w.analytical_criterion_code
       AND w.amb_context_code               = g_amb_context_code
       AND s.amb_context_code               = g_staging_context_code;

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

  IF (g_force_flag <> 'Y') THEN
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'BEGIN LOOP - invalid AAD versions',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    FOR l_aad IN c_aad LOOP
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'LOOP - invalid AAD version: '||l_aad.name,
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      l_retcode := 'WARNING';
      xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_OVW_INV_AAD_VERS'
               ,p_token_1         => 'PROD_RULE_NAME'
               ,p_value_1         => l_aad.name);
    END LOOP;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'END LOOP - invalid AAD versions',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'BEGIN LOOP - invalid MS versions',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    FOR l_ms IN c_ms LOOP
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'LOOP - invalid MS version: '||l_ms.name,
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      l_retcode := 'WARNING';
      xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_OVW_INV_MS_VERS'
               ,p_token_1         => 'MAPPING_SET_NAME'
               ,p_value_1         => l_ms.name);
    END LOOP;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'END LOOP - invalid MS versions',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'BEGIN LOOP - invalid ADR versions',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    FOR l_adr IN c_adr LOOP
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'LOOP - invalid ADR version: '||l_adr.name,
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      l_retcode := 'WARNING';
      xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_OVW_INV_ADR_VERS'
               ,p_token_1         => 'SEGMENT_RULE_NAME'
               ,p_value_1         => l_adr.name);
    END LOOP;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'END LOOP - invalid ADR versions',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'BEGIN LOOP - invalid AC versions',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    FOR l_ac IN c_ac LOOP
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'LOOP - invalid AC version: '||l_ac.name,
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      l_retcode := 'WARNING';
      xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_OVW_INV_AC_VERS'
               ,p_token_1         => 'ANALYTICAL_CRITERION_NAME'
               ,p_value_1         => l_ac.name);
    END LOOP;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'END LOOP - invalid AC versions',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;
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
               ,p_value_1         => 'xla_aad_overwrite_pvt.validation'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END validation;


--=============================================================================
--
-- Name: record_log
-- Description: This API records the overwritten application accounting
--              definitions into the log table
--
--=============================================================================
PROCEDURE record_log
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
        ,g_amb_context_code
        ,g_application_id
        ,'IMPORT'
        ,'OVERWRITTEN_AAD'
        ,s.application_id
        ,s.product_rule_code
        ,s.product_rule_type_code
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
  WHERE s.application_id         = g_application_id
    AND s.amb_context_code       = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row inserted into xla_aad_loader_logs = '||SQL%ROWCOUNT,
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
               ,p_value_1         => 'xla_aad_overwrite_pvt.record_log'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END record_log;


--=============================================================================
--
-- Name: pre_overwrite
-- Description: This API prepares the environment for overwrite
--
--=============================================================================
FUNCTION pre_overwrite
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
    l_log_module := C_DEFAULT_MODULE||'.pre_overwrite';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function pre_overwrite',
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
                   (p_application_id   => g_application_id
                   ,p_amb_context_code => g_amb_context_code);

    IF (l_retcode <> 'SUCCESS') THEN
      xla_aad_loader_util_pvt.stack_error
        (p_appli_s_name  => 'XLA'
        ,p_msg_name      => 'XLA_AAD_OVW_LOCK_FAILED');
      l_retcode := 'WARNING';
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function pre_overwrite - Return value = '||l_retcode,
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
      trace(p_msg    => 'END of function pre_overwrite - Return value = '||l_retcode,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    xla_aad_loader_util_pvt.stack_error
          (p_appli_s_name  => 'XLA'
          ,p_msg_name      => 'XLA_AAD_OVW_LOCK_FAILED');

    RETURN l_retcode;
  ELSE
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_overwrite_pvt.pre_overwrite'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
    RAISE;
  END IF;

END pre_overwrite;


--=============================================================================
--
-- Name: purge_mapping_sets
-- Description: This API deletes the mapping sets from the working area
--              if it exists in the working area.
--
--=============================================================================
PROCEDURE purge_mapping_sets
IS
  CURSOR c_ms IS
    SELECT bs.mapping_set_code
          ,bw.version_num version_from
          ,bs.version_num version_to
      FROM xla_mapping_sets_b   bs
          ,xla_mapping_sets_b   bw
     WHERE bs.mapping_set_code    = bw.mapping_set_code
       AND bs.amb_context_code    = g_staging_context_code
       AND bw.amb_context_code    = g_amb_context_code;

  l_mapping_sets  xla_component_tbl_type;
  l_mapping_set   xla_component_rec_type;
  l_ms_codes      t_array_varchar2;
  i               INTEGER;

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

  i := 0;
  l_mapping_sets := xla_component_tbl_type();

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - retrieve mapping set',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_ms IN c_ms LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - mapping set = '||l_ms.mapping_set_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    i := i + 1;
    l_mapping_set := xla_component_rec_type
                              (NULL
                              ,l_ms.mapping_set_code
                              ,l_ms.version_from
                              ,l_ms.version_to);
    l_mapping_sets.extend;
    l_mapping_sets(i) := l_mapping_set;
    l_ms_codes(i) := l_ms.mapping_set_code;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - retrieve mapping set: # retrieve = '||i,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (i > 0) THEN
    INSERT INTO xla_aad_loader_logs
    (aad_loader_log_id
    ,amb_context_code
    ,application_id
    ,request_code
    ,log_type_code
    ,aad_application_id
    ,component_type_code
    ,component_code
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
        ,'MERGED_SETUP'
        ,d.application_id
        ,'AMB_MS'
        ,ms.component_code
        ,ms.version_from
        ,ms.version_to
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
    FROM xla_seg_rule_details     d
        ,TABLE(CAST(l_mapping_sets AS xla_component_tbl_type)) ms
   WHERE d.amb_context_code       = g_amb_context_code
     AND d.application_id        <> g_application_id
     AND d.value_mapping_set_code = ms.component_code;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row inserted into xla_aad_loader_logs = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1 .. l_ms_codes.COUNT
      DELETE FROM xla_mapping_set_values
       WHERE mapping_set_code = l_ms_codes(i)
         AND amb_context_code = g_amb_context_code;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row deleted into xla_mapping_set_values = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1 .. l_ms_codes.COUNT
      DELETE FROM xla_mapping_sets_tl
       WHERE mapping_set_code = l_ms_codes(i)
         AND amb_context_code = g_amb_context_code;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row deleted into xla_mapping_sets_tl = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1 .. l_ms_codes.COUNT
      DELETE FROM xla_mapping_sets_b
       WHERE mapping_set_code = l_ms_codes(i)
         AND amb_context_code = g_amb_context_code;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row deleted into xla_mapping_sets_b = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

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
               ,p_value_1         => 'xla_aad_overwrite_pvt.purge_mapping_sets'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END purge_mapping_sets;


--=============================================================================
--
-- Name: purge_analytical_criteria
-- Description: This API deletes the analytical criteria from the working area
--              if it exists in the working area.
--
--=============================================================================
PROCEDURE purge_analytical_criteria
IS
  CURSOR c_ac IS
    SELECT s.analytical_criterion_type_code
          ,s.analytical_criterion_code
          ,w.version_num version_from
          ,s.version_num version_to
      FROM xla_analytical_hdrs_b   s
          ,xla_analytical_hdrs_b   w
     WHERE s.analytical_criterion_type_code = w.analytical_criterion_type_code
       AND s.analytical_criterion_code      = w.analytical_criterion_code
       AND s.amb_context_code               = g_staging_context_code
       AND w.amb_context_code               = g_amb_context_code
     UNION
    SELECT w.analytical_criterion_type_code
          ,w.analytical_criterion_code
          ,NULL
          ,NULL
      FROM xla_analytical_hdrs_b   w
     WHERE w.application_id   = g_application_id
       AND w.amb_context_code = g_amb_context_code;

  l_analytical_criteria  xla_component_tbl_type;
  l_analytical_criterion xla_component_rec_type;
  l_ac_codes             t_array_varchar2;
  l_ac_type_codes        t_array_varchar2;
  i                      INTEGER;
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.purge_analytical_criteria';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure purge_analytical_criteria',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  i := 0;
  l_analytical_criteria := xla_component_tbl_type();

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - retrieve analytical criteria',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_ac IN c_ac LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - analytical criterion = '||
                        l_ac.analytical_criterion_type_code||','||
                        l_ac.analytical_criterion_code||','||
                        NVL(l_ac.version_from,'')||','||
                        NVL(l_ac.version_to,''),
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    i := i + 1;
    l_analytical_criterion := xla_component_rec_type
                                (l_ac.analytical_criterion_type_code
                                ,l_ac.analytical_criterion_code
                                ,l_ac.version_from
                                ,l_ac.version_to);
    l_analytical_criteria.extend;
    l_analytical_criteria(i) := l_analytical_criterion;

    l_ac_type_codes(i) := l_ac.analytical_criterion_type_code;
    l_ac_codes(i)      := l_ac.analytical_criterion_code;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - retrieve analytical criteria: # retrieve = '||i,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (i>0) THEN
    g_ac_updated := TRUE;

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
        ,'MERGED_SETUP'
        ,application_id
        ,'AMB_AC'
        ,analytical_criterion_type_code
        ,analytical_criterion_code
        ,version_from
        ,version_to
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
      FROM (SELECT a.application_id
                  ,a.analytical_criterion_type_code
                  ,a.analytical_criterion_code
                  ,ac.version_from
                  ,ac.version_to
              FROM xla_aad_header_ac_assgns    a
                  ,TABLE(CAST(l_analytical_criteria AS xla_component_tbl_type)) ac
             WHERE a.amb_context_code               = g_amb_context_code
               AND a.application_id                <> g_application_id
               AND a.analytical_criterion_type_code = ac.component_owner_code
               AND a.analytical_criterion_code      = ac.component_code
               AND ac.version_from                  IS NOT NULL
             UNION
            SELECT a.application_id
                  ,a.analytical_criterion_type_code
                  ,a.analytical_criterion_code
                  ,ac.version_from
                  ,ac.version_to
              FROM xla_line_defn_ac_assgns    a
                  ,TABLE(CAST(l_analytical_criteria AS xla_component_tbl_type)) ac
             WHERE a.amb_context_code               = g_amb_context_code
               AND a.application_id                <> g_application_id
               AND a.analytical_criterion_type_code = ac.component_owner_code
               AND a.analytical_criterion_code      = ac.component_code
               AND ac.version_from                  IS NOT NULL);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row insert into xla_aad_loader_logs = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1 .. l_ac_codes.COUNT
      DELETE FROM xla_analytical_sources
       WHERE analytical_criterion_type_code = l_ac_type_codes(i)
         AND analytical_criterion_code      = l_ac_codes(i)
         AND amb_context_code               = g_amb_context_code;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row deleted into xla_analytical_sources = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1 .. l_ac_codes.COUNT
      DELETE FROM xla_analytical_dtls_tl
       WHERE analytical_criterion_type_code = l_ac_type_codes(i)
         AND analytical_criterion_code      = l_ac_codes(i)
         AND amb_context_code               = g_amb_context_code;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row deleted into xla_analytical_dtls_tl = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1 .. l_ac_codes.COUNT
      DELETE FROM xla_analytical_dtls_b
       WHERE analytical_criterion_type_code = l_ac_type_codes(i)
         AND analytical_criterion_code      = l_ac_codes(i)
         AND amb_context_code               = g_amb_context_code;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row deleted into xla_analytical_dtls_b = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1 .. l_ac_codes.COUNT
      DELETE FROM xla_analytical_hdrs_tl
       WHERE analytical_criterion_type_code = l_ac_type_codes(i)
         AND analytical_criterion_code      = l_ac_codes(i)
         AND amb_context_code               = g_amb_context_code;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row deleted into xla_analytical_hdrs_tl = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1 .. l_ac_codes.COUNT
      DELETE FROM xla_analytical_hdrs_b
       WHERE analytical_criterion_type_code = l_ac_type_codes(i)
         AND analytical_criterion_code      = l_ac_codes(i)
         AND amb_context_code               = g_amb_context_code;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row deleted into xla_analytical_hdrs_b = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

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
               ,p_value_1         => 'xla_aad_overwrite_pvt.purge_analytical_criteria'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END purge_analytical_criteria;

--=============================================================================
--
-- Name: purge_adr
-- Description: This API deletes the ADRs from the working area
--              if it exists in the working area.
--
--=============================================================================
PROCEDURE purge_adr
IS
  CURSOR c_adr IS
    SELECT s.segment_rule_type_code
          ,s.segment_rule_code
          ,w.version_num version_from
          ,s.version_num version_to
      FROM xla_seg_rules_b   s
          ,xla_seg_rules_b   w
     WHERE s.application_id         = w.application_id
       AND s.segment_rule_type_code = w.segment_rule_type_code
       AND s.segment_rule_code      = w.segment_rule_code
       AND s.amb_context_code       = g_staging_context_code
       AND w.amb_context_code       = g_amb_context_code
     UNION
    SELECT w.segment_rule_type_code
          ,w.segment_rule_code
          ,NULL
          ,NULL
      FROM xla_seg_rules_b   w
     WHERE w.application_id   = g_application_id
       AND w.amb_context_code = g_amb_context_code;

  l_adrs                 xla_component_tbl_type;
  l_adr                  xla_component_rec_type;
  l_adr_codes            t_array_varchar2;
  l_adr_type_codes       t_array_varchar2;
  i                      INTEGER;
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.purge_adr';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure purge_adr',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  i := 0;
  l_adrs := xla_component_tbl_type();

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - retrieve ADR',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_comp IN c_adr LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - ADR = '||
                        l_comp.segment_rule_type_code||','||
                        l_comp.segment_rule_code||','||
                        NVL(l_comp.version_from,'')||','||
                        NVL(l_comp.version_to,''),
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    i := i + 1;
    l_adr := xla_component_rec_type
                                (l_comp.segment_rule_type_code
                                ,l_comp.segment_rule_code
                                ,l_comp.version_from
                                ,l_comp.version_to);
    l_adrs.extend;
    l_adrs(i) := l_adr;

    l_adr_type_codes(i) := l_comp.segment_rule_type_code;
    l_adr_codes(i)      := l_comp.segment_rule_code;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - retrieve ADRs: # retrieve = '||i,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (i>0) THEN
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
          ,'MERGED_SETUP'
          ,application_id
          ,'AMB_ADR'
          ,segment_rule_type_code
          ,segment_rule_code
          ,version_from
          ,version_to
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
      FROM (SELECT a.application_id
                  ,a.segment_rule_type_code
                  ,a.segment_rule_code
                  ,adr.version_from
                  ,adr.version_to
              FROM xla_line_defn_adr_assgns    a
                  ,TABLE(CAST(l_adrs AS xla_component_tbl_type)) adr
             WHERE a.amb_context_code       = g_amb_context_code
               AND a.application_id        <> g_application_id
               AND a.segment_rule_appl_id   = g_application_id
               AND a.segment_rule_type_code = adr.component_owner_code
               AND a.segment_rule_code      = adr.component_code
               AND adr.version_from         IS NOT NULL
             UNION
            SELECT a.application_id
                  ,a.segment_rule_type_code
                  ,a.segment_rule_code
                  ,adr.version_from
                  ,adr.version_to
              FROM xla_seg_rule_details    a
                  ,TABLE(CAST(l_adrs AS xla_component_tbl_type)) adr
             WHERE a.amb_context_code             = g_amb_context_code
               AND a.application_id              <> g_application_id
               AND a.value_segment_rule_appl_id   = g_application_id
               AND a.value_segment_rule_type_code = adr.component_owner_code
               AND a.value_segment_rule_code      = adr.component_code
               AND adr.version_from         IS NOT NULL);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row insert into xla_aad_loader_logs = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1 .. l_adr_codes.COUNT
      DELETE FROM xla_conditions
       WHERE segment_rule_detail_id IN
             (SELECT segment_rule_detail_id
                FROM xla_seg_rule_details
               WHERE application_id         = g_application_id
                 AND amb_context_code       = g_amb_context_code
                 AND segment_rule_type_code = l_adr_type_codes(i)
                 AND segment_rule_code      = l_adr_codes(i));

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row deleted into xla_conditions = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1 .. l_adr_codes.COUNT
      DELETE FROM xla_seg_rule_details
       WHERE application_id         = g_application_id
         AND amb_context_code       = g_amb_context_code
         AND segment_rule_type_code = l_adr_type_codes(i)
         AND segment_rule_code      = l_adr_codes(i);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row deleted into xla_seg_rule_details = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1 .. l_adr_codes.COUNT
      DELETE FROM xla_seg_rules_tl
       WHERE application_id         = g_application_id
         AND amb_context_code       = g_amb_context_code
         AND segment_rule_type_code = l_adr_type_codes(i)
         AND segment_rule_code      = l_adr_codes(i);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row deleted into xla_seg_rules_tl = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    FORALL i IN 1 .. l_adr_codes.COUNT
      DELETE FROM xla_seg_rules_b
       WHERE application_id         = g_application_id
         AND amb_context_code       = g_amb_context_code
         AND segment_rule_type_code = l_adr_type_codes(i)
         AND segment_rule_code      = l_adr_codes(i);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# row deleted into xla_seg_rules_b = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure purge_adr',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_overwrite_pvt.purge_adr'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END purge_adr;

--=============================================================================
--
-- Name: purge_adr_reference
-- Description: This API deletes any reference to the ADR that no longer exist
--              in the staging area
--=============================================================================
PROCEDURE purge_adr_reference
IS
  l_count         INTEGER;
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.purge_adr_reference';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure purge_adr_reference',
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
        ,segment_rule_type_code
        ,segment_rule_code
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
    FROM xla_line_defn_adr_assgns xld
   WHERE xld.amb_context_code     = g_amb_context_code
     AND xld.application_id      <> g_application_id
     AND xld.segment_rule_appl_id = g_application_id
     AND NOT EXISTS (SELECT 1
                       FROM xla_seg_rules_b s
                      WHERE s.amb_context_code       = g_staging_context_code
                        AND s.application_id         = xld.segment_rule_appl_id
                        AND s.segment_rule_type_code = xld.segment_rule_type_code
                        AND s.segment_rule_code      = xld.segment_rule_code);

  l_count := SQL%ROWCOUNT;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# row inserted to xla_aad_loader_log = '||l_count,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (l_count > 0) THEN
    DELETE FROM xla_line_defn_adr_assgns xld
     WHERE xld.amb_context_code     = g_amb_context_code
       AND xld.segment_rule_appl_id = g_application_id
       AND NOT EXISTS (SELECT 1
                       FROM xla_seg_rules_b s
                      WHERE s.amb_context_code       = g_staging_context_code
                        AND s.application_id         = xld.segment_rule_appl_id
                        AND s.segment_rule_type_code = xld.segment_rule_type_code
                        AND s.segment_rule_code      = xld.segment_rule_code);

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => '# row inserted to xla_aad_loader_log = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure purge_adr_reference',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_overwrite_pvt.purge_adr_reference'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END purge_adr_reference;


--=============================================================================
--
-- Name: move_components
-- Description: This API moves the different components from staging to working
--              area.
--
--=============================================================================
PROCEDURE move_components
IS
  l_count         INTEGER;
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.move_components';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure move_components',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Move journal line types
  UPDATE xla_acct_line_types_b
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_acct_line_types_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_acct_line_types_tl
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_acct_line_types_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_jlt_acct_attrs
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_jlt_acct_attrs = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Move journal entry descriptions
  UPDATE xla_descriptions_b
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_descriptions_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_descriptions_tl
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_descriptions_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_desc_priorities
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_desc_priorities = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_descript_details_b
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_descript_details_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_descript_details_tl
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_descript_details_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Move account derivation rules
  UPDATE xla_seg_rules_b
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_seg_rules_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_seg_rules_tl
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_seg_rules_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_seg_rule_details
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_seg_rule_details = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Move mapping sets
  UPDATE xla_mapping_sets_b
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_mapping_sets_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_mapping_sets_tl
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_mapping_sets_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_mapping_set_values
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_mapping_set_values = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Move analytical criteria
  UPDATE xla_analytical_hdrs_b
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  l_count := SQL%ROWCOUNT;
  IF (l_count > 0) THEN
    g_ac_updated := TRUE;
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_analytical_hdrs_b = '||l_count,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_analytical_hdrs_tl
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_analytical_hdrs_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_analytical_dtls_b
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  l_count := SQL%ROWCOUNT;
  IF (l_count > 0) THEN
    g_ac_updated := TRUE;
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_analytical_dtls_b = '||l_count,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_analytical_dtls_tl
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_analytical_dtls_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_analytical_sources
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_analytical_sources = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Move conditions
  UPDATE xla_conditions
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_conditions = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure move_components',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_overwrite_pvt.move_components'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END move_components;

--=============================================================================
--
-- Name: move_jlds
-- Description: This API moves the JLDs and its assignments from staging to
--              working area
--
--=============================================================================
PROCEDURE move_jlds
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.move_jlds';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure move_jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  UPDATE xla_line_definitions_b
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_line_definitions_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_line_definitions_tl
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_line_definitions_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_line_defn_jlt_assgns
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_line_defn_jlt_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_line_defn_adr_assgns
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_line_defn_adr_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_line_defn_ac_assgns
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_line_defn_ac_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_mpa_jlt_assgns
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_mpa_jlt_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_mpa_header_ac_assgns
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_mpa_header_ac_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_mpa_jlt_adr_assgns
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_mpa_jlt_adr_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_mpa_jlt_ac_assgns
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_mpa_jlt_ac_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure move_jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_overwrite_pvt.move_jlds'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END move_jlds;


--=============================================================================
--
-- Name: move_aads
-- Description: This API moves the AADs and its assignments from staging to
--              working area
--
--=============================================================================
PROCEDURE move_aads
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.move_aads';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure move_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Move accounting definitions
  UPDATE xla_product_rules_b
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_product_rules_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_product_rules_tl
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_product_rules_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Move header assignment
  UPDATE xla_prod_acct_headers
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_prod_acct_headers = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_aad_hdr_acct_attrs
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_aad_hdr_acct_attrs = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_aad_header_ac_assgns
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_aad_header_ac_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  UPDATE xla_aad_line_defn_assgns
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_aad_line_defn_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure move_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_overwrite_pvt.move_aads'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END move_aads;

--=============================================================================
--
-- Name: move_acctg_methods
-- Description: This API copies the accounting methods from the staging to the
--              working area if not already exists.  Then it moves the
--              accounting method rules from the staging to the working area.
--
--=============================================================================
PROCEDURE move_acctg_methods
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.move_acctg_methods';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure move_acctg_methods',
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
  SELECT
   s.accounting_method_type_code
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
  SELECT
   s.accounting_method_type_code
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

  UPDATE xla_acctg_method_rules
     SET amb_context_code = g_amb_context_code
   WHERE amb_context_code = g_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row moved in xla_acctg_method_rules = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure move_acctg_methods',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_overwrite_pvt.move_acctg_methods'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END move_acctg_methods;

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
-- Name: overwrite
-- Description: This API overwrite the AADs and its components from the
--              staging area to the working area of an AMB context
--
--=============================================================================
PROCEDURE overwrite
(p_api_version        IN NUMBER
,x_return_status      IN OUT NOCOPY VARCHAR2
,p_application_id     IN INTEGER
,p_amb_context_code   IN VARCHAR2
,p_force_flag         IN VARCHAR2
,p_compile_flag       IN VARCHAR2
,x_overwrite_status   IN OUT NOCOPY VARCHAR2)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'overwrite';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_staging_context_code VARCHAR2(30);
  l_retcode              VARCHAR2(30);
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.overwrite';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function overwrite: '||
                      'p_application_id = '||p_application_id||
                      ', p_amb_context_code = '||p_amb_context_code||
                      ', p_force_flag = '||p_force_flag,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_staging_context_code := xla_aad_loader_util_pvt.get_staging_context_code
                                (p_application_id   => p_application_id
                                ,p_amb_context_code => p_amb_context_code);

  xla_aad_overwrite_pvt.overwrite
             (p_api_version          => p_api_version
             ,x_return_status        => x_return_status
             ,p_application_id       => p_application_id
             ,p_amb_context_code     => p_amb_context_code
             ,p_staging_context_code => l_staging_context_code
             ,p_force_flag           => p_force_flag
             ,p_compile_flag         => p_compile_flag
             ,x_overwrite_status     => x_overwrite_status);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function overwrite - Return value = '||x_overwrite_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN G_EXC_WARNING THEN
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  x_overwrite_status := 'WARNING';

WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  x_overwrite_status := 'ERROR';

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_overwrite_status := 'ERROR';

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_overwrite_status := 'ERROR';

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_overwrite_pvt.overwrite'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
END overwrite;


--=============================================================================
--
-- Name: overwrite
-- Description: This API overwrite the AADs and its components from the
--              staging area to the working area of an AMB context
--
--=============================================================================
PROCEDURE overwrite
(p_api_version          IN NUMBER
,x_return_status        IN OUT NOCOPY VARCHAR2
,p_application_id       IN INTEGER
,p_amb_context_code     IN VARCHAR2
,p_staging_context_code IN VARCHAR2
,p_force_flag           IN VARCHAR2
,p_compile_flag         IN VARCHAR2
,x_overwrite_status     IN OUT NOCOPY VARCHAR2)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'overwrite';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_retcode           VARCHAR2(30);
  l_log_module        VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.overwrite';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function overwrite: '||
                      'p_application_id = '||p_application_id||
                      ', p_amb_context_code = '||p_amb_context_code||
                      ', p_force_flag = '||p_force_flag,
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

  g_application_id       := p_application_id;
  g_amb_context_code     := p_amb_context_code;
  g_force_flag           := p_force_flag;
  g_ac_updated           := FALSE;
  g_staging_context_code := p_staging_context_code;

  -- API Logic
  x_overwrite_status := pre_overwrite;
  IF (x_overwrite_status = 'WARNING') THEN
    RAISE G_EXC_WARNING;
  ELSIF (x_overwrite_status = 'ERROR') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_overwrite_status := validation;
  IF (x_overwrite_status = 'WARNING') THEN
    RAISE G_EXC_WARNING;
  ELSIF (x_overwrite_status = 'ERROR') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  record_log;

  -- Clean up working area
  xla_aad_loader_util_pvt.purge
    (p_application_id    => g_application_id
    ,p_amb_context_code  => g_amb_context_code);

  purge_mapping_sets;
  purge_analytical_criteria;
  purge_adr;
  purge_adr_reference;

  -- Move AADs from staging to working area
  move_components;
  move_jlds;
  move_aads;
  move_acctg_methods;

  -- Update AAD and component histories
  xla_aad_loader_util_pvt.merge_history
        (p_application_id       => g_application_id
        ,p_staging_context_code => g_staging_context_code);

  IF (g_ac_updated) THEN
    xla_aad_loader_util_pvt.rebuild_ac_views;
  END IF;

  IF (p_compile_flag = 'Y') THEN
    IF (NOT xla_aad_loader_util_pvt.compile
                        (p_application_id    => g_application_id
                        ,p_amb_context_code  => g_amb_context_code)) THEN
      RAISE G_EXC_WARNING;
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function overwrite - Return value = '||x_overwrite_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN G_EXC_WARNING THEN
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  x_overwrite_status := 'WARNING';

WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  x_overwrite_status := 'ERROR';

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_overwrite_status := 'ERROR';

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_overwrite_status := 'ERROR';

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_overwrite_pvt.overwrite'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
END overwrite;

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

END xla_aad_overwrite_pvt;

/
