--------------------------------------------------------
--  DDL for Package IGI_AP_INV_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_AP_INV_LINES_PKG" AUTHID CURRENT_USER as
-- $Header: igisials.pls 120.0.12000000.1 2007/09/12 11:48:01 mbremkum noship $
PROCEDURE Lock_Row
                (X_Rowid                VARCHAR2
                ,X_igi_sap_flag       VARCHAR2
                );
PROCEDURE Update_Row
                (X_Rowid                VARCHAR2
                ,X_igi_sap_flag       VARCHAR2
                ,X_Last_Update_Login    NUMBER
                ,X_Last_Update_Date     DATE
                ,X_Last_Updated_By      NUMBER
                );
END IGI_AP_INV_LINES_PKG;

 

/
