--------------------------------------------------------
--  DDL for Package AMS_CT_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CT_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvctrs.pls 120.2 2006/05/30 11:09:54 prageorg noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Ct_Rule_PVT
--
-- Purpose
--          Private api created to Update/insert/Delete general
--          and object-specific content rules
--
-- History
--    21-mar-2002    jieli       Created.
--    21-aug-2002    soagrawa    Fixed bug# 2524840, regd default value of p_profile_id
--    29-May-2006    prageorg    Added delivery_mode column. Bug 4920064
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
--             ct_rule_rec_type
--   -------------------------------------------------------
--   Parameters:
--       content_rule_id
--       created_by
--       creation_date
--       last_updated_by
--       last_updated_date
--       last_update_login
--       object_version_number
--       object_type
--       object_id
--       sender
--       reply_to
--       cover_letter_id
--       table_of_content_flag
--       trigger_code
--       enabled_flag
--       delivery_mode
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
TYPE ct_rule_rec_type IS RECORD
(
       content_rule_id                 NUMBER := FND_API.G_MISS_NUM,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       last_updated_date               DATE := FND_API.G_MISS_DATE,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       object_type                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       object_id                       NUMBER := FND_API.G_MISS_NUM,
       sender                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       reply_to                        VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       cover_letter_id                 NUMBER := FND_API.G_MISS_NUM,
       table_of_content_flag           VARCHAR2(1) := FND_API.G_MISS_CHAR,
       trigger_code                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       enabled_flag                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       subject                         VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       sender_display_name             VARCHAR2(2000) := FND_API.G_MISS_CHAR,--anchaudh
       delivery_mode                   VARCHAR2(30) := FND_API.G_MISS_CHAR --prageorg
);

g_miss_ct_rule_rec          ct_rule_rec_type;
TYPE  ct_rule_tbl_type      IS TABLE OF ct_rule_rec_type INDEX BY BINARY_INTEGER;
g_miss_ct_rule_tbl          ct_rule_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Ct_Rule
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ct_rule_rec            IN   ct_rule_rec_type  Required
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

PROCEDURE Create_Ct_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ct_rule_rec               IN   ct_rule_rec_type  := g_miss_ct_rule_rec,
    x_content_rule_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Ct_Rule
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ct_rule_rec            IN   ct_rule_rec_type  Required
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

PROCEDURE Update_Ct_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ct_rule_rec               IN    ct_rule_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Ct_Rule
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_CONTENT_RULE_ID                IN   NUMBER
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

PROCEDURE Delete_Ct_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_content_rule_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Ct_Rule
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ct_rule_rec            IN   ct_rule_rec_type  Required
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

PROCEDURE Lock_Ct_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_content_rule_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_ct_rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ct_rule_rec               IN   ct_rule_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
-- End of Comments

PROCEDURE Check_ct_rule_Items (
    P_ct_rule_rec     IN    ct_rule_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_ct_rule_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ct_rule_rec               IN    ct_rule_rec_type
    );

--===================================================================
-- NAME
--    xyz
--
-- PURPOSE
--    sees if there are any content rules for given object
--    and submits a request to Fulfillment
--
-- NOTES
--
-- HISTORY
--   10-APR-2001  SOAGRAWA   Created
--===================================================================

PROCEDURE check_content_rule(
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_commit             IN  VARCHAR2  := FND_API.g_false,
   p_object_type        IN  VARCHAR2,
   p_object_id          IN  NUMBER,
   p_trigger_type       IN  VARCHAR2,
   p_requestor_type     IN  VARCHAR2  := NULL,
   p_requestor_id       IN  NUMBER,
   p_server_group       IN  NUMBER := NULL,
   p_scheduled_date     IN  DATE  := SYSDATE,
   p_media_types        IN  VARCHAR2 := 'E',
   p_archive            IN  VARCHAR2 := 'N',
   p_log_user_ih        IN  VARCHAR2 := 'Y',  --anchaudh: fixed to be able to log interactions for fulfillment rules related to Events.
   p_request_type       IN  VARCHAR2 := 'E',
   p_language_code      IN  VARCHAR2 := NULL,
   p_profile_id         IN  NUMBER   := NULL,
   p_order_id           IN  NUMBER   := NULL,
   p_collateral_id      IN  NUMBER   := NULL,
   p_party_id           IN  JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE,
   p_email              IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   p_fax                IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   p_bind_names         IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   p_bind_values        IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   x_request_history_id OUT NOCOPY NUMBER
    );

END AMS_Ct_Rule_PVT;

 

/
