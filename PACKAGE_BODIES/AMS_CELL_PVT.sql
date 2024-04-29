--------------------------------------------------------
--  DDL for Package Body AMS_CELL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CELL_PVT" AS
/* $Header: amsvcelb.pls 120.3 2006/05/03 04:05:42 aanjaria noship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='AMS_CELL_PVT';


---------------------------------------------------------------------
-- PROCEDURE
--    create_cell
--
-- HISTORY
--    12/15/99  mpande  Created.
--    01/19/01  yxliu   modified, add field "sel_type" to cell_rec_type
--    04/16/01  yxliu   modified, add column country
--    11/02/05  musman  fixed bug: 4695424
---------------------------------------------------------------------
PROCEDURE create_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_rec          IN  cell_rec_type,
   x_cell_id           OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'create_cell';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);
   l_cell_rec       cell_rec_type := p_cell_rec;
   l_cell_count     NUMBER;

   CURSOR c_cell_seq IS
   SELECT ams_cells_all_b_s.NEXTVAL
     FROM DUAL;

   CURSOR c_cell_count(p_cell_id IN NUMBER) IS
   SELECT COUNT(*)
     FROM ams_cells_vl ACV
    WHERE ACV.cell_id = p_cell_id;

    CURSOR c_default_cell_user_status_id IS
       SELECT user_status_id
       FROM ams_user_statuses_vl
       WHERE system_status_type = 'AMS_LIST_SEGMENT_STATUS'
       AND system_status_code = 'DRAFT'
       AND enabled_flag = 'Y'
       AND default_flag = 'Y';

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_cell;

   AMS_Utility_PVT.debug_message(l_full_name||': start');

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


   OPEN c_default_cell_user_status_id;
      FETCH c_default_cell_user_status_id INTO l_cell_rec.user_status_id;
      CLOSE c_default_cell_user_status_id;

   ----------------------- validate -----------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': validate');

   validate_cell(
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_cell_rec           => l_cell_rec
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- try to generate a unique id from the sequence
    IF l_cell_rec.cell_id IS NULL THEN
   LOOP

--   dbms_output.put_line('CELL ID = ' ||l_cell_rec.cell_id);
        OPEN c_cell_seq;
        FETCH c_cell_seq INTO l_cell_rec.cell_id;
        CLOSE c_cell_seq;
  --      l_cell_count := 0;
      OPEN c_cell_count(l_cell_rec.cell_id);
      FETCH c_cell_count INTO l_cell_count;
      CLOSE c_cell_count;
--   dbms_output.put_line('CELL ID = ' ||l_cell_rec.cell_id || ' Count = ' || l_cell_count);
      EXIT WHEN l_cell_count = 0;
   END LOOP;
   END IF;

   -------------------------- insert --------------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': insert');
      AMS_Utility_PVT.debug_message('CELLiD' ||l_cell_rec.cell_id);

   INSERT INTO ams_cells_all_b(
      cell_id,
      sel_type,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      cell_code,
      MARKET_SEGMENT_FLAG,
      ENABLED_FLAG,
      ORIGINAL_SIZE,
      PARENT_CELL_ID,
      owner_id,
      ORG_ID,
      user_status_id,
      status_code,
      status_date,
      country
    )
    VALUES(
      l_cell_rec.cell_id,
      l_cell_rec.sel_type,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,  -- object_version_number
      l_cell_rec.cell_code,
      'Y', -- always to be true for segment
      NVL(l_cell_rec.enabled_flag,'Y'),
      l_cell_rec.ORIGINAL_SIZE  ,
      l_cell_rec.PARENT_CELL_ID,
      l_cell_rec.owner_id,--FND_GLOBAL.user_id,
      TO_NUMBER(SUBSTRB(userenv('CLIENT_INFO'),1,10)),
      NVL(l_cell_rec.user_status_id, 400),
      NVL(l_cell_rec.status_code, 'DRAFT'),
      SYSDATE,
      FND_PROFILE.value ('AMS_SRCGEN_USER_CITY')
   );

   INSERT INTO ams_cells_all_tl(
      cell_id,
      language,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      source_lang,
      cell_name,
      description
   )
   SELECT
      l_cell_rec.cell_id,
      l.language_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      USERENV('LANG'),
      l_cell_rec.cell_name,
      l_cell_rec.description
   FROM fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND NOT EXISTS(
         SELECT NULL
         FROM ams_cells_all_tl t
         WHERE t.cell_id = l_cell_rec.cell_id
         AND t.language = l.language_code );

   --dbms_output.put_line('returen status is: ' || x_return_status);
   ------------------------- finish -------------------------------
   x_cell_id := l_cell_rec.cell_id;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_cell;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_cell;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO create_cell;
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
END create_cell;


---------------------------------------------------------------
-- PROCEDURE
--    delete_cell
--
-- HISTORY
--    12/15/99  mpande  Created.
---------------------------------------------------------------
PROCEDURE delete_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_cell';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_cell;

   AMS_Utility_PVT.debug_message(l_full_name||': start');

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
   AMS_Utility_PVT.debug_message(l_full_name ||': delete');

        UPDATE ams_cells_all_b
      SET enabled_flag = 'N'
    WHERE cell_id = p_cell_id
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

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_cell;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_cell;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_cell;
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

END delete_cell;


-------------------------------------------------------------------
-- PROCEDURE
--    lock_cell
--
-- HISTORY
--    12/15/99  mpande  Created.
--------------------------------------------------------------------
PROCEDURE lock_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'lock_cell';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_cell_id      NUMBER;

   CURSOR c_cell_b IS
   SELECT cell_id
     FROM ams_cells_all_b
    WHERE cell_id = p_cell_id
      AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

   CURSOR c_cell_tl IS
   SELECT cell_id
     FROM ams_cells_all_tl
    WHERE cell_id = p_cell_id
      AND USERENV('LANG') IN (language, source_lang)
   FOR UPDATE NOWAIT;

BEGIN

   -------------------- initialize ------------------------
   AMS_Utility_PVT.debug_message(l_full_name||': start');

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
   AMS_Utility_PVT.debug_message(l_full_name||': lock');

   OPEN c_cell_b;
   FETCH c_cell_b INTO l_cell_id;
   IF (c_cell_b%NOTFOUND) THEN
      CLOSE c_cell_b;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_cell_b;

   OPEN c_cell_tl;
   CLOSE c_cell_tl;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

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

END lock_cell;


---------------------------------------------------------------------
-- PROCEDURE
--    update_cell
--
-- HISTORY
--    12/15/99  mpande  Created.
--    01/21/01  yxliu   Added sel_type
--    10/23/01  yxliu   owner_id can be changed
----------------------------------------------------------------------
PROCEDURE update_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_rec          IN  cell_rec_type
)
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_cell';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_cell_rec       cell_rec_type;
   l_return_status  VARCHAR2(1);

BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT update_cell;

   AMS_Utility_PVT.debug_message(l_full_name||': start');

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
   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   AMS_Utility_PVT.debug_message(l_full_name ||': just before call the complete_cell_rec');

   -- replace g_miss_char/num/date with current column values
   complete_cell_rec(p_cell_rec, l_cell_rec);

   AMS_Utility_PVT.debug_message(l_full_name ||': after complete_cell_rec');
   -- item level
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_cell_items(
         p_cell_rec        => l_cell_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- record level
    -------------------------- update --------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': update' ||l_cell_rec.cell_id);

   UPDATE ams_cells_all_b SET
      sel_type = l_cell_rec.sel_type,
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      object_version_number = l_cell_rec.object_version_number + 1,
      cell_code =  l_cell_rec.cell_code,
      enabled_flag = NVL(l_cell_rec.enabled_flag,'Y'),
      parent_cell_id = l_cell_rec.parent_cell_id,
      original_size = l_cell_rec.original_size,
      user_status_id = l_cell_rec.user_status_id,
         status_code = l_cell_rec.status_code,
         status_date = l_cell_rec.status_date,
      owner_id = l_cell_rec.owner_id
   WHERE cell_id = l_cell_rec.cell_id
   AND object_version_number = l_cell_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
         AMS_Utility_PVT.debug_message(l_full_name ||': update b');
      RAISE FND_API.g_exc_error;
   END IF;

   update ams_cells_all_tl set
      cell_name = l_cell_rec.cell_name,
      description = l_cell_rec.description,
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang = USERENV('LANG')
   WHERE cell_id = l_cell_rec.cell_id
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
            AMS_Utility_PVT.debug_message(l_full_name ||': updatetl');
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

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_cell;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_cell;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_cell;
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

END update_cell;


--------------------------------------------------------------------
-- PROCEDURE
--    validate_cell
--
-- HISTORY
--    12/15/99  mpande  Created.
--------------------------------------------------------------------
PROCEDURE validate_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_rec          IN  cell_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_cell';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
   AMS_Utility_PVT.debug_message(l_full_name||': start');

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
   AMS_Utility_PVT.debug_message(l_full_name||': check items');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_cell_items(
         p_cell_rec        => p_cell_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
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

END validate_cell;

---------------------------------------------------------------------
-- PROCEDURE
--    check_cell_req_items
--
-- HISTORY
--    12/15/99  mpande  Created.
--
-- NOTES

---------------------------------------------------------------------
PROCEDURE check_cell_req_items(
   p_cell_rec       IN  cell_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   ------------------------ cell_code --------------------------
   IF p_cell_rec.cell_code IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CELL_NO_CODE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   ------------------------ cell_name --------------------------
   IF p_cell_rec.cell_name IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CELL_NO_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END check_cell_req_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_cell_uk_items
--
-- HISTORY
--    12/15/99  mpande  Created.
---------------------------------------------------------------------
PROCEDURE check_cell_uk_items(
   p_cell_rec        IN  cell_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_cell, when cell_id is passed in, we need to
   -- check if this cell_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_cell_rec.cell_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
              'ams_cells_vl',
                'cell_id = ' || p_cell_rec.cell_id
            ) = FND_API.g_false
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CELL_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   -- Check if cell_name is unique. Need to handle create and
   -- update differently.
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_cells_vl',
         'cell_name = ''' || p_cell_rec.cell_name ||''''
      );
   ELSE
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_cells_vl',
         'cell_name = ''' || p_cell_rec.cell_name ||
            ''' AND cell_id <> ' || p_cell_rec.cell_id
      );
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CELL_DUPLICATE_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
   -- Check if cell_code is unique. Need to handle create and
   -- update differently.
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_cells_vl',
         'cell_code = ''' || p_cell_rec.cell_code||''''
      );
   ELSE
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_cells_vl',
         'cell_code = ''' || p_cell_rec.cell_name ||
            ''' AND cell_id <> ' || p_cell_rec.cell_id
      );
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CELL_INVALID_CODE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END check_cell_uk_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_cell_fk_items
--
-- HISTORY
--    12/15/99  mpande  Created.
---------------------------------------------------------------------
PROCEDURE check_cell_fk_items(
   p_cell_rec        IN  cell_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
--------------------ownerid---------------------------
   IF p_cell_rec.owner_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_jtf_rs_emp_v',
            'resource_id',
            p_cell_rec.owner_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CELL_BAD_OWNER_USER_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- parent_cell_id ------------------------
   IF p_cell_rec.parent_cell_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_cells_vl',
            'cell_id',
            p_cell_rec.parent_cell_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CELL_WRONG_PARENT_CELL_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_cell_fk_items;



---------------------------------------------------------------------
-- PROCEDURE
--    check_cell_flag_items
--
-- HISTORY
--    15/12/99  mpande  Created.
---------------------------------------------------------------------
PROCEDURE check_cell_flag_items(
   p_cell_rec        IN  cell_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- enabled_flag ------------------------
   IF p_cell_rec.enabled_flag <> FND_API.g_miss_char
      AND p_cell_rec.enabled_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_cell_rec.enabled_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CELL_WRONG_ENABLED_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


END check_cell_flag_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_cell_hier_items
--
-- HISTORY
--    07/13/01  yxliu  Created.
--    08/28/01  yxliu  Modified, Just grasp active children instead of all.
--
-- Note
--    If want to cancel a segment, need to check all its children are
--    cancelled, or archived too.
---------------------------------------------------------------------
PROCEDURE check_cell_hier_items(
   p_cell_rec        IN  cell_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_active_children_count    NUMBER;
   l_count number;
   cursor c_check_parent(l_id in number,l_child_id in number) is
   select  count(1)
   from ams_cells_all_b
   where cell_id in (select a.cell_id
                     from ams_cells_all_b a
                     connect by prior a.cell_id = a.parent_cell_id
                     start with parent_cell_id = l_id)
   and cell_id = l_child_id ;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- status ------------------------
   IF p_cell_rec.status_code = 'CANCELLED'
   THEN
      SELECT COUNT(*) INTO l_active_children_count
        FROM ams_cells_vl
       WHERE parent_cell_id = p_cell_rec.cell_id
         AND (status_code = 'DRAFT' or status_code = 'AVAILABLE');

      IF l_active_children_count > 0

      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CELL_CANCEL_ERROR');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- Over lapping child --------------------
   IF p_cell_rec.parent_cell_id <> FND_API.g_miss_num
      AND p_cell_rec.parent_cell_id IS NOT NULL
   THEN
      open c_check_parent(p_cell_rec.cell_id,p_cell_rec.parent_cell_id);
      fetch c_check_parent into l_count;
      close c_check_parent;
      IF l_count >  0
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CELL_PARENT_ERROR');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_cell_hier_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_cell_items
--
-- HISTORY
--    12/15/99  mpande  Created.
--    07/13/01  yxliu   Added check_cell_hier_items
---------------------------------------------------------------------
PROCEDURE check_cell_items(
   p_cell_rec        IN  cell_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   check_cell_req_items(
      p_cell_rec       => p_cell_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_cell_uk_items(
      p_cell_rec        => p_cell_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_cell_fk_items(
      p_cell_rec       => p_cell_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_cell_flag_items(
      p_cell_rec        => p_cell_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_cell_hier_items(
      p_cell_rec        => p_cell_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
END check_cell_items;

---------------------------------------------------------------------
-- PROCEDURE
--    init_cell_rec
--
-- HISTORY
--    12/15/99  mpande  Created.
--    08/28/01  yxliu   Add new columns
---------------------------------------------------------------------
PROCEDURE init_cell_rec(
   x_cell_rec  OUT NOCOPY  cell_rec_type
)
IS
BEGIN
-- dbms_output.put_line('init Start');
   x_cell_rec.cell_id := FND_API.g_miss_num;
   x_cell_rec.last_update_date := FND_API.g_miss_date;
   x_cell_rec.last_updated_by := FND_API.g_miss_num;
   x_cell_rec.creation_date := FND_API.g_miss_date;
   x_cell_rec.created_by := FND_API.g_miss_num;
   x_cell_rec.last_update_login := FND_API.g_miss_num;
   x_cell_rec.object_version_number := FND_API.g_miss_num;
   x_cell_rec.parent_cell_id := FND_API.g_miss_num;
   x_cell_rec.cell_code := FND_API.g_miss_char;
   x_cell_rec.original_size := FND_API.g_miss_num;
   x_cell_rec.enabled_flag := FND_API.g_miss_char;
   x_cell_rec.owner_id := FND_API.g_miss_num;
   x_cell_rec.cell_name := FND_API.g_miss_char;
   x_cell_rec.description := FND_API.g_miss_char;
   x_cell_rec.sel_type := FND_API.g_miss_char;
   x_cell_rec.org_id := FND_API.g_miss_num;
   x_cell_rec.status_code := FND_API.g_miss_char;
   x_cell_rec.status_date := FND_API.g_miss_date;
   x_cell_rec.user_status_id := FND_API.g_miss_num;

-- dbms_output.put_line('init End');
END init_cell_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    complete_cell_rec
--
-- HISTORY
--    12/15/99  mpande  Created.
---------------------------------------------------------------------
PROCEDURE complete_cell_rec(
   p_cell_rec      IN  cell_rec_type,
   x_complete_rec  OUT NOCOPY cell_rec_type
)
IS

   CURSOR c_cell IS
   SELECT *
     FROM ams_cells_vl
    WHERE cell_id = p_cell_rec.cell_id;

   l_cell_rec  c_cell%ROWTYPE;

BEGIN

   x_complete_rec := p_cell_rec;

   OPEN c_cell;
   FETCH c_cell INTO l_cell_rec;
   IF c_cell%NOTFOUND THEN
      CLOSE c_cell;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_cell;

   IF p_cell_rec.owner_id = FND_API.g_miss_num THEN
         x_complete_rec.owner_id := l_cell_rec.owner_id;
   END IF;

   IF p_cell_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_cell_rec.enabled_flag;
   END IF;

   IF p_cell_rec.original_size = FND_API.g_miss_num THEN
       x_complete_rec.original_size := l_cell_rec.original_size;
   END IF;

   IF p_cell_rec.cell_code = FND_API.g_miss_char THEN
      x_complete_rec.cell_code := l_cell_rec.cell_code;
   END IF;

   IF p_cell_rec.parent_cell_id = FND_API.g_miss_num THEN
      x_complete_rec.parent_cell_id:= l_cell_rec.parent_cell_id;
   END IF;


   IF p_cell_rec.cell_name = FND_API.g_miss_char THEN
      x_complete_rec.cell_name := l_cell_rec.cell_name;
   END IF;

   IF p_cell_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_cell_rec.description;
   END IF;

   IF p_cell_rec.sel_type = FND_API.g_miss_char THEN
      x_complete_rec.sel_type := l_cell_rec.sel_type;
   END IF;

   IF p_cell_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := l_cell_rec.user_status_id;
   END IF;

   IF p_cell_rec.status_date = FND_API.g_miss_date THEN
      x_complete_rec.status_date := l_cell_rec.status_date;
   END IF;

   x_complete_rec.status_code := AMS_Utility_PVT.get_system_status_code(
      x_complete_rec.user_status_id );


END complete_cell_rec;

---------------------------------------------------------------------
-- PROCEDURE
--    add_sel_workbook
--
-- HISTORY
--    01/19/01  yxliu  Created.
---------------------------------------------------------------------
PROCEDURE add_sel_workbook(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   p_discoverer_sql_id IN  NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'add_sel_workbook';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);

   l_cell_id              NUMBER    := p_cell_id;
   l_discoverer_sql_id    NUMBER    := p_discoverer_sql_id;
   l_act_disc_id          NUMBER;

   l_sql_string     VARCHAR2(32767)    := '';
   l_from_position        NUMBER     := 0;

   CURSOR c_discoverer_cell is
     SELECT workbook_owner_name, workbook_name, worksheet_name
       FROM ams_discoverer_sql
      WHERE discoverer_sql_id = l_discoverer_sql_id;

   l_discoverer_cell_rec c_discoverer_cell%ROWTYPE;

   CURSOR c_discoverer_sql (p_workbook_name IN VARCHAR2,
                                        p_worksheet_name IN VARCHAR2,
                                        p_workbook_owner_name IN VARCHAR2) IS
     SELECT sql_string, sequence_order
          FROM ams_discoverer_sql
         WHERE workbook_name = p_workbook_name
           AND worksheet_name = p_worksheet_name
        AND workbook_owner_name = p_workbook_owner_name
         ORDER BY sequence_order;

   l_discoverer_sql_rec c_discoverer_sql%ROWTYPE;

   cursor c_act_disc_seq is
        select ams_act_discoverer_all_s.NEXTVAL
          from DUAL;
BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT add_sel_workbook;

   AMS_Utility_PVT.debug_message(l_full_name||': start');

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

   ------------------------ start -------------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': start');

   OPEN c_discoverer_cell;
   FETCH c_discoverer_cell INTO l_discoverer_cell_rec;
   IF c_discoverer_cell%NOTFOUND THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_discoverer_cell;

   ------------------ Verify the sql string --------------
   -- Verify that the sql string in this workbook is a valid cell sql string,
   -- e.g., there is party_id in the select column.

   AMS_Utility_PVT.debug_message(l_full_name ||': get SQL string');
   OPEN c_discoverer_sql (l_discoverer_cell_rec.workbook_name,
                          l_discoverer_cell_rec.worksheet_name,
                          l_discoverer_cell_rec.workbook_owner_name);
   FETCH c_discoverer_sql INTO l_discoverer_sql_rec;
   WHILE c_discoverer_sql%FOUND
   LOOP
     l_sql_string := l_sql_string || l_discoverer_sql_rec.sql_string;
--     dbms_output.put_line('sequence_order is ' ||
--                          l_discoverer_sql_rec.sequence_order);
     FETCH c_discoverer_sql INTO l_discoverer_sql_rec;
   END LOOP;
   CLOSE c_discoverer_sql;

   l_sql_string := upper(l_sql_string);

   -- find ' from ' position
   IF instr(l_sql_string, ' FROM ') > 0
   THEN
      l_from_position := instr(l_sql_string, ' FROM ');
   ELSIF instr(l_sql_string, FND_GLOBAL.LOCAL_CHR(10)||'FROM ') > 0
   THEN
      l_from_position := instr(l_sql_string, FND_GLOBAL.LOCAL_CHR(10)||'FROM ');
   ELSIF instr(l_sql_string, ' FROM'||FND_GLOBAL.LOCAL_CHR(10)) > 0
   THEN
      l_from_position := instr(l_sql_string, ' FROM'||FND_GLOBAL.LOCAL_CHR(10));
   ELSIF instr(l_sql_string, FND_GLOBAL.LOCAL_CHR(10)||'FROM'||FND_GLOBAL.LOCAL_CHR(10)) >0
   THEN
      l_from_position := instr(l_sql_string, FND_GLOBAL.LOCAL_CHR(10)||'FROM'||FND_GLOBAL.LOCAL_CHR(10));
   END IF;

   IF instr(l_sql_string, 'PARTY_ID') = 0
      OR l_from_position = 0
      OR instr(l_sql_string, 'PARTY_ID') > l_from_position
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CELL_INVALID_SQL');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
 --     x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;


   -- Don't support "order by" and "group by" in query
   -- Check if query has these clauses
   IF instr(l_sql_string, 'ORDER BY') > 0
      OR instr(l_sql_string, 'GROUP BY') > 0
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CELL_INVALID_ORDERBY');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
 --     x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;


   ----------------------- Insert ---------------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': insert');

   OPEN c_act_disc_seq;
   FETCH c_act_disc_seq INTO l_act_disc_id;
   CLOSE c_act_disc_seq;

   INSERT INTO ams_act_discoverer_all(
      activity_discoverer_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      workbook_name,
      workbook_owner,
      act_discoverer_used_by_id,
      arc_act_discoverer_used_by,
      discoverer_sql_id,
      worksheet_name
   )
   VALUES(
      l_act_disc_id,
      SYSDATE,
      FND_GLOBAL.user_id,
         SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,
      l_discoverer_cell_rec.workbook_name,
      l_discoverer_cell_rec.workbook_owner_name,
      l_cell_id,
      'CELL',
      l_discoverer_sql_id,
      l_discoverer_cell_rec.worksheet_name
      );


   ------------------------- finish -------------------------------

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO add_sel_workbook;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO add_sel_workbook;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO add_sel_workbook;
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

END add_sel_workbook;

---------------------------------------------------------------------
-- PROCEDURE
--    add_sel_sql
--
-- HISTORY
--    02/02/01  yxliu  Created.
--    04/10/01  yxliu  Modified. Use AMS_List_Query_PVT.Create_List_Query.
---------------------------------------------------------------------
PROCEDURE add_sel_sql(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   p_cell_name         IN  VARCHAR2,
   p_cell_code         IN  VARCHAR2,
   p_sql_string        IN  VARCHAR2,
   p_source_object_name IN VARCHAR2
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'add_sel_sql';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);

   l_sql_string  VARCHAR2(20000) := p_sql_string;

   l_list_query_rec  AMS_List_Query_PVT.list_query_rec_type := AMS_List_Query_PVT.g_miss_list_query_rec;
   l_list_query_id   NUMBER := FND_API.G_MISS_NUM;

   l_from_position   NUMBER := 0;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT add_sel_sql;

   AMS_Utility_PVT.debug_message(l_full_name||': initialize');

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

   ------------------------ start -------------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': start');

   ------------------ Verify the sql string --------------
   -- Verify that the l_sql_string is a valid cell sql string,
   -- e.g., there is party_id in the select column.

   AMS_Utility_PVT.debug_message(l_full_name ||': get SQL string');

   l_sql_string := upper(l_sql_string);

   IF instr(l_sql_string, ' FROM ') > 0
   THEN
      l_from_position := instr(l_sql_string, ' FROM ');
   ELSIF instr(l_sql_string, FND_GLOBAL.LOCAL_CHR(10)||'FROM ') > 0
   THEN
      l_from_position := instr(l_sql_string, FND_GLOBAL.LOCAL_CHR(10)||'FROM ');
   ELSIF instr(l_sql_string, ' FROM'||FND_GLOBAL.LOCAL_CHR(10)) > 0
   THEN
      l_from_position := instr(l_sql_string, ' FROM'||FND_GLOBAL.LOCAL_CHR(10));
   ELSIF instr(l_sql_string, FND_GLOBAL.LOCAL_CHR(10)||'FROM'||FND_GLOBAL.LOCAL_CHR(10)) >0
   THEN
      l_from_position := instr(l_sql_string, FND_GLOBAL.LOCAL_CHR(10)||'FROM'||FND_GLOBAL.LOCAL_CHR(10));
   END IF;

   IF instr(l_sql_string, 'PARTY_ID') = 0
      OR instr(l_sql_string, 'PARTY_ID', 1, 1) > l_from_position
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CELL_INVALID_SQL');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
      RETURN;
   END IF;

   IF instr(l_sql_string, 'ORDER BY') > 0
      OR instr(l_sql_string, 'GROUP BY') > 0
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CELL_INVALID_ORDERBY');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
 --     x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   ----------------------- Insert ---------------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': Create_List_Query');

   l_list_query_rec.name := p_cell_name;
   l_list_query_rec.type := p_cell_code;
   l_list_query_rec.sql_string := p_sql_string;
   l_list_query_rec.source_object_name := p_source_object_name;
   l_list_query_rec.primary_key := 'PARTY_ID';
   l_list_query_rec.act_list_query_used_by_id := p_cell_id;
   l_list_query_rec.arc_act_list_query_used_by := 'CELL';

   AMS_List_Query_PVT.Create_List_Query(
         p_api_version_number        => l_api_version,
         p_init_msg_list      => p_init_msg_list,
         p_commit             => p_commit,
         p_validation_level   => p_validation_level,
         x_return_status      => l_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_list_query_rec     => l_list_query_rec,
         x_list_query_id      => l_list_query_id
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   ------------------------- finish -------------------------------

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO add_sel_sql;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO add_sel_sql;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO add_sel_sql;
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

END add_sel_sql;


---------------------------------------------------------------------
-- PROCEDURE
--    get_single_sql
--
-- HISTORY
--    01/17/01  yxliu  Created.
---------------------------------------------------------------------
PROCEDURE get_single_sql(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   x_sql_string        OUT NOCOPY VARCHAR2
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'get_single_sql';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);

   l_cell_id     NUMBER := p_cell_id;
   l_sel_type        VARCHAR2(30);
   l_sql_string  VARCHAR2(20000) := '';

   CURSOR c_act_discoverer (p_cell_id IN NUMBER) IS
   SELECT workbook_name, worksheet_name, workbook_owner
     FROM ams_act_discoverer_all
    WHERE arc_act_discoverer_used_by = 'CELL'
      AND act_discoverer_used_by_id = p_cell_id;

   l_act_discoverer_rec c_act_discoverer%ROWTYPE;

   CURSOR c_discoverer_sql (p_workbook_name IN VARCHAR2,
                            p_worksheet_name IN VARCHAR2,
                            p_workbook_owner_name IN VARCHAR2) IS
   SELECT sql_string, sequence_order
     FROM ams_discoverer_sql
    WHERE workbook_name = p_workbook_name
         AND worksheet_name = p_worksheet_name
         AND workbook_owner_name = p_workbook_owner_name
    ORDER BY sequence_order;

   l_discoverer_sql_rec c_discoverer_sql%ROWTYPE;

BEGIN

   --------------------- initialize -----------------------

   AMS_Utility_PVT.debug_message(l_full_name||': start');

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
   x_sql_string := '';

   ---------------------- get sel type --------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': get sel type');

   SELECT sel_type into l_sel_type
     FROM ams_cells_all_b
    WHERE cell_id = l_cell_id;

   ------------------- get sql string ---------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': get sql string');

   IF upper(l_sel_type) = 'DIWB' THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': get workbook');
      OPEN c_act_discoverer (l_cell_id);
      FETCH c_act_discoverer INTO l_act_discoverer_rec;
      CLOSE c_act_discoverer;

      AMS_Utility_PVT.debug_message(l_full_name ||': get SQL string');
      OPEN c_discoverer_sql (l_act_discoverer_rec.workbook_name,
                             l_act_discoverer_rec.worksheet_name,
                                            l_act_discoverer_rec.workbook_owner);
      FETCH c_discoverer_sql INTO l_discoverer_sql_rec;
      WHILE c_discoverer_sql%FOUND
      LOOP
        l_sql_string := l_sql_string || l_discoverer_sql_rec.sql_string;
        --dbms_output.put_line('sequence_order is ' ||
           --                        l_discoverer_sql_rec.sequence_order);
           --dbms_output.put('sql string is: ' || l_sql_string);
           FETCH c_discoverer_sql INTO l_discoverer_sql_rec;
      END LOOP;
      CLOSE c_discoverer_sql;

   ELSIF upper(l_sel_type) = 'SQL' THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': get SQL string');
      SELECT query INTO l_sql_string
        FROM ams_list_queries_all
       WHERE upper(arc_act_list_query_used_by) = 'CELL'
         AND act_list_query_used_by_id = l_cell_id;
   END IF;

   ------------------------- finish -------------------------------
   x_sql_string := l_sql_string;

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN NO_DATA_FOUND THEN
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

END get_single_sql;

---------------------------------------------------------------------
-- PROCEDURE
--    get_comp_sql
--
-- HISTORY
--    01/18/01  yxliu  Created.
---------------------------------------------------------------------
PROCEDURE get_comp_sql(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   p_party_id_only     IN  VARCHAR2  := FND_API.g_false,
   x_sql_tbl           OUT NOCOPY DBMS_SQL.VARCHAR2S
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'get_comp_sql';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status      VARCHAR2(1);

   l_cell_id            NUMBER := p_cell_id;
   l_parent_cell_id     NUMBER;
   l_temp_cell_id       NUMBER;
   l_sql_string         VARCHAR2(32767) := '';
   l_sql_string1         VARCHAR2(32767) := '';

   l_parent_sql_string  VARCHAR2(32767) := '';
   l_parent_sql_string1  VARCHAR2(32767) := '';

   l_count              NUMBER;
   l_length             NUMBER;
   l_string_copy        VARCHAR2(32767);
   l_sql_cur            NUMBER;

   l_party_id_string    VARCHAR2(32767) := '';

BEGIN

   --------------------- initialize -----------------------

   AMS_Utility_PVT.debug_message(l_full_name||': start');

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
   x_sql_tbl(1) := '';

   ---------- get sql string for current cell ------------
   AMS_Utility_PVT.debug_message(l_full_name ||': get sql string for current cell');
   get_single_sql(
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_cell_id            => l_cell_id,
      x_sql_string         => l_sql_string
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   -- if we only need party_id column for the current cell sql
   IF FND_API.to_boolean(p_party_id_only) THEN
         l_sql_string1 := l_sql_string;
         format_sql_string(l_sql_string1, l_sql_string,l_party_id_string);
   END IF;

   AMS_Utility_PVT.debug_message(l_full_name ||'- l_sql_string from formatSql:'||l_sql_string);
   AMS_Utility_PVT.debug_message(l_full_name ||'- l_party_id_string from formatSql:'||l_party_id_string);

   ---------- put sql string into sql table ------------
   AMS_Utility_PVT.debug_message(l_full_name ||': put sql string into sql table');

   l_count := 0;
   l_string_copy := l_sql_string;
   l_length := length(l_string_copy);

   LOOP
      l_count := l_count + 1;
      IF l_length < 255 THEN
         x_sql_tbl(l_count) := l_string_copy;
         EXIT;
      ELSE
         x_sql_tbl(l_count) := substr(l_string_copy, 1, 255);
         l_string_copy := substr(l_string_copy, 256);
      END IF;
      l_length := length(l_string_copy);
   END LOOP;

   ---------- get sql string for parent cell -------------
   SELECT parent_cell_id INTO l_parent_cell_id
     FROM ams_cells_all_b
    WHERE cell_id = l_cell_id;

   WHILE l_parent_cell_id is not NULL
   LOOP

      AMS_Utility_PVT.debug_message(l_full_name ||': get sql string for parent cell');
      get_single_sql(
         p_api_version        => l_api_version,
         p_init_msg_list      => p_init_msg_list,
         p_validation_level   => p_validation_level,
         x_return_status      => l_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_cell_id            => l_parent_cell_id,
         x_sql_string         => l_parent_sql_string
      );

      AMS_Utility_PVT.debug_message(l_full_name ||': return status from get single sql'|| x_return_status);

      IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- manipulate parent cell's sql string
      l_parent_sql_string1 := l_parent_sql_string;
      format_sql_string(l_parent_sql_string1, l_parent_sql_string);
      IF instr(upper(l_sql_string), 'WHERE') > 0 THEN
         --l_parent_sql_string := ' AND PARTY_ID IN (' || l_parent_sql_string || ')';
         l_parent_sql_string := ' AND '|| l_party_id_string ||' IN (' || l_parent_sql_string || ')';
      ELSE
         l_parent_sql_string := ' WHERE PARTY_ID IN (' || l_parent_sql_string || ')';
      END IF;

      AMS_Utility_PVT.debug_message(l_full_name || ':parent sql string ' || l_parent_sql_string);

      -- put parent cell's sql into sql table
      l_string_copy := l_parent_sql_string;
      l_length := length(l_string_copy);

      LOOP
         l_count := l_count + 1;
         IF l_length < 255 THEN
            x_sql_tbl(l_count) := l_string_copy;
            EXIT;
         ELSE
            x_sql_tbl(l_count) := substr(l_string_copy, 1, 255);
            l_string_copy := substr(l_string_copy, 256);
         END IF;
         l_length := length(l_string_copy);
         END LOOP;

      -- keep going
      l_temp_cell_id := l_parent_cell_id;
      SELECT parent_cell_id INTO l_parent_cell_id
        FROM ams_cells_all_b
       WHERE cell_id = l_temp_cell_id;
   END LOOP;

   ------------------- Parse the result sql ----------------------
   AMS_Utility_PVT.debug_message(l_full_name || ': parse the result sql');

    l_count := x_sql_tbl.first;
  if (l_count is not null) then
    loop
      AMS_Utility_PVT.debug_message(x_sql_tbl(l_count));
      l_count := x_sql_tbl.next(l_count);
      exit when (l_count is null);
    end loop;
  end if;



   IF (DBMS_SQL.IS_Open(l_sql_cur) = FALSE ) THEN
      l_sql_cur := DBMS_SQL.Open_Cursor;
   END IF;
   DBMS_SQL.Parse(l_sql_cur,
                   x_sql_tbl,
                   x_sql_tbl.first,
                   x_sql_tbl.last,
                   FALSE,
                   DBMS_SQL.Native);


   ------------------------- finish -------------------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN NO_DATA_FOUND THEN
      AMS_Utility_PVT.debug_message(l_full_name || ': No Data Found error in get composite sql for cell ' || l_cell_id);
      AMS_Utility_Pvt.Debug_Message(l_full_name || ': Please check if the workbook or sql statement is valid');
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

   WHEN FND_API.g_exc_error THEN
      AMS_Utility_Pvt.Debug_Message(l_full_name ||': Expected error in get composite sql for cell '||l_cell_id);
      AMS_Utility_Pvt.Debug_Message(l_full_name ||': Please check if the workbook or sql statement is valid');

      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      AMS_Utility_Pvt.Debug_Message(l_full_name || ': Unexpected error in get composite sql for cell ' || l_cell_id);
      AMS_Utility_Pvt.Debug_Message(l_full_name || ': Please check if the workbook or sql statement is valid');
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      AMS_Utility_Pvt.Debug_Message(l_full_name ||': Error in get composite sql for cell ' || l_cell_id);
      AMS_Utility_Pvt.Debug_Message(l_full_name ||': Please check if the workbook or sql statement is valid');
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );



END get_comp_sql;

---------------------------------------------------------------------
-- PROCEDURE
--    format_sql_string
--
-- HISTORY
--    01/18/01  yxliu  Created.
--    07/05/01  yxliu  Modified, remove white space and ; from string end
--    10/18/01  yxliu  Modified. remove upper the original string
---------------------------------------------------------------------

procedure format_sql_string
( p_string         IN  VARCHAR2,
  x_string         OUT NOCOPY VARCHAR2

) IS
   l_party_id_string VARCHAR2(32767);

BEGIN

   format_sql_string (p_string,x_string,l_party_id_string);

END;


procedure format_sql_string
( p_string         IN  VARCHAR2,
  x_string         OUT NOCOPY VARCHAR2,
  x_party_id_string   OUT NOCOPY VARCHAR2
)

IS
  l_string        VARCHAR2(32767) := p_string;
  l_tmp_string    VARCHAR2(32767);
  l_pos_party_id  NUMBER;
  l_pos_comma     NUMBER;
  l_pos_space     NUMBER;
  l_party_id_str  VARCHAR2 (100);
  l_api_name    CONSTANT VARCHAR2(30) := 'format_sql_string';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

    AMS_Utility_PVT.debug_message(l_full_name||': start');
  --l_string := upper(l_string);

  -- if there are redundant white space at end of the string, remove it
  l_string := rtrim(l_string);

  -- if there is ";" at the end of the string, remove it.
  IF instr(l_string, ';') = length(l_string)
  THEN
     l_string := substr(l_string, 1, length(l_string) -1);
  END IF;

  -- if there is no party_id in the select clause, raise exception
  IF instr(upper(l_string), 'PARTY_ID') = 0
     OR instr(upper(l_string), 'PARTY_ID',1,1) > instr(upper(l_string), 'FROM',1,1)
  THEN
     RAISE FND_API.g_exc_unexpected_error;

  ELSIF instr(upper(l_string), '.PARTY_ID') = 0 THEN
  -- simple select ... party_id .... from ...
     x_string := concat('SELECT DISTINCT PARTY_ID ',
                         substr(l_string, instr(upper(l_string), 'FROM')));
     AMS_Utility_PVT.debug_message(l_full_name||':x_string:'||x_string);

     -- bug:4695424 fix, adding the party_id string for where there is no alias
     x_party_id_string :=  'PARTY_ID';
  ELSE
  -- select ... ams_table.party_id ... from ...
     -- get select ... ams_table.party_id
     l_tmp_string := substr(l_string, 1, instr(upper(l_string), '.PARTY_ID')+8);
     -- find the position of comma which is just before ams_table.party_id
     l_pos_comma := instr(l_tmp_string, ',', -1, 1);
     -- find the position of space which is just before ams_table.party_id
        l_pos_space := instr(l_tmp_string, ' ', -1, 1);
     IF l_pos_comma < l_pos_space THEN
           -- get select ... , ams_table.party_id
           -- or select ams_table.party_id ...
        l_party_id_str := substr(l_tmp_string, l_pos_space +1);
        ELSE
           -- get select ... ,ams_table.party_id
           l_party_id_str := substr(l_tmp_string, l_pos_comma + 1);
     END IF;
      AMS_Utility_PVT.debug_message(l_full_name||': l_party_id_str'||l_party_id_str);
       x_party_id_string := l_party_id_str;
       x_string := 'SELECT DISTINCT ' || l_party_id_str || ' '|| substr(l_string, instr(upper(l_string), 'FROM'));
  END IF;

END format_sql_string;

---------------------------------------------------------------------
-- PROCEDURE
--    get_workbook_sql
--
-- HISTORY
--    03/01/2001  yxliu  Created.
---------------------------------------------------------------------
PROCEDURE get_workbook_sql(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_disc_sql_id       IN  NUMBER,
   x_sql_string        OUT NOCOPY VARCHAR2
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'get_workbook_sql';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);

   l_disc_sql_id     NUMBER := p_disc_sql_id;
   l_sql_string  VARCHAR2(20000) := '';

   CURSOR c_discoverer (p_disc_sql_id IN NUMBER) IS
   SELECT workbook_name, worksheet_name, workbook_owner_name
     FROM ams_discoverer_sql
    WHERE discoverer_sql_id = p_disc_sql_id;

   l_discoverer_rec c_discoverer%ROWTYPE;

   CURSOR c_discoverer_sql (p_workbook_name IN VARCHAR2,
                            p_worksheet_name IN VARCHAR2,
                            p_workbook_owner_name IN VARCHAR2) IS
   SELECT sql_string, sequence_order
     FROM ams_discoverer_sql
    WHERE workbook_name = p_workbook_name
         AND worksheet_name = p_worksheet_name
         AND workbook_owner_name = p_workbook_owner_name
    ORDER BY sequence_order;

   l_discoverer_sql_rec c_discoverer_sql%ROWTYPE;

BEGIN

   --------------------- initialize -----------------------

   AMS_Utility_PVT.debug_message(l_full_name||': start');

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
   x_sql_string := '';

   ------------------- get sql string ---------------------

   AMS_Utility_PVT.debug_message(l_full_name ||': get workbook');
   OPEN c_discoverer (l_disc_sql_id);
   FETCH c_discoverer INTO l_discoverer_rec;
   CLOSE c_discoverer;

   AMS_Utility_PVT.debug_message(l_full_name ||': get SQL string');
   OPEN c_discoverer_sql (l_discoverer_rec.workbook_name,
                          l_discoverer_rec.worksheet_name,
                                  l_discoverer_rec.workbook_owner_name);
   FETCH c_discoverer_sql INTO l_discoverer_sql_rec;

   WHILE c_discoverer_sql%FOUND
      LOOP
        l_sql_string := l_sql_string || l_discoverer_sql_rec.sql_string;
          FETCH c_discoverer_sql INTO l_discoverer_sql_rec;
      END LOOP;
      CLOSE c_discoverer_sql;

   ------------------------- finish -------------------------------
   x_sql_string := l_sql_string;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN NO_DATA_FOUND THEN
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

END get_workbook_sql;

---------------------------------------------------------------------
-- PROCEDURE
--    get_segment_size
--
-- DESCRIPTION
--    Dynamically execute the input sql_string to get segment size
--
-- HISTORY
--    03/01/2001  yxliu  Created.
---------------------------------------------------------------------
PROCEDURE get_segment_size(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_sql_string        IN  VARCHAR2,
   x_segment_size              OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'get_segment_size';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);

   l_sql_string  VARCHAR2(32767) := p_sql_string;

   l_party_cur  NUMBER;
   l_dummy      NUMBER;
   l_size       NUMBER;

BEGIN

   --------------------- initialize -----------------------

   AMS_Utility_PVT.debug_message(l_full_name||': start');

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

   ------------------ Validate sql string ----------------------
   AMS_Utility_PVT.debug_message(l_full_name||': validate sql string');

   l_sql_string := upper(l_sql_string);
   IF instr(l_sql_string, 'PARTY_ID') = 0
      OR instr(l_sql_string, 'PARTY_ID', 1, 1) > instr(l_sql_string, 'FROM', 1, 1)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CELL_INVALID_SQL');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
--      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   ------------------- get segment size ---------------------

   AMS_Utility_PVT.debug_message(l_full_name ||': get segment size');

   l_party_cur := DBMS_SQL.OPEN_CURSOR;
   l_sql_string := 'SELECT COUNT(*) FROM (' || l_sql_string || ')';

   DBMS_SQL.PARSE(l_party_cur, l_sql_string, DBMS_SQL.Native);
   DBMS_SQL.DEFINE_COLUMN(l_party_cur, 1, l_size);
   l_dummy := DBMS_SQL.EXECUTE(l_party_cur);
   LOOP
    IF DBMS_SQL.FETCH_ROWS(l_party_cur) > 0 then
       DBMS_SQL.COLUMN_VALUE(l_party_cur, 1, l_size);
       x_segment_size := l_size;
    ELSE
       EXIT;
    END IF;
  END LOOP;

  DBMS_SQL.CLOSE_CURSOR(l_party_cur);

   ------------------------- finish -------------------------------

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN NO_DATA_FOUND THEN
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
END get_segment_size;


---------------------------------------------------------------------
-- PROCEDURE
--    get_comp_segment_size
--
-- DESCRIPTION
--    For input cell_id, get the composite sql string associated to it
--    Then dynamically execute the comp sql to get segment size
--
-- HISTORY
--    04/16/2001  yxliu  Created. using the get_comp_sql to get the segment
--                       size which means segment and all its ancestors'
--                       criteria.
--    08/28/2001  yxliu  Modified. Use count(*) instead of walking through
--                       returned records to get count
---------------------------------------------------------------------
PROCEDURE get_comp_segment_size(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   x_segment_size      OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'get_comp_segment_size';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);

   l_cell_id       NUMBER := p_cell_id;
   l_sql_tbl        DBMS_SQL.varchar2s ;
   l_sql_tbl_new    DBMS_SQL.varchar2s;
   l_segment_size   NUMBER;

   l_temp          NUMBER ;
   l_party_cur     NUMBER ;
   l_dummy         NUMBER ;
   l_count         NUMBER ;

BEGIN

   --------------------- initialize -----------------------

   AMS_Utility_PVT.debug_message(l_full_name||': start');

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

   ------------------ Get comp sql string ----------------------
   AMS_Utility_PVT.debug_message(l_full_name||': get comp sql string');
   AMS_CELL_PVT.get_comp_sql(
        p_api_version        => 1,
        p_init_msg_list      => NULL,
        p_validation_level   => NULL,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_cell_id            => l_cell_id,
        p_party_id_only      => FND_API.g_true,
        x_sql_tbl            => l_sql_tbl
   );

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   ------------------- get segment size ---------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': get segment size');
   AMS_Utility_PVT.debug_message(l_full_name ||': construct new sql');

   l_count := 1 ;
   l_sql_tbl_new(l_count) := 'select count(*) from ( ';
   for i in l_sql_tbl.first .. l_sql_tbl.last
   loop
      l_count := l_count + 1;
      l_sql_tbl_new(l_count) := l_sql_tbl(i);
   end loop;
   l_sql_tbl_new(l_count+1) := ' ) ';

   --  Open the cursor and parse it
   AMS_Utility_PVT.Debug_Message(l_api_name||':  Parse the new sql ');
   IF (DBMS_SQL.Is_Open(l_party_cur) = FALSE) THEN
      l_party_cur := DBMS_SQL.Open_Cursor ;
   END IF;
   DBMS_SQL.Parse(l_party_cur ,
                    l_sql_tbl_new,
                    l_sql_tbl_new.first,
                    l_sql_tbl_new.last,
                    FALSE,
                    DBMS_SQL.Native) ;

--     l_dummy :=  DBMS_SQL.Execute(l_party_cur);
   DBMS_SQL.DEFINE_COLUMN(l_party_cur,1,l_temp);
   l_dummy :=  DBMS_SQL.Execute(l_party_cur);
   AMS_Utility_PVT.Debug_Message(l_api_name||':  Executed the new sql ');

   LOOP
      IF DBMS_SQL.FETCH_ROWS(l_party_cur)>0 THEN
         -- get column values of the row
         DBMS_SQL.COLUMN_VALUE(l_party_cur,1, l_temp);
      ELSE
         EXIT;
      END IF;
   END LOOP;
   l_segment_size := l_temp;
--   dbms_output.put_line('l_segment_size: ' || l_segment_size);

   DBMS_SQL.CLOSE_CURSOR(l_party_cur);

   ------------------------- finish -------------------------------
--   x_segment_size := l_count;
   x_segment_size := l_segment_size;

   AMS_Utility_PVT.debug_message(l_full_name ||': x_segment_size:'||x_segment_size);

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      IF (DBMS_SQL.Is_Open(l_party_cur) = TRUE) THEN
           DBMS_SQL.Close_Cursor(l_party_cur) ;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      IF (DBMS_SQL.Is_Open(l_party_cur) = TRUE) THEN
           DBMS_SQL.Close_Cursor(l_party_cur) ;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      IF (DBMS_SQL.Is_Open(l_party_cur) = TRUE) THEN
           DBMS_SQL.Close_Cursor(l_party_cur) ;
      END IF;
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
END get_comp_segment_size;

---------------------------------------------------------------------
-- PROCEDURE
--    create_sql_cell
--
-- HISTORY
--    03/01/01  yxliu   created, create a segment and add entries into
--                      corresponding mapping tables
---------------------------------------------------------------------
PROCEDURE create_sql_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_sql_cell_rec      IN  sqlcell_rec_type,
   x_cell_id           OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'create_sql_cell';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);
   l_sql_cell_rec   sqlcell_rec_type := p_sql_cell_rec;
   l_cell_rec       cell_rec_type;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_sql_cell;

   AMS_Utility_PVT.debug_message(l_full_name||': start');

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

   ------------------ call create_cell -------------------

   --bmuthukr bug 5130570
   if trim(l_sql_cell_rec.list_sql_string) is null AND l_sql_cell_rec.sel_type = 'SQL' then
      FND_MESSAGE.set_name('AMS', 'AMS_CELL_BLANK_SQL');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   end if;
   --

   AMS_Utility_PVT.debug_message(l_full_name ||': create_cell');

   l_cell_rec.cell_id           := l_sql_cell_rec.cell_id;
   l_cell_rec.sel_type          := l_sql_cell_rec.sel_type;
   l_cell_rec.last_update_date  := l_sql_cell_rec.last_update_date;
   l_cell_rec.last_updated_by   := l_sql_cell_rec.last_updated_by;
   l_cell_rec.creation_date     := l_sql_cell_rec.creation_date;
   l_cell_rec.created_by        := l_sql_cell_rec.created_by;
   l_cell_rec.last_update_login := l_sql_cell_rec.last_update_login;
   l_cell_rec.object_version_number := l_sql_cell_rec.object_version_number;
   l_cell_rec.cell_code         := l_sql_cell_rec.cell_code;
   l_cell_rec.enabled_flag      := l_sql_cell_rec.enabled_flag;
   l_cell_rec.original_size     := l_sql_cell_rec.original_size;
   l_cell_rec.parent_cell_id    := l_sql_cell_rec.parent_cell_id;
   l_cell_rec.org_id            := l_sql_cell_rec.org_id;
   l_cell_rec.owner_id          := l_sql_cell_rec.owner_id;
   l_cell_rec.cell_name         := l_sql_cell_rec.cell_name;
   l_cell_rec.description       := l_sql_cell_rec.description;
   l_cell_rec.status_code       := l_sql_cell_rec.status_code;
   l_cell_rec.status_date       := l_sql_cell_rec.status_date;
   l_cell_rec.user_status_id    := l_sql_cell_rec.user_status_id;


   create_cell(
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      p_commit             => FND_API.g_false,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_cell_rec           => l_cell_rec,
      x_cell_id            => x_cell_id
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --------------------- add selection ----------------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': add selection');
   IF 'DIWB' = upper(l_sql_cell_rec.sel_type)
      AND l_sql_cell_rec.discoverer_sql_id IS NOT NULL THEN
     add_sel_workbook(
        p_api_version        => l_api_version,
        p_init_msg_list      => p_init_msg_list,
        p_commit             => FND_API.g_false,
        p_validation_level   => p_validation_level,
        x_return_status      => l_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_cell_id            => x_cell_id,
        p_discoverer_sql_id  => l_sql_cell_rec.discoverer_sql_id
     );
     IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;
   ELSIF 'SQL' =  upper(l_sql_cell_rec.sel_type) THEN
     add_sel_sql(
        p_api_version        => l_api_version,
        p_init_msg_list      => p_init_msg_list,
        p_commit             => FND_API.g_false,
        p_validation_level   => p_validation_level,
        x_return_status      => l_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_cell_id            => x_cell_id,
        p_cell_name          => l_sql_cell_rec.cell_name,
        p_cell_code          => l_sql_cell_rec.cell_code,
        p_sql_string         => l_sql_cell_rec.list_sql_string,
        p_source_object_name => l_sql_cell_rec.source_object_name
     );
     IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;
   END IF;

   ------------------------- finish -------------------------------

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_sql_cell;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_sql_cell;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO create_sql_cell;
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
END create_sql_cell;

---------------------------------------------------------------------
-- PROCEDURE
--    update_sql_cell
--
-- HISTORY
--    03/01/01  yxliu   created, update the segment and based on the sel_type,
--                      update the corresponding mapping tables
--    04/10/01  yxliu   modified. 1. Use AMS_List_Query_PVT.Update_list_Query
--                      2. Remove the checking for change of sel_type. End user
--                      cannot change sel_type from GUI.
--    04/17/01  yxliu   add verify sql string for update list query
--    08/31/01  yxliu   added source object name for update list sql
--    08/31/01  yxliu   Add get proper FROM position for validate sql string
---------------------------------------------------------------------
PROCEDURE update_sql_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_sql_cell_rec      IN  sqlcell_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_sql_cell';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);
   l_sql_cell_rec   sqlcell_rec_type := p_sql_cell_rec;
   l_cell_rec       cell_rec_type;
   l_sql_string     VARCHAR2(20000);

   l_from_position        NUMBER     := 0;

   CURSOR c_cell IS
   SELECT *
     FROM ams_cells_sel_all_v
    WHERE cell_id = p_sql_cell_rec.cell_id;

   l_sql_cell_rec_old c_cell%ROWTYPE;

   l_list_query_rec  AMS_List_Query_PVT.list_query_rec_type;
   l_object_version_number NUMBER;
   l_list_object_version_number NUMBER;

   CURSOR c_get_list_query(p_list_query_id NUMBER) IS
      SELECT object_version_number
        FROM AMS_LIST_QUERIES_ALL
       WHERE list_query_id = p_list_query_id;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT update_sql_cell;

   AMS_Utility_PVT.debug_message(l_full_name||': start');

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

   ------------------ call update_cell -------------------

   --bmuthukr bug 5130570
   if trim(l_sql_cell_rec.list_sql_string) is null then
      FND_MESSAGE.set_name('AMS', 'AMS_CELL_BLANK_SQL');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   end if;
   --

   AMS_Utility_PVT.debug_message(l_full_name ||': update_cell');

   l_cell_rec.cell_id           := l_sql_cell_rec.cell_id;
   l_cell_rec.sel_type          := l_sql_cell_rec.sel_type;
   l_cell_rec.last_update_date  := l_sql_cell_rec.last_update_date;
   l_cell_rec.last_updated_by   := l_sql_cell_rec.last_updated_by;
   l_cell_rec.creation_date     := l_sql_cell_rec.creation_date;
   l_cell_rec.created_by        := l_sql_cell_rec.created_by;
   l_cell_rec.last_update_login := l_sql_cell_rec.last_update_login;
   l_cell_rec.object_version_number := l_sql_cell_rec.object_version_number;
   l_cell_rec.cell_code         := l_sql_cell_rec.cell_code;
   l_cell_rec.enabled_flag      := l_sql_cell_rec.enabled_flag;
   l_cell_rec.original_size     := l_sql_cell_rec.original_size;
   l_cell_rec.parent_cell_id    := l_sql_cell_rec.parent_cell_id;
   l_cell_rec.org_id            := l_sql_cell_rec.org_id;
   l_cell_rec.owner_id          := l_sql_cell_rec.owner_id;
   l_cell_rec.cell_name         := l_sql_cell_rec.cell_name;
   l_cell_rec.description       := l_sql_cell_rec.description;
   l_cell_rec.status_code       := l_sql_cell_rec.status_code;
   l_cell_rec.status_date       := l_sql_cell_rec.status_date;
   l_cell_rec.user_status_id    := l_sql_cell_rec.user_status_id;


   update_cell(
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      p_commit             => FND_API.g_false,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_cell_rec           => l_cell_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --------------------- update selection ----------------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': update selection');

   OPEN c_cell;
   FETCH c_cell INTO l_sql_cell_rec_old;
   IF c_cell%NOTFOUND THEN
      CLOSE c_cell;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_cell;

   IF 'DIWB' = upper(l_sql_cell_rec.sel_type) THEN
      IF l_sql_cell_rec.discoverer_sql_id IS NULL AND
         l_sql_cell_rec_old.discoverer_sql_id IS NOT NULL THEN

            DELETE FROM ams_act_discoverer_all
             WHERE act_discoverer_used_by_id = l_sql_cell_rec.cell_id
               AND arc_act_discoverer_used_by = 'CELL';

            IF (SQL%NOTFOUND) THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
                  FND_MSG_PUB.add;
               END IF;
               AMS_Utility_PVT.debug_message(l_full_name ||': delete from ams_act_discoverer_all');
               RAISE FND_API.g_exc_error;
            END IF;
      ELSIF l_sql_cell_rec.discoverer_sql_id IS NOT NULL AND
            l_sql_cell_rec_old.discoverer_sql_id IS NULL THEN

         add_sel_workbook(
             p_api_version        => l_api_version,
             p_init_msg_list      => p_init_msg_list,
             p_commit             => FND_API.g_false,
             p_validation_level   => p_validation_level,
             x_return_status      => l_return_status,
             x_msg_count          => x_msg_count,
             x_msg_data           => x_msg_data,
             p_cell_id            => l_sql_cell_rec.cell_id,
             p_discoverer_sql_id  => l_sql_cell_rec.discoverer_sql_id
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

      ELSIF l_sql_cell_rec.discoverer_sql_id <> l_sql_cell_rec_old.discoverer_sql_id THEN
         -- remove the old workbook relationship
         DELETE FROM ams_act_discoverer_all
          WHERE act_discoverer_used_by_id = l_sql_cell_rec.cell_id
            AND arc_act_discoverer_used_by = 'CELL';

         IF (SQL%NOTFOUND) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
               FND_MSG_PUB.add;
            END IF;
            AMS_Utility_PVT.debug_message(l_full_name ||': delete from ams_act_discoverer_all');
            RAISE FND_API.g_exc_error;
         END IF;
         -- add new workbook relationship
         add_sel_workbook(
             p_api_version        => l_api_version,
             p_init_msg_list      => p_init_msg_list,
             p_commit             => FND_API.g_false,
             p_validation_level   => p_validation_level,
             x_return_status      => l_return_status,
             x_msg_count          => x_msg_count,
             x_msg_data           => x_msg_data,
             p_cell_id            => l_sql_cell_rec.cell_id,
             p_discoverer_sql_id  => l_sql_cell_rec.discoverer_sql_id
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;
      -- end if discoverer_sql_id changed
   ELSIF 'SQL' = upper(l_sql_cell_rec.sel_type) THEN
      l_sql_string := upper(l_sql_cell_rec.list_sql_string);
      -- find ' from ' position
      IF instr(l_sql_string, ' FROM ') > 0
      THEN
         l_from_position := instr(l_sql_string, ' FROM ');
      ELSIF instr(l_sql_string, FND_GLOBAL.LOCAL_CHR(10)||'FROM ') > 0
      THEN
         l_from_position := instr(l_sql_string, FND_GLOBAL.LOCAL_CHR(10)||'FROM ');
      ELSIF instr(l_sql_string, ' FROM'||FND_GLOBAL.LOCAL_CHR(10)) > 0
      THEN
         l_from_position := instr(l_sql_string, ' FROM'||FND_GLOBAL.LOCAL_CHR(10));
      ELSIF instr(l_sql_string, FND_GLOBAL.LOCAL_CHR(10)||'FROM'||FND_GLOBAL.LOCAL_CHR(10)) >0
      THEN
         l_from_position := instr(l_sql_string, FND_GLOBAL.LOCAL_CHR(10)||'FROM'||FND_GLOBAL.LOCAL_CHR(10));
      END IF;

      IF instr(l_sql_string, 'PARTY_ID') = 0
         OR l_from_position = 0
         OR instr(l_sql_string, 'PARTY_ID') > l_from_position
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CELL_INVALID_SQL');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
         RETURN;
      END IF;

      IF instr(l_sql_string, 'ORDER BY') > 0
         OR instr(l_sql_string, 'GROUP BY') > 0
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CELL_INVALID_ORDERBY');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
    --     x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      l_list_query_rec.list_query_id := l_sql_cell_rec.list_query_id;
      l_list_query_rec.name := l_sql_cell_rec.cell_name;
      l_list_query_rec.type := l_sql_cell_rec.cell_code;
      l_list_query_rec.sql_string := l_sql_cell_rec.list_sql_string;
      l_list_query_rec.primary_key := 'PARTY_ID';
      l_list_query_rec.object_version_number := l_sql_cell_rec.list_query_version_number;
      l_list_query_rec.source_object_name := l_sql_cell_rec.source_object_name;

      AMS_UTILITY_PVT.debug_message('l_full_name: update_list_query');

      AMS_List_Query_PVT.Update_List_Query(
            p_api_version_number     => l_api_version,
            p_init_msg_list          => p_init_msg_list,
            p_commit                 => FND_API.g_false,
            p_validation_level       => p_validation_level,
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_list_query_rec         => l_list_query_rec,
            x_object_version_number  => l_object_version_number
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   -- end selection type

   ------------------------- finish -------------------------------

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_sql_cell;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_sql_cell;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_sql_cell;
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
END update_sql_cell;

/*****************************************************************************/
-- Procedure
--   Update_Segment_Size
--
-- Purpose
--   This procedure will calculate the segment size for one cell or all cells.
--   If called to update all cells, one fail will not block the process, but
--   leave the segment size for that cell NULL.
-- Notes
--
--
-- History
--   04/09/2001      yxliu    created
--   04/16/2001      yxliu    modified. use get_comp_segment_size instead.
--   06/20/2001      yxliu    modified the way to update single cell
------------------------------------------------------------------------------
PROCEDURE Update_Segment_Size
(   p_cell_id        IN    NUMBER DEFAULT NULL,
    x_return_status  OUT NOCOPY   VARCHAR2,
    x_msg_count      OUT NOCOPY   NUMBER,
    x_msg_data       OUT NOCOPY   VARCHAR2
)
IS
   l_api_name         CONSTANT VARCHAR2(30) := 'Update_Segment_Size';

   l_return_status    VARCHAR2(1) ;
   l_msg_count        NUMBER ;
   l_msg_data         VARCHAR2(2000);

   l_cell_id          NUMBER  := p_cell_id;
   l_object_version_number        NUMBER;
   l_sql_string       VARCHAR2(20000) := '';
   l_segment_size     NUMBER ;

   t_cell_id                  t_number;
   t_object_version_number    t_number;
   t_segment_size             t_number;

   l_iterator                 NUMBER := 1;

   CURSOR c_all_cell_rec IS
   SELECT cell_id, object_version_number
     FROM ams_cells_vl;

   l_cell_rec cell_rec_type;

BEGIN
  AMS_Utility_PVT.Debug_Message(l_api_name||' Start ');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_cell_id IS NOT NULL
  THEN
     -- Create the Savepoint
     SAVEPOINT Update_Segment_Size;

     -- Update segment size for one particular cell

     -- Calculate segment size
     AMS_Utility_PVT.Debug_Message(l_api_name||' get segment size for cell ' || l_cell_id);
     AMS_CELL_PVT.get_comp_segment_size(
        p_api_version        => 1,
        p_init_msg_list      => FND_API.g_false,
        p_validation_level   => FND_API.g_valid_level_full,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_cell_id            => l_cell_id,
        x_segment_size       => l_segment_size
     );
     IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;

     -- Update cell record
     AMS_Utility_PVT.Debug_Message(l_api_name||' update_cell');

     UPDATE ams_cells_all_b
        SET object_version_number  = object_version_number + 1 ,
              original_size        = l_segment_size
      WHERE cell_id = l_cell_id;

     -- If no errors, commit the work
     COMMIT WORK;
  ELSE
     -- Get all the cells

     -- Create the Savepoint
     SAVEPOINT Update_Segment_Size;

     OPEN c_all_cell_rec;
     LOOP                                -- the loop for all CELL_IDs
       FETCH c_all_cell_rec INTO l_cell_id, l_object_version_number;
       EXIT WHEN c_all_cell_rec%NOTFOUND;

       t_cell_id(l_iterator) := l_cell_id;
       t_object_version_number(l_iterator) := l_object_version_number + 1;


       -- Calculate segment size
       AMS_Utility_PVT.Debug_Message(l_api_name||' get segment size for cell ' || l_cell_id);
       AMS_CELL_PVT.get_comp_segment_size(
             p_api_version        => 1,
             p_init_msg_list      => NULL,
             p_validation_level   => NULL,
             x_return_status      => x_return_status,
             x_msg_count          => x_msg_count,
             x_msg_data           => x_msg_data,
             p_cell_id            => l_cell_id,
             x_segment_size       => l_segment_size
       );
       IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          t_segment_size(l_iterator) := l_segment_size;
       ELSE
          t_segment_size(l_iterator) := null;
          FND_MSG_PUB.count_and_get(
                p_encoded => FND_API.g_false,
                p_count   => x_msg_count,
                p_data    => x_msg_data
          );
       END IF;

       l_iterator := l_iterator + 1;
     END LOOP;                             -- end: the loop for all CELL_IDs
     CLOSE c_all_cell_rec;

     -- Do bulk update
     AMS_Utility_PVT.Debug_Message(l_api_name||' get segment size for cell ');
     FORALL I in t_cell_id.first .. t_cell_id.last
       UPDATE ams_cells_all_b
          SET object_version_number  = t_object_version_number(i) ,
              original_size          = t_segment_size(i)
        WHERE cell_id = t_cell_id(i);

     -- commit;
     COMMIT WORK;
  END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      IF (c_all_cell_rec%ISOPEN) THEN
           close c_all_cell_rec ;
      END IF;
      ROLLBACK TO Update_Segment_Size;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      IF (c_all_cell_rec%ISOPEN) THEN
           close c_all_cell_rec ;
      END IF;
      ROLLBACK TO Update_Segment_Size;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      IF (c_all_cell_rec%ISOPEN) THEN
           close c_all_cell_rec ;
      END IF;
      ROLLBACK TO Update_Segment_Size;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Update_Segment_Size;

/*****************************************************************************/
-- Procedure
--   Refresh_Segment_Size
--
-- Purpose
--   This procedure is created to as a concurrent program which
--   will call the update_segment_size and will return errors if any
--
-- Notes
--
--
-- History
--   04/09/2001      yxliu    created
--   06/20/2001      yxliu    moved to package AMS_Party_Mkt_Seg_Loader_PVT
------------------------------------------------------------------------------

--PROCEDURE Refresh_Segment_Size
--(   errbuf        OUT NOCOPY    VARCHAR2,
--    retcode       OUT    NUMBER,
--    p_cell_id     IN     NUMBER DEFAULT NULL
--)
--IS
--   l_return_status    VARCHAR2(1) ;
--   l_msg_count        NUMBER ;
--   l_msg_data         VARCHAR2(2000);
--BEGIN
--   FND_MSG_PUB.initialize;
--   -- Call the procedure to refresh Segment size
--   Update_Segment_Size
--   (   p_cell_id         =>  p_cell_id,
--       x_return_status   =>  l_return_status,
--       x_msg_count       =>  l_msg_count,
--       x_msg_data        =>  l_msg_data);
--
--   -- Write_log ;
--   Ams_Utility_Pvt.Write_Conc_log ;
--   IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
--      retcode :=0;
--   ELSE
--      retcode  :=1;
--      errbuf  := l_msg_data ;
--   END IF;
--END Refresh_Segment_Size ;

END AMS_cell_PVT;

/
