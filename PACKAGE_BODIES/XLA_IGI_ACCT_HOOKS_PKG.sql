--------------------------------------------------------
--  DDL for Package Body XLA_IGI_ACCT_HOOKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_IGI_ACCT_HOOKS_PKG" AS
/*$Header: xlaapigh.pkb 120.0.12000000.1 2007/10/24 14:06:42 samejain noship $*/
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_igi_acct_hooks_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     Call accounting program integration APIs for IGI                       |
|                                                                            |
| HISTORY                                                                    |
|     08/30/2007    S. Jain         Created                                  |
|                                                                            |
+===========================================================================*/


--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_igi_acct_hooks_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, NVL(p_module,C_DEFAULT_MODULE));
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, NVL(p_module,C_DEFAULT_MODULE), p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_igi_acct_hooks_pkg.trace');
END trace;

--=============================================================================
--                   ******* Print Log File **********
--=============================================================================
PROCEDURE print_logfile(p_msg  IN  VARCHAR2) IS
BEGIN

   fnd_file.put_line(fnd_file.log,p_msg);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_igi_acct_hooks_pkg.print_logfile');
END print_logfile;


--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
--
--
--
--
--
--
--
--
--
--
--
--    1.    main (procedure)
--
--
--
--
--
--
--
--
--
--
--=============================================================================

--=============================================================================

--============================================================================
--
--
--
--============================================================================
PROCEDURE main
       (p_application_id           IN NUMBER
       ,p_ledger_id                IN NUMBER
       ,p_process_category         IN VARCHAR2
       ,p_end_date                 IN DATE
       ,p_accounting_mode          IN VARCHAR2
       ,p_valuation_method         IN VARCHAR2
       ,p_security_id_int_1        IN NUMBER
       ,p_security_id_int_2        IN NUMBER
       ,p_security_id_int_3        IN NUMBER
       ,p_security_id_char_1       IN VARCHAR2
       ,p_security_id_char_2       IN VARCHAR2
       ,p_security_id_char_3       IN VARCHAR2
       ,p_report_request_id        IN NUMBER
       ,p_event_name               IN VARCHAR2)
IS
l_log_module         VARCHAR2(240);
l_sqlerrm            VARCHAR2(2000);
l_statement          VARCHAR2(1000) := NULL ;
l_count	             NUMBER := 0;
BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.main';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg    =>  'BEGIN of procedure Main'
         ,p_level  =>  C_LEVEL_PROCEDURE
         ,p_module =>  l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_mode = '||p_accounting_mode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_name = '||p_event_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) AND
      (p_event_name IN ('preaccounting','postaccounting'))
   THEN
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_process_category = '||p_process_category
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_end_date = '||p_end_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_1 = '||p_security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_2 = '||p_security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_3 = '||p_security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_1 = '||p_security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_2 = '||p_security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_3 = '||p_security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_report_request_id = '||p_report_request_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   select count(*) into l_count from user_objects
   where object_name = 'IGI_XLA_ACCOUNTING_MAIN_PKG'
   and object_type = 'PACKAGE BODY';

   ----------------------------------------------------------------------------
   -- Calling different event depending on event_name
   ----------------------------------------------------------------------------

   CASE
   WHEN  p_event_name = 'preaccounting'  THEN
      -------------------------------------------------------------------------
      -- Following code calls preaccounting API
      -------------------------------------------------------------------------
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Ready to call preaccounting API for IGI'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

 l_statement := 'BEGIN
igi_xla_accounting_main_pkg.preaccounting(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13);
END;';

IF ( l_count <> 0) THEN

       EXECUTE IMMEDIATE l_statement
       USING  IN p_application_id
                ,IN p_ledger_id
                ,IN p_process_category
                ,IN p_end_date
                ,IN p_accounting_mode
                ,IN p_valuation_method
                ,IN p_security_id_int_1
                ,IN p_security_id_int_2
                ,IN p_security_id_int_3
                ,IN p_security_id_char_1
                ,IN p_security_id_char_2
                ,IN p_security_id_char_3
                ,IN p_report_request_id;
END IF;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Control returned from preaccounting API'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

   WHEN p_event_name = 'extract'        THEN
      -------------------------------------------------------------------------
      -- Following code calls extract API
      -------------------------------------------------------------------------
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Ready to call extract API for IGI'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

 l_statement := 'BEGIN  igi_xla_accounting_main_pkg.extract(:1,:2); END;';

IF ( l_count <> 0) THEN

       EXECUTE IMMEDIATE l_statement
       USING  IN p_application_id
                ,IN p_accounting_mode;
END IF;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Control returned from extract API'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

   WHEN p_event_name = 'postprocessing'  THEN
      -------------------------------------------------------------------------
      -- Following code calls postprocessing API
      -------------------------------------------------------------------------
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Ready to call postprocessing API for IGI'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

 l_statement := 'BEGIN  igi_xla_accounting_main_pkg.postprocessing(:1,:2);
END;';

IF ( l_count <> 0) THEN

       EXECUTE IMMEDIATE l_statement
       USING  IN p_application_id
                ,IN p_accounting_mode;
END IF;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Control returned from postprocessing API'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

   WHEN p_event_name = 'postaccounting'  THEN
      -------------------------------------------------------------------------
      -- Following code calls postaccounting API
      -------------------------------------------------------------------------
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Ready to call postaccounting API for IGI'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

 l_statement := 'BEGIN
igi_xla_accounting_main_pkg.postaccounting(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13);
END;';

IF ( l_count <> 0) THEN

       EXECUTE IMMEDIATE l_statement
       USING  IN p_application_id
                ,IN p_ledger_id
                ,IN p_process_category
                ,IN p_end_date
                ,IN p_accounting_mode
                ,IN p_valuation_method
                ,IN p_security_id_int_1
                ,IN p_security_id_int_2
                ,IN p_security_id_int_3
                ,IN p_security_id_char_1
                ,IN p_security_id_char_2
                ,IN p_security_id_char_3
                ,IN p_report_request_id;
END IF;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Control returned from postaccounting API'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;
   END CASE;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   l_sqlerrm := fnd_message.get();

   IF (C_LEVEL_EXCEPTION>= g_log_level) THEN
      trace
         (p_msg      => 'Technical problem : Error encountered in product API for '||p_event_name||
                        xla_environment_pkg.g_chr_newline||
                        l_sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;

   xla_accounting_err_pkg.build_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
      ,p_token_1        => 'APPLICATION_NAME'
      ,p_value_1        => 'SLA'
      ,p_entity_id      => NULL
      ,p_event_id       => NULL);

   print_logfile('Technical problem : Error encountered in product API for '||p_event_name);

   xla_exceptions_pkg.raise_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_COMMON_ERROR'
      ,p_token_1        => 'LOCATION'
      ,p_value_1        => 'xla_igi_acct_hooks_pkg.main'
      ,p_token_2        => 'ERROR'
      ,p_value_2        => 'Technical problem : Error encountered in product API for '||p_event_name||
                           xla_environment_pkg.g_chr_newline||l_sqlerrm);
WHEN OTHERS THEN
   l_sqlerrm := sqlerrm;

   IF (C_LEVEL_EXCEPTION>= g_log_level) THEN
      trace
         (p_msg      => 'Technical problem : Error encountered in product API for '||p_event_name||
                        xla_environment_pkg.g_chr_newline||l_sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;

   xla_accounting_err_pkg.build_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
      ,p_token_1        => 'APPLICATION_NAME'
      ,p_value_1        => 'SLA'
      ,p_entity_id      => NULL
      ,p_event_id       => NULL);

   print_logfile('Technical problem : Error encountered in product API for '||p_event_name);

   xla_exceptions_pkg.raise_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_COMMON_ERROR'
      ,p_token_1        => 'LOCATION'
      ,p_value_1        => 'xla_igi_acct_hooks_pkg.main'
      ,p_token_2        => 'ERROR'
      ,p_value_2        => 'Technical problem : Error encountered in product API for '||p_event_name||
                           xla_environment_pkg.g_chr_newline||
                           l_sqlerrm);
END main;


--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;
END xla_igi_acct_hooks_pkg;

/
