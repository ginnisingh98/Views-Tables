--------------------------------------------------------
--  DDL for Package OZF_THRESHOLD_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_THRESHOLD_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvtrus.pls 115.2 2003/11/28 12:27:38 pkarthik noship $ */
-- ===============================================================

-- Start of Comments
-- Package name
--          OZF_Threshold_Rule_PVT
-- Purpose
--
-- History
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
--             threshold_rule_rec_type
--   -------------------------------------------------------
--   Parameters:
--       threshold_rule_id
--       last_update_date
--       last_updated_by
--       last_update_login
--       creation_date
--       created_by
--       created_from
--       request_id
--       program_application_id
--       program_id
--       program_update_date
--       period_type
--       enabled_flag
--       threshold_calendar
--       start_period_name
--       end_period_name
--       threshold_id
--       start_date
--       end_date
--       value_limit
--       operator_code
--       percent_amount
--       base_line
--       error_mode
--       repeat_frequency
--       frequency_period
--       attribute_category
--       attribute1
--       attribute2
--       attribute3
--       attribute4
--       attribute5
--       attribute6
--       attribute7
--       attribute8
--       attribute9
--       attribute10
--       attribute11
--       attribute12
--       attribute13
--       attribute14
--       attribute15
--       org_id
--       security_group_id
--       converted_days
--       object_version_number
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
TYPE threshold_rule_rec_type IS RECORD
(
       threshold_rule_id               NUMBER ,
       last_update_date                DATE ,
       last_updated_by                 NUMBER ,
       last_update_login               NUMBER ,
       creation_date                   DATE ,
       created_by                      NUMBER ,
       created_from                    VARCHAR2(30) ,
       request_id                      NUMBER ,
       program_application_id          NUMBER ,
       program_id                      NUMBER ,
       program_update_date             DATE ,
       period_type                     VARCHAR2(15) ,
       enabled_flag                    VARCHAR2(1) ,
       threshold_calendar              VARCHAR2(30) ,
       start_period_name                    VARCHAR2(15) ,
       end_period_name                      VARCHAR2(15) ,
       threshold_id                    NUMBER ,
       start_date                      DATE ,
       end_date                        DATE ,
       value_limit                     VARCHAR2(25) ,
       operator_code                   VARCHAR2(1) ,
       percent_amount                  NUMBER ,
       base_line                       VARCHAR2(25) ,
       error_mode                      VARCHAR2(15) ,
       repeat_frequency                NUMBER ,
       frequency_period                VARCHAR2(15) ,
       attribute_category              VARCHAR2(30) ,
       attribute1                      VARCHAR2(150),
       attribute2                      VARCHAR2(150) ,
       attribute3                      VARCHAR2(150) ,
       attribute4                      VARCHAR2(150) ,
       attribute5                      VARCHAR2(150) ,
       attribute6                      VARCHAR2(150) ,
       attribute7                      VARCHAR2(150) ,
       attribute8                      VARCHAR2(150) ,
       attribute9                      VARCHAR2(150) ,
       attribute10                     VARCHAR2(150) ,
       attribute11                     VARCHAR2(150) ,
       attribute12                     VARCHAR2(150) ,
       attribute13                     VARCHAR2(150) ,
       attribute14                     VARCHAR2(150) ,
       attribute15                     VARCHAR2(150) ,
       org_id                          NUMBER ,
       security_group_id               NUMBER ,
       converted_days                  NUMBER ,
       object_version_number           NUMBER ,
       comparison_type                 VARCHAR2(50) ,
       alert_type                      VARCHAR2(50)
);

g_miss_threshold_rule_rec          threshold_rule_rec_type;
TYPE  threshold_rule_tbl_type      IS TABLE OF threshold_rule_rec_type INDEX BY BINARY_INTEGER;
g_miss_threshold_rule_tbl          threshold_rule_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Threshold_Rule
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
--       p_threshold_rule_rec            IN   threshold_rule_rec_type  Required
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

PROCEDURE Create_Threshold_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_threshold_rule_rec               IN   threshold_rule_rec_type  := g_miss_threshold_rule_rec,
    x_threshold_rule_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Threshold_Rule
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
--       p_threshold_rule_rec            IN   threshold_rule_rec_type  Required
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

PROCEDURE Update_Threshold_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_threshold_rule_rec               IN    threshold_rule_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Threshold_Rule
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
--       p_THRESHOLD_RULE_ID                IN   NUMBER
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

PROCEDURE Delete_Threshold_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_threshold_rule_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Threshold_Rule
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
--       p_threshold_rule_rec            IN   threshold_rule_rec_type  Required
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

PROCEDURE Lock_Threshold_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_threshold_rule_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_threshold_rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_threshold_rule_rec               IN   threshold_rule_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
-- End of Comments

PROCEDURE Check_threshold_rule_Items (
    P_threshold_rule_rec     IN    threshold_rule_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_threshold_rule_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_threshold_rule_rec               IN    threshold_rule_rec_type
    );



PROCEDURE Complete_threshold_rule_Rec (
    P_threshold_rule_rec     IN    threshold_rule_rec_type,
     x_complete_rec        OUT NOCOPY    threshold_rule_rec_type
    );


END OZF_Threshold_Rule_PVT;

 

/
