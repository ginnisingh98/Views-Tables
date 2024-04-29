--------------------------------------------------------
--  DDL for Package Body XLA_CREATE_ACCT_RPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CREATE_ACCT_RPT_PVT" AS
-- $Header: xlaaprpt.pkb 120.9.12010000.4 2009/10/12 15:45:43 vkasina ship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|                                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|     XLA_CREATE_ACCT_RPT_PVT                                                |
|                                                                            |
| DESCRIPTION                                                                |
|     Package body. This provides XML extract for Create Accounting Report.  |
|                                                                            |
| HISTORY                                                                    |
|     01/27/2006  V. Swapna       Created                                    |
|     03/27/2006  V. Swapna       Modify the filter for zero amount lines    |
|                                 and add the initialization routine for the |
|                                 trace messages to appear in the fnd_log.   |
|     08/24/2006  Ejaz Sayyed     bug#5417847 change in condition to pick the|
|                                 negative amt lines and drop zero amt lines |
|                                 i.e.debit/credit <> 0 for p_zero_amt_filter|
|     02/16/2009  N. K. Surana    Instead of function calling new PROCEDURE  |
|                                 xla_report_utility_pkg.get_transaction_id  |
+===========================================================================*/

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240):= 'xla.plsql.XLA_CREATE_ACCT_RPT_PVT ';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;


PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2) IS
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
         (p_location   => 'XLA_CREATE_ACCT_RPT_PVT.trace');
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
         (p_location   => 'XLA_CREATE_ACCT_RPT_PVT.print_logfile');
END print_logfile;


--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
--
--
--
--    BeforeReport
--
--
--
--=============================================================================

FUNCTION BeforeReport RETURN BOOLEAN IS

l_errbuf                  VARCHAR2(2000);
l_accounting_batch_id     NUMBER;
l_request_id              NUMBER;
l_event_source_info       xla_events_pub_pkg.t_event_source_info;
l_log_module              VARCHAR2(240);
BEGIN
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||
                                 ' - Beginning of the Report');
  -- Get the user id

     SELECT fnd_profile.value('USER_ID') INTO p_user_id FROM dual;
  --
  -- Get the Request id of the concurrent program
  --
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('P_CONC_REQUEST_ID = '|| P_CONC_REQUEST_ID,C_LEVEL_STATEMENT,l_log_module);
       trace('P_USER_ID = '|| p_user_id,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   IF P_CONC_REQUEST_ID IS NOT NULL THEN
      RETURN(TRUE);
   END IF;

   P_CONC_REQUEST_ID := fnd_global.conc_request_id();

   P_REQUEST_ID := NVL(P_REQUEST_ID, P_CONC_REQUEST_ID);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('P_REQUEST_ID = '|| P_REQUEST_ID ,C_LEVEL_STATEMENT,l_log_module);
      trace('P_CONC_REQUEST_ID = '|| P_CONC_REQUEST_ID ,C_LEVEL_STATEMENT,l_log_module);
      trace('P_ENTITY_ID = '|| P_REQUEST_ID ,C_LEVEL_STATEMENT,l_log_module);
      trace('P_END_DATE = '|| P_END_DATE ,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   IF (P_REQUEST_ID = P_CONC_REQUEST_ID) THEN

      IF P_ENTITY_ID IS NULL THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace('Calling xla_accounting_pub_pkg.accounting_program_batch'
                 ,C_LEVEL_STATEMENT
                 ,l_log_module);
         END IF;

         xla_accounting_pub_pkg.accounting_program_batch
            (p_source_application_id   => P_SOURCE_APPLICATION_ID
            ,p_application_id          => P_APPLICATION_ID
            ,p_ledger_id               => P_LEDGER_ID
            ,p_process_category        => P_PROCESS_CATEGORY_CODE
            ,p_end_date                => P_END_DATE
            ,p_accounting_flag         => P_CREATE_ACCOUNTING_FLAG
            ,p_accounting_mode         => P_ACCOUNTING_MODE
            ,p_error_only_flag         => P_ERRORS_ONLY_FLAG
            ,p_transfer_flag           => P_TRANSFER_TO_GL_FLAG
            ,p_gl_posting_flag         => P_POST_IN_GL_FLAG
            ,p_gl_batch_name           => P_GL_BATCH_NAME
            ,p_valuation_method        => P_VALUATION_METHOD_CODE
            ,p_security_id_int_1       => P_SECURITY_INT_1
            ,p_security_id_int_2       => P_SECURITY_INT_2
            ,p_security_id_int_3       => P_SECURITY_INT_3
            ,p_security_id_char_1      => P_SECURITY_CHAR_1
            ,p_security_id_char_2      => P_SECURITY_CHAR_2
            ,p_security_id_char_3      => P_SECURITY_CHAR_3
            ,p_accounting_batch_id     => l_accounting_batch_id
            ,p_errbuf                  => l_errbuf
            ,p_retcode                 => C_ACCT_PROG_RETURN_CODE);

       ELSE

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace('Calling xla_accounting_pub_pkg.accounting_program_document'
                 ,C_LEVEL_STATEMENT
                 ,l_log_module);
          END IF;

          l_event_source_info.application_id := P_APPLICATION_ID;
          xla_accounting_pkg.accounting_program_document
                 (p_application_id             => P_APPLICATION_ID
                 ,p_entity_id                  => P_ENTITY_ID
                 ,p_accounting_flag            => P_CREATE_ACCOUNTING_FLAG
                 ,p_accounting_mode            => P_ACCOUNTING_MODE
                 ,p_gl_posting_flag            => P_POST_IN_GL_FLAG
                 ,p_offline_flag               => 'Y'
                 ,p_accounting_batch_id        => l_accounting_batch_id
                 ,p_errbuf                     => l_errbuf
                 ,p_retcode                    => C_ACCT_PROG_RETURN_CODE);

      END IF;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace('l_accounting_batch_id = '||l_accounting_batch_id ,C_LEVEL_STATEMENT ,l_log_module);
           trace('l_errbuf = '||l_errbuf ,C_LEVEL_STATEMENT ,l_log_module);
           trace('C_ACCT_PROG_RETURN_CODE = '||C_ACCT_PROG_RETURN_CODE ,C_LEVEL_STATEMENT ,l_log_module);
   END IF;


   FOR j IN 1..xla_transfer_pkg.g_arr_group_id.COUNT
      LOOP
         IF j=1 THEN
	    p_group_id_str := TO_CHAR(xla_transfer_pkg.g_arr_group_id(j));
	 ELSE
	    p_group_id_str := p_group_id_str||','|| TO_CHAR(xla_transfer_pkg.g_arr_group_id(j));
         END IF;
   END LOOP;

  --
  -- Get The User Transaction identifiers
  --
  IF p_include_user_trx_id_flag ='Y' AND P_REPORT_STYLE = 'D' THEN
     /* p_trx_identifiers :=
        xla_report_utility_pkg.get_transaction_id(p_application_id
                                                  ,p_ledger_id);  */  --Removed for bug 7580995

             xla_report_utility_pkg.get_transaction_id
            (p_resp_application_id  => p_application_id
            ,p_ledger_id            => p_ledger_id
            ,p_trx_identifiers_1    => p_trx_identifiers_1
            ,p_trx_identifiers_2    => p_trx_identifiers_2
            ,p_trx_identifiers_3    => p_trx_identifiers_3
            ,p_trx_identifiers_4    => p_trx_identifiers_4
            ,p_trx_identifiers_5    => p_trx_identifiers_5);  --Added for bug 7580995

  ELSE
   --p_trx_identifiers    := ' , NULL ';      --Removed for bug 7580995
     p_trx_identifiers_1  := ',NULL  USERIDS '; --Added for bug 7580995
  END IF;
   --
   -- Event Filter for Summary mode
   --

   IF P_REPORT_STYLE = 'S' THEN
      P_EVENT_FILTER := ' AND EVT.PROCESS_STATUS_CODE IN (''E'',''I'',''R'') ';
   END IF;

   --
   -- Filter for Zero Amount lines and Entries. Bugs 4339457 and 5100304
   --
   IF p_include_zero_amount_lines = 'N' THEN
      p_zero_amt_filter :=
         p_zero_amt_filter
                 ||' AND (NVL(ael.accounted_dr,0) <> 0 OR NVL(ael.accounted_cr,0) <> 0)
                     AND NVL(aeh.zero_amount_flag,''N'') = ''N''';
   END IF;

   P_REQ_ID := P_REQUEST_ID;

   IF p_application_id IS NOT NULL THEN
      p_application_query := '
          SELECT application_id                   application_id
                ,application_name                 application_name
                ,:p_req_id                        request_id
            FROM fnd_application_tl
           WHERE language                = USERENV(''LANG'')
             AND application_id          = :p_application_id';
   ELSE
      p_application_query := '
          SELECT fat.application_id                application_id
                ,fat.application_name              application_name
                ,:p_req_id                         request_id
            FROM fnd_application_tl      fat
           WHERE fat.language            = USERENV(''LANG'')
             AND EXISTS
                    (SELECT 1
                       FROM xla_events
                      WHERE application_id          = fat.application_id
                        AND request_id              = :p_req_id)';
   END IF;


  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace('End of BeforeReport '
                 ,C_LEVEL_STATEMENT
                 ,l_log_module);
  END IF;

  RETURN(TRUE);

EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location  => 'xla_create_acct_rpt_pvt.BeforeReport ');
END;


--=============================================================================
--
--
--
--    AfterReport
--
--
--
--=============================================================================

FUNCTION AfterReport RETURN BOOLEAN IS
l_temp         BOOLEAN;
l_log_module   VARCHAR2(240);
BEGIN

 IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace('BEGIN of AfterReport' ,C_LEVEL_STATEMENT ,l_log_module);
   trace('C_ACCT_PROG_RETURN_CODE = '||C_ACCT_PROG_RETURN_CODE,C_LEVEL_STATEMENT ,l_log_module);
 END IF;

  IF C_ACCT_PROG_RETURN_CODE = 0 THEN
        NULL;
  ELSIF C_ACCT_PROG_RETURN_CODE = 1 THEN
        l_temp := fnd_concurrent.set_completion_status
                     (status    => 'WARNING'
                     ,message   => NULL);
  ELSE
        l_temp := fnd_concurrent.set_completion_status
                     (status    => 'ERROR'
                     ,message   => NULL);
  END IF;


  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace('END of AfterReport'
           ,C_LEVEL_STATEMENT
           ,l_log_module);
  END IF;
  print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')|| ' - End of the Report');
  RETURN (TRUE);

EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
        (p_location   => 'xla_create_acct_rpt_pvt.AfterReport');

END;

--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

--=============================================================================
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
--=============================================================================

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;


END XLA_CREATE_ACCT_RPT_PVT  ;

/
