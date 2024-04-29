--------------------------------------------------------
--  DDL for Package Body XLA_AAD_LOADER_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AAD_LOADER_UTIL_PVT" AS
/* $Header: xlaalutl.pkb 120.16.12010000.2 2009/03/05 09:01:53 krsankar ship $ */

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------
TYPE t_array_int       IS TABLE OF INTEGER        INDEX BY BINARY_INTEGER;
TYPE t_array_msg       IS TABLE OF VARCHAR2(2400) INDEX BY BINARY_INTEGER;
TYPE t_array_varchar30 IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- declaring global variables
------------------------------------------------------------------------------
g_err_count                   INTEGER;
g_err_nums                    t_array_int;
g_err_msgs                    t_array_msg;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_aad_loader_util_pvt';

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
      (p_location   => 'xla_aad_loader_util_pvt.trace');
END trace;


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================

--=============================================================================
--
-- Name: create_staging_context_code
-- Description:
--
--=============================================================================
FUNCTION create_staging_context_code
(p_application_id       INTEGER
,p_amb_context_code     VARCHAR2)
RETURN VARCHAR2
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_temp_code       VARCHAR2(80);
  l_code            VARCHAR2(30);
  l_log_module      VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure create_staging_context_code: '||
                      'p_amb_context_code = '||p_amb_context_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  WHILE (l_code IS NULL) LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'staging context code not found',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    SELECT TO_CHAR(systimestamp,'SSSSSFF') INTO l_temp_code FROM dual;
    l_temp_code := substr(p_amb_context_code,1,12) || '_'||
                   p_application_id || '_S_' ||l_temp_code;
    l_code := substr(l_temp_code,1,30);

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'Staging amb context code: '||
                        l_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    INSERT INTO xla_appli_amb_contexts
    (application_id
    ,amb_context_code
    ,staging_amb_context_code
    ,updated_flag
    ,last_analyzed_date
    ,batch_name
    ,object_version_number
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login)
    SELECT
     p_application_id
    ,p_amb_context_code
    ,l_code
    ,'Y'
    ,NULL
    ,NULL
    ,1
    ,sysdate
    ,xla_environment_pkg.g_usr_id
    ,sysdate
    ,xla_environment_pkg.g_usr_id
    ,xla_environment_pkg.g_login_id
    FROM dual
    WHERE NOT EXISTS (SELECT 1
                        FROM xla_appli_amb_contexts
                       WHERE staging_amb_context_code = l_code);

    IF (SQL%ROWCOUNT = 0) THEN
      l_code := NULL;
    END IF;
  END LOOP;

  COMMIT;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure create_staging_context_code: '||
                      'staging AMB context code = '||l_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
  return l_code;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.create_staging_context_code'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END create_staging_context_code;


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
-- Name: purge
-- Description: This API purge all application accounting definitions and its
--              component from a specified AMB context code except mapping sets
--              and analytical criteria.
--
--=============================================================================
PROCEDURE purge
(p_application_id       INTEGER
,p_amb_context_code     VARCHAR2)
IS
  l_log_module               VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.purge';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure purge: '||
                      'application_id = '||p_application_id||
                      ', amb_context_code = '||p_amb_context_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --
  -- Delete accounting method rules
  --
  DELETE FROM xla_acctg_method_rules
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_acctg_method_rules = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  --
  -- Delete application accounting definition assignments
  --
  DELETE FROM xla_line_defn_ac_assgns
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_line_defn_ac_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_line_defn_adr_assgns
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_line_defn_adr_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_line_defn_jlt_assgns
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_line_defn_jlt_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_line_definitions_b
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_line_definitions_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_line_definitions_tl
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_line_definitions_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_aad_line_defn_assgns
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_aad_line_defn_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_aad_header_ac_assgns
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_aad_header_ac_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_mpa_header_ac_assgns
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_mpa_header_ac_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_mpa_jlt_adr_assgns
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_mpa_jlt_adr_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_mpa_jlt_ac_assgns
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_mpa_jlt_ac_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_mpa_jlt_assgns
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_mpa_jlt_assgns = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_aad_hdr_acct_attrs
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_aad_hdr_acct_attrs = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_prod_acct_headers
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_prod_acct_headers = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  --
  -- Delete application accounting definitions
  --
  DELETE FROM xla_product_rules_tl
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_product_rules_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_product_rules_b
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_product_rules_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  --
  -- Delete conditions
  --
  DELETE FROM xla_conditions
   WHERE application_id = p_application_id
     AND amb_context_code       = p_amb_context_code
     AND segment_rule_detail_id IS NULL; -- bug 4367287: delete ADR on demand

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_conditions = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  --
  -- Delete account derivation rules
  --
/* Bug 4367287 - the ADR is deleted on demand

  DELETE FROM xla_seg_rule_details
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_seg_rule_details = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_seg_rules_tl
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_seg_rules_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_seg_rules_b
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_seg_rules_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;
*/

  --
  -- Delete descriptions
  --
  DELETE FROM xla_descript_details_tl
   WHERE description_detail_id IN
         (SELECT description_detail_id
            FROM xla_descript_details_b  dd
                ,xla_desc_priorities     dp
           WHERE dd.description_prio_id = dp.description_prio_id
             AND dp.application_id      = p_application_id
             AND dp.amb_context_code    = p_amb_context_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_descript_details_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_descript_details_b
   WHERE description_prio_id IN
         (SELECT description_prio_id
            FROM xla_desc_priorities
           WHERE application_id = p_application_id
             AND amb_context_code = p_amb_context_code);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_descript_details_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_desc_priorities
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_desc_priorities = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_descriptions_tl
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_descriptions_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_descriptions_b
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_descriptions_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  --
  -- Delete journal line types
  --
  DELETE FROM xla_jlt_acct_attrs
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_jlt_acct_attrs = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_acct_line_types_tl
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_acct_line_types_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_acct_line_types_b
   WHERE application_id = p_application_id
     AND amb_context_code = p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_acct_line_types_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure purge',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN OTHERS                                   THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.purge'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END purge;

--=============================================================================
--
-- Name: lock_area
-- Description: This API locks all the records in amb tables of the amb context.
--
--=============================================================================
FUNCTION lock_area
(p_application_id       INTEGER
,p_amb_context_code     VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c_product_rules_b IS
    SELECT *
      FROM xla_product_rules_b
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_product_rules_tl IS
    SELECT *
      FROM xla_product_rules_tl
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_prod_acct_headers IS
    SELECT *
      FROM xla_prod_acct_headers
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_aad_hdr_acct_attrs IS
    SELECT *
      FROM xla_aad_hdr_acct_attrs
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_aad_header_ac_assgns IS
    SELECT *
      FROM xla_aad_header_ac_assgns
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_mpa_header_ac_assgns IS
    SELECT *
      FROM xla_mpa_header_ac_assgns
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_mpa_jlt_ac_assgns IS
    SELECT *
      FROM xla_mpa_jlt_ac_assgns
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_mpa_jlt_adr_assgns IS
    SELECT *
      FROM xla_mpa_jlt_adr_assgns
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_mpa_jlt_assgns IS
    SELECT *
      FROM xla_mpa_jlt_assgns
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_aad_line_defn_assgns IS
    SELECT *
      FROM xla_aad_line_defn_assgns
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_line_definitions_b IS
    SELECT *
      FROM xla_line_definitions_b
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_line_definitions_tl IS
    SELECT *
      FROM xla_line_definitions_tl
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_line_defn_jlt_assgns IS
    SELECT *
      FROM xla_line_defn_jlt_assgns
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_line_defn_adr_assgns IS
    SELECT *
      FROM xla_line_defn_adr_assgns
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_line_defn_ac_assgns IS
    SELECT *
      FROM xla_line_defn_ac_assgns
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_seg_rules_b IS
    SELECT *
      FROM xla_seg_rules_b
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_seg_rules_tl IS
    SELECT *
      FROM xla_seg_rules_tl
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_seg_rule_details IS
    SELECT *
      FROM xla_seg_rule_details
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_acct_line_types_b IS
    SELECT *
      FROM xla_acct_line_types_b
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_acct_line_types_tl IS
    SELECT *
      FROM xla_acct_line_types_tl
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_jlt_acct_attrs IS
    SELECT *
      FROM xla_jlt_acct_attrs
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_descriptions_b IS
    SELECT *
      FROM xla_descriptions_b
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_descriptions_tl IS
    SELECT *
      FROM xla_descriptions_tl
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_desc_priorities IS
    SELECT *
      FROM xla_desc_priorities
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_descript_details_tl IS
    SELECT *
      FROM xla_descript_details_b  b
          ,xla_descript_details_tl t
          ,xla_desc_priorities     p
     WHERE t.description_detail_id  = b.description_detail_id
       AND b.description_prio_id    = p.description_prio_id
       AND p.application_id         = p_application_id
       AND p.amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_conditions IS
    SELECT *
      FROM xla_conditions
     WHERE application_id         = p_application_id
       AND amb_context_code       = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_mapping_sets IS
    SELECT *
      FROM xla_mapping_sets_b     b
          ,xla_mapping_sets_tl    t
          ,xla_seg_rule_details   s
     WHERE t.mapping_set_code     = b.mapping_set_code
       AND b.mapping_set_code     = s.value_mapping_set_code
       AND s.application_id       = p_application_id
       AND s.amb_context_code     = p_amb_context_code
    FOR UPDATE NOWAIT;

  CURSOR c_mapping_set_values IS
    SELECT *
      FROM xla_mapping_set_values b
          ,xla_seg_rule_details   s
     WHERE b.mapping_set_code     = s.value_mapping_set_code
       AND s.application_id       = p_application_id
       AND s.amb_context_code     = p_amb_context_code
    FOR UPDATE NOWAIT;

  /*CURSOR c_analytical_hdrs IS
    SELECT *
      FROM xla_analytical_hdrs_b  b
          ,xla_analytical_hdrs_tl t
     WHERE t.analytical_criterion_type_code = b.analytical_criterion_type_code
       AND t.analytical_criterion_code      = b.analytical_criterion_code
       AND t.amb_context_code               = b.amb_context_code
       AND b.amb_context_code               = p_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_aad_header_ac_assgns  xah
                    WHERE xah.analytical_criterion_type_code = b.analytical_criterion_type_code
                      AND xah.analytical_criterion_code      = b.analytical_criterion_code
                      AND xah.amb_context_code               = b.amb_context_code
                      AND xah.application_id                 = p_application_id
                      AND xah.amb_context_code               = p_amb_context_code
                    UNION
                   SELECT 1
                     FROM xla_line_defn_ac_assgns  xld
                    WHERE xld.analytical_criterion_type_code = b.analytical_criterion_type_code
                      AND xld.analytical_criterion_code      = b.analytical_criterion_code
                      AND xld.amb_context_code               = b.amb_context_code
                      AND xld.application_id                 = p_application_id
                      AND xld.amb_context_code               = p_amb_context_code
                    UNION
                   SELECT 1
                     FROM xla_mpa_header_ac_assgns  xld
                    WHERE xld.analytical_criterion_type_code = b.analytical_criterion_type_code
                      AND xld.analytical_criterion_code      = b.analytical_criterion_code
                      AND xld.amb_context_code               = b.amb_context_code
                      AND xld.application_id                 = p_application_id
                      AND xld.amb_context_code               = p_amb_context_code
                    UNION
                   SELECT 1
                     FROM xla_mpa_jlt_ac_assgns  xld
                    WHERE xld.analytical_criterion_type_code = b.analytical_criterion_type_code
                      AND xld.analytical_criterion_code      = b.analytical_criterion_code
                      AND xld.amb_context_code               = b.amb_context_code
                      AND xld.application_id                 = p_application_id
                      AND xld.amb_context_code               = p_amb_context_code)
    FOR UPDATE NOWAIT;*/

 /* CURSOR c_analytical_dtls IS
    SELECT *
      FROM xla_analytical_dtls_b  b
          ,xla_analytical_dtls_tl t
     WHERE t.analytical_criterion_type_code = b.analytical_criterion_type_code
       AND t.analytical_criterion_code      = b.analytical_criterion_code
       AND t.amb_context_code               = b.amb_context_code
       AND b.amb_context_code               = p_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_aad_header_ac_assgns  xah
                    WHERE xah.analytical_criterion_type_code = b.analytical_criterion_type_code
                      AND xah.analytical_criterion_code      = b.analytical_criterion_code
                      AND xah.amb_context_code               = b.amb_context_code
                      AND xah.application_id                 = p_application_id
                      AND xah.amb_context_code               = p_amb_context_code
                    UNION
                   SELECT 1
                     FROM xla_line_defn_ac_assgns  xld
                    WHERE xld.analytical_criterion_type_code = b.analytical_criterion_type_code
                      AND xld.analytical_criterion_code      = b.analytical_criterion_code
                      AND xld.amb_context_code               = b.amb_context_code
                      AND xld.application_id                 = p_application_id
                      AND xld.amb_context_code               = p_amb_context_code
                    UNION
                   SELECT 1
                     FROM xla_mpa_header_ac_assgns  xld
                    WHERE xld.analytical_criterion_type_code = b.analytical_criterion_type_code
                      AND xld.analytical_criterion_code      = b.analytical_criterion_code
                      AND xld.amb_context_code               = b.amb_context_code
                      AND xld.application_id                 = p_application_id
                      AND xld.amb_context_code               = p_amb_context_code
                    UNION
                   SELECT 1
                     FROM xla_mpa_jlt_ac_assgns  xld
                    WHERE xld.analytical_criterion_type_code = b.analytical_criterion_type_code
                      AND xld.analytical_criterion_code      = b.analytical_criterion_code
                      AND xld.amb_context_code               = b.amb_context_code
                      AND xld.application_id                 = p_application_id
                      AND xld.amb_context_code               = p_amb_context_code)
    FOR UPDATE NOWAIT;*/

  /*CURSOR c_analytical_sources IS
    SELECT *
      FROM xla_analytical_sources b
     WHERE b.amb_context_code               = p_amb_context_code
       AND EXISTS (SELECT 1
                     FROM xla_aad_header_ac_assgns  xah
                    WHERE xah.analytical_criterion_type_code = b.analytical_criterion_type_code
                      AND xah.analytical_criterion_code      = b.analytical_criterion_code
                      AND xah.amb_context_code               = b.amb_context_code
                      AND xah.application_id                 = p_application_id
                      AND xah.amb_context_code               = p_amb_context_code
                    UNION
                   SELECT 1
                     FROM xla_line_defn_ac_assgns  xld
                    WHERE xld.analytical_criterion_type_code = b.analytical_criterion_type_code
                      AND xld.analytical_criterion_code      = b.analytical_criterion_code
                      AND xld.amb_context_code               = b.amb_context_code
                      AND xld.application_id                 = p_application_id
                      AND xld.amb_context_code               = p_amb_context_code
                    UNION
                   SELECT 1
                     FROM xla_mpa_header_ac_assgns  xld
                    WHERE xld.analytical_criterion_type_code = b.analytical_criterion_type_code
                      AND xld.analytical_criterion_code      = b.analytical_criterion_code
                      AND xld.amb_context_code               = b.amb_context_code
                      AND xld.application_id                 = p_application_id
                      AND xld.amb_context_code               = p_amb_context_code
                    UNION
                   SELECT 1
                     FROM xla_mpa_jlt_ac_assgns  xld
                    WHERE xld.analytical_criterion_type_code = b.analytical_criterion_type_code
                      AND xld.analytical_criterion_code      = b.analytical_criterion_code
                      AND xld.amb_context_code               = b.amb_context_code
                      AND xld.application_id                 = p_application_id
                      AND xld.amb_context_code               = p_amb_context_code)
    FOR UPDATE NOWAIT;*/

  l_dummy            INTEGER;
  l_retcode          VARCHAR2(30);
  l_log_module       VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.lock_area';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure lock_area',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := 'SUCCESS';

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_product_rules_b',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_product_rules_b;
  CLOSE c_product_rules_b;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_product_rules_tl',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_product_rules_tl;
  CLOSE c_product_rules_tl;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_prod_acct_headers',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_prod_acct_headers;
  CLOSE c_prod_acct_headers;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_aad_hdr_acct_attrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_aad_hdr_acct_attrs;
  CLOSE c_aad_hdr_acct_attrs;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_aad_header_ac_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_aad_header_ac_assgns;
  CLOSE c_aad_header_ac_assgns;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_mpa_header_ac_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_mpa_header_ac_assgns;
  CLOSE c_mpa_header_ac_assgns;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_mpa_jlt_ac_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_mpa_jlt_ac_assgns;
  CLOSE c_mpa_jlt_ac_assgns;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_mpa_jlt_adr_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_mpa_jlt_adr_assgns;
  CLOSE c_mpa_jlt_adr_assgns;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_mpa_jlt_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_mpa_jlt_assgns;
  CLOSE c_mpa_jlt_assgns;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_aad_line_defn_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_aad_line_defn_assgns;
  CLOSE c_aad_line_defn_assgns;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_line_definitions_b',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_line_definitions_b;
  CLOSE c_line_definitions_b;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_line_definitions_tl',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_line_definitions_tl;
  CLOSE c_line_definitions_tl;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_line_defn_jlt_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_line_defn_jlt_assgns;
  CLOSE c_line_defn_jlt_assgns;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_line_defn_adr_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_line_defn_adr_assgns;
  CLOSE c_line_defn_adr_assgns;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_line_defn_ac_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_line_defn_ac_assgns;
  CLOSE c_line_defn_ac_assgns;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_seg_rules_b',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_seg_rules_b;
  CLOSE c_seg_rules_b;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_seg_rules_tl',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_seg_rules_tl;
  CLOSE c_seg_rules_tl;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_seg_rule_details',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_seg_rule_details;
  CLOSE c_seg_rule_details;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_acct_line_types_b',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_acct_line_types_b;
  CLOSE c_acct_line_types_b;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_acct_line_types_tl',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_acct_line_types_tl;
  CLOSE c_acct_line_types_tl;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_jlt_acct_attrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_jlt_acct_attrs;
  CLOSE c_jlt_acct_attrs;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_descriptions_b',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_descriptions_b;
  CLOSE c_descriptions_b;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_descriptions_tl',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_descriptions_tl;
  CLOSE c_descriptions_tl;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_desc_priorities',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_desc_priorities;
  CLOSE c_desc_priorities;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_descript_details_tl',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_descript_details_tl;
  CLOSE c_descript_details_tl;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_conditions',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_conditions;
  CLOSE c_conditions;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_mapping_sets',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_mapping_sets;
  CLOSE c_mapping_sets;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_mapping_set_values',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_mapping_set_values;
  CLOSE c_mapping_set_values;

  /*IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_analytical_hdrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;*/

  /*OPEN c_analytical_hdrs;
  CLOSE c_analytical_hdrs;*/

 /* IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_analytical_dtls',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_analytical_dtls;
  CLOSE c_analytical_dtls;*/

  /*IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'lock c_analytical_sources',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_analytical_sources;
  CLOSE c_analytical_sources;*/

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure lock_area',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
  RETURN l_retcode;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  RETURN 'ERROR';

END lock_area;

--=============================================================================
--
-- Name: get_staging_context_code
-- Description: This API retrieves the staging context code of an AMB context.
--              If it does not already have one, one is created.
--
--=============================================================================
FUNCTION get_staging_context_code
(p_application_id       INTEGER
,p_amb_context_code     VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c IS
    SELECT staging_amb_context_code
      FROM xla_appli_amb_contexts
     WHERE application_id    = p_application_id
       AND amb_context_code  = p_amb_context_code;

  l_temp_code                VARCHAR2(80);
  l_staging_amb_context_code VARCHAR2(30);

  CURSOR c_exists IS
    SELECT 1
      FROM xla_appli_amb_contexts
     WHERE staging_amb_context_code = l_staging_amb_context_code;

  l_log_module               VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_staging_context_code';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure get_staging_context_code: '||
                      'p_amb_context_code = '||p_amb_context_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c;
  FETCH c INTO l_staging_amb_context_code;
  CLOSE c;

  IF (l_staging_amb_context_code IS NULL) THEN
    l_staging_amb_context_code := create_staging_context_code
                (p_amb_context_code => p_amb_context_code
                ,p_application_id   => p_application_id);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure get_staging_context_code: '||
                      'return code = '||l_staging_amb_context_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
  return l_staging_amb_context_code;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.get_staging_context_code'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END get_staging_context_code;

--=============================================================================
--
-- Name: merge_history
-- Description:
--
--=============================================================================
PROCEDURE merge_history
(p_application_id       INTEGER
,p_staging_context_code VARCHAR2)
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.merge_history';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure merge_history',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

/*
  MERGE INTO xla_aads_h h
  USING xla_staging_components_h s
    ON (h.application_id           = s.application_id
    AND h.product_rule_type_code   = s.component_owner_code
    AND h.product_rule_code        = s.component_code
    AND h.version_num              = s.version_num
    AND s.application_id           = p_application_id
    AND s.staging_amb_context_code = p_staging_context_code
    AND s.component_type_code      = 'AAD')
   WHEN MATCHED THEN
        UPDATE SET base_version_num = s.base_version_num
                 , user_version     = s.user_version
                 , version_comment  = s.version_comment
                 , leapfrog_flag    = s.leapfrog_flag;
*/

  UPDATE xla_aads_h h
     SET (base_version_num
         ,user_version
         ,version_comment
         ,leapfrog_flag) =
         (SELECT NVL(s.base_version_num, h2.base_version_num)
                ,NVL(s.product_rule_version, h2.user_version)
                ,NVL(s.version_comment, h2.version_comment)
                ,NVL(s.leapfrog_flag, h2.leapfrog_flag)
            FROM xla_aads_h h2
               , xla_staging_components_h s
           WHERE h.application_id              = h2.application_id
             AND h.product_rule_type_code      = h2.product_rule_type_code
             AND h.product_rule_code           = h2.product_rule_code
             AND h.version_num                 = h2.version_num
             AND h2.application_id             = s.application_id(+)
             AND h2.product_rule_type_code     = s.component_owner_code(+)
             AND h2.product_rule_code          = s.component_code(+)
             AND h2.version_num                = s.version_num(+)
             AND s.application_id(+)           = p_application_id
             AND s.staging_amb_context_code(+) = p_staging_context_code
             AND s.component_type_code(+)      = 'AAD');


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_aads_h updated = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

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
         SELECT p_application_id
               ,s.component_owner_code
               ,s.component_code
               ,s.version_num
               ,s.base_version_num
               ,s.product_rule_version
               ,s.version_comment
               ,s.leapfrog_flag
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
           FROM xla_staging_components_h s
          WHERE s.application_id           = p_application_id
            AND s.staging_amb_context_code = p_staging_context_code
            AND s.component_type_code      = 'AAD'
            AND NOT EXISTS
                (SELECT 1
                   FROM xla_aads_h h
                  WHERE h.application_id           = s.application_id
                    AND h.product_rule_type_code   = s.component_owner_code
                    AND h.product_rule_code        = s.component_code
                    AND h.version_num              = s.version_num);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_aads_h inserted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

/*
  MERGE INTO xla_amb_components_h h
  USING xla_staging_components_h  s
    ON (h.component_type_code      = s.component_type_code
    AND h.component_owner_code     = s.component_owner_code
    AND h.component_code           = s.component_code
    AND h.version_num              = s.version_num
    AND s.staging_amb_context_code = p_staging_context_code
    AND s.component_type_code      <> 'AAD')
   WHEN MATCHED THEN
        UPDATE SET base_version_num = s.base_version_num;
*/

  UPDATE xla_amb_components_h h
     SET base_version_num =
         (SELECT nvl(s.base_version_num, h2.base_version_num)
            FROM xla_amb_components_h      h2
               , xla_staging_components_h  s
           WHERE h.component_type_code         = h2.component_type_code
             AND h.component_owner_code        = h2.component_owner_code
             AND h.component_code              = h2.component_code
             AND h.application_id              = h2.application_id
             AND h.version_num                 = h2.version_num
             AND h2.component_type_code        = s.component_type_code(+)
             AND h2.component_owner_code       = s.component_owner_code(+)
             AND h2.component_code             = s.component_code(+)
             AND h2.application_id             = s.application_id(+)
             AND h2.version_num                = s.version_num(+)
             AND s.staging_amb_context_code(+) = p_staging_context_code
             AND s.component_type_code(+)      <> 'AAD');

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_amb_components_h updated = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  INSERT INTO xla_amb_components_h h
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
           SELECT
                s.component_type_code
               ,s.component_owner_code
               ,s.component_code
               ,NVL(s.application_id,-1)
               ,s.version_num
               ,s.base_version_num
               ,s.leapfrog_flag
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
           FROM xla_staging_components_h s
          WHERE s.staging_amb_context_code = p_staging_context_code
            AND s.component_type_code      <> 'AAD'
            AND NOT EXISTS
                (SELECT 1
                   FROM xla_amb_components_h h
                  WHERE h.component_type_code      = s.component_type_code
                    AND h.component_owner_code     = s.component_owner_code
                    AND h.component_code           = s.component_code
                    AND h.application_id           = NVL(s.application_id,-1)
                    AND h.version_num              = s.version_num);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_amb_components_h inserted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure merge_history',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.merge_history'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END merge_history;

--=============================================================================
--
-- Name: get_segment
-- Description:
--
--=============================================================================
FUNCTION get_segment
(p_chart_of_accounts_id  INTEGER
,p_code_combination_id   INTEGER
,p_segment_num           INTEGER)
RETURN VARCHAR2
IS
  l_num_segments             INTEGER;
  l_ret_segment              VARCHAR2(25);
  l_seg                      FND_FLEX_EXT.SegmentArray;

  l_log_module               VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_segment: '||p_segment_num;
  END IF;

  IF ( FND_FLEX_EXT.get_segments(
                application_short_name  => 'SQLGL',
                key_flex_code           => 'GL#',
                structure_number        => p_chart_of_accounts_id,
                combination_id          => p_code_combination_id,
                n_segments              => l_num_segments,
                segments                => l_seg) = FALSE) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Cannot get segment: FND_FLEX_EXT.get_segments',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;
    l_ret_segment := NULL;
  ELSE
    BEGIN
      l_ret_segment := l_seg(p_segment_num);
    EXCEPTION
    WHEN OTHERS THEN
      l_ret_segment := NULL;
    END;
  END IF;

  RETURN l_ret_segment;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.get_segment'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END get_segment;

--=============================================================================
--
-- Name: reset_errors
-- Description: This API deletes the error from the log table and
--              resets the error stack
--
--=============================================================================
PROCEDURE reset_errors
(p_application_id       INTEGER
,p_amb_context_code     VARCHAR2
,p_request_code         VARCHAR2)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_log_module               VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.reset_errors';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure reset_errors:'||
                      ' p_application_id = '||p_application_id||
                      ', p_amb_context_code = '||p_amb_context_code||
                      ', p_request_code = '||p_request_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_aad_loader_logs
   WHERE application_id     = p_application_id
     AND amb_context_code   = p_amb_context_code
     AND request_code       = p_request_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# row deleted into xla_aad_loader_logs = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  COMMIT;

  g_err_count := 0;
  g_err_nums.DELETE;
  g_err_msgs.DELETE;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure reset_errors',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.reset_errors'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END reset_errors;


--=============================================================================
--
-- Name: stack_errors
-- Description: This API stacks the error to the error array
--
--=============================================================================
PROCEDURE stack_error
(p_appli_s_name      VARCHAR2
,p_msg_name          VARCHAR2)
IS
BEGIN
  stack_error
       (p_appli_s_name     => p_appli_s_name
       ,p_msg_name         => p_msg_name
       ,p_token_1          => NULL
       ,p_value_1          => NULL);
END;

PROCEDURE stack_error
(p_appli_s_name      VARCHAR2
,p_msg_name          VARCHAR2
,p_token_1           VARCHAR2
,p_value_1           VARCHAR2)
IS
BEGIN
  stack_error
       (p_appli_s_name     => p_appli_s_name
       ,p_msg_name         => p_msg_name
       ,p_token_1          => p_token_1
       ,p_value_1          => p_value_1
       ,p_token_2          => NULL
       ,p_value_2          => NULL);
END;

PROCEDURE stack_error
(p_appli_s_name      VARCHAR2
,p_msg_name          VARCHAR2
,p_token_1           VARCHAR2
,p_value_1           VARCHAR2
,p_token_2           VARCHAR2
,p_value_2           VARCHAR2)
IS
BEGIN
  stack_error
       (p_appli_s_name     => p_appli_s_name
       ,p_msg_name         => p_msg_name
       ,p_token_1          => p_token_1
       ,p_value_1          => p_value_1
       ,p_token_2          => p_token_2
       ,p_value_2          => p_value_2
       ,p_token_3          => NULL
       ,p_value_3          => NULL);
END;

PROCEDURE stack_error
(p_appli_s_name      VARCHAR2
,p_msg_name          VARCHAR2
,p_token_1           VARCHAR2
,p_value_1           VARCHAR2
,p_token_2           VARCHAR2
,p_value_2           VARCHAR2
,p_token_3           VARCHAR2
,p_value_3           VARCHAR2)
IS
BEGIN
  stack_error
       (p_appli_s_name     => p_appli_s_name
       ,p_msg_name         => p_msg_name
       ,p_token_1          => p_token_1
       ,p_value_1          => p_value_1
       ,p_token_2          => p_token_2
       ,p_value_2          => p_value_2
       ,p_token_3          => p_token_3
       ,p_value_3          => p_value_3
       ,p_token_4          => NULL
       ,p_value_4          => NULL);
END;

PROCEDURE stack_error
(p_appli_s_name      VARCHAR2
,p_msg_name          VARCHAR2
,p_token_1           VARCHAR2
,p_value_1           VARCHAR2
,p_token_2           VARCHAR2
,p_value_2           VARCHAR2
,p_token_3           VARCHAR2
,p_value_3           VARCHAR2
,p_token_4           VARCHAR2
,p_value_4           VARCHAR2)
IS
  l_msg_number                INTEGER;
  l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.stack_error';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg      => 'BEGIN of procedure stack_error'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    trace(p_msg      => 'p_appli_s_name = '||p_appli_s_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    trace(p_msg      => 'p_msg_name = '||p_msg_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  IF (p_token_4 IS NOT NULL and p_value_4 IS NOT NULL) THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg      => 'p_token_1 = '||p_token_1
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_value_1 = '||p_value_1
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_token_2 = '||p_token_2
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_value_2 = '||p_value_2
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_token_3 = '||p_token_3
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_value_3 = '||p_value_3
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_token_4 = '||p_token_4
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_value_4 = '||p_value_4
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;

    xla_messages_pkg.build_message
      (p_appli_s_name                  => p_appli_s_name
      ,p_msg_name                      => p_msg_name
      ,p_token_1                       => p_token_1
      ,p_value_1                       => p_value_1
      ,p_token_2                       => p_token_2
      ,p_value_2                       => p_value_2
      ,p_token_3                       => p_token_3
      ,p_value_3                       => p_value_3
      ,p_token_4                       => p_token_4
      ,p_value_4                       => p_value_4);

  ELSIF (p_token_3 IS NOT NULL and p_value_3 IS NOT NULL) THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg      => 'p_token_1 = '||p_token_1
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_value_1 = '||p_value_1
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_token_2 = '||p_token_2
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_value_2 = '||p_value_2
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_token_3 = '||p_token_3
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_value_3 = '||p_value_3
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
    xla_messages_pkg.build_message
      (p_appli_s_name                  => p_appli_s_name
      ,p_msg_name                      => p_msg_name
      ,p_token_1                       => p_token_1
      ,p_value_1                       => p_value_1
      ,p_token_2                       => p_token_2
      ,p_value_2                       => p_value_2
      ,p_token_3                       => p_token_3
      ,p_value_3                       => p_value_3);

  ELSIF (p_token_2 IS NOT NULL and p_value_2 IS NOT NULL) THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg      => 'p_token_1 = '||p_token_1
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_value_1 = '||p_value_1
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_token_2 = '||p_token_2
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_value_2 = '||p_value_2
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;

    xla_messages_pkg.build_message
      (p_appli_s_name                  => p_appli_s_name
      ,p_msg_name                      => p_msg_name
      ,p_token_1                       => p_token_1
      ,p_value_1                       => p_value_1
      ,p_token_2                       => p_token_2
      ,p_value_2                       => p_value_2);

  ELSIF (p_token_1 IS NOT NULL and p_value_1 IS NOT NULL) THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg      => 'p_token_1 = '||p_token_1
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'p_value_1 = '||p_value_1
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;

    xla_messages_pkg.build_message
      (p_appli_s_name                  => p_appli_s_name
      ,p_msg_name                      => p_msg_name
      ,p_token_1                       => p_token_1
      ,p_value_1                       => p_value_1);

  ELSE
    xla_messages_pkg.build_message
      (p_appli_s_name                  => p_appli_s_name
      ,p_msg_name                      => p_msg_name);
  END IF;

  l_msg_number := fnd_message.get_number
      (appin                  => p_appli_s_name
      ,namein                 => p_msg_name);

  g_err_count := g_err_count + 1;
  g_err_msgs(g_err_count) := fnd_message.get();
  g_err_nums(g_err_count) := l_msg_number;

  IF (C_LEVEL_ERROR >= g_log_level) THEN
    trace(p_msg      => 'g_err_count = '||g_err_count
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
    trace(p_msg      => 'g_err_msgs(g_err_count) = '||g_err_msgs(g_err_count)
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
    trace(p_msg      => 'g_err_nums(g_err_count) = '||g_err_nums(g_err_count)
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure stack_error'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_aad_loader_util_pvt.stack_error');

END stack_error;

--=============================================================================
--
-- Name: insert_errors
-- Description: This API inserts the errors from the array to the error table
--
--=============================================================================
PROCEDURE insert_errors
(p_application_id       INTEGER
,p_amb_context_code     VARCHAR2
,p_request_code         VARCHAR2)
IS
  l_log_module       VARCHAR2(240);
  l_exception        VARCHAR2(240);
  l_excp_code        VARCHAR2(100);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.insert_errors';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg      => 'BEGIN of procedure insert_errors'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  FORALL i IN 1 .. g_err_msgs.COUNT
    INSERT INTO xla_aad_loader_logs
      (aad_loader_log_id
      ,amb_context_code
      ,application_id
      ,request_code
      ,log_type_code
      ,encoded_message
      ,message_num
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
      ,p_amb_context_code
      ,p_application_id
      ,p_request_code
      ,'ERROR'
      ,g_err_msgs(i)
      ,g_err_nums(i)
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
    trace(p_msg    => '# errors inserted into xla_aad_loader_logs = '||SQL%ROWCOUNT
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure insert_errors'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN OTHERS THEN

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'In exception of xla_aad_loader_util_pvt.insert_errors'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Error in xla_aad_loader_util_pvt.insert_errors is : '||l_excp_code||'-'||l_exception
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.insert_errors'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END insert_errors;

--=============================================================================
--
-- Name: wait_for_request
-- Description: This API waits for the Upload Application Accounting
--              Definitions request to be completed
--
--=============================================================================
FUNCTION wait_for_request
(p_req_id         INTEGER)
RETURN VARCHAR2
IS
  l_btemp         BOOLEAN;
  l_phase         VARCHAR2(30);
  l_status        VARCHAR2(30);
  l_dphase        VARCHAR2(30);
  l_dstatus       VARCHAR2(30);
  l_message       VARCHAR2(240);
  l_retcode       VARCHAR2(30);
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.wait_for_request';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function wait_for_request',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := 'SUCCESS';

  l_btemp := fnd_concurrent.wait_for_request
                         (request_id    => p_req_id
                         ,interval      => 30
                         ,phase         => l_phase
                         ,status        => l_status
                         ,dev_phase     => l_dphase
                         ,dev_status    => l_dstatus
                         ,message       => l_message);

  IF NOT l_btemp THEN
    IF (C_LEVEL_ERROR>= g_log_level) THEN
      trace(p_msg    => 'FND_CONCURRENT.WAIT_FOR_REQUEST returned FALSE'
           ,p_level  => C_LEVEL_ERROR
           ,p_module => l_log_module);
    END IF;

    l_retcode := 'ERROR';
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.wait_for_request'
               ,p_token_2         => 'ERROR'
               ,p_value_2         =>
                     'Technical problem : FND_CONCURRENT.WAIT_FOR_REQUEST returned FALSE');
  ELSE
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'request completed with status = '||l_status
           ,p_level  => C_LEVEL_EVENT
           ,p_module => l_log_module);
    END IF;

    -- If the return code is 'NORMAL', return SUCCESS
    -- For all other status other than WARNING, return ERROR
    IF (l_dstatus = 'NORMAL') THEN
      l_retcode := 'SUCCESS';
    ELSIF (l_dstatus = 'WARNING') THEN
      l_retcode := 'WARNING';
    ELSE
      l_retcode := 'ERROR';
    END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function wait_for_request : Return Code = '||l_retcode,
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
               ,p_value_1         => 'xla_aad_loader_util_pvt.wait_for_request'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END wait_for_request;

--=============================================================================
--
-- Name: submit_compile_report_request
-- Description:
--
--=============================================================================
FUNCTION submit_compile_report_request
(p_application_id         IN INTEGER)
RETURN INTEGER
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_req_id            INTEGER;
  l_log_module        VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.submit_compile_report_request';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure submit_compile_report_request',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_req_id := fnd_request.submit_request
               (application => 'XLA'
               ,program     => 'XLAABACR'
               ,argument1   => NULL
               ,argument2   => NULL
               ,argument3   => TO_CHAR(p_application_id)
               ,argument4   => 'Y'
               ,argument5   => NULL
               ,argument6   => NULL
               ,argument7   => 'N');
  COMMIT;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function submit_compile_report_request - request id = '||l_req_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_req_id;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.submit_compile_report_request'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END;

--=============================================================================
--
-- Name: compile
-- Description: This API compiles all AADs for an application in an AMB context
--
--=============================================================================
FUNCTION compile
(p_amb_context_code      IN VARCHAR2
,p_application_id        IN INTEGER)
RETURN BOOLEAN
IS
  l_req_id            INTEGER;
  l_retcode           BOOLEAN;
  l_log_module        VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compile';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure compile',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --  Initialize global variables
  l_retcode := TRUE;

  -- Compile each AADs and recorded its compilation and validation statuses
  l_req_id := submit_compile_report_request
                 (p_application_id         => p_application_id);

  IF (l_req_id = 0) THEN
    l_retcode := FALSE;
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.compile'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'Unable to submit compilation report request');
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compile - l_retcode = '||
                       CASE WHEN l_retcode THEN 'TRUE' ELSE 'FALSE' END ,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION

WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.compile'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END;



--=============================================================================
--
-- Name: compatible_api_call
-- Description:
--
--=============================================================================
FUNCTION compatible_api_call
(p_current_version_number NUMBER
,p_caller_version_number  NUMBER
,p_api_name               VARCHAR2
,p_pkg_name               VARCHAR2)
RETURN BOOLEAN
IS
  l_error_text        VARCHAR2(2000);
  l_retcode           BOOLEAN;
  l_log_module        VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compatible_api_call';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure compatible_api_call',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := TRUE;
  IF (NOT fnd_api.compatible_api_call
                 (p_current_version_number => p_current_version_number
                 ,p_caller_version_number  => p_caller_version_number
                 ,p_api_name               => p_api_name
                 ,p_pkg_name               => p_pkg_name)) THEN

    l_error_text := fnd_msg_pub.get(fnd_msg_pub.G_FIRST, FND_API.G_FALSE);

    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.compatible_api_call'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => l_error_text);

    l_retcode := FALSE;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compatible_api_call',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
  RETURN l_retcode;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_loader_util_pvt.compatible_api_call'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END;

--=============================================================================
--
-- Name: purge_subledger_seed
-- Description: This API purge the SLA-related seed data for the subledger
--
--=============================================================================
PROCEDURE purge_subledger_seed
(p_api_version           IN NUMBER
,x_return_status         IN OUT NOCOPY VARCHAR2
,p_application_id        IN INTEGER
)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'purge_subledger_seed';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_schema            VARCHAR2(30);
  l_short_name        VARCHAR2(30);
  l_status            VARCHAR2(30);
  l_industry          VARCHAR2(30);

  l_log_module        VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.purge_subledger_seed';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function purge_subledger_seed',
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

  SELECT application_short_name
    INTO l_short_name
    FROM fnd_application
   WHERE application_id    = p_application_id;

  DELETE FROM xla_event_mappings_b     WHERE application_id = p_application_id;
  DELETE FROM xla_event_mappings_tl    WHERE event_mapping_id IN
  (SELECT event_mapping_id
     FROM xla_event_mappings_b
    WHERE application_id = p_application_id);

  DELETE FROM xla_event_class_grps_b   WHERE application_id = p_application_id;
  DELETE FROM xla_event_class_grps_tl  WHERE application_id = p_application_id;

  DELETE FROM xla_entity_id_mappings   WHERE application_id = p_application_id;
  DELETE FROM xla_event_class_attrs    WHERE application_id = p_application_id;
  DELETE FROM xla_event_sources        WHERE application_id = p_application_id;
  DELETE FROM xla_extract_objects      WHERE application_id = p_application_id;
  DELETE FROM xla_reference_objects    WHERE application_id = p_application_id;
  DELETE FROM xla_source_params        WHERE application_id = p_application_id;
  DELETE FROM xla_evt_class_acct_attrs WHERE application_id = p_application_id;

  DELETE FROM xla_event_types_tl       WHERE application_id = p_application_id;
  DELETE FROM xla_event_types_b        WHERE application_id = p_application_id;
  DELETE FROM xla_event_classes_tl     WHERE application_id = p_application_id;
  DELETE FROM xla_event_classes_b      WHERE application_id = p_application_id;
  DELETE FROM xla_entity_types_tl      WHERE application_id = p_application_id;
  DELETE FROM xla_entity_types_b       WHERE application_id = p_application_id;

  DELETE FROM xla_sources_tl           WHERE application_id = p_application_id;
  DELETE FROM xla_sources_b            WHERE application_id = p_application_id;

  DELETE FROM xla_subledgers           WHERE application_id = p_application_id;

  IF (FND_INSTALLATION.get_app_info
                       (application_short_name   => 'XLA'
                       ,status                   => l_status
                       ,industry                 => l_industry
                       ,oracle_schema            => l_schema)) THEN
    l_schema := l_schema || '.';
  ELSE
    l_schema := '';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'XLA_AE_HEADERS drop partition '||l_short_name;
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'XLA_AE_LINES drop partition '||l_short_name;
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema||'XLA_DISTRIBUTION_LINKS drop partition '||l_short_name;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function purge_subledger_seed',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END purge_subledger_seed;


--=============================================================================
--
-- Name: purge_aad
-- Description: This API purge the application accounting definition of an
--              application for an AMB context
--
--=============================================================================
PROCEDURE purge_aad
(p_api_version           IN NUMBER
,x_return_status         IN OUT NOCOPY VARCHAR2
,p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
)
IS
  CURSOR c_staging_context_code IS
    SELECT staging_amb_context_code
      FROM xla_appli_amb_contexts
     WHERE amb_context_code   = p_amb_context_code
       AND application_id     = p_application_id;

  l_staging_context_code   VARCHAR2(30);

  l_api_name          CONSTANT VARCHAR2(30) := 'purge_aad';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_log_module        VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.purge_aad';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function purge_aad: '||
                      'p_application_id = '||p_application_id||
                      ', p_amb_context_code = '||p_amb_context_code,
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
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

  -- API logic
  OPEN c_staging_context_code;
  FETCH c_staging_context_code INTO l_staging_context_code;
  CLOSE c_staging_context_code;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'l_staging_context_code = '||l_staging_context_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (l_staging_context_code IS NOT NULL) THEN
    DELETE FROM xla_aad_loader_defns_t
     WHERE staging_amb_context_code = l_staging_context_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => '# xla_aad_loader_defns_t deleted = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    DELETE FROM xla_appli_amb_contexts
     WHERE staging_amb_context_code = l_staging_context_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => '# xla_appli_amb_contexts deleted = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    DELETE FROM xla_staging_components_h
     WHERE staging_amb_context_code = l_staging_context_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => '# xla_staging_components_h deleted = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    DELETE FROM xla_stage_acctg_methods
     WHERE staging_amb_context_code = l_staging_context_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => '# xla_stage_acctg_methods deleted = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;
  ELSE
    l_staging_context_code := '';

    DELETE FROM xla_aad_loader_defns_t
     WHERE staging_amb_context_code = p_amb_context_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => '# xla_aad_loader_defns_t deleted = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    DELETE FROM xla_appli_amb_contexts
     WHERE staging_amb_context_code = p_amb_context_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => '# xla_appli_amb_contexts deleted = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    DELETE FROM xla_staging_components_h
     WHERE staging_amb_context_code = p_amb_context_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => '# xla_staging_components_h deleted = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    DELETE FROM xla_stage_acctg_methods
     WHERE staging_amb_context_code = p_amb_context_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => '# xla_stage_acctg_methods deleted = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;
  END IF;

  DELETE FROM xla_amb_setup_errors
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_amb_setup_errors deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_acctg_method_rules
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_acctg_method_rules deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_aad_hdr_acct_attrs
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_aad_hdr_acct_attrs deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_aad_header_ac_assgns
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_aad_header_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_mpa_header_ac_assgns
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_header_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_mpa_jlt_adr_assgns
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_adr_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_mpa_jlt_ac_assgns
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_mpa_jlt_assgns
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_mpa_jlt_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_aad_line_defn_assgns
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_aad_line_defn_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_jlt_acct_attrs
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_jlt_acct_attrs deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_line_defn_ac_assgns
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_ac_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_line_defn_adr_assgns
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_adr_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_line_defn_jlt_assgns
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_line_defn_jlt_assgns deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_line_definitions_tl
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_line_definitions_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_line_definitions_b
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_line_definitions_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_prod_acct_headers
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_prod_acct_headers deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_product_rules_tl
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_product_rules_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_product_rules_b
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_product_rules_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_conditions
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_conditions deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_analytical_sources b
   WHERE EXISTS (SELECT 1
                   FROM xla_analytical_hdrs_b h
                  WHERE b.analytical_criterion_type_code = h.analytical_criterion_type_code
                    AND b.analytical_criterion_code      = h.analytical_criterion_code
                    AND b.amb_context_code               = h.amb_context_code
                    AND h.amb_context_code               IN (p_amb_context_code, l_staging_context_code)
                    AND h.application_id                 = p_application_id);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_sources deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_analytical_dtls_tl b
   WHERE EXISTS (SELECT 1
                   FROM xla_analytical_hdrs_b h
                  WHERE b.analytical_criterion_type_code = h.analytical_criterion_type_code
                    AND b.analytical_criterion_code      = h.analytical_criterion_code
                    AND b.amb_context_code               = h.amb_context_code
                    AND h.amb_context_code               IN (p_amb_context_code, l_staging_context_code)
                    AND h.application_id                 = p_application_id);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_dtls_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_analytical_dtls_b b
   WHERE EXISTS (SELECT 1
                   FROM xla_analytical_hdrs_b h
                  WHERE b.analytical_criterion_type_code = h.analytical_criterion_type_code
                    AND b.analytical_criterion_code      = h.analytical_criterion_code
                    AND b.amb_context_code               = h.amb_context_code
                    AND h.amb_context_code               IN (p_amb_context_code, l_staging_context_code)
                    AND h.application_id                 = p_application_id);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_dtls_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_analytical_hdrs_tl b
   WHERE EXISTS (SELECT 1
                   FROM xla_analytical_hdrs_b h
                  WHERE b.analytical_criterion_type_code = h.analytical_criterion_type_code
                    AND b.analytical_criterion_code      = h.analytical_criterion_code
                    AND b.amb_context_code               = h.amb_context_code
                    AND h.amb_context_code               IN (p_amb_context_code, l_staging_context_code)
                    AND h.application_id                 = p_application_id);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_hdrs_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_analytical_hdrs_b
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_analytical_hdrs_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_seg_rule_details
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rule_details deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_seg_rules_tl
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rules_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_seg_rules_b
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_seg_rules_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_descript_details_tl
   WHERE description_detail_id IN
         (SELECT d.description_detail_id
            FROM xla_descript_details_b d
                ,xla_desc_priorities    p
           WHERE d.description_prio_id  = p.description_prio_id
             AND p.application_id   = p_application_id
             AND p.amb_context_code IN (p_amb_context_code, l_staging_context_code));

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_descript_details_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_descript_details_b
   WHERE description_prio_id IN
         (SELECT description_prio_id
            FROM xla_desc_priorities
           WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
             AND application_id   = p_application_id);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_descript_details_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_desc_priorities
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_desc_priorities deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_descriptions_tl
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_descriptions_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_descriptions_b
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_descriptions_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_acct_line_types_tl
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_acct_line_types_tl deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_acct_line_types_b
   WHERE amb_context_code IN (p_amb_context_code, l_staging_context_code)
     AND application_id   = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => '# xla_acct_line_types_b deleted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function purge_aad',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_util_pvt.purge_aad'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');

END purge_aad;

--=============================================================================
--
-- Name: rebuild_ac_views
-- Description: This API rebuild the view_column_name for the analytical detail
--              and rebuild the views.
--
--=============================================================================
PROCEDURE rebuild_ac_views
IS
  CURSOR c_acs IS
    SELECT analytical_criterion_type_code
         , analytical_criterion_code
         , amb_context_code
      FROM xla_analytical_hdrs_b;

  l_ret_value         INTEGER;
  l_log_module        VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.rebuild_ac_views';
  END IF;

  FOR l_ac IN c_acs LOOP

    l_ret_value := xla_analytical_criteria_pkg.compile_criterion
                   (p_anacri_code       => l_ac.analytical_criterion_code
                   ,p_anacri_type_code  => l_ac.analytical_criterion_type_code
                   ,p_amb_context_code  => l_ac.amb_context_code);

  END LOOP;

  l_ret_value := xla_analytical_criteria_pkg.build_criteria_view;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function rebuild_ac_views',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function rebuild_ac_views',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION

WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_util_pvt.rebuild_ac_views'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;


END;

--=============================================================================
--
-- Name: validate_adr_compatibility
-- Description: This API validate if the AAD includes any ADR from other
--              application that has incompatible version
--
--=============================================================================
FUNCTION validate_adr_compatibility
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_staging_context_code  IN VARCHAR2
) RETURN VARCHAR2
IS
  CURSOR c_invalid_adrs IS
    SELECT app.application_name
         , xst.name segment_rule_name
         , lk1.meaning segment_rule_owner
         , xld.adr_version_num version_num
      FROM xla_line_defn_adr_assgns xld
         , xla_seg_rules_b          xsr
         , xla_seg_rules_tl         xst
         , fnd_application_vl       app
         , xla_lookups              lk1
     WHERE xld.amb_context_code       = p_staging_context_code
       AND xld.segment_rule_appl_id  <> p_application_id
       AND xsr.amb_context_code       = p_amb_context_code
       AND xsr.application_id         = xld.segment_rule_appl_id
       AND xsr.segment_rule_type_code = xld.segment_rule_type_code
       AND xsr.segment_rule_code      = xld.segment_rule_code
       AND xsr.version_num            < xld.adr_version_num
       AND app.application_id         = xld.segment_rule_appl_id
       AND xst.application_id         = xld.segment_rule_appl_id
       AND xst.segment_rule_type_code = xld.segment_rule_type_code
       AND xst.segment_rule_code      = xld.segment_rule_code
       AND xst.language               = USERENV('LANG')
       AND lk1.lookup_type            = 'XLA_OWNER_TYPE'
       AND lk1.lookup_code            = xld.segment_rule_type_code
    UNION
    SELECT app.application_name
         , xst.name segment_rule_name
         , lk1.meaning segment_rule_owner
         , xsd.value_adr_version_num
      FROM xla_seg_rule_details     xsd
         , xla_seg_rules_b          xsr
         , xla_seg_rules_tl         xst
         , fnd_application_vl       app
         , xla_lookups              lk1
     WHERE xsd.amb_context_code           = p_staging_context_code
       AND xsd.value_segment_rule_appl_id <> p_application_id
       AND xsr.amb_context_code           = p_amb_context_code
       AND xsr.application_id             = xsd.value_segment_rule_appl_id
       AND xsr.segment_rule_type_code     = xsd.value_segment_rule_type_code
       AND xsr.segment_rule_code          = xsd.value_segment_rule_code
       AND xsr.version_num                < xsd.value_adr_version_num
       AND app.application_id             = xsd.value_segment_rule_appl_id
       AND xst.application_id             = xsd.value_segment_rule_appl_id
       AND xst.segment_rule_type_code     = xsd.value_segment_rule_type_code
       AND xst.segment_rule_code          = xsd.value_segment_rule_code
       AND xst.language                   = USERENV('LANG')
       AND lk1.lookup_type                = 'XLA_OWNER_TYPE'
       AND lk1.lookup_code                = xsd.value_segment_rule_type_code;

  l_retcode       VARCHAR2(30);
  l_log_module        VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_adr_compatibility';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_adr_compatibility: '||
                      'p_application_id = '||p_application_id||
                      ', p_amb_context_code = '||p_amb_context_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := 'SUCCESS';

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: c_invalid_adr ',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_err in c_invalid_adrs LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: c_invalid_adr - '||
                         l_err.application_name||','||
                         l_err.segment_rule_name||','||
                         l_err.segment_rule_owner||','||
                         l_err.version_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    l_retcode := 'ERROR';
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_INCOMPATIBLE_ADR_VERS'
               ,p_token_1         => 'APP_NAME'
               ,p_value_1         => l_err.application_name
               ,p_token_2         => 'SEGMENT_RULE_NAME'
               ,p_value_2         => l_err.segment_rule_name
               ,p_token_3         => 'SEGMENT_RULE_OWNER'
               ,p_value_3         => l_err.segment_rule_owner
               ,p_token_4         => 'VERSION_NUM'
               ,p_value_4         => l_err.version_num);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: c_invalid_adr ',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function validate_adr_compatibility',
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
               ,p_value_1         => 'xla_aad_util_pvt.validate_adr_compatibility'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END validate_adr_compatibility;

--=============================================================================
--
-- Name: purge_history
-- Description: This API reset the version of the AADs, ADRs, etc of an
--              application to 0 and clear all its version history.
--
--=============================================================================
PROCEDURE purge_history
(p_api_version           IN NUMBER
,x_return_status         IN OUT NOCOPY VARCHAR2
,p_application_id        IN INTEGER)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'purge_history';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_log_module        VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.purge_history';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function purge_history: '||
                      'p_application_id = '||p_application_id,
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
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM xla_aads_h
   WHERE application_id = p_application_id;

  DELETE FROM xla_amb_components_h
   WHERE application_id = p_application_id;

  UPDATE xla_product_rules_b
     SET version_num = 0
       , updated_flag = 'Y'
   WHERE application_id = p_application_id;

  UPDATE xla_seg_rules_b
     SET version_num = 0
       , updated_flag = 'Y'
   WHERE application_id = p_application_id;

  UPDATE xla_analytical_hdrs_b
     SET version_num = 0
       , updated_flag = 'Y'
   WHERE application_id = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function purge_history',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END purge_history;





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

END xla_aad_loader_util_pvt;

/
