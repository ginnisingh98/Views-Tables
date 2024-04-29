--------------------------------------------------------
--  DDL for Package AMS_DM_SCORE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_SCORE_PVT" AUTHID CURRENT_USER as
/* $Header: amsvdmss.pls 115.18 2003/08/20 08:30:40 kbasavar ship $ */
-- Start of Comments
-- Package name     : AMS_DM_SCORE_PVT
-- Purpose          : PACKAGE SPECIFICATION FOR PRIVATE API
-- History          : 11/20  julou  created
-- 23-Jan-2001 choang   Added org_id to rec type
-- 12-Feb-2001 choang   1) Changed model_score to score. 2) added new columns.
-- 19-Feb-2001 choang   Replaced top_down_flag with row_selection_type.
-- 26-Feb-2001 choang   Added custom_setup_id and country_id.
-- 10-Mar-2001 choang   Added wf_itemkey, wf_revert(), process_score_status()
-- 11-Mar-2001 choang   Added handle_preview_request
-- 07-Apr-2001 choang   Added copy_score
-- 11-Apr-2001 choang   1) changed spec of wf_revert 2) added wf_score
-- 17-Aug-2001 choang   Added custom_setup_id in out param of create api.
-- 07-Jan-2002 choang   Removed security group id
-- 04-Oct-2002 choang   Added cancel_run_request
-- 20-Aug-2003 kbasavar Incresed the description size to 4000
--
--
--
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name: Score_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    score_ID
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--    OBJECT_VERSION_NUMBER
--    MODEL_ID
--    USER_STATUS_ID
--    STATUS_CODE
--    STATUS_DATE
--    OWNER_USER_ID
--    RESULTS_FLAG
--    logs_flag
--    scheduled_date
--    scheduled_timezone_id
--    score_date
--    expiration_date
--    total_records
--    total_positives
--    min_records
--    max_records
--    row_selection_type
--    every_nth_row
--    pct_random
--    custom_setup_id
--    country_id
--    wf_itemkey
--    score_name
--    description
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

TYPE Score_Rec_Type IS RECORD
(
   score_id               NUMBER := FND_API.G_MISS_NUM,
   last_update_date       DATE := FND_API.G_MISS_DATE,
   last_updated_by        NUMBER := FND_API.G_MISS_NUM,
   creation_date          DATE := FND_API.G_MISS_DATE,
   created_by             NUMBER := FND_API.G_MISS_NUM,
   last_update_login      NUMBER := FND_API.G_MISS_NUM,
   object_version_number  NUMBER := FND_API.G_MISS_NUM,
   org_id                 NUMBER := FND_API.G_MISS_NUM,
   model_id               NUMBER := FND_API.G_MISS_NUM,
   user_status_id         NUMBER := FND_API.G_MISS_NUM,
   status_code            VARCHAR2(30) := FND_API.G_MISS_CHAR,
   status_date            DATE := FND_API.G_MISS_DATE,
   owner_user_id          NUMBER := FND_API.G_MISS_NUM,
   results_flag           VARCHAR2(1) := FND_API.G_MISS_CHAR,
   logs_flag              VARCHAR2(1) := FND_API.G_MISS_CHAR,
   scheduled_date         DATE := FND_API.G_MISS_DATE,
   scheduled_timezone_id  NUMBER := FND_API.G_MISS_NUM,
   score_date             DATE := FND_API.G_MISS_DATE,
   expiration_date        DATE := FND_API.G_MISS_DATE,
   total_records          NUMBER := FND_API.G_MISS_NUM,
   total_positives        NUMBER := FND_API.G_MISS_NUM,
   min_records            NUMBER := FND_API.G_MISS_NUM,
   max_records            NUMBER := FND_API.G_MISS_NUM,
   row_selection_type     VARCHAR2(30) := FND_API.G_MISS_CHAR,
   every_nth_row          NUMBER := FND_API.G_MISS_NUM,
   pct_random             NUMBER := FND_API.G_MISS_NUM,
   custom_setup_id        NUMBER := FND_API.G_MISS_NUM,
   country_id             NUMBER := FND_API.G_MISS_NUM,
   wf_itemkey             VARCHAR2(240) := FND_API.G_MISS_CHAR,
   score_name             VARCHAR2(120) := FND_API.G_MISS_CHAR,
   description            VARCHAR2(4000) := FND_API.G_MISS_CHAR,
   attribute_category     VARCHAR2(30) := FND_API.G_MISS_CHAR,
   attribute1             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute2             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute3             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute4             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute5             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute6             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute7             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute8             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute9             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute10            VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute11            VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute12            VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute13            VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute14            VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute15            VARCHAR2(150) := FND_API.G_MISS_CHAR
);

G_MISS_Score_REC          Score_Rec_Type;
TYPE  DM_score_Tbl_Type      IS TABLE OF Score_Rec_Type INDEX BY BINARY_INTEGER;
G_MISS_Score_TBL          DM_score_Tbl_Type;


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

PROCEDURE Check_Score_Items (
    p_Score_rec     IN    Score_Rec_Type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Lock_Score
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_Score_Rec            IN   Score_Rec_Type  Required
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
PROCEDURE Lock_Score(
    p_api_version         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_score_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Score
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_Score_Rec            IN   Score_Rec_Type  Required
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
PROCEDURE Create_Score(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2     := FND_API.G_FALSE,
    p_commit            IN VARCHAR2     := FND_API.G_FALSE,
    p_validation_level  IN NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_Score_rec         IN Score_Rec_Type  := G_MISS_Score_REC,
    x_custom_setup_id   OUT NOCOPY NUMBER,
    x_score_id          OUT NOCOPY NUMBER
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Score
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_Score_Rec            IN   Score_Rec_Type  Required
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
PROCEDURE Update_Score(
    p_api_version         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_Score_rec               IN    Score_Rec_Type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Score
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_score_ID                IN   NUMBER
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
PROCEDURE Delete_Score(
    p_api_version         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_score_id             IN  NUMBER,
    p_object_version_number      IN   NUMBER
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

PROCEDURE Validate_Score_rec(
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_mode IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_Score_rec       IN Score_Rec_Type
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

PROCEDURE Validate_Score(
   p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_validation_mode    IN VARCHAR2,
   p_Score_rec          IN Score_Rec_Type,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
);


--
-- Purpose
--    Allow Workflow to revert the scoring run's status
--    to the original status with which the score started.
--
PROCEDURE wf_revert (
   p_score_id        IN NUMBER,
   p_status_code     IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


PROCEDURE process_score_success (
   p_score_id        IN NUMBER,
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
   p_score_id     IN NUMBER,
   x_request_id   OUT NOCOPY NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
);

-- History
-- 04-Oct-2002 nyostos   Created.
-- Overloaded procedure. New implementation in 11.5.9 to start
-- the Build/Score/Preview Workflow process to handle Preview instead of
-- starting the AMS_DM_PREVIEW concurrent program.

PROCEDURE handle_preview_request (
   p_score_id        IN NUMBER,
   x_monitor_url     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);

--
-- Purpose
--    Copy parameters of a scoring run.
-- Parameters
--    p_source_object_id - ID of the copy source.
--    p_attributes_table - table of attributes to indicate the different
--       attributes of the source object to copy.
--    p_copy_columns_table - table of column name and value pairs to
--       indicate the values to replace the respective columns.
--    x_new_object_id - ID for the newly created object.
--    x_custom_setup_id - ID of the custom setup which is associated to
--       the new object.  The ID is used by the UI to render the detail
--       page which follows a copy operation.
PROCEDURE copy_score (
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


--
-- Purpose
--    Validate model status and update scoring run status before
--    the actual scoring is executed.
-- Parameters
--    p_score_id - ID of the scoring run instance.
--    x_status_code - the status set for the scoring run.  If the scoring run
--          cannot be started, then the status is set to DRAFT, set the status
--          to SCORING, otherwise.
PROCEDURE wf_score (
   p_score_id        IN NUMBER,
   x_status_code     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);

-- History
-- 04-Oct-2002 nyostos   Created.
-- Cancels the Score workflow process. If the Scoring Run is in SCHEDULED.
-- state (i.e. the first step in the WF process has not started yet),
-- the Scoring Run status will be reverted to its previous status.
-- If the Scoring status is SCORING (i.e. the Workflow process is in progress),
-- then the Scoring Run status will be set to DRAFT.

PROCEDURE cancel_run_request (
   p_score_id           IN NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2
);

--
-- Purpose
--    Checks whether a model is still AVAILABLE for scoring
-- History
-- 09-Oct-2002 nyostos   Created.
PROCEDURE wf_checkModelStatus (
   p_score_id        IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_model_status    OUT NOCOPY VARCHAR2
);

--
-- Purpose
-- Procedure to handle data selection changes
-- This would INVALIDate a COMPLETED Scoring Run.
--
-- History
-- 14-Oct-2002 nyostos   Created.
PROCEDURE handle_data_selection_changes(
   p_score_id                 IN    NUMBER
);

End ams_dm_score_pvt;

 

/
