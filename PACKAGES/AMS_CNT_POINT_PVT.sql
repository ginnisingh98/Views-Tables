--------------------------------------------------------
--  DDL for Package AMS_CNT_POINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CNT_POINT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcons.pls 120.0 2005/05/31 16:09:48 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Cnt_Point_PVT
-- Purpose
--
-- History
--     20-may-2005    musman	  Added contact_point_value_id column for webadi collaboration script usage
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
--             cnt_point_rec_type
--   -------------------------------------------------------
--   Parameters:
--       contact_point_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       arc_contact_used_by
--       act_contact_used_by_id
--       contact_point_type
--       contact_point_value
--       city
--       country
--       zipcode
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
--       content_point_value_id
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE cnt_point_rec_type IS RECORD
(
       contact_point_id                NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       arc_contact_used_by             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       act_contact_used_by_id          NUMBER := FND_API.G_MISS_NUM,
       contact_point_type              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       contact_point_value             VARCHAR2(256) := FND_API.G_MISS_CHAR,
       city                            VARCHAR2(120) := FND_API.G_MISS_CHAR,
       country                         NUMBER := FND_API.G_MISS_NUM,
       zipcode                         VARCHAR2(120) := FND_API.G_MISS_CHAR,
       attribute_category              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       attribute1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       contact_point_value_id          NUMBER        := FND_API.G_MISS_NUM
);

g_miss_cnt_point_rec          cnt_point_rec_type;
TYPE  cnt_point_tbl_type      IS TABLE OF cnt_point_rec_type INDEX BY BINARY_INTEGER;
g_miss_cnt_point_tbl          cnt_point_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Cnt_Point
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
--       p_cnt_point_rec            IN   cnt_point_rec_type  Required
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

PROCEDURE Create_Cnt_Point(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_cnt_point_rec               IN   cnt_point_rec_type  := g_miss_cnt_point_rec,
    x_contact_point_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Cnt_Point
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
--       p_cnt_point_rec            IN   cnt_point_rec_type  Required
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

PROCEDURE Update_Cnt_Point(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_cnt_point_rec               IN    cnt_point_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Cnt_Point
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
--       p_CONTACT_POINT_ID                IN   NUMBER
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

PROCEDURE Delete_Cnt_Point(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_contact_point_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Cnt_Point
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
--       p_cnt_point_rec            IN   cnt_point_rec_type  Required
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

PROCEDURE Lock_Cnt_Point(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_contact_point_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
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

PROCEDURE Validate_cnt_point(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2,
    p_cnt_point_rec               IN   cnt_point_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

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

PROCEDURE Check_cnt_point_Items (
    P_cnt_point_rec     IN    cnt_point_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
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

PROCEDURE Validate_cnt_point_rec(
    p_api_version_number         IN   NUMBER,
    p_validation_mode            IN   VARCHAR2,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_cnt_point_rec               IN    cnt_point_rec_type
    );
END AMS_Cnt_Point_PVT;

 

/
