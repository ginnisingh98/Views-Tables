--------------------------------------------------------
--  DDL for Package Body XLA_REPORTING_SEQUENCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_REPORTING_SEQUENCE_PKG" AS
-- $Header: xlarepseq.pkb 120.7.12010000.2 2009/03/18 14:15:48 nksurana ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     XLA_REPORTING_SEQUENCE_PKG                                             |
|                                                                            |
| DESCRIPTION                                                                |
|     Package body for reporting sequence.                                   |
|                                                                            |
| HISTORY                                                                    |
|     07/16/2004    W. Shen         Created                                  |
+===========================================================================*/

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================


C_PERIOD_STATUS_C   CONSTANT VARCHAR2(1) :='C'; --closed
C_PERIOD_STATUS_O   CONSTANT VARCHAR2(1) :='O'; --open
C_PERIOD_STATUS_F   CONSTANT VARCHAR2(1) :='F'; --future entry
C_PERIOD_STATUS_N   CONSTANT VARCHAR2(1) :='N'; --Never opened
C_PERIOD_STATUS_P   CONSTANT VARCHAR2(1) :='P'; --Permanently closed

TYPE t_reset_seq IS REF CURSOR;

PROCEDURE reset_reporting_seq_num(p_ledger_id    IN NUMBER
                          , p_start_date           IN DATE
                          , p_end_date             IN DATE
                          , p_sort_date       IN VARCHAR2);
PROCEDURE populate_seq_gt_table(p_ledger_id    IN NUMBER
                          , p_start_date           IN DATE
                          , p_end_date             IN DATE
                          , p_sort_date       IN VARCHAR2);
PROCEDURE update_entries_from_gt;

PROCEDURE assign_sequence(p_ledger_id    IN NUMBER
                          , p_period_name   IN VARCHAR2
                          , p_errbuf        OUT NOCOPY VARCHAR2
                          , p_retcode       OUT NOCOPY NUMBER);

PROCEDURE reset_sequence(p_ledger_id    IN NUMBER
                          , p_period_name   IN VARCHAR2
                          , p_errbuf        OUT NOCOPY VARCHAR2
                          , p_retcode       OUT NOCOPY NUMBER);

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.XLA_REPORTING_SEQUENCE_PKG';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

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
         (p_location   => 'XLA_REPORTING_SEQUENCE_PKG.trace');
END trace;


--=============================================================================
--  This function is the subscription routine to gl workflow business event
--  oracle.apps.gl.CloseProcess.period.close. It get the parameters of the
--  event and submit a concurrent request
--=============================================================================

FUNCTION period_close(p_subscription_guid IN raw,
                          p_event IN OUT NOCOPY WF_EVENT_T) return varchar2 is
l_parameter_list wf_parameter_list_t;
l_ledger_id number;
l_period_name varchar2(100);
l_log_module  VARCHAR2(240);
l_request_id number;
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.period_close';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure period_close'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  -- get the parameter of the event
  l_parameter_list := p_event.getParameterList;
  l_period_name:=wf_event.getValueForParameter('PERIOD_NAME', l_parameter_list);
  l_ledger_id:=to_number(wf_event.getValueForParameter('LEDGER_ID', l_parameter_list));
--  insert_to('close:'||l_period_name ||' '||to_char(l_ledger_id));

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
    trace
         (p_msg      => 'period_name:'|| l_period_name
                                   || ' ledger_id:'||to_char(l_ledger_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  -- launch the concurrent request
  l_request_id :=
            fnd_request.submit_request
               (application     => 'XLA'
               ,program         => 'XLAREPSEQ'
               ,description     => NULL
               ,start_time      => NULL
               ,sub_request     => FALSE
               ,argument1       => l_ledger_id
               ,argument2       => l_period_name
               ,argument3       => 'ASSIGN');
  IF l_request_id = 0 THEN
    xla_exceptions_pkg.raise_message
        (p_appli_s_name   => 'XLA'
        ,p_msg_name       => 'XLA_REP_TECHNICAL_ERROR'
        ,p_token_1        => 'APPLICATION_NAME'
        ,p_value_1        => 'SLA');

  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'END of procedure period_close'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  return 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    return 'ERROR';
END period_close;

--=============================================================================
--  This function is the subscription routine to gl workflow business event
--  oracle.apps.gl.CloseProcess.period.reopen. It get the parameters of the
--  event and submit a concurrent request
--=============================================================================

FUNCTION period_reopen(p_subscription_guid IN raw,
                          p_event IN OUT NOCOPY WF_EVENT_T) return varchar2 is
l_parameter_list wf_parameter_list_t;
l_ledger_id number;
l_period_name varchar2(100);
l_log_module  VARCHAR2(240);
l_request_id NUMBER;
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.period_reopen';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure period_reopen'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;


  -- get the parameter of the event
  l_parameter_list := p_event.getParameterList;
  l_period_name:=wf_event.getValueForParameter('PERIOD_NAME', l_parameter_list);
  l_ledger_id:=to_number(wf_event.getValueForParameter('LEDGER_ID', l_parameter_list));
  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
    trace
         (p_msg      => 'periodname:'||l_period_name ||' ledger_id:'||to_char(l_ledger_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  -- launch the concurrent request
  l_request_id :=
            fnd_request.submit_request
               (application     => 'XLA'
               ,program         => 'XLAREPSEQ'
               ,description     => NULL
               ,start_time      => NULL
               ,sub_request     => FALSE
               ,argument1       => l_ledger_id
               ,argument2       => l_period_name
               ,argument3       => 'RESET');
  IF l_request_id = 0 THEN
    xla_exceptions_pkg.raise_message
        (p_appli_s_name   => 'XLA'
        ,p_msg_name       => 'XLA_REP_TECHNICAL_ERROR'
        ,p_token_1        => 'APPLICATION_NAME'
        ,p_value_1        => 'SLA');

  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'END of procedure period_reopen'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  return 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    return 'ERROR';
END period_reopen;


--=============================================================================
--  This procedure is registered as a concurrent request to assign/reset the
--  reporting sequence. The concurrent request is launched when gl period is
--  closed or reopened.
--=============================================================================

PROCEDURE reporting_sequence(p_errbuf      OUT NOCOPY VARCHAR2
                          , p_retcode      OUT NOCOPY NUMBER
                          , p_ledger_id    IN NUMBER
                          , p_period_name  IN VARCHAR2
                          , p_mode         IN VARCHAR2) is

l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.reporting_sequence';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure reporting_sequence'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  IF(p_mode='ASSIGN') THEN
    assign_sequence(p_ledger_id   => p_ledger_id
                   ,p_period_name => p_period_name
                   ,p_errbuf      => p_errbuf
                   ,p_retcode     => p_retcode);
  ELSIF(p_mode='RESET') THEN
    reset_sequence(p_ledger_id   => p_ledger_id
                   ,p_period_name => p_period_name
                   ,p_errbuf      => p_errbuf
                   ,p_retcode     => p_retcode);
  ELSE
    p_errbuf := 'INVALID MODE';
    p_retcode := 2;
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure reporting_sequence'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

END reporting_sequence;

PROCEDURE get_end_date(p_ledger_id IN NUMBER
                      ,p_end_date IN OUT NOCOPY DATE) is

l_end_date  DATE;
l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_end_date';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure get_end_date'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    trace
         (p_msg      => 'parameter:ledger_id:'||to_char(p_ledger_id)
                            || ' end_date:'||to_char(p_end_date)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;


  SELECT min(start_date)
    INTO l_end_date
    FROM gl_period_statuses
   WHERE ledger_id=p_ledger_id
     AND adjustment_period_flag = 'N'
     AND CLOSING_STATUS in (C_PERIOD_STATUS_O, C_PERIOD_STATUS_F, C_PERIOD_STATUS_N)
     AND start_date>p_end_date
     AND application_id = 101;

  IF (l_end_date is null) THEN
  -- all the following period is closed or permentantly closed
    SELECT max(end_date)
      INTO l_end_date
      FROM gl_period_statuses
     WHERE ledger_id=p_ledger_id
       AND adjustment_period_flag = 'N'
       AND end_date>=p_end_date
       AND application_id = 101;
    p_end_date := trunc(l_end_date)+1;
  ELSE
    p_end_date := trunc(l_end_date);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'END of procedure get_end_date'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    trace
         (p_msg      => 'return value of end_date'||to_char(p_end_date)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;
END get_end_date;

FUNCTION already_assigned(p_ledger_id    IN NUMBER
                         ,p_period_name  IN VARCHAR2
                         ,p_start_date   IN DATE
                         ,p_end_date     IN DATE
                         ,p_sort_date IN VARCHAR2 ) return boolean is
cursor c_gl_date is
        SELECT 1
          FROM gl_je_headers gjh
               , xla_subledgers xs
         WHERE gjh.ledger_id = p_ledger_id
           AND gjh.period_name = p_period_name
           AND gjh.status = 'P'
           AND (gjh.parent_je_header_id is not null or xs.je_source_name is null)
           AND gjh.close_acct_seq_version_id is null
           AND gjh.default_effective_date>= p_start_date
           AND gjh.default_effective_date< p_end_date;

cursor c_ref_date is
        SELECT 1
          FROM gl_je_headers gjh
               , xla_subledgers xs
         WHERE ledger_id = p_ledger_id
           AND period_name = p_period_name
           AND gjh.status = 'P'
           AND (gjh.parent_je_header_id is not null or xs.je_source_name is null)
           AND close_acct_seq_version_id is null
           AND nvl(gjh.reference_date, gjh.posted_date) >= p_start_date
           AND nvl(gjh.reference_date, gjh.posted_date) < p_end_date;

cursor c_comp_date is
        SELECT 1
          FROM gl_je_headers gjh
               , xla_subledgers xs
         WHERE ledger_id = p_ledger_id
           AND period_name = p_period_name
           AND gjh.status = 'P'
           AND (gjh.parent_je_header_id is not null or xs.je_source_name is null)
           AND close_acct_seq_version_id is null
           AND gjh.posted_date >= p_start_date
           AND gjh.posted_date < p_end_date;

l_temp NUMBER;
l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.already_assigned';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of function already_assigned'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  IF(p_sort_date = 'GL_DATE') THEN
    OPEN c_gl_date;
    FETCH c_gl_date into l_temp;
    IF(c_gl_date%NOTFOUND) THEN
      l_temp := 0;
    END IF;
    CLOSE c_gl_date;
  ELSIF (p_sort_date = 'REFERENCE_DATE') THEN
    OPEN c_ref_date;
    FETCH c_ref_date into l_temp;
    IF(c_ref_date%NOTFOUND) THEN
      l_temp := 0;
    END IF;
    CLOSE c_ref_date;
  ELSE
    OPEN c_comp_date;
    FETCH c_comp_date into l_temp;
    IF(c_comp_date%NOTFOUND) THEN
      l_temp := 0;
    END IF;
    CLOSE c_comp_date;
  END IF;

  IF (l_temp = 0 ) THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'end of function already_assigned, return true'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;

    RETURN TRUE;
  ELSE
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'end of function already_assigned, return false'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
    RETURN FALSE;
  END IF;
END already_assigned;

--=============================================================================
--  This procedure is called by the concurrent request.
--  reporting sequence. The concurrent request is launched when gl period is
--  closed or reopened.
--=============================================================================

PROCEDURE assign_sequence(p_ledger_id    IN NUMBER
                          , p_period_name   IN VARCHAR2
                          , p_errbuf        OUT NOCOPY VARCHAR2
                          , p_retcode       OUT NOCOPY NUMBER) is
l_exception exception;
l_parameter_list wf_parameter_list_t;
l_ledger_id number;
l_period_name varchar2(100);
l_seq_context_value  fun_seq_batch.context_value_tbl_type;
l_xla_seq_status     varchar2(30);
l_gl_seq_status      varchar2(30);
l_start_date         gl_period_statuses.start_date%TYPE;
l_end_date           gl_period_statuses.end_date%TYPE;
l_adjustment_flag    gl_period_statuses.adjustment_period_flag%TYPE;
l_xla_seq_context_id NUMBER;
l_gl_seq_context_id  NUMBER;
l_sort_date          VARCHAR2(30);

l_log_module  VARCHAR2(240);

l_request_id    NUMBER;

l_temp NUMBER;
cursor c_open_previous_normal_period is
  SELECT 1
    FROM gl_period_statuses
   WHERE ledger_id = p_ledger_id
     AND start_date<l_start_date
     AND closing_status = C_PERIOD_STATUS_O
     AND adjustment_period_flag = 'N'
     AND application_id = 101;


begin
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.assign_sequence';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure assign_sequence'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    trace
         (p_msg      => 'parameter: ledger_id:'|| to_char(p_ledger_id)
                            || ' period_name:'|| p_period_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  p_retcode := 0;

  -- get the start date and end date of the period
  SELECT trunc(start_date), trunc(end_date), adjustment_period_flag
    INTO l_start_date, l_end_date, l_adjustment_flag
    FROM GL_PERIOD_STATUSES
   WHERE ledger_id = p_ledger_id
     AND period_name = p_period_name
     AND application_id = 101;

  -- find if there is previous open period
  open c_open_previous_normal_period;
  fetch c_open_previous_normal_period into l_temp;
  IF(c_open_previous_normal_period%NOTFOUND) THEN
    l_temp := 0;
  END IF;
  close c_open_previous_normal_period;

  IF(l_temp = 1) THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'previous period open, end of procedure assign_sequence'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
    return;
  END IF;

  l_request_id := fnd_global.conc_request_id;

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
    trace
         (p_msg      => 'request_id:'|| to_char(l_request_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  IF (C_LEVEL_EVENT>= g_log_level) THEN
    trace
         (p_msg      => 'calling fun_seq_batch.batch_init'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
  END IF;

  -- call fun_seq_batch.batch_init
  -- for xla first
  l_seq_context_value(1)  := p_ledger_id;
  fun_seq_batch.Batch_init(p_application_id => 602
                          ,p_table_name     => 'XLA_AE_HEADERS'
                          ,p_event_code     => 'PERIOD_CLOSE'
                          ,p_context_type   => 'LEDGER_AND_CURRENCY'
                          ,p_context_value_tbl =>l_seq_context_value
                          ,p_request_id     => l_request_id
                          ,x_status         => l_xla_seq_status
                          ,x_seq_context_id      => l_xla_seq_context_id);

  -- for gl
  fun_seq_batch.Batch_init(p_application_id => 101
                          ,p_table_name     => 'GL_JE_HEADERS'
                          ,p_event_code     => 'PERIOD_CLOSE'
                          ,p_context_type   => 'LEDGER_AND_CURRENCY'
                          ,p_context_value_tbl =>l_seq_context_value
                          ,p_request_id     => l_request_id
                          ,x_status         => l_gl_seq_status
                          ,x_seq_context_id      => l_gl_seq_context_id);

  IF (C_LEVEL_EVENT>= g_log_level) THEN
    trace
         (p_msg      => 'after calling fun_seq_batch.batch_init'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
  END IF;

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
    trace
         (p_msg      => 'xla_seq_status:'||l_xla_seq_status||' id:'||to_char(l_xla_seq_context_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    trace
         (p_msg      => 'gl_seq_status:'||l_gl_seq_status||' id:'||to_char(l_gl_seq_context_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;
  -- only if there is sequence set up, start the sequence
  IF (l_xla_seq_status = 'SUCCESS' or l_gl_seq_status = 'SUCCESS') then

    -- get the sort date of each context
    -- l_sort_date will have value 'GL_DATE', 'REFERENCE_DATE' or 'COMPLETION_DATE'
    IF(l_gl_seq_status = 'SUCCESS') THEN
      SELECT nvl(SORT_OPTION, DATE_TYPE)
        INTO l_sort_date
        FROM FUN_SEQ_CONTEXTS
       WHERE SEQ_CONTEXT_ID = l_gl_seq_context_id;
    ELSE
      SELECT nvl(SORT_OPTION, DATE_TYPE)
        INTO l_sort_date
        FROM FUN_SEQ_CONTEXTS
       WHERE SEQ_CONTEXT_ID = l_xla_seq_context_id;
    END IF;

    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'sortdate:'||to_char(l_sort_date)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;

    IF(l_adjustment_flag = 'Y') THEN
      --check if there is entries from the adjustment period that is not
      -- sequenced yet.
      -- only gl have entry in adjustment period
      IF(l_gl_seq_status='SUCCESS' and
             already_assigned(p_ledger_id    => p_ledger_id
                         ,p_period_name  => p_period_name
                         ,p_start_date   => l_start_date
                         ,p_end_date     => l_end_date
                         ,p_sort_date    => l_sort_date)) THEN
        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace
               (p_msg      => 'adjustment period, already assigned. End of assign_sequence'
               ,p_level    => C_LEVEL_PROCEDURE
               ,p_module   => l_log_module);
        END IF;
        fun_seq_batch.Batch_exit(p_request_id => l_request_id
                                ,x_status     => l_gl_seq_status); --Added for bug 8310543
        RETURN;
      END IF;
    END IF;

    -- get the end date of the date range
    get_end_date(p_ledger_id  => p_ledger_id
                ,p_end_date   => l_end_date);

    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'end date:'||to_char(l_end_date)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;

    IF(l_adjustment_flag = 'Y') THEN
      -- get the normal entry start date
      -- reset the sequence number.
      SELECT trunc(max(start_date))
        INTO l_start_date
        FROM gl_period_statuses
       WHERE ledger_id = p_ledger_id
         AND start_date <= l_start_date
         AND adjustment_period_flag = 'N'
         AND application_id = 101;

      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace
           (p_msg      => 'adjustment period, normal start date:'||to_char(l_start_date)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;
      -- is it possible that gl has set up but not xla?
      reset_reporting_seq_num( p_ledger_id    => p_ledger_id
                          , p_start_date      => l_start_date
                          , p_end_date        => l_end_date
                          , p_sort_date       => l_sort_date);

    END IF;

    populate_seq_gt_table(p_ledger_id      => p_ledger_id
                          ,p_start_date    => l_start_date
                          ,p_end_date      => l_end_date
                          ,p_sort_date     => l_sort_date);

    IF (C_LEVEL_EVENT>= g_log_level) THEN
      trace
           (p_msg      => 'before calling fun_seq_batch.populate_acct_seq_info'
           ,p_level    => C_LEVEL_EVENT
           ,p_module   => l_log_module);
    END IF;

    fun_seq_batch.populate_acct_seq_info(p_calling_program => 'REPORTING'
                                         ,p_request_id     => l_request_id);

    IF (C_LEVEL_EVENT>= g_log_level) THEN
      trace
           (p_msg      => 'after calling fun_seq_batch.populate_acct_seq_info'
           ,p_level    => C_LEVEL_EVENT
           ,p_module   => l_log_module);
    END IF;

    update_entries_from_gt;

    IF (l_xla_seq_status = 'SUCCESS') THEN
      fun_seq_batch.Batch_exit(p_request_id => l_request_id
                              ,x_status     => l_xla_seq_status);
    END IF;
    IF (l_gl_seq_status = 'SUCCESS') THEN
      fun_seq_batch.Batch_exit(p_request_id => l_request_id
                              ,x_status     => l_gl_seq_status);
    END IF;
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure assign_sequence'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    trace
       (p_msg      => 'p_retcode = '||p_retcode
       ,p_level    => C_LEVEL_PROCEDURE
       ,p_module   => l_log_module);
    trace
       (p_msg      => 'p_errbuf = '||p_errbuf
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
         (p_msg      => 'END of procedure assign_sequence'
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
         (p_msg      => 'END of procedure assign_sequence'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    END IF;
END assign_sequence;

--=============================================================================
--  This procedure is called by the concurrent request.
--  reporting sequence. The concurrent request is launched when gl period is
--  closed or reopened.
--=============================================================================

PROCEDURE reset_sequence(p_ledger_id    IN NUMBER
                          , p_period_name   IN VARCHAR2
                          , p_errbuf        OUT NOCOPY VARCHAR2
                          , p_retcode       OUT NOCOPY NUMBER) is
l_log_module  VARCHAR2(240);
l_ledger_id number;
l_period_name varchar2(100);
l_seq_context_value  fun_seq_batch.context_value_tbl_type;
l_xla_seq_status     varchar2(30);
l_gl_seq_status      varchar2(30);
l_start_date         gl_period_statuses.start_date%TYPE;
l_end_date           gl_period_statuses.end_date%TYPE;
l_adjustment_flag    gl_period_statuses.adjustment_period_flag%TYPE;
l_xla_seq_context_id NUMBER;
l_gl_seq_context_id  NUMBER;
l_sort_date          VARCHAR2(30);
l_temp               NUMBER;
l_request_id         NUMBER;

cursor c_open_previous_normal_period is
  SELECT 1
    FROM gl_period_statuses
   WHERE ledger_id = p_ledger_id
     AND start_date<l_start_date
     AND closing_status = C_PERIOD_STATUS_O
     AND adjustment_period_flag = 'N'
     AND application_id = 101;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.reset_sequence';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure reset_sequence'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  -- get the start date and end date of the period
  SELECT trunc(start_date), trunc(end_date), adjustment_period_flag
    INTO l_start_date, l_end_date, l_adjustment_flag
    FROM GL_PERIOD_STATUSES
   WHERE ledger_id = p_ledger_id
     AND period_name = p_period_name
     AND application_id = 101;

  IF(l_adjustment_flag = 'Y') THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'end of procedure reset_sequence, adjustment period'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
    RETURN;
  END IF;

  open c_open_previous_normal_period;
  fetch c_open_previous_normal_period into l_temp;
  IF(c_open_previous_normal_period%NOTFOUND) THEN
    l_temp := 0;
  END IF;
  close c_open_previous_normal_period;

  IF(l_temp = 1) THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'end of procedure reset_sequence, previous period open'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
    RETURN;
  END IF;

  l_request_id := fnd_global.conc_request_id;

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
    trace
         (p_msg      => 'request_id:'|| to_char(l_request_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  IF (C_LEVEL_EVENT>= g_log_level) THEN
    trace
         (p_msg      => 'calling fun_seq_batch.batch_init'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
  END IF;
  -- call fun_seq_batch.batch_init
  -- for xla first
  l_seq_context_value(1)  := p_ledger_id;
  fun_seq_batch.Batch_init(p_application_id => 602
                          ,p_table_name     => 'XLA_AE_HEADERS'
                          ,p_event_code     => 'PERIOD_CLOSE'
                          ,p_context_type   => 'LEDGER_AND_CURRENCY'
                          ,p_context_value_tbl =>l_seq_context_value
                          ,p_request_id     => l_request_id
                          ,x_status         => l_xla_seq_status
                          ,x_seq_context_id      => l_xla_seq_context_id);

  -- for gl
  fun_seq_batch.Batch_init(p_application_id => 101
                          ,p_table_name     => 'GL_JE_HEADERS'
                          ,p_event_code     => 'PERIOD_CLOSE'
                          ,p_context_type   => 'LEDGER_AND_CURRENCY'
                          ,p_context_value_tbl =>l_seq_context_value
                          ,p_request_id     => l_request_id
                          ,x_status         => l_gl_seq_status
                          ,x_seq_context_id      => l_gl_seq_context_id);

  IF (C_LEVEL_EVENT>= g_log_level) THEN
    trace
         (p_msg      => 'after calling fun_seq_batch.batch_init'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
  END IF;

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
    trace
         (p_msg      => 'xla_seq_status:'||l_xla_seq_status||' id:'||to_char(l_xla_seq_context_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    trace
         (p_msg      => 'gl_seq_status:'||l_gl_seq_status||' id:'||to_char(l_gl_seq_context_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  -- only if there is sequence set up, start the sequence
  IF (l_xla_seq_status = 'SUCCESS' or l_gl_seq_status = 'SUCCESS') then

    -- get the sort date of each context
    -- l_sort_date will have value 'GL_DATE', 'REFERENCE_DATE' or 'COMPLETION_DATE'
    IF(l_gl_seq_status = 'SUCCESS') THEN
      SELECT nvl(SORT_OPTION, DATE_TYPE)
        INTO l_sort_date
        FROM FUN_SEQ_CONTEXTS
       WHERE SEQ_CONTEXT_ID = l_gl_seq_context_id;
    ELSE
      SELECT nvl(SORT_OPTION, DATE_TYPE)
        INTO l_sort_date
        FROM FUN_SEQ_CONTEXTS
       WHERE SEQ_CONTEXT_ID = l_xla_seq_context_id;
    END IF;

    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'sortdate:'||to_char(l_sort_date)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;

    get_end_date(p_ledger_id  => p_ledger_id
                ,p_end_date   => l_end_date);

    reset_reporting_seq_num( p_ledger_id    => p_ledger_id
                          , p_start_date      => l_start_date
                          , p_end_date        => l_end_date
                          , p_sort_date       => l_sort_date);
    IF (l_xla_seq_status = 'SUCCESS') THEN
      fun_seq_batch.Batch_exit(p_request_id => l_request_id
                              ,x_status     => l_xla_seq_status);
    END IF;
    IF (l_gl_seq_status = 'SUCCESS') THEN
      fun_seq_batch.Batch_exit(p_request_id => l_request_id
                              ,x_status     => l_gl_seq_status);
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure reset_sequence'
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
         (p_msg      => 'END of procedure assign_sequence'
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
         (p_msg      => 'END of procedure assign_sequence'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    END IF;
END reset_sequence;

PROCEDURE update_entries_from_gt is
l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_entries_from_gt';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure update_entries_from_gt'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  UPDATE gl_je_headers gjh
     SET (gjh.close_acct_seq_value
          ,gjh.close_acct_seq_version_id
          ,gjh.close_acct_seq_assign_id) =
         (select xgt.sequence_value
                ,xgt.sequence_version_id
                ,xgt.sequence_assign_id
            FROM xla_seq_je_headers_gt xgt
           WHERE xgt.application_id = 101
             AND gjh.je_header_id   = xgt.ae_header_id)
  WHERE gjh.je_header_id in (select ae_header_id from xla_seq_je_headers_gt where application_id=101);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  UPDATE xla_ae_headers xah
     SET (xah.close_acct_seq_value
          ,xah.close_acct_seq_version_id
          ,xah.close_acct_seq_assign_id) =
         (SELECT xgt.sequence_value
                ,xgt.sequence_version_id
                ,xgt.sequence_assign_id
            FROM xla_seq_je_headers_gt xgt
           WHERE xgt.application_id = 602
             AND xah.ae_header_id   = xgt.ae_header_id)
  WHERE xah.ae_header_id in (select ae_header_id from xla_seq_je_headers_gt where application_id=602);

/*
  UPDATE (SELECT xah.close_acct_seq_value
                ,xah.close_acct_seq_version_id
                ,xah.close_acct_seq_assign_id
                ,xgt.sequence_assign_id
                ,xgt.sequence_version_id
                ,xgt.sequence_value
            FROM xla_ae_headers xah
                ,xla_seq_je_headers_gt xgt
           WHERE xgt.application_id = 602
             AND xah.ae_header_id   = xgt.ae_header_id)
     SET close_acct_seq_value=sequence_value
        ,close_acct_seq_version_id = sequence_version_id
        ,close_acct_seq_assign_id = sequence_assign_id;
*/

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure update_entries_from_gt'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

END update_entries_from_gt;

/*==============================================================
-- assumption1: p_gl_sort_date and p_xla_sort_date must be the same
==============================================================*/

PROCEDURE reset_reporting_seq_num(p_ledger_id    IN NUMBER
                          , p_start_date           IN DATE
                          , p_end_date             IN DATE
                          , p_sort_date       IN VARCHAR2) is

c_reset_cursor t_reset_seq;
l_seq_value    NUMBER;
l_seq_ver_id   NUMBER;
l_log_module  VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.reset_reporting_seq_num';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure reset_reporting_seq_num'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    trace
         (p_msg      => 'p_ledger_id:'||to_char(p_ledger_id)
                               || 'p_start:'||to_char(p_start_date)
                               || 'p_end:'||to_char(p_end_date)
                               || 'p_sort_date:'||p_sort_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;


  IF(p_sort_date = 'GL_DATE') THEN
    OPEN c_reset_cursor FOR
      SELECT min(close_acct_seq_value), close_acct_seq_version_id
        FROM (
            SELECT close_acct_seq_value, close_acct_seq_version_id
              FROM xla_ae_headers
             WHERE ledger_id=p_ledger_id
               AND accounting_date >= p_start_date
               AND accounting_date < p_end_date
               AND close_acct_seq_version_id is not null
               AND gl_transfer_status_code = 'Y'
               AND accounting_entry_status_code = 'F'
            UNION
            SELECT close_acct_seq_value, close_acct_seq_version_id
              FROM gl_je_headers
             WHERE ledger_id=p_ledger_id
               AND default_effective_date >= p_start_date
               AND default_effective_date < p_end_date
               AND status = 'P'
               AND close_acct_seq_version_id is not null
             )
      GROUP BY close_acct_seq_version_id;
  ELSIF (p_sort_date = 'REFERENCE_DATE') THEN
    OPEN c_reset_cursor FOR
      SELECT min(close_acct_seq_value), close_acct_seq_version_id
        FROM (
            SELECT close_acct_seq_value, close_acct_seq_version_id
              FROM xla_ae_headers
             WHERE ledger_id=p_ledger_id
               AND nvl(reference_date, accounting_date) >= p_start_date
               AND nvl(reference_date, accounting_date) < p_end_date
               AND close_acct_seq_version_id is not null
               AND gl_transfer_status_code = 'Y'
               AND accounting_entry_status_code = 'F'
            UNION
            SELECT close_acct_seq_value, close_acct_seq_version_id
              FROM gl_je_headers gjh, gl_period_statuses gps
             WHERE gjh.ledger_id=p_ledger_id
               AND nvl(gjh.reference_date, decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date)) >= p_start_date
               AND nvl(gjh.reference_date, decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date)) < p_end_date
               AND gjh.status = 'P'
               AND gjh.close_acct_seq_version_id is not null
               AND gps.application_id = 101
               AND gps.ledger_id=p_ledger_id
               AND gps.period_name = gjh.period_name
             )
      GROUP BY close_acct_seq_version_id;
  ELSE
    OPEN c_reset_cursor FOR
      SELECT min(close_acct_seq_value), close_acct_seq_version_id
        FROM (
            SELECT close_acct_seq_value, close_acct_seq_version_id
              FROM xla_ae_headers
             WHERE ledger_id=p_ledger_id
               AND  nvl(completed_date,accounting_date)>= p_start_date
               AND nvl(completed_date,accounting_date) < p_end_date
               AND close_acct_seq_version_id is not null
               AND gl_transfer_status_code = 'Y'
               AND accounting_entry_status_code = 'F'
            UNION
            SELECT close_acct_seq_value, close_acct_seq_version_id
              FROM gl_je_headers
             WHERE ledger_id=p_ledger_id
               AND posted_date >= p_start_date
               AND posted_date < p_end_date
               AND status = 'P'
               AND close_acct_seq_version_id is not null
             )
      GROUP BY close_acct_seq_version_id;
  END IF;

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
    trace
         (p_msg      => 'just before loop'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;
  LOOP
    FETCH c_reset_cursor into l_seq_value, l_seq_ver_id;
    EXIT WHEN c_reset_cursor%NOTFOUND;

    fun_seq.reset(p_seq_version_id => l_seq_ver_id
                 ,p_sequence_number => l_seq_value -1 );
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
           (p_msg      => 'ver_id:'||to_char(l_seq_ver_id) || ' ver value:'||
                                     to_char(l_seq_value -1 )
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
    END IF;
  END LOOP;
  CLOSE c_reset_cursor;

  IF(p_sort_date = 'GL_DATE') THEN
    UPDATE xla_ae_headers
       SET close_acct_seq_value = null
          ,close_acct_seq_version_id = null
          ,close_acct_seq_assign_id = null
     WHERE ledger_id=p_ledger_id
       AND accounting_date >= p_start_date
       AND accounting_date < p_end_date
       AND close_acct_seq_version_id is not null
       AND gl_transfer_status_code = 'Y'
       AND accounting_entry_status_code = 'F';

    UPDATE gl_je_headers
       SET close_acct_seq_value = null
          ,close_acct_seq_version_id = null
          ,close_acct_seq_assign_id = null
     WHERE ledger_id=p_ledger_id
       AND default_effective_date >= p_start_date
       AND default_effective_date < p_end_date
       AND status = 'P'
       AND close_acct_seq_version_id is not null;

  ELSIF (p_sort_date = 'REFERENCE_DATE') THEN

    UPDATE xla_ae_headers
       SET close_acct_seq_value = null
          ,close_acct_seq_version_id = null
          ,close_acct_seq_assign_id = null
     WHERE ledger_id=p_ledger_id
       AND nvl(reference_date, accounting_date) >= p_start_date
       AND nvl(reference_date, accounting_date) < p_end_date
       AND close_acct_seq_version_id is not null
       AND gl_transfer_status_code = 'Y'
       AND accounting_entry_status_code = 'F';

    UPDATE gl_je_headers
       SET close_acct_seq_value = null
          ,close_acct_seq_version_id = null
          ,close_acct_seq_assign_id = null
     WHERE je_header_id in
           (
            SELECT gjh.je_header_id
              FROM gl_je_headers gjh, gl_period_statuses gps
             WHERE gjh.ledger_id=p_ledger_id
               AND nvl(gjh.reference_date, decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date)) >= p_start_date
               AND nvl(gjh.reference_date, decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date)) < p_end_date
               AND gjh.status = 'P'
               AND gjh.close_acct_seq_version_id is not null
               AND gps.application_id = 101
               AND gps.ledger_id=p_ledger_id
               AND gps.period_name = gjh.period_name
             );
  ELSE
    UPDATE xla_ae_headers
       SET close_acct_seq_value = null
          ,close_acct_seq_version_id = null
          ,close_acct_seq_assign_id = null
     WHERE ledger_id=p_ledger_id
       AND nvl(completed_date,accounting_date) >= p_start_date
       AND nvl(completed_date,accounting_date) < p_end_date
       AND close_acct_seq_version_id is not null
       AND gl_transfer_status_code = 'Y'
       AND accounting_entry_status_code = 'F';

    UPDATE gl_je_headers
       SET close_acct_seq_value = null
          ,close_acct_seq_version_id = null
          ,close_acct_seq_assign_id = null
     WHERE ledger_id=p_ledger_id
       AND posted_date >= p_start_date
       AND posted_date < p_end_date
       AND status = 'P'
       AND close_acct_seq_version_id is not null;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'END of procedure reset_reporting_seq_num'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

END reset_reporting_seq_num;


PROCEDURE populate_seq_gt_table(p_ledger_id    IN NUMBER
                          , p_start_date           IN DATE
                          , p_end_date             IN DATE
                          , p_sort_date       IN VARCHAR2) is
l_log_module  VARCHAR2(240);
l_temp        NUMBER:=0;

-- if there is such segment defined, we need check before inserting into the table
-- otherwise, all the segments are balancing segments.

cursor c_analytical_segment_defined(l_ledger_id NUMBER) is
              SELECT 1
                FROM gl_ledger_segment_values glsv
                    ,gl_ledger_norm_seg_vals glnsv
               WHERE
                     glsv.ledger_id                      = l_ledger_id
                 AND glsv.segment_type_code              = 'B'
                 AND glsv.parent_record_id               = glnsv.record_id
                 AND nvl(glnsv.sla_sequencing_flag, 'Y') = 'N'
                 AND glsv.Status_code                    is NULL
                 AND glnsv.Status_code                    is NULL;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_seq_gt_table';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure populate_seq_gt_table'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  open c_analytical_segment_defined(p_ledger_id);
  fetch c_analytical_segment_defined into l_temp;
  IF(c_analytical_segment_defined%NOTFOUND) THEN
    l_temp := 0;
  END IF;
  close c_analytical_segment_defined;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
           (p_msg      => 'analytical segment defined:'||to_char(l_temp)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
  END IF;

  IF (l_temp = 1) THEN
    IF (p_sort_date = 'GL_DATE') THEN
    -- populate the table XLA_SEQ_JE_HEADERS_GT
      INSERT INTO XLA_SEQ_JE_HEADERS_GT
         (application_id
         ,ledger_id
         ,ae_header_id
         ,je_source_name
         ,je_category_name
         ,gl_date
         ,reference_date
         ,completion_posted_date)
      (SELECT 101
            ,p_ledger_id
            ,gjh.je_header_id
            ,gjh.je_source
            ,gjh.je_category
            ,gjh.default_effective_date
            ,nvl(gjh.reference_date,
               decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date))
            ,gjh.posted_date
       FROM gl_je_headers      gjh
           ,gl_period_statuses gps
           ,xla_subledgers xs
       WHERE gjh.ledger_id                 = p_ledger_id
         AND gjh.default_effective_date    >= p_start_date
         AND gjh.default_effective_date    < p_end_date
         AND gjh.status                    = 'P'
         AND gjh.actual_flag               = 'A'
         AND (   gjh.parent_je_header_id is not null
              OR xs.je_source_name is null
              -- 6722378
              OR (gjh.global_attribute_category = 'JE.GR.GLXJEENT.HEADER' AND xs.je_source_name = 'Project Accounting')
             )
         AND gjh.je_source                 =  xs.je_source_name (+)
         AND gps.application_id            =  101
         AND gjh.period_name               = gps.period_name
         AND gps.ledger_id                 = p_ledger_id
         AND exists
             (SELECT 1
                FROM gl_ledger_segment_values glsv
                    ,gl_ledger_norm_seg_vals glnsv
                    ,gl_je_segment_values gljsv
               WHERE gljsv.je_header_id                  = gjh.je_header_id
                 AND glsv.ledger_id              (+)     = p_ledger_id
                 AND gljsv.segment_type_code             = 'B'
                 AND gljsv.segment_type_code             = glsv.segment_type_code (+)
                 AND gljsv.segment_value                 = glsv.segment_value (+)
                 AND glsv.parent_record_id               = glnsv.record_id (+)
                 AND glsv.status_code                    is NULL
                 AND glnsv.status_code                   is NULL
                 AND nvl(glnsv.sla_sequencing_flag, 'Y') = 'Y')
       );
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;

    ELSIF (p_sort_date = 'REFERENCE_DATE') THEN
    -- populate the table XLA_SEQ_JE_HEADERS_GT
      INSERT INTO XLA_SEQ_JE_HEADERS_GT
       (application_id
       ,ledger_id
       ,ae_header_id
       ,je_source_name
       ,je_category_name
       ,gl_date
       ,reference_date
       ,completion_posted_date)
      (SELECT 101
            ,p_ledger_id
            ,gjh.je_header_id
            ,gjh.je_source
            ,gjh.je_category
            ,gjh.default_effective_date
            ,nvl(gjh.reference_date, decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date))
            ,gjh.posted_date
       FROM gl_je_headers gjh
          ,gl_period_statuses gps
          ,xla_subledgers xs
       WHERE gjh.ledger_id = p_ledger_id
         AND nvl(gjh.reference_date
             ,decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date)) >= p_start_date
         AND nvl(gjh.reference_date
             ,decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date)) < p_end_date
         AND gjh.status             = 'P'
         AND gjh.actual_flag        = 'A'
         AND nvl(gjh.je_from_sla_flag,'N') = 'N'
         AND (   gjh.parent_je_header_id is not null
              OR xs.je_source_name is null
              -- 6722378 upgraded journal entries
              OR (gjh.global_attribute_category = 'JE.GR.GLXJEENT.HEADER' AND xs.je_source_name = 'Project Accounting')
             )
         AND gjh.je_source          =          xs.je_source_name (+)
         AND gps.application_id     = 101
         AND gjh.period_name        = gps.period_name
         AND gps.ledger_id          = p_ledger_id
         AND exists
             (SELECT 1
                FROM gl_ledger_segment_values glsv
                    ,gl_ledger_norm_seg_vals glnsv
                    ,gl_je_segment_values gljsv
               WHERE gljsv.je_header_id                  = gjh.je_header_id
                 AND glsv.ledger_id                 (+)  = p_ledger_id
                 AND gljsv.segment_type_code             = 'B'
                 AND gljsv.segment_type_code             = glsv.segment_type_code (+)
                 AND gljsv.segment_value                 = glsv.segment_value (+)
                 AND glsv.parent_record_id               = glnsv.record_id (+)
                 AND glsv.status_code                    is NULL
                 AND glnsv.status_code                   is NULL
                 AND nvl(glnsv.sla_sequencing_flag, 'Y') = 'Y')
       );
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;
    ELSE
    -- populate the table XLA_SEQ_JE_HEADERS_GT
      INSERT INTO XLA_SEQ_JE_HEADERS_GT
       (application_id
       ,ledger_id
       ,ae_header_id
       ,je_source_name
       ,je_category_name
       ,gl_date
       ,reference_date
       ,completion_posted_date)
      (SELECT 101
            ,p_ledger_id
            ,gjh.je_header_id
            ,gjh.je_source
            ,gjh.je_category
            ,gjh.default_effective_date
            ,nvl(gjh.reference_date, decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date))
            ,gjh.posted_date
       FROM gl_je_headers gjh
          ,gl_period_statuses gps
          ,xla_subledgers xs
       WHERE gjh.ledger_id = p_ledger_id
         AND gjh.posted_date>= p_start_date
         AND gjh.posted_date< p_end_date
         AND gjh.status = 'P'
         AND gjh.actual_flag = 'A'
         AND (   gjh.parent_je_header_id is not null
              OR xs.je_source_name is null
              -- 6722378 upgraded journal entries
              OR (gjh.global_attribute_category = 'JE.GR.GLXJEENT.HEADER' AND xs.je_source_name = 'Project Accounting')
             )
         AND gjh.je_source=xs.je_source_name (+)
         AND gps.application_id = 101
         AND gjh.period_name    = gps.period_name
         AND gps.ledger_id      = p_ledger_id
         AND exists
             (SELECT 1
                FROM gl_ledger_segment_values glsv
                    ,gl_ledger_norm_seg_vals glnsv
                    ,gl_je_segment_values gljsv
               WHERE gljsv.je_header_id                  = gjh.je_header_id
                 AND glsv.ledger_id                  (+) = p_ledger_id
                 AND gljsv.segment_type_code             = 'B'
                 AND gljsv.segment_type_code             = glsv.segment_type_code (+)
                 AND gljsv.segment_value                 = glsv.segment_value (+)
                 AND glsv.parent_record_id               = glnsv.record_id (+)
                 AND glsv.status_code                    is NULL
                 AND glnsv.status_code                   is NULL
                 AND nvl(glnsv.sla_sequencing_flag, 'Y') = 'Y')
       );
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;
    END IF;


    IF (p_sort_date = 'GL_DATE') THEN
      INSERT INTO XLA_SEQ_JE_HEADERS_GT
       (application_id
       ,ledger_id
       ,ae_header_id
       ,je_source_name
       ,je_category_name
       ,gl_date
       ,reference_date
       ,completion_posted_date)
      (SELECT 602
            ,p_ledger_id
            ,xah.ae_header_id
            ,xs.je_source_name
            ,xah.je_category_name
            ,xah.accounting_date
            ,nvl(xah.reference_date, xah.accounting_date)
            ,nvl(xah.completed_date, xah.accounting_date)
       FROM xla_ae_headers xah
          ,xla_subledgers xs
       WHERE xah.ledger_id                     = p_ledger_id
         AND xah.accounting_date               >= p_start_date
         AND xah.accounting_date               < p_end_date
         AND xah.accounting_entry_status_code  = 'F'
         AND xah.gl_transfer_status_code       = 'Y'
         AND xah.application_id                = xs.application_id
         AND xah.balance_type_code             = 'A'
         AND exists
           (SELECT 1
              FROM gl_ledger_segment_values glsv
                   ,gl_ledger_norm_seg_vals glnsv
                   ,xla_ae_segment_values xasv
             WHERE xah.ae_header_id        = xasv.ae_header_id
               AND glsv.ledger_id    (+)   = p_ledger_id
               AND xasv.segment_type_code  = 'B'
               AND xasv.segment_type_code  = glsv.segment_type_code (+)
               AND xasv.segment_value      = glsv.segment_value (+)
               AND glsv.parent_record_id   = glnsv.record_id (+)
               AND glsv.status_code        is NULL
               AND glnsv.status_code       is NULL
               AND nvl(glnsv.sla_sequencing_flag, 'Y') = 'Y')
       );
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;
    ELSIF (p_sort_date = 'REFERENCE_DATE') THEN
      INSERT INTO XLA_SEQ_JE_HEADERS_GT
       (application_id
       ,ledger_id
       ,ae_header_id
       ,je_source_name
       ,je_category_name
       ,gl_date
       ,reference_date
       ,completion_posted_date)
      (SELECT 602
            ,p_ledger_id
            ,xah.ae_header_id
            ,xs.je_source_name
            ,xah.je_category_name
            ,xah.accounting_date
            ,nvl(xah.reference_date, xah.accounting_date)
            ,nvl(xah.completed_date, xah.accounting_date)
        FROM xla_ae_headers xah
          ,xla_subledgers xs
       WHERE xah.ledger_id                                = p_ledger_id
         AND nvl(xah.reference_date, xah.accounting_date) >= p_start_date
         AND nvl(xah.reference_date, xah.accounting_date) < p_end_date
         AND xah.accounting_entry_status_code             = 'F'
         AND xah.gl_transfer_status_code                  = 'Y'
         AND xah.application_id                           = xs.application_id
         AND xah.balance_type_code                        = 'A'
         AND exists
           (SELECT 1
              FROM gl_ledger_segment_values glsv
                  ,gl_ledger_norm_seg_vals glnsv
                  ,xla_ae_segment_values xasv
             WHERE xah.ae_header_id                    = xasv.ae_header_id
               AND glsv.ledger_id                (+)   = p_ledger_id
               AND xasv.segment_type_code              = 'B'
               AND xasv.segment_type_code              = glsv.segment_type_code (+)
               AND xasv.segment_value                  = glsv.segment_value (+)
               AND glsv.parent_record_id               = glnsv.record_id(+)
               AND glsv.status_code        is NULL
               AND glnsv.status_code       is NULL
               AND nvl(glnsv.sla_sequencing_flag, 'Y') = 'Y')
       );
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;
    ELSE
      INSERT INTO XLA_SEQ_JE_HEADERS_GT
       (application_id
       ,ledger_id
       ,ae_header_id
       ,je_source_name
       ,je_category_name
       ,gl_date
       ,reference_date
       ,completion_posted_date)
      (SELECT 602
            ,p_ledger_id
            ,xah.ae_header_id
            ,xs.je_source_name
            ,xah.je_category_name
            ,xah.accounting_date
            ,nvl(xah.reference_date, xah.accounting_date)
            ,nvl(xah.completed_date, xah.accounting_date)

       FROM xla_ae_headers xah
          ,xla_subledgers xs
       WHERE xah.ledger_id                    = p_ledger_id
         AND nvl(xah.completed_date, xah.accounting_date) >= p_start_date
         AND nvl(xah.completed_date, xah.accounting_date)  < p_end_date
         AND xah.accounting_entry_status_code = 'F'
         AND xah.gl_transfer_status_code      = 'Y'
         AND xah.application_id               =  xs.application_id
         AND xah.balance_type_code            = 'A'
         AND exists
           (SELECT 1
              FROM gl_ledger_segment_values glsv
                   ,gl_ledger_norm_seg_vals glnsv
                   ,xla_ae_segment_values xasv
             WHERE xah.ae_header_id                    = xasv.ae_header_id
               AND glsv.ledger_id                  (+) = p_ledger_id
               AND xasv.segment_type_code              = 'B'
               AND xasv.segment_type_code              = glsv.segment_type_code (+)
               AND xasv.segment_value                  = glsv.segment_value (+)
               AND glsv.parent_record_id               = glnsv.record_id(+)
               AND glsv.status_code        is NULL
               AND glnsv.status_code       is NULL
               AND nvl(glnsv.sla_sequencing_flag, 'Y') = 'Y')
       );
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;

    END IF;
  ELSE
    IF (p_sort_date = 'GL_DATE') THEN
    -- populate the table XLA_SEQ_JE_HEADERS_GT
      INSERT INTO XLA_SEQ_JE_HEADERS_GT
         (application_id
         ,ledger_id
         ,ae_header_id
         ,je_source_name
         ,je_category_name
         ,gl_date
         ,reference_date
         ,completion_posted_date)
      (SELECT 101
            ,p_ledger_id
            ,gjh.je_header_id
            ,gjh.je_source
            ,gjh.je_category
            ,gjh.default_effective_date
            ,nvl(gjh.reference_date,
               decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date))
            ,gjh.posted_date
       FROM gl_je_headers      gjh
           ,gl_period_statuses gps
           ,xla_subledgers xs
       WHERE gjh.ledger_id                 = p_ledger_id
         AND gjh.default_effective_date    >= p_start_date
         AND gjh.default_effective_date    < p_end_date
         AND gjh.status                    = 'P'
         AND gjh.actual_flag               = 'A'
         AND (   gjh.parent_je_header_id is not null
              OR xs.je_source_name is null
              -- 6722378 upgraded journal entries
              OR (gjh.global_attribute_category = 'JE.GR.GLXJEENT.HEADER' AND xs.je_source_name = 'Project Accounting')
             )
         AND gjh.je_source                 =  xs.je_source_name (+)
         AND gps.application_id            =  101
         AND gjh.period_name               = gps.period_name
         AND gps.ledger_id                 = p_ledger_id
       );
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;

    ELSIF (p_sort_date = 'REFERENCE_DATE') THEN
    -- populate the table XLA_SEQ_JE_HEADERS_GT
      INSERT INTO XLA_SEQ_JE_HEADERS_GT
       (application_id
       ,ledger_id
       ,ae_header_id
       ,je_source_name
       ,je_category_name
       ,gl_date
       ,reference_date
       ,completion_posted_date)
      (SELECT 101
            ,p_ledger_id
            ,gjh.je_header_id
            ,gjh.je_source
            ,gjh.je_category
            ,gjh.default_effective_date
            ,nvl(gjh.reference_date, decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date))
            ,gjh.posted_date
       FROM gl_je_headers gjh
          ,gl_period_statuses gps
          ,xla_subledgers xs
       WHERE gjh.ledger_id = p_ledger_id
         AND nvl(gjh.reference_date
             ,decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date)) >= p_start_date
         AND nvl(gjh.reference_date
             ,decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date)) < p_end_date
         AND gjh.status             = 'P'
         AND gjh.actual_flag        = 'A'
         AND nvl(gjh.je_from_sla_flag,'N') = 'N'
         AND (   gjh.parent_je_header_id is not null
              OR xs.je_source_name is null
              -- 6722378 upgraded journal entries
              OR (gjh.global_attribute_category = 'JE.GR.GLXJEENT.HEADER' AND xs.je_source_name = 'Project Accounting')
             )
         AND gjh.je_source          =          xs.je_source_name (+)
         AND gps.application_id     = 101
         AND gjh.period_name        = gps.period_name
         AND gps.ledger_id          = p_ledger_id
       );
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;
    ELSE
    -- populate the table XLA_SEQ_JE_HEADERS_GT
      INSERT INTO XLA_SEQ_JE_HEADERS_GT
       (application_id
       ,ledger_id
       ,ae_header_id
       ,je_source_name
       ,je_category_name
       ,gl_date
       ,reference_date
       ,completion_posted_date)
      (SELECT 101
            ,p_ledger_id
            ,gjh.je_header_id
            ,gjh.je_source
            ,gjh.je_category
            ,gjh.default_effective_date
            ,nvl(gjh.reference_date, decode(gps.adjustment_period_flag, 'Y', gjh.posted_date, gjh.default_effective_date))
            ,gjh.posted_date
       FROM gl_je_headers gjh
          ,gl_period_statuses gps
          ,xla_subledgers xs
       WHERE gjh.ledger_id = p_ledger_id
         AND gjh.posted_date>= p_start_date
         AND gjh.posted_date< p_end_date
         AND gjh.status = 'P'
         AND gjh.actual_flag = 'A'
         AND (   gjh.parent_je_header_id is not null
              OR xs.je_source_name is null
              -- 6722378 upgraded journal entries
              OR (gjh.global_attribute_category = 'JE.GR.GLXJEENT.HEADER' AND xs.je_source_name = 'Project Accounting')
             )
         AND gjh.je_source=xs.je_source_name (+)
         AND gps.application_id = 101
         AND gjh.period_name    = gps.period_name
         AND gps.ledger_id      = p_ledger_id
       );
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;
    END IF;


    IF (p_sort_date = 'GL_DATE') THEN
      INSERT INTO XLA_SEQ_JE_HEADERS_GT
       (application_id
       ,ledger_id
       ,ae_header_id
       ,je_source_name
       ,je_category_name
       ,gl_date
       ,reference_date
       ,completion_posted_date)
      (SELECT 602
            ,p_ledger_id
            ,xah.ae_header_id
            ,xs.je_source_name
            ,xah.je_category_name
            ,xah.accounting_date
            ,nvl(xah.reference_date, xah.accounting_date)
            ,nvl(xah.completed_date, xah.accounting_date)

       FROM xla_ae_headers xah
          ,xla_subledgers xs
       WHERE xah.ledger_id                     = p_ledger_id
         AND xah.accounting_date               >= p_start_date
         AND xah.accounting_date               < p_end_date
         AND xah.accounting_entry_status_code  = 'F'
         AND xah.gl_transfer_status_code       = 'Y'
         AND xah.application_id                = xs.application_id
         AND xah.balance_type_code             = 'A'
       );
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;
    ELSIF (p_sort_date = 'REFERENCE_DATE') THEN
      INSERT INTO XLA_SEQ_JE_HEADERS_GT
       (application_id
       ,ledger_id
       ,ae_header_id
       ,je_source_name
       ,je_category_name
       ,gl_date
       ,reference_date
       ,completion_posted_date)
      (SELECT 602
            ,p_ledger_id
            ,xah.ae_header_id
            ,xs.je_source_name
            ,xah.je_category_name
            ,xah.accounting_date
            ,nvl(xah.reference_date, xah.accounting_date)
            ,nvl(xah.completed_date, xah.accounting_date)

        FROM xla_ae_headers xah
          ,xla_subledgers xs
       WHERE xah.ledger_id                                = p_ledger_id
         AND nvl(xah.reference_date, xah.accounting_date) >= p_start_date
         AND nvl(xah.reference_date, xah.accounting_date) < p_end_date
         AND xah.accounting_entry_status_code             = 'F'
         AND xah.gl_transfer_status_code                  = 'Y'
         AND xah.application_id                           = xs.application_id
         AND xah.balance_type_code                        = 'A'
       );
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;
    ELSE
      INSERT INTO XLA_SEQ_JE_HEADERS_GT
       (application_id
       ,ledger_id
       ,ae_header_id
       ,je_source_name
       ,je_category_name
       ,gl_date
       ,reference_date
       ,completion_posted_date)
      (SELECT 602
            ,p_ledger_id
            ,xah.ae_header_id
            ,xs.je_source_name
            ,xah.je_category_name
            ,xah.accounting_date
            ,nvl(xah.reference_date, xah.accounting_date)
            ,nvl(xah.completed_date, xah.accounting_date)

       FROM xla_ae_headers xah
          ,xla_subledgers xs
       WHERE xah.ledger_id                    = p_ledger_id
         AND nvl(xah.completed_date, xah.accounting_date)>= p_start_date
         AND nvl(xah.completed_date, xah.accounting_date) < p_end_date
         AND xah.accounting_entry_status_code = 'F'
         AND xah.gl_transfer_status_code      = 'Y'
         AND xah.application_id               =  xs.application_id
         AND xah.balance_type_code            = 'A'
       );
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '#number of rows inserted:'||to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;

    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure populate_seq_gt_table'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

exception
  when others then
    raise;
end;


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

END XLA_REPORTING_SEQUENCE_PKG;

/
