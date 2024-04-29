--------------------------------------------------------
--  DDL for Package QA_PC_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_PC_CRITERIA_PKG" AUTHID CURRENT_USER as
/* $Header: qapccris.pls 120.2 2005/12/19 04:08:30 srhariha noship $ */
  PROCEDURE Insert_Row( X_Rowid                 IN OUT  NOCOPY VARCHAR2,
                       X_Criteria_Id            IN OUT  NOCOPY NUMBER,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Char_Id                        NUMBER,
                       X_Operator                       NUMBER,
                       X_Low_Value                      VARCHAR2,
                       X_Low_Value_Id                   NUMBER,
                       X_High_Value                     VARCHAR2,
                       X_High_Value_Id                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
                       );

  PROCEDURE Lock_Row( X_Rowid                           VARCHAR2,
                       X_Criteria_Id                    NUMBER,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Char_Id                        NUMBER,
                       X_Operator                       NUMBER,
                       X_Low_Value                      VARCHAR2,
                       X_Low_Value_Id                   NUMBER,
                       X_High_Value                     VARCHAR2,
                       X_High_Value_Id                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER
                      );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Criteria_Id                    NUMBER,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Char_Id                        NUMBER,
                       X_Operator                       NUMBER,
                       X_Low_Value                      VARCHAR2,
                       X_Low_Value_Id                   NUMBER,
                       X_High_Value                     VARCHAR2,
                       X_High_Value_Id                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
                       );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);
END QA_PC_CRITERIA_PKG;

 

/
