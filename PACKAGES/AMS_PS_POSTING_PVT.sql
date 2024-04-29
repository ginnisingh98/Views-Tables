--------------------------------------------------------
--  DDL for Package AMS_PS_POSTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PS_POSTING_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvpsts.pls 115.9 2002/12/19 04:17:07 ryedator ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Ps_Posting_PVT
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
--================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             ps_posting_rec_type
--   -------------------------------------------------------
--   Parameters:
--       created_by
--       creation_date
--       last_updated_by
--       last_update_date
--       last_update_login
--       object_version_number
--       posting_id
--       max_no_contents
--       posting_type
--       content_type
--       default_content_id
--       status_code
--       posting_name
--       display_name
--       posting_description
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
TYPE ps_posting_rec_type IS RECORD
(
       created_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date              DATE := FND_API.G_MISS_DATE,
       last_updated_by            NUMBER := FND_API.G_MISS_NUM,
       last_update_date           DATE := FND_API.G_MISS_DATE,
       last_update_login          NUMBER := FND_API.G_MISS_NUM,
       object_version_number      NUMBER := FND_API.G_MISS_NUM,
       posting_id                 NUMBER := FND_API.G_MISS_NUM,
       max_no_contents            NUMBER := FND_API.G_MISS_NUM,
       posting_type               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       content_type               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       default_content_id         NUMBER := FND_API.G_MISS_NUM,
       status_code                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       posting_name               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       display_name               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       posting_description        VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       attribute_category         VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute1                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute2                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute3                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute4                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute5                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute6                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute7                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute8                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute9                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute10                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute11                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute12                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute13                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute14                VARCHAR2(100) := FND_API.G_MISS_CHAR,
       attribute15                VARCHAR2(1000) := FND_API.G_MISS_CHAR
);

g_miss_ps_posting_rec      ps_posting_rec_type;
TYPE  ps_posting_tbl_type  IS TABLE OF ps_posting_rec_type INDEX BY BINARY_INTEGER;
g_miss_ps_posting_tbl      ps_posting_tbl_type;

--   =======================================================================
--    Start of Comments
--   =======================================================================
--   API Name
--           Create_Ps_Posting
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number  IN   NUMBER     Required
--       p_init_msg_list       IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit              IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level    IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ps_posting_rec      IN   ps_posting_rec_type  Required
--
--   OUT
--       x_return_status       OUT  VARCHAR2
--       x_msg_count           OUT  NUMBER
--       x_msg_data            OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ===========================================================
--

PROCEDURE Create_Ps_Posting(
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,

    p_ps_posting_rec      IN  ps_posting_rec_type := g_miss_ps_posting_rec,
    x_posting_id          OUT NOCOPY  NUMBER
     );

--   =============================================================
--    Start of Comments
--   =============================================================
--   API Name
--           Update_Ps_Posting
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number  IN   NUMBER     Required
--       p_init_msg_list       IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit              IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level    IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ps_posting_rec      IN   ps_posting_rec_type  Required
--
--   OUT
--       x_return_status       OUT  VARCHAR2
--       x_msg_count           OUT  NUMBER
--       x_msg_data            OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   =============================================================
--

PROCEDURE Update_Ps_Posting(
    p_api_version_number     IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,

    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,

    p_ps_posting_rec         IN  ps_posting_rec_type,
    x_object_version_number  OUT NOCOPY  NUMBER
    );

--   =============================================================
--    Start of Comments
--   =============================================================
--   API Name
--           Delete_Ps_Posting
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
--       p_POSTING_ID              IN   NUMBER
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
--   ====================================================================
--

PROCEDURE Delete_Ps_Posting(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_posting_id             IN  NUMBER,
    p_object_version_number  IN   NUMBER
    );

--   =======================================================================
--    Start of Comments
--   =======================================================================
--   API Name
--           Lock_Ps_Posting
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number  IN   NUMBER     Required
--       p_init_msg_list       IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit              IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level    IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ps_posting_rec      IN   ps_posting_rec_type  Required
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
--   ====================================================================
--

PROCEDURE Lock_Ps_Posting(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,

    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,

    p_posting_id          IN  NUMBER,
    p_object_version      IN  NUMBER
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

PROCEDURE Validate_ps_posting(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ps_posting_rec      IN   ps_posting_rec_type,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2
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

/****************************************************************************/
-- Procedure
--   Check_ps_posting_Items
-- Purpose
--   item_level validate
-- Parameters
--   IN:
--     p_validation_mode    IN   VARCHAR2
--     p_ps_posting_rec     IN   ps_posting_rec_type,
--   OUT:
--     x_return_status      OUT  VARCHAR2
------------------------------------------------------------------------------
PROCEDURE Check_ps_posting_Items
(
    p_ps_posting_rec   IN   ps_posting_rec_type,
    p_validation_mode  IN   VARCHAR2,
    x_return_status    OUT NOCOPY  VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_ps_posting_req_items
-- Purpose
--   check if required items are miss
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_ps_posting_rec     IN   ps_posting_rec_type,
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_ps_posting_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_ps_posting_rec     IN      ps_posting_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_ps_posting_fk_items
-- Purpose
--   check foreign key items
-- Parameters
--   IN:
--   p_ps_posting_rec      IN   ps_posting_rec_type
--   OUT:
--     x_return_status     OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_ps_posting_fk_items
(
  p_ps_posting_rec    IN   ps_posting_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
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

PROCEDURE Validate_ps_posting_rec(
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_ps_posting_rec      IN  ps_posting_rec_type
    );
END AMS_Ps_Posting_PVT;

 

/
