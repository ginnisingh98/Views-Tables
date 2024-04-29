--------------------------------------------------------
--  DDL for Package AHL_PP_RESRC_REQUIRE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PP_RESRC_REQUIRE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVREQS.pls 120.1.12010000.4 2009/05/07 10:41:53 bachandr ship $*/

---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
TYPE Resrc_Require_Rec_Type IS RECORD (
        OPERATION_RESOURCE_ID     NUMBER          ,
        RESOURCE_SEQ_NUMBER       NUMBER          ,
        OPERATION_SEQ_NUMBER      NUMBER          ,
--JKJAIN US space FP for ER # 6998882 -- start
 	    SCHEDULE_SEQ_NUM          NUMBER          ,
--JKJAIN US space FP for ER # 6998882 -- end
        WORKORDER_ID              NUMBER          ,
        JOB_NUMBER                VARCHAR2(80)    ,
        WIP_ENTITY_ID             NUMBER          ,
        WORKORDER_OPERATION_ID    NUMBER          ,
        ORGANIZATION_ID           NUMBER          ,

        DEPARTMENT_ID             NUMBER          ,
        DEPARTMENT_NAME           VARCHAR2(240)    ,

        RESOURCE_TYPE_CODE        NUMBER          ,
        RESOURCE_TYPE_NAME        VARCHAR2(80)    ,

        RESOURCE_ID               NUMBER          ,
        RESOURCE_NAME             VARCHAR2(80)    ,

        OPER_START_DATE           DATE            ,
        OPER_END_DATE             DATE            ,

        DURATION                  NUMBER          ,
        QUANTITY                  NUMBER          ,
        SET_UP                    NUMBER          ,

        UOM_CODE                  VARCHAR2(3)     ,
        UOM_NAME                  VARCHAR2(30)    ,

        COST_BASIS_CODE           NUMBER          ,
        COST_BASIS_NAME           VARCHAR2(80)    ,

        CHARGE_TYPE_CODE          NUMBER          ,
        CHARGE_TYPE_NAME          VARCHAR2(80)    ,

        SCHEDULED_TYPE_CODE       NUMBER          ,
        SCHEDULED_TYPE_NAME       VARCHAR2(80)    ,

        STD_RATE_FLAG_CODE        NUMBER          ,
        STD_RATE_FLAG_NAME        VARCHAR2(80)    ,

        TOTAL_REQUIRED            NUMBER          ,
        APPLIED_NUM               NUMBER          ,
        OPEN_NUM                  NUMBER          ,

        REQ_START_DATE            DATE            ,
        REQ_END_DATE              DATE            ,

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
        OPERATION_FLAG            VARCHAR2(1)					,
        IS_UNIT_LOCKED            VARCHAR2(1)
        );

TYPE Resrc_Require_Tbl_Type IS TABLE OF Resrc_Require_Rec_Type INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Process_Resrc_Require
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
--      x_return_status                 OUT     NOCOPY VARCHAR2               Required
--      x_msg_count                     OUT     NOCOPY NUMBER                 Required
--      x_msg_data                      OUT     NOCOPY VARCHAR2               Required
--
--  Process_Resrc_Require Parameters :
--  p_x_resrc_Require_tbl     IN OUT        Ahl_PP_Resrc_Require_Pvt.Resrc_Require_Tbl_Type,Required
--         List of Resource Requireed for a job
--

PROCEDURE Process_Resrc_Require (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_operation_flag         IN            VARCHAR2,
    p_interface_flag         IN            VARCHAR2,
    p_x_Resrc_Require_tbl    IN OUT NOCOPY AHL_PP_RESRC_Require_PVT.Resrc_Require_Tbl_Type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2

);

-- Fix for Bug # 8329755 (FP for Bug # 7697909) -- start
--------------------------------------------------------------------------------------------------
-- Procedure added for Bug # 8329755 (FP for Bug # 7697909)
-- This procedure expands Master Work Order scheduled dates such that there is enough space
-- for child work orders to expand and add resource requirement.
-- This process of expanding the work orders is needed only for Planned Work Order
-- due to the fact that scheduling for planned work orders is done by EAM, and EAM
-- does not take care of expanding Master work orders.
--------------------------------------------------------------------------------------------------
PROCEDURE Expand_Master_Wo_Dates(
    l_Resrc_Require_Rec  IN OUT NOCOPY Resrc_Require_Rec_Type
);
-- Fix for Bug # 8329755 (FP for Bug # 7697909) -- end

END AHL_PP_RESRC_REQUIRE_PVT;

/
