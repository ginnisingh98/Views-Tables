--------------------------------------------------------
--  DDL for Package PAY_US_GARN_FEE_RULES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_GARN_FEE_RULES_F_PKG" AUTHID CURRENT_USER as
/* $Header: pygfr01t.pkh 115.1.1150.1 2000/02/10 15:53:40 pkm ship     $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Fee_Rule_Id                    IN OUT NUMBER,
                       X_Effective_Start_Date           DATE,
                       X_Effective_End_Date             DATE,
                       X_Garn_Category                  VARCHAR2,
                       X_State_Code                     VARCHAR2,
                       X_Addl_Garn_Fee_Amount           NUMBER,
                       X_Correspondence_Fee             NUMBER,
                       X_Creator_Type                   VARCHAR2,
                       X_Fee_Amount                     NUMBER,
                       X_Fee_Rule                       VARCHAR2,
                       X_Max_Fee_Amount                 NUMBER,
                       X_Pct_Current                    NUMBER,
							  X_Take_Fee_On_Proration          VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Fee_Rule_Id                      NUMBER,
                     X_Effective_Start_Date             DATE,
                     X_Effective_End_Date               DATE,
                     X_Garn_Category                    VARCHAR2,
                     X_State_Code                       VARCHAR2,
                     X_Addl_Garn_Fee_Amount             NUMBER,
                     X_Correspondence_Fee               NUMBER,
                     X_Creator_Type                     VARCHAR2,
                     X_Fee_Amount                       NUMBER,
                     X_Fee_Rule                         VARCHAR2,
                     X_Max_Fee_Amount                   NUMBER,
                     X_Pct_Current                      NUMBER,
							X_Take_Fee_On_Proration            VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Fee_Rule_Id                    NUMBER,
                       X_Effective_Start_Date           DATE,
                       X_Effective_End_Date             DATE,
                       X_Garn_Category                  VARCHAR2,
                       X_State_Code                     VARCHAR2,
                       X_Addl_Garn_Fee_Amount           NUMBER,
                       X_Correspondence_Fee             NUMBER,
                       X_Creator_Type                   VARCHAR2,
                       X_Fee_Amount                     NUMBER,
                       X_Fee_Rule                       VARCHAR2,
                       X_Max_Fee_Amount                 NUMBER,
                       X_Pct_Current                    NUMBER,
							  X_Take_Fee_On_Proration          VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  PROCEDURE Check_Unique( X_State_Code                     VARCHAR2,
                          X_Garn_Category                  VARCHAR2);


END PAY_US_GARN_FEE_RULES_F_PKG;

 

/
