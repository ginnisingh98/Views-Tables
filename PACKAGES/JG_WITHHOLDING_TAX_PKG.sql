--------------------------------------------------------
--  DDL for Package JG_WITHHOLDING_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_WITHHOLDING_TAX_PKG" AUTHID CURRENT_USER as
/* $Header: jgzzawts.pls 120.1.12010000.1 2008/07/28 07:56:42 appldev ship $ */

FUNCTION Get_Rate_Id
                (
                 P_Tax_Name    	IN varchar2
                ,P_Invoice_Id  	IN number
                ,P_Payment_Num 	IN number
                ,P_Awt_Date    	IN date
                ,P_Amount      	IN number
                )
               return number;


PROCEDURE AWT_Rounding
                (
	       	 P_Checkrun_Name IN varchar2
                );

/**************************************************************
  Procedure JG_Special_Rounding
  Objective: Make special rounding for the Withheld Amount
             and Check a minimum withheld amount.
  Countries: Korea. (So far)
 **************************************************************/

PROCEDURE JG_Special_Withheld_Amt
                (
                 P_Withheld_Amount        IN OUT NOCOPY Number
                ,P_Base_WT_amount         IN OUT NOCOPY Number
                ,P_CurrCode               IN Varchar2
                ,P_BaseCurrCode           IN Varchar2
                ,P_Invoice_exchange_rate  IN Number
                ,P_Tax_Name               IN Varchar2
                ,P_Calling_sequence       IN Varchar2
                 );

END JG_WITHHOLDING_TAX_PKG;

/
