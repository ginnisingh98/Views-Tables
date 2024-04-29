--------------------------------------------------------
--  DDL for Package OE_LIN_SCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LIN_SCH" AUTHID CURRENT_USER AS
/* $Header: OEXLNSHS.pls 115.1 99/07/16 08:13:20 porting shi $ */


PROCEDURE Get_Reserved_Quantity
(
        P_Line_Id                   IN NUMBER,
        P_Reserved_Quantity         OUT NUMBER,
        P_Return_Status             OUT VARCHAR2
);

PROCEDURE Get_Released_Quantity
(
        P_Line_Id                   IN NUMBER,
        P_Config_Item_Exists IN VARCHAR2,
        P_Line_Released_Quantity      OUT NUMBER,
        P_Return_Status                   OUT VARCHAR2
);

PROCEDURE Check_Details_Complexity
(
        P_Line_Id                   IN NUMBER,
        Details_Complexity_Count          OUT NUMBER,
        P_Return_Status                   OUT VARCHAR2
);

PROCEDURE Get_Scheduling_Quantity
(
        P_Line_Id                   IN NUMBER,
        P_Config_Item_Exists IN VARCHAR2,
        P_Reserved_Quantity         OUT NUMBER,
        P_Line_Released_Quantity      OUT NUMBER,
        Details_Complexity_Count          OUT NUMBER,
        P_Return_Status                   IN OUT VARCHAR2
);

PROCEDURE Check_Scheduling_Quantity
(
        P_Line_Id                   IN NUMBER,
        P_Config_Item_Exists        IN VARCHAR2,
        P_Ordered_Quantity          IN NUMBER,
        P_Cancelled_Quantity        IN NUMBER,
        P_Reserved_Quantity         IN OUT NUMBER,
        Return_Status                     IN OUT VARCHAR2
);

PROCEDURE Get_Schedule_Status
(

        P_Line_Id                         IN NUMBER,
        P_Schedule_Status_Code            IN OUT VARCHAR2,
        P_Schedule_Status_Name            OUT VARCHAR2,
        P_Schedule_Action_Code            OUT VARCHAR2,
        P_Return_Status                   OUT VARCHAR2
);

PROCEDURE Get_Schedule_DB_Values
(
        P_Row_Id                          IN VARCHAR2,
        P_Line_Id                         IN NUMBER,
        P_schedule_date                   OUT VARCHAR2,
        P_demand_Class_Code               OUT VARCHAR2,
        P_Ship_To_Site_Use_Id             OUT NUMBER,
        P_Warehouse_id                    OUT Number,
        P_Ship_To_Contact_Id              OUT NUMBER,
        P_Shipment_Priority_Code          OUT VARCHAR2,
        P_Ship_Method_Code                OUT VARCHAR2,
        P_Schedule_Date_Svrid             OUT NUMBER,
        P_Demand_Class_Svrid              OUT NUMBER,
        P_Ship_To_Svrid                   OUT NUMBER,
        P_Warehouse_Svrid                 OUT NUMBER,
        P_Ordered_Quantity                OUT NUMBER,
        P_Unit_Code                       OUT VARCHAR2,
        P_Reserved_Quantity               OUT NUMBER,
        P_Return_Status                   OUT VARCHAR2

);

PROCEDURE Validate_Scheduling_Attributes
(
        P_DB_Record_Flag                  IN VARCHAR2,
        P_Lin_Obj_Schedule_Action_Code    IN VARCHAR2,
        P_Lin_Obj_Reserved_Quantity       IN NUMBER,
        P_Lin_Obj_Ordered_Quantity        IN NUMBER,
        P_Lin_Obj_Ship_To_Site_Use_Id     IN NUMBER,
        P_Lin_Obj_Warehouse_Id            IN Number,
        P_Lin_Obj_Schedule_Date           IN DATE,
        P_Lin_Obj_Demand_Class_Code       IN VARCHAR2,
        P_Row_Id                          IN VARCHAR2,
        P_Line_Id                         IN NUMBER,
        P_World_DB_schedule_date          IN OUT VARCHAR2,
        P_World_DB_demand_Class_Code      IN OUT VARCHAR2,
        P_World_DB_Ship_To_Site_Use_Id    IN OUT NUMBER,
        P_World_DB_Warehouse_id           IN OUT Number,
        P_World_DB_Ship_To_Contact_Id     IN OUT NUMBER,
        P_World_DB_Ship_Priority_Code     IN OUT VARCHAR2,
        P_World_DB_Ship_Method_Code       IN OUT VARCHAR2,
        P_World_DB_Schedule_Date_Svrid    IN OUT NUMBER,
        P_World_DB_Demand_Class_Svrid     IN OUT NUMBER,
        P_World_DB_Ship_To_Svrid          IN OUT NUMBER,
        P_World_DB_Warehouse_Svrid        IN OUT NUMBER,
        P_World_DB_Ordered_Quantity       IN OUT NUMBER,
        P_World_DB_Unit_Code              IN OUT VARCHAR2,
        P_World_DB_Reserved_Quantity      IN OUT NUMBER,
        P_Return_Status                   IN OUT VARCHAR2

);


PROCEDURE Scheduling_Security
(
        Attribute                           IN VARCHAR2,
        ATO_Model_Flag                      IN VARCHAR2,
        ATO_Line_Id                         IN NUMBER,
        Supply_Reservation_Exists           IN VARCHAR2,
        DB_Record_Flag                      IN VARCHAR2,
        Source_Object                       IN VARCHAR2,
        Order_Category                      IN VARCHAR2,
        Row_Id                              IN VARCHAR2,
        Return_Status                       OUT VARCHAR2
);

PROCEDURE Query_Reserved_Quantity
(

        P_Line_Id                         IN NUMBER,
        P_Reservations                    IN VARCHAR2,
        P_Reserved_Quantity               OUT NUMBER,
        P_Return_Status                   OUT VARCHAR2
);


END OE_LIN_SCH;

 

/
