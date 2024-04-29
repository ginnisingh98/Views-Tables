--------------------------------------------------------
--  DDL for Package GL_GLWACCTR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLWACCTR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLWACCTRS.pls 120.1 2008/01/09 07:27:46 vijranga noship $ */
	P_LEDGER_ID	number;
	P_CURRENCY	varchar2(15);
	P_START_DATE	varchar2(32767);
	P_END_DATE	varchar2(32767);
	P_STATUS	varchar2(32767);
	P_DOC_ID	number;
	P_DOC_VALUE	number;
	P_COA	number;
	C_PARAM_START_DATE varchar2(20);
	C_PARAM_END_DATE varchar2(20);
	C_DATE_FORMAT varchar2(20);
	P_AFF_FROM	varchar2(800);
	P_AFF_TO	varchar2(800);
	P_AMOUNT_FROM	number;
	P_AMOUNT_TO	number;
	P_SUB_DOC_ID	varchar2(40);
	P_SUB_DOC_VALUE	varchar2(40);
	P_CONTRA_ACCT	varchar2(25);
	P_CONC_REQUEST_ID	number;
	P_PAGEBREAK	varchar2(25);
	P_SEC_SEG_NUM	varchar2(5);
	P_ACTUAL_FLAG	varchar2(1);
	P_ACCESS_SET_ID	number;
	P_DEBUG	varchar2(5);
	P_AMT_FLAG	varchar2(5);
	P_CONTRA_FLAG	varchar2(32767);
	P_SOURCE	varchar2(50);
	P_CATEGORY	varchar2(25);
	P_BATCH_NAME	varchar2(100);
	P_BAL_SEG_VAL	varchar2(25);
	P_START_DOC_VALUE	varchar2(255);
	P_END_DOC_VALUE	number;
	P_JOURNALS_LINE_FLAG	varchar2(32767);
	P_PERIOD_NAME	varchar2(30);
	P_LAST_UPDATED_BY	number;
	P_REPORT_NAME	varchar2(100);
	P_START_UPDATE_DATE	varchar2(32767);
	P_LAST_UPDATE_DATE	varchar2(32767);
	P_END_UPDATE_DATE	varchar2(32767);
	P_PERF_FROM_CLUASE	varchar2(40);
	ACCESS_SET_NAME	varchar2(30);
	PARAM_CURRENCY_CODE	varchar2(20);
	CHART_OF_ACCOUNTS_ID	number;
	PARAM_START_DATE	date;
	PARAM_END_DATE	date;
	PARAM_DOC_SEQ_VALUE	number;
	PARAM_AMOUNT_LOW	number;
	PARAM_AMOUNT_HIGH	number;
	PARAM_SUB_DOC_SEQ_VALUE	number;
	SELECT_ACCT_SEGMENT	varchar2(30) := 'cc.segment3' ;
	SELECT_BAL_SEGMENT	varchar2(30) := 'cc.segment1' ;
	PARAM_SEC_SEG_NAME	varchar2(240);
	PARAM_POSTING_STATUS	varchar2(80);
	NO_CONTRA_ACCOUNT	varchar2(20);
	P_ACC_SEGMENT_WHERE	varchar2(1200);
	P_CURRENCY_WHERE	varchar2(200);
	P_SEC_SEGMENT_WHERE	varchar2(200);
	P_DAS_WHERE	varchar2(600);
	SELECT_ACCOUNT	varchar2(1000) := '(CC.SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3 || ''\n'' || SEGMENT4 || ''\n'' || SEGMENT5 || ''\n'' || SEGMENT6 || ''\n'' || SEGMENT7 || ''\n'' || SEGMENT8 || ''\n'' || SEGMENT9 || ''\n'' || SEGMENT10
	|| ''\n'' || SEGMENT11 || ''\n'' || SEGMENT12 || ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15 || ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' || SEGMENT18 || ''\n'' || SEGMENT19 || ''\n''
	|| SEGMENT20 || ''\n'' || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' || SEGMENT23 || ''\n'' || SEGMENT24 || ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27 || ''\n'' || SEGMENT28 || ''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)';
	SELECT_SECONDARY_SEGMENT	varchar2(30) := 'NULL' ;
	P_POSTING_STATUS	varchar2(500);
	P_HEADER_POSTING_STATUS	varchar2(500);
	P_SOURCE_WHERE	varchar2(200);
	P_BATCH_WHERE	varchar2(500);
	P_CATEGORY_WHERE	varchar2(500);
	P_BAL_WHERE	varchar2(500);
	P_DOC_ID_WHERE	varchar2(500);
	P_DOC_VAL_WHERE	varchar2(500);
	P_SUB_DOC_ID_WHERE	varchar2(500);
	P_SUB_DOC_VAL_WHERE	varchar2(500);
	P_NOT_ZERO_LINE_WHERE	varchar2(500);
	P_CONTRA_ACCOUNT_WHERE	varchar2(2000);
	P_CONTRA_ACCOUNT	varchar2(255);
	P_PERIOD_WHERE	varchar2(2000);
	P_JOURNAL_DATE_WHERE	varchar2(2000);
	P_JOURNAL_DATE_WHERE_2	varchar2(2000);
	P_USE_DATE_COL	varchar2(500);
	P_JOURNAL_FROM_CLAUSE	varchar2(4000);
	P_JOURNAL_WHERE_CLAUSE	varchar2(2000);
	PARAM_SOURCE	varchar2(30);
	PARAM_CATEGORY	varchar2(30);
	PARAM_BATCH_NAME	varchar2(100);
	PARAM_LAST_UPDATED_BY	varchar2(100);
	PARAM_BALANCING_SEGMENT	varchar2(30);
	PARAM_PERIOD_NAME	varchar2(15);
	PARAM_BASIS	varchar2(80);
	PARAM_DOC_SEQ_NAME	varchar2(30);
	PARAM_ACCT_FROM	varchar2(800);
	PARAM_ACCT_TO	varchar2(800);
	PARAM_AMT_FLAG	varchar2(80);
	PARAM_SUB_DOC_SEQ_NAME	varchar2(30);
	PARAM_CONTRA_ACCT	varchar2(30);
	PARAM_LEDGER_NAME	varchar2(30);
	PARAM_START_DOC_SEQ_VALUE	number;
	PARAM_END_DOC_SEQ_VALUE	number;
	H_SET_OF_BOOKS_ID	number;
	BAL_SEG_NAME_DSP	varchar2(240);
	ACCT_SEG_NAME_DSP	varchar2(240);
	SELECT_COST_CTR_SEGMENT	varchar2(30) := 'NULL' ;
	H_START_DATE	date;
	H_END_DATE	date;
	PREV_BAL_SEG_VAL	varchar2(20) := 'N' ;
	P_LEDGER_WHERE	varchar2(1000);
	P_LEDGER_FROM	varchar2(250);
	PREV_ACCT_SEG_VAL	varchar2(52) := 'N' ;
	PREV_SEC_SEG_VAL	varchar2(20) := '0' ;
	PREV_LED_ID	number := 0 ;
	PREV_LINE_BAL	number := 0 ;
	PREV_GL_BAL	number := 0 ;
	P_AFF_WHERE	varchar2(2000);
	P_AMOUNT_WHERE	varchar2(1000);
	P_AFF_WHERE_JRL	varchar2(4000);
	P_ACC_SEGMENT_SELECT	varchar2(2000);
	P_JOURNAL_UPD_DATE_WHERE	varchar2(1000);
	H_START_UPDATE_DATE	date;
	H_END_UPDATE_DATE	date;
	P_JOURNAL_LAST_UPD_WHERE	varchar2(400);
	P_JOURNAL_DATE_WHERE_3	varchar2(500);
	P_HINT_CLAUSE	varchar2(1000);
	P_PERF_FROM	varchar2(3000) := 'GL_LEDGERS LGR,        GL_JE_BATCHES   GLB,         GL_JE_HEADERS   GLH,         GL_JE_SOURCES          GJS,         GL_JE_CATEGORIES         GJC,         GL_JE_LINES    GLL,
		GL_DAILY_CONVERSION_TYPES      DCT,         FND_DOCUMENT_SEQUENCES  DOCSEQ,          FND_DOCUMENT_SEQUENCES  SUBDOCSEQ,         GL_CODE_COMBINATIONS CC,         FND_USER    FU' ;
	P_ACTUAL_TYPE_WHERE	varchar2(500);
	function AfterReport return boolean  ;
	PROCEDURE SET_DATE_FORMAT  ;
	function CF_1Formula return Char  ;
	function H_START_PERIOD_DATEFormula return DATE  ;
	function H_START_PERIOD_NAMEFormula return Char  ;
	function NO_CONTRA_ACCOUNTFormula return Char  ;
	function tax_typeformula(TAX_TYPE_CODE in varchar2) return char  ;
	function approval_statusformula(APPROVAL_STATUS_CODE in varchar2) return char  ;
	function batch_statusformula(BATCH_STATUS_CODE in varchar2) return char  ;
	function batch_typeformula(ACTUAL_FLAG in varchar2) return char  ;
	function budget_ctrl_statusformula(BUD_CONTROL_STATUS in varchar2) return char  ;
	function jrnl_typeformula(AVERAGE_JOURNAL_FLAG in varchar2) return char  ;
	function tax_statusformula(TAX_STATUS_CODE in varchar2) return char  ;
	function budget_nameformula(BUDGET_VERSION_ID in number) return char  ;
	function encumbrance_typeformula(ENCUMBRANCE_TYPE_ID in number) return char  ;
	function tax_codeformula(TAX_CODE_ID in number, TAX_TYPE_CODE in varchar2) return char  ;
	function contra_acct_valueformula(HDR_ID in number, SUB_DOC_SEQ_ID in number, SUB_DOC_SEQ_VAL in number, ACCOUNTED_DR in number, ACCOUNTED_CR in number) return char  ;
	function cf_line_balanceformula(BAL_SEG_VAL in varchar2, ACCT_SEG_VAL in varchar2, ADDITIONAL_SEGMENT_VALUE in varchar2, LEDGER_ID in number, BATCH_STATUS_CODE in varchar2) return number  ;
	function cf_gl_balanceformula(BAL_SEG_VAL in varchar2, ACCT_SEG_VAL in varchar2, ADDITIONAL_SEGMENT_VALUE in varchar2, LEDGER_ID in number, BATCH_STATUS_CODE in varchar2) return number  ;
	function begin_balanceformula(CF_LINE_BALANCE in number, CF_GL_BALANCE in number) return number  ;
	Function ACCESS_SET_NAME_p return varchar2;
	Function PARAM_CURRENCY_CODE_p return varchar2;
	Function CHART_OF_ACCOUNTS_ID_p return number;
	Function PARAM_START_DATE_p return date;
	Function PARAM_END_DATE_p return date;
	Function PARAM_DOC_SEQ_VALUE_p return number;
	Function PARAM_AMOUNT_LOW_p return number;
	Function PARAM_AMOUNT_HIGH_p return number;
	Function PARAM_SUB_DOC_SEQ_VALUE_p return number;
	Function SELECT_ACCT_SEGMENT_p return varchar2;
	Function SELECT_BAL_SEGMENT_p return varchar2;
	Function PARAM_SEC_SEG_NAME_p return varchar2;
	Function PARAM_POSTING_STATUS_p return varchar2;
	Function NO_CONTRA_ACCOUNT_p return varchar2;
	Function P_ACC_SEGMENT_WHERE_p return varchar2;
	Function P_CURRENCY_WHERE_p return varchar2;
	Function P_SEC_SEGMENT_WHERE_p return varchar2;
	Function P_DAS_WHERE_p return varchar2;
	Function SELECT_ACCOUNT_p return varchar2;
	Function SELECT_SECONDARY_SEGMENT_p return varchar2;
	Function P_POSTING_STATUS_p return varchar2;
	Function P_HEADER_POSTING_STATUS_p return varchar2;
	Function P_SOURCE_WHERE_p return varchar2;
	Function P_BATCH_WHERE_p return varchar2;
	Function P_CATEGORY_WHERE_p return varchar2;
	Function P_BAL_WHERE_p return varchar2;
	Function P_DOC_ID_WHERE_p return varchar2;
	Function P_DOC_VAL_WHERE_p return varchar2;
	Function P_SUB_DOC_ID_WHERE_p return varchar2;
	Function P_SUB_DOC_VAL_WHERE_p return varchar2;
	Function P_NOT_ZERO_LINE_WHERE_p return varchar2;
	Function P_CONTRA_ACCOUNT_WHERE_p return varchar2;
	Function P_CONTRA_ACCOUNT_p return varchar2;
	Function P_PERIOD_WHERE_p return varchar2;
	Function P_JOURNAL_DATE_WHERE_p return varchar2;
	Function P_JOURNAL_DATE_WHERE_2_p return varchar2;
	Function P_USE_DATE_COL_p return varchar2;
	Function P_JOURNAL_FROM_CLAUSE_p return varchar2;
	Function P_JOURNAL_WHERE_CLAUSE_p return varchar2;
	Function PARAM_SOURCE_p return varchar2;
	Function PARAM_CATEGORY_p return varchar2;
	Function PARAM_BATCH_NAME_p return varchar2;
	Function PARAM_LAST_UPDATED_BY_p return varchar2;
	Function PARAM_BALANCING_SEGMENT_p return varchar2;
	Function PARAM_PERIOD_NAME_p return varchar2;
	Function PARAM_BASIS_p return varchar2;
	Function PARAM_DOC_SEQ_NAME_p return varchar2;
	Function PARAM_ACCT_FROM_p return varchar2;
	Function PARAM_ACCT_TO_p return varchar2;
	Function PARAM_AMT_FLAG_p return varchar2;
	Function PARAM_SUB_DOC_SEQ_NAME_p return varchar2;
	Function PARAM_CONTRA_ACCT_p return varchar2;
	Function PARAM_LEDGER_NAME_p return varchar2;
	Function PARAM_START_DOC_SEQ_VALUE_p return number;
	Function PARAM_END_DOC_SEQ_VALUE_p return number;
	Function H_SET_OF_BOOKS_ID_p return number;
	Function BAL_SEG_NAME_DSP_p return varchar2;
	Function ACCT_SEG_NAME_DSP_p return varchar2;
	Function SELECT_COST_CTR_SEGMENT_p return varchar2;
	Function H_START_DATE_p return date;
	Function H_END_DATE_p return date;
	Function PREV_BAL_SEG_VAL_p return varchar2;
	Function P_LEDGER_WHERE_p return varchar2;
	Function P_LEDGER_FROM_p return varchar2;
	Function PREV_ACCT_SEG_VAL_p return varchar2;
	Function PREV_SEC_SEG_VAL_p return varchar2;
	Function PREV_LED_ID_p return number;
	Function PREV_LINE_BAL_p return number;
	Function PREV_GL_BAL_p return number;
	Function P_AFF_WHERE_p return varchar2;
	Function P_AMOUNT_WHERE_p return varchar2;
	Function P_AFF_WHERE_JRL_p return varchar2;
	Function P_ACC_SEGMENT_SELECT_p return varchar2;
	Function P_JOURNAL_UPD_DATE_WHERE_p return varchar2;
	Function H_START_UPDATE_DATE_p return date;
	Function H_END_UPDATE_DATE_p return date;
	Function P_JOURNAL_LAST_UPD_WHERE_p return varchar2;
	Function P_JOURNAL_DATE_WHERE_3_p return varchar2;
	Function P_HINT_CLAUSE_p return varchar2;
	Function P_PERF_FROM_p return varchar2;
	Function P_ACTUAL_TYPE_WHERE_p return varchar2;
	FUNCTION BEFOREREPORT RETURN BOOLEAN;
END GL_GLWACCTR_XMLP_PKG;



/