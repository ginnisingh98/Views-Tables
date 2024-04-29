--------------------------------------------------------
--  DDL for Package Body AMS_CUST_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CUST_SETUP_PVT" AS
/* $Header: amsvcusb.pls 120.4 2006/03/08 00:51:22 vmodur ship $ */

g_pkg_name      CONSTANT VARCHAR2(30) := 'AMS_Cust_Setup_PVT';

/*****************************************************************************/
-- Procedure: create_cust_setup
--
-- History
--   11/29/1999    julou    created
-------------------------------------------------------------------------------
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean  := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_cust_setup
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_cust_setup_rec      IN      cust_setup_rec_type,
  x_cust_setup_id       OUT NOCOPY     NUMBER
)
IS

  l_api_version         CONSTANT NUMBER := 1.0;
  l_api_name            CONSTANT VARCHAR2(30) := 'create_cust_setup';
  l_full_name           CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status       VARCHAR2(1);
  l_cust_setup_rec      cust_setup_rec_type := p_cust_setup_rec;
  l_cust_setup_count    NUMBER;

  CURSOR c_cust_setup_seq IS
    SELECT AMS_CUSTOM_SETUPS_B_S.NEXTVAL
    FROM DUAL;

  CURSOR c_cust_setup_count(cust_setup_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM AMS_CUSTOM_SETUPS_VL
    WHERE custom_setup_id = cust_setup_id;

BEGIN
-- initialize
  SAVEPOINT create_cust_setup;

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

   validate_cust_setup
   (
      p_api_version      => l_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_cust_setup_rec   => l_cust_setup_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

-- generate an unique ID if it is not parsed in
   IF l_cust_setup_rec.custom_setup_id IS NULL THEN
      LOOP
         OPEN c_cust_setup_seq;
         FETCH c_cust_setup_seq INTO l_cust_setup_rec.custom_setup_id;
         CLOSE c_cust_setup_seq;

         OPEN c_cust_setup_count(l_cust_setup_rec.custom_setup_id);
         FETCH c_cust_setup_count INTO l_cust_setup_count;
         CLOSE c_cust_setup_count;

         EXIT WHEN l_cust_setup_count = 0;
      END LOOP;
   END IF;

-- insert
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': insert');
  END IF;

  INSERT INTO AMS_CUSTOM_SETUPS_B
  (
    custom_setup_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    object_version_number,
    last_update_login,
    activity_type_code,
    media_id,
    enabled_flag,
    allow_essential_grouping,
    usage,
    object_type,
    source_code_suffix,
    application_id
  )
  VALUES
  (
    l_cust_setup_rec.custom_setup_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    1,
    FND_GLOBAL.conc_login_id,
    l_cust_setup_rec.activity_type_code,
    l_cust_setup_rec.media_id,
    NVL(l_cust_setup_rec.enabled_flag,'Y'),
    NVL(l_cust_setup_rec.allow_essential_grouping,'N'),
    l_cust_setup_rec.usage,
    l_cust_setup_rec.object_type,
    l_cust_setup_rec.source_code_suffix,
    l_cust_setup_rec.application_id
  );

  INSERT INTO AMS_CUSTOM_SETUPS_TL
  (
    custom_setup_id,
    language,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    source_lang,
    setup_name,
    description
  )
  SELECT
    l_cust_setup_rec.custom_setup_id,
    l.language_code,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id,
    USERENV('LANG'),
    l_cust_setup_rec.setup_name,
    l_cust_setup_rec.description
  FROM fnd_languages l
  WHERE l.installed_flag in ('I', 'B')
  AND NOT EXISTS
  (
    SELECT NULL
    FROM AMS_CUSTOM_SETUPS_TL t
    WHERE t.custom_setup_id = l_cust_setup_rec.custom_setup_id
    AND t.language = l.language_code
  );

-- finish
  x_cust_setup_id := l_cust_setup_rec.custom_setup_id;

IF l_cust_setup_rec.usage IS NULL  THEN
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
   select ams_custom_setup_attr_s.nextval,
          x_cust_setup_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          1,
          FND_GLOBAL.conc_login_id,
          stp.display_sequence_no,
          stp.setup_attribute,
          stp.mandatory_flag,
          'Y',
          stp.function_name,
          stp.parent_function_name,
          stp.parent_setup_attribute,
          stp.parent_display_sequence,
          nvl(stp.show_in_report,'Y'),
          nvl(stp.show_in_cue_card,'Y'),
          nvl(stp.copy_allowed_flag,'N'),
          stp.related_ak_attribute,
          stp.essential_seq_num

    FROM  ams_setup_types stp
    WHERE stp.object_type = l_cust_setup_rec.object_type
         AND stp.activity_type_code = l_cust_setup_rec.activity_type_code
         AND (stp.usage ='ALL' OR stp.usage is null)
         AND stp.application_id     = l_cust_setup_rec.application_id;
  IF SQL%NOTFOUND THEN
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
   select ams_custom_setup_attr_s.nextval,
          x_cust_setup_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          1,
          FND_GLOBAL.conc_login_id,
          stp.display_sequence_no,
          stp.setup_attribute,
          stp.mandatory_flag,
          'Y',
          stp.function_name,
          stp.parent_function_name,
          stp.parent_setup_attribute,
          stp.parent_display_sequence,
          nvl(stp.show_in_report,'Y'),
          nvl(stp.show_in_cue_card,'Y'),
          nvl(stp.copy_allowed_flag,'N'),
          stp.related_ak_attribute,
          stp.essential_seq_num
    FROM  ams_setup_types stp
    WHERE stp.object_type = l_cust_setup_rec.object_type
         AND stp.activity_type_code is null
         AND (stp.usage ='ALL' OR stp.usage is null)
         AND stp.application_id     = l_cust_setup_rec.application_id;
  END IF;

ELSE
  --anchaudh adding the IF condition for bug#3718563
  IF (l_cust_setup_rec.activity_type_code = 'DIRECT_MARKETING' AND l_cust_setup_rec.media_id = 460) THEN
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
   select ams_custom_setup_attr_s.nextval,
          x_cust_setup_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          1,
          FND_GLOBAL.conc_login_id,
          stp.display_sequence_no,
          stp.setup_attribute,
          stp.mandatory_flag,
          --decode(stp.setup_attribute,'PTNR','N','Y'), --'Y',--anchaudh modified: to bring up partner attribute unchecked while any user activity template creation
          --'Y', --anchaudh modified: to bring up partner attribute CHECKED while any user activity template creation in R12.
          decode(stp.setup_attribute,'FUND','N','BAPL','N','PTNR','N','Y'), -- VMODUR Bug 4884550, 4945973
          stp.function_name,
          stp.parent_function_name,
          stp.parent_setup_attribute,
          stp.parent_display_sequence,
          nvl(stp.show_in_report,'Y'),
          nvl(stp.show_in_cue_card,'Y'),
          nvl(stp.copy_allowed_flag,'N'),
          stp.related_ak_attribute,
          stp.essential_seq_num

    FROM  ams_setup_types stp
    WHERE stp.object_type = l_cust_setup_rec.object_type
         AND stp.activity_type_code = l_cust_setup_rec.activity_type_code
         AND stp.usage in ('LITE','ALL')
         AND stp.application_id     = l_cust_setup_rec.application_id
         AND stp.setup_attribute not in ('COLT');  --ANCHAUDH

  IF SQL%NOTFOUND THEN
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
   select ams_custom_setup_attr_s.nextval,
          x_cust_setup_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          1,
          FND_GLOBAL.conc_login_id,
          stp.display_sequence_no,
          stp.setup_attribute,
          stp.mandatory_flag,
          --decode(stp.setup_attribute,'PTNR','N','Y'), --'Y',--anchaudh modified: to bring up partner attribute unchecked while any user activity template creation
          --'Y', --anchaudh modified: to bring up partner attribute CHECKED while any user activity template creation in R12.
          decode(stp.setup_attribute,'FUND','N','BAPL','N','PTNR','N','Y'), -- VMODUR Bug 4884550, 4945973
          stp.function_name,
          stp.parent_function_name,
          stp.parent_setup_attribute,
          stp.parent_display_sequence,
          nvl(stp.show_in_report,'Y'),
          nvl(stp.show_in_cue_card,'Y'),
          nvl(stp.copy_allowed_flag,'N'),
          stp.related_ak_attribute,
          stp.essential_seq_num
    FROM  ams_setup_types stp
    WHERE stp.object_type = l_cust_setup_rec.object_type
         AND stp.activity_type_code is null
         AND stp.usage in ('LITE','ALL')
         AND stp.application_id     = l_cust_setup_rec.application_id
         AND stp.setup_attribute not in ('COLT');  --ANCHAUDH
  END IF;

  ELSE --anchaudh adding the ELSE condition for bug#3718563

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
   select ams_custom_setup_attr_s.nextval,
          x_cust_setup_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          1,
          FND_GLOBAL.conc_login_id,
          stp.display_sequence_no,
          stp.setup_attribute,
          stp.mandatory_flag,
          --decode(stp.setup_attribute,'PTNR','N','Y'), --'Y',--anchaudh modified: to bring up partner attribute unchecked while any user activity template creation
          --'Y', --anchaudh modified: to bring up partner attribute CHECKED while any user activity template creation in R12.
          decode(stp.setup_attribute,'FUND','N','BAPL','N','PTNR','N','Y'), -- VMODUR Bug 4884550, 4945973
          stp.function_name,
          stp.parent_function_name,
          stp.parent_setup_attribute,
          stp.parent_display_sequence,
          nvl(stp.show_in_report,'Y'),
          nvl(stp.show_in_cue_card,'Y'),
          nvl(stp.copy_allowed_flag,'N'),
          stp.related_ak_attribute,
          stp.essential_seq_num

    FROM  ams_setup_types stp
    WHERE stp.object_type = l_cust_setup_rec.object_type
         AND stp.activity_type_code = l_cust_setup_rec.activity_type_code
         AND stp.usage in ('LITE','ALL')
         AND stp.application_id     = l_cust_setup_rec.application_id;

 IF SQL%NOTFOUND THEN
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
   select ams_custom_setup_attr_s.nextval,
          x_cust_setup_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          1,
          FND_GLOBAL.conc_login_id,
          stp.display_sequence_no,
          stp.setup_attribute,
          stp.mandatory_flag,
          --decode(stp.setup_attribute,'PTNR','N','Y'), --'Y',--anchaudh modified: to bring up partner attribute unchecked while any user activity template creation
          --'Y', --anchaudh modified: to bring up partner attribute CHECKED while any user activity template creation in R12.
          decode(stp.setup_attribute,'FUND','N','BAPL','N','PTNR','N','Y'), -- VMODUR Bug 4884550, 4945973
          stp.function_name,
          stp.parent_function_name,
          stp.parent_setup_attribute,
          stp.parent_display_sequence,
          nvl(stp.show_in_report,'Y'),
          nvl(stp.show_in_cue_card,'Y'),
          nvl(stp.copy_allowed_flag,'N'),
          stp.related_ak_attribute,
          stp.essential_seq_num
    FROM  ams_setup_types stp
    WHERE stp.object_type = l_cust_setup_rec.object_type
	 AND stp.activity_type_code is null
	 AND stp.usage in ('LITE','ALL')
	 AND stp.application_id     = l_cust_setup_rec.application_id;
  END IF;

  END IF; --anchaudh ending the IF condition for bug#3718563

END IF;




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
      ROLLBACK TO create_cust_setup;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_cust_setup;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO create_cust_setup;
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

END create_cust_setup;


/*****************************************************************************/
-- Procedure: update_cust_setup
--
-- History
--   11/29/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE update_cust_setup
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER := FND_API.g_valid_level_full,
  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_cust_setup_rec      IN      cust_setup_rec_type
)
IS

  l_api_version       CONSTANT NUMBER := 1.0;
  l_api_name          CONSTANT VARCHAR2(30) := 'update_cust_setup';
  l_full_name         CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_return_status     VARCHAR2(1);
  l_cust_setup_rec    cust_setup_rec_type := p_cust_setup_rec;

BEGIN

-- initialize
  SAVEPOINT update_cust_setup;

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

-- check custom_setup_id, dont update setups if id < 10000 as they are seed data
/**
IF l_cust_setup_rec.custom_setup_id < 10000 THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CUS_SETUP_SEED_DATA');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
**/
-- complete the record
  complete_cust_setup_rec
  (
    p_cust_setup_rec,
    l_cust_setup_rec
  );

-- validate
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(l_full_name || ': validate');
    END IF;
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(l_full_name || ': check items');
    END IF;
    check_items
    (
      p_validation_mode => JTF_PLSQL_API.g_update,
      x_return_status   => l_return_status,
      p_cust_setup_rec  => l_cust_setup_rec
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

  UPDATE AMS_CUSTOM_SETUPS_B SET
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    object_version_number = l_cust_setup_rec.object_version_number + 1,
    last_update_login = FND_GLOBAL.conc_login_id,
    activity_type_code = l_cust_setup_rec.activity_type_code,
    media_id = l_cust_setup_rec.media_id,
    enabled_flag = l_cust_setup_rec.enabled_flag,
    object_type = l_cust_setup_rec.object_type,
    source_code_suffix = l_cust_setup_rec.source_code_suffix,
    allow_essential_grouping = l_cust_setup_rec.allow_essential_grouping,
    usage = l_cust_setup_rec.usage
  WHERE custom_setup_id = l_cust_setup_rec.custom_setup_id
  AND object_version_number = l_cust_setup_rec.object_version_number;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  UPDATE AMS_CUSTOM_SETUPS_TL SET
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    last_update_login = FND_GLOBAL.conc_login_id,
    source_lang = USERENV('LANG'),
    setup_name = l_cust_setup_rec.setup_name,
    description = l_cust_setup_rec.description
  WHERE custom_setup_id = l_cust_setup_rec.custom_setup_id
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
      ROLLBACK TO update_cust_setup;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_cust_setup;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO update_cust_setup;
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

END update_cust_setup;


/*****************************************************************************/
-- Procedure: delete_cust_setup
--
-- History
--   11/29/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE delete_cust_setup
(
  p_api_version       IN      NUMBER,
  p_init_msg_list     IN      VARCHAR2 := FND_API.g_false,
  p_commit            IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY     VARCHAR2,
  x_msg_count         OUT NOCOPY     NUMBER,
  x_msg_data          OUT NOCOPY     VARCHAR2,

  p_cust_setup_id     IN      NUMBER,
  p_object_version    IN      NUMBER
)
IS

  l_api_version    CONSTANT NUMBER := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'delete_cust_setup';
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_is_used_count  NUMBER;
  l_object_version NUMBER;

  CURSOR c_is_used_count(cust_setup_id IN NUMBER) IS
    SELECT COUNT(*)
    FROM AMS_OBJECT_ATTRIBUTES
    WHERE custom_setup_id = cust_setup_id;

  CURSOR c_object_version(cust_setup_id IN NUMBER) IS
    SELECT object_version_number
    FROM AMS_CUSTOM_SETUPS_B
    WHERE custom_setup_id = cust_setup_id;

BEGIN
-- initialize
  SAVEPOINT delete_cust_setup;

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

-- check custom_setup_id, dont delete setups if id < 10000 as they are seed data
  IF p_cust_setup_id < 10000 THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CUS_SETUP_SEED_DATA');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

-- delete
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': delete');
  END IF;

  OPEN c_is_used_count(p_cust_setup_id);
  FETCH c_is_used_count INTO l_is_used_count;
  CLOSE c_is_used_count;

  OPEN c_object_version(p_cust_setup_id);
  FETCH c_object_version INTO l_object_version;
  CLOSE c_object_version;

  IF l_is_used_count = 0 THEN				-- IS NOT USED
    IF l_object_version = p_object_version THEN         -- VERSIONS MATCH
      DELETE FROM AMS_CUSTOM_SETUP_ATTR
      WHERE custom_setup_id = p_cust_setup_id;

      DELETE FROM AMS_CUSTOM_SETUPS_TL
      WHERE custom_setup_id = p_cust_setup_id;

      IF (SQL%NOTFOUND) THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;

      DELETE FROM AMS_CUSTOM_SETUPS_B
      WHERE custom_setup_id = p_cust_setup_id
      AND object_version_number = p_object_version;

      IF (SQL%NOTFOUND) THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;
    ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_VERS_DONT_MATCH');
        FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
    END IF;
  ELSE
    UPDATE AMS_CUSTOM_SETUPS_B SET			-- IS USED
      object_version_number = l_object_version +1,
      enabled_flag = 'N'
    WHERE custom_setup_id = p_cust_setup_id
      AND object_version_number = p_object_version;
/*
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_IN_USE');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
*/
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
      ROLLBACK TO delete_cust_setup;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_cust_setup;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO delete_cust_setup;
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

END delete_cust_setup;


/*****************************************************************************/
-- Procedure: lock_cust_setup
--
-- History
--   11/29/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE lock_cust_setup
(
  p_api_version       IN      NUMBER,
  P_init_msg_list     IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY     VARCHAR2,
  x_msg_count         OUT NOCOPY     NUMBER,
  x_msg_data          OUT NOCOPY     VARCHAR2,

  p_cust_setup_id     IN      NUMBER,
  p_object_version    IN      NUMBER
)
IS

  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'lock_cust_setup';
  l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_cust_setup_id    NUMBER;

  CURSOR c_cust_setup_b IS
    SELECT custom_setup_id
    FROM AMS_CUSTOM_SETUPS_B
    WHERE custom_setup_id = p_cust_setup_id
    AND object_version_number = p_object_version
    FOR UPDATE OF custom_setup_id NOWAIT;

  CURSOR c_cust_setup_tl IS
    SELECT custom_setup_id
    FROM AMS_CUSTOM_SETUPS_TL
    WHERE custom_setup_id = p_cust_setup_id
    AND USERENV('LANG') IN (language, source_lang)
    FOR UPDATE OF custom_setup_id NOWAIT;

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

  OPEN c_cust_setup_b;
  FETCH c_cust_setup_b INTO l_cust_setup_id;
  IF (c_cust_setup_b%NOTFOUND) THEN
    CLOSE c_cust_setup_b;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_cust_setup_b;

  OPEN c_cust_setup_tl;
  FETCH c_cust_setup_tl INTO l_cust_setup_id;
  IF (c_cust_setup_tl%NOTFOUND) THEN
    CLOSE c_cust_setup_tl;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_cust_setup_tl;

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

END lock_cust_setup;


/*****************************************************************************/
-- PROCEDURE
--    validate_cust_setup
--
-- HISTORY
--    11/29/99    julou    Created.
--------------------------------------------------------------------
PROCEDURE validate_cust_setup
(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cust_setup_rec    IN  cust_setup_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_cust_setup';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

--   IF FND_API.to_boolean(p_init_msg_list) THEN
--      FND_MSG_PUB.initialize;
--   END IF;

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
         p_cust_setup_rec  => p_cust_setup_rec
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

END validate_cust_setup;


/*****************************************************************************/
-- Procedure: check_items
--
-- History
--   12/19/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode    IN      VARCHAR2,
    x_return_status      OUT NOCOPY     VARCHAR2,
    p_cust_setup_rec     IN      cust_setup_rec_type
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
  check_cust_setup_req_items
  (
    p_validation_mode => p_validation_mode,
    p_cust_setup_rec  => p_cust_setup_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check unique key items
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': check uk items');
  END IF;
  check_cust_setup_uk_items
  (
    p_validation_mode => p_validation_mode,
    p_cust_setup_rec  => p_cust_setup_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check foreign key items
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': check fk items');
  END IF;
  check_cust_setup_fk_items
  (
    p_cust_setup_rec  => p_cust_setup_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check flags
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': check flag items');
  END IF;
  check_cust_setup_flag_items
  (
    p_cust_setup_rec  => p_cust_setup_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

END check_items;


/*****************************************************************************/
-- Procedure: check_cust_setup_req_items
--
-- History
--   11/29/1999    julou    created
--   03-Jan-2000   ptendulk Modified the Activity type check for Rollup campaigns
--                          as it can be null for rollup campaigns.
-------------------------------------------------------------------------------
PROCEDURE check_cust_setup_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_cust_setup_rec     IN      cust_setup_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
)
IS

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check custom_setup_id
  IF p_cust_setup_rec.custom_setup_id IS NULL
    AND p_validation_mode = JTF_PLSQL_API.g_update
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CUS_SETUP_NO_CUS_SETUP_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check object_version_number
  IF p_cust_setup_rec.object_version_number IS NULL
    AND p_validation_mode = JTF_PLSQL_API.g_update
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_NO_OBJ_VER_NUM');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check object_type
/*  IF p_cust_setup_rec.object_type NOT IN ('CAMP','ECAM','RCAM','EVEH','EVEO') THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CUS_SETUP_BAD_OBJ_TYPE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check activity_type_code
-- Following Line is modified by ptendulk on 03-Jan-2000 as for rollup campaigns,
-- Activity type is not mandatory now.
--  IF p_cust_setup_rec.object_type IN ('CAMP','ECAM','RCAM')
  IF p_cust_setup_rec.object_type IN ('CAMP','ECAM')
    AND p_cust_setup_rec.activity_type_code IS NULL
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CUS_SETUP_NO_ACT_TP_CODE');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

  IF p_cust_setup_rec.object_type = 'EVEH'
    OR p_cust_setup_rec.object_type = 'EVEO'
  THEN
    IF p_cust_setup_rec.activity_type_code IS NOT NULL
      OR p_cust_setup_rec.media_id IS NOT NULL
    THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_CUS_SETUP_BAD_ACT_TP_CODE');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF; */

-- check setup_name
  IF p_cust_setup_rec.setup_name IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CUS_SETUP_NO_SETUP_NAME');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;


END check_cust_setup_req_items;


/*****************************************************************************/
-- Procedure: check_cust_setup_uk_items
--
-- History
--   11/29/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_cust_setup_uk_items
(
  p_validation_mode    IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_cust_setup_rec     IN      cust_setup_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
)
IS

  l_uk_flag    VARCHAR2(1);

  CURSOR c_name_unique_cr (p_setup_name IN VARCHAR2) IS
       SELECT  ''
	    FROM AMS_CUSTOM_SETUPS_TL
	   WHERE UPPER(setup_name) = UPPER(p_setup_name)
	      AND language = USERENV('LANG') ;

  CURSOR c_name_unique_up (p_setup_name IN VARCHAR2, p_setup_id IN NUMBER) IS
		SELECT  ''
	       FROM AMS_CUSTOM_SETUPS_TL
		 WHERE UPPER(setup_name) = UPPER(p_setup_name)
	        AND custom_setup_id <> p_setup_id
		   AND language = USERENV('LANG');

  l_flag VARCHAR2(1);
  l_dummy VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

-- check PK, if custom_setup_id is passed in, must check if it is duplicATE
  IF p_validation_mode = JTF_PLSQL_API.g_create
    AND p_cust_setup_rec.custom_setup_id IS NOT NULL
  THEN
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
		   'AMS_CUSTOM_SETUPS_VL',
		   'custom_setup_id = ' || p_cust_setup_rec.custom_setup_id
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)	THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CUSTOM_SETUP_DUPLICATE_ID');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

-- check custom_setup_id
/***************  commented by abhola
  IF p_cust_setup_rec.custom_setup_id IS NOT NULL THEN      -- UPDATE RECORD
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
                   'AMS_CUSTOM_SETUPS_TL',
                   'custom_setup_id <> ' || p_cust_setup_rec.custom_setup_id
                   || ' AND setup_name =  ''' || p_cust_setup_rec.setup_name
                   || ''' AND language = ''' || USERENV('LANG') ||''''
                 );
  ELSE                                                       -- NEW RECORD
    l_uk_flag := AMS_Utility_PVT.check_uniqueness
                 (
                   'AMS_CUSTOM_SETUPS_TL',
                   'setup_name = ''' || p_cust_setup_rec.setup_name
                   || ''' AND language = ''' || USERENV('LANG') ||''''
                 );
  END IF;

  IF l_uk_flag = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CUST_SETUP_DUP_NAME_LANG');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;
  ************* end abhola **************/
--
-- start abhola
--
    l_flag := 'N';

    IF p_cust_setup_rec.custom_setup_id IS NULL THEN    -- UPDATE RECORD

	  OPEN c_name_unique_cr (p_cust_setup_rec.setup_name);
	  FETCH  c_name_unique_cr INTO l_dummy;
	  if (c_name_unique_cr%FOUND) then
		l_flag := 'Y';
       end if;
	  CLOSE c_name_unique_cr;

   ELSE

	 OPEN c_name_unique_up (p_cust_setup_rec.setup_name,p_cust_setup_rec.custom_setup_id);
	 FETCH  c_name_unique_up INTO l_dummy;
      if (c_name_unique_up%FOUND) then
	    l_flag := 'Y';
      end if;

   END IF;

  IF (l_flag = 'Y')  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CUST_SETUP_DUP_NAME_LANG');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;
--  end abhola

END check_cust_setup_uk_items;


/*****************************************************************************/
-- Procedure: check_cust_setup_fk_items
--
-- History
--   11/29/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_cust_setup_fk_items
(
  p_cust_setup_rec    IN      cust_setup_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
)
IS

  l_fk_flag       VARCHAR2(1);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;
  IF p_cust_setup_rec.media_id IS NOT NULL THEN
    -- DELV condition added by rrajesh on 07/21/01
    -- And moved ams_media_b check in else condition
    IF p_cust_setup_rec.object_type = 'DELV' THEN
       l_fk_flag := AMS_Utility_PVT.check_fk_exists
                 (
                   'AMS_CATEGORIES_B',
                   'category_id',
                   p_cust_setup_rec.media_id
                 );
    ELSE
       l_fk_flag := AMS_Utility_PVT.check_fk_exists
                 (
                   'AMS_MEDIA_B',
                   'media_id',
                   p_cust_setup_rec.media_id
                 );
    END IF;
    -- end change. 07/21/01
    IF l_fk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_CUS_SETUP_BAD_MEDIA_ID');
        FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

END check_cust_setup_fk_items;

/*****************************************************************************/
-- Procedure: check_cust_setup_flag_items
--
-- History
--   11/29/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE check_cust_setup_flag_items
(
  p_cust_setup_rec    IN      cust_setup_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
)
IS

  l_mand_flag    VARCHAR2(1);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

-- enabled_flag
  IF p_cust_setup_rec.enabled_flag NOT IN ('Y','N',FND_API.g_miss_char)
    AND p_cust_setup_rec.enabled_flag IS NOT NULL
  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CUS_SETUP_BAD_ENBL_FLAG');
      FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;

END check_cust_setup_flag_items;


/*****************************************************************************/
-- Procedure: complete_cust_setup_rec
--
-- History
--   11/29/1999    julou    created
-------------------------------------------------------------------------------
PROCEDURE complete_cust_setup_rec
(
  p_cust_setup_rec    IN      cust_setup_rec_type,
  x_complete_rec      OUT NOCOPY     cust_setup_rec_type
)
IS

  CURSOR c_cust_setup IS
    SELECT * FROM AMS_CUSTOM_SETUPS_VL
    WHERE custom_setup_id = p_cust_setup_rec.custom_setup_id;

  l_cust_setup_rec     c_cust_setup%ROWTYPE;

BEGIN

  x_complete_rec := p_cust_setup_rec;

  OPEN c_cust_setup;
  FETCH c_cust_setup INTO l_cust_setup_rec;
  IF (c_cust_setup%NOTFOUND) THEN
    CLOSE c_cust_setup;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_cust_setup;

  IF p_cust_setup_rec.object_type = FND_API.g_miss_char THEN
    x_complete_rec.object_type := l_cust_setup_rec.object_type;
  END IF;

  IF p_cust_setup_rec.enabled_flag = FND_API.g_miss_char THEN
    x_complete_rec.enabled_flag := l_cust_setup_rec.enabled_flag;
  END IF;

  IF p_cust_setup_rec.allow_essential_grouping = FND_API.g_miss_char THEN
    x_complete_rec.allow_essential_grouping := l_cust_setup_rec.allow_essential_grouping;
  END IF;

  IF p_cust_setup_rec.usage = FND_API.g_miss_char THEN
    x_complete_rec.usage := l_cust_setup_rec.usage;
  END IF;

--  IF p_cust_setup_rec.object_type NOT IN ('CAMP','ECAM','RCAM') THEN
--    x_complete_rec.activity_type_code := NULL;
--    x_complete_rec.media_id := NULL;
--  ELSE
    IF p_cust_setup_rec.activity_type_code = FND_API.g_miss_char THEN
      x_complete_rec.activity_type_code := l_cust_setup_rec.activity_type_code;
    END IF;

    IF p_cust_setup_rec.source_code_suffix = FND_API.g_miss_char THEN
      x_complete_rec.source_code_suffix := l_cust_setup_rec.source_code_suffix;
    END IF;

    IF p_cust_setup_rec.media_id = FND_API.g_miss_num THEN
      x_complete_rec.media_id := l_cust_setup_rec.media_id;
    END IF;
--  END IF;

  IF p_cust_setup_rec.setup_name = FND_API.g_miss_char THEN
    x_complete_rec.setup_name := l_cust_setup_rec.setup_name;
  END IF;

  IF p_cust_setup_rec.description = FND_API.g_miss_char THEN
    x_complete_rec.description := l_cust_setup_rec.description;
  END IF;

END complete_cust_setup_rec;


/****************************************************************************/
-- Procedure
--   init_rec
--
-- HISTORY
--    12/19/1999    julou    Created.
------------------------------------------------------------------------------
PROCEDURE init_rec
(
  x_cust_setup_rec  OUT NOCOPY  cust_setup_rec_type
)
IS

BEGIN

  x_cust_setup_rec.custom_setup_id := FND_API.g_miss_num;
  x_cust_setup_rec.last_update_date := FND_API.g_miss_date;
  x_cust_setup_rec.last_updated_by := FND_API.g_miss_num;
  x_cust_setup_rec.creation_date := FND_API.g_miss_date;
  x_cust_setup_rec.created_by := FND_API.g_miss_num;
  x_cust_setup_rec.last_update_login := FND_API.g_miss_num;
  x_cust_setup_rec.object_version_number := FND_API.g_miss_num;
  x_cust_setup_rec.activity_type_code := FND_API.g_miss_char;
  x_cust_setup_rec.media_id := FND_API.g_miss_num;
  x_cust_setup_rec.enabled_flag := FND_API.g_miss_char;
  x_cust_setup_rec.object_type := FND_API.g_miss_char;
  x_cust_setup_rec.source_code_suffix := FND_API.g_miss_char;
  x_cust_setup_rec.setup_name := FND_API.g_miss_char;
  x_cust_setup_rec.description := FND_API.g_miss_char;
  x_cust_setup_rec.allow_essential_grouping := FND_API.g_miss_char;
  x_cust_setup_rec.usage := FND_API.g_miss_char;

END init_rec;

END AMS_Cust_Setup_PVT;

/
