--------------------------------------------------------
--  DDL for Package Body OZF_QP_PRODUCTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_QP_PRODUCTS_PVT" AS
/* $Header: ozfvoqppb.pls 120.3 2005/08/25 04:19:26 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--
-- Purpose
--
-- History
--      Thu Jul 07 2005:7/12 PM RSSHARMA Created
-- NOTE
-- End of Comments
-- ===============================================================
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_QP_PRODUCTS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(15) := 'ozfvoqppb.pls';



PROCEDURE check_qp_prod_req_items(
    p_qp_product_rec                     IN   qp_product_rec_type
    , p_validation_mode            IN   VARCHAR2
    , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_validation_mode = JTF_PLSQL_API.g_create THEN
        IF p_qp_product_rec.off_discount_product_id IS NULL OR p_qp_product_rec.off_discount_product_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','off_discount_product_id');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
        IF p_qp_product_rec.pricing_attribute_id IS NULL OR p_qp_product_rec.pricing_attribute_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','PRICING_ATTRIBUTE_ID');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
    ELSIF p_validation_mode = JTF_PLSQL_API.g_update THEN
        IF p_qp_product_rec.qp_product_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','QP_PRODUCT_ID');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
        IF p_qp_product_rec.off_discount_product_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','OFF_DISCOUNT_PRODUCT_ID');
               x_return_status := FND_API.g_ret_sts_error;
               return;
        END IF;
        IF p_qp_product_rec.pricing_attribute_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','PRICING_ATTRIBUTE_ID');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
        IF p_qp_product_rec.object_version_number = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','OBJECT_VERSION_NUMBER');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
    END IF;
END check_qp_prod_req_items;


PROCEDURE check_qp_prod_uk_items(
    p_qp_product_rec                     IN   qp_product_rec_type
    , p_validation_mode            IN   VARCHAR2
    , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_validation_mode = JTF_PLSQL_API.G_CREATE THEN
    IF p_qp_product_rec.qp_product_id IS NOT NULL AND p_qp_product_rec.qp_product_id <> FND_API.G_MISS_NUM THEN
          IF OZF_Utility_PVT.check_uniqueness('ozf_qp_products','qp_product_id = ''' || p_qp_product_rec.qp_product_id ||'''') = FND_API.g_false THEN
             OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_QP_PROD_ID_DUP');
             x_return_status := FND_API.g_ret_sts_error;
             return;
          END IF;
    END IF;

    IF
    (
        p_qp_product_rec.off_discount_product_id IS NOT NULL AND p_qp_product_rec.off_discount_product_id <> FND_API.G_MISS_NUM
    )
    AND
    (
        p_qp_product_rec.pricing_attribute_id IS NOT NULL AND p_qp_product_rec.pricing_attribute_id <> FND_API.G_MISS_NUM
    )
    THEN
          IF OZF_Utility_PVT.check_uniqueness('ozf_qp_products','off_discount_product_id = ' || p_qp_product_rec.off_discount_product_id || ' AND pricing_attribute_id = ' ||p_qp_product_rec.pricing_attribute_id) = FND_API.g_false THEN
             OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_QP_PROD_DUP');
             x_return_status := FND_API.g_ret_sts_error;
             return;
          END IF;
    END IF;
    END IF;


END check_qp_prod_uk_items;


PROCEDURE check_qp_prod_fk_items(
    p_qp_product_rec                     IN   qp_product_rec_type
    , p_validation_mode            IN   VARCHAR2
    , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_qp_product_rec.off_discount_product_id IS NOT NULL AND p_qp_product_rec.off_discount_product_id <> FND_API.G_MISS_NUM THEN
        IF ozf_utility_pvt.check_fk_exists('ozf_offer_discount_products','off_discount_product_id',to_char(p_qp_product_rec.off_discount_product_id)) = FND_API.g_false THEN
                OZF_Utility_PVT.Error_Message('OZF_INVALID_OZF_PROD_ID' );
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
     END IF;

    IF p_qp_product_rec.pricing_attribute_id IS NOT NULL AND p_qp_product_rec.pricing_attribute_id <> FND_API.G_MISS_NUM THEN
        IF ozf_utility_pvt.check_fk_exists('qp_pricing_attributes','pricing_attribute_id',to_char(p_qp_product_rec.pricing_attribute_id)) = FND_API.g_false THEN
                OZF_Utility_PVT.Error_Message('OZF_INVALID_OZF_PROD_ID' );
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
    END IF;
END check_qp_prod_fk_items;


PROCEDURE check_qp_prod_attr(
    p_qp_product_rec               IN   qp_product_rec_type
    , p_validation_mode            IN   VARCHAR2
    , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
CURSOR c_list_header(p_pricing_attribute_id NUMBER)
IS
SELECT list_header_id FROM qp_pricing_attributes WHERE pricing_attribute_id = p_pricing_attribute_id;
l_list_header NUMBER;
CURSOR c_list_header2 (p_off_discount_product_id NUMBER)
IS
SELECT qp_list_header_id FROM ozf_offers WHERE offer_id = (SELECT offer_id FROM ozf_offer_discount_products WHERE off_discount_product_id = p_off_discount_product_id);
l_list_header2 NUMBER;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN c_list_header(p_qp_product_rec.pricing_attribute_id);
    FETCH c_list_header INTO l_list_header;
    CLOSE c_list_header;

    OPEN c_list_header2(p_qp_product_rec.off_discount_product_id);
    FETCH c_list_header2 INTO l_list_header2;
    CLOSE c_list_header2;

    IF l_list_header2 <> l_list_header THEN
            OZF_Utility_PVT.Error_Message('OZF_OFFR_INVALID_PROD_PAIR');
            x_return_status := FND_API.g_ret_sts_error;
    END IF;
END check_qp_prod_attr;

PROCEDURE check_ozf_qp_prod_items(
    p_qp_product_rec                     IN   qp_product_rec_type
    , p_validation_mode            IN   VARCHAR2
    , x_return_status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    check_qp_prod_req_items
    (
            p_qp_product_rec => p_qp_product_rec
            , p_validation_mode => p_validation_mode
            , x_return_status => x_return_status
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    check_qp_prod_uk_items
    (
            p_qp_product_rec => p_qp_product_rec
            , p_validation_mode => p_validation_mode
            , x_return_status => x_return_status
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    check_qp_prod_fk_items
    (
            p_qp_product_rec => p_qp_product_rec
            , p_validation_mode => p_validation_mode
            , x_return_status => x_return_status
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

/*    check_qp_prod_attr(
                        p_qp_product_rec => p_qp_product_rec
                        , p_validation_mode => p_validation_mode
                        , x_return_status => x_return_status
                    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
*/
END check_ozf_qp_prod_items;


PROCEDURE Validate_ozf_qp_products
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_product_rec                     IN   qp_product_rec_type
    )
    IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_ozf_qp_products';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_qp_product_rec               qp_product_rec_type;

    BEGIN
    -- initialize

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check items
    IF p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM THEN
        check_ozf_qp_prod_items(
            p_qp_product_rec => p_qp_product_rec
            , p_validation_mode => p_validation_mode
            , x_return_status => x_return_status
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
          OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
--     ROLLBACK TO validate_market_options_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--     ROLLBACK TO validate_market_options_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
--     ROLLBACK TO validate_market_options_pvt;
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

    END Validate_ozf_qp_products;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_ozf_qp_product
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_qp_product_rec               IN   qp_product_rec_type
--   OUT NOCOPY
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--       x_qp_product_id  OUT NOCOPY  NUMBER. qp product id of the market option just created
--   Version : Current version 1.0
--
--   History
--
--   Description
--              : Method to Create relation between ozf and qp products
--   End of Comments
--   ==============================================================================

PROCEDURE Create_ozf_qp_product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_product_rec                     IN   qp_product_rec_type ,
    x_qp_product_id        OUT NOCOPY  NUMBER
)
IS
l_api_version_number NUMBER := 1.0;
l_api_name VARCHAR2(30) := 'Create_ozf_qp_product';
l_qp_product_rec        qp_product_rec_type;
l_qp_product_id NUMBER;
l_dummy NUMBER;
l_object_version_number NUMBER;

CURSOR c_id
IS
SELECT ozf_qp_products_s.nextval FROM dual;
CURSOR c_id_exists (p_id IN NUMBER) IS
SELECT 1
FROM ozf_qp_products
WHERE qp_product_id = p_id;

BEGIN
--INITIALIZE
    -- save point
    SAVEPOINT Create_ozf_qp_product_pvt;
    -- check api compatibility
    IF NOT FND_API.Compatible_Api_Call(
                                        l_api_version_number
                                        , p_api_version_number
                                        , l_api_name
                                        , G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- initialize messages
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- debug message start
    ozf_utility_pvt.debug_message('Private API: '|| l_api_name|| 'start');
    -- set return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF  FND_GLOBAL.USER_ID IS NULL THEN
            OZF_Utility_PVT.Error_Message('USER_PROFILE_MISSING');
            x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    l_qp_product_rec := p_qp_product_rec;

   IF p_qp_product_rec.qp_product_id IS NULL OR p_qp_product_rec.qp_product_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_qp_product_id;
         CLOSE c_id;

         OPEN c_id_exists(l_qp_product_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_qp_product_id := p_qp_product_rec.qp_product_id;
   END IF;

-- validate
validate_ozf_qp_products
(
p_api_version_number => p_api_version_number
, p_init_msg_list    => p_init_msg_list
, p_validation_level => p_validation_level
, p_validation_mode  => JTF_PLSQL_API.G_CREATE
, x_return_status    => x_return_status
, x_msg_count        => x_msg_count
, x_msg_data         => x_msg_data
, p_qp_product_rec   => l_qp_product_rec
);
IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
END IF;
-- insert
OZF_QP_PRODUCTS_PKG.Insert_row
(
px_qp_product_id            => l_qp_product_id
, p_off_discount_product_id => l_qp_product_rec.off_discount_product_id
, p_pricing_attribute_id    => l_qp_product_rec.pricing_attribute_id
, px_object_version_number  => l_object_version_number
, p_creation_date           => sysdate
, p_created_by              => FND_GLOBAL.USER_ID
, p_last_update_date       => sysdate
, p_last_updated_by         => FND_GLOBAL.USER_ID
, p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID
);

IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
END IF;

x_qp_product_id := l_qp_product_id;

IF FND_API.to_boolean(p_commit) THEN
    COMMIT WORK;
END IF;

      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

FND_MSG_PUB.COUNT_AND_GET
(
    p_count => x_msg_count
    ,p_data  => x_msg_data
);

-- exception
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
ROLLBACK TO create_ozf_qp_product_pvt;
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.COUNT_AND_GET
(
p_encoded => FND_API.G_FALSE
, p_count => x_msg_count
, p_data  => x_msg_data
);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO create_ozf_qp_products_pvt;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.COUNT_AND_GET
(
p_encoded => FND_API.G_FALSE
, p_count => x_msg_count
, p_data => x_msg_data
);

   WHEN OTHERS THEN
     ROLLBACK TO create_ozf_qp_products_pvt;
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

END Create_ozf_qp_product;


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
--       p_qp_product_rec               IN   qp_product_rec_type
--   OUT
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--
--   Description
--              : Method to Update ozf qp product relation
--   End of Comments
--   ==============================================================================
PROCEDURE Update_ozf_qp_product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_product_rec             IN   qp_product_rec_type
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'Update_ozf_qp_product';
l_api_version_number CONSTANT NUMBER:= 1.0;


CURSOR c_get_qp_prod(p_qp_product_id NUMBER, p_object_version_number NUMBER) IS
    SELECT *
    FROM ozf_qp_products
    WHERE qp_product_id = p_qp_product_id
    AND object_version_number = p_object_version_number;
    -- Hint: Developer need to provide Where clause

-- Local Variables
l_object_version_number     NUMBER;
l_market_option_id    NUMBER;
l_ref_qp_prod_rec  c_get_qp_prod%ROWTYPE ;
l_tar_qp_prod_rec  qp_product_rec_type := p_qp_product_rec ;
l_rowid  ROWID;

BEGIN
-- initialize
SAVEPOINT Update_ozf_qp_product_pvt;
IF NOT FND_API.Compatible_api_call(l_api_version_number
                                    , p_api_version_number
                                    , l_api_name
                                    , g_pkg_name)
 THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;
      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN c_get_qp_prod( l_tar_qp_prod_rec.qp_product_id,l_tar_qp_prod_rec.object_version_number);
          FETCH c_get_qp_prod INTO l_ref_qp_prod_rec  ;
       If ( c_get_qp_prod%NOTFOUND) THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'OZF_MARKET_OPTIONS') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE c_get_qp_prod;

      If (l_tar_qp_prod_rec.object_version_number is NULL or
          l_tar_qp_prod_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING'
                                           , p_token_name   => 'COLUMN'
                                           , p_token_value  => 'Last_Update_Date') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_qp_prod_rec.object_version_number <> l_ref_qp_prod_rec.object_version_number) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'Ozf_Market_Options') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;
-- validate
validate_ozf_qp_products
(
p_api_version_number => p_api_version_number
, p_init_msg_list    => p_init_msg_list
, p_validation_level => p_validation_level
, p_validation_mode  => JTF_PLSQL_API.G_UPDATE
, x_return_status    => x_return_status
, x_msg_count        => x_msg_count
, x_msg_data         => x_msg_data
, p_qp_product_rec   => l_tar_qp_prod_rec
);
IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
END IF;

-- update
OZF_QP_PRODUCTS_PKG.Update_Row(
            p_qp_product_id => l_tar_qp_prod_rec.qp_product_id
            , p_off_discount_product_id => l_tar_qp_prod_rec.off_discount_product_id
            , p_pricing_attribute_id    => l_tar_qp_prod_rec.pricing_attribute_id
            , p_object_version_number   =>     l_tar_qp_prod_rec.object_version_number
            , p_last_update_date        => sysdate
            , p_last_updated_by         => FND_GLOBAL.USER_ID
            , p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID
          );
-- get messages
IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
END IF;
-- commit
IF FND_API.to_boolean(p_commit) THEN
    COMMIT WORK;
END IF;
ozf_utility_pvt.debug_message('Private API : '||l_api_name || ' End');
FND_MSG_PUB.count_and_get
(
p_count => x_msg_count
, p_data => x_msg_data
);
-- exception
EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

WHEN FND_API.G_EXC_ERROR THEN
ROLLBACK TO Update_ozf_qp_product_pvt;
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO Update_ozf_qp_product_pvt;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.G_FALSE
    , p_count => x_msg_count
    , p_data => x_msg_data
    );
WHEN OTHERS THEN
ROLLBACK TO Update_ozf_qp_product_pvt;
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

NULL;
END Update_ozf_qp_product;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_ozf_qp_product
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
--    p_qp_product_id              IN  NUMBER
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
PROCEDURE Delete_ozf_qp_product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_qp_product_id              IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )
    IS
    l_api_version_number CONSTANT number := 1.0;
    l_api_name CONSTANT VARCHAR2(30) := 'Delete_ozf_qp_product';
    BEGIN
    -- initialize
    SAVEPOINT Delete_ozf_qp_product_pvt;
    IF NOT FND_API.Compatible_API_call
    (
    l_api_version_number
    , p_api_version_number
    , l_api_name
    , g_pkg_name
    ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- delete
    OZF_QP_PRODUCTS_PKG.Delete_Row(
                p_qp_product_id => p_qp_product_id
                , p_object_version_number  => p_object_version_number
                );

    -- commit
    IF FND_API.to_boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
    -- get messages
    FND_MSG_PUB.count_and_get(
    p_count => x_msg_count
    , p_data => x_msg_data
    );
    -- exception
    EXCEPTION
    WHEN OZF_UTILITY_PVT.resource_locked THEN
                OZF_Utility_PVT.Error_Message('OZF_API_RESOURCE_LOCKED');
                x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.G_EXC_ERROR THEN
            rollback to Delete_ozf_qp_product_pvt;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.COUNT_AND_GET(
                        p_encoded => FND_API.G_FALSE
                        , p_count => x_msg_count
                        , p_data => x_msg_data
            );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_ozf_qp_product_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get(
                    p_encoded => FND_API.G_FALSE
                    , p_count => x_msg_count
                    , p_data  => x_msg_data
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

    END Delete_ozf_qp_product;


END OZF_QP_PRODUCTS_PVT;


/
