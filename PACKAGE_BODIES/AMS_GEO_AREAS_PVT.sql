--------------------------------------------------------
--  DDL for Package Body AMS_GEO_AREAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_GEO_AREAS_PVT" AS
/* $Header: amsvgeob.pls 115.16 2002/11/22 23:37:12 dbiswas ship $ */

g_pkg_name      CONSTANT VARCHAR2(30) := 'AMS_Geo_Areas_PVT';

/*****************************************************************************/
-- Procedure: create_geo_area
--
-- History
--   12/3/1999      julou      created
-------------------------------------------------------------------------------
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_geo_area
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_geo_area_rec          IN      geo_area_rec_type,
  x_geo_area_id           OUT NOCOPY     NUMBER
)
IS

  l_api_version     CONSTANT NUMBER := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'create_geo_area';
  l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status   VARCHAR2(1);
  l_geo_area_rec    geo_area_rec_type := p_geo_area_rec;
  l_geo_area_count  NUMBER;

  CURSOR c_geo_area_seq IS
    SELECT AMS_ACT_GEO_AREAS_S.NEXTVAL
    FROM DUAL;

  CURSOR c_geo_area_count(geo_area_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM AMS_ACT_GEO_AREAS
    WHERE activity_geo_area_id = geo_area_id;

BEGIN
-- initialize
  SAVEPOINT create_geo_area;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name || ': start');

  END IF;

  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name
  )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

-- validate
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(l_full_name || ': validate');
    END IF;

    validate_geo_area
    (
      p_api_version      => l_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_geo_area_rec     => l_geo_area_rec
    );

    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
  END IF;

-- insert
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': insert');
  END IF;

  IF l_geo_area_rec.activity_geo_area_id IS NULL THEN
    LOOP
      OPEN c_geo_area_seq;
      FETCH c_geo_area_seq INTO l_geo_area_rec.activity_geo_area_id;
      CLOSE c_geo_area_seq;

      OPEN c_geo_area_count(l_geo_area_rec.activity_geo_area_id);
      FETCH c_geo_area_count INTO l_geo_area_count;
      CLOSE c_geo_area_count;

      EXIT WHEN l_geo_area_count = 0;
    END LOOP;
  END IF;

  INSERT INTO AMS_ACT_GEO_AREAS
  (
    activity_geo_area_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    object_version_number,
    act_geo_area_used_by_id,
    arc_act_geo_area_used_by,
    geo_area_type_code,
    geo_hierarchy_id,
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
  )
  VALUES
  (
    l_geo_area_rec.activity_geo_area_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id,
    1,
    l_geo_area_rec.act_geo_area_used_by_id,
    l_geo_area_rec.arc_act_geo_area_used_by,
    l_geo_area_rec.geo_area_type_code,
    l_geo_area_rec.geo_hierarchy_id,
    l_geo_area_rec.attribute_category,
    l_geo_area_rec.attribute1,
    l_geo_area_rec.attribute2,
    l_geo_area_rec.attribute3,
    l_geo_area_rec.attribute4,
    l_geo_area_rec.attribute5,
    l_geo_area_rec.attribute6,
    l_geo_area_rec.attribute7,
    l_geo_area_rec.attribute8,
    l_geo_area_rec.attribute9,
    l_geo_area_rec.attribute10,
    l_geo_area_rec.attribute11,
    l_geo_area_rec.attribute12,
    l_geo_area_rec.attribute13,
    l_geo_area_rec.attribute14,
    l_geo_area_rec.attribute15
  );

-- added by julou on 03/07/2000
   -- indicate offer has been defined for the campaign
   -- commented out by soagrawa on 24-May-2001
/*   AMS_ObjectAttribute_PVT.modify_object_attribute(
      p_api_version        => l_api_version,
      p_init_msg_list      => FND_API.g_false,
      p_commit             => FND_API.g_false,
      p_validation_level   => FND_API.g_valid_level_full,

      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,

      p_object_type        => l_geo_area_rec.arc_act_geo_area_used_by,
      p_object_id          => l_geo_area_rec.act_geo_area_used_by_id,
      p_attr               => 'GEOS',
      p_attr_defined_flag  => 'Y'
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
-- end of added part
*/
-- finish
  x_geo_area_id := l_geo_area_rec.activity_geo_area_id;

  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get
  (
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
  );

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name||': end');

  END IF;

  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_geo_area;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_geo_area;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO create_geo_area;
      x_return_status :=FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

END create_geo_area;


/*****************************************************************************/
-- Procedure: update_geo_area
--
-- History
--   12/3/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE update_geo_area
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER := FND_API.g_valid_level_full,
  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_geo_area_rec          IN      geo_area_rec_type
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'update_geo_area';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status VARCHAR2(1);
  l_geo_area_rec  geo_area_rec_type := p_geo_area_rec;

BEGIN

-- initialize
  SAVEPOINT update_geo_area;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name || ': start');

  END IF;

  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name
  )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

-- complete record
  complete_geo_area_rec
  (
    p_geo_area_rec,
    l_geo_area_rec
  );
-- validate
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(l_full_name || ': validate'||l_geo_area_rec.object_version_number);
    END IF;

    check_items
    (
      p_validation_mode  => JTF_PLSQL_API.g_update,
      x_return_status    => l_return_status,
      p_geo_area_rec     => l_geo_area_rec
    );

    IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    ELSIF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;

-- update
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name||': update');
  END IF;

  UPDATE AMS_ACT_GEO_AREAS SET
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    last_update_login = FND_GLOBAL.conc_login_id,
    object_version_number = l_geo_area_rec.object_version_number + 1,
    act_geo_area_used_by_id = l_geo_area_rec.act_geo_area_used_by_id,
    arc_act_geo_area_used_by = l_geo_area_rec.arc_act_geo_area_used_by,
    geo_area_type_code = l_geo_area_rec.geo_area_type_code,
    geo_hierarchy_id  = l_geo_area_rec.geo_hierarchy_id,
    attribute_category = l_geo_area_rec.attribute_category,
    attribute1 = l_geo_area_rec.attribute1,
    attribute2 = l_geo_area_rec.attribute2,
    attribute3 = l_geo_area_rec.attribute3,
    attribute4 = l_geo_area_rec.attribute4,
    attribute5 = l_geo_area_rec.attribute5,
    attribute6 = l_geo_area_rec.attribute6,
    attribute7 = l_geo_area_rec.attribute7,
    attribute8 = l_geo_area_rec.attribute8,
    attribute9 = l_geo_area_rec.attribute9,
    attribute10 = l_geo_area_rec.attribute10,
    attribute11 = l_geo_area_rec.attribute11,
    attribute12 = l_geo_area_rec.attribute12,
    attribute13 = l_geo_area_rec.attribute13,
    attribute14 = l_geo_area_rec.attribute14,
    attribute15 = l_geo_area_rec.attribute15
  WHERE activity_geo_area_id = l_geo_area_rec.activity_geo_area_id
  AND object_version_number = l_geo_area_rec.object_version_number;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

-- finish
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get
  (
    P_ENCODED => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
  );

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name || ': end');

  END IF;

  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_geo_area;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_geo_area;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO update_geo_area;
      x_return_status :=FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

END update_geo_area;


/*****************************************************************************/
-- Procedure: delete_geo_area
--
-- History
--   12/3/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE delete_geo_area
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_geo_area_id           IN      NUMBER,
  p_object_version        IN      NUMBER
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_geo_area';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_used_by_id             NUMBER;
  l_used_by                VARCHAR2(30);
  l_dummy                  NUMBER;

   CURSOR c_used_by IS
   SELECT act_geo_area_used_by_id, arc_act_geo_area_used_by
     FROM ams_act_geo_areas
    WHERE activity_geo_area_id = p_geo_area_id;

   CURSOR c_geo IS
   SELECT 1
     FROM ams_act_geo_areas
   WHERE act_geo_area_used_by_id = l_used_by_id
     AND arc_act_geo_area_used_by = l_used_by;

BEGIN
-- initialize
  SAVEPOINT delete_geo_area;

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name || ': start');

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
  )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

   OPEN c_used_by;
   FETCH c_used_by INTO l_used_by_id, l_used_by;
   CLOSE c_used_by;

-- delete
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': delete');
  END IF;

  DELETE FROM AMS_ACT_GEO_AREAS
  WHERE activity_geo_area_id = p_geo_area_id
  AND object_version_number = p_object_version;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

-- added by julou on 03/07/2000
   -- indicate if there is any other geo areas for this campaign
   OPEN c_geo;
   FETCH c_geo INTO l_dummy;
   CLOSE c_geo;

--commented OUT NOCOPY by soagrawa 24-May-2001
/*
   IF l_dummy IS NULL THEN
      AMS_ObjectAttribute_PVT.modify_object_attribute(
         p_api_version        => l_api_version,
         p_init_msg_list      => FND_API.g_false,
         p_commit             => FND_API.g_false,
         p_validation_level   => FND_API.g_valid_level_full,

         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,

         p_object_type        => l_used_by,
         p_object_id          => l_used_by_id,
         p_attr               => 'GEOS',
         p_attr_defined_flag  => 'N'
      );

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   */
-- end of added part

-- finish
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get
  (
    P_ENCODED => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
  );

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name || ': end');

  END IF;

  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_geo_area;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_geo_area;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO delete_geo_area;
      x_return_status :=FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

END delete_geo_area;


/*****************************************************************************/
-- Procedure: lock_geo_area
--
-- History
--   12/3/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE lock_geo_area
(
  p_api_version           IN      NUMBER,
  P_init_msg_list         IN      VARCHAR2 := FND_API.g_false,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_geo_area_id           IN      NUMBER,
  p_object_version        IN      NUMBER
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'lock_geo_area';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_geo_area_id   NUMBER;

  CURSOR c_geo_area IS
    SELECT activity_geo_area_id
    FROM AMS_ACT_GEO_AREAS
    WHERE activity_geo_area_id = p_geo_area_id
    AND object_version_number = p_object_version
    FOR UPDATE OF activity_geo_area_id NOWAIT;

BEGIN
-- initialize
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': start');
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
  )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

-- lock
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': lock');
  END IF;

  OPEN c_geo_area;
  FETCH c_geo_area INTO l_geo_area_id;
  IF (c_geo_area%NOTFOUND) THEN
    CLOSE c_geo_area;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_geo_area;

-- finish
  FND_MSG_PUB.count_and_get
  (
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
  );

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name || ': end');

  END IF;

  EXCEPTION

    WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      x_return_status :=FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

END lock_geo_area;


/*****************************************************************************/
-- PROCEDURE
--    validate_geo_area
--
-- HISTORY
--    12/19/1999    julou    Created.
--------------------------------------------------------------------
PROCEDURE validate_geo_area
(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_geo_area_rec      IN  geo_area_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_geo_area';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

--   IF FND_API.to_boolean(p_init_msg_list) THEN
--      FND_MSG_PUB.initialize;
--   END IF;

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
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message(l_full_name||': check items');
      END IF;
      check_items
      (
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status,
         p_geo_area_rec    => p_geo_area_rec
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
         FND_MSG_PUB.count_and_get
         (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN FND_API.g_exc_unexpected_error THEN
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
         (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN OTHERS THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

END validate_geo_area;

/*****************************************************************************/
-- Procedure: check_items
--
-- History
--   12/19/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode       IN      VARCHAR2,
    x_return_status         OUT NOCOPY     VARCHAR2,
    p_geo_area_rec          IN      geo_area_rec_type
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'check_items';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

BEGIN
-- initialize
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': start');
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

-- check required items
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': check required items');
  END IF;
  check_geo_area_req_items
  (
    p_validation_mode => p_validation_mode,
    p_geo_area_rec    => p_geo_area_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check unique key items
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': check uk items');
  END IF;
  check_geo_area_uk_items
  (
    p_validation_mode => p_validation_mode,
    p_geo_area_rec    => p_geo_area_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check foreign key items
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': check fk items');
  END IF;
  check_geo_area_fk_items
  (
    p_geo_area_rec  => p_geo_area_rec,
    x_return_status => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

END check_items;


/*****************************************************************************/
-- Procedure: check_geo_area_req_items
--
-- History
--   12/3/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE check_geo_area_req_items
(
  p_validation_mode   IN      VARCHAR2,
  p_geo_area_rec      IN      geo_area_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
)
IS

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check activity_geo_area_id
  IF p_geo_area_rec.activity_geo_area_id IS NULL
  AND p_validation_mode = JTF_PLSQL_API.g_update THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_GEO_NO_ACT_AREA_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check object_version_number
  IF p_geo_area_rec.object_version_number IS NULL
    AND p_validation_mode = JTF_PLSQL_API.g_update
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_NO_OBJ_VER_NUM');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check act_geo_area_used_by_id
  IF p_geo_area_rec.act_geo_area_used_by_id IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_GEO_NO_AREA_USED_BY_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check arc_act_geo_area_used_by
  IF p_geo_area_rec.arc_act_geo_area_used_by IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_GEO_NO_AREA_USED_BY');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- commented out by soagrawa on 29-Jun-2001
--  IF p_geo_area_rec.arc_act_geo_area_used_by NOT IN ('CAMP','ECAM','RCAM') THEN
--    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
--      FND_MESSAGE.set_name('AMS', 'AMS_GEO_BAD_AREA_USED_BY');
--      FND_MSG_PUB.add;
--    END IF;

--    x_return_status := FND_API.g_ret_sts_error;
--    RETURN;
--  END IF;

-- check geo_area_type_code
  IF p_geo_area_rec.geo_area_type_code IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_GEO_NO_AREA_TYPE_CODE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check geo_hierarchy_id
  IF p_geo_area_rec.geo_hierarchy_id IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_GEO_NO_HIERARCHY_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_geo_area_req_items;


/*****************************************************************************/
-- Procedure: check_geo_area_uk_items
--
-- History
--   12/3/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE check_geo_area_uk_items
(
  p_validation_mode   IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_geo_area_rec      IN      geo_area_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
)
IS

  l_uk_flag    VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check PK, if activity_geo_area_id is passed in, must check if it is duplicate
  IF p_validation_mode = JTF_PLSQL_API.g_create
    AND p_geo_area_rec.activity_geo_area_id IS NOT NULL
  THEN
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
         'AMS_ACT_GEO_AREAS',
         'activity_geo_area_id = ' || p_geo_area_rec.activity_geo_area_id
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)   THEN
      FND_MESSAGE.set_name('AMS', 'AMS_ACT_GEO_AREAS_DUP_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check used_by, used_by_id
  IF p_geo_area_rec.activity_geo_area_id IS NOT NULL THEN      -- UPDATE RECORD

    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
                   'AMS_ACT_GEO_AREAS',
                   'activity_geo_area_id <> ' || p_geo_area_rec.activity_geo_area_id
                   || ' AND geo_hierarchy_id = ' || p_geo_area_rec.geo_hierarchy_id
                   || ' AND act_geo_area_used_by_id = ' || p_geo_area_rec.act_geo_area_used_by_id
                   || ' AND arc_act_geo_area_used_by = ''' || p_geo_area_rec.arc_act_geo_area_used_by || ''''
                 );
  ELSE                                                       -- NEW RECORD
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
                   'AMS_ACT_GEO_AREAS',
                   'act_geo_area_used_by_id = ' || p_geo_area_rec.act_geo_area_used_by_id
                   || ' AND geo_hierarchy_id = ' || p_geo_area_rec.geo_hierarchy_id
                   || ' AND arc_act_geo_area_used_by = ''' || p_geo_area_rec.arc_act_geo_area_used_by || ''''
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_GEO_DUP_USED_BY_AND_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_geo_area_uk_items;


/*****************************************************************************/
-- Procedure: check_geo_area_fk_items
--
-- History
--   12/3/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE check_geo_area_fk_items
(
  p_geo_area_rec        IN      geo_area_rec_type,
  x_return_status       OUT NOCOPY     VARCHAR2
)
IS

  l_fk_flag                     VARCHAR2(1);
  l_table_name                  VARCHAR2(30);
  l_pk_name                     VARCHAR2(30);
  l_pk_value                    VARCHAR2(30);
  l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.
  l_pk_data_type                VARCHAR2(30);
BEGIN

  x_return_status := FND_API.g_ret_sts_success;



-- check act_geo_area_used_by_id

--modified by soagrawa on 29-Jun-2001
/*****
   l_fk_flag := AMS_Utility_PVT.check_fk_exists
               (
                 'AMS_CAMPAIGNS_VL',
                 'campaign_id',
                 p_geo_area_rec.act_geo_area_used_by_id
               );
***************/

/*********************** CODE COMMENTED BY ABHOLA **********************************
--  22 - APR - 02
--

     AMS_Utility_PVT.Get_Qual_Table_Name_And_PK (
         p_sys_qual                     => p_geo_area_rec.arc_act_geo_area_used_by,
         x_return_status                => x_return_status,
         x_table_name                   => l_table_name,
         x_pk_name                      => l_pk_name
      );

      l_pk_value                 := p_geo_area_rec.act_geo_area_used_by_id;
      l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
      l_additional_where_clause  := NULL;

      l_fk_flag := AMS_Utility_PVT.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => l_additional_where_clause
         );

  -- end soagrawa

  IF l_fk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_GEO_BAD_AREA_USED_BY_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;


************************************************************************************/

-- check geo_area_type_code
  l_fk_flag := AMS_Utility_PVT.check_fk_exists
               (
                 'JTF_LOC_TYPES_VL',
                 'location_type_code',
                 p_geo_area_rec.geo_area_type_code,
                 2                             --varchar2 types
               );

  IF l_fk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_GEO_BAD_AREA_TYPE_CODE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check geo_hierarchy_id
  l_fk_flag := AMS_Utility_PVT.check_fk_exists
               (
                 'JTF_LOC_HIERARCHIES_B',
                 'location_hierarchy_id',
                 p_geo_area_rec.geo_hierarchy_id
               );

  IF l_fk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_GEO_BAD_AREA_HIERARCHY_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_geo_area_fk_items;


/*****************************************************************************/
-- Procedure: complete_geo_area_rec
--
-- History
--   12/3/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE complete_geo_area_rec
(
  p_geo_area_rec    IN      geo_area_rec_type,
  x_complete_rec    OUT NOCOPY     geo_area_rec_type
)
IS

  CURSOR c_geo_area IS
    SELECT * FROM AMS_ACT_GEO_AREAS
    WHERE activity_geo_area_id = p_geo_area_rec.activity_geo_area_id;

  l_geo_area_rec     c_geo_area%ROWTYPE;

BEGIN

  x_complete_rec := p_geo_area_rec;

  OPEN c_geo_area;
  FETCH c_geo_area INTO l_geo_area_rec;
  IF (c_geo_area%NOTFOUND) THEN
    CLOSE c_geo_area;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_geo_area;


  IF p_geo_area_rec.act_geo_area_used_by_id = FND_API.g_miss_num THEN
    x_complete_rec.act_geo_area_used_by_id := l_geo_area_rec.act_geo_area_used_by_id;
  END IF;

  IF p_geo_area_rec.arc_act_geo_area_used_by = FND_API.g_miss_char THEN
    x_complete_rec.arc_act_geo_area_used_by := l_geo_area_rec.arc_act_geo_area_used_by;
  END IF;

  IF p_geo_area_rec.geo_area_type_code = FND_API.g_miss_char THEN
    x_complete_rec.geo_area_type_code := l_geo_area_rec.geo_area_type_code;
  END IF;

  IF p_geo_area_rec.geo_hierarchy_id = FND_API.g_miss_num THEN
    x_complete_rec.geo_hierarchy_id := l_geo_area_rec.geo_hierarchy_id;
  END IF;


  IF p_geo_area_rec.attribute_category = FND_API.g_miss_char THEN
    x_complete_rec.attribute_category := l_geo_area_rec.attribute_category;
  END IF;

  IF p_geo_area_rec.attribute1 = FND_API.g_miss_char THEN
    x_complete_rec.attribute1 := l_geo_area_rec.attribute1;
  END IF;

  IF p_geo_area_rec.attribute2 = FND_API.g_miss_char THEN
    x_complete_rec.attribute2 := l_geo_area_rec.attribute2;
  END IF;

  IF p_geo_area_rec.attribute3 = FND_API.g_miss_char THEN
    x_complete_rec.attribute3 := l_geo_area_rec.attribute3;
  END IF;

  IF p_geo_area_rec.attribute4 = FND_API.g_miss_char THEN
    x_complete_rec.attribute4 := l_geo_area_rec.attribute4;
  END IF;

  IF p_geo_area_rec.attribute5 = FND_API.g_miss_char THEN
    x_complete_rec.attribute5 := l_geo_area_rec.attribute5;
  END IF;

  IF p_geo_area_rec.attribute6 = FND_API.g_miss_char THEN
    x_complete_rec.attribute6 := l_geo_area_rec.attribute6;
  END IF;

  IF p_geo_area_rec.attribute7 = FND_API.g_miss_char THEN
    x_complete_rec.attribute7 := l_geo_area_rec.attribute7;
  END IF;

  IF p_geo_area_rec.attribute8 = FND_API.g_miss_char THEN
    x_complete_rec.attribute8 := l_geo_area_rec.attribute8;
  END IF;

  IF p_geo_area_rec.attribute9 = FND_API.g_miss_char THEN
    x_complete_rec.attribute9 := l_geo_area_rec.attribute9;
  END IF;

  IF p_geo_area_rec.attribute10 = FND_API.g_miss_char THEN
    x_complete_rec.attribute10 := l_geo_area_rec.attribute10;
  END IF;

  IF p_geo_area_rec.attribute11 = FND_API.g_miss_char THEN
    x_complete_rec.attribute11 := l_geo_area_rec.attribute11;
  END IF;

  IF p_geo_area_rec.attribute12 = FND_API.g_miss_char THEN
    x_complete_rec.attribute12 := l_geo_area_rec.attribute12;
  END IF;

  IF p_geo_area_rec.attribute13 = FND_API.g_miss_char THEN
    x_complete_rec.attribute13 := l_geo_area_rec.attribute13;
  END IF;

  IF p_geo_area_rec.attribute14 = FND_API.g_miss_char THEN
    x_complete_rec.attribute14 := l_geo_area_rec.attribute14;
  END IF;

  IF p_geo_area_rec.attribute15 = FND_API.g_miss_char THEN
    x_complete_rec.attribute15 := l_geo_area_rec.attribute15;
  END IF;

END complete_geo_area_rec;


/****************************************************************************/
-- Procedure
--   init_rec
--
-- HISTORY
--    12/19/1999    julou    Created.
------------------------------------------------------------------------------
PROCEDURE init_rec
(
  x_geo_area_rec  OUT NOCOPY  geo_area_rec_type
)
IS

BEGIN

  x_geo_area_rec.activity_geo_area_id := FND_API.g_miss_num;
  x_geo_area_rec.last_update_date := FND_API.g_miss_date;
  x_geo_area_rec.last_updated_by := FND_API.g_miss_num;
  x_geo_area_rec.creation_date := FND_API.g_miss_date;
  x_geo_area_rec.created_by := FND_API.g_miss_num;
  x_geo_area_rec.last_update_login := FND_API.g_miss_num;
  x_geo_area_rec.object_version_number := FND_API.g_miss_num;
  x_geo_area_rec.act_geo_area_used_by_id := FND_API.g_miss_num;
  x_geo_area_rec.arc_act_geo_area_used_by := FND_API.g_miss_char;
  x_geo_area_rec.attribute_category := FND_API.g_miss_char;
  x_geo_area_rec.attribute1 := FND_API.g_miss_char;
  x_geo_area_rec.attribute2 := FND_API.g_miss_char;
  x_geo_area_rec.attribute3 := FND_API.g_miss_char;
  x_geo_area_rec.attribute4 := FND_API.g_miss_char;
  x_geo_area_rec.attribute5 := FND_API.g_miss_char;
  x_geo_area_rec.attribute6 := FND_API.g_miss_char;
  x_geo_area_rec.attribute7 := FND_API.g_miss_char;
  x_geo_area_rec.attribute8 := FND_API.g_miss_char;
  x_geo_area_rec.attribute9 := FND_API.g_miss_char;
  x_geo_area_rec.attribute10 := FND_API.g_miss_char;
  x_geo_area_rec.attribute11 := FND_API.g_miss_char;
  x_geo_area_rec.attribute12 := FND_API.g_miss_char;
  x_geo_area_rec.attribute13 := FND_API.g_miss_char;
  x_geo_area_rec.attribute14 := FND_API.g_miss_char;
  x_geo_area_rec.attribute15 := FND_API.g_miss_char;
  x_geo_area_rec.geo_area_type_code := FND_API.g_miss_char;
  x_geo_area_rec.geo_hierarchy_id := FND_API.g_miss_num;

END init_rec;

END AMS_Geo_Areas_PVT;

/
