--------------------------------------------------------
--  DDL for Package IGI_BUD_PROFILE_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_BUD_PROFILE_PERIODS_PKG" AUTHID CURRENT_USER as
-- $Header: igibudcs.pls 120.3 2005/10/30 05:51:38 appldev ship $

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Profile_Code                   VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Period_Number                  NUMBER,
                       X_Period_Ratio                   NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Profile_Code                     VARCHAR2,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Period_Number                    NUMBER,
                     X_Period_Ratio                     NUMBER
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Profile_Code                   VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Period_Number                  NUMBER,
                       X_Period_Ratio                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid                          VARCHAR2);

END IGI_BUD_PROFILE_PERIODS_PKG;

/
