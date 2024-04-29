--------------------------------------------------------
--  DDL for Package Body JTF_MSITE_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_MSITE_RESP_PKG" AS
/* $Header: JTFTMRSB.pls 115.5 2004/07/09 18:51:21 applrt ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'JTF_MSITE_RESP_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'JTFTMRSB.pls';

PROCEDURE insert_row
  (
   p_msite_resp_id                      IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_msite_id                           IN NUMBER,
   p_responsibility_id                  IN NUMBER,
   p_application_id                     IN NUMBER,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_sort_order                         IN NUMBER,
   p_security_group_id                  IN NUMBER,
   p_display_name                       IN VARCHAR2,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT VARCHAR2,
   x_msite_resp_id                      OUT NUMBER
  )
IS
  CURSOR c IS SELECT rowid FROM jtf_msite_resps_b
    WHERE msite_resp_id = x_msite_resp_id;
  CURSOR c2 IS SELECT jtf_msite_resps_b_s1.nextval FROM dual;

BEGIN

  -- Primary key validation check
  x_msite_resp_id := p_msite_resp_id;
  IF ((x_msite_resp_id IS NULL) OR
      (x_msite_resp_id = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO x_msite_resp_id;
    CLOSE c2;
  END IF;

  -- insert base
  INSERT INTO jtf_msite_resps_b
    (
    msite_resp_id,
    object_version_number,
    msite_id,
    responsibility_id,
    application_id,
    start_date_active,
    end_date_active,
    sort_order,
    security_group_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
    )
    VALUES
    (
    x_msite_resp_id,
    p_object_version_number,
    p_msite_id,
    p_responsibility_id,
    p_application_id,
    p_start_date_active,
    decode(p_end_date_active, FND_API.G_MISS_DATE, NULL, p_end_date_active),
    decode(p_sort_order, FND_API.G_MISS_NUM, NULL, p_sort_order),
    decode(p_security_group_id, FND_API.G_MISS_NUM, NULL, p_security_group_id),
    decode(p_creation_date, FND_API.G_MISS_DATE, sysdate, NULL, sysdate,
           p_creation_date),
    decode(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_created_by),
    decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate, NULL, sysdate,
           p_last_update_date),
    decode(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_last_updated_by),
    decode(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,
           NULL, FND_GLOBAL.login_id, p_last_update_login)
    );

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

  -- insert tl
  INSERT INTO jtf_msite_resps_tl
    (
    msite_resp_id,
    object_version_number,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    display_name,
    security_group_id,
    language,
    source_lang
    )
    SELECT
    x_msite_resp_id,
      p_object_version_number,
      decode(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
             NULL, FND_GLOBAL.user_id, p_created_by),
      decode(p_creation_date, FND_API.G_MISS_DATE, sysdate,
             NULL, sysdate, p_creation_date),
      decode(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
             NULL, FND_GLOBAL.user_id, p_last_updated_by),
      decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate,
             NULL, sysdate, p_last_update_date),
      decode(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,
           NULL, FND_GLOBAL.login_id, p_last_update_login),
      p_display_name,
      decode(p_security_group_id, FND_API.G_MISS_NUM, NULL,
             p_security_group_id),
      L.language_code,
      userenv('LANG')
      FROM fnd_languages L
      WHERE L.installed_flag IN ('I', 'B')
      AND NOT EXISTS
      (SELECT NULL
      FROM jtf_msite_resps_tl T
      WHERE T.msite_resp_id = x_msite_resp_id
      AND T.language = L.language_code);

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END if;
    CLOSE c;

END insert_row;

PROCEDURE update_row
  (
   p_msite_resp_id                      IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_sort_order                         IN NUMBER,
   p_security_group_id                  IN NUMBER,
   p_display_name                       IN VARCHAR2,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER
  )
IS
BEGIN

  -- update base
  UPDATE jtf_msite_resps_b SET
    object_version_number = object_version_number + 1,
    start_date_active = decode(p_start_date_active, FND_API.G_MISS_DATE,
                               start_date_active, p_start_date_active),
    end_date_active = decode(p_end_date_active, FND_API.G_MISS_DATE,
                             end_date_active, p_end_date_active),
    sort_order = decode(p_sort_order, FND_API.G_MISS_NUM,
                        sort_order, p_sort_order),
    security_group_id = decode(p_security_group_id, FND_API.G_MISS_NUM,
                               security_group_id, p_security_group_id),
    last_update_date = decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate,
                              NULL, sysdate, p_last_update_date),
    last_updated_by = decode(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = decode(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login)
    WHERE msite_resp_id = p_msite_resp_id
    AND object_version_number = decode(p_object_version_number,
                                       FND_API.G_MISS_NUM,
                                       object_version_number,
                                       p_object_version_number);
  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  -- update tl
  UPDATE jtf_msite_resps_tl SET
    object_version_number = object_version_number + 1,
    display_name = decode(p_display_name, FND_API.G_MISS_CHAR,
                          display_name, p_display_name),
    last_update_date = decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate,
                              NULL, sysdate, p_last_update_date),
    last_updated_by = decode(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = decode(p_last_update_login, FND_API.G_MISS_NUM,
                               FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                               p_last_update_login),
    source_lang = USERENV('LANG')
    WHERE msite_resp_id = p_msite_resp_id
    --AND object_version_number = decode(p_object_version_number,
                                       --FND_API.G_MISS_NUM,
                                       --object_version_number,
                                       --p_object_version_number)
    AND USERENV('LANG') IN (language, source_lang);

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;

-- ****************************************************************************
-- delete row
-- ****************************************************************************
PROCEDURE delete_row
  (
   p_msite_resp_id IN NUMBER
  )
IS
BEGIN
  DELETE FROM jtf_msite_resps_tl
    WHERE msite_resp_id = p_msite_resp_id;

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM jtf_msite_resps_b
    WHERE msite_resp_id = p_msite_resp_id;

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;

PROCEDURE add_language
IS
BEGIN
  delete FROM jtf_msite_resps_tl T
    WHERE NOT EXISTS
    (SELECT NULL
    FROM jtf_msite_resps_b B
    WHERE B.MSITE_RESP_ID = T.MSITE_RESP_ID
    );

  UPDATE jtf_msite_resps_tl T SET
    (
    DISPLAY_NAME
    ) = (SELECT
    B.DISPLAY_NAME
    FROM jtf_msite_resps_tl B
    WHERE B.MSITE_RESP_ID = T.MSITE_RESP_ID
    AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE
    (
    T.MSITE_RESP_ID,
    T.LANGUAGE
    ) IN (select
    SUBT.MSITE_RESP_ID,
    SUBT.LANGUAGE
    FROM jtf_msite_resps_tl SUBB, jtf_msite_resps_tl SUBT
    WHERE SUBB.MSITE_RESP_ID = SUBT.MSITE_RESP_ID
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
        ));

  INSERT INTO jtf_msite_resps_tl
    (
    MSITE_RESP_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DISPLAY_NAME,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
    ) SELECT
    B.MSITE_RESP_ID,
      B.OBJECT_VERSION_NUMBER,
      B.CREATED_BY,
      B.CREATION_DATE,
      B.LAST_UPDATED_BY,
      B.LAST_UPDATE_DATE,
      B.LAST_UPDATE_LOGIN,
      B.DISPLAY_NAME,
      B.SECURITY_GROUP_ID,
      L.LANGUAGE_CODE,
      B.SOURCE_LANG
      FROM jtf_msite_resps_tl B, FND_LANGUAGES L
      WHERE L.INSTALLED_FLAG IN ('I', 'B')
      and B.LANGUAGE = userenv('LANG')
      and not exists
      (select NULL
      FROM jtf_msite_resps_tl T
      WHERE T.MSITE_RESP_ID = B.MSITE_RESP_ID
      and T.LANGUAGE = L.LANGUAGE_CODE);
END add_language;

END Jtf_Msite_Resp_Pkg;

/
