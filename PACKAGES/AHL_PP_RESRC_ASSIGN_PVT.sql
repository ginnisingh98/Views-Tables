--------------------------------------------------------
--  DDL for Package AHL_PP_RESRC_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PP_RESRC_ASSIGN_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVASGS.pls 120.2 2005/07/06 06:19:17 rroy noship $*/

---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
TYPE Resrc_Assign_Rec_Type IS RECORD (
        ASSIGNMENT_ID             NUMBER          ,
        WORKORDER_ID              NUMBER          ,
        WORKORDER_OPERATION_ID    NUMBER          ,

        WIP_ENTITY_ID             NUMBER          ,
        ORGANIZATION_ID           NUMBER          ,

        OPERATION_SEQ_NUMBER      NUMBER          ,
        RESOURCE_SEQ_NUMBER       NUMBER          ,

        RESOURCE_TYPE_CODE        NUMBER          ,
        RESOURCE_TYPE_NAME        VARCHAR2(80)    ,
        OPER_RESOURCE_ID          NUMBER          ,
        DEPARTMENT_ID             NUMBER          ,

        EMPLOYEE_ID               NUMBER          ,
        EMPLOYEE_NUMBER           VARCHAR2(30)    ,
        EMPLOYEE_NAME             VARCHAR2(240)   ,

        INVENTORY_ITEM_ID         NUMBER          ,
        ITEM_ORGANIZATION_ID      NUMBER          ,
        SERIAL_NUMBER             VARCHAR2(30)    ,
        INSTANCE_ID               NUMBER          ,

        ASSIGN_START_DATE         DATE            ,
        ASSIGN_START_HOUR         NUMBER          ,
        ASSIGN_START_MIN          NUMBER          ,
        ASSIGN_END_DATE           DATE            ,
        ASSIGN_END_HOUR           NUMBER          ,
        ASSIGN_END_MIN            NUMBER          ,

	       SELF_ASSIGNED_FLAG        VARCHAR2(1)     ,
 	      LOGIN_DATE                DATE            ,

        OBJECT_VERSION_NUMBER     NUMBER          ,
        SECURITY_GROUP_ID         NUMBER          ,
        LAST_UPDATE_LOGIN         NUMBER          ,
        LAST_UPDATED_DATE         DATE            ,
        LAST_UDDATED_BY           NUMBER          ,
        CREATION_DATE             DATE            ,
        CREATED_BY                NUMBER          ,
        ATTRIBUTE_CATEGORY        VARCHAR2(30)    ,
        ATTRIBUTE1                VARCHAR2(150)   ,
        ATTRIBUTE2                VARCHAR2(150)   ,
        ATTRIBUTE3                VARCHAR2(150)   ,
        ATTRIBUTE4                VARCHAR2(150)   ,
        ATTRIBUTE5                VARCHAR2(150)   ,
        ATTRIBUTE6                VARCHAR2(150)   ,
        ATTRIBUTE7                VARCHAR2(150)   ,
        ATTRIBUTE8                VARCHAR2(150)   ,
        ATTRIBUTE9                VARCHAR2(150)   ,
        ATTRIBUTE10               VARCHAR2(150)   ,
        ATTRIBUTE11               VARCHAR2(150)   ,
        ATTRIBUTE12               VARCHAR2(150)   ,
        ATTRIBUTE13               VARCHAR2(150)   ,
        ATTRIBUTE14               VARCHAR2(150)   ,
        ATTRIBUTE15               VARCHAR2(150)   ,
        OPERATION_FLAG            VARCHAR2(1)
        );

TYPE Resrc_Assign_Tbl_Type IS TABLE OF Resrc_Assign_Rec_Type INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Process_Resrc_Assign
--  Type        : Private
--  Function    : Manages Create/Modify/Delete material requirements for routine and
--                non routine operations associated to a job.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_Resrc_Assign Parameters :
--  p_x_resrc_assign_tbl     IN OUT        Ahl_PP_Resrc_Assign_Pvt.Resrc_Assign_Tbl_Type,Required
--         List of Resource Assigned for a job
--

PROCEDURE Process_Resrc_Assign (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_operation_flag         IN            VARCHAR2,
    p_x_resrc_assign_tbl     IN OUT NOCOPY AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Tbl_Type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2

);

END AHL_PP_RESRC_ASSIGN_PVT;

 

/
