--------------------------------------------------------
--  DDL for Package PV_ATTRIBUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ATTRIBUTE_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvatss.pls 120.0 2005/05/27 16:12:54 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Attribute_PVT
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
--             attribute_rec_type
--   -------------------------------------------------------
--   Parameters:
--       attribute_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       --security_group_id
--       enabled_flag
--       attribute_type
--       attribute_category
--       seeded_flag
--       lov_function_name
--       return_type
--       max_value_flag
--       name
--       description
--       short_name
--       display_style
--	 character_width
--	 decimal_points
--	 no_of_lines
--	 expose_to_partner_flag
--	 value_extn_return_type
--	enable_matching_flag
--	performance_flag
--	additive_flag
--	sequence_number
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
TYPE attribute_rec_type IS RECORD
(
attribute_id               NUMBER         := FND_API.G_MISS_NUM
,last_update_date          DATE           := FND_API.G_MISS_DATE
,last_updated_by           NUMBER         := FND_API.G_MISS_NUM
,creation_date             DATE           := FND_API.G_MISS_DATE
,created_by                NUMBER         := FND_API.G_MISS_NUM
,last_update_login         NUMBER         := FND_API.G_MISS_NUM
,object_version_number     NUMBER         := FND_API.G_MISS_NUM
--,security_group_id       NUMBER         := FND_API.G_MISS_NUM
,enabled_flag              VARCHAR2(1)    := FND_API.G_MISS_CHAR
,attribute_type            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,attribute_category        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,seeded_flag               VARCHAR2(30)   := FND_API.G_MISS_CHAR
,lov_function_name         VARCHAR2(30)   := FND_API.G_MISS_CHAR
,return_type               VARCHAR2(30)   := FND_API.G_MISS_CHAR
,max_value_flag            VARCHAR2(1)    := FND_API.G_MISS_CHAR
,name                      VARCHAR2(60)   := FND_API.G_MISS_CHAR
,description               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,short_name                VARCHAR2(60)   := FND_API.G_MISS_CHAR
,display_style		   VARCHAR2(30)   := FND_API.G_MISS_CHAR
,character_width           NUMBER         := FND_API.G_MISS_NUM
,decimal_points            NUMBER         := FND_API.G_MISS_NUM
,no_of_lines               NUMBER         := FND_API.G_MISS_NUM
,expose_to_partner_flag    VARCHAR2(1)    := FND_API.G_MISS_CHAR
,value_extn_return_type    VARCHAR2(30)   := FND_API.G_MISS_CHAR
,enable_matching_flag      VARCHAR2(1)    := FND_API.G_MISS_CHAR
,performance_flag	   VARCHAR2(1)   := FND_API.G_MISS_CHAR
,additive_flag		   VARCHAR2(1)   := FND_API.G_MISS_CHAR
,sequence_number           NUMBER         := FND_API.G_MISS_NUM
);

g_miss_attribute_rec          attribute_rec_type;
TYPE  attribute_tbl_type      IS TABLE OF attribute_rec_type INDEX BY BINARY_INTEGER;
g_miss_attribute_tbl          attribute_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Attribute
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
--       p_attribute_rec           IN   attribute_rec_type  Required
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

PROCEDURE Create_Attribute(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list             IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                    IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level          IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                 OUT NOCOPY  NUMBER
    ,x_msg_data                  OUT NOCOPY  VARCHAR2

    ,p_attribute_rec             IN   attribute_rec_type  := g_miss_attribute_rec
    ,x_attribute_id              OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Attribute
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
--       p_attribute_rec           IN   attribute_rec_type  Required
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

PROCEDURE Update_Attribute(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN  NUMBER        := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attribute_rec              IN    attribute_rec_type
    ,x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Attribute
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
--       p_ATTRIBUTE_ID            IN   NUMBER
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

PROCEDURE Delete_Attribute(
     p_api_version_number        IN   NUMBER
    ,p_init_msg_list             IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                    IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level          IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                 OUT NOCOPY  NUMBER
    ,x_msg_data                  OUT NOCOPY  VARCHAR2
    ,p_attribute_id              IN  NUMBER
    ,p_object_version_number     IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Attribute
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
--       p_attribute_rec           IN   attribute_rec_type  Required
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

PROCEDURE Lock_Attribute(
     p_api_version_number        IN   NUMBER
    ,p_init_msg_list             IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                 OUT NOCOPY  NUMBER
    ,x_msg_data                  OUT NOCOPY  VARCHAR2

    ,p_attribute_id              IN  NUMBER
    ,p_object_version            IN  NUMBER
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

PROCEDURE Validate_attribute(
     p_api_version_number        IN   NUMBER
    ,p_init_msg_list             IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level          IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_validation_mode           IN   VARCHAR2     := JTF_PLSQL_API.g_UPDATE
    ,p_attribute_rec             IN   attribute_rec_type
    ,x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                 OUT NOCOPY  NUMBER
    ,x_msg_data                  OUT NOCOPY  VARCHAR2
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

PROCEDURE Check_attribute_Items (
     p_attribute_rec    IN    attribute_rec_type
    ,p_validation_mode  IN    VARCHAR2
    ,x_return_status    OUT NOCOPY   VARCHAR2
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

PROCEDURE Validate_attribute_rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_attribute_rec              IN    attribute_rec_type
    ,p_validation_mode           IN   VARCHAR2     := JTF_PLSQL_API.g_UPDATE
    );
END PV_Attribute_PVT;

 

/
