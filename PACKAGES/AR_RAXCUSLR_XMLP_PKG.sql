--------------------------------------------------------
--  DDL for Package AR_RAXCUSLR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXCUSLR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXCUSLRS.pls 120.0 2007/12/27 14:18:12 abraghun noship $ */
	TODAY	date;
	lp_lcn	varchar2(200);
	lp_hcn	varchar2(200);
	lcn	varchar2(30);
	hcn	varchar2(30);
	P_Conc_Request_Id	number:=0;
	P_Order_By	varchar2(32767);
	P_Customer_Name_Low	varchar2(360);
	P_Customer_Name_High	varchar2(360);
	lp_customer_low	varchar2(700);
	lp_customer_high	varchar2(700);
	P_veh_select_column1	varchar2(35):='123456789012345678912345678901234';
	P_veh_from_table	varchar2(50);
	P_veh_where_clause1	varchar2(150):='null';
	P_veh_install_status	varchar2(32767);
	P_veh_select_column2	varchar2(35):='123456789012345678901234567891234';
	P_veh_where_clause2	varchar2(150):='null';
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(240);
	RP_DATA_FOUND	varchar2(32767);
	TERR_FLEX_ALL_SEG	varchar2(240) := 'RATT.SEGMENT1||''.''||RATT.SEGMENT2||''.''||RATT.SEGMENT3' ;
	c_industry_code	varchar2(20);
	c_salesrep_title	varchar2(20);
	c_sales_title	varchar2(20);
	c_salester_title	varchar2(20);
	function AfterPForm return boolean  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function ITEM_FLEX_STRUCTUREFormula return VARCHAR2  ;
	function Set_DataFormula return VARCHAR2  ;
	procedure get_lookup_meaning(p_lookup_type	in varchar2,
			     p_lookup_code	in varchar2,
			     p_lookup_meaning  	in out nocopy varchar2);
	procedure get_boiler_plates  ;
	function set_display_for_core(p_field_name in varchar2) return boolean  ;
	function set_display_for_gov(p_field_name in varchar2) return boolean  ;
	function c_veh_tp_designatorformula(TRANSLATOR_CODE in varchar2) return varchar2  ;
	function G_CU_ADDRESSGroupFilter return boolean  ;
	function CF_ORDER_BYFormula return Char  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function TERR_FLEX_ALL_SEG_p return varchar2;
	Function c_industry_code_p return varchar2;
	Function c_salesrep_title_p return varchar2;
	Function c_sales_title_p return varchar2;
	Function c_salester_title_p return varchar2;
	PROCEDURE Get_Customer_Segment;
     PROCEDURE Setup_Automotive_Requirements ;
     PROCEDURE Get_Company_Name ;
     PROCEDURE Get_Report_Name ;

END AR_RAXCUSLR_XMLP_PKG;



/
