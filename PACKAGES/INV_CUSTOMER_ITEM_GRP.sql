--------------------------------------------------------
--  DDL for Package INV_CUSTOMER_ITEM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CUSTOMER_ITEM_GRP" AUTHID CURRENT_USER as
/* $Header: INVICSDS.pls 120.1.12010000.3 2012/08/02 07:16:18 zewhuang ship $ */

PRAGMA RESTRICT_REFERENCES ( INV_CUSTOMER_ITEM_GRP, WNDS, WNPS, RNDS, RNPS );

 PROCEDURE CI_Attribute_Value(
	Z_Customer_Item_Id		IN	Number 	DEFAULT NULL,
	Z_Customer_Id			IN	Number 	DEFAULT NULL,
	Z_Customer_Category_Code	IN	Varchar2	DEFAULT NULL,
	Z_Address_Id			IN	Number	DEFAULT NULL,
	Z_Customer_Item_Number		IN	Varchar2	DEFAULT NULL,
	Z_Inventory_Item_Id		IN	Number	DEFAULT NULL,
	Z_Organization_Id		IN	Number	DEFAULT NULL,
	Attribute_Name			IN	Varchar2	DEFAULT NULL,
	Error_Code			OUT	NOCOPY Varchar2,
	Error_Flag			OUT	NOCOPY Varchar2,
	Error_Message			OUT	NOCOPY Varchar2,
  Attribute_Value      OUT  NOCOPY Varchar2,
  Z_Line_Category_Code IN   VARCHAR2 DEFAULT 'ORDER' -- bug 13718740
	);


 PROCEDURE Fetch_Attributes(
	Y_Address_Id	 		IN	Number	DEFAULT NULL,
	Y_Customer_Category_Code	IN	Varchar2	DEFAULT NULL,
	Y_Customer_Id			IN	Number	DEFAULT NULL,
	Y_Customer_Item_Number		IN	Varchar2	DEFAULT NULL,
	Y_Organization_Id		IN	Number	DEFAULT NULL,
	Y_Customer_Item_Id		IN	Number	DEFAULT NULL,
	Y_Inventory_Item_Id		IN	Number	DEFAULT NULL,
	X_Customer_Item_Id		OUT	NOCOPY Number,
	X_Customer_Id			OUT	NOCOPY Number,
	X_Customer_Category_Code	OUT	NOCOPY Varchar2,
	X_Address_Id			OUT	NOCOPY Number,
	X_Customer_Item_Number		OUT	NOCOPY Varchar2,
	X_Item_Definition_Level		OUT	NOCOPY Varchar2,
	X_Customer_Item_Desc		OUT	NOCOPY Varchar2,
	X_Model_Customer_Item_Id	OUT	NOCOPY Number,
	X_Commodity_Code_Id		OUT	NOCOPY Number,
	X_Master_Container_Item_Id	OUT	NOCOPY Number,
	X_Container_Item_Org_Id		OUT	NOCOPY Number,
	X_Detail_Container_Item_Id	OUT	NOCOPY Number,
	X_Min_Fill_Percentage		OUT	NOCOPY Number,
	X_Dep_Plan_Required_Flag	OUT	NOCOPY Varchar2,
	X_Dep_Plan_Prior_Bld_Flag	OUT	NOCOPY Varchar2,
	X_Demand_Tolerance_Positive	OUT	NOCOPY Number,
	X_Demand_Tolerance_Negative	OUT	NOCOPY Number,
	X_Attribute_Category		OUT	NOCOPY Varchar2,
	X_Attribute1			OUT	NOCOPY Varchar2,
	X_Attribute2			OUT	NOCOPY Varchar2,
	X_Attribute3			OUT	NOCOPY Varchar2,
	X_Attribute4			OUT	NOCOPY Varchar2,
	X_Attribute5			OUT	NOCOPY Varchar2,
	X_Attribute6			OUT	NOCOPY Varchar2,
	X_Attribute7			OUT	NOCOPY Varchar2,
	X_Attribute8			OUT	NOCOPY Varchar2,
	X_Attribute9			OUT	NOCOPY Varchar2,
	X_Attribute10			OUT	NOCOPY Varchar2,
	X_Attribute11			OUT	NOCOPY Varchar2,
	X_Attribute12			OUT	NOCOPY Varchar2,
	X_Attribute13			OUT	NOCOPY Varchar2,
	X_Attribute14			OUT	NOCOPY Varchar2,
	X_Attribute15			OUT	NOCOPY Varchar2,
	X_Inventory_Item_Id		OUT	NOCOPY Number,
	X_Master_Organization_Id	OUT	NOCOPY Number,
	X_Preference_Number		OUT	NOCOPY Number,
	X_Error_Code			OUT	NOCOPY Varchar2,
	X_Error_Flag			OUT	NOCOPY Varchar2,
  X_Error_Message      OUT  NOCOPY Varchar2,
  Y_Line_Category_Code IN   VARCHAR2 DEFAULT 'RETURN'-- bug 13718740, 14394021
	);


END INV_CUSTOMER_ITEM_GRP;

/
