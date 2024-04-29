--------------------------------------------------------
--  DDL for Package JA_AWT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_AWT_PKG" AUTHID CURRENT_USER as
/* $Header: jazzawts.pls 120.2 2005/10/30 01:48:09 appldev ship $ */

function Get_Rate_Id (
                       P_Tax_Name    IN varchar2
                      ,P_Invoice_Id  IN number
                      ,P_Payment_Num IN number
                      ,P_Awt_Date    IN date
                      ,P_Amount      IN number
                      )
                      return number;

procedure AWT_Rounding (P_Checkrun_Name IN varchar2);

end JA_AWT_PKG;

/
