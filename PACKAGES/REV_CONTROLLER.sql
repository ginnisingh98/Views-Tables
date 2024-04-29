--------------------------------------------------------
--  DDL for Package REV_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."REV_CONTROLLER" AUTHID CURRENT_USER AS
/* $Header: ENGCREVS.pls 115.6 2003/01/06 12:47:07 akumar ship $ */

-- Global Record Type:
-- The ECO form declares a revised item controller record of this type to send in
-- user-entered information that requires processing.

TYPE Controller_REV_Rec_Type IS RECORD
(   Change_Notice                 VARCHAR2(10)   := NULL
,   Organization_code             VARCHAR2(3)    := NULL
,   Revision                      VARCHAR2(10)   := NULL
,   New_Revision                  VARCHAR2(10)   := NULL
,   Comments                      VARCHAR2(240)  := NULL
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
,   Return_Status                 VARCHAR2(1)    := NULL
,   Transaction_Type              VARCHAR2(30)   := NULL
,   Organization_Id               NUMBER         := NULL
,   Revision_Id                   NUMBER         := NULL
,   Change_Id                     NUMBER         := NULL   --added on 6.1.2003
);

PROCEDURE Validate_And_Write
(   p_REV_controller_rec        IN  REV_Controller.Controller_REV_Rec_Type
,   p_control_rec		IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_REV_controller_rec        IN OUT NOCOPY REV_Controller.Controller_REV_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Row
(   p_REV_controller_rec        IN  REV_Controller.Controller_REV_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

/*
PROCEDURE Change_Attribute
(   p_REV_controller_rec        IN  ENG_ECO_PUB.Controller_REV_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_REV_controller_rec        IN OUT NOCOPY ENG_ECO_PUB.Controller_REV_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text			    OUT NOCOPY VARCHAR2
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   x_ECO_rec                       OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
);
*/

END REV_Controller;

 

/
