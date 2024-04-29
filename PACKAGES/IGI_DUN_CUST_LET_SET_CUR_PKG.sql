--------------------------------------------------------
--  DDL for Package IGI_DUN_CUST_LET_SET_CUR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DUN_CUST_LET_SET_CUR_PKG" AUTHID CURRENT_USER as
  -- $Header: igidunks.pls 115.5 2002/11/18 05:03:13 sowsubra ship $

     PROCEDURE Insert_Row(X_Rowid               IN OUT NOCOPY VARCHAR2,
        X_Customer_Profile_Id                NUMBER,
        X_Currency_Code                      VARCHAR2,
        X_Created_By                         NUMBER,
        X_Creation_Date                      DATE,
        X_Last_Updated_By                    NUMBER,
        X_Last_Update_Date                   DATE,
        X_Last_Update_Login                  NUMBER DEFAULT NULL
                   );

     PROCEDURE Lock_Row(X_Rowid                    VARCHAR2,
        X_Customer_Profile_Id                NUMBER,
        X_Currency_Code                      VARCHAR2
                              );

     PROCEDURE Update_Row(X_Rowid                   VARCHAR2,
        X_Customer_Profile_Id                NUMBER,
        X_Currency_Code                      VARCHAR2,
        X_Last_Updated_By                    NUMBER,
        X_Last_Update_Date                   DATE,
        X_Last_Update_Login                  NUMBER DEFAULT NULL
                                 );

   PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  END IGI_DUN_CUST_LET_SET_CUR_PKG;

 

/
