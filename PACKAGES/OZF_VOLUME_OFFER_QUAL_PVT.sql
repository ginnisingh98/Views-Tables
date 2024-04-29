--------------------------------------------------------
--  DDL for Package OZF_VOLUME_OFFER_QUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_VOLUME_OFFER_QUAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvvoqs.pls 120.4 2005/08/24 06:33 rssharma noship $*/
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
-- Wed Aug 24 2005:1/21 AM rssharma Commented out showerrors and added nocopy hint to all out variables
-- End of Comments
-- ===============================================================


PROCEDURE create_vo_qualifier
(
    p_api_version_number         IN   NUMBER
    , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    , x_return_status              OUT NOCOPY  VARCHAR2
    , x_msg_count                  OUT NOCOPY  NUMBER
    , x_msg_data                   OUT NOCOPY  VARCHAR2

    , p_qualifiers_rec             IN   OZF_Offer_Pvt.qualifiers_rec_Type
);

FUNCTION create_mo_for_group(
    p_group_number NUMBER
    , p_qp_list_header_id NUMBER
) RETURN VARCHAR2;

FUNCTION get_market_option_id(p_group_number NUMBER,p_qp_list_header_id NUMBER) return number;


FUNCTION get_group_members(p_qp_list_header_id NUMBER,  p_group_number NUMBER)
RETURN VARCHAR2;


PROCEDURE update_vo_qualifier
(
    p_api_version_number         IN   NUMBER
    , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    , x_return_status              OUT NOCOPY  VARCHAR2
    , x_msg_count                  OUT NOCOPY  NUMBER
    , x_msg_data                   OUT NOCOPY  VARCHAR2

    , p_qualifiers_rec             IN   OZF_Offer_Pvt.qualifiers_Rec_Type
);
PROCEDURE Delete_vo_qualifier(
    p_api_version_number        IN NUMBER
    , p_init_msg_list           IN VARCHAR2     := FND_API.G_FALSE
    , p_commit                  IN VARCHAR2     := FND_API.G_FALSE
    , p_validation_level        IN NUMBER       := FND_API.G_VALID_LEVEL_FULL
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    , p_qualifier_id IN NUMBER
    );

END OZF_volume_offer_qual_PVT;


 

/
