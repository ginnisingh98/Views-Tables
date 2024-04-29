--------------------------------------------------------
--  DDL for Package Body JTF_LOC_POSTAL_CODES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_LOC_POSTAL_CODES_PVT" AS
/* $Header: jtfvlopb.pls 120.2 2005/08/18 22:55:35 stopiwal ship $ */

g_pkg_name      CONSTANT VARCHAR2(30) := 'JTF_Loc_Postal_Codes_PVT';

/*****************************************************************************/
-- Procedure: create_postal_code
--
-- History
--   12/23/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE create_postal_code
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_postal_code_rec     IN      postal_code_rec_type,
  x_postal_code_id      OUT NOCOPY /* file.sql.39 change */     NUMBER
)
IS

  l_api_version          CONSTANT NUMBER := 1.0;
  l_api_name             CONSTANT VARCHAR2(30) := 'create_postal_code';
  l_full_name            CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status        VARCHAR2(1);
  l_postal_code_rec      postal_code_rec_type := p_postal_code_rec;
  l_postal_code_count    NUMBER;

  CURSOR c_postal_code_seq IS
    SELECT JTF_LOC_POSTAL_CODES_S.NEXTVAL
    FROM DUAL;

  CURSOR c_postal_code_count(postal_code_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM JTF_LOC_POSTAL_CODES
    WHERE location_postal_code_id = postal_code_id;

BEGIN
-- initialize
  SAVEPOINT create_postal_code;

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
   JTF_Utility_PVT.debug_message(l_full_name || ': validate');

   validate_postal_code
   (
      p_api_version      => l_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_postal_code_rec  => l_postal_code_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

-- generate an unique ID if it is not parsed in
   IF l_postal_code_rec.location_postal_code_id IS NULL THEN
      LOOP
         OPEN c_postal_code_seq;
         FETCH c_postal_code_seq INTO l_postal_code_rec.location_postal_code_id;
         CLOSE c_postal_code_seq;

         OPEN c_postal_code_count(l_postal_code_rec.location_postal_code_id);
         FETCH c_postal_code_count INTO l_postal_code_count;
         CLOSE c_postal_code_count;

         EXIT WHEN l_postal_code_count = 0;
      END LOOP;
   END IF;

-- insert
  JTF_Utility_PVT.debug_message(l_full_name || ': insert');

  INSERT INTO JTF_LOC_POSTAL_CODES
  (
    location_postal_code_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    object_version_number,
    orig_system_ref,
    orig_system_id,
    location_area_id,
    start_date_active,
    end_date_active,
    postal_code_start,
    postal_code_end
  )
  VALUES
  (
    l_postal_code_rec.location_postal_code_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id,
    1,
    l_postal_code_rec.orig_system_ref,
    l_postal_code_rec.orig_system_id,
    l_postal_code_rec.location_area_id,
    l_postal_code_rec.start_date_active,
    l_postal_code_rec.end_date_active,
    l_postal_code_rec.postal_code_start,
    l_postal_code_rec.postal_code_end
  );

-- finish
  x_postal_code_id := l_postal_code_rec.location_postal_code_id;

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
      ROLLBACK TO create_postal_code;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_postal_code;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO create_postal_code;
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

END create_postal_code;


/*****************************************************************************/
-- Procedure: update_postal_code
--
-- History
--   12/23/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE update_postal_code
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_postal_code_rec       IN      postal_code_rec_type,
  p_remove_flag           IN      VARCHAR2 := 'N'
)
IS

  l_api_version       CONSTANT NUMBER := 1.0;
  l_api_name          CONSTANT VARCHAR2(30) := 'update_postal_code';
  l_full_name         CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status     VARCHAR2(1);
  l_postal_code_rec   postal_code_rec_type := p_postal_code_rec;

BEGIN

-- initialize
  SAVEPOINT update_postal_code;

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

-- complete the record
  complete_rec
  (
    p_postal_code_rec,
    l_postal_code_rec
  );

  IF p_remove_flag <> 'Y' THEN
    -- item level
    JTF_Utility_PVT.debug_message(l_full_name || ': validate');
    IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      JTF_Utility_PVT.debug_message(l_full_name || ': check items');
      check_items
      (
        p_validation_mode => JTF_PLSQL_API.g_update,
        x_return_status   => l_return_status,
        p_postal_code_rec => l_postal_code_rec
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
        p_postal_code_rec => p_postal_code_rec,
        p_complete_rec    => l_postal_code_rec,
        x_return_status   => l_return_status
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
    UPDATE JTF_LOC_POSTAL_CODES SET
      end_date_active = SYSDATE
    WHERE location_postal_code_id = l_postal_code_rec.location_postal_code_id
    AND object_version_number = l_postal_code_rec.object_version_number;
  ELSE
    UPDATE JTF_LOC_POSTAL_CODES SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      object_version_number = l_postal_code_rec.object_version_number + 1,
      last_update_login = FND_GLOBAL.conc_login_id,
      orig_system_ref = l_postal_code_rec.orig_system_ref,
      orig_system_id = l_postal_code_rec.orig_system_id,
      location_area_id = l_postal_code_rec.location_area_id,
      start_date_active = l_postal_code_rec.start_date_active,
      end_date_active = l_postal_code_rec.end_date_active,
      postal_code_start = l_postal_code_rec.postal_code_start,
      postal_code_end = l_postal_code_rec.postal_code_end
    WHERE location_postal_code_id = l_postal_code_rec.location_postal_code_id
    AND object_version_number = l_postal_code_rec.object_version_number;
  END IF;

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
      ROLLBACK TO update_postal_code;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_postal_code;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO update_postal_code;
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

END update_postal_code;


/*****************************************************************************/
-- Procedure: delete_postal_code
--
-- History
--   12/23/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE delete_postal_code
(
  p_api_version       IN      NUMBER,
  p_init_msg_list     IN      VARCHAR2 := FND_API.g_false,
  p_commit            IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count         OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data          OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_postal_code_id    IN      NUMBER,
  p_object_version    IN      NUMBER
)
IS

  l_api_version    CONSTANT NUMBER := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'delete_postal_code';
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

BEGIN
-- initialize
  SAVEPOINT delete_postal_code;

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

-- delete
  JTF_Utility_PVT.debug_message(l_full_name || ': delete');

  DELETE FROM JTF_LOC_POSTAL_CODES
  WHERE location_postal_code_id = p_postal_code_id
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
      ROLLBACK TO delete_postal_code;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_postal_code;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO delete_postal_code;
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

END delete_postal_code;


/*****************************************************************************/
-- Procedure: lock_postal_code
--
-- History
--   12/23/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE lock_postal_code
(
  p_api_version       IN      NUMBER,
  P_init_msg_list     IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count         OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data          OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_postal_code_id    IN      NUMBER,
  p_object_version    IN      NUMBER
)
IS

  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'lock_postal_code';
  l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_postal_code_id   NUMBER;

  CURSOR c_postal_code IS
    SELECT location_postal_code_id
    FROM JTF_LOC_POSTAL_CODES
    WHERE location_postal_code_id = p_postal_code_id
    AND object_version_number = p_object_version
    FOR UPDATE OF location_postal_code_id NOWAIT;

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

  OPEN c_postal_code;
  FETCH c_postal_code INTO l_postal_code_id;
  IF (c_postal_code%NOTFOUND) THEN
    CLOSE c_postal_code;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_postal_code;

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

END lock_postal_code;


/*****************************************************************************/
-- PROCEDURE
--    validate_postal_code
--
-- HISTORY
--    12/23/99    julou    Created.
--------------------------------------------------------------------
PROCEDURE validate_postal_code
(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
   x_msg_count         OUT NOCOPY /* file.sql.39 change */ NUMBER,
   x_msg_data          OUT NOCOPY /* file.sql.39 change */ VARCHAR2,

   p_postal_code_rec   IN  postal_code_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_postal_code';
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
         p_postal_code_rec => p_postal_code_rec
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
      p_postal_code_rec => p_postal_code_rec,
      p_complete_rec    => p_postal_code_rec,
      x_return_status   => l_return_status
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

END validate_postal_code;


/*****************************************************************************/
-- Procedure: check_items
--
-- History
--   12/23/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode    IN      VARCHAR2,
    x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    p_postal_code_rec    IN      postal_code_rec_type
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
    p_postal_code_rec => p_postal_code_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check foreign key items
  JTF_Utility_PVT.debug_message(l_full_name || ': check fk items');
  check_fk_items
  (
    p_postal_code_rec  => p_postal_code_rec,
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
--   12/23/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_postal_code_rec    IN      postal_code_rec_type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check location_postal_code_id
  IF p_postal_code_rec.location_postal_code_id IS NULL
    AND p_validation_mode = JTF_PLSQL_API.g_update
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_POS_NO_LOC_POS_CODE_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check object_version_number
  IF p_postal_code_rec.object_version_number IS NULL
    AND p_validation_mode = JTF_PLSQL_API.g_update
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_NO_OBJ_VER_NUM');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check location_area_id
  IF p_postal_code_rec.location_area_id IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_POS_NO_LOC_AREA_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check start_date_active
  IF p_postal_code_rec.start_date_active IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_POS_NO_START_DATES');
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
--   12/23/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_fk_items
(
  p_postal_code_rec   IN      postal_code_rec_type,
  x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

  l_fk_flag       VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

  IF p_postal_code_rec.location_area_id IS NOT NULL THEN
    l_fk_flag := JTF_Utility_PVT.check_fk_exists
                 (
                   'JTF_LOC_AREAS_VL',
                   'location_area_id',
                   p_postal_code_rec.location_area_id
                 );

    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('JTF', 'JTF_LOC_POS_BAD_LOC_AREA_ID');
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
  p_postal_code_rec    IN  postal_code_rec_type,
  p_complete_rec       IN  postal_code_rec_type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
--   12/23/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE complete_rec
(
  p_postal_code_rec   IN      postal_code_rec_type,
  x_complete_rec      OUT NOCOPY /* file.sql.39 change */     postal_code_rec_type
)
IS

  CURSOR c_postal_code IS
    SELECT * FROM JTF_LOC_POSTAL_CODES
    WHERE location_postal_code_id = p_postal_code_rec.location_postal_code_id;

  l_postal_code_rec     c_postal_code%ROWTYPE;

BEGIN

  x_complete_rec := p_postal_code_rec;

  OPEN c_postal_code;
  FETCH c_postal_code INTO l_postal_code_rec;
  IF (c_postal_code%NOTFOUND) THEN
    CLOSE c_postal_code;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_postal_code;

  IF p_postal_code_rec.orig_system_ref = FND_API.g_miss_char THEN
    x_complete_rec.orig_system_ref := l_postal_code_rec.orig_system_ref;
  END IF;

  IF p_postal_code_rec.orig_system_id = FND_API.g_miss_num THEN
    x_complete_rec.orig_system_id := l_postal_code_rec.orig_system_id;
  END IF;

  IF p_postal_code_rec.location_area_id = FND_API.g_miss_num THEN
    x_complete_rec.location_area_id := l_postal_code_rec.location_area_id;
  END IF;

  IF p_postal_code_rec.start_date_active = FND_API.g_miss_date THEN
    x_complete_rec.start_date_active := l_postal_code_rec.start_date_active;
  END IF;

  IF p_postal_code_rec.end_date_active = FND_API.g_miss_date THEN
    x_complete_rec.end_date_active := l_postal_code_rec.end_date_active;
  END IF;

  IF p_postal_code_rec.postal_code_start = FND_API.g_miss_char THEN
    x_complete_rec.postal_code_start := l_postal_code_rec.postal_code_start;
  END IF;

  IF p_postal_code_rec.postal_code_end = FND_API.g_miss_char THEN
    x_complete_rec.postal_code_end := l_postal_code_rec.postal_code_end;
  END IF;

END complete_rec;


/****************************************************************************/
-- Procedure
--   init_rec
--
-- HISTORY
--    12/23/1999    julou    Created.
------------------------------------------------------------------------------
PROCEDURE init_rec
(
  x_postal_code_rec  OUT NOCOPY /* file.sql.39 change */  postal_code_rec_type
)
IS

BEGIN

  x_postal_code_rec.location_postal_code_id := FND_API.g_miss_num;
  x_postal_code_rec.last_update_date := FND_API.g_miss_date;
  x_postal_code_rec.last_updated_by := FND_API.g_miss_num;
  x_postal_code_rec.creation_date := FND_API.g_miss_date;
  x_postal_code_rec.created_by := FND_API.g_miss_num;
  x_postal_code_rec.last_update_login := FND_API.g_miss_num;
  x_postal_code_rec.object_version_number := FND_API.g_miss_num;
  x_postal_code_rec.orig_system_ref := FND_API.g_miss_char;
  x_postal_code_rec.orig_system_id := FND_API.g_miss_num;
  x_postal_code_rec.location_area_id := FND_API.g_miss_num;
  x_postal_code_rec.start_date_active := FND_API.g_miss_date;
  x_postal_code_rec.end_date_active := FND_API.g_miss_date;
  x_postal_code_rec.postal_code_start := FND_API.g_miss_char;
  x_postal_code_rec.postal_code_end := FND_API.g_miss_char;

END init_rec;

END JTF_Loc_Postal_Codes_PVT;

/
