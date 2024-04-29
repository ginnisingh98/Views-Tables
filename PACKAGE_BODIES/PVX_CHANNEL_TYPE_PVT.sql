--------------------------------------------------------
--  DDL for Package Body PVX_CHANNEL_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_CHANNEL_TYPE_PVT" AS
/* $Header: pvxchnlb.pls 115.7 2002/11/20 02:05:42 pklin ship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='pvx_channel_type_pvt';

---------------------------------------------------------------------
-- PROCEDURE
--    Create_channel_type
--
-- PURPOSE
--    Create a new channel type record
--
-- PARAMETERS
--    p_channel_type_rec: the new record to be inserted
--    x_channel_type_id:  return the channel_type_id of the new record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If channel_type_id is not passed in, generate a unique one from
--       the sequence.
--    3. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_channel_type(
   p_api_version       IN  NUMBER    := 1.0
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,p_channel_type_rec  IN  channel_type_rec_type
  ,x_channel_type_id   OUT NOCOPY NUMBER
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
)
IS
   l_api_version CONSTANT  NUMBER       := 1.0;
   l_api_name    CONSTANT  VARCHAR2(30) := 'Create_channel_type';
   l_full_name   CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_channel_type_rec      channel_type_rec_type := p_channel_type_rec;
   l_object_version_number NUMBER := 1;
   l_uniqueness_check     pls_integer;

   CURSOR lc_get_next_seq IS
   SELECT pv_channel_types_s.NEXTVAL FROM DUAL;

   CURSOR lc_chk_exists(pc_lookup_type varchar2,
                        pc_lookup_code varchar2) is
   SELECT 1 FROM  PV_CHANNEL_TYPES
   WHERE channel_lookup_type = pc_lookup_type
   and   channel_lookup_code = pc_lookup_code;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Create_channel_type;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   -------------------------- insert --------------------------
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;


   IF l_channel_type_rec.channel_type_id IS NULL THEN

      -- Get the identifier
      OPEN  lc_get_next_seq;
      FETCH lc_get_next_seq INTO l_channel_type_rec.channel_type_id;
      CLOSE lc_get_next_seq;

      -- Check the uniqueness of the identifier
      OPEN  lc_chk_exists(pc_lookup_type => l_channel_type_rec.channel_lookup_type,
                          pc_lookup_code => l_channel_type_rec.channel_lookup_code);
      FETCH lc_chk_exists INTO l_uniqueness_check;
      CLOSE lc_chk_exists;

      if l_uniqueness_check is not null then
         FND_MESSAGE.set_name('PV', 'PV_DUPLICATE_RECORD');
         FND_MSG_PUB.add;
         RAISE FND_API.g_exc_unexpected_error;
      end if;

   END IF;

   INSERT INTO PV_CHANNEL_TYPES (
      CHANNEL_TYPE_ID,
      CHANNEL_LOOKUP_TYPE,
      CHANNEL_LOOKUP_CODE,
      INDIRECT_CHANNEL_FLAG,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      OBJECT_VERSION_NUMBER,
      RANK
   ) VALUES (
       l_channel_type_rec.channel_type_id
      ,l_channel_type_rec.channel_lookup_type
      ,l_channel_type_rec.channel_lookup_code
      ,l_channel_type_rec.indirect_channel_flag
      ,SYSDATE                                -- LAST_UPDATE_DATE
      ,NVL(FND_GLOBAL.user_id,-1)             -- LAST_UPDATED_BY
      ,SYSDATE                                -- CREATION_DATE
      ,NVL(FND_GLOBAL.user_id,-1)             -- CREATED_BY
      ,NVL(FND_GLOBAL.conc_login_id,-1)       -- LAST_UPDATE_LOGIN
      ,l_object_version_number                -- object_version_number
      ,l_channel_type_rec.rank
   );

   x_channel_type_id := l_channel_type_rec.channel_type_id;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

WHEN FND_API.g_exc_error THEN

   ROLLBACK TO Create_channel_type;
   x_return_status := FND_API.g_ret_sts_error;

   FND_MSG_PUB.count_and_get ( p_encoded  => FND_API.g_false
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

WHEN FND_API.g_exc_unexpected_error THEN

   ROLLBACK TO Create_channel_type;
   x_return_status := FND_API.g_ret_sts_unexp_error ;

   FND_MSG_PUB.count_and_get ( p_encoded  => FND_API.g_false
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

WHEN OTHERS THEN

   ROLLBACK TO Create_channel_type;
   x_return_status := FND_API.g_ret_sts_unexp_error ;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
   END IF;

   FND_MSG_PUB.count_and_get( p_encoded  => FND_API.g_false
                              ,p_count   => x_msg_count
                              ,p_data    => x_msg_data);

END Create_channel_type;


---------------------------------------------------------------
-- PROCEDURE
--   Delete_channel_type
--
---------------------------------------------------------------
PROCEDURE Delete_channel_type(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false
  ,p_channel_type_id   IN  NUMBER
  ,p_object_version    IN  NUMBER
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_channel_type';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Delete_channel_type;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;


   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ delete ------------------------
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   IF p_channel_type_id < 10000 THEN

        FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
        FND_MESSAGE.set_token('TEXT', 'Cannot delete a seeded channel type');
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;


   END IF;


   DELETE FROM PV_channel_types
   WHERE channel_type_id = p_channel_type_id
   AND   object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get( p_encoded => FND_API.g_false,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

WHEN FND_API.g_exc_error THEN

   ROLLBACK TO Delete_channel_type;
   x_return_status := FND_API.g_ret_sts_error;

   FND_MSG_PUB.count_and_get ( p_encoded  => FND_API.g_false
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

WHEN FND_API.g_exc_unexpected_error THEN

   ROLLBACK TO Delete_channel_type;
   x_return_status := FND_API.g_ret_sts_unexp_error ;

   FND_MSG_PUB.count_and_get ( p_encoded  => FND_API.g_false
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

WHEN OTHERS THEN

   ROLLBACK TO Delete_channel_type;
   x_return_status := FND_API.g_ret_sts_unexp_error ;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
   END IF;

   FND_MSG_PUB.count_and_get( p_encoded  => FND_API.g_false
                              ,p_count   => x_msg_count
                              ,p_data    => x_msg_data);

END Delete_channel_type;


---------------------------------------------------------------------
-- PROCEDURE
-- Update_channel_type
----------------------------------------------------------------------
PROCEDURE Update_channel_type(
   p_api_version       IN  NUMBER    := 1.0
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,p_channel_type_rec  IN  channel_type_rec_type
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2)
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Update_channel_type';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_channel_type_rec   channel_type_rec_type;
   l_indirect_channel_flag VARCHAR2(20);

   CURSOR lc_seed_chk(pc_channel_type_id NUMBER) IS
   SELECT indirect_channel_flag
   FROM   pv_channel_types
   WHERE  channel_type_id = pc_channel_type_id;

BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT Update_channel_type;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----------------------- validate ----------------------
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   -- replace g_miss_char/num/date with current column values
   Complete_channel_type_rec(p_channel_type_rec => p_channel_type_rec,
                             x_complete_rec     => l_channel_type_rec);


   -------------------------- update --------------------


   IF l_channel_type_rec.channel_type_id < 10000 THEN

      OPEN lc_seed_chk(l_channel_type_rec.channel_type_id);
      FETCH lc_seed_chk INTO l_indirect_channel_flag;
      CLOSE lc_seed_chk;


      IF l_indirect_channel_flag <> l_channel_type_rec.indirect_channel_flag THEN

         FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
         FND_MESSAGE.set_token('TEXT', 'Cannot update a seeded channel type');
         FND_MSG_PUB.add;
         RAISE FND_API.g_exc_error;

      END IF;

   END IF;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': update');
   END IF;

   UPDATE PV_CHANNEL_TYPES
   SET
       last_update_date        = SYSDATE
      ,last_updated_by         = NVL(FND_GLOBAL.user_id,-1)
      ,last_update_login       = NVL(FND_GLOBAL.conc_login_id,-1)
      ,channel_lookup_type     = l_channel_type_rec.channel_lookup_type
      ,channel_lookup_code     = l_channel_type_rec.channel_lookup_code
      ,indirect_channel_flag   = l_channel_type_rec.indirect_channel_flag
      ,object_version_number   = l_channel_type_rec.object_version_number + 1
      ,rank		       = l_channel_type_rec.rank
   WHERE channel_type_id       = l_channel_type_rec.channel_type_id
   AND   object_version_number = l_channel_type_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_RECORD_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION

WHEN FND_API.g_exc_error THEN

   ROLLBACK TO Update_channel_type;
   x_return_status := FND_API.g_ret_sts_error;

   FND_MSG_PUB.count_and_get ( p_encoded  => FND_API.g_false
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

WHEN FND_API.g_exc_unexpected_error THEN

   ROLLBACK TO Update_channel_type;
   x_return_status := FND_API.g_ret_sts_unexp_error ;

   FND_MSG_PUB.count_and_get ( p_encoded  => FND_API.g_false
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

WHEN OTHERS THEN

   ROLLBACK TO Update_channel_type;
   x_return_status := FND_API.g_ret_sts_unexp_error ;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
   END IF;

   FND_MSG_PUB.count_and_get( p_encoded  => FND_API.g_false
                              ,p_count   => x_msg_count
                              ,p_data    => x_msg_data);

END Update_channel_type;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_channel_type_rec
--
---------------------------------------------------------------------
PROCEDURE Complete_channel_type_rec(
   p_channel_type_rec   IN  channel_type_rec_type
  ,x_complete_rec       OUT NOCOPY channel_type_rec_type
)
IS

   CURSOR lc_get_channel_type IS
     SELECT *
     FROM  PV_CHANNEL_TYPES
     WHERE channel_type_id = p_channel_type_rec.channel_type_id;

   l_channel_type_rec   lc_get_channel_type%ROWTYPE;

BEGIN

   x_complete_rec := p_channel_type_rec;

   OPEN lc_get_channel_type;
   FETCH lc_get_channel_type INTO l_channel_type_rec;

   IF lc_get_channel_type%NOTFOUND THEN
      CLOSE lc_get_channel_type;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_RECORD_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   CLOSE lc_get_channel_type;

   IF p_channel_type_rec.channel_lookup_type = FND_API.G_MISS_CHAR THEN
      x_complete_rec.channel_lookup_type := l_channel_type_rec.channel_lookup_type;
   END IF;

   IF p_channel_type_rec.channel_lookup_code = FND_API.G_MISS_CHAR  THEN
      x_complete_rec.channel_lookup_code := l_channel_type_rec.channel_lookup_code;
   END IF;

   IF p_channel_type_rec.indirect_channel_flag = FND_API.G_MISS_CHAR  THEN
      x_complete_rec.indirect_channel_flag := l_channel_type_rec.indirect_channel_flag;
   END IF;

   IF p_channel_type_rec.object_version_number = FND_API.G_MISS_NUM THEN
      x_complete_rec.object_version_number := l_channel_type_rec.object_version_number;
   END IF;

   IF p_channel_type_rec.rank = FND_API.G_MISS_NUM THEN
      x_complete_rec.rank := l_channel_type_rec.rank;
   END IF;

END Complete_channel_type_rec;

END pvx_channel_type_pvt;

/
