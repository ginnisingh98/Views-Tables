--------------------------------------------------------
--  DDL for Package OZF_OFFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvofrs.pls 120.13 2008/01/11 06:36:17 nirprasa ship $ */
--G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_offer_PVT';

TYPE ozf_qp_reln_rec_type IS RECORD
(
qp_list_line_id NUMBER
, offer_discount_line_id NUMBER
, pricing_attribute_id NUMBER
, off_discount_product_id NUMBER
);

TYPE ozf_qp_reln_TBL_type IS TABLE OF ozf_qp_reln_rec_type
        INDEX BY BINARY_INTEGER;

TYPE Modifier_LIST_Rec_Type IS RECORD
(
   OFFER_ID                      NUMBER         := Fnd_Api.g_miss_num
  ,QP_LIST_HEADER_ID             NUMBER         := Fnd_Api.g_miss_num
  ,OFFER_TYPE                    VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,OFFER_CODE                    VARCHAR2(100)  := Fnd_Api.g_miss_char
  ,ACTIVITY_MEDIA_ID             NUMBER         := Fnd_Api.g_miss_num
  ,REUSABLE                      VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,USER_STATUS_ID                NUMBER         := Fnd_Api.g_miss_num
  ,OWNER_ID                      NUMBER         := Fnd_Api.g_miss_num
  ,WF_ITEM_KEY                   VARCHAR2(120)  := Fnd_Api.g_miss_char
  ,CUSTOMER_REFERENCE            VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,BUYING_GROUP_CONTACT_ID       NUMBER         := Fnd_Api.g_miss_num
  ,OBJECT_VERSION_NUMBER         NUMBER         := Fnd_Api.g_miss_num
  ,PERF_DATE_FROM                DATE           := Fnd_Api.g_miss_date
  ,PERF_DATE_TO                  DATE           := Fnd_Api.g_miss_date
  ,STATUS_CODE                   VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,STATUS_DATE                   DATE           := Fnd_Api.g_miss_date
  ,MODIFIER_LEVEL_CODE           VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,ORDER_VALUE_DISCOUNT_TYPE     VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,LUMPSUM_AMOUNT                NUMBER         := Fnd_Api.g_miss_num
  ,LUMPSUM_PAYMENT_TYPE          VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,CUSTOM_SETUP_ID               NUMBER         := Fnd_Api.g_miss_num
  ,OFFER_AMOUNT                  NUMBER         := FND_API.g_miss_num
  ,BUDGET_AMOUNT_TC              NUMBER         := Fnd_Api.g_miss_num
  ,BUDGET_AMOUNT_FC              NUMBER         := Fnd_Api.g_miss_num
  ,TRANSACTION_CURRENCY_CODE     VARCHAR2(15)   := Fnd_Api.g_miss_char
  ,FUNCTIONAL_CURRENCY_CODE      VARCHAR2(15)   := Fnd_Api.g_miss_char
  ,CONTEXT                       VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,ATTRIBUTE1                    VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE2                    VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE3                    VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE4                    VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE5                    VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE6                    VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE7                    VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE8                    VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE9                    VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE10                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE11                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE12                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE13                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE14                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE15                   VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,CURRENCY_CODE                 VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,START_DATE_ACTIVE             DATE           := Fnd_Api.g_miss_date
  ,END_DATE_ACTIVE               DATE           := Fnd_Api.g_miss_date
  ,LIST_TYPE_CODE                VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,DISCOUNT_LINES_FLAG           VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,NAME                          VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,DESCRIPTION                   VARCHAR2(2000) := Fnd_Api.g_miss_char
  ,COMMENTS                      VARCHAR2(2000) := Fnd_Api.g_miss_char
  ,ASK_FOR_FLAG                  VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,START_DATE_ACTIVE_FIRST       DATE           := Fnd_Api.g_miss_date
  ,END_DATE_ACTIVE_FIRST         DATE           := Fnd_Api.g_miss_date
  ,ACTIVE_DATE_FIRST_TYPE        VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,START_DATE_ACTIVE_SECOND      DATE           := Fnd_Api.g_miss_date
  ,END_DATE_ACTIVE_SECOND        DATE           := Fnd_Api.g_miss_date
  ,ACTIVE_DATE_SECOND_TYPE      VARCHAR2(30)    := Fnd_Api.g_miss_char
  ,ACTIVE_FLAG                  VARCHAR2(1)     := Fnd_Api.g_miss_char
  ,MAX_NO_OF_USES               NUMBER          := Fnd_Api.g_miss_num
  ,BUDGET_SOURCE_ID             NUMBER          := Fnd_Api.g_miss_num
  ,BUDGET_SOURCE_TYPE           VARCHAR2(30)    := Fnd_Api.g_miss_char
  ,OFFER_USED_BY_ID             NUMBER          := Fnd_Api.g_miss_num
  ,OFFER_USED_BY                VARCHAR2(30)    := Fnd_Api.g_miss_char
  ,QL_QUALIFIER_TYPE            VARCHAR2(30)    := Fnd_Api.g_miss_char
  ,QL_QUALIFIER_ID              NUMBER          := Fnd_Api.g_miss_num
  ,DISTRIBUTION_TYPE            VARCHAR2(30)    := FND_API.g_miss_char
  ,AMOUNT_LIMIT_ID              NUMBER          := FND_API.g_miss_num
  ,USES_LIMIT_ID                NUMBER          := FND_API.g_miss_num
  ,OFFER_OPERATION              VARCHAR2(30)    := FND_API.g_miss_char
  ,MODIFIER_OPERATION           VARCHAR2(30)    := FND_API.g_miss_char
  ,BUDGET_OFFER_YN              VARCHAR2(1)     := FND_API.g_miss_char
  ,BREAK_TYPE                   VARCHAR2(30)    := FND_API.g_miss_char
  ,RETROACTIVE                  VARCHAR2(1)     := FND_API.g_miss_char
  ,VOLUME_OFFER_TYPE            VARCHAR2(30)    := FND_API.g_miss_char
  ,CONFIDENTIAL_FLAG            VARCHAR2(1)     := FND_API.g_miss_char
  ,COMMITTED_AMOUNT_EQ_MAX     VARCHAR2(1)     := FND_API.g_miss_char
  ,SOURCE_FROM_PARENT          VARCHAR2(1)     := FND_API.g_miss_char
  ,BUYER_NAME                  VARCHAR2(240)   := FND_API.g_miss_char
  ,TIER_LEVEL                   VARCHAR2(30)    := FND_API.g_miss_char
  ,NA_RULE_HEADER_ID            NUMBER          := FND_API.g_miss_num
  ,SALES_METHOD_FLAG            VARCHAR2(1)    := FND_API.g_miss_char
  ,GLOBAL_FLAG                  VARCHAR2(1)     := FND_API.g_miss_char
  ,ORIG_ORG_ID                  NUMBER          := FND_API.g_miss_num
  ,na_qualifier_type            VARCHAR2(30)    := FND_API.g_miss_char
  ,na_qualifier_id              NUMBER          := FND_API.g_miss_num);

TYPE Modifier_Line_Rec_Type IS RECORD
(
   OFFER_LINE_TYPE             VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,OPERATION                   VARCHAR2(30)   := FND_API.g_miss_char
  ,LIST_LINE_ID                NUMBER         := Fnd_Api.g_miss_num
  ,LIST_LINE_NO                VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,LIST_HEADER_ID              NUMBER         := Fnd_Api.g_miss_num
  ,LIST_LINE_TYPE_CODE         VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,OPERAND                     NUMBER         := Fnd_Api.g_miss_num
  ,START_DATE_ACTIVE           DATE           := FND_API.g_miss_date
  ,END_DATE_ACTIVE             DATE           := FND_API.g_miss_date
  ,ARITHMETIC_OPERATOR         VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,INACTIVE_FLAG               VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,QD_OPERAND                  NUMBER         := Fnd_Api.g_miss_num
  ,QD_ARITHMETIC_OPERATOR      VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,QD_RELATED_DEAL_LINES_ID    NUMBER         := Fnd_Api.g_miss_num
  ,QD_OBJECT_VERSION_NUMBER    NUMBER         := Fnd_Api.g_miss_num
  ,QD_ESTIMATED_QTY_IS_MAX     VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,QD_LIST_LINE_ID             NUMBER         := Fnd_Api.g_miss_num
  ,QD_ESTIMATED_AMOUNT_IS_MAX  VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,ESTIM_GL_VALUE              NUMBER         := Fnd_Api.g_miss_num
  ,BENEFIT_PRICE_LIST_LINE_ID  NUMBER         := Fnd_Api.g_miss_num
  ,BENEFIT_LIMIT               NUMBER         := Fnd_Api.g_miss_num
  ,BENEFIT_QTY                 NUMBER         := Fnd_Api.g_miss_num
  ,BENEFIT_UOM_CODE            VARCHAR2(3)    := Fnd_Api.g_miss_char
  ,SUBSTITUTION_CONTEXT        VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,SUBSTITUTION_ATTR           VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,SUBSTITUTION_VAL            VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,PRICE_BREAK_TYPE_CODE       VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,PRICING_ATTRIBUTE_ID        NUMBER         := Fnd_Api.g_miss_num
  ,PRODUCT_ATTRIBUTE_CONTEXT   VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,PRODUCT_ATTR                VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,PRODUCT_ATTR_VAL            VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,PRODUCT_UOM_CODE            VARCHAR2(3)    := Fnd_Api.g_miss_char
  ,PRICING_ATTRIBUTE_CONTEXT   VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,PRICING_ATTR                VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,PRICING_ATTR_VALUE_FROM     VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,PRICING_ATTR_VALUE_TO       VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,EXCLUDER_FLAG               VARCHAR2(1)    := Fnd_Api.g_miss_char
  ,ORDER_VALUE_FROM            VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ORDER_VALUE_TO              VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,QUALIFIER_ID                NUMBER         := FND_API.g_miss_num
  ,COMMENTS                    VARCHAR2(2000) := Fnd_Api.g_miss_char
  ,CONTEXT                     VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,ATTRIBUTE1                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE2                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE3                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE4                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE5                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE6                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE7                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE8                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE9                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE10                 VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE11                 VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE12                 VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE13                 VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE14                 VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE15                 VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,MAX_QTY_PER_ORDER           NUMBER         := Fnd_Api.g_miss_num
  ,MAX_QTY_PER_ORDER_ID        NUMBER         := Fnd_Api.g_miss_num
  ,MAX_QTY_PER_CUSTOMER        NUMBER         := Fnd_Api.g_miss_num
  ,MAX_QTY_PER_CUSTOMER_ID     NUMBER         := Fnd_Api.g_miss_num
  ,MAX_QTY_PER_RULE            NUMBER         := Fnd_Api.g_miss_num
  ,MAX_QTY_PER_RULE_ID         NUMBER         := Fnd_Api.g_miss_num
  ,MAX_ORDERS_PER_CUSTOMER     NUMBER         := Fnd_Api.g_miss_num
  ,MAX_ORDERS_PER_CUSTOMER_ID  NUMBER         := Fnd_Api.g_miss_num
  ,MAX_AMOUNT_PER_RULE         NUMBER         := Fnd_Api.g_miss_num
  ,MAX_AMOUNT_PER_RULE_ID      NUMBER         := Fnd_Api.g_miss_num
  ,ESTIMATE_QTY_UOM            VARCHAR2(3)    := Fnd_Api.g_miss_char
  ,generate_using_formula_id   NUMBER         := FND_API.G_MISS_NUM
  ,price_by_formula_id         NUMBER         := FND_API.G_MISS_NUM
  ,generate_using_formula      VARCHAR2(240)  := FND_API.G_MISS_CHAR
  ,price_by_formula            VARCHAR2(240)  := FND_API.G_MISS_CHAR
  ,limit_exceed_action_code    VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE modifier_line_tbl_type IS TABLE OF  MODIFIER_LINE_REC_TYPE
        INDEX BY BINARY_INTEGER;

TYPE Pricing_ATTR_Rec_Type IS RECORD
(
    LIST_LINE_ID               NUMBER          := Fnd_Api.g_miss_num
   ,EXCLUDER_FLAG              VARCHAR2(1)     := Fnd_Api.g_miss_char
   ,PRICING_ATTRIBUTE_ID       NUMBER          := Fnd_Api.g_miss_num
   ,PRODUCT_ATTRIBUTE_CONTEXT  VARCHAR2(30)    := Fnd_Api.g_miss_char
   ,PRODUCT_ATTRIBUTE          VARCHAR2(30)    := Fnd_Api.g_miss_char
   ,PRODUCT_ATTR_VALUE         VARCHAR2(240)   := Fnd_Api.g_miss_char
   ,PRODUCT_UOM_CODE           VARCHAR2(3)     := Fnd_Api.g_miss_char
   ,PRICING_ATTRIBUTE_CONTEXT  VARCHAR2(30)    := Fnd_Api.g_miss_char
   ,PRICING_ATTRIBUTE          VARCHAR2(30)    := Fnd_Api.g_miss_char
   ,PRICING_ATTR_VALUE_FROM    VARCHAR2(240)   := Fnd_Api.g_miss_char
   ,PRICING_ATTR_VALUE_TO      VARCHAR2(240)   := Fnd_Api.g_miss_char
   ,MODIFIERS_INDEX            NUMBER          := Fnd_Api.g_miss_num
   ,OPERATION                  VARCHAR2(20)    := Fnd_Api.g_miss_char
);

TYPE pricing_attR_tbl_type IS TABLE OF  Pricing_ATTR_Rec_Type
	   INDEX BY BINARY_INTEGER;

TYPE qualifiers_Rec_Type IS RECORD
(
   QUALIFIER_CONTEXT           VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,QUALIFIER_ATTRIBUTE         VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,QUALIFIER_ATTR_VALUE        VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,QUALIFIER_ATTR_VALUE_TO     VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,COMPARISON_OPERATOR_CODE    VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,QUALIFIER_GROUPING_NO       NUMBER         := Fnd_Api.g_miss_num
  ,LIST_LINE_ID                NUMBER         := Fnd_Api.g_miss_num
  ,LIST_HEADER_ID              NUMBER         := Fnd_Api.g_miss_num
  ,QUALIFIER_ID                NUMBER         := Fnd_Api.g_miss_num
  ,START_DATE_ACTIVE           DATE           := Fnd_Api.g_miss_date
  ,END_DATE_ACTIVE             DATE           := Fnd_Api.g_miss_date
  ,ACTIVITY_MARKET_SEGMENT_ID  NUMBER         := Fnd_Api.g_miss_num
  ,OPERATION                   VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,CONTEXT                     VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,ATTRIBUTE1                  VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,ATTRIBUTE2                   VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE3                   VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE4                   VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE5                   VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE6                   VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE7                   VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE8                   VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE9                   VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE10                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE11                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE12                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE13                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE14                  VARCHAR2(240) := Fnd_Api.g_miss_char
  ,ATTRIBUTE15                  VARCHAR2(240) := Fnd_Api.g_miss_char
);

TYPE qualifiers_tbl_type IS TABLE OF qualifiers_rec_type
        INDEX BY BINARY_INTEGER;

TYPE Advanced_Option_Rec_Type IS RECORD
(
   LIST_LINE_ID               NUMBER          := Fnd_Api.g_miss_num
  ,LIST_HEADER_ID             NUMBER          := Fnd_Api.g_miss_num
  ,OFFER_TYPE                 VARCHAR2(30)    := Fnd_Api.g_miss_char
  ,MODIFIER_LEVEL_CODE        VARCHAR2(30)    := Fnd_Api.g_miss_char
  ,PRICING_PHASE_ID           NUMBER          := Fnd_Api.g_miss_num
  ,INCOMPATIBILITY_GRP_CODE   VARCHAR2(30)    := Fnd_Api.g_miss_char
  ,PRODUCT_PRECEDENCE         NUMBER          := Fnd_Api.g_miss_num
  ,PRICING_GROUP_SEQUENCE     NUMBER          := Fnd_Api.g_miss_num
  ,PRINT_ON_INVOICE_FLAG      VARCHAR2(1)     := Fnd_Api.g_miss_char
  ,autopay_flag                 VARCHAR2(1)     :=  FND_API.g_miss_char
  ,autopay_days                 NUMBER          := FND_API.G_miss_num
  ,autopay_method               VARCHAR2(30)    :=  FND_API.g_miss_char
  ,autopay_party_attr           VARCHAR2(30)    :=  FND_API.g_miss_char
  ,autopay_party_id             NUMBER          := FND_API.g_miss_num
);


---------------------------------------------------------------------
-- PROCEDURE
--    process_modifiers_
--
-- HISTORY
--    20-MAY-2000  Satish Karumuri  Created.
---------------------------------------------------------------------

PROCEDURE process_modifiers
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offer_type            IN  VARCHAR2
  ,p_modifier_list_rec     IN   MODIFIER_LIST_REC_TYPE
  ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
  ,x_qp_list_header_id     OUT NOCOPY  NUMBER
  ,x_error_location        OUT NOCOPY  NUMBER
);

PROCEDURE create_offer_tiers
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
  ,x_error_location        OUT NOCOPY  NUMBER
--  ,x_modifiers_tbl         OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
--  ,x_pricing_attr_tbl      OUT NOCOPY qp_modifiers_pub.pricing_attr_tbl_type
);

PROCEDURE process_market_qualifiers
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_qualifiers_tbl         IN  QUALIFIERS_TBL_TYPE
  ,x_error_location        OUT NOCOPY  NUMBER
  ,x_qualifiers_tbl        OUT NOCOPY qp_qualifier_rules_pub.qualifiers_tbl_type
);

PROCEDURE process_market_qualifiers
(
   p_init_msg_list         IN  VARCHAR2
  ,p_api_version           IN  NUMBER
  ,p_commit                IN  VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
  ,p_qualifiers_tbl        IN  QUALIFIERS_TBL_TYPE
  ,x_error_location        OUT NOCOPY NUMBER
);

PROCEDURE process_exclusions
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_pricing_attr_tbl      IN   PRICING_ATTR_TBL_TYPE
  ,x_error_location        OUT NOCOPY  NUMBER
);

PROCEDURE process_adv_options
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_advanced_options_rec  IN   ADVANCED_OPTION_REC_TYPE
);

PROCEDURE activate_offer
(
   x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_qp_list_header_id     IN   NUMBER
  ,p_new_status_id         IN   NUMBER
);


PROCEDURE validate_lumpsum_offer
(
   p_init_msg_list         IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_qp_list_header_id     IN   NUMBER
);

PROCEDURE Activate_Offer_Over(
   p_init_msg_list         IN   VARCHAR2,
   p_api_version           IN   NUMBER,
   p_commit                IN   VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2,
   p_called_from            IN  VARCHAR2,
   p_offer_rec             IN   modifier_list_rec_type,
   x_amount_error          OUT NOCOPY  VARCHAR2
   );

PROCEDURE Update_Offer_Status
(
   p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_modifier_list_rec     IN   modifier_list_rec_type
);

FUNCTION find_territories
(
     aso_party_id   IN NUMBER
    ,oe_sold_to_org IN NUMBER
) RETURN Qp_Attr_Mapping_Pub.t_multirecord;

FUNCTION find_sections
(
     aso_inventory_item_id IN NUMBER
    ,oe_inventory_item_id IN NUMBER
) RETURN Qp_Attr_Mapping_Pub.t_multirecord;


FUNCTION get_commited_amount(p_list_header_id IN NUMBER) RETURN NUMBER;
FUNCTION get_recal_commited_amount(p_list_header_id IN NUMBER) RETURN NUMBER;
FUNCTION get_paid_amount(p_list_header_id IN NUMBER) RETURN NUMBER;
FUNCTION get_earned_amount(p_list_header_id IN NUMBER) RETURN NUMBER;
FUNCTION discount_lines_exist(p_list_header_id IN NUMBER) RETURN NUMBER;

PROCEDURE process_qp_list_lines
(
  x_return_status         OUT NOCOPY  VARCHAR2
 ,x_msg_count             OUT NOCOPY  NUMBER
 ,x_msg_data              OUT NOCOPY  VARCHAR2
 ,p_offer_type            IN   VARCHAR2
 ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
 ,p_list_header_id        IN   NUMBER
 ,x_modifier_line_tbl     OUT NOCOPY  qp_modifiers_pub.modifiers_tbl_type
 ,x_error_location        OUT NOCOPY  NUMBER
);

FUNCTION get_qualifier_name(p_qualifier_type IN VARCHAR2 , p_qualifier_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_formula_name(p_formula_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_offer_discount_id(p_offer_id IN NUMBER) RETURN VARCHAR2;
--FUNCTION get_order_amount(p_list_header_id IN NUMBER) RETURN NUMBER;

PROCEDURE push_discount_rules_to_qp
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  , p_qp_list_header_id    IN NUMBER
  , x_error_location       OUT NOCOPY NUMBER
);

PROCEDURE process_offer_activation
(
  p_api_version_number           IN   NUMBER
  , p_init_msg_list         IN   VARCHAR2
  , p_commit                IN   VARCHAR2
  , p_validation_level      IN VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_offer_rec             IN Modifier_LIST_Rec_Type
);


PROCEDURE raise_offer_event(p_offer_id      IN NUMBER,
                            p_adjustment_id IN NUMBER :=NULL);

FUNCTION getOfferType(p_listHeaderId NUMBER) RETURN VARCHAR2;
FUNCTION getDiscountLevel(p_listHeaderId IN NUMBER) RETURN VARCHAR2;
FUNCTION getPricingPhase(p_listHeaderId IN NUMBER) RETURN VARCHAR2;

PROCEDURE processPbhLine
    (
        x_return_status         OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY  NUMBER
        ,x_msg_data              OUT NOCOPY  VARCHAR2
        ,p_offerType               IN VARCHAR2
        ,p_modifierLineRec         IN   MODIFIER_LINE_REC_TYPE
        ,x_modifiersTbl            OUT NOCOPY QP_MODIFIERS_PUB.modifiers_tbl_type
        -- ,x_error_location        OUT NOCOPY  NUMBER
    );
PROCEDURE process_header_tiers
( x_return_status         OUT NOCOPY  VARCHAR2
 ,x_msg_count             OUT NOCOPY  NUMBER
 ,x_msg_data              OUT NOCOPY  VARCHAR2
 ,p_offer_type            IN   VARCHAR2
 ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
 ,x_modifiers_tbl         OUT NOCOPY QP_MODIFIERS_PUB.modifiers_tbl_type
 ,x_error_location        OUT NOCOPY  NUMBER
);

PROCEDURE pushDiscountRuleToQp
(
x_return_status             OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_qp_list_header_id     IN NUMBER
  , p_offDiscountProductId  IN NUMBER
  , x_error_location        OUT NOCOPY NUMBER
  , x_modifiersTbl          OUT NOCOPY Qp_Modifiers_Pub.modifiers_tbl_type
  , x_pricingAttrTbl        OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
);
PROCEDURE pushDiscountRuleToQpAndRelate
(
x_return_status             OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_qp_list_header_id     IN NUMBER
  , p_offDiscountProductId  IN NUMBER
  , x_error_location        OUT NOCOPY NUMBER
  , x_modifiersTbl          OUT NOCOPY Qp_Modifiers_Pub.modifiers_tbl_type
  , x_pricingAttrTbl        OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
);
PROCEDURE process_sd_modifiers(
   p_sdr_header_id         IN  NUMBER
  ,p_init_msg_list         IN  VARCHAR2 :=FND_API.g_true
  ,p_api_version           IN  NUMBER
  ,p_commit                IN  VARCHAR2 :=FND_API.g_false
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
  ,x_qp_list_header_id     IN OUT NOCOPY  NUMBER
  ,x_error_location        OUT NOCOPY NUMBER
  );


END OZF_Offer_Pvt;

/
