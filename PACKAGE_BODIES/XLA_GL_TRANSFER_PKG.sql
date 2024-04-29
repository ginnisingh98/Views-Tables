--------------------------------------------------------
--  DDL for Package Body XLA_GL_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_GL_TRANSFER_PKG" AS
/*  $Header: XLACGLXB.pls 120.21.12010000.3 2009/03/17 11:35:36 svellani ship $        */

   --if g_entry_type is 'A', actual only; else 'B', actual and budget.
   --the purpuse is that,the new version is still working for AP and CST,
   --even if they do not add new column to their AEH and AEL.
   --The new version is still use old gl_insert code when g_entry_type is 'A'.
   g_entry_type             VARCHAR2(1);

   -- Accounting Table variables.
   g_application_id         NUMBER(15);
   g_events_table           VARCHAR2(30);
   g_headers_table          VARCHAR2(30);
   g_lines_table            VARCHAR2(30);
   g_periods_table          VARCHAR2(30);
   g_encumbrance_table      VARCHAR2(30);
   g_actual_table_alias     VARCHAR2(30);
   g_enc_table_alias        VARCHAR2(30);
   g_enc_sequence_name      VARCHAR2(30);
   g_lines_sequence_name    VARCHAR2(30);
   g_program_id             NUMBER;
   g_user_id                NUMBER;
   g_base_currency_code     VARCHAR2(15);

   -- Flow Control Flags
   g_proceed                  VARCHAR2(1);
   g_rec_transfer_flag      VARCHAR2(1);  -- add the flag to solve fund_check and journal_import calling problem
   g_enc_proceed            VARCHAR2(1);

   g_headers_selected       NUMBER := 0;         -- No. of headers selected
   g_batch_name             VARCHAR2(30);
   g_program_name           VARCHAR2(30);
   g_debug_info             VARCHAR2(4000);
   g_sob_rows_created       NUMBER := 0;
   g_total_rows_created     NUMBER := 0;

   -- Record counters to display control info.

   g_periods_cnt            NUMBER := 0;
   g_rec_transferred        NUMBER := 0;
   g_cnt_transfer_errors    NUMBER := 0;
   g_cnt_acct_errors        NUMBER := 0;

C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER        := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_gl_transfer_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

g_line_type           VARCHAR2(4000);

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 ) IS
  l_log_module  VARCHAR2(255);
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, NVL(p_module,C_DEFAULT_MODULE));
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, NVL(p_module,C_DEFAULT_MODULE), p_msg);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
   IF g_log_level <= FND_LOG.LEVEL_UNEXPECTED THEN
      fnd_log.string(LOG_LEVEL => FND_LOG.LEVEL_UNEXPECTED,
                     MODULE    => NVL(p_module,C_DEFAULT_MODULE),
                     MESSAGE   => 'Unexpected Error While Executing ' || p_module );
   END IF;
END trace;

-- The function is used by the Payables Report
-- The function returns number of entries transferred to GL, No. of entries with
-- the transfer error and entries with the accounting entry creation errors.
FUNCTION get_control_info( p_sob_id        NUMBER,
                           p_period_name   VARCHAR2,
                           p_error_type    VARCHAR2
                         ) RETURN NUMBER IS
  l_rec_count   NUMBER := 0;
  l_log_module  VARCHAR2(255);
BEGIN

  IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_control_info';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GET_CONTROL_INFO'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  FOR i IN g_control_info.first..g_control_info.last loop
   IF (g_control_info(i).sob_id = p_sob_id) AND
      (g_control_info(i).period_name = p_period_name) then
      IF p_error_type = 'ENTRIES_TRANSFERRED' then
         l_rec_count := g_control_info(i).rec_transferred;
      ELSIF p_error_type = 'TRANSFER_ERRORS' THEN
         l_rec_count := g_control_info(i).cnt_transfer_errors;
      ELSE
         l_rec_count := g_control_info(i).cnt_acct_errors;
      END IF;
   END IF;
 END LOOP;

 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value = ' || TO_CHAR(l_rec_count)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of function GET_CONTROL_INFO'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
 END IF;

 RETURN(l_rec_count);
EXCEPTION
   WHEN OTHERS THEN
     RETURN(0);
END get_control_info;

PROCEDURE xla_message( p_message_code   VARCHAR2,
                       p_token_1        VARCHAR2 DEFAULT NULL,
                       p_token_1_value  VARCHAR2 DEFAULT NULL,
                       p_token_2        VARCHAR2 DEFAULT NULL,
                       p_token_2_value  VARCHAR2 DEFAULT NULL,
                       p_token_3        VARCHAR2 DEFAULT NULL,
                       p_token_3_value  VARCHAR2 DEFAULT NULL,
                       p_module_name    VARCHAR2,
                       p_level          NUMBER
                       ) IS
  l_log_module  VARCHAR2(255);
BEGIN
   -- 1. If p_message_code is NOT NULL, the msg will be interpreted from msg dictionary;
   -- 2. If p_message_code is NULL, the msg(passed from p_token_1);

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.xla_message';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure XLA_MESSAGE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


   IF p_message_code is NOT NULL THEN
      FND_MESSAGE.SET_NAME('XLA',p_message_code);
      IF p_token_1 IS NOT NULL THEN
         fnd_message.set_token(p_token_1, p_token_1_value);
      END IF;
      IF p_token_2 IS NOT NULL THEN
         fnd_message.set_token(p_token_2, p_token_2_value);
      END IF;
      IF p_token_3 IS NOT NULL THEN
         fnd_message.set_token(p_token_3, p_token_3_value);
      END IF;
      trace(fnd_message.get, p_level, p_module_name);

   ELSE
      trace(p_token_1, p_level, p_module_name);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure XLA_MESSAGE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


END xla_message;

PROCEDURE xla_app_error( p_message_code   VARCHAR2,
             p_token_1        VARCHAR2,
             p_token_1_value  VARCHAR2,
             p_token_2        VARCHAR2 DEFAULT NULL,
             p_token_2_value  VARCHAR2 DEFAULT NULL,
             p_token_3        VARCHAR2 DEFAULT NULL,
             p_token_3_value  VARCHAR2 DEFAULT NULL,
             p_debug          VARCHAR2
             ) IS
  l_log_module  VARCHAR2(255);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.xla_app_error';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure XLA_APP_ERROR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   FND_MESSAGE.SET_NAME('XLA',p_message_code);
   IF p_token_1 IS NOT NULL THEN
      fnd_message.set_token(p_token_1, p_token_1_value);
   END IF;
   IF p_token_2 IS NOT NULL THEN
      fnd_message.set_token(p_token_2, p_token_2_value);
   END IF;
   IF p_token_3 IS NOT NULL THEN
      fnd_message.set_token(p_token_3, p_token_3_value);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure XLA_APP_ERROR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

END ;

-- Function to return the link_id
FUNCTION get_linkid(p_program_name VARCHAR2) RETURN NUMBER IS
   l_linkid NUMBER;
   statement VARCHAR2(1000);
   l_log_module  VARCHAR2(255);
BEGIN
   -- Returns link id
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_linkid';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GET_LINKID'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;

  statement := 'select ' || g_lines_sequence_name ||
               '.NEXTVAL  from dual';

  EXECUTE IMMEDIATE statement INTO l_linkid;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value = ' || to_char(l_linkid)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of function GET_LINKID'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;

  RETURN (l_linkid);
EXCEPTION
   WHEN OTHERS THEN
   IF g_log_level <= FND_LOG.LEVEL_UNEXPECTED THEN
         fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                        l_log_module,
                        'Unexpected Error While Executing  ' || l_log_module);
   END IF;
END get_linkid;


-- Does period validation if GL is Installed.
PROCEDURE validate_periods(p_selection_type  IN VARCHAR2,
                           p_sob_list        IN t_sob_list,
                           p_program_name    IN VARCHAR2,
                           p_start_date      IN DATE,
                           p_end_date        IN DATE ) IS
l_periods            VARCHAR2(30);
l_start_date         DATE;
l_begin_date         DATE;
l_end_date           DATE;
l_open_start_date    DATE;
l_open_end_date      DATE;
l_max_end_date       DATE;
l_period_status      VARCHAR2(1);
l_headers_cnt        NUMBER := 0;
cid                  NUMBER;
statement            VARCHAR2(2000);
l_log_module         VARCHAR2(255);
   -- Get periods that are not Open or Future Open in the specified
   -- date range.

   CURSOR c_getClosedPeriods(c_sob_id       NUMBER,
                             c_start_date   DATE,
                             c_end_date     DATE ) IS
       SELECT   gps.period_name, gps.start_date, gps.end_date, gps.closing_status
       FROM     gl_period_statuses gps
       WHERE    gps.application_id  = 101
       AND      gps.set_of_books_id = c_sob_id
       AND      Nvl(gps.adjustment_period_flag,'N') = 'N'
       AND      gps.end_date       >= c_start_date
       AND      gps.start_date     <= c_end_date
       AND      gps.closing_status NOT IN ('O','F')
       ORDER BY gps.start_date;
BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.validate_periods';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure VALIDATE_PERIODS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;

   -- Validate period for all set of books.
   FOR i IN p_sob_list.first..p_sob_list.last LOOP
      IF  p_sob_list(i).sob_id IS NOT NULL THEN
         IF p_selection_type = 1 THEN
            -- Get the start date of the first open or future open
            -- period and end date of the last open period.
            BEGIN
               SELECT min(start_date), max(end_date)
               INTO   l_open_start_date, l_open_end_date
               FROM   gl_period_statuses
               WHERE  application_id  = 101
               AND    set_of_books_id = p_sob_list(i).sob_id
               AND    Nvl(adjustment_period_flag,'N') = 'N'
               AND    closing_status IN ( 'O','F');
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- There are no open periods
                  -- Log message to a log file
                  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                      xla_message('XLA_GLT_NO_OPEN_PERIODS',
                                  'SOB_NAME', p_sob_list(i).sob_name,
                                  '', '',
                                  '','',
                                  l_log_module,
                                  C_LEVEL_EXCEPTION );
                 END IF;

                  -- Log message to output file
                 xla_app_error(
                    p_message_code  =>  'XLA_GLT_NO_OPEN_PERIODS',
                    p_token_1       =>  'SOB_NAME',
                    p_token_1_value =>   p_sob_list(i).sob_name,
                    p_debug         => 'N' );

                  APP_EXCEPTION.RAISE_EXCEPTION;
            END;

            -- Set start date

            -- Bug3226680. Changed the condition from Greatest to NVL.
            l_start_date := NVL(p_start_date,l_open_start_date);

            -- Check for closed periods
            OPEN c_getClosedPeriods(p_sob_list(i).sob_id,
                                    l_start_date,
                                    p_end_date
                                    );
            LOOP
               FETCH c_getClosedPeriods
               INTO  l_periods, l_begin_date, l_end_date, l_period_status;
               EXIT  WHEN c_getClosedPeriods%NOTFOUND;

               OPEN c_get_program_info(p_program_name);
               LOOP -- to process multiple accounting entities
                  FETCH c_get_program_info
                  INTO  g_events_table, g_headers_table, g_lines_table,
                        g_encumbrance_table, g_lines_sequence_name,
                        g_enc_sequence_name, g_actual_table_alias,
                        g_enc_table_alias;
                  EXIT WHEN c_get_program_info%NOTFOUND;
                  statement :=
                    ' SELECT COUNT(*)
                      FROM dual
                      WHERE EXISTS (
                          SELECT ''x''
                          FROM ' || g_headers_table ||
                          ' WHERE accounting_date BETWEEN :b_begin_date AND :b_end_date
                            AND  set_of_books_id =  :sob_id
                            AND  gl_transfer_flag = ''N'')';
                    EXECUTE IMMEDIATE statement
                    INTO l_headers_cnt
                    USING l_begin_date, l_end_date, p_sob_list(i).sob_id;

                  -- Display an error message if there are records in the
                  -- closed period.
                  IF l_headers_cnt > 0 THEN
                     g_proceed := 'N';
                     CLOSE c_get_program_info;
                     CLOSE c_getClosedPeriods;

                     -- Display error message when there are unposted records in given period
                     -- and the period is closed.
                     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                         xla_message('XLA_GLT_PERIOD_CLOSED',
                                     'PERIOD', l_periods,
                                     'SOB_NAME', p_sob_list(i).sob_name,
                                     '','',
                                     l_log_module,
                                     C_LEVEL_EXCEPTION );
                     END IF;

                     xla_app_error(
                      p_message_code  =>  'XLA_GLT_PERIOD_CLOSED',
                      p_token_1       =>  'PERIOD',
                      p_token_1_value =>  l_periods,
                      p_token_2       =>  'SOB_NAME',
                      p_token_2_value =>   p_sob_list(i).sob_name,
                      p_debug         => 'N' );

                     APP_EXCEPTION.RAISE_EXCEPTION;
                  END IF;
               END LOOP; -- Multiple Accounting Entries
               CLOSE c_get_program_info;
            END LOOP; -- Cursor c_getClosedPeriods
            CLOSE c_getClosedPeriods;
          ELSE -- Document Level Transfer
            OPEN c_getClosedPeriods(p_sob_list(i).sob_id,
                                    p_start_date,
                                    p_end_date
                                    );
            LOOP
               FETCH c_getClosedPeriods
               INTO  l_periods, l_begin_date, l_end_date, l_period_status;
               EXIT  WHEN c_getClosedPeriods%NOTFOUND;
               IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                   xla_message('XLA_GLT_PERIOD_CLOSED',
                               'PERIOD', l_periods,
                               'SOB_NAME', p_sob_list(i).sob_name,
                               '','',
                               l_log_module,
                               C_LEVEL_ERROR );
               END IF;

               xla_app_error(
                      p_message_code  =>  'XLA_GLT_PERIOD_CLOSED',
                      p_token_1       =>  'PERIOD',
                      p_token_1_value =>  l_periods,
                      p_token_2       =>  'SOB_NAME',
                      p_token_2_value =>   p_sob_list(i).sob_name,
                      p_debug         => 'N' );

               APP_EXCEPTION.RAISE_EXCEPTION;
            END LOOP;
            CLOSE c_getClosedPeriods;
         END IF; -- Selection Type
      END IF;
   END LOOP; -- Set of Books
   -- There are no closed periods.  The transfer should continue.

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure VALIDATE_PERIODS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

END validate_periods;

-- Get the accounting date range
PROCEDURE get_date_range(p_transfer_run_id IN  NUMBER,
                         p_start_date      OUT NOCOPY DATE,
                         p_end_date        OUT NOCOPY DATE ) IS
  l_statement  VARCHAR2(2000);
  l_log_module VARCHAR2(255);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_date_range';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure GET_DATE_RANGE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;


   l_statement := ' SELECT MIN(accounting_date), MAX(accounting_date)
                    FROM ' ||  g_headers_table ||
                  ' WHERE  gl_transfer_run_id = :b_transfer_run_id ';

   EXECUTE IMMEDIATE l_statement
                INTO p_start_date, p_end_date
               USING p_transfer_run_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value --> p_start_date = ' || TO_CHAR(p_start_date)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'return value --> p_end_date = ' || TO_CHAR(p_end_date)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of procedure GET_DATE_RANGE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

EXCEPTION
   WHEN OTHERS THEN
   IF g_log_level <= FND_LOG.LEVEL_UNEXPECTED THEN
         fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                        l_log_module,
                        'Unexpected Error While Executing  ' || l_log_module);
   END IF;
END get_date_range;

PROCEDURE select_acct_headers( p_selection_type    NUMBER,
                               p_set_of_books_id   NUMBER,
                               p_source_id         NUMBER   DEFAULT NULL,
                               p_source_table      VARCHAR2 DEFAULT NULL,
                               p_transfer_run_id   NUMBER,
                               p_request_id        NUMBER,
                               p_ae_category       t_ae_category,
                               p_start_date        DATE,
                               p_end_date          DATE,
                               p_legal_entity_id   NUMBER,
                               p_cost_group_id     NUMBER,
                               p_cost_type_id      NUMBER,
                               p_validate_account  VARCHAR2 ) IS
   statement             VARCHAR2(4000) ;
   l_where               VARCHAR2(2000) ;
   l_where_error         VARCHAR2(2000);
   cid                   NUMBER;
   rows_processed        NUMBER;
   l_ae_category         VARCHAR2(1000);
   l_acct_errors         NUMBER := 0;
   l_log_module VARCHAR2(255);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.select_acct_headers';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure SELECT_ACCT_HEADERS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF Nvl(p_selection_type,1) = 1 THEN -- for batch transfer
      IF p_legal_entity_id IS NOT NULL  THEN
         -- Manufacturing Transfer
         l_where  := ' AND   aeh.accounting_date BETWEEN :b_start_date  AND :b_end_date
                       AND   aeh.legal_entity_id  = :b_legal_entity_id
                       AND   aeh.cost_group_id    = :b_cost_group_id
                       AND   aeh.cost_type_id     = :b_cost_type_id ';
      ELSE
         -- Allow user to transfer multiple journal categories. Following will
         -- generate a string to transfer multiple categories.
         IF p_ae_category.COUNT > 1 THEN
            l_ae_category := 'AND aeh.ae_category IN ( ';
            FOR i IN p_ae_category.FIRST..p_ae_category.LAST LOOP
               l_ae_category := l_ae_category || '''' || p_ae_category(i) || '''';
               IF i < p_ae_category.COUNT THEN
                  l_ae_category := l_ae_category || ', ';
               END IF;
            END LOOP;
            l_ae_category := l_ae_category || ' ) ';
         ELSE
            l_ae_category :=  ' AND aeh.ae_category =  Decode(:b_journal_category,
                                                             ''A'', aeh.ae_category,
                                                             :b_journal_category)';
         END IF;

         --Where clause is different based on if g_events_table is NULL or not.
         --This is intended for design enhancement. pls refer to bug#1748305.
         --Which means: ledgers of an event will be transferred only when the event
         --status is 'ACCOUNTED'.
         IF g_events_table IS NULL   THEN  --eg. CST
             l_where :=
                    ' AND   aeh.accounting_date BETWEEN :b_start_date  AND :b_end_date '
                      ||    l_ae_category ||
                    ' AND   aeh.set_of_books_id = :b_set_of_books_id '
                      ||
                    ' AND   NOT EXISTS ( SELECT ''x'' FROM ' || g_lines_table || ' ael
                                        WHERE ael.ae_header_id = aeh.ae_header_id
                                        AND ael.accounting_error_code IS NOT NULL ) ';
         ELSE -- g_events_table is not null like AP
             l_where_error :=
                    ' AND   aeh.accounting_date BETWEEN :b_start_date  AND :b_end_date '
                      ||    l_ae_category ||
                    ' AND   aeh.set_of_books_id = :b_set_of_books_id
                      AND   EXISTS
                            ( SELECT ''x''
                              FROM   ' || g_events_table  || ' ace
                              WHERE  aeh.accounting_event_id = ace.accounting_event_id
                              AND    ace.event_status_code = ''ACCOUNTED WITH ERROR'' ) ';

      -- Bug2789042. Added the l_where_error to detect errors.
             l_where :=
                    ' AND   aeh.accounting_date BETWEEN :b_start_date  AND :b_end_date '
                      ||    l_ae_category ||
                    ' AND   aeh.set_of_books_id = :b_set_of_books_id
                      AND   EXISTS
                            ( SELECT ''x''
                              FROM   ' || g_events_table  || ' ace
                              WHERE  aeh.accounting_event_id = ace.accounting_event_id
                              AND    ace.event_status_code = ''ACCOUNTED'' ) ';
         END IF;


      END IF;
    ELSE --for Document Level Transfer
      -- Currently supported for Payables and PSB only.
      l_where :=    ' AND   aeh.set_of_books_id = :b_set_of_books_id
                      AND   EXISTS
                            ( SELECT ''x''
                              FROM   ' || g_events_table  || ' ace
                              WHERE  aeh.accounting_event_id = ace.accounting_event_id
                              AND    ace.event_status_code = ''ACCOUNTED''
                              AND    ace.source_id = :b_source_id
                              AND    ace.source_table = :b_source_table) ';


      -- Bug2789042. Added the l_where_error to detect errors.
      l_where_error :=    ' AND   aeh.set_of_books_id = :b_set_of_books_id
                      AND   EXISTS
                            ( SELECT ''x''
                              FROM   ' || g_events_table  || ' ace
                              WHERE  aeh.accounting_event_id = ace.accounting_event_id
                              AND    ace.event_status_code = ''ACCOUNTED WITH ERROR''
                              AND    ace.source_id = :b_source_id
                              AND    ace.source_table = :b_source_table) ';
    END IF;

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           xla_message('XLA_GLT_SELECTING_HEADERS',
                       '','',
                       '','',
                       '','',
                       l_log_module,
                       C_LEVEL_STATEMENT);
       END IF;

      -- Select header entries with no line creation errors and update the error code
      -- the entries are in the closed GL period.

      statement := ' UPDATE ' || g_headers_table || ' aeh
                     SET program_update_date = Sysdate,
                         program_id = :b_program_id,
                         request_id = :b_request_id,
                         gl_transfer_run_id  = :b_transfer_run_id,
                         gl_transfer_error_code = NULL,
                         gl_transfer_flag       = ''Y''
                    WHERE gl_transfer_run_id = -1
                    AND   gl_transfer_flag   IN ( ''N'',''E'')
                    AND   aeh.accounting_error_code IS NULL ' || l_where;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN

           trace
               (p_msg      => 'l_where = ' || l_where
               ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);

           trace
               (p_msg      => 'l_where_error = ' || l_where_error
               ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);

           trace
               (p_msg      => 'l_ae_category = ' || l_ae_category
               ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);

           trace
               (p_msg      => 'statement = ' || statement
               ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);

         END IF;



         cid := dbms_sql.open_cursor;
           dbms_sql.parse(cid, statement, dbms_sql.native);

   -- Bind Variables
           dbms_sql.bind_variable(cid,':b_transfer_run_id', p_transfer_run_id);
           dbms_sql.bind_variable(cid,':b_program_id', g_program_id);
           dbms_sql.bind_variable(cid,':b_request_id', p_request_id);

   IF Nvl(p_selection_type,1) = 1 THEN -- for batch transfer
      IF p_legal_entity_id IS NOT NULL  THEN
         -- Manufacturing Transfer
           dbms_sql.bind_variable(cid,':b_legal_entity_id', p_legal_entity_id);
           dbms_sql.bind_variable(cid,':b_cost_group_id', p_cost_group_id);
           dbms_sql.bind_variable(cid,':b_cost_type_id', p_cost_type_id);
           dbms_sql.bind_variable(cid,':b_start_date', p_start_date);
           dbms_sql.bind_variable(cid,':b_end_date', p_end_date);
      ELSE
         -- Allow user to transfer multiple journal categories. Following will
         -- generate a string to transfer multiple categories.
         IF p_ae_category.COUNT > 1 THEN
            NULL;
         ELSE
            dbms_sql.bind_variable(cid,':b_journal_category', p_ae_category(1));
         END IF;

           dbms_sql.bind_variable(cid,':b_start_date', p_start_date);
           dbms_sql.bind_variable(cid,':b_end_date', p_end_date);
           dbms_sql.bind_variable(cid,':b_set_of_books_id', p_set_of_books_id);
      END IF;
   ELSE --for Document Level Transfer
           dbms_sql.bind_variable(cid,':b_set_of_books_id', p_set_of_books_id);
           dbms_sql.bind_variable(cid,':b_source_id', p_source_id);
           dbms_sql.bind_variable(cid,':b_source_table', p_source_table);
   END IF;


           rows_processed :=  dbms_sql.execute(cid);

           dbms_sql.close_cursor(cid);
        IF rows_processed > 0 THEN
           g_headers_selected := rows_processed;
           -- Populate records transferred only when account validation
           -- is not done
           IF Nvl(p_validate_account,'N') <> 'Y' THEN
              g_control_info(g_periods_cnt).rec_transferred :=
                Nvl(g_control_info(g_periods_cnt).rec_transferred,0) + g_headers_selected;
           END IF;

           g_proceed := 'Y';
           xla_message('XLA_GLT_SELECTED_HEADERS','COUNT',rows_processed,'','','','',
                       l_log_module,
                       C_LEVEL_STATEMENT);
        ELSE
           g_proceed := 'N';
           xla_message('XLA_GLT_NO_ENTRIES_TO_PROCESS','','','','','','',
                       l_log_module,
                       C_LEVEL_STATEMENT);
        END IF;

    -- Currently for Payables only. Needs to be modifed for CST
   IF Nvl(p_selection_type,1) = 1 THEN -- for batch transfer
        IF p_legal_entity_id IS NULL THEN
        -- Bug2708663. Removed the extra Exists Condition.
          statement := ' SELECT COUNT(aeh.gl_transfer_run_id)
                         FROM '  || g_headers_table || ' aeh
                         WHERE  gl_transfer_run_id = -1 ' || l_where_error;
        -- Bug2789042. Added the l_where_error to report errors.
             IF p_ae_category.COUNT = 1 THEN
                  EXECUTE IMMEDIATE statement
                               INTO l_acct_errors
                              USING p_start_date, p_end_date, p_ae_category(1),
                                    p_ae_category(1),p_set_of_books_id;
             ELSE
                EXECUTE IMMEDIATE statement
                             INTO l_acct_errors
                            USING p_start_date, p_end_date, p_set_of_books_id;

             END IF;
             g_control_info(g_periods_cnt).cnt_acct_errors :=
             g_control_info(g_periods_cnt).cnt_acct_errors + l_acct_errors;
        END IF;
    END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure SELECT_ACCT_HEADERS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

END select_acct_headers;

PROCEDURE validate_acct_lines( p_selection_type    NUMBER,
                               p_set_of_books_id   NUMBER,
                               p_coa_id            NUMBER,
                               p_transfer_run_id   NUMBER,
                               p_start_date        DATE,
                               p_end_date          DATE ) IS
   statement             VARCHAR2(4000) ;
   cid                   NUMBER;
   rows_processed        NUMBER;
   l_log_module VARCHAR2(255);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.validate_acct_lines';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure validate_acct_lines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      xla_message('XLA_GLT_VALIDATE_LINES','','','','','','',
                  l_log_module,
                  C_LEVEL_STATEMENT);
   END IF;
   ----------------------------------------------------------

   -- Bug2842884. Budget journals need to be validated for detail_budgeting_allowed_flag = 'Y'.

   IF g_entry_type = 'B' THEN
      statement :=
         'UPDATE ' || g_lines_table || ' ael
          SET ael.gl_transfer_error_code =
            ( SELECT Decode(gcc.detail_budgeting_allowed_flag, ''N'', ''POST'',
                            Decode(gcc.summary_flag, ''Y'', ''POST'',
                                   Decode(template_id, NULL,
                                          Decode(enabled_flag, ''N'', ''DISABLED'',
                                                 Decode(nvl(gcc.code_combination_id,-1) , -1, ''INVALID'',
                                                        Decode(Sign(gcc.start_date_active - aeh.accounting_date), 1, ''INACTIVE'',
                                                               Decode(Sign(aeh.accounting_date - gcc.end_date_active), 1, ''INACTIVE'',
                                                                      NULL)))),
                                                        ''POST''))) FROM ' || g_headers_table || ' aeh, gl_code_combinations gcc
              WHERE aeh.ae_header_id = ael.ae_header_id
              AND   gcc.code_combination_id = ael.code_combination_id
              AND   gcc.chart_of_accounts_id = :b_coa_id )
        WHERE ael.ae_header_id IN ( SELECT ae_header_id FROM ' || g_headers_table ||  ' aeh
                                    WHERE  aeh.gl_transfer_run_id = :b_transfer_run_id
                                    AND  aeh.accounting_date BETWEEN :b_start_date AND :b_end_date) ';
   ELSE
      statement :=
         'UPDATE ' || g_lines_table || ' ael
          SET ael.gl_transfer_error_code =
            ( SELECT Decode(gcc.detail_posting_allowed_flag, ''N'', ''POST'',
                            Decode(gcc.summary_flag, ''Y'', ''POST'',
                                   Decode(template_id, NULL,
                                          Decode(enabled_flag, ''N'', ''DISABLED'',
                                                 Decode(nvl(gcc.code_combination_id,-1) , -1, ''INVALID'',
                                                        Decode(Sign(gcc.start_date_active - aeh.accounting_date), 1, ''INACTIVE'',
                                                               Decode(Sign(aeh.accounting_date - gcc.end_date_active), 1, ''INACTIVE'',
                                                                      NULL)))),
                                                        ''POST''))) FROM ' || g_headers_table || ' aeh, gl_code_combinations gcc
              WHERE aeh.ae_header_id = ael.ae_header_id
              AND   gcc.code_combination_id = ael.code_combination_id
              AND   gcc.chart_of_accounts_id = :b_coa_id )
        WHERE ael.ae_header_id IN ( SELECT ae_header_id FROM ' || g_headers_table ||  ' aeh
                                    WHERE  aeh.gl_transfer_run_id = :b_transfer_run_id
                                    AND  aeh.accounting_date BETWEEN :b_start_date AND :b_end_date) ';
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
            (p_msg   => 'statement = ' || statement
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF;

   cid := dbms_sql.open_cursor;
   dbms_sql.parse(cid, statement, dbms_sql.native);

   -- Bind Variables
   dbms_sql.bind_variable(cid,':b_coa_id', p_coa_id);
   dbms_sql.bind_variable(cid,':b_transfer_run_id', p_transfer_run_id);
   dbms_sql.bind_variable(cid,':b_start_date', p_start_date);
   dbms_sql.bind_variable(cid,':b_end_date', p_end_date);

   rows_processed :=  dbms_sql.execute(cid);
   dbms_sql.close_cursor(cid);

   IF rows_processed = 0 THEN
      g_proceed := 'N';
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       xla_message('XLA_GLT_LINES_UPDATED','COUNT',rows_processed,'','','','',
                   l_log_module,
                   C_LEVEL_STATEMENT);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure validate_acct_lines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


END validate_acct_lines;

PROCEDURE  validate_acct_headers ( p_selection_type     NUMBER,
                                   p_set_of_books_id    NUMBER,
                                   p_transfer_run_id    NUMBER,
                                   p_start_date         DATE,
                                   p_end_date           DATE ) IS
  cid                     NUMBER;
  statement               VARCHAR2(4000);
  l_invalid_headers       NUMBER;
  l_log_module            VARCHAR2(255);

BEGIN

    -- Reset the batch_run_id to -1 and set gl_tranfer_flag to 'E' to
    -- deselect the headers with erroneous accounting entry lines.

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.validate_acct_lines';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure validate_acct_headers'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     xla_message('XLA_GLT_VALIDATE_HEADERS','','','','','','',
                  l_log_module,
                  C_LEVEL_STATEMENT);
   END IF;

     statement := ' UPDATE ' || g_headers_table || ' aeh
                    SET    aeh.gl_transfer_run_id  = -1,
                           aeh.gl_transfer_flag = ''E''
                    WHERE  aeh.gl_transfer_run_id =  :b_transfer_run_id
                    AND    aeh.accounting_date BETWEEN :b_start_date AND :b_end_date
                    AND EXISTS ( SELECT ''x'' FROM ' || g_lines_table || ' ael
                                 WHERE  ael.ae_header_id = aeh.ae_header_id
                                 AND   ael.gl_transfer_error_code IS NOT NULL )';

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
            (p_msg   => 'statement = ' || statement
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF;

    cid := dbms_sql.open_cursor;
    dbms_sql.parse(cid, statement, dbms_sql.native);
    dbms_sql.bind_variable(cid,':b_transfer_run_id', p_transfer_run_id);
    dbms_sql.bind_variable(cid,':b_start_date', p_start_date);
    dbms_sql.bind_variable(cid,':b_end_date', p_end_date);

    l_invalid_headers :=  dbms_sql.execute(cid);

    dbms_sql.close_cursor(cid);

    g_control_info(g_periods_cnt).cnt_transfer_errors :=
            g_control_info(g_periods_cnt).cnt_transfer_errors + l_invalid_headers;

    -- subtract invalid headers from selected headers.  If the number is > 0
    -- then proceed otherwise stop the transfer.
    g_headers_selected := g_headers_selected - l_invalid_headers;

    IF (g_headers_selected > 0) THEN
       g_proceed := 'Y';
       g_control_info(g_periods_cnt).rec_transferred :=
            Nvl(g_control_info(g_periods_cnt).rec_transferred,0)
         + (g_headers_selected);
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          xla_message('XLA_GLT_HEADERS_TRANSFERRED','COUNT',g_headers_selected ,'','','','',
                      l_log_module,
                      C_LEVEL_STATEMENT);
       END IF;
    ELSE
       g_proceed := 'N';
    END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure validate_acct_headers'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


END validate_acct_headers;

PROCEDURE transfer_enc_lines( p_application_id         NUMBER,
                              p_set_of_books_id        NUMBER,
                              p_transfer_run_id        NUMBER,
                              p_start_date             DATE,
                              p_end_date               DATE,
                              p_next_period            VARCHAR2,
                              p_reversal_date          VARCHAR2,
                              p_average_balances_flag  VARCHAR2,
                              p_source_name            VARCHAR2,
                              p_group_id               NUMBER,
                              p_request_id             NUMBER,
                              p_batch_desc             VARCHAR2,
                              p_je_desc                VARCHAR2,
                              p_je_line_desc           VARCHAR2 ) IS
    statement            VARCHAR2(4000) ;
    cid                  NUMBER;
    rows_processed       NUMBER;
    l_log_module         VARCHAR2(255);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.transfer_enc_lines';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure transfer_enc_lines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

    IF g_proceed = 'N' THEN
       RETURN;
    END IF;

  -- Encumbrances are always transferred in Detail.
  -- Populate Link Id for only valid accounting entry headers.
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      xla_message('XLA_GLT_UPDATE_ENC_LINKID','','','','','','',
                  l_log_module,
                  C_LEVEL_STATEMENT);
   END IF;

   statement := 'UPDATE ' || g_encumbrance_table ||
                ' SET   program_update_date    = Sysdate,
                        program_id = :b_program_id,
                        request_id = :b_request_id,
                        gl_sl_link_id = ' || g_enc_sequence_name || '.NEXTVAL
                 WHERE ae_header_id IN ( SELECT ae_header_id FROM ' || g_headers_table
                        || ' WHERE gl_transfer_run_id = :b_transfer_run_id
                             AND   accounting_date BETWEEN :b_start_date AND :b_end_date )';

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
            (p_msg   => 'statement = ' || statement
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF;


   cid := dbms_sql.open_cursor;
   dbms_sql.parse(cid, statement, dbms_sql.native);
   dbms_sql.bind_variable(cid,':b_transfer_run_id', p_transfer_run_id);
   dbms_sql.bind_variable(cid,':b_program_id', g_program_id);
   dbms_sql.bind_variable(cid,':b_request_id', p_request_id);
   dbms_sql.bind_variable(cid,':b_start_date', p_start_date);
   dbms_sql.bind_variable(cid,':b_end_date', p_end_date);

   rows_processed :=  dbms_sql.execute(cid);
   dbms_sql.close_cursor(cid);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      xla_message('XLA_GLT_UPDATE_ENC_LINES','COUNT',rows_processed,'','','','',
                  l_log_module,
                  C_LEVEL_STATEMENT);
   END IF;

   -- Transfer Encumbrance entries to gl_interface table.
   IF rows_processed > 0 THEN
      g_rec_transfer_flag  := 'Y';  --set the globle flag to 'Y' whenever there are records transferred.
      g_enc_proceed        := 'Y';  --set the funds check flag if there are encumbrance entries.

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          xla_message('XLA_GLT_INSERTING_ENC_LINES','','','','','','',
                  l_log_module,
                  C_LEVEL_STATEMENT);
      END IF;

      statement := 'INSERT INTO gl_interface(
                    status,                      set_of_books_id,
                    user_je_source_name,         user_je_category_name,
                    accounting_date,             currency_code,
                    date_created,                created_by,
                    actual_flag,                 encumbrance_type_id,
                    code_combination_id,         stat_amount,
                    entered_dr,                  entered_cr,
                    accounted_dr,                accounted_cr,
                    reference1,                  reference2,
                    reference7,                  reference8,
                    reference5,                  reference10,
                    reference21,                 reference22,
                    reference23,                 reference24,
                    reference25,                 reference26,
                    reference27,                 reference28,
                    reference29,                 reference30,
                    subledger_doc_sequence_id,
                    subledger_doc_sequence_value,
                    gl_sl_link_table,            gl_sl_link_id,
                    je_header_id,                group_id
                    )
              SELECT
                     ''NEW'',                       aeh.set_of_books_id,
                    :b_source_name,                 jc.user_je_category_name,
                    aeh.accounting_date,            :b_base_currency_code,
                    Sysdate,                        :b_user_id,
                    ''E'',                          ael.encumbrance_type_id,
                    ael.code_combination_id,        stat_amount,
                    accounted_dr,                   accounted_cr,
                    accounted_dr,                   accounted_cr,
                    :b_batch_name,                  :b_batch_desc,
                    aeh.gl_reversal_flag,
                    Decode(Nvl(aeh.gl_reversal_flag,''N''), ''Y'',
                       Decode(Nvl(:b_average_balances_flag,''N''),
                          ''Y'',to_char(:b_reversal_date),:b_next_period),NULL),
                    :b_je_desc,                     :b_je_line_desc,
                    ael.reference1,                 ael.reference2,
                    ael.reference3,                 ael.reference4,
                    ael.reference5,                 ael.reference6,
                    ael.reference7,                 ael.reference8,
                    ael.reference9,                 ael.reference10,
                    ael.subledger_doc_sequence_id,
                    ael.subledger_doc_sequence_value,
                    :b_link_table,                  ael.gl_sl_link_id,
                     -1,                            :b_group_id
             FROM '|| g_headers_table ||' aeh, '|| g_encumbrance_table ||
                   ' ael, gl_je_categories jc
         WHERE ael.ae_header_id         = aeh.ae_header_id
         AND  aeh.set_of_books_id       =  :b_set_of_books_id
         AND  aeh.gl_transfer_run_id    =  :b_transfer_run_id
         AND  aeh.accounting_date BETWEEN :b_start_date AND :b_end_date
         AND  jc.je_category_name       = aeh.ae_category';

         cid := dbms_sql.open_cursor;
         dbms_sql.parse(cid, statement, dbms_sql.native);

         -- Bind variables
         dbms_sql.bind_variable(cid,':b_set_of_books_id', p_set_of_books_id);
         dbms_sql.bind_variable(cid,':b_transfer_run_id', p_transfer_run_id);
         dbms_sql.bind_variable(cid,':b_source_name', p_source_name);
         dbms_sql.bind_variable(cid,':b_batch_name', g_batch_name);
         dbms_sql.bind_variable(cid,':b_group_id', p_group_id);
         dbms_sql.bind_variable(cid,':b_user_id', g_user_id);
         dbms_sql.bind_variable(cid,':b_base_currency_code', g_base_currency_code);
         dbms_sql.bind_variable(cid,':b_link_table', g_enc_table_alias);
         dbms_sql.bind_variable(cid,':b_start_date', p_start_date);
         dbms_sql.bind_variable(cid,':b_end_date', p_end_date);
         dbms_sql.bind_variable(cid,':b_batch_desc', p_batch_desc);
         dbms_sql.bind_variable(cid,':b_je_desc', p_je_desc);
         dbms_sql.bind_variable(cid,':b_je_line_desc', p_je_line_desc);
         dbms_sql.bind_variable(cid,':b_next_period', p_next_period);

         dbms_sql.bind_variable(cid,':b_reversal_date', p_reversal_date);
         dbms_sql.bind_variable(cid,':b_average_balances_flag', p_average_balances_flag);

         rows_processed :=  dbms_sql.execute(cid);
         dbms_sql.close_cursor(cid);
         g_sob_rows_created := g_sob_rows_created + rows_processed;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            xla_message('XLA_GLT_INSERTED_ENC_LINES','COUNT',rows_processed,'','','','',
                         l_log_module,
                         C_LEVEL_STATEMENT);
         END IF;

   ELSE
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           xla_message('XLA_GLT_NO_ENC_LINES','','','','','','',
                       l_log_module,
                       C_LEVEL_STATEMENT);
       END IF;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure transfer_enc_lines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

END transfer_enc_lines;

-- This procedure transfers all the journal lines in summarized mode.
-- Summarization can be by accounting date/period depending on what
-- the user has choosen.

-- In case entries exist in XLA_JE_LINE_TYPES, all those records
-- with summary_flag = 'D' will be omitted.

-- All the line_type_code with 'D' are stored in g_line_type variable.

PROCEDURE gl_insert_summary( p_request_id             NUMBER,
                             p_source_name            VARCHAR2,
                             p_transfer_run_id        NUMBER,
                             p_period_name            VARCHAR2,
                             p_start_date             DATE,
                             p_end_date               DATE,
                             p_next_period            VARCHAR2,
                             p_reversal_date          DATE,
                             p_average_balances_flag  VARCHAR2,
                             p_gl_transfer_mode       VARCHAR2,
                             p_group_id               NUMBER,
                             p_batch_desc             VARCHAR2,
                             p_je_desc                VARCHAR2,
                             p_je_line_desc           VARCHAR2) IS

   statement_summary          VARCHAR2(10000) ;

   cid                        BINARY_INTEGER;
   rows_processed             NUMBER;

   l_from                     VARCHAR2(1000);
   l_where                    VARCHAR2(1000);
   l_reference3               VARCHAR2(400);

   l_select_actual_flag       VARCHAR2(1000);  -- This is for different entry type A or B
   l_insert_actual_flag       VARCHAR2(1000);  -- This is for different entry type A or B
   l_group_by_actual_flag     VARCHAR2(1000);  -- This is for different entry type A or B

   l_log_module               VARCHAR2(255);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.gl_insert_summary';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure GL_INSERT_SUMMARY'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
            (p_msg   => 'l_from = ' || l_from
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

       trace
            (p_msg   => 'l_where = ' || l_where
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);


       trace
            (p_msg   => 'l_reference3 = ' || l_reference3
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF;


   /*----------------------------------------------------------------
   1. 'A' is for Actual -- only for AP and CST -- old source code
   2. 'B' is for Budget and Actual -- new requirement for PSB
     -----------------------------------------------------------------*/
   IF g_entry_type = 'A' THEN
      l_select_actual_flag        := '''A'',';
      l_insert_actual_flag        := '';
      l_group_by_actual_flag      := '';
   ELSE --g_entry_type = 'B'
      l_select_actual_flag        := 'NVL(ael.actual_flag,''A''), aeh.budget_version_id,';
      l_insert_actual_flag        := 'budget_version_id,';
      l_group_by_actual_flag      := ',NVL(ael.actual_flag,''A''), aeh.budget_version_id';
   END IF;

   l_from := ' FROM '|| g_headers_table ||' aeh, '
                     || g_lines_table   ||' ael, '
             	     || ' gl_je_categories jc ';


   l_where := ' WHERE ael.ae_header_id      = aeh.ae_header_id
                  AND  aeh.gl_transfer_run_id = :b_transfer_run_id
                  AND  aeh.accounting_date BETWEEN :b_start_date AND :b_end_date
                  AND  jc.je_category_name    = Decode(Nvl(aeh.cross_currency_flag,''N''),
                                               ''Y'',''Cross Currency'', aeh.ae_category) ';

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       xla_message('XLA_GLT_TRANSFER_MODE_A','','','','','','',
                    l_log_module,
                    C_LEVEL_STATEMENT);
   END IF;

   IF g_line_type IS NOT NULL THEN
      l_where := l_where || 'AND ael.ae_line_type_code NOT IN (' || g_line_type || ')';
   END IF;

   IF p_gl_transfer_mode = 'A' THEN

      statement_summary := 'INSERT INTO gl_interface(
                                                 status,
                                                 set_of_books_id,
                                                 user_je_source_name,
                                                 user_je_category_name,
                                                 accounting_date,
                                                 currency_code,
                                                 date_created,
                                                 created_by,
                                                 actual_flag,
                                                 '|| l_insert_actual_flag ||'
                                                 code_combination_id,
                                                 stat_amount,
                                                 entered_dr,
                                                 entered_cr,
                                                 accounted_dr,
                                                 accounted_cr,
                                                 reference1,
                                                 reference2,
                                                 reference5,
                                                 reference10,
                                                 reference7,
                                                 reference8,
                                                 reference21,
                                                 gl_sl_link_id,
                                                 gl_sl_link_table,
                                                 request_id,
                                                 ussgl_transaction_code,
                                                 je_header_id,
                                                 group_id
                                               )
                     SELECT /*+ ORDERED */
                                                 jc.je_category_name,
                                                 aeh.set_of_books_id,
                                                 :b_source_name,
                                                 jc.user_je_category_name,
                                                 trunc(aeh.accounting_date) ,
                                                 ael.currency_code,
                                                 Sysdate,
                                                 :b_user_id,
                                                 '|| l_select_actual_flag ||'
                                                 ael.code_combination_id,
                                                 SUM(stat_amount),
                                                 SUM(entered_dr),
                                                 SUM(entered_cr),
                                                 SUM(accounted_dr),
                                                 SUM(accounted_cr),
                                                 :b_batch_name,
                                                 :b_batch_desc,
                                                 :b_je_desc,
                                                 :b_je_line_desc,
                                                 aeh.gl_reversal_flag,
                                                 Decode(Nvl(aeh.gl_reversal_flag,''N''), ''Y'',
                                                 Decode(Nvl(:b_average_balances_flag,''N''),
                                                 ''Y'',to_char(:b_reversal_date),:b_next_period),NULL),
                                                 To_char(:b_transfer_run_id),
                                                 xla_gl_transfer_pkg.get_linkid(:b_program_name),
                                                 :b_link_table,
                                                 :b_request_id,
                                                 ael.ussgl_transaction_code,
                                                 :b_transfer_run_id,
                                                 :b_group_id '
                                                 || l_from ||
                                                    l_where ||
                  ' GROUP BY  aeh.set_of_books_id, aeh.ae_category,jc.je_category_name,
                              jc.user_je_category_name, trunc(aeh.accounting_date),
                             aeh.gl_reversal_flag, ael.currency_code,
                             ael.code_combination_id,ael.ussgl_transaction_code,
                             Decode(Sign(ael.entered_dr), 1,''dr'', -1, ''dr'',
                                   0,Decode(Sign(ael.entered_cr), 1,''cr'', -1, ''cr'',''dr''),''cr'')
                           '|| l_group_by_actual_flag ;

   ELSE -- Summarized by Period
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           xla_message('XLA_GLT_TRANSFER_MODE_P','','','','','','',
                        l_log_module,
                        C_LEVEL_STATEMENT);
       END IF;

       statement_summary := 'INSERT INTO gl_interface(
                                                 status,
                                                 set_of_books_id,
                                                 user_je_source_name,
                                                 user_je_category_name,
                                                 accounting_date,
                                                 currency_code,
                                                 date_created,
                                                 created_by,
                                                 actual_flag,
                                                 '|| l_insert_actual_flag ||'
                                                 encumbrance_type_id,
                                                 code_combination_id,
                                                 stat_amount,
                                                 entered_dr,
                                                 entered_cr,
                                                 accounted_dr,
                                                 accounted_cr,
                                                 reference1,
                                                 reference2,
                                                 reference5,
                                                 reference10,
                                                 reference7,
                                                 reference8,
                                                 reference21,
                                                 gl_sl_link_id,
                                                 gl_sl_link_table,
                                                 request_id,
                                                 ussgl_transaction_code,
                                                 je_header_id,
                                                 group_id,
                                                 period_name
                                               )
                     SELECT /*+ ORDERED */
                                                 jc.je_category_name,
                                                 aeh.set_of_books_id,
                                                 :b_source_name,
                                                 jc.user_je_category_name,
                                                 :b_end_date_truncated,
                                                 ael.currency_code,
                                                 Sysdate,
                                                 :b_user_id,
                                                 '|| l_select_actual_flag ||'
                                                 NULL,
                                                 ael.code_combination_id,
                                                 SUM(stat_amount),
                                                 SUM(entered_dr),
                                                 SUM(entered_cr),
                                                 SUM(accounted_dr),
                                                 SUM(accounted_cr),
                                                 :b_batch_name,
                                                 :b_batch_desc,
                                                 :b_je_desc,
                                                 :b_je_line_desc,
                                                 aeh.gl_reversal_flag,
                                                 Decode(Nvl(aeh.gl_reversal_flag,''N''), ''Y'',
                                                 Decode(Nvl(:b_average_balances_flag,''N''),
                                                 ''Y'',To_char(:b_reversal_date),:b_next_period),NULL),
                                                 To_char(:b_transfer_run_id),
                                                 xla_gl_transfer_pkg.get_linkid(:b_program_name), :b_link_table,
                                                 :b_request_id,
                                                 ael.ussgl_transaction_code,
                                                 :b_transfer_run_id,
                                                 :b_group_id,
                                                 :b_period_name '
                                                 || l_from ||
                                                    l_where ||
                     ' GROUP BY   aeh.set_of_books_id, aeh.ae_category, jc.je_category_name,jc.user_je_category_name,
                                aeh.period_name, aeh.gl_reversal_flag, ael.currency_code,
                                ael.code_combination_id, ael.ussgl_transaction_code,
                                Decode(Sign(ael.entered_dr), 1,''dr'', -1, ''dr'',
                                0,Decode(Sign(ael.entered_cr), 1,''cr'', -1, ''cr'',''dr''),''cr'')
                                '|| l_group_by_actual_flag;
   END IF;

   cid := dbms_sql.open_cursor;
   dbms_sql.parse(cid, statement_summary, dbms_sql.native);

    --Bind Variables
   dbms_sql.bind_variable(cid,':b_user_id', g_user_id);
   dbms_sql.bind_variable(cid,':b_group_id', p_group_id);
   dbms_sql.bind_variable(cid,':b_request_id', p_request_id);
   dbms_sql.bind_variable(cid,':b_transfer_run_id', p_transfer_run_id);
   dbms_sql.bind_variable(cid,':b_source_name', p_source_name);
   dbms_sql.bind_variable(cid,':b_batch_name', g_batch_name);
   dbms_sql.bind_variable(cid,':b_link_table', g_actual_table_alias);
   dbms_sql.bind_variable(cid,':b_start_date', p_start_date);
   dbms_sql.bind_variable(cid,':b_end_date', p_end_date);
      IF p_gl_transfer_mode <> 'A' THEN
          	dbms_sql.bind_variable(cid,':b_end_date_truncated', trunc(p_end_date));
      END IF;
   dbms_sql.bind_variable(cid,':b_batch_desc', p_batch_desc);
   dbms_sql.bind_variable(cid,':b_je_desc', p_je_desc);
   dbms_sql.bind_variable(cid,':b_je_line_desc', p_je_line_desc);
   dbms_sql.bind_variable(cid,':b_next_period', p_next_period);
   dbms_sql.bind_variable(cid,':b_reversal_date', p_reversal_date);
   dbms_sql.bind_variable(cid,':b_average_balances_flag', p_average_balances_flag);
   dbms_sql.bind_variable(cid,':b_program_name', g_program_name);

   IF p_gl_transfer_mode = 'P' THEN
      dbms_sql.bind_variable(cid,':b_period_name', p_period_name);
   END IF;

   rows_processed :=  dbms_sql.execute(cid);

   IF rows_processed = 0 THEN
      g_proceed := 'N';
   ELSE
      g_sob_rows_created := g_sob_rows_created + rows_processed;
      g_rec_transfer_flag  := 'Y';  --set the globle flag to 'Y' whenever there are records transferred.
   END IF;
   dbms_sql.close_cursor(cid);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       xla_message('XLA_GLT_GL_INSERT','COUNT','(summary) ' || rows_processed,'','','','',
                    l_log_module,
                    C_LEVEL_STATEMENT);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
          (p_msg      => 'END of procedure GL_INSERT_SUMMARY'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
   END IF;

END gl_insert_summary ;

-- This procedure transfers all the journal lines in detail mode.

-- Data in XLA_JE_LINE_TYPES will be ignored.

PROCEDURE gl_insert_detail( p_request_id             NUMBER,
                            p_source_name            VARCHAR2,
                            p_transfer_run_id        NUMBER,
                            p_period_name            VARCHAR2,
                            p_start_date             DATE,
                            p_end_date               DATE,
                            p_next_period            VARCHAR2,
                            p_reversal_date          DATE,
                            p_average_balances_flag  VARCHAR2,
                            p_gl_transfer_mode       VARCHAR2,
                            p_group_id               NUMBER,
                            p_batch_desc             VARCHAR2,
                            p_je_desc                VARCHAR2,
                            p_je_line_desc           VARCHAR2) IS

   statement_detail           VARCHAR2(10000) ;

   cid                        BINARY_INTEGER;
   rows_processed             NUMBER;

   l_from                     VARCHAR2(1000);
   l_where                    VARCHAR2(1000);
   l_reference3               VARCHAR2(400);

   l_select_actual_flag       VARCHAR2(1000);  -- This is for different entry type A or B
   l_insert_actual_flag       VARCHAR2(1000);  -- This is for different entry type A or B
   l_group_by_actual_flag     VARCHAR2(1000);  -- This is for different entry type A or B

   l_log_module               VARCHAR2(255);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.gl_insert_detail';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure GL_INSERT_DETAIL'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
            (p_msg   => 'l_from = ' || l_from
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

       trace
            (p_msg   => 'l_where = ' || l_where
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);


       trace
            (p_msg   => 'l_reference3 = ' || l_reference3
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF;


   /*----------------------------------------------------------------
   1. 'A' is for Actual -- only for AP and CST -- old source code
   2. 'B' is for Budget and Actual -- new requirement for PSB
     -----------------------------------------------------------------*/
   IF g_entry_type = 'A' THEN
      l_select_actual_flag        := '''A'',';
      l_insert_actual_flag        := '';
      l_group_by_actual_flag      := '';
   ELSE --g_entry_type = 'B'
      l_select_actual_flag        := 'NVL(ael.actual_flag,''A''), aeh.budget_version_id,';
      l_insert_actual_flag        := 'budget_version_id,';
      l_group_by_actual_flag      := ',NVL(ael.actual_flag,''A''), aeh.budget_version_id';
   END IF;

   l_from := ' FROM '|| g_headers_table ||' aeh, '
                     || g_lines_table   ||' ael, '
             	     || ' gl_je_categories jc ';


   l_where := ' WHERE ael.ae_header_id      = aeh.ae_header_id
                  AND  aeh.gl_transfer_run_id = :b_transfer_run_id
                  AND  aeh.accounting_date BETWEEN :b_start_date AND :b_end_date
                  AND  jc.je_category_name    = Decode(Nvl(aeh.cross_currency_flag,''N''),
                                               ''Y'',''Cross Currency'', aeh.ae_category) ';

   IF  g_line_type IS NOT NULL THEN
         l_where := l_where || 'AND ael.ae_line_type_code IN (' || g_line_type ||')';
   END IF;


   IF ( p_gl_transfer_mode = 'D' ) OR ( g_line_type IS NOT NULL ) THEN  -- Detail Transfer
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          xla_message('XLA_GLT_TRANSFER_MODE_D','','','','','','',
                       l_log_module,
                       C_LEVEL_STATEMENT);
       END IF;

      statement_detail := 'INSERT INTO gl_interface(
                    status,                      set_of_books_id,
                    user_je_source_name,         user_je_category_name,
                    accounting_date,             currency_code,
                    date_created,                created_by,
                    actual_flag,
                    '|| l_insert_actual_flag ||'
                    code_combination_id,         stat_amount,
                    entered_dr,                  entered_cr,
                    accounted_dr,                accounted_cr,
                    reference1,                  reference2,
                    reference3,                  reference5,
                    reference7,                  reference8,
                    reference10,
                    reference21,                 reference22,
                    reference23,                 reference24,
                    reference25,                 reference26,
                    reference27,                 reference28,
                    reference29,                 reference30,
                    subledger_doc_sequence_id,
                    subledger_doc_sequence_value,
                    gl_sl_link_table,
                    gl_sl_link_id,               request_id,
                    ussgl_transaction_code,
                    je_header_id,                group_id,
                    period_name
                    )
              SELECT /*+ ORDERED */
                     ''NEW'',                     aeh.set_of_books_id,
                    :b_source_name,               jc.user_je_category_name,
                    aeh.accounting_date,          ael.currency_code,
                    Sysdate,                      :b_user_id,
                    '|| l_select_actual_flag ||'
                    ael.code_combination_id,      stat_amount,
                    entered_dr,                   entered_cr,
                    accounted_dr,                 accounted_cr,
                    :b_batch_name ,               :b_batch_desc,
                    NULL,        :b_je_desc,
                    aeh.gl_reversal_flag,
                    Decode(Nvl(aeh.gl_reversal_flag,''N''),
                         ''Y'',Decode(Nvl(:b_average_balances_flag,''N''),
                                     ''Y'',To_char(:b_reversal_date),:b_next_period),NULL),
                    Nvl(ael.description, :b_je_line_desc),
                      Nvl(ael.reference1,:b_transfer_run_id),
                    ael.reference2,
                    ael.reference3,               ael.reference4,
                    ael.reference5,               ael.reference6,
                    ael.reference7,               ael.reference8,
                    ael.reference9,               ael.reference10,
                    ael.subledger_doc_sequence_id,
                    ael.subledger_doc_sequence_value,
                    :b_link_table,
                    ael.gl_sl_link_id,            :b_request_id,
                    ael.ussgl_transaction_code,
                    :b_transfer_run_id,           :b_group_id,
                    aeh.period_name
                    ' || l_from
                      || l_where;
  END IF;


  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid, statement_detail, dbms_sql.native);

   --Bind Variables
  dbms_sql.bind_variable(cid,':b_user_id', g_user_id);
  dbms_sql.bind_variable(cid,':b_user_id', g_user_id);
  dbms_sql.bind_variable(cid,':b_group_id', p_group_id);
  dbms_sql.bind_variable(cid,':b_request_id', p_request_id);
  dbms_sql.bind_variable(cid,':b_transfer_run_id', p_transfer_run_id);
  dbms_sql.bind_variable(cid,':b_source_name', p_source_name);
  dbms_sql.bind_variable(cid,':b_batch_name', g_batch_name);
  dbms_sql.bind_variable(cid,':b_link_table', g_actual_table_alias);
  dbms_sql.bind_variable(cid,':b_start_date', p_start_date);
  dbms_sql.bind_variable(cid,':b_end_date', p_end_date);
  dbms_sql.bind_variable(cid,':b_batch_desc', p_batch_desc);
  dbms_sql.bind_variable(cid,':b_je_desc', p_je_desc);
  dbms_sql.bind_variable(cid,':b_je_line_desc', p_je_line_desc);
  dbms_sql.bind_variable(cid,':b_next_period', p_next_period);
  dbms_sql.bind_variable(cid,':b_reversal_date', p_reversal_date);
  dbms_sql.bind_variable(cid,':b_average_balances_flag', p_average_balances_flag);

  rows_processed :=  dbms_sql.execute(cid);

  IF rows_processed = 0 THEN
     g_proceed := 'N';
  ELSE
     g_sob_rows_created := g_sob_rows_created + rows_processed;
     g_rec_transfer_flag  := 'Y';  --set the globle flag to 'Y' whenever there are records transferred.
  END IF;
  dbms_sql.close_cursor(cid);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     xla_message('XLA_GLT_GL_INSERT','COUNT','(Detail) ' || rows_processed,'','','','',
                  l_log_module,
                  C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure GL_INSERT_DETAIL'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

 END IF;

END gl_insert_detail;

-- This procedure stamps the gl_sl_linkid for all those accounting
-- entries transferred in Summary. This routine is called after
-- lines have been transferred to GL_INTERFACE.

PROCEDURE update_linkid_summary( p_request_id        NUMBER,
                         p_gl_transfer_mode  VARCHAR2,
                         p_transfer_run_id   NUMBER,
                         p_start_date        DATE,
                         p_end_date          DATE
                         ) IS
  statement          VARCHAR2(2000) ;
  cid                NUMBER;
  rows_processed     NUMBER;
  l_and              VARCHAR2(1000);
  l_budget_version   VARCHAR2(100);
  l_log_module       VARCHAR2(255);
  l_line_type_cond   VARCHAR2(1000);

BEGIN

   l_line_type_cond := '';

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_linkid_summary';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure update_linkid_summary'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


   -- Use accounting date in join condition if records are summarized
   -- by accounting date or use period name if records summarized by period

   IF p_gl_transfer_mode = 'A' THEN
      l_and := ' AND   aeh.accounting_date = gi.accounting_date ';
   ELSIF  p_gl_transfer_mode = 'P' THEN
      l_and := ' AND   aeh.period_name = gi.period_name ';
   END IF;

   /*----------------------------------------------------------------
     1. 'A' is for actual -- only for AP and CST -- old source code
     2. 'B' is for budget and actual -- new requirement for PSB
     -----------------------------------------------------------------*/
   IF g_entry_type = 'A' THEN
      l_budget_version        := '';
   ELSE --g_entry_type = 'B'
      l_budget_version        := 'AND aeh.budget_version_id   = gi.budget_version_id';
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      xla_message('XLA_GLT_UPDATE_SUM_LINKID','','','','','','',
                   l_log_module,
                   C_LEVEL_STATEMENT);
   END IF;

   statement :=
        'UPDATE ' || g_lines_table || ' ael
         SET   program_update_date = Sysdate,
               program_id = :b_program_id,
               request_id = :b_request_id,
               gl_sl_link_id =
                 (
                  SELECT  gi.gl_sl_link_id
                  FROM    gl_interface gi,  ' || g_headers_table || ' aeh
                  WHERE   gi.request_id           =  :b_request_id
                  AND     gi.je_header_id         =  :b_transfer_run_id
                  AND     aeh.gl_transfer_run_id  =  :b_transfer_run_id
                  AND     aeh.accounting_date BETWEEN  :b_start_date AND :b_end_date
                  AND     Decode(Nvl(aeh.cross_currency_flag,''N''), ''Y'', ''Cross Currency'',
                               aeh.ae_category)   = gi.status
                  AND     Nvl(aeh.gl_reversal_flag,''N'') = nvl(gi.reference7,''N'')
                  AND     gi.gl_sl_link_table     =  :b_actual_table_alias '
                  ||      l_and || '
                  AND     aeh.set_of_books_id     = gi.set_of_books_id '
                  ||      l_budget_version ||'
                  AND     ael.code_combination_id = gi.code_combination_id
                  AND     ael.currency_code       = gi.currency_code
                  AND     aeh.ae_header_id        = ael.ae_header_id
                  AND     Decode(Sign(gi.entered_dr), 1,''dr'', -1, ''dr'', 0,
                            Decode(Sign(gi.entered_cr), 1,''cr'', -1, ''cr'',''dr''),''cr'') =
                          Decode(Sign(ael.entered_dr), 1,''dr'', -1, ''dr'', 0,
                            Decode(Sign(ael.entered_cr), 1,''cr'', -1, ''cr'',''dr''),''cr'')
                  )
         WHERE ael.ae_header_id IN ( SELECT ae_header_id
                                     FROM ' || g_headers_table ||
                                   ' WHERE  gl_transfer_run_id = :b_transfer_run_id
                                     AND    accounting_date BETWEEN :b_start_date AND :b_end_date )';

   IF g_line_type IS NOT NULL THEN
      statement := statement || ' AND ael.ae_line_type_code NOT IN ( ' || g_line_type || ' )';
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
            (p_msg   => 'statement = ' || statement
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF;


   cid := dbms_sql.open_cursor;
   dbms_sql.parse(cid, statement, dbms_sql.native);

   dbms_sql.bind_variable(cid,':b_transfer_run_id', p_transfer_run_id);
   dbms_sql.bind_variable(cid,':b_request_id', p_request_id);
   dbms_sql.bind_variable(cid,':b_program_id', g_program_id);
   dbms_sql.bind_variable(cid,':b_start_date', p_start_date);
   dbms_sql.bind_variable(cid,':b_end_date', p_end_date);
   dbms_sql.bind_variable(cid,':b_actual_table_alias', g_actual_table_alias);

   rows_processed :=  dbms_sql.execute(cid);

   dbms_sql.close_cursor(cid);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure update_linkid_summary'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

END update_linkid_summary ;

-- This procedure stamps the gl_sl_linkid for all those accounting
-- entries to be transferred in DETAIL. This routine is called before
-- GL_INSERT_DETAIL is called.

PROCEDURE update_linkid_detail( p_transfer_run_id NUMBER,
                                p_request_id      NUMBER,
                                p_start_date      DATE,
                                p_end_date        DATE) IS
   statement             VARCHAR2(2000) ;
   cid                   NUMBER;
   rows_processed        NUMBER;
   l_log_module         VARCHAR2(255);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_linkid_detail';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure UPDATE_LINKID_DETAIL'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF g_proceed = 'N' THEN
      RETURN;
   END IF;

   statement := 'UPDATE ' || g_lines_table || ' ael ' ||
                '   SET program_update_date    = Sysdate,
                        program_id             = :b_program_id,
                        request_id             = :b_request_id,
                        gl_sl_link_id          = ' || g_lines_sequence_name  || '.NEXTVAL
                  WHERE ae_header_id in
                    ( SELECT ae_header_id
                      FROM   ' || g_headers_table ||
                    ' WHERE  gl_transfer_run_id = :b_transfer_run_id
                      AND    accounting_date BETWEEN :b_start_date AND :b_end_date )' ;

   IF g_line_type IS NOT NULL THEN
      statement := statement || ' AND ael.ae_line_type_code IN ( ' || g_line_type || ' )';
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
            (p_msg   => 'statement = ' || statement
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF;


   cid := dbms_sql.open_cursor;
   dbms_sql.parse(cid, statement, dbms_sql.native);

   dbms_sql.bind_variable(cid,':b_transfer_run_id', p_transfer_run_id);
   dbms_sql.bind_variable(cid,':b_request_id', p_request_id);
   dbms_sql.bind_variable(cid,':b_program_id', g_program_id);
   dbms_sql.bind_variable(cid,':b_start_date', p_start_date);
   dbms_sql.bind_variable(cid,':b_end_date', p_end_date);

   rows_processed :=  dbms_sql.execute(cid);

   IF rows_processed = 0 THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          xla_message('XLA_GLT_NO_ACCT_LINES','','','','','','',
                      l_log_module,
                      C_LEVEL_STATEMENT);
      END IF;

      g_proceed := 'N';
   END IF;
   dbms_sql.close_cursor(cid);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure UPDATE_LINKID_DETAIL'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

END update_linkid_detail;

-- Check input parameters
PROCEDURE check_input_param(p_selection_type          NUMBER,
                            p_start_date              DATE,
                            p_end_date                DATE,
                            p_gl_transfer_mode        VARCHAR2,
                            p_source_doc_id           NUMBER,
                            p_source_document_table   VARCHAR2) IS
    l_log_module         VARCHAR2(255);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.check_input_param';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure CHECK_INPUT_PARAM'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


   -- Check gl_transfer_mode
   IF (p_gl_transfer_mode IS NULL) OR (p_gl_transfer_mode NOT IN ('D','A','P')) THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         xla_message('XLA_GLT_INVALID_MODE', '','','','','','',
                     l_log_module,
                     C_LEVEL_EXCEPTION);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

   IF p_selection_type = 1 THEN
      -- Date validation
      IF p_start_date IS NOT NULL THEN
         IF p_start_date > p_end_date THEN
           IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
              xla_message('XLA_GLT_INVALID_DATE_RANGE','','','','','','',
                          l_log_module,
                          C_LEVEL_EXCEPTION);
           END IF;
          APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;
      END IF;
      -- Check document parameter
      IF (p_source_doc_id IS NOT NULL) OR (p_source_document_table IS NOT NULL) THEN
           IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
               xla_message('','Source document Id and Source document table should be NULL for batch Transfer','','','','','',
                           l_log_module,
                           C_LEVEL_EXCEPTION);
           END IF;
          APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
   ELSIF p_selection_type = 2 THEN
      IF (p_source_doc_id IS NULL) OR (p_source_document_table IS NULL) THEN
           IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
               xla_message('','Source document Id and Source document table should be NULL for document Transfer','','','','','',
                           l_log_module,
                           C_LEVEL_EXCEPTION);
           END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
          xla_message('XLA_GLT_INVALID_SELECTION_TYPE','','','','','','',
                     l_log_module,
                     C_LEVEL_EXCEPTION);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure CHECK_INPUT_PARAM'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

END check_input_param;


/***********************************************************************************
 * FUNCTION
 *        get_funds_check_flag
 *
 * DESCRIPTION
 *        get_funds_check_flag will return TRUE if
 *                1.encumbrance accounting is being used
 *                2.Bugetary control is enabled for this set_of_books_id
 *                3.USSGL profile option is Yes --not available currently
 * SCOPE - PRIVATE
 *
 * ARGUMENTS:
 *        IN:        p_encumbrance_flag        -- flag to check if encumbrance accounting
 *                                           is being used
 *                p_user_source_name        -- it is used to get budget accounting flag
 *                p_group_id                -- it is used to get budget accounting flag
 *                p_set_of_books_id        -- it is used to get budget accounting flag
 *
 **********************************************************************************/

FUNCTION get_funds_check_flag(p_encumbrance_flag        VARCHAR2,
                              p_user_source_name        VARCHAR2,
                              p_group_id                NUMBER,
                              p_set_of_books_id         NUMBER) RETURN BOOLEAN IS
l_log_module            VARCHAR2(255);
l_budget_entries        NUMBER;
l_budget_control_flag   VARCHAR2(1);
BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_funds_check_flag';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GET_FUNDS_CHECK_FLAG'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

        -- check if there are budget entries processed
        SELECT COUNT(*)
        INTO   l_budget_entries
        FROM   dual
        WHERE EXISTS ( SELECT 'x'
                       FROM   gl_interface
                       WHERE  user_je_source_name = p_user_source_name
                       AND    group_id            = p_group_id
                       AND    set_of_books_id     = p_set_of_books_id );


        -- check if budget control is enabled
        SELECT enable_budgetary_control_flag
        INTO   l_budget_control_flag
        FROM   gl_sets_of_books
        WHERE  set_of_books_id = p_set_of_books_id;


        IF ( Nvl(p_encumbrance_flag,'N') = 'Y' AND g_enc_proceed = 'Y'  ) OR
           ( l_budget_control_flag = 'Y'       AND l_budget_entries > 0 )        THEN
                RETURN (TRUE);
        ELSE
                RETURN (FALSE);
        END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of function GET_FUNDS_CHECK_FLAG'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
   IF g_log_level <= FND_LOG.LEVEL_UNEXPECTED THEN
         fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                        l_log_module,
                        'Unexpected Error While Executing  ' || l_log_module);
   END IF;
END get_funds_check_flag;

-- This procedure is used to derive line_type_code that need to be transferred in DETAIL.

-- Also sets the flag whether a detail transfer is required.

PROCEDURE derive_line_types IS
  l_log_module            VARCHAR2(255);
BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.derive_line_types';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure derive_line_types'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   FOR select_line_type_rec IN ( SELECT Line_Type_Code
                                 FROM   xla_je_line_types
                                 WHERE  application_id = g_application_id
                                   AND  summary_flag = 'D' )
   LOOP
      IF g_line_type IS NULL THEN
         g_line_type :=  '''' || select_line_type_rec.Line_Type_Code || ''',';
      ELSE
         g_line_type := g_line_type || '''' || select_line_type_rec.Line_Type_Code || ''',';
      END IF;
   END LOOP;

   g_line_type := RTRIM(g_line_type,',');

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      xla_message('','Line types to be transferred in detail: ' || g_line_type,'','','','','',l_log_module,C_LEVEL_STATEMENT );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure derive_line_types'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
   IF g_log_level <= FND_LOG.LEVEL_UNEXPECTED THEN
         fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                        l_log_module,
                        'Unexpected Error While Executing  ' || l_log_module);
   END IF;
END derive_line_types;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    XLA_GL_TRANSFER                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Main procedure for the transfer. All the sub procedures are called from  |
 |  from this procedure.                                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |     p_application_id  Application ID of the calling application.          |
 |     p_program_name    Unique program name for the calling application.    |
 |     p_selection_type  Transfer Type 1-Batch , 2- Doc. Level Transfer      |
 |     p_fc_force_flag   Force flag for the funds checker.                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE xla_gl_transfer(p_application_id                   NUMBER,
                          p_user_id                          NUMBER,
                          p_org_id                           NUMBER,
                          p_request_id                       NUMBER,
                          p_program_name                     VARCHAR2,
                          p_selection_type                   NUMBER DEFAULT 1,
                          p_sob_list                         t_sob_list,
                          p_batch_name                       VARCHAR2,
                          p_source_doc_id                    NUMBER   DEFAULT NULL,
                          p_source_document_table            VARCHAR2 DEFAULT NULL,
                          p_start_date                       DATE,
                          p_end_date                         DATE,
                          p_journal_category                 t_ae_category,
                          p_validate_account                 VARCHAR2,
                          p_gl_transfer_mode                 VARCHAR2,
                          p_submit_journal_import            VARCHAR2,
                          p_summary_journal_entry            VARCHAR2,
                          p_process_days                     NUMBER ,
                          p_batch_desc                       VARCHAR2 DEFAULT NULL,
                          p_je_desc                          VARCHAR2 DEFAULT NULL,
                          p_je_line_desc                     VARCHAR2 DEFAULT NULL,
                          p_fc_force_flag                    BOOLEAN  DEFAULT TRUE,
                          p_debug_flag                       VARCHAR2
                 ) IS
  l_start_date             DATE;
  l_end_date               DATE;
  l_period_start_date      DATE;
  l_period_end_date        DATE;
  l_open_start_date        DATE;
  l_open_end_date          DATE;
  l_min_start_date         DATE;
  l_max_end_date           DATE;
  l_next_period            gl_period_statuses.period_name%TYPE;
  l_reversal_date          DATE; -- Bug #974204
  l_application_id         NUMBER(15);
  l_period_status          VARCHAR2(1);
  l_period_name            gl_period_statuses.period_name%TYPE;
  l_transfer_run_id        NUMBER;
  l_set_of_books_id        NUMBER;
  l_batch_run_id           NUMBER;
  l_gl_installed_flag      VARCHAR2(10);
  l_group_id               NUMBER;
  l_interface_run_id       NUMBER;
  l_encumbrance_flag       VARCHAR2(1);
  l_source_name            gl_je_sources.je_source_name%TYPE;
  l_user_source_name       gl_je_sources.user_je_source_name%TYPE;
  industry                 VARCHAR2(10);
  l_debug_info             VARCHAR2(2000);
  l_submittedreqid         NUMBER;
  l_packet_id              NUMBER;
  l_request_id             NUMBER;
  l_sob_name               gl_sets_of_books.name%TYPE;
  l_sob_type               gl_sets_of_books.mrc_sob_type_code%TYPE;
  l_coa_id                 NUMBER;
  l_acct_validation_flag   VARCHAR2(1);
  l_pre_commit_api         xla_gl_transfer_programs.pre_commit_api_name%TYPE;
  l_budget_entries         NUMBER;
  l_fc_force_flag          VARCHAR2(10);

  l_log_module             VARCHAR2(255);


  -- Get Period Information
  -- Added the entry type to check if the entry is an actual/budget entry
  CURSOR c_getPeriods(c_sob_id     NUMBER,
                      c_start_date DATE,
                      c_end_date   DATE) IS
     SELECT gp1.period_name, gp1.start_date, gp1.end_date,
            gp2.period_name, gp2.start_date
       FROM gl_period_statuses gp1,
            gl_period_statuses gp2
      WHERE gp1.application_id = 101
        AND gp1.set_of_books_id = c_sob_id
        AND gp1.end_date >= Nvl(c_start_date,gp1.end_date-1)
        AND gp1.start_date <= c_end_date
        AND gp1.closing_status = DECODE( g_entry_type,'A', DECODE( gp1.closing_status, 'O', 'O', 'F', 'F','Z'),
     	                                                'B', gp1.closing_status )
        AND nvl(gp1.adjustment_period_flag,'N') = 'N'
        AND gp2.application_id(+) = 101
        AND gp2.set_of_books_id(+) = c_sob_id
        AND gp2.start_date(+) = gp1.end_date+1
        AND nvl(gp2.adjustment_period_flag,'N') = 'N'
   ORDER BY gp1.start_date;
BEGIN

   g_proceed           := 'Y';
   g_rec_transfer_flag := 'N';
   g_enc_proceed       := 'N';

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.xla_gl_transfer';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure XLA_GL_TRANSFER'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      xla_message('' , 'p_application_id        = ' || p_application_id,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_user_id               = ' || p_user_id,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_org_id                = ' || p_org_id,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_request_id            = ' || p_request_id,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_program_name          = ' || p_program_name,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_selection_type        = ' || p_selection_type,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_batch_name            = ' || p_batch_name,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_source_doc_id         = ' || p_source_doc_id,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_source_document_table = ' || p_source_document_table,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_start_date            = ' || To_char(p_start_date,'MM/DD/YYYY'),'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_end_date              = ' || To_char(p_end_date,'MM/DD/YYYY'),'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_validate_account      = ' || p_validate_account,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_gl_transfer_mode      = ' || p_gl_transfer_mode,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_submit_journal_import = ' || NVL(p_submit_journal_import,'Y'),'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_summary_journal_entry = ' || NVL(p_summary_journal_entry,'N'),'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_process_days          = ' || p_process_days,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_batch_desc            = ' || p_batch_desc,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_je_desc               = ' || p_je_desc,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_je_line_desc          = ' || p_je_line_desc,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_fc_force_flag         = ' || l_fc_force_flag,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

      xla_message('' , 'p_debug_flag            = ' || p_debug_flag,'','','','','',
                     l_log_module,
                     C_LEVEL_PROCEDURE);

   END IF;

   IF p_fc_force_flag THEN
      l_fc_force_flag := 'TRUE';
   ELSE
      l_fc_force_flag := 'FALSE';
   END IF;
   -- Initialize Variables

   g_application_id := p_application_id;
   g_program_id   := fnd_global.conc_program_id;
   g_user_id      := p_user_id;
   g_program_name := p_program_name;

   -- Check input parameters
   check_input_param(p_selection_type,
                     p_start_date,
                     p_end_date,
                     p_gl_transfer_mode,
                     p_source_doc_id,
                     p_source_document_table
                     );

   -- Get the user source name

   SELECT je_source_name, account_validation_flag, period_status_table_name,
          pre_commit_api_name, application_id, NVL(entry_type,'A')
     INTO l_source_name, l_acct_validation_flag, g_periods_table,
          l_pre_commit_api, l_application_id, g_entry_type
     FROM xla_gl_transfer_programs
     WHERE program_name = p_program_name;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      xla_message('' , 'SOB list count                   = ' || p_sob_list.count,'','','','','',l_log_module,
                  C_LEVEL_STATEMENT);
   END IF;
   FOR i IN p_sob_list.first..p_sob_list.last LOOP
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           xla_message('' , 'SOB(' || i || ').sob_id          = ' || p_sob_list(i).sob_id,'','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);

           xla_message('' , 'SOB(' || i || ').sob_name        = ' || p_sob_list(i).sob_name,'','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);

           xla_message('' , 'SOB(' || i || ').sob_curr_code   = ' || p_sob_list(i).sob_curr_code,'','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);

           xla_message('' , 'SOB(' || i || ').ave_bal_flag    = ' || p_sob_list(i).average_balances_flag,'','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);

           xla_message('' , 'SOB(' || i || ').legal_entity_id = ' || p_sob_list(i).legal_entity_id,'','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);

           xla_message('' , 'SOB(' || i || ').cost_group_id   = ' || p_sob_list(i).cost_group_id,'','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);

           xla_message('' , 'SOB(' || i || ').cost_type_id    = ' || p_sob_list(i).cost_type_id,'','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);

       END IF;

   END LOOP;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      xla_message('' , 'p_journal_category count         = ' || p_journal_category.count,'','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);

   END IF;
   FOR i IN p_journal_category.FIRST..p_journal_category.LAST LOOP
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          xla_message('' , 'journal_category(' || i || ')    = ' || p_journal_category(i),'','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);
       END IF;
   END LOOP;
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       xla_message('' , '------------------------------------------','','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);
   END IF;

   -- Legal Entity, Cost Group, Cost Type is one is not null then
   -- all three must be not null.

   FOR i IN p_sob_list.first..p_sob_list.last LOOP
      IF p_sob_list(i).legal_entity_id IS NOT NULL THEN
         IF p_sob_list(i).cost_group_id IS NULL OR p_sob_list(i).cost_type_id IS NULL THEN
            IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
               xla_message('XLA_GLT_INVALID_CST_DATA','','','','','','',
                           l_log_module,
                           C_LEVEL_EXCEPTION);
            END IF;
            APP_EXCEPTION.RAISE_EXCEPTION;
         END  IF;
       ELSIF p_sob_list(i).cost_group_id IS NOT NULL THEN
         IF p_sob_list(i).legal_entity_id IS NULL OR p_sob_list(i).cost_type_id IS NULL THEN
            IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                xla_message('XLA_GLT_INVALID_CST_DATA','','','','','','',
                            l_log_module,
                            C_LEVEL_EXCEPTION);
            END IF;
            APP_EXCEPTION.RAISE_EXCEPTION;
         END  IF;
       ELSIF p_sob_list(i).cost_type_id IS NOT NULL THEN
         IF p_sob_list(i).legal_entity_id IS NULL OR p_sob_list(i).cost_group_id IS NULL THEN
            IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
               xla_message('XLA_GLT_INVALID_CST_DATA','','','','','','',
                           l_log_module,
                           C_LEVEL_EXCEPTION);
            END IF;
            APP_EXCEPTION.RAISE_EXCEPTION;
         END  IF;
      END IF;
   END LOOP;

   -- Check if GL is installed.
   IF (FND_INSTALLATION.GET(101, 101, l_gl_installed_flag, industry)) THEN
      IF Nvl(l_gl_installed_flag,'N') = 'I' THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN

             xla_message('XLA_GLT_GL_INSTALLED','','','','',
                         '','',                    l_log_module,
                    C_LEVEL_STATEMENT);

         END IF;
       ELSE
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN

            xla_message('XLA_GLT_GL_NOT_INSTALLED','','','',
                         '','','',                    l_log_module,
                    C_LEVEL_STATEMENT);

        END IF;
      END IF;
   END IF;

   -- Get the user source name for an application.
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       xla_message('XLA_GLT_GET_SOURCE_NAME','','','',
                   '','','',                    l_log_module,
                    C_LEVEL_STATEMENT);
   END IF;

   SELECT user_je_source_name
   INTO   l_user_source_name
   FROM   gl_je_sources js
   WHERE  je_source_name = l_source_name;

   -- Validate periods if GL is installed.
   -- Bug2543724. Skipping Accounting Period validation for Budget journals
   IF Nvl(l_gl_installed_flag,'N') = 'I' THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          xla_message('XLA_GLT_VALIDATE_PERIODS','','','','','',
                  '',                    l_log_module,
                    C_LEVEL_STATEMENT);
      END IF;

      IF p_selection_type = 1 THEN -- this is only for SRS, Doc Transfer will call it later.
         IF(g_entry_type = 'A') THEN
	    validate_periods(p_selection_type,
                               p_sob_list,
                               p_program_name,
                               p_start_date,
                               p_end_date
                            );

         END IF;

      END IF;
   END IF;

   -- If the transfer is submitted for more than one sobs then we will
   -- process one SOB at a time.

   -- Loop to process each set of books.
   FOR i IN p_sob_list.FIRST..p_sob_list.LAST LOOP
      l_set_of_books_id    := p_sob_list(i).sob_id;
      l_sob_name           := p_sob_list(i).sob_name;
      g_base_currency_code := p_sob_list(i).sob_curr_code;
      l_encumbrance_flag   := p_sob_list(i).encum_flag;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          xla_message('XLA_GLT_PROCESS_SOB','SOB_NAME', l_sob_name,'','','','',                    l_log_module,
                    C_LEVEL_STATEMENT);
      END IF;

      IF l_set_of_books_id IS NOT NULL THEN
        SELECT chart_of_accounts_id
        INTO   l_coa_id
        FROM   gl_sets_of_books
        WHERE  set_of_books_id = l_set_of_books_id;
      END IF;

      -- Get Transfer Run Id
      SELECT xla_gl_transfer_runid_s.NEXTVAL
        INTO l_transfer_run_id
        FROM dual;

      -- Set the batch Name

      --Bug3196153. p_batch_name exceeds the limit of varchar2(30)
      --during translation in some languages.
      g_batch_name := SUBSTRB(p_batch_name || ' ' || l_transfer_run_id,1,30);

      -- If GL is installed populate group id and inter_run_id;
      IF Nvl(l_gl_installed_flag,'N') = 'I' THEN
         SELECT gl_interface_control_s.NEXTVAL, gl_journal_import_s.NEXTVAL
           INTO l_group_id, l_interface_run_id
           FROM dual;
      END IF;

      ---------------------------------------------------------------------------
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

          xla_message('' , 'Batch_Name       = ' || g_batch_name,'','','','','',
                      l_log_module,
                      C_LEVEL_STATEMENT);

          xla_message('' , 'Transfer_run_id  = ' || l_transfer_run_id,'','','','','',
                      l_log_module,
                      C_LEVEL_STATEMENT);

         xla_message('' , 'Group_id         = ' || l_group_id,'','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);

         xla_message('' , 'Interface_run_id = ' || l_interface_run_id,'','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);

      END IF;

      ---------------------------------------------------------------------------

      ---------------------------------------------------------------------
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

          xla_message('XLA_GLT_INSERT_XTB','','','','','','',
                     l_log_module,
                     C_LEVEL_STATEMENT);

      END IF;
      ---------------------------------------------------------------------
      INSERT INTO xla_gl_transfer_batches_all
        ( gl_transfer_run_id,
          request_id ,
          application_id ,
          user_id ,
          selection_type ,
          set_of_books_id  ,
          batch_name,
          source_id ,
          source_table ,
          transfer_from_date,
          transfer_to_date,
          ae_category  ,
          gl_transfer_mode ,
          submit_journal_import ,
          summary_journal_entry ,
          process_days ,
          gl_transfer_date,
          group_id,
          interface_run_id,
          org_id,
          legal_entity_id,
          cost_group_id,
          cost_type_id,
          transfer_status
          )
        VALUES
        (   l_transfer_run_id,
            p_request_id,
            p_application_id,
            p_user_id,
            p_selection_type ,
            p_sob_list(i).sob_id  ,
            g_batch_name ,
            p_source_doc_id   ,
            p_source_document_table ,
            p_start_date ,
            p_end_date  ,
            p_journal_category(1),
            p_gl_transfer_mode ,
            NVL(p_submit_journal_import,'Y') ,
            NVL(p_summary_journal_entry,'N') ,
            p_process_days ,
            Sysdate,
            l_group_id,
            l_interface_run_id,
            p_org_id,
            p_sob_list(i).legal_entity_id,
            p_sob_list(i).cost_group_id,
            p_sob_list(i).cost_type_id,
            'P'
            );

      g_rec_transfer_flag := 'N';  --reset the global flag for each sob

      IF p_selection_type = 1 THEN
         -- If processing more than one period then break the date range into
         -- multiple peirods.
         OPEN c_getPeriods(p_sob_list(i).sob_id,
                           p_start_date,
                           p_end_date
                           );
         LOOP -- Proecss Periods
            FETCH c_getPeriods
            INTO  l_period_name, l_period_start_date,l_period_end_date,
                  l_next_period, l_reversal_date;
            EXIT WHEN c_getPeriods%NOTFOUND;

            -- Bug-4014659 deleted the if loop which checks for the NULL starting date
            -- because the loop makes the starting date of the latest open period as the
            -- start date of the GL transfer for reporting SOB which gives some inconsistency
            -- while posting.
               l_start_date := Nvl(p_start_date, l_period_start_date);

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               xla_message('XLA_GLT_GET_PERIOD_INFO','','','','','','', l_log_module,
                     C_LEVEL_STATEMENT);
            END IF;


            g_periods_cnt := g_periods_cnt + 1;
            g_control_info(g_periods_cnt).sob_id := l_set_of_books_id;
            g_control_info(g_periods_cnt).period_name := l_period_name;
            g_control_info(g_periods_cnt).rec_transferred := 0;
            g_control_info(g_periods_cnt).cnt_transfer_errors := 0;
            g_control_info(g_periods_cnt).cnt_acct_errors := 0;

            <<process_commit_cycle>>
            LOOP
               -- Set the date range. Ignore process days specified by the user
               -- when summarized by period or encumbrance is used.

               IF (NVL(p_process_days,0) = 0 OR
                   Nvl(l_encumbrance_flag,'N') = 'Y' OR
                   p_gl_transfer_mode = 'P') THEN
                  -- If period end date > transfer end date then set
                  -- the end date to transfer end date.
                  l_end_date := Least(p_end_date, l_period_end_date);
                ELSE
                  l_end_date := Least(l_start_date+(p_process_days-1),
                                      Least(l_period_end_date,p_end_date));
               END IF;

               --temporarily fixed for the bug2139573 (add 23:59:59)
               l_end_date := trunc(l_end_date) + 86399/86400;

               -- Reset proceed to 'Y' for each process_commit_cycle
               g_proceed := 'Y';

               OPEN c_get_program_info(p_program_name);
               <<multiple_entities>>
               LOOP -- to process multiple accounting entities
                  FETCH c_get_program_info
                  INTO g_events_table, g_headers_table, g_lines_table,
                       g_encumbrance_table, g_lines_sequence_name,
                       g_enc_sequence_name, g_actual_table_alias, g_enc_table_alias;
                  EXIT WHEN c_get_program_info%NOTFOUND;

                  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     xla_message('XLA_GLT_DATE_RANGE','START_DATE',l_start_date,
                              'END_DATE',l_end_date,'','',l_log_module,
                                 C_LEVEL_STATEMENT);
                  END IF;


                  select_acct_headers( p_selection_type,
                                       l_set_of_books_id,
                                       p_source_doc_id,
                                       p_source_document_table,
                                       l_transfer_run_id,
                                       p_request_id,
                                       p_journal_category,
                                       l_start_date,
                                       l_end_date,
                                       p_sob_list(i).legal_entity_id,
                                       p_sob_list(i).cost_group_id,
                                       p_sob_list(i).cost_type_id,
                                       p_validate_account);
                  -- Validate account on accounting entry lines if necessary
                  IF Nvl(p_validate_account, Nvl(l_acct_validation_flag,'N')) = 'Y'
                    AND g_proceed = 'Y' THEN
                    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                        xla_message('XLA_GLT_CALL_VALIDATE_LINES','','','','','',
                                 '',l_log_module,
                                 C_LEVEL_STATEMENT);
                     END IF;

                     validate_acct_lines( p_selection_type,
                                          l_set_of_books_id,
                                          l_coa_id,
                                          l_transfer_run_id,
                                          l_start_date,
                                          l_end_date);

                     -- Update headers for the lines that failed accounting
                     -- validation.  Do not call routine if there are no
                     -- accounting entry lines to process.
                     IF g_proceed = 'Y' THEN
                       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('XLA_GLT_CALL_VALIDATE_LINES','','','','','',
                                       '',l_log_module,
                                       C_LEVEL_STATEMENT);
                       END IF;
                        validate_acct_headers( p_selection_type,
                                               l_set_of_books_id,
                                               l_transfer_run_id,
                                               l_start_date,
                                               l_end_date);
                     END IF;
                  END IF;
                  -- Call following procedures only if there are records to
                  -- process in this period
                  IF g_proceed  = 'Y' THEN
                     IF p_gl_transfer_mode = 'D' THEN
                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('XLA_GLT_CALL_UPDATE_LINKID','','','','','',
                                       '',l_log_module,
                                       C_LEVEL_STATEMENT);
                        END IF;

                        update_linkid_detail( l_transfer_run_id,
                                              p_request_id,
                                              l_start_date,
                                              l_end_date);

                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('XLA_GLT_CREATE_JOURNAL_ENTRIES','','','','','','',
                                       l_log_module,
                                       C_LEVEL_STATEMENT);
                        END IF;

                        gl_insert_detail( p_request_id,
                                          l_user_source_name,
                                          l_transfer_run_id,
                                          l_period_name,
                                          l_start_date,
                                          l_end_date,
                                          l_next_period,
                                          l_reversal_date,
                                          p_sob_list(i).average_balances_flag,
                                          p_gl_transfer_mode,
                                          l_group_id,
                                          p_batch_desc,
                                          p_je_desc,
                                          p_je_line_desc);

                     ELSE  -- Summarize By Accounting Date

                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('','Calling derive line types ','','','','','',l_log_module,C_LEVEL_STATEMENT );
                        END IF;

                        IF g_line_type IS NULL THEN
                           derive_line_types;
                        END IF;

                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('XLA_GLT_CREATE_JOURNAL_ENTRIES','','','','','','',
                                       l_log_module,
                                       C_LEVEL_STATEMENT);
                        END IF;

                        gl_insert_summary( p_request_id,
                                           l_user_source_name,
                                           l_transfer_run_id,
                                           l_period_name,
                                           l_start_date,
                                           l_end_date,
                                           l_next_period,
                                           l_reversal_date,
                                           p_sob_list(i).average_balances_flag,
                                           p_gl_transfer_mode,
                                           l_group_id,
                                           p_batch_desc,
                                           p_je_desc,
                                           p_je_line_desc);

                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('XLA_GLT_CALL_UPDATE_LINKID','','','','','',
                                       '',l_log_module,
                                       C_LEVEL_STATEMENT);
                        END IF;

                        update_linkid_summary( p_request_id,
                                               p_gl_transfer_mode,
                                               l_transfer_run_id,
                                               l_start_date,
                                               l_end_date);

                        IF g_line_type IS NOT NULL  THEN

                           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                               xla_message('XLA_GLT_CALL_UPDATE_LINKID','','','','','',
                                           '',l_log_module,
                                           C_LEVEL_STATEMENT);
                           END IF;

                           update_linkid_detail( l_transfer_run_id,
                                                 p_request_id,
                                                 l_start_date,
                                                 l_end_date);

                           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                               xla_message('XLA_GLT_CREATE_JOURNAL_ENTRIES','','','','','','',
                                           l_log_module,
                                           C_LEVEL_STATEMENT);
                           END IF;

                           gl_insert_detail( p_request_id,
                                             l_user_source_name,
                                             l_transfer_run_id,
                                             l_period_name,
                                             l_start_date,
                                             l_end_date,
                                             l_next_period,
                                             l_reversal_date,
                                             p_sob_list(i).average_balances_flag,
                                             p_gl_transfer_mode,
                                             l_group_id,
                                             p_batch_desc,
                                             p_je_desc,
                                             p_je_line_desc);

                        END IF;

                     END IF;

                     -- Transfer encumbrance reversals to gl_interface if
                     -- encumbrance is used.
                     IF (Nvl(l_encumbrance_flag,'N') = 'Y') THEN
                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('XLA_GLT_CALL_ENCUM_ROUTINE','','','','','',
                                       '',l_log_module,
                                       C_LEVEL_STATEMENT);
                        END IF;

                        transfer_enc_lines( p_application_id,
                                            l_set_of_books_id,
                                            l_transfer_run_id,
                                            l_start_date,
                                            l_end_date,
                                            l_next_period,
                                            l_reversal_date,
                                            p_sob_list(i).average_balances_flag,
                                            l_user_source_name,
                                            l_group_id,
                                            l_request_id,
                                            p_batch_desc,
                                            p_je_desc,
                                            p_je_line_desc);
                     END IF;
                     -- Call Globalization Routine

                     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                         xla_message('XLA_GLT_CALLING_JG_PKG','','','','','','',l_log_module,
                                      C_LEVEL_STATEMENT);
                     END IF;


                    JG_XLA_GL_TRANSFER_PKG.jg_xla_gl_transfer
                      ( p_application_id,
                        p_user_id,
                        p_org_id,
                        p_request_id,
                        l_transfer_run_id,
                        p_program_name,
                        p_selection_type,
                        p_batch_name,
                        l_start_date,
                        l_end_date,
                        p_gl_transfer_mode,
                        p_process_days,
                        p_debug_flag
                        );

                 END IF;
              END LOOP multiple_entities; -- Multiple entities loop
              CLOSE c_get_program_info;

              IF p_process_days IS NOT NULL THEN
                 -- Save changes if commit cycle is needed
                 IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                    xla_message('XLA_GLT_SAVE_WORK','','','','','','',l_log_module,
                                      C_LEVEL_STATEMENT);
                 END IF;
                 COMMIT;
              END IF;

              IF ( p_selection_type = 1 AND
                   l_end_date <  Least(p_end_date,l_period_end_date)) THEN
                 l_start_date := l_end_date+1;
              ELSE
                 EXIT;
              END IF;
           END LOOP process_commit_cycle ;
        END LOOP; --process_periods

        -- Log an error if there are no open periods
        IF c_getPeriods%ROWCOUNT = 0 THEN
           CLOSE c_getPeriods;
           IF (C_LEVEL_EXCEPTION >= g_log_level) THEN

              xla_message('XLA_GLT_NO_OPEN_PERIODS','SOB_NAME',l_sob_name,
                       '','','','', l_log_module,C_LEVEL_EXCEPTION);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
        CLOSE c_getPeriods;
      ELSE
        -- Document Specific Transfer
        OPEN c_get_program_info(p_program_name);
        LOOP
           FETCH c_get_program_info
           INTO  g_events_table, g_headers_table, g_lines_table,
                 g_encumbrance_table, g_lines_sequence_name,
                 g_enc_sequence_name, g_actual_table_alias, g_enc_table_alias;
           EXIT WHEN c_get_program_info%NOTFOUND;

           -- Select Accounting Entries.
           select_acct_headers( p_selection_type,
                                l_set_of_books_id,
                                p_source_doc_id,
                                p_source_document_table,
                                l_transfer_run_id,
                                p_request_id,
                                p_journal_category,
                                l_start_date,
                                l_end_date,
                                p_sob_list(i).legal_entity_id,
                                p_sob_list(i).cost_group_id,
                                p_sob_list(i).cost_type_id,
                                p_validate_account
                                );
           -- Get the Date range to see if the entries are in
           -- multiple accounting periods
           IF g_proceed = 'Y' THEN
              get_date_range(l_transfer_run_id,
                             l_start_date,
                             l_end_date
                             );

                  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     xla_message('XLA_GLT_DATE_RANGE','START_DATE',l_start_date,
                              'END_DATE',l_end_date,'','',l_log_module,
                                 C_LEVEL_STATEMENT);
                  END IF;
              -- Validate Period/ Year
              -- Bug2543724. Skipping Accounting Period validation for Budget journals

              IF Nvl(l_gl_installed_flag,'N') = 'I' THEN

                  IF(g_entry_type = 'A') THEN
                     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                        xla_message('','Calling validate periods ','','','','','',l_log_module,C_LEVEL_STATEMENT );
                     END IF;
                     validate_periods(p_selection_type,
                                     p_sob_list,
                                     p_program_name,
                                     l_start_date,
                                     l_end_date
                                    );
	            END IF;

              END IF;

              -- Process entries by periods
              OPEN c_getPeriods(p_sob_list(i).sob_id,
                                l_start_date,
                                l_end_date
                                );
              LOOP -- Proecss Periods
                 FETCH c_getPeriods
                 INTO  l_period_name, l_period_start_date,l_period_end_date,
                       l_next_period, l_reversal_date;
                 EXIT WHEN c_getPeriods%NOTFOUND;

                 --temporarily fixed for the bug2139573 (add 23:59:59)
                 l_period_end_date := trunc(l_period_end_date) + 86399/86400;

                 -- Reset proceed to 'Y' for each period
                 g_proceed := 'Y';

                 g_periods_cnt := g_periods_cnt + 1;
                 g_control_info(g_periods_cnt).sob_id := l_set_of_books_id;
                 g_control_info(g_periods_cnt).period_name := l_period_name;
                 g_control_info(g_periods_cnt).rec_transferred := 0;
                 g_control_info(g_periods_cnt).cnt_transfer_errors := 0;
                 g_control_info(g_periods_cnt).cnt_acct_errors := 0;

                 IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                    xla_message('','~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~','','','','','',l_log_module,C_LEVEL_STATEMENT );
                    xla_message('XLA_GLT_DATE_RANGE','START_DATE',l_period_start_date,
                                'END_DATE',l_period_end_date,'','',l_log_module,C_LEVEL_STATEMENT );
                            END IF;

                 -- Validate account on accounting entry lines if necessary
                 IF Nvl(p_validate_account, Nvl(l_acct_validation_flag,'N')) = 'Y'
                   AND g_proceed = 'Y' THEN
                    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                        xla_message('XLA_GLT_CALL_VALIDATE_LINES','','','','','',
                                 '',l_log_module,
                                 C_LEVEL_STATEMENT);
                     END IF;
                    validate_acct_lines( p_selection_type,
                                         l_set_of_books_id,
                                         l_coa_id,
                                         l_transfer_run_id,
                                         l_period_start_date,
                                         l_period_end_date);

                    -- Update headers for the lines that failed accounting
                    -- validation.  Do not call routine if there are no
                    -- accounting entry lines to process.
                    IF g_proceed = 'Y' THEN
                    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                        xla_message('XLA_GLT_CALL_VALIDATE_LINES','','','','','',
                                 '',l_log_module,
                                 C_LEVEL_STATEMENT);
                     END IF;
                       validate_acct_headers( p_selection_type,
                                              l_set_of_books_id,
                                              l_transfer_run_id,
                                              l_period_start_date,
                                              l_period_end_date);

                    END IF;
                 END IF;
                 -- Call following procedures only if there are records to
                 -- process in this period
                 IF g_proceed  = 'Y' THEN
                    IF p_gl_transfer_mode = 'D' THEN
                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('XLA_GLT_CALL_UPDATE_LINKID','','','','','',
                                       '',l_log_module,
                                       C_LEVEL_STATEMENT);
                        END IF;
                        update_linkid_detail( l_transfer_run_id,
                                              p_request_id,
                                              l_period_start_date,
                                              l_period_end_date);

                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('XLA_GLT_CREATE_JOURNAL_ENTRIES','','','','','','',
                                       l_log_module,
                                       C_LEVEL_STATEMENT);
                        END IF;

                        gl_insert_detail( p_request_id,
                                          l_user_source_name,
                                          l_transfer_run_id,
                                          l_period_name,
                                          l_period_start_date,
                                          l_period_end_date,
                                          l_next_period,
                                          l_reversal_date,
                                          p_sob_list(i).average_balances_flag,
                                          p_gl_transfer_mode,
                                          l_group_id,
                                          p_batch_desc,
                                          p_je_desc,
                                          p_je_line_desc);

                    ELSE  -- Summarize By Accounting Date

                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('','Calling derive line types ','','','','','',l_log_module,C_LEVEL_STATEMENT );
                        END IF;

                        IF g_line_type IS NULL THEN
                           derive_line_types;
                        END IF;

                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('XLA_GLT_CREATE_JOURNAL_ENTRIES','','','','','','',
                                       l_log_module,
                                       C_LEVEL_STATEMENT);
                        END IF;

                        gl_insert_summary( p_request_id,
                                           l_user_source_name,
                                           l_transfer_run_id,
                                           l_period_name,
                                           l_period_start_date,
                                           l_period_end_date,
                                           l_next_period,
                                           l_reversal_date,
                                           p_sob_list(i).average_balances_flag,
                                           p_gl_transfer_mode,
                                           l_group_id,
                                           p_batch_desc,
                                           p_je_desc,
                                           p_je_line_desc);

                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('XLA_GLT_CALL_UPDATE_LINKID','','','','','',
                                       '',l_log_module,
                                       C_LEVEL_STATEMENT);
                        END IF;

                        update_linkid_summary( p_request_id,
                                               p_gl_transfer_mode,
                                               l_transfer_run_id,
                                               l_period_start_date,
                                               l_period_end_date);


                       IF g_line_type IS NOT NULL THEN

                          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                              xla_message('XLA_GLT_CALL_UPDATE_LINKID','','','','','',
                                          '',l_log_module,
                                          C_LEVEL_STATEMENT);
                          END IF;

                          update_linkid_detail( l_transfer_run_id,
                                                p_request_id,
                                                l_start_date,
                                                l_end_date);

                          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                              xla_message('XLA_GLT_CREATE_JOURNAL_ENTRIES','','','','','','',
                                          l_log_module,
                                          C_LEVEL_STATEMENT);
                          END IF;


                           gl_insert_detail( p_request_id,
                                             l_user_source_name,
                                             l_transfer_run_id,
                                             l_period_name,
                                             l_period_start_date,
                                             l_period_end_date,
                                             l_next_period,
                                             l_reversal_date,
                                             p_sob_list(i).average_balances_flag,
                                             p_gl_transfer_mode,
                                             l_group_id,
                                             p_batch_desc,
                                             p_je_desc,
                                             p_je_line_desc);

                       END IF;

                    END IF;

                    -- Transfer encumbrance reversals to gl_interface if
                    -- encumbrance is used.
                    IF (Nvl(l_encumbrance_flag,'N') = 'Y') THEN
                        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                           xla_message('XLA_GLT_CALL_ENCUM_ROUTINE','','','','','',
                                       '',l_log_module,
                                       C_LEVEL_STATEMENT);
                        END IF;
                       transfer_enc_lines( p_application_id,
                                           l_set_of_books_id,
                                           l_transfer_run_id,
                                           l_period_start_date,
                                           l_period_end_date,
                                           l_next_period,
                                           l_reversal_date,
                                           p_sob_list(i).average_balances_flag,
                                           l_user_source_name,
                                           l_group_id,
                                           l_request_id,
                                           p_batch_desc,
                                           p_je_desc,
                                           p_je_line_desc);
                    END IF;
                    -- Call Globalization Routine
                     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                         xla_message('XLA_GLT_CALLING_JG_PKG','','','','','','',l_log_module,
                                      C_LEVEL_STATEMENT);
                     END IF;

                    JG_XLA_GL_TRANSFER_PKG.jg_xla_gl_transfer
                      ( p_application_id,
                        p_user_id,
                        p_org_id,
                        p_request_id,
                        l_transfer_run_id,
                        p_program_name,
                        p_selection_type,
                        p_batch_name,
                        l_period_start_date,
                        l_period_end_date,
                        p_gl_transfer_mode,
                        p_process_days,
                        p_debug_flag
                        );
                 END IF;
              END LOOP; -- Process Periods
              CLOSE c_getPeriods;
           END IF; -- Entries Found
        END LOOP; -- Multiple Entities
        CLOSE c_get_program_info;
      END IF;  -- Selection Type

      -- Call product specific API
      -- AP Trial Balance
      IF l_pre_commit_api IS NOT NULL THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             xla_message('XLA_GLT_CALL_PRE_COMMIT_API', 'API_NAME',
                         l_pre_commit_api, '','','','',l_log_module,
                         C_LEVEL_STATEMENT);
         END IF;
         EXECUTE IMMEDIATE
           ' begin ' || l_pre_commit_api ||'( '|| l_transfer_run_id || ' ); end;';
      END IF;

      -- Bug# 4675862 - Call PSA API if Bugetary control is enabled for this
      -- set_of_books_id or USSGL profile option is Yes or encumbrance
      -- accounting is being used.
      -- (call the funds checker only if there are entries to process)

      IF Nvl(l_gl_installed_flag,'N') = 'I' AND g_rec_transfer_flag = 'Y' THEN
            -- Bug2691999. Insert records only if, Submit Journal Import = Y
            IF  NVL(p_submit_journal_import,'Y') = 'Y' THEN
               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                   xla_message('XLA_GLT_INSERT_GIC','STATUS','S','','','','',l_log_module,
                                  C_LEVEL_STATEMENT);
               END IF;

               INSERT INTO gl_interface_control
               ( JE_SOURCE_NAME,
                 STATUS,
                 INTERFACE_RUN_ID,
                 GROUP_ID,
                 SET_OF_BOOKS_ID,
                 PACKET_ID
               )
              VALUES
               (
                 l_source_name,
                 'S',
                 l_interface_run_id,
                 l_group_id,
                 l_set_of_books_id,
                 ''
               );
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               xla_message('XLA_GLT_SUBMIT_JOURNAL_IMP','','','','','','',l_log_module,C_LEVEL_STATEMENT);
            END IF;
            l_submittedreqid:= fnd_request.submit_request
              (
               'SQLGL',                 -- application short name
               'GLLEZL',                -- program short name
               NULL,                    -- program name
               NULL,                    -- start date
               FALSE,                   -- sub-request
               l_interface_run_id,      -- interface run id
               l_set_of_books_id,       -- set of books id
               'N',                     -- error to suspense flag
               NULL,                    -- from accounting date
               NULL,                    -- to accounting date
               NVL(p_summary_journal_entry,'N'), -- create summary flag
               'N'                      -- import desc flex flag
               );


            IF Nvl(l_submittedreqid,0) = 0 THEN
               IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                  xla_message('XLA_GLT_JOURNALIMP_ERROR','','','','','','',l_log_module,C_LEVEL_EXCEPTION);
               END IF;
             ELSE
               -- Journal Import is submitted successfully.
               -- Call PSA routine. Bug# 4675862
               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  xla_message('XLA_GLT_JOURNALIMP_SUBMITTED','REQUEST_ID',
                              l_submittedreqid,'','','','',l_log_module,C_LEVEL_STATEMENT);
               END IF;
               xla_utility_pkg.print_logfile('Calling PSA_FUNDS_CHECKER_PKG');
                PSA_FUNDS_CHECKER_PKG.populate_group_id
                  (p_grp_id         => l_group_id
                  ,p_application_id => g_application_id
                  );
            END IF;
         END IF;
      END IF;

      UPDATE xla_gl_transfer_batches_all
          SET gllezl_request_id = l_submittedreqid,
              transfer_status   = Decode(g_sob_rows_created,0,'N','C'),
              packet_id         = l_packet_id
       WHERE gl_transfer_run_id = l_transfer_run_id;
       COMMIT;
       g_total_rows_created := g_total_rows_created + g_sob_rows_created;

   END LOOP; -- process sobs
   IF g_total_rows_created > 0 THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         xla_message('XLA_GLT_TRANSFER_SUCCESS','','','',
                     '','','',l_log_module,C_LEVEL_STATEMENT);
      END IF;
    ELSE
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          xla_message('XLA_GLT_NO_DATA','','','',
                      '','','',l_log_module,C_LEVEL_STATEMENT);
      END IF;
   END IF;
 EXCEPTION
   WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
       IF (C_LEVEL_ERROR >= g_log_level) THEN
           xla_message('XLA_GLT_DEBUG','ERROR', Sqlerrm, 'DEBUG_INFO',
                       l_debug_info,'','',l_log_module,C_LEVEL_ERROR);
       END IF;
    END IF;
    RAISE;
END XLA_GL_TRANSFER;

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END XLA_GL_TRANSFER_PKG;

/
