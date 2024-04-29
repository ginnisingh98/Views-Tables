--------------------------------------------------------
--  DDL for Package IGI_BUD_JOURNAL_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_BUD_JOURNAL_BATCHES_PKG" AUTHID CURRENT_USER as
-- $Header: igibudgs.pls 120.4 2007/09/12 10:33:45 pshivara ship $


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Be_Batch_Id                    IN OUT NOCOPY NUMBER,
                       X_Fiscal_Year                    NUMBER,
                       X_Name                           VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Record_Type                    VARCHAR2,
                       X_Complete_Flag                  VARCHAR2,
                       X_Control_Total                  NUMBER,
                       X_Running_Total_Dr               NUMBER,
                       X_Running_Total_Cr               NUMBER,
                       X_Date_Completed                 DATE,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Be_Batch_Id                      NUMBER,
                     X_Fiscal_Year                      NUMBER,
                     X_Name                             VARCHAR2,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Record_Type                      VARCHAR2,
                     X_Complete_Flag                    VARCHAR2,
                     X_Control_Total                    NUMBER,
                     X_Running_Total_Dr                 NUMBER,
                     X_Running_Total_Cr                 NUMBER,
                     X_Date_Completed                   DATE
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Be_Batch_Id                    NUMBER,
                       X_Fiscal_Year                    NUMBER,
                       X_Name                           VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Record_Type                    VARCHAR2,
                       X_Complete_Flag                  VARCHAR2,
                       X_Control_Total                  NUMBER,
                       X_Running_Total_Dr               NUMBER,
                       X_Running_Total_Cr               NUMBER,
                       X_Date_Completed                 DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_REQUEST_ID                     NUMBER         -- bug 5982297
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                       X_Be_Batch_Id NUMBER);

END IGI_BUD_JOURNAL_BATCHES_PKG;

/
