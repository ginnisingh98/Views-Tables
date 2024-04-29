--------------------------------------------------------
--  DDL for Package Body AMS_CHANNEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CHANNEL_PVT" AS
/* $Header: amsvchab.pls 115.30 2004/06/18 08:15:28 kgupta ship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='AMS_CHANNEL_PVT';

-- HISTORY
--                   mpande      Created
--   07/13/2000      ptendulk    Added procedure 'Check_Chan_Record Bug#1353602
--   01/18/2001      rssharma    Removed internal_attribute attribute(from the record) and relateed code
--   31-May-2001     soagrawa    In check_chan_fk_items: Changed table name while checking for country id
--   28-sep-2001     soagrawa    In check_chan_fk_items: fixed bug# 2021940
--   31-OCT-2001     rrajesh     Bug fix:2089112
--   03-Dec-2002     ptendulk    Added fix for bug 2615287, increased length of vendor
--   13-FEB-2003     vmodur      Fix for Bug 2791639


AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Check_Chan_Record(
   p_chan_rec       IN  chan_rec_type,
   p_complete_rec   IN  chan_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
) ;

---------------------------------------------------------------------
-- PROCEDURE
--    create_CHANNEL
--
-- HISTORY
--    11/23/99  mpande  Created.
-- 1. active_from_date,active_to_date and order_sequence are all for upgrade purposes only
-- so no validation is done for these columns
-- 08-Nov-2000    rrajesh     Modified the uniqueness checking of channel_name, by replacing
--                            the AMS_Utility_PVT call with c_name_unique_cr,
--                            c_name_unique_up cursors.
-- 13-Dec-2000	  rrajesh     Changes for R4
-- 22-Dec-2000    rrajesh     Removed the comments of internal channel flag.
-- 01/18/2001     rssharma    Removed internal_resource attribute from the record and related code
---------------------------------------------------------------------
PROCEDURE create_channel(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_chan_rec          IN  chan_rec_type,
   x_chan_id           OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'create_channel';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);
   l_chan_rec       chan_rec_type := p_chan_rec;
   l_chan_count     NUMBER;

   CURSOR c_chan_seq IS
   SELECT ams_channels_b_s.NEXTVAL
     FROM DUAL;

   CURSOR c_chan_count(chan_id IN NUMBER) IS
   SELECT COUNT(*)
     FROM ams_channels_vl
    WHERE channel_id = chan_id;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_channel;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   validate_channel(
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_chan_rec           => l_chan_rec
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- try to generate a unique id from the sequence
	IF l_chan_rec.channel_id IS NULL THEN
   LOOP
		OPEN c_chan_seq;
		FETCH c_chan_seq INTO l_chan_rec.channel_id;
		CLOSE c_chan_seq;

      OPEN c_chan_count(l_chan_rec.channel_id);
      FETCH c_chan_count INTO l_chan_count;
      CLOSE c_chan_count;

      EXIT WHEN l_chan_count = 0;
   END LOOP;
   END IF;

   -------------------------- insert --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;

   -- Added by rrajesh on 12/07/00
   --l_chan_rec.channel_type_code := 'INTERNAL'; --commented OUT NOCOPY by rrajesh on 12/22/00
   l_chan_rec.outbound_flag := 'Y';
   l_chan_rec.inbound_flag := 'Y';
   -- end 12/07/00

   INSERT INTO ams_channels_b(
      channel_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      channel_type_code,
      order_sequence,
      managed_by_person_id,
      outbound_flag,
      inbound_flag,
      active_from_date,
      active_to_date,
      rating,
      preferred_vendor_id,
      party_id,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      --rrajesh added on 12/07/00
      country_id
      -- Rahul Sharma  removed on 01/18/2001
      --internal_resource
      --end 12/07/00
	)
	VALUES(
      l_chan_rec.channel_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,  -- object_version_number
      l_chan_rec.channel_type_code,
      l_chan_rec.order_sequence,
           -- no validation for order.This column is for upgrade purposes only
      l_chan_rec.managed_by_person_id,

      -- added by rrajesh on 12/07/00
      --NVL(l_chan_rec.outbound_flag,'Y'),
      --NVL(l_chan_rec.inbound_flag,'N'),
      NVL(l_chan_rec.outbound_flag,'Y'),
      NVL(l_chan_rec.inbound_flag,'Y'),
      --end 12/07/00

      NVL(l_chan_rec.active_from_date,SYSDATE),
            -- no validation for active_for_date .This column is for upgrade purposes only
      l_chan_rec.active_to_date,
            -- no validation for active_to_date .This column is for upgrade purposes only
      l_chan_rec.rating,
      l_chan_rec.preferred_vendor_id,
      l_chan_rec.party_id,
      l_chan_rec.attribute_category,
      l_chan_rec.attribute1,
      l_chan_rec.attribute2,
      l_chan_rec.attribute3,
      l_chan_rec.attribute4,
      l_chan_rec.attribute5,
      l_chan_rec.attribute6,
      l_chan_rec.attribute7,
      l_chan_rec.attribute8,
      l_chan_rec.attribute9,
      l_chan_rec.attribute10,
      l_chan_rec.attribute11,
      l_chan_rec.attribute12,
      l_chan_rec.attribute13,
      l_chan_rec.attribute14,
      l_chan_rec.attribute15,
      --added by rrajesh 12/07/00
      l_chan_rec.country_id
      -- Rahul Sharma removed on 01/18/2001
      --l_chan_rec.internal_resource
      --end 12/07/00
	);

   INSERT INTO ams_channels_tl(
      channel_id,
      language,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      source_lang,
      channel_name,
      description
   )
   SELECT
      l_chan_rec.channel_id,
      l.language_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      USERENV('LANG'),
      l_chan_rec.channel_name,
      l_chan_rec.description
   FROM fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND NOT EXISTS(
         SELECT NULL
         FROM ams_channels_tl t
         WHERE t.channel_id = l_chan_rec.channel_id
         AND t.language = l.language_code );


   ------------------------- finish -------------------------------
   x_chan_id := l_chan_rec.channel_id;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_channel;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_channel;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_channel;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END create_channel;


-----------------------------------------------------------------
-- PROCEDURE
--    delete_channel
--
-- HISTORY
--    11/23/99  mpande  Created.
--    07/11/00  holiu   Cannot delete if associated to activities.
-----------------------------------------------------------------
PROCEDURE delete_channel(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_chan_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_channel';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_media_id    NUMBER;

   CURSOR c_media_id IS
   SELECT media_id
   FROM   ams_media_channels
   WHERE  channel_id = p_chan_id
   AND    (active_to_date > SYSDATE OR active_to_date IS NULL);

   --  Bug fix:2089112. Added by rrajesh on 10/31/01
   CURSOR c_check_schedule_association IS
       SELECT marketing_medium_id
       FROM ams_campaign_schedules_b
       WHERE marketing_medium_id = p_chan_id;
   l_mktg_medium_id NUMBER;
   -- End change 10/31/01

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_channel;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- holiu: the following checking is added for bug 1350477
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': check before delete');
   END IF;

   OPEN c_media_id;
   FETCH c_media_id INTO l_media_id;
   CLOSE c_media_id;

   IF l_media_id IS NOT NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
		THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CHAN_CANNOT_DELETE');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   --  Bug fix:2089112. Added by rrajesh on 10/31/01
   OPEN c_check_schedule_association;
   FETCH c_check_schedule_association INTO l_mktg_medium_id;
   CLOSE c_check_schedule_association;

   IF l_mktg_medium_id IS NOT NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
		THEN
         FND_MESSAGE.set_name('AMS', 'AMS_MKTG_MEDIA_IS_USED_BY_CSCH');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   --  Bug fix:2089112. 10/31/01
   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   DELETE FROM ams_channels_b
   WHERE channel_id = p_chan_id
   AND object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
		THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   DELETE FROM ams_channels_tl
   WHERE channel_id = p_chan_id;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
		THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_channel;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_channel;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_channel;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END delete_channel;


-------------------------------------------------------------------
-- PROCEDURE
--    lock_channel
--
-- HISTORY
--    11/23/99  mpande  Created.
--------------------------------------------------------------------
PROCEDURE lock_channel(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_chan_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'lock_channel';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_chan_id      NUMBER;

   CURSOR c_chan_b IS
   SELECT channel_id
     FROM ams_channels_b
    WHERE channel_id = p_chan_id
      AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

   CURSOR c_chan_tl IS
   SELECT channel_id
     FROM ams_channels_tl
    WHERE channel_id = p_chan_id
      AND USERENV('LANG') IN (language, source_lang)
   FOR UPDATE NOWAIT;

BEGIN

   -------------------- initialize ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ lock -------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN c_chan_b;
   FETCH c_chan_b INTO l_chan_id;
   IF (c_chan_b%NOTFOUND) THEN
      CLOSE c_chan_b;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_chan_b;

   OPEN c_chan_tl;
   CLOSE c_chan_tl;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
		   FND_MSG_PUB.add;
		END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

	WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END lock_channel;


---------------------------------------------------------------------
-- PROCEDURE
--    update_channel
--
-- HISTORY
--    11/23/99  mpande  Created.
--    01/18/2001 rssharma removed internal_resource attribute
----------------------------------------------------------------------
PROCEDURE update_channel(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_chan_rec          IN  chan_rec_type
)
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_channel';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_chan_rec       chan_rec_type;
   l_return_status  VARCHAR2(1);

BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT update_channel;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----------------------- validate ----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   -- replace g_miss_char/num/date with current column values
   complete_chan_rec(p_chan_rec, l_chan_rec);
   -- item level
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_chan_items(
         p_chan_rec        => l_chan_rec, -- change from p_chan_rec vmodur
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   --=============================================================================
   -- Following call is added by ptendulk on Jul 13th 2000 Ref: Bug#1353602
   --=============================================================================

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Chan_Record(
         p_chan_rec       => l_chan_rec, -- change from p_chan_rec vmodur
         p_complete_rec   => l_chan_rec,
         x_return_status  => l_return_status
      );


      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- record level
    -------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': update');
   END IF;

   -- Added by rrajesh on 12/07/00
   --l_chan_rec.channel_type_code := 'INTERNAL'; -- commented out by rrajesh on 12/22/00
   l_chan_rec.outbound_flag := 'Y';
   l_chan_rec.inbound_flag := 'Y';
   -- end 12/07/00


   UPDATE ams_channels_b SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      object_version_number = l_chan_rec.object_version_number + 1,
      channel_type_code =  l_chan_rec.channel_type_code,
      order_sequence    = l_chan_rec.order_sequence,
      managed_by_person_id = l_chan_rec.managed_by_person_id,
      --rrajesh added 12/07/00
      --outbound_flag =  NVL(l_chan_rec.outbound_flag,'Y'),
      --inbound_flag = NVL(l_chan_rec.inbound_flag,'N'),
      outbound_flag =  NVL(l_chan_rec.outbound_flag,'Y'),
      inbound_flag = NVL(l_chan_rec.inbound_flag,'Y'),
      --end 12/07/00
      active_from_date  = l_chan_rec.active_from_date,
      active_to_date = l_chan_rec.active_to_date,
      rating = l_chan_rec.rating,
      preferred_vendor_id = l_chan_rec.preferred_vendor_id,
      party_id =  l_chan_rec.party_id,
      attribute_category = l_chan_rec.attribute_category,
      attribute1 = l_chan_rec.attribute1,
      attribute2 = l_chan_rec.attribute2,
      attribute3 = l_chan_rec.attribute3,
      attribute4 = l_chan_rec.attribute4,
      attribute5 = l_chan_rec.attribute5,
      attribute6 = l_chan_rec.attribute6,
      attribute7 = l_chan_rec.attribute7,
      attribute8 = l_chan_rec.attribute8,
      attribute9 = l_chan_rec.attribute9,
      attribute10 = l_chan_rec.attribute10,
      attribute11 = l_chan_rec.attribute11,
      attribute12 = l_chan_rec.attribute12,
      attribute13 = l_chan_rec.attribute13,
      attribute14 = l_chan_rec.attribute14,
      attribute15 = l_chan_rec.attribute15,
      --rrajesh added 12/07/00
      country_id = l_chan_rec.country_id
      -- Rahul Sharma removed 01/18/2001
      --internal_resource = l_chan_rec.internal_resource
      -- end 01/18/2001
      --end 12/07/00
   WHERE channel_id = l_chan_rec.channel_id
   AND object_version_number = l_chan_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   update ams_channels_tl set
      channel_name = l_chan_rec.channel_name,
      description = l_chan_rec.description,
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang = USERENV('LANG')
   WHERE channel_id = l_chan_rec.channel_id
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_channel;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_channel;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_channel;
      x_return_status := FND_API.g_ret_sts_unexp_error;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END update_channel;


--------------------------------------------------------------------
-- PROCEDURE
--    validate_channel
--
-- HISTORY
--    11/23/99  mpande  Created.
-- 1. active_from_date,active_to_date and order_sequence are all for upgrade purposes only
-- so no validation is done for these columns
--------------------------------------------------------------------
PROCEDURE validate_channel(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_chan_rec          IN  chan_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_channel';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': check items');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_chan_items(
         p_chan_rec        => p_chan_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   --=============================================================================
   -- Following call is added by ptendulk on Jul 13th 2000 Ref: Bug#1353602
   --=============================================================================
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': check Records');
   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Chan_Record(
         p_chan_rec       => p_chan_rec,
         p_complete_rec   => null,
         x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END validate_channel;


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_req_items
--
-- HISTORY
--    11/23/99  mpande  Created.
--
-- NOTES
--    1. We don't check active_from_date and any flags.
---------------------------------------------------------------------
PROCEDURE check_chan_req_items(
   p_chan_rec       IN  chan_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   ------------------------ channel_type --------------------------
   IF p_chan_rec.channel_type_code IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CHAN_INVALID_TYPE_CODE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   ------------------------ channel_name --------------------------
   IF p_chan_rec.channel_name IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CHAN_NO_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- Added by rrajesh on 12/07/00
   ------------------------ country_id --------------------------
   IF p_chan_rec.country_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CHAN_INVALID_COUNTRY_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
   -- end rrajesh 12/07/00

   -- Added by vmodur on 02/13/2003
   ------------------------ Active From Date ---------------------
   IF p_chan_rec.active_from_date IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_MED_CFD_IS_NULL');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
   -- end vmodur


END check_chan_req_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_chan_uk_items
--
-- HISTORY
--    23/11/99  mpande  Created.
---------------------------------------------------------------------
PROCEDURE check_chan_uk_items(
   p_chan_rec        IN  chan_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
   -- rrajesh 11/08/00 start
   l_count        NUMBER ;

   -- Modified by rrajesh 12/07/00
   /*CURSOR c_name_unique_cr (p_channel_name IN VARCHAR2) IS
	SELECT COUNT(1)
	FROM ams_channels_vl
	WHERE UPPER(channel_name) = UPPER(p_channel_name) ;*/
   CURSOR c_name_unique_cr (p_channel_name IN VARCHAR2, p_country_id IN NUMBER) IS
	SELECT COUNT(1)
	FROM ams_channels_vl
	WHERE UPPER(channel_name) = UPPER(p_channel_name)
	AND country_id = p_country_id;

   /*CURSOR c_name_unique_up (p_channel_name IN VARCHAR2, p_channel_id IN NUMBER) IS
	SELECT COUNT(1)
	FROM ams_channels_vl
	WHERE UPPER(channel_name) = UPPER(p_channel_name)
	AND channel_id <> p_channel_id ;*/
   CURSOR c_name_unique_up (p_channel_name IN VARCHAR2, p_channel_id IN NUMBER, p_country_id IN NUMBER) IS
	SELECT COUNT(1)
	FROM ams_channels_vl
	WHERE UPPER(channel_name) = UPPER(p_channel_name)
	AND country_id = p_country_id
	AND channel_id <> p_channel_id ;
   --end 12/07/00
   -- end rrajesh 11/08

BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_Utility_PVT.debug_message('Check the uniqueness Count - begin'); END IF;
   -- For create_channel, when channel_id is passed in, we need to
   -- check if this channel_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_chan_rec.channel_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
		      'ams_channels_vl',
				'channel_id = ' || p_chan_rec.channel_id
			) = FND_API.g_false
		THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
			THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CHAN_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   -- Check if channel_name is unique. Need to handle create and
   -- update differently.
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

	-- rrajesh start 11/08. Replaced the AMS_Utility_PVT call
	-- with the new cursor.
	--modified by rrajesh on 12/07/00
        --OPEN c_name_unique_cr(p_chan_rec.channel_name) ;
	OPEN c_name_unique_cr(p_chan_rec.channel_name, p_chan_rec.country_id) ;
	-- end 12/07/00
        FETCH c_name_unique_cr INTO l_count ;
        CLOSE c_name_unique_cr ;

      --l_valid_flag := AMS_Utility_PVT.check_uniqueness(
      --   'ams_channels_vl',
      --   'channel_name = ''' || p_chan_rec.channel_name ||''''
      --);
   ELSE
      --l_valid_flag := AMS_Utility_PVT.check_uniqueness(
      --   'ams_channels_vl',
      --   'channel_name = ''' || p_chan_rec.channel_name ||
      --      ''' AND channel_id <> ' || p_chan_rec.channel_id
      --);
      -- modified by rrajesh on 12/07/00
      --OPEN c_name_unique_up(p_chan_rec.channel_name,p_chan_rec.channel_id) ;
      OPEN c_name_unique_up(p_chan_rec.channel_name,p_chan_rec.channel_id, p_chan_rec.country_id) ;
      -- end 12/07/00
      FETCH c_name_unique_up INTO l_count ;
      CLOSE c_name_unique_up ;
      -- rrajesh end 11/08
   END IF;

   -- rrajesh start 11/08. Checking the uniqueness against the new cursor,
   -- c_name_unique_up
   -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_Utility_PVT.debug_message('Check the uniqueness Count '|| l_count ); END IF;
   IF l_count > 0 THEN
   --IF l_valid_flag = FND_API.g_false THEN
   -- rrajesh end 11/08
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CHAN_DUPLICATE_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END check_chan_uk_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_chan_fk_items
--
-- HISTORY
--    11/23/99  mpande  Created.
--    31-May-2001 soagrawa  Changed table name while checking for country id
--    28-sep-2001 soagrawa  Modified additional where clause in check for country fk, bug# 2021940
---------------------------------------------------------------------
PROCEDURE check_chan_fk_items(
   p_chan_rec        IN  chan_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- managed_by_person_id ------------------------
   IF p_chan_rec.managed_by_person_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_jtf_rs_emp_v',
            'resource_id',
            p_chan_rec.managed_by_person_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CHAN_BAD_MANAGED_BY_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- preferred_vendor_id ------------------------
   IF p_chan_rec.preferred_vendor_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'po_vendors',
            'vendor_id',
            p_chan_rec.preferred_vendor_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CHAN_WRONG_VENDOR_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   --------------------- party_id ------------------------
   IF p_chan_rec.party_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'HZ_PARTIES',
            'party_id',
            p_chan_rec.party_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CHAN_WRONG_PARTY_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --Added by rrajesh on 12/07/00
   --------------------- country_id ------------------------
   IF p_chan_rec.country_id <> FND_API.g_miss_num THEN

      -- modified by soagrawa on 31-May-2001
      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => 'jtf_loc_hierarchies_vl', --'jtf_loc_areas_vl',
                   p_pk_name                 => 'location_hierarchy_id', --'location_area_id',
                   p_pk_value                => p_chan_rec.country_id,
                   p_pk_data_type            => AMS_Utility_PVT.G_NUMBER,
                   -- modified by soagrawa on 28-sep-2001, bug# 2021940
                   p_additional_where_clause => ' location_type_code = ''COUNTRY'' ' --' location_type_name = ''Country'' '
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CHAN_WRONG_COUNTRY_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

  --end 12/07/00

END check_chan_fk_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_chan_lookup_items
--
-- HISTORY
--    23/11/99  mpande  Created.
---------------------------------------------------------------------
PROCEDURE check_chan_lookup_items(
   p_chan_rec        IN  chan_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- channel_type_code ------------------------
   IF p_chan_rec.channel_type_code <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_CHANNEL_TYPE',
            p_lookup_code => p_chan_rec.channel_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CAMP_WRONG_CHANNEL_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- rating ------------------------
   IF p_chan_rec.rating <> FND_API.g_miss_char
      AND p_chan_rec.rating IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_CHANNEL_RATING',
            p_lookup_code => p_chan_rec.rating
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CHAN_WRONG_RATING_VALUE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


END check_chan_lookup_items;

-- commented out by rrajesh on 12/07/00
/*

---------------------------------------------------------------------
-- PROCEDURE
--    check_chan_flag_items
--
-- HISTORY
--    23/11/99  mpande  Created.
---------------------------------------------------------------------
PROCEDURE check_chan_flag_items(
   p_chan_rec        IN  chan_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- outbound_flag ------------------------
   IF p_chan_rec.outbound_flag <> FND_API.g_miss_char
      AND p_chan_rec.outbound_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_chan_rec.outbound_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CHAN_WRONG_OUTBOUND_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- inbound_flag ------------------------
   IF p_chan_rec.inbound_flag <> FND_API.g_miss_char
      AND p_chan_rec.inbound_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_chan_rec.inbound_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CHAN_WRONG_INBOUND_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_chan_flag_items;
*/
--end comment rrajesh 12/07/00





---------------------------------------------------------------------
-- PROCEDURE
--    check_chan_items
--
-- HISTORY
--    11/23/99  mpande  Created.
---------------------------------------------------------------------
PROCEDURE check_chan_items(
   p_chan_rec        IN  chan_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   check_chan_req_items(
      p_chan_rec       => p_chan_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_chan_uk_items(
      p_chan_rec        => p_chan_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_chan_fk_items(
      p_chan_rec       => p_chan_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_chan_lookup_items(
      p_chan_rec        => p_chan_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --commented OUT NOCOPY by rrajesh on 12/07/00
   --check_chan_flag_items(
   --   p_chan_rec        => p_chan_rec,
   --   x_return_status   => x_return_status
   --);
   -- end 12/07/00

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END check_chan_items;


-- Start of Comments
--
-- NAME
--   Validate_Chan_Record
--
-- PURPOSE
--   This procedure is to validate the start and end date of the channel
--
-- NOTES
--
--
-- HISTORY
--   07/13/2000        ptendulk     created
-- End of Comments
PROCEDURE Check_Chan_Record(
   p_chan_rec       IN  chan_rec_type,
   p_complete_rec   IN  chan_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   l_start_date  	  			DATE;
   l_end_date    	  			DATE;
BEGIN
   --
   -- Initialize the Out Variable
   --
   x_return_status := FND_API.g_ret_sts_success;

   	-- Check start date time
	IF (p_chan_rec.active_from_date IS NOT NULL AND
	   p_chan_rec.active_from_date <> FND_API.G_MISS_DATE) OR
	   (p_chan_rec.active_to_date IS NOT NULL AND
            p_chan_rec.active_to_date <> FND_API.G_MISS_DATE)
	THEN
	   IF p_chan_rec.active_from_date = FND_API.G_MISS_DATE THEN
	   	  l_start_date := p_complete_rec.active_from_date;
	   ELSE
	   	  l_start_date := p_chan_rec.active_from_date;
	   END IF ;

	   IF p_chan_rec.active_to_date = FND_API.G_MISS_DATE THEN
	   	  l_end_date := p_complete_rec.active_to_date;
	   ELSE
	   	  l_end_date := p_chan_rec.active_to_date;
	   END IF ;


	   IF l_end_date IS NOT NULL
           AND l_start_date IS NOT NULL THEN
              IF l_start_date >  l_end_date  THEN
	   	-- invalid item
        	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN -- MMSG
--            	  DBMS_OUTPUT.Put_Line('Start Date time or End Date Time is invalid');
                        FND_MESSAGE.Set_Name('AMS', 'AMS_MED_FROMDT_GTR_TODT');
			-- FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_DT_RANGE');
       			FND_MSG_PUB.Add;
	          END IF;
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  -- If any errors happen abort API/Procedure.
		  RETURN;
              END IF;

           END IF;
	END IF;

	--Added by rrajesh on 12/07/00
	--Validation to be done against the fulfillment server and call center
	--end 12/07/00 rrajesh
END Check_Chan_Record;


---------------------------------------------------------------------
-- PROCEDURE
--    init_chan_rec
--
-- HISTORY
--    11/23/99  mpande  Created.
--    01/18/2001 rssharma Removed internal_resource attribute
---------------------------------------------------------------------
PROCEDURE init_chan_rec(
   x_chan_rec  OUT NOCOPY  chan_rec_type
)
IS
BEGIN

   x_chan_rec.channel_id := FND_API.g_miss_num;
   x_chan_rec.last_update_date := FND_API.g_miss_date;
   x_chan_rec.last_updated_by := FND_API.g_miss_num;
   x_chan_rec.creation_date := FND_API.g_miss_date;
   x_chan_rec.created_by := FND_API.g_miss_num;
   x_chan_rec.last_update_login := FND_API.g_miss_num;
   x_chan_rec.object_version_number := FND_API.g_miss_num;
   x_chan_rec.managed_by_person_id := FND_API.g_miss_num;
   x_chan_rec.preferred_vendor_id := FND_API.g_miss_num;
   x_chan_rec.party_id := FND_API.g_miss_num;
   x_chan_rec.channel_type_code := FND_API.g_miss_char;
   x_chan_rec.active_from_date := FND_API.g_miss_date;
   x_chan_rec.active_to_date := FND_API.g_miss_date;
   x_chan_rec.order_sequence := FND_API.g_miss_num;
   x_chan_rec.outbound_flag := FND_API.g_miss_char;
   x_chan_rec.inbound_flag := FND_API.g_miss_char;
   x_chan_rec.rating := FND_API.g_miss_char;
   x_chan_rec.attribute_category := FND_API.g_miss_char;
   x_chan_rec.attribute1 := FND_API.g_miss_char;
   x_chan_rec.attribute2 := FND_API.g_miss_char;
   x_chan_rec.attribute3 := FND_API.g_miss_char;
   x_chan_rec.attribute4 := FND_API.g_miss_char;
   x_chan_rec.attribute5 := FND_API.g_miss_char;
   x_chan_rec.attribute6 := FND_API.g_miss_char;
   x_chan_rec.attribute7 := FND_API.g_miss_char;
   x_chan_rec.attribute8 := FND_API.g_miss_char;
   x_chan_rec.attribute9 := FND_API.g_miss_char;
   x_chan_rec.attribute10 := FND_API.g_miss_char;
   x_chan_rec.attribute11 := FND_API.g_miss_char;
   x_chan_rec.attribute12 := FND_API.g_miss_char;
   x_chan_rec.attribute13 := FND_API.g_miss_char;
   x_chan_rec.attribute14 := FND_API.g_miss_char;
   x_chan_rec.attribute15 := FND_API.g_miss_char;
   x_chan_rec.channel_name := FND_API.g_miss_char;
   x_chan_rec.description := FND_API.g_miss_char;
   --added by rrajesh on 12/07/00
   x_chan_rec.country_id := FND_API.g_miss_num;
   -- removed by Rahul Sharma on 01/18/2001
   --x_chan_rec.internal_resource := FND_API.g_miss_char;
   -- end 01/18/2001
   --end addition 12/07/00
END init_chan_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    complete_chan_rec
--
-- HISTORY
--    23/11/99  mpande  Created.
--    01/18/2001 rssharma removed internal_resource attribute
---------------------------------------------------------------------
PROCEDURE complete_chan_rec(
   p_chan_rec      IN  chan_rec_type,
   x_complete_rec  OUT NOCOPY chan_rec_type
)
IS

   CURSOR c_chan IS
   SELECT *
     FROM ams_channels_vl
    WHERE channel_id = p_chan_rec.channel_id;

   l_chan_rec  c_chan%ROWTYPE;

BEGIN

   x_complete_rec := p_chan_rec;

   OPEN c_chan;
   FETCH c_chan INTO l_chan_rec;
   IF c_chan%NOTFOUND THEN
      CLOSE c_chan;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_chan;

   IF p_chan_rec.managed_by_person_id = FND_API.g_miss_num THEN
      x_complete_rec.managed_by_person_id := l_chan_rec.managed_by_person_id;
   END IF;

   IF p_chan_rec.active_from_date = FND_API.g_miss_date
   THEN
       x_complete_rec.active_from_date := l_chan_rec.active_from_date;
   END IF;

   IF p_chan_rec.active_to_date = FND_API.g_miss_date
   THEN
       x_complete_rec.active_to_date := l_chan_rec.active_to_date;
   END IF;

   IF p_chan_rec.outbound_flag = FND_API.g_miss_char THEN
      x_complete_rec.outbound_flag := l_chan_rec.outbound_flag;
   END IF;

   IF p_chan_rec.inbound_flag = FND_API.g_miss_char THEN
      x_complete_rec.inbound_flag := l_chan_rec.inbound_flag;
   END IF;

   IF p_chan_rec.order_sequence = FND_API.g_miss_num THEN
       x_complete_rec.order_sequence := l_chan_rec.order_sequence;
   END IF;

   IF p_chan_rec.channel_type_code = FND_API.g_miss_char THEN
      x_complete_rec.channel_type_code := l_chan_rec.channel_type_code;
   END IF;

   IF p_chan_rec.rating = FND_API.g_miss_char THEN
      x_complete_rec.rating := l_chan_rec.rating;
   END IF;

   IF p_chan_rec.preferred_vendor_id = FND_API.g_miss_num THEN
      x_complete_rec.preferred_vendor_id:= l_chan_rec.preferred_vendor_id;
   END IF;

   IF p_chan_rec.party_id = FND_API.g_miss_num THEN
      x_complete_rec.party_id:= l_chan_rec.party_id;
   END IF;


   IF p_chan_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_chan_rec.attribute_category;
   END IF;

   IF p_chan_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_chan_rec.attribute1;
   END IF;

   IF p_chan_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_chan_rec.attribute2;
   END IF;

   IF p_chan_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_chan_rec.attribute3;
   END IF;

   IF p_chan_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_chan_rec.attribute4;
   END IF;

   IF p_chan_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_chan_rec.attribute5;
   END IF;

   IF p_chan_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_chan_rec.attribute6;
   END IF;

   IF p_chan_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_chan_rec.attribute7;
   END IF;

   IF p_chan_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_chan_rec.attribute8;
   END IF;

   IF p_chan_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_chan_rec.attribute9;
   END IF;

   IF p_chan_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_chan_rec.attribute10;
   END IF;

   IF p_chan_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_chan_rec.attribute11;
   END IF;

   IF p_chan_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_chan_rec.attribute12;
   END IF;

   IF p_chan_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_chan_rec.attribute13;
   END IF;

   IF p_chan_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_chan_rec.attribute14;
   END IF;

   IF p_chan_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_chan_rec.attribute15;
   END IF;

   IF p_chan_rec.channel_name = FND_API.g_miss_char THEN
      x_complete_rec.channel_name := l_chan_rec.channel_name;
   END IF;

   IF p_chan_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_chan_rec.description;
   END IF;

   --Added by rrajesh on 12/07/00
   IF p_chan_rec.country_id = FND_API.g_miss_num THEN
      x_complete_rec.country_id := l_chan_rec.country_id;
   END IF;

   -- removed by Rahul Sharma on 01/18/2001
   --IF p_chan_rec.internal_resource = FND_API.g_miss_char THEN
      --x_complete_rec.internal_resource := l_chan_rec.internal_resource;
   --END IF;
   --end 01/18/2001
   --end 12/07/00
END complete_chan_rec;

--
-- Code added by abhola to this API ( code written by GJOBY )
--

---------------------------------------------------------------------
-- FUNCTION
--    get_party_name
-- USAGE
--    Example:
--       SELECT AMS_CHANNEL_PVT.get_party_name (party_id)
--       FROM   AMS_CHANNELS_VL
-- HISTORY
-- 25-MAY-2000 gjoby   Created.
---------------------------------------------------------------------
FUNCTION get_party_name (
   p_party_id IN NUMBER
)
RETURN VARCHAR2
IS
   l_party_name   VARCHAR2(255);

   CURSOR c_party_name IS
      SELECT party_name
      FROM   hz_parties
      WHERE  party_id = p_party_id;
BEGIN
   IF p_party_id IS NULL THEN
      RETURN NULL;
   END IF;

   OPEN c_party_name;
   FETCH c_party_name INTO l_party_name;
   CLOSE c_party_name;

   RETURN l_party_name;
END get_party_name;



---------------------------------------------------------------------
-- FUNCTION
--    get_party_number
-- USAGE
--    Example:
--       SELECT AMS_CHANNEL_PVT.get_party_number(party_id)
--       FROM   AMS_CHANNELS_VL
-- HISTORY
-- 25-MAY-2000 gjoby   Created.
---------------------------------------------------------------------
FUNCTION get_party_number (
   p_party_id IN NUMBER
)
RETURN VARCHAR2
IS
   l_party_number   VARCHAR2(30);

   CURSOR c_party_number IS
      SELECT party_number
      FROM   hz_parties
      WHERE  party_id = p_party_id;
BEGIN
   IF p_party_id IS NULL THEN
      RETURN NULL;
   END IF;

   OPEN c_party_number;
   FETCH c_party_number INTO l_party_number;
   CLOSE c_party_number;

   RETURN l_party_number;
END get_party_number;


---------------------------------------------------------------------
-- FUNCTION
--    get_party_type
-- USAGE
--    Example:
--       SELECT AMS_CHANNEL_PVT.get_party_type(party_id)
--       FROM   AMS_CHANNELS_VL
-- HISTORY
-- 25-MAY-2000 gjoby   Created.
---------------------------------------------------------------------
FUNCTION get_party_type (
   p_party_id IN NUMBER
)
RETURN VARCHAR2
IS
   l_party_type   VARCHAR2(30);

   CURSOR c_party_type IS
      SELECT party_type
      FROM   hz_parties
      WHERE  party_id = p_party_id;
BEGIN
   IF p_party_id IS NULL THEN
      RETURN NULL;
   END IF;

   OPEN c_party_type;
   FETCH c_party_type INTO l_party_type;
   CLOSE c_party_type;

   RETURN l_party_type;
END get_party_type;

---------------------------------------------------------------------
-- FUNCTION
--    get_vendor_name
-- USAGE
--    Example:
--       SELECT AMS_CHANNEL_PVT.get_vendor_name (PREFERRED_vendor_id)
--       FROM   AMS_CHANNELS_VL
-- HISTORY
-- 25-MAY-2000 gjoby   Created.
---------------------------------------------------------------------
FUNCTION get_vendor_name (
   p_vendor_id IN NUMBER
)
RETURN VARCHAR2
IS
   l_vendor_name   VARCHAR2(300);

   CURSOR c_vendor_name IS
      SELECT vendor_name
      FROM   po_vendors
      WHERE  vendor_id = p_vendor_id;
BEGIN
   IF p_vendor_id IS NULL THEN
      RETURN NULL;
   END IF;

   OPEN c_vendor_name;
   FETCH c_vendor_name INTO l_vendor_name;
   CLOSE c_vendor_name;

   RETURN l_vendor_name;
END get_vendor_name;

---------------------------------------------------------------------
-- FUNCTION
--    get_country_name
-- USAGE
--    Example:
--       SELECT AMS_CHANNEL_PVT.get_country_name (country_id)
--       FROM   jtf_loc_areas_vl
-- HISTORY
-- 13-DEC-2000 rrajesh   Created.
---------------------------------------------------------------------
FUNCTION get_country_name (
   p_country_id IN NUMBER
)
RETURN VARCHAR2
IS
   l_country_name   VARCHAR2(80);

   CURSOR c_country_name IS
      SELECT location_area_name
      FROM   jtf_loc_areas_vl
      WHERE location_area_id = p_country_id
      AND location_type_code = 'COUNTRY';

BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('arg in get_country_name() :' || p_country_id);
   END IF;

   IF p_country_id IS NULL THEN
      RETURN NULL;
   END IF;

   OPEN c_country_name;
   FETCH c_country_name INTO l_country_name;
   CLOSE c_country_name;

   RETURN l_country_name;
END get_country_name;


END AMS_CHANNEL_PVT;

/
