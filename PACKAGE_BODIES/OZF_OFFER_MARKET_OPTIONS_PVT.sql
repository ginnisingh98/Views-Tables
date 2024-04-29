--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_MARKET_OPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_MARKET_OPTIONS_PVT" AS
/* $Header: ozfvomob.pls 120.6 2005/10/11 17:52:33 rssharma noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_offer_Market_Options_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvodlb.pls';

FUNCTION get_combine_discounts(p_offer_id IN NUMBER)
RETURN VARCHAR2
IS
CURSOR c_volume_type_cnt (p_offer_id NUMBER) IS
SELECT count(distinct(volume_type)) FROM ozf_offer_discount_lines
WHERE offer_id = p_offer_id
AND tier_type = 'PBH';
l_vol_type_cnt NUMBER:=0;

CURSOR c_uom_code_cnt(p_offer_id NUMBER) IS
SELECT count(distinct(uom_code)) FROM ozf_offer_discount_lines
WHERE offer_id = p_offer_id
AND tier_type = 'PBH';
l_uom_code_cnt NUMBER := 0;

BEGIN
OPEN c_volume_type_cnt(p_offer_id);
FETCH c_volume_type_cnt INTO l_vol_type_cnt;
    IF c_volume_type_cnt%NOTFOUND THEN
        l_vol_type_cnt :=0;
    END IF;
CLOSE c_volume_type_cnt ;

IF l_vol_type_cnt > 1 THEN
RETURN 'N';
ELSE
    OPEN c_uom_code_cnt(p_offer_id);
    FETCH c_uom_code_cnt INTO l_uom_code_cnt;
    IF (c_uom_code_cnt%NOTFOUND) THEN
        l_uom_code_cnt := 0;
    END IF;
    CLOSE c_uom_code_cnt;
    IF l_uom_code_cnt > 1 THEN
        return 'N';
    ELSE
        return 'Y';
    END IF;
END IF;
END get_combine_discounts;

FUNCTION get_mo_name(p_qp_list_header_id IN NUMBER, p_qualifier_grouping_no IN NUMBER)
RETURN VARCHAR2
IS

CURSOR c_market_option_name(p_qp_list_header_id NUMBER, p_qualifier_grouping_no NUMBER) IS
SELECT  QP_QP_Form_Pricing_Attr.Get_Attribute_Value('QP_ATTR_DEFNS_QUALIFIER',qpl.qualifier_context, qpl.qualifier_attribute, qpl.qualifier_attr_value)
FROM qp_qualifiers qpl
WHERE list_header_id = p_qp_list_header_id
AND qualifier_grouping_no = p_qualifier_grouping_no
AND qualifier_context IN ('CUSTOMER', 'CUSTOMER_GROUP','TERRITORY','SOLD_BY')
and qualifier_id = (select min(qualifier_id) from qp_qualifiers WHERE list_header_id = qpl.list_header_id and qualifier_grouping_no = qpl.qualifier_grouping_no);

l_market_option_name VARCHAR2(240);

BEGIN

OPEN c_market_option_name(p_qp_list_header_id , p_qualifier_grouping_no);
    FETCH c_market_option_name INTO l_market_option_name;
    IF c_market_option_name%NOTFOUND THEN
        l_market_option_name := 'NONAME';
    END IF;
CLOSE c_market_option_name;

RETURN l_market_option_name||'...';

END get_mo_name;


PROCEDURE check_mo_uk_items(
                 p_mo_rec                     IN   vo_mo_rec_type
                , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
                , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
l_dummy NUMBER:= -1;
CURSOR c_mo_uk (p_offer_id NUMBER, p_group_number NUMBER) IS
SELECT 1 FROM dual
      WHERE EXISTS
                (SELECT 'X'
                    FROM ozf_offr_market_options
                    WHERE offer_id = p_offer_id --p_mo_rec.offer_id
                    AND group_number = p_group_number); --p_mo_rec.group_number);

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
          OZF_Volume_Offer_disc_PVT.debug_message('Market optionId is : '|| p_mo_rec.offer_market_option_id);
      IF p_validation_mode = JTF_PLSQL_API.G_CREATE THEN
      IF p_mo_rec.offer_market_option_id IS NOT NULL AND p_mo_rec.offer_market_option_id <> FND_API.G_MISS_NUM THEN
          OZF_Volume_Offer_disc_PVT.debug_message('Checking qunqieness for moid');
          IF OZF_Utility_PVT.check_uniqueness('ozf_offr_market_options','offer_market_option_id = ''' || p_mo_rec.offer_market_option_id ||'''') = FND_API.g_false THEN
             OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFF_MO_ID_DUP');
             x_return_status := FND_API.g_ret_sts_error;
          END IF;
      END IF;
      END IF;
      OZF_Volume_Offer_disc_PVT.debug_message('Val mode is : '|| p_validation_mode);
/*
    IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      OZF_Volume_Offer_disc_PVT.debug_message('Val mode is1 : '|| p_validation_mode);
      OZF_Volume_Offer_disc_PVT.debug_message('Market OPtion Id is1  '|| p_mo_rec.offer_market_option_id);
          IF (p_mo_rec.offer_id IS NOT NULL AND p_mo_rec.offer_id <> FND_API.G_MISS_NUM)
          AND (p_mo_rec.group_number IS NOT NULL AND p_mo_rec.group_number <> FND_API.G_MISS_NUM)
          THEN
          OZF_Volume_Offer_disc_PVT.debug_message('Market OPtion Id is1  '|| p_mo_rec.offer_market_option_id);
          OPEN c_mo_uk(p_mo_rec.offer_id,p_mo_rec.group_number);
          FETCH c_mo_uk INTO l_dummy;
                IF ( c_mo_uk%NOTFOUND) THEN
                     NULL;
                 ELSE
                     OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_MO_DUP');
                     x_return_status := FND_API.g_ret_sts_error;
                END IF;
        END IF;

    END IF;
    */

        IF l_dummy = 1 THEN
             OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFR_MO_DUP');
             x_return_status := FND_API.g_ret_sts_error;
        END IF;

END check_mo_uk_items;

PROCEDURE check_mo_req_items(
                 p_mo_rec                     IN   vo_mo_rec_type
                , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
                , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
      l_api_name CONSTANT VARCHAR2(30) := 'check_mo_req_items';
BEGIN
      OZF_Volume_Offer_disc_PVT.debug_message('Private API: ' || l_api_name || 'start');
      OZF_Volume_Offer_disc_PVT.debug_message('Validation Mode is : ' || p_validation_mode || ' '|| JTF_PLSQL_API.g_create);

      x_return_status := FND_API.g_ret_sts_success;

       IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_mo_rec.offer_id = FND_API.G_MISS_NUM OR p_mo_rec.offer_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      /*IF p_mo_rec.group_number = FND_API.G_MISS_NUM OR p_mo_rec.group_number IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'GROUP_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/
      IF p_mo_rec.retroactive_flag = FND_API.G_MISS_CHAR OR p_mo_rec.retroactive_flag IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'RETROACTIVE_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_mo_rec.combine_schedule_flag = FND_API.G_MISS_CHAR OR p_mo_rec.combine_schedule_flag IS NULL THEN
               OZF_UTILITY_PVT.Error_message('OZF_API_MISSING_FIELD','MISS_FIELD','COMBINE_SCHEDULE_FLAG');
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_mo_rec.volume_tracking_level_code = FND_API.G_MISS_CHAR OR p_mo_rec.volume_tracking_level_code IS NULL THEN
              OZF_UTILITY_PVT.Error_message('OZF_API_MISSING_FIELD','MISS_FIELD','VOLUME_TRACKING_LEVEL_CODE');
              x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_mo_rec.accrue_to_code = FND_API.G_MISS_CHAR OR p_mo_rec.accrue_to_code IS NULL THEN
            OZF_UTILITY_PVT.Error_message('OZF_API_MISSING_FIELD','MISS_FIELD','ACCRUE_TO_CODE');
            x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_mo_rec.precedence = FND_API.G_MISS_NUM OR p_mo_rec.precedence IS NULL THEN
            OZF_UTILITY_PVT.Error_message('OZF_API_MISSING_FIELD','MISS_FIELD','PRECEDENCE');
      END IF;


   ELSE
          IF p_mo_rec.offer_market_option_id = FND_API.G_MISS_NUM THEN
                   OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'offer_market_option_id' );
                   x_return_status := FND_API.g_ret_sts_error;
          END IF;

      IF p_mo_rec.offer_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

/*      IF p_mo_rec.group_number = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'GROUP_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/
      IF p_mo_rec.retroactive_flag = FND_API.G_MISS_CHAR THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'RETROACTIVE_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_mo_rec.combine_schedule_flag = FND_API.G_MISS_CHAR THEN
               OZF_UTILITY_PVT.Error_message('OZF_API_MISSING_FIELD','MISS_FIELD','COMBINE_SCHEDULE_FLAG');
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_mo_rec.volume_tracking_level_code = FND_API.G_MISS_CHAR THEN
              OZF_UTILITY_PVT.Error_message('OZF_API_MISSING_FIELD','MISS_FIELD','VOLUME_TRACKING_LEVEL_CODE');
              x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_mo_rec.accrue_to_code = FND_API.G_MISS_CHAR THEN
            OZF_UTILITY_PVT.Error_message('OZF_API_MISSING_FIELD','MISS_FIELD','ACCRUE_TO_CODE');
            x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_mo_rec.precedence = FND_API.G_MISS_NUM THEN
            OZF_UTILITY_PVT.Error_message('OZF_API_MISSING_FIELD','MISS_FIELD','PRECEDENCE');
            x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_mo_rec.object_version_number = FND_API.G_MISS_NUM OR p_mo_rec.object_version_number IS NULL THEN
            OZF_UTILITY_PVT.Error_message('OZF_API_MISSING_FIELD','MISS_FIELD','OBJECT_VERSION_NUMBER');
            x_return_status := FND_API.g_ret_sts_error;
      END IF;

END IF;

END check_mo_req_items;

PROCEDURE check_mo_fk_items(
                 p_mo_rec                     IN   vo_mo_rec_type
                , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
                , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
l_dummy number := -1;
CURSOR c_mo_grp(p_list_header_id NUMBER, p_group_number NUMBER) IS
SELECT 1 FROM dual WHERE EXISTS( SELECT 'X' FROM qp_qualifiers WHERE list_header_id = p_list_header_id AND qualifier_grouping_no = p_group_number);

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_mo_rec.offer_id IS NOT NULL AND p_mo_rec.offer_id  <> FND_API.G_MISS_NUM
    THEN
        IF ozf_utility_pvt.check_fk_exists('OZF_OFFERS','OFFER_ID',to_char(p_mo_rec.offer_id)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_OFFER_ID' );
            x_return_status := FND_API.g_ret_sts_error;
        END IF;
    END IF;

    IF p_mo_rec.qp_list_header_id IS NOT NULL AND p_mo_rec.qp_list_header_id  <> FND_API.G_MISS_NUM
    THEN
        IF ozf_utility_pvt.check_fk_exists('QP_LIST_HEADERS_B','list_header_id',to_char(p_mo_rec.qp_list_header_id)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_QP_LIST_HEADER' );
            x_return_status := FND_API.g_ret_sts_error;
        END IF;
    END IF;

    IF p_mo_rec.beneficiary_party_id IS NOT NULL AND p_mo_rec.beneficiary_party_id <> FND_API.G_MISS_NUM THEN
        IF ozf_utility_pvt.check_fk_exists('QP_CUSTOMERS_V','CUSTOMER_ID',to_char(p_mo_rec.beneficiary_party_id)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_BENEFICIARY' );
            x_return_status := FND_API.g_ret_sts_error;
        END IF;
    END IF;

/*    IF (p_mo_rec.qp_list_header_id IS NOT NULL AND p_mo_rec.qp_list_header_id <> FND_API.G_MISS_NUM)
    AND (p_mo_rec.group_number IS NOT NULL AND p_mo_rec.group_number <> FND_API.G_MISS_NUM)
    THEN
        OPEN c_mo_grp(p_mo_rec.qp_list_header_id,p_mo_rec.group_number);
        FETCH c_mo_grp INTO l_dummy;
            IF (c_mo_grp%NOTFOUND) THEN
                    OZF_Utility_PVT.Error_Message('OZF_OFFR_INV_LH_GRP' );
                    x_return_status := FND_API.g_ret_sts_error;
            END IF;
    END IF;
*/
END check_mo_fk_items;

PROCEDURE check_mo_lkup_items(
                 p_mo_rec                     IN   vo_mo_rec_type
                , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
                , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF p_mo_rec.volume_tracking_level_code <> FND_API.G_MISS_CHAR AND p_mo_rec.volume_tracking_level_code IS NOT NULL THEN
        IF OZF_UTILITY_PVT.check_lookup_exists('OZF_LOOKUPS', 'OZF_VO_TRACKING_LEVEL', p_mo_rec.volume_tracking_level_code) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_OFFR_MO_INV_VOL_TRK' );
            x_return_status := FND_API.g_ret_sts_error;
        END IF;
      END IF;

      IF p_mo_rec.accrue_to_code <> FND_API.G_MISS_CHAR AND p_mo_rec.accrue_to_code IS NOT NULL THEN
        IF OZF_UTILITY_PVT.check_lookup_exists('OZF_LOOKUPS', 'OZF_VO_ACCRUE_TO', p_mo_rec.accrue_to_code) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_OFFR_MO_INV_ACCR_TO' );
            x_return_status := FND_API.g_ret_sts_error;
        END IF;
      END IF;
END check_mo_lkup_items;


PROCEDURE check_mo_attr(
                 p_mo_rec                     IN   vo_mo_rec_type
                , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
                , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF p_mo_rec.retroactive_flag IS NOT NULL AND p_mo_rec.retroactive_flag <> FND_API.G_MISS_CHAR THEN
        IF upper(p_mo_rec.retroactive_flag) <> 'Y' AND upper(p_mo_rec.retroactive_flag) <> 'N' THEN
            OZF_Utility_PVT.Error_Message('OZF_OFFR_MO_INV_RETROACT_FLAG' );
            x_return_status := FND_API.g_ret_sts_error;
        END IF;
      END IF;

      IF p_mo_rec.combine_schedule_flag IS NOT NULL AND p_mo_rec.combine_schedule_flag <> FND_API.G_MISS_CHAR THEN
        IF upper(p_mo_rec.combine_schedule_flag) <> 'Y' AND upper(p_mo_rec.combine_schedule_flag) <> 'N' THEN
            OZF_Utility_PVT.Error_Message('OZF_OFFR_MO_INV_COMB_TIERS' );
            x_return_status := FND_API.g_ret_sts_error;
        END IF;
      END IF;

END check_mo_attr;


PROCEDURE check_mo_inter_attr(
                 p_mo_rec                     IN   vo_mo_rec_type
                , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
                , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
END check_mo_inter_attr;

PROCEDURE check_mo_entity(
                 p_mo_rec                     IN   vo_mo_rec_type
                , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
                , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
END check_mo_entity;



PROCEDURE Check_mo_Items(
                 p_mo_rec                     IN   vo_mo_rec_type
                , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
                , x_return_status              OUT NOCOPY  VARCHAR2
              )
IS
BEGIN
-- initialize
      x_return_status := FND_API.G_RET_STS_SUCCESS;
-- check unique items
    check_mo_uk_items(
                        p_mo_rec => p_mo_rec
                        , p_validation_mode => p_validation_mode
                        , x_return_status => x_return_status
                      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

-- check required items
    check_mo_req_items(
                        p_mo_rec => p_mo_rec
                        , p_validation_mode => p_validation_mode
                        , x_return_status => x_return_status
                      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

-- check Foreign key items
    check_mo_fk_items(
                       p_mo_rec => p_mo_rec
                       , p_validation_mode => p_validation_mode
                       , x_return_status => x_return_status
                       );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

-- check lookup items
    check_mo_lkup_items(
                        p_mo_rec => p_mo_rec
                        , p_validation_mode => p_validation_mode
                        , x_return_status    => x_return_status
                        );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

-- check mo attributes
    check_mo_attr(
                    p_mo_rec => p_mo_rec
                    , p_validation_mode => p_validation_mode
                    , x_return_status => x_return_status
                    );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

-- check mo inter attributes
    check_mo_inter_attr(
                        p_mo_rec => p_mo_rec
                        , p_validation_mode => p_validation_mode
                        , x_return_status    => x_return_status
                        );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

-- check mo entity
    check_mo_entity(
                    p_mo_rec => p_mo_rec
                    , p_validation_mode => p_validation_mode
                    , x_return_status    => x_return_status
                    );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

END Check_mo_Items;



PROCEDURE validate_market_options
(
    p_api_version_number         IN   NUMBER
    , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    , p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
    , x_return_status              OUT NOCOPY  VARCHAR2
    , x_msg_count                  OUT NOCOPY  NUMBER
    , x_msg_data                   OUT NOCOPY  VARCHAR2
    , p_mo_rec                     IN   vo_mo_rec_type
    )
    IS
l_api_name                  CONSTANT VARCHAR2(30) := 'validate_market_options';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_vo_mo_rec               vo_mo_rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_market_options_pvt;

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
      OZF_Volume_Offer_disc_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check items
          IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_mo_Items(
                 p_mo_rec        => p_mo_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );
              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
      IF p_validation_mode = JTF_PLSQL_API.g_update THEN
/*      Complete_mo_Rec(
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
*/
              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

    -- exception
      OZF_Volume_Offer_disc_PVT.debug_message('Private API: ' || l_api_name || 'Return status is : '|| x_return_status);

      -- Debug Message
      OZF_Volume_Offer_disc_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO validate_market_options_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO validate_market_options_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO validate_market_options_pvt;
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
    END validate_market_options;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_market_options
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_api_version_number         IN   NUMBER
--    p_init_msg_list            IN   VARCHAR2
--    p_validation_level           IN   NUMBER
--    p_mo_rec              IN  vo_mo_rec_type
--    p_validation_mode          IN VARCHAR2
--
--   OUT
--    x_return_status              OUT NOCOPY  VARCHAR2
--    x_msg_count                  OUT NOCOPY  NUMBER
--    x_msg_data                   OUT NOCOPY  VARCHAR2

--   Version : Current version 1.0
--
--   History
--            Mon Jun 20 2005:7/57 PM RSSHARMA Created
--
--   Description
--   End of Comments
--   ==============================================================================

PROCEDURE Create_market_options(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_mo_rec                     IN   vo_mo_rec_type  ,
    x_vo_market_option_id        OUT NOCOPY  NUMBER
)
IS
l_mo_rec vo_mo_rec_type;
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_market_options';
l_market_option_id NUMBER;
l_object_version_number NUMBER;
l_dummy NUMBER;
   CURSOR c_id IS
      SELECT ozf_offr_market_options_s.NEXTVAL
      FROM dual;
   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM ozf_offr_market_options
      WHERE offer_market_option_id = l_id;

BEGIN
-- initialize
--initialize
      -- Standard Start of API savepoint
      SAVEPOINT Create_market_options_pvt;

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
      OZF_Volume_Offer_disc_PVT.debug_message('Private API: ' || l_api_name || 'start');

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

l_mo_rec := p_mo_rec;


   IF p_mo_rec.offer_market_option_id IS NULL OR p_mo_rec.OFFER_MARKET_OPTION_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_market_option_id;
         CLOSE c_id;

         OPEN c_id_exists(l_market_option_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_market_option_id := p_mo_rec.offer_market_option_id;
   END IF;

-- if group_number is -1 then dont create a market option. But since the market option id may be required , set the returned market option id to -1
   IF  l_mo_rec.group_number IS NOT NULL AND l_mo_rec.group_number <> FND_API.G_MISS_NUM THEN
        IF l_mo_rec.group_number <> -1 THEN
-- validate
validate_market_options
(
    p_api_version_number        => p_api_version_number
    , p_init_msg_list           => p_init_msg_list
    , p_validation_level        => p_validation_level
    , p_validation_mode         => JTF_PLSQL_API.g_create
    , x_return_status           => x_return_status
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , p_mo_rec                  => l_mo_rec
    );

-- insert
OZF_OFFR_MARKET_OPTION_PKG.Insert_Row(
          px_offer_market_option_id => l_market_option_id
          , p_offer_id => l_mo_rec.offer_id
          , p_qp_list_header_id => l_mo_rec.qp_list_header_id
          , p_group_number => l_mo_rec.group_number
          , p_retroactive_flag => l_mo_rec.retroactive_flag
          , p_beneficiary_party_id => l_mo_rec.beneficiary_party_id
          , p_combine_schedule_flag => l_mo_rec.combine_schedule_flag
          , p_volume_tracking_level_code => l_mo_rec.volume_tracking_level_code
          , p_accrue_to_code  => l_mo_rec.accrue_to_code
          , p_precedence => l_mo_rec.precedence
          , px_object_version_number  => l_object_version_number
          , p_creation_date           => SYSDATE
          , p_created_by              => FND_GLOBAL.USER_ID
          , p_last_updated_by         => FND_GLOBAL.USER_ID
          , p_last_update_date        => SYSDATE
          , p_last_update_login       => FND_GLOBAL.conc_login_id
          );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

    x_vo_market_option_id := l_market_option_id;
    ELSE
    x_vo_market_option_id := -1;
    END IF;
   END IF;

-- commit;
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      OZF_Volume_Offer_disc_PVT.debug_message('Private API: ' || l_api_name || 'Return status is : '|| x_return_status);
      OZF_Volume_Offer_disc_PVT.debug_message('Private API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- exception
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_market_options_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_market_options_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_market_options_pvt;
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

END Create_market_options;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_market_options
--   Type
--           Private
--   Pre-Req
--             validate_market_options
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_mo_rec   IN   vo_mo_rec_type Required Record Containing Market options Data
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Mon Jun 20 2005:7/56 PM  Created
--
--   Description
--              : Method to Update Discount Lines.
--   End of Comments
--   ==============================================================================

PROCEDURE Update_market_options(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_mo_rec                     IN   vo_mo_rec_type
)
IS
CURSOR c_get_mo(p_market_option_id NUMBER, p_object_version_number NUMBER) IS
    SELECT *
    FROM ozf_offr_market_options
    WHERE offer_market_option_id = p_market_option_id
    AND object_version_number = p_object_version_number;
    -- Hint: Developer need to provide Where clause

l_api_name                  CONSTANT VARCHAR2(30) := 'Update_market_options';
l_api_version_number        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_market_option_id    NUMBER;
l_ref_mo_rec  c_get_mo%ROWTYPE ;
l_tar_mo_rec  vo_mo_rec_type := p_mo_rec ;
l_rowid  ROWID;
BEGIN
--initialize
      -- Standard Start of API savepoint
      SAVEPOINT Update_market_options_pvt;
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
      OZF_Volume_Offer_disc_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN c_get_mo( l_tar_mo_rec.offer_market_option_id,l_tar_mo_rec.object_version_number);
          FETCH c_get_mo INTO l_ref_mo_rec  ;
       If ( c_get_mo%NOTFOUND) THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'OZF_MARKET_OPTIONS') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE c_get_mo;

      If (l_tar_mo_rec.object_version_number is NULL or
          l_tar_mo_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING'
                                           , p_token_name   => 'COLUMN'
                                           , p_token_value  => 'Last_Update_Date') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_mo_rec.object_version_number <> l_ref_mo_rec.object_version_number) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'Ozf_Market_Options') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;
-- validate
validate_market_options
(
    p_api_version_number        => p_api_version_number
    , p_init_msg_list           => p_init_msg_list
    , p_validation_level        => p_validation_level
    , p_validation_mode         => JTF_PLSQL_API.g_update
    , x_return_status           => x_return_status
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , p_mo_rec                  => l_tar_mo_rec
    );
-- update
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

OZF_OFFR_MARKET_OPTION_PKG.Update_Row(
          p_offer_market_option_id => l_tar_mo_rec.offer_market_option_id
          , p_offer_id => l_tar_mo_rec.offer_id
          , p_qp_list_header_id => l_tar_mo_rec.qp_list_header_id
          , p_group_number => l_tar_mo_rec.group_number
          , p_retroactive_flag => l_tar_mo_rec.retroactive_flag
          , p_beneficiary_party_id => l_tar_mo_rec.beneficiary_party_id
          , p_combine_schedule_flag => l_tar_mo_rec.combine_schedule_flag
          , p_volume_tracking_level_code => l_tar_mo_rec.volume_tracking_level_code
          , p_accrue_to_code  => l_tar_mo_rec.accrue_to_code
          , p_precedence => l_tar_mo_rec.precedence
          , p_object_version_number  => l_tar_mo_rec.object_version_number
          , p_creation_date           => SYSDATE
          , p_created_by              => FND_GLOBAL.USER_ID
          , p_last_updated_by         => FND_GLOBAL.USER_ID
          , p_last_update_date        => SYSDATE
          , p_last_update_login       => FND_GLOBAL.conc_login_id
          );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      OZF_Volume_Offer_disc_PVT.debug_message('Private API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- exception
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_market_options_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_market_options_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_market_options_pvt;
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

END Update_market_options;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_market_options
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
--    p_offer_market_option_id    IN  NUMBER
--    p_object_version_number      IN   NUMBER

--
--   OUT
--    x_return_status              OUT NOCOPY  VARCHAR2
--    x_msg_count                  OUT NOCOPY  NUMBER
--    x_msg_data                   OUT NOCOPY  VARCHAR2

--   Version : Current version 1.0
--
--   History
--            Mon Jun 20 2005:7/55 PM  Created
--
--   Description
--   End of Comments
--   ==============================================================================
PROCEDURE Delete_market_options(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_market_option_id    IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )
    IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_market_options';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_market_options_PVT;

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
      OZF_OFFR_MARKET_OPTION_PKG.Delete_row(
                                                    p_offer_market_option_id  => p_offer_market_option_id
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
     ROLLBACK TO Delete_market_options_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_market_options_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_market_options_PVT;
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

    END Delete_market_options;


END OZF_offer_Market_Options_PVT;


/
