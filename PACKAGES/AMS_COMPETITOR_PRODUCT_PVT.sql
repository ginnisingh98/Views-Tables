--------------------------------------------------------
--  DDL for Package AMS_COMPETITOR_PRODUCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_COMPETITOR_PRODUCT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcprs.pls 120.1 2005/08/04 08:19:13 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          Ams_Competitor_Product_Pvt
-- Purpose
--
-- History
--   01-Oct-2001    musman    Created.
--   05-Nov-2001    musman    Commented out the reference to security_group_id
--   10-Sep-2003   Musman     Added Changes reqd for interest type to category
--   04-Aug-2005   inanaiah  R12 change - added a DFF
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
--             comp_prod_rec_type
--   -------------------------------------------------------
--   Parameters:
--       competitor_product_id
--       object_version_number
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       competitor_party_id
--       competitor_product_code
--       interest_type_id
--       inventory_item_id
--       organization_id
--       comp_product_url
--       original_system_ref
--       security_group_id
--       competitor_product_name
--       description
--       start_date
--       end_date
--       category_id
--       category_set_id
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
TYPE comp_prod_rec_type IS RECORD
(
       competitor_product_id           NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       competitor_party_id             NUMBER := FND_API.G_MISS_NUM,
       competitor_product_code         VARCHAR2(30) := FND_API.G_MISS_CHAR,
       interest_type_id                NUMBER := FND_API.G_MISS_NUM,
       inventory_item_id               NUMBER := FND_API.G_MISS_NUM,
       organization_id                 NUMBER := FND_API.G_MISS_NUM,
       comp_product_url                VARCHAR2(100) := FND_API.G_MISS_CHAR,
       original_system_ref             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       --security_group_id             NUMBER := FND_API.G_MISS_NUM,
       competitor_product_name         VARCHAR2(240) := FND_API.G_MISS_CHAR,
       description                     VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       start_date                      DATE      := FND_API.G_MISS_DATE,
       end_date                        DATE      := FND_API.G_MISS_DATE,
       category_id                     NUMBER := FND_API.G_MISS_NUM,
       category_set_id                 NUMBER := FND_API.G_MISS_NUM,
       context                         VARCHAR2(30),
       attribute1                      VARCHAR2(150),
       attribute2                      VARCHAR2(150),
       attribute3                      VARCHAR2(150),
       attribute4                      VARCHAR2(150),
       attribute5                      VARCHAR2(150),
       attribute6                      VARCHAR2(150),
       attribute7                      VARCHAR2(150),
       attribute8                      VARCHAR2(150),
       attribute9                      VARCHAR2(150),
       attribute10                      VARCHAR2(150),
       attribute11                      VARCHAR2(150),
       attribute12                      VARCHAR2(150),
       attribute13                      VARCHAR2(150),
       attribute14                      VARCHAR2(150),
       attribute15                      VARCHAR2(150)
);

g_miss_comp_prod_type_rec          comp_prod_rec_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Comp_Product
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
--       p_comp_prod_rec            IN   comp_prod_rec_type  Required
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

PROCEDURE Create_Comp_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_comp_prod_rec               IN   comp_prod_rec_type  := g_miss_comp_prod_type_rec ,
    x_competitor_product_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Comp_Product
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
--       p_comp_prod_rec            IN   comp_prod_rec_type  Required
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

PROCEDURE Update_Comp_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_comp_prod_rec               IN    comp_prod_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Comp_Product
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
--       p_COMPETITOR_PRODUCT_ID                IN   NUMBER
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

PROCEDURE Delete_Comp_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_competitor_product_id      IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Ams_Competitor_Product_Pvt
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
--       p_comp_prod_rec            IN   comp_prod_rec_type  Required
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

PROCEDURE Lock_Comp_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_competitor_product_id                   IN  NUMBER,
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

PROCEDURE Validate_comp_prod(
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
  p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_validation_mode            IN   VARCHAR2 := JTF_PLSQL_API.g_create,
  p_comp_prod_rec               IN   comp_prod_rec_type,
  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2
    );

END Ams_Competitor_Product_Pvt;

 

/
