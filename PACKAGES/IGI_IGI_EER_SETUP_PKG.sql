--------------------------------------------------------
--  DDL for Package IGI_IGI_EER_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGI_EER_SETUP_PKG" AUTHID CURRENT_USER as
-- $Header: igihglas.pls 120.3.12000000.1 2007/09/12 10:11:43 mbremkum ship $
--
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Gl_Set_Of_Books_Id             NUMBER,
                       X_Level_1                        NUMBER,
                       X_Level_2                        NUMBER,
                       X_Level_3                        NUMBER,
                       X_Level_4                        NUMBER,
                       X_Level_5                        NUMBER,
                       X_Level_6                        NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Gl_Set_Of_Books_Id               NUMBER,
                     X_Level_1                          NUMBER,
                     X_Level_2                          NUMBER,
                     X_Level_3                          NUMBER,
                     X_Level_4                          NUMBER,
                     X_Level_5                          NUMBER,
                     X_Level_6                          NUMBER
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Gl_Set_Of_Books_Id             NUMBER,
                       X_Level_1                        NUMBER,
                       X_Level_2                        NUMBER,
                       X_Level_3                        NUMBER,
                       X_Level_4                        NUMBER,
                       X_Level_5                        NUMBER,
                       X_Level_6                        NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

END IGI_IGI_EER_SETUP_PKG;

 

/
