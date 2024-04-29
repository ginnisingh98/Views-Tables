--------------------------------------------------------
--  DDL for Package Body JTF_LOC_AREAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_LOC_AREAS_PVT" AS
/* $Header: jtfvloab.pls 120.2 2005/08/18 22:55:16 stopiwal ship $ */

g_pkg_name      CONSTANT VARCHAR2(30) := 'JTF_Loc_Areas_PVT';

/*****************************************************************************/
-- Procedure: create_loc_area
--
-- History
--   11/22/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE create_loc_area
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_area_rec        IN      loc_area_rec_type,
  x_loc_area_id         OUT NOCOPY /* file.sql.39 change */     NUMBER
)
IS

  l_api_version       CONSTANT NUMBER := 1.0;
  l_api_name          CONSTANT VARCHAR2(30) := 'create_loc_area';
  l_full_name         CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status     VARCHAR2(1);
  l_loc_area_rec      loc_area_rec_type := p_loc_area_rec;
  l_loc_area_count    NUMBER;

  CURSOR c_loc_area_seq IS
    SELECT JTF_LOC_AREAS_B_S.NEXTVAL
    FROM DUAL;

  CURSOR c_loc_area_count(loc_area_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM JTF_LOC_AREAS_VL
    WHERE location_area_id = loc_area_id;

BEGIN
-- initialize
  SAVEPOINT create_loc_area;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;


  JTF_Utility_PVT.debug_message(l_full_name || ': start');

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
--  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    JTF_Utility_PVT.debug_message(l_full_name || ': validate');

    validate_loc_area
    (
      p_api_version      => l_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_loc_area_rec     => l_loc_area_rec
    );

    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
--  END IF;

-- insert
  JTF_Utility_PVT.debug_message(l_full_name || ': insert');

  IF l_loc_area_rec.location_area_id IS NULL THEN
    LOOP
      OPEN c_loc_area_seq;
      FETCH c_loc_area_seq INTO l_loc_area_rec.location_area_id;
      CLOSE c_loc_area_seq;

      OPEN c_loc_area_count(l_loc_area_rec.location_area_id);
      FETCH c_loc_area_count INTO l_loc_area_count;
      CLOSE c_loc_area_count;

      EXIT WHEN l_loc_area_count = 0;
    END LOOP;
  END IF;

  INSERT INTO JTF_LOC_AREAS_B
  (
    location_area_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    object_version_number,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    location_type_code,
    start_date_active,
    end_date_active,
    location_area_code,
    orig_system_id,
    orig_system_ref,
    parent_location_area_id
  )
  VALUES
  (
    l_loc_area_rec.location_area_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    1,
    FND_GLOBAL.conc_login_id,
    l_loc_area_rec.request_id,
    l_loc_area_rec.program_application_id,
    l_loc_area_rec.program_id,
    l_loc_area_rec.program_update_date,
    l_loc_area_rec.location_type_code,
    l_loc_area_rec.start_date_active,
    l_loc_area_rec.end_date_active,
    l_loc_area_rec.location_area_code,
    l_loc_area_rec.orig_system_id,
    l_loc_area_rec.orig_system_ref,
    l_loc_area_rec.parent_location_area_id
  );

    INSERT INTO JTF_LOC_AREAS_TL
  (
    location_area_id,
    language,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    source_lang,
    location_area_name,
    location_area_description
  )
  SELECT
    l_loc_area_rec.location_area_id,
    l.language_code,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id,
    USERENV('LANG'),
    l_loc_area_rec.location_area_name,
    l_loc_area_rec.location_area_description
  FROM fnd_languages l
  WHERE l.installed_flag in ('I', 'B')
  AND NOT EXISTS
  (
    SELECT NULL
    FROM JTF_LOC_AREAS_TL t
    WHERE t.location_area_id = l_loc_area_rec.location_area_id
    AND t.language = l.language_code
  );

-- finish
  x_loc_area_id := l_loc_area_rec.location_area_id;

  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get
  (
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
  );

  JTF_Utility_PVT.debug_message(l_full_name||': end');

  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_loc_area;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_loc_area;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO create_loc_area;
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

END create_loc_area;


/*****************************************************************************/
-- Procedure: update_loc_area
--
-- History
--   11/22/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE update_loc_area
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_area_rec        IN      loc_area_rec_type,
  p_remove_flag         IN      VARCHAR2 := 'N'
)
IS

  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'update_loc_area';
  l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status    VARCHAR2(1);
  l_loc_area_rec     loc_area_rec_type := p_loc_area_rec;

BEGIN

-- initialize
  SAVEPOINT update_loc_area;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  JTF_Utility_PVT.debug_message(l_full_name || ': start');

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
  complete_loc_area_rec
  (
    p_loc_area_rec,
    l_loc_area_rec
  );

-- validate
  IF p_remove_flag <> 'Y' THEN
    -- item level
    IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      JTF_Utility_PVT.debug_message(l_full_name || ': validate');

      check_items
      (
        p_validation_mode => JTF_PLSQL_API.g_update,
        x_return_status   => l_return_status,
        p_loc_area_rec    => l_loc_area_rec
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF;

    -- record level
    IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      JTF_Utility_PVT.debug_message(l_full_name||': check record');
      check_record
      (
        p_loc_area_rec  => p_loc_area_rec,
        p_complete_rec  => l_loc_area_rec,
        x_return_status => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      END IF;
    END IF;
  END IF;

-- update
  JTF_Utility_PVT.debug_message(l_full_name||': update');

  IF p_remove_flag = 'Y' THEN
     l_loc_area_rec.end_date_active := SYSDATE;
  END IF;

  UPDATE JTF_LOC_AREAS_B SET
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    object_version_number = l_loc_area_rec.object_version_number + 1,
    last_update_login = FND_GLOBAL.conc_login_id,
    request_id = l_loc_area_rec.request_id,
    program_application_id = l_loc_area_rec.program_application_id,
    program_id = l_loc_area_rec.program_id,
    program_update_date = l_loc_area_rec.program_update_date,
    location_type_code = l_loc_area_rec.location_type_code,
    start_date_active = l_loc_area_rec.start_date_active,
    end_date_active = l_loc_area_rec.end_date_active,
    location_area_code = l_loc_area_rec.location_area_code,
    orig_system_id = l_loc_area_rec.orig_system_id,
    orig_system_ref = l_loc_area_rec.orig_system_ref,
    parent_location_area_id = l_loc_area_rec.parent_location_area_id
  WHERE location_area_id = l_loc_area_rec.location_area_id
  AND object_version_number = l_loc_area_rec.object_version_number;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  UPDATE JTF_LOC_AREAS_TL SET
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    last_update_login = FND_GLOBAL.conc_login_id,
    source_lang = USERENV('LANG'),
    location_area_name = l_loc_area_rec.location_area_name,
    location_area_description = l_loc_area_rec.location_area_description
  WHERE location_area_id = l_loc_area_rec.location_area_id
  AND USERENV('LANG') IN (language, source_lang);

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
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

  JTF_Utility_PVT.debug_message(l_full_name || ': end');

  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_loc_area;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_loc_area;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO update_loc_area;
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

END update_loc_area;


/*****************************************************************************/
-- Procedure: delete_loc_area
--
-- History
--   11/22/1999    julou    created
--   24-APR-2001   julou    updating the end_date_active to current date,
--                          instead of deleting the record
-------------------------------------------------------------------------------
PROCEDURE delete_loc_area
(
  p_api_version         IN      NUMBER,
  P_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,

  x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_area_id         IN      NUMBER,
  p_object_version      IN      NUMBER
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_loc_area';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_child_exist   NUMBER := NULL;

  CURSOR c_child_exist(l_id NUMBER) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS(SELECT 1
                  FROM jtf_loc_areas_b
                 WHERE nvl(end_date_active,SYSDATE + 1) > SYSDATE
                   AND parent_location_area_id = l_id);

BEGIN
-- initialize
  SAVEPOINT delete_loc_area;

  JTF_Utility_PVT.debug_message(l_full_name || ': start');

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
  JTF_Utility_PVT.debug_message(l_full_name || ': delete');

  OPEN c_child_exist(p_loc_area_id);
  FETCH c_child_exist INTO l_child_exist;
  CLOSE c_child_exist;

  -- check if the area has child
  IF l_child_exist IS NOT NULL
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREA_HAS_CHILD');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

/* removed by julou for bug 1717907/1703508
  DELETE FROM JTF_LOC_AREAS_TL
  WHERE location_area_id = p_loc_area_id;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  DELETE FROM JTF_LOC_AREAS_B
  WHERE location_area_id = p_loc_area_id
  AND object_version_number = p_object_version;
*/

-- added by julou  24-APR-2001 for bug 1717907/1703508
  UPDATE jtf_loc_areas_b
  SET    last_update_date = SYSDATE
        ,last_updated_by = FND_GLOBAL.user_id
        ,last_update_login = FND_GLOBAL.conc_login_id
        ,end_date_active = SYSDATE
        ,object_version_number = object_version_number + 1
  WHERE location_area_id = p_loc_area_id
  AND   object_version_number = p_object_version;
-- end of added

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
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

  JTF_Utility_PVT.debug_message(l_full_name || ': end');

  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_loc_area;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_loc_area;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO delete_loc_area;
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

END delete_loc_area;


/*****************************************************************************/
-- Procedure: lock_loc_area
--
-- History
--   11/22/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE lock_loc_area
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,

  x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_area_id         IN      NUMBER,
  p_object_version      IN      NUMBER
)
IS

  l_api_version    CONSTANT NUMBER := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'lock_loc_area';
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_loc_area_id    NUMBER;

  CURSOR c_loc_area_b IS
    SELECT location_area_id
    FROM JTF_LOC_AREAS_B
    WHERE location_area_id = p_loc_area_id
    AND object_version_number = p_object_version
    FOR UPDATE OF location_area_id NOWAIT;

  CURSOR c_loc_area_tl IS
    SELECT location_area_id
    FROM JTF_LOC_AREAS_TL
    WHERE location_area_id = p_loc_area_id
    AND USERENV('LANG') IN (language, source_lang)
    FOR UPDATE OF location_area_id NOWAIT;

BEGIN
-- initialize
  JTF_Utility_PVT.debug_message(l_full_name || ': start');

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
  JTF_Utility_PVT.debug_message(l_full_name || ': lock');

  OPEN c_loc_area_b;
  FETCH c_loc_area_b INTO l_loc_area_id;
  IF (c_loc_area_b%NOTFOUND) THEN
    CLOSE c_loc_area_b;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_loc_area_b;

  OPEN c_loc_area_tl;
  FETCH c_loc_area_tl INTO l_loc_area_id;
  IF (c_loc_area_tl%NOTFOUND) THEN
    CLOSE c_loc_area_tl;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_loc_area_tl;

-- finish
  FND_MSG_PUB.count_and_get
  (
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
  );

  JTF_Utility_PVT.debug_message(l_full_name || ': end');

  EXCEPTION

    WHEN JTF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_API_RESOURCE_LOCKED');
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

END lock_loc_area;


/*****************************************************************************/
-- PROCEDURE
--    validate_loc_area
--
-- HISTORY
--    11/29/99    julou    Created.
--------------------------------------------------------------------
PROCEDURE validate_loc_area
(
  p_api_version           IN      NUMBER,
  P_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_area_rec          IN      loc_area_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_loc_area';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
   JTF_Utility_PVT.debug_message(l_full_name||': start');

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
      JTF_Utility_PVT.debug_message(l_full_name||': check items');
      check_items
      (
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status,
         p_loc_area_rec    => p_loc_area_rec
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

  -- record level
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
    JTF_Utility_PVT.debug_message(l_full_name||': check record');
    check_record
    (
      p_loc_area_rec  => p_loc_area_rec,
      p_complete_rec  => p_loc_area_rec,
      x_return_status => l_return_status
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

   JTF_Utility_PVT.debug_message(l_full_name ||': end');

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

END validate_loc_area;

/*****************************************************************************/
-- Procedure: check_items
--
-- History
--   11/22/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_items
(
   p_validation_mode    IN      VARCHAR2,
   x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
   p_loc_area_rec       IN      loc_area_rec_type
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'check_items';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

BEGIN
-- initialize
  JTF_Utility_PVT.debug_message(l_full_name || ': start');

  x_return_status := FND_API.g_ret_sts_success;

-- check required items
  JTF_Utility_PVT.debug_message(l_full_name || ': check required items');
  check_loc_area_req_items
  (
    p_validation_mode => p_validation_mode,
    p_loc_area_rec    => p_loc_area_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check unique key items
    JTF_Utility_PVT.debug_message(l_full_name || ': check uk items');
    check_loc_area_uk_items
    (
      p_validation_mode => p_validation_mode,
      p_loc_area_rec    => p_loc_area_rec,
      x_return_status   => x_return_status
    );

    IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
    END IF;

-- check foreign key items
  JTF_Utility_PVT.debug_message(l_full_name || ': check fk items');
  check_loc_area_fk_items
  (
    p_loc_area_rec  => p_loc_area_rec,
    x_return_status => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

END check_items;


/*****************************************************************************/
-- Procedure: check_loc_area_req_items
--
-- History
--   11/22/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_loc_area_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_loc_area_rec       IN      loc_area_rec_type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

  CURSOR c_world_exist IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS(SELECT 1
                  FROM jtf_loc_areas_b
                 WHERE location_type_code = 'AREA1');

  l_world_exist NUMBER;

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check location_area_id
  IF p_loc_area_rec.location_area_id IS NULL
  AND p_validation_mode = JTF_PLSQL_API.g_update THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREA_NO_LOC_AREA_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check location_type_code
  IF p_loc_area_rec.location_type_code IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREA_NO_LOC_TYPE_CODE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check object_version_number
  IF p_loc_area_rec.object_version_number IS NULL
    AND p_validation_mode = JTF_PLSQL_API.g_update
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_NO_OBJ_VER_NUM');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check start_date_active
  IF p_loc_area_rec.start_date_active IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREA_NO_START_DATE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check locaton_area_name
  IF p_loc_area_rec.location_area_name IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREA_NO_AREA_NAME');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check location_area_code
  IF p_loc_area_rec.location_area_code IS NULL
  OR p_loc_area_rec.location_area_code = FND_API.g_miss_char
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREA_NO_AREA_CODE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check parent_location_area_id
  IF p_loc_area_rec.location_type_code <> 'AREA1' THEN
    IF p_loc_area_rec.parent_location_area_id = FND_API.g_miss_num
      OR p_loc_area_rec.parent_location_area_id IS NULL
    THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREA_BAD_PARENT_ID');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  ELSE -- user trying to create world type area, check the existence of world first
    OPEN c_world_exist;
    FETCH c_world_exist INTO l_world_exist;
    CLOSE c_world_exist;

    IF l_world_exist IS NOT NULL -- world exists, cant create another world
    THEN
      IF p_validation_mode = JTF_PLSQL_API.g_create
      THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREA_WORLD_EXISTS');
          FND_MSG_PUB.add;
        END IF;

        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;
    ELSE
      IF p_loc_area_rec.parent_location_area_id IS NOT NULL
      AND p_loc_area_rec.parent_location_area_id <> FND_API.g_miss_num
      THEN -- creating new world, no parent allowed
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREA_BAD_PARENT_ID');
          FND_MSG_PUB.add;
        END IF;

        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;
    END IF;
  END IF;

END check_loc_area_req_items;


/*****************************************************************************/
-- Procedure: check_loc_area_uk_items
--
-- History
--   11/22/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_loc_area_uk_items
(
  p_validation_mode    IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_loc_area_rec       IN      loc_area_rec_type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

  l_uk_flag    VARCHAR2(1);
  l_parent_loc_str VARCHAR2(60);
  l_count      NUMBER := NULL;

  CURSOR c_area_name_count1(l_id NUMBER, l_parent_id NUMBER, l_name VARCHAR2) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS(SELECT 1
                  FROM jtf_loc_areas_b b, jtf_loc_areas_tl t
                 WHERE t.location_area_name = l_name
                   AND t.language = USERENV('LANG')
                   AND t.location_area_id <> l_id
                   AND b.parent_location_area_id = l_parent_id
                   AND b.location_area_id =t.location_area_id);

CURSOR c_area_name_count2(l_parent_id NUMBER, l_name VARCHAR2) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS(SELECT 1
                  FROM jtf_loc_areas_b b, jtf_loc_areas_tl t
                 WHERE t.location_area_name = l_name
                   AND t.language = USERENV('LANG')
                   AND b.parent_location_area_id = l_parent_id
                   AND b.location_area_id =t.location_area_id);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check PK, if location_area_id is passed in, must check if it is duplicate
  IF p_validation_mode = JTF_PLSQL_API.g_create
  AND p_loc_area_rec.location_area_id IS NOT NULL
  THEN
    l_uk_flag := JTF_Utility_PVT.check_uniqueness
                 (
		   'JTF_LOC_AREAS_VL',
		   'location_area_id = ' || p_loc_area_rec.location_area_id
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)	THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREAS_DUPLICATE_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- 07/09/2001  julou  modified where clause for parent_location_area_id
-- check location_area_code
  IF p_loc_area_rec.parent_location_area_id = FND_API.g_miss_num
  OR p_loc_area_rec.parent_location_area_id IS NULL
  THEN
    l_parent_loc_str := ' AND parent_location_area_id = NULL';
  ELSE
    l_parent_loc_str := ' AND parent_location_area_id = ' || p_loc_area_rec.parent_location_area_id;
  END IF;

  IF p_loc_area_rec.location_area_id IS NOT NULL THEN
    l_uk_flag := JTF_Utility_PVT.check_uniqueness
                 (
                   'JTF_LOC_AREAS_VL',
                   'location_area_id <> ' || p_loc_area_rec.location_area_id
                   || ' AND location_area_code =  ''' || p_loc_area_rec.location_area_code || ''''
                   || l_parent_loc_str
                   );
  ELSE
    l_uk_flag := JTF_Utility_PVT.check_uniqueness
                 (
                  'JTF_LOC_AREAS_VL',
                  'location_area_code = ''' || p_loc_area_rec.location_area_code || ''''
                  || l_parent_loc_str
                   );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREA_DUP_AREA_CODE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;


-- check location_area_name, language

  IF p_loc_area_rec.location_area_id IS NOT NULL THEN
    OPEN c_area_name_count1(p_loc_area_rec.location_area_id, p_loc_area_rec.parent_location_area_id, p_loc_area_rec.location_area_name);
    FETCH c_area_name_count1 INTO l_count;
    CLOSE c_area_name_count1;
  ELSE
    OPEN c_area_name_count2(p_loc_area_rec.parent_location_area_id, p_loc_area_rec.location_area_name);
    FETCH c_area_name_count2 INTO l_count;
    CLOSE c_area_name_count2;
  END IF;

  IF l_count = 1 THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREAS_DUP_NAME_LANG');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_loc_area_uk_items;


/*****************************************************************************/
-- Procedure: check_loc_area_fk_items
--
-- History
--   11/22/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_loc_area_fk_items
(
  p_loc_area_rec     IN      loc_area_rec_type,
  x_return_status    OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

  l_fk_flag       VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check location_type_code
  l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'JTF_LOC_TYPES_VL',
                   'location_type_code',
                   p_loc_area_rec.location_type_code,
                   2                         -- varchar2 type
                 );

  IF l_fk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREA_BAD_LOC_TYPE_CODE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check parent_location_area_id
  IF p_loc_area_rec.parent_location_area_id IS NOT NULL
  AND p_loc_area_rec.parent_location_area_id <> FND_API.g_miss_num
  THEN
    l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'JTF_LOC_AREAS_VL',
                   'location_area_id',
                   p_loc_area_rec.parent_location_area_id
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_AREA_BAD_PARENT_ID');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

END check_loc_area_fk_items;


/*****************************************************************************/
-- PROCEDURE
--    check_record
--
-- HISTORY
--    12/23/99    julou    Created.
-------------------------------------------------------------------------------
PROCEDURE check_record
(
  p_loc_area_rec    IN  loc_area_rec_type,
  p_complete_rec    IN  loc_area_rec_type,
  x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS

   l_start_date  DATE;
   l_end_date    DATE;

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

  -- check that start_date_active <= end_date_active
  IF p_complete_rec.start_date_active <> FND_API.g_miss_date
    AND p_complete_rec.end_date_active <> FND_API.g_miss_date
    AND p_complete_rec.end_date_active IS NOT NULL
  THEN
    l_start_date := p_complete_rec.start_date_active;
    l_end_date := p_complete_rec.end_date_active;
    IF l_start_date > l_end_date THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_START_DATE_AFTER_END_DATE');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

END check_record;


/*****************************************************************************/
-- Procedure: complete_loc_area_rec
--
-- History
--   11/22/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE complete_loc_area_rec
(
  p_loc_area_rec    IN      loc_area_rec_type,
  x_complete_rec    OUT NOCOPY /* file.sql.39 change */     loc_area_rec_type
)
IS

  CURSOR c_loc_area IS
    SELECT * FROM JTF_LOC_AREAS_VL
    WHERE location_area_id = p_loc_area_rec.location_area_id;

  l_loc_area_rec     c_loc_area%ROWTYPE;

BEGIN

  x_complete_rec := p_loc_area_rec;

  OPEN c_loc_area;
  FETCH c_loc_area INTO l_loc_area_rec;
  IF (c_loc_area%NOTFOUND) THEN
    CLOSE c_loc_area;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_loc_area;

  IF p_loc_area_rec.request_id = FND_API.g_miss_num THEN
    x_complete_rec.request_id := l_loc_area_rec.request_id;
  END IF;

  IF p_loc_area_rec.program_application_id = FND_API.g_miss_num THEN
    x_complete_rec.program_application_id := l_loc_area_rec.program_application_id;
  END IF;

  IF p_loc_area_rec.program_id = FND_API.g_miss_num THEN
    x_complete_rec.program_id := l_loc_area_rec.program_id;
  END IF;

  IF p_loc_area_rec.program_update_date = FND_API.g_miss_date THEN
    x_complete_rec.program_update_date := l_loc_area_rec.program_update_date;
  END IF;

  IF p_loc_area_rec.location_type_code = FND_API.g_miss_char THEN
    x_complete_rec.location_type_code := l_loc_area_rec.location_type_code;
  END IF;

  IF p_loc_area_rec.start_date_active = FND_API.g_miss_date THEN
    x_complete_rec.start_date_active := l_loc_area_rec.start_date_active;
  END IF;

  IF p_loc_area_rec.end_date_active = FND_API.g_miss_date THEN
    x_complete_rec.end_date_active := l_loc_area_rec.end_date_active;
  END IF;

  IF p_loc_area_rec.location_area_code = FND_API.g_miss_char THEN
    x_complete_rec.location_area_code := l_loc_area_rec.location_area_code;
  END IF;

  IF p_loc_area_rec.location_area_name = FND_API.g_miss_char THEN
    x_complete_rec.location_area_name := l_loc_area_rec.location_area_name;
  END IF;

  IF p_loc_area_rec.location_area_description = FND_API.g_miss_char THEN
    x_complete_rec.location_area_description := l_loc_area_rec.location_area_description;
  END IF;

  IF p_loc_area_rec.orig_system_id = FND_API.g_miss_num THEN
    x_complete_rec.orig_system_id := l_loc_area_rec.orig_system_id;
  END IF;

  IF p_loc_area_rec.orig_system_ref = FND_API.g_miss_char THEN
    x_complete_rec.orig_system_ref := l_loc_area_rec.orig_system_ref;
  END IF;

  IF p_loc_area_rec.parent_location_area_id = FND_API.g_miss_num THEN
    x_complete_rec.parent_location_area_id := l_loc_area_rec.parent_location_area_id;
  END IF;

END complete_loc_area_rec;


/****************************************************************************/
-- Procedure
--   init_rec
--
-- HISTORY
--    12/19/1999    julou    Created.
------------------------------------------------------------------------------
PROCEDURE init_rec
(
  x_loc_area_rec  OUT NOCOPY /* file.sql.39 change */  loc_area_rec_type
)
IS

BEGIN

  x_loc_area_rec.location_area_id := FND_API.g_miss_num;
  x_loc_area_rec.last_update_date := FND_API.g_miss_date;
  x_loc_area_rec.last_updated_by := FND_API.g_miss_num;
  x_loc_area_rec.creation_date := FND_API.g_miss_date;
  x_loc_area_rec.created_by := FND_API.g_miss_num;
  x_loc_area_rec.last_update_login := FND_API.g_miss_num;
  x_loc_area_rec.object_version_number := FND_API.g_miss_num;
  x_loc_area_rec.request_id := FND_API.g_miss_num;
  x_loc_area_rec.program_application_id := FND_API.g_miss_num;
  x_loc_area_rec.program_id := FND_API.g_miss_num;
  x_loc_area_rec.program_update_date := FND_API.g_miss_date;
  x_loc_area_rec.location_type_code := FND_API.g_miss_char;
  x_loc_area_rec.start_date_active := FND_API.g_miss_date;
  x_loc_area_rec.end_date_active := FND_API.g_miss_date;
  x_loc_area_rec.location_area_code := FND_API.g_miss_char;
  x_loc_area_rec.orig_system_id := FND_API.g_miss_num;
  x_loc_area_rec.orig_system_ref := FND_API.g_miss_char;
  x_loc_area_rec.parent_location_area_id := FND_API.g_miss_num;
  x_loc_area_rec.location_area_name := FND_API.g_miss_char;
  x_loc_area_rec.location_area_description := FND_API.g_miss_char;

END init_rec;

END JTF_Loc_Areas_PVT;

/
