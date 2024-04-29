--------------------------------------------------------
--  DDL for Package Body GCS_DIMENSION_SET_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DIMENSION_SET_LINES_PKG" AS
/* $Header: gcsdmslb.pls 120.1 2005/10/30 05:17:31 appldev noship $ */

  --
  -- PRIVATE GLOBAL VARIABLES
  --
  g_api    VARCHAR2(40) := 'gcs.plsql.GCS_DIMENSION_SET_LINES_PKG';

  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE Assign_Dimension_Combinations(
    p_errbuf           OUT NOCOPY VARCHAR2,
    p_retcode          OUT NOCOPY VARCHAR2,
    p_dimension_set_id NUMBER)
  IS
    fn_name       VARCHAR2(30) := 'ASSIGN_DIMENSION_COMBINATIONS';

    l_dimension_set_type VARCHAR2(30);
    l_col_name           VARCHAR2(30);
    l_num_of_dimensions  NUMBER;

    stmt          VARCHAR2(5000);
    insert_clause VARCHAR2(1500);
    select_clause VARCHAR2(600);
    from_clause   VARCHAR2(700);
    where_clause  VARCHAR2(2000);

    CURSOR src_tgt_dims IS
      SELECT column_name
      FROM   gcs_dimension_set_dims
      WHERE  dimension_set_id = p_dimension_set_id
      ORDER BY column_name;
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
                      fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- In case of an error, roll back to this point
    SAVEPOINT gcs_dms_line_assign_start;

    -- Initialization
    g_fnd_user_id  := fnd_global.user_id;
    g_fnd_login_id := fnd_global.login_id;

    SELECT set_type_code
    INTO   l_dimension_set_type
    FROM   GCS_DIMENSION_SETS_B
    WHERE  dimension_set_id = p_dimension_set_id;

    l_num_of_dimensions := 0;
    insert_clause := '';
    select_clause := '';
    from_clause   := '';
    where_clause  := '';

    -- build the statement parts
    IF (l_dimension_set_type = 'TARGET_ONLY') THEN
      GCS_UTILITY_PKG.init_dimension_info;
      l_col_name := GCS_UTILITY_PKG.g_gcs_dimension_info.FIRST;
    ELSE
      OPEN src_tgt_dims;
      FETCH src_tgt_dims INTO l_col_name;
    END IF;

    LOOP
      EXIT WHEN (l_col_name IS NULL);

      -- if getting from g_gcs_dimension_info, skip these dimensions
      IF (l_col_name IN ('COMPANY_COST_CENTER_ORG_ID',
                         'ENTITY_ID',
                         'INTERCOMPANY_ID')) THEN
        GOTO next_dim;
      END IF;

      l_num_of_dimensions := l_num_of_dimensions + 1;

      insert_clause := insert_clause || '
    SRC_' || l_col_name || ',
    TGT_' || l_col_name || ',';

      select_clause := select_clause || '
    grp' || l_num_of_dimensions || '.source_member_id,
    grp' || l_num_of_dimensions || '.target_member_id,';

      from_clause := from_clause || ',
    GCS_DIMENSION_SET_GRPS grp' || l_num_of_dimensions;

      where_clause := where_clause || '
AND   grp' || l_num_of_dimensions || '.dimension_set_id = ds.dimension_set_id
AND   grp' || l_num_of_dimensions || '.column_name = ''' ||
        l_col_name || '''';

      <<next_dim>>
      IF (l_dimension_set_type = 'TARGET_ONLY') THEN
        l_col_name := GCS_UTILITY_PKG.g_gcs_dimension_info.NEXT(l_col_name);
      ELSE
        FETCH src_tgt_dims INTO l_col_name;
        EXIT WHEN (src_tgt_dims%NOTFOUND);
      END IF;
    END LOOP;

    IF (l_dimension_set_type = 'SOURCE_TARGET') THEN
      CLOSE src_tgt_dims;
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.' || fn_name,
                     'Dimension Set Id ' || to_char(p_dimension_set_id) || ': '
                     || to_char(l_num_of_dimensions) || ' dimension(s)');
    END IF;

    -- Delete existing assignments
    DELETE FROM GCS_DIMENSION_SET_LINES
    WHERE  dimension_set_id = p_dimension_set_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.' || fn_name,
                     'Deleted ' || to_char(SQL%ROWCOUNT) || ' row(s)');
    END IF;

    IF (l_num_of_dimensions <= 0) THEN
      -- no dimensions assigned to the dimension set, exit directly
      GOTO prog_exit;
    END IF;

    -- build the insert statement
    stmt :=
'INSERT INTO GCS_DIMENSION_SET_LINES
   (dimension_set_id,' ||
    insert_clause || '
    creation_date, created_by,
    last_update_date, last_updated_by,
    last_update_login)
SELECT
    :dim_set_id,' ||
    select_clause || '
    sysdate, :user_id,
    sysdate, :user_id,
    :login_id
FROM
    GCS_DIMENSION_SETS_B ds' ||
    from_clause || '
WHERE ds.dimension_set_id = :dim_set_id' ||
    where_clause;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.' || fn_name,
                     stmt);
    END IF;

    -- Insert new assignments
    EXECUTE IMMEDIATE stmt USING p_dimension_set_id,
                                 g_fnd_user_id,
                                 g_fnd_user_id,
                                 g_fnd_login_id,
                                 p_dimension_set_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.' || fn_name,
                     'Inserted ' || to_char(SQL%ROWCOUNT) || ' row(s)');
    END IF;

    <<prog_exit>>
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_success || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
                      fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_api || '.' || fn_name,
                       SUBSTR(SQLERRM, 1, 4000));
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
                        fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

      ROLLBACK TO gcs_dms_line_assign_start;
      p_errbuf := 'GCS_DMSL_UNHANDLED_EXCEPTION';
      p_retcode := '2';
  END Assign_Dimension_Combinations;

END GCS_DIMENSION_SET_LINES_PKG;

/
