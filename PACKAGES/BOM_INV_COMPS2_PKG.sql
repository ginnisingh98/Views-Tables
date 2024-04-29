--------------------------------------------------------
--  DDL for Package BOM_INV_COMPS2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_INV_COMPS2_PKG" AUTHID CURRENT_USER as
/* $Header: bompic2s.pls 120.1 2005/07/12 02:15:22 vhymavat noship $ */

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Operation_Seq_Num                NUMBER,
                     X_Component_Item_Id                NUMBER,
                     X_Item_Num                         NUMBER,
                     X_Component_Quantity               NUMBER,
                     X_Component_Yield_Factor           NUMBER,
                     X_Component_Remarks                VARCHAR2,
                     X_Effectivity_Date                 DATE,
                     X_Change_Notice                    VARCHAR2,
                     X_Implementation_Date              DATE,
                     X_Disable_Date                     DATE,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Planning_Factor                  NUMBER,
                     X_Quantity_Related                 NUMBER,
                     X_So_Basis                         NUMBER,
                     X_Optional                         NUMBER,
                     X_Mutually_Exclusive_Options       NUMBER,
                     X_Include_In_Cost_Rollup           NUMBER,
                     X_Check_Atp                        NUMBER,
                     X_Required_To_Ship                 NUMBER,
                     X_Required_For_Revenue             NUMBER,
                     X_Include_On_Ship_Docs             NUMBER,
                     X_Include_On_Bill_Docs             NUMBER,
                     X_Low_Quantity                     NUMBER,
                     X_High_Quantity                    NUMBER,
                     X_Acd_Type                         NUMBER,
                     X_Old_Component_Sequence_Id        NUMBER,
                     X_Component_Sequence_Id            NUMBER,
                     X_Bill_Sequence_Id                 NUMBER,
                     X_Wip_Supply_Type                  NUMBER,
                     X_Pick_Components                  NUMBER,
                     X_Supply_Subinventory              VARCHAR2,
                     X_Supply_Locator_Id                NUMBER,
                     X_Operation_Lead_Time_Percent      NUMBER,
                     X_Revised_Item_Sequence_Id         NUMBER,
                     X_Cost_Factor                      NUMBER,
                     X_Bom_Item_Type                    NUMBER,
                     X_From_Unit_Number                 VARCHAR2,
                     X_To_Unit_Number                   VARCHAR2,
		     X_Enforce_Int_Requirements         NUMBER DEFAULT NULL,
		     X_Auto_Request_Material	     	VARCHAR2 DEFAULT NULL
		     ,X_Suggested_Vendor_Name           VARCHAR2 DEFAULT NULL
             	     ,X_Vendor_Id                        NUMBER DEFAULT NULL
                     ,X_Unit_Price                       NUMBER DEFAULT NULL
		     ,X_basis_type                       NUMBER DEFAULT NULL
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Operation_Seq_Num              NUMBER,
                       X_Component_Item_Id              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Item_Num                       NUMBER,
                       X_Component_Quantity             NUMBER,
                       X_Component_Yield_Factor         NUMBER,
                       X_Component_Remarks              VARCHAR2,
                       X_Effectivity_Date               DATE,
                       X_Change_Notice                  VARCHAR2,
                       X_Implementation_Date            DATE,
                       X_Disable_Date                   DATE,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Planning_Factor                NUMBER,
                       X_Quantity_Related               NUMBER,
                       X_So_Basis                       NUMBER,
                       X_Optional                       NUMBER,
                       X_Mutually_Exclusive_Options     NUMBER,
                       X_Include_In_Cost_Rollup         NUMBER,
                       X_Check_Atp                      NUMBER,
                       X_Required_To_Ship               NUMBER,
                       X_Required_For_Revenue           NUMBER,
                       X_Include_On_Ship_Docs           NUMBER,
                       X_Include_On_Bill_Docs           NUMBER,
                       X_Low_Quantity                   NUMBER,
                       X_High_Quantity                  NUMBER,
                       X_Acd_Type                       NUMBER,
                       X_Old_Component_Sequence_Id      NUMBER,
                       X_Component_Sequence_Id          NUMBER,
                       X_Bill_Sequence_Id               NUMBER,
                       X_Wip_Supply_Type                NUMBER,
                       X_Pick_Components                NUMBER,
                       X_Supply_Subinventory            VARCHAR2,
                       X_Supply_Locator_Id              NUMBER,
                       X_Operation_Lead_Time_Percent    NUMBER,
                       X_Revised_Item_Sequence_Id       NUMBER,
                       X_Cost_Factor                    NUMBER,
                       X_Bom_Item_Type                  NUMBER,
                       X_From_Unit_Number               VARCHAR2,
                       X_To_Unit_Number                 VARCHAR2,
		       X_Enforce_Int_Requirements       NUMBER DEFAULT NULL,
		       X_Auto_Request_Material	     	VARCHAR2 DEFAULT NULL
		       ,X_Suggested_Vendor_Name         VARCHAR2 DEFAULT NULL
		       ,X_Vendor_Id                     NUMBER DEFAULT NULL
                       ,X_Unit_Price                    NUMBER DEFAULT NULL
		       ,X_basis_type                     NUMBER DEFAULT NULL
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  FUNCTION POPULATE_INV_COMPS (X_Group_Id NUMBER,
                               X_Bill_Sequence_Id IN NUMBER,
                               X_Err_Text IN OUT NOCOPY VARCHAR2
                               ) return NUMBER;

END BOM_INV_COMPS2_PKG;

 

/
