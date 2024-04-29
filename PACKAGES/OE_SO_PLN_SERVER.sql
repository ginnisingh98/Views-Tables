--------------------------------------------------------
--  DDL for Package OE_SO_PLN_SERVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SO_PLN_SERVER" AUTHID CURRENT_USER AS
/* $Header: OESOPLNS.pls 115.1 99/07/16 08:11:09 porting shi $ */

PROCEDURE When_Validate_Record
        (
                    X_Row_Id                    IN      VARCHAR2,
                    P_Picking_Line_Id           IN      NUMBER,
                    P_Db_Schedule_Date          IN OUT  DATE,
                    P_Db_Demand_Class_Code      IN OUT  VARCHAR2,
                    P_Db_Ship_To_Site_Use_Id    IN OUT  NUMBER,
                    P_Db_Warehouse_Id           IN OUT  NUMBER,
                    P_Db_Ship_To_Contact_Id     IN OUT  NUMBER,
                    P_Db_Shipment_Priority_Code IN OUT  VARCHAR2,
                    P_Db_Ship_Method_Code       IN OUT  VARCHAR2,
                    P_Db_Reserved_Quantity      IN OUT  NUMBER,
                    P_Schedule_Action_Code      IN      VARCHAR2,
                    P_Schedule_Date             IN      DATE,
                    P_Demand_Class_Code         IN      VARCHAR2,
                    P_Ship_To_Site_Use_Id       IN      NUMBER,
                    P_Warehouse_Id              IN      NUMBER,
                    P_Ship_To_Contact_Id        IN      NUMBER,
                    P_Shipment_Priority_Code    IN      VARCHAR2,
                    P_Ship_Method_Code          IN      VARCHAR2,
                    P_Reserved_Quantity         IN      NUMBER,
                    P_Result                    OUT     VARCHAR2
        );


  FUNCTION complex_details (x_picking_line_id IN NUMBER) RETURN BOOLEAN;
  pragma restrict_references( complex_details, WNPS, WNDS);

  PROCEDURE Validate_Reserved_Qty (
                P_Picking_Line_Id 	 IN  NUMBER,
		P_Reserved_Qty    	 IN  NUMBER,
		P_Original_Requested_Qty IN  NUMBER,
		P_Cancelled_Qty   	 IN  NUMBER,
		P_Released_Qty    	 IN  NUMBER,
		P_Result	  	 OUT VARCHAR2
		);



  FUNCTION DB_Reserved_Quantity(X_Picking_Line_Id IN NUMBER) return NUMBER;
  pragma restrict_references (DB_Reserved_Quantity, WNPS, WNDS);

  PROCEDURE Get_Schedule_DB_Values(
                    X_Row_Id                      IN  VARCHAR2
                ,   X_Picking_Line_Id                     IN  NUMBER
                ,   P_Db_Schedule_Date            OUT DATE
                ,   P_Db_Demand_Class_Code        OUT VARCHAR2
                ,   P_Db_Ship_To_Site_Use_Id      OUT NUMBER
                ,   P_Db_Warehouse_Id             OUT NUMBER
                ,   P_Db_Ship_To_Contact_Id       OUT NUMBER
                ,   P_Db_Shipment_Priority_Code   OUT VARCHAR2
                ,   P_Db_Ship_Method_Code         OUT VARCHAR2
                ,   P_Db_Reserved_Quantity        OUT NUMBER
                ,   Result                        OUT VARCHAR2
                );


PROCEDURE Lock_Row(X_Rowid VARCHAR2,
    X_ATTRIBUTE1    VARCHAR2,
    X_ATTRIBUTE10    VARCHAR2,
    X_ATTRIBUTE11    VARCHAR2,
    X_ATTRIBUTE12    VARCHAR2,
    X_ATTRIBUTE13    VARCHAR2,
    X_ATTRIBUTE14    VARCHAR2,
    X_ATTRIBUTE15    VARCHAR2,
    X_ATTRIBUTE2    VARCHAR2,
    X_ATTRIBUTE3    VARCHAR2,
    X_ATTRIBUTE4    VARCHAR2,
    X_ATTRIBUTE5    VARCHAR2,
    X_ATTRIBUTE6    VARCHAR2,
    X_ATTRIBUTE7    VARCHAR2,
    X_ATTRIBUTE8    VARCHAR2,
    X_ATTRIBUTE9    VARCHAR2,
    X_CANCELLED_QUANTITY    NUMBER,
    X_COMPONENT_CODE    VARCHAR2,
    X_COMPONENT_RATIO    NUMBER,
    X_COMPONENT_SEQUENCE_ID    NUMBER,
    X_CONFIGURATION_ITEM_FLAG    VARCHAR2,
    X_CONTEXT    VARCHAR2,
    X_CREATED_BY    NUMBER,
    X_CREATION_DATE    DATE,
    X_DATE_CONFIRMED    DATE,
    X_DATE_REQUESTED    DATE,
    X_DEMAND_CLASS_CODE    VARCHAR2,
    X_INCLUDED_ITEM_FLAG    VARCHAR2,
    X_INVENTORY_ITEM_ID    NUMBER,
    X_INVENTORY_STATUS    VARCHAR2,
    X_INVOICED_QUANTITY    NUMBER,
    X_LAST_UPDATED_BY    NUMBER,
    X_LAST_UPDATE_DATE    DATE,
    X_LAST_UPDATE_LOGIN    NUMBER,
    X_LATEST_ACCEPTABLE_DATE    DATE,
    X_LINE_DETAIL_ID    NUMBER,
    X_ORDER_LINE_ID    NUMBER,
    X_ORGANIZATION_ID    NUMBER,
    X_ORIGINAL_REQUESTED_QUANTITY    NUMBER,
    X_PICKING_HEADER_ID    NUMBER,
    X_PICKING_LINE_ID    NUMBER,
    X_PROGRAM_APPLICATION_ID    NUMBER,
    X_PROGRAM_ID    NUMBER,
    X_PROGRAM_UPDATE_DATE    DATE,
    X_RA_INTERFACE_STATUS    VARCHAR2,
    X_REQUESTED_QUANTITY    NUMBER,
    X_REQUEST_ID    NUMBER,
    X_SCHEDULE_DATE    DATE,
    X_SEQUENCE_NUMBER    NUMBER,
    X_SHIPMENT_PRIORITY_CODE    VARCHAR2,
    X_SHIPPED_QUANTITY    NUMBER,
    X_SHIP_METHOD_CODE    VARCHAR2,
    X_SHIP_TO_CONTACT_ID    NUMBER,
    X_SHIP_TO_SITE_USE_ID    NUMBER,
    X_UNIT_CODE    VARCHAR2,
    X_WAREHOUSE_ID    NUMBER,
    Result OUT VARCHAR2);

PROCEDURE Update_Row(X_Rowid VARCHAR2,
    X_ATTRIBUTE1    VARCHAR2,
    X_ATTRIBUTE10    VARCHAR2,
    X_ATTRIBUTE11    VARCHAR2,
    X_ATTRIBUTE12    VARCHAR2,
    X_ATTRIBUTE13    VARCHAR2,
    X_ATTRIBUTE14    VARCHAR2,
    X_ATTRIBUTE15    VARCHAR2,
    X_ATTRIBUTE2    VARCHAR2,
    X_ATTRIBUTE3    VARCHAR2,
    X_ATTRIBUTE4    VARCHAR2,
    X_ATTRIBUTE5    VARCHAR2,
    X_ATTRIBUTE6    VARCHAR2,
    X_ATTRIBUTE7    VARCHAR2,
    X_ATTRIBUTE8    VARCHAR2,
    X_ATTRIBUTE9    VARCHAR2,
    X_CANCELLED_QUANTITY    NUMBER,
    X_COMPONENT_CODE    VARCHAR2,
    X_COMPONENT_RATIO    NUMBER,
    X_COMPONENT_SEQUENCE_ID    NUMBER,
    X_CONFIGURATION_ITEM_FLAG    VARCHAR2,
    X_CONTEXT    VARCHAR2,
    X_CREATED_BY    NUMBER,
    X_CREATION_DATE    DATE,
    X_DATE_CONFIRMED    DATE,
    X_DATE_REQUESTED    DATE,
    X_DEMAND_CLASS_CODE    VARCHAR2,
    X_INCLUDED_ITEM_FLAG    VARCHAR2,
    X_INVENTORY_ITEM_ID    NUMBER,
    X_INVENTORY_STATUS    VARCHAR2,
    X_INVOICED_QUANTITY    NUMBER,
    X_LAST_UPDATED_BY    NUMBER,
    X_LAST_UPDATE_DATE    DATE,
    X_LAST_UPDATE_LOGIN    NUMBER,
    X_LATEST_ACCEPTABLE_DATE    DATE,
    X_LINE_DETAIL_ID    NUMBER,
    X_ORDER_LINE_ID    NUMBER,
    X_ORGANIZATION_ID    NUMBER,
    X_ORIGINAL_REQUESTED_QUANTITY    NUMBER,
    X_PICKING_HEADER_ID    NUMBER,
    X_PICKING_LINE_ID    NUMBER,
    X_PROGRAM_APPLICATION_ID    NUMBER,
    X_PROGRAM_ID    NUMBER,
    X_PROGRAM_UPDATE_DATE    DATE,
    X_RA_INTERFACE_STATUS    VARCHAR2,
    X_REQUESTED_QUANTITY    NUMBER,
    X_REQUEST_ID    NUMBER,
    X_SCHEDULE_DATE    DATE,
    X_SEQUENCE_NUMBER    NUMBER,
    X_SHIPMENT_PRIORITY_CODE    VARCHAR2,
    X_SHIPPED_QUANTITY    NUMBER,
    X_SHIP_METHOD_CODE    VARCHAR2,
    X_SHIP_TO_CONTACT_ID    NUMBER,
    X_SHIP_TO_SITE_USE_ID    NUMBER,
    X_UNIT_CODE    VARCHAR2,
    X_WAREHOUSE_ID    NUMBER
);

END OE_SO_PLN_SERVER;

 

/
