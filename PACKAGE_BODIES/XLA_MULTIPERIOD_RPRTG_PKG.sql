--------------------------------------------------------
--  DDL for Package Body XLA_MULTIPERIOD_RPRTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_MULTIPERIOD_RPRTG_PKG" AS
-- $Header: xlarpmpa.pkb 120.5.12010000.4 2009/10/12 14:45:00 vkasina ship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation Belmont, California, USA            |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|    xlarpmpa.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_multiperiod_rprtg_pkg                                              |
|                                                                            |
| DESCRIPTION                                                                |
|          This package calls XLA_MULTIPERIOD_ACCOUNTING_PKG.complete_       |
|          journal_entries and generates the XML extract for reporting       |
|          multiperiod recognition entries,accrual reversal entries and      |
|          their errors.                                                     |
| HISTORY                                                                    |
|     16/08/2005  VS Koushik      Created                                    |
+===========================================================================*/

TYPE t_rec IS RECORD
    (f1               VARCHAR2(80)
    ,f2               VARCHAR2(80));
TYPE t_array IS TABLE OF t_rec INDEX BY BINARY_INTEGER;


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
   C_DEFAULT_MODULE      CONSTANT VARCHAR2(240)
                         := 'xla.plsql.xla_multiperiod_rprtg_pkg';

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
          (p_location   => 'xla_multiperiod_rprtg_pkg.trace');
END trace;

PROCEDURE build_xml_sql (p_accounting_batch_id IN NUMBER);

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--    1.  run_report
--=============================================================================
   PROCEDURE RUN_REPORT
       (p_errbuf                          OUT NOCOPY VARCHAR2
       ,p_retcode                         OUT NOCOPY NUMBER
       ,p_application_id                  IN NUMBER
       ,p_ledger_id                       IN NUMBER
       ,p_process_category_code           IN VARCHAR2
       ,p_end_date                        IN DATE
       ,p_errors_only_flag                IN VARCHAR2
       ,p_transfer_to_gl_flag             IN VARCHAR2
       ,p_post_in_gl_flag                 IN VARCHAR2
       ,p_gl_batch_name                   IN VARCHAR2
       ,p_valuation_method_code           IN VARCHAR2
       ,p_security_int_1                  IN NUMBER
       ,p_security_int_2                  IN NUMBER
       ,p_security_int_3                  IN NUMBER
       ,p_security_char_1                 IN VARCHAR2
       ,p_security_char_2                 IN VARCHAR2
       ,p_security_char_3                 IN VARCHAR2) IS

       l_log_module                    VARCHAR2(240);
       l_accounting_batch_id           XLA_AE_HEADERS.ACCOUNTING_BATCH_ID%TYPE;

   BEGIN

      IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||'.run_report';
      END IF;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('run_report.Begin',C_LEVEL_PROCEDURE,l_log_module);
      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('p_application_id = '|| to_char(p_application_id),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_ledger_id = '|| to_char(p_ledger_id),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_process_category_code = '||to_char(p_process_category_code),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_end_date  = '||to_char(p_end_date,'DD-MON-YYYY'),
               C_LEVEL_STATEMENT,l_log_module);
         trace('p_errors_only_flag = '|| p_errors_only_flag,
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_transfer_to_gl_flag = '|| to_char(p_transfer_to_gl_flag),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_post_in_gl_flag = '|| to_char(p_post_in_gl_flag),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_gl_batch_name = '|| to_char(p_gl_batch_name),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_valuation_method_code = '||to_char(p_valuation_method_code),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_security_int_1 = '|| to_char(p_security_int_1),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_security_int_2 = '|| to_char(p_security_int_2),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_security_int_3 = '|| to_char(p_security_int_3),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_security_char_1 = '|| to_char(p_security_char_1),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_security_char_2 = '|| to_char(p_security_char_2),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_security_char_3 = '|| to_char(p_security_char_3),
               C_LEVEL_STATEMENT, l_log_module);
      END IF;
      XLA_MULTIPERIOD_ACCOUNTING_PKG.complete_journal_entries(
         p_application_id             => p_application_id
      ,p_ledger_id                  => p_ledger_id
      ,p_process_category_code      => p_process_category_code
      ,p_end_date                   => p_end_date
      ,p_errors_only_flag           => p_errors_only_flag
      ,p_transfer_to_gl_flag        => p_transfer_to_gl_flag
      ,p_post_in_gl_flag            => p_post_in_gl_flag
      ,p_gl_batch_name              => p_gl_batch_name
      ,p_valuation_method_code      => p_valuation_method_code
      ,p_security_id_int_1          => p_security_int_1
      ,p_security_id_int_2          => p_security_int_2
      ,p_security_id_int_3          => p_security_int_3
        ,p_security_id_char_1         => p_Security_char_1
      ,p_security_id_char_2         => p_security_char_2
      ,p_security_id_char_3         => p_security_char_3
      ,p_accounting_batch_id        => l_accounting_batch_id
      ,p_errbuf                     => p_errbuf
      ,p_retcode                    => p_retcode);

      build_xml_sql(l_accounting_batch_id);


      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('run_report.End',C_LEVEL_PROCEDURE,l_log_module);
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         -- trace mesg
         xla_exceptions_pkg.raise_message
            (p_location       => 'xla_multiperiod_rprtg_pkg.run_report ');
   END run_report;

FUNCTION get_transaction_id
            (p_application_id         IN NUMBER
            ,p_ledger_id              IN NUMBER
            ,p_end_date               IN DATE
            ,p_process_category_code  IN VARCHAR2) RETURN VARCHAR2 IS

CURSOR cur_event_class  IS
/* Changed from = xla_ae_headers to exists in xla_ae_headers
performance bug#8234582*/
SELECT   DISTINCT  xcl.application_id APPLICATION_ID
                  ,xcl.entity_code          ENTITY_CODE
                  ,xcl.event_class_code     EVENT_CLASS_CODE
                  ,xatr.reporting_view_name REPORTING_VIEW_NAME
FROM  xla_event_types_b         xcl
     ,xla_event_class_attrs     xatr
WHERE xatr.entity_code       =  xcl.entity_code
AND   xatr.event_class_code  =  xcl.event_class_code
AND   xatr.application_id    =  p_application_id
AND   xcl.application_id     =  p_application_id -- added for 8722755
AND   xatr.event_class_group_code  =  nvl(p_process_category_code, xatr.event_class_group_code)
AND   xatr.event_class_code NOT IN ('THIRD_PARTY_MERGE','MANUAL','REVERSAL');


     l_col_array           t_array;
     l_null_col_array      t_array;
     l_trx_id_str          VARCHAR2(32000);
     l_col_string          VARCHAR2(4000)   := NULL;
     l_view_name           VARCHAR2(800);
     l_join_string         VARCHAR2(4000)   := NULL;
     l_sql_string          VARCHAR2(4000)   := NULL;
     l_index               INTEGER;
     l_outerjoin           VARCHAR2(30);
     l_log_module          VARCHAR2(240);

BEGIN
     IF g_log_enabled THEN
        l_log_module := C_DEFAULT_MODULE||'.get_transaction_id';
     END IF;
     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           (p_msg      => 'BEGIN of function GET_TRANSACTION_ID'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
        trace
           (p_msg      => 'p_application_id = '||to_char(p_application_id)
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
        trace
           (p_msg      => 'p_ledger_id = '||to_char(p_ledger_id)
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
        trace
           (p_msg      => 'p_end_date = '||to_char(p_end_date,'DD-MON-YYYY')
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
        trace
           (p_msg      => 'p_process_category_code = '||p_process_category_code
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
     END IF;

     l_trx_id_str := ',CASE WHEN 1<1 THEN NULL';

     FOR cur_trx IN cur_event_class LOOP
        l_col_string    := NULL;
        l_view_name     := NULL;
        l_join_string   := NULL;

        IF cur_trx.entity_code <> 'MANUAL'  THEN
        --
        -- creating a dummy array that contains "NULL" strings
        --
        FOR i IN 1..10 LOOP
           l_null_col_array(i).f1 := 'NULL';
           l_null_col_array(i).f2 := 'NULL';
        END LOOP;
        --
        -- initiating the array that contains name of the columns to be selected
        -- from the TID View.
        --
        l_col_array := l_null_col_array;

        --
        -- creating SELECT,FROM and WHERE clause strings when the reporting view is
        -- defined for an Event Class.
        --

        IF cur_trx.reporting_view_name IS NOT NULL THEN
        --
        -- creating string to be added to FROM clause
        --
           l_view_name   := cur_trx.reporting_view_name || '    TIV';
           l_index := 0;
           FOR cols_csr IN
              (SELECT  xid.transaction_id_col_name_1   trx_col_1
                      ,xid.transaction_id_col_name_2   trx_col_2
                      ,xid.transaction_id_col_name_3   trx_col_3
                      ,xid.transaction_id_col_name_4   trx_col_4
                      ,xid.source_id_col_name_1        src_col_1
                      ,xid.source_id_col_name_2        src_col_2
                      ,xid.source_id_col_name_3        src_col_3
                      ,xid.source_id_col_name_4        src_col_4
                      ,xem.column_name                 column_name
                      ,xem.column_title                PROMPT
                      ,utc.data_type                   data_type
                 FROM  xla_entity_id_mappings   xid
                      ,xla_event_mappings_vl    xem
                      ,user_tab_columns         utc
                WHERE xid.application_id       = cur_trx.application_id
                  AND xid.entity_code          = cur_trx.entity_code
                  AND xem.application_id       = cur_trx.application_id
                  AND xem.entity_code          = cur_trx.entity_code
                  AND xem.event_class_code     = cur_trx.event_class_code
                  AND utc.table_name           = cur_trx.reporting_view_name
                  AND utc.column_name          = xem.column_name
             ORDER BY xem.user_sequence)
           LOOP

             l_index := l_index + 1;
             --
             -- creating string to be added to WHERE clause
             --
             IF l_index = 1 THEN

                IF g_log_level <> C_LEVEL_LOG_DISABLED THEN
                   l_outerjoin := '(+)';
                ELSE
                   l_outerjoin := NULL;
                END IF;

                IF cols_csr.trx_col_1 IS NOT NULL THEN
                   l_join_string := l_join_string ||
                                   '  TIV.'|| cols_csr.trx_col_1 ||l_outerjoin ||
                                   ' = ENT.'|| cols_csr.src_col_1;
                END IF;
                IF cols_csr.trx_col_2 IS NOT NULL THEN
                   l_join_string := l_join_string ||
                                  ' AND TIV.'|| cols_csr.trx_col_2 ||l_outerjoin ||
                                  ' = ENT.'|| cols_csr.src_col_2;
                END IF;
                IF cols_csr.trx_col_3 IS NOT NULL THEN
                   l_join_string := l_join_string ||
                                  ' AND TIV.'|| cols_csr.trx_col_3 ||l_outerjoin ||
                                  ' = ENT.'|| cols_csr.src_col_3;
                END IF;
                IF cols_csr.trx_col_4 IS NOT NULL THEN
                   l_join_string := l_join_string ||
                                 ' AND TIV.'|| cols_csr.trx_col_4 ||l_outerjoin ||
                                 ' = ENT.'|| cols_csr.src_col_4;
                END IF;
             END IF;
             --
             -- getting the PROMPTs to be displayed
             --
             --l_col_array(l_index).f1 := ''''||cols_csr.PROMPT||'''';
             l_col_array(l_index).f1 := ''''||REPLACE (cols_csr.PROMPT, '''', '''''')||''''; -- bug 7636128

             ---
             -- getting the columns to be displayed
             ---
             IF cols_csr.data_type = 'VARCHAR2' THEN
               l_col_array(l_index).f2 := 'TIV.'|| cols_csr.column_name;
             ELSE
               l_col_array(l_index).f2 := 'to_char(TIV.'|| cols_csr.column_name||')';
             END IF;
          END LOOP;
       END IF;
       --------------------------------------------------------------------------
       -- building the string to be added to the SELECT clause
       --------------------------------------------------------------------------
       l_col_string := l_col_string ||
                       l_col_array(1).f1||'||''|''||'||l_col_array(1).f2;

       FOR i IN 2..l_col_array.count LOOP
          l_col_string := l_col_string ||'||''|''||'||l_col_array(i).f1
                          ||'||''|''||'||l_col_array(i).f2;
       END LOOP;
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
             (p_msg      => 'l_col_string = '||l_col_string
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);
       END IF;
      l_trx_id_str := l_trx_id_str||' WHEN xet.event_class_code = '''
                   ||cur_trx.event_class_code||''' THEN  ( SELECT '||l_col_string
                   ||'  FROM  '||l_view_name ||' WHERE '|| l_join_string ||' )' ;
      END IF;
    END LOOP;

    l_trx_id_str := l_trx_id_str ||' END  ';

     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace('get_transaction_id.End'
                ,C_LEVEL_PROCEDURE, l_log_module);
     END IF;

    RETURN l_trx_id_str;

EXCEPTION
  WHEN OTHERS THEN
     xla_exceptions_pkg.raise_message
        (p_location       => 'xla_multiperiod_rprtg_pkg.get_transaction_id ');

END get_transaction_id;

PROCEDURE build_xml_sql (p_accounting_batch_id IN NUMBER) IS
    l_log_module VARCHAR2(240);
BEGIN

    IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||'.build_xml_sql';
    END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('build_xml_sql.Begin'
               ,C_LEVEL_PROCEDURE, l_log_module);
        trace
           (p_msg      => 'p_accounting_batch_id = '||to_char(p_accounting_batch_id)
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;

    xla_multiperiod_rprtg_pkg.C_SUMMARY_QUERY :=
                   ' SELECT xec.event_class_code              EVENT_CLASS_CODE
                            ,xec.name                         EVENT_CLASS
                            ,xgl.ledger_id                    LEDGER_ID
                            ,xgl.name                         LEDGER
                            ,lk1.meaning                      ACTUAL
                            ,lk2.meaning                      BUDGET
                            ,lk3.meaning                      ENCUMBRANCE
                            ,ent.entity_id                    NUMBER_OF_DOC
                            ,DECODE(xah.balance_type_code,''A''
                                   ,xah.accounting_entry_status_code) ACTUAL_B
                            ,DECODE(xah.balance_type_code,''B''
                                   ,xah.accounting_entry_status_code) BUDGET_B
                            ,DECODE(xah.balance_type_code,''E''
                                   ,xah.accounting_entry_status_code) ENCUMBRANCE_B
                        FROM  xla_ae_headers             xah
                             ,xla_gl_ledgers_v           xgl
                             ,xla_events                 xae
                             ,xla_event_classes_tl       xec
                             ,xla_event_types_b          xet
                             ,xla_transaction_entities   ent
                             ,xla_lookups                lk1
                             ,xla_lookups                lk2
                             ,xla_lookups                lk3
                       WHERE  xgl.ledger_id              = xah.ledger_id
                         AND  xec.application_id         = xet.application_id
                         AND  xec.event_class_code       = xet.event_class_code
                         AND  xec.language               = USERENV(''LANG'')
                         AND  ent.entity_id              = xae.entity_id
                         AND  xet.application_id         = xae.application_id
                         AND  xet.event_type_code        = xae.event_type_code
                         AND  xae.event_id               = xah.event_id
                         AND  lk1.lookup_type            = ''XLA_BALANCE_TYPE''
                         AND  lk1.lookup_code            = ''A''
                         AND  lk2.lookup_type            = ''XLA_BALANCE_TYPE''
                         AND  lk2.lookup_code            = ''B''
                         AND  lk3.lookup_type            = ''XLA_BALANCE_TYPE''
                         AND  lk3.lookup_code            = ''E'' ';

    xla_multiperiod_rprtg_pkg.xah_appl_filter := ' AND  xah.application_id         = '||
                                                       to_char(xla_multiperiod_rprtg_pkg.p_application_id);
    xla_multiperiod_rprtg_pkg.xae_appl_filter := ' AND  xae.application_id         = '||
                                                       to_char(xla_multiperiod_rprtg_pkg.p_application_id);
    xla_multiperiod_rprtg_pkg.ent_appl_filter := ' AND  ent.application_id         = '||
                                                       to_char(xla_multiperiod_rprtg_pkg.p_application_id);
    xla_multiperiod_rprtg_pkg.xal_appl_filter := ' AND  xal.application_id         = '||
                                                       to_char(xla_multiperiod_rprtg_pkg.p_application_id);

    xla_multiperiod_rprtg_pkg.acct_batch_filter := ' AND  xah.accounting_batch_id    = '||
                                                     to_char(p_accounting_batch_id);

    xla_multiperiod_rprtg_pkg.C_TRANSFER_QUERY :=
                        ' SELECT xgl.name                     LEDGER
                                 ,xgl.ledger_id               LEDGER_ID
                                 ,lk1.meaning                 ACTUAL
                                 ,lk2.meaning                 BUDGET
                                 ,lk3.meaning                 ENCUMBRANCE
                                 ,sum(decode(xah.balance_type_code,''A'',1,0))
                                                              ACTUAL_B
                                 ,sum(decode(xah.balance_type_code,''B'',1,0))
                                                              BUDGET_B
                                 ,sum(decode(xah.balance_type_code,''E'',1,0))
                                                              ENCUMBRANCE_B
                             FROM xla_ae_headers              xah
                                 ,xla_gl_ledgers_v            xgl
                                 ,xla_lookups                 lk1
                                 ,xla_lookups                 lk2
                                 ,xla_lookups                 lk3
                            WHERE xgl.ledger_id               = xah.ledger_id
                              AND xah.gl_transfer_status_code = ''Y''
                              AND lk1.lookup_type             = ''XLA_BALANCE_TYPE''
                              AND lk1.lookup_code             = ''A''
                              AND lk2.lookup_type             = ''XLA_BALANCE_TYPE''
                              AND lk2.lookup_code             = ''B''
                              AND lk3.lookup_type             = ''XLA_BALANCE_TYPE''
                              AND lk3.lookup_code             = ''E'' ';

    xla_multiperiod_rprtg_pkg.C_GENERAL_ERRORS_QUERY :=
                              ' SELECT ERR.MESSAGE_NUMBER      ERROR_NO
                                      ,ERR.ENCODED_MSG         ERROR_MSG
                                      ,ERR.AE_LINE_NUM         LINE_NUM
                                  FROM XLA_ACCOUNTING_ERRORS   ERR
                                      ,XLA_AE_HEADERS          XAH
                                 WHERE err.ae_header_id        = xah.ae_header_id
                                   AND err.application_id      = xah.application_id ';

    xla_multiperiod_rprtg_pkg.C_RECOGNITION_COLS_QUERY :=
                                  ' SELECT xah.event_id                  event_id
                                          ,xec.name                      event_class
                                          ,xet.name                      event_type
                                          ,xae.event_number              event_number
                                          ,to_char(xae.event_date,''YYYY-MM-DD'')
                                                                         event_date
                                          ,xah.ae_header_id              ae_header_id
                                          ,gld.name                      ledger
                                          ,to_char(xah.accounting_date,''YYYY-MM-DD'')
                                                                         gl_date
                                          ,gld.currency_code             ledger_currency
                                          ,xpr.name                      aad_name
                                          ,xah.product_rule_version      aad_version
                                          ,xah.description               description
                                          ,lk1.meaning                   journal_entry_status
                                          ,lk3.meaning                   mpa_type
                                          ,seqv2.header_name             acounting_sequence_name
                                          ,seqv2.version_name            acounting_sequence_version
                                          ,xah.completion_acct_seq_value accounting_sequence_number
                                          ,seqv3.header_name             reporting_sequence_name
                                          ,seqv3.version_name            reporting_sequence_version
                                          ,xah.close_acct_seq_value      reporting_sequence_number
                                          ,seq.name                      document_sequence_name
                                          ,xah.doc_sequence_value        document_sequence_value
                                          ,xal.ae_line_num               ae_line_num
                                          ,lk2.meaning                   accounting_class
                                          ,xal.displayed_line_number     line_number
                                          ,fnd_flex_ext.get_segs(''SQLGL'', ''GL#'',
                                           gld.chart_of_accounts_id, xal.code_combination_id) account
                                          ,xal.currency_code             currency
                                          ,xal.entered_dr                entered_debit
                                          ,xal.entered_cr                entered_credit
                                          ,xal.accounted_dr              accounted_debit
                                          ,xal.accounted_cr              accounted_credit
                                          ,sum(xal.accounted_dr) over (partition by xal.ae_header_id)
                                                                         total_accted_debits
                                          ,sum(xal.accounted_cr) over (partition by xal.ae_header_id)
                                                                         total_accted_credits ';

    xla_multiperiod_rprtg_pkg.C_RECOGNITION_FROM_QUERY :=
                                  ' FROM xla_ae_headers             xah
                                        ,xla_events                 xae
                                        ,xla_event_types_tl         xet
                                        ,xla_event_classes_tl       xec
                                        ,xla_transaction_entities   ent
                                        ,xla_gl_ledgers_v           gld
                                        ,xla_product_rules_tl       xpr
                                        ,xla_lookups                lk1
                                        ,xla_lookups                lk2
                                        ,xla_lookups                lk3
                                        ,xla_ae_lines               xal
                                        ,fnd_document_sequences     seq
                                        ,fun_seq_versions           seqv2
                                        ,fun_seq_versions           seqv3 ';

    xla_multiperiod_rprtg_pkg.C_RECOGNITION_WHR_QUERY :=
                                 ' WHERE xec.application_id         = xet.application_id
                                     AND xec.event_class_code       = xet.event_class_code
                                     AND xec.language               = USERENV(''LANG'')
                                     AND ent.application_id         = xet.application_id
                                     AND ent.entity_code            = xet.entity_code
                                     AND xet.application_id         = xae.application_id
                                     AND xet.event_type_code        = xae.event_type_code
                                     AND xah.entity_id              = ent.entity_id
                                     AND xet.language               = USERENV(''LANG'')
                                     AND xpr.amb_context_code       = xah.amb_context_code
                                     AND xpr.application_id         = xah.application_id
                                     AND xpr.product_rule_type_code = xah.product_rule_type_code
                                     AND xpr.product_rule_code      = xah.product_rule_code
                                     AND xpr.language               = USERENV(''LANG'')
                                     AND gld.ledger_id              = xah.ledger_id
                                     AND xal.application_id         = xah.application_id
                                     AND xal.ae_header_id           = xah.ae_header_id
                                     AND xae.application_id         = xah.application_id
                                     AND xae.event_id               = xah.event_id
                                     AND seq.doc_sequence_id(+)     = xah.doc_sequence_id
                                     AND seqv2.seq_version_id(+)    = xah.completion_acct_seq_version_id
                                     AND seqv3.seq_version_id(+)    = xah.close_acct_seq_version_id
                                     AND lk1.lookup_type            = ''XLA_ACCOUNTING_ENTRY_STATUS''
                                     AND lk1.lookup_code            = xah.accounting_entry_status_code
                                     AND lk2.lookup_type            = ''XLA_ACCOUNTING_CLASS''
                                     AND lk2.lookup_code            = xal.accounting_class_code
                                     AND lk3.lookup_type            = ''XLA_MPA_TYPE''
                                     AND lk3.lookup_code            = decode(xal.mpa_accrual_entry_flag,''Y'',''M'',''R'')
                                     AND xah.accounting_entry_status_code in (''D'',''F'')
                                     AND xah.parent_ae_header_id    IS NOT NULL
                                     AND xah.parent_ae_line_num     IS NOT NULL ';

    xla_multiperiod_rprtg_pkg.C_ACCRUAL_RVRSL_COLS_QUERY :=
                                  ' SELECT xah.event_id                  event_id
                                          ,xec.name                      event_class
                                          ,xet.name                      event_type
                                          ,xae.event_number              event_number
                                          ,to_char(xae.event_date,''YYYY-MM-DD'')
                                                                         event_date
                                          ,xah.ae_header_id              ae_header_id
                                          ,gld.name                      ledger
                                          ,to_char(xah.accounting_date,''YYYY-MM-DD'')
                                                                         gl_date
                                          ,gld.currency_code             ledger_currency
                                          ,xpr.name                      aad_name
                                          ,xah.product_rule_version      aad_version
                                          ,xah.description               description
                                          ,lk1.meaning                   journal_entry_status
                                          ,lk3.meaning                   mpa_type
                                          ,seqv2.header_name             acounting_sequence_name
                                          ,seqv2.version_name            acounting_sequence_version
                                          ,xah.completion_acct_seq_value accounting_sequence_number
                                          ,seqv3.header_name             reporting_sequence_name
                                          ,seqv3.version_name            reporting_sequence_version
                                          ,xah.close_acct_seq_value      reporting_sequence_number
                                          ,seq.name                      document_sequence_name
                                          ,xah.doc_sequence_value        document_sequence_value
                                          ,xal.ae_line_num               ae_line_num
                                          ,lk2.meaning                   accounting_class
                                          ,xal.displayed_line_number     line_number
                                          ,fnd_flex_ext.get_segs(''SQLGL'', ''GL#'',
                                           gld.chart_of_accounts_id, xal.code_combination_id) account
                                          ,xal.currency_code             currency
                                          ,xal.entered_dr                entered_debit
                                          ,xal.entered_cr                entered_credit
                                          ,xal.accounted_dr              accounted_debit
                                          ,xal.accounted_cr              accounted_credit
                                          ,sum(xal.accounted_dr) over (partition by xal.ae_header_id)
                                                                         total_accted_debits
                                          ,sum(xal.accounted_cr) over (partition by xal.ae_header_id)
                                                                         total_accted_credits ';

    xla_multiperiod_rprtg_pkg.C_ACCRUAL_RVRSL_FROM_QUERY :=
                                  ' FROM xla_ae_headers             xah
                                        ,xla_events                 xae
                                        ,xla_event_types_tl         xet
                                        ,xla_event_classes_tl       xec
                                        ,xla_transaction_entities   ent
                                        ,xla_gl_ledgers_v           gld
                                        ,xla_product_rules_tl       xpr
                                        ,xla_lookups                lk1
                                        ,xla_lookups                lk2
                                        ,xla_lookups                lk3
                                        ,xla_ae_lines               xal
                                        ,fnd_document_sequences     seq
                                        ,fun_seq_versions           seqv2
                                        ,fun_seq_versions           seqv3 ';

    xla_multiperiod_rprtg_pkg.C_ACCRUAL_RVRSL_WHR_QUERY :=
                                 ' WHERE xec.application_id          = xet.application_id
                                     AND xec.event_class_code        = xet.event_class_code
                                     AND xec.language                = USERENV(''LANG'')
                                     AND ent.application_id          = xet.application_id
                                     AND ent.entity_code             = xet.entity_code
                                     AND xet.application_id          = xae.application_id
                                     AND xet.event_type_code         = xae.event_type_code
                                     AND xah.entity_id               = ent.entity_id
                                     AND xet.language                = USERENV(''LANG'')
                                     AND xpr.amb_context_code        = xah.amb_context_code
                                     AND xpr.application_id          = xah.application_id
                                     AND xpr.product_rule_type_code  = xah.product_rule_type_code
                                     AND xpr.product_rule_code       = xah.product_rule_code
                                     AND xpr.language                = USERENV(''LANG'')
                                     AND gld.ledger_id               = xah.ledger_id
                                     AND xal.application_id          = xah.application_id
                                     AND xal.ae_header_id            = xah.ae_header_id
                                     AND xae.application_id          = xah.application_id
                                     AND xae.event_id                = xah.event_id
                                     AND seq.doc_sequence_id(+)      = xah.doc_sequence_id
                                     AND seqv2.seq_version_id(+)     = xah.completion_acct_seq_version_id
                                     AND seqv3.seq_version_id(+)     = xah.close_acct_seq_version_id
                                     AND lk1.lookup_type             = ''XLA_ACCOUNTING_ENTRY_STATUS''
                                     AND lk1.lookup_code             = xah.accounting_entry_status_code
                                     AND lk2.lookup_type             = ''XLA_ACCOUNTING_CLASS''
                                     AND lk2.lookup_code             = xal.accounting_class_code
                                     AND lk3.lookup_type             = ''XLA_MPA_TYPE''
                                     AND lk3.lookup_code             = decode(xah.accrual_reversal_flag,''Y'',''A'',''V'')
                                     AND xah.accounting_entry_status_code in (''D'',''F'')
                                     AND xah.parent_ae_header_id    IS NOT NULL
                                     AND xah.parent_ae_line_num     IS NULL ';

    xla_multiperiod_rprtg_pkg.C_ERRORS_COLS_QUERY :=
                           ' SELECT xah.event_id                  event_id
                                   ,xec.name                      event_class
                                   ,xet.name                      event_type
                                   ,xae.event_number              event_number
                                   ,to_char(xae.event_date,''YYYY-MM-DD'')
                                                                  event_date
                                   ,xah.ae_header_id              ae_header_id
                                   ,gld.name                      ledger
                                   ,to_char(xah.accounting_date,''YYYY-MM-DD'')
                                                                  gl_date
                                   ,gld.currency_code             ledger_currency
                                   ,xpr.name                      aad_name
                                   ,xah.product_rule_version      aad_version
                                   ,xah.description               description
                                   ,lk1.meaning                   journal_entry_status
                                   ,lk3.meaning                   mpa_type
                                   ,seqv2.header_name             acounting_sequence_name
                                   ,seqv2.version_name            acounting_sequence_version
                                   ,xah.completion_acct_seq_value accounting_sequence_number
                                   ,seqv3.header_name             reporting_sequence_name
                                   ,seqv3.version_name            reporting_sequence_version
                                   ,xah.close_acct_seq_value      reporting_sequence_number
                                   ,seq.name                      document_sequence_name
                                   ,xah.doc_sequence_value        document_sequence_value
                                   ,xal.ae_line_num               ae_line_num
                                   ,lk2.meaning                   accounting_class
                                   ,xal.displayed_line_number     line_number
                                   ,fnd_flex_ext.get_segs(''SQLGL'', ''GL#'',
                                    gld.chart_of_accounts_id, xal.code_combination_id) account
                                   ,xal.currency_code             currency
                                   ,xal.entered_dr                entered_debit
                                   ,xal.entered_cr                entered_credit
                                   ,xal.accounted_dr              accounted_debit
                                   ,xal.accounted_cr              accounted_credit
                                   ,sum(xal.accounted_dr) over (partition by xal.ae_header_id)
                                                                  total_accted_debits
                                   ,sum(xal.accounted_cr) over (partition by xal.ae_header_id)
                                                                  total_accted_credits
                                   ,err.message_number            error_number
                                   ,err.encoded_msg               error_message ';

    xla_multiperiod_rprtg_pkg.C_ERRORS_FROM_QUERY :=
                           ' FROM xla_ae_headers             xah
                                 ,xla_events                 xae
                                 ,xla_event_types_tl         xet
                                 ,xla_event_classes_tl       xec
                                 ,xla_transaction_entities   ent
                                 ,xla_gl_ledgers_v           gld
                                 ,xla_product_rules_tl       xpr
                                 ,xla_lookups                lk1
                                 ,xla_lookups                lk2
                                 ,xla_lookups                lk3
                                 ,xla_ae_lines               xal
                                 ,fnd_document_sequences     seq
                                 ,fun_seq_versions           seqv2
                                 ,fun_seq_versions           seqv3
                                 ,xla_accounting_errors      err ';

    xla_multiperiod_rprtg_pkg.C_ERRORS_WHR_QUERY :=
                          ' WHERE xec.application_id         = xet.application_id
                              AND xec.event_class_code       = xet.event_class_code
                              AND xec.language               = USERENV(''LANG'')
                              AND ent.application_id         = xet.application_id
                              AND ent.entity_code            = xet.entity_code
                              AND xet.application_id         = xae.application_id
                              AND xet.event_type_code        = xae.event_type_code
                              AND xah.entity_id              = ent.entity_id
                              AND xet.language               = USERENV(''LANG'')
                              AND xpr.amb_context_code       = xah.amb_context_code
                              AND xpr.application_id         = xah.application_id
                              AND xpr.product_rule_type_code = xah.product_rule_type_code
                              AND xpr.product_rule_code      = xah.product_rule_code
                              AND xpr.language               = USERENV(''LANG'')
                              AND gld.ledger_id              = xah.ledger_id
                              AND xal.application_id         = xah.application_id
                              AND xal.ae_header_id           = xah.ae_header_id
                              AND xae.application_id         = xah.application_id
                              AND xae.event_id               = xah.event_id
                              AND seq.doc_sequence_id(+)     = xah.doc_sequence_id
                              AND seqv2.seq_version_id(+)    = xah.completion_acct_seq_version_id
                              AND seqv3.seq_version_id(+)    = xah.close_acct_seq_version_id
                              AND lk1.lookup_type            = ''XLA_ACCOUNTING_ENTRY_STATUS''
                              AND lk1.lookup_code            = xah.accounting_entry_status_code
                              AND lk2.lookup_type            = ''XLA_ACCOUNTING_CLASS''
                              AND lk2.lookup_code            = xal.accounting_class_code
                              AND lk3.lookup_type            = ''XLA_MPA_TYPE''
                              AND lk3.lookup_code            = (CASE WHEN xah.accrual_reversal_flag = ''Y''
                                                                        THEN ''A''
                                                                        WHEN xah.parent_ae_header_id IS NOT NULL
                                                                         AND xah.parent_ae_line_num  IS NULL
                                                                        THEN ''V''
                                                                        WHEN xal.mpa_accrual_entry_Flag = ''Y''
                                                                        THEN ''M''
                                                                        ELSE ''R'' END)
                              AND xal.application_id(+)      = err.application_id
                              AND xal.ae_header_id(+)        = err.ae_header_id
                              AND xal.ae_line_num(+)         = err.ae_line_num
                              AND xah.accounting_entry_status_code NOT IN (''D'',''F'')
                              AND xah.parent_ae_header_id    IS NOT NULL ';

    IF p_report = 'D' THEN
       xla_multiperiod_rprtg_pkg.p_trx_identifiers := get_transaction_id(xla_multiperiod_rprtg_pkg.p_application_id
                                                                     ,xla_multiperiod_rprtg_pkg.p_ledger_id
                                                                     ,xla_multiperiod_rprtg_pkg.p_end_date
                                                                     ,xla_multiperiod_rprtg_pkg.p_process_category_code)
                                                   ||' USERIDS ';
    ELSE
       xla_multiperiod_rprtg_pkg.p_trx_identifiers := ',CASE WHEN 1<1 THEN NULL END USERIDS ';
    END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('build_xml_sql.End'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('build_xml_sql.End with Error'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;
     xla_exceptions_pkg.raise_message
           (p_location       =>
                'xla_multiperiod_rprtg_pkg.build_xml_sql');
END build_xml_sql;


FUNCTION beforeReport  RETURN BOOLEAN IS
   l_errbuf                  VARCHAR2(2000);
   l_log_module              VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
        l_log_module := C_DEFAULT_MODULE||'.beforeReport';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace('beforeReport.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace('p_application_id = '|| to_char(p_application_id),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_ledger_id = '|| to_char(p_ledger_id),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_process_category_code = '|| to_char(p_process_category_code),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_end_date = '|| to_char(p_end_date,'DD-MON-YYYY'),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_errors_only_flag = '|| to_char(p_errors_only),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_transfer_to_gl_flag = '|| to_char(p_transfer_to_gl),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_post_in_gl_flag = '|| to_char(p_post_in_gl),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_gl_batch_name = '|| p_gl_batch_name,
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_valuation_method_code = '|| to_char(p_valuation_method_code),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_security_int_1 = '|| to_char(p_security_int_1),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_security_int_2 = '|| to_char(p_security_int_2),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_security_int_3 = '|| to_char(p_security_int_3),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_security_char_1 = '|| to_char(p_security_char_1),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_security_char_2 = '|| to_char(p_security_char_2),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_security_char_3 = '|| to_char(p_security_char_3),
               C_LEVEL_STATEMENT, l_log_module);
   END IF;

   run_report(p_errbuf                  =>  l_errbuf
             ,p_retcode                 =>  C_RETURN_CODE
             ,p_application_id          =>  xla_multiperiod_rprtg_pkg.p_application_id
             ,p_ledger_id               =>  xla_multiperiod_rprtg_pkg.p_ledger_id
             ,p_process_category_code   =>  xla_multiperiod_rprtg_pkg.p_process_category_code
             ,p_end_date                =>  xla_multiperiod_rprtg_pkg.p_end_date
             ,p_errors_only_flag        =>  xla_multiperiod_rprtg_pkg.p_errors_only
             ,p_transfer_to_gl_flag     =>  xla_multiperiod_rprtg_pkg.p_transfer_to_gl
             ,p_post_in_gl_flag         =>  xla_multiperiod_rprtg_pkg.p_post_in_gl
             ,p_gl_batch_name           =>  xla_multiperiod_rprtg_pkg.p_gl_batch_name
             ,p_valuation_method_code   =>  xla_multiperiod_rprtg_pkg.p_valuation_method_code
             ,p_security_int_1          =>  xla_multiperiod_rprtg_pkg.p_security_int_1
             ,p_security_int_2          =>  xla_multiperiod_rprtg_pkg.p_security_int_2
             ,p_security_int_3          =>  xla_multiperiod_rprtg_pkg.p_security_int_3
             ,p_security_char_1         =>  xla_multiperiod_rprtg_pkg.p_security_char_1
             ,p_security_char_2         =>  xla_multiperiod_rprtg_pkg.p_security_char_2
             ,p_security_char_3         =>  xla_multiperiod_rprtg_pkg.p_security_char_3);

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('beforeReport.End'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location  => 'xla_multiperiod_rprtg_pkg.beforeReport ');

END beforeReport;

 BEGIN
      g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
      g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,MODULE     => C_DEFAULT_MODULE);

      IF NOT g_log_enabled  THEN
         g_log_level := C_LEVEL_LOG_DISABLED;
      END IF;
 END xla_multiperiod_rprtg_pkg;

/
