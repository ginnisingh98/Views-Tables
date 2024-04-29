--------------------------------------------------------
--  DDL for Package IGI_ITR_APPROVAL_LINES_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR_APPROVAL_LINES_SS_PKG" AUTHID CURRENT_USER as
-- $Header: igiitrms.pls 120.2.12000000.1 2007/09/12 10:31:59 mbremkum ship $
--

  PROCEDURE Lock_Row(X_Rowid                      VARCHAR2,
                     X_It_Service_Line_Id         NUMBER,
                     X_Status_Flag                VARCHAR2,
                     X_Rejection_Note             VARCHAR2,
                     X_Suggested_Amount           NUMBER,
                     X_Suggested_Recv_Ccid        NUMBER
                    );
  PROCEDURE Update_Row(X_Rowid                      VARCHAR2,
                       X_Status_Flag                VARCHAR2,
                       X_Rejection_Note             VARCHAR2,
                       X_Suggested_Amount           NUMBER,
                       X_Suggested_Recv_Ccid        NUMBER,
                       X_Last_Update_Login          NUMBER,
                       X_Last_Updated_By            NUMBER,
                       X_Last_Update_Date           DATE
                      );

END IGI_ITR_APPROVAL_LINES_SS_PKG;

 

/
