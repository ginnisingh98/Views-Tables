--------------------------------------------------------
--  DDL for Package OZF_VOLUME_OFFER_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_VOLUME_OFFER_ADJ" AUTHID CURRENT_USER AS
/* $Header: ozfvvads.pls 120.1 2006/03/29 17:58 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_VOLUME_OFFER_ADJ
-- Purpose
--
-- History
-- Tue Mar 14 2006:4/40 PM RSSHARMA Created
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE adjust_old_discounts
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);

PROCEDURE adjust_new_products
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);

PROCEDURE process_vo_adjustments
(
  p_init_msg_list         IN   VARCHAR2 := FND_API.g_false
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2 := FND_API.g_false
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);
----------------------------------------New temp procedures to ber deleted
PROCEDURE update_adj_vo_tiers
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);
PROCEDURE end_date_qp_lines
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);
PROCEDURE end_qp_line
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_listLineId           IN NUMBER
  ,p_offerAdjustmentId     IN NUMBER
);

PROCEDURE populate_modifier_lines
(
  x_return_status         OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_listLineId   IN   NUMBER
  , x_modifier_line_tbl    OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , x_pricing_attr_tbl          OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
  , p_offerAdjustmentId     IN   NUMBER
);

PROCEDURE create_new_qp_lines
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , x_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
);
PROCEDURE create_modifier_from_line
(
  x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_offerAdjustmentId     IN   NUMBER
  , p_listLineId            IN NUMBER
  , x_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
);
PROCEDURE create_new_products
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);
PROCEDURE create_new_qp_products
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , x_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
);

PROCEDURE create_new_exclusions
(
    p_offDiscountProductId      IN NUMBER
    , x_return_status         OUT NOCOPY  VARCHAR2
    , x_msg_count             OUT NOCOPY  NUMBER
    , x_msg_data              OUT NOCOPY  VARCHAR2
);
PROCEDURE relate_lines
(
  p_from_list_line_id IN NUMBER
  , p_to_list_line_id IN NUMBER
  , p_offer_adjustment_id IN NUMBER
  , x_return_status         OUT NOCOPY VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
);
PROCEDURE populate_discounts
(
 x_modifiers_rec  IN OUT NOCOPY Qp_Modifiers_Pub.modifiers_rec_type
, p_list_line_id  IN NUMBER
);
PROCEDURE populate_pricing_attributes
(
 x_pricing_attr_tbl OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
 , p_list_line_id IN NUMBER
 , p_index IN NUMBER
);
PROCEDURE merge_pricing_attributes
(
  px_to_pricing_attr_tbl    IN OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
  , p_from_pricing_attr_tbl IN QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
);
PROCEDURE merge_modifiers
(
  px_to_modifier_line_tbl    IN OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , p_from_modifier_line_tbl IN QP_MODIFIERS_PUB.Modifiers_Tbl_Type
);
PROCEDURE populate_pbh_line
(
  x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_listLineId            IN   NUMBER
  , x_modifier_line_tbl     OUT NOCOPY QP_MODIFIERS_PUB.Modifiers_Tbl_Type
  , x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
);
PROCEDURE relate_lines
(
 p_modifiers_tbl          IN qp_modifiers_pub.modifiers_tbl_type
  , p_offer_adjustment_id IN NUMBER
  , x_return_status         OUT NOCOPY VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
);
END OZF_VOLUME_OFFER_ADJ;


 

/
