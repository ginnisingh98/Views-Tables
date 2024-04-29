--------------------------------------------------------
--  DDL for Package AHL_UMP_SMRINSTANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_SMRINSTANCE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVSMRS.pls 120.1.12010000.2 2008/12/27 17:57:39 sracha ship $ */




---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
--------------------------------------------------------------------
TYPE Search_MRInstance_Rec_Type IS RECORD (
        UNIT_NAME               VARCHAR2(80),
        PART_NUMBER             VARCHAR2(40),
        SERIAL_NUMBER           VARCHAR2(30),
        SORT_BY                 VARCHAR2(30),
        MR_STATUS               VARCHAR2(30),
        MR_TITLE                VARCHAR2(80),
        PROGRAM_TYPE            VARCHAR2(80),
        DUE_FROM                DATE,
        DUE_TO                  DATE,
        SHOW_TOLERANCE          VARCHAR2(1),
        COMPONENTS_FLAG         VARCHAR2(1),
        REPETITIVE_FLAG         VARCHAR2(1),
        CONTRACT_NUMBER         VARCHAR2(120),
        CONTRACT_MODIFIER       VARCHAR2(120),
        SERVICE_LINE_ID         NUMBER,
        SERVICE_LINE_NUM        VARCHAR2(150),
        PROGRAM_ID              NUMBER,
        PROGRAM_TITLE           VARCHAR2(80),
        SHOW_GROUPMR            VARCHAR2(1),
        OBJECT_TYPE             VARCHAR2(3),
        SEARCH_FOR_TYPE         VARCHAR2(30),
        --amsriniv ER 6116245
        VISIT_NUMBER            VARCHAR2(30),
        VISIT_ORG_NAME          VARCHAR2(240),
        VISIT_DEPT_NAME         VARCHAR2(240),
        --amsriniv ER 6116245
        --start changes for bug# 7562008
        INCIDENT_TYPE_ID        NUMBER,
        SERVICE_REQ_NUM         cs_incidents_all_b.incident_number%TYPE
        --end changes for bug# 7562008
        );

TYPE Results_MRInstance_Rec_Type IS RECORD (
        PROGRAM_TYPE_MEANING    VARCHAR2(80),
        MR_TITLE                VARCHAR2(80),
        PART_NUMBER             VARCHAR2(40),
        SERIAL_NUMBER           VARCHAR2(30),
        UOM_REMAIN              NUMBER,
        COUNTER_NAME            VARCHAR2(30),
        EARLIEST_DUE_DATE       DATE,
        DUE_DATE                DATE,
        LATEST_DUE_DATE         DATE,
        TOLERANCE_FLAG          VARCHAR2(30),
        UMR_STATUS_CODE         VARCHAR2(30),
        UMR_STATUS_MEANING      VARCHAR2(80),
        SCHEDULED_DATE          DATE,
        VISIT_NUMBER            VARCHAR2(80),
        VISIT_STATUS            VARCHAR2(80),
        ASSIGN_STATUS           VARCHAR2(80),
	    SERVICE_REQ_ID          NUMBER,
        SERVICE_REQ_NUM         VARCHAR2(64),
	    SERVICE_REQ_DATE        DATE,
        ORIGINATOR_TITLE        VARCHAR2(80),
        DEPENDANT_TITLE         VARCHAR2(80),
        UNIT_EFFECTIVITY_ID     NUMBER,
        MR_ID                   NUMBER,
        CSI_ITEM_INSTANCE_ID    NUMBER,
        INSTANCE_NUMBER         VARCHAR2(30),
        MR_INTERVAL_ID          NUMBER,
        UNIT_NAME               VARCHAR2(4000),
        PROGRAM_TITLE           VARCHAR2(80),
        CONTRACT_NUMBER         VARCHAR2(120),
        DEFER_FROM_UE_ID        NUMBER,
        DEFER_TO_UE_ID          NUMBER,
        UNIT_EFFECTIVITY_TYPE   VARCHAR2(30),
        OBJECT_TYPE             VARCHAR2(3),
        MANUALLY_PLANNED_FLAG    VARCHAR2(30),
        MANUALLY_PLANNED_DESC    VARCHAR2(80),
	VISIT_ID                NUMBER  --PDOKI Added for ER# 6333770

        );


----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE Results_MRInstance_Tbl_Type IS TABLE OF Results_MRInstance_Rec_Type INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------
--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Search_MR_Instances
--  Type              : Private
--  Function          : This procedure fetches all the MR Instances based both at the instance level
--                      and the item level for the given search criteria.
--  Pre-reqs          :
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2                    Default  FND_API.G_TRUE
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   IN      VARCHAR2                    Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  Search_MR_Instances Parameters :
--      p_start_row                     IN      NUMBER                      Required
--         The row from which the search results table should be displayed.
--      p_rows_per_page                 IN      NUMBER                      Required
--         The number of rows to be displayed per page.
--      p_search_mr_instance_rec        IN      Search_MRInstance_Rec_Type  Required
--         The search criteria based on which the query needs to be run to
--         return the MR Instances.
--      x_results_mr_instance_tbl       OUT     Results_MRInstance_Tbl_Type Required
--         List of all the MR Instances which match the search criteria entered.
--      x_results_count                 OUT     NUMBER                      Required
--         The total count of the results returned from the entered search criteria.
--
--
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

   PROCEDURE Search_MR_Instances
      (
        p_api_version                   IN            NUMBER,
        p_init_msg_list                 IN            VARCHAR2  := FND_API.G_FALSE,
        p_commit                        IN            VARCHAR2  := FND_API.G_FALSE,
        p_validation_level              IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_default                       IN            VARCHAR2  := FND_API.G_TRUE,
        p_module_type                   IN            VARCHAR2  := NULL,
        p_start_row                     IN            NUMBER,
        p_rows_per_page                 IN            NUMBER,
        p_search_mr_instance_rec        IN            AHL_UMP_SMRINSTANCE_PVT.Search_MRInstance_Rec_Type,
        x_results_mr_instance_tbl       OUT NOCOPY    AHL_UMP_SMRINSTANCE_PVT.Results_MRInstance_Tbl_Type,
        x_results_count                 OUT NOCOPY    NUMBER,
        x_return_status                 OUT NOCOPY    VARCHAR2,
        x_msg_count                     OUT NOCOPY    NUMBER,
        x_msg_data                      OUT NOCOPY    VARCHAR2
      );



END AHL_UMP_SMRINSTANCE_PVT; -- Package spec

/
