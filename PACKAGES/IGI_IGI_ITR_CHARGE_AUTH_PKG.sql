--------------------------------------------------------
--  DDL for Package IGI_IGI_ITR_CHARGE_AUTH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGI_ITR_CHARGE_AUTH_PKG" AUTHID CURRENT_USER as
-- $Header: igiitrds.pls 120.3.12000000.1 2007/09/12 10:30:45 mbremkum ship $
--
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Charge_Center_Id               NUMBER,
                       X_User_Id                        NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Charge_Center_Id                 NUMBER,
                     X_User_Id                          NUMBER
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Charge_Center_Id               NUMBER,
                       X_User_Id                        NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END IGI_IGI_ITR_CHARGE_AUTH_PKG;

 

/
