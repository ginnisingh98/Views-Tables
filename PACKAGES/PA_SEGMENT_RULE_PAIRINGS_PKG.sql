--------------------------------------------------------
--  DDL for Package PA_SEGMENT_RULE_PAIRINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SEGMENT_RULE_PAIRINGS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXAAASS.pls 120.3 2005/08/03 10:27:26 aaggarwa noship $ */

  PROCEDURE Insert_Row(X_Rowid            IN OUT NOCOPY VARCHAR2,
                       X_Application_Id                 NUMBER,
                       X_Function_Code                  VARCHAR2,
                       X_Function_Transaction_Code      VARCHAR2,
                       X_Id_Flex_Code                   VARCHAR2,
                       X_Id_Flex_Num                    NUMBER,
                       X_Segment_Num                    NUMBER,
                       X_Rule_Id                        NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Display_Flag                   VARCHAR2,
                       P_Org_Id                         NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Application_Id                   NUMBER,
                     X_Function_Code                    VARCHAR2,
                     X_Function_Transaction_Code        VARCHAR2,
                     X_Id_Flex_Code                     VARCHAR2,
                     X_Id_Flex_Num                      NUMBER,
                     X_Segment_Num                      NUMBER,
                     X_Rule_Id                          NUMBER,
                     X_Display_Flag                     VARCHAR2
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Application_Id                 NUMBER,
                       X_Function_Code                  VARCHAR2,
                       X_Function_Transaction_Code      VARCHAR2,
                       X_Id_Flex_Code                   VARCHAR2,
                       X_Id_Flex_Num                    NUMBER,
                       X_Segment_Num                    NUMBER,
                       X_Rule_Id                        NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Display_Flag                   VARCHAR2
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PA_SEGMENT_RULE_PAIRINGS_PKG;
 

/
