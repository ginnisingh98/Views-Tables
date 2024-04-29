--------------------------------------------------------
--  DDL for Package Body OZF_QP_DISCOUNTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_QP_DISCOUNTS_PVT" AS
/* $Header: ozfvoqpdb.pls 120.3 2005/08/24 06:47 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--
-- Purpose
--
-- History
--      Thu Jul 07 2005:7/12 PM RSSHARMA Created
-- Wed Aug 24 2005:2/0 AM RSSHARMA Made all inout and out params nocopy
-- NOTE

-- End of Comments
-- ===============================================================
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_QP_DISCOUNTS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(15) := 'ozfvoqpdb.pls';

PROCEDURE check_qp_disc_inter_attr
(
p_qp_disc_rec IN qp_discount_rec_type
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
CURSOR c_valid_offer(p_offer_discount_line_id NUMBER, p_list_line_id NUMBER) IS
SELECT 1 FROM DUAL
WHERE exists
(
SELECT 'X' FROM qp_list_lines a, ozf_offer_discount_lines b, ozf_offers c WHERE
a.list_header_id = c.qp_list_header_id
AND b.offer_id = c.offer_id
AND a.list_line_id = p_list_line_id
AND b.offer_discount_line_id = p_offer_discount_line_id
);
l_dummy NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
OPEN c_valid_offer(p_qp_disc_rec.offer_discount_line_id, p_qp_disc_rec.list_line_id);
FETCH c_valid_offer INTO l_dummy;
    IF c_valid_offer%NOTFOUND THEN
        OZF_UTILITY_PVT.Error_message('OZF_QP_DISC_INV_LL_DL');
        x_return_status := FND_API.G_RET_STS_ERROR;
        CLOSE c_valid_offer;
        RETURN;
    ELSE
        CLOSE c_valid_offer;
    END IF;
END check_qp_disc_inter_attr;

PROCEDURE check_qp_disc_req_items
(
p_qp_disc_rec   IN qp_discount_rec_type
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_validation_mode = JTF_PLSQL_API.g_create THEN
        IF p_qp_disc_rec.list_line_id IS NULL OR p_qp_disc_rec.list_line_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','list_line_id');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
        IF p_qp_disc_rec.offer_discount_line_id IS NULL OR p_qp_disc_rec.offer_discount_line_id = FND_API.G_MISS_NUM  THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','offer_discount_line_id');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
    ELSE
        IF p_qp_disc_rec.ozf_qp_discount_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','ozf_qp_discount_id');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
        IF p_qp_disc_rec.list_line_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','list_line_id');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
        IF p_qp_disc_rec.offer_discount_line_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','offer_discount_line_id');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;

        IF p_qp_disc_rec.object_version_number = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','object_version_number');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
    END IF;
END check_qp_disc_req_items;

PROCEDURE check_qp_disc_uk_items
(
p_qp_disc_rec   IN qp_discount_rec_type
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_validation_mode = JTF_PLSQL_API.g_create THEN
        IF p_qp_disc_rec.ozf_qp_discount_id IS NOT NULL AND p_qp_disc_rec.ozf_qp_discount_id <> FND_API.G_MISS_NUM THEN
            IF OZF_UTILITY_PVT.check_uniqueness('ozf_qp_discounts', 'ozf_qp_discount_id = '||p_qp_disc_rec.ozf_qp_discount_id) = FND_API.G_FALSE THEN
                    OZF_Utility_PVT.Error_Message('OZF_QP_DISC_PK_DUP');
                    x_return_status := FND_API.g_ret_sts_error;
                    return;
            END IF;
        END IF;
    END IF;

    IF
    (
    (p_qp_disc_rec.list_line_id IS NOT NULL AND p_qp_disc_rec.list_line_id <> FND_API.G_MISS_NUM)
    AND
    (p_qp_disc_rec.offer_discount_line_id IS NOT NULL AND p_qp_disc_rec.offer_discount_line_id <> FND_API.G_MISS_NUM)
    )
    THEN
        IF OZF_UTILITY_PVT.check_uniqueness('ozf_qp_discounts', ' list_line_id = '|| p_qp_disc_rec.list_line_id || ' AND offer_discount_line_id = '|| p_qp_disc_rec.offer_discount_line_id) = FND_API.G_FALSE THEN
                OZF_Utility_PVT.Error_Message('OZF_QP_DISC_DUP');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
    END IF;
END check_qp_disc_uk_items;

PROCEDURE check_qp_disc_fk_items
(
p_qp_disc_rec   IN qp_discount_rec_type
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_qp_disc_rec.list_line_id IS NOT NULL AND p_qp_disc_rec.list_line_id <> FND_API.G_MISS_NUM THEN
        IF ozf_utility_pvt.check_fk_exists('qp_list_lines', 'list_line_id',to_char(p_qp_disc_rec.list_line_id)) = FND_API.G_FALSE THEN
                OZF_Utility_PVT.Error_Message('OZF_QP_DISC_INV_LLID');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
    END IF;
    IF p_qp_disc_rec.offer_discount_line_id IS NOT NULL AND p_qp_disc_rec.offer_discount_line_id <> FND_API.G_MISS_NUM THEN
        IF ozf_utility_pvt.check_fk_exists('ozf_offer_discount_lines','offer_discount_line_id', to_char(p_qp_disc_rec.offer_discount_line_id)) = FND_API.G_FALSE THEN
                OZF_Utility_PVT.Error_Message('OZF_QP_DISC_INV_ODID');
                x_return_status := FND_API.g_ret_sts_error;
                return;
        END IF;
    END IF;
END check_qp_disc_fk_items;



PROCEDURE check_ozf_qp_disc_items
(
p_qp_disc_rec   IN qp_discount_rec_type
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
check_qp_disc_req_items
(
p_qp_disc_rec => p_qp_disc_rec
, p_validation_mode => p_validation_mode
, x_return_status => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

check_qp_disc_uk_items
(
p_qp_disc_rec => p_qp_disc_rec
, p_validation_mode => p_validation_mode
, x_return_status   => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

check_qp_disc_fk_items
(
p_qp_disc_rec => p_qp_disc_rec
, p_validation_mode => p_validation_mode
, x_return_status   => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

check_qp_disc_inter_attr
(
p_qp_disc_rec => p_qp_disc_rec
, p_validation_mode => p_validation_mode
, x_return_status => x_return_status
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END check_ozf_qp_disc_items;

PROCEDURE Validate_ozf_qp_discounts
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.g_create,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_disc_rec                 IN    qp_discount_rec_type
)
IS
l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'Validate_ozf_qp_discounts';

BEGIN
IF NOT FND_API.Compatible_api_call(
                                    l_api_version_number
                                    , p_api_version_number
                                    , l_api_name
                                    , g_pkg_name
                                    ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

ozf_utility_pvt.debug_message('Private API: '|| l_api_name || ' Start');

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM THEN
    check_ozf_qp_disc_items(
    p_qp_disc_rec => p_qp_disc_rec
    , p_validation_mode => p_validation_mode
    , x_return_status => x_return_status
    );
END IF;
ozf_utility_pvt.debug_message('Private API: '|| l_api_name || ' End');
NULL;
END Validate_ozf_qp_discounts;

PROCEDURE Create_ozf_qp_discount
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_disc_rec               IN    qp_discount_rec_type,
    x_qp_discount_id             OUT NOCOPY NUMBER
)
IS
l_api_version_number CONSTANT NUMBER:= 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'Create_ozf_qp_discount';
l_dummy NUMBER;
l_ozf_qp_discount_id NUMBER;
l_object_version_number NUMBER;
l_qp_disc_rec qp_discount_rec_type;

CURSOR c_id IS
SELECT ozf_qp_discounts_s.nextval FROM DUAL;

CURSOR c_id_exists(p_qp_discount_id NUMBER)
is
SELECT 1 FROM dual
WHERE EXISTS(SELECT 'X' FROM ozf_qp_discounts WHERE ozf_qp_discount_id = p_qp_discount_id);

BEGIN
-- INITIALIZE
    -- savepoint
    SAVEPOINT Create_ozf_qp_discount;
    -- check api compatibility
    IF NOT FND_API.Compatible_API_Call( l_api_version_number
                                        , p_api_version_number
                                        , l_api_name
                                        , G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- initialize messages
    FND_MSG_PUB.initialize;
    -- debug start
    ozf_utility_pvt.debug_message('Private API: '||l_api_name||' Start');
    -- set return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF  FND_GLOBAL.USER_ID IS NULL THEN
            OZF_Utility_PVT.Error_Message('USER_PROFILE_MISSING');
            x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    l_qp_disc_rec :=  p_qp_disc_rec;

    IF p_qp_disc_rec.ozf_qp_discount_id IS NULL OR p_qp_disc_rec.ozf_qp_discount_id = FND_API.G_MISS_NUM THEN
    LOOP
        l_dummy := null;
        OPEN c_id;
            FETCH c_id INTO l_ozf_qp_discount_id;
        CLOSE c_id;
        OPEN c_id_exists(l_ozf_qp_discount_id);
            FETCH c_id_exists INTO l_dummy;
        CLOSE c_id_exists;
        EXIT WHEN l_dummy IS NULL;
     END LOOP;
     ELSE
        l_ozf_qp_discount_id := p_qp_disc_rec.ozf_qp_discount_id;
    END IF;
-- validate

    Validate_ozf_qp_discounts
    (
    p_api_version_number         => p_api_version_number
    , p_init_msg_list           => p_init_msg_list
    , p_commit                  => p_commit
    , p_validation_level        => p_validation_level
    , p_validation_mode         => JTF_PLSQL_API.g_create
    , x_return_status           => x_return_status
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , p_qp_disc_rec             => p_qp_disc_rec
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
-- insert
   OZF_QP_DISCOUNTS_PKG.Insert_row
   (
   px_qp_discount_id => l_ozf_qp_discount_id
   , p_list_line_id => p_qp_disc_rec.list_line_id
   , p_offer_discount_line_id => p_qp_disc_rec.offer_discount_line_id
   , px_object_version_number => l_object_version_number
   , p_creation_date         => sysdate
   , p_created_by            => FND_GLOBAL.user_id
   , p_last_update_date      => sysdate
   , p_last_updated_by       => FND_GLOBAL.user_id
   , p_last_update_login     => FND_GLOBAL.conc_login_id
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

x_qp_discount_id := l_ozf_qp_discount_id;
ozf_utility_pvt.debug_message('Private API: '|| l_api_name || ' End');
-- commit
   IF FND_API.to_boolean(p_commit) THEN
    COMMIT WORK;
   END IF;
-- collect messages
    FND_MSG_PUB.count_and_get
    (
    p_count => x_msg_count
    , p_data =>x_msg_data
    );
-- exception
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_ozf_qp_discount;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
    (
    p_encoded => FND_API.G_FALSE
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_ozf_qp_discount;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get
    (
    p_encoded => FND_API.G_FALSE
    , p_count => x_msg_count
    , p_data => x_msg_data
    );
WHEN OTHERS THEN
    ROLLBACK TO Create_ozf_qp_discount;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.G_FALSE
    , p_data => x_msg_data
    , p_count => x_msg_count
    );
END Create_ozf_qp_discount;



PROCEDURE Update_ozf_qp_discount
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_disc_rec               IN    qp_discount_rec_type
)
IS
l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'Update_ozf_qp_discount';

CURSOR c_get_qp_disc(p_ozf_qp_discount_id NUMBER, p_object_version_number NUMBER)
IS
SELECT * FROM ozf_qp_discounts
WHERE ozf_qp_discount_id = p_ozf_qp_discount_id
AND object_version_number = p_object_version_number;

l_ref_qp_disc c_get_qp_disc%ROWTYPE;

l_tar_qp_disc qp_discount_rec_type := p_qp_disc_rec;

BEGIN
SAVEPOINT Update_ozf_qp_discount;
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



IF l_tar_qp_disc.object_version_number IS NULL OR l_tar_qp_disc.object_version_number = FND_API.G_MISS_NUM THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING'
                                           , p_token_name   => 'COLUMN'
                                           , p_token_value  => 'Last_Update_Date') ;
           RAISE FND_API.G_EXC_ERROR;

END IF;

OPEN c_get_qp_disc(l_tar_qp_disc.ozf_qp_discount_id, l_tar_qp_disc.object_version_number);
FETCH c_get_qp_disc INTO l_ref_qp_disc;
IF (c_get_qp_disc%NOTFOUND) THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'OZF_QP_DISC') ;
           RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE c_get_qp_disc;

IF l_tar_qp_disc.object_version_number <> l_ref_qp_disc.object_version_number THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'OZF_QP_DISC') ;
          RAISE FND_API.G_EXC_ERROR;
END IF;

Validate_ozf_qp_discounts
(
p_api_version_number => p_api_version_number
, p_init_msg_list      => p_init_msg_list
, p_commit             => p_validation_level
, p_validation_level   => p_validation_level
, p_validation_mode    => JTF_PLSQL_API.g_update
, x_return_status      => x_return_status
, x_msg_count          => x_msg_count
, x_msg_data           => x_msg_data
, p_qp_disc_rec        => p_qp_disc_rec
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

OZF_QP_DISCOUNTS_PKG.Update_row
(
p_qp_discount_id  => p_qp_disc_rec.ozf_qp_discount_id
, p_list_line_id  => p_qp_disc_rec.list_line_id
, p_offer_discount_line_id => p_qp_disc_rec.offer_discount_line_id
, p_object_version_number   => p_qp_disc_rec.object_version_number
, p_last_update_date        => sysdate
, p_last_updated_by         => FND_GLOBAL.user_id
, p_last_update_login       => FND_GLOBAL.conc_login_id
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

FND_MSG_PUB.count_and_get
(
p_data  => x_msg_data
, p_count => x_msg_count
);

EXCEPTION
WHEN OZF_Utility_PVT.resource_locked THEN
x_return_status := FND_API.g_ret_sts_error;
OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

WHEN FND_API.G_EXC_ERROR THEN
ROLLBACK TO Update_ozf_qp_discount;
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO Update_ozf_qp_discount;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN OTHERS THEN
ROLLBACK TO Update_ozf_qp_discount;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_exc_msg(G_PKG_NAME, l_api_name);
END IF;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
END Update_ozf_qp_discount;

PROCEDURE Delete_ozf_qp_discount
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qp_discount_id             IN NUMBER,
    p_object_version_number      IN NUMBER
)
IS
l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'Delete_ozf_qp_discount';
BEGIN
SAVEPOINT Delete_ozf_qp_discount;
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
ozf_utility_pvt.debug_message('Private API: '|| l_api_name|| ' Start');

x_return_status := FND_API.G_RET_STS_SUCCESS;

OZF_QP_DISCOUNTS_PKG.Delete_row(
p_qp_discount_id => p_qp_discount_id
, p_object_version_number => p_object_version_number
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF FND_API.to_boolean(p_commit) THEN
COMMIT WORK;
END IF;

 FND_MSG_PUB.count_and_get(
      p_count => x_msg_count
     , p_data  => x_msg_data
     );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
ROLLBACK TO Delete_ozf_qp_discount;
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO Delete_ozf_qp_discount;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN OTHERS THEN
ROLLBACK TO Delete_ozf_qp_discount;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,l_api_name);
END IF;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
END Delete_ozf_qp_discount;

END OZF_QP_DISCOUNTS_PVT;

/
