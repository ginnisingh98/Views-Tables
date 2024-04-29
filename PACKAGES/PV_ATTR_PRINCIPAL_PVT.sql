--------------------------------------------------------
--  DDL for Package PV_ATTR_PRINCIPAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ATTR_PRINCIPAL_PVT" AUTHID CURRENT_USER AS
 /* $Header: pvxvatps.pls 120.0 2007/12/20 07:12:09 abnagapp noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          PV_Attr_Principal_PVT
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
 -- End of Comments
 -- ===============================================================

 -- Default number of records fetch per call
 --G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
 --===================================================================
 --    Start of Comments
 --   -------------------------------------------------------
 --    Record name
 --             Attr_Principal_rec_type
 --   -------------------------------------------------------
 --   Parameters:
 --       Attribute_Principal_id
 --       last_update_date
 --       last_updated_by
 --       creation_date
 --       created_by
 --       last_update_login
 --       object_version_number
 --       attribute_id
 --       jtf_auth_principal_id
 --
 --    Required
 --
 --    Defaults
 --
 --
 --   End of Comments

 --===================================================================

TYPE Attr_Principal_rec_type IS RECORD
(
 Attr_Principal_id    NUMBER         := FND_API.G_MISS_NUM
,last_update_date          DATE           := FND_API.G_MISS_DATE
,last_updated_by           NUMBER         := FND_API.G_MISS_NUM
,creation_date             DATE           := FND_API.G_MISS_DATE
,created_by                NUMBER         := FND_API.G_MISS_NUM
,last_update_login         NUMBER         := FND_API.G_MISS_NUM
,object_version_number     NUMBER         := FND_API.G_MISS_NUM
,attribute_id              NUMBER         := FND_API.G_MISS_NUM
,jtf_auth_principal_id     NUMBER         := FND_API.G_MISS_NUM
);


 g_miss_Attr_Principal_rec          Attr_Principal_rec_type;
 TYPE  Attr_Principal_tbl_type      IS TABLE OF Attr_Principal_rec_type INDEX BY BINARY_INTEGER;
 g_miss_Attr_Principal_tbl          Attr_Principal_tbl_type;

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Create_Attribute_Principal
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
 --       p_Attribute_Principal_rec            IN   Attribute_Principal_rec_type  Required
 --
 --   OUT
 --       x_return_status           OUT  VARCHAR2
 --       x_msg_count               OUT  NUMBER
 --       x_msg_data                OUT  VARCHAR2
 --   Version : Current version 1.0
 --
 --   End of Comments
 --   ==============================================================================
 --

 PROCEDURE Create_Attr_Principal(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_Attr_Principal_rec        IN   Attr_Principal_rec_type  := g_miss_Attr_Principal_rec
    ,x_Attr_Principal_id         OUT NOCOPY  NUMBER
    );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Update_Attribute_Principal
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
 --       p_Attribute_Principal_rec            IN   Attribute_Principal_rec_type  Required
 --
 --   OUT
 --       x_return_status           OUT  VARCHAR2
 --       x_msg_count               OUT  NUMBER
 --       x_msg_data                OUT  VARCHAR2
 --   Version : Current version 1.0
 --   End of Comments
 --   ==============================================================================
 --

 PROCEDURE Update_Attr_Principal(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_Attr_Principal_rec        IN   Attr_Principal_rec_type
    ,x_object_version_number      OUT NOCOPY  NUMBER
    );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Delete_Attribute_Principal
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
 --       p_Attribute_Principal_ID                IN   NUMBER
 --       p_object_version_number   IN   NUMBER     Optional  Default = NULL
 --
 --   OUT
 --       x_return_status           OUT  VARCHAR2
 --       x_msg_count               OUT  NUMBER
 --       x_msg_data                OUT  VARCHAR2
 --   Version : Current version 1.0
 --   End of Comments
 --   ==============================================================================
 --

 PROCEDURE Delete_Attr_Principal(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_Attr_Principal_id         IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Lock_Attribute_Principal
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
 --       p_Attribute_Principal_rec            IN   Attribute_Principal_rec_type  Required
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

 PROCEDURE Lock_Attr_Principal(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_Attr_Principal_id         IN   NUMBER
    ,p_object_version             IN   NUMBER
    );


 -- Start of Comments
 --
 --  validation procedures
 --
 -- p_validation_mode is a constant defined in null_UTILITY_PVT package
 --                  For create: G_CREATE, for update: G_UPDATE
 -- End of Comments

 PROCEDURE Validate_Attr_Principal(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.G_UPDATE
    ,p_Attr_Principal_rec        IN   Attr_Principal_rec_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    );




 -- Start of Comments
 --
 -- Record level validation procedures
 --
 -- p_validation_mode is a constant defined in null_UTILITY_PVT package
 --                  For create: G_CREATE, for update: G_UPDATE
 -- End of Comments

 PROCEDURE Validate_Attr_Principal_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_Attr_Principal_rec        IN   Attr_Principal_rec_type
    ,p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.G_UPDATE
    );

PROCEDURE Check_Attr_Principal_Items (
     p_Attr_Principal_rec     IN   Attr_Principal_rec_type
    ,p_validation_mode         IN   VARCHAR2
    ,x_return_status           OUT NOCOPY  VARCHAR2
    );

 END PV_Attr_Principal_PVT;

/
