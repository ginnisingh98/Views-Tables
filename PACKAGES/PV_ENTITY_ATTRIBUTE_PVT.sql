--------------------------------------------------------
--  DDL for Package PV_ENTITY_ATTRIBUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENTITY_ATTRIBUTE_PVT" AUTHID CURRENT_USER AS
 /* $Header: pvxveats.pls 120.1 2005/06/30 13:09:12 appldev ship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Entity_Attribute_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
-- Default number of records fetch per call
-- G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             entity_attr_rec_type
--   -------------------------------------------------------
--   Parameters:
--       entity_attr_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       attribute_id
--       entity
--       sql_text
--       attr_data_type
--       lov_string
--       enabled_flag
--       display_flag
--       security_group_id
--       locator_flag
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

TYPE entity_attr_rec_type IS RECORD
(
        entity_attr_id                  NUMBER         := Fnd_Api.G_MISS_NUM
       ,last_update_date                DATE           := Fnd_Api.G_MISS_DATE
       ,last_updated_by                 NUMBER         := Fnd_Api.G_MISS_NUM
       ,creation_date                   DATE           := Fnd_Api.G_MISS_DATE
       ,created_by                      NUMBER         := Fnd_Api.G_MISS_NUM
       ,last_update_login               NUMBER         := Fnd_Api.G_MISS_NUM
       ,object_version_number           NUMBER         := Fnd_Api.G_MISS_NUM
       ,attribute_id                    NUMBER         := Fnd_Api.G_MISS_NUM
       ,entity                          VARCHAR2(30)   := Fnd_Api.G_MISS_CHAR
       ,entity_type                     VARCHAR2(30)   := Fnd_Api.G_MISS_CHAR
       ,sql_text                        VARCHAR2(2000) := Fnd_Api.G_MISS_CHAR
       ,attr_data_type                  VARCHAR2(30)   := Fnd_Api.G_MISS_CHAR
       ,lov_string                      VARCHAR2(2000) := Fnd_Api.G_MISS_CHAR
       ,enabled_flag                    VARCHAR2(1)    := Fnd_Api.G_MISS_CHAR
       ,display_flag                    VARCHAR2(1)    := Fnd_Api.G_MISS_CHAR
       ,locator_flag                    VARCHAR2(1)    := Fnd_Api.G_MISS_CHAR
       ,require_validation_flag		VARCHAR2(1)    := Fnd_Api.G_MISS_CHAR
       ,external_update_text		VARCHAR2(2000) := Fnd_Api.G_MISS_CHAR
       ,refresh_frequency               NUMBER  := Fnd_Api.G_MISS_NUM
       ,refresh_frequency_uom           VARCHAR2(20) := Fnd_Api.G_MISS_CHAR
       ,batch_sql_text		        VARCHAR2(2000) := Fnd_Api.G_MISS_CHAR
       ,last_refresh_date		DATE    := Fnd_Api.G_MISS_DATE
       ,display_external_value_flag     VARCHAR2(1)    := Fnd_Api.G_MISS_CHAR);

g_miss_entity_attr_rec          entity_attr_rec_type;

TYPE  pv_entity_attr_tbl_type      IS TABLE OF entity_attr_rec_type INDEX BY BINARY_INTEGER;
g_miss_entity_attr_tbl          pv_entity_attr_tbl_type;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Entity_Attr
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
--       p_entity_attr_rec      IN   entity_attr_rec_type  Required
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
Procedure Create_Entity_Attr(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_entity_attr_rec            IN   entity_attr_rec_type  := g_miss_entity_attr_rec
    ,x_entity_attr_id             OUT NOCOPY  NUMBER
     );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Entity_Attr
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
--       p_entity_attr_rec      IN   entity_attr_rec_type  Required
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
PROCEDURE Update_Entity_Attr(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_entity_attr_rec            IN   entity_attr_rec_type
    ,x_object_version_number      OUT NOCOPY  NUMBER
    );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Entity_Attr
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
--       p_ENTITY_ATTR_ID          IN   NUMBER
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
PROCEDURE Delete_Entity_Attr(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_entity_attr_id             IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Entity_Attr
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
--       p_entity_attr_rec      IN   entity_attr_rec_type  Required
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
PROCEDURE Lock_Entity_Attr(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_entity_attr_id             IN   NUMBER
    ,p_object_version             IN   NUMBER
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

PROCEDURE Validate_Entity_Attr(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,p_validation_mode            IN   VARCHAR2     := Jtf_Plsql_Api.G_UPDATE
    ,p_entity_attr_rec            IN   entity_attr_rec_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
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

PROCEDURE Check_Entity_Attr_Items (
     p_entity_attr_rec     IN    entity_attr_rec_type
    ,p_validation_mode        IN    VARCHAR2
    ,x_return_status          OUT NOCOPY   VARCHAR2
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

PROCEDURE Validate_Entity_Attr_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_entity_attr_rec            IN   entity_attr_rec_type
    ,p_validation_mode            IN   VARCHAR2     := Jtf_Plsql_Api.G_UPDATE
    );


PROCEDURE Validate_sql_text(
    p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

	,p_sql_text					  IN   VARCHAR2
    ,p_entity					  IN   VARCHAR2

    );

PROCEDURE Validate_Lov_String(
    p_api_version_number          IN	NUMBER
    ,p_init_msg_list              IN	VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN	VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN	NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,x_return_status              OUT	NOCOPY	VARCHAR2
    ,x_msg_count                  OUT	NOCOPY  NUMBER
    ,x_msg_data                   OUT	NOCOPY  VARCHAR2

    ,p_lov_string		  IN	VARCHAR2
    ,p_entity			  IN	VARCHAR2
    ,p_attribute_id		  IN	NUMBER
    ,x_lov_result		  OUT NOCOPY VARCHAR2
    );

END Pv_Entity_Attribute_Pvt;

 

/
