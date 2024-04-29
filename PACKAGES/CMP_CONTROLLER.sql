--------------------------------------------------------
--  DDL for Package CMP_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CMP_CONTROLLER" AUTHID CURRENT_USER AS
/* $Header: ENGCCMPS.pls 120.0 2005/05/26 19:04:47 appldev noship $ */

-- Global Record Type:
-- The ECO form declares a revised component controller record of this type
-- to send in user-entered information that requires processing.

TYPE Controller_CMP_Rec_Type IS RECORD
(   Change_Notice                   VARCHAR2(10)         := NULL
,   Organization_Code               VARCHAR2(3)          := NULL
,   Revised_Item_Name               VARCHAR2(700)         := NULL
,   New_Item_Revision               VARCHAR2(3)          := NULL
,   Scheduled_Date                  DATE                 := NULL
,   Disable_Date                    DATE                 := NULL
,   Operation_Sequence_Number       NUMBER               := NULL
,   Old_Operation_Sequence_Number   NUMBER		 := NULL
,   Old_Effectivity_Date	    DATE		 := NULL
,   Old_from_end_item_unit_number   VARCHAR2(30)	 := NULL
,   New_Operation_Sequence_Number   NUMBER		 := NULL
,   Component_Item_Name             VARCHAR2(700)         := NULL
,   Alternate_BOM_Code              VARCHAR2(10)         := NULL
,   ACD_Type                        NUMBER               := NULL
,   Item_Sequence_Number            NUMBER               := NULL
,   Component_Quantity              NUMBER               := NULL
,   Planning_Factor                 NUMBER               := NULL
,   Component_Yield_Factor          NUMBER               := NULL
,   Include_In_Cost_Rollup          NUMBER               := NULL
,   Wip_Supply                      NUMBER               := NULL
,   So_Basis                        NUMBER               := NULL
,   Optional                        NUMBER               := NULL
,   Mutually_Exclusive              NUMBER               := NULL
,   Check_Atp                       NUMBER               := NULL
,   Shipping_Allowed                NUMBER               := NULL
,   Required_To_Ship                NUMBER               := NULL
,   Required_For_Revenue            NUMBER               := NULL
,   Include_On_Ship_Docs            NUMBER               := NULL
,   Quantity_Related                NUMBER               := NULL
,   Supply_Subinventory             VARCHAR2(10)         := NULL
,   Supply_Locator                  VARCHAR2(81)         := NULL
,   Low_Quantity                    NUMBER               := NULL
,   High_Quantity                   NUMBER               := NULL
,   Component_Remarks               VARCHAR2(240)        := NULL
,   cancel_comments                 VARCHAR2(240)        := NULL
,   Attribute_category              VARCHAR2(30)         := NULL
,   Attribute1                      VARCHAR2(150)        := NULL
,   Attribute2                      VARCHAR2(150)        := NULL
,   Attribute3                      VARCHAR2(150)        := NULL
,   Attribute4                      VARCHAR2(150)        := NULL
,   Attribute5                      VARCHAR2(150)        := NULL
,   Attribute6                      VARCHAR2(150)        := NULL
,   Attribute7                      VARCHAR2(150)        := NULL
,   Attribute8                      VARCHAR2(150)        := NULL
,   Attribute9                      VARCHAR2(150)        := NULL
,   Attribute10                     VARCHAR2(150)        := NULL
,   Attribute11                     VARCHAR2(150)        := NULL
,   Attribute12                     VARCHAR2(150)        := NULL
,   Attribute13                     VARCHAR2(150)        := NULL
,   Attribute14                     VARCHAR2(150)        := NULL
,   Attribute15                     VARCHAR2(150)        := NULL
,   From_End_Item_Unit_Number       VARCHAR2(30)         := NULL
,   To_End_Item_Unit_Number         VARCHAR2(30)         := NULL
,   Return_Status                   VARCHAR2(1)          := NULL
,   Transaction_Type                VARCHAR2(30)         := NULL
,   Organization_Id                 NUMBER               := NULL
,   Component_Item_Id               NUMBER               := NULL
,   Old_Component_Sequence_Id       NUMBER               := NULL
,   Component_Sequence_Id           NUMBER               := NULL
,   Bill_Sequence_Id                NUMBER               := NULL
,   Pick_Components                 NUMBER               := NULL
,   Supply_Locator_Id               NUMBER               := NULL
,   Revised_Item_Sequence_Id        NUMBER               := NULL
,   Bom_Item_Type                   NUMBER               := NULL
,   Revised_Item_Id                 NUMBER               := NULL
,   Include_On_Bill_Docs            NUMBER               := NULL
,   Enforce_Int_Requirements        VARCHAR2(80)         := NULL
,   Enforce_Int_Requirements_Code   NUMBER               := NULL
,    Basis_Type                           NUMBER               := NULL
);

-- Procedure Initialize_Record

PROCEDURE Initialize_Record
(   p_CMP_controller_rec        IN  Controller_CMP_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_CMP_controller_rec        IN OUT  NOCOPY Controller_CMP_Rec_Type
,   x_Mesg_Token_Tbl            OUT  NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_And_Write
(   p_CMP_controller_rec        IN  Controller_CMP_Rec_Type
,   p_control_rec		IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_CMP_controller_rec        IN OUT NOCOPY Controller_CMP_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Row
(   p_CMP_controller_rec        IN  Controller_CMP_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Change_Attribute
(   p_CMP_controller_rec        IN  Controller_CMP_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_CMP_controller_rec        IN OUT NOCOPY Controller_CMP_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

/*PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text			    OUT NOCOPY VARCHAR2
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   x_ECO_rec                       OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
);
*/

END CMP_Controller;

 

/
