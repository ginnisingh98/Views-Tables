--------------------------------------------------------
--  DDL for Package Body ICX_CAT_CONTENT_ZONES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_CONTENT_ZONES_PVT" AS
    /* $Header: ICXVZNEB.pls 120.8.12000000.3 2007/09/19 17:30:16 kkram ship $ */

    PROCEDURE INSERT_ROW(X_ROWID                          IN OUT NOCOPY VARCHAR2,
                         X_ZONE_ID                        IN NUMBER,
                         X_TYPE                           IN VARCHAR2,
                         X_URL                            IN VARCHAR2,
                         X_IMAGE                          IN VARCHAR2,
                         X_NAME                           IN VARCHAR2,
                         X_DESCRIPTION                    IN VARCHAR2,
                         X_SUPPLIER_ATTRIBUTE_ACTION IN VARCHAR2,
                         X_CATEGORY_ATTRIBUTE_ACTION IN VARCHAR2,
                         X_ITEMS_WITHOUT_SUPPLIER    IN VARCHAR2,
                         X_ITEMS_WITHOUT_SHOP_CATG   IN VARCHAR2,
                         X_SECURITY_ASSIGNMENT_FLAG     IN VARCHAR2,
                         X_CREATION_DATE                  IN DATE,
                         X_CREATED_BY                     IN NUMBER,
                         X_LAST_UPDATE_DATE               IN DATE,
                         X_LAST_UPDATED_BY                IN NUMBER,
                         X_LAST_UPDATE_LOGIN              IN NUMBER) IS
        CURSOR C IS
            SELECT ROWID
            FROM   ICX_CAT_CONTENT_ZONES_B
            WHERE  ZONE_ID = X_ZONE_ID;
    BEGIN

        INSERT INTO ICX_CAT_CONTENT_ZONES_B
            (ZONE_ID,
             TYPE,
             URL,
             SUPPLIER_ATTRIBUTE_ACTION_FLAG,
             CATEGORY_ATTRIBUTE_ACTION_FLAG,
             ITEMS_WITHOUT_SUPPLIER_FLAG,
             ITEMS_WITHOUT_SHOP_CATG_FLAG,
             SECURITY_ASSIGNMENT_FLAG,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN)
        VALUES
            (X_ZONE_ID,
             X_TYPE,
             X_URL,
             X_SUPPLIER_ATTRIBUTE_ACTION,
             X_CATEGORY_ATTRIBUTE_ACTION,
             X_ITEMS_WITHOUT_SUPPLIER,
             X_ITEMS_WITHOUT_SHOP_CATG,
             X_SECURITY_ASSIGNMENT_FLAG,
             X_CREATION_DATE,
             X_CREATED_BY,
             X_LAST_UPDATE_DATE,
             X_LAST_UPDATED_BY,
             X_LAST_UPDATE_LOGIN);

        INSERT INTO ICX_CAT_CONTENT_ZONES_TL
            (ZONE_ID,
             NAME,
             DESCRIPTION,
	     IMAGE,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             LANGUAGE,
             SOURCE_LANG)
            SELECT X_ZONE_ID,
                   X_NAME,
                   X_DESCRIPTION,
		   X_IMAGE,
                   X_CREATION_DATE,
                   X_CREATED_BY,
                   X_LAST_UPDATE_DATE,
                   X_LAST_UPDATED_BY,
                   X_LAST_UPDATE_LOGIN,
                   L.LANGUAGE_CODE,
                   userenv('LANG')
            FROM   FND_LANGUAGES L
            WHERE  L.INSTALLED_FLAG IN ('I', 'B')
                   AND NOT EXISTS
             (SELECT NULL
                    FROM   ICX_CAT_CONTENT_ZONES_TL T
                    WHERE  T.ZONE_ID = X_ZONE_ID
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

    PROCEDURE UPDATE_ROW(X_ZONE_ID                        IN NUMBER,
                         X_TYPE                           IN VARCHAR2,
                         X_URL                            IN VARCHAR2,
                         X_IMAGE                          IN VARCHAR2,
                         X_NAME                           IN VARCHAR2,
                         X_DESCRIPTION                    IN VARCHAR2,
                         X_SUPPLIER_ATTRIBUTE_ACTION IN VARCHAR2,
                         X_CATEGORY_ATTRIBUTE_ACTION IN VARCHAR2,
                         X_ITEMS_WITHOUT_SUPPLIER IN VARCHAR2,
                         X_ITEMS_WITHOUT_SHOP_CATG   IN VARCHAR2,
                         X_SECURITY_ASSIGNMENT_FLAG     IN VARCHAR2,
                         X_LAST_UPDATE_DATE               IN DATE,
                         X_LAST_UPDATED_BY                IN NUMBER,
                         X_LAST_UPDATE_LOGIN              IN NUMBER) IS
    BEGIN
        UPDATE ICX_CAT_CONTENT_ZONES_TL
        SET    NAME              = X_NAME,
               DESCRIPTION       = X_DESCRIPTION,
	       IMAGE             = X_IMAGE,
               LAST_UPDATE_DATE  = X_LAST_UPDATE_DATE,
               LAST_UPDATED_BY   = X_LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
               SOURCE_LANG       = userenv('LANG')
        WHERE  ZONE_ID = X_ZONE_ID
               AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

        IF (SQL%NOTFOUND)
        THEN
            INSERT INTO ICX_CAT_CONTENT_ZONES_TL
                (ZONE_ID,
                 NAME,
                 DESCRIPTION,
		 IMAGE,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 LANGUAGE,
                 SOURCE_LANG)
            VALUES
                (X_ZONE_ID,
                 X_NAME,
                 X_DESCRIPTION,
		 X_IMAGE,
                 X_LAST_UPDATE_DATE,
                 X_LAST_UPDATED_BY,
                 X_LAST_UPDATE_DATE,
                 X_LAST_UPDATED_BY,
                 X_LAST_UPDATE_LOGIN,
                 userenv('LANG'),
                 userenv('LANG'));
        END IF;
    END UPDATE_ROW;

    PROCEDURE TRANSLATE_ROW(X_ZONE_ID          IN VARCHAR2,
                            X_OWNER            IN VARCHAR2,
                            X_NAME             IN VARCHAR2,
                            X_DESCRIPTION      IN VARCHAR2,
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
            FROM   ICX_CAT_CONTENT_ZONES_TL
            WHERE  LANGUAGE = userenv('LANG')
                   AND ZONE_ID = to_number(X_ZONE_ID);

            -- Bug : 6120281 - Start
            -- Seed data was loaded with wrong OWNER. So updated_by column in db was having -1. Which should be treated as seeded for the seeded rows with id 1,2
           IF db_luby = -1 and f_luby <> -1 and to_number(X_ZONE_ID) in (1,2) THEN
                db_luby := f_luby;
           END IF;
            -- Bug : 6120281 - Start


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
                UPDATE ICX_CAT_CONTENT_ZONES_tl
                SET    NAME              = nvl(X_NAME,
                                               NAME),
                       description       = nvl(X_DESCRIPTION,
                                               DESCRIPTION),
		       image             = nvl(X_IMAGE,
		                               IMAGE),
                       last_update_date  = f_ludate,
                       last_updated_by   = f_luby,
                       last_update_login = 0,
                       source_lang       = userenv('LANG')
                WHERE  ZONE_ID = to_number(X_ZONE_ID)
                       AND userenv('LANG') IN (LANGUAGE, source_lang);
            END IF;
        END;

    END TRANSLATE_ROW;

    PROCEDURE LOAD_ROW(X_ZONE_ID                        IN VARCHAR2,
                       X_OWNER                          IN VARCHAR2,
                       X_NAME                           IN VARCHAR2,
                       X_DESCRIPTION                    IN VARCHAR2,
                       X_TYPE                           IN VARCHAR2,
                       X_URL                            IN VARCHAR2,
                       X_IMAGE                          IN VARCHAR2,
                       X_SUPPLIER_ATTRIBUTE_ACTION IN VARCHAR2,
                       X_CATEGORY_ATTRIBUTE_ACTION IN VARCHAR2,
                       X_ITEMS_WITHOUT_SUPPLIER    IN VARCHAR2,
                       X_ITEMS_WITHOUT_SHOP_CATG   IN VARCHAR2,
                       X_SECURITY_ASSIGNMENT_FLAG     IN VARCHAR2,
                       X_CUSTOM_MODE                    IN VARCHAR2,
                       X_LAST_UPDATE_DATE               IN VARCHAR2) IS
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
            FROM   ICX_CAT_CONTENT_ZONES_TL
            WHERE  LANGUAGE = userenv('LANG')
                   AND ZONE_ID = to_number(X_ZONE_ID);

            -- Bug#3219138
            -- Always update the Type supported
            -- irrespective of customization. Cst should not change the
            -- type supported values.
            UPDATE ICX_CAT_CONTENT_ZONES_B
            SET    TYPE                           = X_TYPE,
                   URL                            = X_URL,
                   SUPPLIER_ATTRIBUTE_ACTION_FLAG = X_SUPPLIER_ATTRIBUTE_ACTION,
                   CATEGORY_ATTRIBUTE_ACTION_FLAG = X_CATEGORY_ATTRIBUTE_ACTION,
                   ITEMS_WITHOUT_SUPPLIER_FLAG    = X_ITEMS_WITHOUT_SUPPLIER,
                   ITEMS_WITHOUT_SHOP_CATG_FLAG   = X_ITEMS_WITHOUT_SHOP_CATG,
                   SECURITY_ASSIGNMENT_FLAG     = X_SECURITY_ASSIGNMENT_FLAG,
                   LAST_UPDATE_DATE               = f_ludate,
                   LAST_UPDATED_BY                = f_luby,
                   LAST_UPDATE_LOGIN              = 0
            WHERE  ZONE_ID = X_ZONE_ID;

            IF (SQL%NOTFOUND)
            THEN
                RAISE no_data_found;
            END IF;

            -- Bug : 6120281 - Start
            -- Seed data was loaded with wrong OWNER. So updated_by column in db was having -1. Which should be treated as seeded for the seeded rows with id 1,2
           IF db_luby = -1 and f_luby <> -1 and to_number(X_ZONE_ID) in (1,2) THEN
                db_luby := f_luby;
           END IF;
            -- Bug : 6120281 - Start


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
                ICX_CAT_CONTENT_ZONES_PVT.UPDATE_ROW(X_ZONE_ID                        => to_number(X_ZONE_ID),
                                                     X_TYPE                           => X_TYPE,
                                                     X_URL                            => X_URL,
                                                     X_IMAGE                          => X_IMAGE,
                                                     X_NAME                           => X_NAME,
                                                     X_DESCRIPTION                    => X_DESCRIPTION,
                                                     X_SUPPLIER_ATTRIBUTE_ACTION => X_SUPPLIER_ATTRIBUTE_ACTION,
                                                     X_CATEGORY_ATTRIBUTE_ACTION => X_CATEGORY_ATTRIBUTE_ACTION,
                                                     X_ITEMS_WITHOUT_SUPPLIER => X_ITEMS_WITHOUT_SUPPLIER,
                                                     X_ITEMS_WITHOUT_SHOP_CATG   => X_ITEMS_WITHOUT_SHOP_CATG,
                                                     X_SECURITY_ASSIGNMENT_FLAG     => X_SECURITY_ASSIGNMENT_FLAG,
                                                     X_LAST_UPDATE_DATE               => f_ludate,
                                                     X_LAST_UPDATED_BY                => f_luby,
                                                     X_LAST_UPDATE_LOGIN              => 0);
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                ICX_CAT_CONTENT_ZONES_PVT.INSERT_ROW(X_ROWID                          => row_id,
                                                     X_ZONE_ID                        => to_number(X_ZONE_ID),
                                                     X_TYPE                           => X_TYPE,
                                                     X_URL                            => X_URL,
                                                     X_IMAGE                          => X_IMAGE,
                                                     X_NAME                           => X_NAME,
                                                     X_DESCRIPTION                    => X_DESCRIPTION,
                                                     X_SUPPLIER_ATTRIBUTE_ACTION => X_SUPPLIER_ATTRIBUTE_ACTION,
                                                     X_CATEGORY_ATTRIBUTE_ACTION => X_CATEGORY_ATTRIBUTE_ACTION,
                                                     X_ITEMS_WITHOUT_SUPPLIER => X_ITEMS_WITHOUT_SUPPLIER,
                                                     X_ITEMS_WITHOUT_SHOP_CATG   => X_ITEMS_WITHOUT_SHOP_CATG,
                                                     X_SECURITY_ASSIGNMENT_FLAG     => X_SECURITY_ASSIGNMENT_FLAG,
                                                     X_CREATION_DATE                  => f_ludate,
                                                     X_CREATED_BY                     => f_luby,
                                                     X_LAST_UPDATE_DATE               => f_ludate,
                                                     X_LAST_UPDATED_BY                => f_luby,
                                                     X_LAST_UPDATE_LOGIN              => 0);
        END;
    END LOAD_ROW;

    PROCEDURE ADD_LANGUAGE IS
    BEGIN
        DELETE FROM ICX_CAT_CONTENT_ZONES_TL T
        WHERE  NOT EXISTS (SELECT NULL
                FROM   ICX_CAT_CONTENT_ZONES_B B
                WHERE  B.ZONE_ID = T.ZONE_ID);

        INSERT INTO ICX_CAT_CONTENT_ZONES_TL
            (LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             ZONE_ID,
             NAME,
             DESCRIPTION,
	     IMAGE,
             LANGUAGE,
             SOURCE_LANG)
            SELECT B.LAST_UPDATE_LOGIN,
                   B.LAST_UPDATE_DATE,
                   B.LAST_UPDATED_BY,
                   B.CREATION_DATE,
                   B.CREATED_BY,
                   B.ZONE_ID,
                   B.NAME,
                   B.DESCRIPTION,
		   B.IMAGE,
                   L.LANGUAGE_CODE,
                   B.SOURCE_LANG
            FROM   ICX_CAT_CONTENT_ZONES_TL B,
                   FND_LANGUAGES            L
            WHERE  L.INSTALLED_FLAG IN ('I', 'B')
                   AND B.LANGUAGE = userenv('LANG')
                   AND NOT EXISTS
             (SELECT NULL
                    FROM   ICX_CAT_CONTENT_ZONES_TL T
                    WHERE  T.ZONE_ID = B.ZONE_ID
                           AND T.LANGUAGE = L.LANGUAGE_CODE);
    END ADD_LANGUAGE;

END ICX_CAT_CONTENT_ZONES_PVT;

/
