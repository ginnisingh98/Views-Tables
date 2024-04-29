--------------------------------------------------------
--  DDL for Package Body OZF_MO_PRESET_TIERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_MO_PRESET_TIERS_PVT" AS
/* $Header: ozfvmoptb.pls 120.4 2005/08/25 04:34:57 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_MO_PRESET_TIERS_PKG
-- Purpose
--
-- History
--  Mon Jul 11 2005:6/29 PM RSSHARMA Created
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================

G_PKG_NAME VARCHAR2(30) := 'OZF_MO_PRESET_TIERS_PVT';
G_FILE_NAME VARCHAR2(15) := 'ozfvmoptb.pls';

PROCEDURE check_preset_tiers_req_items
(
    p_preset_tier_rec              IN   mo_preset_rec_type
    , p_validation_mode            IN   VARCHAR2
    , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_validation_mode = JTF_PLSQL_API.g_create THEN
    IF p_preset_tier_rec.offer_market_option_id IS NULL OR p_preset_tier_rec.offer_market_option_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','offer_market_option_id');
                x_return_status := FND_API.g_ret_sts_error;
                return;
    END IF;
    IF p_preset_tier_rec.pbh_offer_discount_id IS NULL OR p_preset_tier_rec.pbh_offer_discount_id = FND_API.G_MISS_NUM THEN
                    OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','pbh_offer_discount_id');
                    x_return_status := FND_API.g_ret_sts_error;
                    return;
    END IF;
    IF p_preset_tier_rec.dis_offer_discount_id IS NULL OR p_preset_tier_rec.dis_offer_discount_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','dis_offer_discount_id');
                x_return_status := FND_API.g_ret_sts_error;
                return;
    END IF;
ELSE
    IF p_preset_tier_rec.market_preset_tier_id = FND_API.G_MISS_NUM THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','market_preset_tier_id');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
    IF p_preset_tier_rec.offer_market_option_id = FND_API.G_MISS_NUM THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','offer_market_option_id');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
    IF p_preset_tier_rec.pbh_offer_discount_id = FND_API.G_MISS_NUM THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','pbh_offer_discount_id');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
    IF p_preset_tier_rec.dis_offer_discount_id = FND_API.G_MISS_NUM THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','dis_offer_discount_id');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
    IF p_preset_tier_rec.object_version_number = FND_API.G_MISS_NUM THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','object_version_number');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
END IF;

END check_preset_tiers_req_items;

PROCEDURE check_preset_tiers_uk_items
(
    p_preset_tier_rec              IN   mo_preset_rec_type
    , p_validation_mode            IN   VARCHAR2
    , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_validation_mode = JTF_PLSQL_API.G_CREATE THEN
IF p_preset_tier_rec.market_preset_tier_id IS NOT NULL AND p_preset_tier_rec.market_preset_tier_id <> FND_API.G_MISS_NUM THEN
    IF ozf_utility_pvt.check_uniqueness('ozf_market_preset_tiers','market_preset_tier_id = '||p_preset_tier_rec.market_preset_tier_id) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_MO_PRESET_ID_DUP');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
END IF;
END IF;

IF p_validation_mode = JTF_PLSQL_API.G_UPDATE THEN
IF
(
    p_preset_tier_rec.offer_market_option_id IS NOT NULL AND p_preset_tier_rec.offer_market_option_id <> FND_API.G_MISS_NUM
)
AND
(
    p_preset_tier_rec.pbh_offer_discount_id IS NOT NULL AND p_preset_tier_rec.pbh_offer_discount_id <> FND_API.G_MISS_NUM
)
AND
(
    p_preset_tier_rec.dis_offer_discount_id IS NOT NULL AND p_preset_tier_rec.dis_offer_discount_id <> FND_API.G_MISS_NUM
)
AND
(
    p_preset_tier_rec.market_preset_tier_id IS NOT NULL AND p_preset_tier_rec.market_preset_tier_id <> FND_API.G_MISS_NUM
)
    THEN
    IF ozf_utility_pvt.check_uniqueness('ozf_market_preset_tiers'
        ,'offer_market_option_id = '||p_preset_tier_rec.offer_market_option_id
        ||' AND pbh_offer_discount_id = '|| p_preset_tier_rec.pbh_offer_discount_id
        || ' AND dis_offer_discount_id = '||p_preset_tier_rec.dis_offer_discount_id
        || ' AND market_preset_tier_id <> ' ||p_preset_tier_rec.market_preset_tier_id
        )
        = FND_API.G_FALSE
    THEN
            OZF_Utility_PVT.Error_Message('OZF_MO_PRESTE_TIER_DUP');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
END IF;
ELSE
IF
(
    p_preset_tier_rec.offer_market_option_id IS NOT NULL AND p_preset_tier_rec.offer_market_option_id <> FND_API.G_MISS_NUM
)
AND
(
    p_preset_tier_rec.pbh_offer_discount_id IS NOT NULL AND p_preset_tier_rec.pbh_offer_discount_id <> FND_API.G_MISS_NUM
)
AND
(
    p_preset_tier_rec.dis_offer_discount_id IS NOT NULL AND p_preset_tier_rec.dis_offer_discount_id <> FND_API.G_MISS_NUM
)
    THEN
    IF ozf_utility_pvt.check_uniqueness('ozf_market_preset_tiers'
    ,'offer_market_option_id = '||p_preset_tier_rec.offer_market_option_id ||' AND pbh_offer_discount_id = '|| p_preset_tier_rec.pbh_offer_discount_id || ' AND dis_offer_discount_id = '||p_preset_tier_rec.dis_offer_discount_id ) = FND_API.G_FALSE
    THEN
            OZF_Utility_PVT.Error_Message('OZF_MO_PRESTE_TIER_DUP');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
END IF;

END IF;
END check_preset_tiers_uk_items;

PROCEDURE check_preset_tiers_fk_items
(
    p_preset_tier_rec              IN   mo_preset_rec_type
    , p_validation_mode            IN   VARCHAR2
    , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
CURSOR c_pbh(p_pbh_discount_id NUMBER)
IS
SELECT 1 FROM DUAL
WHERE EXISTS( SELECT 'X' FROM ozf_offer_discount_lines WHERE offer_discount_line_id = p_pbh_discount_id AND tier_type = 'PBH');

CURSOR c_dis(p_dis_discount_id NUMBER)
IS
SELECT 1 FROM dual WHERE EXISTS (SELECT 'X' FROM ozf_offer_discount_lines WHERE offer_discount_line_id = p_dis_discount_id AND tier_type = 'DIS');

l_dummy NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_preset_tier_rec.offer_market_option_id IS NOT NULL AND p_preset_tier_rec.offer_market_option_id <> FND_API.G_MISS_NUM THEN
    IF ozf_utility_pvt.check_fk_exists('ozf_offr_market_options','offer_market_option_id',to_char(p_preset_tier_rec.offer_market_option_id)) = FND_API.G_FALSE THEN
            OZF_Utility_PVT.Error_Message('OZF_MO_PRESET_TIER_INV_MO_ID');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
END IF;

IF p_preset_tier_rec.pbh_offer_discount_id IS NOT NULL AND p_preset_tier_rec.pbh_offer_discount_id <> FND_API.G_MISS_NUM THEN
    IF ozf_utility_pvt.check_fk_exists('OZF_OFFER_DISCOUNT_LINES','offer_discount_line_id',to_char(p_preset_tier_rec.pbh_offer_discount_id)) =FND_API.G_FALSE THEN
            OZF_Utility_PVT.Error_Message('OZF_MO_PRESET_TIER_INV_PBH_ID');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
IF p_preset_tier_rec.dis_offer_discount_id IS NOT NULL AND p_preset_tier_rec.dis_offer_discount_id <> FND_API.G_MISS_NUM THEN
    IF ozf_utility_pvt.check_fk_exists('OZF_OFFER_DISCOUNT_LINES', 'OFFER_DISCOUNT_LINE_ID', to_char(p_preset_tier_rec.dis_offer_discount_id)) = FND_API.G_FALSE THEN
           OZF_Utility_PVT.Error_Message('OZF_MO_PRESET_TIERS_INV_DIS_ID');
           x_return_status := FND_API.g_ret_sts_error;
           return;
    END IF;
END IF;
END IF;


END check_preset_tiers_fk_items;

PROCEDURE check_preset_tiers_attr
(
    p_preset_tier_rec              IN   mo_preset_rec_type
    , p_validation_mode            IN   VARCHAR2
    , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
END check_preset_tiers_attr;

PROCEDURE check_preset_tiers_inter_attr
(
    p_preset_tier_rec              IN   mo_preset_rec_type
    , p_validation_mode            IN   VARCHAR2
    , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
CURSOR c_valid(p_dis_discount_id NUMBER, p_pbh_discount_id NUMBER) IS
SELECT 1 FROM dual
WHERE EXISTS(
SELECT 'x' FROM ozf_offer_discount_lines
WHERE offer_discount_line_id = p_dis_discount_id
AND parent_discount_line_id = p_pbh_discount_id);
l_dummy NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF
(p_preset_tier_rec.pbh_offer_discount_id IS NOT NULL AND p_preset_tier_rec.pbh_offer_discount_id <> FND_API.G_MISS_NUM )
AND
(p_preset_tier_rec.dis_offer_discount_id IS NOT NULL AND p_preset_tier_rec.dis_offer_discount_id <> FND_API.G_MISS_NUM )
THEN
   OPEN c_valid(p_preset_tier_rec.dis_offer_discount_id,p_preset_tier_rec.pbh_offer_discount_id);
   FETCH c_valid INTO l_dummy;
   IF (c_valid%NOTFOUND) THEN
           CLOSE c_valid;
            OZF_Utility_PVT.Error_Message('OZF_MO_PRESET_TIER_INV_DIS_PBH');
            x_return_status := FND_API.g_ret_sts_error;
            return;
   END IF;
    CLOSE c_valid;
END IF;
END check_preset_tiers_inter_attr;


PROCEDURE check_preset_tier_items
(
    p_preset_tier_rec              IN   mo_preset_rec_type
    , p_validation_mode            IN   VARCHAR2
    , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
    check_preset_tiers_req_items
    (
    p_preset_tier_rec => p_preset_tier_rec
    , p_validation_mode => p_validation_mode
    , x_return_status => x_return_status
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    check_preset_tiers_uk_items
    (
    p_preset_tier_rec => p_preset_tier_rec
    , p_validation_mode => p_validation_mode
    , x_return_status => x_return_status
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    check_preset_tiers_fk_items
    (
    p_preset_tier_rec => p_preset_tier_rec
    , p_validation_mode => p_validation_mode
    , x_return_status => x_return_status
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    check_preset_tiers_attr
    (
    p_preset_tier_rec => p_preset_tier_rec
    , p_validation_mode => p_validation_mode
    , x_return_status => x_return_status
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    check_preset_tiers_inter_attr
    (
    p_preset_tier_rec => p_preset_tier_rec
    , p_validation_mode => p_validation_mode
    , x_return_status => x_return_status
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
END check_preset_tier_items;

PROCEDURE Validate_mo_preset_tiers
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.G_CREATE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_preset_tier_rec              IN   mo_preset_rec_type
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'Validate_mo_preset_tiers';
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;

ozf_utility_pvt.debug_message('Private API: '|| l_api_name||' Start');

IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
check_preset_tier_items
(
p_preset_tier_rec => p_preset_tier_rec
, p_validation_mode => p_validation_mode
, x_return_status => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END IF;
ozf_utility_pvt.debug_message('Private API: '||l_api_name ||' End');

END Validate_mo_preset_tiers;

PROCEDURE Create_mo_preset_tiers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_preset_tier_rec              IN   mo_preset_rec_type  ,
    x_market_preset_tier_id      OUT NOCOPY  NUMBER
)
IS
l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'Create_mo_preset_tiers';
l_market_preset_tier_id NUMBER;
l_dummy NUMBER;
l_object_version_number NUMBER;

l_preset_tier_rec mo_preset_rec_type;
CURSOR c_id IS
SELECT ozf_market_preset_tiers_s.nextval
FROM DUAL;

CURSOR c_id_exists(l_market_preset_tier_id NUMBER)
is
SELECT 1 FROM dual WHERE exists(SELECT 'X' FROM ozf_market_preset_tiers WHERE market_preset_tier_id = l_market_preset_tier_id);
BEGIN
-- initialize
--  savepoint
SAVEPOINT Create_mo_preset_tiers;
--  api compatibility
IF NOT FND_API.Compatible_api_call(
                                    l_api_version_number
                                    , p_api_version_number
                                    , g_pkg_name
                                    , l_api_name
) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--  initialize messages
IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
END IF;

ozf_utility_pvt.debug_message('Private API: '|| l_api_name || ' Start');
x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

l_preset_tier_rec := p_preset_tier_rec;

IF p_preset_tier_rec.market_preset_tier_id IS NULL OR p_preset_tier_rec.market_preset_tier_id = FND_API.G_MISS_NUM THEN
    LOOP
    l_dummy := null;
    OPEN c_id;
    FETCH c_id INTO l_market_preset_tier_id;
    CLOSE c_id;
    OPEN c_id_exists(l_market_preset_tier_id);
        FETCH c_id_exists INTO l_dummy;
    CLOSE c_id_exists;
    EXIT WHEN l_dummy IS NULL;
    END LOOP;
ELSE
    l_market_preset_tier_id := p_preset_tier_rec.market_preset_tier_id;
END IF;
-- validate
    Validate_mo_preset_tiers
    (
        p_api_version_number         => p_api_version_number
        , p_init_msg_list            => p_init_msg_list
        , p_commit                   => p_commit
        , p_validation_level         => p_validation_level
        , p_validation_mode          => JTF_PLSQL_API.g_create
        , x_return_status            => x_return_status
        , x_msg_count                => x_msg_count
        , x_msg_data                 => x_msg_data
        , p_preset_tier_rec          => l_preset_tier_rec
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

-- insert
    OZF_MO_PRESET_TIERS_PKG.Insert_row
    (
           px_market_preset_tier_id => l_market_preset_tier_id
          , p_offer_market_option_id => l_preset_tier_rec.offer_market_option_id
          , p_pbh_offer_discount_id  => l_preset_tier_rec.pbh_offer_discount_id
          , p_dis_offer_discount_id  => l_preset_tier_rec.dis_offer_discount_id
          , px_object_version_number => l_object_version_number
          , p_creation_date          => sysdate
          , p_created_by             => FND_GLOBAL.user_id
          , p_last_update_date       => sysdate
          , p_last_updated_by        => FND_GLOBAL.user_id
          , p_last_update_login      => FND_GLOBAL.conc_login_id
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_market_preset_tier_id := l_market_preset_tier_id;

    ozf_utility_pvt.debug_message('Private API: '|| l_api_name || ' Start');

    IF FND_API.to_boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
-- commit
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_mo_preset_tiers;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false
        , p_count => x_msg_count
        , p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_mo_preset_tiers;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false
        , p_count => x_msg_count
        , p_data  => x_msg_data
        );
    WHEN OTHERS THEN
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
-- exception
NULL;
END Create_mo_preset_tiers;

PROCEDURE Update_mo_preset_tiers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_preset_tier_rec              IN   mo_preset_rec_type
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'Update_mo_preset_tiers';
l_api_version_number CONSTANT NUMBER := 1.0;
l_tar_preset_rec mo_preset_rec_type := p_preset_tier_rec;

CURSOR c_get_preset_tiers(p_market_preset_tier_id NUMBER, p_object_version_number NUMBER)
IS
SELECT * FROM ozf_market_preset_tiers
WHERE market_preset_tier_id = p_market_preset_tier_id
AND object_version_number = p_object_version_number;
l_ref_preset_tiers c_get_preset_tiers%ROWTYPE;

BEGIN
--initialize
SAVEPOINT Update_mo_preset_tiers;
IF NOT FND_API.Compatible_api_call
(
l_api_version_number
, p_api_version_number
, G_PKG_NAME
, l_api_name
)
THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
END IF;

ozf_utility_pvt.debug_message('Private API: '|| l_api_name || ' Start');
x_return_status := FND_API.G_RET_STS_SUCCESS;

open c_get_preset_tiers(l_tar_preset_rec.market_preset_tier_id, l_tar_preset_rec.object_version_number);
FETCH c_get_preset_tiers INTO l_ref_preset_tiers;
IF (c_get_preset_tiers%NOTFOUND) THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'OZF_MO_PRESET_TIERS') ;
           RAISE FND_API.G_EXC_ERROR;
END IF;
IF l_tar_preset_rec.object_version_number = FND_API.G_MISS_NUM OR l_tar_preset_rec.object_version_number IS NULL THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING'
                                           , p_token_name   => 'COLUMN'
                                           , p_token_value  => 'Last_Update_Date') ;
          RAISE FND_API.G_EXC_ERROR;
END IF;
IF l_tar_preset_rec.object_version_number <> l_ref_preset_tiers.object_version_number THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'Ozf_Market_Options') ;
          RAISE FND_API.G_EXC_ERROR;
END IF;
-- validate
-- update
-- commit
-- exception
    Validate_mo_preset_tiers
    (
        p_api_version_number         => p_api_version_number
        , p_init_msg_list            => p_init_msg_list
        , p_commit                   => p_commit
        , p_validation_level         => p_validation_level
        , p_validation_mode          => JTF_PLSQL_API.g_update
        , x_return_status            => x_return_status
        , x_msg_count                => x_msg_count
        , x_msg_data                 => x_msg_data
        , p_preset_tier_rec          => p_preset_tier_rec
    );

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

OZF_MO_PRESET_TIERS_PKG.Update_row
(
          p_market_preset_tier_id => l_tar_preset_rec.market_preset_tier_id
          , p_offer_market_option_id => l_tar_preset_rec.offer_market_option_id
          , p_pbh_offer_discount_id  => l_tar_preset_rec.pbh_offer_discount_id
          , p_dis_offer_discount_id  => l_tar_preset_rec.dis_offer_discount_id
          , p_object_version_number  => l_tar_preset_rec.object_version_number
          , p_last_update_date       => sysdate
          , p_last_updated_by        => FND_GLOBAL.user_id
          , p_last_update_login      => FND_GLOBAL.conc_login_id
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

ozf_utility_pvt.debug_message('Private API: '|| l_api_name ||' End');

IF FND_API.to_boolean(p_commit) THEN
    COMMIT WORK;
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
ROLLBACK TO UPDATE_mo_PRESET_TIERS;
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO UPDATE_mo_PRESET_TIERS;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN OTHERS THEN
ROLLBACK TO UPDATE_mo_PRESET_TIERS;
x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
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

END UPDATE_mo_PRESET_TIERS;

PROCEDURE Delete_mo_preset_tiers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_market_preset_tier_id      IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )
IS
l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'Delete_mo_preset_tiers';
BEGIN
--INITIALIZE
SAVEPOINT Delete_mo_preset_tiers;
IF NOT FND_API.Compatible_api_call
(
l_api_version_number
, p_api_version_number
, G_PKG_NAME
, l_api_name
)
THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF FND_API.to_boolean(p_init_msg_list) THEN
FND_MSG_PUB.initialize;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;
ozf_utility_pvt.debug_message('Private API: '|| l_api_name || ' Start');

OZF_MO_PRESET_TIERS_PKG.Delete_row(p_market_preset_tier_id => p_market_preset_tier_id, p_object_version_number => p_object_version_number);

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

ozf_utility_pvt.debug_message('Private API: '|| l_api_name || ' End');
IF FND_API.to_boolean(p_commit) THEN
COMMIT WORK;
END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
ROLLBACK TO Delete_mo_preset_tiers;
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO Delete_mo_preset_tiers;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN OTHERS THEN
ROLLBACK TO Delete_mo_preset_tiers;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,l_api_name);
END IF;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );

-- exception
END Delete_mo_preset_tiers;


END OZF_MO_PRESET_TIERS_PVT;

/
