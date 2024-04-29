--------------------------------------------------------
--  DDL for Package Body XLA_JE_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_JE_VALIDATION_PKG" AS
/* $Header: xlajebal.pkb 120.158.12010000.16 2010/04/28 10:42:51 kapkumar ship $ */

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------

TYPE t_array_varchar30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_array_varchar80 IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE t_array_date      IS TABLE OF DATE         INDEX BY BINARY_INTEGER;
TYPE t_array_number    IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------

C_BALANCING_ACCT_LINE_NAME      CONSTANT VARCHAR2(30) := 'BALANCING';

/*
 * These are the types of lines exists in the validation lines table:
 * C_LINE_TYPE_PROCESS          : Original lines to be processed
 * C_LINE_TYPE_COMPLETE         : Original lines that has completed processing
 * C_LINE_TYPE_LC_BALANCING     : Balancing lines created by balanced by ledger currency
 * C_LINE_TYPE_IC_BAL_INTRA     : Balancing lines created by balanced by Intercompany balancing
 * C_LINE_TYPE_IC_BAL_INTER     : Balancing lines created by balanced by Intracompany balancing
 * C_LINE_TYPE_XLA_BALANCING    : Balancing lines created by balanced by entered currency and
 * C_LINE_TYPE_RD_BALANCING     : Balancing lines created by balanced by journal rounding
 *                                balancing segments
 */
C_LINE_TYPE_PROCESS             CONSTANT VARCHAR2(1) := 'P';
C_LINE_TYPE_COMPLETE            CONSTANT VARCHAR2(1) := 'C';
C_LINE_TYPE_LC_BALANCING        CONSTANT VARCHAR2(1) := 'L';
C_LINE_TYPE_IC_BAL_INTRA        CONSTANT VARCHAR2(1) := 'R';
C_LINE_TYPE_IC_BAL_INTER        CONSTANT VARCHAR2(1) := 'E';
C_LINE_TYPE_XLA_BALANCING       CONSTANT VARCHAR2(1) := 'X';
C_LINE_TYPE_RD_BALANCING        CONSTANT VARCHAR2(1) := 'J';
C_LINE_TYPE_ENC_BALANCING       CONSTANT VARCHAR2(1) := 'N';
C_LINE_TYPE_ENC_BAL_ERROR       CONSTANT VARCHAR2(1) := 'O';

-- The segment type code
C_BAL_SEGMENT                   CONSTANT VARCHAR2(1) := 'B';
C_MGT_SEGMENT                   CONSTANT VARCHAR2(1) := 'M';
C_CC_SEGMENT                    CONSTANT VARCHAR2(1) := 'C';
C_NA_SEGMENT                    CONSTANT VARCHAR2(1) := 'N';

-- Data type constant for comparison
C_NUM                           CONSTANT NUMBER      := 9E125;
C_CHAR                          CONSTANT VARCHAR2(1) := fnd_global.local_chr(12);
C_DATE                          CONSTANT DATE        := TO_DATE('1','j');

-- Application id for GL
C_GL_APPLICATION_ID             CONSTANT INTEGER := 101;

-- Accounting entry status codes
C_AE_STATUS_INVALID             CONSTANT VARCHAR2(30) := 'I';
C_AE_STATUS_RELATED             CONSTANT VARCHAR2(30) := 'R';

-- Line type returned by Intercompany balance API
C_FUN_INTRA                     CONSTANT VARCHAR2(1) := 'R';
C_FUN_INTER                     CONSTANT VARCHAR2(1) := 'E';

-- Accounting class for the balance lines
C_ACCT_CLASS_INTRA              CONSTANT VARCHAR2(30) := 'INTRA';
C_ACCT_CLASS_INTER              CONSTANT VARCHAR2(30) := 'INTER';
C_ACCT_CLASS_BALANCE            CONSTANT VARCHAR2(30) := 'BALANCE';
C_ACCT_CLASS_ROUNDING           CONSTANT VARCHAR2(30) := 'ROUNDING';
C_ACCT_CLASS_RFE                CONSTANT VARCHAR2(30) := 'RFE';

-- The code for the full privilege access set
C_ACCESS_SET_FULL_PRIVILEGE     CONSTANT VARCHAR2(1) := 'B';

-- If the API called by accounting program, manaul journal entry, or
-- complete multiperiod/accrual program.
C_CALLER_ACCT_PROGRAM           CONSTANT VARCHAR2(1) := 'A';
C_CALLER_MANUAL                 CONSTANT VARCHAR2(1) := 'M';
C_CALLER_MPA_PROGRAM            CONSTANT VARCHAR2(1) := 'P';  -- 4262811
C_CALLER_THIRD_PARTY_MERGE      CONSTANT VARCHAR2(1) := 'T';  -- 4262811

-- Internal error code used for validation
C_VALID                         CONSTANT VARCHAR2(1) := 'Y';
C_INVALID                       CONSTANT VARCHAR2(1) := 'N';
C_INVALID_DATE                  CONSTANT VARCHAR2(1) := 'D';


------------------------------------------------------------------------------
-- declaring global variables
-------------------------------------------------------------------------------

g_amb_context_code              VARCHAR2(30);
g_caller                        VARCHAR2(1);  -- Call by acct program or manual
g_application_id                INTEGER;
g_ae_header_id                  INTEGER;
g_balance_flag                  BOOLEAN;
g_end_date                      DATE;         -- 4262811 MPA
--g_mode                        VARCHAR2(80); -- 4262811a MPA
g_accounting_mode               VARCHAR2(30);
g_message_name                  VARCHAR2(30); -- 4262811 MPA
g_app_je_source_name            VARCHAR2(30);
g_app_ctl_acct_source_code      VARCHAR2(30);

-- Globals to store error information
g_err_event_ids                 t_array_int;
g_err_hdr_ids                   t_array_int;
g_err_count                     INTEGER := 0;
g_prev_err_count                INTEGER := 0;

-- Globals to store ledger information
g_trx_ledger_id                 INTEGER;      -- ledger of the transaction
g_ledger_id                     INTEGER;      -- current processing ledger (PRI, SEC, ALC)
g_target_ledger_id              INTEGER;      -- primary/secondary ledger if the g_ledger_id is ALC

-- Globals to store the ledger information of the curreny processing ledger
g_ledger_name                   VARCHAR2(30);
g_ledger_currency_code          VARCHAR2(30);
g_ledger_category_code          VARCHAR2(30);
g_ledger_coa_id                 INTEGER;
g_bal_seg_column_name           VARCHAR2(30);
g_mgt_seg_column_name           VARCHAR2(30);
g_cc_seg_column_name            VARCHAR2(30);
g_na_seg_column_name            VARCHAR2(30);
g_allow_intercompany_post_flag  VARCHAR2(30);
g_bal_seg_value_option_code     VARCHAR2(30);
g_mgt_seg_value_option_code     VARCHAR2(30);
g_sla_bal_by_ledger_curr_flag   VARCHAR2(30);
g_sla_ledger_cur_bal_sus_ccid   INTEGER;
g_sla_entered_cur_bal_sus_ccid  INTEGER;
g_sla_rounding_ccid             INTEGER;
g_latest_encumbrance_year       INTEGER;
g_transaction_calendar_id       INTEGER;
g_enable_average_balances_flag  VARCHAR2(1);
g_res_encumb_ccid               INTEGER;
g_suspense_allowed_flag         VARCHAR2(1);

-- Globals used for ledger security validation
g_use_ledger_security         VARCHAR2(1);
g_pri_access_set_id           INTEGER;
g_sec_access_set_id           INTEGER;
g_tmp_access_set_id           INTEGER;  -- 5109176
g_pri_access_set_name         fnd_profile_options_vl.user_profile_option_name%TYPE;  -- 5109176
g_sec_access_set_name         fnd_profile_options_vl.user_profile_option_name%TYPE;  -- 5109176
g_tmp_access_set_name         fnd_profile_options_vl.user_profile_option_name%TYPE;  -- 5109176
g_pri_coa_id                  INTEGER;
g_sec_coa_id                  INTEGER;
g_tmp_coa_id                  INTEGER;
g_pri_security_seg_code       VARCHAR2(1);
g_sec_security_seg_code       VARCHAR2(1);
g_tmp_security_seg_code       VARCHAR2(1);
g_user_name                   VARCHAR2(80);
g_access_set_name             VARCHAR2(80);

g_new_line_count              INTEGER;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_je_validation_pkg';

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
      (p_location   => 'xla_je_validation_pkg.trace');
END trace;


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================

--=============================================================================
--
--
--
--=============================================================================
FUNCTION get_period_name
  (p_ledger_id          IN  INTEGER
  ,p_accounting_date    IN  DATE
  ,p_closing_status     OUT NOCOPY VARCHAR2
  ,p_period_type        OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c IS
    SELECT      closing_status, period_name, period_type
    FROM        gl_period_statuses
    WHERE       application_id          = C_GL_APPLICATION_ID
      AND       ledger_id               = p_ledger_id
      AND       adjustment_period_flag  = 'N'
      AND       p_accounting_date       BETWEEN start_date AND end_date;
  l_period_name         VARCHAR2(25);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_period_name';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function get_period_name',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_ledger_id = '||p_ledger_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_accounting_date = '||p_accounting_date,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c;
  FETCH c INTO p_closing_status, l_period_name, p_period_type;
  CLOSE c;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function get_period_name',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_period_name;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.get_period_name');
END get_period_name;


--=============================================================================
--
-- Name: validate_period
-- Description: Determine if the accounting date is in an open period.
-- Result code:
--      0 - the accounting date is in an open or a future open period
--      1 - the accounting date is not in an open or a future open period
--      2 - no valid period is found for the accounting date
--
--=============================================================================
FUNCTION validate_period
  (p_ledger_id                  IN  INTEGER
  ,p_accounting_date            IN  DATE
  ,p_period_name                OUT NOCOPY VARCHAR2)
RETURN INTEGER
IS
  l_status      VARCHAR2(30);
  l_result      INTEGER := 0;
  l_period_type VARCHAR2(30);
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_period';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_period',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_ledger_id = '||p_ledger_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_accounting_date = '||p_accounting_date,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  p_period_name := get_period_name
        (p_ledger_id            => p_ledger_id
        ,p_accounting_date      => p_accounting_date
        ,p_closing_status       => l_status
        ,p_period_type          => l_period_type);

  IF (p_period_name = '') THEN
    l_result := 2;
  ELSIF l_status NOT IN ('F', 'O') THEN
    l_result := 1;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'p_period_name = '||p_period_name,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
    trace(p_msg    => 'l_status = '||l_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
    trace(p_msg    => 'l_result(validate_period) = '||l_result,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function validate_period',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_period');

END validate_period;


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--
--
--
--
-- Followings are the balancing routines and the related validation routines
--
--
--
--
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--=============================================================================
--
-- Name: initialize
-- Description: This procedure initialize the global variables required for
--              the validation routine.
--
--=============================================================================
PROCEDURE initialize
  (p_application_id             IN  INTEGER
  ,p_ledger_id                  IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_end_date                   IN  DATE                  -- 4262811
  ,p_mode                       IN  VARCHAR2              -- 4262811
  ,p_balance_flag               IN  BOOLEAN
  ,p_accounting_mode            IN  VARCHAR2)
IS
  l_log_module  VARCHAR2(240);

  cursor c_profile_user_name (l_profile_name VARCHAR2) IS
  select user_profile_option_name
  from   fnd_profile_options_vl
  where  profile_option_name = l_profile_name;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.initialize';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure initialize',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --
  -- Initialize application level information
  --
  g_application_id := p_application_id;
  g_trx_ledger_id  := p_ledger_id;
  g_balance_flag   := p_balance_flag;
  g_accounting_mode:= p_accounting_mode;
  g_err_count      := 0;
  g_new_line_count := 0;
  -- 4262811 ------------------------------------------------
  g_end_date       := p_end_date;
  --g_mode         := p_mode;   -- 4262811a
  IF (p_mode = 'CREATE_ACCOUNTING') THEN
     g_caller := C_CALLER_ACCT_PROGRAM;
  ELSIF (p_mode = 'COMPLETE_MPA') THEN
     g_caller := C_CALLER_MPA_PROGRAM;
  ELSIF (p_mode = 'THIRD_PARTY_MERGE') THEN
     g_caller := C_CALLER_THIRD_PARTY_MERGE;
  ELSE
     g_caller := C_CALLER_MANUAL;
  END IF;
  -----------------------------------------------------------

  SELECT nvl(control_account_type_code, 'N')
--        ,control_account_enabled_flag
        ,je_source_name
  INTO   g_app_ctl_acct_source_code
--        ,g_app_ctl_acct_enabled_flag
        ,g_app_je_source_name
  FROM   xla_subledgers
  WHERE  application_id = g_application_id;

  IF (p_ae_header_id IS NULL) THEN
  --  g_caller := C_CALLER_ACCT_PROGRAM;    -- 4262811

    UPDATE xla_ae_headers_gt h
       SET (period_year,period_closing_status) =
           (SELECT period_year,closing_status
              FROM gl_period_statuses gl
             WHERE gl.period_name    = h.period_name
               AND gl.ledger_id      = h.ledger_id
               AND gl.application_id = 101);

  ELSE
     g_ae_header_id := p_ae_header_id;
  -- g_caller := C_CALLER_MANUAL;    -- 4262811
  END IF;

  --
  -- Initialize ledger security information
  --
  g_use_ledger_security := NVL(fnd_profile.value('XLA_USE_LEDGER_SECURITY'), 'N');

  IF (g_use_ledger_security = 'Y') THEN
    g_pri_access_set_id := fnd_profile.value('GL_ACCESS_SET_ID');
    g_sec_access_set_id := fnd_profile.value('XLA_GL_SECONDARY_ACCESS_SET_ID');

    ----------------------------------------------------------------------------------------
    -- 5109176 find the user profile name for the error message XLA_AP_ACCESS_SET_VIOLATION
    ----------------------------------------------------------------------------------------
    open  c_profile_user_name('GL_ACCESS_SET_ID');
    fetch c_profile_user_name into g_pri_access_set_name;
    close c_profile_user_name;
    open  c_profile_user_name('XLA_GL_SECONDARY_ACCESS_SET_ID');
    fetch c_profile_user_name into g_sec_access_set_name;
    close c_profile_user_name;
    ------------------------------------------------------------

    IF (g_pri_access_set_id IS NULL AND g_sec_access_set_id IS NULL) THEN

      g_use_ledger_security := 'N';

    ELSE
      g_pri_security_seg_code := 'N';
      g_sec_security_seg_code := 'N';

      IF (g_pri_access_set_id IS NOT NULL) THEN
        SELECT    security_segment_code, chart_of_accounts_id
        INTO      g_pri_security_seg_code, g_pri_coa_id
        FROM      gl_access_sets
        WHERE     access_set_id   = g_pri_access_set_id;
      END IF;

      IF (g_sec_access_set_id IS NOT NULL) THEN
        SELECT    security_segment_code, chart_of_accounts_id
        INTO      g_sec_security_seg_code, g_sec_coa_id
        FROM      gl_access_sets
        WHERE     access_set_id   = g_sec_access_set_id;
      END IF;

      IF (g_sec_security_seg_code = 'F' AND g_pri_security_seg_code <> 'F') OR
         (g_pri_security_seg_code = 'N' AND g_sec_security_seg_code <> 'N') OR
         (g_pri_security_seg_code = 'M' AND g_sec_security_seg_code = 'B') THEN
        g_tmp_coa_id := g_pri_coa_id;
        g_pri_coa_id := g_sec_coa_id;
        g_sec_coa_id := g_tmp_coa_id;
        g_tmp_security_seg_code := g_pri_security_seg_code;
        g_pri_security_seg_code := g_sec_security_seg_code;
        g_sec_security_seg_code := g_tmp_security_seg_code;

        --------------------------------------------------------------------------------------------------
        -- 5109176  To handle setting Primary Access set to Secondary Access set when Primary is null
        --------------------------------------------------------------------------------------------------
        g_tmp_access_set_id   := g_pri_access_set_id;
        g_pri_access_set_id   := g_sec_access_set_id;
        g_sec_access_set_id   := g_tmp_access_set_id;
        g_tmp_access_set_name := g_pri_access_set_name;
        g_pri_access_set_name := g_sec_access_set_name;
        g_sec_access_set_name := g_tmp_access_set_name;

      END IF;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => 'g_pri_access_set_id = '||g_pri_access_set_id,
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
        trace(p_msg    => 'g_pri_security_seg_code = '||g_pri_security_seg_code,
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
        trace(p_msg    => 'g_pri_coa_id = '||g_pri_coa_id,
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
        trace(p_msg    => 'g_sec_access_set_id = '||g_sec_access_set_id,
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
        trace(p_msg    => 'g_sec_security_seg_code = '||g_sec_security_seg_code,
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
        trace(p_msg    => 'g_sec_coa_id = '||g_sec_coa_id,
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;
    END IF;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'g_use_ledger_security = '||g_use_ledger_security,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure initialize',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.initialize');

END initialize;

--=============================================================================
--
-- Name: validate_ledger_security
-- Description: This procedure will validate the line againist the
--              access set ledger security.
--
--=============================================================================
PROCEDURE validate_ledger_security
IS
  CURSOR c_full_none IS
    SELECT asa.ledger_id
      FROM gl_access_set_assignments asa
     WHERE asa.ledger_id             = g_ledger_id
       AND asa.access_privilege_code = C_ACCESS_SET_FULL_PRIVILEGE
       AND asa.access_set_id         = g_pri_access_set_id;

  CURSOR c_full_full IS
    SELECT asa.ledger_id
      FROM gl_access_set_assignments asa
     WHERE asa.ledger_id             = g_ledger_id
       AND asa.access_privilege_code = C_ACCESS_SET_FULL_PRIVILEGE
       AND asa.access_set_id         in (g_pri_access_set_id, g_sec_access_set_id);

  CURSOR c_err IS
    SELECT  entity_id, event_id, ae_header_id
      FROM  xla_validation_lines_gt;

  l_err              c_err%ROWTYPE;
  l_ledger_id        INTEGER;
  l_log_module       VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_ledger_security';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_ledger_security',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_sec_security_seg_code = 'N') THEN
    OPEN c_full_none;
    FETCH c_full_none INTO l_ledger_id;
    CLOSE c_full_none;
  ELSIF (g_sec_security_seg_code = 'F') THEN
    OPEN c_full_full;
    FETCH c_full_full INTO l_ledger_id;
    CLOSE c_full_full;
  END IF;

  IF (l_ledger_id IS NULL) THEN
    IF (g_access_set_name IS NULL) THEN
      SELECT  u.user_name, a.name
      INTO    g_user_name, g_access_set_name
      FROM    fnd_user u, gl_access_sets a
      WHERE   u.user_id       = xla_environment_pkg.g_usr_id
      AND     a.access_set_id = g_pri_access_set_id;
    END IF;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'BEGIN LOOP - invalid access set ledger security',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    FOR l_err IN c_err LOOP
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'LOOP invalid access set ledger security: ae_header_id = '||l_err.ae_header_id,
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      g_err_count := g_err_count+1;
      g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
      g_err_event_ids(g_err_count) := l_err.event_id;

      xla_accounting_err_pkg.build_message(
              p_appli_s_name          => 'XLA'
              ,p_msg_name             => 'XLA_AP_ACCESS_SET_VIOLATION'
              ,p_token_1              => 'ACCESS_SET'
              ,p_value_1              => g_access_set_name
              ,p_token_2              => 'LEDGER_NAME'
              ,p_value_2              => g_ledger_name
              ,p_token_3              => 'PRI_DATA_ACCESS_SET'  -- 5109176
              ,p_value_3              => g_pri_access_set_name
              ,p_entity_id            => l_err.entity_id
              ,p_event_id             => l_err.event_id
              ,p_ledger_id            => g_ledger_id
              ,p_ae_header_id         => l_err.ae_header_id
              ,p_ae_line_num          => NULL
              ,p_accounting_batch_id  => NULL);
    END LOOP;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'END LOOP - invalid access set ledger security',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_ledger_security',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF c_full_full%ISOPEN THEN
    CLOSE c_full_full;
  END IF;
  IF c_full_none%ISOPEN THEN
    CLOSE c_full_none;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF c_full_full%ISOPEN THEN
    CLOSE c_full_full;
  END IF;
  IF c_full_none%ISOPEN THEN
    CLOSE c_full_none;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_ledger_security');

END validate_ledger_security;

--=============================================================================
--
-- Name: validate_segment_security
-- Description: This procedure will validate the line againist the
--              access set segment security.
--
--=============================================================================
PROCEDURE validate_segment_security
IS
  CURSOR c_full_bal IS
    SELECT  t.entity_id, t.event_id, t.ae_header_id, t.ae_line_num
           ,NULL segment_value
      FROM  xla_validation_lines_gt t
            LEFT OUTER JOIN gl_access_set_assignments asa
            on  asa.ledger_id             = g_ledger_id
            AND asa.access_privilege_code = C_ACCESS_SET_FULL_PRIVILEGE
            AND asa.access_set_id         = g_pri_access_set_id
            LEFT OUTER JOIN gl_access_set_assignments asa2
            on  asa2.segment_value         = t.bal_seg_value
            AND asa2.ledger_id             = g_ledger_id
            AND asa2.access_privilege_code = C_ACCESS_SET_FULL_PRIVILEGE
            AND asa2.access_set_id         = g_sec_access_set_id
     WHERE  asa.access_set_id IS NULL
       AND  asa2.access_set_id IS NULL;

  CURSOR c_full_mgt IS
    SELECT  t.entity_id, t.event_id, t.ae_header_id, t.ae_line_num
           ,NULL segment_value
      FROM  xla_validation_lines_gt t
            LEFT OUTER JOIN gl_access_set_assignments asa
            on  asa.ledger_id             = g_ledger_id
            AND asa.access_privilege_code = C_ACCESS_SET_FULL_PRIVILEGE
            AND asa.access_set_id         = g_pri_access_set_id
            LEFT OUTER JOIN gl_access_set_assignments asa2
            on  asa2.segment_value         = t.mgt_seg_value
            AND asa2.ledger_id             = g_ledger_id
            AND asa2.access_privilege_code = C_ACCESS_SET_FULL_PRIVILEGE
            AND asa2.access_set_id         = g_sec_access_set_id
     WHERE  asa.access_set_id IS NULL
       AND  asa2.access_set_id IS NULL;

  CURSOR c_bal_none IS
    SELECT  t.entity_id, t.event_id, t.ae_header_id, t.ae_line_num
           ,t.bal_seg_value segment_value
      FROM  xla_validation_lines_gt t
            LEFT OUTER JOIN gl_access_set_assignments asa
            ON  asa.segment_value         = t.bal_seg_value
            AND asa.access_privilege_code = C_ACCESS_SET_FULL_PRIVILEGE
            AND asa.ledger_id             = g_ledger_id
            AND asa.access_set_id         = g_pri_access_set_id
     WHERE  asa.access_set_id IS NULL;

  CURSOR c_bal_bal IS
    SELECT  t.entity_id, t.event_id, t.ae_header_id, t.ae_line_num
           ,t.bal_seg_value segment_value
      FROM  xla_validation_lines_gt t
            LEFT OUTER JOIN gl_access_set_assignments asa
            ON  asa.segment_value         = t.bal_seg_value
            AND asa.access_privilege_code = C_ACCESS_SET_FULL_PRIVILEGE
            AND asa.ledger_id             = g_ledger_id
            AND asa.access_set_id         in (g_pri_access_set_id, g_sec_access_set_id)
     WHERE  asa.access_set_id IS NULL;

  CURSOR c_bal_mgt IS
    SELECT  t.entity_id, t.event_id, t.ae_header_id, t.ae_line_num
           ,t.bal_seg_value segment_value
      FROM  xla_validation_lines_gt t
            LEFT OUTER JOIN gl_access_set_assignments asa
            on  asa.segment_value         = t.bal_seg_value
            AND asa.ledger_id             = g_ledger_id
            AND asa.access_privilege_code = C_ACCESS_SET_FULL_PRIVILEGE
            AND asa.access_set_id         = g_pri_access_set_id
            LEFT OUTER JOIN gl_access_set_assignments asa2
            on  asa2.segment_value         = t.mgt_seg_value
            AND asa2.ledger_id             = g_ledger_id
            AND asa2.access_privilege_code = C_ACCESS_SET_FULL_PRIVILEGE
            AND asa2.access_set_id         = g_sec_access_set_id
     WHERE  asa.access_set_id IS NULL
       AND  asa2.access_set_id IS NULL;

  CURSOR c_mgt_none IS
    SELECT  t.entity_id, t.event_id, t.ae_header_id, t.ae_line_num
           ,t.mgt_seg_value segment_value
      FROM  xla_validation_lines_gt t
            LEFT OUTER JOIN gl_access_set_assignments asa
            ON  asa.segment_value         = t.mgt_seg_value
            AND asa.access_privilege_code = C_ACCESS_SET_FULL_PRIVILEGE
            AND asa.ledger_id             = g_ledger_id
            AND asa.access_set_id         = g_pri_access_set_id
     WHERE  asa.access_set_id IS NULL;

  CURSOR c_mgt_mgt IS
    SELECT  t.entity_id, t.event_id, t.ae_header_id, t.ae_line_num
           ,t.mgt_seg_value segment_value
      FROM  xla_validation_lines_gt t
            LEFT OUTER JOIN gl_access_set_assignments asa
            ON  asa.segment_value         = t.mgt_seg_value
            AND asa.access_privilege_code = C_ACCESS_SET_FULL_PRIVILEGE
            AND asa.ledger_id             = g_ledger_id
            AND asa.access_set_id         in (g_pri_access_set_id, g_sec_access_set_id)
     WHERE  asa.access_set_id IS NULL;

  l_pri_security_seg_code     VARCHAR2(1);
  l_sec_security_seg_code     VARCHAR2(1);
  l_err                       c_mgt_mgt%ROWTYPE;
  l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_segment_security';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_segment_security',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- If the management column name is NULL, discard it from validation
  l_pri_security_seg_code := g_pri_security_seg_code;
  l_sec_security_seg_code := g_sec_security_seg_code;

  IF (g_mgt_seg_column_name IS NULL) THEN
    IF (g_sec_security_seg_code = 'M') THEN
      l_sec_security_seg_code := 'N';
    END IF;
    IF (g_pri_security_seg_code = 'M') THEN
      l_pri_security_seg_code := l_sec_security_seg_code;
      l_sec_security_seg_code := 'N';
    END IF;
    -- If management column name is NULL and only management segment validation
    -- was specified to start with, no further validation is necessary.
    IF (l_pri_security_seg_code = 'N' AND
        l_sec_security_seg_code = 'N') THEN
      RETURN;
    END IF;
  END IF;

  IF (l_pri_security_seg_code = 'F') THEN
    IF (l_sec_security_seg_code = 'B') THEN
      OPEN c_full_bal;
    ELSIF(l_sec_security_seg_code = 'M') THEN
      OPEN c_full_mgt;
    END IF;
  ELSIF (l_pri_security_seg_code = 'B') THEN
    IF (l_sec_security_seg_code = 'N') THEN
      OPEN c_bal_none;
    ELSIF (l_sec_security_seg_code = 'B') THEN
      OPEN c_bal_bal;
    ELSIF(l_sec_security_seg_code = 'M') THEN
      OPEN c_bal_mgt;
    END IF;
  ELSIF (l_pri_security_seg_code = 'M') THEN
    IF (l_sec_security_seg_code = 'N') THEN
      OPEN c_mgt_none;
    ELSIF(l_sec_security_seg_code = 'M') THEN
      OPEN c_mgt_mgt;
    END IF;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid access set segments',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  LOOP
    IF (l_pri_security_seg_code = 'F') THEN
      IF (l_sec_security_seg_code = 'B') THEN
        FETCH c_full_bal INTO l_err;
        EXIT WHEN c_full_bal%NOTFOUND;
      ELSIF(l_sec_security_seg_code = 'M') THEN
        FETCH c_full_mgt INTO l_err;
        EXIT WHEN c_full_mgt%NOTFOUND;
      END IF;
    ELSIF (l_pri_security_seg_code = 'B') THEN
      IF (l_sec_security_seg_code = 'N') THEN
        FETCH c_bal_none INTO l_err;
        EXIT WHEN c_bal_none%NOTFOUND;
      ELSIF (l_sec_security_seg_code = 'B') THEN
        FETCH c_bal_bal INTO l_err;
        EXIT WHEN c_bal_bal%NOTFOUND;
      ELSIF(l_sec_security_seg_code = 'M') THEN
        FETCH c_bal_mgt INTO l_err;
        EXIT WHEN c_bal_mgt%NOTFOUND;
      END IF;
    ELSIF (l_pri_security_seg_code = 'M') THEN
      IF (l_sec_security_seg_code = 'N') THEN
        FETCH c_mgt_none INTO l_err;
        EXIT WHEN c_mgt_none%NOTFOUND;
      ELSIF(l_sec_security_seg_code = 'M') THEN
        FETCH c_mgt_mgt INTO l_err;
        EXIT WHEN c_mgt_mgt%NOTFOUND;
      END IF;
    END IF;

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP invalid access set segments: ae_header_id = '||l_err.ae_header_id||
                        ', ae_line_num = '||l_err.ae_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    IF (l_pri_security_seg_code = 'F') THEN
      IF (g_access_set_name IS NULL) THEN
        SELECT  u.user_name, a.name
        INTO    g_user_name, g_access_set_name
        FROM    fnd_user u, gl_access_sets a
        WHERE   u.user_id       = xla_environment_pkg.g_usr_id
        AND     a.access_set_id = g_pri_access_set_id;
      END IF;

      g_err_count := g_err_count+1;
      g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
      g_err_event_ids(g_err_count) := l_err.event_id;

      xla_accounting_err_pkg.build_message(
              p_appli_s_name          => 'XLA'
              ,p_msg_name             => 'XLA_AP_ACCESS_SET_VIOLATION'
              ,p_token_1              => 'ACCESS_SET'
              ,p_value_1              => g_access_set_name
              ,p_token_2              => 'LEDGER_NAME'
              ,p_value_2              => g_ledger_name
              ,p_token_3              => 'PRI_DATA_ACCESS_SET'  -- 5109176
              ,p_value_3              => g_pri_access_set_name
              ,p_entity_id            => l_err.entity_id
              ,p_event_id             => l_err.event_id
              ,p_ledger_id            => g_ledger_id
              ,p_ae_header_id         => l_err.ae_header_id
              ,p_ae_line_num          => l_err.ae_line_num
              ,p_accounting_batch_id  => NULL);
    ELSIF (l_pri_security_seg_code = 'B') THEN
      g_err_count := g_err_count+1;
      g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
      g_err_event_ids(g_err_count) := l_err.event_id;

      xla_accounting_err_pkg.build_message(
              p_appli_s_name          => 'XLA'
              ,p_msg_name             => 'XLA_AP_BSV_SECURITY_VIOLATION'
              ,p_token_1              => 'BALANCING_SEGMENT_VALUE'
              ,p_value_1              => l_err.segment_value
              ,p_token_2              => 'LINE_NUM'
              ,p_value_2              => l_err.ae_line_num
              ,p_entity_id            => l_err.entity_id
              ,p_event_id             => l_err.event_id
              ,p_ledger_id            => g_ledger_id
              ,p_ae_header_id         => l_err.ae_header_id
              ,p_ae_line_num          => l_err.ae_line_num
              ,p_accounting_batch_id  => NULL);
    ELSE
      g_err_count := g_err_count+1;
      g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
      g_err_event_ids(g_err_count) := l_err.event_id;

      xla_accounting_err_pkg.build_message(
              p_appli_s_name          => 'XLA'
              ,p_msg_name             => 'XLA_AP_MSV_SECURITY_VIOLATION'
              ,p_token_1              => 'MANAGEMENT_SEGMENT_VALUE'
              ,p_value_1              => l_err.segment_value
              ,p_token_2              => 'LINE_NUM'
              ,p_value_2              => l_err.ae_line_num
              ,p_entity_id            => l_err.entity_id
              ,p_event_id             => l_err.event_id
              ,p_ledger_id            => g_ledger_id
              ,p_ae_header_id         => l_err.ae_header_id
              ,p_ae_line_num          => l_err.ae_line_num
              ,p_accounting_batch_id  => NULL);
    END IF;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid access set segments',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (l_pri_security_seg_code = 'F') THEN
    IF (l_sec_security_seg_code = 'B') THEN
      CLOSE c_full_bal;
    ELSIF(l_sec_security_seg_code = 'M') THEN
      CLOSE c_full_mgt;
    END IF;
  ELSIF (l_pri_security_seg_code = 'B') THEN
    IF (l_sec_security_seg_code = 'N') THEN
      CLOSE c_bal_none;
    ELSIF (l_sec_security_seg_code = 'B') THEN
      CLOSE c_bal_bal;
    ELSIF(l_sec_security_seg_code = 'M') THEN
      CLOSE c_bal_mgt;
    END IF;
  ELSIF (l_pri_security_seg_code = 'M') THEN
    IF (l_sec_security_seg_code = 'N') THEN
      CLOSE c_mgt_none;
    ELSIF(l_sec_security_seg_code = 'M') THEN
      CLOSE c_mgt_mgt;
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of procedure validate_segment_security',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF c_full_bal%ISOPEN THEN
    CLOSE c_full_bal;
  END IF;
  IF c_full_mgt%ISOPEN THEN
    CLOSE c_full_mgt;
  END IF;
  IF c_bal_none%ISOPEN THEN
    CLOSE c_bal_none;
  END IF;
  IF c_bal_bal%ISOPEN THEN
    CLOSE c_bal_bal;
  END IF;
  IF c_bal_mgt%ISOPEN THEN
    CLOSE c_bal_mgt;
  END IF;
  IF c_mgt_none%ISOPEN THEN
    CLOSE c_mgt_none;
  END IF;
  IF c_mgt_mgt%ISOPEN THEN
    CLOSE c_mgt_mgt;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF c_full_bal%ISOPEN THEN
    CLOSE c_full_bal;
  END IF;
  IF c_full_mgt%ISOPEN THEN
    CLOSE c_full_mgt;
  END IF;
  IF c_bal_none%ISOPEN THEN
    CLOSE c_bal_none;
  END IF;
  IF c_bal_bal%ISOPEN THEN
    CLOSE c_bal_bal;
  END IF;
  IF c_bal_mgt%ISOPEN THEN
    CLOSE c_bal_mgt;
  END IF;
  IF c_mgt_none%ISOPEN THEN
    CLOSE c_mgt_none;
  END IF;
  IF c_mgt_mgt%ISOPEN THEN
    CLOSE c_mgt_mgt;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_segment_security');
END validate_segment_security;


--=============================================================================
--
-- Name: validate_access_set_security
-- Description: This procedure will validate the line againist the
--              access set security.
--
--=============================================================================
PROCEDURE validate_access_set_security
IS
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_access_set_security';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_access_set_security',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_use_ledger_security = 'Y') THEN
    IF (g_pri_security_seg_code = 'F' AND
        g_sec_security_seg_code IN ('F', 'N')) THEN
      -- Fix bug 3534929
      -- Only perform ledger security if the current ledger is not the transaction
      -- ledger.  Otherwise, it is already validated in the LOV during submission.
      IF (g_ledger_id <> g_trx_ledger_id) THEN
        validate_ledger_security;
      END IF;
    ELSE
      validate_segment_security;
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_access_set_security',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_access_set_security');
END validate_access_set_security;


--=============================================================================
--
-- Name: load_lines
-- Description: This function will retrieve all necessary line information
--              and put them into the temporary table, which is the working
--              table for this package.
--
--=============================================================================
PROCEDURE load_lines
(p_budgetary_control_mode VARCHAR2)
IS
  i                     INTEGER;
  l_stmt                VARCHAR2(25000);
  l_log_module          VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.load_lines';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure load_lines',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --
  -- Retrieve all working data into the temporary table
  --
  -- Added in C_CALLER_MPA_PROGRAM for 4262811.
  IF (g_caller in (C_CALLER_ACCT_PROGRAM, C_CALLER_MPA_PROGRAM, C_CALLER_THIRD_PARTY_MERGE)) THEN

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'g_suspense_allowed_flag = '||g_suspense_allowed_flag,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    IF (p_budgetary_control_mode <> 'NONE') THEN
      --
      -- If running in BC mode, do not use suspense account nor substitute accounts.
      --
      l_stmt := '
      INSERT INTO xla_validation_lines_gt
        (ae_header_id
        ,ae_line_num
        ,ledger_id
        ,displayed_line_number
        ,max_ae_line_num
        ,max_displayed_line_number
        ,entity_id
        ,event_id
        ,balance_type_code
        ,budget_version_id
        ,encumbrance_type_id
        ,accounting_date
        ,je_category_name
        ,party_type_code
        ,party_id
        ,party_site_id
        ,entered_currency_code
        ,unrounded_entered_cr
        ,unrounded_entered_dr
        ,entered_cr
        ,entered_dr
        ,entered_currency_mau
        ,unrounded_accounted_cr
        ,unrounded_accounted_dr
        ,accounted_cr
        ,accounted_dr
        ,currency_conversion_type
        ,currency_conversion_date
        ,currency_conversion_rate
        ,code_combination_id
        ,accounting_class_code
        ,bal_seg_value
        ,mgt_seg_value
        ,cost_center_seg_value
        ,natural_account_seg_value
        ,ccid_coa_id
        ,ccid_enabled_flag
        ,ccid_summary_flag
        ,detail_posting_allowed_flag
        ,detail_budgeting_allowed_flag
        ,control_account_enabled_flag
        ,product_rule_type_code
        ,product_rule_code
        ,balancing_line_type
        ,error_flag
        ,substituted_ccid
        ,accounting_entry_status_code
        ,period_name
        ,gain_or_loss_flag
        )
      SELECT     /*+  cardinality(h,1) index(l, XLA_AE_LINES_U1) use_nl(l) use_nl(ccid) */
                 h.ae_header_id
                ,l.ae_line_num
                ,h.ledger_id
                ,l.displayed_line_number
                ,max(l.ae_line_num) over (partition by l.ae_header_id)
                ,max(l.displayed_line_number) over (partition by l.ae_header_id)
                ,h.entity_id
                ,h.event_id
                ,h.balance_type_code
                ,h.budget_version_id
                ,l.encumbrance_type_id
                ,h.accounting_date
                ,h.je_category_name
                ,l.party_type_code
                ,l.party_id
                ,l.party_site_id
                ,l.currency_code
                ,l.unrounded_entered_cr
                ,l.unrounded_entered_dr
                ,l.entered_cr
                ,l.entered_dr
                ,nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
                ,l.unrounded_accounted_cr
                ,l.unrounded_accounted_dr
                ,l.accounted_cr
                ,l.accounted_dr
                ,l.currency_conversion_type
                ,l.currency_conversion_date
                ,l.currency_conversion_rate
                ,l.code_combination_id
                ,l.accounting_class_code
                ,ccid.'||g_bal_seg_column_name||'
                ,'||CASE WHEN g_mgt_seg_column_name is NULL THEN 'NULL' ELSE 'ccid.'||g_mgt_seg_column_name END||'
                ,'||CASE WHEN g_cc_seg_column_name  is NULL THEN 'NULL' ELSE 'ccid.'||g_cc_seg_column_name  END||'
                ,'||CASE WHEN g_na_seg_column_name  is NULL THEN 'NULL' ELSE 'ccid.'||g_na_seg_column_name  END||'
                ,ccid.chart_of_accounts_id
                -- ccid_enabled_flag
                ,CASE WHEN ccid.enabled_flag IS NULL THEN NULL
                      WHEN ccid.enabled_flag = ''N'' THEN ''N''
                      WHEN h.accounting_date < nvl(ccid.start_date_active, h.accounting_date) THEN ''D''
                      WHEN h.accounting_date > nvl(ccid.end_date_active, h.accounting_date) THEN ''D''
                      ELSE ''Y''
                      END
                ,CASE WHEN ccid.summary_flag = ''Y'' THEN ''Y'' ELSE ''N'' END
                ,ccid.detail_posting_allowed_flag
                ,ccid.detail_budgeting_allowed_flag
                ,nvl(ccid.reference3,''N'')
                ,h.product_rule_type_code
                ,h.product_rule_code
                ,'''||C_LINE_TYPE_PROCESS||'''
                ,CASE WHEN ccid.enabled_flag IS NULL
                      or (ccid.code_combination_id = -1 and nvl(l.gain_or_loss_flag, ''N'')=''Y'')
                      or l.accounting_class_code IS NULL
                      or ccid.enabled_flag = ''N''
                      or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                      or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date)
                      or (ccid.summary_flag = ''Y'')
                      or (h.balance_type_code <> ''B'' AND ccid.detail_posting_allowed_flag = ''N'')
                      or (h.balance_type_code = ''B'' AND ccid.detail_budgeting_allowed_flag = ''N'')
                      or ('''||g_app_ctl_acct_source_code||''' <> ''Y'' AND
                          (nvl(ccid.reference3,''N'') NOT IN (''Y'', ''N'', ''R'', '''||g_app_ctl_acct_source_code||''')))
                      or ('''||g_app_ctl_acct_source_code||''' = ''N'' AND nvl(ccid.reference3,''N'') NOT IN  (''N'',''R''))
                      or (nvl(ccid.reference3,''N'') NOT IN  (''N'', ''R'' ) AND
                          (l.party_type_code IS NULL OR l.party_id IS NULL))
                      or (nvl(ccid.reference3,''N'') = ''CUSTOMER'' AND l.party_type_code <> ''C'')
                      or (nvl(ccid.reference3,''N'') = ''SUPPLIER'' AND l.party_type_code <> ''S'')
                      or (l.party_type_code IS NOT NULL AND l.party_type_code NOT IN (''C'', ''S''))
                      or ((l.party_id IS NOT NULL OR l.party_site_id IS NOT NULL) AND l.party_type_code IS NULL)
                    --  or ((l.party_site_id IS NOT NULL OR l.party_type_code IS NOT NULL) AND l.party_id IS NULL)
                      or (nvl(l.gain_or_loss_flag,''N'') = ''N'' AND l.entered_dr IS NULL AND l.entered_cr IS NULL)
                      or (l.entered_dr IS NOT NULL AND l.accounted_dr IS NULL)
                      or (l.entered_cr IS NOT NULL AND l.accounted_cr IS NULL)
                      or (nvl(l.gain_or_loss_flag, ''N'') = ''N'' and l.entered_dr IS NULL AND l.accounted_dr IS NOT NULL)
                      or (nvl(l.gain_or_loss_flag, ''N'') = ''N'' and l.entered_cr IS NULL AND l.accounted_cr IS NOT NULL)
                      or (NVL(l.entered_cr,0) > 0 AND NVL(l.accounted_cr,0) < 0)
                      or (NVL(l.entered_dr,0) > 0 AND NVL(l.accounted_dr,0) < 0)
                      or (NVL(l.entered_cr,0) < 0 AND NVL(l.accounted_cr,0) > 0)
                      or (NVL(l.entered_dr,0) < 0 AND NVL(l.accounted_dr,0) > 0)
                      or (:1 = l.currency_code AND nvl(l.gain_or_loss_flag, ''N'') = ''N'' AND
                          (nvl(l.unrounded_entered_dr,9E125) <> nvl(l.unrounded_accounted_dr,9E125) or
                           nvl(l.unrounded_entered_cr,9E125) <> nvl(l.unrounded_accounted_cr,9E125)))
                     /* or (:2 = l.currency_code AND
                          (l.currency_conversion_type IS NOT NULL or nvl(l.currency_conversion_rate,1) <> 1)) */ -- commented for bug:8417965
                      or (:3 <> l.currency_code AND
                          ((l.currency_conversion_type = ''User'' AND l.currency_conversion_rate IS NULL) or
                           (nvl(l.currency_conversion_type,''User'') <> ''User'' AND l.currency_conversion_date IS NULL)))
                      or (:4 <> ccid.chart_of_accounts_id)
                      or (l.accounted_cr is NULL and l.accounted_dr is NULL and l.currency_conversion_rate is NULL)
                      THEN ''Y''
                      ELSE NULL
                      END
                ,NULL -- substituted_ccid
                ,h.accounting_entry_status_code
                ,h.period_name
                ,l.gain_or_loss_flag
      FROM       xla_ae_headers_gt      h
                ,xla_ae_lines           l
                ,gl_code_combinations   ccid
                ,fnd_currencies fcu
      WHERE     ccid.code_combination_id(+) = l.code_combination_id
        AND     l.ae_header_id          = h.ae_header_id
        AND       h.ledger_id             = :5
        AND       l.currency_code = fcu.currency_code
        AND     l.application_id        = '||g_application_id;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace(p_msg    => substr(l_stmt, 1, 4000),
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 4001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 8001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 12001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 16001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 20001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
      END IF;

      EXECUTE IMMEDIATE l_stmt using
          g_ledger_currency_code
       --  ,g_ledger_currency_code -- commented for bug:8417965
         ,g_ledger_currency_code
         ,g_ledger_coa_id
         ,g_ledger_id
         ;

      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace(p_msg    => '# of rows inserted:'||to_char(SQL%ROWCOUNT),
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
      END IF;

    ELSIF(g_suspense_allowed_flag = 'Y') THEN
      l_stmt := '
      INSERT INTO xla_validation_lines_gt
        (ae_header_id
        ,ae_line_num
        ,ledger_id
        ,displayed_line_number
        ,max_ae_line_num
        ,max_displayed_line_number
        ,entity_id
        ,event_id
        ,balance_type_code
        ,budget_version_id
        ,encumbrance_type_id
        ,accounting_date
        ,je_category_name
        ,party_type_code
        ,party_id
        ,party_site_id
        ,entered_currency_code
        ,unrounded_entered_cr
        ,unrounded_entered_dr
        ,entered_cr
        ,entered_dr
        ,entered_currency_mau
        ,unrounded_accounted_cr
        ,unrounded_accounted_dr
        ,accounted_cr
        ,accounted_dr
        ,currency_conversion_type
        ,currency_conversion_date
        ,currency_conversion_rate
        ,code_combination_id
        ,accounting_class_code
        ,bal_seg_value
        ,mgt_seg_value
        ,cost_center_seg_value
        ,natural_account_seg_value
        ,ccid_coa_id
        ,ccid_enabled_flag
        ,ccid_summary_flag
        ,detail_posting_allowed_flag
        ,detail_budgeting_allowed_flag
        ,control_account_enabled_flag
        ,product_rule_type_code
        ,product_rule_code
        ,balancing_line_type
        ,error_flag
        ,gain_or_loss_flag
        ,substituted_by_suspense_flag
        ,substituted_ccid
        ,suspense_code_combination_id
        ,accounting_entry_status_code
        ,period_name
        )
      SELECT     /*+ leading(h) cardinality(h,1) index(l, XLA_AE_LINES_U1) use_nl(l) use_nl(ccid) */
                 h.ae_header_id
                ,l.ae_line_num
                ,h.ledger_id
                ,l.displayed_line_number
                ,max(l.ae_line_num) over (partition by l.ae_header_id)
                ,max(l.displayed_line_number) over (partition by l.ae_header_id)
                ,h.entity_id
                ,h.event_id
                ,h.balance_type_code
                ,h.budget_version_id
                ,l.encumbrance_type_id
                ,h.accounting_date
                ,h.je_category_name
                ,l.party_type_code
                ,l.party_id
                ,l.party_site_id
                ,l.currency_code
                ,l.unrounded_entered_cr
                ,l.unrounded_entered_dr
                ,l.entered_cr
                ,l.entered_dr
                ,nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
                ,l.unrounded_accounted_cr
                ,l.unrounded_accounted_dr
                ,l.accounted_cr
                ,l.accounted_dr
                ,l.currency_conversion_type
                ,l.currency_conversion_date
                ,l.currency_conversion_rate
                -- code_combination_id
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN  -- ccid disabled or outdated, ccid1 defined
                     CASE
                     WHEN nvl(gsa.code_combination_id, nvl(gsa1.code_combination_id, nvl(gsa2.code_combination_id, gsa3.code_combination_id))) is not NULL
                          and (--ccid1.enabled_flag is NULL
                               ccid1.enabled_flag = ''N''
                               or h.accounting_date < nvl(ccid1.start_date_active, h.accounting_date)
                               or h.accounting_date > nvl(ccid1.end_date_active, h.accounting_date)
                               --or ccid1.summary_flag = ''Y''
                               --or (ccid1.detail_posting_allowed_flag = ''N'' and h.balance_type_code <>''B'')
                               --or (ccid1.detail_budgeting_allowed_flag = ''N'' and h.balance_type_code = ''B'')
                               )
                     THEN nvl(gsa.code_combination_id, nvl(gsa1.code_combination_id, nvl(gsa2.code_combination_id, gsa3.code_combination_id)))
                     ELSE ccid.alternate_code_combination_id
                     END
                 WHEN l.code_combination_id <> -1
                      and nvl(gsa.code_combination_id, nvl(gsa1.code_combination_id, nvl(gsa2.code_combination_id, gsa3.code_combination_id))) is not NULL
                      and (--ccid.enabled_flag is NULL
                           ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date)
                           --or ccid.summary_flag = ''Y''
                           --or (ccid.detail_posting_allowed_flag = ''N'' and h.balance_type_code <> ''B'')
                           --or (ccid.detail_budgeting_allowed_flag =''N'' and h.balance_type_code = ''B'')
                           )
                 THEN nvl(gsa.code_combination_id, nvl(gsa1.code_combination_id, nvl(gsa2.code_combination_id, gsa3.code_combination_id)))
                 ELSE l.code_combination_id
                 END
                ,l.accounting_class_code
                ,CASE WHEN l.code_combination_id <> -1
                           and (ccid.enabled_flag = ''N''
                                or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                                or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                           and ccid.alternate_code_combination_id is not NULL
                      THEN ccid1.'||g_bal_seg_column_name||'
                      ELSE ccid.'||g_bal_seg_column_name||'
                      END';

       IF (g_mgt_seg_column_name is NULL) THEN
         l_stmt := l_stmt || '
                ,NULL';
       ELSE
         l_stmt := l_stmt || '
                ,CASE WHEN l.code_combination_id <> -1
                           and (ccid.enabled_flag = ''N''
                                or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                                or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                           and ccid.alternate_code_combination_id is not NULL
                      THEN ccid1.'||g_mgt_seg_column_name||'
                      ELSE ccid.'||g_mgt_seg_column_name||'
                      END';
       END IF;

       IF (g_cc_seg_column_name is NULL) THEN
         l_stmt := l_stmt || '
                ,NULL';
       ELSE
         l_stmt := l_stmt || '
                ,CASE WHEN l.code_combination_id <> -1
                           and (ccid.enabled_flag = ''N''
                                or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                                or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                           and ccid.alternate_code_combination_id is not NULL
                      THEN ccid1.'||g_cc_seg_column_name||'
                      ELSE ccid.'||g_cc_seg_column_name||'
                      END';
       END IF;

       IF (g_na_seg_column_name is NULL) THEN
         l_stmt := l_stmt || '
                ,NULL';
       ELSE
         l_stmt := l_stmt || '
                ,CASE WHEN l.code_combination_id <> -1
                           and (ccid.enabled_flag = ''N''
                                or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                                or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                           and ccid.alternate_code_combination_id is not NULL
                      THEN ccid1.'||g_na_seg_column_name||'
                      ELSE ccid.'||g_na_seg_column_name||'
                      END ';
       END IF;


       l_stmt := l_stmt || '
                ,ccid.chart_of_accounts_id
                -- ccid_enabled_flag
                ,CASE WHEN l.code_combination_id = -1 THEN ''Y''
                      WHEN (ccid.enabled_flag = ''N''
                             or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                             or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                            and ccid.alternate_code_combination_id is not NULL
                      THEN
                          CASE
                          WHEN ccid1.enabled_flag IS NULL THEN NULL
                          WHEN ccid1.enabled_flag = ''N'' THEN ''N''
                          WHEN h.accounting_date < nvl(ccid1.start_date_active, h.accounting_date) THEN ''D''
                          WHEN h.accounting_date > nvl(ccid1.end_date_active, h.accounting_date) THEN ''D''
                          ELSE ''Y''
                          END
                      ELSE
                          CASE
                          WHEN ccid.enabled_flag IS NULL THEN NULL
                          WHEN ccid.enabled_flag = ''N'' THEN ''N''
                          WHEN h.accounting_date < nvl(ccid.start_date_active, h.accounting_date) THEN ''D''
                          WHEN h.accounting_date > nvl(ccid.end_date_active, h.accounting_date) THEN ''D''
                          ELSE ''Y''
                          END
                      END
                -- ccid_summary_flag
                ,CASE WHEN l.code_combination_id <> -1
                           and (ccid.enabled_flag = ''N''
                                or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                                or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                           and ccid.alternate_code_combination_id is not NULL
                      THEN CASE WHEN ccid1.summary_flag = ''Y'' THEN ''Y'' ELSE ''N'' END
                      ELSE CASE WHEN ccid.summary_flag = ''Y'' THEN ''Y'' ELSE ''N'' END
                      END
                 -- detail_posting_allowed_flag
                ,CASE WHEN l.code_combination_id <> -1
                           and (ccid.enabled_flag = ''N''
                                or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                                or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                           and ccid.alternate_code_combination_id is not NULL
                      THEN ccid1.detail_posting_allowed_flag
                      ELSE ccid.detail_posting_allowed_flag
                      END
                 -- detail_budgeting_allowed_flag
                ,CASE WHEN l.code_combination_id <> -1
                           and (ccid.enabled_flag = ''N''
                                or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                                or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                           and ccid.alternate_code_combination_id is not NULL
                      THEN ccid1.detail_budgeting_allowed_flag
                      ELSE ccid.detail_budgeting_allowed_flag
                      END
                 -- control_account_enabled_flag
                ,CASE WHEN l.code_combination_id <> -1
                           and (ccid.enabled_flag = ''N''
                                or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                                or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                           and ccid.alternate_code_combination_id is not NULL
                      THEN nvl(ccid1.reference3,''N'')
                      ELSE nvl(ccid.reference3,''N'')
                      END
                ,h.product_rule_type_code
                ,h.product_rule_code
                ,'''||C_LINE_TYPE_PROCESS||'''
                -- error_flag
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN
                    CASE WHEN ccid1.enabled_flag IS NULL
                      or (ccid1.code_combination_id = -1 and nvl(l.gain_or_loss_flag, ''N'')=''Y'')
                      or l.accounting_class_code IS NULL
                      or ccid1.enabled_flag = ''N''
                      or h.accounting_date < nvl(ccid1.start_date_active, h.accounting_date)
                      or h.accounting_date > nvl(ccid1.end_date_active, h.accounting_date)
                      or (ccid1.summary_flag = ''Y'')
                      or (h.balance_type_code <> ''B'' AND ccid1.detail_posting_allowed_flag = ''N'')
                      or (h.balance_type_code = ''B'' AND ccid1.detail_budgeting_allowed_flag = ''N'')
                      or ('''||g_app_ctl_acct_source_code||''' <> ''Y'' AND
                          (nvl(ccid1.reference3,''N'') NOT IN (''Y'', ''N'', ''R'', '''||g_app_ctl_acct_source_code||''')))
                      or ('''||g_app_ctl_acct_source_code||''' = ''N'' AND nvl(ccid1.reference3,''N'') NOT IN ( ''N'', ''R''))
                      or (nvl(ccid1.reference3,''N'') NOT IN (''N'', ''R'') AND
                          (l.party_type_code IS NULL OR l.party_id IS NULL))
                      or (nvl(ccid1.reference3,''N'') = ''CUSTOMER'' AND l.party_type_code <> ''C'')
                      or (nvl(ccid1.reference3,''N'') = ''SUPPLIER'' AND l.party_type_code <> ''S'')
                      or (l.party_type_code IS NOT NULL AND l.party_type_code NOT IN (''C'', ''S''))
                      or ((l.party_id IS NOT NULL OR l.party_site_id IS NOT NULL) AND l.party_type_code IS NULL)
                   --   or ((l.party_site_id IS NOT NULL OR l.party_type_code IS NOT NULL) AND l.party_id IS NULL)
                      or (nvl(l.gain_or_loss_flag,''N'') = ''N'' AND l.entered_dr IS NULL AND l.entered_cr IS NULL)
                      or (l.entered_dr IS NOT NULL AND l.accounted_dr IS NULL)
                      or (l.entered_cr IS NOT NULL AND l.accounted_cr IS NULL)
                      or (nvl(l.gain_or_loss_flag, ''N'') = ''N'' and l.entered_dr IS NULL AND l.accounted_dr IS NOT NULL)
                      or (nvl(l.gain_or_loss_flag, ''N'') = ''N'' and l.entered_cr IS NULL AND l.accounted_cr IS NOT NULL)
                      or (NVL(l.entered_cr,0) > 0 AND NVL(l.accounted_cr,0) < 0)
                      or (NVL(l.entered_dr,0) > 0 AND NVL(l.accounted_dr,0) < 0)
                      or (NVL(l.entered_cr,0) < 0 AND NVL(l.accounted_cr,0) > 0)
                      or (NVL(l.entered_dr,0) < 0 AND NVL(l.accounted_dr,0) > 0)
                      or (:1 = l.currency_code AND nvl(l.gain_or_loss_flag, ''N'') = ''N'' AND
                          (nvl(l.unrounded_entered_dr,9E125) <> nvl(l.unrounded_accounted_dr,9E125) or
                           nvl(l.unrounded_entered_cr,9E125) <> nvl(l.unrounded_accounted_cr,9E125)))
                     /* or (:2 = l.currency_code AND
                          (l.currency_conversion_type IS NOT NULL or nvl(l.currency_conversion_rate,1) <> 1))*/ -- commented for bug:8417965
                      or (:3 <> l.currency_code AND
                          ((l.currency_conversion_type = ''User'' AND l.currency_conversion_rate IS NULL) or
                           (nvl(l.currency_conversion_type,''User'') <> ''User'' AND l.currency_conversion_date IS NULL)))
                      or (:4 <> ccid1.chart_of_accounts_id)
                      or (l.accounted_cr is NULL and l.accounted_dr is NULL and l.currency_conversion_rate is NULL)
                      THEN ''Y''
                      ELSE NULL
                      END
                 ELSE
                    CASE WHEN ccid.enabled_flag IS NULL
                      or (ccid.code_combination_id = -1 and nvl(l.gain_or_loss_flag, ''N'')=''Y'')
                      or l.accounting_class_code IS NULL
                      or ccid.enabled_flag = ''N''
                      or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                      or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date)
                      or (ccid.summary_flag = ''Y'')
                      or (h.balance_type_code <> ''B'' AND ccid.detail_posting_allowed_flag = ''N'')
                      or (h.balance_type_code = ''B'' AND ccid.detail_budgeting_allowed_flag = ''N'')
                      or ('''||g_app_ctl_acct_source_code||''' <> ''Y'' AND
                           (nvl(ccid.reference3,''N'') NOT IN (''Y'', ''N'', ''R'', '''||g_app_ctl_acct_source_code||''')))
                      or ('''||g_app_ctl_acct_source_code||''' = ''N'' AND nvl(ccid.reference3,''N'') NOT IN (''N'',''R''))
                      or (nvl(ccid.reference3,''N'') NOT IN (''N'', ''R'') AND
                          (l.party_type_code IS NULL OR l.party_id IS NULL))
                      or (nvl(ccid.reference3,''N'') = ''CUSTOMER'' AND l.party_type_code <> ''C'')
                      or (nvl(ccid.reference3,''N'') = ''SUPPLIER'' AND l.party_type_code <> ''S'')
                      or (l.party_type_code IS NOT NULL AND l.party_type_code NOT IN (''C'', ''S''))
                      or ((l.party_id IS NOT NULL OR l.party_site_id IS NOT NULL) AND l.party_type_code IS NULL)
                  --    or ((l.party_site_id IS NOT NULL OR l.party_type_code IS NOT NULL) AND l.party_id IS NULL)
                      or (nvl(l.gain_or_loss_flag,''N'') = ''N'' AND l.entered_dr IS NULL AND l.entered_cr IS NULL)
                      or (l.entered_dr IS NOT NULL AND l.accounted_dr IS NULL)
                      or (l.entered_cr IS NOT NULL AND l.accounted_cr IS NULL)
                      or (nvl(l.gain_or_loss_flag, ''N'') = ''N'' and l.entered_dr IS NULL AND l.accounted_dr IS NOT NULL)
                      or (nvl(l.gain_or_loss_flag, ''N'') = ''N'' and l.entered_cr IS NULL AND l.accounted_cr IS NOT NULL)
                      or (NVL(l.entered_cr,0) > 0 AND NVL(l.accounted_cr,0) < 0)
                      or (NVL(l.entered_dr,0) > 0 AND NVL(l.accounted_dr,0) < 0)
                      or (NVL(l.entered_cr,0) < 0 AND NVL(l.accounted_cr,0) > 0)
                      or (NVL(l.entered_dr,0) < 0 AND NVL(l.accounted_dr,0) > 0)
                      or (:5 = l.currency_code AND nvl(l.gain_or_loss_flag, ''N'') = ''N'' AND
                          (nvl(l.unrounded_entered_dr,9E125) <> nvl(l.unrounded_accounted_dr,9E125) or
                           nvl(l.unrounded_entered_cr,9E125) <> nvl(l.unrounded_accounted_cr,9E125)))
                    /*  or (:6 = l.currency_code AND
                          (l.currency_conversion_type IS NOT NULL or nvl(l.currency_conversion_rate,1) <> 1)) */ -- commented for bug:8417965
                      or (:7 <> l.currency_code AND
                          ((l.currency_conversion_type = ''User'' AND l.currency_conversion_rate IS NULL) or
                           (nvl(l.currency_conversion_type,''User'') <> ''User'' AND l.currency_conversion_date IS NULL)))
                      or (:8 <> ccid.chart_of_accounts_id)
                      or (l.accounted_cr is NULL and l.accounted_dr is NULL and l.currency_conversion_rate is NULL)
                      THEN ''Y''
                      ELSE NULL
                      END
                 END
                ,gain_or_loss_flag
                -- substituted_by_suspense_flag
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN
                     CASE
                     WHEN nvl(gsa.code_combination_id, nvl(gsa1.code_combination_id, nvl(gsa2.code_combination_id, gsa3.code_combination_id))) is not NULL
                          and (--ccid1.enabled_flag is NULL
                                ccid1.enabled_flag = ''N''
                               or h.accounting_date < nvl(ccid1.start_date_active, h.accounting_date)
                               or h.accounting_date > nvl(ccid1.end_date_active, h.accounting_date)
                               --or ccid1.summary_flag = ''Y''
                               --or (ccid1.detail_posting_allowed_flag = ''N'' and h.balance_type_code <>''B'')
                               --or (ccid1.detail_budgeting_allowed_flag = ''N'' and h.balance_type_code = ''B'')
                               )
                     THEN ''Y''
                     ELSE ''N''
                     END
                 WHEN l.code_combination_id <> -1
                      and nvl(gsa.code_combination_id, nvl(gsa1.code_combination_id, nvl(gsa2.code_combination_id, gsa3.code_combination_id))) is not NULL
                      and (--ccid.enabled_flag is NULL
                           ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date)
                           --or ccid.summary_flag = ''Y''
                           --or (ccid.detail_posting_allowed_flag = ''N'' and h.balance_type_code <> ''B'')
                           --or (ccid.detail_budgeting_allowed_flag =''N'' and h.balance_type_code = ''B'')
                           )
                 THEN ''Y''
                 ELSE ''N''
                 END
                 -- substituted_ccid
                ,CASE WHEN l.code_combination_id <> -1 AND
                           (ccid.enabled_flag = ''N'' OR
                            h.accounting_date < nvl(ccid.start_date_active, h.accounting_date) OR
                            h.accounting_date > nvl(ccid.end_date_active, h.accounting_date)) AND
                           ccid.alternate_code_combination_id is not NULL
                      THEN l.code_combination_id
                      WHEN l.code_combination_id <> -1 AND
                           nvl(gsa.code_combination_id,
                               nvl(gsa1.code_combination_id,
                                   nvl(gsa2.code_combination_id, gsa3.code_combination_id))) IS NOT NULL AND
                           (--ccid.enabled_flag IS NULL OR
                            ccid.enabled_flag = ''N'' OR
                            h.accounting_date < nvl(ccid.start_date_active, h.accounting_date) OR
                            h.accounting_date > nvl(ccid.end_date_active, h.accounting_date)
                            --ccid.summary_flag = ''Y'' OR
                            --(ccid.detail_posting_allowed_flag = ''N'' AND h.balance_type_code <> ''B'') OR
                            --(ccid.detail_budgeting_allowed_flag =''N'' AND h.balance_type_code = ''B'')
                           )
                      THEN l.code_combination_id
                      ELSE NULL END
                -- suspense_code_combination_id
                ,NVL(gsa.code_combination_id,
                      NVL(gsa1.code_combination_id,
                          NVL(gsa2.code_combination_id, gsa3.code_combination_id)))
                ,h.accounting_entry_status_code
                ,h.period_name
      FROM       xla_ae_headers_gt      h
                ,xla_ae_lines           l
                ,gl_code_combinations   ccid
                ,gl_code_combinations   ccid1
                ,gl_suspense_accounts gsa
                ,gl_suspense_accounts gsa1
                ,gl_suspense_accounts gsa2
                ,gl_suspense_accounts gsa3
                ,fnd_currencies fcu
      WHERE     ccid.code_combination_id(+) = l.code_combination_id
        AND     l.ae_header_id          = h.ae_header_id
        AND       h.ledger_id             = :9
        AND       ccid1.code_combination_id(+) = ccid.alternate_code_combination_id
        and       gsa.ledger_id (+) = :10
        and       gsa.je_source_name (+) = :11
        and       gsa.je_category_name (+) = h.je_category_name
        and       gsa1.ledger_id (+) = NVL(:12, h.ledger_id)
        and       gsa1.je_source_name (+) = :13
        and       gsa1.je_category_name (+) = ''Other''
        and       gsa2.ledger_id (+) = :14
        and       gsa2.je_source_name (+) = ''Other''
        and       gsa2.je_category_name (+) = h.je_category_name
        and       gsa3.ledger_id (+) = NVL(:15, h.ledger_id)
        and       gsa3.je_source_name (+) = ''Other''
        and       gsa3.je_category_name (+) = ''Other''
        and       l.currency_code = fcu.currency_code
        AND       h.accounting_date      <= NVL(:16,h.accounting_date)   -- 4262811
        AND       l.application_id      = '||g_application_id;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace(p_msg    => substr(l_stmt, 1, 4000),
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 4001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 8001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 12001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 16001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 20001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
      END IF;

      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace(p_msg    => 'g_ledger_currency_code = '||g_ledger_currency_code,
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => 'g_ledger_coa_id = '||g_ledger_coa_id,
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => 'g_ledger_id = '||g_ledger_id,
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => 'g_target_ledger_id = '||g_target_ledger_id,
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => 'g_app_je_source_name = '||g_app_je_source_name,
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => 'g_end_date = '||g_end_date,
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
      END IF;

      EXECUTE IMMEDIATE l_stmt using
          g_ledger_currency_code
        -- ,g_ledger_currency_code -- commented for bug:8417965
         ,g_ledger_currency_code
         ,g_ledger_coa_id
         ,g_ledger_currency_code -- 5
        -- ,g_ledger_currency_code -- commented for bug:8417965
         ,g_ledger_currency_code
         ,g_ledger_coa_id
         ,g_ledger_id
         ,g_target_ledger_id    -- 10
         ,g_app_je_source_name
         ,g_target_ledger_id
         ,g_app_je_source_name
         ,g_target_ledger_id
         ,g_target_ledger_id    -- 15
         ,g_end_date                  -- 4262811
         ;

      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace(p_msg    => '# of rows inserted:'||to_char(SQL%ROWCOUNT),
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
      END IF;

      l_stmt:=
       'UPDATE xla_validation_lines_gt l
       SET
        ( l.bal_seg_value
        ,l.mgt_seg_value
        ,l.cost_center_seg_value
        ,l.natural_account_seg_value
        ,l.ccid_enabled_flag
        ,l.ccid_summary_flag
        ,l.detail_posting_allowed_flag
        ,l.detail_budgeting_allowed_flag
        ,l.control_account_enabled_flag
        ,l.error_flag) =
       ( SELECT
           ccid.' || g_bal_seg_column_name;

      IF (g_mgt_seg_column_name is NULL) THEN
        l_stmt := l_stmt || '
           ,NULL';
      ELSE
        l_stmt := l_stmt || '
           ,ccid.'||g_mgt_seg_column_name;
      END IF;

      IF (g_cc_seg_column_name is NULL) THEN
        l_stmt := l_stmt || '
           ,NULL';
      ELSE
        l_stmt := l_stmt || '
           ,ccid.'||g_cc_seg_column_name;
      END IF;

      IF (g_na_seg_column_name is NULL) THEN
        l_stmt := l_stmt || '
           ,NULL';
      ELSE
        l_stmt := l_stmt || '
           ,ccid.'||g_na_seg_column_name;
      END IF;

      l_stmt := l_stmt || '
           ,CASE
               WHEN ccid.enabled_flag IS NULL THEN NULL
               WHEN ccid.enabled_flag = ''N'' THEN ''N''
               WHEN l.accounting_date < nvl(ccid.start_date_active, l.accounting_date) THEN ''D''
               WHEN l.accounting_date > nvl(ccid.end_date_active, l.accounting_date) THEN ''D''
               ELSE ''Y''
            END
            ,CASE WHEN ccid.summary_flag = ''Y'' THEN ''Y'' ELSE ''N'' END
            ,ccid.detail_posting_allowed_flag
            ,ccid.detail_budgeting_allowed_flag
            ,nvl(ccid.reference3,''N'')
            ,CASE WHEN ccid.enabled_flag IS NULL
                      or l.accounting_class_code IS NULL
                      or ccid.enabled_flag = ''N''
                      or l.accounting_date < nvl(ccid.start_date_active, l.accounting_date)
                      or l.accounting_date > nvl(ccid.end_date_active, l.accounting_date)
                      or (ccid.summary_flag = ''Y'')
                      or (l.balance_type_code <> ''B'' AND ccid.detail_posting_allowed_flag = ''N'')
                      or (l.balance_type_code = ''B'' AND ccid.detail_budgeting_allowed_flag = ''N'')
                      or ('''||g_app_ctl_acct_source_code||''' <> ''Y'' AND
                           (nvl(ccid.reference3,''N'') NOT IN (''Y'', ''N'', ''R'','''||g_app_ctl_acct_source_code||''')))
                      or ('''||g_app_ctl_acct_source_code||''' = ''N'' AND nvl(ccid.reference3,''N'') NOT IN (''N'',''R''))
                      or (nvl(ccid.reference3,''N'') NOT IN (''N'',''R'') AND
                          (l.party_type_code IS NULL OR l.party_id IS NULL))
                      or (nvl(ccid.reference3,''N'') = ''CUSTOMER'' AND l.party_type_code <> ''C'')
                      or (nvl(ccid.reference3,''N'') = ''SUPPLIER'' AND l.party_type_code <> ''S'')
                      or (l.party_type_code IS NOT NULL AND l.party_type_code NOT IN (''C'', ''S''))
                      or ((l.party_id IS NOT NULL OR l.party_site_id IS NOT NULL) AND l.party_type_code IS NULL)
                     -- or ((l.party_site_id IS NOT NULL OR l.party_type_code IS NOT NULL) AND l.party_id IS NULL)
                      or (nvl(l.gain_or_loss_flag,''N'') = ''N'' AND l.entered_dr IS NULL AND l.entered_cr IS NULL)
                      or (l.entered_dr IS NOT NULL AND l.accounted_dr IS NULL)
                      or (l.entered_cr IS NOT NULL AND l.accounted_cr IS NULL)
                      or (nvl(l.gain_or_loss_flag, ''N'') = ''N'' and l.entered_dr IS NULL AND l.accounted_dr IS NOT NULL)
                      or (nvl(l.gain_or_loss_flag, ''N'') = ''N'' and l.entered_cr IS NULL AND l.accounted_cr IS NOT NULL)
                      or (NVL(l.entered_cr,0) > 0 AND NVL(l.accounted_cr,0) < 0)
                      or (NVL(l.entered_dr,0) > 0 AND NVL(l.accounted_dr,0) < 0)
                      or (NVL(l.entered_cr,0) < 0 AND NVL(l.accounted_cr,0) > 0)
                      or (NVL(l.entered_dr,0) < 0 AND NVL(l.accounted_dr,0) > 0)
                      or (:1 = l.entered_currency_code AND nvl(l.gain_or_loss_flag, ''N'') = ''N'' AND
                          (nvl(l.unrounded_entered_dr,9E125) <> nvl(l.unrounded_accounted_dr,9E125) or
                           nvl(l.unrounded_entered_cr,9E125) <> nvl(l.unrounded_accounted_cr,9E125)))
                     /* or (:2 = l.entered_currency_code AND
                          (l.currency_conversion_type IS NOT NULL or nvl(l.currency_conversion_rate,1) <> 1)) */ -- commented for bug:8417965
                      or (:3 <> l.entered_currency_code AND
                          ((l.currency_conversion_type = ''User'' AND l.currency_conversion_rate IS NULL) or
                           (nvl(l.currency_conversion_type,''User'') <> ''User'' AND l.currency_conversion_date IS NULL)))
                      or (:4 <> ccid.chart_of_accounts_id)
                      or (l.accounted_cr is NULL and l.accounted_dr is NULL and l.currency_conversion_rate is NULL)
                      THEN ''Y''
                      ELSE NULL
            END
         FROM gl_code_combinations ccid
         WHERE ccid.code_combination_id = l.code_combination_id )
      WHERE l.substituted_by_suspense_flag= ''Y''';

      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace(p_msg    => 'UPDATE sql:',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 1, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 4001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
      END IF;

      EXECUTE IMMEDIATE l_stmt using
         g_ledger_currency_code
        -- ,g_ledger_currency_code -- commented for bug:8417965
         ,g_ledger_currency_code
         ,g_ledger_coa_id
         ;
      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace(p_msg    => '# of rows updated:'||to_char(SQL%ROWCOUNT),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
      END IF;

    ELSE  -- (g_sla_bal_by_ledger_curr_flag <> 'Y')
      l_stmt := '
      INSERT INTO xla_validation_lines_gt
        (ae_header_id
        ,ae_line_num
        ,ledger_id
        ,displayed_line_number
        ,max_ae_line_num
        ,max_displayed_line_number
        ,entity_id
        ,event_id
        ,balance_type_code
        ,budget_version_id
        ,encumbrance_type_id
        ,accounting_date
        ,je_category_name
        ,party_type_code
        ,party_id
        ,party_site_id
        ,entered_currency_code
        ,unrounded_entered_cr
        ,unrounded_entered_dr
        ,entered_cr
        ,entered_dr
        ,entered_currency_mau
        ,unrounded_accounted_cr
        ,unrounded_accounted_dr
        ,accounted_cr
        ,accounted_dr
        ,currency_conversion_type
        ,currency_conversion_date
        ,currency_conversion_rate
        ,code_combination_id
        ,accounting_class_code
        ,bal_seg_value
        ,mgt_seg_value
        ,cost_center_seg_value
        ,natural_account_seg_value
        ,ccid_coa_id
        ,ccid_enabled_flag
        ,ccid_summary_flag
        ,detail_posting_allowed_flag
        ,detail_budgeting_allowed_flag
        ,control_account_enabled_flag
        ,product_rule_type_code
        ,product_rule_code
        ,balancing_line_type
        ,error_flag
        ,substituted_ccid
        ,accounting_entry_status_code
        ,period_name
        ,gain_or_loss_flag
        )
      SELECT     /*+  cardinality(h,1) index(l, XLA_AE_LINES_U1) use_nl(l) use_nl(ccid) */
                 h.ae_header_id
                ,l.ae_line_num
                ,h.ledger_id
                ,l.displayed_line_number
                ,max(l.ae_line_num) over (partition by l.ae_header_id)
                ,max(l.displayed_line_number) over (partition by l.ae_header_id)
                ,h.entity_id
                ,h.event_id
                ,h.balance_type_code
                ,h.budget_version_id
                ,l.encumbrance_type_id
                ,h.accounting_date
                ,h.je_category_name
                ,l.party_type_code
                ,l.party_id
                ,l.party_site_id
                ,l.currency_code
                ,l.unrounded_entered_cr
                ,l.unrounded_entered_dr
                ,l.entered_cr
                ,l.entered_dr
                ,nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
                ,l.unrounded_accounted_cr
                ,l.unrounded_accounted_dr
                ,l.accounted_cr
                ,l.accounted_dr
                ,l.currency_conversion_type
                ,l.currency_conversion_date
                ,l.currency_conversion_rate
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN
                     ccid1.code_combination_id
                 ELSE l.code_combination_id
                 END
                ,l.accounting_class_code
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN
                     ccid1.'||g_bal_seg_column_name||'
                 ELSE ccid.'||g_bal_seg_column_name||'
                 END';
       IF (g_mgt_seg_column_name is NULL) THEN
         l_stmt := l_stmt || '
                ,NULL';
       ELSE
         l_stmt := l_stmt || '
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN
                     ccid1.'||g_mgt_seg_column_name||'
                 ELSE ccid.'||g_mgt_seg_column_name||'
                 END';
       END IF;

       IF (g_cc_seg_column_name is NULL) THEN
         l_stmt := l_stmt || '
                ,NULL';
       ELSE
         l_stmt := l_stmt || '
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN
                     ccid1.'||g_cc_seg_column_name||'
                 ELSE ccid.'||g_cc_seg_column_name||'
                 END';
       END IF;

       IF (g_na_seg_column_name is NULL) THEN
         l_stmt := l_stmt || '
                ,NULL';
       ELSE
         l_stmt := l_stmt || '
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN
                     ccid1.'||g_na_seg_column_name||'
                 ELSE ccid.'||g_na_seg_column_name||'
                 END';
       END IF;

       l_stmt := l_stmt || '
                ,ccid.chart_of_accounts_id
                ,CASE WHEN l.code_combination_id = -1 THEN ''Y''
                      WHEN (ccid.enabled_flag = ''N''
                             or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                             or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                            and ccid.alternate_code_combination_id is not NULL
                      THEN
                          CASE
                          WHEN ccid1.enabled_flag IS NULL THEN NULL
                          WHEN ccid1.enabled_flag = ''N'' THEN ''N''
                          WHEN h.accounting_date < nvl(ccid1.start_date_active, h.accounting_date) THEN ''D''
                          WHEN h.accounting_date > nvl(ccid1.end_date_active, h.accounting_date) THEN ''D''
                          ELSE ''Y''
                          END
                      ELSE
                          CASE
                          WHEN ccid.enabled_flag IS NULL THEN NULL
                          WHEN ccid.enabled_flag = ''N'' THEN ''N''
                          WHEN h.accounting_date < nvl(ccid.start_date_active, h.accounting_date) THEN ''D''
                          WHEN h.accounting_date > nvl(ccid.end_date_active, h.accounting_date) THEN ''D''
                          ELSE ''Y''
                          END
                      END
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN
                     CASE WHEN ccid1.summary_flag = ''Y'' THEN ''Y'' ELSE ''N'' END
                 ELSE
                     CASE WHEN ccid.summary_flag = ''Y'' THEN ''Y'' ELSE ''N'' END
                 END
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN ccid1.detail_posting_allowed_flag
                 ELSE ccid.detail_posting_allowed_flag
                 END
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN ccid1.detail_budgeting_allowed_flag
                 ELSE ccid.detail_budgeting_allowed_flag
                 END
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN nvl(ccid1.reference3,''N'')
                 ELSE nvl(ccid.reference3,''N'')
                 END
                ,h.product_rule_type_code
                ,h.product_rule_code
                ,'''||C_LINE_TYPE_PROCESS||'''
                ,CASE
                 WHEN l.code_combination_id <> -1
                      and (ccid.enabled_flag = ''N''
                           or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                           or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date))
                      and ccid.alternate_code_combination_id is not NULL
                 THEN
                    CASE WHEN ccid1.enabled_flag IS NULL
                      or (ccid1.code_combination_id = -1 and nvl(l.gain_or_loss_flag, ''N'')=''Y'')
                      or l.accounting_class_code IS NULL
                      or ccid1.enabled_flag = ''N''
                      or h.accounting_date < nvl(ccid1.start_date_active, h.accounting_date)
                      or h.accounting_date > nvl(ccid1.end_date_active, h.accounting_date)
                      or (ccid1.summary_flag = ''Y'')
                      or (h.balance_type_code <> ''B'' AND ccid1.detail_posting_allowed_flag = ''N'')
                      or (h.balance_type_code = ''B'' AND ccid1.detail_budgeting_allowed_flag = ''N'')
                      or ('''||g_app_ctl_acct_source_code||''' <> ''Y'' AND
                          (nvl(ccid1.reference3,''N'') NOT IN (''Y'', ''N'', ''R'', '''||g_app_ctl_acct_source_code||''')))
                      or ('''||g_app_ctl_acct_source_code||''' = ''N'' AND nvl(ccid1.reference3,''N'') NOT IN (''N'',''R''))
                      or (nvl(ccid1.reference3,''N'') NOT IN (''N'',''R'') AND
                          (l.party_type_code IS NULL OR l.party_id IS NULL))
                      or (nvl(ccid1.reference3,''N'') = ''CUSTOMER'' AND l.party_type_code <> ''C'')
                      or (nvl(ccid1.reference3,''N'') = ''SUPPLIER'' AND l.party_type_code <> ''S'')
                      or (l.party_type_code IS NOT NULL AND l.party_type_code NOT IN (''C'', ''S''))
                      or ((l.party_id IS NOT NULL OR l.party_site_id IS NOT NULL) AND l.party_type_code IS NULL)
                     -- or ((l.party_site_id IS NOT NULL OR l.party_type_code IS NOT NULL) AND l.party_id IS NULL)
                      or (nvl(l.gain_or_loss_flag,''N'') = ''N'' AND l.entered_dr IS NULL AND l.entered_cr IS NULL)
                      or (l.entered_dr IS NOT NULL AND l.accounted_dr IS NULL)
                      or (l.entered_cr IS NOT NULL AND l.accounted_cr IS NULL)
                      or (nvl(l.gain_or_loss_flag, ''N'') = ''N'' and l.entered_dr IS NULL AND l.accounted_dr IS NOT NULL)
                      or (nvl(l.gain_or_loss_flag, ''N'') = ''N'' and l.entered_cr IS NULL AND l.accounted_cr IS NOT NULL)
                      or (NVL(l.entered_cr,0) > 0 AND NVL(l.accounted_cr,0) < 0)
                      or (NVL(l.entered_dr,0) > 0 AND NVL(l.accounted_dr,0) < 0)
                      or (NVL(l.entered_cr,0) < 0 AND NVL(l.accounted_cr,0) > 0)
                      or (NVL(l.entered_dr,0) < 0 AND NVL(l.accounted_dr,0) > 0)
                      or (:1 = l.currency_code AND nvl(l.gain_or_loss_flag, ''N'') = ''N'' AND
                          (nvl(l.unrounded_entered_dr,9E125) <> nvl(l.unrounded_accounted_dr,9E125) or
                           nvl(l.unrounded_entered_cr,9E125) <> nvl(l.unrounded_accounted_cr,9E125)))
                    /*  or (:2 = l.currency_code AND
                          (l.currency_conversion_type IS NOT NULL or nvl(l.currency_conversion_rate,1) <> 1)) */ -- commented for bug:8417965
                      or (:3 <> l.currency_code AND
                          ((l.currency_conversion_type = ''User'' AND l.currency_conversion_rate IS NULL) or
                           (nvl(l.currency_conversion_type,''User'') <> ''User'' AND l.currency_conversion_date IS NULL)))
                      or (:4 <> ccid1.chart_of_accounts_id)
                      or (l.accounted_cr is NULL and l.accounted_dr is NULL and l.currency_conversion_rate is NULL)
                      THEN ''Y''
                      ELSE NULL
                      END
                 ELSE
                    CASE WHEN ccid.enabled_flag IS NULL
                      or (ccid.code_combination_id = -1 and nvl(l.gain_or_loss_flag, ''N'')=''Y'')
                      or l.accounting_class_code IS NULL
                      or ccid.enabled_flag = ''N''
                      or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                      or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date)
                      or (ccid.summary_flag = ''Y'')
                      or (h.balance_type_code <> ''B'' AND ccid.detail_posting_allowed_flag = ''N'')
                      or (h.balance_type_code = ''B'' AND ccid.detail_budgeting_allowed_flag = ''N'')
                      or ('''||g_app_ctl_acct_source_code||''' <> ''Y'' AND
                          (nvl(ccid.reference3,''N'') NOT IN (''Y'', ''N'',''R'', '''||g_app_ctl_acct_source_code||''')))
                      or ('''||g_app_ctl_acct_source_code||''' = ''N'' AND nvl(ccid.reference3,''N'') NOT IN (''N'',''R''))
                      or (nvl(ccid.reference3,''N'') NOT IN (''N'',''R'') AND
                          (l.party_type_code IS NULL OR l.party_id IS NULL))
                      or (nvl(ccid.reference3,''N'') = ''CUSTOMER'' AND l.party_type_code <> ''C'')
                      or (nvl(ccid.reference3,''N'') = ''SUPPLIER'' AND l.party_type_code <> ''S'')
                      or (l.party_type_code IS NOT NULL AND l.party_type_code NOT IN (''C'', ''S''))
                      or ((l.party_id IS NOT NULL OR l.party_site_id IS NOT NULL) AND l.party_type_code IS NULL)
                     -- or ((l.party_site_id IS NOT NULL OR l.party_type_code IS NOT NULL) AND l.party_id IS NULL)
                      or (nvl(l.gain_or_loss_flag,''N'') = ''N'' AND l.entered_dr IS NULL AND l.entered_cr IS NULL)
                      or (l.entered_dr IS NOT NULL AND l.accounted_dr IS NULL)
                      or (l.entered_cr IS NOT NULL AND l.accounted_cr IS NULL)
                      or (nvl(l.gain_or_loss_flag, ''N'') = ''N'' and l.entered_dr IS NULL AND l.accounted_dr IS NOT NULL)
                      or (nvl(l.gain_or_loss_flag, ''N'') = ''N'' and l.entered_cr IS NULL AND l.accounted_cr IS NOT NULL)
                      or (NVL(l.entered_cr,0) > 0 AND NVL(l.accounted_cr,0) < 0)
                      or (NVL(l.entered_dr,0) > 0 AND NVL(l.accounted_dr,0) < 0)
                      or (NVL(l.entered_cr,0) < 0 AND NVL(l.accounted_cr,0) > 0)
                      or (NVL(l.entered_dr,0) < 0 AND NVL(l.accounted_dr,0) > 0)
                      or (:5 = l.currency_code AND nvl(l.gain_or_loss_flag, ''N'') = ''N'' AND
                          (nvl(l.unrounded_entered_dr,9E125) <> nvl(l.unrounded_accounted_dr,9E125) or
                           nvl(l.unrounded_entered_cr,9E125) <> nvl(l.unrounded_accounted_cr,9E125)))
                    /*  or (:6 = l.currency_code AND
                          (l.currency_conversion_type IS NOT NULL or nvl(l.currency_conversion_rate,1) <> 1)) */ -- commented for bug:8417965
                      or (:7 <> l.currency_code AND
                          ((l.currency_conversion_type = ''User'' AND l.currency_conversion_rate IS NULL) or
                           (nvl(l.currency_conversion_type,''User'') <> ''User'' AND l.currency_conversion_date IS NULL)))
                      or (:8 <> ccid.chart_of_accounts_id)
                      or (l.accounted_cr is NULL and l.accounted_dr is NULL and l.currency_conversion_rate is NULL)
                      THEN ''Y''
                      ELSE NULL
                      END
                 END
                ,CASE WHEN l.code_combination_id <> -1 AND  -- substituted_ccid
                           (ccid.enabled_flag = ''N'' OR
                            h.accounting_date < nvl(ccid.start_date_active, h.accounting_date) OR
                            h.accounting_date > nvl(ccid.end_date_active, h.accounting_date)) AND
                           ccid.alternate_code_combination_id IS NOT NULL
                      THEN l.code_combination_id
                      ELSE NULL END
                ,h.accounting_entry_status_code
                ,h.period_name
                ,l.gain_or_loss_flag
      FROM       xla_ae_headers_gt      h
                ,xla_ae_lines           l
                ,gl_code_combinations   ccid
                ,gl_code_combinations   ccid1
                ,fnd_currencies fcu
      WHERE     ccid.code_combination_id(+) = l.code_combination_id
        AND     l.ae_header_id          = h.ae_header_id
        AND       h.ledger_id             = :9
        AND       ccid1.code_combination_id(+) = ccid.alternate_code_combination_id
        AND       l.currency_code = fcu.currency_code
        AND     l.application_id        = '||g_application_id;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace(p_msg    => substr(l_stmt, 1, 4000),
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 4001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 8001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 12001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 16001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
        trace(p_msg    => substr(l_stmt, 20001, 4000),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
      END IF;

      EXECUTE IMMEDIATE l_stmt using
          g_ledger_currency_code
       --  ,g_ledger_currency_code -- commented for bug:8417965
         ,g_ledger_currency_code
         ,g_ledger_coa_id
         ,g_ledger_currency_code
       --  ,g_ledger_currency_code -- commented for bug:8417965
         ,g_ledger_currency_code
         ,g_ledger_coa_id
         ,g_ledger_id;

      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace(p_msg    => '# of rows inserted:'||to_char(SQL%ROWCOUNT),
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
      END IF;
    END IF;

    UPDATE xla_ae_headers
       SET zero_amount_flag = 'Y'
     WHERE application_id = g_application_id and
           ae_header_id in
           (select /*+ cardinality(XLA_VALIDATION_LINES_GT, 1) */  ae_header_id  --bug9174950
              from xla_validation_lines_gt
             group by ae_header_id
             having sum(abs(accounted_cr)) = 0 and sum(abs(accounted_dr))=0);

    IF (p_budgetary_control_mode = 'NONE') THEN
      UPDATE /*+ index(XAL,XLA_AE_LINES_U1)*/ xla_ae_lines xal -- 4769388
         SET (code_combination_id, substituted_ccid)=
               (SELECT code_combination_id, substituted_ccid
                  FROM xla_validation_lines_gt xvlg
                 WHERE xvlg.ae_header_id = xal.ae_header_id
                   AND xvlg.ae_line_num = xal.ae_line_num)
       WHERE xal.application_id = g_application_id
         AND (xal.ae_header_id, xal.ae_line_num) in
             (select /*+ unnest cardinality(GT,10)*/        -- 4769388
                     ae_header_id, ae_line_num
                from xla_validation_lines_gt  GT            -- 4769388
               where substituted_ccid is not NULL);

      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace(p_msg    => '# of rows updated to xla_ae_lines:'||to_char(SQL%ROWCOUNT),
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
      END IF;
    END IF;


  ELSE   -- (g_caller <> mpa or acct program or third party merge)

    INSERT INTO xla_validation_lines_gt
        (ae_header_id
        ,ae_line_num
        ,ledger_id
        ,displayed_line_number
        ,max_ae_line_num
        ,max_displayed_line_number
        ,entity_id
        ,event_id
        ,balance_type_code
        ,budget_version_id
        ,encumbrance_type_id
        ,accounting_date
        ,je_category_name
        ,party_type_code
        ,party_id
        ,party_site_id
        ,entered_currency_code
        ,unrounded_entered_cr
        ,unrounded_entered_dr
        ,entered_cr
        ,entered_dr
        ,entered_currency_mau
        ,unrounded_accounted_cr
        ,unrounded_accounted_dr
        ,accounted_cr
        ,accounted_dr
        ,currency_conversion_type
        ,currency_conversion_date
        ,currency_conversion_rate
        ,code_combination_id
        ,accounting_class_code
        ,bal_seg_value
        ,mgt_seg_value
        ,cost_center_seg_value
        ,natural_account_seg_value
        ,ccid_coa_id
        ,ccid_enabled_flag
        ,ccid_summary_flag
        ,detail_posting_allowed_flag
        ,detail_budgeting_allowed_flag
        ,control_account_enabled_flag
        ,accounting_entry_status_code
        ,period_name
        ,balancing_line_type
        ,error_flag)
    SELECT       h.ae_header_id
                ,l.ae_line_num
                ,h.ledger_id
                ,l.displayed_line_number
                ,max(l.ae_line_num) over (partition by l.ae_header_id)
                ,max(l.displayed_line_number) over (partition by l.ae_header_id)
                ,h.entity_id
                ,h.event_id
                ,h.balance_type_code
                ,h.budget_version_id
                ,l.encumbrance_type_id
                ,h.accounting_date
                ,h.je_category_name
                ,l.party_type_code
                ,l.party_id
                ,l.party_site_id
                ,l.currency_code
                ,l.unrounded_entered_cr
                ,l.unrounded_entered_dr
                ,l.entered_cr
                ,l.entered_dr
                ,nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
                ,l.unrounded_accounted_cr
                ,l.unrounded_accounted_dr
                ,l.accounted_cr
                ,l.accounted_dr
                ,l.currency_conversion_type
                ,l.currency_conversion_date
                ,l.currency_conversion_rate
                ,l.code_combination_id
                ,l.accounting_class_code
                ,decode(g_bal_seg_column_name,
                                        'SEGMENT1', ccid.segment1,
                                        'SEGMENT2', ccid.segment2,
                                        'SEGMENT3', ccid.segment3,
                                        'SEGMENT4', ccid.segment4,
                                        'SEGMENT5', ccid.segment5,
                                        'SEGMENT6', ccid.segment6,
                                        'SEGMENT7', ccid.segment7,
                                        'SEGMENT8', ccid.segment8,
                                        'SEGMENT9', ccid.segment9,
                                        'SEGMENT10', ccid.segment10,
                                        'SEGMENT11', ccid.segment11,
                                        'SEGMENT12', ccid.segment12,
                                        'SEGMENT13', ccid.segment13,
                                        'SEGMENT14', ccid.segment14,
                                        'SEGMENT15', ccid.segment15,
                                        'SEGMENT16', ccid.segment16,
                                        'SEGMENT17', ccid.segment17,
                                        'SEGMENT18', ccid.segment18,
                                        'SEGMENT19', ccid.segment19,
                                        'SEGMENT20', ccid.segment20,
                                        'SEGMENT21', ccid.segment21,
                                        'SEGMENT22', ccid.segment22,
                                        'SEGMENT23', ccid.segment23,
                                        'SEGMENT24', ccid.segment24,
                                        'SEGMENT25', ccid.segment25,
                                        'SEGMENT26', ccid.segment26,
                                        'SEGMENT27', ccid.segment27,
                                        'SEGMENT28', ccid.segment28,
                                        'SEGMENT29', ccid.segment29,
                                        'SEGMENT30', ccid.segment30,
                                        NULL)
                ,decode(g_mgt_seg_column_name,
                                        'SEGMENT1', ccid.segment1,
                                        'SEGMENT2', ccid.segment2,
                                        'SEGMENT3', ccid.segment3,
                                        'SEGMENT4', ccid.segment4,
                                        'SEGMENT5', ccid.segment5,
                                        'SEGMENT6', ccid.segment6,
                                        'SEGMENT7', ccid.segment7,
                                        'SEGMENT8', ccid.segment8,
                                        'SEGMENT9', ccid.segment9,
                                        'SEGMENT10', ccid.segment10,
                                        'SEGMENT11', ccid.segment11,
                                        'SEGMENT12', ccid.segment12,
                                        'SEGMENT13', ccid.segment13,
                                        'SEGMENT14', ccid.segment14,
                                        'SEGMENT15', ccid.segment15,
                                        'SEGMENT16', ccid.segment16,
                                        'SEGMENT17', ccid.segment17,
                                        'SEGMENT18', ccid.segment18,
                                        'SEGMENT19', ccid.segment19,
                                        'SEGMENT20', ccid.segment20,
                                        'SEGMENT21', ccid.segment21,
                                        'SEGMENT22', ccid.segment22,
                                        'SEGMENT23', ccid.segment23,
                                        'SEGMENT24', ccid.segment24,
                                        'SEGMENT25', ccid.segment25,
                                        'SEGMENT26', ccid.segment26,
                                        'SEGMENT27', ccid.segment27,
                                        'SEGMENT28', ccid.segment28,
                                        'SEGMENT29', ccid.segment29,
                                        'SEGMENT30', ccid.segment30,
                                        NULL)
                ,decode(g_cc_seg_column_name,
                                        'SEGMENT1', ccid.segment1,
                                        'SEGMENT2', ccid.segment2,
                                        'SEGMENT3', ccid.segment3,
                                        'SEGMENT4', ccid.segment4,
                                        'SEGMENT5', ccid.segment5,
                                        'SEGMENT6', ccid.segment6,
                                        'SEGMENT7', ccid.segment7,
                                        'SEGMENT8', ccid.segment8,
                                        'SEGMENT9', ccid.segment9,
                                        'SEGMENT10', ccid.segment10,
                                        'SEGMENT11', ccid.segment11,
                                        'SEGMENT12', ccid.segment12,
                                        'SEGMENT13', ccid.segment13,
                                        'SEGMENT14', ccid.segment14,
                                        'SEGMENT15', ccid.segment15,
                                        'SEGMENT16', ccid.segment16,
                                        'SEGMENT17', ccid.segment17,
                                        'SEGMENT18', ccid.segment18,
                                        'SEGMENT19', ccid.segment19,
                                        'SEGMENT20', ccid.segment20,
                                        'SEGMENT21', ccid.segment21,
                                        'SEGMENT22', ccid.segment22,
                                        'SEGMENT23', ccid.segment23,
                                        'SEGMENT24', ccid.segment24,
                                        'SEGMENT25', ccid.segment25,
                                        'SEGMENT26', ccid.segment26,
                                        'SEGMENT27', ccid.segment27,
                                        'SEGMENT28', ccid.segment28,
                                        'SEGMENT29', ccid.segment29,
                                        'SEGMENT30', ccid.segment30,
                                        NULL)
                ,decode(g_na_seg_column_name,
                                        'SEGMENT1', ccid.segment1,
                                        'SEGMENT2', ccid.segment2,
                                        'SEGMENT3', ccid.segment3,
                                        'SEGMENT4', ccid.segment4,
                                        'SEGMENT5', ccid.segment5,
                                        'SEGMENT6', ccid.segment6,
                                        'SEGMENT7', ccid.segment7,
                                        'SEGMENT8', ccid.segment8,
                                        'SEGMENT9', ccid.segment9,
                                        'SEGMENT10', ccid.segment10,
                                        'SEGMENT11', ccid.segment11,
                                        'SEGMENT12', ccid.segment12,
                                        'SEGMENT13', ccid.segment13,
                                        'SEGMENT14', ccid.segment14,
                                        'SEGMENT15', ccid.segment15,
                                        'SEGMENT16', ccid.segment16,
                                        'SEGMENT17', ccid.segment17,
                                        'SEGMENT18', ccid.segment18,
                                        'SEGMENT19', ccid.segment19,
                                        'SEGMENT20', ccid.segment20,
                                        'SEGMENT21', ccid.segment21,
                                        'SEGMENT22', ccid.segment22,
                                        'SEGMENT23', ccid.segment23,
                                        'SEGMENT24', ccid.segment24,
                                        'SEGMENT25', ccid.segment25,
                                        'SEGMENT26', ccid.segment26,
                                        'SEGMENT27', ccid.segment27,
                                        'SEGMENT28', ccid.segment28,
                                        'SEGMENT29', ccid.segment29,
                                        'SEGMENT30', ccid.segment30,
                                        NULL)
                ,ccid.chart_of_accounts_id
                ,CASE WHEN g_caller = C_CALLER_ACCT_PROGRAM AND l.code_combination_id = -1 THEN 'Y'
                      WHEN ccid.enabled_flag IS NULL THEN NULL
                      WHEN ccid.enabled_flag = 'N' THEN 'N'
                      WHEN h.accounting_date < nvl(ccid.start_date_active, h.accounting_date) THEN 'D'
                      WHEN h.accounting_date > nvl(ccid.end_date_active, h.accounting_date) THEN 'D'
                      ELSE 'Y' END
                ,CASE WHEN ccid.summary_flag = 'Y' THEN 'Y' ELSE 'N' END
                ,ccid.detail_posting_allowed_flag
                ,ccid.detail_budgeting_allowed_flag
                ,nvl(ccid.reference3,'N')
                ,h.accounting_entry_status_code
                ,h.period_name
                ,C_LINE_TYPE_PROCESS
                ,CASE WHEN ccid.enabled_flag IS NULL
                      or ccid.enabled_flag = 'N'
                      or l.accounting_class_code IS NULL
                      or h.accounting_date < nvl(ccid.start_date_active, h.accounting_date)
                      or h.accounting_date > nvl(ccid.end_date_active, h.accounting_date)
                      or (ccid.summary_flag = 'Y')
                      or (h.balance_type_code <> 'B' AND ccid.detail_posting_allowed_flag = 'N')
                      or (h.balance_type_code = 'B' AND ccid.detail_budgeting_allowed_flag = 'N')
                      or (g_app_ctl_acct_source_code <> 'Y'
                            AND (nvl(ccid.reference3,'N') NOT IN ('Y', 'N', 'R', g_app_ctl_acct_source_code)))
                      or (g_app_ctl_acct_source_code= 'N' AND nvl(ccid.reference3,'N') NOT IN  ('N','R'))
                      or (nvl(ccid.reference3,'N') NOT IN ('N','R') AND
                          (l.party_type_code IS NULL OR l.party_id IS NULL))
                      or (nvl(ccid.reference3,'N') = 'CUSTOMER' AND l.party_type_code <> 'C')
                      or (nvl(ccid.reference3,'N') = 'SUPPLIER' AND l.party_type_code <> 'S')
                      or (l.party_type_code IS NOT NULL AND l.party_type_code NOT IN ('C', 'S'))
                      or ((l.party_id IS NOT NULL OR l.party_site_id IS NOT NULL) AND l.party_type_code IS NULL)
                     -- or ((l.party_site_id IS NOT NULL OR l.party_type_code IS NOT NULL) AND l.party_id IS NULL)
                      or (l.entered_dr IS NULL AND l.entered_cr IS NULL)
                      or (l.entered_dr IS NOT NULL AND l.accounted_dr IS NULL)
                      or (l.entered_cr IS NOT NULL AND l.accounted_cr IS NULL)
                      or (l.entered_dr IS NULL AND l.accounted_dr IS NOT NULL)
                      or (l.entered_cr IS NULL AND l.accounted_cr IS NOT NULL)
                      or (NVL(l.entered_cr,0) > 0 AND NVL(l.accounted_cr,0) < 0)
                      or (NVL(l.entered_dr,0) > 0 AND NVL(l.accounted_dr,0) < 0)
                      or (NVL(l.entered_cr,0) < 0 AND NVL(l.accounted_cr,0) > 0)
                      or (NVL(l.entered_dr,0) < 0 AND NVL(l.accounted_dr,0) > 0)
                      or (g_ledger_currency_code = l.currency_code AND
                          (nvl(l.unrounded_entered_dr,C_NUM) <> nvl(l.unrounded_accounted_dr,C_NUM) or
                           nvl(l.unrounded_entered_cr,C_NUM) <> nvl(l.unrounded_accounted_cr,C_NUM)))
                    /*  or (g_ledger_currency_code = l.currency_code AND
                          (l.currency_conversion_type IS NOT NULL or nvl(l.currency_conversion_rate,1) <> 1)) */ -- commented for bug:8417965
                      or (g_ledger_currency_code <> l.currency_code AND
                          ((l.currency_conversion_type = 'User' AND l.currency_conversion_rate IS NULL) or
                           (nvl(l.currency_conversion_type,'User') <> 'User' AND l.currency_conversion_date IS NULL)))
                      or (g_ledger_coa_id <> ccid.chart_of_accounts_id)
                      THEN 'Y'
                      ELSE NULL
                      END
    FROM         xla_ae_headers         h
                ,xla_ae_lines           l
                ,gl_code_combinations   ccid
                ,fnd_currencies fcu
    WHERE       ccid.code_combination_id(+) = l.code_combination_id
      AND       l.ae_header_id              = h.ae_header_id
      AND       l.application_id            = h.application_id
      AND       l.currency_code = fcu.currency_code
      AND       h.ledger_id                 = g_ledger_id
      AND       h.ae_header_id              = g_ae_header_id
      AND       h.application_id            = g_application_id;

  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# lines inserted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of procedure load_lines',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.load_lines');
END load_lines;

--=============================================================================
--
-- Name: validate_doc_sequence
-- Description: This function will perform validation on the document sequence
--              for the journal entry. If any validation failed, the error will
--              be loaded into the xla_accounting_errors table for future referal.
--
--=============================================================================
PROCEDURE validate_doc_sequence
IS
  CURSOR c_manual IS
    SELECT h.ae_header_id
          ,h.entity_id
          ,h.event_id
          ,h.doc_sequence_id
          ,h.doc_category_code
          ,CASE WHEN h.doc_category_code IS NOT NULL AND cat.code IS NULL
                THEN 'N'
                ELSE 'Y'
                END doc_category_code_valid_flag
          ,CASE WHEN h.doc_sequence_id IS NOT NULL AND doc.doc_sequence_id IS NULL
                THEN 'N'
                ELSE 'Y'
                END doc_sequence_id_valid_flag
    FROM   xla_ae_headers h
           LEFT OUTER JOIN fnd_doc_sequence_categories cat
           ON   cat.code                     = h.doc_category_code
           LEFT OUTER JOIN fnd_document_sequences doc
           ON   doc.doc_sequence_id          = h.doc_sequence_id
    WHERE  h.ae_header_id             = g_ae_header_id
    AND    h.application_id           = g_application_id
    AND    ((h.doc_category_code IS NOT NULL AND cat.code IS NULL) OR
            (h.doc_sequence_id IS NOT NULL AND doc.doc_sequence_id IS NULL));

  CURSOR c_standard IS
    SELECT h.ae_header_id
          ,h.entity_id
          ,h.event_id
          ,h.doc_sequence_id
          ,h.doc_category_code
          ,CASE WHEN h.doc_category_code IS NOT NULL AND cat.code IS NULL
                THEN 'N'
                ELSE 'Y'
                END doc_category_code_valid_flag
          ,CASE WHEN h.doc_sequence_id IS NOT NULL AND doc.doc_sequence_id IS NULL
                THEN 'N'
                ELSE 'Y'
                END doc_sequence_id_valid_flag
    FROM   xla_ae_headers_gt h
           LEFT OUTER JOIN fnd_doc_sequence_categories cat
           ON   cat.code                     = h.doc_category_code
           LEFT OUTER JOIN fnd_document_sequences doc
           ON   doc.doc_sequence_id          = h.doc_sequence_id
    WHERE  h.ledger_id = g_ledger_id
      AND  h.accounting_date <= NVL(g_end_date, h.accounting_date)    -- 4262811
      AND  ((h.doc_category_code IS NOT NULL AND cat.code IS NULL) OR
            (h.doc_sequence_id IS NOT NULL AND doc.doc_sequence_id IS NULL));

  l_app_name         VARCHAR2(240);
  l_err              c_standard%ROWTYPE;

  l_log_module                  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_doc_sequence';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_doc_sequence',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_caller = C_CALLER_MANUAL) THEN
    OPEN c_manual;
  ELSE
    OPEN c_standard;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid doc sequence',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  LOOP
    IF (g_caller = C_CALLER_MANUAL) THEN
      FETCH c_manual INTO l_err;
      EXIT WHEN c_manual%NOTFOUND;
    ELSE
      FETCH c_standard INTO l_err;
      EXIT WHEN c_standard%NOTFOUND;
    END IF;

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP invalid headers: ae_header_id = '||l_err.ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    g_err_count := g_err_count + 1;
    g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
    g_err_event_ids(g_err_count) := l_err.event_id;

    IF (l_err.doc_category_code_valid_flag = 'N') THEN

      SELECT    application_name INTO l_app_name
      FROM      fnd_application_vl
      WHERE     application_id = g_application_id;

      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_AP_INVALID_DOC_SEQ_CAT'
        ,p_token_1              => 'CATEGORY_NAME'
        ,p_value_1              => l_err.doc_category_code
        ,p_token_2              => 'APPLICATION_NAME'
        ,p_value_2              => l_app_name
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
    END IF;

    IF (l_err.doc_sequence_id_valid_flag = 'N') THEN

      SELECT    application_name INTO l_app_name
      FROM      fnd_application_vl
      WHERE     application_id = g_application_id;

      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_AP_INVALID_DOC_SEQ_ID'
        ,p_token_1              => 'SEQUENCE_ID'
        ,p_value_1              => l_err.doc_sequence_id
        ,p_token_2              => 'APPLICATION_NAME'
        ,p_value_2              => l_app_name
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
    END IF;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid doc sequence',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (g_caller = C_CALLER_MANUAL) THEN
    CLOSE c_manual;
  ELSE
    CLOSE c_standard;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function validate_doc_sequence',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_manual%ISOPEN) THEN
    CLOSE c_manual;
  END IF;
  IF (c_standard%ISOPEN) THEN
    CLOSE c_standard;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_manual%ISOPEN) THEN
    CLOSE c_manual;
  END IF;
  IF (c_standard%ISOPEN) THEN
    CLOSE c_standard;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_doc_sequence');
END validate_doc_sequence;

--=============================================================================
--
-- Name: validate_encumbrances
-- Description: This function will perform validation on the encumbrance type id
--              for the journal entry. If any validation failed, the error will
--              be loaded into the xla_accounting_errors table for future referal.
--
--=============================================================================
PROCEDURE validate_encumbrances
IS
  CURSOR c_err IS
    SELECT h.ae_header_id
          ,h.ae_line_num       -- 5522973
          ,h.entity_id
          ,h.event_id
          ,h.encumbrance_type_id
          ,e.encumbrance_type  -- 5522973
          ,e.enabled_flag encum_type_enabled_flag
    FROM  xla_validation_lines_gt h
          LEFT OUTER JOIN gl_encumbrance_types e
          ON   e.encumbrance_type_id        = h.encumbrance_type_id
    WHERE h.ledger_id             = g_ledger_id
    AND   h.balance_type_code     = 'E'
--  AND   h.encumbrance_type_id   IS NOT NULL  -- 5522973 removed
    AND   nvl(e.enabled_flag,'N') = 'N';

  l_log_module       VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_encumbrances';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_encumbrances',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid encumbrances',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_err IN c_err LOOP
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP invalid encumbrances: ae_header_id = '||l_err.ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
      trace(p_msg    => 'ae_line = '||l_err.ae_line_num||  -- 5522973
                        ' enc_id = '||l_err.encumbrance_type_id||
                        ' enc_enabled = '||l_err.encum_type_enabled_flag,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    g_err_count := g_err_count + 1;
    g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
    g_err_event_ids(g_err_count) := l_err.event_id;

    IF (l_err.encum_type_enabled_flag IS NULL) THEN
       IF l_err.encumbrance_type_id IS NULL THEN  -- 5522973
          xla_accounting_err_pkg.build_message(
             p_appli_s_name           => 'XLA'
            ,p_msg_name               => 'XLA_AP_NO_ENCUM_TYPE'
            ,p_entity_id              => l_err.entity_id
            ,p_event_id               => l_err.event_id
            ,p_ledger_id              => g_ledger_id
            ,p_ae_header_id           => l_err.ae_header_id
            ,p_ae_line_num            => l_err.ae_line_num
            ,p_accounting_batch_id    => NULL);
       ELSE
          xla_accounting_err_pkg.build_message(
             p_appli_s_name         => 'XLA'
            ,p_msg_name             => 'XLA_AP_INVALID_ENCU_TYPE'
            ,p_token_1              => 'ENCUMBRANCE_TYPE_ID'
            ,p_value_1              => l_err.encumbrance_type_id
            ,p_entity_id            => l_err.entity_id
            ,p_event_id             => l_err.event_id
            ,p_ledger_id            => g_ledger_id
            ,p_ae_header_id         => l_err.ae_header_id
            ,p_ae_line_num          => l_err.ae_line_num  -- 5522973
            ,p_accounting_batch_id  => NULL);
       END IF;
    ELSIF l_err.encum_type_enabled_flag <> 'Y'  THEN
      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_AP_INACTIVE_ENCUM_TYPE'
        ,p_token_1              => 'ENCUMBRANCE_TYPE_ID'
        ,p_value_1              => l_err.encumbrance_type  -- 5520736 instead of l_err.encumbrance_type_id
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => l_err.ae_line_num  -- 5522973
        ,p_accounting_batch_id  => NULL);
    END IF;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid encumbrances',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function validate_encumbrances',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_err%ISOPEN) THEN
    CLOSE c_err;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_err%ISOPEN) THEN
    CLOSE c_err;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_encumbrances');
END validate_encumbrances;

--=============================================================================
--
-- Name: validate_budgets
-- Description: This function will perform validation on the budget version id
--              and the budget period for the journal entry. If any validation
--              failed, the error will be loaded into the xla_accounting_errors
--              table for future referal.
--
--=============================================================================
PROCEDURE validate_budgets
IS
  CURSOR c_manual IS
    SELECT h.ae_header_id
          ,h.entity_id
          ,h.event_id
          ,h.budget_version_id
          ,h.accounting_date
          ,bv.budget_name                                                                           -- 5592776
          ,bv.status budget_version_status
          ,CASE WHEN h.balance_type_code = 'B' AND
                     gp.period_year > b.latest_opened_year
                THEN 'N'
                ELSE 'Y' END budget_period_valid_flag
    FROM  xla_ae_headers h
          JOIN gl_period_statuses gp
          ON   gp.period_name               = h.period_name
          AND  gp.ledger_id                 = g_ledger_id
          AND  gp.application_id            = C_GL_APPLICATION_ID
          LEFT OUTER JOIN gl_budget_versions bv
          ON   bv.budget_version_id     = h.budget_version_id
          LEFT OUTER JOIN gl_budgets b
          ON   b.budget_name             = bv.budget_name
          AND  b.budget_type             = bv.budget_type
    WHERE h.ae_header_id        = g_ae_header_id
      AND h.application_id      = g_application_id
      AND h.balance_type_code   = 'B'
      AND h.budget_version_id   IS NOT NULL
      AND (bv.status IS NULL OR
           nvl(bv.status,'I') in ('I', 'F') OR
           gp.period_year > b.latest_opened_year);

  CURSOR c_standard IS
    SELECT h.ae_header_id
          ,h.entity_id
          ,h.event_id
          ,h.budget_version_id
          ,h.accounting_date
          ,bv.budget_name                                                                           -- 5592776
          ,decode(nvl(b.ledger_id,h.ledger_id), h.ledger_id, bv.status , 'X') budget_version_status -- 5592776
          ,CASE WHEN h.balance_type_code = 'B' AND
                     h.period_year > b.latest_opened_year
                THEN 'N'
                ELSE 'Y' END budget_period_valid_flag
    FROM  xla_ae_headers_gt h
          LEFT OUTER JOIN gl_budget_versions bv
          ON   bv.budget_version_id     = h.budget_version_id
          LEFT OUTER JOIN gl_budgets b
          ON   b.budget_name             = bv.budget_name
          AND  b.budget_type             = bv.budget_type
    WHERE h.ledger_id           = g_ledger_id
      AND h.balance_type_code   = 'B'
      AND h.budget_version_id   IS NOT NULL
      AND (bv.status IS NULL OR
           nvl(bv.status,'I') in ('I', 'F') OR
           b.ledger_id <> h.ledger_id OR                                                            -- 5592776
           h.period_year > b.latest_opened_year);

  l_budget_name      VARCHAR2(30);
  l_err              c_standard%ROWTYPE;
  l_log_module       VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_budgets';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_budgets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_caller = C_CALLER_MANUAL) THEN
    OPEN c_manual;
  ELSE
    OPEN c_standard;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid budgets',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  LOOP
    IF (g_caller = C_CALLER_MANUAL) THEN
      FETCH c_manual INTO l_err;
      EXIT WHEN c_manual%NOTFOUND;
    ELSE
      FETCH c_standard INTO l_err;
      EXIT WHEN c_standard%NOTFOUND;
    END IF;

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP invalid budgets: ae_header_id = '||l_err.ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    g_err_count := g_err_count + 1;
    g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
    g_err_event_ids(g_err_count) := l_err.event_id;

    IF (l_err.budget_version_status IS NULL) THEN
        xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_AP_INVALID_BUD_VER'
        ,p_token_1              => 'BUDGET_VERSION_ID'
        ,p_value_1              => l_err.budget_version_id
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);

    ELSIF l_err.budget_version_status in ('X') THEN  -- 5592776
        xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_AP_INVALID_BUDGET_LEDGER'
        ,p_token_1              => 'BUDGET_NAME'
        ,p_value_1              => l_err.budget_name
        ,p_token_2              => 'LEDGER_NAME'
        ,p_value_2              => g_ledger_name
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);

    ELSIF l_err.budget_version_status in ('I', 'F') THEN
        xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_AP_INACTIVE_BUDGET_VER'
        ,p_token_1              => 'BUDGET_VERSION_ID'
        ,p_value_1              => l_err.budget_version_id
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);

    ELSIF (l_err.budget_period_valid_flag = 'N') THEN
      SELECT    budget_name
      INTO      l_budget_name
      FROM      gl_budget_versions
      WHERE     budget_version_id = l_err.budget_version_id;

      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_AP_INVALID_BUDGET_DATE'
        ,p_token_1              => 'BUDGET_NAME'
        ,p_value_1              => l_budget_name
        ,p_token_2              => 'GL_DATE'
        ,p_value_2              => l_err.accounting_date
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
    END IF;

  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid budgets',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (g_caller = C_CALLER_MANUAL) THEN
    CLOSE c_manual;
  ELSE
    CLOSE c_standard;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function validate_budgets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_manual%ISOPEN) THEN
    CLOSE c_manual;
  END IF;
  IF (c_standard%ISOPEN) THEN
    CLOSE c_standard;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_manual%ISOPEN) THEN
    CLOSE c_manual;
  END IF;
  IF (c_standard%ISOPEN) THEN
    CLOSE c_standard;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_budgets');
END validate_budgets;


--=============================================================================
--
-- Name: validate_business_date
-- Description: This procedure will validate the business date
--
--=============================================================================
PROCEDURE validate_business_date
IS
  CURSOR c_eff_date_rule IS
    SELECT effective_date_rule_code
      FROM gl_je_sources  gjs
         , xla_subledgers xs
     WHERE gjs.je_source_name = xs.je_source_name
       AND xs.application_id  = g_application_id;

  CURSOR c_invalid_business_date IS
    SELECT xah.ae_header_id
          ,xah.event_id
          ,xah.entity_id
          ,xah.accounting_date
      FROM xla_ae_headers         xah
         , gl_transaction_dates   gtd
     WHERE xah.accounting_date         = gtd.transaction_date
       AND gtd.transaction_calendar_id = g_transaction_calendar_id
       AND gtd.business_day_flag          = 'N';

  l_eff_date_rule_code          VARCHAR2(1);
  l_log_module                  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_business_date';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_business_date'||
                      ': enable_average_balances_flag = '||g_enable_average_balances_flag||
                      ', transaction_calendar_id = '||g_transaction_calendar_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_enable_average_balances_flag = 'Y' AND
      g_transaction_calendar_id     IS NOT NULL) THEN

    OPEN c_eff_date_rule;
    FETCH c_eff_date_rule INTO l_eff_date_rule_code;
    CLOSE c_eff_date_rule;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'effective_date_rule_code = '||l_eff_date_rule_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF (l_eff_date_rule_code = 'F') THEN

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => 'BEGIN LOOP - invalid business date',
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;

      FOR l_err IN c_invalid_business_date LOOP

        IF (C_LEVEL_ERROR >= g_log_level) THEN
          trace(p_msg    => 'LOOP - invalid business date: ae_header_id = '|| l_err.ae_header_id||
                           ', accounting_date = '|| l_err.accounting_date,
                p_module => l_log_module,
                p_level  => C_LEVEL_ERROR);
        END IF;

        g_err_count := g_err_count+1;
        g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
        g_err_event_ids(g_err_count) := l_err.event_id;

        xla_accounting_err_pkg.build_message(
                    p_appli_s_name              => 'XLA'
                    ,p_msg_name         => 'XLA_AP_INVALID_TRX_DATE'
                    ,p_entity_id                => l_err.entity_id
                    ,p_event_id         => l_err.event_id
                    ,p_ledger_id                => g_ledger_id
                    ,p_ae_header_id             => l_err.ae_header_id
                    ,p_ae_line_num              => NULL
                    ,p_accounting_batch_id      => NULL);
      END LOOP;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => 'END LOOP - invalid business date',
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;

    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function validate_business_date',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_eff_date_rule%ISOPEN) THEN
    CLOSE c_eff_date_rule;
  END IF;
  IF (c_invalid_business_date%ISOPEN) THEN
    CLOSE c_invalid_business_date;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_eff_date_rule%ISOPEN) THEN
    CLOSE c_eff_date_rule;
  END IF;
  IF (c_invalid_business_date%ISOPEN) THEN
    CLOSE c_invalid_business_date;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_business_date');
END validate_business_date;



--=============================================================================
--
-- Name: validate_headers
-- Description: This function will perform validation for the journal entry.
--              If any validation failed, the error will be loaded into the
--              xla_accounting_errors table for future referal.
--
--=============================================================================
PROCEDURE validate_headers
IS
  CURSOR c_manual IS
      SELECT h.ae_header_id
            ,h.entity_id
            ,h.event_id
            ,h.accounting_date
            ,h.reference_date
            ,h.balance_type_code
            ,h.budget_version_id
            ,CASE WHEN h.balance_type_code = 'E' AND
                           gp.period_year > g.latest_encumbrance_year
                  THEN 'N'
                  ELSE 'Y' END encum_period_valid_flag
            ,CASE WHEN h.balance_type_code = 'A' AND
                           gp.closing_status not in ('O', 'F')
                  THEN 'N'
                  ELSE 'Y' END gl_date_valid_flag
            ,CASE WHEN h.reference_date IS NULL THEN 'Y'
                  WHEN nvl(rp.closing_status,'C') in ('O', 'F') THEN 'Y'
                  ELSE 'N' END reference_date_valid_flag
            ,NULL                            header_num            -- 4262811
            ,NULL                            period_closing_status -- 4262811
            ,h.period_name                   period_name           -- 5136994
	    ,h.gl_transfer_status_code
      FROM   xla_ae_headers     h
             JOIN gl_ledgers g
             ON   g.ledger_id                  = h.ledger_id
             JOIN gl_period_statuses gp
             ON   gp.period_name               = h.period_name
             AND  gp.ledger_id                 = h.ledger_id
             AND  gp.application_id            = C_GL_APPLICATION_ID
             LEFT OUTER JOIN gl_period_statuses rp
             ON   rp.adjustment_period_flag    = 'N'
             AND  h.reference_date BETWEEN rp.start_date AND rp.end_date
             AND  rp.ledger_id                 = h.ledger_id
             AND  rp.application_id            = C_GL_APPLICATION_ID
      WHERE  h.ae_header_id        = g_ae_header_id
      AND    h.application_id      = g_application_id
      AND    ((h.balance_type_code = 'B' AND h.budget_version_id IS NULL) OR
              (h.balance_type_code <> 'B' AND h.budget_version_id IS NOT NULL) OR
              (h.balance_type_code NOT IN ('A', 'B', 'E')) OR
              (h.balance_type_code = 'E' AND gp.period_year > g.latest_encumbrance_year) OR
              (h.balance_type_code = 'A' AND gp.closing_status NOT IN ('O', 'F')) OR
              (h.reference_date IS NOT NULL AND nvl(rp.closing_status,'C') NOT IN ('O', 'F')));

  CURSOR c_standard IS
      SELECT     /*+ index(gp, GL_PERIOD_STATUSES_U3) */
                 h.ae_header_id
                ,h.entity_id
                ,h.event_id
                ,h.accounting_date
                ,NULL reference_date
                ,h.balance_type_code
                ,h.budget_version_id
                ,CASE WHEN h.balance_type_code = 'E' AND
                         --h.period_year > g_latest_encumbrance_year                                   -- 5136994
                           NVL(h.period_year,g_latest_encumbrance_year+1) > g_latest_encumbrance_year  -- 5136994
                      THEN 'N'
                      ELSE 'Y' END encum_period_valid_flag
                ,CASE WHEN h.balance_type_code = 'A' AND
                         --h.period_closing_status not in ('O', 'F')
                           NVL(h.period_closing_status,'X') not in ('O', 'F') -- 5136994
                      THEN 'N'
                      ELSE 'Y' END gl_date_valid_flag
                ,'Y' reference_date_valid_flag
                ,NVL(h.header_num,0)             header_num            -- 4262811
                ,h.period_closing_status         period_closing_status -- 4262811
                ,h.period_name                   period_name           -- 5136994
		,h.gl_transfer_status_code
      FROM       xla_ae_headers_gt h
      WHERE      h.ledger_id = g_ledger_id
        AND     (h.accounting_date <= g_end_date OR h.period_closing_status IN ('P','C')    -- 4262811
                   OR h.period_name IS NULL)  -- 5136994
        AND      ((h.balance_type_code =  'B' AND h.budget_version_id IS NULL) OR
                  (h.balance_type_code <> 'B' AND h.budget_version_id IS NOT NULL) OR
                  (h.balance_type_code NOT IN ('A', 'B', 'E')) OR
                -- 5136994
                  (h.balance_type_code =  'E' AND NVL(h.period_year,g_latest_encumbrance_year+1) > g_latest_encumbrance_year) OR
                  (h.balance_type_code =  'A' AND NVL(h.period_closing_status,'X') NOT IN ('O', 'F')));
                --(h.balance_type_code =  'E' AND h.period_year > g_latest_encumbrance_year) OR
                --(h.balance_type_code =  'A' AND h.period_closing_status NOT IN ('O', 'F')));

  l_err                c_standard%ROWTYPE;
  l_log_module         VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_headers';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_headers',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_caller = C_CALLER_MANUAL) THEN
    OPEN c_manual;
  ELSE
    OPEN c_standard;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid header',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;


LOOP
    IF (g_caller = C_CALLER_MANUAL) THEN
      FETCH c_manual INTO l_err;
      EXIT WHEN c_manual%NOTFOUND;
    ELSE
      FETCH c_standard INTO l_err;
      EXIT WHEN c_standard%NOTFOUND;
    END IF;


IF (l_err.balance_type_code = 'A' AND l_err.gl_date_valid_flag = 'N' AND l_err.gl_transfer_status_code = 'NT') THEN
    IF (l_err.reference_date_valid_flag = 'N') THEN
      -- 4262811-----------------------------
      IF g_caller = C_CALLER_MPA_PROGRAM THEN
         g_message_name := 'XLA_MA_INVALID_REF_DATE';
      ELSE
         g_message_name := 'XLA_AP_INVALID_REF_DATE';
      END IF;
      ---------------------------------------
      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => g_message_name      -- 4262811 'XLA_AP_INVALID_REF_DATE'
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);

	g_err_count := g_err_count + 1;
	g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
	g_err_event_ids(g_err_count) := l_err.event_id;
    END IF;

ELSE

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP invalid headers: ae_header_id = '||l_err.ae_header_id||
                        ' status='||l_err.period_closing_status||
                        ' period_name='||l_err.period_name||
                        ' gl_date_valid='||l_err.gl_date_valid_flag||
                        ' encum_period_valid='||l_err.encum_period_valid_flag||
                        ' g_latest_encumbrance_year='||g_latest_encumbrance_year
           ,p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    g_err_count := g_err_count + 1;
    g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
    g_err_event_ids(g_err_count) := l_err.event_id;

    IF (l_err.balance_type_code NOT IN ('A', 'B', 'E')) THEN
      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_AP_INVALID_BAL_TYPE'
        ,p_token_1              => 'BALANCE_TYPE'
        ,p_value_1              => l_err.balance_type_code
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
    ELSE
      IF l_err.balance_type_code = 'B' THEN
        IF l_err.budget_version_id IS NULL THEN
          xla_accounting_err_pkg.build_message(
               p_appli_s_name           => 'XLA'
              ,p_msg_name               => 'XLA_AP_NO_BUDGET_VER'
              ,p_entity_id              => l_err.entity_id
              ,p_event_id               => l_err.event_id
              ,p_ledger_id              => g_ledger_id
              ,p_ae_header_id           => l_err.ae_header_id
              ,p_ae_line_num            => NULL
              ,p_accounting_batch_id    => NULL);
        END IF;
      ELSIF l_err.budget_version_id IS NOT NULL THEN
        xla_accounting_err_pkg.build_message(
               p_appli_s_name           => 'XLA'
              ,p_msg_name               => 'XLA_AP_BUD_VER_REJECT'
              ,p_entity_id              => l_err.entity_id
              ,p_event_id               => l_err.event_id
              ,p_ledger_id              => g_ledger_id
              ,p_ae_header_id           => l_err.ae_header_id
              ,p_ae_line_num            => NULL
              ,p_accounting_batch_id    => NULL);
      END IF;

      IF l_err.balance_type_code = 'E' THEN
        IF (l_err.encum_period_valid_flag = 'N') THEN
          xla_accounting_err_pkg.build_message(
               p_appli_s_name           => 'XLA'
              ,p_msg_name               => 'XLA_AP_INVALID_ENCUM_DATE'
              ,p_token_1                => 'GL_DATE'
              ,p_value_1                => l_err.accounting_date
              ,p_entity_id              => l_err.entity_id
              ,p_event_id               => l_err.event_id
              ,p_ledger_id              => g_ledger_id
              ,p_ae_header_id           => l_err.ae_header_id
              ,p_ae_line_num            => NULL
              ,p_accounting_batch_id    => NULL);
        END IF;
      END IF;

      IF l_err.balance_type_code = 'A' THEN
        IF (NVL(l_err.header_num,0) > 0) THEN                            -- 4262811
          xla_accounting_err_pkg.build_message(
               p_appli_s_name         => 'XLA'
              ,p_msg_name             => 'XLA_MA_NO_OPEN_PERIOD'
              ,p_token_1              => 'LEDGER'
              ,p_value_1              => g_ledger_name
              ,p_entity_id            => l_err.entity_id
              ,p_event_id             => l_err.event_id
              ,p_ledger_id            => g_ledger_id
              ,p_ae_header_id         => l_err.ae_header_id
              ,p_ae_line_num          => NULL
              ,p_accounting_batch_id  => NULL);
        ELSIF (l_err.gl_date_valid_flag = 'N' AND l_err.gl_transfer_status_code <> 'NT') THEN
          xla_accounting_err_pkg.build_message(
               p_appli_s_name         => 'XLA'
              ,p_msg_name             => 'XLA_AP_INVALID_GL_DATE'
              ,p_token_1              => 'GL_DATE'
              ,p_value_1              => to_char(l_err.accounting_date,'DD-MON-YYYY')
              ,p_entity_id            => l_err.entity_id
              ,p_event_id             => l_err.event_id
              ,p_ledger_id            => g_ledger_id
              ,p_ae_header_id         => l_err.ae_header_id
              ,p_ae_line_num          => NULL
              ,p_accounting_batch_id  => NULL);

        END IF;
      END IF;
    END IF;

    IF (l_err.reference_date_valid_flag = 'N') THEN
      -- 4262811-----------------------------
      IF g_caller = C_CALLER_MPA_PROGRAM THEN
         g_message_name := 'XLA_MA_INVALID_REF_DATE';
      ELSE
         g_message_name := 'XLA_AP_INVALID_REF_DATE';
      END IF;
      ---------------------------------------
      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => g_message_name      -- 4262811 'XLA_AP_INVALID_REF_DATE'
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
    END IF;

END IF;
END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid headers',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (g_caller = C_CALLER_MANUAL) THEN
    CLOSE c_manual;
  ELSE
    CLOSE c_standard;
  END IF;

  IF g_caller <> C_CALLER_MPA_PROGRAM THEN    -- 4262811
     --validate_encumbrances; -- 4458381
     validate_budgets;
  END IF;
  validate_doc_sequence;
  validate_business_date;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function validate_headers',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_manual%ISOPEN) THEN
    CLOSE c_manual;
  END IF;
  IF (c_standard%ISOPEN) THEN
    CLOSE c_standard;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_manual%ISOPEN) THEN
    CLOSE c_manual;
  END IF;
  IF (c_standard%ISOPEN) THEN
    CLOSE c_standard;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_headers');
END validate_headers;

--=============================================================================
--
-- Name: validate_bal_segments
-- Description: This procedure will validate the balancing segments for the
--              LBM security.
--
--=============================================================================
PROCEDURE validate_bal_segments
(p_seg_ledger_id INTEGER)
IS
  CURSOR c_invalid_bal_segment IS
    SELECT t.*
      FROM xla_validation_lines_gt t
           LEFT OUTER JOIN gl_ledger_segment_values s
           ON  s.segment_value     = t.bal_seg_value
           AND s.segment_type_code = C_BAL_SEGMENT
           AND s.ledger_id         = p_seg_ledger_id
           AND t.accounting_date   BETWEEN NVL(s.start_date, t.accounting_date)
                                   AND NVL(s.end_date, t.accounting_date)
     WHERE t.ccid_enabled_flag IS NOT NULL
       AND s.ledger_id IS NULL
       AND t.code_combination_id <> -1;

  l_account             VARCHAR2(2000) := NULL;
  l_log_module          VARCHAR2(240);

  l_segment_name VARCHAR2(30);   --  4262811c

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_bal_segments';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_bal_segments',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid balancing segment',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_err IN c_invalid_bal_segment LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - invalid balancing segment: ae_header_id = '|| l_err.ae_header_id||
                       ', ae_line_num = '|| l_err.ae_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    g_err_count := g_err_count+1;
    g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
    g_err_event_ids(g_err_count) := l_err.event_id;

    -- Check if the balancing segment value is valid for the ledger
    SELECT fnd_flex_ext.get_segs('SQLGL', 'GL#', l_err.ccid_coa_id, l_err.code_combination_id)
    INTO   l_account
    FROM   dual;

    -- 4262811---------------------------------------------------------------------------------
    IF g_caller = C_CALLER_MPA_PROGRAM THEN
       g_message_name := 'XLA_MA_INVALID_BAL_SEG';
    ELSE
       g_message_name := 'XLA_AP_INVALD_BAL_SEG';
    END IF;
    l_segment_name := xla_flex_pkg.get_flexfield_segment_name       -- 4262811c
                                          (p_application_id         => 101
                                          ,p_flex_code              => 'GL#'
                                          ,p_chart_of_accounts_id   => l_err.ccid_coa_id
                                          ,p_flexfield_segment_code => g_bal_seg_column_name);
    -------------------------------------------------------------------------------------------

    xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => g_message_name   -- 4262811 'XLA_AP_INVALD_BAL_SEG'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_token_3              => 'LEDGER_NAME'
                ,p_value_3              => g_ledger_name
                ,p_token_4              => 'SEGMENT_NAME'     -- 4262811c
                ,p_value_4              => l_segment_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid balancing segment',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function validate_bal_segments',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_invalid_bal_segment%ISOPEN) THEN
    CLOSE c_invalid_bal_segment;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_invalid_bal_segment%ISOPEN) THEN
    CLOSE c_invalid_bal_segment;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_bal_segments');
END;

--=============================================================================
--
-- Name: validate_mgt_segments
-- Description: This procedure will validate the management segments for the
--              LBM security.
--
--=============================================================================
PROCEDURE validate_mgt_segments
(p_seg_ledger_id INTEGER)
IS
  CURSOR c_invalid_mgt_segment IS
    SELECT t.*
      FROM xla_validation_lines_gt t
           LEFT OUTER JOIN gl_ledger_segment_values s
           ON  s.segment_value     = t.mgt_seg_value
           AND s.segment_type_code = C_MGT_SEGMENT
           AND s.ledger_id         = p_seg_ledger_id
           AND t.accounting_date   BETWEEN NVL(s.start_date, t.accounting_date)
                                   AND NVL(s.end_date, t.accounting_date)
     WHERE t.ccid_enabled_flag IS NOT NULL
       AND s.ledger_id IS NULL;

  CURSOR c_coa_structure_name (p_coa_id INTEGER) IS
    SELECT  id_flex_structure_name
    FROM    fnd_id_flex_structures_vl
    WHERE   application_id = 101
    AND     id_flex_num = p_coa_id;

  l_account                VARCHAR2(2000) := NULL;
  l_coa_structure_name     VARCHAR2(80);
  l_log_module             VARCHAR2(240);
  l_segment_name VARCHAR2(30);   --  4262811c
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_mgt_segments';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_mgt_segments',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid management segment',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_err IN c_invalid_mgt_segment LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - invalid management segment: ae_header_id = '|| l_err.ae_header_id||
                       ', ae_line_num = '|| l_err.ae_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    g_err_count := g_err_count+1;
    g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
    g_err_event_ids(g_err_count) := l_err.event_id;

    -- Check if the management segment value is valid for the ledger
    SELECT fnd_flex_ext.get_segs('SQLGL', 'GL#', l_err.ccid_coa_id, l_err.code_combination_id)
    INTO   l_account
    FROM   dual;

    OPEN c_coa_structure_name(l_err.ccid_coa_id);
    FETCH c_coa_structure_name INTO l_coa_structure_name;
    CLOSE c_coa_structure_name;

    -- 4262811---------------------------------------------------------------------------------
    IF g_caller = C_CALLER_MPA_PROGRAM THEN
       g_message_name := 'XLA_MA_INVALID_MGT_SEG';
    ELSE
       g_message_name := 'XLA_AP_INVALD_MGT_SEG';
    END IF;
    l_segment_name := xla_flex_pkg.get_flexfield_segment_name       -- 4262811c
                                          (p_application_id         => 101
                                          ,p_flex_code              => 'GL#'
                                          ,p_chart_of_accounts_id   => l_err.ccid_coa_id
                                          ,p_flexfield_segment_code => g_mgt_seg_column_name);
    -------------------------------------------------------------------------------------------

    xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => g_message_name     -- 4262811 'XLA_AP_INVALD_MGT_SEG'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_token_3              => 'LEDGER_NAME'
                ,p_value_3              => g_ledger_name
                ,p_token_4              => 'STRUCTURE_NAME'
                ,p_value_4              => l_coa_structure_name
                ,p_token_5              => 'SEGMENT_NAME'     -- 4262811c
                ,p_value_5              => l_segment_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid management segment',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function validate_mgt_segments',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_coa_structure_name%ISOPEN) THEN
    CLOSE c_coa_structure_name;
  END IF;
  IF (c_invalid_mgt_segment%ISOPEN) THEN
    CLOSE c_invalid_mgt_segment;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_coa_structure_name%ISOPEN) THEN
    CLOSE c_coa_structure_name;
  END IF;
  IF (c_invalid_mgt_segment%ISOPEN) THEN
    CLOSE c_invalid_mgt_segment;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_mgt_segments');
END;

--=============================================================================
--
-- Name: validate_third_parties
-- Description: This procedure will validate the third party information.
--
--=============================================================================
PROCEDURE validate_third_parties
IS
  CURSOR c_invalid_party IS
    SELECT t.ae_header_id, t.ae_line_num, t.event_id, t.displayed_line_number,
           t.entity_id,
           t.party_type_code, t.party_id, t.party_site_id,
           c.cust_account_id customer_id, ps.site_use_id customer_site_id,
           s.vendor_id, ss.vendor_site_id
      FROM xla_validation_lines_gt t
           LEFT OUTER JOIN hz_cust_accounts_all c
           ON   c.cust_account_id       = t.party_id
           LEFT OUTER JOIN hz_cust_site_uses_all ps
           ON   ps.site_use_id          = t.party_site_id
           LEFT OUTER JOIN ap_supplier_sites_all ss
           ON   ss.vendor_site_id   = t.party_site_id
           LEFT OUTER JOIN ap_suppliers s
           ON   s.vendor_id             = t.party_id
      WHERE  (t.party_type_code IS NULL
        AND ((c.cust_account_id IS NOT NULL )OR (t.party_site_id IS NOT NULL AND ps.site_use_id IS NULL ))
	     )
        OR  (t.party_type_code = 'S'
       AND ((s.vendor_id IS NULL) OR
            (t.party_site_id IS NOT NULL AND ss.vendor_site_id IS NULL)))  ;


  l_party_mesg_name       VARCHAR2(30);
  l_party_site_mesg_name  VARCHAR2(30);

  l_log_module            VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_third_parties';
  END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_third_parties',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;



  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid party',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_inv_party IN c_invalid_party LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - invalid party: ae_header_id = '|| l_inv_party.ae_header_id||
                       ', ae_line_num = '|| l_inv_party.ae_line_num||
                       ', party_type_code = ' ||l_inv_party.party_type_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    g_err_count := g_err_count+1;
    g_err_hdr_ids(g_err_count) := l_inv_party.ae_header_id;
    g_err_event_ids(g_err_count) := l_inv_party.event_id;

    --
    -- Message names are shared across party related errors.
    -- Store message names in local variables for the first offending row.
    --
    IF c_invalid_party%ROWCOUNT = 1 THEN

       --
       -- Set message names
       --
       IF g_caller = C_CALLER_ACCT_PROGRAM THEN

          l_party_mesg_name      := 'XLA_AP_INVALID_PARTY_ID';
          l_party_site_mesg_name := 'XLA_AP_INVALID_PARTY_SITE';

       ELSE

          IF g_caller = C_CALLER_MPA_PROGRAM THEN

             l_party_mesg_name      := 'XLA_MA_INVALID_PARTY_ID';
             l_party_site_mesg_name := 'XLA_MA_INVALID_PARTY_SITE';

          ELSE

             l_party_mesg_name      := 'XLA_MJE_INVALID_PARTY_ID';
             l_party_site_mesg_name := 'XLA_MJE_INVALID_PARTY_SITE';

          END IF;

       END IF;

    END IF;

    --  If party type code is populated, party id must be valid and populated
    IF (l_inv_party.customer_id IS NULL) OR
       (l_inv_party.vendor_id IS NULL)
    THEN

       xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => l_party_mesg_name
                ,p_token_1              => 'PARTY_ID'
                ,p_value_1              => l_inv_party.party_id
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_inv_party.ae_line_num
                ,p_entity_id            => l_inv_party.entity_id
                ,p_event_id             => l_inv_party.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_inv_party.ae_header_id
                ,p_ae_line_num          => l_inv_party.ae_line_num
                ,p_accounting_batch_id  => NULL);

    END IF;

    --  If party site id is populated, it must be valid
    IF (l_inv_party.party_site_id IS NOT NULL) AND
       (l_inv_party.customer_site_id IS NULL   OR
        l_inv_party.vendor_site_id IS NULL)
    THEN

        xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => l_party_site_mesg_name
                ,p_token_1              => 'PARTY_SITE'
                ,p_value_1              => l_inv_party.party_site_id
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_inv_party.ae_line_num
                ,p_entity_id            => l_inv_party.entity_id
                ,p_event_id             => l_inv_party.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_inv_party.ae_header_id
                ,p_ae_line_num          => l_inv_party.ae_line_num
                ,p_accounting_batch_id  => NULL);

    END IF;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
       trace(p_msg    => 'END Validation - invalid party',
             p_module => l_log_module,
             p_level  => C_LEVEL_EVENT);
    END IF;

  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid party',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_third_parties',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_invalid_party%ISOPEN) THEN
    CLOSE c_invalid_party;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_invalid_party%ISOPEN) THEN
    CLOSE c_invalid_party;
  END IF;

  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_third_parties');
END validate_third_parties;

--=============================================================================
--
-- Name: validate_currencies
-- Description: This procedure will validate the currency and conversion information.
--
--=============================================================================
PROCEDURE validate_currencies
IS
  CURSOR c_invalid_curr IS
    SELECT t.ae_header_id
          ,t.ae_line_num
          ,t.event_id
          ,t.displayed_line_number
          ,t.entity_id
          ,t.accounting_date
          ,t.entered_currency_code
          ,curr.enabled_flag           curr_enabled_flag
          ,curr.start_date_active      curr_start_date_active
          ,curr.end_date_active        curr_end_date_active
    FROM   xla_validation_lines_gt t
           LEFT OUTER JOIN fnd_currencies curr
           ON   curr.currency_code          = t.entered_currency_code
    WHERE  (curr.enabled_flag IS NULL) OR
           (curr.enabled_flag = 'N') OR
           (t.accounting_date < nvl(curr.start_date_active,t.accounting_date)) OR
           (t.accounting_date > nvl(curr.end_date_active,t.accounting_date));

  l_log_module      VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_currencies';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_currencies',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid currency',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_inv_curr IN c_invalid_curr LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - invalid line: ae_header_id = '|| l_inv_curr.ae_header_id||
                       ', ae_line_num = '|| l_inv_curr.ae_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    g_err_count := g_err_count+1;
    g_err_hdr_ids(g_err_count) := l_inv_curr.ae_header_id;
    g_err_event_ids(g_err_count) := l_inv_curr.event_id;

    IF (l_inv_curr.curr_enabled_flag IS NULL) THEN
      -- 4262811-----------------------------
      IF g_caller = C_CALLER_MPA_PROGRAM THEN
         g_message_name := 'XLA_MA_INVALID_CURR_CODE';
      ELSE
         g_message_name := 'XLA_AP_INVALID_CURR_CODE';
      END IF;
      ---------------------------------------
      xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => g_message_name   -- 4262811 'XLA_AP_INVALID_CURR_CODE'
                ,p_token_1              => 'CURR_CODE'
                ,p_value_1              => l_inv_curr.entered_currency_code
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_inv_curr.ae_line_num
                ,p_entity_id            => l_inv_curr.entity_id
                ,p_event_id             => l_inv_curr.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_inv_curr.ae_header_id
                ,p_ae_line_num          => l_inv_curr.ae_line_num
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_inv_curr.curr_enabled_flag = C_INVALID) THEN
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_AP_INACTIVE_CURR_CODE'
                ,p_token_1              => 'CURRENCY_NAME'
                ,p_value_1              => l_inv_curr.entered_currency_code
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_inv_curr.ae_line_num
                ,p_entity_id            => l_inv_curr.entity_id
                ,p_event_id             => l_inv_curr.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_inv_curr.ae_header_id
                ,p_ae_line_num          => l_inv_curr.ae_line_num
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_inv_curr.accounting_date < l_inv_curr.curr_start_date_active OR
           l_inv_curr.accounting_date > l_inv_curr.curr_end_date_active) THEN
      -- 4262811-----------------------------
      IF g_caller = C_CALLER_MPA_PROGRAM THEN
         g_message_name := 'XLA_MA_CURRENCY_INVALID_DATE';
      ELSE
         g_message_name := 'XLA_AP_CURRENCY_INVALID_DATE';
      END IF;
      ---------------------------------------
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => g_message_name   -- 4262811 'XLA_AP_CURRENCY_INVALID_DATE'
                ,p_token_1              => 'GL_DATE'
                ,p_value_1              => l_inv_curr.accounting_date
                ,p_token_2              => 'CURRENCY_CODE'
                ,p_value_2              => l_inv_curr.entered_currency_code
                ,p_token_3              => 'LINE_NUM'
                ,p_value_3              => l_inv_curr.ae_line_num
                ,p_entity_id            => l_inv_curr.entity_id
                ,p_event_id             => l_inv_curr.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_inv_curr.ae_header_id
                ,p_ae_line_num          => l_inv_curr.ae_line_num
                ,p_accounting_batch_id  => NULL);
    END IF;

  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid currency',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function validate_currencies',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_invalid_curr%ISOPEN) THEN
    CLOSE c_invalid_curr;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_invalid_curr%ISOPEN) THEN
    CLOSE c_invalid_curr;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_currencies');
END validate_currencies;


--=============================================================================
--
-- Name: validate_budget_ccids
-- Description: This procedure will validate the ccid for the budget entry.
--
--=============================================================================
PROCEDURE validate_budget_ccids
IS
  CURSOR c_invalid_budget_ccids IS
    SELECT t.ae_header_id
          ,t.ae_line_num
          ,t.event_id
          ,t.displayed_line_number
          ,t.entity_id
          ,bud.budget_name
          ,fnd_flex_ext.get_segs('SQLGL', 'GL#', t.ccid_coa_id, t.code_combination_id) account
      FROM xla_validation_lines_gt t
           JOIN gl_budget_versions bud
           ON  bud.budget_version_id           = t.budget_version_id
           LEFT OUTER JOIN gl_budget_assignments b
           ON  b.currency_code                 = t.entered_currency_code
           AND b.code_combination_id           = t.code_combination_id
           AND b.ledger_id                     = g_ledger_id
           LEFT OUTER JOIN gl_budorg_bc_options bc
           ON  bc.range_id = b.range_id
           AND t.budget_version_id = bc.funding_budget_version_id
     WHERE t.balance_type_code = 'B'
       AND t.budget_version_id IS NOT NULL
       AND bc.funding_budget_version_id IS NULL;

  l_log_module                  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_budget_ccids';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_budget_ccids',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid budget ccids',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_invalid_budget_ccid IN c_invalid_budget_ccids LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - invalid budget ccid: ae_header_id = '|| l_invalid_budget_ccid.ae_header_id||
                       ', ae_line_num = '|| l_invalid_budget_ccid.ae_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    g_err_count := g_err_count+1;
    g_err_hdr_ids(g_err_count) := l_invalid_budget_ccid.ae_header_id;
    g_err_event_ids(g_err_count) := l_invalid_budget_ccid.event_id;

    xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_INVALID_CCID_FOR_BUDGET'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_invalid_budget_ccid.account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_invalid_budget_ccid.ae_line_num
                ,p_token_3              => 'BUDGET_NAME'
                ,p_value_3              => l_invalid_budget_ccid.budget_name
                ,p_entity_id            => l_invalid_budget_ccid.entity_id
                ,p_event_id             => l_invalid_budget_ccid.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_invalid_budget_ccid.ae_header_id
                ,p_ae_line_num          => l_invalid_budget_ccid.ae_line_num
                ,p_accounting_batch_id  => NULL);
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid budget ccids',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function validate_budget_ccids',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_invalid_budget_ccids%ISOPEN) THEN
    CLOSE c_invalid_budget_ccids;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_invalid_budget_ccids%ISOPEN) THEN
    CLOSE c_invalid_budget_ccids;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_budget_ccids');
END validate_budget_ccids;


--=============================================================================
--
-- Name: validate_accounting_classes
-- Description: This procedure will validate the accounting class
--
--=============================================================================
PROCEDURE validate_accounting_classes
IS
  CURSOR c_invalid_accounting_classes IS
    SELECT t.ae_header_id
          ,t.ae_line_num
          ,t.event_id
          ,t.displayed_line_number
          ,t.entity_id
          ,t.accounting_class_code
      FROM xla_validation_lines_gt t
           LEFT OUTER JOIN xla_lookups lk
           ON  lk.lookup_type        = 'XLA_ACCOUNTING_CLASS'
           AND lk.lookup_code        = t.accounting_class_code
     WHERE lk.lookup_code            IS NULL
       AND t.accounting_class_code   IS NOT NULL;

  l_log_module                  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_accounting_classes';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_accounting_classes',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid accounting classes',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_inv_acct_class IN c_invalid_accounting_classes LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - invalid accounting class: ae_header_id = '|| l_inv_acct_class.ae_header_id||
                       ', ae_line_num = '|| l_inv_acct_class.ae_line_num ||
                       ', accounting_class_code = '|| l_inv_acct_class.accounting_class_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    g_err_count := g_err_count+1;
    g_err_hdr_ids(g_err_count) := l_inv_acct_class.ae_header_id;
    g_err_event_ids(g_err_count) := l_inv_acct_class.event_id;

    -- 4262811-----------------------------
    IF g_caller = C_CALLER_MPA_PROGRAM THEN
       g_message_name := 'XLA_MA_INVALID_ACCT_CLASS';
    ELSE
       g_message_name := 'XLA_AP_INVALID_ACCT_CLASS';
    END IF;
    ---------------------------------------
    xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => g_message_name   -- 4262811 'XLA_AP_INVALID_ACCT_CLASS'
                ,p_token_1              => 'LINE_NUM'
                ,p_value_1              => l_inv_acct_class.ae_line_num
                ,p_entity_id            => l_inv_acct_class.entity_id
                ,p_event_id             => l_inv_acct_class.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_inv_acct_class.ae_header_id
                ,p_ae_line_num          => l_inv_acct_class.ae_line_num
                ,p_accounting_batch_id  => NULL);
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid accounting classes',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function validate_accounting_classes',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_invalid_accounting_classes%ISOPEN) THEN
    CLOSE c_invalid_accounting_classes;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_invalid_accounting_classes%ISOPEN) THEN
    CLOSE c_invalid_accounting_classes;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_accounting_classes');
END validate_accounting_classes;


--=============================================================================
--
-- Name: validate_lines
-- Description: This API performs line level validations
--
--=============================================================================
PROCEDURE validate_lines
IS
  l_app_name                    VARCHAR2(240);
  l_user_name                   VARCHAR2(80);
  l_coa_structure_name          VARCHAR2(80);
  l_access_set_name             VARCHAR2(80);
  l_account                     VARCHAR2(2000) := NULL;
  l_budget_name                 VARCHAR2(80);
  l_je_source_name              VARCHAR2(80);
  l_prod_rule_name              VARCHAR2(80);
  l_user_conv_type              VARCHAR2(240);
  l_gain_or_loss_flag           VARCHAR2(1);
  l_seg_ledger_id               INTEGER;

  CURSOR c_line_error IS
    SELECT      *
    FROM        xla_validation_lines_gt
    WHERE       error_flag = 'Y';

  CURSOR c_account(p_coa_id INTEGER, p_code_combination_id INTEGER) IS
    SELECT fnd_flex_ext.get_segs('SQLGL', 'GL#', p_coa_id, p_code_combination_id)
    FROM   dual;

  CURSOR c_je_source_name(l_lookup_code VARCHAR2) IS
    SELECT meaning
    FROM   fnd_lookups
    WHERE  lookup_type = 'GL_CONTROL_ACCOUNT_SOURCES'
    AND    lookup_code = l_lookup_code;

  CURSOR c_prod_rule_name(p_prod_rule_type_code VARCHAR2, p_prod_rule_code VARCHAR2) IS
    SELECT name
    FROM   xla_product_rules_vl
    WHERE  product_rule_type_code = p_prod_rule_type_code
    AND    product_rule_code      = p_prod_rule_code
    AND    application_id         = g_application_id
    AND    amb_context_code       = g_amb_context_code;

  CURSOR c_budget_name(p_budget_version_id INTEGER) IS
    SELECT budget_name
    FROM   gl_budget_versions
    WHERE  budget_version_id = p_budget_version_id;

  CURSOR c_user_conv_type(p_conv_type VARCHAR2) IS
    SELECT gdct.user_conversion_type
    FROM   gl_daily_conversion_types gdct
    WHERE  gdct.conversion_type   =  p_conv_type;

  l_log_module                  VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_lines';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validate_lines',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - invalid line',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;


  IF xla_ae_code_combination_pkg.g_error_exists THEN
    xla_ae_code_combination_pkg.get_ccid_errors;
  END IF;


  FOR l_err IN c_line_error LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - invalid line: ae_header_id = '|| l_err.ae_header_id||
                       ', ae_line_num = '|| l_err.ae_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    g_err_count := g_err_count+1;
    g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
    g_err_event_ids(g_err_count) := l_err.event_id;

    l_account := NULL;

    -- Bug 7541615 - Removed the validation on currency conversion information
    IF (g_ledger_currency_code <> l_err.entered_currency_code) THEN
      IF (l_err.currency_conversion_type = 'User' AND
          l_err.currency_conversion_rate IS NULL) THEN
        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_NO_USER_CONV_RATE'
                ,p_token_1              => 'LINE_NUM'
                ,p_value_1              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      END IF;

      IF (nvl(l_err.currency_conversion_type,'User') <> 'User' AND
          l_err.currency_conversion_date IS NULL) THEN
        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_NO_CONV_DATE'
                ,p_token_1              => 'LINE_NUM'
                ,p_value_1              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      END IF;
    END IF;

    -- Validate CCID
    IF (l_err.code_combination_id = -1 and l_err.gain_or_loss_flag = 'Y') THEN
      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_AP_GAIN_LOSS_INVALID_CCID'
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => l_err.ae_line_num
        ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.ccid_enabled_flag is NULL) THEN

      -- 4262811-----------------------------
      IF g_caller = C_CALLER_MPA_PROGRAM THEN
         g_message_name := 'XLA_MA_INVALID_CCID';
      ELSE
         g_message_name := 'XLA_AP_INVALID_CCID';
      END IF;
      ---------------------------------------

      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => g_message_name   -- 4262811 'XLA_AP_INVALID_CCID'
        ,p_token_1              => 'CCID'
        ,p_value_1              => l_err.code_combination_id
        ,p_token_2              => 'LINE_NUM'
        ,p_value_2              => l_err.ae_line_num
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => l_err.ae_line_num
        ,p_accounting_batch_id  => NULL);
    ELSE
      -- CCID is disabled
      IF (l_err.ccid_enabled_flag = 'N') THEN
        IF (l_account IS NULL) THEN
          OPEN c_account(l_err.ccid_coa_id, l_err.code_combination_id);
          FETCH c_account INTO l_account;
          CLOSE c_account;
        END IF;

        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_INACTIVE_CCID'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      END IF;

      -- CCID is not within the effective date
      IF (l_err.ccid_enabled_flag = 'D') THEN
        IF (l_account IS NULL) THEN
          OPEN c_account(l_err.ccid_coa_id, l_err.code_combination_id);
          FETCH c_account INTO l_account;
          CLOSE c_account;
        END IF;

        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_CCID_INACTIVE_DATE'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      END IF;

      -- CCID is not a summary account
      IF (l_err.ccid_summary_flag = 'Y') THEN
        IF (l_account IS NULL) THEN
          OPEN c_account(l_err.ccid_coa_id, l_err.code_combination_id);
          FETCH c_account INTO l_account;
          CLOSE c_account;
        END IF;

        IF (g_caller = C_CALLER_ACCT_PROGRAM) THEN
          xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_SUMMARY_CCID'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
        ELSE
          -- 4262811-----------------------------
          IF g_caller = C_CALLER_MPA_PROGRAM THEN
             g_message_name := 'XLA_MA_SUMMARY_CCID';
          ELSE
             g_message_name := 'XLA_MJE_SUMMARY_CCID';
          END IF;
          ---------------------------------------
          xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => g_message_name   -- 4262811 'XLA_MJE_SUMMARY_CCID'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
        END IF;
      END IF;

      -- For actual and encumbrance entries, detail posting must be allowed
      -- for the ledger
      IF (l_err.balance_type_code <> 'B' AND
          l_err.detail_posting_allowed_flag = 'N') THEN
        IF (l_account IS NULL) THEN
          OPEN c_account(l_err.ccid_coa_id, l_err.code_combination_id);
          FETCH c_account INTO l_account;
          CLOSE c_account;
        END IF;

        IF (g_caller = C_CALLER_ACCT_PROGRAM) THEN
          IF (l_prod_rule_name IS NULL) THEN
            OPEN c_prod_rule_name(l_err.product_rule_type_code, l_err.product_rule_code);
            FETCH c_prod_rule_name INTO l_prod_rule_name;
            CLOSE c_prod_rule_name;
          END IF;

          xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_CCID_NOT_DET_POST'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_token_3              => 'PROD_RULE_NAME'
                ,p_value_3              => l_prod_rule_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
        ELSE
          xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_MJE_CCID_NOT_DET_POST'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
        END IF;
      END IF;

      -- For budget entries, detail budgeting must be allowed for the ledger
      IF (l_err.balance_type_code = 'B' AND
          l_err.detail_budgeting_allowed_flag = 'N') THEN
        IF (l_account IS NULL) THEN
          OPEN c_account(l_err.ccid_coa_id, l_err.code_combination_id);
          FETCH c_account INTO l_account;
          CLOSE c_account;
        END IF;

        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_CCID_NOT_DET_BUD'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      END IF;

      -- The journal source assigned to the CCID does not match that for the application
      IF (g_app_ctl_acct_source_code <> 'Y' AND
          l_err.control_account_enabled_flag NOT IN ('Y', 'N', g_app_ctl_acct_source_code)) THEN
        IF (l_je_source_name IS NULL) THEN
          OPEN c_je_source_name(l_err.control_account_enabled_flag);
          FETCH c_je_source_name INTO l_je_source_name;
          CLOSE c_je_source_name;
        END IF;

        IF (l_account IS NULL) THEN
          OPEN c_account(l_err.ccid_coa_id, l_err.code_combination_id);
          FETCH c_account INTO l_account;
          CLOSE c_account;
        END IF;

        IF (l_app_name IS NULL) THEN
          SELECT application_name INTO l_app_name
          FROM   fnd_application_vl
          WHERE  application_id = g_application_id;
        END IF;

        IF (g_caller = C_CALLER_ACCT_PROGRAM) THEN
          xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_CON_ACCT_NOT_MAT'
                ,p_token_1              => 'JOURNAL_SOURCE_NAME'
                ,p_value_1              => l_je_source_name
                ,p_token_2              => 'ACCOUNT_VALUE'
                ,p_value_2              => l_account
                ,p_token_3              => 'LINE_NUM'
                ,p_value_3              => l_err.ae_line_num
                ,p_token_4              => 'APP_NAME'
                ,p_value_4              => l_app_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
        ELSE
          xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_MJE_CON_ACCT_NOT_MAT'
                ,p_token_1              => 'JOURNAL_SOURCE_NAME'
                ,p_value_1              => l_je_source_name
                ,p_token_2              => 'ACCOUNT_VALUE'
                ,p_value_2              => l_account
                ,p_token_3              => 'LINE_NUM'
                ,p_value_3              => l_err.ae_line_num
                ,p_token_4              => 'APP_NAME'
                ,p_value_4              => l_app_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
        END IF;
      END IF;

      -- If the application is not control account enabled, the CCID must not be
      -- a control account
      IF (g_app_ctl_acct_source_code = 'N' AND
          l_err.control_account_enabled_flag <> 'N') THEN

        IF (l_app_name IS NULL) THEN
          SELECT application_name INTO l_app_name
          FROM   fnd_application_vl
          WHERE  application_id = g_application_id;
        END IF;

        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             =>'XLA_AP_APP_NOT_CONT_AC'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_token_3              => 'APPLICATION_NAME'
                ,p_value_3              => l_app_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      END IF;

      --  If CCID is a control account, all party information must be provided
      IF (l_err.control_account_enabled_flag <> 'N' AND
          (l_err.party_type_code IS NULL OR
           l_err.party_id IS NULL)) THEN

        IF (l_account IS NULL) THEN
          OPEN c_account(l_err.ccid_coa_id, l_err.code_combination_id);
          FETCH c_account INTO l_account;
          CLOSE c_account;
        END IF;

        SELECT gain_or_loss_flag INTO l_gain_or_loss_flag
          FROM xla_ae_lines
         WHERE application_id = g_application_id
           AND ae_header_id   = l_err.ae_header_id
           AND ae_line_num    = l_err.ae_line_num;

        IF l_gain_or_loss_flag = 'Y' THEN
          xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_APP_NOT_CONT_AC_GL'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
        ELSE
          IF g_caller = C_CALLER_MPA_PROGRAM THEN
            g_message_name := 'XLA_MA_NO_3RD_PARTY_CONT';
          ELSE
            g_message_name := 'XLA_AP_NO_3RD_PARTY_CONT';
          END IF;

          xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => g_message_name  -- 4262811 'XLA_AP_NO_3RD_PARTY_CONT'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_iD
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
        END IF;
      END IF;

      --  If CCID is a control account of customer or supplier, party type information must be
      --  consistant with the ccid type
      IF ((l_err.control_account_enabled_flag = 'SUPPLIER' AND l_err.party_type_code <> 'S')
            OR (l_err.control_account_enabled_flag = 'CUSTOMER' AND l_err.party_type_code <> 'C')) THEN

        IF (l_account IS NULL) THEN
          OPEN c_account(l_err.ccid_coa_id, l_err.code_combination_id);
          FETCH c_account INTO l_account;
          CLOSE c_account;
        END IF;
        g_message_name := 'XLA_AP_INCONSISTANT_3RD_PARTY';
        ---------------------------------------
        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => g_message_name  -- 4262811 'XLA_AP_NO_3RD_PARTY_CONT'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_token_3              => 'PARTY_TYPE'
                ,p_value_3              => l_err.control_account_enabled_flag
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_iD
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      END IF;

      IF (g_ledger_coa_id <> l_err.ccid_coa_id) THEN
        IF (l_account IS NULL) THEN
          OPEN c_account(l_err.ccid_coa_id, l_err.code_combination_id);
          FETCH c_account INTO l_account;
          CLOSE c_account;
        END IF;
        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_INVALID_CCID_COA_ID'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_token_3              => 'LEDGER_NAME'
                ,p_value_3              => g_ledger_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      END IF;

    END IF;

    --  If CCID is a control account, party type code must be 'S' or 'C'
    IF (l_err.party_type_code IS NOT NULL AND
        l_err.party_type_code NOT IN ('S', 'C')) THEN
      xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_INVALID_PARTY_TYPE'
                ,p_token_1              => 'PARTY_TYPE'
                ,p_value_1              => l_err.party_type_code
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
    END IF;

    -- If party id is missing when party site id is specified
    IF (l_err.party_site_id IS NOT NULL AND l_err.party_id IS NULL) THEN
      IF (g_caller = C_CALLER_ACCT_PROGRAM) THEN
        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_INVALID_PARTY_ID'
                ,p_token_1              => 'PARTY_ID'
                ,p_value_1              => l_err.party_id
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      ELSE
        -- 4262811-----------------------------
        IF g_caller = C_CALLER_MPA_PROGRAM THEN
           g_message_name := 'XLA_MA_INVALID_PARTY_ID';
        ELSE
           g_message_name := 'XLA_MJE_INVALID_PARTY_ID';
        END IF;
        ---------------------------------------
        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => g_message_name  -- 4262811 'XLA_MJE_INVALID_PARTY_ID'
                ,p_token_1              => 'PARTY_ID'
                ,p_value_1              => l_err.party_id
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      END IF;
    END IF;

    --  If party site id is missing when party id is not NULL
/*
    -- This is commented out for on bug 3648508, party site id is not always required
    IF (l_err.party_id IS NOT NULL AND l_err.party_type_code IS NULL AND l_err.party_site_id IS NULL) THEN
      IF (g_caller = C_CALLER_ACCT_PROGRAM) THEN
        xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_AP_INVALID_PARTY_SITE'
                ,p_token_1              => 'LINE_NUM'
                ,p_value_1              => l_err.displayed_line_number
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      ELSE
        xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_token_1              => 'LINE_NUM'
                ,p_value_1              => l_err.displayed_line_number
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      END IF;
    END IF;
*/

    -- If party type code is missing when party id or party site id is specified
    IF ((l_err.party_id IS NOT NULL OR l_err.party_site_id IS NOT NULL) AND
        l_err.party_type_code IS NULL) THEN
      IF (g_caller = C_CALLER_ACCT_PROGRAM) THEN
        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_INVALID_PARTY_CODE'
                ,p_token_1              => 'PARTY_TYPE'
                ,p_value_1              => l_err.party_type_code
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      ELSE
        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_MJE_INVALID_PARTY_CODE'
                ,p_token_1              => 'PARTY_TYPE'
                ,p_value_1              => l_err.party_type_code
                ,p_token_2              => 'LINE_NUM'
                ,p_value_2              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      END IF;
    END IF;

    IF (l_err.entered_dr IS NULL or l_err.entered_cr IS NOT NULL or
        l_err.accounted_dr IS NULL or l_err.accounted_cr IS NOT NULL) AND
       (l_err.entered_dr IS NOT NULL or l_err.entered_cr IS NULL or
        l_err.accounted_dr IS NOT NULL or l_err.accounted_cr IS NULL) AND
       (l_err.accounted_dr IS NOT NULL or l_err.accounted_cr IS NOT NULL) THEN
      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => 'entered_dr:'||to_char(l_err.entered_dr),
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
        trace(p_msg    => 'entered_cr:'||to_char(l_err.entered_cr),
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
        trace(p_msg    => 'accounted_cr:'||to_char(l_err.accounted_cr),
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
        trace(p_msg    => 'accounted_dr:'||to_char(l_err.accounted_dr),
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;
      IF (g_caller = C_CALLER_ACCT_PROGRAM) THEN
        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_INVALID_AMT_SIDE'
                ,p_token_1              => 'LINE_NUM'
                ,p_value_1              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      ELSE
        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_MJE_INVALID_AMT_SIDE'
                ,p_token_1              => 'LINE_NUM'
                ,p_value_1              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
      END IF;
    END IF;

    IF (NVL(l_err.entered_cr,0) > 0 AND NVL(l_err.accounted_cr,0) < 0) OR
       (NVL(l_err.entered_dr,0) > 0 AND NVL(l_err.accounted_dr,0) < 0) OR
       (NVL(l_err.entered_cr,0) < 0 AND NVL(l_err.accounted_cr,0) > 0) OR
       (NVL(l_err.entered_dr,0) < 0 AND NVL(l_err.accounted_dr,0) > 0) THEN
      xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_INCONSISTENT_AMOUNTS'
                ,p_token_1              => 'LINE_NUM'
                ,p_value_1              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
    END IF;

    IF (g_ledger_currency_code = l_err.entered_currency_code AND
       ((l_err.entered_cr IS NULL AND l_err.unrounded_entered_dr <> l_err.unrounded_accounted_dr) or
        (l_err.entered_dr IS NULL AND l_err.unrounded_entered_cr <> l_err.unrounded_accounted_cr))) THEN
        xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_INVALID_AMT_BASE'
                ,p_token_1              => 'LINE_NUM'
                ,p_value_1              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
    END IF;

    IF (l_err.accounting_class_code IS NULL) THEN
      xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_NO_ACCT_CLASS'
                ,p_token_1              => 'LINE_NUMBER'
                ,p_value_1              => l_err.displayed_line_number
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
    END IF;

    IF (l_err.accounted_cr IS NULL and l_err.accounted_dr is Null
           and l_err.currency_conversion_rate is NULL) THEN
      IF((l_err.entered_cr is not NULL or l_err.entered_dr is not NULL)
            and l_err.entered_currency_code<>g_ledger_currency_code ) THEN
--     if both are null, no need to report error here since it is reported
--     when temp line is generated.
        IF (l_err.currency_conversion_type is not NULL) THEN
          -- Bug 4765421.
          OPEN c_user_conv_type(l_err.currency_conversion_type);
          FETCH c_user_conv_type into l_user_conv_type;
          CLOSE c_user_conv_type;

          xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_NO_CONV_RATE'
                ,p_token_1              => 'CURRENCY_FROM'
                ,p_value_1              => l_err.entered_currency_code
                ,p_token_2              => 'CURRENCY_TO'
                ,p_value_2              => g_ledger_currency_code
                ,p_token_3              => 'CONVERSION_TYPE'
                ,p_value_3              => l_user_conv_type
                ,p_token_4              => 'CONVERSION_DATE'
                ,p_value_4              => l_err.currency_conversion_date
                ,p_token_5              => 'LINE_NUM'
                ,p_value_5              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
        ELSE
          xla_accounting_err_pkg.build_message(
                p_appli_s_name          => 'XLA'
                ,p_msg_name             => 'XLA_AP_NO_CONV_TYPE'
                ,p_token_1              => 'LINE_NUM'
                ,p_value_1              => l_err.ae_line_num
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => l_err.ae_line_num
                ,p_accounting_batch_id  => NULL);
        END IF;
      END IF;
    END IF;
  END LOOP;
  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - invalid line',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF ((g_bal_seg_value_option_code <> 'A') OR
      (g_mgt_seg_value_option_code <> 'A' AND g_mgt_seg_column_name IS NOT NULL)) THEN

    IF (g_bal_seg_value_option_code <> 'A') THEN
      validate_bal_segments(g_target_ledger_id);
    END IF;
    IF (g_mgt_seg_value_option_code <> 'A' AND
        g_mgt_seg_column_name IS NOT NULL) THEN
      validate_mgt_segments(g_target_ledger_id);
    END IF;
  END IF;

  IF (g_caller <> C_CALLER_THIRD_PARTY_MERGE) THEN
    validate_third_parties;
  end if;

  validate_currencies;

  IF (g_caller <> C_CALLER_THIRD_PARTY_MERGE) THEN
    validate_accounting_classes;
  END IF;

  validate_encumbrances;         -- 4458381

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function validate_lines',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_line_error%ISOPEN) THEN
    CLOSE c_line_error;
  END IF;
  IF (c_account%ISOPEN) THEN
    CLOSE c_account;
  END IF;
  IF (c_je_source_name%ISOPEN) THEN
    CLOSE c_je_source_name;
  END IF;
  IF (c_prod_rule_name%ISOPEN) THEN
    CLOSE c_prod_rule_name;
  END IF;
  IF (c_budget_name%ISOPEN) THEN
    CLOSE c_budget_name;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_line_error%ISOPEN) THEN
    CLOSE c_line_error;
  END IF;
  IF (c_account%ISOPEN) THEN
    CLOSE c_account;
  END IF;
  IF (c_je_source_name%ISOPEN) THEN
    CLOSE c_je_source_name;
  END IF;
  IF (c_prod_rule_name%ISOPEN) THEN
    CLOSE c_prod_rule_name;
  END IF;
  IF (c_budget_name%ISOPEN) THEN
    CLOSE c_budget_name;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validate_lines');
END validate_lines;


--=============================================================================
--
-- Name: validation
-- Description: This procedure performs the validation for journal entry lines,
--              journal entry headers, and the ledger security.  All journal
--              entry with error will be marked as complete.
--
--=============================================================================
PROCEDURE validation
IS
  l_prev_err_count  INTEGER;
  l_temp_err_count  INTEGER;
  l_log_module      VARCHAR2(240);
	l_distinct_hdr_ids t_array_int;
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validation';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validation',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_prev_err_count := g_err_count;

  IF (C_LEVEL_ERROR >= g_log_level) THEN
    trace(p_msg    => 'before error count = '||g_err_count,
          p_module => l_log_module,
          p_level  => C_LEVEL_ERROR);
  END IF;

  validate_lines;
  validate_access_set_security;
  validate_headers;

  IF (C_LEVEL_ERROR >= g_log_level) THEN
    trace(p_msg    => 'after error count = '||g_err_count,
          p_module => l_log_module,
          p_level  => C_LEVEL_ERROR);
  END IF;

  --
  -- Mark the journal entry as done if any error is encountered for its lines
  -- so no further processing will be performed on those journal entries.
  --
  IF (g_err_count > l_prev_err_count) THEN

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      l_temp_err_count := g_err_count-l_prev_err_count;
      trace(p_msg    => '# error count from validation = '||l_temp_err_count,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    /* Bug 	7128871
       Exhausted Undo Tablespace when a single header has many lines.
       The following sql updates # of errors * # of lines.

    FORALL i IN l_prev_err_count+1..g_err_count
      UPDATE     xla_validation_lines_gt
        set      balancing_line_type = C_LINE_TYPE_COMPLETE
        WHERE    ae_header_id = g_err_hdr_ids(i); */

    --
    -- Bug 7128871
    --     Update xla_validation_lines_gt for distinct ae header ids.
    --

     FOR i IN g_prev_err_count+1..g_err_count LOOP
       IF NOT l_distinct_hdr_ids.EXISTS(g_err_hdr_ids(i)) THEN
          l_distinct_hdr_ids(g_err_hdr_ids(i)) := g_err_hdr_ids(i);
       END IF;
     END LOOP;
     --
     --  As indices of l_dinstinct_hdr_ids are not consecutive,
     --  need to use "INDICES OF".
     --
     FORALL i IN INDICES OF l_distinct_hdr_ids
       UPDATE  /*+ INDEX (XLA_VALIDATION_LINES_GT,XLA_VALIDATION_LINES_GT_N2)
 */ XLA_VALIDATION_LINES_GT
          SET balancing_line_type = C_LINE_TYPE_COMPLETE
        WHERE ae_header_id = l_distinct_hdr_ids(i);

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validation',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.validation');
END validation;


--=============================================================================
--
-- Name: balance_by_bsv_and_ledger_curr
-- Description: This function inserts rows to the xla_ae_lines of the specified
--              subledger journal entry so that the entry will be balanced by
--              balancing segments and ledger currency.
--
--=============================================================================
PROCEDURE balance_by_bsv_and_ledger_curr
  (p_event_id                   IN  INTEGER,
   p_entity_id                  IN  INTEGER,
   p_ae_header_id               IN  INTEGER)
IS
  CURSOR c_bal IS
    SELECT      bal_seg_value                  bal_seg_val
              , entered_currency_code          currency_code
              , max_ae_line_num                max_ae_line_num
              , max_displayed_line_number      max_disp_line_num
              , sum(nvl(accounted_dr,0))       accted_dr
              , sum(nvl(accounted_cr,0))       accted_cr
              , sum(nvl(entered_dr,0))         entered_dr
              , sum(nvl(entered_cr,0))         entered_cr
              , accounting_date                accounting_date
              , party_type_code                party_type_code
              , party_id                       party_id
              , party_site_id                  party_site_id
    FROM        xla_validation_lines_gt
    WHERE       ae_header_id = p_ae_header_id
    GROUP BY    bal_seg_value
              , entered_currency_code
              , max_ae_line_num
              , max_displayed_line_number
              , accounting_date
              , party_type_code
              , party_id
              , party_site_id
    HAVING    sum(nvl(accounted_dr,0)) <> sum(nvl(accounted_cr,0));

  -- 4917607 - performance changes
  CURSOR c_sccid_segs (p_bal_seg_val VARCHAR2, p_sus_ccid INTEGER, p_bal_seg_column VARCHAR2) IS
    SELECT chart_of_accounts_id
         , decode(p_bal_seg_column,'SEGMENT1',p_bal_seg_val,t.segment1)
         , decode(p_bal_seg_column,'SEGMENT2',p_bal_seg_val,t.segment2)
         , decode(p_bal_seg_column,'SEGMENT3',p_bal_seg_val,t.segment3)
         , decode(p_bal_seg_column,'SEGMENT4',p_bal_seg_val,t.segment4)
         , decode(p_bal_seg_column,'SEGMENT5',p_bal_seg_val,t.segment5)
         , decode(p_bal_seg_column,'SEGMENT6',p_bal_seg_val,t.segment6)
         , decode(p_bal_seg_column,'SEGMENT7',p_bal_seg_val,t.segment7)
         , decode(p_bal_seg_column,'SEGMENT8',p_bal_seg_val,t.segment8)
         , decode(p_bal_seg_column,'SEGMENT9',p_bal_seg_val,t.segment9)
         , decode(p_bal_seg_column,'SEGMENT10',p_bal_seg_val,t.segment10)
         , decode(p_bal_seg_column,'SEGMENT11',p_bal_seg_val,t.segment11)
         , decode(p_bal_seg_column,'SEGMENT12',p_bal_seg_val,t.segment12)
         , decode(p_bal_seg_column,'SEGMENT13',p_bal_seg_val,t.segment13)
         , decode(p_bal_seg_column,'SEGMENT14',p_bal_seg_val,t.segment14)
         , decode(p_bal_seg_column,'SEGMENT15',p_bal_seg_val,t.segment15)
         , decode(p_bal_seg_column,'SEGMENT16',p_bal_seg_val,t.segment16)
         , decode(p_bal_seg_column,'SEGMENT17',p_bal_seg_val,t.segment17)
         , decode(p_bal_seg_column,'SEGMENT18',p_bal_seg_val,t.segment18)
         , decode(p_bal_seg_column,'SEGMENT19',p_bal_seg_val,t.segment19)
         , decode(p_bal_seg_column,'SEGMENT20',p_bal_seg_val,t.segment20)
         , decode(p_bal_seg_column,'SEGMENT21',p_bal_seg_val,t.segment21)
         , decode(p_bal_seg_column,'SEGMENT22',p_bal_seg_val,t.segment22)
         , decode(p_bal_seg_column,'SEGMENT23',p_bal_seg_val,t.segment23)
         , decode(p_bal_seg_column,'SEGMENT24',p_bal_seg_val,t.segment24)
         , decode(p_bal_seg_column,'SEGMENT25',p_bal_seg_val,t.segment25)
         , decode(p_bal_seg_column,'SEGMENT26',p_bal_seg_val,t.segment26)
         , decode(p_bal_seg_column,'SEGMENT27',p_bal_seg_val,t.segment27)
         , decode(p_bal_seg_column,'SEGMENT28',p_bal_seg_val,t.segment28)
         , decode(p_bal_seg_column,'SEGMENT29',p_bal_seg_val,t.segment29)
         , decode(p_bal_seg_column,'SEGMENT30',p_bal_seg_val,t.segment30)
      FROM gl_code_combinations t
     WHERE t.code_combination_id = p_sus_ccid;

  CURSOR c_seg_number (p_seg_col_name VARCHAR2, p_coa_id INTEGER) IS
    SELECT      display_order
    FROM        (SELECT ROWNUM display_order, application_column_name
                 FROM ( SELECT application_column_name
                        FROM   FND_ID_FLEX_SEGMENTS_VL
                        WHERE  ID_FLEX_NUM    = p_coa_id
                        AND    ID_FLEX_CODE   = 'GL#'
                        AND    APPLICATION_ID = 101
                        order by decode(enabled_flag, 'Y', 1, 'N', 2), segment_num))
    WHERE       application_column_name = p_seg_col_name;

  l_bal                 c_bal%ROWTYPE;
  l_mgt_seg_val         VARCHAR2(30);
  l_ref3                VARCHAR2(30);
  l_seg_number          NUMBER;
  l_sus_ccid            INTEGER;
  l_seg                 FND_FLEX_EXT.SegmentArray;
  l_seg2                FND_FLEX_EXT.SegmentArray;
  l_coa_id              INTEGER;
  l_num_segs            INTEGER;
  l_result              INTEGER := 0;
  l_stmt                VARCHAR2(4000);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.balance_by_bsv_and_ledger_curr';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function balance_by_bsv_and_ledger_curr',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_ae_header_id = '||p_ae_header_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c_bal;
  FETCH c_bal INTO l_bal;

  IF (g_mgt_seg_column_name IS NULL) THEN
    l_mgt_seg_val := NULL;
  ELSIF (g_mgt_seg_column_name = g_bal_seg_column_name) THEN
    l_mgt_seg_val := l_bal.bal_seg_val;
  ELSE
    l_stmt := 'SELECT '||g_mgt_seg_column_name||'
               FROM   gl_code_combinations
               WHERE  code_combination_id = '||g_sla_ledger_cur_bal_sus_ccid;

    EXECUTE IMMEDIATE l_stmt INTO l_mgt_seg_val;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP -lance by BSV and ledger currency',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  WHILE (c_bal%FOUND) LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP balance by BSV and ledger currency: bal_seg_val = '||l_bal.bal_seg_val,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    OPEN c_sccid_segs(l_bal.bal_seg_val, g_sla_ledger_cur_bal_sus_ccid, g_bal_seg_column_name);
    FETCH c_sccid_segs INTO l_coa_id,
                            l_seg2(1), l_seg2(2), l_seg2(3), l_seg2(4), l_seg2(5),
                            l_seg2(6), l_seg2(7), l_seg2(8), l_seg2(9), l_seg2(10),
                            l_seg2(11), l_seg2(12), l_seg2(13), l_seg2(14), l_seg2(15),
                            l_seg2(16), l_seg2(17), l_seg2(18), l_seg2(19), l_seg2(20),
                            l_seg2(21), l_seg2(22), l_seg2(23), l_seg2(24), l_seg2(25),
                            l_seg2(26), l_seg2(27), l_seg2(28), l_seg2(29), l_seg2(30);
    CLOSE c_sccid_segs;

    l_stmt := 'SELECT code_combination_id, reference3 FROM gl_code_combinations '||
              'WHERE chart_of_accounts_id = :1 ';
    FOR i in 1 .. 30 LOOP
      IF l_seg2(i) IS NOT NULL THEN
        l_stmt := l_stmt || ' AND segment'||i||' = '''||l_seg2(i)||'''';
      ELSE
        l_stmt := l_stmt || ' AND segment'||i||' IS NULL ';
      END IF;
    END LOOP;

    BEGIN
      EXECUTE IMMEDIATE l_stmt
         INTO l_sus_ccid, l_ref3
        USING l_coa_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_sus_ccid := NULL;
    END;

    IF (l_sus_ccid IS NULL) THEN

      IF (FND_FLEX_EXT.get_segments(
                        application_short_name       => 'SQLGL',
                        key_flex_code                => 'GL#',
                        structure_number             => g_ledger_coa_id,
                        combination_id               => g_sla_ledger_cur_bal_sus_ccid,
                        n_segments                   => l_num_segs,
                        segments                     => l_seg) = FALSE) THEN
        IF (C_LEVEL_ERROR >= g_log_level) THEN
          trace(p_msg    => 'XLA_INTERNAL_ERROR : Invalid balance by ledger currency suspense CCID',
                p_module => l_log_module,
                p_level  => C_LEVEL_ERROR);
          trace(p_msg    => 'Error: '||fnd_message.get,
                p_module => l_log_module,
                p_level  => C_LEVEL_ERROR);
        END IF;
        xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTERNAL_ERROR'
                ,p_token_1              => 'MESSAGE'
                ,p_value_1              => 'Invalid balance by ledger currency suspense CCID'
                ,p_token_2              => 'LOCATION'
                ,p_value_2              => 'XLA_JE_VALIDATION_PKG.balance_by_bsv_and_ledger_curr'
                ,p_entity_id            => p_entity_id
                ,p_event_id             => p_event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => p_ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
        l_sus_ccid := -1;
        l_result := 1;
        l_ref3 := 'N';
      ELSE
        OPEN c_seg_number(g_bal_seg_column_name, g_ledger_coa_id);
        FETCH c_seg_number INTO l_seg_number;
        CLOSE c_seg_number;

        l_seg(l_seg_number) := l_bal.bal_seg_val;
        IF (FND_FLEX_EXT.get_combination_id(
                        application_short_name       => 'SQLGL',
                        key_flex_code                => 'GL#',
                        structure_number             => g_ledger_coa_id,
                        validation_date              => l_bal.accounting_date,
                        n_segments                   => l_num_segs,
                        segments                     => l_seg,
                        combination_id               => l_sus_ccid) = FALSE) THEN
          IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace(p_msg    => 'XLA_INTERNAL_ERROR : Cannot get valid Code Combination ID',
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
            trace(p_msg    => 'Error: '||fnd_message.get,
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
            trace(p_msg    => 'accounting_date = '||l_bal.accounting_date,
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
            trace(p_msg    => 'num_segs = '||l_num_segs,
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
            FOR i IN 1..l_num_segs LOOP
              trace(p_msg    => 'seg('||i||') = '||l_seg(i),
                    p_module => l_log_module,
                    p_level  => C_LEVEL_ERROR);
            END LOOP;
          END IF;

          xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTERNAL_ERROR'
                ,p_token_1              => 'MESSAGE'
                ,p_value_1              => 'Cannot get valid Code Combination ID'
                ,p_token_2              => 'LOCATION'
                ,p_value_2              => 'XLA_JE_VALIDATION_PKG.balance_by_bsv_and_ledger_curr'
                ,p_entity_id            => p_entity_id
                ,p_event_id             => p_event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => p_ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
          l_sus_ccid := -1;
          l_result := 1;
          l_ref3 := 'N';
        ELSE
          SELECT reference3 INTO l_ref3
            FROM gl_code_combinations
           WHERE code_combination_id = l_sus_ccid;
        END IF;
      END IF;
    END IF;

    IF (l_bal.accted_dr>l_bal.accted_cr) THEN
      l_bal.accted_cr := l_bal.accted_dr - l_bal.accted_cr;
      l_bal.accted_dr := NULL;
      l_bal.entered_cr := l_bal.entered_dr - l_bal.entered_cr;
      l_bal.entered_dr := NULL;
    ELSE
      l_bal.accted_dr := l_bal.accted_cr - l_bal.accted_dr;
      l_bal.accted_cr := NULL;
      l_bal.entered_dr := l_bal.entered_cr - l_bal.entered_dr;
      l_bal.entered_cr := NULL;
    END IF;

    INSERT INTO xla_validation_lines_gt
        (balancing_line_type
        ,ledger_id
        ,ae_header_id
        ,ae_line_num
        ,displayed_line_number
        ,max_ae_line_num
        ,max_displayed_line_number
        ,event_id
        ,entity_id
        ,accounting_date
        ,entered_currency_code
        ,entered_cr
        ,entered_dr
        ,accounted_cr
        ,accounted_dr
        ,code_combination_id
        ,mgt_seg_value
        ,bal_seg_value
        ,control_account_enabled_flag
        ,party_type_code
        ,party_id
        ,party_site_id)
        VALUES
        (C_LINE_TYPE_LC_BALANCING
        ,g_ledger_id
        ,p_ae_header_id
        ,l_bal.max_ae_line_num
        ,l_bal.max_disp_line_num
        ,l_bal.max_ae_line_num
        ,l_bal.max_disp_line_num
        ,p_event_id
        ,p_entity_id
        ,l_bal.accounting_date
        ,l_bal.currency_code
        ,l_bal.entered_cr
        ,l_bal.entered_dr
        ,l_bal.accted_cr
        ,l_bal.accted_dr
        ,l_sus_ccid
        ,l_mgt_seg_val
        ,l_bal.bal_seg_val
        ,l_ref3
        ,l_bal.party_type_code
        ,l_bal.party_id
        ,l_bal.party_site_id );

    g_new_line_count := g_new_line_count + 1;

    FETCH c_bal INTO l_bal;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - balance by BSV and ledger currency',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;
  CLOSE c_bal;

  IF (l_result > 0) THEN
    g_err_count := g_err_count + 1;
    g_err_hdr_ids(g_err_count) := p_ae_header_id;
    g_err_event_ids(g_err_count) := p_event_id;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function balance_by_bsv_and_ledger_curr',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_bal%ISOPEN) THEN
    CLOSE c_bal;
  END IF;
  IF (c_seg_number%ISOPEN) THEN
    CLOSE c_seg_number;
  END IF;
  IF (c_sccid_segs%ISOPEN) THEN
    CLOSE c_sccid_segs;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_bal%ISOPEN) THEN
    CLOSE c_bal;
  END IF;
  IF (c_seg_number%ISOPEN) THEN
    CLOSE c_seg_number;
  END IF;
  IF (c_sccid_segs%ISOPEN) THEN
    CLOSE c_sccid_segs;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.balance_by_bsv_and_ledger_curr');
END;

--=============================================================================
--
-- Name: balance_single_entered_curr
-- Description: This function checks if the journal entries that have only one
--              entered currency are balanced by entered currency.  If the
--              journal entry is not balanced, the entry is marked as error
--
--=============================================================================
PROCEDURE balance_single_entered_curr
is

  CURSOR c_bal(p_rounding_offset NUMBER) is
    SELECT ae_header_id
           ,entity_id
           ,event_id
      FROM xla_validation_lines_gt
     WHERE balance_type_code = 'A' --  <> 'B'   -- 4458381
       AND entered_currency_code <> 'STAT'
       AND balancing_line_type = C_LINE_TYPE_PROCESS
     GROUP BY ae_header_id, entity_id , event_id
     HAVING ROUND(nvl(sum(unrounded_entered_dr/entered_currency_mau), 0)+p_rounding_offset) <>
               ROUND(nvl(sum(unrounded_entered_cr/entered_currency_mau), 0)+p_rounding_offset)
       AND count(distinct entered_currency_code) = 1;
  l_comp_hdr_ids        t_array_int;
  l_comp_count          INTEGER := 0;
  l_log_module          VARCHAR2(240);
  l_rounding_offset     NUMBER;
  l_rounding_rule_code  VARCHAR2(30);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.balance_single_entered_curr';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function balance_single_entered_curr',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_caller = C_CALLER_ACCT_PROGRAM) THEN
    l_rounding_rule_code :=xla_accounting_cache_pkg.GetValueChar(
                           p_source_code        => 'XLA_ROUNDING_RULE_CODE'
                         , p_target_ledger_id   => g_ledger_id
                         );
  ELSE
    SELECT xlo.rounding_rule_code
    INTO   l_rounding_rule_code
    FROM   xla_ledger_options     xlo
    WHERE xlo.application_id = g_application_id
      AND xlo.ledger_id = g_trx_ledger_id;
  END IF;

  IF l_rounding_rule_code = 'NEAREST' THEN
    l_rounding_offset := 0;
  ELSIF l_rounding_rule_code = 'UP' THEN
    l_rounding_offset := .5-power(10, -30);
  ELSIF l_rounding_rule_code = 'DOWN' THEN
    l_rounding_offset := -(.5-power(10, -30));
  ELSE
    l_rounding_offset := 0;
  END IF;

  FOR l_bal IN c_bal(l_rounding_offset) LOOP

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - check error for single entered currency: ae_header_id = '||l_bal.ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_AP_UNBAL_ENTED_AMT'
                ,p_entity_id            => l_bal.entity_id
                ,p_event_id             => l_bal.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_bal.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    g_err_count := g_err_count + 1;
    g_err_hdr_ids(g_err_count) := l_bal.ae_header_id;
    g_err_event_ids(g_err_count) := l_bal.event_id;

    l_comp_count := l_comp_count + 1;
    l_comp_hdr_ids(l_comp_count) := l_bal.ae_header_id;

  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - check error for single entered currency',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (l_comp_count>0) THEN
    FORALL j in 1..l_comp_count
        UPDATE  xla_validation_lines_gt
           SET  balancing_line_type = C_LINE_TYPE_COMPLETE
         WHERE  ae_header_id = l_comp_hdr_ids(j)
           AND  balancing_line_type = C_LINE_TYPE_PROCESS;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function balance_single_entered_curr',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_bal%ISOPEN) THEN
    CLOSE c_bal;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_bal%ISOPEN) THEN
    CLOSE c_bal;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.balance_single_entered_curr');

END balance_single_entered_curr;



--=============================================================================
--
-- Name: balance_by_ledger_currency
-- Description: This function checks if the journal entries are balanced by
--              ledger currency.  If the journal entry is not balanced by
--              ledger currency and the 'balance by ledger currency option'
--              is 'N', error will be returned.  However, if the balance option
--              is 'Y', new lines will be created to balance the journal entry
--              by balancing segment and ledger currency.
--
--=============================================================================
PROCEDURE balance_by_ledger_currency
IS
  CURSOR c_bal(p_mau                   NUMBER
              ,p_rounding_offset       NUMBER) IS
    SELECT  ae_header_id
           ,entity_id
           ,event_id
    FROM    xla_validation_lines_gt
    WHERE   balance_type_code = 'A'
    AND     entered_currency_code <> 'STAT'
    AND     balancing_line_type = C_LINE_TYPE_PROCESS
    GROUP BY ae_header_id, entity_id, event_id
    HAVING   sum(nvl(accounted_dr,0)) <> sum(nvl(accounted_cr,0))
       AND   ROUND( NVL(SUM(unrounded_accounted_dr),0) /p_mau+p_rounding_offset)
               <> ROUND( NVL(SUM(unrounded_accounted_cr),0) /p_mau+p_rounding_offset);

  l_bal_seg_column      VARCHAR2(30);
  l_mgt_seg_column      VARCHAR2(30);
  l_max_ae_line_num     INTEGER;
  l_max_disp_line_num   INTEGER;

  CURSOR c_aad (p_ae_header_id INTEGER) IS
    SELECT  pr.name, lk.meaning, ec.name, et.name
    FROM    xla_product_rules_tl    pr
            ,xla_event_classes_tl   ec
            ,xla_event_types_tl     et
            ,xla_lookups            lk
            ,xla_ae_headers         h
    WHERE   lk.lookup_code            = h.product_rule_type_code
      AND   lk.lookup_type            = 'XLA_OWNER_TYPE'
      AND   pr.amb_context_code       = g_amb_context_code
      AND   pr.application_id         = g_application_id
      AND   pr.product_rule_type_code = h.product_rule_type_code
      AND   pr.product_rule_code      = h.product_rule_code
      AND   pr.language               = USERENV('LANG')
      AND   ec.application_id         = et.application_id
      AND   ec.event_class_code       = et.event_class_code
      AND   ec.language               = USERENV('LANG')
      AND   et.application_id         = h.application_id
      AND   et.event_type_code        = h.event_type_code
      AND   et.language               = USERENV('LANG')
      AND   h.ae_header_id            = p_ae_header_id
      AND   h.application_id          = g_application_id;

  l_prod_rule_name      VARCHAR2(80);
  l_owner               VARCHAR2(80);
  l_event_class_name    VARCHAR2(80);
  l_event_type_name     VARCHAR2(80);

  l_comp_hdr_ids        t_array_int;
  l_comp_count          INTEGER := 0;
  j                     INTEGER;

  l_mau                 NUMBER;
  l_rounding_offset     NUMBER;
  l_rounding_rule_code  VARCHAR2(30);

  l_log_module          VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.balance_by_ledger_currency';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function balance_by_ledger_currency',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_caller = C_CALLER_ACCT_PROGRAM) THEN
    l_mau:= xla_accounting_cache_pkg.GetValueNum(
                           p_source_code        => 'XLA_CURRENCY_MAU'
                         , p_target_ledger_id   => g_ledger_id);

    l_rounding_rule_code :=xla_accounting_cache_pkg.GetValueChar(
                           p_source_code        => 'XLA_ROUNDING_RULE_CODE'
                         , p_target_ledger_id   => g_ledger_id
                         );
  ELSE
    SELECT nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
          ,xlo.rounding_rule_code
    INTO   l_mau, l_rounding_rule_code
    FROM   xla_ledger_options     xlo
          ,gl_ledgers             gl
          ,fnd_currencies         fcu
    WHERE xlo.application_id = g_application_id
      AND xlo.ledger_id = g_trx_ledger_id
      AND gl.ledger_id = g_ledger_id
      AND fcu.currency_code = gl.currency_code;
  END IF;

  IF l_rounding_rule_code = 'NEAREST' THEN
    l_rounding_offset := 0;
  ELSIF l_rounding_rule_code = 'UP' THEN
    l_rounding_offset := .5-power(10, -30);
  ELSIF l_rounding_rule_code = 'DOWN' THEN
    l_rounding_offset := -(.5-power(10, -30));
  ELSE
    l_rounding_offset := 0;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'l_mau = '||l_mau,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
    trace(p_msg    => 'l_rounding_offset = '||l_rounding_offset,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
    trace(p_msg    => 'g_sla_bal_by_ledger_curr_flag = '||g_sla_bal_by_ledger_curr_flag,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
    trace(p_msg    => 'BEGIN LOOP - balance by ledger currency',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_bal IN c_bal(l_mau,l_rounding_offset) LOOP

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - balance by ledger currency: ae_header_id = '||l_bal.ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF (g_sla_bal_by_ledger_curr_flag = 'N') THEN
      IF (g_caller = C_CALLER_MANUAL) THEN
        xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_MJE_UNBAL_BASE_AMT'
                ,p_entity_id            => l_bal.entity_id
                ,p_event_id             => l_bal.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_bal.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
      ELSE
        OPEN c_aad (l_bal.ae_header_id);
        FETCH c_aad INTO l_prod_rule_name, l_owner, l_event_class_name, l_event_type_name;
        CLOSE c_aad;

        xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_AP_UNBAL_BASE_AMT'
                ,p_token_1              => 'PROD_RULE_NAME'
                ,p_value_1              => l_prod_rule_name
                ,p_token_2              => 'OWNER'
                ,p_value_2              => l_owner
                ,p_token_3              => 'EVENT_CLASS_NAME'
                ,p_value_3              => l_event_class_name
                ,p_token_4              => 'EVENT_TYPE_NAME'
                ,p_value_4              => l_event_type_name
                ,p_entity_id            => l_bal.entity_id
                ,p_event_id             => l_bal.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_bal.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
      END IF;
      g_err_count := g_err_count + 1;
      g_err_hdr_ids(g_err_count) := l_bal.ae_header_id;
      g_err_event_ids(g_err_count) := l_bal.event_id;
    ELSE
      balance_by_bsv_and_ledger_curr(l_bal.event_id,
                                     l_bal.entity_id,
                                     l_bal.ae_header_id);
    END IF;

    l_comp_count := l_comp_count + 1;
    l_comp_hdr_ids(l_comp_count) := l_bal.ae_header_id;

  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - balance by ledger currency',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (l_comp_count>0) THEN
    FORALL j in 1..l_comp_count
        UPDATE  xla_validation_lines_gt
           SET  balancing_line_type = C_LINE_TYPE_COMPLETE
         WHERE  ae_header_id = l_comp_hdr_ids(j)
           AND  balancing_line_type = C_LINE_TYPE_PROCESS;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function balance_by_ledger_curr',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_bal%ISOPEN) THEN
    CLOSE c_bal;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_bal%ISOPEN) THEN
    CLOSE c_bal;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.balance_by_ledger_currency');
END;


--=============================================================================
--
-- Name: balance_by_journal_rounding
-- Description: Journal rounding  pre segment, entered currency
--
--=============================================================================
PROCEDURE balance_by_journal_rounding
IS
  CURSOR c_bal IS
    SELECT bal_seg_value               bal_seg_val
          ,entered_currency_code       entered_currency_code
          ,nvl(sum(entered_dr), 0)     entered_dr
          ,nvl(sum(entered_cr), 0)     entered_cr
          ,nvl(sum(accounted_dr), 0)     accted_dr
          ,nvl(sum(accounted_cr), 0)     accted_cr
          ,ae_header_id                ae_header_id
          ,encumbrance_type_id        -- added for 9030331
          ,max_ae_line_num                max_ae_line_num
          ,max_displayed_line_number      max_disp_line_num
          ,accounting_date                accounting_date
          ,entity_id
          ,event_id
    FROM   XLA_VALIDATION_LINES_GT
    WHERE balancing_line_type in (C_LINE_TYPE_PROCESS
                                 ,C_LINE_TYPE_IC_BAL_INTER
                                 ,C_LINE_TYPE_IC_BAL_INTRA
                                 ,C_LINE_TYPE_XLA_BALANCING
                                 ,C_LINE_TYPE_ENC_BALANCING) -- 4458381
      AND balance_type_code <> 'B'
      AND entered_currency_code <> 'STAT'
    GROUP BY bal_seg_value
            ,encumbrance_type_id        -- added for 9030331
            ,entered_currency_code
            ,max_ae_line_num
            ,max_displayed_line_number
            ,ae_header_id
            ,entity_id
            ,event_id
            ,accounting_date
    HAVING nvl(sum(accounted_dr), 0) <> nvl(sum(accounted_cr), 0)
           or nvl(sum(entered_dr), 0) <> nvl(sum(entered_cr), 0);

  -- 4917607 - performance changes
  CURSOR c_rccid_segs (p_bal_seg_val VARCHAR2, p_rounding_ccid INTEGER, p_bal_seg_column VARCHAR2) IS
    SELECT chart_of_accounts_id
         , decode(p_bal_seg_column,'SEGMENT1',p_bal_seg_val,t.segment1)
         , decode(p_bal_seg_column,'SEGMENT2',p_bal_seg_val,t.segment2)
         , decode(p_bal_seg_column,'SEGMENT3',p_bal_seg_val,t.segment3)
         , decode(p_bal_seg_column,'SEGMENT4',p_bal_seg_val,t.segment4)
         , decode(p_bal_seg_column,'SEGMENT5',p_bal_seg_val,t.segment5)
         , decode(p_bal_seg_column,'SEGMENT6',p_bal_seg_val,t.segment6)
         , decode(p_bal_seg_column,'SEGMENT7',p_bal_seg_val,t.segment7)
         , decode(p_bal_seg_column,'SEGMENT8',p_bal_seg_val,t.segment8)
         , decode(p_bal_seg_column,'SEGMENT9',p_bal_seg_val,t.segment9)
         , decode(p_bal_seg_column,'SEGMENT10',p_bal_seg_val,t.segment10)
         , decode(p_bal_seg_column,'SEGMENT11',p_bal_seg_val,t.segment11)
         , decode(p_bal_seg_column,'SEGMENT12',p_bal_seg_val,t.segment12)
         , decode(p_bal_seg_column,'SEGMENT13',p_bal_seg_val,t.segment13)
         , decode(p_bal_seg_column,'SEGMENT14',p_bal_seg_val,t.segment14)
         , decode(p_bal_seg_column,'SEGMENT15',p_bal_seg_val,t.segment15)
         , decode(p_bal_seg_column,'SEGMENT16',p_bal_seg_val,t.segment16)
         , decode(p_bal_seg_column,'SEGMENT17',p_bal_seg_val,t.segment17)
         , decode(p_bal_seg_column,'SEGMENT18',p_bal_seg_val,t.segment18)
         , decode(p_bal_seg_column,'SEGMENT19',p_bal_seg_val,t.segment19)
         , decode(p_bal_seg_column,'SEGMENT20',p_bal_seg_val,t.segment20)
         , decode(p_bal_seg_column,'SEGMENT21',p_bal_seg_val,t.segment21)
         , decode(p_bal_seg_column,'SEGMENT22',p_bal_seg_val,t.segment22)
         , decode(p_bal_seg_column,'SEGMENT23',p_bal_seg_val,t.segment23)
         , decode(p_bal_seg_column,'SEGMENT24',p_bal_seg_val,t.segment24)
         , decode(p_bal_seg_column,'SEGMENT25',p_bal_seg_val,t.segment25)
         , decode(p_bal_seg_column,'SEGMENT26',p_bal_seg_val,t.segment26)
         , decode(p_bal_seg_column,'SEGMENT27',p_bal_seg_val,t.segment27)
         , decode(p_bal_seg_column,'SEGMENT28',p_bal_seg_val,t.segment28)
         , decode(p_bal_seg_column,'SEGMENT29',p_bal_seg_val,t.segment29)
         , decode(p_bal_seg_column,'SEGMENT30',p_bal_seg_val,t.segment30)
      FROM gl_code_combinations t
     WHERE t.code_combination_id = p_rounding_ccid;

  CURSOR c_seg_number (p_seg_col_name VARCHAR2, p_coa_id INTEGER) IS
    SELECT      display_order
    FROM        (SELECT ROWNUM display_order, application_column_name
                 FROM ( SELECT application_column_name
                        FROM   FND_ID_FLEX_SEGMENTS_VL
                        WHERE  ID_FLEX_NUM    = p_coa_id
                        AND    ID_FLEX_CODE   = 'GL#'
                        AND    APPLICATION_ID = 101
                        order by decode(enabled_flag, 'Y', 1, 'N', 2), segment_num))
    WHERE       application_column_name = p_seg_col_name;

  l_bal                 c_bal%ROWTYPE;
  l_ref3                VARCHAR2(30);
  l_mgt_seg_val         VARCHAR2(30);
  l_seg_number          NUMBER;
  l_seg                 FND_FLEX_EXT.SegmentArray;
  l_seg2                FND_FLEX_EXT.SegmentArray;
  l_num_segs            INTEGER;
  l_coa_id              INTEGER;
  l_stmt                VARCHAR2(4000);
  l_entered_cr          NUMBER;
  l_entered_dr          NUMBER;

  l_rounding_ccid       INTEGER;
  l_account             VARCHAR2(1000);
  l_log_module          VARCHAR2(240);

BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.balance_by_journal_rounding';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function balance_by_journal_rounding',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;


  -- to prevent unbalanced data from entering GL

  IF (g_sla_rounding_ccid is NULL) AND (g_suspense_allowed_flag = 'Y') THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'rounding_account not exist, suspense enabled. end of function balance_by_journal_rounding',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    END IF;
    RETURN;
  END IF;


  IF (g_sla_rounding_ccid is NULL) AND (g_suspense_allowed_flag = 'N') THEN

	FOR l_bal_rec IN c_bal LOOP

		 xla_accounting_err_pkg.build_message(
                    p_appli_s_name              => 'XLA'
                    ,p_msg_name                 => 'XLA_NO_RND_NO_SUSP'
                    ,p_entity_id                => l_bal_rec.entity_id
                    ,p_event_id                 => l_bal_rec.event_id
                    ,p_ledger_id                => g_ledger_id
                    ,p_ae_header_id             => l_bal_rec.ae_header_id
                    ,p_ae_line_num              => NULL
                    ,p_accounting_batch_id      => NULL);

		g_err_count := g_err_count + 1;
		g_err_hdr_ids(g_err_count) := l_bal_rec.ae_header_id;
		g_err_event_ids(g_err_count) := l_bal_rec.event_id;

	END LOOP;

    RETURN;
 END IF;




  OPEN c_bal;
  FETCH c_bal INTO l_bal;

  IF (g_mgt_seg_column_name IS NULL) THEN
    l_mgt_seg_val := NULL;
  ELSIF (g_mgt_seg_column_name = g_bal_seg_column_name) THEN
    l_mgt_seg_val := l_bal.bal_seg_val;
  ELSE
    l_stmt := 'SELECT '||g_mgt_seg_column_name||'
               FROM   gl_code_combinations
               WHERE  code_combination_id = '||g_sla_rounding_ccid;

    EXECUTE IMMEDIATE l_stmt INTO l_mgt_seg_val;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - balance by journal rounding',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  WHILE (c_bal%FOUND) LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP balance by journal rounding',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    OPEN c_rccid_segs(l_bal.bal_seg_val, g_sla_rounding_ccid, g_bal_seg_column_name);
    FETCH c_rccid_segs INTO l_coa_id,
                            l_seg2(1), l_seg2(2), l_seg2(3), l_seg2(4), l_seg2(5),
                            l_seg2(6), l_seg2(7), l_seg2(8), l_seg2(9), l_seg2(10),
                            l_seg2(11), l_seg2(12), l_seg2(13), l_seg2(14), l_seg2(15),
                            l_seg2(16), l_seg2(17), l_seg2(18), l_seg2(19), l_seg2(20),
                            l_seg2(21), l_seg2(22), l_seg2(23), l_seg2(24), l_seg2(25),
                            l_seg2(26), l_seg2(27), l_seg2(28), l_seg2(29), l_seg2(30);
    CLOSE c_rccid_segs;

    l_stmt := 'SELECT code_combination_id, reference3 FROM gl_code_combinations '||
              'WHERE chart_of_accounts_id = :1 ';
    FOR i in 1 .. 30 LOOP
      IF l_seg2(i) IS NOT NULL THEN
        l_stmt := l_stmt || ' AND segment'||i||' = '''||l_seg2(i)||'''';
      ELSE
        l_stmt := l_stmt || ' AND segment'||i||' IS NULL ';
      END IF;
    END LOOP;

    BEGIN
      EXECUTE IMMEDIATE l_stmt
         INTO l_rounding_ccid, l_ref3
        USING l_coa_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_rounding_ccid := NULL;
    END;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'l_rounding_ccid = '||l_rounding_ccid,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF (l_rounding_ccid IS NULL) THEN

      IF (FND_FLEX_EXT.get_segments(
                        application_short_name       => 'SQLGL',
                        key_flex_code                => 'GL#',
                        structure_number             => g_ledger_coa_id,
                        combination_id               => g_sla_rounding_ccid,
                        n_segments                   => l_num_segs,
                        segments                     => l_seg) = FALSE) THEN
        IF (C_LEVEL_ERROR >= g_log_level) THEN
          trace(p_msg    => 'XLA_INTERNAL_ERROR : Invalid rounding CCID',
                p_module => l_log_module,
                p_level  => C_LEVEL_ERROR);
          trace(p_msg    => 'Error: '||fnd_message.get,
                p_module => l_log_module,
                p_level  => C_LEVEL_ERROR);
        END IF;
        xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTERNAL_ERROR'
                ,p_token_1              => 'MESSAGE'
                ,p_value_1              => 'Invalid rounding CCID'
                ,p_token_2              => 'LOCATION'
                ,p_value_2              => 'XLA_JE_VALIDATION_PKG.balance_by_journal_rounding'
                ,p_entity_id            => l_bal.entity_id
                ,p_event_id             => l_bal.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_bal.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
        l_rounding_ccid := -1;
        g_err_count := g_err_count + 1;
        g_err_hdr_ids(g_err_count) := l_bal.ae_header_id;
        g_err_event_ids(g_err_count) := l_bal.event_id;
      ELSE
        OPEN c_seg_number(g_bal_seg_column_name, g_ledger_coa_id);
        FETCH c_seg_number INTO l_seg_number;
        CLOSE c_seg_number;

        l_seg(l_seg_number) := l_bal.bal_seg_val;
        IF (FND_FLEX_EXT.get_combination_id(
                        application_short_name       => 'SQLGL',
                        key_flex_code                => 'GL#',
                        structure_number             => g_ledger_coa_id,
                        validation_date              => l_bal.accounting_date,
                        n_segments                   => l_num_segs,
                        segments                     => l_seg,
                        combination_id               => l_rounding_ccid) = FALSE) THEN
          IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace(p_msg    => 'XLA_INTERNAL_ERROR : Cannot get valid Code Combination ID',
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
            trace(p_msg    => 'Error: '||fnd_message.get,
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
            trace(p_msg    => 'accounting_date = '||l_bal.accounting_date,
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
            trace(p_msg    => 'num_segs = '||l_num_segs,
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
            FOR i IN 1..l_num_segs LOOP
              trace(p_msg    => 'seg('||i||') = '||l_seg(i),
                    p_module => l_log_module,
                    p_level  => C_LEVEL_ERROR);
            END LOOP;
          END IF;

          xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTERNAL_ERROR'
                ,p_token_1              => 'MESSAGE'
                ,p_value_1              => 'Cannot get valid Code Combination ID'
                ,p_token_2              => 'LOCATION'
                ,p_value_2              => 'XLA_JE_VALIDATION_PKG.balance_by_journal_rounding'
                ,p_entity_id            => l_bal.entity_id
                ,p_event_id             => l_bal.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_bal.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
          l_rounding_ccid := -1;
          g_err_count := g_err_count + 1;
          g_err_hdr_ids(g_err_count) := l_bal.ae_header_id;
          g_err_event_ids(g_err_count) := l_bal.event_id;
        ELSE
          SELECT reference3
            INTO l_ref3
            FROM gl_code_combinations
           WHERE code_combination_id = l_rounding_ccid;
        END IF;
      END IF;
    END IF;

    IF (l_bal.accted_dr>l_bal.accted_cr) THEN
      l_bal.accted_cr := l_bal.accted_dr - l_bal.accted_cr;
      l_bal.accted_dr := NULL;

      IF(l_bal.entered_currency_code = g_ledger_currency_code) THEN
        l_bal.entered_cr    := l_bal.accted_cr;
      ELSE
        l_bal.entered_cr    := l_bal.entered_dr - l_bal.entered_cr;
      END IF;
      l_bal.entered_dr    := NULL;
    ELSIF (l_bal.accted_dr<l_bal.accted_cr) THEN
      l_bal.accted_dr := l_bal.accted_cr - l_bal.accted_dr;
      l_bal.accted_cr := NULL;
      IF(l_bal.entered_currency_code = g_ledger_currency_code) THEN
        l_bal.entered_dr    := l_bal.accted_dr;
      ELSE
        l_bal.entered_dr    := l_bal.entered_cr - l_bal.entered_dr;
      END IF;
      l_bal.entered_cr    := NULL;
    -- following, we assume entered_currency can't be ledger currency
    ELSIF (l_bal.entered_dr>l_bal.entered_cr) THEN
      l_bal.accted_cr := 0;
      l_bal.accted_dr := NULL;
      l_bal.entered_cr    := l_bal.entered_dr - l_bal.entered_cr;
      l_bal.entered_dr    := NULL;
    ELSIF (l_bal.entered_dr<l_bal.entered_cr) THEN
      l_bal.accted_dr := 0;
      l_bal.accted_cr := NULL;
      l_bal.entered_dr    := l_bal.entered_cr - l_bal.entered_dr;
      l_bal.entered_cr    := NULL;
    END IF;


    INSERT INTO xla_validation_lines_gt
        (balancing_line_type
        ,ledger_id
        ,ae_header_id
        ,ae_line_num
        ,displayed_line_number
        ,max_ae_line_num
        ,max_displayed_line_number
        ,event_id
        ,entity_id
        ,accounting_date
        ,entered_currency_code
        ,entered_cr
        ,entered_dr
        ,accounted_cr
        ,accounted_dr
        ,code_combination_id
        ,control_account_enabled_flag
        ,mgt_seg_value
        ,bal_seg_value
        ,encumbrance_type_id        -- added for 9030331
        )
        VALUES
        (C_LINE_TYPE_RD_BALANCING
        ,g_ledger_id
        ,l_bal.ae_header_id
        ,l_bal.max_ae_line_num
        ,l_bal.max_disp_line_num
        ,l_bal.max_ae_line_num
        ,l_bal.max_disp_line_num
        ,l_bal.event_id
        ,l_bal.entity_id
        ,l_bal.accounting_date
        ,l_bal.entered_currency_code
        ,l_bal.entered_cr
        ,l_bal.entered_dr
        ,l_bal.accted_cr
        ,l_bal.accted_dr
        ,l_rounding_ccid
        ,l_ref3
        ,l_mgt_seg_val
        ,l_bal.bal_seg_val
        ,l_bal.encumbrance_type_id        -- added for 9030331
         );

    IF (NVL(l_rounding_ccid,-1) > 0 AND
        NVL(l_ref3,'N') NOT IN ( 'N','R') ) THEN

      SELECT fnd_flex_ext.get_segs('SQLGL', 'GL#', g_ledger_coa_id, l_rounding_ccid)
        INTO l_account
        FROM dual;

      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_AP_ROUNDING_CONT_ACCT'
                ,p_token_1              => 'ACCOUNT'
                ,p_value_1              => l_account
                ,p_token_2              => 'LEDGER_NAME'
                ,p_value_2              => g_ledger_name
                ,p_entity_id            => l_bal.entity_id
                ,p_event_id             => l_bal.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_bal.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);

      g_err_count := g_err_count + 1;
      g_err_hdr_ids(g_err_count) := l_bal.ae_header_id;
      g_err_event_ids(g_err_count) := l_bal.event_id;
    END IF;

    g_new_line_count := g_new_line_count + 1;

    FETCH c_bal INTO l_bal;
  END LOOP;

-- Bug 7529475
/*
update xla_validation_lines_gt xgt
set xgt.encumbrance_type_id = (SELECT xll.encumbrance_type_id
                               FROM xla_validation_lines_gt xll
			       WHERE xll.ae_header_id = xgt.ae_header_id
                               and xll.balancing_line_type=C_LINE_TYPE_ENC_BALANCING
                               and xll.balance_type_code <> 'B'
				AND xll.entered_currency_code <> 'STAT'
                                and xll.encumbrance_type_id is not null
                                and rownum = 1
                                )
where xgt.balancing_line_type = C_LINE_TYPE_RD_BALANCING
and xgt.encumbrance_type_id is null
and nvl(xgt.balance_type_code, ' ') <> 'B'
AND nvl(xgt.entered_currency_code, ' ') <> 'STAT';
*/ -- commented for 9030331

IF (SQL%ROWCOUNT > 0) then
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Encumbrance type id stamped for rounding lines',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
END IF;

-- End of Bug 7529475

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - balance by journal rounding',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;
  CLOSE c_bal;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function balance_by_journal_rounding',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_bal%ISOPEN) THEN
    CLOSE c_bal;
  END IF;
  IF (c_seg_number%ISOPEN) THEN
    CLOSE c_seg_number;
  END IF;
  IF (c_rccid_segs%ISOPEN) THEN
    CLOSE c_rccid_segs;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_bal%ISOPEN) THEN
    CLOSE c_bal;
  END IF;
  IF (c_seg_number%ISOPEN) THEN
    CLOSE c_seg_number;
  END IF;
  IF (c_rccid_segs%ISOPEN) THEN
    CLOSE c_rccid_segs;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.balance_by_journal_rounding');

END balance_by_journal_rounding;

--=============================================================================
--
-- Name: create_intercompany_errors
-- Description: Translate intercompany errors FROM FUN_BAL_ERRORS_GT into
--              XLA error messages.
--
--=============================================================================
PROCEDURE create_intercompany_errors
  (p_err_count           IN OUT NOCOPY INTEGER
  ,p_err_ae_header_ids   IN OUT NOCOPY t_array_int)
IS
  CURSOR c_error_standard IS
    SELECT  distinct
            err.error_code
          , le2.name                   from_le_name
          , le3.name                   to_le_name
          , le1.name                   le_name
          , err.ccid
          , je.user_je_category_name   je_category_name
          , hdr.entity_id
          , hdr.event_id
          , hdr.ae_header_id
    FROM    fun_bal_errors_gt           err
          , xla_ae_headers_gt           hdr
          , gl_je_categories            je
          , xle_entity_profiles         le1
          , xle_entity_profiles         le2
          , xle_entity_profiles         le3
    WHERE   err.group_id                = hdr.ae_header_id
      AND   je.je_category_name(+)      = hdr.je_category_name
      AND   le1.legal_entity_id(+)      = err.le_id
      AND   le2.legal_entity_id(+)      = err.from_le_id
      AND   le3.legal_entity_id(+)      = err.to_le_id;

  CURSOR c_error_manual IS
    SELECT  distinct
            err.error_code
          , le2.name                   from_le_name
          , le3.name                   to_le_name
          , le1.name                   le_name
          , err.ccid
          , je.user_je_category_name   je_category_name
          , hdr.entity_id
          , hdr.event_id
          , hdr.ae_header_id
    FROM    fun_bal_errors_gt           err
          , xla_ae_headers              hdr
          , gl_je_categories            je
          , xle_entity_profiles         le1
          , xle_entity_profiles         le2
          , xle_entity_profiles         le3
    WHERE   err.group_id                = hdr.ae_header_id
      AND   je.je_category_name(+)      = hdr.je_category_name
      AND   le1.legal_entity_id(+)      = err.le_id
      AND   le2.legal_entity_id(+)      = err.from_le_id
      AND   le3.legal_entity_id(+)      = err.to_le_id
      AND   hdr.application_id          = g_application_id
      AND   hdr.ae_header_id            = g_ae_header_id;

  l_err                  c_error_manual%ROWTYPE;
  l_account              VARCHAR2(2400);
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_intercompany_errors';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure create_intercompany_errors',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - fun_bal_errors_gt',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (g_caller in( C_CALLER_ACCT_PROGRAM, C_CALLER_THIRD_PARTY_MERGE, C_CALLER_MPA_PROGRAM)) THEN
    OPEN c_error_standard;
  ELSE
    OPEN c_error_manual;
  END IF;

  LOOP
    IF (g_caller in (C_CALLER_ACCT_PROGRAM,  C_CALLER_THIRD_PARTY_MERGE, C_CALLER_MPA_PROGRAM)) THEN
      FETCH c_error_standard INTO l_err;
      EXIT WHEN c_error_standard%NOTFOUND;
    ELSE
      FETCH c_error_manual INTO l_err;
      EXIT WHEN c_error_manual%NOTFOUND;
    END IF;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - fun_bal_errors_gt: ae_header_id = '||l_err.ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'ae_header_id = '||l_err.ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
      trace(p_msg    => 'error_code = '||l_err.error_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    g_err_count := g_err_count + 1;
    g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
    g_err_event_ids(g_err_count) := l_err.event_id;

    p_err_count := p_err_count + 1;
    p_err_ae_header_ids(p_err_count) := l_err.ae_header_id;

    IF (l_err.error_code = 'FUN_INTER_BSV_NOT_ASSIGNED') THEN
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTER_BSV_NOT_ASSIGNED'
                ,p_token_1              => 'LEDGER_NAME'
                ,p_value_1              => g_ledger_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.error_code = 'FUN_INTER_REC_NOT_ASSIGNED') THEN
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTER_REC_NOT_ASSIGNED'
                ,p_token_1              => 'FROM_LE_ID'
                ,p_value_1              => l_err.from_le_name
                ,p_token_2              => 'TO_LE_ID'
                ,p_value_2              => l_err.to_le_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.error_code = 'FUN_INTER_REC_NO_DEFAULT') THEN
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTER_REC_NO_DEFAULT'
                ,p_token_1              => 'FROM_LE_ID'
                ,p_value_1              => l_err.from_le_name
                ,p_token_2              => 'TO_LE_ID'
                ,p_value_2              => l_err.to_le_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.error_code = 'FUN_INTER_REC_NOT_VALID') THEN
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTER_REC_NOT_VALID'
                ,p_token_1              => 'FROM_LE_ID'
                ,p_value_1              => l_err.from_le_name
                ,p_token_2              => 'TO_LE_ID'
                ,p_value_2              => l_err.to_le_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.error_code = 'FUN_INTER_PAY_NOT_ASSIGNED') THEN
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTER_PAY_NOT_ASSIGNED'
                ,p_token_1              => 'FROM_LE_ID'
                ,p_value_1              => l_err.from_le_name
                ,p_token_2              => 'TO_LE_ID'
                ,p_value_2              => l_err.to_le_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.error_code = 'FUN_INTER_PAY_NO_DEFAULT') THEN
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTER_PAY_NO_DEFAULT'
                ,p_token_1              => 'FROM_LE_ID'
                ,p_value_1              => l_err.from_le_name
                ,p_token_2              => 'TO_LE_ID'
                ,p_value_2              => l_err.to_le_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.error_code = 'FUN_INTER_PAY_NOT_VALID') THEN
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'FUN_INTER_PAY_NOT_VALID'
                ,p_token_1              => 'FROM_LE_ID'
                ,p_value_1              => l_err.from_le_name
                ,p_token_2              => 'TO_LE_ID'
                ,p_value_2              => l_err.to_le_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.error_code = 'FUN_INTRA_RULE_NOT_ASSIGNED') THEN
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTRA_RULE_NOT_ASSIGNED'
                ,p_token_1              => 'LEDGER_NAME'
                ,p_value_1              => g_ledger_name
                ,p_token_2              => 'SOURCE_NAME'
                ,p_value_2              => g_app_je_source_name
                ,p_token_3              => 'JE_CATEGORY'
                ,p_value_3              => l_err.je_category_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.error_code = 'FUN_INTRA_NO_CLEARING_BSV') THEN
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTRA_NO_CLEARING_BSV'
                ,p_token_1              => 'LEDGER_NAME'
                ,p_value_1              => g_ledger_name
                ,p_token_2              => 'SOURCE_NAME'
                ,p_value_2              => g_app_je_source_name
                ,p_token_3              => 'JE_CATEGORY'
                ,p_value_3              => l_err.je_category_name
                ,p_token_4              => 'LE_ID'
                ,p_value_4              => l_err.le_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.error_code = 'FUN_INTRA_CC_NOT_VALID') THEN
      SELECT    fnd_flex_ext.get_segs('SQLGL', 'GL#', g_ledger_coa_id, l_err.ccid)
      INTO      l_account
      FROM      dual;

      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTRA_CC_NOT_VALID'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.error_code = 'FUN_INTRA_CC_NOT_CREATED') THEN
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTRA_CC_NOT_CREATED'
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.error_code = 'FUN_INTRA_CC_NOT_ACTIVE') THEN
      SELECT    fnd_flex_ext.get_segs('SQLGL', 'GL#', g_ledger_coa_id, l_err.ccid)
      INTO      l_account
      FROM      dual;

      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTRA_CC_NOT_ACTIVE'
                ,p_token_1              => 'ACCOUNT_VALUE'
                ,p_value_1              => l_account
                ,p_token_2              => 'LE_ID'
                ,p_value_2              => l_err.le_name
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.error_code = 'FUN_BSV_INVALID') THEN
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTRA_BSV_INVALID'
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    ELSE
      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'FUN'
                ,p_msg_name             => l_err.error_code
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    END IF;
  END LOOP;
  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - fun_bal_errors_gt',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (g_caller in (C_CALLER_ACCT_PROGRAM,  C_CALLER_THIRD_PARTY_MERGE, C_CALLER_MPA_PROGRAM)) THEN
    CLOSE c_error_standard;
  ELSE
    CLOSE c_error_manual;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of procedure create_intercompany_errors',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_error_manual%ISOPEN) THEN
    CLOSE c_error_manual;
  END IF;
  IF (c_error_standard%ISOPEN) THEN
    CLOSE c_error_standard;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_error_manual%ISOPEN) THEN
    CLOSE c_error_manual;
  END IF;
  IF (c_error_standard%ISOPEN) THEN
    CLOSE c_error_standard;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.create_intercompany_errors');
END;


--=============================================================================
--
-- Name: balance_by_intercompany
-- Description: This function inserts rows to the gl temporary balancing table
--              if the journal entry is not balanced by balancing segments.  If
--              rows are inserted into the gl balancing temporary table, it
--              will THEN call the GL due from/due to routine which create
--              entries to balance the journal entry by balancing segment.
--              After the call, this function will save the new entries to the
--              xla temporary balancing table.
--
--=============================================================================
PROCEDURE balance_by_intercompany
IS
  CURSOR c_bal(p_mau                   NUMBER
              ,p_rounding_offset       NUMBER
              ) IS SELECT ae_header_id
                        ,je_category_name
                        ,accounting_date
                        ,event_id
                        ,entity_id
                FROM    xla_validation_lines_gt l
                WHERE   balance_type_code       = 'A'
                AND     entered_currency_code  <> 'STAT'
                AND     balancing_line_type     = C_LINE_TYPE_PROCESS
                GROUP BY ae_header_id
                        ,je_category_name
                        ,accounting_date
                        ,event_id
                        ,entity_id
                        ,bal_seg_value
                --HAVING        sum(nvl(accounted_dr,0)) <> sum(nvl(accounted_cr,0))
                HAVING  ROUND( NVL(SUM(unrounded_accounted_dr),0) /p_mau+p_rounding_offset)
               <> ROUND( NVL(SUM(unrounded_accounted_cr),0) /p_mau+p_rounding_offset)

                ORDER BY ae_header_id;

  l_bal_count           INTEGER := 0;
  l_err_hdr_ids         t_array_int;
  l_err_count           INTEGER := 0;
  l_ae_header_ids       t_array_int;
  l_distinct_hdr_ids    t_array_int;
  l_je_category_names   t_array_varchar30;
  l_accounting_dates    t_array_date;
  l_count               INTEGER;
  j                     INTEGER;

  l_last_ae_header_id   INTEGER := -1;

  l_bal_retcode         VARCHAR2(30);
  l_bal_msg_count       NUMBER;
  l_bal_msg_data        VARCHAR2(4000);
  l_debug_flag          VARCHAR2(1);

  l_mau                 NUMBER;
  l_rounding_offset     NUMBER;
  l_rounding_rule_code  VARCHAR2(30);

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.balance_by_intercompany';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function balance_by_intercompany',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --
  -- For journal entry unbalanced by BSV and entered currency, if the
  -- balance cross entity journals is disabled, mark error.
  --
  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'LOOP BEGIN - balance by intercompany',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (g_caller = C_CALLER_ACCT_PROGRAM) THEN
    l_mau:= xla_accounting_cache_pkg.GetValueNum(
                           p_source_code        => 'XLA_CURRENCY_MAU'
                         , p_target_ledger_id   => g_ledger_id);

    l_rounding_rule_code :=xla_accounting_cache_pkg.GetValueChar(
                           p_source_code        => 'XLA_ROUNDING_RULE_CODE'
                         , p_target_ledger_id   => g_ledger_id
                         );
  ELSE
    SELECT nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
          ,xlo.rounding_rule_code
    INTO   l_mau, l_rounding_rule_code
    FROM   xla_ledger_options     xlo
          ,gl_ledgers             gl
          ,fnd_currencies         fcu
    WHERE xlo.application_id = g_application_id
      AND xlo.ledger_id      = g_trx_ledger_id
      AND gl.ledger_id       = g_ledger_id
      AND fcu.currency_code  = gl.currency_code;
  END IF;

  IF l_rounding_rule_code = 'NEAREST' THEN
    l_rounding_offset := 0;
  ELSIF l_rounding_rule_code = 'UP' THEN
    l_rounding_offset := .5-power(10, -30);
  ELSIF l_rounding_rule_code = 'DOWN' THEN
    l_rounding_offset := -(.5-power(10, -30));
  ELSE
    l_rounding_offset := 0;
  END IF;

  FOR l_bal IN c_bal(l_mau,l_rounding_offset) LOOP

    IF (l_last_ae_header_id <> l_bal.ae_header_id) THEN
      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => 'LOOP - balance by intercompany: ae_header_id - '||l_bal.ae_header_id,
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;

      IF (g_allow_intercompany_post_flag = 'N') THEN
        g_err_count := g_err_count+1;
        g_err_hdr_ids(g_err_count) := l_bal.ae_header_id;
        g_err_event_ids(g_err_count) := l_bal.event_id;

        l_err_count := l_err_count+1;
        l_err_hdr_ids(l_err_count) := l_bal.ae_header_id;
        xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_AP_IC_POST_FLAG_OFF'
                ,p_token_1              => 'LEDGER_NAME'
                ,p_value_1              => g_ledger_name
                ,p_entity_id            => l_bal.entity_id
                ,p_event_id             => l_bal.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_bal.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
      ELSE
        l_bal_count := l_bal_count+1;

        l_ae_header_ids(l_bal_count)     := l_bal.ae_header_id;
        l_je_category_names(l_bal_count) := l_bal.je_category_name;
        l_accounting_dates(l_bal_count)  := l_bal.accounting_date;

        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace(p_msg    => 'ae_header_ids('||l_bal_count||') = '||l_ae_header_ids(l_bal_count),
                p_module => l_log_module,
                p_level  => C_LEVEL_STATEMENT);
          trace(p_msg    => 'je_category_names('||l_bal_count||') = '||l_je_category_names(l_bal_count),
                p_module => l_log_module,
                p_level  => C_LEVEL_STATEMENT);
          trace(p_msg    => 'accounting_dates('||l_bal_count||') = '||l_accounting_dates(l_bal_count),
                p_module => l_log_module,
                p_level  => C_LEVEL_STATEMENT);
        END IF;
      END IF;
      l_last_ae_header_id := l_bal.ae_header_id;
    END IF;

  END LOOP;
  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - balance by intercompany',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  --
  -- If FUN balancing is required for any journal entries, insert the
  -- journal entries into the FUN balancing tables and call the
  -- balancing API
  --
  IF (l_bal_count>0) THEN
    FORALL j IN 1..l_bal_count
      INSERT INTO fun_bal_headers_gt (
           group_id
          ,ledger_id
          ,je_source_name
          ,je_category_name
          ,gl_date
          ,status)
        VALUES (
           l_ae_header_ids(j)
          ,g_target_ledger_id
          ,g_app_je_source_name
          ,l_je_category_names(j)
          ,l_accounting_dates(j)
          ,'OK');

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# rows inserted into fun_bal_headers_gt: '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;


    --8496807
    --three types of unbalanced headers are handled in this FUN API-integration
    --a) header with no reversal: insert H1
    --b) header with some lines reversed, some lines not reversed: insert -H1 and H1, for XLA these are same header but FUN
    --   API is tricked into seeing these as two different transactions
    --c) header with all lines reversed: insert -H1

    -- for negative headers inserted, lines cr/dr are switched before sending and after being retrieved from FUN API


    --HINTS added on several sqls in this procedure for 9351919

    INSERT INTO fun_bal_headers_gt( group_id
          ,ledger_id
          ,je_source_name
          ,je_category_name
          ,gl_date
          ,status)
    SELECT group_id * -1
          ,ledger_id
          ,je_source_name
          ,je_category_name
          ,gl_date
          ,status
    FROM fun_bal_headers_gt fgt
    WHERE EXISTS (SELECT /*+ NO_UNNEST INDEX(xdl XLA_DISTRIBUTION_LINKS_N3)*/ 1
                  FROM xla_distribution_links xdl
		  WHERE fgt.group_id = xdl.ae_header_id
		  AND xdl.temp_line_num <0
		  AND xdl.application_id = g_application_id);


    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# rows inserted into fun_bal_headers_gt: (insert negative headers if full/partial reversal exists) '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;


    DELETE FROM fun_bal_headers_gt fgt
    WHERE fgt.group_id > 0
    AND NOT EXISTS (SELECT /*+ NO_UNNEST INDEX(xdl XLA_DISTRIBUTION_LINKS_N3)*/ 1
                    FROM xla_distribution_links xdl
		    WHERE fgt.group_id = xdl.ae_header_id
		    AND (xdl.temp_line_num IS NULL OR xdl.temp_line_num >0)
		    AND xdl.application_id = g_application_id);


    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# rows deleted fun_bal_headers_gt: (delete positive headers if all header-lines are reversed) '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;


--normal case
   INSERT INTO fun_bal_lines_gt (
         group_id
        ,bal_seg_val
        ,entered_amt_dr
        ,entered_amt_cr
        ,entered_currency_code
        ,exchange_date
        ,exchange_rate
        ,exchange_rate_type
        ,accounted_amt_dr
        ,accounted_amt_cr
        ,generated)
        SELECT   /*+ leading(h) */ l.ae_header_id
                ,l.bal_seg_value
                ,l.unrounded_entered_dr
                ,l.unrounded_entered_cr
                ,l.entered_currency_code
                ,l.currency_conversion_date
                ,l.currency_conversion_rate
                ,l.currency_conversion_type
                ,l.unrounded_accounted_dr
                ,l.unrounded_accounted_cr
                ,'N'
        FROM     xla_validation_lines_gt l
                ,fun_bal_headers_gt h
        WHERE    l.balancing_line_type = C_LINE_TYPE_PROCESS
        AND      l.ae_header_id = h.group_id
	AND      h.group_id > 0
	AND      EXISTS (SELECT /*+ NO_UNNEST INDEX(xdl XLA_DISTRIBUTION_LINKS_N3)*/ 1
	                 FROM xla_distribution_links xdl
			 WHERE xdl.ae_header_id= l.ae_header_id
			 AND xdl.ae_line_num= l.ae_line_num
			 AND (xdl.temp_line_num IS NULL OR xdl.temp_line_num >0)
			 AND xdl.application_id = g_application_id);

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# non-reversal rows inserted into fun_bal_lines_gt: '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;


--reversal case
    INSERT INTO fun_bal_lines_gt (
         group_id
        ,bal_seg_val
        ,entered_amt_dr
        ,entered_amt_cr
        ,entered_currency_code
        ,exchange_date
        ,exchange_rate
        ,exchange_rate_type
        ,accounted_amt_dr
        ,accounted_amt_cr
        ,generated)
        SELECT   /*+ leading(h) */ l.ae_header_id * -1
                ,l.bal_seg_value
		,l.unrounded_entered_cr
                ,l.unrounded_entered_dr
                ,l.entered_currency_code
                ,l.currency_conversion_date
                ,l.currency_conversion_rate
                ,l.currency_conversion_type
                ,l.unrounded_accounted_cr
                ,l.unrounded_accounted_dr
                ,'N'
        FROM     xla_validation_lines_gt l
                ,fun_bal_headers_gt h
        WHERE    l.balancing_line_type = C_LINE_TYPE_PROCESS
        AND      l.ae_header_id = h.group_id * -1
	AND      h.group_id < 0
	AND      EXISTS (SELECT /*+ NO_UNNEST INDEX(xdl XLA_DISTRIBUTION_LINKS_N3)*/ 1
	                 FROM xla_distribution_links xdl
			 WHERE xdl.ae_header_id= l.ae_header_id
			 AND xdl.ae_line_num= l.ae_line_num
			 AND xdl.temp_line_num <0
			 AND xdl.application_id = g_application_id);


	IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# reversal rows inserted into fun_bal_lines_gt: '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;


    IF (g_log_enabled) THEN
      l_debug_flag := 'Y';
    ELSE
      l_debug_flag := 'N';
    END IF;


    fun_bal_pkg.journal_balancing
                (p_api_version          => 1.0
                ,p_debug                => l_debug_flag
                ,x_return_status        => l_bal_retcode
                ,x_msg_count            => l_bal_msg_count
                ,x_msg_data             => l_bal_msg_data
                ,p_product_code         => 'XLA');



    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'l_bal_retcode = '||l_bal_retcode,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
      trace(p_msg    => 'l_bal_msg_count = '||l_bal_msg_count,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
      trace(p_msg    => 'l_bal_msg_data = '||l_bal_msg_data,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF (l_bal_retcode <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'Error returning from fun_bal_pkg.journal_balancing: '||l_bal_retcode,
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;
      create_intercompany_errors(l_err_count, l_err_hdr_ids);
    END IF;

    INSERT INTO xla_validation_lines_gt(
                     ae_header_id
                    ,ae_line_num
                    ,displayed_line_number
                    ,max_ae_line_num
                    ,max_displayed_line_number
                    ,ledger_id
                    ,event_id
                    ,entity_id
                    ,accounting_date
                    ,entered_currency_mau
                    ,code_combination_id
                    ,entered_currency_code
                    ,currency_conversion_date
                    ,currency_conversion_rate
                    ,currency_conversion_type
                    ,entered_cr
                    ,entered_dr
                    ,accounted_cr
                    ,accounted_dr
                    ,unrounded_entered_cr
                    ,unrounded_entered_dr
                    ,unrounded_accounted_cr
                    ,unrounded_accounted_dr
                    ,bal_seg_value
                    ,mgt_seg_value
                    ,balancing_line_type
                    ,balance_type_code)
            SELECT   /*+ LEADING(RES) USE_NL(L)*/ res.group_id
                    ,l.max_ae_line_num
                    ,l.max_displayed_line_number
                    ,l.max_ae_line_num
                    ,l.max_displayed_line_number
                    ,g_ledger_id
                    ,l.event_id
                    ,l.entity_id
                    ,l.accounting_date
                    ,nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
                    ,res.ccid
                    ,res.entered_currency_code
                    ,res.exchange_date
                    ,res.exchange_rate
                    ,res.exchange_rate_type
                    ,ROUND(res.entered_amt_cr /(nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision)))+l_rounding_offset)*(nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision)))
                    ,ROUND(res.entered_amt_dr /(nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision)))+l_rounding_offset)*(nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision)))
                    ,ROUND(res.accounted_amt_cr /l_mau+l_rounding_offset)*l_mau
                    ,ROUND(res.accounted_amt_dr /l_mau+l_rounding_offset)*l_mau
                    ,res.entered_amt_cr
                    ,res.entered_amt_dr
                    ,res.accounted_amt_cr
                    ,res.accounted_amt_dr
                    ,res.bal_seg_val
                    ,decode(g_mgt_seg_column_name
                            ,'SEGMENT1', ccid.segment1, 'SEGMENT2', ccid.segment2
                            ,'SEGMENT3', ccid.segment3, 'SEGMENT4', ccid.segment4
                            ,'SEGMENT5', ccid.segment5, 'SEGMENT6', ccid.segment6
                            ,'SEGMENT7', ccid.segment7, 'SEGMENT8', ccid.segment8
                            ,'SEGMENT9', ccid.segment9, 'SEGMENT10', ccid.segment10
                            ,'SEGMENT11', ccid.segment11, 'SEGMENT12', ccid.segment12
                            ,'SEGMENT13', ccid.segment13, 'SEGMENT14', ccid.segment14
                            ,'SEGMENT15', ccid.segment15, 'SEGMENT16', ccid.segment16
                            ,'SEGMENT17', ccid.segment17, 'SEGMENT18', ccid.segment18
                            ,'SEGMENT19', ccid.segment19, 'SEGMENT20', ccid.segment20
                            ,'SEGMENT21', ccid.segment21, 'SEGMENT22', ccid.segment22
                            ,'SEGMENT23', ccid.segment23, 'SEGMENT24', ccid.segment24
                            ,'SEGMENT25', ccid.segment25, 'SEGMENT26', ccid.segment26
                            ,'SEGMENT27', ccid.segment27, 'SEGMENT28', ccid.segment28
                            ,'SEGMENT29', ccid.segment29, 'SEGMENT30', ccid.segment30, NULL)
                    ,decode(res.balancing_type, C_FUN_INTRA, C_LINE_TYPE_IC_BAL_INTRA,
                                                C_LINE_TYPE_IC_BAL_INTER)
                    ,l.balance_type_code
            FROM    fun_bal_results_gt     res
                    ,xla_validation_lines_gt l
                    ,gl_code_combinations   ccid
                    ,fnd_currencies fcu
            WHERE   l.ae_line_num           = l.max_ae_line_num
              AND   l.ae_header_id          = res.group_id
              AND   ccid.code_combination_id= res.ccid
	      AND   res.group_id > 0
              AND   res.entered_currency_code = fcu.currency_code;

      l_count := SQL%ROWCOUNT;
      g_new_line_count := g_new_line_count + l_count;



    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# non-reversal rows created by intercompany API  = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;



    INSERT INTO xla_validation_lines_gt(
                     ae_header_id
                    ,ae_line_num
                    ,displayed_line_number
                    ,max_ae_line_num
                    ,max_displayed_line_number
                    ,ledger_id
                    ,event_id
                    ,entity_id
                    ,accounting_date
                    ,entered_currency_mau
                    ,code_combination_id
                    ,entered_currency_code
                    ,currency_conversion_date
                    ,currency_conversion_rate
                    ,currency_conversion_type
                    ,entered_cr
                    ,entered_dr
                    ,accounted_cr
                    ,accounted_dr
                    ,unrounded_entered_cr
                    ,unrounded_entered_dr
                    ,unrounded_accounted_cr
                    ,unrounded_accounted_dr
                    ,bal_seg_value
                    ,mgt_seg_value
                    ,balancing_line_type
                    ,balance_type_code)
            SELECT    /*+ LEADING(RES) USE_NL(L)*/ res.group_id * -1
                    ,l.max_ae_line_num
                    ,l.max_displayed_line_number
                    ,l.max_ae_line_num
                    ,l.max_displayed_line_number
                    ,g_ledger_id
                    ,l.event_id
                    ,l.entity_id
                    ,l.accounting_date
                    ,nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
                    ,res.ccid
                    ,res.entered_currency_code
                    ,res.exchange_date
                    ,res.exchange_rate
                    ,res.exchange_rate_type
                    ,ROUND(res.entered_amt_dr /(nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision)))+l_rounding_offset)*(nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision)))
		    ,ROUND(res.entered_amt_cr /(nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision)))+l_rounding_offset)*(nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision)))
                    --,ROUND(res.entered_amt_dr /(nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision)))+l_rounding_offset)*(nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision)))
                    ,ROUND(res.accounted_amt_dr /l_mau+l_rounding_offset)*l_mau
		    ,ROUND(res.accounted_amt_cr /l_mau+l_rounding_offset)*l_mau
                    --,ROUND(res.accounted_amt_dr /l_mau+l_rounding_offset)*l_mau
                    ,res.entered_amt_dr
		    ,res.entered_amt_cr
                    --,res.entered_amt_dr
		    ,res.accounted_amt_dr
                    ,res.accounted_amt_cr
                    --,res.accounted_amt_dr
                    ,res.bal_seg_val
                    ,decode(g_mgt_seg_column_name
                            ,'SEGMENT1', ccid.segment1, 'SEGMENT2', ccid.segment2
                            ,'SEGMENT3', ccid.segment3, 'SEGMENT4', ccid.segment4
                            ,'SEGMENT5', ccid.segment5, 'SEGMENT6', ccid.segment6
                            ,'SEGMENT7', ccid.segment7, 'SEGMENT8', ccid.segment8
                            ,'SEGMENT9', ccid.segment9, 'SEGMENT10', ccid.segment10
                            ,'SEGMENT11', ccid.segment11, 'SEGMENT12', ccid.segment12
                            ,'SEGMENT13', ccid.segment13, 'SEGMENT14', ccid.segment14
                            ,'SEGMENT15', ccid.segment15, 'SEGMENT16', ccid.segment16
                            ,'SEGMENT17', ccid.segment17, 'SEGMENT18', ccid.segment18
                            ,'SEGMENT19', ccid.segment19, 'SEGMENT20', ccid.segment20
                            ,'SEGMENT21', ccid.segment21, 'SEGMENT22', ccid.segment22
                            ,'SEGMENT23', ccid.segment23, 'SEGMENT24', ccid.segment24
                            ,'SEGMENT25', ccid.segment25, 'SEGMENT26', ccid.segment26
                            ,'SEGMENT27', ccid.segment27, 'SEGMENT28', ccid.segment28
                            ,'SEGMENT29', ccid.segment29, 'SEGMENT30', ccid.segment30, NULL)
                    ,decode(res.balancing_type, C_FUN_INTRA, C_LINE_TYPE_IC_BAL_INTRA,
                                                C_LINE_TYPE_IC_BAL_INTER)
                    ,l.balance_type_code
            FROM     fun_bal_results_gt     res
                    ,xla_validation_lines_gt l
                    ,gl_code_combinations   ccid
                    ,fnd_currencies fcu
            WHERE   l.ae_line_num           = l.max_ae_line_num
	      AND   l.balancing_line_type NOT IN (C_LINE_TYPE_IC_BAL_INTRA, C_LINE_TYPE_IC_BAL_INTER)
              AND   l.ae_header_id          = res.group_id * -1
              AND   ccid.code_combination_id= res.ccid
              AND   res.entered_currency_code = fcu.currency_code
	      AND   res.group_id < 0;



    l_count := SQL%ROWCOUNT;
    g_new_line_count := g_new_line_count + l_count;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# reversal rows created by intercompany API  = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;


  END IF;

  --
  -- Mark error entries
  --
  IF (l_err_count>0) THEN
    /* Commented out for bug 7128871
       Exhausted Undo Tablespace when a single header has many lines.

    FORALL j IN 1..l_err_count
      UPDATE /*+ INDEX (XLA_VALIDATION_LINES_GT,XLA_VALIDATION_LINES_GT_N2)
             XLA_VALIDATION_LINES_GT
         SET balancing_line_type = C_LINE_TYPE_COMPLETE
       WHERE ae_header_id = l_err_hdr_ids(j); */

    --
    -- Bug 7128871
    --   Retrieve distinct ae header ids not to update redundant lines.
    --

    FOR i IN 1..l_err_count LOOP
      IF NOT l_distinct_hdr_ids.EXISTS(l_err_hdr_ids(i)) THEN
         l_distinct_hdr_ids(l_err_hdr_ids(i)) := l_err_hdr_ids(i);
      END IF;
    END LOOP;
    --
    -- Bug 7128871
    --   Update xla_validation_lines_gt for distinct ae header ids.
    --   As indices of l_dinstinct_hdr_ids are not consecutive,
    --   need to use "INDICES OF".
    --
    FORALL i IN INDICES OF l_distinct_hdr_ids
      UPDATE  /*+ INDEX (XLA_VALIDATION_LINES_GT,XLA_VALIDATION_LINES_GT_N2)
*/ XLA_VALIDATION_LINES_GT
         SET balancing_line_type = C_LINE_TYPE_COMPLETE
       WHERE ae_header_id = l_distinct_hdr_ids(i);

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# rows updated with C_LINE_TYPE_COMPLETE: '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function balance_by_intercompany',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;


EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_bal%ISOPEN) THEN
    CLOSE c_bal;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_bal%ISOPEN) THEN
    CLOSE c_bal;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.balance_by_intercompany');
END;
--=============================================================================
--
-- Name: populate_missing_ccid
-- Description: This function will call FND routine to create missing CCID for
--              those entries created by the balancing routines.
-- Result:
--      0 - all missing CCID are created successfully
--      1 - error is encounted when calling the FND routine to create CCID
--
--=============================================================================
PROCEDURE populate_missing_ccid
  (p_err_count                  IN OUT NOCOPY INTEGER
  ,p_err_hdr_ids                IN OUT NOCOPY t_array_int)
IS
  l_seg                         FND_FLEX_EXT.SegmentArray;
  l_result                      INTEGER;
  l_ccids                       t_array_int;
  l_reference3s                 t_array_varchar30;
  l_num_segments                INTEGER;
  l_counter                     INTEGER;
  i                             INTEGER := 1;
  j                             INTEGER;

  l_bal_type_codes              t_array_varchar30;
  l_bal_seg_values              t_array_varchar30;
  l_mgt_seg_values              t_array_varchar30;
  l_bal_seg_number              INTEGER;
  l_mgt_seg_number              INTEGER;

  l_log_module                  VARCHAR2(240);

  CURSOR c_ccid IS
    SELECT t.bal_seg_value
          ,t.balance_type_code       -- 4458381
          ,min(t.accounting_date) accounting_date
      FROM xla_validation_lines_gt t
     WHERE balancing_line_type IN (C_LINE_TYPE_XLA_BALANCING
                                  ,C_LINE_TYPE_ENC_BALANCING)
       AND t.code_combination_id IS NULL
       AND ((g_res_encumb_ccid IS NOT NULL AND t.balance_type_code = 'E') OR
            (g_sla_entered_cur_bal_sus_ccid IS NOT NULL AND t.balance_type_code = 'A'))
     GROUP BY  t.bal_seg_value, t.balance_type_code;

  CURSOR c_errors IS
    SELECT entity_id
          ,event_id
          ,ae_header_id
      FROM xla_validation_lines_gt
     WHERE balancing_line_type IN (C_LINE_TYPE_XLA_BALANCING
                                  ,C_LINE_TYPE_ENC_BALANCING)
       AND code_combination_id < 0
     GROUP BY entity_id, event_id, ae_header_id;

  CURSOR c_seg_number (p_seg_col_name VARCHAR2, p_coa_id INTEGER) IS
    SELECT      display_order
    FROM        (SELECT ROWNUM display_order, application_column_name
                 FROM ( SELECT application_column_name
                        FROM   FND_ID_FLEX_SEGMENTS_VL
                        WHERE  ID_FLEX_NUM    = p_coa_id
                        AND    ID_FLEX_CODE   = 'GL#'
                        AND    APPLICATION_ID = 101
                        order by decode(enabled_flag, 'Y', 1, 'N', 2), segment_num))
    WHERE       application_column_name = p_seg_col_name;

  CURSOR c_ref3 (p_ccid INTEGER) IS
    SELECT reference3
      FROM gl_code_combinations
     WHERE code_combination_id = p_ccid;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_missing_ccid';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function populate_missing_ccid',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_result := 0;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - populate missing ccid',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_ccid IN c_ccid LOOP

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - populate missing ccid: bal_seg_value = '||l_ccid.bal_seg_value||
                        ', balance_type_code = '||l_ccid.balance_type_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    l_bal_seg_values(i) := l_ccid.bal_seg_value;
    l_bal_type_codes(i) := l_ccid.balance_type_code;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'g_ledger_coa_id = '||g_ledger_coa_id||
                        ', balance_type_code = '||l_ccid.balance_type_code||
                        ', g_res_encumb_ccid = '||g_res_encumb_ccid||
                        ', g_sla_entered_cur_bal_sus_ccid = '||g_sla_entered_cur_bal_sus_ccid,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF ( FND_FLEX_EXT.get_segments(
                application_short_name  => 'SQLGL',
                key_flex_code           => 'GL#',
                structure_number        => g_ledger_coa_id,
                combination_id          => CASE l_ccid.balance_type_code  -- 4458381
                                                WHEN 'E' THEN g_res_encumb_ccid
                                                ELSE g_sla_entered_cur_bal_sus_ccid END,
                n_segments              => l_num_segments,
                segments                => l_seg) = FALSE) THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'FND_FLEX_EXT.get_segments failed',
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      l_ccids(i)          := -1;
      l_mgt_seg_values(i) := NULL;
      l_result            := 1;
    ELSE
      OPEN c_seg_number(g_bal_seg_column_name, g_ledger_coa_id);
      FETCH c_seg_number INTO l_bal_seg_number;
      CLOSE c_seg_number;

      l_seg(l_bal_seg_number) := l_ccid.bal_seg_value;
      IF (FND_FLEX_EXT.get_combination_id(
                        application_short_name       => 'SQLGL',
                        key_flex_code                => 'GL#',
                        structure_number             => g_ledger_coa_id,
                        validation_date              => l_ccid.accounting_date,
                        n_segments                   => l_num_segments,
                        segments                     => l_seg,
                        combination_id               => l_ccids(i)) = FALSE) THEN
        IF (C_LEVEL_ERROR >= g_log_level) THEN
          trace(p_msg    => 'XLA_INTERNAL_ERROR : Cannot get valid Code Combination ID',
                p_module => l_log_module,
                p_level  => C_LEVEL_ERROR);
          trace(p_msg    => 'Error: '||fnd_message.get,
                p_module => l_log_module,
                p_level  => C_LEVEL_ERROR);
          trace(p_msg    => 'accounting_date = '||l_ccid.accounting_date,
                p_module => l_log_module,
                p_level  => C_LEVEL_ERROR);
          trace(p_msg    => 'num_segs = '||l_num_segments,
                p_module => l_log_module,
                p_level  => C_LEVEL_ERROR);
          FOR i IN 1..l_num_segments LOOP
            trace(p_msg    => 'seg('||i||') = '||l_seg(i),
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
          END LOOP;
        END IF;

        l_ccids(i)          := -1;
        l_mgt_seg_values(i) := NULL;
        l_reference3s(i)    := 'N';
        l_result            := 1;
      ELSE
        IF (g_mgt_seg_column_name IS NULL) THEN
          l_mgt_seg_values(i) := NULL;
        ELSIF (g_mgt_seg_column_name = g_bal_seg_column_name) THEN
          l_mgt_seg_values(i) := l_ccid.bal_seg_value;
        ELSE
          OPEN c_seg_number(g_mgt_seg_column_name, g_ledger_coa_id);
          FETCH c_seg_number INTO l_mgt_seg_number;
          CLOSE c_seg_number;

          l_mgt_seg_values(i) := l_seg(l_mgt_seg_number);
        END IF;

        OPEN c_ref3(l_ccids(i));
        FETCH c_ref3 INTO l_reference3s(i);
        CLOSE c_ref3;
      END IF;
    END IF;

    i := i+1;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - populate missing ccid: i = '||i,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  j := i-1;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'j = '||j,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR i IN 1..j LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'l_ccid = '||l_ccids(i),
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'l_mgt_seg_values = '||l_mgt_seg_values(i),
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'l_bal_seg_values = '||l_bal_seg_values(i),
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'l_bal_type_codes = '||l_bal_type_codes(i),
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;
  END LOOP;

  FORALL i IN 1..j
    UPDATE   xla_validation_lines_gt t
       SET   code_combination_id     = l_ccids(i)
            ,control_account_enabled_flag = l_reference3s(i)
            ,mgt_seg_value           = l_mgt_seg_values(i)
     WHERE   t.bal_seg_value         = l_bal_seg_values(i)
       AND   t.balance_type_code     = l_bal_type_codes(i) -- 4458381
       AND   t.code_combination_id   IS NULL;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# rows updated for filled for missing ccid = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (l_result = 1) THEN

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'BEGIN LOOP - fill in missing ccid error',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    FOR l_err IN c_errors LOOP

      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'LOOP - fill in missing ccid error: l_ae_header_id = '||l_err.ae_header_id,
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      g_err_count := g_err_count + 1;
      g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
      g_err_event_ids(g_err_count) := l_err.event_id;

      p_err_count := p_err_count + 1;
      p_err_hdr_ids(p_err_count) := l_err.ae_header_id;

      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTERNAL_ERROR'
                ,p_token_1              => 'MESSAGE'
                ,p_value_1              => 'Cannot get valid code combination id'
                ,p_token_2              => 'LOCATION'
                ,p_value_2              => 'XLA_JE_VALIDATION_PKG.populate_missing_ccid'
                ,p_entity_id            => l_err.entity_id
                ,p_event_id             => l_err.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_err.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
    END LOOP;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'END LOOP - fill in missing ccid error',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function populate_missing_ccid',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_ccid%ISOPEN) THEN
    CLOSE c_ccid;
  END IF;
  IF (c_seg_number%ISOPEN) THEN
    CLOSE c_seg_number;
  END IF;
  IF (c_errors%ISOPEN) THEN
    CLOSE c_errors;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_ccid%ISOPEN) THEN
    CLOSE c_ccid;
  END IF;
  IF (c_seg_number%ISOPEN) THEN
    CLOSE c_seg_number;
  END IF;
  IF (c_errors%ISOPEN) THEN
    CLOSE c_errors;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.populate_missing_ccid');
END;

--=============================================================================
--
-- Name: balance_by_entered_curr
-- Description: This function creates new entries to the xla temporary
--              balancing table that will balance the journal entry by entered
--              currency and balancing segment.  It will then determine the
--              ccid for the suspense account that will be used by the new
--              entries.  If the ccid is not already exists, it will call
--              the FND routine to generate a new CCID.
-- Return:
--      0 - completed successfully
--      1 - error is detected
--
--=============================================================================
PROCEDURE balance_by_entered_curr
IS
  l_count               INTEGER;

  l_bal_hdr_ids         t_array_int;
  l_bal_ent_currs       t_array_varchar30;
  l_bal_bal_segs        t_array_varchar30;
  l_bal_enc_ids         t_array_int;
  l_err_hdr_ids         t_array_int;
  l_err_count           INTEGER := 0;
  j                     INTEGER;
  l_log_module          VARCHAR2(240);
  l_rounding_offset     NUMBER;
  l_rounding_rule_code  VARCHAR2(30);
  l_mau                 NUMBER;

  l_already_bal_hdr_ids         t_array_int;            -- bug7210785
  l_already_bal_ent_currs       t_array_varchar30;      -- bug7210785


  CURSOR c_no_sus_ccid IS
    SELECT entity_id, event_id, ae_header_id, balance_type_code
      FROM xla_validation_lines_gt
     WHERE balancing_line_type = C_LINE_TYPE_XLA_BALANCING
       AND balance_type_code = 'A'
     GROUP BY entity_id, event_id, ae_header_id, balance_type_code;

BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.balance_by_entered_curr';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function balance_by_entered_curr',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_caller = C_CALLER_ACCT_PROGRAM) THEN
    l_mau:= xla_accounting_cache_pkg.GetValueNum(
                           p_source_code        => 'XLA_CURRENCY_MAU'
                         , p_target_ledger_id   => g_ledger_id);
    l_rounding_rule_code :=xla_accounting_cache_pkg.GetValueChar(
                           p_source_code        => 'XLA_ROUNDING_RULE_CODE'
                         , p_target_ledger_id   => g_ledger_id
                         );
  ELSE
    SELECT nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
          ,xlo.rounding_rule_code
    INTO   l_mau, l_rounding_rule_code
    FROM   xla_ledger_options     xlo
          ,gl_ledgers             gl
          ,fnd_currencies         fcu
    WHERE xlo.application_id = g_application_id
      AND xlo.ledger_id = g_trx_ledger_id
      AND gl.ledger_id = g_ledger_id
      AND fcu.currency_code = gl.currency_code;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'l_rounding_rule_code = '||l_rounding_rule_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF l_rounding_rule_code = 'NEAREST' THEN
    l_rounding_offset := 0;
  ELSIF l_rounding_rule_code = 'UP' THEN
    l_rounding_offset := .5-power(10, -30);
  ELSIF l_rounding_rule_code = 'DOWN' THEN
    l_rounding_offset := -(.5-power(10, -30));
  ELSE
    l_rounding_offset := 0;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'l_rounding_offset = '||l_rounding_offset,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  SELECT ae_header_id, bal_seg_value, entered_currency_code, encumbrance_type_id
    BULK COLLECT INTO l_bal_hdr_ids, l_bal_bal_segs, l_bal_ent_currs, l_bal_enc_ids
    FROM xla_validation_lines_gt t
   WHERE balance_type_code not in('E','B')
     AND entered_currency_code <> 'STAT'
     AND balancing_line_type in (C_LINE_TYPE_PROCESS,
                                 C_LINE_TYPE_IC_BAL_INTER,
                                 C_LINE_TYPE_IC_BAL_INTRA)
   GROUP BY ae_header_id, entered_currency_mau, bal_seg_value, entered_currency_code, encumbrance_type_id
  HAVING decode(l_rounding_rule_code
               ,'NEAREST' ,ROUND(sum(nvl(unrounded_entered_cr,0))/entered_currency_mau)
               ,'UP'      ,CEIL(sum(nvl(unrounded_entered_cr,0))/entered_currency_mau)
                          ,FLOOR(sum(nvl(unrounded_entered_cr,0))/entered_currency_mau)) <>
         decode(l_rounding_rule_code
               ,'NEAREST' ,ROUND(sum(nvl(unrounded_entered_dr,0))/entered_currency_mau)
               ,'UP'      ,CEIL(sum(nvl(unrounded_entered_dr,0))/entered_currency_mau)
                          ,FLOOR(sum(nvl(unrounded_entered_dr,0))/entered_currency_mau));


  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# un-balanced header(1) = '||l_bal_hdr_ids.COUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (l_bal_hdr_ids.COUNT > 0) THEN

	-- bug7210785 start:
	-- out of the headers that need entered currency balancing, find the headers that have
	-- currencies already balanced in entered amounts but not in accounted amounts.

                  SELECT DISTINCT xvl.ae_header_id, xvl.entered_currency_code
		  BULK COLLECT INTO l_already_bal_hdr_ids, l_already_bal_ent_currs
		  FROM xla_validation_lines_gt xvl
                  WHERE xvl.ae_header_id IN (

						  SELECT t.ae_header_id
						    FROM xla_validation_lines_gt t
						   WHERE t.balance_type_code not in('E','B')
						     AND t.entered_currency_code <> 'STAT'
						     AND t.balancing_line_type in (C_LINE_TYPE_PROCESS,
										 C_LINE_TYPE_IC_BAL_INTER,
										 C_LINE_TYPE_IC_BAL_INTRA)
						   GROUP BY t.ae_header_id, t.entered_currency_mau, t.bal_seg_value, t.entered_currency_code, t.encumbrance_type_id
						  HAVING decode(l_rounding_rule_code
							       ,'NEAREST' ,ROUND(sum(nvl(t.unrounded_entered_cr,0))/t.entered_currency_mau)
							       ,'UP'      ,CEIL(sum(nvl(t.unrounded_entered_cr,0))/t.entered_currency_mau)
									  ,FLOOR(sum(nvl(t.unrounded_entered_cr,0))/t.entered_currency_mau)) <>
							 decode(l_rounding_rule_code
							       ,'NEAREST' ,ROUND(sum(nvl(t.unrounded_entered_dr,0))/t.entered_currency_mau)
							       ,'UP'      ,CEIL(sum(nvl(t.unrounded_entered_dr,0))/t.entered_currency_mau)
									  ,FLOOR(sum(nvl(t.unrounded_entered_dr,0))/t.entered_currency_mau))
					    )
		  GROUP BY xvl.ae_header_id, xvl.entered_currency_mau, xvl.entered_currency_code
		  HAVING    decode(l_rounding_rule_code
				    ,'NEAREST' ,ROUND(sum(nvl(xvl.unrounded_entered_cr,0))/xvl.entered_currency_mau)
				    ,'UP'      ,CEIL(sum(nvl(xvl.unrounded_entered_cr,0))/xvl.entered_currency_mau)
			           ,FLOOR(sum(nvl(xvl.unrounded_entered_cr,0))/xvl.entered_currency_mau)) =
			     decode(l_rounding_rule_code
				    ,'NEAREST' ,ROUND(sum(nvl(xvl.unrounded_entered_dr,0))/xvl.entered_currency_mau)
                                    ,'UP'      ,CEIL(sum(nvl(xvl.unrounded_entered_dr,0))/xvl.entered_currency_mau)
                                    ,FLOOR(sum(nvl(xvl.unrounded_entered_dr,0))/xvl.entered_currency_mau))
                        AND  decode(l_rounding_rule_code
                                    ,'NEAREST' ,ROUND(sum(nvl(xvl.unrounded_accounted_cr,0))/l_mau)*l_mau
                                    ,'UP' ,CEIL(sum(nvl(xvl.unrounded_accounted_cr,0))/l_mau)*l_mau
                                    ,FLOOR(sum(nvl(xvl.unrounded_accounted_cr,0))/l_mau)*l_mau) <>
                             decode(l_rounding_rule_code
                                    ,'NEAREST' ,ROUND(sum(nvl(xvl.unrounded_accounted_dr,0))/l_mau)*l_mau
                                    ,'UP',CEIL(sum(nvl(xvl.unrounded_accounted_dr,0))/l_mau)*l_mau
                                    ,FLOOR(sum(nvl(xvl.unrounded_accounted_dr,0))/l_mau)*l_mau);


	      IF (C_LEVEL_EVENT >= g_log_level) THEN
		trace(p_msg    => '# un-balanced header(2) = '||l_already_bal_hdr_ids.COUNT,
			p_module => l_log_module,
			 p_level  => C_LEVEL_EVENT);
	      END IF;

	  -- bug7210785 end

    --
    -- Note: Debit and Credit line are created by using two insert statement
    -- to prevent the 0 amount lines from being created
    --
    /* bug 9127520 start, for all commented out then replaced below

    FORALL i IN 1..l_bal_hdr_ids.COUNT
          INSERT INTO xla_validation_lines_gt
            (balancing_line_type
            ,ledger_id
            ,ae_header_id
            ,max_ae_line_num
            ,max_displayed_line_number
            ,ae_line_num
            ,displayed_line_number
            ,event_id
            ,entity_id
            ,balance_type_code
            ,accounting_date
            ,entered_currency_code
            ,unrounded_entered_dr
            ,entered_dr
            ,unrounded_accounted_dr
            ,accounted_dr
            ,unrounded_entered_cr
            ,entered_cr
            ,unrounded_accounted_cr
            ,accounted_cr
            ,bal_seg_value
            ,code_combination_id
            ,encumbrance_type_id
            ,party_type_code
            ,party_id
            ,party_site_id
            ,error_flag)
      SELECT C_LINE_TYPE_XLA_BALANCING
            ,g_ledger_id
            ,l_bal_hdr_ids(i)
            ,t.max_ae_line_num
            ,t.max_displayed_line_number
            ,t.max_ae_line_num
            ,t.max_displayed_line_number
            ,t.event_id
            ,t.entity_id
            ,t.balance_type_code
            ,t.accounting_date
            ,t.entered_currency_code
            ,CASE
               WHEN sum(nvl(unrounded_accounted_cr,0)) <> 0 THEN
                    sum(nvl(unrounded_entered_cr,0))
             END
            ,CASE
               WHEN sum(nvl(unrounded_accounted_cr,0)) <> 0 THEN
                    decode(l_rounding_rule_code
                          ,'NEAREST'
                          ,ROUND(sum(nvl(unrounded_entered_cr,0))/t.entered_currency_mau)*t.entered_currency_mau
                          ,'UP'
                          ,CEIL(sum(nvl(unrounded_entered_cr,0))/t.entered_currency_mau)*t.entered_currency_mau
                          ,FLOOR(sum(nvl(unrounded_entered_cr,0))/t.entered_currency_mau)*t.entered_currency_mau)
             END
            ,CASE
               WHEN sum(nvl(unrounded_accounted_cr,0)) <> 0 THEN
                    sum(nvl(unrounded_accounted_cr,0))
             END
            ,CASE
               WHEN sum(nvl(unrounded_accounted_cr,0)) <> 0 THEN
                    decode(l_rounding_rule_code
                          ,'NEAREST'
                          ,ROUND(sum(nvl(unrounded_accounted_cr,0))/l_mau)*l_mau
                          ,'UP'
                          ,CEIL(sum(nvl(unrounded_accounted_cr,0))/l_mau)*l_mau
                          ,FLOOR(sum(nvl(unrounded_accounted_cr,0))/l_mau)*l_mau)
            END
           ,CASE
              WHEN sum(nvl(unrounded_accounted_dr,0)) <> 0 THEN
                   sum(nvl(unrounded_entered_dr,0))
            END  -- unrounded_entered_cr
           ,CASE
              WHEN sum(nvl(unrounded_accounted_dr,0)) <> 0 THEN
                   decode(l_rounding_rule_code
                         ,'NEAREST'
                         ,ROUND(sum(nvl(unrounded_entered_dr,0))/t.entered_currency_mau)*t.entered_currency_mau
                         ,'UP'
                         ,CEIL(sum(nvl(unrounded_entered_dr,0))/t.entered_currency_mau)*t.entered_currency_mau
                         ,FLOOR(sum(nvl(unrounded_entered_dr,0))/t.entered_currency_mau)*t.entered_currency_mau)
            END  -- entered_cr
           ,CASE
              WHEN sum(nvl(unrounded_accounted_dr,0)) <> 0 THEN
                   sum(nvl(unrounded_accounted_dr,0))
            END  -- unrounded_accounted_cr
           ,CASE
              WHEN sum(nvl(unrounded_accounted_dr,0)) <> 0 THEN
                   decode(l_rounding_rule_code
                         ,'NEAREST'
                         ,ROUND(sum(nvl(unrounded_accounted_dr,0))/l_mau)*l_mau
                         ,'UP'
                         ,CEIL(sum(nvl(unrounded_accounted_dr,0))/l_mau)*l_mau
                         ,FLOOR(sum(nvl(unrounded_accounted_dr,0))/l_mau)*l_mau)
            END  -- accounted_cr
           ,t.bal_seg_value
           ,-1
           ,t.encumbrance_type_id
           ,t.party_type_code
           ,t.party_id
           ,t.party_site_id
           ,NULL
       FROM xla_validation_lines_gt        t
      WHERE ae_header_id = l_bal_hdr_ids(i)
        AND entered_currency_code = l_bal_ent_currs(i)
        AND bal_seg_value = l_bal_bal_segs(i)
        AND NVL(encumbrance_type_id,-99) = NVL(l_bal_enc_ids(i),-99)
        AND balancing_line_type IN (C_LINE_TYPE_PROCESS
                                   ,C_LINE_TYPE_IC_BAL_INTER
                                   ,C_LINE_TYPE_IC_BAL_INTRA)
      GROUP BY
            t.max_ae_line_num
           ,t.max_displayed_line_number
           ,t.event_id
           ,t.entity_id
           ,t.balance_type_code
           ,t.bal_seg_value
           ,t.entered_currency_code
           ,t.accounting_date
           ,t.entered_currency_mau
           ,t.encumbrance_type_id
           ,t.party_type_code
           ,t.party_id
           ,t.party_site_id
            --
            -- This has been added to combine two insert statements
            -- (for Debit and Credit) - Bug 5279912.
            -- Without this, credit and debit lines are merged.
            --
           ,DECODE(t.unrounded_entered_dr,NULL,'CR','DR')
     HAVING sum(nvl(unrounded_accounted_cr,0)) <> 0
         OR sum(nvl(unrounded_accounted_dr,0)) <> 0; */


	FORALL i IN 1..l_bal_hdr_ids.COUNT
          INSERT INTO xla_validation_lines_gt
            (balancing_line_type
            ,ledger_id
            ,ae_header_id
            ,max_ae_line_num
            ,max_displayed_line_number
            ,ae_line_num
            ,displayed_line_number
            ,event_id
            ,entity_id
            ,balance_type_code
            ,accounting_date
            ,entered_currency_code
            ,unrounded_entered_dr
            ,entered_dr
            ,unrounded_accounted_dr
            ,accounted_dr
            ,unrounded_entered_cr
            ,entered_cr
            ,unrounded_accounted_cr
            ,accounted_cr
            ,bal_seg_value
            ,code_combination_id
            ,encumbrance_type_id
            ,party_type_code
            ,party_id
            ,party_site_id
            ,error_flag)
      SELECT C_LINE_TYPE_XLA_BALANCING
            ,g_ledger_id
            ,l_bal_hdr_ids(i)
            ,t.max_ae_line_num
            ,t.max_displayed_line_number
            ,t.max_ae_line_num
            ,t.max_displayed_line_number
            ,t.event_id
            ,t.entity_id
            ,t.balance_type_code
            ,t.accounting_date
            ,t.entered_currency_code
            ,CASE
               WHEN sum(nvl(unrounded_entered_cr,0)) <> 0 or sum(nvl(unrounded_accounted_cr,0)) <> 0 THEN
                    sum(nvl(unrounded_entered_cr,0))
             END
            ,CASE
               WHEN sum(nvl(unrounded_entered_cr,0)) <> 0 or sum(nvl(unrounded_accounted_cr,0)) <> 0 THEN
                    decode(l_rounding_rule_code
                          ,'NEAREST'
                          ,ROUND(sum(nvl(unrounded_entered_cr,0))/t.entered_currency_mau)*t.entered_currency_mau
                          ,'UP'
                          ,CEIL(sum(nvl(unrounded_entered_cr,0))/t.entered_currency_mau)*t.entered_currency_mau
                          ,FLOOR(sum(nvl(unrounded_entered_cr,0))/t.entered_currency_mau)*t.entered_currency_mau)
             END
            ,CASE
               WHEN sum(nvl(unrounded_entered_cr,0)) <> 0 or sum(nvl(unrounded_accounted_cr,0)) <> 0 THEN
                    sum(nvl(unrounded_accounted_cr,0))
             END
            ,CASE
               WHEN sum(nvl(unrounded_entered_cr,0)) <> 0 or sum(nvl(unrounded_accounted_cr,0)) <> 0 THEN
                    decode(l_rounding_rule_code
                          ,'NEAREST'
                          ,ROUND(sum(nvl(unrounded_accounted_cr,0))/l_mau)*l_mau
                          ,'UP'
                          ,CEIL(sum(nvl(unrounded_accounted_cr,0))/l_mau)*l_mau
                          ,FLOOR(sum(nvl(unrounded_accounted_cr,0))/l_mau)*l_mau)
            END
           ,CASE
              WHEN sum(nvl(unrounded_entered_dr,0)) <> 0 or sum(nvl(unrounded_accounted_dr,0)) <> 0 THEN
                   sum(nvl(unrounded_entered_dr,0))
            END  -- unrounded_entered_cr
           ,CASE
              WHEN sum(nvl(unrounded_entered_dr,0)) <> 0 or sum(nvl(unrounded_accounted_dr,0)) <> 0 THEN
                   decode(l_rounding_rule_code
                         ,'NEAREST'
                         ,ROUND(sum(nvl(unrounded_entered_dr,0))/t.entered_currency_mau)*t.entered_currency_mau
                         ,'UP'
                         ,CEIL(sum(nvl(unrounded_entered_dr,0))/t.entered_currency_mau)*t.entered_currency_mau
                         ,FLOOR(sum(nvl(unrounded_entered_dr,0))/t.entered_currency_mau)*t.entered_currency_mau)
            END  -- entered_cr
           ,CASE
              WHEN sum(nvl(unrounded_entered_dr,0)) <> 0 or sum(nvl(unrounded_accounted_dr,0)) <> 0 THEN
                   sum(nvl(unrounded_accounted_dr,0))
            END  -- unrounded_accounted_cr
           ,CASE
              WHEN sum(nvl(unrounded_entered_dr,0)) <> 0 or sum(nvl(unrounded_accounted_dr,0)) <> 0 THEN
                   decode(l_rounding_rule_code
                         ,'NEAREST'
                         ,ROUND(sum(nvl(unrounded_accounted_dr,0))/l_mau)*l_mau
                         ,'UP'
                         ,CEIL(sum(nvl(unrounded_accounted_dr,0))/l_mau)*l_mau
                         ,FLOOR(sum(nvl(unrounded_accounted_dr,0))/l_mau)*l_mau)
            END  -- accounted_cr
           ,t.bal_seg_value
           ,-1
           ,t.encumbrance_type_id
           ,t.party_type_code
           ,t.party_id
           ,t.party_site_id
           ,NULL
       FROM xla_validation_lines_gt        t
      WHERE ae_header_id = l_bal_hdr_ids(i)
        AND entered_currency_code = l_bal_ent_currs(i)
        AND bal_seg_value = l_bal_bal_segs(i)
        AND NVL(encumbrance_type_id,-99) = NVL(l_bal_enc_ids(i),-99)
        AND balancing_line_type IN (C_LINE_TYPE_PROCESS
                                   ,C_LINE_TYPE_IC_BAL_INTER
                                   ,C_LINE_TYPE_IC_BAL_INTRA)
      GROUP BY
            t.max_ae_line_num
           ,t.max_displayed_line_number
           ,t.event_id
           ,t.entity_id
           ,t.balance_type_code
           ,t.bal_seg_value
           ,t.entered_currency_code
           ,t.accounting_date
           ,t.entered_currency_mau
           ,t.encumbrance_type_id
           ,t.party_type_code
           ,t.party_id
           ,t.party_site_id
            --
            -- This has been added to combine two insert statements
            -- (for Debit and Credit) - Bug 5279912.
            -- Without this, credit and debit lines are merged.
            --
           ,DECODE(t.unrounded_entered_dr,NULL,'CR','DR')
	HAVING sum(nvl(unrounded_accounted_cr,0)) <> 0
         OR sum(nvl(unrounded_accounted_dr,0)) <> 0
	 OR sum(nvl(unrounded_entered_dr,0)) <> 0
	 OR sum(nvl(unrounded_entered_cr,0)) <> 0;

      -- bug 9127520 end



    l_count := SQL%ROWCOUNT;
    g_new_line_count := g_new_line_count + l_count;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# balancing rows created(1) = '||l_count,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;


	-- bug7210785 start

	IF (l_already_bal_hdr_ids.COUNT > 0) THEN

        FORALL i IN 1..l_already_bal_hdr_ids.COUNT
          INSERT INTO xla_validation_lines_gt
            (balancing_line_type
            ,ledger_id
            ,ae_header_id
            ,max_ae_line_num
            ,max_displayed_line_number
            ,ae_line_num
            ,displayed_line_number
            ,event_id
            ,entity_id
            ,balance_type_code
            ,accounting_date
            ,entered_currency_code
            ,entered_dr
            ,entered_cr
            ,accounted_dr
            ,accounted_cr
            ,unrounded_entered_dr
            ,unrounded_entered_cr
            ,unrounded_accounted_dr
            ,unrounded_accounted_cr
            ,bal_seg_value
            ,code_combination_id
            ,encumbrance_type_id
            ,party_type_code
            ,party_id
            ,party_site_id
            ,error_flag)
      SELECT C_LINE_TYPE_XLA_BALANCING
            ,g_ledger_id
            ,l_already_bal_hdr_ids(i)
            ,t.max_ae_line_num
            ,t.max_displayed_line_number
            ,t.max_ae_line_num
            ,t.max_displayed_line_number
            ,t.event_id
            ,t.entity_id
            ,t.balance_type_code
            ,t.accounting_date
            ,t.entered_currency_code
            ,t.entered_cr
            ,t.entered_dr
            ,t.accounted_cr
            ,t.accounted_dr
            ,t.unrounded_entered_cr
            ,t.unrounded_entered_dr
            ,t.unrounded_accounted_cr
            ,t.unrounded_accounted_dr
            ,t.bal_seg_value
            ,-1
            ,t.encumbrance_type_id
            ,t.party_type_code
            ,t.party_id
            ,t.party_site_id
            ,NULL
       FROM xla_validation_lines_gt  t
      WHERE t.ae_header_id = l_already_bal_hdr_ids(i)
        AND t.entered_currency_code = l_already_bal_ent_currs(i)
        AND t.balancing_line_type IN (C_LINE_TYPE_PROCESS
                                   ,C_LINE_TYPE_IC_BAL_INTER
                                   ,C_LINE_TYPE_IC_BAL_INTRA);


	l_count := SQL%ROWCOUNT;
	g_new_line_count := g_new_line_count + l_count;

	IF (C_LEVEL_EVENT >= g_log_level) THEN
		trace(p_msg    => '# balancing rows created(2) = '||l_count,
		      p_module => l_log_module,
                      p_level  => C_LEVEL_EVENT);
	END IF;

	END IF;

	-- bug7210785 end




    -- Validate the suspense account is defined if balancing should be created for
    -- balancing entered currency and balancing segments
    --
    IF (g_sla_entered_cur_bal_sus_ccid IS NULL) THEN

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => 'BEGIN LOOP - no suspense ccid',
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;

      FOR l_no_sus_ccid IN c_no_sus_ccid LOOP

        IF (g_sla_entered_cur_bal_sus_ccid IS NULL AND l_no_sus_ccid.balance_type_code = 'A') THEN

          IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace(p_msg    => 'LOOP - no suspense ccid:'||
                              ' ae_header_id = '||l_no_sus_ccid.ae_header_id||
                              ',balance_type_code = '||l_no_sus_ccid.balance_type_code,
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
          END IF;

          g_err_count := g_err_count + 1;
          g_err_hdr_ids(g_err_count) := l_no_sus_ccid.ae_header_id;
          g_err_event_ids(g_err_count) := l_no_sus_ccid.event_id;

          l_err_count := l_err_count + 1;
          l_err_hdr_ids(l_err_count) := l_no_sus_ccid.ae_header_id;

          IF (l_no_sus_ccid.balance_type_code = 'A') THEN
            xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_AP_ENT_BAL_NO_SUS_CCID'
                ,p_token_1              => 'LEDGER_NAME'
                ,p_value_1              => g_ledger_name
                ,p_entity_id            => l_no_sus_ccid.entity_id
                ,p_event_id             => l_no_sus_ccid.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_no_sus_ccid.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
          END IF;
        END IF;
      END LOOP;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => 'END LOOP - no suspense ccid',
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;

    END IF;

    UPDATE  xla_validation_lines_gt t
       SET (code_combination_id, control_account_enabled_flag, mgt_seg_value) = (
           SELECT nc.code_combination_id
                 ,nc.reference3
                 ,decode(g_mgt_seg_column_name, g_bal_seg_column_name, t.bal_seg_value,
                         'SEGMENT1', sc.segment1, 'SEGMENT2', sc.segment2,
                         'SEGMENT3', sc.segment3, 'SEGMENT4', sc.segment4,
                         'SEGMENT5', sc.segment5, 'SEGMENT6', sc.segment6,
                         'SEGMENT7', sc.segment7, 'SEGMENT8', sc.segment8,
                         'SEGMENT9', sc.segment9, 'SEGMENT10', sc.segment10,
                         'SEGMENT11', sc.segment11, 'SEGMENT12', sc.segment12,
                         'SEGMENT13', sc.segment13, 'SEGMENT14', sc.segment14,
                         'SEGMENT15', sc.segment15, 'SEGMENT16', sc.segment16,
                         'SEGMENT17', sc.segment17, 'SEGMENT18', sc.segment18,
                         'SEGMENT19', sc.segment19, 'SEGMENT20', sc.segment20,
                         'SEGMENT21', sc.segment21, 'SEGMENT22', sc.segment22,
                         'SEGMENT23', sc.segment23, 'SEGMENT24', sc.segment24,
                         'SEGMENT25', sc.segment25, 'SEGMENT26', sc.segment26,
                         'SEGMENT27', sc.segment27, 'SEGMENT28', sc.segment28,
                         'SEGMENT29', sc.segment29, 'SEGMENT30', sc.segment30, NULL)
             FROM gl_code_combinations nc,
                  gl_code_combinations sc
            WHERE nvl(nc.segment1,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT1',
                                                   t.bal_seg_value,nvl(sc.segment1,C_CHAR))
              AND nvl(nc.segment2,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT2',
                                                   t.bal_seg_value,nvl(sc.segment2,C_CHAR))
              AND nvl(nc.segment3,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT3',
                                                   t.bal_seg_value,nvl(sc.segment3,C_CHAR))
              AND nvl(nc.segment4,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT4',
                                                   t.bal_seg_value,nvl(sc.segment4,C_CHAR))
              AND nvl(nc.segment5,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT5',
                                                   t.bal_seg_value,nvl(sc.segment5,C_CHAR))
              AND nvl(nc.segment6,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT6',
                                                   t.bal_seg_value,nvl(sc.segment6,C_CHAR))
              AND nvl(nc.segment7,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT7',
                                                   t.bal_seg_value,nvl(sc.segment7,C_CHAR))
              AND nvl(nc.segment8,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT8',
                                                   t.bal_seg_value,nvl(sc.segment8,C_CHAR))
              AND nvl(nc.segment9,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT9',
                                                   t.bal_seg_value,nvl(sc.segment9,C_CHAR))
              AND nvl(nc.segment10,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT10',
                                                   t.bal_seg_value,nvl(sc.segment10,C_CHAR))
              AND nvl(nc.segment11,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT11',
                                                   t.bal_seg_value,nvl(sc.segment11,C_CHAR))
              AND nvl(nc.segment12,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT12',
                                                   t.bal_seg_value,nvl(sc.segment12,C_CHAR))
              AND nvl(nc.segment13,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT13',
                                                   t.bal_seg_value,nvl(sc.segment13,C_CHAR))
              AND nvl(nc.segment14,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT14',
                                                   t.bal_seg_value,nvl(sc.segment14,C_CHAR))
              AND nvl(nc.segment15,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT15',
                                                   t.bal_seg_value,nvl(sc.segment15,C_CHAR))
              AND nvl(nc.segment16,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT16',
                                                   t.bal_seg_value,nvl(sc.segment16,C_CHAR))
              AND nvl(nc.segment17,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT17',
                                                   t.bal_seg_value,nvl(sc.segment17,C_CHAR))
              AND nvl(nc.segment18,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT18',
                                                   t.bal_seg_value,nvl(sc.segment18,C_CHAR))
              AND nvl(nc.segment19,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT19',
                                                   t.bal_seg_value,nvl(sc.segment19,C_CHAR))
              AND nvl(nc.segment20,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT20',
                                                   t.bal_seg_value,nvl(sc.segment20,C_CHAR))
              AND nvl(nc.segment21,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT21',
                                                   t.bal_seg_value,nvl(sc.segment21,C_CHAR))
              AND nvl(nc.segment22,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT22',
                                                   t.bal_seg_value,nvl(sc.segment22,C_CHAR))
              AND nvl(nc.segment23,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT23',
                                                   t.bal_seg_value,nvl(sc.segment23,C_CHAR))
              AND nvl(nc.segment24,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT24',
                                                   t.bal_seg_value,nvl(sc.segment24,C_CHAR))
              AND nvl(nc.segment25,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT25',
                                                   t.bal_seg_value,nvl(sc.segment25,C_CHAR))
              AND nvl(nc.segment26,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT26',
                                                   t.bal_seg_value,nvl(sc.segment26,C_CHAR))
              AND nvl(nc.segment27,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT27',
                                                   t.bal_seg_value,nvl(sc.segment27,C_CHAR))
              AND nvl(nc.segment28,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT28',
                                                   t.bal_seg_value,nvl(sc.segment28,C_CHAR))
              AND nvl(nc.segment29,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT29',
                                                   t.bal_seg_value,nvl(sc.segment29,C_CHAR))
              AND nvl(nc.segment30,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT30',
                                                   t.bal_seg_value,nvl(sc.segment30,C_CHAR))
              AND nc.chart_of_accounts_id  = sc.chart_of_accounts_id
              AND sc.code_combination_id   = g_sla_entered_cur_bal_sus_ccid)
     WHERE t.balancing_line_type = C_LINE_TYPE_XLA_BALANCING;

    populate_missing_ccid(l_err_count, l_err_hdr_ids);

    IF (l_err_count>0) THEN
      FORALL j IN 1..l_err_count
        UPDATE     xla_validation_lines_gt
           SET     balancing_line_type = C_LINE_TYPE_COMPLETE
         WHERE     ae_header_id = l_err_hdr_ids(j)
           AND     balancing_line_type = C_LINE_TYPE_PROCESS;
    END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function balance_by_entered_curr',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_no_sus_ccid%ISOPEN) THEN
    CLOSE c_no_sus_ccid;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_no_sus_ccid%ISOPEN) THEN
    CLOSE c_no_sus_ccid;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.balance_by_entered_curr');
END;


--=============================================================================
--
-- Name: balance_by_encumberance
-- Description: This function creates new entries to the xla temporary
--              balancing table that will balance the journal entry by
--              encumbrance entries
-- Return:
--      0 - completed successfully
--      1 - error is detected
--
--=============================================================================
PROCEDURE balance_by_encumberance
IS
  l_count               INTEGER;

  l_bal_hdr_ids         t_array_int;
  l_bal_ent_currs       t_array_varchar30;
  l_bal_bal_segs        t_array_varchar30;
  l_bal_enc_ids         t_array_int;
  l_err_hdr_ids         t_array_int;
  l_err_count           INTEGER := 0;
  j                     INTEGER;
  l_log_module          VARCHAR2(240);
  l_rounding_offset     NUMBER;
  l_rounding_rule_code  VARCHAR2(30);
  l_mau                 NUMBER;

  l_stmt                VARCHAR2(25000);  --8531035
  l_stmt2              VARCHAR2(5000);    --8531035


  CURSOR c_no_sus_ccid IS
    SELECT entity_id, event_id, ae_header_id, balance_type_code
      FROM xla_validation_lines_gt
     WHERE balancing_line_type = C_LINE_TYPE_ENC_BALANCING
     GROUP BY entity_id, event_id, ae_header_id, balance_type_code;

BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.balance_by_encumberance';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function balance_by_encumberance',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_caller = C_CALLER_ACCT_PROGRAM) THEN
    l_mau:= xla_accounting_cache_pkg.GetValueNum(
                           p_source_code        => 'XLA_CURRENCY_MAU'
                         , p_target_ledger_id   => g_ledger_id);
    l_rounding_rule_code :=xla_accounting_cache_pkg.GetValueChar(
                           p_source_code        => 'XLA_ROUNDING_RULE_CODE'
                         , p_target_ledger_id   => g_ledger_id
                         );
  ELSE
    SELECT nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
          ,xlo.rounding_rule_code
    INTO   l_mau, l_rounding_rule_code
    FROM   xla_ledger_options     xlo
          ,gl_ledgers             gl
          ,fnd_currencies         fcu
    WHERE xlo.application_id = g_application_id
      AND xlo.ledger_id = g_trx_ledger_id
      AND gl.ledger_id = g_ledger_id
      AND fcu.currency_code = gl.currency_code;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'l_rounding_rule_code = '||l_rounding_rule_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF l_rounding_rule_code = 'NEAREST' THEN
    l_rounding_offset := 0;
  ELSIF l_rounding_rule_code = 'UP' THEN
    l_rounding_offset := .5-power(10, -30);
  ELSIF l_rounding_rule_code = 'DOWN' THEN
    l_rounding_offset := -(.5-power(10, -30));
  ELSE
    l_rounding_offset := 0;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'l_rounding_offset = '||l_rounding_offset,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  SELECT ae_header_id, bal_seg_value, entered_currency_code, encumbrance_type_id
    BULK COLLECT INTO l_bal_hdr_ids, l_bal_bal_segs, l_bal_ent_currs, l_bal_enc_ids
    FROM xla_validation_lines_gt t
   WHERE balance_type_code = 'E'
     AND entered_currency_code <> 'STAT'
     AND balancing_line_type in (C_LINE_TYPE_PROCESS,
                                 C_LINE_TYPE_IC_BAL_INTER,
                                 C_LINE_TYPE_IC_BAL_INTRA)
   GROUP BY ae_header_id, entered_currency_mau, bal_seg_value, entered_currency_code, encumbrance_type_id
  HAVING (
         decode(l_rounding_rule_code
               ,'NEAREST' ,ROUND(sum(nvl(unrounded_entered_cr,0))/entered_currency_mau)
               ,'UP'      ,CEIL(sum(nvl(unrounded_entered_cr,0))/entered_currency_mau)
                          ,FLOOR(sum(nvl(unrounded_entered_cr,0))/entered_currency_mau)) <>
         decode(l_rounding_rule_code
               ,'NEAREST' ,ROUND(sum(nvl(unrounded_entered_dr,0))/entered_currency_mau)
               ,'UP'      ,CEIL(sum(nvl(unrounded_entered_dr,0))/entered_currency_mau)
                          ,FLOOR(sum(nvl(unrounded_entered_dr,0))/entered_currency_mau))
          )
	  OR
	   (
         decode(l_rounding_rule_code
               ,'NEAREST' ,ROUND(sum(nvl(unrounded_accounted_cr,0))/l_mau)
               ,'UP'      ,CEIL(sum(nvl(unrounded_accounted_cr,0))/l_mau)
                          ,FLOOR(sum(nvl(unrounded_accounted_cr,0))/l_mau)) <>
         decode(l_rounding_rule_code
               ,'NEAREST' ,ROUND(sum(nvl(unrounded_accounted_dr,0))/l_mau)
               ,'UP'      ,CEIL(sum(nvl(unrounded_accounted_dr,0))/l_mau)
                          ,FLOOR(sum(nvl(unrounded_accounted_dr,0))/l_mau))
          );

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# un-balanced header = '||l_bal_hdr_ids.COUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (l_bal_hdr_ids.COUNT > 0) THEN
    --
    -- Note: Debit and Credit line are created by using two insert statement
    -- to prevent the 0 amount lines from being created
    --
    FORALL i IN 1..l_bal_hdr_ids.COUNT
          INSERT INTO xla_validation_lines_gt
            (balancing_line_type
            ,ledger_id
            ,ae_header_id
            ,max_ae_line_num
            ,max_displayed_line_number
            ,ae_line_num
            ,displayed_line_number
            ,event_id
            ,entity_id
            ,balance_type_code
            ,accounting_date
            ,entered_currency_code
            ,unrounded_entered_dr
            ,entered_dr
            ,unrounded_accounted_dr
            ,accounted_dr
            ,unrounded_entered_cr
            ,entered_cr
            ,unrounded_accounted_cr
            ,accounted_cr
            ,bal_seg_value
            ,code_combination_id
            ,encumbrance_type_id
            ,party_type_code
            ,party_id
            ,party_site_id
            ,error_flag)
      SELECT C_LINE_TYPE_ENC_BALANCING
            ,g_ledger_id
            ,l_bal_hdr_ids(i)
            ,t.max_ae_line_num
            ,t.max_displayed_line_number
            ,t.max_ae_line_num
            ,t.max_displayed_line_number
            ,t.event_id
            ,t.entity_id
            ,t.balance_type_code
            ,t.accounting_date
            ,t.entered_currency_code
            ,CASE
               WHEN sum(nvl(unrounded_accounted_cr,0)) <> 0 THEN
                    sum(nvl(unrounded_entered_cr,0))
             END
            ,CASE
               WHEN sum(nvl(unrounded_accounted_cr,0)) <> 0 THEN
                    decode(l_rounding_rule_code
                          ,'NEAREST'
                          ,ROUND(sum(nvl(unrounded_entered_cr,0))/t.entered_currency_mau)*t.entered_currency_mau
                          ,'UP'
                          ,CEIL(sum(nvl(unrounded_entered_cr,0))/t.entered_currency_mau)*t.entered_currency_mau
                          ,FLOOR(sum(nvl(unrounded_entered_cr,0))/t.entered_currency_mau)*t.entered_currency_mau)
             END
            ,CASE
               WHEN sum(nvl(unrounded_accounted_cr,0)) <> 0 THEN
                    sum(nvl(unrounded_accounted_cr,0))
             END
            ,CASE
               WHEN sum(nvl(unrounded_accounted_cr,0)) <> 0 THEN
                    decode(l_rounding_rule_code
                          ,'NEAREST'
                          ,ROUND(sum(nvl(unrounded_accounted_cr,0))/l_mau)*l_mau
                          ,'UP'
                          ,CEIL(sum(nvl(unrounded_accounted_cr,0))/l_mau)*l_mau
                          ,FLOOR(sum(nvl(unrounded_accounted_cr,0))/l_mau)*l_mau)
            END
           ,CASE
              WHEN sum(nvl(unrounded_accounted_dr,0)) <> 0 THEN
                   sum(nvl(unrounded_entered_dr,0))
            END  -- unrounded_entered_cr
           ,CASE
              WHEN sum(nvl(unrounded_accounted_dr,0)) <> 0 THEN
                   decode(l_rounding_rule_code
                         ,'NEAREST'
                         ,ROUND(sum(nvl(unrounded_entered_dr,0))/t.entered_currency_mau)*t.entered_currency_mau
                         ,'UP'
                         ,CEIL(sum(nvl(unrounded_entered_dr,0))/t.entered_currency_mau)*t.entered_currency_mau
                         ,FLOOR(sum(nvl(unrounded_entered_dr,0))/t.entered_currency_mau)*t.entered_currency_mau)
            END  -- entered_cr
           ,CASE
              WHEN sum(nvl(unrounded_accounted_dr,0)) <> 0 THEN
                   sum(nvl(unrounded_accounted_dr,0))
            END  -- unrounded_accounted_cr
           ,CASE
              WHEN sum(nvl(unrounded_accounted_dr,0)) <> 0 THEN
                   decode(l_rounding_rule_code
                         ,'NEAREST'
                         ,ROUND(sum(nvl(unrounded_accounted_dr,0))/l_mau)*l_mau
                         ,'UP'
                         ,CEIL(sum(nvl(unrounded_accounted_dr,0))/l_mau)*l_mau
                         ,FLOOR(sum(nvl(unrounded_accounted_dr,0))/l_mau)*l_mau)
            END  -- accounted_cr
           ,t.bal_seg_value
           ,-1
           ,t.encumbrance_type_id
           ,t.party_type_code
           ,t.party_id
           ,t.party_site_id
           ,NULL
       FROM xla_validation_lines_gt        t
      WHERE ae_header_id = l_bal_hdr_ids(i)
        AND entered_currency_code = l_bal_ent_currs(i)
        AND bal_seg_value = l_bal_bal_segs(i)
        AND NVL(encumbrance_type_id,-99) = NVL(l_bal_enc_ids(i),-99)
        AND balancing_line_type IN (C_LINE_TYPE_PROCESS
                                   ,C_LINE_TYPE_IC_BAL_INTER
                                   ,C_LINE_TYPE_IC_BAL_INTRA)
      GROUP BY
            t.max_ae_line_num
           ,t.max_displayed_line_number
           ,t.event_id
           ,t.entity_id
           ,t.balance_type_code
           ,t.bal_seg_value
           ,t.entered_currency_code
           ,t.accounting_date
           ,t.entered_currency_mau
           ,t.encumbrance_type_id
           ,t.party_type_code
           ,t.party_id
           ,t.party_site_id
            --
            -- This has been added to combine two insert statements
            -- (for Debit and Credit) - Bug 5279912.
            -- Without this, credit and debit lines are merged.
            --
           ,DECODE(t.unrounded_entered_dr,NULL,'CR','DR')
     HAVING sum(nvl(unrounded_accounted_cr,0)) <> 0
         OR sum(nvl(unrounded_accounted_dr,0)) <> 0;

    l_count := SQL%ROWCOUNT;
    g_new_line_count := g_new_line_count + l_count;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# rows created = '||l_count,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    --
    -- Validate the suspense account is defined if balancing should be created for
    -- balancing entered currency and balancing segments
    --
    IF ( g_res_encumb_ccid IS NULL) THEN

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => 'BEGIN LOOP - no suspense ccid',
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;

      FOR l_no_sus_ccid IN c_no_sus_ccid LOOP

        IF  (g_res_encumb_ccid IS NULL AND l_no_sus_ccid.balance_type_code = 'E') THEN

          IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace(p_msg    => 'LOOP - no suspense ccid:'||
                              ' ae_header_id = '||l_no_sus_ccid.ae_header_id||
                              ',balance_type_code = '||l_no_sus_ccid.balance_type_code,
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
          END IF;

          g_err_count := g_err_count + 1;
          g_err_hdr_ids(g_err_count) := l_no_sus_ccid.ae_header_id;
          g_err_event_ids(g_err_count) := l_no_sus_ccid.event_id;

          l_err_count := l_err_count + 1;
          l_err_hdr_ids(l_err_count) := l_no_sus_ccid.ae_header_id;

          IF (l_no_sus_ccid.balance_type_code = 'E') THEN
            xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_AP_NO_RFE_CCID'
                ,p_token_1              => 'LEDGER_NAME'
                ,p_value_1              => g_ledger_name
                ,p_entity_id            => l_no_sus_ccid.entity_id
                ,p_event_id             => l_no_sus_ccid.event_id
                ,p_ledger_id            => g_ledger_id
                ,p_ae_header_id         => l_no_sus_ccid.ae_header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
          END IF;
        END IF;
      END LOOP;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => 'END LOOP - no suspense ccid',
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;

    END IF;

    /*UPDATE  xla_validation_lines_gt t
       SET (code_combination_id, control_account_enabled_flag, mgt_seg_value) = (
           SELECT nc.code_combination_id
                 ,nc.reference3
                 ,decode(g_mgt_seg_column_name, g_bal_seg_column_name, t.bal_seg_value,
                         'SEGMENT1', sc.segment1, 'SEGMENT2', sc.segment2,
                         'SEGMENT3', sc.segment3, 'SEGMENT4', sc.segment4,
                         'SEGMENT5', sc.segment5, 'SEGMENT6', sc.segment6,
                         'SEGMENT7', sc.segment7, 'SEGMENT8', sc.segment8,
                         'SEGMENT9', sc.segment9, 'SEGMENT10', sc.segment10,
                         'SEGMENT11', sc.segment11, 'SEGMENT12', sc.segment12,
                         'SEGMENT13', sc.segment13, 'SEGMENT14', sc.segment14,
                         'SEGMENT15', sc.segment15, 'SEGMENT16', sc.segment16,
                         'SEGMENT17', sc.segment17, 'SEGMENT18', sc.segment18,
                         'SEGMENT19', sc.segment19, 'SEGMENT20', sc.segment20,
                         'SEGMENT21', sc.segment21, 'SEGMENT22', sc.segment22,
                         'SEGMENT23', sc.segment23, 'SEGMENT24', sc.segment24,
                         'SEGMENT25', sc.segment25, 'SEGMENT26', sc.segment26,
                         'SEGMENT27', sc.segment27, 'SEGMENT28', sc.segment28,
                         'SEGMENT29', sc.segment29, 'SEGMENT30', sc.segment30, NULL)
             FROM gl_code_combinations nc,
                  gl_code_combinations sc
            WHERE nvl(nc.segment1,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT1',
                                                   t.bal_seg_value,nvl(sc.segment1,C_CHAR))
              AND nvl(nc.segment2,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT2',
                                                   t.bal_seg_value,nvl(sc.segment2,C_CHAR))
              AND nvl(nc.segment3,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT3',
                                                   t.bal_seg_value,nvl(sc.segment3,C_CHAR))
              AND nvl(nc.segment4,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT4',
                                                   t.bal_seg_value,nvl(sc.segment4,C_CHAR))
              AND nvl(nc.segment5,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT5',
                                                   t.bal_seg_value,nvl(sc.segment5,C_CHAR))
              AND nvl(nc.segment6,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT6',
                                                   t.bal_seg_value,nvl(sc.segment6,C_CHAR))
              AND nvl(nc.segment7,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT7',
                                                   t.bal_seg_value,nvl(sc.segment7,C_CHAR))
              AND nvl(nc.segment8,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT8',
                                                   t.bal_seg_value,nvl(sc.segment8,C_CHAR))
              AND nvl(nc.segment9,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT9',
                                                   t.bal_seg_value,nvl(sc.segment9,C_CHAR))
              AND nvl(nc.segment10,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT10',
                                                   t.bal_seg_value,nvl(sc.segment10,C_CHAR))
              AND nvl(nc.segment11,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT11',
                                                   t.bal_seg_value,nvl(sc.segment11,C_CHAR))
              AND nvl(nc.segment12,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT12',
                                                   t.bal_seg_value,nvl(sc.segment12,C_CHAR))
              AND nvl(nc.segment13,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT13',
                                                   t.bal_seg_value,nvl(sc.segment13,C_CHAR))
              AND nvl(nc.segment14,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT14',
                                                   t.bal_seg_value,nvl(sc.segment14,C_CHAR))
              AND nvl(nc.segment15,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT15',
                                                   t.bal_seg_value,nvl(sc.segment15,C_CHAR))
              AND nvl(nc.segment16,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT16',
                                                   t.bal_seg_value,nvl(sc.segment16,C_CHAR))
              AND nvl(nc.segment17,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT17',
                                                   t.bal_seg_value,nvl(sc.segment17,C_CHAR))
              AND nvl(nc.segment18,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT18',
                                                   t.bal_seg_value,nvl(sc.segment18,C_CHAR))
              AND nvl(nc.segment19,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT19',
                                                   t.bal_seg_value,nvl(sc.segment19,C_CHAR))
              AND nvl(nc.segment20,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT20',
                                                   t.bal_seg_value,nvl(sc.segment20,C_CHAR))
              AND nvl(nc.segment21,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT21',
                                                   t.bal_seg_value,nvl(sc.segment21,C_CHAR))
              AND nvl(nc.segment22,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT22',
                                                   t.bal_seg_value,nvl(sc.segment22,C_CHAR))
              AND nvl(nc.segment23,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT23',
                                                   t.bal_seg_value,nvl(sc.segment23,C_CHAR))
              AND nvl(nc.segment24,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT24',
                                                   t.bal_seg_value,nvl(sc.segment24,C_CHAR))
              AND nvl(nc.segment25,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT25',
                                                   t.bal_seg_value,nvl(sc.segment25,C_CHAR))
              AND nvl(nc.segment26,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT26',
                                                   t.bal_seg_value,nvl(sc.segment26,C_CHAR))
              AND nvl(nc.segment27,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT27',
                                                   t.bal_seg_value,nvl(sc.segment27,C_CHAR))
              AND nvl(nc.segment28,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT28',
                                                   t.bal_seg_value,nvl(sc.segment28,C_CHAR))
              AND nvl(nc.segment29,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT29',
                                                   t.bal_seg_value,nvl(sc.segment29,C_CHAR))
              AND nvl(nc.segment30,C_CHAR) = DECODE(g_bal_seg_column_name,'SEGMENT30',
                                                   t.bal_seg_value,nvl(sc.segment30,C_CHAR))
              AND nc.chart_of_accounts_id  = sc.chart_of_accounts_id
              AND sc.code_combination_id   = DECODE(t.balance_type_code, 'E'
                                                   ,g_res_encumb_ccid, g_sla_entered_cur_bal_sus_ccid))
     WHERE t.balancing_line_type = C_LINE_TYPE_ENC_BALANCING;*/



   --8531035 performance changes start, old query commented above

l_stmt := '
    UPDATE  xla_validation_lines_gt t
       SET (code_combination_id, control_account_enabled_flag, mgt_seg_value) = (
           SELECT nc.code_combination_id
                 ,nc.reference3
                 ,decode(:1, :2, t.bal_seg_value,
                         ''SEGMENT1'', sc.segment1, ''SEGMENT2'', sc.segment2,
                         ''SEGMENT3'', sc.segment3, ''SEGMENT4'', sc.segment4,
                         ''SEGMENT5'', sc.segment5, ''SEGMENT6'', sc.segment6,
                         ''SEGMENT7'', sc.segment7, ''SEGMENT8'', sc.segment8,
                         ''SEGMENT9'', sc.segment9, ''SEGMENT10'', sc.segment10,
                         ''SEGMENT11'', sc.segment11, ''SEGMENT12'', sc.segment12,
                         ''SEGMENT13'', sc.segment13, ''SEGMENT14'', sc.segment14,
                         ''SEGMENT15'', sc.segment15, ''SEGMENT16'', sc.segment16,
                         ''SEGMENT17'', sc.segment17, ''SEGMENT18'', sc.segment18,
                         ''SEGMENT19'', sc.segment19, ''SEGMENT20'', sc.segment20,
                         ''SEGMENT21'', sc.segment21, ''SEGMENT22'', sc.segment22,
                         ''SEGMENT23'', sc.segment23, ''SEGMENT24'', sc.segment24,
                         ''SEGMENT25'', sc.segment25, ''SEGMENT26'', sc.segment26,
                         ''SEGMENT27'', sc.segment27, ''SEGMENT28'', sc.segment28,
                         ''SEGMENT29'', sc.segment29, ''SEGMENT30'', sc.segment30, NULL)
             FROM gl_code_combinations nc,
                  gl_code_combinations sc
            WHERE ';


     l_stmt2 := ' ';

     FOR l_rec IN  (SELECT application_column_name
		    FROM   FND_ID_FLEX_SEGMENTS_VL
		    WHERE  id_flex_num    = g_ledger_coa_id
		    AND    id_flex_code   = 'GL#'
	            AND    application_id = 101
		    AND    enabled_flag = 'Y'
		    MINUS
		    SELECT g_bal_seg_column_name
		    FROM   FND_ID_FLEX_SEGMENTS_VL
		    WHERE  rownum=1
		    )
     LOOP
	l_stmt2 := l_stmt2 || 'nc.' || l_rec.application_column_name || ' = ' ||  'sc.' || l_rec.application_column_name || ' AND ';
     END LOOP;

     l_stmt2 := l_stmt2 || 'nc.' || g_bal_seg_column_name || ' = ' || 't.bal_seg_value' || '
                   AND nc.chart_of_accounts_id  = sc.chart_of_accounts_id
                   AND sc.code_combination_id   = DECODE(t.balance_type_code, ''E'',:3,:4 ))
                   WHERE t.balancing_line_type = :5';

     l_stmt := l_stmt || l_stmt2;



     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace(p_msg    => 'balance by encumberance dynamic sql' || l_stmt,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
     END IF;

     /* g_mgt_seg_column_name :1
        g_bal_seg_column_name :2
        g_res_encumb_ccid :3
        g_sla_entered_cur_bal_sus_ccid :4
        C_LINE_TYPE_ENC_BALANCING :5 */


     EXECUTE IMMEDIATE l_stmt USING     g_mgt_seg_column_name,
					g_bal_seg_column_name,
					g_res_encumb_ccid,
					g_sla_entered_cur_bal_sus_ccid,
					C_LINE_TYPE_ENC_BALANCING;



    --8531035 end

    populate_missing_ccid(l_err_count, l_err_hdr_ids);

    IF (l_err_count>0) THEN
      FORALL j IN 1..l_err_count
        UPDATE     xla_validation_lines_gt
           SET     balancing_line_type = C_LINE_TYPE_COMPLETE
         WHERE     ae_header_id = l_err_hdr_ids(j)
           AND     balancing_line_type = C_LINE_TYPE_PROCESS;
    END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function balance_by_encumberance',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_no_sus_ccid%ISOPEN) THEN
    CLOSE c_no_sus_ccid;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_no_sus_ccid%ISOPEN) THEN
    CLOSE c_no_sus_ccid;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.balance_by_encumberance');
END;


--=============================================================================
--
-- Name: populate_balancing_lines
-- Description: This function inserts the new entry lines created for the
--              balancing routines into the real xla_ae_lines table.
--
--=============================================================================
PROCEDURE populate_balancing_lines
IS
  CURSOR c_ledger_option IS
    SELECT transfer_to_gl_mode_code
      FROM xla_ledger_options
     WHERE ledger_id      = g_ledger_id
       AND application_id = g_application_id;

  l_line_num                   INTEGER;
  l_transfer_to_gl_mode_code   VARCHAR2(1);
  l_log_module                 VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_balancing_lines';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_balancing_lines',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'ledger_id      = '||g_ledger_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
    trace(p_msg    => 'application_id = '||g_application_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_ledger_option;
  FETCH c_ledger_option INTO l_transfer_to_gl_mode_code;
  CLOSE c_ledger_option;

  IF (l_transfer_to_gl_mode_code IS NULL) THEN
    l_transfer_to_gl_mode_code := 'D';
  END IF;



  INSERT INTO xla_ae_lines
        (ae_header_id
        ,ae_line_num
        ,displayed_line_number
        ,code_combination_id
        ,accounting_class_code
        ,application_id
        ,control_balance_flag
        ,analytical_balance_flag
        ,unrounded_accounted_cr
        ,unrounded_accounted_dr
        ,accounted_cr
        ,accounted_dr
	,description               -- added line for bug 6902085
        ,currency_code
        ,currency_conversion_date
        ,currency_conversion_type
        ,currency_conversion_rate
        ,unrounded_entered_cr
        ,unrounded_entered_dr
        ,entered_cr
        ,entered_dr
        ,gl_sl_link_table
        ,gl_sl_link_id
        ,gl_transfer_mode_code
        ,gain_or_loss_flag
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,program_update_date
        ,program_application_id
        ,program_id
        ,request_id
        ,ledger_id
        ,accounting_date
        ,encumbrance_type_id
        ,party_type_code
        ,party_id
        ,party_site_id
        ,mpa_accrual_entry_flag)  -- 4262811
    SELECT       l.ae_header_id
                ,max_ae_line_num +
                  ROW_NUMBER() over (partition by l.ae_header_id
                                     order by l.ae_line_num)
                ,max_displayed_line_number +
                  ROW_NUMBER() over (partition by l.ae_header_id
                                     order by l.displayed_line_number)
                ,NVL(l.code_combination_id,-1)
                ,CASE l.balancing_line_type
                      WHEN C_LINE_TYPE_IC_BAL_INTRA THEN C_ACCT_CLASS_INTRA
                      WHEN C_LINE_TYPE_IC_BAL_INTER THEN C_ACCT_CLASS_INTER
                      WHEN C_LINE_TYPE_RD_BALANCING THEN C_ACCT_CLASS_ROUNDING
                      WHEN C_LINE_TYPE_ENC_BALANCING THEN C_ACCT_CLASS_RFE -- 4458381
                      WHEN C_LINE_TYPE_ENC_BAL_ERROR THEN C_ACCT_CLASS_RFE -- 4458381
                      ELSE C_ACCT_CLASS_BALANCE END
                ,g_application_id
                -- control_balance_flag
                ,CASE l.balancing_line_type
                      WHEN C_LINE_TYPE_IC_BAL_INTRA THEN NULL
                      WHEN C_LINE_TYPE_IC_BAL_INTER THEN NULL
                      ELSE DECODE(NVL(ccid.reference3,'N'),'N',NULL, 'R', NULL,
                              DECODE(ccid.account_type, 'A', 'P'
                                                      , 'L', 'P'
                                                      , 'O', 'P'
                                                      , NULL)) END
                ,NULL
                ,l.unrounded_accounted_cr
                ,l.unrounded_accounted_dr
                ,l.accounted_cr
                ,l.accounted_dr
		,xl.meaning                            -- added line for bug 6902085
                ,l.entered_currency_code
                ,decode(l.entered_currency_code,
                        g_ledger_currency_code, NULL,
                        l.accounting_date)
                ,decode(l.entered_currency_code, g_ledger_currency_code, NULL, 'User')
                ,decode(l.entered_currency_code, g_ledger_currency_code, NULL,
                        CASE WHEN l.accounted_dr IS NOT NULL AND l.entered_dr <> 0
                                  THEN l.accounted_dr/l.entered_dr
                             WHEN l.accounted_dr IS NOT NULL
                                  THEN 1
                             WHEN l.entered_cr <> 0
                                  THEN l.accounted_cr/l.entered_cr
                             ELSE 1
                             END)
                ,l.unrounded_entered_cr
                ,l.unrounded_entered_dr
                ,l.entered_cr
                ,l.entered_dr
                ,'XLAJEL'
                ,decode(g_accounting_mode,'F',xla_gl_sl_link_id_s.nextval,NULL)
                ,decode(l_transfer_to_gl_mode_code,'D','D','S')
                ,'N'
                ,TRUNC(SYSDATE)
                ,xla_environment_pkg.g_usr_id
                ,TRUNC(SYSDATE)
                ,xla_environment_pkg.g_usr_id
                ,xla_environment_pkg.g_login_id
                ,TRUNC(SYSDATE)
                ,xla_environment_pkg.g_Prog_Appl_Id
                ,xla_environment_pkg.g_Prog_Id
                ,xla_environment_pkg.g_Req_Id
                ,l.ledger_id
                ,l.accounting_date
                ,l.encumbrance_type_id
                ,l.party_type_code
                ,l.party_id
                ,l.party_site_id
                ,'N'   -- 4262811
    FROM          xla_validation_lines_gt  l
                 ,gl_code_combinations     ccid
                 ,xla_lookups              xl                          -- added line for bug 6902085
    WHERE        l.balancing_line_type NOT IN (C_LINE_TYPE_PROCESS, C_LINE_TYPE_COMPLETE)
      AND        ccid.code_combination_id(+) = l.code_combination_id
      AND        xl.lookup_type = 'XLA_JE_VALD_LINE_DESC'              -- added filter for bug 6902085
      AND        xl.lookup_code = decode(l.balancing_line_type         -- added filter for bug 6902085
                                  ,C_LINE_TYPE_IC_BAL_INTRA
				  ,'INTRA'
                                  ,C_LINE_TYPE_IC_BAL_INTER
				  ,'INTER'
                                  ,C_LINE_TYPE_RD_BALANCING
				  ,'ROUNDING'
                                  ,C_LINE_TYPE_ENC_BALANCING
				  ,'RFE'
                                  ,C_LINE_TYPE_ENC_BAL_ERROR
				  ,'RFE'
                                  ,'BALANCE');


  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# xla_ae_lines inserted for balancing = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;



  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of procedure populate_balancing_lines',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.populate_balancing_lines');
END populate_balancing_lines;

--=============================================================================
--
-- Name: populate_segment_values
-- Description: This function populate the segment values for the journal entry
--
--=============================================================================
PROCEDURE populate_segment_values
IS
  l_log_module                 VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_segment_values';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_segment_values',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- 4262811.  Added c_caller_mpa_program
  IF (g_caller in (C_CALLER_MPA_PROGRAM, C_CALLER_THIRD_PARTY_MERGE)) THEN
    DELETE FROM xla_ae_segment_values
     WHERE ae_header_id in (SELECT /*+ UNNEST NO_SEMIJOIN cardinality(XLA_AE_HEADERS_GT,1)*/ ae_header_id       -- 4752774  bug9174950
                              FROM xla_ae_headers_gt
                             WHERE ledger_id = g_ledger_id
                               AND accounting_date <= NVL(g_end_date, accounting_date));  -- 4262811
  ELSIF g_caller = C_CALLER_ACCT_PROGRAM THEN
     NULL;                                   -- bug 4883830
  ELSE
    DELETE FROM xla_ae_segment_values
     WHERE ae_header_id = g_ae_header_id;
  END IF;

  INSERT INTO xla_ae_segment_values
        (ae_header_id, segment_type_code, segment_value, ae_lines_count)
  SELECT ae_header_id, C_BAL_SEGMENT, bal_seg_value, count(*)
    FROM xla_validation_lines_gt
   WHERE bal_seg_value IS NOT NULL
   GROUP BY ae_header_id, bal_seg_value
   UNION ALL
  SELECT ae_header_id, C_MGT_SEGMENT, mgt_seg_value, count(*)
    FROM xla_validation_lines_gt
   WHERE mgt_seg_value IS NOT NULL
   GROUP BY ae_header_id, mgt_seg_value
   UNION ALL
  SELECT ae_header_id, C_CC_SEGMENT, cost_center_seg_value, count(*)
    FROM xla_validation_lines_gt
   WHERE cost_center_seg_value IS NOT NULL
   GROUP BY ae_header_id, cost_center_seg_value
   UNION ALL
  SELECT ae_header_id, C_NA_SEGMENT, natural_account_seg_value, count(*)
    FROM xla_validation_lines_gt
   WHERE natural_account_seg_value IS NOT NULL
   GROUP BY ae_header_id, natural_account_seg_value;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# xla_ae_segment_values inserted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of procedure populate_segment_values',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.populate_segment_values');
END populate_segment_values;

--=============================================================================
--
-- Name: post_validation
-- Description: This procedure performs the validation that to be done for
--              the original journal entry lines as well as the XLA generated
--              lines.
--
--=============================================================================
PROCEDURE post_validation
IS
  CURSOR c_cont_acct IS
    SELECT *
      FROM xla_validation_lines_gt
     WHERE balancing_line_type IN (C_LINE_TYPE_LC_BALANCING
                                  ,C_LINE_TYPE_XLA_BALANCING
                                  ,C_LINE_TYPE_ENC_BALANCING)
       AND control_account_enabled_flag <> 'N'
       AND (party_type_code IS NULL OR party_id IS NULL);

  l_prev_err_count  INTEGER;
  l_temp_err_count  INTEGER;
  l_log_module      VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.post_validation';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure post_validation',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_prev_err_count := g_err_count;

  IF (C_LEVEL_ERROR >= g_log_level) THEN
    trace(p_msg    => 'before error count = '||g_err_count,
          p_module => l_log_module,
          p_level  => C_LEVEL_ERROR);
  END IF;

  -- logic
  FOR l_err IN c_cont_acct LOOP
    g_err_count := g_err_count+1;
    g_err_hdr_ids(g_err_count) := l_err.ae_header_id;
    g_err_event_ids(g_err_count) := l_err.event_id;

    IF (l_err.balancing_line_type = C_LINE_TYPE_LC_BALANCING) THEN
      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_AP_CONT_LC_SUS_ACCT'
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => l_err.ae_line_num
        ,p_accounting_batch_id  => NULL);
    ELSIF (l_err.balancing_line_type = C_LINE_TYPE_XLA_BALANCING) THEN
      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_AP_CONT_XLA_SUS_ACCT'
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => l_err.ae_line_num
        ,p_accounting_batch_id  => NULL);
    ELSE
      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_AP_CONT_RFE_SUS_ACCT'
        ,p_entity_id            => l_err.entity_id
        ,p_event_id             => l_err.event_id
        ,p_ledger_id            => g_ledger_id
        ,p_ae_header_id         => l_err.ae_header_id
        ,p_ae_line_num          => l_err.ae_line_num
        ,p_accounting_batch_id  => NULL);
    END IF;

  END LOOP;

  IF (C_LEVEL_ERROR >= g_log_level) THEN
    trace(p_msg    => 'after error count = '||g_err_count,
          p_module => l_log_module,
          p_level  => C_LEVEL_ERROR);

    l_temp_err_count := g_err_count-l_prev_err_count;
    trace(p_msg    => '# error count from post_validation = '||l_temp_err_count,
          p_module => l_log_module,
          p_level  => C_LEVEL_ERROR);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure post_validation',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;



EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.post_validation');
END post_validation;


--=============================================================================
--
-- Name: budgetary_control
-- Description:
--
--=============================================================================
PROCEDURE budgetary_control
IS
  l_array_ae_header_id           t_array_int;
  l_array_ln_funds_status_code   t_array_varchar30;
  l_array_ln_funds_status        t_array_varchar80;
  l_array_hdr_funds_status_code  t_array_varchar30;
  l_array_event_id               t_array_int;
  l_array_entity_id              t_array_int;
  l_array_ae_line_num            t_array_int;
  l_array_balance_type_code      t_array_varchar30;
  l_array_entered_cr             t_array_number;
  l_array_entered_dr             t_array_number;
  l_array_accounted_cr           t_array_number;
  l_array_accounted_dr           t_array_number;
  l_array_unrounded_entered_cr   t_array_number;
  l_array_unrounded_entered_dr   t_array_number;
  l_array_unrounded_accounted_cr t_array_number;
  l_array_unrounded_accounted_dr t_array_number;
  l_msg_name                     VARCHAR2(30);
  l_return_code                  VARCHAR2(30);
  i                              INTEGER;

  l_log_module              VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.budgetary_control';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure budgetary_control',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_err_count > 0) THEN
    FORALL i IN 1..g_err_count
      UPDATE xla_validation_lines_gt
         SET accounting_entry_status_code = xla_ae_journal_entry_pkg.C_INVALID
      WHERE ae_header_id = g_err_hdr_ids(i);

    FORALL i IN 1..g_err_count
      UPDATE xla_validation_lines_gt
         SET accounting_entry_status_code = xla_ae_journal_entry_pkg.C_RELATED_INVALID
       WHERE event_id = g_err_event_ids(i);
  END IF;

  --
  -- Call Funds Availablility API
  --
  -- Possible values returned in p_return_code are:
  -- S - If all rows in the packet pass funds check (Success)
  -- A - If all rows in the packet pass funds check and some of the rows have advisory warnings (Advisory)
  -- F - If all rows in the packet fail funds check (Fail)
  -- P - If some rows in the packet pass while some fail (Partial)
  -- T - If funds check throws a fatal error (Fatal)
  --

  IF (NOT PSA_FUNDS_CHECKER_PKG.budgetary_control
               (p_ledgerid    => g_ledger_id
               ,p_return_code => l_return_code)) THEN

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'ERROR: PSA_FUNDS_CHECKER_PKG.budgetary_control failed',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'LOCATION'
            ,p_value_1        => 'xla_je_validation_pkg.budgetary_control'
            ,p_token_2        => 'ERROR'
            ,p_value_2        => 'PSA_FUNDS_CHECK_PKG.budgetary_control failed');

  ELSE

    --
    -- Possible values returned to xla_ae_headers_gt.funds_status_codes are:
    -- S - If all rows in the packet pass funds check (Success)
    -- A - If all rows in the packet pass funds check and some of the rows have advisory warnings (Advisory)
    -- F - If all rows in the packet fail funds check (Fail)
    -- P - If some rows in the packet pass while some fail (Partial)
    -- T - If funds check throws a fatal error (Fatal)
    --
    SELECT ae_header_id
         , funds_status_code
         , event_id
         , entity_id
      BULK COLLECT INTO
           l_array_ae_header_id
         , l_array_hdr_funds_status_code
         , l_array_event_id
         , l_array_entity_id
      FROM xla_ae_headers_gt
     WHERE ledger_id = g_ledger_id;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      FOR i IN 1 .. l_array_ae_header_id.count LOOP
        trace(p_msg    => 'ae_header_id = '||l_array_ae_header_id(i)||
                          ', funds_status_code = '||l_array_hdr_funds_status_code(i),
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
      END LOOP;
    END IF;

    -- Update header level status
    FORALL i IN 1 .. l_array_ae_header_id.count
      UPDATE xla_ae_headers
         SET funds_status_code            = l_array_hdr_funds_status_code(i)
           , accounting_entry_status_code = CASE WHEN l_array_hdr_funds_status_code(i) = 'F' THEN
                                                      'I'
			                     WHEN l_array_hdr_funds_status_code(i) = 'T' THEN
					              'I'
                                                 ELSE accounting_entry_status_code
                                            END
             -- Bug 5056632. updates group_id back to Null if je is invalid
           , group_id                     = CASE WHEN l_array_hdr_funds_status_code(i) = 'F' THEN
                                                      NULL
    				            WHEN l_array_hdr_funds_status_code(i) = 'T' THEN
					              NULL
                                                 ELSE group_id
                                            END
       WHERE application_id    = g_application_id
         AND ae_header_id      = l_array_ae_header_id(i);

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# row updated in xla_ae_headers = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    FOR i IN 1 .. l_array_event_id.count LOOP
      IF (l_array_hdr_funds_status_code(i)  = 'F')OR(l_array_hdr_funds_status_code(i) = 'T') THEN
        g_err_count := g_err_count + 1;
        g_err_hdr_ids(g_err_count) := l_array_ae_header_id(i);
        g_err_event_ids(g_err_count) := l_array_event_id(i);

        xla_accounting_err_pkg.build_message(
              p_appli_s_name          => 'XLA'
              ,p_msg_name             => 'XLA_BC_FAILED_HDR'
              ,p_entity_id            => l_array_entity_id(i)
              ,p_event_id             => l_array_event_id(i)
              ,p_ledger_id            => g_ledger_id
              ,p_ae_header_id         => l_array_ae_header_id(i)
              ,p_ae_line_num          => NULL
              ,p_accounting_batch_id  => NULL);

      ELSIF (l_array_hdr_funds_status_code(i)  = 'A') THEN

        xla_accounting_err_pkg.build_message(
              p_appli_s_name          => 'XLA'
              ,p_msg_name             => 'XLA_BC_ADVISORY_HDR'
              ,p_entity_id            => l_array_entity_id(i)
              ,p_event_id             => l_array_event_id(i)
              ,p_ledger_id            => g_ledger_id
              ,p_ae_header_id         => l_array_ae_header_id(i)
              ,p_ae_line_num          => NULL
              ,p_accounting_batch_id  => NULL);

      ELSIF (l_array_hdr_funds_status_code(i)  = 'P') THEN

        xla_accounting_err_pkg.build_message(
              p_appli_s_name          => 'XLA'
              ,p_msg_name             => 'XLA_BC_PARTIAL_HDR'
              ,p_entity_id            => l_array_entity_id(i)
              ,p_event_id             => l_array_event_id(i)
              ,p_ledger_id            => g_ledger_id
              ,p_ae_header_id         => l_array_ae_header_id(i)
              ,p_ae_line_num          => NULL
              ,p_accounting_batch_id  => NULL);

      END IF;
    END LOOP;

    --
    -- Possible values returned to xla_validation_lines_gt.funds_status_codes
    -- can be found using
    -- select * from fnd_lookup_values where lookup_type like 'FUNDS_CHECK_RESULT_CODE'
    -- and language = 'US' order by lookup_code;
    -- In particular, any result code starts with 'F' (FXX) means the line is
    -- failed for funds check, and any result code starts with 'P' (PXX) means the line
    -- passed funds check.
    --
    SELECT xvl.ae_header_id
         , xvl.ae_line_num
         , xvl.event_id
         , xvl.entity_id
         , xvl.funds_status_code
         , flv.meaning
         , xah.funds_status_code
         , xvl.entered_cr
         , xvl.entered_dr
         , xvl.accounted_cr
         , xvl.accounted_dr
         , xvl.unrounded_entered_cr
         , xvl.unrounded_entered_dr
         , xvl.unrounded_accounted_cr
         , xvl.unrounded_accounted_dr
      BULK COLLECT INTO
           l_array_ae_header_id
         , l_array_ae_line_num
         , l_array_event_id
         , l_array_entity_id
         , l_array_ln_funds_status_code
         , l_array_ln_funds_status
         , l_array_hdr_funds_status_code
         , l_array_entered_cr
         , l_array_entered_dr
         , l_array_accounted_cr
         , l_array_accounted_dr
         , l_array_unrounded_entered_cr
         , l_array_unrounded_entered_dr
         , l_array_unrounded_accounted_cr
         , l_array_unrounded_accounted_dr
      FROM xla_validation_lines_gt xvl
         , xla_ae_headers          xah
         , fnd_lookup_values       flv
     WHERE xvl.ae_header_id                   = xah.ae_header_id
       AND xvl.accounting_class_code         <> 'RFE'
       AND flv.lookup_type                    = 'FUNDS_CHECK_RESULT_CODE'
       AND flv.lookup_code                    = xvl.funds_status_code
       AND flv.language                       = USERENV('LANG');

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# lines = '||l_array_ae_header_id.count,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    FOR i IN 1 .. l_array_ae_header_id.count LOOP

      l_msg_name := NULL;

      -- bug 4897846: only following codes are treated as advisory
      -- IF (l_array_ln_funds_status_code(i) BETWEEN 'P20' AND 'P39') THEN
      IF (l_array_ln_funds_status_code(i) in ('P20', 'P22', 'P25', 'P27', 'P29', 'P31', 'P35',
                                              'P36', 'P37', 'P38', 'P39')) THEN
          l_msg_name := 'XLA_BC_ADVISORY_LINE';

      ELSIF (SUBSTR(l_array_ln_funds_status_code(i),1,1) = 'F') THEN

        IF ((l_array_hdr_funds_status_code(i) = 'F')OR(l_array_hdr_funds_status_code(i)='T')) THEN
          l_msg_name := 'XLA_BC_FAILED_LINE';

        ELSE -- header status code = 'P'
          l_msg_name := 'XLA_BC_PARTIAL_LINE';

        END IF;
      END IF;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => 'Funds message for event id = '||l_array_event_id(i)||
                          ', msg = '||NVL(l_msg_name,''),
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;

      IF (l_msg_name IS NOT NULL) THEN
        xla_accounting_err_pkg.build_message(
              p_appli_s_name          => 'XLA'
              ,p_msg_name             => l_msg_name
              ,p_token_1              => 'MSG'
              ,p_value_1              => l_array_ln_funds_status(i)
              ,p_entity_id            => l_array_entity_id(i)
              ,p_event_id             => l_array_event_id(i)
              ,p_ledger_id            => g_ledger_id
              ,p_ae_header_id         => l_array_ae_header_id(i)
              ,p_ae_line_num          => l_array_ae_line_num(i)
              ,p_accounting_batch_id  => NULL);
      END IF;
    END LOOP;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'Done stacking error messages',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    -- Update line level funds status, and update the amount to zero if it is
    -- an encumbrance entry and the BC validation partially failed for the JE
    FORALL i IN 1 .. l_array_ae_header_id.count
      UPDATE xla_ae_lines
       SET funds_status_code = l_array_ln_funds_status_code(i)
         , entered_cr   = CASE WHEN entered_cr IS NULL
                               THEN NULL
                               WHEN l_array_hdr_funds_status_code(i)            = 'P'
                                AND SUBSTR(l_array_ln_funds_status_code(i),1,1) = 'F'
                               THEN 0
                               ELSE entered_cr END
         , entered_dr   = CASE WHEN entered_dr IS NULL
                               THEN NULL
                               WHEN l_array_hdr_funds_status_code(i)            = 'P'
                                AND SUBSTR(l_array_ln_funds_status_code(i),1,1) = 'F'
                               THEN 0
                               ELSE entered_dr END
         , accounted_cr = CASE WHEN accounted_cr IS NULL
                               THEN NULL
                               WHEN l_array_hdr_funds_status_code(i)            = 'P'
                                AND SUBSTR(l_array_ln_funds_status_code(i),1,1) = 'F'
                               THEN 0
                               ELSE accounted_cr END
         , accounted_dr = CASE WHEN accounted_dr IS NULL
                               THEN NULL
                               WHEN l_array_hdr_funds_status_code(i)            = 'P'
                                AND SUBSTR(l_array_ln_funds_status_code(i),1,1) = 'F'
                               THEN 0
                               ELSE accounted_dr END
         , unrounded_entered_cr
                        = CASE WHEN unrounded_entered_cr IS NULL
                               THEN NULL
                               WHEN l_array_hdr_funds_status_code(i)            = 'P'
                                AND SUBSTR(l_array_ln_funds_status_code(i),1,1) = 'F'
                               THEN 0
                               ELSE unrounded_entered_cr END
         , unrounded_entered_dr
                        = CASE WHEN unrounded_entered_dr IS NULL
                               THEN NULL
                               WHEN l_array_hdr_funds_status_code(i)            = 'P'
                                AND SUBSTR(l_array_ln_funds_status_code(i),1,1) = 'F'
                               THEN 0
                               ELSE unrounded_entered_dr END
         , unrounded_accounted_cr
                        = CASE WHEN unrounded_accounted_cr IS NULL
                               THEN NULL
                               WHEN l_array_hdr_funds_status_code(i)            = 'P'
                                AND SUBSTR(l_array_ln_funds_status_code(i),1,1) = 'F'
                               THEN 0
                               ELSE unrounded_accounted_cr END
         , unrounded_accounted_dr
                        = CASE WHEN unrounded_accounted_dr IS NULL
                               THEN NULL
                               WHEN l_array_hdr_funds_status_code(i)            = 'P'
                                AND SUBSTR(l_array_ln_funds_status_code(i),1,1) = 'F'
                               THEN 0
                               ELSE unrounded_accounted_dr END
     WHERE application_id    = g_application_id
       AND ae_header_id      = l_array_ae_header_id(i)
       AND ae_line_num       = l_array_ae_line_num(i);

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# row updated in xla_ae_lines = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    -- Adjust the amount for the RFE lines for any failed BC lines
    FORALL i in 1 .. l_array_ae_header_id.count
      UPDATE xla_ae_lines
         SET entered_cr   = CASE WHEN entered_cr IS NULL
                                 THEN NULL
                                 ELSE entered_cr   - NVL(l_array_entered_dr(i),0)
                                 END
           , entered_dr   = CASE WHEN entered_dr IS NULL
                                 THEN NULL
                                 ELSE entered_dr   - NVL(l_array_entered_cr(i),0)
                                 END
           , accounted_cr = CASE WHEN accounted_cr IS NULL
                                 THEN NULL
                                 ELSE accounted_cr - NVL(l_array_accounted_dr(i),0)
                                 END
           , accounted_dr = CASE WHEN accounted_dr IS NULL
                                 THEN NULL
                                 ELSE accounted_dr - NVL(l_array_accounted_cr(i),0)
                                 END
           , unrounded_entered_cr
                               = CASE WHEN unrounded_entered_cr IS NULL
                                 THEN NULL
                                 ELSE unrounded_entered_cr   - NVL(l_array_unrounded_entered_dr(i),0)
                                 END
           , unrounded_entered_dr
                               = CASE WHEN unrounded_entered_dr IS NULL
                                 THEN NULL
                                 ELSE unrounded_entered_dr   - NVL(l_array_unrounded_entered_cr(i),0)
                                 END
           , unrounded_accounted_cr
                               = CASE WHEN unrounded_accounted_cr IS NULL
                                 THEN NULL
                                 ELSE unrounded_accounted_cr - NVL(l_array_unrounded_accounted_dr(i),0)
                                 END
           , unrounded_accounted_dr
                               = CASE WHEN unrounded_accounted_dr IS NULL
                                 THEN NULL
                                 ELSE unrounded_accounted_dr - NVL(l_array_unrounded_accounted_cr(i),0)
                                 END
       WHERE application_id                               = g_application_id
         AND ae_header_id                                 = l_array_ae_header_id(i)
         AND l_array_hdr_funds_status_code(i)             = 'P'
         AND SUBSTR(l_array_ln_funds_status_code(i),1,1)  = 'F'
         AND accounting_class_code                        = 'RFE';

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# RFE row updated in xla_ae_lines = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of procedure budgetary_control',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.budgetary_control');
END budgetary_control;



--=============================================================================
--
-- Name: update_error_status
-- Description: This procedure update the error status if errors was encountered.
--
--=============================================================================
PROCEDURE update_error_status
IS
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_error_status';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_error_status',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --------------------------------------------------------------------------------
  -- 4262811a note: Do not modify. This sets the status correctly on each MPA rows
  --------------------------------------------------------------------------------
  FORALL i IN 1..g_err_count
    UPDATE xla_ae_headers
       SET accounting_entry_status_code = C_AE_STATUS_INVALID
           -- Bug 5056632. updates group_id back to Null if je is invalid
          ,group_id                     = NULL
     WHERE ae_header_id = g_err_hdr_ids(i)
       AND application_id = g_application_id;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# xla_ae_headers updated to C_AE_STATUS_INVALID = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF g_caller = C_CALLER_ACCT_PROGRAM THEN      -- 4262811a

     /*
     FORALL i IN 1..g_err_count
       UPDATE xla_ae_headers
          SET accounting_entry_status_code = C_AE_STATUS_RELATED
        WHERE accounting_entry_status_code <> C_AE_STATUS_INVALID
          AND event_id = g_err_event_ids(i)
          AND application_id = g_application_id;
     */
     FORALL i IN 1..g_err_count
       UPDATE xla_ae_headers xah1                  -- 4262811a
          SET accounting_entry_status_code = C_AE_STATUS_RELATED
              -- Bug 5056632. updates group_id back to Null if je is invalid
             ,group_id                     = NULL
        WHERE xah1.accounting_entry_status_code <> C_AE_STATUS_INVALID
          AND xah1.event_id = g_err_event_ids(i)
          AND xah1.application_id = g_application_id
          AND xah1.parent_ae_line_num IS NULL      -- 4262811a Existing logic, and this works for Accrual Reversal.
          AND NOT EXISTS (SELECT 1                 -- 4262811a Do not update MPA's original entry, it is set correctly above.
                          FROM   xla_ae_headers xah2
                          WHERE  xah2.event_id        = xah1.event_id         -- 5231063 g_err_event_ids(i)
                          AND    xah2.application_id  = xah1.application_id   -- 5231063 g_application_id
                          AND    xah2.ae_header_id    = g_err_hdr_ids(i)
                          AND    xah2.parent_ae_line_num IS NOT NULL);

     IF (C_LEVEL_EVENT >= g_log_level) THEN
       trace(p_msg    => '# xla_ae_headers updated to C_AE_STATUS_RELATED = '||SQL%ROWCOUNT,
             p_module => l_log_module,
             p_level  => C_LEVEL_EVENT);
     END IF;
     --------------------------------------------------------------------------------------
     -- 4262811a Update MPA rows ----------------------------------------------------------
     --------------------------------------------------------------------------------------
     FORALL i IN 1..g_err_count
       UPDATE xla_ae_headers xah1
          SET (accounting_entry_status_code, group_id) =
              (SELECT DECODE(xah2.accounting_entry_status_code
                            ,'D',xah1.accounting_entry_status_code
                            ,'F',xah1.accounting_entry_status_code
                            ,C_AE_STATUS_RELATED)
                      --
                      -- Bug 5056632. updates group_id back to Null if je is invalid
                     ,NULL
               FROM   xla_ae_headers xah2
               WHERE  xah2.event_id       = g_err_event_ids(i)
               AND    xah2.application_id = g_application_id
               AND    xah2.ae_header_id   = xah1.parent_ae_header_id
               AND    xah2.parent_ae_line_num IS NULL)
        WHERE xah1.event_id       = g_err_event_ids(i)
          AND xah1.application_id = g_application_id
          AND xah1.parent_ae_line_num IS NOT NULL;
     --------------------------------------------------------------------------------------

     /*
     FORALL i IN 1..g_err_count
     UPDATE xla_events_gt
          SET process_status_code = 'I'
        WHERE event_id = g_err_event_ids(i)
          AND process_status_code <> 'E';
     */
     FORALL i IN 1..g_err_count
     UPDATE xla_events_gt evt     -- 4262811a
          SET process_status_code =
              (SELECT DECODE(xah2.parent_ae_line_num,NULL,'I'  -- 4262811a  Status of MPA rows does not affect event status
                                                         , evt.process_status_code)
               FROM   xla_ae_headers xah2
               WHERE  xah2.event_id       = g_err_event_ids(i)
               AND    xah2.application_id = g_application_id
               AND    xah2.ae_header_id   = g_err_hdr_ids(i))
        WHERE event_id = g_err_event_ids(i)
          AND process_status_code <> 'E';


     IF (C_LEVEL_EVENT >= g_log_level) THEN
       trace(p_msg    => '# xla_events_gt updated = '||SQL%ROWCOUNT,
             p_module => l_log_module,
             p_level  => C_LEVEL_EVENT);
     END IF;
  END IF;  --  4262811a g_caller = C_CALLER_ACCT_PROGRAM

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of procedure update_error_status',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.update_error_status');
END;

--=============================================================================
--
-- Name: undo_funds_reserve
-- Description: This procedure undo the funds reservation if there is any
--              error in secondary or report currency ledgers
--
--=============================================================================
PROCEDURE undo_funds_reserve
IS
  CURSOR c_failed_je IS
    SELECT distinct xah.ledger_id, xah.event_id
      FROM xla_ae_headers xah
         , xla_events_gt  xeg
     WHERE xeg.event_id = xah.event_id
       AND xah.application_id = g_application_id
       AND xeg.process_status_code = 'I';

  l_failed_ldgr_array   PSA_FUNDS_CHECKER_PKG.num_rec;
  l_failed_evnt_array   PSA_FUNDS_CHECKER_PKG.num_rec;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.undo_funds_reserve';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure undo_funds_reserve',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c_failed_je;
  FETCH c_failed_je BULK COLLECT INTO l_failed_ldgr_array, l_failed_evnt_array;
  CLOSE c_failed_je;

  psa_funds_checker_pkg.sync_xla_errors
      (p_failed_ldgr_array => l_failed_ldgr_array
      ,p_failed_evnt_array => l_failed_evnt_array);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of procedure undo_funds_reserve',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.undo_funds_reserve');
END;


--=============================================================================
--
-- Name: populate_ledger_info
-- Description: This procedure populate ledger information to the global
--              variables.
--
--=============================================================================
PROCEDURE populate_ledger_info
IS
  CURSOR c_qualifier_segment (p_coa_id INTEGER, p_qualifier VARCHAR2) IS
    SELECT application_column_name
      FROM fnd_segment_attribute_values
     WHERE application_id = 101
       AND id_flex_code = 'GL#'
       AND id_flex_num = p_coa_id
       AND attribute_value = 'Y'
       AND segment_attribute_type = p_qualifier;

  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_ledger_info';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function populate_ledger_info',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- 4262811.  Added in C_CALLER_MPA_PROGRAM.
  IF (g_caller in (C_CALLER_ACCT_PROGRAM, C_CALLER_MPA_PROGRAM)) THEN
    g_ledger_name                  := xla_accounting_cache_pkg.GetValueChar('XLA_LEDGER_NAME',g_ledger_id);
    g_ledger_currency_code         := xla_accounting_cache_pkg.GetValueChar('XLA_CURRENCY_CODE',g_ledger_id);
    g_ledger_coa_id                := xla_accounting_cache_pkg.GetValueNum('XLA_COA_ID',g_ledger_id);
    g_bal_seg_column_name          := xla_accounting_cache_pkg.GetValueChar('BAL_SEG_COLUMN_NAME',g_ledger_id);
    g_mgt_seg_column_name          := xla_accounting_cache_pkg.GetValueChar('MGT_SEG_COLUMN_NAME',g_ledger_id);
    g_allow_intercompany_post_flag := xla_accounting_cache_pkg.GetValueChar('ALLOW_INTERCOMPANY_POST_FLAG',g_ledger_id);
    g_bal_seg_value_option_code    := xla_accounting_cache_pkg.GetValueChar('BAL_SEG_VALUE_OPTION_CODE',g_ledger_id);
    g_mgt_seg_value_option_code    := xla_accounting_cache_pkg.GetValueChar('MGT_SEG_VALUE_OPTION_CODE',g_ledger_id);
    g_sla_bal_by_ledger_curr_flag  := xla_accounting_cache_pkg.GetValueChar('SLA_BAL_BY_LEDGER_CURR_FLAG',g_ledger_id);
    g_sla_ledger_cur_bal_sus_ccid  := xla_accounting_cache_pkg.GetValueNum('XLA_LEDGER_CUR_BAL_SUS_CCID',g_ledger_id);
    g_sla_entered_cur_bal_sus_ccid := xla_accounting_cache_pkg.GetValueNum('XLA_ENTERED_CUR_BAL_SUS_CCID',g_ledger_id);
    g_sla_rounding_ccid            := xla_accounting_cache_pkg.GetValueNum('XLA_ROUNDING_CCID',g_ledger_id);
    g_latest_encumbrance_year      := xla_accounting_cache_pkg.GetValueNum('LATEST_ENCUMBRANCE_YEAR',g_ledger_id);
    g_transaction_calendar_id      := xla_accounting_cache_pkg.GetValueNum('TRANSACTION_CALENDAR_ID',g_ledger_id);
    g_enable_average_balances_flag := xla_accounting_cache_pkg.GetValueChar('ENABLE_AVERAGE_BALANCES_FLAG',g_ledger_id);
    g_res_encumb_ccid              := xla_accounting_cache_pkg.GetValueNum('RES_ENCUMB_CODE_COMBINATION_ID',g_ledger_id);
    g_ledger_category_code         := xla_accounting_cache_pkg.GetValueChar('LEDGER_CATEGORY_CODE',g_ledger_id);
    g_suspense_allowed_flag        := xla_accounting_cache_pkg.GetValueChar('SUSPENSE_ALLOWED_FLAG',g_ledger_id);
/*
    SELECT suspense_allowed_flag
      INTO g_suspense_allowed_flag
      FROM gl_ledgers
     WHERE ledger_id = g_ledger_id;
*/
  ELSE
    SELECT name
          ,currency_code ledger_currency_code
          ,chart_of_accounts_id ledger_coa_id
          ,bal_seg_column_name
          ,mgt_seg_column_name
          ,allow_intercompany_post_flag
          ,bal_seg_value_option_code
          ,mgt_seg_value_option_code
          ,sla_bal_by_ledger_curr_flag
          ,sla_ledger_cur_bal_sus_ccid
          ,sla_entered_cur_bal_sus_ccid
          ,rounding_code_combination_id
          ,latest_encumbrance_year
          ,transaction_calendar_id
          ,enable_average_balances_flag
          ,res_encumb_code_combination_id
          ,ledger_category_code
          ,suspense_allowed_flag
      INTO g_ledger_name,
           g_ledger_currency_code,
           g_ledger_coa_id,
           g_bal_seg_column_name,
           g_mgt_seg_column_name,
           g_allow_intercompany_post_flag,
           g_bal_seg_value_option_code,
           g_mgt_seg_value_option_code,
           g_sla_bal_by_ledger_curr_flag,
           g_sla_ledger_cur_bal_sus_ccid,
           g_sla_entered_cur_bal_sus_ccid,
           g_sla_rounding_ccid,
           g_latest_encumbrance_year,
           g_transaction_calendar_id,
           g_enable_average_balances_flag,
           g_res_encumb_ccid,
           g_ledger_category_code,
           g_suspense_allowed_flag
      FROM gl_ledgers
     WHERE ledger_id = g_ledger_id;
  END IF;

  IF (g_latest_encumbrance_year IS NULL) THEN
    g_latest_encumbrance_year := 0;
  END IF;

  IF (g_ledger_category_code = 'ALC') THEN
    g_target_ledger_id := g_trx_ledger_id;
  ELSE
    g_target_ledger_id := g_ledger_id;
  END IF;

  OPEN c_qualifier_segment(g_ledger_coa_id, 'GL_ACCOUNT');
  FETCH c_qualifier_segment INTO g_na_seg_column_name;
  CLOSE c_qualifier_segment;

  OPEN c_qualifier_segment(g_ledger_coa_id, 'FA_COST_CTR');
  FETCH c_qualifier_segment INTO g_cc_seg_column_name;
  CLOSE c_qualifier_segment;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function populate_ledger_info',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_qualifier_segment%ISOPEN) THEN
    CLOSE c_qualifier_segment;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c_qualifier_segment%ISOPEN) THEN
    CLOSE c_qualifier_segment;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.populate_ledger_info');
END populate_ledger_info;


--=============================================================================
--
-- Name: balance_by_ledger
-- Description: This procedure performs balancing and validation by ledger.
--
--=============================================================================
PROCEDURE balance_by_ledger
  (p_ledger_id              INTEGER
  ,p_ledger_category_code   VARCHAR2
  ,p_budgetary_control_mode VARCHAR2)
IS
  l_log_module           VARCHAR2(240);
  l_valuation_method_flag  VARCHAR2(1) := 'N';
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.balance_by_ledger';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function balance_by_ledger - ledger_id = '||p_ledger_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  g_ledger_id := p_ledger_id;
  populate_ledger_info;

  --
  -- Load working data into the temporary table

 load_lines(p_budgetary_control_mode);

  --
  -- Perform validation
  --
  validation;

  IF (g_balance_flag) THEN
    balance_single_entered_curr;
    balance_by_ledger_currency;
    balance_by_intercompany;
    balance_by_entered_curr;
    balance_by_encumberance;
    balance_by_journal_rounding;
    IF (g_new_line_count > 0) THEN
      post_validation;
      populate_balancing_lines;
    END IF;
    populate_segment_values;
  END IF;


  -- 6369778 to use secondary ledger for budgetory control purpose
SELECT nvl(valuation_method_flag,'N')
INTO   l_valuation_method_flag
FROM   XLA_SUBLEDGERS
WHERE  application_id = g_application_id;

IF  (p_budgetary_control_mode <> 'NONE') AND
        (NVL(p_ledger_category_code,'NONE') NOT IN ('ALC'))
        AND
        (  p_ledger_category_code = 'PRIMARY'
           OR
           ( NVL(p_ledger_category_code,'NONE') = 'SECONDARY' AND
             l_valuation_method_flag = 'Y'
           )
        ) THEN
      budgetary_control;
END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function balance_by_ledger',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.balance_by_ledger');
END balance_by_ledger;


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
-- Name: balance_amounts
-- Description: This function handle the validation and the balancing
--              requirement for a standard journal entry.
-- Parameters:
--   p_application_id - the application id (required)
--   p_ledger_id - the transaction ledger id (required)
-- Result:
--      0 - The balancing routine is completed successfully
--      1 - Error is found in the balancing program
--
--=============================================================================
FUNCTION balance_amounts
  (p_application_id             IN  INTEGER
  ,p_mode                       IN  VARCHAR2
  ,p_end_date                   IN  DATE    DEFAULT NULL
  ,p_ledger_id                  IN  INTEGER DEFAULT NULL
  ,p_budgetary_control_mode     IN  VARCHAR2
  ,p_accounting_mode            IN  VARCHAR2)
RETURN INTEGER
IS
  l_array_ledgers        xla_accounting_cache_pkg.t_array_ledger_id;
  l_ledger_id            INTEGER;
  l_count                INTEGER;
  l_result               INTEGER := 0;
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.balance_amounts';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function balance_amounts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- initialize
  initialize(p_application_id    => p_application_id
            ,p_ledger_id         => p_ledger_id
            ,p_ae_header_id      => NULL
            ,p_end_date          => p_end_date   -- 4262811
            ,p_mode              => p_mode       -- 4262811
            ,p_balance_flag      => TRUE
            ,p_accounting_mode   => p_accounting_mode);

  -- Process Primary and Secondary ledgers
  l_array_ledgers  := xla_accounting_cache_pkg.GetLedgers;

  IF  l_array_ledgers.COUNT > 0 THEN
    FOR l_count IN 1 .. l_array_ledgers.COUNT LOOP

      DELETE FROM xla_validation_lines_gt;
      DELETE FROM fun_bal_headers_gt;            --bug9526716 added fun table deletes in multiple place in xlajebal.pkb
      DELETE FROM fun_bal_lines_gt;
      DELETE FROM fun_bal_results_gt;
      DELETE FROM fun_bal_errors_gt;


      balance_by_ledger(l_array_ledgers(l_count)
                       ,gl_mc_info.get_ledger_category
                            (l_array_ledgers(l_count)) -- ledger category code
                       ,p_budgetary_control_mode);
    END LOOP;
  END IF;

  -- Process ALC ledgers
  l_array_ledgers  := xla_accounting_cache_pkg.GetAlcLedgers(
                            p_primary_ledger_id => g_trx_ledger_id);

  IF  l_array_ledgers.COUNT > 0 THEN
    FOR l_count IN 1 .. l_array_ledgers.COUNT LOOP

      DELETE FROM xla_validation_lines_gt;
      DELETE FROM fun_bal_headers_gt;
      DELETE FROM fun_bal_lines_gt;
      DELETE FROM fun_bal_results_gt;
      DELETE FROM fun_bal_errors_gt;

      balance_by_ledger(l_array_ledgers(l_count)
                       ,'ALC'
                       ,p_budgetary_control_mode);
    END LOOP;
  END IF;

  -- Record error
  IF (g_err_count > 0) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error founds in validation routine',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    update_error_status;

    IF (p_budgetary_control_mode = 'FUNDS_RESERVE') THEN
      undo_funds_reserve;
    END IF;

    l_result := 1;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'l_result(balance_amounts) = '||l_result,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function balance_amounts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.balance_amounts');
END;

--=============================================================================
--
-- Name: balance_tpm_amounts
-- Description: This function handle the validation and the balancing
--              requirement for a standard journal entry.
-- Parameters:
--   p_application_id - the application id (required)
--   p_ledger_id - the transaction ledger id (required)
-- Result:
--      0 - The balancing routine is completed successfully
--      1 - Error is found in the balancing program
--
--=============================================================================
FUNCTION balance_tpm_amounts
  (p_application_id             IN  INTEGER
  ,p_ledger_id                  IN  INTEGER
  ,p_ledger_array               IN  xla_accounting_cache_pkg.t_array_ledger_id
  ,p_accounting_mode            IN  VARCHAR2
) RETURN INTEGER
IS
  l_ledger_id            INTEGER;
  l_count                INTEGER;
  l_result               INTEGER := 0;
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.balance_amounts';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function balance_amounts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- initialize
  initialize(p_application_id    => p_application_id
            ,p_ledger_id         => p_ledger_id
            ,p_ae_header_id      => NULL
            ,p_end_date          => null
            ,p_mode              => 'THIRD_PARTY_MERGE'
            ,p_balance_flag      => TRUE
            ,p_accounting_mode   => p_accounting_mode);

  IF  p_ledger_array.COUNT > 0 THEN
    FOR l_count IN 1 .. p_ledger_array.COUNT loop
      IF(g_err_count=0) THEN

	      DELETE FROM xla_validation_lines_gt;
	      DELETE FROM fun_bal_headers_gt;
	      DELETE FROM fun_bal_lines_gt;
	      DELETE FROM fun_bal_results_gt;
	      DELETE FROM fun_bal_errors_gt;

        balance_by_ledger(p_ledger_array(l_count)
                       , NULL  -- Ledger category code
                       ,'NONE');
      END IF;
    END LOOP;
  END IF;

  -- Record error
  IF (g_err_count > 0) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error founds in validation routine',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

--    no need since we will rollback;
--    update_error_status;

    l_result := 1;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'l_result(balance_amounts) = '||l_result,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function balance_amounts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.balance_amounts');
END;

--=============================================================================
--
-- Name: balance_manual_entries
-- Description: This function handle the validation and the balancing
--              requirement for a manual journal entry.
-- Parameters:
--   p_application_id - the application id (required)
--   p_ledger_id - the transaction ledger id (required)
--   p_event_id - the event id
--   p_balance_flag - indicates if balancing should be performed
-- Result:
--      0 - The balancing routine is completed successfully
--      1 - Error is found in the balancing program
--
--=============================================================================
FUNCTION balance_manual_entry
  (p_application_id     IN INTEGER
  ,p_balance_flag       IN BOOLEAN DEFAULT TRUE
  ,p_accounting_mode    IN VARCHAR2
  ,p_ledger_ids         IN t_array_int
  ,p_ae_header_ids      IN t_array_int
  ,p_end_date           IN DATE          -- 4262811
  ,p_status_codes       IN OUT NOCOPY t_array_varchar)
RETURN INTEGER
IS
  l_prev_err_count       INTEGER := 0;
  l_result               INTEGER := 0;
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.balance_manual_entry';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function balance_manual_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- initialize
  initialize(p_application_id    => p_application_id
            ,p_ledger_id         => p_ledger_ids(1)
            ,p_ae_header_id      => p_ae_header_ids(1)
            ,p_end_date          => p_end_date            -- 4262811
            ,p_mode              => 'MANUAL_JE'           -- 4262811
            ,p_balance_flag      => p_balance_flag
            ,p_accounting_mode   => p_accounting_mode);

  -- Process ALC ledgers
  FOR i IN 1 .. p_ledger_ids.COUNT LOOP

      DELETE FROM xla_validation_lines_gt;
      DELETE FROM fun_bal_headers_gt;
      DELETE FROM fun_bal_lines_gt;
      DELETE FROM fun_bal_results_gt;
      DELETE FROM fun_bal_errors_gt;

    g_ae_header_id := p_ae_header_ids(i);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'Processing ae_header_id = '||g_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'starting g_err_count = '||g_err_count,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    balance_by_ledger(p_ledger_ids(i)
                     ,NULL -- ledger category code
                     ,'NONE');

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'ending g_err_count = '||g_err_count,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    IF (g_err_count > l_prev_err_count) THEN

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace(p_msg    => 'Journal entry is marked as error',
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
      END IF;

      p_status_codes(i) := C_AE_STATUS_INVALID;
      l_prev_err_count := g_err_count;
      l_result := 1;
    END IF;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'l_result(balance_manual_entry) = '||l_result,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'End of function balance_manual_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_je_validation_pkg.balance_manual_entry');
END;


--=============================================================================
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--=============================================================================
BEGIN
   g_new_line_count     := 0;
   g_amb_context_code   := NVL(fnd_profile.value('XLA_AMB_CONTEXT'), 'DEFAULT');

   g_log_level          := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled        := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_je_validation_pkg;

/
