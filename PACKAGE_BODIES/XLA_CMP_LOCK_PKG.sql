--------------------------------------------------------
--  DDL for Package Body XLA_CMP_LOCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_LOCK_PKG" AS
/* $Header: xlacplck.pkb 120.2 2005/04/28 18:43:49 masada ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_cmp_lock_pkg                                                   |
|                                                                       |
| DESCRIPTION                                                           |
|    Transaction Account Builder API Compiler                           |
|                                                                       |
| HISTORY                                                               |
|    26-JAN-04 A.Quaglia      Created                                   |
+======================================================================*/


   --
   -- Private exceptions
   --
   le_resource_busy                   EXCEPTION;
   PRAGMA exception_init(le_resource_busy, -00054);

   --
   -- Private types
   --

   --
   -- Private constants
   --

   --
   -- Global variables
   --
   g_user_id                 INTEGER := xla_environment_pkg.g_usr_id;
   g_login_id                INTEGER := xla_environment_pkg.g_login_id;
   g_date                    DATE    := SYSDATE;
   g_prog_appl_id            INTEGER := xla_environment_pkg.g_prog_appl_id;
   g_prog_id                 INTEGER := xla_environment_pkg.g_prog_id;
   g_req_id                  INTEGER := NVL(xla_environment_pkg.g_req_id, -1);

   --

   -- Cursor declarations
   --



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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_lock_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

--1-STATEMENT, 2-PROCEDURE, 3-EVENT, 4-EXCEPTION, 5-ERROR, 6-UNEXPECTED

PROCEDURE trace
       ( p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE
        ,p_msg                        IN VARCHAR2
        ,p_level                      IN NUMBER
        ) IS
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
         (p_location   => 'xla_cmp_lock_pkg.trace');
END trace;


--Forward declarations of private functions

FUNCTION lock_tad_details
            (
              p_application_id                 IN NUMBER
             ,p_account_definition_code        IN VARCHAR2
             ,p_account_definition_type_code   IN VARCHAR2
             ,p_amb_context_code               IN VARCHAR2
            )

RETURN BOOLEAN;




FUNCTION lock_tats_and_sources
                           ( p_application_id       IN         NUMBER
                           )
RETURN BOOLEAN
IS
   --Declare appropriate cursor
   CURSOR lc_lck IS
   SELECT xtatb.account_type_code
     FROM xla_tab_acct_types_b   xtatb
         ,xla_tab_acct_type_srcs xtsrc
         ,xla_sources_b          xsb
    WHERE xtatb.application_id     = p_application_id
      AND xtatb.enabled_flag       = 'Y'
      AND xtsrc.account_type_code  = xtatb.account_type_code
      AND xsb.application_id       = xtsrc.source_application_id
      AND xsb.source_code          = xtsrc.source_code
      AND xsb.source_type_code     = xtsrc.source_type_code
   FOR UPDATE NOWAIT;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.lock_tats_and_sources';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg    => 'BEGIN ' || C_DEFAULT_MODULE ||'.lock_tats_and_sources'
         ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   --Open cursor
   OPEN  lc_lck;
   --Close cursor
   CLOSE lc_lck;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE ||'.lock_tats_and_sources'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN le_resource_busy
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
        ( p_module => l_log_module
         ,p_msg      => 'Unable to lock the records'
         ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_lock_pkg.lock_tats_and_sources');

END lock_tats_and_sources;


FUNCTION lock_tad
            (
              p_application_id                 IN NUMBER
             ,p_account_definition_code        IN VARCHAR2
             ,p_account_definition_type_code   IN VARCHAR2
             ,p_amb_context_code               IN VARCHAR2
            )

RETURN BOOLEAN
IS
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.lock_tad';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => '****NOT COMPLETE!!!***** ' || l_log_module
         ,p_level    => C_LEVEL_EXCEPTION);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN le_resource_busy
THEN
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_lock_pkg.lock_tad');


END lock_tad;


FUNCTION lock_tad_details
            (
              p_application_id                 IN NUMBER
             ,p_account_definition_code        IN VARCHAR2
             ,p_account_definition_type_code   IN VARCHAR2
             ,p_amb_context_code               IN VARCHAR2
            )

RETURN BOOLEAN
IS
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.lock_tad_details';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE ||'.lock_tad_details'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END  ' || C_DEFAULT_MODULE ||'.lock_tad_details'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN FALSE;

EXCEPTION
WHEN le_resource_busy
THEN
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_lock_pkg.lock_tad_details');

END lock_tad_details;


FUNCTION lock_adr
            (
              p_application_id           IN NUMBER
             ,p_segment_rule_code        IN VARCHAR2
             ,p_segment_rule_type_code   IN VARCHAR2
             ,p_amb_context_code         IN VARCHAR2
            )

RETURN BOOLEAN
IS
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.lock_adr';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE ||'.lock_adr'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE ||'.lock_adr'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN FALSE;

EXCEPTION
WHEN le_resource_busy
THEN
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_lock_pkg.lock_adr');

END lock_adr;


FUNCTION lock_source
            (
              p_application_id                 IN NUMBER
             ,p_source_code                    IN VARCHAR2
             ,p_source_type_code               IN VARCHAR2
            )

RETURN BOOLEAN
IS
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.lock_source';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE ||'.lock_source'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE ||'.lock_source'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN FALSE;

EXCEPTION
WHEN le_resource_busy
THEN
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_lock_pkg.lock_source');

END lock_source;


FUNCTION lock_adr_detail_conditions
            (
              p_application_id                 IN NUMBER
             ,p_segment_rule_detail_id         IN NUMBER
             ,p_amb_context_code               IN VARCHAR2
            )

RETURN BOOLEAN
IS
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.lock_adr_detail_conditions';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE ||'.lock_adr_detail_conditions'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE ||'.lock_adr_detail_conditions'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN FALSE;

EXCEPTION
WHEN le_resource_busy
THEN
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_lock_pkg.lock_adr_detail_conditions');

END lock_adr_detail_conditions;



FUNCTION lock_mapping_set
            (
              p_mapping_set_code               IN VARCHAR2
             ,p_amb_context_code               IN VARCHAR2
            )

RETURN BOOLEAN
IS
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.lock_mapping_set';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE ||'.lock_mapping_set'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE ||'.lock_mapping_set'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN FALSE;

EXCEPTION
WHEN le_resource_busy
THEN
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_lock_pkg.lock_mapping_set');

END lock_mapping_set;


--Trace initialization
BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_cmp_lock_pkg;

/
