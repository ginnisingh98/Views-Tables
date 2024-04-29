--------------------------------------------------------
--  DDL for Package IGI_IGI_ITR_CHARGE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGI_ITR_CHARGE_LINES_PKG" AUTHID CURRENT_USER as
-- $Header: igiitrcs.pls 120.3.12000000.1 2007/09/12 10:30:38 mbremkum ship $
--

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_It_Header_Id                   NUMBER,
                       X_It_Line_Num                    NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Charge_Center_Id               NUMBER,
                       X_Effective_Date                 DATE,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Description                    VARCHAR2,
                       X_Status_Flag                    VARCHAR2,
                       X_Posting_Flag                   VARCHAR2,
                       X_Submit_Date                    DATE,
                       X_Suggested_Amount               NUMBER,
                       X_Rejection_Note                 VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_It_Header_Id                     NUMBER,
                     X_It_Line_Num                      NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Code_Combination_Id              NUMBER,
                     X_Charge_Center_Id                 NUMBER,
                     X_Entered_Dr                       NUMBER,
                     X_Entered_Cr                       NUMBER,
                     X_Description                      VARCHAR2,
                     X_Status_Flag                      VARCHAR2,
                     X_Posting_Flag                     VARCHAR2,
                     X_Suggested_Amount                 NUMBER,
                     X_Rejection_Note                   VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_It_Header_Id                   NUMBER,
                       X_It_Line_Num                    NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Charge_Center_Id               NUMBER,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Description                    VARCHAR2,
                       X_Status_Flag                    VARCHAR2,
                       X_Posting_Flag                   VARCHAR2,
                       X_Suggested_Amount               NUMBER,
                       X_Rejection_Note                 VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END IGI_IGI_ITR_CHARGE_LINES_PKG;

 

/
