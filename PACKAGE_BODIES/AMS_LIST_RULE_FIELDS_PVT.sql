--------------------------------------------------------
--  DDL for Package Body AMS_LIST_RULE_FIELDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_RULE_FIELDS_PVT" AS
/* $Header: amsvrufb.pls 115.11 2003/02/14 23:49:26 gjoby ship $ */

g_pkg_name      CONSTANT VARCHAR2(30) := 'AMS_List_Rule_Fields_PVT';

/*****************************************************************************/
-- Procedure: create_list_rule_field
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_list_rule_field
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_rule_fld_rec        IN      rule_fld_rec_type,
  x_rule_fld_id         OUT NOCOPY     NUMBER
)
IS

  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'create_list_rule_field';
  l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status    VARCHAR2(1);
  l_rule_fld_rec      rule_fld_rec_type := p_rule_fld_rec;
  l_rule_fld_count    NUMBER;

  l_list_rule_count  NUMBER;
  CURSOR c_list_rule_field_seq IS
    SELECT AMS_LIST_RULE_FIELDS_S.NEXTVAL
    FROM DUAL;

  CURSOR c_list_rule_field_count(rule_fld_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM AMS_LIST_RULE_FIELDS
    WHERE list_rule_field_id = rule_fld_id;

   CURSOR c_list_rule_count(lst_rule_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM AMS_LIST_RULE_USAGES
    WHERE list_rule_id = lst_rule_id;

BEGIN
-- initialize
  SAVEPOINT create_list_rule_field;

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

  OPEN c_list_rule_count(l_rule_fld_rec.list_rule_id);
  FETCH c_list_rule_count INTO l_list_rule_count;
  CLOSE c_list_rule_count;

  IF l_list_rule_count > 0   THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULE_CANNOT_MODIFY');
      FND_MSG_PUB.add;
    END IF;
    ---RAISE FND_API.g_exc_error;
  END IF;

-- validate
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': validate');
  END IF;
  validate_list_rule_field
  (
    p_api_version      => l_api_version,
    p_init_msg_list    => p_init_msg_list,
    p_validation_level => p_validation_level,
    x_return_status    => l_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data,
    p_rule_fld_rec     => l_rule_fld_rec
  );

  IF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

-- insert
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': insert');
  END IF;

  IF l_rule_fld_rec.list_rule_field_id IS NULL THEN
    LOOP
      OPEN c_list_rule_field_seq;
      FETCH c_list_rule_field_seq INTO l_rule_fld_rec.list_rule_field_id;
      CLOSE c_list_rule_field_seq;

      OPEN c_list_rule_field_count(l_rule_fld_rec.list_rule_field_id);
      FETCH c_list_rule_field_count INTO l_rule_fld_count;
      CLOSE c_list_rule_field_count;

      EXIT WHEN l_rule_fld_count = 0;
    END LOOP;
  END IF;

  INSERT INTO AMS_LIST_RULE_FIELDS
  (
    list_rule_field_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    object_version_number,
    field_table_name,
    field_column_name,
    list_rule_id,
    substring_length,
    weightage,
    sequence_number,
    word_replacement_code
  )
  VALUES
  (
    l_rule_fld_rec.list_rule_field_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id,
    1,
    l_rule_fld_rec.field_table_name,
    l_rule_fld_rec.field_column_name,
    l_rule_fld_rec.list_rule_id,
    l_rule_fld_rec.substring_length,
    l_rule_fld_rec.weightage,
    l_rule_fld_rec.sequence_number,
    l_rule_fld_rec.word_replacement_code
  );

-- finish
  x_rule_fld_id := l_rule_fld_rec.list_rule_field_id;

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
      ROLLBACK TO create_list_rule_field;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_list_rule_field;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO create_list_rule_field;
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

END create_list_rule_field;


/*****************************************************************************/
-- Procedure: update_list_rule_field
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE update_list_rule_field
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_rule_fld_rec        IN      rule_fld_rec_type
)
IS

  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'update_list_rule_field';
  l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status    VARCHAR2(1);
  l_rule_fld_rec     rule_fld_rec_type := p_rule_fld_rec;

BEGIN

-- initialize
  SAVEPOINT update_list_rule_field;

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

    check_items
    (
      p_validation_mode => JTF_PLSQL_API.g_update,
      x_return_status   => l_return_status,
      p_rule_fld_rec    => l_rule_fld_rec
    );

    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
  END IF;

-- complete record
  complete_rec
  (
    p_rule_fld_rec,
    l_rule_fld_rec
  );

-- record level

-- update
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name||': update');
  END IF;

  UPDATE AMS_LIST_RULE_FIELDS SET
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    last_update_login = FND_GLOBAL.conc_login_id,
    object_version_number = l_rule_fld_rec.object_version_number + 1,
    field_table_name = l_rule_fld_rec.field_table_name,
    field_column_name = l_rule_fld_rec.field_column_name,
    list_rule_id = l_rule_fld_rec.list_rule_id,
    substring_length = l_rule_fld_rec.substring_length,
    weightage = l_rule_fld_rec.weightage,
    sequence_number = l_rule_fld_rec.sequence_number,
    word_replacement_code = l_rule_fld_rec.word_replacement_code
  WHERE list_rule_field_id = l_rule_fld_rec.list_rule_field_id
  AND object_version_number = l_rule_fld_rec.object_version_number;

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
      ROLLBACK TO update_list_rule_field;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_list_rule_field;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO update_list_rule_field;
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

END update_list_rule_field;


/*****************************************************************************/
-- Procedure: delete_list_rule_field
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE delete_list_rule_field
(
  p_api_version       IN      NUMBER,
  p_init_msg_list     IN      VARCHAR2 := FND_API.g_false,
  p_commit            IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY     VARCHAR2,
  x_msg_count         OUT NOCOPY     NUMBER,
  x_msg_data          OUT NOCOPY     VARCHAR2,

  p_rule_fld_id       IN      NUMBER,
  p_object_version    IN      NUMBER
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_list_rule_field';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

  l_list_rule_count  NUMBER;
  l_list_rule_id      NUMBER;

  CURSOR c_list_rule_id(l_lst_rule_field_id IN NUMBER) IS
  SELECT list_rule_id FROM ams_list_rule_fields
  WHERE list_rule_field_id=l_lst_rule_field_id;



  CURSOR c_list_rule_count(lst_rule_id IN NUMBER) IS
  SELECT COUNT(*)
  FROM AMS_LIST_RULE_USAGES
  WHERE list_rule_id = lst_rule_id;

BEGIN
-- initialize
  SAVEPOINT delete_list_rule_field;

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

  OPEN c_list_rule_id(p_rule_fld_id);
  FETCH c_list_rule_id INTO l_list_rule_id;
  CLOSE c_list_rule_id;

  OPEN c_list_rule_count(l_list_rule_id);
  FETCH c_list_rule_count INTO l_list_rule_count;
  CLOSE c_list_rule_count;

  IF l_list_rule_count > 0   THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULE_CANNOT_MODIFY');
      FND_MSG_PUB.add;
    END IF;
    ---RAISE FND_API.g_exc_error;
  END IF;

-- delete
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': delete');
  END IF;

  DELETE FROM AMS_LIST_RULE_FIELDS
  WHERE list_rule_field_id = p_rule_fld_id
  AND object_version_number = p_object_version;

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
      ROLLBACK TO delete_list_rule_field;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_list_rule_field;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO delete_list_rule_field;
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

END delete_list_rule_field;


/*****************************************************************************/
-- Procedure: lock_list_rule_field
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE lock_list_rule_field
(
  p_api_version       IN      NUMBER,
  p_init_msg_list     IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY     VARCHAR2,
  x_msg_count         OUT NOCOPY     NUMBER,
  x_msg_data          OUT NOCOPY     VARCHAR2,

  p_rule_fld_id       IN      NUMBER,
  p_object_version    IN      NUMBER
)
IS

  l_api_version    CONSTANT NUMBER := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'lock_list_rule_field';
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_rule_fld_id     NUMBER;

  CURSOR c_list_rule_field IS
    SELECT list_rule_field_id
    FROM AMS_LIST_RULE_FIELDS
    WHERE list_rule_field_id = p_rule_fld_id
    AND object_version_number = p_object_version
    FOR UPDATE OF list_rule_field_id NOWAIT;

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

  OPEN c_list_rule_field;
  FETCH c_list_rule_field INTO l_rule_fld_id;
  IF (c_list_rule_field%NOTFOUND) THEN
    CLOSE c_list_rule_field;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_list_rule_field;

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

END lock_list_rule_field;


/*****************************************************************************/
-- PROCEDURE
--    validate_list_rule_field
--
-- HISTORY
--    01/24/2000    julou    Created.
--------------------------------------------------------------------
PROCEDURE validate_list_rule_field
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_rule_fld_rec        IN      rule_fld_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_list_rule_field';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
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

   ---------------------- validate ------------------------
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message(l_full_name||': check items');
      END IF;
      check_items
      (
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status,
         p_rule_fld_rec    => p_rule_fld_rec
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

  -- record level

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

END validate_list_rule_field;

/*****************************************************************************/
-- Procedure: check_items
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode    IN      VARCHAR2,
    x_return_status      OUT NOCOPY     VARCHAR2,
    p_rule_fld_rec       IN      rule_fld_rec_type
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
  check_req_items
  (
    p_validation_mode => p_validation_mode,
    p_rule_fld_rec    => p_rule_fld_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check foreign key items
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': check fk items');
  END IF;
  check_fk_items
  (
    p_rule_fld_rec  => p_rule_fld_rec,
    x_return_status => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check unique key items
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(l_full_name || ': check uk items');
    END IF;
    check_uk_items
    (
      p_validation_mode => p_validation_mode,
      p_rule_fld_rec    => p_rule_fld_rec,
      x_return_status   => x_return_status
    );

    IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
    END IF;

END check_items;


/*****************************************************************************/
-- Procedure: check_req_items
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_rule_fld_rec        IN      rule_fld_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
)
IS

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check list_rule_field_id
  IF p_rule_fld_rec.list_rule_field_id IS NULL
  AND p_validation_mode = JTF_PLSQL_API.g_update THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULE_FLD_NO_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check object_version_number
  IF p_rule_fld_rec.object_version_number IS NULL
    AND p_validation_mode = JTF_PLSQL_API.g_update
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_NO_OBJ_VER_NUM');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check field_table_name
  IF p_rule_fld_rec.field_table_name IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULE_FLD_NO_TBL_NAME');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check field_column_name
  IF p_rule_fld_rec.field_column_name IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULE_FLD_NO_COL_NAME');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check list_rule_id
  IF p_rule_fld_rec.list_rule_id IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULES_ALL_NO_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_req_items;


/*****************************************************************************/
-- Procedure: check_fk_items
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_fk_items
(
  p_rule_fld_rec     IN      rule_fld_rec_type,
  x_return_status    OUT NOCOPY     VARCHAR2
)
IS

  l_fk_flag       VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check field_table_name, field_column_name
  l_fk_flag := AMS_Utility_PVT.check_fk_exists
                 (
                   'AMS_LIST_FIELDS_B',
                   'field_table_name',
                   p_rule_fld_rec.field_table_name,
                   2,                         -- varchar2 type
                   'field_column_name = ''' || p_rule_fld_rec.field_column_name || ''''
                 );

  IF l_fk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULE_FLD_BAD_TBL_COL');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check list_rule_id
  IF p_rule_fld_rec.list_rule_id IS NOT NULL THEN
    l_fk_flag := AMS_Utility_PVT.check_fk_exists
                 (
                   'AMS_LIST_RULES_ALL',
                   'list_rule_id',
                   p_rule_fld_rec.list_rule_id
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULES_ALL_NO_ID');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

END check_fk_items;


/*****************************************************************************/
-- Procedure: check_uk_items
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_uk_items
(
  p_validation_mode   IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_rule_fld_rec      IN      rule_fld_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
)
IS

  l_uk_flag    VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check PK, if list_rule_field_id is passed in, must check if it is duplicate
  IF p_validation_mode = JTF_PLSQL_API.g_create
    AND p_rule_fld_rec.list_rule_field_id IS NOT NULL
  THEN
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
		   'AMS_LIST_RULE_FIELDS',
		   'list_rule_field_id = ' || p_rule_fld_rec.list_rule_field_id
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)	THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULE_FLD_NO_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check original_word, replacement_word
  IF p_rule_fld_rec.list_rule_field_id IS NOT NULL THEN
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
                   'AMS_LIST_RULE_FIELDS',
                   'list_rule_field_id <> ' || p_rule_fld_rec.list_rule_field_id
                   || ' AND list_rule_id =  ' || p_rule_fld_rec.list_rule_id
                   || ' AND field_table_name = ''' || p_rule_fld_rec.field_table_name
                   || ''' AND field_column_name = ''' || p_rule_fld_rec.field_column_name || ''''
                 );
  ELSE
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
                   'AMS_LIST_RULE_FIELDS',
                   'list_rule_id =  ' || p_rule_fld_rec.list_rule_id
                   || ' AND field_table_name = ''' || p_rule_fld_rec.field_table_name
                   || ''' AND field_column_name = ''' || p_rule_fld_rec.field_column_name || ''''
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULE_FLD_DUP_RU_TB_CO');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_uk_items;


/*****************************************************************************/
-- Procedure: complete_rec
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE complete_rec
(
  p_rule_fld_rec    IN      rule_fld_rec_type,
  x_complete_rec    OUT NOCOPY     rule_fld_rec_type
)
IS

  CURSOR c_list_rule_field IS
    SELECT * FROM AMS_LIST_RULE_FIELDS
    WHERE list_rule_field_id = p_rule_fld_rec.list_rule_field_id;

  l_rule_fld_rec     c_list_rule_field%ROWTYPE;

BEGIN

  x_complete_rec := p_rule_fld_rec;

  OPEN c_list_rule_field;
  FETCH c_list_rule_field INTO l_rule_fld_rec;
  IF (c_list_rule_field%NOTFOUND) THEN
    CLOSE c_list_rule_field;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_list_rule_field;

  IF p_rule_fld_rec.field_table_name = FND_API.g_miss_char THEN
    x_complete_rec.field_table_name := l_rule_fld_rec.field_table_name;
  END IF;

  IF p_rule_fld_rec.field_column_name = FND_API.g_miss_char THEN
    x_complete_rec.field_column_name := l_rule_fld_rec.field_column_name;
  END IF;

  IF p_rule_fld_rec.list_rule_id = FND_API.g_miss_num THEN
    x_complete_rec.list_rule_id := l_rule_fld_rec.list_rule_id;
  END IF;

  IF p_rule_fld_rec.substring_length = FND_API.g_miss_num THEN
    x_complete_rec.substring_length := l_rule_fld_rec.substring_length;
  END IF;

  IF p_rule_fld_rec.weightage = FND_API.g_miss_num THEN
    x_complete_rec.weightage := l_rule_fld_rec.weightage;
  END IF;

  IF p_rule_fld_rec.sequence_number = FND_API.g_miss_num THEN
    x_complete_rec.sequence_number := l_rule_fld_rec.sequence_number;
  END IF;

  IF p_rule_fld_rec.word_replacement_code = FND_API.g_miss_char THEN
    x_complete_rec.word_replacement_code := l_rule_fld_rec.word_replacement_code;
  END IF;


END complete_rec;


/****************************************************************************/
-- Procedure
--   init_rec
--
-- HISTORY
--    01/24/2000    julou    Created.
------------------------------------------------------------------------------
PROCEDURE init_rec
(
  x_rule_fld_rec  OUT NOCOPY  rule_fld_rec_type
)
IS

BEGIN

  x_rule_fld_rec.list_rule_field_id := FND_API.g_miss_num;
  x_rule_fld_rec.last_update_date := FND_API.g_miss_date;
  x_rule_fld_rec.last_updated_by := FND_API.g_miss_num;
  x_rule_fld_rec.creation_date := FND_API.g_miss_date;
  x_rule_fld_rec.created_by := FND_API.g_miss_num;
  x_rule_fld_rec.last_update_login := FND_API.g_miss_num;
  x_rule_fld_rec.object_version_number := FND_API.g_miss_num;
  x_rule_fld_rec.list_rule_id := FND_API.g_miss_num;
  x_rule_fld_rec.field_table_name := FND_API.g_miss_char;
  x_rule_fld_rec.field_column_name := FND_API.g_miss_char;
  x_rule_fld_rec.substring_length := FND_API.g_miss_num;
  x_rule_fld_rec.weightage := FND_API.g_miss_num;
  x_rule_fld_rec.sequence_number := FND_API.g_miss_num;
  x_rule_fld_rec.word_replacement_code := FND_API.g_miss_char;

END init_rec;

END AMS_List_Rule_Fields_PVT;

/
