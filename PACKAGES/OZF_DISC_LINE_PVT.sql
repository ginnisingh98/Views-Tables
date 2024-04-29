--------------------------------------------------------
--  DDL for Package OZF_DISC_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_DISC_LINE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvodls.pls 120.1 2006/05/04 15:25:50 julou noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Disc_Line_PVT
-- Purpose
--
-- History
--           Thu Oct 02 2003:1/8 PM  RSSHARMA Created
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
--             ozf_offer_line_rec_type
--   -------------------------------------------------------
--   Parameters:
--       offer_discount_line_id
--       parent_discount_line_id
--       volume_from
--       volume_to
--       volume_operator
--       volume_type
--       volume_break_type
--       discount
--       discount_type
--       tier_type
--       tier_level
--       incompatibility_group
--       precedence
--       bucket
--       scan_value
--       scan_data_quantity
--       scan_unit_forecast
--       channel_id
--       adjustment_flag
--       start_date_active
--       end_date_active
--       uom_code
--       creation_date
--       created_by
--       last_update_date
--       last_updated_by
--       last_update_login
--       object_version_number
--       offer_id
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
TYPE ozf_offer_line_rec_type IS RECORD
(
       offer_discount_line_id          NUMBER,
       parent_discount_line_id         NUMBER,
       volume_from                     NUMBER,
       volume_to                       NUMBER,
       volume_operator                 VARCHAR2(30),
       volume_type                     VARCHAR2(30),
       volume_break_type               VARCHAR2(30),
       discount                        NUMBER,
       discount_type                   VARCHAR2(30),
       tier_type                       VARCHAR2(30),
       tier_level                      VARCHAR2(30),
       incompatibility_group           VARCHAR2(30),
       precedence                      NUMBER,
       bucket                          VARCHAR2(30),
       scan_value                      NUMBER,
       scan_data_quantity              NUMBER,
       scan_unit_forecast              NUMBER,
       channel_id                      NUMBER,
       adjustment_flag                 VARCHAR2(1),
       start_date_active               DATE,
       end_date_active                 DATE,
       uom_code                        VARCHAR2(30),
       creation_date                   DATE,
       created_by                      NUMBER,
       last_update_date                DATE,
       last_updated_by                 NUMBER,
       last_update_login               NUMBER,
       object_version_number           NUMBER,
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
       offer_id                        NUMBER
);

g_miss_ozf_offer_line_rec          ozf_offer_line_rec_type := NULL;
TYPE  ozf_offer_line_tbl_type      IS TABLE OF ozf_offer_line_rec_type INDEX BY BINARY_INTEGER;
g_miss_ozf_offer_line_tbl          ozf_offer_line_tbl_type;

TYPE ozf_offer_tier_rec_type IS RECORD
(
       offer_discount_line_id          NUMBER,
       parent_discount_line_id         NUMBER,
       offer_id                        NUMBER,
       volume_from                     NUMBER,
       volume_to                       NUMBER,
       volume_operator                 VARCHAR2(30),
       volume_type                     VARCHAR2(30),
       volume_break_type               VARCHAR2(30),
       discount                        NUMBER,
       discount_type                   VARCHAR2(30),
       start_date_active               DATE,
       end_date_active                 DATE,
       uom_code                        VARCHAR2(30),
       object_version_number           NUMBER,
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
       attribute15                     VARCHAR2(240)
);


/*       tier_type                       VARCHAR2(10),
       tier_level                      VARCHAR2(10),
       offer_id                        NUMBER
*/

g_miss_ozf_offer_tier_rec          ozf_offer_tier_rec_type := NULL;
TYPE  ozf_offer_tier_tbl_type      IS TABLE OF ozf_offer_tier_rec_type INDEX BY BINARY_INTEGER;
g_miss_ozf_offer_tier_tbl          ozf_offer_tier_tbl_type;




 --===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             ozf_prod_rec_type
--   -------------------------------------------------------
--   Parameters:
--       off_discount_product_id
--       product_level
--       product_id
--       excluder_flag
--       uom_code
--       start_date_active
--       end_date_active
--       offer_discount_line_id
--       offer_id
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

TYPE ozf_discount_line_rec_type IS RECORD
(
       offer_discount_line_id          NUMBER,
       parent_discount_line_id         NUMBER,
       volume_from                     NUMBER,
       volume_to                       NUMBER,
       volume_operator                 VARCHAR2(30),
       volume_type                     VARCHAR2(30),
       volume_break_type               VARCHAR2(30),
       discount                        NUMBER,
       discount_type                   VARCHAR2(30),
       tier_type                       VARCHAR2(30),
       tier_level                      VARCHAR2(30),
       incompatibility_group           VARCHAR2(30),
       precedence                      NUMBER,
       bucket                          VARCHAR2(30),
       scan_value                      NUMBER,
       scan_data_quantity              NUMBER,
       scan_unit_forecast              NUMBER,
       channel_id                      NUMBER,
       adjustment_flag                 VARCHAR2(1),
       start_date_active               DATE,
       end_date_active                 DATE,
       uom_code                        VARCHAR2(30),
       creation_date                   DATE,
       created_by                      NUMBER,
       last_update_date                DATE,
       last_updated_by                 NUMBER,
       last_update_login               NUMBER,
       object_version_number           NUMBER,
       offer_id                        NUMBER,
       off_discount_product_id         NUMBER,
       parent_off_disc_prod_id         NUMBER,
       product_level                   VARCHAR2(30),
       product_id                      NUMBER,
       excluder_flag                   VARCHAR2(1),
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
       attribute15                     VARCHAR2(240)
);

TYPE  ozf_discount_line_tbl      IS TABLE OF ozf_discount_line_rec_type INDEX BY BINARY_INTEGER;




TYPE ozf_prod_rec_type IS RECORD
(
       off_discount_product_id         NUMBER,
       parent_off_disc_prod_id         NUMBER,
       product_level                   VARCHAR2(30),
       product_id                      NUMBER,
       excluder_flag                   VARCHAR2(1),
       uom_code                        VARCHAR2(30),
       start_date_active               DATE,
       end_date_active                 DATE,
       offer_discount_line_id          NUMBER,
       offer_id                        NUMBER,
       creation_date                   DATE,
       created_by                      NUMBER,
       last_update_date                DATE,
       last_updated_by                 NUMBER,
       last_update_login               NUMBER,
       object_version_number           NUMBER
);
g_miss_ozf_prod_rec          ozf_prod_rec_type := NULL;
TYPE  prod_rec_tbl_type      IS TABLE OF ozf_prod_rec_type INDEX BY BINARY_INTEGER;


TYPE ozf_excl_rec_type IS RECORD
(
       off_discount_product_id         NUMBER,
       parent_off_disc_prod_id         NUMBER,
       product_level                   VARCHAR2(30),
       product_id                      NUMBER,
       object_version_number           NUMBER,
       start_date_active               DATE,
       end_date_active                 DATE
);
g_miss_ozf_excl_rec          ozf_excl_rec_type := NULL;
TYPE  excl_rec_tbl_type      IS TABLE OF ozf_excl_rec_type INDEX BY BINARY_INTEGER;



--g_miss_prod_rec_tbl          prod_reln_tbl_type;


--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             prod_reln_rec_type
--   -------------------------------------------------------
--   Parameters:
--       discount_product_reln_id
--       offer_discount_line_id
--       off_discount_product_id
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
TYPE prod_reln_rec_type IS RECORD
(
       discount_product_reln_id        NUMBER,
       offer_discount_line_id          NUMBER,
       off_discount_product_id         NUMBER,
       creation_date                   DATE,
       created_by                      NUMBER,
       last_update_date                DATE,
       last_updated_by                 NUMBER,
       last_update_login               NUMBER,
       object_version_number           NUMBER
);

g_miss_prod_reln_rec          prod_reln_rec_type := NULL;
TYPE  prod_reln_tbl_type      IS TABLE OF prod_reln_rec_type INDEX BY BINARY_INTEGER;
g_miss_prod_reln_tbl          prod_reln_tbl_type;







--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Product
--   Type
--           Private
--   Pre-Req
--             Delete_Relation,OZF_Create_Ozf_Prod_Line_PKG.Delete_product
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_offer_discount_line_id  IN NUMBER       Required  All the products attached to this discount line will be deleted
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to Hard Delete All the Products for a given discount line
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_discount_line_id     IN NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Offer_line
--   Type
--           Private
--   Pre-Req
--             Delete_Product,delete_Ozf_Disc_Line
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_offer_discount_line_id  IN   NUMBER     Required  Discount Line id to be deleted
--       p_object_version_number   IN   NUMBER     Required  Object Version No. Of Discount Line to be deleted
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_off_discount_product_id OUT  NUMBER
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to Hard Delete a Discount Line and all the Related Product Lines and relations.
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_offer_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_discount_line_id     IN NUMBER,
    p_object_version_number      IN NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_discount_line
--   Type
--           Private
--   Pre-Req
--             Create_Ozf_Disc_Line,Create Product
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_offer_line_rec      IN   ozf_offer_line_rec_type   Required Record containing Discount Line Data
--       p_ozf_prod_rec            IN   ozf_prod_rec_type   Required Record containing Product Data
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_offer_discount_line_id  OUT  NUMBER. Discount Line Id of Discount Line Created
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Method to Create New Discount Lines.
--   End of Comments
--   ==============================================================================

PROCEDURE Create_discount_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_discount_line_rec              IN   ozf_discount_line_rec_type  ,
    x_offer_discount_line_id              OUT NOCOPY  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_discount_line
--   Type
--           Private
--   Pre-Req
--             Create_Ozf_Disc_Line,Create Product
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_discount_line_rec   IN   ozf_discount_line_rec_type Required Record Containing Discount Line Data
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Method to Update Discount Lines.
--   End of Comments
--   ==============================================================================
PROCEDURE Update_discount_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_discount_line_rec              IN   ozf_discount_line_rec_type
);



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Product_Exclusion
--   Type
--           Private
--   Pre-Req
--             Create_Product
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_prod_rec            IN   ozf_prod_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_off_discount_product_id OUT  NUMBER
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to create Exclusions for Discount Lines.
--              Does the following validations
--              1)if excluder flag is not Y then it is set to Y
--              2)If parent_off_disc_prod_id should not be null
--              3)If parent_off_disc_prod_id should be a valid off_discount_product_id for the same offer
--   End of Comments
--   ==============================================================================

PROCEDURE Create_Product_Exclusion
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_excl_rec               IN   ozf_excl_rec_type  ,
    x_off_discount_product_id    OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Product_Exclusion
--   Type
--           Private
--   Pre-Req
--             Create_Product
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_prod_rec            IN   ozf_prod_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to Update Exclusions for Discount Lines.
--              Does the following validations
--              1)if excluder flag is not Y then Raises Error message saying the line is not an exclusion line.
--               Use Update Discount Lines to Update normal Discount lines
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Product_Exclusion(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_excl_rec               IN   ozf_excl_rec_type
     );


PROCEDURE Create_Disc_Tiers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_tier_rec               IN   ozf_offer_tier_rec_type  ,
    x_offer_discount_line_id     OUT NOCOPY NUMBER
);

PROCEDURE Update_Disc_Tiers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_tier_rec               IN   ozf_offer_tier_rec_type
);

PROCEDURE Delete_Disc_tiers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_parent_discount_line_id     IN NUMBER
);
PROCEDURE Delete_Tier_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_discount_line_id     IN NUMBER,
    p_object_version_number      IN NUMBER
);


PROCEDURE Create_Ozf_Prod_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_prod_rec              IN   ozf_prod_rec_type  ,
    x_off_discount_product_id              OUT NOCOPY  NUMBER
     );

PROCEDURE Update_Ozf_Prod_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_prod_rec               IN    ozf_prod_rec_type
    );

PROCEDURE Delete_Ozf_Prod_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_off_discount_product_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );


END OZF_Disc_Line_PVT;



 

/
