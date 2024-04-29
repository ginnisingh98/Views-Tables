--------------------------------------------------------
--  DDL for Package GL_GLXDDA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXDDA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXDDAS.pls 120.0 2007/12/27 14:54:29 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_CONSOLIDATION_ID	varchar2(15);
	P_PERIOD_NAME	varchar2(15);
	P_FLEXDATA1	varchar2(1000);
	P_FLEXDATA2	varchar2(1000);
	P_ORDERBY	varchar2(298);
	STRUCT_NUM	varchar2(15);
	Ledger_Name	varchar2(30);
	To_Ledger_Name	varchar2(30);
	From_Ledger_Name	varchar2(30);
	ConsolidationName	varchar2(33);
	WHERE_DR_CR_NOT_ZERO	varchar2(300) := '((nvl(glca.entered_dr,0) <> 0) or (nvl(glca.entered_cr,0) <> 0))' ;
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	procedure gl_get_consolidation_info(
                           cons_id number, cons_name out NOCOPY varchar2,
                           method out NOCOPY varchar2, curr_code out NOCOPY varchar2,
                           from_ledid out NOCOPY number, to_ledid out NOCOPY number,
                           description out NOCOPY varchar2, errbuf out NOCOPY varchar2)  ;
	Function STRUCT_NUM_p return varchar2;
	Function Ledger_Name_p return varchar2;
	Function To_Ledger_Name_p return varchar2;
	Function From_Ledger_Name_p return varchar2;
	Function ConsolidationName_p return varchar2;
	Function WHERE_DR_CR_NOT_ZERO_p return varchar2;
END GL_GLXDDA_XMLP_PKG;



/
