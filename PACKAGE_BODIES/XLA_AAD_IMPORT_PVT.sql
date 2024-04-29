--------------------------------------------------------
--  DDL for Package Body XLA_AAD_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AAD_IMPORT_PVT" AS
/* $Header: xlaalimp.pkb 120.10 2006/06/02 21:23:50 wychan ship $ */

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- declaring global variables
------------------------------------------------------------------------------

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_aad_import_pvt';

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
WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
    (p_location   => 'xla_aad_import_pvt.trace');
END trace;


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================

--=============================================================================
--
-- Name: pre_import
-- Description: This API perform the pre-import step.
--
--=============================================================================
FUNCTION pre_import
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_staging_context_code  IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c_lock IS
    SELECT *
      FROM xla_appli_amb_contexts
     WHERE application_id      = p_application_id
       AND amb_context_code    = p_amb_context_code
    FOR UPDATE OF application_id NOWAIT;

  recinfo         c_lock%ROWTYPE;
  l_lock_error    BOOLEAN;
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.pre_import';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure pre_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Lock the staging area of the AMB context
  l_lock_error := TRUE;
  OPEN c_lock;
  CLOSE c_lock;
  l_lock_error := FALSE;

  -- Clean up staging accounting methods
  DELETE FROM xla_stage_acctg_methods
   WHERE staging_amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_stage_acctg_methods = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Clean up staging history
  DELETE FROM xla_staging_components_h
   WHERE staging_amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_staging_components_h = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Clean up ADR
  DELETE FROM xla_conditions
   WHERE amb_context_code       = p_staging_context_code
     AND segment_rule_detail_id IS NOT NULL;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_conditions = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_seg_rule_details
   WHERE amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_seg_rule_details = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_seg_rules_tl
   WHERE amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_seg_rules_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_seg_rules_b
   WHERE amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_seg_rules_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Clean up mapping set tables
  DELETE FROM xla_mapping_set_values
   WHERE amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_mapping_set_values = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_mapping_sets_tl
   WHERE amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_mapping_sets_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_mapping_sets_b
   WHERE amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_mapping_sets_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Clean up analytical criterion tables
  DELETE FROM xla_analytical_sources
   WHERE amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_analytical_sources = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_analytical_dtls_tl
   WHERE amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_analytical_dtls_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_analytical_dtls_b
   WHERE amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_analytical_dtls_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_analytical_hdrs_tl
   WHERE amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_analytical_hdrs_tl = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE FROM xla_analytical_hdrs_b
   WHERE amb_context_code = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# record deleted from xla_analytical_hdrs_b = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  xla_aad_loader_util_pvt.purge
    (p_application_id   => p_application_id
    ,p_amb_context_code => p_staging_context_code);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function pre_import - Return value = SUCCESS',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN 'SUCCESS';
EXCEPTION
WHEN OTHERS THEN
  IF (c_lock%ISOPEN) THEN
    CLOSE c_lock;
  END IF;

  IF (l_lock_error) THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'END of function pre_import - Return value = ERROR',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    xla_aad_loader_util_pvt.stack_error
        (p_appli_s_name  => 'XLA'
        ,p_msg_name      => 'XLA_AAD_IMP_LOCK_FAILED');

    RETURN 'ERROR';
  ELSE
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_import_pvt.pre_import'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
    RETURN 'ERROR';
  END IF;

END pre_import;

--=============================================================================
--
-- Name: record_log
-- Description: This API inserts the log information to the log table
--
--=============================================================================
PROCEDURE record_log
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_staging_context_code  IN VARCHAR2)
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
        ,'IMPORT'
        ,'IMPORTED_AAD'
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
    AND amb_context_code       = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# rows inserted into xla_aad_loader_logs = '||SQL%ROWCOUNT,
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
               ,p_value_1         => 'xla_aad_import_pvt.record_log'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END record_log;

--=============================================================================
--
-- Name: post_import
-- Description: This API perform post-import steps
--
--=============================================================================
PROCEDURE post_import
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_staging_context_code  IN VARCHAR2)
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.post_import';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure post_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  UPDATE xla_appli_amb_contexts
     SET updated_flag        = 'Y'
        ,creation_date       = sysdate
        ,created_by          = xla_environment_pkg.g_usr_id
        ,last_update_date    = sysdate
        ,last_updated_by     = xla_environment_pkg.g_usr_id
        ,last_update_login   = xla_environment_pkg.g_login_id
   WHERE amb_context_code    = p_amb_context_code
     AND application_id      = p_application_id;

  record_log(p_application_id       => p_application_id
            ,p_amb_context_code     => p_amb_context_code
            ,p_staging_context_code => p_staging_context_code);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure post_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_import_pvt.post_import'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END post_import;


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
-- Name: import
-- Description: This API imports the AADs and the components from the data file
--              to the staging area of an AMB context
--
--=============================================================================
PROCEDURE import
(p_api_version           IN NUMBER
,x_return_status         IN OUT NOCOPY VARCHAR2
,p_application_id        IN INTEGER
,p_source_pathname       IN VARCHAR2
,p_amb_context_code      IN VARCHAR2
,x_import_status         IN OUT NOCOPY VARCHAR2
)
IS
  l_api_name             CONSTANT VARCHAR2(30) := 'import';
  l_api_version          CONSTANT NUMBER       := 1.0;
  l_staging_context_code VARCHAR2(30);
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.import';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function import',
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

  -- API Logic
  l_staging_context_code := xla_aad_loader_util_pvt.get_staging_context_code
                               (p_application_id   => p_application_id
                               ,p_amb_context_code => p_amb_context_code);

  x_import_status := pre_import(p_application_id       => p_application_id
                               ,p_amb_context_code     => p_amb_context_code
                               ,p_staging_context_code => l_staging_context_code);

  IF (x_import_status = 'ERROR') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  xla_aad_upload_pvt.upload
                     (p_api_version      => 1.0
                     ,x_return_status    => x_return_status
                     ,p_application_id   => p_application_id
                     ,p_source_pathname  => p_source_pathname
                     ,p_amb_context_code => p_amb_context_code
                     ,x_upload_status    => x_import_status);
  IF (x_import_status = 'ERROR') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  post_import(p_application_id       => p_application_id
             ,p_amb_context_code     => p_amb_context_code
             ,p_staging_context_code => l_staging_context_code);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function import - Return value = '||x_import_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  x_import_status := 'ERROR';

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_import_status := 'ERROR';

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_import_status := 'ERROR';

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_import_pvt.import'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');

END import;

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

END xla_aad_import_pvt;

/
