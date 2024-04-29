--------------------------------------------------------
--  DDL for Package Body AMS_LIST_RULES_ALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_RULES_ALL_PVT" AS
/* $Header: amsvruab.pls 120.0 2005/05/31 14:29:20 appldev noship $ */

g_pkg_name      CONSTANT VARCHAR2(30) := 'AMS_List_Rules_All_PVT';

/*****************************************************************************/
-- Procedure: create_list_rule
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_list_rule
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_list_rule_rec       IN      list_rule_rec_type,
  x_list_rule_id        OUT NOCOPY     NUMBER
)
IS

  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'create_list_rule';
  l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status    VARCHAR2(1);
  l_list_rule_rec    list_rule_rec_type := p_list_rule_rec;
  l_list_rule_count  NUMBER;

  CURSOR c_list_rule_seq IS
    SELECT AMS_LIST_RULES_ALL_S.NEXTVAL
    FROM DUAL;

  CURSOR c_list_rule_count(lst_rule_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM AMS_LIST_RULES_ALL
    WHERE list_rule_id = lst_rule_id;

BEGIN
-- initialize
  SAVEPOINT create_list_rule;

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
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': validate');
  END IF;
  validate_list_rule
  (
    p_api_version      => l_api_version,
    p_init_msg_list    => p_init_msg_list,
    p_validation_level => p_validation_level,
    x_return_status    => l_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data,
    p_list_rule_rec    => l_list_rule_rec
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

  IF l_list_rule_rec.list_rule_id IS NULL THEN
    LOOP
      OPEN c_list_rule_seq;
      FETCH c_list_rule_seq INTO l_list_rule_rec.list_rule_id;
      CLOSE c_list_rule_seq;

      OPEN c_list_rule_count(l_list_rule_rec.list_rule_id);
      FETCH c_list_rule_count INTO l_list_rule_count;
      CLOSE c_list_rule_count;

      EXIT WHEN l_list_rule_count = 0;
    END LOOP;
  END IF;

-- get org_id
  l_list_rule_rec.org_id := TO_NUMBER (SUBSTRB (USERENV ('CLIENT_INFO'), 1, 10));

  INSERT INTO AMS_LIST_RULES_ALL
  (
    list_rule_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    object_version_number,
    list_rule_name,
    weightage_for_dedupe,
    active_from_date,
    active_to_date,
    description,
    org_id,
    list_rule_type
  )
  VALUES
  (
    l_list_rule_rec.list_rule_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id,
    1,
    l_list_rule_rec.list_rule_name,
    l_list_rule_rec.weightage_for_dedupe,
    SYSDATE,
    l_list_rule_rec.active_to_date,
    l_list_rule_rec.description,
    l_list_rule_rec.org_id,
    l_list_rule_rec.list_rule_type
  );

-- finish
  x_list_rule_id := l_list_rule_rec.list_rule_id;

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
      ROLLBACK TO create_list_rule;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_list_rule;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO create_list_rule;
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

END create_list_rule;


/*****************************************************************************/
-- Procedure: update_list_rule
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE update_list_rule
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_list_rule_rec       IN      list_rule_rec_type
)
IS

  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'update_list_rule';
  l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status    VARCHAR2(1);
  l_list_rule_rec    list_rule_rec_type := p_list_rule_rec;

BEGIN

-- initialize
  SAVEPOINT update_list_rule;

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
      p_list_rule_rec     => l_list_rule_rec
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
    p_list_rule_rec,
    l_list_rule_rec
  );

-- record level
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(l_full_name||': check record');
    END IF;
    check_record
    (
      p_list_rule_rec => p_list_rule_rec,
      p_complete_rec  => l_list_rule_rec,
      x_return_status => l_return_status
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

-- get org_id
  l_list_rule_rec.org_id := TO_NUMBER (SUBSTRB (USERENV ('CLIENT_INFO'), 1, 10));

  UPDATE AMS_LIST_RULES_ALL SET
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    last_update_login = FND_GLOBAL.conc_login_id,
    object_version_number = l_list_rule_rec.object_version_number + 1,
    list_rule_name = l_list_rule_rec.list_rule_name,
    weightage_for_dedupe = l_list_rule_rec.weightage_for_dedupe,
    active_from_date = l_list_rule_rec.active_from_date,
    active_to_date = l_list_rule_rec.active_to_date,
    description = l_list_rule_rec.description,
    org_id = l_list_rule_rec.org_id,
    list_rule_type = l_list_rule_rec.list_rule_type
  WHERE list_rule_id = l_list_rule_rec.list_rule_id
  AND object_version_number = l_list_rule_rec.object_version_number;

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
      ROLLBACK TO update_list_rule;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_list_rule;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO update_list_rule;
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

END update_list_rule;


/*****************************************************************************/
-- Procedure: delete_list_rule
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE delete_list_rule
(
  p_api_version       IN      NUMBER,
  p_init_msg_list     IN      VARCHAR2 := FND_API.g_false,
  p_commit            IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY     VARCHAR2,
  x_msg_count         OUT NOCOPY     NUMBER,
  x_msg_data          OUT NOCOPY     VARCHAR2,

  p_list_rule_id      IN      NUMBER,
  p_object_version    IN      NUMBER
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_list_rule';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_list_rule_count  NUMBER;

   CURSOR c_list_rule_count(lst_rule_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM AMS_LIST_RULE_USAGES
    WHERE list_rule_id = lst_rule_id;


BEGIN
-- initialize
  SAVEPOINT delete_list_rule;

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

-- delete
--  IF (AMS_DEBUG_HIGH_ON) THEN    AMS_Utility_PVT.debug_message(l_full_name || ': delete');  END IF;

  OPEN c_list_rule_count(p_list_rule_id);
  FETCH c_list_rule_count INTO l_list_rule_count;
  CLOSE c_list_rule_count;

  IF l_list_rule_count > 0   THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULE_BEING_USED');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  DELETE FROM AMS_LIST_RULES_ALL
  WHERE list_rule_id = p_list_rule_id
  AND object_version_number = p_object_version;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  -- SOLIN, bug 4377845
  --Vbhandar added 05/16/2003 to fix bug 3003409
  DELETE FROM AMS_LIST_RULE_FIELDS
  WHERE list_rule_id = p_list_rule_id;

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
      ROLLBACK TO delete_list_rule;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_list_rule;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO delete_list_rule;
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

END delete_list_rule;


/*****************************************************************************/
-- Procedure: lock_list_rule
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE lock_list_rule
(
  p_api_version       IN      NUMBER,
  p_init_msg_list     IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY     VARCHAR2,
  x_msg_count         OUT NOCOPY     NUMBER,
  x_msg_data          OUT NOCOPY     VARCHAR2,

  p_list_rule_id        IN      NUMBER,
  p_object_version    IN      NUMBER
)
IS

  l_api_version    CONSTANT NUMBER := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'lock_list_rule';
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_list_rule_id   NUMBER;

  CURSOR c_list_rule IS
    SELECT list_rule_id
    FROM AMS_LIST_RULES_ALL
    WHERE list_rule_id = p_list_rule_id
    AND object_version_number = p_object_version
    FOR UPDATE OF list_rule_id NOWAIT;

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

  OPEN c_list_rule;
  FETCH c_list_rule INTO l_list_rule_id;
  IF (c_list_rule%NOTFOUND) THEN
    CLOSE c_list_rule;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_list_rule;

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

END lock_list_rule;


/*****************************************************************************/
-- PROCEDURE
--    validate_list_rule
--
-- HISTORY
--    01/24/2000    julou    Created.
--------------------------------------------------------------------
PROCEDURE validate_list_rule
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_list_rule_rec         IN      list_rule_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_list_rule';
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
         p_list_rule_rec   => p_list_rule_rec
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

  -- record level
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(l_full_name||': check record');
    END IF;
    check_record
    (
      p_list_rule_rec => p_list_rule_rec,
      p_complete_rec  => p_list_rule_rec,
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

END validate_list_rule;

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
    p_list_rule_rec      IN      list_rule_rec_type
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
    p_list_rule_rec   => p_list_rule_rec,
    x_return_status   => x_return_status
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
      p_list_rule_rec   => p_list_rule_rec,
      x_return_status   => x_return_status
    );

    IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
    END IF;

-- check lookup items
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': check lookup items');
  END IF;
  check_lookup_items
  (
    p_list_rule_rec => p_list_rule_rec,
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
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_list_rule_rec      IN      list_rule_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
)
IS

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check list_rule_id
  IF p_list_rule_rec.list_rule_id IS NULL
  AND p_validation_mode = JTF_PLSQL_API.g_update THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULES_ALL_NO_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check object_version_number
  IF p_list_rule_rec.object_version_number IS NULL
    AND p_validation_mode = JTF_PLSQL_API.g_update
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_NO_OBJ_VER_NUM');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check list_rule_name
  IF p_list_rule_rec.list_rule_name IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULES_ALL_NO_NAME');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check weightage_for_dedupe
--commented by vb 08/30/2001 after we made this column nullable
 /* IF p_list_rule_rec.weightage_for_dedupe IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULES_ALL_NO_DEDUPE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check active_from_date
  IF p_list_rule_rec.active_from_date IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULES_ALL_NO_STRT_DT');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;
 */
END check_req_items;


/*****************************************************************************/
-- Procedure: check_uk_items
--
-- History
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_uk_items
(
  p_validation_mode   IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_list_rule_rec     IN      list_rule_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
)
IS

  l_uk_flag    VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check PK, if list_rule_id is passed in, must check if it is duplicate
  IF p_validation_mode = JTF_PLSQL_API.g_create
    AND p_list_rule_rec.list_rule_id IS NOT NULL
  THEN
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
		   'AMS_LIST_RULES_ALL',
		   'list_rule_id = ' || p_list_rule_rec.list_rule_id
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)	THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULES_ALL_NO_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check list_rule_name
  IF p_list_rule_rec.list_rule_id IS NOT NULL THEN
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
                   'AMS_LIST_RULES_ALL',
                   'list_rule_id <> ' || p_list_rule_rec.list_rule_id
                   || ' AND list_rule_name =  ''' || p_list_rule_rec.list_rule_name || ''''
                 );
  ELSE
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
                   'AMS_LIST_RULES_ALL',
                   'list_rule_name = ''' || p_list_rule_rec.list_rule_name || ''''
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_LIST_RULES_ALL_DUP_NAME');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_uk_items;


/*****************************************************************************/
-- Procedure: check_lookup_items
--
-- History
--   01/25/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_lookup_items
(
  p_list_rule_rec   IN  list_rule_rec_type,
  x_return_status   OUT NOCOPY VARCHAR2
)
IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

-- check list_rule_type
   IF p_list_rule_rec.list_rule_type <> FND_API.g_miss_char
     AND p_list_rule_rec.list_rule_type IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
          --  p_lookup_type => 'AMS_LIST_SRC_TYPE',
	     p_lookup_type => 'AMS_LIST_DEDUP_TYPE',
            p_lookup_code => p_list_rule_rec.list_rule_type
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LST_RULE_BAD_LST_RULE_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_lookup_items;


/*****************************************************************************/
-- PROCEDURE
--    check_record
--
-- HISTORY
--    01/24/2000    julou    Created.
-------------------------------------------------------------------------------
PROCEDURE check_record
(
  p_list_rule_rec    IN  list_rule_rec_type,
  p_complete_rec     IN  list_rule_rec_type,
  x_return_status    OUT NOCOPY VARCHAR2
)
IS

   l_from_date  DATE;
   l_to_date    DATE;

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

  -- check that date_effective_from <= date_effective_to
  IF p_complete_rec.active_from_date <> FND_API.g_miss_date
    AND p_complete_rec.active_from_date IS NOT NULL
    AND p_complete_rec.active_to_date <> FND_API.g_miss_date
    AND p_complete_rec.active_to_date IS NOT NULL
  THEN
    l_from_date := p_complete_rec.active_from_date;
    l_to_date := p_complete_rec.active_to_date;
    IF l_from_date > l_to_date THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_DATE_FROM_AFTER_DATE_TO');
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
--   01/24/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE complete_rec
(
  p_list_rule_rec   IN      list_rule_rec_type,
  x_complete_rec    OUT NOCOPY     list_rule_rec_type
)
IS

  CURSOR c_list_rule IS
    SELECT * FROM AMS_LIST_RULES_ALL
    WHERE list_rule_id = p_list_rule_rec.list_rule_id;

  l_list_rule_rec     c_list_rule%ROWTYPE;

BEGIN

  x_complete_rec := p_list_rule_rec;

  OPEN c_list_rule;
  FETCH c_list_rule INTO l_list_rule_rec;
  IF (c_list_rule%NOTFOUND) THEN
    CLOSE c_list_rule;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_list_rule;

  IF p_list_rule_rec.list_rule_name = FND_API.g_miss_char THEN
    x_complete_rec.list_rule_name := l_list_rule_rec.list_rule_name;
  END IF;

  IF p_list_rule_rec.weightage_for_dedupe = FND_API.g_miss_num THEN
    x_complete_rec.weightage_for_dedupe := l_list_rule_rec.weightage_for_dedupe;
  END IF;

  IF p_list_rule_rec.active_from_date = FND_API.g_miss_date THEN
    x_complete_rec.active_from_date := l_list_rule_rec.active_from_date;
  END IF;

  IF p_list_rule_rec.active_to_date = FND_API.g_miss_date THEN
    x_complete_rec.active_to_date := l_list_rule_rec.active_to_date;
  END IF;

  IF p_list_rule_rec.description = FND_API.g_miss_char THEN
    x_complete_rec.description := l_list_rule_rec.description;
  END IF;

  IF p_list_rule_rec.org_id = FND_API.g_miss_num THEN
    x_complete_rec.org_id := l_list_rule_rec.org_id;
  END IF;

  IF p_list_rule_rec.list_rule_type = FND_API.g_miss_char THEN
    x_complete_rec.list_rule_type := l_list_rule_rec.list_rule_type;
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
  x_list_rule_rec  OUT NOCOPY  list_rule_rec_type
)
IS

BEGIN

  x_list_rule_rec.list_rule_id := FND_API.g_miss_num;
  x_list_rule_rec.last_update_date := FND_API.g_miss_date;
  x_list_rule_rec.last_updated_by := FND_API.g_miss_num;
  x_list_rule_rec.creation_date := FND_API.g_miss_date;
  x_list_rule_rec.created_by := FND_API.g_miss_num;
  x_list_rule_rec.last_update_login := FND_API.g_miss_num;
  x_list_rule_rec.object_version_number := FND_API.g_miss_num;
  x_list_rule_rec.list_rule_name := FND_API.g_miss_char;
  x_list_rule_rec.weightage_for_dedupe := FND_API.g_miss_num;
  x_list_rule_rec.active_from_date := FND_API.g_miss_date;
  x_list_rule_rec.active_to_date := FND_API.g_miss_date;
  x_list_rule_rec.description := FND_API.g_miss_char;
  x_list_rule_rec.org_id := FND_API.g_miss_num;
  x_list_rule_rec.list_rule_type := FND_API.g_miss_char;

END init_rec;

END AMS_List_Rules_All_PVT;

/
