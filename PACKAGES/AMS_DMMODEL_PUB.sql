--------------------------------------------------------
--  DDL for Package AMS_DMMODEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DMMODEL_PUB" AUTHID CURRENT_USER AS
/* $Header: amspdmms.pls 115.8 2002/12/17 04:12:58 choang noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DMModel_PUB
-- Purpose
--
-- History
-- 02-Feb-2001 choang   Added new columns.
-- 16-Feb-2001 choang   Replaced top_down_flag with row_selection_type.
-- 20-Feb-2001 choang   Changed row_selection_type to varchar2(30).
-- 26-Feb-2001 choang   Added custom_setup_id, country_id, and best_subtree.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             model_rec_type
--   -------------------------------------------------------
--   Parameters:
--    ROW_ID
--    MODEL_ID
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--    OBJECT_VERSION_NUMBER
--    MODEL_TYPE
--    USER_STATUS_ID
--    STATUS_CODE
--    STATUS_DATE
--    LAST_BUILD_DATE
--    OWNER_USER_ID
--    SCHEDULED_DATE
--    SCHEDULED_TIMEZONE_ID
--    EXPIRATION_DATE
--    custom_setup_id
--    country_id
--    best_subtree
--    RESULTS_FLAG
--    LOGS_FLAG
--    TARGET_FIELD
--    TARGET_TYPE
--    TARGET_POSITIVE_VALUE
--    MIN_RECORDS
--    MAX_RECORDS
--    row_selection_type
--    EVERY_NTH_ROW
--    PCT_RANDOM
--    PERFORMANCE
--    TARGET_GROUP_TYPE
--    DARWIN_MODEL_REF
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
--    MODEL_NAME
--    DESCRIPTION
--
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE model_rec_type IS RECORD
(
   ROW_ID                  ROWID := FND_API.G_MISS_CHAR,
   MODEL_ID                NUMBER := FND_API.G_MISS_NUM,
   LAST_UPDATE_DATE        DATE := FND_API.G_MISS_DATE,
   LAST_UPDATED_BY         NUMBER := FND_API.G_MISS_NUM,
   CREATION_DATE           DATE := FND_API.G_MISS_DATE,
   CREATED_BY              NUMBER := FND_API.G_MISS_NUM,
   LAST_UPDATE_LOGIN       NUMBER := FND_API.G_MISS_NUM,
   OBJECT_VERSION_NUMBER   NUMBER := FND_API.G_MISS_NUM,
   org_id                  NUMBER := FND_API.G_MISS_NUM,
   MODEL_TYPE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
   USER_STATUS_ID          NUMBER := FND_API.G_MISS_NUM,
   STATUS_CODE             VARCHAR2(30) := FND_API.G_MISS_CHAR,
   STATUS_DATE             DATE := FND_API.G_MISS_DATE,
   LAST_BUILD_DATE         DATE := FND_API.G_MISS_DATE,
   OWNER_USER_ID           NUMBER := FND_API.G_MISS_NUM,
   SCHEDULED_DATE          DATE := FND_API.G_MISS_DATE,
   SCHEDULED_TIMEZONE_ID   NUMBER := FND_API.G_MISS_NUM,
   EXPIRATION_DATE         DATE := FND_API.G_MISS_DATE,
   custom_setup_id         NUMBER := FND_API.G_MISS_NUM,
   country_id              NUMBER := FND_API.G_MISS_NUM,
   best_subtree            NUMBER := FND_API.G_MISS_NUM,
   RESULTS_FLAG            VARCHAR2(1) := FND_API.G_MISS_CHAR,
   LOGS_FLAG               VARCHAR2(1) := FND_API.G_MISS_CHAR,
   TARGET_FIELD            VARCHAR2(30) := FND_API.G_MISS_CHAR,
   TARGET_TYPE             VARCHAR2(30) := FND_API.G_MISS_CHAR,
   TARGET_POSITIVE_VALUE   VARCHAR2(30) := FND_API.G_MISS_CHAR,
   MIN_RECORDS             NUMBER := FND_API.G_MISS_NUM,
   MAX_RECORDS             NUMBER := FND_API.G_MISS_NUM,
   row_selection_type      VARCHAR2(30) := FND_API.G_MISS_CHAR,
   EVERY_NTH_ROW           NUMBER := FND_API.G_MISS_NUM,
   PCT_RANDOM              NUMBER := FND_API.G_MISS_NUM,
   PERFORMANCE             NUMBER := FND_API.G_MISS_NUM,
   TARGET_GROUP_TYPE       VARCHAR2(30) := FND_API.G_MISS_CHAR,
   DARWIN_MODEL_REF        VARCHAR2(4000) := FND_API.G_MISS_CHAR,
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
   ATTRIBUTE15             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   MODEL_NAME              VARCHAR2(120) := FND_API.G_MISS_CHAR,
   DESCRIPTION             VARCHAR2(4000) := FND_API.G_MISS_CHAR
);

g_miss_model_rec          model_rec_type;
TYPE  model_tbl_type      IS TABLE OF model_rec_type INDEX BY BINARY_INTEGER;
g_miss_model_tbl          model_tbl_type;

TYPE model_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      model_id   NUMBER := NULL
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Model
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_model_rec            IN   model_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Create_Model(
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit               IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,

    p_model_rec            IN   model_rec_type  := g_miss_model_rec,
    x_model_id             OUT NOCOPY  NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Model
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_model_rec            IN   model_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Update_Model(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_model_rec               IN    model_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Model
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_MODEL_ID                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Delete_Model(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_model_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Model
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_model_rec            IN   model_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Lock_Model(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_model_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Model
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_model_type      IN VARCHAR2
--       p_model_name      IN VARCHAR2
--       p_target_group_type  IN VARCHAR2, default CONSUMER
--       p_target_type     IN VARCHAR2, default BINARY
--       p_target_field    IN VARCHAR2
--       p_target_value    IN VARCHAR2
--       p_darwin_model_ref   IN VARCHAR2, default NULL
--       p_description     IN VARCHAR2
--
--   OUT
--       x_model_id        OUT NUMBER
--       x_return_status           OUT  VARCHAR2
--
--   Note
--       Used by the ODM Accelerator to create CUSTOM models.  The ODM
--       Accelerator is a consulting solution provided to supplement the
--       out of the box functionality of OMO data mining.
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Create_Model (
   p_model_type      IN VARCHAR2,
   p_model_name      IN VARCHAR2,
   p_target_group_type  IN VARCHAR2 := 'CONSUMER',
   p_target_type     IN VARCHAR2 := 'BINARY',
   p_target_field    IN VARCHAR2,
   p_target_value    IN VARCHAR2,
   p_darwin_model_ref   IN VARCHAR2 := NULL,
   p_description     IN VARCHAR2,
   x_model_id        OUT NOCOPY NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
);


END AMS_DMModel_PUB;

 

/
