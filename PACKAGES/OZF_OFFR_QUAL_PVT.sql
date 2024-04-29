--------------------------------------------------------
--  DDL for Package OZF_OFFR_QUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFR_QUAL_PVT" AUTHID CURRENT_USER AS
 /* $Header: ozfvoqfs.pls 120.0 2005/06/01 02:40:45 appldev noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          OZF_Offr_Qual_PVT
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
 -- This Api is generated with Latest version of
 -- Rosetta, where g_miss indicates NULL and
 -- NULL indicates missing value. Rosetta Version 1.55
 -- End of Comments
 -- ===============================================================

 -- Default number of records fetch per call
 -- G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
 --===================================================================
 --    Start of Comments
 --   -------------------------------------------------------
 --    Record name
 --             ozf_offr_qual_rec_type
 --   -------------------------------------------------------
 --   Parameters:
 --       qualifier_id
 --       creation_date
 --       created_by
 --       last_update_date
 --       last_updated_by
 --       last_update_login
 --       qualifier_grouping_no
 --       qualifier_context
 --       qualifier_attribute
 --       qualifier_attr_value
 --       start_date_active
 --       end_date_active
 --       offer_id
 --       offer_discount_line_id
 --       context
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
 --       active_flag
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
 TYPE ozf_offr_qual_rec_type IS RECORD
 (
        qualifier_id                    NUMBER,
        creation_date                   DATE,
        created_by                      NUMBER,
        last_update_date                DATE,
        last_updated_by                 NUMBER,
        last_update_login               NUMBER,
        qualifier_grouping_no           NUMBER,
        qualifier_context               VARCHAR2(30),
        qualifier_attribute             VARCHAR2(30),
        qualifier_attr_value            VARCHAR2(240),
        start_date_active               DATE,
        end_date_active                 DATE,
        offer_id                        NUMBER,
        offer_discount_line_id          NUMBER,
        context                         VARCHAR2(30),
        attribute1                      VARCHAR2(240),
        attribute2                      VARCHAR2(240),
        attribute3                      VARCHAR2(240),
        attribute4                      VARCHAR2(240),
        attribute5                      VARCHAR2(240),
        attribute6                      VARCHAR2(240),
        attribute7                      VARCHAR2(240),
        attribute8                      VARCHAR2(240),
        attribute9                      VARCHAR2(240),
        attribute10                     VARCHAR2(240),
        attribute11                     VARCHAR2(240),
        attribute12                     VARCHAR2(240),
        attribute13                     VARCHAR2(240),
        attribute14                     VARCHAR2(240),
        attribute15                     VARCHAR2(240),
        active_flag                     VARCHAR2(1),
        object_version_number           NUMBER
 );

 g_miss_ozf_offr_qual_rec          ozf_offr_qual_rec_type := NULL;
 TYPE  ozf_offr_qual_tbl_type      IS TABLE OF ozf_offr_qual_rec_type INDEX BY BINARY_INTEGER;
 g_miss_ozf_offr_qual_tbl          ozf_offr_qual_tbl_type;

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Create_Offr_Qual
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
 --       p_ozf_offr_qual_rec_type_rec            IN   ozf_offr_qual_rec_type  Required
 --
 --   OUT
 --       x_return_status           OUT  VARCHAR2
 --       x_msg_count               OUT  NUMBER
 --       x_msg_data                OUT  VARCHAR2
 --   Version : Current version 1.0
 --   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
 --         and basic operation, developer must manually add parameters and business logic as necessary.
 --
 --   History
 --
 --   NOTE
 --
 --   End of Comments
 --   ==============================================================================

 PROCEDURE Create_Offr_Qual(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_ozf_offr_qual_rec              IN   ozf_offr_qual_rec_type  ,
     x_qualifier_id              OUT NOCOPY  NUMBER
      );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Update_Offr_Qual
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
 --       p_ozf_offr_qual_rec_type_rec            IN   ozf_offr_qual_rec_type  Required
 --
 --   OUT
 --       x_return_status           OUT  VARCHAR2
 --       x_msg_count               OUT  NUMBER
 --       x_msg_data                OUT  VARCHAR2
 --   Version : Current version 1.0
 --   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
 --         and basic operation, developer must manually add parameters and business logic as necessary.
 --
 --   History
 --
 --   NOTE
 --
 --   End of Comments
 --   ==============================================================================

 PROCEDURE Update_Offr_Qual(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_ozf_offr_qual_rec               IN    ozf_offr_qual_rec_type
     );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Delete_Offr_Qual
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
 --       p_qualifier_id                IN   NUMBER
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
 --   History
 --
 --   NOTE
 --
 --   End of Comments
 --   ==============================================================================

 PROCEDURE Delete_Offr_Qual(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,
     p_qualifier_id                   IN  NUMBER,
     p_object_version_number      IN   NUMBER
     );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Lock_Offr_Qual
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
 --       p_ozf_offr_qual_rec_type_rec            IN   ozf_offr_qual_rec_type  Required
 --
 --   OUT
 --       x_return_status           OUT  VARCHAR2
 --       x_msg_count               OUT  NUMBER
 --       x_msg_data                OUT  VARCHAR2
 --   Version : Current version 1.0
 --   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
 --         and basic operation, developer must manually add parameters and business logic as necessary.
 --
 --   History
 --
 --   NOTE
 --
 --   End of Comments
 --   ==============================================================================

 PROCEDURE Lock_Offr_Qual(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_qualifier_id                   IN  NUMBER,
     p_object_version             IN  NUMBER
     );


 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Validate_Offr_Qual
 --
 --   Version : Current version 1.0
 --   p_validation_mode is a constant defined in OZF_UTILITY_PVT package
 --           For create: G_CREATE, for update: G_UPDATE
 --   Note: 1. This is automated generated item level validation procedure.
 --           The actual validation detail is needed to be added.
 --           2. We can also validate table instead of record. There will be an option for user to choose.
 --
 --   History
 --
 --   NOTE
 --
 --   End of Comments
 --   ==============================================================================


 PROCEDURE Validate_Offr_Qual(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
     p_ozf_offr_qual_rec               IN   ozf_offr_qual_rec_type,
     p_validation_mode            IN    VARCHAR2,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2
     );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Ozf_Offr_Qual_Rec_Type_Items
 --
 --   Version : Current version 1.0
 --   p_validation_mode is a constant defined in OZF_UTILITY_PVT package
 --           For create: G_CREATE, for update: G_UPDATE
 --   Note: 1. This is automated generated item level validation procedure.
 --           The actual validation detail is needed to be added.
 --           2. Validate the unique keys, lookups here
 --
 --   History
 --
 --   NOTE
 --
 --   End of Comments
 --   ==============================================================================


 PROCEDURE Check_Ozf_Offr_Qual_Items (
     p_ozf_offr_qual_rec     IN    ozf_offr_qual_rec_type,
     p_validation_mode  IN    VARCHAR2,
     x_return_status    OUT NOCOPY   VARCHAR2
     );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Validate_Ozf_Offr_Qual_Rec
 --
 --   Version : Current version 1.0
 --   p_validation_mode is a constant defined in OZF_UTILITY_PVT package
 --           For create: G_CREATE, for update: G_UPDATE
 --   Note: 1. This is automated generated item level validation procedure.
 --           The actual validation detail is needed to be added.
 --           2. Developer can manually added inter-field level validation.
 --
 --   History
 --
 --   NOTE
 --
 --   End of Comments
 --   ==============================================================================


 PROCEDURE Validate_Ozf_Offr_Qual_Rec (
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,
     p_ozf_offr_qual_rec               IN    ozf_offr_qual_rec_type
     );

 END OZF_Offr_Qual_PVT;

 

/
