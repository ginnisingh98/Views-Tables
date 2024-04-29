--------------------------------------------------------
--  DDL for Package ENG_RIT_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_RIT_CONTROLLER" AUTHID CURRENT_USER AS
/* $Header: ENGCRICS.pls 120.0 2006/02/12 23:44:16 asjohal noship $ */

-- Global Record Type:
-- The ECO form declares a revised item controller record of this type to
-- send in user-entered information that requires processing.

TYPE Controller_RIT_Rec_Type IS RECORD
(   Eco_Name                      VARCHAR2(10)   := NULL
,   Organization_Code             VARCHAR2(3)    := NULL
,   Revised_Item_Name             VARCHAR2(700)   := NULL
,   New_Revised_Item_Revision     VARCHAR2(3)    := NULL
,   New_Revised_Item_Rev_Desc     VARCHAR2(240)  := NULL
,   Updated_Revised_Item_Revision VARCHAR2(3)    := NULL
,   Updated_Routing_Revision      VARCHAR2(3)    := NULL
,   Start_Effective_Date          DATE           := NULL
,   New_Effective_Date            DATE           := NULL
,   Alternate_Bom_Code            VARCHAR2(10)   := NULL
,   Status_Type                   NUMBER         := NULL
,   Mrp_Active                    NUMBER         := NULL
,   Earliest_Effective_Date       DATE           := NULL
,   Use_Up_Item_Name              VARCHAR2(700)   := NULL
,   Use_Up_Plan_Name              VARCHAR2(10)   := NULL
,   Requestor			  VARCHAR2(30)   := NULL
,   Disposition_Type              NUMBER         := NULL
,   Update_Wip                    NUMBER         := NULL
,   Cancel_Comments               VARCHAR2(240)  := NULL
,   Change_Description            VARCHAR2(240)  := NULL
,   Attribute_category            VARCHAR2(30)   := NULL
,   Attribute1                    VARCHAR2(150)  := NULL
,   Attribute2                    VARCHAR2(150)  := NULL
,   Attribute3                    VARCHAR2(150)  := NULL
,   Attribute4                    VARCHAR2(150)  := NULL
,   Attribute5                    VARCHAR2(150)  := NULL
,   Attribute6                    VARCHAR2(150)  := NULL
,   Attribute7                    VARCHAR2(150)  := NULL
,   Attribute8                    VARCHAR2(150)  := NULL
,   Attribute9                    VARCHAR2(150)  := NULL
,   Attribute10                   VARCHAR2(150)  := NULL
,   Attribute11                   VARCHAR2(150)  := NULL
,   Attribute12                   VARCHAR2(150)  := NULL
,   Attribute13                   VARCHAR2(150)  := NULL
,   Attribute14                   VARCHAR2(150)  := NULL
,   Attribute15                   VARCHAR2(150)  := NULL
,   Start_From_Unit_Number     VARCHAR2(30)   := NULL
,   New_From_End_Item_Unit_Number VARCHAR2(30)   := NULL
,   Original_System_Reference     VARCHAR2(50)   := NULL
,   Return_Status                 VARCHAR2(1)    := NULL
,   Transaction_Type              VARCHAR2(30)   := NULL
,   From_Work_Order               VARCHAR2(150)  := NULL
,   To_Work_Order                 VARCHAR2(150)  := NULL
,   From_Cumulative_Quantity      NUMBER         := NULL
,   Lot_Number                    VARCHAR2(30)   := NULL
,   Completion_Subinventory       VARCHAR2(10)   := NULL
,   Completion_Location_Name      VARCHAR2(700)   := NULL
,   Priority                      NUMBER         := NULL
,   Ctp_Flag                      NUMBER         := NULL
,   New_Routing_Revision          VARCHAR2(240)  := NULL
,   Routing_Comment               VARCHAR2(240)  := NULL
,   Organization_Id               NUMBER         := NULL
,   Revised_Item_Id               NUMBER         := NULL
,   Implementation_Date           DATE           := NULL
,   Auto_Implement_Date           DATE           := NULL
,   Cancellation_Date             DATE           := NULL
,   Bill_Sequence_Id              NUMBER         := NULL
,   Use_Up_Item_Id                NUMBER         := NULL
,   Use_Up                        NUMBER         := NULL
,   Requestor_id                  NUMBER         := NULL
,   Revised_Item_Sequence_Id      NUMBER         := NULL
,   Routing_Sequence_Id		  NUMBER         := NULL
,   From_WIP_Entity_Id            NUMBER         := NULL
,   To_WIP_Entity_Id              NUMBER         := NULL
,   CFM_Routing_Flag              NUMBER         := NULL
,   Completion_Locator_Id         NUMBER         := NULL
,   Eco_For_Production            NUMBER         := NULL
 -- added for Requirements :ECO form
,   Change_Id                     NUMBER         := NULL
,   Reschedule_Comments           VARCHAR2(240)  := NULL -- Bug 3589974
);

-- Procedure Initialize_Record

PROCEDURE Initialize_Record
(   p_RIT_controller_rec        IN  ENG_RIT_Controller.Controller_Rit_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_RIT_controller_rec        IN OUT NOCOPY ENG_RIT_Controller.Controller_Rit_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_And_Write
(   p_RIT_controller_rec        IN  ENG_RIT_Controller.Controller_Rit_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_RIT_controller_rec        IN OUT NOCOPY ENG_RIT_Controller.Controller_Rit_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Row
(   p_RIT_controller_rec        IN  ENG_RIT_Controller.Controller_Rit_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Change_Attribute
(   p_RIT_controller_rec        IN  ENG_RIT_Controller.Controller_Rit_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_RIT_controller_rec        IN  OUT NOCOPY ENG_RIT_Controller.Controller_Rit_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
,   x_disable_revision          OUT NOCOPY NUMBER --Bug no:3034642
);

/*PROCEDURE Lock_Row
(   x_return_status             OUT NOCOPY VARCHAR2
,   x_err_text                  OUT NOCOPY VARCHAR2
,   p_ECO_rec                   IN  ENG_Eco_PUB.Eco_Rec_Type
,   x_ECO_rec                   OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
);
*/

END ENG_RIT_Controller;

 

/
