--------------------------------------------------------
--  DDL for Package Body XLA_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_BALANCES_PKG" AS
/* $Header: xlabacom.pkb 120.43.12010000.27 2010/04/09 13:25:49 karamakr ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_balances_pkg                                                   |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Balances Package                                               |
|                                                                       |
| HISTORY                                                               |
|    27-AUG-02 A. Quaglia     Created                                   |
|    15-NOV-02 A. Quaglia     -Added NOCOPY hint to OUT parameters      |
|                             -'N' not allowed for balance_flags        |
|                             -Analytical balances do not propagate     |
|                             -beyond fiscal years.                     |
|    20-DEC-02 A. Quaglia     -Implemented new propagation for          |
|                              analytical criteria.                     |
|    16-JUN-03 A. Quaglia     Global temporary tables renamed           |
|                             changed je_source_name to                 |
|                             control_account_source_code in            |
|                             xla_subledgers                            |
|    10-OCT-03 A. Quaglia     Bug3177938                                |
|                             massive_update:                           |
|                                p_application_id must be not null.     |
|                             load_balance_temp_tables:                 |
|                                added support for p_application_id     |
|                                not null when p_request_id not null    |
|    29-OCT-03 A. Quaglia     Bug3190083                                |
|                             lock_create_balance_statuses:             |
|                                replaced FND_FLEX_APIS                 |
|                                get_qualifier_segnum + get_segment_info|
|                                with get_segment_column                |
|                             in all _srs:                              |
|                                added activate/deactivate trace stmts  |
|    31-OCT-03 A.Quaglia      Bug3202694:                               |
|                             massive_update:                           |
|                                added p_entity_id                      |
|                                old, deprecated API maintained until   |
|                                uptake is done.                        |
|                             calculate_balances:                       |
|                                if no rows to process exit immediately |
|                                also when commit_flag <> 'Y'           |
|    31-OCT-03 A.Quaglia      Replaced other occurences of FND_FLEX_APIS|
|    26-NOV-03 A.Quaglia      Bug3264347:                               |
|                             massive_update_srs:                       |
|                                new param p_dummy                      |
|                             massive_update:                           |
|                                changed concurrent submission of       |
|                                XLABAOPE (new dummy param in def.)     |
|    15-DEC-03 A.Quaglia      Bug3315864:                               |
|                             move_balances_forward:                    |
|                                fixed carry forward of NULL amounts    |
|                             move_identified_bals_forward:             |
|                                fixed carry forward of NULL amounts    |
|                                fixed missing outer join on one cond.  |
|                                fixed running from SQLPlus (no req.id) |
|                                renamed to move_balances_forward_COMMIT|
|                             build_line_selection_dyn_stmts:           |
|                                corrected WHEN clause in INSERT ALL    |
|    05-MAR-04 A.Quaglia      Changed trace handling as per Sandeep's   |
|                             code.                                     |
|    19-MAR-04 A.Quaglia      Fixed debug changes issues:               |
|                               -Replaced global variable for trace     |
|                                with local one                         |
|                               -Fixed issue with SQL%ROWCOUNT which is |
|                                modified after calling debug proc      |
|    29-JUL-04 A.Quaglia      Bug3202694:                               |
|                             massive_update:                           |
|                                removed deprecated API                 |
|                                                                       |
|    22-OCT-04 W.Shen         New API is added                          |
|                             massive_update(p_application_id)          |
|                                This API is for Bulk Event API only    |
|                                It will update the balance for events  |
|                                in events_gt table.                    |
|                             Two private functions: Calculate_balances,|
|                                Load_balance_temp_tables are updated   |
|                                too                                    |
|    11-MAR-05 W. Chan       Fixed bug 4220415 - removed join to        |
|                            xla_transaction_entities in                |
|                            load_balance_temp_tables when the          |
|                            entity_id IS NULL                          |
|                                                                       |
|    01-APR-05 W. Chan       Fixed bug 4277500 - removed join to        |
|                            xla_events in load_balance_temp_tables     |
|                            when the entity_id IS NULL                 |
|                                                                       |
|    10-APR-05 W. Shen       Fixed bug 4277500 - removed the table      |
|    30-NOV-05 V. Kumar      Bug 4769611 Modify SQLs in balance calcul- |
|                             ation routine                             |
|    19-Jan-05 V. Kumar      Removed the code for AC balances           |
|    03-Mar-06 V. Kumar      Populating GL_SL_LINK_IN in xla_ae_lines   |
|    05-Dec-08 karamakr      7608545- Reset l_begin_bal_dr,             |
|                            l_begin_bal_cr to null                     |
+======================================================================*/

--Generic Procedure/Function template
/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
|                                                                       |
|  MUST SOLVE                                                           |
|                                                                       |
|                                                                       |
|  NICE TO SOLVE                                                        |
|                                                                       |
|                                                                       |
+======================================================================*/

   --
   -- Private exceptions
   --
   le_resource_busy                   EXCEPTION;
   PRAGMA exception_init(le_resource_busy, -00054);

   --
   -- Private types
   --
   TYPE table_of_pls_integer IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;

   --
   -- Private constants
   --
   --maximum number of accounting lines processed in a COMMIT cycle.
   C_BATCH_COMMIT_SIZE       CONSTANT NATURAL      := NVL(FND_PROFILE.VALUE('XLA_BAL_BATCH_COMMIT_SIZE'),10000);
   --maximum numbers of values retrieved at a time by BULK COLLECT statements
   C_BULK_LIMIT              CONSTANT NATURAL      :=   5000;

   --balance types: analytical criteria or control accounts
   C_BALANCE_TYPE_ANALYTICAL CONSTANT VARCHAR2(10) := 'ANALYTICAL';
   C_BALANCE_TYPE_CONTROL    CONSTANT VARCHAR2(10) := 'CONTROL';

   --balance modes: draft or final
   C_BALANCE_MODE_DRAFT      CONSTANT VARCHAR2(10) := 'DRAFT';
   C_BALANCE_MODE_FINAL      CONSTANT VARCHAR2(10) := 'FINAL';

/*
   C_BALANCE_STATUS_RECREATE CONSTANT VARCHAR2(1) := 'R';
   C_BALANCE_STATUS_REC_BAL CONSTANT VARCHAR2(1) := 'R';
*/

   --Analytical Criteria year end carry forward codes
   --Just for reference, Currently not used in the code
   C_AC_YEAR_END_CF_CODE_NEVER      CONSTANT VARCHAR2(1) := 'N';
   C_AC_YEAR_END_CF_CODE_ALWAYS     CONSTANT VARCHAR2(1) := 'A';
   C_AC_YEAR_END_CF_CODE_ACC_TYPE   CONSTANT VARCHAR2(1) := 'B';

   --
   -- Global variables
   --
   g_user_id                 INTEGER;
   g_login_id                INTEGER;
   g_date                    DATE;
   g_prog_appl_id            INTEGER;
   g_prog_id                 INTEGER;
   g_req_id                  INTEGER;

   g_cached_ledgers          table_of_pls_integer;
   g_cached_single_period    BOOLEAN;
   g_lock_flag VARCHAR2(1) DEFAULT 'N';
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_balances_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

--1-STATEMENT, 2-PROCEDURE, 3-EVENT, 4-EXCEPTION, 5-ERROR, 6-UNEXPECTED

PROCEDURE trace
       ( p_module                     IN VARCHAR2
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
         (p_location   => 'xla_balances_pkg.trace');
END trace;


FUNCTION get_account_segment_column
          ( p_chart_of_accounts_id INTEGER
          )
RETURN VARCHAR2
IS

l_id_flex_code               VARCHAR2 ( 4);
l_account_segment_column     VARCHAR2 (30);
l_balancing_value_set        VARCHAR2 (60);
l_account_value_set          VARCHAR2 (60);
l_log_module                 VARCHAR2 (2000);
BEGIN

l_id_flex_code          := 'GL#';

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_account_segment_column';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg          => 'BEGIN ' || l_log_module
         ,p_level        => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_chart_of_accounts_id    :' || p_chart_of_accounts_id
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   IF FND_FLEX_APIS.get_segment_column( 101
                                       ,l_id_flex_code
                                       ,p_chart_of_accounts_id
                                       ,'GL_ACCOUNT'
                                       ,l_account_segment_column
                                      )

   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg          =>
'l_account_segment_column:' || l_account_segment_column
            ,p_level        => C_LEVEL_STATEMENT);
      END IF;
   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION: ' ||
'Unable to retrieve segment information for chart of accounts ' ||
                         p_chart_of_accounts_id
            ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: Unable to retrieve segment information for chart of accounts ' ||
                         p_chart_of_accounts_id);
   END IF;

   RETURN l_account_segment_column;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.get_account_segment_column');
END get_account_segment_column;


FUNCTION move_balances_forward_COMMIT
  ( p_application_id               IN INTEGER
   ,p_ledger_id                    IN INTEGER
   ,p_balance_source_code          IN VARCHAR2
   ,p_source_effective_period_num  IN INTEGER
   ,p_balance_status_code_selected IN VARCHAR2
   ,p_balance_status_code_not_sel  IN VARCHAR2
  )
RETURN BOOLEAN
IS
/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
| WARNING: this procedure performs COMMITs                              |
|                                                                       |
|                                                                       |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
+======================================================================*/

CURSOR lc_lock_balance_statuses ( cp_application_id       INTEGER
                                 ,cp_ledger_id            INTEGER
                                 ,cp_balance_status_code  VARCHAR2
                                 ,cp_balance_source_code  VARCHAR2
                                 ,cp_effective_period_num INTEGER
                                 ,cp_request_id           INTEGER
                                )
IS
   SELECT xbs.code_combination_id
     FROM xla_balance_statuses xbs
    WHERE xbs.application_id          = cp_application_id
      AND xbs.ledger_id               = cp_ledger_id
      AND xbs.balance_status_code     = cp_balance_status_code
      AND xbs.balance_source_code     = cp_balance_source_code
      AND xbs.effective_period_num    = cp_effective_period_num
      AND xbs.request_id              = cp_request_id
    FOR UPDATE;


l_user_id                 INTEGER;
l_login_id                INTEGER;
l_date                    DATE;
l_prog_appl_id            INTEGER;
l_prog_id                 INTEGER;
l_req_id                  INTEGER;

l_source_period_name        VARCHAR2(15);
l_dest_effective_period_num INTEGER;
l_dest_period_name          VARCHAR2(15);
l_dest_period_year          INTEGER;
l_dest_first_period_flag    VARCHAR2(1);
l_return_value              BOOLEAN;
l_row_count                 NUMBER;

l_log_module                 VARCHAR2 (2000);

-- C_DUMMY                           CONSTANT VARCHAR2(30) := ' ';

BEGIN

l_user_id                 := xla_environment_pkg.g_usr_id;
l_login_id                := xla_environment_pkg.g_login_id;
l_date                    := SYSDATE;
l_prog_appl_id            := xla_environment_pkg.g_prog_appl_id;
l_prog_id                 := xla_environment_pkg.g_prog_id;
l_req_id                  := xla_environment_pkg.g_req_id;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.move_balances_forward_COMMIT';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_application_id               :' || p_application_id
         ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_ledger_id                    :' || p_ledger_id
         ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_balance_source_code          :' || p_balance_source_code
         ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_source_effective_period_num  :' || p_source_effective_period_num
         ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_balance_status_code_selected :' || p_balance_status_code_selected
         ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_balance_status_code_not_sel  :' || p_balance_status_code_not_sel
         ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      => 'l_req_id                       :' || l_req_id
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF  p_balance_status_code_selected IS NULL
   AND p_balance_status_code_not_sel  IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:'
||'p_balance_status_code_selected and p_balance_status_code_not_sel '
|| 'cannot be both NULL'
            ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:'
||'p_balance_status_code_selected and p_balance_status_code_not_sel '
|| 'cannot be both NULL');

   END IF;

   IF p_source_effective_period_num IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION: ' ||
                        'p_source_effective_period_num cannot be NULL'
            ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: ' ||
                        'p_source_effective_period_num cannot be NULL');
   END IF;

   SELECT gpssource.period_name
         ,gpsdest.period_name
         ,gpsdest.effective_period_num
         ,gpsdest.period_year
         ,DECODE( gpssource.period_year
                 ,gpsdest.period_year
                 ,'N'
                 ,'Y'
                ) first_period_flag
     INTO l_source_period_name
         ,l_dest_period_name
         ,l_dest_effective_period_num
         ,l_dest_period_year
         ,l_dest_first_period_flag
     FROM gl_period_statuses gpssource
         ,gl_period_statuses gpsdest
    WHERE gpssource.ledger_id              =  p_ledger_id
      AND gpssource.application_id         =  101
      AND gpssource.closing_status         IN ('O', 'C', 'P')
      AND gpssource.adjustment_period_flag =  'N'
      AND gpssource.effective_period_num   =  p_source_effective_period_num
      AND gpsdest.ledger_id                =  p_ledger_id
      AND gpsdest.application_id           =  101
      AND gpsdest.effective_period_num     =
          ( SELECT MIN(gps2.effective_period_num)
              FROM gl_period_statuses gps2
             WHERE gps2.ledger_id              =  p_ledger_id
               AND gps2.application_id         =  101
               AND gps2.effective_period_num   >  p_source_effective_period_num
               AND gps2.closing_status         IN ('O', 'C', 'P')
               AND gps2.adjustment_period_flag =  'N'
          );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      =>
'l_source_period_name                       :' || l_source_period_name
          ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      =>
'l_dest_period_name                       :' || l_dest_period_name
          ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      =>
'l_dest_effective_period_num                       :' || l_dest_effective_period_num
          ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      =>
'l_dest_period_year                       :' || l_dest_period_year
          ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      =>
'l_dest_first_period_flag                       :' || l_dest_first_period_flag
          ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   LOOP  --process a chunk of balance statuses at a time

      --If called from SQLPlus we need exclusive access
      IF NVL(l_req_id, -1) = -1
      THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_module => l_log_module
               ,p_msg   => 'Script called from SQLPlus (req_id NULL) '
               ,p_level => C_LEVEL_STATEMENT
               );
            trace
               (p_module => l_log_module
               ,p_msg   => 'trying to lock xla_balance_statuses'
               ,p_level => C_LEVEL_STATEMENT
               );
         END IF;
         LOCK TABLE xla_balance_statuses    IN EXCLUSIVE MODE NOWAIT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_module => l_log_module
               ,p_msg   => 'trying to lock xla_control_balances'
               ,p_level => C_LEVEL_STATEMENT
               );
         END IF;
         LOCK TABLE xla_control_balances    IN EXCLUSIVE MODE NOWAIT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_module => l_log_module
               ,p_msg   => 'trying to lock xla_ac_balances'
               ,p_level => C_LEVEL_STATEMENT
               );
         END IF;
         LOCK TABLE xla_ac_balances IN EXCLUSIVE MODE NOWAIT;

      END IF;

      l_date := SYSDATE;
      UPDATE xla_balance_statuses xbsext
         SET xbsext.balance_status_code      = p_balance_status_code_selected
            ,xbsext.last_update_date         = l_date
            ,xbsext.last_updated_by          = l_user_id
            ,xbsext.last_update_login        = l_login_id
            ,xbsext.program_update_date      = l_date
            ,xbsext.program_application_id   = l_prog_appl_id
            ,xbsext.program_id               = l_prog_id
            ,xbsext.request_id               = NVL(l_req_id, -1)
       WHERE xbsext.ROWID IN
            (SELECT xbs.ROWID
               FROM xla_balance_statuses    xbs
                   ,fnd_concurrent_requests fnd
              WHERE xbs.application_id       =  p_application_id
                AND xbs.ledger_id            =  p_ledger_id
                AND xbs.balance_source_code  =  NVL( p_balance_source_code
                                                    ,xbs.balance_source_code
                                                   )
                AND xbs.effective_period_num =  p_source_effective_period_num
                AND xbs.balance_status_code  IN ( p_balance_status_code_not_sel
                                                 ,p_balance_status_code_selected
                                                )
                AND fnd.request_id(+)           =  xbs.request_id
                --pick up records being handled by this request
                --or by any another request which is not running
                AND (    NVL(xbs.request_id, -1)  =  NVL(l_req_id, -1)
                      OR NVL(fnd.status_code,'N') <> 'R'
                    )
             --handle the case where the procedure is invoked
             --outside a concurrent request
             UNION
             SELECT xbs.ROWID
               FROM xla_balance_statuses    xbs
              WHERE xbs.application_id       =  p_application_id
                AND xbs.ledger_id            =  p_ledger_id
                AND xbs.balance_source_code  =  NVL( p_balance_source_code
                                                    ,xbs.balance_source_code
                                                   )
                AND xbs.effective_period_num =  p_source_effective_period_num
                AND xbs.balance_status_code  IN ( p_balance_status_code_not_sel
                                                 ,p_balance_status_code_selected
                                                )
                AND NVL(l_req_id, -1)         = -1
            )
         AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
               ,p_msg   => l_row_count
                           || ' xla_balance_statuses updated to '
                           || p_balance_status_code_selected
               ,p_level => C_LEVEL_STATEMENT
               );
      END IF;

      IF l_row_count = 0
      THEN
         l_return_value := TRUE;
         COMMIT;
         EXIT;
      ELSE
         COMMIT;
      END IF;

      LOOP
         --If called from SQLPlus we need exclusive access
         IF NVL(l_req_id, -1) = -1
         THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_module => l_log_module
                  ,p_msg   => 'Script called from SQLPlus (req_id NULL) '
                  ,p_level => C_LEVEL_STATEMENT
                  );
               trace
                  (p_module => l_log_module
                  ,p_msg   => 'trying to lock xla_balance_statuses'
                  ,p_level => C_LEVEL_STATEMENT
                  );
            END IF;
            LOCK TABLE xla_balance_statuses    IN EXCLUSIVE MODE NOWAIT;

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_module => l_log_module
                  ,p_msg   => 'trying to lock xla_control_balances'
                  ,p_level => C_LEVEL_STATEMENT
                  );
            END IF;
            LOCK TABLE xla_control_balances    IN EXCLUSIVE MODE NOWAIT;

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_module => l_log_module
                  ,p_msg   => 'trying to lock xla_ac_balances'
                  ,p_level => C_LEVEL_STATEMENT
                  );
            END IF;
            LOCK TABLE xla_ac_balances IN EXCLUSIVE MODE NOWAIT;

         END IF;

         IF NVL(p_balance_source_code, 'C') =  'C'
         THEN
            --lock xla_balance_statuses and wait if necessary
            OPEN lc_lock_balance_statuses
                   ( cp_application_id       => p_application_id
                    ,cp_ledger_id            => p_ledger_id
                    ,cp_balance_status_code  => p_balance_status_code_selected
                    ,cp_balance_source_code  => 'C'
                    ,cp_effective_period_num => p_source_effective_period_num
                    ,cp_request_id           => NVL(l_req_id, -1)
                   );
            CLOSE lc_lock_balance_statuses;

               INSERT INTO xla_control_balances
                 ( application_id
                  ,ledger_id
                  ,code_combination_id
                  ,party_type_code
                  ,party_id
                  ,party_site_id
                  ,period_name
                  ,period_year
                  ,beginning_balance_dr
                  ,beginning_balance_cr
                  ,period_balance_dr
                  ,period_balance_cr
                  ,draft_beginning_balance_dr
                  ,draft_beginning_balance_cr
                  ,period_draft_balance_dr
                  ,period_draft_balance_cr
                  ,initial_balance_flag
                  ,first_period_flag
                  ,creation_date
                  ,created_by
                  ,last_update_date
                  ,last_updated_by
                  ,last_update_login
                  ,program_update_date
                  ,program_application_id
                  ,program_id
                  ,request_id
                  ,effective_period_num
                 )
   SELECT xba.application_id
         ,xba.ledger_id
         ,xba.code_combination_id
         ,xba.party_type_code
         ,xba.party_id
         ,xba.party_site_id
         ,l_dest_period_name
         ,l_dest_period_year
         ,DECODE( l_dest_first_period_flag
                 ,'Y'
                 ,DECODE( SIGN ( NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0)
                                -(NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0))
                               )
                         ,1
                         ,NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0)
                          - (NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0))
                         ,NULL
                        )
                 ,NVL2( xba.beginning_balance_dr
                       ,xba.beginning_balance_dr + NVL(xba.period_balance_dr, 0)
                       ,xba.period_balance_dr
                      )
                 )       --beginning_balance_dr
         ,DECODE( l_dest_first_period_flag
                 ,'Y'
                 ,DECODE( SIGN ( NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0)
                                -(NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0))
                               )
                         ,1
                         ,NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0)
                          - ( NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0))
                         ,NULL
                        )
                 ,NVL2( xba.beginning_balance_cr
                       ,xba.beginning_balance_cr + NVL(xba.period_balance_cr, 0)
                       ,xba.period_balance_cr
                      )
                 )       --beginning_balance_cr
         ,NULL              --period_balance_dr
         ,NULL              --period_balance_cr
         ,DECODE( l_dest_first_period_flag
                 ,'Y'
                 ,DECODE( SIGN ( NVL(xba.draft_beginning_balance_dr, 0) + NVL(xba.period_draft_balance_dr, 0)
                                -( NVL(xba.draft_beginning_balance_cr, 0) + NVL(xba.period_draft_balance_cr, 0) )
                               )
                         ,1
                         ,NVL(xba.draft_beginning_balance_dr, 0) + NVL(xba.period_draft_balance_dr, 0)
                          - ( NVL(xba.draft_beginning_balance_cr, 0) + NVL(xba.period_draft_balance_cr, 0) )
                         ,NULL
                        )
                 ,NVL2( xba.draft_beginning_balance_dr
                       ,xba.draft_beginning_balance_dr + NVL(xba.period_draft_balance_dr, 0)
                       ,xba.period_draft_balance_dr
                      )
                 )       --draft_beginning_balance_dr
         ,DECODE( l_dest_first_period_flag
                 ,'Y'
                 ,DECODE( SIGN ( NVL(xba.draft_beginning_balance_cr, 0) + NVL(xba.period_draft_balance_cr, 0)
                                -( NVL(xba.draft_beginning_balance_dr, 0) + NVL(xba.period_draft_balance_dr, 0) )
                               )
                         ,1
                         ,NVL(xba.draft_beginning_balance_cr, 0) + NVL(xba.period_draft_balance_cr, 0)
                          - ( NVL(xba.draft_beginning_balance_dr, 0) + NVL(xba.period_draft_balance_dr, 0) )
                         ,NULL
                        )
                 ,NVL2( xba.draft_beginning_balance_cr
                       ,xba.draft_beginning_balance_cr + NVL(xba.period_draft_balance_cr, 0)
                       ,xba.period_draft_balance_cr
                      )
                 )       --draft_beginning_balance_cr
         ,NULL              --period_draft_balance_dr
         ,NULL              --period_draft_balance_cr
         ,'N'            --initial_balance_flag
         ,l_dest_first_period_flag --first_period_flag
         ,SYSDATE        --creation_date
         ,l_user_id      --created_by
         ,SYSDATE        --last_update_date
         ,l_user_id      --last_update_by
         ,l_login_id     --last_update_login
         ,SYSDATE        --program_update_date
         ,l_prog_appl_id --program_application_id
         ,l_prog_id      --program_id
         ,NVL(l_req_id, -1)   --request_id
         ,l_dest_effective_period_num
     FROM xla_balance_statuses       xbs
         ,xla_control_balances       xba
         ,xla_control_balances       xbanew
    WHERE xbs.application_id                   =  p_application_id
      AND xbs.ledger_id                        =  p_ledger_id
      AND xbs.balance_source_code              =  'C'
      AND xbs.balance_status_code              =  p_balance_status_code_selected
      AND xbs.effective_period_num             =  p_source_effective_period_num
      AND xbs.request_id                       =  NVL(l_req_id, -1)
      AND xba.ledger_id                        =  p_ledger_id
      AND xba.application_id                   =  p_application_id
      AND xba.code_combination_id              =  xbs.code_combination_id
      AND xba.period_name                      =  l_source_period_name
      AND xbanew.application_id             (+)=  p_application_id
      AND xbanew.ledger_id                  (+)=  p_ledger_id
      AND xbanew.application_id             (+)=  xba.application_id
      AND xbanew.code_combination_id        (+)=  xba.code_combination_id
      AND xbanew.period_name                (+)=  l_dest_period_name
      AND xbanew.party_id                   (+)=  xba.party_id
      AND xbanew.party_site_id              (+)=  xba.party_site_id
      AND xbanew.ledger_id                     IS NULL
      AND ROWNUM                               <= C_BATCH_COMMIT_SIZE;

            l_row_count := SQL%ROWCOUNT;

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_module => l_log_module
                  ,p_msg   => l_row_count
                              || 'control balances created '
                  ,p_level => C_LEVEL_STATEMENT
                  );
            END IF;

         END IF;

         IF NVL(p_balance_source_code, 'A') =  'A'
         THEN
            --lock xla_balance_statuses and wait if necessary
            OPEN lc_lock_balance_statuses
                   ( cp_application_id       => p_application_id
                    ,cp_ledger_id            => p_ledger_id
                    ,cp_balance_status_code  => p_balance_status_code_selected
                    ,cp_balance_source_code  => 'A'
                    ,cp_effective_period_num => p_source_effective_period_num
                    ,cp_request_id           => NVL(l_req_id, -1)
                   );
            CLOSE lc_lock_balance_statuses;

            INSERT INTO xla_ac_balances
                 ( application_id
                  ,ledger_id
                  ,code_combination_id
                  ,analytical_criterion_code
                  ,analytical_criterion_type_code
                  ,amb_context_code
                  ,ac1
                  ,ac2
                  ,ac3
                  ,ac4
                  ,ac5
                  ,period_name
                  ,period_year
                  ,beginning_balance_dr
                  ,beginning_balance_cr
                  ,period_balance_dr
                  ,period_balance_cr
                  ,initial_balance_flag
                  ,first_period_flag
                  ,creation_date
                  ,created_by
                  ,last_update_date
                  ,last_updated_by
                  ,last_update_login
                  ,program_update_date
                  ,program_application_id
                  ,program_id
                  ,request_id
		  ,effective_period_num
                 )
   SELECT /*+ leading(XBS XBA) use_nl(XBH XBA) index(XBA XLA_AC_BALANCES_N1) index(XBA_NEW XLA_AC_BALANCES_N1) */ xba.application_id
         ,xba.ledger_id
         ,xba.code_combination_id
         ,xba.analytical_criterion_code
         ,xba.analytical_criterion_type_code
         ,xba.amb_context_code
         ,xba.ac1
         ,xba.ac2
         ,xba.ac3
         ,xba.ac4
         ,xba.ac5
         ,l_dest_period_name
         ,l_dest_period_year
         ,DECODE( l_dest_first_period_flag
                 ,'Y'
                 ,DECODE( SIGN ( NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0)
                                -(NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0))
                               )
                         ,1
                         ,NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0)
                          - (NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0))
                         ,NULL
                        )
                 ,NVL2( xba.beginning_balance_dr
                       ,xba.beginning_balance_dr + NVL(xba.period_balance_dr, 0)
                       ,xba.period_balance_dr
                      )
                 )       --beginning_balance_dr
         ,DECODE( l_dest_first_period_flag
                 ,'Y'
                 ,DECODE( SIGN ( NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0)
                                -(NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0))
                               )
                         ,1
                         ,NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0)
                          - ( NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0))
                         ,NULL
                        )
                 ,NVL2( xba.beginning_balance_cr
                       ,xba.beginning_balance_cr + NVL(xba.period_balance_cr, 0)
                       ,xba.period_balance_cr
                      )
                 )       --beginning_balance_cr
         ,NULL           --period_balance_dr
         ,NULL           --period_balance_cr
         ,'N'            --initial_balance_flag
         ,l_dest_first_period_flag
         ,SYSDATE        --creation_date
         ,l_user_id      --created_by
         ,SYSDATE        --last_update_date
         ,l_user_id      --last_update_by
         ,l_login_id     --last_update_login
         ,SYSDATE        --program_update_date
         ,l_prog_appl_id --program_application_id
         ,l_prog_id      --program_id
         ,NVL(l_req_id, -1)  --request_id
	 ,l_dest_effective_period_num
     FROM xla_balance_statuses         xbs
         ,xla_ac_balances              xba
         ,xla_analytical_hdrs_b        xbh
    WHERE xbs.application_id                   =  p_application_id
      AND xbs.ledger_id                        =  p_ledger_id
      AND xbs.balance_source_code              =  'A'
      AND xbs.balance_status_code              =  p_balance_status_code_selected
      AND xbs.effective_period_num             =  p_source_effective_period_num
      AND xbs.request_id                       =  NVL(l_req_id, -1)
      AND xba.application_id                   =  p_application_id
      AND xba.ledger_id                        =  p_ledger_id
      AND xba.application_id                   =  xbs.application_id
      AND xba.code_combination_id              =  xbs.code_combination_id
      AND xba.period_name                      =  l_source_period_name
      AND xbh.analytical_criterion_code        =  xba.analytical_criterion_code
      AND xbh.analytical_criterion_type_code   =  xba.analytical_criterion_type_code
      AND xbh.amb_context_code                 =  xba.amb_context_code
      AND (    xba.period_year                        =  l_dest_period_year
           OR  xbh.year_end_carry_forward_code        =  'A'
           OR  (     xbh.year_end_carry_forward_code  =  'B'
                 AND xbs.account_type            IN ('A', 'L', 'O')
               )
          )
      -- Bug 7321087  Begin
      AND   NOT EXISTS( SELECT 1
                        FROM xla_ac_balances xba1
                        WHERE xba1.application_id                 = xba.application_id
                        AND xba1.ledger_id                      = xba.ledger_id
                        AND xba1.code_combination_id            = xba.code_combination_id
                        AND xba1.analytical_criterion_code      = xba.analytical_criterion_code
                        AND xba1.analytical_criterion_type_code = xba.analytical_criterion_type_code
                        AND xba1.amb_context_code               = xba.amb_context_code
                        AND NVL(xba1.ac1,' ')               = NVL(xba.ac1,' ')
                        AND NVL(xba1.ac2,' ')               = NVL(xba.ac2,' ')
                        AND NVL(xba1.ac3,' ')               = NVL(xba.ac3,' ')
                        AND NVL(xba1.ac4,' ')               = NVL(xba.ac4,' ')
                        AND NVL(xba1.ac5,' ')               = NVL(xba.ac5,' ')
                        AND xba1.period_name                    =  l_dest_period_name)
      -- Bug 7321087  End
      AND ROWNUM                               <= C_BATCH_COMMIT_SIZE;

            l_row_count := SQL%ROWCOUNT;
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_module => l_log_module
                  ,p_msg   => l_row_count
                              || 'analytical balances created '
                  ,p_level => C_LEVEL_STATEMENT
                  );
            END IF;
         END IF;

         IF l_row_count < C_BATCH_COMMIT_SIZE
         THEN
            l_return_value := TRUE;
            COMMIT;
            EXIT;
         END IF;

         COMMIT;

      END LOOP; --until there are no more balances to create in this period

      --Update the records in xla_balance_statuses.
      l_date := SYSDATE;

      UPDATE xla_balance_statuses xbs
         SET xbs.balance_status_code  = p_balance_status_code_not_sel
            ,xbs.effective_period_num = l_dest_effective_period_num
            ,last_update_date         = l_date
            ,last_updated_by          = l_user_id
            ,last_update_login        = l_login_id
            ,program_update_date      = l_date
            ,program_application_id   = l_prog_appl_id
            ,program_id               = l_prog_id
            ,request_id               = NVL(l_req_id, -1)
       WHERE xbs.application_id       = p_application_id
         AND xbs.ledger_id            = p_ledger_id
         AND xbs.balance_source_code  = NVL( p_balance_source_code
                                            ,xbs.balance_source_code
                                           )
         AND xbs.effective_period_num = p_source_effective_period_num
         AND xbs.balance_status_code  = p_balance_status_code_selected
         AND xbs.request_id           = NVL(l_req_id, -1);

         l_row_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_module => l_log_module
               ,p_msg   =>  l_row_count ||
                            ' xla_balance_statuses updated to '
                            || p_balance_status_code_not_sel
               ,p_level => C_LEVEL_STATEMENT
               );
         END IF;
   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.move_balances_forward_COMMIT');
END move_balances_forward_COMMIT;


FUNCTION check_create_period_balances
  ( p_application_id          IN INTEGER
   ,p_ledger_id               IN INTEGER
   ,p_balance_source_code     IN VARCHAR2
  )
RETURN BOOLEAN
IS
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
|                                                                       |
| ISSUES COMMITS                                                        |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
+======================================================================*/

l_min_bal_effective_period_num    INTEGER;
l_latest_effective_period_num     INTEGER;
l_return_value                    BOOLEAN;
l_user_id                         INTEGER;
l_login_id                        INTEGER;
l_date                            DATE;
l_prog_appl_id                    INTEGER;
l_prog_id                         INTEGER;
l_req_id                          INTEGER;
l_log_module                 VARCHAR2 (2000);

BEGIN

   l_user_id                     := xla_environment_pkg.g_usr_id;
   l_login_id                    := xla_environment_pkg.g_login_id;
   l_date                        := SYSDATE;
   l_prog_appl_id                := xla_environment_pkg.g_prog_appl_id;
   l_prog_id                     := xla_environment_pkg.g_prog_id;
   l_req_id                      := xla_environment_pkg.g_req_id;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.check_create_period_balances';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_application_id          :'
                      || p_application_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_ledger_id               :'
                         || p_ledger_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_balance_source_code     :'
                         || p_balance_source_code
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   SELECT MIN(xbs.effective_period_num)
     INTO l_min_bal_effective_period_num
     FROM xla_balance_statuses xbs
    WHERE xbs.application_id      = p_application_id
      AND xbs.ledger_id           = p_ledger_id
      AND xbs.balance_source_code = p_balance_source_code;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'Lowest balance status eff period num: ' ||
                          l_min_bal_effective_period_num
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   SELECT MAX(gps.effective_period_num)
     INTO l_latest_effective_period_num
     FROM gl_period_statuses gps
    WHERE gps.ledger_id              =  p_ledger_id
      AND gps.application_id         =  101
      AND gps.closing_status         IN ('O', 'C', 'P')
      AND gps.adjustment_period_flag =  'N';

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'l_latest_effective_period_num: '
                      || l_latest_effective_period_num
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   l_return_value :=TRUE;

   FOR i IN ( SELECT gps.effective_period_num
                FROM gl_period_statuses gps
               WHERE gps.ledger_id              =  p_ledger_id
                 AND gps.application_id         =  101
                 AND gps.closing_status         IN ('O', 'C', 'P')
                 AND gps.adjustment_period_flag =  'N'
                 AND gps.effective_period_num   >= l_min_bal_effective_period_num
                 AND gps.effective_period_num   <  l_latest_effective_period_num
              ORDER BY gps.effective_period_num
              )
   LOOP
      IF NOT move_balances_forward_COMMIT
                          ( p_application_id               => p_application_id
                           ,p_ledger_id                    => p_ledger_id
                           ,p_balance_source_code          => p_balance_source_code
                           ,p_source_effective_period_num  => i.effective_period_num
                           ,p_balance_status_code_selected => 'O'
                           ,p_balance_status_code_not_sel  => 'A'
                           )
      THEN
         l_return_value := FALSE;
         EXIT;
      END IF;

   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.check_create_period_balances');
END check_create_period_balances;


FUNCTION AUT_check_create_period_bals
  ( p_application_id          IN INTEGER
   ,p_ledger_id               IN INTEGER
   ,p_balance_source_code     IN VARCHAR2
  )
RETURN BOOLEAN
IS
PRAGMA AUTONOMOUS_TRANSACTION;
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
|                                                                       |
| ISSUES COMMITS                                                        |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
+======================================================================*/
l_return_value BOOLEAN;
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AUT_check_create_period_bals';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_application_id          :'
                      || p_application_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_ledger_id               :'
                         || p_ledger_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_balance_source_code     :'
                         || p_balance_source_code
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   l_return_value :=
           check_create_period_balances
               ( p_application_id          => p_application_id
                ,p_ledger_id               => p_ledger_id
                ,p_balance_source_code     => p_balance_source_code
               );

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.AUT_check_create_period_bals');
END AUT_check_create_period_bals;

FUNCTION lock_create_balance_statuses

RETURN BOOLEAN
IS

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
+======================================================================*/


CURSOR c_lock_control_statuses
IS
   SELECT 1
     FROM xla_bal_ctrl_lines_gt xbct
         ,xla_balance_statuses        xbs
    WHERE xbs.application_id          =  xbct.application_id
      AND xbs.ledger_id               =  xbct.ledger_id
      AND xbs.code_combination_id     =  xbct.code_combination_id
      AND xbs.balance_source_code     =  'C'
   FOR UPDATE OF xbs.ledger_id NOWAIT;

CURSOR c_lock_analytical_statuses
IS
   SELECT /*+ full(xblt) */ 1
     FROM xla_bal_anacri_lines_gt xblt
         ,xla_balance_statuses        xbs
    WHERE xbs.application_id          =  xblt.application_id
      AND xbs.ledger_id               =  xblt.ledger_id
      AND xbs.code_combination_id     =  xblt.code_combination_id
      AND xbs.balance_source_code     =  'A'
   FOR UPDATE OF xbs.ledger_id NOWAIT;

l_user_id                    INTEGER;
l_login_id                   INTEGER;
l_date                       DATE;
l_prog_appl_id               INTEGER;
l_prog_id                    INTEGER;
l_req_id                     INTEGER;

l_balance_status_code        VARCHAR2(1);
l_latest_open_eff_period_num NUMBER(15);

l_id_flex_code               VARCHAR2 ( 4);
l_chart_of_accounts_id       NUMBER   (15);

l_account_segment_column     VARCHAR2 (30);
l_balancing_segment_column   VARCHAR2 (30);

l_row_count                 NUMBER;

l_return_status           BOOLEAN;
l_log_module                 VARCHAR2 (2000);

BEGIN

   l_user_id                    := xla_environment_pkg.g_usr_id;
   l_login_id                   := xla_environment_pkg.g_login_id;
   l_date                       := SYSDATE;
   l_prog_appl_id               := xla_environment_pkg.g_prog_appl_id;
   l_prog_id                    := xla_environment_pkg.g_prog_id;
   l_req_id                     := xla_environment_pkg.g_req_id;

   l_id_flex_code               := 'GL#';

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.lock_create_balance_statuses';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'Start inserting in xla_balance_statuses'
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   --Create the missing records in xla_balance_statuses, if any.
   INSERT INTO xla_bal_statuses_gt
               ( application_id
                ,ledger_id
                ,code_combination_id
                ,balance_source_code
                ,balance_status_code
                ,effective_period_num
                ,natural_account_segment
                ,balancing_segment
                ,account_type
               )
          (
           SELECT DISTINCT
                  xbct.application_id
                 ,xbct.ledger_id
                 ,xbct.code_combination_id
                 ,'C'
                 ,'A'
                 , -1
                 ,'TO BE DETERMINED'
                 ,'TO BE DETERMINED'
                 ,'?'
             FROM xla_bal_ctrl_lines_gt xbct
                 ,xla_balance_statuses xbs
            WHERE xbs.application_id       (+)=  xbct.application_id
              AND xbs.ledger_id            (+)=  xbct.ledger_id
              AND xbs.code_combination_id  (+)=  xbct.code_combination_id
              AND xbs.balance_source_code  (+)=  'C'
              AND xbs.ledger_id               IS NULL

           UNION ALL

           SELECT DISTINCT
                  xbat.application_id
                 ,xbat.ledger_id
                 ,xbat.code_combination_id
                 ,'A'
                 ,'A'
                 , -1
                 ,'TO BE DETERMINED'
                 ,'TO BE DETERMINED'
                 ,'?'
             FROM xla_bal_anacri_lines_gt    xbat
                 ,xla_balance_statuses xbs
            WHERE xbs.application_id       (+)=  xbat.application_id
              AND xbs.ledger_id            (+)=  xbat.ledger_id
              AND xbs.code_combination_id  (+)=  xbat.code_combination_id
              AND xbs.balance_source_code  (+)=  'A'
              AND xbs.ledger_id               IS NULL

          );

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => l_row_count  ||
                      ' records inserted in xla_bal_statuses_gt'
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

   FOR i IN (
              SELECT DISTINCT
                     ledger_id
                FROM xla_bal_statuses_gt xbs
            )
   LOOP

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => 'ledger_id                 : ' || i.ledger_id
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      SELECT gle.chart_of_accounts_id
            ,gle.bal_seg_column_name
        INTO l_chart_of_accounts_id
            ,l_balancing_segment_column
        FROM gl_ledgers gle
       WHERE gle.ledger_id = i.ledger_id;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => 'l_chart_of_accounts_id    : ' || l_chart_of_accounts_id
          ,p_level => C_LEVEL_STATEMENT
         );
         trace
         (p_module => l_log_module
         ,p_msg   => 'l_balancing_segment_column: ' || l_balancing_segment_column
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      SELECT MAX(gps2.effective_period_num)
        INTO l_latest_open_eff_period_num
        FROM gl_period_statuses gps2
       WHERE gps2.ledger_id              =  i.ledger_id
         AND gps2.application_id         =  101
         AND gps2.closing_status         IN ('O', 'C', 'P')
         AND gps2.adjustment_period_flag =  'N';

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => 'l_latest_open_eff_period_num : '
                      || l_latest_open_eff_period_num
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      IF FND_FLEX_APIS.get_segment_column( 101
                                           ,l_id_flex_code
                                           ,l_chart_of_accounts_id
                                           ,'GL_ACCOUNT'
                                           ,l_account_segment_column
                                         )

      THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            (p_module => l_log_module
             ,p_msg   => 'GL_ACCOUNT segment column name: '
                         || l_account_segment_column
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;
      ELSE
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_module => l_log_module
               ,p_msg   => 'EXCEPTION: ' ||
                           'Unable to retrieve segment names for ledger_id '
                            || i.ledger_id
               ,p_level => C_LEVEL_EXCEPTION
               );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: ' ||
                           'Unable to retrieve segment names for ledger_id '
                            || i.ledger_id);
      END IF;

      EXECUTE IMMEDIATE
      '
      UPDATE xla_bal_statuses_gt xbst
         SET xbst.effective_period_num   = ' ||l_latest_open_eff_period_num || '
            ,(
               xbst.natural_account_segment
              ,xbst.balancing_segment
              ,xbst.account_type
             )
             =
             ( SELECT ' || l_balancing_segment_column || '
                     ,' || l_account_segment_column   || '
                     ,account_type
                FROM gl_code_combinations   gcc
               WHERE gcc.code_combination_id  = xbst.code_combination_id
             )
      WHERE xbst.ledger_id =  ' || i.ledger_id;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => l_row_count   ||
                      ' records updated in xla_bal_statuses_gt'
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

   END LOOP;

   INSERT INTO xla_balance_statuses
               ( application_id
                ,ledger_id
                ,code_combination_id
                ,balance_source_code
                ,balance_status_code
                ,effective_period_num
                ,natural_account_segment
                ,balancing_segment
                ,account_type
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
                ,last_update_login
                ,program_update_date
                ,program_application_id
                ,program_id
                ,request_id
               )
       SELECT    application_id
                ,ledger_id
                ,code_combination_id
                ,balance_source_code
                ,balance_status_code
                ,effective_period_num
                ,natural_account_segment
                ,balancing_segment
                ,account_type
                ,l_date
                ,l_user_id
                ,l_date
                ,l_user_id
                ,l_login_id
                ,l_date
                ,l_prog_appl_id
                ,l_prog_id
                ,NVL(l_req_id, -1)
         FROM   xla_bal_statuses_gt xbst;

   l_row_count := SQL%ROWCOUNT;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   =>  l_row_count ||
                      ' records inserted in xla_balance_statuses'
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => ' Start locking xla_balance_statuses'
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   --Lock the records in xla_balance_statuses.

   OPEN  c_lock_control_statuses;
   CLOSE c_lock_control_statuses;
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'Records in xla_balance_statuses (control) have been locked.'
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   OPEN  c_lock_analytical_statuses;
   CLOSE c_lock_analytical_statuses;
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'Records in xla_balance_statuses (anacri) have been locked.'
          ,p_level => C_LEVEL_STATEMENT
         );
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
   IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'Cannot lock xla_balance_statuses records'
          ,p_level => C_LEVEL_ERROR
         );
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.lock_create_balance_statuses');
END lock_create_balance_statuses;

FUNCTION calculate_control_balances
  ( p_application_id           IN INTEGER
   ,p_ledger_id                IN INTEGER
   ,p_effective_period_num     IN INTEGER
   ,p_operation_code           IN VARCHAR2 --'F' Finalize
                                           --'A' Add
                                           --'R' Remove
  ) RETURN BOOLEAN
IS
/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
|                                                                       |
+======================================================================*/

CURSOR lc_control_contributions
IS
SELECT DISTINCT ctr.application_id
      ,ctr.ledger_id
      ,NVL(xba.period_year, ctr.period_year) contributed_period_year
      ,ctr.period_name
      ,ctr.period_year
      ,ctr.effective_period_num
      ,ctr.code_combination_id
      ,ctr.party_type_code
      ,ctr.party_id
      ,ctr.party_site_id
      ,ctr.contribution_dr
      ,ctr.contribution_cr
      ,ctr.contribution_draft_dr
      ,ctr.contribution_draft_cr
      ,NVL2( contribution_dr
            ,NVL2( contribution_cr
                   ,DECODE( SIGN(contribution_dr - contribution_cr)
                           ,1
                           ,contribution_dr - contribution_cr
                           ,0
                          )
                   ,DECODE( SIGN(contribution_dr)
                           ,1
                           ,contribution_dr
                           ,0
                          )
                  )
             ,NVL2( contribution_cr
                   ,DECODE( SIGN(contribution_cr)
                           ,-1
                           ,-contribution_cr
                           ,NULL
                          )
                   ,NULL
                  )
           ) net_contribution_dr
       ,NVL2( contribution_cr
             ,NVL2( contribution_dr
                   ,DECODE( SIGN(contribution_cr - contribution_dr)
                           ,1
                           ,contribution_cr - contribution_dr
                           ,0
                          )
                   ,DECODE( SIGN(contribution_cr)
                           ,1
                           ,contribution_cr
                           ,0
                          )
                  )
             ,NVL2( contribution_dr
                   ,DECODE( SIGN(contribution_dr)
                           ,-1
                           ,-contribution_dr
                           ,NULL
                          )
                   ,NULL
                  )
           ) net_contribution_cr
       ,NVL2( contribution_draft_dr
             ,NVL2( contribution_draft_cr
                   ,DECODE( SIGN(contribution_draft_dr - contribution_draft_cr)
                           ,1
                           ,contribution_draft_dr - contribution_draft_cr
                           ,0
                          )
                   ,DECODE( SIGN(contribution_draft_dr)
                           ,1
                           ,contribution_draft_dr
                           ,0
                          )
                  )
             ,NVL2( contribution_draft_cr
                   ,DECODE( SIGN(contribution_draft_cr)
                           ,-1
                           ,-contribution_draft_cr
                           ,NULL
                          )
                   ,NULL
                  )
           ) net_contribution_draft_dr
       ,NVL2( contribution_draft_cr
             ,NVL2( contribution_draft_dr
                   ,DECODE( SIGN(contribution_draft_cr - contribution_draft_dr)
                           ,1
                           ,contribution_draft_cr - contribution_draft_dr
                           ,0
                          )
                   ,DECODE( SIGN(contribution_draft_cr)
                           ,1
                           ,contribution_draft_cr
                           ,0
                          )
                  )
             ,NVL2( contribution_draft_dr
                   ,DECODE( SIGN(contribution_draft_dr)
                           ,-1
                           ,-contribution_draft_dr
                           ,NULL
                          )
                   ,NULL
                  )
           ) net_contribution_draft_cr
      ,DECODE( SIGN ( NVL(xba.beginning_balance_dr, 0) + NVL(ctr.contribution_dr, 0)
                     -NVL(xba.beginning_balance_cr,0) - NVL(ctr.contribution_cr, 0)
                    )
              ,1
              ,  NVL(ctr.contribution_dr, 0) - NVL(ctr.contribution_cr, 0)
                                     - NVL(xba.beginning_balance_cr, 0)
              ,- NVL(xba.beginning_balance_dr, 0)
             )    change_balance_dr
      ,DECODE( SIGN ( NVL(xba.beginning_balance_cr, 0) + NVL(ctr.contribution_cr , 0)
                     -NVL(xba.beginning_balance_dr, 0) - NVL(ctr.contribution_dr, 0)
                    )
              ,1
              ,  NVL(ctr.contribution_cr, 0) - NVL(ctr.contribution_dr, 0)
                                     - NVL(xba.beginning_balance_dr, 0)
              ,- NVL(xba.beginning_balance_cr, 0)
             )    change_balance_cr
      ,DECODE( SIGN (  NVL(xba.draft_beginning_balance_dr, 0)
                     + NVL(ctr.contribution_draft_dr, 0)
                     - NVL(xba.draft_beginning_balance_cr, 0)
                     - NVL(ctr.contribution_draft_cr, 0)
                    )
              ,1
              ,NVL(ctr.contribution_draft_dr, 0) - NVL(ctr.contribution_draft_cr, 0)
                                         - NVL(xba.draft_beginning_balance_cr, 0)
              ,-NVL(xba.draft_beginning_balance_dr, 0)
             )    change_draft_balance_dr
      ,DECODE( SIGN (  NVL(xba.draft_beginning_balance_cr, 0)
                     + NVL(ctr.contribution_draft_cr, 0)
                     - NVL(xba.draft_beginning_balance_dr, 0)
                     - NVL(ctr.contribution_draft_dr, 0)
                    )
              ,1
              ,NVL(ctr.contribution_draft_cr, 0) - NVL(ctr.contribution_draft_dr, 0)
                                         - NVL(xba.draft_beginning_balance_dr, 0)
              ,-NVL(xba.draft_beginning_balance_cr, 0)
             )    change_draft_balance_cr
      ,ctr.balance_status_eff_per_num
  FROM xla_bal_ctrl_ctrbs_gt ctr
      ,xla_control_balances           xba
WHERE ctr.application_id          =  p_application_id
  AND ctr.ledger_id               =  p_ledger_id
  AND ctr.effective_period_num    =  p_effective_period_num
  AND xba.application_id       (+)=  ctr.application_id
  AND xba.ledger_id            (+)=  ctr.ledger_id
  AND xba.code_combination_id  (+)=  ctr.code_combination_id
  AND xba.party_type_code      (+)=  ctr.party_type_code
  AND xba.party_id             (+)=  ctr.party_id
  AND xba.party_site_id        (+)=  ctr.party_site_id
  AND xba.first_period_flag    (+)=  'Y'
  AND xba.period_year          (+)>= ctr.period_year;

TYPE lt_table_varchar2_1          IS TABLE OF VARCHAR2(1);
TYPE lt_table_varchar2_15         IS TABLE OF VARCHAR2(15);
TYPE lt_table_varchar2_25         IS TABLE OF VARCHAR2(25);
TYPE lt_table_integer             IS TABLE OF INTEGER;
TYPE lt_table_number              IS TABLE OF NUMBER;
TYPE lt_table_number_15           IS TABLE OF NUMBER(15);

la_application_id            lt_table_number;
la_ledger_id                 lt_table_number_15;
la_party_type_code           lt_table_varchar2_1;
la_contributed_period_year   lt_table_varchar2_15;
la_contribution_period_name  lt_table_varchar2_15;
la_contribution_period_year  lt_table_number_15;
la_contribution_eff_per_num  lt_table_number_15;
la_code_combination_id       lt_table_integer;
la_party_id                  lt_table_integer;
la_party_site_id             lt_table_integer;
la_balance_stat_eff_per_num  lt_table_integer;
la_contribution_dr           lt_table_number;
la_contribution_cr           lt_table_number;
la_contribution_draft_dr     lt_table_number;
la_contribution_draft_cr     lt_table_number;
la_net_contribution_dr       lt_table_number;
la_net_contribution_cr       lt_table_number;
la_net_contribution_draft_dr lt_table_number;
la_net_contribution_draft_cr lt_table_number;
la_change_balance_dr         lt_table_number;
la_change_balance_cr         lt_table_number;
la_change_draft_balance_dr   lt_table_number;
la_change_draft_balance_cr   lt_table_number;
l_begin_bal_dr               NUMBER;
l_begin_bal_cr               NUMBER;

l_row_count                 NUMBER;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.calculate_control_balances';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_application_id       :' || p_application_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_ledger_id            :' || p_ledger_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_effective_period_num :' || p_effective_period_num
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_operation_code       :' || p_operation_code
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   OPEN lc_control_contributions;

   LOOP --contributions are collected in chunks
      FETCH lc_control_contributions
      BULK COLLECT
              INTO la_application_id
                  ,la_ledger_id
                  ,la_contributed_period_year
                  ,la_contribution_period_name
                  ,la_contribution_period_year
                  ,la_contribution_eff_per_num
                  ,la_code_combination_id
                  ,la_party_type_code
                  ,la_party_id
                  ,la_party_site_id
                  ,la_contribution_dr
                  ,la_contribution_cr
                  ,la_contribution_draft_dr
                  ,la_contribution_draft_cr
                  ,la_net_contribution_dr
                  ,la_net_contribution_cr
                  ,la_net_contribution_draft_dr
                  ,la_net_contribution_draft_cr
                  ,la_change_balance_dr
                  ,la_change_balance_cr
                  ,la_change_draft_balance_dr
                  ,la_change_draft_balance_cr
                  ,la_balance_stat_eff_per_num
      LIMIT C_BULK_LIMIT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => 'Processing ' || la_code_combination_id.COUNT
                                   || ' contributions'
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      IF la_code_combination_id.COUNT = 0
      THEN
            EXIT;
      END IF;

/*
      FOR i IN 1..la_code_combination_id.LAST
      LOOP
         trace(l_log_module,'CONTRIBUTION                    :'
                                        || i ,C_LEVEL_STATEMENT);
         trace(l_log_module,'contributed year                :'
                                        || la_contributed_period_year(i) ,C_LEVEL_STATEMENT);
         trace(l_log_module,'ccid                            :'
                                        || la_code_combination_id(i),C_LEVEL_STATEMENT);
         trace(l_log_module,'Party info                      :'
                                        || la_party_type_code(i) || ','
                                        || la_party_id(i) || ','
                                        || la_party_site_id(i) ,C_LEVEL_STATEMENT);
         trace(l_log_module,'Contribution                    :'
                                        || la_contribution_dr(i) || ','
                                        || la_contribution_cr(i) || ','
                                        || la_contribution_draft_dr(i) || ','
                                        || la_contribution_draft_cr(i) ,C_LEVEL_STATEMENT);
         trace(l_log_module,'Net Contribution                :'
                                        || la_net_contribution_dr(i) || ','
                                        || la_net_contribution_cr(i) || ','
                                        || la_net_contribution_draft_dr(i) || ','
                                        || la_net_contribution_draft_cr(i) ,C_LEVEL_STATEMENT);
         trace(l_log_module,'Begin balance variation         :'
                                        || la_change_balance_dr(i) || ','
                                        || la_change_balance_cr(i) || ','
                                        || la_change_draft_balance_dr(i) || ','
                                        || la_change_draft_balance_cr(i),C_LEVEL_STATEMENT);
         trace(l_log_module,'Balance stat eff per num        :'
                                        ||  la_balance_stat_eff_per_num(i), 1);
         END LOOP;
*/

      g_date := SYSDATE;

      --Update balances same year
      FORALL i IN 1..la_code_combination_id.LAST
         UPDATE xla_control_balances xba
            SET xba.beginning_balance_dr  =
                        DECODE( xba.period_name
                               ,la_contribution_period_name (i)
                               ,xba.beginning_balance_dr
                               ,NVL2( la_contribution_dr (i)
                                     ,NVL(xba.beginning_balance_dr, 0) + la_contribution_dr (i)
                                     ,xba.beginning_balance_dr
                                    )
                              )
                ,xba.beginning_balance_cr =
                        DECODE( xba.period_name
                               ,la_contribution_period_name (i)
                               ,xba.beginning_balance_cr
                               ,NVL2( la_contribution_cr (i)
                                     ,NVL(xba.beginning_balance_cr, 0) + la_contribution_cr (i)
                                     ,xba.beginning_balance_cr
                                    )
                              )
                ,xba.period_balance_dr    =
                        DECODE( xba.period_name
                               ,la_contribution_period_name (i)
                               ,NVL2( la_contribution_dr (i)
                                     ,NVL(xba.period_balance_dr, 0) + la_contribution_dr (i)
                                     ,xba.period_balance_dr
                                    )
                               ,xba.period_balance_dr
                              )
                ,xba.period_balance_cr    =
                        DECODE( xba.period_name
                               ,la_contribution_period_name (i)
                               ,NVL2( la_contribution_cr (i)
                                     ,NVL(xba.period_balance_cr, 0) + la_contribution_cr (i)
                                     ,xba.period_balance_cr
                                    )
                               ,xba.period_balance_cr
                              )
                ,xba.draft_beginning_balance_dr =
                        DECODE( xba.period_name
                               ,la_contribution_period_name (i)
                               ,xba.draft_beginning_balance_dr
                               ,NVL2( la_contribution_draft_dr (i)
                                     ,NVL(xba.draft_beginning_balance_dr, 0) + la_contribution_draft_dr (i)
                                     ,xba.draft_beginning_balance_dr
                                    )
                              )
                ,xba.draft_beginning_balance_cr =
                        DECODE( xba.period_name
                               ,la_contribution_period_name (i)
                               ,xba.draft_beginning_balance_cr
                               ,NVL2( la_contribution_draft_cr (i)
                                     ,NVL(xba.draft_beginning_balance_cr, 0) + la_contribution_draft_cr (i)
                                     ,xba.draft_beginning_balance_cr
                                    )
                              )
                ,xba.period_draft_balance_dr    =
                        DECODE( xba.period_name
                               ,la_contribution_period_name (i)
                               ,NVL2( la_contribution_draft_dr (i)
                                     ,NVL(xba.period_draft_balance_dr, 0) + la_contribution_draft_dr (i)
                                     ,xba.period_draft_balance_dr
                                    )
                               ,xba.period_draft_balance_dr
                              )
                ,xba.period_draft_balance_cr    =
                        DECODE( xba.period_name
                               ,la_contribution_period_name (i)
                               ,NVL2( la_contribution_draft_cr (i)
                                     ,NVL(xba.period_draft_balance_cr, 0) + la_contribution_draft_cr (i)
                                     ,xba.period_draft_balance_cr
                                    )
                               ,xba.period_draft_balance_cr
                              )
                ,first_period_flag              =
                        DECODE( xba.first_period_flag
                               ,'Y'
                               ,DECODE( xba.period_name
                                       ,la_contribution_period_name (i)
                                       ,'Y'
                                       ,'N'
                                      )
                               ,'N'
                              )
                ,creation_date              = g_date
                ,created_by                 = g_user_id
                ,last_update_date           = g_date
                ,last_updated_by            = g_user_id
                ,last_update_login          = g_login_id
                ,program_update_date        = g_date
                ,program_application_id     = g_prog_appl_id
                ,program_id                 = g_prog_id
                ,request_id                 = g_req_id
          WHERE xba.application_id       = la_application_id(i)
            AND xba.ledger_id            = la_ledger_id(i)
            AND xba.code_combination_id  = la_code_combination_id(i)
            AND xba.party_type_code      = la_party_type_code(i)
            AND xba.party_id             = la_party_id(i)
            AND xba.party_site_id        = la_party_site_id(i)
            AND xba.initial_balance_flag = 'N'
            AND xba.period_name IN
                        ( SELECT gps.period_name
                            FROM xla_bal_period_stats_gt gps
                           WHERE gps.ledger_id                  =  la_ledger_id(i)
                             AND gps.period_year                =  la_contribution_period_year(i)
                             AND gps.effective_period_num       >= la_contribution_eff_per_num(i)
                        )
            AND la_contributed_period_year(i)  =  la_contribution_period_year(i);

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => l_row_count || 'Same year balances updated '
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      g_date := SYSDATE;

      --UPDATE balances following years
      FORALL i IN 1..la_code_combination_id.LAST
         UPDATE xla_control_balances xba
            SET xba.beginning_balance_dr       =
                  DECODE( la_change_balance_dr(i)
                         ,0
                         ,xba.beginning_balance_dr
                         ,NVL(xba.beginning_balance_dr, 0)
                          + la_change_balance_dr(i)
                      )
               ,xba.beginning_balance_cr       =
                  DECODE( la_change_balance_cr(i)
                         ,0
                         ,xba.beginning_balance_cr
                         ,NVL(xba.beginning_balance_cr, 0)
                          + la_change_balance_cr(i)
                      )
               ,xba.draft_beginning_balance_dr =
                  DECODE( la_change_draft_balance_dr(i)
                         ,0
                         ,xba.draft_beginning_balance_dr
                         ,NVL(xba.draft_beginning_balance_dr, 0)
                          + la_change_draft_balance_dr(i)
                      )
               ,xba.draft_beginning_balance_cr =
                  DECODE( la_change_draft_balance_cr(i)
                         ,0
                         ,xba.draft_beginning_balance_cr
                         ,NVL(xba.draft_beginning_balance_cr, 0)
                          + la_change_draft_balance_cr(i)
                      )
               ,xba.first_period_flag              =
                   (SELECT gps2.first_period_in_year_flag
                      FROM xla_bal_period_stats_gt gps2
                     WHERE gps2.ledger_id              =  la_ledger_id(i)
                       AND gps2.period_name            =  xba.period_name
                   )
               ,creation_date              = g_date
               ,created_by                 = g_user_id
               ,last_update_date           = g_date
               ,last_updated_by            = g_user_id
               ,last_update_login          = g_login_id
               ,program_update_date        = g_date
               ,program_application_id     = g_prog_appl_id
               ,program_id                 = g_prog_id
               ,request_id                 = g_req_id
          WHERE xba.application_id       = la_application_id(i)
            AND xba.ledger_id            = la_ledger_id(i)
            AND xba.code_combination_id  = la_code_combination_id(i)
            AND xba.party_type_code      = la_party_type_code(i)
            AND xba.party_id             = la_party_id(i)
            AND xba.party_site_id        = la_party_site_id(i)
            AND xba.initial_balance_flag = 'N'
            AND xba.period_name IN
              ( SELECT gps.period_name
                  FROM xla_bal_period_stats_gt gps
                 WHERE gps.ledger_id                 =  la_ledger_id(i)
                   AND gps.period_year               = la_contributed_period_year(i)
               )
            AND la_contributed_period_year(i) > la_contribution_period_year(i);

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => l_row_count
                     || ' following years balances updated '
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      --Create new balances
      IF p_operation_code <> 'R'
      THEN
         g_date := SYSDATE;

         FOR i IN 1..la_code_combination_id.LAST LOOP
	  	      l_begin_bal_dr := null; -- Bug 7608545 - Reset begin_bal_dr to null
		      l_begin_bal_cr := null; --7608545 - Reset begin_bal_cr to null
	              FOR j IN (select nvl(beginning_balance_dr,0) + nvl(period_balance_dr,0) begin_dr
                               ,nvl(beginning_balance_cr,0) + nvl(period_balance_cr,0) begin_cr
                           from(select xcb.*
                                  from xla_control_balances xcb, gl_period_statuses gps
                                 where xcb.application_id = la_application_id(i)
                                   and xcb.application_id = gps.application_id
                                   and xcb.ledger_id = gps.ledger_id
                                   and xcb.ledger_id = la_ledger_id(i)
                                   and xcb.period_name = gps.period_name
                                   and xcb.code_combination_id = la_code_combination_id(i)
                                   and xcb.party_type_code =  la_party_type_code(i)
                                   and xcb.party_id =  la_party_id(i)
                                   and xcb.party_site_id =  la_party_site_id(i)
                                   and gps.effective_period_num < la_contribution_eff_per_num(i)
                                 order by gps.effective_period_num desc)
                          where rownum = 1) LOOP
                   l_begin_bal_dr := j.begin_dr;
                   l_begin_bal_cr := j.begin_cr;

               END LOOP;

            INSERT INTO xla_control_balances xba
                  ( application_id
                   ,ledger_id
                   ,code_combination_id
                   ,party_type_code
                   ,party_id
                   ,party_site_id
                   ,period_name
                   ,period_year
                   ,first_period_flag
                   ,beginning_balance_dr
                   ,beginning_balance_cr
                   ,period_balance_dr
                   ,period_balance_cr
                   ,draft_beginning_balance_dr
                   ,draft_beginning_balance_cr
                   ,period_draft_balance_dr
                   ,period_draft_balance_cr
                   ,initial_balance_flag
                   ,creation_date
                   ,created_by
                   ,last_update_date
                   ,last_updated_by
                   ,last_update_login
                   ,program_update_date
                   ,program_application_id
                   ,program_id
                   ,request_id
				   ,effective_period_num
                  )
                  (
                     SELECT la_application_id(i)
                           ,la_ledger_id(i)
                           ,la_code_combination_id(i)
                           ,la_party_type_code(i)
                           ,la_party_id(i)
                           ,la_party_site_id(i)
                           ,gps.period_name
                           ,gps.period_year
                           ,DECODE( gps.first_period_in_year_flag
                                   ,'Y'
                                   ,'Y'
                                    ,CASE WHEN l_begin_bal_dr IS NULL AND l_begin_bal_cr IS NULL THEN
                                             DECODE( gps.period_name

                                           ,la_contribution_period_name(i)
                                           ,'Y'
                                           ,'N'
                                          )
					        ELSE 'N' END
                                  )
                           ,NULLIF(NVL(DECODE( gps.period_year
                                   ,la_contribution_period_year(i)
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,NULL
                                           ,la_contribution_dr(i)
                                          )
                                   ,la_net_contribution_dr(i)
                                    ),0) +  nvl(l_begin_bal_dr,0)
				  ,0) --beginning_balance_dr
                           ,NULLIF(NVL(DECODE( gps.period_year
                                   ,la_contribution_period_year(i)
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,NULL
                                           ,la_contribution_cr(i)
                                          )
                                   ,la_net_contribution_cr(i)
                                     ),0) +   nvl(l_begin_bal_cr,0)
				   ,0) --beginning_balance_cr
                           ,DECODE( gps.period_year
                                   ,la_contribution_period_year(i)
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,la_contribution_dr(i)
                                           ,NULL
                                          )
                                   ,NULL
                                  )  --period_balance_dr
                           ,DECODE( gps.period_year
                                   ,la_contribution_period_year(i)
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,la_contribution_cr(i)
                                           ,NULL
                                          )
                                   ,NULL
                                  )  --period_balance_cr
                           ,DECODE( gps.period_year
                                   ,la_contribution_period_year(i)
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,NULL
                                           ,la_contribution_draft_dr(i)
                                          )
                                   ,la_net_contribution_draft_dr(i)
                                  ) --draft_beginning_balance_dr
                           ,DECODE( gps.period_year
                                   ,la_contribution_period_year(i)
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,NULL
                                           ,la_contribution_draft_cr(i)
                                          )
                                   ,la_net_contribution_draft_cr(i)
                                  ) --draft_beginning_balance_cr
                           ,DECODE( gps.period_year
                                   ,la_contribution_period_year(i)
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,la_contribution_draft_dr(i)
                                           ,NULL
                                          )
                                   ,NULL
                                  )  --period_draft_balance_dr
                           ,DECODE( gps.period_year
                                   ,la_contribution_period_year(i)
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,la_contribution_draft_cr(i)
                                           ,NULL
                                          )
                                   ,NULL
                                  )  --period_draft_balance_cr
                           ,'N'
                           ,g_date
                           ,g_user_id
                           ,g_date
                           ,g_user_id
                           ,g_login_id
                           ,g_date
                           ,g_prog_appl_id
                           ,g_prog_id
                           ,g_req_id
						   ,gps.effective_period_num
                       FROM xla_bal_period_stats_gt gps
                           ,xla_control_balances       xba
                      WHERE gps.ledger_id                  =  la_ledger_id (i)
                        AND gps.effective_period_num       >= la_contribution_eff_per_num(i)
                        AND gps.effective_period_num       <= la_balance_stat_eff_per_num(i)
                        AND xba.application_id          (+)=  la_application_id(i)
                        AND xba.ledger_id               (+)=  la_ledger_id(i)
                        AND xba.code_combination_id     (+)=  la_code_combination_id(i)
                        AND xba.party_type_code         (+)=  la_party_type_code(i)
                        AND xba.party_id                (+)=  la_party_id(i)
                        AND xba.party_site_id           (+)=  la_party_site_id(i)
                        AND xba.period_name             (+)=  gps.period_name
                        AND xba.ledger_id                  IS NULL
                   );

          l_row_count := SQL%ROWCOUNT;

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace
            ( p_module => l_log_module
             ,p_msg    => l_row_count || 'New balances inserted '
             ,p_level  => C_LEVEL_STATEMENT
            );
          END IF;
	  END LOOP;
       END IF; --p_operation_code

   END LOOP; --process the next chunk of contributions

   CLOSE lc_control_contributions;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.calculate_control_balances');
END calculate_control_balances;

FUNCTION calculate_analytical_balances
  ( p_application_id           IN INTEGER
   ,p_ledger_id                IN INTEGER
   ,p_effective_period_num     IN INTEGER
   ,p_operation_code           IN VARCHAR2 --'F' Finalize
                                           --'A' Add
                                           --'R' Remove
  ) RETURN BOOLEAN
IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
+======================================================================*/

--C_DUMMY                         CONSTANT VARCHAR2(30) := ' ';

CURSOR lc_analytical_contributions
IS
SELECT ctr.application_id
      ,ctr.ledger_id
      ,NVL(xba.period_year, ctr.period_year) contributed_period_year
      ,ctr.period_name
      ,ctr.period_year
      ,ctr.effective_period_num
      ,ctr.code_combination_id
      ,ctr.analytical_criterion_code
      ,ctr.analytical_criterion_type_code
      ,ctr.amb_context_code
      ,ctr.ac1
      ,ctr.ac2
      ,ctr.ac3
      ,ctr.ac4
      ,ctr.ac5
      ,ctr.contribution_dr
      ,ctr.contribution_cr
      ,NVL2( contribution_dr
            ,NVL2( contribution_cr
                   ,DECODE( SIGN(contribution_dr - contribution_cr)
                           ,1
                           ,contribution_dr - contribution_cr
                           ,0
                          )
                   ,DECODE( SIGN(contribution_dr)
                           ,1
                           ,contribution_dr
                           ,0
                          )
                  )
             ,NVL2( contribution_cr
                   ,DECODE( SIGN(contribution_cr)
                           ,-1
                           ,-contribution_cr
                           ,NULL
                          )
                   ,NULL
                  )
           ) net_contribution_dr
       ,NVL2( contribution_cr
             ,NVL2( contribution_dr
                   ,DECODE( SIGN(contribution_cr - contribution_dr)
                           ,1
                           ,contribution_cr - contribution_dr
                           ,0
                          )
                   ,DECODE( SIGN(contribution_cr)
                           ,1
                           ,contribution_cr
                           ,0
                          )
                  )
             ,NVL2( contribution_dr
                   ,DECODE( SIGN(contribution_dr)
                           ,-1
                           ,-contribution_dr
                           ,NULL
                          )
                   ,NULL
                  )
           ) net_contribution_cr
      ,DECODE( SIGN ( NVL(xba.beginning_balance_dr, 0) + NVL(ctr.contribution_dr, 0)
                     -NVL(xba.beginning_balance_cr,0) - NVL(ctr.contribution_cr, 0)
                    )
              ,1
              ,  NVL(ctr.contribution_dr, 0) - NVL(ctr.contribution_cr, 0)
                                     - NVL(xba.beginning_balance_cr, 0)
              ,- NVL(xba.beginning_balance_dr, 0)
             )    change_balance_dr
      ,DECODE( SIGN ( NVL(xba.beginning_balance_cr, 0) + NVL(ctr.contribution_cr , 0)
                     -NVL(xba.beginning_balance_dr, 0) - NVL(ctr.contribution_dr, 0)
                    )
              ,1
              ,  NVL(ctr.contribution_cr, 0) - NVL(ctr.contribution_dr, 0)
                                     - NVL(xba.beginning_balance_dr, 0)
              ,- NVL(xba.beginning_balance_cr, 0)
             )    change_balance_cr
      ,ctr.balance_status_eff_per_num
      ,xbh.year_end_carry_forward_code
      ,ctr.account_type
 FROM xla_bal_ac_ctrbs_gt            ctr
     ,xla_analytical_hdrs_b          xbh
     ,xla_ac_balances                xba
WHERE  ctr.application_id = p_application_id
       AND ctr.ledger_id = p_ledger_id
       AND ctr.effective_period_num = p_effective_period_num
       AND xbh.analytical_criterion_code = ctr.analytical_criterion_code
       AND xbh.analytical_criterion_type_code = ctr.analytical_criterion_type_code
       AND xbh.amb_context_code = ctr.amb_context_code
       AND xba.application_id (+)  = ctr.application_id
       AND xba.ledger_id (+)  = ctr.ledger_id
       AND xba.code_combination_id (+)  = ctr.code_combination_id
       AND xba.analytical_criterion_code (+)  = ctr.analytical_criterion_code
       AND xba.analytical_criterion_type_code (+)  = ctr.analytical_criterion_type_code
       AND xba.amb_context_code (+)  = ctr.amb_context_code
       AND NVL(xba.ac1 (+) ,' ') = NVL(ctr.ac1,' ')
       AND NVL(xba.ac5 (+) ,' ') = NVL(ctr.ac5,' ')
       AND NVL(xba.ac2 (+) ,' ') = NVL(ctr.ac2,' ')
       AND NVL(xba.ac3 (+) ,' ') = NVL(ctr.ac3,' ')
       AND NVL(xba.ac4 (+) ,' ') = NVL(ctr.ac4,' ')
       AND xba.first_period_flag (+)  = 'Y'
       AND xba.period_year (+)  >= ctr.period_year
       AND xbh.balancing_flag <> 'N'; --Bug 8895800 : Balances should be calculated based on the setup;

TYPE lt_table_varchar2_1          IS TABLE OF VARCHAR2(1);
TYPE lt_table_varchar2_15         IS TABLE OF VARCHAR2(15);
TYPE lt_table_varchar2_25         IS TABLE OF VARCHAR2(25);
TYPE lt_table_varchar2_30         IS TABLE OF VARCHAR2(30);
TYPE lt_table_integer             IS TABLE OF INTEGER;
TYPE lt_table_number              IS TABLE OF NUMBER;
TYPE lt_table_number_15           IS TABLE OF NUMBER(15);

la_application_id                 lt_table_number;
la_ledger_id                      lt_table_number_15;
la_contributed_period_year        lt_table_varchar2_15;
la_contribution_period_name       lt_table_varchar2_15;
la_contribution_period_year       lt_table_number_15;
la_contribution_eff_per_num       lt_table_number_15;
la_code_combination_id            lt_table_integer;

la_analytical_criterion_code      lt_table_varchar2_30;
la_anacri_type_code               lt_table_varchar2_1;
la_amb_context_code               lt_table_varchar2_30;
la_ac1                            lt_table_varchar2_30;
la_ac2                            lt_table_varchar2_30;
la_ac3                            lt_table_varchar2_30;
la_ac4                            lt_table_varchar2_30;
la_ac5                            lt_table_varchar2_30;
la_balance_stat_eff_per_num       lt_table_integer;
la_contribution_dr                lt_table_number;
la_contribution_cr                lt_table_number;
la_contribution_draft_dr          lt_table_number;
la_contribution_draft_cr          lt_table_number;
la_net_contribution_dr            lt_table_number;
la_net_contribution_cr            lt_table_number;
la_net_contribution_draft_dr      lt_table_number;
la_net_contribution_draft_cr      lt_table_number;
la_change_balance_dr              lt_table_number;
la_change_balance_cr              lt_table_number;
la_change_draft_balance_dr        lt_table_number;
la_change_draft_balance_cr        lt_table_number;
la_year_end_carry_forward_code    lt_table_varchar2_1;
la_account_type                   lt_table_varchar2_1;


l_row_count                       NUMBER;

l_log_module                      VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.calculate_analytical_balances';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_application_id       :' || p_application_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_ledger_id            :' || p_ledger_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_effective_period_num :' || p_effective_period_num
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_operation_code       :' || p_operation_code
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;


la_application_id                :=lt_table_number();
la_ledger_id                     :=lt_table_number_15();
la_contributed_period_year         :=lt_table_varchar2_15();
la_contribution_period_name        :=lt_table_varchar2_15();
la_contribution_period_year        :=lt_table_number_15();
la_contribution_eff_per_num        :=lt_table_number_15();
la_code_combination_id             :=lt_table_integer();
la_analytical_criterion_code      :=lt_table_varchar2_30();
la_anacri_type_code               :=lt_table_varchar2_1();
la_amb_context_code               :=lt_table_varchar2_30();
la_ac1                            :=lt_table_varchar2_30();
la_ac2                            :=lt_table_varchar2_30();
la_ac3                            :=lt_table_varchar2_30();
la_ac4                            :=lt_table_varchar2_30();
la_ac5                            :=lt_table_varchar2_30();
la_balance_stat_eff_per_num       :=lt_table_integer();
la_contribution_dr                :=lt_table_number();
la_contribution_cr                :=lt_table_number();
la_contribution_draft_dr          :=lt_table_number();
la_contribution_draft_cr          :=lt_table_number();
la_net_contribution_dr            :=lt_table_number();
la_net_contribution_cr            :=lt_table_number();
la_net_contribution_draft_dr      :=lt_table_number();
la_net_contribution_draft_cr      :=lt_table_number();
la_change_balance_dr              :=lt_table_number();
la_change_balance_cr              :=lt_table_number();
la_change_draft_balance_dr        :=lt_table_number();
la_change_draft_balance_cr        :=lt_table_number();
la_year_end_carry_forward_code    :=lt_table_varchar2_1();
la_account_type                   :=lt_table_varchar2_1();


   OPEN lc_analytical_contributions;

   LOOP --contributions are collected in chunks
      FETCH lc_analytical_contributions
         BULK COLLECT
                 INTO la_application_id
                     ,la_ledger_id
                     ,la_contributed_period_year
                     ,la_contribution_period_name
                     ,la_contribution_period_year
                     ,la_contribution_eff_per_num
                     ,la_code_combination_id
                     ,la_analytical_criterion_code
                     ,la_anacri_type_code
                     ,la_amb_context_code
                     ,la_ac1
                     ,la_ac2
                     ,la_ac3
                     ,la_ac4
                     ,la_ac5
                     ,la_contribution_dr
                     ,la_contribution_cr
                     ,la_net_contribution_dr
                     ,la_net_contribution_cr
                     ,la_change_balance_dr
                     ,la_change_balance_cr
                     ,la_balance_stat_eff_per_num
                     ,la_year_end_carry_forward_code
                     ,la_account_type
      LIMIT C_BULK_LIMIT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => 'Processing ' || la_code_combination_id.COUNT
                                   || ' contributions'
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      IF la_code_combination_id.COUNT = 0
      THEN
         --increment the case counter, if the limit is reached exit.
         EXIT;
      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         FOR i IN 1..la_code_combination_id.LAST
         LOOP
             trace
            ( p_module => l_log_module
             ,p_msg    => 'CONTRIBUTION                    :' || i
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'contributed year                :'
                          || la_contributed_period_year(i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'ccid                            :'
                          || la_code_combination_id(i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'Analytical Criterion Code      :'
                          || la_analytical_criterion_code (i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'Analytical Criterion Type Code      :'
                          || la_anacri_type_code (i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'Amb Context Code      :'
                          || la_amb_context_code (i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'ac1      :'
                          || la_ac1 (i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'ac2      :'
                          || la_ac2 (i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'ac3      :'
                          || la_ac3 (i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'ac4      :'
                          || la_ac4 (i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'ac5      :'
                          || la_ac5 (i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'Contribution                    :'
                          || la_contribution_dr(i) || ','
                          || la_contribution_cr(i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'Net Contribution                :'
                          || la_net_contribution_dr(i) || ','
                          || la_net_contribution_cr(i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'Begin balance variation         :'
                          || la_change_balance_dr(i) || ','
                          || la_change_balance_cr(i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'Balance stat eff per num        :'
                          ||  la_balance_stat_eff_per_num(i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'la_year_end_carry_forward_code       :'
                          ||  la_year_end_carry_forward_code(i)
             ,p_level  => C_LEVEL_STATEMENT
            );
             trace
            ( p_module => l_log_module
             ,p_msg    => 'la_account_type           :'
                          ||  la_account_type(i)
             ,p_level  => C_LEVEL_STATEMENT
            );

         END LOOP;
      END IF;

      g_date := SYSDATE;

      --Update balances same year
      FORALL i IN 1..la_code_combination_id.LAST
      UPDATE /*+ NO_EXPAND INDEX (XBA XLA_AC_BALANCES_U1)*/ xla_ac_balances xba
         SET xba.beginning_balance_dr  =
                        DECODE( xba.period_name
                               ,la_contribution_period_name (i)
                               ,xba.beginning_balance_dr
                               ,NVL2( la_contribution_dr (i)
                                     ,NVL(xba.beginning_balance_dr, 0) + la_contribution_dr (i)
                                     ,xba.beginning_balance_dr
                                    )
                              )
                ,xba.beginning_balance_cr =
                        DECODE( xba.period_name
                               ,la_contribution_period_name (i)
                               ,xba.beginning_balance_cr
                               ,NVL2( la_contribution_cr (i)
                                     ,NVL(xba.beginning_balance_cr, 0) + la_contribution_cr (i)
                                     ,xba.beginning_balance_cr
                                    )
                              )
                ,xba.period_balance_dr    =
                        DECODE( xba.period_name
                               ,la_contribution_period_name (i)
                               ,NVL2( la_contribution_dr (i)
                                     ,NVL(xba.period_balance_dr, 0) + la_contribution_dr (i)
                                     ,xba.period_balance_dr
                                    )
                               ,xba.period_balance_dr
                              )
                ,xba.period_balance_cr    =
                        DECODE( xba.period_name
                               ,la_contribution_period_name (i)
                               ,NVL2( la_contribution_cr (i)
                                     ,NVL(xba.period_balance_cr, 0) + la_contribution_cr (i)
                                     ,xba.period_balance_cr
                                    )
                               ,xba.period_balance_cr
                              )
                ,first_period_flag              =
                        DECODE( xba.first_period_flag
                               ,'Y'
                               ,DECODE( xba.period_name
			               ,la_contribution_period_name (i)
			               ,'Y'
			               ,'N'
			              )
			       ,'N'
			      )
                ,creation_date              = g_date
                ,created_by                 = g_user_id
                ,last_update_date           = g_date
                ,last_updated_by            = g_user_id
                ,last_update_login          = g_login_id
                ,program_update_date        = g_date
                ,program_application_id     = g_prog_appl_id
                ,program_id                 = g_prog_id
                ,request_id                 = g_req_id
       WHERE xba.application_id             = la_application_id(i)
         AND xba.ledger_id                  = la_ledger_id(i)
         AND xba.code_combination_id        = la_code_combination_id(i)
         AND xba.analytical_criterion_code  = la_analytical_criterion_code(i)
         AND xba.analytical_criterion_type_code
                                            = la_anacri_type_code(i)
         AND xba.amb_context_code           = la_amb_context_code(i)
         AND nvl(xba.ac1,' ')    =  nvl(la_ac1(i),' ')
         AND nvl(xba.ac2,' ')    =  nvl(la_ac2(i),' ')
         AND nvl(xba.ac3,' ')    =  nvl(la_ac3(i),' ')
         AND nvl(xba.ac4,' ')    =  nvl(la_ac4(i),' ')
         AND nvl(xba.ac5,' ')    =  nvl(la_ac5(i),' ')
         AND xba.initial_balance_flag = 'N'
         AND xba.period_name IN
                        ( SELECT /*+ CARDINALITY(GPS,1) */ gps.period_name
                            FROM xla_bal_period_stats_gt gps
                           WHERE gps.ledger_id                  =  la_ledger_id(i)
                             AND gps.period_year                =  la_contribution_period_year(i)
                             AND gps.effective_period_num       >= la_contribution_eff_per_num(i)
                        )
         AND la_contributed_period_year(i)  =  la_contribution_period_year(i);

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => l_row_count || 'Same year balances updated '
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      g_date := SYSDATE;

      --UPDATE balances following years
      FORALL i IN 1..la_code_combination_id.LAST
         UPDATE /*+ NO_EXPAND INDEX (XBA XLA_AC_BALANCES_U1)*/ xla_ac_balances xba
            SET xba.beginning_balance_dr       =
                  DECODE( la_change_balance_dr(i)
                         ,0
                         ,xba.beginning_balance_dr
                         ,NVL(xba.beginning_balance_dr, 0)
                          + la_change_balance_dr(i)
                      )
               ,xba.beginning_balance_cr       =
                  DECODE( la_change_balance_cr(i)
                         ,0
                         ,xba.beginning_balance_cr
                         ,NVL(xba.beginning_balance_cr, 0)
                          + la_change_balance_cr(i)
                      )
               ,xba.first_period_flag              =
                   (SELECT gps2.first_period_in_year_flag
                      FROM xla_bal_period_stats_gt gps2
                     WHERE gps2.ledger_id              =  la_ledger_id(i)
                       AND gps2.period_name            =  xba.period_name
                   )
                  ,creation_date              = g_date
                  ,created_by                 = g_user_id
                  ,last_update_date           = g_date
                  ,last_updated_by            = g_user_id
                  ,last_update_login          = g_login_id
                  ,program_update_date        = g_date
                  ,program_application_id     = g_prog_appl_id
                  ,program_id                 = g_prog_id
                  ,request_id                 = g_req_id
             WHERE xba.ledger_id            = la_ledger_id(i)
               AND xba.application_id       = la_application_id(i)
               AND xba.code_combination_id  = la_code_combination_id(i)
               AND xba.analytical_criterion_code  = la_analytical_criterion_code(i)
               AND xba.analytical_criterion_type_code
                                                  = la_anacri_type_code(i)
               AND xba.amb_context_code           = la_amb_context_code(i)
             AND nvl(xba.ac1,' ')    =  nvl(la_ac1(i),' ')
         AND nvl(xba.ac2,' ')    =  nvl(la_ac2(i),' ')
         AND nvl(xba.ac3,' ')    =  nvl(la_ac3(i),' ')
         AND nvl(xba.ac4,' ')    =  nvl(la_ac4(i),' ')
         AND nvl(xba.ac5,' ')    =  nvl(la_ac5(i),' ')
               AND xba.initial_balance_flag = 'N'
               AND (    la_year_end_carry_forward_code(i)    = 'A'
                     OR (     la_year_end_carry_forward_code(i) =  'B'
                          AND la_account_type(i)           IN ('A', 'L', 'O')
                        )
                   )
               AND xba.period_name IN
                 ( SELECT /*+ CARDINALITY(GPS,1) */ gps.period_name
                     FROM xla_bal_period_stats_gt gps
                    WHERE gps.ledger_id                 = la_ledger_id(i)
                      AND gps.period_year               = la_contributed_period_year(i)
                  )
               AND la_contributed_period_year(i) > la_contribution_period_year(i);

         l_row_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            (p_module => l_log_module
	     ,p_msg   => l_row_count
                         || ' following years balances updated '
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;

         --Create new balances
      IF p_operation_code <> 'R'
         THEN
            g_date := SYSDATE;

            FORALL i IN 1..la_code_combination_id.LAST
               INSERT INTO xla_ac_balances xba
                  ( application_id
                   ,ledger_id
                   ,code_combination_id
                   ,analytical_criterion_code
                   ,analytical_criterion_type_code
                   ,amb_context_code
                   ,ac1
                   ,ac2
                   ,ac3
                   ,ac4
                   ,ac5
                   ,period_name
                   ,period_year
                   ,first_period_flag
                   ,beginning_balance_dr
                   ,beginning_balance_cr
                   ,period_balance_dr
                   ,period_balance_cr
                   ,initial_balance_flag
                   ,creation_date
                   ,created_by
                   ,last_update_date
                   ,last_updated_by
                   ,last_update_login
                   ,program_update_date
                   ,program_application_id
                   ,program_id
                   ,request_id
				   ,effective_period_num
                  )
                  (
                     SELECT /*+ leading(GPS) */  la_application_id(i)
                           ,la_ledger_id(i)
                           ,la_code_combination_id(i)
                           ,la_analytical_criterion_code(i)
                           ,la_anacri_type_code(i)
                           ,la_amb_context_code(i)
                           ,la_ac1(i)
                           ,la_ac2(i)
                           ,la_ac3(i)
                           ,la_ac4(i)
                           ,la_ac5(i)
                           ,gps.period_name
                           ,gps.period_year
                           ,DECODE( gps.first_period_in_year_flag
                                   ,'Y'
                                   ,'Y'
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,'Y'
                                           ,'N'
                                          )
                                  )
                           ,DECODE( gps.period_year
                                   ,la_contribution_period_year(i)
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,NULL
                                           ,la_contribution_dr(i)
                                          )
                                   ,la_net_contribution_dr(i)
                                  ) --beginning_balance_dr
                           ,DECODE( gps.period_year
                                   ,la_contribution_period_year(i)
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,NULL
                                           ,la_contribution_cr(i)
                                          )
                                   ,la_net_contribution_cr(i)
                                  ) --beginning_balance_cr
                           ,DECODE( gps.period_year
                                   ,la_contribution_period_year(i)
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,la_contribution_dr(i)
                                           ,NULL
                                          )
                                   ,NULL
                                  )  --period_balance_dr
                           ,DECODE( gps.period_year
                                   ,la_contribution_period_year(i)
                                   ,DECODE( gps.period_name
                                           ,la_contribution_period_name(i)
                                           ,la_contribution_cr(i)
                                           ,NULL
                                          )
                                   ,NULL
                                  )  --period_balance_cr
                           ,'N'
                           ,g_date
                           ,g_user_id
                           ,g_date
                           ,g_user_id
                           ,g_login_id
                           ,g_date
                           ,g_prog_appl_id
                           ,g_prog_id
                           ,g_req_id
						   ,gps.effective_period_num
                       FROM xla_bal_period_stats_gt            gps
                           ,xla_analytical_hdrs_b              xbh
                      WHERE gps.ledger_id                      = la_ledger_id (i)
                        AND gps.effective_period_num          >= la_contribution_eff_per_num(i)
                        AND gps.effective_period_num          <= la_balance_stat_eff_per_num(i)
                        -- bug 6117987
                        AND NOT EXISTS
                           (
                             -- bug 7113937 Removed outer join in where clause
                             SELECT /*+ no_unnest */ 1
                              FROM xla_ac_balances xba
                             WHERE xba.application_id              = la_application_id(i)
                               AND xba.ledger_id                   = la_ledger_id (i)
                               AND xba.code_combination_id         = la_code_combination_id(i)
                               AND xba.analytical_criterion_code   = la_analytical_criterion_code(i)
                               AND xba.analytical_criterion_type_code
                                                                   = la_anacri_type_code(i)
                               AND xba.amb_context_code            = la_amb_context_code(i)
                               AND NVL(xba.ac1,' ')               = NVL(la_ac1(i),' ')
                               AND NVL(xba.ac2,' ')               = NVL(la_ac2(i),' ')
                               AND NVL(xba.ac3,' ')               = NVL(la_ac3(i),' ')
                               AND NVL(xba.ac4,' ')               = NVL(la_ac4(i),' ')
                               AND NVL(xba.ac5,' ')               = NVL(la_ac5(i),' ')
                               AND xba.period_name                 =  gps.period_name
                           )
                        AND xbh.analytical_criterion_code      = la_analytical_criterion_code(i)
                        AND xbh.analytical_criterion_type_code = la_anacri_type_code(i)
                        AND xbh.amb_context_code               =  la_amb_context_code(i)
			AND xbh.balancing_flag <> 'N' --Bug 8895800 : Balances should be calculated based on the setup
                        AND (     gps.period_year            =  la_contribution_period_year(i)
		              OR  xbh.year_end_carry_forward_code       =  'A'
                              OR  (     xbh.year_end_carry_forward_code =  'B'
                                    AND la_account_type(i)              IN ('A', 'L', 'O')
                                  )
                            )
                   );

          l_row_count := SQL%ROWCOUNT;

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace
            ( p_module => l_log_module
	     ,p_msg   => l_row_count  || 'New balances inserted '
             ,p_level => C_LEVEL_STATEMENT
            );
          END IF;
       END IF; --p_operation_code

   END LOOP; --proceed to the next chunk of contributions

   CLOSE lc_analytical_contributions;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.calculate_analytical_balances');
END calculate_analytical_balances;




/*
bug#8347976 PLSQL numeric character to number conversion error while undo acctng.
p_analytical_criterion_code is VARCHAR2 wherever its referenced ie
xla_bal_ac_ctrbs_gt and  xla_ac_balances.
*/

FUNCTION move_identified_bals_forward
  ( p_application_id             IN INTEGER
   ,p_ledger_id                  IN INTEGER
   ,p_code_combination_id        IN INTEGER
   ,p_dest_effective_period_num  IN INTEGER
   ,p_balance_source_code        IN VARCHAR2
   ,p_party_type_code            IN VARCHAR2
   ,p_party_id                   IN INTEGER
   ,p_analytical_criterion_code  IN VARCHAR2 --INTEGER bug8347976
   ,p_anacri_type_code           IN VARCHAR2
   ,p_amb_context_code           IN VARCHAR2
   ,p_ac1                        IN VARCHAR2
   ,p_ac2                        IN VARCHAR2
   ,p_ac3                        IN VARCHAR2
   ,p_ac4                        IN VARCHAR2
   ,p_ac5                        IN VARCHAR2
  )
RETURN BOOLEAN
IS
/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
+======================================================================*/

l_user_id                 INTEGER;
l_login_id                INTEGER;
l_date                    DATE;
l_prog_appl_id            INTEGER;
l_prog_id                 INTEGER;
l_req_id                  INTEGER;

l_row_count                 NUMBER;

l_return_value            INTEGER;

l_log_module                 VARCHAR2 (2000);

BEGIN

   l_user_id                 := xla_environment_pkg.g_usr_id;
   l_login_id                := xla_environment_pkg.g_login_id;
   l_date                    := SYSDATE;
   l_prog_appl_id            := xla_environment_pkg.g_prog_appl_id;
   l_prog_id                 := xla_environment_pkg.g_prog_id;
   l_req_id                  := xla_environment_pkg.g_req_id;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.move_identified_bals_forward';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
        (p_module => l_log_module
         , p_msg   => 'p_application_id               :'
                     || p_application_id
         ,p_level => C_LEVEL_STATEMENT
        );
      trace
        ( p_module => l_log_module
         ,p_msg   => 'p_ledger_id                    :'
                     || p_ledger_id
         ,p_level => C_LEVEL_STATEMENT
        );
      trace
        ( p_module => l_log_module
         ,p_msg   => 'p_code_combination_id          :'
                     || p_code_combination_id
         ,p_level => C_LEVEL_STATEMENT
        );
      trace
        (p_module => l_log_module
         ,p_msg   => 'p_dest_effective_period_num    :'
                     || p_dest_effective_period_num
         ,p_level => C_LEVEL_STATEMENT
        );
      trace
        (p_module => l_log_module
         ,p_msg   => 'p_balance_source_code          :'
                     || p_balance_source_code
         ,p_level => C_LEVEL_STATEMENT
        );
      trace
        (p_module => l_log_module
        ,p_msg   => 'p_party_type_code              :'
                     || p_party_type_code
         ,p_level => C_LEVEL_STATEMENT
        );
      trace
        (p_module => l_log_module
         ,p_msg   => 'p_party_id                     :'
                     || p_party_id
         ,p_level => C_LEVEL_STATEMENT
        );
   END IF;

   IF p_application_id             IS NULL
   OR p_ledger_id                  IS NULL
   OR p_code_combination_id        IS NULL
   OR p_dest_effective_period_num  IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
             ,p_msg   => 'EXCEPTION: ' ||
                        'parameters cannot be NULL'
            ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: ' ||
                        'parameters cannot be NULL');
   END IF;

   IF NVL(p_balance_source_code, 'C') = 'C'
   THEN
      IF p_party_type_code IS NULL
      OR p_party_id        IS NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
             ,p_msg   => 'EXCEPTION: ' ||
'If p_balance_source_code is not ''A'' party parameters cannot be NULL'
            ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: ' ||
'If p_balance_source_code is not ''A'' party parameters cannot be NULL');
      END IF;
   END IF;

   IF NVL(p_balance_source_code, 'A') = 'A'
   THEN
      IF p_analytical_criterion_code IS NULL
      OR p_anacri_type_code IS NULL
      OR p_amb_context_code IS NULL
      OR (p_ac1 IS NULL AND p_ac2 IS NULL AND
          p_ac3 IS NULL AND p_ac4 IS NULL AND
          p_ac5 IS NULL)
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
             ,p_msg   => 'EXCEPTION: ' ||
'If p_balance_source_code is not ''C'' analytical detail parameter cannot be NULL'
            ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: ' ||
'If p_balance_source_code is not ''C'' analytical detail parameter cannot be NULL');
      END IF;
   END IF;


   l_return_value := 0;

   IF NVL(p_balance_source_code, 'C') = 'C'
   THEN
      INSERT INTO xla_control_balances xba
                  ( application_id
                   ,ledger_id
                   ,code_combination_id
                   ,party_type_code
                   ,party_id
                   ,party_site_id
                   ,period_name
                   ,period_year
                   ,beginning_balance_dr
                   ,beginning_balance_cr
                   ,period_balance_dr
                   ,period_balance_cr
                   ,draft_beginning_balance_dr
                   ,draft_beginning_balance_cr
                   ,period_draft_balance_dr
                   ,period_draft_balance_cr
                   ,initial_balance_flag
                   ,first_period_flag
                   ,creation_date
                   ,created_by
                   ,last_update_date
                   ,last_updated_by
                   ,last_update_login
                   ,program_update_date
                   ,program_application_id
                   ,program_id
                   ,request_id
				   ,effective_period_num
                  )
                  (
                     SELECT xba.application_id
                           ,xba.ledger_id
                           ,xba.code_combination_id
                           ,xba.party_type_code
                           ,xba.party_id
                           ,xba.party_site_id
                           ,gpsnew.period_name
                           ,gpsnew.period_year
--disregarding indentation for readability
         ,DECODE( gpsnew.period_year
                 ,gpsbs.period_year
                 ,NVL2( xba.period_balance_dr
                       ,NVL2( xba.beginning_balance_dr
                             ,xba.beginning_balance_dr + xba.period_balance_dr
                             ,xba.period_balance_dr
                            )
                        ,xba.beginning_balance_dr
                       )
                 ,DECODE( SIGN ( NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0)
                                -( NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0) )
                               )
                         ,1
                         ,NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0)
                          - ( NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0) )
                        )
                 )       --beginning_balance_dr
         ,DECODE( gpsnew.period_year
                 ,gpsbs.period_year
                 ,NVL2( xba.period_balance_cr
                       ,NVL2( xba.beginning_balance_cr
                             ,xba.beginning_balance_cr + xba.period_balance_cr
                             ,xba.period_balance_cr
                            )
                        ,xba.beginning_balance_cr
                       )
                 ,DECODE( SIGN ( NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0)
                                -( NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0) )
                               )
                         ,1
                         ,NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0)
                          - ( NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0) )
                        )
                 )       --beginning_balance_cr
         ,NULL           --period_balance_dr
         ,NULL           --period_balance_cr
         ,DECODE( gpsnew.period_year
                 ,gpsbs.period_year
                 ,NVL2( xba.period_draft_balance_dr
                       ,NVL2( xba.draft_beginning_balance_dr
                             ,xba.draft_beginning_balance_dr + xba.period_draft_balance_dr
                             ,xba.period_draft_balance_dr
                            )
                        ,xba.draft_beginning_balance_dr
                       )
                 ,DECODE( SIGN ( NVL(xba.draft_beginning_balance_dr, 0) + NVL(xba.period_draft_balance_dr, 0)
                                -( NVL(xba.draft_beginning_balance_cr, 0) + NVL(xba.period_draft_balance_cr, 0) )
                               )
                         ,1
                         ,NVL(xba.draft_beginning_balance_dr, 0) + NVL(xba.period_draft_balance_dr, 0)
                          - ( NVL(xba.draft_beginning_balance_cr, 0) + NVL(xba.period_draft_balance_cr, 0))
                        )
                 )       --draft_beginning_balance_dr
         ,DECODE( gpsnew.period_year
                 ,gpsbs.period_year
                 ,NVL2( xba.period_draft_balance_cr
                       ,NVL2( xba.draft_beginning_balance_cr
                             ,xba.draft_beginning_balance_cr + xba.period_draft_balance_cr
                             ,xba.period_draft_balance_cr
                            )
                        ,xba.draft_beginning_balance_cr
                       )
                 ,DECODE( SIGN ( NVL(xba.draft_beginning_balance_cr, 0) + NVL(xba.period_draft_balance_cr, 0)
                                -( NVL(xba.draft_beginning_balance_dr, 0) + NVL(xba.period_draft_balance_dr, 0) )
                               )
                         ,1
                         ,NVL (xba.draft_beginning_balance_cr, 0) + NVL(xba.period_draft_balance_cr, 0)
                          - ( NVL(xba.draft_beginning_balance_dr, 0) + NVL(xba.period_draft_balance_dr, 0) )
                        )
                 )       --draft_beginning_balance_cr
                 ,NULL   --period_draft_balance_dr
                 ,NULL   --period_draft_balance_cr

                           ,'N'
                           ,(SELECT DECODE( MAX(gps2.effective_period_num)
                                           ,NULL
                                           ,'Y'
                                           ,'N'
                                          )
                              FROM gl_period_statuses gps2
                             WHERE gps2.ledger_id              =  ledger_id
                               AND gps2.application_id         =  101
                               AND gps2.closing_status         IN ('O','C','P')
                               AND gps2.adjustment_period_flag =  'N'
                               AND gps2.period_year            =  gpsnew.period_year
                               AND gps2.effective_period_num   <  gpsnew.effective_period_num
                             )
                           ,l_date
                           ,l_user_id
                           ,l_date
                           ,l_user_id
                           ,l_login_id
                           ,l_date
                           ,l_prog_appl_id
                           ,l_prog_id
                           ,NVL(l_req_id, -1)
						   ,gpsbs.effective_period_num
                       FROM xla_balance_statuses       xbs
                           ,gl_period_statuses         gpsbs
                           ,xla_control_balances       xba
                           ,gl_period_statuses         gpsnew
                      WHERE xbs.application_id             =  p_application_id
                        AND xbs.ledger_id                  =  p_ledger_id
                        AND xbs.balance_source_code        =  'C'
                        AND xbs.effective_period_num       <  p_dest_effective_period_num
                        AND xbs.code_combination_id        =  p_code_combination_id
                        AND gpsbs.ledger_id                =  p_ledger_id
                        AND gpsbs.application_id           =  101
                        AND gpsbs.effective_period_num     =  xbs.effective_period_num
                        AND xba.ledger_id                  =  p_ledger_id
                        AND xba.application_id             =  p_application_id
                        AND xba.code_combination_id        =  p_code_combination_id
                        AND xba.party_type_code            =  p_party_type_code
                        AND xba.party_id                   =  p_party_id
                        AND xba.period_name                =  gpsbs.period_name
                        AND gpsnew.ledger_id               =  p_ledger_id
                        AND gpsnew.application_id          =  101
                        AND gpsnew.closing_status          IN ('O', 'C', 'P')
                        AND gpsnew.adjustment_period_flag  =  'N'
                        AND gpsnew.effective_period_num    <= p_dest_effective_period_num
                        AND gpsnew.effective_period_num    >
                                (
                                 SELECT MAX(gpsint.effective_period_num)
                                   FROM xla_control_balances       xbanew
                                       ,gl_period_statuses         gpsint
                                  WHERE xbanew.ledger_id               =  p_ledger_id
                                    AND xbanew.application_id          =  p_application_id
                                    AND xbanew.code_combination_id     =  p_code_combination_id
                                    AND xbanew.party_type_code         =  p_party_type_code
                                    AND xbanew.party_id                =  p_party_id
                                    AND xbanew.party_site_id           =  xba.party_site_id
                                    AND gpsint.ledger_id               =  p_ledger_id
                                    AND gpsint.application_id          =  101
                                    AND gpsint.period_name             =  xbanew.period_name
                                )
                   );

          l_row_count := SQL%ROWCOUNT;
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace
            ( p_module => l_log_module
             ,p_msg   => l_row_count ||
                         ' xla_control_balances created'
             ,p_level => C_LEVEL_STATEMENT
            );
          END IF;
   END IF;

   IF NVL(p_balance_source_code, 'A') = 'A'
   THEN
      INSERT INTO xla_ac_balances xba
                  ( application_id
                   ,ledger_id
                   ,code_combination_id
                   ,analytical_criterion_code
                   ,analytical_criterion_type_code
                   ,amb_context_code
                   ,ac1
                   ,ac2
                   ,ac3
                   ,ac4
                   ,ac5
                   ,period_name
                   ,period_year
                   ,beginning_balance_dr
                   ,beginning_balance_cr
                   ,period_balance_dr
                   ,period_balance_cr
                   ,initial_balance_flag
                   ,first_period_flag
                   ,creation_date
                   ,created_by
                   ,last_update_date
                   ,last_updated_by
                   ,last_update_login
                   ,program_update_date
                   ,program_application_id
                   ,program_id
                   ,request_id
				   ,effective_period_num
                  )
                  (
                     SELECT xba.application_id
                           ,xba.ledger_id
                           ,xba.code_combination_id
                           ,xba.analytical_criterion_code
                           ,xba.analytical_criterion_type_code
                           ,xba.amb_context_code
                           ,xba.ac1
                           ,xba.ac2
                           ,xba.ac3
                           ,xba.ac4
                           ,xba.ac5
                           ,gpsnew.period_name
                           ,gpsnew.period_year
--disregarding indentation for readability
         ,DECODE( gpsnew.period_year
                 ,gpsbs.period_year
                 ,NVL2( xba.period_balance_dr
                       ,NVL2( xba.beginning_balance_dr
                             ,xba.beginning_balance_dr + xba.period_balance_dr
                             ,xba.period_balance_dr
                            )
                        ,xba.beginning_balance_dr
                       )
                 ,DECODE( SIGN ( NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0)
                                -( NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0) )
                               )
                         ,1
                         ,NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0)
                          - ( NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0) )
                        )
                 )       --beginning_balance_dr
         ,DECODE( gpsnew.period_year
                 ,gpsbs.period_year
                 ,NVL2( xba.period_balance_cr
                       ,NVL2( xba.beginning_balance_cr
                             ,xba.beginning_balance_cr + xba.period_balance_cr
                             ,xba.period_balance_cr
                            )
                        ,xba.beginning_balance_cr
                       )
                 ,DECODE( SIGN ( NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0)
                                -( NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0) )
                               )
                         ,1
                         ,NVL(xba.beginning_balance_cr, 0) + NVL(xba.period_balance_cr, 0)
                          - ( NVL(xba.beginning_balance_dr, 0) + NVL(xba.period_balance_dr, 0) )
                        )
                 )       --beginning_balance_cr
         ,NULL           --period_balance_dr
         ,NULL           --period_balance_cr
                ,'N'
                 ,(SELECT DECODE( MAX(gps2.effective_period_num)
                                 ,NULL
                                 ,'Y'
                                 ,'N'
                                )
                     FROM gl_period_statuses gps2
                    WHERE gps2.ledger_id              =  ledger_id
                      AND gps2.application_id         =  101
                      AND gps2.closing_status         IN ('O','C','P')
                      AND gps2.adjustment_period_flag =  'N'
                      AND gps2.period_year            =  gpsnew.period_year
                      AND gps2.effective_period_num   <  gpsnew.effective_period_num
                  )
                 ,l_date
                 ,l_user_id
                 ,l_date
                 ,l_user_id
                 ,l_login_id
                 ,l_date
                 ,l_prog_appl_id
                 ,l_prog_id
                 ,NVL(l_req_id, -1)
				 ,gpsbs.effective_period_num
            FROM xla_balance_statuses         xbs
                ,gl_period_statuses           gpsbs
                ,xla_ac_balances              xba
                ,gl_period_statuses           gpsnew
                ,xla_analytical_hdrs_b        xbh
           WHERE xbs.application_id                 =  p_application_id
             AND xbs.ledger_id                      =  p_ledger_id
             AND xbs.balance_source_code            =  'A'
             AND xbs.effective_period_num           <  p_dest_effective_period_num
             AND xbs.code_combination_id            =  p_code_combination_id
             AND gpsbs.ledger_id                    =  p_ledger_id
             AND gpsbs.application_id               =  101
             AND gpsbs.effective_period_num         =  xbs.effective_period_num
             AND xba.ledger_id                      =  p_ledger_id
             AND xba.application_id                 =  p_application_id
             AND xba.code_combination_id            =  p_code_combination_id
             AND xba.analytical_criterion_code      = p_analytical_criterion_code
             AND xba.analytical_criterion_type_code = p_anacri_type_code
             AND xba.amb_context_code               = p_amb_context_code
             AND nvl(xba.ac1(+),' ')                        = nvl(p_ac1,' ')
             AND nvl(xba.ac2(+),' ')                        = nvl(p_ac2,' ')
             AND nvl(xba.ac3(+),' ')                        = nvl(p_ac3,' ')
             AND nvl(xba.ac4(+),' ')                        = nvl(p_ac4,' ')
             AND nvl(xba.ac5(+),' ')                        = nvl(p_ac5,' ')
             AND xba.period_name                    =  gpsbs.period_name
             AND xbh.analytical_criterion_code      =  xba.analytical_criterion_code
             AND xbh.analytical_criterion_type_code =  xba.analytical_criterion_type_code
             AND xbh.amb_context_code               =  xba.amb_context_code
             AND (    xba.period_year             =  gpsnew.period_year
                  OR  xbh.year_end_carry_forward_code        =  'A'
                  OR  (     xbh.year_end_carry_forward_code  =  'B'
                        AND xbs.account_type            IN ('A', 'L', 'O')
                      )
                 )
             AND gpsnew.ledger_id               =  p_ledger_id
             AND gpsnew.application_id          =  101
             AND gpsnew.closing_status          IN ('O', 'C', 'P')
             AND gpsnew.adjustment_period_flag  =  'N'
             AND gpsnew.effective_period_num    <= p_dest_effective_period_num
             AND gpsnew.effective_period_num    >
                       (
                        SELECT MAX(gpsint.effective_period_num)
                         FROM xla_ac_balances    xbanew
                              ,gl_period_statuses         gpsint
                         WHERE xbanew.ledger_id                  =  p_ledger_id
                           AND xbanew.application_id             =  p_application_id
                           AND xbanew.code_combination_id        =  p_code_combination_id
                           AND gpsint.ledger_id                  =  p_ledger_id
                           AND gpsint.application_id             =  101
                           AND gpsint.period_name                =  xbanew.period_name
                       )
              );

          l_row_count := SQL%ROWCOUNT;
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace
            ( p_module => l_log_module
             ,p_msg   => l_row_count ||
                         ' xla_ac_balances created'
             ,p_level => C_LEVEL_STATEMENT
            );
          END IF;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.move_identified_bals_forward');
END move_identified_bals_forward;

PROCEDURE build_line_selection_dyn_stmts
  ( p_application_id           IN         INTEGER
   ,p_ledger_id                IN         INTEGER
   ,p_event_id                 IN         INTEGER
   ,p_accounting_batch_id      IN         INTEGER
   ,p_ae_header_id             IN         INTEGER
   ,p_ae_line_num              IN         INTEGER
   ,p_code_combination_id      IN         INTEGER
   ,p_period_name              IN         VARCHAR2
   ,p_balance_source_code      IN         VARCHAR2
   ,p_balance_flag_pre_update  IN         VARCHAR2
   ,p_balance_flag_post_update IN         VARCHAR2
   ,p_commit_flag              IN         VARCHAR2
   ,p_entry_locking_dyn_stmt   OUT NOCOPY VARCHAR2
   ,p_line_selection_dyn_stmt  OUT NOCOPY VARCHAR2
   ,p_locking_arg_array        OUT NOCOPY t_array_varchar  -- bug 7551435
   ,p_lck_bind_var_count       OUT NOCOPY        INTEGER   -- bug 7551435
   ,p_selection_arg_array      OUT NOCOPY t_array_varchar  -- bug 7551435
   ,p_ins_bind_var_num         OUT NOCOPY        INTEGER   -- bug 7551435
   )
IS
  l_log_module                 VARCHAR2 (2000);     -- bug 7551435
  i                            number;              -- bug 7551435

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_line_selection_dyn_stmts';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

      p_lck_bind_var_count:=1;
      p_ins_bind_var_num:=1;

      IF p_accounting_batch_id IS NOT NULL
      THEN
         p_entry_locking_dyn_stmt :=
         ' SELECT  /*+ PARALLEL (AEL) leading(aeh) use_nl(ael)   */ 1
           FROM xla_ae_headers       aeh
               ,xla_ae_lines         ael
          WHERE ael.ae_header_id                 =  aeh.ae_header_id
            AND ael.application_id               =  aeh.application_id
            AND aeh.accounting_entry_status_code = ''F''
         ';
      ELSE
             p_entry_locking_dyn_stmt :=
         ' SELECT 1
           FROM xla_ae_headers       aeh
               ,xla_ae_lines         ael
          WHERE ael.ae_header_id                 =  aeh.ae_header_id
            AND ael.application_id               =  aeh.application_id
            AND aeh.accounting_entry_status_code = ''F''
         ';
      END IF;

      -- bug 7551435  begin add bind variables

      IF p_balance_source_code IS NULL
      THEN
         p_entry_locking_dyn_stmt := p_entry_locking_dyn_stmt ||
         ' AND (ael.control_balance_flag  =''P''
              OR ael.analytical_balance_flag =''P''  )';

      ELSIF p_balance_source_code = 'C'
      THEN
         p_entry_locking_dyn_stmt := p_entry_locking_dyn_stmt || '
          AND ael.control_balance_flag    =  ''P''';

      ELSIF p_balance_source_code = 'A'
      THEN
         p_entry_locking_dyn_stmt := p_entry_locking_dyn_stmt || '
          AND ael.analytical_balance_flag   =  ''P''';

      END IF;

      IF p_ledger_id IS NOT NULL
      THEN
         p_entry_locking_dyn_stmt := p_entry_locking_dyn_stmt ||
         ' AND ael.ledger_id = :'|| p_lck_bind_var_count;

         p_locking_arg_array(p_lck_bind_var_count):=to_char(p_ledger_id);

         p_lck_bind_var_count:= p_lck_bind_var_count + 1;

         IF p_period_name IS NOT NULL
         THEN
            p_entry_locking_dyn_stmt := p_entry_locking_dyn_stmt ||
            '            AND aeh.period_name                 =  :' || p_lck_bind_var_count ;
            p_locking_arg_array(p_lck_bind_var_count):=p_period_name;
            p_lck_bind_var_count:= p_lck_bind_var_count + 1;


         END IF;

         IF p_code_combination_id IS NOT NULL
         THEN
            p_entry_locking_dyn_stmt := p_entry_locking_dyn_stmt ||
            '            AND ael.code_combination_id          =  :'|| p_lck_bind_var_count;

         p_locking_arg_array(p_lck_bind_var_count):=to_char(p_code_combination_id);
         p_lck_bind_var_count:=p_lck_bind_var_count+1;

         END IF;


      END IF;

      IF p_accounting_batch_id IS NOT NULL
      THEN
         p_entry_locking_dyn_stmt := p_entry_locking_dyn_stmt ||
         '            AND aeh.accounting_batch_id          =  :'||p_lck_bind_var_count;
         p_locking_arg_array(p_lck_bind_var_count):=to_char(p_accounting_batch_id);
         p_lck_bind_var_count:=p_lck_bind_var_count+1;

      END IF;

      IF p_application_id IS NOT NULL
      THEN
         p_entry_locking_dyn_stmt := p_entry_locking_dyn_stmt ||
            '
             AND ael.application_id                 =
             :'|| p_lck_bind_var_count;
         p_locking_arg_array(p_lck_bind_var_count):=to_char(p_application_id);
         p_lck_bind_var_count:=p_lck_bind_var_count+1;

      END IF;

      IF p_ae_header_id IS NOT NULL
      THEN
         p_entry_locking_dyn_stmt := p_entry_locking_dyn_stmt ||
         '            AND aeh.ae_header_id                 =  :'||p_lck_bind_var_count;
         p_locking_arg_array(p_lck_bind_var_count):=to_char(p_ae_header_id);
         p_lck_bind_var_count:=p_lck_bind_var_count+1;

      END IF;
      IF p_event_id IS NOT NULL
      THEN
         p_entry_locking_dyn_stmt := p_entry_locking_dyn_stmt ||
         '            AND aeh.event_id                     =   :'||p_lck_bind_var_count;
         p_locking_arg_array(p_lck_bind_var_count):=to_char(p_event_id);
         p_lck_bind_var_count:=p_lck_bind_var_count+1;

      END IF;

      IF p_ae_line_num IS NOT NULL
      THEN
         p_entry_locking_dyn_stmt := p_entry_locking_dyn_stmt ||
         '            AND ael.ae_line_num                  =   :' || p_lck_bind_var_count;
         p_locking_arg_array(p_lck_bind_var_count):=to_char(p_ae_line_num);
         p_lck_bind_var_count:=p_lck_bind_var_count+1;

      END IF;

      p_entry_locking_dyn_stmt := p_entry_locking_dyn_stmt ||
         ' FOR UPDATE OF ael.ae_header_id,ael.ae_line_num, ael.control_balance_flag,ael.analytical_balance_flag NOWAIT ';

       p_lck_bind_var_count:=p_lck_bind_var_count-1;

      -- bug 7551435  end add bind variables

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               ( p_module => l_log_module
                ,p_msg    => 'START of Entry locking statement'
                ,p_level  => C_LEVEL_STATEMENT
               );
         trace
               ( p_module => l_log_module
                ,p_msg    => SUBSTR(p_entry_locking_dyn_stmt, 1, 1000)
                ,p_level  => C_LEVEL_STATEMENT
               );
         trace
               ( p_module => l_log_module
                ,p_msg    => SUBSTR(p_entry_locking_dyn_stmt, 1001, 1000)
                ,p_level  => C_LEVEL_STATEMENT
               );
         trace
               ( p_module => l_log_module
                ,p_msg    => SUBSTR(p_entry_locking_dyn_stmt, 2001, 1000)
                ,p_level  => C_LEVEL_STATEMENT
               );
         trace
               ( p_module => l_log_module
                ,p_msg    => 'END of Entry locking statement'
                ,p_level  => C_LEVEL_STATEMENT
               );
         trace
               ( p_module => l_log_module
                ,p_msg    => 'p_lck_bind_var_count='||p_lck_bind_var_count
                ,p_level  => C_LEVEL_STATEMENT
               );

          for i  in 1 .. p_lck_bind_var_count
          loop
             trace
                ( p_module => l_log_module
                 ,p_msg    => 'p_locking_arg_array['||i||']='||p_locking_arg_array(i)
                 ,p_level  => C_LEVEL_STATEMENT
                );
           end loop;




      END IF;

   p_line_selection_dyn_stmt :=
   '
   INSERT ALL
     WHEN control_balance_flag = ''' || p_balance_flag_pre_update || '''
      AND NVL( ''' || p_balance_source_code || ''', ''C'') = ''C''
     THEN
     INTO xla_bal_ctrl_lines_gt
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,party_type_code
          ,party_id
          ,party_site_id
          ,accounted_dr
          ,accounted_cr
         )
   VALUES
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,party_type_code
          ,party_id
          ,NVL(party_site_id, -999)
          ,accounted_dr
          ,accounted_cr
         )

    WHEN analytical_balance_flag = ''' || p_balance_flag_pre_update || '''
     AND NVL( ''' || p_balance_source_code || ''', ''A'') = ''A''
    THEN
    INTO xla_bal_anacri_lines_gt
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,accounted_dr
          ,accounted_cr
         )
         VALUES
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,accounted_dr
          ,accounted_cr
         )
   SELECT /*+ leading(aeh) use_nl(ael) */ ael.ROWID    line_rowid -- Added for performance issue
         ,aeh.ae_header_id

         ,ael.ae_line_num
         ,aeh.application_id
         ,aeh.ledger_id
         ,aeh.period_name
         ,gps.period_year
         ,gps.effective_period_num
         ,aeh.accounting_entry_status_code
         ,ael.control_balance_flag
         ,ael.analytical_balance_flag
         ,ael.code_combination_id
         ,ael.party_type_code
         ,ael.party_id
         ,NVL(ael.party_site_id,-999)         party_site_id
         ,ael.accounted_dr
         ,ael.accounted_cr
     FROM xla_ae_headers       aeh
         ,xla_ae_lines         ael
         ,gl_period_statuses   gps
    WHERE ael.ae_header_id                 =  aeh.ae_header_id
      AND ael.application_id               =  aeh.application_id
      AND gps.ledger_id                    =  aeh.ledger_id
      AND gps.application_id               =  101
      AND gps.period_name                  =  aeh.period_name
      AND gps.closing_status in  (''O'',''C'',''P'')
      AND gps.adjustment_period_flag = ''N''
      AND aeh.accounting_entry_status_code =  ''F''
      AND aeh.balance_type_code = ''A'' --bug 9385087
--      AND ael.control_balance_flag = ''' || p_balance_flag_pre_update || '''
--      AND NVL( ''' || p_balance_source_code || ''', ''C'') = ''C''
      ';


   -- bug 7441310 begin add bind variables

   IF p_balance_source_code IS NULL
   THEN
      p_line_selection_dyn_stmt := p_line_selection_dyn_stmt ||
      ' AND (   ael.control_balance_flag    = ''P''
         OR ael.analytical_balance_flag =  ''P'') ';



   ELSIF p_balance_source_code = 'C'
   THEN
      p_line_selection_dyn_stmt := p_line_selection_dyn_stmt || '
       AND ael.control_balance_flag    =  :''P''';

   ELSIF p_balance_source_code = 'A'
   THEN
      p_line_selection_dyn_stmt := p_line_selection_dyn_stmt || '
       AND ael.analytical_balance_flag   =  :''P''';

   END IF;

    IF p_ledger_id IS NOT NULL
   THEN
      p_line_selection_dyn_stmt := p_line_selection_dyn_stmt ||
      '
       AND ael.ledger_id = :'   || p_ins_bind_var_num;
       p_selection_arg_array(p_ins_bind_var_num):=to_char(p_ledger_id);
       p_ins_bind_var_num:=p_ins_bind_var_num+1;


      IF p_period_name IS NOT NULL
      THEN
         p_line_selection_dyn_stmt := p_line_selection_dyn_stmt ||
         '            AND aeh.period_name                 =  :'   || p_ins_bind_var_num ;
       p_selection_arg_array(p_ins_bind_var_num):=p_period_name;
       p_ins_bind_var_num:=p_ins_bind_var_num+1;


      END IF;
      IF p_code_combination_id IS NOT NULL
      THEN
         p_line_selection_dyn_stmt := p_line_selection_dyn_stmt ||
         '            AND ael.code_combination_id          =  :'   || p_ins_bind_var_num;
       p_selection_arg_array(p_ins_bind_var_num):=to_char(p_code_combination_id);
       p_ins_bind_var_num:=p_ins_bind_var_num+1;


      END IF;
   END IF;

   IF p_application_id IS NOT NULL
   THEN
      p_line_selection_dyn_stmt := p_line_selection_dyn_stmt ||
         '
          AND ael.application_id                 = :'   || p_ins_bind_var_num;
       p_selection_arg_array(p_ins_bind_var_num):=to_char(p_application_id);
       p_ins_bind_var_num:=p_ins_bind_var_num+1;


   END IF;

  IF p_ae_header_id IS NOT NULL
   THEN
         p_line_selection_dyn_stmt := p_line_selection_dyn_stmt ||
         '            AND aeh.ae_header_id                 =  :'   || p_ins_bind_var_num;
         p_selection_arg_array(p_ins_bind_var_num):=to_char(p_ae_header_id);
         p_ins_bind_var_num:=p_ins_bind_var_num+1;


   END IF;

   IF p_event_id IS NOT NULL
   THEN
         p_line_selection_dyn_stmt := p_line_selection_dyn_stmt ||
         '            AND aeh.event_id                     =  :'   || p_ins_bind_var_num;
         p_selection_arg_array(p_ins_bind_var_num):=to_char(p_event_id);
         p_ins_bind_var_num:=p_ins_bind_var_num+1;


   END IF;

   IF p_accounting_batch_id IS NOT NULL
   THEN
         p_line_selection_dyn_stmt := p_line_selection_dyn_stmt ||
         '            AND aeh.accounting_batch_id          =  :'   || p_ins_bind_var_num;
         p_selection_arg_array(p_ins_bind_var_num):=to_char(p_accounting_batch_id);
         p_ins_bind_var_num:=p_ins_bind_var_num+1;


   END IF;

   IF p_ae_line_num IS NOT NULL
   THEN
         p_line_selection_dyn_stmt := p_line_selection_dyn_stmt ||
         '            AND ael.ae_line_num                  =  :'   || p_ins_bind_var_num;
         p_selection_arg_array(p_ins_bind_var_num):=to_char(p_ae_line_num);
         p_ins_bind_var_num:=p_ins_bind_var_num+1;


   END IF;
   IF p_commit_flag = 'Y'
   THEN
         p_line_selection_dyn_stmt := p_line_selection_dyn_stmt ||
         '  AND ROWNUM                                     <= '   || C_BATCH_COMMIT_SIZE;
   ELSIF p_commit_flag = 'N'
   THEN
         NULL;
  ELSE
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
             ,p_msg   => 'EXCEPTION: ' ||
'Invalid value for p_commit_flag: ' || p_commit_flag
            ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: ' ||
'Invalid value for p_commit_flag: ' || p_commit_flag);
   END IF;

  p_ins_bind_var_num:=p_ins_bind_var_num-1;

 -- bug 7441310 end add bind variables

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               ( p_module => l_log_module
                ,p_msg    => 'START of Line Selection statement'
                ,p_level  => C_LEVEL_STATEMENT
               );
         trace
               ( p_module => l_log_module
                ,p_msg    => SUBSTR(p_line_selection_dyn_stmt, 1, 1000)
                ,p_level  => C_LEVEL_STATEMENT
               );
         trace
               ( p_module => l_log_module
                ,p_msg    => SUBSTR(p_line_selection_dyn_stmt, 1001, 1000)
                ,p_level  => C_LEVEL_STATEMENT
               );
         trace
               ( p_module => l_log_module
                ,p_msg    => SUBSTR(p_line_selection_dyn_stmt, 2001, 1000)
                ,p_level  => C_LEVEL_STATEMENT
               );
         trace
               ( p_module => l_log_module
                ,p_msg    => 'END of Line Selection statement'
                ,p_level  => C_LEVEL_STATEMENT
               );
         trace
               ( p_module => l_log_module
                ,p_msg    => 'p_ins_bind_var_num='||p_ins_bind_var_num
                ,p_level  => C_LEVEL_STATEMENT
               );


          for i  in 1 .. p_lck_bind_var_count
          loop
             trace
                ( p_module => l_log_module
                 ,p_msg    => 'p_selection_arg_array['||i||']='||p_selection_arg_array(i)
                 ,p_level  => C_LEVEL_STATEMENT
                );
           end loop;



      END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN;

EXCEPTION
WHEN le_resource_busy
THEN
   IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
         ( p_module => l_log_module
          ,p_msg   => 'cannot lock accounting entry records'
          ,p_level => C_LEVEL_ERROR
         );
   END IF;
   RAISE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.build_line_selection_dyn_stmts');
END build_line_selection_dyn_stmts;


FUNCTION load_balance_temp_tables
  ( p_application_id           IN INTEGER
   ,p_request_id               IN INTEGER
   ,p_entity_id                IN INTEGER
   ,p_called_by_flag           IN VARCHAR2
   ,p_balance_flag_pre_update  IN VARCHAR2
   ,p_entry_locking_dyn_stmt   IN VARCHAR2
   ,p_line_selection_dyn_stmt  IN VARCHAR2
   ,p_locking_arg_array        IN t_array_varchar
   ,p_lck_bind_var_count       IN INTEGER
   ,p_selection_arg_array      IN t_array_varchar
   ,p_ins_bind_var_num         IN INTEGER
   )
RETURN INTEGER
IS

CURSOR lc_lock_entries_for_event_API
( p_application_id          INTEGER
 ,p_balance_flag_pre_update VARCHAR2
)
IS
   SELECT ael.ROWID    line_rowid
         ,aeh.ae_header_id
         ,ael.ae_line_num
         ,aeh.application_id
         ,aeh.ledger_id
         ,aeh.period_name
         ,gps.period_year
         ,gps.effective_period_num
         ,aeh.accounting_entry_status_code
         ,ael.control_balance_flag
         ,ael.analytical_balance_flag
         ,ael.code_combination_id
         ,ael.party_type_code
         ,ael.party_id
         ,ael.party_site_id
         ,ael.accounted_dr
         ,ael.accounted_cr
     FROM xla_events              xev
         ,xla_events_gt           xeg
         ,xla_ae_headers          aeh
         ,xla_ae_lines            ael
         ,gl_period_statuses      gps
    WHERE xev.application_id               =  p_application_id
      AND xeg.event_id                     =  xev.event_id
      AND xeg.application_id               =  xev.application_id
      AND xev.process_status_code in ('D', 'I')
      AND aeh.event_id                     =  xev.event_id
      AND aeh.application_id               =  xev.application_id
      AND ael.ae_header_id                 =  aeh.ae_header_id
      AND ael.application_id               =  aeh.application_id
      AND gps.ledger_id                    =  aeh.ledger_id
      AND gps.application_id               =  101
      AND gps.period_name                  =  aeh.period_name
      AND aeh.accounting_entry_status_code =  'F'
      AND (    ael.control_balance_flag    =  p_balance_flag_pre_update
            OR ael.analytical_balance_flag =  p_balance_flag_pre_update
          )
    FOR UPDATE OF ael.ae_line_num NOWAIT;

CURSOR lc_lock_entries_for_request_id
( p_application_id          INTEGER
 ,p_request_id              INTEGER
 ,p_balance_flag_pre_update VARCHAR2
)
IS
   SELECT ael.ROWID    line_rowid
         ,aeh.ae_header_id
         ,ael.ae_line_num
         ,aeh.application_id
         ,aeh.ledger_id
         ,aeh.period_name
         ,gps.period_year
         ,gps.effective_period_num
         ,aeh.accounting_entry_status_code
         ,ael.control_balance_flag
         ,ael.analytical_balance_flag
         ,ael.code_combination_id
         ,ael.party_type_code
         ,ael.party_id
         ,ael.party_site_id
         ,ael.accounted_dr
         ,ael.accounted_cr
     FROM xla_events              xev
         ,xla_ae_headers          aeh
         ,xla_ae_lines            ael
         ,gl_period_statuses      gps
    WHERE xev.request_id                   =  p_request_id
      AND xev.application_id               =  p_application_id
      AND xev.process_status_code  =  'P'
      AND aeh.event_id                     =  xev.event_id
      AND aeh.application_id               =  xev.application_id
      AND ael.ae_header_id                 =  aeh.ae_header_id
      AND ael.application_id               =  aeh.application_id
      AND gps.ledger_id                    =  aeh.ledger_id
      AND gps.application_id               =  101
      AND gps.period_name                  =  aeh.period_name
      AND (    ael.control_balance_flag    =  p_balance_flag_pre_update
            OR ael.analytical_balance_flag =  p_balance_flag_pre_update
          )
    FOR UPDATE OF ael.ae_line_num NOWAIT;


CURSOR lc_lock_entries_for_entity_id
( p_application_id          INTEGER
 ,p_entity_id               INTEGER
 ,p_balance_flag_pre_update VARCHAR2
)
IS
   SELECT ael.ROWID    line_rowid
         ,aeh.ae_header_id
         ,ael.ae_line_num
         ,aeh.application_id
         ,aeh.ledger_id
         ,aeh.period_name
         ,gps.period_year
         ,gps.effective_period_num
         ,aeh.accounting_entry_status_code
         ,ael.control_balance_flag
         ,ael.analytical_balance_flag
         ,ael.code_combination_id
         ,ael.party_type_code
         ,ael.party_id
         ,ael.party_site_id
         ,ael.accounted_dr
         ,ael.accounted_cr
     FROM xla_ae_headers           aeh
         ,xla_ae_lines             ael
         ,gl_period_statuses       gps
    WHERE aeh.application_id               =  p_application_id
      AND aeh.entity_id                    =  p_entity_id
      AND ael.ae_header_id                 =  aeh.ae_header_id
      AND ael.application_id               =  aeh.application_id
      AND gps.ledger_id                    =  aeh.ledger_id
      AND gps.application_id               =  101
      AND gps.period_name                  =  aeh.period_name
      AND aeh.accounting_entry_status_code = 'F'
      AND (    ael.control_balance_flag    =  p_balance_flag_pre_update
            OR ael.analytical_balance_flag =  p_balance_flag_pre_update
          )
    FOR UPDATE OF ael.ae_line_num NOWAIT;

l_row_count                 NUMBER;
l_log_module                VARCHAR2 (2000);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.load_balance_temp_tables';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --if temp tabs are empty this will not take long
   DELETE
     FROM xla_bal_ctrl_lines_gt;

   DELETE
     FROM xla_bal_anacri_lines_gt;

   -- if it is called by bulk event API
   IF p_called_by_flag = 'E' THEN
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg      => 'p_called_by_flag = E '
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

      OPEN lc_lock_entries_for_event_API
        ( p_application_id          => p_application_id
         ,p_balance_flag_pre_update => p_balance_flag_pre_update
        );
      --close the cursor
      CLOSE lc_lock_entries_for_event_API;

      --insert into xla_bal_ctrl_lines_gt and xla_bal_anacri_lines_gt
      INSERT ALL
      WHEN control_balance_flag = p_balance_flag_pre_update
      THEN
      INTO xla_bal_ctrl_lines_gt
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,party_type_code
          ,party_id
          ,party_site_id
          ,accounted_dr
          ,accounted_cr
         )
   VALUES
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,party_type_code
          ,party_id
          ,party_site_id
          ,accounted_dr
          ,accounted_cr
         )
     WHEN analytical_balance_flag = p_balance_flag_pre_update
     THEN
     INTO xla_bal_anacri_lines_gt
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,accounted_dr
          ,accounted_cr
         )
         VALUES
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,accounted_dr
          ,accounted_cr
         )
   SELECT ael.ROWID    line_rowid
         ,aeh.ae_header_id
         ,ael.ae_line_num
         ,aeh.application_id
         ,aeh.ledger_id
         ,aeh.period_name
         ,gps.period_year
         ,gps.effective_period_num
         ,aeh.accounting_entry_status_code
         ,ael.control_balance_flag
         ,ael.analytical_balance_flag
         ,ael.code_combination_id
         ,ael.party_type_code
         ,ael.party_id
         ,NVL(ael.party_site_id,-999)         party_site_id
         ,ael.accounted_dr
         ,ael.accounted_cr
     FROM xla_events_gt           xeg
         ,xla_events              xe
         ,xla_ae_headers          aeh
         ,xla_ae_lines            ael
         ,gl_period_statuses      gps
    WHERE xeg.application_id               =  p_application_id
      AND aeh.application_id               =  xeg.application_id
      AND aeh.event_id                     =  xeg.event_id
      AND xe.event_id                      =  xeg.event_id
      AND xe.application_id                =  xeg.application_id
      AND xe.process_status_code in ('D', 'I')
      AND ael.ae_header_id                 =  aeh.ae_header_id
      AND ael.application_id               =  aeh.application_id
      AND gps.ledger_id                    =  aeh.ledger_id
      AND gps.application_id               =  101
      AND gps.period_name                  =  aeh.period_name
      AND aeh.accounting_entry_status_code =  'F'
      AND gps.closing_status in ('O','C','P')
      AND gps.adjustment_period_flag = 'N'
      AND aeh.balance_type_code = 'A' -- bug 9385087
      AND ( ael.control_balance_flag       =  p_balance_flag_pre_update
         OR ael.analytical_balance_flag    =  p_balance_flag_pre_update
          );

   --If p_request_id is not null
   ELSIF p_request_id IS NOT NULL
   THEN
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg      => 'p_request_id IS NOT NULL'
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

      --Open the corresponding cursor for locking the lines
      OPEN lc_lock_entries_for_request_id
        ( p_application_id          => p_application_id
         ,p_request_id              => p_request_id
         ,p_balance_flag_pre_update => p_balance_flag_pre_update
        );
      --close the cursor
      CLOSE lc_lock_entries_for_request_id;

   --insert into xla_bal_ctrl_lines_gt
   INSERT ALL
     WHEN control_balance_flag = p_balance_flag_pre_update
     THEN
     INTO xla_bal_ctrl_lines_gt
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,party_type_code
          ,party_id
          ,party_site_id
          ,accounted_dr
          ,accounted_cr
         )
   VALUES
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,party_type_code
          ,party_id
          ,party_site_id
          ,accounted_dr
          ,accounted_cr
         )
    WHEN analytical_balance_flag = p_balance_flag_pre_update
    THEN
    INTO xla_bal_anacri_lines_gt
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,accounted_dr
          ,accounted_cr
         )
         VALUES
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,accounted_dr
          ,accounted_cr
         )

   SELECT ael.ROWID    line_rowid
         ,aeh.ae_header_id
         ,ael.ae_line_num
         ,aeh.application_id
         ,aeh.ledger_id
         ,aeh.period_name
         ,gps.period_year
         ,gps.effective_period_num
         ,aeh.accounting_entry_status_code
         ,ael.control_balance_flag
         ,ael.analytical_balance_flag
         ,ael.code_combination_id
         ,ael.party_type_code
         ,ael.party_id
         ,NVL(ael.party_site_id,-999)         party_site_id
         ,ael.accounted_dr
         ,ael.accounted_cr
     FROM xla_events              xev
         ,xla_ae_headers          aeh
         ,xla_ae_lines            ael
         ,gl_period_statuses      gps
    WHERE xev.request_id                   =  p_request_id
      AND xev.application_id               =  p_application_id
      AND xev.process_status_code   = 'P'
      AND aeh.application_id               =  xev.application_id
      AND aeh.event_id                     =  xev.event_id
      AND aeh.balance_type_code            =  'A' --bug 9385087
      AND ael.ae_header_id                 =  aeh.ae_header_id
      AND ael.application_id               =  aeh.application_id
      AND gps.ledger_id                    =  aeh.ledger_id
      AND gps.application_id               =  101
      AND gps.closing_status in ('O','C','P')
      AND gps.adjustment_period_flag = 'N'
      AND gps.period_name                  =  aeh.period_name
      AND (    ael.control_balance_flag    =  p_balance_flag_pre_update
            OR ael.analytical_balance_flag =  p_balance_flag_pre_update
          );
   --If p_entity_id is not null
   ELSIF p_entity_id IS NOT NULL
   THEN
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg      => 'p_entity_id IS NOT NULL'
            ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

      --Open the corresponding cursor for locking the lines
      OPEN lc_lock_entries_for_entity_id
        ( p_application_id          => p_application_id
         ,p_entity_id               => p_entity_id
         ,p_balance_flag_pre_update => p_balance_flag_pre_update
        );
      --close the cursor
      CLOSE lc_lock_entries_for_entity_id;

   --insert into xla_bal_ctrl_lines_gt and xla_bal_anacri_lines_gt
   INSERT ALL
     WHEN control_balance_flag = p_balance_flag_pre_update
     THEN
     INTO xla_bal_ctrl_lines_gt
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,party_type_code
          ,party_id
          ,party_site_id
          ,accounted_dr
          ,accounted_cr
         )
   VALUES
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,party_type_code
          ,party_id
          ,party_site_id
          ,accounted_dr
          ,accounted_cr
         )
     WHEN analytical_balance_flag = p_balance_flag_pre_update
     THEN
     INTO xla_bal_anacri_lines_gt
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,accounted_dr
          ,accounted_cr
         )
   VALUES
         ( line_rowid
          ,ae_header_id
          ,ae_line_num
          ,application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,accounting_entry_status_code
          ,code_combination_id
          ,accounted_dr
          ,accounted_cr
         )

   SELECT ael.ROWID    line_rowid
         ,aeh.ae_header_id
         ,ael.ae_line_num
         ,aeh.application_id
         ,aeh.ledger_id
         ,aeh.period_name
         ,gps.period_year
         ,gps.effective_period_num
         ,aeh.accounting_entry_status_code
         ,ael.control_balance_flag
         ,ael.analytical_balance_flag
         ,ael.code_combination_id
         ,ael.party_type_code
         ,ael.party_id
         ,NVL(ael.party_site_id,-999)         party_site_id
         ,ael.accounted_dr
         ,ael.accounted_cr
     FROM xla_ae_headers           aeh
         ,xla_ae_lines             ael
         ,gl_period_statuses       gps
    WHERE aeh.application_id               =  p_application_id
      AND aeh.entity_id                    =  p_entity_id
      AND ael.ae_header_id                 =  aeh.ae_header_id
      AND ael.application_id               =  aeh.application_id
      AND aeh.balance_type_code        =  'A' --bug 9385087
      AND gps.ledger_id                    =  aeh.ledger_id
      AND gps.application_id               =  101
      AND gps.closing_status           in ('O','C','P')
      AND gps.adjustment_period_flag = 'N'
      AND gps.period_name                  =  aeh.period_name
      AND aeh.accounting_entry_status_code = 'F'
      AND (    ael.control_balance_flag    =  p_balance_flag_pre_update
            OR ael.analytical_balance_flag =  p_balance_flag_pre_update
          );
 -- bug 7441310 begin add bind variables

      --DO NOT MOVE THIS AFTER THE TRACE CODE WHICH AFFECTS SQL%ROWCOUNT
      l_row_count := SQL%ROWCOUNT;
   --else (all other cases where we need a dynamic statement)
   ELSE
     IF g_lock_flag <> 'Y' THEN -- added for performance issue
      --execute immediate the entry locking statement
      if p_lck_bind_var_count = 1 then
        EXECUTE IMMEDIATE p_entry_locking_dyn_stmt using p_locking_arg_array(1);
      else
        if p_lck_bind_var_count = 2 then
          EXECUTE IMMEDIATE p_entry_locking_dyn_stmt using p_locking_arg_array(1),p_locking_arg_array(2);
        else
           if p_lck_bind_var_count = 3 then
             EXECUTE IMMEDIATE p_entry_locking_dyn_stmt using p_locking_arg_array(1),p_locking_arg_array(2),p_locking_arg_array(3);
           else
             if p_lck_bind_var_count = 4 then
                EXECUTE IMMEDIATE p_entry_locking_dyn_stmt using p_locking_arg_array(1),p_locking_arg_array(2),p_locking_arg_array(3),
                  p_locking_arg_array(4);
             else
               if p_lck_bind_var_count = 5 then
                  EXECUTE IMMEDIATE p_entry_locking_dyn_stmt using p_locking_arg_array(1),p_locking_arg_array(2),p_locking_arg_array(3),
                     p_locking_arg_array(4),p_locking_arg_array(5);
               else
                 if p_lck_bind_var_count = 6 then
                    EXECUTE IMMEDIATE p_entry_locking_dyn_stmt using p_locking_arg_array(1),p_locking_arg_array(2),p_locking_arg_array(3),
                     p_locking_arg_array(4),p_locking_arg_array(5),p_locking_arg_array(6);
                 else
                   if p_lck_bind_var_count = 7 then
                     EXECUTE IMMEDIATE p_entry_locking_dyn_stmt using p_locking_arg_array(1),p_locking_arg_array(2),p_locking_arg_array(3),
                                       p_locking_arg_array(4),p_locking_arg_array(5),p_locking_arg_array(6),p_locking_arg_array(7);
                   else
                      if p_lck_bind_var_count = 8 then
                        EXECUTE IMMEDIATE p_entry_locking_dyn_stmt using p_locking_arg_array(1),p_locking_arg_array(2),p_locking_arg_array(3),
                                          p_locking_arg_array(4),p_locking_arg_array(5),p_locking_arg_array(6),p_locking_arg_array(7),
                                          p_locking_arg_array(8);
                      else
                        if p_lck_bind_var_count = 9 then
                           EXECUTE IMMEDIATE p_entry_locking_dyn_stmt using p_locking_arg_array(1),
                                             p_locking_arg_array(2),p_locking_arg_array(3),
                                             p_locking_arg_array(4),p_locking_arg_array(5),p_locking_arg_array(6),
                                             p_locking_arg_array(7),p_locking_arg_array(8),p_locking_arg_array(9);
                        else
                          if p_lck_bind_var_count = 9 then
                             EXECUTE IMMEDIATE p_entry_locking_dyn_stmt using p_locking_arg_array(1),
                                               p_locking_arg_array(2),p_locking_arg_array(3),
                                               p_locking_arg_array(4),p_locking_arg_array(5),p_locking_arg_array(6),
                                               p_locking_arg_array(7),p_locking_arg_array(8),p_locking_arg_array(9),
                                               p_locking_arg_array(10);
                          end if;
                        end if;
                      end if;
                   end if;
                 end if;
               end if;
             end if;
           end if;
         end if;
      end if;
      g_lock_flag := 'Y';

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'Entries locked'
            ,p_level => C_LEVEL_EVENT
            );
      END IF;
    end if; -- added for performance issue
    IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'g_lock_flag ='||g_lock_flag
            ,p_level => C_LEVEL_EVENT
            );
      END IF;

 -- bug 7441310 end add bind variables

 -- bug 7441310 begin add bind variables

      --execute immediate the statement for filling the temp tabs

      if p_ins_bind_var_num = 1 then
        EXECUTE IMMEDIATE p_line_selection_dyn_stmt using p_selection_arg_array(1);
      else
        if p_ins_bind_var_num = 2 then
          EXECUTE IMMEDIATE p_line_selection_dyn_stmt using p_selection_arg_array(1),p_selection_arg_array(2);
        else
           if p_ins_bind_var_num = 3 then
             EXECUTE IMMEDIATE p_line_selection_dyn_stmt using p_selection_arg_array(1),p_selection_arg_array(2),p_selection_arg_array(3);
           else
             if p_ins_bind_var_num = 4 then
                EXECUTE IMMEDIATE p_line_selection_dyn_stmt using p_selection_arg_array(1),p_selection_arg_array(2),p_selection_arg_array(3),
                  p_selection_arg_array(4);
             else
               if p_ins_bind_var_num = 5 then
                  EXECUTE IMMEDIATE p_line_selection_dyn_stmt using p_selection_arg_array(1),p_selection_arg_array(2),p_selection_arg_array(3),
                     p_selection_arg_array(4),p_selection_arg_array(5);
               else
                 if p_ins_bind_var_num = 6 then
                    EXECUTE IMMEDIATE p_line_selection_dyn_stmt using p_selection_arg_array(1),p_selection_arg_array(2),p_selection_arg_array(3),
                     p_selection_arg_array(4),p_selection_arg_array(5),p_selection_arg_array(6);
                 else
                   if p_ins_bind_var_num = 7 then
                     EXECUTE IMMEDIATE p_line_selection_dyn_stmt using p_selection_arg_array(1),p_selection_arg_array(2),p_selection_arg_array(3),
                                       p_selection_arg_array(4),p_selection_arg_array(5),p_selection_arg_array(6),p_selection_arg_array(7);
                   else
                      if p_ins_bind_var_num = 8 then
                        EXECUTE IMMEDIATE p_line_selection_dyn_stmt using p_selection_arg_array(1),p_selection_arg_array(2),p_selection_arg_array(3),
                                          p_selection_arg_array(4),p_selection_arg_array(5),p_selection_arg_array(6),p_selection_arg_array(7),p_selection_arg_array(8);
                      else
                        if p_ins_bind_var_num = 9 then
                           EXECUTE IMMEDIATE p_line_selection_dyn_stmt using p_selection_arg_array(1),
                                             p_selection_arg_array(2),p_selection_arg_array(3),
                                             p_selection_arg_array(4),p_selection_arg_array(5),p_selection_arg_array(6),
                                             p_selection_arg_array(7),p_selection_arg_array(8),p_selection_arg_array(9);
                        else
                           if p_ins_bind_var_num = 10 then
                             EXECUTE IMMEDIATE p_line_selection_dyn_stmt using p_selection_arg_array(1),p_selection_arg_array(2),p_selection_arg_array(3),
                                             p_selection_arg_array(4),p_selection_arg_array(5),p_selection_arg_array(6),p_selection_arg_array(7),p_selection_arg_array(8),
                                             p_selection_arg_array(9);
                           else
                              if p_ins_bind_var_num = 11 then
                                  EXECUTE IMMEDIATE p_line_selection_dyn_stmt using p_selection_arg_array(1),
                                             p_selection_arg_array(2),p_selection_arg_array(3),
                                             p_selection_arg_array(4),p_selection_arg_array(5),p_selection_arg_array(6),
                                             p_selection_arg_array(7),p_selection_arg_array(8),p_selection_arg_array(9),
                                             p_selection_arg_array(10),p_selection_arg_array(11);
                              else
                                 if p_ins_bind_var_num = 11 then
                                    EXECUTE IMMEDIATE p_line_selection_dyn_stmt using p_selection_arg_array(1),
                                          p_selection_arg_array(2),p_selection_arg_array(3),
                                          p_selection_arg_array(4),p_selection_arg_array(5),p_selection_arg_array(6),
                                          p_selection_arg_array(7),p_selection_arg_array(8),p_selection_arg_array(9),
                                          p_selection_arg_array(10),p_selection_arg_array(11),
                                          p_selection_arg_array(12);
                                 end if;
                              end if;
                           end if;
                        end if;
                      end if;
                   end if;
                 end if;
               end if;
             end if;
           end if;
         end if;
      end if;
 -- bug 7441310 end add bind variables

      --DO NOT MOVE THIS AFTER THE TRACE CODE WHICH AFFECTS SQL%ROWCOUNT
      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'Entries selected'
            ,p_level => C_LEVEL_EVENT
            );
      END IF;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module => l_log_module
          ,p_msg    => l_row_count
                       || ' lines inserted in temp tables. '
          ,p_level  => C_LEVEL_STATEMENT
         );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_row_count;

EXCEPTION
WHEN le_resource_busy
THEN
   IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'cannot lock accounting entry records'
          ,p_level => C_LEVEL_ERROR
         );
   END IF;
   RAISE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.load_balance_temp_tables');
END load_balance_temp_tables;



FUNCTION load_alyt_secondary_temp_tabs
          ( p_operation_code             IN VARCHAR2 --'F' Finalize
                                                     --'A' Add
                                                     --'R' Remove
          )
RETURN INTEGER
IS
l_row_count                 NUMBER;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.load_alyt_secondary_temp_tabs';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --if temp tabs are empty this will not take long
   DELETE
     FROM xla_bal_ac_ctrbs_gt;

   IF p_operation_code = 'F'
   THEN
      INSERT
        INTO xla_bal_ac_ctrbs_gt
        ( application_id
         ,ledger_id
         ,period_name
         ,period_year
         ,effective_period_num
         ,code_combination_id
         ,analytical_criterion_code
         ,analytical_criterion_type_code
         ,amb_context_code
         ,ac1
         ,ac2
         ,ac3
         ,ac4
         ,ac5
         ,contribution_dr
         ,contribution_cr
         ,balance_status_eff_per_num
         ,account_type
        )
        (
         SELECT xbct.application_id
               ,xbct.ledger_id
               ,xbct.period_name
               ,xbct.period_year
               ,xbct.effective_period_num
               ,xbct.code_combination_id
               ,xad.analytical_criterion_code
               ,xad.analytical_criterion_type_code
               ,xad.amb_context_code
               ,xad.ac1
               ,xad.ac2
               ,xad.ac3
               ,xad.ac4
               ,xad.ac5
               ,SUM(xbct.accounted_dr)       contribution_dr
               ,SUM(xbct.accounted_cr)       contribution_cr
               ,xbct.balance_status_eff_per_num
               ,xbct.account_type
           FROM xla_bal_anacri_lines_gt  xbct
               ,xla_ae_line_acs          xad
          WHERE xad.ae_header_id   = xbct.ae_header_id
            AND xad.ae_line_num    = xbct.ae_line_num
       GROUP BY xbct.application_id
               ,xbct.ledger_id
               ,xbct.effective_period_num
               ,xbct.period_name
               ,xbct.period_year
               ,xbct.balance_status_eff_per_num
               ,xbct.code_combination_id
               ,xad.analytical_criterion_code
               ,xad.analytical_criterion_type_code
               ,xad.amb_context_code
               ,xad.ac1
               ,xad.ac2
               ,xad.ac3
               ,xad.ac4
               ,xad.ac5
               ,xbct.balance_status_eff_per_num
               ,xbct.balance_status_code
               ,xbct.account_type
        );
      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => l_row_count
                      || ' inserted into xla_bal_ac_ctrbs_gt'
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

   ELSIF p_operation_code ='A'
   THEN
      INSERT
        INTO xla_bal_ac_ctrbs_gt
           ( application_id
            ,ledger_id
            ,period_name
            ,period_year
            ,effective_period_num
            ,code_combination_id
            ,analytical_criterion_code
            ,analytical_criterion_type_code
            ,amb_context_code
            ,ac1
            ,ac2
            ,ac3
            ,ac4
            ,ac5
            ,contribution_dr
            ,contribution_cr
            ,balance_status_eff_per_num
            ,account_type
           )
           (
              --  - perf changes
              SELECT /*+ CARDINALITY(XBCT,1) LEADING(XBCT,XAD) */
                      xbct.application_id
                     ,xbct.ledger_id
                     ,xbct.period_name
                     ,xbct.period_year
                     ,xbct.effective_period_num
                     ,xbct.code_combination_id
                     ,xad.analytical_criterion_code
                     ,xad.analytical_criterion_type_code
                     ,xad.amb_context_code
                     ,xad.ac1
                     ,xad.ac2
                     ,xad.ac3
                     ,xad.ac4
                     ,xad.ac5
                     ,SUM(DECODE( xbct.accounting_entry_status_code
                                 ,'F'
                                 ,xbct.accounted_dr
                                 ,NULL
                                )
                         )  contribution_dr
                     ,SUM(DECODE( xbct.accounting_entry_status_code
                                ,'F'
                                 ,xbct.accounted_cr
                                 ,NULL
                                )
                         )  contribution_cr
                     ,xbct.balance_status_eff_per_num
                     ,xbct.account_type
                FROM xla_bal_anacri_lines_gt  xbct
                    ,xla_ae_line_acs          xad
               WHERE xad.ae_header_id   = xbct.ae_header_id
                 AND xad.ae_line_num    = xbct.ae_line_num
            GROUP BY xbct.application_id
                    ,xbct.ledger_id
                    ,xbct.effective_period_num
                    ,xbct.period_name
                    ,xbct.period_year
                    ,xbct.balance_status_eff_per_num
                    ,xbct.code_combination_id
                    ,xad.analytical_criterion_code
                    ,xad.analytical_criterion_type_code
                    ,xad.amb_context_code
                    ,xad.ac1
                    ,xad.ac2
                    ,xad.ac3
                    ,xad.ac4
                    ,xad.ac5
                    ,xbct.balance_status_eff_per_num
                    ,xbct.balance_status_code
                    ,xbct.account_type
           );
      l_row_count := SQL%ROWCOUNT;
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => l_row_count
                      || ' inserted into xla_bal_ac_ctrbs_gt'
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;
   ELSIF p_operation_code ='R'
   THEN
      INSERT
        INTO xla_bal_ac_ctrbs_gt
           ( application_id
            ,ledger_id
            ,period_name
            ,period_year
            ,effective_period_num
            ,code_combination_id
            ,analytical_criterion_code
            ,analytical_criterion_type_code
            ,amb_context_code
            ,ac1
            ,ac2
            ,ac3
            ,ac4
            ,ac5
            ,contribution_dr
            ,contribution_cr
            ,balance_status_eff_per_num
            ,account_type
           )
           (
              --  - perf changes
              SELECT  /*+ CARDINALITY(XBCT,1) LEADING(XBCT,XAD) */
                      xbct.application_id
                     ,xbct.ledger_id
                     ,xbct.period_name
                     ,xbct.period_year
                     ,xbct.effective_period_num
                     ,xbct.code_combination_id
                     ,xad.analytical_criterion_code
                     ,xad.analytical_criterion_type_code
                     ,xad.amb_context_code
                     ,xad.ac1
                     ,xad.ac2
                     ,xad.ac3
                     ,xad.ac4
                     ,xad.ac5
                     ,SUM(DECODE( xbct.accounting_entry_status_code
                                 ,'F'
                                 ,xbct.accounted_dr
                                 ,NULL
                                )
                         )  * -1 contribution_dr
                     ,SUM(DECODE( xbct.accounting_entry_status_code
                                 ,'F'
                                 ,xbct.accounted_cr
                                 ,NULL
                                )
                         )  * -1 contribution_cr
                     ,xbct.balance_status_eff_per_num
                     ,xbct.account_type
                FROM xla_bal_anacri_lines_gt  xbct
                    ,xla_ae_line_acs          xad
              WHERE xad.ae_header_id   = xbct.ae_header_id
                AND xad.ae_line_num    = xbct.ae_line_num
            GROUP BY xbct.application_id
                    ,xbct.ledger_id
                    ,xbct.effective_period_num
                    ,xbct.period_name
                    ,xbct.period_year
                    ,xbct.balance_status_eff_per_num
                    ,xbct.code_combination_id
                    ,xad.analytical_criterion_code
                    ,xad.analytical_criterion_type_code
                    ,xad.amb_context_code
                    ,xad.ac1
                    ,xad.ac2
                    ,xad.ac3
                    ,xad.ac4
                    ,xad.ac5
                    ,xbct.balance_status_eff_per_num
                    ,xbct.balance_status_code
                    ,xbct.account_type
           );
      l_row_count := SQL%ROWCOUNT;
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => l_row_count
                      || ' inserted into xla_bal_ac_ctrbs_gt'
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

   ELSE --p_operation_code
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg    => 'EXCEPTION: ' || 'Invalid value for p_operation_code: '
                                        || p_operation_code
             ,p_level  => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: ' ||'Invalid value for p_operation_code: '
                                            || p_operation_code);
   END IF; --p_operation_code

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => l_row_count
                      || ' inserted into xla_bal_ac_ctrbs_gt'
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;


   RETURN l_row_count;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.load_alyt_secondary_temp_tabs');
END load_alyt_secondary_temp_tabs;



FUNCTION load_ctrl_secondary_temp_tabs
          ( p_operation_code       IN VARCHAR2 --'F' Finalize
                                               --'A' Add
                                               --'R' Remove
          )
RETURN INTEGER
IS
l_row_count                 NUMBER;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.load_ctrl_secondary_temp_tabs';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --if temp tabs are empty this will not take long
   DELETE
     FROM xla_bal_ctrl_ctrbs_gt;

   IF p_operation_code = 'F'
   THEN
      INSERT
        INTO xla_bal_ctrl_ctrbs_gt
     ( application_id
      ,ledger_id
      ,period_name
      ,period_year
      ,effective_period_num
      ,code_combination_id
      ,party_type_code
      ,party_id
      ,party_site_id
      ,contribution_dr
      ,contribution_cr
      ,contribution_draft_dr
      ,contribution_draft_cr
      ,balance_status_eff_per_num
     )
     (
        SELECT  xbct.application_id
               ,xbct.ledger_id
               ,xbct.period_name
               ,xbct.period_year
               ,xbct.effective_period_num
               ,xbct.code_combination_id
               ,xbct.party_type_code
               ,xbct.party_id
               ,xbct.party_site_id
               ,SUM(xbct.accounted_dr)       contribution_dr
               ,SUM(xbct.accounted_cr)       contribution_cr
               ,SUM(xbct.accounted_dr) * -1  contribution_draft_dr
               ,SUM(xbct.accounted_cr) * -1  contribution_draft_cr
               ,xbct.balance_status_eff_per_num
           FROM xla_bal_ctrl_lines_gt  xbct
       GROUP BY xbct.application_id
               ,xbct.ledger_id
               ,xbct.effective_period_num
               ,xbct.period_name
               ,xbct.period_year
               ,xbct.balance_status_eff_per_num
               ,xbct.code_combination_id
               ,xbct.party_type_code
               ,xbct.party_id
               ,xbct.party_site_id
               ,xbct.balance_status_eff_per_num
               ,xbct.balance_status_code
      );
      l_row_count := SQL%ROWCOUNT;
   ELSIF p_operation_code ='A'
   THEN
      INSERT
        INTO xla_bal_ctrl_ctrbs_gt
         ( application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,code_combination_id
          ,party_type_code
          ,party_id
          ,party_site_id
          ,contribution_dr
          ,contribution_cr
          ,contribution_draft_dr
          ,contribution_draft_cr
          ,balance_status_eff_per_num
         )
         (
            SELECT  xbct.application_id
                   ,xbct.ledger_id
                   ,xbct.period_name
                   ,xbct.period_year
                   ,xbct.effective_period_num
                   ,xbct.code_combination_id
                   ,xbct.party_type_code
                   ,xbct.party_id
                   ,xbct.party_site_id
                   ,SUM(DECODE( xbct.accounting_entry_status_code
                               ,'F'
                               ,xbct.accounted_dr
                               ,NULL
                              )
                       )  contribution_dr
                   ,SUM(DECODE( xbct.accounting_entry_status_code
                               ,'F'
                               ,xbct.accounted_cr
                               ,NULL
                              )
                       )  contribution_cr
                   ,SUM(DECODE( xbct.accounting_entry_status_code
                               ,'D'
                               ,xbct.accounted_dr
                               ,NULL
                              )
                       )  contribution_draft_dr
                   ,SUM(DECODE( xbct.accounting_entry_status_code
                               ,'D'
                               ,xbct.accounted_cr
                               ,NULL
                              )
                       )  contribution_draft_cr
                   ,xbct.balance_status_eff_per_num
              FROM xla_bal_ctrl_lines_gt  xbct
          GROUP BY xbct.application_id
                  ,xbct.ledger_id
                  ,xbct.effective_period_num
                  ,xbct.period_name
                  ,xbct.period_year
                  ,xbct.balance_status_eff_per_num
                  ,xbct.code_combination_id
                  ,xbct.party_type_code
                  ,xbct.party_id
                  ,xbct.party_site_id
                  ,xbct.balance_status_eff_per_num
                  ,xbct.balance_status_code
         );
      l_row_count := SQL%ROWCOUNT;
   ELSIF p_operation_code ='R'
   THEN
      INSERT
        INTO xla_bal_ctrl_ctrbs_gt
         ( application_id
          ,ledger_id
          ,period_name
          ,period_year
          ,effective_period_num
          ,code_combination_id
          ,party_type_code
          ,party_id
          ,party_site_id
          ,contribution_dr
          ,contribution_cr
          ,contribution_draft_dr
          ,contribution_draft_cr
          ,balance_status_eff_per_num
         )
         (
            SELECT  xbct.application_id
                   ,xbct.ledger_id
                   ,xbct.period_name
                   ,xbct.period_year
                   ,xbct.effective_period_num
                   ,xbct.code_combination_id
                   ,xbct.party_type_code
                   ,xbct.party_id
                   ,xbct.party_site_id
                   ,SUM(DECODE( xbct.accounting_entry_status_code
                               ,'F'
                               ,xbct.accounted_dr
                               ,NULL
                              )
                       )  * -1 contribution_dr
                   ,SUM(DECODE( xbct.accounting_entry_status_code
                               ,'F'
                               ,xbct.accounted_cr
                               ,NULL
                              )
                       )  * -1 contribution_cr
                   ,SUM(DECODE( xbct.accounting_entry_status_code
                               ,'D'
                               ,xbct.accounted_dr
                               ,NULL
                              )
                       )  * -1 contribution_draft_dr
                   ,SUM(DECODE( xbct.accounting_entry_status_code
                               ,'D'
                               ,xbct.accounted_cr
                               ,NULL
                              )
                       )  * -1 contribution_draft_cr
                   ,xbct.balance_status_eff_per_num
               FROM xla_bal_ctrl_lines_gt  xbct
           GROUP BY xbct.application_id
                   ,xbct.ledger_id
                   ,xbct.effective_period_num
                   ,xbct.period_name
                   ,xbct.period_year
                   ,xbct.balance_status_eff_per_num
                   ,xbct.code_combination_id
                   ,xbct.party_type_code
                   ,xbct.party_id
                   ,xbct.party_site_id
                   ,xbct.balance_status_eff_per_num
                   ,xbct.balance_status_code
          );

      l_row_count := SQL%ROWCOUNT;

   ELSE --p_operation_code
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
             ,p_msg   => 'EXCEPTION: ' ||
'Invalid value for p_operation_code: ' || p_operation_code
            ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: ' ||
'Invalid value for p_operation_code: ' || p_operation_code);

   END IF; --p_operation_code

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => l_row_count ||
                      ' inserted into xla_bal_ctrl_ctrbs_gt'
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_row_count;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.load_ctrl_secondary_temp_tabs');
END load_ctrl_secondary_temp_tabs;


PROCEDURE insert_ledger_period_statuses
          ( p_ledger_id                   IN INTEGER
           ,p_equal_to_eff_per_num        IN INTEGER
           ,p_grt_or_equal_to_eff_per_num IN INTEGER
           ,p_grteq_1_diff_2_arg1         IN INTEGER
           ,p_grteq_1_diff_2_arg2         IN INTEGER
           ,p_grteq_1_less_2_arg1         IN INTEGER
           ,p_grteq_1_less_2_arg2         IN INTEGER
          )
IS
l_row_count                 NUMBER;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_ledger_period_statuses';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF  p_equal_to_eff_per_num        IS NOT NULL
   AND p_grt_or_equal_to_eff_per_num IS NULL
   AND p_grteq_1_diff_2_arg1         IS NULL
   AND p_grteq_1_diff_2_arg2         IS NULL
   AND p_grteq_1_less_2_arg1         IS NULL
   AND p_grteq_1_less_2_arg2         IS NULL
   THEN
      --**Insert a record = p_equal_to_eff_per_num
--Disregarded indentation for readability
INSERT
  INTO xla_bal_period_stats_gt
     ( ledger_id
      ,period_name
      ,effective_period_num
      ,period_year
      ,first_period_in_year_flag
     )
     (
       SELECT gps.ledger_id
             ,gps.period_name
             ,gps.effective_period_num
             ,gps.period_year
             ,( SELECT NVL2( MAX(gps2.effective_period_num)
                            ,'N'
                            ,'Y'
                           )
                  FROM gl_period_statuses gps2
                 WHERE gps2.application_id         =  101
                   AND gps2.ledger_id              =  gps.ledger_id
                   AND gps2.closing_status         IN ('O','C','P')
                   AND gps2.adjustment_period_flag =  'N'
                   AND gps2.period_year            =  gps.period_year
                   AND gps2.effective_period_num   <  gps.effective_period_num
              ) first_period_in_year_flag
         FROM gl_period_statuses gps
        WHERE gps.application_id         =  101
          AND gps.ledger_id              =  p_ledger_id
          AND gps.closing_status         IN ('O','C','P')
          AND gps.adjustment_period_flag =  'N'
          AND gps.effective_period_num   =  p_equal_to_eff_per_num
          AND (gps.ledger_id, gps.period_name)
              NOT IN (SELECT xbp.ledger_id, xbp.period_name
                        FROM xla_bal_period_stats_gt xbp
                     )
     );

      l_row_count := SQL%ROWCOUNT;


   ELSIF p_grt_or_equal_to_eff_per_num IS NOT NULL
     AND p_equal_to_eff_per_num        IS NULL
     AND p_grteq_1_diff_2_arg1         IS NULL
     AND p_grteq_1_diff_2_arg2         IS NULL
     AND p_grteq_1_less_2_arg1         IS NULL
     AND p_grteq_1_less_2_arg2         IS NULL

   THEN
      --**insert records >= p_grt_or_equal_to_eff_per_num
--Disregarded indentation for readability
INSERT
  INTO xla_bal_period_stats_gt
     ( ledger_id
      ,period_name
      ,effective_period_num
      ,period_year
      ,first_period_in_year_flag
     )
     (
       SELECT gps.ledger_id
             ,gps.period_name
             ,gps.effective_period_num
             ,gps.period_year
             ,( SELECT NVL2( MAX(gps2.effective_period_num)
                            ,'N'
                            ,'Y'
                           )
                  FROM gl_period_statuses gps2
                 WHERE gps2.application_id         =  101
                   AND gps2.ledger_id              =  gps.ledger_id
                   AND gps2.closing_status         IN ('O','C','P')
                   AND gps2.adjustment_period_flag =  'N'
                   AND gps2.period_year            =  gps.period_year
                   AND gps2.effective_period_num   <  gps.effective_period_num
              ) first_period_in_year_flag
         FROM gl_period_statuses gps
        WHERE gps.application_id         =  101
          AND gps.ledger_id              =  p_ledger_id
          AND gps.closing_status         IN ('O','C','P')
          AND gps.adjustment_period_flag =  'N'
          AND gps.effective_period_num   >= p_grt_or_equal_to_eff_per_num
          AND (gps.ledger_id, gps.period_name)
              NOT IN (SELECT xbp.ledger_id, xbp.period_name
                        FROM xla_bal_period_stats_gt xbp
                     )
     );

      l_row_count := SQL%ROWCOUNT;

   ELSIF p_grteq_1_diff_2_arg1         IS NOT NULL
     AND p_grteq_1_diff_2_arg2         IS NOT NULL
     AND p_equal_to_eff_per_num        IS NULL
     AND p_grt_or_equal_to_eff_per_num IS NULL
     AND p_grteq_1_less_2_arg1         IS NULL
     AND p_grteq_1_less_2_arg2         IS NULL
   THEN
    --**insert records > p_grt_1_diff_2_arg1 but <> p_grt_1_diff_2_arg2
--Disregarded indentation for readability
INSERT
  INTO xla_bal_period_stats_gt
     ( ledger_id
      ,period_name
      ,effective_period_num
      ,period_year
      ,first_period_in_year_flag
     )
     (
      SELECT gps.ledger_id
            ,gps.period_name
            ,gps.effective_period_num
            ,gps.period_year
            ,( SELECT NVL2( MAX(gps2.effective_period_num)
                            ,'N'
                            ,'Y'
                          )
                 FROM gl_period_statuses gps2
                WHERE gps2.application_id         =  101
                  AND gps2.ledger_id              =  gps.ledger_id
                  AND gps2.closing_status         IN ('O','C','P')
                  AND gps2.adjustment_period_flag =  'N'
                  AND gps2.period_year            =  gps.period_year
                  AND gps2.effective_period_num   <  gps.effective_period_num
              ) first_period_in_year_flag
        FROM gl_period_statuses gps
       WHERE gps.application_id         =  101
         AND gps.ledger_id              =  p_ledger_id
         AND gps.closing_status         IN ('O','C','P')
         AND gps.adjustment_period_flag =  'N'
         AND gps.effective_period_num   >= p_grteq_1_diff_2_arg1
         AND gps.effective_period_num   <> p_grteq_1_diff_2_arg2
         AND (gps.ledger_id, gps.period_name)
             NOT IN (SELECT xbp.ledger_id, xbp.period_name
                       FROM xla_bal_period_stats_gt xbp
                    )
     );

      l_row_count := SQL%ROWCOUNT;

   ELSIF p_grteq_1_less_2_arg1         IS NOT NULL
     AND p_grteq_1_less_2_arg2         IS NOT NULL
     AND p_equal_to_eff_per_num        IS NULL
     AND p_grt_or_equal_to_eff_per_num IS NULL
     AND p_grteq_1_diff_2_arg1         IS NULL
     AND p_grteq_1_diff_2_arg2         IS NULL
   THEN
      --**insert records >= p_grteq_1_less_2_arg1 but < p_grteq_1_less_2_arg2
--Disregarded indentation for readability
INSERT
  INTO xla_bal_period_stats_gt
     ( ledger_id
      ,period_name
      ,effective_period_num
      ,period_year
      ,first_period_in_year_flag
     )
     (
      SELECT gps.ledger_id
            ,gps.period_name
            ,gps.effective_period_num
            ,gps.period_year
            ,( SELECT NVL2( MAX(gps2.effective_period_num)
                            ,'N'
                            ,'Y'
                          )
                 FROM gl_period_statuses gps2
                WHERE gps2.application_id         =  101
                  AND gps2.ledger_id              =  gps.ledger_id
                  AND gps2.closing_status         IN ('O','C','P')
                  AND gps2.adjustment_period_flag =  'N'
                  AND gps2.period_year            =  gps.period_year
                  AND gps2.effective_period_num   <  gps.effective_period_num
              ) first_period_in_year_flag
        FROM gl_period_statuses gps
       WHERE gps.application_id         =  101
         AND gps.ledger_id              =  p_ledger_id
         AND gps.closing_status         IN ('O','C','P')
         AND gps.adjustment_period_flag =  'N'
         AND gps.effective_period_num   >= p_grteq_1_less_2_arg1
         AND gps.effective_period_num   <  p_grteq_1_less_2_arg2
         AND (gps.ledger_id, gps.period_name)
           NOT IN (SELECT xbp.ledger_id, xbp.period_name
                    FROM xla_bal_period_stats_gt xbp
                  )
     );

      l_row_count := SQL%ROWCOUNT;

   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
                        'Unsupported combinations of parameters'
            ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:' ||
                        'Unsupported combinations of parameters');
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => l_row_count
                     || ' inserted into xla_bal_period_stats_gt'
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.insert_ledger_period_statuses');
END insert_ledger_period_statuses;


PROCEDURE cache_ledger_period_statuses
          ( p_ledger_id          IN INTEGER
           ,p_first_eff_per_num  IN INTEGER
           ,p_load_single_period IN BOOLEAN
          )
IS
l_row_count                 NUMBER;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.cache_ledger_period_statuses';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF g_cached_ledgers.EXISTS(p_ledger_id)
   THEN
      IF p_load_single_period
      THEN
         IF g_cached_single_period
         THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_module => l_log_module
                  ,p_msg   => '1 g_cached_single_period IS TRUE'
                   ,p_level => C_LEVEL_STATEMENT
                  );
            END IF;

            IF g_cached_ledgers(p_ledger_id) <> p_first_eff_per_num
            THEN
               DELETE
                 FROM xla_bal_period_stats_gt xbst
                WHERE xbst.ledger_id = p_ledger_id;

               l_row_count := SQL%ROWCOUNT;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                  (p_module => l_log_module
                  ,p_msg   => l_row_count  ||
                               ' deleted from xla_bal_period_stats_gt'
                   ,p_level => C_LEVEL_STATEMENT
                  );
               END IF;

               --**Insert a record = p_first_eff_per_num
               insert_ledger_period_statuses
                  ( p_ledger_id                   => p_ledger_id
                   ,p_equal_to_eff_per_num        => p_first_eff_per_num
                   ,p_grt_or_equal_to_eff_per_num => NULL
                   ,p_grteq_1_diff_2_arg1         => NULL
                   ,p_grteq_1_diff_2_arg2         => NULL
                   ,p_grteq_1_less_2_arg1         => NULL
                   ,p_grteq_1_less_2_arg2         => NULL
                  );
            ELSE --g_cached_ledgers(p_ledger_id) = p_first_eff_per_num
               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                  (p_module => l_log_module
                   ,p_msg   => 'Already cached, no action performed'
                   ,p_level => C_LEVEL_STATEMENT
                  );
               END IF;
            END IF; --g_cached_ledgers(p_ledger_id) <> p_first_eff_per_num
         ELSE --g_cached_single_period IS NOT TRUE
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_module => l_log_module
                  ,p_msg   => '2 g_cached_single_period IS FALSE'
                   ,p_level => C_LEVEL_STATEMENT
                  );
            END IF;

            IF g_cached_ledgers(p_ledger_id) < p_first_eff_per_num
            THEN
               DELETE
                 FROM xla_bal_period_stats_gt xbst
                WHERE xbst.ledger_id = p_ledger_id
                  AND (   xbst.effective_period_num < p_first_eff_per_num
                       OR xbst.effective_period_num > p_first_eff_per_num
                      );

               l_row_count := SQL%ROWCOUNT;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                  (p_module => l_log_module
                  ,p_msg   => l_row_count ||
                               ' deleted from xla_bal_period_stats_gt'
                   ,p_level => C_LEVEL_STATEMENT
                  );
               END IF;
            ELSIF g_cached_ledgers(p_ledger_id) = p_first_eff_per_num
            THEN
               DELETE
                 FROM xla_bal_period_stats_gt xbst
                WHERE xbst.ledger_id            = p_ledger_id
                  AND xbst.effective_period_num > p_first_eff_per_num;

               l_row_count := SQL%ROWCOUNT;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                  (p_module => l_log_module
                  ,p_msg   => l_row_count ||
                               ' deleted from xla_bal_period_stats_gt'
                   ,p_level => C_LEVEL_STATEMENT
                  );
               END IF;
            ELSE --g_cached_ledgers(p_ledger_id) > p_first_eff_per_num
               DELETE
                 FROM xla_bal_period_stats_gt xbst
                WHERE xbst.ledger_id            = p_ledger_id;

               l_row_count := SQL%ROWCOUNT;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                  (p_module => l_log_module
                  ,p_msg   => l_row_count ||
                              ' deleted from xla_bal_period_stats_gt'
                   ,p_level => C_LEVEL_STATEMENT
                  );
               END IF;
               --***Insert a record = p_first_eff_per_num
               insert_ledger_period_statuses
                  ( p_ledger_id                   => p_ledger_id
                   ,p_equal_to_eff_per_num        => p_first_eff_per_num
                   ,p_grt_or_equal_to_eff_per_num => NULL
                   ,p_grteq_1_diff_2_arg1         => NULL
                   ,p_grteq_1_diff_2_arg2         => NULL
                   ,p_grteq_1_less_2_arg1         => NULL
                   ,p_grteq_1_less_2_arg2         => NULL
                  );
            END IF; --g_cached_ledgers(p_ledger_id) < p_first_eff_per_num

         END IF; --g_cached_single_period

         g_cached_ledgers(p_ledger_id) := p_first_eff_per_num;
         g_cached_single_period := TRUE;

      ELSE --NOT p_load_single_period
         IF g_cached_single_period
         THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_module => l_log_module
                  ,p_msg   => '3 g_cached_single_period IS TRUE'
                   ,p_level => C_LEVEL_STATEMENT
                  );
            END IF;
            IF g_cached_ledgers(p_ledger_id) < p_first_eff_per_num
            THEN
               DELETE
                 FROM xla_bal_period_stats_gt xbst
                WHERE xbst.ledger_id            = p_ledger_id
                  AND xbst.effective_period_num < p_first_eff_per_num;

               l_row_count := SQL%ROWCOUNT;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                     (p_module => l_log_module
                     ,p_msg   => l_row_count ||
                                 ' deleted from xla_bal_period_stats_gt'
                      ,p_level => C_LEVEL_STATEMENT
                     );
               END IF;

               --**insert records >= p_first_eff_per_num
               insert_ledger_period_statuses
                  ( p_ledger_id                   => p_ledger_id
                   ,p_equal_to_eff_per_num        => NULL
                   ,p_grt_or_equal_to_eff_per_num => p_first_eff_per_num
                   ,p_grteq_1_diff_2_arg1         => NULL
                   ,p_grteq_1_diff_2_arg2         => NULL
                   ,p_grteq_1_less_2_arg1         => NULL
                   ,p_grteq_1_less_2_arg2         => NULL
                  );
            ELSE --g_cached_ledgers(p_ledger_id) >= p_first_eff_per_num
               --**insert records > p_first_eff_per_num but <> g_cached_ledgers(p_ledger_id)
               insert_ledger_period_statuses
                  ( p_ledger_id                   => p_ledger_id
                   ,p_equal_to_eff_per_num        => NULL
                   ,p_grt_or_equal_to_eff_per_num => NULL
                   ,p_grteq_1_diff_2_arg1         => p_first_eff_per_num
                   ,p_grteq_1_diff_2_arg2         => g_cached_ledgers(p_ledger_id)
                   ,p_grteq_1_less_2_arg1         => NULL
                   ,p_grteq_1_less_2_arg2         => NULL
                  );
            END IF; --g_cached_ledgers(p_ledger_id) < p_first_eff_per_num
         ELSE --g_cached_single_period IS NOT TRUE
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                     (p_module => l_log_module
                     ,p_msg   => '4 g_cached_single_period IS FALSE'
                      ,p_level => C_LEVEL_STATEMENT
                     );
            END IF;
            IF g_cached_ledgers(p_ledger_id) = p_first_eff_per_num
            THEN
               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                     (p_module => l_log_module
                     ,p_msg   => 'Already cached, no action performed'
                      ,p_level => C_LEVEL_STATEMENT
                     );
               END IF;
            ELSIF g_cached_ledgers(p_ledger_id) < p_first_eff_per_num
            THEN
               DELETE
                 FROM xla_bal_period_stats_gt xbst
                WHERE xbst.ledger_id = p_ledger_id
                  AND xbst.effective_period_num < p_first_eff_per_num;

               l_row_count := SQL%ROWCOUNT;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                     (p_module => l_log_module
                     ,p_msg   => l_row_count ||
                                  ' deleted from xla_bal_period_stats_gt'
                      ,p_level => C_LEVEL_STATEMENT
                     );
               END IF;
            ELSE --g_cached_ledgers(p_ledger_id) > p_first_eff_per_num
               --**insert records >= p_first_eff_per_num but < g_cached_ledgers(p_ledger_id)
               insert_ledger_period_statuses
                  ( p_ledger_id                   => p_ledger_id
                   ,p_equal_to_eff_per_num        => NULL
                   ,p_grt_or_equal_to_eff_per_num => NULL
                   ,p_grteq_1_diff_2_arg1         => NULL
                   ,p_grteq_1_diff_2_arg2         => NULL
                   ,p_grteq_1_less_2_arg1         => p_first_eff_per_num
                   ,p_grteq_1_less_2_arg2         => g_cached_ledgers(p_ledger_id)
                  );
            END IF; --g_cached_ledgers(p_ledger_id) = p_first_eff_per_num
         END IF; --g_cached_single_period

         g_cached_ledgers(p_ledger_id) := p_first_eff_per_num;
         g_cached_single_period := FALSE;
      END IF; --p_load_single_period

   ELSE --ledger_id is not yet cached
      IF p_load_single_period
      THEN
         g_cached_single_period := TRUE;
         g_cached_ledgers(p_ledger_id) := p_first_eff_per_num;
         --*** insert record = p_first_eff_per_num
         insert_ledger_period_statuses
                  ( p_ledger_id                   => p_ledger_id
                   ,p_equal_to_eff_per_num        => p_first_eff_per_num
                   ,p_grt_or_equal_to_eff_per_num => NULL
                   ,p_grteq_1_diff_2_arg1         => NULL
                   ,p_grteq_1_diff_2_arg2         => NULL
                   ,p_grteq_1_less_2_arg1         => NULL
                   ,p_grteq_1_less_2_arg2         => NULL
                  );
      ELSE --NOT p_load_single_period
         g_cached_single_period := FALSE;
         g_cached_ledgers(p_ledger_id) := p_first_eff_per_num;
         --**insert record >= p_first_eff_per_num
         insert_ledger_period_statuses
                  ( p_ledger_id                   => p_ledger_id
                   ,p_equal_to_eff_per_num        => NULL
                   ,p_grt_or_equal_to_eff_per_num => p_first_eff_per_num
                   ,p_grteq_1_diff_2_arg1         => NULL
                   ,p_grteq_1_diff_2_arg2         => NULL
                   ,p_grteq_1_less_2_arg1         => NULL
                   ,p_grteq_1_less_2_arg2         => NULL
                  );
      END IF; --p_load_single_period
   END IF; --g_cached_ledgers.EXISTS(p_ledger_id)

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.cache_ledger_period_statuses');
END cache_ledger_period_statuses;



FUNCTION calculate_balances
  ( p_application_id             IN INTEGER
   ,p_ledger_id                  IN INTEGER
   ,p_entity_id                  IN INTEGER
   ,p_event_id                   IN INTEGER
   ,p_request_id                 IN INTEGER
   ,p_accounting_batch_id        IN INTEGER
   ,p_ae_header_id               IN INTEGER
   ,p_ae_line_num                IN INTEGER
   ,p_code_combination_id        IN INTEGER
   ,p_period_name                IN VARCHAR2
   ,p_update_mode                IN VARCHAR2
   ,p_balance_source_code        IN VARCHAR2
   ,p_called_by_flag             IN VARCHAR2
   ,p_commit_flag                IN VARCHAR2
  )
RETURN BOOLEAN
IS

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
+======================================================================*/

l_temp_rows_inserted           INTEGER;

l_balance_flag_pre_update      VARCHAR2(1);
l_balance_flag_post_update     VARCHAR2(1);

l_operation_code               VARCHAR2(1);
l_entry_locking_dyn_stmt       VARCHAR2(4000);
l_line_selection_dyn_stmt      VARCHAR2(4000);

l_entry_locking_required       BOOLEAN;
l_result                       BOOLEAN;
l_exit_after_calculation       BOOLEAN;

l_locking_arg_array         t_array_varchar;
l_lck_bind_var_count        INTEGER;


l_selection_arg_array      t_array_varchar;
l_ins_bind_var_num         INTEGER;





l_row_count                    NUMBER;


l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.calculate_balances';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

--WARNING:
--This procedure contains intermediate exit points for performance reasons!

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_application_id        :' || p_application_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_ledger_id             :' || p_ledger_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_entity_id             :' || p_event_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_event_id              :' || p_entity_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_request_id            :' || p_request_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_accounting_batch_id   :' || p_accounting_batch_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_ae_header_id          :' || p_ae_header_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_ae_line_num           :' || p_ae_line_num
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_code_combination_id   :' || p_code_combination_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_period_name           :' || p_period_name
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_update_mode           :' || p_update_mode
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_balance_source_code   :' || p_balance_source_code
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_commit_flag           :' || p_commit_flag
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_called_by_flag           :' || p_called_by_flag
          ,p_level => C_LEVEL_STATEMENT
         );
	   trace
         (p_module => l_log_module
         ,p_msg   =>  'batch commit size           :' ||C_BATCH_COMMIT_SIZE
	 ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   IF p_update_mode = 'A'
   THEN
      l_balance_flag_pre_update  := 'P';
      l_balance_flag_post_update := 'Y';

   ELSIF p_update_mode = 'D'
   THEN
      l_balance_flag_pre_update  := 'Y';
      l_balance_flag_post_update := 'P';

   ELSIF p_update_mode = 'F'
   THEN
      IF p_commit_flag = 'Y'
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'Unsupported p_update_mode: ' || p_update_mode || ' with p_commit_flag: ' ||
                         p_commit_flag
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:' ||
'Unsupported p_update_mode: ' || p_update_mode || ' with p_commit_flag: ' ||
                         p_commit_flag);
      END IF;
      l_balance_flag_pre_update  := 'Y';
      l_balance_flag_post_update := 'Y';

   ELSIF p_update_mode = 'M'
   THEN
      l_balance_flag_pre_update  := 'P';
      l_balance_flag_post_update := 'Y';

      trace
         ( p_module => l_log_module
          ,p_msg   => 'Balance calculation will be performed ' ||
                     'in maintenance mode'
          ,p_level => C_LEVEL_ERROR
         );

   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
                         'Unkown p_update_mode value: ' || p_update_mode
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:' ||
                         'Unkown p_update_mode value: ' || p_update_mode);
   END IF;

   IF  p_balance_source_code IS NOT NULL
   AND p_balance_source_code NOT IN ('C', 'A')
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'Unsupported p_balance_source_code value: ' || p_balance_source_code
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:' ||
'Unsupported p_balance_source_code value: ' || p_balance_source_code);
   END IF;

   -- modify to skip the call if p_called_by_flag is not null
   IF  p_request_id IS NULL
   AND p_entity_id  IS NULL
   AND p_called_by_flag is NULL
   THEN
      build_line_selection_dyn_stmts
       ( p_application_id           => p_application_id
        ,p_ledger_id                => p_ledger_id
        ,p_event_id                 => p_event_id
        ,p_accounting_batch_id      => p_accounting_batch_id
        ,p_ae_header_id             => p_ae_header_id
        ,p_ae_line_num              => p_ae_line_num
        ,p_code_combination_id      => p_code_combination_id
        ,p_period_name              => p_period_name
        ,p_balance_source_code      => p_balance_source_code
        ,p_balance_flag_pre_update  => l_balance_flag_pre_update
        ,p_balance_flag_post_update => l_balance_flag_post_update
        ,p_commit_flag              => p_commit_flag
        ,p_entry_locking_dyn_stmt   => l_entry_locking_dyn_stmt
        ,p_line_selection_dyn_stmt  => l_line_selection_dyn_stmt
        ,p_locking_arg_array        => l_locking_arg_array
        ,p_lck_bind_var_count       => l_lck_bind_var_count
        ,p_selection_arg_array      => l_selection_arg_array
        ,p_ins_bind_var_num         => l_ins_bind_var_num
       );
   END IF;

   LOOP

      SAVEPOINT SAVEPOINT_INCREMENTAL;

      l_temp_rows_inserted := load_balance_temp_tables
         ( p_application_id           => p_application_id
          ,p_request_id               => p_request_id
          ,p_entity_id                => p_entity_id
          ,p_called_by_flag           => p_called_by_flag
          ,p_balance_flag_pre_update  => l_balance_flag_pre_update
          ,p_entry_locking_dyn_stmt   => l_entry_locking_dyn_stmt
          ,p_line_selection_dyn_stmt  => l_line_selection_dyn_stmt
          ,p_locking_arg_array        => l_locking_arg_array
          ,p_lck_bind_var_count       => l_lck_bind_var_count
          ,p_selection_arg_array      => l_selection_arg_array
          ,p_ins_bind_var_num         => l_ins_bind_var_num
         )  ;

      IF p_commit_flag = 'Y' THEN
         IF l_temp_rows_inserted = 0
         THEN
            l_result := TRUE;
            EXIT;
         ELSIF l_temp_rows_inserted < C_BATCH_COMMIT_SIZE
            -- not accurate because of the multi-insert
            -- but it works for small calculations
            -- which is when the check is more useful
         THEN
            l_exit_after_calculation := TRUE;
         ELSE
            l_exit_after_calculation := FALSE;
         END IF;
      ELSE
         IF l_temp_rows_inserted = 0
         THEN
            l_result := TRUE;
            EXIT;
         ELSE
            l_exit_after_calculation := TRUE;
         END IF;
      END IF;

      IF p_update_mode <> 'M'
      THEN
         IF  p_commit_flag = 'Y'
         THEN
            --If commit flag is set then the balance calculation was not called in
            --online mode. Hence we have time to call the open period routine.
            FOR l_apps_ldgr IN
                 (
                  SELECT DISTINCT
                         xbct.application_id
                        ,xbct.ledger_id
                    FROM xla_bal_ctrl_lines_gt xbct
                   UNION
                  SELECT DISTINCT
                         xbat.application_id
                        ,xbat.ledger_id
                    FROM xla_bal_anacri_lines_gt xbat
                  )
            LOOP
               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                   ( p_module => l_log_module
                    ,p_msg   => 'Moving bals forward for ledger id: '
                                || l_apps_ldgr.ledger_id
                    ,p_level => C_LEVEL_STATEMENT
                   );
               END IF;

               IF NVL(p_balance_source_code, 'C') = 'C'
               THEN
                  IF NOT AUT_check_create_period_bals
                    ( p_application_id      => l_apps_ldgr.application_id
                     ,p_ledger_id           => l_apps_ldgr.ledger_id
                     ,p_balance_source_code => 'C'
                    )
                  THEN
                     ROLLBACK TO SAVEPOINT_INCREMENTAL;
                     IF (C_LEVEL_EVENT >= g_log_level) THEN
                     trace
                        ( p_module => l_log_module
                         ,p_msg    => 'Rolled back to SAVE POINT'
                                      || l_apps_ldgr.ledger_id
                         ,p_level  => C_LEVEL_EVENT
                        );
                     END IF;
                     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
                        trace
                           ( p_module   => l_log_module
                            ,p_msg      => 'END ' || l_log_module
                            ,p_level    => C_LEVEL_PROCEDURE);
                     END IF;
                     RETURN FALSE;
                  END IF;
               END IF;

               IF NVL(p_balance_source_code, 'A') = 'A'
               THEN
                  IF NOT AUT_check_create_period_bals
                    ( p_application_id      => l_apps_ldgr.application_id
                     ,p_ledger_id           => l_apps_ldgr.ledger_id
                     ,p_balance_source_code => 'A'
                    )
                  THEN
                     ROLLBACK TO SAVEPOINT_INCREMENTAL;
                     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
                        trace
                           ( p_module => l_log_module
                            ,p_msg      => 'END ' || l_log_module
                            ,p_level    => C_LEVEL_PROCEDURE);
                     END IF;
                     RETURN FALSE;
                  END IF;
               END IF;
            END LOOP;
         END IF; --p_commit_flag
      END IF;  --p_update_mode

      IF NOT lock_create_balance_statuses
      THEN
         IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'lock_create_balance_status failed'
             ,p_level => C_LEVEL_ERROR
         );
         END IF;
         ROLLBACK TO SAVEPOINT_INCREMENTAL;
         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg      => 'END ' || l_log_module
                ,p_level    => C_LEVEL_PROCEDURE);
         END IF;
         RETURN FALSE;
      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         ( p_module => l_log_module
          ,p_msg    => 'lookup of balance statuses'
          ,p_level  => C_LEVEL_STATEMENT
         );
      END IF;

      UPDATE xla_bal_ctrl_lines_gt xbct
         SET (
               balance_status_code
              ,balance_status_eff_per_num
             )
             =
             (
               SELECT xbs.balance_status_code
                     ,xbs.effective_period_num
                 FROM xla_balance_statuses xbs
                WHERE xbs.application_id      =  xbct.application_id
                  AND xbs.ledger_id           =  xbct.ledger_id
                  AND xbs.code_combination_id =  xbct.code_combination_id
                  AND xbs.balance_source_code =  'C'
             );
      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => l_row_count ||
                      ' updated in xla_bal_ctrl_lines_gt'
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      UPDATE  /*+ PARALLEL (xbat) */ xla_bal_anacri_lines_gt xbat
         SET (
               balance_status_code
              ,balance_status_eff_per_num
              ,account_type
             )
             =
             (
               SELECT xbs.balance_status_code
                     ,xbs.effective_period_num
                     ,xbs.account_type
                 FROM xla_balance_statuses xbs
                WHERE xbs.application_id      =  xbat.application_id
                  AND xbs.ledger_id           =  xbat.ledger_id
                  AND xbs.code_combination_id =  xbat.code_combination_id
                  AND xbs.balance_source_code =  'A'
             );

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => l_row_count ||
                      ' updated in xla_bal_anacri_lines_gt'
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      l_result := TRUE;

      IF p_update_mode <> 'M'
      THEN
         --Remove the lines for which the balance status is in maintenance mode.
         DELETE
           FROM xla_bal_ctrl_lines_gt xbct
          WHERE xbct.balance_status_code = 'M';

         l_row_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            ( p_module => l_log_module
             ,p_msg   => l_row_count ||
                         ' lines deleted from xla_bal_ctrl_lines_gt'
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;

         IF l_row_count > 0
         THEN
            l_result := FALSE;
         END IF;

         DELETE
           FROM xla_bal_anacri_lines_gt xbat
          WHERE xbat.balance_status_code = 'M';
         l_row_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            (p_module => l_log_module
             ,p_msg   => l_row_count ||
                            ' lines deleted from xla_bal_anacri_lines_gt'
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;

         IF l_row_count > 0
         THEN
            l_result := FALSE;
         END IF;

      END IF;

      IF p_update_mode = 'A'
      OR p_update_mode = 'M'
      THEN
         l_operation_code := 'A';
      ELSIF p_update_mode = 'D'
      THEN
         l_operation_code := 'R';
      ELSIF p_update_mode = 'F'
      THEN
         l_operation_code := 'F';
      ELSE
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'Unsupported p_update_mode value: ' || p_update_mode
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:' ||
'Unsupported p_update_mode value: ' || p_update_mode);
      END IF;

      --Control balances
      IF NVL(p_balance_source_code, 'C') = 'C'
      THEN
         l_temp_rows_inserted := load_ctrl_secondary_temp_tabs
                 ( p_operation_code => l_operation_code
                 );
         IF l_temp_rows_inserted > 0
         THEN
            FOR i IN
            (
             SELECT DISTINCT
                    bclt.application_id
                   ,bclt.ledger_id
                   ,bclt.effective_period_num
               FROM xla_bal_ctrl_lines_gt bclt
             ORDER BY bclt.application_id
                     ,bclt.ledger_id
                     ,bclt.effective_period_num

            )
            LOOP

               IF p_update_mode = 'M'
               THEN
                  cache_ledger_period_statuses
                      ( p_ledger_id            => i.ledger_id
                       ,p_first_eff_per_num    => i.effective_period_num
                       ,p_load_single_period   => TRUE
                      );
               ELSE
                  cache_ledger_period_statuses
                      ( p_ledger_id            => i.ledger_id
                       ,p_first_eff_per_num    => i.effective_period_num
                       ,p_load_single_period   => FALSE
                      );
               END IF;

               --If p_commit_flag is 'N' we assume the data are limited
               --therefore we perform a localized moving forward of the balances
               IF  p_update_mode <> 'M'
               AND p_commit_flag =  'N'
               THEN
                  --control balances
                  FOR m IN
                  (
                     SELECT DISTINCT
                            bcct.code_combination_id
                           ,bcct.party_type_code
                           ,bcct.party_id
                       FROM xla_bal_ctrl_ctrbs_gt  bcct
                      WHERE bcct.application_id             = i.application_id
                        AND bcct.ledger_id                  = i.ledger_id
                        AND bcct.effective_period_num       = i.effective_period_num
                        AND bcct.balance_status_eff_per_num <  bcct.effective_period_num
                  )
                  LOOP
                     IF NOT move_identified_bals_forward
                    ( p_application_id             => i.application_id
                     ,p_ledger_id                  => i.ledger_id
                     ,p_code_combination_id        => m.code_combination_id
                     ,p_dest_effective_period_num  => i.effective_period_num
                     ,p_balance_source_code        => 'C'
                     ,p_party_type_code            => m.party_type_code
                     ,p_party_id                   => m.party_id
                     ,p_analytical_criterion_code  => NULL
                     ,p_anacri_type_code           => NULL
                     ,p_amb_context_code           => NULL
                     ,p_ac1                        => NULL
                     ,p_ac2                        => NULL
                     ,p_ac3                        => NULL
                     ,p_ac4                        => NULL
                     ,p_ac5                        => NULL
                    )
                     THEN
                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           trace
                             (p_module => l_log_module
                             ,p_msg   => 'move_identified_bals_forward failed'
                              ,p_level => C_LEVEL_STATEMENT
                             );
                        END IF;
                        ROLLBACK TO SAVEPOINT_INCREMENTAL;
                        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
                           trace
                           (p_module => l_log_module
                           ,p_msg      => 'END ' || l_log_module
                            ,p_level    => C_LEVEL_PROCEDURE);
                        END IF;
                        RETURN FALSE;
                     END IF;
                  END LOOP;
               END IF;

               l_result :=  l_result  AND
                  calculate_control_balances
                  ( p_application_id           => i.application_id
                   ,p_ledger_id                => i.ledger_id
                   ,p_effective_period_num     => i.effective_period_num
                   ,p_operation_code           => l_operation_code
                  );
            END LOOP;

            IF p_update_mode <> 'F'
            THEN
               g_date := SYSDATE;

              UPDATE xla_ae_lines ael
                  SET ael.control_balance_flag    = l_balance_flag_post_update
                     ,ael.last_update_date        = g_date
                     ,ael.last_updated_by         = g_user_id
                     ,ael.last_update_login       = g_login_id
                     ,ael.program_update_date     = g_date
                     ,ael.program_application_id  = g_prog_appl_id
                     ,ael.program_id              = g_prog_id
                     ,ael.request_id              = g_req_id
              WHERE  ael.ROWID IN
                 (SELECT /*+ leading(XBCT)  */  xbct.line_rowid
                  FROM   xla_bal_ctrl_lines_gt xbct
                  WHERE  EXISTS
                        (SELECT /*+ no_unnest */ 1
                         FROM   gl_period_statuses gps
                         WHERE gps.application_id = 101
                           AND gps.period_name    = xbct.period_name
                           AND gps.ledger_id      = xbct.ledger_id
                           AND gps.closing_status IN ('O','C','P'))
                       );

               l_row_count := SQL%ROWCOUNT;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                     (p_module => l_log_module
                     ,p_msg   => l_row_count
                                  || ' control flags marked as : '
                                  || l_balance_flag_post_update
                      ,p_level => C_LEVEL_STATEMENT
                     );
               END IF;

            END IF; --p_update_mode

         END IF; --l_temp_rows_inserted

      END IF; --p_balance_source_code

      IF NVL(p_balance_source_code, 'A') = 'A'
      THEN
         l_temp_rows_inserted := load_alyt_secondary_temp_tabs
                ( p_operation_code             => l_operation_code
                );

         IF l_temp_rows_inserted > 0
         THEN
            FOR i IN
            (
             SELECT DISTINCT
                    bclt.application_id
                   ,bclt.ledger_id
                   ,bclt.effective_period_num
               FROM xla_bal_anacri_lines_gt bclt
            )
            LOOP

               IF p_update_mode = 'M'
               THEN
                  cache_ledger_period_statuses
                      ( p_ledger_id            => i.ledger_id
                       ,p_first_eff_per_num    => i.effective_period_num
                       ,p_load_single_period   => TRUE
                      );
               ELSE
                  cache_ledger_period_statuses
                      ( p_ledger_id            => i.ledger_id
                       ,p_first_eff_per_num    => i.effective_period_num
                       ,p_load_single_period   => FALSE
                      );
               END IF;
               --If p_commit_flag is 'N' we assume the data are limited
               --therefore we perform a localized moving forward of the balances
               IF  p_update_mode <> 'M'
               AND p_commit_flag =  'N'
               THEN
                  --analytical balances
                  FOR m IN
                  (
                     SELECT DISTINCT
                            bact.code_combination_id
                           ,bact.analytical_criterion_code
                           ,bact.analytical_criterion_type_code
                           ,bact.amb_context_code
                           ,bact.ac1
                           ,bact.ac2
                           ,bact.ac3
                           ,bact.ac4
                           ,bact.ac5
                       FROM xla_bal_ac_ctrbs_gt  bact
                      WHERE bact.application_id             = i.application_id
                        AND bact.ledger_id                  = i.ledger_id
                        AND bact.effective_period_num       = i.effective_period_num
                        AND bact.balance_status_eff_per_num <  bact.effective_period_num
                  )
                  LOOP
                     IF NOT move_identified_bals_forward
                    ( p_application_id             => i.application_id
                     ,p_ledger_id                  => i.ledger_id
                     ,p_code_combination_id        => m.code_combination_id
                     ,p_dest_effective_period_num  => i.effective_period_num
                     ,p_balance_source_code        => 'A'
                     ,p_party_type_code            => NULL
                     ,p_party_id                   => NULL
                     ,p_analytical_criterion_code  => m.analytical_criterion_code
                     ,p_anacri_type_code           => m.analytical_criterion_type_code
                     ,p_amb_context_code           => m.amb_context_code
                     ,p_ac1                        => m.ac1
                     ,p_ac2                        => m.ac2
                     ,p_ac3                        => m.ac3
                     ,p_ac4                        => m.ac4
                     ,p_ac5                        => m.ac5
                    )
                     THEN
                        IF (C_LEVEL_ERROR >= g_log_level) THEN
                           trace
                              (p_module => l_log_module
                              ,p_msg   => 'move_identified_bals_forward failed'
                               ,p_level => C_LEVEL_ERROR
                              );
                        END IF;
                        ROLLBACK TO SAVEPOINT_INCREMENTAL;
                        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
                           trace
                           (p_module => l_log_module
                           ,p_msg      => 'END ' || l_log_module
                            ,p_level    => C_LEVEL_PROCEDURE);
                        END IF;
                        RETURN FALSE;
                     END IF;

                  END LOOP;
               END IF;

               l_result :=  l_result  AND
                  calculate_analytical_balances
                  ( p_application_id           => i.application_id
                   ,p_ledger_id                => i.ledger_id
                   ,p_effective_period_num     => i.effective_period_num
                   ,p_operation_code           => l_operation_code
                  );

            END LOOP;

            IF p_update_mode <> 'F'
            THEN
               g_date := SYSDATE;

               --  parallel and remove xla_ae_headers join
               -- perf changes.

      UPDATE /*+ PARALLEL (AEL) */ xla_ae_lines ael
      SET ael.analytical_balance_flag = l_balance_flag_post_update
         ,ael.last_update_date        = g_date
         ,ael.last_updated_by         = g_user_id
         ,ael.last_update_login       = g_login_id
         ,ael.program_update_date     = g_date
         ,ael.program_application_id  = g_prog_appl_id
         ,ael.program_id              = g_prog_id
         ,ael.request_id              = g_req_id
    WHERE (ael.ROWID) IN
          (SELECT /*+ leading(XBCT)  */  xbct.line_rowid
                  FROM   xla_bal_anacri_lines_gt xbct)
          and ael.application_id=p_application_id;--Bug 7493686


               l_row_count := SQL%ROWCOUNT;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                     (p_module => l_log_module
                     ,p_msg   => l_row_count || ' analytical flags as : '
                                  || l_balance_flag_post_update
                      ,p_level => C_LEVEL_STATEMENT
                     );
               END IF;
            END IF; --p_update_mode

         END IF; --l_temp_rows_inserted

      END IF; --p_balance_source_code

      IF p_commit_flag = 'Y'
      THEN
         COMMIT;
      ELSIF p_commit_flag = 'N'
      THEN
         NULL;
      ELSE
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'Unkown p_commit_flag value: ' || p_commit_flag
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:' ||
'Unkown p_commit_flag value: ' || p_commit_flag);
      END IF;

      IF l_exit_after_calculation
      THEN
         EXIT;
      END IF;
   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_result;

EXCEPTION
WHEN le_resource_busy
THEN
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'cannot lock accounting entry records'
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
        (p_module => l_log_module
        ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   ROLLBACK TO SAVEPOINT_INCREMENTAL;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.calculate_balances');

END calculate_balances;

FUNCTION event_set_update
  (
    p_update_mode                  IN VARCHAR2
  ) RETURN BOOLEAN
IS
l_return_value                 BOOLEAN;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.event_set_update';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --parameter validation
   IF p_update_mode IS NULL
   OR p_update_mode NOT IN ('A', 'D')
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'Unsupported value for p_update_mode: ' || p_update_mode
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:' ||
'Unsupported value for p_update_mode: ' || p_update_mode);
   END IF;

   l_return_value := calculate_balances
            ( p_application_id             => NULL
             ,p_ledger_id                  => NULL
             ,p_entity_id                  => NULL
             ,p_event_id                   => NULL
             ,p_request_id                 => NULL
             ,p_accounting_batch_id        => NULL
             ,p_ae_header_id               => NULL
             ,p_ae_line_num                => NULL
             ,p_code_combination_id        => NULL
             ,p_period_name                => NULL
             ,p_update_mode                => p_update_mode
             ,p_balance_source_code        => NULL
             ,p_called_by_flag             => NULL
             ,p_commit_flag                => 'N'
            );

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.event_set_update');
END event_set_update;



FUNCTION single_update
  (
    p_application_id          IN INTEGER
   ,p_ae_header_id            IN INTEGER
   ,p_ae_line_num             IN INTEGER
   ,p_update_mode             IN VARCHAR2
  ) RETURN BOOLEAN
IS
l_return_value                 BOOLEAN      ;

l_log_module                 VARCHAR2 (2000);

CURSOR lock_bal_control (p_application_id NUMBER)
IS
   SELECT     application_id
            , ledger_id
         FROM xla_bal_concurrency_control
        WHERE application_id = p_application_id
    FOR UPDATE NOWAIT;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.single_update';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --parameter validation
   IF p_application_id IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'p_application_id cannot be NULL'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:' ||
'p_application_id cannot be NULL');
   END IF;

   IF p_ae_header_id IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'p_ae_header_id cannot be NULL'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:' ||
'p_ae_header_id cannot be NULL');
   END IF;

   IF p_update_mode IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'p_update_mode cannot be NULL'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:' ||
'p_update_mode cannot be NULL');
   ELSIF p_update_mode NOT IN ('A', 'D', 'F')
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'Unsupported value for p_update_mode: ' || p_update_mode
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:' ||
'Unsupported value for p_update_mode: ' || p_update_mode);
   END IF;

   IF NOT xla_balances_calc_pkg.lock_bal_concurrency_control ( p_application_id      => p_application_id
                                       , p_ledger_id           => NULL
                                       , p_entity_id           => NULL
                                       , p_event_id            => NULL
                                       , p_ae_header_id        => p_ae_header_id
                                       , p_ae_line_num         => p_ae_line_num
                                       , p_request_id          => g_req_id
                                       , p_accounting_batch_id => NULL
                                       , p_execution_mode      => 'O'
                                       , p_concurrency_class   => 'BALANCES_CALCULATION'
                                       )
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name      => 'XLA'
        , p_msg_name          => 'XLA_COMMON_ERROR'
        , p_token_1           => 'LOCATION'
        , p_value_1           => 'xla_balances_pkg.MASSIVE_UPDATE'
        , p_token_2           => 'ERROR'
        , p_value_2           =>    'EXCEPTION:'
                                 || 'XLA_BAL_CONCURRENCY_CONTROL COULD NOT BE LOCKED. RESOURCE BUSY'
         );
   END IF;
   OPEN lock_bal_control (p_application_id      => p_application_id);

   CLOSE lock_bal_control;

   l_return_value := calculate_balances
            ( p_application_id             => p_application_id
             ,p_ledger_id                  => NULL
             ,p_entity_id                  => NULL
             ,p_event_id                   => NULL
             ,p_request_id                 => NULL
             ,p_accounting_batch_id        => NULL
             ,p_ae_header_id               => p_ae_header_id
             ,p_ae_line_num                => p_ae_line_num
             ,p_code_combination_id        => NULL
             ,p_period_name                => NULL
             ,p_update_mode                => p_update_mode
             ,p_balance_source_code        => NULL
             ,p_called_by_flag             => NULL
             ,p_commit_flag                => 'N'
            );

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   DELETE xla_bal_concurrency_control
   WHERE application_id=p_application_id
   AND request_id = -1
   AND execution_mode = 'O'
   AND concurrency_class = 'BALANCES_CALCULATION';

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.single_update');
END single_update;


PROCEDURE massive_update_srs
                           ( p_errbuf               OUT NOCOPY VARCHAR2
                            ,p_retcode              OUT NOCOPY NUMBER
                            ,p_application_id       IN         NUMBER
                            ,p_dummy                IN         VARCHAR2
                            ,p_ledger_id            IN         NUMBER
                            ,p_accounting_batch_id  IN         NUMBER
                            ,p_update_mode          IN         VARCHAR2)
IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|  Just the SRS wrapper for massive_update in batch mode                |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|  Call massive_update             and assign its return code to        |
|  p_retcode                                                            |
|  RETURN p_retcode (0=success, 1=warning, 2=error)                     |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
|                                                                       |
| 1) Need to review the value assigned to p_errbuf                      |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/

l_commit_flag     VARCHAR2(1);

l_log_module                 VARCHAR2 (2000);

CURSOR lock_bal_control (p_application_id NUMBER)
IS
SELECT     application_id
         , ledger_id
FROM xla_bal_concurrency_control
WHERE application_id = p_application_id
FOR UPDATE WAIT 60;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.massive_update_srs';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   fnd_file.put_line(fnd_file.log,'p_application_id: ' || p_application_id);
   fnd_file.put_line(fnd_file.log,'p_ledger_id: ' || p_ledger_id);
   fnd_file.put_line(fnd_file.log,'p_accounting_batch_id: ' || p_accounting_batch_id);
   fnd_file.put_line(fnd_file.log,'p_update_mode: ' || p_update_mode);

   IF p_update_mode = 'F'
   THEN
      l_commit_flag := 'N';
   ELSE
      l_commit_flag := 'Y';
   END IF;

   IF NOT xla_balances_calc_pkg.lock_bal_concurrency_control (  p_application_id      => p_application_id
							 , p_ledger_id           => p_ledger_id
							 , p_entity_id           => NULL
							 , p_event_id            => NULL
							 , p_ae_header_id        => NULL
							 , p_ae_line_num         => NULL
							 , p_request_id          => g_req_id
							 , p_accounting_batch_id => p_accounting_batch_id
							 , p_execution_mode      => 'C'
							 , p_concurrency_class   => 'BALANCES_CALCULATION'
							 )
   THEN
         xla_exceptions_pkg.raise_message
            (p_appli_s_name      => 'XLA'
           , p_msg_name          => 'XLA_COMMON_ERROR'
           , p_token_1           => 'LOCATION'
           , p_value_1           => 'xla_balances_pkg.massive_update_srs'
           , p_token_2           => 'ERROR'
           , p_value_2           =>    'EXCEPTION:'
                                    || 'XLA_BAL_CONCURRENCY_CONTROL COULD NOT BE LOCKED. RESOURCE BUSY'
            );
   END IF;

   OPEN lock_bal_control (p_application_id      => p_application_id );

   CLOSE lock_bal_control;

   IF calculate_balances
            ( p_application_id             => p_application_id
             ,p_ledger_id                  => p_ledger_id
             ,p_entity_id                  => NULL
             ,p_event_id                   => NULL
             ,p_request_id                 => NULL
             ,p_accounting_batch_id        => p_accounting_batch_id
             ,p_ae_header_id               => NULL
             ,p_ae_line_num                => NULL
             ,p_code_combination_id        => NULL
             ,p_period_name                => NULL
             ,p_update_mode                => p_update_mode
             ,p_balance_source_code        => NULL
             ,p_called_by_flag             => NULL
             ,p_commit_flag                => l_commit_flag
            )
   THEN
      p_retcode := 0;

       DELETE xla_bal_concurrency_control
       WHERE application_id=p_application_id
       AND request_id = g_req_id
       AND execution_mode = 'C'
       AND concurrency_class = 'BALANCES_CALCULATION';
   ELSE
      p_retcode := 1;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   p_retcode := 2;
   p_errbuf := sqlerrm;
WHEN OTHERS                                   THEN
   p_retcode := 2;
   p_errbuf := sqlerrm;
END massive_update_srs;

FUNCTION massive_update_for_events(p_application_id IN INTEGER)
RETURN boolean
IS
   l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.massive_update_for_events';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --parameter validation
   --p_application_id must have a value, always
   IF p_application_id IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'p_application_id cannot be NULL'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.pre_accounting'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION:' ||
'p_application_id cannot be NULL'
);
   END IF;

   RETURN calculate_balances
            ( p_application_id             => p_application_id
             ,p_ledger_id                  => NULL
             ,p_entity_id                  => NULL
             ,p_event_id                   => NULL
             ,p_request_id                 => NULL
             ,p_accounting_batch_id        => NULL
             ,p_ae_header_id               => NULL
             ,p_ae_line_num                => NULL
             ,p_code_combination_id        => NULL
             ,p_period_name                => NULL
             ,p_update_mode                => 'D'
             ,p_balance_source_code        => NULL
             ,p_called_by_flag             => 'E'
             ,p_commit_flag                => 'N'
            );

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.massive_update_for_events');
END massive_update_for_events;

FUNCTION massive_update
  (
    p_application_id          IN INTEGER
   ,p_ledger_id               IN INTEGER
   ,p_entity_id               IN INTEGER
   ,p_event_id                IN INTEGER
   ,p_request_id              IN INTEGER
   ,p_accounting_batch_id     IN INTEGER
   ,p_update_mode             IN VARCHAR2
   ,p_execution_mode          IN VARCHAR2
  ) RETURN BOOLEAN
IS
   l_req_id                 NUMBER;
   l_result                 BOOLEAN;

   l_return_value           BOOLEAN;

   l_log_module                 VARCHAR2 (2000);

   CURSOR lock_bal_control (p_application_id NUMBER)
   IS
   SELECT     application_id
            , ledger_id
   FROM xla_bal_concurrency_control
   WHERE application_id = p_application_id
   FOR UPDATE NOWAIT;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.massive_update';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --parameter validation
   --p_application_id must have a value, always
   IF p_application_id IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'p_application_id cannot be NULL'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;

      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: p_application_id cannot be NULL');

   END IF;

   --if p_entity_id has a value, p_ledger_id, p_event_id,
   --p_request_id and p_accounting_batch_id must be NULL
   IF p_entity_id IS NOT NULL
   THEN
      IF p_ledger_id              IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'IF p_entity_id is not NULL, p_ledger_id must be NULL  '
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: IF p_entity_id is not NULL, p_ledger_id must be NULL');

      ELSIF p_event_id            IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'IF p_entity_id is not NULL, p_event_id must be NULL  '
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: IF p_entity_id is not NULL, p_event_id must be NULL');
      ELSIF p_request_id IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'IF p_entity_id is not NULL, p_request_id must be NULL  '
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: IF p_entity_id is not NULL, p_request_id must be NULL');

      ELSIF p_accounting_batch_id IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'IF p_entity_id is not NULL, p_accounting_batch_id must be NULL  '
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: IF p_entity_id is not NULL, p_accounting_batch_id must be NULL');

      END IF;
   END IF;

   --if p_request_id has a value, p_ledger_id, p_entity_id,
   --p_event_id and p_accounting_batch_id must be NULL
   IF p_request_id IS NOT NULL
   THEN
      IF p_ledger_id              IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'IF p_request_id is not NULL, p_ledger_id must be NULL  '
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: IF p_request_id is not NULL, p_ledger_id must be NULL');

      ELSIF p_entity_id IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'IF p_request_id is not NULL, p_entity_id must be NULL  '
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: IF p_request_id is not NULL, p_entity_id must be NULL');

      ELSIF p_event_id            IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'IF p_request_id is not NULL, p_event_id must be NULL  '
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: IF p_request_id is not NULL, p_event_id must be NULL');

      ELSIF p_accounting_batch_id IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'IF p_request_id is not NULL, p_accounting_batch_id must be NULL  '
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: IF p_request_id is not NULL, p_accounting_batch_id must be NULL');
      END IF;
   END IF;

   IF p_update_mode IS NULL
   OR p_update_mode NOT IN ('A', 'D', 'F')
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'Invalid p_update_mode parameter: '|| p_update_mode
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: Invalid p_update_mode parameter: '|| p_update_mode);
   END IF;

   IF p_execution_mode IS NULL
   OR p_execution_mode NOT IN ('O', 'C')
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'Invalid p_execution_mode parameter: '|| p_execution_mode
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: Invalid p_execution_mode parameter: '|| p_execution_mode);

   END IF;

   -- If p_execution_mode is Concurrent,
   -- p_event_id, p_request_id must be NULL
   IF p_execution_mode = 'C'
   THEN
      IF p_event_id   IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'When p_execution_mode is C, p_event_id, must be NULL.'
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: When p_execution_mode is C, p_event_id, must be NULL');

      ELSIF p_request_id   IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'When p_execution_mode is C, p_request_id, must be NULL.'
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: When p_execution_mode is C, p_request_id, must be NULL');

      ELSIF p_entity_id   IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'When p_execution_mode is C, p_entity_id, must be NULL.'
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: When p_execution_mode is C, p_entity_id, must be NULL');

      END IF;

      --batch execution
      l_result := fnd_request.set_mode(TRUE);
      l_req_id := fnd_request.submit_request
                ( application => 'XLA'
                 ,program     => 'XLABABUP'
                 ,description => NULL
                 ,argument1   => TO_CHAR(p_application_id)
                 ,argument2   => NULL --dummy parameter in conc prog. definition
                 ,argument3   => TO_CHAR(p_ledger_id)
                 ,argument4   => TO_CHAR(p_accounting_batch_id)
                 ,argument5   => p_update_mode
                );

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => 'Request ID: ' || l_req_id
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      IF l_req_id = 0 THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            (p_module => l_log_module
             ,p_msg   => 'Unable to submit request'
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;
         l_return_value := FALSE;
      ELSE
         l_return_value := TRUE;
      END IF;

   ELSIF p_execution_mode = 'O'
   THEN

      IF NOT xla_balances_calc_pkg.lock_bal_concurrency_control (   p_application_id      => p_application_id
							     , p_ledger_id           => p_ledger_id
							     , p_entity_id           => p_entity_id
							     , p_event_id            => p_event_id
							     , p_ae_header_id        => NULL
							     , p_ae_line_num         => NULL
							     , p_request_id          => g_req_id
							     , p_accounting_batch_id => p_accounting_batch_id
							     , p_execution_mode      => 'O'
							     , p_concurrency_class   => 'BALANCES_CALCULATION'
							   )
      THEN
           xla_exceptions_pkg.raise_message
           (p_appli_s_name      => 'XLA'
           , p_msg_name          => 'XLA_COMMON_ERROR'
           , p_token_1           => 'LOCATION'
           , p_value_1           => 'xla_balances_pkg.MASSIVE_UPDATE'
           , p_token_2           => 'ERROR'
           , p_value_2           =>    'EXCEPTION:'
                                  || 'XLA_BAL_CONCURRENCY_CONTROL COULD NOT BE LOCKED. RESOURCE BUSY'
           );
      END IF;

      OPEN lock_bal_control (p_application_id      => p_application_id );

      CLOSE lock_bal_control;

      IF calculate_balances
            ( p_application_id             => p_application_id
             ,p_ledger_id                  => p_ledger_id
             ,p_entity_id                  => p_entity_id
             ,p_event_id                   => p_event_id
             ,p_request_id                 => p_request_id
             ,p_accounting_batch_id        => p_accounting_batch_id
             ,p_ae_header_id               => NULL
             ,p_ae_line_num                => NULL
             ,p_code_combination_id        => NULL
             ,p_period_name                => NULL
             ,p_update_mode                => p_update_mode
             ,p_balance_source_code        => NULL
             ,p_called_by_flag             => NULL
             ,p_commit_flag                => 'N'
            )
	THEN
	   DELETE XLA_BAL_CONCURRENCY_CONTROL
	   WHERE application_id = p_application_id
	   AND request_id       = -1
	   AND execution_mode   = 'O'
	   AND concurrency_class = 'BALANCES_CALCULATION';

	   RETURN TRUE;
      END IF;

   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   => 'EXCEPTION:' ||
'Invalid value for parameter p_execution_mode: ' || p_execution_mode
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
         xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_balances_pkg.massive_update'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'EXCEPTION: Invalid value for parameter p_execution_mode: ' || p_execution_mode);

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.massive_update');
END massive_update;


FUNCTION recreation_common
RETURN BOOLEAN
IS
l_starting_eff_period_num         INTEGER;
l_chart_of_accounts_id            INTEGER;
l_account_segment_column          VARCHAR2(  30);
l_balance_source_code             VARCHAR2(   1);
l_count_unavailable               INTEGER;
l_current_ledger_id               INTEGER;
l_current_effective_period_num    INTEGER;
l_massive_recreation              BOOLEAN;
l_user_id                         INTEGER;
l_login_id                        INTEGER;
l_date                            DATE;
l_prog_appl_id                    INTEGER;
l_prog_id                         INTEGER;
l_req_id                          INTEGER;
l_result                          BOOLEAN;
l_return_value                    BOOLEAN;
l_num_of_records_updated          INTEGER;
l_warning_count                   INTEGER;

l_row_count                 NUMBER;

l_log_module                 VARCHAR2 (2000);

BEGIN

   l_user_id                         := xla_environment_pkg.g_usr_id;
   l_login_id                        := xla_environment_pkg.g_login_id;
   l_date                            := SYSDATE;
   l_prog_appl_id                    := xla_environment_pkg.g_prog_appl_id;
   l_prog_id                         := xla_environment_pkg.g_prog_id;
   l_req_id                          := xla_environment_pkg.g_req_id;
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.recreation_common';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --Phase 1: Deletion of balances and update of balance flags on ae_lines

   --delete control balances
      LOOP
         DELETE
           FROM xla_control_balances xcbext
          WHERE xcbext.ROWID IN
                 ( SELECT xcb.ROWID
                     FROM xla_balance_statuses      xbs
                         ,xla_control_balances      xcb
                         ,gl_period_statuses        gps
                    WHERE xbs.balance_source_code  = 'C'
                      AND xbs.balance_status_code  = 'R'
                      AND xbs.request_id           = NVL(l_req_id, -1)
                      AND xcb.initial_balance_flag = 'N'
                      AND xcb.application_id       = xbs.application_id
                      AND xcb.ledger_id            = xbs.ledger_id
                      AND xcb.code_combination_id  = xbs.code_combination_id
                      AND (   (     xbs.recreate_party_type_code IS NULL
                              )
                           OR (     xbs.recreate_party_type_code IS NOT NULL
                                AND xcb.party_type_code          =  xbs.recreate_party_type_code
                              )
                          )
                      AND (   (     xbs.recreate_party_type_code IS NULL
                              )
                           OR (     xbs.recreate_party_type_code IS NOT NULL
                                AND xcb.party_id                 = xbs.recreate_party_id
                              )
                          )
                      AND (   (     xbs.recreate_party_site_id   IS NULL
                              )
                           OR (     xbs.recreate_party_site_id   IS NOT NULL
                                AND xcb.party_site_id            = xbs.recreate_party_site_id
                              )
                          )
                      AND gps.ledger_id            =  xcb.ledger_id
                      AND gps.application_id       =  101
                      AND gps.period_name          =  xcb.period_name
                      AND gps.effective_period_num >= xbs.recreate_effective_period_num
                 )
            AND ROWNUM  <= C_BATCH_COMMIT_SIZE;

         l_row_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            (p_module => l_log_module
             ,p_msg   => l_row_count || ' xla_control_balances deleted'
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;

         IF l_row_count < C_BATCH_COMMIT_SIZE
         THEN
            COMMIT;
            EXIT;
         ELSE
            COMMIT;
         END IF;
      END LOOP;

   --delete xla_ac_balances
      LOOP
         DELETE
           FROM xla_ac_balances xabext
          WHERE xabext.ROWID IN
                 ( SELECT xab.ROWID
                     FROM xla_balance_statuses      xbs
                         ,xla_ac_balances   xab
                         ,gl_period_statuses        gps
                    WHERE xbs.balance_source_code  = 'A'
                      AND xbs.balance_status_code  = 'R'
                      AND xbs.request_id           = NVL(l_req_id, -1)
                      AND xab.initial_balance_flag =  'N'
                      AND xab.application_id       =  xbs.application_id
                      AND xab.ledger_id            =  xbs.ledger_id
                      AND xab.code_combination_id  =  xbs.code_combination_id
                      AND gps.ledger_id            =  xab.ledger_id
                      AND gps.period_name          =  xab.period_name
                      AND gps.application_id       =  101
                      AND gps.effective_period_num >= xbs.recreate_effective_period_num
                 )
            AND ROWNUM  <= C_BATCH_COMMIT_SIZE;

         l_row_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            ( p_module => l_log_module
             ,p_msg   => l_row_count || ' xla_ac_balances deleted'
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;

         IF l_row_count < C_BATCH_COMMIT_SIZE
         THEN
            COMMIT;
            EXIT;
         ELSE
            COMMIT;
         END IF;
      END LOOP;


   --update xla_ae_lines
      LOOP
         l_num_of_records_updated := 0;
         UPDATE xla_ae_lines ael
            SET ael.control_balance_flag =
                             DECODE( ael.control_balance_flag
                                    ,'Y'
                                    ,'P'
                                    ,ael.control_balance_flag
                                   )
          WHERE ael.ROWID IN
                  (SELECT xal.ROWID
                     FROM xla_balance_statuses      xbs
                         ,xla_ae_headers            xah
                         ,xla_ae_lines              xal
                         ,gl_period_statuses        gps
                    WHERE xbs.balance_status_code        = 'R'
                      AND xbs.balance_source_code        = 'C'
                      AND xbs.request_id                 = NVL(l_req_id, -1)
                      AND xah.ledger_id                  = xbs.ledger_id
                      AND xah.application_id             = xbs.application_id
                      AND xal.ae_header_id               = xah.ae_header_id
                      AND xal.application_id             = xah.application_id
                      AND xal.code_combination_id        = xbs.code_combination_id
                      AND (   (     xbs.recreate_party_type_code IS NULL
                              )
                           OR (     xbs.recreate_party_type_code IS NOT NULL
                                AND xal.party_type_code          =  xbs.recreate_party_type_code
                              )
                          )
                      AND (   (     xbs.recreate_party_id        IS NULL
                              )
                           OR (     xbs.recreate_party_id        IS NOT NULL
                                AND (   xal.party_id                 = xbs.recreate_party_id
                                    )
                              )
                          )
                      AND (   (     xbs.recreate_party_site_id   IS NULL
                              )
                           OR (     xbs.recreate_party_site_id   IS NOT NULL
                                AND (   xal.party_site_id            = xbs.recreate_party_site_id
                                    )
                              )
                          )
                      AND xal.control_balance_flag       <> 'P'
                      AND gps.ledger_id                  =  xah.ledger_id
                      AND gps.period_name                =  xah.period_name
                      AND gps.application_id             =  101
                      AND gps.effective_period_num       >= xbs.recreate_effective_period_num
                   )
            AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

            l_num_of_records_updated := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            ( p_module => l_log_module
             ,p_msg   => l_num_of_records_updated  || ' xla_ae_lines (ctrl bal) updated to P'
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;

         UPDATE xla_ae_lines ael
            SET ael.analytical_balance_flag =
                             DECODE( ael.analytical_balance_flag
                                    ,'Y'
                                    ,'P'
                                    ,ael.analytical_balance_flag
                                   )
          WHERE ael.ROWID IN
                  (SELECT xal.ROWID
                     FROM xla_balance_statuses      xbs
                         ,xla_ae_headers            xah
                         ,xla_ae_lines              xal
                         ,gl_period_statuses        gps
                    WHERE xbs.balance_status_code        =  'R'
                      AND xbs.balance_source_code        =  'A'
                      AND xbs.request_id                 =  NVL(l_req_id, -1)
                      AND xah.ledger_id                  =  xbs.ledger_id
                      AND xah.application_id             =  xbs.application_id
                      AND xal.ae_header_id               =  xah.ae_header_id
                      AND xal.application_id             =  xah.application_id
                      AND xal.code_combination_id        =  xbs.code_combination_id
                      AND xal.analytical_balance_flag    <> 'P'
                      AND gps.ledger_id                  =  xah.ledger_id
                      AND gps.period_name                =  xah.period_name
                      AND gps.application_id             =  101
                      AND gps.effective_period_num       >= xbs.recreate_effective_period_num
                   )
            AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

         l_num_of_records_updated := l_num_of_records_updated  + SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            ( p_module => l_log_module
             ,p_msg   => l_num_of_records_updated  || ' xla_ae_lines (ac bal) updated to P'
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;

         IF l_num_of_records_updated = 0
         THEN
            COMMIT;
            EXIT;
         ELSE
            COMMIT;
         END IF;
      END LOOP;


--Phase 2: Balance calculation
      LOOP
         l_date := SYSDATE;
         UPDATE xla_balance_statuses xbs
            SET xbs.balance_status_code  = 'B'
               ,xbs.effective_period_num = (SELECT LEAST( NVL( xbs.recreate_effective_period_num
                                                              ,MAX(gps.effective_period_num)
                                                             )
                                                         ,xbs.effective_period_num
                                                        )
                                              FROM gl_period_statuses gps
                                             WHERE gps.ledger_id      = xbs.ledger_id
                                               AND gps.application_id = 101
                                               AND gps.closing_status IN ('O', 'C', 'P')
                                               AND gps.adjustment_period_flag = 'N'
                                               AND gps.effective_period_num < xbs.recreate_effective_period_num
                                           )
               ,last_update_date         = l_date
               ,last_updated_by          = l_user_id
               ,last_update_login        = l_login_id
               ,program_update_date      = l_date
               ,program_application_id   = l_prog_appl_id
               ,program_id               = l_prog_id
               ,request_id               = NVL(l_req_id, -1)
          WHERE xbs.balance_status_code  =  'R'
            AND xbs.request_id           =  NVL(l_req_id, -1)
            AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

         l_row_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            ( p_module => l_log_module
             ,p_msg   => l_row_count || ' xla_balance_statuses updated to B'
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;

         IF l_row_count < C_BATCH_COMMIT_SIZE
         THEN
            COMMIT;
            EXIT;
         ELSE
            COMMIT;
         END IF;
      END LOOP;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_module => l_log_module
             , p_msg   => 'Starting Phase 2: balance calculation'
             ,p_level => C_LEVEL_STATEMENT
            );
      END IF;

   --Start rebuilding the balances
   LOOP
      BEGIN
         SELECT xbs.ledger_id
               ,MIN(xbs.recreate_effective_period_num)
           INTO l_current_ledger_id
               ,l_current_effective_period_num
           FROM xla_balance_statuses xbs
          WHERE xbs.balance_status_code        = 'B'
            AND xbs.request_id                 =  NVL(l_req_id, -1)
            AND ROWNUM                         = 1
         GROUP BY xbs.ledger_id;
      EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         EXIT;
      WHEN OTHERS
      THEN
         RAISE;
      END;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'l_current_ledger_id: ' || l_current_ledger_id
             ,p_level => C_LEVEL_STATEMENT
            );
         trace
            ( p_module => l_log_module
             ,p_msg   => 'l_current_effective_period_num: ' || l_current_effective_period_num
             ,p_level => C_LEVEL_STATEMENT
            );
      END IF;

      FOR i IN ( SELECT gps.period_name
                       ,gps.effective_period_num
                       ,( SELECT MAX(gps2.effective_period_num)
                            FROM gl_period_statuses gps2
                           WHERE gps2.ledger_id              = l_current_ledger_id
                             AND gps2.application_id         =  101
                             AND gps2.effective_period_num   <  gps.effective_period_num
                             AND gps2.closing_status         IN ('O', 'C', 'P')
                             AND gps2.adjustment_period_flag =  'N'
                        ) previous_effective_period_num
                   FROM gl_period_statuses gps
                  WHERE gps.ledger_id              =  l_current_ledger_id
                    AND gps.application_id         =  101
                    AND gps.closing_status         IN ('O', 'C', 'P')
                    AND gps.adjustment_period_flag =  'N'
                    AND gps.effective_period_num   >= l_current_effective_period_num
                 ORDER BY gps.effective_period_num
               )
      LOOP

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            ( p_module => l_log_module
             ,p_msg   => 'i.previous_effective_period_num: '
                         || i.previous_effective_period_num
             ,p_level => C_LEVEL_STATEMENT
            );
            trace
            ( p_module => l_log_module
             ,p_msg   => 'i.effective_period_num: ' || i.effective_period_num
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;

         IF i.previous_effective_period_num IS NOT NULL
         THEN
            l_result       := move_balances_forward_COMMIT
                          ( p_application_id               => NULL
                           ,p_ledger_id                    => l_current_ledger_id
                           ,p_balance_source_code          => NULL
                           ,p_source_effective_period_num  => i.previous_effective_period_num
                           ,p_balance_status_code_selected => 'Q'
                           ,p_balance_status_code_not_sel  => 'B'
                           );
            IF NOT l_result
            THEN
               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                  ( p_module => l_log_module
                  ,p_msg   => 'Unable to open balances in period:'
                               || i.effective_period_num
                   ,p_level => C_LEVEL_STATEMENT
                  );
            END IF;
               IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
                  trace
                     (p_module => l_log_module
                     ,p_msg      => 'END ' || l_log_module
                      ,p_level    => C_LEVEL_PROCEDURE);
               END IF;
               RETURN FALSE;
            END IF;
         END IF;

         l_result       := calculate_balances
                     ( p_application_id             => NULL
                      ,p_ledger_id                  => l_current_ledger_id
                      ,p_entity_id                  => NULL
                      ,p_event_id                   => NULL
                      ,p_request_id                 => NULL
                      ,p_accounting_batch_id        => NULL
                      ,p_ae_header_id               => NULL
                      ,p_ae_line_num                => NULL
                      ,p_code_combination_id        => NULL
                      ,p_period_name                => i.period_name
                      ,p_update_mode                => 'M'
                      ,p_balance_source_code        => NULL
                      ,p_called_by_flag             => NULL
                      ,p_commit_flag                => 'Y'
                     );

         IF NOT l_result
         THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
               ( p_module => l_log_module
                ,p_msg   => 'Unable to calculate balances in period:'
                            || i.effective_period_num
                ,p_level => C_LEVEL_STATEMENT
               );
            END IF;
            IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
               trace
                      (p_module => l_log_module
                      , p_msg      => 'END ' || l_log_module
                      ,p_level    => C_LEVEL_PROCEDURE);
            END IF;
            RETURN FALSE;
         END IF;

      END LOOP;

      l_date := SYSDATE;
      UPDATE xla_balance_statuses xbs
         SET xbs.balance_status_code  = 'C'
            ,last_update_date         = l_date
            ,last_updated_by          = l_user_id
            ,last_update_login        = l_login_id
            ,program_update_date      = l_date
            ,program_application_id   = l_prog_appl_id
            ,program_id               = l_prog_id
            ,request_id               = NVL(l_req_id, -1)
       WHERE xbs.balance_status_code  = 'B'
         AND xbs.request_id           = NVL(l_req_id, -1)
         AND xbs.ledger_id            = l_current_ledger_id;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
               ,p_msg   => l_row_count
                            || ' xla_balance_statuses updated to C'
                ,p_level => C_LEVEL_STATEMENT
               );
      END IF;

      COMMIT;

   END LOOP;

--Phase 3: check for warnings


   SELECT count(*)
     INTO l_warning_count
     FROM xla_balance_statuses xbs
    WHERE xbs.request_id             =  NVL(l_req_id, -1)
      AND NVL(xbs.warning_flag, 'N') = 'Y';

   IF l_warning_count > 0
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg   =>
'This request was unable to process all the requested balances'
             ,p_level => C_LEVEL_ERROR
            );
         trace
            (p_module => l_log_module
            , p_msg   =>
'Please resubmit again this request to complete the task.'
             ,p_level => C_LEVEL_ERROR
            );
      END IF;

      LOOP
         l_date := SYSDATE;

         UPDATE xla_balance_statuses xbs
            SET xbs.balance_status_code  = 'A'
               ,last_update_date         = l_date
               ,last_updated_by          = l_user_id
               ,last_update_login        = l_login_id
               ,program_update_date      = l_date
               ,program_application_id   = l_prog_appl_id
               ,program_id               = l_prog_id
               ,request_id               = NVL(l_req_id, -1)
          WHERE xbs.request_id             =  NVL(l_req_id, -1)
            AND NVL(xbs.warning_flag, 'N') =  'Y'
            AND ROWNUM                     <= C_BATCH_COMMIT_SIZE;

         l_row_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            (p_module => l_log_module
             , p_msg   => l_row_count || ' xla_balance_statuses updated to A'
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;

         IF l_row_count < C_BATCH_COMMIT_SIZE
         THEN
            COMMIT;
            EXIT;
         ELSE
            COMMIT;
         END IF;
      END LOOP;

      l_return_value := FALSE;
   ELSE
      l_return_value := TRUE;
   END IF;

--Phase 4: set status back to available
   IF l_return_value
   THEN
      LOOP
         l_date := SYSDATE;
         UPDATE xla_balance_statuses xbs
            SET xbs.balance_status_code  = 'A'
               ,last_update_date         = l_date
               ,last_updated_by          = l_user_id
               ,last_update_login        = l_login_id
               ,program_update_date      = l_date
               ,program_application_id   = l_prog_appl_id
               ,program_id               = l_prog_id
               ,request_id               = NVL(l_req_id, -1)
          WHERE xbs.balance_status_code  =  'C'
            AND xbs.request_id           =  NVL(l_req_id, -1)
            AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

         l_row_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            ( p_module => l_log_module
             ,p_msg   => l_row_count || ' xla_balance_statuses updated to A'
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;

         IF l_row_count < C_BATCH_COMMIT_SIZE
         THEN
            COMMIT;
            EXIT;
         ELSE
            COMMIT;
         END IF;
      END LOOP;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.recreation_common');

END recreation_common;


FUNCTION recreation_detailed
  ( p_application_id             IN INTEGER
   ,p_ledger_id                  IN INTEGER
   ,p_party_type_code            IN VARCHAR2
   ,p_party_id                   IN INTEGER
   ,p_party_site_id              IN INTEGER
   ,p_account_segment_value_low  IN VARCHAR2
   ,p_account_segment_value_high IN VARCHAR2
   ,p_starting_period_name       IN VARCHAR2
  ) RETURN BOOLEAN
IS

l_starting_eff_period_num         INTEGER;
l_chart_of_accounts_id            INTEGER;
l_temp_population_dyn_stmt        VARCHAR2(4000);
l_application_clause              VARCHAR2( 500);
l_ledger_clause                   VARCHAR2( 500);
l_party_clause                    VARCHAR2(1000);
l_account_clause                  VARCHAR2( 500);
l_account_segment_column          VARCHAR2(  30);
l_balance_source_code             VARCHAR2(   1);
l_count_unavailable               INTEGER;
l_current_application_id          INTEGER;
l_current_ledger_id               INTEGER;
l_current_effective_period_num    INTEGER;
l_massive_recreation              BOOLEAN;
l_user_id                         INTEGER;
l_login_id                        INTEGER;
l_date                            DATE;
l_prog_appl_id                    INTEGER;
l_prog_id                         INTEGER;
l_req_id                          INTEGER;
l_return_value                    BOOLEAN;

l_row_count                 NUMBER;

l_log_module                 VARCHAR2 (2000);

BEGIN

   l_user_id                         := xla_environment_pkg.g_usr_id;
   l_login_id                        := xla_environment_pkg.g_login_id;
   l_date                            := SYSDATE;
   l_prog_appl_id                    := xla_environment_pkg.g_prog_appl_id;
   l_prog_id                         := xla_environment_pkg.g_prog_id;
   l_req_id                          := xla_environment_pkg.g_req_id;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.recreation_detailed';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_application_id IS NOT NULL
   THEN
      l_application_clause :=
      'AND xbs.application_id                     = ' || p_application_id || '
      ';
   END IF;


   IF p_ledger_id IS NOT NULL
   THEN
      SELECT chart_of_accounts_id
        INTO l_chart_of_accounts_id
        FROM gl_ledgers  xgl
       WHERE xgl.ledger_id = p_ledger_id;

      l_ledger_clause :=
      'AND xbs.ledger_id                          = ' || p_ledger_id || '
      ';
      IF p_starting_period_name IS NOT NULL
      THEN
         SELECT gps.effective_period_num
           INTO l_starting_eff_period_num
           FROM gl_period_statuses gps
          WHERE gps.ledger_id      = p_ledger_id
            AND gps.application_id = 101
            AND gps.period_name    = p_starting_period_name;
      END IF;
      IF p_account_segment_value_low IS NOT NULL
      THEN
         IF p_account_segment_value_high IS NOT NULL
         THEN
            l_account_segment_column := get_account_segment_column
                       (p_chart_of_accounts_id => l_chart_of_accounts_id);

            l_account_clause :=
            'AND gcc.' || l_account_segment_column || '
             BETWEEN  '' || p_account_segment_value_low  || ''
                  AND  '' || p_account_segment_value_high || ''
            ';

         END IF;
      END IF;
   END IF; --p_ledger_id IS NOT NULL

   IF p_party_type_code IS NOT NULL
   THEN
      l_party_clause :=
            'AND EXISTS (SELECT 1
                           FROM xla_ae_headers xah
                               ,xla_ae_lines   xal
                          WHERE xah.application_id             =  xbs.application_id
                            AND xah.ledger_id                  =  xbs.ledger_id
                            AND xal.code_combination_id        =  xbs.code_combination_id
                            AND xal.ae_header_id               =  xah.ae_header_id
                            AND xal.party_type_code            = ''' || p_party_type_code ||'''
            ';

      IF p_party_id IS NOT NULL
      THEN
         l_party_clause := l_party_clause ||
         'AND xal.party_id                   = '|| p_party_id ||' ';
         IF p_party_site_id IS NOT NULL
         THEN
            l_party_clause := l_party_clause ||
            'AND NVL(xal.party_site_id,-999) = '|| p_party_site_id || ' ';
         END IF;

      END IF;
      l_party_clause := l_party_clause || ') ';

   END IF;

   l_temp_population_dyn_stmt  :=
   '  INSERT
      INTO xla_bal_recreate_gt
      ( application_id
       ,ledger_id
       ,code_combination_id
       ,balance_source_code
      )
      SELECT xbs.application_id
            ,xbs.ledger_id
            ,xbs.code_combination_id
            ,xbs.balance_source_code
        FROM xla_balance_statuses      xbs
            ,gl_code_combinations      gcc
            ,xla_bal_recreate_gt xbt
       WHERE gcc.code_combination_id           =  xbs.code_combination_id
         AND xbt.application_id             (+)=  xbs.application_id
         AND xbt.ledger_id                  (+)=  xbs.ledger_id
         AND xbt.code_combination_id        (+)=  xbs.code_combination_id
         AND xbt.balance_source_code        (+)=  xbs.balance_source_code
         AND xbt.application_id                IS NULL
         AND ROWNUM                            <= ' || C_BATCH_COMMIT_SIZE || '
   ';

   l_temp_population_dyn_stmt  := l_temp_population_dyn_stmt  ||
                                  l_application_clause        ||
                                  l_ledger_clause             ||
                                  l_party_clause              ||
                                  l_account_clause;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module => l_log_module
          ,p_msg    => 'l_temp_population_dyn_stmt: '
          ,p_level  => C_LEVEL_STATEMENT
         );
      trace
         ( p_module => l_log_module
          ,p_msg    => l_temp_population_dyn_stmt
          ,p_level  => C_LEVEL_STATEMENT
         );
   END IF;


   LOOP
      EXECUTE IMMEDIATE
      l_temp_population_dyn_stmt;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => l_row_count
                      || ' records inserted in xla_bal_recreate_gt'
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      IF l_row_count < C_BATCH_COMMIT_SIZE
      THEN
         COMMIT;
         EXIT;
      ELSE
         COMMIT;
      END IF;
   END LOOP;

  --try to bring the balances off line for recreation
      LOOP
         l_date := SYSDATE;
         UPDATE xla_balance_statuses xbsext
            SET xbsext.balance_status_code      = DECODE( xbsext.balance_status_code
                                                         ,'A'
                                                         ,'R'
                                                         ,xbsext.balance_status_code
                                                        )
               ,xbsext.recreate_party_type_code = DECODE( xbsext.balance_status_code
                                                         ,'A'
                                                         ,p_party_type_code
                                                         ,xbsext.recreate_party_type_code
                                                        )
               ,xbsext.recreate_party_id        = DECODE( xbsext.balance_status_code
                                                         ,'A'
                                                         ,p_party_id
                                                         ,xbsext.recreate_party_id
                                                        )
               ,xbsext.recreate_party_site_id   = DECODE( xbsext.balance_status_code
                                                         ,'A'
                                                         ,p_party_site_id
                                                         ,xbsext.recreate_party_site_id
                                                        )
               ,xbsext.recreate_effective_period_num = DECODE( xbsext.balance_status_code
                                                         ,'A'
                                                         ,NVL( l_starting_eff_period_num
                                                              ,(SELECT MIN(effective_period_num)
                                                                  FROM gl_period_statuses gps
                                                                 WHERE gps.ledger_id      = xbsext.ledger_id
                                                                   AND gps.application_id = 101
                                                                   AND gps.closing_status IN ('O', 'C', 'P')
                                                                   AND gps.adjustment_period_flag = 'N'
                                                               )
                                                             )
                                                         ,xbsext.recreate_effective_period_num
                                                        )
               ,xbsext.warning_flag             = DECODE( xbsext.balance_status_code
                                                         ,'A'
                                                         ,'N'
                                                         ,'C'
                                                         ,'N'
                                                         ,'Y'
                                                        )
               ,xbsext.last_update_date         = l_date
               ,xbsext.last_updated_by          = l_user_id
               ,xbsext.last_update_login        = l_login_id
               ,xbsext.program_update_date      = l_date
               ,xbsext.program_application_id   = l_prog_appl_id
               ,xbsext.program_id               = l_prog_id
               ,xbsext.request_id               = NVL(l_req_id, -1)
          WHERE xbsext.ROWID IN
            (SELECT xbs.ROWID
               FROM xla_bal_recreate_gt xbt
                   ,xla_balance_statuses      xbs
                   ,fnd_concurrent_requests   fnd
              WHERE xbs.application_id             =  xbt.application_id
                AND xbs.ledger_id                  =  xbt.ledger_id
                AND xbs.code_combination_id        =  xbt.code_combination_id
                AND xbs.balance_source_code        =  xbt.balance_source_code
                AND xbs.effective_period_num       >= NVL( l_starting_eff_period_num
                                                          ,xbs.effective_period_num
                                                         )
                AND fnd.request_id(+)                 =  xbs.request_id
                AND (   xbs.balance_status_code       =  'A'
                     OR (    xbs.balance_status_code  IN ('R', 'B', 'Q', 'C')
                         AND nvl(fnd.status_code,'N')          <>  'R'
                        )
                    )
             UNION
             SELECT xbs.ROWID
               FROM xla_balance_statuses      xbs
              WHERE xbs.application_id             =  NVL( p_application_id
                                                          ,xbs.application_id
                                                         )
                AND xbs.ledger_id                  =  NVL( p_ledger_id
                                                          ,xbs.ledger_id
                                                         )
                AND xbs.effective_period_num       >= NVL( l_starting_eff_period_num
                                                          ,xbs.effective_period_num
                                                         )
                AND NVL(xbs.request_id, -1)        =  -1
                AND xbs.balance_status_code        IN ('A', 'R', 'B', 'Q', 'C')
             )
            AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

         l_row_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
            ( p_module => l_log_module
             ,p_msg   => l_row_count || ' xla_balance_statuses updated to R'
             ,p_level => C_LEVEL_STATEMENT
            );
         END IF;

         IF l_row_count < C_BATCH_COMMIT_SIZE
         THEN
            COMMIT;
            EXIT;
         ELSE
            COMMIT;
         END IF;
      END LOOP;

     SELECT count(*)
       INTO l_count_unavailable
       FROM xla_bal_recreate_gt xbt
           ,xla_balance_statuses      xbs
      WHERE xbs.application_id             =  xbt.application_id
        AND xbs.ledger_id                  =  xbt.ledger_id
        AND xbs.code_combination_id        =  xbt.code_combination_id
        AND xbs.balance_source_code        =  xbt.balance_source_code
        AND xbs.effective_period_num       >= NVL( l_starting_eff_period_num
                                                   ,xbs.effective_period_num
                                                 )
        AND (   NVL(xbs.request_id, -1)    <> NVL(l_req_id, -1)
             OR xbs.balance_status_code    NOT IN ('R', 'B', 'Q', 'C')
            );

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF l_count_unavailable > 0
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'Some balance status records are unavailable'
             ,p_level => C_LEVEL_STATEMENT
            );
      END IF;
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;


EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.recreation_detailed');

END recreation_detailed;


FUNCTION recreation_massive
  ( p_application_id             IN INTEGER
   ,p_ledger_id                  IN INTEGER
   ,p_starting_period_name       IN VARCHAR2
  ) RETURN BOOLEAN
IS

l_starting_eff_period_num         INTEGER;
l_chart_of_accounts_id            INTEGER;
l_account_segment_column          VARCHAR2(  30);
l_balance_source_code             VARCHAR2(   1);
l_count_unavailable               INTEGER;
l_massive_recreation              BOOLEAN;
l_user_id                         INTEGER;
l_login_id                        INTEGER;
l_date                            DATE;
l_prog_appl_id                    INTEGER;
l_prog_id                         INTEGER;
l_req_id                          INTEGER;

l_row_count                 NUMBER;

l_log_module                 VARCHAR2 (2000);

BEGIN

   l_user_id                         := xla_environment_pkg.g_usr_id;
   l_login_id                        := xla_environment_pkg.g_login_id;
   l_date                            := SYSDATE;
   l_prog_appl_id                    := xla_environment_pkg.g_prog_appl_id;
   l_prog_id                         := xla_environment_pkg.g_prog_id;
   l_req_id                          := xla_environment_pkg.g_req_id;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.recreation_massive';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF  p_ledger_id IS NOT NULL
   AND p_starting_period_name IS NOT NULL
   THEN
      SELECT gps.effective_period_num
        INTO l_starting_eff_period_num
        FROM gl_period_statuses gps
       WHERE gps.ledger_id      = p_ledger_id
         AND gps.application_id = 101
         AND gps.period_name    = p_starting_period_name;
   END IF;

  --try to bring the balances off line
  LOOP
     l_date := SYSDATE;

      UPDATE xla_balance_statuses xbsext
            SET xbsext.balance_status_code      = DECODE( xbsext.balance_status_code
                                                         ,'A'
                                                         ,'R'
                                                         ,xbsext.balance_status_code
                                                        )
               ,xbsext.recreate_party_type_code = DECODE( xbsext.balance_status_code
                                                         ,'A'
                                                         ,NULL
                                                         ,xbsext.recreate_party_type_code
                                                        )
               ,xbsext.recreate_party_id        = DECODE( xbsext.balance_status_code
                                                         ,'A'
                                                         ,NULL
                                                         ,xbsext.recreate_party_id
                                                        )
               ,xbsext.recreate_party_site_id   = DECODE( xbsext.balance_status_code
                                                         ,'A'
                                                         ,NULL
                                                         ,xbsext.recreate_party_site_id
                                                        )
               ,xbsext.recreate_effective_period_num = DECODE( xbsext.balance_status_code
                                                         ,'A'
                                                         ,NVL( l_starting_eff_period_num
                                                              ,(SELECT MIN(effective_period_num)
                                                                  FROM gl_period_statuses gps
                                                                 WHERE gps.ledger_id      = xbsext.ledger_id
                                                                   AND gps.application_id = 101
                                                                   AND gps.closing_status IN ('O', 'C', 'P')
                                                                   AND gps.adjustment_period_flag = 'N'
                                                               )
                                                             )
                                                         ,xbsext.recreate_effective_period_num
                                                        )
               ,xbsext.warning_flag             = DECODE( xbsext.balance_status_code
                                                         ,'A'
                                                         ,'N'
                                                         ,'C'
                                                         ,'N'
                                                         ,'Y'
                                                        )
               ,xbsext.last_update_date         = l_date
               ,xbsext.last_updated_by          = l_user_id
               ,xbsext.last_update_login        = l_login_id
               ,xbsext.program_update_date      = l_date
               ,xbsext.program_application_id   = l_prog_appl_id
               ,xbsext.program_id               = l_prog_id
               ,xbsext.request_id               = l_req_id
          WHERE xbsext.ROWID IN
            (SELECT xbs.ROWID
               FROM xla_balance_statuses      xbs
                   ,fnd_concurrent_requests   fnd
              WHERE xbs.application_id             =  NVL( p_application_id
                                                          ,xbs.application_id
                                                         )
                AND xbs.ledger_id                  =  NVL( p_ledger_id
                                                          ,xbs.ledger_id
                                                         )
                AND xbs.effective_period_num       >= NVL( l_starting_eff_period_num
                                                          ,xbs.effective_period_num
                                                         )
                AND fnd.request_id(+)                 =  xbs.request_id
                AND (   xbs.balance_status_code       =  'A'
                     OR (    xbs.balance_status_code  IN ('R', 'B', 'Q', 'C')
                         AND NVL(fnd.status_code,'N')          <>  'R'
                        )
                    )
             UNION
             SELECT xbs.ROWID
               FROM xla_balance_statuses      xbs
              WHERE xbs.application_id             =  NVL( p_application_id
                                                          ,xbs.application_id
                                                         )
                AND xbs.ledger_id                  =  NVL( p_ledger_id
                                                          ,xbs.ledger_id
                                                         )
                AND xbs.effective_period_num       >= NVL( l_starting_eff_period_num
                                                          ,xbs.effective_period_num
                                                         )
                AND NVL(xbs.request_id, -1)        =  -1
                AND xbs.balance_status_code        IN ('A', 'R', 'B', 'Q', 'C')
             )
            AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => l_row_count || ' xla_balance_statuses updated to R'
             ,p_level => C_LEVEL_STATEMENT
            );

      END IF;

      IF l_row_count < C_BATCH_COMMIT_SIZE
      THEN
         COMMIT;
         EXIT;
      ELSE
         COMMIT;
      END IF;
   END LOOP;


     SELECT count(*)
       INTO l_count_unavailable
       FROM xla_balance_statuses      xbs
      WHERE xbs.application_id             =  NVL( p_application_id
                                                  ,xbs.application_id
                                                 )
        AND xbs.ledger_id                  =  NVL( p_ledger_id
                                                  ,xbs.ledger_id
                                                 )
        AND xbs.effective_period_num       >= NVL( l_starting_eff_period_num
                                                  ,xbs.effective_period_num
                                                 )
        AND (   NVL(xbs.request_id, -1)    <> NVL(l_req_id, -1)
             OR xbs.balance_status_code    NOT IN ('R', 'B', 'Q', 'C')
            );



   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF l_count_unavailable > 0
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'This request was unable to select all the requested balances'
             ,p_level => C_LEVEL_ERROR
            );
         trace
            ( p_module => l_log_module
             ,p_msg   => 'Please resubmit again this request later.'
             ,p_level => C_LEVEL_ERROR
            );
      END IF;
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.recreation_massive');

END recreation_massive;


PROCEDURE recreate_srs
                       ( p_errbuf                     OUT NOCOPY VARCHAR2
                        ,p_retcode                    OUT NOCOPY NUMBER
                        ,p_application_id             IN         INTEGER
                        ,p_ledger_id                  IN         INTEGER
                        ,p_party_type_code            IN         VARCHAR2
                        ,p_party_id                   IN         INTEGER
                        ,p_party_site_id              IN         INTEGER
                        ,p_starting_period_name       IN         VARCHAR2
                        ,p_account_segment_value_low  IN         VARCHAR2
                        ,p_account_segment_value_high IN         VARCHAR2
                       )
IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
l_result BOOLEAN;

l_row_count                 NUMBER;

l_log_module                 VARCHAR2 (2000);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.recreate_srs';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   fnd_file.put_line(fnd_file.log,'p_application_id            : ' || p_application_id);
   fnd_file.put_line(fnd_file.log,'p_ledger_id                 : ' || p_ledger_id);
   fnd_file.put_line(fnd_file.log,'p_party_type_code           : ' || p_party_type_code);
   fnd_file.put_line(fnd_file.log,'p_party_id                  : ' || p_party_id);
   fnd_file.put_line(fnd_file.log,'p_party_site_id             : ' || p_party_site_id);
   fnd_file.put_line(fnd_file.log,'p_starting_period_name      : ' || p_starting_period_name);
   fnd_file.put_line(fnd_file.log,'p_account_segment_value_low : ' || p_account_segment_value_low);
   fnd_file.put_line(fnd_file.log,'p_account_segment_value_high: ' || p_account_segment_value_high);

   LOOP

      DELETE
        FROM xla_bal_recreate_gt;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => l_row_count || ' xla_bal_recreate_gt deleted.'
          ,p_level => C_LEVEL_STATEMENT
         );
      END IF;

      IF l_row_count < C_BATCH_COMMIT_SIZE
      THEN
         COMMIT;
         EXIT;
      ELSE
         COMMIT;
      END IF;
   END LOOP;

   IF  p_party_type_code            IS NULL
   AND p_party_id                   IS NULL
   AND p_party_site_id              IS NULL
   AND p_account_segment_value_low  IS NULL
   AND p_account_segment_value_high IS NULL
   THEN
      l_result :=
         recreation_massive
            ( p_application_id       => p_application_id
             ,p_ledger_id            => p_ledger_id
             ,p_starting_period_name => p_starting_period_name
            );
   ELSE
      l_result :=
         recreation_detailed
            ( p_application_id             => p_application_id
             ,p_ledger_id                  => p_ledger_id
             ,p_party_type_code            => p_party_type_code
             ,p_party_id                   => p_party_id
             ,p_party_site_id              => p_party_site_id
             ,p_starting_period_name       => p_starting_period_name
             ,p_account_segment_value_low  => p_account_segment_value_low
             ,p_account_segment_value_high => p_account_segment_value_high
            );
   END IF;

   IF NOT l_result
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg   => 'recreation selection failed'
          ,p_level => C_LEVEL_ERROR
         );
      END IF;
      p_retcode := 2;
      RETURN;
   END IF;

   l_result := recreation_common;

   IF l_result
   THEN
      p_retcode := 0;
   ELSE
      p_retcode := 1;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   p_retcode := 2;
   p_errbuf := sqlerrm;
WHEN OTHERS                                   THEN
   p_retcode := 2;
   p_errbuf := sqlerrm;
END recreate_srs;


FUNCTION recreate
  ( p_application_id             IN INTEGER
   ,p_ledger_id                  IN INTEGER
   ,p_party_type_code            IN VARCHAR2
   ,p_party_id                   IN INTEGER
   ,p_party_site_id              IN INTEGER
   ,p_starting_period_name       IN VARCHAR2
   ,p_account_segment_value_low  IN VARCHAR2
   ,p_account_segment_value_high IN VARCHAR2
  ) RETURN BOOLEAN
IS

l_return_value BOOLEAN;
l_req_id       NUMBER;
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.recreate';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_req_id := fnd_request.submit_request
                ( application => 'XLA'
                 ,program     => 'XLABAREC'
                 ,description => 'Balance Recreation'
                 ,argument1   => p_application_id
                 ,argument2   => p_ledger_id
                 ,argument3   => p_party_type_code
                 ,argument4   => p_party_id
                 ,argument5   => p_party_site_id
                 ,argument6   => p_starting_period_name
                 ,argument7   => p_account_segment_value_low
                 ,argument8   => p_account_segment_value_high
                );

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'Submitted request ID: ' || l_req_id
         ,p_level    => C_LEVEL_EVENT );
   END IF;

   IF l_req_id = 0 THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'Unable to submit request'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
                  (p_location => 'xla_balances_pkg.recreate');
   END IF;

   l_return_value := TRUE;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.recreate');

END recreate;



FUNCTION synchronize
  ( p_chart_of_accounts_id       IN INTEGER
   ,p_account_segment_value      IN VARCHAR2
  ) RETURN BOOLEAN
IS
l_user_id                     INTEGER;
l_login_id                    INTEGER;
l_date                        DATE;
l_prog_appl_id                INTEGER;
l_prog_id                     INTEGER;
l_req_id                      INTEGER;

l_id_flex_code                VARCHAR2 ( 4);
l_account_segment_column      VARCHAR2 (30);
l_min_reference3              VARCHAR2 (30) ;
l_max_reference3              VARCHAR2 (30) ;
l_count_unavailable           INTEGER;
l_control_account_source_code VARCHAR2(30);
l_code_combination_id         INTEGER;
l_result                      BOOLEAN;

l_row_count                 NUMBER;

l_log_module                 VARCHAR2 (2000);

BEGIN

l_user_id                     := xla_environment_pkg.g_usr_id;
l_login_id                    := xla_environment_pkg.g_login_id;
l_date                        := SYSDATE;
l_prog_appl_id                := xla_environment_pkg.g_prog_appl_id;
l_prog_id                     := xla_environment_pkg.g_prog_id;
l_req_id                      := xla_environment_pkg.g_req_id;

l_id_flex_code                := 'GL#';

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.synchronize';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_chart_of_accounts_id    :' || p_chart_of_accounts_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'p_account_segment_value   :' || p_account_segment_value
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   IF FND_FLEX_APIS.get_segment_column( 101
                                       ,l_id_flex_code
                                       ,p_chart_of_accounts_id
                                       ,'GL_ACCOUNT'
                                       ,l_account_segment_column
                                      )

   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
             ,p_msg   => 'l_account_segment_column:' ||
                            l_account_segment_column
               ,p_level => C_LEVEL_STATEMENT
               );
      END IF;
   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'Unable to retrieve segment information for chart of accounts ' ||
                          p_chart_of_accounts_id
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_balances_pkg.synchronize');
   END IF;

   LOOP
      EXECUTE IMMEDIATE
      '
      INSERT
      INTO xla_bal_synchronize_gt
      ( chart_of_accounts_id
       ,code_combination_id
       ,reference3
      )
      SELECT gcc.chart_of_accounts_id
            ,gcc.code_combination_id
            ,gcc.reference3
        FROM gl_code_combinations         gcc
            ,xla_bal_synchronize_gt xbt
       WHERE gcc.chart_of_accounts_id               =  :1
         AND gcc.' || l_account_segment_column || ' =  :2
         AND xbt.chart_of_accounts_id            (+)=  :3
         AND xbt.code_combination_id             (+)=  gcc.code_combination_id
         AND xbt.chart_of_accounts_id               IS NULL
         AND ROWNUM                                 <= :4
      '
      USING p_chart_of_accounts_id
           ,p_account_segment_value
           ,p_chart_of_accounts_id
           ,C_BATCH_COMMIT_SIZE;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
             ,p_msg   => l_row_count
                          || ' records inserted in xla_bal_synchronize_gt'
               ,p_level => C_LEVEL_STATEMENT
               );
      END IF;

      IF l_row_count < C_BATCH_COMMIT_SIZE
      THEN
         COMMIT;
         EXIT;
      ELSE
         COMMIT;
      END IF;
   END LOOP;

   SELECT MIN(reference3)
         ,MAX(reference3)
     INTO l_min_reference3
         ,l_max_reference3
     FROM xla_bal_synchronize_gt xbt
    WHERE xbt.chart_of_accounts_id = p_chart_of_accounts_id;

   IF NVL(l_min_reference3,'N') = NVL(l_max_reference3, 'N') OR
      NVL(l_min_reference3,'R') = NVL(l_max_reference3, 'R') -- added condition for 8490178
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
             ,p_msg   => 'Current reference3: ' || l_min_reference3
               ,p_level => C_LEVEL_STATEMENT
               );
      END IF;
   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'REFERENCE3 is not consistent across ccids'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
            (p_location => 'xla_balances_pkg.synchronize');
   END IF;

   IF NVL(l_min_reference3,'N') = 'N'
      OR
      NVL(l_min_reference3,'N') = 'R' -- added condition for 8490178
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
             ,p_msg   => 'account is no more control'
               ,p_level => C_LEVEL_STATEMENT
               );
      END IF;
   END IF;
   --Since the control account may have changed application
   --all the existing balances must be deleted and recomputed

   --try to bring the balances off line
   LOOP

      UPDATE xla_balance_statuses xbsext
         SET xbsext.balance_status_code      = 'S'
            ,xbsext.last_update_date         = l_date
            ,xbsext.last_updated_by          = l_user_id
            ,xbsext.last_update_login        = l_login_id
            ,xbsext.program_update_date      = l_date
            ,xbsext.program_application_id   = l_prog_appl_id
            ,xbsext.program_id               = l_prog_id
            ,xbsext.request_id               = NVL(l_req_id, -1)
       WHERE xbsext.ROWID IN
            (SELECT xbs.ROWID
               FROM xla_balance_statuses    xbs
                   ,fnd_concurrent_requests fnd
              WHERE xbs.ledger_id            IN
                       (
                        SELECT xgl.ledger_id
                          FROM gl_ledgers        xgl
                         WHERE xgl.chart_of_accounts_id = p_chart_of_accounts_id
                       )
                AND xbs.code_combination_id IN
                       (
                        SELECT xbt.code_combination_id
                          FROM xla_bal_synchronize_gt xbt
                         WHERE xbt.chart_of_accounts_id = p_chart_of_accounts_id
                        )
                AND xbs.balance_source_code  =  'C'
                AND xbs.balance_status_code  IN ('A', 'S')
                AND fnd.request_id(+)           =  xbs.request_id
                AND NVL(fnd.status_code,'N')  <> 'R'
             UNION
             SELECT xbs.ROWID
               FROM xla_balance_statuses    xbs
              WHERE xbs.ledger_id            IN
                       (
                        SELECT xgl.ledger_id
                          FROM gl_ledgers        xgl
                         WHERE xgl.chart_of_accounts_id = p_chart_of_accounts_id
                       )
                AND xbs.code_combination_id IN
                       (
                        SELECT xbt.code_combination_id
                          FROM xla_bal_synchronize_gt xbt
                         WHERE xbt.chart_of_accounts_id = p_chart_of_accounts_id
                        )
                AND xbs.balance_source_code  =  'C'
                AND xbs.balance_status_code  IN ('A', 'S')
                AND NVL(xbs.request_id, -1)  =  NVL(l_req_id, -1)
            )
         AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
             ,p_msg   => l_row_count
                           || ' xla_balance_statuses updated to S'
               ,p_level => C_LEVEL_STATEMENT
               );
      END IF;

      IF l_row_count < C_BATCH_COMMIT_SIZE
      THEN
         COMMIT;
         EXIT;
      ELSE
        COMMIT;
       END IF;
   END LOOP;

/*
   --lock xla_balance_statuses and wait if necessary
   EXECUTE IMMEDIATE
   '
       SELECT xbs.code_combination_id
         FROM xla_balance_statuses xbs
        WHERE xbs.ledger_id            IN
               (
                SELECT xgl.ledger_id
                  FROM gl_ledgers        xgl
                      ,xla_setup_ledgers xsl
                 WHERE xgl.chart_of_accounts_id = :1
                   AND xsl.ledger_id            = xgl.ledger_id
                )
          AND xbs.balance_source_code  =  ''C''
          AND xbs.code_combination_id IN
                (
                   SELECT xbt.code_combination_id
                     FROM xla_bal_synchronize_gt xbt
                    WHERE xbt.chart_of_accounts_id = :1
                )
       FOR UPDATE OF xbs.ledger_id
   '
   USING p_chart_of_accounts_id
        ,p_chart_of_accounts_id;
*/

   SELECT COUNT(*)
     INTO l_count_unavailable
     FROM xla_balance_statuses xbs
    WHERE xbs.balance_status_code  <> 'S'
      AND ( xbs.application_id
             ,xbs.ledger_id
             ,xbs.code_combination_id
            )
           IN
           (
              SELECT xbt.application_id
                    ,xbt.ledger_id
                    ,xbt.code_combination_id
                FROM xla_bal_recreate_gt xbt
           );

   IF l_count_unavailable > 0
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
             ,p_msg   => 'Check for previous balance requests in error'
               ,p_level => C_LEVEL_STATEMENT
               );
         trace
               (p_module => l_log_module
             ,p_msg   => 'Please resubmit'
               ,p_level => C_LEVEL_STATEMENT
               );
      END IF;
      RETURN FALSE;
   END IF;

   --must ensure accounting lines have control_balance_flag NULL
   LOOP
      UPDATE xla_ae_lines xal
         SET xal.control_balance_flag = NULL
       WHERE xal.code_combination_id  IN
                (
                  SELECT xbt.code_combination_id
                    FROM xla_bal_synchronize_gt xbt
                   WHERE xbt.chart_of_accounts_id = p_chart_of_accounts_id
                )
         AND xal.control_balance_flag IS NOT NULL
         AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
             ,p_msg   => l_row_count || ' xla_ae_lines updated to N'
               ,p_level => C_LEVEL_STATEMENT
               );
      END IF;

      IF l_row_count < C_BATCH_COMMIT_SIZE
      THEN
         COMMIT;
         EXIT;
      ELSE
         COMMIT;
      END IF;
   END LOOP;

   --delete xla_control_balances
   LOOP
      DELETE
        FROM xla_control_balances xcb
       WHERE xcb.code_combination_id IN
                (
                 SELECT xbt.code_combination_id
                   FROM xla_bal_synchronize_gt xbt
                  WHERE xbt.chart_of_accounts_id = p_chart_of_accounts_id
                )
         AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
             ,p_msg   => l_row_count || ' xla_balance_statuses deleted'
               ,p_level => C_LEVEL_STATEMENT
               );
      END IF;
      IF l_row_count < C_BATCH_COMMIT_SIZE
      THEN
         COMMIT;
         EXIT;
      ELSE
        COMMIT;
      END IF;
   END LOOP;

   --delete xla_balance_statuses
   LOOP
      DELETE
        FROM xla_balance_statuses xbs
       WHERE xbs.code_combination_id IN
              (
                SELECT xbt.code_combination_id
                  FROM xla_bal_synchronize_gt xbt
                 WHERE xbt.chart_of_accounts_id = p_chart_of_accounts_id
              )
         AND xbs.balance_status_code = 'S'
         AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
             ,p_msg   => l_row_count || ' xla_balance_statuses deleted'
               ,p_level => C_LEVEL_STATEMENT
               );
      END IF;
      IF l_row_count < C_BATCH_COMMIT_SIZE
      THEN
         COMMIT;
         EXIT;
      ELSE
        COMMIT;
      END IF;
   END LOOP;

   SELECT COUNT(*)
     INTO l_count_unavailable
     FROM xla_balance_statuses xbs
    WHERE xbs.balance_source_code  =  'C'
      AND xbs.code_combination_id IN
       (
         SELECT xbt.code_combination_id
           FROM xla_bal_synchronize_gt xbt
          WHERE xbt.chart_of_accounts_id = p_chart_of_accounts_id
       );

   IF l_count_unavailable > 0
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
               (p_module => l_log_module
             ,p_msg   => 'Not all xla_balance_statuses records available'
               ,p_level => C_LEVEL_ERROR
               );
         trace
               (p_module => l_log_module
             ,p_msg   => 'Please resubmit'
               ,p_level => C_LEVEL_ERROR
               );
      END IF;
      RETURN FALSE;
   END IF;

   IF NVL(l_min_reference3,'N') NOT IN  ('N','R') -- added not in condition for 8490178
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
             ,p_msg   => 'account is now control'
               ,p_level => C_LEVEL_STATEMENT
               );
      END IF;

      LOOP
          UPDATE xla_ae_lines xal
             SET xal.control_balance_flag = 'P'
           WHERE xal.ROWID IN
                 ( SELECT xal.ROWID
                     FROM xla_bal_synchronize_gt xbt
                         ,xla_ae_lines                 xal
                         ,xla_ae_headers               xah
                         ,xla_subledgers               xsl
                    WHERE xbt.chart_of_accounts_id =  p_chart_of_accounts_id
                      AND xal.code_combination_id  =  xbt.code_combination_id
                      AND xah.ae_header_id         =  xal.ae_header_id
                      AND xah.application_id       =  xal.application_id
                      AND xal.party_type_code      IS NOT NULL
                      AND xal.party_id             IS NOT NULL
                      AND xal.control_balance_flag IS NULL
                      AND xsl.application_id       =  xah.application_id
                      AND xbt.reference3           =  xsl.control_account_type_code
                 )
             AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

         l_row_count := SQL%ROWCOUNT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_module => l_log_module
             ,p_msg   => l_row_count || ' xla_ae_lines updated to P'
               ,p_level => C_LEVEL_STATEMENT
               );
         END IF;

         IF l_row_count < C_BATCH_COMMIT_SIZE
         THEN
            COMMIT;
            EXIT;
         ELSE
           COMMIT;
          END IF;
      END LOOP;

      l_result := FALSE;
      WHILE NOT l_result
      LOOP
         l_result := calculate_balances
               ( p_application_id             => NULL
                ,p_ledger_id                  => NULL
                ,p_entity_id                  => NULL
                ,p_event_id                   => NULL
                ,p_request_id                 => NULL
                ,p_accounting_batch_id        => NULL
                ,p_ae_header_id               => NULL
                ,p_ae_line_num                => NULL
                ,p_code_combination_id        => l_code_combination_id
                ,p_period_name                => NULL
                ,p_update_mode                => 'M'
                ,p_balance_source_code        => NULL
                ,p_called_by_flag             => NULL
                ,p_commit_flag                => 'Y'
               );
      END LOOP;

   END IF;

   LOOP
      DELETE
        FROM xla_bal_synchronize_gt xbt
       WHERE xbt.chart_of_accounts_id = p_chart_of_accounts_id
         AND ROWNUM                   <= C_BATCH_COMMIT_SIZE;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_module => l_log_module
             ,p_msg   => l_row_count || ' xla_bal_synchronize_gt deleted'
               ,p_level => C_LEVEL_STATEMENT
               );
      END IF;

      IF l_row_count < C_BATCH_COMMIT_SIZE
      THEN
         COMMIT;
         EXIT;
      ELSE
        COMMIT;
       END IF;
   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.synchronize');
END synchronize;

PROCEDURE open_period_srs
                                   ( p_errbuf         OUT NOCOPY VARCHAR2
                                    ,p_retcode        OUT NOCOPY NUMBER
                                    ,p_ledger_id      IN         NUMBER
                                   )
IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|  Just the SRS wrapper for check_create_period_balances                |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|  Call create_new_period_balances and assign its return code to        |
|  p_retcode                                                            |
|  RETURN p_retcode (0=success, 1=warning, 2=error)                     |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
|                                                                       |
| 1) Need to review the value assigned to p_errbuf                      |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/

   l_sobname       VARCHAR2(30);

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.open_period_srs';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   fnd_file.put_line(fnd_file.log,'p_ledger_id: ' || p_ledger_id);

   p_retcode := 0;

   fnd_file.put_line(fnd_file.log,'Opening control account balances' );
   IF check_create_period_balances
           ( p_application_id          => NULL
            ,p_ledger_id               => p_ledger_id
            ,p_balance_source_code     => 'C'
           )
   THEN
      fnd_file.put_line(fnd_file.log,'Successful' );
   ELSE
      p_retcode := p_retcode + 1;
      fnd_file.put_line(fnd_file.log,'Unsuccessful' );
   END IF;

   fnd_file.put_line(fnd_file.log,'Opening analytical criteria balances' );
   IF check_create_period_balances
           ( p_application_id          => NULL
            ,p_ledger_id               => p_ledger_id
            ,p_balance_source_code     => 'A'
           )
   THEN
      fnd_file.put_line(fnd_file.log,'Successful' );
   ELSE
      p_retcode := p_retcode + 1;
      fnd_file.put_line(fnd_file.log,'Unsuccessful' );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   p_retcode := 2;
   p_errbuf := sqlerrm;
WHEN OTHERS                                   THEN
   p_retcode := 2;
   p_errbuf := sqlerrm;
END open_period_srs;


FUNCTION open_period
  ( p_ledger_id                  IN INTEGER
  ) RETURN BOOLEAN
IS
l_return_value BOOLEAN;
l_req_id       NUMBER;
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.open_period';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

      --batch execution
      l_return_value := fnd_request.set_mode(TRUE);
      l_req_id := fnd_request.submit_request
                ( application => 'XLA'
                 ,program     => 'XLABAOPE'
                 ,description => 'Balance Period Opening'
                 ,argument1   => p_ledger_id
                );
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
         (p_module   => l_log_module
         ,p_msg      => 'Submitted request ID: ' || l_req_id
         ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

      IF l_req_id = 0 THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            ( p_module   => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'Unable to submit request'
             ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
                  (p_location => 'xla_balances_pkg.open_period');
      END IF;

      l_return_value := TRUE;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.open_period');
END open_period;


PROCEDURE handle_fake_journal_entry
           ( p_mode                            VARCHAR2 --'A' or 'D'
            ,p_ae_header_id                    INTEGER
            ,p_application_id                  INTEGER  DEFAULT NULL
            ,p_ledger_id                       INTEGER  DEFAULT NULL
            ,p_entity_id                       INTEGER  DEFAULT NULL
            ,p_event_id                        INTEGER  DEFAULT NULL
            ,p_event_type_code                 VARCHAR2 DEFAULT NULL
            ,p_accounting_date                 DATE     DEFAULT NULL
            ,p_gl_transfer_status_code         VARCHAR2 DEFAULT NULL
            ,p_je_category_name                VARCHAR2 DEFAULT NULL
            ,p_accounting_entry_status_code    VARCHAR2 DEFAULT NULL
            ,p_accounting_entry_type_code      VARCHAR2 DEFAULT NULL
            ,p_balance_type_code               VARCHAR2 DEFAULT NULL
            ,p_period_name                     VARCHAR2 DEFAULT NULL
            ,p_ae_line_num                     INTEGER  DEFAULT NULL
            ,p_code_combination_id             INTEGER  DEFAULT NULL
            ,p_accounted_dr                    NUMBER   DEFAULT NULL
            ,p_accounted_cr                    NUMBER   DEFAULT NULL
            ,p_currency_code                   VARCHAR2 DEFAULT NULL
            ,p_entered_dr                      NUMBER   DEFAULT NULL
            ,p_entered_cr                      NUMBER   DEFAULT NULL
            ,p_party_id                        NUMBER   DEFAULT NULL
            ,p_party_site_id                   NUMBER   DEFAULT NULL
            ,p_party_type_code                 VARCHAR2 DEFAULT NULL
            ,p_control_balance_flag            VARCHAR2 DEFAULT NULL
            ,p_analytical_balance_flag         VARCHAR2 DEFAULT NULL
           )
IS

l_user_id                    INTEGER;
l_login_id                   INTEGER;
l_date                       DATE;
l_prog_appl_id               INTEGER;
l_prog_id                    INTEGER;
l_req_id                     INTEGER;

l_log_module                 VARCHAR2 (2000);

BEGIN

l_user_id                    := xla_environment_pkg.g_usr_id;
l_login_id                   := xla_environment_pkg.g_login_id;
l_date                       := SYSDATE;
l_prog_appl_id               := xla_environment_pkg.g_prog_appl_id;
l_prog_id                    := xla_environment_pkg.g_prog_id;
l_req_id                     := xla_environment_pkg.g_req_id;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.handle_fake_journal_entry';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_mode = 'A' THEN
   INSERT INTO xla_ae_headers
    (
     AE_HEADER_ID
    ,APPLICATION_ID
    ,LEDGER_ID
    ,ENTITY_ID
    ,EVENT_ID
    ,EVENT_TYPE_CODE
    ,ACCOUNTING_DATE
    ,GL_TRANSFER_STATUS_CODE
    ,JE_CATEGORY_NAME
    ,ACCOUNTING_ENTRY_STATUS_CODE
    ,ACCOUNTING_ENTRY_TYPE_CODE
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,BALANCE_TYPE_CODE
    ,PERIOD_NAME
    )
    VALUES
    (
     p_ae_header_id
    ,p_application_id
    ,p_ledger_id
    ,p_entity_id
    ,p_event_id
    ,p_event_type_code
    ,p_accounting_date
    ,p_gl_transfer_status_code
    ,p_je_category_name
    ,p_accounting_entry_status_code
    ,p_accounting_entry_type_code
    ,l_date
    ,l_user_id
    ,l_date
    ,l_user_id
    ,p_balance_type_code
    ,p_period_name
    );

    INSERT INTO xla_ae_lines
    (
     AE_HEADER_ID
    ,AE_LINE_NUM
    ,CODE_COMBINATION_ID
    ,CREATION_DATE
    ,ACCOUNTED_DR
    ,ACCOUNTED_CR
    ,CURRENCY_CODE
    ,ENTERED_DR
    ,ENTERED_CR
    ,LAST_UPDATE_DATE
    ,PARTY_ID
    ,PARTY_SITE_ID
    ,PARTY_TYPE_CODE
    ,CREATED_BY
    ,LAST_UPDATED_BY
    ,CONTROL_BALANCE_FLAG
    ,ANALYTICAL_BALANCE_FLAG
    ,APPLICATION_ID
    ,LEDGER_ID              --5067260
    ,ACCOUNTING_DATE        --5067260
    ,GL_SL_LINK_ID          --5041325
    )
    VALUES
    (
     p_ae_header_id
    ,p_ae_line_num
    ,p_code_combination_id
    ,l_date
    ,p_accounted_dr
    ,p_accounted_cr
    ,p_currency_code
    ,p_entered_dr
    ,p_entered_cr
    ,l_date
    ,p_party_id
    ,p_party_site_id
    ,p_party_type_code
    ,l_user_id
    ,l_user_id
    ,p_control_balance_flag
    ,p_analytical_balance_flag
    ,p_application_id
    ,p_ledger_id
    ,p_accounting_date
    ,DECODE(p_accounting_entry_status_code,'F'
           ,xla_gl_sl_link_id_s.nextval,NULL)  --5041325
    );

ELSIF p_mode = 'D'
THEN
   DELETE
     FROM xla_ae_lines xal
    WHERE xal.ae_header_id = p_ae_header_id;

   DELETE
     FROM xla_ae_headers xah
    WHERE xah.ae_header_id = p_ae_header_id;

ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'Invalid p_mode: ' || p_mode
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
                  (p_location => 'xla_balances_pkg.handle_fake_journal_entry');
END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.handle_fake_journal_entry');
END handle_fake_journal_entry;


FUNCTION initialize
  ( p_application_id             IN INTEGER
   ,p_ledger_id                  IN INTEGER
   ,p_code_combination_id        IN INTEGER
   ,p_party_type_code            IN VARCHAR2
   ,p_party_id                   IN INTEGER
   ,p_party_site_id              IN INTEGER
   ,p_period_name                IN VARCHAR2
   ,p_new_beginning_balance_dr   IN NUMBER
   ,p_new_beginning_balance_cr   IN NUMBER
  ) RETURN BOOLEAN
IS
l_effective_period_num         INTEGER;
l_first_entry_eff_period_num   INTEGER;
l_ledger_id                    INTEGER;
l_ledger_currency_code         VARCHAR2(15);
l_application_id               INTEGER;
l_period_start_date            DATE;
l_ae_header_id                 INTEGER;

l_existing_balance_rowid       UROWID;
l_existing_balance_period_name VARCHAR2(15);
l_existing_begin_balance_dr    NUMBER;
l_existing_begin_balance_cr    NUMBER;
l_new_balance_debit_dr         NUMBER;
l_new_balance_debit_cr         NUMBER;

l_user_id                      INTEGER;
l_login_id                     INTEGER;
l_date                         DATE;
l_prog_appl_id                 INTEGER;
l_prog_id                      INTEGER;
l_req_id                       INTEGER;

l_row_count                 NUMBER;

l_log_module                 VARCHAR2 (2000);

BEGIN

   l_user_id                      := xla_environment_pkg.g_usr_id;
   l_login_id                     := xla_environment_pkg.g_login_id;
   l_date                         := SYSDATE;
   l_prog_appl_id                 := xla_environment_pkg.g_prog_appl_id;
   l_prog_id                      := xla_environment_pkg.g_prog_id;
   l_req_id                       := xla_environment_pkg.g_req_id;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.initialize';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   SELECT gll.currency_code
     INTO l_ledger_currency_code
     FROM gl_ledgers gll
    WHERE gll.ledger_id = p_ledger_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'Currency code : ' || l_ledger_currency_code
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   SELECT gps.effective_period_num
         ,gps.start_date
     INTO l_effective_period_num
         ,l_period_start_date
     FROM gl_period_statuses gps
    WHERE gps.ledger_id      = p_ledger_id
      AND gps.period_name    = p_period_name
      AND gps.application_id = 101;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'Effective period num: ' || l_effective_period_num
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         (p_module => l_log_module
         ,p_msg   => 'Period start date: ' || l_period_start_date
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   SELECT xls.application_id
     INTO l_application_id
     FROM xla_subledgers xls
    WHERE xls.application_id = p_application_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'Application id: ' || l_application_id
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   SELECT xll.ledger_id
     INTO l_ledger_id
     FROM xla_gl_ledgers_v xll
    WHERE xll.ledger_id = p_ledger_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg   => 'Ledger id: ' || l_ledger_id
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;


   IF p_party_type_code IS NULL
   OR p_party_id        IS NULL
   OR p_party_site_id   IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'Party information cannot be NULL.'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
                  (p_location => 'xla_balances_pkg.initialize');
   END IF;

   IF p_new_beginning_balance_dr IS NULL
   AND p_new_beginning_balance_cr IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'p_beginning_balance_dr and p_beginning_balance_cr cannot be both NULL'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
                  (p_location => 'xla_balances_pkg.initialize');
   END IF;

   IF xla_control_accounts_pkg.C_IS_CONTROL_ACCOUNT
      = xla_control_accounts_pkg.is_control_account
              ( p_code_combination_id => p_code_combination_id
               ,p_natural_account     => NULL
               ,p_ledger_id           => p_ledger_id
               ,p_application_id      => p_application_id
              )
   THEN
      RETURN FALSE;
   END IF;

   SELECT MIN(gps.effective_period_num)
     INTO l_first_entry_eff_period_num
     FROM gl_period_statuses gps
         ,xla_ae_headers xah
         ,xla_ae_lines   xal
    WHERE gps.ledger_id           = p_ledger_id
      AND gps.application_id      = 101
      AND gps.period_name         = xah.period_name
      AND xah.ledger_id           = p_ledger_id
      AND xah.application_id      = p_application_id
      AND xal.ae_header_id        = xah.ae_header_id
      AND xal.code_combination_id = p_code_combination_id
      AND xal.party_type_code     = p_party_type_code
      AND xal.party_id            = p_party_id
      AND NVL(xal.party_site_id,-999)= p_party_site_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'First entry in period: '
                        || l_first_entry_eff_period_num
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF l_first_entry_eff_period_num IS NOT NULL
   AND l_first_entry_eff_period_num <= l_effective_period_num
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'Entry exist before or on the initialization period'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
                  (p_location => 'xla_balances_pkg.initialize');
   END IF;

   BEGIN
      SELECT xba.period_name
            ,xba.beginning_balance_dr
            ,xba.beginning_balance_cr
            ,xba.rowid
        INTO l_existing_balance_period_name
            ,l_existing_begin_balance_dr
            ,l_existing_begin_balance_cr
            ,l_existing_balance_rowid
        FROM xla_control_balances xba
       WHERE xba.ledger_id            = p_ledger_id
         AND xba.application_id       = p_application_id
         AND xba.code_combination_id  = p_code_combination_id
         AND xba.initial_balance_flag = 'Y'
         AND xba.party_type_code      = p_party_type_code
         AND xba.party_id             = p_party_id
         AND xba.party_site_id        = p_party_site_id;
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   WHEN OTHERS
   THEN
      RAISE;
   END;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'Balance rowid: ' || l_existing_balance_rowid
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF l_existing_balance_rowid IS NOT NULL
   THEN
      IF l_existing_balance_period_name <> p_period_name
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'A initialization balance already exists for these key for period ' ||
                         l_existing_balance_period_name
              ,p_level => C_LEVEL_EXCEPTION
            );
         END IF;
         xla_exceptions_pkg.raise_message
            (p_location => 'xla_balances_pkg.initialize');
      END IF;

      UPDATE xla_control_balances xba
         SET xba.initial_balance_flag = 'N'
       WHERE xba.rowid = l_existing_balance_rowid;

      l_row_count := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => l_row_count || ' balances updated '
         ,p_level    => C_LEVEL_STATEMENT);
      END IF;

   END IF;

   SELECT xla_ae_headers_s.nextval
     INTO l_ae_header_id
     FROM DUAL;

   --Create fake entries
   handle_fake_journal_entry
           ( p_mode                            => 'A'
            ,p_ae_header_id                    => l_ae_header_id
            ,p_application_id                  => p_application_id
            ,p_ledger_id                       => p_ledger_id
            ,p_entity_id                       => -1
            ,p_event_id                        => -1
            ,p_event_type_code                 => 'EVENT_TYPE_CODE'
            ,p_accounting_date                 => l_period_start_date
            ,p_gl_transfer_status_code         => 'T'
            ,p_je_category_name                => 'JE_CATEGORY'
            ,p_accounting_entry_status_code    => 'F'
            ,p_accounting_entry_type_code      => 'A'
            ,p_balance_type_code               => 'A'
            ,p_period_name                     => p_period_name
            ,p_ae_line_num                     => 1
            ,p_code_combination_id             => p_code_combination_id
            ,p_accounted_dr                    => NVL(p_new_beginning_balance_dr   , 0)
                                                  - NVL(l_existing_begin_balance_dr, 0)
            ,p_accounted_cr                    => NVL(p_new_beginning_balance_cr, 0)
                                                  - NVL(l_existing_begin_balance_cr, 0)
            ,p_currency_code                   => l_ledger_currency_code
            ,p_entered_dr                      => NULL
            ,p_entered_cr                      => NULL
            ,p_party_id                        => p_party_id
            ,p_party_site_id                   => p_party_site_id
            ,p_party_type_code                 => p_party_type_code
            ,p_control_balance_flag            => 'P'
            ,p_analytical_balance_flag         => NULL
           );


   --Update the balances
   IF NOT calculate_balances
            ( p_application_id             => p_application_id
             ,p_ledger_id                  => p_ledger_id
             ,p_entity_id                  => NULL
             ,p_event_id                   => NULL
             ,p_request_id                 => NULL
             ,p_accounting_batch_id        => NULL
             ,p_ae_header_id               => -1
             ,p_ae_line_num                => 1
             ,p_code_combination_id        => NULL
             ,p_period_name                => NULL
             ,p_update_mode                => 'A'
             ,p_balance_source_code        => 'C'
             ,p_called_by_flag             => NULL
             ,p_commit_flag                => 'N'
            )
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION:' ||
'Failure propagating the initial balance'
              ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
                  (p_location => 'xla_balances_pkg.initialize');
   END IF;

   --Delete fake entries
   handle_fake_journal_entry
           ( p_mode                 => 'D'
            ,p_ae_header_id         => l_ae_header_id
           );

   UPDATE xla_control_balances xba
      SET xba.beginning_balance_dr = xba.beginning_balance_dr + xba.period_balance_dr
         ,xba.beginning_balance_cr = xba.beginning_balance_cr + xba.period_balance_cr
         ,xba.period_balance_dr    = 0
         ,xba.period_balance_cr    = 0
         ,xba.initial_balance_flag = 'Y'
         ,xba.first_period_flag    = 'Y'
    WHERE xba.ledger_id            = p_ledger_id
      AND xba.application_id       = p_application_id
      AND xba.code_combination_id  = p_code_combination_id
      AND xba.initial_balance_flag = 'N'
      AND xba.party_type_code      = p_party_type_code
      AND xba.party_id             = p_party_id
      AND xba.party_site_id        = p_party_site_id
      AND xba.period_name          = p_period_name;

   l_row_count := SQL%ROWCOUNT;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => l_row_count || ' balances udpated '
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_balances_pkg.initialize');
END initialize;

FUNCTION open_period_event ( p_subscription_guid IN     raw
                            ,p_event             IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2 IS
l_parameter_list wf_parameter_list_t;
l_ledger_id number;
l_period_name varchar2(100);
l_log_module  VARCHAR2(240);
l_request_id number;
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.open_period_event';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure open_period_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  -- get the parameter of the event
  l_parameter_list := p_event.getParameterList;
  l_period_name:=wf_event.getValueForParameter('PERIOD_NAME', l_parameter_list);
  l_ledger_id:=to_number(wf_event.getValueForParameter('LEDGER_ID', l_parameter_list));

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
    trace
         (p_msg      => 'period_name:'|| l_period_name
                                   || ' ledger_id:'||to_char(l_ledger_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  l_request_id := fnd_request.submit_request
                ( application => 'XLA'
                 ,program     => 'XLABAOPE'
                 ,description => 'Open Period Balances'
                 ,argument1   => l_ledger_id
                );

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
    trace
         (p_msg      => 'l_request_id = '||l_request_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  IF l_request_id = 0 THEN
    xla_exceptions_pkg.raise_message
        (p_appli_s_name   => 'XLA'
        ,p_msg_name       => 'XLA_REP_TECHNICAL_ERROR'
        ,p_token_1        => 'APPLICATION_NAME'
        ,p_value_1        => 'SLA');

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'END of procedure open_period_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  RETURN 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
   RETURN 'ERROR';
END;

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

   g_user_id            := xla_environment_pkg.g_usr_id;
   g_login_id           := xla_environment_pkg.g_login_id;
   g_date               := SYSDATE;
   g_prog_appl_id       := xla_environment_pkg.g_prog_appl_id;
   g_prog_id            := xla_environment_pkg.g_prog_id;
   g_req_id             := NVL(xla_environment_pkg.g_req_id, -1);

   g_cached_single_period    := FALSE;
END xla_balances_pkg;

/
