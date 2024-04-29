--------------------------------------------------------
--  DDL for Package OZF_ADJ_NEW_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ADJ_NEW_LINE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvanls.pls 120.0 2006/03/30 13:53:47 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Adj_New_Line_PVT
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
--             adj_new_line_rec_type
--   -------------------------------------------------------
--   Parameters:
--       offer_adj_new_line_id
--       offer_adjustment_id
--       volume_from
--       volume_to
--       volume_type
--       discount
--       discount_type
--       tier_type
--       creation_date
--       created_by
--       last_update_date
--       last_updated_by
--       last_update_login
--       object_version_number
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
TYPE adj_new_line_rec_type IS RECORD
(
       offer_adj_new_line_id           NUMBER ,
       offer_adjustment_id             NUMBER ,
       volume_from                     NUMBER ,
       volume_to                       NUMBER ,
       volume_type                     VARCHAR2(30) ,
       discount                        NUMBER ,
       discount_type                   VARCHAR2(30) ,
       tier_type                       VARCHAR2(30) ,
       td_discount                     NUMBER       ,
       td_discount_type                VARCHAR2(30) ,
       quantity                        NUMBER       ,
       benefit_price_list_line_id      NUMBER       ,
       parent_adj_line_id              NUMBER       ,
       start_date_active               DATE,
       end_date_active                 DATE,
       creation_date                   DATE ,
       created_by                      NUMBER ,
       last_update_date                DATE ,
       last_updated_by                 NUMBER ,
       last_update_login               NUMBER ,
       object_version_number           NUMBER
);

g_miss_adj_new_line_rec          adj_new_line_rec_type;
TYPE  adj_new_line_tbl_type      IS TABLE OF adj_new_line_rec_type INDEX BY BINARY_INTEGER;
g_miss_adj_new_line_tbl          adj_new_line_tbl_type;

TYPE adj_new_disc_rec_type IS RECORD
(
       offer_adj_new_line_id           NUMBER ,
       offer_adjustment_id             NUMBER ,
       volume_from                     NUMBER ,
       volume_to                       NUMBER ,
       volume_type                     VARCHAR2(30) ,
       discount                        NUMBER ,
       discount_type                   VARCHAR2(30) ,
       tier_type                       VARCHAR2(30) ,
       td_discount                     NUMBER       ,
       td_discount_type                VARCHAR2(30) ,
       quantity                        NUMBER       ,
       benefit_price_list_line_id      NUMBER       ,
       parent_adj_line_id              NUMBER       ,
       offer_adj_new_product_id        NUMBER ,
       product_context                 VARCHAR2(30) ,
       product_attribute               VARCHAR2(30) ,
       product_attr_value              VARCHAR2(240) ,
       excluder_flag                   VARCHAR2(1) ,
       uom_code                        VARCHAR2(30) ,
       start_date_active               DATE,
       end_date_active                 DATE,
       creation_date                   DATE ,
       created_by                      NUMBER ,
       last_update_date                DATE ,
       last_updated_by                 NUMBER ,
       last_update_login               NUMBER ,
       object_version_number           NUMBER ,
       prod_obj_version_number         NUMBER
);

g_miss_adj_new_disc_rec          adj_new_disc_rec_type;
TYPE  adj_new_disc_tbl_type      IS TABLE OF adj_new_disc_rec_type INDEX BY BINARY_INTEGER;
g_miss_adj_new_disc_tbl          adj_new_disc_tbl_type;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Adj_New_Line
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
--       p_adj_new_line_rec            IN   adj_new_line_rec_type  Required
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

PROCEDURE Create_Adj_New_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,

    p_adj_new_line_rec               IN   adj_new_line_rec_type  := g_miss_adj_new_line_rec,
    x_offer_adj_new_line_id                   OUT NOCOPY   NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Adj_New_Line
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
--       p_adj_new_line_rec            IN   adj_new_line_rec_type  Required
--
--   OUT
--       x_return_status           OUT NOCOPY   VARCHAR2
--       x_msg_count               OUT NOCOPY   NUMBER
--       x_msg_data                OUT NOCOPY   VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Update_Adj_New_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,

    p_adj_new_line_rec               IN    adj_new_line_rec_type,
    x_object_version_number      OUT NOCOPY   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Adj_New_Line
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
--       p_OFFER_ADJ_NEW_LINE_ID                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT NOCOPY   VARCHAR2
--       x_msg_count               OUT NOCOPY   NUMBER
--       x_msg_data                OUT NOCOPY   VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Delete_Adj_New_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,
    p_offer_adj_new_line_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Adj_New_Line
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
--       p_adj_new_line_rec            IN   adj_new_line_rec_type  Required
--
--   OUT
--       x_return_status           OUT NOCOPY   VARCHAR2
--       x_msg_count               OUT NOCOPY   NUMBER
--       x_msg_data                OUT NOCOPY   VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Lock_Adj_New_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,

    p_offer_adj_new_line_id                   IN  NUMBER,
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


PROCEDURE Validate_adj_new_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.g_update,
    p_adj_new_line_rec           IN   adj_new_line_rec_type,
    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2
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

PROCEDURE Check_adj_new_line_Items (
    P_adj_new_line_rec     IN    adj_new_line_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY    VARCHAR2
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

PROCEDURE Validate_adj_new_line_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,
    p_adj_new_line_rec               IN    adj_new_line_rec_type
    );

PROCEDURE Create_Adj_New_Disc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,

    p_adj_new_disc_rec               IN   adj_new_disc_rec_type  := g_miss_adj_new_disc_rec,
    x_offer_adj_new_line_id                   OUT NOCOPY   NUMBER
    );

PROCEDURE Update_Adj_New_Disc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,

    p_adj_new_disc_rec               IN    adj_new_disc_rec_type,
    x_object_version_number      OUT NOCOPY   NUMBER
    );


END OZF_Adj_New_Line_PVT;

 

/
