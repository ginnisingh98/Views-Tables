--------------------------------------------------------
--  DDL for Package Body IBE_MSITE_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MSITE_RESP_PKG" AS
/* $Header: IBETMRSB.pls 120.4.12010000.4 2016/10/19 22:18:36 ytian ship $ */


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_MSITE_RESP_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBETMRSB.pls';
l_true       VARCHAR2(1)            := FND_API.G_TRUE;

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
   p_display_name                       IN VARCHAR2,
   p_group_code					IN VARCHAR2,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT NOCOPY VARCHAR2,
   x_msite_resp_id                      OUT NOCOPY NUMBER
  )
IS
  CURSOR c IS SELECT rowid FROM ibe_msite_resps_b
    WHERE msite_resp_id = x_msite_resp_id;
  CURSOR c2 IS SELECT ibe_msite_resps_b_s1.nextval FROM dual;

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
  INSERT INTO ibe_msite_resps_b
    (
    msite_resp_id,
    object_version_number,
    msite_id,
    responsibility_id,
    application_id,
    start_date_active,
    end_date_active,
    sort_order,
    group_code,
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
    decode(p_group_code, FND_API.G_MISS_CHAR, NULL, p_group_code),
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
  IF ((p_msite_resp_id IS NULL) OR
      (p_msite_resp_id = FND_API.G_MISS_NUM))
  THEN
    INSERT INTO ibe_msite_resps_tl
      (
      msite_resp_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      display_name,
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
        L.language_code,
        userenv('LANG')
        FROM fnd_languages L
        WHERE L.installed_flag IN ('I', 'B')
        AND NOT EXISTS
        (SELECT NULL
        FROM ibe_msite_resps_tl T
        WHERE T.msite_resp_id = x_msite_resp_id
        AND T.language = L.language_code);

      OPEN c;
      FETCH c INTO x_rowid;
      IF (c%NOTFOUND) THEN
        CLOSE c;
        RAISE NO_DATA_FOUND;
      END if;
      CLOSE c;
   END IF;

END insert_row;

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
   p_display_name                       IN VARCHAR2,
   p_group_code					IN VARCHAR2,
   p_ordertype_id                        IN NUMBER,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT NOCOPY VARCHAR2,
   x_msite_resp_id                      OUT NOCOPY NUMBER
  )
IS
  CURSOR c IS SELECT rowid FROM ibe_msite_resps_b
    WHERE msite_resp_id = x_msite_resp_id;
  CURSOR c2 IS SELECT ibe_msite_resps_b_s1.nextval FROM dual;
   DEFAULT_NUM NUMBER ;
   DEFAULT_DAT DATE   ;
   DEFAULT_CHAR VARCHAR2(1) ;
   DEBUGSTR varchar2(2000);
   orderTypeIdVal number;
BEGIN

  DEFAULT_NUM  := FND_API.G_MISS_NUM;
  DEFAULT_DAT    := FND_API.G_MISS_DATE;
  DEFAULT_CHAR  := FND_API.G_MISS_CHAR;

  -- Primary key validation check
  x_msite_resp_id := p_msite_resp_id;
  IF ((x_msite_resp_id IS NULL) OR
      (x_msite_resp_id = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO x_msite_resp_id;
    CLOSE c2;
  END IF;

/*
 if (p_ordertype_id = 0) then
     orderTypeIdVal := DEFAULT_NUM;
else
     orderTypeIdVal := p_ordertype_id;
 end if;
*/
  orderTypeIdVal := p_ordertype_id;

  -- insert base
  INSERT INTO ibe_msite_resps_b
    (
    msite_resp_id,
    object_version_number,
    msite_id,
    responsibility_id,
    application_id,
    start_date_active,
    end_date_active,
    sort_order,
    group_code,
    order_type_id,
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
    decode(p_end_date_active, DEFAULT_DAT, NULL, p_end_date_active),
    decode(p_sort_order, DEFAULT_NUM, NULL, p_sort_order),
    decode(p_group_code, DEFAULT_CHAR, NULL, p_group_code),
    orderTypeIdVal,
    decode(p_creation_date, DEFAULT_DAT, sysdate, NULL, sysdate,
           p_creation_date),
    decode(p_created_by, DEFAULT_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_created_by),
    decode(p_last_update_date, DEFAULT_DAT, sysdate, NULL, sysdate,
           p_last_update_date),
    decode(p_last_updated_by, DEFAULT_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_last_updated_by),
    decode(p_last_update_login, DEFAULT_NUM, FND_GLOBAL.login_id,
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
  IF ((p_msite_resp_id IS NULL) OR
      (p_msite_resp_id = FND_API.G_MISS_NUM))
  THEN
    INSERT INTO ibe_msite_resps_tl
      (
      msite_resp_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      display_name,
      language,
      source_lang
      )
      SELECT
      x_msite_resp_id,
        p_object_version_number,
        decode(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
               NULL, FND_GLOBAL.user_id, p_created_by),
        decode(p_creation_date, DEFAULT_DAT, sysdate,
               NULL, sysdate, p_creation_date),
        decode(p_last_updated_by, DEFAULT_NUM, FND_GLOBAL.user_id,
               NULL, FND_GLOBAL.user_id, p_last_updated_by),
        decode(p_last_update_date, DEFAULT_DAT, sysdate,
               NULL, sysdate, p_last_update_date),
        decode(p_last_update_login, DEFAULT_NUM, FND_GLOBAL.login_id,
             NULL, FND_GLOBAL.login_id, p_last_update_login),
        p_display_name,
        L.language_code,
        userenv('LANG')
        FROM fnd_languages L
        WHERE L.installed_flag IN ('I', 'B')
        AND NOT EXISTS
        (SELECT NULL
        FROM ibe_msite_resps_tl T
        WHERE T.msite_resp_id = x_msite_resp_id
        AND T.language = L.language_code);

      OPEN c;
      FETCH c INTO x_rowid;
      IF (c%NOTFOUND) THEN
        CLOSE c;
        RAISE NO_DATA_FOUND;
      END if;
      CLOSE c;
   END IF;

END insert_row;

PROCEDURE update_row
  (
   p_msite_resp_id                      IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_sort_order                         IN NUMBER,
   p_display_name                       IN VARCHAR2,
   p_group_code					IN VARCHAR2,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER
  )
IS
BEGIN
   IBE_Util.enable_debug_new('N');
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('update_row starts');
        END IF;

  -- update base
  UPDATE ibe_msite_resps_b SET
    object_version_number = object_version_number + 1,
    start_date_active = decode(p_start_date_active, FND_API.G_MISS_DATE,
                               start_date_active, p_start_date_active),
    end_date_active = decode(p_end_date_active, FND_API.G_MISS_DATE,
                             end_date_active, p_end_date_active),
    sort_order = decode(p_sort_order, FND_API.G_MISS_NUM,
                        sort_order, p_sort_order),
    group_code = decode(p_group_code, FND_API.G_MISS_CHAR,
                          group_code, p_group_code),
    last_update_date = decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate,
                              NULL, sysdate, p_last_update_date),
    last_updated_by = decode(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = decode(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login)
    WHERE msite_resp_id = p_msite_resp_id;
    -- AND object_version_number = decode(p_object_version_number,
    --                                   FND_API.G_MISS_NUM,
    --                                   object_version_number,
    --                                   p_object_version_number);
  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  -- update tl
  UPDATE ibe_msite_resps_tl SET
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
    --    AND object_version_number = decode(p_object_version_number,
    --                                 FND_API.G_MISS_NUM,
    --                                 object_version_number,
    --                                 p_object_version_number)
    AND USERENV('LANG') IN (language, source_lang);

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;


PROCEDURE update_row
  (
   p_msite_resp_id                      IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_sort_order                         IN NUMBER,
   p_display_name                       IN VARCHAR2,
   p_group_code				IN VARCHAR2,
   p_order_type_id                      IN NUMBER ,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER
  )
IS
   DEFAULT_NUM NUMBER ;
   DEFAULT_DAT DATE   ;
   DEFAULT_CHAR VARCHAR2(1) ;
   DEBUGSTR varchar2(2000);
BEGIN

  DEFAULT_NUM  := FND_API.G_MISS_NUM;
  DEFAULT_DAT    := FND_API.G_MISS_DATE;
  DEFAULT_CHAR  := FND_API.G_MISS_CHAR;

  IBE_Util.enable_debug_new('N');

  -- update base


   begin

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Ibe_Msite_Resp_Pkg.update_row p_order_Type_id'||p_order_Type_id||' msite_resp_id='||p_msite_resp_id);
     END IF;

    UPDATE ibe_msite_resps_b SET
    object_version_number = object_version_number + 1,
    order_type_id = decode(p_order_Type_id, DEFAULT_NUM, order_TYPE_ID, p_order_Type_id),
    start_date_active = decode(p_start_date_active, DEFAULT_DAT,
                               start_date_active, p_start_date_active),
    end_date_active = decode(p_end_date_active, DEFAULT_DAT,
                             end_date_active, p_end_date_active),
    sort_order = decode(p_sort_order, DEFAULT_NUM,
                        sort_order, p_sort_order),
    group_code = decode(p_group_code, DEFAULT_CHAR,
                          group_code, p_group_code),
    last_update_date = decode(p_last_update_date, DEFAULT_DAT, sysdate,
                              NULL, sysdate, p_last_update_date),
    last_updated_by = decode(p_last_updated_by, DEFAULT_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = decode(p_last_update_login, DEFAULT_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login)
    WHERE msite_resp_id = p_msite_resp_id;
    -- AND object_version_number = decode(p_object_version_number,
    --                                   FND_API.G_MISS_NUM,
    --                                   object_version_number,
    --                                   p_object_version_number);

    IF (sql%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;



    exception
       when others then
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('update_row exception starts here:'||sqlerrm);
         END IF;

end;

  -- update tl

  UPDATE ibe_msite_resps_tl SET
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
    --    AND object_version_number = decode(p_object_version_number,
    --                                 FND_API.G_MISS_NUM,
    --                                 object_version_number,
    --                                 p_object_version_number)
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
  DELETE FROM ibe_msite_resps_tl
    WHERE msite_resp_id = p_msite_resp_id;

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM ibe_msite_resps_b
    WHERE msite_resp_id = p_msite_resp_id;

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;

PROCEDURE add_language
IS
BEGIN
  delete FROM ibe_msite_resps_tl T
    WHERE NOT EXISTS
    (SELECT NULL
    FROM ibe_msite_resps_b B
    WHERE B.MSITE_RESP_ID = T.MSITE_RESP_ID
    );

  UPDATE ibe_msite_resps_tl T SET
    (
    DISPLAY_NAME
    ) = (SELECT
    B.DISPLAY_NAME
    FROM ibe_msite_resps_tl B
    WHERE B.MSITE_RESP_ID = T.MSITE_RESP_ID
    AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE
    (
    T.MSITE_RESP_ID,
    T.LANGUAGE
    ) IN (select
    SUBT.MSITE_RESP_ID,
    SUBT.LANGUAGE
    FROM ibe_msite_resps_tl SUBB, ibe_msite_resps_tl SUBT
    WHERE SUBB.MSITE_RESP_ID = SUBT.MSITE_RESP_ID
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
        ));

  INSERT INTO ibe_msite_resps_tl
    (
    MSITE_RESP_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DISPLAY_NAME,
    LANGUAGE,
    SOURCE_LANG
    ) select
     b.msite_resp_id,
     b.object_version_number,
     b.created_by,
     b.creation_date,
     b.last_updated_by,
     b.last_update_date,
     b.last_update_login,
     b.display_name,
     l.language_code,
     b.source_lang
     from ibe_msite_resps_tl b, fnd_languages l
     where l.installed_flag in ('I', 'B')
      and b.language = userenv('LANG')
     and not exists
     (select null
     from ibe_msite_resps_tl t
     where t.msite_resp_id = b.msite_resp_id
     and t.language = l.language_code);
END add_language;

END Ibe_Msite_Resp_Pkg;

/
