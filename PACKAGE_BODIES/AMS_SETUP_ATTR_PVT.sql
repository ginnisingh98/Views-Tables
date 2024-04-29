--------------------------------------------------------
--  DDL for Package Body AMS_SETUP_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SETUP_ATTR_PVT" AS
/* $Header: amsvattb.pls 115.30 2003/03/11 06:39:08 cgoyal ship $ */

g_pkg_name      CONSTANT VARCHAR2(30) := 'AMS_Setup_Attr_PVT';

/*****************************************************************************/
-- Procedure: create_setup_attr
--
-- History
--   12/1/1999    julou    created
-------------------------------------------------------------------------------
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean  := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_setup_attr
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER :=FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_setup_attr_rec      IN      setup_attr_rec_type,
  x_setup_attr_id       OUT NOCOPY     NUMBER
)
IS

  l_api_version         CONSTANT NUMBER := 1.0;
  l_api_name            CONSTANT VARCHAR2(30) := 'create_setup_attr';
  l_full_name           CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status       VARCHAR2(1);
  l_setup_attr_rec      setup_attr_rec_type := p_setup_attr_rec;
  l_setup_attr_count    NUMBER;

  CURSOR c_setup_attr_seq IS
    SELECT AMS_CUSTOM_SETUP_ATTR_S.NEXTVAL
    FROM DUAL;

  CURSOR c_setup_attr_count(setup_attr_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM AMS_CUSTOM_SETUP_ATTR
    WHERE setup_attribute_id = setup_attr_id;

BEGIN
-- initialize
  SAVEPOINT create_setup_attr;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name || ': start');

  END IF;

/*  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name
  )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
*/

  x_return_status := FND_API.g_ret_sts_success;

-- validate
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(l_full_name || ': validate');
    END IF;

    validate_setup_attr
    (
      p_api_version      => l_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_setup_attr_rec   => l_setup_attr_rec
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

  IF l_setup_attr_rec.setup_attribute_id IS NULL THEN
    LOOP
      OPEN c_setup_attr_seq;
      FETCH c_setup_attr_seq INTO l_setup_attr_rec.setup_attribute_id;
      CLOSE c_setup_attr_seq;

      OPEN c_setup_attr_count(l_setup_attr_rec.setup_attribute_id);
      FETCH c_setup_attr_count INTO l_setup_attr_count;
      CLOSE c_setup_attr_count;

      EXIT WHEN l_setup_attr_count = 0;
    END LOOP;
  END IF;

  INSERT INTO AMS_CUSTOM_SETUP_ATTR
  (
    setup_attribute_id,
    custom_setup_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    object_version_number,
    last_update_login,
    display_sequence_no,
    object_attribute,
    attr_mandatory_flag,
    attr_available_flag,
    function_name,
    parent_function_name,
    parent_setup_attribute,
    parent_display_sequence,
    show_in_report,
    show_in_cue_card,
    copy_allowed_flag,
    related_ak_attribute,
    essential_seq_num
  )
  VALUES
  (
    l_setup_attr_rec.setup_attribute_id,
    l_setup_attr_rec.custom_setup_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    1,
    FND_GLOBAL.conc_login_id,
    l_setup_attr_rec.display_sequence_no,
    l_setup_attr_rec.object_attribute,
    l_setup_attr_rec.attr_mandatory_flag,
    NVL(l_setup_attr_rec.attr_available_flag,'Y'),
    l_setup_attr_rec.function_name,
    l_setup_attr_rec.parent_function_name,
    l_setup_attr_rec.parent_setup_attribute,
    l_setup_attr_rec.parent_display_sequence,
    nvl(l_setup_attr_rec.show_in_report,'Y'),
    nvl(l_setup_attr_rec.show_in_cue_card,'Y'),
    nvl(l_setup_attr_rec.copy_allowed_flag,'N'),
    l_setup_attr_rec.related_ak_attribute,
    l_setup_attr_rec.essential_seq_num
  );

-- finish
  x_setup_attr_id := l_setup_attr_rec.setup_attribute_id;

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
      ROLLBACK TO create_setup_attr;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_setup_attr;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO create_setup_attr;
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

END create_setup_attr;


/*****************************************************************************/
-- Procedure: update_setup_attr
--
-- History
--   12/1/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE update_setup_attr
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_setup_attr_rec      IN      setup_attr_rec_type
)
IS

  l_api_version       CONSTANT NUMBER := 1.0;
  l_api_name          CONSTANT VARCHAR2(30) := 'update_setup_attr';
  l_full_name         CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status     VARCHAR2(1);
  l_setup_attr_rec    setup_attr_rec_type := p_setup_attr_rec;

BEGIN

-- initialize
  SAVEPOINT update_setup_attr;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

--  IF (AMS_DEBUG_HIGH_ON) THEN    AMS_Utility_PVT.debug_message(l_full_name || ': start of api');  END IF;

  /***
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
 **/


 --  IF (AMS_DEBUG_HIGH_ON) THEN    AMS_Utility_PVT.debug_message(l_full_name || ': complete ');  END IF;

-- complete record
  complete_setup_attr_rec
  (
    p_setup_attr_rec,
    l_setup_attr_rec
  );

-- validate
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_Utility_PVT.debug_message(l_full_name || ': validate'); END IF;

    check_items
    (
      p_validation_mode  => JTF_PLSQL_API.g_update,
      x_return_status    => l_return_status,
      p_setup_attr_rec   => l_setup_attr_rec
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

  UPDATE AMS_CUSTOM_SETUP_ATTR SET
    custom_setup_id  = l_setup_attr_rec.custom_setup_id,
    last_update_date = SYSDATE,
    last_updated_by  = FND_GLOBAL.user_id,
    object_version_number   = l_setup_attr_rec.object_version_number + 1,
    last_update_login       = FND_GLOBAL.conc_login_id,
    display_sequence_no     = l_setup_attr_rec.display_sequence_no,
    object_attribute        = l_setup_attr_rec.object_attribute,
    attr_mandatory_flag     = l_setup_attr_rec.attr_mandatory_flag,
    attr_available_flag     = l_setup_attr_rec.attr_available_flag,
    function_name           = l_setup_attr_rec.function_name,
    parent_function_name    = l_setup_attr_rec.parent_function_name,
    parent_setup_attribute  = l_setup_attr_rec.parent_setup_attribute,
    parent_display_sequence = l_setup_attr_rec.parent_display_sequence,
    show_in_report          = nvl(l_setup_attr_rec.show_in_report,'Y'),
    related_ak_attribute    = l_setup_attr_rec.related_ak_attribute,
    essential_seq_num       = l_setup_attr_rec.essential_seq_num
  WHERE setup_attribute_id = l_setup_attr_rec.setup_attribute_id
  AND object_version_number = l_setup_attr_rec.object_version_number;

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
      ROLLBACK TO update_setup_attr;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_setup_attr;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO update_setup_attr;
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

END update_setup_attr;


/*****************************************************************************/
-- PROCEDURE
--    validate_setup_attr
--
-- HISTORY
--    11/29/99    julou    Created.
--------------------------------------------------------------------
PROCEDURE validate_setup_attr
(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_setup_attr_rec    IN  setup_attr_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_setup_attr';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
-- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_Utility_PVT.debug_message(l_full_name||': start start '); END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

  /** IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
 **/

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
         p_setup_attr_rec  => p_setup_attr_rec
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

END validate_setup_attr;


/*****************************************************************************/
-- Procedure: check_items
--
-- History
--   12/1/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode    IN      VARCHAR2,
    x_return_status      OUT NOCOPY     VARCHAR2,
    p_setup_attr_rec     IN      setup_attr_rec_type
)
IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'check items';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

BEGIN
-- initialize
--  IF (AMS_DEBUG_HIGH_ON) THEN    AMS_Utility_PVT.debug_message(l_full_name || ': start');  END IF;

  x_return_status := FND_API.g_ret_sts_success;

-- check required items
--   IF (AMS_DEBUG_HIGH_ON) THEN      AMS_Utility_PVT.debug_message(l_full_name || ': check required items');   END IF;
  check_setup_attr_req_items
  (
    p_validation_mode => p_validation_mode,
    p_setup_attr_rec  => p_setup_attr_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check unique key items
--  IF (AMS_DEBUG_HIGH_ON) THEN    AMS_Utility_PVT.debug_message(l_full_name || ': check uk items');  END IF;
/*
  check_setup_attr_uk_items
  (
    p_setup_attr_rec  => p_setup_attr_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;
*/
-- check foreign key items
--  IF (AMS_DEBUG_HIGH_ON) THEN    AMS_Utility_PVT.debug_message(l_full_name || ': check fk items');  END IF;
  check_setup_attr_fk_items
  (
    p_setup_attr_rec  => p_setup_attr_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check flag items
--  IF (AMS_DEBUG_HIGH_ON) THEN    AMS_Utility_PVT.debug_message(l_full_name || ': check flag items');  END IF;
  check_setup_attr_flag_items
  (
    p_setup_attr_rec  => p_setup_attr_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

END check_items;


/*****************************************************************************/
-- Procedure: check_setup_attr_req_items
--
-- History
--   12/1/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_setup_attr_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_setup_attr_rec     IN      setup_attr_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
)
IS

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check setup_attribute_id
  IF p_setup_attr_rec.setup_attribute_id IS NULL
  AND p_validation_mode = JTF_PLSQL_API.g_update THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATT_NO_SETUP_ATT_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check object_version_number
  IF p_setup_attr_rec.object_version_number IS NULL
    AND p_validation_mode = JTF_PLSQL_API.g_update
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_NO_OBJ_VER_NUM');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check custom_setup_id
  IF p_setup_attr_rec.custom_setup_id IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATT_NO_CUS_SETUP_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check display_sequence_no
  IF p_setup_attr_rec.display_sequence_no IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATT_NO_DIS_SEQ_NO');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check object_attribute
  IF p_setup_attr_rec.object_attribute IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CUS_SETUP_NO_OBJ_ATTR');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check attr_mandatory_flag
  IF p_setup_attr_rec.attr_mandatory_flag IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
    -- Change message here from Mandatory to Essential
      FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATT_NO_ATT_ESS_FLAG');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- Put the check for the essential seq num here
  IF (nvl(p_setup_attr_rec.attr_mandatory_flag, 'N') = 'Y' AND
    p_setup_attr_rec.essential_seq_num IS NULL) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATT_NO_ESS_SEQ_NUM');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check attr_available_flag
  IF p_setup_attr_rec.attr_available_flag IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATT_NO_ATT_AVAL_FLAG');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_setup_attr_req_items;


/*****************************************************************************/
-- Procedure: check_setup_attr_uk_items
--
-- History
--   11/29/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_setup_attr_uk_items
(
  p_validation_mode    IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_setup_attr_rec     IN      setup_attr_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
)
IS

  l_uk_flag    VARCHAR2(1);
  l_dummy      NUMBER;

  CURSOR c_ess_seq_exists(seq_num_in IN NUMBER, id_in IN NUMBER, setup_id_in IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM   ams_custom_setup_attr
            WHERE  custom_setup_id = id_in
            AND essential_seq_num = seq_num_in
	    AND setup_attribute_id <> setup_id_in
            );
BEGIN

  --  IF (AMS_DEBUG_HIGH_ON) THEN    AMS_Utility_PVT.debug_message(' UK Check ');  END IF;

  x_return_status := FND_API.g_ret_sts_success;

-- check PK, if custom_setup_id is passed in, must check if it is duplicate

/***

IF p_validation_mode = JTF_PLSQL_API.g_create
    AND p_setup_attr_rec.setup_attribute_id IS NOT NULL
  THEN
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
		   'AMS_CUSTOM_SETUP_ATTR',
		   'setup_attribute_id = ' || p_setup_attr_rec.setup_attribute_id
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)	THEN
      FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATTR_DUPLICATE_ID');
      FND_MSG_PUB.add;
    END IF;


    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;
*****/

   IF p_validation_mode = Jtf_Plsql_Api.g_create
      THEN
      OPEN c_ess_seq_exists (p_setup_attr_rec.essential_seq_num,
                 p_setup_attr_rec.custom_setup_id,
		 p_setup_attr_rec.setup_attribute_id);
      FETCH  c_ess_seq_exists INTO l_dummy;
      CLOSE  c_ess_seq_exists;

      IF l_dummy = 1 THEN
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
      THEN
            Fnd_Message.set_name('AMS', 'AMS_ESSENTIAL_DUP_SEQ');
            Fnd_Msg_Pub.ADD;
            x_return_status := Fnd_Api.g_ret_sts_error;
            RETURN;
          END IF;
      END IF;
   END IF;

END check_setup_attr_uk_items;


/*****************************************************************************/
-- Procedure: check_setup_attr_fk_items
--
-- History
--   12/1/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_setup_attr_fk_items
(
  p_setup_attr_rec    IN      setup_attr_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
)
IS

  l_fk_flag       VARCHAR2(1);

BEGIN

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(' FK Check ');

  END IF;
  x_return_status := FND_API.g_ret_sts_success;

  l_fk_flag := AMS_Utility_PVT.check_fk_exists
                 (
                   'AMS_CUSTOM_SETUPS_B',
                   'custom_setup_id',
                   p_setup_attr_rec.custom_setup_id
                 );

  IF l_fk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATTR_BAD_CUS_SET_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_setup_attr_fk_items;


/*****************************************************************************/
-- Procedure: check_setup_attr_flag_items
--
-- History
--   12/1/1999    julou    created
--   29-Dec-2000  ptendulk 1.Added Additional cursor to get the object details
--                         from ams_custom_setups_vl
--                         2.Check Mandatory flag for object type and activity
--                         type
--   19-OCT-2001  julou    modified. fix for bug 2064453
--                         added cursor to check mandatory flag for setup with
--                         no activity type.
--
-- Note
--   Desc of the fix done by ptendulk on 29 Dec
--   Current code check for mandatory flag for attribute instead of checking for
--   object or attribute. Due to this when the custom setup is created for Events
--   cost and metric is not mandatory but when query selects for the attribute,
--   it selects for campaign, and it gives Mandatory flag as Y and creation
--   errors out for events (It copies attribute till cost)
-------------------------------------------------------------------------------
PROCEDURE check_setup_attr_flag_items
(
  p_setup_attr_rec    IN      setup_attr_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
)
IS

  CURSOR c_mand_flag1 (obj_attr IN VARCHAR2,l_obj_type IN VARCHAR2,
                      l_act_type IN VARCHAR2) IS
    SELECT mandatory_flag FROM AMS_SETUP_TYPES
    WHERE setup_attribute = obj_attr
    -- Following lines are added by ptendulk on 29th Dec
    AND object_type = l_obj_type
    AND activity_type_code = l_act_type ;
    -- cursor added by julou 19-OCT-2001
    CURSOR c_mand_flag2 (obj_attr IN VARCHAR2,l_obj_type IN VARCHAR2) IS
    SELECT mandatory_flag FROM AMS_SETUP_TYPES
    WHERE setup_attribute = obj_attr
    -- Following lines are added by ptendulk on 29th Dec
    AND object_type = l_obj_type
    AND activity_type_code IS NULL ;

-- Following code is added by ptendulk on 29 Dec
  CURSOR c_cus_det IS
    SELECT object_type,activity_type_code
    FROM   ams_custom_setups_vl
    WHERE  custom_setup_id = p_setup_attr_rec.custom_setup_id ;

-- Added by cgoyal on 06/Feb/2002 for bugfix 2178381
  CURSOR c_mand_setup_attr (obj_attr IN VARCHAR2) IS
    SELECT MEANING FROM AMS_LOOKUPS WHERE LOOKUP_TYPE = 'AMS_SYS_ARC_QUALIFIER' AND LOOKUP_CODE = obj_attr;
  l_mand_setup_attr_rec  c_mand_setup_attr%ROWTYPE;
-- End add by cgoyal

  l_obj  VARCHAR2(30) ;
  l_act  VARCHAR2(30) ;

  l_mand_flag    VARCHAR2(1);
  l_mand_setup_attr AMS_LOOKUPS.meaning%type;

BEGIN
  x_return_status := FND_API.g_ret_sts_success;
  l_mand_setup_attr := NULL;
  IF p_setup_attr_rec.attr_mandatory_flag NOT IN ('Y','N',FND_API.g_miss_char,NULL)
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      -- Added by cgoyal on 06/Feb/2002 for bugfix 2178381
      IF l_mand_setup_attr IS NULL THEN
	   OPEN c_mand_setup_attr (p_setup_attr_rec.object_attribute);
           FETCH c_mand_setup_attr
           INTO l_mand_setup_attr_rec;
           IF (c_mand_setup_attr%NOTFOUND) THEN
               CLOSE c_mand_setup_attr;
               l_mand_setup_attr := NULL;
           ELSE
               l_mand_setup_attr := l_mand_setup_attr_rec.meaning;
               CLOSE c_mand_setup_attr;
           END IF;
      END IF;
      FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATTR_INVALID_ESS_FLG');
      FND_MESSAGE.set_token('ESS_SETUP_ATTR', l_mand_setup_attr);
      -- End Add by cgoyal
      FND_MSG_PUB.add;
    END IF;
    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

  IF p_setup_attr_rec.attr_available_flag NOT IN ('Y','N',FND_API.g_miss_char,NULL)
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      -- Added by cgoyal on 06/Feb/2002 for bugfix 2178381
      IF l_mand_setup_attr IS NULL THEN
	OPEN c_mand_setup_attr (p_setup_attr_rec.object_attribute);
	FETCH c_mand_setup_attr
	INTO l_mand_setup_attr_rec;
	IF (c_mand_setup_attr%NOTFOUND) THEN
		CLOSE c_mand_setup_attr;
		l_mand_setup_attr := NULL;
	ELSE
          	l_mand_setup_attr := l_mand_setup_attr_rec.meaning;
		CLOSE c_mand_setup_attr;
	END IF;
	FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATTR_INVALID_AVL_FLG');
	FND_MESSAGE.set_token('MAND_SETUP_ATTR', l_mand_setup_attr);
	-- End Add by cgoyal
	FND_MSG_PUB.add;
      END IF;
    END IF;
    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

  -- start of code modified by ptendulk on 29th Dec
  OPEN c_cus_det ;
  FETCH c_cus_det INTO l_obj,l_act ;
  CLOSE c_cus_det ;

  IF l_act IS NOT NULL THEN
    OPEN c_mand_flag1(p_setup_attr_rec.object_attribute,l_obj,l_act);
    FETCH c_mand_flag1 INTO l_mand_flag;
    CLOSE c_mand_flag1;
  ELSE -- no activity_type_code, added by julou 19-OCT-2001
    OPEN c_mand_flag2(p_setup_attr_rec.object_attribute,l_obj);
    FETCH c_mand_flag2 INTO l_mand_flag;
    CLOSE c_mand_flag2;
  END IF;
  -- End of code modified by ptendulk on 29th Dec.

  IF (p_setup_attr_rec.OBJECT_ATTRIBUTE = 'DETL') AND (p_setup_attr_rec.attr_mandatory_flag <> 'Y') THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        -- Added by cgoyal on 06/Feb/2002 for bugfix 2178381
	IF l_mand_setup_attr IS NULL THEN
	   OPEN c_mand_setup_attr (p_setup_attr_rec.object_attribute);
	   FETCH c_mand_setup_attr
	   INTO l_mand_setup_attr_rec;
	   IF (c_mand_setup_attr%NOTFOUND) THEN
	       CLOSE c_mand_setup_attr;
	       l_mand_setup_attr := NULL;
	   ELSE
	       l_mand_setup_attr := l_mand_setup_attr_rec.meaning;
	       CLOSE c_mand_setup_attr;
	   END IF;
	END IF;
        FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATTR_BAD_ESS_FLAG');
        FND_MESSAGE.set_token('ESS_SETUP_ATTR', l_mand_setup_attr);
	-- End Add by cgoyal
	FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
  END IF;

  IF l_mand_flag = 'Y' THEN
    IF p_setup_attr_rec.attr_available_flag <> 'Y' THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	-- Added by cgoyal on 06/Feb/2002 for bugfix 2178381
	IF l_mand_setup_attr IS NULL THEN
	   OPEN c_mand_setup_attr (p_setup_attr_rec.object_attribute);
	   FETCH c_mand_setup_attr
	   INTO l_mand_setup_attr_rec;
	   IF (c_mand_setup_attr%NOTFOUND) THEN
	       CLOSE c_mand_setup_attr;
	       l_mand_setup_attr := NULL;
	   ELSE
	       l_mand_setup_attr := l_mand_setup_attr_rec.meaning;
	       CLOSE c_mand_setup_attr;
	   END IF;
	END IF;
        FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATTR_BAD_AVAL_FLAG');
	FND_MESSAGE.set_token('MAND_SETUP_ATTR', l_mand_setup_attr);
	-- End Add by cgoyal
	FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

  IF p_setup_attr_rec.attr_mandatory_flag = 'Y'
    AND p_setup_attr_rec.attr_available_flag <> 'Y'
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	-- Added by cgoyal on 06/Feb/2002 for bugfix 2178381
	IF l_mand_setup_attr IS NULL THEN
	   OPEN c_mand_setup_attr (p_setup_attr_rec.object_attribute);
	   FETCH c_mand_setup_attr
	   INTO l_mand_setup_attr_rec;
	   IF (c_mand_setup_attr%NOTFOUND) THEN
	       CLOSE c_mand_setup_attr;
	       l_mand_setup_attr := NULL;
	   ELSE
	       l_mand_setup_attr := l_mand_setup_attr_rec.meaning;
	       CLOSE c_mand_setup_attr;
	   END IF;
	END IF;
	FND_MESSAGE.set_name('AMS', 'AMS_SETUP_ATTR_BAD_AVAL_FLAG');
	FND_MESSAGE.set_token('MAND_SETUP_ATTR', l_mand_setup_attr);
	-- End Add by cgoyal
	FND_MSG_PUB.add;
    END IF;
    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_setup_attr_flag_items;


/*****************************************************************************/
-- Procedure: complete_setup_attr_rec
--
-- History
--   12/1/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE complete_setup_attr_rec
(
  p_setup_attr_rec    IN      setup_attr_rec_type,
  x_complete_rec      OUT NOCOPY     setup_attr_rec_type
)
IS

  CURSOR c_setup_attr IS
    SELECT * FROM AMS_CUSTOM_SETUP_ATTR
    WHERE setup_attribute_id = p_setup_attr_rec.setup_attribute_id;

  l_setup_attr_rec     c_setup_attr%ROWTYPE;

BEGIN

  x_complete_rec := p_setup_attr_rec;

  OPEN c_setup_attr;
  FETCH c_setup_attr INTO l_setup_attr_rec;
  IF (c_setup_attr%NOTFOUND) THEN
    CLOSE c_setup_attr;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_setup_attr;

  IF p_setup_attr_rec.display_sequence_no = FND_API.g_miss_num THEN
    x_complete_rec.display_sequence_no := l_setup_attr_rec.display_sequence_no;
  END IF;

  IF p_setup_attr_rec.parent_display_sequence = FND_API.g_miss_num THEN
    x_complete_rec.parent_display_sequence := l_setup_attr_rec.parent_display_sequence;
  END IF;
  IF p_setup_attr_rec.object_attribute = FND_API.g_miss_char THEN
    x_complete_rec.object_attribute := l_setup_attr_rec.object_attribute;
  END IF;

  IF p_setup_attr_rec.attr_mandatory_flag = FND_API.g_miss_char THEN
    x_complete_rec.attr_available_flag := l_setup_attr_rec.attr_available_flag;
  END IF;

  IF p_setup_attr_rec.attr_available_flag = FND_API.g_miss_char THEN
    x_complete_rec.attr_available_flag := l_setup_attr_rec.attr_available_flag;
  END IF;

  IF p_setup_attr_rec.show_in_report = FND_API.g_miss_char THEN
    x_complete_rec.show_in_report := l_setup_attr_rec.show_in_report;
  END IF;

  IF p_setup_attr_rec.copy_allowed_flag = FND_API.g_miss_char THEN
    x_complete_rec.copy_allowed_flag := l_setup_attr_rec.copy_allowed_flag;
  END IF;

  IF p_setup_attr_rec.parent_setup_attribute= FND_API.g_miss_char THEN
    x_complete_rec.parent_setup_attribute := l_setup_attr_rec.parent_setup_attribute;
  END IF;

 IF p_setup_attr_rec.related_ak_attribute = FND_API.g_miss_char THEN
   x_complete_rec.related_ak_attribute := l_setup_attr_rec.related_ak_attribute;
 END IF;

 IF p_setup_attr_rec.parent_function_name = FND_API.g_miss_char THEN
  x_complete_rec.parent_function_name := l_setup_attr_rec.parent_function_name;
 END IF;

 IF p_setup_attr_rec.function_name= FND_API.g_miss_char THEN
   x_complete_rec.function_name := l_setup_attr_rec.function_name;
 END IF;

 IF p_setup_attr_rec.essential_seq_num = FND_API.g_miss_num THEN
   x_complete_rec.essential_seq_num := l_setup_attr_rec.essential_seq_num;
 END IF;

END complete_setup_attr_rec;


/****************************************************************************/
-- Procedure
--   init_rec
--
-- HISTORY
--    12/19/1999    julou    Created.
------------------------------------------------------------------------------
PROCEDURE init_rec
(
  x_setup_attr_rec  OUT NOCOPY  setup_attr_rec_type
)
IS

BEGIN

  x_setup_attr_rec.setup_attribute_id      := FND_API.g_miss_num;
  x_setup_attr_rec.custom_setup_id         := FND_API.g_miss_num;
  x_setup_attr_rec.last_update_date        := FND_API.g_miss_date;
  x_setup_attr_rec.last_updated_by         := FND_API.g_miss_num;
  x_setup_attr_rec.creation_date           := FND_API.g_miss_date;
  x_setup_attr_rec.created_by              := FND_API.g_miss_num;
  x_setup_attr_rec.last_update_login       := FND_API.g_miss_num;
  x_setup_attr_rec.object_version_number   := FND_API.g_miss_num;
  x_setup_attr_rec.display_sequence_no     := FND_API.g_miss_num;
  x_setup_attr_rec.object_attribute        := FND_API.g_miss_char;
  x_setup_attr_rec.attr_mandatory_flag     := FND_API.g_miss_char;
  x_setup_attr_rec.attr_available_flag     := FND_API.g_miss_char;
  x_setup_attr_rec.function_name           := FND_API.g_miss_char;
  x_setup_attr_rec.parent_function_name    := FND_API.g_miss_char;
  x_setup_attr_rec.parent_setup_attribute  := FND_API.g_miss_char;
  x_setup_attr_rec.parent_display_sequence := FND_API.g_miss_num;
  x_setup_attr_rec.show_in_report          := FND_API.g_miss_char;
  x_setup_attr_rec.show_in_cue_card        := FND_API.g_miss_char;
  x_setup_attr_rec.copy_allowed_flag       := FND_API.g_miss_char;
  x_setup_attr_rec.related_ak_attribute    := FND_API.g_miss_char;
  x_setup_attr_rec.essential_seq_num       := FND_API.g_miss_num;

END init_rec;

END AMS_Setup_Attr_PVT;

/
