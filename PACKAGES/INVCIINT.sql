--------------------------------------------------------
--  DDL for Package INVCIINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVCIINT" AUTHID CURRENT_USER as
/* $Header: INVICOIS.pls 120.1 2005/06/21 03:10:31 appldev ship $ */

PRAGMA RESTRICT_REFERENCES ( INVCIINT, WNDS, WNPS, RNDS, RNPS );

Error	EXCEPTION;
Current_Error_Code  Varchar2(9)	:= NULL;
Curr_Error	    Varchar2(9)	:= NULL;

 PROCEDURE Load_Cust_Item(ERRBUF OUT NOCOPY VARCHAR2,
		  	RETCODE OUT NOCOPY VARCHAR2,
		  	ARGUMENT1 IN VARCHAR2,
		  	ARGUMENT2 IN VARCHAR2);


 FUNCTION Load_Cust_Items_Iface(
			Abort_On_Error	IN	Varchar2	DEFAULT	'No',
			Delete_Record	IN	Varchar2	DEFAULT	'Yes')
		RETURN Number;


PROCEDURE Validate_Customer_Item(
		Row_Id				IN OUT	NOCOPY Varchar2,
		Process_Mode			IN OUT	NOCOPY Number,
		Customer_Name			IN OUT	NOCOPY Varchar2,
		Customer_Number			IN OUT	NOCOPY Varchar2,
		Customer_Id			IN OUT	NOCOPY Number,
		Customer_Category_Code		IN OUT	NOCOPY Varchar2,
		Customer_Category		IN OUT	NOCOPY Varchar2,
		Address1			IN OUT	NOCOPY Varchar2,
		Address2			IN OUT	NOCOPY Varchar2,
		Address3			IN OUT	NOCOPY Varchar2,
		Address4			IN OUT	NOCOPY Varchar2,
		City				IN OUT	NOCOPY Varchar2,
		State				IN OUT	NOCOPY Varchar2,
		County				IN OUT	NOCOPY Varchar2,
		Country				IN OUT	NOCOPY Varchar2,
		Postal_Code			IN OUT	NOCOPY Varchar2,
		Address_Id			IN OUT	NOCOPY Number,
		Customer_Item_Number		IN OUT	NOCOPY Varchar2,
		Item_Definition_Level_Desc	IN OUT	NOCOPY Varchar2,
		Item_Definition_Level		IN OUT	NOCOPY Number,
		Customer_Item_Desc		IN OUT	NOCOPY Varchar2,
		Model_Customer_Item_Number	IN OUT	NOCOPY Varchar2,
		Model_Customer_Item_Id		IN OUT	NOCOPY Number,
		Commodity_Code			IN OUT	NOCOPY Varchar2,
		Commodity_Code_Id		IN OUT	NOCOPY Number,
		Master_Container_Segment1	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment2	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment3	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment4	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment5	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment6	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment7	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment8	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment9	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment10	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment11	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment12	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment13	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment14	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment15	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment16	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment17	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment18	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment19	IN OUT	NOCOPY Varchar2,
		Master_Container_Segment20	IN OUT	NOCOPY Varchar2,
		Master_Container		IN OUT	NOCOPY Varchar2,
		Master_Container_Item_Id	IN OUT	NOCOPY Number,
		Container_Item_Org_Name		IN OUT	NOCOPY Varchar2,
		Container_Item_Org_Code		IN OUT	NOCOPY Varchar2,
		Container_Item_Org_Id		IN OUT	NOCOPY Number,
		Detail_Container_Segment1	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment2	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment3	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment4	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment5	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment6	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment7	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment8	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment9	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment10	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment11	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment12	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment13	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment14	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment15	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment16	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment17	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment18	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment19	IN OUT	NOCOPY Varchar2,
		Detail_Container_Segment20	IN OUT	NOCOPY Varchar2,
		Detail_Container		IN OUT	NOCOPY Varchar2,
		Detail_Container_Item_Id	IN OUT	NOCOPY Number,
		Min_Fill_Percentage		IN OUT	NOCOPY Number,
		Dep_Plan_Required_Flag		IN OUT	NOCOPY Varchar2,
		Dep_Plan_Prior_Bld_Flag		IN OUT	NOCOPY Varchar2,
		Inactive_Flag			IN OUT	NOCOPY Varchar2,
		Attribute_Category		IN OUT	NOCOPY Varchar2,
		Attribute1			IN OUT	NOCOPY Varchar2,
		Attribute2			IN OUT	NOCOPY Varchar2,
		Attribute3			IN OUT	NOCOPY Varchar2,
		Attribute4			IN OUT	NOCOPY Varchar2,
		Attribute5			IN OUT	NOCOPY Varchar2,
		Attribute6			IN OUT	NOCOPY Varchar2,
		Attribute7			IN OUT	NOCOPY Varchar2,
		Attribute8			IN OUT	NOCOPY Varchar2,
		Attribute9			IN OUT	NOCOPY Varchar2,
		Attribute10			IN OUT	NOCOPY Varchar2,
		Attribute11			IN OUT	NOCOPY Varchar2,
		Attribute12			IN OUT	NOCOPY Varchar2,
		Attribute13			IN OUT	NOCOPY Varchar2,
		Attribute14			IN OUT	NOCOPY Varchar2,
		Attribute15			IN OUT	NOCOPY Varchar2,
		Demand_Tolerance_Positive	IN OUT	NOCOPY Number,
		Demand_Tolerance_Negative	IN OUT	NOCOPY Number,
		Last_Update_Date		IN OUT	NOCOPY Date,
		Last_Updated_By			IN OUT	NOCOPY Number,
		Creation_Date			IN OUT	NOCOPY Date,
		Created_By			IN OUT	NOCOPY Number,
		Last_Update_Login		IN OUT	NOCOPY Number,
		Request_Id			IN	Number,
		Program_Application_Id		IN 	Number,
		Program_Id			IN 	Number,
		Program_Update_Date		IN 	Date,
		Delete_Record			IN 	Varchar2 DEFAULT	NULL
	);

PROCEDURE Validate_Customer(
		P_Customer_Id			IN OUT	NOCOPY Number,
		P_Customer_Number		IN	Varchar2	DEFAULT NULL,
		P_Customer_Name			IN	Varchar2	DEFAULT NULL
	);

PROCEDURE Validate_Address(
		P_Address_Id		IN OUT	NOCOPY Number,
		P_Customer_Id		IN	Number	DEFAULT NULL,
		P_Address1		IN	Varchar2	DEFAULT NULL,
		P_Address2		IN	Varchar2	DEFAULT NULL,
		P_Address3		IN	Varchar2	DEFAULT NULL,
		P_Address4		IN	Varchar2	DEFAULT NULL,
		P_City			IN	Varchar2	DEFAULT NULL,
		P_State			IN	Varchar2	DEFAULT NULL,
		P_County		IN	Varchar2	DEFAULT NULL,
		P_Country		IN	Varchar2	DEFAULT NULL,
		P_Postal_Code		IN	Varchar2	DEFAULT NULL
	);

PROCEDURE Validate_Address_Category(
		P_Customer_Category_Code	IN OUT	NOCOPY Varchar2,
		P_Customer_Category		IN	Varchar2	DEFAULT NULL
	);

PROCEDURE Validate_CI_Def_Level(
		P_Item_Definition_Level		IN OUT	NOCOPY Varchar2,
		P_Item_Definition_Level_Desc	IN	Varchar2	DEFAULT NULL,
		P_Customer_Id			IN OUT	NOCOPY Number,
		P_Customer_Number		IN OUT	NOCOPY Varchar2,
		P_Customer_Name			IN OUT	NOCOPY Varchar2,
		P_Customer_Category_Code	IN OUT	NOCOPY Varchar2,
		P_Customer_Category		IN OUT	NOCOPY Varchar2,
		P_Address_Id			IN OUT	NOCOPY Number,
		P_Address1			IN OUT	NOCOPY Varchar2,
		P_Address2			IN OUT	NOCOPY Varchar2,
		P_Address3			IN OUT	NOCOPY Varchar2,
		P_Address4			IN OUT	NOCOPY Varchar2,
		P_City				IN OUT	NOCOPY Varchar2,
		P_State				IN OUT	NOCOPY Varchar2,
		P_County			IN OUT	NOCOPY Varchar2,
		P_Country			IN OUT	NOCOPY Varchar2,
		P_Postal_Code			IN OUT	NOCOPY Varchar2
	);

PROCEDURE Validate_Containers(
		P_Container_Item_Id		IN OUT	NOCOPY Number,
		P_Container_Item		IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment1	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment2	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment3	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment4	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment5	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment6	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment7	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment8	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment9	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment10	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment11	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment12	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment13	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment14	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment15	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment16	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment17	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment18	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment19	IN	Varchar2	DEFAULT NULL,
		P_Container_Item_Segment20	IN	Varchar2	DEFAULT NULL,
		P_Container_Organization_Id	IN	Number	DEFAULT NULL
	);

PROCEDURE Validate_Commodity_Code(
		P_Commodity_Code_Id		IN OUT	NOCOPY Number,
		P_Commodity_Code		IN	Varchar2	DEFAULT NULL
	);

PROCEDURE Validate_Model(
		P_Model_Customer_Item_Id	IN OUT	NOCOPY Number,
		P_Model_Customer_Item		IN	Varchar2	DEFAULT NULL,
		P_Customer_Id			IN	Number	DEFAULT NULL,
		P_Address_Id			IN	Number	DEFAULT NULL,
		P_Customer_Category_Code	IN	Varchar2	DEFAULT NULL,
		P_Item_Definition_Level		IN	Varchar2	DEFAULT NULL,
		P_Customer_Item_Number		IN	Varchar2	DEFAULT NULL
	);

PROCEDURE Validate_Demand_Tolerance(
		P_Demand_Tolerance		IN	Number	DEFAULT NULL
	);


PROCEDURE Validate_Fill_Percentage(
		P_Min_Fill_Percentage		IN	Number	DEFAULT NULL
	);


PROCEDURE Validate_Departure_Plan_Flags(
		P_Dep_Plan_Required_Flag	IN OUT	NOCOPY Varchar2,
		P_Dep_Plan_Prior_Bld_Flag	IN OUT	NOCOPY Varchar2
	);


/*===========================================================================+
 +===========================================================================*/
/* These procedures are specific to the Customer Item XRefs Open Interface.  */
/*===========================================================================+
 +===========================================================================*/

PROCEDURE Load_Cust_Item_Xrefs(ERRBUF OUT NOCOPY VARCHAR2,
		  	RETCODE OUT NOCOPY VARCHAR2,
		  	ARGUMENT1 IN VARCHAR2,
		  	ARGUMENT2 IN VARCHAR2);


FUNCTION Load_Cust_Item_XRefs_Iface(
		Abort_On_Error		IN	Varchar2	DEFAULT	'No',
		Delete_Record		IN	Varchar2	DEFAULT	'Yes'
	) RETURN NUMBER;


PROCEDURE Validate_CI_XRefs(
		Row_Id				IN OUT	NOCOPY Varchar2,
		Process_Mode			IN OUT	NOCOPY Varchar2,
		Customer_Name			IN OUT	NOCOPY Varchar2,
		Customer_Number			IN OUT	NOCOPY Varchar2,
		Customer_Id			IN OUT	NOCOPY Number,
		Customer_Category_Code		IN OUT	NOCOPY Varchar2,
		Customer_Category		IN OUT	NOCOPY Varchar2,
		Address1			IN OUT	NOCOPY Varchar2,
		Address2			IN OUT	NOCOPY Varchar2,
		Address3			IN OUT	NOCOPY Varchar2,
		Address4			IN OUT	NOCOPY Varchar2,
		City				IN OUT	NOCOPY Varchar2,
		State				IN OUT	NOCOPY Varchar2,
		County				IN OUT	NOCOPY Varchar2,
		Country				IN OUT	NOCOPY Varchar2,
		Postal_Code			IN OUT	NOCOPY Varchar2,
		Address_Id			IN OUT	NOCOPY Number,
		Customer_Item_Number		IN OUT	NOCOPY Varchar2,
		Item_Definition_Level_Desc	IN OUT	NOCOPY Varchar2,
		Item_Definition_Level		IN OUT	NOCOPY Varchar2,
		Customer_Item_Id		IN OUT	NOCOPY Number,
		Master_Organization_Name	IN OUT	NOCOPY Varchar2,
		Master_Organization_Code	IN OUT	NOCOPY Varchar2,
		Master_Organization_Id		IN OUT	NOCOPY Number,
		Inventory_Item_Segment1		IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment2		IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment3		IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment4		IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment5		IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment6		IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment7		IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment8		IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment9		IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment10	IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment11	IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment12	IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment13	IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment14	IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment15	IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment16	IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment17	IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment18	IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment19	IN OUT	NOCOPY Varchar2,
		Inventory_Item_Segment20	IN OUT	NOCOPY Varchar2,
		Inventory_Item			IN OUT	NOCOPY Varchar2,
		Inventory_Item_Id		IN OUT	NOCOPY Number,
		Preference_Number		IN OUT	NOCOPY Number,
		Inactive_Flag			IN OUT	NOCOPY Varchar2,
		Attribute_Category		IN OUT	NOCOPY Varchar2,
		Attribute1			IN OUT	NOCOPY Varchar2,
		Attribute2			IN OUT	NOCOPY Varchar2,
		Attribute3			IN OUT	NOCOPY Varchar2,
		Attribute4			IN OUT	NOCOPY Varchar2,
		Attribute5			IN OUT	NOCOPY Varchar2,
		Attribute6			IN OUT	NOCOPY Varchar2,
		Attribute7			IN OUT	NOCOPY Varchar2,
		Attribute8			IN OUT	NOCOPY Varchar2,
		Attribute9			IN OUT	NOCOPY Varchar2,
		Attribute10			IN OUT	NOCOPY Varchar2,
		Attribute11			IN OUT	NOCOPY Varchar2,
		Attribute12			IN OUT	NOCOPY Varchar2,
		Attribute13			IN OUT	NOCOPY Varchar2,
		Attribute14			IN OUT	NOCOPY Varchar2,
		Attribute15			IN OUT	NOCOPY Varchar2,
		Last_Update_Date		IN OUT	NOCOPY Date,
		Last_Updated_By			IN OUT	NOCOPY Number,
		Creation_Date			IN OUT	NOCOPY Date,
		Created_By			IN OUT	NOCOPY Number,
		Last_Update_Login		IN OUT	NOCOPY Number,
		Request_Id			IN 	Number,
		Program_Application_Id		IN	Number,
		Program_Id			IN 	Number,
		Program_Update_Date		IN 	Date,
		Delete_Record			IN	Varchar2	DEFAULT	NULL
	);


PROCEDURE Validate_Cust_Item(
		P_Customer_Item_Id		IN OUT	NOCOPY Number,
		P_Customer_Item_Number		IN	Varchar2	DEFAULT NULL,
		P_Item_Definition_Level		IN	Varchar2	DEFAULT NULL,
		P_Item_Definition_Level_Desc	IN	Varchar2	DEFAULT NULL,
		P_Customer_Id			IN	Number		DEFAULT NULL,
		P_Customer_Number		IN	Varchar2	DEFAULT NULL,
		P_Customer_Name			IN	Varchar2	DEFAULT NULL,
		P_Customer_Category_Code	IN	Varchar2	DEFAULT NULL,
		P_Customer_Category		IN	Varchar2	DEFAULT NULL,
		P_Address_Id			IN	Number		DEFAULT NULL,
		P_Address1			IN	Varchar2	DEFAULT NULL,
		P_Address2			IN		Varchar2	DEFAULT NULL,
		P_Address3			IN		Varchar2	DEFAULT NULL,
		P_Address4			IN		Varchar2	DEFAULT NULL,
		P_City				IN		Varchar2	DEFAULT NULL,
		P_State				IN		Varchar2	DEFAULT NULL,
		P_County			IN		Varchar2	DEFAULT NULL,
		P_Country			IN		Varchar2	DEFAULT NULL,
		P_Postal_Code			IN		Varchar2	DEFAULT NULL
		);

PROCEDURE Validate_Master_Organization(
		P_Master_Organization_Id	IN OUT	NOCOPY Number,
		P_Master_Organization_Code	IN	Varchar2	DEFAULT NULL,
		P_Master_Organization_Name	IN	Varchar2	DEFAULT NULL

	);

PROCEDURE Validate_Inventory_Item(
		P_Inventory_Item_Id		IN OUT	NOCOPY Number,
		P_Inventory_Item		IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment1	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment2	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment3	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment4	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment5	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment6	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment7	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment8	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment9	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment10	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment11	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment12	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment13	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment14	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment15	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment16	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment17	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment18	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment19	IN	Varchar2	DEFAULT NULL,
		P_Inventory_Item_Segment20	IN	Varchar2	DEFAULT NULL,
		P_Master_Organization_Id	IN	Number		DEFAULT NULL
	);


/*===========================================================================+
 +===========================================================================*/
/* These procedures will be shared by both Customer Item Open Interfaces.    */
/*===========================================================================+
 +===========================================================================*/

PROCEDURE Validate_Inactive_Flag(
		P_Inactive_Flag			IN OUT	NOCOPY Varchar2
	);


PROCEDURE Validate_Concurrent_Program(
		P_Request_Id			IN	Number	DEFAULT NULL,
		P_Program_Application_Id	IN	Number	DEFAULT NULL,
		P_Program_Id			IN	Number	DEFAULT NULL,
		P_Program_Update_Date		IN	Date	DEFAULT NULL
	);


PROCEDURE Check_Uniqueness(
		P_Origin			IN	Varchar2	DEFAULT NULL,
		P_Customer_Id			IN	Number		DEFAULT NULL,
		P_Customer_Item_Number		IN	Varchar2	DEFAULT NULL,
		P_Item_Definition_Level		IN	Varchar2	DEFAULT NULL,
		P_Customer_Category_Code	IN	Varchar2	DEFAULT NULL,
		P_Address_Id			IN	Number	DEFAULT NULL,
		P_Customer_Item_Id		IN	Number	DEFAULT NULL,
		P_Inventory_Item_Id		IN	Number	DEFAULT NULL,
		P_Master_Organization_Id	IN	Number	DEFAULT NULL,
		P_Preference_Number		IN	Number	DEFAULT NULL
	);


PROCEDURE Check_Required_Columns(
		P_Origin			IN	Varchar2	DEFAULT NULL,
		P_Customer_Id			IN	Number	DEFAULT NULL,
		P_Customer_Item_Number		IN	Varchar2	DEFAULT NULL,
		P_Item_Definition_Level		IN	Varchar2	DEFAULT NULL,
		P_Customer_Category_Code	IN	Varchar2	DEFAULT NULL,
		P_Address_Id			IN	Number	DEFAULT NULL,
		P_Inactive_Flag			IN	Varchar2	DEFAULT NULL,
		P_Last_Updated_By		IN	Number	DEFAULT NULL,
		P_Last_Update_Date		IN	Date	DEFAULT NULL,
		P_Created_By			IN	Number	DEFAULT NULL,
		P_Creation_Date			IN	Date	DEFAULT NULL,
		P_Customer_Item_Id		IN	Number	DEFAULT NULL,
		P_Inventory_Item_Id		IN	Number	DEFAULT NULL,
		P_Master_Organization_Id	IN	Number	DEFAULT NULL,
		P_Preference_Number		IN	Number	DEFAULT NULL
	);


PROCEDURE Insert_Row(
		P_Origin			IN	Varchar2	DEFAULT NULL,
		P_Last_Update_Date		IN	Date	DEFAULT NULL,
		P_Last_Updated_By		IN	Number	DEFAULT NULL,
		P_Creation_Date			IN	Date	DEFAULT NULL,
		P_Created_By			IN	Number	DEFAULT NULL,
		P_Last_Update_Login		IN	Number	DEFAULT NULL,
		P_Customer_Id			IN	Number	DEFAULT NULL,
		P_Customer_Category_Code	IN	Varchar2	DEFAULT NULL,
		P_Address_Id			IN	Number	DEFAULT NULL,
		P_Customer_Item_Number		IN	Varchar2	DEFAULT NULL,
		P_Item_Definition_Level		IN	Varchar2	DEFAULT NULL,
		P_Customer_Item_Desc		IN	Varchar2	DEFAULT NULL,
		P_Model_Customer_Item_Id	IN	Number	DEFAULT NULL,
		P_Commodity_Code_Id		IN	Number	DEFAULT NULL,
		P_Master_Container_Item_Id	IN	Number	DEFAULT NULL,
		P_Container_Item_Org_Id		IN	Number	DEFAULT NULL,
		P_Detail_Container_Item_Id	IN	Number	DEFAULT NULL,
		P_Min_Fill_Percentage		IN	Number	DEFAULT NULL,
		P_Dep_Plan_Required_Flag	IN	Varchar2	DEFAULT NULL,
		P_Dep_Plan_Prior_Bld_Flag	IN	Varchar2	DEFAULT NULL,
		P_Inactive_Flag			IN	Varchar2	DEFAULT NULL,
		P_Attribute_Category		IN	Varchar2	DEFAULT NULL,
		P_Attribute1			IN	Varchar2	DEFAULT NULL,
		P_Attribute2			IN	Varchar2	DEFAULT NULL,
		P_Attribute3			IN	Varchar2	DEFAULT NULL,
		P_Attribute4			IN	Varchar2	DEFAULT NULL,
		P_Attribute5			IN	Varchar2	DEFAULT NULL,
		P_Attribute6			IN	Varchar2	DEFAULT NULL,
		P_Attribute7			IN	Varchar2	DEFAULT NULL,
		P_Attribute8			IN	Varchar2	DEFAULT NULL,
		P_Attribute9			IN	Varchar2	DEFAULT NULL,
		P_Attribute10			IN	Varchar2	DEFAULT NULL,
		P_Attribute11			IN	Varchar2	DEFAULT NULL,
		P_Attribute12			IN	Varchar2	DEFAULT NULL,
		P_Attribute13			IN	Varchar2	DEFAULT NULL,
		P_Attribute14			IN	Varchar2	DEFAULT NULL,
		P_Attribute15			IN	Varchar2	DEFAULT NULL,
		P_Demand_Tolerance_Positive	IN	Number	DEFAULT NULL,
		P_Demand_Tolerance_Negative	IN	Number	DEFAULT NULL,
		P_Request_Id			IN	Number	DEFAULT NULL,
		P_Program_Application_Id	IN	Number	DEFAULT NULL,
		P_Program_Id			IN	Number	DEFAULT NULL,
		P_Program_Update_Date		IN	Date		DEFAULT NULL,
		P_Customer_Item_Id		IN	Number	DEFAULT NULL,
		P_Inventory_Item_Id		IN	Number	DEFAULT NULL,
		P_Master_Organization_Id	IN	Number	DEFAULT NULL,
		P_Preference_Number		IN	Number	DEFAULT NULL
	);


PROCEDURE Delete_Row(
		P_Origin		IN	Varchar2	DEFAULT NULL,
		P_Delete_Record		IN	Varchar2	DEFAULT NULL,
		P_Temp_RowId		IN	Varchar2	DEFAULT NULL	);


PROCEDURE Manage_Error_Code(
		P_Action		IN	Varchar2	DEFAULT 'IN',
		Error_Code		IN	Varchar2	DEFAULT NULL,
		Curr_Error		OUT	NOCOPY Varchar2	);

END INVCIINT;

 

/
