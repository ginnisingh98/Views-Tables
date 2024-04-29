--------------------------------------------------------
--  DDL for Package Body GCS_DATA_TYPE_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DATA_TYPE_CODES_PKG" AS
  /* $Header: gcsdatatypesb.pls 120.5 2006/08/10 22:10:06 skamdar noship $ */

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row into the gcs_data_type_codes_b table.
  -- Arguments
  --   row_id
  --   data_type_id
  --   data_type_code
  --   enforce_balancing_flag
  --   apply_elim_rules_flag
  --   apply_cons_rules_flag
  --   source_dataset_code
  --   data_type_name
  --   description
  --   creation_date
  --   created_by
  --   last_update_date
  --   last_updated_by
  --   last_update_login
  --   object_version_number
  -- Example
  --   GCS_DATA_TYPE_CODES_PKG.Insert_Row(...);
  -- Notes
  --
  PROCEDURE Insert_Row(row_id                 IN OUT NOCOPY VARCHAR2,
                       data_type_id           NUMBER,
                       data_type_code         VARCHAR2,
                       enforce_balancing_flag VARCHAR2,
                       apply_elim_rules_flag  VARCHAR2,
                       apply_cons_rules_flag  VARCHAR2,
                       source_dataset_code    NUMBER,
                       data_type_name         VARCHAR2,
                       description            VARCHAR2,
                       creation_date          DATE,
                       created_by             NUMBER,
                       last_update_date       DATE,
                       last_updated_by        NUMBER,
                       last_update_login      NUMBER,
                       object_version_number  NUMBER) IS
    CURSOR datatypes_row IS
      SELECT rowid
        FROM GCS_DATA_TYPE_CODES_B cb
       WHERE cb.data_type_id = insert_row.data_type_id;

  BEGIN
    IF data_type_id IS NULL THEN
      raise no_data_found;
    END IF;

    INSERT INTO GCS_DATA_TYPE_CODES_B
            (data_type_id,
             data_type_code,
             enforce_balancing_flag,
             apply_elim_rules_flag,
             apply_cons_rules_flag,
             source_dataset_code,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login,
             object_version_number)
      SELECT insert_row.data_type_id,
             insert_row.data_type_code,
             insert_row.enforce_balancing_flag,
             insert_row.apply_elim_rules_flag,
             insert_row.apply_cons_rules_flag,
             insert_row.source_dataset_code,
             insert_row.creation_date,
             insert_row.created_by,
             insert_row.last_update_date,
             insert_row.last_updated_by,
             insert_row.last_update_login,
             insert_row.object_version_number
        FROM dual
       WHERE NOT EXISTS
       (SELECT 1
                FROM GCS_DATA_TYPE_CODES_b cb
               WHERE cb.data_type_id = insert_row.data_type_id);

      -- Bugfix 5155519  : Inserted rows for the other installed languages on the env.
    INSERT INTO GCS_DATA_TYPE_CODES_tl
            (data_type_id,
             language,
             source_lang,
             data_type_name,
             description,
             last_update_date,
             last_updated_by,
             last_update_login,
             creation_date,
             created_by)
    -- Bugfix 5353211 : Qualify API variables with the API name, so that the values passed to the API are utilized
    SELECT   insert_row.data_type_id,
             L.LANGUAGE_CODE,
             userenv('LANG'),
             insert_row.data_type_name,
             insert_row.description,
             insert_row.last_update_date,
             insert_row.last_updated_by,
             insert_row.last_update_login,
             insert_row.creation_date,
             insert_row.created_by
        FROM FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG in ('I', 'B')
       AND   NOT EXISTS
             (SELECT 1
                FROM GCS_DATA_TYPE_CODES_tl ctl
               WHERE ctl.data_type_id = insert_row.data_type_id
                 AND ctl.LANGUAGE = L.LANGUAGE_CODE);

    OPEN datatypes_row;
    FETCH datatypes_row
      INTO row_id;
    IF datatypes_row%NOTFOUND THEN
      CLOSE datatypes_row;
      raise no_data_found;
    END IF;
    CLOSE datatypes_row;

  END Insert_Row;

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Updates a row in the gcs_data_type_codes_b table.
  -- Arguments
  --   row_id
  --   data_type_code
  --   enforce_balancing_flag
  --   apply_elim_rules_flag
  --   apply_cons_rules_flag
  --   source_dataset_code
  --   data_type_name
  --   description
  --   creation_date
  --   created_by
  --   last_update_date
  --   last_updated_by
  --   last_update_login
  --   object_version_number
  -- Example
  --   GCS_DATA_TYPE_CODES_PKG.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(row_id                 IN OUT NOCOPY VARCHAR2,
                       data_type_id           NUMBER,
                       data_type_code         VARCHAR2,
                       enforce_balancing_flag VARCHAR2,
                       apply_elim_rules_flag  VARCHAR2,
                       apply_cons_rules_flag  VARCHAR2,
                       source_dataset_code    NUMBER,
                       data_type_name         VARCHAR2,
                       description            VARCHAR2,
                       creation_date          DATE,
                       created_by             NUMBER,
                       last_update_date       DATE,
                       last_updated_by        NUMBER,
                       last_update_login      NUMBER,
                       object_version_number  NUMBER) IS
  BEGIN
    UPDATE GCS_DATA_TYPE_CODES_b cb
       SET data_type_id           = update_row.data_type_id,
           data_type_code         = update_row.data_type_code,
           enforce_balancing_flag = update_row.enforce_balancing_flag,
           apply_elim_rules_flag  = update_row.apply_elim_rules_flag,
           apply_cons_rules_flag  = update_row.apply_cons_rules_flag,
           source_dataset_code    = update_row.source_dataset_code,
           last_update_date       = update_row.last_update_date,
           last_updated_by        = update_row.last_updated_by,
           last_update_login      = update_row.last_update_login,
           object_version_number  = update_row.object_version_number
     WHERE cb.data_type_id = update_row.data_type_id;

    IF SQL%NOTFOUND THEN
      raise no_data_found;
    END IF;

   -- Bugfix 5155519  : Inserted rows for the other installed languages on the env.
    INSERT INTO GCS_DATA_TYPE_CODES_tl
            (data_type_id,
             language,
             source_lang,
             data_type_name,
             description,
             last_update_date,
             last_updated_by,
             last_update_login,
             creation_date,
             created_by)
    -- Bugfix 5353211 : Qualify API variables with the API name, so that the values passed to the API are utilized
    SELECT   update_row.data_type_id,
             L.LANGUAGE_CODE,
             userenv('LANG'),
             update_row.data_type_name,
             update_row.description,
             update_row.last_update_date,
             update_row.last_updated_by,
             update_row.last_update_login,
             update_row.creation_date,
             update_row.created_by
        FROM FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG in ('I', 'B')
       AND   NOT EXISTS
             (SELECT 1
                FROM GCS_DATA_TYPE_CODES_tl ctl
               WHERE ctl.data_type_id = update_row.data_type_id
                 AND ctl.LANGUAGE = L.LANGUAGE_CODE);

    UPDATE GCS_DATA_TYPE_CODES_tl ctl
       SET data_type_name    = update_row.data_type_name,
           description       = update_row.description,
           last_update_date  = update_row.last_update_date,
           last_updated_by   = update_row.last_updated_by,
           last_update_login = update_row.last_update_login
     WHERE ctl.data_type_id = update_row.data_type_id
       AND ctl.language = userenv('LANG');

    IF SQL%NOTFOUND THEN
      raise no_data_found;
    END IF;
  END Update_Row;

  --
  -- Procedure
  --   Load_Row
  -- Purpose
  --   Loads a row into the gcs_data_type_codes_b table.
  -- Arguments
  --   data_type_code
  --   owner
  --   last_update_date
  --   enforce_balancing_flag
  --   apply_elim_rules_flag
  --   apply_cons_rules_flag
  --   source_dataset_code
  --   object_version_number
  --   data_type_name
  --   description

  -- Example
  --   GCS_DATA_TYPE_CODES_PKG.Load_Row(...);
  -- Notes
  --
  -- Bugfix 5155519  : source_dataset_display_code instead of source_dataset_code in the signature.

  PROCEDURE Load_Row(data_type_id                  NUMBER,
                     owner                         VARCHAR2,
                     last_update_date              VARCHAR2,
                     custom_mode	                 VARCHAR2,
		                 data_type_code                VARCHAR2,
                     enforce_balancing_flag        VARCHAR2,
                     apply_elim_rules_flag         VARCHAR2,
                     apply_cons_rules_flag         VARCHAR2,
                     source_dataset_display_code   VARCHAR2,
                     object_version_number         NUMBER,
                     data_type_name                VARCHAR2,
                     description                   VARCHAR2) IS

    row_id       VARCHAR2(64);
    f_luby       NUMBER; -- datatype owner in file
    f_ludate     DATE; -- datatype update date in file
    f_start_date DATE; -- start date in file
    db_luby      NUMBER; -- datatype owner in db
    db_ludate    DATE; -- datatype update date in db

    -- Bugfix 5155519
    source_dataset_code NUMBER;

  BEGIN
    -- Get last updated information from the loader data file
    f_luby   := fnd_load_util.owner_id(owner);
    f_ludate := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
        -- Bugfix 5155519  : Get the source_dataset_code  for the display code
        -- Bugfix 5453669: We will no longer populate the source dataset. EPF is no longer delivering defaults in R12
        /*
        SELECT dataset_code
          INTO source_dataset_code
          FROM fem_datasets_b fdb
         WHERE dataset_display_code =  load_row.source_dataset_display_code ;
        */

        SELECT cb.last_updated_by, cb.last_update_date
          INTO db_luby, db_ludate
          FROM GCS_DATA_TYPE_CODES_B cb
         WHERE cb.data_type_id = load_row.data_type_id;

        -- Test for customization information
        IF fnd_load_util.upload_test(f_luby,
                                   f_ludate,
                                   db_luby,
                                   db_ludate,
                                   custom_mode) THEN
          update_row(row_id                 => row_id,
                   data_type_id           => load_row.data_type_id,
                   data_type_code         => load_row.data_type_code,
                   enforce_balancing_flag => load_row.enforce_balancing_flag,
                   apply_elim_rules_flag  => load_row.apply_elim_rules_flag,
                   apply_cons_rules_flag  => load_row.apply_cons_rules_flag,
                   source_dataset_code    => source_dataset_code,
                   data_type_name         => load_row.data_type_name,
                   description            => load_row.description,
                   creation_date          => f_ludate,
                   created_by             => f_luby,
                   last_update_date       => f_ludate,
                   last_updated_by        => f_luby,
                   last_update_login      => 0,
                   object_version_number  => load_row.object_version_number);
        END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        insert_row(row_id                 => row_id,
                   data_type_id           => load_row.data_type_id,
                   data_type_code         => load_row.data_type_code,
                   enforce_balancing_flag => load_row.enforce_balancing_flag,
                   apply_elim_rules_flag  => load_row.apply_elim_rules_flag,
                   apply_cons_rules_flag  => load_row.apply_cons_rules_flag,
                   source_dataset_code    => source_dataset_code,
                   data_type_name         => load_row.data_type_name,
                   description            => load_row.description,
                   creation_date          => f_ludate,
                   created_by             => f_luby,
                   last_update_date       => f_ludate,
                   last_updated_by        => f_luby,
                   last_update_login      => 0,
                   object_version_number  => load_row.object_version_number);
    END;


  END Load_Row;

  --
  -- Procedure
  --   Translate_Row
  -- Purpose
  --   Updates translated infromation for a row in the
  --   gcs_categories_tl table.
  -- Arguments
  --   data_type_code
  --   owner
  --   last_update_date
  --   data_type_name
  --   description
  -- Example
  --   GCS_DATA_TYPE_CODES_PKG.Translate_Row(...);
  -- Notes
  --
  PROCEDURE Translate_Row(data_type_id   NUMBER,
                          owner            VARCHAR2,
                          last_update_date VARCHAR2,
                          custom_mode      VARCHAR2,
                          data_type_name   VARCHAR2,
                          description      VARCHAR2) IS

    f_luby    NUMBER; -- category owner in file
    f_ludate  DATE; -- category update date in file
    db_luby   NUMBER; -- category owner in db
    db_ludate DATE; -- category update date in db
  BEGIN
    -- Get last updated information from the loader data file
    f_luby   := fnd_load_util.owner_id(owner);
    f_ludate := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT ctl.last_updated_by, ctl.last_update_date
        INTO db_luby, db_ludate
        FROM GCS_DATA_TYPE_CODES_TL ctl
       WHERE ctl.data_type_id = translate_row.data_type_id
         AND ctl.language = userenv('LANG');

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby,
                                   f_ludate,
                                   db_luby,
                                   db_ludate,
                                   custom_mode) THEN
        UPDATE gcs_data_type_codes_tl ctl
           SET data_type_name    = translate_row.data_type_name,
               description       = translate_row.description,
               source_lang       = userenv('LANG'),
               last_update_date  = f_ludate,
               last_updated_by   = f_luby,
               last_update_login = 0
         WHERE ctl.data_type_id = translate_row.data_type_id
           AND userenv('LANG') IN (ctl.language, ctl.source_lang);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;
  END Translate_Row;

  -- Procedure
  --   ADD_LANGUAGE
  -- Arguments

  -- Example
  --   GCS_DATA_TYPE_CODES_PKG.ADD_LANGUAGE();
  -- Notes
  --

  PROCEDURE ADD_LANGUAGE is
  BEGIN
    INSERT /*+ append parallel(tt) */
    INTO GCS_DATA_TYPE_CODES_TL tt
      (DATA_TYPE_ID,
       DATA_TYPE_NAME,
       DESCRIPTION,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       LANGUAGE,
       SOURCE_LANG)

    SELECT /*+ parallel(v) parallel(t) use_nl(t) */
       v.*
    FROM (SELECT /*+ no_merge ordered parellel(b) */

               B.DATA_TYPE_ID,
               B.DATA_TYPE_NAME,
               B.DESCRIPTION,
               B.CREATION_DATE,
               B.CREATED_BY,
               B.LAST_UPDATED_BY,
               B.LAST_UPDATE_DATE,
               B.LAST_UPDATE_LOGIN,
               L.LANGUAGE_CODE,
               B.SOURCE_LANG

          FROM GCS_DATA_TYPE_CODES_TL B, FND_LANGUAGES L
          WHERE L.INSTALLED_FLAG in ('I', 'B')
          AND   B.LANGUAGE = userenv('LANG')) v,

          GCS_DATA_TYPE_CODES_TL t
    WHERE T.DATA_TYPE_ID(+) = v.data_type_id
    AND   T.LANGUAGE(+) = v.language_code
    AND   T.DATA_TYPE_ID IS NULL;

  END ADD_LANGUAGE;

BEGIN

  SELECT data_type_id,
         data_type_code,
         enforce_balancing_flag,
         apply_elim_rules_flag,
         apply_cons_rules_flag,
         source_dataset_code BULK COLLECT
    INTO g_datatype_info
    FROM gcs_data_type_codes_b;

END GCS_DATA_TYPE_CODES_PKG;

/
