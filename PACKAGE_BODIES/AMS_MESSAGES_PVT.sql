--------------------------------------------------------
--  DDL for Package Body AMS_MESSAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MESSAGES_PVT" AS
/* $Header: amsvmsgb.pls 115.22 2002/11/15 21:02:26 abhola ship $ */

g_pkg_name      CONSTANT VARCHAR2(30) := 'AMS_Messages_PVT';

/*****************************************************************************/
-- Procedure: create_msg
--
-- History
--   01/04/2000    julou    created
--   11/29/2000    musman   bug 1519059 fix.Changed the cursor in check_uk_items procedure.
-------------------------------------------------------------------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_msg
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_msg_rec             IN      msg_rec_type,
  x_msg_id              OUT NOCOPY     NUMBER
)
IS

  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'create_msg';
  l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status    VARCHAR2(1);
  l_msg_rec          msg_rec_type := p_msg_rec;
  l_msg_count        NUMBER;

  CURSOR c_msg_seq IS
    SELECT AMS_MESSAGES_B_S.NEXTVAL
    FROM DUAL;

  CURSOR c_msg_count(msg_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM AMS_MESSAGES_VL
    WHERE message_id = msg_id;

BEGIN
-- initialize
  SAVEPOINT create_msg;

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
  validate_msg
  (
    p_api_version      => l_api_version,
    p_init_msg_list    => p_init_msg_list,
    p_validation_level => p_validation_level,
    x_return_status    => l_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data,
    p_msg_rec          => l_msg_rec
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

  IF l_msg_rec.message_id IS NULL THEN
    LOOP
      OPEN c_msg_seq;
      FETCH c_msg_seq INTO l_msg_rec.message_id;
      CLOSE c_msg_seq;

      OPEN c_msg_count(l_msg_rec.message_id);
      FETCH c_msg_count INTO l_msg_count;
      CLOSE c_msg_count;

      EXIT WHEN l_msg_count = 0;
    END LOOP;
  END IF;

/*
AMS_ObjectAttribute_PVT.create_object_attributes
  (
    p_api_version      => p_api_version,
    p_init_msg_list    => p_init_msg_list,
    p_validation_level => p_validation_level,
    x_return_status    => x_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data,
    p_object_type      => 'MESG',
    p_object_id        => l_msg_rec.message_id,
    p_setup_id         => 1000
  );
 */

  INSERT INTO AMS_MESSAGES_B
  (
    message_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    object_version_number,
    date_effective_from,
    date_effective_to,
    active_flag,
    message_type_code,
    owner_user_id,
    country_id,
    custom_setup_id,
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
    l_msg_rec.message_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id,
    1,
    l_msg_rec.date_effective_from,
    l_msg_rec.date_effective_to,
    l_msg_rec.active_flag,
    l_msg_rec.message_type_code,
    l_msg_rec.owner_user_id,
    l_msg_rec.country_id,
    1000,
    l_msg_rec.attribute_category,
      l_msg_rec.attribute1,
      l_msg_rec.attribute2,
      l_msg_rec.attribute3,
      l_msg_rec.attribute4,
      l_msg_rec.attribute5,
      l_msg_rec.attribute6,
      l_msg_rec.attribute7,
      l_msg_rec.attribute8,
      l_msg_rec.attribute9,
      l_msg_rec.attribute10,
      l_msg_rec.attribute11,
      l_msg_rec.attribute12,
      l_msg_rec.attribute13,
      l_msg_rec.attribute14,
      l_msg_rec.attribute15
  );

    INSERT INTO AMS_MESSAGES_TL
  (
    message_id,
    language,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    source_lang,
    message_name,
    description
  )
  SELECT
    l_msg_rec.message_id,
    l.language_code,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id,
    USERENV('LANG'),
    l_msg_rec.message_name,
    l_msg_rec.description
  FROM fnd_languages l
  WHERE l.installed_flag in ('I', 'B')
  AND NOT EXISTS
  (
    SELECT NULL
    FROM AMS_MESSAGES_TL t
    WHERE t.message_id = l_msg_rec.message_id
    AND t.language = l.language_code
  );

-- finish
  x_msg_id := l_msg_rec.message_id;

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
      ROLLBACK TO create_msg;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_msg;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO create_msg;
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

END create_msg;


/*****************************************************************************/
-- Procedure: update_msg
--
-- History
--   01/04/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE update_msg
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_msg_rec             IN      msg_rec_type
)
IS

  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'update_msg';
  l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status    VARCHAR2(1);
  l_msg_rec          msg_rec_type := p_msg_rec;

BEGIN

-- initialize
  SAVEPOINT update_msg;

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
  complete_msg_rec
  (
    p_msg_rec,
    l_msg_rec
  );

-- validate
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(l_full_name || ': validate');
    END IF;

    check_items
    (
      p_validation_mode => JTF_PLSQL_API.g_update,
      x_return_status   => l_return_status,
      p_msg_rec         => l_msg_rec
    );

    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
  END IF;
/*
-- complete record
  complete_msg_rec
  (
    p_msg_rec,
    l_msg_rec
  );
*/
-- record level
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(l_full_name||': check record');
    END IF;
    check_record
    (
      p_msg_rec       => p_msg_rec,
      p_complete_rec  => l_msg_rec,
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

  UPDATE AMS_MESSAGES_B SET
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    last_update_login = FND_GLOBAL.conc_login_id,
    object_version_number = l_msg_rec.object_version_number + 1,
    date_effective_from = l_msg_rec.date_effective_from,
    date_effective_to = l_msg_rec.date_effective_to,
    active_flag = l_msg_rec.active_flag,
    message_type_code = l_msg_rec.message_type_code,
    owner_user_id = l_msg_rec.owner_user_id,
     attribute_category = l_msg_rec.attribute_category,
      attribute1 = l_msg_rec.attribute1,
      attribute2 = l_msg_rec.attribute2,
      attribute3 = l_msg_rec.attribute3,
      attribute4 = l_msg_rec.attribute4,
      attribute5 = l_msg_rec.attribute5,
      attribute6 = l_msg_rec.attribute6,
      attribute7 = l_msg_rec.attribute7,
      attribute8 = l_msg_rec.attribute8,
      attribute9 = l_msg_rec.attribute9,
      attribute10 = l_msg_rec.attribute10,
      attribute11 = l_msg_rec.attribute11,
      attribute12 = l_msg_rec.attribute12,
      attribute13 = l_msg_rec.attribute13,
      attribute14 = l_msg_rec.attribute14,
      attribute15 = l_msg_rec.attribute15
  WHERE message_id = l_msg_rec.message_id
  AND object_version_number = l_msg_rec.object_version_number;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  UPDATE AMS_MESSAGES_TL SET
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    last_update_login = FND_GLOBAL.conc_login_id,
    source_lang = USERENV('LANG'),
    message_name = l_msg_rec.message_name,
    description = l_msg_rec.description
  WHERE message_id = l_msg_rec.message_id
  AND USERENV('LANG') IN (language, source_lang);

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
      ROLLBACK TO update_msg;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_msg;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO update_msg;
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

END update_msg;


/*****************************************************************************/
-- Procedure: delete_msg
--
-- History
--   01/04/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE delete_msg
(
  p_api_version       IN      NUMBER,
  P_init_msg_list     IN      VARCHAR2 := FND_API.g_false,
  p_commit            IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY     VARCHAR2,
  x_msg_count         OUT NOCOPY     NUMBER,
  x_msg_data          OUT NOCOPY     VARCHAR2,

  p_msg_id            IN      NUMBER,
  p_object_version    IN      NUMBER
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_msg';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

BEGIN
-- initialize
  SAVEPOINT delete_msg;

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
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': delete');
  END IF;

  DELETE FROM AMS_MESSAGES_TL
  WHERE message_id = p_msg_id;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  DELETE FROM AMS_MESSAGES_B
  WHERE message_id = p_msg_id
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
      ROLLBACK TO delete_msg;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_msg;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO delete_msg;
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

END delete_msg;


/*****************************************************************************/
-- Procedure: lock_msg
--
-- History
--   01/04/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE lock_msg
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_msg_id         IN      NUMBER,
  p_object_version      IN      NUMBER
)
IS

  l_api_version    CONSTANT NUMBER := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'lock_msg';
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_msg_id         NUMBER;

  CURSOR c_msg_b IS
    SELECT message_id
    FROM AMS_MESSAGES_B
    WHERE message_id = p_msg_id
    AND object_version_number = p_object_version
    FOR UPDATE OF message_id NOWAIT;

  CURSOR c_msg_tl IS
    SELECT message_id
    FROM AMS_MESSAGES_TL
    WHERE message_id = p_msg_id
    AND USERENV('LANG') IN (language, source_lang)
    FOR UPDATE OF message_id NOWAIT;

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

  OPEN c_msg_b;
  FETCH c_msg_b INTO l_msg_id;
  IF (c_msg_b%NOTFOUND) THEN
    CLOSE c_msg_b;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_msg_b;

  OPEN c_msg_tl;
  FETCH c_msg_tl INTO l_msg_id;
  IF (c_msg_tl%NOTFOUND) THEN
    CLOSE c_msg_tl;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_msg_tl;

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

END lock_msg;


/*****************************************************************************/
-- PROCEDURE
--    validate_msg
--
-- HISTORY
--    01/04/2000    julou    Created.
--------------------------------------------------------------------
PROCEDURE validate_msg
(
  p_api_version           IN      NUMBER,
  P_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_msg_rec          IN      msg_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_msg';
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
         p_msg_rec         => p_msg_rec
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
      p_msg_rec       => p_msg_rec,
      p_complete_rec  => p_msg_rec,
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

END validate_msg;

/*****************************************************************************/
-- Procedure: check_items
--
-- History
--   01/04/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_items
(
   p_validation_mode    IN      VARCHAR2,
   x_return_status      OUT NOCOPY     VARCHAR2,
   p_msg_rec            IN      msg_rec_type
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
    p_msg_rec         => p_msg_rec,
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
      p_msg_rec         => p_msg_rec,
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
--   01/04/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_msg_rec            IN      msg_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
)
IS

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check message_id
  IF p_msg_rec.message_id IS NULL
  AND p_validation_mode = JTF_PLSQL_API.g_update THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MSG_NO_MSG_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check object_version_number
  IF p_msg_rec.object_version_number IS NULL
    AND p_validation_mode = JTF_PLSQL_API.g_update
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_NO_OBJ_VER_NUM');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check active_flag
  IF p_msg_rec.active_flag IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MSG_BAD_ACTIVE_FLAG');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

  IF p_msg_rec.active_flag <> 'Y'
    AND p_msg_rec.active_flag <> 'N'
    AND p_msg_rec.active_flag <> FND_API.g_miss_char
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MSG_BAD_ACTIVE_FLAG');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check message_name
  IF p_msg_rec.message_name IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MSG_NO_MSG_NAME');
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
--   01/04/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_uk_items
(
  p_validation_mode    IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_msg_rec       IN      msg_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
)
IS

  l_uk_flag    VARCHAR2(1);

  cursor check_name_with_id(l_msg_id IN NUMBER, l_msg_name IN VARCHAR2) IS
	    SELECT  ''
		 FROM AMS_MESSAGES_TL
          WHERE message_id <> l_msg_id
		  AND  message_name = l_msg_name
		  AND  language = USERENV('LANG');


  cursor check_name_without_id(l_msg_name IN VARCHAR2) IS
	    SELECT  ''
		 FROM AMS_MESSAGES_TL
          WHERE  message_name = l_msg_name
		  AND  language = USERENV('LANG');
  l_dummy VARCHAR2(1);
  l_flag  VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check PK, if message_id is passed in, must check if it is duplicate
  IF p_validation_mode = JTF_PLSQL_API.g_create
    AND p_msg_rec.message_id IS NOT NULL
  THEN
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
		   'AMS_MESSAGES_VL',
		   'message_id = ' || p_msg_rec.message_id
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)	THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MSG_DUPLICATE_MSG_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check message_name, language
  /********
  IF p_msg_rec.message_id IS NOT NULL THEN
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
                   'AMS_MESSAGES_TL',
                   'message_id<> ' || p_msg_rec.message_id
                   || ' AND message_name =  '''
                   || p_msg_rec.message_name
                   || ''' AND language = ''' || USERENV('LANG') || ''''
                 );
  ELSE
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
                   'AMS_MESSAGES_TL',
                   'message_name = ''' || p_msg_rec.message_name
                   ||''' AND language = ''' || USERENV('LANG') || ''''
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_MSG_DUP_NAME_LANG');
      FND_MSG_PUB.add;
    END IF;

 ***************/
   l_flag := 'N';

   IF p_msg_rec.message_id IS NOT NULL THEN
     OPEN check_name_with_id(p_msg_rec.message_id,p_msg_rec.message_name);
     FETCH check_name_with_id INTO l_dummy;
	  IF (check_name_with_id%FOUND)  THEN
		l_flag := 'Y';
       END IF;
     CLOSE check_name_with_id;
   ELSE
	OPEN check_name_without_id(p_msg_rec.message_name);
	FETCH check_name_without_id INTO l_dummy;
	  if (check_name_without_id%FOUND) then
		 l_flag := 'Y';
       end if;
     CLOSE check_name_without_id;

   END IF;

   IF ( l_flag = 'Y')  THEN
	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	    FND_MESSAGE.set_name('AMS', 'AMS_MSG_DUP_NAME_LANG');
	    FND_MSG_PUB.add;
      END IF;
    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_uk_items;


/*****************************************************************************/
-- PROCEDURE
--    check_record
--
-- HISTORY
--    01/04/2000    julou    Created.
-------------------------------------------------------------------------------
PROCEDURE check_record
(
  p_msg_rec          IN  msg_rec_type,
  p_complete_rec     IN  msg_rec_type,
  x_return_status    OUT NOCOPY VARCHAR2
)
IS

   l_date_from  DATE;
   l_date_to    DATE;

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

  -- check that date_effective_from <= date_effective_to
  IF p_complete_rec.date_effective_from <> FND_API.g_miss_date
    AND p_complete_rec.date_effective_from IS NOT NULL
    AND p_complete_rec.date_effective_to <> FND_API.g_miss_date
    AND p_complete_rec.date_effective_to IS NOT NULL
  THEN
    l_date_from := p_complete_rec.date_effective_from;
    l_date_to := p_complete_rec.date_effective_to;
    IF l_date_from > l_date_to THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_MESG_INVALID_DATES');
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
--   01/04/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE complete_msg_rec
(
  p_msg_rec         IN      msg_rec_type,
  x_complete_rec    OUT NOCOPY     msg_rec_type
)
IS

  CURSOR c_msg IS
    SELECT * FROM AMS_MESSAGES_VL
    WHERE message_id = p_msg_rec.message_id;

  l_msg_rec     c_msg%ROWTYPE;

BEGIN

  x_complete_rec := p_msg_rec;

  OPEN c_msg;
  FETCH c_msg INTO l_msg_rec;
  IF (c_msg%NOTFOUND) THEN
    CLOSE c_msg;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_msg;

  IF p_msg_rec.date_effective_from = FND_API.g_miss_date THEN
    x_complete_rec.date_effective_from := l_msg_rec.date_effective_from;
  END IF;

  IF p_msg_rec.date_effective_to = FND_API.g_miss_date THEN
    x_complete_rec.date_effective_to := l_msg_rec.date_effective_to;
  END IF;

  IF p_msg_rec.active_flag = FND_API.g_miss_char THEN
    x_complete_rec.active_flag := l_msg_rec.active_flag;
  END IF;

  IF p_msg_rec.message_name = FND_API.g_miss_char THEN
    x_complete_rec.message_name := l_msg_rec.message_name;
  END IF;

  IF p_msg_rec.description = FND_API.g_miss_char THEN
    x_complete_rec.description := l_msg_rec.description;
  END IF;

  IF p_msg_rec.owner_user_id = FND_API.g_miss_num THEN
    x_complete_rec.owner_user_id := l_msg_rec.owner_user_id;
  END IF;

  IF p_msg_rec.message_type_code = FND_API.g_miss_char THEN
    x_complete_rec.message_type_code := l_msg_rec.message_type_code;
  END IF;

END complete_msg_rec;


/****************************************************************************/
-- Procedure
--   init_rec
--
-- HISTORY
--    01/04/2000    julou    Created.
------------------------------------------------------------------------------
PROCEDURE init_rec
(
  x_msg_rec  OUT NOCOPY  msg_rec_type
)
IS

BEGIN

  x_msg_rec.message_id := FND_API.g_miss_num;
  x_msg_rec.country_id := FND_API.g_miss_num;
  x_msg_rec.last_update_date := FND_API.g_miss_date;
  x_msg_rec.last_updated_by := FND_API.g_miss_num;
  x_msg_rec.creation_date := FND_API.g_miss_date;
  x_msg_rec.created_by := FND_API.g_miss_num;
  x_msg_rec.last_update_login := FND_API.g_miss_num;
  x_msg_rec.object_version_number := FND_API.g_miss_num;
  x_msg_rec.date_effective_from := FND_API.g_miss_date;
  x_msg_rec.date_effective_to := FND_API.g_miss_date;
  x_msg_rec.active_flag := 'Y';
  x_msg_rec.message_type_code := FND_API.g_miss_char;
  x_msg_rec.owner_user_id := FND_API.g_miss_num;
  x_msg_rec.message_name := FND_API.g_miss_char;
  x_msg_rec.description := FND_API.g_miss_char;

END init_rec;

END AMS_Messages_PVT;

/
