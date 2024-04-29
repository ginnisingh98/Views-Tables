--------------------------------------------------------
--  DDL for Package Body XLA_AC_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AC_BALANCES_PKG" AS
/* $Header: xlaacbal.pkb 120.3 2008/02/07 03:19:13 veramach noship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_ac_balances_pkg                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Account Balances Package                                       |
|                                                                       |
| HISTORY                                                               |
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
   -- Global variables
   --
   g_user_id                 INTEGER;
   g_login_id                INTEGER;
   g_date                    DATE;
   g_prog_appl_id            INTEGER;
   g_prog_id                 INTEGER;
   g_req_id                  INTEGER;


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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_ac_balances_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

--1-STATEMENT, 2-PROCEDURE, 3-EVENT, 4-EXCEPTION, 5-ERROR, 6-UNEXPECTED
CANT_DELETE_BALANCES EXCEPTION;

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
         (p_location   => 'xla_ac_balances_pkg.trace');
END trace;

FUNCTION call_update_balances RETURN BOOLEAN IS

 l_batch_code VARCHAR2(100) := p_batch_code;
 l_purge_mode VARCHAR2(1) := p_purge_mode;
BEGIN
 update_balances(l_batch_code,l_purge_mode);
 RETURN TRUE;
END call_update_balances;

FUNCTION call_purge_interface_recs RETURN BOOLEAN IS

 l_batch_code VARCHAR2(100) := p_batch_code;
 l_purge_mode VARCHAR2(1) := p_purge_mode;
BEGIN
 purge_interface_recs(l_batch_code,l_purge_mode);
 RETURN TRUE;
END call_purge_interface_recs;

FUNCTION get_period_year(
  p_period_name   gl_period_statuses.period_name%TYPE
)
  RETURN VARCHAR2 AS
------------------------------------------------------------------
--Created by  : veramach, Oracle India
--Date created: 29-Nov-2007
--
--Purpose:
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------
  CURSOR c_get_period(
    cp_period_name   gl_period_statuses.period_name%TYPE
  ) IS
    SELECT gps.period_year
      FROM gl_period_statuses gps,
           xla_ac_balances_int bal
     WHERE gps.ledger_id = bal.ledger_id
       AND gps.application_id = bal.application_id
       AND gps.adjustment_period_flag = 'N'
       AND gps.period_name = cp_period_name;

  l_period_year   gl_period_statuses.period_year%TYPE;
BEGIN
  OPEN c_get_period(p_period_name);
  FETCH c_get_period INTO l_period_year;
  CLOSE c_get_period;

  RETURN l_period_year;
END get_period_year;

PROCEDURE insert_balances_rec(
  p_ac_balance_int_rec   xla_ac_balances%ROWTYPE
) IS
  l_log_module    VARCHAR2(240);
  l_period_year                 gl_period_statuses.period_year%TYPE;
  l_row_count     NUMBER;
BEGIN
  IF g_log_enabled THEN
    l_log_module := c_default_module || '.insert';
  END IF;

  IF (c_level_procedure >= g_log_level) THEN
    TRACE(p_msg                        => 'BEGIN of function insert',
          p_module                     => l_log_module,
          p_level                      => c_level_procedure
         );
  END IF;

  l_period_year := get_period_year(p_ac_balance_int_rec.period_name);

  INSERT INTO xla_ac_balances
              (application_id,
               ledger_id,
               code_combination_id,
               analytical_criterion_code,
               analytical_criterion_type_code,
               amb_context_code,
               ac1,
               ac2,
               ac3,
               ac4,
               ac5,
               period_name,
               beginning_balance_dr,
               beginning_balance_cr,
               period_balance_dr,
               period_balance_cr,
               initial_balance_flag,
               first_period_flag,
               period_year,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               program_update_date,
               program_application_id,
               program_id,
               request_id
              )
       VALUES (p_ac_balance_int_rec.application_id,
               p_ac_balance_int_rec.ledger_id,
               p_ac_balance_int_rec.code_combination_id,
               p_ac_balance_int_rec.analytical_criterion_code,
               p_ac_balance_int_rec.analytical_criterion_type_code,
               p_ac_balance_int_rec.amb_context_code,
               p_ac_balance_int_rec.ac1,
               p_ac_balance_int_rec.ac2,
               p_ac_balance_int_rec.ac3,
               p_ac_balance_int_rec.ac4,
               p_ac_balance_int_rec.ac5,
               p_ac_balance_int_rec.period_name,
               p_ac_balance_int_rec.beginning_balance_dr,
               p_ac_balance_int_rec.beginning_balance_cr,
               p_ac_balance_int_rec.period_balance_dr,
               p_ac_balance_int_rec.period_balance_cr,
               p_ac_balance_int_rec.initial_balance_flag,
               p_ac_balance_int_rec.first_period_flag,
               l_period_year,
               g_date,
               g_user_id,
               g_date,
               g_user_id,
               g_login_id,
               g_date,
               g_prog_appl_id,
               g_prog_id,
               g_req_id
              );
  l_row_count := SQL%ROWCOUNT;
  IF (c_level_statement >= g_log_level) THEN
    TRACE(p_module                     => l_log_module,
          p_msg                        => l_row_count || ' initial balances inserted',
          p_level                      => c_level_statement
         );
  END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_ac_balances_pkg.insert_balances_rec');
END insert_balances_rec;

PROCEDURE update_balances_rec(
  p_ac_balance_int_rec   xla_ac_balances%ROWTYPE
) IS
  l_log_module                  VARCHAR2(240);
  l_period_year                 gl_period_statuses.period_year%TYPE;
  l_row_count     NUMBER;
BEGIN
  IF g_log_enabled THEN
    l_log_module := c_default_module || '.update_balances_rec';
  END IF;

  IF (c_level_procedure >= g_log_level) THEN
    TRACE(p_msg                        => 'BEGIN of function update_balances_rec',
          p_module                     => l_log_module,
          p_level                      => c_level_procedure
         );
  END IF;

  UPDATE xla_ac_balances
     SET period_name = p_ac_balance_int_rec.period_name,
         beginning_balance_dr = p_ac_balance_int_rec.beginning_balance_dr,
         beginning_balance_cr = p_ac_balance_int_rec.beginning_balance_cr,
         initial_balance_flag = p_ac_balance_int_rec.initial_balance_flag,
         first_period_flag = p_ac_balance_int_rec.first_period_flag,
         period_year = p_ac_balance_int_rec.period_year,
         last_update_date = g_date,
         program_update_date = g_date,
         last_updated_by = g_user_id,
         last_update_login = g_login_id,
         program_application_id = g_prog_appl_id,
         program_id = g_prog_id,
         request_id = g_req_id
   WHERE application_id = p_ac_balance_int_rec.application_id
     AND ledger_id = p_ac_balance_int_rec.ledger_id
     AND code_combination_id = p_ac_balance_int_rec.code_combination_id
     AND analytical_criterion_code = p_ac_balance_int_rec.analytical_criterion_code
     AND analytical_criterion_type_code = p_ac_balance_int_rec.analytical_criterion_type_code
     AND amb_context_code = p_ac_balance_int_rec.amb_context_code
     AND period_name = p_ac_balance_int_rec.period_name
     AND NVL(ac1,'*') = NVL(p_ac_balance_int_rec.ac1,'*')
     AND NVL(ac2,'*') = NVL(p_ac_balance_int_rec.ac2,'*')
     AND NVL(ac3,'*') = NVL(p_ac_balance_int_rec.ac3,'*')
     AND NVL(ac4,'*') = NVL(p_ac_balance_int_rec.ac4,'*')
     AND NVL(ac5,'*') = NVL(p_ac_balance_int_rec.ac5,'*');
  l_row_count := SQL%ROWCOUNT;
  IF (c_level_statement >= g_log_level) THEN
    TRACE(p_module                     => l_log_module,
          p_msg                        => l_row_count || ' initial balances updated',
          p_level                      => c_level_statement
         );
  END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_ac_balances_pkg.update_balances_rec');
END update_balances_rec;

PROCEDURE delete_balances_rec(
  p_ac_balance_int_rec   xla_ac_balances%ROWTYPE
) IS
  l_log_module                  VARCHAR2(240);
  l_period_year                 gl_period_statuses.period_year%TYPE;
  l_row_count     NUMBER;
BEGIN
  IF g_log_enabled THEN
    l_log_module := c_default_module || '.delete_balances_rec';
  END IF;

  IF (c_level_procedure >= g_log_level) THEN
    TRACE(p_msg                        => 'BEGIN of function delete_balances_rec',
          p_module                     => l_log_module,
          p_level                      => c_level_procedure
         );
  END IF;

  DELETE xla_ac_balances xab
   WHERE xab.application_id = p_ac_balance_int_rec.application_id
     AND xab.ledger_id = p_ac_balance_int_rec.ledger_id
     AND xab.code_combination_id = p_ac_balance_int_rec.code_combination_id
     AND xab.analytical_criterion_code = p_ac_balance_int_rec.analytical_criterion_code
     AND xab.analytical_criterion_type_code = p_ac_balance_int_rec.analytical_criterion_type_code
     AND xab.amb_context_code = p_ac_balance_int_rec.amb_context_code
     AND NVL(xab.ac1,'*') = NVL(p_ac_balance_int_rec.ac1,'*')
     AND NVL(xab.ac2,'*') = NVL(p_ac_balance_int_rec.ac2,'*')
     AND NVL(xab.ac3,'*') = NVL(p_ac_balance_int_rec.ac3,'*')
     AND NVL(xab.ac4,'*') = NVL(p_ac_balance_int_rec.ac4,'*')
     AND NVL(xab.ac5,'*') = NVL(p_ac_balance_int_rec.ac5,'*')
     AND xab.period_name = p_ac_balance_int_rec.period_name;
  l_row_count := SQL%ROWCOUNT;


  IF (c_level_statement >= g_log_level) THEN
    TRACE(p_module                     => l_log_module,
          p_msg                        => l_row_count || ' initial balances deleted',
          p_level                      => c_level_statement
         );
  END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_ac_balances_pkg.delete_balances_rec');
END delete_balances_rec;

PROCEDURE merge_balances_rec
          ( p_ac_balance_int_rec  IN         xla_ac_balances_int%ROWTYPE
          )
IS

l_log_module                 VARCHAR2 (2000);

-- Get existing balance
CURSOR c_exist_balance(
                       cp_ledger_id                 xla_ac_balances.ledger_id%TYPE,
                       cp_code_combination_id       xla_ac_balances.code_combination_id%TYPE,
                       cp_analytical_criterion_code xla_ac_balances.analytical_criterion_code%TYPE,
                       cp_criterion_type_code       xla_ac_balances.analytical_criterion_type_code%TYPE,
                       cp_amb_context_code          xla_ac_balances.amb_context_code%TYPE,
                       cp_ac1                       xla_ac_balances.ac1%TYPE,
                       cp_ac2                       xla_ac_balances.ac2%TYPE,
                       cp_ac3                       xla_ac_balances.ac3%TYPE,
                       cp_ac4                       xla_ac_balances.ac4%TYPE,
                       cp_ac5                       xla_ac_balances.ac5%TYPE,
                       cp_period_name               xla_ac_balances.period_name%TYPE
                      ) IS
  SELECT xab.*
    FROM xla_ac_balances xab
   WHERE xab.ledger_id = cp_ledger_id
     AND xab.code_combination_id = cp_code_combination_id
     AND xab.analytical_criterion_code = cp_analytical_criterion_code
     AND xab.analytical_criterion_type_code = cp_criterion_type_code
     AND xab.amb_context_code = cp_amb_context_code
     AND xab.period_name = cp_period_name
     AND NVL(xab.ac1,'*') = NVL(cp_ac1,'*')
     AND NVL(xab.ac2,'*') = NVL(cp_ac2,'*')
     AND NVL(xab.ac3,'*') = NVL(cp_ac3,'*')
     AND NVL(xab.ac4,'*') = NVL(cp_ac4,'*')
     AND NVL(xab.ac5,'*') = NVL(cp_ac5,'*');
l_exist_balance xla_ac_balances%ROWTYPE;

l_balances_rec xla_ac_balances%ROWTYPE;

-- Get subsequent periods
CURSOR c_subsequent_periods(
                      cp_application_id            xla_ac_balances.application_id%TYPE,
                      cp_ledger_id                 xla_ac_balances.ledger_id%TYPE,
                      cp_code_combination_id       xla_ac_balances.code_combination_id%TYPE,
                      cp_analytical_criterion_code xla_ac_balances.analytical_criterion_code%TYPE,
                      cp_criterion_type_code       xla_ac_balances.analytical_criterion_type_code%TYPE,
                      cp_amb_context_code          xla_ac_balances.amb_context_code%TYPE,
                      cp_ac1                       xla_ac_balances.ac1%TYPE,
                      cp_ac2                       xla_ac_balances.ac2%TYPE,
                      cp_ac3                       xla_ac_balances.ac3%TYPE,
                      cp_ac4                       xla_ac_balances.ac4%TYPE,
                      cp_ac5                       xla_ac_balances.ac5%TYPE,
                      cp_period_year               xla_ac_balances.period_year%TYPE,
                      cp_period_name               xla_ac_balances.period_name%TYPE
                     ) IS
SELECT xab.*
  FROM xla_ac_balances xab,
       gl_ledgers ledger,
       gl_periods fut_periods,
       gl_period_types period_types,
       gl_period_statuses fut_period_statuses,
       gl_period_sets period_sets
 WHERE ledger.accounted_period_type = period_types.period_type
   AND period_types.period_type = fut_periods.period_type
   AND fut_period_statuses.ledger_id = ledger.ledger_id
   AND fut_period_statuses.period_name = fut_periods.period_name
   AND fut_period_statuses.period_type = period_types.period_type
   AND fut_period_statuses.closing_status IN('O','C','F')
   AND fut_period_statuses.adjustment_period_flag = 'N'
   AND fut_period_statuses.period_type = period_types.period_type
   AND fut_period_statuses.period_name = fut_periods.period_name
   AND period_sets.period_set_name = fut_periods.period_set_name
   AND ledger.period_set_name = period_sets.period_set_name
   AND ledger.accounted_period_type = period_types.period_type
   AND ledger.ledger_id = cp_ledger_id
   AND fut_period_statuses.application_id = cp_application_id
   AND xab.ledger_id = ledger.ledger_id
   AND fut_periods.period_name = xab.period_name
   AND xab.ledger_id = cp_ledger_id
   AND xab.code_combination_id = cp_code_combination_id
   AND xab.analytical_criterion_code = cp_analytical_criterion_code
   AND xab.analytical_criterion_type_code = cp_criterion_type_code
   AND xab.amb_context_code = cp_amb_context_code
   AND NVL(xab.ac1,'*') = NVL(cp_ac1,'*')
   AND NVL(xab.ac2,'*') = NVL(cp_ac2,'*')
   AND NVL(xab.ac3,'*') = NVL(cp_ac3,'*')
   AND NVL(xab.ac4,'*') = NVL(cp_ac4,'*')
   AND NVL(xab.ac5,'*') = NVL(cp_ac5,'*')
   AND xab.period_year = NVL(cp_period_year,xab.period_year)
   AND xab.period_name <> cp_period_name
   ORDER BY fut_periods.start_date;
l_subsequent_periods xla_ac_balances%ROWTYPE;

l_delta_cr NUMBER := NULL;
l_delta_dr NUMBER := NULL;

-- Get supporting referehnce header
CURSOR c_sup_ref_hdr (
  cp_amb_context_code          xla_ac_balances.amb_context_code%TYPE,
  cp_analytical_criterion_code xla_ac_balances.analytical_criterion_code%TYPE,
  cp_criterion_type_code       xla_ac_balances.analytical_criterion_type_code%TYPE
 ) IS
  SELECT NVL(xah.balancing_flag,'N') balancing_flag,
         xah.year_end_carry_forward_code
    FROM xla_analytical_hdrs_b xah
   WHERE xah.amb_context_code               = cp_amb_context_code
     AND xah.analytical_criterion_code      = cp_analytical_criterion_code
     AND xah.analytical_criterion_type_code = cp_criterion_type_code;
l_sup_ref_hdr c_sup_ref_hdr%ROWTYPE;

l_period_year xla_ac_balances.period_year%TYPE := NULL;

-- Get current period end date
CURSOR c_current_period_end_date(
  cp_ledger_id      gl_ledgers.ledger_id%TYPE,
  cp_application_id gl_period_statuses.application_id%TYPE,
  cp_period_name    gl_periods.period_name%TYPE,
  cp_period_year    gl_periods.period_year%TYPE
  ) IS
SELECT periods.end_date
  FROM gl_ledgers ledger,
       gl_periods periods,
       gl_period_types period_types,
       gl_period_statuses period_statuses,
       gl_period_sets period_sets
 WHERE ledger.accounted_period_type = period_types.period_type
   AND period_types.period_type = periods.period_type
   AND period_statuses.ledger_id = ledger.ledger_id
   AND period_statuses.period_name = periods.period_name
   AND period_statuses.period_type = period_types.period_type
   --AND period_statuses.closing_status IN('O', 'C', 'P')
   AND period_statuses.adjustment_period_flag = 'N'
   AND period_statuses.period_type = period_types.period_type
   AND period_statuses.period_name = periods.period_name
   AND period_sets.period_set_name = periods.period_set_name
   AND ledger.period_set_name = period_sets.period_set_name
   AND ledger.accounted_period_type = period_types.period_type
   AND ledger.ledger_id = cp_ledger_id
   AND period_statuses.application_id = cp_application_id
   AND periods.period_year = NVL(cp_period_year, periods.period_year)
   AND periods.period_name = cp_period_name;

-- Get next period's start date
CURSOR c_next_period_start_date(
                       cp_application_id            xla_ac_balances.application_id%TYPE,
                       cp_ledger_id                 xla_ac_balances.ledger_id%TYPE,
                       cp_code_combination_id       xla_ac_balances.code_combination_id%TYPE,
                       cp_analytical_criterion_code xla_ac_balances.analytical_criterion_code%TYPE,
                       cp_criterion_type_code       xla_ac_balances.analytical_criterion_type_code%TYPE,
                       cp_amb_context_code          xla_ac_balances.amb_context_code%TYPE,
                       cp_ac1                       xla_ac_balances.ac1%TYPE,
                       cp_ac2                       xla_ac_balances.ac2%TYPE,
                       cp_ac3                       xla_ac_balances.ac3%TYPE,
                       cp_ac4                       xla_ac_balances.ac4%TYPE,
                       cp_ac5                       xla_ac_balances.ac5%TYPE,
                       cp_period_year               xla_ac_balances.period_year%TYPE,
                       cp_period_name               xla_ac_balances.period_name%TYPE
          ) IS
  SELECT periods.start_date
    FROM xla_ac_balances xab,
         gl_ledgers ledger,
         gl_periods periods,
         gl_period_types period_types,
         gl_period_statuses period_statuses,
         gl_period_sets period_sets
   WHERE ledger.accounted_period_type = period_types.period_type
     AND period_types.period_type = periods.period_type
     AND period_statuses.ledger_id = ledger.ledger_id
     AND period_statuses.period_name = periods.period_name
     AND period_statuses.period_type = period_types.period_type
     AND period_statuses.adjustment_period_flag = 'N'
     AND period_statuses.period_type = period_types.period_type
     AND period_statuses.period_name = periods.period_name
     AND period_sets.period_set_name = periods.period_set_name
     AND ledger.period_set_name = period_sets.period_set_name
     AND ledger.accounted_period_type = period_types.period_type
     AND ledger.ledger_id = cp_ledger_id
     AND periods.period_year = NVL(cp_period_year, periods.period_year)
     AND xab.ledger_id = ledger.ledger_id
     AND periods.period_name = xab.period_name
     AND xab.ledger_id = cp_ledger_id
     AND xab.code_combination_id = cp_code_combination_id
     AND xab.analytical_criterion_code = cp_analytical_criterion_code
     AND xab.analytical_criterion_type_code = cp_criterion_type_code
     AND xab.amb_context_code = cp_amb_context_code
     AND period_statuses.application_id = cp_application_id
     AND NVL(xab.ac1,'*') = NVL(cp_ac1,'*')
     AND NVL(xab.ac2,'*') = NVL(cp_ac2,'*')
     AND NVL(xab.ac3,'*') = NVL(cp_ac3,'*')
     AND NVL(xab.ac4,'*') = NVL(cp_ac4,'*')
     AND NVL(xab.ac5,'*') = NVL(cp_ac5,'*')
     AND xab.period_name <> cp_period_name
ORDER BY periods.start_date;

l_current_period_end_date DATE;
l_next_period_start_date  DATE;
l_synchronize_fut_periods BOOLEAN;

-- Get future periods
CURSOR c_future_periods(
                       cp_application_id            xla_ac_balances.application_id%TYPE,
                       cp_ledger_id                 xla_ac_balances.ledger_id%TYPE,
                       cp_period_year               xla_ac_balances.period_year%TYPE,
                       cp_earliest_start_date       DATE,
                       cp_latest_end_date           DATE
          ) IS
SELECT fut_periods.period_name,
       fut_periods.period_year,
       fut_periods.period_num
  FROM gl_ledgers ledger,
       gl_periods fut_periods,
       gl_period_types period_types,
       gl_period_statuses fut_period_statuses,
       gl_period_sets period_sets
 WHERE ledger.accounted_period_type = period_types.period_type
   AND period_types.period_type = fut_periods.period_type
   AND fut_period_statuses.ledger_id = ledger.ledger_id
   AND fut_period_statuses.period_name = fut_periods.period_name
   AND fut_period_statuses.period_type = period_types.period_type
   AND fut_period_statuses.adjustment_period_flag = 'N'
   AND fut_period_statuses.period_type = period_types.period_type
   AND fut_period_statuses.period_name = fut_periods.period_name
   AND period_sets.period_set_name = fut_periods.period_set_name
   AND ledger.period_set_name = period_sets.period_set_name
   AND ledger.accounted_period_type = period_types.period_type
   AND ledger.ledger_id = cp_ledger_id
   AND fut_period_statuses.application_id = cp_application_id
   AND fut_periods.period_year = NVL(cp_period_year, fut_periods.period_year)
   AND fut_periods.start_date > cp_earliest_start_date
   AND fut_periods.end_date < cp_latest_end_date;

-- Get account type for a ccid
CURSOR c_account_type(
  cp_cc_id gl_code_combinations.code_combination_id%TYPE
          ) IS
  SELECT account_type
    FROM gl_code_combinations
   WHERE code_combination_id = cp_cc_id;
l_account_type gl_code_combinations.account_type%TYPE;

-- Get period num
CURSOR c_period_num(
  cp_application_id gl_ledgers.ledger_id%TYPE,
  cp_period_name    gl_periods.period_name%TYPE
          ) IS
SELECT periods.period_num
  FROM gl_periods periods,
       gl_ledgers ledger
 WHERE ledger.ledger_id = cp_application_id
   AND ledger.period_set_name = periods.period_set_name
   AND periods.period_name = cp_period_name;
l_period_num gl_periods.period_num%TYPE;


CURSOR c_future_open_periods(
                             cp_application_id xla_ac_balances.application_id%TYPE,
                             cp_ledger_id      gl_ledgers.ledger_id%TYPE,
                             cp_period_name    gl_periods.period_name%TYPE,
                             cp_period_year    gl_periods.period_year%TYPE
                            ) IS
  SELECT fut_periods.period_name,
         fut_periods.period_num
    FROM gl_ledgers ledger,
         gl_periods fut_periods,
         gl_period_types period_types,
         gl_period_statuses fut_period_statuses,
         gl_period_sets period_sets,
         gl_periods ref_period
   WHERE ledger.accounted_period_type = period_types.period_type
     AND period_types.period_type = fut_periods.period_type
     AND fut_period_statuses.ledger_id = ledger.ledger_id
     AND fut_period_statuses.period_name = fut_periods.period_name
     AND fut_period_statuses.period_type = period_types.period_type
     AND fut_period_statuses.closing_status IN('O', 'F')
     AND fut_period_statuses.adjustment_period_flag = 'N'
     AND fut_period_statuses.period_type = period_types.period_type
     AND fut_period_statuses.period_name = fut_periods.period_name
     AND period_sets.period_set_name = fut_periods.period_set_name
     AND ledger.period_set_name = period_sets.period_set_name
     AND ledger.accounted_period_type = period_types.period_type
     AND ledger.ledger_id = cp_ledger_id
     AND fut_period_statuses.application_id = cp_application_id
     AND fut_periods.period_year = NVL(cp_period_year, fut_periods.period_year)
     AND ref_period.period_name = cp_period_name
     AND ref_period.period_type = period_types.period_type
     AND period_sets.period_set_name = ref_period.period_set_name
     AND ref_period.start_date < fut_periods.start_date;
l_future_open_periods c_future_open_periods%ROWTYPE;

CURSOR c_closed_periods(
                        cp_application_id xla_ac_balances.application_id%TYPE,
                        cp_ledger_id      gl_ledgers.ledger_id%TYPE,
                        cp_period_name    gl_periods.period_name%TYPE,
                        cp_period_year    gl_periods.period_year%TYPE
                       ) IS
  SELECT fut_periods.period_name,
         fut_periods.period_num
    FROM gl_ledgers ledger,
         gl_periods fut_periods,
         gl_period_types period_types,
         gl_period_statuses fut_period_statuses,
         gl_period_sets period_sets,
         gl_periods ref_period
   WHERE ledger.accounted_period_type = period_types.period_type
     AND period_types.period_type = fut_periods.period_type
     AND fut_period_statuses.ledger_id = ledger.ledger_id
     AND fut_period_statuses.period_name = fut_periods.period_name
     AND fut_period_statuses.period_type = period_types.period_type
     AND fut_period_statuses.closing_status = 'C'
     AND fut_period_statuses.adjustment_period_flag = 'N'
     AND fut_period_statuses.period_type = period_types.period_type
     AND fut_period_statuses.period_name = fut_periods.period_name
     AND period_sets.period_set_name = fut_periods.period_set_name
     AND ledger.period_set_name = period_sets.period_set_name
     AND ledger.accounted_period_type = period_types.period_type
     AND ledger.ledger_id = cp_ledger_id
     AND fut_period_statuses.application_id = cp_application_id
     AND fut_periods.period_year = NVL(cp_period_year, fut_periods.period_year)
     AND ref_period.period_name = cp_period_name
     AND ref_period.period_type = period_types.period_type
     AND period_sets.period_set_name = ref_period.period_set_name
     AND ref_period.start_date < fut_periods.start_date;

l_dr NUMBER;
l_cr NUMBER;

l_delete_cr_delta NUMBER;
l_delete_dr_delta NUMBER;

l_prev_year xla_ac_balances.period_year%TYPE;

CURSOR c_delete_records(
                       cp_application_id            xla_ac_balances.application_id%TYPE,
                       cp_ledger_id                 xla_ac_balances.ledger_id%TYPE,
                       cp_code_combination_id       xla_ac_balances.code_combination_id%TYPE,
                       cp_analytical_criterion_code xla_ac_balances.analytical_criterion_code%TYPE,
                       cp_criterion_type_code       xla_ac_balances.analytical_criterion_type_code%TYPE,
                       cp_amb_context_code          xla_ac_balances.amb_context_code%TYPE,
                       cp_ac1                       xla_ac_balances.ac1%TYPE,
                       cp_ac2                       xla_ac_balances.ac2%TYPE,
                       cp_ac3                       xla_ac_balances.ac3%TYPE,
                       cp_ac4                       xla_ac_balances.ac4%TYPE,
                       cp_ac5                       xla_ac_balances.ac5%TYPE,
                       cp_period_year               xla_ac_balances.period_year%TYPE
                      ) IS
  SELECT xab.*
    FROM xla_ac_balances xab,
         gl_ledgers ledger,
         gl_periods fut_periods,
         gl_period_types period_types,
         gl_period_statuses fut_period_statuses,
         gl_period_sets period_sets
   WHERE ledger.accounted_period_type = period_types.period_type
     AND period_types.period_type = fut_periods.period_type
     AND fut_period_statuses.ledger_id = ledger.ledger_id
     AND fut_period_statuses.period_name = fut_periods.period_name
     AND fut_period_statuses.period_type = period_types.period_type
     AND fut_period_statuses.adjustment_period_flag = 'N'
     AND fut_period_statuses.period_type = period_types.period_type
     AND fut_period_statuses.period_name = fut_periods.period_name
     AND period_sets.period_set_name = fut_periods.period_set_name
     AND ledger.period_set_name = period_sets.period_set_name
     AND ledger.accounted_period_type = period_types.period_type
     AND ledger.ledger_id = cp_ledger_id
     AND fut_period_statuses.application_id = cp_application_id
     AND xab.ledger_id = ledger.ledger_id
     AND fut_periods.period_name = xab.period_name
     AND xab.ledger_id = cp_ledger_id
     AND xab.code_combination_id = cp_code_combination_id
     AND xab.analytical_criterion_code = cp_analytical_criterion_code
     AND xab.analytical_criterion_type_code = cp_criterion_type_code
     AND xab.amb_context_code = cp_amb_context_code
     AND NVL(xab.ac1, '*') = NVL(cp_ac1, '*')
     AND NVL(xab.ac2, '*') = NVL(cp_ac2, '*')
     AND NVL(xab.ac3, '*') = NVL(cp_ac3, '*')
     AND NVL(xab.ac4, '*') = NVL(cp_ac4, '*')
     AND NVL(xab.ac5, '*') = NVL(cp_ac5, '*')
     AND fut_periods.period_year <> cp_period_year
ORDER BY fut_periods.start_date;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.merge_balances_rec';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg          => 'BEGIN ' || l_log_module
         ,p_level        => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_module => l_log_module,p_msg => 'batch_code :'|| p_ac_balance_int_rec.batch_code,p_level => C_LEVEL_PROCEDURE);
      trace(p_module => l_log_module,p_msg => 'application_id :'|| p_ac_balance_int_rec.application_id,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'ledger_id :'|| p_ac_balance_int_rec.ledger_id,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'code_combination_id :'|| p_ac_balance_int_rec.code_combination_id,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'analytical_criterion_code :'|| p_ac_balance_int_rec.analytical_criterion_code,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'analytical_criterion_type_code :'|| p_ac_balance_int_rec.analytical_criterion_type_code,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'amb_context_code :'|| p_ac_balance_int_rec.amb_context_code,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'ac1 :'|| p_ac_balance_int_rec.ac1,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'ac2 :'|| p_ac_balance_int_rec.ac2,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'ac3 :'|| p_ac_balance_int_rec.ac3,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'ac4 :'|| p_ac_balance_int_rec.ac4,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'ac5 :'|| p_ac_balance_int_rec.ac5,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'period_name :'|| p_ac_balance_int_rec.period_name,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'init_balance_dr :'|| p_ac_balance_int_rec.init_balance_dr,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'init_balance_cr :'|| p_ac_balance_int_rec.init_balance_cr,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment1 :'|| p_ac_balance_int_rec.segment1,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment2 :'|| p_ac_balance_int_rec.segment2,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment3 :'|| p_ac_balance_int_rec.segment3,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment4 :'|| p_ac_balance_int_rec.segment4,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment5 :'|| p_ac_balance_int_rec.segment5,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment6 :'|| p_ac_balance_int_rec.segment6,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment7 :'|| p_ac_balance_int_rec.segment7,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment8 :'|| p_ac_balance_int_rec.segment8,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment9 :'|| p_ac_balance_int_rec.segment9,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment10 :'|| p_ac_balance_int_rec.segment10,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment11 :'|| p_ac_balance_int_rec.segment11,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment12 :'|| p_ac_balance_int_rec.segment12,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment13 :'|| p_ac_balance_int_rec.segment13,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment14 :'|| p_ac_balance_int_rec.segment14,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment15 :'|| p_ac_balance_int_rec.segment15,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment16 :'|| p_ac_balance_int_rec.segment16,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment17 :'|| p_ac_balance_int_rec.segment17,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment18 :'|| p_ac_balance_int_rec.segment18,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment19 :'|| p_ac_balance_int_rec.segment19,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment20 :'|| p_ac_balance_int_rec.segment20,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment21 :'|| p_ac_balance_int_rec.segment21,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment22 :'|| p_ac_balance_int_rec.segment22,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment23 :'|| p_ac_balance_int_rec.segment23,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment24 :'|| p_ac_balance_int_rec.segment24,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment25 :'|| p_ac_balance_int_rec.segment25,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment26 :'|| p_ac_balance_int_rec.segment26,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment27 :'|| p_ac_balance_int_rec.segment27,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment28 :'|| p_ac_balance_int_rec.segment28,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment29 :'|| p_ac_balance_int_rec.segment29,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'segment30 :'|| p_ac_balance_int_rec.segment30,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'status :'|| p_ac_balance_int_rec.status,p_level => C_LEVEL_STATEMENT);
      trace(p_module => l_log_module,p_msg => 'message_codes :'|| p_ac_balance_int_rec.message_codes,p_level => C_LEVEL_STATEMENT);
   END IF;

  /*
   * first, fetch the header detail for the supporting reference
   * Ignoring c_sup_ref_hdr%NOTFOUND assuming that validation_balances_rec has already validated it
   */
  OPEN c_sup_ref_hdr(p_ac_balance_int_rec.amb_context_code,p_ac_balance_int_rec.analytical_criterion_code,p_ac_balance_int_rec.analytical_criterion_type_code);
  FETCH c_sup_ref_hdr INTO l_sup_ref_hdr;
  CLOSE c_sup_ref_hdr;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_module => l_log_module,p_msg => 'l_sup_ref_hdr.balancing_flag:'||l_sup_ref_hdr.balancing_flag,p_level => C_LEVEL_STATEMENT);
    trace(p_module => l_log_module,p_msg => 'l_sup_ref_hdr.year_end_carry_forward_code:'||l_sup_ref_hdr.year_end_carry_forward_code,p_level => C_LEVEL_STATEMENT);
  END IF;

  /*
   * We balance accounts for subsequent periods only if balancing_flag='Y'
   */
  IF l_sup_ref_hdr.balancing_flag = 'Y' THEN
    /*
     * if l_sup_ref_hdr.year_end_carry_forward_code = 'A', always carry forward the balances
     * if l_sup_ref_hdr.year_end_carry_forward_code = 'N', never forward the balances
     * if l_sup_ref_hdr.year_end_carry_forward_code = 'B', carry forward the balances based on account
     * For l_sup_ref_hdr.year_end_carry_forward_code = 'B',
     * A            Asset           - All periods
     * E            Expense         - Current year
     * R            Revenue         - Current year
     * C            Budgetary (CR)  - Current year
     * D            Budgetary (DR)  - Current year
     * O            Owners' equity  - All periods
     * L            Liability       - All Periods
     * N                            - All Periods
    */
    IF l_sup_ref_hdr.year_end_carry_forward_code = 'A' THEN
      l_period_year := NULL;
    ELSIF l_sup_ref_hdr.year_end_carry_forward_code = 'N' THEN
      l_period_year := get_period_year(p_ac_balance_int_rec.period_name);
    ELSIF l_sup_ref_hdr.year_end_carry_forward_code = 'B' THEN
      OPEN c_account_type(p_ac_balance_int_rec.code_combination_id);
      FETCH c_account_type INTO l_account_type;
      CLOSE c_account_type;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace(p_module => l_log_module,p_msg => 'l_account_type:'||l_account_type,p_level => C_LEVEL_STATEMENT);
      END IF;

      IF l_account_type IN ('A','O','L') OR l_account_type IS NULL THEN
        l_period_year := NULL;
      ELSIF l_account_type IN ('E','R','C','D') THEN
        l_period_year := get_period_year(p_ac_balance_int_rec.period_name);
      END IF;
    END IF;
    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_module => l_log_module,p_msg => 'l_period_year:'||l_period_year,p_level => C_LEVEL_STATEMENT);
    END IF;
    /*
     * For maintaining balances, we need to peek into xla_ac_balances table and find which period(ocurring after the period for which
     * data is being imported) is next. We get this "next period" and see if there are more periods in between the period for which
     * data is being imported and the "next period". We need to insert new records for such intermediate periods
     */

    OPEN c_next_period_start_date(p_ac_balance_int_rec.application_id,
                                  p_ac_balance_int_rec.ledger_id,
                                  p_ac_balance_int_rec.code_combination_id,
                                  p_ac_balance_int_rec.analytical_criterion_code,
                                  p_ac_balance_int_rec.analytical_criterion_type_code,
                                  p_ac_balance_int_rec.amb_context_code,
                                  p_ac_balance_int_rec.ac1,
                                  p_ac_balance_int_rec.ac2,
                                  p_ac_balance_int_rec.ac3,
                                  p_ac_balance_int_rec.ac4,
                                  p_ac_balance_int_rec.ac5,
                                  l_period_year,
                                  p_ac_balance_int_rec.period_name);
    FETCH c_next_period_start_date INTO l_next_period_start_date;
    CLOSE c_next_period_start_date;
    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_module => l_log_module,p_msg => 'l_next_period_start_date:'||l_next_period_start_date,p_level => C_LEVEL_STATEMENT);
    END IF;

    l_synchronize_fut_periods := TRUE;
    IF l_next_period_start_date IS NULL THEN
      l_synchronize_fut_periods := FALSE;
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace(p_module => l_log_module,p_msg => 'l_synchronize_fut_periods set to FALSE',p_level => C_LEVEL_STATEMENT);
      END IF;
    END IF;

    /*
     * get current period end date
     */
    OPEN c_current_period_end_date(p_ac_balance_int_rec.ledger_id,p_ac_balance_int_rec.application_id,p_ac_balance_int_rec.period_name,l_period_year);
    FETCH c_current_period_end_date INTO l_current_period_end_date;
    CLOSE c_current_period_end_date;
    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_module => l_log_module,p_msg => 'l_current_period_end_date:'||l_current_period_end_date,p_level => C_LEVEL_STATEMENT);
    END IF;
  END IF;

  /*
   * a new record
   */
   -- find out if there is an existing record
   OPEN c_exist_balance(
                        p_ac_balance_int_rec.ledger_id,
                        p_ac_balance_int_rec.code_combination_id,
                        p_ac_balance_int_rec.analytical_criterion_code,
                        p_ac_balance_int_rec.analytical_criterion_type_code,
                        p_ac_balance_int_rec.amb_context_code,
                        p_ac_balance_int_rec.ac1,
                        p_ac_balance_int_rec.ac2,
                        p_ac_balance_int_rec.ac3,
                        p_ac_balance_int_rec.ac4,
                        p_ac_balance_int_rec.ac5,
                        p_ac_balance_int_rec.period_name
                       );
   FETCH c_exist_balance INTO l_exist_balance;
   IF c_exist_balance%FOUND THEN
     CLOSE c_exist_balance;
     /*
      * Record exists
      */
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace(p_module => l_log_module,p_msg => 'c_exist_balance%FOUND',p_level => C_LEVEL_STATEMENT);
      END IF;
      -- update the cr/dr
      IF p_ac_balance_int_rec.init_balance_dr IS NOT NULL AND p_ac_balance_int_rec.init_balance_dr <> 0 THEN
        -- update dr
        l_delta_dr := p_ac_balance_int_rec.init_balance_dr - NVL(l_exist_balance.beginning_balance_dr,0);
        l_delta_cr := 0;
        l_exist_balance.beginning_balance_dr := p_ac_balance_int_rec.init_balance_dr;
        --l_exist_balance.initial_balance_flag := 'N';

        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace(p_module => l_log_module,p_msg => 'case 1',p_level => C_LEVEL_STATEMENT);
          trace(p_module => l_log_module,p_msg => 'l_delta_dr:'||l_delta_dr,p_level => C_LEVEL_STATEMENT);
          trace(p_module => l_log_module,p_msg => 'l_delta_cr:'||l_delta_cr,p_level => C_LEVEL_STATEMENT);
          trace(p_module => l_log_module,p_msg => 'l_exist_balance.beginning_balance_dr:'||l_exist_balance.beginning_balance_dr,p_level => C_LEVEL_STATEMENT);
          trace(p_module => l_log_module,p_msg => 'l_exist_balance.initial_balance_flag:'||l_exist_balance.initial_balance_flag,p_level => C_LEVEL_STATEMENT);
        END IF;
        update_balances_rec(l_exist_balance);
      ELSIF p_ac_balance_int_rec.init_balance_cr IS NOT NULL AND p_ac_balance_int_rec.init_balance_cr <> 0 THEN
        -- update cr
        l_delta_cr := p_ac_balance_int_rec.init_balance_cr - NVL(l_exist_balance.beginning_balance_cr,0);
        l_delta_dr := 0;
        l_exist_balance.beginning_balance_cr := p_ac_balance_int_rec.init_balance_cr;
        --l_exist_balance.initial_balance_flag := 'N';

        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace(p_module => l_log_module,p_msg => 'case 2',p_level => C_LEVEL_STATEMENT);
          trace(p_module => l_log_module,p_msg => 'l_delta_dr:'||l_delta_dr,p_level => C_LEVEL_STATEMENT);
          trace(p_module => l_log_module,p_msg => 'l_delta_cr:'||l_delta_cr,p_level => C_LEVEL_STATEMENT);
          trace(p_module => l_log_module,p_msg => 'l_exist_balance.beginning_balance_cr:'||l_exist_balance.beginning_balance_cr,p_level => C_LEVEL_STATEMENT);
          trace(p_module => l_log_module,p_msg => 'l_exist_balance.initial_balance_flag:'||l_exist_balance.initial_balance_flag,p_level => C_LEVEL_STATEMENT);
        END IF;
        update_balances_rec(l_exist_balance);
      ELSIF p_ac_balance_int_rec.init_balance_dr = 0  AND p_ac_balance_int_rec.init_balance_dr = 0 THEN
        IF l_exist_balance.initial_balance_flag = 'Y' AND (l_exist_balance.period_balance_dr IS NOT NULL OR l_exist_balance.period_balance_cr IS NOT NULL) THEN
          -- (logical) delete record
          l_delta_cr := NVL(-1 * l_exist_balance.beginning_balance_cr,0);
          l_delta_dr := NVL(-1 * l_exist_balance.beginning_balance_dr,0);

          l_exist_balance.beginning_balance_dr := NULL;
          l_exist_balance.beginning_balance_cr := NULL;
          l_exist_balance.initial_balance_flag := 'N';

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace(p_module => l_log_module,p_msg => 'case 3',p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => 'l_delta_dr:'||l_delta_dr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => 'l_delta_cr:'||l_delta_cr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => 'l_exist_balance.beginning_balance_dr:'||l_exist_balance.beginning_balance_dr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => 'l_exist_balance.beginning_balance_cr:'||l_exist_balance.beginning_balance_cr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => 'l_exist_balance.initial_balance_flag:'||l_exist_balance.initial_balance_flag,p_level => C_LEVEL_STATEMENT);
          END IF;
          update_balances_rec(l_exist_balance);
        ELSIF l_exist_balance.initial_balance_flag = 'Y' AND l_exist_balance.period_balance_dr IS NULL AND l_exist_balance.period_balance_cr IS NULL THEN
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace(p_module => l_log_module,p_msg => 'calling delete_balances_rec',p_level => C_LEVEL_STATEMENT);
          END IF;
          l_delta_cr := NVL(-1 * l_exist_balance.beginning_balance_cr,0);
          l_delta_dr := NVL(-1 * l_exist_balance.beginning_balance_dr,0);
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace(p_module => l_log_module,p_msg => 'l_delta_cr:'||l_delta_cr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => 'l_delta_dr:'||l_delta_dr,p_level => C_LEVEL_STATEMENT);
          END IF;
          delete_balances_rec(l_exist_balance);

        ELSIF l_exist_balance.initial_balance_flag = 'N' THEN
          RAISE CANT_DELETE_BALANCES;
        END IF;
      END IF;

      IF l_synchronize_fut_periods THEN
        l_cr := NVL(l_delta_cr,0);
        l_dr := NVL(l_delta_dr,0);
        OPEN c_subsequent_periods(p_ac_balance_int_rec.application_id,
                                  p_ac_balance_int_rec.ledger_id,
                                  p_ac_balance_int_rec.code_combination_id,
                                  p_ac_balance_int_rec.analytical_criterion_code,
                                  p_ac_balance_int_rec.analytical_criterion_type_code,
                                  p_ac_balance_int_rec.amb_context_code,
                                  p_ac_balance_int_rec.ac1,
                                  p_ac_balance_int_rec.ac2,
                                  p_ac_balance_int_rec.ac3,
                                  p_ac_balance_int_rec.ac4,
                                  p_ac_balance_int_rec.ac5,
                                  l_period_year,
                                  p_ac_balance_int_rec.period_name);
        FETCH c_subsequent_periods INTO l_subsequent_periods;
        WHILE c_subsequent_periods%FOUND LOOP
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace(p_module => l_log_module,p_msg => '1.c_subsequent_periods fetched period_name:'||l_subsequent_periods.period_name||'/'||'period_year:'||l_subsequent_periods.period_year,p_level => C_LEVEL_STATEMENT);
          END IF;

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace(p_module => l_log_module,p_msg => '1-l_subsequent_periods.beginning_balance_dr:'||l_subsequent_periods.beginning_balance_dr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => '1-l_subsequent_periods.beginning_balance_cr:'||l_subsequent_periods.beginning_balance_cr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => '1-l_delta_dr:'||l_delta_dr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => '1-l_delta_cr:'||l_delta_cr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => '1-l_subsequent_periods.period_balance_dr:'||l_subsequent_periods.period_balance_dr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => '1-l_subsequent_periods.period_balance_cr:'||l_subsequent_periods.period_balance_cr,p_level => C_LEVEL_STATEMENT);
          END IF;

          IF l_cr IS NULL AND l_dr IS NULL THEN
            l_subsequent_periods.beginning_balance_dr := NVL(l_delta_dr,0);
            l_subsequent_periods.beginning_balance_cr := NVL(l_delta_cr,0);

            l_dr := NVL(l_subsequent_periods.beginning_balance_dr,0) + NVL(l_subsequent_periods.period_balance_dr,0);
            l_cr := NVL(l_subsequent_periods.beginning_balance_cr,0) + NVL(l_subsequent_periods.period_balance_cr,0);

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace(p_module => l_log_module,p_msg => '1.1-l_subsequent_periods.beginning_balance_dr:'||l_subsequent_periods.beginning_balance_dr,p_level => C_LEVEL_STATEMENT);
              trace(p_module => l_log_module,p_msg => '1.1-l_subsequent_periods.beginning_balance_cr:'||l_subsequent_periods.beginning_balance_cr,p_level => C_LEVEL_STATEMENT);
            END IF;
          ELSE
            l_subsequent_periods.beginning_balance_dr := NVL(l_subsequent_periods.beginning_balance_dr,0) + NVL(l_delta_dr,0);
            l_subsequent_periods.beginning_balance_cr := NVL(l_subsequent_periods.beginning_balance_cr,0) + NVL(l_delta_cr,0);

            l_dr := NVL(l_dr,0) + NVL(l_subsequent_periods.period_balance_dr,0);
            l_cr := NVL(l_cr,0) + NVL(l_subsequent_periods.period_balance_cr,0);

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace(p_module => l_log_module,p_msg => '1.2-l_subsequent_periods.beginning_balance_dr:'||l_subsequent_periods.beginning_balance_dr,p_level => C_LEVEL_STATEMENT);
              trace(p_module => l_log_module,p_msg => '1.2-l_subsequent_periods.beginning_balance_cr:'||l_subsequent_periods.beginning_balance_cr,p_level => C_LEVEL_STATEMENT);
            END IF;
          END IF;
          l_subsequent_periods.initial_balance_flag := 'N';

          IF l_subsequent_periods.beginning_balance_cr = 0 THEN
            l_subsequent_periods.beginning_balance_cr := NULL;
          END IF;
          IF l_subsequent_periods.beginning_balance_dr = 0 THEN
            l_subsequent_periods.beginning_balance_dr := NULL;
          END IF;
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace(p_module => l_log_module,p_msg => 'l_subsequent_periods.beginning_balance_dr:'||l_subsequent_periods.beginning_balance_dr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => 'l_subsequent_periods.beginning_balance_cr:'||l_subsequent_periods.beginning_balance_cr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => 'l_subsequent_periods.period_balance_dr:'||l_subsequent_periods.period_balance_dr,p_level => C_LEVEL_STATEMENT);
            trace(p_module => l_log_module,p_msg => 'l_subsequent_periods.period_balance_cr:'||l_subsequent_periods.period_balance_cr,p_level => C_LEVEL_STATEMENT);
          END IF;

          /*
           * If we are deleting a balances record, we need to delete future balances records
           * which don't have any period activity
           */
          IF (l_subsequent_periods.beginning_balance_dr IS NULL AND l_subsequent_periods.beginning_balance_cr IS NULL AND NVL(l_subsequent_periods.period_balance_cr,0) = 0 AND NVL(l_subsequent_periods.period_balance_dr,0) = 0) THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace(p_module => l_log_module,p_msg => 'calling delete_balances_rec for period:'||l_subsequent_periods.period_name,p_level => C_LEVEL_STATEMENT);
            END IF;
            delete_balances_rec(l_subsequent_periods);
          ELSE
            l_period_num := NULL;
            OPEN c_period_num(l_subsequent_periods.ledger_id,l_subsequent_periods.period_name);
            FETCH c_period_num INTO l_period_num;
            CLOSE c_period_num;
            IF l_period_num = 1 THEN
              l_subsequent_periods.first_period_flag := 'Y';
            ELSE
              l_subsequent_periods.first_period_flag := 'N';
            END IF;
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace(p_module => l_log_module,p_msg => 'l_subsequent_periods.first_period_flag:'||l_subsequent_periods.first_period_flag||' for '||l_subsequent_periods.period_name,p_level => C_LEVEL_STATEMENT);
            END IF;
            update_balances_rec(l_subsequent_periods);
          END IF;
          FETCH c_subsequent_periods INTO l_subsequent_periods;
        END LOOP;


        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace(p_module => l_log_module,p_msg => 'opening c_future_open_periods with l_subsequent_periods.period_name:'||l_subsequent_periods.period_name||',l_period_year:'||l_period_year,p_level => C_LEVEL_STATEMENT);
        END IF;
        OPEN c_future_open_periods(p_ac_balance_int_rec.application_id,
                                   p_ac_balance_int_rec.ledger_id,
                                   l_subsequent_periods.period_name,
                                   l_period_year);
        FETCH c_future_open_periods INTO l_future_open_periods;
        IF c_future_open_periods%FOUND THEN
          /*
           * There are future open periods. so insert new records for them with zero period activity
           */
          WHILE c_future_open_periods%FOUND LOOP
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace(p_module => l_log_module,p_msg => 'c_future_open_periods fetched period:'||l_future_open_periods.period_name,p_level => C_LEVEL_STATEMENT);
            END IF;
            l_balances_rec := NULL;
            l_balances_rec.application_id                 := p_ac_balance_int_rec.application_id;
            l_balances_rec.ledger_id                      := p_ac_balance_int_rec.ledger_id;
            l_balances_rec.code_combination_id            := p_ac_balance_int_rec.code_combination_id;
            l_balances_rec.analytical_criterion_code      := p_ac_balance_int_rec.analytical_criterion_code;
            l_balances_rec.analytical_criterion_type_code := p_ac_balance_int_rec.analytical_criterion_type_code;
            l_balances_rec.amb_context_code               := p_ac_balance_int_rec.amb_context_code;
            l_balances_rec.ac1                            := p_ac_balance_int_rec.ac1;
            l_balances_rec.ac2                            := p_ac_balance_int_rec.ac2;
            l_balances_rec.ac3                            := p_ac_balance_int_rec.ac3;
            l_balances_rec.ac4                            := p_ac_balance_int_rec.ac4;
            l_balances_rec.ac5                            := p_ac_balance_int_rec.ac5;
            l_balances_rec.period_name                    := l_future_open_periods.period_name;
            l_balances_rec.beginning_balance_dr           := l_subsequent_periods.beginning_balance_dr;
            l_balances_rec.beginning_balance_cr           := l_subsequent_periods.beginning_balance_cr;
            l_balances_rec.period_balance_dr              := NULL;
            l_balances_rec.period_balance_cr              := NULL;
            l_balances_rec.initial_balance_flag           := 'N';
            l_balances_rec.period_year                    := NVL(l_period_year,get_period_year(l_future_open_periods.period_name));
            IF l_future_open_periods.period_num = 1 THEN
              l_balances_rec.first_period_flag            := 'Y';
            ELSE
              l_balances_rec.first_period_flag            := 'N';
            END IF;
            insert_balances_rec(l_balances_rec);
            FETCH c_future_open_periods INTO l_future_open_periods;
          END LOOP;
        END IF;

        IF l_account_type IN ('E','R','C','D') AND l_sup_ref_hdr.year_end_carry_forward_code = 'B' THEN
          l_period_year := get_period_year(p_ac_balance_int_rec.period_name);
          l_prev_year := NULL;
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace(p_module => l_log_module,p_msg => 'opening c_delete_records for year :'||l_period_year,p_level => C_LEVEL_STATEMENT);
          END IF;
          FOR l_delete_records IN c_delete_records(p_ac_balance_int_rec.application_id,
                                                   p_ac_balance_int_rec.ledger_id,
                                                   p_ac_balance_int_rec.code_combination_id,
                                                   p_ac_balance_int_rec.analytical_criterion_code,
                                                   p_ac_balance_int_rec.analytical_criterion_type_code,
                                                   p_ac_balance_int_rec.amb_context_code,
                                                   p_ac_balance_int_rec.ac1,
                                                   p_ac_balance_int_rec.ac2,
                                                   p_ac_balance_int_rec.ac3,
                                                   p_ac_balance_int_rec.ac4,
                                                   p_ac_balance_int_rec.ac5,
                                                   l_period_year) LOOP
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace(p_module => l_log_module,p_msg => 'c_delete_records fetched period:'||l_delete_records.period_name,p_level => C_LEVEL_STATEMENT);
            END IF;
            IF c_delete_records%ROWCOUNT = 1 AND (l_delete_records.period_balance_dr IS NOT NULL OR l_delete_records.period_balance_cr IS NOT NULL) THEN
              EXIT;
            END IF;

            IF c_delete_records%ROWCOUNT = 1 AND l_delete_records.period_balance_dr IS NULL AND l_delete_records.period_balance_cr IS NULL THEN
              delete_balances_rec(l_delete_records);
              l_delete_cr_delta := l_delete_records.beginning_balance_cr;
              l_delete_dr_delta := l_delete_records.beginning_balance_dr;
              l_prev_year := l_delete_records.period_year;
            ELSE
              IF l_prev_year = l_delete_records.period_year THEN
                IF l_delete_records.period_balance_dr IS NULL AND l_delete_records.period_balance_cr IS NULL THEN
                  delete_balances_rec(l_delete_records);
                ELSE
                  l_delete_records.beginning_balance_cr := NVL(l_delete_records.beginning_balance_cr,0) + NVL(l_delete_cr_delta,0);
                  l_delete_records.beginning_balance_dr := NVL(l_delete_records.beginning_balance_dr,0) + NVL(l_delete_dr_delta,0);
                  update_balances_rec(l_delete_records);
                END IF;
              END IF;
            END IF;
          END LOOP;
        END IF;
      ELSE
        IF l_account_type IN ('E','R','C','D') AND l_sup_ref_hdr.year_end_carry_forward_code = 'B' THEN
          l_period_year := get_period_year(p_ac_balance_int_rec.period_name);
          l_prev_year := NULL;
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace(p_module => l_log_module,p_msg => 'opening c_delete_records for year :'||l_period_year,p_level => C_LEVEL_STATEMENT);
          END IF;
          FOR l_delete_records IN c_delete_records(p_ac_balance_int_rec.application_id,
                                                   p_ac_balance_int_rec.ledger_id,
                                                   p_ac_balance_int_rec.code_combination_id,
                                                   p_ac_balance_int_rec.analytical_criterion_code,
                                                   p_ac_balance_int_rec.analytical_criterion_type_code,
                                                   p_ac_balance_int_rec.amb_context_code,
                                                   p_ac_balance_int_rec.ac1,
                                                   p_ac_balance_int_rec.ac2,
                                                   p_ac_balance_int_rec.ac3,
                                                   p_ac_balance_int_rec.ac4,
                                                   p_ac_balance_int_rec.ac5,
                                                   l_period_year) LOOP
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace(p_module => l_log_module,p_msg => 'c_delete_records fetched period:'||l_delete_records.period_name,p_level => C_LEVEL_STATEMENT);
            END IF;
            IF c_delete_records%ROWCOUNT = 1 AND (l_delete_records.period_balance_dr IS NOT NULL OR l_delete_records.period_balance_cr IS NOT NULL) THEN
              EXIT;
            END IF;

            IF c_delete_records%ROWCOUNT = 1 AND l_delete_records.period_balance_dr IS NULL AND l_delete_records.period_balance_cr IS NULL THEN
              delete_balances_rec(l_delete_records);
              l_delete_cr_delta := l_delete_records.beginning_balance_cr;
              l_delete_dr_delta := l_delete_records.beginning_balance_dr;
              l_prev_year := l_delete_records.period_year;
            ELSE
              IF l_prev_year = l_delete_records.period_year THEN
                IF l_delete_records.period_balance_dr IS NULL AND l_delete_records.period_balance_cr IS NULL THEN
                  delete_balances_rec(l_delete_records);
                ELSE
                  l_delete_records.beginning_balance_cr := NVL(l_delete_records.beginning_balance_cr,0) + NVL(l_delete_cr_delta,0);
                  l_delete_records.beginning_balance_dr := NVL(l_delete_records.beginning_balance_dr,0) + NVL(l_delete_dr_delta,0);
                  update_balances_rec(l_delete_records);
                END IF;
              END IF;
            END IF;
          END LOOP;
        END IF;
      END IF;
   ELSE
     CLOSE c_exist_balance;
     /*
      * Record does not exist
      */
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace(p_module => l_log_module,p_msg => 'c_exist_balance%NOTFOUND',p_level => C_LEVEL_STATEMENT);
      END IF;
      IF l_balances_rec.beginning_balance_dr = 0 AND l_balances_rec.beginning_balance_cr = 0 THEN
        RAISE CANT_DELETE_BALANCES;
      END IF;
      -- insert record here
      l_balances_rec.application_id                 := p_ac_balance_int_rec.application_id;
      l_balances_rec.ledger_id                      := p_ac_balance_int_rec.ledger_id;
      l_balances_rec.code_combination_id            := p_ac_balance_int_rec.code_combination_id;
      l_balances_rec.analytical_criterion_code      := p_ac_balance_int_rec.analytical_criterion_code;
      l_balances_rec.analytical_criterion_type_code := p_ac_balance_int_rec.analytical_criterion_type_code;
      l_balances_rec.amb_context_code               := p_ac_balance_int_rec.amb_context_code;
      l_balances_rec.ac1                            := p_ac_balance_int_rec.ac1;
      l_balances_rec.ac2                            := p_ac_balance_int_rec.ac2;
      l_balances_rec.ac3                            := p_ac_balance_int_rec.ac3;
      l_balances_rec.ac4                            := p_ac_balance_int_rec.ac4;
      l_balances_rec.ac5                            := p_ac_balance_int_rec.ac5;
      l_balances_rec.period_name                    := p_ac_balance_int_rec.period_name;
      l_balances_rec.beginning_balance_dr           := p_ac_balance_int_rec.init_balance_dr;
      l_balances_rec.beginning_balance_cr           := p_ac_balance_int_rec.init_balance_cr;
      l_balances_rec.period_balance_dr              := NULL;
      l_balances_rec.period_balance_cr              := NULL;
      l_balances_rec.initial_balance_flag           := 'Y';

      l_balances_rec.period_year                    := get_period_year(p_ac_balance_int_rec.period_name);

      l_period_num := NULL;
      OPEN c_period_num(l_balances_rec.ledger_id,l_balances_rec.period_name);
      FETCH c_period_num INTO l_period_num;
      CLOSE c_period_num;
      IF l_period_num = 1 THEN
        l_balances_rec.first_period_flag := 'Y';
      ELSE
        l_balances_rec.first_period_flag := 'N';
      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace(p_module => l_log_module,p_msg => 'p_ac_balance_int_rec.period_name:'||p_ac_balance_int_rec.period_name,p_level => C_LEVEL_STATEMENT);
        trace(p_module => l_log_module,p_msg => 'p_ac_balance_int_rec.init_balance_dr:'||p_ac_balance_int_rec.init_balance_dr,p_level => C_LEVEL_STATEMENT);
        trace(p_module => l_log_module,p_msg => 'p_ac_balance_int_rec.init_balance_cr:'||p_ac_balance_int_rec.init_balance_cr,p_level => C_LEVEL_STATEMENT);
        trace(p_module => l_log_module,p_msg => 'l_balances_rec.initial_balance_flag:'||l_balances_rec.initial_balance_flag,p_level => C_LEVEL_STATEMENT);
        trace(p_module => l_log_module,p_msg => 'calling insert_balances_rec',p_level => C_LEVEL_STATEMENT);
      END IF;
      insert_balances_rec(l_balances_rec);

     IF l_synchronize_fut_periods THEN
        l_cr := NULL;
        l_dr := NULL;
       FOR l_subsequent_periods IN c_subsequent_periods(p_ac_balance_int_rec.application_id,
                                                        p_ac_balance_int_rec.ledger_id,
                                                        p_ac_balance_int_rec.code_combination_id,
                                                        p_ac_balance_int_rec.analytical_criterion_code,
                                                        p_ac_balance_int_rec.analytical_criterion_type_code,
                                                        p_ac_balance_int_rec.amb_context_code,
                                                        p_ac_balance_int_rec.ac1,
                                                        p_ac_balance_int_rec.ac2,
                                                        p_ac_balance_int_rec.ac3,
                                                        p_ac_balance_int_rec.ac4,
                                                        p_ac_balance_int_rec.ac5,
                                                        l_period_year,
                                                        p_ac_balance_int_rec.period_name) LOOP
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace(p_module => l_log_module,p_msg => '2.c_subsequent_periods fetched period_name:'||l_subsequent_periods.period_name||'/'||'period_year:'||l_subsequent_periods.period_year,p_level => C_LEVEL_STATEMENT);
         END IF;
         l_delta_cr := NVL(p_ac_balance_int_rec.init_balance_cr,0);
         l_delta_dr := NVL(p_ac_balance_int_rec.init_balance_dr,0);

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace(p_module => l_log_module,p_msg => '2-l_subsequent_periods.beginning_balance_dr:'||l_subsequent_periods.beginning_balance_dr,p_level => C_LEVEL_STATEMENT);
           trace(p_module => l_log_module,p_msg => '2-l_subsequent_periods.beginning_balance_cr:'||l_subsequent_periods.beginning_balance_cr,p_level => C_LEVEL_STATEMENT);
           trace(p_module => l_log_module,p_msg => '2-l_delta_dr:'||l_delta_dr,p_level => C_LEVEL_STATEMENT);
           trace(p_module => l_log_module,p_msg => '2-l_delta_cr:'||l_delta_cr,p_level => C_LEVEL_STATEMENT);
           trace(p_module => l_log_module,p_msg => '2-l_subsequent_periods.period_balance_dr:'||l_subsequent_periods.period_balance_dr,p_level => C_LEVEL_STATEMENT);
           trace(p_module => l_log_module,p_msg => '2-l_subsequent_periods.period_balance_cr:'||l_subsequent_periods.period_balance_cr,p_level => C_LEVEL_STATEMENT);
         END IF;


         IF l_cr IS NULL AND l_dr IS NULL THEN
           l_subsequent_periods.beginning_balance_dr := NVL(l_delta_dr,0);
           l_subsequent_periods.beginning_balance_cr := NVL(l_delta_cr,0);

           l_dr := NVL(l_subsequent_periods.beginning_balance_dr,0) + NVL(l_subsequent_periods.period_balance_dr,0);
           l_cr := NVL(l_subsequent_periods.beginning_balance_cr,0) + NVL(l_subsequent_periods.period_balance_cr,0);
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace(p_module => l_log_module,p_msg => '2.1-l_subsequent_periods.beginning_balance_dr:'||l_subsequent_periods.beginning_balance_dr,p_level => C_LEVEL_STATEMENT);
             trace(p_module => l_log_module,p_msg => '2.1-l_subsequent_periods.beginning_balance_cr:'||l_subsequent_periods.beginning_balance_cr,p_level => C_LEVEL_STATEMENT);
           END IF;
         ELSE
           l_subsequent_periods.beginning_balance_dr := l_dr;
           l_subsequent_periods.beginning_balance_cr := l_cr;

           l_dr := NVL(l_dr,0) + NVL(l_subsequent_periods.period_balance_dr,0);
           l_cr := NVL(l_cr,0) + NVL(l_subsequent_periods.period_balance_cr,0);
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace(p_module => l_log_module,p_msg => '2.2-l_subsequent_periods.beginning_balance_dr:'||l_subsequent_periods.beginning_balance_dr,p_level => C_LEVEL_STATEMENT);
             trace(p_module => l_log_module,p_msg => '2.2-l_subsequent_periods.beginning_balance_cr:'||l_subsequent_periods.beginning_balance_cr,p_level => C_LEVEL_STATEMENT);
           END IF;
         END IF;

         IF l_subsequent_periods.beginning_balance_cr = 0 THEN
           l_subsequent_periods.beginning_balance_cr := NULL;
         END IF;
         IF l_subsequent_periods.beginning_balance_dr = 0 THEN
           l_subsequent_periods.beginning_balance_dr := NULL;
         END IF;
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace(p_module => l_log_module,p_msg => 'l_subsequent_periods.beginning_balance_dr:'||l_subsequent_periods.beginning_balance_dr,p_level => C_LEVEL_STATEMENT);
           trace(p_module => l_log_module,p_msg => 'l_subsequent_periods.beginning_balance_cr:'||l_subsequent_periods.beginning_balance_cr,p_level => C_LEVEL_STATEMENT);
         END IF;

         l_subsequent_periods.initial_balance_flag := 'N';

         l_period_num := NULL;
         OPEN c_period_num(l_subsequent_periods.ledger_id,l_subsequent_periods.period_name);
         FETCH c_period_num INTO l_period_num;
         CLOSE c_period_num;
         IF l_period_num = 1 THEN
           l_subsequent_periods.first_period_flag := 'Y';
         ELSE
           l_subsequent_periods.first_period_flag := 'N';
         END IF;
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace(p_module => l_log_module,p_msg => 'l_subsequent_periods.first_period_flag:'||l_subsequent_periods.first_period_flag||' for '||l_subsequent_periods.period_name,p_level => C_LEVEL_STATEMENT);
         END IF;
         update_balances_rec(l_subsequent_periods);
       END LOOP;

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_module => l_log_module,p_msg => 'starting insert/update for future periods',p_level => C_LEVEL_STATEMENT);
       END IF;
       FOR l_future_periods IN c_future_periods(p_ac_balance_int_rec.application_id,
                                                p_ac_balance_int_rec.ledger_id,
                                                l_period_year,
                                                l_current_period_end_date,
                                                l_next_period_start_date
                                               ) LOOP
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace(p_module => l_log_module,p_msg => 'c_future_periods fetched period_name:'||l_future_periods.period_name||'/'||'period_year:'||l_future_periods.period_year,p_level => C_LEVEL_STATEMENT);
         END IF;
         l_balances_rec := NULL;
         l_balances_rec.application_id                 := p_ac_balance_int_rec.application_id;
         l_balances_rec.ledger_id                      := p_ac_balance_int_rec.ledger_id;
         l_balances_rec.code_combination_id            := p_ac_balance_int_rec.code_combination_id;
         l_balances_rec.analytical_criterion_code      := p_ac_balance_int_rec.analytical_criterion_code;
         l_balances_rec.analytical_criterion_type_code := p_ac_balance_int_rec.analytical_criterion_type_code;
         l_balances_rec.amb_context_code               := p_ac_balance_int_rec.amb_context_code;
         l_balances_rec.ac1                            := p_ac_balance_int_rec.ac1;
         l_balances_rec.ac2                            := p_ac_balance_int_rec.ac2;
         l_balances_rec.ac3                            := p_ac_balance_int_rec.ac3;
         l_balances_rec.ac4                            := p_ac_balance_int_rec.ac4;
         l_balances_rec.ac5                            := p_ac_balance_int_rec.ac5;
         l_balances_rec.period_name                    := l_future_periods.period_name;
         l_balances_rec.beginning_balance_dr           := p_ac_balance_int_rec.init_balance_dr;
         l_balances_rec.beginning_balance_cr           := p_ac_balance_int_rec.init_balance_cr;
         l_balances_rec.period_balance_dr              := NULL;
         l_balances_rec.period_balance_cr              := NULL;
         l_balances_rec.initial_balance_flag           := 'N';

         IF l_future_periods.period_num = 1 THEN
           l_balances_rec.first_period_flag            := 'Y';
         ELSE
           l_balances_rec.first_period_flag            := 'N';
         END IF;
         l_balances_rec.period_year                    := l_future_periods.period_year;
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace(p_module => l_log_module,p_msg => 'l_balances_rec.first_period_flag:'||l_balances_rec.first_period_flag||' for '||l_future_periods.period_name,p_level => C_LEVEL_STATEMENT);
         END IF;
         insert_balances_rec(l_balances_rec);
       END LOOP;
     ELSE
       /*
        * l_synchronize_fut_periods = FALSE means there are no future periods which have balances
        * In that case, insert new balances for periods until the last open or future entry period
        * If no open/future entry periods exist, then go until the last closed period
        */
        OPEN c_future_open_periods(p_ac_balance_int_rec.application_id,
                                   p_ac_balance_int_rec.ledger_id,
                                   p_ac_balance_int_rec.period_name,
                                   l_period_year);
        FETCH c_future_open_periods INTO l_future_open_periods;
        IF c_future_open_periods%FOUND THEN
          /*
           * There are future open periods. so insert new records for them with zero period activity
           */
          WHILE c_future_open_periods%FOUND LOOP
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace(p_module => l_log_module,p_msg => 'c_future_open_periods fetched period:'||l_future_open_periods.period_name,p_level => C_LEVEL_STATEMENT);
            END IF;
            l_balances_rec := NULL;
            l_balances_rec.application_id                 := p_ac_balance_int_rec.application_id;
            l_balances_rec.ledger_id                      := p_ac_balance_int_rec.ledger_id;
            l_balances_rec.code_combination_id            := p_ac_balance_int_rec.code_combination_id;
            l_balances_rec.analytical_criterion_code      := p_ac_balance_int_rec.analytical_criterion_code;
            l_balances_rec.analytical_criterion_type_code := p_ac_balance_int_rec.analytical_criterion_type_code;
            l_balances_rec.amb_context_code               := p_ac_balance_int_rec.amb_context_code;
            l_balances_rec.ac1                            := p_ac_balance_int_rec.ac1;
            l_balances_rec.ac2                            := p_ac_balance_int_rec.ac2;
            l_balances_rec.ac3                            := p_ac_balance_int_rec.ac3;
            l_balances_rec.ac4                            := p_ac_balance_int_rec.ac4;
            l_balances_rec.ac5                            := p_ac_balance_int_rec.ac5;
            l_balances_rec.period_name                    := l_future_open_periods.period_name;
            l_balances_rec.beginning_balance_dr           := p_ac_balance_int_rec.init_balance_dr;
            l_balances_rec.beginning_balance_cr           := p_ac_balance_int_rec.init_balance_cr;
            l_balances_rec.period_balance_dr              := NULL;
            l_balances_rec.period_balance_cr              := NULL;
            l_balances_rec.initial_balance_flag           := 'N';
            l_balances_rec.period_year                    := NVL(l_period_year,get_period_year(l_future_open_periods.period_name));
            IF l_future_open_periods.period_num = 1 THEN
              l_balances_rec.first_period_flag            := 'Y';
            ELSE
              l_balances_rec.first_period_flag            := 'N';
            END IF;
            insert_balances_rec(l_balances_rec);
            FETCH c_future_open_periods INTO l_future_open_periods;
          END LOOP;
        ELSE
          /*
           * There are no future open periods. so insert new records for closed periods in the current year with zero period activity, only for
           * E  Expense
           * R  Revenue
           * C  Budgetary (CR)
           * D  Budgetary (DR)
           */
          IF l_account_type IN ('E','R','C','D') THEN
            FOR l_closed_periods IN c_closed_periods(p_ac_balance_int_rec.application_id,p_ac_balance_int_rec.ledger_id,p_ac_balance_int_rec.period_name,l_period_year) LOOP
              IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace(p_module => l_log_module,p_msg => 'c_closed_periods fetched period:'||l_closed_periods.period_name,p_level => C_LEVEL_STATEMENT);
              END IF;
              l_balances_rec := NULL;
              l_balances_rec.application_id                 := p_ac_balance_int_rec.application_id;
              l_balances_rec.ledger_id                      := p_ac_balance_int_rec.ledger_id;
              l_balances_rec.code_combination_id            := p_ac_balance_int_rec.code_combination_id;
              l_balances_rec.analytical_criterion_code      := p_ac_balance_int_rec.analytical_criterion_code;
              l_balances_rec.analytical_criterion_type_code := p_ac_balance_int_rec.analytical_criterion_type_code;
              l_balances_rec.amb_context_code               := p_ac_balance_int_rec.amb_context_code;
              l_balances_rec.ac1                            := p_ac_balance_int_rec.ac1;
              l_balances_rec.ac2                            := p_ac_balance_int_rec.ac2;
              l_balances_rec.ac3                            := p_ac_balance_int_rec.ac3;
              l_balances_rec.ac4                            := p_ac_balance_int_rec.ac4;
              l_balances_rec.ac5                            := p_ac_balance_int_rec.ac5;
              l_balances_rec.period_name                    := l_closed_periods.period_name;
              l_balances_rec.beginning_balance_dr           := p_ac_balance_int_rec.init_balance_dr;
              l_balances_rec.beginning_balance_cr           := p_ac_balance_int_rec.init_balance_cr;
              l_balances_rec.period_balance_dr              := NULL;
              l_balances_rec.period_balance_cr              := NULL;
              l_balances_rec.initial_balance_flag           := 'N';
              l_balances_rec.period_year                    := NVL(l_period_year,get_period_year(l_closed_periods.period_name));
              IF l_future_open_periods.period_num = 1 THEN
                l_balances_rec.first_period_flag            := 'Y';
              ELSE
                l_balances_rec.first_period_flag            := 'N';
              END IF;
              insert_balances_rec(l_balances_rec);
            END LOOP;
          END IF;
        END IF;

        IF l_account_type IN ('E','R','C','D') AND l_sup_ref_hdr.year_end_carry_forward_code = 'B' THEN
          l_period_year := get_period_year(p_ac_balance_int_rec.period_name);
          l_prev_year := NULL;
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace(p_module => l_log_module,p_msg => 'opening c_delete_records for year :'||l_period_year,p_level => C_LEVEL_STATEMENT);
          END IF;
          FOR l_delete_records IN c_delete_records(p_ac_balance_int_rec.application_id,
                                                   p_ac_balance_int_rec.ledger_id,
                                                   p_ac_balance_int_rec.code_combination_id,
                                                   p_ac_balance_int_rec.analytical_criterion_code,
                                                   p_ac_balance_int_rec.analytical_criterion_type_code,
                                                   p_ac_balance_int_rec.amb_context_code,
                                                   p_ac_balance_int_rec.ac1,
                                                   p_ac_balance_int_rec.ac2,
                                                   p_ac_balance_int_rec.ac3,
                                                   p_ac_balance_int_rec.ac4,
                                                   p_ac_balance_int_rec.ac5,
                                                   l_period_year) LOOP
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace(p_module => l_log_module,p_msg => 'c_delete_records fetched period:'||l_delete_records.period_name,p_level => C_LEVEL_STATEMENT);
            END IF;
            IF c_delete_records%ROWCOUNT = 1 AND (l_delete_records.period_balance_dr IS NOT NULL OR l_delete_records.period_balance_cr IS NOT NULL) THEN
              EXIT;
            END IF;

            IF c_delete_records%ROWCOUNT = 1 AND l_delete_records.period_balance_dr IS NULL AND l_delete_records.period_balance_cr IS NULL THEN
              delete_balances_rec(l_delete_records);
              l_delete_cr_delta := l_delete_records.beginning_balance_cr;
              l_delete_dr_delta := l_delete_records.beginning_balance_dr;
              l_prev_year := l_delete_records.period_year;
            ELSE
              IF l_prev_year = l_delete_records.period_year THEN
                IF l_delete_records.period_balance_dr IS NULL AND l_delete_records.period_balance_cr IS NULL THEN
                  delete_balances_rec(l_delete_records);
                ELSE
                  l_delete_records.beginning_balance_cr := NVL(l_delete_records.beginning_balance_cr,0) + NVL(l_delete_cr_delta,0);
                  l_delete_records.beginning_balance_dr := NVL(l_delete_records.beginning_balance_dr,0) + NVL(l_delete_dr_delta,0);
                  update_balances_rec(l_delete_records);
                END IF;
              END IF;
            END IF;
          END LOOP;
        END IF;

     END IF;
   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg          => 'END ' || l_log_module
         ,p_level        => C_LEVEL_PROCEDURE);
   END IF;


EXCEPTION
   WHEN CANT_DELETE_BALANCES THEN
      RAISE;
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_ac_balances_pkg.merge_balances_rec');
END merge_balances_rec;

FUNCTION validate_balances_rec(
                               p_balances_int_rec IN  OUT NOCOPY xla_ac_balances_int%ROWTYPE,
                               p_message_codes        OUT NOCOPY xla_ac_balances_int.message_codes%TYPE
                               )
RETURN BOOLEAN IS
l_log_module                 VARCHAR2 (2000);
  l_result boolean :=true;
  l_rec xla_ac_balances_int%ROWTYPE := p_balances_int_rec;
  l_test_value NUMBER;
  l_error_codes xla_ac_balances_int.message_codes%TYPE;
  l_ledger_category_code   gl_ledgers.ledger_category_code%TYPE;
  l_code_comb_id  xla_ac_balances_int.code_combination_id%TYPE;
  l_coa_id  gl_ledgers.chart_of_accounts_id%TYPE;

  x_err_msg                    VARCHAR2(1000);
  x_ccid                       NUMBER :=  0;
  x_templgrid                  NUMBER :=  0;
  x_acct_type                  VARCHAR2(1);
  x_result  boolean := true;

  --=============================================================================
  --
  -- Cursor to validate application_id
  --
  --=============================================================================
  CURSOR c_is_valid_application(p_app_id  xla_ac_balances_int.application_id%TYPE) IS
    select 1
    from xla_subledgers
    where application_id = p_app_id;

  --=============================================================================
  --
  -- Cursor to validate ledger
  --
  --=============================================================================
  CURSOR c_is_valid_ledger(p_ledger_id  xla_ac_balances_int.ledger_id%TYPE) IS
    select ledger_category_code
    from gl_ledgers
    where ledger_id = p_ledger_id;

  --=============================================================================
  --
  -- Cursor to validate secondary or ALC ledger
  --
  --=============================================================================
  CURSOR c_is_valid_sec_ledger(p_ledger_id  xla_ac_balances_int.ledger_id%TYPE) IS
    select 1
    from gl_ledger_relationships
    where primary_ledger_id = p_ledger_id
    and relationship_type_code='SUBLEDGER';

  --=============================================================================
  --
  -- Cursor to fetch chart_of_accounts id for a given ledger
  --
  --=============================================================================
  CURSOR c_fetch_coa_id(p_ledger_id xla_ac_balances_int.ledger_id%TYPE) IS
    select chart_of_accounts_id
    from gl_ledgers
    where ledger_id = p_ledger_id;

  --=============================================================================
  --
  -- Cursor to validate code combination id
  --
  --=============================================================================
  CURSOR c_is_valid_code_comb_id(
    p_ledger_id   xla_ac_balances_int.ledger_id%TYPE
    ,p_code_comb_id  gl_code_combinations.code_combination_id%TYPE) IS
    select 1
    from gl_ledgers lg,
        gl_code_combinations cc
    where lg.ledger_id = p_ledger_id
    and lg.chart_of_accounts_id = cc.chart_of_accounts_id
    and cc.code_combination_id = p_code_comb_id;

  --=============================================================================
  --
  -- Cursor to validate populated code combination id
  --
  --=============================================================================
  CURSOR c_is_valid_pop_code_comb_id(p_rec  xla_ac_balances_int%ROWTYPE) IS
    select  gl.code_combination_id
    from   gl_code_combinations gl
    where  NVL(gl.segment1, 'X') = NVL(p_rec.segment1, 'X')
    and     NVL(gl.segment2, 'X') = NVL(p_rec.segment2, 'X')
    and     NVL(gl.segment3, 'X') = NVL(p_rec.segment3, 'X')
    and     NVL(gl.segment4, 'X') = NVL(p_rec.segment4, 'X')
    and     NVL(gl.segment5, 'X') = NVL(p_rec.segment5, 'X')
    and     NVL(gl.segment6, 'X') = NVL(p_rec.segment6, 'X')
    and     NVL(gl.segment7, 'X') = NVL(p_rec.segment7, 'X')
    and     NVL(gl.segment8, 'X') = NVL(p_rec.segment8, 'X')
    and     NVL(gl.segment9, 'X') = NVL(p_rec.segment9, 'X')
    and     NVL(gl.segment10, 'X') = NVL(p_rec.segment10, 'X')
    and     NVL(gl.segment11, 'X') = NVL(p_rec.segment11, 'X')
    and     NVL(gl.segment12, 'X') = NVL(p_rec.segment12, 'X')
    and     NVL(gl.segment13, 'X') = NVL(p_rec.segment13, 'X')
    and     NVL(gl.segment14, 'X') = NVL(p_rec.segment14, 'X')
    and     NVL(gl.segment15, 'X') = NVL(p_rec.segment15, 'X')
    and     NVL(gl.segment16, 'X') = NVL(p_rec.segment16, 'X')
    and     NVL(gl.segment17, 'X') = NVL(p_rec.segment17, 'X')
    and     NVL(gl.segment18, 'X') = NVL(p_rec.segment18, 'X')
    and     NVL(gl.segment19, 'X') = NVL(p_rec.segment19, 'X')
    and     NVL(gl.segment20, 'X') = NVL(p_rec.segment20, 'X')
    and     NVL(gl.segment21, 'X') = NVL(p_rec.segment21, 'X')
    and     NVL(gl.segment22, 'X') = NVL(p_rec.segment22, 'X')
    and     NVL(gl.segment23, 'X') = NVL(p_rec.segment23, 'X')
    and     NVL(gl.segment24, 'X') = NVL(p_rec.segment24, 'X')
    and     NVL(gl.segment25, 'X') = NVL(p_rec.segment25, 'X')
    and     NVL(gl.segment26, 'X') = NVL(p_rec.segment26, 'X')
    and     NVL(gl.segment27, 'X') = NVL(p_rec.segment27, 'X')
    and     NVL(gl.segment28, 'X') = NVL(p_rec.segment28, 'X')
    and     NVL(gl.segment29, 'X') = NVL(p_rec.segment29, 'X')
    and     NVL(gl.segment30, 'X') = NVL(p_rec.segment30, 'X');


  --=============================================================================
  --
  -- Cursor to validate analytical criterion code
  --
  --=============================================================================
  CURSOR c_is_valid_anal_crit_code
      (p_anal_crit_code   XLA_ANALYTICAL_HDRS_B.analytical_criterion_code%TYPE
      ,p_anal_crit_type_code  XLA_ANALYTICAL_HDRS_B.analytical_criterion_type_code%TYPE
      ,p_amb_context_code XLA_ANALYTICAL_HDRS_B.amb_context_code%TYPE) IS
    SELECT 1
    FROM XLA_ANALYTICAL_HDRS_B
    WHERE analytical_criterion_code = p_anal_crit_code
    AND analytical_criterion_type_code = p_anal_crit_type_code
    AND amb_context_code = p_amb_context_code
    AND balancing_flag = 'Y'
    AND enabled_flag = 'Y';

  --=============================================================================
  --
  -- Cursor to validate period
  --
  --=============================================================================
  CURSOR c_is_valid_period
      (p_app_id   xla_ac_balances_int.application_id%TYPE
      ,p_ledger_id  xla_ac_balances_int.ledger_id%TYPE
      ,p_period_name  gl_period_statuses.period_name%TYPE) IS
    select 1
    from gl_period_statuses
    where application_id =p_app_id
    and ledger_id = p_ledger_id
    and period_name=p_period_name
    AND closing_status IN ('O','C');

  --=============================================================================
  --
  -- Cursor to validate prior journal extries exits or not for the given period name
  --
  --=============================================================================
  CURSOR c_is_prior_je_exists(p_rec xla_ac_balances_int%ROWTYPE) IS
    select 1
    from xla_ac_balances
    where ledger_id = p_rec.ledger_id
    and code_combination_id = p_rec.code_combination_id
    and analytical_criterion_code = p_rec.analytical_criterion_code
    and analytical_criterion_type_code = p_rec.analytical_criterion_type_code
    and amb_context_code = p_rec.amb_context_code
    AND NVL(ac1,'*') = NVL(p_rec.ac1,'*')
    AND NVL(ac2,'*') = NVL(p_rec.ac2,'*')
    AND NVL(ac3,'*') = NVL(p_rec.ac3,'*')
    AND NVL(ac4,'*') = NVL(p_rec.ac4,'*')
    AND NVL(ac5,'*') = NVL(p_rec.ac5,'*')
    and period_name in (
    select per.period_name
    from gl_periods per,
        gl_ledgers led,
        gl_periods ref_per
    where per.adjustment_period_flag = 'N'
    and led.accounted_period_type = per.period_type
    and led.period_set_name = per.period_set_name
    and led.ledger_id = p_rec.ledger_id
    and per.start_date < ref_per.start_date
    and ref_per.period_name = p_rec.period_name
    and ref_per.period_type = per.period_type
    and ref_per.period_set_name = per.period_set_name
    );


BEGIN
    l_error_codes :=  '';
    -- validate application id
    OPEN c_is_valid_application(l_rec.application_id);
      FETCH  c_is_valid_application INTO l_test_value;

      IF(c_is_valid_application%NOTFOUND) THEN
        l_error_codes :=  'IB001,';
        l_result := false;
      END IF;

    CLOSE c_is_valid_application;

    -- validate ledger
    OPEN c_is_valid_ledger(l_rec.ledger_id);
      FETCH c_is_valid_ledger INTO l_ledger_category_code;

      IF (c_is_valid_ledger%FOUND) THEN
         IF (l_ledger_category_code <> 'PRIMARY') THEN
            OPEN c_is_valid_sec_ledger(l_rec.ledger_id);

          FETCH c_is_valid_sec_ledger INTO l_test_value;

          IF (c_is_valid_sec_ledger%NOTFOUND) THEN
             l_error_codes  :=  l_error_codes || 'IB004,';
             l_result := false;
          END IF;
            CLOSE c_is_valid_sec_ledger;
         END IF;
      ELSE
         l_error_codes  :=  l_error_codes || 'IB003,';
         l_result := false;
      END IF;

    CLOSE c_is_valid_ledger;

    IF (l_rec.code_combination_id IS NOT NULL) THEN
      -- validate code combination id

      OPEN c_fetch_coa_id(l_rec.ledger_id);
        FETCH c_fetch_coa_id INTO l_coa_id;
      CLOSE c_fetch_coa_id;

      IF NOT FND_FLEX_KEYVAL.validate_ccid
      (
        appl_short_name         => 'SQLGL'
        ,key_flex_code           => 'GL#'
        ,structure_number        => l_coa_id
        ,combination_id          => l_rec.code_combination_id
        ,displayable             => 'ALL'
        ,data_set                => NULL
        ,vrule                   => NULL
        ,security                => 'IGNORE'
        ,get_columns             => NULL
        ,resp_appl_id            => NULL
        ,resp_id                 => NULL
        ,user_id                 => NULL
        ,select_comb_from_view   => NULL
      )
      THEN
        l_error_codes :=  l_error_codes || 'IB005,';
        l_result := false;
      END IF;

    ELSE
      -- populate code combination id and validate it
      OPEN c_fetch_coa_id(l_rec.ledger_id);
        FETCH c_fetch_coa_id INTO l_coa_id;
      CLOSE c_fetch_coa_id;

      x_result  :=  GL_RECURRING_RULES_PKG.get_ccid
            (
               l_rec.ledger_id
              ,l_coa_id
              ,NULL -- concat segs
              ,x_err_msg
              ,x_ccid
              ,x_templgrid
              ,x_acct_type
              ,l_rec.segment1
              ,l_rec.segment2
              ,l_rec.segment3
              ,l_rec.segment4
              ,l_rec.segment5
              ,l_rec.segment6
              ,l_rec.segment7
              ,l_rec.segment8
              ,l_rec.segment9
              ,l_rec.segment10
              ,l_rec.segment11
              ,l_rec.segment12
              ,l_rec.segment13
              ,l_rec.segment14
              ,l_rec.segment15
              ,l_rec.segment16
              ,l_rec.segment17
              ,l_rec.segment18
              ,l_rec.segment19
              ,l_rec.segment20
              ,l_rec.segment21
              ,l_rec.segment22
              ,l_rec.segment23
              ,l_rec.segment24
              ,l_rec.segment25
              ,l_rec.segment26
              ,l_rec.segment27
              ,l_rec.segment28
              ,l_rec.segment29
              ,l_rec.segment30
            );

      IF (x_result = true AND x_ccid  IS NOT NULL) THEN
        IF NOT FND_FLEX_KEYVAL.validate_ccid
        (
          appl_short_name         => 'SQLGL'
          ,key_flex_code           => 'GL#'
          ,structure_number        => l_coa_id
          ,combination_id          => x_ccid
          ,displayable             => 'ALL'
          ,data_set                => NULL
          ,vrule                   => NULL
          ,security                => 'IGNORE'
          ,get_columns             => NULL
          ,resp_appl_id            => NULL
          ,resp_id                 => NULL
          ,user_id                 => NULL
          ,select_comb_from_view   => NULL
        )
        THEN
          l_error_codes :=  l_error_codes || 'IB006,';
          l_result := false;
        ELSE
          l_rec.code_combination_id  := x_ccid;
        END IF;
      ELSE
        l_error_codes :=  l_error_codes || 'IB005,';
        l_result := false;
      END IF;


    END IF;

    -- valiadate analytical criterions
    OPEN c_is_valid_anal_crit_code
      (l_rec.analytical_criterion_code
      ,l_rec.analytical_criterion_type_code
      ,l_rec.amb_context_code);
      FETCH c_is_valid_anal_crit_code INTO l_test_value;

      IF (c_is_valid_anal_crit_code%NOTFOUND) THEN
         l_error_codes  :=  l_error_codes || 'IB016,';
         l_result := false;
      END IF;

    CLOSE c_is_valid_anal_crit_code;

    -- validate all AC rows 1-5 cannot be null
    IF (l_rec.AC1 IS NULL AND l_rec.AC2 IS NULL AND l_rec.AC3 IS NULL AND l_rec.AC4 IS NULL AND l_rec.AC5 IS NULL) THEN
       l_error_codes  :=  l_error_codes || 'IB017,';
       l_result := false;
    END IF;

    -- validate period
    OPEN c_is_valid_period(l_rec.application_id, l_rec.ledger_id, l_rec.period_name);
      FETCH c_is_valid_period INTO l_test_value;

      IF(c_is_valid_period%NOTFOUND) THEN
        l_error_codes :=  l_error_codes || 'IB011,';
        l_result := false;
      END IF;

    CLOSE c_is_valid_period;

    -- validate prior journal entries for a given period_name
    OPEN c_is_prior_je_exists(l_rec);
      FETCH c_is_prior_je_exists INTO l_test_value;

      IF (c_is_prior_je_exists%FOUND) THEN
         l_error_codes  :=  l_error_codes || 'IB012,';
         l_result := false;
      END IF;

    CLOSE c_is_prior_je_exists;

    --validate balances
    IF (l_rec.init_balance_dr IS NULL AND l_rec.init_balance_cr IS NULL ) THEN
       l_error_codes  :=  l_error_codes || 'IB013,';
       l_result := false;
    END IF;

    IF (l_rec.init_balance_dr < 0 OR l_rec.init_balance_cr < 0) THEN
       l_error_codes  :=  l_error_codes || 'IB014,';
       l_result := false;
    END IF;

    /*
     * Remove the last character if it is a comma
    */
    IF INSTR(l_error_codes,',',-1) = LENGTH(l_error_codes) THEN
      l_error_codes := SUBSTR(l_error_codes,1,LENGTH(l_error_codes)-1);
    END IF;
    p_message_codes  := l_error_codes;
    p_balances_int_rec  :=  l_rec;

    RETURN l_result;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_ac_balances_pkg.validate_balances_rec');
END validate_balances_rec;

PROCEDURE purge_interface_recs(
                               p_batch_code VARCHAR2,
                               p_purge_mode VARCHAR2
                              ) AS
------------------------------------------------------------------
--Created by  : veramach, Oracle India
--Date created:
--
--Purpose:
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------

BEGIN

    /*
     * Delete records based on p_purge_mode
     * If p_purge_mode = A, then delete all records for the p_batch_code passed
     * If p_purge_mode = S, then delete all records that were imported in this run
     * If p_purge_mode = N, then do not delete anything
     */
      DELETE      xla_ac_balances_int xib
            WHERE (   (    p_batch_code IS NOT NULL
                       AND p_batch_code = xib.batch_code)
                   OR (    p_batch_code IS NULL
                       AND 1 = 1))
              AND (   (    p_purge_mode = 'N'
                       AND 1 = 2)
                   OR (    p_purge_mode = 'S'
                       AND xib.status = 'IMPORTED')
                   OR (    p_purge_mode = 'A'
                       AND xib.status IN('IMPORTED', 'ERROR')));

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_ac_balances_pkg.purge_interface_recs');
END purge_interface_recs;

PROCEDURE update_balances
                        ( p_errbuf     OUT NOCOPY VARCHAR2
                         ,p_retcode    OUT NOCOPY NUMBER
                         ,p_batch_code IN         VARCHAR2
                         ,p_purge_mode IN         VARCHAR2
                        )
IS
BEGIN
  update_balances(p_batch_code,p_purge_mode);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   p_retcode := 2;
   p_errbuf := sqlerrm;
WHEN OTHERS                                   THEN
   p_retcode := 2;
   p_errbuf := sqlerrm;
END update_balances;


PROCEDURE update_balances
                        ( p_batch_code IN         VARCHAR2
                         ,p_purge_mode IN         VARCHAR2
                        )
IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|  Just the SRS wrapper                                                 |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|  Call update_balances            and assign its return code to        |
|  p_retcode                                                            |
|  RETURN p_retcode (0=success, 1=warning, 2=error)                     |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/

l_commit_flag     VARCHAR2(1);

l_log_module         VARCHAR2 (2000);
l_message_codes      xla_ac_balances_int.message_codes%TYPE;

  -- Get interface records
  CURSOR c_balances_int(
                        cp_batch_code VARCHAR2
                       ) IS
  SELECT xib.*
    FROM xla_ac_balances_int xib
   WHERE (   xib.status IS NULL
          OR xib.status = 'ERROR')
     AND (xib.batch_code = NVL(cp_batch_code, xib.batch_code))
    ORDER BY batch_code DESC
    FOR UPDATE OF status NOWAIT;

  l_balances_int_rec xla_ac_balances_int%ROWTYPE;
  l_sql_err VARCHAR2(1000);

  l_success_rec NUMBER := 0;
  l_error_rec   NUMBER := 0;
BEGIN

   fnd_file.put_line(fnd_file.log,'------------Parameters-----------');
   fnd_file.put_line(fnd_file.log,'Batch Code : '||p_batch_code);
   fnd_file.put_line(fnd_file.log,'Purge Mode : '||p_purge_mode);
   fnd_file.put_line(fnd_file.log,'---------------------------------');

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_balances';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   FOR l_balances_int_rec IN c_balances_int(p_batch_code) LOOP
   BEGIN
     fnd_file.new_line(fnd_file.log,2);
     fnd_file.put_line(fnd_file.log,'Processing record with:');
     fnd_file.put_line(fnd_file.log,'Supporting Reference Name : '||l_balances_int_rec.analytical_criterion_code);
     fnd_file.put_line(fnd_file.log,'Supporting Reference Type : '||l_balances_int_rec.analytical_criterion_type_code);
     fnd_file.put_line(fnd_file.log,'Supporting Reference 1    : '||l_balances_int_rec.ac1);
     fnd_file.put_line(fnd_file.log,'Supporting Reference 2    : '||l_balances_int_rec.ac2);
     fnd_file.put_line(fnd_file.log,'Supporting Reference 3    : '||l_balances_int_rec.ac3);
     fnd_file.put_line(fnd_file.log,'Supporting Reference 4    : '||l_balances_int_rec.ac4);
     fnd_file.put_line(fnd_file.log,'Supporting Reference 5    : '||l_balances_int_rec.ac5);
     fnd_file.put_line(fnd_file.log,'Period                    : '||l_balances_int_rec.period_name);

     IF NOT validate_balances_rec(l_balances_int_rec,l_message_codes) THEN
      /*
       * Some validations failed
       */
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_module => l_log_module
            ,p_msg      => 'validations failed with l_message_codes:'||l_message_codes
            ,p_level    => C_LEVEL_STATEMENT);
      END IF;
      fnd_file.put_line(fnd_file.log,'Import Failed with error codes: '||l_message_codes);
      fnd_file.new_line(fnd_file.log,2);
      UPDATE xla_ac_balances_int
         SET status = 'ERROR',
             message_codes = l_message_codes,
             last_updated_by = g_user_id,
             last_update_date = g_date,
             last_update_login = g_login_id
       WHERE CURRENT OF c_balances_int;
       l_error_rec := l_error_rec + 1;
     ELSE
      /*
       * All validations passed
       */

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
             (p_module => l_log_module
             ,p_msg      => 'validations succeeded'
             ,p_level    => C_LEVEL_STATEMENT);
       END IF;
       merge_balances_rec(l_balances_int_rec);
       /*
        * Successfully merged the records. Update the status of the interface record
        */
        fnd_file.put_line(fnd_file.log,'Import Succeeded');
        fnd_file.new_line(fnd_file.log,2);
        UPDATE xla_ac_balances_int
         SET status = 'IMPORTED',
             message_codes = NULL,
             last_updated_by = g_user_id,
             last_update_date = g_date,
             last_update_login = g_login_id
       WHERE CURRENT OF c_balances_int;
       l_success_rec := l_success_rec + 1;
     END IF;
     EXCEPTION
       WHEN CANT_DELETE_BALANCES THEN
          UPDATE xla_ac_balances_int
             SET status = 'ERROR',
                 message_codes = 'IB018',
                 last_updated_by = g_user_id,
                 last_update_date = g_date,
                 last_update_login = g_login_id
           WHERE CURRENT OF c_balances_int;
           l_error_rec := l_error_rec + 1;
       WHEN OTHERS THEN
          l_sql_err := SQLERRM;
          UPDATE xla_ac_balances_int
             SET status = 'ERROR',
                 message_codes = l_sql_err,
                 last_updated_by = g_user_id,
                 last_update_date = g_date,
                 last_update_login = g_login_id
           WHERE CURRENT OF c_balances_int;
           l_error_rec := l_error_rec + 1;
     END;
   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_ac_balances_pkg.update_balances');
END update_balances;

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

END xla_ac_balances_pkg;

/
