--------------------------------------------------------
--  DDL for Package IGI_AP_INVOICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_AP_INVOICE_PKG" AUTHID CURRENT_USER as
-- $Header: igisiafs.pls 120.2.12000000.1 2007/09/12 11:47:50 mbremkum ship $

PROCEDURE Lock_Row
                (X_Rowid                VARCHAR2
                ,X_Invoice_id           NUMBER
                );
PROCEDURE Update_Row
                (X_Rowid                VARCHAR2
                ,X_igi_sap_flag       VARCHAR2
                ,X_Last_Update_Login    NUMBER
                ,X_Last_Update_Date     DATE
                ,X_Last_Updated_By      NUMBER
                );
END IGI_AP_INVOICE_PKG;
 

/
