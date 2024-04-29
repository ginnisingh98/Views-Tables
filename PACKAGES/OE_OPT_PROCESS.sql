--------------------------------------------------------
--  DDL for Package OE_OPT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OPT_PROCESS" AUTHID CURRENT_USER AS
/* $Header: OEXOPPRS.pls 115.1 99/07/16 08:14:01 porting shi $ */

PROCEDURE Get_Item_Information
(
      Options_Inventory_Item_Id                  IN NUMBER,
      Options_Item_Type_Code                     IN OUT VARCHAR2,
      Options_Item_Type                          OUT VARCHAR2,
      P_Organization_Id                          IN NUMBER,
      Lines_Component_Sequence_Id                IN NUMBER,
      Options_Component_Code                     IN VARCHAR2,
      Configuration_Parent_Line_Id               IN NUMBER,
      Options_ATO_Flag                           OUT VARCHAR2,
      Options_ATO_Line_Id                        OUT NUMBER,
      ATO_Parent_Component_Code                  OUT VARCHAR2,
      Lines_ATO_Flag                             IN  VARCHAR2 ,
      Options_Line_Id                            IN OUT NUMBER,
      Serviceable_Flag                           OUT VARCHAR2,
      Item                                       IN VARCHAR2,
      Lines_Ship_Model_Comp_Flag                 IN VARCHAR2,
      Options_Ship_Model_Comp_Flag               OUT VARCHAR2,
      Options_Plan_Level                         IN  NUMBER,
      Lines_Creation_Date_Time                   IN  DATE,
      Return_Status                              OUT VARCHAR2
);


PROCEDURE Get_Option_Detail_Controls
(
        World_Organization_Id            IN NUMBER,
        Options_Inventory_Item_Id        IN NUMBER,
        Options_ATO_Flag                 IN VARCHAR2,
        ATO_Parent_Component_Code        IN VARCHAR2,
        Options_Component_Code           IN VARCHAR2,
        Options_ATO_Line_Id              IN NUMBER,
        Options_Schedulable_Flag         OUT VARCHAR2,
        Order_Enforce_List_Prices_Flag   IN VARCHAR2,
        Options_Adjustable_Flag          OUT VARCHAR2,
        Apply_Order_Adjs_Flag            OUT VARCHAR2,
        Options_Serviceable_Flag         OUT VARCHAR2,
	P_return_Status			 OUT VARCHAR2
);


PROCEDURE Get_ATO_Parent_Information
(
        Options_ATO_Line_Id               IN  NUMBER,
        Options_ATO_Parent_Comp_Code      OUT VARCHAR2,
        P_Return_Status                   OUT VARCHAR2
);

PROCEDURE Insert_Installn_Details
(
        P_Line_Id                           IN NUMBER,
        P_User_Id                           IN NUMBER,
        P_Login_Id                          IN NUMBER,
        P_Configuration_Parent_Line_Id      IN NUMBER,
	P_return_Status			  OUT VARCHAR2
);

PROCEDURE Query_BOM_Quantity
(
        P_Creation_Date_Time                IN DATE,
        P_Component_Sequence_Id             IN NUMBER,
        P_Component_Code                    IN VARCHAR2,
        P_Model_Open_Quantity               IN NUMBER,
        P_Component_Quantity                IN OUT NUMBER,
        P_Low_Quantity                      IN OUT NUMBER,
        P_High_Quantity                     IN OUT NUMBER,
        P_Return_Status                     OUT VARCHAR2
);

PROCEDURE Set_Update_Subconfig_Flag
(
        P_Row_Id                            IN VARCHAR2,
        P_Ordered_Quantity                  IN NUMBER,
        P_Update_Subconfig_Flag             OUT VARCHAR2,
        P_Return_Status                     OUT VARCHAR2
);

END OE_OPT_PROCESS;

 

/
