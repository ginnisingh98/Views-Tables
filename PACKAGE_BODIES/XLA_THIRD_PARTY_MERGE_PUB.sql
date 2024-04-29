--------------------------------------------------------
--  DDL for Package Body XLA_THIRD_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_THIRD_PARTY_MERGE_PUB" AS
-- $Header: xlamergp.pkb 120.0 2005/10/28 22:27:31 weshen noship $
/*===========================================================================+
|                Copyright (c) 2005 Oracle Corporation                       |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlamergp.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_third_party_merge_pub                                               |
|                                                                            |
| DESCRIPTION                                                                |
|    This is a public package for product teams, which contains all the      |
|    APIs required for creating Third Party Merge events.                    |
|                                                                            |
|    These public APIs are wrapper over public routines of                   |
|    xla_third_party_merge                                                   |
|                                                                            |
| HISTORY                                                                    |
|    08-Sep-05 L. Poon         Created                                       |
+===========================================================================*/

--=============================================================================
--             *********** Local Trace and Log Routines **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_third_party_merge_pub';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
 (  p_msg                       IN VARCHAR2
  , p_level                     IN NUMBER
  , p_module                    IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level)
   THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level
   THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;
END trace;

PROCEDURE user_log
 (p_msg                         IN VARCHAR2) IS
BEGIN
   fnd_file.put_line(fnd_file.log, p_msg);
END user_log;

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================

-- ----------------------------------------------------------------------------
-- Third party merge event creation routine
-- ----------------------------------------------------------------------------
PROCEDURE third_party_merge
 (  x_errbuf                    OUT NOCOPY VARCHAR2
  , x_retcode                   OUT NOCOPY VARCHAR2
  , x_event_ids                 OUT NOCOPY t_event_ids
  , x_request_id                OUT NOCOPY INTEGER
  , p_source_application_id     IN INTEGER DEFAULT NULL
  , p_application_id            IN INTEGER
  , p_ledger_id                 IN INTEGER DEFAULT NULL
  , p_third_party_merge_date    IN DATE
  , p_third_party_type          IN VARCHAR2
  , p_original_third_party_id   IN INTEGER
  , p_original_site_id          IN INTEGER DEFAULT NULL
  , p_new_third_party_id        IN INTEGER
  , p_new_site_id               IN INTEGER DEFAULT NULL
  , p_type_of_third_party_merge IN VARCHAR2
  , p_mapping_flag              IN VARCHAR2
  , p_execution_mode            IN VARCHAR2
  , p_accounting_mode           IN VARCHAR2
  , p_transfer_to_gl_flag       IN VARCHAR2
  , p_post_in_gl_flag           IN VARCHAR2) IS

  v_function VARCHAR2(240);
  v_module   VARCHAR2(240);
  v_message  VARCHAR2(2000);

BEGIN
  -- --------------------------
  -- Initialize local variables
  -- --------------------------
  v_function := 'xla_third_party_merge_pub.third_party_merge';
  v_module   := C_DEFAULT_MODULE||'.third_party_merge';

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'p_source_application_id = ' || p_source_application_id
                         || ', p_applicaiton_id = ' || p_application_id
                         || ', p_ledger_id = ' || p_ledger_id
                         || ', p_third_party_merge_date = '
	                     || p_third_party_merge_date
	                     || ', p_third_party_type = ' || p_third_party_type
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'p_original_third_party_id = '
	                     || p_original_third_party_id
						 || ', p_original_site_id = ' || p_original_site_id
                         || ', p_new_third_party_id = ' || p_new_third_party_id
                         || ', p_new_site_id = ' || p_new_site_id
                         || ', p_type_of_third_party_merge = '
	                     || p_type_of_third_party_merge
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'p_mapping_flag = ' || p_mapping_flag
	                     || ', p_execution_mode = ' || p_execution_mode
	                     || ', p_accounting_mode = ' || p_accounting_mode
                         || ', p_transfer_to_gl_flag = '
						 || p_transfer_to_gl_flag
                         || ', p_post_in_gl_flag = ' || p_post_in_gl_flag
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF;

  -- --------------------------------------------
  -- Call the XLA API to set environment settings
  -- --------------------------------------------
  trace(  p_msg    => 'Call xla_environment_pkg.refresh()'
        , p_level  => C_LEVEL_STATEMENT
        , p_module => v_module);
  xla_environment_pkg.refresh();

  -- ---------------------------------------------------
  -- Call the XLA API to create Third Party Merge events
  -- ---------------------------------------------------
  trace(  p_msg    => 'Call xla_third_party_merge.third_party_merge()'
        , p_level  => C_LEVEL_STATEMENT
        , p_module => v_module);
  xla_third_party_merge.third_party_merge
   (  x_errbuf                    => x_errbuf
    , x_retcode                   => x_retcode
    , x_event_ids                 => x_event_ids
    , x_request_id                => x_request_id
    , p_source_application_id     => p_source_application_id
    , p_application_id            => p_application_id
    , p_ledger_id                 => p_ledger_id
    , p_third_party_merge_date    => p_third_party_merge_date
    , p_third_party_type          => p_third_party_type
    , p_original_third_party_id   => p_original_third_party_id
    , p_original_site_id          => p_original_site_id
    , p_new_third_party_id        => p_new_third_party_id
    , p_new_site_id               => p_new_site_id
    , p_type_of_third_party_merge => p_type_of_third_party_merge
    , p_mapping_flag              => p_mapping_flag
    , p_execution_mode            => p_execution_mode
    , p_accounting_mode           => p_accounting_mode
    , p_transfer_to_gl_flag       => p_transfer_to_gl_flag
    , p_post_in_gl_flag           => p_post_in_gl_flag);

  -- Log the out parameters, their returned values and the function exit
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'x_retcode = ' || x_retcode
                         || ', x_errbuf = ' || x_errbuf
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'x_request_id = ' || x_request_id
                         || ', x_event_ids.COUNT = ' || x_event_ids.COUNT
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);

    -- Log the function exit
    IF (x_retcode = G_RET_STS_ERROR OR x_retcode = G_RET_STS_UNEXP_ERROR)
    THEN
      trace(  p_msg    => 'EXIT with ERROR - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    ELSE
      trace(  p_msg    => 'END - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    END IF; -- IF (x_retcode = G_RET_STS_ERROR OR ...

  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

EXCEPTION
  WHEN OTHERS THEN
    -- Get and log the SQL error message
    v_message := SQLERRM;
    trace(  p_msg    => v_message
          , p_level  => C_LEVEL_UNEXPECTED
          , p_module => v_module);
    -- Set the out parameters
    x_errbuf := xla_messages_pkg.get_message
                 (  p_appli_s_name => 'XLA'
                  , p_msg_name     => 'XLA_MERGE_FATAL_ERR'
                  , p_token_1      => 'FUNCTION'
                  , p_value_1      => v_function
                  , p_token_2      => 'ERROR'
                  , p_value_2      => v_message);
    x_retcode := G_RET_STS_UNEXP_ERROR;
    -- Log the out parameters, their returned values and the function exit
    IF (C_LEVEL_PROCEDURE >= g_log_level)
    THEN
      trace(  p_msg    => 'x_retcode = ' || x_retcode
                           || ', x_errbuf = ' || x_errbuf
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
      trace(  p_msg    => 'x_request_id = ' || x_request_id
                           || ', x_event_ids.COUNT = ' || x_event_ids.COUNT
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
      -- Log the function exit
      trace(  p_msg    => 'EXIT with ERROR - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    END IF;

END third_party_merge;

-- ----------------------------------------------------------------------------
-- Create third party merge accounting routine - called by SRS
-- ----------------------------------------------------------------------------
PROCEDURE create_accounting
 (  x_errbuf                    OUT NOCOPY VARCHAR2
  , x_retcode                   OUT NOCOPY VARCHAR2
  , p_application_id            IN INTEGER
  , p_event_id                  IN INTEGER DEFAULT NULL
  , p_accounting_mode           IN VARCHAR2
  , p_transfer_to_gl_flag       IN VARCHAR2
  , p_post_in_gl_flag           IN VARCHAR2
  , p_merge_event_set_id        IN INTEGER DEFAULT NULL) IS

  v_function      VARCHAR2(240);
  v_module        VARCHAR2(240);
  v_message       VARCHAR2(2000);
  v_cp_status     VARCHAR2(30);
  v_return_status BOOLEAN;

BEGIN

  -- --------------------------
  -- Initialize local variables
  -- --------------------------
  v_function := 'xla_third_party_merge_pub.create_accounting';
  v_module   := C_DEFAULT_MODULE||'.create_accounting';

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'p_applicaiton_id = ' || p_application_id
                         || ', p_event_id = ' || p_event_id
                         || ', p_accounting_mode = ' || p_accounting_mode
                         || ', p_transfer_to_gl_flag = ' || p_transfer_to_gl_flag
                         || ', p_post_in_gl_flag = ' || p_post_in_gl_flag
                         || ', p_merge_event_set_id = ' || p_merge_event_set_id
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  -- --------------------------------------------
  -- Call the XLA API to set environment settings
  -- --------------------------------------------
  trace(  p_msg    => 'Call xla_environment_pkg.refresh()'
        , p_level  => C_LEVEL_STATEMENT
        , p_module => v_module);
  xla_environment_pkg.refresh();

  -- ------------------------------------------------------------------
  -- Call the XLA API to create accoutning for Third Party Merge events
  -- ------------------------------------------------------------------
  trace(  p_msg    => 'Call xla_third_party_merge.create_accounting()'
        , p_level  => C_LEVEL_STATEMENT
        , p_module => v_module);
  xla_third_party_merge.create_accounting
   (  x_errbuf              => x_errbuf
    , x_retcode             => x_retcode
    , p_application_id      => p_application_id
    , p_event_id            => p_event_id
    , p_accounting_mode     => p_accounting_mode
    , p_transfer_to_gl_flag => p_transfer_to_gl_flag
    , p_post_in_gl_flag     => p_post_in_gl_flag
	, p_merge_event_set_id  => p_merge_event_set_id
	, p_srs_flag            => 'Y');

  -- ------------------------------------------------------------------------
  -- Write final message to the concurrent request log and set the concurrent
  -- request completion status according to the return values
  -- ------------------------------------------------------------------------
  trace(  p_msg    => 'Write final log message'
        , p_level  => C_LEVEL_STATEMENT
        , p_module => v_module);
  IF (x_retcode = G_RET_STS_ERROR OR x_retcode = G_RET_STS_UNEXP_ERROR)
  THEN
    -- An error was raised, so write the returned error message to the
    -- concurrent request log and set the completion status to 'ERROR'
    user_log(x_errbuf);
    v_cp_status := 'ERROR';
  ELSIF (x_retcode = G_RET_STS_WARN)
  THEN
    -- A warning was raised, so get and write the message XLA_MERGE_ACCT_WARN to
    -- the concurrent request log
    v_message := xla_messages_pkg.get_message
                  (  p_appli_s_name => 'XLA'
                   , p_msg_name     => 'XLA_MERGE_ACCT_WARN');
    user_log(v_message);
    v_cp_status := 'WARNING';
  ELSE
    -- It completed successfully, so write the message XLA_MERGE_ACCT_SUCCEEDED
	-- to the concurrent request log
    v_message := xla_messages_pkg.get_message
                  (  p_appli_s_name => 'XLA'
                   , p_msg_name     => 'XLA_MERGE_ACCT_SUCCEEDED');
    user_log(v_message);
    v_cp_status := 'SUCCESS';
  END IF;

  -- Log the out parameters, their returned values and function exit
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'x_retcode = ' || x_retcode
	                     || ', x_errbuf = ' || x_errbuf
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);

    -- Log the function exit
    IF (v_cp_status = 'ERROR')
    THEN
      trace(  p_msg    => 'EXIT with ERROR - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    ELSE
      trace(  p_msg    => 'END - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    END IF; -- IF (x_retcode = G_RET_STS_ERROR OR ...

  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  -- Set the concurrent request completion status
  v_return_status := fnd_concurrent.set_completion_status
                      (  status  => v_cp_status
                       , message => NULL);

  -- Commit the changes made by this concurrent request and exit
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    -- Rollback all the changes made by this concurrent request
    ROLLBACK;
    -- Get and log the SQL error message
    v_message := SQLERRM;
    trace(  p_msg    => v_message
          , p_level  => C_LEVEL_UNEXPECTED
          , p_module => v_module);
    -- Set the out parameters
    x_errbuf := xla_messages_pkg.get_message
                 (  p_appli_s_name => 'XLA'
                  , p_msg_name     => 'XLA_MERGE_FATAL_ERR'
                  , p_token_1      => 'FUNCTION'
                  , p_value_1      => v_function
                  , p_token_2      => 'ERROR'
                  , p_value_2      => v_message);
    x_retcode := G_RET_STS_UNEXP_ERROR;
    -- Write the error message to the concurrent request log
    user_log(x_errbuf);
    -- Log the out parameters, their returned values and function exit
    IF (C_LEVEL_PROCEDURE >= g_log_level)
    THEN
      trace(  p_msg    => 'x_retcode = ' || x_retcode
  	                       || ', x_errbuf = ' || x_errbuf
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
      trace(  p_msg    => 'EXIT with ERROR - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)
    -- Set the concurrent request completion status as ERROR
    v_return_status := fnd_concurrent.set_completion_status
                        (  status  => 'ERROR'
                         , message => NULL);
    -- Commit the above changes and exit
    COMMIT;

END create_accounting;

--=============================================================================
--          *******************  Initialization  *********************
--=============================================================================
BEGIN
   g_log_level      := fnd_log.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test(  log_level => g_log_level
                                    , module    => C_DEFAULT_MODULE);

   IF NOT g_log_enabled
   THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_third_party_merge_pub;

/
