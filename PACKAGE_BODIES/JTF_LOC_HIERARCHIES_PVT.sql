--------------------------------------------------------
--  DDL for Package Body JTF_LOC_HIERARCHIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_LOC_HIERARCHIES_PVT" AS
/* $Header: jtfvlohb.pls 120.2 2005/08/18 22:55:25 stopiwal ship $ */

g_pkg_name      CONSTANT VARCHAR2(30) := 'JTF_Loc_Hierarchies_PVT';

/*****************************************************************************/
-- Procedure: create_hierarchy
--
-- History
--   12/15/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE create_hierarchy
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_hier_rec          IN      loc_hier_rec_type,
  x_hier_id               OUT NOCOPY /* file.sql.39 change */     NUMBER
)
IS

  l_api_version     CONSTANT NUMBER := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'create_hierarchy';
  l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status   VARCHAR2(1);
  l_loc_hier_rec    loc_hier_rec_type := p_loc_hier_rec;
  l_count           NUMBER;

  CURSOR c_seq IS
    SELECT JTF_LOC_HIERARCHIES_B_S.NEXTVAL
    FROM DUAL;

  CURSOR c_count(hier_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM JTF_LOC_HIERARCHIES_B
    WHERE location_hierarchy_id = hier_id;

BEGIN
-- initialize
  SAVEPOINT create_hierarchy;

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

  validate_hierarchy
  (
    p_api_version      => l_api_version,
    p_init_msg_list    => p_init_msg_list,
    p_validation_level => p_validation_level,
    x_return_status    => l_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data,
    p_loc_hier_rec     => l_loc_hier_rec
  );

  IF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
--END IF;

-- generate an unique ID if it is not parsed in
  JTF_Utility_PVT.debug_message(l_full_name || ': insert');

  IF l_loc_hier_rec.location_hierarchy_id IS NULL THEN
    LOOP
      OPEN c_seq;
      FETCH c_seq INTO l_loc_hier_rec.location_hierarchy_id;
      CLOSE c_seq;

      OPEN c_count(l_loc_hier_rec.location_hierarchy_id);
      FETCH c_count INTO l_count;
      CLOSE c_count;

      EXIT WHEN l_count = 0;
    END LOOP;
  END IF;

-- insert
  INSERT INTO JTF_LOC_HIERARCHIES_B
  (
    location_hierarchy_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    object_version_number,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    created_by_application_id,
    location_type_code,
    start_date_active,
    end_date_active,
    area1_id,
    area1_code,
    area2_id,
    area2_code,
    country_id,
    country_code,
    country_region_id,
    country_region_code,
    state_id,
    state_code,
    state_region_id,
    state_region_code,
    city_id,
    city_code,
    postal_code_id
  )
  VALUES
  (
    l_loc_hier_rec.location_hierarchy_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id,
    1,
    l_loc_hier_rec.request_id,
    l_loc_hier_rec.program_application_id,
    l_loc_hier_rec.program_id,
    l_loc_hier_rec.program_update_date,
    l_loc_hier_rec.created_by_application_id,
    l_loc_hier_rec.location_type_code,
    l_loc_hier_rec.start_date_active,
    l_loc_hier_rec.end_date_active,
    l_loc_hier_rec.area1_id,
    l_loc_hier_rec.area1_code,
    l_loc_hier_rec.area2_id,
    l_loc_hier_rec.area2_code,
    l_loc_hier_rec.country_id,
    l_loc_hier_rec.country_code,
    l_loc_hier_rec.country_region_id,
    l_loc_hier_rec.country_region_code,
    l_loc_hier_rec.state_id,
    l_loc_hier_rec.state_code,
    l_loc_hier_rec.state_region_id,
    l_loc_hier_rec.state_region_code,
    l_loc_hier_rec.city_id,
    l_loc_hier_rec.city_code,
    l_loc_hier_rec.postal_code_id
  );

-- finish
  x_hier_id := l_loc_hier_rec.location_hierarchy_id;

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
      ROLLBACK TO create_hierarchy;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_hierarchy;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO create_hierarchy;
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

END create_hierarchy;


/*****************************************************************************/
-- Procedure: update_hierarchy
--
-- History
--   12/15/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE update_hierarchy
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_hier_rec          IN      loc_hier_rec_type
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'update_hierarchy';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status VARCHAR2(1);
  l_loc_hier_rec  loc_hier_rec_type := p_loc_hier_rec;

BEGIN

-- initialize
  SAVEPOINT update_hierarchy;

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
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    JTF_Utility_PVT.debug_message(l_full_name || ': validate');

    check_items
    (
      p_validation_mode  => JTF_PLSQL_API.g_update,
      x_return_status    => l_return_status,
      p_loc_hier_rec     => l_loc_hier_rec
    );

    IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    ELSIF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;

-- complete record
  complete_rec
  (
    p_loc_hier_rec,
    l_loc_hier_rec
  );

-- record level
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
    JTF_Utility_PVT.debug_message(l_full_name||': check record');
    check_record
    (
      p_loc_hier_rec  => p_loc_hier_rec,
      p_complete_rec  => l_loc_hier_rec,
      x_return_status => l_return_status
    );

    IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    ELSIF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;

-- update
  JTF_Utility_PVT.debug_message(l_full_name||': update');

  UPDATE JTF_LOC_HIERARCHIES_B SET
    last_update_date = sysdate,
    last_updated_by = fnd_global.user_id,
    object_version_number = l_loc_hier_rec.object_version_number + 1,
    last_update_login = fnd_global.conc_login_id,
    request_id = l_loc_hier_rec.request_id,
    program_application_id = l_loc_hier_rec.program_application_id,
    program_id = l_loc_hier_rec.program_id,
    program_update_date = l_loc_hier_rec.program_update_date,
    created_by_application_id = l_loc_hier_rec.created_by_application_id,
    location_type_code = l_loc_hier_rec.location_type_code,
    start_date_active = l_loc_hier_rec.start_date_active,
    end_date_active = l_loc_hier_rec.end_date_active,
    area1_id = l_loc_hier_rec.area1_id,
    area1_code = l_loc_hier_rec.area1_code,
    area2_id = l_loc_hier_rec.area2_id,
    area2_code = l_loc_hier_rec.area2_code,
    country_id = l_loc_hier_rec.country_id,
    country_code = l_loc_hier_rec.country_code,
    country_region_id = l_loc_hier_rec.country_region_id,
    country_region_code = l_loc_hier_rec.country_region_code,
    state_id = l_loc_hier_rec.state_id,
    state_code = l_loc_hier_rec.state_code,
    state_region_id = l_loc_hier_rec.state_region_id,
    state_region_code = l_loc_hier_rec.state_region_code,
    city_id = l_loc_hier_rec.city_id,
    city_code = l_loc_hier_rec.city_code,
    postal_code_id = l_loc_hier_rec.postal_code_id
  WHERE location_hierarchy_id = l_loc_hier_rec.location_hierarchy_id
  AND object_version_number = l_loc_hier_rec.object_version_number;

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
      ROLLBACK TO update_hierarchy;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_hierarchy;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO update_hierarchy;
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

END update_hierarchy;


/*****************************************************************************/
-- Procedure: delete_hierarchy
--
-- History
--   12/15/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE delete_hierarchy
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_hier_id               IN      NUMBER,
  p_object_version        IN      NUMBER
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_hierarchy';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

BEGIN
-- initialize
  SAVEPOINT delete_hierarchy;

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

  DELETE FROM JTF_LOC_HIERARCHIES_B
  WHERE location_hierarchy_id = p_hier_id
  AND object_version_number = p_object_version;

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
      ROLLBACK TO delete_hierarchy;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_hierarchy;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO delete_hierarchy;
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

END delete_hierarchy;


/*****************************************************************************/
-- Procedure: lock_hierarchy
--
-- History
--   12/15/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE lock_hierarchy
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_hier_id               IN      NUMBER,
  p_object_version        IN      NUMBER
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'lock_hierarchy';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_hier_id        NUMBER;

  CURSOR c_hier IS
    SELECT location_hierarchy_id
    FROM JTF_LOC_HIERARCHIES_B
    WHERE location_hierarchy_id = p_hier_id
    AND object_version_number = p_object_version
    FOR UPDATE OF location_hierarchy_id NOWAIT;

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

  OPEN c_hier;
  FETCH c_hier INTO l_hier_id;
  IF (c_hier%NOTFOUND) THEN
    CLOSE c_hier;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_hier;

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

END lock_hierarchy;


/*****************************************************************************/
-- PROCEDURE
--    validate_hierarchy
--
-- HISTORY
--    11/29/99    julou    Created.
--------------------------------------------------------------------
PROCEDURE validate_hierarchy
(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
   x_msg_count         OUT NOCOPY /* file.sql.39 change */ NUMBER,
   x_msg_data          OUT NOCOPY /* file.sql.39 change */ VARCHAR2,

   p_loc_hier_rec      IN  loc_hier_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_hierarchy';
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
-- item level
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      JTF_Utility_PVT.debug_message(l_full_name||': check items');
      check_items
      (
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status,
         p_loc_hier_rec    => p_loc_hier_rec
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
      p_loc_hier_rec  => p_loc_hier_rec,
      p_complete_rec  => p_loc_hier_rec,
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

END validate_hierarchy;

/*****************************************************************************/
-- Procedure: check_items
--
-- History
--   12/15/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE check_items
(
  p_validation_mode       IN      VARCHAR2,
  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  p_loc_hier_rec          IN      loc_hier_rec_type
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
  check_req_items
  (
    p_validation_mode => p_validation_mode,
    p_loc_hier_rec    => p_loc_hier_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check unique key items
  JTF_Utility_PVT.debug_message(l_full_name || ': check uk items');
  check_uk_items
  (
    p_validation_mode => p_validation_mode,
    p_loc_hier_rec    => p_loc_hier_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check foreign key items
  JTF_Utility_PVT.debug_message(l_full_name || ': check fk items');
  check_fk_items
  (
    p_loc_hier_rec  => p_loc_hier_rec,
    x_return_status => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

END check_items;


/*****************************************************************************/
-- Procedure: check_req_items
--
-- History
--   12/15/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE check_req_items
(
  p_validation_mode       IN      VARCHAR2,
  p_loc_hier_rec          IN      loc_hier_rec_type,
  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check location_hierarchy_id
  IF p_loc_hier_rec.location_hierarchy_id IS NULL
  AND p_validation_mode = JTF_PLSQL_API.g_update THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_NO_LOC_HIER_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check object_version_number
  IF p_loc_hier_rec.object_version_number IS NULL
    AND p_validation_mode = JTF_PLSQL_API.g_update
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_NO_OBJ_VER_NUM');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check created_by_application_id
  IF p_loc_hier_rec.created_by_application_id IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_NO_CR_BY_APP_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check location_type_code
  IF p_loc_hier_rec.location_type_code IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_NO_LOC_TYPE_CODE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check start_date_active
  IF p_loc_hier_rec.start_date_active IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_NO_STAT_DATE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_req_items;


/*****************************************************************************/
-- Procedure: check_uk_items
--
-- History
--   12/19/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_uk_items
(
  p_validation_mode   IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_loc_hier_rec      IN      loc_hier_rec_type,
  x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

  l_uk_flag    VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check PK, if location_hierarchy_id is parsed in, must check if it is duplicate
  IF p_validation_mode = JTF_PLSQL_API.g_create
    AND p_loc_hier_rec.location_hierarchy_id IS NOT NULL
  THEN
    l_uk_flag := JTF_Utility_PVT.check_uniqueness
                 (
		   'JTF_LOC_HIERARCHIES_VL',
		   'location_hierarchy_id = ' || p_loc_hier_rec.location_hierarchy_id
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)	THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIERARCHY_DUPLICATE_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_uk_items;


/*****************************************************************************/
-- Procedure: check_fk_items
--
-- History
--   12/15/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE check_fk_items
(
  p_loc_hier_rec          IN      loc_hier_rec_type,
  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

  l_fk_flag       VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check FK1 location_type_code
  IF p_loc_hier_rec.location_type_code IS NOT NULL THEN
    l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'JTF_LOC_TYPES_VL',
                   'location_type_code',
                   p_loc_hier_rec.location_type_code,
                   2                        -- varchar2 type
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_BAD_LOC_TYPE_CODE');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

-- check FK2 created_by_application_id
  IF p_loc_hier_rec.created_by_application_id IS NOT NULL THEN
    l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'FND_APPLICATION',
                   'application_id',
                   p_loc_hier_rec.created_by_application_id
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_BAD_APP_ID');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

-- check FK3 area1_id area1_code
  IF p_loc_hier_rec.area1_id IS NOT NULL THEN
    l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'JTF_LOC_AREAS_VL',
                   'location_area_id',
                   p_loc_hier_rec.area1_id,
                   1,
                   'location_area_code = ''' ||  p_loc_hier_rec.area1_code || ''''
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_BAD_AREA1');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

-- check FK4 area2_id area2_code
  IF p_loc_hier_rec.area2_id IS NOT NULL THEN
    l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'JTF_LOC_AREAS_VL',
                   'location_area_id',
                   p_loc_hier_rec.area2_id,
                   1,
                   'location_area_code = ''' ||  p_loc_hier_rec.area2_code || ''''
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_BAD_AREA2');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

-- check FK5 country_id country_code
  IF p_loc_hier_rec.country_id IS NOT NULL THEN
    l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'JTF_LOC_AREAS_VL',
                   'location_area_id',
                   p_loc_hier_rec.country_id,
                   1,
                   'location_area_code = ''' ||  p_loc_hier_rec.country_code || ''''
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_BAD_COUNTRY');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

-- check FK6 country_region_id country_region_code
  IF p_loc_hier_rec.country_region_id IS NOT NULL THEN
    l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'JTF_LOC_AREAS_VL',
                   'location_area_id',
                   p_loc_hier_rec.country_region_id,
                   1,
                   'location_area_code = ''' ||  p_loc_hier_rec.country_region_code || ''''
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_BAD_COUNTRY_REGN');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

-- check FK7 state_id state_code
  IF p_loc_hier_rec.state_id IS NOT NULL THEN
    l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'JTF_LOC_AREAS_VL',
                   'location_area_id',
                   p_loc_hier_rec.state_id,
                   1,
                   'location_area_code = ''' ||  p_loc_hier_rec.state_code || ''''
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_BAD_STATE');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

-- check FK8 state_region_id state_region_code
  IF p_loc_hier_rec.state_region_id IS NOT NULL THEN
    l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'JTF_LOC_AREAS_VL',
                   'location_area_id',
                   p_loc_hier_rec.state_region_id,
                   1,
                   'location_area_code = ''' ||  p_loc_hier_rec.state_region_code || ''''
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_BAD_STATE_REGN');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;


-- check FK9 city_id city_code
  IF p_loc_hier_rec.city_id IS NOT NULL THEN
    l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'JTF_LOC_AREAS_VL',
                   'location_area_id',
                   p_loc_hier_rec.city_id,
                   1,
                   'location_area_code = ''' ||  p_loc_hier_rec.city_code || ''''
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_BAD_CITY');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

-- check FK10 postal_code_id
  IF p_loc_hier_rec.postal_code_id IS NOT NULL THEN
    l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'JTF_LOC_AREAS_VL',
                   'location_area_id',
                   p_loc_hier_rec.postal_code_id
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_HIER_BAD_POSTAL_CODE');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

END check_fk_items;


/*****************************************************************************/
-- PROCEDURE
--    check_record
--
-- HISTORY
--    12/23/99    julou    Created.
-------------------------------------------------------------------------------
PROCEDURE check_record
(
  p_loc_hier_rec    IN  loc_hier_rec_type,
  p_complete_rec    IN  loc_hier_rec_type,
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
-- Procedure: complete_rec
--
-- History
--   12/15/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE complete_rec
(
  p_loc_hier_rec      IN      loc_hier_rec_type,
  x_complete_rec      OUT NOCOPY /* file.sql.39 change */     loc_hier_rec_type
)
IS

  CURSOR c_hier IS
    SELECT * FROM JTF_LOC_HIERARCHIES_B
    WHERE location_hierarchy_id = p_loc_hier_rec.location_hierarchy_id;

  l_loc_hier_rec     c_hier%ROWTYPE;

BEGIN

  x_complete_rec := p_loc_hier_rec;

  OPEN c_hier;
  FETCH c_hier INTO l_loc_hier_rec;
  IF (c_hier%NOTFOUND) THEN
    CLOSE c_hier;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_hier;


  IF p_loc_hier_rec.request_id = FND_API.g_miss_num THEN
    x_complete_rec.request_id := l_loc_hier_rec.request_id;
  END IF;

  IF p_loc_hier_rec.program_application_id = FND_API.g_miss_char THEN
    x_complete_rec.program_application_id := l_loc_hier_rec.program_application_id;
  END IF;

  IF p_loc_hier_rec.program_id = FND_API.g_miss_char THEN
    x_complete_rec.program_id := l_loc_hier_rec.program_id;
  END IF;

  IF p_loc_hier_rec.program_update_date = FND_API.g_miss_char THEN
    x_complete_rec.program_update_date := l_loc_hier_rec.program_update_date;
  END IF;

  IF p_loc_hier_rec.created_by_application_id = FND_API.g_miss_char THEN
    x_complete_rec.created_by_application_id := l_loc_hier_rec.created_by_application_id;
  END IF;

  IF p_loc_hier_rec.location_type_code = FND_API.g_miss_char THEN
    x_complete_rec.location_type_code := l_loc_hier_rec.location_type_code;
  END IF;

  IF p_loc_hier_rec.start_date_active = FND_API.g_miss_char THEN
    x_complete_rec.start_date_active := l_loc_hier_rec.start_date_active;
  END IF;

  IF p_loc_hier_rec.end_date_active = FND_API.g_miss_char THEN
    x_complete_rec.end_date_active := l_loc_hier_rec.end_date_active;
  END IF;

  IF p_loc_hier_rec.area1_id = FND_API.g_miss_char THEN
    x_complete_rec.area1_id := l_loc_hier_rec.area1_id;
  END IF;

  IF p_loc_hier_rec.area1_code = FND_API.g_miss_char THEN
    x_complete_rec.area1_code := l_loc_hier_rec.area1_code;
  END IF;

  IF p_loc_hier_rec.area2_id = FND_API.g_miss_char THEN
    x_complete_rec.area2_id := l_loc_hier_rec.area2_id;
  END IF;

  IF p_loc_hier_rec.area2_code = FND_API.g_miss_char THEN
    x_complete_rec.area2_code := l_loc_hier_rec.area2_code;
  END IF;

  IF p_loc_hier_rec.country_id = FND_API.g_miss_char THEN
    x_complete_rec.country_id := l_loc_hier_rec.country_id;
  END IF;

  IF p_loc_hier_rec.country_code = FND_API.g_miss_char THEN
    x_complete_rec.country_code := l_loc_hier_rec.country_code;
  END IF;

  IF p_loc_hier_rec.country_region_id = FND_API.g_miss_char THEN
    x_complete_rec.country_region_id := l_loc_hier_rec.country_region_id;
  END IF;

  IF p_loc_hier_rec.country_region_code = FND_API.g_miss_char THEN
    x_complete_rec.country_region_code := l_loc_hier_rec.country_region_code;
  END IF;

  IF p_loc_hier_rec.state_id = FND_API.g_miss_char THEN
    x_complete_rec.state_id := l_loc_hier_rec.state_id;
  END IF;

  IF p_loc_hier_rec.state_code = FND_API.g_miss_char THEN
    x_complete_rec.state_code := l_loc_hier_rec.state_code;
  END IF;

  IF p_loc_hier_rec.state_region_id = FND_API.g_miss_char THEN
    x_complete_rec.state_region_id := l_loc_hier_rec.state_region_id;
  END IF;

  IF p_loc_hier_rec.state_region_code = FND_API.g_miss_char THEN
    x_complete_rec.state_region_code := l_loc_hier_rec.state_region_code;
  END IF;

  IF p_loc_hier_rec.city_id = FND_API.g_miss_char THEN
    x_complete_rec.city_id := l_loc_hier_rec.city_id;
  END IF;

  IF p_loc_hier_rec.city_code = FND_API.g_miss_char THEN
    x_complete_rec.city_code := l_loc_hier_rec.city_code;
  END IF;

  IF p_loc_hier_rec.postal_code_id = FND_API.g_miss_char THEN
    x_complete_rec.postal_code_id := l_loc_hier_rec.postal_code_id;
  END IF;

END complete_rec;


/****************************************************************************/
-- Procedure
--   init_rec
--
-- HISTORY
--    12/19/1999    julou    Created.
------------------------------------------------------------------------------
PROCEDURE init_rec
(
  x_loc_hier_rec  OUT NOCOPY /* file.sql.39 change */  loc_hier_rec_type
)
IS

BEGIN

   x_loc_hier_rec.location_hierarchy_id := FND_API.g_miss_num;
   x_loc_hier_rec.last_update_date := FND_API.g_miss_date;
   x_loc_hier_rec.last_updated_by := FND_API.g_miss_num;
   x_loc_hier_rec.creation_date := FND_API.g_miss_date;
   x_loc_hier_rec.created_by := FND_API.g_miss_num;
   x_loc_hier_rec.last_update_login := FND_API.g_miss_num;
   x_loc_hier_rec.object_version_number := FND_API.g_miss_num;
   x_loc_hier_rec.request_id := FND_API.g_miss_num;
   x_loc_hier_rec.program_application_id := FND_API.g_miss_num;
   x_loc_hier_rec.program_id := FND_API.g_miss_num;
   x_loc_hier_rec.program_update_date := FND_API.g_miss_date;
   x_loc_hier_rec.created_by_application_id := FND_API.g_miss_num;
   x_loc_hier_rec.location_type_code := FND_API.g_miss_char;
   x_loc_hier_rec.start_date_active := FND_API.g_miss_date;
   x_loc_hier_rec.end_date_active := FND_API.g_miss_date;
   x_loc_hier_rec.area1_id := FND_API.g_miss_num;
   x_loc_hier_rec.area1_code := FND_API.g_miss_char;
   x_loc_hier_rec.area2_id := FND_API.g_miss_num;
   x_loc_hier_rec.area2_code := FND_API.g_miss_char;
   x_loc_hier_rec.country_id := FND_API.g_miss_num;
   x_loc_hier_rec.country_code := FND_API.g_miss_char;
   x_loc_hier_rec.country_region_id := FND_API.g_miss_num;
   x_loc_hier_rec.country_region_code := FND_API.g_miss_char;
   x_loc_hier_rec.state_id := FND_API.g_miss_num;
   x_loc_hier_rec.state_code := FND_API.g_miss_char;
   x_loc_hier_rec.state_region_id := FND_API.g_miss_num;
   x_loc_hier_rec.state_region_code := FND_API.g_miss_char;
   x_loc_hier_rec.city_id := FND_API.g_miss_num;
   x_loc_hier_rec.city_code := FND_API.g_miss_char;
   x_loc_hier_rec.postal_code_id := FND_API.g_miss_num;

END init_rec;

END JTF_Loc_Hierarchies_PVT;

/
