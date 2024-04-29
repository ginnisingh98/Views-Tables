--------------------------------------------------------
--  DDL for Package Body XLA_SEQUENCE_DATAFIX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_SEQUENCE_DATAFIX_PKG" AS
-- $Header: xlaseqdf.pkb 120.3 2006/05/04 22:48:39 masada ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     XLA_SEQUENCE_DATAFIX_PKG                                               |
|                                                                            |
| DESCRIPTION                                                                |
|     Package body for accounting sequence datafix                           |
|                                                                            |
| HISTORY                                                                    |
|     07/06/2004    W. Shen         Created                                  |
+===========================================================================*/

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================


C_PERIOD_STATUS_C   CONSTANT VARCHAR2(1) :='C'; --closed
C_PERIOD_STATUS_O   CONSTANT VARCHAR2(1) :='O'; --open
C_PERIOD_STATUS_F   CONSTANT VARCHAR2(1) :='F'; --future entry
C_PERIOD_STATUS_N   CONSTANT VARCHAR2(1) :='N'; --Never opened
C_PERIOD_STATUS_P   CONSTANT VARCHAR2(1) :='P'; --Permanently closed


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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.XLA_SEQUENCE_DATAFIX_PKG';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE reset_accounting_seq_num(p_application_id IN NUMBER
                          , p_ledger_id        IN NUMBER
                          , p_start_date       IN DATE
                          , p_seq_ver_id       IN NUMBER);

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2) IS
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
         (p_location   => 'XLA_SEQUENCE_DATAFIX_PKG.trace');
END trace;


PROCEDURE resequence_acct_seq(p_errbuf           OUT NOCOPY VARCHAR2
                          , p_retcode          OUT NOCOPY NUMBER
                          , p_application_id IN NUMBER
                          , p_ledger_id        IN NUMBER
                          , p_start_date       IN DATE
                          , p_ae_header_id     IN NUMBER
                          , p_period_name      IN VARCHAR2
                          , p_seq_ver_id       IN NUMBER) is
l_seq_ver_id NUMBER;
l_entry_status_code xla_ae_headers.accounting_entry_status_code%TYPE;
l_start_date DATE := null;
l_result     NUMBER:=0;
l_request_id NUMBER;
l_seq_context_value  fun_seq_batch.context_value_tbl_type;
l_seq_status     varchar2(30);
l_seq_context_id NUMBER;
l_log_module  VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.resequence_acct_seq';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure resequence_acct_seq'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  p_retcode := 0;

-- validate parameter
  IF(p_start_date is null and p_ae_header_id is null and p_period_name is null) THEN
    p_errbuf := 'start_date and ae_header_id and period_name can not be all null';
    p_retcode := 2;
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'end of procedure resequence_acct_seq'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => p_errbuf
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
    RETURN;
  END IF;

  IF(p_ae_header_id is not null) THEN
    SELECT accounting_entry_status_code, completion_acct_seq_version_id, completed_date
      INTO l_entry_status_code, l_seq_ver_id, l_start_date
      FROM xla_ae_headers
     WHERE ae_header_id   = p_ae_header_id
       AND application_id = p_application_id;

    IF (l_entry_status_code <> 'F') THEN
      p_errbuf := 'The entry with the id has not been finally accounted';
      p_retcode := 2;
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
             (p_msg      => 'end of procedure resequence_acct_seq'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);
        trace
             (p_msg      => p_errbuf
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);
      END IF;
      RETURN;
    END IF;

    IF(p_seq_ver_id is not null
         AND p_seq_ver_id <> nvl(l_seq_ver_id, p_seq_ver_id - 1)) THEN
      p_errbuf := 'ae_header_id and p_seq_ver_id does not match';
      p_retcode := 2;
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
             (p_msg      => 'end of procedure resequence_acct_seq'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);
        trace
             (p_msg      => p_errbuf
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);
      END IF;
      RETURN;
    END IF;
  END IF;

  if(l_seq_ver_id is null) THEN
    l_seq_ver_id :=p_seq_ver_id;
  END IF;

  l_start_date :=nvl(p_start_date, l_start_date);

  IF(l_start_date is null) THEN
    SELECT start_date
      INTO l_start_date
      FROM gl_period_statuses
     WHERE ledger_id=p_ledger_id
       AND application_id = 101
       AND period_name = p_period_name;
  END IF;

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
    trace
         (p_msg      => 'start date is:'||to_char(l_start_date)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  l_request_id := fnd_global.conc_request_id;

  l_seq_context_value(1)  := p_ledger_id;
  fun_seq_batch.Batch_init(p_application_id      => 602
                          ,p_table_name          => 'XLA_AE_HEADERS'
                          ,p_event_code          => 'COMPLETION'
                          ,p_context_type        => 'LEDGER_AND_CURRENCY'
                          ,p_context_value_tbl   =>l_seq_context_value
                          ,p_request_id          => l_request_id
                          ,x_status              => l_seq_status
                          ,x_seq_context_id      => l_seq_context_id);

  IF(l_seq_status = 'NO_SEQUENCING') THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'END of procedure resequence_acct_seq, no sequencing'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;

    RETURN;
  ELSE
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
           (p_msg      => 'fun_seq_batch.Batch_init executed, status success, id:'||to_char(l_seq_context_id)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
    END IF;
  END IF;

  IF(l_seq_ver_id is not null) THEN
    INSERT INTO xla_events_gt
      (event_id
      ,application_id
      ,ledger_id
      ,entity_code
      ,event_type_code
      ,event_date
      ,event_status_code
      )
    SELECT DISTINCT
      event_id
      ,p_application_id
      ,p_ledger_id
      ,'a'
      ,'a'
      ,sysdate
      ,'U'
    FROM xla_ae_headers
    WHERE completion_acct_seq_version_id = l_seq_ver_id
      AND ledger_id = p_ledger_id
      AND application_id = p_application_id
      AND accounting_entry_status_code = 'F'
      AND completed_date >= l_start_date;
    l_result :=  SQL%ROWCOUNT;
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
           (p_msg      => ' ver_id is not null, # of rows inserted:'||to_char(l_result)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
    END IF;

  ELSE
    INSERT INTO xla_events_gt
      (event_id
      ,application_id
      ,ledger_id
      ,entity_code
      ,event_type_code
      ,event_date
      ,event_status_code
      )
    SELECT DISTINCT
      event_id
      ,p_application_id
      ,p_ledger_id
      ,'a'
      ,'a'
      ,sysdate
     ,'U'
    FROM xla_ae_headers
    WHERE ledger_id = p_ledger_id
      AND application_id = p_application_id
      AND accounting_entry_status_code = 'F'
      AND (completed_date >= l_start_date or completed_date is null);
      --AND completion_acct_seq_version_id is not null;
    l_result :=  SQL%ROWCOUNT ;
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
           (p_msg      => ' ver_id is null, # of rows inserted:'||to_char(l_result)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
    END IF;
  END IF;
  IF(l_result>0) THEN
    reset_accounting_seq_num(p_application_id => p_application_id
                             ,p_ledger_id => p_ledger_id
                             ,p_start_date => l_start_date
                             ,p_seq_ver_id => l_seq_ver_id);
    fun_seq_batch.populate_acct_seq_info
               (p_calling_program         => 'ACCOUNTING'
               ,p_request_id              => l_request_id);
  END IF;

  fun_seq_batch.batch_exit
            (p_request_id             => l_request_id
            ,x_status                 => l_seq_status);
  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace
      (p_msg      => 'Procedure FUN_SEQ_BATCH.BATCH_EXIT executed'
      ,p_level    => C_LEVEL_EVENT
      ,p_module   => l_log_module);
  END IF;

  IF (C_LEVEL_EVENT>= g_log_level) THEN
    trace
      (p_msg      => 'l_seq_status = '||l_seq_status
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
       (p_msg      => 'END of resequence_acct_seq'
       ,p_level    => C_LEVEL_PROCEDURE
       ,p_module   => l_log_module);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    p_retcode := 2;
    p_errbuf   := xla_messages_pkg.get_message;
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
         (p_msg      => 'END of procedure resequence_acct_seq'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    END IF;

  WHEN OTHERS THEN
    p_retcode := 2;
    p_errbuf   := sqlerrm;
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
         (p_msg      => 'END of procedure resequence_acct_seq'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    END IF;


END resequence_acct_seq;


PROCEDURE reset_accounting_seq_num(p_application_id IN NUMBER
                          , p_ledger_id        IN NUMBER
                          , p_start_date       IN DATE
                          , p_seq_ver_id       IN NUMBER) is
l_seq_value  NUMBER:=null;
l_seq_ver_id NUMBER:=null;

cursor c_seq_ver is
  SELECT min(completion_acct_seq_value), completion_acct_seq_version_id
    FROM xla_ae_headers
   WHERE ledger_id = p_ledger_id
     AND application_id = p_application_id
     AND (completed_date >= p_start_date or completed_date is null)
     AND accounting_entry_status_code = 'F'
     --AND completion_acct_seq_version_id is not null
  GROUP BY completion_acct_seq_version_id;

l_entry_status_code xla_ae_headers.accounting_entry_status_code%TYPE;
l_start_date DATE := null;
l_log_module  VARCHAR2(240);

BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.reset_accounting_seq_num';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure reset_accounting_seq_num'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;


  IF(p_seq_ver_id is not null) THEN
    SELECT min(completion_acct_seq_value)
      INTO l_seq_value
      FROM xla_ae_headers
     WHERE ledger_id = p_ledger_id
       AND application_id = p_application_id
       AND accounting_entry_status_code = 'F'
       AND completed_date >= p_start_date
       AND completion_acct_seq_version_id = p_seq_ver_id;

    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
           (p_msg      => 'p_seq_ver_id:'||to_char(p_seq_ver_id) || ' value:'||to_char(l_seq_value)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
    END IF;


    IF(l_seq_value is not null) THEN
      fun_seq.reset(p_seq_version_id => p_seq_ver_id
                   ,p_sequence_number => l_seq_value - 1 );
      UPDATE xla_ae_headers
         SET completion_acct_seq_version_id = null
            ,completion_acct_seq_value = null
            ,completion_acct_seq_assign_id = null
            ,completed_date = null
       WHERE ledger_id = p_ledger_id
         AND application_id = p_application_id
         AND completed_date >= p_start_date
         AND accounting_entry_status_code = 'F'
         AND completion_acct_seq_version_id = p_seq_ver_id;
    END IF;
  ELSE
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
           (p_msg      => 'begin the loop to reset the seq'
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
    END IF;
    OPEN c_seq_ver;
    LOOP
      FETCH c_seq_ver into l_seq_value, l_seq_ver_id;
      EXIT WHEN c_seq_ver%NOTFOUND;
      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace
             (p_msg      => 'l_seq_ver_id:'||to_char(l_seq_ver_id) || ' value:'||to_char(l_seq_value)
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);
      END IF;
      IF(l_seq_ver_id is not null) THEN
        fun_seq.reset(p_seq_version_id => l_seq_ver_id
                   ,p_sequence_number => l_seq_value - 1);
      END IF;
    END LOOP;
    CLOSE c_seq_ver;
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
           (p_msg      => 'end the loop to reset the seq'
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
    END IF;
    UPDATE xla_ae_headers
       SET completion_acct_seq_version_id = null
          ,completion_acct_seq_value = null
          ,completion_acct_seq_assign_id = null
          ,completed_date = null
     WHERE ledger_id = p_ledger_id
       AND application_id = p_application_id
       AND accounting_entry_status_code = 'F'
       AND (completed_date >= p_start_date or completed_date is null);
--       AND completion_acct_seq_version_id is not null;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'END of procedure reset_accounting_seq_num'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

END reset_accounting_seq_num;

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
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END XLA_SEQUENCE_DATAFIX_PKG;

/
