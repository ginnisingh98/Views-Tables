--------------------------------------------------------
--  DDL for Package Body GCS_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_HIERARCHIES_PKG" AS
  /* $Header: gcshierb.pls 120.3 2006/05/22 12:36:19 smatam noship $ */
  --
  -- Package
  --   gcs_hierarchies_pkg
  -- Purpose
  --   Package procedures for Consolidation Hierarchies
  -- History
  --   28-JUN-04  M Ward    Created
  --
  --
  -- Private Global Variables
  --
  -- The API name
  g_api CONSTANT VARCHAR2(40) := 'gcs.plsql.GCS_HIERARCHIES_PKG';
  -- Action types for writing module information to the log file. Used for
  -- the procedure log_file_module_write.
  g_module_enter   CONSTANT VARCHAR2(2) := '>>';
  g_module_success CONSTANT VARCHAR2(2) := '<<';
  g_module_failure CONSTANT VARCHAR2(2) := '<x';
  -- A newline character. Included for convenience when writing long strings.
  g_nl CONSTANT VARCHAR2(1) := '
';
  -- Create an associative array (hashtable) to hold the entities that have
  -- already been traversed in a hierarchy. This is to prevent infinite
  -- looping in the case of mutual ownerships
  TYPE EntitiesTableType IS TABLE OF BINARY_INTEGER INDEX BY BINARY_INTEGER;

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row into the gcs_lex_map_structs table.
  -- Arguments
  --   row_id
  --   hierarchy_id
  --   top_entity_id
  --   start_date
  --   calendar_id
  --   dimension_group_id
  --   ie_by_org_code
  --   balance_by_org_flag
  --   enabled_flag
  --   threshold_amount
  --   threshold_currency
  --   fem_ledger_id
  --   column_name
  --   object_version_number
  --   hierarchy_name
  --   description
  --   last_update_date
  --   last_updated_by
  --   last_update_login
  --   creation_date
  --   created_by
  -- Example
  --   GCS_HIERARCHIES_PKG.Insert_Row(...);
  -- Notes
  --
  PROCEDURE Insert_Row(row_id                IN OUT NOCOPY VARCHAR2,
                       hierarchy_id          VARCHAR2,
                       top_entity_id         NUMBER,
                       start_date            VARCHAR2,
                       calendar_id           NUMBER,
                       dimension_group_id    NUMBER,
                       ie_by_org_code        VARCHAR2,
                       balance_by_org_flag   VARCHAR2,
                       enabled_flag          VARCHAR2,
                       threshold_amount      NUMBER,
                       threshold_currency    VARCHAR2,
                       fem_ledger_id         NUMBER,
                       column_name           VARCHAR2,
                       object_version_number NUMBER,
                       hierarchy_name        VARCHAR2,
                       description           VARCHAR2,
                       last_update_date      DATE,
                       last_updated_by       NUMBER,
                       last_update_login     NUMBER,
                       creation_date         DATE,
                       created_by            NUMBER) IS
    CURSOR hier_row IS
      SELECT rowid
        FROM gcs_hierarchies_b hb
       WHERE hb.hierarchy_id = insert_row.hierarchy_id;
  BEGIN
    IF hierarchy_id IS NULL THEN
      raise no_data_found;
    END IF;
    INSERT INTO gcs_hierarchies_b
      (hierarchy_id,
       top_entity_id,
       start_date,
       calendar_id,
       dimension_group_id,
       ie_by_org_code,
       balance_by_org_flag,
       enabled_flag,
       threshold_amount,
       threshold_currency,
       fem_ledger_id,
       column_name,
       object_version_number,
       last_update_date,
       last_updated_by,
       last_update_login,
       creation_date,
       created_by)
      SELECT hierarchy_id,
             top_entity_id,
             start_date,
             calendar_id,
             dimension_group_id,
             ie_by_org_code,
             balance_by_org_flag,
             enabled_flag,
             threshold_amount,
             threshold_currency,
             fem_ledger_id,
             column_name,
             object_version_number,
             last_update_date,
             last_updated_by,
             last_update_login,
             creation_date,
             created_by
        FROM dual
       WHERE NOT EXISTS
       (SELECT 1
                FROM gcs_hierarchies_b hb
               WHERE hb.hierarchy_id = insert_row.hierarchy_id);
    INSERT INTO gcs_hierarchies_tl
      (hierarchy_id,
       language,
       source_lang,
       hierarchy_name,
       description,
       last_update_date,
       last_updated_by,
       last_update_login,
       creation_date,
       created_by)
      SELECT hierarchy_id,
             userenv('LANG'),
             userenv('LANG'),
             hierarchy_name,
             description,
             last_update_date,
             last_updated_by,
             last_update_login,
             creation_date,
             created_by
        FROM dual
       WHERE NOT EXISTS (SELECT 1
                FROM gcs_hierarchies_tl htl
               WHERE htl.hierarchy_id = insert_row.hierarchy_id
                 AND htl.language = userenv('LANG'));
    OPEN hier_row;
    FETCH hier_row
      INTO row_id;
    IF hier_row%NOTFOUND THEN
      CLOSE hier_row;
      raise no_data_found;
    END IF;
    CLOSE hier_row;
  END Insert_Row;
  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Updates a row in the gcs_lex_map_structs table.
  -- Arguments
  --   hierarchy_id
  --   top_entity_id
  --   start_date
  --   calendar_id
  --   dimension_group_id
  --   ie_by_org_code
  --   balance_by_org_flag
  --   enabled_flag
  --   threshold_amount
  --   threshold_currency
  --   fem_ledger_id
  --   column_name
  --   object_version_number
  --   hierarchy_name
  --   description
  --   last_update_date
  --   last_udpated_by
  --   last_update_login
  -- Example
  --   GCS_HIERARCHIES_PKG.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(hierarchy_id          VARCHAR2,
                       top_entity_id         NUMBER,
                       start_date            VARCHAR2,
                       calendar_id           NUMBER,
                       dimension_group_id    NUMBER,
                       ie_by_org_code        VARCHAR2,
                       balance_by_org_flag   VARCHAR2,
                       enabled_flag          VARCHAR2,
                       threshold_amount      NUMBER,
                       threshold_currency    VARCHAR2,
                       fem_ledger_id         NUMBER,
                       column_name           VARCHAR2,
                       object_version_number NUMBER,
                       hierarchy_name        VARCHAR2,
                       description           VARCHAR2,
                       last_update_date      DATE,
                       last_updated_by       NUMBER,
                       last_update_login     NUMBER,
                       creation_date         DATE,
                       created_by            NUMBER) IS
  BEGIN
    UPDATE gcs_hierarchies_b hb
       SET top_entity_id         = update_row.top_entity_id,
           start_date            = update_row.start_date,
           calendar_id           = update_row.calendar_id,
           dimension_group_id    = update_row.dimension_group_id,
           ie_by_org_code        = update_row.ie_by_org_code,
           balance_by_org_flag   = update_row.balance_by_org_flag,
           enabled_flag          = update_row.enabled_flag,
           threshold_amount      = update_row.threshold_amount,
           threshold_currency    = update_row.threshold_currency,
           fem_ledger_id         = update_row.fem_ledger_id,
           column_name           = update_row.column_name,
           object_version_number = update_row.object_version_number,
           last_update_date      = update_row.last_update_date,
           last_updated_by       = update_row.last_updated_by,
           last_update_login     = update_row.last_update_login
     WHERE hb.hierarchy_id = update_row.hierarchy_id;
    IF SQL%NOTFOUND THEN
      raise no_data_found;
    END IF;
    INSERT INTO gcs_hierarchies_tl
      (hierarchy_id,
       language,
       source_lang,
       hierarchy_name,
       description,
       last_update_date,
       last_updated_by,
       last_update_login,
       creation_date,
       created_by)
      SELECT hierarchy_id,
             userenv('LANG'),
             userenv('LANG'),
             hierarchy_name,
             description,
             last_update_date,
             last_updated_by,
             last_update_login,
             creation_date,
             created_by
        FROM dual
       WHERE NOT EXISTS (SELECT 1
                FROM gcs_hierarchies_tl htl
               WHERE htl.hierarchy_id = update_row.hierarchy_id
                 AND htl.language = userenv('LANG'));
    UPDATE gcs_hierarchies_tl ht
       SET hierarchy_name    = update_row.hierarchy_name,
           description       = update_row.description,
           last_update_date  = update_row.last_update_date,
           last_updated_by   = update_row.last_updated_by,
           last_update_login = update_row.last_update_login
     WHERE ht.hierarchy_id = update_row.hierarchy_id
       AND ht.language = userenv('LANG');
    IF SQL%NOTFOUND THEN
      raise no_data_found;
    END IF;
  END Update_Row;
  --
  -- Procedure
  --   Load_Row
  -- Purpose
  --   Loads a row into the gcs_lex_map_structs table.
  -- Arguments
  --   hierarchy_id
  --   owner
  --   last_update_date
  --   custom_mode
  --   top_entity_id
  --   start_date
  --   calendar_id
  --   dimension_group_id
  --   ie_by_org_code
  --   balance_by_org_flag
  --   enabled_flag
  --   threshold_amount
  --   threshold_currency
  --   fem_ledger_id
  --   column_name
  --   object_version_number
  --   hierarchy_name
  --   description
  -- Example
  --   GCS_HIERARCHIES_PKG.Load_Row(...);
  -- Notes
  --
  PROCEDURE Load_Row(hierarchy_id          VARCHAR2,
                     owner                 VARCHAR2,
                     last_update_date      VARCHAR2,
                     custom_mode           VARCHAR2,
                     top_entity_id         NUMBER,
                     start_date            VARCHAR2,
                     calendar_id           NUMBER,
                     dimension_group_id    NUMBER,
                     ie_by_org_code        VARCHAR2,
                     balance_by_org_flag   VARCHAR2,
                     enabled_flag          VARCHAR2,
                     threshold_amount      NUMBER,
                     threshold_currency    VARCHAR2,
                     fem_ledger_id         NUMBER,
                     column_name           VARCHAR2,
                     object_version_number NUMBER,
                     hierarchy_name        VARCHAR2,
                     description           VARCHAR2) IS
    row_id       VARCHAR2(64);
    f_luby       NUMBER; -- entity owner in file
    f_ludate     DATE; -- entity update date in file
    db_luby      NUMBER; -- entity owner in db
    db_ludate    DATE; -- entity update date in db
    f_start_date DATE; -- start date in file
  BEGIN
    -- Get last updated information from the loader data file
    f_luby       := fnd_load_util.owner_id(owner);
    f_ludate     := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);
    f_start_date := nvl(to_date(start_date, 'YYYY/MM/DD'), sysdate);
    BEGIN
      SELECT hb.last_updated_by, hb.last_update_date
        INTO db_luby, db_ludate
        FROM GCS_HIERARCHIES_B hb
       WHERE hb.hierarchy_id = load_row.hierarchy_id;
      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby,
                                   f_ludate,
                                   db_luby,
                                   db_ludate,
                                   custom_mode) THEN
        update_row(hierarchy_id          => HIERARCHY_ID,
                   top_entity_id         => TOP_ENTITY_ID,
                   start_date            => F_START_DATE,
                   calendar_id           => CALENDAR_ID,
                   dimension_group_id    => DIMENSION_GROUP_ID,
                   ie_by_org_code        => IE_BY_ORG_CODE,
                   balance_by_org_flag   => BALANCE_BY_ORG_FLAG,
                   enabled_flag          => ENABLED_FLAG,
                   threshold_amount      => THRESHOLD_AMOUNT,
                   threshold_currency    => THRESHOLD_CURRENCY,
                   fem_ledger_id         => FEM_LEDGER_ID,
                   column_name           => COLUMN_NAME,
                   object_version_number => OBJECT_VERSION_NUMBER,
                   hierarchy_name        => HIERARCHY_NAME,
                   description           => DESCRIPTION,
                   last_update_date      => f_ludate,
                   last_updated_by       => f_luby,
                   last_update_login     => 0,
                   creation_date         => f_ludate,
                   created_by            => f_luby);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        insert_row(row_id                => row_id,
                   hierarchy_id          => HIERARCHY_ID,
                   top_entity_id         => TOP_ENTITY_ID,
                   start_date            => F_START_DATE,
                   calendar_id           => CALENDAR_ID,
                   dimension_group_id    => DIMENSION_GROUP_ID,
                   ie_by_org_code        => IE_BY_ORG_CODE,
                   balance_by_org_flag   => BALANCE_BY_ORG_FLAG,
                   enabled_flag          => ENABLED_FLAG,
                   threshold_amount      => THRESHOLD_AMOUNT,
                   threshold_currency    => THRESHOLD_CURRENCY,
                   fem_ledger_id         => FEM_LEDGER_ID,
                   column_name           => COLUMN_NAME,
                   object_version_number => OBJECT_VERSION_NUMBER,
                   hierarchy_name        => HIERARCHY_NAME,
                   description           => DESCRIPTION,
                   last_update_date      => f_ludate,
                   last_updated_by       => f_luby,
                   last_update_login     => 0,
                   creation_date         => f_ludate,
                   created_by            => f_luby);
    END;
  END Load_Row;
  --
  -- Procedure
  --   Translate_Row
  -- Purpose
  --   Updates translated infromation for a row in the
  --   gcs_hierarchies_tl table.
  -- Arguments
  --   hierarchy_id
  --   owner
  --   last_update_date
  --   custom_mode
  --   hierarchy_name
  --   description
  -- Example
  --   GCS_HIERARCHIES_PKG.Translate_Row(...);
  -- Notes
  --
  PROCEDURE Translate_Row(hierarchy_id     NUMBER,
                          owner            VARCHAR2,
                          last_update_date VARCHAR2,
                          custom_mode      VARCHAR2,
                          hierarchy_name   VARCHAR2,
                          description      VARCHAR2) IS
    f_luby    NUMBER; -- entity owner in file
    f_ludate  DATE; -- entity update date in file
    db_luby   NUMBER; -- entity owner in db
    db_ludate DATE; -- entity update date in db
  BEGIN
    -- Get last updated information from the loader data file
    f_luby   := fnd_load_util.owner_id(owner);
    f_ludate := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);
    BEGIN
      SELECT htl.last_updated_by, htl.last_update_date
        INTO db_luby, db_ludate
        FROM GCS_HIERARCHIES_TL htl
       WHERE htl.hierarchy_id = translate_row.hierarchy_id
         AND htl.language = userenv('LANG');
      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby,
                                   f_ludate,
                                   db_luby,
                                   db_ludate,
                                   custom_mode) THEN
        UPDATE gcs_hierarchies_tl htl
           SET hierarchy_name    = translate_row.hierarchy_name,
               description       = translate_row.description,
               source_lang       = userenv('LANG'),
               last_update_date  = f_ludate,
               last_updated_by   = f_luby,
               last_update_login = 0
         WHERE htl.hierarchy_id = translate_row.hierarchy_id
           AND userenv('LANG') IN (htl.language, htl.source_lang);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;
  END Translate_Row;
  --
  -- Procedure
  --   ADD_LANGUAGE
  -- Purpose
  --
  -- Arguments
  --
  -- GCS_HIERARCHIES_PKG.ADD_LANGUAGE();
  -- Notes
  --
  procedure ADD_LANGUAGE is
  begin
    insert /*+ append parallel(tt) */
    into GCS_HIERARCHIES_TL tt
      (HIERARCHY_ID,
       LANGUAGE,
       SOURCE_LANG,
       HIERARCHY_NAME,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       DESCRIPTION)
      select /*+ parallel(v) parallel(t) use_nl(t) */
       v.*
        from (SELECT /*+ no_merge ordered parellel(b) */
               B.HIERARCHY_ID,
               L.LANGUAGE_CODE,
               B.SOURCE_LANG,
               B.HIERARCHY_NAME,
               B.CREATION_DATE,
               B.CREATED_BY,
               B.LAST_UPDATE_DATE,
               B.LAST_UPDATED_BY,
               B.LAST_UPDATE_LOGIN,
               B.DESCRIPTION
                from GCS_HIERARCHIES_TL B, FND_LANGUAGES L
               where L.INSTALLED_FLAG in ('I', 'B')
                 and B.LANGUAGE = userenv('LANG')) v,
             GCS_HIERARCHIES_TL t
       where T.HIERARCHY_ID(+) = v.HIERARCHY_ID
         and T.LANGUAGE(+) = v.LANGUAGE_CODE
         and t.HIERARCHY_ID IS NULL;
  end ADD_LANGUAGE;
  --
  -- Private Procedures and Functions for Multiple Parents
  --
  --
  -- Procedure
  --   Module_Log_Write
  -- Purpose
  --   Write the procedure or function entered or exited, and the time that
  --   this happened. Write it to the log repository.
  -- Arguments
  --   p_module         Name of the module
  --   p_action_type    Entered, Exited Successfully, or Exited with Failure
  -- Example
  --   GCS_HIERARCHIES_PKG.Module_Log_Write
  -- Notes
  --
  PROCEDURE Module_Log_Write(p_module VARCHAR2, p_action_type VARCHAR2) IS
  BEGIN
    -- Only print if the log level is set at the appropriate level
    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || p_module,
                     p_action_type || ' ' || p_module || '() ' ||
                     to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      p_action_type || ' ' || p_module || '() ' ||
                      to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
  END Module_Log_Write;
  --
  -- Procedure
  --   Write_To_Log
  -- Purpose
  --   Write the text given to the log in 3500 character increments
  --   this happened. Write it to the log repository.
  -- Arguments
  --   p_module         Name of the module
  --   p_level          Logging level
  --   p_text           Text to write
  -- Example
  --   GCS_HIERARCHIES_PKG.Write_To_Log
  -- Notes
  --
  PROCEDURE Write_To_Log(p_module VARCHAR2,
                         p_level  NUMBER,
                         p_text   VARCHAR2) IS
    api_module_concat  VARCHAR2(200);
    text_with_date     VARCHAR2(32767);
    text_with_date_len NUMBER;
    curr_index         NUMBER;
  BEGIN
    -- Only print if the log level is set at the appropriate level
    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= p_level THEN
      api_module_concat  := g_api || '.' || p_module;
      text_with_date     := to_char(sysdate, 'DD-MON-YYYY HH:MI:SS') || g_nl ||
                            p_text;
      text_with_date_len := length(text_with_date);
      curr_index         := 1;
      WHILE curr_index <= text_with_date_len LOOP
        fnd_log.string(p_level,
                       api_module_concat,
                       substr(text_with_date, curr_index, 3500));
        curr_index := curr_index + 3500;
      END LOOP;
    END IF;
  END Write_To_Log;
  --
  -- Function
  --   Entity_Exists
  -- Purpose
  --   Gets an entry from the hashtable with the given key. If no entry exists
  --   this will simply return NULL.
  -- Arguments
  --   p_entities_hashtable Hashtable of entities
  --   p_entity_id    The key
  -- Return Value
  --   The value in the hashtable, of NULL if no value exists
  -- Example
  --   GCS_HIERARCHIES_PKG.Entity_In_Hashtable(...);
  -- Notes
  --
  FUNCTION Entity_Exists(p_entities_hashtable IN OUT NOCOPY EntitiesTableType,
                         p_entity_id          NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN p_entities_hashtable(p_entity_id);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Entity_Exists;
  --
  -- Procedure
  --   Calc_Delta_To_Single_Parent
  -- Purpose
  --   Calculate the delta ownership to a single parent from the original
  --   entity. The current entity given is the one we have gotten to in the
  --   recursive traversal. We continue until we get to the parent or there are
  --   no more parents to traverse.
  -- Arguments
  --   p_hierarchy_id   Hierarchy for which the logic must be performed
  --   p_original_entity_id Original child entity for which the logic must
  --        be performed
  --   p_parent_entity_id The parent for which the delta ownership must
  --        be found
  --   p_current_entity_id  The entity we have gotten to in the traversal
  --   p_effective_ownership  The effective ownership of the original entity
  --        by the current entity
  --   p_start_date   Date range for performing the logic
  --   p_end_date   Date range for performing the logic
  --   p_traversed_entities List of entities we have already traversed to
  --        get to the current entity
  --   p_calc_parent_entities List of entities for which we have already run
  --        delta calculations
  -- Example
  --   GCS_HIERARCHIES_PKG.Calc_Delta_To_Single_Parent(...);
  -- Notes
  --
  PROCEDURE Calc_Delta_To_Single_Parent(p_hierarchy_id         NUMBER,
                                        p_original_entity_id   NUMBER,
                                        p_parent_entity_id     NUMBER,
                                        p_current_entity_id    NUMBER,
                                        p_effective_ownership  NUMBER,
                                        p_start_date           DATE,
                                        p_end_date             DATE,
                                        p_traversed_entities   IN OUT NOCOPY EntitiesTableType,
                                        p_calc_parent_entities IN OUT NOCOPY EntitiesTableType) IS
    -- Used to find the list of existing delta ownership rows that must be
    -- taken into consideration when creating and updating delta ownership rows
    CURSOR get_existing_delta_rows_c IS
      SELECT r.cons_relationship_id,
             r.start_date,
             r.end_date,
             r.delta_owned
        FROM gcs_cons_relationships r
       WHERE r.hierarchy_id = p_hierarchy_id
         AND r.parent_entity_id = p_parent_entity_id
         AND r.child_entity_id = p_original_entity_id
         AND r.actual_ownership_flag = 'N'
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND r.start_date <= nvl(p_end_date, r.start_date)
         AND nvl(r.end_date, p_start_date) >= p_start_date
       ORDER BY r.start_date;
    -- The end date of the last existing delta relationship that we found. This
    -- is used to create "filler" delta relationships between existing delta
    -- relationships so that we do not have unwanted gaps, and we only have one
    -- delta relationship for a particular date.
    last_end_date DATE;
    -- Used to get the consolidated parents for the current entity. The decodes
    -- exist to pick the most restrictive date range possible.
    CURSOR get_curr_entity_parent_c IS
      SELECT r.parent_entity_id,
             r.ownership_percent,
             decode(sign(r.start_date - p_start_date),
                    1,
                    r.start_date,
                    p_start_date) start_date,
             decode(r.end_date,
                    null,
                    p_end_date,
                    decode(p_end_date,
                           null,
                           r.end_date,
                           decode(sign(r.end_date - p_end_date),
                                  1,
                                  p_end_date,
                                  r.end_date))) end_date
        FROM gcs_cons_relationships r
       WHERE r.hierarchy_id = p_hierarchy_id
         AND r.child_entity_id = p_current_entity_id
         AND r.actual_ownership_flag = 'Y'
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND p_start_date <= nvl(r.end_date, p_start_date)
         AND nvl(p_end_date, r.start_date) >= r.start_date;
    fnd_user_id  NUMBER;
    fnd_login_id NUMBER;
    v_module     VARCHAR2(30);
  BEGIN
    v_module := 'Calc_Delta_To_Single_Parent';
    module_log_write(v_module, g_module_enter);
    -- If we have already come up this path or we have calculated deltas for
    -- this parent entity, then return
    IF entity_exists(p_traversed_entities, p_current_entity_id) =
       p_current_entity_id OR
       entity_exists(p_calc_parent_entities, p_current_entity_id) =
       p_current_entity_id THEN
      module_log_write(v_module, g_module_success);
      RETURN;
    END IF;
    -- If we have reached the desired parent entity, create the necessary rows.
    -- Otherwise keep going up the hierarchy.
    IF p_current_entity_id = p_parent_entity_id THEN
      fnd_user_id  := fnd_global.user_id;
      fnd_login_id := fnd_global.login_id;
      -- Initialize the previous end date to be the day prior to the start date
      -- of the new range
      last_end_date := p_start_date - 1;
      -- Go through each of the delta rows, and perform the necessary actions
      -- to update the delta ownership
      FOR delta_row IN get_existing_delta_rows_c LOOP
        -- If this relationship straddles the start date, split it in two
        IF delta_row.start_date < p_start_date THEN
          INSERT INTO gcs_cons_relationships
            (cons_relationship_id,
             hierarchy_id,
             parent_entity_id,
             child_entity_id,
             ownership_percent,
             start_date,
             treatment_id,
             curr_treatment_id,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login,
             end_date,
             delta_owned,
             dominant_parent_flag,
             actual_ownership_flag)
          VALUES
            (gcs_cons_relationships_s.nextval,
             p_hierarchy_id,
             p_parent_entity_id,
             p_original_entity_id,
             0,
             delta_row.start_date,
             null,
             null,
             1,
             sysdate,
             fnd_user_id,
             sysdate,
             fnd_user_id,
             fnd_login_id,
             p_start_date - 1,
             delta_row.delta_owned,
             'N',
             'N');
          UPDATE gcs_cons_relationships r
             SET start_date = p_start_date
           WHERE r.cons_relationship_id = delta_row.cons_relationship_id;
        END IF;
        -- If this relationship straddles the end date, split it in two
        IF p_end_date IS NOT NULL AND
           nvl(delta_row.end_date, p_end_date + 1) > p_end_date THEN
          INSERT INTO gcs_cons_relationships
            (cons_relationship_id,
             hierarchy_id,
             parent_entity_id,
             child_entity_id,
             ownership_percent,
             start_date,
             treatment_id,
             curr_treatment_id,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login,
             end_date,
             delta_owned,
             dominant_parent_flag,
             actual_ownership_flag)
          VALUES
            (gcs_cons_relationships_s.nextval,
             p_hierarchy_id,
             p_parent_entity_id,
             p_original_entity_id,
             0,
             p_end_date + 1,
             null,
             null,
             1,
             sysdate,
             fnd_user_id,
             sysdate,
             fnd_user_id,
             fnd_login_id,
             delta_row.end_date,
             delta_row.delta_owned,
             'N',
             'N');
          UPDATE gcs_cons_relationships r
             SET end_date = p_end_date
           WHERE r.cons_relationship_id = delta_row.cons_relationship_id;
        END IF;
        -- If this relationship's start date is not the day after the prior
        -- relationship's end date, then create a "filler" relationship
        IF delta_row.start_date >
           nvl(last_end_date + 1, delta_row.start_date) THEN
          INSERT INTO gcs_cons_relationships
            (cons_relationship_id,
             hierarchy_id,
             parent_entity_id,
             child_entity_id,
             ownership_percent,
             start_date,
             treatment_id,
             curr_treatment_id,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login,
             end_date,
             delta_owned,
             dominant_parent_flag,
             actual_ownership_flag)
          VALUES
            (gcs_cons_relationships_s.nextval,
             p_hierarchy_id,
             p_parent_entity_id,
             p_original_entity_id,
             0,
             last_end_date + 1,
             null,
             null,
             1,
             sysdate,
             fnd_user_id,
             sysdate,
             fnd_user_id,
             fnd_login_id,
             delta_row.start_date - 1,
             p_effective_ownership,
             'N',
             'N');
        END IF;
        -- Now update the relationship with the new effective ownership
        UPDATE gcs_cons_relationships r
           SET r.delta_owned = r.delta_owned + p_effective_ownership
         WHERE r.cons_relationship_id = delta_row.cons_relationship_id;
        -- Finally, update last_end_date to the end date of this relationship
        last_end_date := delta_row.end_date;
      END LOOP;
      -- Create the trailing "filler" relationship if necessary
      IF last_end_date IS NOT NULL AND
         nvl(p_end_date, last_end_date + 1) > last_end_date THEN
        INSERT INTO gcs_cons_relationships
          (cons_relationship_id,
           hierarchy_id,
           parent_entity_id,
           child_entity_id,
           ownership_percent,
           start_date,
           treatment_id,
           curr_treatment_id,
           object_version_number,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           end_date,
           delta_owned,
           dominant_parent_flag,
           actual_ownership_flag)
        VALUES
          (gcs_cons_relationships_s.nextval,
           p_hierarchy_id,
           p_parent_entity_id,
           p_original_entity_id,
           0,
           last_end_date + 1,
           null,
           null,
           1,
           sysdate,
           fnd_user_id,
           sysdate,
           fnd_user_id,
           fnd_login_id,
           p_end_date,
           p_effective_ownership,
           'N',
           'N');
      END IF;
    ELSE
      -- Ensure that an infinite loop does not occur
      p_traversed_entities(p_current_entity_id) := p_current_entity_id;
      -- Get the list of parents for the current entity, and go up looking for
      -- the parent entity
      FOR parent_entity IN get_curr_entity_parent_c LOOP
        calc_delta_to_single_parent(p_hierarchy_id         => p_hierarchy_id,
                                    p_original_entity_id   => p_original_entity_id,
                                    p_parent_entity_id     => p_parent_entity_id,
                                    p_current_entity_id    => parent_entity.parent_entity_id,
                                    p_effective_ownership  => parent_entity.ownership_percent *
                                                              p_effective_ownership / 100,
                                    p_start_date           => parent_entity.start_date,
                                    p_end_date             => parent_entity.end_date,
                                    p_traversed_entities   => p_traversed_entities,
                                    p_calc_parent_entities => p_calc_parent_entities);
      END LOOP;
      -- Now, clear out the entry so that we can traverse this entity again
      p_traversed_entities(p_current_entity_id) := NULL;
    END IF;
    module_log_write(v_module, g_module_success);
  EXCEPTION
    WHEN OTHERS THEN
      write_to_log(v_module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(v_module, g_module_failure);
      RAISE;
  END Calc_Delta_To_Single_Parent;
  --
  -- Procedure
  --   Calc_Delta_To_All_Parents
  -- Purpose
  --   Calculate the delta ownership to all parents from the original entity.
  --   The parent entity given is the one for which we are currently performing
  --   the calculation. We will recursively go up and perform the calculations
  --   as necessary.
  -- Arguments
  --   p_hierarchy_id   Hierarchy for which the logic must be performed
  --   p_original_entity_id Original child entity for which the logic must
  --        be performed
  --   p_parent_entity_id The parent for which the delta ownership must
  --        be found
  --   p_start_date   Date range for performing the logic
  --   p_end_date   Date range for performing the logic
  --   p_calc_parent_entities List of entities we have already gone through
  --        to get to this parent
  -- Example
  --   GCS_HIERARCHIES_PKG.Calc_Delta_To_All_Parents(...);
  -- Notes
  --
  PROCEDURE Calc_Delta_To_All_Parents(p_hierarchy_id         NUMBER,
                                      p_original_entity_id   NUMBER,
                                      p_parent_entity_id     NUMBER,
                                      p_start_date           DATE,
                                      p_end_date             DATE,
                                      p_calc_parent_entities IN OUT NOCOPY EntitiesTableType) IS
    -- Used to get the unconsolidated parents for the original child. The
    -- decodes exist to pick the most restrictive date range possible.
    CURSOR get_uncons_parent_c IS
      SELECT r.parent_entity_id,
             r.ownership_percent,
             decode(sign(r.start_date - p_start_date),
                    1,
                    r.start_date,
                    p_start_date) start_date,
             decode(r.end_date,
                    null,
                    p_end_date,
                    decode(p_end_date,
                           null,
                           r.end_date,
                           decode(sign(r.end_date - p_end_date),
                                  1,
                                  p_end_date,
                                  r.end_date))) end_date
        FROM gcs_cons_relationships r, gcs_treatments_b tb
       WHERE r.hierarchy_id = p_hierarchy_id
         AND r.child_entity_id = p_original_entity_id
         AND r.actual_ownership_flag = 'Y'
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND p_start_date <= nvl(r.end_date, p_start_date)
         AND nvl(p_end_date, r.start_date) >= r.start_date
         AND tb.treatment_id = r.treatment_id
         AND tb.consolidation_type_code = 'NONE';
    -- A list of entities that I have visited on my way to get to the parent.
    -- This is used to prevent infinite looping
    v_traversed_entities EntitiesTableType;
    -- Used to get the full consolidated parent for this child. The decodes
    -- exist to pick the most restrictive date range possible.
    CURSOR get_cons_parent_c IS
      SELECT r.parent_entity_id,
             decode(sign(r.start_date - p_start_date),
                    1,
                    r.start_date,
                    p_start_date) start_date,
             decode(r.end_date,
                    null,
                    p_end_date,
                    decode(p_end_date,
                           null,
                           r.end_date,
                           decode(sign(r.end_date - p_end_date),
                                  1,
                                  p_end_date,
                                  r.end_date))) end_date
        FROM gcs_cons_relationships r, gcs_treatments_b tb
       WHERE r.hierarchy_id = p_hierarchy_id
         AND r.child_entity_id = p_parent_entity_id
         AND r.actual_ownership_flag = 'Y'
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND p_start_date <= nvl(r.end_date, p_start_date)
         AND nvl(p_end_date, r.start_date) >= r.start_date
         AND tb.treatment_id = r.treatment_id
         AND tb.consolidation_type_code = 'FULL';
    v_module VARCHAR2(30);
  BEGIN
    v_module := 'Calc_Delta_To_All_Parents';
    module_log_write(v_module, g_module_enter);
    -- If we have already calculated deltas for this entity, return
    IF entity_exists(p_calc_parent_entities, p_parent_entity_id) =
       p_parent_entity_id THEN
      module_log_write(v_module, g_module_success);
      RETURN;
    END IF;
    -- Add the first child entity to the list of already-traversed entities
    -- to prevent looping
    v_traversed_entities(p_original_entity_id) := p_original_entity_id;
    -- Get the immediate unconsolidated parents of the original entity, and
    -- go up until you no longer have parents or you reach the parent entity,
    -- and then create the appropriate delta ownership rows
    FOR uncons_parent IN get_uncons_parent_c LOOP
      Calc_Delta_To_Single_Parent(p_hierarchy_id         => p_hierarchy_id,
                                  p_original_entity_id   => p_original_entity_id,
                                  p_parent_entity_id     => p_parent_entity_id,
                                  p_current_entity_id    => uncons_parent.parent_entity_id,
                                  p_effective_ownership  => uncons_parent.ownership_percent,
                                  p_start_date           => uncons_parent.start_date,
                                  p_end_date             => uncons_parent.end_date,
                                  p_traversed_entities   => v_traversed_entities,
                                  p_calc_parent_entities => p_calc_parent_entities);
    END LOOP;
    -- Add this entity to the list of entities that have already had deltas
    -- calculated for them
    p_calc_parent_entities(p_parent_entity_id) := p_parent_entity_id;
    -- Get the immediate consolidated parent of this entity if there is one,
    -- and recursively go up the hierarchy, creating delta ownership rows
    FOR cons_parent IN get_cons_parent_c LOOP
      -- Calculate the delta ownership to the parent entity specified here,
      -- along with all its ancestors. Work within the date range given, and
      -- do not go up branches that go to parents that are in the list of
      -- already-traversed entities to prevent infinite looping.
      Calc_Delta_To_All_Parents(p_hierarchy_id         => p_hierarchy_id,
                                p_original_entity_id   => p_original_entity_id,
                                p_parent_entity_id     => cons_parent.parent_entity_id,
                                p_start_date           => cons_parent.start_date,
                                p_end_date             => cons_parent.end_date,
                                p_calc_parent_entities => p_calc_parent_entities);
    END LOOP;
    -- Clear out this parent entity, since we could be calculating a delta
    -- ownership for this for a future date range
    p_calc_parent_entities(p_parent_entity_id) := NULL;
    module_log_write(v_module, g_module_success);
  EXCEPTION
    WHEN OTHERS THEN
      write_to_log(v_module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(v_module, g_module_failure);
      RAISE;
  END Calc_Delta_To_All_Parents;
  --
  -- Procedure
  --   Calculate_Delta_Internal
  -- Purpose
  --   This does the actual work of calculating the delta amounts. It has the
  --   added parameter of a list of entities for which we have already
  --   performed the delta calculation logic.
  -- Arguments
  --   p_hierarchy_id   Hierarchy for which the logic must be performed
  --   p_child_entity_id  Entity for which the logic must be performed
  --   p_effective_date   Date range for performing the logic
  --   p_calc_child_entities  Entities for which the calculation has already
  --        been performed
  -- Example
  --   GCS_HIERARCHIES_PKG.Calculate_Delta_Internal(...);
  -- Notes
  --
  PROCEDURE Calculate_Delta_Internal(p_hierarchy_id        NUMBER,
                                     p_child_entity_id     NUMBER,
                                     p_effective_date      DATE,
                                     p_calc_child_entities IN OUT NOCOPY EntitiesTableType) IS
    -- Used to get the full consolidated parent for this child. The decode
    -- exists to pick the most restrictive date range possible.
    CURSOR get_cons_parent_c IS
      SELECT r.parent_entity_id,
             decode(sign(r.start_date - p_effective_date),
                    1,
                    r.start_date,
                    p_effective_date) start_date,
             r.end_date
        FROM gcs_cons_relationships r, gcs_treatments_b tb
       WHERE r.hierarchy_id = p_hierarchy_id
         AND r.child_entity_id = p_child_entity_id
         AND r.actual_ownership_flag = 'Y'
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND p_effective_date <= nvl(r.end_date, p_effective_date)
         AND tb.treatment_id = r.treatment_id
         AND tb.consolidation_type_code = 'FULL';
    v_calc_parent_entities EntitiesTableType;
    -- Get a list of this entity's children, if any exist
    CURSOR get_child_entities_c IS
      SELECT r.child_entity_id
        FROM gcs_cons_relationships r
       WHERE r.hierarchy_id = p_hierarchy_id
         AND r.parent_entity_id = p_child_entity_id
         AND r.actual_ownership_flag = 'Y'
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND p_effective_date <= nvl(r.end_date, p_effective_date)
         AND r.treatment_id IS NOT NULL;
    v_module VARCHAR2(30);
  BEGIN
    v_module := 'Calculate_Delta_Internal';
    module_log_write(v_module, g_module_enter);
    -- If we've already calculated the deltas for this entity, return
    IF entity_exists(p_calc_child_entities, p_child_entity_id) =
       p_child_entity_id THEN
      module_log_write(v_module, g_module_success);
      RETURN;
    END IF;
    -- First, we clean things up by end-dating all delta relationships
    -- that end after this day. We'll be recalculating these amounts later.
    UPDATE gcs_cons_relationships
       SET end_date = p_effective_date - 1
     WHERE hierarchy_id = p_hierarchy_id
       AND child_entity_id = p_child_entity_id
       AND actual_ownership_flag = 'N'
       AND nvl(end_date, p_effective_date) >= p_effective_date;
    -- Add this entity to the list of entities that have already had deltas
    -- calculated for them
    v_calc_parent_entities(p_child_entity_id) := p_child_entity_id;
    -- Get the immediate consolidated parent of this child if there is one,
    -- and recursively go up the hierarchy, creating delta ownership rows
    FOR cons_parent IN get_cons_parent_c LOOP
      -- Calculate the delta ownership to the parent entity specified here,
      -- along with all its ancestors. Work within the date range given, and
      -- do not go up branches that go to parents that are in the list of
      -- already-traversed entities to prevent infinite looping.
      Calc_Delta_To_All_Parents(p_hierarchy_id         => p_hierarchy_id,
                                p_original_entity_id   => p_child_entity_id,
                                p_parent_entity_id     => cons_parent.parent_entity_id,
                                p_start_date           => cons_parent.start_date,
                                p_end_date             => cons_parent.end_date,
                                p_calc_parent_entities => v_calc_parent_entities);
    END LOOP;
    -- List this entity so that we can prevent infinite loops
    p_calc_child_entities(p_child_entity_id) := p_child_entity_id;
    -- Now go through all this entity's children and perform the same logic
    FOR child_entity_row IN get_child_entities_c LOOP
      Calculate_Delta_Internal(p_hierarchy_id        => p_hierarchy_id,
                               p_child_entity_id     => child_entity_row.child_entity_id,
                               p_effective_date      => p_effective_date,
                               p_calc_child_entities => p_calc_child_entities);
    END LOOP;
    module_log_write(v_module, g_module_success);
  EXCEPTION
    WHEN OTHERS THEN
      write_to_log(v_module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(v_module, g_module_failure);
      RAISE;
  END Calculate_Delta_Internal;
  --
  -- Public Procedures and Functions for Multiple Parents
  --
  --
  -- Procedure
  --   Calculate_Delta
  -- Purpose
  --   Calculates the delta ownership amounts for an entity and its children,
  --   and updates or creates the necessary gcs_cons_relationships row.
  -- Arguments
  --   p_hierarchy_id   Hierarchy for which the logic must be performed
  --   p_child_entity_id  Entity for which the logic must be performed
  --   p_effective_date   Start date for performing the logic
  -- Example
  --   GCS_HIERARCHIES_PKG.Calculate_Delta(...);
  -- Notes
  --
  PROCEDURE Calculate_Delta(p_hierarchy_id    NUMBER,
                            p_child_entity_id NUMBER,
                            p_effective_date  DATE) IS
    -- For holding the entities that have already had their deltas calculated
    v_calc_child_entities EntitiesTableType;
    v_module              VARCHAR2(30);
  BEGIN
    v_module := 'Calculate_Delta';
    module_log_write(v_module, g_module_enter);
    -- In case of an error, we will roll back to this point in time.
    SAVEPOINT gcs_calc_delta_single_entity;
    Calculate_Delta_Internal(p_hierarchy_id        => p_hierarchy_id,
                             p_child_entity_id     => p_child_entity_id,
                             p_effective_date      => p_effective_date,
                             p_calc_child_entities => v_calc_child_entities);
    module_log_write(v_module, g_module_success);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO gcs_calc_delta_single_entity;
      write_to_log(v_module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(v_module, g_module_failure);
      RAISE;
  END Calculate_Delta;
  --
  -- Procedure
  --   Reciprocal_Exists
  -- Purpose
  --   See whether or not a cycle exists in the hierarchy. Search recursively
  --   for the child entity id, starting from the parent entity id, within the
  --   dates specified.
  -- Arguments
  --   p_hierarchy_id   Hierarchy for which the logic must be performed
  --   p_child_id   Entity we are searching for
  --   p_parent_id    Entity to start the search from
  --   p_start_date   Effective date range
  --   p_end_date   Effective date range
  -- Example
  --   GCS_HIERARCHIES_PKG.Reciprocal_Exists(...);
  -- Notes
  --
  FUNCTION Reciprocal_Exists(p_hierarchy_id NUMBER,
                             p_child_id     NUMBER,
                             p_parent_id    NUMBER,
                             p_start_date   DATE,
                             p_end_date     DATE) RETURN VARCHAR2 IS
    CURSOR parents_c IS
      SELECT r.parent_entity_id,
             decode(sign(r.start_date - p_start_date),
                    1,
                    r.start_date,
                    p_start_date) start_date,
             decode(r.end_date,
                    null,
                    p_end_date,
                    decode(p_end_date,
                           null,
                           r.end_date,
                           decode(sign(r.end_date - p_end_date),
                                  1,
                                  p_end_date,
                                  r.end_date))) end_date
        FROM gcs_cons_relationships r
       WHERE r.hierarchy_id = p_hierarchy_id
         AND r.child_entity_id = p_parent_id
         AND r.actual_ownership_flag = 'Y'
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND p_start_date <= nvl(r.end_date, p_start_date)
         AND nvl(p_end_date, r.start_date) >= r.start_date;
  BEGIN
    IF p_parent_id = p_child_id THEN
      return 'Y';
    END IF;
    FOR parent_info in parents_c LOOP
      IF reciprocal_exists(p_hierarchy_id,
                           p_child_id,
                           parent_info.parent_entity_id,
                           parent_info.start_date,
                           parent_info.end_date) = 'Y' THEN
        return 'Y';
      END IF;
    END LOOP;
    return 'N';
  END Reciprocal_Exists;
  --
  -- Procedure
  --   Get_Ccy_Treat
  -- Purpose
  --   Get the currency treatment for a given relationship
  -- Arguments
  --   p_hierarchy_id   Hierarchy for which the logic must be performed
  --   p_parent_id    Parent entity
  --   p_parent_id    Child entity
  --   p_date     Date
  -- Example
  --   GCS_HIERARCHIES_PKG.Calc_Delta_To_All_Parents(...);
  -- Notes
  --
  FUNCTION get_Ccy_Treat(p_hierarchy_id NUMBER,
                         p_parent_id    NUMBER,
                         p_child_id     NUMBER,
                         p_date         DATE) RETURN NUMBER IS
    to_ccy     VARCHAR2(100);
    from_ccy   VARCHAR2(100);
    return_val NUMBER;
    CURSOR locked_ccy_treat_c IS
      SELECT cr.curr_treatment_id
        FROM gcs_cons_eng_runs       r,
             gcs_cons_eng_run_dtls   rd,
             fem_cal_periods_attr    cpa,
             gcs_cons_relationships  cr,
             fem_dim_attributes_b    fdab,
             fem_dim_attr_versions_b fdavb
       WHERE r.hierarchy_id = p_hierarchy_id
         AND r.run_entity_id = p_parent_id
         AND rd.run_name = r.run_name
         AND rd.consolidation_entity_id = p_parent_id
         AND rd.child_entity_id = p_child_id
         AND fdab.attribute_varchar_label = 'CAL_PERIOD_END_DATE'
         AND fdavb.attribute_id = fdab.attribute_id
         AND fdavb.default_version_flag = 'Y'
         AND cpa.cal_period_id = r.cal_period_id
         AND cpa.attribute_id = fdab.attribute_id
         AND cpa.version_id = fdavb.version_id
         AND cpa.date_assign_value < p_date
         AND cr.cons_relationship_id = rd.cons_relationship_id
       order by cpa.date_assign_value, rd.last_update_date desc;
    CURSOR def_ccy_treat_c IS
      SELECT ctb.curr_treatment_id
        FROM gcs_curr_treatments_b ctb
       WHERE ctb.enabled_flag = 'Y'
       ORDER BY decode(ctb.default_flag, 'Y', 0, 1), ctb.curr_treatment_id;
  BEGIN
    SELECT currency_code
      INTO to_ccy
      FROM gcs_entity_cons_attrs
     WHERE hierarchy_id = p_hierarchy_id
       AND entity_id = p_parent_id;
    SELECT currency_code
      INTO from_ccy
      FROM gcs_entity_cons_attrs
     WHERE hierarchy_id = p_hierarchy_id
       AND entity_id = p_child_id;
    IF to_ccy = from_ccy THEN
      return null;
    END IF;
    OPEN locked_ccy_treat_c;
    FETCH locked_ccy_treat_c
      INTO return_val;
    IF locked_ccy_treat_c%FOUND THEN
      CLOSE locked_ccy_treat_c;
      return return_val;
    END IF;
    CLOSE locked_ccy_treat_c;
    OPEN def_ccy_treat_c;
    FETCH def_ccy_treat_c
      INTO return_val;
    IF def_ccy_treat_c%FOUND THEN
      CLOSE def_ccy_treat_c;
      return return_val;
    END IF;
    CLOSE def_ccy_treat_c;
    return null;
  END Get_Ccy_Treat;
  --
  -- Procedure
  --   Set_Dominance
  -- Purpose
  --   Set the dominant parent flag for a relationship after an add or update
  --   entity in the update flow.
  -- Arguments
  --   p_rel_id               New relationship identifier
  -- Example
  --   GCS_HIERARCHIES_PKG.Set_Dominance(123, 'ADD');
  -- Notes
  --
  PROCEDURE Set_Dominance(p_rel_id NUMBER) IS
    l_hierarchy_id  NUMBER;
    l_parent_id     NUMBER;
    l_child_id      NUMBER;
    l_ownership     NUMBER;
    l_start_date    DATE;
    l_treat_id      NUMBER;
    l_ccy_treat_id  NUMBER;
    l_dominant_flag VARCHAR2(1);
    l_treat_type    VARCHAR2(30);
    l_from_ccy      VARCHAR2(30);
    l_to_ccy        VARCHAR2(30);
    CURSOR other_dominant_c IS
      SELECT r.*
        FROM gcs_cons_relationships r
       WHERE r.hierarchy_id = l_hierarchy_id
         AND r.child_entity_id = l_child_id
         AND r.parent_entity_id <> l_parent_id
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND l_start_date <= nvl(r.end_date, l_start_date)
         AND r.actual_ownership_flag = 'Y'
         AND r.dominant_parent_flag = 'Y';
    CURSOR future_full_c IS
      SELECT r.*
        FROM gcs_cons_relationships r, gcs_treatments_b tb
       WHERE r.hierarchy_id = l_hierarchy_id
         AND r.child_entity_id = l_child_id
         AND r.parent_entity_id <> l_parent_id
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND l_start_date <= r.start_date
         AND r.actual_ownership_flag = 'Y'
         AND tb.treatment_id = r.treatment_id
         AND tb.consolidation_type_code = 'FULL'
       ORDER BY r.start_date;
    CURSOR non_full_dominant_straddle_c IS
      SELECT r.cons_relationship_id
        FROM gcs_cons_relationships r, gcs_treatments_b tb
       WHERE r.hierarchy_id = l_hierarchy_id
         AND r.child_entity_id = l_child_id
         AND r.parent_entity_id <> l_parent_id
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND r.start_date < l_start_date
         AND l_start_date <= nvl(r.end_date, l_start_date)
         AND r.actual_ownership_flag = 'Y'
         AND r.dominant_parent_flag = 'Y'
         AND tb.treatment_id = r.treatment_id
         AND tb.consolidation_type_code = 'NONE';
    l_temp_rel_id NUMBER;
    CURSOR future_rel_c IS
      SELECT r.*
        FROM gcs_cons_relationships r
       WHERE r.hierarchy_id = l_hierarchy_id
         AND r.child_entity_id = l_child_id
         AND r.parent_entity_id <> l_parent_id
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND l_start_date <= nvl(r.end_date, l_start_date)
         AND r.actual_ownership_flag = 'Y'
       ORDER BY r.start_date;
    l_last_end_date DATE;
    CURSOR future_dominant_rel_c IS
      SELECT r.*
        FROM gcs_cons_relationships r
       WHERE r.hierarchy_id = l_hierarchy_id
         AND r.child_entity_id = l_child_id
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND l_start_date <= nvl(r.end_date, l_start_date)
         AND r.actual_ownership_flag = 'Y'
         AND r.dominant_parent_flag = 'Y'
       ORDER BY r.start_date;
    l_temp_parent_id    NUMBER;
    l_temp_ccy_treat_id NUMBER;
  BEGIN
    SELECT r.hierarchy_id,
           r.parent_entity_id,
           r.child_entity_id,
           r.ownership_percent,
           r.start_date,
           r.treatment_id,
           r.curr_treatment_id,
           r.dominant_parent_flag,
           tb.consolidation_type_code
      INTO l_hierarchy_id,
           l_parent_id,
           l_child_id,
           l_ownership,
           l_start_date,
           l_treat_id,
           l_ccy_treat_id,
           l_dominant_flag,
           l_treat_type
      FROM gcs_cons_relationships r, gcs_treatments_b tb
     WHERE r.cons_relationship_id = p_rel_id
       AND tb.treatment_id = r.treatment_id;
    IF l_treat_type = 'FULL' THEN
      UPDATE gcs_cons_relationships r
         SET dominant_parent_flag = 'Y'
       WHERE r.cons_relationship_id = p_rel_id;
      FOR other_row IN other_dominant_c LOOP
        -- Split a row if necessary
        IF other_row.start_date < l_start_date THEN
          INSERT INTO gcs_cons_relationships
            (CONS_RELATIONSHIP_ID,
             HIERARCHY_ID,
             PARENT_ENTITY_ID,
             CHILD_ENTITY_ID,
             OWNERSHIP_PERCENT,
             START_DATE,
             TREATMENT_ID,
             CURR_TREATMENT_ID,
             OBJECT_VERSION_NUMBER,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             END_DATE,
             DOMINANT_PARENT_FLAG,
             ACTUAL_OWNERSHIP_FLAG)
          VALUES
            (gcs_cons_relationships_s.nextval,
             other_row.hierarchy_id,
             other_row.parent_entity_id,
             other_row.child_entity_id,
             other_row.ownership_percent,
             l_start_date,
             other_row.treatment_id,
             null,
             1,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID,
             FND_GLOBAL.LOGIN_ID,
             other_row.end_date,
             'N',
             other_row.actual_ownership_flag);
          UPDATE gcs_cons_relationships r
             SET end_date          = l_start_date - 1,
                 last_update_date  = sysdate,
                 last_updated_by   = FND_GLOBAL.USER_ID,
                 last_update_login = FND_GLOBAL.LOGIN_ID
           WHERE r.cons_relationship_id = other_row.cons_relationship_id;
        ELSE
          UPDATE gcs_cons_relationships r
             SET dominant_parent_flag = 'N',
                 curr_treatment_id    = null,
                 last_update_date     = sysdate,
                 last_updated_by      = FND_GLOBAL.USER_ID,
                 last_update_login    = FND_GLOBAL.LOGIN_ID
           WHERE r.cons_relationship_id = other_row.cons_relationship_id;
        END IF;
      END LOOP;
    ELSIF l_treat_type = 'NONE' THEN
      IF l_dominant_flag = 'Y' THEN
        -- Split so that for any future full relationships, the relationship's
        -- dominant parent flag = 'N' and currency treatment is null
        FOR future_full_row IN future_full_c LOOP
          UPDATE gcs_cons_relationships r
             SET end_date = future_full_row.start_date - 1
           WHERE r.hierarchy_id = l_hierarchy_id
             AND r.parent_entity_id = l_parent_id
             AND r.child_entity_id = l_child_id
             AND r.end_date IS NULL
             AND r.actual_ownership_flag = 'Y';
          INSERT INTO gcs_cons_relationships
            (CONS_RELATIONSHIP_ID,
             HIERARCHY_ID,
             PARENT_ENTITY_ID,
             CHILD_ENTITY_ID,
             OWNERSHIP_PERCENT,
             START_DATE,
             TREATMENT_ID,
             CURR_TREATMENT_ID,
             OBJECT_VERSION_NUMBER,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             END_DATE,
             DOMINANT_PARENT_FLAG,
             ACTUAL_OWNERSHIP_FLAG)
          VALUES
            (gcs_cons_relationships_s.nextval,
             l_hierarchy_id,
             l_parent_id,
             l_child_id,
             l_ownership,
             future_full_row.start_date,
             l_treat_id,
             null,
             1,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID,
             FND_GLOBAL.LOGIN_ID,
             future_full_row.end_date,
             'N',
             'Y');
          IF future_full_row.end_date IS NOT NULL THEN
            INSERT INTO gcs_cons_relationships
              (CONS_RELATIONSHIP_ID,
               HIERARCHY_ID,
               PARENT_ENTITY_ID,
               CHILD_ENTITY_ID,
               OWNERSHIP_PERCENT,
               START_DATE,
               TREATMENT_ID,
               CURR_TREATMENT_ID,
               OBJECT_VERSION_NUMBER,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               END_DATE,
               DOMINANT_PARENT_FLAG,
               ACTUAL_OWNERSHIP_FLAG)
            VALUES
              (gcs_cons_relationships_s.nextval,
               l_hierarchy_id,
               l_parent_id,
               l_child_id,
               l_ownership,
               future_full_row.end_date + 1,
               l_treat_id,
               l_ccy_treat_id,
               1,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID,
               null,
               'Y',
               'Y');
          END IF;
        END LOOP;
        -- Split a dominant relationship if it straddles the start date
        OPEN non_full_dominant_straddle_c;
        FETCH non_full_dominant_straddle_c
          INTO l_temp_rel_id;
        IF non_full_dominant_straddle_c%FOUND THEN
          CLOSE non_full_dominant_straddle_c;
          INSERT INTO gcs_cons_relationships
            (CONS_RELATIONSHIP_ID,
             HIERARCHY_ID,
             PARENT_ENTITY_ID,
             CHILD_ENTITY_ID,
             OWNERSHIP_PERCENT,
             START_DATE,
             TREATMENT_ID,
             CURR_TREATMENT_ID,
             OBJECT_VERSION_NUMBER,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             END_DATE,
             DOMINANT_PARENT_FLAG,
             ACTUAL_OWNERSHIP_FLAG)
            SELECT gcs_cons_relationships_s.nextval,
                   r.hierarchy_id,
                   r.parent_entity_id,
                   r.child_entity_id,
                   r.ownership_percent,
                   l_start_date,
                   r.treatment_id,
                   null,
                   1,
                   sysdate,
                   FND_GLOBAL.USER_ID,
                   sysdate,
                   FND_GLOBAL.USER_ID,
                   FND_GLOBAL.LOGIN_ID,
                   r.end_date,
                   'N',
                   'Y'
              FROM gcs_cons_relationships r
             WHERE r.cons_relationship_id = l_temp_rel_id;
          UPDATE gcs_cons_relationships r
             SET end_date = l_start_date - 1
           WHERE r.cons_relationship_id = l_temp_rel_id;
        ELSE
          CLOSE non_full_dominant_straddle_c;
        END IF;
        -- Update all relationships that are on or after this date, with a
        -- different parent, that are not full relationships, to be not
        -- dominant parents
        UPDATE gcs_cons_relationships r
           SET dominant_parent_flag = 'N', curr_treatment_id = null
         WHERE r.hierarchy_id = l_hierarchy_id
           AND r.child_entity_id = l_child_id
           AND r.parent_entity_id <> l_parent_id
           AND r.start_date <= nvl(r.end_date, r.start_date)
           AND r.start_date >= l_start_date
           AND r.actual_ownership_flag = 'Y'
           AND r.dominant_parent_flag = 'Y'
           AND EXISTS
         (SELECT 1
                  FROM gcs_treatments_b tb
                 WHERE tb.treatment_id = r.treatment_id
                   AND tb.consolidation_type_code = 'NONE');
      ELSE
        -- dominant flag = 'N'
        SELECT currency_code
          INTO l_from_ccy
          FROM gcs_entity_cons_attrs
         WHERE hierarchy_id = l_hierarchy_id
           AND entity_id = l_child_id;
        SELECT currency_code
          INTO l_to_ccy
          FROM gcs_entity_cons_attrs
         WHERE hierarchy_id = l_hierarchy_id
           AND entity_id = l_parent_id;
        -- Set the currency treatment that should be used when required
        IF l_from_ccy = l_to_ccy THEN
          l_ccy_treat_id := null;
        END IF;
        l_last_end_date := l_start_date - 1;
        FOR future_rel_row IN future_rel_c LOOP
          -- If there is a gap, create a relationship
          IF l_last_end_date IS NOT NULL AND
             l_last_end_date < future_rel_row.start_date - 1 THEN
            UPDATE gcs_cons_relationships r
               SET end_date = l_last_end_date
             WHERE r.hierarchy_id = l_hierarchy_id
               AND r.parent_entity_id = l_parent_id
               AND r.child_entity_id = l_child_id
               AND r.end_date IS NULL
               AND r.actual_ownership_flag = 'Y';
            INSERT INTO gcs_cons_relationships
              (CONS_RELATIONSHIP_ID,
               HIERARCHY_ID,
               PARENT_ENTITY_ID,
               CHILD_ENTITY_ID,
               OWNERSHIP_PERCENT,
               START_DATE,
               TREATMENT_ID,
               CURR_TREATMENT_ID,
               OBJECT_VERSION_NUMBER,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               END_DATE,
               DOMINANT_PARENT_FLAG,
               ACTUAL_OWNERSHIP_FLAG)
            VALUES
              (gcs_cons_relationships_s.nextval,
               l_hierarchy_id,
               l_parent_id,
               l_child_id,
               l_ownership,
               l_last_end_date + 1,
               l_treat_id,
               l_ccy_treat_id,
               1,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID,
               future_rel_row.start_date - 1,
               'Y',
               'Y');
            INSERT INTO gcs_cons_relationships
              (CONS_RELATIONSHIP_ID,
               HIERARCHY_ID,
               PARENT_ENTITY_ID,
               CHILD_ENTITY_ID,
               OWNERSHIP_PERCENT,
               START_DATE,
               TREATMENT_ID,
               CURR_TREATMENT_ID,
               OBJECT_VERSION_NUMBER,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               END_DATE,
               DOMINANT_PARENT_FLAG,
               ACTUAL_OWNERSHIP_FLAG)
            VALUES
              (gcs_cons_relationships_s.nextval,
               l_hierarchy_id,
               l_parent_id,
               l_child_id,
               l_ownership,
               future_rel_row.start_date,
               l_treat_id,
               null,
               1,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID,
               null,
               'N',
               'Y');
          END IF;
          -- Update the future relationship end date appropriately
          IF l_last_end_date IS NOT NULL AND
             (future_rel_row.end_date IS NULL OR
             l_last_end_date < future_rel_row.end_date) THEN
            l_last_end_date := future_rel_row.end_date;
          END IF;
        END LOOP;
        -- If the last relationship does not go to null, insert a row
        IF l_last_end_date IS NOT NULL THEN
          UPDATE gcs_cons_relationships r
             SET end_date = l_last_end_date
           WHERE r.hierarchy_id = l_hierarchy_id
             AND r.parent_entity_id = l_parent_id
             AND r.child_entity_id = l_child_id
             AND r.end_date IS NULL
             and r.actual_ownership_flag = 'Y';
          INSERT INTO gcs_cons_relationships
            (CONS_RELATIONSHIP_ID,
             HIERARCHY_ID,
             PARENT_ENTITY_ID,
             CHILD_ENTITY_ID,
             OWNERSHIP_PERCENT,
             START_DATE,
             TREATMENT_ID,
             CURR_TREATMENT_ID,
             OBJECT_VERSION_NUMBER,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             END_DATE,
             DOMINANT_PARENT_FLAG,
             ACTUAL_OWNERSHIP_FLAG)
          VALUES
            (gcs_cons_relationships_s.nextval,
             l_hierarchy_id,
             l_parent_id,
             l_child_id,
             l_ownership,
             l_last_end_date + 1,
             l_treat_id,
             l_ccy_treat_id,
             1,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID,
             FND_GLOBAL.LOGIN_ID,
             null,
             'Y',
             'Y');
        END IF;
        UPDATE gcs_cons_relationships r
           SET curr_treatment_id = NULL
         WHERE r.hierarchy_id = l_hierarchy_id
           AND r.parent_entity_id = l_parent_id
           AND r.child_entity_id = l_child_id
           AND r.start_date <= nvl(r.end_date, r.start_date)
           AND r.start_date >= l_start_date
           AND r.dominant_parent_flag = 'N'
           AND r.actual_ownership_flag = 'Y'
           AND r.curr_treatment_id IS NOT NULL;
        l_last_end_date := l_start_date - 1;
        -- if there are any dominance gaps, fill them here
        FOR future_dominant_rel_row IN future_dominant_rel_c LOOP
          IF future_dominant_rel_row.start_date > l_last_end_date + 1 THEN
            begin
              SELECT r.cons_relationship_id, r.parent_entity_id
                INTO l_temp_rel_id, l_temp_parent_id
                FROM gcs_cons_relationships r
               WHERE r.hierarchy_id = l_hierarchy_id
                 AND r.child_entity_id = l_child_id
                 AND r.start_date <= nvl(r.end_date, r.start_date)
                 AND r.start_date = l_last_end_date + 1
                 AND r.end_date = future_dominant_rel_row.start_date - 1
                 AND r.actual_ownership_flag = 'Y'
                 AND r.dominant_parent_flag = 'N'
                 AND rownum = 1;
              l_temp_ccy_treat_id := get_ccy_treat(l_hierarchy_id,
                                                   l_temp_parent_id,
                                                   l_child_id,
                                                   l_last_end_date + 1);
              UPDATE gcs_cons_relationships r
                 SET dominant_parent_flag = 'Y',
                     curr_treatment_id    = l_temp_ccy_treat_id
               WHERE r.cons_relationship_id = l_temp_rel_id;
            exception
              when others then
                null;
            end;
          END IF;
          IF l_last_end_date IS NOT NULL AND
             (future_dominant_rel_row.end_date IS NULL OR
             l_last_end_date < future_dominant_rel_row.end_date) THEN
            l_last_end_date := future_dominant_rel_row.end_date;
          END IF;
        END LOOP;
        IF l_last_end_date IS NOT NULL THEN
          begin
            SELECT r.cons_relationship_id, r.parent_entity_id
              INTO l_temp_rel_id, l_temp_parent_id
              FROM gcs_cons_relationships r
             WHERE r.hierarchy_id = l_hierarchy_id
               AND r.child_entity_id = l_child_id
               AND r.start_date <= nvl(r.end_date, r.start_date)
               AND r.start_date = l_last_end_date + 1
               AND r.end_date IS NULL
               AND r.actual_ownership_flag = 'Y'
               AND r.dominant_parent_flag = 'N'
               AND rownum = 1;
            l_temp_ccy_treat_id := get_ccy_treat(l_hierarchy_id,
                                                 l_temp_parent_id,
                                                 l_child_id,
                                                 l_last_end_date + 1);
            UPDATE gcs_cons_relationships r
               SET dominant_parent_flag = 'Y',
                   curr_treatment_id    = l_temp_ccy_treat_id
             WHERE r.cons_relationship_id = l_temp_rel_id;
          exception
            when others then
              null;
          end;
        END IF;
      END IF;
    END IF;
  END Set_Dominance;
  PROCEDURE Handle_Remove_Internal(p_hier_id      NUMBER,
                                   p_parent_id    NUMBER,
                                   p_child_id     NUMBER,
                                   p_start_date   DATE,
                                   p_end_date     DATE,
                                   p_removal_date DATE,
                                   p_ownership    NUMBER,
                                   p_treat_id     NUMBER,
                                   p_dom_flag     VARCHAR2) IS
    CURSOR all_dominant_rel_c IS
      SELECT r.*
        FROM gcs_cons_relationships r
       WHERE r.hierarchy_id = p_hier_id
         AND r.child_entity_id = p_child_id
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND p_start_date <= nvl(r.end_date, p_start_date)
         AND r.start_date <= nvl(p_end_date, r.start_date)
         AND r.actual_ownership_flag = 'Y'
         AND r.dominant_parent_flag = 'Y'
       ORDER BY r.start_date;
    l_last_end_date DATE;
    l_ccy_treat_id  NUMBER;
    l_temp_end_date DATE;
    l_temp_date     DATE;
    CURSOR all_child_rels_c IS
      SELECT r.*
        FROM gcs_cons_relationships r
       WHERE r.hierarchy_id = p_hier_id
         AND r.parent_entity_id = p_child_id
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND l_temp_date <= nvl(r.end_date, l_temp_date)
         AND r.actual_ownership_flag = 'Y';
  BEGIN
    IF p_removal_date > p_start_date THEN
      l_temp_date := p_removal_date;
    ELSE
      l_temp_date := p_start_date;
    END IF;
    l_last_end_date := l_temp_date - 1;
    IF p_dom_flag = 'N' THEN
      FOR dominant_rel_row IN all_dominant_rel_c LOOP
        IF dominant_rel_row.start_date > l_last_end_date + 1 THEN
          UPDATE gcs_cons_relationships r
             SET end_date = l_last_end_date
           WHERE r.hierarchy_id = p_hier_id
             AND r.parent_entity_id = p_parent_id
             AND r.child_entity_id = p_child_id
             AND r.start_date <= nvl(r.end_date, r.start_date)
             AND r.actual_ownership_flag = 'Y'
             AND r.dominant_parent_flag = 'N'
             AND ((r.end_date IS NULL AND p_end_date IS NULL) OR
                 (r.end_date = p_end_date));
          l_ccy_treat_id := get_ccy_treat(p_hier_id,
                                          p_parent_id,
                                          p_child_id,
                                          l_last_end_date + 1);
          INSERT INTO gcs_cons_relationships
            (CONS_RELATIONSHIP_ID,
             HIERARCHY_ID,
             PARENT_ENTITY_ID,
             CHILD_ENTITY_ID,
             OWNERSHIP_PERCENT,
             START_DATE,
             TREATMENT_ID,
             CURR_TREATMENT_ID,
             OBJECT_VERSION_NUMBER,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             END_DATE,
             DOMINANT_PARENT_FLAG,
             ACTUAL_OWNERSHIP_FLAG)
          VALUES
            (gcs_cons_relationships_s.nextval,
             p_hier_id,
             p_parent_id,
             p_child_id,
             p_ownership,
             l_last_end_date + 1,
             p_treat_id,
             l_ccy_treat_id,
             1,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID,
             FND_GLOBAL.LOGIN_ID,
             dominant_rel_row.start_date - 1,
             'Y',
             'Y');
          IF dominant_rel_row.end_date IS NULL OR
             dominant_rel_row.end_date > p_end_date THEN
            l_temp_end_date := p_end_date;
          ELSE
            l_temp_end_date := dominant_rel_row.end_date;
          END IF;
          INSERT INTO gcs_cons_relationships
            (CONS_RELATIONSHIP_ID,
             HIERARCHY_ID,
             PARENT_ENTITY_ID,
             CHILD_ENTITY_ID,
             OWNERSHIP_PERCENT,
             START_DATE,
             TREATMENT_ID,
             CURR_TREATMENT_ID,
             OBJECT_VERSION_NUMBER,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             END_DATE,
             DOMINANT_PARENT_FLAG,
             ACTUAL_OWNERSHIP_FLAG)
          VALUES
            (gcs_cons_relationships_s.nextval,
             p_hier_id,
             p_parent_id,
             p_child_id,
             p_ownership,
             dominant_rel_row.start_date,
             p_treat_id,
             null,
             1,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID,
             FND_GLOBAL.LOGIN_ID,
             l_temp_end_date,
             'N',
             'Y');
        END IF;
        IF l_last_end_date IS NOT NULL AND
           (dominant_rel_row.end_date IS NULL OR
           l_last_end_date < dominant_rel_row.end_date) THEN
          l_last_end_date := dominant_rel_row.end_date;
        END IF;
      END LOOP;
      IF l_last_end_date IS NOT NULL AND
         (p_end_date IS NULL OR l_last_end_date < p_end_date) THEN
        UPDATE gcs_cons_relationships r
           SET end_date = l_last_end_date
         WHERE r.hierarchy_id = p_hier_id
           AND r.parent_entity_id = p_parent_id
           AND r.child_entity_id = p_child_id
           AND r.start_date <= nvl(r.end_date, r.start_date)
           AND r.actual_ownership_flag = 'Y'
           AND r.dominant_parent_flag = 'N'
           AND ((r.end_date IS NULL AND p_end_date IS NULL) OR
               (r.end_date = p_end_date));
        l_ccy_treat_id := get_ccy_treat(p_hier_id,
                                        p_parent_id,
                                        p_child_id,
                                        l_last_end_date + 1);
        INSERT INTO gcs_cons_relationships
          (CONS_RELATIONSHIP_ID,
           HIERARCHY_ID,
           PARENT_ENTITY_ID,
           CHILD_ENTITY_ID,
           OWNERSHIP_PERCENT,
           START_DATE,
           TREATMENT_ID,
           CURR_TREATMENT_ID,
           OBJECT_VERSION_NUMBER,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           END_DATE,
           DOMINANT_PARENT_FLAG,
           ACTUAL_OWNERSHIP_FLAG)
        VALUES
          (gcs_cons_relationships_s.nextval,
           p_hier_id,
           p_parent_id,
           p_child_id,
           p_ownership,
           l_last_end_date + 1,
           p_treat_id,
           l_ccy_treat_id,
           1,
           sysdate,
           FND_GLOBAL.USER_ID,
           sysdate,
           FND_GLOBAL.USER_ID,
           FND_GLOBAL.LOGIN_ID,
           p_end_date,
           'Y',
           'Y');
      END IF;
    END IF;
    FOR all_child_rel_row IN all_child_rels_c LOOP
      handle_remove_internal(p_hier_id,
                             all_child_rel_row.parent_entity_id,
                             all_child_rel_row.child_entity_id,
                             all_child_rel_row.start_date,
                             all_child_rel_row.end_date,
                             l_temp_date,
                             all_child_rel_row.ownership_percent,
                             all_child_rel_row.treatment_id,
                             all_child_rel_row.dominant_parent_flag);
    END LOOP;
  END Handle_Remove_Internal;
  --
  -- Procedure
  --   Handle_Remove
  -- Purpose
  --   Handle removal of an entity in the update flow.
  -- Arguments
  --   p_hier_id               Hierarchy identifier
  --   p_removal_date          Date of the removal
  -- Example
  --   GCS_HIERARCHIES_PKG.Set_Dominance(123, 'ADD');
  -- Notes
  --
  PROCEDURE Handle_Remove(p_hier_id NUMBER, p_removal_date DATE) IS
    CURSOR all_child_rels_c IS
      SELECT r.*
        FROM gcs_cons_relationships r
       WHERE r.hierarchy_id = p_hier_id
         AND r.parent_entity_id =
             (SELECT hb.top_entity_id
                FROM gcs_hierarchies_b hb
               WHERE hb.hierarchy_id = p_hier_id)
         AND r.start_date <= nvl(r.end_date, r.start_date)
         AND p_removal_date <= nvl(r.end_date, p_removal_date)
         AND r.actual_ownership_flag = 'Y';
    CURSOR cons_entity_no_assoc_c IS
      SELECT r.child_entity_id, r.start_date, r.end_date
        FROM gcs_cons_relationships  r,
             fem_entities_attr       fea_type,
             fem_dim_attributes_b    fdab_type,
             fem_dim_attr_versions_b fdavb_type
       WHERE r.hierarchy_id = p_hier_id
         AND r.start_date > p_removal_date
         AND fea_type.entity_id = r.child_entity_id
         AND fea_type.attribute_id = fdab_type.attribute_id
         AND fea_type.version_id = fdavb_type.version_id
         AND fdab_type.attribute_varchar_label = 'ENTITY_TYPE_CODE'
         AND fdavb_type.attribute_id = fdab_type.attribute_id
         AND fdavb_type.default_version_flag = 'Y'
         AND fea_type.dim_attribute_varchar_member = 'C'
         AND NOT EXISTS
       (SELECT 1
                FROM gcs_cons_relationships rassoc
               WHERE rassoc.hierarchy_id = p_hier_id
                 AND rassoc.parent_entity_id = r.child_entity_id
                 AND rassoc.start_date <= r.start_date
                 AND (rassoc.end_date IS NULL OR
                     (r.end_date IS NOT NULL AND
                     rassoc.end_date >= r.end_date))
                 AND rassoc.actual_ownership_flag = 'Y'
                 AND rassoc.treatment_id IS NULL)
       ORDER BY r.child_entity_id, r.start_date;
    l_child_id   NUMBER;
    l_start_date DATE;
    l_end_date   DATE;
  BEGIN
    FOR all_child_rel_row IN all_child_rels_c LOOP
      handle_remove_internal(p_hier_id,
                             all_child_rel_row.parent_entity_id,
                             all_child_rel_row.child_entity_id,
                             all_child_rel_row.start_date,
                             all_child_rel_row.end_date,
                             p_removal_date,
                             all_child_rel_row.ownership_percent,
                             all_child_rel_row.treatment_id,
                             all_child_rel_row.dominant_parent_flag);
    END LOOP;
    OPEN cons_entity_no_assoc_c;
    FETCH cons_entity_no_assoc_c
      INTO l_child_id, l_start_date, l_end_date;
    WHILE cons_entity_no_assoc_c%FOUND LOOP
      CLOSE cons_entity_no_assoc_c;
      INSERT INTO gcs_cons_relationships
        (CONS_RELATIONSHIP_ID,
         HIERARCHY_ID,
         PARENT_ENTITY_ID,
         CHILD_ENTITY_ID,
         OWNERSHIP_PERCENT,
         START_DATE,
         TREATMENT_ID,
         CURR_TREATMENT_ID,
         OBJECT_VERSION_NUMBER,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         END_DATE,
         DOMINANT_PARENT_FLAG,
         ACTUAL_OWNERSHIP_FLAG)
        SELECT gcs_cons_relationships_s.nextval,
               p_hier_id,
               l_child_id,
               fea.DIM_ATTRIBUTE_NUMERIC_MEMBER,
               100,
               l_start_date,
               null,
               null,
               1,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID,
               l_end_date,
               'Y',
               'Y'
          FROM fem_entities_attr       fea,
               fem_dim_attributes_b    fdab,
               fem_dim_attr_versions_b fdavb
         WHERE fea.entity_id = l_child_id
           AND fea.attribute_id = fdab.attribute_id
           AND fea.version_id = fdavb.version_id
           AND fdab.attribute_varchar_label IN
               ('OPERATING_ENTITY', 'ELIMINATION_ENTITY')
           AND fdavb.attribute_id = fdab.attribute_id
           AND fdavb.default_version_flag = 'Y';
      OPEN cons_entity_no_assoc_c;
      FETCH cons_entity_no_assoc_c
        INTO l_child_id, l_start_date, l_end_date;
    END LOOP;
    CLOSE cons_entity_no_assoc_c;
  END Handle_Remove;

  --
  -- Procedure
  --   Update_Hierarchies_Datatype
  -- Purpose
  --   .
  -- Arguments
  --   p_data_type_code         Data Type Code identifier
  -- Example
  --   GCS_HIERARCHIES_PKG.Update_Hierarchies_Datatype('TEST' );
  -- Notes
  --
  PROCEDURE Update_Hierarchies_Datatype(p_data_type_code VARCHAR2) IS
    TYPE hier_info_rec_type IS RECORD(
      hier_id   NUMBER,
      hier_name VARCHAR2(150));
    TYPE t_heir_info IS TABLE OF hier_info_rec_type;
    l_hier_info            t_heir_info;
    l_data_type_name       VARCHAR2(30) := NULL;
    l_fem_balance_type     VARCHAR2(30) := NULL;
    l_dataset_code         NUMBER;
    l_budget_id            NUMBER := NULL;
    l_encumbrance_type_id  NUMBER := NULL;
    l_base_balance_type    VARCHAR2(30);
    l_analyze_balance_type VARCHAR2(30);
    l_base_display_code    VARCHAR2(1000);
    l_analyze_display_code VARCHAR2(1000);
    l_base_description     VARCHAR2(1000);
    l_analyze_description  VARCHAR2(1000);
    l_base_ds_code         NUMBER;
    l_analyze_ds_code      NUMBER;
    l_base_err_code    NUMBER;
    l_base_num_msg     NUMBER;
    l_analyze_err_code NUMBER;
    l_analyze_num_msg  NUMBER;
    l_counter          NUMBER;
  BEGIN
    -- Get Source Data Set's FEM Balance type code for the given data type code.
    SELECT gdtctl.data_type_name,
           gdtcb.source_dataset_code,
           fda.dim_attribute_varchar_member
      INTO l_data_type_name, l_dataset_code, l_fem_balance_type
      FROM gcs_data_type_codes_b   gdtcb,
           gcs_data_type_codes_tl  gdtctl,
           fem_dim_attributes_b    fdab,
           fem_dim_attr_versions_b fdavb,
           fem_datasets_attr       fda
     WHERE gdtcb.source_dataset_code = fda.dataset_code
       AND gdtcb.data_type_id = gdtctl.data_type_id
       AND gdtctl.language = userenv('LANG')
       AND fda.attribute_id = fdab.attribute_id
       AND fdab.attribute_id = fdavb.attribute_id
       AND fda.version_id = fdavb.version_id
       AND fdavb.default_version_flag = 'Y'
       AND fda.attribute_id = gcs_utility_pkg.get_dimension_attribute('DATASET_CODE-DATASET_BALANCE_TYPE_CODE')
       AND gdtcb.data_type_code = p_data_type_code;

    -- If the source dataset is a budget or encumbrance, get the budget or encumbrance type id of the source dataset
    IF l_fem_balance_type = 'BUDGET' THEN
      SELECT fda.dim_attribute_numeric_member
        INTO l_budget_id
        FROM fem_datasets_attr       fda,
             fem_dim_attributes_b    fdab,
             fem_dim_attr_versions_b fdavb
       WHERE fda.attribute_id  = fdab.attribute_id
         AND fdab.attribute_id = fdavb.attribute_id
         AND fda.version_id    = fdavb.version_id
         AND fdavb.default_version_flag = 'Y'
         AND fda.attribute_id = gcs_utility_pkg.get_dimension_attribute('DATASET_CODE-BUDGET_ID')
         AND fda.dataset_code = l_dataset_code;
    END IF;

    IF l_fem_balance_type = 'ENCUMBRANCE' THEN
      SELECT fda.dim_attribute_numeric_member
        INTO l_encumbrance_type_id
        FROM fem_datasets_attr       fda,
             fem_dim_attributes_b    fdab,
             fem_dim_attr_versions_b fdavb
       WHERE fda.attribute_id  = fdab.attribute_id
         AND fdab.attribute_id = fdavb.attribute_id
         AND fda.version_id    = fdavb.version_id
         AND fdavb.default_version_flag = 'Y'
         AND fda.attribute_id = gcs_utility_pkg.get_dimension_attribute('DATASET_CODE-ENCUMBRANCE_TYPE_ID')
         AND fda.dataset_code = l_dataset_code;
    END IF;

    l_base_balance_type    := p_data_type_code;
    l_analyze_balance_type := 'ANALYZE_' || p_data_type_code;

    -- Get the hierarchies' information
    SELECT hierarchy_id, hierarchy_name BULK COLLECT
      INTO l_hier_info
      FROM gcs_hierarchies_tl
     WHERE language = userenv('LANG');


    IF l_hier_info.FIRST IS NOT NULL AND l_hier_info.LAST IS NOT NULL THEN
      FOR l_counter IN l_hier_info.FIRST .. l_hier_info.LAST LOOP

        l_base_display_code    := TO_CHAR(l_hier_info(l_counter).hier_id) || ': ' || l_data_type_name;
        l_analyze_display_code := l_hier_info(l_counter).hier_name || ': ' || l_data_type_name;

        fnd_message.set_name('GCS', 'GCS_HIER_NEW_DATASET_DESC');
        fnd_message.set_token('HIER_NAME', l_hier_info(l_counter).hier_name);
        fnd_message.set_token('BAL_TYPE', l_base_balance_type);
        l_base_description := fnd_message.get;
        fnd_message.set_name('GCS', 'GCS_HIER_NEW_DATASET_DESC');
        fnd_message.set_token('HIER_NAME', l_hier_info(l_counter).hier_name);
        fnd_message.set_token('BAL_TYPE', l_analyze_balance_type);
        l_analyze_description := fnd_message.get;

        -- Create a dataset for the base balance type
        FEM_DIMENSION_UTIL_PKG.new_dataset(x_err_code     => l_base_err_code,
                                           x_num_msg      => l_base_num_msg,
                                           p_display_code => l_base_display_code,
                                           p_dataset_name => l_base_display_code,
                                           p_bal_type_cd  => l_fem_balance_type,
                                           p_source_cd    => 70,
                                           p_budget_id    => l_budget_id,
                                           p_enc_type_id  => l_encumbrance_type_id,
                                           p_ver_name     => 'Default',
                                           p_ver_disp_cd  => 'Default',
                                           p_dataset_desc => l_base_description);
        SELECT dataset_code
          INTO l_base_ds_code
          FROM fem_datasets_tl
         WHERE language = userenv('LANG')
           AND dataset_name = l_base_display_code;

        --  Create a row in gcs_dataset_codes for the hierarchy, balance type, and new
        --  dataset for the base balance types and datasets
        INSERT INTO gcs_dataset_codes
          (hierarchy_id,
           balance_type_code,
           dataset_code,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login)
        VALUES
          (l_hier_info(l_counter).hier_id,
           l_base_balance_type,
           l_base_ds_code,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id);

        -- Create a dataset for the analyze balance type
        FEM_DIMENSION_UTIL_PKG.new_dataset(x_err_code     => l_analyze_err_code,
                                           x_num_msg      => l_analyze_num_msg,
                                           p_display_code => l_analyze_display_code,
                                           p_dataset_name => l_analyze_display_code,
                                           p_bal_type_cd  => l_fem_balance_type,
                                           p_source_cd    => 70,
                                           p_budget_id    => l_budget_id,
                                           p_enc_type_id  => l_encumbrance_type_id,
                                           p_ver_name     => 'Default',
                                           p_ver_disp_cd  => 'Default',
                                           p_dataset_desc => l_analyze_description);
        SELECT dataset_code
          INTO l_analyze_ds_code
          FROM fem_datasets_tl
         WHERE language = userenv('LANG')
           AND dataset_name = l_analyze_display_code;

        --  Create a row in gcs_dataset_codes for the hierarchy, balance type, and new
        --  dataset for analyze balance types and datasets
        INSERT INTO gcs_dataset_codes
          (hierarchy_id,
           balance_type_code,
           dataset_code,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login)
        VALUES
          (l_hier_info(l_counter).hier_id,
           l_analyze_balance_type,
           l_analyze_ds_code,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id);
      END LOOP;
    END IF;
  END Update_Hierarchies_Datatype;

  --
  -- Procedure
  --   Handle_Datatypes
  -- Purpose
  --   .
  -- Arguments
  --   p_hier_id               Hierarchy identifier
  -- Example
  --   GCS_HIERARCHIES_PKG.Handle_Datatypes(123 );
  -- Notes
  --
  PROCEDURE Handle_Datatypes(p_hierarchy_id NUMBER) IS
    TYPE data_type_info_rec_type IS RECORD(
      data_type_code      VARCHAR2(30),
      data_type_name      VARCHAR2(30),
      source_dataset_code NUMBER,
      fem_balance_type    VARCHAR2(30));
    TYPE t_data_type_info IS TABLE OF data_type_info_rec_type;
    l_data_type_info       t_data_type_info;
    l_data_type_name       VARCHAR2(30);
    l_fem_balance_type     VARCHAR2(30);
    l_dataset_code         NUMBER;
    l_budget_id            NUMBER := NULL;
    l_encumbrance_type_id  NUMBER := NULL;
    l_base_balance_type    VARCHAR2(30);
    l_analyze_balance_type VARCHAR2(30);
    l_base_display_code    VARCHAR2(1000);
    l_analyze_display_code VARCHAR2(1000);
    l_base_description     VARCHAR2(1000);
    l_analyze_description  VARCHAR2(1000);
    l_base_ds_code         NUMBER;
    l_analyze_ds_code      NUMBER;
    l_base_err_code        NUMBER;
    l_base_num_msg         NUMBER;
    l_analyze_err_code     NUMBER;
    l_analyze_num_msg      NUMBER;
    l_counter              NUMBER;
    l_hierarchy_name       VARCHAR2(150);
  BEGIN

    SELECT hierarchy_name
      INTO l_hierarchy_name
      FROM gcs_hierarchies_tl
     WHERE language = userenv('LANG')
       AND hierarchy_id = p_hierarchy_id;

    -- Get Source Data Set's FEM Balance type code for the given data type code.
    SELECT gdtcb.data_type_code,
           gdtctl.data_type_name,
           gdtcb.source_dataset_code,
           fda.dim_attribute_varchar_member BULK COLLECT
      INTO l_data_type_info
      FROM gcs_data_type_codes_b   gdtcb,
           gcs_data_type_codes_tl  gdtctl,
           fem_dim_attributes_b    fdab,
           fem_dim_attr_versions_b fdavb,
           fem_datasets_attr       fda
     WHERE gdtcb.source_dataset_code = fda.dataset_code
       AND gdtcb.data_type_id = gdtctl.data_type_id
       AND gdtctl.language = userenv('LANG')
       AND fda.attribute_id = fdab.attribute_id
       AND fdab.attribute_id = fdavb.attribute_id
       AND fda.version_id = fdavb.version_id
       AND fdavb.default_version_flag = 'Y'
       AND fda.attribute_id = gcs_utility_pkg.get_dimension_attribute('DATASET_CODE-DATASET_BALANCE_TYPE_CODE');

    IF l_data_type_info.FIRST IS NOT NULL AND
       l_data_type_info.LAST IS NOT NULL THEN
      FOR l_counter IN l_data_type_info.FIRST .. l_data_type_info.LAST LOOP
        l_budget_id            := NULL;
    	l_encumbrance_type_id  := NULL;
        l_data_type_name       := l_data_type_info(l_counter).data_type_name;
        l_fem_balance_type     := l_data_type_info(l_counter).fem_balance_type;
        l_dataset_code         := l_data_type_info(l_counter).source_dataset_code;
        l_base_balance_type    := l_data_type_info(l_counter).data_type_code;
        l_analyze_balance_type := 'ANALYZE_' || l_base_balance_type;

        l_base_display_code    := TO_CHAR(p_hierarchy_id) || ': ' || l_data_type_name;
        l_analyze_display_code := l_hierarchy_name || ': ' || l_data_type_name;

        -- If the source dataset is a budget or encumbrance, get the budget or encumbrance type id of the source dataset
        IF l_fem_balance_type = 'BUDGET' THEN
          SELECT fda.dim_attribute_numeric_member
            INTO l_budget_id
            FROM fem_datasets_attr       fda,
                 fem_dim_attributes_b    fdab,
                 fem_dim_attr_versions_b fdavb
           WHERE fda.attribute_id  = fdab.attribute_id
             AND fdab.attribute_id = fdavb.attribute_id
             AND fda.version_id    = fdavb.version_id
             AND fdavb.default_version_flag = 'Y'
             AND fda.attribute_id = gcs_utility_pkg.get_dimension_attribute('DATASET_CODE-BUDGET_ID')
             AND fda.dataset_code = l_dataset_code;
        END IF;

        IF l_fem_balance_type = 'ENCUMBRANCE' THEN
          SELECT fda.dim_attribute_numeric_member
            INTO l_encumbrance_type_id
            FROM fem_datasets_attr       fda,
                 fem_dim_attributes_b    fdab,
                 fem_dim_attr_versions_b fdavb
           WHERE fda.attribute_id  = fdab.attribute_id
             AND fdab.attribute_id = fdavb.attribute_id
             AND fda.version_id    = fdavb.version_id
             AND fdavb.default_version_flag = 'Y'
             AND fda.attribute_id = gcs_utility_pkg.get_dimension_attribute('DATASET_CODE-ENCUMBRANCE_TYPE_ID')
             AND fda.dataset_code = l_dataset_code;
        END IF;

        fnd_message.set_name('GCS', 'GCS_HIER_NEW_DATASET_DESC');
        fnd_message.set_token('HIER_NAME', l_hierarchy_name);
        fnd_message.set_token('BAL_TYPE', l_base_balance_type);
        l_base_description := fnd_message.get;
        fnd_message.set_name('GCS', 'GCS_HIER_NEW_DATASET_DESC');
        fnd_message.set_token('HIER_NAME', l_hierarchy_name);
        fnd_message.set_token('BAL_TYPE', l_analyze_balance_type);
        l_analyze_description := fnd_message.get;

        -- Create a dataset for the base balance type
        FEM_DIMENSION_UTIL_PKG.new_dataset(x_err_code     => l_base_err_code,
                                           x_num_msg      => l_base_num_msg,
                                           p_display_code => l_base_display_code,
                                           p_dataset_name => l_base_display_code,
                                           p_bal_type_cd  => l_fem_balance_type,
                                           p_source_cd    => 70,
                                           p_budget_id    => l_budget_id,
                                           p_enc_type_id  => l_encumbrance_type_id,
                                           p_ver_name     => 'Default',
                                           p_ver_disp_cd  => 'Default',
                                           p_dataset_desc => l_base_description);
        SELECT dataset_code
          INTO l_base_ds_code
          FROM fem_datasets_tl
         WHERE language = userenv('LANG')
           AND dataset_name = l_base_display_code;

        --  Create a row in gcs_dataset_codes for the hierarchy, balance type, and new
        --  dataset for the base balance types and datasets
        INSERT INTO gcs_dataset_codes
          (hierarchy_id,
           balance_type_code,
           dataset_code,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login)
        VALUES
          (p_hierarchy_id,
           l_base_balance_type,
           l_base_ds_code,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id);

        -- Create a dataset for the analyze balance type
        FEM_DIMENSION_UTIL_PKG.new_dataset(x_err_code     => l_analyze_err_code,
                                           x_num_msg      => l_analyze_num_msg,
                                           p_display_code => l_analyze_display_code,
                                           p_dataset_name => l_analyze_display_code,
                                           p_bal_type_cd  => l_fem_balance_type,
                                           p_source_cd    => 70,
                                           p_budget_id    => l_budget_id,
                                           p_enc_type_id  => l_encumbrance_type_id,
                                           p_ver_name     => 'Default',
                                           p_ver_disp_cd  => 'Default',
                                           p_dataset_desc => l_analyze_description);
        SELECT dataset_code
          INTO l_analyze_ds_code
          FROM fem_datasets_tl
         WHERE language = userenv('LANG')
           AND dataset_name = l_analyze_display_code;

        --  Create a row in gcs_dataset_codes for the hierarchy, balance type, and new
        --  dataset for analyze balance types and datasets
        INSERT INTO gcs_dataset_codes
          (hierarchy_id,
           balance_type_code,
           dataset_code,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login)
        VALUES
          (p_hierarchy_id,
           l_analyze_balance_type,
           l_analyze_ds_code,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id);
      END LOOP;
    END IF;
  END Handle_Datatypes;

  --
  -- Procedure
  --   Handle_Datasets_Ledger
  -- Purpose
  --   Updates the Dataset name/desc and Ledger Name/Desc when Hierarchy Name is changed.
  -- Arguments
  --   p_hier_id               Hierarchy identifier
  -- Example
  --   GCS_HIERARCHIES_PKG.Handle_Datasets_Ledger(hierarchyId );
  -- Notes
  --
  PROCEDURE Handle_Datasets_Ledger(p_hierarchy_id NUMBER) IS
    TYPE dataset_info_rec_type IS RECORD(balance_type_code VARCHAR2(30),
                                         dataset_code      NUMBER,
                                         data_type_name    VARCHAR2(30));
    TYPE t_dataset_info IS TABLE OF dataset_info_rec_type;
    l_dataset_info         t_dataset_info;
    l_dataset_code         NUMBER;
    l_balance_type         VARCHAR2(150);
    l_data_type_name       VARCHAR2(150);
    l_display_code         VARCHAR2(150);
    l_description          VARCHAR2(255);
    l_counter              NUMBER;
    l_hierarchy_name       VARCHAR2(150);
    l_ledger_id            NUMBER;
    l_ledger_name          VARCHAR2(150);
    l_ledger_desc          VARCHAR2(255);
  BEGIN

    SELECT tl.hierarchy_name,
           b.fem_ledger_id
      INTO l_hierarchy_name,l_ledger_id
      FROM gcs_hierarchies_b b,
           gcs_hierarchies_tl tl
     WHERE b.hierarchy_id = tl.hierarchy_id
       AND tl.hierarchy_id = p_hierarchy_id
       AND tl.language = userenv('LANG');


    SELECT gdc.balance_type_code,
           gdc.dataset_code,
           gtl.data_type_name BULK COLLECT
      INTO l_dataset_info
      FROM gcs_dataset_codes gdc,
           gcs_data_type_codes_b gtb,
           gcs_data_type_codes_tl gtl
     WHERE gdc.hierarchy_id = p_hierarchy_id
       AND INSTR(gdc.balance_type_code,gtb.data_type_code) > 0
       AND gtb.data_type_id = gtl.data_type_id
       AND gtl.language = userenv('LANG');

      -- Update fem_datasets_b/tl tables accordingly by setting proper Dataset Name and Description
      IF l_dataset_info.FIRST IS NOT NULL AND l_dataset_info.LAST IS NOT NULL THEN
        FOR l_counter IN l_dataset_info.FIRST .. l_dataset_info.LAST LOOP

          l_balance_type         := l_dataset_info(l_counter).balance_type_code;
          l_dataset_code         := l_dataset_info(l_counter).dataset_code;
          l_data_type_name       := l_dataset_info(l_counter).data_type_name;

          IF INSTR(l_balance_type, 'ANALYZE_') = 1 THEN
                l_display_code := l_hierarchy_name || ': ' || l_data_type_name;
          ELSE
                l_display_code := TO_CHAR(p_hierarchy_id) || ': ' || l_data_type_name;
          END IF;

          fnd_message.set_name('GCS', 'GCS_HIER_NEW_DATASET_DESC');
          fnd_message.set_token('HIER_NAME', l_hierarchy_name);
          fnd_message.set_token('BAL_TYPE', l_balance_type);
          l_description := fnd_message.get;

          UPDATE fem_datasets_b
             SET dataset_display_code = l_display_code
           WHERE dataset_code = l_dataset_code;

          UPDATE fem_datasets_tl
          SET dataset_name = l_display_code,
              description = l_description
          WHERE dataset_code = l_dataset_code
          AND language = userenv('LANG');
        END LOOP;
      END IF;

      -- Update the fem_ledgers_b/tl tables accordingly by setting proper Ledger Name and Description

          fnd_message.set_name('GCS', 'GCS_HIER_NEW_LEDGER_NAME');
          fnd_message.set_token('HIER_NAME', l_hierarchy_name);
          l_ledger_name := fnd_message.get;

          fnd_message.set_name('GCS', 'GCS_HIER_NEW_LEDGER_DESC');
          fnd_message.set_token('HIER_NAME', l_hierarchy_name);
          l_ledger_desc := fnd_message.get;

          UPDATE fem_ledgers_b
             SET ledger_display_code = l_ledger_name
           WHERE ledger_id = l_ledger_id;

          UPDATE fem_ledgers_tl
          SET ledger_name = l_ledger_name,
              description = l_ledger_desc
          WHERE ledger_id = l_ledger_id
          AND language = userenv('LANG');

  END Handle_Datasets_Ledger;

END GCS_HIERARCHIES_PKG;

/
