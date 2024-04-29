--------------------------------------------------------
--  DDL for Package Body OZF_QUAL_MARKET_OPTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_QUAL_MARKET_OPTION_PVT" AS
/* $Header: ozfvqmob.pls 120.4 2005/08/24 06:52:04 rssharma noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_offer_Market_Options_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvodlb.pls';




PROCEDURE check_qual_mo_uk_items(
                p_qual_mo_rec IN qual_mo_rec_type
                , p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.G_CREATE
                , x_return_status OUT NOCOPY VARCHAR2
                )
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
END check_qual_mo_uk_items;

PROCEDURE check_qual_mo_req_items(
                p_qual_mo_rec IN qual_mo_rec_type
                , p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create
                , x_return_status OUT NOCOPY VARCHAR2
                )
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;

ozf_utility_pvt.debug_message('Mode is : '||p_validation_mode || ' : '||JTF_PLSQL_API.g_create);
IF p_validation_mode = JTF_PLSQL_API.g_create THEN
    IF p_qual_mo_rec.offer_market_option_id IS NULL OR p_qual_mo_rec.offer_market_option_id = FND_API.G_MISS_NUM THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','offer_market_option_id');
        x_return_status := FND_API.g_ret_sts_error;
    END IF;

    IF p_qual_mo_rec.qp_qualifier_id IS NULL OR p_qual_mo_rec.qp_qualifier_id = FND_API.G_MISS_NUM THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','qp_qualifier_id');
            x_return_status := FND_API.g_ret_sts_error;
    END IF;

ELSIF p_validation_mode = JTF_PLSQL_API.g_update THEN

    IF p_qual_mo_rec.qualifier_market_option_id = FND_API.G_MISS_NUM THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','qualifier_market_option_id');
        x_return_status := FND_API.g_ret_sts_error;
    END IF;

    IF p_qual_mo_rec.offer_market_option_id = FND_API.G_MISS_NUM THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','offer_market_option_id');
        x_return_status := FND_API.g_ret_sts_error;
    END IF;

    IF p_qual_mo_rec.object_version_number = FND_API.G_MISS_NUM THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','object_version_number');
            x_return_status := FND_API.g_ret_sts_error;
    END IF;

    IF p_qual_mo_rec.qp_qualifier_id = FND_API.G_MISS_NUM THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','qp_qualifier_id');
            x_return_status := FND_API.g_ret_sts_error;
    END IF;
END IF;

END check_qual_mo_req_items;

PROCEDURE check_qual_mo_fk_items(
            p_qual_mo_rec IN qual_mo_rec_type
            , p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create
            , x_return_status OUT NOCOPY VARCHAR2
            )
IS


BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_qual_mo_rec.offer_market_option_id IS NOT NULL AND p_qual_mo_rec.offer_market_option_id <> FND_API.G_MISS_NUM THEN
    IF p_qual_mo_rec.offer_market_option_id <> -1 THEN
        IF ozf_utility_pvt.check_fk_exists('ozf_offr_market_options','offer_market_option_id',to_char(p_qual_mo_rec.offer_market_option_id)) = FND_API.g_false
        THEN
            OZF_Utility_PVT.Error_Message('OZF_OFFR_MOID_INV');
            x_return_status := FND_API.g_ret_sts_error;
        END IF;
    END IF;
END IF;

IF p_qual_mo_rec.qp_qualifier_id IS NOT NULL AND p_qual_mo_rec.qp_qualifier_id <> FND_API.G_MISS_NUM THEN
    IF ozf_utility_pvt.check_fk_exists('qp_qualifiers','qualifier_id',to_char(p_qual_mo_rec.qp_qualifier_id)) = FND_API.g_false
    THEN
        OZF_Utility_PVT.Error_Message('OZF_OFFR_INV_QP_QUAL');
        x_return_status := FND_API.g_ret_sts_error;
    END IF;
END IF;

END check_qual_mo_fk_items;

PROCEDURE check_qual_mo_lkup_items(
            p_qual_mo_rec IN qual_mo_rec_type
            , p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create
            , x_return_status OUT NOCOPY VARCHAR2
            )
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
END check_qual_mo_lkup_items;

PROCEDURE check_qual_mo_attr(
            p_qual_mo_rec IN qual_mo_rec_type
            , p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.G_CREATE
            , x_return_status OUT NOCOPY VARCHAR2
            )
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
END check_qual_mo_attr;

PROCEDURE check_qual_mo_inter_attr(
            p_qual_mo_rec IN qual_mo_rec_type
            , p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.G_CREATE
            , x_return_status OUT NOCOPY VARCHAR2
            )
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
END check_qual_mo_inter_attr;

PROCEDURE check_qual_mo_entity(
            p_qual_mo_rec IN qual_mo_rec_type
            , p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.G_CREATE
            , x_return_status OUT NOCOPY VARCHAR2
            )
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
END check_qual_mo_entity;





PROCEDURE Check_qual_mo_Items(
                p_qual_mo_rec IN qual_mo_rec_type
                , p_validation_mode   IN VARCHAR2 := JTF_PLSQL_API.g_create
                , x_return_status     OUT NOCOPY VARCHAR2
              )
IS
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      check_qual_mo_req_items(
                              p_qual_mo_rec => p_qual_mo_rec
                              , p_validation_mode => p_validation_mode
                              , x_return_status => x_return_status
                              );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      check_qual_mo_uk_items(
                             p_qual_mo_rec        => p_qual_mo_rec,
                             p_validation_mode   => p_validation_mode,
                             x_return_status     => x_return_status
                            );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      check_qual_mo_fk_items(
                             p_qual_mo_rec => p_qual_mo_rec
                             , p_validation_mode => p_validation_mode
                             , x_return_status => x_return_status
                             );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    check_qual_mo_lkup_items(
                            p_qual_mo_rec => p_qual_mo_rec
                            , p_validation_mode => p_validation_mode
                            , x_return_status => x_return_status
                            );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    check_qual_mo_attr(
                        p_qual_mo_rec => p_qual_mo_rec
                        , p_validation_mode => p_validation_mode
                        , x_return_status => x_return_status
                        );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    check_qual_mo_inter_attr(
                        p_qual_mo_rec => p_qual_mo_rec
                        , p_validation_mode => p_validation_mode
                        , x_return_status => x_return_status
                        );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    check_qual_mo_entity(
                        p_qual_mo_rec => p_qual_mo_rec
                        , p_validation_mode => p_validation_mode
                        , x_return_status => x_return_status
                        );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

END Check_qual_mo_Items;



PROCEDURE validate_qual_market_options
(
p_api_version_number NUMBER
, p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_validation_mode          IN VARCHAR2 := JTF_PLSQL_API.g_create
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY VARCHAR2
, x_msg_data OUT NOCOPY VARCHAR2
, p_qual_mo_rec IN qual_mo_rec_type
)
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'validate_qual_market_options';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_qual_mo_rec               qual_mo_rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_qual_mkt_options_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
-- check
          IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_qual_mo_Items(
                 p_qual_mo_rec        => p_qual_mo_rec,
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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'Return status is : '|| x_return_status);

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

-- collect message

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
     ROLLBACK TO validate_qual_mkt_options_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO validate_qual_mkt_options_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO validate_qual_mkt_options_pvt;
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

END validate_qual_market_options;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_qual_market_options
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
--       p_qual_mo_rec               IN   qual_mo_rec_type
--   OUT NOCOPY
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--       x_vo_market_option_id  OUT NOCOPY  NUMBER. Market Option id of the market option just created
--   Version : Current version 1.0
--
--   History
--            Mon Jun 20 2005:3/33 PM RSSHARMA Created
--
--   Description
--              : Method to Create New Market Options.
--   End of Comments
--   ==============================================================================

PROCEDURE Create_qual_market_options(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qual_mo_rec                     IN   qual_mo_rec_type  ,
    x_qual_market_option_id        OUT NOCOPY  NUMBER
)
IS
l_qual_mo_rec qual_mo_rec_type;
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_qual_market_options';
l_qual_market_option_id NUMBER;
l_dummy NUMBER;
   CURSOR c_id IS
      SELECT ozf_qualifier_market_option_s.NEXTVAL
      FROM dual;
   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM ozf_qualifier_market_option
      WHERE qualifier_market_option_id = l_id;
l_object_version_number NUMBER;
BEGIN
--initialize
      -- Standard Start of API savepoint
      SAVEPOINT Create_qual_market_options_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

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

l_qual_mo_rec := p_qual_mo_rec;


   IF p_qual_mo_rec.qualifier_market_option_id IS NULL OR p_qual_mo_rec.qualifier_market_option_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_qual_market_option_id;
         CLOSE c_id;

         OPEN c_id_exists(l_qual_market_option_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_qual_market_option_id := p_qual_mo_rec.qualifier_market_option_id;
   END IF;
-- validate

    validate_qual_market_options
    (
    p_api_version_number        => p_api_version_number
    , p_init_msg_list           => p_init_msg_list
    , p_validation_level        => p_validation_level
    , p_validation_mode         => JTF_PLSQL_API.g_create
    , x_return_status           => x_return_status
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , p_qual_mo_rec             => l_qual_mo_rec
    );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
-- insert
OZF_QUAL_MARKET_OPTION_PKG.Insert_Row(
        px_qualifier_market_option_id => l_qual_market_option_id
        , p_offer_market_option_id => l_qual_mo_rec.offer_market_option_id
        , p_qp_qualifier_id => l_qual_mo_rec.qp_qualifier_id
        , px_object_version_number => l_object_version_number
        , p_creation_date           => SYSDATE
        , p_created_by              => FND_GLOBAL.USER_ID
        , p_last_updated_by         => FND_GLOBAL.USER_ID
        , p_last_update_date        => SYSDATE
        , p_last_update_login       => FND_GLOBAL.conc_login_id
        );
-- commit
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

x_qual_market_option_id := l_qual_market_option_id;

      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'Return status is : '|| x_return_status);
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- exception
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_qual_market_options_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_qual_market_options_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_qual_market_options_pvt;
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

END Create_qual_market_options;

PROCEDURE update_qual_market_options(
    p_api_version_number            IN NUMBER
    , p_init_msg_list               IN VARCHAR2       := FND_API.G_FALSE
    , p_commit                      IN VARCHAR2              := FND_API.G_FALSE
    , p_validation_level            IN VARCHAR2    := FND_API.G_VALID_LEVEL_FULL

    , x_return_status               OUT NOCOPY VARCHAR2
    , x_msg_count                   OUT NOCOPY VARCHAR2
    , x_msg_data                    OUT NOCOPY VARCHAR2

    , p_qual_mo_rec                 IN qual_mo_rec_type
    )
IS
CURSOR c_get_qual_mo(p_qualifier_market_option_id NUMBER, p_object_version_number NUMBER) IS
    SELECT *
    FROM ozf_qualifier_market_option
    WHERE qualifier_market_option_id = p_qualifier_market_option_id
    AND object_version_number = p_object_version_number;
    -- Hint: Developer need to provide Where clause

l_api_name                  CONSTANT VARCHAR2(30) := 'update_qual_market_options';
l_api_version_number        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_qual_market_option_id    NUMBER;
l_ref_qual_mo_rec  c_get_qual_mo%ROWTYPE ;
l_tar_qual_mo_rec  qual_mo_rec_type := p_qual_mo_rec ;
l_rowid  ROWID;
BEGIN
--initialize
      -- Standard Start of API savepoint
      SAVEPOINT update_qual_market_options_pvt;
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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN c_get_qual_mo( l_tar_qual_mo_rec.qualifier_market_option_id,l_tar_qual_mo_rec.object_version_number);
          FETCH c_get_qual_mo INTO l_ref_qual_mo_rec  ;
       If ( c_get_qual_mo%NOTFOUND) THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'OZF_QUAL_MARKET_OPTIONS') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE c_get_qual_mo;

      If (l_tar_qual_mo_rec.object_version_number is NULL or
          l_tar_qual_mo_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING'
                                           , p_token_name   => 'COLUMN'
                                           , p_token_value  => 'Last_Update_Date') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_qual_mo_rec.object_version_number <> l_ref_qual_mo_rec.object_version_number) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED'
                                           , p_token_name   => 'INFO'
                                           , p_token_value  => 'Ozf_Market_Options') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;
-- validate
validate_qual_market_options
(
p_api_version_number    => p_api_version_number
, p_init_msg_list       => p_init_msg_list
, p_validation_level    => p_validation_level
, p_validation_mode     => JTF_PLSQL_API.g_update
, x_return_status       => x_return_status
, x_msg_count           => x_msg_count
, x_msg_data            => x_msg_data
, p_qual_mo_rec         => p_qual_mo_rec
);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
-- update
OZF_QUAL_MARKET_OPTION_PKG.Update_Row(
        p_qualifier_market_option_id => p_qual_mo_rec.qualifier_market_option_id
        , p_offer_market_option_id   => p_qual_mo_rec.offer_market_option_id
        , p_qp_qualifier_id          => p_qual_mo_rec.qp_qualifier_id
        , p_object_version_number    => p_qual_mo_rec.object_version_number
        , p_last_updated_by         => FND_GLOBAL.USER_ID
        , p_last_update_date        => SYSDATE
        , p_last_update_login       => FND_GLOBAL.conc_login_id
        );
-- commit;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'Return status is : '|| x_return_status);
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
--exception

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_qual_market_options_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_qual_market_options_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO update_qual_market_options_pvt;
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

END update_qual_market_options;


PROCEDURE Delete_qual_market_options(
    p_api_version_number        IN NUMBER
    , p_init_msg_list           IN VARCHAR2     := FND_API.G_FALSE
    , p_commit                  IN VARCHAR2     := FND_API.G_FALSE
    , p_validation_level        IN NUMBER       := FND_API.G_VALID_LEVEL_FULL
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY VARCHAR2
    , x_msg_data                OUT NOCOPY VARCHAR2
    , p_qualifier_market_option_id IN NUMBER
    , p_object_version_number    IN NUMBER
    )
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_qual_market_options';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
 BEGIN
--initialize
      -- Standard Start of API savepoint
      SAVEPOINT Delete_qual_market_options_PVT;

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

-- delete
OZF_QUAL_MARKET_OPTION_PKG.Delete_Row(
        p_qualifier_market_option_id  => p_qualifier_market_option_id
        , p_object_version_number     => p_object_version_number
    );
-- commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

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
     ROLLBACK TO Delete_qual_market_options_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_qual_market_options_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_qual_market_options_PVT;
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

END Delete_qual_market_options;

END OZF_QUAL_MARKET_OPTION_PVT;


/
