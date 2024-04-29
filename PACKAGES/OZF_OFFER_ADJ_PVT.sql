--------------------------------------------------------
--  DDL for Package OZF_OFFER_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_ADJ_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvoajs.pls 120.1 2006/03/29 17:43 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--
-- Purpose
--
-- History
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE process_old_discounts
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);
PROCEDURE process_new_products
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);
/**
Processes an Adjustment.
For a given adjustment.
End dates old discounts and creates corresponding new discounts
Create new disocunts for new products added thru. Adjustments
Maps the old list_line_id to the new list_line_id
*/
PROCEDURE process_adjustment
(
  p_init_msg_list         IN   VARCHAR2 := FND_API.g_false
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2 := FND_API.g_false
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);

PROCEDURE create_dis_line
(
  x_return_status          OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_listLineId            IN   NUMBER
  ,x_modifier_line_tbl     OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
  ,x_pricing_attr_tbl      OUT NOCOPY QP_MODIFIERS_PUB.Pricing_Attr_Tbl_Type
  , x_listLineId           OUT NOCOPY NUMBER
  , p_offerAdjustmentLineId IN NUMBER
  , p_offerAdjustmentId      IN NUMBER
);
PROCEDURE copyListLine
(
  x_return_status          OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_listLineId            IN   NUMBER
  , x_listLineId           OUT NOCOPY NUMBER
  , p_offerAdjustmentLineId IN NUMBER
  , p_offerAdjustmentId      IN NUMBER
);
PROCEDURE process_old_dis_discount
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_listLineId             IN NUMBER
  ,p_offerAdjustmentId      IN   NUMBER
  , p_offerAdjustmentLineId IN NUMBER
);

PROCEDURE process_old_reg_discount
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);

PROCEDURE copyPbhLine
(
  x_return_status          OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_pbhListLineId            IN   NUMBER
  ,p_offerAdjustmentId   IN   NUMBER
  ,x_modifier_line_tbl       OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
  );
PROCEDURE processOldPbhLines
(
  x_return_status          OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);

PROCEDURE createPgLine
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_listLineId            IN NUMBER
  , x_listLineId            OUT NOCOPY NUMBER
  , p_offerAdjustmentLineId IN NUMBER
  , p_offerAdjustmentId     IN NUMBER
  , x_pricing_attr_tbl      OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
  , x_modifier_line_tbl     OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
);

PROCEDURE copyPGListLine
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  , p_listLineId           IN NUMBER
  , x_listLineId           OUT NOCOPY NUMBER
  , p_offerAdjustmentLineId IN NUMBER
  ,p_offerAdjustmentId   IN NUMBER
);

PROCEDURE process_old_pg_discount
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);

PROCEDURE endDateTdLine
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , p_listLineId            IN NUMBER
);

PROCEDURE createTdLine
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , p_listLineId            IN NUMBER
  , x_modifier_tbl          OUT  NOCOPY QP_MODIFIERS_PUB.modifiers_tbl_type
);

PROCEDURE copyListLineExclusion
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_fromListLineId IN NUMBER
  ,p_toListLineId IN NUMBER
);

PROCEDURE copyTdLine
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , p_listLineId            IN NUMBER
  , x_listLineId            IN NUMBER
  , x_modifier_tbl          OUT NOCOPY QP_MODIFIERS_PUB.modifiers_tbl_type
);

PROCEDURE process_old_td_discount
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);
PROCEDURE relateTdLines
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , p_listLineId            IN NUMBER
  , p_modifier_tbl          IN QP_MODIFIERS_PUB.modifiers_tbl_type
);

PROCEDURE populateTdExclusion
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  , p_fromListLineId       IN NUMBER
  ,x_pricing_attr_tbl     OUT NOCOPY OZF_OFFER_PVT.PRICING_ATTR_TBL_TYPE
);

PROCEDURE processOldTdLine
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
  , p_listLineId            IN NUMBER
);
/*PROCEDURE processNewStProducts
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN NUMBER
);
*/
PROCEDURE createNewMtProduct
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_offerAdjNewLineId      IN NUMBER
  , x_modifier_line_tbl     OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
);
PROCEDURE createNewBuyProduct
(
  x_return_status           OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId      IN   NUMBER
  , x_modifier_tbl         OUT NOCOPY QP_MODIFIERS_PUB.modifiers_tbl_type
);
PROCEDURE processNewBuyProduct
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjNewLineId   IN   NUMBER
);

PROCEDURE processNewGetProduct
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
    ,p_offerAdjNewLineId     IN NUMBER
);
PROCEDURE processNewPgProducts
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offerAdjustmentId   IN   NUMBER
);

END OZF_OFFER_ADJ_PVT;


 

/
