--------------------------------------------------------
--  DDL for Package GL_GLXUSA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXUSA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXUSAS.pls 120.0 2007/12/27 15:24:43 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_CONSOLIDATION_ID	number;
	P_PERIOD_NAME	varchar2(15);
	P_PERIOD_TYPE	varchar2(32767);
	P_FLEXDATA	varchar2(1000);
	P_ORDERBY	varchar2(750);
	P_BALJOIN	varchar2(1000) := 'glb.period_net_dr = 0';
	P_BALJOINAB	varchar2(1000) := 'gdb.period_average_to_date_num <> 0';
	P_N	varchar2(1) := 'N';
	P_A	varchar2(1) := 'A';
	P_Y	varchar2(1) := 'Y';
	PZ	varchar2(2) := 'ZZ';
	P_Accounts	varchar2(25000) := '( 1 = 1 )';
	P_Accounts_Clause	varchar2(1) := 'N';
	P_Accounts_ADB	varchar2(25000) := '( 1 = 1 )';
	P_Accounts_Clause_ADB	varchar2(1) := 'N';
	STRUCT_NUM	varchar2(115);
	CONSOLIDATION_NAME	varchar2(33);
	ParentLedgerName	varchar2(30);
	SubsidLedgerName	varchar2(30);
	ConsCurrencyCode	varchar2(15);
	SubsidLedgerId	number;
	FromCurrencyCode	varchar2(15);
	PeriodSetName	varchar2(16);
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	procedure gl_get_consolidation_info(
                           cons_id number, cons_name out nocopy varchar2,
                           method out varchar2, curr_code out nocopy varchar2,
                           from_ledid out number, to_ledid out nocopy number,
                           description out nocopy varchar2,
                           errbuf out nocopy varchar2)  ;
	procedure gl_check_cons_accounts(
                           cons_id  number,
                           avg_flag varchar2,
                           actual_flag varchar2,
                           amount_type varchar2,
                           records_present out nocopy varchar2
                           )  ;
	Function STRUCT_NUM_p return varchar2;
	Function CONSOLIDATION_NAME_p return varchar2;
	Function ParentLedgerName_p return varchar2;
	Function SubsidLedgerName_p return varchar2;
	Function ConsCurrencyCode_p return varchar2;
	Function SubsidLedgerId_p return number;
	Function FromCurrencyCode_p return varchar2;
	Function PeriodSetName_p return varchar2;
END GL_GLXUSA_XMLP_PKG;



/
