--------------------------------------------------------
--  DDL for Package OZF_OFFER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_PUB" AUTHID CURRENT_USER AS
/* $Header: ozfpofrs.pls 120.6 2006/05/24 09:39:20 asylvia ship $ */
/*#
* Use the Offers Public API to create non-offer modules such as Referral.
* This API provides a single location for managing offers.
* You can modify budget requests and discount rules with just one call to the method public.
* @rep:scope public
* @rep:product OZF
* @rep:lifecycle active
* @rep:displayname Offer Public API
* @rep:category BUSINESS_ENTITY OZF_OFFERS
*/
G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_OFFER_PUB';

TYPE act_product_line_rec_type IS RECORD
(
   activity_product_id       NUMBER
  ,object_version_number     NUMBER(9)
  ,act_product_used_by_id    NUMBER
  ,arc_act_product_used_by   VARCHAR2(30)
  ,product_sale_type         VARCHAR2(30)
  ,primary_product_flag      VARCHAR2(1)
  ,enabled_flag              VARCHAR2(1)
  ,inventory_item_id         NUMBER(38)
  ,organization_id           NUMBER(32)
  ,category_id               NUMBER
  ,category_set_id           NUMBER
  ,attribute_category        VARCHAR2(30)
  ,level_type_code           VARCHAR2(30)
  ,excluded_flag             VARCHAR2(1)
  ,line_lumpsum_amount       NUMBER
  ,line_lumpsum_qty          NUMBER
  ,scan_value                NUMBER
  ,uom_code                  VARCHAR2(3)
  ,adjustment_flag           VARCHAR2(1)
  ,scan_unit_forecast        NUMBER
  ,channel_id                NUMBER
  ,quantity                  NUMBER
  ,operation                 VARCHAR2(30)
);
TYPE act_product_tbl_type IS TABLE OF act_product_line_rec_type INDEX BY BINARY_INTEGER;

TYPE discount_line_rec_type IS RECORD
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
       operation                       VARCHAR2(30)
);
TYPE discount_line_tbl_type IS TABLE OF discount_line_rec_type INDEX BY BINARY_INTEGER;

TYPE prod_rec_type IS RECORD
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
       object_version_number           NUMBER,
       operation                       VARCHAR2(30)
);
TYPE prod_rec_tbl_type IS TABLE OF prod_rec_type INDEX BY BINARY_INTEGER;

TYPE excl_rec_type IS RECORD
(
       off_discount_product_id         NUMBER,
       parent_off_disc_prod_id         NUMBER,
       product_level                   VARCHAR2(30),
       product_id                      NUMBER,
       object_version_number           NUMBER,
       start_date_active               DATE,
       end_date_active                 DATE,
       operation                       VARCHAR2(30)
);
TYPE excl_rec_tbl_type IS TABLE OF excl_rec_type INDEX BY BINARY_INTEGER;

TYPE offer_tier_rec_type IS RECORD
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
       operation                       VARCHAR2(30)
);
TYPE offer_tier_tbl_type IS TABLE OF offer_tier_rec_type INDEX BY BINARY_INTEGER;

TYPE na_qualifier_rec_type IS RECORD
(
        qualifier_id                    NUMBER,
        creation_date                   DATE,
        created_by                      NUMBER,
        last_update_date                DATE,
        last_updated_by                 NUMBER,
        last_update_login               NUMBER,
        qualifier_grouping_no           NUMBER,
        qualifier_context               VARCHAR2(30),
        qualifier_attribute             VARCHAR2(30),
        qualifier_attr_value            VARCHAR2(240),
        start_date_active               DATE,
        end_date_active                 DATE,
        offer_id                        NUMBER,
        offer_discount_line_id          NUMBER,
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
        active_flag                     VARCHAR2(1),
        object_version_number           NUMBER,
        operation                       VARCHAR2(30)
);
TYPE na_qualifier_tbl_type IS TABLE OF na_qualifier_rec_type INDEX BY BINARY_INTEGER;

TYPE budget_rec_type IS RECORD
(
   act_budget_id NUMBER
  ,budget_id     NUMBER
  ,budget_amount NUMBER
  ,operation     VARCHAR2(30)
);
TYPE budget_tbl_type IS TABLE OF budget_rec_type INDEX BY BINARY_INTEGER;

TYPE Modifier_LIST_Rec_Type IS RECORD
(
   offer_id                     NUMBER         := Fnd_Api.g_miss_num
  ,qp_list_header_id            NUMBER         := Fnd_Api.g_miss_num
  ,offer_type                   VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,offer_code                   VARCHAR2(100)  := Fnd_Api.g_miss_char
  ,activity_media_id            NUMBER         := Fnd_Api.g_miss_num
  ,reusable                     VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,user_status_id               NUMBER         := Fnd_Api.g_miss_num
  ,owner_id                     NUMBER         := Fnd_Api.g_miss_num
  ,wf_item_key                  VARCHAR2(120)  := Fnd_Api.g_miss_char
  ,customer_reference           VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,buying_group_contact_id      NUMBER         := Fnd_Api.g_miss_num
  ,object_version_number        NUMBER         := Fnd_Api.g_miss_num
  ,perf_date_from               DATE           := Fnd_Api.g_miss_date
  ,perf_date_to                 DATE           := Fnd_Api.g_miss_date
  ,status_code                  VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,status_date                  DATE           := Fnd_Api.g_miss_date
  ,modifier_level_code          VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,order_value_discount_type    VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,lumpsum_amount               NUMBER         := Fnd_Api.g_miss_num
  ,lumpsum_payment_type         VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,custom_setup_id              NUMBER         := Fnd_Api.g_miss_num
  ,offer_amount                 NUMBER         := FND_API.g_miss_num
  ,budget_amount_tc             NUMBER         := Fnd_Api.g_miss_num
  ,budget_amount_fc             NUMBER         := Fnd_Api.g_miss_num
  ,transaction_currency_code    VARCHAR2(15)   := Fnd_Api.g_miss_char
  ,functional_currency_code     VARCHAR2(15)   := Fnd_Api.g_miss_char
  ,context                      VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,attribute1                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute2                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute3                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute4                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute5                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute6                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute7                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute8                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute9                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute10                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute11                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute12                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute13                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute14                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute15                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,currency_code                VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,start_date_active            DATE           := Fnd_Api.g_miss_date
  ,end_date_active              DATE           := Fnd_Api.g_miss_date
  ,list_type_code               VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,discount_lines_flag          VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,name                         VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,description                  VARCHAR2(2000) := Fnd_Api.g_miss_char
  ,comments                     VARCHAR2(2000) := Fnd_Api.g_miss_char
  ,ask_for_flag                 VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,start_date_active_first      DATE           := Fnd_Api.g_miss_date
  ,end_date_active_first        DATE           := Fnd_Api.g_miss_date
  ,active_date_first_type       VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,start_date_active_second     DATE           := Fnd_Api.g_miss_date
  ,end_date_active_second       DATE           := Fnd_Api.g_miss_date
  ,active_date_second_type      VARCHAR2(30)    := Fnd_Api.g_miss_char
  ,active_flag                  VARCHAR2(1)     := Fnd_Api.g_miss_char
  ,max_no_of_uses               NUMBER          := Fnd_Api.g_miss_num
  ,budget_source_id             NUMBER          := Fnd_Api.g_miss_num
  ,budget_source_type           VARCHAR2(30)    := Fnd_Api.g_miss_char
  ,offer_used_by_id             NUMBER          := Fnd_Api.g_miss_num
  ,offer_used_by                VARCHAR2(30)    := Fnd_Api.g_miss_char
  ,ql_qualifier_type            VARCHAR2(30)    := Fnd_Api.g_miss_char
  ,ql_qualifier_id              NUMBER          := Fnd_Api.g_miss_num
  ,distribution_type            VARCHAR2(30)    := FND_API.g_miss_char
  ,amount_limit_id              NUMBER          := FND_API.g_miss_num
  ,uses_limit_id                NUMBER          := FND_API.g_miss_num
  ,offer_operation              VARCHAR2(30)    := FND_API.g_miss_char
  ,modifier_operation           VARCHAR2(30)    := FND_API.g_miss_char
  ,budget_offer_yn              VARCHAR2(1)     := FND_API.g_miss_char
  ,break_type                   VARCHAR2(30)    := FND_API.g_miss_char
  ,retroactive                  VARCHAR2(1)     := FND_API.g_miss_char
  ,volume_offer_type            VARCHAR2(30)    := FND_API.g_miss_char
  ,confidential_flag            VARCHAR2(1)     := FND_API.g_miss_char
  ,committed_amount_eq_max      VARCHAR2(1)     := FND_API.g_miss_char
  ,source_from_parent           VARCHAR2(1)     := FND_API.g_miss_char
  ,buyer_name                   VARCHAR2(240)   := FND_API.g_miss_char
  ,tier_level                   VARCHAR2(30)    := FND_API.g_miss_char
  ,na_rule_header_id            NUMBER          := FND_API.g_miss_num
  ,sales_method_flag            VARCHAR2(1)     := FND_API.g_miss_char
  ,global_flag                  VARCHAR2(1)     := FND_API.g_miss_char
  ,orig_org_id                  NUMBER          := FND_API.g_miss_num
);

TYPE Modifier_Line_Rec_Type IS RECORD
(
   offer_line_type             VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,operation                   VARCHAR2(30)   := FND_API.g_miss_char
  ,list_line_id                NUMBER         := Fnd_Api.g_miss_num
  ,list_header_id              NUMBER         := Fnd_Api.g_miss_num
  ,list_line_type_code         VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,operand                     NUMBER         := Fnd_Api.g_miss_num
  ,start_date_active           DATE           := FND_API.g_miss_date
  ,end_date_active             DATE           := FND_API.g_miss_date
  ,arithmetic_operator         VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,active_flag                 VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,qd_operand                  NUMBER         := Fnd_Api.g_miss_num
  ,qd_arithmetic_operator      VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,qd_related_deal_lines_id    NUMBER         := Fnd_Api.g_miss_num
  ,qd_object_version_number    NUMBER         := Fnd_Api.g_miss_num
  ,qd_estimated_qty_is_max     VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,qd_list_line_id             NUMBER         := Fnd_Api.g_miss_num
  ,qd_estimated_amount_is_max  VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,estim_gl_value              NUMBER         := Fnd_Api.g_miss_num
  ,benefit_price_list_line_id  NUMBER         := Fnd_Api.g_miss_num
  ,benefit_limit               NUMBER         := Fnd_Api.g_miss_num
  ,benefit_qty                 NUMBER         := Fnd_Api.g_miss_num
  ,benefit_uom_code            VARCHAR2(3)    := Fnd_Api.g_miss_char
  ,substitution_context        VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,substitution_attr           VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,substitution_val            VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,price_break_type_code       VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,pricing_attribute_id        NUMBER         := Fnd_Api.g_miss_num
  ,product_attribute_context   VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,product_attr                VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,product_attr_val            VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,product_uom_code            VARCHAR2(3)    := Fnd_Api.g_miss_char
  ,pricing_attribute_context   VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,pricing_attr                VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,pricing_attr_value_from     VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,pricing_attr_value_to       VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,excluder_flag               VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,order_value_from            VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,order_value_to              VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,qualifier_id                NUMBER         := FND_API.g_miss_num
  ,comments                    VARCHAR2(2000) := Fnd_Api.g_miss_char
  ,context                     VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,attribute1                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute2                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute3                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute4                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute5                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute6                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute7                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute8                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute9                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute10                 VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute11                 VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute12                 VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute13                 VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute14                 VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute15                 VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,max_qty_per_order           NUMBER         := Fnd_Api.g_miss_num
  ,max_qty_per_order_id        NUMBER         := Fnd_Api.g_miss_num
  ,max_qty_per_customer        NUMBER         := Fnd_Api.g_miss_num
  ,max_qty_per_customer_id     NUMBER         := Fnd_Api.g_miss_num
  ,max_qty_per_rule            NUMBER         := Fnd_Api.g_miss_num
  ,max_qty_per_rule_id         NUMBER         := Fnd_Api.g_miss_num
  ,max_orders_per_customer     NUMBER         := Fnd_Api.g_miss_num
  ,max_orders_per_customer_id  NUMBER         := Fnd_Api.g_miss_num
  ,max_amount_per_rule         NUMBER         := Fnd_Api.g_miss_num
  ,max_amount_per_rule_id      NUMBER         := Fnd_Api.g_miss_num
  ,estimate_qty_uom            VARCHAR2(3)    := Fnd_Api.g_miss_char
  ,generate_using_formula_id   NUMBER         := FND_API.G_MISS_NUM
  ,price_by_formula_id         NUMBER         := FND_API.G_MISS_NUM
  ,generate_using_formula      VARCHAR2(240)  := FND_API.G_MISS_CHAR
  ,price_by_formula            VARCHAR2(240)  := FND_API.G_MISS_CHAR
);
TYPE modifier_line_tbl_type IS TABLE OF MODIFIER_LINE_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE qualifiers_Rec_Type IS RECORD
(
   qualifier_context           VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,qualifier_attribute         VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,qualifier_attr_value        VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,qualifier_attr_value_to     VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,comparison_operator_code    VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,qualifier_grouping_no       NUMBER         := Fnd_Api.g_miss_num
  ,list_line_id                NUMBER         := Fnd_Api.g_miss_num
  ,list_header_id              NUMBER         := Fnd_Api.g_miss_num
  ,qualifier_id                NUMBER         := Fnd_Api.g_miss_num
  ,start_date_active           DATE           := Fnd_Api.g_miss_date
  ,end_date_active             DATE           := Fnd_Api.g_miss_date
  ,activity_market_segment_id  NUMBER         := Fnd_Api.g_miss_num
  ,operation                   VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,context                     VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,attribute1                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,attribute2                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute3                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute4                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute5                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute6                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute7                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute8                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute9                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute10                 VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute11                 VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute12                 VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute13                 VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute14                 VARCHAR2(240) := Fnd_Api.g_miss_char
  ,attribute15                 VARCHAR2(240) := Fnd_Api.g_miss_char
);
TYPE qualifiers_tbl_type IS TABLE OF qualifiers_rec_type INDEX BY BINARY_INTEGER;

TYPE vo_disc_rec_type IS RECORD
(
   offer_discount_line_id          NUMBER
  ,parent_discount_line_id         NUMBER
  ,volume_from                     NUMBER
  ,volume_to                       NUMBER
  ,volume_operator                 VARCHAR2(30)
  ,volume_type                     VARCHAR2(30)
  ,volume_break_type               VARCHAR2(30)
  ,discount                        NUMBER
  ,discount_type                   VARCHAR2(30)
  ,tier_type                       VARCHAR2(30)
  ,tier_level                      VARCHAR2(30)
  ,uom_code                        VARCHAR2(30)
  ,object_version_number           NUMBER
  ,offer_id                        NUMBER
  ,discount_by_code                VARCHAR2(30)
  ,formula_id                      NUMBER
  ,offr_disc_struct_name_id        NUMBER
  ,name                            VARCHAR2(240)
  ,description                     VARCHAR2(2000)
  ,operation                       VARCHAR2(30)
  ,pbh_index                       NUMBER
);
TYPE vo_disc_tbl_type IS TABLE OF vo_disc_rec_type INDEX BY BINARY_INTEGER;

TYPE vo_prod_rec_type IS RECORD
(
   off_discount_product_id NUMBER
  ,excluder_flag           VARCHAR2(1)
  ,offer_discount_line_id  NUMBER
  ,offer_id                NUMBER
  ,object_version_number   NUMBER
  ,product_context         VARCHAR2(30)
  ,product_attribute       VARCHAR2(30)
  ,product_attr_value      VARCHAR2(240)
  ,apply_discount_flag     VARCHAR2(1)
  ,include_volume_flag     VARCHAR2(1)
  ,operation               VARCHAR2(30)
  ,pbh_index               NUMBER
);
TYPE vo_prod_tbl_type IS TABLE OF vo_prod_rec_type INDEX BY BINARY_INTEGER;

TYPE vo_mo_rec_type IS RECORD
(
   offer_market_option_id     NUMBER
  ,offer_id                   NUMBER
  ,qp_list_header_id          NUMBER
  ,group_number               NUMBER
  ,retroactive_flag           VARCHAR2(1)
  ,beneficiary_party_id       NUMBER
  ,combine_schedule_flag      VARCHAR2(1)
  ,volume_tracking_level_code VARCHAR2(30)
  ,accrue_to_code             VARCHAR2(30)
  ,precedence                 NUMBER
  ,object_version_number      NUMBER
  ,security_group_id          NUMBER
  ,operation                  VARCHAR2(30)
);
TYPE vo_mo_tbl_type IS TABLE OF vo_mo_rec_type INDEX BY BINARY_INTEGER;

/*#
* This procedure accepts detailed offer infomation, discrete data, and processes the data by calling private APIs.
* @param p_init_msg_list	Indicates whether to initialize the message stack.
* @param p_api_version		Indicates the API version number.
* @param p_commit		Indicates whether to commit within the program.
* @param x_return_status	This is the program status.
* @param x_msg_count		Indicates the number of messages the program returns.
* @param x_msg_data		Message returned by the program.
* @param p_offer_type		Determines the offer type.
* @param p_modifier_list_rec	offer header detail.
* @param p_modifier_line_tbl	Stores discount rules for Advanced Pricing (QP) offer types. Net Accrual, Scan Data, and Lumpsum offers are not QP offers.
* @param p_qualifier_tbl	Stores the market eligibility values for QP offer types.
* @param p_budget_tbl		Stores budget request details related to offers for all offer types.
* @param p_act_product_tbl	Stores discount rules for Scan Data and Lumpsum offer types.
* @param p_discount_tbl		Stores discount and product related information for Net Accrual offers(for tier_level='LINE').
* @param p_excl_tbl		Stores product exclusion detauls for Net Accrual offers(for tier_level='LINE').
* @param p_offer_tier_tbl	Stores discount tier information for Net Accrual offers(for tier_level='HEADER').
* @param p_prod_tbl		Stores discount and products related information for Net Accrual offers(for tier_level='HEADER').
* @param p_na_qualifier_tbl	Stores market eligibility information for Net Accrual offers.
* @param x_qp_list_header_id	Advanced Pricing list header id of the new offer.
* @param x_error_location	This parameter is reserved for future use.
* @rep:displayname Process Modifiers
* @rep:scope public
* @rep:lifecycle active
* @rep:compatibility S
*/
PROCEDURE process_modifiers(
   p_init_msg_list         IN  VARCHAR2
  ,p_api_version           IN  NUMBER
  ,p_commit                IN  VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
  ,p_offer_type            IN  VARCHAR2
  ,p_modifier_list_rec     IN  modifier_list_rec_type
  ,p_modifier_line_tbl     IN  modifier_line_tbl_type
  ,p_qualifier_tbl         IN  qualifiers_tbl_type
  ,p_budget_tbl            IN  budget_tbl_type
  ,p_act_product_tbl       IN  act_product_tbl_type
  ,p_discount_tbl          IN  discount_line_tbl_type
  ,p_excl_tbl              IN  excl_rec_tbl_type
  ,p_offer_tier_tbl        IN  offer_tier_tbl_type
  ,p_prod_tbl              IN  prod_rec_tbl_type
  ,p_na_qualifier_tbl      IN  na_qualifier_tbl_type
  ,x_qp_list_header_id     OUT NOCOPY NUMBER
  ,x_error_location        OUT NOCOPY NUMBER);

/*#
* This procedure accepts detailed offer infomation, discrete data, and processes the data by calling private APIs.
* @param p_init_msg_list	Indicates whether to initialize the message stack.
* @param p_api_version		API version number.
* @param p_commit		Indicator whether to commit within the program.
* @param x_return_status	Program status.
* @param x_msg_count		This number indicates the number of messages the program returned.
* @param x_msg_data		Return message by the program
* @param p_modifier_list_rec	offer header detail.
* @param p_vo_pbh_tbl Stores	discount structure information for volume offer types.
* @param p_vo_dis_tbl Stores	discount tier information for volume offer types.
* @param p_vo_prod_tbl Stores	discount product information for volume offer types.
* @param p_qualifier_tbl	Stores the market eligibility values for volume offer types.
* @param p_vo_mo_tbl		Stores market option information for volume offer types.
* @param p_budget_tbl		Stores budget request details related to offers for all offer types.
* @param x_qp_list_header_id	Advanced Pricing list header id of the new offer.
* @param x_error_location	Reserved for future use.
* @rep:displayname Process VO
* @rep:scope public
* @rep:lifecycle active
* @rep:compatibility S
*/
PROCEDURE process_vo(
   p_init_msg_list         IN  VARCHAR2
  ,p_api_version           IN  NUMBER
  ,p_commit                IN  VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
  ,p_modifier_list_rec     IN  modifier_list_rec_type
  ,p_vo_pbh_tbl            IN  vo_disc_tbl_type
  ,p_vo_dis_tbl            IN  vo_disc_tbl_type
  ,p_vo_prod_tbl           IN  vo_prod_tbl_type
  ,p_qualifier_tbl         IN  qualifiers_tbl_type
  ,p_vo_mo_tbl             IN  vo_mo_tbl_type
  ,p_budget_tbl            IN  budget_tbl_type
  ,x_qp_list_header_id     OUT NOCOPY NUMBER
  ,x_error_location        OUT NOCOPY NUMBER
);
END OZF_Offer_PUB;

 

/
