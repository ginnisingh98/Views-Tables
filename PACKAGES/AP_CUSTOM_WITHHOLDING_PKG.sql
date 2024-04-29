--------------------------------------------------------
--  DDL for Package AP_CUSTOM_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CUSTOM_WITHHOLDING_PKG" AUTHID CURRENT_USER as
/* $Header: apcmawts.pls 120.2 2004/10/27 01:29:31 pjena noship $ */
                                                                          --
function Ap_Special_Rate (
                          P_Tax_Name    IN varchar2
                         ,P_Invoice_Id  IN number
                         ,P_Payment_Num IN number
                         ,P_Awt_Date    IN date
                         ,P_Amount      IN number
                         )
                         return number;
                                                                          --
procedure Ap_Special_Rounding (P_Checkrun_Name IN varchar2);

/*****************************************************************
 Procedure: Ap_Spcial_Withheld_Amt
 Objective: This procedure enable globalization to make some
            adjusments in the withheld amount, for example
            rounding.  This procedure is called from
            AP_CALC_WITHHOLDING_PKG.Insert_Temp_Distribution
 ******************************************************************/

procedure Ap_Special_Withheld_Amt
                (
                 P_Withheld_Amount        IN OUT NOCOPY Number
                ,P_Base_WT_amount         IN OUT NOCOPY Number
                ,P_CurrCode               IN Varchar2
                ,P_BaseCurrCode           IN Varchar2
                ,P_Invoice_exchange_rate  IN Number
                ,P_Tax_Name               IN Varchar2
                ,P_Calling_sequence       IN Varchar2
                 );


end AP_CUSTOM_WITHHOLDING_PKG;

 

/
