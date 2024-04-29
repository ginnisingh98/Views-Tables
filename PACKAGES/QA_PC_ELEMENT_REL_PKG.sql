--------------------------------------------------------
--  DDL for Package QA_PC_ELEMENT_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_PC_ELEMENT_REL_PKG" AUTHID CURRENT_USER as
/* $Header: qapceles.pls 120.2 2005/12/19 04:02:43 srhariha noship $ */
 PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Element_Relationship_Id        IN OUT NOCOPY NUMBER,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Parent_Char_id                 NUMBER,
                       X_Child_Char_id                  NUMBER,
                       X_Element_Relationship_Type      NUMBER,
                       X_Link_Flag                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

 PROCEDURE Lock_Row(   X_Rowid                          VARCHAR2,
                       X_Element_Relationship_Id        NUMBER,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Parent_Char_id                 NUMBER,
                       X_Child_Char_id                  NUMBER,
                       X_Element_Relationship_Type      NUMBER,
                       X_Link_Flag                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER
                      );

 PROCEDURE Update_Row (X_Rowid                          VARCHAR2,
                       X_Element_Relationship_Id        NUMBER,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Parent_Char_id                 NUMBER,
                       X_Child_Char_id                  NUMBER,
                       X_Element_Relationship_Type      NUMBER,
                       X_Link_Flag                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
                      );
 PROCEDURE Delete_Row(X_Rowid VARCHAR2);


END QA_PC_ELEMENT_REL_PKG;

 

/
