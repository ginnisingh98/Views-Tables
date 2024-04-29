--------------------------------------------------------
--  DDL for Package OZF_QP_PRODUCTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_QP_PRODUCTS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvoqpps.pls 120.3 2005/08/25 04:19:24 rssharma noship $ */
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
-- object_version_number
-- last_update_date
-- last_updated_by
-- creation_date
-- created_by
-- last_update_login
-- security_group_id
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE qp_product_rec_type IS RECORD
(
 qp_product_id NUMBER
 , off_discount_product_id NUMBER
 , pricing_attribute_id NUMBER
 , object_version_number NUMBER
, last_update_date DATE
, last_updated_by NUMBER
, creation_date DATE
, created_by NUMBER
, last_update_login NUMBER
, security_group_id NUMBER
);


g_miss_qp_prod_rec          qp_product_rec_type := NULL;
TYPE  qp_product_tbl_type      IS TABLE OF qp_product_rec_type INDEX BY BINARY_INTEGER;
g_miss_qp_prod_tbl          qp_product_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_ozf_qp_product
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_qp_product_rec               IN   qp_product_rec_type
--   OUT
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--       x_qp_product_id  OUT NOCOPY  NUMBER. qp product id of the market option just created
--   Version : Current version 1.0
--
--   History
--
--   Description
--              : Method to Create relation between ozf and qp products
--   End of Comments
--   ==============================================================================

PROCEDURE Create_ozf_qp_product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_product_rec             IN   qp_product_rec_type ,
    x_qp_product_id              OUT NOCOPY  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_market_options
--   Type
--           Private
--   Pre-Req
--             validate_market_options
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_qp_product_rec               IN   qp_product_rec_type
--   OUT
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--
--   Description
--              : Method to Update ozf qp product relation
--   End of Comments
--   ==============================================================================
PROCEDURE Update_ozf_qp_product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_product_rec             IN   qp_product_rec_type
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_ozf_qp_product
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
--    p_qp_product_id              IN  NUMBER
--    p_object_version_number      IN   NUMBER

--
--   OUT
--    x_return_status              OUT NOCOPY  VARCHAR2
--    x_msg_count                  OUT NOCOPY  NUMBER
--    x_msg_data                   OUT NOCOPY  VARCHAR2

--   Version : Current version 1.0
--
--   History
--            Mon Jun 20 2005:7/55 PM  Created
--
--   Description
--   End of Comments
--   ==============================================================================
PROCEDURE Delete_ozf_qp_product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_qp_product_id              IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );
PROCEDURE Validate_ozf_qp_products
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_product_rec                     IN   qp_product_rec_type
    );

END OZF_QP_PRODUCTS_PVT;


 

/
