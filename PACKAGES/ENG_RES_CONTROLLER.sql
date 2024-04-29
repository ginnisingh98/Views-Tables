--------------------------------------------------------
--  DDL for Package ENG_RES_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_RES_CONTROLLER" AUTHID CURRENT_USER AS
/* $Header: ENGCRESS.pls 115.6 2004/02/12 22:55:34 sshrikha ship $ */

-- Global Record Type:
-- The ECO form declares a revised operation resource controller record of this type
-- to send in user-entered information that requires processing.

TYPE Controller_RES_Rec_Type IS RECORD
(   Eco_Name                        VARCHAR2(10)         := NULL
,   Organization_Code          	    VARCHAR2(3)          := NULL
,   Revised_Item_Name               VARCHAR2(700)         := NULL
,   New_revised_Item_Revision       VARCHAR2(3)          := NULL
,   ACD_Type                        NUMBER               := NULL
,   Alternate_Routing_Code          VARCHAR2(10)         := NULL
,   Operation_Sequence_Number       NUMBER               := NULL
,   Operation_Type                  NUMBER               := NULL
,   Op_Start_Effective_Date         DATE                 := NULL
,   Resource_Sequence_Number        NUMBER               := NULL
,   Resource_Code                   VARCHAR2(10)         := NULL
,   Activity                        VARCHAR2(10)         := NULL
,   Standard_Rate_Flag              NUMBER               := NULL
,   Assigned_Units                  NUMBER               := NULL
,   Usage_Rate_Or_amount            NUMBER               := NULL
,   Usage_Rate_Or_Amount_Inverse    NUMBER               := NULL
,   Basis_Type                      NUMBER               := NULL
,   Schedule_Flag                   NUMBER               := NULL
,   Resource_Offset_Percent         NUMBER               := NULL
,   Autocharge_Type                 NUMBER               := NULL
,   Schedule_Sequence_Number        NUMBER               := NULL
,   Principle_Flag                  NUMBER               := NULL
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
,   Original_System_Reference       VARCHAR2(50)         := NULL
,   Transaction_Type                VARCHAR2(30)         := NULL
,   Setup_Code                      VARCHAR2(30)         := NULL
,   Return_Status                   VARCHAR2(1)          := NULL
,   Revised_Item_Sequence_Id        NUMBER               := NULL
,   Operation_Sequence_Id	    NUMBER               := NULL
,   Routing_Sequence_Id             NUMBER               := NULL
,   Revised_Item_Id                 NUMBER               := NULL
,   Organization_Id                 NUMBER               := NULL
,   Substitute_Group_Number         NUMBER               := NULL
,   Resource_Id                     NUMBER               := NULL
,   Activity_Id                     NUMBER               := NULL
,   Setup_Id                        NUMBER               := NULL
);

-- Procedure Initialize_Record

PROCEDURE Initialize_Record
(   p_RES_controller_rec        IN  Controller_RES_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_RES_controller_rec        IN OUT NOCOPY Controller_RES_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_And_Write
(   p_RES_controller_rec        IN  Controller_RES_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_RES_controller_rec        IN OUT NOCOPY Controller_RES_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Row
(   p_RES_controller_rec        IN  Controller_RES_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Change_Attribute
(   p_RES_controller_rec        IN  Controller_RES_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_RES_controller_rec        IN OUT NOCOPY Controller_RES_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

/*PROCEDURE Lock_Row
(   x_return_status             OUT NOCOPY VARCHAR2
,   x_err_text                  OUT NOCOPY VARCHAR2
,   p_ECO_rec                   IN  ENG_Eco_PUB.Eco_Rec_Type
,   x_ECO_rec                   OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
);
*/

END ENG_RES_Controller;

 

/
