--------------------------------------------------------
--  DDL for Package IGI_MPP_AP_INVOICE_DISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_MPP_AP_INVOICE_DISTS_PKG" AUTHID CURRENT_USER as
 /* $Header: igipmuds.pls 115.6 2002/09/09 09:55:01 lsilveir ship $ */


     PROCEDURE Lock_Row(X_Rowid              VARCHAR2,
        X_Distribution_Line_Number           NUMBER,
        X_Invoice_Id                         NUMBER,
        X_Ignore_Mpp_Flag                    VARCHAR2,
        X_Accounting_Rule_Id                 VARCHAR2,
        X_Start_Date                         DATE,
        X_Duration                           NUMBER

                              );


     PROCEDURE Update_Row(X_Rowid            VARCHAR2,
        X_Distribution_Line_Number           NUMBER,
        X_Invoice_Id                         NUMBER,
        X_Ignore_Mpp_Flag                    VARCHAR2,
        X_Accounting_Rule_Id                 VARCHAR2,
        X_Start_Date                         DATE,
        X_Duration                           NUMBER,
        X_Last_Updated_By                    NUMBER,
        X_Last_Update_Date                   DATE,
        X_Last_Update_Login                  NUMBER DEFAULT NULL

                                 );
  END IGI_MPP_AP_INVOICE_DISTS_PKG;

 

/
