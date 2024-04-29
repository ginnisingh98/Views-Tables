--------------------------------------------------------
--  DDL for Package OZF_OFFER_ADJ_PRODUCTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_ADJ_PRODUCTS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvoadps.pls 120.5 2005/08/25 06:41 rssharma noship $ */

TYPE offer_adj_prod_rec IS record
(
 offer_adjustment_product_id     NUMBER
 , offer_adjustment_id             NUMBER
 , offer_discount_line_id          NUMBER
 , off_discount_product_id         NUMBER
 , product_context                 VARCHAR2(30)
 , product_attribute               VARCHAR2(30)
 , product_attr_value              VARCHAR2(240)
 , excluder_flag                   VARCHAR2(1)
 , apply_discount_flag             VARCHAR2(1)
 , include_volume_flag             VARCHAR2(1)
 , object_version_number           NUMBER
 , last_update_date                DATE
 , last_updated_by                 NUMBER
 , creation_date                   DATE
 , created_by                      NUMBER
 , last_update_login               NUMBER
);

PROCEDURE CREATE_OFFER_ADJ_PRODUCT
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_adj_prod                   IN offer_adj_prod_rec,
    px_offer_adjustment_product_id OUT NOCOPY NUMBER
);

PROCEDURE UPDATE_OFFER_ADJ_PRODUCT
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_adj_prod_rec               IN offer_adj_prod_rec

);
PROCEDURE DELETE_OFFER_ADJ_PRODUCT
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_adjustment_product_id IN NUMBER,
    p_object_version_number       IN NUMBER
);

END OZF_OFFER_ADJ_PRODUCTS_PVT;

 

/
