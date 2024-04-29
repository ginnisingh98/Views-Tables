--------------------------------------------------------
--  DDL for Package Body XLA_AAD_LOADER_INSTALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AAD_LOADER_INSTALL_PVT" AS
/* $Header: xlaalins.pkb 120.0 2006/06/29 02:25:00 wychan noship $ */

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
C_FILE_NAME                   CONSTANT VARCHAR2(30):='xlaalupl.pkb';
C_CHAR                        CONSTANT VARCHAR2(1) :='
';

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_aad_loader_install_pvt';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS
l_time varchar2(300);
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
      (p_location   => 'xla_aad_loader_install_pvt.trace');
END trace;


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================


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
-- Name:
-- Description:
--
--=============================================================================
PROCEDURE pre_export
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_versioning_mode       IN VARCHAR2
,p_user_version          IN VARCHAR2
,p_version_comment       IN VARCHAR2
,x_return_status         IN OUT NOCOPY VARCHAR2
)IS
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.pre_export';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure pre_export',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.reset_errors
             (p_application_id     => p_application_id
             ,p_amb_context_code   => p_amb_context_code
             ,p_request_code       => 'EXPORT');

  x_return_status := xla_aad_export_pvt.pre_export
                     (p_application_id   => p_application_id
                     ,p_amb_context_code => p_amb_context_code
                     ,p_versioning_mode  => CASE p_versioning_mode
                                                 WHEN 'N' THEN 'STANDARD'
                                                 WHEN 'Y' THEN 'LEAPFROG'
                                                 ELSE p_versioning_mode
                                                 END
                     ,p_user_version     => CASE WHEN p_user_version = 'NULL'
                                                 THEN NULL
                                                 ELSE p_user_version END
                     ,p_version_comment  => CASE WHEN p_version_comment = 'NULL'
                                                 THEN NULL
                                                 ELSE p_version_comment END
                     ,p_owner_type       => 'C');

  IF (x_return_status <> 'SUCCESS') THEN
    ROLLBACK;
    xla_aad_loader_util_pvt.insert_errors
             (p_application_id     => p_application_id
             ,p_amb_context_code   => p_amb_context_code
             ,p_request_code       => 'EXPORT');
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure pre_export: x_return_status = '||x_return_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := 'ERROR';
  xla_aad_loader_util_pvt.insert_errors
             (p_application_id     => p_application_id
             ,p_amb_context_code   => p_amb_context_code
             ,p_request_code       => 'EXPORT');
END pre_export;

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

END xla_aad_loader_install_pvt;

/
