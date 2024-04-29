--------------------------------------------------------
--  DDL for Package Body ICX_CAT_ATTRIBUTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_ATTRIBUTES_PVT" AS
    /* $Header: ICXVATRB.pls 120.3.12010000.2 2012/03/21 09:06:44 rkandima ship $ */

    PROCEDURE INSERT_ROW(X_ROWID                  IN OUT NOCOPY VARCHAR2,
                         X_ATTRIBUTE_ID           IN NUMBER,
                         X_KEY                    IN VARCHAR2,
                         X_ATTRIBUTE_NAME         IN VARCHAR2,
                         X_DESCRIPTION            IN VARCHAR2,
                         X_RT_CATEGORY_ID         IN NUMBER,
                         X_TYPE                   IN NUMBER,
                         X_SEARCH_RESULTS_VISIBLE IN VARCHAR2,
                         X_ITEM_DETAIL_VISIBLE    IN VARCHAR2,
                         X_SEARCHABLE             IN NUMBER,
                         X_SEQUENCE               IN NUMBER,
                         X_CREATED_BY             IN NUMBER,
                         X_CREATION_DATE          IN DATE,
                         X_LAST_UPDATED_BY        IN NUMBER,
                         X_LAST_UPDATE_DATE       IN DATE,
                         X_LAST_UPDATE_LOGIN      IN NUMBER,
                         X_REQUEST_ID             IN NUMBER,
                         X_PROGRAM_APPLICATION_ID IN NUMBER,
                         X_PROGRAM_ID             IN NUMBER,
                         X_STORED_IN_TABLE        IN VARCHAR2,
                         X_STORED_IN_COLUMN       IN VARCHAR2,
                         X_SECTION_TAG            IN NUMBER) IS
        CURSOR C IS
            SELECT ROWID
            FROM   ICX_CAT_ATTRIBUTES_TL
            WHERE  ATTRIBUTE_ID = X_ATTRIBUTE_ID
                   AND LANGUAGE = userenv('LANG');
    BEGIN
        INSERT INTO ICX_CAT_ATTRIBUTES_TL
            (ATTRIBUTE_ID,
             KEY,
             ATTRIBUTE_NAME,
             DESCRIPTION,
             RT_CATEGORY_ID,
             TYPE,
             SEARCH_RESULTS_VISIBLE,
             ITEM_DETAIL_VISIBLE,
             SEARCHABLE,
             SEQUENCE,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             LANGUAGE,
             SOURCE_LANG,
             STORED_IN_TABLE,
             STORED_IN_COLUMN,
             SECTION_TAG)
            SELECT X_ATTRIBUTE_ID,
                   X_KEY,
                   X_ATTRIBUTE_NAME,
                   X_DESCRIPTION,
                   X_RT_CATEGORY_ID,
                   X_TYPE,
                   X_SEARCH_RESULTS_VISIBLE,
                   X_ITEM_DETAIL_VISIBLE,
                   X_SEARCHABLE,
                   X_SEQUENCE,
                   X_CREATED_BY,
                   X_CREATION_DATE,
                   X_LAST_UPDATED_BY,
                   X_LAST_UPDATE_DATE,
                   X_LAST_UPDATE_LOGIN,
                   X_REQUEST_ID,
                   X_PROGRAM_APPLICATION_ID,
                   X_PROGRAM_ID,
                   L.LANGUAGE_CODE,
                   userenv('LANG'),
                   X_STORED_IN_TABLE,
                   X_STORED_IN_COLUMN,
                   X_SECTION_TAG
            FROM   FND_LANGUAGES L
            WHERE  L.INSTALLED_FLAG IN ('I', 'B')
                   AND NOT EXISTS
             (SELECT NULL
                    FROM   ICX_CAT_ATTRIBUTES_TL T
                    WHERE  T.ATTRIBUTE_ID = X_ATTRIBUTE_ID
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

    PROCEDURE LOCK_ROW(X_ATTRIBUTE_ID           IN NUMBER,
                       X_KEY                    IN VARCHAR2,
                       X_ATTRIBUTE_NAME         IN VARCHAR2,
                       X_DESCRIPTION            IN VARCHAR2,
                       X_RT_CATEGORY_ID         IN NUMBER,
                       X_TYPE                   IN NUMBER,
                       X_SEARCH_RESULTS_VISIBLE IN VARCHAR2,
                       X_ITEM_DETAIL_VISIBLE    IN VARCHAR2,
                       X_SEARCHABLE             IN NUMBER,
                       X_SEQUENCE               IN NUMBER) IS
        CURSOR c1 IS
            SELECT ATTRIBUTE_ID,
                   KEY,
                   ATTRIBUTE_NAME,
                   DESCRIPTION,
                   RT_CATEGORY_ID,
                   TYPE,
                   SEARCH_RESULTS_VISIBLE,
                   ITEM_DETAIL_VISIBLE,
                   SEARCHABLE,
                   SEQUENCE,
                   decode(LANGUAGE,
                          userenv('LANG'),
                          'Y',
                          'N') BASELANG
            FROM   ICX_CAT_ATTRIBUTES_TL
            WHERE  ATTRIBUTE_ID = X_ATTRIBUTE_ID
                   AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
            FOR    UPDATE OF ATTRIBUTE_ID NOWAIT;
    BEGIN
        FOR tlinfo IN c1
        LOOP
            IF (tlinfo.BASELANG = 'Y')
            THEN
                IF ((tlinfo.KEY = X_KEY) AND
                   (tlinfo.ATTRIBUTE_NAME = X_ATTRIBUTE_NAME) AND
                   ((tlinfo.DESCRIPTION = X_DESCRIPTION) OR
                   ((tlinfo.DESCRIPTION IS NULL) AND (X_DESCRIPTION IS NULL))) AND
                   (tlinfo.RT_CATEGORY_ID = X_RT_CATEGORY_ID) AND
                   (tlinfo.TYPE = X_TYPE) AND
                   ((tlinfo.SEARCH_RESULTS_VISIBLE = X_SEARCH_RESULTS_VISIBLE) OR
                   ((tlinfo.SEARCH_RESULTS_VISIBLE IS NULL) AND
                   (X_SEARCH_RESULTS_VISIBLE IS NULL))) AND
                   ((tlinfo.ITEM_DETAIL_VISIBLE = X_ITEM_DETAIL_VISIBLE) OR
                   ((tlinfo.ITEM_DETAIL_VISIBLE IS NULL) AND
                   (X_ITEM_DETAIL_VISIBLE IS NULL))) AND
                   ((tlinfo.SEARCHABLE = X_SEARCHABLE) OR
                   ((tlinfo.SEARCHABLE IS NULL) AND (X_SEARCHABLE IS NULL))) AND
                   ((tlinfo.SEQUENCE = X_SEQUENCE) OR
                   ((tlinfo.SEQUENCE IS NULL) AND (X_SEQUENCE IS NULL))))
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

    PROCEDURE UPDATE_ROW(X_ATTRIBUTE_ID           IN NUMBER,
                         X_KEY                    IN VARCHAR2,
                         X_ATTRIBUTE_NAME         IN VARCHAR2,
                         X_DESCRIPTION            IN VARCHAR2,
                         X_RT_CATEGORY_ID         IN NUMBER,
                         X_TYPE                   IN NUMBER,
                         X_SEARCH_RESULTS_VISIBLE IN VARCHAR2,
                         X_ITEM_DETAIL_VISIBLE    IN VARCHAR2,
                         X_SEARCHABLE             IN NUMBER,
                         X_SEQUENCE               IN NUMBER,
                         X_LAST_UPDATED_BY        IN NUMBER,
                         X_LAST_UPDATE_DATE       IN DATE,
                         X_LAST_UPDATE_LOGIN      IN NUMBER,
                         X_REQUEST_ID             IN NUMBER,
                         X_PROGRAM_APPLICATION_ID IN NUMBER,
                         X_PROGRAM_ID             IN NUMBER,
                         X_STORED_IN_TABLE        IN VARCHAR2,
                         X_STORED_IN_COLUMN       IN VARCHAR2,
                         X_SECTION_TAG            IN NUMBER) IS
    BEGIN
        --Attributes that are not translated i.e rt_category_id, key, type,
        --search_resuls_visible, item_detail_visible, required, refinable,
        --searchable, sequence, stored_in_table, stored_in_column,
        --section_tag and class should be updated
        --for all rows irrespective of the language and source_lang
        --So changed the update statement into two update statements,
        --first sql non-translated values only for those descriptors which are
        --not customized i.e. for a descriptor there should
        --be no row with the last_updated_by <> -1.
        --and the secpnd sql updates the translated values, for the descriptors
        --which were not already translated by the customers
        --due the clause (userenv('LANG') in (LANGUAGE, SOURCE_LANG))
        UPDATE ICX_CAT_ATTRIBUTES_TL o
        SET    KEY                    = X_KEY,
               RT_CATEGORY_ID         = X_RT_CATEGORY_ID,
               TYPE                   = X_TYPE,
               SEARCH_RESULTS_VISIBLE = X_SEARCH_RESULTS_VISIBLE,
               ITEM_DETAIL_VISIBLE    = X_ITEM_DETAIL_VISIBLE,
               SEARCHABLE             = X_SEARCHABLE,
               SEQUENCE               = X_SEQUENCE,
               LAST_UPDATED_BY        = X_LAST_UPDATED_BY,
               LAST_UPDATE_DATE       = X_LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN      = X_LAST_UPDATE_LOGIN,
               REQUEST_ID             = X_REQUEST_ID,
               PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
               PROGRAM_ID             = X_PROGRAM_ID,
               STORED_IN_TABLE        = X_STORED_IN_TABLE,
               STORED_IN_COLUMN       = X_STORED_IN_COLUMN,
               SECTION_TAG            = X_SECTION_TAG
        WHERE  ATTRIBUTE_ID = X_ATTRIBUTE_ID
               AND NOT EXISTS (SELECT NULL
                FROM   ICX_CAT_ATTRIBUTES_TL i
                WHERE  i.ATTRIBUTE_ID = o.ATTRIBUTE_ID
                       AND i.LAST_UPDATED_BY <> -1);

        UPDATE ICX_CAT_ATTRIBUTES_TL
        SET    ATTRIBUTE_NAME         = X_ATTRIBUTE_NAME,
               DESCRIPTION            = X_DESCRIPTION,
               LAST_UPDATED_BY        = X_LAST_UPDATED_BY,
               LAST_UPDATE_DATE       = X_LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN      = X_LAST_UPDATE_LOGIN,
               REQUEST_ID             = X_REQUEST_ID,
               PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
               PROGRAM_ID             = X_PROGRAM_ID,
               SOURCE_LANG            = userenv('LANG')
        WHERE  ATTRIBUTE_ID = X_ATTRIBUTE_ID
               AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

        IF (SQL%NOTFOUND)
        THEN
            RAISE no_data_found;
        END IF;
    END UPDATE_ROW;

    PROCEDURE DELETE_ROW(X_ATTRIBUTE_ID IN NUMBER) IS
    BEGIN
        DELETE FROM ICX_CAT_ATTRIBUTES_TL
        WHERE  ATTRIBUTE_ID = X_ATTRIBUTE_ID;

        IF (SQL%NOTFOUND)
        THEN
            RAISE no_data_found;
        END IF;

    END DELETE_ROW;

    PROCEDURE TRANSLATE_ROW(X_ATTRIBUTE_ID      IN VARCHAR2,
                            X_OWNER             IN VARCHAR2,
                            X_ATTRIBUTE_NAME    IN VARCHAR2,
                            X_DESCRIPTION       IN VARCHAR2,
                            X_CUSTOM_MODE       IN VARCHAR2,
                            X_LAST_UPDATE_DATE  IN VARCHAR2) IS
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
            FROM   ICX_CAT_ATTRIBUTES_TL
            WHERE  LANGUAGE = userenv('LANG')
                   AND ATTRIBUTE_ID = to_number(X_ATTRIBUTE_ID);

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
                UPDATE ICX_CAT_ATTRIBUTES_TL
                SET    ATTRIBUTE_NAME    = nvl(X_ATTRIBUTE_NAME,
                                               ATTRIBUTE_NAME),
                       description       = nvl(X_DESCRIPTION,
                                               DESCRIPTION),
                       source_lang       = userenv('LANG'),
                       last_update_date  = f_ludate,
                       last_updated_by   = f_luby,
                       last_update_login = 0
                WHERE  ATTRIBUTE_ID = to_number(X_ATTRIBUTE_ID)
                       AND userenv('LANG') IN (LANGUAGE, source_lang);

            END IF;
        END;

    END TRANSLATE_ROW;

    PROCEDURE LOAD_ROW(X_ATTRIBUTE_ID           IN VARCHAR2,
                       X_OWNER                  IN VARCHAR2,
                       X_KEY                    IN VARCHAR2,
                       X_ATTRIBUTE_NAME         IN VARCHAR2,
                       X_DESCRIPTION            IN VARCHAR2,
                       X_CATEGORY_ID            IN VARCHAR2,
                       X_TYPE                   IN VARCHAR2,
                       X_SEARCH_RESULTS_VISIBLE IN VARCHAR2,
                       X_ITEM_DETAIL_VISIBLE    IN VARCHAR2,
                       X_SEARCHABLE             IN VARCHAR2,
                       X_SEQUENCE               IN VARCHAR2,
                       X_STORED_IN_TABLE        IN VARCHAR2,
                       X_STORED_IN_COLUMN       IN VARCHAR2,
                       X_SECTION_TAG            IN NUMBER,
                       X_CUSTOM_MODE            IN VARCHAR2,
                       X_LAST_UPDATE_DATE       IN VARCHAR2) IS
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
            FROM   ICX_CAT_ATTRIBUTES_TL
            WHERE  LANGUAGE = userenv('LANG')
                   AND ATTRIBUTE_ID = to_number(X_ATTRIBUTE_ID);


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
                ICX_CAT_ATTRIBUTES_PVT.UPDATE_ROW(X_ATTRIBUTE_ID           => to_number(X_ATTRIBUTE_ID),
                                                  X_KEY                    => X_KEY,
                                                  X_ATTRIBUTE_NAME         => X_ATTRIBUTE_NAME,
                                                  X_DESCRIPTION            => X_DESCRIPTION,
                                                  X_RT_CATEGORY_ID         => to_number(X_CATEGORY_ID),
                                                  X_TYPE                   => to_number(X_TYPE),
                                                  X_SEARCH_RESULTS_VISIBLE => X_SEARCH_RESULTS_VISIBLE,
                                                  X_ITEM_DETAIL_VISIBLE    => X_ITEM_DETAIL_VISIBLE,
                                                  X_SEARCHABLE             => to_number(X_SEARCHABLE),
                                                  X_SEQUENCE               => to_number(X_SEQUENCE),
                                                  X_LAST_UPDATED_BY        => f_luby,
                                                  X_LAST_UPDATE_DATE       => f_ludate,
                                                  X_LAST_UPDATE_LOGIN      => 0,
                                                  X_REQUEST_ID             => NULL,
                                                  X_PROGRAM_APPLICATION_ID => NULL,
                                                  X_PROGRAM_ID             => NULL,
                                                  X_STORED_IN_TABLE        => X_STORED_IN_TABLE,
                                                  X_STORED_IN_COLUMN       => X_STORED_IN_COLUMN,
                                                  X_SECTION_TAG            => X_SECTION_TAG);
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                ICX_CAT_ATTRIBUTES_PVT.INSERT_ROW(X_ROWID                  => row_id,
                                                  X_ATTRIBUTE_ID           => to_number(X_ATTRIBUTE_ID),
                                                  X_KEY                    => X_KEY,
                                                  X_ATTRIBUTE_NAME         => X_ATTRIBUTE_NAME,
                                                  X_DESCRIPTION            => X_DESCRIPTION,
                                                  X_RT_CATEGORY_ID         => to_number(X_CATEGORY_ID),
                                                  X_TYPE                   => to_number(X_TYPE),
                                                  X_SEARCH_RESULTS_VISIBLE => X_SEARCH_RESULTS_VISIBLE,
                                                  X_ITEM_DETAIL_VISIBLE    => X_ITEM_DETAIL_VISIBLE,
                                                  X_SEARCHABLE             => to_number(X_SEARCHABLE),
                                                  X_SEQUENCE               => to_number(X_SEQUENCE),
                                                  X_CREATED_BY             => f_luby,
                                                  X_CREATION_DATE          => f_ludate,
                                                  X_LAST_UPDATED_BY        => f_luby,
                                                  X_LAST_UPDATE_DATE       => f_ludate,
                                                  X_LAST_UPDATE_LOGIN      => 0,
                                                  X_REQUEST_ID             => NULL,
                                                  X_PROGRAM_APPLICATION_ID => NULL,
                                                  X_PROGRAM_ID             => NULL,
                                                  X_STORED_IN_TABLE        => X_STORED_IN_TABLE,
                                                  X_STORED_IN_COLUMN       => X_STORED_IN_COLUMN,
                                                  X_SECTION_TAG            => X_SECTION_TAG);
        END;
    END LOAD_ROW;


    PROCEDURE ADD_LANGUAGE IS
    BEGIN
        INSERT INTO ICX_CAT_ATTRIBUTES_TL
            (ATTRIBUTE_ID,
             KEY,
             ATTRIBUTE_NAME,
             DESCRIPTION,
             RT_CATEGORY_ID,
             TYPE,
             SEARCH_RESULTS_VISIBLE,
             ITEM_DETAIL_VISIBLE,
             SEARCHABLE,
             SEQUENCE,
             SECTION_TAG,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             LANGUAGE,
             SOURCE_LANG,
             STORED_IN_TABLE,
             STORED_IN_COLUMN)
            SELECT B.ATTRIBUTE_ID,
                   B.KEY,
                   B.ATTRIBUTE_NAME,
                   B.DESCRIPTION,
                   B.RT_CATEGORY_ID,
                   B.TYPE,
                   B.SEARCH_RESULTS_VISIBLE,
                   B.ITEM_DETAIL_VISIBLE,
                   B.SEARCHABLE,
                   B.SEQUENCE,
                   B.SECTION_TAG,
                   B.CREATED_BY,
                   B.CREATION_DATE,
                   B.LAST_UPDATED_BY,
                   B.LAST_UPDATE_DATE,
                   B.LAST_UPDATE_LOGIN,
                   B.REQUEST_ID,
                   B.PROGRAM_APPLICATION_ID,
                   B.PROGRAM_ID,
                   L.LANGUAGE_CODE,
                   B.SOURCE_LANG,
                   B.STORED_IN_TABLE,
                   B.STORED_IN_COLUMN
            FROM   ICX_CAT_ATTRIBUTES_TL B,
                   FND_LANGUAGES         L
            WHERE  L.INSTALLED_FLAG IN ('I', 'B')
                   AND B.LANGUAGE = userenv('LANG')
                   AND NOT EXISTS
             (SELECT NULL
                    FROM   ICX_CAT_ATTRIBUTES_TL T
                    WHERE  T.ATTRIBUTE_ID = B.ATTRIBUTE_ID
                           AND T.LANGUAGE = L.LANGUAGE_CODE);

    END ADD_LANGUAGE;

END ICX_CAT_ATTRIBUTES_PVT;

/
