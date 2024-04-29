--------------------------------------------------------
--  DDL for Package IGI_BUD_JOURNAL_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_BUD_JOURNAL_LINES_PKG" AUTHID CURRENT_USER as
-- $Header: igibudes.pls 120.3 2005/10/30 05:51:43 appldev ship $

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Be_Batch_Id                    NUMBER,
                       X_Be_Header_Id                   NUMBER,
                       X_Be_Line_Num                    NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Record_Type                    VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Next_Year_Budget               NUMBER,
                       X_Description                    VARCHAR2,
                       X_Fye_Pye_Entry                  VARCHAR2,
                       X_Profile_Code                   VARCHAR2,
                       X_Start_Period                   VARCHAR2,
                       X_Reason_Code                    VARCHAR2,
                       X_Recurring_Entry                VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Be_Batch_Id                      NUMBER,
                     X_Be_Header_Id                     NUMBER,
                     X_Be_Line_Num                      NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Code_Combination_Id              NUMBER,
                     X_Record_Type                      VARCHAR2,
                     X_Entered_Dr                       NUMBER,
                     X_Entered_Cr                       NUMBER,
                     X_Next_Year_Budget                 NUMBER,
                     X_Description                      VARCHAR2,
                     X_Fye_Pye_Entry                    VARCHAR2,
                     X_Profile_Code                     VARCHAR2,
                     X_Start_Period                     VARCHAR2,
                     X_Reason_Code                      VARCHAR2,
                     X_Recurring_Entry                  VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Be_Batch_Id                    NUMBER,
                       X_Be_Header_Id                   NUMBER,
                       X_Be_Line_Num                    NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Record_Type                    VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Next_Year_Budget               NUMBER,
                       X_Description                    VARCHAR2,
                       X_Fye_Pye_Entry                  VARCHAR2,
                       X_Profile_Code                   VARCHAR2,
                       X_Start_Period                   VARCHAR2,
                       X_Reason_Code                    VARCHAR2,
                       X_Recurring_Entry                VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid        VARCHAR2,
                       X_Be_Header_Id NUMBER,
                       X_Be_Line_Num  NUMBER);

END IGI_BUD_JOURNAL_LINES_PKG;

/
