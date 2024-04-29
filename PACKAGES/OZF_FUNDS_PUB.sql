--------------------------------------------------------
--  DDL for Package OZF_FUNDS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUNDS_PUB" AUTHID CURRENT_USER AS
/* $Header: OZFPFUNS.pls 120.6 2006/05/24 09:35:20 asylvia ship $ */
/*#
* Use this package to create, update and delete funds and
* create, update and delete market segments and
* product eligibilities for funds and quotas in Oracle Trade Management.
* Funds are also known as budgets
* @rep:scope public
* @rep:product OZF
* @rep:lifecycle active
* @rep:displayname Budget Public API
* @rep:compatibility S
* @rep:businessevent None
* @rep:category BUSINESS_ENTITY OZF_BUDGET
*/

TYPE fund_rec_type IS RECORD
(fund_id                NUMBER
,fund_number            VARCHAR2(30)
,short_name             VARCHAR2(80)
,fund_type              VARCHAR2(30)
,custom_setup_id        NUMBER
,object_version_number  NUMBER
,description            VARCHAR2(4000)
,parent_fund_id         NUMBER
,parent_fund_name       VARCHAR2(80)
,category_id            NUMBER
,category_name          VARCHAR2(50)
,business_unit_id       NUMBER
,business_unit          VARCHAR2(50)
,status_code            VARCHAR2(30)
,user_status_id         NUMBER
,start_date_active      DATE
,end_date_active        DATE
,start_period_name      VARCHAR2(15)
,end_period_name        VARCHAR2(15)
,original_budget        NUMBER
,holdback_amt           NUMBER
,currency_code_tc       VARCHAR2(15)
,owner                  NUMBER
,accrual_basis          VARCHAR2(30)
,accrual_phase          VARCHAR2(30)
,accrual_discount_level VARCHAR2(30)
,threshold_id           NUMBER
,threshold_name         VARCHAR2(50)
,task_id                NUMBER
,task_name              VARCHAR2(50)
,org_id                 NUMBER
,liability_flag         VARCHAR2(1)
,ledger_id              NUMBER
,ledger_name            VARCHAR2(100)
,accrued_liable_account NUMBER
,ded_adjustment_account NUMBER
,product_spread_time_id NUMBER
);

TYPE mks_rec_type IS RECORD
(activity_market_segment_id     NUMBER
,market_segment_id              NUMBER
,act_market_segment_used_by_id  NUMBER
,arc_act_market_segment_used_by VARCHAR2(30)
,segment_type                   VARCHAR2(30)
,object_version_number          NUMBER
,exclude_flag                   VARCHAR2(1)
);

TYPE act_product_rec_type IS RECORD
(activity_product_id     NUMBER
,act_product_used_by_id  NUMBER
,arc_act_product_used_by VARCHAR2(30)
,inventory_item_name     VARCHAR2(100)
,inventory_item_id       NUMBER
,level_type_code         VARCHAR2(7)
,category_name           VARCHAR2(100)
,category_id             NUMBER
,category_set_id         NUMBER
,primary_product_flag    VARCHAR2(1)
,excluded_flag           VARCHAR2(1)
,object_version_number   NUMBER
,organization_id         NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Fund
--
-- PURPOSE
--    Create a new fund (fixed budget).
--
-- PARAMETERS
--    p_fund_rec: the new record to be inserted
--    x_fund_id: return the fund_id of the new fund
---------------------------------------------------------------------
/*#
* This procedure creates a new fixed budget.
* @param p_api_version        Indicates API version number.
* @param p_init_msg_list      Indicates whether to initialize the message stack.
* @param p_commit             Indicates whether to commit within the program.
* @param p_validation_level   Indicates validation level.
* @param x_return_status      Indicates program status.
* @param x_msg_data           Messages returned by the program.
* @param x_msg_count          Provides the number of the messages returned by the program.
* @param p_fund_rec           Identifies the new record to be inserted.
* @param x_fund_id            Returns the ID of the new fund.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Fixed Budget
* @rep:compatibility S
* @rep:businessevent None
*/
PROCEDURE Create_fund(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  ,p_fund_rec           IN         fund_rec_type
  ,x_fund_id            OUT NOCOPY NUMBER
  );

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Fund
--
-- PURPOSE
--    Create a new fund (fully accrued budget).
--
-- PARAMETERS
--    p_fund_rec: the new record to be inserted
--    x_fund_id: return the fund_id of the new fund
---------------------------------------------------------------------
/*#
* This procedure creates a new fully accrued budget.
* @param p_api_version        Indicates API version number.
* @param p_init_msg_list      Indicates whether to initialize the message stack.
* @param p_commit             Indicates whether to commit within the program.
* @param p_validation_level   Indicates validation level.
* @param x_return_status      Indicates program status.
* @param x_msg_data           Messages returned by the program.
* @param x_msg_count          Provides the number of the messages returned by the program.
* @param p_fund_rec           Identifies the new record to be inserted.
* @param p_modifier_list_rec  Offer header detail.
* @param p_modifier_line_tbl  Stores discount rules for accrual offer.
* @param p_vo_pbh_tbl         Stores discount structure information for volume offer.
* @param p_vo_dis_tbl         Stores discount tier information for volume offer.
* @param p_vo_prod_tbl        Stores discount product information for volume offer.
* @param p_qualifier_tbl      Stores the market eligibility values for volume offer.
* @param p_vo_mo_tbl          Stores market option information for volume offer.
* @param x_fund_id            Returns the ID of the new fund.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Fully Accrued Budget
* @rep:compatibility S
* @rep:businessevent None
*/
PROCEDURE Create_fund(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  ,p_fund_rec           IN         fund_rec_type
  ,p_modifier_list_rec  IN         ozf_offer_pub.modifier_list_rec_type
  ,p_modifier_line_tbl  IN         ozf_offer_pub.modifier_line_tbl_type
  ,p_vo_pbh_tbl         IN         ozf_offer_pub.vo_disc_tbl_type
  ,p_vo_dis_tbl         IN         ozf_offer_pub.vo_disc_tbl_type
  ,p_vo_prod_tbl        IN         ozf_offer_pub.vo_prod_tbl_type
  ,p_qualifier_tbl      IN         ozf_offer_pub.qualifiers_tbl_type
  ,p_vo_mo_tbl          IN         ozf_offer_pub.vo_mo_tbl_type
  ,x_fund_id            OUT NOCOPY NUMBER
  );


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Fund
--
-- PURPOSE
--    Delete a fund.
--
-- PARAMETERS
--    p_fund_id: the fund_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
/*#
* This procedure deletes an existing budget.
* @param p_api_version    Indicates API version number.
* @param p_init_msg_list  Indicates whether to initialize the message stack.
* @param p_commit         Indicates whether to commit within the program.
* @param x_return_status  Indicates program status.
* @param x_msg_count      Number of messages the program returns.
* @param x_msg_data       Messages returned by the program .
* @param p_fund_id        Fund identifier of the fund to be deleted.
* @param p_object_version Indicates the object version number.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Delete Budget
* @rep:compatibility S
* @rep:businessevent None
*/
PROCEDURE Delete_Fund(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_fund_id           IN  NUMBER
  ,p_object_version    IN  NUMBER
  );

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Fund
--
-- PURPOSE
--    Update a fund.
--
-- PARAMETERS
--    p_fund_rec: the record with new items.
--    p_mode    : determines what sort of validation is to be performed during update.
--              : The mode should always be 'UPDATE' except when updating the earned or committed amount
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
/**
 * This procedure updates an existing budget.
 * @param p_api_version       Indicates API version number.
 * @param p_init_msg_list     Indicates whether to initialize the message stack.
 * @param p_commit            Indicates whether to commit within the program.
 * @param p_validation_level  Indicates validation level.
 * @param x_return_status     Indicates program status.
 * @param x_msg_count         Indicates number of messages the program returns.
 * @param x_msg_data          Return message by the program.
 * @param p_fund_rec          Fund record to be updated.
 * @param p_modifier_list_rec Offer header detail.
 * @param p_modifier_line_tbl Stores discount rules for accrual offer.
 * @param p_vo_pbh_tbl        Stores discount structure information for volume offer.
 * @param p_vo_dis_tbl        Stores discount tier information for volume offer.
 * @param p_vo_prod_tbl       Stores discount product information for volume offer.
 * @param p_qualifier_tbl     Stores the market eligibility values for volume offer.
 * @param p_vo_mo_tbl         Stores market option information for volume offer.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Budget
 * @rep:compatibility S
 * @rep:businessevent None
 */
PROCEDURE Update_fund(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  ,p_fund_rec           IN         fund_rec_type
  ,p_modifier_list_rec  IN         ozf_offer_pub.modifier_list_rec_type
  ,p_modifier_line_tbl  IN         ozf_offer_pub.modifier_line_tbl_type
  ,p_vo_pbh_tbl         IN         ozf_offer_pub.vo_disc_tbl_type
  ,p_vo_dis_tbl         IN         ozf_offer_pub.vo_disc_tbl_type
  ,p_vo_prod_tbl        IN         ozf_offer_pub.vo_prod_tbl_type
  ,p_qualifier_tbl      IN         ozf_offer_pub.qualifiers_tbl_type
  ,p_vo_mo_tbl          IN         ozf_offer_pub.vo_mo_tbl_type
  );

---------------------------------------------------------------------
-- PROCEDURE
--    create_market_segment
--
-- PURPOSE
--    Creates a market segment for fund or quota.
--
-- PARAMETERS
--    p_mks_rec    : the record with new items
--    x_act_mks_id : return the market segment id for the fund
--
-- HISTORY
--    07/07/2005  kdass Created
----------------------------------------------------------------------
/*#
 * This procedure creates a market segment for an existing budget or quota.
 * @param p_api_version      Indicates API version number.
 * @param p_init_msg_list    Indicates whether to initialize the message stack.
 * @param p_commit           Indicates whether to commit within the program.
 * @param p_validation_level Indicates validation level.
 * @param p_mks_rec          Market segment record to be inserted.
 * @param x_return_status    Indicates program status.
 * @param x_msg_count        Indicates number of messages the program returns.
 * @param x_msg_data         Messages returned by the program.
 * @param x_act_mks_id       Indicates market segment id for the fund.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Market Segment
 * @rep:compatibility S
 * @rep:businessevent None
 */
PROCEDURE create_market_segment(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,p_mks_rec            IN         mks_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  ,x_act_mks_id         OUT NOCOPY NUMBER
  );

---------------------------------------------------------------------
-- PROCEDURE
--    update_market_segment
--
-- PURPOSE
--    Updates a market segment for fund or quota.
--
-- PARAMETERS
--    p_mks_rec : the record with items to be updated
--
-- HISTORY
--    07/07/2005  kdass Created
----------------------------------------------------------------------
/*#
 * This procedure updates a market segment for an existing budget or quota.
 * @param p_api_version      Indicates API version number.
 * @param p_init_msg_list    Indicates whether to initialize the message stack.
 * @param p_commit           Indicates whether to commit within the program.
 * @param p_validation_level Indicates validation level.
 * @param p_mks_rec          Market segment record to be updated.
 * @param x_return_status    Indicates program status.
 * @param x_msg_count        Number of messages the program returns.
 * @param x_msg_data         Messages returned by the program.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Market Segment
 * @rep:compatibility S
 * @rep:businessevent None
 */
PROCEDURE update_market_segment(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,p_mks_rec            IN         mks_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  );

---------------------------------------------------------------------
-- PROCEDURE
--    delete_market_segment
--
-- PURPOSE
--    Deletes a market segment for fund or quota.
--
-- PARAMETERS
--    p_act_mks_id : the market segment to be deleted
--
-- HISTORY
--    07/07/2005  kdass Created
----------------------------------------------------------------------
/*#
 * This procedure deletes a market segment for an existing budget or quota.
 * @param p_api_version      Indicates API version number.
 * @param p_init_msg_list    Indicates whether to initialize the message stack.
 * @param p_commit           Indicates whether to commit within the program.
 * @param p_act_mks_id       Market segment identifier of the market segment to be deleted.
 * @param x_return_status    Program Status.
 * @param x_msg_count        Number of messages the program returns.
 * @param x_msg_data         Messages returned by the program.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Market Segment
 * @rep:compatibility S
 * @rep:businessevent None
 */
PROCEDURE delete_market_segment(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_act_mks_id         IN         NUMBER
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  );

----------------------------------------------------------------------
-- PROCEDURE
--    create_product_eligibility
--
-- PURPOSE
--    Creates the product eligibility record for fund or quota.
--
-- PARAMETERS
--    p_act_product_rec : the record with new items
--    x_act_product_id  : return the activity product id for the fund or quota
--
-- HISTORY
--    07/11/2005  kdass Created
----------------------------------------------------------------------
/*#
 * This procedure creates a product eligibility record for an existing budget or quota.
 * @param p_api_version      Indicates API version number.
 * @param p_init_msg_list    Indicates whether to initialize the message stack.
 * @param p_commit           Indicates whether to commit within the program.
 * @param p_validation_level Indicates validation level.
 * @param p_act_product_rec  Product Eligibility record to be inserted.
 * @param x_return_status    Indicates program status.
 * @param x_msg_count        Number of messages the program returns.
 * @param x_msg_data         Messages returned by the program.
 * @param x_act_product_id   Indicates product's activity product id.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Product Eligibility
 * @rep:compatibility S
 * @rep:businessevent None
 */
PROCEDURE create_product_eligibility(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,p_act_product_rec    IN         act_product_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  ,x_act_product_id     OUT NOCOPY NUMBER
  );

---------------------------------------------------------------------
-- PROCEDURE
--    update_product_eligibility
--
-- PURPOSE
--    Updates the product eligibility record for fund or quota.
--
-- PARAMETERS
--    p_act_product_rec : the record with items to be updated
--
-- HISTORY
--    07/11/2005  kdass Created
----------------------------------------------------------------------
/*#
 * This procedure updates a product eligibility record for an existing budget or quota.
 * @param p_api_version      Indicates API version number.
 * @param p_init_msg_list    Indicates whether to initialize the message stack.
 * @param p_commit           Indicates whether to commit within the program.
 * @param p_validation_level Indicates validation level.
 * @param p_act_product_rec  Product eligibility record to be updated.
 * @param x_return_status    Indicates program status.
 * @param x_msg_count        Indicates number of messages the program returns.
 * @param x_msg_data         Messages returned by the program.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Product Eligibility
 * @rep:compatibility S
 * @rep:businessevent None
 */
PROCEDURE update_product_eligibility(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN         NUMBER := fnd_api.g_valid_level_full
  ,p_act_product_rec    IN         act_product_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  );

---------------------------------------------------------------------
-- PROCEDURE
--    delete_product_eligibility
--
-- PURPOSE
--    Deletes the product eligibility record for fund or quota.
--
-- PARAMETERS
--    p_act_product_id : the product eligibility to be deleted
--
-- HISTORY
--    07/11/2005  kdass Created
----------------------------------------------------------------------
/*#
 * This procedure deletes a product eligibility record for an existing budget or quota.
 * @param p_api_version      Indicates API version number.
 * @param p_init_msg_list    Indicates whether to initialize the message stack.
 * @param p_commit           Indicates whether to commit within the program .
 * @param p_act_product_id   Activity product identifier of the product eligibility record to be deleted.
 * @param x_return_status    Indicates program status.
 * @param x_msg_count        Indicates number of messages the program returns.
 * @param x_msg_data         Messages returned by the program.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Product Eligibility
 * @rep:compatibility S
 * @rep:businessevent None
 */
PROCEDURE delete_product_eligibility(
   p_api_version        IN         NUMBER
  ,p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
  ,p_commit             IN         VARCHAR2 := fnd_api.g_false
  ,p_act_product_id     IN         NUMBER
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  );

/*kdass - funds accrual process by business event descoped due to performance issues.
  added back by feliu since calling API don't descope.*/
PROCEDURE increase_order_message_counter;


END OZF_FUNDS_PUB;


 

/
