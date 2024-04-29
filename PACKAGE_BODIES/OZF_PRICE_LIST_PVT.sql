--------------------------------------------------------
--  DDL for Package Body OZF_PRICE_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PRICE_LIST_PVT" as
/* $Header: ozfvprlb.pls 120.0 2005/05/31 23:54:23 appldev noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_PRICE_LIST_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvprlb.pls';



FUNCTION get_user_status_name(p_user_status_id IN NUMBER) return VARCHAR2 IS
l_user_status_name VARCHAR2(120);
CURSOR cur_user_status_name IS
SELECT name
  FROM ams_user_statuses_vl
 WHERE user_status_id = p_user_status_id;

BEGIN

  OPEN cur_user_status_name;
  FETCH cur_user_status_name into l_user_status_name;
  CLOSE cur_user_status_name;
  return l_user_status_name;

END;

PROCEDURE Check_Uk_Items
(
   p_validation_mode      IN         VARCHAR2 := JTF_PLSQL_API.g_create,
   p_ozf_price_list_rec   IN         OZF_PRICE_LIST_Rec_Type,
   x_return_status         OUT NOCOPY       VARCHAR2
)
IS

   l_uk_flag      VARCHAR2(1);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_ozf_price_list_rec.price_list_attribute_id IS NOT NULL AND p_ozf_price_list_rec.price_list_attribute_id <> FND_API.G_MISS_NUM
   THEN
      l_uk_flag := OZF_Utility_PVT.check_uniqueness
                         (
		    'OZF_PRICE_LIST_ATTRIBUTES',
		    'price_list_attribute_id = ' || p_ozf_price_list_rec.price_list_attribute_id
                         );
   END IF;
   IF l_uk_flag = FND_API.g_false THEN

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)	THEN
         FND_MESSAGE.set_name('OZF', 'OZF_PRICE_LIST_DUP_PK');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_ozf_price_list_rec.qp_list_header_id IS NOT NULL
   THEN
      l_uk_flag := OZF_Utility_PVT.check_uniqueness
                         (
		    'OZF_PRICE_LIST_ATTRIBUTES',
		    'qp_list_header_id = ' || p_ozf_price_list_rec.qp_list_header_id
                         );
   END IF;

   IF l_uk_flag = FND_API.g_false THEN

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)	THEN
         FND_MESSAGE.set_name('OZF', 'OZF_PRICE_LIST_DUP_PK');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
END;

PROCEDURE Check_Fk_Items
(
   p_ozf_price_list_rec      IN         ozf_price_list_rec_type,
   x_return_status      OUT NOCOPY       VARCHAR2
)
IS
   l_fk_flag          VARCHAR2(1);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_ozf_price_list_rec.qp_list_header_id <> FND_API.g_miss_num THEN
      l_fk_flag := OZF_Utility_PVT.check_fk_exists
                         (
                            'QP_LIST_HEADERS_B',
                            'list_header_id',
                            p_ozf_price_list_rec.qp_list_header_id
                         );

        IF l_fk_flag = FND_API.g_false THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_PRICE_LIST_NO_QP_LIST');
            FND_MSG_PUB.add;
          END IF;

	 x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
END;

PROCEDURE Check_Lookup_Items
(
   p_ozf_price_list_rec      IN         ozf_price_list_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS

BEGIN

    x_return_status := FND_API.g_ret_sts_success;

   IF    p_ozf_price_list_rec.status_code <> FND_API.g_miss_char
       AND p_ozf_price_list_rec.status_code IS NOT NULL
    THEN
         IF OZF_Utility_PVT.check_lookup_exists(
                  p_lookup_type => 'OZF_PRICELIST_STATUS',
                  p_lookup_code => p_ozf_price_list_rec.status_code
             ) = FND_API.g_false
         THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
             THEN
                  FND_MESSAGE.set_name('OZF', 'OZ0_CAMP_BAD_STATUS_CHANGE');
                  FND_MSG_PUB.add;
             END IF;
             x_return_status := FND_API.g_ret_sts_error;
             RETURN;
         END IF;
    END IF;
    NULL;
END;

PROCEDURE Check_Req_Items
(
   p_validation_mode       IN         VARCHAR2,
   p_ozf_price_list_rec    IN         ozf_price_list_rec_type,
   x_return_status         OUT NOCOPY        VARCHAR2
)
IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
/*
   IF (p_ozf_price_list_rec.price_list_attribute_id IS NULL OR p_ozf_price_list_rec.price_list_attribute_id = FND_API.g_miss_num)
      AND p_validation_mode = JTF_PLSQL_API.g_update
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_NO_PRICE_LIST_ATTR_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
*/
   IF (p_ozf_price_list_rec.object_version_number IS NULL OR p_ozf_price_list_rec.object_version_number = FND_API.g_miss_num)
      AND p_validation_mode = JTF_PLSQL_API.g_update
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_NO_OBJ_VER_NUM');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF ( p_ozf_price_list_rec.qp_list_header_id IS NULL OR p_ozf_price_list_rec.qp_list_header_id = FND_API.g_miss_num )
      AND p_validation_mode = JTF_PLSQL_API.g_create
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_NO_LIST_HEAD_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF ( p_ozf_price_list_rec.status_code IS NULL OR p_ozf_price_list_rec.status_code = FND_API.g_miss_char )
      AND p_validation_mode = JTF_PLSQL_API.g_create
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CAMP_NO_STATUS_CODE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

    IF ( p_ozf_price_list_rec.owner_id IS NULL OR p_ozf_price_list_rec.owner_id = FND_API.g_miss_num )
      AND p_validation_mode = JTF_PLSQL_API.g_create
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_PRIC_NO_OWNER_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

    IF ( p_ozf_price_list_rec.user_status_id IS NULL OR p_ozf_price_list_rec.user_status_id = FND_API.g_miss_num )
      AND p_validation_mode = JTF_PLSQL_API.g_create
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CAMP_NO_USER_STATUS_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

    IF ( p_ozf_price_list_rec.custom_setup_id IS NULL OR p_ozf_price_list_rec.custom_setup_id = FND_API.g_miss_num )
      AND p_validation_mode = JTF_PLSQL_API.g_create
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_PRIC_NO_CUSTOM_SETUP_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
END;

PROCEDURE Check_OZF_PRICE_LIST_Items (
    P_OZF_PRICE_LIST_Rec     IN    OZF_PRICE_LIST_Rec_Type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN
  x_return_status := FND_API.g_ret_sts_success;

 check_req_items
   (
      p_validation_mode => p_validation_mode,
      P_OZF_PRICE_LIST_Rec      => P_OZF_PRICE_LIST_Rec,
      x_return_status    => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

  check_uk_items
   (
      p_validation_mode => p_validation_mode,
      P_OZF_PRICE_LIST_Rec      => P_OZF_PRICE_LIST_Rec,
      x_return_status    => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- check foreign key items
   check_fk_items
   (
      P_OZF_PRICE_LIST_Rec      => P_OZF_PRICE_LIST_Rec,
      x_return_status => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- check lookup items
   check_lookup_items
   (
      P_OZF_PRICE_LIST_Rec      => P_OZF_PRICE_LIST_Rec,
      x_return_status => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


END Check_OZF_PRICE_LIST_Items;


PROCEDURE Validate_OZF_PRICE_LIST_rec(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_OZF_PRICE_LIST_Rec     IN    OZF_PRICE_LIST_Rec_Type
    )
IS
BEGIN

      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      NULL;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_OZF_PRICE_LIST_Rec;

PROCEDURE Complete_OZF_PRICE_LIST_Rec(
         p_OZF_PRICE_LIST_rec      IN    OZF_PRICE_LIST_Rec_Type,
         x_complete_rec            OUT NOCOPY   OZF_PRICE_LIST_Rec_Type
      )
 IS
   CURSOR c_ozf_price_list IS
   SELECT *
     FROM OZF_price_list_attributes
--    WHERE price_list_attribute_id = p_ozf_price_list_rec.price_list_attribute_id;
    WHERE qp_list_header_id = p_ozf_price_list_rec.qp_list_header_id;

   l_price_list_rec  c_ozf_price_list%ROWTYPE;

BEGIN

   x_complete_rec := p_OZF_PRICE_LIST_rec;

   OPEN c_ozf_price_list;
   FETCH c_ozf_price_list INTO l_price_list_rec;

   IF (c_ozf_price_list%NOTFOUND) THEN
      CLOSE c_ozf_price_list;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_ozf_price_list;


   IF p_OZF_PRICE_LIST_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := NULL;
   END IF;
   IF p_OZF_PRICE_LIST_rec.status_code IS NULL THEN
      x_complete_rec.status_code := l_price_list_rec.status_code;
   END IF;

   IF p_OZF_PRICE_LIST_rec.status_date = FND_API.g_miss_date
      OR p_OZF_PRICE_LIST_rec.status_date IS NULL
   THEN
      IF x_complete_rec.status_date = l_price_list_rec.status_date THEN
      -- no status change, set it to be the original value
         x_complete_rec.status_date := l_price_list_rec.status_date;
      ELSE
      -- status changed, set it to be SYSDATE
         x_complete_rec.status_date := SYSDATE;
      END IF;
   END IF;
/*
   IF p_OZF_PRICE_LIST_rec.qp_list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.qp_list_header_id := NULL;
   END IF;
   IF p_OZF_PRICE_LIST_rec.qp_list_header_id IS NULL THEN
      x_complete_rec.qp_list_header_id := l_price_list_rec.qp_list_header_id;
   END IF;
*/
   IF p_OZF_PRICE_LIST_rec.price_list_attribute_id = FND_API.g_miss_num THEN
      x_complete_rec.price_list_attribute_id := NULL;
   END IF;
   IF p_OZF_PRICE_LIST_rec.price_list_attribute_id IS NULL THEN
      x_complete_rec.price_list_attribute_id := l_price_list_rec.price_list_attribute_id;
   END IF;


   IF p_OZF_PRICE_LIST_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := NULL;
   END IF;
   IF p_OZF_PRICE_LIST_rec.user_status_id IS NULL THEN
      x_complete_rec.user_status_id := l_price_list_rec.user_status_id;
   END IF;

   IF p_OZF_PRICE_LIST_rec.custom_setup_id = FND_API.g_miss_num THEN
      x_complete_rec.custom_setup_id := NULL;
   END IF;
   IF p_OZF_PRICE_LIST_rec.custom_setup_id IS NULL THEN
      x_complete_rec.custom_setup_id := l_price_list_rec.custom_setup_id;
   END IF;

   IF p_OZF_PRICE_LIST_rec.owner_id = FND_API.g_miss_num THEN
      x_complete_rec.owner_id := NULL;
   END IF;
   IF p_OZF_PRICE_LIST_rec.owner_id IS NULL THEN
      x_complete_rec.owner_id := l_price_list_rec.owner_id;
   END IF;

   IF p_OZF_PRICE_LIST_rec.wf_item_key = FND_API.g_miss_char THEN
      x_complete_rec.wf_item_key := NULL;
   END IF;
   IF p_OZF_PRICE_LIST_rec.wf_item_key IS NULL THEN
      x_complete_rec.wf_item_key := l_price_list_rec.wf_item_key;
   END IF;


END ;

PROCEDURE Validate_price_list(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_Validation_mode            IN   VARCHAR2 := 'CREATE',
    P_OZF_PRICE_LIST_Rec         IN   OZF_PRICE_LIST_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
 l_api_name                CONSTANT VARCHAR2(30) := 'Validate_price_list';
 l_api_version_number      CONSTANT NUMBER   := 1.0;
 l_object_version_number     NUMBER;
 l_OZF_PRICE_LIST_rec  OZF_PRICE_LIST_Rec_Type := P_OZF_PRICE_LIST_Rec;
 BEGIN

      SAVEPOINT VALIDATE_PRICE_LIST_;

      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

   If p_validation_mode = 'UPDATE' THEN
      Complete_OZF_PRICE_LIST_Rec(
         p_OZF_PRICE_LIST_rec        => p_OZF_PRICE_LIST_rec,
         x_complete_rec      => l_OZF_PRICE_LIST_rec
      );
   END IF;
ozf_utility_pvt.debug_message(l_OZF_PRICE_LIST_rec.status_code);
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_OZF_PRICE_LIST_Items(
                 p_OZF_PRICE_LIST_rec        => l_OZF_PRICE_LIST_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );
ozf_utility_pvt.debug_message(x_return_status);
              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

	 Validate_OZF_PRICE_LIST_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           P_OZF_PRICE_LIST_Rec     => l_OZF_PRICE_LIST_Rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

       -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO VALIDATE_PRICE_LIST_;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO VALIDATE_PRICE_LIST_;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO VALIDATE_PRICE_LIST_;
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
End Validate_price_list;


PROCEDURE Lock_Row(
          p_PRICE_LIST_ATTRIBUTE_ID    NUMBER,
          p_USER_STATUS_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_OWNER_ID    NUMBER,
          p_QP_LIST_HEADER_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_STATUS_DATE    DATE,
          p_WF_ITEM_KEY    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATED_BY    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_PRICE_LIST_ATTRIBUTES
        WHERE PRICE_LIST_ATTRIBUTE_ID =  p_PRICE_LIST_ATTRIBUTE_ID
        FOR UPDATE of PRICE_LIST_ATTRIBUTE_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
   NULL;
END Lock_Row;


PROCEDURE Create_price_list(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_OZF_PRICE_LIST_Rec         IN   OZF_PRICE_LIST_Rec_Type  := G_MISS_OZF_PRICE_LIST_REC,
    X_PRICE_LIST_ATTRIBUTE_ID    OUT NOCOPY  NUMBER
   )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_price_list';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_object_version_number     NUMBER := 1;
l_org_id     NUMBER := FND_API.G_MISS_NUM;
l_PRICE_LIST_ATTRIBUTE_ID    NUMBER;

 CURSOR C2 IS SELECT OZF_PRICE_LIST_ATTRIBUTES_S.nextval FROM sys.dual;

 BEGIN

      SAVEPOINT CREATE_PRICE_LIST_PVT;


      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (P_OZF_PRICE_LIST_Rec.PRICE_LIST_ATTRIBUTE_ID IS NULL OR P_OZF_PRICE_LIST_Rec.PRICE_LIST_ATTRIBUTE_ID = FND_API.G_MISS_NUM) THEN
        OPEN C2;
        FETCH C2 INTO l_PRICE_LIST_ATTRIBUTE_ID;
        CLOSE C2;
     ELSE
        L_PRICE_LIST_ATTRIBUTE_ID := P_OZF_PRICE_LIST_Rec.PRICE_LIST_ATTRIBUTE_ID;
     END IF;

   IF (P_OZF_PRICE_LIST_Rec.OBJECT_VERSION_NUMBER IS NULL OR
       P_OZF_PRICE_LIST_Rec.OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM) THEN
       l_OBJECT_VERSION_NUMBER := 1;
   END IF;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN

          Validate_price_list(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_level       => p_validation_level,
   	        p_validation_mode        => 'CREATE',
            P_OZF_PRICE_LIST_Rec     => P_OZF_PRICE_LIST_Rec,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);

      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
         INSERT INTO OZF_PRICE_LIST_ATTRIBUTES(
           PRICE_LIST_ATTRIBUTE_ID,
           USER_STATUS_ID,
           CUSTOM_SETUP_ID,
           STATUS_CODE,
           OWNER_ID,
           QP_LIST_HEADER_ID,
           OBJECT_VERSION_NUMBER,
           STATUS_DATE,
           WF_ITEM_KEY,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATED_BY
          ) VALUES (
           l_price_list_attribute_id,
           decode( p_OZF_PRICE_LIST_rec.USER_STATUS_ID, FND_API.G_MISS_NUM, NULL, p_OZF_PRICE_LIST_rec.USER_STATUS_ID),
           decode( p_OZF_PRICE_LIST_rec.CUSTOM_SETUP_ID, FND_API.G_MISS_NUM, NULL, p_OZF_PRICE_LIST_rec.CUSTOM_SETUP_ID),
           decode( p_OZF_PRICE_LIST_rec.STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_OZF_PRICE_LIST_rec.STATUS_CODE),
           decode( p_OZF_PRICE_LIST_rec.OWNER_ID, FND_API.G_MISS_NUM, NULL, p_OZF_PRICE_LIST_rec.OWNER_ID),
           decode( p_OZF_PRICE_LIST_rec.QP_LIST_HEADER_ID, FND_API.G_MISS_NUM, NULL, p_OZF_PRICE_LIST_rec.QP_LIST_HEADER_ID),
           1,
           decode( p_OZF_PRICE_LIST_rec.STATUS_DATE, FND_API.G_MISS_DATE, NULL, p_OZF_PRICE_LIST_rec.STATUS_DATE),
           decode( p_OZF_PRICE_LIST_rec.WF_ITEM_KEY, FND_API.G_MISS_CHAR, NULL, p_OZF_PRICE_LIST_rec.WF_ITEM_KEY),
           FND_GLOBAL.USER_ID,
	         SYSDATE,
           SYSDATE,
           FND_GLOBAL.CONC_LOGIN_ID,
           FND_GLOBAL.USER_ID);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
      x_price_list_attribute_id := l_price_list_attribute_id;

      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CREATE_PRICE_LIST_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_PRICE_LIST_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO CREATE_PRICE_LIST_PVT;
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
End Create_price_list;

PROCEDURE Update_price_list(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_OZF_PRICE_LIST_Rec     IN    OZF_PRICE_LIST_Rec_Type,
    X_Object_Version_Number      OUT NOCOPY  NUMBER
    )
 IS

l_api_name                CONSTANT VARCHAR2(30) := 'Update_price_list';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_PRICE_LIST_ATTRIBUTE_ID    NUMBER;
l_rowid  ROWID;

  CURSOR c_is_qp_pricelist(p_id NUMBER) IS
  SELECT 'N'
  FROM   ozf_price_list_attributes
  WHERE  qp_list_header_id = p_id;
  l_is_qp_pricelist VARCHAR2(1);
 BEGIN

      SAVEPOINT UPDATE_PRICE_LIST_PVT;


      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_is_qp_pricelist(p_ozf_price_list_rec.qp_list_header_id);
  FETCH c_is_qp_pricelist INTO l_is_qp_pricelist;
  CLOSE c_is_qp_pricelist;

  IF l_is_qp_pricelist = 'N' THEN -- bug 3780070 exception when updating price list created from QP
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          Validate_price_list(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
	          p_validation_mode  => 'UPDATE',
            P_OZF_PRICE_LIST_Rec  =>  P_OZF_PRICE_LIST_Rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      Update OZF_PRICE_LIST_ATTRIBUTES
          SET
              PRICE_LIST_ATTRIBUTE_ID = decode( p_OZF_PRICE_LIST_rec.PRICE_LIST_ATTRIBUTE_ID, FND_API.G_MISS_NUM, PRICE_LIST_ATTRIBUTE_ID, p_OZF_PRICE_LIST_rec.PRICE_LIST_ATTRIBUTE_ID),
              USER_STATUS_ID = decode( p_OZF_PRICE_LIST_rec.USER_STATUS_ID, FND_API.G_MISS_NUM, USER_STATUS_ID, p_OZF_PRICE_LIST_rec.USER_STATUS_ID),
              CUSTOM_SETUP_ID = decode( p_OZF_PRICE_LIST_rec.CUSTOM_SETUP_ID, FND_API.G_MISS_NUM, CUSTOM_SETUP_ID, p_OZF_PRICE_LIST_rec.CUSTOM_SETUP_ID),
              STATUS_CODE = decode( p_OZF_PRICE_LIST_rec.STATUS_CODE, FND_API.G_MISS_CHAR, STATUS_CODE, p_OZF_PRICE_LIST_rec.STATUS_CODE),
              OWNER_ID = decode( p_OZF_PRICE_LIST_rec.OWNER_ID, FND_API.G_MISS_NUM, OWNER_ID, p_OZF_PRICE_LIST_rec.OWNER_ID),
              QP_LIST_HEADER_ID = decode( p_OZF_PRICE_LIST_rec.QP_LIST_HEADER_ID, FND_API.G_MISS_NUM, QP_LIST_HEADER_ID, p_OZF_PRICE_LIST_rec.QP_LIST_HEADER_ID),
              OBJECT_VERSION_NUMBER = p_OZF_PRICE_LIST_rec.object_version_number + 1,
              STATUS_DATE = decode( p_OZF_PRICE_LIST_rec.STATUS_DATE, FND_API.G_MISS_DATE, STATUS_DATE, p_OZF_PRICE_LIST_rec.STATUS_DATE),
              WF_ITEM_KEY = decode( p_OZF_PRICE_LIST_rec.WF_ITEM_KEY, FND_API.G_MISS_CHAR, WF_ITEM_KEY, p_OZF_PRICE_LIST_rec.WF_ITEM_KEY),
              LAST_UPDATE_DATE = SYSDATE,
              LAST_UPDATE_LOGIN = FND_GLOBAL.CONC_LOGIN_ID,
              LAST_UPDATED_BY = FND_GLOBAL.USER_ID
    where qp_list_header_id = p_OZF_PRICE_LIST_rec.qp_list_header_id
      and object_version_number = p_OZF_PRICE_LIST_rec.object_version_number;

     IF (SQL%NOTFOUND) THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
     END IF;
  END IF;

   x_object_version_number := p_OZF_PRICE_LIST_rec.object_version_number + 1;

     IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_PRICE_LIST_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_PRICE_LIST_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO UPDATE_PRICE_LIST_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Update_price_list;


PROCEDURE Delete_price_list(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_PRICE_LIST_ATTRIBUTE_ID  IN  NUMBER,
    P_Object_Version_Number      IN   NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_price_list';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN

      SAVEPOINT DELETE_PRICE_LIST_PVT;


      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     DELETE FROM OZF_PRICE_LIST_ATTRIBUTES
     WHERE PRICE_LIST_ATTRIBUTE_ID = p_PRICE_LIST_ATTRIBUTE_ID
       AND object_version_number = p_object_version_number;

    IF (SQL%NOTFOUND) THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
   END IF;



      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DELETE_PRICE_LIST_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_PRICE_LIST_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO DELETE_PRICE_LIST_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Delete_price_list;


End OZF_PRICE_LIST_PVT;

/
