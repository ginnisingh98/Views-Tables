--------------------------------------------------------
--  DDL for Package OE_SHP_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SHP_PROCESS" AUTHID CURRENT_USER AS
/* $Header: OEXSHPRS.pls 115.1 99/07/16 08:15:57 porting shi $ */

PROCEDURE Apply_Ordered_Quantity_Change
(
        P_Lines_Item_Type_Code          IN  VARCHAR2,
        P_Lines_Ser_Flag                IN  VARCHAR2,
        P_Ord_Enforce_List_Prices_Flag  IN VARCHAR2,
        P_Shp_Config_Flag               OUT VARCHAR2,
        P_Shp_Sch_Flag                  OUT VARCHAR2,
        P_Shp_Adj_Flag                  OUT VARCHAR2,
        P_Shp_Apply_Ord_Adj_Flag        OUT VARCHAR2,
        P_Shp_Credit_Flag               OUT VARCHAR2,
        P_Shp_Ser_Flag                  IN OUT VARCHAR2,
        P_Shp_Schedule_Quantity_Tot   IN OUT NUMBER,
        P_Line_Details_S_Qty_Total   OUT NUMBER,
        P_Shp_Installation_Quantity   OUT NUMBER,
        P_Shp_Ordered_Quantity        IN  NUMBER,
        P_Shp_Open_Quantity           IN OUT NUMBER,
        P_Shp_Cancelled_Quantity      IN  NUMBER,
        P_return_Status                 IN OUT VARCHAR2
);


PROCEDURE Get_Shipment_Detail_Controls
(
        P_Lines_Item_Type_Code          IN  VARCHAR2,
        P_Lines_Ser_Flag                IN  VARCHAR2,
        P_Ord_Enforce_List_Prices_Flag  IN VARCHAR2,
        P_Shp_Config_Flag               OUT VARCHAR2,
        P_Shp_Sch_Flag                  OUT VARCHAR2,
        P_Shp_Adj_Flag                  OUT VARCHAR2,
        P_Shp_Apply_Ord_Adj_Flag        OUT VARCHAR2,
        P_Shp_Credit_Flag               OUT VARCHAR2,
        P_Shp_Ser_Flag                  OUT VARCHAR2,
        P_return_Status                 OUT VARCHAR2
);

PROCEDURE Query_Shipment_Total
(
        P_Shp_Row_Id            IN VARCHAR2,
        P_Shp_Line_Id           IN NUMBER,
        P_Lines_Line_Id             IN NUMBER,
        P_Shp_Line_Type_Code    IN VARCHAR2,
        P_Shp_serviceable_Flag  IN VARCHAR2,
        P_Order_Currency_Precision  IN NUMBER,
        P_Shp_Selling_Price     IN NUMBER,
        P_Shp_Line_Total          IN OUT NUMBER,
        P_Shp_Total             IN OUT NUMBER,
        P_Shp_Ordered_Quantity  IN NUMBER,
        P_Shp_Open_Quantity     IN OUT NUMBER,
        P_Shp_Cancelled_Quantity IN NUMBER,
        P_Shp_Service_Total     OUT NUMBER,
        P_Shp_Query_Total       OUT VARCHAR2,
        P_Return_Status           IN OUT VARCHAR2
);

PROCEDURE Calc_Shipment_Total
(
        P_Shp_Line_Total                OUT  NUMBER,
        P_Shp_Ordered_Quantity        IN   NUMBER,
        P_Shp_Open_Quantity           IN OUT  NUMBER,
        P_Shp_Cancelled_Quantity      IN   NUMBER,
        P_Shp_Selling_Price           IN   NUMBER,
        P_Shp_Line_Type_Code          IN   VARCHAR2,
        P_Return_Status                 IN OUT VARCHAR2
);

PROCEDURE Total_Shipment
(
        P_Shp_Total                     IN OUT  NUMBER,
        P_Shp_Line_Total                IN OUT  NUMBER,
        P_Shp_Ordered_Quantity          IN NUMBER,
        P_Shp_Open_Quantity             IN OUT NUMBER,
        P_Shp_Cancelled_Quantity        IN NUMBER,
        P_Shp_Selling_Price             IN NUMBER,
        P_Shp_Line_Type_Code            IN VARCHAR2,
        P_return_Status                 IN OUT VARCHAR2
);

PROCEDURE Calc_Line_Total
(
        P_Lines_Line_Total              OUT  NUMBER,
        P_Lines_Ordered_Quantity        IN   NUMBER,
        P_Lines_Open_Quantity           IN OUT  NUMBER,
        P_Lines_Cancelled_Quantity      IN   NUMBER,
        P_Lines_Selling_Price           IN   NUMBER,
        P_Lines_Line_Type_Code          IN   VARCHAR2,
        P_Lines_Item_Type_Code          IN   VARCHAR2,
        P_Lines_Service_Duration        IN   NUMBER,
        P_Return_Status                 IN OUT VARCHAR2
);

PROCEDURE Total_Line
(
        P_Lines_Total                   IN OUT  NUMBER,
        P_Lines_Line_Total              IN OUT  NUMBER,
        P_Lines_Ordered_Quantity        IN NUMBER,
        P_Lines_Open_Quantity           IN OUT NUMBER,
        P_Lines_Cancelled_Quantity      IN NUMBER,
        P_Lines_Selling_Price           IN NUMBER,
        P_Lines_Line_Type_Code          IN VARCHAR2,
        P_Lines_Item_Type_Code          IN VARCHAR2,
        P_Lines_Service_Duration        IN NUMBER,
        P_return_Status                 IN OUT VARCHAR2
);

PROCEDURE  Shipment_Total
(
        P_Line_Id               IN NUMBER,
        P_Line_Total            OUT NUMBER,
        P_Return_Status         OUT VARCHAR2
);


PROCEDURE Shipment_Quantity_Total
(
        P_Lines_Line_Id                 IN NUMBER,
        P_Lines_Shipment_Qty_Total      OUT NUMBER,
        P_Lines_Shipment_Lines_Count    OUT NUMBER,
        P_return_Status                 OUT VARCHAR2
);

PROCEDURE  Update_Line_Type_Code
(
        P_Line_Id               IN NUMBER,
        P_Line_Type_Code        IN VARCHAR2,
        P_Return_Status         OUT VARCHAR2
);

PROCEDURE  Match_Shipment_Quantity
(
        P_Ship_Sched_Line_Id       IN OUT NUMBER,
        P_Line_RowId               IN VARCHAR2,
        P_Open_Line_Quantity       IN OUT NUMBER,
        P_Total_Shipment_Quantity  IN OUT NUMBER,
        P_Return_Status            OUT VARCHAR2
);


PROCEDURE  Update_Line_Quantity
(
        P_Ship_Sched_Line_Id       IN OUT NUMBER,
        P_Total_Shipment_Quantity  IN OUT NUMBER,
        P_Open_Line_Quantity       IN OUT NUMBER,
        P_Line_Quantity            IN OUT NUMBER,
        P_Return_Status            OUT VARCHAR2
);

PROCEDURE  Update_Parent_Option_Quantity
(
                P_Line_Id                  IN NUMBER,
                P_Total_Shipment_Quantity  IN NUMBER,
                P_Ordered_Quantity         IN NUMBER,
                P_Cancelled_Quantity       IN NUMBER,
                P_Return_Status            OUT VARCHAR2
);

END OE_SHP_PROCESS;

 

/
