--------------------------------------------------------
--  DDL for Package Body XLA_AAD_DOWNLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AAD_DOWNLOAD_PVT" AS
/* $Header: xlaaldnl.pkb 120.7 2005/06/14 00:39:28 wychan ship $ */

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------
g_application_id              NUMBER;
g_amb_context_code            VARCHAR2(30);
g_destination_file            VARCHAR2(240);
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_aad_download_pvt';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS
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
      (p_location   => 'xla_aad_download_pvt.trace');
END trace;


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================

--=============================================================================
--
-- Name: submit_request
-- Description: This API submits the Download Application Accounting Definitions
--              request
--
--=============================================================================
FUNCTION submit_request
RETURN INTEGER
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_req_id        NUMBER;
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.submit_request';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function submit_request',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_req_id := fnd_request.submit_request
               (application => 'XLA'
               ,program     => 'XLAAADDL'
               ,description => NULL
               ,start_time  => NULL
               ,sub_request => FALSE
               ,argument1   => 'DOWNLOAD'
               ,argument2   => '@xla:/patch/115/import/xlaaadrule.lct'
               ,argument3   => g_destination_file
               ,argument4   => 'XLA_AAD'
               ,argument5   => 'APPLICATION_ID='||g_application_id
               ,argument6   => 'AMB_CONTEXT_CODE='||g_amb_context_code);

  COMMIT;

  IF (C_LEVEL_EVENT>= g_log_level) THEN
    trace(p_msg    => 'Submitted XLAAADDL request = '||l_req_id
         ,p_level  => C_LEVEL_EVENT
         ,p_module => l_log_module);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function submit_request : Return Code = '||l_req_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
  return l_req_id;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_download_pkg.submit_request'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END submit_request;

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
-- Name: download
-- Description: This API downloads the AADs and the components from an AMB
--              context to a data file
--
--=============================================================================
PROCEDURE download
(p_api_version           IN NUMBER
,x_return_status         IN OUT NOCOPY VARCHAR2
,p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_destination_file      IN VARCHAR2
,x_download_status       IN OUT NOCOPY VARCHAR2)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'download';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_req_id            INTEGER;
  l_log_module        VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.download';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function download',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Commit is necessary for the XLAAADDL download program to read the
  -- modified histories information in the spawn FNDLOAD program
  COMMIT;

  IF (NOT xla_aad_loader_util_pvt.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => C_DEFAULT_MODULE))
  THEN

  IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
    trace(p_msg    => 'RAISING FND_API.G_EXC_UNEXPECTED_ERROR',
          p_module => l_log_module,
          p_level  => C_LEVEL_UNEXPECTED);
  END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

  END IF;

  --  Initialize global variables
  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'Value of x_return_status is' || x_return_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  g_application_id   := p_application_id;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'Value of g_application_id is' || g_application_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  g_amb_context_code := p_amb_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'Value of g_amb_context_code is' || g_amb_context_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  g_destination_file := p_destination_file;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'Value of g_destination_file is' || g_destination_file,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- API Logic
  l_req_id := submit_request;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'Value of l_req_id is' || l_req_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (l_req_id = 0) THEN

  IF (C_LEVEL_ERROR >= g_log_level) THEN
    trace(p_msg    => 'Raise FND_API.G_EXC_ERROR',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_download_status := xla_aad_loader_util_pvt.wait_for_request(p_req_id => l_req_id);
  IF (x_download_status = 'ERROR' ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function download - Return value = '||x_download_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK;
  x_return_status := 'ERROR';

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'Value of x_return_status is' || x_return_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  x_download_status := 'ERROR';

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'Value of x_download_status is' || x_download_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_DNL_FNDLOAD_FAIL'
               ,p_token_1         => 'CONC_REQUEST_ID'
               ,p_value_1         => l_req_id
               ,p_token_2         => 'DATA_FILE'
               ,p_value_2         => g_destination_file);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function download - Return value = '||x_download_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'Value of x_return_status is' || x_return_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  x_download_status := 'ERROR';

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'Value of x_download_status is' || x_download_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'Value of x_return_status is' || x_return_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  x_download_status := 'ERROR';

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'Value of x_download_status is' || x_download_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_download_pvt.download'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');

END download;

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

END xla_aad_download_pvt;

/
