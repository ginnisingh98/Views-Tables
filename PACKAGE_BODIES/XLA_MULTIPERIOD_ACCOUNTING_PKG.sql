--------------------------------------------------------
--  DDL for Package Body XLA_MULTIPERIOD_ACCOUNTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_MULTIPERIOD_ACCOUNTING_PKG" AS
-- $Header: xlampaac.pkb 120.10.12010000.4 2009/10/12 14:47:08 vkasina ship $
/*===========================================================================+
|             Copyright (c) 2005 Oracle Corporation                          |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_multiperiod_accounting_pkg                                         |
|                                                                            |
| DESCRIPTION                                                                |
|     This package contains the APIs related to the Complete Multiperiod     |
|     Accounting Program.                                                    |
|                                                                            |
| HISTORY                                                                    |
|     05/23/2005    eklau             Created                                |
|     02/15/2006    awan              5039413 performance fix                |
|     03/29/2006    awan              5115223 cannot complete MPA            |
+===========================================================================*/

-------------------------------------------------------------------------------
--              *********** Local Exceptions ************
-------------------------------------------------------------------------------

normal_termination     EXCEPTION;
resource_busy          EXCEPTION;
PRAGMA EXCEPTION_INIT(resource_busy, -54);

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_multiperiod_accounting_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;


--  Parameters

g_application_id               PLS_INTEGER;
g_ledger_id                    PLS_INTEGER;
g_process_category_code        VARCHAR2(30);
g_end_date                     DATE;
g_errors_only_flag             VARCHAR2(1);
g_transfer_to_gl_flag          VARCHAR2(1);
g_post_in_gl_flag              VARCHAR2(1);
g_gl_batch_name                VARCHAR2(50);
g_valuation_method_code        VARCHAR2(30);
g_security_id_int_1            PLS_INTEGER;
g_security_id_int_2            PLS_INTEGER;
g_security_id_int_3            PLS_INTEGER;
g_security_id_char_1           VARCHAR2(30);
g_security_id_char_2           VARCHAR2(30);
g_security_id_char_3           VARCHAR2(30);

g_request_id                   NUMBER;
g_accounting_batch_id          NUMBER;
g_total_error_count            NUMBER;
g_total_error_count_main       NUMBER;
g_security_condition           VARCHAR2(2000);
g_process_category_condition   VARCHAR2(2000);

g_array_ae_header_id   xla_je_validation_pkg.t_array_int; -- 5115223

--========================================================
-- Forward declarion of private procedures and functions
--========================================================

PROCEDURE Initialize
       (p_application_id             IN  NUMBER
       ,p_ledger_id                  IN  NUMBER
       ,p_process_category_code      IN  VARCHAR2
       ,p_end_date                   IN  DATE
       ,p_errors_only_flag           IN  VARCHAR2
       ,p_transfer_to_gl_flag        IN  VARCHAR2
       ,p_post_in_gl_flag            IN  VARCHAR2
       ,p_gl_batch_name              IN  VARCHAR2
       ,p_valuation_method_code      IN  VARCHAR2
       ,p_security_id_int_1          IN  NUMBER
       ,p_security_id_int_2          IN  NUMBER
       ,p_security_id_int_3          IN  NUMBER
       ,p_security_id_char_1         IN  VARCHAR2
       ,p_security_id_char_2         IN  VARCHAR2
       ,p_security_id_char_3         IN  VARCHAR2);

PROCEDURE Populate_Journal_Entries;

PROCEDURE Update_Journal_Entries;

PROCEDURE Populate_Sequences;

PROCEDURE Transfer_To_GL;

--===========================================================================
-- Local trace routine.
--===========================================================================

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
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
         (p_location   => 'xla_multiperiod_accounting_pkg.trace');
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
         (p_location   => 'xla_multiperiod_accounting_pkg.print_logfile');
END print_logfile;


--============================================================================
--
--  Public API which completes incomplete recognition journal entries and
--  accrual reversal journal entries.
--
--============================================================================

PROCEDURE Complete_Journal_Entries
       (p_application_id             IN  NUMBER
       ,p_ledger_id                  IN  NUMBER
       ,p_process_category_code      IN  VARCHAR2
       ,p_end_date                   IN  DATE
       ,p_errors_only_flag           IN  VARCHAR2
       ,p_transfer_to_gl_flag        IN  VARCHAR2
       ,p_post_in_gl_flag            IN  VARCHAR2
       ,p_gl_batch_name              IN  VARCHAR2
       ,p_valuation_method_code      IN  VARCHAR2
       ,p_security_id_int_1          IN  NUMBER
       ,p_security_id_int_2          IN  NUMBER
       ,p_security_id_int_3          IN  NUMBER
       ,p_security_id_char_1         IN  VARCHAR2
       ,p_security_id_char_2         IN  VARCHAR2
       ,p_security_id_char_3         IN  VARCHAR2
       ,p_accounting_batch_id        OUT NOCOPY NUMBER
       ,p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER) IS

   l_log_module                VARCHAR2(240);
   l_validation                NUMBER      := 0;
   l_ret_flag_bal_reversal     BOOLEAN     := FALSE;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Complete_Journal_Entries';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN procedure COMPLETE_JOURNAL_ENTRIES'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_process_category_code = '||p_process_category_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_end_date = '||to_char(p_end_date,'DD-MON-YYYY')
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_errors_only_flag = '||p_errors_only_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_transfer_to_gl_flag = '||p_transfer_to_gl_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_post_in_gl_flag = '||p_post_in_gl_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_gl_batch_name = '||p_gl_batch_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_valuation_method_code = '||p_valuation_method_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_security_id_int_1 = '||p_security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_security_id_int_1 = '||p_security_id_int_1
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

   END IF;

   Initialize
      (p_application_id                  => p_application_id
      ,p_ledger_id                       => p_ledger_id
      ,p_process_category_code           => p_process_category_code
      ,p_end_date                        => p_end_date
      ,p_errors_only_flag                => p_errors_only_flag
      ,p_transfer_to_gl_flag             => p_transfer_to_gl_flag
      ,p_post_in_gl_flag                 => p_post_in_gl_flag
      ,p_gl_batch_name                   => p_gl_batch_name
      ,p_valuation_method_code           => p_valuation_method_code
      ,p_security_id_int_1               => p_security_id_int_1
      ,p_security_id_int_2               => p_security_id_int_2
      ,p_security_id_int_3               => p_security_id_int_3
      ,p_security_id_char_1              => p_security_id_char_1
      ,p_security_id_char_2              => p_security_id_char_2
      ,p_security_id_char_3              => p_security_id_char_3);

   -- Populate xla_ae_headers_gt table for processing.

   Populate_Journal_Entries;

   -- Invoke API to validate and balance journal entries by balancing segments.

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Calling the function XLA_JE_VALIDATION_PKG.BALANCE_AMOUNTS'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   xla_accounting_cache_pkg.load_application_ledgers
      (p_application_id      => g_application_id
      ,p_event_ledger_id     => g_ledger_id);

   l_validation := XLA_JE_VALIDATION_PKG.Balance_Amounts
                         (p_application_id   => g_application_id
                         ,p_ledger_id        => g_ledger_id
                         ,p_mode             => 'COMPLETE_MPA'
                         ,p_end_date         => g_end_date
                         ,p_budgetary_control_mode => 'NONE'
                         ,p_accounting_mode  => 'F');

   If (l_validation = 1) then

      -- Error encountered in validation and balancing program.

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Error encountered in the XLA_JE_VALIDATION_PKG.Balance_Amounts function.'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;
   Else
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Routine XLA_JE_VALIDATION_PKG.Balance_Amounts executed.'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;
   End If;

   -- Invoke API to balance control account balances and analytical criterion balances.

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Calling the function XLA_BALANCES_PKG.MASSIVE_UPDATE'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   l_ret_flag_bal_reversal :=
           XLA_BALANCES_PKG.Massive_Update
                     (p_application_id                  => g_application_id
                     ,p_ledger_id                       => NULL
                     ,p_entity_id                       => NULL
                     ,p_event_id                        => NULL
                     ,p_request_id                      => NULL
                     ,p_accounting_batch_id             => g_accounting_batch_id
                     ,p_update_mode                     => 'A'
                     ,p_execution_mode                  => 'O');

   IF NOT l_ret_flag_bal_reversal THEN

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Error encountered in the function XLA_BALANCES_PKG.Massive_Update '
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      xla_accounting_err_pkg.build_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
         ,p_token_1        => 'APPLICATION_NAME'
         ,p_value_1        => 'SLA'
         ,p_entity_id      => NULL
         ,p_event_id       => NULL);

      print_logfile('Technical problem : Problem in the routine XLA_BALANCES_PKG.Massive_Update');

      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_multiperiod_accounting_pkg.complete_journal_entries'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'Technical problem : Problem in the routine XLA_BALANCES_PKG.Massive_Update');
   ELSE

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Call to function XLA_BALANCES_PKG.Massive_Update completed.'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;
      print_logfile('- call to XLA_BALANCES_PKG.Massive_Update completed');
   END IF;

   -- Update journal entry status.

   Update_journal_Entries;

   -- Track number of errors encountered during XLA routines.

   g_total_error_count_main := xla_accounting_err_pkg.g_error_count;

   -- Populate document sequence.

   Populate_Sequences;

   -- Transfer to GL.

   If (g_transfer_to_gl_flag = 'Y') then
      Transfer_To_Gl;
   End If;

   ----------------------------------------------------------------------------
   -- insert any errors that were build in this session (for them to appear
   -- on the report).
   ----------------------------------------------------------------------------
   g_total_error_count := xla_accounting_err_pkg.g_error_count;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_total_error_count = '||g_total_error_count
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   --
   -- If errors were encountered during sequencing and/or transfer to GL
   -- then rollback to allow reprocessing of JE headers.  Otherwise, it
   -- will be possible to have "completed" entries without the proper
   -- sequencing data and/or properly transferred to GL.
   --

   If (g_total_error_count > g_total_error_count_main) then
      rollback;
   End If;

   xla_accounting_err_pkg.insert_errors;
   COMMIT;

   ----------------------------------------------------------------------------
   -- set return variables
   ----------------------------------------------------------------------------

   p_accounting_batch_id := g_accounting_batch_id;

   IF g_total_error_count = 0 THEN
      p_retcode             := 0;
      p_errbuf              := 'Complete Multiperiod Accounting Program completed Normal';
   ELSE
      p_retcode             := 1;
      p_errbuf              := 'Complete Multiperiod Accounting Program completed Normal with some entries in error';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure COMPLETE_JOURNAL_ENTRIES'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN

      ----------------------------------------------------------------------------
      -- set out variables
      ----------------------------------------------------------------------------
      p_accounting_batch_id    := g_accounting_batch_id;
      p_retcode                := 2;
      p_errbuf                 := xla_messages_pkg.get_message;

      print_logfile(p_errbuf);

      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            (p_msg      => NULL
            ,p_level    => C_LEVEL_ERROR
            ,p_module   => l_log_module);
      END IF;

      ----------------------------------------------------------------------------
      -- insert any errors that were build in this session (for them to appear
      -- on the report).
      ----------------------------------------------------------------------------
      rollback;

      xla_accounting_err_pkg.insert_errors;
      COMMIT;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_msg      => 'p_retcode = '||p_retcode
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
         trace
            (p_msg      => 'p_errbuf = '||p_errbuf
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
         trace
            (p_msg      => 'END of procedure COMPLETE_JOURNAL_ENTRIES'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
      END IF;

   WHEN OTHERS THEN
      xla_accounting_err_pkg.build_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
         ,p_token_1        => 'XLA_MULTIPERIOD_ACCOUNTING_PKG.Complete_Journal_Entries'
         ,p_value_1        => 'SLA'
         ,p_entity_id      => NULL
         ,p_event_id       => NULL);

      rollback;

      xla_accounting_err_pkg.insert_errors;
      COMMIT;

      xla_exceptions_pkg.raise_message
         (p_location       => 'xla_multiperiod_accounting_pkg.complete_journal_entries');

END complete_journal_entries; -- end of procedure


--============================================================================
--
-- Private API which initializes the complete multiperiod accounting program.
--
--============================================================================

PROCEDURE Initialize
       (p_application_id             IN  NUMBER
       ,p_ledger_id                  IN  NUMBER
       ,p_process_category_code      IN  VARCHAR2
       ,p_end_date                   IN  DATE
       ,p_errors_only_flag           IN  VARCHAR2
       ,p_transfer_to_gl_flag        IN  VARCHAR2
       ,p_post_in_gl_flag            IN  VARCHAR2
       ,p_gl_batch_name              IN  VARCHAR2
       ,p_valuation_method_code      IN  VARCHAR2
       ,p_security_id_int_1          IN  NUMBER
       ,p_security_id_int_2          IN  NUMBER
       ,p_security_id_int_3          IN  NUMBER
       ,p_security_id_char_1         IN  VARCHAR2
       ,p_security_id_char_2         IN  VARCHAR2
       ,p_security_id_char_3         IN  VARCHAR2)
IS
   l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Initialize';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN procedure INITIALIZE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


   -- Initialize global params.

   g_application_id          := p_application_id;
   g_ledger_id               := p_ledger_id;
   g_process_category_code   := p_process_category_code;
   g_end_date                := p_end_date;
   g_errors_only_flag        := p_errors_only_flag;
   g_transfer_to_gl_flag     := p_transfer_to_gl_flag;
   g_post_in_gl_flag         := p_post_in_gl_flag;
   g_gl_batch_name           := p_gl_batch_name;
   g_valuation_method_code   := p_valuation_method_code;
   g_security_id_int_1       := p_security_id_int_1;
   g_security_id_int_2       := p_security_id_int_2;
   g_security_id_int_3       := p_security_id_int_3;
   g_security_id_char_1      := p_security_id_char_1;
   g_security_id_char_2      := p_security_id_char_2;
   g_security_id_char_3      := p_security_id_char_3;


   -- Set request id.

   g_request_id              := FND_GLOBAL.Conc_Request_Id();

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_request_id = '||g_request_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   xla_security_pkg.set_security_context(p_application_id);

   -- Set new accounting batch id.

   Select xla_accounting_batches_s.nextval
     into g_accounting_batch_id
     from dual;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_accounting_batch_id = '||g_accounting_batch_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   -- Initialize errors package.

   XLA_ACCOUNTING_ERR_PKG.Set_Options
      (p_error_source     => xla_accounting_err_pkg.C_ACCT_PROGRAM
      ,p_request_id       => g_request_id
      ,p_application_id   => p_application_id);


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure INITIALIZE '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_accounting_err_pkg.build_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
         ,p_token_1        => 'XLA_MULTIPERIOD_ACCOUNTING_PKG.Initialize'
         ,p_value_1        => 'SLA'
         ,p_entity_id      => NULL
         ,p_event_id       => NULL);

      xla_exceptions_pkg.raise_message
         (p_location       => 'xla_multiperiod_accounting_pkg.Initialize');
END Initialize;


--============================================================================
--
--  Private API which populates the xla_ae_headers_gt table with journal
--  entries to be completed and reset its status to 'Incomplete'.
--
--  The accounting entries to be completed must fullfill the following
--  conditions:
--
--  (1) The journal entry is an accrual reversal entry or a multiperiod
--      accounting recognition entry.
--  (2) Filtered by the input parameters.
--  (3) The accounting entry status of the accrual entry of the entry to
--      be completed is 'Final'.
--
--============================================================================

PROCEDURE Populate_Journal_Entries
IS

   l_stmt          VARCHAR2(5000);
   l_count         NUMBER  := 0;
   l_log_module    VARCHAR2(240);

   l_err_msg    varchar2(100);
   l_err_num    number;

   Cursor C_SEL_HDRS is
   Select accounting_entry_status_code
     from xla_ae_headers
    where ae_header_id in (Select ae_header_id from xla_ae_headers_gt)
     and application_id = g_application_id
      for update nowait;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Populate_Journal_Entries';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN procedure POPULATE_JOURNAL_ENTRIES'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   g_security_condition := NULL;

   -- Building filter condition based on security columns and valuation method
   -- This condition will be added dynamically to select statemtents.

   SELECT DECODE(g_valuation_method_code,NULL,NULL,'and valuation_method = '''||g_valuation_method_code||''' ')||
          DECODE(g_security_id_int_1,NULL,NULL,'and security_id_int_1 = '||g_security_id_int_1||' ')||
          DECODE(g_security_id_int_2,NULL,NULL,'and security_id_int_2 = '||g_security_id_int_2||' ')||
          DECODE(g_security_id_int_3,NULL,NULL,'and security_id_int_3 = '||g_security_id_int_3||' ')||
          DECODE(g_security_id_char_1,NULL,NULL,'and security_id_char_1 = '''||g_security_id_char_1||''' ')||
          DECODE(g_security_id_char_2,NULL,NULL,'and security_id_char_2 = '''||g_security_id_char_2||''' ')||
          DECODE(g_security_id_char_3,NULL,NULL,'and security_id_char_3 = '''||g_security_id_char_3||''' ')
     INTO g_security_condition
     FROM DUAL;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
          (p_msg      => 'g_security_condition = '||g_security_condition
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
   End If;

   -- Building filter condition based process_category.
   -- This condition will be added dynamically to select statemtents.

   g_process_category_condition := NULL;

   SELECT DECODE(g_process_category_code,NULL,NULL,'and event_class_group_code = '''||g_process_category_code||'''')
     INTO g_process_category_condition
     FROM DUAL;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
          (p_msg      => 'g_process_category_condition = '||g_process_category_condition
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
   End If;

   -- Insert the journal entries to be completed into xla_ae_headers_gt.

   l_stmt := 'INSERT INTO xla_ae_headers_gt
                          (ae_header_id
                          ,ledger_id
                          ,entity_id
                          ,event_id
                          ,accounting_date
                          ,balance_type_code
                          ,je_category_name
                          ,product_rule_type_code
                          ,product_rule_code
                          ,period_name
                          ,doc_sequence_id
                          ,doc_category_code
                          ,gl_transfer_status_code
                          ,accrual_reversal_flag
                          ,accounting_entry_status_code)
              SELECT /*+ INDEX(xah xla_ae_headers_n7) */ xah.ae_header_id
                    ,xlr.ledger_id
                    ,xah.entity_id
                    ,xah.event_id
                    ,xah.accounting_date
                    ,xah.balance_type_code
                    ,xah.je_category_name
                    ,xah.product_rule_type_code
                    ,xah.product_rule_code
                    ,xah.period_name
                    ,xah.doc_sequence_id
                    ,xah.doc_category_code
                    ,xah.gl_transfer_status_code
                    ,xah.accrual_reversal_flag
                    ,''F''
              FROM  xla_ae_headers             xah
                  , xla_ae_headers             xah2
                  , xla_ledger_relationships_v xlr
                  , xla_subledgers             xs
                  , xla_event_types_b          xet
                  , xla_event_class_attrs      xec
                  , xla_transaction_entities    xte
              WHERE xlr.primary_ledger_id         = :1
                and xlr.relationship_enabled_flag = ''Y''
                and xlr.ledger_category_code      in (''ALC'',''PRIMARY'',''SECONDARY'')
                and xlr.ledger_id                 = xah.ledger_id
                and xah.application_id            = :2
                and xah.accounting_date           <= :3
                and xah.accounting_entry_status_code
                            IN (''I'', DECODE(:4, ''Y'', ''I'', ''N''))
                AND xah.application_id         = xah2.application_id
                AND xah.parent_ae_header_id    = xah2.ae_header_id
                AND xah2.accounting_entry_status_code = ''F''
                AND xs.application_id          = xah.application_id
                AND EXISTS (SELECT NULL
                              FROM xla_ledger_options xlo
                             WHERE application_id = xah.application_id
                               AND DECODE(xlr.ledger_category_code
                                         ,''ALC'',xlr.ledger_id
                                         ,xlo.ledger_id) = xlr.ledger_id
                               AND DECODE(xlr.ledger_category_code
                                         ,''SECONDARY'',xlo.capture_event_flag
                                         ,''N'') = ''N''
                               AND DECODE(xlr.ledger_category_code
                                         ,''ALC'',''Y''
                                         ,xlo.enabled_flag) = ''Y'')
                AND xte.application_id         = xah.application_id
                AND xte.entity_id              = xah.entity_id
                AND xte.entity_code            <> ''MANUAL''
                AND xet.application_id         = xah.application_id
                AND xet.event_type_code        = xah.event_type_code
                AND xec.application_id         = xet.application_id
                AND xec.entity_code            = xet.entity_code
                AND xec.event_class_code       = xet.event_class_code' ||
                g_security_condition || ' ' ||
                g_process_category_condition;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
          (p_msg      => 'l_stmt = '||l_stmt
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
   End If;

   print_logfile('- Dynamic stmt to populate xla_ae_headers_gt table built');

   EXECUTE IMMEDIATE l_stmt
     USING g_ledger_id
          ,g_application_id
          ,g_end_date
          ,g_errors_only_flag;

   l_count := SQL%ROWCOUNT;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# lines inserted = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
   END IF;

   print_logfile('- xla_ae_headers_gt table populuated');

   If (l_count = 0) then
      If (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'No incomplete recognition journal entries and accrual reversal ' ||
                           'journal entries fetched for the application. '||
                           'There are no events to process in this run.'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      xla_accounting_err_pkg.build_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_AP_NO_EVENT_TO_PROCESS'
         ,p_entity_id      => NULL
         ,p_event_id       => NULL);

      print_logfile('Technical warning : There are no Incomplete entries to process.');

   Else

      --
      -- Reset journal entry status for the journal entry to be completed
      --

      Update xla_ae_headers
         Set accounting_entry_status_code  = 'N'
           , request_id                    = g_request_id
           , accounting_batch_id           = g_accounting_batch_id
           , last_update_date              = sysdate
           , last_updated_by               = xla_environment_pkg.g_usr_id
           , last_update_login             = xla_environment_pkg.g_login_id
       Where application_id = g_application_id
         and ae_header_id in (Select ae_header_id from xla_ae_headers_gt)
       RETURNING  ae_header_id   BULK COLLECT INTO g_array_ae_header_id;   -- 5115223

      -- Lock rows in main headers table selected for processing.

      Begin
         Open  C_SEL_HDRS;
         Close C_SEL_HDRS;
      Exception
         When resource_busy Then
            xla_accounting_err_pkg.build_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_MA_HDR_LOCKED'
               ,p_entity_id      => NULL
               ,p_event_id       => NULL);

            print_logfile('Technical problem : JE Headers of transactions to be completed cannot be locked.');

            xla_exceptions_pkg.raise_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_MA_HDR_LOCKED');

         When Others Then
            xla_exceptions_pkg.raise_message
               (p_location       => 'xla_multiperiod_accounting_pkg.Populate_Journal_Entries');
      End;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => '# lines updated = '||SQL%ROWCOUNT,
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
      END IF;

   End If;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END procedure POPULATE_JOURNAL_ENTRIES'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_accounting_err_pkg.build_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
         ,p_token_1        => 'XLA_MULTIPERIOD_ACCOUNTING_PKG.Populate_Journal_Entries'
         ,p_value_1        => 'SLA'
         ,p_entity_id      => NULL
         ,p_event_id       => NULL);

      xla_exceptions_pkg.raise_message
         (p_location       => 'xla_multiperiod_accounting_pkg.Populate_Journal_Entries');

END Populate_Journal_Entries;


--============================================================================
--
-- Private API which updates the journal entry completed in the current run.
--
--============================================================================

PROCEDURE Update_Journal_Entries
IS
   l_log_module               VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Update_Journal_Entries';
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure UPDATE_JOURNAL_ENTRIES'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => '# incomplete ='||g_array_ae_header_id.COUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   FORALL i IN 1..g_array_ae_header_id.COUNT  -- 5115223
      UPDATE xla_ae_headers xah
      SET    accounting_entry_status_code = 'F'
            ,completed_date               = sysdate
      WHERE  xah.request_id          = g_request_id
      AND    xah.accounting_batch_id = g_accounting_batch_id
      AND    xah.application_id      = g_application_id
      AND    xah.ae_header_id        = g_array_ae_header_id(i)
      AND    accounting_entry_status_code NOT IN ('I', 'R');


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'Number of headers updated = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of procedure UPDATE_JOURNAL_ENTRIES '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS THEN
      xla_accounting_err_pkg.build_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
         ,p_token_1        => 'XLA_MULTIPERIOD_ACCOUNTING_PKG.Update_Journal_Entries'
         ,p_value_1        => 'SLA'
         ,p_entity_id      => NULL
         ,p_event_id       => NULL);

      xla_exceptions_pkg.raise_message
         (p_location       => 'xla_multiperiod_accounting_pkg.Update_Journal_Entries');
END Update_Journal_Entries;


--============================================================================
--
-- Private API which populates the completion sequence number for the journal
-- entries to be completed.
--
--============================================================================

PROCEDURE Populate_Sequences
IS
   l_seq_context_value     fun_seq_batch.context_value_tbl_type;
   l_xla_seq_status        VARCHAR2(30);
   l_xla_seq_context_id    NUMBER;
   l_log_module            VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Populate_Sequences';
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure POPULATE_SEQUENCES'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   --
   -- Insert the journal entry to be sequenced to the XLA_EVENTS_GT
   -- and the sequencing batch API will use the GT table to identify
   -- the journal entry to be sequenced.
   --

   INSERT INTO xla_events_gt
               (application_id
               ,ledger_id
               ,entity_id
               ,entity_code
               ,event_id)
        SELECT DISTINCT
               g_application_id
              ,g_ledger_id
              ,h.entity_id
              ,t.entity_code
              ,h.event_id
         FROM xla_ae_headers_gt h,
              xla_transaction_entities t
        WHERE h.entity_id = t.entity_id
        AND h.ledger_id = t.ledger_id
        AND t.application_id = g_application_id
        AND t.ledger_id = g_ledger_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'Number of journal entries to be sequenced = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
   END IF;

   --
   -- Retrieve all primary, secondary, and ALC ledgers
   --

   SELECT xlr.ledger_id BULK COLLECT
     INTO l_seq_context_value
     FROM xla_ledger_relationships_v       xlr
         ,xla_subledger_options_v          xso
    WHERE xlr.relationship_enabled_flag    = 'Y'
      AND xlr.ledger_category_code         IN ('ALC','PRIMARY','SECONDARY')
      AND DECODE(xso.valuation_method_flag
                 ,'N',xlr.primary_ledger_id
                 ,DECODE(xlr.ledger_category_code
                         ,'ALC',xlr.primary_ledger_id
                         ,xlr.ledger_id)
                 )                         = g_ledger_id
      AND xso.application_id               = g_application_id
      AND xso.ledger_id                    = DECODE(xlr.ledger_category_code
                                                    ,'ALC',xlr.primary_ledger_id
                                                    ,xlr.ledger_id)
      AND xso.enabled_flag                  = 'Y';

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'Number of ledgers to be sequenced = '|| l_seq_context_value.COUNT
           ,p_module => l_log_module
           ,p_level  => C_LEVEL_STATEMENT);
   END IF;

   --
   -- Create sequence in batch mode
   --

   IF (C_LEVEL_EVENT>= g_log_level) THEN
      trace(p_msg      => 'Calling FUN_SEQ_BATCH.Batch_Init'
           ,p_level    => C_LEVEL_EVENT
           ,p_module   => l_log_module);
   END IF;

   fun_seq_batch.batch_init
         (p_application_id      => 602
         ,p_table_name          => 'XLA_AE_HEADERS'
         ,p_event_code          => 'COMPLETION'
         ,p_context_type        => 'LEDGER_AND_CURRENCY'
         ,p_context_value_tbl   => l_seq_context_value
         ,p_request_id          => g_request_id
         ,x_status              => l_xla_seq_status
         ,x_seq_context_id      => l_xla_seq_context_id);

   IF l_xla_seq_status <> 'NO_SEQUENCING' THEN

      fun_seq_batch.populate_acct_seq_info
         (p_calling_program        => 'ACCOUNTING'
         ,p_request_id             => g_request_id);

      fun_seq_batch.batch_exit
         (p_request_id             => g_request_id
         ,x_status                 => l_xla_seq_status);

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure POPULATE_SEQUENCES '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS THEN
      xla_accounting_err_pkg.build_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
      ,p_token_1        => 'XLA_MULTIPERIOD_ACCOUNTING_PKG.Populate_Sequences'
      ,p_value_1        => 'SLA'
      ,p_entity_id      => NULL
      ,p_event_id       => NULL);

      xla_exceptions_pkg.raise_message
         (p_location       => 'xla_multiperiod_accounting_pkg.Populate_Sequences');
END Populate_Sequences;



--============================================================================
--
--   Private API which transfer the accounting entry to GL if required.
--
--============================================================================

PROCEDURE Transfer_To_GL
IS
   l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Transfer_To_GL';
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure TRANSFER_TO_GL'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   xla_accounting_err_pkg.set_options
       (p_error_source     => xla_accounting_err_pkg.C_TRANSFER_TO_GL);

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Calling transfer routine XLA_TRANSFER_PKG.GL_TRANSFER_MAIN'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   xla_transfer_pkg.gl_transfer_main
         (p_application_id        => g_application_id
         ,p_transfer_mode         => 'COMBINED'
         ,p_ledger_id             => g_ledger_id
         ,p_securiy_id_int_1      => NULL
         ,p_securiy_id_int_2      => NULL
         ,p_securiy_id_int_3      => NULL
         ,p_securiy_id_char_1     => NULL
         ,p_securiy_id_char_2     => NULL
         ,p_securiy_id_char_3     => NULL
         ,p_valuation_method      => NULL
         ,p_process_category      => g_process_category_code
         ,p_accounting_batch_id   => g_accounting_batch_id
         ,p_entity_id             => NULL
         ,p_batch_name            => g_gl_batch_name
         ,p_end_date              => g_end_date
         ,p_submit_gl_post        => g_post_in_gl_flag
         ,p_caller                => xla_transfer_pkg.C_MPA_COMPLETE); -- Bug 5056632

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Transfer routine XLA_TRANSFER_PKG.GL_TRANSFER_MAIN executed'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   xla_accounting_err_pkg.set_options
       (p_error_source     => xla_accounting_err_pkg.C_ACCT_PROGRAM);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure TRANSFER_TO_GL '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_accounting_err_pkg.build_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
         ,p_token_1        => 'XLA_MULTIPERIOD_ACCOUNTING_PKG.Transfer_To_GL'
         ,p_value_1        => 'SLA'
         ,p_entity_id      => NULL
         ,p_event_id       => NULL);

      xla_exceptions_pkg.raise_message
         (p_location       => 'xla_multiperiod_accounting_pkg.Transfer_To_GL');
END Transfer_To_GL;


--=============================================================================
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--=============================================================================

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_multiperiod_accounting_pkg; -- end of package body

/
