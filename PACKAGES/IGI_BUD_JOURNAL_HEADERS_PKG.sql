--------------------------------------------------------
--  DDL for Package IGI_BUD_JOURNAL_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_BUD_JOURNAL_HEADERS_PKG" AUTHID CURRENT_USER as
-- $Header: igibudfs.pls 120.3 2005/10/30 05:57:46 appldev ship $

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Be_Batch_Id                    NUMBER,
                       X_Be_Header_Id                   IN OUT NOCOPY NUMBER,
                       X_Budget_Entity_Id               NUMBER,
                       X_Budget_Version_Id              NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Je_Category_Name               VARCHAR2,
                       X_Name                           VARCHAR2,
                       X_Running_Total_Dr               NUMBER,
                       X_Running_Total_Cr               NUMBER,
                       X_Autocopy_Flag                  VARCHAR2,
                       X_Control_Total                  NUMBER,
                       X_Default_Reason_Code            VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Be_Batch_Id                      NUMBER,
                     X_Be_Header_Id                     NUMBER,
                     X_Budget_Entity_Id                 NUMBER,
                     X_Budget_Version_Id                NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Currency_Code                    VARCHAR2,
                     X_Je_Category_Name                 VARCHAR2,
                     X_Name                             VARCHAR2,
                     X_Running_Total_Dr                 NUMBER,
                     X_Running_Total_Cr                 NUMBER,
                     X_Autocopy_Flag                    VARCHAR2,
                     X_Control_Total                    NUMBER,
                     X_Default_Reason_Code              VARCHAR2,
                     X_Description                      VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Be_Batch_Id                    NUMBER,
                       X_Be_Header_Id                   NUMBER,
                       X_Budget_Entity_Id               NUMBER,
                       X_Budget_Version_Id              NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Je_Category_Name               VARCHAR2,
                       X_Name                           VARCHAR2,
                       X_Running_Total_Dr               NUMBER,
                       X_Running_Total_Cr               NUMBER,
                       X_Autocopy_Flag                  VARCHAR2,
                       X_Control_Total                  NUMBER,
                       X_Default_Reason_Code            VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid         VARCHAR2,
                       X_Be_Header_Id  NUMBER);

END IGI_BUD_JOURNAL_HEADERS_PKG;

/
