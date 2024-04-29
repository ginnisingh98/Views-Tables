--------------------------------------------------------
--  DDL for Package GL_GLXJETAX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXJETAX_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXJETAXS.pls 120.1 2008/01/02 05:58:05 vijranga noship $ */
	P_LEDGER_ID	number;
	P_CHART_OF_ACCOUNTS_ID	number;
	P_LOW_BAL_SEG	varchar2(25);
	CP_START_DATE  varchar2(25);
	CP_END_DATE varchar2(25);
	P_HIGH_BAL_SEG	varchar2(25);
	P_TAX_TYPE	varchar2(1);
	P_TAX_CODE	varchar2(50);
	P_START_DATE	date;
	P_END_DATE	date;
	P_POSTING_STATUS	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_ACCESS_SET_ID	number;
	C_OLD_GROUPS	varchar2(2000);
	C_OLD_HEADER_ID	number;
	C_RUN_ACCOUNTED_DR	number;
	C_RUN_ACCOUNTED_CR	number;
	H_LEDGER_NAME	varchar2(30);
	H_CURRENCY_CODE	varchar2(15);
	H_POSTING_MEANING	varchar2(30);
	H_ACCESS_SET_NAME	varchar2(30);
	P_BAL_SEGMENT	varchar2(600) := '(gcc1.SEGMENT1||gcc1.SEGMENT2||gcc1.SEGMENT3||gcc1.SEGMENT4||gcc1.SEGMENT5||gcc1.SEGMENT6||gcc1.SEGMENT7||gcc1.SEGMENT8||gcc1.SEGMENT9||gcc1.SEGMENT10||gcc1.SEGMENT11||
	gcc1.SEGMENT12||gcc1.SEGMENT13||gcc1.SEGMENT14||gcc1.SEGMENT15||gcc1.SEGMENT16||gcc1.SEGMENT17||
	gcc1.SEGMENT18||gcc1.SEGMENT19||gcc1.SEGMENT20||gcc1.SEGMENT21||gcc1.SEGMENT22||gcc1.SEGMENT23||gcc1.SEGMENT24||gcc1.SEGMENT25||gcc1.SEGMENT26||gcc1.SEGMENT27||gcc1.SEGMENT28||gcc1.SEGMENT29||gcc1.SEGMENT30)' ;
	P_TAXABLE_ACC_SEGMENT	varchar2(6000) := '(gcc1.SEGMENT1||gcc1.SEGMENT2||gcc1.SEGMENT3||gcc1.SEGMENT4||gcc1.SEGMENT5||gcc1.SEGMENT6||gcc1.SEGMENT7||gcc1.SEGMENT8||gcc1.SEGMENT9||gcc1.SEGMENT10||
	gcc1.SEGMENT11||gcc1.SEGMENT12||gcc1.SEGMENT13||gcc1.SEGMENT14||gcc1.SEGMENT15||gcc1.SEGMENT16||gcc1.SEGMENT17||gcc1.SEGMENT18||gcc1.SEGMENT19||gcc1.SEGMENT20||gcc1.SEGMENT21||gcc1.SEGMENT22||
	gcc1.SEGMENT23||gcc1.SEGMENT24||gcc1.SEGMENT25||gcc1.SEGMENT26||gcc1.SEGMENT27||gcc1.SEGMENT28||gcc1.SEGMENT29||gcc1.SEGMENT30)' ;
	P_TAX_ACC_SEGMENT	varchar2(6000) := '(gcc2.SEGMENT1||gcc2.SEGMENT2||gcc2.SEGMENT3||gcc2.SEGMENT4||gcc2.SEGMENT5||gcc2.SEGMENT6||gcc2.SEGMENT7||gcc2.SEGMENT8||gcc2.SEGMENT9||
	gcc2.SEGMENT10||gcc2.SEGMENT11||gcc2.SEGMENT12||gcc2.SEGMENT13||gcc2.SEGMENT14||gcc2.SEGMENT15||gcc2.SEGMENT16||gcc2.SEGMENT17||gcc2.SEGMENT18||gcc2.SEGMENT19||gcc2.SEGMENT20||
	gcc2.SEGMENT21||gcc2.SEGMENT22||gcc2.SEGMENT23||gcc2.SEGMENT24||gcc2.SEGMENT25||gcc2.SEGMENT26||gcc2.SEGMENT27||gcc2.SEGMENT28||gcc2.SEGMENT29||gcc2.SEGMENT30)' ;
	P_WHERE_BAL_SEGMENT	varchar2(300) := 'gcc1.segment1 between '||'00'||' and '||'ZZ' ;
	P_WHERE_POSTING_STATUS	varchar2(100) := 'gjb.status'||''''||' = '||'U' ;
	P_WHERE_TAX	varchar2(300) := '1 = 1' ;
	--P_WHERE_DAS	varchar2(600);
	P_WHERE_DAS	varchar2(600) := '1 = 1' ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function c_dr_or_crformula(C_TAXABLE_ACC_DR in number, C_TAXABLE_ACC_CR in number) return varchar2  ;
	function c_taxable_acc_amountformula(C_TAXABLE_ACC_DR in number, C_TAXABLE_ACC_CR in number) return number  ;
	function c_accounted_amountformula(C_ACCOUNTED_DR in number, C_ACCOUNTED_CR in number) return number  ;
	function c_grossformula(C_GROSS_DR in number, C_GROSS_CR in number) return number  ;
	function c_gross_drformula(C_TAXABLE_ACC_DR in number, C_ACCOUNTED_DR in number) return number  ;
	function c_gross_crformula(C_TAXABLE_ACC_CR in number, C_ACCOUNTED_CR in number) return number  ;
	function c_jou_grossformula(C_JOU_GROSS_DR in number, C_JOU_GROSS_CR in number) return number  ;
	function c_jou_accounted_sumformula(C_JOU_ACCOUNTED_DR in number, C_JOU_ACCOUNTED_CR in number) return number  ;
	function c_jou_taxable_acc_sumformula(C_JOU_TAXABLE_ACC_DR in number, C_JOU_TAXABLE_ACC_CR in number) return number  ;
	function c_jou_gross_drformula(C_JOU_TAXABLE_ACC_DR in number, C_JOU_ACCOUNTED_DR in number) return number  ;
	function c_jou_gross_crformula(C_JOU_TAXABLE_ACC_CR in number, C_JOU_ACCOUNTED_CR in number) return number  ;
	function c_tax_codeformula(C_TAX_TYPE_CODE in varchar2, C_TAX_CODE_ID in number) return varchar2  ;
	function c_jou_dr_or_crformula(C_JOU_TAXABLE_ACC_DR in number, C_JOU_TAXABLE_ACC_CR in number) return varchar2  ;
	function C_OLD_GROUPSFormula return VARCHAR2  ;
	function c_new_groupformula(C_JE_HEADER_ID in number, C_TAX_GROUP_ID in number, C_ACCOUNTED_DR in number, C_ACCOUNTED_CR in number) return varchar2  ;
	function C_OLD_HEADER_IDFormula return Number  ;
	function C_RUN_ACCOUNTED_DRFormula return Number  ;
	function C_RUN_ACCOUNTED_CRFormula return Number  ;
	function g_taxablegroupfilter(ACC_SECURE in varchar2) return boolean  ;
	function g_bal_segmentgroupfilter(BAL_SECURE in varchar2) return boolean  ;
	Function C_OLD_GROUPS_p return varchar2;
	Function C_OLD_HEADER_ID_p return number;
	Function C_RUN_ACCOUNTED_DR_p return number;
	Function C_RUN_ACCOUNTED_CR_p return number;
	Function H_LEDGER_NAME_p return varchar2;
	Function H_CURRENCY_CODE_p return varchar2;
	Function H_POSTING_MEANING_p return varchar2;
	Function H_ACCESS_SET_NAME_p return varchar2;
	Function P_BAL_SEGMENT_p return varchar2;
	Function P_TAXABLE_ACC_SEGMENT_p return varchar2;
	Function P_TAX_ACC_SEGMENT_p return varchar2;
	Function P_WHERE_BAL_SEGMENT_p return varchar2;
	Function P_WHERE_POSTING_STATUS_p return varchar2;
	Function P_WHERE_TAX_p return varchar2;
	Function P_WHERE_DAS_p return varchar2;
END GL_GLXJETAX_XMLP_PKG;



/
