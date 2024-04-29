--------------------------------------------------------
--  DDL for Package OZF_FUNDTHRESHOLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUNDTHRESHOLD_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvthrs.pls 115.4 2004/01/21 20:11:48 kvattiku noship $ */
-- ===============================================================

-- Start of Comments
-- Package name
--          OZF_Fundthreshold_PVT
-- Purpose
--
-- History
--Jan 20, 2004  kvattiku......changed the description field in threshold_rec_type
--               to VARCHAR2(2000) from VARCHAR2(240)....bug 3386996..
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
--             threshold_rec_type
--   -------------------------------------------------------
--   Parameters:
--       threshold_id
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
--       threshold_calendar
--       start_period_name
--       end_period_name
--       start_date_active
--       end_date_active
--       owner
--       enable_flag
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
--       object_version_number
--       name
--       description
--       language
--       source_lang
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
TYPE threshold_rec_type IS RECORD
(
       threshold_id                    NUMBER ,
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
       threshold_calendar              VARCHAR2(30) ,
       start_period_name               VARCHAR2(15) ,
       end_period_name                 VARCHAR2(15) ,
       start_date_active               DATE ,
       end_date_active                 DATE ,
       owner                           NUMBER ,
       enable_flag                     VARCHAR2(1) ,
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
       object_version_number           NUMBER ,
       name                            VARCHAR2(80) ,
       description                     VARCHAR2(2000),
       language                        VARCHAR2(4) ,
       source_lang                     VARCHAR2(4),
       threshold_type                  VARCHAR2(30)
);

g_miss_threshold_rec          threshold_rec_type;
TYPE  threshold_tbl_type      IS TABLE OF threshold_rec_type INDEX BY BINARY_INTEGER;
g_miss_threshold_tbl          threshold_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Threshold
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
--       p_threshold_rec            IN   threshold_rec_type  Required
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

PROCEDURE Create_Threshold(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_threshold_rec               IN   threshold_rec_type  := g_miss_threshold_rec,
    x_threshold_id                   OUT NOCOPY NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Threshold
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
--       p_threshold_rec            IN   threshold_rec_type  Required
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

PROCEDURE Update_Threshold(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_threshold_rec               IN    threshold_rec_type,
    x_object_version_number      OUT NOCOPY NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Threshold
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
--       p_THRESHOLD_ID                IN   NUMBER
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

PROCEDURE Delete_Threshold(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_threshold_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Threshold
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
--       p_threshold_rec            IN   threshold_rec_type  Required
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

PROCEDURE Lock_Threshold(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_threshold_id                   IN  NUMBER,
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

PROCEDURE Validate_threshold(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_threshold_rec               IN   threshold_rec_type,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
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

PROCEDURE Check_threshold_Items (
    P_threshold_rec     IN    threshold_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_threshold_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_threshold_rec               IN    threshold_rec_type
    );


PROCEDURE Complete_threshold_Rec (
    P_threshold_rec     IN    threshold_rec_type,
     x_complete_rec        OUT NOCOPY   threshold_rec_type
    );
END OZF_Fundthreshold_PVT;

 

/
