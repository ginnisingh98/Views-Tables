--------------------------------------------------------
--  DDL for Package OE_SO_LIN_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SO_LIN_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: oesolins.pls 115.1 99/07/16 08:28:23 porting shi $ */

  FUNCTION complex_details (x_line_id IN NUMBER) RETURN BOOLEAN;
  pragma restrict_references( complex_details, WNPS, WNDS);

  PROCEDURE Validate_Reserved_Qty (
                P_Line_Id		IN  NUMBER,
		P_Lines_Reserved_Qty	IN  NUMBER,
		P_Lines_Ordered_Qty	IN  NUMBER,
		P_Lines_Cancelled_Qty	IN  NUMBER,
		P_Lines_Released_Qty	IN  NUMBER,
		P_Result		OUT VARCHAR2
		);

  PROCEDURE Load_Item_Warehouse_Attributes(
		P_Inventory_Item_Id	IN	NUMBER,
		P_Organization_id	IN	NUMBER,
		P_Item_Desc		OUT	VARCHAR2,
		P_SO_Xactions_Flag	OUT	VARCHAR2,
		P_Reservable_Type	OUT	NUMBER,
		P_ATP_Flag		OUT	VARCHAR2,
		P_Result		OUT	VARCHAR2
		);

  PROCEDURE Get_Schedule_DB_Values(
		    X_Row_Id			  IN  VARCHAR2
		,   X_Line_Id			  IN  NUMBER
		,   P_Db_Schedule_Date		  OUT DATE
	        ,   P_Db_Demand_Class_Code	  OUT VARCHAR2
	        ,   P_Db_Ship_To_Site_Use_Id	  OUT NUMBER
	        ,   P_Db_Warehouse_Id		  OUT NUMBER
	        ,   P_Db_Ship_To_Contact_Id  	  OUT NUMBER
	        ,   P_Db_Shipment_Priority_Code	  OUT VARCHAR2
	        ,   P_Db_Ship_Method_Code	  OUT VARCHAR2
	        ,   P_Db_Schedule_Date_Svrid 	  OUT NUMBER
	        ,   P_Db_Demand_Class_Svrid	  OUT NUMBER
	        ,   P_Db_Ship_To_Svrid  	  OUT NUMBER
	        ,   P_Db_Warehouse_Svrid  	  OUT NUMBER
	        ,   P_Db_Ship_Set_Number  	  OUT NUMBER
	        ,   P_Db_Ship_Set_Number_Svrid    OUT NUMBER
		,   P_Db_Reserved_Quantity  	  OUT NUMBER
		,   Result			  OUT VARCHAR2
		);

  PROCEDURE Query_Time_Stamps(
		X_Row_Id			IN VARCHAR2,
		X_Creation_Date			OUT DATE,
		X_Creation_Date_Time		OUT DATE,
		X_Std_Component_Freeze_Date	OUT DATE,
		X_Tax_Code			OUT VARCHAR2,
		X_Tax_Code_SVRID		OUT NUMBER,
		Result				OUT VARCHAR2
		);

  PROCEDURE Load_ATO_Model(
			X_Line_Id		IN     	NUMBER,
			X_ATO_Model		OUT    	VARCHAR2,
			X_ATO_Flag		IN     	VARCHAR2,
			X_ATO_Line_Id		IN     	NUMBER,
			X_Item_Type_Code	IN     	VARCHAR2,
			X_Configuration_Item_Exists OUT VARCHAR2,
			Result			OUT	VARCHAR2
		);

  PROCEDURE Load_Supply_Reserved(
			X_Line_Id		IN     	NUMBER,
			X_Supply_Res_Details    OUT 	VARCHAR2,
			Result			OUT	VARCHAR2
		);

  FUNCTION DB_Reserved_Quantity(X_Line_Id IN NUMBER) return NUMBER;
  pragma restrict_references (DB_Reserved_Quantity, WNPS, WNDS);


PROCEDURE Validate_Scheduling_Attributes
	(
		P_Row_Id			VARCHAR2,
		P_Line_Id			NUMBER,
		P_Ship_Set_Number		NUMBER,
		P_Reserved_Quantity		NUMBER,
		P_Warehouse_Id			NUMBER,
		P_Ship_To_Site_Use_Id		NUMBER,
		P_Schedule_Date			DATE,
		P_Demand_Class_Code		VARCHAR2,
		P_Ship_Method_Code		VARCHAR2,
		P_Shipment_Priority_Code	VARCHAR2,
		P_Schedule_Action_Code		VARCHAR2,
		P_Navigation_Context		VARCHAR2,
		P_Result		IN OUT	VARCHAR2
	);

END OE_SO_LIN_VALIDATE;

 

/
