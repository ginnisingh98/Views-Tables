--------------------------------------------------------
--  DDL for Package AR_ARXFXGL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXFXGL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXFXGLS.pls 120.0 2007/12/27 13:51:42 abraghun noship $ */
	P_Customer_Id	number;
	P_Site_Use_Id	number;
	P_From_Receipt_Date	date;
	P_To_Receipt_Date	date;
	P_Receipt_Currency	varchar2(15);
	P_Rate_Type	varchar2(30);
	P_Conc_Request_Id	number;
	P_Set_Of_Books_Id	number;
	P_Customer_Number	varchar2(30);
	P_Customer_Name	varchar2(50);
	Where_Customer	varchar2(60) :=  'AND 1 = 1' ;
	P_Location	varchar2(40);
	Where_Location	varchar2(60) :=  'AND 1 = 1' ;
	Where_Date	varchar2(85) :=  'AND 1 = 1' ;
	Where_Currency	varchar2(60) :=  'AND 1 = 1' ;
	P_Exchange_Rate_Type	varchar2(30);
	Report_Name	varchar2(2000);
	Functional_Currency	varchar2(15);
	Set_Of_Books_Name	varchar2(30);
	Functional_Precision	number;
	function BeforeReport return boolean  ;
	PROCEDURE Build_Customer_Details  ;
	PROCEDURE Build_Location_Details  ;
	PROCEDURE Build_Rate_Type_Details  ;
	PROCEDURE BUILD_RECEIPT_DATE_DETAILS  ;
	PROCEDURE BUILD_CURRENCY_DETAILS  ;
	function cf_gain_loss_actualfo(Actual_Alloc_Receipt_Amt_Base in number, Trx_Amt_Applied_Base in number) return number  ;
	--function allocated_amount_rateformula(Rate_Sys_Curr_Rate in number) return number  ;
	function allocated_amount_rateformula(Trx_Amt_Applied IN NUMBER,Receipt_Precision IN NUMBER,Rate_Sys_Curr_Rate in number) return number;
	--function Sys_Cross_CurrencyFormula return Number  ;
	function Sys_Cross_CurrencyFormula(Trx_Currency IN VARCHAR2,Receipt_Currency IN VARCHAR2,Receipt_Date IN DATE) return Number;
	--function rate_alloc_receipt_amt_basefor(Rate_Sys_Curr_Rate in number) return number  ;
	function rate_alloc_receipt_amt_basefor(Rate_Sys_Curr_Rate in number,Rate_Alloc_Receipt_Amt IN NUMBER,Receipt_Exchange_Rate IN NUMBER) return number;
	function rate_gain_lossformula(Rate_Alloc_Receipt_Amt_Base in number, Trx_Amt_Applied_Base in number) return number  ;
	function absolute_differenceformula(Actual_Gain_Loss in number, Rate_Gain_Loss in number) return number  ;
	function actual_gainformula(Actual_Gain_Loss in number) return number  ;
	function actual_rate_lossformula(Actual_Gain_Loss in number) return number  ;
	function rate_gainformula(Rate_Gain_Loss in number) return number  ;
	function rate_lossformula(Rate_Gain_Loss in number) return number  ;
	PROCEDURE Get_Report_Name  ;
	PROCEDURE Get_SOB_Details  ;
	function rate_sys_curr_rate_dformula(Rate_Sys_Curr_Rate in number) return number  ;
	function actual_cross_curr_rate_dformul(Actual_Cross_Curr_Rate in number) return number  ;
	function AfterReport return boolean  ;
	Function P_Customer_Number_p return varchar2;
	Function P_Customer_Name_p return varchar2;
	Function Where_Customer_p return varchar2;
	Function P_Location_p return varchar2;
	Function Where_Location_p return varchar2;
	Function Where_Date_p return varchar2;
	Function Where_Currency_p return varchar2;
	Function P_Exchange_Rate_Type_p return varchar2;
	Function Report_Name_p return varchar2;
	Function Functional_Currency_p return varchar2;
	Function Set_Of_Books_Name_p return varchar2;
	Function Functional_Precision_p return number;
END AR_ARXFXGL_XMLP_PKG;


/
