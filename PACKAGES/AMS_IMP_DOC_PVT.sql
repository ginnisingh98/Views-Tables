--------------------------------------------------------
--  DDL for Package AMS_IMP_DOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IMP_DOC_PVT" AUTHID CURRENT_USER AS
 /* $Header: amsvidos.pls 115.3 2002/11/12 23:38:25 jieli noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          AMS_Imp_Doc_PVT
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
 --             imp_doc_rec_type
 --   -------------------------------------------------------
 --   Parameters:
 --       imp_document_id
 --       last_updated_by
 --       object_version_number
 --       last_update_by
 --       created_by
 --       last_update_login
 --       last_update_date
 --       creation_date
 --       object_version_number
 --       import_list_header_id
 --       import_list_header_id
 --       content_text
 --       content_text
 --       dtd_text
 --       dtd_text
 --       file_type
 --       filter_content_text
 --       filter_content_text
 --       file_type
 --       file_size
 --       file_size
 --       last_updated_by
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
 TYPE imp_doc_rec_type IS RECORD
 (
        imp_document_id                 NUMBER,
        last_updated_by                 NUMBER,
        object_version_number           NUMBER,
        created_by                      NUMBER,
        last_update_login               NUMBER,
        last_update_date                DATE,
        creation_date                   DATE,
        import_list_header_id           NUMBER,
        --content_text                    CLOB,
        --dtd_text                        CLOB,
        file_type                       VARCHAR2(10),
        --filter_content_text             CLOB,
        file_size                       NUMBER
 );

 g_miss_imp_doc_rec          imp_doc_rec_type := NULL;
 TYPE  imp_doc_tbl_type      IS TABLE OF imp_doc_rec_type INDEX BY BINARY_INTEGER;
 g_miss_imp_doc_tbl          imp_doc_tbl_type;

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Create_Imp_Doc
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
 --       p_imp_doc_rec            IN   imp_doc_rec_type  Required
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

 PROCEDURE Create_Imp_Doc(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_imp_doc_rec              IN   imp_doc_rec_type  := g_miss_imp_doc_rec,
     x_imp_document_id              OUT NOCOPY  NUMBER
      );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Update_Imp_Doc
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
 --       p_imp_doc_rec            IN   imp_doc_rec_type  Required
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

 PROCEDURE Update_Imp_Doc(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_imp_doc_rec               IN    imp_doc_rec_type,
     x_object_version_number      OUT NOCOPY  NUMBER
     );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Delete_Imp_Doc
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
 --       p_imp_document_id                IN   NUMBER
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

 PROCEDURE Delete_Imp_Doc(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,
     p_imp_document_id                   IN  NUMBER,
     p_object_version_number      IN   NUMBER
     );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Lock_Imp_Doc
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
 --       p_imp_doc_rec            IN   imp_doc_rec_type  Required
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

 PROCEDURE Lock_Imp_Doc(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_imp_document_id                   IN  NUMBER,
     p_object_version             IN  NUMBER
     );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           add_language
 --   Type
 --           Private
 --   History
 --
 --   NOTE
 --
 -- End of Comments
 -- ===============================================================

 --PROCEDURE Add_Language;

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Validate_Imp_Doc
 --
 --   Version : Current version 1.0
 --   p_validation_mode is a constant defined in AMS_UTILITY_PVT package
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


 PROCEDURE Validate_Imp_Doc(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
     p_imp_doc_rec               IN   imp_doc_rec_type,
     p_validation_mode            IN    VARCHAR2,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2
     );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Imp_Doc_Items
 --
 --   Version : Current version 1.0
 --   p_validation_mode is a constant defined in AMS_UTILITY_PVT package
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


 PROCEDURE Check_Imp_Doc_Items (
     P_imp_doc_rec     IN    imp_doc_rec_type,
     p_validation_mode  IN    VARCHAR2,
     x_return_status    OUT NOCOPY   VARCHAR2
     );

 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Validate_Imp_Doc_Rec
 --
 --   Version : Current version 1.0
 --   p_validation_mode is a constant defined in AMS_UTILITY_PVT package
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


 PROCEDURE Validate_Imp_Doc_Rec (
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,
     p_imp_doc_rec               IN    imp_doc_rec_type
     );

END AMS_Imp_Doc_PVT;

 

/
