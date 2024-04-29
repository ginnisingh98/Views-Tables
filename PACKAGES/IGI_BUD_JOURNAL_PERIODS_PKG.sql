--------------------------------------------------------
--  DDL for Package IGI_BUD_JOURNAL_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_BUD_JOURNAL_PERIODS_PKG" AUTHID CURRENT_USER as
-- $Header: igibudds.pls 120.3 2005/10/30 05:51:40 appldev ship $


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Be_Batch_Id                    NUMBER,
                       X_Be_Header_Id                   NUMBER,
                       X_Be_Line_Num                    NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Period_Number                  NUMBER,
                       X_Period_Year                    NUMBER,
                       X_Record_Type                    VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Next_Year_Budget               NUMBER,
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
                     X_Period_Name                      VARCHAR2,
                     X_Period_Number                    NUMBER,
                     X_Period_Year                      NUMBER,
                     X_Record_Type                      VARCHAR2,
                     X_Entered_Dr                       NUMBER,
                     X_Entered_Cr                       NUMBER,
                     X_Next_Year_Budget                 NUMBER
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Be_Batch_Id                    NUMBER,
                       X_Be_Header_Id                   NUMBER,
                       X_Be_Line_Num                    NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Period_Number                  NUMBER,
                       X_Period_Year                    NUMBER,
                       X_Record_Type                    VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Next_Year_Budget               NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END IGI_BUD_JOURNAL_PERIODS_PKG;

/
