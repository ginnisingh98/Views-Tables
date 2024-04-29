--------------------------------------------------------
--  DDL for Package ECO_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECO_CONTROLLER" AUTHID CURRENT_USER AS
/* $Header: ENGCECOS.pls 115.14 2003/09/22 18:40:14 akumar ship $ */

/*
-- Control record definition

TYPE Control_Rec_Type IS RECORD
( controlled_operation  BOOLEAN := FALSE
, check_existence       BOOLEAN := FALSE
, attribute_defaulting  BOOLEAN := FALSE
, entity_defaulting     BOOLEAN := FALSE
, entity_validation     BOOLEAN := FALSE
, process_entity        VARCHAR2(30) := ENG_Globals.G_ENTITY_ECO
, write_to_db           BOOLEAN := FALSE
);
*/

-- Global Record Type:
-- The ECO form declares an ECO controller record of this type to send in
-- user-entered information that requires processing.

TYPE Controller_Eco_Rec_Type IS RECORD
( change_notice			VARCHAR2(10) := NULL
, organization_id		NUMBER := NULL
, organization_code		VARCHAR2(3) := NULL
, change_order_type		VARCHAR2(10) := NULL
, change_order_type_id		NUMBER := NULL
, description			VARCHAR2(2000) := NULL
, initiation_date		DATE := NULL
, implementation_date		DATE := NULL
, cancellation_date		DATE := NULL
, status_type			NUMBER := NULL
, cancellation_comments		VARCHAR2(240) := NULL
, priority_code			VARCHAR2(10) := NULL
, reason_code			VARCHAR2(10) := NULL
, estimated_eng_cost		NUMBER := NULL
, estimated_mfg_cost		NUMBER := NULL
, requestor_id			NUMBER := NULL
, requestor_full_name		VARCHAR2(240) := NULL
, approval_status_type		NUMBER := NULL
, approval_list_id		NUMBER := NULL
, approval_list_name		VARCHAR2(10) := NULL
, approval_date			DATE := NULL
, approval_request_date		DATE := NULL
, responsible_organization_id	NUMBER := NULL
, project_id			NUMBER := NULL
, task_id 			NUMBER := NULL
, attribute_category		VARCHAR2(30) := NULL
, attribute1			VARCHAR2(150) := NULL
, attribute2			VARCHAR2(150) := NULL
, attribute3			VARCHAR2(150) := NULL
, attribute4                    VARCHAR2(150) := NULL
, attribute5                    VARCHAR2(150) := NULL
, attribute6               	VARCHAR2(150) := NULL
, attribute7                    VARCHAR2(150) := NULL
, attribute8                    VARCHAR2(150) := NULL
, attribute9                    VARCHAR2(150) := NULL
, attribute10                   VARCHAR2(150) := NULL
, attribute11                   VARCHAR2(150) := NULL
, attribute12                   VARCHAR2(150) := NULL
, attribute13                   VARCHAR2(150) := NULL
, attribute14                   VARCHAR2(150) := NULL
, attribute15                   VARCHAR2(150) := NULL
--, hierarchy_flag                NUMBER := NULL
, organization_hierarchy        VARCHAR2(30) := NULL
-- Added for Requirements: ECO form
, change_mgmt_type_code         VARCHAR2(30) := NULL
, hierarchy_id                  NUMBER := NULL
, change_id                     NUMBER := NULL
, PLM_OR_ERP_CHANGE             VARCHAR2(3) :=NULL --11.5.10 to differentiate between ERP/PLM records
);


-- Procedure Initialize_Record

PROCEDURE Initialize_Record
(   p_ECO_controller_rec        IN  Controller_Eco_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_ECO_controller_rec        IN OUT NOCOPY Controller_Eco_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

-- Procedure Validate_And_Write

PROCEDURE Validate_And_Write
(   p_ECO_controller_rec        IN  Controller_Eco_Rec_Type
,   p_control_rec		IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_ECO_controller_rec        IN OUT NOCOPY Controller_Eco_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

-- Procedure Delete_Row

PROCEDURE Delete_Row
(   p_ECO_controller_rec        IN  Controller_Eco_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

--Procedure Change_Attibute

PROCEDURE Change_Attribute
(   p_ECO_controller_rec        IN  Controller_Eco_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_ECO_controller_rec        IN OUT NOCOPY Controller_Eco_Rec_Type
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

END ECO_Controller;

 

/
