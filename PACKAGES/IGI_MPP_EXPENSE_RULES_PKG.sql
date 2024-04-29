--------------------------------------------------------
--  DDL for Package IGI_MPP_EXPENSE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_MPP_EXPENSE_RULES_PKG" AUTHID CURRENT_USER as
 /* $Header: igipmers.pls 115.6 2002/11/18 13:24:08 panaraya ship $ */

     PROCEDURE Lock_Row(X_Rowid              VARCHAR2,
        X_Expense_Ccid                       NUMBER,
        X_Default_Accounting_Rule_Id         NUMBER,
        X_Enabled_Flag                       VARCHAR2,
        X_Org_Id                             NUMBER,
        X_Set_Of_Books_Id                    NUMBER
                              );


     PROCEDURE Update_Row(X_Rowid            VARCHAR2,
        X_Expense_Ccid                       NUMBER,
        X_Default_Accounting_Rule_Id         NUMBER,
        X_Enabled_Flag                       VARCHAR2,
        X_Last_Updated_By                    NUMBER,
        X_Last_Update_Date                   DATE,
        X_Last_Update_Login                  NUMBER DEFAULT NULL

                                 );


     PROCEDURE Insert_Row(X_Rowid      IN OUT NOCOPY      VARCHAR2,
        X_Expense_Ccid                       NUMBER,
        X_Default_Accounting_Rule_Id         NUMBER,
        X_Enabled_Flag                       VARCHAR2,
        X_Org_Id                             NUMBER,
        X_Set_Of_Books_Id                    NUMBER,
        X_Created_By                         NUMBER,
        X_Creation_Date                      DATE,
        X_Last_Updated_By                    NUMBER,
        X_Last_Update_Date                   DATE,
        X_Last_Update_Login                  NUMBER DEFAULT NULL

                          );


     PROCEDURE  Delete_Row(X_Rowid           VARCHAR2);



  END IGI_MPP_EXPENSE_RULES_PKG;

 

/
