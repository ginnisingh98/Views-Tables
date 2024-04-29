--------------------------------------------------------
--  DDL for Package OZF_VOLUME_OFFER_DISC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_VOLUME_OFFER_DISC_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvvods.pls 120.5 2006/05/05 11:06:00 julou noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--
-- Purpose
--
-- History
--
-- NOTE
--            Mon Jun 20 2005:2/19 PM RSSHARMA Added new procedure copy_vo_discounts
-- Wed Aug 24 2005:1/34 AM RSSHARMA Made all out and in-out params nocopy
-- Sat Oct 01 2005:6/23 PM Added function get_discount_line_exists to check if a pbh line exists
-- Tue Oct 11 2005:5/55 PM RSSHARMA Added debug_message api
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
TYPE vo_disc_rec_type IS RECORD
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
       discount_by_code                VARCHAR2(30),
       formula_id                      NUMBER,
       offr_disc_struct_name_id        NUMBER,
       name                            VARCHAR2(240),
       description                     VARCHAR2(2000),
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

g_miss_vo_disc_rec_type          vo_disc_rec_type := NULL;
TYPE  ozf_vo_disc_tbl_type      IS TABLE OF vo_disc_rec_type INDEX BY BINARY_INTEGER;
g_miss_ozf_vo_disc_tbl          ozf_vo_disc_tbl_type;


TYPE vo_prod_rec_type IS RECORD
(
         off_discount_product_id NUMBER,
         product_level           VARCHAR2(30),
         product_id              NUMBER,
         excluder_flag           VARCHAR2(1),
         uom_code                VARCHAR2(30),
         start_date_active       DATE,
         end_date_active         DATE,
         offer_discount_line_id  NUMBER,
         offer_id                NUMBER,
         creation_date           DATE,
         created_by              NUMBER,
         last_update_date        DATE,
         last_updated_by         NUMBER,
         last_update_login       NUMBER,
         object_version_number   NUMBER,
         parent_off_disc_prod_id NUMBER,
         product_context         VARCHAR2(30),
         product_attribute       VARCHAR2(30),
         product_attr_value      VARCHAR2(240),
         apply_discount_flag     VARCHAR2(1),
         include_volume_flag     VARCHAR2(1)
 );
g_miss_ozf_vo_prod_rec          vo_prod_rec_type := NULL;
TYPE  vo_prod_rec_tbl_type      IS TABLE OF vo_prod_rec_type INDEX BY BINARY_INTEGER;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_vo_discount
--   Type
--           Private
--   Pre-Req
--             OZF_Create_Ozf_Prod_Line_PKG.Delete_Product,OZF_DISC_LINE_PKG.Delete_Row
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
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to Hard Delete a Discount Line and all the Related Product Lines for a volume offer
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_vo_discount(
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

PROCEDURE Create_vo_discount(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_vo_disc_rec           IN   vo_disc_rec_type  ,
    x_vo_discount_line_id        OUT NOCOPY  NUMBER
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
PROCEDURE Update_vo_discount(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_vo_disc_rec           IN   vo_disc_rec_type
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_vo_Product
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_api_version_number         IN   NUMBER
--    p_init_msg_list            IN   VARCHAR2
--    p_validation_level           IN   NUMBER
--    p_vo_prod_rec              IN  vo_prod_rec_type
--    p_validation_mode          IN VARCHAR2
--
--   OUT
--    x_return_status              OUT  VARCHAR2
--    x_msg_count                  OUT  NUMBER
--    x_msg_data                   OUT  VARCHAR2

--   Version : Current version 1.0
--
--   History
--            Mon May 16 2005:5/41 PM RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE Create_vo_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_vo_prod_rec                   IN   vo_prod_rec_type  ,
    x_off_discount_product_id    OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_vo_Product
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_api_version_number         IN   NUMBER
--    p_init_msg_list            IN   VARCHAR2
--    p_validation_level           IN   NUMBER
--    p_vo_prod_rec              IN  vo_prod_rec_type
--    p_validation_mode          IN VARCHAR2
--
--   OUT
--    x_return_status              OUT  VARCHAR2
--    x_msg_count                  OUT  NUMBER
--    x_msg_data                   OUT  VARCHAR2

--   Version : Current version 1.0
--
--   History
--            Mon May 16 2005:5/41 PM RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE Update_vo_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_vo_prod_rec                   IN   vo_prod_rec_type
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_vo_Product
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_api_version_number         IN   NUMBER
--    p_init_msg_list              IN   VARCHAR2
--    p_commit                     IN   VARCHAR2
--    p_validation_level           IN   NUMBER
--    p_off_discount_product_id    IN  NUMBER
--    p_object_version_number      IN   NUMBER

--
--   OUT
--    x_return_status              OUT  VARCHAR2
--    x_msg_count                  OUT  NUMBER
--    x_msg_data                   OUT  VARCHAR2

--   Version : Current version 1.0
--
--   History
--            Mon May 16 2005:5/41 PM RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_vo_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_off_discount_product_id    IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

PROCEDURE copy_vo_discounts
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_discount_line_id        IN   NUMBER ,
    p_vo_disc_rec                IN vo_disc_rec_type,
    x_vo_discount_line_id        OUT NOCOPY  NUMBER
);

PROCEDURE check_vo_product_attr(
     p_vo_prod_rec              IN  vo_prod_rec_type
    , x_return_status              OUT NOCOPY  VARCHAR2
      );

FUNCTION get_discount_line_exists
( p_offerDiscountLineId IN NUMBER)
RETURN VARCHAR2;

PROCEDURE debug_message(p_message IN VARCHAR2);


END OZF_Volume_Offer_disc_PVT;


 

/
