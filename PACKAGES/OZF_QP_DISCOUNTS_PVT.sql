--------------------------------------------------------
--  DDL for Package OZF_QP_DISCOUNTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_QP_DISCOUNTS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvoqpds.pls 120.2 2005/08/24 06:21 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--
-- Purpose
--
-- History
--
-- NOTE

-- End of Comments
-- ===============================================================


TYPE qp_discount_rec_type IS RECORD
(
        OZF_QP_DISCOUNT_ID NUMBER
        , LIST_LINE_ID NUMBER
        , OFFER_DISCOUNT_LINE_ID NUMBER
        , START_DATE DATE
        , END_DATE DATE
        , OBJECT_VERSION_NUMBER NUMBER
        , CREATION_DATE DATE
        , CREATED_BY NUMBER
        , LAST_UPDATED_BY NUMBER
        , LAST_UPDATE_DATE DATE
        , LAST_UPDATE_LOGIN NUMBER
        );

g_miss_qp_disc_rec qp_discount_rec_type := NULL;

TYPE qp_discount_tbl_type IS TABLE OF qp_discount_rec_type INDEX BY BINARY_INTEGER;

g_miss_qp_prod_tbl qp_discount_tbl_type ;

PROCEDURE Create_ozf_qp_discount
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_disc_rec               IN    qp_discount_rec_type,
    x_qp_discount_id             OUT NOCOPY NUMBER
);


PROCEDURE Update_ozf_qp_discount
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_disc_rec               IN    qp_discount_rec_type
);

PROCEDURE Delete_ozf_qp_discount
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_discount_id             IN NUMBER,
    p_object_version_number      IN NUMBER
);

END OZF_QP_DISCOUNTS_PVT;

 

/
