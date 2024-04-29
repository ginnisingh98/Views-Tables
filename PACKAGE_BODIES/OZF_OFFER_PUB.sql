--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_PUB" AS
/* $Header: ozfpofrb.pls 120.5.12010000.2 2009/08/18 08:25:11 nirprasa ship $ */
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
  ,x_error_location        OUT NOCOPY NUMBER)
IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'process_modifiers';

  l_act_product_rec ams_actproduct_pvt.act_product_rec_type;
  l_act_product_id      NUMBER;
  l_offer_id            NUMBER;
  l_obj_ver_num         NUMBER;
  l_discount_line_id    NUMBER;
  l_discount_product_id NUMBER;
  l_activity_budget_id  NUMBER;
  l_na_qualifier_id     NUMBER;
  l_dummy               NUMBER;
  l_prod_index          NUMBER := 0;
  l_excl_index          NUMBER := 0;

  l_discount_line_rec   ozf_disc_line_pvt.ozf_discount_line_rec_type;
  l_prod_rec            ozf_disc_line_pvt.ozf_prod_rec_type;
  l_excl_rec            ozf_disc_line_pvt.ozf_excl_rec_type;
  l_act_budgets_rec     ozf_actbudgets_pvt.act_budgets_rec_type;
  l_offer_tier_rec      ozf_disc_line_pvt.ozf_offer_tier_rec_type;
  l_na_qualifier_rec    ozf_offr_qual_pvt.ozf_offr_qual_rec_type;
  l_modifier_list_rec   ozf_offer_pvt.modifier_list_rec_type;
  l_modifier_line_tbl   ozf_offer_pvt.modifier_line_tbl_type;
  l_qualifiers_tbl      ozf_offer_pvt.qualifiers_tbl_type;
  l_exclusion_tbl       ozf_offer_pvt.pricing_attr_tbl_type;
  l_qualifiers_tbl_out  qp_qualifier_rules_pub.qualifiers_tbl_type;

  CURSOR c_offer_info(l_qp_list_header_id NUMBER) IS
  SELECT offer_id, offer_type, custom_setup_id, offer_code, tier_level, object_version_number
  FROM   ozf_offers
  WHERE  qp_list_header_id = l_qp_list_header_id;

  CURSOR c_act_budget_obj_ver(l_act_budg_id NUMBER) IS
  SELECT object_version_number
  FROM   ozf_act_budgets
  WHERE  activity_budget_id = l_act_budg_id;
BEGIN

  SAVEPOINT process_modifiers_pub;
  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  IF NOT Fnd_Api.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;
  x_error_location := 0;

  l_modifier_list_rec.OFFER_ID                      := p_modifier_list_rec.OFFER_ID;
  l_modifier_list_rec.QP_LIST_HEADER_ID             := p_modifier_list_rec.QP_LIST_HEADER_ID;
  l_modifier_list_rec.OFFER_TYPE                    := p_modifier_list_rec.OFFER_TYPE;
  l_modifier_list_rec.OFFER_CODE                    := p_modifier_list_rec.OFFER_CODE;
  l_modifier_list_rec.ACTIVITY_MEDIA_ID             := p_modifier_list_rec.ACTIVITY_MEDIA_ID;
  l_modifier_list_rec.REUSABLE                      := p_modifier_list_rec.REUSABLE;
  l_modifier_list_rec.USER_STATUS_ID                := p_modifier_list_rec.USER_STATUS_ID;
  l_modifier_list_rec.WF_ITEM_KEY                   := p_modifier_list_rec.WF_ITEM_KEY;
  l_modifier_list_rec.CUSTOMER_REFERENCE            := p_modifier_list_rec.CUSTOMER_REFERENCE;
  l_modifier_list_rec.BUYING_GROUP_CONTACT_ID       := p_modifier_list_rec.BUYING_GROUP_CONTACT_ID;
  l_modifier_list_rec.OBJECT_VERSION_NUMBER         := p_modifier_list_rec.OBJECT_VERSION_NUMBER;
  l_modifier_list_rec.PERF_DATE_FROM                := p_modifier_list_rec.PERF_DATE_FROM;
  l_modifier_list_rec.PERF_DATE_TO                  := p_modifier_list_rec.PERF_DATE_TO;
  l_modifier_list_rec.STATUS_CODE                   := p_modifier_list_rec.STATUS_CODE;
  l_modifier_list_rec.STATUS_DATE                   := p_modifier_list_rec.STATUS_DATE;
  l_modifier_list_rec.MODIFIER_LEVEL_CODE           := p_modifier_list_rec.MODIFIER_LEVEL_CODE;
  l_modifier_list_rec.ORDER_VALUE_DISCOUNT_TYPE     := p_modifier_list_rec.ORDER_VALUE_DISCOUNT_TYPE;
  l_modifier_list_rec.LUMPSUM_AMOUNT                := p_modifier_list_rec.LUMPSUM_AMOUNT;
  l_modifier_list_rec.LUMPSUM_PAYMENT_TYPE          := p_modifier_list_rec.LUMPSUM_PAYMENT_TYPE;
  l_modifier_list_rec.CUSTOM_SETUP_ID               := p_modifier_list_rec.CUSTOM_SETUP_ID;
  l_modifier_list_rec.OFFER_AMOUNT                  := p_modifier_list_rec.OFFER_AMOUNT;
  l_modifier_list_rec.BUDGET_AMOUNT_TC              := p_modifier_list_rec.BUDGET_AMOUNT_TC;
  l_modifier_list_rec.BUDGET_AMOUNT_FC              := p_modifier_list_rec.BUDGET_AMOUNT_FC;
  l_modifier_list_rec.TRANSACTION_CURRENCY_CODE     := p_modifier_list_rec.TRANSACTION_CURRENCY_CODE;
  l_modifier_list_rec.FUNCTIONAL_CURRENCY_CODE      := p_modifier_list_rec.FUNCTIONAL_CURRENCY_CODE;
  l_modifier_list_rec.CONTEXT                       := p_modifier_list_rec.CONTEXT;
  l_modifier_list_rec.ATTRIBUTE1                    := p_modifier_list_rec.ATTRIBUTE1;
  l_modifier_list_rec.ATTRIBUTE2                    := p_modifier_list_rec.ATTRIBUTE2;
  l_modifier_list_rec.ATTRIBUTE3                    := p_modifier_list_rec.ATTRIBUTE3;
  l_modifier_list_rec.ATTRIBUTE4                    := p_modifier_list_rec.ATTRIBUTE4;
  l_modifier_list_rec.ATTRIBUTE5                    := p_modifier_list_rec.ATTRIBUTE5;
  l_modifier_list_rec.ATTRIBUTE6                    := p_modifier_list_rec.ATTRIBUTE6;
  l_modifier_list_rec.ATTRIBUTE7                    := p_modifier_list_rec.ATTRIBUTE7;
  l_modifier_list_rec.ATTRIBUTE8                    := p_modifier_list_rec.ATTRIBUTE8;
  l_modifier_list_rec.ATTRIBUTE9                    := p_modifier_list_rec.ATTRIBUTE9;
  l_modifier_list_rec.ATTRIBUTE10                   := p_modifier_list_rec.ATTRIBUTE10;
  l_modifier_list_rec.ATTRIBUTE11                   := p_modifier_list_rec.ATTRIBUTE11;
  l_modifier_list_rec.ATTRIBUTE12                   := p_modifier_list_rec.ATTRIBUTE12;
  l_modifier_list_rec.ATTRIBUTE13                   := p_modifier_list_rec.ATTRIBUTE13;
  l_modifier_list_rec.ATTRIBUTE14                   := p_modifier_list_rec.ATTRIBUTE14;
  l_modifier_list_rec.ATTRIBUTE15                   := p_modifier_list_rec.ATTRIBUTE15;
  l_modifier_list_rec.CURRENCY_CODE                 := p_modifier_list_rec.CURRENCY_CODE;
  l_modifier_list_rec.START_DATE_ACTIVE             := p_modifier_list_rec.START_DATE_ACTIVE;
  l_modifier_list_rec.END_DATE_ACTIVE               := p_modifier_list_rec.END_DATE_ACTIVE;
  l_modifier_list_rec.LIST_TYPE_CODE                := p_modifier_list_rec.LIST_TYPE_CODE;
  l_modifier_list_rec.DISCOUNT_LINES_FLAG           := p_modifier_list_rec.DISCOUNT_LINES_FLAG;
  l_modifier_list_rec.NAME                          := p_modifier_list_rec.NAME;
  l_modifier_list_rec.DESCRIPTION                   := p_modifier_list_rec.DESCRIPTION;
  l_modifier_list_rec.COMMENTS                      := p_modifier_list_rec.COMMENTS;
  l_modifier_list_rec.ASK_FOR_FLAG                  := p_modifier_list_rec.ASK_FOR_FLAG;
  l_modifier_list_rec.START_DATE_ACTIVE_FIRST       := p_modifier_list_rec.START_DATE_ACTIVE_FIRST;
  l_modifier_list_rec.END_DATE_ACTIVE_FIRST         := p_modifier_list_rec.END_DATE_ACTIVE_FIRST;
  l_modifier_list_rec.ACTIVE_DATE_FIRST_TYPE        := p_modifier_list_rec.ACTIVE_DATE_FIRST_TYPE;
  l_modifier_list_rec.START_DATE_ACTIVE_SECOND      := p_modifier_list_rec.START_DATE_ACTIVE_SECOND;
  l_modifier_list_rec.END_DATE_ACTIVE_SECOND        := p_modifier_list_rec.END_DATE_ACTIVE_SECOND;
  l_modifier_list_rec.ACTIVE_DATE_SECOND_TYPE       := p_modifier_list_rec.ACTIVE_DATE_SECOND_TYPE;
  l_modifier_list_rec.ACTIVE_FLAG                   := p_modifier_list_rec.ACTIVE_FLAG;
  l_modifier_list_rec.MAX_NO_OF_USES                := p_modifier_list_rec.MAX_NO_OF_USES;
  l_modifier_list_rec.BUDGET_SOURCE_ID              := p_modifier_list_rec.BUDGET_SOURCE_ID;
  l_modifier_list_rec.BUDGET_SOURCE_TYPE            := p_modifier_list_rec.BUDGET_SOURCE_TYPE;
  l_modifier_list_rec.OFFER_USED_BY_ID              := p_modifier_list_rec.OFFER_USED_BY_ID;
  l_modifier_list_rec.OFFER_USED_BY                 := p_modifier_list_rec.OFFER_USED_BY;
  l_modifier_list_rec.QL_QUALIFIER_TYPE             := p_modifier_list_rec.QL_QUALIFIER_TYPE;
  l_modifier_list_rec.QL_QUALIFIER_ID               := p_modifier_list_rec.QL_QUALIFIER_ID;
  l_modifier_list_rec.DISTRIBUTION_TYPE             := p_modifier_list_rec.DISTRIBUTION_TYPE;
  l_modifier_list_rec.AMOUNT_LIMIT_ID               := p_modifier_list_rec.AMOUNT_LIMIT_ID;
  l_modifier_list_rec.USES_LIMIT_ID                 := p_modifier_list_rec.USES_LIMIT_ID;
  l_modifier_list_rec.OFFER_OPERATION               := p_modifier_list_rec.OFFER_OPERATION;
  l_modifier_list_rec.MODIFIER_OPERATION            := p_modifier_list_rec.MODIFIER_OPERATION;
  l_modifier_list_rec.BUDGET_OFFER_YN               := p_modifier_list_rec.BUDGET_OFFER_YN;
  l_modifier_list_rec.BREAK_TYPE                    := p_modifier_list_rec.BREAK_TYPE;
  l_modifier_list_rec.RETROACTIVE                   := p_modifier_list_rec.RETROACTIVE;
  l_modifier_list_rec.VOLUME_OFFER_TYPE             := p_modifier_list_rec.VOLUME_OFFER_TYPE;
  l_modifier_list_rec.CONFIDENTIAL_FLAG             := p_modifier_list_rec.CONFIDENTIAL_FLAG;
  l_modifier_list_rec.COMMITTED_AMOUNT_EQ_MAX       := p_modifier_list_rec.COMMITTED_AMOUNT_EQ_MAX;
  l_modifier_list_rec.SOURCE_FROM_PARENT            := p_modifier_list_rec.SOURCE_FROM_PARENT;
  l_modifier_list_rec.BUYER_NAME                    := p_modifier_list_rec.BUYER_NAME;
  l_modifier_list_rec.TIER_LEVEL                    := p_modifier_list_rec.TIER_LEVEL;
  l_modifier_list_rec.NA_RULE_HEADER_ID             := p_modifier_list_rec.NA_RULE_HEADER_ID;
  l_modifier_list_rec.sales_method_flag             := p_modifier_list_rec.sales_method_flag;
  l_modifier_list_rec.global_flag                   := p_modifier_list_rec.global_flag;
  l_modifier_list_rec.orig_org_id                   := p_modifier_list_rec.orig_org_id;

  -- offer header
  IF p_modifier_list_rec.offer_operation = 'CREATE' THEN
    l_modifier_list_rec.offer_operation := 'CREATE';
    l_modifier_list_rec.modifier_operation := 'CREATE';
    l_modifier_list_rec.status_code := 'DRAFT';
    l_modifier_list_rec.user_status_id := ozf_utility_pvt.get_default_user_status('OZF_OFFER_STATUS','DRAFT');--1600;

    IF p_modifier_list_rec.OWNER_ID IS NULL OR p_modifier_list_rec.OWNER_ID = fnd_api.g_miss_num THEN
      l_modifier_list_rec.OWNER_ID                      := ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id);
    ELSE
      l_modifier_list_rec.OWNER_ID                      := p_modifier_list_rec.OWNER_ID;
    END IF;

    Ozf_Offer_Pvt.process_modifiers(
       p_init_msg_list     => p_init_msg_list
      ,p_api_version       => p_api_version
      ,p_commit            => p_commit
      ,x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_offer_type        => p_offer_type
      ,p_modifier_list_rec => l_modifier_list_rec
      ,p_modifier_line_tbl => l_modifier_line_tbl -- need to create header first. use empty line.
      ,x_qp_list_header_id => x_qp_list_header_id
      ,x_error_location    => x_error_location);

    IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
    ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;

    l_modifier_list_rec.qp_list_header_id := x_qp_list_header_id;
    IF p_modifier_list_rec.user_status_id IS NOT NULL AND p_modifier_list_rec.user_status_id <> fnd_api.g_miss_num THEN -- might have additional stage eg ACTIVE to go
      l_modifier_list_rec.offer_operation := 'UPDATE';
      l_modifier_list_rec.modifier_operation := 'UPDATE';
      l_modifier_list_rec.user_status_id := p_modifier_list_rec.user_status_id;
      l_modifier_list_rec.status_code := ozf_utility_pvt.get_system_status_code(p_modifier_list_rec.user_status_id);
    ELSE -- creating draft offer hdr only
      l_modifier_list_rec.offer_operation := fnd_api.g_miss_char;
      l_modifier_list_rec.modifier_operation := fnd_api.g_miss_char;
      l_modifier_list_rec.user_status_id := fnd_api.g_miss_num;
      l_modifier_list_rec.status_code := fnd_api.g_miss_char;
    END IF;
  ELSE
    x_qp_list_header_id := p_modifier_list_rec.qp_list_header_id;
    IF p_modifier_list_rec.OWNER_ID IS NULL THEN
      l_modifier_list_rec.OWNER_ID                      := fnd_api.g_miss_num;
    ELSE
      l_modifier_list_rec.OWNER_ID                      := p_modifier_list_rec.OWNER_ID;
    END IF;
  END IF;

  OPEN c_offer_info(x_qp_list_header_id);
  FETCH c_offer_info INTO l_modifier_list_rec.offer_id, l_modifier_list_rec.offer_type, l_modifier_list_rec.custom_setup_id, l_modifier_list_rec.offer_code, l_modifier_list_rec.tier_level, l_modifier_list_rec.object_version_number;
  CLOSE c_offer_info;

  l_offer_id := l_modifier_list_rec.offer_id;
  l_obj_ver_num := l_modifier_list_rec.object_version_number;

  IF p_modifier_line_tbl.COUNT > 0 THEN
  FOR i IN p_modifier_line_tbl.FIRST..p_modifier_line_tbl.LAST LOOP
    IF p_modifier_line_tbl(i).excluder_flag = 'Y' THEN
      l_excl_index := l_excl_index + 1;
      l_exclusion_tbl(l_excl_index).operation := p_modifier_line_tbl(i).operation;
      l_exclusion_tbl(l_excl_index).pricing_attribute_id := p_modifier_line_tbl(i).pricing_attribute_id;
      l_exclusion_tbl(l_excl_index).list_line_id := p_modifier_line_tbl(i).list_line_id;
      l_exclusion_tbl(l_excl_index).product_attribute_context := p_modifier_line_tbl(i).product_attribute_context;
      l_exclusion_tbl(l_excl_index).product_attribute := p_modifier_line_tbl(i).product_attr;
      l_exclusion_tbl(l_excl_index).product_attr_value := p_modifier_line_tbl(i).product_attr_val;
    ELSE
      l_prod_index := l_prod_index + 1;
      l_modifier_line_tbl(l_prod_index).OFFER_LINE_TYPE             := p_modifier_line_tbl(i).OFFER_LINE_TYPE;
      l_modifier_line_tbl(l_prod_index).OPERATION                   := p_modifier_line_tbl(i).OPERATION;
      l_modifier_line_tbl(l_prod_index).LIST_LINE_ID                := p_modifier_line_tbl(i).LIST_LINE_ID;
      l_modifier_line_tbl(l_prod_index).LIST_HEADER_ID              := x_qp_list_header_id;
      l_modifier_line_tbl(l_prod_index).LIST_LINE_TYPE_CODE         := p_modifier_line_tbl(i).LIST_LINE_TYPE_CODE;
      l_modifier_line_tbl(l_prod_index).OPERAND                     := p_modifier_line_tbl(i).OPERAND;
      l_modifier_line_tbl(l_prod_index).START_DATE_ACTIVE           := p_modifier_line_tbl(i).START_DATE_ACTIVE;
      l_modifier_line_tbl(l_prod_index).END_DATE_ACTIVE             := p_modifier_line_tbl(i).END_DATE_ACTIVE;
      l_modifier_line_tbl(l_prod_index).ARITHMETIC_OPERATOR         := p_modifier_line_tbl(i).ARITHMETIC_OPERATOR;
      l_modifier_line_tbl(l_prod_index).INACTIVE_FLAG               := p_modifier_line_tbl(i).ACTIVE_FLAG;
      l_modifier_line_tbl(l_prod_index).QD_OPERAND                  := p_modifier_line_tbl(i).QD_OPERAND;
      l_modifier_line_tbl(l_prod_index).QD_ARITHMETIC_OPERATOR      := p_modifier_line_tbl(i).QD_ARITHMETIC_OPERATOR;
      l_modifier_line_tbl(l_prod_index).QD_RELATED_DEAL_LINES_ID    := p_modifier_line_tbl(i).QD_RELATED_DEAL_LINES_ID;
      l_modifier_line_tbl(l_prod_index).QD_OBJECT_VERSION_NUMBER    := p_modifier_line_tbl(i).QD_OBJECT_VERSION_NUMBER;
      l_modifier_line_tbl(l_prod_index).QD_ESTIMATED_QTY_IS_MAX     := p_modifier_line_tbl(i).QD_ESTIMATED_QTY_IS_MAX;
      l_modifier_line_tbl(l_prod_index).QD_LIST_LINE_ID             := p_modifier_line_tbl(i).QD_LIST_LINE_ID;
      l_modifier_line_tbl(l_prod_index).QD_ESTIMATED_AMOUNT_IS_MAX  := p_modifier_line_tbl(i).QD_ESTIMATED_AMOUNT_IS_MAX;
      l_modifier_line_tbl(l_prod_index).ESTIM_GL_VALUE              := p_modifier_line_tbl(i).ESTIM_GL_VALUE;
      l_modifier_line_tbl(l_prod_index).BENEFIT_PRICE_LIST_LINE_ID  := p_modifier_line_tbl(i).BENEFIT_PRICE_LIST_LINE_ID;
      l_modifier_line_tbl(l_prod_index).BENEFIT_LIMIT               := p_modifier_line_tbl(i).BENEFIT_LIMIT;
      l_modifier_line_tbl(l_prod_index).BENEFIT_QTY                 := p_modifier_line_tbl(i).BENEFIT_QTY;
      l_modifier_line_tbl(l_prod_index).BENEFIT_UOM_CODE            := p_modifier_line_tbl(i).BENEFIT_UOM_CODE;
      l_modifier_line_tbl(l_prod_index).SUBSTITUTION_CONTEXT        := p_modifier_line_tbl(i).SUBSTITUTION_CONTEXT;
      l_modifier_line_tbl(l_prod_index).SUBSTITUTION_ATTR           := p_modifier_line_tbl(i).SUBSTITUTION_ATTR;
      l_modifier_line_tbl(l_prod_index).SUBSTITUTION_VAL            := p_modifier_line_tbl(i).SUBSTITUTION_VAL;
      l_modifier_line_tbl(l_prod_index).PRICE_BREAK_TYPE_CODE       := p_modifier_line_tbl(i).PRICE_BREAK_TYPE_CODE;
      l_modifier_line_tbl(l_prod_index).PRICING_ATTRIBUTE_ID        := p_modifier_line_tbl(i).PRICING_ATTRIBUTE_ID;
      l_modifier_line_tbl(l_prod_index).PRODUCT_ATTRIBUTE_CONTEXT   := p_modifier_line_tbl(i).PRODUCT_ATTRIBUTE_CONTEXT;
      l_modifier_line_tbl(l_prod_index).PRODUCT_ATTR                := p_modifier_line_tbl(i).PRODUCT_ATTR;
      l_modifier_line_tbl(l_prod_index).PRODUCT_ATTR_VAL            := p_modifier_line_tbl(i).PRODUCT_ATTR_VAL;
      l_modifier_line_tbl(l_prod_index).PRODUCT_UOM_CODE            := p_modifier_line_tbl(i).PRODUCT_UOM_CODE;
      l_modifier_line_tbl(l_prod_index).PRICING_ATTRIBUTE_CONTEXT   := p_modifier_line_tbl(i).PRICING_ATTRIBUTE_CONTEXT;
      l_modifier_line_tbl(l_prod_index).PRICING_ATTR                := p_modifier_line_tbl(i).PRICING_ATTR;
      l_modifier_line_tbl(l_prod_index).PRICING_ATTR_VALUE_FROM     := p_modifier_line_tbl(i).PRICING_ATTR_VALUE_FROM;
      l_modifier_line_tbl(l_prod_index).PRICING_ATTR_VALUE_TO       := p_modifier_line_tbl(i).PRICING_ATTR_VALUE_TO;
      l_modifier_line_tbl(l_prod_index).EXCLUDER_FLAG               := p_modifier_line_tbl(i).EXCLUDER_FLAG;
      l_modifier_line_tbl(l_prod_index).ORDER_VALUE_FROM            := p_modifier_line_tbl(i).ORDER_VALUE_FROM;
      l_modifier_line_tbl(l_prod_index).ORDER_VALUE_TO              := p_modifier_line_tbl(i).ORDER_VALUE_TO;
      l_modifier_line_tbl(l_prod_index).QUALIFIER_ID                := p_modifier_line_tbl(i).QUALIFIER_ID;
      l_modifier_line_tbl(l_prod_index).COMMENTS                    := p_modifier_line_tbl(i).COMMENTS;
      l_modifier_line_tbl(l_prod_index).CONTEXT                     := p_modifier_line_tbl(i).CONTEXT;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE1                  := p_modifier_line_tbl(i).ATTRIBUTE1;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE2                  := p_modifier_line_tbl(i).ATTRIBUTE2;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE3                  := p_modifier_line_tbl(i).ATTRIBUTE3;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE4                  := p_modifier_line_tbl(i).ATTRIBUTE4;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE5                  := p_modifier_line_tbl(i).ATTRIBUTE5;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE6                  := p_modifier_line_tbl(i).ATTRIBUTE6;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE7                  := p_modifier_line_tbl(i).ATTRIBUTE7;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE8                  := p_modifier_line_tbl(i).ATTRIBUTE8;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE9                  := p_modifier_line_tbl(i).ATTRIBUTE9;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE10                 := p_modifier_line_tbl(i).ATTRIBUTE10;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE11                 := p_modifier_line_tbl(i).ATTRIBUTE11;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE12                 := p_modifier_line_tbl(i).ATTRIBUTE12;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE13                 := p_modifier_line_tbl(i).ATTRIBUTE13;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE14                 := p_modifier_line_tbl(i).ATTRIBUTE14;
      l_modifier_line_tbl(l_prod_index).ATTRIBUTE15                 := p_modifier_line_tbl(i).ATTRIBUTE15;
      l_modifier_line_tbl(l_prod_index).MAX_QTY_PER_ORDER           := p_modifier_line_tbl(i).MAX_QTY_PER_ORDER;
      l_modifier_line_tbl(l_prod_index).MAX_QTY_PER_ORDER_ID        := p_modifier_line_tbl(i).MAX_QTY_PER_ORDER_ID;
      l_modifier_line_tbl(l_prod_index).MAX_QTY_PER_CUSTOMER        := p_modifier_line_tbl(i).MAX_QTY_PER_CUSTOMER;
      l_modifier_line_tbl(l_prod_index).MAX_QTY_PER_CUSTOMER_ID     := p_modifier_line_tbl(i).MAX_QTY_PER_CUSTOMER_ID;
      l_modifier_line_tbl(l_prod_index).MAX_QTY_PER_RULE            := p_modifier_line_tbl(i).MAX_QTY_PER_RULE;
      l_modifier_line_tbl(l_prod_index).MAX_QTY_PER_RULE_ID         := p_modifier_line_tbl(i).MAX_QTY_PER_RULE_ID;
      l_modifier_line_tbl(l_prod_index).MAX_ORDERS_PER_CUSTOMER     := p_modifier_line_tbl(i).MAX_ORDERS_PER_CUSTOMER;
      l_modifier_line_tbl(l_prod_index).MAX_ORDERS_PER_CUSTOMER_ID  := p_modifier_line_tbl(i).MAX_ORDERS_PER_CUSTOMER_ID;
      l_modifier_line_tbl(l_prod_index).MAX_AMOUNT_PER_RULE         := p_modifier_line_tbl(i).MAX_AMOUNT_PER_RULE;
      l_modifier_line_tbl(l_prod_index).MAX_AMOUNT_PER_RULE_ID      := p_modifier_line_tbl(i).MAX_AMOUNT_PER_RULE_ID;
      l_modifier_line_tbl(l_prod_index).ESTIMATE_QTY_UOM            := p_modifier_line_tbl(i).ESTIMATE_QTY_UOM;
      l_modifier_line_tbl(l_prod_index).generate_using_formula_id   := p_modifier_line_tbl(i).generate_using_formula_id;
      l_modifier_line_tbl(l_prod_index).price_by_formula_id         := p_modifier_line_tbl(i).price_by_formula_id;
      l_modifier_line_tbl(l_prod_index).generate_using_formula      := p_modifier_line_tbl(i).generate_using_formula;
      l_modifier_line_tbl(l_prod_index).price_by_formula            := p_modifier_line_tbl(i).price_by_formula;
    END IF;
  END LOOP;
  END IF;

  IF l_exclusion_tbl.COUNT > 0 THEN
    ozf_offer_pvt.process_exclusions(
       p_init_msg_list    => p_init_msg_list
      ,p_api_version      => p_api_version
      ,p_commit           => p_commit
      ,x_return_status    => x_return_status
      ,x_msg_count        => x_msg_count
      ,x_msg_data         => x_msg_data
      ,p_pricing_attr_tbl => l_exclusion_tbl
      ,x_error_location   => x_error_location);

    IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
    ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;
  END IF;

  -- offer line
  IF p_offer_type IN ('LUMPSUM', 'SCAN_DATA') THEN
    IF p_act_product_tbl.COUNT > 0 THEN
    FOR i IN p_act_product_tbl.FIRST..p_act_product_tbl.LAST LOOP
      l_act_product_rec := NULL;

      l_act_product_rec.arc_act_product_used_by := 'OFFR';
      l_act_product_rec.primary_product_flag := p_act_product_tbl(i).primary_product_flag;
      l_act_product_rec.enabled_flag := p_act_product_tbl(i).enabled_flag;
      l_act_product_rec.inventory_item_id := p_act_product_tbl(i).inventory_item_id;
      l_act_product_rec.organization_id := p_act_product_tbl(i).organization_id;
      l_act_product_rec.category_id := p_act_product_tbl(i).category_id;
      l_act_product_rec.category_set_id := p_act_product_tbl(i).category_set_id;
      l_act_product_rec.attribute_category := p_act_product_tbl(i).attribute_category;
      l_act_product_rec.level_type_code := p_act_product_tbl(i).level_type_code;
      l_act_product_rec.excluded_flag := p_act_product_tbl(i).excluded_flag;
      l_act_product_rec.line_lumpsum_amount := p_act_product_tbl(i).line_lumpsum_amount;
      l_act_product_rec.line_lumpsum_qty := p_act_product_tbl(i).line_lumpsum_qty;
      l_act_product_rec.scan_value := p_act_product_tbl(i).scan_value;
      l_act_product_rec.uom_code := p_act_product_tbl(i).uom_code;
      l_act_product_rec.scan_unit_forecast := p_act_product_tbl(i).scan_unit_forecast;
      l_act_product_rec.channel_id := p_act_product_tbl(i).channel_id;
      l_act_product_rec.quantity := p_act_product_tbl(i).quantity;
      l_act_product_rec.adjustment_flag := p_act_product_tbl(i).adjustment_flag;

      IF p_act_product_tbl(i).operation = 'CREATE' THEN
        IF p_act_product_tbl(i).act_product_used_by_id IS NULL OR p_act_product_tbl(i).act_product_used_by_id = FND_API.g_miss_num THEN
          l_act_product_rec.act_product_used_by_id := x_qp_list_header_id;
        ELSE
          l_act_product_rec.act_product_used_by_id := p_act_product_tbl(i).act_product_used_by_id;
        END IF;

        AMS_ActProduct_PVT.Create_Act_Product(
          p_api_version      => p_api_version,
          p_init_msg_list    => p_init_msg_list,
          p_commit           => p_commit,
          p_validation_level => FND_API.G_VALID_LEVEL_FULL,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data,
          p_act_Product_rec  => l_act_product_rec,
          x_act_Product_id   => l_act_product_id);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_act_product_tbl(i).operation = 'UPDATE' THEN
        l_act_product_rec.activity_product_id := p_act_product_tbl(i).activity_product_id;
        l_act_product_rec.object_version_number := p_act_product_tbl(i).object_version_number;
        l_act_product_rec.act_product_used_by_id := p_act_product_tbl(i).act_product_used_by_id;

        AMS_ActProduct_PVT.Update_Act_Product(
          p_api_version      => p_api_version,
          p_init_msg_list    => p_init_msg_list,
          p_commit           => p_commit,
          p_validation_level => FND_API.G_VALID_LEVEL_FULL,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data,
          p_act_Product_rec  => l_act_product_rec);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_act_product_tbl(i).operation = 'DELETE' THEN
        AMS_ActProduct_PVT.Delete_Act_Product(
          p_api_version      => p_api_version,
          p_init_msg_list    => p_init_msg_list,
          p_commit           => p_commit,
          p_validation_level => FND_API.G_VALID_LEVEL_FULL,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data,
          p_act_Product_id   => p_act_product_tbl(i).activity_product_id,
          p_object_version   => p_act_product_tbl(i).object_version_number);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      END IF;
    END LOOP;
    END IF;
  ELSIF p_offer_type = 'NET_ACCRUAL' THEN
    IF l_modifier_list_rec.tier_level = 'LINE' THEN
      IF p_discount_tbl.COUNT > 0 THEN
      FOR i IN p_discount_tbl.FIRST..p_discount_tbl.LAST LOOP
        l_discount_line_rec.parent_discount_line_id := p_discount_tbl(i).parent_discount_line_id;
        l_discount_line_rec.volume_from := p_discount_tbl(i).volume_from;
        l_discount_line_rec.volume_to := p_discount_tbl(i).volume_to;
        l_discount_line_rec.volume_operator := p_discount_tbl(i).volume_operator;
        l_discount_line_rec.volume_type := p_discount_tbl(i).volume_type;
        l_discount_line_rec.volume_break_type := p_discount_tbl(i).volume_break_type;
        l_discount_line_rec.discount := p_discount_tbl(i).discount;
        l_discount_line_rec.discount_type := p_discount_tbl(i).discount_type;
        l_discount_line_rec.tier_type := p_discount_tbl(i).tier_type;
        l_discount_line_rec.tier_level := p_discount_tbl(i).tier_level;
        l_discount_line_rec.incompatibility_group := p_discount_tbl(i).incompatibility_group;
        l_discount_line_rec.precedence := p_discount_tbl(i).precedence;
        l_discount_line_rec.bucket := p_discount_tbl(i).bucket;
        l_discount_line_rec.scan_value := p_discount_tbl(i).scan_value;
        l_discount_line_rec.scan_data_quantity := p_discount_tbl(i).scan_data_quantity;
        l_discount_line_rec.scan_unit_forecast := p_discount_tbl(i).scan_unit_forecast;
        l_discount_line_rec.channel_id := p_discount_tbl(i).channel_id;
        l_discount_line_rec.adjustment_flag := p_discount_tbl(i).adjustment_flag;
        l_discount_line_rec.start_date_active := p_discount_tbl(i).start_date_active;
        l_discount_line_rec.end_date_active := p_discount_tbl(i).end_date_active;
        l_discount_line_rec.uom_code := p_discount_tbl(i).uom_code;
        l_discount_line_rec.off_discount_product_id := p_discount_tbl(i).off_discount_product_id;
        l_discount_line_rec.parent_off_disc_prod_id := p_discount_tbl(i).parent_off_disc_prod_id;
        l_discount_line_rec.product_level := p_discount_tbl(i).product_level;
        l_discount_line_rec.product_id := p_discount_tbl(i).product_id;
        l_discount_line_rec.excluder_flag := p_discount_tbl(i).excluder_flag;

        IF p_discount_tbl(i).operation = 'CREATE' THEN
          IF p_discount_tbl(i).offer_id IS NULL OR p_discount_tbl(i).offer_id = FND_API.g_miss_num THEN
            l_discount_line_rec.offer_id := l_offer_id;
          ELSE
            l_discount_line_rec.offer_id := p_discount_tbl(i).offer_id;
          END IF;

          OZF_Disc_Line_PVT.Create_discount_line(
            p_api_version_number     => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_commit                 => p_commit,
            p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_ozf_discount_line_rec  => l_discount_line_rec,
            x_offer_discount_line_id => l_discount_line_id);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        ELSIF p_discount_tbl(i).operation = 'UPDATE' THEN
          l_discount_line_rec.offer_discount_line_id := p_discount_tbl(i).offer_discount_line_id;
          l_discount_line_rec.offer_id := p_discount_tbl(i).offer_id;
          l_discount_line_rec.object_version_number := p_discount_tbl(i).object_version_number;

          OZF_Disc_Line_PVT.Update_discount_line(
            p_api_version_number     => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_commit                 => p_commit,
            p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_ozf_discount_line_rec  => l_discount_line_rec);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        ELSIF p_discount_tbl(i).operation = 'DELETE' THEN
          OZF_Disc_Line_PVT.Delete_offer_line(
            p_api_version_number     => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_commit                 => p_commit,
            p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_offer_discount_line_id => p_discount_tbl(i).offer_discount_line_id,
            p_object_version_number  => p_discount_tbl(i).object_version_number);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        END IF;
      END LOOP;
      END IF;

      IF p_excl_tbl.COUNT > 0 THEN
      FOR i IN p_excl_tbl.FIRST..p_excl_tbl.LAST LOOP
        l_excl_rec.product_level := p_excl_tbl(i).product_level;
        l_excl_rec.product_id := p_excl_tbl(i).product_id;
        l_excl_rec.start_date_active := p_excl_tbl(i).start_date_active;
        l_excl_rec.end_date_active := p_excl_tbl(i).end_date_active;
        l_excl_rec.parent_off_disc_prod_id := p_excl_tbl(i).parent_off_disc_prod_id;

        IF p_excl_tbl(i).operation = 'CREATE' THEN
          OZF_Disc_Line_PVT.Create_Product_Exclusion(
            p_api_version_number      => p_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data,
            p_ozf_excl_rec            => l_excl_rec,
            x_off_discount_product_id => l_discount_product_id);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        ELSIF p_excl_tbl(i).operation = 'UPDATE' THEN
          l_excl_rec.off_discount_product_id := p_excl_tbl(i).off_discount_product_id;
          l_excl_rec.object_version_number := p_excl_tbl(i).object_version_number;

          OZF_Disc_Line_PVT.Update_Product_Exclusion(
            p_api_version_number => p_api_version,
            p_init_msg_list      => p_init_msg_list,
            p_commit             => p_commit,
            p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_ozf_excl_rec       => l_excl_rec);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        ELSIF p_excl_tbl(i).operation = 'DELETE' THEN
          OZF_Disc_Line_PVT.Delete_Ozf_Prod_Line(
            p_api_version_number      => p_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data,
            p_off_discount_product_id => p_excl_tbl(i).off_discount_product_id,
            p_object_version_number   => p_excl_tbl(i).object_version_number);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        END IF;
      END LOOP;
      END IF;

      IF p_offer_tier_tbl.COUNT > 0 THEN
      FOR i IN p_offer_tier_tbl.FIRST..p_offer_tier_tbl.LAST LOOP
        l_offer_tier_rec.parent_discount_line_id := p_offer_tier_tbl(i).parent_discount_line_id;
        l_offer_tier_rec.offer_id := p_offer_tier_tbl(i).offer_id;
        l_offer_tier_rec.volume_from := p_offer_tier_tbl(i).volume_from;
        l_offer_tier_rec.volume_to := p_offer_tier_tbl(i).volume_to;
        l_offer_tier_rec.volume_operator := p_offer_tier_tbl(i).volume_operator;
        l_offer_tier_rec.volume_type := p_offer_tier_tbl(i).volume_type;
        l_offer_tier_rec.volume_break_type := p_offer_tier_tbl(i).volume_break_type;
        l_offer_tier_rec.discount := p_offer_tier_tbl(i).discount;
        l_offer_tier_rec.discount_type := p_offer_tier_tbl(i).discount_type;
        l_offer_tier_rec.start_date_active := p_offer_tier_tbl(i).start_date_active;
        l_offer_tier_rec.end_date_active := p_offer_tier_tbl(i).end_date_active;
        l_offer_tier_rec.uom_code := p_offer_tier_tbl(i).uom_code;

        IF p_offer_tier_tbl(i).operation = 'CREATE' THEN
          OZF_Disc_Line_PVT.Create_Disc_Tiers(
            p_api_version_number     => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_commit                 => p_commit,
            p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_tier_rec               => l_offer_tier_rec,
            x_offer_discount_line_id => l_discount_line_id);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        ELSIF p_offer_tier_tbl(i).operation = 'UPDATE' THEN
          l_offer_tier_rec.offer_discount_line_id := p_offer_tier_tbl(i).offer_discount_line_id;
          l_offer_tier_rec.object_version_number := p_offer_tier_tbl(i).object_version_number;

          OZF_Disc_Line_PVT.Update_Disc_Tiers(
            p_api_version_number     => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_commit                 => p_commit,
            p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_tier_rec               => l_offer_tier_rec);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        ELSIF p_offer_tier_tbl(i).operation = 'DELETE' THEN
          IF p_offer_tier_tbl(i).parent_discount_line_id IS NULL OR p_offer_tier_tbl(i).parent_discount_line_id = FND_API.g_miss_num THEN
            OZF_Disc_Line_PVT.Delete_Disc_tiers(
              p_api_version_number      => p_api_version,
              p_init_msg_list           => p_init_msg_list,
              p_commit                  => p_commit,
              p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
              x_return_status           => x_return_status,
              x_msg_count               => x_msg_count,
              x_msg_data                => x_msg_data,
              p_parent_discount_line_id => p_offer_tier_tbl(i).offer_discount_line_id);

            IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;
          ELSE
            OZF_Disc_Line_PVT.Delete_Tier_line(
              p_api_version_number     => p_api_version,
              p_init_msg_list          => p_init_msg_list,
              p_commit                 => p_commit,
              p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_offer_discount_line_id => p_offer_tier_tbl(i).offer_discount_line_id,
              p_object_version_number  => p_offer_tier_tbl(i).object_version_number);

            IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;
          END IF;
        END IF;
      END LOOP;
      END IF;
    ELSIF l_modifier_list_rec.tier_level = 'HEADER' THEN
      IF p_prod_tbl.COUNT > 0 THEN
      FOR i IN p_prod_tbl.FIRST..p_prod_tbl.LAST LOOP
        l_prod_rec.parent_off_disc_prod_id := p_prod_tbl(i).parent_off_disc_prod_id;
        l_prod_rec.product_level := p_prod_tbl(i).product_level;
        l_prod_rec.product_id := p_prod_tbl(i).product_id;
        l_prod_rec.excluder_flag := p_prod_tbl(i).excluder_flag;
        l_prod_rec.uom_code := p_prod_tbl(i).uom_code;
        l_prod_rec.start_date_active := p_prod_tbl(i).start_date_active;
        l_prod_rec.end_date_active := p_prod_tbl(i).end_date_active;
        l_prod_rec.offer_discount_line_id := p_prod_tbl(i).offer_discount_line_id;

        IF p_prod_tbl(i).operation = 'CREATE' THEN
          IF p_prod_tbl(i).offer_id IS NULL OR p_prod_tbl(i).offer_id = FND_API.g_miss_num THEN
            l_prod_rec.offer_id := l_offer_id;
          ELSE
            l_prod_rec.offer_id := p_prod_tbl(i).offer_id;
          END IF;

          OZF_Disc_Line_PVT.Create_Ozf_Prod_Line(
            p_api_version_number      => p_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data,
            p_ozf_prod_rec            => l_prod_rec,
            x_off_discount_product_id => l_discount_product_id);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        ELSIF p_prod_tbl(i).operation = 'UPDATE' THEN
          l_prod_rec.off_discount_product_id := p_prod_tbl(i).off_discount_product_id;
          l_prod_rec.offer_id := p_prod_tbl(i).offer_id;
          l_prod_rec.object_version_number := p_prod_tbl(i).object_version_number;

          OZF_Disc_Line_PVT.Update_Ozf_Prod_Line(
            p_api_version_number      => p_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data,
            p_ozf_prod_rec            => l_prod_rec);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        ELSIF p_prod_tbl(i).operation = 'DELETE' THEN
          OZF_Disc_Line_PVT.Delete_Ozf_Prod_Line(
            p_api_version_number      => p_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data,
            p_off_discount_product_id => p_prod_tbl(i).off_discount_product_id,
            p_object_version_number   => p_prod_tbl(i).object_version_number);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        END IF;
      END LOOP;
      END IF;
    END IF;

    IF p_excl_tbl.COUNT > 0 THEN
    FOR i IN p_excl_tbl.FIRST..p_excl_tbl.LAST LOOP
      l_excl_rec.product_level := p_excl_tbl(i).product_level;
      l_excl_rec.product_id := p_excl_tbl(i).product_id;
      l_excl_rec.start_date_active := p_excl_tbl(i).start_date_active;
      l_excl_rec.end_date_active := p_excl_tbl(i).end_date_active;
      l_excl_rec.parent_off_disc_prod_id := p_excl_tbl(i).parent_off_disc_prod_id;

      IF p_excl_tbl(i).operation = 'CREATE' THEN
        OZF_Disc_Line_PVT.Create_Product_Exclusion(
          p_api_version_number      => p_api_version,
          p_init_msg_list           => p_init_msg_list,
          p_commit                  => p_commit,
          p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          p_ozf_excl_rec            => l_excl_rec,
          x_off_discount_product_id => l_discount_product_id);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_excl_tbl(i).operation = 'UPDATE' THEN
        l_excl_rec.off_discount_product_id := p_excl_tbl(i).off_discount_product_id;
        l_excl_rec.object_version_number := p_excl_tbl(i).object_version_number;

        OZF_Disc_Line_PVT.Update_Product_Exclusion(
          p_api_version_number => p_api_version,
          p_init_msg_list      => p_init_msg_list,
          p_commit             => p_commit,
          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          p_ozf_excl_rec       => l_excl_rec);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_excl_tbl(i).operation = 'DELETE' THEN
        OZF_Disc_Line_PVT.Delete_Ozf_Prod_Line(
          p_api_version_number      => p_api_version,
          p_init_msg_list           => p_init_msg_list,
          p_commit                  => p_commit,
          p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          p_off_discount_product_id => p_excl_tbl(i).off_discount_product_id,
          p_object_version_number   => p_excl_tbl(i).object_version_number);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      END IF;
    END LOOP;
    END IF;

    IF p_offer_tier_tbl.COUNT > 0 THEN
    FOR i IN p_offer_tier_tbl.FIRST..p_offer_tier_tbl.LAST LOOP
      l_offer_tier_rec.parent_discount_line_id := p_offer_tier_tbl(i).parent_discount_line_id;
      l_offer_tier_rec.offer_id := p_offer_tier_tbl(i).offer_id;
      l_offer_tier_rec.volume_from := p_offer_tier_tbl(i).volume_from;
      l_offer_tier_rec.volume_to := p_offer_tier_tbl(i).volume_to;
      l_offer_tier_rec.volume_operator := p_offer_tier_tbl(i).volume_operator;
      l_offer_tier_rec.volume_type := p_offer_tier_tbl(i).volume_type;
      l_offer_tier_rec.volume_break_type := p_offer_tier_tbl(i).volume_break_type;
      l_offer_tier_rec.discount := p_offer_tier_tbl(i).discount;
      l_offer_tier_rec.discount_type := p_offer_tier_tbl(i).discount_type;
      l_offer_tier_rec.start_date_active := p_offer_tier_tbl(i).start_date_active;
      l_offer_tier_rec.end_date_active := p_offer_tier_tbl(i).end_date_active;
      l_offer_tier_rec.uom_code := p_offer_tier_tbl(i).uom_code;

      IF p_offer_tier_tbl(i).operation = 'CREATE' THEN
        OZF_Disc_Line_PVT.Create_Disc_Tiers(
          p_api_version_number     => p_api_version,
          p_init_msg_list          => p_init_msg_list,
          p_commit                 => p_commit,
          p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_tier_rec               => l_offer_tier_rec,
          x_offer_discount_line_id => l_discount_line_id);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_offer_tier_tbl(i).operation = 'UPDATE' THEN
        l_offer_tier_rec.offer_discount_line_id := p_offer_tier_tbl(i).offer_discount_line_id;
        l_offer_tier_rec.object_version_number := p_offer_tier_tbl(i).object_version_number;

        OZF_Disc_Line_PVT.Update_Disc_Tiers(
          p_api_version_number     => p_api_version,
          p_init_msg_list          => p_init_msg_list,
          p_commit                 => p_commit,
          p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_tier_rec               => l_offer_tier_rec);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_offer_tier_tbl(i).operation = 'DELETE' THEN
        IF p_offer_tier_tbl(i).parent_discount_line_id IS NULL OR p_offer_tier_tbl(i).parent_discount_line_id = FND_API.g_miss_num THEN
          OZF_Disc_Line_PVT.Delete_Disc_tiers(
            p_api_version_number      => p_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data,
            p_parent_discount_line_id => p_offer_tier_tbl(i).offer_discount_line_id);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        ELSE
          OZF_Disc_Line_PVT.Delete_Tier_line(
            p_api_version_number     => p_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_commit                 => p_commit,
            p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_offer_discount_line_id => p_offer_tier_tbl(i).offer_discount_line_id,
            p_object_version_number  => p_offer_tier_tbl(i).object_version_number);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        END IF;
      END IF;
    END LOOP;
    END IF;
  END IF; -- end offer_type

  Ozf_Offer_Pvt.process_modifiers(
     p_init_msg_list     => p_init_msg_list
    ,p_api_version       => p_api_version
    ,p_commit            => p_commit
    ,x_return_status     => x_return_status
    ,x_msg_count         => x_msg_count
    ,x_msg_data          => x_msg_data
    ,p_offer_type        => p_offer_type
    ,p_modifier_list_rec => l_modifier_list_rec
    ,p_modifier_line_tbl => l_modifier_line_tbl
    ,x_qp_list_header_id => l_dummy
    ,x_error_location    => x_error_location);

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  -- process qualifier
  IF p_offer_type = 'NET_ACCRUAL' THEN
    IF p_na_qualifier_tbl.COUNT > 0 THEN
    FOR i IN p_na_qualifier_tbl.FIRST..p_na_qualifier_tbl.LAST LOOP
      l_na_qualifier_rec.qualifier_id           := p_na_qualifier_tbl(i).qualifier_id;
      l_na_qualifier_rec.qualifier_grouping_no  := p_na_qualifier_tbl(i).qualifier_grouping_no;
      l_na_qualifier_rec.qualifier_context      := p_na_qualifier_tbl(i).qualifier_context;
      l_na_qualifier_rec.qualifier_attribute    := p_na_qualifier_tbl(i).qualifier_attribute;
      l_na_qualifier_rec.qualifier_attr_value   := p_na_qualifier_tbl(i).qualifier_attr_value;
      l_na_qualifier_rec.start_date_active      := p_na_qualifier_tbl(i).start_date_active;
      l_na_qualifier_rec.end_date_active        := p_na_qualifier_tbl(i).end_date_active;
      l_na_qualifier_rec.offer_id               := l_offer_id;
      l_na_qualifier_rec.offer_discount_line_id := p_na_qualifier_tbl(i).offer_discount_line_id;
      l_na_qualifier_rec.context                := p_na_qualifier_tbl(i).context;
      l_na_qualifier_rec.attribute1             := p_na_qualifier_tbl(i).attribute1;
      l_na_qualifier_rec.attribute2             := p_na_qualifier_tbl(i).attribute2;
      l_na_qualifier_rec.attribute3             := p_na_qualifier_tbl(i).attribute3;
      l_na_qualifier_rec.attribute4             := p_na_qualifier_tbl(i).attribute4;
      l_na_qualifier_rec.attribute5             := p_na_qualifier_tbl(i).attribute5;
      l_na_qualifier_rec.attribute6             := p_na_qualifier_tbl(i).attribute6;
      l_na_qualifier_rec.attribute7             := p_na_qualifier_tbl(i).attribute7;
      l_na_qualifier_rec.attribute8             := p_na_qualifier_tbl(i).attribute8;
      l_na_qualifier_rec.attribute9             := p_na_qualifier_tbl(i).attribute9;
      l_na_qualifier_rec.attribute10            := p_na_qualifier_tbl(i).attribute10;
      l_na_qualifier_rec.attribute11            := p_na_qualifier_tbl(i).attribute11;
      l_na_qualifier_rec.attribute12            := p_na_qualifier_tbl(i).attribute12;
      l_na_qualifier_rec.attribute13            := p_na_qualifier_tbl(i).attribute13;
      l_na_qualifier_rec.attribute14            := p_na_qualifier_tbl(i).attribute14;
      l_na_qualifier_rec.attribute15            := p_na_qualifier_tbl(i).attribute15;
      IF p_na_qualifier_tbl(i).active_flag IS NULL THEN
        l_na_qualifier_rec.active_flag            := 'Y'; -- set qualifier default to Active
      ELSE
        l_na_qualifier_rec.active_flag            := p_na_qualifier_tbl(i).active_flag;
      END IF;
      l_na_qualifier_rec.object_version_number  := p_na_qualifier_tbl(i).object_version_number;

      IF p_na_qualifier_tbl(i).operation = 'CREATE' THEN
        OZF_Offr_Qual_PVT.Create_Offr_Qual(
          p_api_version_number => p_api_version,
          p_init_msg_list      => p_init_msg_list,
          p_commit             => p_commit,
          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          p_ozf_offr_qual_rec  => l_na_qualifier_rec,
          x_qualifier_id       => l_na_qualifier_id);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_na_qualifier_tbl(i).operation = 'UPDATE' THEN
        OZF_Offr_Qual_PVT.Update_Offr_Qual(
          p_api_version_number => p_api_version,
          p_init_msg_list      => p_init_msg_list,
          p_commit             => p_commit,
          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          p_ozf_offr_qual_rec  => l_na_qualifier_rec);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_na_qualifier_tbl(i).operation = 'DELETE' THEN
        OZF_Offr_Qual_PVT.Delete_Offr_Qual(
          p_api_version_number    => p_api_version,
          p_init_msg_list         => p_init_msg_list,
          p_commit                => p_commit,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          p_qualifier_id          => l_na_qualifier_rec.qualifier_id,
          p_object_version_number => l_na_qualifier_rec.object_version_number);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      END IF;
    END LOOP;
    END IF;
  ELSE
    IF p_qualifier_tbl.COUNT > 0 THEN
      FOR i IN p_qualifier_tbl.FIRST..p_qualifier_tbl.LAST LOOP
        l_qualifiers_tbl(i).list_header_id             := x_qp_list_header_id;
        l_qualifiers_tbl(i).qualifier_context          := p_qualifier_tbl(i).qualifier_context;
        l_qualifiers_tbl(i).qualifier_attribute        := p_qualifier_tbl(i).qualifier_attribute;
        l_qualifiers_tbl(i).qualifier_attr_value       := p_qualifier_tbl(i).qualifier_attr_value;
        l_qualifiers_tbl(i).qualifier_attr_value_to    := p_qualifier_tbl(i).qualifier_attr_value_to;
        l_qualifiers_tbl(i).comparison_operator_code   := p_qualifier_tbl(i).comparison_operator_code;
        l_qualifiers_tbl(i).qualifier_grouping_no      := p_qualifier_tbl(i).qualifier_grouping_no;
        l_qualifiers_tbl(i).list_line_id               := p_qualifier_tbl(i).list_line_id;
        l_qualifiers_tbl(i).qualifier_id               := p_qualifier_tbl(i).qualifier_id;
        l_qualifiers_tbl(i).start_date_active          := p_qualifier_tbl(i).start_date_active;
        l_qualifiers_tbl(i).end_date_active            := p_qualifier_tbl(i).end_date_active;
        l_qualifiers_tbl(i).activity_market_segment_id := p_qualifier_tbl(i).activity_market_segment_id;
        l_qualifiers_tbl(i).operation                  := p_qualifier_tbl(i).operation;
        l_qualifiers_tbl(i).context                    := p_qualifier_tbl(i).context;
        l_qualifiers_tbl(i).attribute1                 := p_qualifier_tbl(i).attribute1;
        l_qualifiers_tbl(i).attribute2                 := p_qualifier_tbl(i).attribute2;
        l_qualifiers_tbl(i).attribute3                 := p_qualifier_tbl(i).attribute3;
        l_qualifiers_tbl(i).attribute4                 := p_qualifier_tbl(i).attribute4;
        l_qualifiers_tbl(i).attribute5                 := p_qualifier_tbl(i).attribute5;
        l_qualifiers_tbl(i).attribute6                 := p_qualifier_tbl(i).attribute6;
        l_qualifiers_tbl(i).attribute7                 := p_qualifier_tbl(i).attribute7;
        l_qualifiers_tbl(i).attribute8                 := p_qualifier_tbl(i).attribute8;
        l_qualifiers_tbl(i).attribute9                 := p_qualifier_tbl(i).attribute9;
        l_qualifiers_tbl(i).attribute10                := p_qualifier_tbl(i).attribute10;
        l_qualifiers_tbl(i).attribute11                := p_qualifier_tbl(i).attribute11;
        l_qualifiers_tbl(i).attribute12                := p_qualifier_tbl(i).attribute12;
        l_qualifiers_tbl(i).attribute13                := p_qualifier_tbl(i).attribute13;
        l_qualifiers_tbl(i).attribute14                := p_qualifier_tbl(i).attribute14;
        l_qualifiers_tbl(i).attribute15                := p_qualifier_tbl(i).attribute15;
      END LOOP;

      Ozf_Offer_Pvt.process_market_qualifiers(
         p_init_msg_list  => p_init_msg_list
        ,p_api_version    => p_api_version
        ,p_commit         => p_commit
        ,x_return_status  => x_return_status
        ,x_msg_count      => x_msg_count
        ,x_msg_data       => x_msg_data
        ,p_qualifiers_tbl => l_qualifiers_tbl
        ,x_error_location => x_error_location
        ,x_qualifiers_tbl => l_qualifiers_tbl_out);
      IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;
    END IF;
  END IF;

  -- budget
  IF p_budget_tbl.COUNT > 0 THEN
  FOR i IN p_budget_tbl.FIRST..p_budget_tbl.LAST LOOP
    l_act_budgets_rec.act_budget_used_by_id  := x_qp_list_header_id;
    l_act_budgets_rec.budget_source_id       := p_budget_tbl(i).budget_id;
    l_act_budgets_rec.request_amount         := p_budget_tbl(i).budget_amount;
    l_act_budgets_rec.budget_source_type     := 'FUND';
    l_act_budgets_rec.transfer_type          := 'REQUEST';
    l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
    l_act_budgets_rec.request_currency       := p_modifier_list_rec.transaction_currency_code;
    l_act_budgets_rec.approved_in_currency   := p_modifier_list_rec.transaction_currency_code;
    l_act_budgets_rec.activity_budget_id     := p_budget_tbl(i).act_budget_id;

    OPEN c_act_budget_obj_ver(l_act_budgets_rec.activity_budget_id);
    FETCH c_act_budget_obj_ver INTO l_act_budgets_rec.object_version_number;
    CLOSE c_act_budget_obj_ver;

    IF p_budget_tbl(i).operation = 'CREATE' THEN
      Ozf_Actbudgets_Pvt.create_act_budgets(
         p_api_version      =>  p_api_version
        ,p_init_msg_list    =>  p_init_msg_list
        ,p_commit           =>  p_commit
        ,p_validation_level =>  Fnd_Api.g_valid_level_full
        ,x_return_status    =>  x_return_status
        ,x_msg_count        =>  x_msg_count
        ,x_msg_data         =>  x_msg_data
        ,p_act_budgets_rec  =>  l_act_budgets_rec
        ,x_act_budget_id    =>  l_activity_budget_id);

      IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;
    ELSIF p_budget_tbl(i).operation = 'UPDATE' THEN
      Ozf_Actbudgets_Pvt.update_act_budgets(
         p_api_version      =>  p_api_version
        ,p_init_msg_list    =>  p_init_msg_list
        ,p_commit           =>  p_commit
        ,p_validation_level =>  Fnd_Api.g_valid_level_full
        ,x_return_status    =>  x_return_status
        ,x_msg_count        =>  x_msg_count
        ,x_msg_data         =>  x_msg_data
        ,p_act_budgets_rec  =>  l_act_budgets_rec);

      IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;
    ELSIF p_budget_tbl(i).operation = 'DELETE' THEN
      Ozf_Actbudgets_Pvt.delete_act_budgets(
         p_api_version      =>  p_api_version
        ,p_init_msg_list    =>  p_init_msg_list
        ,p_commit           =>  p_commit
        ,p_validation_level =>  Fnd_Api.g_valid_level_full
        ,x_return_status    =>  x_return_status
        ,x_msg_count        =>  x_msg_count
        ,x_msg_data         =>  x_msg_data
        ,p_act_budget_id    =>  l_act_budgets_rec.activity_budget_id
        ,p_object_version   =>  l_act_budgets_rec.object_version_number);

      IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;
    END IF;
  END LOOP;
  END IF;
/*
  Ozf_Offer_Pvt.process_modifiers(
     p_init_msg_list     => p_init_msg_list
    ,p_api_version       => p_api_version
    ,p_commit            => p_commit
    ,x_return_status     => x_return_status
    ,x_msg_count         => x_msg_count
    ,x_msg_data          => x_msg_data
    ,p_offer_type        => p_offer_type
    ,p_modifier_list_rec => l_modifier_list_rec
    ,p_modifier_line_tbl => l_modifier_line_tbl
    ,x_qp_list_header_id => l_dummy
    ,x_error_location    => x_error_location);

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;
*/
EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO process_modifiers_pub;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO process_modifiers_pub;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO process_modifiers_pub;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END process_modifiers;


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
)
IS
  CURSOR c_act_budget_obj_ver(l_act_budg_id NUMBER) IS
  SELECT object_version_number
  FROM   ozf_act_budgets
  WHERE  activity_budget_id = l_act_budg_id;

  CURSOR c_offer_info(l_qp_list_header_id NUMBER) IS
  SELECT offer_id, offer_type, custom_setup_id, offer_code, object_version_number
  FROM   ozf_offers
  WHERE  qp_list_header_id = l_qp_list_header_id;

  l_api_version        CONSTANT NUMBER       := 1.0;
  l_api_name           CONSTANT VARCHAR2(30) := 'process_vo';

  l_modifier_list_rec  ozf_offer_pvt.modifier_list_rec_type;
  l_modifier_line_tbl  ozf_offer_pvt.modifier_line_tbl_type;
  l_qualifier_rec      ozf_offer_pvt.qualifiers_rec_type;
  l_act_budgets_rec    ozf_actbudgets_pvt.act_budgets_rec_type;
  l_vo_pbh_rec         ozf_volume_offer_disc_pvt.vo_disc_rec_type;
  l_vo_dis_rec         ozf_volume_offer_disc_pvt.vo_disc_rec_type;
  l_vo_prod_rec        ozf_volume_offer_disc_pvt.vo_prod_rec_type;
  l_vo_mo_rec          ozf_offer_market_options_pvt.vo_mo_rec_type;

  l_activity_budget_id NUMBER;
  l_vo_pbh_line_id     NUMBER;
  l_vo_dis_line_id     NUMBER;
  l_vo_prod_id         NUMBER;
  l_vo_mo_id           NUMBER;
  l_dummy              NUMBER;

BEGIN
  SAVEPOINT process_vo;
  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  IF NOT Fnd_Api.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;
  x_error_location := 0;

  l_modifier_list_rec.offer_id                      := p_modifier_list_rec.offer_id;
  l_modifier_list_rec.qp_list_header_id             := p_modifier_list_rec.qp_list_header_id;
  l_modifier_list_rec.offer_type                    := p_modifier_list_rec.offer_type;
  l_modifier_list_rec.offer_code                    := p_modifier_list_rec.offer_code;
  l_modifier_list_rec.activity_media_id             := p_modifier_list_rec.activity_media_id;
  l_modifier_list_rec.reusable                      := p_modifier_list_rec.reusable;
  l_modifier_list_rec.user_status_id                := p_modifier_list_rec.user_status_id;
  l_modifier_list_rec.customer_reference            := p_modifier_list_rec.customer_reference;
  l_modifier_list_rec.buying_group_contact_id       := p_modifier_list_rec.buying_group_contact_id;
  l_modifier_list_rec.object_version_number         := p_modifier_list_rec.object_version_number;
  l_modifier_list_rec.perf_date_from                := p_modifier_list_rec.perf_date_from;
  l_modifier_list_rec.perf_date_to                  := p_modifier_list_rec.perf_date_to;
  l_modifier_list_rec.status_code                   := p_modifier_list_rec.status_code;
  l_modifier_list_rec.modifier_level_code           := p_modifier_list_rec.modifier_level_code;
  l_modifier_list_rec.custom_setup_id               := p_modifier_list_rec.custom_setup_id;
  l_modifier_list_rec.offer_amount                  := p_modifier_list_rec.offer_amount;
  l_modifier_list_rec.budget_amount_tc              := p_modifier_list_rec.budget_amount_tc;
  l_modifier_list_rec.budget_amount_fc              := p_modifier_list_rec.budget_amount_fc;
  l_modifier_list_rec.transaction_currency_code     := p_modifier_list_rec.transaction_currency_code;
  l_modifier_list_rec.functional_currency_code      := p_modifier_list_rec.functional_currency_code;
  l_modifier_list_rec.context                       := p_modifier_list_rec.context;
  l_modifier_list_rec.attribute1                    := p_modifier_list_rec.attribute1;
  l_modifier_list_rec.attribute2                    := p_modifier_list_rec.attribute2;
  l_modifier_list_rec.attribute3                    := p_modifier_list_rec.attribute3;
  l_modifier_list_rec.attribute4                    := p_modifier_list_rec.attribute4;
  l_modifier_list_rec.attribute5                    := p_modifier_list_rec.attribute5;
  l_modifier_list_rec.attribute6                    := p_modifier_list_rec.attribute6;
  l_modifier_list_rec.attribute7                    := p_modifier_list_rec.attribute7;
  l_modifier_list_rec.attribute8                    := p_modifier_list_rec.attribute8;
  l_modifier_list_rec.attribute9                    := p_modifier_list_rec.attribute9;
  l_modifier_list_rec.attribute10                   := p_modifier_list_rec.attribute10;
  l_modifier_list_rec.attribute11                   := p_modifier_list_rec.attribute11;
  l_modifier_list_rec.attribute12                   := p_modifier_list_rec.attribute12;
  l_modifier_list_rec.attribute13                   := p_modifier_list_rec.attribute13;
  l_modifier_list_rec.attribute14                   := p_modifier_list_rec.attribute14;
  l_modifier_list_rec.attribute15                   := p_modifier_list_rec.attribute15;
  l_modifier_list_rec.currency_code                 := p_modifier_list_rec.currency_code;
  l_modifier_list_rec.start_date_active             := p_modifier_list_rec.start_date_active;
  l_modifier_list_rec.end_date_active               := p_modifier_list_rec.end_date_active;
  l_modifier_list_rec.list_type_code                := p_modifier_list_rec.list_type_code;
  l_modifier_list_rec.discount_lines_flag           := p_modifier_list_rec.discount_lines_flag;
  l_modifier_list_rec.name                          := p_modifier_list_rec.name;
  l_modifier_list_rec.description                   := p_modifier_list_rec.description;
  l_modifier_list_rec.comments                      := p_modifier_list_rec.comments;
  l_modifier_list_rec.ask_for_flag                  := p_modifier_list_rec.ask_for_flag;
  l_modifier_list_rec.start_date_active_first       := p_modifier_list_rec.start_date_active_first;
  l_modifier_list_rec.end_date_active_first         := p_modifier_list_rec.end_date_active_first;
  l_modifier_list_rec.active_date_first_type        := p_modifier_list_rec.active_date_first_type;
  l_modifier_list_rec.start_date_active_second      := p_modifier_list_rec.start_date_active_second;
  l_modifier_list_rec.end_date_active_second        := p_modifier_list_rec.end_date_active_second;
  l_modifier_list_rec.active_date_second_type       := p_modifier_list_rec.active_date_second_type;
  l_modifier_list_rec.active_flag                   := p_modifier_list_rec.active_flag;
  l_modifier_list_rec.max_no_of_uses                := p_modifier_list_rec.max_no_of_uses;
  l_modifier_list_rec.budget_source_id              := p_modifier_list_rec.budget_source_id;
  l_modifier_list_rec.budget_source_type            := p_modifier_list_rec.budget_source_type;
  l_modifier_list_rec.offer_used_by_id              := p_modifier_list_rec.offer_used_by_id;
  l_modifier_list_rec.offer_used_by                 := p_modifier_list_rec.offer_used_by;
  l_modifier_list_rec.ql_qualifier_type             := p_modifier_list_rec.ql_qualifier_type;
  l_modifier_list_rec.ql_qualifier_id               := p_modifier_list_rec.ql_qualifier_id;
  l_modifier_list_rec.amount_limit_id               := p_modifier_list_rec.amount_limit_id;
  l_modifier_list_rec.uses_limit_id                 := p_modifier_list_rec.uses_limit_id;
  l_modifier_list_rec.offer_operation               := p_modifier_list_rec.offer_operation;
  l_modifier_list_rec.modifier_operation            := p_modifier_list_rec.modifier_operation;
  l_modifier_list_rec.budget_offer_yn               := p_modifier_list_rec.budget_offer_yn;
  l_modifier_list_rec.break_type                    := p_modifier_list_rec.break_type;
  l_modifier_list_rec.volume_offer_type             := p_modifier_list_rec.volume_offer_type;
  l_modifier_list_rec.confidential_flag             := p_modifier_list_rec.confidential_flag;
  l_modifier_list_rec.committed_amount_eq_max       := p_modifier_list_rec.committed_amount_eq_max;
  l_modifier_list_rec.source_from_parent            := p_modifier_list_rec.source_from_parent;
  l_modifier_list_rec.buyer_name                    := p_modifier_list_rec.buyer_name;
  l_modifier_list_rec.sales_method_flag             := p_modifier_list_rec.sales_method_flag;
  l_modifier_list_rec.global_flag                   := p_modifier_list_rec.global_flag;
  l_modifier_list_rec.orig_org_id                   := p_modifier_list_rec.orig_org_id;

  IF p_modifier_list_rec.offer_operation = 'CREATE' THEN
    l_modifier_list_rec.offer_operation := 'CREATE';
    l_modifier_list_rec.modifier_operation := 'CREATE';
    l_modifier_list_rec.status_code := 'DRAFT';
    l_modifier_list_rec.user_status_id := ozf_utility_pvt.get_default_user_status('OZF_OFFER_STATUS','DRAFT');--1600;

    IF p_modifier_list_rec.OWNER_ID IS NULL OR p_modifier_list_rec.OWNER_ID = fnd_api.g_miss_num THEN
      l_modifier_list_rec.OWNER_ID                      := ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id);
    ELSE
      l_modifier_list_rec.OWNER_ID                      := p_modifier_list_rec.OWNER_ID;
    END IF;

    Ozf_Offer_Pvt.process_modifiers(
       p_init_msg_list     => p_init_msg_list
      ,p_api_version       => p_api_version
      ,p_commit            => p_commit
      ,x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_offer_type        => 'VOLUME_OFFER'
      ,p_modifier_list_rec => l_modifier_list_rec
      ,p_modifier_line_tbl => l_modifier_line_tbl -- need to create header first. use empty line.
      ,x_qp_list_header_id => x_qp_list_header_id
      ,x_error_location    => x_error_location);

    IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
    ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;

    l_modifier_list_rec.offer_operation := 'UPDATE';
    l_modifier_list_rec.modifier_operation := 'UPDATE';
    l_modifier_list_rec.qp_list_header_id := x_qp_list_header_id;
    l_modifier_list_rec.user_status_id := p_modifier_list_rec.user_status_id;
    l_modifier_list_rec.status_code := p_modifier_list_rec.status_code;
  ELSE
    x_qp_list_header_id := p_modifier_list_rec.qp_list_header_id;
    IF p_modifier_list_rec.OWNER_ID IS NULL THEN
      l_modifier_list_rec.OWNER_ID                      := fnd_api.g_miss_num;
    ELSE
      l_modifier_list_rec.OWNER_ID                      := p_modifier_list_rec.OWNER_ID;
    END IF;
  END IF;

  OPEN c_offer_info(x_qp_list_header_id);
  FETCH c_offer_info INTO l_modifier_list_rec.offer_id, l_modifier_list_rec.offer_type, l_modifier_list_rec.custom_setup_id, l_modifier_list_rec.offer_code, l_modifier_list_rec.object_version_number;
  CLOSE c_offer_info;

  IF p_qualifier_tbl.COUNT > 0 THEN
    FOR i IN p_qualifier_tbl.FIRST..p_qualifier_tbl.LAST LOOP
      l_qualifier_rec.list_header_id             := x_qp_list_header_id;
      l_qualifier_rec.qualifier_context          := p_qualifier_tbl(i).qualifier_context;
      l_qualifier_rec.qualifier_attribute        := p_qualifier_tbl(i).qualifier_attribute;
      l_qualifier_rec.qualifier_attr_value       := p_qualifier_tbl(i).qualifier_attr_value;
      l_qualifier_rec.qualifier_attr_value_to    := p_qualifier_tbl(i).qualifier_attr_value_to;
      l_qualifier_rec.comparison_operator_code   := p_qualifier_tbl(i).comparison_operator_code;
      l_qualifier_rec.qualifier_grouping_no      := p_qualifier_tbl(i).qualifier_grouping_no;
      l_qualifier_rec.list_line_id               := p_qualifier_tbl(i).list_line_id;
      l_qualifier_rec.qualifier_id               := p_qualifier_tbl(i).qualifier_id;
      l_qualifier_rec.start_date_active          := p_qualifier_tbl(i).start_date_active;
      l_qualifier_rec.end_date_active            := p_qualifier_tbl(i).end_date_active;
      l_qualifier_rec.activity_market_segment_id := p_qualifier_tbl(i).activity_market_segment_id;
      l_qualifier_rec.context                    := p_qualifier_tbl(i).context;
      l_qualifier_rec.attribute1                 := p_qualifier_tbl(i).attribute1;
      l_qualifier_rec.attribute2                 := p_qualifier_tbl(i).attribute2;
      l_qualifier_rec.attribute3                 := p_qualifier_tbl(i).attribute3;
      l_qualifier_rec.attribute4                 := p_qualifier_tbl(i).attribute4;
      l_qualifier_rec.attribute5                 := p_qualifier_tbl(i).attribute5;
      l_qualifier_rec.attribute6                 := p_qualifier_tbl(i).attribute6;
      l_qualifier_rec.attribute7                 := p_qualifier_tbl(i).attribute7;
      l_qualifier_rec.attribute8                 := p_qualifier_tbl(i).attribute8;
      l_qualifier_rec.attribute9                 := p_qualifier_tbl(i).attribute9;
      l_qualifier_rec.attribute10                := p_qualifier_tbl(i).attribute10;
      l_qualifier_rec.attribute11                := p_qualifier_tbl(i).attribute11;
      l_qualifier_rec.attribute12                := p_qualifier_tbl(i).attribute12;
      l_qualifier_rec.attribute13                := p_qualifier_tbl(i).attribute13;
      l_qualifier_rec.attribute14                := p_qualifier_tbl(i).attribute14;
      l_qualifier_rec.attribute15                := p_qualifier_tbl(i).attribute15;

      IF p_qualifier_tbl(i).operation = 'CREATE' THEN
        ozf_volume_offer_qual_pvt.create_vo_qualifier(
           p_api_version_number => p_api_version
          ,p_init_msg_list      => p_init_msg_list
          ,p_commit             => p_commit
          ,p_validation_level   => Fnd_Api.g_valid_level_full
          ,x_return_status      => x_return_status
          ,x_msg_count          => x_msg_count
          ,x_msg_data           => x_msg_data
          ,p_qualifiers_rec     => l_qualifier_rec);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_qualifier_tbl(i).operation = 'UPDATE' THEN
        ozf_volume_offer_qual_pvt.update_vo_qualifier(
           p_api_version_number => p_api_version
          ,p_init_msg_list      => p_init_msg_list
          ,p_commit             => p_commit
          ,p_validation_level   => Fnd_Api.g_valid_level_full
          ,x_return_status      => x_return_status
          ,x_msg_count          => x_msg_count
          ,x_msg_data           => x_msg_data
          ,p_qualifiers_rec     => l_qualifier_rec);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_qualifier_tbl(i).operation = 'DELETE' THEN
        ozf_volume_offer_qual_pvt.delete_vo_qualifier(
           p_api_version_number => p_api_version
          ,p_init_msg_list      => p_init_msg_list
          ,p_commit             => p_commit
          ,p_validation_level   => Fnd_Api.g_valid_level_full
          ,x_return_status      => x_return_status
          ,x_msg_count          => x_msg_count
          ,x_msg_data           => x_msg_data
          ,p_qualifier_id       => l_qualifier_rec.qualifier_id);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      END IF;
    END LOOP;

/*    Ozf_Offer_Pvt.process_market_qualifiers(
         p_init_msg_list  => p_init_msg_list
        ,p_api_version    => p_api_version
        ,p_commit         => p_commit
        ,x_return_status  => x_return_status
        ,x_msg_count      => x_msg_count
        ,x_msg_data       => x_msg_data
        ,p_qualifiers_tbl => l_qualifiers_tbl
        ,x_error_location => x_error_location
        ,x_qualifiers_tbl => l_qualifiers_tbl_out);

    IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
    ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;*/
  END IF;

  IF p_budget_tbl.COUNT > 0 THEN
    FOR i IN p_budget_tbl.FIRST..p_budget_tbl.LAST LOOP
      l_act_budgets_rec.act_budget_used_by_id  := x_qp_list_header_id;
      l_act_budgets_rec.budget_source_id       := p_budget_tbl(i).budget_id;
      l_act_budgets_rec.request_amount         := p_budget_tbl(i).budget_amount;
      l_act_budgets_rec.budget_source_type     := 'FUND';
      l_act_budgets_rec.transfer_type          := 'REQUEST';
      l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
      l_act_budgets_rec.request_currency       := p_modifier_list_rec.transaction_currency_code;
      l_act_budgets_rec.approved_in_currency   := p_modifier_list_rec.transaction_currency_code;
      l_act_budgets_rec.activity_budget_id     := p_budget_tbl(i).act_budget_id;

      OPEN c_act_budget_obj_ver(l_act_budgets_rec.activity_budget_id);
      FETCH c_act_budget_obj_ver INTO l_act_budgets_rec.object_version_number;
      CLOSE c_act_budget_obj_ver;

      IF p_budget_tbl(i).operation = 'CREATE' THEN
        Ozf_Actbudgets_Pvt.create_act_budgets(
           p_api_version      => p_api_version
          ,p_init_msg_list    => p_init_msg_list
          ,p_commit           => p_commit
          ,p_validation_level => Fnd_Api.g_valid_level_full
          ,x_return_status    => x_return_status
          ,x_msg_count        => x_msg_count
          ,x_msg_data         => x_msg_data
          ,p_act_budgets_rec  => l_act_budgets_rec
          ,x_act_budget_id    => l_activity_budget_id);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_budget_tbl(i).operation = 'UPDATE' THEN
        Ozf_Actbudgets_Pvt.update_act_budgets(
           p_api_version      => p_api_version
          ,p_init_msg_list    => p_init_msg_list
          ,p_commit           => p_commit
          ,p_validation_level => Fnd_Api.g_valid_level_full
          ,x_return_status    => x_return_status
          ,x_msg_count        => x_msg_count
          ,x_msg_data         => x_msg_data
          ,p_act_budgets_rec  => l_act_budgets_rec);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_budget_tbl(i).operation = 'DELETE' THEN
        Ozf_Actbudgets_Pvt.delete_act_budgets(
           p_api_version      => p_api_version
          ,p_init_msg_list    => p_init_msg_list
          ,p_commit           => p_commit
          ,p_validation_level => Fnd_Api.g_valid_level_full
          ,x_return_status    => x_return_status
          ,x_msg_count        => x_msg_count
          ,x_msg_data         => x_msg_data
          ,p_act_budget_id    => l_act_budgets_rec.activity_budget_id
          ,p_object_version   => l_act_budgets_rec.object_version_number);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      END IF;
    END LOOP;
  END IF;

  -- PBH lines
  IF p_vo_pbh_tbl.COUNT > 0 THEN
    FOR i IN p_vo_pbh_tbl.FIRST..p_vo_pbh_tbl.LAST LOOP
      l_vo_pbh_rec.offer_discount_line_id   := p_vo_pbh_tbl(i).offer_discount_line_id;
      l_vo_pbh_rec.volume_type              := p_vo_pbh_tbl(i).volume_type;
      l_vo_pbh_rec.volume_break_type        := p_vo_pbh_tbl(i).volume_break_type;
      l_vo_pbh_rec.discount_type            := p_vo_pbh_tbl(i).discount_type;
      l_vo_pbh_rec.tier_type                := p_vo_pbh_tbl(i).tier_type; -- 'PBH'
      l_vo_pbh_rec.tier_level               := p_vo_pbh_tbl(i).tier_level; --'HEADER'
      l_vo_pbh_rec.uom_code                 := p_vo_pbh_tbl(i).uom_code;
      l_vo_pbh_rec.object_version_number    := p_vo_pbh_tbl(i).object_version_number;
      l_vo_pbh_rec.offer_id                 := l_modifier_list_rec.offer_id;
      l_vo_pbh_rec.discount_by_code         := p_vo_pbh_tbl(i).discount_by_code;
      l_vo_pbh_rec.offr_disc_struct_name_id := p_vo_pbh_tbl(i).offr_disc_struct_name_id;
      l_vo_pbh_rec.name                     := p_vo_pbh_tbl(i).name;
      l_vo_pbh_rec.description              := p_vo_pbh_tbl(i).description;

      IF p_vo_pbh_tbl(i).operation = 'CREATE' THEN
        ozf_volume_offer_disc_pvt.create_vo_discount(
           p_api_version_number  => p_api_version
          ,p_init_msg_list       => p_init_msg_list
          ,p_commit              => p_commit
          ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
          ,p_vo_disc_rec         => l_vo_pbh_rec
          ,x_vo_discount_line_id => l_vo_pbh_line_id);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_vo_pbh_tbl(i).operation = 'UPDATE' THEN
        ozf_volume_offer_disc_pvt.update_vo_discount(
           p_api_version_number  => p_api_version
          ,p_init_msg_list       => p_init_msg_list
          ,p_commit              => p_commit
          ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
          ,p_vo_disc_rec         => l_vo_pbh_rec);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_vo_pbh_tbl(i).operation = 'DELETE' THEN
        ozf_volume_offer_disc_pvt.delete_vo_discount(
           p_api_version_number     => p_api_version
          ,p_init_msg_list          => p_init_msg_list
          ,p_commit                 => p_commit
          ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
          ,x_return_status          => x_return_status
          ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data
          ,p_offer_discount_line_id => l_vo_pbh_rec.offer_discount_line_id
          ,p_object_version_number  => l_vo_pbh_rec.object_version_number);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      END IF; -- end PBH operation switching

      -- DIS lines
      IF p_vo_dis_tbl.COUNT > 0 THEN
        FOR j IN p_vo_dis_tbl.FIRST..p_vo_dis_tbl.LAST LOOP
          IF p_vo_dis_tbl(j).pbh_index = p_vo_pbh_tbl(i).pbh_index THEN
            l_vo_dis_rec.offer_discount_line_id  := p_vo_dis_tbl(j).offer_discount_line_id;
            l_vo_dis_rec.parent_discount_line_id := l_vo_pbh_line_id;
            l_vo_dis_rec.volume_from             := p_vo_dis_tbl(j).volume_from;
            l_vo_dis_rec.volume_to               := p_vo_dis_tbl(j).volume_to;
            l_vo_dis_rec.volume_operator         := p_vo_dis_tbl(j).volume_operator; -- 'BETWEEN'
            l_vo_dis_rec.discount                := p_vo_dis_tbl(j).discount;
            l_vo_dis_rec.tier_type               := p_vo_dis_tbl(j).tier_type; -- 'DIS'
            l_vo_dis_rec.tier_level              := p_vo_dis_tbl(j).tier_level; -- 'HEADER'
            l_vo_dis_rec.object_version_number   := p_vo_dis_tbl(j).object_version_number;
            l_vo_dis_rec.offer_id                := l_modifier_list_rec.offer_id;
            l_vo_dis_rec.discount_by_code        := p_vo_dis_tbl(j).discount_by_code;
            l_vo_dis_rec.formula_id              := p_vo_dis_tbl(j).formula_id;
            --added for bug 8721678
            l_vo_dis_rec.volume_break_type       := p_vo_dis_tbl(j).volume_break_type;

            IF p_vo_dis_tbl(j).operation = 'CREATE' THEN
              ozf_volume_offer_disc_pvt.create_vo_discount(
                 p_api_version_number  => p_api_version
                ,p_init_msg_list       => p_init_msg_list
                ,p_commit              => p_commit
                ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
                ,x_return_status       => x_return_status
                ,x_msg_count           => x_msg_count
                ,x_msg_data            => x_msg_data
                ,p_vo_disc_rec         => l_vo_dis_rec
                ,x_vo_discount_line_id => l_vo_dis_line_id);

              IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
                RAISE Fnd_Api.g_exc_error;
              ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                RAISE Fnd_Api.g_exc_unexpected_error;
              END IF;
            ELSIF p_vo_dis_tbl(j).operation = 'UPDATE' THEN
              ozf_volume_offer_disc_pvt.update_vo_discount(
                 p_api_version_number  => p_api_version
                ,p_init_msg_list       => p_init_msg_list
                ,p_commit              => p_commit
                ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
                ,x_return_status       => x_return_status
                ,x_msg_count           => x_msg_count
                ,x_msg_data            => x_msg_data
                ,p_vo_disc_rec         => l_vo_dis_rec);

              IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
                RAISE Fnd_Api.g_exc_error;
              ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                RAISE Fnd_Api.g_exc_unexpected_error;
              END IF;
            ELSIF p_vo_dis_tbl(j).operation = 'DELETE' THEN
              ozf_volume_offer_disc_pvt.delete_vo_discount(
                 p_api_version_number     => p_api_version
                ,p_init_msg_list          => p_init_msg_list
                ,p_commit                 => p_commit
                ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
                ,x_return_status          => x_return_status
                ,x_msg_count              => x_msg_count
                ,x_msg_data               => x_msg_data
                ,p_offer_discount_line_id => l_vo_dis_rec.offer_discount_line_id
                ,p_object_version_number  => l_vo_dis_rec.object_version_number);

              IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
                RAISE Fnd_Api.g_exc_error;
              ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                RAISE Fnd_Api.g_exc_unexpected_error;
              END IF;
            END IF; -- end DIS opeartion switching
          END IF; -- end pbh_index matching
        END LOOP;
      END IF; -- end DIS lines

      -- products
      IF p_vo_prod_tbl.COUNT > 0 THEN
        FOR k IN p_vo_prod_tbl.FIRST..p_vo_prod_tbl.LAST LOOP
          IF p_vo_prod_tbl(k).pbh_index = p_vo_pbh_tbl(i).pbh_index THEN
            l_vo_prod_rec.off_discount_product_id := p_vo_prod_tbl(k).off_discount_product_id;
            l_vo_prod_rec.excluder_flag           := p_vo_prod_tbl(k).excluder_flag;
            l_vo_prod_rec.offer_discount_line_id  := l_vo_pbh_line_id;
            l_vo_prod_rec.offer_id                := l_modifier_list_rec.offer_id;
            l_vo_prod_rec.object_version_number   := p_vo_prod_tbl(k).object_version_number;
            l_vo_prod_rec.product_context         := p_vo_prod_tbl(k).product_context;
            l_vo_prod_rec.product_attribute       := p_vo_prod_tbl(k).product_attribute;
            l_vo_prod_rec.product_attr_value      := p_vo_prod_tbl(k).product_attr_value;
            l_vo_prod_rec.apply_discount_flag     := p_vo_prod_tbl(k).apply_discount_flag;
            l_vo_prod_rec.include_volume_flag     := p_vo_prod_tbl(k).include_volume_flag;

            IF p_vo_prod_tbl(k).operation = 'CREATE' THEN
              ozf_volume_offer_disc_pvt.create_vo_product(
                 p_api_version_number      => p_api_version
                ,p_init_msg_list           => p_init_msg_list
                ,p_commit                  => p_commit
                ,p_validation_level        => FND_API.G_VALID_LEVEL_FULL
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data
                ,p_vo_prod_rec             => l_vo_prod_rec
                ,x_off_discount_product_id => l_vo_prod_id);

              IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
                RAISE Fnd_Api.g_exc_error;
              ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                RAISE Fnd_Api.g_exc_unexpected_error;
              END IF;
            ELSIF p_vo_prod_tbl(k).operation = 'UPDATE' THEN
              ozf_volume_offer_disc_pvt.update_vo_product(
                 p_api_version_number      => p_api_version
                ,p_init_msg_list           => p_init_msg_list
                ,p_commit                  => p_commit
                ,p_validation_level        => FND_API.G_VALID_LEVEL_FULL
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data
                ,p_vo_prod_rec             => l_vo_prod_rec);

              IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
                RAISE Fnd_Api.g_exc_error;
              ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                RAISE Fnd_Api.g_exc_unexpected_error;
              END IF;
            ELSIF p_vo_prod_tbl(k).operation = 'DELETE' THEN
              ozf_volume_offer_disc_pvt.delete_vo_product(
                 p_api_version_number      => p_api_version
                ,p_init_msg_list           => p_init_msg_list
                ,p_commit                  => p_commit
                ,p_validation_level        => FND_API.G_VALID_LEVEL_FULL
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data
                ,p_off_discount_product_id => l_vo_prod_rec.off_discount_product_id
                ,p_object_version_number   => l_vo_prod_rec.object_version_number);

              IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
                RAISE Fnd_Api.g_exc_error;
              ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                RAISE Fnd_Api.g_exc_unexpected_error;
              END IF;
            END IF; -- end product operation switching
          END IF; -- end pbh_idex matching
        END LOOP;
      END IF; -- end products
    END LOOP;
  END IF; -- end PBH lines

  -- market options
  IF p_vo_mo_tbl.COUNT > 0 THEN
    FOR i IN p_vo_mo_tbl.FIRST..p_vo_mo_tbl.LAST LOOP
      l_vo_mo_rec.offer_market_option_id     := p_vo_mo_tbl(i).offer_market_option_id;
      l_vo_mo_rec.offer_id                   := l_modifier_list_rec.offer_id;
      l_vo_mo_rec.qp_list_header_id          := x_qp_list_header_id;
      l_vo_mo_rec.group_number               := p_vo_mo_tbl(i).group_number;
      l_vo_mo_rec.retroactive_flag           := p_vo_mo_tbl(i).retroactive_flag;
      l_vo_mo_rec.beneficiary_party_id       := p_vo_mo_tbl(i).beneficiary_party_id;
      l_vo_mo_rec.combine_schedule_flag      := p_vo_mo_tbl(i).combine_schedule_flag;
      l_vo_mo_rec.volume_tracking_level_code := p_vo_mo_tbl(i).volume_tracking_level_code;
      l_vo_mo_rec.accrue_to_code             := p_vo_mo_tbl(i).accrue_to_code;
      l_vo_mo_rec.precedence                 := p_vo_mo_tbl(i).precedence;
      l_vo_mo_rec.object_version_number      := p_vo_mo_tbl(i).object_version_number;
      l_vo_mo_rec.security_group_id          := p_vo_mo_tbl(i).security_group_id;

      IF p_vo_mo_tbl(i).operation = 'CREATE' THEN
        ozf_offer_market_options_pvt.create_market_options(
           p_api_version_number  => p_api_version
          ,p_init_msg_list       => p_init_msg_list
          ,p_commit              => p_commit
          ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
          ,p_mo_rec              => l_vo_mo_rec
          ,x_vo_market_option_id => l_vo_mo_id);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_vo_mo_tbl(i).operation = 'UPDATE' THEN
        ozf_offer_market_options_pvt.update_market_options(
           p_api_version_number  => p_api_version
          ,p_init_msg_list       => p_init_msg_list
          ,p_commit              => p_commit
          ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
          ,p_mo_rec              => l_vo_mo_rec);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      ELSIF p_vo_mo_tbl(i).operation = 'DELETE' THEN
        ozf_offer_market_options_pvt.delete_market_options(
           p_api_version_number     => p_api_version
          ,p_init_msg_list          => p_init_msg_list
          ,p_commit                 => p_commit
          ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
          ,x_return_status          => x_return_status
          ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data
          ,p_offer_market_option_id => l_vo_mo_rec.offer_market_option_id
          ,p_object_version_number  => l_vo_mo_rec.object_version_number);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
      END IF;
    END LOOP;
  END IF; -- end market options

  Ozf_Offer_Pvt.process_modifiers(
     p_init_msg_list     => p_init_msg_list
    ,p_api_version       => p_api_version
    ,p_commit            => p_commit
    ,x_return_status     => x_return_status
    ,x_msg_count         => x_msg_count
    ,x_msg_data          => x_msg_data
    ,p_offer_type        => 'VOLUME_OFFER'
    ,p_modifier_list_rec => l_modifier_list_rec
    ,p_modifier_line_tbl => l_modifier_line_tbl
    ,x_qp_list_header_id => l_dummy
    ,x_error_location    => x_error_location);

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO process_vo;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
        ( p_count      =>      x_msg_count,
          p_data       =>      x_msg_data,
          p_encoded    =>      Fnd_Api.G_FALSE
         );
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      ROLLBACK TO process_vo;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
        ( p_count      =>      x_msg_count,
          p_data       =>      x_msg_data,
          p_encoded    =>      Fnd_Api.G_FALSE
         );
    WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
      ROLLBACK TO process_vo;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
        ( p_count      =>      x_msg_count,
          p_data       =>      x_msg_data,
          p_encoded    =>      Fnd_Api.G_FALSE
        );

END process_vo;

END OZF_Offer_PUB;

/
