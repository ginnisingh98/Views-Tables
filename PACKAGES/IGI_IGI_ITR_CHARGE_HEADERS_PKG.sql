--------------------------------------------------------
--  DDL for Package IGI_IGI_ITR_CHARGE_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGI_ITR_CHARGE_HEADERS_PKG" AUTHID CURRENT_USER as
-- $Header: igiitras.pls 120.3.12000000.1 2007/09/12 10:30:22 mbremkum ship $
--

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_It_Header_Id                   IN OUT NOCOPY NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Name                           VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_It_Period_Name                 VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Submit_Flag                    VARCHAR2,
                       X_It_Originator_Id               VARCHAR2,
                       X_It_Category                    VARCHAR2,
                       X_It_Source                      VARCHAR2,
                       X_Gl_Date                        DATE,
                       X_Submit_Date                    DATE,
                       X_Currency_Code                  VARCHAR2,
                       X_Code_Combination_Id            NUMBER,
                       X_Encumbrance_Type_Id            NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_It_Header_Id                     NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Name                             VARCHAR2,
                     X_Description                      VARCHAR2,
                     X_It_Period_Name                   VARCHAR2,
                     X_Entered_Dr                       NUMBER,
                     X_Entered_Cr                       NUMBER,
                     X_Submit_Flag                      VARCHAR2,
                     X_It_Originator_Id                 VARCHAR2,
                     X_It_Category                      VARCHAR2,
                     X_It_Source                        VARCHAR2,
                     X_Gl_Date                          DATE,
                     X_Submit_Date                      DATE,
                     X_Currency_Code                    VARCHAR2,
                     X_Code_Combination_Id              NUMBER,
                     X_Encumbrance_Type_Id              NUMBER
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_It_Header_Id                   NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Name                           VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_It_Period_Name                 VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Submit_Flag                    VARCHAR2,
                       X_It_Originator_Id               VARCHAR2,
                       X_It_Category                    VARCHAR2,
                       X_It_Source                      VARCHAR2,
                       X_Gl_Date                        DATE,
                       X_Submit_Date                    DATE,
                       X_Currency_Code                  VARCHAR2,
                       X_Code_Combination_Id            NUMBER,
                       X_Encumbrance_Type_Id            NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END IGI_IGI_ITR_CHARGE_HEADERS_PKG;

 

/
