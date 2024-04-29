--------------------------------------------------------
--  DDL for Package AR_RAXNCAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXNCAR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXNCARS.pls 120.0 2007/12/27 14:31:41 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_Start_GL_Date	date;
	P_End_GL_Date	date;
	P_Min_Precision	number;
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	RP_SUB_TITLE	varchar2(2100);
	Cm_foot	varchar2(80);
	Dep_Foot	varchar2(80);
	Guar_foot	varchar2(80);
	Inv_foot	varchar2(80);
	Yes	varchar2(80);
	No	varchar2(80);
	Arra_Min	varchar2(11);
	Arra_Max	varchar2(11);
	Adjs_Min	varchar2(11);
	Adjs_Max	varchar2(11);
	Min_Date	varchar2(11);
	Max_Date	varchar2(11);
	Sql_Start_Date	varchar2(11);
	Sql_End_Date	varchar2(11);
	GSum_Tran_Foreign_Dsp	varchar2(17);
	GSum_Tran_Funct_Dsp	varchar2(17);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function Sub_TitleFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_SUB_TITLE_p return varchar2;
	Function Cm_foot_p return varchar2;
	Function Dep_Foot_p return varchar2;
	Function Guar_foot_p return varchar2;
	Function Inv_foot_p return varchar2;
	Function Yes_p return varchar2;
	Function No_p return varchar2;
	Function Arra_Min_p return varchar2;
	Function Arra_Max_p return varchar2;
	Function Adjs_Min_p return varchar2;
	Function Adjs_Max_p return varchar2;
	Function Min_Date_p return varchar2;
	Function Max_Date_p return varchar2;
	Function Sql_Start_Date_p return varchar2;
	Function Sql_End_Date_p return varchar2;
	Function GSum_Tran_Foreign_Dsp_p return varchar2;
	Function GSum_Tran_Funct_Dsp_p return varchar2;
	function D_Tran_ForeignFormula return VARCHAR2;
END AR_RAXNCAR_XMLP_PKG;


/
