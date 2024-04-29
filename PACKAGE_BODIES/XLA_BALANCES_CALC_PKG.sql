--------------------------------------------------------
--  DDL for Package Body XLA_BALANCES_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_BALANCES_CALC_PKG" as
/* $Header: xlabacalc.pkb 120.0.12010000.12 2010/04/14 09:24:45 karamakr noship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_balances_calc_pkg                                              |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Balances Calculation Package                                   |
|                                                                       |
+======================================================================*/

   -- Private exceptions
   --
   le_resource_busy                EXCEPTION;
   PRAGMA EXCEPTION_INIT (le_resource_busy, -00054);

   --
   -- Private types
   --
   TYPE table_of_pls_integer IS TABLE OF PLS_INTEGER
      INDEX BY PLS_INTEGER;

   --
   --
   g_user_id                       INTEGER;
   g_login_id                      INTEGER;
   g_date                          DATE;
   g_prog_appl_id                  INTEGER;
   g_prog_id                       INTEGER;
   g_req_id                        INTEGER;
   g_cached_ledgers                table_of_pls_integer;
   g_cached_single_period          BOOLEAN;
   g_lock_flag                     VARCHAR2 (1)         DEFAULT 'N';
   g_preupdate_flag                VARCHAR2 (1);
   g_postupdate_flag               VARCHAR2 (1);

--
-- Cursor declarations
--
--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
   c_level_statement      CONSTANT NUMBER          := fnd_log.level_statement;
   c_level_procedure      CONSTANT NUMBER          := fnd_log.level_procedure;
   c_level_event          CONSTANT NUMBER              := fnd_log.level_event;
   c_level_exception      CONSTANT NUMBER          := fnd_log.level_exception;
   c_level_error          CONSTANT NUMBER              := fnd_log.level_error;
   c_level_unexpected     CONSTANT NUMBER         := fnd_log.level_unexpected;
   c_level_log_disabled   CONSTANT NUMBER               := 99;
   c_default_module       CONSTANT VARCHAR2 (240)
                                                := 'xla.plsql.xla_balances_calc_pkg';
   g_log_level                     NUMBER;
   g_log_enabled                   BOOLEAN;

PROCEDURE TRACE (p_module IN VARCHAR2, p_msg IN VARCHAR2, p_level IN NUMBER)
IS
   BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level)
   THEN
    fnd_log.MESSAGE (p_level, p_module);
   ELSIF p_level >= g_log_level
   THEN
    fnd_log.STRING (p_level, p_module, p_msg);
   END IF;
   EXCEPTION
   WHEN xla_exceptions_pkg.application_exception
   THEN
    RAISE;
   WHEN OTHERS
   THEN
    xla_exceptions_pkg.raise_message(p_location      => 'xla_balances_calc_pkg.trace');
END TRACE;

/*===============================================+
|                                                |
| Private Function                               |
|------------------                              |
| lock records in xla_bal_concurrency_control    |
|                                                |
|                                                |
+===============================================*/
FUNCTION lock_bal_concurrency_control (
p_application_id        IN   INTEGER
, p_ledger_id           IN   INTEGER
, p_entity_id           IN   INTEGER
, p_event_id            IN   INTEGER
, p_ae_header_id        IN   INTEGER
, p_ae_line_num         IN   INTEGER
, p_request_id          IN   INTEGER
, p_accounting_batch_id IN   INTEGER
, p_execution_mode      IN   VARCHAR2
, p_concurrency_class   IN   VARCHAR2
)
RETURN BOOLEAN
IS
l_log_module   VARCHAR2 (2000);
PRAGMA AUTONOMOUS_TRANSACTION;
l_insert_sql   VARCHAR2(2000);
BEGIN
    IF g_log_enabled
    THEN
     l_log_module := c_default_module || '.lock_bal_concurrency_control';
    END IF;

    IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => 'BEGIN ' || l_log_module
          , p_level       => c_level_procedure
           );
    END IF;

      IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => 'p_application_id ' || p_application_id
          , p_level       => c_level_procedure
           );
    END IF;
      IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => 'p_ledger_id ' || p_ledger_id
          , p_level       => c_level_procedure
           );
    END IF;
      IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => 'p_entity_id ' || p_entity_id
          , p_level       => c_level_procedure
           );
    END IF;
      IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => 'p_event_id ' || p_event_id
          , p_level       => c_level_procedure
           );
    END IF;
      IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => 'p_ae_header_id ' || p_ae_header_id
          , p_level       => c_level_procedure
           );
    END IF;
      IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => 'p_ae_line_num ' || p_ae_line_num
          , p_level       => c_level_procedure
           );
    END IF;
      IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => 'p_request_id ' || p_request_id
          , p_level       => c_level_procedure
           );
    END IF;
      IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => 'p_accounting_batch_id ' || p_accounting_batch_id
          , p_level       => c_level_procedure
           );
    END IF;
      IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => 'p_execution_mode ' || p_execution_mode
          , p_level       => c_level_procedure
           );
    END IF;
      IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => 'p_concurrency_class ' || p_concurrency_class
          , p_level       => c_level_procedure
           );
    END IF;

    IF p_ledger_id IS NOT NULL
    AND p_concurrency_class = 'BALANCES_CALCULATION'
    AND p_execution_mode = 'C'
    AND p_entity_id IS NULL
    AND p_event_id  IS NULL
    AND p_ae_header_id IS NULL
    AND p_ae_line_num IS NULL
    AND p_accounting_batch_id IS NULL
    THEN   -- For sandalone balance process
        INSERT INTO xla_bal_concurrency_control
                 (ledger_id
                , application_id
		, concurrency_class
                , accounting_batch_id
                , execution_mode
                , request_id
                 )
        SELECT   xah.ledger_id
               , xah.application_id
               , p_concurrency_class
               , xah.accounting_batch_id
               , p_execution_mode
               , p_request_id
            FROM xla_ae_headers xah
	       , xla_ae_lines xal
	       , gl_period_statuses gps
	       , xla_ledger_relationships_v xlr
           WHERE xah.application_id = p_application_id
             AND xah.ledger_id = p_ledger_id
             AND xah.ae_header_id = xal.ae_header_id
             AND xah.application_id = xal.application_id
             AND xah.accounting_batch_id IS NOT NULL
             -- to handle undo case. accounting_batch_id will be null if the entries were created by undo
             AND (   xal.analytical_balance_flag = 'P'
                  OR xal.control_balance_flag = 'P'
                 )
	     AND xah.accounting_entry_status_code ='F'
	     AND xah.ledger_id = xlr.ledger_id
	     AND gps.period_name = xah.period_name
	     AND gps.ledger_id = DECODE(xlr.ledger_category_code, 'ALC'
	                                , xlr.primary_ledger_id, xlr.ledger_id)
             AND gps.application_id=101
	     AND gps.closing_status in ('O','C','P')
	     AND gps.adjustment_period_flag = 'N'
        GROUP BY xah.application_id
               , xah.ledger_id
               , xah.accounting_batch_id;

    ELSIF p_concurrency_class = 'BALANCES_CALCULATION'
    THEN
      INSERT INTO xla_bal_concurrency_control
                  (ledger_id
                  ,application_id
                  ,concurrency_class
                  ,accounting_batch_id
                  ,execution_mode
                  ,request_id
                  )
            VALUES( p_ledger_id
                  ,p_application_id
                  ,p_concurrency_class
                  ,p_accounting_batch_id
                  ,p_execution_mode
                  ,p_request_id
		  );
    ELSIF p_concurrency_class <> 'BALANCES_CALCULATION'
    THEN -- open period balances program
      INSERT INTO xla_bal_concurrency_control
                 (ledger_id
                , concurrency_class
                , request_id
                 )
        VALUES (p_ledger_id
              , p_concurrency_class
              , p_request_id
                );

    END IF;

    IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => '# rows inserted into xla_bal_concurrency_control ' || SQL%ROWCOUNT
          , p_level       => c_level_procedure
           );
    END IF;

    IF (c_level_procedure >= g_log_level)
    THEN
     TRACE (p_module      => l_log_module
          , p_msg         => 'END ' || l_log_module
          , p_level       => c_level_procedure
           );
    END IF;

    COMMIT;
    RETURN TRUE;

EXCEPTION
WHEN le_resource_busy
THEN
 IF (c_level_error >= g_log_level)
 THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'Cannot lock XLA_BAL_CONCURRENCY_CONTROL'
         , p_level       => c_level_error
          );
 END IF;

 IF (c_level_procedure >= g_log_level)
 THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'END ' || l_log_module
         , p_level       => c_level_procedure
          );
 END IF;

 RAISE;
WHEN xla_exceptions_pkg.application_exception
THEN
 RAISE;
WHEN OTHERS
THEN
 xla_exceptions_pkg.raise_message
        (p_location      => 'xla_balances_calc_pkg.lock_bal_concurrency_control');
END lock_bal_concurrency_control;

/*===============================================+
|                                                |
|          Private Function                      |
+------------------------------------------------+
| Calculate Analaytical Balances                 |
|                                                |
+===============================================*/
FUNCTION calculate_analytical_balances ( p_application_id      IN   INTEGER
                                       , p_ledger_id           IN   INTEGER
                                       , p_entity_id           IN   INTEGER
                                       , p_event_id            IN   INTEGER
                                       , p_ae_header_id        IN   INTEGER
                                       , p_ae_line_num         IN   INTEGER
                                       , p_request_id          IN   INTEGER
                                       , p_accounting_batch_id IN   INTEGER
                                       , p_operation_code      IN   VARCHAR2
                                       , p_execution_mode      IN   VARCHAR2
                                       )
RETURN BOOLEAN
IS
  l_log_module              VARCHAR2 (240);
  l_processing_rows         NUMBER   := 0;
  l_rows_merged             NUMBER;
  l_row_count               NUMBER;
  l_update_bal              VARCHAR2(6000);
  l_insert_bal              VARCHAR2(6000);
  l_update_processed        VARCHAR2(5000);
  l_summary_bind_array      t_array_varchar;
  l_summary_bind_count      INTEGER :=1 ;
  l_processed_bind_array    t_array_varchar;
  l_processed_bind_count    INTEGER :=1 ;
  --
  l_summary_stmt VARCHAR2(7000):= 'INSERT INTO xla_ac_bal_interim_gt
                                              ( application_id
                                              , ledger_id
                                              , code_combination_id
                                              , analytical_criterion_code
                                              , analytical_criterion_type_code
                                              , amb_context_code
                                              , ac1
                                              , ac2
                                              , ac3
                                              , ac4
                                              , ac5
                                              , period_name
                                              , effective_period_num
                                              , period_balance_dr
                                              , period_balance_cr
                                              , period_year
                                              )
                                     SELECT   /*+ $parallel$ use_nl(aeh) use_nl(acs) use_nl(ael) */
                                              ael.application_id
                                            , ael.ledger_id
                                            , ael.code_combination_id
                                            , acs.analytical_criterion_code
                                            , acs.analytical_criterion_type_code
                                            , acs.amb_context_code
                                            , acs.ac1
                                            , acs.ac2
                                            , acs.ac3
                                            , acs.ac4
                                            , acs.ac5
                                            , aeh.period_name
                                            , gps.effective_period_num
                                            , $period_balance_dr$
                                            , $period_balance_cr$
                                            , SUBSTR (gps.effective_period_num, 1, 4) period_year
                                       FROM xla_ae_headers aeh
                                          , xla_ae_lines ael
                                          , xla_ae_line_acs acs
                                          , gl_period_statuses gps
                                          , xla_ledger_options xlo
                                          , xla_ledger_relationships_v xlr
                                          $bal_concurrency$
                                    WHERE aeh.application_id               = :'||l_summary_bind_count||'
                                      AND aeh.accounting_entry_status_code = ''F''
				      AND aeh.balance_type_code            = ''A''
                                      AND ael.application_id               = aeh.application_id
                                      AND ael.ae_header_id                 = aeh.ae_header_id
                                      AND ael.analytical_balance_flag      = '''||g_preupdate_flag||'''
                                      AND ael.ledger_id                    = aeh.ledger_id
                                      AND acs.ae_header_id                 = ael.ae_header_id
                                      AND acs.ae_line_num                  = ael.ae_line_num
                                      AND xlr.ledger_id                    = aeh.ledger_id
                                      AND xlo.application_id               = aeh.application_id
                                      AND xlo.ledger_id                    =  DECODE (xlr.ledger_category_code  , ''ALC''
                                                                                    , xlr.primary_ledger_id , xlr.ledger_id )
                                      AND gps.ledger_id                    = xlo.ledger_id
                                      AND gps.application_id               = 101
                                      AND gps.closing_status               IN (''O'', ''C'', ''P'')
                                      AND gps.effective_period_num         <= xlo.effective_period_num
                                      AND gps.adjustment_period_flag       = ''N''
                                      AND gps.period_name                  = aeh.period_name';
  l_group_by_stmt VARCHAR2(1000):= ' GROUP BY ael.application_id
                                   , ael.ledger_id
                                   , ael.code_combination_id
                                   , acs.analytical_criterion_code
                                   , acs.analytical_criterion_type_code
                                   , acs.amb_context_code
                                   , acs.ac1
                                   , acs.ac2
                                   , acs.ac3
                                   , acs.ac4
                                   , acs.ac5
                                   , aeh.period_name
                                   , gps.effective_period_num';
BEGIN
   IF g_log_enabled
   THEN
    l_log_module := c_default_module || '.calculate_analytical_balances';
   END IF;
   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'BEGIN ' || l_log_module
         , p_level       => c_level_procedure
          );
   END IF;
   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_application_id : ' || p_application_id
         , p_level       => c_level_exception
          );
   END IF;
   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_ledger_id : ' || p_ledger_id
         , p_level       => c_level_exception
          );
   END IF;
   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         =>    'p_accounting_batch_id : '
                            || p_accounting_batch_id
         , p_level       => c_level_exception
          );
   END IF;
   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_execution_mode : ' || p_execution_mode
         , p_level       => c_level_exception
          );
   END IF;
   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'request_id : ' || g_req_id
         , p_level       => c_level_exception
          );
   END IF;
   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_operation_code : ' || p_operation_code
         , p_level       => c_level_exception
          );
   END IF;

   l_summary_bind_array(l_summary_bind_count) := to_char(p_application_id);
   l_summary_bind_count := l_summary_bind_count+1;

   -- add dynamic conditions
   IF p_request_id IS NOT NULL AND p_request_id <> -1
   THEN
       l_summary_stmt := REPLACE (l_summary_stmt, '$bal_concurrency$', ',xla_bal_concurrency_control bcc');
           l_summary_stmt := l_summary_stmt || '
           AND bcc.request_id = :'||l_summary_bind_count||'
           AND bcc.accounting_batch_id = aeh.accounting_batch_id
           AND bcc.application_id = aeh.application_id';

	   l_summary_bind_array(l_summary_bind_count) := to_char(p_request_id);
           l_summary_bind_count := l_summary_bind_count+1;
   ELSE
        l_summary_stmt := REPLACE(l_summary_stmt,'$bal_concurrency$','');
   END IF;

   IF p_accounting_batch_id IS NOT NULL
   THEN
           l_summary_stmt := l_summary_stmt || '
           AND aeh.accounting_batch_id = :'||l_summary_bind_count;

	   l_summary_bind_array(l_summary_bind_count) := to_char(p_accounting_batch_id);
           l_summary_bind_count := l_summary_bind_count+1;
   END IF;

   IF p_ledger_id IS NOT NULL
           AND p_accounting_batch_id IS NULL
           AND p_event_id IS NULL
           AND p_entity_id IS NULL
           AND p_ae_header_id IS NULL
           AND p_ae_line_num IS NULL
   THEN
           l_summary_stmt := l_summary_stmt || '
           AND aeh.ledger_id = :'||l_summary_bind_count;

	   l_summary_bind_array(l_summary_bind_count) := to_char(p_ledger_id);
           l_summary_bind_count := l_summary_bind_count+1;
   END IF;

   IF p_entity_id IS NOT NULL
   THEN
       l_summary_stmt := l_summary_stmt || '
        AND aeh.entity_id = :'||l_summary_bind_count;

	l_summary_bind_array(l_summary_bind_count) := to_char(p_entity_id);
        l_summary_bind_count := l_summary_bind_count+1;
   END IF;

   IF p_event_id IS NOT NULL
   THEN
       l_summary_stmt := l_summary_stmt || '
        AND aeh.event_id = :'||l_summary_bind_count;

	l_summary_bind_array(l_summary_bind_count) := to_char(p_event_id);
        l_summary_bind_count := l_summary_bind_count+1;
   END IF;

   IF p_ae_header_id IS NOT NULL
   THEN
       l_summary_stmt := l_summary_stmt || '
       AND aeh.ae_header_id = :'||l_summary_bind_count;

       l_summary_bind_array(l_summary_bind_count) := to_char(p_ae_header_id);
       l_summary_bind_count := l_summary_bind_count+1;
   END IF;

   IF p_ae_line_num  IS NOT NULL
   THEN
       l_summary_stmt := l_summary_stmt || '
           AND ael.ae_line_num = :'||l_summary_bind_count;

       l_summary_bind_array(l_summary_bind_count) := to_char(p_ae_line_num);
       l_summary_bind_count := l_summary_bind_count+1;
   END IF;

   l_summary_bind_count := l_summary_bind_count-1;

   -- Replace perf. hint dynamically
   IF (nvl(fnd_profile.value('XLA_BAL_PARALLEL_MODE'),'N') ='Y') THEN
           l_summary_stmt := REPLACE(l_summary_stmt,'$parallel$','parallel(aeh)');
   ELSE
       l_summary_stmt := REPLACE(l_summary_stmt,'$parallel$','');
   END IF;

   IF p_operation_code = 'A' --Add
   THEN
           l_summary_stmt := REPLACE(l_summary_stmt,'$period_balance_dr$','SUM (NVL (ael.accounted_dr, 0)) period_balance_dr');
           l_summary_stmt := REPLACE(l_summary_stmt,'$period_balance_cr$','SUM (NVL (ael.accounted_cr, 0)) period_balance_cr');
   ELSIF p_operation_code = 'R' -- Remove
   THEN
           l_summary_stmt := REPLACE(l_summary_stmt,'$period_balance_dr$','SUM (NVL (ael.accounted_dr, 0)) * -1 period_balance_dr');
           l_summary_stmt := REPLACE(l_summary_stmt,'$period_balance_cr$','SUM (NVL (ael.accounted_cr, 0)) * -1 period_balance_cr');
   END IF;

     l_summary_stmt := l_summary_stmt || l_group_by_stmt;

   IF (c_level_procedure >= g_log_level)
   THEN
	     trace
	     (p_msg      => 'AC l_summary_stmt_1:'||substr(l_summary_stmt, 1, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'AC l_summary_stmt_2:'||substr(l_summary_stmt, 1001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'AC l_summary_stmt_3:'||substr(l_summary_stmt, 2001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'AC l_summary_stmt_4:'||substr(l_summary_stmt, 3001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'AC l_summary_stmt_5:'||substr(l_summary_stmt, 4001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'AC l_summary_stmt_6:'||substr(l_summary_stmt, 5001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
	     trace
	     (p_msg      => 'AC l_summary_stmt_7:'||substr(l_summary_stmt, 6001, 999)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
	     trace
	     (p_msg      => 'l_summary_bind_count : '||l_summary_bind_count
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);

   END IF;

   IF l_summary_bind_count = 1
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1);
   ELSIF l_summary_bind_count = 2
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2);
   ELSIF l_summary_bind_count = 3
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2),l_summary_bind_array(3);
   ELSIF l_summary_bind_count = 4
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2),l_summary_bind_array(3)
                       ,l_summary_bind_array(4);
   ELSIF l_summary_bind_count = 5
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2),l_summary_bind_array(3)
                       ,l_summary_bind_array(4), l_summary_bind_array(5);
   ELSIF l_summary_bind_count = 6
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2),l_summary_bind_array(3)
                       ,l_summary_bind_array(4), l_summary_bind_array(5), l_summary_bind_array(6);
   ELSIF l_summary_bind_count = 7
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2),l_summary_bind_array(3)
                       ,l_summary_bind_array(4), l_summary_bind_array(5), l_summary_bind_array(6)
		       , l_summary_bind_array(7);
   ELSIF l_summary_bind_count = 8
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2),l_summary_bind_array(3)
                       ,l_summary_bind_array(4), l_summary_bind_array(5), l_summary_bind_array(6)
		       , l_summary_bind_array(7), l_summary_bind_array(8);
   END IF;

   l_row_count := SQL%ROWCOUNT;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         =>    '# rows inserted in XLA_AC_BAL_INTERIM_GT : '
                            || SQL%ROWCOUNT
         , p_level       => c_level_procedure
          );
   END IF;

   IF l_row_count = 0
   THEN
    IF (c_level_procedure >= g_log_level)
    THEN
       TRACE (p_module      => l_log_module
            , p_msg         => 'No Records to process ' || SQL%ROWCOUNT
            , p_level       => c_level_procedure
             );
    END IF;

    RETURN TRUE;                                  --No records to process
   END IF;

   --
   --  Calculate the bgin balance and insert records into summary table for future periods
   --
   MERGE INTO xla_ac_bal_interim_gt stmp
    USING (SELECT period_balance_dr
                , period_balance_cr
                , SUM (lag_dr) OVER (PARTITION BY application_id, ledger_id, code_combination_id
                 , analytical_criterion_code, analytical_criterion_type_code, amb_context_code
                 , ac1, ac2, ac3, ac4, ac5 ORDER BY application_id, ledger_id
                 , code_combination_id
                 , analytical_criterion_code
                 , analytical_criterion_type_code
                 , amb_context_code
                 , ac1
                 , ac2
                 , ac3
                 , ac4
                 , ac5
                 , effective_period_num) xal_beginning_balance_dr
                 , SUM (lag_cr) OVER (PARTITION BY application_id, ledger_id, code_combination_id
                 , analytical_criterion_code, analytical_criterion_type_code
                 , amb_context_code, ac1, ac2, ac3, ac4, ac5
                   ORDER BY application_id, ledger_id,code_combination_id
                 , analytical_criterion_code
                 , analytical_criterion_type_code
                 , amb_context_code
                 , ac1
                 , ac2
                 , ac3
                 , ac4
                 , ac5
                 , effective_period_num) xal_beginning_balance_cr
                , application_id
                , ledger_id
                , code_combination_id
                , analytical_criterion_code
                , analytical_criterion_type_code
                , amb_context_code
                , ac1
                , ac2
                , ac3
                , ac4
                , ac5
                , period_name
                , effective_period_num
                , period_year
             FROM (SELECT   /*+  leading(xag,xal_bal)  */
                            xal_bal.application_id
                          , xal_bal.ledger_id
                          , xal_bal.code_combination_id
                                                     code_combination_id
                          , xal_bal.analytical_criterion_code
                          , xal_bal.analytical_criterion_type_code
                          , xal_bal.amb_context_code
                          , xal_bal.ac1
                          , xal_bal.ac2
                          , xal_bal.ac3
                          , xal_bal.ac4
                          , xal_bal.ac5
                          , xal_bal.period_name period_name
                          , xal_bal.effective_period_num
                          , xal_bal.period_balance_dr
                          , xal_bal.period_balance_cr
                          , xal_bal.period_year
                          , LAG (NVL (xal_bal.period_balance_dr, 0)
                               , 1
                               , NVL (xal_bal.beginning_balance_dr, 0)
                                ) OVER (PARTITION BY xal_bal.application_id, xal_bal.ledger_id
                           , xal_bal.code_combination_id, xal_bal.analytical_criterion_type_code
                           , xal_bal.amb_context_code, xal_bal.ac1, xal_bal.ac2, xal_bal.ac3, xal_bal.ac4
                           , xal_bal.ac5 ORDER BY xal_bal.application_id
                           , xal_bal.ledger_id
                           , xal_bal.code_combination_id
                           , xal_bal.analytical_criterion_code
                           , xal_bal.analytical_criterion_type_code
                           , xal_bal.amb_context_code
                           , xal_bal.ac1
                           , xal_bal.ac2
                           , xal_bal.ac3
                           , xal_bal.ac4
                           , xal_bal.ac5
                           , xal_bal.effective_period_num) lag_dr
                          , LAG (NVL (xal_bal.period_balance_cr, 0)
                               , 1
                               , NVL (xal_bal.beginning_balance_cr, 0)
                                ) OVER (PARTITION BY xal_bal.application_id, xal_bal.ledger_id
                           , xal_bal.code_combination_id, xal_bal.analytical_criterion_type_code
                           , xal_bal.amb_context_code, xal_bal.ac1, xal_bal.ac2, xal_bal.ac3
                           , xal_bal.ac4, xal_bal.ac5 ORDER BY xal_bal.application_id
                           , xal_bal.ledger_id
                           , xal_bal.code_combination_id
                           , xal_bal.analytical_criterion_code
                           , xal_bal.analytical_criterion_type_code
                           , xal_bal.amb_context_code
                           , xal_bal.ac1
                           , xal_bal.ac2
                           , xal_bal.ac3
                           , xal_bal.ac4
                           , xal_bal.ac5
                           , xal_bal.effective_period_num) lag_cr
                       FROM (SELECT   tmp.application_id
                                    , tmp.ledger_id
                                    , tmp.code_combination_id
                                    , tmp.analytical_criterion_code
                                    , tmp.analytical_criterion_type_code
                                    , tmp.amb_context_code
                                    , MAX
                                         (DECODE
                                               (gps.effective_period_num
                                              , tmp.effective_period_num, tmp.period_balance_dr
                                              , NULL
                                               )
                                         ) period_balance_dr
                                    , MAX
                                         (DECODE
                                               (gps.effective_period_num
                                              , tmp.effective_period_num, tmp.period_balance_cr
                                              , NULL
                                               )
                                         ) period_balance_cr
                                    , tmp.beginning_balance_dr
                                    , tmp.beginning_balance_cr
                                    , tmp.ac1
                                    , tmp.ac2
                                    , tmp.ac3
                                    , tmp.ac4
                                    , tmp.ac5
                                    , gps.period_name
                                    , gps.effective_period_num
                                    , gps.period_year
                                 FROM gl_period_statuses gps
                                    , xla_ac_bal_interim_gt tmp
                                                                            , xla_ledger_options xlo
                                                                            , xla_ledger_relationships_v xlr
                                WHERE gps.effective_period_num  <= xlo.effective_period_num
                                  AND gps.effective_period_num  >= tmp.effective_period_num
                                  AND gps.closing_status        IN ('O', 'C', 'P')
                                  AND gps.adjustment_period_flag = 'N'
                                  AND gps.application_id         = 101
                                  AND gps.ledger_id              = xlo.ledger_id
                                  AND xlo.application_id         = tmp.application_id
                                  AND tmp.ledger_id              = xlr.ledger_id
                                  AND xlo.ledger_id              = DECODE(xlr.ledger_category_code, 'ALC'
                                                                    , xlr.primary_ledger_id, tmp.ledger_id)
                             GROUP BY tmp.application_id
                                    , tmp.ledger_id
                                    , tmp.code_combination_id
                                    , tmp.analytical_criterion_code
                                    , tmp.analytical_criterion_type_code
                                    , tmp.amb_context_code
                                    , tmp.beginning_balance_dr
                                    , tmp.beginning_balance_cr
                                    , tmp.ac1
                                    , tmp.ac2
                                    , tmp.ac3
                                    , tmp.ac4
                                    , tmp.ac5
                                    , gps.period_name
                                    , gps.effective_period_num
                                    , gps.period_year) xal_bal
                   ORDER BY xal_bal.application_id
                          , xal_bal.ledger_id
                          , xal_bal.code_combination_id
                          , xal_bal.analytical_criterion_code
                          , xal_bal.analytical_criterion_type_code
                          , xal_bal.amb_context_code
                          , xal_bal.ac1
                          , xal_bal.ac2
                          , xal_bal.ac3
                          , xal_bal.ac4
                          , xal_bal.ac5
                          , xal_bal.effective_period_num
                          , xal_bal.period_year)) tmp
    ON (    stmp.application_id                     = tmp.application_id
        AND stmp.ledger_id                          = tmp.ledger_id
        AND stmp.code_combination_id                = tmp.code_combination_id
        AND stmp.analytical_criterion_code          = tmp.analytical_criterion_code
        AND stmp.analytical_criterion_type_code = tmp.analytical_criterion_type_code
        AND stmp.amb_context_code                           = tmp.amb_context_code
        AND NVL (stmp.ac1, ' ')                             = NVL (tmp.ac1, ' ')
        AND NVL (stmp.ac2, ' ')                 = NVL (tmp.ac2, ' ')
        AND NVL (stmp.ac3, ' ')                 = NVL (tmp.ac3, ' ')
        AND NVL (stmp.ac4, ' ')                 = NVL (tmp.ac4, ' ')
        AND NVL (stmp.ac5, ' ')                 = NVL (tmp.ac5, ' ')
        AND stmp.effective_period_num           = tmp.effective_period_num)
    WHEN MATCHED THEN
       UPDATE
          SET stmp.beginning_balance_dr = tmp.xal_beginning_balance_dr
            , stmp.beginning_balance_cr = tmp.xal_beginning_balance_cr
    WHEN NOT MATCHED THEN
       INSERT (stmp.application_id, stmp.ledger_id
             , stmp.code_combination_id, stmp.analytical_criterion_code
             , stmp.analytical_criterion_type_code
             , stmp.amb_context_code, stmp.ac1, stmp.ac2, stmp.ac3
             , stmp.ac4, stmp.ac5, stmp.period_balance_dr
             , stmp.period_balance_cr, stmp.beginning_balance_dr
             , stmp.beginning_balance_cr, stmp.period_name
             , stmp.effective_period_num, stmp.period_year)
       VALUES (tmp.application_id, tmp.ledger_id
             , tmp.code_combination_id, tmp.analytical_criterion_code
             , tmp.analytical_criterion_type_code, tmp.amb_context_code
             , tmp.ac1, tmp.ac2, tmp.ac3, tmp.ac4, tmp.ac5
             , tmp.period_balance_dr, tmp.period_balance_cr
             , tmp.xal_beginning_balance_dr
             , tmp.xal_beginning_balance_cr, tmp.period_name
             , tmp.effective_period_num, tmp.period_year);

   l_rows_merged := SQL%ROWCOUNT;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         =>    '# rows merged in XLA_AC_BAL_INTERIM_GT : '
                            || l_rows_merged
         , p_level       => c_level_procedure
          );
   END IF;

   --
   -- Update the BEGINNING BALANCE, PERIOD BALANCE into the xla_ac_balances  table if record already exists for that group.
   --
   l_update_bal := 'UPDATE /*+ index(b,xla_ac_balances_N99) */xla_ac_balances b
                   SET last_update_date           = '''||g_date||'''
		     , last_updated_by            = '||g_user_id||'
                     , last_update_login          = '||g_login_id||'
                     , program_update_date        = '''||g_date||'''
                     , program_application_id     = '||g_prog_appl_id||'
                     , program_id                 = '||g_prog_id||'
                     , request_id                 = '||g_req_id||'
		     ,(period_balance_dr, period_balance_cr
                      , beginning_balance_dr, beginning_balance_cr) = (SELECT /*+ $parallel$  index(tmp,xla_ac_bgnbal_gt_U1) */
                                                                                NVL (b.period_balance_dr, 0)
                                                                              + NVL (tmp.period_balance_dr, 0) period_balance_dr
                                                                            ,   NVL (b.period_balance_cr, 0)
                                                                              + NVL (tmp.period_balance_cr, 0) period_balance_cr
                                                                            ,   NVL (b.beginning_balance_dr, 0)
                                                                              + NVL (tmp.beginning_balance_dr, 0) beginning_balance_dr
                                                                            ,   NVL (b.beginning_balance_cr, 0)
                                                                              + NVL (tmp.beginning_balance_cr, 0) beginning_balance_cr
                                                                       FROM xla_ac_bal_interim_gt tmp
                                                                       WHERE tmp.application_id                   = b.application_id
                                                                           AND tmp.ledger_id                      = b.ledger_id
                                                                           AND tmp.code_combination_id            = b.code_combination_id
                                                                           AND tmp.analytical_criterion_code      = b.analytical_criterion_code
                                                                           AND tmp.analytical_criterion_type_code = b.analytical_criterion_type_code
                                                                           AND tmp.amb_context_code               = b.amb_context_code
                                                                           AND NVL (tmp.ac1, '' '')               = NVL (b.ac1, '' '')
                                                                           AND NVL (tmp.ac2, '' '')               = NVL (b.ac2, '' '')
                                                                           AND NVL (tmp.ac3, '' '')               = NVL (b.ac3, '' '')
                                                                           AND NVL (tmp.ac4, '' '')               = NVL (b.ac4, '' '')
                                                                           AND NVL (tmp.ac5, '' '')               = NVL (b.ac5, '' '')
                                                                           AND tmp.effective_period_num           = b.effective_period_num)
                    WHERE ( b.application_id
                          , b.ledger_id
                          , b.code_combination_id
                          , b.analytical_criterion_code
                          , b.analytical_criterion_type_code
                          , b.amb_context_code
                          , NVL (b.ac1, '' '')
                          , NVL (b.ac2, '' '')
                          , NVL (b.ac3, '' '')
                          , NVL (b.ac4, '' '')
                          , NVL (b.ac5, '' '')
                          , b.effective_period_num
                          ) IN (SELECT /*+ $parallel_1$ full(xal_bal1) */
                                         xal_bal1.application_id
                                       , xal_bal1.ledger_id
                                       , xal_bal1.code_combination_id
                                       , xal_bal1.analytical_criterion_code
                                       , xal_bal1.analytical_criterion_type_code
                                       , xal_bal1.amb_context_code
                                       , NVL (xal_bal1.ac1, '' '')
                                       , NVL (xal_bal1.ac2, '' '')
                                       , NVL (xal_bal1.ac3, '' '')
                                       , NVL (xal_bal1.ac4, '' '')
                                       , NVL (xal_bal1.ac5, '' '')
                                       , xal_bal1.effective_period_num
                                FROM xla_ac_bal_interim_gt xal_bal1)';

   -- Replace parallel hint based on the profile option
   IF (nvl(fnd_profile.value('XLA_BAL_PARALLEL_MODE'),'N') ='Y') THEN
     l_update_bal := REPLACE(l_update_bal,'$parallel$','parallel(tmp)');
     l_update_bal := REPLACE(l_update_bal,'$parallel_1$','parallel(xal_bal1)');
   ELSE
     l_update_bal := REPLACE(l_update_bal,'$parallel$','');
     l_update_bal := REPLACE(l_update_bal,'$parallel_1$','');
   END IF;

   IF (c_level_procedure >= g_log_level)
     THEN
	     trace
	     (p_msg      => 'AC l_update_bal_1:'||substr(l_update_bal, 1, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'AC l_update_bal_2:'||substr(l_update_bal, 1001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'AC l_update_bal_3:'||substr(l_update_bal, 2001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'AC l_update_bal_4:'||substr(l_update_bal, 3001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'AC l_update_bal_5:'||substr(l_update_bal, 4001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'AC l_update_bal_6:'||substr(l_update_bal, 5001, 999)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
   END IF;


   --Execute sql

   EXECUTE IMMEDIATE l_update_bal;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         =>    '# rows updated in xla_ac_balances : '
                            || SQL%ROWCOUNT
         , p_level       => c_level_procedure
          );
   END IF;

   --
   -- Insert record into xla_ac_balance if record does not exist
   --
   IF SQL%ROWCOUNT <> l_rows_merged
   THEN
    -- insert rows only if the rows updated is not equal to the total no of rows in gt table
    l_insert_bal := 'INSERT INTO xla_ac_balances xba
                              (  application_id
                               , ledger_id
                               , code_combination_id
                               , analytical_criterion_code
                               , analytical_criterion_type_code
                               , amb_context_code
                               , ac1
                               , ac2
                               , ac3
                               , ac4
                               , ac5
                               , period_name
                               , period_year
                               , first_period_flag
                               , period_balance_dr
                               , period_balance_cr
                               , beginning_balance_dr
                               , beginning_balance_cr
                               , initial_balance_flag
                               , effective_period_num
                               , creation_date
                               , created_by
                               , last_update_date
                               , last_updated_by
			       , last_update_login
			       , program_update_date
			       , program_application_id
			       , program_id
			       , request_id
                              )
                   SELECT /*+ $parallel$ */
                              temp.application_id
                            , temp.ledger_id
                            , temp.code_combination_id
                            , temp.analytical_criterion_code
                            , temp.analytical_criterion_type_code
                            , temp.amb_context_code
                            , temp.ac1
                            , temp.ac2
                            , temp.ac3
                            , temp.ac4
                            , temp.ac5
                            , gps.period_name
                            , gps.period_year
                            , DECODE (gps.period_num, 1, ''Y'', ''N'') first_period_flag
                            , temp.period_balance_dr
                            , temp.period_balance_cr
                            , temp.beginning_balance_dr
                            , temp.beginning_balance_cr
                            , ''N'' initial_balance_flag
                            , temp.effective_period_num
                            , '''||g_date||'''
                            , '||g_user_id||'
                            , '''||g_date||'''
                            , '||g_user_id||'
			    , '||g_login_id||'
			    , '''||g_date||'''
			    , '||g_prog_appl_id||'
			    , '||g_prog_id||'
			    , '||g_req_id||'
                    FROM xla_ac_bal_interim_gt temp
                       , xla_analytical_hdrs_b xbh
                       , gl_code_combinations gcc
                       , gl_period_statuses gps
                       , xla_ledger_relationships_v xlr
                   WHERE xlr.ledger_id  = temp.ledger_id
                      AND gps.ledger_id = DECODE(xlr.ledger_category_code,''ALC''
                                                ,xlr.primary_ledger_id , temp.ledger_id)
                      AND gps.effective_period_num = temp.effective_period_num
                      AND gps.application_id = 101
                      AND gps.adjustment_period_flag = ''N''
                      AND gps.closing_status IN (''O'', ''C'', ''P'')
                      AND gcc.code_combination_id = temp.code_combination_id
                      AND xbh.analytical_criterion_code = temp.analytical_criterion_code
                      AND xbh.analytical_criterion_type_code =  temp.analytical_criterion_type_code
                      AND xbh.amb_context_code = temp.amb_context_code
                      AND xbh.balancing_flag <> ''N''
                      AND (   gps.period_year =  SUBSTR (temp.effective_period_num, 1, 4)
                              OR xbh.year_end_carry_forward_code = ''A''
                              OR (    xbh.year_end_carry_forward_code = ''B''
                                      AND gcc.account_type IN (''A'', ''L'', ''O'')
                                  )
                           )
                      AND NOT EXISTS ( SELECT /*+ no_unnest $parallel_1$ */ 1
                                       FROM xla_ac_balances xba
                                       WHERE xba.application_id = temp.application_id
                                         AND xba.ledger_id = temp.ledger_id
                                         AND xba.code_combination_id =  temp.code_combination_id
                                         AND xba.analytical_criterion_code = temp.analytical_criterion_code
                                         AND xba.analytical_criterion_type_code = temp.analytical_criterion_type_code
                                         AND xba.amb_context_code = temp.amb_context_code
                                         AND NVL (xba.ac1, '' '') = NVL (temp.ac1, '' '')
                                         AND NVL (xba.ac2, '' '') = NVL (temp.ac2, '' '')
                                         AND NVL (xba.ac3, '' '') = NVL (temp.ac3, '' '')
                                         AND NVL (xba.ac4, '' '') = NVL (temp.ac4, '' '')
                                         AND NVL (xba.ac5, '' '') = NVL (temp.ac5, '' '')
                                         AND xba.period_name = gps.period_name)';

   -- Replace parallel hint based on profile option
   IF (nvl(fnd_profile.value('XLA_BAL_PARALLEL_MODE'),'N') ='Y') THEN
        l_insert_bal := REPLACE(l_insert_bal,'$parallel$','parallel(temp)');
        l_insert_bal := REPLACE(l_insert_bal,'$parallel_1$','parallel(xba)');
   ELSE
        l_insert_bal := REPLACE(l_insert_bal,'$parallel$','');
        l_insert_bal := REPLACE(l_insert_bal,'$parallel_1$','');
   END IF;

   IF (c_level_procedure >= g_log_level)
     THEN
	     trace
	     (p_msg      => 'AC l_insert_bal_1:'||substr(l_insert_bal, 1, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'AC l_insert_bal_2:'||substr(l_insert_bal, 1001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'AC l_insert_bal_3:'||substr(l_insert_bal, 2001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'AC l_insert_bal_4:'||substr(l_insert_bal, 3001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'AC l_insert_bal_5:'||substr(l_insert_bal, 4001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'AC l_insert_bal_6:'||substr(l_insert_bal, 5001, 999)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
   END IF;

   --Execute sql
    EXECUTE IMMEDIATE l_insert_bal;
   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         =>    ' # rows inserted into xla_ac_balances : '
                            || SQL%ROWCOUNT
         , p_level       => c_level_procedure
          );
   END IF;

   --
   --update records being processed to 'y' in xla_ae_lines
   --

   l_update_processed := 'UPDATE /*+ use_nl(ael) */xla_ae_lines ael
                                                     SET analytical_balance_flag   = '''||g_postupdate_flag||'''
                                                    WHERE application_id           = :'||l_processed_bind_count||'
                                                    AND analytical_balance_flag    = '''||g_preupdate_flag||'''
                                                    AND (ae_header_id,ae_line_num) IN
						                      ( SELECT /*+ $parallel$ leading(aeh)  */
                                                                              ael.ae_header_id
                                                                             ,ael.ae_line_num
                                                                         FROM xla_ae_headers aeh
                                                                                , xla_ae_lines ael
                                                                                , gl_period_statuses gps
                                                                                , xla_ledger_options xlo
                                                                                , xla_ledger_relationships_v xlr
                                                                                $bal_concurrency$
                                                                        WHERE aeh.accounting_entry_status_code = ''F''
                                                                          AND aeh.application_id               = :'||l_processed_bind_count||'
                                                                          AND aeh.ledger_id                    = xlr.ledger_id
                                                                          AND ael.ae_header_id                 = aeh.ae_header_id
									  AND aeh.balance_type_code            = ''A''
                                                                          AND ael.analytical_balance_flag      = '''||g_preupdate_flag||'''
                                                                          AND ael.application_id               = aeh.application_id
                                                                          AND xlo.ledger_id                    = DECODE(xlr.ledger_category_code, ''ALC''
                                                                                                                       ,xlr.primary_ledger_id, xlr.ledger_id)
                                                                          AND gps.ledger_id                    = xlo.ledger_id
                                                                          AND gps.application_id               = 101
                                                                          AND gps.closing_status               IN (''O'', ''C'', ''P'')
                                                                          AND gps.effective_period_num         <= xlo.effective_period_num
                                                                          AND gps.adjustment_period_flag       = ''N''
                                                                          AND gps.period_name                  = aeh.period_name
                                                                         ' ;
   l_processed_bind_array(l_processed_bind_count) := to_char(p_application_id);
   l_processed_bind_count := l_processed_bind_count+1;

   --Add dynamic conditions
   IF p_request_id IS NOT NULL AND p_request_id <> -1
   THEN
     l_update_processed := REPLACE(l_update_processed,'$bal_concurrency$',',xla_bal_concurrency_control bcc');
     l_update_processed := l_update_processed||
     ' AND bcc.request_id = :'||l_processed_bind_count||'
       AND bcc.accounting_batch_id          = aeh.accounting_batch_id
       AND bcc.application_id               = aeh.application_id' ;

       l_processed_bind_array(l_processed_bind_count) := to_char(p_request_id);
       l_processed_bind_count := l_processed_bind_count+1;

   ELSE
     l_update_processed := REPLACE(l_update_processed,'$bal_concurrency$','');
   END IF;

   IF p_accounting_batch_id IS NOT NULL
   THEN
     l_update_processed := l_update_processed||
   ' AND aeh.accounting_batch_id = :'||l_processed_bind_count;

     l_processed_bind_array(l_processed_bind_count) := to_char(p_accounting_batch_id);
     l_processed_bind_count := l_processed_bind_count+1;
   END IF;

   IF p_event_id IS NOT NULL
   THEN
     l_update_processed := l_update_processed||
   ' AND aeh.event_id  = :'||l_processed_bind_count;

     l_processed_bind_array(l_processed_bind_count) := to_char(p_event_id);
     l_processed_bind_count := l_processed_bind_count+1;
   END IF;

   IF p_entity_id IS NOT NULL
   THEN
   l_update_processed := l_update_processed||
   ' AND aeh.entity_id  = :'||l_processed_bind_count;

   l_processed_bind_array(l_processed_bind_count) := to_char(p_entity_id);
   l_processed_bind_count := l_processed_bind_count+1;
   END IF;
   IF p_ae_header_id IS NOT NULL
   THEN
   l_update_processed := l_update_processed||
   ' AND aeh.ae_header_id  = :'||l_processed_bind_count;

   l_processed_bind_array(l_processed_bind_count) := to_char(p_ae_header_id);
   l_processed_bind_count := l_processed_bind_count+1;

   END IF;
   IF p_ae_line_num IS NOT NULL
   THEN
   l_update_processed := l_update_processed||
   ' AND ael.ae_line_num  = :'||l_processed_bind_count;

   l_processed_bind_array(l_processed_bind_count) := to_char(p_ae_line_num);
   l_processed_bind_count := l_processed_bind_count+1;
   END IF;

   IF p_ledger_id IS NOT NULL
    AND p_accounting_batch_id IS NULL
    AND p_event_id IS NULL
    AND p_entity_id IS NULL
    AND p_ae_header_id IS NULL
    AND p_ae_line_num IS NULL
   THEN
    l_update_processed := l_update_processed || '
    AND aeh.ledger_id = :'||l_processed_bind_count;

    l_processed_bind_array(l_processed_bind_count) := to_char(p_ledger_id);
    l_processed_bind_count := l_processed_bind_count+1;
   END IF;

   l_processed_bind_count := l_processed_bind_count-1 ;

   l_update_processed := l_update_processed||')';

   -- Replace parallel hint based on the profile option
   IF (nvl(fnd_profile.value('XLA_BAL_PARALLEL_MODE'),'N') ='Y') THEN
   l_update_processed := REPLACE(l_update_processed,'$parallel$','parallel(aeh)');
   ELSE
   l_update_processed := REPLACE(l_update_processed,'$parallel$','');
   END IF;

   IF (c_level_procedure >= g_log_level)
     THEN
	     trace
	     (p_msg      => 'AC l_update_processed_1:'||substr(l_update_processed, 1, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'AC l_update_processed_2:'||substr(l_update_processed, 1001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'AC l_update_processed_3:'||substr(l_update_processed, 2001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'AC l_update_processed_4:'||substr(l_update_processed, 3001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'AC l_update_processed_5:'||substr(l_update_processed, 4001, 999)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
   END IF;

   -- Execute sql
   IF l_processed_bind_count =1
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1),l_processed_bind_array(1);
   ELSIF l_processed_bind_count =2
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1), l_processed_bind_array(1),l_processed_bind_array(2);
   ELSIF l_processed_bind_count =3
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1),l_processed_bind_array(1),l_processed_bind_array(2),l_processed_bind_array(3);
   ELSIF l_processed_bind_count =4
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1), l_processed_bind_array(1),l_processed_bind_array(2),l_processed_bind_array(3)
                       ,l_processed_bind_array(4);
   ELSIF l_processed_bind_count =5
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1),l_processed_bind_array(1),l_processed_bind_array(2),l_processed_bind_array(3)
                       ,l_processed_bind_array(4),l_processed_bind_array(5);
   ELSIF l_processed_bind_count =6
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1),l_processed_bind_array(1),l_processed_bind_array(2),l_processed_bind_array(3)
                       ,l_processed_bind_array(4),l_processed_bind_array(5),l_processed_bind_array(6);
   ELSIF l_processed_bind_count =7
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1),l_processed_bind_array(1),l_processed_bind_array(2),l_processed_bind_array(3)
                       ,l_processed_bind_array(4),l_processed_bind_array(5),l_processed_bind_array(6),l_processed_bind_array(7);
   ELSIF l_processed_bind_count =8
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1),l_processed_bind_array(1),l_processed_bind_array(2),l_processed_bind_array(3)
                       ,l_processed_bind_array(4),l_processed_bind_array(5),l_processed_bind_array(6),l_processed_bind_array(7)
		       ,l_processed_bind_array(8);
   END IF;


   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => '# Rows update in xla_ae_lines' || SQL%ROWCOUNT
         , p_level       => c_level_procedure
          );
   END IF;

   --
   --
   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'END ' || l_log_module
         , p_level       => c_level_procedure
          );
   END IF;

   RETURN TRUE;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
 ROLLBACK;

WHEN OTHERS
THEN
 ROLLBACK;
 xla_exceptions_pkg.raise_message
       (p_location      => 'xla_balances_calc_pkg.calculate_analytical_balances');
--
--
END calculate_analytical_balances;

/*===============================================+
|                                                |
|          Private Function                      |
+------------------------------------------------+
|      Calculate Control Balances                |
|                                                |
+===============================================*/
FUNCTION calculate_control_balances (   p_application_id      IN   INTEGER
                              , p_ledger_id           IN   INTEGER
                              , p_entity_id           IN   INTEGER
                              , p_event_id            IN   INTEGER
                              , p_ae_header_id        IN   INTEGER
                              , p_ae_line_num         IN   INTEGER
                              , p_request_id          IN   INTEGER
                              , p_accounting_batch_id IN   INTEGER
                              , p_operation_code      IN   VARCHAR2
                              , p_execution_mode      IN   VARCHAR2
                              )
RETURN BOOLEAN
IS
   l_log_module        VARCHAR2 (240);
   l_processing_rows   NUMBER         := 0;
   l_rows_merged       NUMBER;
   l_row_count         NUMBER;
   l_update_bal        VARCHAR2(6000);
   l_insert_bal        VARCHAR2(6000);
   l_update_processed  VARCHAR2(5000);
   l_summary_bind_array      t_array_varchar;
   l_summary_bind_count      INTEGER :=1 ;
   l_processed_bind_array    t_array_varchar;
   l_processed_bind_count    INTEGER :=1 ;

   l_summary_stmt VARCHAR2(6000):= 'INSERT INTO xla_ctrl_bal_interim_gt (
                                               application_id
                                             , ledger_id
                                             , code_combination_id
                                             , party_type_code
                                             , party_id
                                             , party_site_id
                                             , period_name
                                             , effective_period_num
                                             , period_balance_dr
                                             , period_balance_cr
                                             , period_year
                                            )
                                   SELECT   /*+ $parallel$ use_nl(aeh) use_nl(ael) */
                                               ael.application_id
                                             , ael.ledger_id
                                             , ael.code_combination_id
                                             , ael.party_type_code
                                             , ael.party_id
                                             , ael.party_site_id
                                             , gps.period_name
                                             , gps.effective_period_num
                                             , $period_balance_dr$
                                             , $period_balance_cr$
                                              , SUBSTR (gps.effective_period_num, 1, 4) period_year
                                      FROM xla_ae_headers aeh
                                         , xla_ae_lines ael
                                         , gl_period_statuses gps
                                         , xla_ledger_options xlo
                                         , xla_ledger_relationships_v xlr
                                           $bal_concurrency$
                                     WHERE aeh.application_id = :'||l_summary_bind_count||'
                                       AND aeh.accounting_entry_status_code = ''F''
				       AND aeh.balance_type_code            = ''A''
                                       AND ael.application_id = aeh.application_id
                                       AND ael.ae_header_id = aeh.ae_header_id
                                       AND ael.control_balance_flag = '''||g_preupdate_flag||'''
                                       AND ael.ledger_id = aeh.ledger_id
                                       AND xlr.ledger_id = aeh.ledger_id
                                       AND xlo.application_id = aeh.application_id
                                       AND xlo.ledger_id = DECODE (xlr.ledger_category_code , ''ALC''
                                                                 , xlr.primary_ledger_id , xlr.ledger_id )
                                       AND gps.ledger_id = xlo.ledger_id
                                       AND gps.application_id = 101
                                       AND gps.closing_status IN (''O'', ''C'', ''P'')
                                       AND gps.effective_period_num <= xlo.effective_period_num
                                       AND gps.adjustment_period_flag = ''N''
                                       AND gps.period_name = aeh.period_name';
   l_group_by_stmt VARCHAR2(1000):= ' GROUP BY ael.application_id
                                             , ael.ledger_id
                                             , ael.code_combination_id
                                             , ael.party_type_code
                                             , ael.party_id
                                             , ael.party_site_id
                                             , gps.period_name
                                             , gps.effective_period_num';
BEGIN
   IF g_log_enabled
   THEN
    l_log_module := c_default_module || '.calculate_control_balances';
   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'BEGIN ' || l_log_module
         , p_level       => c_level_procedure
          );
   END IF;
   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_application_id : ' || p_application_id
         , p_level       => c_level_exception
          );
   END IF;
   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_ledger_id : ' || p_ledger_id
         , p_level       => c_level_exception
          );
   END IF;
   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         =>    'p_accounting_batch_id : '
                            || p_accounting_batch_id
         , p_level       => c_level_exception
          );
   END IF;
   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_execution_mode : ' || p_execution_mode
         , p_level       => c_level_exception
          );
   END IF;
   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'request_id : ' || g_req_id
         , p_level       => c_level_exception
          );
   END IF;
     IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_event_id : ' || p_event_id
         , p_level       => c_level_exception
          );
   END IF;
     IF (c_level_exception >= g_log_level)
     THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_entity_id : ' || p_entity_id
         , p_level       => c_level_exception
          );
   END IF;
     IF (c_level_exception >= g_log_level)
     THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_ae_header_id : ' || p_ae_header_id
         , p_level       => c_level_exception
          );
   END IF;
     IF (c_level_exception >= g_log_level)
     THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_ae_line_num : ' || p_ae_line_num
         , p_level       => c_level_exception
          );
   END IF;
     IF (c_level_exception >= g_log_level)
     THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_operation_code : ' || p_operation_code
         , p_level       => c_level_exception
          );
   END IF;

   l_summary_bind_array(l_summary_bind_count) := to_char(p_application_id);
   l_summary_bind_count := l_summary_bind_count+1;

   -- add dynamic conditions
   IF p_request_id IS NOT NULL AND p_request_id <> -1
   THEN
   l_summary_stmt := REPLACE (l_summary_stmt, '$bal_concurrency$', ',xla_bal_concurrency_control bcc');
   l_summary_stmt := l_summary_stmt || '
   AND bcc.request_id = :'||l_summary_bind_count||'
   AND bcc.accounting_batch_id = aeh.accounting_batch_id
   AND bcc.application_id = aeh.application_id';

   l_summary_bind_array(l_summary_bind_count) := to_char(p_request_id);
   l_summary_bind_count := l_summary_bind_count+1;
   ELSE
   l_summary_stmt := REPLACE(l_summary_stmt,'$bal_concurrency$','');
   END IF;

   IF p_accounting_Batch_id IS NOT NULL
   THEN
   l_summary_stmt := l_summary_stmt || '
   AND aeh.accounting_batch_id = :'||l_summary_bind_count;

   l_summary_bind_array(l_summary_bind_count) := to_char(p_accounting_Batch_id);
   l_summary_bind_count := l_summary_bind_count+1;
   END IF;

   IF p_ledger_id IS NOT NULL
    AND p_accounting_batch_id IS NULL
    AND p_event_id IS NULL
    AND p_entity_id IS NULL
    AND p_ae_header_id IS NULL
    AND p_ae_line_num IS NULL
   THEN
   l_summary_stmt := l_summary_stmt || '
   AND aeh.ledger_id = :'||l_summary_bind_count;

   l_summary_bind_array(l_summary_bind_count) := to_char(p_ledger_id);
   l_summary_bind_count := l_summary_bind_count+1;
   END IF;

   IF p_entity_id IS NOT NULL
   THEN
     l_summary_stmt := l_summary_stmt || '
     AND aeh.entity_id = :'||l_summary_bind_count;

     l_summary_bind_array(l_summary_bind_count) := to_char(p_entity_id);
     l_summary_bind_count := l_summary_bind_count+1;
   END IF;

   IF p_event_id IS NOT NULL
   THEN
     l_summary_stmt := l_summary_stmt || '
     AND aeh.event_id = :'||l_summary_bind_count;

     l_summary_bind_array(l_summary_bind_count) := to_char(p_event_id);
     l_summary_bind_count := l_summary_bind_count+1;
   END IF;

   IF p_ae_header_id IS NOT NULL
   THEN
     l_summary_stmt := l_summary_stmt || '
     AND aeh.ae_header_id = :'||l_summary_bind_count;

     l_summary_bind_array(l_summary_bind_count) := to_char(p_ae_header_id);
     l_summary_bind_count := l_summary_bind_count+1;
   END IF;

   IF p_ae_line_num  IS NOT NULL
   THEN
     l_summary_stmt := l_summary_stmt || '
     AND ael.ae_line_num = :'||l_summary_bind_count;

     l_summary_bind_array(l_summary_bind_count) := to_char(p_ae_line_num);
     l_summary_bind_count := l_summary_bind_count+1;
   END IF;

   l_summary_bind_count := l_summary_bind_count-1;

   -- Replace perf. hint dynamically
   IF (nvl(fnd_profile.value('XLA_BAL_PARALLEL_MODE'),'N') ='Y') THEN
    l_summary_stmt := REPLACE(l_summary_stmt,'$parallel$','parallel(aeh)');
   ELSE
    l_summary_stmt := REPLACE(l_summary_stmt,'$parallel$','');
   END IF;

   IF p_operation_code = 'A' --Add
   THEN
      l_summary_stmt := REPLACE(l_summary_stmt,'$period_balance_dr$','SUM (NVL (ael.accounted_dr, 0)) period_balance_dr');
      l_summary_stmt := REPLACE(l_summary_stmt,'$period_balance_cr$','SUM (NVL (ael.accounted_cr, 0)) period_balance_cr');
   ELSIF p_operation_code = 'R' -- Remove
   THEN
      l_summary_stmt := REPLACE(l_summary_stmt,'$period_balance_dr$','SUM (NVL (ael.accounted_dr, 0)) * -1 period_balance_dr');
      l_summary_stmt := REPLACE(l_summary_stmt,'$period_balance_cr$','SUM (NVL (ael.accounted_cr, 0)) * -1 period_balance_cr');
   END IF;

   l_summary_stmt := l_summary_stmt || l_group_by_stmt;

   IF (c_level_procedure >= g_log_level)
     THEN
	     trace
	     (p_msg      => 'CTRL: l_summary_stmt_1:'||substr(l_summary_stmt, 1, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'CTRL: l_summary_stmt_2:'||substr(l_summary_stmt, 1001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'CTRL: l_summary_stmt_3:'||substr(l_summary_stmt, 2001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'CTRL: l_summary_stmt_4:'||substr(l_summary_stmt, 3001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'CTRL: l_summary_stmt_5:'||substr(l_summary_stmt, 4001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'CTRL: l_summary_stmt_6:'||substr(l_summary_stmt, 5001, 999)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
	     trace
	     (p_msg      => 'l_summary_bind_count : '||l_summary_bind_count
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
   END IF;


   IF l_summary_bind_count = 1
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1);
   ELSIF l_summary_bind_count = 2
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2);
   ELSIF l_summary_bind_count = 3
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2),l_summary_bind_array(3);
   ELSIF l_summary_bind_count = 4
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2),l_summary_bind_array(3)
                       ,l_summary_bind_array(4);
   ELSIF l_summary_bind_count = 5
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2),l_summary_bind_array(3)
                       ,l_summary_bind_array(4), l_summary_bind_array(5);
   ELSIF l_summary_bind_count = 6
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2),l_summary_bind_array(3)
                       ,l_summary_bind_array(4), l_summary_bind_array(5), l_summary_bind_array(6);
   ELSIF l_summary_bind_count = 7
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2),l_summary_bind_array(3)
                       ,l_summary_bind_array(4), l_summary_bind_array(5), l_summary_bind_array(6)
		       , l_summary_bind_array(7);
   ELSIF l_summary_bind_count = 8
   THEN
     EXECUTE IMMEDIATE l_summary_stmt USING l_summary_bind_array(1) , l_summary_bind_array(2),l_summary_bind_array(3)
                       ,l_summary_bind_array(4), l_summary_bind_array(5), l_summary_bind_array(6)
		       , l_summary_bind_array(7), l_summary_bind_array(8);
   END IF;

   l_row_count := SQL%ROWCOUNT;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         =>    '# rows inserted in xla_ctrl_bal_interim_gt : '
                            || SQL%ROWCOUNT
         , p_level       => c_level_procedure
          );
   END IF;

   IF l_row_count = 0
   THEN
   IF (c_level_procedure >= g_log_level)
   THEN
       TRACE (p_module      => l_log_module
            , p_msg         => 'No Records to process ' || SQL%ROWCOUNT
            , p_level       => c_level_procedure
             );
   END IF;

   RETURN TRUE;                                  --No records to process
   END IF;

   --
   --  Calculate the bgin balance and insert records into summary table for future periods
   --
   MERGE INTO xla_ctrl_bal_interim_gt stmp
    USING (SELECT period_balance_dr
                , period_balance_cr
                , SUM (lag_dr) OVER (PARTITION BY application_id, ledger_id, code_combination_id
                , party_type_code, party_id, party_site_id
                  ORDER BY application_id
                 , ledger_id
                 , code_combination_id
                 , party_type_code
                 , party_id
                 , party_site_id
                 , effective_period_num) xal_beginning_balance_dr
                 , SUM (lag_cr) OVER (PARTITION BY application_id, ledger_id, code_combination_id
                 , party_type_code, party_id, party_site_id
                  ORDER BY application_id
                 , ledger_id
                 , code_combination_id
                 , party_type_code
                 , party_id
                 , party_site_id
                 , effective_period_num) xal_beginning_balance_cr
                , application_id
                , ledger_id
                , code_combination_id
                , party_type_code
                , party_id
                , party_site_id
                , period_name
                , effective_period_num
                , period_year
             FROM (SELECT   /*+  leading(xag,xal_bal)  */
                            xal_bal.application_id
                          , xal_bal.ledger_id
                          , xal_bal.code_combination_id
                          , xal_bal.party_type_code
                          , xal_bal.party_id
                          , xal_bal.party_site_id
                          , xal_bal.period_name
                          , xal_bal.effective_period_num
                          , xal_bal.period_balance_dr
                          , xal_bal.period_balance_cr
                          , xal_bal.period_year
                          , LAG (NVL (xal_bal.period_balance_dr, 0)
                               , 1
                               , NVL (xal_bal.beginning_balance_dr, 0)
                                ) OVER (PARTITION BY xal_bal.application_id, xal_bal.ledger_id
                                , xal_bal.code_combination_id, xal_bal.party_type_code
                                , xal_bal.party_id, xal_bal.party_site_id
                                ORDER BY xal_bal.application_id
                           , xal_bal.ledger_id
                           , xal_bal.code_combination_id
                           , xal_bal.party_type_code
                           , xal_bal.party_id
                           , xal_bal.party_site_id
                           , xal_bal.effective_period_num) lag_dr
                          , LAG (NVL (xal_bal.period_balance_cr, 0)
                               , 1
                               , NVL (xal_bal.beginning_balance_cr, 0)
                                ) OVER (PARTITION BY xal_bal.application_id, xal_bal.ledger_id
                                , xal_bal.code_combination_id, xal_bal.party_type_code
                                , xal_bal.party_id, xal_bal.party_site_id
                                ORDER BY xal_bal.application_id
                           , xal_bal.ledger_id
                           , xal_bal.code_combination_id
                           , xal_bal.party_type_code
                           , xal_bal.party_id
                           , xal_bal.party_site_id
                           , xal_bal.effective_period_num) lag_cr
                       FROM (SELECT   tmp.application_id
                                    , tmp.ledger_id
                                    , tmp.code_combination_id
                                    , tmp.party_type_code
                                    , tmp.party_id
                                    , tmp.party_site_id
                                    , MAX
                                         (DECODE
                                               (gps.effective_period_num
                                              , tmp.effective_period_num, tmp.period_balance_dr
                                              , NULL
                                               )
                                         ) period_balance_dr
                                    , MAX
                                         (DECODE
                                               (gps.effective_period_num
                                              , tmp.effective_period_num, tmp.period_balance_cr
                                              , NULL
                                               )
                                         ) period_balance_cr
                                    , tmp.beginning_balance_dr
                                    , tmp.beginning_balance_cr
                                    , gps.period_name
                                    , gps.effective_period_num
                                    , gps.period_year
                                 FROM gl_period_statuses gps
                                    , xla_ctrl_bal_interim_gt tmp
                                    , xla_ledger_options xlo
                                    , xla_ledger_relationships_v xlr
                                WHERE gps.effective_period_num <= xlo.effective_period_num
                                AND gps.effective_period_num >=   tmp.effective_period_num
                                  AND gps.closing_status IN ('O', 'C', 'P')
                                  AND gps.adjustment_period_flag = 'N'
                                  AND gps.application_id = 101
                                  AND gps.ledger_id = xlo.ledger_id
                                  AND tmp.application_id = xlo.application_id
                                  AND tmp.ledger_id = xlr.ledger_id
                                  AND xlo.ledger_id = DECODE(xlr.ledger_category_code, 'ALC'
				                            ,xlr.primary_ledger_id, xlr.ledger_id)
                             GROUP BY tmp.application_id
                                    , tmp.ledger_id
                                    , tmp.code_combination_id
                                    , tmp.party_type_code
                                    , tmp.party_id
                                    , tmp.party_site_id
                                    , tmp.beginning_balance_dr
                                    , tmp.beginning_balance_cr
                                    , gps.period_name
                                    , gps.effective_period_num
                                    , gps.period_year) xal_bal
                   ORDER BY xal_bal.application_id
                          , xal_bal.ledger_id
                          , xal_bal.code_combination_id
                          , xal_bal.party_type_code
                          , xal_bal.party_id
                          , xal_bal.party_site_id
                          , xal_bal.effective_period_num
                          , xal_bal.period_year)) tmp
    ON (    stmp.application_id = tmp.application_id
        AND stmp.ledger_id = tmp.ledger_id
        AND stmp.code_combination_id = tmp.code_combination_id
        AND stmp.party_type_code = tmp.party_type_code
        AND stmp.party_id = tmp.party_id
        AND stmp.party_site_id = tmp.party_site_id
        AND stmp.effective_period_num = tmp.effective_period_num)
    WHEN MATCHED THEN
       UPDATE
          SET stmp.beginning_balance_dr = tmp.xal_beginning_balance_dr
            , stmp.beginning_balance_cr = tmp.xal_beginning_balance_cr
    WHEN NOT MATCHED THEN
       INSERT (stmp.application_id, stmp.ledger_id
             , stmp.code_combination_id, stmp.party_type_code
             , stmp.party_id, stmp.party_site_id, stmp.period_balance_dr
             , stmp.period_balance_cr, stmp.beginning_balance_dr
             , stmp.beginning_balance_cr, stmp.period_name
             , stmp.effective_period_num, stmp.period_year)
       VALUES (tmp.application_id, tmp.ledger_id
             , tmp.code_combination_id, tmp.party_type_code
             , tmp.party_id, tmp.party_site_id, tmp.period_balance_dr
             , tmp.period_balance_cr, tmp.xal_beginning_balance_dr
             , tmp.xal_beginning_balance_cr, tmp.period_name
             , tmp.effective_period_num, tmp.period_year);

   l_rows_merged := SQL%ROWCOUNT;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         =>    '# rows merged in xla_ctrl_bal_interim_gt : '
                            || l_rows_merged
         , p_level       => c_level_procedure
          );
   END IF;

   --
   --
   -- Update the BEGINNING BALANCE, PERIOD BALANCE into the xla_control_balances  table if record already exists for that group.
   --
   l_update_bal := 'UPDATE /*+ ordered index(b,xla_control_balances_N99) */xla_control_balances b
    SET last_update_date           = '''||g_date||'''
      , last_updated_by            = '||g_user_id||'
      , last_update_login          = '||g_login_id||'
      , program_update_date        = '''||g_date||'''
      , program_application_id     = '||g_prog_appl_id||'
      , program_id                 = '||g_prog_id||'
      , request_id                 = '||g_req_id||'
      ,(period_balance_dr, period_balance_cr, beginning_balance_dr
       , beginning_balance_cr) =
           (SELECT /*+ $parallel$ index(tmp,xla_ctrl_bal_interim_gt_U1) */
                     NVL (b.period_balance_dr, 0)
                   + NVL (tmp.period_balance_dr, 0) period_balance_dr
                 ,   NVL (b.period_balance_cr, 0)
                   + NVL (tmp.period_balance_cr, 0) period_balance_cr
                 ,   NVL (b.beginning_balance_dr, 0)
                   + NVL (tmp.beginning_balance_dr, 0) beginning_balance_dr
                 ,   NVL (b.beginning_balance_cr, 0)
                   + NVL (tmp.beginning_balance_cr, 0) beginning_balance_cr
              FROM xla_ctrl_bal_interim_gt tmp
             WHERE tmp.application_id = b.application_id
               AND tmp.ledger_id = b.ledger_id
               AND tmp.code_combination_id = b.code_combination_id
               AND tmp.party_type_code = b.party_type_code
               AND tmp.party_id = b.party_id
               AND tmp.party_site_id = b.party_site_id
               AND tmp.effective_period_num = b.effective_period_num)
   WHERE (b.application_id
       , b.ledger_id
       , b.code_combination_id
       , b.party_type_code
       , b.party_id
       , b.party_site_id
       , b.effective_period_num
        ) IN (
           SELECT /*+ $parallel_1$ full(xal_bal1) */
                  xal_bal1.application_id
                , xal_bal1.ledger_id
                , xal_bal1.code_combination_id
                , xal_bal1.party_type_code
                , xal_bal1.party_id
                , xal_bal1.party_site_id
                , xal_bal1.effective_period_num
             FROM xla_ctrl_bal_interim_gt xal_bal1)';

   -- Replace parallel hint based on the profile option
   IF (nvl(fnd_profile.value('XLA_BAL_PARALLEL_MODE'),'N') ='Y') THEN
   l_update_bal := REPLACE(l_update_bal,'$parallel$','parallel(tmp)');
   l_update_bal := REPLACE(l_update_bal,'$parallel_1$','parallel(xal_bal1)');
   ELSE
   l_update_bal := REPLACE(l_update_bal,'$parallel$','');
   l_update_bal := REPLACE(l_update_bal,'$parallel_1$','');
   END IF;

   IF (c_level_procedure >= g_log_level)
     THEN
	     trace
	     (p_msg      => 'CTRL: l_update_bal_1:'||substr(l_update_bal, 1, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'CTRL: l_update_bal_2:'||substr(l_update_bal, 1001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'CTRL: l_update_bal_3:'||substr(l_update_bal, 2001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'CTRL: l_update_bal_4:'||substr(l_update_bal, 3001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'CTRL: l_update_bal_5:'||substr(l_update_bal, 4001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'CTRL: l_update_bal_6:'||substr(l_update_bal, 5001, 999)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
   END IF;
   --Execute sql

   EXECUTE IMMEDIATE l_update_bal;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         =>    '# rows updated in xla_control_balances : '
                            || SQL%ROWCOUNT
         , p_level       => c_level_procedure
          );
   END IF;

   --
   -- Insert record into xla_control_balance if record does not exist
   --
   IF SQL%ROWCOUNT <> l_rows_merged
   THEN
   -- insert rows only if the rows updated is not equal to the total no of rows in gt table
   l_insert_bal := 'INSERT INTO xla_control_balances xba (
                               application_id
                             , ledger_id
                             , code_combination_id
                             , party_type_code
                             , party_id
                             , party_site_id
                             , period_name
                             , period_year
                             , first_period_flag
                             , period_balance_dr
                             , period_balance_cr
                             , beginning_balance_dr
                             , beginning_balance_cr
                             , initial_balance_flag
                             , effective_period_num
                             , creation_date
                             , created_by
                             , last_update_date
                             , last_updated_by
			     , last_update_login
			     , program_update_date
			     , program_application_id
			     , program_id
			     , request_id
                            )
                   SELECT /*+ $parallel$ */
                              temp.application_id
                            , temp.ledger_id
                            , temp.code_combination_id
                            , temp.party_type_code
                            , temp.party_id
                            , temp.party_site_id
                            , gps.period_name
                            , gps.period_year
                            , DECODE (gps.period_num, 1, ''Y'', ''N'') first_period_flag
                            , temp.period_balance_dr
                            , temp.period_balance_cr
                            , temp.beginning_balance_dr
                            , temp.beginning_balance_cr
                            , ''N'' initial_balance_flag
                            , temp.effective_period_num
                            , '''||g_date||'''
                            , '||g_user_id||'
                            , '''||g_date||'''
                            , '||g_user_id||'
			    , '||g_login_id||'
			    , '''||g_date||'''
			    , '||g_prog_appl_id||'
			    , '||g_prog_id||'
			    , '||g_req_id||'
                     FROM xla_ctrl_bal_interim_gt temp
                        , gl_period_statuses gps
                        , xla_ledger_relationships_v xlr
                    WHERE xlr.ledger_id = temp.ledger_id
                      AND gps.ledger_id = DECODE(xlr.ledger_category_code, ''ALC''
                                                ,xlr.primary_ledger_id , xlr.ledger_id)
                      AND gps.effective_period_num = temp.effective_period_num
                      AND gps.application_id = 101
                      AND gps.adjustment_period_flag = ''N''
                      AND gps.closing_status IN (''O'', ''C'', ''P'')
                      AND NOT EXISTS ( SELECT /*+ no_unnest $parallel_1$ */ 1
                                         FROM xla_control_balances xba
                                        WHERE xba.application_id = temp.application_id
                                          AND xba.ledger_id = temp.ledger_id
                                          AND xba.code_combination_id = temp.code_combination_id
                                          AND xba.party_type_code = temp.party_type_code
                                          AND xba.party_id = temp.party_id
                                          AND xba.party_site_id = temp.party_site_id
                                          AND xba.period_name = temp.period_name)';

   -- Replace parallel hint based on profile option
   IF (nvl(fnd_profile.value('XLA_BAL_PARALLEL_MODE'),'N') ='Y') THEN
    l_insert_bal := REPLACE(l_insert_bal,'$parallel$','parallel(temp)');
    l_insert_bal := REPLACE(l_insert_bal,'$parallel_1$','parallel(xba)');
   ELSE
    l_insert_bal := REPLACE(l_insert_bal,'$parallel$','');
    l_insert_bal := REPLACE(l_insert_bal,'$parallel_1$','');
   END IF;

   IF (c_level_procedure >= g_log_level)
     THEN
	     trace
	     (p_msg      => 'CTRL: l_insert_bal_1:'||substr(l_insert_bal, 1, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'CTRL: l_insert_bal_2:'||substr(l_insert_bal, 1001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'CTRL: l_insert_bal_3:'||substr(l_insert_bal, 2001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'CTRL: l_insert_bal_4:'||substr(l_insert_bal, 3001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'CTRL: l_insert_bal_5:'||substr(l_insert_bal, 4001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'CTRL: l_insert_bal_6:'||substr(l_insert_bal, 5001, 999)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
   END IF;

   --Execute sql
   EXECUTE IMMEDIATE l_insert_bal;
   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         =>    ' # rows inserted into xla_control_balances : '
                            || SQL%ROWCOUNT
         , p_level       => c_level_procedure
          );
   END IF;

   --
   --update records processed to 'Y' in xla_ae_lines
   --
   l_update_processed := 'UPDATE /*+ use_nl(ael) */xla_ae_lines ael
                     SET control_balance_flag   = '''||g_postupdate_flag||'''
                    WHERE application_id        = :'||l_processed_bind_count||'
                    AND control_balance_flag    = '''||g_preupdate_flag||'''
                    AND (ae_header_id,ae_line_num) IN ( SELECT /*+ $parallel$ leading(aeh)  */
                                                              ael.ae_header_id
                                                             ,ael.ae_line_num
                                                         FROM xla_ae_headers aeh
                                                            , xla_ae_lines ael
                                                            , gl_period_statuses gps
                                                            , xla_ledger_options xlo
                                                            , xla_ledger_relationships_v xlr
                                                              $bal_concurrency$
                                                        WHERE aeh.accounting_entry_status_code = ''F''
                                                          AND aeh.application_id               = :'||l_processed_bind_count||'
							  AND aeh.balance_type_code            = ''A''
                                                          AND aeh.ledger_id                    = xlr.ledger_id
                                                          AND ael.ae_header_id                 = aeh.ae_header_id
                                                          AND ael.control_balance_flag      = '''||g_preupdate_flag||'''
                                                          AND ael.application_id               = aeh.application_id
                                                          AND xlo.ledger_id                    = DECODE(xlr.ledger_category_code, ''ALC''
                                                                                                       ,xlr.primary_ledger_id, xlr.ledger_id)
                                                          AND gps.ledger_id                    = xlo.ledger_id
                                                          AND gps.application_id               = 101
                                                          AND gps.closing_status               IN (''O'', ''C'', ''P'')
                                                          AND gps.effective_period_num         <= xlo.effective_period_num
                                                          AND gps.adjustment_period_flag       = ''N''
                                                          AND gps.period_name                  = aeh.period_name' ;

   l_processed_bind_array(l_processed_bind_count) := to_char(p_application_id);
   l_processed_bind_count := l_processed_bind_count+1;

   --Add dynamic conditions
   IF p_request_id IS NOT NULL AND p_request_id <> -1
   THEN
    l_update_processed := REPLACE(l_update_processed,'$bal_concurrency$',',xla_bal_concurrency_control bcc');
    l_update_processed := l_update_processed||
    ' AND bcc.request_id = :'||l_processed_bind_count||'
    AND bcc.accounting_batch_id          = aeh.accounting_batch_id
    AND bcc.application_id               = aeh.application_id' ;

    l_processed_bind_array(l_processed_bind_count) := to_char(p_request_id);
    l_processed_bind_count := l_processed_bind_count+1;
   ELSE
     l_update_processed := REPLACE(l_update_processed,'$bal_concurrency$','');
   END IF;

   IF p_accounting_batch_id IS NOT NULL
   THEN
    l_update_processed := l_update_processed||
    ' AND aeh.accounting_batch_id = :'||l_processed_bind_count;

    l_processed_bind_array(l_processed_bind_count) := to_char(p_accounting_batch_id);
    l_processed_bind_count := l_processed_bind_count+1;
   END IF;

   IF p_event_id IS NOT NULL
   THEN
     l_update_processed := l_update_processed||
   ' AND aeh.event_id  = :'||l_processed_bind_count;

    l_processed_bind_array(l_processed_bind_count) := to_char(p_event_id);
    l_processed_bind_count := l_processed_bind_count+1;
   END IF;

   IF p_entity_id IS NOT NULL
   THEN
     l_update_processed := l_update_processed||
   ' AND aeh.entity_id  = :'||l_processed_bind_count;

     l_processed_bind_array(l_processed_bind_count) := to_char(p_entity_id);
     l_processed_bind_count := l_processed_bind_count+1;
   END IF;
   IF p_ae_header_id IS NOT NULL
   THEN
     l_update_processed := l_update_processed||
   ' AND aeh.ae_header_id  = :'||l_processed_bind_count;

     l_processed_bind_array(l_processed_bind_count) := to_char(p_ae_header_id);
     l_processed_bind_count := l_processed_bind_count+1;
   END IF;
   IF p_ae_line_num IS NOT NULL
   THEN
     l_update_processed := l_update_processed||
   ' AND ael.ae_line_num  = :'||l_processed_bind_count;

     l_processed_bind_array(l_processed_bind_count) := to_char(p_ae_line_num);
     l_processed_bind_count := l_processed_bind_count+1;
   END IF;

   IF p_ledger_id IS NOT NULL
   AND p_accounting_batch_id IS NULL
   AND p_event_id IS NULL
   AND p_entity_id IS NULL
   AND p_ae_header_id IS NULL
   AND p_ae_line_num IS NULL
   THEN
     l_update_processed := l_update_processed || '
     AND aeh.ledger_id = :'||l_processed_bind_count;

     l_processed_bind_array(l_processed_bind_count) := to_char(p_ledger_id);
     l_processed_bind_count := l_processed_bind_count+1;
   END IF;

   l_processed_bind_count := l_processed_bind_count-1;

   l_update_processed := l_update_processed||')';

   -- Replace parallel hint based on the profile option
   IF (nvl(fnd_profile.value('XLA_BAL_PARALLEL_MODE'),'N') ='Y') THEN
   l_update_processed := REPLACE(l_update_processed,'$parallel$','parallel(aeh)');
   ELSE
   l_update_processed := REPLACE(l_update_processed,'$parallel$','');
   END IF;

   IF (c_level_procedure >= g_log_level)
     THEN
	     trace
	     (p_msg      => 'CTRL: l_update_processed_1:'||substr(l_update_processed, 1, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'CTRL: l_update_processed_2:'||substr(l_update_processed, 1001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'CTRL: l_update_processed_3:'||substr(l_update_processed, 2001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
     	     trace
	     (p_msg      => 'CTRL: l_update_processed_4:'||substr(l_update_processed, 3001, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
    	     trace
	     (p_msg      => 'CTRL: l_update_processed_5:'||substr(l_update_processed, 4001, 999)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
	     trace
	     (p_msg      => 'l_processed_bind_count : '||l_processed_bind_count
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);

   END IF;
   -- Execute sql
   IF l_processed_bind_count =1
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1),l_processed_bind_array(1);
   ELSIF l_processed_bind_count =2
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1), l_processed_bind_array(1),l_processed_bind_array(2);
   ELSIF l_processed_bind_count =3
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1),l_processed_bind_array(1),l_processed_bind_array(2),l_processed_bind_array(3);
   ELSIF l_processed_bind_count =4
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1), l_processed_bind_array(1),l_processed_bind_array(2),l_processed_bind_array(3)
                       ,l_processed_bind_array(4);
   ELSIF l_processed_bind_count =5
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1),l_processed_bind_array(1),l_processed_bind_array(2),l_processed_bind_array(3)
                       ,l_processed_bind_array(4),l_processed_bind_array(5);
   ELSIF l_processed_bind_count =6
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1),l_processed_bind_array(1),l_processed_bind_array(2),l_processed_bind_array(3)
                       ,l_processed_bind_array(4),l_processed_bind_array(5),l_processed_bind_array(6);
   ELSIF l_processed_bind_count =7
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1),l_processed_bind_array(1),l_processed_bind_array(2),l_processed_bind_array(3)
                       ,l_processed_bind_array(4),l_processed_bind_array(5),l_processed_bind_array(6),l_processed_bind_array(7);
   ELSIF l_processed_bind_count =8
   THEN
     EXECUTE IMMEDIATE l_update_processed USING l_processed_bind_array(1),l_processed_bind_array(1),l_processed_bind_array(2),l_processed_bind_array(3)
                       ,l_processed_bind_array(4),l_processed_bind_array(5),l_processed_bind_array(6),l_processed_bind_array(7)
		       ,l_processed_bind_array(8);
   END IF;
   --
   --
   IF (c_level_procedure >= g_log_level)
   THEN
   TRACE (p_module      => l_log_module
      , p_msg         => 'END ' || l_log_module
      , p_level       => c_level_procedure
       );
   END IF;

   RETURN TRUE;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
 ROLLBACK;

WHEN OTHERS
THEN
 ROLLBACK;
 xla_exceptions_pkg.raise_message
          (p_location      => 'xla_balances_calc_pkg.calculate_control_balances');
--
--
END calculate_control_balances;

/*===============================================+
|                                                |
|          public Function                       |
+------------------------------------------------+
|      Calculate Balances                        |
|                                                |
+===============================================*/
FUNCTION calculate_balances (  p_application_id        IN   INTEGER
			       , p_ledger_id             IN   INTEGER
			       , p_entity_id             IN   INTEGER
			       , p_event_id              IN   INTEGER
			       , p_ae_header_id          IN   INTEGER
			       , p_ae_line_num           IN   INTEGER
			       , p_request_id            IN   INTEGER
			       , p_accounting_batch_id   IN   INTEGER
			       , p_update_mode           IN   VARCHAR2
			       , p_execution_mode        IN   VARCHAR2
			      )
RETURN BOOLEAN
IS
l_log_module        VARCHAR2 (240);
l_processing_rows   NUMBER         := 0;
l_return_value      BOOLEAN;
l_operation_code    VARCHAR2(1);
l_open_period_sql   VARCHAR2(2000);
l_eff_period_num    NUMBER;

BEGIN
   IF g_log_enabled
   THEN
    l_log_module := c_default_module || '.calculate_balances';
   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'BEGIN ' || l_log_module
         , p_level       => c_level_procedure
          );
   END IF;

   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_application_id : ' || p_application_id
         , p_level       => c_level_exception
          );
   END IF;

   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_ledger_id : ' || p_ledger_id
         , p_level       => c_level_exception
          );
   END IF;

   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         =>    'p_accounting_batch_id : '
                            || p_accounting_batch_id
         , p_level       => c_level_exception
          );
   END IF;

   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_execution_mode : ' || p_execution_mode
         , p_level       => c_level_exception
          );
   END IF;

   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_update_mode : ' || p_execution_mode
         , p_level       => c_level_exception
          );
   END IF;

   IF (c_level_exception >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'request_id : ' || g_req_id
         , p_level       => c_level_exception
          );
   END IF;

   IF p_ledger_id is not NULL
   AND p_accounting_batch_id IS NULL
   AND p_event_id IS NULL
   AND p_entity_id IS NULL
   AND p_ae_header_id IS NULL
   THEN
      l_open_period_sql    := 'SELECT SUM(
                                          DECODE(xlo_effective_period_num, gps_effective_period_num,0,1)
                                          )
				FROM (
                                      SELECT DISTINCT xlo.effective_period_num xlo_effective_period_num
                                             ,(SELECT MAX(gps.effective_period_num)
                                                 FROM gl_period_statuses gps
                                               WHERE gps.application_id = 101
                                                 AND gps.ledger_id = xlo.ledger_id
                                                 AND gps.closing_status IN (''O'',''C'',''P'')
                                                 AND gps.adjustment_period_flag = ''N''
                                               )gps_effective_period_num
                                              , xlo.ledger_id
                                        FROM xla_ledger_options xlo
                                            ,xla_ledger_relationships_v xlr
                                       WHERE xlr.ledger_id = '||p_ledger_id || '
                                         AND xlo.ledger_id = DECODE(xlr.ledger_category_code , ''ALC''
                                                                   ,xlr.primary_ledger_id, xlr.ledger_id)
                                         AND xlo.application_id = '||p_application_id||'
                                      )';
   ELSE
      l_open_period_sql     := 'SELECT SUM(
                                           DECODE(xlo_effective_period_num, gps_effective_period_num,0,1)
                                           )
				 FROM (
                                       SELECT DISTINCT xlo.effective_period_num xlo_effective_period_num
                                             ,(SELECT MAX(gps.effective_period_num)
                                                 FROM gl_period_statuses gps
                                               WHERE gps.application_id = 101
                                                 AND gps.ledger_id = xlo.ledger_id
                                                 AND gps.closing_status IN (''O'',''C'',''P'')
                                                 AND gps.adjustment_period_flag = ''N''
                                               )gps_effective_period_num
                                              , xlo.ledger_id
                                        FROM xla_ledger_options xlo
                                            ,xla_ledger_relationships_v xlr
                                            ,xla_ae_headers xah
                                       WHERE xlo.ledger_id = DECODE(xlr.ledger_category_code , ''ALC''
                                                                   ,xlr.primary_ledger_id, xlr.ledger_id)
                                         AND xlo.application_id = '||p_application_id||'
                                         AND xah.application_id = ' ||p_application_id ||'
                                         AND xlr.ledger_id      = xah.ledger_id';

     IF p_entity_id IS NOT NULL
     THEN
       l_open_period_sql := l_open_period_sql || '
       AND xah.entity_id = '||p_entity_id;

     END IF;

     IF p_event_id IS NOT NULL
     THEN
       l_open_period_sql := l_open_period_sql || '
       AND xah.event_id = '||p_event_id;
     END IF;

     IF p_accounting_batch_id IS NOT NULL
     THEN
       l_open_period_sql := l_open_period_sql || '
       AND xah.accounting_batch_id = '||p_accounting_batch_id;
     END IF;

     IF p_ae_header_id IS NOT NULL
     THEN
       l_open_period_sql := l_open_period_sql || '
       AND xah.ae_header_id = '||p_ae_header_id;
     END IF;

   l_open_period_sql := l_open_period_sql || ')';

   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
	     trace
	     (p_msg      => 'l_open_period_sql_1:'||substr(l_open_period_sql, 1, 1000)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);

	     trace
	     (p_msg      => 'l_open_period_sql_1:'||substr(l_open_period_sql, 1001, 999)
	     ,p_level    => C_LEVEL_STATEMENT
	     ,p_module   => l_log_module);
   END IF;

   EXECUTE IMMEDIATE l_open_period_sql INTO  l_eff_period_num;
   --
   --Proceed with balance calculation only if the balnaces are carried forward to the latest open peirod
   --
   IF l_eff_period_num > 0
   THEN
    fnd_file.put_line
       (fnd_file.LOG
      , 'Balances are not initialized for the latest open period.
	 Before proceeding with balance calculation, run Open Period Balances Program for Ledger ID: '||p_ledger_id||' for the latest open period in General Ledger.'
       );
    xla_exceptions_pkg.raise_message
                     (p_appli_s_name      => 'XLA'
                    , p_msg_name          => 'XLA_COMMON_ERROR'
                    , p_token_1           => 'LOCATION'
                    , p_value_1           => 'xla_balances_calc_pkg.calculate_balances'
                    , p_token_2           => 'ERROR'
                    , p_value_2           =>  'Balances are not initialized for the latest open period.
					      Before proceeding with balance calculation, run Open Period Balances Program for Ledger ID: '||p_ledger_id||' for the latest open period in General Ledger.'
                     );
   END IF;
   --
   -- Validate Input Parameters
   --
   IF p_execution_mode IS NULL
   THEN
    IF (c_level_exception >= g_log_level)
    THEN
       TRACE (p_module      => l_log_module
            , p_msg         =>    'EXCEPTION:'
                               || 'p_execution_mode cannot be NULL'
            , p_level       => c_level_exception
             );
    END IF;

    xla_exceptions_pkg.raise_message
                     (p_appli_s_name      => 'XLA'
                    , p_msg_name          => 'XLA_COMMON_ERROR'
                    , p_token_1           => 'LOCATION'
                    , p_value_1           => 'xla_balances_calc_pkg.calculate_balances'
                    , p_token_2           => 'ERROR'
                    , p_value_2           =>    'EXCEPTION:'
                                             || 'p_execution_mode cannot be NULL'
                     );
   END IF;
   -- End validation

   IF p_update_mode IN ('A','F','M')
   THEN
     l_operation_code := 'A';
   ELSIF  p_update_mode = 'D'
   THEN
     l_operation_code := 'R'; --remove
   ELSE
   IF (c_level_exception >= g_log_level)
   THEN
       TRACE
          (p_module      => l_log_module
         , p_msg         =>    'EXCEPTION:'
                            || 'Invalid value for Update Mode '|| p_update_mode
         , p_level       => c_level_exception
          );
   END IF;

   xla_exceptions_pkg.raise_message
       (p_appli_s_name      => 'XLA'
      , p_msg_name          => 'XLA_COMMON_ERROR'
      , p_token_1           => 'LOCATION'
      , p_value_1           => 'xla_balances_calc_pkg.calculate_balances'
      , p_token_2           => 'ERROR'
      , p_value_2           =>    'EXCEPTION:'
                               || 'Invalid value for update mode '||p_update_mode
       );
   END IF;
   IF l_operation_code = 'A'
   THEN
      g_preupdate_flag  := 'P';
      g_postupdate_flag := 'Y';
   ELSIF l_operation_code = 'R'
   THEN
      g_preupdate_flag  := 'Y';
      g_postupdate_flag := 'P';
   END If;
   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'Calling calculate_analytical_balances'
         , p_level       => c_level_procedure
          );
   END IF;

   l_return_value :=
    calculate_analytical_balances ( p_application_id       => p_application_id
                                  , p_ledger_id            => p_ledger_id
                                  , p_entity_id            => p_entity_id
                                  , p_event_id             => p_event_id
                                  , p_ae_header_id         => p_ae_header_id
                                  , p_ae_line_num          => p_ae_line_num
                                  , p_request_id           => p_request_id
                                  , p_accounting_batch_id  => p_accounting_batch_id
                                  , p_operation_code       => l_operation_code
                                  , p_execution_mode       => p_execution_mode
                                  );

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'Calling calculate_control_balances'
         , p_level       => c_level_procedure
          );
   END IF;

   l_return_value :=
        l_return_value
        AND calculate_control_balances( p_application_id       => p_application_id
                                      , p_ledger_id            => p_ledger_id
                                      , p_entity_id            => p_entity_id
                                      , p_event_id             => p_event_id
                                      , p_ae_header_id         => p_ae_header_id
                                      , p_ae_line_num          => p_ae_line_num
                                      , p_request_id           => p_request_id
                                      , p_accounting_batch_id  => p_accounting_batch_id
                                      , p_operation_code       => l_operation_code
                                      , p_execution_mode       => p_execution_mode
                                      );

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'END ' || l_log_module
         , p_level       => c_level_procedure
          );
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
 ROLLBACK;
 RAISE;
WHEN OTHERS
THEN
 ROLLBACK;
 xla_exceptions_pkg.raise_message
                  (p_location      => 'xla_balances_calc_pkg.calculate_balances');
END calculate_balances;

/*===============================================+
|                                                |
|          Private Function                      |
+------------------------------------------------+
|  Description: To carry forward the balances    |
|  to target period for a given ledger           |
+===============================================*/

FUNCTION move_balances_forward (
p_ledger_id              IN   INTEGER
, p_effective_period_num   IN   NUMBER
, p_period_name             IN   VARCHAR2
)
RETURN BOOLEAN
IS
   l_log_module                  VARCHAR2 (240);
   l_from_effective_period_num   NUMBER;
   l_count                       NUMBER;
BEGIN
   IF g_log_enabled
   THEN
    l_log_module := c_default_module || '.open_period_event';
   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_msg         => 'BEGIN of procedure move_balances_forward'
         , p_level       => c_level_procedure
         , p_module      => l_log_module
          );
   END IF;

   SELECT distinct effective_period_num
   INTO l_from_effective_period_num
   FROM xla_ledger_options
   WHERE ledger_id = p_ledger_id;

   -- Validate the Target Period
   SELECT count(1)
    INTO l_count
   FROM gl_period_statuses
   WHERE application_id=101
   AND ledger_id = p_ledger_id
   AND effective_period_num = p_effective_period_num
   AND closing_status in ('O','C','P')
   AND adjustment_period_flag = 'N';

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_msg         => 'p_ledger_id'||p_ledger_id
         , p_level       => c_level_procedure
         , p_module      => l_log_module
          );
   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_msg         => 'l_from_effective_period_num'||l_from_effective_period_num
         , p_level       => c_level_procedure
         , p_module      => l_log_module
          );
   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_msg         => 'target Effective_period_num'||p_effective_period_num
         , p_level       => c_level_procedure
         , p_module      => l_log_module
          );
   END IF;

   IF l_from_effective_period_num >= p_effective_period_num
   THEN -- Proceed only if target period is greater than current open period

   fnd_file.put_line
       (fnd_file.LOG
      , 'Balances exists for the target period '||p_period_name||' and ledger '||p_ledger_id
       );
   return FALSE;

   ELSIF l_count = 0
   THEN -- if target period is Future enterable or Never open period EXIT
   fnd_file.put_line
       (fnd_file.LOG
      , 'Target period '||p_period_name||' is not Open/Close/Pending close Period '
       );
   return FALSE;

   ELSE

     IF (c_level_procedure >= g_log_level)
     THEN
        TRACE (p_msg         => 'Opening Analytical Balances'
             , p_level       => c_level_procedure
             , p_module      => l_log_module
              );
     END IF;

     INSERT INTO xla_ac_balances
                 (application_id
                , ledger_id
                , code_combination_id
                , analytical_criterion_code
                , analytical_criterion_type_code
                , amb_context_code
                , ac1
                , ac2
                , ac3
                , ac4
                , ac5
                , period_name
                , first_period_flag
                , effective_period_num
                , initial_balance_flag
                , creation_date
                , created_by
                , last_update_date
                , last_updated_by
                , beginning_balance_dr
                , beginning_balance_cr
                , period_year
		, last_update_login
		, program_update_date
		, program_application_id
		, program_id
		, request_id
                 )
        SELECT /*+ parallel(bal,24) */
               bal.application_id
             , bal.ledger_id
             , bal.code_combination_id
             , bal.analytical_criterion_code
             , bal.analytical_criterion_type_code
             , bal.amb_context_code
             , bal.ac1
             , bal.ac2
             , bal.ac3
             , bal.ac4
             , bal.ac5
             , gps.period_name
             , DECODE (period_num, 1, 'Y', 'N') first_period_flag
             , gps.effective_period_num
             , 'N' initial_balance_flag
             , g_date
             , g_user_id
             , g_date
             , g_user_id
             , DECODE (gps.period_year
                     , SUBSTR (bal.effective_period_num, 1, 4), (  NVL
                                                                      (bal.beginning_balance_dr
                                                                     , 0
                                                                      )
                                                                 + NVL
                                                                      (bal.period_balance_dr
                                                                     , 0
                                                                      )
                        )
                     , DECODE (SIGN (  (  NVL (bal.beginning_balance_dr, 0)
                                        + NVL (bal.period_balance_dr, 0)
                                       )
                                     - (  NVL (bal.beginning_balance_cr, 0)
                                        + NVL (bal.period_balance_cr, 0)
                                       )
                                    )
                             , 1, (  (  NVL (bal.beginning_balance_dr, 0)
                                      + NVL (bal.period_balance_dr, 0)
                                     )
                                   - (  NVL (bal.beginning_balance_cr, 0)
                                      + NVL (bal.period_balance_cr, 0)
                                     )
                                )
                             , 0
                              )
                      ) beginning_balance_dr
             , DECODE (gps.period_year
                     , SUBSTR (bal.effective_period_num, 1, 4), (  NVL
                                                                      (bal.beginning_balance_cr
                                                                     , 0
                                                                      )
                                                                 + NVL
                                                                      (bal.period_balance_cr
                                                                     , 0
                                                                      )
                        )
                     , DECODE (SIGN (  (  NVL (bal.beginning_balance_dr, 0)
                                        + NVL (bal.period_balance_dr, 0)
                                       )
                                     - (  NVL (bal.beginning_balance_cr, 0)
                                        + NVL (bal.period_balance_cr, 0)
                                       )
                                    )
                             , -1, (  NVL (bal.beginning_balance_cr, 0)
                                    + NVL (bal.period_balance_cr, 0)
                                   )
                                - (  NVL (bal.beginning_balance_dr, 0)
                                   + NVL (bal.period_balance_dr, 0)
                                  )
                             , 0
                              )
                      ) beginning_balance_cr
             ,gps.period_year
	     ,g_login_id
             ,g_date
             ,g_prog_appl_id
             ,g_prog_id
             ,g_req_id
          FROM gl_period_statuses gps
             , xla_ac_balances bal
             , gl_code_combinations gcc
             , xla_analytical_hdrs_b xbh
             , (select ledger_id
                   from xla_ledger_relationships_v
                   where (ledger_category_code IN ('PRIMARY','ALC')
                            and primary_ledger_id = p_ledger_id)
                            or (ledger_category_code = 'SECONDARY'
                            and ledger_id = p_ledger_id)
                    ) xlr
         WHERE gps.application_id = 101
           AND gps.ledger_id = p_ledger_id
           AND gps.closing_status IN ('O', 'C', 'P')
           AND gps.adjustment_period_flag = 'N'
           AND gps.effective_period_num <= p_effective_period_num
           AND gps.effective_period_num > l_from_effective_period_num
           AND bal.effective_period_num = l_from_effective_period_num
           AND bal.ledger_id = xlr.ledger_id
           AND gcc.code_combination_id = bal.code_combination_id
           AND xbh.analytical_criterion_code = bal.analytical_criterion_code
           AND xbh.analytical_criterion_type_code =
                                           bal.analytical_criterion_type_code
           AND xbh.amb_context_code = bal.amb_context_code
           AND xbh.balancing_flag <> 'N'
           AND (   gps.period_year = SUBSTR (bal.effective_period_num, 1, 4)
                OR xbh.year_end_carry_forward_code = 'A'
                OR (    xbh.year_end_carry_forward_code = 'B'
                    AND gcc.account_type IN ('A', 'L', 'O')
                   )
               );

     IF (c_level_procedure >= g_log_level)
     THEN
        TRACE (p_msg         => '# rows created for Analytical Balances : ' || SQL%ROWCOUNT
             , p_level       => c_level_procedure
             , p_module      => l_log_module
              );
     END IF;

     IF (c_level_procedure >= g_log_level)
     THEN
        TRACE (p_msg         => 'Opening Control Balances'
             , p_level       => c_level_procedure
             , p_module      => l_log_module
              );
     END IF;

     INSERT INTO xla_control_balances
                 (application_id
                , ledger_id
                , code_combination_id
                , party_type_code
                , party_id
                , party_site_id
                , period_name
                , first_period_flag
                , effective_period_num
                , initial_balance_flag
                , creation_date
                , created_by
                , last_update_date
                , last_updated_by
                , beginning_balance_dr
                , beginning_balance_cr
                , period_year
		, last_update_login
                , program_update_date
                , program_application_id
                , program_id
                , request_id
                 )
        SELECT /*+ parallel(bal,24) */
               bal.application_id
             , bal.ledger_id
             , bal.code_combination_id
             , bal.party_type_code
             , bal.party_id
             , bal.party_site_id
             , gps.period_name
             , DECODE (period_num, 1, 'Y', 'N') first_period_flag
             , gps.effective_period_num
             , 'N' initial_balance_flag
             , g_date
             , g_user_id
             , g_date
             , g_user_id
             , DECODE (gps.period_year
                     , SUBSTR (bal.effective_period_num, 1, 4), (  NVL
                                                                      (bal.beginning_balance_dr
                                                                     , 0
                                                                      )
                                                                 + NVL
                                                                      (bal.period_balance_dr
                                                                     , 0
                                                                      )
                        )
                     , DECODE (SIGN (  (  NVL (bal.beginning_balance_dr, 0)
                                        + NVL (bal.period_balance_dr, 0)
                                       )
                                     - (  NVL (bal.beginning_balance_cr, 0)
                                        + NVL (bal.period_balance_cr, 0)
                                       )
                                    )
                             , 1, (  (  NVL (bal.beginning_balance_dr, 0)
                                      + NVL (bal.period_balance_dr, 0)
                                     )
                                   - (  NVL (bal.beginning_balance_cr, 0)
                                      + NVL (bal.period_balance_cr, 0)
                                     )
                                )
                             , 0
                              )
                      ) beginning_balance_dr
             , DECODE (gps.period_year
                     , SUBSTR (bal.effective_period_num, 1, 4), (  NVL
                                                                      (bal.beginning_balance_cr
                                                                     , 0
                                                                      )
                                                                 + NVL
                                                                      (bal.period_balance_cr
                                                                     , 0
                                                                      )
                        )
                     , DECODE (SIGN (  (  NVL (bal.beginning_balance_dr, 0)
                                        + NVL (bal.period_balance_dr, 0)
                                       )
                                     - (  NVL (bal.beginning_balance_cr, 0)
                                        + NVL (bal.period_balance_cr, 0)
                                       )
                                    )
                             , -1, (  NVL (bal.beginning_balance_cr, 0)
                                    + NVL (bal.period_balance_cr, 0)
                                   )
                                - (  NVL (bal.beginning_balance_dr, 0)
                                   + NVL (bal.period_balance_dr, 0)
                                  )
                             , 0
                              )
                      ) beginning_balance_cr
                    ,gps.period_year
		    ,g_login_id
		    ,g_date
		    ,g_prog_appl_id
		    ,g_prog_id
	            ,g_req_id
          FROM gl_period_statuses gps
             , xla_control_balances bal
             ,(select ledger_id
                   from xla_ledger_relationships_v
                   where (ledger_category_code IN ('PRIMARY','ALC')
                            and primary_ledger_id = p_ledger_id)
                            or (ledger_category_code = 'SECONDARY'
                            and ledger_id = p_ledger_id)
                    ) xlr
         WHERE gps.application_id = 101
           AND gps.ledger_id = p_ledger_id
           AND gps.closing_status IN ('O', 'C', 'P')
           AND gps.adjustment_period_flag = 'N'
           AND gps.effective_period_num <= p_effective_period_num
           AND gps.effective_period_num > l_from_effective_period_num
           AND bal.effective_period_num = l_from_effective_period_num
           AND bal.ledger_id = xlr.ledger_id;

     IF (c_level_procedure >= g_log_level)
     THEN
        TRACE (p_msg         => '# rows created for Control Balances : ' || SQL%ROWCOUNT
             , p_level       => c_level_procedure
             , p_module      => l_log_module
              );
     END IF;

     UPDATE xla_ledger_options
     set effective_period_num = p_effective_period_num
     where ledger_id = p_ledger_id;

     IF (c_level_procedure >= g_log_level)
     THEN
        TRACE (p_msg         => '# rows updated in xla_ledger_options : ' || SQL%ROWCOUNT
             , p_level       => c_level_procedure
             , p_module      => l_log_module
              );
     END IF;

     IF (c_level_procedure >= g_log_level)
     THEN
        TRACE (p_msg         => 'xla_ledger_options updated with effective_period_num '||p_effective_period_num
                 , p_level       => c_level_procedure
                 , p_module      => l_log_module
                  );
     END IF;
   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_msg         => 'END of procedure move_balances_forward'
         , p_level       => c_level_procedure
         , p_module      => l_log_module
          );
   END IF;

   RETURN TRUE;
   EXCEPTION
   WHEN NO_DATA_FOUND
     THEN
      fnd_file.put_line
       (fnd_file.LOG
      , 'There is no record in xla_ledger_options for ledger '||p_ledger_id
       );
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
 RAISE;
WHEN OTHERS
THEN
 xla_exceptions_pkg.raise_message
               (p_location      => 'xla_balances_calc_pkg.move_balances_forward');
 RETURN FALSE;
END move_balances_forward;

/*===============================================+
|                                                |
| public Function                                |
|-----------------                               |
| Description:                                   |
|                                                |
|                                                |
+===============================================*/
PROCEDURE open_period_srs (
p_errbuf                 OUT NOCOPY      VARCHAR2
, p_retcode                OUT NOCOPY      NUMBER
, p_application_id         IN              NUMBER
, p_ledger_id              IN              NUMBER
, p_period_name            IN              VARCHAR2
)
IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|  Just the SRS wrapper for Open Period balances                        |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|  Call create_new_period_balances and assign its return code to        |
|  p_retcode                                                            |
|  RETURN p_retcode (0=success, 1=warning, 2=error)                     |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
l_sobname                VARCHAR2 (30);
l_log_module             VARCHAR2 (2000);
l_effective_period_num   NUMBER;
l_alc_ledger             NUMBER;
l_ledger_count           NUMBER;
l_ledger_nul_count       NUMBER;

CURSOR lock_bal_control (p_ledger_id NUMBER)
IS
 SELECT     application_id
          , ledger_id
       FROM xla_bal_concurrency_control
      WHERE application_id in (SELECT application_id
                                FROM xla_ledger_options
				WHERE ledger_id = p_ledger_id
			       )
 FOR UPDATE NOWAIT; --Lock All the applications belonging to this ledger

BEGIN
   IF g_log_enabled
   THEN
    l_log_module := c_default_module || '.open_period_srs';
   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'BEGIN ' || l_log_module
         , p_level       => c_level_procedure
          );
   END IF;

   -- Check if balances upgrade script has been run.
   SELECT count(1)
     INTO l_ledger_count
   FROM xla_ledger_options;

   SELECT count(1)
     INTO l_ledger_nul_count
   FROM xla_ledger_options
   WHERE effective_period_num is null;

   IF l_ledger_count = l_ledger_nul_count
   THEN
      fnd_file.put_line(fnd_file.LOG
			,'Balances upgrade script xlabalupg.sql has not been run.
			  Run xlabalupg.sql to use Update Subledger Accounting Balances program'
		       );
      p_retcode := 0;
   ELSE

      --check if the ledger is ALC ledger
      SELECT count(1)
       INTO l_alc_ledger
      FROM xla_ledger_relationships_v
      WHERE ledger_id=p_ledger_id
      AND ledger_category_code = 'ALC';

      IF l_alc_ledger = 0 THEN -- ALC ledger's balances are created along with primary.
                                     -- So exit if the program is called for ALC ledger.

        SELECT effective_period_num
           INTO l_effective_period_num
        FROM gl_period_statuses
        WHERE application_id = 101
          AND ledger_id = p_ledger_id
          AND period_name = p_period_name;

        fnd_file.put_line (fnd_file.LOG, 'p_ledger_id: ' || p_ledger_id);
        fnd_file.put_line (fnd_file.LOG, 'p_effective_period_num: ' || l_effective_period_num);
        p_retcode := 0;

        IF NOT lock_bal_concurrency_control (  p_application_id      => NULL
                                             , p_ledger_id           => p_ledger_id
                                             , p_entity_id           => NULL
                                             , p_event_id            => NULL
                                             , p_ae_header_id        => NULL
                                             , p_ae_line_num         => NULL
                                             , p_request_id          => g_req_id
                                             , p_accounting_batch_id => NULL
                                             , p_execution_mode      => NULL
                                             , p_concurrency_class   => 'OPEN_PERIOD_BALANCE'
                                                                                 )
        THEN
                xla_exceptions_pkg.raise_message
                          (p_appli_s_name      => 'XLA'
                         , p_msg_name          => 'XLA_COMMON_ERROR'
                         , p_token_1           => 'LOCATION'
                         , p_value_1           => 'xla_balances_calc_pkg.open_period_srs'
                         , p_token_2           => 'ERROR'
                         , p_value_2           =>    'EXCEPTION:'|| 'Record cannot be inserted into XLA_BAL_CONCURRENCY_CONTROL '
                         );
        END IF;

        OPEN lock_bal_control (p_ledger_id           => p_ledger_id  );
        CLOSE lock_bal_control;

        fnd_file.put_line (fnd_file.LOG, 'Opening SLA Period Balances');

        IF move_balances_forward
                                                       (p_ledger_id                 => p_ledger_id
                                                      , p_effective_period_num      => l_effective_period_num
                              , p_period_name               => p_period_name
                                                       )
        THEN
               fnd_file.put_line (fnd_file.LOG, 'Open Period Balances Successfully completed');

               delete xla_bal_concurrency_control
               where ledger_id = p_ledger_id
               and request_id = g_req_id;

        ELSE
               p_retcode := p_retcode + 1;
               fnd_file.put_line (fnd_file.LOG, 'Unsuccessful');
        END IF;
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
       TRACE (p_module      => l_log_module
            , p_msg         => 'END ' || l_log_module
            , p_level       => c_level_procedure
             );
      END IF;
   END IF;
EXCEPTION
WHEN le_resource_busy
THEN
    IF (c_level_error >= g_log_level)
    THEN
            TRACE (p_module      => l_log_module
                 , p_msg         => 'Cannot lock XLA_BAL_CONCURRENCY_CONTROL'
                 , p_level       => c_level_error
                  );
    END IF;

    IF (c_level_procedure >= g_log_level)
    THEN
           TRACE (p_module      => l_log_module
                 , p_msg         => 'END ' || l_log_module
                 , p_level       => c_level_procedure
                  );
    END IF;

   p_retcode := 1;
   fnd_file.put_line
    (fnd_file.LOG
      ,'There is another request running for the ledger_id : '
     || p_ledger_id
     || '. Pls. submit Open Period Balances Concurrent Program once the running request is completed'
    );
WHEN xla_exceptions_pkg.application_exception
THEN
   p_retcode := 2;
   p_errbuf := SQLERRM;
WHEN OTHERS
THEN
   p_retcode := 2;
   p_errbuf := SQLERRM;
END open_period_srs;

/*===============================================+
|                                                |
| public Function                                |
| Description:                                   |
|                                                |
+===============================================*/

PROCEDURE massive_update_srs (
  p_errbuf                OUT NOCOPY      VARCHAR2
, p_retcode               OUT NOCOPY      NUMBER
, p_application_id        IN              NUMBER
, p_ledger_id             IN              NUMBER
, p_accounting_batch_id   IN              NUMBER
, p_update_mode           IN              VARCHAR2
)
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
l_commit_flag      VARCHAR2 (1);
l_log_module       VARCHAR2 (2000);
l_execution_mode   VARCHAR2 (1);
l_count            NUMBER;
l_ledger_count     NUMBER;
l_ledger_nul_count NUMBER;

CURSOR lock_bal_control (p_application_id NUMBER)
IS
 SELECT application_id
       ,ledger_id
   FROM xla_bal_concurrency_control
  WHERE application_id = p_application_id
  FOR UPDATE WAIT 60;

BEGIN
   IF g_log_enabled
   THEN
    l_log_module := c_default_module || '.massive_update_srs';
   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'BEGIN ' || l_log_module
         , p_level       => c_level_procedure
          );
   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_application_id ' || p_application_id
         , p_level       => c_level_procedure
          );
   END IF;
   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_ledger_id ' || p_ledger_id
         , p_level       => c_level_procedure
          );
   END IF;
   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_accounting_batch_id ' || p_accounting_batch_id
         , p_level       => c_level_procedure
          );
   END IF;
   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_update_mode ' || p_update_mode
         , p_level       => c_level_procedure
          );
   END IF;

   fnd_file.put_line (fnd_file.LOG
                  , 'p_application_id: ' || p_application_id
                   );
   fnd_file.put_line (fnd_file.LOG, 'p_ledger_id: ' || p_ledger_id);
   fnd_file.put_line (fnd_file.LOG
                  , 'p_accounting_batch_id: ' || p_accounting_batch_id
                   );
   fnd_file.put_line (fnd_file.LOG, 'p_request_id: ' || g_req_id);

   -- Check if balances upgrade script has been run.
   SELECT count(1)
     INTO l_ledger_count
   FROM xla_ledger_options;

   SELECT count(1)
     INTO l_ledger_nul_count
   FROM xla_ledger_options
   WHERE effective_period_num is null;

   IF l_ledger_count = l_ledger_nul_count
   THEN
      fnd_file.put_line(fnd_file.LOG
			,'Balances upgrade script xlabalupg.sql has not been run. Run xlabalupg.sql to use Update Subledger Accounting Balances program'
		       );
      p_retcode := 1;
   ELSE

      --parameter validation
      --p_application_id must have a value, always
      IF p_application_id IS NULL
      THEN
       IF (c_level_exception >= g_log_level)
       THEN
          TRACE (p_module      => l_log_module
               , p_msg         =>    'EXCEPTION:'
                                  || 'p_application_id cannot be NULL'
               , p_level       => c_level_exception
                );
       END IF;

       xla_exceptions_pkg.raise_message
                         (p_appli_s_name      => 'XLA'
                        , p_msg_name          => 'XLA_COMMON_ERROR'
                        , p_token_1           => 'LOCATION'
                        , p_value_1           => 'xla_balances_calc_pkg.massive_update_srs'
                        , p_token_2           => 'ERROR'
                        , p_value_2           =>    'EXCEPTION:'
                                                 || 'p_application_id cannot be NULL'
                         );
      END IF;

      IF p_ledger_id IS NULL AND p_accounting_batch_id IS NULL
      THEN
       IF (c_level_exception >= g_log_level)
       THEN
          TRACE
             (p_module      => l_log_module
            , p_msg         =>    'EXCEPTION:'
                               || 'p_ledger_id and p_accounting_batch_id cannot be NULL'
            , p_level       => c_level_exception
             );
       END IF;

       xla_exceptions_pkg.raise_message
          (p_appli_s_name      => 'XLA'
         , p_msg_name          => 'XLA_COMMON_ERROR'
         , p_token_1           => 'LOCATION'
         , p_value_1           => 'xla_balances_calc_pkg.massive_update_srs'
         , p_token_2           => 'ERROR'
         , p_value_2           =>    'EXCEPTION:'
                                  || 'p_ledger_id and p_accounting_batch_id cannot be NULL'
          );
      END IF;

      l_execution_mode := 'C';

      IF NOT lock_bal_concurrency_control (  p_application_id      => p_application_id
                                         , p_ledger_id           => p_ledger_id
                                         , p_entity_id           => NULL
                                         , p_event_id            => NULL
                                         , p_ae_header_id        => NULL
                                         , p_ae_line_num         => NULL
                                         , p_request_id          => g_req_id
                                         , p_accounting_batch_id => p_accounting_batch_id
                                         , p_execution_mode      => l_execution_mode
                                         , p_concurrency_class   => 'BALANCES_CALCULATION'
                                         )
        THEN
       xla_exceptions_pkg.raise_message
          (p_appli_s_name      => 'XLA'
         , p_msg_name          => 'XLA_COMMON_ERROR'
         , p_token_1           => 'LOCATION'
         , p_value_1           => 'xla_balances_calc_pkg.massive_update_srs'
         , p_token_2           => 'ERROR'
         , p_value_2           =>    'EXCEPTION:'
                                  || 'XLA_BAL_CONCURRENCY_CONTROL COULD NOT BE LOCKED. RESOURCE BUSY'
          );
      END IF;

      OPEN lock_bal_control (p_application_id      => p_application_id);

      CLOSE lock_bal_control;

      IF calculate_balances (   p_application_id          => p_application_id
                              , p_ledger_id               => p_ledger_id
                              , p_entity_id               => NULL
                              , p_event_id                => NULL
                              , p_ae_header_id            => NULL
                              , p_ae_line_num             => NULL
                              , p_request_id              => g_req_id
                              , p_accounting_batch_id     => p_accounting_batch_id
                              , p_update_mode                         => p_update_mode
                              , p_execution_mode          => l_execution_mode
                             )
        THEN
      p_retcode := 0;

              --DELETE RECORDS FROM XLA_BAL_CONCURRENCY_CONTROL TABLE
              DELETE  xla_bal_concurrency_control
          WHERE application_id = p_application_id
            AND ledger_id      = p_ledger_id
            AND request_id     = g_req_id;
      ELSE
      p_retcode := 1;
      END IF;
   END IF;
EXCEPTION
WHEN le_resource_busy
THEN
 IF (c_level_error >= g_log_level)
 THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'Cannot lock XLA_BAL_CONCURRENCY_CONTROL'
         , p_level       => c_level_error
          );
 END IF;

 IF (c_level_procedure >= g_log_level)
 THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'END ' || l_log_module
         , p_level       => c_level_procedure
          );
 END IF;

 p_retcode := 1;
 fnd_file.put_line
    (fnd_file.LOG
   ,    'There is another request running for the ledger_id : '
     || p_ledger_id
     || ' application_id : '
     || p_application_id
     || '. Pls. submit Subledger Accounting Balances Update Concurrent Program once the running request is completed'
    );
WHEN xla_exceptions_pkg.application_exception
THEN
 p_retcode := 2;
 RAISE;
WHEN OTHERS
THEN
 p_retcode := 2;
 xla_exceptions_pkg.raise_message
        (p_location      => 'xla_balances_calc_pkg.massive_update_srs');
END massive_update_srs;

/*===============================================+
|                                                |
|          public Function                       |
+------------------------------------------------+
| Description:                                   |
|                                                |
+===============================================*/
FUNCTION massive_update (
p_application_id        IN   INTEGER
, p_ledger_id             IN   INTEGER
, p_entity_id             IN   INTEGER
, p_event_id              IN   INTEGER
, p_request_id            IN   INTEGER
, p_accounting_batch_id   IN   INTEGER
, p_update_mode           IN   VARCHAR2
, p_execution_mode        IN   VARCHAR2
)
RETURN BOOLEAN
IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|  Called in online accounting flow            |
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
l_commit_flag      VARCHAR2 (1);
l_log_module       VARCHAR2 (2000);
l_count            NUMBER;
l_success          VARCHAR2 (1);
l_return_value     BOOLEAN;
l_result           BOOLEAN;
l_req_id           NUMBER;
l_ledger_count     NUMBER;
l_ledger_nul_count NUMBER;

CURSOR lock_bal_control (p_application_id NUMBER)
IS
 SELECT application_id
      , ledger_id
   FROM xla_bal_concurrency_control
  WHERE application_id = p_application_id
 FOR UPDATE NOWAIT;
BEGIN
   IF g_log_enabled
   THEN
    l_log_module := c_default_module || '.massive_update';
   END IF;

   IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'BEGIN ' || l_log_module
         , p_level       => c_level_procedure
          );
   END IF;

     IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_application_id ' || p_application_id
         , p_level       => c_level_procedure
          );
   END IF;
     IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_ledger_id ' || p_ledger_id
         , p_level       => c_level_procedure
          );
   END IF;
     IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_entity_id ' || p_entity_id
         , p_level       => c_level_procedure
          );
   END IF;
     IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_event_id ' || p_event_id
         , p_level       => c_level_procedure
          );
   END IF;
     IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_request_id ' || p_request_id
         , p_level       => c_level_procedure
          );
   END IF;
     IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_accounting_batch_id ' || p_accounting_batch_id
         , p_level       => c_level_procedure
          );
   END IF;
     IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_update_mode ' || p_update_mode
         , p_level       => c_level_procedure
          );
   END IF;
     IF (c_level_procedure >= g_log_level)
   THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'p_execution_mode ' || p_execution_mode
         , p_level       => c_level_procedure
          );
   END IF;


   fnd_file.put_line (fnd_file.LOG
                  , 'p_application_id: ' || p_application_id
                   );
   fnd_file.put_line (fnd_file.LOG, 'p_ledger_id: ' || p_ledger_id);
   fnd_file.put_line (fnd_file.LOG
                  , 'p_accounting_batch_id: ' || p_accounting_batch_id
                   );
   fnd_file.put_line (fnd_file.LOG, 'p_request_id: ' || g_req_id);

    -- Check if balances upgrade script has been run.
   SELECT count(1)
     INTO l_ledger_count
   FROM xla_ledger_options;

   SELECT count(1)
     INTO l_ledger_nul_count
   FROM xla_ledger_options
   WHERE effective_period_num is null;

   IF l_ledger_count = l_ledger_nul_count
   THEN
      fnd_file.put_line(fnd_file.LOG
			,'Balances upgrade script xlabalupg.sql has not been run. Run xlabalupg.sql to use Update Subledger Accounting Balances program'
		       );
      RETURN FALSE;
   ELSE

     --parameter validation
     --p_application_id must have a value
     IF p_application_id IS NULL
     THEN
      IF (c_level_exception >= g_log_level)
      THEN
         TRACE (p_module      => l_log_module
              , p_msg         =>    'EXCEPTION:'
                                 || 'p_application_id cannot be NULL'
              , p_level       => c_level_exception
               );
      END IF;

      xla_exceptions_pkg.raise_message
                            (p_appli_s_name      => 'XLA'
                           , p_msg_name          => 'XLA_COMMON_ERROR'
                           , p_token_1           => 'LOCATION'
                           , p_value_1           => 'xla_balances_calc_pkg.massive_update'
                           , p_token_2           => 'ERROR'
                           , p_value_2           =>    'EXCEPTION:'
                                                    || 'p_application_id cannot be NULL'
                            );
     END IF;

     IF p_execution_mode = 'C'
     THEN
      --batch execution
      l_result := fnd_request.set_mode (TRUE);
      l_req_id :=
         fnd_request.submit_request (application      => 'XLA'
                                   , program          => 'XLABAPUB'
                                   , description      => NULL
                                   , argument1        => p_application_id
                                   , argument2        => p_ledger_id
                                   , argument3        => p_accounting_batch_id
                                   , argument4        => p_update_mode
                                    );

      IF (c_level_statement >= g_log_level)
      THEN
         TRACE (p_module      => l_log_module
              , p_msg         => 'Request ID: ' || l_req_id
              , p_level       => c_level_statement
               );
      END IF;

      IF l_req_id = 0
      THEN
         IF (c_level_statement >= g_log_level)
         THEN
            TRACE (p_module      => l_log_module
                 , p_msg         => 'Unable to submit request'
                 , p_level       => c_level_statement
                  );
         END IF;

         l_return_value := FALSE;
      ELSE
         l_return_value := TRUE;
      END IF;
     ELSIF p_execution_mode = 'O'
     THEN
      IF NOT lock_bal_concurrency_control (   p_application_id      => p_application_id
                                            , p_ledger_id           => p_ledger_id
                                            , p_entity_id           => p_entity_id
                                            , p_event_id            => p_event_id
                                            , p_ae_header_id        => NULL
                                            , p_ae_line_num         => NULL
                                            , p_request_id          => g_req_id
                                            , p_accounting_batch_id => p_accounting_batch_id
                                            , p_execution_mode      => p_execution_mode
                                            , p_concurrency_class   => 'BALANCES_CALCULATION'
                                          )
      THEN
         xla_exceptions_pkg.raise_message
            (p_appli_s_name      => 'XLA'
           , p_msg_name          => 'XLA_COMMON_ERROR'
           , p_token_1           => 'LOCATION'
           , p_value_1           => 'xla_balances_calc_pkg.MASSIVE_UPDATE'
           , p_token_2           => 'ERROR'
           , p_value_2           =>    'EXCEPTION:'
                                    || 'XLA_BAL_CONCURRENCY_CONTROL COULD NOT BE LOCKED. RESOURCE BUSY'
            );
      END IF;

      OPEN lock_bal_control (p_application_id      => p_application_id );

      CLOSE lock_bal_control;

      IF calculate_balances (  p_application_id      => p_application_id
                             , p_ledger_id           => p_ledger_id
                             , p_entity_id           => p_entity_id
                             , p_event_id            => p_event_id
                             , p_ae_header_id        => NULL
                             , p_ae_line_num         => NULL
                             , p_request_id          => -1
                             , p_accounting_batch_id => p_accounting_batch_id
                             , p_update_mode         => p_update_mode
                             , p_execution_mode      => p_execution_mode
                            )
      THEN
         DELETE FROM xla_bal_concurrency_control
              WHERE application_id = p_application_id
                 AND ledger_id = p_ledger_id
                 AND accounting_batch_id = p_accounting_batch_id;

         RETURN TRUE;
      END IF;
     END IF;

     RETURN l_return_value;
   END IF;
EXCEPTION
WHEN le_resource_busy
THEN
 IF (c_level_error >= g_log_level)
 THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'Cannot lock XLA_BAL_CONCURRENCY_CONTROL'
         , p_level       => c_level_error
          );
 END IF;

 IF (c_level_procedure >= g_log_level)
 THEN
    TRACE (p_module      => l_log_module
         , p_msg         => 'END ' || l_log_module
         , p_level       => c_level_procedure
          );
 END IF;

 fnd_file.put_line
    (fnd_file.LOG
   ,    'There is another request running for the ledger_id : '
     || p_ledger_id
     || ' application_id : '
     || p_application_id
     || '. Pls. submit Subledger Accounting Balances Update Concurrent Program once the running request is completed'
    );
 RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
 RAISE;
WHEN OTHERS
THEN
 xla_exceptions_pkg.raise_message
                      (p_location      => 'xla_balances_calc_pkg.massive_update');
END massive_update;

/*===============================================+
|                                                |
|          public Function                       |
+------------------------------------------------+
| Description:                                   |
|                                                |
+===============================================*/

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
l_execution_mode             VARCHAR2(1) := 'O';
l_ledger_count               NUMBER;
l_ledger_nul_count           NUMBER;

CURSOR lock_bal_control (p_application_id NUMBER)
IS
SELECT application_id
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

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
            (p_module => l_log_module
            ,p_msg      => 'p_application_id ' || p_application_id
            ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
            (p_module => l_log_module
            ,p_msg      => 'p_update_mode ' || p_update_mode
            ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
            (p_module => l_log_module
            ,p_msg      => 'p_ae_header_id ' || p_ae_header_id
            ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
            (p_module => l_log_module
            ,p_msg      => 'p_ae_line_num ' || p_ae_line_num
            ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   -- Check if balances upgrade script has been run.
   SELECT count(1)
     INTO l_ledger_count
   FROM xla_ledger_options;

   SELECT count(1)
     INTO l_ledger_nul_count
   FROM xla_ledger_options
   WHERE effective_period_num is null;

   IF l_ledger_count = l_ledger_nul_count
   THEN
      fnd_file.put_line(fnd_file.LOG
			,'Balances upgrade script xlabalupg.sql has not been run. Run xlabalupg.sql to use Update Subledger Accounting Balances program'
		       );
      RETURN FALSE;
   ELSE
     --parameter validation
     IF p_application_id IS NULL
     THEN
       IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
              trace
                     (p_module => l_log_module
                     ,p_msg   => 'EXCEPTION:' ||'p_application_id cannot be NULL'
                     ,p_level => C_LEVEL_EXCEPTION
                     );
       END IF;
       xla_exceptions_pkg.raise_message
                      (p_appli_s_name   => 'XLA'
                      ,p_msg_name       => 'XLA_COMMON_ERROR'
                      ,p_token_1        => 'LOCATION'
                      ,p_value_1        => 'xla_balances_calc_pkg.pre_accounting'
                      ,p_token_2        => 'ERROR'
                      ,p_value_2        => 'EXCEPTION:' ||
                      'p_application_id cannot be NULL');
     END IF;

     IF p_ae_header_id IS NULL
     THEN
           IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
              trace  (p_module => l_log_module
                     ,p_msg   => 'EXCEPTION:' ||'p_ae_header_id cannot be NULL'
                     ,p_level => C_LEVEL_EXCEPTION
                     );
           END IF;
           xla_exceptions_pkg.raise_message
                      (p_appli_s_name   => 'XLA'
                      ,p_msg_name       => 'XLA_COMMON_ERROR'
                      ,p_token_1        => 'LOCATION'
                      ,p_value_1        => 'xla_balances_calc_pkg.pre_accounting'
                      ,p_token_2        => 'ERROR'
                      ,p_value_2        => 'EXCEPTION:' || 'p_ae_header_id cannot be NULL');
     END IF;

     IF p_update_mode IS NULL
     THEN
               IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                      trace
                             (p_module => l_log_module
                             ,p_msg   => 'EXCEPTION:' ||'p_update_mode cannot be NULL'
                              ,p_level => C_LEVEL_EXCEPTION
                             );
               END IF;
               xla_exceptions_pkg.raise_message
                      (p_appli_s_name   => 'XLA'
                      ,p_msg_name       => 'XLA_COMMON_ERROR'
                      ,p_token_1        => 'LOCATION'
                      ,p_value_1        => 'xla_balances_calc_pkg.pre_accounting'
                      ,p_token_2        => 'ERROR'
                      ,p_value_2        => 'EXCEPTION:' ||'p_update_mode cannot be NULL');
     ELSIF p_update_mode NOT IN ('A', 'D', 'F')
     THEN
               IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                      trace
                             (p_module => l_log_module
                             ,p_msg   => 'EXCEPTION:' || 'Unsupported value for p_update_mode: ' || p_update_mode
                             ,p_level => C_LEVEL_EXCEPTION
                             );
               END IF;
               xla_exceptions_pkg.raise_message
                      (p_appli_s_name   => 'XLA'
                      ,p_msg_name       => 'XLA_COMMON_ERROR'
                      ,p_token_1        => 'LOCATION'
                      ,p_value_1        => 'xla_balances_calc_pkg.pre_accounting'
                      ,p_token_2        => 'ERROR'
                      ,p_value_2        => 'EXCEPTION:' ||'Unsupported value for p_update_mode: ' || p_update_mode);
     END IF;
     -- END parameter validation

     IF NOT lock_bal_concurrency_control ( p_application_id      => p_application_id
                                       , p_ledger_id           => NULL
                                       , p_entity_id           => NULL
                                       , p_event_id            => NULL
                                       , p_ae_header_id        => p_ae_header_id
                                       , p_ae_line_num         => p_ae_line_num
                                       , p_request_id          => g_req_id
                                       , p_accounting_batch_id => NULL
                                       , p_execution_mode      => l_execution_mode
                                       , p_concurrency_class   => 'BALANCES_CALCULATION'
                                       )
     THEN
         xla_exceptions_pkg.raise_message
            (p_appli_s_name      => 'XLA'
           , p_msg_name          => 'XLA_COMMON_ERROR'
           , p_token_1           => 'LOCATION'
           , p_value_1           => 'xla_balances_calc_pkg.MASSIVE_UPDATE'
           , p_token_2           => 'ERROR'
           , p_value_2           =>    'EXCEPTION:'
                                    || 'XLA_BAL_CONCURRENCY_CONTROL COULD NOT BE LOCKED. RESOURCE BUSY'
            );
     END IF;
     OPEN lock_bal_control (p_application_id      => p_application_id );

     CLOSE lock_bal_control;

     l_return_value := calculate_balances ( p_application_id        => p_application_id
                                        , p_ledger_id               => NULL
                                        , p_entity_id               => NULL
                                        , p_event_id                => NULL
                                        , p_ae_header_id            => p_ae_header_id
                                        , p_ae_line_num             => p_ae_line_num
                                        , p_request_id              => g_req_id
                                        , p_accounting_batch_id     => NULL
                                        , p_update_mode             => p_update_mode
                                        , p_execution_mode          => l_execution_mode
                                        );
     IF l_return_value THEN
     DELETE FROM xla_bal_concurrency_control
       WHERE application_id = p_application_id
         AND concurrency_class = 'BALANCES_CALCULATION'
         AND execution_mode = l_execution_mode
	 AND request_id     = g_req_id;
     END IF;

     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace (p_module => l_log_module
              ,p_msg      => 'END ' || l_log_module
              ,p_level    => C_LEVEL_PROCEDURE);
     END IF;
     RETURN l_return_value;
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
          (p_location => 'xla_balances_calc_pkg.single_update');
END single_update;

BEGIN
   g_log_level := fnd_log.g_current_runtime_level;
   g_log_enabled :=
   fnd_log.TEST (log_level      => g_log_level
                      , module         => c_default_module);

   IF NOT g_log_enabled
   THEN
      g_log_level := c_level_log_disabled;
   END IF;

   g_user_id := xla_environment_pkg.g_usr_id;
   g_login_id := xla_environment_pkg.g_login_id;
   g_date := SYSDATE;
   g_prog_appl_id := xla_environment_pkg.g_prog_appl_id;
   g_prog_id := xla_environment_pkg.g_prog_id;
   g_req_id := NVL (xla_environment_pkg.g_req_id, -1);
   g_cached_single_period := FALSE;
END xla_balances_calc_pkg;

/
