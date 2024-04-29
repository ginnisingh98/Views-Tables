--------------------------------------------------------
--  DDL for Package OE_LIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LIN" AUTHID CURRENT_USER AS
/* $Header: OEXLINSS.pls 115.1 99/07/16 08:13:14 porting shi $ */

PROCEDURE Check_Allow_Manual_Discount
(
        P_Price_List_Id                      IN    NUMBER,
        P_Order_Price_List_Id                IN    NUMBER,
        P_Order_Order_Type_Id                IN    NUMBER,
        P_Header_Id                          IN    NUMBER,
        P_Line_Id                            IN    NUMBER,
        P_List_Price                         IN    NUMBER,
        P_Discounting_Privilage              IN    VARCHAR2,
        P_Global_Result                      OUT   VARCHAR2,
        P_Check_Multiple_Adj_Flag            IN    VARCHAR2 DEFAULT 'Y'
);

PROCEDURE Check_Manual_Discount_Priv
(
        X_Price_List_Id                      IN    NUMBER,
        X_Order_Price_List_Id                IN    NUMBER,
        X_Order_Order_Type_Id                IN    NUMBER,
        X_Header_Id                          IN    NUMBER,
        X_Line_Id                            IN    NUMBER,
        X_List_Price                         IN    NUMBER,
        X_Discounting_Privilage              IN    VARCHAR2,
        X_Global_Result                      OUT   VARCHAR2,
        X_Reason                             OUT   VARCHAR2,
        X_Check_Multiple_Adj_Flag            IN    VARCHAR2 DEFAULT 'Y'
);


PROCEDURE Apply_Manual_Discount
(
        P_Manual_Discount_Id                IN NUMBER,
        P_List_Price                        IN NUMBER,
        P_List_Percent                      IN NUMBER,
        P_Selling_Price                     IN NUMBER,
        P_Manual_Discount_Percent           IN NUMBER,
        P_Pricing_Method_Code               IN VARCHAR2,
        P_Selling_Percent                   OUT NUMBER,
        P_Header_Id                         IN NUMBER,
        P_Line_Id                           IN NUMBER,
        P_User_Id                           IN NUMBER,
        P_Login_Id                          IN NUMBER,
        P_Manual_Discount_Line_Id           IN NUMBER,
        P_Price_List_Id        		    IN NUMBER,
        P_Order_Price_List_Id               IN NUMBER,
        P_Order_Order_Type_Id               IN NUMBER,
        P_Discounting_Privilage             IN VARCHAR2,
        P_Adjustment_Total          	    OUT NUMBER,
        P_Global_Result                     OUT VARCHAR2
);

PROCEDURE Get_Line_Object_Adj_Total
(
        Order_Header_Id               IN    NUMBER,
        Lin_Obj_Line_Id               IN    NUMBER,
        Lin_Obj_Apply_Order_Adjs_Flag IN    VARCHAR2,
        P_Automatic_Flag              IN    VARCHAR2,
        Lin_Obj_Adjustment_Total      OUT   NUMBER,
        P_Return_Status               OUT   VARCHAR2
);


PROCEDURE ATO_Model
(
        ATO_Model_Flag                      IN VARCHAR2,
        Return_Status                       OUT VARCHAR2
);

PROCEDURE ATO_Configuration
(
        ATO_Line_Id                         IN NUMBER,
        Return_Status                       OUT VARCHAR2
);

PROCEDURE Supply_Reserved
(
        Supply_Reservation_Exists           IN VARCHAR2,
        Return_Status                       OUT VARCHAR2
);

PROCEDURE Check_Schedule_Group
(
        DB_Record_Flag                      IN VARCHAR2,
        Source_Object                       IN VARCHAR2,
        Return_Status                       OUT VARCHAR2
);

PROCEDURE Internal_Order
(
        Order_Category                      IN VARCHAR2,
        Return_Status                       OUT VARCHAR2
);

PROCEDURE Fully_Released
(
        Row_Id                            IN VARCHAR2,
        Return_Status                     OUT VARCHAR2
);

PROCEDURE Fully_Cancelled
(
        Row_Id                            IN VARCHAR2,
        Return_Status                     OUT VARCHAR2
);

PROCEDURE Calc_Lin_Obj_Open_Quantity
(
        Lin_Obj_Ordered_Quantity        IN  NUMBER,
        Lin_Obj_Open_Quantity           OUT NUMBER,
        Lin_Obj_Cancelled_Quantity      IN  NUMBER,
        P_return_Status                 OUT VARCHAR2

);

PROCEDURE Load_ATO_Flag
(
        P_Lin_Obj_Line_Id                   IN  NUMBER,
        P_Lin_Obj_Item_Type_Code            IN  VARCHAR2,
        P_Lin_Obj_ATO_Line_Id               IN  NUMBER,
        P_Lin_Obj_ATO_Flag                  IN  VARCHAR2,
        P_Lin_Obj_ATO_Model_Flag            IN OUT  VARCHAR2,
        P_Lin_Obj_Supply_Reserv_Exists     OUT VARCHAR2,
        P_Lin_Obj_Config_Item_Exists        OUT VARCHAR2,
        P_Return_Status                     OUT VARCHAR2
);

PROCEDURE Check_Navigate_Shipments
(
        P_Header_Id                         IN  NUMBER,
        P_Line_Id                           IN  NUMBER,
        P_Order_S1                          IN  NUMBER,
        P_Config_Item_Exists                IN  VARCHAR2,
        P_Return_Status                     OUT VARCHAR2,
        P_ITEM_TYPE_CODE                    IN VARCHAR2 default null,
        P_SERVICE_INSTALLED                 IN VARCHAR2 default 'N'
);

PROCEDURE Update_Shippable_Flag
(
        P_ATO_Option_Parent_Line            IN  NUMBER,
        P_Return_Status                     OUT VARCHAR2
);

END OE_LIN;

 

/
