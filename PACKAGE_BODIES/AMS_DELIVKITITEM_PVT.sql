--------------------------------------------------------
--  DDL for Package Body AMS_DELIVKITITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DELIVKITITEM_PVT" AS
/* $Header: amsvdkib.pls 120.0 2005/06/01 03:28:05 appldev noship $ */

g_pkg_name      CONSTANT VARCHAR2(30):='AMS_DelivKitItem_PVT';

---------------------------------------------------------------------
-- PROCEDURE
--    create_deliv_kit_item
--
-- HISTORY
--    10/09/99  khung  Create.
---------------------------------------------------------------------

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_deliv_kit_item
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count    OUT NOCOPY NUMBER,
  x_msg_data     OUT NOCOPY VARCHAR2,

  p_deliv_kit_item_rec  IN      deliv_kit_item_rec_type,
  x_deliv_kit_item_id OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'create_deliv_kit_item';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status              VARCHAR2(1);
   l_deliv_kit_item_rec         deliv_kit_item_rec_type := p_deliv_kit_item_rec;
   l_deliv_kit_item_count       NUMBER;
   l_kit_flag                   VARCHAR2(1);
   l_kit_part_count             NUMBER;

   CURSOR c_deliv_kit_item_seq IS
   SELECT ams_deliv_kit_items_s.NEXTVAL
     FROM DUAL;

   CURSOR c_deliv_kit_item_count(deliv_kit_item_id IN NUMBER) IS
   SELECT COUNT(*)
     FROM ams_deliv_kit_items
    WHERE deliverable_kit_item_id = deliv_kit_item_id;

   -- AMS_KIT_PART_CANNOT_BE_KIT
   CURSOR c_deliv_kit_part_flag(deliv_kit_item_id IN NUMBER) IS
   SELECT kit_flag
     FROM ams_deliverables_all_b
    WHERE deliverable_id = deliv_kit_item_id;

   -- AMS_KIT_CANNOT_BE_KIT_PART
   /*
   CURSOR c_deliv_kit_part_count(deliv_kit_id IN NUMBER) IS
   SELECT COUNT(*)
     FROM ams_deliv_kit_items
    WHERE deliverable_kit_part_id = deliv_kit_id;*/

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_deliv_kit_item;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

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

   validate_deliv_kit_item
   (
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_deliv_kit_item_rec => l_deliv_kit_item_rec
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

   -- check the kit_flag for kit_part_item
   -- return false if this kit_part_item is also a kit
   OPEN c_deliv_kit_part_flag(l_deliv_kit_item_rec.deliverable_kit_part_id);
   FETCH c_deliv_kit_part_flag INTO l_kit_flag;
   CLOSE c_deliv_kit_part_flag;

   IF (l_kit_flag = 'Y')
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_KITPART_NOT_KIT');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   /*
   OPEN c_deliv_kit_part_count(l_deliv_kit_item_rec.deliverable_kit_id);
   FETCH c_deliv_kit_part_count INTO l_kit_part_count;
   CLOSE c_deliv_kit_part_count;

   IF (l_kit_part_count <> 0)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_KIT_NOT_KITPART');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   */

   IF l_deliv_kit_item_rec.deliverable_kit_item_id IS NULL THEN
   LOOP
      OPEN c_deliv_kit_item_seq;
      FETCH c_deliv_kit_item_seq INTO l_deliv_kit_item_rec.deliverable_kit_item_id;
      CLOSE c_deliv_kit_item_seq;

      OPEN c_deliv_kit_item_count(l_deliv_kit_item_rec.deliverable_kit_item_id);
      FETCH c_deliv_kit_item_count INTO l_deliv_kit_item_count;
      CLOSE c_deliv_kit_item_count;

      EXIT WHEN l_deliv_kit_item_count = 0;
   END LOOP;
   END IF;

   INSERT INTO ams_deliv_kit_items
   (
      deliverable_kit_item_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      deliverable_kit_id,
      deliverable_kit_part_id,
      kit_part_included_from_kit_id,
      quantity,
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
      attribute15
      ) VALUES (
      l_deliv_kit_item_rec.deliverable_kit_item_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,  -- object_version_number
      l_deliv_kit_item_rec.deliverable_kit_id,
      l_deliv_kit_item_rec.deliverable_kit_part_id,
      l_deliv_kit_item_rec.kit_part_included_from_kit_id,
      l_deliv_kit_item_rec.quantity,
      l_deliv_kit_item_rec.attribute_category,
      l_deliv_kit_item_rec.attribute1,
      l_deliv_kit_item_rec.attribute2,
      l_deliv_kit_item_rec.attribute3,
      l_deliv_kit_item_rec.attribute4,
      l_deliv_kit_item_rec.attribute5,
      l_deliv_kit_item_rec.attribute6,
      l_deliv_kit_item_rec.attribute7,
      l_deliv_kit_item_rec.attribute8,
      l_deliv_kit_item_rec.attribute9,
      l_deliv_kit_item_rec.attribute10,
      l_deliv_kit_item_rec.attribute11,
      l_deliv_kit_item_rec.attribute12,
      l_deliv_kit_item_rec.attribute13,
      l_deliv_kit_item_rec.attribute14,
      l_deliv_kit_item_rec.attribute15
   );


/*
-- musman 02/13/2002
-- Commenting the call to update kit flag
-- because the user would be allowed to change
-- the kit flag from the screen.

   -- modified by khung 12/13/1999
   -- change ams_deliverables_all_b.kit_flag to 'Y'
   UPDATE ams_deliverables_all_b
      SET kit_flag = 'Y'
    WHERE deliverable_id = l_deliv_kit_item_rec.deliverable_kit_id;


*/
/* commented by musman
   -- added by khung 03/22/2000
   -- indicate kit has been defined for this deliverable
   -- AMS_ObjectAttribute_PVT.modify_object_attribute(
   --   p_api_version        => l_api_version,
   --   p_init_msg_list      => FND_API.g_false,
   --   p_commit             => FND_API.g_false,
   --   p_validation_level   => FND_API.g_valid_level_full,
   --
   --   x_return_status      => l_return_status,
   --   x_msg_count          => x_msg_count,
   --   x_msg_data           => x_msg_data,
   --
   --   p_object_type        => 'DELV',
   --   p_object_id          => l_deliv_kit_item_rec.deliverable_kit_id,
   --   p_attr               => 'INVK',
   --   p_attr_defined_flag  => 'Y'
   --     );
   --IF l_return_status = FND_API.g_ret_sts_error THEN
   --   RAISE FND_API.g_exc_error;
   --ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
   --   RAISE FND_API.g_exc_unexpected_error;
   --END IF;
*/
   ------------------------- finish -------------------------------
   x_deliv_kit_item_id := l_deliv_kit_item_rec.deliverable_kit_item_id;

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
      ROLLBACK TO create_deliv_kit_item;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_deliv_kit_item;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_deliv_kit_item;
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

END create_deliv_kit_item;


--------------------------------------------------------------------
-- PROCEDURE
--    delete_deliv_kit_item
--
-- HISTORY
--    10/09/99  khung  Create.
--------------------------------------------------------------------

PROCEDURE delete_deliv_kit_item
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,

  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count    OUT NOCOPY NUMBER,
  x_msg_data     OUT NOCOPY VARCHAR2,

  p_deliv_kit_item_id   IN      NUMBER,
  p_object_version      IN      NUMBER
)

IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'delete_deliv_kit_item';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_kit_count            NUMBER;
  l_kit_id               NUMBER;

  CURSOR c_kit_count(kit_item_id IN NUMBER) IS
  SELECT COUNT(*)
    FROM ams_deliv_kit_items
   WHERE deliverable_kit_id =
       ( SELECT deliverable_kit_id
           FROM ams_deliv_kit_items
          WHERE deliverable_kit_item_id = kit_item_id);

  CURSOR c_kit_id(kit_item_id IN NUMBER) IS
  SELECT deliverable_kit_id
    FROM ams_deliv_kit_items
   WHERE deliverable_kit_item_id = kit_item_id;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_deliv_kit_item;

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

   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   OPEN c_kit_id(p_deliv_kit_item_id);
   FETCH c_kit_id INTO l_kit_id;
   CLOSE c_kit_id;

   OPEN c_kit_count(p_deliv_kit_item_id);
   FETCH c_kit_count INTO l_kit_count;
   CLOSE c_kit_count;

   DELETE FROM ams_deliv_kit_items
   WHERE deliverable_kit_item_id = p_deliv_kit_item_id
   AND object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': after delete');

   END IF;

   -- check if there are kit_part associated with this kit after the delete
   -- if not, change the deliverable's kit_flag to 'N'

   l_kit_count := l_kit_count - 1;
/*
-- musman 02/13/2002
-- Commenting the call to update kit flag
-- because the user would be allowed to change
-- the kit flag from the screen.

--   IF (l_kit_count < 1)
--   THEN
--     UPDATE ams_deliverables_all_b
--        SET kit_flag = 'N'
--      WHERE deliverable_id = l_kit_id;

-- commented by musman

    -- remove the 'check' icon when there is no kit item associated with
    -- this deliverable
--      AMS_ObjectAttribute_PVT.modify_object_attribute(
--         p_api_version        => l_api_version,
--         p_init_msg_list      => FND_API.g_false,
--         p_commit             => FND_API.g_false,
--         x_return_status      => x_return_status,
--         x_msg_count          => x_msg_count,
--         x_msg_data           => x_msg_data,
--         p_object_type        => 'DELV',
--         p_object_id          => l_kit_id,
--         p_attr               => 'INVK',
--         p_attr_defined_flag  => 'N'
--      );
--      IF x_return_status = FND_API.g_ret_sts_error THEN
--         RAISE FND_API.g_exc_error;
--      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
--         RAISE FND_API.g_exc_unexpected_error;
--      END IF;

--   END IF;

   */

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
      ROLLBACK TO delete_deliv_kit_item;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_deliv_kit_item;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_deliv_kit_item;
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

END delete_deliv_kit_item;

-------------------------------------------------------------------
-- PROCEDURE
--    lock_deliv_kit_item
--
-- PURPOSE
--    Lock a deliverable kit item.
--------------------------------------------------------------------

PROCEDURE lock_deliv_kit_item
(
   p_api_version        IN      NUMBER,
   p_init_msg_list      IN      VARCHAR2 := FND_API.g_false,

   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count   OUT NOCOPY NUMBER,
   x_msg_data    OUT NOCOPY VARCHAR2,

   p_deliv_kit_item_id  IN      NUMBER,
   p_object_version     IN      NUMBER
)

IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'lock_deliv_kit_item';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_deliv_kit_item_id      NUMBER;

   CURSOR c_deliv_kit_item IS
   SELECT deliverable_kit_item_id
     FROM ams_deliv_kit_items
    WHERE deliverable_kit_item_id = p_deliv_kit_item_id
      AND object_version_number = p_object_version
   FOR UPDATE OF deliverable_kit_item_id NOWAIT;

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

   OPEN c_deliv_kit_item;
   FETCH c_deliv_kit_item INTO l_deliv_kit_item_id;
   IF (c_deliv_kit_item%NOTFOUND) THEN
      CLOSE c_deliv_kit_item;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_deliv_kit_item;

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

END lock_deliv_kit_item;


---------------------------------------------------------------------
-- PROCEDURE
--    update_deliv_kit_item
--
-- HISTORY
--    10/09/99  khung  Create.
----------------------------------------------------------------------

PROCEDURE update_deliv_kit_item
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count    OUT NOCOPY NUMBER,
  x_msg_data     OUT NOCOPY VARCHAR2,

  p_deliv_kit_item_rec  IN      deliv_kit_item_rec_type
)

IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_deliv_kit_item';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_deliv_kit_item_rec deliv_kit_item_rec_type;
   l_return_status      VARCHAR2(1);

BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT update_deliv_kit_item;

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

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_deliv_kit_item_items
      (
         p_deliv_kit_item_rec => p_deliv_kit_item_rec,
         p_validation_mode    => JTF_PLSQL_API.g_update,
         x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- replace g_miss_char/num/date with current column values
   complete_deliv_kit_item_rec(p_deliv_kit_item_rec, l_deliv_kit_item_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_deliv_kit_item_record
      (
         p_deliv_kit_item_rec    => p_deliv_kit_item_rec,
         p_complete_rec => l_deliv_kit_item_rec,
         x_return_status         => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': update');
   END IF;

   UPDATE ams_deliv_kit_items SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      object_version_number = l_deliv_kit_item_rec.object_version_number + 1,
      deliverable_kit_id = l_deliv_kit_item_rec.deliverable_kit_id,
      deliverable_kit_part_id = l_deliv_kit_item_rec.deliverable_kit_part_id,
      kit_part_included_from_kit_id = l_deliv_kit_item_rec.kit_part_included_from_kit_id,
      quantity = l_deliv_kit_item_rec.quantity,
      attribute_category = l_deliv_kit_item_rec.attribute_category,
      attribute1 = l_deliv_kit_item_rec.attribute1,
      attribute2 = l_deliv_kit_item_rec.attribute2,
      attribute3 = l_deliv_kit_item_rec.attribute3,
      attribute4 = l_deliv_kit_item_rec.attribute4,
      attribute5 = l_deliv_kit_item_rec.attribute5,
      attribute6 = l_deliv_kit_item_rec.attribute6,
      attribute7 = l_deliv_kit_item_rec.attribute7,
      attribute8 = l_deliv_kit_item_rec.attribute8,
      attribute9 = l_deliv_kit_item_rec.attribute9,
      attribute10 = l_deliv_kit_item_rec.attribute10,
      attribute11 = l_deliv_kit_item_rec.attribute11,
      attribute12 = l_deliv_kit_item_rec.attribute12,
      attribute13 = l_deliv_kit_item_rec.attribute13,
      attribute14 = l_deliv_kit_item_rec.attribute14,
      attribute15 = l_deliv_kit_item_rec.attribute15
   WHERE deliverable_kit_item_id = l_deliv_kit_item_rec.deliverable_kit_item_id
   AND object_version_number = l_deliv_kit_item_rec.object_version_number;

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
      ROLLBACK TO update_deliv_kit_item;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_deliv_kit_item;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_deliv_kit_item;
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

END update_deliv_kit_item;

---------------------------------------------------------------------
-- PROCEDURE
--    validate_deliv_kit_item
--
-- HISTORY
--    10/09/99  khung  Create.
----------------------------------------------------------------------

PROCEDURE validate_deliv_kit_item
(
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count   OUT NOCOPY NUMBER,
   x_msg_data    OUT NOCOPY VARCHAR2,

   p_deliv_kit_item_rec IN  deliv_kit_item_rec_type
)

IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_deliv_kit_item';
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
      check_deliv_kit_item_items
      (
         p_deliv_kit_item_rec => p_deliv_kit_item_rec,
         p_validation_mode    => JTF_PLSQL_API.g_create,
         x_return_status      => l_return_status
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
      check_deliv_kit_item_record
      (
         p_deliv_kit_item_rec => p_deliv_kit_item_rec,
         p_complete_rec       => NULL,
         x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get
   (
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

      FND_MSG_PUB.count_and_get
      (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END validate_deliv_kit_item;

---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_kit_item_req_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------

PROCEDURE check_deliv_kit_item_req_items
(
   p_deliv_kit_item_rec IN  deliv_kit_item_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
)

IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -------------------- put required items here ---------------------

   IF p_deliv_kit_item_rec.deliverable_kit_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_KIT_NO_KIT_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_deliv_kit_item_rec.deliverable_kit_part_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DELIV_KIT_NO_KIT_PART_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END check_deliv_kit_item_req_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_kit_item_uk_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------

PROCEDURE check_deliv_kit_item_uk_items(
   p_deliv_kit_item_rec IN  deliv_kit_item_rec_type,
   p_validation_mode    IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status OUT NOCOPY VARCHAR2
)
IS

   l_valid_flag  VARCHAR2(1);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_deliv_kit_item, when deliverable_kit_item_id is passed in, we need to
   -- check if this deliverable_kit_item_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_deliv_kit_item_rec.deliverable_kit_item_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
                      'ams_deliv_kit_items',
                        'deliverable_kit_item_id = ' || p_deliv_kit_item_rec.deliverable_kit_item_id
                        ) = FND_API.g_false
                THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                        THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DELIV_KIT_ITEM_DUP_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other unique items

END check_deliv_kit_item_uk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_kit_item_fk_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_deliv_kit_item_fk_items
(
   p_deliv_kit_item_rec IN  deliv_kit_item_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
)
IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

      --------------------- deliverable_kit_id ----------------------------
   IF p_deliv_kit_item_rec.deliverable_kit_id <> FND_API.g_miss_num
   AND p_deliv_kit_item_rec.deliverable_kit_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_deliverables_all_b',
            'deliverable_id',
            p_deliv_kit_item_rec.deliverable_kit_id,
            AMS_Utility_PVT.g_number,
            NULL
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_DELIV_KIT_NO_KIT_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- deliverable_kit_part_id ----------------------------
   IF p_deliv_kit_item_rec.deliverable_kit_part_id <> FND_API.g_miss_num
   AND p_deliv_kit_item_rec.deliverable_kit_part_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_deliverables_all_b',
            'deliverable_id',
            p_deliv_kit_item_rec.deliverable_kit_part_id,
            AMS_Utility_PVT.g_number,
            NULL
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_DELV_KIT_TIP');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other fk items

END check_deliv_kit_item_fk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_kit_item_lk_items (lookup)
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_deliv_kit_item_lk_items
(
   p_deliv_kit_item_rec IN  deliv_kit_item_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
)
IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- check other lookup codes

END check_deliv_kit_item_lk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_kit_types
--    This method is used to find out whether the combination
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_kit_types
(
   p_deliv_kit_item_rec IN  deliv_kit_item_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
)
IS

CURSOR get_type(p_Deliv_id IN NUMBER)
IS
SELECT DECODE(can_fulfill_electronic_flag, 'Y', 'ELEC','PHYS')
FROM  ams_Deliverables_all_b
where deliverable_id = p_deliv_id;


CURSOR get_detail(p_deliv_id IN NUMBER)
IS
SELECT DECODE(inventory_flag, 'Y', 'INVN','PHYS') TYPE
       ,nvl(non_inv_quantity_on_hand,-99999) Quantity
FROM  ams_Deliverables_all_b
where deliverable_id = p_deliv_id;

l_kit_type VARCHAR2(4);
l_kit_part_type VARCHAR2(4);

l_kit_rec get_detail%ROWTYPE;
l_kit_part_rec get_detail%ROWTYPE;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- getting the type of kit
   OPEN get_type(p_deliv_kit_item_rec.deliverable_kit_id);
   FETCH get_type INTO l_kit_type;
   CLOSE get_type;

   -- getting the type of kit part
   OPEN get_type(p_deliv_kit_item_rec.deliverable_kit_part_id);
   FETCH get_type INTO l_kit_part_type;
   CLOSE get_type;

   IF l_kit_type <> l_kit_part_type
   THEN
      AMS_Utility_PVT.Error_Message('AMS_DELV_PHY_ELE_MISMATCH');
      -- The Deliverable kit and kit part are of different types. Please select you want to create kit for electronic
      -- deliverable or physical deliverable.
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF l_kit_type ='PHYS'
   THEN
      --collecting the details of Kit
      OPEN get_detail(p_deliv_kit_item_rec.deliverable_kit_id);
      FETCH get_detail INTO l_kit_rec;
      CLOSE get_detail;

      --collecting the details of Kit part
      OPEN get_detail(p_deliv_kit_item_rec.deliverable_kit_part_id);
      FETCH get_detail INTO l_kit_part_rec;
      CLOSE get_detail;

      IF l_kit_rec.type <> l_kit_part_rec.type
      THEN
         AMS_Utility_PVT.Error_Message('AMS_DELV_STO_INV_MISMATCH');
         -- The Deliverable kit and kit part are of different types. Please select whether you want to create kit for physically inventoried
         -- deliverable or physically stocked manual deliverable.
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF l_kit_rec.type = 'PHYS'
      AND( l_kit_rec.quantity = -99999
      OR  l_kit_part_rec.quantity = -99999)
      THEN
         AMS_Utility_PVT.Error_Message('AMS_DELV_KIT_NO_STOCK');
	 -- Please make this physical deliverable kit or kit part as stock manually, by adding the quantity .
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;

END check_kit_types;

---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_kit_item_fg_items (flag)
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_deliv_kit_item_fg_items
(
   p_deliv_kit_item_rec IN  deliv_kit_item_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
)
IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

    -- check other flags

END check_deliv_kit_item_fg_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_kit_item_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_deliv_kit_item_items
(
   p_deliv_kit_item_rec IN      deliv_kit_item_rec_type,
   p_validation_mode    IN      VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status OUT NOCOPY VARCHAR2
)
IS


BEGIN

   check_deliv_kit_item_req_items
   (
      p_deliv_kit_item_rec => p_deliv_kit_item_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_deliv_kit_item_uk_items
   (
      p_deliv_kit_item_rec => p_deliv_kit_item_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_deliv_kit_item_fk_items
   (
      p_deliv_kit_item_rec => p_deliv_kit_item_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_deliv_kit_item_lk_items
   (
      p_deliv_kit_item_rec => p_deliv_kit_item_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_deliv_kit_item_fg_items
   (
      p_deliv_kit_item_rec => p_deliv_kit_item_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_kit_types
   (
      p_deliv_kit_item_rec => p_deliv_kit_item_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


END check_deliv_kit_item_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_kit_item_record
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------

PROCEDURE check_deliv_kit_item_record
(
   p_deliv_kit_item_rec IN      deliv_kit_item_rec_type,
   p_complete_rec       IN      deliv_kit_item_rec_type := NULL,
   x_return_status OUT NOCOPY VARCHAR2
)

IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- do other record level checkings

END check_deliv_kit_item_record;


---------------------------------------------------------------------
-- PROCEDURE
--    init_deliv_kit_ite_rec
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------

PROCEDURE init_deliv_kit_ite_rec
(
   x_deliv_kit_item_rec OUT NOCOPY deliv_kit_item_rec_type
)
IS

BEGIN

   x_deliv_kit_item_rec.deliverable_kit_item_id := FND_API.g_miss_num;
   x_deliv_kit_item_rec.last_update_date := FND_API.g_miss_date;
   x_deliv_kit_item_rec.last_updated_by := FND_API.g_miss_num;
   x_deliv_kit_item_rec.creation_date := FND_API.g_miss_date;
   x_deliv_kit_item_rec.created_by := FND_API.g_miss_num;
   x_deliv_kit_item_rec.last_update_login := FND_API.g_miss_num;
   x_deliv_kit_item_rec.object_version_number := FND_API.g_miss_num;
   x_deliv_kit_item_rec.deliverable_kit_id := FND_API.g_miss_num;
   x_deliv_kit_item_rec.deliverable_kit_part_id := FND_API.g_miss_num;
   x_deliv_kit_item_rec.kit_part_included_from_kit_id := FND_API.g_miss_num;
   x_deliv_kit_item_rec.quantity := FND_API.g_miss_num;

   x_deliv_kit_item_rec.attribute_category := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute1 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute2 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute3 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute4 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute5 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute6 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute7 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute8 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute9 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute10 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute11 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute12 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute13 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute14 := FND_API.g_miss_char;
   x_deliv_kit_item_rec.attribute15 := FND_API.g_miss_char;

END init_deliv_kit_ite_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    complete_deliv_kit_item_rec
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE complete_deliv_kit_item_rec
(
   p_deliv_kit_item_rec IN      deliv_kit_item_rec_type,
   x_complete_rec OUT NOCOPY deliv_kit_item_rec_type
)

IS

   CURSOR c_deliv_kit_item IS
   SELECT *
     FROM ams_deliv_kit_items
    WHERE deliverable_kit_item_id = p_deliv_kit_item_rec.deliverable_kit_item_id;

   l_deliv_kit_item_rec  c_deliv_kit_item%ROWTYPE;

BEGIN

   x_complete_rec := p_deliv_kit_item_rec;

   OPEN c_deliv_kit_item;
   FETCH c_deliv_kit_item INTO l_deliv_kit_item_rec;
   IF c_deliv_kit_item%NOTFOUND THEN
      CLOSE c_deliv_kit_item;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_deliv_kit_item;

   IF p_deliv_kit_item_rec.deliverable_kit_id = FND_API.g_miss_num THEN
      x_complete_rec.deliverable_kit_id := l_deliv_kit_item_rec.deliverable_kit_id;
   END IF;

   IF p_deliv_kit_item_rec.deliverable_kit_part_id = FND_API.g_miss_num THEN
      x_complete_rec.deliverable_kit_part_id := l_deliv_kit_item_rec.deliverable_kit_part_id;
   END IF;

   IF p_deliv_kit_item_rec.kit_part_included_from_kit_id = FND_API.g_miss_num THEN
      x_complete_rec.kit_part_included_from_kit_id := l_deliv_kit_item_rec.kit_part_included_from_kit_id;
   END IF;

   IF p_deliv_kit_item_rec.quantity = FND_API.g_miss_num THEN
      x_complete_rec.quantity := l_deliv_kit_item_rec.quantity;
   END IF;

   IF p_deliv_kit_item_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_deliv_kit_item_rec.attribute_category;
   END IF;

   IF p_deliv_kit_item_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_deliv_kit_item_rec.attribute1;
   END IF;

   IF p_deliv_kit_item_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_deliv_kit_item_rec.attribute2;
   END IF;

   IF p_deliv_kit_item_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_deliv_kit_item_rec.attribute3;
   END IF;

   IF p_deliv_kit_item_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_deliv_kit_item_rec.attribute4;
   END IF;

   IF p_deliv_kit_item_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_deliv_kit_item_rec.attribute5;
   END IF;

   IF p_deliv_kit_item_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_deliv_kit_item_rec.attribute6;
   END IF;

   IF p_deliv_kit_item_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_deliv_kit_item_rec.attribute7;
   END IF;

   IF p_deliv_kit_item_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_deliv_kit_item_rec.attribute8;
   END IF;

   IF p_deliv_kit_item_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_deliv_kit_item_rec.attribute9;
   END IF;

   IF p_deliv_kit_item_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_deliv_kit_item_rec.attribute10;
   END IF;

   IF p_deliv_kit_item_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_deliv_kit_item_rec.attribute11;
   END IF;

   IF p_deliv_kit_item_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_deliv_kit_item_rec.attribute12;
   END IF;

   IF p_deliv_kit_item_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_deliv_kit_item_rec.attribute13;
   END IF;

   IF p_deliv_kit_item_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_deliv_kit_item_rec.attribute14;
   END IF;

   IF p_deliv_kit_item_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_deliv_kit_item_rec.attribute15;
   END IF;


END complete_deliv_kit_item_rec;


END AMS_DelivKitItem_PVT;

/
