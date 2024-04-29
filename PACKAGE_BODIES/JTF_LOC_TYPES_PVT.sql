--------------------------------------------------------
--  DDL for Package Body JTF_LOC_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_LOC_TYPES_PVT" AS
/* $Header: jtfvlotb.pls 120.2 2005/08/18 22:55:44 stopiwal ship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='JTF_Loc_Types_PVT';


-------------------------------------------------------------------
-- PROCEDURE
--   lock_loc_type
--
-- HISTORY
--   11/17/99  julou  Create.
--------------------------------------------------------------------
PROCEDURE lock_loc_type
(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2 := FND_API.g_false,

  x_return_status    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count        OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,

  p_loc_type_id      IN  NUMBER,
  p_object_version   IN  NUMBER
)
IS

   l_api_version    CONSTANT NUMBER       := 1.0;
   l_api_name       CONSTANT VARCHAR2(30) := 'lock_loc_type';
   l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_loc_type_id    NUMBER;

   CURSOR c_loc_type_b IS
   SELECT location_type_id
     FROM JTF_LOC_TYPES_B
    WHERE location_type_id = p_loc_type_id
      AND object_version_number = p_object_version
   FOR UPDATE OF location_type_id NOWAIT;

   CURSOR c_loc_type_tl IS
   SELECT location_type_id
     FROM JTF_LOC_TYPES_TL
    WHERE location_type_id = p_loc_type_id
      AND USERENV('LANG') IN (language, source_lang)
   FOR UPDATE OF location_type_id NOWAIT;

BEGIN

   -------------------- initialize ------------------------
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   JTF_Utility_PVT.debug_message(l_full_name||': start');

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
   JTF_Utility_PVT.debug_message(l_full_name||': lock');

   OPEN c_loc_type_b;
   FETCH c_loc_type_b INTO l_loc_type_id;
   IF (c_loc_type_b%NOTFOUND) THEN
      CLOSE c_loc_type_b;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_loc_type_b;

   OPEN c_loc_type_tl;
   FETCH c_loc_type_tl INTO l_loc_type_id;
   IF (c_loc_type_tl%NOTFOUND) THEN
      CLOSE c_loc_type_tl;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_loc_type_tl;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   JTF_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN JTF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name('JTF', 'JTF_API_RESOURCE_LOCKED');
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

END lock_loc_type;


---------------------------------------------------------------------
-- PROCEDURE
--   update_loc_type
--
-- HISTORY
--   11/17/99  julou  Create.
----------------------------------------------------------------------
PROCEDURE update_loc_type
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2  := FND_API.g_false,
  p_commit              IN  VARCHAR2  := FND_API.g_false,
  p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,

  p_loc_type_rec        IN  loc_type_rec_type
)
IS

   l_api_version    CONSTANT NUMBER := 1.0;
   l_api_name       CONSTANT VARCHAR2(30) := 'update_loc_type';
   l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

--   l_loc_type_rec       loc_type_rec_type := p_loc_type_rec;
   l_return_status      VARCHAR2(1);

BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT update_loc_type;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----------------------- validate ----------------------
-- validate
    JTF_Utility_PVT.debug_message(l_full_name || ': check items');

    check_items
    (
      p_validation_mode => JTF_PLSQL_API.g_update,
      x_return_status    => l_return_status,
      p_loc_type_rec     => p_loc_type_rec
    );

    IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    ELSIF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    END IF;

   -------------------------- update --------------------
   JTF_Utility_PVT.debug_message(l_full_name ||': update');

   UPDATE JTF_LOC_TYPES_B SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      object_version_number = p_loc_type_rec.object_version_number + 1,
      location_type_code = p_loc_type_rec.location_type_code

   WHERE location_type_id = p_loc_type_rec.location_type_id
   AND object_version_number = p_loc_type_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   UPDATE JTF_LOC_TYPES_TL SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      location_type_name = p_loc_type_rec.location_type_name,
      location_type_description = p_loc_type_rec.description,
      source_lang = USERENV('LANG')

   WHERE location_type_id = p_loc_type_rec.location_type_id
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
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

   JTF_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_loc_type;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_loc_type;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_loc_type;
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

END update_loc_type;


/*****************************************************************************/
-- Procedure:
--   check_items
--
-- History
--   11/19/1999    julou      created
-------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode  IN      VARCHAR2,
    x_return_status    OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    p_loc_type_rec     IN      loc_type_rec_type
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

  check_loc_type_req_items
  (
    p_validation_mode => p_validation_mode,
    p_loc_type_rec    => p_loc_type_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check unique key items
    JTF_Utility_PVT.debug_message(l_full_name || ': check uk items');
    check_loc_type_uk_items
    (
      p_validation_mode => p_validation_mode,
      p_loc_type_rec    => p_loc_type_rec,
      x_return_status   => x_return_status
    );

    IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
    END IF;

END check_items;


/*****************************************************************************/
-- Procedure:
--   check_loc_type_req_items
--
-- Hisory
--   11/18/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_loc_type_req_items
(
  p_validation_mode  IN      VARCHAR2,
  p_loc_type_rec     IN      loc_type_rec_type,
  x_return_status    OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check location_type_id
  IF p_loc_type_rec.location_type_id IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_TYPE_NO_TYPE_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;

  END IF;

-- check object_version_number
  IF p_loc_type_rec.object_version_number IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_API_NO_OBJ_VER_NUM');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check location_type_code
  IF p_loc_type_rec.location_type_code IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_TYPE_NO_TYPE_CODE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;

  END IF;

-- check location_type_name
  IF p_loc_type_rec.location_type_name IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_TYPE_NO_TYPE_NAME');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;

  END IF;

END check_loc_type_req_items;


/*****************************************************************************/
-- Procedure:
--   check_loc_type_uk_items
--
-- History
--   11/18/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_loc_type_uk_items
(
  p_validation_mode  IN      VARCHAR2,
  p_loc_type_rec     IN      loc_type_rec_type,
  x_return_status    OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

  l_uk_flag    VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

  l_uk_flag := JTF_Utility_PVT.check_uniqueness
                 (
                   'JTF_LOC_TYPES_TL',
                   'location_type_id <> ' || p_loc_type_rec.location_type_id
                   || ' AND location_type_name = ''' || p_loc_type_rec.location_type_name
                   || ''' AND language = ''' || USERENV('LANG') ||''''
                 );

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('JTF', 'JTF_LOC_TYPE_DUP_NAME_LANG');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_loc_type_uk_items;

END JTF_Loc_Types_PVT;

/
