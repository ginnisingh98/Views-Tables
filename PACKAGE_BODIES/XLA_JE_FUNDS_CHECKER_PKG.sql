--------------------------------------------------------
--  DDL for Package Body XLA_JE_FUNDS_CHECKER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_JE_FUNDS_CHECKER_PKG" AS
/* $Header: xlajefck.pkb 120.13 2006/11/10 19:50:57 awan ship $ */

-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- forward declarion of private procedures and functions
-------------------------------------------------------------------------------

FUNCTION bc_packet_insert
   (p_ae_header_id              IN INTEGER
   ,p_application_id		IN INTEGER
   ,p_funds_action              IN VARCHAR2)
RETURN INTEGER;

FUNCTION funds_action
   (p_ledger_id                 IN INTEGER
   ,p_ae_header_id              IN INTEGER
   ,p_application_id		IN INTEGER
   ,p_funds_action              IN VARCHAR2
   ,p_packet_id			IN INTEGER)
RETURN VARCHAR2;

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------

G_FUNDS_ACTION_RESERVE          CONSTANT VARCHAR2(1) := 'P';   -- 5649848 'R'
G_FUNDS_ACTION_UNRESERVE        CONSTANT VARCHAR2(1) := 'U';
G_FUNDS_ACTION_CHECK            CONSTANT VARCHAR2(1) := 'C';


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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_je_funds_checker_pkg';

g_debug_flag          VARCHAR2(1) :=
NVL(fnd_profile.value('XLA_DEBUG_TRACE'),'N');

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
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_je_funds_checker_pkg.trace');
END trace;

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================

--=============================================================================
--
--
--
--=============================================================================
FUNCTION reserve_funds
   (p_ae_header_id              IN INTEGER
   ,p_application_id		IN INTEGER
   ,p_ledger_id			IN INTEGER
   ,p_packet_id			OUT NOCOPY INTEGER)
RETURN VARCHAR2
IS
  l_result      VARCHAR2(1);
  l_packet_id	INTEGER;
  l_log_module  VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.reserve_funds';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure reserve_funds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'ae_header_id = '||p_ae_header_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'application_id = '||p_application_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'ledger_id = '||p_ledger_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --
  -- Insert into gl_bc_packet
  --
  p_packet_id := bc_packet_insert(p_ae_header_id, p_application_id, G_FUNDS_ACTION_RESERVE);

  --
  -- Call funds checker
  --
  l_result := funds_action(p_ledger_id, p_ae_header_id, p_application_id,
                           G_FUNDS_ACTION_RESERVE, p_packet_id);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure reserve_funds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  return l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_funds_checker_pkg.reserve_funds');
END reserve_funds;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION unreserve_funds
   (p_ae_header_id              IN INTEGER
   ,p_application_id		IN INTEGER
   ,p_ledger_id			IN INTEGER
   ,p_packet_id			IN INTEGER)
RETURN VARCHAR2
IS
  l_result      VARCHAR2(1);
  l_log_module  VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.unreserve_funds';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure unreserve_funds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'ae_header_id = '||p_ae_header_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'application_id = '||p_application_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'ledger_id = '||p_ledger_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'packet_id = '||p_packet_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --
  -- Call funds checker with unreserve mode
  --
  l_result := funds_action(p_ledger_id, p_ae_header_id, p_application_id,
                           G_FUNDS_ACTION_UNRESERVE, p_packet_id);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure unreserve_funds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  return l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_funds_checker_pkg.unreserve_funds');
END unreserve_funds;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE check_funds
   (p_ae_header_id              IN INTEGER
   ,p_application_id		IN INTEGER
   ,p_ledger_id			IN INTEGER
   ,p_packet_id			IN INTEGER
   ,p_retcode			OUT NOCOPY VARCHAR2)
IS
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.check_funds';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure check_funds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'ae_header_id = '||p_ae_header_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'application_id = '||p_application_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'ledger_id = '||p_ledger_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'packet_id = '||p_packet_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;


  p_retcode := funds_action(p_ledger_id, p_ae_header_id, p_application_id,
                           G_FUNDS_ACTION_CHECK, p_packet_id);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure check_funds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_funds_checker_pkg.check_funds');
END check_funds;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE insert_check_funds_row
   (p_packet_id			IN INTEGER
   ,p_ledger_id			IN INTEGER
   ,p_application_id		IN INTEGER
   ,p_ae_header_id              IN INTEGER
   ,p_ae_line_num		IN INTEGER
   ,p_gl_date			IN DATE
   ,p_balance_type_code		IN VARCHAR2
   ,p_je_category_name		IN VARCHAR2
   ,p_budget_version_id		IN INTEGER
   ,p_encumbrance_type_id	IN INTEGER
   ,p_code_combination_id	IN INTEGER
   ,p_currency_code		IN VARCHAR2
   ,p_entered_dr		IN NUMBER
   ,p_entered_cr		IN NUMBER
   ,p_accounted_dr		IN NUMBER
   ,p_accounted_cr		IN NUMBER
   ,p_ussgl_transaction_code	IN VARCHAR2
   ,p_event_id                  IN NUMBER)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.insert_check_funds_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure insert_check_funds_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'application_id = '||p_application_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'ledger_id = '||p_ledger_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'packet_id = '||p_packet_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'ae_header_id = '||p_ae_header_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'ae_line_num = '||p_ae_line_num,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --
  -- Insert the data into gl_je_packets
  --
	insert into gl_bc_packets
(PACKET_ID
,APPLICATION_ID
,LEDGER_ID
,JE_SOURCE_NAME
,JE_CATEGORY_NAME
,CODE_COMBINATION_ID
,ACTUAL_FLAG
,PERIOD_NAME
,PERIOD_YEAR
,PERIOD_NUM
,QUARTER_NUM
,CURRENCY_CODE
,STATUS_CODE
,LAST_UPDATE_DATE
,LAST_UPDATED_BY
,ENCUMBRANCE_TYPE_ID
,BUDGET_VERSION_ID
,ENTERED_DR
,ENTERED_CR
,ACCOUNTED_DR
,ACCOUNTED_CR
,EVENT_ID
,AE_HEADER_ID
,AE_LINE_NUM
,SESSION_ID
,SERIAL_ID
,BC_DATE
)
SELECT
  p_packet_id
, p_application_id
, p_ledger_id
, xs.je_source_name
, p_je_category_name
, p_code_combination_id
, p_balance_type_code
, gps.period_name
, gps.period_year
, gps.period_num
, gps.quarter_num
, p_currency_code
, G_FUNDS_ACTION_CHECK
, sysdate
, xla_environment_pkg.g_usr_id
, p_encumbrance_type_id
, p_budget_version_id
, p_entered_dr
, p_entered_cr
, p_accounted_dr
, p_accounted_cr
, p_event_id
, p_ae_header_id
, p_ae_line_num
, ses.sid
, ses.serial#
, p_gl_date
 FROM xla_subledgers     xs
    , gl_period_statuses gps
    , v$session          ses
WHERE xs.application_id  = p_application_id
  AND gps.application_id = 101
  AND gps.ledger_id      = p_ledger_id
  AND p_gl_date  between gps.start_date and gps.end_date
  AND ses.audsid         = userenv('SESSIONID');

  COMMIT;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure insert_check_funds_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_funds_checker_pkg.insert_check_funds_row');

END insert_check_funds_row;

--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================

--=============================================================================
--
--
--
--=============================================================================
FUNCTION bc_packet_insert
   (p_ae_header_id              IN INTEGER
   ,p_application_id		IN INTEGER
   ,p_funds_action              IN VARCHAR2)
RETURN INTEGER
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  CURSOR c_get_packet_id IS
    SELECT gl_bc_packets_s.NEXTVAL
    FROM dual;
  l_packet_id   NUMBER;
  l_log_module  VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.bc_packet_insert';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure bc_packet_insert',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'ae_header_id = '||p_ae_header_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'application_id = '||p_application_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'funds_action = '||p_funds_action,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --
  -- Get the packet id
  --
  OPEN c_get_packet_id;
  FETCH c_get_packet_id INTO l_packet_id;

  IF c_get_packet_id%FOUND THEN
    CLOSE c_get_packet_id;
  ELSE
    CLOSE c_get_packet_id;
    fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
    fnd_message.set_token('SEQUENCE', 'GL_BC_PACKETS_S');
    app_exception.raise_exception;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'packet_id: '||l_packet_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  --
  -- Insert the data into gl_je_packets
  --
	insert into gl_bc_packets
(PACKET_ID
,APPLICATION_ID
,LEDGER_ID
,JE_SOURCE_NAME
,JE_CATEGORY_NAME
,CODE_COMBINATION_ID
,ACTUAL_FLAG
,PERIOD_NAME
,PERIOD_YEAR
,PERIOD_NUM
,QUARTER_NUM
,CURRENCY_CODE
,STATUS_CODE -- Should be C if checking, P if reservation
,LAST_UPDATE_DATE
,LAST_UPDATED_BY
,ENCUMBRANCE_TYPE_ID
,BUDGET_VERSION_ID
,ENTERED_DR
,ENTERED_CR
,ACCOUNTED_DR
,ACCOUNTED_CR
,EVENT_ID
,AE_HEADER_ID
,AE_LINE_NUM
,SESSION_ID
,SERIAL_ID
,BC_DATE
)
SELECT
  l_packet_id
, p_application_id
, xah.ledger_id
, xs.je_source_name
, xah.je_category_name
, xal.code_combination_id
, xah.balance_type_code
, xah.period_name
, gps.period_year
, gps.period_num
, gps.quarter_num
, xal.currency_code
, p_funds_action
, sysdate
, xla_environment_pkg.g_usr_id
, xal.encumbrance_type_id
, xah.budget_version_id
, xal.entered_dr
, xal.entered_cr
, xal.accounted_dr
, xal.accounted_cr
, xah.event_id
, xal.ae_header_id
, xal.ae_line_num
, ses.sid
, ses.serial#
, xah.accounting_date
 FROM xla_ae_headers      xah
    , xla_ae_lines       xal
    , xla_subledgers     xs
    , gl_period_statuses gps
    , v$session          ses
WHERE xal.application_id = xah.application_id
  AND xal.ae_header_id   = xah.ae_header_id
  AND xs.application_id  = xah.application_id
  AND gps.application_id = 101
  AND gps.ledger_id      = xah.ledger_id
  AND gps.period_name    = xah.period_name
  AND xah.application_id = p_application_id
  AND xah.ae_header_id   = p_ae_header_id
  AND ses.audsid         = userenv('SESSIONID');

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'Num of rows inserted: '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  COMMIT;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure bc_packet_insert',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_packet_id;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN

  if (c_get_packet_id%ISOPEN) then
    CLOSE c_get_packet_id;
  end if;

  RAISE;
WHEN OTHERS                                   THEN

  if (c_get_packet_id%ISOPEN) then
    CLOSE c_get_packet_id;
  end if;

  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_funds_checker_pkg.bc_packet_insert');

END bc_packet_insert;

--=============================================================================
--
--
--
--=============================================================================
FUNCTION funds_action
   (p_ledger_id                 IN INTEGER
   ,p_ae_header_id              IN INTEGER
   ,p_application_id		IN INTEGER
   ,p_funds_action              IN VARCHAR2
   ,p_packet_id                 IN INTEGER)
RETURN VARCHAR2
IS
  l_result      VARCHAR2(1);
  l_log_module  VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.funds_action';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure funds_action',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'ledger_id = '||p_ledger_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'ae_header_id = '||p_ae_header_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'application_id = '||p_application_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'funds_action = '||p_funds_action,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'packet_id = '||p_packet_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --
  -- Call PSA funds checker function
  --


IF (NOT PSA_FUNDS_CHECKER_PKG.glxfck
      (p_ledgerid             => p_ledger_id
       ,p_packetid            => p_packet_id
       ,p_mode                 => p_funds_action
       ,p_override             => 'N'
       ,p_conc_flag            => 'N'
       ,p_user_id              => xla_environment_pkg.g_usr_id
       ,p_user_resp_id         => xla_environment_pkg.g_resp_appl_id
       ,p_calling_prog_flag    => 'S' -- SLA
       ,p_return_code          => l_result)) THEN

	  xla_exceptions_pkg.raise_message
	         ('XLA'
	         ,'XLA_COMMON_ERROR'
	         ,'ERROR'
	         ,'Error from funds checking routine: '||PSA_FUNDS_CHECKER_PKG.GET_DEBUG
	         ,'LOCATION'
         ,'xla_je_funds_checker_pkg.funds_action');

END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'GL_FUNDS_CHECKER_PKG.glxfck return code = '||l_result,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure funds_action',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  return l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'rollback in funds_action',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  RAISE;
WHEN OTHERS                                   THEN
  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'rollback in funds_action',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_funds_checker_pkg.funds_action');
END funds_action;

end xla_je_funds_checker_pkg;

/
