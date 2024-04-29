--------------------------------------------------------
--  DDL for Package PV_ATTRIBUTE_CODE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ATTRIBUTE_CODE_PVT" AUTHID CURRENT_USER AS
 /* $Header: pvxvatcs.pls 120.1 2005/06/30 14:47:04 appldev ship $ */
 /*-- ===============================================================
 -- Start of Comments
 -- Package name
 --          PV_ATTRIBUTE_CODE_PVT
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
 --             attribute_code_rec_type
 --   -------------------------------------------------------
 --   Parameters:
 --            attr_code_id
 --            attr_code
 --            last_update_date
 --            last_updated_by
 --            creation_date
 --            created_by
 --            last_update_login
 --            object_version_number
 --            attribute_id
 --            enabled_flag
 --            description
 --            security_group_id
 --
 --    Required
 --
 --    Defaults
 --
 --    Note: This is automatic generated record definition, it includes all columns
 --          defined in the table, developer must manually add or delete some of the attributes.
 --
 --   End of Comments

History
      22-JAN-2002	shitij.vatsa		Created
 --===================================================================*/
TYPE attribute_code_rec_type IS RECORD
(
 attr_code_id              NUMBER         := FND_API.G_MISS_NUM
,attr_code                 VARCHAR2(30)   := FND_API.G_MISS_CHAR
,last_update_date          DATE           := FND_API.G_MISS_DATE
,last_updated_by           NUMBER         := FND_API.G_MISS_NUM
,creation_date             DATE           := FND_API.G_MISS_DATE
,created_by                NUMBER         := FND_API.G_MISS_NUM
,last_update_login         NUMBER         := FND_API.G_MISS_NUM
,object_version_number     NUMBER         := FND_API.G_MISS_NUM
,attribute_id              NUMBER         := FND_API.G_MISS_NUM
,enabled_flag              VARCHAR2(1)    := FND_API.G_MISS_CHAR
,description               VARCHAR2(240)  := FND_API.G_MISS_CHAR
--,security_group_id         NUMBER         := FND_API.G_MISS_NUM
);


 g_miss_attribute_code_rec           attribute_code_rec_type;
 TYPE  attribute_code_tbl_type      IS TABLE OF attribute_code_rec_type INDEX BY BINARY_INTEGER;
 g_miss_attribute_code_tbl          attribute_code_tbl_type;

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Create_Attribute_Code
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
 --       p_attribute_code_rec      IN   attribute_code_rec_type  Required
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

 PROCEDURE Create_Attribute_Code(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attribute_code_rec         IN   attribute_code_rec_type  := g_miss_attribute_code_rec
    ,x_attr_code_id               OUT NOCOPY  NUMBER
    );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Update_Attribute_Code
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
 --       p_attribute_code_rec      IN   attribute_code_rec_type  Required
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

 PROCEDURE Update_Attribute_Code(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attribute_code_rec         IN   attribute_code_rec_type
    ,x_object_version_number      OUT NOCOPY  NUMBER
    );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Delete_Attribute_Code
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
 --       p_ATTRIBUTE_USAGE_ID                IN   NUMBER
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

 PROCEDURE Delete_Attribute_Code(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attr_code_id               IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Lock_Attribute_Code
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

 PROCEDURE Lock_Attribute_Code(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attr_code_id               IN   NUMBER
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

 PROCEDURE Validate_Attribute_Code(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.G_UPDATE
    ,p_attribute_code_rec         IN   attribute_code_rec_type
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

 PROCEDURE Check_Attr_Code_Items (
     p_attribute_code_rec      IN   attribute_code_rec_type
    ,p_validation_mode         IN   VARCHAR2
    ,x_return_status           OUT NOCOPY  VARCHAR2
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

 PROCEDURE Validate_Attr_Code_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_attribute_code_rec         IN   attribute_code_rec_type
    ,p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.G_UPDATE
    );

 END PV_ATTRIBUTE_CODE_PVT;


 

/
