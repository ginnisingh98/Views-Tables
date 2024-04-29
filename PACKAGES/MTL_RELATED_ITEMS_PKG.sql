--------------------------------------------------------
--  DDL for Package MTL_RELATED_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_RELATED_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: INVISDRS.pls 115.6 2004/01/19 19:21:45 anakas ship $ */

PROCEDURE Insert_Row (X_Rowid		IN OUT  NOCOPY  VARCHAR2,
                       X_Inventory_Item_Id              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Related_Item_Id                NUMBER,
                       X_Relationship_Type_Id           NUMBER,
                       X_Reciprocal_Flag                VARCHAR2,
                       X_Planning_Enabled_Flag          VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Attr_Context	                VARCHAR2,
                       X_Attr_Char1		       VARCHAR2,
                       X_Attr_Char2		       VARCHAR2,
                       X_Attr_Char3		       VARCHAR2,
                       X_Attr_Char4		       VARCHAR2,
                       X_Attr_Char5		       VARCHAR2,
                       X_Attr_Char6		       VARCHAR2,
                       X_Attr_Char7		       VARCHAR2,
                       X_Attr_Char8		       VARCHAR2,
                       X_Attr_Char9		       VARCHAR2,
                       X_Attr_Char10	               VARCHAR2,
                       X_Attr_Num1		       NUMBER,
                       X_Attr_Num2		       NUMBER,
                       X_Attr_Num3		       NUMBER,
                       X_Attr_Num4		       NUMBER,
                       X_Attr_Num5		       NUMBER,
                       X_Attr_Num6		       NUMBER,
                       X_Attr_Num7		       NUMBER,
                       X_Attr_Num8		       NUMBER,
                       X_Attr_Num9		       NUMBER,
                       X_Attr_Num10		       NUMBER,
                       X_Attr_Date1		       DATE,
                       X_Attr_Date2		       DATE,
                       X_Attr_Date3		       DATE,
                       X_Attr_Date4		       DATE,
                       X_Attr_Date5		       DATE,
                       X_Attr_Date6		       DATE,
                       X_Attr_Date7		       DATE,
                       X_Attr_Date8		       DATE,
                       X_Attr_Date9		       DATE,
                       X_Attr_Date10		       DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Object_Version_Number          NUMBER
                      );

PROCEDURE Lock_Row (X_Rowid                            VARCHAR2,
                     X_Inventory_Item_Id                NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Related_Item_Id                  NUMBER,
                     X_Relationship_Type_Id             NUMBER,
                     X_Reciprocal_Flag                  VARCHAR2,
                     X_Planning_Enabled_Flag            VARCHAR2,
                       X_Start_Date                      DATE,
                       X_End_Date                        DATE,
                       X_Attr_Context	               VARCHAR2,
                       X_Attr_Char1		       VARCHAR2,
                       X_Attr_Char2		       VARCHAR2,
                       X_Attr_Char3		       VARCHAR2,
                       X_Attr_Char4		       VARCHAR2,
                       X_Attr_Char5		       VARCHAR2,
                       X_Attr_Char6		       VARCHAR2,
                       X_Attr_Char7		       VARCHAR2,
                       X_Attr_Char8		       VARCHAR2,
                       X_Attr_Char9		       VARCHAR2,
                       X_Attr_Char10	               VARCHAR2,
                       X_Attr_Num1		       NUMBER,
                       X_Attr_Num2		       NUMBER,
                       X_Attr_Num3		       NUMBER,
                       X_Attr_Num4		       NUMBER,
                       X_Attr_Num5		       NUMBER,
                       X_Attr_Num6		       NUMBER,
                       X_Attr_Num7		       NUMBER,
                       X_Attr_Num8		       NUMBER,
                       X_Attr_Num9		       NUMBER,
                       X_Attr_Num10		       NUMBER,
                       X_Attr_Date1		       DATE,
                       X_Attr_Date2		       DATE,
                       X_Attr_Date3		       DATE,
                       X_Attr_Date4		       DATE,
                       X_Attr_Date5		       DATE,
                       X_Attr_Date6		       DATE,
                       X_Attr_Date7		       DATE,
                       X_Attr_Date8		       DATE,
                       X_Attr_Date9		       DATE,
                       X_Attr_Date10		       DATE
                    );

PROCEDURE Update_Row (X_Rowid                          VARCHAR2,
                       X_Inventory_Item_Id              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Related_Item_Id                NUMBER,
                       X_Relationship_Type_Id           NUMBER,
                       X_Reciprocal_Flag                VARCHAR2,
                       X_Planning_Enabled_Flag          VARCHAR2,
                       X_Start_Date                    DATE,
                       X_End_Date                      DATE,
                       X_Attr_Context	               VARCHAR2,
                       X_Attr_Char1		       VARCHAR2,
                       X_Attr_Char2		       VARCHAR2,
                       X_Attr_Char3		       VARCHAR2,
                       X_Attr_Char4		       VARCHAR2,
                       X_Attr_Char5		       VARCHAR2,
                       X_Attr_Char6		       VARCHAR2,
                       X_Attr_Char7		       VARCHAR2,
                       X_Attr_Char8		       VARCHAR2,
                       X_Attr_Char9		       VARCHAR2,
                       X_Attr_Char10      	       VARCHAR2,
                       X_Attr_Num1		       NUMBER,
                       X_Attr_Num2		       NUMBER,
                       X_Attr_Num3		       NUMBER,
                       X_Attr_Num4		       NUMBER,
                       X_Attr_Num5		       NUMBER,
                       X_Attr_Num6		       NUMBER,
                       X_Attr_Num7		       NUMBER,
                       X_Attr_Num8		       NUMBER,
                       X_Attr_Num9		       NUMBER,
                       X_Attr_Num10		       NUMBER,
                       X_Attr_Date1		       DATE,
                       X_Attr_Date2		       DATE,
                       X_Attr_Date3		       DATE,
                       X_Attr_Date4		       DATE,
                       X_Attr_Date5		       DATE,
                       X_Attr_Date6		       DATE,
                       X_Attr_Date7		       DATE,
                       X_Attr_Date8		       DATE,
                       X_Attr_Date9		       DATE,
                       X_Attr_Date10		       DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);


END MTL_RELATED_ITEMS_PKG;

 

/