--------------------------------------------------------
--  DDL for Package ENG_OPS_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_OPS_CONTROLLER" AUTHID CURRENT_USER AS
/* $Header: ENGCOPSS.pls 120.0.12010000.2 2015/05/21 05:50:22 nlingamp ship $ */

-- Global Record Type:
-- The ECO form declares a revised operation sequence controller record of this type
-- to send in user-entered information that requires processing.

TYPE Controller_OPS_Rec_Type IS RECORD
(   Eco_Name                        VARCHAR2(10)         := NULL
,   Organization_Code          	    VARCHAR2(3)          := NULL
,   Revised_Item_Name               VARCHAR2(700)         := NULL
,   New_revised_Item_Revision       VARCHAR2(3)          := NULL
,   ACD_Type                        NUMBER               := NULL
,   Alternate_Routing_Code          VARCHAR2(10)         := NULL
,   Operation_Sequence_Number       NUMBER               := NULL
,   Operation_Type                  NUMBER               := NULL
,   Start_Effective_Date            DATE                 := NULL
,   New_Operation_Sequence_Number   NUMBER               := NULL
,   Old_Operation_Sequence_Number   NUMBER               := NULL
,   Old_Start_Effective_Date        DATE                 := NULL
,   Standard_Operation_Code         VARCHAR2(4)          := NULL
,   Department_Code                 VARCHAR2(10)         := NULL
,   Op_Lead_Time_Percent            NUMBER               := NULL
,   Minimum_Transfer_Quantity       NUMBER               := NULL
,   Count_Point_Type                NUMBER               := NULL
,   Operation_Description           VARCHAR2(240)        := NULL
,   Disable_Date                    DATE                 := NULL
,   Backflush_Flag                  NUMBER               := NULL
,   Check_Skill                     NUMBER               := NULL  --Added for bug 13979762
,   Option_Dependent_Flag           NUMBER               := NULL
,   Reference_Flag                  NUMBER               := NULL
,   Yield                           NUMBER               := NULL
,   Cumulative_Yield                NUMBER               := NULL
,   Cancel_Comments                 VARCHAR2(240)        := NULL
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
,   Return_Status                   VARCHAR2(1)          := NULL
,   Revised_Item_Sequence_Id        NUMBER               := NULL
,   Operation_Sequence_Id           NUMBER               := NULL
,   Old_Operation_Sequence_Id       NUMBER               := NULL
,   Routing_Sequence_Id             NUMBER               := NULL
,   Revised_Item_Id                 NUMBER               := NULL
,   Organization_Id                 NUMBER               := NULL
,   Standard_Operation_Id           NUMBER               := NULL
,   Department_Id                   NUMBER               := NULL
);

-- Procedure Initialize_Record

PROCEDURE Initialize_Record
(   p_OPS_controller_rec        IN  Controller_OPS_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_OPS_controller_rec        IN OUT NOCOPY Controller_OPS_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_And_Write
(   p_OPS_controller_rec        IN  Controller_OPS_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_OPS_controller_rec        IN OUT NOCOPY Controller_OPS_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Row
(   p_OPS_controller_rec        IN  Controller_OPS_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Change_Attribute
(   p_OPS_controller_rec        IN  Controller_OPS_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_OPS_controller_rec        IN OUT NOCOPY Controller_OPS_Rec_Type
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

END ENG_OPS_Controller;

/
