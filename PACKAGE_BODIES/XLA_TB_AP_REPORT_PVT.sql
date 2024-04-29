--------------------------------------------------------
--  DDL for Package Body XLA_TB_AP_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TB_AP_REPORT_PVT" AS
/* $Header: xlatbapt.pkb 120.2.12010000.9 2010/03/17 13:29:17 vgopiset noship $ */


--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Global Constants                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

C_TB_SOURCE_SQL    CONSTANT VARCHAR2(32000) := '
SELECT
      gcck.concatenated_segments           ACCOUNT
     ,$gl_balance_cols$                    GL_BALANCE
     ,tbg.code_combination_id              CODE_COMBINATION_ID
     ,tbg.balancing_segment_value          BALANCING_SEGMENT_VALUE
     ,tbg.natural_account_segment_value    NATURAL_ACCOUNT_SEGMENT_VALUE
     ,tbg.cost_center_segment_value        COST_CENTER_SEGMENT_VALUE
     ,tbg.management_segment_value         MANAGEMENT_SEGMENT_VALUE
     ,tbg.intercompany_segment_value       INTERCOMPANY_SEGMENT_VALUE
     ,tbg.ledger_id                        LEDGER_ID
     ,tbg.ledger_name                      LEDGER_NAME
     ,tbg.ledger_short_name                LEDGER_SHORT_NAME
     ,tbg.ledger_currency_code             LEDGER_CURRENCY_CODE
     ,tbg.third_party_name                 THIRD_PARTY_NAME
     ,tbg.third_party_number               THIRD_PARTY_NUMBER
     ,tbg.third_party_type_code            THIRD_PARTY_TYPE_CODE
     ,tbg.third_party_type                 THIRD_PARTY_TYPE
     ,tbg.third_party_site_name            THIRD_PARTY_SITE_NAME
     ,tbg.source_application_id            SOURCE_TRX_APPLICATION_ID
     ,tbg.source_entity_id                 SOURCE_ENTITY_ID
     ,app.application_name                 SOURCE_TRX_APPLICATION_NAME
     ,ett.name                             SOURCE_TRX_TYPE
     ,tbg.transaction_number               SOURCE_TRX_NUMBER
     ,to_char(tbg.gl_date,''YYYY-MM-DD'')  SOURCE_TRX_GL_DATE
     ,tbg.trx_currency_code                SOURCE_TRX_CURR
     ,tbg.entered_unrounded_orig_amount    SRC_ENTERED_UNROUNDED_ORIG_AMT
     ,tbg.entered_unrounded_rem_amount     SRC_ENTERED_UNROUNDED_REM_AMT
     ,tbg.entered_rounded_orig_amount      SRC_ENTERED_ROUNDED_ORIG_AMT
     ,tbg.entered_rounded_rem_amount       SRC_ENTERED_ROUNDED_REM_AMT
     ,tbg.acctd_unrounded_orig_amount      SRC_ACCTD_UNROUNDED_ORIG_AMT
     ,tbg.acctd_unrounded_rem_amount       SRC_ACCTD_UNROUNDED_REM_AMT
     ,tbg.acctd_rounded_orig_amount        SRC_ACCTD_ROUNDED_ORIG_AMT
     ,tbg.acctd_rounded_rem_amount         SRC_ACCTD_ROUNDED_REM_AMT
     ,tbg.user_trx_identifier_name_1       USER_TRX_IDENTIFIER_NAME_1
     ,tbg.user_trx_identifier_name_2       USER_TRX_IDENTIFIER_NAME_2
     ,tbg.user_trx_identifier_name_3       USER_TRX_IDENTIFIER_NAME_3
     ,tbg.user_trx_identifier_name_4       USER_TRX_IDENTIFIER_NAME_4
     ,tbg.user_trx_identifier_name_5       USER_TRX_IDENTIFIER_NAME_5
     ,tbg.user_trx_identifier_name_6       USER_TRX_IDENTIFIER_NAME_6
     ,tbg.user_trx_identifier_name_7       USER_TRX_IDENTIFIER_NAME_7
     ,tbg.user_trx_identifier_name_8       USER_TRX_IDENTIFIER_NAME_8
     ,tbg.user_trx_identifier_name_9       USER_TRX_IDENTIFIER_NAME_9
     ,tbg.user_trx_identifier_name_10      USER_TRX_IDENTIFIER_NAME_10
     ,tbg.user_trx_identifier_value_1      USER_TRX_IDENTIFIER_VALUE_1
     ,tbg.user_trx_identifier_value_2      USER_TRX_IDENTIFIER_VALUE_2
     ,tbg.user_trx_identifier_value_3      USER_TRX_IDENTIFIER_VALUE_3
     ,tbg.user_trx_identifier_value_4      USER_TRX_IDENTIFIER_VALUE_4
     ,tbg.user_trx_identifier_value_5      USER_TRX_IDENTIFIER_VALUE_5
     ,tbg.user_trx_identifier_value_6      USER_TRX_IDENTIFIER_VALUE_6
     ,tbg.user_trx_identifier_value_7      USER_TRX_IDENTIFIER_VALUE_7
     ,tbg.user_trx_identifier_value_8      USER_TRX_IDENTIFIER_VALUE_8
     ,tbg.user_trx_identifier_value_9      USER_TRX_IDENTIFIER_VALUE_9
     ,tbg.user_trx_identifier_value_10     USER_TRX_IDENTIFIER_VALUE_10
     ,tbg.NON_AP_AMOUNT                    NON_AP_AMOUNT
     ,tbg.MANUAL_SLA_AMOUNT                MANUAL_SLA_AMOUNT
$seg_desc_cols$
FROM   xla_trial_balances_gt            tbg
     ,fnd_application_vl                app
     ,xla_entity_types_vl               ett
     ,gl_code_combinations_kfv          gcck
     ,gl_balances                       gb
     $seg_desc_from$
WHERE  tbg.source_entity_code          = ett.entity_code
  AND tbg.source_application_id       = ett.application_id
  AND tbg.source_application_id       = app.application_id
  AND tbg.code_combination_id         = gcck.code_combination_id
 $gl_balance_join$
$seg_desc_join$
 ';

--added TB phase 4 bug#7600550
C_SELECT_NONAP_AMOUNT  CONSTANT  VARCHAR2(32000) :=
'
WITH xtd AS
       (
         SELECT /*+ materialize */
                DISTINCT p.ledger_id, d.code_combination_id,
                p.period_name,
                rpad(''x'',500) pad
         FROM   xla_tb_defn_details d,
                xla_tb_definitions_vl vl,
                gl_period_statuses p
         WHERE d.definition_code = ''$p_definition_code$''
         AND   vl.definition_code = d.definition_code
         AND   p.application_id =200
         AND   p.ledger_id = vl.ledger_id
         AND   p.start_date >= NVL(:1,  p.start_date + 1)
         AND   p.end_date   <= NVL(:2,  p.end_date   + 1)
         AND NVL(p.adjustment_period_flag,''N'')=''N''
       )
SELECT  /*+ leading(xtd,l,h,gcck) parallel(xtd) pq_distribute(l,broadcast,none)
            use_nl(l,gcck,h) parallel(l) parallel(h) parallel(gcck)
         */
        l.ledger_id,
        l.code_combination_id,
        sum(nvl(l.accounted_cr, 0))- sum(nvl(l.accounted_dr,0)) NONAP_AMOUNT
FROM    gl_je_headers h
       ,gl_je_lines l
       ,gl_code_combinations_kfv gcck
       ,xtd
WHERE l.code_combination_id = gcck.code_combination_id
  AND l.code_combination_id = xtd.code_combination_id
  AND l.ledger_id = xtd.ledger_id
  AND l.period_name = xtd.period_name
  AND h.je_source <> ''Payables''
  AND  h.je_header_id = l.je_header_id
  AND h.ledger_id = l.ledger_id
  AND h.actual_flag = ''A''
  AND h.status = ''P''
  AND l.effective_date BETWEEN NVL(:3, l.effective_date )
                       AND NVL(:4, l.effective_date + 1 )
GROUP BY l.ledger_id,l.code_combination_id
';


C_SELECT_MANUAL_SLA_AMOUNT  CONSTANT  VARCHAR2(32000) :=
'
WITH xtd AS
       (
         SELECT /*+ materialize */ DISTINCT ledger_id, code_combination_id,
                                rpad(''x'',500) pad
         FROM   xla_tb_defn_details d,
                xla_tb_definitions_vl vl
         WHERE d.definition_code = ''$p_definition_code$''
         AND   vl.definition_code = d.definition_code
       )
SELECT  /*+ leading(xtd,gcck,l,h) parallel(xtd) pq_distribute(l,broadcast,none)
            use_nl(l,gcck,h ) parallel(l) parallel(h) parallel(gcck)
         */
        l.ledger_id,
        l.code_combination_id,
        sum(nvl(accounted_cr,0))-sum(nvl(accounted_dr,0)) MANUAL_SLA_AMOUNT
FROM xla_ae_headers h,
     xla_ae_lines l,
     gl_code_combinations_kfv gcck,
     xtd
WHERE gcck.code_combination_id = l.code_combination_id
AND h.application_id = 200
AND gcck.code_combination_id = xtd.code_combination_id
AND l.application_id = h.application_id
AND l.ae_header_id = h.ae_header_id
AND h.ledger_id = l.ledger_id
AND h.gl_transfer_status_code=''Y''
AND h.accounting_entry_status_code=''F''
AND h.event_type_code=''MANUAL''
AND h.balance_type_code=''A''
AND h.ledger_id = xtd.ledger_id
AND h.accounting_date BETWEEN NVL(:1, h.accounting_date )
                                   AND NVL(:2, h.accounting_date + 1 )
GROUP BY l.ledger_id,l.code_combination_id
';


--added TB phase 4 bug#7600550 bug#8291101
C_SELECT_NONAP_SEGRANGES_AMT  CONSTANT  VARCHAR2(32000) :=
'WITH xtd AS
       (
         SELECT /*+ materialize */
                DISTINCT gcck.code_combination_id, vl.ledger_id,
                rpad(''x'',500) pad
         FROM
                xla_tb_definitions_vl vl,
                gl_code_combinations_kfv gcck
         WHERE vl.definition_code = ''$p_definition_code$''
         $gcck_join$
         AND EXISTS
         ( SELECT /*+ no_unnest */ 1
           FROM xla_trial_balances xtb
           WHERE xtb.code_combination_id = gcck.code_combination_id
           AND xtb.definition_code = vl.definition_code
         )
       )
SELECT  /*+ leading(xtd,l,p,h) parallel(xtd) pq_distribute(l,broadcast,none)
            use_nl(l,h,p) parallel(p) ,parallel(l) parallel(h)
         */
        l.ledger_id,
        l.code_combination_id,
        sum(nvl(l.accounted_cr, 0))- sum(nvl(l.accounted_dr,0)) NONAP_AMOUNT
FROM    gl_je_headers h
       ,gl_je_lines l
       ,xtd
       ,gl_period_statuses p
WHERE l.code_combination_id = xtd.code_combination_id
  AND l.ledger_id = xtd.ledger_id
  AND l.period_name = p.period_name
  AND h.je_source <> ''Payables''
  AND  h.je_header_id = l.je_header_id
  AND h.ledger_id = l.ledger_id
  AND h.actual_flag = ''A''
  AND h.status = ''P''
  AND l.effective_date BETWEEN NVL(:1, l.effective_date )
                       AND NVL(:2, l.effective_date + 1 )
  AND   p.application_id =200
  AND   p.ledger_id = xtd.ledger_id
  AND NVL(p.adjustment_period_flag,''N'')=''N''
GROUP BY l.ledger_id,l.code_combination_id
';

--added TB phase 4 bug#7600550 bug#8291101
C_SELECT_MANUAL_SEGRANGES_AMT  CONSTANT  VARCHAR2(32000) :=
'
WITH xtd AS
       (
         SELECT /*+ materialize */
                DISTINCT gcck.code_combination_id, vl.ledger_id,
                rpad(''x'',500) pad
         FROM
                xla_tb_definitions_vl vl,
                gl_code_combinations_kfv gcck
         WHERE vl.definition_code = ''$p_definition_code$''
         $gcck_join$
         AND EXISTS
         ( SELECT /*+ no_unnest */ 1
           FROM xla_trial_balances xtb
           WHERE xtb.code_combination_id = gcck.code_combination_id
           AND xtb.definition_code = vl.definition_code
         )
       )
SELECT  /*+ leading(xtd,l,h) parallel(xtd) pq_distribute(l,broadcast,none)
            use_nl(l,h) parallel(l) parallel(h)
         */
        l.ledger_id,
        l.code_combination_id,
        sum(nvl(accounted_cr,0))-sum(nvl(accounted_dr,0)) MANUAL_SLA_AMOUNT
FROM xla_ae_headers h,
     xla_ae_lines l,
     xtd
WHERE h.application_id = 200
AND h.application_id = l.application_id
AND h.ae_header_id   = l.ae_header_id
AND h.ledger_id      = l.ledger_id
AND h.ledger_id      = xtd.ledger_id
AND l.code_combination_id = xtd.code_combination_id
AND h.gl_transfer_status_code=''Y''
AND h.accounting_entry_status_code=''F''
AND h.event_type_code= ''MANUAL''
AND h.balance_type_code=''A''
AND h.ledger_id = xtd.ledger_id
AND h.accounting_date BETWEEN NVL(:1, h.accounting_date )
                                   AND NVL(:2, h.accounting_date + 1 )
GROUP BY l.ledger_id,l.code_combination_id
';

--end bug#7600550 bug#8291101

C_TB_WRITE_OFF_SQL    CONSTANT VARCHAR2(32000) := '
SELECT
      gcck.concatenated_segments           ACCOUNT
     ,$gl_balance_cols$                    GL_BALANCE
     ,tbg.code_combination_id              CODE_COMBINATION_ID
     ,tbg.balancing_segment_value          BALANCING_SEGMENT_VALUE
     ,tbg.natural_account_segment_value    NATURAL_ACCOUNT_SEGMENT_VALUE
     ,tbg.cost_center_segment_value        COST_CENTER_SEGMENT_VALUE
     ,tbg.management_segment_value         MANAGEMENT_SEGMENT_VALUE
     ,tbg.intercompany_segment_value       INTERCOMPANY_SEGMENT_VALUE
     ,tbg.ledger_id                        LEDGER_ID
     ,tbg.ledger_name                      LEDGER_NAME
     ,tbg.ledger_short_name                LEDGER_SHORT_NAME
     ,tbg.ledger_currency_code             LEDGER_CURRENCY_CODE
     ,tbg.third_party_name                 THIRD_PARTY_NAME
     ,tbg.third_party_number               THIRD_PARTY_NUMBER
     ,tbg.third_party_type_code            THIRD_PARTY_TYPE_CODE
     ,tbg.third_party_type                 THIRD_PARTY_TYPE
     ,tbg.third_party_site_name            THIRD_PARTY_SITE_NAME
     ,tbg.source_application_id            SOURCE_TRX_APPLICATION_ID
     ,tbg.source_entity_id                 SOURCE_ENTITY_ID
     ,app.application_name                 SOURCE_TRX_APPLICATION_NAME
     ,''$write_off$''                      SOURCE_TRX_TYPE
     ,tbg.transaction_number               SOURCE_TRX_NUMBER
     ,to_char(tbg.gl_date,''YYYY-MM-DD'')  SOURCE_TRX_GL_DATE
     ,tbg.trx_currency_code                SOURCE_TRX_CURR
     ,tbg.entered_unrounded_orig_amount    SRC_ENTERED_UNROUNDED_ORIG_AMT
     ,tbg.entered_unrounded_rem_amount     SRC_ENTERED_UNROUNDED_REM_AMT
     ,tbg.entered_rounded_orig_amount      SRC_ENTERED_ROUNDED_ORIG_AMT
     ,tbg.entered_rounded_rem_amount       SRC_ENTERED_ROUNDED_REM_AMT
     ,tbg.acctd_unrounded_orig_amount      SRC_ACCTD_UNROUNDED_ORIG_AMT
     ,tbg.acctd_unrounded_rem_amount       SRC_ACCTD_UNROUNDED_REM_AMT
     ,tbg.acctd_rounded_orig_amount        SRC_ACCTD_ROUNDED_ORIG_AMT
     ,tbg.acctd_rounded_rem_amount         SRC_ACCTD_ROUNDED_REM_AMT
     ,tbg.user_trx_identifier_name_1       USER_TRX_IDENTIFIER_NAME_1
     ,tbg.user_trx_identifier_name_2       USER_TRX_IDENTIFIER_NAME_2
     ,tbg.user_trx_identifier_name_3       USER_TRX_IDENTIFIER_NAME_3
     ,tbg.user_trx_identifier_name_4       USER_TRX_IDENTIFIER_NAME_4
     ,tbg.user_trx_identifier_name_5       USER_TRX_IDENTIFIER_NAME_5
     ,tbg.user_trx_identifier_name_6       USER_TRX_IDENTIFIER_NAME_6
     ,tbg.user_trx_identifier_name_7       USER_TRX_IDENTIFIER_NAME_7
     ,tbg.user_trx_identifier_name_8       USER_TRX_IDENTIFIER_NAME_8
     ,tbg.user_trx_identifier_name_9       USER_TRX_IDENTIFIER_NAME_9
     ,tbg.user_trx_identifier_name_10      USER_TRX_IDENTIFIER_NAME_10
     ,tbg.user_trx_identifier_value_1      USER_TRX_IDENTIFIER_VALUE_1
     ,tbg.user_trx_identifier_value_2      USER_TRX_IDENTIFIER_VALUE_2
     ,tbg.user_trx_identifier_value_3      USER_TRX_IDENTIFIER_VALUE_3
     ,tbg.user_trx_identifier_value_4      USER_TRX_IDENTIFIER_VALUE_4
     ,tbg.user_trx_identifier_value_5      USER_TRX_IDENTIFIER_VALUE_5
     ,tbg.user_trx_identifier_value_6      USER_TRX_IDENTIFIER_VALUE_6
     ,tbg.user_trx_identifier_value_7      USER_TRX_IDENTIFIER_VALUE_7
     ,tbg.user_trx_identifier_value_8      USER_TRX_IDENTIFIER_VALUE_8
     ,tbg.user_trx_identifier_value_9      USER_TRX_IDENTIFIER_VALUE_9
     ,tbg.user_trx_identifier_value_10     USER_TRX_IDENTIFIER_VALUE_10
     ,tbg.NON_AP_AMOUNT                    NON_AP_AMOUNT
     ,tbg.MANUAL_SLA_AMOUNT                MANUAL_SLA_AMOUNT
     $seg_desc_cols$
 FROM xla_trial_balances_gt    tbg
     ,fnd_application_vl       app
     ,gl_code_combinations_kfv gcck
     ,gl_balances              gb
     $seg_desc_from$
WHERE tbg.record_type_code            = ''SOURCE''
  AND tbg.source_application_id       = app.application_id
  AND tbg.code_combination_id         = gcck.code_combination_id
  AND tbg.acctd_rounded_rem_amount    <> 0
  AND tbg.acctd_unrounded_rem_amount  = 0
$gl_balance_join$
$seg_desc_join$
 ';

-- Perf changes for TB Report Summary Template bug:8773522 --
C_INSERT_GT_SUMMARY_STATEMENT    CONSTANT VARCHAR2(32000) := '
INSERT INTO xla_trial_balances_gt
         (definition_code
          ,ledger_id
          ,ledger_name
          ,ledger_short_name
          ,ledger_currency_code
          ,record_type_code
          ,source_application_id
         ,code_combination_id
         ,acctd_unrounded_orig_amount
         ,acctd_rounded_orig_amount
         ,entered_unrounded_rem_amount
         ,entered_rounded_rem_amount
         ,acctd_unrounded_rem_amount
         ,acctd_rounded_rem_amount
         ,third_party_name
         ,third_party_number
         ,balancing_segment_value
         ,natural_account_segment_value
         ,cost_center_segment_value
         ,intercompany_segment_value
         ,management_segment_value
         ,trx_currency_code) ';

-- Perf changes for TB Report Summary Template bug:8773522 --
C_INSERT_GT_SUMMARY_SELECT    CONSTANT VARCHAR2(32000) := '
SELECT
summary_dat.definition_code,
summary_dat.ledger_id,
gl.name,
gl.short_name,
gl.currency_code,
''SUMMARY'',
summary_dat.source_application_id,
summary_dat.code_combination_id,
decode(gl.ledger_category_code,''PRIMARY'',summary_dat.SUM_acctd_unrounded_orig_amt ,0),
decode(gl.ledger_category_code,''PRIMARY'',summary_dat.SUM_acctd_rounded_orig_amt,0),
summary_dat.sum_entd_unrounded_rem_amount,
summary_dat.sum_entd_rounded_rem_amount,
summary_dat.sum_acctd_unrounded_rem_amount,
summary_dat.sum_acctd_rounded_rem_amount,
summary_dat.party_name,
summary_dat.party_id,
summary_dat.balancing_segment_value,
summary_dat.natural_account_segment_value,
summary_dat.cost_center_segment_value,
summary_dat.intercompany_segment_value,
summary_dat.management_segment_value,
gl.currency_code
FROM
    (
        SELECT
		tb.definition_code,
		tb.ledger_id,
		tb.source_application_id,
		tb.code_combination_id,
		SUM(tb.entered_unrounded_rem_amount) SUM_ENTD_UNROUNDED_REM_AMOUNT,
		SUM(tb.entered_rounded_rem_amount) SUM_entd_rounded_rem_amount ,
		SUM(tb.acctd_unrounded_rem_amount) SUM_acctd_unrounded_rem_amount ,
		SUM(tb.acctd_rounded_rem_amount) SUM_acctd_rounded_rem_amount ,
		SUM(nvl(tiv.base_amount,tiv.invoice_amount)) SUM_acctd_unrounded_orig_amt,
		SUM(nvl(tiv.base_amount,tiv.invoice_amount)) SUM_acctd_rounded_orig_amt,
		tiv.party_name,
		tb.party_id,
		tb.balancing_segment_value,
		tb.natural_account_segment_value,
		tb.cost_center_segment_value,
		tb.intercompany_segment_value,
		tb.management_segment_value
	FROM
		AP_SLA_INVOICES_TRANSACTION_V tiv,
		xla_transaction_entities xte,
		-- inline view
		( SELECT /*+ parallel(xtb) leading(xtb) NO_MERGE */  --added hint bug#8409806 bug9133956
		xtb.definition_code,
		nvl(xtb.applied_to_entity_id,xtb.source_entity_id) entity_id,
		xtb.code_combination_id ,
		xtb.source_application_id,
		SUM (Nvl(xtb.entered_unrounded_cr,0)) -  SUM (Nvl(xtb.entered_unrounded_dr,0)) entered_unrounded_rem_amount,
		SUM (Nvl(xtb.entered_rounded_cr,0)) -  SUM (Nvl(xtb.entered_rounded_dr,0)) entered_rounded_rem_amount,
		SUM (Nvl(xtb.acctd_unrounded_cr,0)) -  SUM (Nvl(xtb.acctd_unrounded_dr,0)) acctd_unrounded_rem_amount,
		SUM (Nvl(xtb.acctd_rounded_cr,0)) -  SUM (Nvl(xtb.acctd_rounded_dr,0)) acctd_rounded_rem_amount,
		xtb.ledger_id,
		xtb.party_id,
		xtb.balancing_segment_value,
		xtb.natural_account_segment_value,
		xtb.cost_center_segment_value,
		xtb.intercompany_segment_value,
		xtb.management_segment_value
		FROM     xla_trial_balances xtb
		where    xtb.definition_code = :1
			 and xtb.source_application_id=200
			 and xtb.gl_date between :2 and :3
			 AND NVL(xtb.party_id,-99)    = NVL(:4,NVL(xtb.party_id,-99))
		    GROUP BY  xtb.definition_code,
			 nvl(xtb.applied_to_entity_id,xtb.source_entity_id) ,
			 xtb.code_combination_id ,
			 xtb.source_application_id,
			 xtb.ledger_id,
			 xtb.party_id,
			 xtb.balancing_segment_value,
			 xtb.natural_account_segment_value,
			 xtb.cost_center_segment_value,
			 xtb.intercompany_segment_value,
			 xtb.management_segment_value
			  HAVING SUM (Nvl(xtb.acctd_rounded_cr,0)) <> SUM (Nvl(xtb.acctd_rounded_dr,0))
		) tb
		--end of inline view
		$account_tab$
	WHERE tb.entity_id=xte.entity_id
	AND tb.source_application_id=200
	AND xte.entity_code=''AP_INVOICES''
	AND xte.application_id=tb.source_application_id
	AND nvl(xte.source_id_int_1,-99)=tiv.invoice_id
	$security_valuation_join$
	$account_range$
	GROUP BY
		tb.definition_code, tb.ledger_id, tb.source_application_id,
		tb.code_combination_id, tiv.party_name,tb.party_id,
		tb.balancing_segment_value, tb.natural_account_segment_value,
		tb.cost_center_segment_value, tb.intercompany_segment_value,
		tb.management_segment_value
    ) summary_dat ,
   gl_ledgers gl
 WHERE summary_dat.ledger_id=gl.ledger_id
  ';

-- Perf changes for TB Report Summary Template bug:8773522 --
C_TB_SUMMARY_SOURCE_SQL    CONSTANT VARCHAR2(32000) := '
	SELECT
	      gcck.concatenated_segments           ACCOUNT
	     ,$gl_balance_cols$                    GL_BALANCE
	     ,tbg.code_combination_id              CODE_COMBINATION_ID
	     ,tbg.balancing_segment_value          BALANCING_SEGMENT_VALUE
	     ,tbg.natural_account_segment_value    NATURAL_ACCOUNT_SEGMENT_VALUE
	     ,tbg.cost_center_segment_value        COST_CENTER_SEGMENT_VALUE
	     ,tbg.management_segment_value         MANAGEMENT_SEGMENT_VALUE
	     ,tbg.intercompany_segment_value       INTERCOMPANY_SEGMENT_VALUE
	     ,tbg.ledger_id                        LEDGER_ID
	     ,tbg.ledger_name                      LEDGER_NAME
	     ,tbg.ledger_short_name                LEDGER_SHORT_NAME
	     ,tbg.ledger_currency_code             LEDGER_CURRENCY_CODE
	     ,tbg.third_party_name                 THIRD_PARTY_NAME
	     ,tbg.third_party_number               THIRD_PARTY_NUMBER
	     ,tbg.third_party_type_code            THIRD_PARTY_TYPE_CODE
	     ,tbg.third_party_type                 THIRD_PARTY_TYPE
	     ,tbg.third_party_site_name            THIRD_PARTY_SITE_NAME
	     ,tbg.source_application_id            SOURCE_TRX_APPLICATION_ID
	     ,app.application_name                 SOURCE_TRX_APPLICATION_NAME
	     ,tbg.entered_unrounded_orig_amount    SUM_SRC_ENTD_UNROUND_ORG_AMT
	     ,tbg.entered_unrounded_rem_amount     SUM_SRC_ENTD_UNROUND_REM_AMT
	     ,tbg.entered_rounded_orig_amount      SUM_SRC_ENTD_ROUNDED_ORG_AMT
	     ,tbg.entered_rounded_rem_amount       SUM_SRC_ENTD_ROUNDED_REM_AMT
	     ,tbg.acctd_unrounded_orig_amount      SUM_SRC_ACCTD_UNROUND_ORG_AMT
	     ,tbg.acctd_unrounded_rem_amount       SUM_SRC_ACCTD_UNROUND_REM_AMT
	     ,tbg.acctd_rounded_orig_amount        SUM_SRC_ACCTD_ROUNDED_ORG_AMT
	     ,tbg.acctd_rounded_rem_amount         SUM_SRC_ACCTD_ROUNDED_REM_AMT
	     ,tbg.NON_AP_AMOUNT                    NON_AP_AMOUNT
	     ,tbg.MANUAL_SLA_AMOUNT                MANUAL_SLA_AMOUNT
	     $seg_desc_cols$
	FROM   xla_trial_balances_gt            tbg
	     ,fnd_application_vl                app
	     ,gl_code_combinations_kfv          gcck
	     ,gl_balances                       gb
	     $seg_desc_from$
	WHERE tbg.source_application_id       = app.application_id
	  AND tbg.code_combination_id         = gcck.code_combination_id
	  $gl_balance_join$
	  $seg_desc_join$
	 ';

/*C_TB_APPLIED_SQL    CONSTANT VARCHAR2(32000) := '
SELECT
      tbg.third_party_name                 THIRD_PARTY_NAME
     ,tbg.third_party_number               THIRD_PARTY_NUMBER
     ,tbg.third_party_type_code            THIRD_PARTY_TYPE_CODE
     ,tbg.third_party_type                 THIRD_PARTY_TYPE
     ,tbg.third_party_site_name            THIRD_PARTY_SITE_NAME
     ,tbg.applied_to_entity_id             APPLIED_TO_ENTITY_ID
     ,tbg.source_application_id            APPLIED_TRX_APPLICATION_ID
     ,app.application_name                 APPLIED_TRX_APPLICATION_NAME
     ,ett.name                             APPLIED_TRX_TYPE
     ,tbg.transaction_number               APPLIED_TRX_NUMBER
     ,tbg.gl_date                          APPLIED_TRX_GL_DATE
     ,tbg.trx_currency_code                APPLIED_TRX_CURR
     ,tbg.entered_unrounded_orig_amount    APPLIED_ENTERED_UNROUNDED_AMT
     ,tbg.entered_rounded_orig_amount      APPLIED_ENTERED_ROUNDED_AMT
     ,tbg.acctd_unrounded_orig_amount      APPLIED_ACCTD_UNROUNDED_AMT
     ,tbg.acctd_rounded_orig_amount        APPLIED_ACCTD_ROUNDED_AMT
     ,tbg.user_trx_identifier_name_1       APPLIED_TRX_IDENTIFIER_NAME_1
     ,tbg.user_trx_identifier_name_2       APPLIED_TRX_IDENTIFIER_NAME_2
     ,tbg.user_trx_identifier_name_3       APPLIED_TRX_IDENTIFIER_NAME_3
     ,tbg.user_trx_identifier_name_4       APPLIED_TRX_IDENTIFIER_NAME_4
     ,tbg.user_trx_identifier_name_5       APPLIED_TRX_IDENTIFIER_NAME_5
     ,tbg.user_trx_identifier_name_6       APPLIED_TRX_IDENTIFIER_NAME_6
     ,tbg.user_trx_identifier_name_7       APPLIED_TRX_IDENTIFIER_NAME_7
     ,tbg.user_trx_identifier_name_8       APPLIED_TRX_IDENTIFIER_NAME_8
     ,tbg.user_trx_identifier_name_9       APPLIED_TRX_IDENTIFIER_NAME_9
     ,tbg.user_trx_identifier_name_10      APPLIED_TRX_IDENTIFIER_NAME_10
     ,tbg.user_trx_identifier_value_1      APPLIED_TRX_IDENTIFIER_VAL_1
     ,tbg.user_trx_identifier_value_2      APPLIED_TRX_IDENTIFIER_VAL_2
     ,tbg.user_trx_identifier_value_3      APPLIED_TRX_IDENTIFIER_VAL_3
     ,tbg.user_trx_identifier_value_4      APPLIED_TRX_IDENTIFIER_VAL_4
     ,tbg.user_trx_identifier_value_5      APPLIED_TRX_IDENTIFIER_VAL_5
     ,tbg.user_trx_identifier_value_6      APPLIED_TRX_IDENTIFIER_VAL_6
     ,tbg.user_trx_identifier_value_7      APPLIED_TRX_IDENTIFIER_VAL_7
     ,tbg.user_trx_identifier_value_8      APPLIED_TRX_IDENTIFIER_VAL_8
     ,tbg.user_trx_identifier_value_9      APPLIED_TRX_IDENTIFIER_VAL_9
     ,tbg.user_trx_identifier_value_10     APPLIED_TRX_IDENTIFIER_VAL_10
FROM  xla_trial_balances_gt     tbg
     ,fnd_application_vl       app
     ,xla_entity_types_vl      ett
WHERE tbg.source_entity_code          = ett.entity_code
  AND tbg.source_application_id       = ett.application_id
  AND tbg.source_application_id       = app.application_id
  AND tbg.record_type_code            = ''APPLIED''
  AND tbg.applied_to_entity_id        = :SOURCE_ENTITY_ID
';*/


C_TB_APPLIED_SQL    CONSTANT VARCHAR2(32000) := '
               SELECT/*+ index(tbg XLA_TRIAL_BALANCES_GT_N1)*/
                      tbg.third_party_name                 THIRD_PARTY_NAME
                     ,tbg.third_party_number               THIRD_PARTY_NUMBER
                     ,tbg.third_party_type_code            THIRD_PARTY_TYPE_CODE
                     ,tbg.third_party_type                 THIRD_PARTY_TYPE
                     ,tbg.third_party_site_name            THIRD_PARTY_SITE_NAME
                     ,tbg.applied_to_entity_id             APPLIED_TO_ENTITY_ID
                     ,tbg.source_application_id            APPLIED_TRX_APPLICATION_ID
                     ,app.application_name                 APPLIED_TRX_APPLICATION_NAME
                     ,ett.name                             APPLIED_TRX_TYPE
                     ,tbg.transaction_number               APPLIED_TRX_NUMBER
                     ,tbg.gl_date                          APPLIED_TRX_GL_DATE

                     ,tbg.trx_currency_code                APPLIED_TRX_CURR
                     ,tbg.entered_unrounded_orig_amount    APPLIED_ENTERED_UNROUNDED_AMT
                     ,tbg.entered_rounded_orig_amount      APPLIED_ENTERED_ROUNDED_AMT
                     ,tbg.acctd_unrounded_orig_amount      APPLIED_ACCTD_UNROUNDED_AMT
                     ,tbg.acctd_rounded_orig_amount        APPLIED_ACCTD_ROUNDED_AMT
                     ,tbg.user_trx_identifier_name_1       APPLIED_TRX_IDENTIFIER_NAME_1
                     ,tbg.user_trx_identifier_name_2       APPLIED_TRX_IDENTIFIER_NAME_2
                     ,tbg.user_trx_identifier_name_3       APPLIED_TRX_IDENTIFIER_NAME_3
                     ,tbg.user_trx_identifier_name_4       APPLIED_TRX_IDENTIFIER_NAME_4
                     ,tbg.user_trx_identifier_name_5       APPLIED_TRX_IDENTIFIER_NAME_5
                     ,tbg.user_trx_identifier_name_6       APPLIED_TRX_IDENTIFIER_NAME_6
                     ,tbg.user_trx_identifier_name_7       APPLIED_TRX_IDENTIFIER_NAME_7
                     ,tbg.user_trx_identifier_name_8       APPLIED_TRX_IDENTIFIER_NAME_8
                     ,tbg.user_trx_identifier_name_9       APPLIED_TRX_IDENTIFIER_NAME_9
                     ,tbg.user_trx_identifier_name_10      APPLIED_TRX_IDENTIFIER_NAME_10
                     ,tbg.user_trx_identifier_value_1      APPLIED_TRX_IDENTIFIER_VAL_1
                     ,tbg.user_trx_identifier_value_2      APPLIED_TRX_IDENTIFIER_VAL_2
                     ,tbg.user_trx_identifier_value_3      APPLIED_TRX_IDENTIFIER_VAL_3
                     ,tbg.user_trx_identifier_value_4      APPLIED_TRX_IDENTIFIER_VAL_4
                     ,tbg.user_trx_identifier_value_5      APPLIED_TRX_IDENTIFIER_VAL_5
                     ,tbg.user_trx_identifier_value_6      APPLIED_TRX_IDENTIFIER_VAL_6
                     ,tbg.user_trx_identifier_value_7      APPLIED_TRX_IDENTIFIER_VAL_7
                     ,tbg.user_trx_identifier_value_8      APPLIED_TRX_IDENTIFIER_VAL_8
                     ,tbg.user_trx_identifier_value_9      APPLIED_TRX_IDENTIFIER_VAL_9
                     ,tbg.user_trx_identifier_value_10     APPLIED_TRX_IDENTIFIER_VAL_10
                 FROM xla_trial_balances_gt    tbg
                     ,fnd_application_vl       app
                     ,xla_entity_types_vl      ett
                WHERE tbg.source_entity_code          = ett.entity_code
                  AND tbg.source_application_id       = ett.application_id
                  AND tbg.source_application_id       = app.application_id
                  AND tbg.record_type_code            = ''APPLIED''
                  AND tbg.code_combination_id         = :CODE_COMBINATION_ID
                  AND tbg.applied_to_entity_id        = :SOURCE_ENTITY_ID
';


C_TB_UPG_SQL    CONSTANT VARCHAR2(32000) := '
SELECT
      gcck.concatenated_segments           ACCOUNT
     ,$gl_balance_cols$                    GL_BALANCE
     ,tb.code_combination_id               CODE_COMBINATION_ID
     ,tb.balancing_segment_value           BALANCING_SEGMENT_VALUE
     ,tb.natural_account_segment_value     NATURAL_ACCOUNT_SEGMENT_VALUE
     ,tb.cost_center_segment_value         COST_CENTER_SEGMENT_VALUE
     ,tb.management_segment_value          MANAGEMENT_SEGMENT_VALUE
     ,tb.intercompany_segment_value        INTERCOMPANY_SEGMENT_VALUE
     ,$ledger_cols$
     ,NULL                                 THIRD_PARTY_NAME
     ,NULL                                 THIRD_PARTY_NUMBER
     ,NULL                                 THIRD_PARTY_TYPE_CODE
     ,NULL                                 THIRD_PARTY_TYPE
     ,NULL                                 THIRD_PARTY_SITE_NAME
     ,tb.source_application_id             SOURCE_TRX_APPLICATION_ID
     ,tb.source_entity_id                  SOURCE_ENTITY_ID
     ,app.application_name                 SOURCE_TRX_APPLICATION_NAME
     ,''$initial_balance$''                SOURCE_TRX_TYPE
     ,NULL                                 SOURCE_TRX_NUMBER
     ,to_char(tb.gl_date,''YYYY-MM-DD'')   SOURCE_TRX_GL_DATE
     ,tb.trx_currency_code                 SOURCE_TRX_CURR
     ,$amount_cols$
     ,NULL                                 USER_TRX_IDENTIFIER_NAME_1
     ,NULL                                 USER_TRX_IDENTIFIER_NAME_2
     ,NULL                                 USER_TRX_IDENTIFIER_NAME_3
     ,NULL                                 USER_TRX_IDENTIFIER_NAME_4
     ,NULL                                 USER_TRX_IDENTIFIER_NAME_5
     ,NULL                                 USER_TRX_IDENTIFIER_NAME_6
     ,NULL                                 USER_TRX_IDENTIFIER_NAME_7
     ,NULL                                 USER_TRX_IDENTIFIER_NAME_8
     ,NULL                                 USER_TRX_IDENTIFIER_NAME_9
     ,NULL                                 USER_TRX_IDENTIFIER_NAME_10
     ,NULL                                 USER_TRX_IDENTIFIER_VALUE_1
     ,NULL                                 USER_TRX_IDENTIFIER_VALUE_2
     ,NULL                                 USER_TRX_IDENTIFIER_VALUE_3
     ,NULL                                 USER_TRX_IDENTIFIER_VALUE_4
     ,NULL                                 USER_TRX_IDENTIFIER_VALUE_5
     ,NULL                                 USER_TRX_IDENTIFIER_VALUE_6
     ,NULL                                 USER_TRX_IDENTIFIER_VALUE_7
     ,NULL                                 USER_TRX_IDENTIFIER_VALUE_8
     ,NULL                                 USER_TRX_IDENTIFIER_VALUE_9
     ,NULL                                 USER_TRX_IDENTIFIER_VALUE_10
     ,NULL                                 NON_AP_AMOUNT
     ,NULL                                 MANUAL_SLA_AMOUNT
$seg_desc_cols$
FROM  xla_trial_balances       tb
     ,fnd_application_vl       app
     ,gl_code_combinations_kfv gcck
     ,gl_balances              gb
$seg_desc_from$
WHERE tb.definition_code              = ''$definition_code$''
  AND tb.record_type_code             = ''SOURCE''
  AND tb.source_entity_id             = -1
  AND tb.source_application_id        = app.application_id
  AND tb.code_combination_id          = gcck.code_combination_id
  AND tb.gl_date       >=  NVL(''$p_start_date$'',tb.gl_date)
  AND tb.gl_date       <=  NVL(''$p_as_of_date$'',tb.gl_date + 1)
$gl_balance_join$
$seg_desc_join$
 ';

C_NEW_LINE            CONSTANT VARCHAR2(8)  := fnd_global.newline;
C_OWNER_ORACLE        CONSTANT VARCHAR2(1)  := 'S';
-------------------------------------------------------------------------------
-- constant for getting flexfield segment value description
-------------------------------------------------------------------------------
C_SEG_DESC_JOIN      CONSTANT    VARCHAR2(32000) :=
      '  AND $alias$.flex_value_set_id = $flex_value_set_id$ '
   || C_NEW_LINE
   || '  AND $alias$.flex_value        = $segment_column$ '
   || C_NEW_LINE
   || '  AND $alias$.parent_flex_value_low '          -- added for bug:7641746 for Dependant/Table Validated Value Set
   ;


-------------------------------------------------------------------------------
-- Define Types
-------------------------------------------------------------------------------
TYPE t_array_char IS TABLE OF VARCHAR2(32000) INDEX BY BINARY_INTEGER ;
TYPE r_security_info IS RECORD
  (valuation_method          xla_transaction_entities.valuation_method%TYPE
  ,security_id_int_1         xla_transaction_entities.security_id_int_1%TYPE
  ,security_id_char_1        xla_transaction_entities.security_id_char_1%TYPE);

-------------------------------------------------------------------------------
-- Global Constants
-------------------------------------------------------------------------------




--
-- Amount Columns:  Balance Side = 'Credit'
-- When Balance Side 'Credit' of Source Transactions,
-- the "balance side" of Applied to transactions is 'Debit'.
--
--  Source Trx Dr     Source Trx Dr
--  ----------------- ------------------
--                    100
--  Source Amount = 100 (Cr) - 0 (Dr)
--
--  Applied to Trx Dr  Applied to Trx Cr
--  ----------------- ------------------
--  30
--
--  Applied to Amount = 30 (Dr) - 0 (Cr)
--
--  Remaining Amount = 100 - 30 = 70
--
C_CR_APPLIED_AMT_COL   CONSTANT VARCHAR2(32000)
   := '
       , SUM(NVL(xtb.entered_unrounded_dr,0)) -
         SUM(NVL(xtb.entered_unrounded_cr,0))   entd_unrounded_appl_to_amount
       , SUM(NVL(xtb.entered_rounded_dr,0)) -
         SUM(NVL(xtb.entered_rounded_cr,0))     entd_rounded_appl_to_amount
       , SUM(NVL(xtb.acctd_unrounded_dr,0)) -
         SUM(NVL(xtb.acctd_unrounded_cr,0))     acctd_unrounded_appl_to_amount
       , SUM(NVL(xtb.acctd_rounded_dr,0)) -
         SUM(NVL(xtb.acctd_rounded_cr,0))       acctd_rounded_appl_to_amount
     ';

--
-- Amount Columns:  Balance Side = 'Debit'
--
C_DR_APPLIED_AMT_COL   CONSTANT VARCHAR2(32000)
   := '
       , SUM(NVL(xtb.entered_unrounded_cr,0)) -
         SUM(NVL(xtb.entered_unrounded_dr,0))   entd_unrounded_appl_to_amount
       , SUM(NVL(xtb.entered_rounded_cr,0)) -
         SUM(NVL(xtb.entered_rounded_dr,0))     entd_rounded_appl_to_amount
       , SUM(NVL(xtb.acctd_unrounded_cr,0)) -
         SUM(NVL(xtb.acctd_unrounded_dr,0))     acctd_unrounded_appl_to_amount
       , SUM(NVL(xtb.acctd_rounded_cr,0)) -
         SUM(NVL(xtb.acctd_rounded_dr,0))       acctd_rounded_appl_to_amount
     ';

--
-- Amount Columns:  Balance Side = 'Credit'
--

C_TB_CR_AMOUNT_COLUMN   CONSTANT VARCHAR2(32000)
   := ', sum(CASE WHEN xtb1.applied_to_entity_id IS NULL THEN
             NVL(xtb1.entered_unrounded_cr,0) - NVL(xtb1.entered_unrounded_dr,0)
          ELSE
             NVL(xtb1.entered_unrounded_dr,0) - NVL(xtb1.entered_unrounded_cr,0)
          END)  entered_unrounded_orig_amount
        , sum(CASE WHEN xtb1.applied_to_entity_id IS NULL THEN
             NVL(xtb1.entered_rounded_cr,0) - NVL(xtb1.entered_rounded_dr,0)
          ELSE
             NVL(xtb1.entered_rounded_dr,0) - NVL(xtb1.entered_rounded_cr,0)
          END)  entered_rounded_orig_amount
        , sum(CASE WHEN xtb1.applied_to_entity_id IS NULL THEN
            NVL(xtb1.acctd_unrounded_cr,0) - NVL(xtb1.acctd_unrounded_dr,0)
          ELSE
            NVL(xtb1.acctd_unrounded_dr,0) - NVL(xtb1.acctd_unrounded_cr,0)
          END)  acctd_unrounded_orig_amount
        , sum(CASE WHEN xtb1.applied_to_entity_id IS NULL THEN
             NVL(xtb1.acctd_rounded_cr,0) - NVL(xtb1.acctd_rounded_dr,0)
          ELSE
             NVL(xtb1.acctd_rounded_dr,0) - NVL(xtb1.acctd_rounded_cr,0)
          END)   acctd_rounded_orig_amount
     ';

--
-- Amount Columns:  Balance Side = 'Debit'
--
C_TB_DR_AMOUNT_COLUMN   CONSTANT VARCHAR2(32000)
   := ', sum(CASE WHEN xtb1.applied_to_entity_id IS NULL THEN
             NVL(xtb1.entered_unrounded_dr,0) - NVL(xtb1.entered_unrounded_cr,0)
          ELSE
             NVL(xtb1.entered_unrounded_cr,0) - NVL(xtb1.entered_unrounded_dr,0)
          END)  entered_unrounded_orig_amount
        , sum(CASE WHEN xtb1.applied_to_entity_id IS NULL THEN
             NVL(xtb1.entered_rounded_dr,0) - NVL(xtb1.entered_rounded_cr,0)
          ELSE
             NVL(xtb1.entered_rounded_cr,0) - NVL(xtb1.entered_rounded_dr,0)
          END)  entered_rounded_orig_amount
        , sum(CASE WHEN xtb1.applied_to_entity_id IS NULL THEN
            NVL(xtb1.acctd_unrounded_dr,0) - NVL(xtb1.acctd_unrounded_cr,0)
          ELSE
            NVL(xtb1.acctd_unrounded_cr,0) - NVL(xtb1.acctd_unrounded_dr,0)
          END)  acctd_unrounded_orig_amount
        , sum(CASE WHEN xtb1.applied_to_entity_id IS NULL THEN
             NVL(xtb1.acctd_rounded_dr,0) - NVL(xtb1.acctd_rounded_cr,0)
          ELSE
             NVL(xtb1.acctd_rounded_cr,0) - NVL(xtb1.acctd_rounded_dr,0)
          END)   acctd_rounded_orig_amount
     ';

--
--  Amount Columns (Upgrade): Balance Side = 'Credit'
--
C_UPG_CR_AMOUNT_COLUMN CONSTANT VARCHAR2(32000)
   := 'NULL                     SRC_ENTERED_UNROUNDED_ORIG_AMT
      ,tb.entered_unrounded_cr  SRC_ENTERED_UNROUNDED_REM_AMT
      ,NULL                     SRC_ENTERED_ROUNDED_ORIG_AMT
      ,tb.entered_rounded_cr    SRC_ENTERED_ROUNDED_REM_AMT
      ,NULL                     SRC_ACCTD_UNROUNDED_ORIG_AMT
      ,tb.acctd_unrounded_cr    SRC_ACCTD_UNROUNDED_REM_AMT
      ,NULL                     SRC_ACCTD_ROUNDED_ORIG_AMT
      ,tb.acctd_rounded_cr      SRC_ACCTD_ROUNDED_REM_AMT
';

--
--  Amount Columns (Upgrade): Balance Side = 'Dedit'
--
C_UPG_DR_AMOUNT_COLUMN CONSTANT VARCHAR2(32000)
   := 'NULL                     SRC_ENTERED_UNROUNDED_ORIG_AMT
      ,tb.entered_unrounded_dr  SRC_ENTERED_UNROUNDED_REM_AMT
      ,NULL                     SRC_ENTERED_ROUNDED_ORIG_AMT
      ,tb.entered_rounded_dr    SRC_ENTERED_ROUNDED_REM_AMT
      ,NULL                     SRC_ACCTD_UNROUNDED_ORIG_AMT
      ,tb.acctd_unrounded_dr    SRC_ACCTD_UNROUNDED_REM_AMT
      ,NULL                     SRC_ACCTD_ROUNDED_ORIG_AMT
      ,tb.acctd_rounded_dr      SRC_ACCTD_ROUNDED_REM_AMT
';

--
-- Party Info:  Party Type = Customer
--

--
-- Replace $party_col$ in C_INSERT_GT_SELECT
--
C_PARTY_CUST_COLUMN  CONSTANT  VARCHAR2(32000) := '
   ,hzp.party_name                 third_party_name
   ,hca.account_number             third_party_number
   ,tb.party_type_code             third_party_type_code
   ,$third_party_type_cust$        third_party_type
   ,hps.party_site_name            third_party_site_name
   ,hca.account_number             third_party_account_number
'
;

--
-- Replace $party_tab$ in C_INSERT_GT_SELECT
--
C_PARTY_CUST_TABLE   CONSTANT  VARCHAR2(32000) := '
    ,hz_parties                hzp
    ,hz_party_sites            hps
    ,hz_cust_accounts          hca
    ,hz_cust_acct_sites_all    hcas
    ,hz_cust_site_uses_all     hcsu
';

--
-- Replace $party_where$ in C_INSERT_GT_SELECT
--
C_PARTY_CUST_WHERE   CONSTANT  VARCHAR2(32000) := '
   AND tb.party_id                = hca.cust_account_id (+)
   AND tb.party_type_code (+)     = ''C''
   AND hzp.party_id  (+)          = hca.party_id
   AND tb.party_site_id           = hcsu.site_use_id (+)
   AND hcas.cust_acct_site_id (+) = hcsu.cust_acct_site_id
   AND hcas.party_site_id         = hps.party_site_id (+)
';


--
-- Party Info: Party Type = Supplier
--
C_PARTY_SUPP_COLUMN  CONSTANT  VARCHAR2(32000) := '
  ,hzp.party_name              third_party_name
  ,hzp.party_number            third_party_number
  ,tb.party_type_code          third_party_type_code
  ,$third_party_type_supp$     third_party_type
  ,hps.party_site_name         third_party_site_name
  ,hzp.party_number            third_party_account_number
';

C_PARTY_SUPP_TABLE   CONSTANT  VARCHAR2(32000) := '
    ,ap_suppliers              aps
    ,ap_supplier_sites_all     apss
    ,hz_parties                hzp
    ,hz_party_sites            hps
';

--
-- Include the cases that party information is null in ae lines
--
C_PARTY_SUPP_WHERE   CONSTANT  VARCHAR2(32000) := '
   AND (tb.party_type_code is NULL OR tb.party_type_code = ''S'')
   AND tb.party_id            = aps.vendor_id (+)
   AND tb.party_site_id       = apss.vendor_site_id (+)
   AND aps.party_id           = hzp.party_id (+)
   AND NVL(apss.party_site_id,0) = hps.party_site_id (+) --added nvl for bug 6601283,in case where supplier is employee,party_site_id should be null

';

C_INSERT_GT_STATEMENT    CONSTANT VARCHAR2(32000) := '
INSERT INTO xla_trial_balances_gt
         (definition_code
          ,ledger_id
          ,ledger_name
          ,ledger_short_name
          ,ledger_currency_code
          ,record_type_code
          ,source_application_id
         ,source_entity_id
         ,source_entity_code
         ,transaction_number
         ,code_combination_id
         ,gl_date
         ,entered_unrounded_orig_amount
         ,entered_rounded_orig_amount
         ,acctd_unrounded_orig_amount
         ,acctd_rounded_orig_amount
         ,entered_unrounded_rem_amount
         ,entered_rounded_rem_amount
         ,acctd_unrounded_rem_amount
         ,acctd_rounded_rem_amount
         ,third_party_name
         ,third_party_number
         ,balancing_segment_value
         ,natural_account_segment_value
         ,cost_center_segment_value
         ,intercompany_segment_value
         ,management_segment_value
         ,applied_to_entity_id
         ,trx_currency_code
         ,user_trx_identifier_name_1
         ,user_trx_identifier_value_1
         ,user_trx_identifier_name_2
         ,user_trx_identifier_value_2
         ,user_trx_identifier_name_3
         ,user_trx_identifier_value_3
         ,user_trx_identifier_name_4
         ,user_trx_identifier_value_4
         ,user_trx_identifier_name_5
         ,user_trx_identifier_value_5
         ,user_trx_identifier_name_6
         ,user_trx_identifier_value_6
         ,user_trx_identifier_name_7
         ,user_trx_identifier_value_7
         ,user_trx_identifier_name_8
         ,user_trx_identifier_value_8
         ,user_trx_identifier_name_9
         ,user_trx_identifier_value_9
         ,user_trx_identifier_name_10
         ,user_trx_identifier_value_10) ';

-- added leading(xtb) hint for Perf Changes for bug:8773522
C_INSERT_GT_SELECT    CONSTANT VARCHAR2(32000) := '
SELECT
tb.definition_code,
tb.ledger_id,
gl.name,
gl.short_name,
gl.currency_code,
''X'',
tb.source_application_id,
tb.entity_id,
xte.entity_code,
xte.transaction_number,
tb.code_combination_id,
tiv.invoice_date,
--added bug 7359012 original amounts would be displayed only for primary ledger.
decode(gl.ledger_category_code,''PRIMARY'',tiv.invoice_amount,0),
decode(gl.ledger_category_code,''PRIMARY'',tiv.invoice_amount,0),
decode(gl.ledger_category_code,''PRIMARY'',nvl(tiv.base_amount,tiv.invoice_amount),0),
decode(gl.ledger_category_code,''PRIMARY'',nvl(tiv.base_amount,tiv.invoice_amount),0),
--end bug 7359012
tb.entered_unrounded_rem_amount,
tb.entered_rounded_rem_amount,
tb.acctd_unrounded_rem_amount,
tb.acctd_rounded_rem_amount,
tiv.party_name,
tb.party_id,
tb.balancing_segment_value,
tb.natural_account_segment_value,
tb.cost_center_segment_value,
tb.intercompany_segment_value,
tb.management_segment_value,
tb.entity_id,
tiv.invoice_currency_code, --added for bug 8321482 Removed hard-coded USD
''Party Name''   USER_TRX_IDENTIFIER_NAME_1,
TIV.PARTY_NAME   USER_TRX_IDENTIFIER_VALUE_1,
''Party Site Name''   USER_TRX_IDENTIFIER_NAME_2,
TIV.PARTY_SITE_NAME   USER_TRX_IDENTIFIER_VALUE_2,
''Invoice Number''   USER_TRX_IDENTIFIER_NAME_3,
TIV.INVOICE_NUM   USER_TRX_IDENTIFIER_VALUE_3,
''Invoice Amount''   USER_TRX_IDENTIFIER_NAME_4,
to_char(TIV.INVOICE_AMOUNT)   USER_TRX_IDENTIFIER_VALUE_4,
--remod ''Invoice Currency''   USER_TRX_IDENTIFIER_NAME_5,
--remod TIV.INVOICE_CURRENCY_CODE   USER_TRX_IDENTIFIER_VALUE_5,
''Due Days''   USER_TRX_IDENTIFIER_NAME_5,
TIV.DUE_DAYS   USER_TRX_IDENTIFIER_VALUE_5,
''Invoice Ledger Amount''   USER_TRX_IDENTIFIER_NAME_6,
to_char(TIV.BASE_AMOUNT)   USER_TRX_IDENTIFIER_VALUE_6,
''Payment Status''         USER_TRX_IDENTIFIER_NAME_7,
tiv.PAYMENT_STATUS USER_TRX_IDENTIFIER_VALUE_7,
''Invoice Date''   USER_TRX_IDENTIFIER_NAME_8,
to_char(TIV.INVOICE_DATE,''YYYY-MM-DD"T"hh:mi:ss'')  USER_TRX_IDENTIFIER_VALUE_8,
''Cancelled Date''   USER_TRX_IDENTIFIER_NAME_9,
to_char(TIV.CANCELLED_DATE,''YYYY-MM-DD"T"hh:mi:ss'')   USER_TRX_IDENTIFIER_VALUE_9,
''Invoice Description'' USER_TRX_IDENTIFIER_NAME_10,
TIV.DESCRIPTION   USER_TRX_IDENTIFIER_VALUE_10
FROM
AP_SLA_INVOICES_TRANSACTION_V tiv,
xla_transaction_entities xte,
gl_ledgers gl,
-- inline view
( SELECT /*+ parallel(xtb) leading(xtb) NO_MERGE */  --added hint bug#8409806 -- leading hint for bug:9165098
         /* added NO_MERGE for bug:9473043  */
xtb.definition_code,
nvl(xtb.applied_to_entity_id,xtb.source_entity_id) entity_id,
xtb.code_combination_id ,
xtb.source_application_id,
SUM (Nvl(xtb.entered_unrounded_cr,0)) -  SUM (Nvl(xtb.entered_unrounded_dr,0)) entered_unrounded_rem_amount,
SUM (Nvl(xtb.entered_rounded_cr,0)) -  SUM (Nvl(xtb.entered_rounded_dr,0)) entered_rounded_rem_amount,
SUM (Nvl(xtb.acctd_unrounded_cr,0)) -  SUM (Nvl(xtb.acctd_unrounded_dr,0)) acctd_unrounded_rem_amount,
SUM (Nvl(xtb.acctd_rounded_cr,0)) -  SUM (Nvl(xtb.acctd_rounded_dr,0)) acctd_rounded_rem_amount,
xtb.ledger_id,
xtb.party_id,
xtb.balancing_segment_value,
xtb.natural_account_segment_value,
xtb.cost_center_segment_value,
xtb.intercompany_segment_value,
xtb.management_segment_value
FROM     xla_trial_balances xtb
where    xtb.definition_code = :1
         and xtb.source_application_id=200
         and xtb.gl_date between :2 and :3
         AND NVL(xtb.party_id,-99)    = NVL(:4,NVL(xtb.party_id,-99))

    GROUP BY  xtb.definition_code,
         nvl(xtb.applied_to_entity_id,xtb.source_entity_id) ,
         xtb.code_combination_id ,
         xtb.source_application_id,
         xtb.ledger_id,
         xtb.party_id,
         xtb.balancing_segment_value,
         xtb.natural_account_segment_value,
         xtb.cost_center_segment_value,
         xtb.intercompany_segment_value,
         xtb.management_segment_value
          HAVING SUM (Nvl(xtb.acctd_rounded_cr,0)) <> SUM (Nvl(xtb.acctd_rounded_dr,0))
) tb
$account_tab$
--end of inline view
where tb.entity_id=xte.entity_id
and tb.source_application_id=200
and xte.entity_code=''AP_INVOICES''
and xte.application_id=tb.source_application_id
--and xte.ledger_id=tb.ledger_id  removed join to make report work for reporting/secondary ledger,Bug 7331692
and nvl(xte.source_id_int_1,-99)=tiv.invoice_id
and tb.ledger_id=gl.ledger_id
$account_range$
  ';

-- C_ORDER_BY          CONSTANT VARCHAR2(2000) := '
-- ORDER BY
--      cck.concatenated_segs
--     ,tbg.third_party_name
--';

--=============================================================================
--               *********** Global Variables **********
--=============================================================================
g_ledger_info              xla_tb_data_manager_pvt.r_ledger_info;
g_defn_info                xla_tb_data_manager_pvt.r_definition_info;

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
                      := 'xla.plsql.xla_tb_report_pvt';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_level                      IN NUMBER
  ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE)

IS
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
         (p_location   => 'xla_tb_report_pvt.trace');
END trace;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
|    Print_Logfile                                                      |
|                                                                       |
|    Print concurrent request logs.                                     |
|                                                                       |
+======================================================================*/
PROCEDURE print_logfile(p_msg  IN  VARCHAR2) IS
BEGIN

   fnd_file.put_line(fnd_file.log,p_msg);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_report_pvt.print_logfile');

END print_logfile;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
|    Dump_Text                                                          |
|                                                                       |
|    Dump text into fnd_log_messages.                                   |
|                                                                       |
+======================================================================*/
PROCEDURE dump_text
                    (
                      p_text          IN  VARCHAR2
                    )
IS
   l_cur_position      INTEGER;
   l_next_cr_position  INTEGER;
   l_text_length       INTEGER;
   l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_text';
   END IF;

   --Dump the SQL command
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      l_cur_position      := 1;
      l_next_cr_position  := 0;
      l_text_length       := LENGTH(p_text);

      WHILE l_next_cr_position < l_text_length
      LOOP
         l_next_cr_position := INSTR( p_text
                                     ,C_NEW_LINE
                                     ,l_cur_position
                                    );

         IF l_next_cr_position = 0
         THEN
            l_next_cr_position := l_text_length;
         END IF;

         trace
            (p_msg      => SUBSTR( p_text
                                  ,l_cur_position
                                  ,l_next_cr_position
                                   - l_cur_position
                                   + 1
                                 )
            ,p_level    => C_LEVEL_STATEMENT
			,p_module   => l_log_module);

         IF l_cur_position < l_text_length
         THEN
            l_cur_position := l_next_cr_position + 1;
         END IF;
      END LOOP;
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_report_pvt.dump_text');
END dump_text;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
|    Get_Period_Name                                                    |
|                                                                       |
|                                                                       |
|    Retrieve Current Period Name                                       |
|                                                                       |
+======================================================================*/
FUNCTION get_period_name
  (p_ledger_id            IN NUMBER) RETURN VARCHAR2
IS

   l_log_module              VARCHAR2(240);

   l_period_name             VARCHAR2(30);

   l_as_of_date   DATE;


-- add TB phase4 bug#7600550 bug#8278138
CURSOR c_latest_open_period IS
SELECT latest_opened_period_name , gp.start_date
                FROM gl_ledgers gl , gl_periods gp
                where ledger_id = p_ledger_id
                AND gp.period_set_name = gl.period_set_name
                AND gp.period_type     = gl.accounted_period_type
                AND NVL(gp.adjustment_period_flag,'N')='N'
                AND gp.period_name = gl.latest_opened_period_name;


CURSOR c_max_open_period IS
SELECT period_name
FROM gl_period_statuses
WHERE application_id =101
AND   ledger_id = p_ledger_id
AND NVL(adjustment_period_flag,'N')='N'
AND closing_status = 'O'
AND effective_period_num =
(
 SELECT max(effective_period_num)
 FROM gl_period_statuses
 WHERE application_id = 101
 AND   ledger_id = p_ledger_id
 AND NVL(adjustment_period_flag,'N')='N'
 AND closing_status = 'O'
);

l_latest_opened_period_name  gl_periods.period_name%TYPE;
l_start_date                 gl_periods.start_date%TYPE;



BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_period_name';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of replace_gl_bal_string'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'p_ledger_id: ' || p_ledger_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

    l_as_of_date := p_as_of_date;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'p_as_of_date: ' || p_as_of_date || ' l_as_of_date ' || l_as_of_date
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

   --
   -- Retrieve current period name
   --


 --added bug 6684579 ,pick as_of_date period instead of sysdate period if as of date is provided
     /*
     SELECT gp.period_name
     INTO l_period_name
     FROM gl_ledgers       gl
         ,gl_periods       gp
    WHERE gl.ledger_id = p_ledger_id
      AND gp.period_set_name = gl.period_set_name
      AND gp.period_type     = gl.accounted_period_type
      AND NVL(TRUNC(l_as_of_date),TRUNC(sysdate)) BETWEEN gp.start_date AND gp.end_date
      AND NVL(gp.adjustment_period_flag,'N')='N';*/

 /*
   Prior to TB phase4 bug#7600550 if as of date entered by user is of future period like
    1-JAN-2030 and the period_name does not exists in gl_balance the gl balance was
    showing 0 and the remaining amount is calculated based on the date range.
    To avoid gl_balance being shown 0 in such cases following logic is followed:
    a. Check whether the period exists in gl_balance for as_of_date entered
    b. If not in the Exceptions block get the latest open period and start date
       IF latest open period is NULL then its an adjustment period...
          Obtain the actual period_name for the latest open period in gl_period_statuses
          for the ledger and return.
       ELSIF as_of_date entered is < than start_date of latest open period
         Return Null ( example as_of_date entered is a prior period like '01-JAN-1930'
       ELSE
         Return the latest open period name
       END IF;
 */

   SELECT gp.period_name
     INTO l_period_name
     FROM gl_ledgers       gl
         ,gl_periods       gp
    WHERE gl.ledger_id = p_ledger_id
      AND gp.period_set_name = gl.period_set_name
      AND gp.period_type     = gl.accounted_period_type
      AND NVL(TRUNC(l_as_of_date),TRUNC(sysdate)) BETWEEN gp.start_date AND gp.end_date
      AND NVL(gp.adjustment_period_flag,'N')='N'
      AND EXISTS
      ( SELECT 1
        FROM gl_balances gb
        WHERE gb.ledger_id = gl.ledger_id
        AND gb.period_name = gp.period_name
      )
    ;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'l_period_name' || l_period_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of get_period_name'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   RETURN l_period_name;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   IF l_period_name IS NULL THEN

	 OPEN c_latest_open_period;
         FETCH c_latest_open_period INTO l_latest_opened_period_name,
                                         l_start_date;
         CLOSE c_latest_open_period;

         IF  l_start_date IS NULL THEN
             --This condition indicates that its a adjustment period
             -- pick up the max open period for a ledger
             OPEN c_max_open_period;
             FETCH c_max_open_period INTO l_period_name;
             CLOSE c_max_open_period;
         ELSIF p_as_of_date < l_start_date THEN
            l_period_name:= NULL;
         ELSE
           l_period_name:= l_latest_opened_period_name;
         END IF;

   END IF;

  RETURN l_period_name;

WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     ('XLA'         , 'XLA_COMMON_FAILURE'
     ,'LOCATION'    , 'xla_tb_report_pvt.get_period_name'
     ,'ERROR'       ,  sqlerrm);

END get_period_name;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
|    Replace_Gl_Bal_String                                              |
|                                                                       |
|                                                                       |
|    Replace GL balance related string in C_TB_SOURCE_SQL               |
|                                                                       |
+======================================================================*/
FUNCTION replace_gl_bal_string
  (p_select_sql           IN VARCHAR2
  ,p_ledger_id            IN NUMBER
  ,p_account_balance_code IN VARCHAR2
  ,p_balance_side_code    IN VARCHAR2
  ,p_upg_flag             IN VARCHAR2) RETURN VARCHAR2
IS

   l_log_module              VARCHAR2(240);

   l_period_name             VARCHAR2(30);
   l_balance_cols            VARCHAR2(32000);
   l_balance_join            VARCHAR2(32000);
   l_select_sql              VARCHAR2(32000);

   C_YEAR_TO_DATE_CR_COL     CONSTANT VARCHAR2(2000) :=
                             '(NVL(gb.begin_balance_cr,0) -
                               NVL(gb.begin_balance_dr,0)) +
                              (NVL(gb.period_net_cr,0) -
                               NVL(gb.period_net_dr,0))';

   C_YEAR_TO_DATE_DR_COL     CONSTANT VARCHAR2(2000)  :=
                             '(NVL(gb.begin_balance_dr,0) -
                               NVL(gb.begin_balance_cr,0)) +
                              (NVL(gb.period_net_dr,0) -
                               NVL(gb.period_net_cr,0))';

   C_CURRENT_PERIOD_CR_COL   CONSTANT VARCHAR2(2000)  :=
                             '(NVL(gb.period_net_cr,0) -
                               NVL(gb.period_net_dr,0))';

   C_CURRENT_PERIOD_DR_COL   CONSTANT VARCHAR2(2000)  :=
                             '(NVL(gb.period_net_dr,0) -
                               NVL(gb.period_net_cr,0))';

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.replace_gl_bal_string';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of replace_gl_bal_string'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'p_ledger_id: ' || p_ledger_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_account_balance_code: ' || p_account_balance_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_balance_side_code: ' || p_balance_side_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

   --
   --
   --  Build columns to return GL Balances
   --
   --
   --IF p_account_balance_code = 'YEAR_TO_DATE' THEN
   -- commented from TB phase4 7600550 GL Balance will be calculated
   -- year_to_date

      IF p_balance_side_code = 'C' THEN

         --
         --  Balance Side = 'Credit'
         --
         l_balance_cols := C_YEAR_TO_DATE_CR_COL;

      ELSIF p_balance_side_code = 'D' THEN

         --
         -- Balance Side = 'Debit'
         --
         l_balance_cols := C_YEAR_TO_DATE_DR_COL;

      END IF;

/*   ELSIF p_account_balance_code = 'CURR_PERIOD' THEN

      IF p_balance_side_code = 'C' THEN

         --
         --  Balance Side = 'Credit'
         --
         l_balance_cols := C_CURRENT_PERIOD_CR_COL;

      ELSE

         --
         --  Balance Side = 'Debit'
         --
         l_balance_cols := C_CURRENT_PERIOD_DR_COL;

      END IF;
   END IF; */

   --
   --
   --  Build where clauses for GL Balances
   --
   --

   --
   -- Retrieve current period name
   --
   l_period_name := get_period_name
                      (p_ledger_id => p_ledger_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'Period Name: ' || l_period_name
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

   --
   --  Build Join Conditions
   --
   IF NVL(p_upg_flag,'Y') = 'N' THEN
      l_balance_join :=
   '  AND gb.code_combination_id  (+) = tbg.code_combination_id '   || C_NEW_LINE ||
   '  AND gb.ledger_id            (+) = tbg.ledger_id '             || C_NEW_LINE ||
   '  AND gb.actual_flag          (+) = ''A'' '                     || C_NEW_LINE ||
   '  AND gb.currency_code        (+) = tbg.ledger_currency_code '  || C_NEW_LINE ||
   '  AND gb.period_name          (+) = ' || '''' || l_period_name || '''';
   ELSE
      l_balance_join :=
   '  AND gb.code_combination_id  (+) = tb.code_combination_id '    || C_NEW_LINE ||
   '  AND gb.ledger_id            (+) = tb.ledger_id '              || C_NEW_LINE ||
   '  AND gb.actual_flag          (+) = ''A'' '                     || C_NEW_LINE ||
   '  AND gb.currency_code        (+) = ' || ''''
                                      || g_ledger_info.currency_code
                                      || ''''
                                      || C_NEW_LINE ||
   '  AND gb.period_name          (+) = ' || '''' || l_period_name || '''';
   END IF;
   --
   -- Replace strings in p_select_sql
   --
   l_select_sql := p_select_sql;

   l_select_sql := REPLACE(l_select_sql,'$gl_balance_cols$',l_balance_cols);
   l_select_sql := REPLACE(l_select_sql,'$gl_balance_join$',l_balance_join);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of replace_gl_bal_string'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   RETURN l_select_sql;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     ('XLA'         , 'XLA_COMMON_FAILURE'
     ,'LOCATION'    , 'xla_tb_report_pvt.replace_gl_bal_string'
     ,'ERROR'       ,  sqlerrm);

END replace_gl_bal_string;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
|    Replace_String_for_Party                                           |
|                                                                       |
|                                                                       |
|    Replace party related string in C_INSERT_GT_SELECT.                   |
|                                                                       |
+======================================================================*/
FUNCTION replace_party_string
  (p_party_id             IN NUMBER
  ,p_party_type_code      IN VARCHAR2 -- <C/S>
  ,p_insert_sql           IN VARCHAR2) RETURN VARCHAR2

IS

   l_log_module           VARCHAR2(240);

   l_cust_meaning         VARCHAR2(80);
   l_supp_meaning         VARCHAR2(80);
   l_party_type_code      VARCHAR2(30);
   l_party_column_cust    VARCHAR2(32000);
   l_party_column_supp    VARCHAR2(32000);

   l_insert_gt_sql        VARCHAR2(32000);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.replace_party_string';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of replace_party_string'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   l_insert_gt_sql := p_insert_sql;

   --
   --  Replace $party_col$, $party_Tab$, and $party_where$
   --
   SELECT xlc.meaning
         ,xls.meaning
     INTO l_cust_meaning
         ,l_supp_meaning
     FROM xla_lookups xlc, xla_lookups xls
    WHERE xlc.lookup_type = 'XLA_PARTY_TYPE'
      AND xlc.lookup_code = 'C'
      AND xls.lookup_type = 'XLA_PARTY_TYPE'
      AND xls.lookup_code = 'S';

   --
   -- Retrieve Party Type Code
   --

   IF p_party_type_code = 'C' THEN

      l_party_column_cust := REPLACE(C_PARTY_CUST_COLUMN
                                    ,'$third_party_type_cust$'
                                    ,''''||l_cust_meaning||'''');

      l_insert_gt_sql := REPLACE (l_insert_gt_sql
                                 ,'$party_col$'
                                 ,l_party_column_cust);

      l_insert_gt_sql := REPLACE (l_insert_gt_sql
                                 ,'$party_tab$'
                                 ,C_PARTY_CUST_TABLE);

      l_insert_gt_sql := REPLACE (l_insert_gt_sql
                                 ,'$party_where$'
                                 ,C_PARTY_CUST_WHERE);

   ELSIF p_party_type_code = 'S' THEN

      l_party_column_supp := REPLACE(C_PARTY_SUPP_COLUMN
                                    ,'$third_party_type_supp$'
                                    ,''''||l_supp_meaning||'''');

      l_insert_gt_sql := REPLACE (l_insert_gt_sql
                                 ,'$party_col$'
                                 ,l_party_column_supp);

      l_insert_gt_sql := REPLACE (l_insert_gt_sql
                                 ,'$party_tab$'
                                 ,C_PARTY_SUPP_TABLE);

      l_insert_gt_sql := REPLACE (l_insert_gt_sql
                                 ,'$party_where$'
                                 ,C_PARTY_SUPP_WHERE);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of replace_party_string'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   RETURN l_insert_gt_sql;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     ('XLA'         , 'XLA_COMMON_FAILURE'
     ,'LOCATION'    , 'xla_tb_report_pvt.replace_party_string'
     ,'ERROR'       ,  sqlerrm);

END replace_party_string;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
|    get_flex_range_where                                               |
|                                                                       |
|                                                                       |
|    Return where clauses for flexfield ranges                          |
|                                                                       |
+======================================================================*/
FUNCTION get_flex_range_where
  (p_coa_id          IN NUMBER
  ,p_account_from    IN VARCHAR2
  ,p_account_to      IN VARCHAR2) RETURN VARCHAR

IS

   l_log_module           VARCHAR2(240);

   l_where                VARCHAR2(32000);
   l_bind_variables       fnd_flex_xml_publisher_apis.bind_variables;
   l_numof_bind_variables NUMBER;
   l_segment_name         VARCHAR2(30);
   l_segment_value        VARCHAR2(1000);
   l_data_type            VARCHAR2(30);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_flex_range_where';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_flex_range_where'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg   => 'p_coa_id = '||to_char(p_coa_id)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_account_from = '||to_char(p_account_from)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_account_to = '||to_char(p_account_to)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

   END IF;

   --
   --  e.g. l_where stores the following:
   --       CC.SEGMENT1 BETWEEN :FLEX_PARM1 AND :FLEX_PARM2
   --   AND CC.SEGMENT2 BETWEEN :FLEX_PARM3 AND :FLEX_PARM4 ...
   --
   fnd_flex_xml_publisher_apis.kff_where
     (p_lexical_name                 => 'FLEX_PARM'
     ,p_application_short_name       => 'SQLGL'
     ,p_id_flex_code                 => 'GL#'
     ,p_id_flex_num                  => p_coa_id
     ,p_code_combination_table_alias => 'CC'
     ,p_segments                     => 'ALL'
     ,p_operator                     => 'BETWEEN'
     ,p_operand1                     => p_account_from
     ,p_operand2                     => p_account_to
     ,x_where_expression             => l_where
     ,x_numof_bind_variables         => l_numof_bind_variables
     ,x_bind_variables               => l_bind_variables);

   FOR i IN l_bind_variables.FIRST .. l_bind_variables.LAST LOOP

      l_segment_name := l_bind_variables(i).name;
      l_data_type    := l_bind_variables(i).data_type;

      IF (l_data_type='VARCHAR2') THEN

         l_segment_value := '''' || l_bind_variables(i).varchar2_value || '''';

      ELSIF (l_data_type='NUMBER') THEN

         l_segment_value :=  l_bind_variables(i).canonical_value;

      ELSIF (l_data_type='DATE')  THEN

         l_segment_value := '''' ||  TO_CHAR(l_bind_variables(i).date_value
                                    ,'yyyy-mm-dd HH24:MI:SS') || '''';

      END IF;

     --
     -- Use REGEXP_REPLACE instead of REPLACE not to replace
     -- string 'SEGMENT1' in 'SEGMENT10'.
     -- REGEXP_REPLACE replaces the first occurent of a segment name
     -- e.g.
     --  BETWEEN :FLEX_PARM9 AND :FLEX_PARM10
     --  =>
     --  BETWEEN '000' AND '100'
     --
     l_where := REGEXP_REPLACE
                  (l_where
                  ,':' || l_segment_name
                  ,l_segment_value
                  ,1    -- Position
                  ,1    -- The first occurence
                  , 'c'  -- Case sensitive
                  );

   END LOOP ;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of get_flex_range_where'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   RETURN l_where;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_tb_report_pvt.get_flex_range_where');

END get_flex_range_where;
/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
|    get_report_parameters                                              |
|                                                                       |
|                                                                       |
|    Get dipalyed values of report paramters                            |
|                                                                       |
+======================================================================*/
PROCEDURE get_report_parameters
  (p_journal_source       IN VARCHAR2
  ,p_definition_code      IN VARCHAR2
  ,p_third_party_id       IN VARCHAR2
  ,p_show_trx_detail_flag IN VARCHAR2
  ,p_incl_write_off_flag  IN VARCHAR2
  ,p_acct_balance         IN VARCHAR2)

IS

   l_log_module           VARCHAR2(240);

   l_party_type_code      VARCHAR2(1);
   l_party_id             NUMBER(15);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_report_parameters';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_report_parameters'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF p_journal_source IS NOT NULL THEN

      SELECT user_je_source_name
        INTO p_journal_source_dsp
        FROM gl_je_sources
       WHERE je_source_name = p_journal_source;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

         trace
           (p_msg   => 'p_journal_source_dsp = '|| p_journal_source_dsp
           ,p_level => C_LEVEL_STATEMENT
           ,p_module=> l_log_module );

      END IF;

   END IF;

   IF p_definition_code IS NOT NULL THEN

      SELECT NAME
        INTO p_report_definition_dsp
        FROM xla_tb_definitions_vl
       WHERE definition_code = p_definition_code;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

         trace
           (p_msg   => 'p_report_definition_dsp = '|| p_report_definition_dsp
           ,p_level => C_LEVEL_STATEMENT
           ,p_module=> l_log_module );

      END IF;

   END IF;

   IF p_show_trx_detail_flag IS NOT NULL THEN

      SELECT meaning
        INTO p_show_trx_detail_dsp
        FROM xla_lookups
       WHERE lookup_code = p_show_trx_detail_flag
         AND lookup_type = 'XLA_YES_NO';

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

         trace
           (p_msg   => 'p_show_trx_detail_dsp = '|| p_show_trx_detail_dsp
           ,p_level => C_LEVEL_STATEMENT
           ,p_module=> l_log_module );

      END IF;

   END IF;

   IF p_incl_write_off_flag IS NOT NULL THEN

      SELECT meaning
        INTO p_incl_write_off_dsp
        FROM xla_lookups
       WHERE lookup_code = p_incl_write_off_flag
         AND lookup_type = 'XLA_YES_NO';

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

         trace
           (p_msg   => 'p_incl_write_off_dsp = '|| p_incl_write_off_dsp
           ,p_level => C_LEVEL_STATEMENT
           ,p_module=> l_log_module );

      END IF;

   END IF;

   IF p_third_party_id IS NOT NULL THEN

      --
      -- Retrieve party id and party type code
      -- e.g. p_third_party_id = 1000#$C
      --      =>
      --      l_party_id = 100, l_party_type_code = C
      --
      l_party_id  := TO_NUMBER(SUBSTRB(p_third_party_id
                                   ,1
                                   ,INSTRB(p_third_party_id,'#$') - 1
                                   )
                           );

      l_party_type_code := SUBSTRB(p_third_party_id
                               ,INSTRB(p_third_party_id,'#$') + 2
                               ,LENGTHB(p_third_party_id));

      IF l_party_type_code = 'C' THEN

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN

            trace
              (p_msg   => 'Retrieving customer name for party id: '||l_party_id
              ,p_level => C_LEVEL_STATEMENT
              ,p_module=> l_log_module );

         END IF;

         SELECT hzp.party_name
           INTO p_third_party_name
           FROM hz_parties hzp
               ,hz_cust_accounts hca
          WHERE hzp.party_id = hca.party_id
            AND hca.cust_account_id = l_party_id;

      ELSIF l_party_type_code = 'S' THEN

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN

            trace
              (p_msg   => 'Retrieving supplier name for party id: '||l_party_id
              ,p_level => C_LEVEL_STATEMENT
              ,p_module=> l_log_module );

         END IF;

         SELECT vendor_name
           INTO p_third_party_name
           FROM ap_suppliers
          WHERE vendor_id = l_party_id;

      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

           trace
             (p_msg   => 'p_third_party_name = '|| p_third_party_name
             ,p_level => C_LEVEL_STATEMENT
             ,p_module=> l_log_module );

      END IF;

   END IF;

   IF p_acct_balance IS NOT NULL THEN

      SELECT meaning
        INTO p_acct_balance_dsp
        FROM xla_lookups
       WHERE lookup_type = 'XLA_TB_ACCT_BALANCE'
         AND lookup_code = p_acct_balance;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

         trace
           (p_msg   => 'p_acct_balance_dsp = '|| p_acct_balance_dsp
           ,p_level => C_LEVEL_STATEMENT
           ,p_module=> l_log_module );

      END IF;

   END IF;

   SELECT meaning
     INTO P_REPORT_MODE_DSP
     FROM xla_lookups
    WHERE lookup_type = 'XLA_REPORT_LEVEL'
     AND lookup_code = NVL(P_REPORT , 'D');

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

        trace
          (p_msg   => 'P_REPORT_MODE_DSP = '|| P_REPORT_MODE_DSP
          ,p_level => C_LEVEL_STATEMENT
          ,p_module=> l_log_module );

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of get_report_parameters'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     ('XLA'         , 'XLA_COMMON_FAILURE'
     ,'LOCATION'    , 'xla_tb_report_pvt.get_report_parameters'
     ,'ERROR'       ,  sqlerrm);
END get_report_parameters;


/*======================================================================+
|                                                                       |
| Provate Procedure                                                     |
|                                                                       |
|    Populate_Trail_Balance_Gt                                          |
|                                                                       |
|                                                                       |
|    Populate trial balance to xla_trial_balances_GT.                    |
|                                                                       |
+======================================================================*/
PROCEDURE populate_trial_balance_gt
  (p_defn_info            IN xla_tb_data_manager_pvt.r_definition_info
  ,p_ledger_info          IN xla_tb_data_manager_pvt.r_ledger_info
  ,p_journal_source       IN VARCHAR2
  ,p_start_date           IN DATE
  ,p_as_of_date           IN DATE
  ,p_third_party_id       IN VARCHAR2 -- <Party ID> || '#$' || <Party Type>
  ,p_show_trx_detail_flag IN VARCHAR2
  ,p_incl_write_off_flag  IN VARCHAR2
  ,p_acct_balance         IN VARCHAR2
  ,p_security_info        IN r_security_info)

IS


   l_log_module           VARCHAR2(240);

   l_party_id             NUMBER;
   l_party_type_code      VARCHAR2(30);
   l_party_column_cust    VARCHAR2(32000);
   l_party_column_supp    VARCHAR2(32000);
   l_ledger_column        VARCHAR2(32000);
   l_parameter_where      VARCHAR2(32000);

   l_insert_gt_sql        VARCHAR2(32000);
   l_insert_gt_cust_sql   VARCHAR2(32000);
   l_insert_gt_supp_sql   VARCHAR2(32000);

   l_application_id       NUMBER(15);
   l_select_string        VARCHAR2(4000);
   l_from_string          VARCHAR2(4000);
   l_where_string         VARCHAR2(4000);
   l_event_class_code     VARCHAR2(30);

   l_flex_range_where     VARCHAR2(32000);
   l_months_between       NUMBER(15); --Added for bug 8409806
   l_security_join        VARCHAR2(1000) ; -- added for bug:8773522

   CURSOR c_ec IS
   SELECT event_class_code
         ,select_string
         ,from_string
         ,where_string
    FROM  xla_tb_user_trans_views
   WHERE  definition_code = p_definition_code;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.populate_trial_balance_gt';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of populate_trial_balance_gt'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   --
   --  Debug information
   --
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg   => 'ledger_id = ' || p_ledger_info.ledger_id
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'ledger_name = ' || p_ledger_info.ledger_name
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'ledger_short_name = ' || p_ledger_info.ledger_short_name
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'ledger_category_code = '
                         || p_ledger_info.ledger_category_code
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'currency_code = ' || p_ledger_info.currency_code
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'coa_id = ' || p_ledger_info.coa_id
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'definition_code = ' || p_defn_info.definition_code
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'ledger_id (defn) = ' || p_defn_info.ledger_id
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'je_source_name = ' || p_defn_info.je_source_name
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'enabled_flag = ' || p_defn_info.enabled_flag
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'balance_side_code = ' || p_defn_info.balance_side_code
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'defined_by_code = ' || p_defn_info.defined_by_code
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'definition_status_code = '
                        || p_defn_info.definition_status_code
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

   END IF;

   --
   -- Retrieve user transaction identifiers
   --
 /*  OPEN c_ec;
   LOOP
      FETCH c_ec
       INTO l_event_class_code
           ,l_select_string
           ,l_from_string
           ,l_where_string;
       EXIT WHEN c_ec%NOTFOUND;*/

   --
   -- Assign template sql C_INSERT_GT_SELECT for Detail C_INSERT_GT_SUMMARY_SELECT for Summary Report
   -- to a local variable to replace strings

   -- Changes for bug#8773522
   IF XLA_TB_AP_REPORT_PVT.P_REPORT = 'S'
   THEN
   	l_insert_gt_sql := C_INSERT_GT_SUMMARY_STATEMENT || C_INSERT_GT_SUMMARY_SELECT;
   ELSE
   	l_insert_gt_sql := C_INSERT_GT_STATEMENT || C_INSERT_GT_SELECT;
   END IF ;

  /*
    commented as we are considering the  + parallel(xtb)  hint and allowing
    the optimizer to consider the correct path.

  --Added for bug 8409806

   select trunc(months_between(p_as_of_date, p_start_date))
   INTO l_months_between
   from dual;

   If l_months_between < 12 then

     l_insert_gt_sql:= REPLACE(l_insert_gt_sql,'$hint$','+ index(xtb XLA_TRIAL_BALANCES_N1) ');

   else

     l_insert_gt_sql:= REPLACE(l_insert_gt_sql,'$hint$','+ parallel(xtb) full(xtb)');

   END If;
  --Added for bug 8409806

  */


   IF p_account_from IS NOT NULL THEN

      l_flex_range_where := get_flex_range_where
                              (p_coa_id       => p_coa_id
                              ,p_account_from => p_account_from
                              ,p_account_to   => p_account_to);

      l_insert_gt_sql := REPLACE (
          l_insert_gt_sql
         ,'$account_range$'
         ,' AND cc.code_combination_id = tb.code_combination_id AND '||
          l_flex_range_where);

      l_insert_gt_sql := REPLACE(l_insert_gt_sql
                              ,'$account_tab$'
                              ,' ,gl_code_combinations cc ');

   ELSE

      l_insert_gt_sql := REPLACE(l_insert_gt_sql, '$account_range$', '');

      l_insert_gt_sql := REPLACE(l_insert_gt_sql
                              ,'$account_tab$'
                              ,'');

   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'After replace ledger col, l_insert_gl_sql ----'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   --
   -- Replace $amount_col$ based on balance side code
   -- For the inline view in C_INSERT_GT_SELECT
   --
   -- Added for bug 8321482,8228354
   -- Security Filter
   --
   -- Security Conditions are copied to l_security_join and
   -- appended at the end for DETAIL mode
   -- Replaced at the end for SUMMARY mode
   IF p_security_info.valuation_method IS NOT NULL THEN

      l_security_join := l_security_join    ||' AND xte.valuation_method = '''
                      || p_security_info.valuation_method ||'''';

   END IF;

   IF p_security_info.security_id_int_1 IS NOT NULL THEN

      l_security_join := l_security_join    ||' AND xte.security_id_int_1 = '
                      || p_security_info.security_id_int_1;

   END IF;

   IF p_security_info.security_id_char_1 IS NOT NULL THEN

      l_security_join := l_security_join    ||' AND xte.security_id_char_1 = '''
                      || p_security_info.security_id_char_1 ||'''';

   END IF;

   -- newly added for bug:8773522
   IF  XLA_TB_AP_REPORT_PVT.P_REPORT = 'S'
   THEN
   	IF l_security_join IS NOT NULL THEN
		l_insert_gt_sql := REPLACE(l_insert_gt_sql
                              		,'$security_valuation_join$'
                              		, l_security_join ) ;
   	ELSE
		l_insert_gt_sql := REPLACE(l_insert_gt_sql
                              ,'$security_valuation_join$'
                              ,'') ;
   	END IF;
   ELSE
   	IF l_security_join IS NOT NULL THEN
		l_insert_gt_sql := l_insert_gt_sql || l_security_join ;
	END IF;
   END IF;

   -- Added for bug 8321482,8228354
   --
   -- Retrieve party id and party type code
   -- e.g. p_third_party_id = 1000#$C
   --      =>
   --      l_party_id = 100, l_party_type_code = C
   --
   l_party_id  := TO_NUMBER(SUBSTRB(p_third_party_id
                                   ,1
                                   ,INSTRB(p_third_party_id,'#$') - 1
                                   )
                           );

   l_party_type_code := SUBSTRB(p_third_party_id
                               ,INSTRB(p_third_party_id,'#$') + 2
                               ,LENGTHB(p_third_party_id));

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'l_party_id: ' || l_party_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'l_party_type_code: ' || l_party_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'l_insert_gl_sql: ' || substr(l_insert_gt_sql,1,3500)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'l_insert_gl_sql: ' || substr(l_insert_gt_sql,3501,3500)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'l_insert_gl_sql: ' || substr(l_insert_gt_sql,7001,3500)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


      EXECUTE IMMEDIATE l_insert_gt_sql
        USING p_definition_code
         ,trunc(p_start_date)
          ,trunc(p_as_of_date)
           ,l_party_id;


   print_logfile('# of rows inserted into GT table '
                || ' - ' || l_event_class_code
                || ' : ' || SQL%ROWCOUNT);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => '# of rows inserted: ' || SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;


  -- END LOOP;
  -- CLOSE c_ec;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of populate_trial_balance_gt'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_tb_report_pvt.populate_trial_balance_gt');

END populate_trial_balance_gt;




/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| get_select_clause                                                     |
|                                                                       |
| Returns the sql for the event class                                   |
|                                                                       |
+======================================================================*/
FUNCTION get_upg_select_clause
RETURN VARCHAR2 IS

   l_upg_sql              VARCHAR2(32000);
   l_init_balance_dsp     xla_lookups.meaning%TYPE;
   l_ledger_cols          VARCHAR2(1000);
   l_balancing_segment              VARCHAR2(80);
   l_account_segment                VARCHAR2(80);
   l_costcenter_segment             VARCHAR2(80);
   l_management_segment             VARCHAR2(80);
   l_intercompany_segment           VARCHAR2(80);

   l_alias_balancing_segment        VARCHAR2(80);
   l_alias_account_segment          VARCHAR2(80);
   l_alias_costcenter_segment       VARCHAR2(80);
   l_alias_management_segment       VARCHAR2(80);
   l_alias_intercompany_segment     VARCHAR2(80);

   l_fnd_flex_hint        VARCHAR2(400);
   l_coa_id               NUMBER;

   l_seg_desc_column      VARCHAR2(32000);
   l_seg_desc_from        VARCHAR2(32000);
   l_seg_desc_join        VARCHAR2(32000);

BEGIN

   l_upg_sql := C_TB_UPG_SQL;

   l_upg_sql := REPLACE(l_upg_sql,'$definition_code$',p_definition_code);
   --
   -- Replace $gl_balance_cols$
   --
   -- Call replace_gl_bal_string
   l_upg_sql := replace_gl_bal_string
                   (p_select_sql           => l_upg_sql
                   ,p_ledger_id            => g_defn_info.ledger_id
                   ,p_account_balance_code => p_acct_balance -- Global Variable
                   ,p_balance_side_code    => g_defn_info.balance_side_code
                   ,p_upg_flag                => 'Y');

   l_upg_sql := REPLACE(l_upg_sql
                       ,'$p_start_date$'
                       ,trunc(p_start_date));

   l_upg_sql := REPLACE(l_upg_sql
                        ,'$p_as_of_date$'
                        ,trunc(p_as_of_date));

   --
   --  Replace $ledger_col$.
   --
   --  Returns following strings:
   --  <ledger_id>            ledger_id
   -- ,<ledger_name>          ledger_name
   -- ,<ledger_short_name>    ledger_short_name
   -- ,<ledger_currency_code> ledger_currency_code
   --
   l_ledger_cols :=
         g_ledger_info.ledger_id
      || '          ledger_id   '|| C_NEW_LINE  ||
      '         ,   ' || ''''    || g_ledger_info.ledger_name       || ''''
      || '          ledger_name '|| C_NEW_LINE  ||
      '         ,'    || ''''    || g_ledger_info.ledger_short_name  || ''''
      || '          ledger_short_name ' || C_NEW_LINE  ||
      '         ,'    || ''''    || g_ledger_info.currency_code     || ''''
      || '                         ledger_currency_code ';

   l_upg_sql := REPLACE (l_upg_sql
                        ,'$ledger_cols$'
                        ,l_ledger_cols);
   --
   --  Replace $initial_balance$ with 'Initial Balance'
   --
   SELECT meaning
     INTO l_init_balance_dsp
     FROM xla_lookups
    WHERE lookup_type = 'XLA_TB_TRX_TYPE';

   l_upg_sql := REPLACE (l_upg_sql,'$initial_balance$',l_init_balance_dsp);

   --
   --  Replace Amount Columns
   --
   IF g_defn_info.balance_side_code = 'C' THEN

      l_upg_sql := REPLACE (l_upg_sql,'$amount_cols$',C_UPG_CR_AMOUNT_COLUMN);

   ELSIF g_defn_info.balance_side_code = 'D' THEN

      l_upg_sql := REPLACE (l_upg_sql,'$amount_cols$',C_UPG_DR_AMOUNT_COLUMN);

   END IF;


   --
   -- Replace segment related columns
   --

   ----------------------------------------------------------------------------
   -- get qualifier segments for the COA
   ----------------------------------------------------------------------------
   xla_report_utility_pkg.get_acct_qualifier_segs
     (p_coa_id                    => p_coa_id
     ,p_balance_segment           => l_balancing_segment
     ,p_account_segment           => l_account_segment
     ,p_cost_center_segment       => l_costcenter_segment
     ,p_management_segment        => l_management_segment
     ,p_intercompany_segment      => l_intercompany_segment);

   --
   -- attach table alias to the column names
   --
   IF l_balancing_segment = 'NULL' THEN
      l_alias_balancing_segment := 'NULL';
   ELSE
      l_alias_balancing_segment := 'gcck.'||l_balancing_segment;
   END IF;

   IF l_account_segment = 'NULL' THEN
      l_alias_account_segment := 'NULL';
   ELSE
      l_alias_account_segment := 'gcck.'||l_account_segment;
   END IF;

   IF l_costcenter_segment = 'NULL' THEN
      l_alias_costcenter_segment := 'NULL';
   ELSE
      l_alias_costcenter_segment := 'gcck.'||l_costcenter_segment;
   END IF;

   IF l_management_segment = 'NULL' THEN
      l_alias_management_segment := 'NULL';
   ELSE
      l_alias_management_segment := 'gcck.'||l_management_segment;
   END IF;

   IF l_intercompany_segment = 'NULL' THEN
      l_alias_intercompany_segment := 'NULL';
   ELSE
      l_alias_intercompany_segment := 'gcck.'||l_intercompany_segment;
   END IF;

   --
   -- Replace segment related columns
   --
   xla_report_utility_pkg.get_segment_info
     (p_coa_id                    => p_coa_id
     ,p_balancing_segment         => l_balancing_segment
     ,p_account_segment           => l_account_segment
     ,p_costcenter_segment        => l_costcenter_segment
     ,p_management_segment        => l_management_segment
     ,p_intercompany_segment      => l_intercompany_segment
     ,p_alias_balancing_segment   => l_alias_balancing_segment
     ,p_alias_account_segment     => l_alias_account_segment
     ,p_alias_costcenter_segment  => l_alias_costcenter_segment
     ,p_alias_management_segment  => l_alias_management_segment
     ,p_alias_intercompany_segment=> l_alias_intercompany_segment
     ,p_seg_desc_column           => l_seg_desc_column
     ,p_seg_desc_from             => l_seg_desc_from
     ,p_seg_desc_join             => l_seg_desc_join
     ,p_hint                      => l_fnd_flex_hint
     );


   -- replace placeholders for the qualified segemnts
   --
   l_upg_sql := REPLACE(l_upg_sql, '$seg_desc_cols$', l_seg_desc_column);
   l_upg_sql := REPLACE(l_upg_sql, '$seg_desc_from$', l_seg_desc_from);
   l_upg_sql := REPLACE(l_upg_sql, '$seg_desc_join$', l_seg_desc_join);


   RETURN l_upg_sql;

END get_upg_select_clause;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| get_gcck_join                                                         |
|                                                                       |
| Returns the gcck join condition for definition code created with      |
| segment ranges. This join condition is used to derive SLA Manuals and |
| NON AP Amounts for definition codes created by seg ranges             |
+======================================================================*/

FUNCTION get_gcck_join
       (p_ledger_id                IN NUMBER
       ) RETURN VARCHAR2 IS

l_coa_id                  gl_ledgers.chart_of_accounts_id%TYPE;
l_join_gcck VARCHAR2(32000) := ' ';

BEGIN

   SELECT chart_of_accounts_id
     INTO l_coa_id
     FROM gl_ledgers
    WHERE ledger_id = p_ledger_id;


  l_join_gcck := l_join_gcck || ' AND  gcck.chart_of_accounts_id = ' || l_coa_id;

   FOR i IN ( SELECT *
              FROM xla_tb_defn_details d
              WHERE d.definition_code = p_definition_code
             )
   LOOP
      l_join_gcck := l_join_gcck || ' AND  gcck.'|| i.flexfield_segment_code  || ' BETWEEN ' ||
                    '''' ||  i.segment_value_from  || '''' || ' AND ' || '''' ||  i.segment_value_to  || '''';

    END LOOP;

   RETURN(l_join_gcck);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
     RAISE;
WHEN OTHERS    THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_ap_report_pvt.get_gcck_join');
END get_gcck_join;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| get_select_clause                                                     |
|                                                                       |
| Returns the sql for the event class                                   |
|                                                                       |
+======================================================================*/

FUNCTION get_select_clause
  (p_defn_info             IN xla_tb_data_manager_pvt.r_definition_info
  ,p_show_trx_detail_flag  IN VARCHAR2
  ,p_incl_write_off_flag   IN VARCHAR2
  ,p_account_balance_code  IN VARCHAR2)

RETURN BOOLEAN IS

   l_log_module                     VARCHAR2(240);

   l_source_sql                     VARCHAR2(32000);
   l_app_source_sql                 VARCHAR2(32000);
   l_upg_sql                        VARCHAR2(32000);
   l_write_off                      VARCHAR2(80);
   l_balance                        VARCHAR2(400);

   l_balancing_segment              VARCHAR2(80);
   l_account_segment                VARCHAR2(80);
   l_costcenter_segment             VARCHAR2(80);
   l_management_segment             VARCHAR2(80);
   l_intercompany_segment           VARCHAR2(80);

   l_alias_balancing_segment        VARCHAR2(80);
   l_alias_account_segment          VARCHAR2(80);
   l_alias_costcenter_segment       VARCHAR2(80);
   l_alias_management_segment       VARCHAR2(80);
   l_alias_intercompany_segment     VARCHAR2(80);

   l_fnd_flex_hint        VARCHAR2(400);
   l_coa_id               NUMBER;
   l_seg_desc_column                VARCHAR2(32000);
   l_seg_desc_from                  VARCHAR2(32000);
   l_seg_desc_join                  VARCHAR2(32000);

    --added TB phase 4 bug#7600550
    l_select_nonap_amount            VARCHAR2(32000);
    l_select_manual_sla_amount       VARCHAR2(32000);

    --added TB phase 4 bug#7600550 bug#8291101
    l_select_nonap_segranges_amt     VARCHAR2(32000);
    l_select_manual_segranges_amt    VARCHAR2(32000);

    TYPE t_ccid     IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;
    TYPE t_ledgerid IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;
    TYPE t_non_ap_amount   IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;
    TYPE t_manual_sla_amount   IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;


    arr_ledgerid        t_ledgerid;
    arr_ccid            t_ccid;

    arr_non_ap_amount        t_non_ap_amount;
    arr_manual_sla_amount    t_manual_sla_amount;

    CURSOR csr_seg_range_check IS
    SELECT code_combination_id
    FROM xla_tb_defn_details
    WHERE definition_code = p_definition_code;

    l_code_combination_id gl_code_combinations.code_combination_id%TYPE;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_select_clause';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_select_clause'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF XLA_TB_AP_REPORT_PVT.P_REPORT = 'S'
   THEN
   	l_source_sql := C_TB_SUMMARY_SOURCE_SQL  ;
   ELSE
   	IF p_incl_write_off_flag = 'Y' THEN
      		l_source_sql := C_TB_SOURCE_SQL||' UNION ALL '||C_TB_WRITE_OFF_SQL ;

     		SELECT meaning
        	INTO l_write_off
        	FROM xla_lookups
       		WHERE lookup_type = 'XLA_ACCOUNTING_CLASS'
         	  AND lookup_code = 'WRITE_OFF';

      		l_source_sql := REPLACE(l_source_sql, '$write_off$', l_write_off);
   	ELSE
      		l_source_sql := C_TB_SOURCE_SQL ;
 	END IF;

   	IF p_show_trx_detail_flag = 'Y' THEN
   		l_app_source_sql := C_TB_APPLIED_SQL;
    	ELSE
    		l_app_source_sql := 'Select 1 from dual where 1=2';
   	END IF;

    END IF;
   --
   ----------------------------------------------------------------------------
   -- get qualifier segments for the COA
   ----------------------------------------------------------------------------
   xla_report_utility_pkg.get_acct_qualifier_segs
     (p_coa_id                    => p_coa_id
     ,p_balance_segment           => l_balancing_segment
     ,p_account_segment           => l_account_segment
     ,p_cost_center_segment       => l_costcenter_segment
     ,p_management_segment        => l_management_segment
     ,p_intercompany_segment      => l_intercompany_segment);


   -- attach table alias to the column names
   --
   IF l_balancing_segment = 'NULL' THEN
      l_alias_balancing_segment := 'NULL';
   ELSE
      l_alias_balancing_segment := 'gcck.'||l_balancing_segment;
   END IF;

   IF l_account_segment = 'NULL' THEN
      l_alias_account_segment := 'NULL';
   ELSE
      l_alias_account_segment := 'gcck.'||l_account_segment;
   END IF;

   IF l_costcenter_segment = 'NULL' THEN
      l_alias_costcenter_segment := 'NULL';
   ELSE
      l_alias_costcenter_segment := 'gcck.'||l_costcenter_segment;
   END IF;

   IF l_management_segment = 'NULL' THEN
      l_alias_management_segment := 'NULL';
   ELSE
      l_alias_management_segment := 'gcck.'||l_management_segment;
   END IF;

   IF l_intercompany_segment = 'NULL' THEN
      l_alias_intercompany_segment := 'NULL';
   ELSE
      l_alias_intercompany_segment := 'gcck.'||l_intercompany_segment;
   END IF;

   --
   -- Replace segment related columns
   --
   xla_report_utility_pkg.get_segment_info
     (p_coa_id                    => p_coa_id
     ,p_balancing_segment         => l_balancing_segment
     ,p_account_segment           => l_account_segment
     ,p_costcenter_segment        => l_costcenter_segment
     ,p_management_segment        => l_management_segment
     ,p_intercompany_segment      => l_intercompany_segment
     ,p_alias_balancing_segment   => l_alias_balancing_segment
     ,p_alias_account_segment     => l_alias_account_segment
     ,p_alias_costcenter_segment  => l_alias_costcenter_segment
     ,p_alias_management_segment  => l_alias_management_segment
     ,p_alias_intercompany_segment=> l_alias_intercompany_segment
     ,p_seg_desc_column           => l_seg_desc_column
     ,p_seg_desc_from             => l_seg_desc_from
     ,p_seg_desc_join             => l_seg_desc_join
     ,p_hint                      => l_fnd_flex_hint
     );



   --
   -- replace placeholders for the qualified segemnts
   --
   l_source_sql := REPLACE(l_source_sql, '$seg_desc_cols$', l_seg_desc_column);
   l_source_sql := REPLACE(l_source_sql, '$seg_desc_from$', l_seg_desc_from);
   l_source_sql := REPLACE(l_source_sql, '$seg_desc_join$', l_seg_desc_join);

   l_source_sql := replace_gl_bal_string
                     (p_select_sql           => l_source_sql
                     ,p_ledger_id            => p_defn_info.ledger_id
                     ,p_account_balance_code => p_account_balance_code
                     ,p_balance_side_code    => p_defn_info.balance_side_code
                     ,p_upg_flag             => 'N');


   /*
   -- commented out for bug: 9133956 , AS in DATA MANAGER code to INSERT source_entity_id with -1
   -- has been commented 5635401
   IF p_defn_info.owner_code = C_OWNER_ORACLE THEN

      l_upg_sql    := get_upg_select_clause;
      l_source_sql := l_source_sql  || ' UNION ALL ' ||
                      l_upg_sql;

   END IF;
   */ -- bug 9133956

   IF XLA_TB_AP_REPORT_PVT.P_REPORT = 'S'
   THEN
   	P_SUMMARY_SQL_STATEMENT     := l_source_sql;
   ELSE
   	p_sql_statement     := l_source_sql;
   	p_app_sql_statement := l_app_source_sql;
   END IF;


  IF nvl(P_INCLUDE_SLA_MANUALS_UNPOSTED,'N') = 'Y' THEN


   OPEN csr_seg_range_check;
   FETCH csr_seg_range_check INTO l_code_combination_id;
   CLOSE csr_seg_range_check;

  IF l_code_combination_id IS NOT NULL
  THEN


   --added TB phase 4 bug#7600550
   l_select_nonap_amount       := C_SELECT_NONAP_AMOUNT;
   l_select_nonap_amount := REPLACE(l_select_nonap_amount,'$p_definition_code$',p_definition_code);


   EXECUTE IMMEDIATE l_select_nonap_amount
           BULK COLLECT INTO  arr_ledgerid, arr_ccid, arr_non_ap_amount
   USING trunc(p_start_date),
         trunc(p_as_of_date),
         trunc(p_start_date),
         trunc(p_as_of_date);

   FORALL i IN 1..arr_ccid.COUNT
      UPDATE xla_trial_balances_gt
      SET NON_AP_AMOUNT = arr_non_ap_amount(i)
      WHERE code_combination_id = arr_ccid(i)
      AND   ledger_id =  arr_ledgerid(i);


   l_select_manual_sla_amount  := C_SELECT_MANUAL_SLA_AMOUNT;
   l_select_manual_sla_amount := REPLACE(l_select_manual_sla_amount,'$p_definition_code$',p_definition_code);


   EXECUTE IMMEDIATE l_select_manual_sla_amount
            BULK COLLECT INTO  arr_ledgerid, arr_ccid, arr_manual_sla_amount
   USING  trunc(p_start_date),
          trunc(p_as_of_date);

   FORALL i IN 1..arr_ccid.COUNT
      UPDATE xla_trial_balances_gt
      SET MANUAL_SLA_AMOUNT = arr_manual_sla_amount(i)
      WHERE code_combination_id = arr_ccid(i)
      AND   ledger_id =  arr_ledgerid(i);

  --End TB phase 4 bug#7600550

   ELSE --definition code created by seg ranges

    l_select_nonap_segranges_amt :=  C_SELECT_NONAP_SEGRANGES_AMT;
    l_select_nonap_segranges_amt := REPLACE(l_select_nonap_segranges_amt,'$p_definition_code$',p_definition_code);
    l_select_nonap_segranges_amt := REPLACE(l_select_nonap_segranges_amt,'$gcck_join$',get_gcck_join(p_defn_info.ledger_id));

    EXECUTE IMMEDIATE l_select_nonap_segranges_amt
           BULK COLLECT INTO  arr_ledgerid, arr_ccid, arr_non_ap_amount
    USING trunc(p_start_date),
          trunc(p_as_of_date);

     FORALL i IN 1..arr_ccid.COUNT
      UPDATE xla_trial_balances_gt
      SET NON_AP_AMOUNT = arr_non_ap_amount(i)
      WHERE code_combination_id = arr_ccid(i)
      AND   ledger_id =  arr_ledgerid(i);

    l_select_manual_segranges_amt := C_SELECT_MANUAL_SEGRANGES_AMT;
    l_select_manual_segranges_amt := REPLACE(l_select_manual_segranges_amt,'$p_definition_code$',p_definition_code);
    l_select_manual_segranges_amt := REPLACE(l_select_manual_segranges_amt, '$gcck_join$' , get_gcck_join(p_defn_info.ledger_id));

    EXECUTE IMMEDIATE l_select_manual_segranges_amt
           BULK COLLECT INTO  arr_ledgerid, arr_ccid, arr_manual_sla_amount
    USING trunc(p_start_date),
          trunc(p_as_of_date);

    FORALL i IN 1..arr_ccid.COUNT
    UPDATE xla_trial_balances_gt
    SET    MANUAL_SLA_AMOUNT = arr_manual_sla_amount(i)
    WHERE  code_combination_id = arr_ccid(i)
    AND    ledger_id =  arr_ledgerid(i);

   END IF;

  END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

     IF XLA_TB_AP_REPORT_PVT.P_REPORT = 'S'
     THEN
     	dump_text(p_text => p_summary_sql_statement);
     ELSE
     	dump_text(p_text => p_sql_statement);
     END IF;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of get_select_clause'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   RETURN TRUE;


EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_tb_report_pvt.get_select_clause');

END get_select_clause;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Before_report                                                         |
|                                                                       |
| Code for before_report trigger                                        |
|                                                                       |
+======================================================================*/
FUNCTION before_report RETURN BOOLEAN

IS

   l_log_module               VARCHAR2(240);
   l_return                   BOOLEAN;
   l_ledger_id                NUMBER(15);

   l_definition_code          VARCHAR2(30);
   l_journal_source           VARCHAR2(50);
   l_third_party_id           VARCHAR2(80);
   l_show_trx_detail_flag     VARCHAR2(1);
   l_incl_write_off_flag      VARCHAR2(1);
   l_acct_balance             VARCHAR2(80);
   l_start_date               DATE;
   l_as_of_date               DATE;
   l_security_info            r_security_info;

   l_application_id           xla_subledgers.application_id%TYPE;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.before_report';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of before_report'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg   => 'p_definition_code = ' || p_definition_code
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_journal_source = ' || p_journal_source
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_third_party_id = ' || p_third_party_id
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_show_trx_detail_flag = ' || p_show_trx_detail_flag
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_incl_write_off_flag = ' || p_incl_write_off_flag
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_acct_balance = ' || p_acct_balance
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_start_date = ' || fnd_date.date_to_canonical
                                            (dateval => p_start_date)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_as_of_date = ' || fnd_date.date_to_canonical
                                            (dateval => p_as_of_date)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_security_flag = ' || p_security_flag
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_custom_param_1 = ' || p_custom_param_1
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_custom_param_2 = ' || p_custom_param_2
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_custom_param_3 = ' || p_custom_param_3
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_valuation_method = ' || p_valuation_method
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_security_id_int_1 = ' || p_security_id_int_1
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_security_id_char_1 = ' || p_security_id_char_1
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

   END IF;

   --
   -- 1. Retrieve displayed values for Concurrent Program Parameters
   --

   l_definition_code                  := p_definition_code;
   l_journal_source                   := p_journal_source;
   l_third_party_id                   := p_third_party_id;
   l_show_trx_detail_flag             := p_show_trx_detail_flag;
   l_incl_write_off_flag              := p_incl_write_off_flag;
   l_acct_balance                     := p_acct_balance;
   l_start_date                       := nvl(p_start_date,to_date('01-01-1950','DD-MM-YYYY'));
   l_as_of_date                       := p_as_of_date;
   l_security_info.valuation_method   := p_valuation_method;
   l_security_info.security_id_int_1  := p_security_id_int_1;
   l_security_info.security_id_char_1 := p_security_id_char_1;

   P_INCLUDE_SLA_MANUALS_UNPOSTED  := NVL(P_INCLUDE_SLA_MANUALS_UNPOSTED,'N');
   p_start_date                    := nvl(p_start_date,to_date('01-01-1950','DD-MM-YYYY'));

   print_logfile('>> get_report_parameters');

   get_report_parameters
      (p_journal_source        => l_journal_source
      ,p_definition_code       => l_definition_code
      ,p_third_party_id        => l_third_party_id
      ,p_show_trx_detail_flag  => l_show_trx_detail_flag
      ,p_incl_write_off_flag   => l_incl_write_off_flag
      ,p_acct_balance          => l_acct_balance);

   print_logfile('<< get_report_parameters');

   --
   -- 2. Set security context
   --
   IF NVL(p_security_flag,'N') = 'Y' THEN

      --
      -- The flag is 'Y' only when security function
      -- is defined for a given journal source
      -- That is when the flag is 'Y', the journal source is not null.
      --
      SELECT application_id
        INTO l_application_id
        FROM xla_subledgers
       WHERE je_source_name = l_journal_source;

      print_logfile('>> set_security_context');

      xla_security_pkg.set_security_context(l_application_id);

      print_logfile('<< set_security_context');

      print_logfile('# of operating units initialized: '
                  || mo_global.get_ou_count);

   END IF;
   --
   -- 3. Retrieve details of Ledger and Report Definition
   --
   print_logfile('>> get_report_definition');

   g_defn_info     := xla_tb_data_manager_pvt.get_report_definition
                        (p_definition_code => p_definition_code);

   print_logfile('<< get_report_definition');

   print_logfile('>> get_ledger_info');

   g_ledger_info   := xla_tb_data_manager_pvt.get_ledger_info
                        (p_ledger_id => g_defn_info.ledger_id);

   print_logfile('<< get_ledger_info');

   --
   -- 4. Populate trial balance data into the GT table
   --
   print_logfile('>> populate_trial_balance_gt');

   populate_trial_balance_gt
      (p_defn_info             => g_defn_info
      ,p_ledger_info           => g_ledger_info
      ,p_journal_source        => l_journal_source
      ,p_start_date            => l_start_date
      ,p_as_of_date            => l_as_of_date
      ,p_third_party_id        => l_third_party_id
      ,p_show_trx_detail_flag  => l_show_trx_detail_flag
      ,p_incl_write_off_flag   => l_incl_write_off_flag
      ,p_acct_balance          => l_acct_balance
      ,p_security_info         => l_security_info);

   print_logfile('<< populate_trial_balance_gt');

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'passed populate_trial_balance_gt'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

   --
   -- 5. Build select statement to retrieve trial balance data
   --
   print_logfile('>> get_select_clause');

   l_return := get_select_clause
                (p_defn_info               => g_defn_info
                ,p_show_trx_detail_flag    => p_show_trx_detail_flag
                ,p_incl_write_off_flag     => p_incl_write_off_flag
                ,p_account_balance_code    => p_acct_balance);

   print_logfile('<< get_select_clause');

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of before_report '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_tb_report_pvt.before_report');

END before_report;

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
                         ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_tb_ap_report_pvt;

/
