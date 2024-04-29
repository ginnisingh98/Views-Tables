--------------------------------------------------------
--  DDL for Package Body FUN_RECON_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RECON_RPT_PKG" AS
/* $Header: funrecrptb.pls 120.19.12010000.12 2010/01/08 06:13:02 srampure ship $ */

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================

TYPE t_rec IS RECORD
    (f1               VARCHAR2(80)
    ,f2               VARCHAR2(80));
TYPE t_array IS TABLE OF t_rec INDEX BY BINARY_INTEGER;


C_FUN_GET_ACCTS_QUERY CONSTANT VARCHAR2(3000) :=
'SELECT /*+ NO_MERGE Leading(gl2,fia2,fia1,gl1) */
        distinct gl1.legal_entity_id  TRANSACTING_LE_ID
       ,gl1.LEGAL_ENTITY_NAME         TRANSACTING_LE
       ,gl1.ledger_id                 TRANSACTING_LEDGER_ID
       ,gl1.ledger_name               TRANSACTING_LEDGER
       ,fia1.to_le_id                 TRADING_PARTNER_LE_ID
       ,gl2.LEGAL_ENTITY_NAME         TRADING_PARTNER_LE
       ,gl2.ledger_id                 TRADING_PARTNER_LEDGER_ID
       ,gl2.ledger_name               TRADING_PARTNER_LEDGER
       ,fia1.ccid                     CCID
       ,fia1.type                     ACCT_TYPE
       ,gl1.accounted_period_type     ACCOUNTED_PERIOD_TYPE
       ,gl1.period_set_name           PERIOD_SET_NAME
FROM  fun_inter_accounts_v fia1,
      fun_inter_accounts_v fia2,
      gl_ledger_le_v     gl1,
      gl_ledger_le_v     gl2
WHERE fia1.ledger_id      = gl1.ledger_id
AND   fia1.from_le_id     = gl1.legal_entity_id
AND   fia1.to_le_id       = fia2.from_le_id
AND   fia1.from_le_id     = fia2.to_le_id
AND   fia2.ledger_id      = gl2.ledger_id
AND   fia2.from_le_id     = gl2.legal_entity_id';

-- In the following query, fia1 relates to the receivables account side
-- of the transacting ledger and fia2 relates to the payables account side
-- of the trading ledger
-- The same query when passed with different parameters will be used such
-- that fia1 relates to the receivables account side of the trading ledger
-- fia2 relates to the payables account side of the transacting ledger
-- Note below is actually a subquery for gl balances balances. This is used
-- within C_FUN_GL_BALANCE_QUERY1 (which is the full query)
C_FUN_GL_BALANCE_QUERY CONSTANT VARCHAR2(30000) :=
'
SELECT  distinct gl1.legal_entity_id  TRANSACTING_LE_ID
       ,gl1.LEGAL_ENTITY_NAME         TRANSACTING_LE
       ,gl1.ledger_id                 TRANSACTING_LEDGER_ID
       ,gl1.ledger_name               TRANSACTING_LEDGER
       ,fia1.to_le_id                 TRADING_PARTNER_LE_ID
       ,gl2.LEGAL_ENTITY_NAME         TRADING_PARTNER_LE
       ,gl2.ledger_id                 TRADING_PARTNER_LEDGER_ID
       ,gl2.ledger_name               TRADING_PARTNER_LEDGER
       ,glb1.currency_code            TRANSACTION_CURRENCY
       ,glb1.period_name              TRANSACTING_PERIOD_NAME
       ,glp2.period_name              TRADING_PERIOD_NAME
FROM  fun_inter_accounts_v fia1,
      gl_balances        glb1,
      gl_ledger_le_v     gl1,
      gl_periods         glp1,
      fun_inter_accounts_v fia2,
      gl_ledger_le_v     gl2,
      gl_periods         glp2
WHERE fia1.ledger_id      = glb1.ledger_id
AND   fia1.ccid           = glb1.code_combination_id
AND   fia1.type           = ''R''
AND   fia1.ledger_id      = gl1.ledger_id
AND   fia1.from_le_id     = gl1.legal_entity_id
AND   fia2.type           = ''P''
AND   fia1.to_le_id       = fia2.from_le_id
AND   fia1.from_le_id     = fia2.to_le_id
AND   glb1.actual_flag    = ''A''
AND   fia2.ledger_id      = gl2.ledger_id
AND   fia2.from_le_id     = gl2.legal_entity_id
AND   gl1.period_set_name = glp1.period_set_name
AND   glp1.period_type    = gl1.accounted_period_type
AND   glp1.period_name    = glb1.period_name
AND   gl2.period_set_name = glp2.period_set_name
AND   glp2.period_type    = gl2.accounted_period_type
AND (glb1.translated_flag = ''R'' OR glb1.translated_flag is NULL)
';

C_ADD_CURRENCY_COLS     CONSTANT VARCHAR2(30000) :=
' ,LTRIM(TO_CHAR(gl_currency_api.convert_amount_sql (TRANSACTION_CURRENCY, :TO_CURR, fnd_date.canonical_to_date(:TO_DATE), :TYPE
  ,fun_recon_rpt_pkg.get_balance(''R'', ''BEGIN_BALANCE_DR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
  ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY)),''999999999999999999999.999999999999''))   AR_BEGIN_BALANCE_DR_ADD_CURR

  ,LTRIM(TO_CHAR (gl_currency_api.convert_amount_sql (TRANSACTION_CURRENCY, :TO_CURR, fnd_date.canonical_to_date(:TO_DATE), :TYPE
  ,fun_recon_rpt_pkg.get_balance(''R'', ''BEGIN_BALANCE_CR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
  ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY)),''999999999999999999999.999999999999''))   AR_BEGIN_BALANCE_CR_ADD_CURR

  ,LTRIM(TO_CHAR(gl_currency_api.convert_amount_sql (TRANSACTION_CURRENCY, :TO_CURR, fnd_date.canonical_to_date(:TO_DATE), :TYPE
  ,fun_recon_rpt_pkg.get_balance(''P'', ''BEGIN_BALANCE_DR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
  ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY)),''999999999999999999999.999999999999''))   AP_BEGIN_BALANCE_DR_ADD_CURR

  ,LTRIM(TO_CHAR(gl_currency_api.convert_amount_sql (TRANSACTION_CURRENCY, :TO_CURR, fnd_date.canonical_to_date(:TO_DATE), :TYPE
  ,fun_recon_rpt_pkg.get_balance(''P'', ''BEGIN_BALANCE_CR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
  ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY)),''999999999999999999999.999999999999''))   AP_BEGIN_BALANCE_CR_ADD_CURR

  ,LTRIM(TO_CHAR(gl_currency_api.convert_amount_sql (TRANSACTION_CURRENCY, :TO_CURR, fnd_date.canonical_to_date(:TO_DATE), :TYPE
  ,fun_recon_rpt_pkg.get_balance(''R'', ''PERIOD_NET_DR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
  ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY)),''999999999999999999999.999999999999''))      AR_PERIOD_NET_DR_ADD_CURR

  ,LTRIM(TO_CHAR(gl_currency_api.convert_amount_sql (TRANSACTION_CURRENCY, :TO_CURR, fnd_date.canonical_to_date(:TO_DATE), :TYPE
  ,fun_recon_rpt_pkg.get_balance(''R'', ''PERIOD_NET_CR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
  ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY)),''999999999999999999999.999999999999''))      AR_PERIOD_NET_CR_ADD_CURR

  ,LTRIM(TO_CHAR(gl_currency_api.convert_amount_sql (TRANSACTION_CURRENCY, :TO_CURR, fnd_date.canonical_to_date(:TO_DATE), :TYPE
  ,fun_recon_rpt_pkg.get_balance(''P'', ''PERIOD_NET_DR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
  ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY)),''999999999999999999999.999999999999''))      AP_PERIOD_NET_DR_ADD_CURR

  ,LTRIM(TO_CHAR(gl_currency_api.convert_amount_sql (TRANSACTION_CURRENCY, :TO_CURR, fnd_date.canonical_to_date(:TO_DATE), :TYPE
  ,fun_recon_rpt_pkg.get_balance(''P'', ''PERIOD_NET_CR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
  ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY)),''999999999999999999999.999999999999''))      AP_PERIOD_NET_CR_ADD_CURR
 ';


C_FUN_GL_BALANCE_QUERY1 CONSTANT VARCHAR2(30000) :=
'
SELECT  TRANSACTING_LE_ID
       ,TRANSACTING_LE
       ,TRANSACTING_LEDGER_ID
       ,TRANSACTING_LEDGER
       ,TRADING_PARTNER_LE_ID
       ,TRADING_PARTNER_LE
       ,TRADING_PARTNER_LEDGER_ID
       ,TRADING_PARTNER_LEDGER
       ,TRANSACTION_CURRENCY
       ,TRANSACTING_PERIOD_NAME
       ,TRADING_PERIOD_NAME
       ,LTRIM(TO_CHAR(fun_recon_rpt_pkg.get_balance(''R'', ''BEGIN_BALANCE_DR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
           ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY),''999999999999999999999.999999999999''))    AR_BEGIN_BALANCE_DR

       ,LTRIM(TO_CHAR(fun_recon_rpt_pkg.get_balance(''R'', ''BEGIN_BALANCE_CR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
           ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY),''999999999999999999999.999999999999''))    AR_BEGIN_BALANCE_CR

       ,LTRIM(TO_CHAR(fun_recon_rpt_pkg.get_balance(''R'', ''BEGIN_BALANCE_CR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
           ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY),''999999999999999999999.999999999999''))    AP_BEGIN_BALANCE_DR

       ,LTRIM(TO_CHAR(fun_recon_rpt_pkg.get_balance(''P'', ''BEGIN_BALANCE_CR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
           ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY),''999999999999999999999.999999999999''))    AP_BEGIN_BALANCE_CR

       ,LTRIM(TO_CHAR(fun_recon_rpt_pkg.get_balance(''R'', ''PERIOD_NET_DR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
           ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY),''999999999999999999999.999999999999''))       AR_PERIOD_NET_DR

       ,LTRIM(TO_CHAR(fun_recon_rpt_pkg.get_balance(''R'', ''PERIOD_NET_CR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
           ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY),''999999999999999999999.999999999999''))       AR_PERIOD_NET_CR

       ,LTRIM(TO_CHAR(fun_recon_rpt_pkg.get_balance(''P'', ''PERIOD_NET_DR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
           ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY),''999999999999999999999.999999999999''))       AP_PERIOD_NET_DR

       ,LTRIM(TO_CHAR(fun_recon_rpt_pkg.get_balance(''P'', ''PERIOD_NET_CR'', TRANSACTING_LEDGER_ID, TRANSACTING_LE_ID, TRANSACTING_PERIOD_NAME
           ,TRADING_PARTNER_LEDGER_ID, TRADING_PARTNER_LE_ID, TRADING_PERIOD_NAME, TRANSACTION_CURRENCY),''999999999999999999999.999999999999''))       AP_PERIOD_NET_CR

$additional_currency_columns$

FROM
(
    $sub_query$
 )  ';

C_FUN_JELINES_SLA_QUERY     CONSTANT VARCHAR2(30000) :=
'SELECT  /*+ Leading(fun_act,aeh,xle) index (aeh XLA_AE_HEADERS_N5)*/
          fun_act.TRANSACTING_LE_ID         TRANS_LE_ID
         ,fun_act.TRANSACTING_LE            TRANS_LE
         ,fun_act.TRADING_PARTNER_LE_ID     TRAD_LE_ID
         ,fun_act.TRADING_PARTNER_LE        TRAD_LE
         ,fun_act.TRANSACTING_LEDGER        TRANSACTING_LEDGER
         ,fun_act.TRANSACTING_LEDGER_ID     LEDGER_ID
         ,''SLA''                           SOURCE
         ,fun_act.ACCT_TYPE                ACCOUNT_TYPE
	 ,aeh.accounting_date               GL_DATE
         ,aeh.creation_date                 CREATION_DATE
         ,aeh.last_update_date              LAST_UPDATE_DATE
         ,aeh.gl_transfer_date              GL_TRANSFER_DATE
         ,aeh.reference_date                REFERENCE_DATE
         ,aeh.completed_date                COMPLETED_DATE
         ,ent.transaction_number            TRANSACTION_NUMBER
         ,xle.transaction_date              TRANSACTION_DATE
         ,aeh.doc_sequence_value            DOCUMENT_SEQUENCE_NUMBER
         ,aeh.application_id                APPLICATION_ID
         ,fap.application_name              APPLICATION_NAME
         ,aeh.ae_header_id                  HEADER_ID
         ,aeh.description                   HEADER_DESCRIPTION
         ,xlk1.meaning                      FUND_STATUS
         ,gjct.user_je_category_name        JE_CATEGORY_NAME
         ,gjst.user_je_source_name          JE_SOURCE_NAME
         ,ae_line_num                       SLA_LINE_NUMBER
         ,xle.event_id                      EVENT_ID
         ,xle.event_date                    EVENT_DATE
         ,xle.event_number                  EVENT_NUMBER
         ,xet.event_class_code              EVENT_CLASS_CODE
         ,xect.NAME                         EVENT_CLASS_NAME
         ,aeh.event_type_code               EVENT_TYPE_CODE
         ,xett.NAME                         EVENT_TYPE_NAME
         ,gjb.NAME                          GL_BATCH_NAME
         ,gjb.posted_date                   POSTED_DATE
         ,gjh.NAME                          GL_JE_NAME
         ,gjh.je_source                     JE_SOURCE_CODE
         ,gjh.je_header_id                  JE_HEADER_ID
         ,gjl.je_line_num                   GL_LINE_NUMBER
         ,ael.displayed_line_number         LINE_NUMBER
         ,ael.accounting_class_code         ACCOUNTING_CLASS_CODE
         ,xlk2.meaning                      ACCOUNTING_CLASS_NAME
         ,ael.description                   LINE_DESCRIPTION
         ,ael.currency_code                 ENTERED_CURRENCY
         ,LTRIM(TO_CHAR(ael.currency_conversion_rate,''999999999999999999999.999999999999''))      CONVERSION_RATE
         ,ael.currency_conversion_date      CONVERSION_RATE_DATE
         ,ael.currency_conversion_type      CONVERSION_RATE_TYPE_CODE
         ,gdct.user_conversion_type         CONVERSION_RATE_TYPE
         ,LTRIM(TO_CHAR(ael.entered_dr,''999999999999999999999.999999999999''))                    ENTERED_DR
         ,LTRIM(TO_CHAR(ael.entered_cr,''999999999999999999999.999999999999''))                    ENTERED_CR
         ,LTRIM(TO_CHAR(ael.unrounded_accounted_dr,''999999999999999999999.999999999999''))        UNROUNDED_ACCOUNTED_DR
         ,LTRIM(TO_CHAR(ael.unrounded_accounted_cr,''999999999999999999999.999999999999''))        UNROUNDED_ACCOUNTED_CR
         ,LTRIM(TO_CHAR(ael.accounted_dr,''999999999999999999999.999999999999''))                  ACCOUNTED_DR
         ,LTRIM(TO_CHAR(ael.accounted_cr ,''999999999999999999999.999999999999''))                 ACCOUNTED_CR
         ,LTRIM(TO_CHAR(ael.statistical_amount ,''999999999999999999999.999999999999''))            STATISTICAL_AMOUNT
         ,ael.jgzz_recon_ref                RECONCILIATION_REFERENCE
         ,ael.attribute_category            ATTRIBUTE_CATEGORY
         ,ael.attribute1                    ATTRIBUTE1
         ,ael.attribute2                    ATTRIBUTE2
         ,ael.attribute3                    ATTRIBUTE3
         ,ael.attribute4                    ATTRIBUTE4
         ,ael.attribute5                    ATTRIBUTE5
         ,ael.attribute6                    ATTRIBUTE6
         ,ael.attribute7                    ATTRIBUTE7
         ,ael.attribute8                    ATTRIBUTE8
         ,ael.attribute9                    ATTRIBUTE9
         ,ael.attribute10                   ATTRIBUTE10
         ,ael.attribute11                   ATTRIBUTE11
         ,ael.attribute12                   ATTRIBUTE12
         ,ael.attribute13                   ATTRIBUTE13
         ,ael.attribute14                   ATTRIBUTE14
         ,ael.attribute15                   ATTRIBUTE15
         ,ael.code_combination_id           CODE_COMBINATION_ID
         ,fun_trx_entry_util.get_concatenated_account(ael.code_combination_id ) ACCOUNT
         ,ael.ae_header_id||''-''||ael.ae_line_num EXPAND_ID
         ,nvl(xsrc.application_id, -1)      DRILLDOWN_APP_ID
FROM     xla_ae_headers                   aeh
        ,xla_ae_lines                     ael
        ,xla_lookups                      xlk1
        ,xla_lookups                      xlk2
        ,xla_events                       xle
        ,xla_event_types_b                xet
        ,xla_event_classes_tl             xect
        ,xla_event_types_tl               xett
        ,xla_transaction_entities         ent
        ,fnd_application_tl               fap
        ,gl_je_categories_tl              gjct
        ,gl_je_sources_tl                 gjst
        ,gl_daily_conversion_types        gdct
        ,gl_import_references             gir
        ,gl_je_lines                      gjl
        ,gl_je_headers                    gjh
        ,gl_je_batches                    gjb
        ,gl_periods                       glp
        ,xla_subledgers                   xsrc
	,gl_ledgers                       gl
        , ($get_accounts_query$) fun_act
WHERE    aeh.accounting_entry_status_code   = ''F''
  AND    aeh.gl_transfer_status_code        = ''Y''
  AND    ael.ae_header_id                   = aeh.ae_header_id
  AND    ael.application_id                 = aeh.application_id
  AND    xsrc.application_id                = aeh.application_id
  AND    xlk1.lookup_type(+)                = ''XLA_FUNDS_STATUS''
  AND    xlk1.lookup_code(+)                = aeh.funds_status_code
  AND    xlk2.lookup_type                   = ''XLA_ACCOUNTING_CLASS''
  AND    xlk2.lookup_code                   = ael.accounting_class_code
  AND    xle.event_id                       = aeh.event_id
  AND    xet.application_id                 = aeh.application_id
  AND    xet.event_type_code                = aeh.event_type_code
  AND    xect.application_id                = xet.application_id
  AND    xect.entity_code                   = xet.entity_code
  AND    xect.event_class_code              = xet.event_class_code
  AND    xect.LANGUAGE                      = USERENV(''LANG'')
  AND    xett.application_id                = xet.application_id
  AND    xett.entity_code                   = xet.entity_code
  AND    xett.event_class_code              = xet.event_class_code
  AND    xett.event_type_code               = xet.event_type_code
  AND    xett.LANGUAGE                      = USERENV(''LANG'')
  AND    xle.application_id                 = aeh.application_id
  AND    ent.entity_id                      = xle.entity_id
  AND    ent.application_id                 = xle.application_id
  AND    fap.application_id                 = aeh.application_id
  AND    fap.LANGUAGE                       = USERENV(''LANG'')
  AND    gdct.conversion_type(+)            = ael.currency_conversion_type
  AND    gir.gl_sl_link_id                  = ael.gl_sl_link_id
  AND    gir.gl_sl_link_table               = ael.gl_sl_link_table
  AND    gjl.je_header_id                   = gir.je_header_id
  AND    gjl.je_line_num                    = gir.je_line_num
  AND    gjh.je_header_id                   = gir.je_header_id
  AND    gjb.je_batch_id                    = gir.je_batch_id
  AND    gjb.status                         = ''P''
  AND    gjct.je_category_name              = gjh.je_category
  AND    gjct.LANGUAGE                      = USERENV(''LANG'')
  AND    gjst.je_source_name                = gjh.je_source
  AND    gjst.LANGUAGE                      = USERENV(''LANG'')
  AND    aeh.balance_type_code              = ''A''
  AND    ael.code_combination_id            = fun_act.ccid
  AND    aeh.ledger_id                      = fun_act.TRANSACTING_LEDGER_ID
  AND    glp.period_set_name                = fun_act.period_set_name
  AND    glp.period_type                    = fun_act.accounted_period_type
  AND    gjl.ledger_id                      = gjh.ledger_id
  AND    glp.period_name                    = aeh.period_name
  AND    glp.period_name                    = gjh.period_name||''''
  AND    xsrc.je_source_name (+)            = gjh.je_source
  AND    gjh.ledger_id = gl.ledger_id
  AND    gl.ledger_category_code = ''PRIMARY''';
-- Bug: 7713462

C_SLA_UNMATCHED_QUERY     CONSTANT VARCHAR2(30000) :=
'SELECT   glv.legal_entity_id               TRANS_LE_ID
         ,glv.LEGAL_ENTITY_NAME             TRANS_LE
         ,fia.to_le_id                      TRAD_LE_ID
         ,fun_recon_rpt_pkg.get_legal_entity(fia.to_le_Id)  TRAD_LE
         ,glv.ledger_name                   TRANSACTING_LEDGER
         ,glv.ledger_id                     LEDGER_ID
         ,''SLA''                           SOURCE
         ,fia.type                          ACCOUNT_TYPE
	   ,aeh.accounting_date               GL_DATE
         ,aeh.creation_date                 CREATION_DATE
         ,aeh.last_update_date              LAST_UPDATE_DATE
         ,aeh.gl_transfer_date              GL_TRANSFER_DATE
         ,aeh.reference_date                REFERENCE_DATE
         ,aeh.completed_date                COMPLETED_DATE
         ,ent.transaction_number            TRANSACTION_NUMBER
         ,xle.transaction_date              TRANSACTION_DATE
         ,aeh.application_id                APPLICATION_ID
         ,fap.application_name              APPLICATION_NAME
         ,aeh.ae_header_id                  HEADER_ID
         ,aeh.description                   HEADER_DESCRIPTION
         ,xlk1.meaning                      FUND_STATUS
         ,gjct.user_je_category_name        JE_CATEGORY_NAME
         ,gjst.user_je_source_name          JE_SOURCE_NAME
         ,ae_line_num                       SLA_LINE_NUMBER
         ,xle.event_id                      EVENT_ID
         ,xle.event_date                    EVENT_DATE
         ,xle.event_number                  EVENT_NUMBER
         ,xet.event_class_code              EVENT_CLASS_CODE
         ,xect.NAME                         EVENT_CLASS_NAME
         ,aeh.event_type_code               EVENT_TYPE_CODE
         ,xett.NAME                         EVENT_TYPE_NAME
         ,gjb.NAME                          GL_BATCH_NAME
         ,gjb.posted_date                   POSTED_DATE
         ,gjh.NAME                          GL_JE_NAME
         ,gjh.je_source                     JE_SOURCE_CODE
         ,gjh.je_header_id                  JE_HEADER_ID
         ,gjl.je_line_num                   GL_LINE_NUMBER
         ,ael.displayed_line_number         LINE_NUMBER
         ,ael.accounting_class_code         ACCOUNTING_CLASS_CODE
         ,xlk2.meaning                      ACCOUNTING_CLASS_NAME
         ,ael.description                   LINE_DESCRIPTION
         ,ael.currency_code                 ENTERED_CURRENCY
         ,LTRIM(TO_CHAR(ael.currency_conversion_rate,''999999999999999999999.999999999999''))      CONVERSION_RATE
         ,ael.currency_conversion_date      CONVERSION_RATE_DATE
         ,ael.currency_conversion_type      CONVERSION_RATE_TYPE_CODE
         ,gdct.user_conversion_type         CONVERSION_RATE_TYPE
         ,LTRIM(TO_CHAR(ael.entered_dr,''999999999999999999999.999999999999''))                    ENTERED_DR
         ,LTRIM(TO_CHAR(ael.entered_cr,''999999999999999999999.999999999999''))                    ENTERED_CR
         ,LTRIM(TO_CHAR(ael.unrounded_accounted_dr,''999999999999999999999.999999999999''))        UNROUNDED_ACCOUNTED_DR
         ,LTRIM(TO_CHAR(ael.unrounded_accounted_cr,''999999999999999999999.999999999999''))        UNROUNDED_ACCOUNTED_CR
         ,LTRIM(TO_CHAR(ael.accounted_dr,''999999999999999999999.999999999999''))                  ACCOUNTED_DR
         ,LTRIM(TO_CHAR(ael.accounted_cr ,''999999999999999999999.999999999999''))                 ACCOUNTED_CR
         ,LTRIM(TO_CHAR(ael.statistical_amount ,''999999999999999999999.999999999999''))            STATISTICAL_AMOUNT
         ,ael.jgzz_recon_ref                RECONCILIATION_REFERENCE
         ,ael.attribute_category            ATTRIBUTE_CATEGORY
         ,ael.attribute1                    ATTRIBUTE1
         ,ael.attribute2                    ATTRIBUTE2
         ,ael.attribute3                    ATTRIBUTE3
         ,ael.attribute4                    ATTRIBUTE4
         ,ael.attribute5                    ATTRIBUTE5
         ,ael.attribute6                    ATTRIBUTE6
         ,ael.attribute7                    ATTRIBUTE7
         ,ael.attribute8                    ATTRIBUTE8
         ,ael.attribute9                    ATTRIBUTE9
         ,ael.attribute10                   ATTRIBUTE10
         ,ael.attribute11                   ATTRIBUTE11
         ,ael.attribute12                   ATTRIBUTE12
         ,ael.attribute13                   ATTRIBUTE13
         ,ael.attribute14                   ATTRIBUTE14
         ,ael.attribute15                   ATTRIBUTE15
         ,ael.code_combination_id           CODE_COMBINATION_ID
         ,fun_trx_entry_util.get_concatenated_account(ael.code_combination_id ) ACCOUNT
         ,ael.ae_header_id||''-''||ael.ae_line_num EXPAND_ID
         ,nvl(xsrc.application_id, -1)      DRILLDOWN_APP_ID
FROM     xla_ae_headers                   aeh
        ,xla_ae_lines                     ael
        ,xla_lookups                      xlk1
        ,xla_lookups                      xlk2
        ,xla_events                       xle
        ,xla_event_types_b                xet
        ,xla_event_classes_tl             xect
        ,xla_event_types_tl               xett
        ,xla_transaction_entities         ent
        ,fnd_application_tl               fap
        ,gl_je_categories_tl              gjct
        ,gl_je_sources_tl                 gjst
        ,gl_daily_conversion_types        gdct
        ,gl_import_references             gir
        ,gl_je_lines                      gjl
        ,gl_je_headers                    gjh
        ,gl_je_batches                    gjb
        ,gl_ledger_le_v                   glv
        ,fun_inter_accounts_v               fia
        ,gl_periods                       glp
        ,xla_subledgers                   xsrc
	,gl_ledgers                       gl
WHERE    aeh.accounting_entry_status_code   = ''F''
  AND    aeh.gl_transfer_status_code        = ''Y''
  AND    ael.ae_header_id                   = aeh.ae_header_id
  AND    ael.application_id                 = aeh.application_id
  AND    xsrc.application_id                = aeh.application_id
  AND    xlk1.lookup_type(+)                = ''XLA_FUNDS_STATUS''
  AND    xlk1.lookup_code(+)                = aeh.funds_status_code
  AND    xlk2.lookup_type                   = ''XLA_ACCOUNTING_CLASS''
  AND    xlk2.lookup_code                   = ael.accounting_class_code
  AND    xle.event_id                       = aeh.event_id
  AND    xet.application_id                 = aeh.application_id
  AND    xet.event_type_code                = aeh.event_type_code
  AND    xect.application_id                = xet.application_id
  AND    xect.entity_code                   = xet.entity_code
  AND    xect.event_class_code              = xet.event_class_code
  AND    xect.LANGUAGE                      = USERENV(''LANG'')
  AND    xett.application_id                = xet.application_id
  AND    xett.entity_code                   = xet.entity_code
  AND    xett.event_class_code              = xet.event_class_code
  AND    xett.event_type_code               = xet.event_type_code
  AND    xett.LANGUAGE                      = USERENV(''LANG'')
  AND    ent.entity_id                      = xle.entity_id
  AND    ent.application_id                 = xle.application_id
  AND    xle.application_id                 = aeh.application_id
  AND    fap.application_id                 = aeh.application_id
  AND    fap.LANGUAGE                       = USERENV(''LANG'')
  AND    gdct.conversion_type(+)            = ael.currency_conversion_type
  AND    gir.gl_sl_link_id                  = ael.gl_sl_link_id
  AND    gir.gl_sl_link_table               = ael.gl_sl_link_table
  AND    gjl.je_header_id                   = gir.je_header_id
  AND    gjl.je_line_num                    = gir.je_line_num
  AND    gjh.je_header_id                   = gir.je_header_id
  AND    gjb.je_batch_id                    = gir.je_batch_id
  AND    gjb.status                         = ''P''
  AND    gjct.je_category_name              = gjh.je_category
  AND    gjct.LANGUAGE                      = USERENV(''LANG'')
  AND    gjst.je_source_name                = gjh.je_source
  AND    gjst.LANGUAGE                      = USERENV(''LANG'')
  AND    aeh.ledger_id                      = fia.ledger_id
  AND    aeh.balance_type_code              = ''A''
  AND    ael.code_combination_id            = fia.ccid
  AND    fia.ledger_id                      = glv.ledger_id
  AND    fia.from_le_id                     = glv.legal_entity_id
  AND    glv.period_set_name                = glp.period_set_name
  AND    glv.accounted_period_type          = glp.period_type
  AND    glp.period_name                    = aeh.period_name
  AND    glp.period_name                    = gjh.period_name ||''''
  AND    xsrc.je_source_name (+)            = gjh.je_source

  AND    glv.ledger_category_code = ''PRIMARY''

  AND    gjh.ledger_id = gl.ledger_id

  AND    gl.ledger_category_code = ''PRIMARY''';
  -- Bug: 7713462
  -- Bug: 6915872

C_FUN_JELINES_SUM_QUERY     CONSTANT VARCHAR2(30000) :=
'SELECT  fun_act.TRANSACTING_LE_ID          SRC_TRANS_LE_ID
        ,fun_act.TRANSACTING_LE             SRC_TRANS_LE
        ,fun_act.TRADING_PARTNER_LE_ID      SRC_TRAD_LE_ID
        ,fun_act.TRADING_PARTNER_LE         SRC_TRAD_LE
        ,fun_act.TRANSACTING_LEDGER         SRC_TRANS_LEDGER
        ,fun_act.TRANSACTING_LEDGER_ID      SRC_TRANS_LEDGER_ID
        ,gjct.user_je_category_name        JOURNAL_CATEGORY
        ,gjst.user_je_source_name          JOURNAL_SOURCE
        ,gjh.currency_code                 TRX_CURR
        ,gjl.period_name                   PERIOD_NAME
        ,LTRIM(TO_CHAR(NVL(sum(decode(fun_act.acct_type,''R'',(Nvl(gjl.entered_dr,0)), 0)),0),''999999999999999999999.999999999999''))   AR_ENTERED_DR
        ,LTRIM(TO_CHAR(NVL(sum(decode(fun_act.acct_type,''R'',(Nvl(gjl.entered_cr,0)), 0)),0),''999999999999999999999.999999999999''))   AR_ENTERED_CR
        ,LTRIM(TO_CHAR(NVL(sum(decode(fun_act.acct_type,''R'',(Nvl(gjl.accounted_dr,0)), 0)),0),''999999999999999999999.999999999999'')) AR_ACCOUNTED_DR
        ,LTRIM(TO_CHAR(NVL(sum(decode(fun_act.acct_type,''R'',(Nvl(gjl.accounted_cr,0)), 0)),0),''999999999999999999999.999999999999'')) AR_ACCOUNTED_CR
        ,LTRIM(TO_CHAR(NVL(sum(decode(fun_act.acct_type,''P'',(Nvl(gjl.entered_dr,0)), 0)),0),''999999999999999999999.999999999999''))   AP_ENTERED_DR
        ,LTRIM(TO_CHAR(NVL(sum(decode(fun_act.acct_type,''P'',(Nvl(gjl.entered_cr,0)), 0)),0),''999999999999999999999.999999999999''))   AP_ENTERED_CR
        ,LTRIM(TO_CHAR(NVL(sum(decode(fun_act.acct_type,''P'',(Nvl(gjl.accounted_dr,0)), 0)),0),''999999999999999999999.999999999999'')) AP_ACCOUNTED_DR
        ,LTRIM(TO_CHAR(NVL(sum(decode(fun_act.acct_type,''P'',(Nvl(gjl.accounted_cr,0)), 0)),0),''999999999999999999999.999999999999'')) AP_ACCOUNTED_CR
FROM    gl_je_categories_tl              gjct
       ,gl_je_sources_tl                 gjst
       ,gl_je_lines                      gjl
       ,gl_je_headers                    gjh
       ,gl_je_batches                    gjb
       ,gl_periods                       glp
       , ($get_accounts_query$) fun_act
WHERE   gjh.je_header_id                 = gjl.je_header_id
  AND   gjb.je_batch_id                  = gjh.je_batch_id
  AND   gjb.status                       = ''P''
  AND   gjct.je_category_name            = gjh.je_category
  AND   gjct.LANGUAGE                    = USERENV(''LANG'')
  AND   gjst.je_source_name              = gjh.je_source
  AND   gjst.language                    = USERENV(''LANG'')
  AND   gjh.actual_flag                  = ''A''
  AND   gjl.code_combination_id          = fun_act.ccid
  AND   gjl.ledger_id                    = fun_act.TRANSACTING_LEDGER_ID
  AND   glp.period_set_name              = fun_act.period_set_name
  AND   glp.period_type                  = fun_act.accounted_period_type
  AND   glp.period_name                  = gjl.period_name
  AND   gjl.ledger_id                    = gjh.ledger_id ';

C_SUM_UNMATCHED_QUERY     CONSTANT VARCHAR2(30000) :=
' SELECT SRC_TRANS_LE_ID
        ,SRC_TRANS_LE
        ,SRC_TRAD_LE_ID
        ,SRC_TRAD_LE
        ,SRC_TRANS_LEDGER
        ,JOURNAL_CATEGORY
        ,JOURNAL_SOURCE
        ,TRX_CURR
        ,PERIOD_NAME
        ,LTRIM(TO_CHAR(NVL(sum(decode(TYPE,''R'',(Nvl(ENTERED_DR,0)), 0)),0),''999999999999999999999.999999999999''))     AR_ENTERED_DR
        ,LTRIM(TO_CHAR(NVL(sum(decode(TYPE,''R'',(Nvl(ENTERED_CR,0)), 0)),0),''999999999999999999999.999999999999''))     AR_ENTERED_CR
        ,LTRIM(TO_CHAR(NVL(sum(decode(TYPE,''R'',(Nvl(ACCOUNTED_DR,0)), 0)),0),''999999999999999999999.999999999999''))   AR_ACCOUNTED_DR
        ,LTRIM(TO_CHAR(NVL(sum(decode(TYPE,''R'',(Nvl(ACCOUNTED_CR,0)), 0)),0),''999999999999999999999.999999999999''))   AR_ACCOUNTED_CR
        ,LTRIM(TO_CHAR(NVL(sum(decode(TYPE,''P'',(Nvl(ENTERED_DR,0)), 0)),0),''999999999999999999999.999999999999''))   AP_ENTERED_DR
        ,LTRIM(TO_CHAR(NVL(sum(decode(TYPE,''P'',(Nvl(ENTERED_CR,0)), 0)),0),''999999999999999999999.999999999999''))   AP_ENTERED_CR
        ,LTRIM(TO_CHAR(NVL(sum(decode(TYPE,''P'',(Nvl(ACCOUNTED_DR,0)), 0)),0),''999999999999999999999.999999999999'')) AP_ACCOUNTED_DR
        ,LTRIM(TO_CHAR(NVL(sum(decode(TYPE,''P'',(Nvl(ACCOUNTED_CR,0)), 0)),0),''999999999999999999999.999999999999'')) AP_ACCOUNTED_CR
FROM (

SELECT   glv.legal_entity_id               SRC_TRANS_LE_ID
        ,glv.LEGAL_ENTITY_NAME             SRC_TRANS_LE
        ,fia.to_le_id                      SRC_TRAD_LE_ID
        ,fun_recon_rpt_pkg.get_legal_entity(fia.to_le_Id)  SRC_TRAD_LE
        ,fia.ledger_id                     SRC_TRANS_LEDGER_ID
        ,glv.ledger_name                   SRC_TRANS_LEDGER
        ,gjct.user_je_category_name        JOURNAL_CATEGORY
        ,gjst.user_je_source_name          JOURNAL_SOURCE
        ,gjh.currency_code                 TRX_CURR
        ,gjl.period_name                   PERIOD_NAME
        ,gjl.entered_dr                    ENTERED_DR
        ,gjl.entered_cr                    ENTERED_CR
        ,gjl.accounted_dr                  ACCOUNTED_DR
        ,gjl.accounted_cr                  ACCOUNTED_CR
        ,fia.type                          TYPE
        ,glp.start_date                    START_DATE
        ,glp.end_date                      END_DATE
FROM    gl_je_categories_tl              gjct
       ,gl_je_sources_tl                 gjst
       ,gl_je_lines                      gjl
       ,gl_je_headers                    gjh
       ,gl_je_batches                    gjb
       ,gl_ledger_le_v                   glv
       ,fun_inter_accounts_v               fia
       ,gl_periods                       glp
WHERE   gjh.je_header_id                 = gjl.je_header_id
  AND   gjb.je_batch_id                  = gjh.je_batch_id
  AND   gjb.status                       = ''P''
  AND   gjct.je_category_name            = gjh.je_category
  AND   gjct.LANGUAGE                    = USERENV(''LANG'')
  AND   gjst.je_source_name              = gjh.je_source
  AND   gjst.language                    = USERENV(''LANG'')
  AND   gjl.ledger_id                    = fia.ledger_id
  AND   gjh.actual_flag                  = ''A''
  AND   gjl.code_combination_id          = fia.ccid
  AND   fia.ledger_id                    = glv.ledger_id
  AND   fia.from_le_id                   = glv.legal_entity_id
  AND   glv.period_set_name              = glp.period_set_name
  AND   glv.accounted_period_type        = glp.period_type
  AND   glp.period_name                  = gjl.period_name
  AND   (
         gjh.parent_je_header_id IS NOT NULL
         OR
         gjh.je_source NOT IN (SELECT DISTINCT je_source_name
                                  FROM xla_subledgers
                               WHERE  je_source_name <> ''Global Intercompany'')

        )

UNION

SELECT   glv.legal_entity_id               SRC_TRANS_LE_ID
        ,glv.LEGAL_ENTITY_NAME             SRC_TRANS_LE
        ,fia.to_le_id                      SRC_TRAD_LE_ID
        ,fun_recon_rpt_pkg.get_legal_entity(fia.to_le_Id)  SRC_TRAD_LE
        ,fia.ledger_id                     SRC_TRANS_LEDGER_ID
        ,glv.ledger_name                   SRC_TRANS_LEDGER
        ,gjct.user_je_category_name        JOURNAL_CATEGORY
        ,gjst.user_je_source_name          JOURNAL_SOURCE
        ,gjh.currency_code                 TRX_CURR
        ,gjl.period_name                   PERIOD_NAME
        ,gjl.entered_dr                    ENTERED_DR
        ,gjl.entered_cr                    ENTERED_CR
        ,gjl.accounted_dr                  ACCOUNTED_DR
        ,gjl.accounted_cr                  ACCOUNTED_CR
        ,fia.type                          TYPE
        ,glp.start_date                    START_DATE
        ,glp.end_date                      END_DATE
FROM    gl_je_categories_tl              gjct
        ,gl_je_sources_tl                 gjst
        ,gl_je_lines                      gjl
        ,gl_je_headers                    gjh
        ,gl_je_batches                    gjb
        ,gl_ledger_le_v                   glv
        ,fun_inter_accounts_v               fia
        ,gl_periods                       glp
        ,xla_ae_headers                   aeh
        ,xla_ae_lines                     ael
        ,xla_events                       xle
        ,xla_event_types_b                xet
        ,xla_transaction_entities         ent
        ,gl_import_references             gir
WHERE   gjh.je_header_id                 = gjl.je_header_id
  AND   gjb.je_batch_id                  = gjh.je_batch_id
  AND   gjb.status                       = ''P''
  AND   gjct.je_category_name            = gjh.je_category
  AND   gjct.LANGUAGE                    = USERENV(''LANG'')
  AND   gjst.je_source_name              = gjh.je_source
  AND   gjst.language                    = USERENV(''LANG'')
  AND   gjl.ledger_id                    = fia.ledger_id
  AND   gjh.actual_flag                  = ''A''
  AND   gjl.code_combination_id          = fia.ccid
  AND   fia.ledger_id                    = glv.ledger_id
  AND   fia.from_le_id                   = glv.legal_entity_id
  AND   glv.period_set_name              = glp.period_set_name
  AND   glv.accounted_period_type        = glp.period_type
  AND   glp.period_name                  = gjl.period_name
  AND    aeh.accounting_entry_status_code   = ''F''
  AND    aeh.gl_transfer_status_code        = ''Y''
  AND    ael.ae_header_id                   = aeh.ae_header_id
  AND    ael.application_id                 = aeh.application_id
  AND    xle.event_id                       = aeh.event_id
  AND    xet.application_id                 = aeh.application_id
  AND    xet.event_type_code                = aeh.event_type_code
  AND    ent.entity_id                      = xle.entity_id
  AND    ent.application_id                 = xle.application_id
  AND    gir.gl_sl_link_id                  = ael.gl_sl_link_id
  AND    gir.gl_sl_link_table               = ael.gl_sl_link_table
  AND    gjl.je_header_id                   = gir.je_header_id
  AND    gjl.je_line_num                    = gir.je_line_num
  AND    gjh.je_header_id                   = gir.je_header_id
  AND    gjb.je_batch_id                    = gir.je_batch_id
  $where_clause1$
)
  WHERE 1 = 1 ';


C_FUN_JELINES_GL_QUERY     CONSTANT VARCHAR2(30000) :=
'SELECT  fun_act.TRANSACTING_LE_ID         TRANS_LE_ID
        ,fun_act.TRANSACTING_LE            TRANS_LE
        ,fun_act.TRADING_PARTNER_LE_ID     TRAD_LE_ID
        ,fun_act.TRADING_PARTNER_LE        TRAD_LE
        ,fun_act.TRANSACTING_LEDGER        TRANSACTING_LEDGER
        ,fun_act.TRANSACTING_LEDGER_ID     LEDGER_ID
        ,''GL''                            SOURCE
        ,fun_act.acct_type                 ACCOUNT_TYPE
        ,gjh.default_effective_date        GL_DATE
        ,fdu.user_name                     CREATED_BY
        ,gjh.creation_date                 CREATION_DATE
        ,gjh.last_update_date              LAST_UPDATE_DATE
        ,gjh.reference_date                REFERENCE_DATE
        ,gjh.je_header_id                  HEADER_ID
        ,gjh.description                   HEADER_DESCRIPTION
        ,gjct.user_je_category_name        JE_CATEGORY_NAME
        ,gjst.user_je_source_name          JE_SOURCE_NAME
        ,gjb.NAME                          GL_BATCH_NAME
        ,gjb.posted_date                   POSTED_DATE
        ,gjh.NAME                          GL_JE_NAME
        ,gjl.je_line_num                   GL_LINE_NUMBER
        ,gjl.description                   LINE_DESCRIPTION
        ,gjh.currency_code                 ENTERED_CURRENCY
        ,LTRIM(TO_CHAR(gjh.currency_conversion_rate ,''999999999999999999999.999999999999''))      CONVERSION_RATE
        ,gjh.currency_conversion_date      CONVERSION_RATE_DATE
        ,gjh.currency_conversion_type      CONVERSION_RATE_TYPE_CODE
        ,gdct.user_conversion_type         CONVERSION_RATE_TYPE
        ,LTRIM(TO_CHAR(gjl.entered_dr,''999999999999999999999.999999999999''))                    ENTERED_DR
        ,LTRIM(TO_CHAR(gjl.entered_cr,''999999999999999999999.999999999999''))                    ENTERED_CR
        ,LTRIM(TO_CHAR(gjl.accounted_dr,''999999999999999999999.999999999999''))                  ACCOUNTED_DR
        ,LTRIM(TO_CHAR(gjl.accounted_cr,''999999999999999999999.999999999999''))                  ACCOUNTED_CR
        ,gjl.code_combination_id           CODE_COMBINATION_ID
        ,gjl.period_name                   PERIOD_NAME
        ,fun_trx_entry_util.get_concatenated_account(gjl.code_combination_id ) ACCOUNT
        ,LTRIM(TO_CHAR(gjl.stat_amount,''999999999999999999999.999999999999''))                   STATISTICAL_AMOUNT
        ,gjl.jgzz_recon_ref_11i            RECONCILIATION_REFERENCE
        ,gjl.context                       ATTRIBUTE_CATEGORY
        ,gjl.attribute1                    ATTRIBUTE1
        ,gjl.attribute2                    ATTRIBUTE2
        ,gjl.attribute3                    ATTRIBUTE3
        ,gjl.attribute4                    ATTRIBUTE4
        ,gjl.attribute5                    ATTRIBUTE5
        ,gjl.attribute6                    ATTRIBUTE6
        ,gjl.attribute7                    ATTRIBUTE7
        ,gjl.attribute8                    ATTRIBUTE8
        ,gjl.attribute9                    ATTRIBUTE9
        ,gjl.attribute10                   ATTRIBUTE10
        ,gjl.attribute11                   ATTRIBUTE11
        ,gjl.attribute12                   ATTRIBUTE12
        ,gjl.attribute13                   ATTRIBUTE13
        ,gjl.attribute14                   ATTRIBUTE14
        ,gjl.attribute15                   ATTRIBUTE15
        ,gjl.attribute16                   ATTRIBUTE16
        ,gjl.attribute17                   ATTRIBUTE17
        ,gjl.attribute18                   ATTRIBUTE18
        ,gjl.attribute19                   ATTRIBUTE19
        ,gjl.attribute20                   ATTRIBUTE20
        ,gjl.je_header_id||''-''||gjl.je_line_num EXPAND_ID
FROM    fnd_user                         fdu
       ,gl_je_categories_tl              gjct
       ,gl_je_sources_tl                 gjst
       ,gl_daily_conversion_types        gdct
       ,gl_je_lines                      gjl
       ,gl_je_headers                    gjh
       ,gl_je_batches                    gjb
       ,gl_periods                       glp
       , ($get_accounts_query$) fun_act
WHERE   gjh.je_header_id                 = gjl.je_header_id
  AND   gjb.je_batch_id                  = gjh.je_batch_id
  AND   gjb.status                       = ''P''
  AND   fdu.user_id                      = gjb.created_by
  AND   gjct.je_category_name            = gjh.je_category
  AND   gjct.LANGUAGE                    = USERENV(''LANG'')
  AND   gjst.je_source_name              = gjh.je_source
  AND   gjst.language                    = USERENV(''LANG'')
  AND   gdct.conversion_type(+)          = gjh.currency_conversion_type
  AND   (gjh.parent_je_header_id IS NOT NULL
         OR
         gjh.je_source NOT IN (SELECT DISTINCT je_source_name
                                 FROM xla_subledgers
                               WHERE je_source_name <> ''Global Intercompany'')
        )
  AND   gjl.ledger_id                   = gjh.ledger_id
  AND   gjh.actual_flag                 = ''A''
  AND   gjl.code_combination_id         = fun_act.ccid
  AND   gjl.ledger_id                   = fun_act.TRANSACTING_LEDGER_ID
  AND   glp.period_set_name             = fun_act.period_set_name
  AND   glp.period_type                 = fun_act.accounted_period_type
  AND   glp.period_name                 = gjl.period_name ';


C_GL_UNMATCHED_QUERY     CONSTANT VARCHAR2(30000) :=
'SELECT  glv.legal_entity_id               TRANS_LE_ID
        ,glv.LEGAL_ENTITY_NAME             TRANS_LE
        ,fia.to_le_id                      TRAD_LE_ID
        ,fun_recon_rpt_pkg.get_legal_entity(fia.to_le_Id)  TRAD_LE
        ,glv.ledger_name                   TRANSACTING_LEDGER
        ,glv.ledger_id                     LEDGER_ID
        ,''GL''                            SOURCE
        ,fia.type                          ACCOUNT_TYPE
        ,gjh.default_effective_date        GL_DATE
        ,fdu.user_name                     CREATED_BY
        ,gjh.creation_date                 CREATION_DATE
        ,gjh.last_update_date              LAST_UPDATE_DATE
        ,gjh.reference_date                REFERENCE_DATE
        ,gjh.je_header_id                  HEADER_ID
        ,gjh.description                   HEADER_DESCRIPTION
        ,gjct.user_je_category_name        JE_CATEGORY_NAME
        ,gjst.user_je_source_name          JE_SOURCE_NAME
        ,gjb.NAME                          GL_BATCH_NAME
        ,gjb.posted_date                   POSTED_DATE
        ,gjh.NAME                          GL_JE_NAME
        ,gjl.je_line_num                   GL_LINE_NUMBER
        ,gjl.description                   LINE_DESCRIPTION
        ,gjh.currency_code                 ENTERED_CURRENCY
        ,LTRIM(TO_CHAR(gjh.currency_conversion_rate,''999999999999999999999.999999999999''))      CONVERSION_RATE
        ,gjh.currency_conversion_date      CONVERSION_RATE_DATE
        ,gjh.currency_conversion_type      CONVERSION_RATE_TYPE_CODE
        ,gdct.user_conversion_type         CONVERSION_RATE_TYPE
        ,LTRIM(TO_CHAR(gjl.entered_dr,''999999999999999999999.999999999999''))                    ENTERED_DR
        ,LTRIM(TO_CHAR(gjl.entered_cr,''999999999999999999999.999999999999''))                    ENTERED_CR
        ,LTRIM(TO_CHAR(gjl.accounted_dr,''999999999999999999999.999999999999''))                  ACCOUNTED_DR
        ,LTRIM(TO_CHAR(gjl.accounted_cr,''999999999999999999999.999999999999''))                  ACCOUNTED_CR
        ,gjl.code_combination_id           CODE_COMBINATION_ID
        ,gjl.period_name                   PERIOD_NAME
        ,fun_trx_entry_util.get_concatenated_account(gjl.code_combination_id ) ACCOUNT
        ,LTRIM(TO_CHAR(gjl.stat_amount,''999999999999999999999.999999999999''))                   STATISTICAL_AMOUNT
        ,gjl.jgzz_recon_ref_11i            RECONCILIATION_REFERENCE
        ,gjl.context                       ATTRIBUTE_CATEGORY
        ,gjl.attribute1                    ATTRIBUTE1
        ,gjl.attribute2                    ATTRIBUTE2
        ,gjl.attribute3                    ATTRIBUTE3
        ,gjl.attribute4                    ATTRIBUTE4
        ,gjl.attribute5                    ATTRIBUTE5
        ,gjl.attribute6                    ATTRIBUTE6
        ,gjl.attribute7                    ATTRIBUTE7
        ,gjl.attribute8                    ATTRIBUTE8
        ,gjl.attribute9                    ATTRIBUTE9
        ,gjl.attribute10                   ATTRIBUTE10
        ,gjl.attribute11                   ATTRIBUTE11
        ,gjl.attribute12                   ATTRIBUTE12
        ,gjl.attribute13                   ATTRIBUTE13
        ,gjl.attribute14                   ATTRIBUTE14
        ,gjl.attribute15                   ATTRIBUTE15
        ,gjl.attribute16                   ATTRIBUTE16
        ,gjl.attribute17                   ATTRIBUTE17
        ,gjl.attribute18                   ATTRIBUTE18
        ,gjl.attribute19                   ATTRIBUTE19
        ,gjl.attribute20                   ATTRIBUTE20
        ,gjl.je_header_id||''-''||gjl.je_line_num EXPAND_ID
FROM    fnd_user                         fdu
       ,gl_je_categories_tl              gjct
       ,gl_je_sources_tl                 gjst
       ,gl_daily_conversion_types        gdct
       ,gl_je_lines                      gjl
       ,gl_je_headers                    gjh
       ,gl_je_batches                    gjb
       ,gl_ledger_le_v                   glv
       ,fun_inter_accounts_v               fia
       ,gl_periods                       glp
WHERE   gjh.je_header_id                 = gjl.je_header_id
  AND   gjb.je_batch_id                  = gjh.je_batch_id
  AND   gjb.status                       = ''P''
  AND   fdu.user_id                      = gjb.created_by
  AND   gjct.je_category_name            = gjh.je_category
  AND   gjct.LANGUAGE                    = USERENV(''LANG'')
  AND   gjst.je_source_name              = gjh.je_source
  AND   gjst.language                    = USERENV(''LANG'')
  AND   gdct.conversion_type(+)          = gjh.currency_conversion_type
  AND   (gjh.parent_je_header_id IS NOT NULL
         OR
         gjh.je_source NOT IN (SELECT DISTINCT je_source_name
                                 FROM xla_subledgers
                               WHERE je_source_name <> ''Global Intercompany'')
        )
  AND   gjl.ledger_id                   = fia.ledger_id
  AND   gjh.actual_flag                 = ''A''
  AND   gjl.code_combination_id         = fia.ccid
  AND   fia.ledger_id                   = glv.ledger_id
  AND   fia.from_le_id                  = glv.legal_entity_id
  AND   glv.period_set_name             = glp.period_set_name
  AND   glv.accounted_period_type       = glp.period_type
  AND   glp.period_name                 = gjl.period_name ';

-------------------------------------------------------------------------------
-- Define Types
-------------------------------------------------------------------------------
TYPE t_array_char IS TABLE OF VARCHAR2(32000) INDEX BY BINARY_INTEGER ;


--=============================================================================
--        **************  forward  declaraions  ******************
--=============================================================================

--------------------------------------------------------------------------------
-- procedure to create the main SQL
--------------------------------------------------------------------------------
PROCEDURE get_fun_main_sql
       (p_trans_ledger_id                 IN NUMBER
       ,p_trans_legal_entity_id           IN NUMBER
       ,p_trans_gl_period                 IN VARCHAR2
       ,p_tp_ledger_id                    IN NUMBER
       ,p_tp_legal_entity_id              IN NUMBER
       ,p_currency                        IN VARCHAR2
       ,p_tp_gl_period                    IN VARCHAR2
       ,p_rate_type                       IN VARCHAR2
       ,p_rate_date                       IN DATE
       ,p_array_sql                       IN OUT NOCOPY T_ARRAY_CHAR);


--------------------------------------------------------------------------------
-- procedure to create a dummy SQL to print paramteres to the XML file
--------------------------------------------------------------------------------

PROCEDURE  get_fun_parameter_sql
      (p_trans_ledger_id                 IN NUMBER
      ,p_trans_legal_entity_id           IN NUMBER
      ,p_trans_gl_period                 IN VARCHAR2
      ,p_tp_ledger_id                    IN NUMBER
      ,p_tp_legal_entity_id              IN NUMBER
      ,p_currency                        IN VARCHAR2
      ,p_tp_gl_period                    IN VARCHAR2
      ,p_rate_type                       IN VARCHAR2
      ,p_rate_date                       IN VARCHAR2
      ,p_array_sql                       IN OUT NOCOPY T_ARRAY_CHAR);



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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240):= 'fun.plsql.fun_recon_rpt_pkg';

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
   WHEN OTHERS THEN
     FUN_UTIL.log_conc_unexp(C_DEFAULT_MODULE, 'trace');
     RAISE;
END trace;


--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
-- Following are public routines
--
--    1.  run_fun_report
--=============================================================================
--=============================================================================
--
-- PROCEDURE RUN_FUN_REPORT
--
--=============================================================================
PROCEDURE run_fun_report
       (p_errbuf                          OUT NOCOPY VARCHAR2
       ,p_retcode                         OUT NOCOPY NUMBER
       ,p_trans_ledger_id                 IN NUMBER
       ,p_trans_legal_entity_id           IN NUMBER
       ,p_trans_gl_period                 IN VARCHAR2
       ,p_tp_ledger_id                    IN NUMBER
       ,p_tp_legal_entity_id              IN NUMBER
       ,p_tp_gl_period                    IN VARCHAR2
       ,p_currency                        IN VARCHAR2
       ,p_rate_type                       IN VARCHAR2
       ,p_rate_date                       IN VARCHAR2) IS

l_array_sql                     T_ARRAY_CHAR;
l_source_application_id         NUMBER;
l_fetch_from_sla_flag           VARCHAR2(1);
l_fetch_from_gl_flag            VARCHAR2(1);
l_xml_clob                      CLOB;
l_ctx                           NUMBER;
l_log_module                    VARCHAR2(240);
l_para_ctx                      dbms_xmlgen.ctxHandle;
l_encoding                      VARCHAR2(20);

l_start_period_num              NUMBER;
l_end_period_num                NUMBER;
l_start_date                    DATE;
l_end_date                      DATE;
l_rate_date                     DATE;
l_select_str                    VARCHAR2(4000);
l_from_str                      VARCHAR2(240);
l_where_str                     VARCHAR2(4000);
l_insert_query                  VARCHAR2(4000);
l_lang                          VARCHAR2(80);
l_count                         NUMBER;
l_message                       fnd_new_messages.message_text%TYPE;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.run_fun_report';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('run_report.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'p_trans_ledger_id = '|| to_char(p_trans_ledger_id)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_trans_legal_entity_id = '|| to_char(p_trans_legal_entity_id)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_trans_gl_period = '|| p_trans_gl_period
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_tp_ledger_id = '|| to_char(p_tp_ledger_id)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_tp_legal_entity_id = '|| to_char(p_tp_legal_entity_id)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_currency = '|| p_currency
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_tp_gl_period = '|| p_tp_gl_period
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
  END IF;

  -- Check conversion rate type entered for additional currency
  IF p_currency IS NOT NULL  AND p_rate_type IS NULL
  THEN
      FND_MESSAGE.SET_NAME('FUN', 'FUN_RECON_RATE_TYPE_REQD');
      l_message := fnd_message.get;
      p_errbuf := l_message;
      p_retcode := 2;
      RETURN;
  END IF;

 l_rate_date := TRUNC(Nvl(fnd_date.canonical_to_date(p_rate_date), sysdate));
  --
  -- get value for language
  --
   SELECT  USERENV('LANG')
    INTO  l_lang
    FROM  dual;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   =>'value of LANG ='||l_lang
         ,p_level =>C_LEVEL_STATEMENT
         ,p_module=>l_log_module);
   END IF;

   -- Set SLA security such that details across applications can be accessed.
   xla_security_pkg.set_security_context(602);

   l_array_sql.DELETE;

   get_fun_parameter_sql
      (p_trans_ledger_id                 => p_trans_ledger_id
      ,p_trans_legal_entity_id           => p_trans_legal_entity_id
      ,p_trans_gl_period                 => p_trans_gl_period
      ,p_tp_ledger_id                    => p_tp_ledger_id
      ,p_tp_legal_entity_id              => p_tp_legal_entity_id
      ,p_currency                        => p_currency
      ,p_tp_gl_period                    => p_tp_gl_period
      ,p_rate_type                       => p_rate_type
      ,p_rate_date                       => p_rate_date
      ,p_array_sql                       => l_array_sql);

   get_fun_main_sql
      (p_trans_ledger_id                 => p_trans_ledger_id
      ,p_trans_legal_entity_id           => p_trans_legal_entity_id
      ,p_trans_gl_period                 => p_trans_gl_period
      ,p_tp_ledger_id                    => p_tp_ledger_id
      ,p_tp_legal_entity_id              => p_tp_legal_entity_id
      ,p_currency                        => p_currency
      ,p_tp_gl_period                    => p_tp_gl_period
      ,p_rate_type                       => p_rate_type
      ,p_rate_date                       => l_rate_date
      ,p_array_sql                       => l_array_sql);

   l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
   fnd_file.put_line(fnd_file.output, '<?xml version="1.0" encoding="'||l_encoding||'"?>');
   fnd_file.put_line(fnd_file.output, '<REPORT_ROOT>');

   FOR i IN 1..l_array_sql.COUNT LOOP
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg   =>'Query('||to_char(i)||') = '||l_array_sql(i)
            ,p_level =>C_LEVEL_STATEMENT
            ,p_module=>l_log_module);
      END IF;

      IF i = 1 THEN
         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg   =>'Start Genrating XML for Parameter'
               ,p_level =>C_LEVEL_EVENT
               ,p_module=>l_log_module);
         END IF;

         l_para_Ctx := dbms_xmlgen.newContext(l_array_sql(i));
         DBMS_XMLGEN.setRowSetTag(l_para_Ctx,NULL);
         DBMS_XMLGEN.setRowTag(l_para_Ctx, 'PARAMETER');
         l_xml_clob := DBMS_XMLGEN.GETXML(l_para_Ctx);
         l_xml_clob:= substr(l_xml_clob,instr(l_xml_clob,'>')+1);
         DBMS_XMLGEN.closeContext(l_para_Ctx);

         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg   =>'End of Genrating XML for Parameter'
               ,p_level =>C_LEVEL_EVENT
               ,p_module=>l_log_module);
         END IF;

      ELSE --i>1
         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg   =>'Start Genrating XML for JE lines'
               ,p_level =>C_LEVEL_EVENT
               ,p_module=>l_log_module);
         END IF;

         fnd_file.put_line(fnd_file.log, l_array_sql(i));
         fnd_file.put_line(fnd_file.log, ' ');
         fnd_file.put_line(fnd_file.log, '+===========================================================================+');
         fnd_file.put_line(fnd_file.log, ' ');

		 IF i = 2 -- Summary query

         THEN
		   fnd_file.put_line(fnd_file.output, '<G_SUMMARY_ROWSET>');

           l_ctx := DBMS_XMLGEN.newContext(l_array_sql(i));
           DBMS_XMLGEN.setRowSetTag(l_ctx,'G_SUMMARY_ROWSET');
           DBMS_XMLGEN.setRowTag(l_ctx, 'G_SUMMARY_ROW');

           IF p_currency IS NOT NULL
           THEN
               DBMS_XMLGEN.setBindValue(l_ctx,'TO_CURR',p_currency);
               DBMS_XMLGEN.setBindValue(l_ctx,'TO_DATE',p_rate_date);
               DBMS_XMLGEN.setBindValue(l_ctx,'TYPE',p_rate_type);
           END IF;

         ELSIF i = 3

         THEN
   		   fnd_file.put_line(fnd_file.output, '<G_JRNLSOURCE_ROWSET>');

           l_ctx := DBMS_XMLGEN.newContext(l_array_sql(i));
           DBMS_XMLGEN.setRowSetTag(l_ctx,'G_JRNLSOURCE_ROWSET');
           DBMS_XMLGEN.setRowTag(l_ctx, 'G_JRNLSOURCE_ROW');

         ELSIF i = 4

         THEN
   		   fnd_file.put_line(fnd_file.output, '<G_JRNLDETAILS_ROWSET>');

           l_ctx := DBMS_XMLGEN.newContext(l_array_sql(i));
           DBMS_XMLGEN.setRowSetTag(l_ctx,'G_JRNLDETAILS_ROWSET');
           DBMS_XMLGEN.setRowTag(l_ctx, 'G_JOURNAL_ROW');

         ELSIF i = 5

         THEN
   		   fnd_file.put_line(fnd_file.output, '<G_SLADETAILS_ROWSET>');

           l_ctx := DBMS_XMLGEN.newContext(l_array_sql(i));
           DBMS_XMLGEN.setRowSetTag(l_ctx,'G_SLADETAILS_ROWSET');
           DBMS_XMLGEN.setRowTag(l_ctx, 'G_SLA_ROW');


         ELSIF i = 6

         THEN
   		   fnd_file.put_line(fnd_file.output, '<G_JRNLSOURCE_UNMATCHED_ROWSET>');

           l_ctx := DBMS_XMLGEN.newContext(l_array_sql(i));
           DBMS_XMLGEN.setRowSetTag(l_ctx,'G_JRNLSOURCE_UNMATCHED_ROWSET');
           DBMS_XMLGEN.setRowTag(l_ctx, 'G_JRNLSOURCE_UNMATCHED_ROW');

         ELSIF i = 7
	 THEN
   		   fnd_file.put_line(fnd_file.output, '<G_JRNLDETAILS_UNMATCHED_ROWSET>');

           l_ctx := DBMS_XMLGEN.newContext(l_array_sql(i));
           DBMS_XMLGEN.setRowSetTag(l_ctx,'G_JRNLDETAILS_UNMATCHED_ROWSET');
           DBMS_XMLGEN.setRowTag(l_ctx, 'G_JOURNAL_UNMATCHED_ROW');

         ELSIF i = 8

         THEN
   		   fnd_file.put_line(fnd_file.output, '<G_SLADETAILS_UNMATCHED_ROWSET>');

           l_ctx := DBMS_XMLGEN.newContext(l_array_sql(i));
           DBMS_XMLGEN.setRowSetTag(l_ctx,'G_SLADETAILS_UNMATCHED_ROWSET');
           DBMS_XMLGEN.setRowTag(l_ctx, 'G_SLA_UNMATCHED_ROW');

        END IF;

         l_xml_clob := DBMS_XMLGEN.GETXML(l_ctx);
         l_xml_clob:= substr(l_xml_clob,instr(l_xml_clob,'>',1,2)+1);
         DBMS_XMLGEN.closeContext(l_ctx);

         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg   =>'End of Genrating XML for JE lines'
               ,p_level =>C_LEVEL_EVENT
               ,p_module=>l_log_module);
         END IF;
      END IF;

      IF l_xml_clob IS NULL THEN
        IF i = 2     THEN
         fnd_file.put_line(fnd_file.output, '</G_SUMMARY_ROWSET>');
        ELSIF i = 3  THEN
         fnd_file.put_line(fnd_file.output, '</G_JRNLSOURCE_ROWSET>');
        ELSIF i = 4   THEN
         fnd_file.put_line(fnd_file.output, '</G_JRNLDETAILS_ROWSET>');
        ELSIF i = 5    THEN
         fnd_file.put_line(fnd_file.output, '</G_SLADETAILS_ROWSET>');
        ELSIF i = 6  THEN
         fnd_file.put_line(fnd_file.output, '</G_JRNLSOURCE_UNMATCHED_ROWSET>');
        ELSIF i = 7 THEN
         fnd_file.put_line(fnd_file.output, '</G_JRNLDETAILS_UNMATCHED_ROWSET>');
        ELSIF i = 8  THEN
         fnd_file.put_line(fnd_file.output, '</G_SLADETAILS_UNMATCHED_ROWSET>');
        END IF;
      END IF;

      fun_recon_rpt_pkg.clob_to_file
                               (p_xml_clob  => l_xml_clob);
   END LOOP;

   fnd_file.put_line(fnd_file.output, '</REPORT_ROOT>');

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg   =>'run_fun_report.End'
         ,p_level =>C_LEVEL_PROCEDURE
         ,p_module=>l_Log_module);
   END IF;
EXCEPTION
WHEN OTHERS THEN
     FUN_UTIL.log_conc_unexp(C_DEFAULT_MODULE, 'run_fun_report');
     RAISE;
END run_fun_report;


--=============================================================================
--
-- PROCEDURE GET_FUN_PARAMETER_SQL
--
--=============================================================================
PROCEDURE  get_fun_parameter_sql
      (p_trans_ledger_id                 IN NUMBER
      ,p_trans_legal_entity_id           IN NUMBER
      ,p_trans_gl_period                 IN VARCHAR2
      ,p_tp_ledger_id                    IN NUMBER
      ,p_tp_legal_entity_id              IN NUMBER
      ,p_currency                        IN VARCHAR2
      ,p_tp_gl_period                    IN VARCHAR2
      ,p_rate_type                       IN VARCHAR2
      ,p_rate_date                       IN VARCHAR2
      ,p_array_sql                       IN OUT NOCOPY T_ARRAY_CHAR)  IS

l_param_query  VARCHAR2(2000);
l_index        NUMBER;
l_log_module                    VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_fun_parameter_sql';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg   => 'get_fun_parameter_sql.Begin'
         ,p_level => C_LEVEL_PROCEDURE
         ,p_module=> l_Log_module );
   END IF;

   l_param_query := 'Select '
          ||''''||p_trans_ledger_id         ||''''||'  p_trans_ledger_id,'
          ||''''||p_trans_legal_entity_id   ||''''||'  p_TRANS_LEGAL_ENTITY_ID,'
          ||''''||p_trans_gl_period         ||''''||'  p_trans_gl_period,'
          ||''''||p_tp_ledger_id            ||''''||'  p_tp_ledger_id,'
          ||''''||p_tp_legal_entity_id      ||''''||'  p_TP_LEGAL_ENTITY_ID,'
          ||''''||p_currency                ||''''||'  p_CURRENCY,'
          ||''''||p_tp_gl_period            ||''''||'  p_tp_gl_period,'
          ||''''||p_rate_type               ||''''||'  p_rate_type,'
          ||''''||to_char(fnd_date.canonical_to_date(p_rate_date))  ||''''||'  p_rate_date'
          ||' FROM DUAL ';

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'Query for parameter value ='||l_param_query
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=>l_Log_module );
   END IF;

   l_index := p_array_sql.count + 1;
   p_array_sql(l_index):= l_param_query;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg   =>'get_fun_parameter_sql.End'
         ,p_level => C_LEVEL_PROCEDURE
         ,p_module=>l_Log_module);
   END IF;
EXCEPTION
WHEN OTHERS THEN
     FUN_UTIL.log_conc_unexp(C_DEFAULT_MODULE, 'get_fun_parameter_sql');
     RAISE;
END get_fun_parameter_sql;


--=============================================================================
--
-- PROCEDURE GET_FUN_MAIN_SQL
--
--=============================================================================
PROCEDURE get_fun_main_sql
       (p_trans_ledger_id                 IN NUMBER
       ,p_trans_legal_entity_id           IN NUMBER
       ,p_trans_gl_period                 IN VARCHAR2
       ,p_tp_ledger_id                    IN NUMBER
       ,p_tp_legal_entity_id              IN NUMBER
       ,p_currency                        IN VARCHAR2
       ,p_tp_gl_period                    IN VARCHAR2
       ,p_rate_type                       IN VARCHAR2
       ,p_rate_date                       IN DATE
       ,p_array_sql                       IN OUT NOCOPY T_ARRAY_CHAR) IS

CURSOR c_get_prd_end_date (p_ledger_id   NUMBER,
                           p_period_name VARCHAR2)
IS
  SELECT glp.start_date,
         glp.end_date
  FROM   gl_periods glp,
         gl_ledgers gl
  WHERE  glp.period_set_name  = gl.period_set_name
  AND    glp.period_type      = gl.accounted_period_type
  AND    glp.period_name      = p_period_name
  AND    gl.ledger_id         = p_ledger_id;


l_get_account_query        VARCHAR2(32000);
l_jelines_sla_query        VARCHAR2(32000);
l_jelines_gl_query         VARCHAR2(32000);
l_jelines_sum_query        VARCHAR2(32000);
l_gl_balances_query        VARCHAR2(32000);
l_gl_balances_query1        VARCHAR2(32000);
l_sum_unmatched_query      VARCHAR2(32000);
l_gl_unmatched_query       VARCHAR2(32000);
l_sla_unmatched_query      VARCHAR2(32000);

l_add_currency_cols        VARCHAR2(32000);

l_coa_id                   NUMBER;

l_get_account_query_rev    VARCHAR2(32000);
l_jelines_sla_query_rev    VARCHAR2(32000);
l_jelines_gl_query_rev     VARCHAR2(32000);
l_jelines_sum_query_rev    VARCHAR2(32000);
l_gl_balances_query_rev    VARCHAR2(32000);
l_gl_balances_query_rev1    VARCHAR2(32000);
l_sum_unmatched_query_rev  VARCHAR2(32000);
l_gl_unmatched_query_rev   VARCHAR2(32000);
l_sla_unmatched_query_rev  VARCHAR2(32000);

l_period_end_date          DATE;
l_period_start_date          DATE;

l_balancing_segment        VARCHAR2(80);
l_account_segment          VARCHAR2(80);
l_costcenter_segment       VARCHAR2(80);
l_management_segment       VARCHAR2(80);
l_intercompany_segment     VARCHAR2(80);

l_alias_balancing_segment        VARCHAR2(80);
l_alias_account_segment          VARCHAR2(80);
l_alias_costcenter_segment       VARCHAR2(80);
l_alias_management_segment       VARCHAR2(80);
l_alias_intercompany_segment     VARCHAR2(80);
l_trx_source_view_columns  VARCHAR2(4000);
l_trx_source_view_name     VARCHAR2(240);
l_trx_source_view_join     VARCHAR2(4000);
l_other_param_filter       VARCHAR2(4000);
l_sla_other_filter         VARCHAR2(1000);
l_gl_other_filter          VARCHAR2(1000);
l_seg_desc_column          VARCHAR2(4000);
l_seg_desc_from            VARCHAR2(4000);
l_seg_desc_join            VARCHAR2(4000);

l_anc_view_columns         VARCHAR2(4000);
l_anc_view_name            VARCHAR2(240);
l_anc_view_join            VARCHAR2(4000);

l_le_columns               VARCHAR2(4000);
l_le_view                  VARCHAR2(4000);
l_le_view_join             VARCHAR2(4000);

l_index                    NUMBER;
l_log_module               VARCHAR2(240);

l_add_where_clause1        VARCHAR2(4000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_fun_main_sql';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('get_fun_main_sql.Begin',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'p_trans_ledger_id = '|| to_char(p_trans_ledger_id)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_trans_legal_entity_id = '|| to_char(p_trans_legal_entity_id)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_trans_gl_period = '|| p_trans_gl_period
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_tp_ledger_id = '|| to_char(p_tp_ledger_id)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_tp_legal_entity_id = '|| to_char(p_tp_legal_entity_id)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_currency = '|| p_currency
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_tp_gl_period = '|| p_tp_gl_period
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'p_array_sql.count = '||p_array_sql.count
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_Log_module);
   END IF;

   -- get the period end date of the transacting ledger
   -- as we might need to use it to find the corresponding
   -- period in the trading ledger
   OPEN c_get_prd_end_date (p_trans_ledger_id,
                            p_trans_gl_period);

   FETCH c_get_prd_end_date INTO l_period_start_date,
                                 l_period_end_date;
   CLOSE c_get_prd_end_date;

   --==========================================================================
   -- building qeury to fetch source summary from GL,
   --                         summary balances from GL,
   --                         journal line details from SLA and GL
   --==========================================================================

   l_get_account_query := C_FUN_GET_ACCTS_QUERY;
   l_jelines_sum_query := C_FUN_JELINES_SUM_QUERY;
   l_sum_unmatched_query := C_SUM_UNMATCHED_QUERY;
   --Bug: 8947605
   l_gl_balances_query := C_FUN_GL_BALANCE_QUERY;
   l_gl_balances_query1 := C_FUN_GL_BALANCE_QUERY1;
   l_jelines_gl_query  := C_FUN_JELINES_GL_QUERY;
   l_gl_unmatched_query  := C_GL_UNMATCHED_QUERY;
   l_jelines_sla_query := C_FUN_JELINES_SLA_QUERY;
   l_sla_unmatched_query := C_SLA_UNMATCHED_QUERY;
   l_add_currency_cols := C_ADD_CURRENCY_COLS;


   IF p_trans_ledger_id IS NOT NULL -- User input parameter
   THEN
       l_gl_balances_query := l_gl_balances_query || ' AND fia1.ledger_id = '||p_trans_ledger_id;
       l_get_account_query := l_get_account_query || ' AND fia1.ledger_id = '||p_trans_ledger_id;
       l_jelines_sum_query := l_jelines_sum_query || ' AND gjl.ledger_id = '||p_trans_ledger_id;
       l_sum_unmatched_query := l_sum_unmatched_query || ' AND SRC_TRANS_LEDGER_ID = '||p_trans_ledger_id;
       l_jelines_gl_query  := l_jelines_gl_query || '  AND gjl.ledger_id = '||p_trans_ledger_id;
       l_gl_unmatched_query  := l_gl_unmatched_query || '  AND fia.ledger_id = '||p_trans_ledger_id;
       l_jelines_sla_query := l_jelines_sla_query || ' AND aeh.ledger_id = '||p_trans_ledger_id;
       l_sla_unmatched_query := l_sla_unmatched_query || ' AND fia.ledger_id = '||p_trans_ledger_id;
   END IF;

   IF P_TRANS_LEGAL_ENTITY_ID IS NOT NULL -- User input parameter
   THEN
       l_gl_balances_query := l_gl_balances_query || ' AND fia1.from_le_id = '||P_TRANS_LEGAL_ENTITY_ID ;
       l_get_account_query := l_get_account_query || ' AND fia1.from_le_id = '||P_TRANS_LEGAL_ENTITY_ID ;
       l_sum_unmatched_query := l_sum_unmatched_query || ' AND SRC_TRANS_LE_ID = '||P_TRANS_LEGAL_ENTITY_ID ;
       l_gl_unmatched_query  := l_gl_unmatched_query || '  AND fia.from_le_id = '||P_TRANS_LEGAL_ENTITY_ID ;
       l_sla_unmatched_query  := l_sla_unmatched_query || ' AND fia.from_le_id = '||P_TRANS_LEGAL_ENTITY_ID ;

   END IF;

   IF p_trans_gl_period IS NOT NULL -- User input parameter
   THEN
       l_gl_balances_query := l_gl_balances_query|| ' AND glb1.period_name = '''||p_trans_gl_period ||'''' ;
       l_jelines_sum_query := l_jelines_sum_query || ' AND gjl.period_name = '''||p_trans_gl_period ||'''' ;
       l_sum_unmatched_query := l_sum_unmatched_query || ' AND PERIOD_NAME = '''||p_trans_gl_period ||'''' ;
       l_jelines_gl_query  := l_jelines_gl_query || ' AND gjl.period_name = '''||p_trans_gl_period ||'''' ;
       l_gl_unmatched_query  := l_gl_unmatched_query || ' AND gjl.period_name = '''||p_trans_gl_period ||'''' ;
       l_jelines_sla_query  := l_jelines_sla_query || ' AND aeh.period_name = '''||p_trans_gl_period ||'''' ;
       l_jelines_sla_query  := l_jelines_sla_query || ' AND aeh.accounting_date BETWEEN '''||l_period_start_date ||''' AND ''' || l_period_end_date || '''';
       l_sla_unmatched_query  := l_sla_unmatched_query || ' AND aeh.period_name = '''||p_trans_gl_period ||'''' ;
       l_sla_unmatched_query  := l_sla_unmatched_query || ' AND aeh.accounting_date BETWEEN '''||l_period_start_date ||''' AND ''' || l_period_end_date || '''';
   END IF;

   IF p_tp_ledger_id IS NOT NULL -- User input parameter
   THEN
       l_gl_balances_query := l_gl_balances_query || ' AND fia2.ledger_id = '||p_tp_ledger_id ;

       l_get_account_query := l_get_account_query || ' AND fia2.ledger_id = '||p_tp_ledger_id ;


       l_sum_unmatched_query := l_sum_unmatched_query || ' AND SRC_TRAD_LE_ID IN (SELECT tole.legal_entity_id
                                          FROM   gl_ledger_le_v tole
                                          WHERE  tole.ledger_id = '||p_tp_ledger_id ||')';


       l_gl_unmatched_query  := l_gl_unmatched_query || ' AND fia.to_le_id IN (SELECT tole.legal_entity_id
                                          FROM   gl_ledger_le_v tole
                                          WHERE  tole.ledger_id = '||p_tp_ledger_id ||')';

       l_sla_unmatched_query  := l_sla_unmatched_query || ' AND fia.to_le_id IN (SELECT tole.legal_entity_id
                                          FROM   gl_ledger_le_v tole
                                          WHERE  tole.ledger_id = '||p_tp_ledger_id ||')';
   END IF;

   IF P_TP_LEGAL_ENTITY_ID IS NOT NULL -- User input parameter
   THEN
       l_gl_balances_query := l_gl_balances_query || ' AND fia1.to_le_id = '||P_TP_LEGAL_ENTITY_ID ;
       l_get_account_query := l_get_account_query || ' AND fia1.to_le_id = '||P_TP_LEGAL_ENTITY_ID ;
       l_sum_unmatched_query := l_sum_unmatched_query || ' AND SRC_TRAD_LE_ID = '||P_TP_LEGAL_ENTITY_ID ;
       l_gl_unmatched_query  := l_gl_unmatched_query  || ' AND fia.to_le_id = '||P_TP_LEGAL_ENTITY_ID ;
       l_sla_unmatched_query  := l_sla_unmatched_query || ' AND fia.to_le_id = '||P_TP_LEGAL_ENTITY_ID ;
   END IF;


   IF P_TP_GL_PERIOD IS NOT NULL -- User input parameter
   THEN
       l_gl_balances_query := l_gl_balances_query || ' AND glp2.period_name = '''||p_tp_gl_period ||'''' ;
   ELSE
       -- find corresponding GL period in the trading ledger side.
       l_gl_balances_query := l_gl_balances_query ||
                              ' AND   ''' ||l_period_end_date||''' BETWEEN glp2.start_date and glp2.end_date
                                AND   glp2.adjustment_period_flag = glp1.adjustment_period_flag';
   END IF;

   IF P_CURRENCY IS NOT NULL
   THEN
       l_gl_balances_query1 := REPLACE(l_gl_balances_query1,
                                     '$additional_currency_columns$',
                                      l_add_currency_cols);
   ELSE
       l_gl_balances_query1 := REPLACE(l_gl_balances_query1,
                                     '$additional_currency_columns$',
                                      ',NULL');
   END IF;

   l_gl_balances_query1 := REPLACE(l_gl_balances_query1,
                                   '$sub_query$',
                                   l_gl_balances_query);


   IF P_TP_GL_PERIOD IS NULL
   THEN
      l_add_where_clause1 := ' AND FUN_RECON_RPT_PKG.match_ap_ar_invoice(fia.from_le_id, fia.ledger_id, glp.period_name, fia.to_le_id, '
||         nvl(to_char(p_tp_ledger_id), 'null') || ', null  , ' ||
   ' fia.type, ent.entity_code, ent.source_id_int_1) = ''UNMATCHED''   ';
   ELSE
      l_add_where_clause1 := ' AND FUN_RECON_RPT_PKG.match_ap_ar_invoice(fia.from_le_id, fia.ledger_id, glp.period_name, fia.to_le_id, ' ||
      nvl(to_char(p_tp_ledger_id), 'null') || ', '''||P_TP_GL_PERIOD ||''' , ' ||
   ' fia.type, ent.entity_code, ent.source_id_int_1) = ''UNMATCHED''   ';
   END IF;


   l_sum_unmatched_query := REPLACE(l_sum_unmatched_query, '$where_clause1$', l_add_where_clause1);
   l_sla_unmatched_query := l_sla_unmatched_query || l_add_where_clause1;

  --bug8844695 l_gl_balances_query1 := l_gl_balances_query1 ||
  --bug8844695                        ' ORDER BY TRANSACTING_LE, TRADING_PARTNER_LE, TRANSACTION_CURRENCY';


   l_jelines_sum_query := REPLACE (l_jelines_sum_query,
                                   '$get_accounts_query$',
                                   l_get_account_query);

   l_jelines_sum_query := l_jelines_sum_query ||
                          ' GROUP BY fun_act.transacting_le_id, '||
                                  ' fun_act.transacting_le, '||
                                  ' fun_act.trading_partner_le_id , '||
                                  ' fun_act.trading_partner_le, '||
                                  ' fun_act.transacting_ledger , '||
                                  ' fun_act.transacting_ledger_id, '||
                                  ' gjh.currency_code,   '||
                                  ' gjl.period_name , '||
                                  ' gjst.user_je_source_name, '||
                                  ' gjct.user_je_category_name ';

     --bug8844695                     'ORDER BY fun_act.transacting_le_id, '||
     --bug8844695                             ' fun_act.transacting_le, '||
     --bug8844695                             ' fun_act.trading_partner_le_id , '||
     --bug8844695                             ' fun_act.trading_partner_le, '||
     --bug8844695                             ' fun_act.transacting_ledger , '||
     --bug8844695                             ' fun_act.transacting_ledger_id, '||
     --bug8844695                             ' gjh.currency_code,   '||
     --bug8844695                             ' gjl.period_name , '||
     --bug8844695                             ' gjst.user_je_source_name, '||
     --bug8844695                             ' gjct.user_je_category_name ';


   l_sum_unmatched_query := l_sum_unmatched_query ||
                           ' GROUP BY
			       SRC_TRANS_LE_ID,
			       SRC_TRANS_LE,
			       SRC_TRAD_LE_ID,
			       SRC_TRAD_LE,
                               SRC_TRANS_LEDGER,
			       TRX_CURR,
			       PERIOD_NAME,
			       JOURNAL_SOURCE,
			       JOURNAL_CATEGORY ';
                            --ORDER BY SRC_TRANS_LE, SRC_TRAD_LE, TRX_CURR, JOURNAL_SOURCE, JOURNAL_CATEGORY ';

   l_jelines_gl_query := REPLACE (l_jelines_gl_query,
                                   '$get_accounts_query$',
                                   l_get_account_query);

   --bug8844695 l_jelines_gl_query := l_jelines_gl_query || '
   --bug8844695 ORDER BY TRANS_LE, TRAD_LE, ENTERED_CURRENCY, JE_SOURCE_NAME,  JE_CATEGORY_NAME, HEADER_ID, GL_LINE_NUMBER';

   --bug8844695 l_gl_unmatched_query := l_gl_unmatched_query || '
   --bug8844695 ORDER BY TRANS_LE, TRAD_LE, ENTERED_CURRENCY, JE_SOURCE_NAME,  JE_CATEGORY_NAME, HEADER_ID, GL_LINE_NUMBER';

   l_jelines_sla_query := REPLACE (l_jelines_sla_query,
                                   '$get_accounts_query$',
                                   l_get_account_query);

   --bug8844695 l_jelines_sla_query := l_jelines_sla_query || '
   --bug8844695 ORDER BY TRANS_LE, TRAD_LE, ENTERED_CURRENCY, JE_SOURCE_NAME, JE_CATEGORY_NAME, HEADER_ID, SLA_LINE_NUMBER';

 --bug8844695   l_sla_unmatched_query := l_sla_unmatched_query || '
   --bug8844695 ORDER BY TRANS_LE, TRAD_LE, ENTERED_CURRENCY, JE_SOURCE_NAME, JE_CATEGORY_NAME, HEADER_ID, SLA_LINE_NUMBER';


   -- Now do the queries to get the reverse side of the relationship
   -- so this is where the transacting_ledger becomes the trading_ledger
   -- and the trading ledger is now the transacting ledger.
   --Bug: 8947605
   l_gl_balances_query_rev  := C_FUN_GL_BALANCE_QUERY;
   l_gl_balances_query_rev1 := C_FUN_GL_BALANCE_QUERY1;
   l_get_account_query_rev  :=  C_FUN_GET_ACCTS_QUERY;
   l_jelines_sum_query_rev  := C_FUN_JELINES_SUM_QUERY;
   l_sum_unmatched_query_rev:= C_SUM_UNMATCHED_QUERY;
   l_jelines_gl_query_rev   := C_FUN_JELINES_GL_QUERY;
   l_gl_unmatched_query_rev := C_GL_UNMATCHED_QUERY;
   l_jelines_sla_query_rev  := C_FUN_JELINES_SLA_QUERY;
   l_sla_unmatched_query_rev   := C_SLA_UNMATCHED_QUERY;
   l_add_currency_cols      := C_ADD_CURRENCY_COLS;


   IF p_trans_ledger_id IS NOT NULL -- User input parameter
   THEN
       l_gl_balances_query_rev := l_gl_balances_query_rev || ' AND fia2.ledger_id = '||p_trans_ledger_id;

       l_get_account_query_rev := l_get_account_query_rev || ' AND fia2.ledger_id = '||p_trans_ledger_id;


       l_sum_unmatched_query_rev := l_sum_unmatched_query_rev || ' AND SRC_TRAD_LE_ID IN (SELECT tole.legal_entity_id
                                          FROM   gl_ledger_le_v tole
                                          WHERE  tole.ledger_id = '||p_trans_ledger_id ||')';

       l_gl_unmatched_query_rev  := l_gl_unmatched_query_rev || ' AND fia.to_le_id IN (SELECT tole.legal_entity_id
                                          FROM   gl_ledger_le_v tole
                                          WHERE  tole.ledger_id = '||p_trans_ledger_id ||')';

       l_sla_unmatched_query_rev  := l_sla_unmatched_query_rev || ' AND fia.to_le_id IN (SELECT tole.legal_entity_id
                                          FROM   gl_ledger_le_v tole
                                          WHERE  tole.ledger_id = '||p_trans_ledger_id ||')';

   END IF;

   IF p_trans_legal_entity_id IS NOT NULL -- User input parameter
   THEN
       l_gl_balances_query_rev := l_gl_balances_query_rev || ' AND fia2.from_le_id = '||P_TRANS_LEGAL_ENTITY_ID ;
       l_get_account_query_rev := l_get_account_query_rev || ' AND fia2.from_le_id = '||P_TRANS_LEGAL_ENTITY_ID ;
       l_sum_unmatched_query_rev := l_sum_unmatched_query_rev || ' AND SRC_TRAD_LE_ID = '||P_TRANS_LEGAL_ENTITY_ID ;
       l_gl_unmatched_query_rev  := l_gl_unmatched_query_rev  || '  AND fia.to_le_id = '||P_TRANS_LEGAL_ENTITY_ID ;
       l_sla_unmatched_query_rev  := l_sla_unmatched_query_rev || ' AND fia.to_le_id = '||P_TRANS_LEGAL_ENTITY_ID ;
   END IF;

   IF p_trans_gl_period IS NOT NULL -- User input parameter
   THEN
       l_gl_balances_query_rev := l_gl_balances_query_rev|| ' AND glp2.period_name = '''||p_trans_gl_period ||'''' ;
       l_jelines_sla_query_rev  := l_jelines_sla_query_rev || ' AND aeh.accounting_date BETWEEN '''||l_period_start_date ||''' AND ''' || l_period_end_date || '''';
       l_sla_unmatched_query_rev  := l_sla_unmatched_query_rev ||' AND aeh.accounting_date BETWEEN '''||l_period_start_date ||''' AND ''' || l_period_end_date || '''';
   END IF;

   IF p_tp_ledger_id IS NOT NULL -- User input parameter
   THEN
       l_gl_balances_query_rev  := l_gl_balances_query_rev || ' AND fia1.ledger_id = '||p_tp_ledger_id ;
       l_get_account_query_rev  := l_get_account_query_rev || ' AND fia1.ledger_id = '||p_tp_ledger_id;
       l_jelines_sum_query_rev  := l_jelines_sum_query_rev || ' AND gjl.ledger_id = '||p_tp_ledger_id;
       l_sum_unmatched_query_rev  := l_sum_unmatched_query_rev || ' AND SRC_TRANS_LEDGER_ID = '||p_tp_ledger_id;
       l_jelines_gl_query_rev   := l_jelines_gl_query_rev  || ' AND gjl.ledger_id = '||p_tp_ledger_id;
       l_gl_unmatched_query_rev   := l_gl_unmatched_query_rev  || ' AND fia.ledger_id = '||p_tp_ledger_id;
       l_jelines_sla_query_rev  := l_jelines_sla_query_rev || ' AND aeh.ledger_id = '||p_tp_ledger_id;
       l_sla_unmatched_query_rev  := l_sla_unmatched_query_rev || ' AND fia.ledger_id = '||p_tp_ledger_id;
   END IF;



   IF P_TP_LEGAL_ENTITY_ID IS NOT NULL -- User input parameter
   THEN
       l_gl_balances_query_rev := l_gl_balances_query_rev || ' AND fia1.from_le_id = '||P_TP_LEGAL_ENTITY_ID ;
       l_get_account_query_rev := l_get_account_query_rev || ' AND fia1.from_le_id = '||P_TP_LEGAL_ENTITY_ID ;
       l_gl_unmatched_query_rev  := l_gl_unmatched_query_rev  || ' AND fia.from_le_id = '||P_TP_LEGAL_ENTITY_ID ;
       l_sla_unmatched_query_rev := l_sla_unmatched_query_rev || ' AND fia.from_le_id = '||P_TP_LEGAL_ENTITY_ID ;
   END IF;


   IF p_tp_gl_period IS NOT NULL -- User input parameter
   THEN
       l_gl_balances_query_rev := l_gl_balances_query_rev || ' AND glb1.period_name = '''||p_tp_gl_period ||'''' ;
       l_jelines_sum_query_rev := l_jelines_sum_query_rev || ' AND gjl.period_name = '''||p_tp_gl_period ||'''' ;
       l_sum_unmatched_query_rev := l_sum_unmatched_query_rev || ' AND PERIOD_NAME = '''||p_tp_gl_period ||'''' ;
       l_jelines_gl_query_rev  := l_jelines_gl_query_rev  || ' AND gjl.period_name = '''||p_tp_gl_period ||'''' ;
       l_gl_unmatched_query_rev  := l_gl_unmatched_query_rev  || ' AND gjl.period_name = '''||p_tp_gl_period ||'''' ;
       l_jelines_sla_query_rev := l_jelines_sla_query_rev || ' AND aeh.period_name = '''||p_tp_gl_period ||'''' ;
       l_jelines_sla_query_rev  := l_jelines_sla_query_rev || ' AND aeh.accounting_date BETWEEN '''||l_period_start_date ||''' AND ''' || l_period_end_date || '''';
       l_sla_unmatched_query_rev := l_sla_unmatched_query_rev || ' AND aeh.period_name = '''||p_tp_gl_period ||'''' ;
       l_sla_unmatched_query_rev  := l_sla_unmatched_query_rev || ' AND aeh.accounting_date BETWEEN '''||l_period_start_date ||''' AND ''' || l_period_end_date || '''';
   ELSE
       -- find corresponding GL period in the relating ledger side.
       l_gl_balances_query_rev := l_gl_balances_query_rev ||
                              ' AND   ''' ||l_period_end_date||''' BETWEEN glp1.start_date and glp1.end_date
                                AND   glp1.adjustment_period_flag =  glp2.adjustment_period_flag';

       l_jelines_sum_query_rev := l_jelines_sum_query_rev ||
                              ' AND   ''' ||l_period_end_date||''' BETWEEN glp.start_date and glp.end_date';

       l_sum_unmatched_query_rev := l_sum_unmatched_query_rev ||
                              ' AND   ''' ||l_period_end_date||''' BETWEEN START_DATE and END_DATE';

       l_jelines_gl_query_rev := l_jelines_gl_query_rev ||
                              ' AND   ''' ||l_period_end_date||''' BETWEEN glp.start_date and glp.end_date ';

       l_gl_unmatched_query_rev := l_gl_unmatched_query_rev ||
                              ' AND   ''' ||l_period_end_date||''' BETWEEN glp.start_date and glp.end_date ';

       l_jelines_sla_query_rev := l_jelines_sla_query_rev ||
                              ' AND   ''' ||l_period_end_date||''' BETWEEN glp.start_date and glp.end_date ';

       l_sla_unmatched_query_rev := l_sla_unmatched_query_rev ||
                              ' AND   ''' ||l_period_end_date||''' BETWEEN glp.start_date and glp.end_date ';


   END IF;

   IF p_currency IS NOT NULL
   THEN
       l_gl_balances_query_rev1 := REPLACE(l_gl_balances_query_rev1,
                                     '$additional_currency_columns$',
                                      l_add_currency_cols);
   ELSE
       l_gl_balances_query_rev1 := REPLACE(l_gl_balances_query_rev1,
                                     '$additional_currency_columns$',
                                      ',NULL');
   END IF;

    l_gl_balances_query_rev1 := REPLACE(l_gl_balances_query_rev1,
                                     '$sub_query$',
                                      l_gl_balances_query_rev);


   l_add_where_clause1 := ' AND FUN_RECON_RPT_PKG.match_ap_ar_invoice(fia.from_le_id, fia.ledger_id, glp.period_name, fia.to_le_id, ' ||
   nvl(to_char(p_trans_ledger_id), 'null') || ', ''' || p_trans_gl_period||''' , ' ||
   ' fia.type, ent.entity_code, ent.source_id_int_1) = ''UNMATCHED''   ';

   l_sum_unmatched_query_rev := REPLACE(l_sum_unmatched_query_rev, '$where_clause1$', l_add_where_clause1);
   l_sla_unmatched_query_rev := l_sla_unmatched_query_rev || l_add_where_clause1;

   l_gl_balances_query_rev1 := l_gl_balances_query_rev1 ||
                          ' ORDER BY TRANSACTING_LE, TRADING_PARTNER_LE, TRANSACTION_CURRENCY';

   l_jelines_sum_query_rev := REPLACE(l_jelines_sum_query_rev,
                                       '$get_accounts_query$',
                                       l_get_account_query_rev);

   l_jelines_sum_query_rev := l_jelines_sum_query_rev ||
                         ' GROUP BY fun_act.transacting_le_id, '||
                                  ' fun_act.transacting_le, '||
                                  ' fun_act.trading_partner_le_id , '||
                                  ' fun_act.trading_partner_le, '||
                                  ' fun_act.transacting_ledger , '||
                                  ' fun_act.transacting_ledger_id, '||
                                  ' gjh.currency_code,   '||
                                  ' gjl.period_name , '||
                                  ' gjst.user_je_source_name, '||
                                  ' gjct.user_je_category_name '||
                          'ORDER BY SRC_TRANS_LE_ID , '||
			          ' SRC_TRANS_LE , '||
				  ' SRC_TRAD_LE_ID , '||
				  ' SRC_TRAD_LE , ' ||
				  ' SRC_TRANS_LEDGER , '||
				  ' SRC_TRANS_LEDGER_ID , '||
				  ' TRX_CURR , '||
				  ' PERIOD_NAME, '||
				  ' JOURNAL_SOURCE , '||
				  ' JOURNAL_CATEGORY ';

   l_sum_unmatched_query_rev := l_sum_unmatched_query_rev ||
                           ' GROUP BY SRC_TRANS_LE_ID, SRC_TRANS_LE, SRC_TRAD_LE_ID, SRC_TRAD_LE, SRC_TRANS_LEDGER,
                                      TRX_CURR,  PERIOD_NAME ,JOURNAL_SOURCE, JOURNAL_CATEGORY
                             ORDER BY SRC_TRANS_LE, SRC_TRAD_LE, TRX_CURR, JOURNAL_SOURCE, JOURNAL_CATEGORY';

   l_jelines_gl_query_rev := REPLACE (l_jelines_gl_query_rev,
                                   '$get_accounts_query$',
                                   l_get_account_query_rev);

   l_jelines_gl_query_rev := l_jelines_gl_query_rev || '
         ORDER BY TRANS_LE, TRAD_LE, ENTERED_CURRENCY, JE_SOURCE_NAME, JE_CATEGORY_NAME, HEADER_ID, GL_LINE_NUMBER';

   l_gl_unmatched_query_rev := l_gl_unmatched_query_rev || '
         ORDER BY TRANS_LE, TRAD_LE, ENTERED_CURRENCY, JE_SOURCE_NAME, JE_CATEGORY_NAME, HEADER_ID, GL_LINE_NUMBER';


   l_jelines_sla_query_rev := REPLACE (l_jelines_sla_query_rev,
                                   '$get_accounts_query$',
                                   l_get_account_query_rev);

   l_jelines_sla_query_rev := l_jelines_sla_query_rev || '
         ORDER BY TRANS_LE, TRAD_LE, ENTERED_CURRENCY, JE_SOURCE_NAME, JE_CATEGORY_NAME, HEADER_ID, SLA_LINE_NUMBER';

   l_sla_unmatched_query_rev := l_sla_unmatched_query_rev || '
         ORDER BY TRANS_LE, TRAD_LE, ENTERED_CURRENCY, JE_SOURCE_NAME, JE_CATEGORY_NAME, HEADER_ID, SLA_LINE_NUMBER';



   p_array_sql(2) := l_gl_balances_query1 || '       --bug8844695
                     UNION
		     ' || l_gl_balances_query_rev1;
   p_array_sql(3) := l_jelines_sum_query || '
                     UNION
		     ' || l_jelines_sum_query_rev;
   p_array_sql(4) := l_jelines_gl_query || '
                     UNION
		     ' || l_jelines_gl_query_rev ;
   p_array_sql(5) := l_jelines_sla_query || '
                     UNION
		     ' || l_jelines_sla_query_rev;

   p_array_sql(6) := l_sum_unmatched_query || '
                      UNION
		      ' || l_sum_unmatched_query_rev;
   p_array_sql(7) := l_gl_unmatched_query || '
                      UNION
		      ' || l_gl_unmatched_query_rev;
   p_array_sql(8) := l_sla_unmatched_query || '
                      UNION
		      ' || l_sla_unmatched_query_rev;     --bug8844695





   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg   => 'get_fun_main_sql.End'
           ,p_level =>C_LEVEL_PROCEDURE
           ,p_module=>l_Log_module);
   END IF;

EXCEPTION
WHEN OTHERS THEN
     FUN_UTIL.log_conc_unexp(C_DEFAULT_MODULE, 'get_fun_main_sql');
     RAISE;
END get_fun_main_sql ;


--=============================================================================
--
-- FUNCTION get_legal_entity
--
--=============================================================================
FUNCTION get_legal_entity(p_le_id NUMBER) RETURN VARCHAR2
IS
v_le_name varchar2(100);
BEGIN
   select distinct legal_entity_name
   into v_le_name
   from gl_ledger_le_v
   where legal_entity_id = p_le_id
   and rownum=1;

   return v_le_name;
EXCEPTION
WHEN OTHERS THEN
 return null;
END get_legal_entity;

--=============================================================================
--
-- BODY FOR THE PROCEDURE CLOB_TO_FILE
--
--=============================================================================
PROCEDURE clob_to_file
        (p_xml_clob           IN CLOB) IS

l_clob_size                NUMBER;
l_offset                   NUMBER;
l_chunk_size               INTEGER;
l_chunk                    VARCHAR2(32767);
l_log_module               VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.clob_to_file';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure CLOB_TO_FILE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_clob_size := dbms_lob.getlength(p_xml_clob);

   IF (l_clob_size = 0) THEN
      RETURN;
   END IF;
   l_offset     := 1;
   l_chunk_size := 3000;

   WHILE (l_clob_size > 0) LOOP
      l_chunk := dbms_lob.substr (p_xml_clob, l_chunk_size, l_offset);
      fnd_file.put
         (which     => fnd_file.output
         ,buff      => l_chunk);

      l_clob_size := l_clob_size - l_chunk_size;
      l_offset := l_offset + l_chunk_size;
   END LOOP;

   fnd_file.new_line(fnd_file.output,1);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure CLOB_TO_FILE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN OTHERS THEN
     FUN_UTIL.log_conc_unexp(C_DEFAULT_MODULE, 'clob_to_file');
     RAISE;
END clob_to_file;

--=============================================================================
--
-- BODY FOR THE FUNCTION get_balance
--
--=============================================================================

/* ----------------------------------------------------------------------------
   This function gets Receivables and Payables balances from gl_balances
------------------------------------------------------------------------------------*/


function get_balance(p_balance_type        varchar2,
                     p_column_name         varchar2,
                     p_trans_ledger_id     number,
                     p_trans_le_id         number,
                     p_trans_gl_period     varchar2,
                     p_trad_ledger_id      number,
                     p_trad_le_id          number,
                     p_trad_gl_period      varchar2,
                     p_currency            varchar2) return number is

l_begin_balance_dr	number;
l_begin_balance_cr	number;
l_period_net_dr		number;
l_period_net_cr		number;
l_currency              gl_balances.CURRENCY_CODE%TYPE;

begin





	if (p_balance_type = 'R') then

		select CURRENCY_CODE
		INTO l_currency
		from gl_ledgers
		where ledger_id = p_trans_ledger_id;

		if( l_currency <> p_currency) THEN

		   SELECT sum(glb.begin_balance_dr),
		   sum(glb.begin_balance_cr),
		   sum(glb.period_net_dr),
		   sum(glb.period_net_cr)
		   INTO l_begin_balance_dr, l_begin_balance_cr, l_period_net_dr, l_period_net_cr
		   FROM gl_balances        glb
		   WHERE glb.period_name    = p_trans_gl_period
		   AND   glb.ledger_id      = p_trans_ledger_id
		   AND   glb.actual_flag    = 'A'
		   AND   glb.currency_code  = p_currency
		   AND   glb.translated_flag = 'R'
		   AND   glb.code_combination_id IN (SELECT DISTINCT fia.ccid
						     FROM   fun_inter_accounts_v fia
						     WHERE  fia.ledger_id  = p_trans_ledger_id
						     AND    fia.from_le_id = p_trans_le_id
						     AND    fia.to_le_id   = p_trad_le_id
						     AND    fia.type       = 'R' );
		else

		   SELECT sum(glb.begin_balance_dr_beq),
		   sum(glb.begin_balance_cr_beq),
		   sum(glb.period_net_dr_beq),
		   sum(glb.period_net_cr_beq)
		   INTO l_begin_balance_dr, l_begin_balance_cr, l_period_net_dr, l_period_net_cr
		   FROM gl_balances        glb
		   WHERE glb.period_name    = p_trans_gl_period
		   AND   glb.ledger_id      = p_trans_ledger_id
		   AND   glb.actual_flag    = 'A'
		   AND   glb.currency_code  = p_currency
		   AND   glb.translated_flag is NULL
		   AND   glb.code_combination_id IN (SELECT DISTINCT fia.ccid
						     FROM   fun_inter_accounts_v fia
						     WHERE  fia.ledger_id  = p_trans_ledger_id
						     AND    fia.from_le_id = p_trans_le_id
						     AND    fia.to_le_id   = p_trad_le_id
						     AND    fia.type       = 'R' );
		end if;

	elsif (p_balance_type = 'P') then

		select CURRENCY_CODE
		INTO l_currency
		from gl_ledgers
		where ledger_id = p_trad_ledger_id;

		if( l_currency <> p_currency) THEN

		   SELECT sum(glb.begin_balance_dr), sum(glb.begin_balance_cr), sum(glb.period_net_dr), sum(glb.period_net_cr)
		   INTO l_begin_balance_dr, l_begin_balance_cr, l_period_net_dr, l_period_net_cr
		   FROM  gl_balances        glb
		   WHERE glb.period_name    = p_trad_gl_period
		   AND   glb.ledger_id      = p_trad_ledger_id
		   AND   glb.actual_flag    = 'A'
		   AND   glb.currency_code  = p_currency
		   AND   glb.translated_flag = 'R'
		   AND   glb.code_combination_id IN (SELECT DISTINCT fia.ccid
						     FROM   fun_inter_accounts_v fia
						     WHERE  fia.ledger_id  = p_trad_ledger_id
						     AND    fia.from_le_id = p_trad_le_id
						     AND    fia.to_le_id   = p_trans_le_id
						     AND    fia.type       = 'P' );

		else

		   SELECT sum(glb.begin_balance_dr_beq), sum(glb.begin_balance_cr_beq), sum(glb.period_net_dr_beq), sum(glb.period_net_cr_beq)
		   INTO l_begin_balance_dr, l_begin_balance_cr, l_period_net_dr, l_period_net_cr
		   FROM  gl_balances        glb
		   WHERE glb.period_name    = p_trad_gl_period
		   AND   glb.ledger_id      = p_trad_ledger_id
		   AND   glb.actual_flag    = 'A'
		   AND   glb.currency_code  = p_currency
		   AND   glb.translated_flag is NULL
		   AND   glb.code_combination_id IN (SELECT DISTINCT fia.ccid
						     FROM   fun_inter_accounts_v fia
						     WHERE  fia.ledger_id  = p_trad_ledger_id
						     AND    fia.from_le_id = p_trad_le_id
						     AND    fia.to_le_id   = p_trans_le_id
						     AND    fia.type       = 'P' );

	        end if;

end if;

if (p_column_name = 'BEGIN_BALANCE_DR') then
    return Nvl(l_begin_balance_dr,0);
elsif (p_column_name = 'BEGIN_BALANCE_CR') then
    return Nvl(l_begin_balance_cr,0);
elsif (p_column_name = 'PERIOD_NET_DR') then
    return Nvl(l_period_net_dr,0);
elsif (p_column_name = 'PERIOD_NET_CR') then
    return Nvl(l_period_net_cr,0);
end if;

exception
  when others then
    return 0;

end get_balance;

--=============================================================================
--
-- BODY FOR THE FUNCTION match_ap_ar_invoice
--
--=============================================================================

/* ----------------------------------------------------------------------------
   Match based on assumption that AR invoice number (customer_trx_id) is stamped
   on both AR and AP tables. If the totals on AR and AP side for the same invoice
   number matches then it returns 'MATCHED' else it returns 'UNMATCHED'
------------------------------------------------------------------------------------*/

Function match_ap_ar_invoice(p_trans_le_id        in       number,
                             p_trans_ledger_id    in       number,
                             p_trans_gl_period    in       varchar2,
                             p_trad_le_id         in       number,
                             p_trad_ledger_id     in       number,
                             p_trad_gl_period     in       varchar2,
                             p_account_type       in       varchar2, -- this will be 'R', or 'P'
                             p_entity_code        in       varchar2,
                             p_ap_ar_invoice_id   in       number) return varchar2 is


l_trans_le_id        number;
l_trans_ledger_id    number;
l_trans_gl_period    varchar2(15);
l_trad_le_id         number;
l_trad_ledger_id     number;
l_trad_gl_period     varchar2(15);

l_ar_invoice_id       number;
l_ap_invoice_id       number;
l_invoice_num         varchar2(50);
l_payables_net_cr     number;
l_receivables_net_dr  number;
l_trans_gl_prd_end_date   date;
l_trans_adj_period_flag   varchar2(1);

BEGIN

   if ((p_ap_ar_invoice_id is null) OR
      ((p_entity_code <> 'AP_INVOICES')  AND (p_entity_code <> 'BILLS_RECEIVABLE')))  then
      return 'UNMATCHED';
   end if;


   if (p_entity_code = 'AP_INVOICES') then
      l_ap_invoice_id := p_ap_ar_invoice_id;

      select invoice_num
      into l_invoice_num
      from ap_invoices_all
      where invoice_id = l_ap_invoice_id;

      -- this invoice_num is = ra_customer_trx_all.customer_trx_id (we are assuming)
      l_ar_invoice_id := to_number(l_invoice_num);

   elsif (p_entity_code = 'BILLS_RECEIVABLE') then
     l_ar_invoice_id := p_ap_ar_invoice_id;

     select invoice_id
     into l_ap_invoice_id
     from ap_invoices_all
     where invoice_num = l_ar_invoice_id;

   else
     return 'UNMATCHED';
   end if;

   l_trans_le_id := p_trans_le_id;
   l_trans_ledger_id := p_trans_ledger_id;
   l_trans_gl_period := p_trans_gl_period;

   l_trad_le_id := p_trad_le_id;

   if (p_trad_ledger_id is not null) then
       l_trad_ledger_id := p_trad_ledger_id;
   else
       null;
       ---- put some logic here if needed -------
   end if;

   if (p_trad_gl_period is not null) then
       l_trad_gl_period := p_trad_gl_period;
   elsif (l_trans_ledger_id = l_trad_ledger_id) then
       l_trad_gl_period := l_trans_gl_period;
   else
      -- get the end date of l_trans_gl_period for l_trans_ledger_id
        SELECT glp.end_date, glp.adjustment_period_flag
        INTO   l_trans_gl_prd_end_date, l_trans_adj_period_flag
        FROM   gl_periods glp,
               gl_ledgers gl
        WHERE  glp.period_set_name  = gl.period_set_name
        AND    glp.period_type      = gl.accounted_period_type
        AND    glp.period_name      = l_trans_gl_period
        AND    gl.ledger_id         = l_trans_ledger_id;

        SELECT glp.period_name
        INTO   l_trad_gl_period
        FROM   gl_periods glp,
               gl_ledgers gl
        WHERE  glp.period_set_name    = gl.period_set_name
        AND    glp.period_type        = gl.accounted_period_type
        AND    gl.ledger_id           = l_trad_ledger_id
        AND    l_trans_gl_prd_end_date     between glp.start_date and glp.end_date
        AND    glp.adjustment_period_flag = l_trans_adj_period_flag;

   end if;


if (p_account_type = 'P')  then

  SELECT
         sum(nvl(ael.entered_cr, 0) - nvl(ael.entered_dr, 0))
  INTO     l_payables_net_cr
  FROM     xla_ae_headers                   aeh
        ,xla_ae_lines                     ael
        ,xla_events                       xle
        ,xla_event_types_b                xet
        ,xla_transaction_entities         ent
        ,gl_import_references             gir
        ,gl_je_lines                      gjl
        ,gl_je_headers                    gjh
        ,gl_je_batches                    gjb
        ,gl_ledger_le_v                   glv
        ,fun_inter_accounts_v               fia
        ,gl_periods                       glp

  WHERE    aeh.accounting_entry_status_code   = 'F'
  AND    aeh.gl_transfer_status_code        = 'Y'
  AND    ael.ae_header_id                   = aeh.ae_header_id
  AND    ael.application_id                 = aeh.application_id
  AND    xle.event_id                       = aeh.event_id
  AND    xet.application_id                 = aeh.application_id
  AND    xet.event_type_code                = aeh.event_type_code
  AND    ent.entity_id                      = xle.entity_id
  AND    ent.application_id                 = xle.application_id
  AND    gir.gl_sl_link_id                  = ael.gl_sl_link_id
  AND    gir.gl_sl_link_table               = ael.gl_sl_link_table
  AND    gjl.je_header_id                   = gir.je_header_id
  AND    gjl.je_line_num                    = gir.je_line_num
  AND    gjh.je_header_id                   = gir.je_header_id
  AND    gjb.je_batch_id                    = gir.je_batch_id
  AND    gjb.status                         = 'P'
  AND    aeh.ledger_id                      = fia.ledger_id
  AND    aeh.balance_type_code              = 'A'
  AND    ael.code_combination_id            = fia.ccid
  AND    fia.ledger_id                      = glv.ledger_id
  AND    fia.from_le_id                     = glv.legal_entity_id
  AND    glv.period_set_name                = glp.period_set_name
  AND    glv.accounted_period_type          = glp.period_type
  AND    glp.period_name                    = aeh.period_name
  AND    ent.application_id = 200
  AND    ent.entity_code = 'AP_INVOICES'
  AND    ent.source_id_int_1 = l_ap_invoice_id
  AND    fia.type = 'P'
  AND    fia.from_le_id = l_trans_le_id
  AND    fia.ledger_id = l_trans_ledger_id
  AND    glp.period_name = l_trans_gl_period
  AND    fia.to_le_id = l_trad_le_id;

  SELECT
         sum(nvl(ael.entered_dr, 0) - nvl(ael.entered_cr, 0))
  INTO     l_receivables_net_dr
  FROM     xla_ae_headers                   aeh
        ,xla_ae_lines                     ael
        ,xla_events                       xle
        ,xla_event_types_b                xet
        ,xla_transaction_entities         ent
        ,gl_import_references             gir
        ,gl_je_lines                      gjl
        ,gl_je_headers                    gjh
        ,gl_je_batches                    gjb
        ,gl_ledger_le_v                   glv
        ,fun_inter_accounts_v               fia
        ,gl_periods                       glp

  WHERE    aeh.accounting_entry_status_code   = 'F'
  AND    aeh.gl_transfer_status_code        = 'Y'
  AND    ael.ae_header_id                   = aeh.ae_header_id
  AND    ael.application_id                 = aeh.application_id
  AND    xle.event_id                       = aeh.event_id
  AND    xet.application_id                 = aeh.application_id
  AND    xet.event_type_code                = aeh.event_type_code
  AND    ent.entity_id                      = xle.entity_id
  AND    ent.application_id                 = xle.application_id
  AND    gir.gl_sl_link_id                  = ael.gl_sl_link_id
  AND    gir.gl_sl_link_table               = ael.gl_sl_link_table
  AND    gjl.je_header_id                   = gir.je_header_id
  AND    gjl.je_line_num                    = gir.je_line_num
  AND    gjh.je_header_id                   = gir.je_header_id
  AND    gjb.je_batch_id                    = gir.je_batch_id
  AND    gjb.status                         = 'P'
  AND    aeh.ledger_id                      = fia.ledger_id
  AND    aeh.balance_type_code              = 'A'
  AND    ael.code_combination_id            = fia.ccid
  AND    fia.ledger_id                      = glv.ledger_id
  AND    fia.from_le_id                     = glv.legal_entity_id
  AND    glv.period_set_name                = glp.period_set_name
  AND    glv.accounted_period_type          = glp.period_type
  AND    glp.period_name                    = aeh.period_name

  AND    ent.application_id = 222
  AND    ent.entity_code = 'BILLS_RECEIVABLE'
  AND    ent.source_id_int_1 = l_ar_invoice_id
  AND    fia.type = 'R'
  AND    fia.from_le_id = l_trad_le_id
  AND    fia.ledger_id = nvl(l_trad_ledger_id, fia.ledger_id)
  AND    glp.period_name = l_trad_gl_period
  AND    fia.to_le_id = l_trans_le_id;

elsif (p_account_type = 'R') then

   SELECT
         sum(nvl(ael.entered_cr, 0) - nvl(ael.entered_dr, 0))
  INTO     l_payables_net_cr
  FROM     xla_ae_headers                   aeh
        ,xla_ae_lines                     ael
        ,xla_events                       xle
        ,xla_event_types_b                xet
        ,xla_transaction_entities         ent
        ,gl_import_references             gir
        ,gl_je_lines                      gjl
        ,gl_je_headers                    gjh
        ,gl_je_batches                    gjb
        ,gl_ledger_le_v                   glv
        ,fun_inter_accounts_v               fia
        ,gl_periods                       glp

  WHERE    aeh.accounting_entry_status_code   = 'F'
  AND    aeh.gl_transfer_status_code        = 'Y'
  AND    ael.ae_header_id                   = aeh.ae_header_id
  AND    ael.application_id                 = aeh.application_id
  AND    xle.event_id                       = aeh.event_id
  AND    xet.application_id                 = aeh.application_id
  AND    xet.event_type_code                = aeh.event_type_code
  AND    ent.entity_id                      = xle.entity_id
  AND    ent.application_id                 = xle.application_id
  AND    gir.gl_sl_link_id                  = ael.gl_sl_link_id
  AND    gir.gl_sl_link_table               = ael.gl_sl_link_table
  AND    gjl.je_header_id                   = gir.je_header_id
  AND    gjl.je_line_num                    = gir.je_line_num
  AND    gjh.je_header_id                   = gir.je_header_id
  AND    gjb.je_batch_id                    = gir.je_batch_id
  AND    gjb.status                         = 'P'
  AND    aeh.ledger_id                      = fia.ledger_id
  AND    aeh.balance_type_code              = 'A'
  AND    ael.code_combination_id            = fia.ccid
  AND    fia.ledger_id                      = glv.ledger_id
  AND    fia.from_le_id                     = glv.legal_entity_id
  AND    glv.period_set_name                = glp.period_set_name
  AND    glv.accounted_period_type          = glp.period_type
  AND    glp.period_name                    = aeh.period_name
  AND    ent.application_id = 200
  AND    ent.entity_code = 'AP_INVOICES'
  AND    ent.source_id_int_1 = l_ap_invoice_id
  AND    fia.type = 'P'
  AND    fia.from_le_id = l_trad_le_id
  AND    fia.ledger_id = nvl(l_trad_ledger_id, fia.ledger_id)
  AND    glp.period_name = l_trad_gl_period;

  SELECT
         sum(nvl(ael.entered_dr, 0) - nvl(ael.entered_cr, 0))
  INTO     l_receivables_net_dr
  FROM     xla_ae_headers                   aeh
        ,xla_ae_lines                     ael
        ,xla_events                       xle
        ,xla_event_types_b                xet
        ,xla_transaction_entities         ent
        ,gl_import_references             gir
        ,gl_je_lines                      gjl
        ,gl_je_headers                    gjh
        ,gl_je_batches                    gjb
        ,gl_ledger_le_v                   glv
        ,fun_inter_accounts_v               fia
        ,gl_periods                       glp

  WHERE    aeh.accounting_entry_status_code   = 'F'
  AND    aeh.gl_transfer_status_code        = 'Y'
  AND    ael.ae_header_id                   = aeh.ae_header_id
  AND    ael.application_id                 = aeh.application_id
  AND    xle.event_id                       = aeh.event_id
  AND    xet.application_id                 = aeh.application_id
  AND    xet.event_type_code                = aeh.event_type_code
  AND    ent.entity_id                      = xle.entity_id
  AND    ent.application_id                 = xle.application_id
  AND    gir.gl_sl_link_id                  = ael.gl_sl_link_id
  AND    gir.gl_sl_link_table               = ael.gl_sl_link_table
  AND    gjl.je_header_id                   = gir.je_header_id
  AND    gjl.je_line_num                    = gir.je_line_num
  AND    gjh.je_header_id                   = gir.je_header_id
  AND    gjb.je_batch_id                    = gir.je_batch_id
  AND    gjb.status                         = 'P'
  AND    aeh.ledger_id                      = fia.ledger_id
  AND    aeh.balance_type_code              = 'A'
  AND    ael.code_combination_id            = fia.ccid
  AND    fia.ledger_id                      = glv.ledger_id
  AND    fia.from_le_id                     = glv.legal_entity_id
  AND    glv.period_set_name                = glp.period_set_name
  AND    glv.accounted_period_type          = glp.period_type
  AND    glp.period_name                    = aeh.period_name

  AND    ent.application_id = 222
  AND    ent.entity_code = 'BILLS_RECEIVABLE'
  AND    ent.source_id_int_1 = l_ar_invoice_id
  AND    fia.type = 'R'
  AND    fia.from_le_id = l_trans_le_id
  AND    fia.ledger_id = l_trans_ledger_id
  AND    glp.period_name = l_trans_gl_period;

end if;

  IF (l_payables_net_cr = l_receivables_net_dr) then
      return 'MATCHED';
  ELSE
      return 'UNMATCHED';

  END IF;


 EXCEPTION
     WHEN OTHERS THEN
       return  'UNMATCHED';
 END match_ap_ar_invoice;


--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

--=============================================================================
-- Following code is executed when the package body is referenced for the first
-- time
--=============================================================================

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END FUN_RECON_RPT_PKG;

/
