--------------------------------------------------------
--  DDL for Package JE_IT_EXEMPT_LETTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_IT_EXEMPT_LETTERS_PKG" AUTHID CURRENT_USER as
/* $Header: jeitexls.pls 120.3 2006/02/24 16:08:29 pmaddula ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
		       X_Legal_Entity_Id		NUMBER,
                       X_Set_of_Books_Id                NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Effective_From                 DATE,
                       X_Effective_To                   DATE,
                       X_Year                           NUMBER,
                       X_Exemption_Letter_Id            NUMBER,
                       X_Print_Flag                     VARCHAR2,
                       X_Issue_Flag                     VARCHAR2,
                       X_Custom_Flag                    VARCHAR2,
                       X_Letter_Type                    VARCHAR2,
                       X_Limit_Amount                   NUMBER,
                       X_Clause_Ref                     VARCHAR2,
                       X_Issue_Date                     DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
	             X_Legal_Entity_Id			NUMBER,
        	     X_Set_of_Books_Id			NUMBER,
                     X_Vendor_Id                        NUMBER,
                     X_Effective_From                   DATE,
                     X_Effective_To                     DATE,
                     X_Year                             NUMBER,
                     X_Exemption_Letter_Id              NUMBER,
                     X_Print_Flag                       VARCHAR2,
                     X_Issue_Flag                       VARCHAR2,
                     X_Custom_Flag                      VARCHAR2,
                     X_Letter_Type                      VARCHAR2,
                     X_Limit_Amount                     NUMBER,
                     X_Clause_Ref                       VARCHAR2,
                     X_Issue_Date                       DATE,
		     X_Last_Update_Date                 DATE,
 		     X_Last_Updated_By                  NUMBER,
 		     X_Creation_Date                    DATE,
 		     X_Created_By                       NUMBER
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
	               X_Legal_Entity_Id		NUMBER,
        	       X_Set_of_Books_Id		NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Effective_From                 DATE,
                       X_Effective_To                   DATE,
                       X_Year                           NUMBER,
                       X_Exemption_Letter_Id            NUMBER,
                       X_Print_Flag                     VARCHAR2,
                       X_Issue_Flag                     VARCHAR2,
                       X_Custom_Flag                    VARCHAR2,
                       X_Letter_Type                    VARCHAR2,
                       X_Limit_Amount                   NUMBER,
                       X_Clause_Ref                     VARCHAR2,
                       X_Issue_Date                     DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER
                       );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END JE_IT_EXEMPT_LETTERS_PKG;

 

/
