--------------------------------------------------------
--  DDL for Package Body AMS_ACTPARTNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTPARTNER_PVT" AS
/* $Header: amsvapnb.pls 120.0 2005/05/31 16:39:43 appldev noship $ */

g_pkg_name	CONSTANT VARCHAR2(30):='AMS_ActPartner_PVT';

----------- Forward Declarations ---------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE check_act_partner_uk_items (
   p_act_partner_rec IN act_partner_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE check_act_partner_req_items(
   p_act_partner_rec    IN  act_partner_rec_type,
   x_return_status      OUT NOCOPY VARCHAR2
);

PROCEDURE check_primary (
   p_primary_flag  IN  VARCHAR2,
   p_act_partner_used_by_id  IN  NUMBER,
   p_arc_act_partner_used_by IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    create_act_partner
--
-- HISTORY
--    04/24/2000  khung@us    created
--   07-Nov-2000  choang      added call to modify object attr for
--                            tick to appear on the cue card item.
---------------------------------------------------------------------

PROCEDURE create_act_partner
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_act_partner_rec     IN  act_partner_rec_type,
  x_act_partner_id      OUT NOCOPY NUMBER
)
IS
   l_partner_attr_code  CONSTANT VARCHAR2(30) := 'PTNR';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_api_name           CONSTANT VARCHAR2(30) := 'create_act_partner';
   l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status      VARCHAR2(1);
   l_act_partner_count  NUMBER;
   l_act_partner_rec    act_partner_rec_type := p_act_partner_rec;

   CURSOR c_act_partner_seq IS
   SELECT ams_act_partners_s.NEXTVAL
     FROM DUAL;

   CURSOR c_act_partner_count(act_partner_id IN NUMBER) IS
   SELECT COUNT(*)
     FROM ams_act_partners
    WHERE activity_partner_id = act_partner_id;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_act_partner;


   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
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

   validate_act_partner
   (
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_act_partner_rec    => l_act_partner_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -------------------------- insert --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;

   IF l_act_partner_rec.activity_partner_id IS NULL THEN
       LOOP
          OPEN c_act_partner_seq;
          FETCH c_act_partner_seq INTO l_act_partner_rec.activity_partner_id;
          CLOSE c_act_partner_seq;

          OPEN c_act_partner_count(l_act_partner_rec.activity_partner_id);
          FETCH c_act_partner_count INTO l_act_partner_count;
          CLOSE c_act_partner_count;

          EXIT WHEN l_act_partner_count = 0;
       END LOOP;
   END IF;

   check_act_partner_req_items(
   p_act_partner_rec    => l_act_partner_rec,
   x_return_status      => l_return_status
);

 check_primary(l_act_partner_rec.primary_flag ,l_act_partner_rec.act_partner_used_by_id,l_act_partner_rec.arc_act_partner_used_by,l_return_status);
   ---------------------- insert --------------------------
   INSERT INTO ams_act_partners(

        activity_partner_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        object_version_number,
        act_partner_used_by_id,
        arc_act_partner_used_by,
        primary_flag,
        partner_id,
        partner_type,
        description,
        attribute_category,
        preferred_vad_id,
        partner_address_id,
	primary_contact_id,
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
        attribute15
      ) VALUES (
        l_act_partner_rec.activity_partner_id,
        SYSDATE,
        FND_GLOBAL.user_id,
        SYSDATE,
        FND_GLOBAL.user_id,
        FND_GLOBAL.conc_login_id,
        1,
        l_act_partner_rec.act_partner_used_by_id,
        l_act_partner_rec.arc_act_partner_used_by,
        l_act_partner_rec.primary_flag,
        l_act_partner_rec.partner_id,
        l_act_partner_rec.partner_type,
        l_act_partner_rec.description,
        l_act_partner_rec.attribute_category,
        l_act_partner_rec.preferred_vad_id,
        l_act_partner_rec.partner_address_id,
	l_act_partner_rec.primary_contact_id,
        l_act_partner_rec.attribute1,
        l_act_partner_rec.attribute2,
        l_act_partner_rec.attribute3,
        l_act_partner_rec.attribute4,
        l_act_partner_rec.attribute5,
        l_act_partner_rec.attribute6,
        l_act_partner_rec.attribute7,
        l_act_partner_rec.attribute8,
        l_act_partner_rec.attribute9,
        l_act_partner_rec.attribute10,
        l_act_partner_rec.attribute11,
        l_act_partner_rec.attribute12,
        l_act_partner_rec.attribute13,
        l_act_partner_rec.attribute14,
        l_act_partner_rec.attribute15
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': call modify_object_attribute');

   END IF;

    IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

   ------------------------- finish -------------------------------
   x_act_partner_id := l_act_partner_rec.activity_partner_id;

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
      ROLLBACK TO create_act_partner;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_act_partner;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_act_partner;
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

END create_act_partner;

---------------------------------------------------------------------
-- PROCEDURE
--    update_act_partner
--
-- HISTORY
--    04/24/2000    khung@us    created
----------------------------------------------------------------------

PROCEDURE update_act_partner
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,
  --p_object_version_number IN NUMBER,

  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,

  p_act_partner_rec     IN  act_partner_rec_type
)
IS

   l_api_version        CONSTANT NUMBER := 1.0;
   l_api_name           CONSTANT VARCHAR2(30) := 'update_act_partner';
   l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_act_partner_rec    act_partner_rec_type;
   l_return_status      VARCHAR2(1);

BEGIN

   -------------------- initialize -------------------------


   SAVEPOINT update_act_partner;
l_act_partner_rec := p_act_partner_rec;
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

   -- replace g_miss_char/num/date with current column values
   complete_act_partner_rec(p_act_partner_rec, l_act_partner_rec);


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message('check_act_partner_items');

      END IF;

      check_act_partner_items(
         p_act_partner_rec => p_act_partner_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message('check_act_partner_record');

      END IF;

      check_act_partner_record(
         p_act_partner_rec  => p_act_partner_rec,
         p_complete_rec     => l_act_partner_rec,
         x_return_status    => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   -------------------------- update --------------------

   UPDATE ams_act_partners SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      primary_flag =  l_act_partner_rec.primary_flag,
      object_version_number = l_act_partner_rec.object_version_number + 1,
      act_partner_used_by_id = l_act_partner_rec.act_partner_used_by_id,
      arc_act_partner_used_by = l_act_partner_rec.arc_act_partner_used_by,
      partner_id = l_act_partner_rec.partner_id,
      partner_type = l_act_partner_rec.partner_type,
      description = l_act_partner_rec.description,
      attribute_category = l_act_partner_rec.attribute_category,
      preferred_vad_id = l_act_partner_rec.preferred_vad_id,
      partner_address_id =  l_act_partner_rec.partner_address_id,
      primary_contact_id =  l_act_partner_rec.primary_contact_id,
      attribute1 = l_act_partner_rec.attribute1,
      attribute2 = l_act_partner_rec.attribute2,
      attribute3 = l_act_partner_rec.attribute3,
      attribute4 = l_act_partner_rec.attribute4,
      attribute5 = l_act_partner_rec.attribute5,
      attribute6 = l_act_partner_rec.attribute6,
      attribute7 = l_act_partner_rec.attribute7,
      attribute8 = l_act_partner_rec.attribute8,
      attribute9 = l_act_partner_rec.attribute9,
      attribute10 = l_act_partner_rec.attribute10,
      attribute11 = l_act_partner_rec.attribute11,
      attribute12 = l_act_partner_rec.attribute12,
      attribute13 = l_act_partner_rec.attribute13,
      attribute14 = l_act_partner_rec.attribute14,
      attribute15 = l_act_partner_rec.attribute15
    WHERE activity_partner_id = l_act_partner_rec.activity_partner_id
    AND object_version_number = l_act_partner_rec.object_version_number;

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
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('into exception block');
   END IF;

      ROLLBACK TO update_act_partner;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
      --RAISE FND_API.G_EXC_ERROR;

   WHEN FND_API.g_exc_unexpected_error THEN

      ROLLBACK TO update_act_partner;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
      --RAISE FND_API.g_exc_unexpected_error;

   WHEN OTHERS THEN

      ROLLBACK TO update_act_partner;
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
       --RAISE FND_API.G_EXC_ERROR;

END update_act_partner;

--------------------------------------------------------------------
-- PROCEDURE
--    delete_act_partner
--
-- HISTORY
--    04/24/2000    khung@us    created
--   07-Nov-2000    choang      Added call to modify object attr
--                              if no more partners associated to
--                              the object, so the tick on the
--                              screen goes away.
--------------------------------------------------------------------

PROCEDURE delete_act_partner
(
  p_api_version     IN  NUMBER,
  p_init_msg_list   IN  VARCHAR2 := FND_API.g_false,
  p_commit          IN  VARCHAR2 := FND_API.g_false,

  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2,

  p_act_partner_id  IN  NUMBER,
  p_object_version  IN  NUMBER
)
IS
   l_partner_attr_code  CONSTANT VARCHAR2(30) := 'PTNR';
   l_api_version     CONSTANT NUMBER       := 1.0;
   l_api_name        CONSTANT VARCHAR2(30) := 'delete_act_partner';
   l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_object_type     VARCHAR2(30);
   l_object_id       NUMBER;
   l_dummy           NUMBER;
   l_return_status   VARCHAR2(1);
   l_primary_flag    VARCHAR2(5);

   --
   -- capture the arc_used_by and used_by_id before
   -- deleting for post delete validation that a
   -- partner is still associated to the marketing
   -- object.
   --
   -- c_partner_type: captures the arc_used_by and
   --                 used_by_id
   -- c_partner_attr: validates that a partner is
   --                 still associated to the marketing
   --                 object.
   CURSOR c_partner_type (p_act_partner_id IN NUMBER) IS
      SELECT arc_act_partner_used_by, act_partner_used_by_id
      FROM   ams_act_partners
      WHERE  activity_partner_id = p_act_partner_id;

   CURSOR c_partner_attr (p_object_type IN VARCHAR2, p_object_id IN NUMBER) IS
      SELECT 1
      FROM  ams_act_partners
      WHERE arc_act_partner_used_by = p_object_type
      AND   act_partner_used_by_id = p_object_id;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_act_partner;

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

   OPEN c_partner_type (p_act_partner_id);
   FETCH c_partner_type INTO l_object_type, l_object_id;
   CLOSE c_partner_type;


   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(p_act_partner_id ||': p_act_partner_id');
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(p_object_version ||': p_object_version');
   END IF;

   DELETE FROM ams_act_partners
   WHERE activity_partner_id = p_act_partner_id
   AND object_version_number = p_object_version;

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
      ROLLBACK TO delete_act_partner;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_act_partner;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_deliverable;
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


END delete_act_partner;

-------------------------------------------------------------------
-- PROCEDURE
--    lock_act_partner
--
-- HISTORY
--    04/24/2000    khung@us    created
--------------------------------------------------------------------

PROCEDURE lock_act_partner
(
   p_api_version    IN  NUMBER,
   p_init_msg_list  IN  VARCHAR2 := FND_API.g_false,

   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,

   p_act_partner_id IN  NUMBER,
   p_object_version IN  NUMBER
)
IS

   l_api_version    CONSTANT NUMBER       := 1.0;
   l_api_name       CONSTANT VARCHAR2(30) := 'lock_act_partner';
   l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_act_partner_id NUMBER;

   CURSOR c_act_partner IS
   SELECT activity_partner_id
     FROM ams_act_partners
    WHERE activity_partner_id = p_act_partner_id
      AND object_version_number = p_object_version
   FOR UPDATE OF activity_partner_id NOWAIT;

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

   OPEN c_act_partner;
   FETCH c_act_partner INTO l_act_partner_id;
   IF (c_act_partner%NOTFOUND) THEN
      CLOSE c_act_partner;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_act_partner;

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


END lock_act_partner;


---------------------------------------------------------------------
-- PROCEDURE
--    validate_act_partner
--
-- HISTORY
--    04/24/2000    khung@us    created
----------------------------------------------------------------------

PROCEDURE validate_act_partner
(
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_act_partner_rec    IN  act_partner_rec_type
)
IS

   l_api_version        CONSTANT NUMBER       := 1.0;
   l_api_name           CONSTANT VARCHAR2(30) := 'validate_act_partner';
   l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status      VARCHAR2(1);

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
      check_act_partner_items(
         p_act_partner_rec => p_act_partner_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': check record');

   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_act_partner_record(
         p_act_partner_rec  => p_act_partner_rec,
         p_complete_rec     => NULL,
         x_return_status    => l_return_status
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


END validate_act_partner;

---------------------------------------------------------------------
-- PROCEDURE
--    check_act_partner_req_items
--
-- HISTORY
--    04/24/2000    khung@us    created
---------------------------------------------------------------------
PROCEDURE check_act_partner_req_items(
   p_act_partner_rec    IN  act_partner_rec_type,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -------------------- put required items here ---------------------

   IF p_act_partner_rec.act_partner_used_by_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_ACT_PARTNER_NO_USEDBY_ID');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;

      x_return_status := FND_API.g_ret_sts_error;
    END IF;

   IF p_act_partner_rec.arc_act_partner_used_by IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_ACT_PARTNER_NO_USEDBY');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
      END IF;

   IF p_act_partner_rec.partner_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_ACT_PARTNER_NO_PARTNER_ID');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
     END IF;

END check_act_partner_req_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_act_partner_items
--
-- HISTORY
--    04/24/2000    khung@us    created
---------------------------------------------------------------------
PROCEDURE check_act_partner_items
(
   p_act_partner_rec    IN  act_partner_rec_type,
   p_validation_mode    IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
   l_act_partner_rec    act_partner_rec_type;

BEGIN
l_act_partner_rec := p_act_partner_rec;

   check_act_partner_req_items
   (
      p_act_partner_rec => p_act_partner_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_act_partner_uk_items (
      p_act_partner_rec => p_act_partner_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
END check_act_partner_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_act_partner_record
--
-- HISTORY
--    04/24/2000    khung@us    created
---------------------------------------------------------------------

PROCEDURE check_act_partner_record
(
   p_act_partner_rec    IN  act_partner_rec_type,
   p_complete_rec       IN  act_partner_rec_type := NULL,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- do other record level checkings

END check_act_partner_record;


---------------------------------------------------------------------
-- PROCEDURE
--    init_act_partner_rec
--
-- HISTORY
--    04/24/2000    khung@us    created
---------------------------------------------------------------------

PROCEDURE init_act_partner_rec
(
   x_act_partner_rec    OUT NOCOPY	act_partner_rec_type
)
IS

BEGIN

   x_act_partner_rec.activity_partner_id := FND_API.g_miss_num;
   x_act_partner_rec.last_update_date := FND_API.g_miss_date;
   x_act_partner_rec.last_updated_by := FND_API.g_miss_num;
   x_act_partner_rec.creation_date := FND_API.g_miss_date;
   x_act_partner_rec.created_by := FND_API.g_miss_num;
   x_act_partner_rec.last_update_login := FND_API.g_miss_num;
   x_act_partner_rec.object_version_number := FND_API.g_miss_num;
   x_act_partner_rec.act_partner_used_by_id := FND_API.g_miss_num;
   x_act_partner_rec.arc_act_partner_used_by := FND_API.g_miss_char;
   x_act_partner_rec.partner_id := FND_API.g_miss_num;
   x_act_partner_rec.primary_flag := FND_API.g_miss_char;
   x_act_partner_rec.partner_type := FND_API.g_miss_char;
   x_act_partner_rec.description := FND_API.g_miss_char;
    x_act_partner_rec.attribute_category := FND_API.g_miss_char;
   x_act_partner_rec.preferred_vad_id := FND_API.g_miss_num;
   x_act_partner_rec.partner_address_id := FND_API.g_miss_num;
   x_act_partner_rec.primary_contact_id := FND_API.g_miss_num;
   x_act_partner_rec.attribute1 := FND_API.g_miss_char;
   x_act_partner_rec.attribute2 := FND_API.g_miss_char;
   x_act_partner_rec.attribute3 := FND_API.g_miss_char;
   x_act_partner_rec.attribute4 := FND_API.g_miss_char;
   x_act_partner_rec.attribute5 := FND_API.g_miss_char;
   x_act_partner_rec.attribute6 := FND_API.g_miss_char;
   x_act_partner_rec.attribute7 := FND_API.g_miss_char;
   x_act_partner_rec.attribute8 := FND_API.g_miss_char;
   x_act_partner_rec.attribute9 := FND_API.g_miss_char;
   x_act_partner_rec.attribute10 := FND_API.g_miss_char;
   x_act_partner_rec.attribute11 := FND_API.g_miss_char;
   x_act_partner_rec.attribute12 := FND_API.g_miss_char;
   x_act_partner_rec.attribute13 := FND_API.g_miss_char;
   x_act_partner_rec.attribute14 := FND_API.g_miss_char;
   x_act_partner_rec.attribute15 := FND_API.g_miss_char;

END init_act_partner_rec;

---------------------------------------------------------------------
-- PROCEDURE
--    complete_act_partner_rec
--
-- HISTORY
--    04/24/2000    khung@us    created
---------------------------------------------------------------------
PROCEDURE complete_act_partner_rec
(
   p_act_partner_rec    IN  act_partner_rec_type,
   x_complete_rec       OUT NOCOPY act_partner_rec_type
)
IS

   CURSOR c_act_partner IS
   SELECT *
     FROM ams_act_partners
    WHERE activity_partner_id = p_act_partner_rec.activity_partner_id;

   l_act_partner_rec  c_act_partner%ROWTYPE;

BEGIN

   x_complete_rec := p_act_partner_rec;

   OPEN c_act_partner;
   FETCH c_act_partner INTO l_act_partner_rec;
      IF c_act_partner%NOTFOUND THEN
      CLOSE c_act_partner;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   --CLOSE c_act_partner;
IF (AMS_DEBUG_HIGH_ON) THEN

AMS_Utility_PVT.debug_message('end cursor...');
END IF;

   IF p_act_partner_rec.act_partner_used_by_id = FND_API.g_miss_num THEN
      x_complete_rec.act_partner_used_by_id := l_act_partner_rec.act_partner_used_by_id;
   END IF;

   IF p_act_partner_rec.arc_act_partner_used_by = FND_API.g_miss_char THEN
      x_complete_rec.arc_act_partner_used_by := l_act_partner_rec.arc_act_partner_used_by;
   END IF;

   IF p_act_partner_rec.primary_flag = FND_API.g_miss_char THEN
      x_complete_rec.primary_flag := l_act_partner_rec.primary_flag;
   END IF;

   IF p_act_partner_rec.partner_id = FND_API.g_miss_num THEN
      x_complete_rec.partner_id := l_act_partner_rec.partner_id;
   END IF;

   IF p_act_partner_rec.partner_type = FND_API.g_miss_char THEN
      x_complete_rec.partner_type := l_act_partner_rec.partner_type;
   END IF;

   IF p_act_partner_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_act_partner_rec.description;
   END IF;

   IF p_act_partner_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_act_partner_rec.attribute_category;
   END IF;

   IF p_act_partner_rec.preferred_vad_id = FND_API.g_miss_num THEN
      x_complete_rec.preferred_vad_id := l_act_partner_rec.preferred_vad_id;
   END IF;

   IF p_act_partner_rec.partner_address_id = FND_API.g_miss_num THEN
      x_complete_rec.partner_address_id := l_act_partner_rec.partner_address_id;
   END IF;

   IF p_act_partner_rec.primary_contact_id = FND_API.g_miss_num THEN
      x_complete_rec.primary_contact_id := l_act_partner_rec.primary_contact_id;
   END IF;

   IF p_act_partner_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_act_partner_rec.attribute1;
   END IF;

   IF p_act_partner_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_act_partner_rec.attribute2;
   END IF;

   IF p_act_partner_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_act_partner_rec.attribute3;
   END IF;

   IF p_act_partner_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_act_partner_rec.attribute4;
   END IF;

   IF p_act_partner_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_act_partner_rec.attribute5;
   END IF;

   IF p_act_partner_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_act_partner_rec.attribute6;
   END IF;

   IF p_act_partner_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_act_partner_rec.attribute7;
   END IF;

   IF p_act_partner_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_act_partner_rec.attribute8;
   END IF;

   IF p_act_partner_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_act_partner_rec.attribute9;
   END IF;

   IF p_act_partner_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_act_partner_rec.attribute10;
   END IF;

   IF p_act_partner_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_act_partner_rec.attribute11;
   END IF;

   IF p_act_partner_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_act_partner_rec.attribute12;
   END IF;

   IF p_act_partner_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_act_partner_rec.attribute13;
   END IF;

   IF p_act_partner_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_act_partner_rec.attribute14;
   END IF;

   IF p_act_partner_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_act_partner_rec.attribute15;
   END IF;
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message('end of complete_act_partner_rec...');
    END IF;

END complete_act_partner_rec;

PROCEDURE check_primary (
   p_primary_flag  IN  VARCHAR2,
   p_act_partner_used_by_id  IN  NUMBER,
   p_arc_act_partner_used_by IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
l_flagStatus  NUMBER :=0;
l_flagStatusUpd  NUMBER :=0;
l_act_partner_used_by_id NUMBER := 0;
l_arc_act_partner_used_by VARCHAR2(10);
l_flag   NUMBER :=0;
l_primary VARCHAR2(10);
l_activity_partner_id NUMBER :=0;

CURSOR c_primary_flag(l_id IN NUMBER , l_used_by IN VARCHAR2) IS
   SELECT count(*)
    FROM ams_act_partners
    WHERE primary_flag = 'Y'
    AND    act_partner_used_by_id = l_id
    AND    arc_act_partner_used_by = l_used_by;
BEGIN
   l_arc_act_partner_used_by := p_arc_act_partner_used_by;
   l_act_partner_used_by_id := p_act_partner_used_by_id;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(':error message');
   END IF;
  OPEN c_primary_flag(l_act_partner_used_by_id,l_arc_act_partner_used_by);
     FETCH c_primary_flag INTO l_flag;
  CLOSE c_primary_flag;
  l_flagStatus := l_flagStatus + l_flag;

   IF (p_primary_flag = 'Y') THEN
   -- dbms_output.put_line(':p_primary_flag = T');
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(':p_primary_flag = T');
   END IF;
   l_flagStatus := l_flagStatus + 1;
   END IF;

    IF (l_flagStatus >=2) THEN
   -- dbms_output.put_line(':error message');
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(':error message');
    END IF;
   --AMS_Utility_PVT.error_message ('AMS_ACT_INVALID_PRIMARY', 'PRIMARY_FLAG', p_primary_flag);
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_ACT_INVALID_PRIMARY');
      FND_MSG_PUB.add;
   END IF;
   x_return_status := FND_API.g_ret_sts_error;
END IF;
END check_primary;

PROCEDURE check_act_partner_uk_items (
   p_act_partner_rec IN act_partner_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
)
IS
   l_partner_name       VARCHAR2(360);
   CURSOR c_partner_name (p_partner_id IN NUMBER) IS
      SELECT partner_party_name
      FROM   pv_partners_v
      WHERE  partner_id = p_partner_id; -- instead of partner_party_id; anchaudh changed it to partner_id on 30 Apr-05.
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- validate uniqueness of arc_used_by, arc_used_by_id, and partner_id
   IF AMS_Utility_PVT.check_uniqueness (
         'AMS_ACT_PARTNERS',
         'arc_act_partner_used_by = ' || p_act_partner_rec.arc_act_partner_used_by ||
         ' AND act_partner_used_by_id = ' || p_act_partner_rec.act_partner_used_by_id ||
         ' AND partner_id = ' || p_act_partner_rec.partner_id
      ) = FND_API.g_false THEN
      OPEN c_partner_name (p_act_partner_rec.partner_id);
      FETCH c_partner_name INTO l_partner_name;
      CLOSE c_partner_name;
      AMS_Utility_PVT.error_message ('AMS_ACTPART_DUP_ACTPARTNER', 'PARTNER_NAME', l_partner_name);
      x_return_status := FND_API.g_ret_sts_error;
   END IF;
END check_act_partner_uk_items;

END AMS_ActPartner_PVT;

/
