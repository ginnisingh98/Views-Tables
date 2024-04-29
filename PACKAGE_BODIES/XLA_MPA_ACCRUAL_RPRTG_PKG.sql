--------------------------------------------------------
--  DDL for Package Body XLA_MPA_ACCRUAL_RPRTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_MPA_ACCRUAL_RPRTG_PKG" AS
-- $Header: xlarpmpb.pkb 120.8.12010000.6 2009/10/20 15:56:13 vgopiset ship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation Belmont, California, USA            |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|    xlarpmpb.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_mpa_accrual_rprtg_pkg                                              |
|                                                                            |
| DESCRIPTION                                                                |
|          This package is called by the Create Accounting program through   |
|          a concurrent request and generates a report if there are mpa      |
|          entries. The report consists of a list of all those mpa,          |
|          recognition, accrual and accrual reversal entries.                |
| HISTORY                                                                    |
|     16/08/2005  VS Koushik      Created                                    |
|     19/10/2009  VGOPISET        8977840: MPA Report should inherit Report  |
|                                 Parameter values from Create Accounting .  |
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
                         := 'xla.plsql.xla_mpa_accrual_rprtg_pkg';

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
            (p_location   => 'xla_mpa_accrual_rprtg_pkg.trace');
  END trace;

PROCEDURE build_xml_sql;

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
FUNCTION get_transaction_id
            (p_application_id          IN NUMBER
            ,p_ledger_id               IN NUMBER
            ,p_end_date                IN DATE
            ,p_process_category_code   IN VARCHAR2) RETURN VARCHAR2 IS

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
AND   xatr.event_class_code NOT IN ('THIRD_PARTY_MERGE','MANUAL','REVERSAL') -- added for 8722755
-- removed the changes done via bug:8234582 for bug:8722755
-- AND EXISTS
-- (  SELECT /*+ hash_sj */ NULL
--    FROM xla_ae_headers aeh
--    WHERE xcl.application_id      = aeh.application_id
--    AND  xcl.event_type_code     = aeh.event_type_code
--    AND  aeh.ledger_id           = p_ledger_id
--    AND  aeh.application_id      = xcl.application_id
--    AND  aeh.accounting_date     < p_end_date
-- )
;


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
        --  Split the join between Entity Mapping and Event Mappings as Report Ends in Error
	--  with SQL Syntax erro when User Transaction Identifiers are nor provided in
	--  Accounting Event Class Options Window bug#8977840
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
                 FROM  xla_entity_id_mappings   xid
		 WHERE xid.application_id       = cur_trx.application_id
                  AND xid.entity_code          = cur_trx.entity_code
	     )
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
	   END LOOP ;

           l_index := 0;
           FOR cols_csr IN
              (SELECT  xem.column_name                 column_name
                      ,xem.column_title                PROMPT
                      ,utc.data_type                   data_type
                 FROM  xla_event_mappings_vl    xem
                      ,user_tab_columns         utc
                WHERE xem.application_id       = cur_trx.application_id
                  AND xem.entity_code          = cur_trx.entity_code
                  AND xem.event_class_code     = cur_trx.event_class_code
                  AND utc.table_name           = cur_trx.reporting_view_name
                  AND utc.column_name          = xem.column_name
             ORDER BY xem.user_sequence)
           LOOP

             l_index := l_index + 1;
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
        (p_location       => 'xla_mpa_accrual_rprtg_pkg.get_transaction_id ');

END get_transaction_id;

PROCEDURE build_xml_sql IS
    l_log_module VARCHAR2(240);
BEGIN

    IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||'.build_xml_sql';
    END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('build_xml_sql.Begin'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;

    xla_mpa_accrual_rprtg_pkg.C_SUMMARY_QUERY :=
                         ' SELECT xec.event_class_code                    EVENT_CLASS_CODE
                                 ,xec.name                                EVENT_CLASS
                                 ,xgl.ledger_id                           LEDGER_ID
                                 ,xgl.name                                LEDGER
                                 ,lk1.meaning                             ACTUAL
                                 ,lk2.meaning                             BUDGET
                                 ,lk3.meaning                             ENCUMBRANCE
                                 ,DECODE(xah.balance_type_code,''A''
                                     ,xah.accounting_entry_status_code)   ACTUAL_B
                                 ,DECODE(xah.balance_type_code,''B''
                                     ,xah.accounting_entry_status_code)   BUDGET_B
                                 ,DECODE(xah.balance_type_code,''E''
                                     ,xah.accounting_entry_status_code)   ENCUMBRANCE_B
                             FROM xla_ae_headers              xah
                                  ,xla_gl_ledgers_v           xgl
                                  ,xla_event_classes_tl       xec
                                  ,xla_event_types_b          xet
                                  ,xla_subledgers             xls
                                  ,xla_lookups                lk1
                                  ,xla_lookups                lk2
                                  ,xla_lookups                lk3
                            WHERE xgl.ledger_id              = xah.ledger_id
                              AND xec.application_id         = xet.application_id
                              AND xec.event_class_code       = xet.event_class_code
                              AND xec.language               = USERENV(''LANG'')
                              AND xet.application_id         = xah.application_id
                              AND xet.event_type_code        = xah.event_type_code
                              AND xls.application_id         = xah.application_id
                              AND lk1.lookup_type            = ''XLA_BALANCE_TYPE''
                              AND lk1.lookup_code            = ''A''
                              AND lk2.lookup_type            = ''XLA_BALANCE_TYPE''
                              AND lk2.lookup_code            = ''B''
                              AND lk3.lookup_type            = ''XLA_BALANCE_TYPE''
                              AND lk3.lookup_code            = ''E'' ';

    xla_mpa_accrual_rprtg_pkg.xah_appl_filter := ' AND  xah.application_id         = '||
                                                       to_char(xla_mpa_accrual_rprtg_pkg.p_application_id);
    xla_mpa_accrual_rprtg_pkg.xae_appl_filter := ' AND  xae.application_id         = '||
                                                       to_char(xla_mpa_accrual_rprtg_pkg.p_application_id);
    xla_mpa_accrual_rprtg_pkg.ent_appl_filter := ' AND  ent.application_id         = '||
                                                       to_char(xla_mpa_accrual_rprtg_pkg.p_application_id);
    xla_mpa_accrual_rprtg_pkg.xal_appl_filter := ' AND  xal.application_id         = '||
                                                       to_char(xla_mpa_accrual_rprtg_pkg.p_application_id);

    xla_mpa_accrual_rprtg_pkg.acct_batch_filter := ' AND  xah.accounting_batch_id    = '||
                                                     to_char(xla_mpa_accrual_rprtg_pkg.p_accounting_batch_id);

    xla_mpa_accrual_rprtg_pkg.C_TRANSFER_QUERY :=
                     ' SELECT xgl.name                  LEDGER
                             ,xgl.ledger_id             LEDGER_ID
                             ,lk1.meaning               ACCRUAL_ENTRY
                             ,lk2.meaning               MPA_ACCRUAL_ENTRY
                             ,lk3.meaning               MPA_RECOGNITION_ENTRY
                             ,lk4.meaning               ACCRUAL_REVERSAL_ENTRY
                             ,SUM(CASE WHEN xal.mpa_accrual_entry_flag = ''Y'' THEN 1
                                       ELSE 0
                                  END)                  MPA_ACCRUAL
                             ,SUM(CASE WHEN xah.parent_ae_header_id IS NOT NULL
                                        AND xah.parent_ae_line_num  IS NOT NULL THEN 1
                                       ELSE 0
                                  END)                  MPA_RECOGNITION
                             ,SUM(CASE WHEN xah.accrual_reversal_flag = ''Y'' THEN 1
                                       ELSE 0
                                  END)                  ACCRUAL
                             ,SUM(CASE WHEN xah.parent_ae_header_id IS NOT NULL
                                           AND xah.parent_ae_line_num  IS NULL THEN 1
                                       ELSE 0
                                  END)                  ACCRUAL_REVERSAL
                         FROM xla_ae_headers            xah
                             ,xla_ae_lines              xal
                             ,xla_gl_ledgers_v          xgl
                             ,xla_subledgers            xls
                             ,xla_lookups               lk1
                             ,xla_lookups               lk2
                             ,xla_lookups               lk3
                             ,xla_lookups               lk4
                       WHERE xgl.ledger_id                = xah.ledger_id
                         AND xah.gl_transfer_status_code  = ''Y''
                         AND xal.application_id           = xah.application_id
                         AND xal.ae_header_id             = xah.ae_header_id
                         AND lk1.lookup_type              = ''XLA_MPA_TYPE''
                         AND lk1.lookup_code              = ''A''
                         AND lk2.lookup_type              = ''XLA_MPA_TYPE''
                         AND lk2.lookup_code              = ''M''
                         AND lk3.lookup_type              = ''XLA_MPA_TYPE''
                         AND lk3.lookup_code              = ''R''
                         AND lk4.lookup_type              = ''XLA_MPA_TYPE''
                         AND lk4.lookup_code              = ''V''
                         AND xls.application_id           = xah.application_id ';

    xla_mpa_accrual_rprtg_pkg.C_GENERAL_ERRORS_QUERY :=
                        ' SELECT ERR.MESSAGE_NUMBER        ERROR_NO
                                ,ERR.ENCODED_MSG           ERROR_MSG
                                ,ERR.AE_LINE_NUM           LINE_NUM
                            FROM XLA_ACCOUNTING_ERRORS   ERR
                                ,XLA_AE_HEADERS          XAH
                                ,xla_subledgers          XLS
                           WHERE err.ae_header_id        = xah.ae_header_id
                             AND err.application_id      = xah.application_id
                             AND xls.application_id      = xah.application_id ';

    xla_mpa_accrual_rprtg_pkg.C_MPA_COLS_QUERY :=
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
    xla_mpa_accrual_rprtg_pkg.C_MPA_FROM_QUERY :=
                      ' FROM xla_ae_headers             xah
                            ,xla_ae_lines               xal
                            ,xla_events                 xae
                            ,xla_event_types_tl         xet
                            ,xla_transaction_entities   ent
                            ,xla_event_classes_tl       xec
                            ,xla_gl_ledgers_v           gld
                            ,xla_product_rules_tl       xpr
                            ,xla_lookups                lk1
                            ,xla_lookups                lk2
                            ,xla_lookups                lk3
                            ,fnd_document_sequences     seq
                            ,fun_seq_versions           seqv2
                            ,fun_seq_versions           seqv3 ';

    xla_mpa_accrual_rprtg_pkg.C_MPA_WHR_QUERY :=
                               ' WHERE xal.application_id         = xah.application_id
                                   AND xal.ae_header_id           = xah.ae_header_id
                                   AND xae.application_id         = xah.application_id
                                   AND xae.event_id               = xah.event_id
                                   AND xec.application_id         = xet.application_id
                                   AND ent.application_id         = xet.application_id
                                   AND ent.entity_code            = xet.entity_code
                                   AND xah.entity_id              = ent.entity_id
                                   AND gld.ledger_id              = xah.ledger_id
                                   AND xec.event_class_code       = xet.event_class_code
                                   AND xec.language               = USERENV(''LANG'')
                                   AND xet.application_id         = xae.application_id
                                   AND xet.event_type_code        = xae.event_type_code
                                   AND xet.language               = USERENV(''LANG'')
                                   AND xpr.amb_context_code       = xah.amb_context_code
                                   AND xpr.application_id         = xah.application_id
                                   AND xpr.product_rule_type_code = xah.product_rule_type_code
                                   AND xpr.product_rule_code      = xah.product_rule_code
                                   AND xpr.language               = USERENV(''LANG'')
                                   AND lk1.lookup_type            = ''XLA_ACCOUNTING_ENTRY_STATUS''
                                   AND lk1.lookup_code            = xah.accounting_entry_status_code
                                   AND lk2.lookup_type            = ''XLA_ACCOUNTING_CLASS''
                                   AND lk2.lookup_code            = xal.accounting_class_code
                                   AND lk3.lookup_type            = ''XLA_MPA_TYPE''
                                   AND lk3.lookup_code            = decode(xal.mpa_accrual_entry_flag,''Y'',''M'',''R'')
                                   AND seq.doc_sequence_id(+)     = xah.doc_sequence_id
                                   AND seqv2.seq_version_id(+)    = xah.completion_acct_seq_version_id
                                   AND seqv3.seq_version_id(+)    = xah.close_acct_seq_version_id
                                   AND ((xal.mpa_accrual_entry_flag = ''Y'' AND
                                         xah.accounting_entry_status_code in (''D'',''F''))
                                    OR (xah.parent_ae_header_id IS NOT NULL AND xah.parent_ae_line_num IS NOT NULL)) ';

    xla_mpa_accrual_rprtg_pkg.C_ACCRUAL_RVRSL_COLS_QUERY :=
                        ' SELECT  xah.event_id                  event_id
                                 ,xec.name                      event_class
                                 ,xet.name                      event_type
                                 ,xae.event_number              event_number
                                 ,to_char(xae.event_date,''YYYY-MM-DD'')
                                                                event_date
                                 ,xah.ae_header_id              ae_header_id
                                 ,gld.name                      ledger
                                 ,TO_CHAR(xah.accounting_date,''YYYY-MM-DD'')
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

    xla_mpa_accrual_rprtg_pkg.C_ACCRUAL_RVRSL_FROM_QUERY :=
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
                               ,xla_subledgers             xls ';

    xla_mpa_accrual_rprtg_pkg.C_ACCRUAL_RVRSL_WHR_QUERY :=
                        ' WHERE xec.application_id          = xet.application_id
                            AND xec.event_class_code        = xet.event_class_code
                            AND xec.language                = USERENV(''LANG'')
                            AND xet.application_id          = xae.application_id
                            AND xet.event_type_code         = xae.event_type_code
                            AND xet.language                = USERENV(''LANG'')
                            AND ent.application_id          = xet.application_id
                            AND ent.entity_code             = xet.entity_code
                            AND xah.entity_id               = ent.entity_id
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
                            AND xls.application_id          = xah.application_id
                            AND ((xah.accrual_reversal_flag = ''Y'' AND
                                  xah.accounting_entry_status_code in (''D'',''F''))
                             OR (xah.parent_ae_header_id    IS NOT NULL
                            AND xah.parent_ae_line_num     IS NULL)) ';

    xla_mpa_accrual_rprtg_pkg.C_ERRORS_COLS_QUERY :=
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
                                         ,err.message_number         error_number
                                         ,err.encoded_msg            error_message ';

    xla_mpa_accrual_rprtg_pkg.C_ERRORS_FROM_QUERY :=
                          ' FROM xla_ae_headers             xah
                                ,xla_events                 xae
                                ,xla_event_types_tl         xet
                                ,xla_event_classes_tl       xec
                                ,xla_gl_ledgers_v           gld
                                ,xla_transaction_entities   ent
                                ,xla_product_rules_tl       xpr
                                ,xla_lookups                lk1
                                ,xla_lookups                lk2
                                ,xla_lookups                lk3
                                ,xla_ae_lines               xal
                                ,fnd_document_sequences     seq
                                ,fun_seq_versions           seqv2
                                ,fun_seq_versions           seqv3
                                ,xla_subledgers             xls
                                ,xla_accounting_errors      err ';

    xla_mpa_accrual_rprtg_pkg.C_ERRORS_WHR_QUERY :=
                             ' WHERE xec.application_id         = xet.application_id
                                 AND xec.event_class_code       = xet.event_class_code
                                 AND xec.language               = USERENV(''LANG'')
                                 AND xet.application_id         = xae.application_id
                                 AND xet.event_type_code        = xae.event_type_code
                                 AND xet.language               = USERENV(''LANG'')
                                 AND ent.application_id         = xet.application_id
                                 AND ent.entity_code            = xet.entity_code
                                 AND xah.entity_id              = ent.entity_id
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
                                 AND  xal.application_id(+)     = err.application_id
                                 AND xal.ae_header_id(+)        = err.ae_header_id
                                 AND xal.ae_line_num(+)         = err.ae_line_num
                                 AND xls.application_id         = xah.application_id
                                 AND xah.accounting_entry_status_code NOT IN (''D'',''F'') ';

    -- User Transaction Identifiers available only when Report Run in Detail Mode.
    -- This to avoid performance issues when run Summary Mode: Bug 8977840
    IF xla_mpa_accrual_rprtg_pkg.p_report = 'D' THEN
       	xla_mpa_accrual_rprtg_pkg.p_trx_identifiers := get_transaction_id(xla_mpa_accrual_rprtg_pkg.p_application_id
                                                                     ,xla_mpa_accrual_rprtg_pkg.p_ledger_id
                                                                     ,xla_mpa_accrual_rprtg_pkg.p_end_date
                                                                     ,xla_mpa_accrual_rprtg_pkg.p_process_category_code)
                                                   		||' USERIDS ';
    ELSE
     	xla_mpa_accrual_rprtg_pkg.p_trx_identifiers := ',NULL  USERIDS '; -- added for Bug 8977840
    END IF ;

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
                'xla_mpa_accrual_rprtg_pkg.build_xml_sql');
END build_xml_sql;


FUNCTION run_report
       (p_source_application_id           IN NUMBER
       ,p_application_id                  IN NUMBER
       ,p_ledger_id                       IN NUMBER
       ,p_process_category                IN VARCHAR2
       ,p_end_date                        IN DATE
       ,p_accounting_flag                 IN VARCHAR2
       ,p_accounting_mode                 IN VARCHAR2
       ,p_errors_only_flag                IN VARCHAR2
       ,p_transfer_flag                   IN VARCHAR2
       ,p_gl_posting_flag                 IN VARCHAR2
       ,p_gl_batch_name                   IN VARCHAR2
       ,p_accounting_batch_id             IN NUMBER) RETURN NUMBER IS

       l_log_module                    VARCHAR2(240);
       l_request_id                    NUMBER;
       l_source_application            gl_je_sources_tl.user_je_source_name%TYPE;
       l_je_source                     gl_je_sources_tl.user_je_source_name%TYPE;
       l_ledger                        VARCHAR2(30);
       l_process_category_name         VARCHAR2(80);
       l_create_accounting_flag        VARCHAR2(80);
       l_errors_only_flag              VARCHAR2(80);
       l_report_style                  VARCHAR2(80);
       l_transfer_to_gl_flag           VARCHAR2(80);
       l_post_in_gl_flag               VARCHAR2(80);

BEGIN

       IF g_log_enabled THEN
          l_log_module := C_DEFAULT_MODULE||'.run_report';
       END IF;

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace('run_report.Begin',C_LEVEL_PROCEDURE,l_log_module);
       END IF;

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace('p_source_application_id = '|| to_char(p_source_application_id),
                C_LEVEL_STATEMENT, l_log_module);
          trace('p_application_id = '|| to_char(p_application_id),
                C_LEVEL_STATEMENT, l_log_module);
          trace('p_ledger_id = '|| to_char(p_ledger_id),
                C_LEVEL_STATEMENT, l_log_module);
          trace('p_process_category_code = '||to_char(p_process_category_code),
                C_LEVEL_STATEMENT, l_log_module);
          trace('p_end_date  = '||to_char(p_end_date,'DD-MON-YYYY'),
                C_LEVEL_STATEMENT,l_log_module);
          trace('p_accounting_flag = '|| p_accounting_flag,
               C_LEVEL_STATEMENT, l_log_module);
          trace('p_accounting_mode = '|| p_accounting_mode,
               C_LEVEL_STATEMENT, l_log_module);
          trace('p_errors_only_flag = '|| p_errors_only_flag,
               C_LEVEL_STATEMENT, l_log_module);
          trace('p_transfer_to_gl_flag = '|| to_char(p_transfer_flag),
                C_LEVEL_STATEMENT, l_log_module);
          trace('p_post_in_gl_flag = '|| to_char(p_gl_posting_flag),
                C_LEVEL_STATEMENT, l_log_module);
          trace('p_gl_batch_name = '|| to_char(p_gl_batch_name),
                C_LEVEL_STATEMENT, l_log_module);
          trace('p_accounting_batch_id = '|| to_char(p_accounting_batch_id),
                C_LEVEL_STATEMENT, l_log_module);
          trace('xla_mpa_accrual_rprtg_pkg.p_report = '|| to_char (xla_mpa_accrual_rprtg_pkg.p_report),
                C_LEVEL_STATEMENT, l_log_module);
        END IF;

        SELECT name
          INTO l_ledger
          FROM gl_ledgers
         WHERE ledger_id = p_ledger_id;

        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
           trace('l_ledger_name '||l_ledger
             ,C_LEVEL_PROCEDURE,l_Log_module);
        END IF;

        BEGIN

           SELECT meaning
             INTO l_create_accounting_flag
             FROM xla_lookups
            WHERE lookup_type = 'XLA_YES_NO'
              AND lookup_code = p_accounting_flag;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
               NULL;
        END;

        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
           trace('l_create_accounting_flag '||l_create_accounting_flag
             ,C_LEVEL_PROCEDURE,l_Log_module);
        END IF;

       IF p_source_application_id IS NOT NULL THEN
           SELECT gjst.user_je_source_name
             INTO l_source_application
             FROM xla_subledgers xls, gl_je_sources_tl gjst
            WHERE xls.application_id = p_source_application_id
              AND xls.je_source_name = gjst.je_source_name
              AND gjst.language = USERENV('LANG');
       END IF;

       SELECT gjst.user_je_source_name
         INTO l_je_source
         FROM xla_subledgers xls, gl_je_sources_tl gjst
        WHERE xls.application_id = p_application_id
          AND xls.je_source_name = gjst.je_source_name
          AND gjst.language = USERENV('LANG');

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace('l_source_application '||l_source_application
            ,C_LEVEL_PROCEDURE,l_Log_module);
       END IF;

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace('l_je_source '||l_je_source
            ,C_LEVEL_PROCEDURE,l_Log_module);
       END IF;

       IF p_process_category is NOT NULL THEN

          select name
            into l_process_category_name
        from XLA_EVENT_CLASS_GRPS_VL
       where application_id         = p_application_id
         and event_class_group_code = p_process_category;
       END IF;

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace('l_process_category_name '||l_process_category_name
            ,C_LEVEL_PROCEDURE,l_Log_module);
       END IF;

       IF xla_mpa_accrual_rprtg_pkg.p_report IS NULL THEN
          -- REPORT STYLE copied from Create Accounting Request's Report Style : bug# 8977840
          xla_mpa_accrual_rprtg_pkg.p_report := XLA_CREATE_ACCT_RPT_PVT.p_report_style ;
       END IF ;

       BEGIN
       	 SELECT meaning
         INTO l_report_style
         FROM xla_lookups
         WHERE lookup_code = xla_mpa_accrual_rprtg_pkg.p_report --  'D' -- commented for  bug# 8977840
         AND lookup_type = 'XLA_REPORT_LEVEL'; --Changed from XLA_ACCT_TRANSFER_MODE to XLA_REPORT_LEVEL bug8977840 as its Report Style and not Accounting
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               NULL;
       END;

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace('l_report_style '||l_report_style
            ,C_LEVEL_PROCEDURE,l_Log_module);
       END IF;

       BEGIN
          SELECT meaning
            INTO l_errors_only_flag
            FROM xla_lookups
           WHERE lookup_code = p_errors_only_flag
             AND lookup_type = 'XLA_YES_NO';

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               NULL;
       END;


       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace('l_errors_only_flag '||l_errors_only_flag
            ,C_LEVEL_PROCEDURE,l_Log_module);
       END IF;

       BEGIN

          SELECT meaning
            INTO l_transfer_to_gl_flag
            FROM xla_lookups
           WHERE lookup_type    = 'XLA_YES_NO'
             AND lookup_code    = p_transfer_flag;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               NULL;
       END;

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace('l_transfer_to_gl_flag '||l_transfer_to_gl_flag
            ,C_LEVEL_PROCEDURE,l_Log_module);
       END IF;

       BEGIN
          SELECT MEANING
            INTO l_post_in_gl_flag
            FROM xla_lookups
           WHERE lookup_type    = 'XLA_YES_NO'
             AND lookup_code    = p_gl_posting_flag;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               NULL;
       END;
       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace('l_post_in_gl_flag '||l_post_in_gl_flag
            ,C_LEVEL_PROCEDURE,l_Log_module);
       END IF;

       l_request_id := fnd_request.submit_request
                                  (application     => 'XLA'
                                  ,program         => 'XLARPMPX'
                                  ,description     => NULL
                                  ,start_time      => NULL
                                  ,sub_request     => FALSE
                                  ,argument1       => p_application_id
                                  ,argument2       => l_je_source
                                  ,argument3       => p_source_application_id
                                  ,argument4       => l_source_application
                                  ,argument5       => 'Y'
                                  ,argument6       => p_ledger_id
                                  ,argument7       => l_ledger
                                  ,argument8       => p_process_category
                                  ,argument9       => l_process_category_name
                                  ,argument10      => to_char(p_end_date,'YYYY/MM/DD HH24:MI:SS')
                                  ,argument11      => p_accounting_flag
                                  ,argument12      => l_create_accounting_flag
                                  ,argument13      => 'Y'
                                  ,argument14      => p_accounting_mode
                                  ,argument15      => 'Y'
                                  ,argument16      => p_errors_only_flag
                                  ,argument17      => l_errors_only_flag
                                  ,argument18      => 'Y'
                                  ,argument19      => xla_mpa_accrual_rprtg_pkg.p_report -- 'D' --  bug# 8977840
                                  ,argument20      => l_report_style
                                  ,argument21      => p_transfer_flag
                                  ,argument22      => l_transfer_to_gl_flag
                                  ,argument23      => 'Y'
                                  ,argument24      => p_gl_posting_flag
                                  ,argument25      => l_post_in_gl_flag
                                  ,argument26      => p_gl_batch_name
                                  ,argument27      => p_accounting_batch_id);

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace('run_report.End',C_LEVEL_PROCEDURE,l_log_module);
       END IF;
       RETURN l_request_id;
   EXCEPTION
      WHEN OTHERS THEN
         -- trace mesg
         xla_exceptions_pkg.raise_message
            (p_location       => 'xla_mpa_accrual_rprtg_pkg.run_report ');

END run_report;


FUNCTION beforeReport  RETURN BOOLEAN IS
   l_log_module              VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
        l_log_module := C_DEFAULT_MODULE||'.beforeReport';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace('beforeReport.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace('p_source_application_id = '|| to_char(p_source_application_id),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_application_id = '|| to_char(p_application_id),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_ledger_id = '|| to_char(p_ledger_id),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_process_category_code = '|| to_char(p_process_category_code),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_end_date = '|| to_char(p_end_date,'DD-MON-YYYY'),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_create_accounting_flag = '|| to_char(p_create_accounting),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_accounting_mode = '|| to_char(p_accounting_mode),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_errors_only_flag = '|| to_char(p_errors_only),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_transfer_to_gl_flag = '|| to_char(p_transfer_to_gl),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_post_in_gl_flag = '|| to_char(p_post_in_gl),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_gl_batch_name = '|| p_gl_batch_name,
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_accounting_batch_id = '|| to_char(p_accounting_batch_id),
               C_LEVEL_STATEMENT, l_log_module);
    END IF;

    build_xml_sql;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('beforeReport.End'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location  => 'xla_mpa_accrual_rprtg_pkg.beforeReport ');

END beforeReport;

 BEGIN
      g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
      g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,MODULE     => C_DEFAULT_MODULE);

      IF NOT g_log_enabled  THEN
         g_log_level := C_LEVEL_LOG_DISABLED;
      END IF;
 END xla_mpa_accrual_rprtg_pkg;

/
