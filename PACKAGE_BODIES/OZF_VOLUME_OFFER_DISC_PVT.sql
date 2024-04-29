--------------------------------------------------------
--  DDL for Package Body OZF_VOLUME_OFFER_DISC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_VOLUME_OFFER_DISC_PVT" AS
/* $Header: ozfvvodb.pls 120.23 2006/08/14 09:59:55 gramanat noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Volume_Offer_disc_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvodlb.pls';

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_discounts_Uk_Items
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_vo_disc_rec     IN    vo_disc_rec_type,
--    p_validation_mode  IN    VARCHAR2,
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2,
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--            Mon Jun 20 2005:2/19 PM RSSHARMA Added new procedure copy_vo_discounts
--   Wed Aug 24 2005:1/39 AM RSSHARMA Made all inout and out params nocopy
--  added new procedure check_XXX_attr. ALso added return at the end of every error
--   Description
-- Wed Sep 28 2005:6/4 PM RSSHARMA Put % validation ie. if disocunttype = % then discount cannot be > 100
-- only if the discount is a static value. Incase the discount is derived using a formula the validation is
-- not fired
-- Thu Sep 29 2005:12/48 PM RSSHARMA Added Buplication check. Dont allow duplicate products in the offer.
-- the duplication check is based on product level, product id and apply_discount_flag
-- Thu Sep 29 2005:2/34 PM RSSHARMA Added no parent validation to discount lines and products.
-- in create mode the parent_discount_line_id (to discount lines) and offer_discount_line_id (to discount products)
-- is passed in as -1. This surpassed the required field validations but fails in FK validations with cryptic messages.
-- catch this situation before hand.
-- Sat Oct 01 2005:6/18 PM Corrected copy_vo_discounts to chech for existance of tier before copying.
-- added function get_discount_line_exists to check if a pbh line exists.
-- Tue Oct 11 2005:2/47 PM RSSHARMA Add debug messages only if debug level is high
-- added tier level validations for overlapping and discontinuous tiers
-- Thu Dec 29 2005:4:00 PM GRAMANAT Changed  QP_CATEGORY_MAPPING_RULE.Validate_UOM to use QP_Validate.Product_Uom
-- Thu Feb 23 2006:12/41 PM  RSSHARMA Fixed big # 5024225. In check_vo_product_Uk_Items, product_attr_value
-- was compared to g_miss_num, which gived charracter to number conversion error.
-- Also for the timebeing commented out discountinuous_tiers_exist call, till the function is corrected
-- Wed Mar 29 2006:6/3 PM RSSHARMA Return product id properly
-- Thu Apr 06 2006:12/12 PM RSSHARMA Fixed bug # 5142859. Added Null currency validation. If the Currency is null then
-- the discount type cannot be anything other than percent.
-- Mon May 22 2006:5/26 PM  RSSHARMA Fixed bug # 5213655. For attributes which are enterable from the UI, retrieve the ak promots to display in required field error messages.
--   End of Comments
--   ==============================================================================


OZF_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
OZF_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
OZF_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


PROCEDURE debug_message(p_message IN VARCHAR2)
IS
BEGIN
  IF (OZF_DEBUG_HIGH_ON) THEN
       ozf_utility_pvt.debug_message(p_message);
   END IF;
END debug_message;


FUNCTION get_discount_line_exists
( p_offerDiscountLineId IN NUMBER)
RETURN VARCHAR2
IS
CURSOR c_discountLineExists(cp_offerDiscountLineId NUMBER) is
SELECT 'Y' from dual where exists (SELECT 'X' FROM ozf_offer_discount_lines WHERE offer_discount_line_id = cp_offerDiscountLineId AND tier_type = 'PBH');
l_discountLineExists VARCHAR2(1) := 'Y';
BEGIN
    OPEN c_discountLineExists(p_offerDiscountLineId );
        FETCH c_discountLineExists INTO l_discountLineExists;
    IF c_discountLineExists%NOTFOUND THEN
        l_discountLineExists := 'N';
    END IF;
    return l_discountLineExists;
CLOSE c_discountLineExists;
END get_discount_line_exists ;


PROCEDURE check_vo_discounts_Uk_Items(
    p_vo_disc_rec               IN   vo_disc_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);
CURSOR c_name(p_name IN VARCHAR2 , p_offer_id IN NUMBER)
IS
SELECT 1 FROM DUAL WHERE EXISTS
(
SELECT 1 FROM OZF_OFFR_DISC_STRUCT_NAME_TL tl, ozf_offr_disc_struct_name_b b, ozf_offer_discount_lines l
           WHERE b.offr_disc_struct_name_id = tl.offr_disc_struct_name_id
           AND tl.LANGUAGE = userenv('LANG')
           AND l.offer_discount_line_id = b.offer_discount_line_id
            AND tl.discount_table_name = p_name
            AND l.offer_id = p_offer_id
            );
l_name c_name%rowtype;
BEGIN

      x_return_status := FND_API.g_ret_sts_success;

      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_vo_disc_rec.offer_discount_line_id IS NOT NULL
      THEN
          IF OZF_Utility_PVT.check_uniqueness('ozf_offer_discount_lines','offer_discount_line_id = ''' || p_vo_disc_rec.offer_discount_line_id ||'''') = FND_API.g_false THEN
             OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_DISC_LINE_ID_DUP');
             x_return_status := FND_API.g_ret_sts_error;
          END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_vo_disc_rec.offr_disc_struct_name_id IS NOT NULL
      THEN
          IF OZF_Utility_PVT.check_uniqueness('ozf_offr_disc_struct_name_b','OFFR_DISC_STRUCT_NAME_ID = ''' || p_vo_disc_rec.offr_disc_struct_name_id ||'''') = FND_API.g_false THEN
             OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_DISC_NAME_ID_DUP');
             x_return_status := FND_API.g_ret_sts_error;
          END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_vo_disc_rec.name IS NOT NULL
      THEN
      OPEN c_name(p_vo_disc_rec.name, p_vo_disc_rec.offer_id);
          FETCH c_name INTO l_name;
             If ( c_name%NOTFOUND) THEN
                 NULL;
             ELSE
                 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_DISC_NAME_DUP');
                 x_return_status := FND_API.g_ret_sts_error;
            END IF;
      END IF;



END check_vo_discounts_Uk_Items;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_PBH_req_items
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_vo_disc_rec     IN    vo_disc_rec_type,
--    p_validation_mode  IN    VARCHAR2,
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2,
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE check_PBH_req_items(
    p_vo_disc_rec               IN  vo_disc_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'check_PBH_req_items';
CURSOR c_volume_type(p_offer_discount_line_id NUMBER)
IS
SELECT volume_type FROM ozf_offer_discount_lines
WHERE offer_discount_line_id = p_offer_discount_line_id;
l_volume_type OZF_OFFER_DISCOUNT_LINES.volume_type%type;
BEGIN
--initialize
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');

   x_return_status := FND_API.g_ret_sts_success;
-- volume type required
      IF p_vo_disc_rec.volume_type = FND_API.G_MISS_CHAR OR p_vo_disc_rec.volume_type IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_TIERS_BY') );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
-- volume_break_type required
      IF p_vo_disc_rec.volume_break_type = FND_API.G_MISS_CHAR OR p_vo_disc_rec.volume_break_type IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_BREAK_TYPE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
-- discount type required
      IF p_vo_disc_rec.discount_type = FND_API.G_MISS_CHAR OR p_vo_disc_rec.discount_type IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_DISCOUNT_BY') );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_vo_disc_rec.name = FND_API.G_MISS_CHAR OR p_vo_disc_rec.name IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_OFFER_DISC_TBL_NAME') );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

-- get volume_type for the discount line
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
            l_volume_type := p_vo_disc_rec.volume_type;
        ELSIF p_validation_mode = JTF_PLSQL_API.g_update then
            IF p_vo_disc_rec.volume_type IS NULL OR p_vo_disc_rec.volume_type = FND_API.G_MISS_CHAR THEN
                OPEN c_volume_type(p_vo_disc_rec.offer_discount_line_id);
                    FETCH c_volume_type INTO l_volume_type ;
                CLOSE c_volume_type;
            ELSE
            l_volume_type := p_vo_disc_rec.volume_type;
            END IF;
        ELSE
         OZF_Offer_Adj_Line_PVT.debug_message('INVALID VALIDATION MODE');
          x_return_status := FND_API.g_ret_sts_error;
        END IF;

-- if volume_type = quantity (PRICING_ATTRIBUTE10) UOM CODE is required
    IF  l_volume_type = 'PRICING_ATTRIBUTE10' THEN
      IF p_vo_disc_rec.uom_code = FND_API.G_MISS_CHAR OR p_vo_disc_rec.uom_code IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_UOM') );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
    END IF;

      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');

END check_pbh_req_items;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_dis_req_items
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_vo_disc_rec     IN    vo_disc_rec_type,
--    p_validation_mode  IN    VARCHAR2,
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2,
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE check_dis_req_items(
    p_vo_disc_rec               IN  vo_disc_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'check_dis_req_items';
l_discStr VARCHAR2(240);
BEGIN
--initialize
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');
   x_return_status := FND_API.g_ret_sts_success;
   l_discStr := OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_DISCOUNT' );
   l_discStr := l_discStr || ' ' || OZF_UTILITY_PVT.getAttributeName(p_attributeCode =>'IEC_ALG_OR' , p_applicationId => 545) ;
   l_discStr := l_discStr || ' '|| OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_FORMULA');

   IF p_validation_mode = jtf_plsql_api.g_create THEN
--parent discount line id is required
      IF p_vo_disc_rec.parent_discount_line_id = FND_API.G_MISS_NUM OR p_vo_disc_rec.parent_discount_line_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'PARENT_DISCOUNT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;
-- volume_from is required
      IF p_vo_disc_rec.VOLUME_FROM = FND_API.G_MISS_NUM OR p_vo_disc_rec.VOLUME_FROM IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', OZF_UTILITY_PVT.getAttributeName(p_attributeCode =>'OZF_FROM') );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;
-- volume_to is required
      IF p_vo_disc_rec.volume_to = FND_API.G_MISS_NUM OR p_vo_disc_rec.volume_to IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', OZF_UTILITY_PVT.getAttributeName(p_attributeCode =>'OZF_SCREEN_TO') );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;
--volume_operator is required
      IF p_vo_disc_rec.volume_operator = FND_API.G_MISS_CHAR OR p_vo_disc_rec.volume_operator IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_OPERATOR' );
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
      END IF;
-- formula_id or discount are required. Both cannot be null
      IF (p_vo_disc_rec.discount = FND_API.G_MISS_NUM OR p_vo_disc_rec.discount IS NULL)
            AND
         (p_vo_disc_rec.formula_id = FND_API.G_MISS_NUM OR p_vo_disc_rec.formula_id IS NULL)
      THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD'
               , l_discStr
                );
               x_return_status := FND_API.g_ret_sts_error;
                return;
      END IF;
ELSE
        IF p_vo_disc_rec.offer_discount_line_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','OFFER_DISCOUNT_LINE_ID');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
        IF p_vo_disc_rec.object_version_number = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','object_version_number');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;

      IF p_vo_disc_rec.parent_discount_line_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'PARENT_DISCOUNT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;
-- volume_from is required
      IF p_vo_disc_rec.VOLUME_FROM = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', OZF_UTILITY_PVT.getAttributeName(p_attributeCode =>'OZF_FROM') );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;
-- volume_to is required
      IF p_vo_disc_rec.volume_to = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', OZF_UTILITY_PVT.getAttributeName(p_attributeCode =>'OZF_SCREEN_TO') );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;
--volume_operator is required
      IF p_vo_disc_rec.volume_operator = FND_API.G_MISS_CHAR THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_OPERATOR' );
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
      END IF;
-- formula_id or discount are required. Both cannot be null
      IF (p_vo_disc_rec.discount = FND_API.G_MISS_NUM )
            AND
         (p_vo_disc_rec.formula_id = FND_API.G_MISS_NUM )
      THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD'
               , l_discStr
                );
               x_return_status := FND_API.g_ret_sts_error;
                return;
      END IF;

   END IF;

        IF p_vo_disc_rec.offer_discount_line_id = -1 THEN
                    OZF_Utility_PVT.Error_Message('OZF_DIS_LINE_NO_PARENT' );
                    x_return_status := FND_API.g_ret_sts_error;
                    return;
        END IF;

      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');

END check_dis_req_items;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_req_items
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_vo_disc_rec     IN    vo_disc_rec_type,
--    p_validation_mode  IN    VARCHAR2,
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2,
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================
PROCEDURE check_vo_req_items(
    p_vo_disc_rec               IN  vo_disc_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY VARCHAR2
)
IS
CURSOR c_offer_type(p_offer_id NUMBER) IS
SELECT offer_type FROM ozf_offers
WHERE offer_id = p_offer_id;

CURSOR c_tier_type(p_offer_discount_line_id number) IS
SELECT tier_type FROM ozf_offer_discount_lines
WHERE offer_discount_line_id = p_offer_discount_line_id;

l_offer_type OZF_OFFERS.offer_type%type;
l_tier_type OZF_OFFER_DISCOUNT_LINES.tier_type%type;

l_api_name CONSTANT VARCHAR2(30) := 'check_vo_req_items';

BEGIN
--initialize
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');

   x_return_status := FND_API.g_ret_sts_success;

-- get offer type
   OPEN c_offer_type(p_vo_disc_rec.offer_id);
   FETCH c_offer_type INTO l_offer_type ;
   CLOSE c_offer_type;
         OZF_Offer_Adj_Line_PVT.debug_message('Offer Type is ' || l_offer_type || 'Offer Id is :'|| p_vo_disc_rec.offer_id);
-- if offer_type is not volume_offer return error message
   IF l_offer_type = 'VOLUME_OFFER' THEN
-- get tier_type for the line either from db or from record itself
        IF p_validation_mode = JTF_PLSQL_API.g_create THEN
            l_tier_type := p_vo_disc_rec.tier_type;
        ELSIF p_validation_mode = JTF_PLSQL_API.g_update then
            IF p_vo_disc_rec.tier_type IS NULL OR p_vo_disc_rec.tier_type = FND_API.G_MISS_CHAR THEN
                OPEN c_tier_type(p_vo_disc_rec.offer_discount_line_id);
                    FETCH c_tier_type INTO l_tier_type ;
                CLOSE c_tier_type;
            ELSE
            l_tier_type := p_vo_disc_rec.tier_type;
            END IF;
        ELSE
         OZF_Offer_Adj_Line_PVT.debug_message('INVALID VALIDATION MODE');
          x_return_status := FND_API.g_ret_sts_error;
        END IF;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

            IF l_tier_type = 'PBH' THEN
                check_PBH_req_items(
                                    p_vo_disc_rec => p_vo_disc_rec
                                    , p_validation_mode => p_validation_mode
                                    , x_return_status => x_return_status
                                    );
            ELSIF l_tier_type = 'DIS' THEN
                    check_dis_req_items(
                                    p_vo_disc_rec => p_vo_disc_rec
                                    , p_validation_mode => p_validation_mode
                                    , x_return_status => x_return_status
                                    );
            ELSE
                       x_return_status := FND_API.g_ret_sts_error;
                       -- populate error message for invalid tier type
            END IF;

   ELSE
         OZF_Offer_Adj_Line_PVT.debug_message('Offer Type is ' || l_offer_type || 'Offer Id is :'|| p_vo_disc_rec.offer_id);
               x_return_status := FND_API.g_ret_sts_error;
   -- populate error message for invalid offer type
   END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');


END check_vo_req_items;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_discounts_req_items
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_vo_disc_rec     IN    vo_disc_rec_type,
--    p_validation_mode  IN    VARCHAR2,
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2,
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================
PROCEDURE check_vo_discounts_req_items(
    p_vo_disc_rec               IN  vo_disc_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'check_vo_discounts_req_items';
BEGIN
--initialize
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');

   x_return_status := FND_API.g_ret_sts_success;
-- check required items
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
/*
      IF p_vo_disc_rec.offer_discount_line_id = FND_API.G_MISS_NUM OR p_vo_disc_rec.offer_discount_line_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_DISCOUNT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;
*/
      IF p_vo_disc_rec.offer_id = FND_API.G_MISS_NUM OR p_vo_disc_rec.offer_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;



   ELSE

      IF p_vo_disc_rec.offer_discount_line_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_DISCOUNT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_vo_disc_rec.offer_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;


   END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

check_vo_req_items(
                    p_vo_disc_rec               => p_vo_disc_rec
                    , p_validation_mode => p_validation_mode
                    , x_return_status         => x_return_status
                    );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');


END check_vo_discounts_req_items;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_discounts_FK_items
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_vo_disc_rec     IN    vo_disc_rec_type,
--    p_validation_mode  IN    VARCHAR2,
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2,
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================
PROCEDURE check_vo_discounts_FK_items(
    p_vo_disc_rec IN vo_disc_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   -- Enter custom code here

    IF p_vo_disc_rec.offer_id IS NOT NULL AND p_vo_disc_rec.offer_id  <> FND_API.G_MISS_NUM
    THEN
        IF ozf_utility_pvt.check_fk_exists('OZF_OFFERS','OFFER_ID',to_char(p_vo_disc_rec.offer_id)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_OFFER_ID' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
    END IF;

    IF p_vo_disc_rec.parent_discount_line_id IS NOT NULL AND p_vo_disc_rec.PARENT_DISCOUNT_LINE_ID  <> FND_API.G_MISS_NUM
    THEN
    OZF_Offer_Adj_Line_PVT.debug_message('Parent Id is :'||p_vo_disc_rec.parent_discount_line_id);
        IF ozf_utility_pvt.check_fk_exists('OZF_OFFER_DISCOUNT_LINES','OFFER_DISCOUNT_LINE_ID',to_char(p_vo_disc_rec.parent_discount_line_id)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_PARENT_ID' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
    END IF;

    IF p_vo_disc_rec.formula_id IS NOT NULL AND p_vo_disc_rec.formula_id  <> FND_API.G_MISS_NUM
    THEN
        IF ozf_utility_pvt.check_fk_exists('QP_PRICE_FORMULAS_B','PRICE_FORMULA_ID',to_char(p_vo_disc_rec.formula_id)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_FORMULA' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
    END IF;

    IF p_vo_disc_rec.uom_code IS NOT NULL AND p_vo_disc_rec.uom_code  <> FND_API.G_MISS_CHAR
    THEN
        IF ozf_utility_pvt.check_fk_exists('MTL_UNITS_OF_MEASURE','UOM_CODE',to_char(p_vo_disc_rec.uom_code)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_UOM' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
    END IF;



    null;
END check_vo_discounts_FK_items;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_discounts_Lkup_Items
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_vo_disc_rec     IN    vo_disc_rec_type,
--    p_validation_mode  IN    VARCHAR2,
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2,
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================
PROCEDURE check_vo_discounts_Lkup_Items(
    p_vo_disc_rec IN vo_disc_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_vo_disc_rec.volume_type IS NOT NULL AND p_vo_disc_rec.volume_type  <> FND_API.G_MISS_CHAR
    THEN
        IF OZF_UTILITY_PVT.check_lookup_exists('OZF_LOOKUPS', 'OZF_QP_VOLUME_TYPE', p_vo_disc_rec.volume_type) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_VOLUME_TYPE' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
    END IF;

   IF p_vo_disc_rec.discount_type IS NOT NULL AND p_vo_disc_rec.discount_type  <> FND_API.G_MISS_CHAR
    THEN
        IF OZF_UTILITY_PVT.check_lookup_exists('QP_LOOKUPS', 'ARITHMETIC_OPERATOR', p_vo_disc_rec.discount_type) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_DISCOUNT_TYPE' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
   END IF;


   IF p_vo_disc_rec.volume_operator IS NOT NULL AND p_vo_disc_rec.volume_operator  <> FND_API.G_MISS_CHAR
    THEN
        IF OZF_UTILITY_PVT.check_lookup_exists('QP_LOOKUPS', 'COMPARISON_OPERATOR', p_vo_disc_rec.volume_operator) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_OPERATOR' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
   END IF;

   IF p_vo_disc_rec.volume_break_type IS NOT NULL AND p_vo_disc_rec.volume_break_type  <> FND_API.G_MISS_CHAR
    THEN
        IF OZF_UTILITY_PVT.check_lookup_exists('QP_LOOKUPS', 'PRICE_BREAK_TYPE_CODE', p_vo_disc_rec.volume_break_type) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_BREAK_TYPE' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
   END IF;

   IF p_vo_disc_rec.tier_type IS NOT NULL AND p_vo_disc_rec.tier_type  <> FND_API.G_MISS_CHAR
    THEN
        IF OZF_UTILITY_PVT.check_lookup_exists('OZF_LOOKUPS', 'OZF_OFFER_TIER_TYPE', p_vo_disc_rec.tier_type) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_TIER_TYPE' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
   END IF;

   -- Enter custom code here
END check_vo_discounts_Lkup_Items;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_discounts_attr
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_vo_disc_rec     IN    vo_disc_rec_type,
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2,
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE   check_vo_discounts_attr(
    p_vo_disc_rec     IN    vo_disc_rec_type,
    x_return_status    OUT NOCOPY   VARCHAR2
      )
IS
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_vo_disc_rec.volume_from IS NOT NULL AND p_vo_disc_rec.volume_from <> FND_API.G_MISS_NUM THEN
    IF p_vo_disc_rec.volume_from < 0 THEN
            OZF_Utility_PVT.Error_Message('OZF_NEGATIVE_QTY' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
END IF;
IF p_vo_disc_rec.volume_to IS NOT NULL AND p_vo_disc_rec.volume_to <> FND_API.G_MISS_NUM THEN
    IF p_vo_disc_rec.volume_to < 0 THEN
            OZF_Utility_PVT.Error_Message('OZF_NEGATIVE_QTY' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
END IF;
IF p_vo_disc_rec.parent_discount_line_id = -1 THEN
            OZF_Utility_PVT.Error_Message('OZF_DIS_LINE_NO_PARENT' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
END IF;
END check_vo_discounts_attr;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_discounts_inter_attr
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_vo_disc_rec     IN    vo_disc_rec_type,
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2,
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE   check_vo_discounts_inter_attr(
    p_vo_disc_rec     IN    vo_disc_rec_type,
    x_return_status    OUT NOCOPY   VARCHAR2
      )
IS
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
IF (p_vo_disc_rec.volume_from IS NOT NULL AND p_vo_disc_rec.volume_from <> FND_API.G_MISS_NUM )
    AND
    (p_vo_disc_rec.volume_to IS NOT NULL AND p_vo_disc_rec.volume_to <> FND_API.G_MISS_NUM )
THEN
    IF p_vo_disc_rec.volume_to <  p_vo_disc_rec.volume_from THEN
            OZF_Utility_PVT.Error_Message('OZF_FROM_GT_TO' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
END IF;
END check_vo_discounts_inter_attr;



FUNCTION overlapping_tiers_exist
(
    p_volumeFrom NUMBER
    , p_volumeTo NUMBER
    , p_offerId NUMBER
    , p_parentDiscountLineId NUMBER
    , p_offerDiscountLineId  NUMBER
)
RETURN VARCHAR2
IS
CURSOR c_getOverlapTiers(cp_volumeFrom NUMBER
                        ,cp_volumeTo NUMBER
                        , cp_offerId NUMBER
                        , cp_parentDiscountLineId NUMBER
                        , cp_offerDiscountLineId NUMBER
                        ) IS
SELECT 1 FROM dual WHERE EXISTS(SELECT 'X'
                                FROM ozf_offer_discount_lines
                                WHERE tier_type = 'DIS'
                                AND (
                                        ( cp_volumeFrom BETWEEN volume_from  AND volume_to)
                                        OR
                                        (cp_volumeTo BETWEEN volume_from AND volume_to )
                                     )
                                AND offer_id = cp_offerId
                                AND parent_discount_line_id = cp_parentDiscountLineId
                                AND offer_discount_line_id <> cp_offerDiscountLineId
                                 );
l_getOverlapTiers NUMBER;
l_return VARCHAR2(10) := null;
BEGIN
l_return := null;
OZF_Offer_Adj_Line_PVT.debug_message('Volume From :'||p_volumeFrom || ' : volume to : '||p_volumeTo || ' OfferDiscountLineId :'||p_parentDiscountLineId || ' : OfferDiscountLIneId is : '||p_offerDiscountLineId|| 'OfferId :'||p_offerId);
    OPEN c_getOverlapTiers(cp_volumeFrom => p_volumeFrom
                            , cp_volumeTo => p_volumeTo
                            , cp_offerId => p_offerId
                            , cp_parentDiscountLineId => p_parentDiscountLineId
                            , cp_offerDiscountLineId => p_offerDiscountLineId
                            );
        FETCH c_getOverlapTiers INTO l_getOverlapTiers;
    IF (c_getOverlapTiers%NOTFOUND) THEN
        l_return := 'N';
    ELSE
        l_return := 'Y';
    END IF;
    CLOSE c_getOverlapTiers;
    return l_return;
END overlapping_tiers_exist;

FUNCTION discontinuous_tiers_exist(p_volumeFrom NUMBER, p_volumeTo NUMBER, p_offerId NUMBER , p_offerDiscountLineId NUMBER)
RETURN VARCHAR2 IS
CURSOR c_getContinuousTiers(cp_volumeFrom NUMBER,cp_volumeTo NUMBER , cp_offerId NUMBER, cp_offerDiscountLineId NUMBER) IS
SELECT 1 FROM dual WHERE EXISTS(SELECT 'X'
                                    FROM ozf_offer_discount_lines
                                WHERE tier_type = 'DIS'
                                AND (
                                        (volume_to IN (cp_volumeFrom , cp_volumeFrom -1 ))
                                        OR
                                        (volume_from IN ( cp_volumeTo , cp_volumeTo + 1 ))
                                     )
                                AND offer_id = cp_offerId
                                AND parent_discount_line_id = cp_offerDiscountLineId
                               );

CURSOR c_tiersExist( cp_parentDiscountLineId NUMBER )IS
SELECT 'Y'
FROM dual
WHERE EXISTS (SELECT 'X'
                FROM ozf_offer_discount_lines
                WHERE parent_discount_line_id = cp_parentDiscountLineId
             );
l_tiersExist VARCHAR2(1) := null;
l_getContinuousTiers NUMBER;
l_return VARCHAR2(10) := null;
BEGIN
    l_return := null;
    l_tiersExist := null;
    OPEN c_tiersExist(cp_parentDiscountLineId => p_offerDiscountLineId);
    FETCH c_tiersExist INTO l_tiersExist;
    IF (c_tiersExist%NOTFOUND) THEN
        l_return := 'N';
    ELSE
        OPEN c_getContinuousTiers(cp_volumeFrom => p_volumeFrom , cp_volumeTo => p_volumeTo, cp_offerId => p_offerId , cp_offerDiscountLineId => p_offerDiscountLineId);
        FETCH c_getContinuousTiers INTO l_getContinuousTiers;
        IF ( c_getContinuousTiers%NOTFOUND )THEN
            l_return := 'N';
        ELSE
            l_return := 'Y';
        END IF;
        CLOSE c_getContinuousTiers;
    END IF;
    CLOSE c_tiersExist;
    return l_return;
END discontinuous_tiers_exist;


FUNCTION getOfferId
(
    p_offerDiscountLineId IN NUMBER
)
RETURN NUMBER
IS
l_offerId NUMBER;
CURSOR c_offerId(cp_offerDiscountLineId NUMBER)
IS
SELECT offer_id
FROM ozf_offer_discount_lines
WHERE offer_discount_line_id = cp_offerDiscountLineId;
BEGIN
    OPEN c_offerId(cp_offerDiscountLineId => p_offerDiscountLineId);
        FETCH c_offerId INTO l_offerId;
        IF c_offerId%NOTFOUND THEN
            l_offerId := null;
        END IF;
    CLOSE c_offerId;
    return l_offerId;
END getOfferId;


PROCEDURE validatePbhLines
(
  x_return_status           OUT NOCOPY  VARCHAR2
 , p_vo_disc_rec            IN    vo_disc_rec_type
)
IS
 CURSOR c_currency(cp_offerId NUMBER)
 IS
 SELECT transaction_currency_code
 FROM ozf_offers
 WHERE offer_id = cp_offerId;
 l_currency ozf_offers.transaction_currency_code%TYPE;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
OPEN c_currency(cp_offerId => nvl(p_vo_disc_rec.offer_id,getOfferId(p_offerDiscountLineId => p_vo_disc_rec.offer_discount_line_id)));
    FETCH c_currency INTO l_currency;
CLOSE c_currency;
IF l_currency IS NULL THEN
    IF (p_vo_disc_rec.tier_type <> FND_API.G_MISS_CHAR AND p_vo_disc_rec.tier_type IS NOT NULL)
    THEN
            IF
            (p_vo_disc_rec.tier_type = 'PBH' AND p_vo_disc_rec.discount_type <> '%' )
            THEN
                 OZF_Utility_PVT.error_message('OZF_OFFR_OPT_CURR_PCNT');
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 RAISE FND_API.g_exc_error;
            END IF;
    END IF;
END IF;
END validatePbhLines;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_discounts_inter_attr
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_vo_disc_rec     IN    vo_disc_rec_type,
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2,
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE   check_vo_discounts_entity(
    p_vo_disc_rec     IN    vo_disc_rec_type,
    x_return_status    OUT NOCOPY   VARCHAR2
      )
IS
l_discount_type OZF_OFFER_DISCOUNT_LINES.DISCOUNT_TYPE%TYPE;
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
OZF_Offer_Adj_Line_PVT.debug_message('uom is ' || p_vo_disc_rec.uom_code);
IF p_vo_disc_rec.uom_code IS NOT NULL AND p_vo_disc_rec.uom_code <> fnd_api.g_miss_char AND p_vo_disc_rec.volume_type <> 'PRICING_ATTRIBUTE10' THEN
  OZF_Utility_PVT.Error_Message('OZF_VO_UOM_INV' );
  x_return_status := FND_API.g_ret_sts_error;
  RETURN;
END IF;

IF p_vo_disc_rec.tier_type = 'DIS' AND (p_vo_disc_rec.parent_discount_line_id IS NOT NULL AND p_vo_disc_rec.parent_discount_line_id <> FND_API.G_MISS_NUM) THEN
    SELECT discount_type INTO l_discount_type FROM OZF_OFFER_DISCOUNT_LINES
    WHERE OFFER_DISCOUNT_LINE_ID = p_vo_disc_rec.parent_discount_line_id;
    OZF_Offer_Adj_Line_PVT.debug_message('Discount is :'||p_vo_disc_rec.discount);
    IF p_vo_disc_rec.discount IS NOT NULL AND p_vo_disc_rec.discount <> FND_API.G_MISS_NUM THEN
        IF l_discount_type ='%' AND p_vo_disc_rec.discount > 100 THEN
            OZF_Utility_PVT.Error_Message('OZF_PER_DISC_INV' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
    END IF;

END IF;
-- Validation for Volume From to be less than Volume to
IF (p_vo_disc_rec.volume_from IS NOT NULL AND p_vo_disc_rec.volume_from <> FND_API.G_MISS_NUM )
    AND
    (p_vo_disc_rec.volume_to IS NOT NULL AND p_vo_disc_rec.volume_to <> FND_API.G_MISS_NUM )
THEN
    IF p_vo_disc_rec.volume_to <  p_vo_disc_rec.volume_from THEN
            OZF_Utility_PVT.Error_Message('OZF_FROM_GT_TO' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
END IF;
/*
IF (p_vo_disc_rec.volume_from IS NOT NULL AND p_vo_disc_rec.volume_from <> FND_API.G_MISS_NUM )
    AND
    (p_vo_disc_rec.volume_to IS NOT NULL AND p_vo_disc_rec.volume_to <> FND_API.G_MISS_NUM)
THEN
*/
-- Validation for non-overlapping tiers
-- Removing the validation of 10 between 0 and 10 as it will always be true.
/*
    IF overlapping_tiers_exist(
                                p_vo_disc_rec.volume_from
                                , p_vo_disc_rec.volume_to
                                , p_vo_disc_rec.offer_id
                                , p_vo_disc_rec.parent_discount_line_id
                                , p_vo_disc_rec.offer_discount_line_id
                                ) = 'Y' THEN
            OZF_Utility_PVT.Error_Message('OZF_VO_INVALID_TIERS' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
*/
-- validation for discountinuous tiers
/*     IF discontinuous_tiers_exist( p_vo_disc_rec.volume_from
                                , p_vo_disc_rec.volume_to
                                , p_vo_disc_rec.offer_id
                                , p_vo_disc_rec.parent_discount_line_id
                                ) = 'Y' THEN
            OZF_Utility_PVT.Error_Message('OZF_VO_DISCNT_TIERS' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
     END IF;
     */
/*
END IF;
*/
validatePbhLines
(
  x_return_status           => x_return_status
 , p_vo_disc_rec            => p_vo_disc_rec
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END check_vo_discounts_entity;











--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Check_vo_discount_Items
--   Type
--           Private
--   Pre-Req
--             check_vo_discounts_Uk_Items,check_vo_discounts_req_items,check_vo_discounts_FK_items,check_vo_discounts_Lkup_Items
--   Parameters
--
--   IN
--    p_vo_disc_rec     IN    vo_disc_rec_type,
--    p_validation_mode  IN    VARCHAR2,
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2,
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE Check_vo_discount_Items (
    p_vo_disc_rec     IN    vo_disc_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_api_name CONSTANT VARCHAR2(30) := 'Check_vo_discount_Items';
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');

   check_vo_discounts_req_items(
      p_vo_disc_rec => p_vo_disc_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   check_vo_discounts_attr(
      p_vo_disc_rec => p_vo_disc_rec,
      x_return_status => x_return_status
      );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Check Items Uniqueness API calls
   check_vo_discounts_Uk_Items(
      p_vo_disc_rec => p_vo_disc_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;



   -- Check Items Foreign Keys API calls

   check_vo_discounts_FK_items(
      p_vo_disc_rec => p_vo_disc_rec,
      x_return_status => x_return_status);
   -- Check Items Lookups

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   check_vo_discounts_Lkup_Items(
      p_vo_disc_rec => p_vo_disc_rec,
      x_return_status => x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


check_vo_discounts_inter_attr(
      p_vo_disc_rec => p_vo_disc_rec,
      x_return_status => x_return_status
      );
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


check_vo_discounts_entity(
      p_vo_disc_rec => p_vo_disc_rec,
      x_return_status => x_return_status
      );
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');

END Check_vo_discount_Items;



PROCEDURE Complete_pbh_Rec (
   p_vo_disc_rec IN vo_disc_rec_type,
   x_complete_rec OUT NOCOPY vo_disc_rec_type)
IS
BEGIN
OZF_Offer_Adj_Line_PVT.debug_message('Complete_pbh_Rec');
x_complete_rec := p_vo_disc_rec;
x_complete_rec.parent_discount_line_id := FND_API.G_MISS_NUM;
x_complete_rec.volume_from             := FND_API.G_MISS_NUM;
x_complete_rec.volume_to               := FND_API.G_MISS_NUM;
x_complete_rec.volume_operator         := FND_API.G_MISS_CHAR;
x_complete_rec.discount                := FND_API.G_MISS_NUM;
x_complete_rec.incompatibility_group   := FND_API.G_MISS_CHAR;
x_complete_rec.precedence              := FND_API.G_MISS_NUM;
x_complete_rec.bucket                  := FND_API.G_MISS_CHAR;
x_complete_rec.scan_value              := FND_API.G_MISS_NUM;
x_complete_rec.scan_data_quantity      := FND_API.G_MISS_NUM;
x_complete_rec.scan_unit_forecast      := FND_API.G_MISS_NUM;
x_complete_rec.channel_id              := FND_API.G_MISS_NUM;
x_complete_rec.discount_by_code        := FND_API.G_MISS_CHAR;
x_complete_rec.formula_id              := FND_API.G_MISS_NUM;
x_complete_rec.adjustment_flag         := FND_API.G_MISS_CHAR;
IF  x_complete_rec.volume_type = 'PRICING_ATTRIBUTE12' THEN
    x_complete_rec.uom_code := FND_API.G_MISS_CHAR;
END IF;
END Complete_pbh_Rec;

PROCEDURE Complete_dis_Rec (
   p_vo_disc_rec IN vo_disc_rec_type,
   x_complete_rec OUT NOCOPY vo_disc_rec_type)
IS
BEGIN
OZF_Offer_Adj_Line_PVT.debug_message('Complete_dis_Rec');
x_complete_rec := p_vo_disc_rec;
x_complete_rec.incompatibility_group   := FND_API.G_MISS_CHAR;
x_complete_rec.precedence              := FND_API.G_MISS_NUM;
x_complete_rec.bucket                  := FND_API.G_MISS_CHAR;
x_complete_rec.scan_value              := FND_API.G_MISS_NUM;
x_complete_rec.scan_data_quantity      := FND_API.G_MISS_NUM;
x_complete_rec.scan_unit_forecast      := FND_API.G_MISS_NUM;
x_complete_rec.channel_id              := FND_API.G_MISS_NUM;
x_complete_rec.discount_by_code        := FND_API.G_MISS_CHAR;
x_complete_rec.adjustment_flag         := FND_API.G_MISS_CHAR;
x_complete_rec.volume_type             := FND_API.G_MISS_CHAR;
x_complete_rec.volume_break_type       := FND_API.G_MISS_CHAR;
x_complete_rec.discount_type           := FND_API.G_MISS_CHAR;
x_complete_rec.name                    := FND_API.G_MISS_CHAR;
x_complete_rec.description             := FND_API.G_MISS_CHAR;

END Complete_dis_Rec;

PROCEDURE Complete_vo_discount_Rec (
   p_vo_disc_rec IN vo_disc_rec_type,
   x_complete_rec OUT NOCOPY vo_disc_rec_type)
IS
BEGIN
x_complete_rec := p_vo_disc_rec;
IF p_vo_disc_rec.tier_type = 'PBH' THEN
Complete_pbh_Rec (
   p_vo_disc_rec => p_vo_disc_rec,
   x_complete_rec => x_complete_rec);
ELSE
Complete_dis_Rec (
   p_vo_disc_rec => p_vo_disc_rec,
   x_complete_rec => x_complete_rec);

END IF;
END Complete_vo_discount_Rec;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_vo_discounts_rec
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_api_version_number         IN   NUMBER
--    p_init_msg_list              IN   VARCHAR2
--    p_vo_disc_rec         IN    vo_disc_rec_type
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--    x_msg_count                  OUT NOCOPY  NUMBER
--    x_msg_data                   OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================


PROCEDURE Validate_vo_discounts_rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_vo_disc_rec         IN    vo_disc_rec_type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_vo_discounts_rec;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_vo_discounts
--   Type
--           Private
--   Pre-Req
--             Check_vo_discount_Items,check_vo_discounts_Uk_Items,check_vo_discounts_req_items,check_vo_discounts_FK_items,check_vo_discounts_Lkup_Items
--   Parameters
--
--   IN
--    p_api_version_number         IN   NUMBER,
--    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
--    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
--    p_vo_disc_rec           IN   vo_disc_rec_type,
--    p_validation_mode            IN   VARCHAR2,
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2,
--    x_msg_count                  OUT NOCOPY  NUMBER,
--    x_msg_data                   OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--              : Helper method to validate discount line record
--   End of Comments
--   ==============================================================================

PROCEDURE Validate_vo_discounts(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    px_vo_disc_rec                IN   OUT NOCOPY vo_disc_rec_type,
    p_validation_mode            IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_vo_discounts';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_vo_disc_rec               vo_disc_rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Validate_vo_discounts_pvt;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'Return status is : '|| x_return_status);

/*IF p_validation_mode <> JTF_PLSQL_API.g_create THEN
      Complete_vo_discount_Rec(
         p_vo_disc_rec        => px_vo_disc_rec,
         x_complete_rec        => px_vo_disc_rec
      );
END IF;*/
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_vo_discount_Items(
                 p_vo_disc_rec        => px_vo_disc_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
--      IF p_validation_mode = JTF_PLSQL_API.g_update THEN

--      END IF;
/*      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_vo_discounts_rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_vo_disc_rec       =>    l_vo_disc_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
 */

      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'Return status is : '|| x_return_status);

      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Validate_vo_discounts_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Validate_vo_discounts_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Validate_vo_discounts_pvt;
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

End Validate_vo_discounts;






--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_vo_discount
--   Type
--           Private
--   Pre-Req
--             OZF_Create_Ozf_Prod_Line_PKG.Delete_Product,OZF_DISC_LINE_PKG.Delete_Row
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_offer_discount_line_id  IN   NUMBER     Required  Discount Line id to be deleted
--       p_object_version_number   IN   NUMBER     Required  Object Version No. Of Discount Line to be deleted
--
--   OUT NOCOPY
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to Hard Delete a Discount Line and all the Related Product Lines for a volume offer
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_vo_discount(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_discount_line_id     IN NUMBER,
    p_object_version_number      IN NUMBER
)
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_vo_discount';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_offr_disc_struct_name_id NUMBER;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_vo_discount_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Invoke table handler(OZF_Promotional_Offers_PKG.Delete_Row)
      BEGIN
      OZF_Create_Ozf_Prod_Line_PKG.Delete_Product(
                                                    p_offer_discount_line_id  => p_offer_discount_line_id
                                                  );
      EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            null;
      END;
OZF_Offer_Adj_Line_PVT.debug_message('Done calling Delete product');

      BEGIN
         SELECT object_version_number, offr_disc_struct_name_id INTO l_object_version_number, l_offr_disc_struct_name_id
         FROM ozf_offr_disc_struct_name_b
         WHERE offer_discount_line_id = p_offer_discount_line_id;

        OZF_VO_DISC_STRUCT_NAME_PKG.Delete_Row(
            p_offr_disc_struct_name_id  => l_offr_disc_struct_name_id,
            p_object_version_number  => l_object_version_number);

      EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            null;
      END;
OZF_Offer_Adj_Line_PVT.debug_message('Done calling Delete name');


BEGIN
      OZF_DISC_LINE_PKG.delete_tiers(p_offer_discount_line_id => p_offer_discount_line_id);
      EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            null;
      END;

OZF_Offer_Adj_Line_PVT.debug_message('Done deleting children');

      BEGIN
      OZF_DISC_LINE_PKG.Delete_Row(
                                    p_offer_discount_line_id  => p_offer_discount_line_id,
                                    p_object_version_number  => p_object_version_number
                                 );
      END;
OZF_Offer_Adj_Line_PVT.debug_message('Done deleting');


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_vo_discount_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_vo_discount_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_vo_discount_PVT;
     OZF_Offer_Adj_Line_PVT.debug_message(SUBSTR(SQLERRM, 1, 100));
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

END Delete_vo_discount;


PROCEDURE copy_vo_discounts
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_discount_line_id        IN   NUMBER ,
    p_vo_disc_rec                IN vo_disc_rec_type,
    x_vo_discount_line_id        OUT NOCOPY  NUMBER
)
IS
CURSOR c_pbh_discount(p_offer_discount_line_id NUMBER) is
SELECT a.offer_id
, a.tier_type
, a.volume_type
, a.volume_break_type
, a.discount_type
, a.start_date_active
, a.end_date_active
, a.uom_code
, tl.discount_table_name
, tl.description
, a.tier_level
FROM OZF_OFFER_DISCOUNT_LINES a, ozf_offr_disc_struct_name_b b, ozf_offr_disc_struct_name_tl tl
WHERE a.offer_discount_line_id = b.offer_discount_line_id
AND b.offr_disc_struct_name_id = tl.offr_disc_struct_name_id
AND tl.language = userenv('LANG')
AND a.offer_discount_line_id = p_offer_discount_line_id;

l_pbh_discount c_pbh_discount%rowtype;

CURSOR c_dis_discount(p_offer_discount_line_id NUMBER) IS
SELECT offer_id
, tier_type
, volume_from
, volume_to
, volume_operator
, volume_break_type
, discount
, start_date_active
, end_date_active
, formula_id
, tier_level
FROM ozf_offer_discount_lines
WHERE parent_discount_line_id = p_offer_discount_line_id;



l_api_name                  CONSTANT VARCHAR2(30) := 'copy_vo_discounts';
l_api_version_number        CONSTANT NUMBER   := 1.0;

l_vo_dis_rec           vo_disc_rec_type;
l_vo_pbh_rec           vo_disc_rec_type;


l_vo_id NUMBER;
l_vo_discount_line_id NUMBER;

CURSOR c_get_vo_disc_line(p_offer_discount_line_id NUMBER, p_object_version_number NUMBER) IS
    SELECT *
    FROM  OZF_OFFER_DISCOUNT_LINES
    WHERE  offer_discount_line_id = p_offer_discount_line_id
    AND object_version_number = p_object_version_number;
    -- Hint: Developer need to provide Where clause
l_get_vo_disc_line c_get_vo_disc_line%ROWTYPE;
-- Local Variables
l_offer_discount_line_id    NUMBER;

BEGIN

      SAVEPOINT copy_vo_discounts_pvt;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    OZF_Offer_Adj_Line_PVT.debug_message('OfferDiscountLineId is : '||p_discount_line_id);


      OPEN c_get_vo_disc_line( p_vo_disc_rec.offer_discount_line_id,p_vo_disc_rec.object_version_number);
          FETCH c_get_vo_disc_line INTO l_get_vo_disc_line  ;
       If ( c_get_vo_disc_line%NOTFOUND) THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'DISCOUNT LINE') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE     c_get_vo_disc_line;

      If (p_vo_disc_rec.object_version_number is NULL or
          p_vo_disc_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING'
                                           , p_token_name   => 'COLUMN'
                                           , p_token_value  => 'Last_Update_Date') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (p_vo_disc_rec.object_version_number <> l_get_vo_disc_line.object_version_number) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'DISCOUNT LINE') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;


OPEN c_pbh_discount(p_discount_line_id) ;
FETCH c_pbh_discount INTO l_pbh_discount ;
IF c_pbh_discount%FOUND THEN
    OZF_Offer_Adj_Line_PVT.debug_message('offerId 2 is : '||l_pbh_discount.offer_id);
    CLOSE c_pbh_discount ;

    l_vo_pbh_rec.offer_id := l_pbh_discount.offer_id;
    l_vo_pbh_rec.volume_type := l_pbh_discount.volume_type;
    l_vo_pbh_rec.volume_break_type := 'POINT';

    l_vo_pbh_rec.discount_type := l_pbh_discount.discount_type;
    l_vo_pbh_rec.tier_type := 'PBH';
    l_vo_pbh_rec.tier_level := 'HEADER';
    l_vo_pbh_rec.uom_code := l_pbh_discount.uom_code;
    l_vo_pbh_rec.start_date_active := l_pbh_discount.start_date_active;
    l_vo_pbh_rec.end_date_active := l_pbh_discount.end_date_active;
    l_vo_pbh_rec.name := p_vo_disc_rec.name;
    --l_vo_pbh_rec.description := l_pbh_discount.description;

    OZF_Offer_Adj_Line_PVT.debug_message('Offer id1 is :'|| l_vo_pbh_rec.offer_id);

    Create_vo_discount(
        p_api_version_number => p_api_version_number
        , p_init_msg_list  => p_init_msg_list
        , p_commit         => p_commit
        , p_validation_level => p_validation_level
        , x_return_status    => x_return_status
        , x_msg_count        => x_msg_count
        , x_msg_data         => x_msg_data
        , p_vo_disc_rec      => l_vo_pbh_rec
        , x_vo_discount_line_id => x_vo_discount_line_id
    );

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

    OZF_Offer_Adj_Line_PVT.debug_message('discount line id1 is :'||p_discount_line_id);
    FOR l_dis_discount IN c_dis_discount(p_discount_line_id) LOOP
            l_vo_dis_rec.offer_id := l_dis_discount.offer_id;
            l_vo_dis_rec.parent_discount_line_id := x_vo_discount_line_id;
            l_vo_dis_rec.volume_from := l_dis_discount.volume_from;
            l_vo_dis_rec.volume_to := l_dis_discount.volume_to;
            l_vo_dis_rec.volume_operator := l_dis_discount.volume_operator;
            l_vo_dis_rec.discount := l_dis_discount.discount;
            l_vo_dis_rec.tier_type := 'DIS';
            l_vo_dis_rec.tier_level := 'HEADER';
            l_vo_dis_rec.formula_id := l_dis_discount.formula_id;
            Create_vo_discount(
                p_api_version_number => p_api_version_number
                , p_init_msg_list  => p_init_msg_list
                , p_commit         => p_commit
                , p_validation_level => p_validation_level
                , x_return_status    => x_return_status
                , x_msg_count        => x_msg_count
                , x_msg_data         => x_msg_data
                , p_vo_disc_rec      => l_vo_dis_rec
                , x_vo_discount_line_id => l_vo_id
            );
     END LOOP;
ELSE
        OZF_Offer_Adj_Line_PVT.debug_message('PBH not found');
        CLOSE c_pbh_discount;
END IF;
OZF_Offer_Adj_Line_PVT.debug_message('New Discount line id is  :'|| x_vo_discount_line_id);


      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO copy_vo_discounts_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO copy_vo_discounts_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO copy_vo_discounts_pvt;
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
END copy_vo_discounts;
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_vo_discount
--   Type
--           Private
--   Pre-Req
--             Create_Ozf_Disc_Line,Create Product
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_vo_disc_rec      IN   vo_disc_rec_type   Required Record containing Discount Line Data
--       p_ozf_prod_rec            IN   ozf_prod_rec_type   Required Record containing Product Data
--   OUT NOCOPY
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--       x_offer_discount_line_id  OUT NOCOPY  NUMBER. Discount Line Id of Discount Line Created
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Method to Create New Discount Lines.
--   End of Comments
--   ==============================================================================

PROCEDURE Create_vo_discount(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_vo_disc_rec           IN   vo_disc_rec_type  ,
    x_vo_discount_line_id        OUT NOCOPY  NUMBER
)
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_vo_discount';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_vo_discount_rec           vo_disc_rec_type;
l_vo_discount_line_id NUMBER;
l_object_version_number NUMBER;
l_dummy NUMBER;
   CURSOR c_id IS
      SELECT ozf_offer_discount_lines_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_OFFER_DISCOUNT_LINES
      WHERE offer_discount_line_id = l_id;

   CURSOR c_struct_id IS
      SELECT ozf_offr_disc_struct_name_s.NEXTVAL
      FROM dual;

   CURSOR c_struct_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM ozf_offr_disc_struct_name_b
      WHERE OFFR_DISC_STRUCT_NAME_ID = l_id;
l_struct_object_version NUMBER;
l_offr_disc_struct_name_id NUMBER;
l_struct_dummy NUMBER;
BEGIN
--initialize
      -- Standard Start of API savepoint
      SAVEPOINT Create_vo_discount_pvt;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

l_vo_discount_rec := p_vo_disc_rec;


   IF p_vo_disc_rec.offer_discount_line_id IS NULL OR p_vo_disc_rec.offer_discount_line_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_vo_discount_line_id;
         CLOSE c_id;

         OPEN c_id_exists(l_vo_discount_line_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_vo_discount_line_id := p_vo_disc_rec.offer_discount_line_id;
   END IF;


   IF p_vo_disc_rec.offr_disc_struct_name_id IS NULL OR p_vo_disc_rec.offr_disc_struct_name_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_struct_id;
         FETCH c_struct_id INTO l_offr_disc_struct_name_id;
         CLOSE c_struct_id;
        OZF_Offer_Adj_Line_PVT.debug_message('disc struct id is :'|| l_offr_disc_struct_name_id);
         OPEN c_struct_id_exists(l_offr_disc_struct_name_id);
         FETCH c_struct_id_exists INTO l_struct_dummy;
         CLOSE c_struct_id_exists;
         EXIT WHEN l_struct_dummy IS NULL;
      END LOOP;
   ELSE
         l_offr_disc_struct_name_id := p_vo_disc_rec.offr_disc_struct_name_id;
   END IF;




l_vo_discount_rec.offer_discount_line_id := l_vo_discount_line_id ;

l_vo_discount_rec.offr_disc_struct_name_id := l_offr_disc_struct_name_id ;


 OZF_Offer_Adj_Line_PVT.debug_message('Calling Validate Discounts: Return Status is :' || x_return_status );


-- validate discounts
Validate_vo_discounts(
    p_api_version_number         => p_api_version_number
    , p_init_msg_list            => p_init_msg_list
    , p_validation_level         => p_validation_level
    , px_vo_disc_rec             => l_vo_discount_rec
    , p_validation_mode          => JTF_PLSQL_API.g_create
    , x_return_status            => x_return_status
    , x_msg_count                => x_msg_count
    , x_msg_data                 => x_msg_data
    );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
-- create discounts
      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message( 'Private API: Calling create table handler');
      -- Invoke table handler(OZF_DISC_LINE_PKG.Insert_Row)
      OZF_DISC_LINE_PKG.Insert_Row(
          px_offer_discount_line_id  => l_vo_discount_line_id,
          p_parent_discount_line_id  => l_vo_discount_rec.parent_discount_line_id,
          p_volume_from  => l_vo_discount_rec.volume_from,
          p_volume_to  => l_vo_discount_rec.volume_to,
          p_volume_operator  => l_vo_discount_rec.volume_operator,
          p_volume_type  => l_vo_discount_rec.volume_type,
          p_volume_break_type  => l_vo_discount_rec.volume_break_type,
          p_discount  => l_vo_discount_rec.discount,
          p_discount_type  => l_vo_discount_rec.discount_type,
          p_tier_type  => l_vo_discount_rec.tier_type,
          p_tier_level  => l_vo_discount_rec.tier_level,
          p_incompatibility_group  => l_vo_discount_rec.incompatibility_group,
          p_precedence  => l_vo_discount_rec.precedence,
          p_bucket  => l_vo_discount_rec.bucket,
          p_scan_value  => l_vo_discount_rec.scan_value,
          p_scan_data_quantity  => l_vo_discount_rec.scan_data_quantity,
          p_scan_unit_forecast  => l_vo_discount_rec.scan_unit_forecast,
          p_channel_id  => l_vo_discount_rec.channel_id,
          p_adjustment_flag  => l_vo_discount_rec.adjustment_flag,
          p_start_date_active  => l_vo_discount_rec.start_date_active,
          p_end_date_active  => l_vo_discount_rec.end_date_active,
          p_uom_code  => l_vo_discount_rec.uom_code,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number,
          p_offer_id  => l_vo_discount_rec.offer_id,
           p_context     => l_vo_discount_rec.context,
           p_attribute1  => l_vo_discount_rec.attribute1,
           p_attribute2  => l_vo_discount_rec.attribute2,
           p_attribute3  => l_vo_discount_rec.attribute3,
           p_attribute4  => l_vo_discount_rec.attribute4,
           p_attribute5  => l_vo_discount_rec.attribute5,
           p_attribute6  => l_vo_discount_rec.attribute6,
           p_attribute7  => l_vo_discount_rec.attribute7,
           p_attribute8  => l_vo_discount_rec.attribute8,
           p_attribute9  => l_vo_discount_rec.attribute9,
           p_attribute10 => l_vo_discount_rec.attribute10,
           p_attribute11 => l_vo_discount_rec.attribute11,
           p_attribute12 => l_vo_discount_rec.attribute12,
           p_attribute13 => l_vo_discount_rec.attribute13,
           p_attribute14 => l_vo_discount_rec.attribute14,
           p_attribute15 => l_vo_discount_rec.attribute15,
          p_formula_id  => l_vo_discount_rec.formula_id
);
          x_vo_discount_line_id := l_vo_discount_line_id ;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

IF l_vo_discount_rec.tier_type = 'PBH' THEN -- create tier names only for pbh tiers
    OZF_VO_DISC_STRUCT_NAME_PKG.Insert_Row(
    px_offr_disc_struct_name_id => l_offr_disc_struct_name_id
    , p_offer_discount_line_id => x_vo_discount_line_id
    , p_creation_date           => SYSDATE
    , p_created_by              => FND_GLOBAL.USER_ID
    , p_last_updated_by         => FND_GLOBAL.USER_ID
    , p_last_update_date        => SYSDATE
    , p_last_update_login       => FND_GLOBAL.conc_login_id
    , p_name                    => l_vo_discount_rec.name
    , p_description             => l_vo_discount_rec.description
    , px_object_version_number  => l_struct_object_version
    );

END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_vo_discount_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_vo_discount_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_vo_discount_pvt;
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
END Create_vo_discount;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_vo_discount
--   Type
--           Private
--   Pre-Req
--             Create_Ozf_Disc_Line,Create Product
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_discount_line_rec   IN   ozf_discount_line_rec_type Required Record Containing Discount Line Data
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Method to Update Discount Lines.
--   End of Comments
--   ==============================================================================
PROCEDURE Update_vo_discount(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_vo_disc_rec           IN   vo_disc_rec_type
)IS

CURSOR c_get_vo_disc_line(p_offer_discount_line_id NUMBER, p_object_version_number NUMBER) IS
    SELECT *
    FROM  OZF_OFFER_DISCOUNT_LINES
    WHERE  offer_discount_line_id = p_offer_discount_line_id
    AND object_version_number = p_object_version_number;
    -- Hint: Developer need to provide Where clause

l_api_name                  CONSTANT VARCHAR2(30) := 'Update_vo_discount';
l_api_version_number        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_offer_discount_line_id    NUMBER;
l_ref_vo_disc_line_rec  c_get_vo_disc_line%ROWTYPE ;
l_tar_vo_disc_line_rec  vo_disc_rec_type := p_vo_disc_rec ;
l_rowid  ROWID;
l_struct_object_version NUMBER;
l_offr_disc_struct_name_id NUMBER;
l_tier_type OZF_OFFER_DISCOUNT_LINES.TIER_TYPE%TYPE;
BEGIN
--initialize
      -- Standard Start of API savepoint
      SAVEPOINT update_ozf_disc_line_pvt;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;
      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: - Open Cursor to Select');
      OZF_Offer_Adj_Line_PVT.debug_message('INputs : '|| l_tar_vo_disc_line_rec.offer_discount_line_id || ' : ' || l_tar_vo_disc_line_rec.object_version_number);
      OPEN c_get_vo_disc_line( l_tar_vo_disc_line_rec.offer_discount_line_id,l_tar_vo_disc_line_rec.object_version_number);
          FETCH c_get_vo_disc_line INTO l_ref_vo_disc_line_rec  ;
       If ( c_get_vo_disc_line%NOTFOUND) THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'Ozf_Disc_Line') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE     c_get_vo_disc_line;

      If (l_tar_vo_disc_line_rec.object_version_number is NULL or
          l_tar_vo_disc_line_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING'
                                           , p_token_name   => 'COLUMN'
                                           , p_token_value  => 'Last_Update_Date') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_vo_disc_line_rec.object_version_number <> l_ref_vo_disc_line_rec.object_version_number) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'Ozf_Disc_Line') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_Offer_Adj_Line_PVT.debug_message('Private API: Validate_vo_discounts');
-- validate data
            Validate_vo_discounts(
                p_api_version_number         => p_api_version_number
                , p_init_msg_list            => p_init_msg_list
                , p_validation_level         => p_validation_level
                , px_vo_disc_rec             => l_tar_vo_disc_line_rec
                , p_validation_mode          => JTF_PLSQL_API.g_update
                , x_return_status            => x_return_status
                , x_msg_count                => x_msg_count
                , x_msg_data                 => x_msg_data
                );
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--update  data in table
      OZF_DISC_LINE_PKG.Update_Row(
          p_offer_discount_line_id  => l_tar_vo_disc_line_rec.offer_discount_line_id,
          p_parent_discount_line_id  => l_tar_vo_disc_line_rec.parent_discount_line_id,
          p_volume_from  => l_tar_vo_disc_line_rec.volume_from,
          p_volume_to  => l_tar_vo_disc_line_rec.volume_to,
          p_volume_operator  => l_tar_vo_disc_line_rec.volume_operator,
          p_volume_type  => l_tar_vo_disc_line_rec.volume_type,
          p_volume_break_type  => l_tar_vo_disc_line_rec.volume_break_type,
          p_discount  => l_tar_vo_disc_line_rec.discount,
          p_discount_type  => l_tar_vo_disc_line_rec.discount_type,
          p_tier_type  => l_tar_vo_disc_line_rec.tier_type,
          p_tier_level  => l_tar_vo_disc_line_rec.tier_level,
          p_incompatibility_group  => l_tar_vo_disc_line_rec.incompatibility_group,
          p_precedence  => l_tar_vo_disc_line_rec.precedence,
          p_bucket  => l_tar_vo_disc_line_rec.bucket,
          p_scan_value  => l_tar_vo_disc_line_rec.scan_value,
          p_scan_data_quantity  => l_tar_vo_disc_line_rec.scan_data_quantity,
          p_scan_unit_forecast  => l_tar_vo_disc_line_rec.scan_unit_forecast,
          p_channel_id  => l_tar_vo_disc_line_rec.channel_id,
          p_adjustment_flag  => l_tar_vo_disc_line_rec.adjustment_flag,
          p_start_date_active  => l_tar_vo_disc_line_rec.start_date_active,
          p_end_date_active  => l_tar_vo_disc_line_rec.end_date_active,
          p_uom_code  => l_tar_vo_disc_line_rec.uom_code,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number  => l_tar_vo_disc_line_rec.object_version_number,
           p_context     => l_tar_vo_disc_line_rec.context,
           p_attribute1  => l_tar_vo_disc_line_rec.attribute1,
           p_attribute2  => l_tar_vo_disc_line_rec.attribute2,
           p_attribute3  => l_tar_vo_disc_line_rec.attribute3,
           p_attribute4  => l_tar_vo_disc_line_rec.attribute4,
           p_attribute5  => l_tar_vo_disc_line_rec.attribute5,
           p_attribute6  => l_tar_vo_disc_line_rec.attribute6,
           p_attribute7  => l_tar_vo_disc_line_rec.attribute7,
           p_attribute8  => l_tar_vo_disc_line_rec.attribute8,
           p_attribute9  => l_tar_vo_disc_line_rec.attribute9,
           p_attribute10 => l_tar_vo_disc_line_rec.attribute10,
           p_attribute11 => l_tar_vo_disc_line_rec.attribute11,
           p_attribute12 => l_tar_vo_disc_line_rec.attribute12,
           p_attribute13 => l_tar_vo_disc_line_rec.attribute13,
           p_attribute14 => l_tar_vo_disc_line_rec.attribute14,
           p_attribute15 => l_tar_vo_disc_line_rec.attribute15,
          p_offer_id  => l_tar_vo_disc_line_rec.offer_id,
          p_formula_id => l_tar_vo_disc_line_rec.formula_id
);

SELECT tier_type into l_tier_type FROM ozf_offer_discount_lines
WHERE offer_discount_line_id = p_vo_disc_rec.offer_discount_line_id;

IF l_tier_type = 'PBH' THEN
    SELECT object_version_number, offr_disc_struct_name_id into l_struct_object_version , l_offr_disc_struct_name_id
    FROM ozf_offr_disc_struct_name_b
    WHERE offer_discount_line_id = p_vo_disc_rec.offer_discount_line_id;

    OZF_VO_DISC_STRUCT_NAME_PKG.Update_Row(
    p_offr_disc_struct_name_id => l_offr_disc_struct_name_id
    , p_offer_discount_line_id  => p_vo_disc_rec.offer_discount_line_id
    , p_last_updated_by         => FND_GLOBAL.USER_ID
    , p_last_update_date        => SYSDATE
    , p_last_update_login       => FND_GLOBAL.conc_login_id
    , p_name                    => p_vo_disc_rec.name
    , p_description             => p_vo_disc_rec.description
    , px_object_version_number  => l_struct_object_version
    );
END IF;
      --
      -- End of API body.
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
-- exception handling
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Ozf_Disc_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ozf_Disc_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ozf_Disc_Line_PVT;
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
END Update_vo_discount;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_product_Uk_Items
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_validation_mode            IN   VARCHAR2
--    p_vo_disc_rec         IN    vo_disc_rec_type
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE check_vo_product_Uk_Items(
     p_vo_prod_rec              IN  vo_prod_rec_type
    , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
    , x_return_status              OUT NOCOPY  VARCHAR2
    )
    IS
l_valid_flag  VARCHAR2(1);
l_api_name CONSTANT VARCHAR2(30) := 'check_vo_product_Uk_Items';
BEGIN
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND (p_vo_prod_rec.off_discount_product_id IS NOT NULL AND p_vo_prod_rec.off_discount_product_id <> FND_API.g_miss_num)
      THEN
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'ozf_offer_discount_products',
         'OFF_DISCOUNT_PRODUCT_ID = ''' || p_vo_prod_rec.off_discount_product_id ||''''
         );
         OZF_Offer_Adj_Line_PVT.debug_message('Off Discount Product Id is '||p_vo_prod_rec.off_discount_product_id);
          IF l_valid_flag = FND_API.g_false THEN
             OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_PROD_LINE_ID_DUP');
             x_return_status := FND_API.g_ret_sts_error;
             return;
          END IF;
      END IF;

declare
l_attr varchar2(500) := 'product_attribute = ''' || p_vo_prod_rec.product_attribute ||''' AND product_attr_value = '''|| p_vo_prod_rec.product_attr_value ;
l_attr2 varchar2(500):= ''' AND apply_discount_flag  = '''||p_vo_prod_rec.apply_discount_flag  || ''' AND offer_id = '|| p_vo_prod_rec.offer_id;
begin
      IF (p_vo_prod_rec.product_attr_value IS NOT NULL AND p_vo_prod_rec.product_attr_value <> FND_API.g_miss_char) THEN

                 l_valid_flag := OZF_Utility_PVT.check_uniqueness(
                 'ozf_offer_discount_products',
                 l_attr || l_attr2
                 );
                OZF_Offer_Adj_Line_PVT.debug_message('Valid Flag for duplicate products is:'||l_valid_flag);
              IF  l_valid_flag = FND_API.g_false THEN
                     OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_VO_PROD_DUP');
                     x_return_status := FND_API.g_ret_sts_error;
                     return;
              END IF;

      END IF;
end;
    END check_vo_product_Uk_Items;


   -- Check Items Foreign Keys API calls

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_product_req_items
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_validation_mode            IN   VARCHAR2
--    p_vo_disc_rec         IN    vo_disc_rec_type
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE check_vo_product_req_items(
     p_vo_prod_rec              IN  vo_prod_rec_type
    , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
    , x_return_status              OUT NOCOPY  VARCHAR2
    )
    IS
l_api_name CONSTANT VARCHAR2(30) := 'check_vo_product_req_items';
BEGIN
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');
      OZF_Offer_Adj_Line_PVT.debug_message('Validation Mode is : ' || p_validation_mode || ' '|| JTF_PLSQL_API.g_create);
      x_return_status := FND_API.g_ret_sts_success;
       IF p_validation_mode = JTF_PLSQL_API.g_create THEN
          IF p_vo_prod_rec.off_discount_product_id = FND_API.G_MISS_NUM OR p_vo_prod_rec.off_discount_product_id IS NULL THEN
                   OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'off_discount_product_id' );
                   x_return_status := FND_API.g_ret_sts_error;
                   return;
          END IF;

      IF p_vo_prod_rec.offer_discount_line_id = FND_API.G_MISS_NUM OR p_vo_prod_rec.offer_discount_line_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_DISCOUNT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_vo_prod_rec.offer_id = FND_API.G_MISS_NUM OR p_vo_prod_rec.offer_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_vo_prod_rec.product_context = FND_API.G_MISS_CHAR OR p_vo_prod_rec.product_context IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'PRODUCT_CONTEXT' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_vo_prod_rec.product_attr_value = FND_API.G_MISS_CHAR OR p_vo_prod_rec.product_attr_value IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_NAME') );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_vo_prod_rec.product_attribute = FND_API.G_MISS_CHAR OR p_vo_prod_rec.product_attribute IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_PROD_LEVEL') );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_vo_prod_rec.apply_discount_flag = FND_API.G_MISS_CHAR OR p_vo_prod_rec.apply_discount_flag IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_OFFR_APPLY_DISC') );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_vo_prod_rec.include_volume_flag = FND_API.G_MISS_CHAR OR p_vo_prod_rec.include_volume_flag IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_OFFR_INCL_VOL') );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

   ELSE
OZF_Offer_Adj_Line_PVT.debug_message('In Update Mode');
          IF p_vo_prod_rec.off_discount_product_id = FND_API.G_MISS_NUM THEN
                   OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'off_discount_product_id' );
                   x_return_status := FND_API.g_ret_sts_error;
                   return;
          END IF;

      IF p_vo_prod_rec.offer_discount_line_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_DISCOUNT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;
OZF_Offer_Adj_Line_PVT.debug_message('OFFER_ID IS '||p_vo_prod_rec.offer_id);
      IF p_vo_prod_rec.offer_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

END IF;

        IF p_vo_prod_rec.offer_discount_line_id = -1 THEN
                    OZF_Utility_PVT.Error_Message('OZF_DIS_LINE_NO_PARENT' );
                    x_return_status := FND_API.g_ret_sts_error;
                    return;
        END IF;

    END check_vo_product_req_items;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_product_FK_items
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_validation_mode            IN   VARCHAR2
--    p_vo_disc_rec         IN    vo_disc_rec_type
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE check_vo_product_FK_items(
     p_vo_prod_rec              IN  vo_prod_rec_type
    , x_return_status              OUT NOCOPY  VARCHAR2
    )
IS
l_api_name CONSTANT VARCHAR2(30) := 'check_vo_product_FK_items';
BEGIN
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_vo_prod_rec.offer_id IS NOT NULL AND p_vo_prod_rec.offer_id  <> FND_API.G_MISS_NUM
    THEN
        IF ozf_utility_pvt.check_fk_exists('OZF_OFFERS','OFFER_ID',to_char(p_vo_prod_rec.offer_id)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_OFFER_ID' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
    END IF;
      OZF_Offer_Adj_Line_PVT.debug_message('Offer Discount LIne Id is: ' || p_vo_prod_rec.offer_discount_line_id || 'end');
    IF p_vo_prod_rec.offer_discount_line_id IS NOT NULL AND p_vo_prod_rec.offer_discount_line_id  <> FND_API.G_MISS_NUM
    THEN
        IF ozf_utility_pvt.check_fk_exists('OZF_OFFER_DISCOUNT_LINES','OFFER_DISCOUNT_LINE_ID',to_char(p_vo_prod_rec.offer_discount_line_id)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_DISCOUNT_ID' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
    END IF;
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');
END check_vo_product_FK_items;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_product_Lkup_Items
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_validation_mode            IN   VARCHAR2
--    p_vo_disc_rec         IN    vo_disc_rec_type
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Fri May 06 2005:6/32 PM  RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================
PROCEDURE check_vo_product_Lkup_Items(
     p_vo_prod_rec              IN  vo_prod_rec_type
    , x_return_status              OUT NOCOPY  VARCHAR2
    )
    IS
    CURSOR C_UOM_CODE_EXISTS  (p_uom_code VARCHAR2,p_organization_id NUMBER,p_inventory_item_id NUMBER)
    IS
        SELECT 1 FROM mtl_item_uoms_view
        WHERE  organization_id = p_organization_id
        AND uom_code =  p_uom_code
        AND inventory_item_id =  p_inventory_item_id;

    l_organization_id NUMBER := -999;
    l_UOM_CODE_EXISTS C_UOM_CODE_EXISTS%ROWTYPE;

    CURSOR c_uom_code(p_discount_line_id NUMBER)
    IS
    SELECT uom_code , volume_type, offer_id
    FROM ozf_offer_discount_lines
    WHERE offer_discount_line_id = p_discount_line_id;

    l_uom_code c_uom_code%rowtype;

    CURSOR c_general_uom(p_uom_code VARCHAR2)
    IS
    SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1
                                    FROM mtl_units_of_measure_vl
                                    WHERE uom_code =  p_uom_code);
    l_general_uom c_general_uom%rowtype;
    l_list_header_id NUMBER;
    l_api_name CONSTANT VARCHAR2(30) := 'check_vo_product_Lkup_Items';
BEGIN
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
--=====================================================================
-- uom validation begin
--=====================================================================
    OPEN c_uom_code(p_vo_prod_rec.offer_discount_line_id);

        FETCH  c_uom_code INTO l_uom_code;

       IF ( c_uom_code%NOTFOUND) THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_INVALID_DISCOUNT_ID') ;
           x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    CLOSE c_uom_code;

    IF l_uom_code.volume_type = 'PRICING_ATTRIBUTE10' THEN

    l_organization_id := QP_UTIL.Get_Item_Validation_Org;

        IF(p_vo_prod_rec.product_attribute = 'PRICING_ATTRIBUTE1') THEN

        OPEN c_uom_code_exists(l_uom_code.uom_code,l_organization_id,p_vo_prod_rec.product_attr_value);

            FETCH c_uom_code_exists INTO l_uom_code_exists;

           IF ( c_uom_code_exists%NOTFOUND) THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                   FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
                   FND_MSG_PUB.add;
                   x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
            END IF;
       CLOSE c_uom_code_exists;

        ELSIF(p_vo_prod_rec.product_attribute = 'PRICING_ATTRIBUTE2') THEN
/*
            IF QP_CATEGORY_MAPPING_RULE.Validate_UOM(
              l_organization_id,
              to_number(p_vo_prod_rec.product_attr_value),
              l_uom_code.uom_code) = 'N'
*/
            select qp_list_header_id into l_list_header_id from ozf_offers where offer_id = l_uom_code.offer_id;
            IF NOT QP_Validate.Product_Uom (
              l_uom_code.uom_code,
              to_number(p_vo_prod_rec.product_attr_value),
              l_list_header_id)
           THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
             FND_MSG_PUB.add;
             x_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
            END IF;
        ELSE
            OPEN c_general_uom(l_uom_code.uom_code);
            FETCH c_general_uom INTO l_general_uom;
               IF ( c_general_uom%NOTFOUND) THEN
                   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                       FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
                       FND_MSG_PUB.add;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;
                END IF;
             CLOSE c_general_uom;
        END IF;
--===========================================================================
--  uom validation end
--===========================================================================

    END IF;

      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');

    END check_vo_product_Lkup_Items;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_product_attr
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_validation_mode            IN   VARCHAR2
--    p_vo_disc_rec         IN    vo_disc_rec_type
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Mon May 16 2005:5/41 PM RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE check_vo_product_attr(
     p_vo_prod_rec              IN  vo_prod_rec_type
    , x_return_status              OUT NOCOPY  VARCHAR2
      )
      IS
l_api_name CONSTANT VARCHAR2(30) := 'check_vo_product_attr';
l_context_flag                VARCHAR2(1);
l_attribute_flag              VARCHAR2(1);
l_value_flag                  VARCHAR2(1);
l_datatype                    VARCHAR2(1);
l_precedence                  NUMBER;
l_error_code                  NUMBER := 0;
BEGIN
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');
      x_return_status := FND_API.G_RET_STS_SUCCESS;



       QP_UTIL.validate_qp_flexfield(flexfield_name                  =>'QP_ATTR_DEFNS_PRICING'
                                     ,context                        =>p_vo_prod_rec.product_context
                                     ,attribute                      =>p_vo_prod_rec.product_attribute
                                     ,value                          =>p_vo_prod_rec.product_attr_value
                                     ,application_short_name         => 'QP'
                                     ,context_flag                   =>l_context_flag
                                     ,attribute_flag                 =>l_attribute_flag
                                     ,value_flag                     =>l_value_flag
                                     ,datatype                       =>l_datatype
                                     ,precedence                     =>l_precedence
                                     ,error_code                     =>l_error_code
                                     );
       If (l_context_flag = 'N'  AND l_error_code = 7)       --  invalid context
      Then
          x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_CONTEXT'  );
               FND_MSG_PUB.add;
            END IF;
       End If;

       If (l_attribute_flag = 'N'  AND l_error_code = 8)       --  invalid attribute
      Then
          x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_ATTR'  );
               FND_MSG_PUB.add;
            END IF;
       End If;

       If (l_value_flag = 'N'  AND l_error_code = 9)       --  invalid value
      Then
          x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_VALUE'  );
               FND_MSG_PUB.add;
            END IF;
       End If;



      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END check_vo_product_attr;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           check_vo_product_attr
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_validation_mode            IN   VARCHAR2
--    p_vo_disc_rec         IN    vo_disc_rec_type
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Mon May 16 2005:5/41 PM RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE check_vo_product_inter_attr(
     p_vo_prod_rec              IN  vo_prod_rec_type
    , x_return_status              OUT NOCOPY  VARCHAR2
      )
      IS
l_api_name CONSTANT VARCHAR2(30) := 'check_vo_product_inter_attr';
BEGIN
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END check_vo_product_inter_attr;

PROCEDURE check_vo_product_entity_attr(
     p_vo_prod_rec              IN  vo_prod_rec_type
    , x_return_status              OUT NOCOPY  VARCHAR2
      )
      IS
      CURSOR c_discount_volume_type(p_offer_discount_line_id NUMBER) IS
      SELECT volume_type FROM ozf_offer_discount_lines
      WHERE offer_discount_line_id = p_offer_discount_line_id;

      l_discount_volume_type c_discount_volume_type%rowtype;

l_api_name CONSTANT VARCHAR2(30) := 'check_vo_product_entity_attr';
BEGIN
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END check_vo_product_entity_attr;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Check_vo_product_Items
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_validation_mode            IN   VARCHAR2
--    p_vo_disc_rec         IN    vo_disc_rec_type
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Mon May 16 2005:5/41 PM RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================
PROCEDURE Check_vo_product_Items(
     p_vo_prod_rec              IN  vo_prod_rec_type
    , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
    , x_return_status              OUT NOCOPY  VARCHAR2
              )
IS
   l_api_name CONSTANT VARCHAR2(30) := 'Check_vo_Product_Items';
BEGIN
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_vo_product_req_items(
      p_vo_prod_rec => p_vo_prod_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Check Items Uniqueness API calls
   check_vo_product_Uk_Items(
      p_vo_prod_rec => p_vo_prod_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   check_vo_product_attr(
      p_vo_prod_rec => p_vo_prod_rec,
      x_return_status => x_return_status
      );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


   -- Check Items Foreign Keys API calls

   check_vo_product_FK_items(
      p_vo_prod_rec => p_vo_prod_rec,
      x_return_status => x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Check Items Lookups

   check_vo_product_Lkup_Items(
      p_vo_prod_rec => p_vo_prod_rec,
      x_return_status => x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;



check_vo_product_inter_attr(
      p_vo_prod_rec => p_vo_prod_rec,
      x_return_status => x_return_status
      );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

check_vo_product_entity_attr(
      p_vo_prod_rec => p_vo_prod_rec,
      x_return_status => x_return_status
      );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');
END Check_vo_product_Items;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_vo_products
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_api_version_number         IN   NUMBER
--    p_init_msg_list            IN   VARCHAR2
--    p_validation_level           IN   NUMBER
--    p_vo_prod_rec              IN  vo_prod_rec_type
--    p_validation_mode          IN VARCHAR2
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--    x_msg_count                  OUT NOCOPY  NUMBER
--    x_msg_data                   OUT NOCOPY  VARCHAR2

--   Version : Current version 1.0
--
--   History
--            Mon May 16 2005:5/41 PM RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE Validate_vo_products(
    p_api_version_number         IN   NUMBER
    , p_init_msg_list            IN   VARCHAR2     := FND_API.G_FALSE
    , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    , p_vo_prod_rec              IN  vo_prod_rec_type
    , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
    , x_return_status              OUT NOCOPY  VARCHAR2
    , x_msg_count                  OUT NOCOPY  NUMBER
    , x_msg_data                   OUT NOCOPY  VARCHAR2
    )
    IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_vo_products';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_vo_prod_rec               vo_prod_rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Validate_vo_products_pvt;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'Return status is : '|| x_return_status);

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_vo_product_Items(
                 p_vo_prod_rec        => p_vo_prod_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );
              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
--      IF p_validation_mode = JTF_PLSQL_API.g_update THEN
/*      Complete_vo_discount_Rec(
         p_vo_disc_rec        => l_vo_disc_rec,
         x_complete_rec        => l_vo_disc_rec
      );
      */
--      END IF;
/*      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_vo_discounts_rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_vo_disc_rec       =>    l_vo_disc_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
 */

      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'Return status is : '|| x_return_status);

      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Validate_vo_products_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Validate_vo_products_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Validate_vo_products_pvt;
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
    END Validate_vo_products;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_vo_Product
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_api_version_number         IN   NUMBER
--    p_init_msg_list            IN   VARCHAR2
--    p_validation_level           IN   NUMBER
--    p_vo_prod_rec              IN  vo_prod_rec_type
--    p_validation_mode          IN VARCHAR2
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--    x_msg_count                  OUT NOCOPY  NUMBER
--    x_msg_data                   OUT NOCOPY  VARCHAR2

--   Version : Current version 1.0
--
--   History
--            Mon May 16 2005:5/41 PM RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE Create_vo_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_vo_prod_rec                   IN   vo_prod_rec_type  ,
    x_off_discount_product_id    OUT NOCOPY  NUMBER
     )
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_vo_Product';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_vo_prod_rec           vo_prod_rec_type;
l_vo_discount_line_id NUMBER;
l_off_discount_product_id NUMBER;
l_vo_prod_id NUMBER;
l_object_version_number NUMBER;
l_dummy NUMBER;
   CURSOR c_id IS
      SELECT ozf_offer_discount_products_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_OFFER_DISCOUNT_PRODUCTS
      WHERE OFF_DISCOUNT_PRODUCT_ID = l_id;

BEGIN
--initialize

      SAVEPOINT Create_vo_Product_pvt;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

l_vo_prod_rec := p_vo_prod_rec;



   IF p_vo_prod_rec.off_discount_product_id IS NULL OR p_vo_prod_rec.off_discount_product_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_vo_prod_id;
         CLOSE c_id;

         OPEN c_id_exists(l_vo_prod_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_vo_prod_id := p_vo_prod_rec.off_discount_product_id;
   END IF;


l_vo_prod_rec.off_discount_product_id := l_vo_prod_id ;

 OZF_Offer_Adj_Line_PVT.debug_message('Calling Validate Discounts: Return Status is :' || x_return_status );

-- validate

Validate_vo_products(
    p_api_version_number         => p_api_version_number
    , p_init_msg_list            => p_init_msg_list
    , p_validation_level         => p_validation_level
    , p_vo_prod_rec              => l_vo_prod_rec
    , p_validation_mode          => JTF_PLSQL_API.g_create
    , x_return_status            => x_return_status
    , x_msg_count                => x_msg_count
    , x_msg_data                 => x_msg_data
    );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

-- insert
      Ozf_Create_Ozf_Prod_Line_Pkg.Insert_Row(
          px_off_discount_product_id  => l_vo_prod_id,
          p_parent_off_disc_prod_id => l_vo_prod_rec.parent_off_disc_prod_id,
          p_product_level  => l_vo_prod_rec.product_level,
          p_product_id  => l_vo_prod_rec.product_id,
          p_excluder_flag  => l_vo_prod_rec.excluder_flag,
          p_uom_code  => l_vo_prod_rec.uom_code,
          p_start_date_active  => l_vo_prod_rec.start_date_active,
          p_end_date_active  => l_vo_prod_rec.end_date_active,
          p_offer_discount_line_id  => l_vo_prod_rec.offer_discount_line_id,
          p_offer_id  => l_vo_prod_rec.offer_id,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_product_context         => l_vo_prod_rec.product_context,
          p_product_attribute       => l_vo_prod_rec.product_attribute,
          p_product_attr_value      => l_vo_prod_rec.product_attr_value,
          p_apply_discount_flag     => l_vo_prod_rec.apply_discount_flag,
          p_include_volume_flag     => l_vo_prod_rec.include_volume_flag,
          px_object_version_number  => l_object_version_number
);

x_off_discount_product_id   := l_vo_prod_id;
-- exception
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_vo_Product_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_vo_Product_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_vo_Product_pvt;
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

END Create_vo_Product;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_vo_Product
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_api_version_number         IN   NUMBER
--    p_init_msg_list            IN   VARCHAR2
--    p_validation_level           IN   NUMBER
--    p_vo_prod_rec              IN  vo_prod_rec_type
--    p_validation_mode          IN VARCHAR2
--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--    x_msg_count                  OUT NOCOPY  NUMBER
--    x_msg_data                   OUT NOCOPY  VARCHAR2

--   Version : Current version 1.0
--
--   History
--            Mon May 16 2005:5/41 PM RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE Update_vo_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_vo_prod_rec                   IN   vo_prod_rec_type
    )
    IS
    CURSOR c_get_vo_prod_line(p_offer_prod_id NUMBER, p_object_version_number NUMBER) IS
    SELECT *
    FROM OZF_OFFER_DISCOUNT_PRODUCTS
    WHERE OFF_DISCOUNT_PRODUCT_ID = p_offer_prod_id
    AND object_version_number = p_object_version_number;
    -- Hint: Developer need to provide Where clause

l_api_name                  CONSTANT VARCHAR2(30) := 'Update_vo_Product';
l_api_version_number        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_offer_prod_id    NUMBER;
l_ref_vo_prod_rec  c_get_vo_prod_line%ROWTYPE ;
l_tar_vo_prod_rec  vo_prod_rec_type := p_vo_prod_rec ;
l_rowid  ROWID;

    BEGIN
    -- iniialize
          -- Standard Start of API savepoint
      SAVEPOINT update_vo_prod_pvt;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;
      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- validate
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: - Open Cursor to Select');
      OPEN c_get_vo_prod_line( l_tar_vo_prod_rec.OFF_DISCOUNT_PRODUCT_ID,l_tar_vo_prod_rec.object_version_number);
          FETCH c_get_vo_prod_line INTO l_ref_vo_prod_rec  ;
       If ( c_get_vo_prod_line%NOTFOUND) THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'VO_PRODUCT_LINE') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE     c_get_vo_prod_line;

      If (l_tar_vo_prod_rec.object_version_number is NULL or
          l_tar_vo_prod_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING'
                                           , p_token_name   => 'COLUMN'
                                           , p_token_value  => 'Last_Update_Date') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_vo_prod_rec.object_version_number <> l_ref_vo_prod_rec.object_version_number) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'VO_PRODUCT_LINE') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_Offer_Adj_Line_PVT.debug_message('Private API: Validate_vo_discounts');
-- validate data
            Validate_vo_products(
                p_api_version_number         => p_api_version_number
                , p_init_msg_list            => p_init_msg_list
                , p_validation_level         => p_validation_level
                , p_vo_prod_rec              => p_vo_prod_rec
                , p_validation_mode          => JTF_PLSQL_API.g_update
                , x_return_status            => x_return_status
                , x_msg_count                => x_msg_count
                , x_msg_data                 => x_msg_data
                );

      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    -- update
    OZF_Create_Ozf_Prod_Line_PKG.Update_Row(
                                              p_off_discount_product_id    => p_vo_prod_rec.off_discount_product_id,
                                              p_parent_off_disc_prod_id    => p_vo_prod_rec.parent_off_disc_prod_id,
                                              p_product_level              => p_vo_prod_rec.product_level,
                                              p_product_id                 => p_vo_prod_rec.product_id,
                                              p_excluder_flag              => p_vo_prod_rec.excluder_flag,
                                              p_uom_code                   => p_vo_prod_rec.uom_code,
                                              p_start_date_active          => p_vo_prod_rec.start_date_active,
                                              p_end_date_active            => p_vo_prod_rec.end_date_active,
                                              p_offer_discount_line_id     => p_vo_prod_rec.offer_discount_line_id,
                                              p_offer_id                   => p_vo_prod_rec.offer_id,
                                              p_last_update_date           => SYSDATE,
                                              p_last_updated_by            => FND_GLOBAL.USER_ID,
                                              p_last_update_login          => FND_GLOBAL.conc_login_id,
                                              p_product_context            => p_vo_prod_rec.product_context,
                                              p_product_attribute          => p_vo_prod_rec.product_attribute,
                                              p_product_attr_value         => p_vo_prod_rec.product_attr_value,
                                              p_apply_discount_flag        => p_vo_prod_rec.apply_discount_flag,
                                              p_include_volume_flag        => p_vo_prod_rec.include_volume_flag,
                                              p_object_version_number      => p_vo_prod_rec.object_version_number
                                             );
      --
      -- End of API body.
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
-- exception handling
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_vo_prod_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_vo_prod_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO update_vo_prod_pvt;
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

    END Update_vo_Product;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_vo_Product
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_api_version_number         IN   NUMBER
--    p_init_msg_list              IN   VARCHAR2
--    p_commit                     IN   VARCHAR2
--    p_validation_level           IN   NUMBER
--    p_off_discount_product_id    IN  NUMBER
--    p_object_version_number      IN   NUMBER

--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--    x_msg_count                  OUT NOCOPY  NUMBER
--    x_msg_data                   OUT NOCOPY  VARCHAR2

--   Version : Current version 1.0
--
--   History
--            Mon May 16 2005:5/41 PM RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_vo_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_off_discount_product_id    IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )
    IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_vo_Product';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_vo_Product_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Invoke table handler(OZF_Promotional_Offers_PKG.Delete_Row)
      OZF_Create_Ozf_Prod_Line_PKG.Delete_row(
                                                    p_off_discount_product_id  => p_off_discount_product_id
                                                    , p_object_version_number    => p_object_version_number
                                                  );


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_vo_Product_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_vo_Product_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_vo_Product_PVT;
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

    END Delete_vo_Product;
END OZF_Volume_Offer_disc_PVT;

/
