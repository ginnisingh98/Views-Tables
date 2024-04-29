--------------------------------------------------------
--  DDL for Package JL_AWT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_AWT_PKG" AUTHID CURRENT_USER as
/* $Header: jlzzawts.pls 115.0 99/10/14 16:13:05 porting ship   $ */

function Get_Rate_Id (
                       P_Tax_Name    IN varchar2
                      ,P_Invoice_Id  IN number
                      ,P_Payment_Num IN number
                      ,P_Awt_Date    IN date
                      ,P_Amount      IN number
                      )
                      return number;

procedure AWT_Rounding (P_Checkrun_Name IN varchar2);

end JL_AWT_PKG;

 

/
