--------------------------------------------------------
--  DDL for Package AHL_PRD_DF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_DF_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPDFS.pls 120.2.12010000.2 2010/03/26 12:17:53 psalgia ship $ */

  -- Operation on a deferral record than this API can handle
  G_OP_CREATE        CONSTANT  VARCHAR2(1) := 'C';
  G_OP_UPDATE        CONSTANT  VARCHAR2(1) := 'U';
  G_OP_DELETE        CONSTANT  VARCHAR2(1) := 'D';
  G_OP_SUBMIT        CONSTANT  VARCHAR2(1) := 'S';
  -- Yes/no flags
  G_YES_FLAG         CONSTANT  VARCHAR2(1) := 'Y';
  G_NO_FLAG          CONSTANT  VARCHAR2(1) := 'N';
  -- Other constants
  G_REASON_CODE_DELIM CONSTANT VARCHAR2(1) := ':';
  G_DEFERRAL_TYPE_MR  CONSTANT VARCHAR2(2) := 'MR';
  G_DEFERRAL_TYPE_SR  CONSTANT VARCHAR2(2) := 'SR';
  G_DEFER_BY          CONSTANT VARCHAR2(30):= 'DEFER_BY';
  G_DEFER_TO          CONSTANT VARCHAR2(30):= 'DEFER_TO';

  G_WORKFLOW_OBJECT_KEY CONSTANT VARCHAR2(30) := 'PRDWF';
---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
TYPE df_header_rec_type IS RECORD (
        UNIT_DEFERRAL_ID        NUMBER,
        OBJECT_VERSION_NUMBER   NUMBER,
        CREATED_BY              NUMBER,
        CREATION_DATE           DATE,
        LAST_UPDATED_BY         NUMBER,
        LAST_UPDATE_DATE        DATE,
        LAST_UPDATE_LOGIN       NUMBER,
        UNIT_EFFECTIVITY_ID     NUMBER,
        UNIT_DEFERRAL_TYPE      VARCHAR2(30),
        APPROVAL_STATUS_CODE    VARCHAR2(30),
        DEFER_REASON_CODE		VARCHAR2(240),
        REMARKS                 VARCHAR2(4000),
        APPROVER_NOTES          VARCHAR2(4000),
        SKIP_MR_FLAG            VARCHAR2(1),
        AFFECT_DUE_CALC_FLAG    VARCHAR2(1),
        SET_DUE_DATE         	DATE,
        DEFERRAL_EFFECTIVE_ON 	DATE,
        DEFERRAL_TYPE           VARCHAR2(2),
        MR_REPETITIVE_FLAG      VARCHAR2(1),
        MANUALLY_PLANNED_FLAG   VARCHAR2(1),
        RESET_COUNTER_FLAG      VARCHAR2(1),
        OPERATION_FLAG          VARCHAR2(1),
        ATTRIBUTE_CATEGORY      VARCHAR2(30),
        ATTRIBUTE1              VARCHAR2(150),
        ATTRIBUTE2              VARCHAR2(150),
        ATTRIBUTE3              VARCHAR2(150),
        ATTRIBUTE4              VARCHAR2(150),
        ATTRIBUTE5              VARCHAR2(150),
        ATTRIBUTE6              VARCHAR2(150),
        ATTRIBUTE7              VARCHAR2(150),
        ATTRIBUTE8              VARCHAR2(150),
        ATTRIBUTE9              VARCHAR2(150),
        ATTRIBUTE10             VARCHAR2(150),
        ATTRIBUTE11             VARCHAR2(150),
        ATTRIBUTE12             VARCHAR2(150),
        ATTRIBUTE13             VARCHAR2(150),
        ATTRIBUTE14             VARCHAR2(150),
        ATTRIBUTE15             VARCHAR2(150),
        USER_DEFERRAL_TYPE_CODE VARCHAR2(30)
        );

TYPE df_header_info_rec_type IS RECORD (
        UNIT_DEFERRAL_ID        NUMBER,
        OBJECT_VERSION_NUMBER   NUMBER,
        UNIT_EFFECTIVITY_ID     NUMBER,
        APPROVAL_STATUS_CODE    VARCHAR2(30),
        APPROVAL_STATUS_MEANING    VARCHAR2(80),
        DEFER_REASON_CODE		VARCHAR2(240),
        REMARKS                 VARCHAR2(4000),
        APPROVER_NOTES          VARCHAR2(4000),
        SKIP_MR_FLAG            VARCHAR2(1),
        AFFECT_DUE_CALC_FLAG    VARCHAR2(1),
        SET_DUE_DATE         	DATE,
        DEFERRAL_EFFECTIVE_ON 	DATE,
        DEFERRAL_TYPE           VARCHAR2(2),
        MR_HEADER_ID            NUMBER,
        MR_TITLE                VARCHAR2(80),
        MR_DESCRIPTION          VARCHAR2(2000),
        INCIDENT_ID             NUMBER,
        INCIDENT_NUMBER         VARCHAR2(64),
        SUMMARY                 VARCHAR2(240),
        DUE_DATE                DATE,
        UE_STATUS_CODE             VARCHAR2(30),
        UE_STATUS_MEANING          VARCHAR2(80),
        VISIT_ID                NUMBER,
        VISIT_NUMBER            number(15),
        MR_REPETITIVE_FLAG      VARCHAR2(1),
        RESET_COUNTER_FLAG      VARCHAR2(1),
        MANUALLY_PLANNED_FLAG   VARCHAR2(1),
        USER_DEFERRAL_TYPE_CODE VARCHAR2(30),
        USER_DEFERRAL_TYPE_MEAN VARCHAR2(80),
	/*manisaga: added attributes for DFF Enablement on 19-Jan-2010--start*/
        ATTRIBUTE_CATEGORY VARCHAR2(30),
        ATTRIBUTE1 VARCHAR2(150),
        ATTRIBUTE2 VARCHAR2(150),
        ATTRIBUTE3 VARCHAR2(150),
        ATTRIBUTE4 VARCHAR2(150),
        ATTRIBUTE5 VARCHAR2(150),
        ATTRIBUTE6 VARCHAR2(150),
        ATTRIBUTE7 VARCHAR2(150),
        ATTRIBUTE8 VARCHAR2(150),
        ATTRIBUTE9 VARCHAR2(150),
        ATTRIBUTE10 VARCHAR2(150),
        ATTRIBUTE11 VARCHAR2(150),
        ATTRIBUTE12 VARCHAR2(150),
        ATTRIBUTE13 VARCHAR2(150),
        ATTRIBUTE14 VARCHAR2(150),
        ATTRIBUTE15 VARCHAR2(150)
        /*manisaga: added attributes for DFF Enablement on 19-Jan-2010--end     */

        );

TYPE df_schedules_rec_type IS RECORD (
        UNIT_THRESHOLD_ID            NUMBER,
        OBJECT_VERSION_NUMBER   NUMBER,
        CREATED_BY              NUMBER,
        CREATION_DATE           DATE,
        LAST_UPDATED_BY         NUMBER,
        LAST_UPDATE_DATE        DATE,
        LAST_UPDATE_LOGIN       NUMBER,
        UNIT_DEFERRAL_ID        NUMBER,
        COUNTER_ID              NUMBER,
        COUNTER_NAME            VARCHAR2(30),
        COUNTER_VALUE           NUMBER,
        CTR_VALUE_TYPE_CODE     VARCHAR2(30),
        UNIT_OF_MEASURE         VARCHAR2(25),
        OPERATION_FLAG          VARCHAR2(1),
        ATTRIBUTE_CATEGORY      VARCHAR2(30),
        ATTRIBUTE1              VARCHAR2(150),
        ATTRIBUTE2              VARCHAR2(150),
        ATTRIBUTE3              VARCHAR2(150),
        ATTRIBUTE4              VARCHAR2(150),
        ATTRIBUTE5              VARCHAR2(150),
        ATTRIBUTE6              VARCHAR2(150),
        ATTRIBUTE7              VARCHAR2(150),
        ATTRIBUTE8              VARCHAR2(150),
        ATTRIBUTE9              VARCHAR2(150),
        ATTRIBUTE10             VARCHAR2(150),
        ATTRIBUTE11             VARCHAR2(150),
        ATTRIBUTE12             VARCHAR2(150),
        ATTRIBUTE13             VARCHAR2(150),
        ATTRIBUTE14             VARCHAR2(150),
        ATTRIBUTE15             VARCHAR2(150)
        );


----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE df_schedules_tbl_type IS TABLE OF df_schedules_rec_type INDEX BY BINARY_INTEGER;


-- ------------------------------------------------------------------------------------------------
--  Procedure name    : process_deferral
--  Type              : private
--  Function          :
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--
--      This parameter indicates the front-end form interface. The default value is 'JSP'. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values based
--      on which the Id's are populated.
--
--  process_deferral Parameters:
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE process_deferral(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := NULL,
    p_x_df_header_rec       IN OUT NOCOPY  AHL_PRD_DF_PVT.df_header_rec_type,
    p_x_df_schedules_tbl    IN OUT NOCOPY  AHL_PRD_DF_PVT.df_schedules_tbl_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2);


-------------------------------------------------------------------------
-- Procedure to get deferral details attached to any uinit effectivity --
--------------------------------------------------------------------------
PROCEDURE get_deferral_details (

    p_init_msg_list          IN          VARCHAR2  := FND_API.G_FALSE,
    p_unit_effectivity_id    IN          NUMBER,
	x_df_header_info_rec     OUT NOCOPY  AHL_PRD_DF_PVT.df_header_info_rec_type,
    x_df_schedules_tbl       OUT NOCOPY  AHL_PRD_DF_PVT.df_schedules_tbl_type,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2);
-------------------------------------------------------------------------
-- Procedure to take action once deferral is approved. --
--------------------------------------------------------------------------
PROCEDURE process_approval_approved (

    p_unit_deferral_id      IN             NUMBER,
    p_object_version_number IN             NUMBER,
    p_new_status            IN             VARCHAR2,
    x_return_status         OUT NOCOPY     VARCHAR2

);
-------------------------------------------------------------------------
-- Procedure to take action once deferral is rejected --
--------------------------------------------------------------------------
PROCEDURE process_approval_rejected (

    p_unit_deferral_id      IN             NUMBER,
    p_object_version_number IN             NUMBER,
    p_new_status            IN             VARCHAR2,
    x_return_status         OUT NOCOPY     VARCHAR2
);

-------------------------------------------------------------------------
-- Procedure to initiate deferral --
--------------------------------------------------------------------------
PROCEDURE process_approval_initiated (
    p_unit_deferral_id      IN             NUMBER,
    p_object_version_number IN             NUMBER,
    p_new_status            IN             VARCHAR2,
    x_return_status         OUT NOCOPY     VARCHAR2);

---------------------------------------------------------------------------
--- Clean up data after exception deleting
---------------------------------------------------------------------------
FUNCTION process_deferred_exceptions(p_unit_effectivity_id IN NUMBER) RETURN BOOLEAN;
---------------------------------------------------------------------------

END AHL_PRD_DF_PVT; -- Package spec

/
