--------------------------------------------------------
--  DDL for Package AR_RAXINX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXINX_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXINXS.pls 120.0 2007/12/27 14:29:01 abraghun noship $ */
	p_start_gl_date	date;
	p_end_gl_date	date;
	p_start_trx_date	date;
	p_end_trx_date	date;
	CP_START_GL_DATE varchar2(25);
	CP_END_GL_DATE VARCHAR2(25);
	CP_START_TRX_DATE VARCHAR2(25);
	CP_END_TRX_DATE VARCHAR2(25);
	invoice_type_low	varchar2(32767);
	invoice_type_high	varchar2(32767);
	start_currency_code	varchar2(15);
	end_currency_code	varchar2(15);
	sortname	varchar2(40);
	lp_sortname varchar2(40):='Customer';
	P_CONC_REQUEST_ID	number;
	lp_start_trx_date	varchar2(500):=' ';
	lp_end_trx_date	varchar2(500):=' ';
	D_COMPANY_NAME	varchar2(50);
	P_REPORTING_ENTITY_ID	number;
	P_REPORTING_ENTITY_NAME	varchar2(200);
	P_REPORTING_LEVEL	varchar2(30);
	P_REPORTING_LEVEL_NAME	varchar2(30);
	P_ORG_WHERE_CUST	varchar2(2000):=' ';
	P_ORG_WHERE_DIST	varchar2(2000):=' ';
	P_ORG_WHERE_TRX	varchar2(2000):=' ';
	P_IN_BAL_SEGMENT_LOW	varchar2(60);
	P_IN_BAL_SEGMENT_HIGH	varchar2(60);
	P_COAID	number;
	LP_BAL_SEG_LOW	varchar2(200):=' ';
	LP_BAL_SEG_HIGH	varchar2(200):=' ';
	P_ORG_WHERE_TYPE	varchar2(2000):=' ';
	RP_FUNC_CURR	varchar2(32767):=' ';
	lp_start_currency	varchar2(200):=' ';
	lp_end_currency	varchar2(200):=' ';
	lp_end_trx_date2	varchar2(200):=' ';
	lp_start_gl_date	varchar2(200):=' ';
	lp_end_gl_date	varchar2(200):=' ';
	lp_start_trx	varchar2(200):=' ';
	lp_end_trx	varchar2(200):=' ';
	lp_start_trx_date2	varchar2(200):=' ';
	RP_REPORT_NAME	varchar2(240);
	CP_ACC_MESSAGE	varchar2(2000);
	RP_MESSAGE VARCHAR2(2000);
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	function c_populateformula(COMPANY_NAME in varchar2, c_functional_currency in varchar2) return varchar2  ;
	function REPORT_NAMEFormula return varChar  ;
	function BeforeReport return boolean  ;
	Function RP_REPORT_NAME_p return varchar2;
	Function CP_ACC_MESSAGE_p return varchar2;
    FUNCTION RP_MESSAGE_P RETURN VARCHAR2;
END AR_RAXINX_XMLP_PKG;


/
