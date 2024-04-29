--------------------------------------------------------
--  DDL for Package SBC_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SBC_CONTROLLER" AUTHID CURRENT_USER AS
/* $Header: ENGCSBCS.pls 115.5 2004/02/12 22:58:41 sshrikha ship $ */

-- Global Record Type:
-- The ECO form declares a revised component controller record of this type to send in
-- user-entered information that requires processing.

TYPE Controller_SBC_Rec_Type IS RECORD
(   Change_Notice                   VARCHAR2(10) := NULL
,   Organization_Code               VARCHAR2(3)  := NULL
,   Revised_Item_Name               VARCHAR2(700) := NULL
,   Start_Effective_Date            DATE         := NULL
,   New_Revised_Item_Revision       VARCHAR2(3)  := NULL
,   Operation_Sequence_Number       NUMBER       := NULL
,   Component_Item_Name             VARCHAR2(700) := NULL
,   Alternate_BOM_Code              VARCHAR2(10) := NULL
,   Substitute_Component_Name       VARCHAR2(700) := NULL
,   Acd_Type                      NUMBER         := NULL
,   Substitute_Item_Quantity      NUMBER         := NULL
,   Attribute_category            VARCHAR2(30)   := NULL
,   Attribute1                    VARCHAR2(150)  := NULL
,   Attribute2                    VARCHAR2(150)  := NULL
,   Attribute4                    VARCHAR2(150)  := NULL
,   Attribute5                    VARCHAR2(150)  := NULL
,   Attribute6                    VARCHAR2(150)  := NULL
,   Attribute8                    VARCHAR2(150)  := NULL
,   Attribute9                    VARCHAR2(150)  := NULL
,   Attribute10                   VARCHAR2(150)  := NULL
,   Attribute12                   VARCHAR2(150)  := NULL
,   Attribute13                   VARCHAR2(150)  := NULL
,   Attribute14                   VARCHAR2(150)  := NULL
,   Attribute15                   VARCHAR2(150)  := NULL
,   program_id                    NUMBER         := NULL
,   Attribute3                    VARCHAR2(150)  := NULL
,   Attribute7                    VARCHAR2(150)  := NULL
,   Attribute11                   VARCHAR2(150)  := NULL
,   Return_Status                 VARCHAR2(1)    := NULL
,   Transaction_Type                VARCHAR2(30) := NULL
,   Organization_Id                NUMBER        := NULL
,   Component_Item_Id              NUMBER        := NULL
,   Component_Sequence_Id          NUMBER        := NULL
,   Revised_Item_Id                NUMBER        := NULL
,   Substitute_Component_Id        NUMBER        := NULL
,   Bill_Sequence_Id               NUMBER        := NULL
,   Revised_Item_Sequence_Id       NUMBER        := NULL
);

PROCEDURE Validate_And_Write
(   p_SBC_controller_rec        IN  Controller_SBC_Rec_Type
,   p_control_rec		IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_SBC_controller_rec        IN OUT NOCOPY Controller_SBC_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Row
(   p_SBC_controller_rec        IN  Controller_SBC_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Change_Attribute
(   p_SBC_controller_rec        IN  Controller_SBC_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_SBC_controller_rec        IN OUT NOCOPY Controller_SBC_Rec_Type
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

END SBC_Controller;

 

/
