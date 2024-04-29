--------------------------------------------------------
--  DDL for Package JE_AWT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_AWT_PKG" AUTHID CURRENT_USER as
/* $Header: jezzawts.pls 115.0 99/10/14 13:52:40 porting ship $ */

function Get_Rate_Id (
                       P_Tax_Name    IN varchar2
                      ,P_Invoice_Id  IN number
                      ,P_Payment_Num IN number
                      ,P_Awt_Date    IN date
                      ,P_Amount      IN number
                      )
                      return number;

procedure AWT_Rounding (P_Checkrun_Name IN varchar2);

end JE_AWT_PKG;

 

/
