--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJ_PRODUCTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJ_PRODUCTS_PVT" AS
/* $Header: ozfvoadpb.pls 120.9 2006/05/22 19:05:45 rssharma noship $ */
/**
  Tue Aug 02 2005:10/26 PM RSSHARMA Created
  Mon Oct 03 2005:6/44 PM RSSHARMA Added duplicate check for Volume Offer Adjustment Products
  Mon May 15 2006:5/6 PM Fixed bug # 5131158. Added check entity method.If the Adjustment is backdated, it raises error message
  saying, products cannot be added to a backdated volume offer adjustment
  Mon May 22 2006:12/1 PM RSSHARMA Fixed debug to print only on debug high
*/
g_pkg_name CONSTANT VARCHAR2(30) := 'OZF_OFFER_ADJ_PRODUCTS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(30) := 'ozfvoadpb.pls';

PROCEDURE check_adj_prod_req_items
(
p_adj_prod IN offer_adj_prod_rec
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_validation_mode = JTF_PLSQL_API.g_create THEN
IF p_adj_prod.offer_adjustment_id IS NULL OR p_adj_prod.offer_adjustment_id = FND_API.G_MISS_NUM THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','offer_adjustment_id');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
/*
IF p_adj_prod.product_context IS NULL OR p_adj_prod.product_context = FND_API.G_MISS_CHAR THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','product_context');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;

IF p_adj_prod.product_attribute IS NULL OR p_adj_prod.product_attribute = FND_API.G_MISS_CHAR THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','product_attribute');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
IF p_adj_prod.product_attr_value IS NULL OR p_adj_prod.product_attr_value = FND_API.G_MISS_CHAR THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','product_attr_value');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;*/
ELSE
IF p_adj_prod.offer_adjustment_id = FND_API.G_MISS_NUM THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','offer_adjustment_id');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
IF p_adj_prod.offer_adjustment_product_id  = FND_API.G_MISS_NUM THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','OFFER_ADJUSTMENT_PRODUCT_ID');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
IF p_adj_prod.object_version_number = FND_API.G_MISS_NUM THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','OBJECT_VERSION_NUMBER');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
END IF;
END check_adj_prod_req_items;

FUNCTION get_offer_type
(
p_offerAdjustmentId NUMBER
)
RETURN VARCHAR2
IS
CURSOR c_offerType(cp_offerAdjustmentId NUMBER) IS
SELECT a.offer_type FROM ozf_offers a, ozf_offer_adjustments_b b
WHERE a.qp_list_header_id = b.list_header_id
AND b.offer_adjustment_id = cp_offerAdjustmentId;
l_offerType VARCHAR2(30);
BEGIN
OPEN c_offerType(p_offerAdjustmentId);
    FETCH c_offerType into l_offerType;
IF c_offerType%NOTFOUND THEN
    l_offerType := NULL;
END IF;
RETURN l_offerType;
END get_offer_type;

PROCEDURE check_adj_prod_uk_items
(
p_adj_prod IN offer_adj_prod_rec
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
/*CURSOR c_prod(p_offer_adjustment_id NUMBER,p_product_context VARCHAR2, p_product_attribute VARCHAR2, p_product_attr_value VARCHAR2, p_excluder_flag VARCHAR2)
IS
SELECT 1 FROM dual WHERE EXISTS
(SELECT 'X' FROM ozf_offer_discount_products a, ozf_offer_adjustments_b b, ozf_offers c
WHERE
a.offer_id = c.offer_id
AND c.qp_list_header_id = b.list_header_id
AND b.offer_adjustment_id = p_offer_adjustment_id
AND product_context = p_product_context
AND product_attribute = p_product_attribute
AND p_product_attr_value = p_product_attr_value
AND excluder_flag = p_excluder_flag ;
*/
CURSOR c_offerId (cp_offerAdjustmentId NUMBER) IS
SELECT a.offer_id
FROM ozf_offers a, ozf_offer_adjustments_b b
WHERE a.qp_list_header_id = b.list_header_id
AND b.offer_adjustment_id = cp_offerAdjustmentId;

l_attr varchar2(500) := 'product_attribute = ''' || p_adj_prod.product_attribute ||''' AND product_attr_value = '''|| p_adj_prod.product_attr_value ;
l_attr2 varchar2(500):= ''' AND apply_discount_flag  = '''||p_adj_prod.apply_discount_flag  || ''' AND offer_id = ';
l_valid_flag VARCHAR2(10);
l_offerType VARCHAR2(30);
l_offerId NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_validation_mode = JTF_PLSQL_API.G_CREATE THEN
    IF p_adj_prod.offer_adjustment_product_id IS NOT NULL AND p_adj_prod.offer_adjustment_product_id <> FND_API.G_MISS_NUM THEN
        IF OZF_UTILITY_PVT.CHECK_UNIQUENESS('ozf_offer_adjustment_products','offer_adjustment_product_id = '|| p_adj_prod.offer_adjustment_product_id) = FND_API.G_FALSE THEN
                OZF_Utility_PVT.Error_Message('OZF_OFFR_ADJ_PROD_ID_DUP');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
    END IF;
END IF;
IF
(p_adj_prod.product_context IS NOT NULL AND p_adj_prod.product_context <> FND_API.G_MISS_CHAR)
AND
(p_adj_prod.product_attribute IS NOT NULL AND p_adj_prod.product_attribute <> FND_API.G_MISS_CHAR)
AND
(p_adj_prod.product_attr_value IS NOT NULL AND p_adj_prod.product_attr_value <> FND_API.G_MISS_CHAR)
AND
(p_adj_prod.excluder_flag IS NOT NULL AND p_adj_prod.excluder_flag <> FND_API.G_MISS_CHAR)
THEN
null;
END IF;
l_offerType := get_offer_type(p_adj_prod.offer_adjustment_id);
OZF_Offer_Adj_Line_PVT.debug_message('OfferType is :'||l_offerType);
IF l_offerType = 'VOLUME_OFFER' THEN
      OPEN c_offerId(p_adj_prod.offer_adjustment_id);
        FETCH c_offerId INTO l_offerId;
      CLOSE c_offerId;

      IF (p_adj_prod.product_attr_value IS NOT NULL AND p_adj_prod.product_attr_value <> FND_API.g_miss_char) THEN
                 l_valid_flag := OZF_Utility_PVT.check_uniqueness(
                 'ozf_offer_discount_products',
                 l_attr || l_attr2 || l_offerId
                 );
              IF  l_valid_flag = FND_API.g_false THEN
                     OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_VO_PROD_DUP');
                     x_return_status := FND_API.g_ret_sts_error;
                     return;
              END IF;

      END IF;
END IF;

END check_adj_prod_uk_items;

PROCEDURE check_adj_prod_fk_items
(
p_adj_prod IN offer_adj_prod_rec
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
 l_vo_prod_rec OZF_Volume_Offer_disc_PVT.vo_prod_rec_type;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_adj_prod.offer_adjustment_id IS NOT NULL AND p_adj_prod.offer_adjustment_id <> FND_API.G_MISS_NUM THEN
IF OZF_UTILITY_PVT.check_fk_exists('ozf_offer_adjustments_b','offer_adjustment_id',to_char(p_adj_prod.offer_adjustment_id)) = FND_API.G_FALSE THEN
        OZF_Utility_PVT.Error_Message('OZF_OFFR_ADJ_PROD_INV_ADJ_ID');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
END IF;
OZF_Offer_Adj_Line_PVT.debug_message('OfferDiscountLineid is: '||p_adj_prod.offer_discount_line_id);
IF p_adj_prod.offer_discount_line_id IS NOT NULL AND p_adj_prod.offer_discount_line_id <> FND_API.G_MISS_NUM THEN
IF OZF_UTILITY_PVT.check_fk_exists('OZF_OFFER_DISCOUNT_LINES', 'offer_discount_line_id', to_char(p_adj_prod.offer_discount_line_id)) =  FND_API.G_FALSE THEN
        OZF_Utility_PVT.Error_Message('OZF_OFFR_ADJ_PROD_INV_DISC_LINE');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
END IF;
OZF_Offer_Adj_Line_PVT.debug_message('OfferDiscountProductId is : '||p_adj_prod.off_discount_product_id);
IF p_adj_prod.off_discount_product_id IS NOT NULL AND p_adj_prod.off_discount_product_id <> FND_API.G_MISS_NUM THEN
IF ozf_utility_pvt.CHECK_FK_EXISTS('ozf_offer_discount_products','off_discount_product_id',to_char(p_adj_prod.off_discount_product_id)) = FND_API.G_FALSE THEN
        OZF_Utility_PVT.Error_Message('OZF_OFFR_ADJ_INV_PROD_LINE');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
END IF;
OZF_Offer_Adj_Line_PVT.debug_message('Calling Product Ctx validation');

IF
(p_adj_prod.product_context IS NOT NULL AND p_adj_prod.product_context <> FND_API.G_MISS_CHAR )
AND
(p_adj_prod.product_attribute IS NOT NULL AND p_adj_prod.product_attribute <> FND_API.G_MISS_CHAR)
AND
(p_adj_prod.product_attr_value IS NOT NULL AND p_adj_prod.product_attr_value <> FND_API.G_MISS_CHAR)
THEN
l_vo_prod_rec.product_context := p_adj_prod.product_context;
l_vo_prod_rec.product_attribute := p_adj_prod.product_attribute;
l_vo_prod_rec.product_attr_value := p_adj_prod.product_attr_value;
OZF_Offer_Adj_Line_PVT.debug_message('Calling Product Ctx validation');
OZF_Volume_Offer_disc_PVT.Check_vo_product_attr(
     p_vo_prod_rec              => l_vo_prod_rec
    , x_return_status           => x_return_status
      );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END IF;
END check_adj_prod_fk_items;

PROCEDURE check_adj_prod_lkup_items
(
p_adj_prod IN offer_adj_prod_rec
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
END check_adj_prod_lkup_items;

PROCEDURE check_adj_prod_attr
(
p_adj_prod IN offer_adj_prod_rec
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_adj_prod.excluder_flag IS NOT NULL AND p_adj_prod.excluder_flag <> fnd_api.g_miss_char THEN
IF p_adj_prod.excluder_flag <> 'Y' AND p_adj_prod.excluder_flag <> 'N' THEN
        OZF_Utility_PVT.Error_Message('OZF_OFFR_ADJ_PROD_INV_EXCL');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
END IF;
IF p_adj_prod.apply_discount_flag IS NOT NULL AND p_adj_prod.apply_discount_flag <> FND_API.G_MISS_CHAR THEN
IF p_adj_prod.apply_discount_flag <> 'Y' and p_adj_prod.apply_discount_flag <> 'N' THEN
        OZF_Utility_PVT.Error_Message('OZF_OFFR_ADJ_PROD_INV_APP_DISC');
        x_return_status := FND_API.g_ret_sts_error;
        return;

END IF;
END IF;


IF p_adj_prod.include_volume_flag IS NOT NULL AND p_adj_prod.include_volume_flag <> FND_API.G_MISS_CHAR THEN
IF p_adj_prod.include_volume_flag <> 'Y' and p_adj_prod.include_volume_flag <> 'N' THEN
        OZF_Utility_PVT.Error_Message('OZF_OFFR_ADJ_PROD_INV_INCL_VOL');
        x_return_status := FND_API.g_ret_sts_error;
        return;

END IF;
END IF;
-- if new product is added then product_context, product_attribute, product_attr_value, apply_discount_flag , include_volume_flag are required
IF p_adj_prod.off_discount_product_id IS NULL OR p_adj_prod.off_discount_product_id = FND_API.G_MISS_NUM THEN -- if this is a new product
    IF p_validation_mode = JTF_PLSQL_API.G_CREATE THEN
        IF p_adj_prod.product_context IS NULL OR p_adj_prod.product_context = FND_API.G_MISS_CHAR THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','PRODUCT_CONTEXT');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
        IF p_adj_prod.product_attribute IS NULL OR p_adj_prod.product_attribute = FND_API.G_MISS_CHAR THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','PRODUCT_ATTRIBUTE');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
        IF p_adj_prod.product_attr_value IS NULL OR p_adj_prod.product_attr_value = FND_API.G_MISS_CHAR THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','PRODUCT_ATTR_VALUE');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
        IF p_adj_prod.apply_discount_flag IS NULL OR p_adj_prod.apply_discount_flag = FND_API.G_MISS_CHAR THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','APPLY_DISCOUNT_FLAG');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
        IF p_adj_prod.include_volume_flag IS NULL OR p_adj_prod.include_volume_flag = FND_API.G_MISS_CHAR THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','INCLUDE_VOLUME_FLAG');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
    ELSE
    IF p_adj_prod.product_context = FND_API.G_MISS_CHAR THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','product_context');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
    IF p_adj_prod.product_attribute = FND_API.G_MISS_CHAR THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','product_attribute');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
    IF p_adj_prod.product_attr_value = FND_API.G_MISS_CHAR THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','product_attr_value');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
    IF p_adj_prod.apply_discount_flag = FND_API.G_MISS_CHAR THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','apply_discount_flag');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
    IF p_adj_prod.include_volume_flag = FND_API.G_MISS_CHAR THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','include_volume_flag');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
    END IF;

END IF;
END check_adj_prod_attr;


PROCEDURE check_adj_prod_inter_attr
(
p_adj_prod IN offer_adj_prod_rec
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
CURSOR C(p_offer_discount_line_id NUMBER, p_off_discount_product_id NUMBER) is
SELECT 1 FROM DUAL WHERE EXISTS (SELECT 'X'
                                FROM ozf_offer_discount_lines a
                                , ozf_offer_discount_products b
                                , ozf_offer_adjustments_b c
                                , ozf_offers d
                                WHERE a.offer_discount_line_id = b.offer_discount_line_id
                                AND a.offer_id = d.offer_id
                                AND d.qp_list_header_id = c.list_header_id
                                AND a.offer_discount_line_id = p_offer_discount_line_id
                                AND b.off_discount_product_id = p_off_discount_product_id);
--AND d.qp_list_header_id = c.list_header_id
--AND a.offer_id = d.offer_id);
l_dummy NUMBER;

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF (p_adj_prod.offer_discount_line_id IS NOT NULL AND p_adj_prod.offer_discount_line_id <> fnd_api.g_miss_num)
AND
(p_adj_prod.off_discount_product_id  IS NOT NULL AND p_adj_prod.off_discount_product_id <> FND_API.G_MISS_NUM )
THEN
OPEN c(P_ADJ_prod.offer_discount_line_id, p_adj_prod.off_discount_product_id);
FETCH c INTO l_dummy;
IF (C%NOTFOUND) THEN
CLOSE C;
        OZF_Utility_PVT.Error_Message('OZF_ADJ_PROD_INV_DISC_PROD');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
END IF;
-- a user can associate a product only to a pbh line
IF p_adj_prod.offer_discount_line_id IS NOT NULL AND p_adj_prod.offer_discount_line_id <> FND_API.G_MISS_NUM THEN
IF OZF_UTILITY_PVT.check_fk_exists('OZF_OFFER_DISCOUNT_LINES'
                                    ,'OFFER_DISCOUNT_LINE_ID'
                                    , to_char(p_adj_prod.offer_discount_line_id)
                                    , OZF_UTILITY_PVT.g_number
                                    , ' TIER_TYPE = ''PBH'''
                                   )  = FND_API.G_FALSE THEN
        OZF_Utility_PVT.Error_Message('OZF_INV_DISC_LINE_TYPE');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
END IF;
END check_adj_prod_inter_attr;

PROCEDURE check_adj_prod_entity
(
p_adj_prod IN offer_adj_prod_rec
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
CURSOR c_effectiveDate(cp_offerAdjustmentId NUMBER) IS
SELECT effective_date
FROM ozf_offer_adjustments_b
WHERE offer_adjustment_id = cp_offerAdjustmentId;
l_effectiveDate DATE;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
OPEN c_effectiveDate(cp_offerAdjustmentId => p_adj_prod.offer_adjustment_id) ;
FETCH c_effectiveDate INTO l_effectiveDate;
IF c_effectiveDate%NOTFOUND THEN
    l_effectiveDate := sysdate + 1;
END IF;
CLOSE c_effectiveDate;
OZF_Offer_Adj_Line_PVT.debug_message('Checking backdated');
IF l_effectiveDate > SYSDATE THEN
OZF_Offer_Adj_Line_PVT.debug_message('Not backdated');
null;
ELSE
OZF_Offer_Adj_Line_PVT.debug_message('backdated');
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_VO_ADJ_BACKDATE_NO_PROD');
          x_return_status := FND_API.G_RET_STS_ERROR;
          return;
END IF;
END check_adj_prod_entity;

PROCEDURE check_adj_products
(
    p_adj_prod                   IN offer_adj_prod_rec
    ,p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.G_CREATE
    , x_return_status             OUT NOCOPY VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
check_adj_prod_req_items
(
p_adj_prod => p_adj_prod
, p_validation_mode => p_validation_mode
, x_return_status => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
check_adj_prod_attr
(
p_adj_prod => p_adj_prod
, p_validation_mode => p_validation_mode
, x_return_status => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
check_adj_prod_uk_items
(
p_adj_prod => p_adj_prod
, p_validation_mode => p_validation_mode
, x_return_status => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

check_adj_prod_fk_items
(
p_adj_prod => p_adj_prod
, p_validation_mode => p_validation_mode
, x_return_status => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
check_adj_prod_lkup_items
(
p_adj_prod => p_adj_prod
, p_validation_mode => p_validation_mode
, x_return_status => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
check_adj_prod_inter_attr
(
p_adj_prod => p_adj_prod
, p_validation_mode => p_validation_mode
, x_return_status => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
check_adj_prod_entity
(
p_adj_prod => p_adj_prod
, p_validation_mode => p_validation_mode
, x_return_status => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END check_adj_products;

PROCEDURE VALIDATE_ADJ_PRODUCTS
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.G_CREATE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_adj_prod                   IN offer_adj_prod_rec
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'VALIDATE_ADJ_PRODUCTS';
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
OZF_Offer_Adj_Line_PVT.debug_message('Private API: '|| l_api_name || ' Start');
IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
check_adj_products(
                    p_adj_prod => p_adj_prod
                    , p_validation_mode => p_validation_mode
                    , x_return_status => x_return_status
                    );
END IF;
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
OZF_Offer_Adj_Line_PVT.debug_message('Private API: '|| l_api_name || ' End');

END VALIDATE_ADJ_PRODUCTS;

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
)
IS
l_api_name constant VARCHAR2(30) := 'CREATE_OFFER_ADJ_PRODUCT';
l_api_version_number CONSTANT NUMBER := 1.0;

l_adj_prod offer_adj_prod_rec;

l_object_version_number NUMBER;
CURSOR  C_ID IS
SELECT ozf_offer_adj_products_s.nextval from dual;
l_offer_adjustment_product_id NUMBER;

CURSOR c_id_exists(l_offer_adjustment_product_id NUMBER)
IS
SELECT 1 FROM DUAL WHERE EXISTS (SELECT 'X' FROM ozf_offer_adjustment_products where offer_adjustment_product_id = l_offer_adjustment_product_id);
l_dummy NUMBER;

l_excluder_flag VARCHAR2(1) := 'N';
BEGIN

SAVEPOINT CREATE_OFFER_ADJ_PRODUCT;

IF not fnd_api.compatible_api_call
(
p_api_version_number
, l_api_version_number
, G_PKG_NAME
, l_api_name
)
THEN
RAISE FND_API.g_exc_unexpected_error;
END IF;


IF fnd_api.to_boolean(p_init_msg_list) THEN
FND_MSG_PUB.INITIALIZE;
END IF;

OZF_Offer_Adj_Line_PVT.debug_message('Private API: '|| l_api_name || ' Start');
x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

l_adj_prod := p_adj_prod;

IF p_adj_prod.offer_adjustment_product_id IS NULL OR p_adj_prod.offer_adjustment_product_id = FND_API.G_MISS_NUM THEN
LOOP
    l_dummy := NULL;
    OPEN c_id;
        FETCH C_ID INTO l_offer_adjustment_product_id ;
    CLOSE c_id;

    OPEN c_id_exists(l_offer_adjustment_product_id);
        FETCH c_id_exists INTO l_dummy;
    CLOSE c_id_exists;

    EXIT WHEN l_dummy IS NULL;
end loop;
ELSE
    l_offer_adjustment_product_id := p_adj_prod.offer_adjustment_product_id;
END IF;

VALIDATE_ADJ_PRODUCTS
(
p_api_version_number => p_api_version_number
, p_init_msg_list => p_init_msg_list
, p_commit => p_commit
, p_validation_level => p_validation_level
, p_validation_mode => jtf_plsql_api.g_create
, x_return_status => x_return_status
, x_msg_count => x_msg_count
, x_msg_data => x_msg_data
, p_adj_prod  => p_adj_prod
);

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
IF l_adj_prod.apply_discount_flag = 'N' AND l_adj_prod.include_volume_flag = 'N' THEN
l_excluder_flag := 'Y';
END IF;
OZF_OFFER_ADJ_PRODUCTS_PKG.INSERT_ROW
(
 px_offer_adjustment_product_id   => l_offer_adjustment_product_id
 , p_offer_adjustment_id          => p_adj_prod.offer_adjustment_id
 , p_offer_discount_line_id       => p_adj_prod.offer_discount_line_id
 , p_off_discount_product_id      => p_adj_prod.off_discount_product_id
 , p_product_context              => p_adj_prod.product_context
 , p_product_attribute            => p_adj_prod.product_attribute
 , p_product_attr_value           => p_adj_prod.product_attr_value
 , p_excluder_flag                => l_excluder_flag
 , p_apply_discount_flag          => p_adj_prod.apply_discount_flag
 , p_include_volume_flag          => p_adj_prod.include_volume_flag
 , px_object_version_number       => l_object_version_number
 , p_creation_date           => SYSDATE
 , p_created_by              => FND_GLOBAL.USER_ID
 , p_last_updated_by         => FND_GLOBAL.USER_ID
 , p_last_update_date        => SYSDATE
 , p_last_update_login       => FND_GLOBAL.conc_login_id
);
 IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
 ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

OZF_Offer_Adj_Line_PVT.debug_message('Private API '|| l_api_name || ' End');

 IF FND_API.to_boolean(p_commit) THEN
 COMMIT WORK;
 END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
ROLLBACK TO CREATE_OFFER_ADJ_PRODUCT;
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.COUNT_AND_GET
(
p_encoded => FND_API.G_FALSE
, p_count => x_msg_count
, p_data => x_msg_data
);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO CREATE_OFFER_ADJ_PRODUCT;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.COUNT_AND_GET
(
p_encoded => FND_API.G_FALSE
, p_count => x_msg_count
, p_data => x_msg_data
);

WHEN OTHERS THEN
ROLLBACK TO CREATE_OFFER_ADJ_PRODUCT;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
THEN
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
END IF;
-- Standard call to get message count and if count=1, get the message
FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data  => x_msg_data
);
END CREATE_OFFER_ADJ_PRODUCT;


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

)
IS
l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_OFFER_ADJ_PRODUCT';
l_api_version_number CONSTANT NUMBER := 1.0;
l_tar_rec offer_adj_prod_rec := p_adj_prod_rec;
CURSOR c_get_adj_prod(p_adj_product_id NUMBER , p_object_version_number NUMBER)
IS
SELECT * FROM ozf_offer_adjustment_products
WHERE offer_adjustment_product_id = p_adj_product_id
AND object_version_number = p_object_version_number;
l_ref_rec c_get_adj_prod%rowtype;

l_excluder_flag VARCHAR2(1) := 'N';
BEGIN
SAVEPOINT UPDATE_OFFER_ADJ_PRODUCT;
IF not fnd_api.compatible_api_call
(
l_api_version_number
, p_api_version_number
, l_api_name
, g_pkg_name
)
THEN
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
FND_MSG_PUB.INITIALIZE;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

OZF_Offer_Adj_Line_PVT.debug_message('Private API: '|| l_api_name || ' Start');
OPEN c_get_adj_prod(l_tar_rec.offer_adjustment_product_id , l_tar_rec.object_version_number);
FETCH c_get_adj_prod INTO l_ref_rec;
IF (c_get_adj_prod%NOTFOUND) THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'OZF_OFFR_ADJ_PRODUCTS') ;
           RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE c_get_adj_prod;

IF l_tar_rec.object_version_number IS NULL OR l_tar_rec.object_version_number = FND_API.G_MISS_NUM THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING'
                                           , p_token_name   => 'COLUMN'
                                           , p_token_value  => 'object_version_number') ;
          RAISE FND_API.G_EXC_ERROR;
END IF;

IF l_tar_rec.object_version_number <> l_ref_rec.object_version_number THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'Ozf_Market_Options') ;
          RAISE FND_API.G_EXC_ERROR;
END IF;

VALIDATE_ADJ_PRODUCTS
(
p_api_version_number => p_api_version_number
, p_init_msg_list => p_init_msg_list
, p_commit => p_commit
, p_validation_level => p_validation_level
, p_validation_mode => jtf_plsql_api.g_update
, x_return_status => x_return_status
, x_msg_count => x_msg_count
, x_msg_data => x_msg_data
, p_adj_prod  => l_tar_rec
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
IF l_tar_rec.apply_discount_flag = 'N' AND l_tar_rec.include_volume_flag = 'N' THEN
l_excluder_flag :='Y';
END IF;
OZF_Offer_Adj_Line_PVT.debug_message('eXCLUDER FLAG IS :'||l_excluder_flag||':123');
OZF_OFFER_ADJ_PRODUCTS_PKG.UPDATE_ROW
(
p_offer_adjustment_product_id => l_tar_rec.offer_adjustment_product_id
, p_offer_adjustment_id => l_tar_rec.offer_adjustment_id
, p_offer_discount_line_id => l_tar_rec.offer_discount_line_id
, p_off_discount_product_id  => l_tar_rec.off_discount_product_id
, p_product_context          => l_tar_rec.product_context
, p_product_attribute        => l_tar_rec.product_attribute
, p_product_attr_value       => l_tar_rec.product_attr_value
, p_excluder_flag            => l_excluder_flag
, p_apply_discount_flag      => l_tar_rec.apply_discount_flag
, p_include_volume_flag      => l_tar_rec.include_volume_flag
, p_object_version_number    => l_tar_rec.object_version_number
, p_last_update_date         => sysdate
, p_last_updated_by          => FND_GLOBAL.USER_ID
, p_last_update_login        => FND_GLOBAL.conc_login_id
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
OZF_Offer_Adj_Line_PVT.debug_message('Private API: '|| l_api_name || ' End');
IF FND_API.TO_BOOLEAN(p_commit) THEN
COMMIT WORK;
END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
ROLLBACK TO UPDATE_OFFER_ADJ_PRODUCT;
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO UPDATE_OFFER_ADJ_PRODUCT;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN OTHERS THEN
ROLLBACK TO UPDATE_OFFER_ADJ_PRODUCT;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
THEN
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
END IF;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
END UPDATE_OFFER_ADJ_PRODUCT;

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
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'DELETE_OFFER_ADJ_PRODUCT';
l_api_version_number CONSTANT NUMBER := 1.0;

BEGIN
SAVEPOINT DELETE_OFFER_ADJ_PRODUCT;
IF NOT FND_API.COMPATIBLE_API_CALL
(
l_api_version_number
, p_api_version_number
, l_api_name
, g_pkg_name
)
THEN
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF FND_API.TO_BOOLEAN(P_INIT_MSG_LIST) THEN
FND_msg_pub.INITIALIZE;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;
OZF_Offer_Adj_Line_PVT.debug_message('Private API:'|| l_api_name ||' Start');

OZF_OFFER_ADJ_PRODUCTS_PKG.DELETE_ROW
(
p_offer_adjustment_product_id => p_offer_adjustment_product_id
, p_object_version_number => p_object_version_number
);
OZF_Offer_Adj_Line_PVT.debug_message('Private API:'|| l_api_name || ' End');
IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
COMMIT WORK;
END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
ROLLBACK TO DELETE_OFFER_ADJ_PRODUCT;
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO DELETE_OFFER_ADJ_PRODUCT;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN OTHERS THEN
ROLLBACK TO DELETE_OFFER_ADJ_PRODUCT;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
THEN
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
END IF;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );


END DELETE_OFFER_ADJ_PRODUCT;

END OZF_OFFER_ADJ_PRODUCTS_PVT;

/
