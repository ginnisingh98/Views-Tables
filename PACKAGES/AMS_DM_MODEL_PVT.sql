--------------------------------------------------------
--  DDL for Package AMS_DM_MODEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_MODEL_PVT" AUTHID CURRENT_USER as
/* $Header: amsvdmms.pls 115.22 2002/12/09 11:07:09 choang noship $ */
-- Start of Comments
-- Package name     : AMS_DM_MODEL_PVT
-- Purpose          : PACKAGE SPECIFICATION FOR PRIVATE API
-- History          : 11/10/00  JIE LI  CREATED
-- 11/16/00    SVEERAVE@US    Commented defaulting of results_flag in dm_model_rec_type record,
--                            and defaulted with FND_G_MISS_CHAR
-- 21-Jan-2001 choang         Added target_field, target_type, target_value, use_weights_fla
--                            to record delcaration.
-- 02-Feb-2001 choang         Added new columns.
-- 16-Feb-2001 choang         Replaced top_down_flag with row_selection_type.
-- 21-Feb-2001 choang         Added validation_mode to validate_rec.
-- 26-Feb-2001 choang         Added custom_setup_id, country_id and best_subtree.
-- 06-Mar-2001 choang         Added expire_models for oncurrent processing.
-- 08-Mar-2001 choang         1) Added wf_revert. 2) Added wf_itemkey to rec type. 3) Added
--                            process_build_success. 4) added unexpire_model
-- 11-Mar-2001 choang         Added handle_preview_request
-- 05-Apr-2001 choang         Added copy_model
-- 11-Apr-2001 choang         1) changed spec of wf_revert 2) added wf_build
-- 17-Aug-2001 choang         Added custom_setup_id in out param of create api.
-- 07-Jan-2002 choang         removed security group id
-- 24-Apr-2002 choang         Added target_id
-- 23-Sep-2002 nyostos        Added handle_preview_request that takes two parameters only.
-- NOTE             :
-- End of Comments


-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:DM_MODEL_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    MODEL_ID
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--    ORG_ID
--    OBJECT_VERSION_NUMBER
--    MODEL_TYPE
--    USER_STATUS_ID
--    STATUS_CODE
--    STATUS_DATE
--    OWNER_USER_ID
--    LAST_BUILD_DATE
--    SCHEDULED_DATE
--    SCHEDULED_TIMEZONE_ID
--    EXPIRATION_DATE
--    RESULTS_FLAG
--    LOGS_FLAG
--    TARGET_FIELD
--    TARGET_TYPE
--    TARGET_POSITIVE_VALUE
--    TOTAL_RECORDS
--    TOTAL_POSITIVES
--    MIN_RECORDS
--    MAX_RECORDS
--    row_selection_type
--    EVERY_NTH_ROW
--    PCT_RANDOM
--    PERFORMANCE
--    TARGET_GROUP_TYPE
--    DARWIN_MODEL_REF
--    model_name
--    description
--    best_subtree
--    custom_setup_id
--    country_id
--    wf_itemkey
--    target_id
--    ATTRIBUTE_CATEGORY
--    ATTRIBUTE1
--    ATTRIBUTE2
--    ATTRIBUTE3
--    ATTRIBUTE4
--    ATTRIBUTE5
--    ATTRIBUTE6
--    ATTRIBUTE7
--    ATTRIBUTE8
--    ATTRIBUTE9
--    ATTRIBUTE10
--    ATTRIBUTE11
--    ATTRIBUTE12
--    ATTRIBUTE13
--    ATTRIBUTE14
--    ATTRIBUTE15
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE DM_MODEL_Rec_Type IS RECORD
(
   MODEL_ID                NUMBER := FND_API.G_MISS_NUM,
   LAST_UPDATE_DATE        DATE := FND_API.G_MISS_DATE,
   LAST_UPDATED_BY         NUMBER := FND_API.G_MISS_NUM,
   CREATION_DATE           DATE := FND_API.G_MISS_DATE,
   CREATED_BY              NUMBER := FND_API.G_MISS_NUM,
   LAST_UPDATE_LOGIN       NUMBER := FND_API.G_MISS_NUM,
   ORG_ID                  NUMBER := FND_API.G_MISS_NUM,
   OBJECT_VERSION_NUMBER   NUMBER := FND_API.G_MISS_NUM,
   MODEL_TYPE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
   USER_STATUS_ID          NUMBER := FND_API.G_MISS_NUM,
   STATUS_CODE             VARCHAR2(30) := FND_API.G_MISS_CHAR,
   STATUS_DATE             DATE := FND_API.G_MISS_DATE,
   OWNER_USER_ID           NUMBER := FND_API.G_MISS_NUM,
   LAST_BUILD_DATE         DATE := FND_API.G_MISS_DATE,
   SCHEDULED_DATE          DATE := FND_API.G_MISS_DATE,
   SCHEDULED_TIMEZONE_ID   NUMBER := FND_API.G_MISS_NUM,
   EXPIRATION_DATE         DATE := FND_API.G_MISS_DATE,
   RESULTS_FLAG            VARCHAR2(1) := FND_API.G_MISS_CHAR,
   LOGS_FLAG               VARCHAR2(1) := FND_API.G_MISS_CHAR,
   TARGET_FIELD            VARCHAR2(30) := FND_API.G_MISS_CHAR,
   TARGET_TYPE             VARCHAR2(30) := FND_API.G_MISS_CHAR,
   TARGET_POSITIVE_VALUE   VARCHAR2(30) := FND_API.G_MISS_CHAR,
   TOTAL_RECORDS           NUMBER := FND_API.G_MISS_NUM,
   TOTAL_POSITIVES         NUMBER := FND_API.G_MISS_NUM,
   MIN_RECORDS             NUMBER := FND_API.G_MISS_NUM,
   MAX_RECORDS             NUMBER := FND_API.G_MISS_NUM,
   row_selection_type      VARCHAR2(30) := FND_API.G_MISS_CHAR,
   EVERY_NTH_ROW           NUMBER := FND_API.G_MISS_NUM,
   PCT_RANDOM              NUMBER := FND_API.G_MISS_NUM,
   PERFORMANCE             NUMBER := FND_API.G_MISS_NUM,
   TARGET_GROUP_TYPE       VARCHAR2(30) := FND_API.G_MISS_CHAR,
   DARWIN_MODEL_REF        VARCHAR2(4000) := FND_API.G_MISS_CHAR,
   model_name              VARCHAR2(120) := FND_API.G_MISS_CHAR,
   description             VARCHAR2(4000) := FND_API.G_MISS_CHAR,
   best_subtree            NUMBER := FND_API.G_MISS_NUM,
   custom_setup_id         NUMBER := FND_API.G_MISS_NUM,
   country_id              NUMBER := FND_API.G_MISS_NUM,
   wf_itemkey              VARCHAR2(240) := FND_API.G_MISS_CHAR,
   target_id               NUMBER := FND_API.G_MISS_NUM,
   ATTRIBUTE_CATEGORY      VARCHAR2(30) := FND_API.G_MISS_CHAR,
   ATTRIBUTE1              VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE2              VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE3              VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE4              VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE5              VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE6              VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE7              VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE8              VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE9              VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE10             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE11             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE12             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE13             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE14             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   ATTRIBUTE15             VARCHAR2(150) := FND_API.G_MISS_CHAR
);

G_MISS_DM_MODEL_REC          DM_MODEL_Rec_Type;
TYPE  DM_MODEL_Tbl_Type      IS TABLE OF DM_MODEL_Rec_Type INDEX BY BINARY_INTEGER;
G_MISS_DM_MODEL_TBL          DM_MODEL_Tbl_Type;


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
-- End of Comments

PROCEDURE Check_DM_MODEL_Items (
    P_DM_MODEL_Rec     IN    DM_MODEL_Rec_Type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Lock_dm_model
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_DM_MODEL_Rec            IN   DM_MODEL_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Lock_dm_model(
    P_Api_Version_Number   IN   NUMBER,
    P_Init_Msg_List        IN   VARCHAR2     := FND_API.G_FALSE,

    X_Return_Status        OUT NOCOPY  VARCHAR2,
    X_Msg_Count            OUT NOCOPY  NUMBER,
    X_Msg_Data             OUT NOCOPY  VARCHAR2,

    p_MODEL_ID             IN  NUMBER,
    p_object_version       IN  NUMBER
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_dm_model
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_DM_MODEL_Rec            IN   DM_MODEL_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_dm_model(
    P_Api_Version_Number   IN   NUMBER,
    P_Init_Msg_List        IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit               IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level     IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status        OUT NOCOPY  VARCHAR2,
    X_Msg_Count            OUT NOCOPY  NUMBER,
    X_Msg_Data             OUT NOCOPY  VARCHAR2,

    P_DM_MODEL_Rec         IN   DM_MODEL_Rec_Type  := G_MISS_DM_MODEL_REC,
    x_custom_setup_id      OUT NOCOPY NUMBER,
    X_MODEL_ID             OUT NOCOPY  NUMBER
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_dm_model
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_DM_MODEL_Rec            IN   DM_MODEL_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Update_dm_model(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                  IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level        IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2,

    P_DM_MODEL_Rec            IN    DM_MODEL_Rec_Type,
    X_Object_Version_Number   OUT NOCOPY  NUMBER
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_dm_model
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_MODEL_ID                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Delete_dm_model(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                  IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2,
    P_MODEL_ID                IN  NUMBER,
    P_Object_Version_Number   IN   NUMBER
);


-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_DM_MODEL_rec(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_mode            IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_DM_MODEL_Rec               IN    DM_MODEL_Rec_Type
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_dm_model(
    P_Api_Version_Number   IN   NUMBER,
    P_Init_Msg_List        IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode      IN   VARCHAR2,
    P_DM_MODEL_Rec         IN   DM_MODEL_Rec_Type,
    X_Return_Status        OUT NOCOPY  VARCHAR2,
    X_Msg_Count            OUT NOCOPY  NUMBER,
    X_Msg_Data             OUT NOCOPY  VARCHAR2
);

PROCEDURE Validate_next_status(
    p_curr_status          IN   VARCHAR2,
    p_next_status          IN   VARCHAR2,
    p_system_status_type   IN   VARCHAR2,
    p_init_msg_list        IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2);


--
-- Purpose
--    Expires models which have reached the specified
--    expiration date.
--
PROCEDURE expire_models (
   errbuf      OUT NOCOPY VARCHAR2,
   retcode     OUT NOCOPY VARCHAR2
);


--
-- Purpose
--    Reverts status and resets the scheduled date
--    if Workflow fails.
--
PROCEDURE wf_revert (
   p_model_id        IN NUMBER,
   p_status_code     IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


--
-- Purpose
--    Un-expire the model and make it available for use.
--
PROCEDURE unexpire_model (
   p_model_id        IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
);


--
-- Purpose
--    Process a success message
--
PROCEDURE process_build_success (
   p_model_id        IN NUMBER,
   p_status_code     IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


--
-- Purpose
--    Submit a concurrent request to initiate the preview process
--
-- Parameters
--    p_model_id        - ID of the model to preview
--    x_request_id      - ID of the concurrent request
--    x_return_status   - standard return status
--
PROCEDURE handle_preview_request (
   p_model_id     IN NUMBER,
   x_request_id   OUT NOCOPY NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
);

-- History
-- 23-Sep-2002 nyostos   Created.
-- Overloaded procedure. New implementation in 11.5.9 to start
-- the Build/Score/Preview Workflow process to handle Preview instead of
-- starting the AMS_DM_PREVIEW concurrent program.

PROCEDURE handle_preview_request (
   p_model_id        IN NUMBER,
   x_monitor_url     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


PROCEDURE copy_model (
   p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_source_object_id   IN NUMBER,
   p_attributes_table   IN AMS_CpyUtility_PVT.copy_attributes_table_type,
   p_copy_columns_table IN AMS_CpyUtility_PVT.copy_columns_table_type,
   x_new_object_id      OUT NOCOPY NUMBER,
   x_custom_setup_id    OUT NOCOPY NUMBER
);


PROCEDURE wf_build (
   p_model_id        IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
);

PROCEDURE cancel_build_request (
   p_model_id           IN NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2
);

--
-- Purpose
-- Procedure to handle data selection changes
-- This would INVALIDate a AVAILABLE Model.
--
-- History
-- 14-Oct-2002 nyostos   Created.
PROCEDURE handle_data_selection_changes(
   p_model_id                 IN    NUMBER
);

--
-- Purpose
-- Procedure to handle data source changes
-- This would INVALIDate a AVAILABLE Model.
--
-- History
-- 14-Oct-2002 nyostos   Created.
PROCEDURE handle_data_source_changes(
   p_datasource_id            IN    NUMBER
);

--
-- Purpose
-- To check if Model is using a Seeded data source.
--
-- History
-- 23-Sep-2002 nyostos   Created.
PROCEDURE seededDataSource(
   p_model_id     IN    NUMBER,
   x_seeded_flag  OUT NOCOPY   VARCHAR2
);

End AMS_DM_MODEL_PVT;

 

/
