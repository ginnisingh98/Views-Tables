--------------------------------------------------------
--  DDL for Package Body ICX_CAT_SHOP_STORES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_SHOP_STORES_PVT" AS
    /* $Header: ICXVSTRB.pls 120.2.12000000.3 2007/09/19 17:30:57 kkram ship $ */

    PROCEDURE INSERT_ROW(X_ROWID                    IN OUT NOCOPY VARCHAR2,
                         X_STORE_ID                 IN NUMBER,
                         X_SEQUENCE                 IN NUMBER,
                         X_LOCAL_CONTENT_FIRST_FLAG IN VARCHAR2,
                         X_NAME                     IN VARCHAR2,
                         X_DESCRIPTION              IN VARCHAR2,
                         X_LONG_DESCRIPTION         IN VARCHAR2,
                         X_IMAGE                    IN VARCHAR2,
                         X_CREATION_DATE            IN DATE,
                         X_CREATED_BY               IN NUMBER,
                         X_LAST_UPDATE_DATE         IN DATE,
                         X_LAST_UPDATED_BY          IN NUMBER,
                         X_LAST_UPDATE_LOGIN        IN NUMBER) IS
        CURSOR C IS
            SELECT ROWID
            FROM   ICX_CAT_SHOP_STORES_B
            WHERE  STORE_ID = X_STORE_ID;
    BEGIN
        INSERT INTO ICX_CAT_SHOP_STORES_B
             (STORE_ID,
             SEQUENCE,
             LOCAL_CONTENT_FIRST_FLAG,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN)
        VALUES
            (X_STORE_ID,
             X_SEQUENCE,
             X_LOCAL_CONTENT_FIRST_FLAG,
             X_CREATION_DATE,
             X_CREATED_BY,
             X_LAST_UPDATE_DATE,
             X_LAST_UPDATED_BY,
             X_LAST_UPDATE_LOGIN);

        INSERT INTO ICX_CAT_SHOP_STORES_TL
            (STORE_ID,
             NAME,
             DESCRIPTION,
             LONG_DESCRIPTION,
             IMAGE,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             LANGUAGE,
             SOURCE_LANG)
            SELECT X_STORE_ID,
                   X_NAME,
                   X_DESCRIPTION,
                   X_LONG_DESCRIPTION,
                   X_IMAGE,
                   X_CREATED_BY,
                   X_CREATION_DATE,
                   X_LAST_UPDATED_BY,
                   X_LAST_UPDATE_DATE,
                   X_LAST_UPDATE_LOGIN,
                   L.LANGUAGE_CODE,
                   userenv('LANG')
            FROM   FND_LANGUAGES L
            WHERE  L.INSTALLED_FLAG IN ('I', 'B')
                   AND NOT EXISTS
             (SELECT NULL
                    FROM   ICX_CAT_SHOP_STORES_TL T
                    WHERE  T.STORE_ID = X_STORE_ID
                           AND T.LANGUAGE = L.LANGUAGE_CODE);

        OPEN c;
        FETCH c
            INTO X_ROWID;
        IF (c%NOTFOUND)
        THEN
            CLOSE c;
            RAISE no_data_found;
        END IF;
        CLOSE c;

    END INSERT_ROW;

    PROCEDURE LOCK_ROW(X_STORE_ID                 IN NUMBER,
                       X_SEQUENCE                 IN NUMBER,
                       X_LOCAL_CONTENT_FIRST_FLAG IN VARCHAR2,
                       X_NAME                     IN VARCHAR2,
                       X_DESCRIPTION              IN VARCHAR2,
                       X_LONG_DESCRIPTION         IN VARCHAR2,
                       X_IMAGE                    IN VARCHAR2) IS
        CURSOR c IS
            SELECT SEQUENCE,
                   LOCAL_CONTENT_FIRST_FLAG
            FROM   ICX_CAT_SHOP_STORES_B
            WHERE  STORE_ID = X_STORE_ID
            FOR    UPDATE OF STORE_ID NOWAIT;
        recinfo c%ROWTYPE;

        CURSOR c1 IS
            SELECT NAME,
                   DESCRIPTION,
                   LONG_DESCRIPTION,
                   IMAGE,
                   decode(LANGUAGE,
                          userenv('LANG'),
                          'Y',
                          'N') BASELANG
            FROM   ICX_CAT_SHOP_STORES_TL
            WHERE  STORE_ID = X_STORE_ID
                   AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
            FOR    UPDATE OF STORE_ID NOWAIT;
    BEGIN
        OPEN c;
        FETCH c
            INTO recinfo;
        IF (c%NOTFOUND)
        THEN
            CLOSE c;
            fnd_message.set_name('FND',
                                 'FORM_RECORD_DELETED');
            app_exception.raise_exception;
        END IF;
        CLOSE c;
        IF (((recinfo.SEQUENCE = X_SEQUENCE) OR
           ((recinfo.SEQUENCE IS NULL) AND (X_SEQUENCE IS NULL))) AND
           ((recinfo.LOCAL_CONTENT_FIRST_FLAG = X_LOCAL_CONTENT_FIRST_FLAG) OR
           ((recinfo.LOCAL_CONTENT_FIRST_FLAG IS NULL) AND
           (X_LOCAL_CONTENT_FIRST_FLAG IS NULL))))
        THEN
            NULL;
        ELSE
            fnd_message.set_name('FND',
                                 'FORM_RECORD_CHANGED');
            app_exception.raise_exception;
        END IF;

        FOR tlinfo IN c1
        LOOP
            IF (tlinfo.BASELANG = 'Y')
            THEN
                IF (((tlinfo.NAME = X_NAME) OR
                   ((tlinfo.NAME IS NULL) AND (X_NAME IS NULL))) AND
                   ((tlinfo.DESCRIPTION = X_DESCRIPTION) OR
                   ((tlinfo.DESCRIPTION IS NULL) AND (X_DESCRIPTION IS NULL))) AND
                   ((tlinfo.LONG_DESCRIPTION = X_LONG_DESCRIPTION) OR
                   ((tlinfo.LONG_DESCRIPTION IS NULL) AND
                   (X_LONG_DESCRIPTION IS NULL))) AND
                   ((tlinfo.IMAGE = X_IMAGE) OR
                   ((tlinfo.IMAGE IS NULL) AND (X_IMAGE IS NULL))))
                THEN
                    NULL;
                ELSE
                    fnd_message.set_name('FND',
                                         'FORM_RECORD_CHANGED');
                    app_exception.raise_exception;
                END IF;
            END IF;
        END LOOP;
        RETURN;
    END LOCK_ROW;

    PROCEDURE UPDATE_ROW(X_STORE_ID                 IN NUMBER,
                         X_SEQUENCE                 IN NUMBER,
                         X_LOCAL_CONTENT_FIRST_FLAG IN VARCHAR2,
                         X_NAME                     IN VARCHAR2,
                         X_DESCRIPTION              IN VARCHAR2,
                         X_LONG_DESCRIPTION         IN VARCHAR2,
                         X_IMAGE                    IN VARCHAR2,
                         X_LAST_UPDATE_DATE         IN DATE,
                         X_LAST_UPDATED_BY          IN NUMBER,
                         X_LAST_UPDATE_LOGIN        IN NUMBER) IS
    BEGIN
        UPDATE ICX_CAT_SHOP_STORES_B
        SET    SEQUENCE                 = X_SEQUENCE,
               LOCAL_CONTENT_FIRST_FLAG = X_LOCAL_CONTENT_FIRST_FLAG,
               LAST_UPDATE_DATE         = X_LAST_UPDATE_DATE,
               LAST_UPDATED_BY          = X_LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN        = X_LAST_UPDATE_LOGIN
        WHERE  STORE_ID = X_STORE_ID;

        IF (SQL%NOTFOUND)
        THEN
            RAISE no_data_found;
        END IF;

        UPDATE ICX_CAT_SHOP_STORES_TL
        SET    NAME              = X_NAME,
               DESCRIPTION       = X_DESCRIPTION,
               LONG_DESCRIPTION  = X_LONG_DESCRIPTION,
               IMAGE             = X_IMAGE,
               LAST_UPDATE_DATE  = X_LAST_UPDATE_DATE,
               LAST_UPDATED_BY   = X_LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
               SOURCE_LANG       = userenv('LANG')
        WHERE  STORE_ID = X_STORE_ID
               AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

        IF (SQL%NOTFOUND)
        THEN
            RAISE no_data_found;
        END IF;
    END UPDATE_ROW;

    PROCEDURE TRANSLATE_ROW(X_STORE_ID         IN VARCHAR2,
                            X_OWNER            IN VARCHAR2,
                            X_NAME             IN VARCHAR2,
                            X_DESCRIPTION      IN VARCHAR2,
                            X_LONG_DESCRIPTION IN VARCHAR2,
                            X_IMAGE            IN VARCHAR2,
                            X_CUSTOM_MODE      IN VARCHAR2,
                            X_LAST_UPDATE_DATE IN VARCHAR2) IS
    BEGIN
        DECLARE
            f_luby    NUMBER; -- entity owner in file
            f_ludate  DATE; -- entity update in file
            db_luby   NUMBER; -- entity owner in db
            db_ludate DATE; -- entity update in db
        BEGIN
            -- Translate owner to file_last_updated_by
            f_luby   := fnd_load_util.OWNER_ID(X_OWNER);
            f_ludate := nvl(to_date(X_LAST_UPDATE_DATE,
                                    'YYYY/MM/DD'),
                            SYSDATE);

            SELECT LAST_UPDATED_BY,
                   LAST_UPDATE_DATE
            INTO   db_luby,
                   db_ludate
            FROM   ICX_CAT_SHOP_STORES_TL
            WHERE  LANGUAGE = userenv('LANG')
                   AND STORE_ID = to_number(X_STORE_ID);


            -- Bug : 6120281 - Start
            -- Seed data was loaded with wrong OWNER. So updated_by column in db was having -1. Which should be treated as seeded for the seeded rows with id 1,2
           IF db_luby = -1 and f_luby <> -1 and to_number(X_STORE_ID) in (1,2) THEN
                db_luby := f_luby;
           END IF;
            -- Bug : 6120281 - End


            -- Update record, honoring customization mode.
            -- Record should be updated only if:
            -- a. CUSTOM_MODE = FORCE, or
            -- b. file owner is CUSTOM, db owner is SEED
            -- c. owners are the same, and file_date > db_date
            IF (fnd_load_util.UPLOAD_TEST(p_file_id     => f_luby,
                                          p_file_lud    => f_ludate,
                                          p_db_id       => db_luby,
                                          p_db_lud      => db_ludate,
                                          p_custom_mode => X_CUSTOM_MODE))
            THEN
                UPDATE ICX_CAT_SHOP_STORES_TL
                SET    NAME              = nvl(X_NAME,
                                               NAME),
                       DESCRIPTION       = nvl(X_DESCRIPTION,
                                               DESCRIPTION),
                       LONG_DESCRIPTION  = nvl(X_LONG_DESCRIPTION,
                                               LONG_DESCRIPTION),
                       IMAGE             = nvl(X_IMAGE,
                                               IMAGE),
                       last_update_date  = f_ludate,
                       last_updated_by   = f_luby,
                       last_update_login = 0,
                       source_lang       = userenv('LANG')
                WHERE  STORE_ID = to_number(X_STORE_ID)
                       AND userenv('LANG') IN (LANGUAGE, source_lang);
            END IF;
        END;

    END TRANSLATE_ROW;


    PROCEDURE LOAD_ROW(X_STORE_ID         IN VARCHAR2,
                       X_OWNER            IN VARCHAR2,
                       X_SEQUENCE         IN VARCHAR2,
                       X_LOCAL_CONTENT_FIRST_FLAG IN VARCHAR2,
                       X_NAME             IN VARCHAR2,
                       X_DESCRIPTION      IN VARCHAR2,
                       X_LONG_DESCRIPTION IN VARCHAR2,
                       X_IMAGE            IN VARCHAR2,
                       X_CUSTOM_MODE      IN VARCHAR2,
                       X_LAST_UPDATE_DATE IN VARCHAR2) IS
    BEGIN

        DECLARE
            row_id    VARCHAR2(64);
            f_luby    NUMBER; -- entity owner in file
            f_ludate  DATE; -- entity update in file
            db_luby   NUMBER; -- entity owner in db
            db_ludate DATE; -- entity update in db

        BEGIN
            -- Translate owner to file_last_updated_by
            f_luby   := fnd_load_util.OWNER_ID(X_OWNER);
            f_ludate := nvl(to_date(X_LAST_UPDATE_DATE,
                                    'YYYY/MM/DD'),
                            SYSDATE);

            SELECT LAST_UPDATED_BY,
                   LAST_UPDATE_DATE
            INTO   db_luby,
                   db_ludate
            FROM   ICX_CAT_SHOP_STORES_TL
            WHERE  LANGUAGE = userenv('LANG')
                   AND STORE_ID = to_number(X_STORE_ID);

            -- Bug : 6120281 - Start
            -- Seed data was loaded with wrong OWNER. So updated_by column in db was having -1. Which should be treated as seeded for the seeded rows with id 1,2
           IF db_luby = -1 and f_luby <> -1 and to_number(X_STORE_ID) in (1,2) THEN
                db_luby := f_luby;
           END IF;
            -- Bug : 6120281 - End

            -- Update record, honoring customization mode.
            -- Record should be updated only if:
            -- a. CUSTOM_MODE = FORCE, or
            -- b. file owner is CUSTOM, db owner is SEED
            -- c. owners are the same, and file_date > db_date
            IF (fnd_load_util.UPLOAD_TEST(p_file_id     => f_luby,
                                          p_file_lud    => f_ludate,
                                          p_db_id       => db_luby,
                                          p_db_lud      => db_ludate,
                                          p_custom_mode => X_CUSTOM_MODE))
            THEN
                ICX_CAT_SHOP_STORES_PVT.UPDATE_ROW(X_STORE_ID                 => to_number(X_STORE_ID),
                                                   X_SEQUENCE                 => to_number(X_SEQUENCE),
                                                   X_LOCAL_CONTENT_FIRST_FLAG => X_LOCAL_CONTENT_FIRST_FLAG,
                                                   X_NAME                     => X_NAME,
                                                   X_DESCRIPTION              => X_DESCRIPTION,
                                                   X_LONG_DESCRIPTION         => X_LONG_DESCRIPTION,
                                                   X_IMAGE                    => X_IMAGE,
                                                   X_LAST_UPDATE_DATE         => f_ludate,
                                                   X_LAST_UPDATED_BY          => f_luby,
                                                   X_LAST_UPDATE_LOGIN        => 0);
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN

                ICX_CAT_SHOP_STORES_PVT.INSERT_ROW(X_ROWID                    => row_id,
                                                   X_STORE_ID                 => to_number(X_STORE_ID),
                                                   X_SEQUENCE                 => to_number(X_SEQUENCE),
                                                   X_LOCAL_CONTENT_FIRST_FLAG => X_LOCAL_CONTENT_FIRST_FLAG,
                                                   X_NAME                     => X_NAME,
                                                   X_DESCRIPTION              => X_DESCRIPTION,
                                                   X_LONG_DESCRIPTION         => X_LONG_DESCRIPTION,
                                                   X_IMAGE                    => X_IMAGE,
                                                   X_CREATION_DATE            => f_ludate,
                                                   X_CREATED_BY               => f_luby,
                                                   X_LAST_UPDATE_DATE         => f_ludate,
                                                   X_LAST_UPDATED_BY          => f_luby,
                                                   X_LAST_UPDATE_LOGIN        => 0);
        END;
    END LOAD_ROW;

    PROCEDURE DELETE_ROW(X_STORE_ID IN NUMBER) IS
    BEGIN
        DELETE FROM ICX_CAT_SHOP_STORES_TL
        WHERE  STORE_ID = X_STORE_ID;

        IF (SQL%NOTFOUND)
        THEN
            RAISE no_data_found;
        END IF;

        DELETE FROM ICX_CAT_SHOP_STORES_B
        WHERE  STORE_ID = X_STORE_ID;

        IF (SQL%NOTFOUND)
        THEN
            RAISE no_data_found;
        END IF;
    END DELETE_ROW;

    PROCEDURE ADD_LANGUAGE IS
    BEGIN
        DELETE FROM ICX_CAT_SHOP_STORES_TL T
        WHERE  NOT EXISTS (SELECT NULL
                FROM   ICX_CAT_SHOP_STORES_B B
                WHERE  B.STORE_ID = T.STORE_ID);

        UPDATE ICX_CAT_SHOP_STORES_TL T
        SET    (NAME, DESCRIPTION, LONG_DESCRIPTION, IMAGE) = (SELECT B.NAME,
                                                                      B.DESCRIPTION,
                                                                      B.LONG_DESCRIPTION,
                                                                      B.IMAGE
                                                               FROM   ICX_CAT_SHOP_STORES_TL B
                                                               WHERE  B.STORE_ID =
                                                                      T.STORE_ID
                                                                      AND
                                                                      B.LANGUAGE =
                                                                      T.SOURCE_LANG)
        WHERE  (T.STORE_ID, T.LANGUAGE) IN
               (SELECT SUBT.STORE_ID,
                       SUBT.LANGUAGE
                FROM   ICX_CAT_SHOP_STORES_TL SUBB,
                       ICX_CAT_SHOP_STORES_TL SUBT
                WHERE  SUBB.STORE_ID = SUBT.STORE_ID
                       AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                       AND (SUBB.NAME <> SUBT.NAME OR
                       (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL) OR
                       (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL) OR
                       SUBB.DESCRIPTION <> SUBT.DESCRIPTION OR
                       (SUBB.DESCRIPTION IS NULL AND
                       SUBT.DESCRIPTION IS NOT NULL) OR
                       (SUBB.DESCRIPTION IS NOT NULL AND
                       SUBT.DESCRIPTION IS NULL) OR
                       SUBB.LONG_DESCRIPTION <> SUBT.LONG_DESCRIPTION OR
                       (SUBB.LONG_DESCRIPTION IS NULL AND
                       SUBT.LONG_DESCRIPTION IS NOT NULL) OR
                       (SUBB.LONG_DESCRIPTION IS NOT NULL AND
                       SUBT.LONG_DESCRIPTION IS NULL) OR
                       SUBB.IMAGE <> SUBT.IMAGE OR
                       (SUBB.IMAGE IS NULL AND SUBT.IMAGE IS NOT NULL) OR
                       (SUBB.IMAGE IS NOT NULL AND SUBT.IMAGE IS NULL)));

        INSERT INTO ICX_CAT_SHOP_STORES_TL
            (STORE_ID,
             NAME,
             DESCRIPTION,
             LONG_DESCRIPTION,
             IMAGE,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             LANGUAGE,
             SOURCE_LANG)
            SELECT /*+ ORDERED */
             B.STORE_ID,
             B.NAME,
             B.DESCRIPTION,
             B.LONG_DESCRIPTION,
             B.IMAGE,
             B.CREATED_BY,
             B.CREATION_DATE,
             B.LAST_UPDATED_BY,
             B.LAST_UPDATE_DATE,
             B.LAST_UPDATE_LOGIN,
             L.LANGUAGE_CODE,
             B.SOURCE_LANG
            FROM   ICX_CAT_SHOP_STORES_TL B,
                   FND_LANGUAGES          L
            WHERE  L.INSTALLED_FLAG IN ('I', 'B')
                   AND B.LANGUAGE = userenv('LANG')
                   AND NOT EXISTS
             (SELECT NULL
                    FROM   ICX_CAT_SHOP_STORES_TL T
                    WHERE  T.STORE_ID = B.STORE_ID
                           AND T.LANGUAGE = L.LANGUAGE_CODE);
    END ADD_LANGUAGE;

END ICX_CAT_SHOP_STORES_PVT;

/
