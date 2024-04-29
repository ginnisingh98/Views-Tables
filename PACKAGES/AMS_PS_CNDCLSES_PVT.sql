--------------------------------------------------------
--  DDL for Package AMS_PS_CNDCLSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PS_CNDCLSES_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvccls.pls 120.0 2005/06/01 02:19:20 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Ps_Cndclses_PVT
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
--             ps_cndclses_rec_type
--   -------------------------------------------------------
--   Parameters:
--       created_by
--       creation_date
--       last_updated_by
--       last_update_date
--       last_update_login
--       object_version_number
--       cnd_clause_id
--       cnd_clause_datatype
--       cnd_clause_ref_code
--       cnd_comp_operator
--       cnd_default_value
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
TYPE ps_cndclses_rec_type IS RECORD
(
       created_by                NUMBER := FND_API.G_MISS_NUM,
       creation_date             DATE := FND_API.G_MISS_DATE,
       last_updated_by           NUMBER := FND_API.G_MISS_NUM,
       last_update_date          DATE := FND_API.G_MISS_DATE,
       last_update_login         NUMBER := FND_API.G_MISS_NUM,
       object_version_number     NUMBER := FND_API.G_MISS_NUM,
       cnd_clause_id             NUMBER := FND_API.G_MISS_NUM,
       cnd_clause_datatype       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       cnd_clause_ref_code       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       cnd_comp_operator         VARCHAR2(30) := FND_API.G_MISS_CHAR,
       cnd_default_value         VARCHAR2(30) := FND_API.G_MISS_CHAR,
	cnd_clause_name          VARCHAR2(240) := FND_API.G_MISS_CHAR,
	cnd_clause_description   VARCHAR2(4000) := FND_API.G_MISS_CHAR
);

g_miss_ps_cndclses_rec          ps_cndclses_rec_type;
TYPE  ps_cndclses_tbl_type      IS TABLE OF ps_cndclses_rec_type INDEX BY BINARY_INTEGER;
g_miss_ps_cndclses_tbl          ps_cndclses_tbl_type;

--   ==========================================================
--    Start of Comments
--   ==========================================================
--   API Name
--           Create_Ps_Cndclses
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number  IN   NUMBER   Required
--       p_init_msg_list       IN   VARCHAR2 Optional  Default = FND_API_G_FALSE
--       p_commit              IN   VARCHAR2 Optional  Default = FND_API.G_FALSE
--       p_validation_level    IN   NUMBER   Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ps_cndclses_rec     IN   ps_cndclses_rec_type  Required
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
--   ==========================================================
--

PROCEDURE Create_Ps_Cndclses(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,

    p_ps_cndclses_rec       IN   ps_cndclses_rec_type := g_miss_ps_cndclses_rec,
    x_cnd_clause_id         OUT NOCOPY  NUMBER
     );

--   ==========================================================
--    Start of Comments
--   ==========================================================
--   API Name
--           Update_Ps_Cndclses
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
--       p_ps_cndclses_rec     IN   ps_cndclses_rec_type  Required
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
--   ==========================================================
--

PROCEDURE Update_Ps_Cndclses(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,

    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,

    p_ps_cndclses_rec       IN    ps_cndclses_rec_type,
    x_object_version_number OUT NOCOPY  NUMBER
    );

--   ==========================================================
--    Start of Comments
--   ==========================================================
--   API Name
--           Delete_Ps_Cndclses
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number    IN   NUMBER   Required
--       p_init_msg_list         IN   VARCHAR2 Optional  Default = FND_API_G_FALSE
--       p_commit                IN   VARCHAR2 Optional  Default = FND_API.G_FALSE
--       p_validation_level      IN   NUMBER   Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_CND_CLAUSE_ID         IN   NUMBER
--       p_object_version_number IN   NUMBER   Optional  Default = NULL
--
--   OUT
--       x_return_status         OUT  VARCHAR2
--       x_msg_count             OUT  NUMBER
--       x_msg_data              OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==========================================================
--

PROCEDURE Delete_Ps_Cndclses(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    p_cnd_clause_id         IN  NUMBER,
    p_object_version_number IN   NUMBER
    );

--   ==========================================================
--    Start of Comments
--   ==========================================================
--   API Name
--           Lock_Ps_Cndclses
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number IN   NUMBER     Required
--       p_init_msg_list      IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit             IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level   IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ps_cndclses_rec    IN   ps_cndclses_rec_type  Required
--
--   OUT
--       x_return_status      OUT  VARCHAR2
--       x_msg_count          OUT  NUMBER
--       x_msg_data           OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==========================================================
--

PROCEDURE Lock_Ps_Cndclses(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2  := FND_API.G_FALSE,

    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,

    p_cnd_clause_id       IN  NUMBER,
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

PROCEDURE Validate_ps_cndclses(
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ps_cndclses_rec      IN   ps_cndclses_rec_type,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2
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

PROCEDURE Check_ps_cndclses_Items (
    P_ps_cndclses_rec     IN    ps_cndclses_rec_type,
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

PROCEDURE Validate_ps_cndclses_rec(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_ps_cndclses_rec     IN   ps_cndclses_rec_type
    );
END AMS_Ps_Cndclses_PVT;

 

/