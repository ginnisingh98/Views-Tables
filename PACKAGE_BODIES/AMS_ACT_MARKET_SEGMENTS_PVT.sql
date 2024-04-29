--------------------------------------------------------
--  DDL for Package Body AMS_ACT_MARKET_SEGMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACT_MARKET_SEGMENTS_PVT" AS
/* $Header: amsvmksb.pls 120.1 2005/06/16 06:13:16 appldev  $ */

g_pkg_name      CONSTANT VARCHAR2(30) := 'AMS_Act_Market_Segments_PVT';

/*****************************************************************************/
-- Procedure: create_market_segments
--
-- History
--   10/28/1999      julou      created
--   14/02/2000      ptendulk   Modified
-------------------------------------------------------------------------------
PROCEDURE create_market_segments
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_mks_rec               IN      mks_rec_type,
  x_act_mks_id            OUT NOCOPY     NUMBER
)
IS

  l_api_version     CONSTANT NUMBER := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'create_market_segments';
  l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status VARCHAR2(1);
  l_mks_rec       mks_rec_type := p_mks_rec;
  l_mks_count     NUMBER;

  CURSOR c_mks_seq IS
    SELECT AMS_ACT_MARKET_SEGMENTS_S.NEXTVAL
    FROM DUAL;

  CURSOR c_mks_count(mks_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM AMS_ACT_MARKET_SEGMENTS
    WHERE activity_market_segment_id = mks_id;

BEGIN
-- initialize
  SAVEPOINT create_market_segments;

  AMS_Utility_PVT.debug_message(l_full_name || ': start');

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

-- validate
--  Following code is Modified by ptendulk as the Validation level Check
--  is done in Validate API

--  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    AMS_Utility_PVT.debug_message(l_full_name || ': validate');

    validate_market_segments
    (
      p_api_version      => l_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_mks_rec          => l_mks_rec
    );



   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
--   END IF;

-- insert
  AMS_Utility_PVT.debug_message(l_full_name || ': insert');

  IF l_mks_rec.activity_market_segment_id IS NULL THEN
    LOOP
      OPEN c_mks_seq;
      FETCH c_mks_seq INTO l_mks_rec.activity_market_segment_id;
      CLOSE c_mks_seq;

      OPEN c_mks_count(l_mks_rec.activity_market_segment_id);
      FETCH c_mks_count INTO l_mks_count;
      CLOSE c_mks_count;

      EXIT WHEN l_mks_count = 0;
    END LOOP;
  END IF;

  INSERT INTO AMS_ACT_MARKET_SEGMENTS
  (
    activity_market_segment_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    market_segment_id,
    act_market_segment_used_by_id,
    arc_act_market_segment_used_by,
    segment_type,
    last_update_login,
    object_version_number,
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
    group_code,
    exclude_flag
  )
  VALUES
  (
    l_mks_rec.activity_market_segment_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    l_mks_rec.market_segment_id,
    l_mks_rec.act_market_segment_used_by_id,
    l_mks_rec.arc_act_market_segment_used_by,
    l_mks_rec.segment_type,
    FND_GLOBAL.conc_login_id,
    1,
    l_mks_rec.attribute_category,
    l_mks_rec.attribute1,
    l_mks_rec.attribute2,
    l_mks_rec.attribute3,
    l_mks_rec.attribute4,
    l_mks_rec.attribute5,
    l_mks_rec.attribute6,
    l_mks_rec.attribute7,
    l_mks_rec.attribute8,
    l_mks_rec.attribute9,
    l_mks_rec.attribute10,
    l_mks_rec.attribute11,
    l_mks_rec.attribute12,
    l_mks_rec.attribute13,
    l_mks_rec.attribute14,
    l_mks_rec.attribute15,
    l_mks_rec.group_code,
    l_mks_rec.exclude_flag
  );

/*-- Following code has been added by ptendulk on 14Feb2000
  -- It will update the attribute in ams_object_attribites
  -- as soon as segment is created for an activity

   -- indicate schedule has been defined for the campaign
   AMS_ObjectAttribute_PVT.modify_object_attribute(
      p_api_version        => l_api_version,
      p_init_msg_list      => FND_API.g_false,
      p_commit             => FND_API.g_false,
      p_validation_level   => FND_API.g_valid_level_full,

      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,

      p_object_type        => l_mks_rec.arc_act_market_segment_used_by,
      p_object_id          => l_mks_rec.act_market_segment_used_by_id,
      p_attr               => 'CELL',
      p_attr_defined_flag  => 'Y'
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF; */

-- finish
  x_act_mks_id := l_mks_rec.activity_market_segment_id;

  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get
  (
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
  );

  AMS_Utility_PVT.debug_message(l_full_name || ': end');

  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_market_segments;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_market_segments;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO create_market_segments;
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

END create_market_segments;


/*****************************************************************************/
-- Procedure: update_market_segments
--
-- History
--   10/28/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE update_market_segments
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,
  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_mks_rec               IN      mks_rec_type
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'update_market_segments';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status VARCHAR2(1);
  l_mks_rec       mks_rec_type := p_mks_rec;

BEGIN

-- initialize
  SAVEPOINT update_market_segments;

  AMS_Utility_PVT.debug_message(l_full_name || ': start');

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

-- validate
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    AMS_Utility_PVT.debug_message(l_full_name || ': validate');

      check_mks_items(
         p_mks_rec         => p_mks_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   complete_mks_rec  (
                p_mks_rec,
                l_mks_rec
                  );
    /* Start Of Code added by ptendulk */


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Validate_cross_ent_Rec(
         p_mks_rec         => p_mks_rec,
         p_complete_rec    => l_mks_rec,
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
      check_mks_record(
         p_mks_rec        => p_mks_rec,
         p_complete_rec   => l_mks_rec,
         x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

    /* End Of Code added by ptendulk */


-- update
  AMS_Utility_PVT.debug_message(l_full_name||': update');

  UPDATE AMS_ACT_MARKET_SEGMENTS SET
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    market_segment_id = l_mks_rec.market_segment_id,
    act_market_segment_used_by_id = l_mks_rec.act_market_segment_used_by_id,
    arc_act_market_segment_used_by = l_mks_rec.arc_act_market_segment_used_by,
    segment_type = l_mks_rec.segment_type,
    last_update_login = FND_GLOBAL.conc_login_id,
    object_version_number = l_mks_rec.object_version_number + 1,
    attribute_category = l_mks_rec.attribute_category,
    attribute1 = l_mks_rec.attribute1,
    attribute2 = l_mks_rec.attribute2,
    attribute3 = l_mks_rec.attribute3,
    attribute4 = l_mks_rec.attribute4,
    attribute5 = l_mks_rec.attribute5,
    attribute6 = l_mks_rec.attribute6,
    attribute7 = l_mks_rec.attribute7,
    attribute8 = l_mks_rec.attribute8,
    attribute9 = l_mks_rec.attribute9,
    attribute10 = l_mks_rec.attribute10,
    attribute11 = l_mks_rec.attribute11,
    attribute12 = l_mks_rec.attribute12,
    attribute13 = l_mks_rec.attribute13,
    attribute14 = l_mks_rec.attribute14,
    attribute15 = l_mks_rec.attribute15,
    group_code = l_mks_rec.group_code,
    exclude_flag        = l_mks_rec.exclude_flag
  WHERE activity_market_segment_id = l_mks_rec.activity_market_segment_id
  AND object_version_number = l_mks_rec.object_version_number;

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

  AMS_Utility_PVT.debug_message(l_full_name || ': end');

  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_market_segments;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_market_segments;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO update_market_segments;
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

END update_market_segments;


/*****************************************************************************/
-- Procedure: delete_market_segments
--
-- History
--   10/28/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE delete_market_segments
(
  p_api_version      IN      NUMBER,
  p_init_msg_list    IN      VARCHAR2 := FND_API.g_false,
  p_commit           IN      VARCHAR2 := FND_API.g_false,

  x_return_status    OUT NOCOPY     VARCHAR2,
  x_msg_count        OUT NOCOPY     NUMBER,
  x_msg_data         OUT NOCOPY     VARCHAR2,

  p_act_mks_id       IN      NUMBER,
  p_object_version   IN      NUMBER
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_market_segments';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   CURSOR c_arc_det IS
   SELECT act_market_segment_used_by_id ,
          arc_act_market_segment_used_by
     FROM ams_act_market_segments
    WHERE activity_market_segment_id = p_act_mks_id;

   l_act_id  NUMBER;
   l_arc_act VARCHAR2(30);
   l_dummy   NUMBER;
   CURSOR c_mks IS
   SELECT 1
     FROM ams_act_market_segments
    WHERE act_market_segment_used_by_id = l_act_id
      AND arc_act_market_segment_used_by = l_arc_act ;

BEGIN
-- initialize
  SAVEPOINT delete_market_segments;

  AMS_Utility_PVT.debug_message(l_full_name || ': start');

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

-- delete
  AMS_Utility_PVT.debug_message(l_full_name || ': delete');

  --  Following code is added by ptendulk on 14th Feb 2000
  --  to update Attribute after deletion
   -- indicate if there is any other schedule for this campaign
   OPEN c_arc_det;
   FETCH c_arc_det INTO l_act_id,l_arc_act;
   CLOSE c_arc_det;


  DELETE FROM AMS_ACT_MARKET_SEGMENTS
  WHERE activity_market_segment_id = p_act_mks_id
  AND object_version_number = p_object_version;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

/*  --  Following code is added by ptendulk on 14th Feb 2000
  --  to update Attribute after deletion
   -- indicate if there is any other schedule for this campaign

   OPEN c_mks;
   FETCH c_mks INTO l_dummy;
   CLOSE c_mks;


   IF l_dummy IS NULL THEN
      AMS_ObjectAttribute_PVT.modify_object_attribute(
         p_api_version        => l_api_version,
         p_init_msg_list      => FND_API.g_false,
         p_commit             => FND_API.g_false,
         p_validation_level   => FND_API.g_valid_level_full,

         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,

         p_object_type        => l_arc_act,
         p_object_id          => l_act_id,
         p_attr               => 'CELL',
         p_attr_defined_flag  => 'N'
      );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;  */


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

  AMS_Utility_PVT.debug_message(l_full_name || ': end');

  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_market_segments;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_market_segments;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO delete_market_segments;
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

END delete_market_segments;


/*****************************************************************************/
-- Procedure: lock_market_segments
--
-- History
--   10/28/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE lock_market_segments
(
  p_api_version      IN      NUMBER,
  p_init_msg_list    IN      VARCHAR2 := FND_API.g_false,

  x_return_status    OUT NOCOPY     VARCHAR2,
  x_msg_count        OUT NOCOPY     NUMBER,
  x_msg_data         OUT NOCOPY     VARCHAR2,

  p_act_mks_id       IN      NUMBER,
  p_object_version   IN      NUMBER
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_market_segments';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_mks_id        NUMBER;

  CURSOR c_obj IS
    SELECT activity_market_segment_id
    FROM AMS_ACT_MARKET_SEGMENTS
    WHERE activity_market_segment_id = p_act_mks_id
    AND object_version_number = p_object_version
    FOR UPDATE NOWAIT;

BEGIN
-- initialize
  AMS_Utility_PVT.debug_message(l_full_name || ': start');

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
  AMS_Utility_PVT.debug_message(l_full_name || ': lock');

  OPEN c_obj;
  FETCH c_obj INTO l_mks_id;
  IF (c_obj%NOTFOUND) THEN
    CLOSE c_obj;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_obj;

-- finish
  FND_MSG_PUB.count_and_get
  (
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
  );

  AMS_Utility_PVT.debug_message(l_full_name || ': end');

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

END LOCK_MARKET_SEGMENTS;


/*****************************************************************************/
-- Procedure: validate_market_segments
--
-- History
--   10/28/1999      julou      created
--   12/16/1999      ptendulk   Modified as we have to chack the validation level
--                              before validting also added Cross Entity Validation
-------------------------------------------------------------------------------
PROCEDURE validate_market_segments
(
    p_api_version           IN      NUMBER,
    P_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
    p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2,

    p_mks_rec               IN      mks_rec_type
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_market_segments';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

  l_return_status   VARCHAR2(1);

BEGIN
-- initialize
  AMS_Utility_PVT.debug_message(l_full_name || ': start');

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

  ---------------------- validate Segment Items ------------------------
  AMS_Utility_PVT.debug_message(l_full_name || ': check required items');

  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    Check_Mks_items(
       p_mks_rec         => p_mks_rec,
       p_validation_mode => JTF_PLSQL_API.g_create,
       x_return_status   => l_return_status
      ) ;

        IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
        ELSIF l_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
        END IF;
  END IF;


   ---------------------- validate Segment Cross Entity Records ------------------------
   --
   -- Debug Message
   --
   AMS_Utility_PVT.debug_message(l_full_name||': check cross Entity');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN

     Validate_cross_ent_Rec(
         p_mks_rec         => p_mks_rec,
         p_complete_rec    => NULL,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   ---------------------- validate Segment Records ------------------------
   --
   -- Debug Message
   --

   AMS_Utility_PVT.debug_message(l_full_name||': check record');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Mks_Record(
         p_mks_rec       => p_mks_rec,
         p_complete_rec   => NULL,
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

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

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

END validate_market_segments;




/*****************************************************************************/
-- Procedure: check_mks_req_items
--
-- History
--   10/28/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE check_mks_req_items
( p_mks_rec           IN      mks_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
)
IS

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

/* Start of code commented by ptendulk */
-- check activity_market_segment_id
--  IF p_mks_rec.activity_market_segment_id IS NULL
--    AND p_validation_mode = JTF_PLSQL_API.g_update
--  THEN
--    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
--      FND_MESSAGE.set_name('AMS', 'AMS_MKS_NO_ACT_MKS_ID');
--      FND_MSG_PUB.add;
--    END IF;
--
--    x_return_status := FND_API.g_ret_sts_error;
--    RETURN;
--  END IF;


-- check object_version_number
--  IF p_mks_rec.object_version_number IS NULL
--    AND p_validation_mode = JTF_PLSQL_API.g_update
--  THEN
--    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
--      FND_MESSAGE.set_name('AMS', 'AMS_MKS_NO_OBJ_VER_NUM');
--      FND_MSG_PUB.add;
--    END IF;
--
--    x_return_status := FND_API.g_ret_sts_error;
--    RETURN;
--  END IF;
/* Start of code commented by ptendulk */

-- check market_segment_id
/* comment by julou 29-MAY-2001
  IF p_mks_rec.market_segment_id IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MKS_NO_MKS_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;
*/
-- check act_market_segment_used_by_id
  IF p_mks_rec.act_market_segment_used_by_id IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MKS_NO_ACT_MKS_USED_BY_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check arc_act_market_segment_used_by
  IF p_mks_rec.arc_act_market_segment_used_by IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MKS_NO_ARC_ACT_MKS_USED_BY');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- Following Code is added by ptendulk on 16th Dec as segment type is not null
-- check segment_type
-- Commented by skarumur as there is no segment type any more

/*  IF p_mks_rec.segment_type IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MKS_MISSING_MKS_TYPE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF; */

END check_mks_req_items;


/*****************************************************************************/
-- Procedure: check_mks_fk_items
--
-- History
--   10/28/1999      julou      created
--   06/14/2000      ptendulk   Added Offer as used by activity
-------------------------------------------------------------------------------
PROCEDURE check_mks_fk_items
(
  p_mks_rec             IN      mks_rec_type,
  x_return_status       OUT NOCOPY     VARCHAR2
)
IS

  l_fk_flag       VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;
/*
  IF UPPER(p_mks_rec.arc_act_market_segment_used_by)
    NOT IN ('CAMP', 'EVEH', 'EVEO', 'CELL') THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MKS_BAD_ARC_ACT_MKS_USEDBY');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;
*/

/* Start of Comments by ptendulk on 16-dec-1999 */
-- Following code is modified by ptendulk as
-- we need to account for G_MISS_NUM /CHAR for arc_act_market_segment_used_by
-- Checking of act_market_segment_used_by_id will be done is Validate record
--
--  IF UPPER(p_mks_rec.arc_act_market_segment_used_by) = 'CAMP' THEN
--    l_fk_flag := AMS_Utility_PVT.check_fk_exists
--                 (
--                   'AMS_CAMPAIGNS_VL',
--                   'campaign_id',
--                   p_mks_rec.act_market_segment_used_by_id
--                 );
--  ELSIF UPPER(p_mks_rec.arc_act_market_segment_used_by) = 'EVEH' THEN
--    l_fk_flag := AMS_Utility_PVT.check_fk_exists
--                 (
--                   'AMS_EVENT_HEADERS_VL',
--                   'event_header_id',
--                   p_mks_rec.act_market_segment_used_by_id
--                 );
-- ELSIF UPPER(p_mks_rec.arc_act_market_segment_used_by) = 'EVEO' THEN
--    l_fk_flag := AMS_Utility_PVT.check_fk_exists
--                 (
--                   'AMS_EVENT_OFFERS_VL',
--                   'event_offer_id',
--                   p_mks_rec.act_market_segment_used_by_id
--                );
--  ELSE
--    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
--      FND_MESSAGE.set_name('AMS', 'AMS_MKS_BAD_ARC_ACT_MKS_USEDBY');
--      FND_MSG_PUB.add;
--    END IF;
/* End of Comments by ptendulk on 16-dec-1999 */

--=============================================================================
-- Following code is modified by ptendulk on 14th Jun 2000
--  Add offer code as segments will be used by offers also.
--=============================================================================
    -- Check arc_act_market_segment_used_by

--=============================================================================
-- Following code is modified by ptendulk on 23th Aug 2000
--  The validation is commented as there are lot of activities going to use
--  Market Segment, it is easier to control the validation modifying
--  Get_Qual_Table_Name_And_PK than changing this package every time the
--  new activity start creating it.
--=============================================================================

--   IF p_mks_rec.arc_act_market_segment_used_by <> FND_API.G_MISS_CHAR   THEN
--   	  IF p_mks_rec.arc_act_market_segment_used_by <> 'CAMP' AND
--  	  	 p_mks_rec.arc_act_market_segment_used_by <> 'EVEH' AND
--  	  	 p_mks_rec.arc_act_market_segment_used_by <> 'EVEO' AND
--                 p_mks_rec.arc_act_market_segment_used_by <> 'OFFR'
--   	  THEN
--      -- invalid item
--         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
--         THEN -- MMSG
---- 		 	  DBMS_OUTPUT.Put_Line('Foreign Key Does not Exist');
--		 	  FND_MESSAGE.Set_Name('AMS', 'AMS_MKS_BAD_ARC_ACT_MKS_USEDBY');
--       	 	  FND_MSG_PUB.Add;
--	     END IF;
--         x_return_status := FND_API.G_RET_STS_ERROR;
--	     -- If any errors happen abort API/Procedure.
--	     RETURN;
--      END IF;
--   END IF;

END check_mks_fk_items;


-- Start of Comments
--
-- NAME
--   Validate_Mks_UK_Items
--
-- PURPOSE
--   This procedure is to validate ams_act_market_segments
--   for Unique ness
-- NOTES
--
--
-- HISTORY
--   12/16/1999        ptendulk            created
-- End of Comments

PROCEDURE Check_Mks_Uk_Items(
   p_mks_rec         IN  mks_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  	 VARCHAR2(1);
   l_where_clause	 VARCHAR2(2000);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_market Segments, when ACTIVITY_MARKET_SEGMENT_ID is passed in, we need to
   -- check if this ACTIVITY_MARKET_SEGMENT_ID is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_mks_rec.activity_market_segment_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
		      'ams_act_market_segments',
				'activity_market_segment_id = ' || p_mks_rec.activity_market_segment_id
			) = FND_API.g_false
		THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
			THEN
            FND_MESSAGE.set_name('AMS', 'AMS_MKS_DUP_ACt_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Mks_Uk_Items;

/*****************************************************************************/
-- Procedure: check_mks_lookup_items
--
-- History
--   10/28/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE check_mks_lookup_items
(
  p_mks_rec             IN      mks_rec_type,
  x_return_status       OUT NOCOPY     VARCHAR2
)
IS

  l_lookup_flag   VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;
/* removed by julou. there is no segment type any more
  IF p_mks_rec.segment_type IS NOT NULL
  AND p_mks_rec.segment_type <> FND_API.g_miss_char THEN
    l_lookup_flag := AMS_Utility_PVT.check_lookup_exists
                     (
                       p_lookup_type => 'AMS_MKT_SEGMENT_TYPE',
                       p_lookup_code => p_mks_rec.segment_type
                     );
  END IF;

  IF l_lookup_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MKS_BAD_SEGMENT_TYPE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;
*/
  /*IF p_mks_rec.exclude_flag IS NOT NULL
  AND p_mks_rec.exclude_flag <> FND_API.g_miss_char THEN
    l_lookup_flag := AMS_Utility_PVT.check_lookup_exists
                     (
                       p_lookup_type => 'AMS_SEGMENT_CONDITIONS',
                       p_lookup_code => p_mks_rec.exclude_flag
                     );
  END IF;

  IF l_lookup_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MKS_BAD_CONDITION_TYPE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;
*/
END check_mks_lookup_items;

-- Start of Comments
--
-- NAME
--   Check_Mks_Items
--
-- PURPOSE
--   This procedure is to validate ams_act_market_segtments
-- NOTES
--
-- HISTORY
--   12/16/1999        ptendulk            created
-- End of Comments

PROCEDURE check_Mks_items(
   p_mks_rec         IN  mks_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   check_mks_req_items(
      p_mks_rec       => p_mks_rec,
      x_return_status  => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   Check_Mks_Uk_Items(
      p_mks_rec         => p_mks_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Mks_Fk_Items(
      p_mks_rec       => p_mks_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Mks_Lookup_Items(
      p_mks_rec        => p_mks_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Mks_Items;

-- Start of Comments
--
-- NAME
--   Validate_cross_ent_Rec
--
-- PURPOSE
--   This procedure is to validate Unique Marketsegment across
--   Activities
-- NOTES
--
--
-- HISTORY
--   12/16/1999        ptendulk            created
-- End of Comments
PROCEDURE Validate_cross_ent_Rec(
   p_mks_rec         IN  mks_rec_type,
   p_complete_rec    IN  mks_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
l_mks_used_by_id    NUMBER ;
l_mks_used_by       VARCHAR2(30) ;
l_mks_id            NUMBER ;
l_where_clause      VARCHAR2(2000);
BEGIN
   x_return_status := FND_API.g_ret_sts_success;


IF p_mks_rec.arc_act_market_segment_used_by <> FND_API.G_MISS_CHAR
	OR p_mks_rec.act_market_segment_used_by_id <> FND_API.G_MISS_NUM
    OR p_mks_rec.market_segment_id <> FND_API.G_MISS_NUM
THEN
      IF p_mks_rec.act_market_segment_used_by_id = FND_API.G_MISS_NUM THEN
	  	 l_mks_used_by_id  := p_complete_rec.act_market_segment_used_by_id ;
	  ELSE
	  	 l_mks_used_by_id  := p_mks_rec.act_market_segment_used_by_id ;
	  END IF;

	  IF p_mks_rec.arc_act_market_segment_used_by = FND_API.G_MISS_CHAR THEN
	  	 l_mks_used_by := p_complete_rec.arc_act_market_segment_used_by ;
	  ELSE
	  	 l_mks_used_by := p_mks_rec.arc_act_market_segment_used_by ;
	  END IF;

      IF p_mks_rec.market_segment_id = FND_API.G_MISS_NUM THEN
	  	 l_mks_id  := p_complete_rec.market_segment_id ;
	  ELSE
	  	 l_mks_id  := p_mks_rec.market_segment_id ;
	  END IF;

      -- Check if Trigger_name is unique. Need to handle create and
      -- update differently.

      -- Unique TRIGGER_NAME and TRIGGER_CREATED_FOR
      l_where_clause := ' market_segment_id  = '|| l_mks_id||
                     ' and act_market_segment_used_by_id = '||l_mks_used_by_id ||
                     ' and arc_act_market_segment_used_by = '||''''||l_mks_used_by||'''' ;


      -- For Updates, must also check that uniqueness is not checked against the same record.
      IF p_validation_mode <> JTF_PLSQL_API.g_create THEN
          l_where_clause := l_where_clause || ' AND activity_market_segment_id <> ' || p_mks_rec.activity_market_segment_id;
      END IF;

      IF AMS_Utility_PVT.Check_Uniqueness(
      	 	p_table_name      => 'ams_act_market_segments',
    		p_where_clause    => l_where_clause
    		) = FND_API.g_false
      THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
    	   THEN
               FND_MESSAGE.set_name('AMS', 'AMS_MKS_DUP_SEGMENT');
               FND_MSG_PUB.add;
           END IF;
           x_return_status := FND_API.g_ret_sts_error;
           RETURN;
      END IF;
END IF;
END  Validate_cross_ent_Rec ;

-- Start of Comments
--
-- NAME
--   Validate_Mks_Record
--
-- PURPOSE
--   This procedure is to validate ams_act_market_segments table
-- NOTES
--
--
-- HISTORY
--   12/16/1999        ptendulk            created
-- End of Comments
PROCEDURE Check_Mks_Record(
   p_mks_rec        IN  mks_rec_type,
   p_complete_rec   IN  mks_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_mkt_seg_id(l_id NUMBER) IS
  SELECT COUNT(1)
    FROM qp_qualifiers
   WHERE qualifier_id = l_id;

l_mks_used_by_id    NUMBER       ;
l_mks_used_by       VARCHAR2(30) ;
l_market_segment_id NUMBER       ;
l_segment_type      VARCHAR2(30) ;
l_seg_flag          VARCHAR2(1)  ;

l_table_name                  VARCHAR2(30);
l_pk_name                     VARCHAR2(30);
l_pk_value                    VARCHAR2(30);
l_pk_data_type                VARCHAR2(30);
l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.
l_dummy             NUMBER;

BEGIN
   --
   -- Initialize the Out Variable
   --
   x_return_status := FND_API.g_ret_sts_success;

-- ELSIF UPPER(p_mks_rec.arc_act_market_segment_used_by) = 'EVEO' THEN
--    l_fk_flag := AMS_Utility_PVT.check_fk_exists
--                 (
--                   'AMS_EVENT_OFFERS_VL',
--                   'event_offer_id',
--                   p_mks_rec.act_market_segment_used_by_id
--                );

	IF p_mks_rec.arc_act_market_segment_used_by <> FND_API.G_MISS_CHAR
	OR p_mks_rec.act_market_segment_used_by_id <> FND_API.G_MISS_NUM THEN

	  IF p_mks_rec.act_market_segment_used_by_id = FND_API.G_MISS_NUM THEN
	  	 l_mks_used_by_id  := p_complete_rec.act_market_segment_used_by_id ;
	  ELSE
	  	 l_mks_used_by_id  := p_mks_rec.act_market_segment_used_by_id ;
	  END IF;

	  IF p_mks_rec.arc_act_market_segment_used_by = FND_API.G_MISS_CHAR THEN
	  	 l_mks_used_by := p_complete_rec.arc_act_market_segment_used_by ;
	  ELSE
	  	 l_mks_used_by := p_mks_rec.arc_act_market_segment_used_by ;
	  END IF;


	  -- Get table_name and pk_name for the ARC qualifier.
      AMS_Utility_PVT.Get_Qual_Table_Name_And_PK (
         p_sys_qual                     => l_mks_used_by,
         x_return_status                => x_return_status,
         x_table_name                   => l_table_name,
         x_pk_name                      => l_pk_name
      );

      l_pk_value                 := l_mks_used_by_id;
      l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
      l_additional_where_clause  := NULL;


      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_MKS_INVALID_USED_BY');
            FND_MSG_PUB.Add;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
      END IF;
   END IF;

-- Check MARKET_SEGMENT_ID

  IF p_mks_rec.segment_type <> FND_API.G_MISS_CHAR
   OR p_mks_rec.market_segment_id <> FND_API.G_MISS_NUM THEN

	  IF p_mks_rec.market_segment_id = FND_API.G_MISS_NUM THEN
	  	 l_market_segment_id  := p_complete_rec.market_segment_id ;
	  ELSE
	  	 l_market_segment_id  := p_mks_rec.market_segment_id ;
	  END IF;

	  IF p_mks_rec.segment_type = FND_API.G_MISS_CHAR THEN
	  	 l_segment_type := p_complete_rec.segment_type ;
	  ELSE
	  	 l_segment_type := p_mks_rec.segment_type ;
	  END IF;

    IF    l_segment_type = 'MARKET_SEGMENT' THEN
         l_seg_flag := 'Y' ;
    ELSIF l_segment_type = 'CELL' THEN
         l_seg_flag := 'N' ;
    END IF;

      l_table_name               := 'AMS_CELLS_VL';
      l_pk_name                  := 'CELL_ID';
      l_pk_value                 := l_market_segment_id;
      l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
/*
    IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name		        => l_table_name
            ,p_pk_name		            => l_pk_name
            ,p_pk_value		            => l_pk_value
            ,p_pk_data_type	            => l_pk_data_type
         ) = FND_API.G_FALSE
    THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
	      FND_MESSAGE.Set_Name('AMS', 'AMS_MKS_INVALID_MKS_ID');
	      FND_MSG_PUB.Add;
		  END IF;

		 x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
    END IF;  -- Check_FK_Exists
  */END IF;

-- added by julou on MAY-01-2001
-- if segment type is 'QUALIFIER', market_segment_id must be qualifier_id
-- from qp_qualifiers
/* removed by julou. no segment type any more.
IF p_mks_rec.segment_type = 'QUALIFIER' THEN
      OPEN c_mkt_seg_id(p_mks_rec.market_segment_id);
      FETCH c_mkt_seg_id INTO l_dummy;
      CLOSE c_mkt_seg_id;

      IF l_dummy = 0 THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('AMS', 'AMS_MKS_INVALID_MKS_ID');
	        FND_MSG_PUB.Add;
	      END IF;
      END IF;
    END IF;*/
-- end of comments
END Check_Mks_Record;


/*****************************************************************************/
-- Procedure: complete_mks_rec
--
-- History
--   10/28/1999      julou      created
--   05/08/2000      ptendulk   Modified the record type declaration
-------------------------------------------------------------------------------
PROCEDURE complete_mks_rec
(
  p_mks_rec         IN      mks_rec_type,
  x_complete_rec    OUT NOCOPY     mks_rec_type
)
IS

  CURSOR c_obj IS
    SELECT * FROM AMS_ACT_MARKET_SEGMENTS
    WHERE activity_market_segment_id = p_mks_rec.activity_market_segment_id;

-- ==============================================================================
-- Following code is Modified by ptendulk on 05/08/2000
-- Changed the record type declaration
-- ==============================================================================
  l_mks_rec     c_obj%ROWTYPE;

--  l_mks_rec     mks_rec_type;

BEGIN

  x_complete_rec := p_mks_rec;

  OPEN c_obj;
  FETCH c_obj INTO l_mks_rec;
  IF (c_obj%NOTFOUND) THEN
    CLOSE c_obj;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_obj;

  IF p_mks_rec.market_segment_id = FND_API.g_miss_num
  -- Following Line is Commented by ptendulk on 16 dec
--    OR p_mks_rec.market_segment_id IS NULL
  THEN
    x_complete_rec.market_segment_id := l_mks_rec.market_segment_id;
  END IF;

  IF p_mks_rec.act_market_segment_used_by_id = FND_API.g_miss_num
--    OR p_mks_rec.act_market_segment_used_by_id IS NULL
  -- Following Line is Commented by ptendulk on 16 dec
  THEN
    x_complete_rec.act_market_segment_used_by_id := l_mks_rec.act_market_segment_used_by_id;
  END IF;

  IF p_mks_rec.arc_act_market_segment_used_by = FND_API.g_miss_char
--    OR p_mks_rec.arc_act_market_segment_used_by IS NULL
  -- Following Line is Commented by ptendulk on 16 dec
  THEN
    x_complete_rec.arc_act_market_segment_used_by := l_mks_rec.arc_act_market_segment_used_by;
  END IF;

  IF p_mks_rec.segment_type = FND_API.g_miss_char THEN
    x_complete_rec.segment_type := l_mks_rec.segment_type;
  END IF;

  IF p_mks_rec.attribute_category = FND_API.g_miss_char THEN
    x_complete_rec.attribute_category := l_mks_rec.attribute_category;
  END IF;

  IF p_mks_rec.attribute1 = FND_API.g_miss_char THEN
    x_complete_rec.attribute1 := l_mks_rec.attribute1;
  END IF;

  IF p_mks_rec.attribute2 = FND_API.g_miss_char THEN
    x_complete_rec.attribute2 := l_mks_rec.attribute2;
  END IF;

  IF p_mks_rec.attribute3 = FND_API.g_miss_char THEN
    x_complete_rec.attribute3 := l_mks_rec.attribute3;
  END IF;

  IF p_mks_rec.attribute4 = FND_API.g_miss_char THEN
    x_complete_rec.attribute4 := l_mks_rec.attribute4;
  END IF;

  IF p_mks_rec.attribute5 = FND_API.g_miss_char THEN
    x_complete_rec.attribute5 := l_mks_rec.attribute5;
  END IF;

  IF p_mks_rec.attribute6 = FND_API.g_miss_char THEN
    x_complete_rec.attribute6 := l_mks_rec.attribute6;
  END IF;

  IF p_mks_rec.attribute7 = FND_API.g_miss_char THEN
    x_complete_rec.attribute7 := l_mks_rec.attribute7;
  END IF;

  IF p_mks_rec.attribute8 = FND_API.g_miss_char THEN
    x_complete_rec.attribute8 := l_mks_rec.attribute8;
  END IF;

  IF p_mks_rec.attribute9 = FND_API.g_miss_char THEN
    x_complete_rec.attribute9 := l_mks_rec.attribute9;
  END IF;

  IF p_mks_rec.attribute10 = FND_API.g_miss_char THEN
    x_complete_rec.attribute10 := l_mks_rec.attribute10;
  END IF;

  IF p_mks_rec.attribute11 = FND_API.g_miss_char THEN
    x_complete_rec.attribute11 := l_mks_rec.attribute11;
  END IF;

  IF p_mks_rec.attribute12 = FND_API.g_miss_char THEN
    x_complete_rec.attribute12 := l_mks_rec.attribute12;
  END IF;

  IF p_mks_rec.attribute13 = FND_API.g_miss_char THEN
    x_complete_rec.attribute13 := l_mks_rec.attribute13;
  END IF;

  IF p_mks_rec.attribute14 = FND_API.g_miss_char THEN
    x_complete_rec.attribute14 := l_mks_rec.attribute14;
  END IF;

  IF p_mks_rec.attribute15 = FND_API.g_miss_char THEN
    x_complete_rec.attribute15 := l_mks_rec.attribute15;
  END IF;
  IF p_mks_rec.group_code = FND_API.g_miss_char THEN
    x_complete_rec.group_code := l_mks_rec.group_code;
  END IF;
  IF p_mks_rec.exclude_flag =  FND_API.g_miss_char THEN
    x_complete_rec.exclude_flag  := l_mks_rec.exclude_flag;
  END IF;

END complete_mks_rec;

-- Start of Comments
--
-- NAME
--   Init_Mks_Rec
--
-- PURPOSE
--   This procedure is to Initialize the Record type before Updation.
--
-- NOTES
--
--
-- HISTORY
--   12/16/1999        ptendulk            created
-- End of Comments
PROCEDURE Init_Mks_Rec(
   x_mks_rec  OUT NOCOPY  mks_rec_type
)
IS
BEGIN
    x_mks_rec.activity_market_segment_id     :=  FND_API.G_MISS_NUM ;
    x_mks_rec.last_update_date               :=  FND_API.G_MISS_DATE ;
    x_mks_rec.last_updated_by                :=  FND_API.G_MISS_NUM ;
    x_mks_rec.creation_date                  :=  FND_API.G_MISS_DATE ;
    x_mks_rec.created_by                     :=  FND_API.G_MISS_NUM ;
    x_mks_rec.last_update_login              :=  FND_API.G_MISS_NUM ;
    x_mks_rec.market_segment_id              :=  FND_API.G_MISS_NUM ;
    x_mks_rec.act_market_segment_used_by_id  :=  FND_API.G_MISS_NUM ;
    x_mks_rec.arc_act_market_segment_used_by :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.object_version_number          :=  FND_API.G_MISS_NUM ;
    x_mks_rec.attribute_category             :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute1                     :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute2                     :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute3                     :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute4                     :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute5                     :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute6                     :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute7                     :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute8                     :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute9                     :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute10                    :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute11                    :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute12                    :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute13                    :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute14                    :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.attribute15                    :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.segment_type                   :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.group_code                     :=  FND_API.G_MISS_CHAR ;
    x_mks_rec.exclude_flag                   :=  FND_API.G_MISS_CHAR ;


END Init_Mks_Rec ;


END AMS_Act_Market_Segments_PVT;

/
