--------------------------------------------------------
--  DDL for Package IGI_SAP_DEPT_APPROVERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_SAP_DEPT_APPROVERS_PKG" AUTHID CURRENT_USER as
-- $Header: igisiacs.pls 120.3.12000000.1 2007/09/12 11:47:29 mbremkum ship $
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Group_Id                       NUMBER,
                       X_Approver_Id                    NUMBER,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Group_Id                         NUMBER,
                     X_Approver_Id                      NUMBER,
                     X_Start_Date_Active                DATE,
                     X_End_Date_Active                  DATE
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Group_Id                       NUMBER,
                       X_Approver_Id                    NUMBER,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END IGI_SAP_DEPT_APPROVERS_PKG;

 

/
