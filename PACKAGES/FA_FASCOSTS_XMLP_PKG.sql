--------------------------------------------------------
--  DDL for Package FA_FASCOSTS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASCOSTS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASCOSTSS.pls 120.0.12010000.1 2008/07/28 13:16:37 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	P_REPORT_TYPE	varchar2(30);
	P_ADJ_MODE	varchar2(32767);
	lp_fa_book_controls	varchar2(50);
	lp_currency_code	varchar2(15);
	p_ca_org_id	number;
	p_ca_set_of_books_id	number;
	p_mrcsobtype	varchar2(10):='P';
	ACCT_BAL_APROMPT	varchar2(222);
	ACCT_CC_APROMPT	varchar2(222);
	CAT_MAJ_RPROMPT	varchar2(222);
	Period1_POD	date;
	Period1_PCD	date;
	Period1_FY	number;
	Period2_POD	date;
	Period2_PCD	date;
	Period2_FY	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(222);
	RP_CTR_APROMPT	varchar2(222);
	PERIOD_FROM	varchar2(20);
	PERIOD_TO	varchar2(20);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function Period1_PCFormula return Number  ;
	function Period2_PCFormula return Number  ;
	function DO_INSERTFormula return Number  ;
	--function out_of_balanceformula(BEGIN in number, ADDITION in number, REVALUATION in number, RECLASS in number, RETIREMENT in number, ADJUSTMENT in number, TRANSFER in number, CAPITALIZATION in number, END in number) return varchar2  ;
	function out_of_balanceformula(BEGIN_P in number, ADDITION in number, REVALUATION in number, RECLASS in number, RETIREMENT in number, ADJUSTMENT in number, TRANSFER in number, CAPITALIZATION in number, END_P in number) return varchar2  ;
	function acct_out_of_balanceformula(ACCT_BEGIN in number, ACCT_ADD in number, ACCT_REVAL in number, ACCT_RECLASS in number, ACCT_RETIRE in number, ACCT_ADJUST in number, ACCT_TRANS in number, ACCT_CAPITAL in number, ACCT_END in number)
	return varchar2  ;
	function bal_out_of_balanceformula(BAL_BEGIN in number, BAL_ADD in number, BAL_REVAL in number, BAL_RECLASS in number, BAL_RETIRE in number, BAL_ADJUST in number, BAL_TRANS in number, BAL_CAPITAL in number, BAL_END in number) return varchar2  ;
	function rp_out_of_balanceformula(RP_BEGIN in number, RP_ADD in number, RP_REVAL in number, RP_RECLASS in number, RP_RETIRE in number, RP_ADJUST in number, RP_TRANS in number, RP_CAPITAL in number, RP_END in number) return varchar2  ;
	function caprevalformula(REVALUATION in number, CAPITALIZATION in number) return number  ;
	function AfterPForm return boolean  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function CAT_MAJ_RPROMPT_p return varchar2;
	Function Period1_POD_p return date;
	Function Period1_PCD_p return date;
	Function Period1_FY_p return number;
	Function Period2_POD_p return date;
	Function Period2_PCD_p return date;
	Function Period2_FY_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_BAL_LPROMPT_p(ACCT_BAL_LPROMPT VARCHAR2) return varchar2;
		--Function RP_BAL_LPROMPT_p return varchar2;
	Function RP_CTR_APROMPT_p return varchar2;
	Function PERIOD_FROM_p return varchar2;
	Function PERIOD_TO_p return varchar2;
	--added during pls fixes
	procedure Get_Adjustments
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period1_PC	in	number,
    Period2_PC	in	number,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2);

    PROCEDURE get_adjustments_for_group
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period1_PC	in	number,
    Period2_PC	in	number,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2);

    procedure Get_Balance
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period_PC	in	number,
    Earliest_PC	in	number,
    Period_Date	in	date,
    Additions_Date in	date,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2,
    Begin_or_End in	varchar2);

    procedure get_balance_group_begin
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period_PC	in	number,
    Earliest_PC	in	number,
    Period_Date	in	date,
    Additions_Date in	date,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2,
    Begin_or_End in	varchar2);

  procedure get_balance_group_end
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period_PC	in	number,
    Earliest_PC	in	number,
    Period_Date	in	date,
    Additions_Date in	date,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2,
    Begin_or_End in	varchar2);

    procedure Get_Deprn_Effects
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period1_PC	in	number,
    Period2_PC	in	number,
    Report_Type	in	varchar2);

    procedure Insert_Info
   (Book		in	varchar2,
    Start_Period_Name	in	varchar2,
    End_Period_Name	in	varchar2,
    Report_Type		in	varchar2,
    Adj_Mode		in	varchar2);

     Function LP_FA_BOOK_CONTROLS_P return varchar2 ;


END FA_FASCOSTS_XMLP_PKG;



/
