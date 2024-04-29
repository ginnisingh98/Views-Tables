--------------------------------------------------------
--  DDL for Package AR_ARXBDP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXBDP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXBDPS.pls 120.0 2007/12/27 13:34:51 abraghun noship $ */
	P_last_updated_by	varchar2(50);
	P_Group_Id	varchar2(50);
	P_Set_of_Books_Id	number;
	P_SortBy	varchar2(100);
	P_Start_Account_Status	varchar2(30);
	P_End_Account_Status	varchar2(30);
	P_Start_Customer_Name	varchar2(50);
	P_End_Customer_Name	varchar2(50);
	P_MIN_PRECISION	number;
	P_conc_request_id	number;
	P_Start_Customer_Number	varchar2(30);
	P_END_CUSTOMER_NUMBER	varchar2(30);
--	lp_start_customer_name	varchar2(200);
--	lp_end_customer_name	varchar2(200);
--	lp_start_customer_number	varchar2(200);
--	lp_end_customer_number	varchar2(200);
--	lp_start_account_status	varchar2(200);
--	lp_end_account_status	varchar2(200);
	lp_start_customer_name	varchar2(200):= ' ';
	lp_end_customer_name	varchar2(200):= ' ';
	lp_start_customer_number	varchar2(200):= ' ';
	lp_end_customer_number	varchar2(200):= ' ';
	lp_start_account_status	varchar2(200):= ' ';
	lp_end_account_status	varchar2(200):= ' ';

	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(240);
	RP_DATA_FOUND	varchar2(100);
	--Ref_Curr_Code	varchar2(5) := := 'USD' ;
	Ref_Curr_Code	varchar2(5) :=  'USD' ;
	GSum_Amt_Due_Remaining_Dsp	varchar2(18);
	GSum_Provision_Dsp	varchar2(18);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function Ref_Curr_Code_p return varchar2;
	Function GSum_Amt_Due_Remaining_Dsp_p return varchar2;
	Function GSum_Provision_Dsp_p return varchar2;
function D_Amount_Due_OriginalFormula(Amount_Due_Original in number) return VARCHAR2;
END AR_ARXBDP_XMLP_PKG;


/
