--------------------------------------------------------
--  DDL for Package Body FEM_INTG_CAL_RULE_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_INTG_CAL_RULE_ENG_PKG" AS
/* $Header: fem_intg_cal_eng.plb 120.15 2008/04/01 06:59:28 rguerrer ship $ */

  --
  -- Package variables
  --
  pv_folder_id                  NUMBER;
  pv_cal_rule_obj_id            NUMBER;
  pv_cal_rule_obj_def_id        NUMBER;

  pv_req_id                     NUMBER;
  pv_user_id                    NUMBER;
  pv_resp_id                    NUMBER;
  pv_login_id                   NUMBER;
  pv_pgm_id                     NUMBER;
  pv_pgm_app_id                 NUMBER;

  pv_effective_start_date       DATE;
  pv_effective_end_date         DATE;

  pv_period_set_name            VARCHAR2(15);
  pv_period_type                VARCHAR2(15);
  pv_period_type_name           VARCHAR2(15);
  pv_period_year                NUMBER;

  pv_effective_period_num_low   NUMBER;
  pv_effective_period_num_high  NUMBER;

  pv_ogl_period_type_code       VARCHAR(50);
  pv_ogl_period_type_name       VARCHAR(50);
  pv_ogl_period_type_desc       VARCHAR(300);
  pv_ogl_number_per_fiscal_year NUMBER;

  pv_cal_per_hier_obj_id        NUMBER;
  pv_cal_per_hier_obj_def_id    NUMBER;
  pv_dimension_grp_id_period    NUMBER;
  pv_calendar_id                NUMBER;
  pv_effective_period_num_min   NUMBER;
  pv_effective_period_num_max   NUMBER;

  pv_new_periods_to_process     VARCHAR2(1);

  pv_ledger_dim_id              NUMBER;
  pv_calendar_dim_id            NUMBER;
  pv_cal_period_dim_id          NUMBER;
  pv_time_group_type_dim_id     NUMBER;
  pv_dimension_grp_id_quarter   NUMBER;
  pv_dimension_grp_id_year      NUMBER;
  pv_source_system_code         NUMBER;

  pv_row_count_tot              NUMBER;

  pv_completion_status          VARCHAR2(15);
  pv_cal_per_hier_name          VARCHAR2(100);

  --
  -- Constants
  --
  pc_module_name CONSTANT VARCHAR2(100):='fem.plsql.' ||
                                         'fem_intg_cal_rule_eng_pkg.';

  pc_object_version_number  CONSTANT NUMBER      := 1;
  pc_aw_snapshot_flag       CONSTANT VARCHAR2(1) := 'N';
  pc_weighting_pct          CONSTANT NUMBER      := NULL;
  pc_period_date_past       CONSTANT DATE:= TO_DATE('1000/01/01','YYYY/MM/DD');
  pc_period_date_future     CONSTANT DATE:= TO_DATE('3000/01/01','YYYY/MM/DD');
  pc_effective_start_date   CONSTANT DATE:= TO_DATE('1900/01/01','YYYY/MM/DD');
  pc_effective_end_date     CONSTANT DATE:= TO_DATE('2500/01/01','YYYY/MM/DD');

  pc_adjustment_period_flag CONSTANT  VARCHAR2(1) := 'Y';

  pc_object_access_code     CONSTANT VARCHAR2(30) := 'W';
  pc_object_origin_code     CONSTANT VARCHAR2(30) := 'USER';
  pc_grp_seq_code           CONSTANT VARCHAR2(30) := 'SEQUENCE_ENFORCED';
  pc_multi_top_flg          CONSTANT VARCHAR2(1)  := 'Y';

  pc_source_cd              CONSTANT VARCHAR2(15) := 'OGL';
  pc_ver_name               CONSTANT VARCHAR2(15) := 'Default';
  pc_ver_disp_cd            CONSTANT VARCHAR2(15) := 'Default';

  pc_log_level_statement    CONSTANT NUMBER := FND_LOG.level_statement;
  pc_log_level_procedure    CONSTANT NUMBER := FND_LOG.level_procedure;
  pc_log_level_event        CONSTANT NUMBER := FND_LOG.level_event;
  pc_log_level_exception    CONSTANT NUMBER := FND_LOG.level_exception;
  pc_log_level_error        CONSTANT NUMBER := FND_LOG.level_error;
  pc_log_level_unexpected   CONSTANT NUMBER := FND_LOG.level_unexpected;

  pc_success                CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;


  -- ======================================================================
  -- Procedure
  --   Init
  -- Purpose
  --   Initializes package level variables
  -- History
  --   02-02-05  Shintaro Okuda  Created
  -- Arguments
  --   p_cal_rule_obj_def_id  Calendar Rule Object Definition ID
  --   p_period_set_name      Period Set Name
  --   p_period_type          Period Type
  --   p_period_year          Period Year
  -- ======================================================================
  PROCEDURE Init(
    p_cal_rule_obj_def_id IN NUMBER,
    p_period_set_name     IN VARCHAR2,
    p_period_type         IN VARCHAR2,
    p_period_year         IN NUMBER
  ) IS
    FEM_INTG_fatal_err EXCEPTION;

    v_rowcount NUMBER;

    v_nls_date_format      VARCHAR2(50);
    v_effective_start_char VARCHAR2(50);
    v_effective_end_char   VARCHAR2(50);

    v_calendar_id             NUMBER;
    v_dimension_grp_id_period NUMBER;
    v_cal_per_hier_obj_id     NUMBER;

    v_ogl_product_name           VARCHAR2(100);
    v_ogl_number_per_fiscal_year NUMBER;

    v_effective_period_num_min NUMBER;
    v_effective_period_num_max NUMBER;
    v_period_num_min           NUMBER;
    v_period_num_max           NUMBER;

    v_gap_found VARCHAR2(1) := 'N';

  BEGIN

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'init.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Init',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    --
    -- Get a rule related information
    --
    SELECT
      C.FOLDER_ID,
      C.OBJECT_ID,
      D.OBJECT_DEFINITION_ID
    INTO
      pv_folder_id,
      pv_cal_rule_obj_id,
      pv_cal_rule_obj_def_id
    FROM
      FEM_OBJECT_DEFINITION_B D,
      FEM_OBJECT_CATALOG_B C
    WHERE
      D.OBJECT_DEFINITION_ID = p_cal_rule_obj_def_id AND
      C.OBJECT_ID = D.OBJECT_ID AND
      C.OBJECT_TYPE_CODE='OGL_INTG_CAL_RULE';

    --
    -- Initialize Concurrent Program related package variables
    --
    pv_req_id     := NVL(FND_GLOBAL.CONC_REQUEST_ID,-1);
    pv_user_id    := NVL(FND_GLOBAL.USER_ID,'-1');
    pv_resp_id    := NVL(FND_GLOBAL.RESP_ID, '-1');
    pv_login_id   := NVL(FND_GLOBAL.CONC_LOGIN_ID, FND_GLOBAL.LOGIN_ID);
    pv_pgm_id     := NVL(FND_GLOBAL.CONC_PROGRAM_ID,-1);
    pv_pgm_app_id := NVL(FND_GLOBAL.PROG_APPL_ID,-1);

    --
    -- Check user's folder assignment
    --
    -- Note that this check is not applicable for FEM.C
    --
    -- REMOVED CODE

    --
    -- Get effective dates from profile options
    --
    v_effective_start_char := FND_PROFILE.Value_Specific(
                                'FEM_EFFECTIVE_START_DATE',
                                pv_user_id,
                                pv_resp_id,
                                pv_pgm_app_id
                              );
    v_effective_end_char   := FND_PROFILE.Value_Specific(
                                'FEM_EFFECTIVE_END_DATE',
                                pv_user_id,
                                pv_resp_id,
                                pv_pgm_app_id
                              );

    --
    -- Initialize completion status
    --
    pv_completion_status := 'NORMAL';

    /*
      In FEM.C, date format validation is not performed in the Define
      Profile Option value Screen. See bug4141148 for details.

      In FEM.D, date format validation with a hard-coded 'DD-MON-YYYY'
      is performed in the Define Profile Option Value screen.
      See bug4141148 for details.

      In FEM.E, the Effective Date profile options are planned to be
      migrated to regular fields which are validated with ICX_DATE_FORMAT_MASK
      profile option. See bug4378378 for details.

      Effective Date profile options are now stored in the Canonical format.
      See bug 5470448 for details.
    */

    BEGIN
      pv_effective_start_date :=
			  FND_DATE.Canonical_To_Date(v_effective_start_char);
      pv_effective_end_date :=
			  FND_DATE.Canonical_To_Date(v_effective_end_char);
    EXCEPTION
      WHEN OTHERS THEN

        pv_completion_status := 'WARNING';

        pv_effective_start_date := pc_effective_start_date;
        pv_effective_end_date   := pc_effective_end_date;

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_error,
          p_module   => pc_module_name || 'init.invalid_dt_fmt',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_INTG_CAL_INVALID_DT_FMT'
        );
        FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_name => 'FEM_INTG_CAL_INVALID_DT_FMT'
        );
    END;

    --
    -- Check if mandatory parameters are passed
    --
    IF p_cal_rule_obj_def_id IS NULL OR
       p_period_set_name IS NULL OR
       p_period_type IS NULL OR
       p_period_year IS NULL THEN

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_error,
        p_module   => pc_module_name || 'init.cal_para_not_found',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_PARA_MISSING'
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_PARA_MISSING'
      );

      RAISE FEM_INTG_fatal_err;

    ELSE
      pv_period_set_name := p_period_set_name;
      pv_period_type := p_period_type;
      pv_period_year := p_period_year;
    END IF;

    --
    -- Store a year being processed in low and high effective period
    -- range variable for later comparison.
    --
    SELECT MIN(P.PERIOD_NUM), MAX(P.PERIOD_NUM)
    INTO v_period_num_min, v_period_num_max
    FROM GL_PERIODS P
    WHERE P.PERIOD_SET_NAME = pv_period_set_name
    AND   P.PERIOD_TYPE = pv_period_type
    AND   P.PERIOD_YEAR = pv_period_year;

    pv_effective_period_num_low := pv_period_year * 10000 + v_period_num_min;
    pv_effective_period_num_high := pv_period_year * 10000 + v_period_num_max;

    --
    -- Get Period Type attributes
    --
    v_ogl_product_name := FND_MESSAGE.get_string(
                            'FEM',
                            'FEM_INTG_CAL_OGL_PRODUCT_NAME'
                          );
    SELECT
      'OGL_' || T.PERIOD_TYPE,
      v_ogl_product_name || ' ' || T.USER_PERIOD_TYPE,
      v_ogl_product_name || ' ' || T.DESCRIPTION,
      T.NUMBER_PER_FISCAL_YEAR,
      T.USER_PERIOD_TYPE
    INTO
      pv_ogl_period_type_code,
      pv_ogl_period_type_name,
      pv_ogl_period_type_desc,
      pv_ogl_number_per_fiscal_year,
      pv_period_type_name
    FROM
      GL_PERIOD_TYPES T
    WHERE
      T.PERIOD_TYPE = pv_period_type;

    --
    -- Check if Period Year has the expected number of periods
    --
    SELECT COUNT(P.PERIOD_NUM) INTO v_ogl_number_per_fiscal_year
    FROM GL_PERIODS P
    WHERE P.PERIOD_SET_NAME = pv_period_set_name
    AND   P.PERIOD_TYPE = pv_period_type
    AND   P.PERIOD_YEAR = pv_period_year;

    IF v_ogl_number_per_fiscal_year <> pv_ogl_number_per_fiscal_year THEN

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_error,
        p_module   => pc_module_name || 'init.no_new_periods',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_INVALID_NUM_PER_Y',
        p_token1   => 'FISCAL_YEAR',
        p_value1   => pv_period_year
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_INVALID_NUM_PER_Y',
        p_token1   => 'FISCAL_YEAR',
        p_value1   => pv_period_year
      );

      RAISE FEM_INTG_fatal_err;

    END IF;

    --
    -- Get a mapping record for a given Period Set Name and Period Type
    --
    BEGIN
      SELECT
        C.OBJECT_ID,
        M.CAL_PER_HIER_OBJ_DEF_ID,
        M.DIMENSION_GROUP_ID,
        M.CALENDAR_ID,
        M.EFFECTIVE_PERIOD_NUM_MIN,
        M.EFFECTIVE_PERIOD_NUM_MAX
      INTO
        pv_cal_per_hier_obj_id,
        pv_cal_per_hier_obj_def_id,
        pv_dimension_grp_id_period,
        pv_calendar_id,
        pv_effective_period_num_min,
        pv_effective_period_num_max
      FROM
        FEM_INTG_CALENDAR_MAP M,
        FEM_OBJECT_DEFINITION_B D,
        FEM_OBJECT_CATALOG_B C
      WHERE
        M.PERIOD_SET_NAME = p_period_set_name AND
        M.PERIOD_TYPE = p_period_type AND
        D.OBJECT_DEFINITION_ID = M.CAL_PER_HIER_OBJ_DEF_ID AND
        C.OBJECT_ID = D.OBJECT_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        pv_cal_per_hier_obj_id := NULL;
        pv_cal_per_hier_obj_def_id := NULL;
        pv_dimension_grp_id_period := NULL;
        pv_calendar_id := NULL;
        pv_effective_period_num_min := NULL;
        pv_effective_period_num_max := NULL;
    END;

    --
    -- If Calendar ID based on the mapping record turns out to be NULL,
    -- then retrieve it from FEM_CALENDARS_B table based on Period Set Name
    -- instead.
    --
    IF pv_calendar_id IS NULL THEN
      BEGIN
        SELECT CALENDAR_ID
        INTO pv_calendar_id
        FROM FEM_CALENDARS_B
        WHERE CALENDAR_DISPLAY_CODE = p_period_set_name;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          pv_calendar_id := NULL;
      END;
    END IF;

    --
    -- If Time Dimension Group ID based on the mapping record turns out to be
    -- NULL, then retrieve it from FEM_DIMENSION_GRPS_B table based on
    -- Period Type instead.
    --
    IF pv_dimension_grp_id_period IS NULL THEN
      BEGIN
        SELECT DIMENSION_GROUP_ID
        INTO pv_dimension_grp_id_period
        FROM FEM_DIMENSION_GRPS_B
        WHERE TIME_GROUP_TYPE_CODE = pv_ogl_period_type_code;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          pv_dimension_grp_id_period := NULL;
      END;
    END IF;

    --
    -- Check gapless periods
    --
    v_effective_period_num_min := NVL(pv_effective_period_num_min,0);
    v_effective_period_num_max := NVL(pv_effective_period_num_max, 3000*10000);

    IF v_effective_period_num_min - pv_effective_period_num_high > 1 THEN

      IF TRUNC(v_effective_period_num_min/10000) -
         TRUNC(pv_effective_period_num_high/10000) = 1 THEN

        SELECT MIN(P.PERIOD_NUM)
        INTO v_period_num_min
        FROM GL_PERIODS P
        WHERE P.PERIOD_SET_NAME = pv_period_set_name
        AND   P.PERIOD_TYPE = pv_period_type
        AND   P.PERIOD_YEAR = TRUNC(v_effective_period_num_min/10000);

        SELECT MAX(P.PERIOD_NUM)
        INTO v_period_num_max
        FROM GL_PERIODS P
        WHERE P.PERIOD_SET_NAME = pv_period_set_name
        AND   P.PERIOD_TYPE = pv_period_type
        AND   P.PERIOD_YEAR = TRUNC(pv_effective_period_num_high/10000);

        IF v_period_num_min <> MOD(v_effective_period_num_min,10000) OR
           v_period_num_max <> MOD(pv_effective_period_num_high,10000) THEN
          v_gap_found := 'Y';
        END IF;

      ELSE
        v_gap_found := 'Y';
      END IF;
    END IF;

    IF pv_effective_period_num_low - v_effective_period_num_max > 1 THEN

      IF TRUNC(pv_effective_period_num_low/10000) -
         TRUNC(v_effective_period_num_max/10000) = 1 THEN

        SELECT MIN(P.PERIOD_NUM)
        INTO v_period_num_min
        FROM GL_PERIODS P
        WHERE P.PERIOD_SET_NAME = pv_period_set_name
        AND   P.PERIOD_TYPE = pv_period_type
        AND   P.PERIOD_YEAR = TRUNC(pv_effective_period_num_low/10000);

        SELECT MAX(P.PERIOD_NUM)
        INTO v_period_num_max
        FROM GL_PERIODS P
        WHERE P.PERIOD_SET_NAME = pv_period_set_name
        AND   P.PERIOD_TYPE = pv_period_type
        AND   P.PERIOD_YEAR = TRUNC(v_effective_period_num_max/10000);

        IF v_period_num_min <> MOD(pv_effective_period_num_low,10000) OR
           v_period_num_max <> MOD(v_effective_period_num_max,10000) THEN
          v_gap_found := 'Y';
        END IF;

      ELSE
        v_gap_found := 'Y';
      END IF;
    END IF;

    IF v_gap_found = 'Y' THEN
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_error,
        p_module   => pc_module_name || 'init.period_gap_found',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_PERIOD_GAP_FOUND',
        p_token1   => 'FISCAL_YEAR',
        p_value1   => pv_period_year,
        p_token2   => 'PERIOD_SET_NAME',
        p_value2   => pv_period_set_name,
        p_token3   => 'PERIOD_TYPE',
        p_value3   => pv_period_type_name
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_PERIOD_GAP_FOUND',
        p_token1   => 'FISCAL_YEAR',
        p_value1   => pv_period_year,
        p_token2   => 'PERIOD_SET_NAME',
        p_value2   => pv_period_set_name,
        p_token3   => 'PERIOD_TYPE',
        p_value3   => pv_period_type_name
      );

      RAISE FEM_INTG_fatal_err;

    END IF;

    --
    -- Check if there are new periods to process
    --
    IF NVL(pv_effective_period_num_min, 3000*10000) -
         pv_effective_period_num_low > 0 OR
       pv_effective_period_num_high -
         NVL(pv_effective_period_num_max, 0) > 0 THEN

      pv_new_periods_to_process := 'Y';

    ELSE

      pv_new_periods_to_process := 'N';

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_error,
        p_module   => pc_module_name || 'init.no_new_periods',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_NO_NEW_PERIODS'
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_NO_NEW_PERIODS'
      );
    END IF;

    --
    -- Check if a Calendar ID already exists for a given Period Set Name.
    -- If Calendar ID is obtained from the mapping record, there is a chance
    -- that it may not be a valid one.
    --
    BEGIN
      SELECT CALENDAR_ID
      INTO v_calendar_id
      FROM FEM_CALENDARS_B
      WHERE CALENDAR_DISPLAY_CODE = pv_period_set_name;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_calendar_id := NULL;
    END;

    --
    -- Check if a Time Dimension Group ID exists for a given Period Type.
    -- If Time Dimension Group ID is obtained from the mapping record,
    -- there is a chance that it may not be a valid one.
    --
    BEGIN
      SELECT G.DIMENSION_GROUP_ID
      INTO v_dimension_grp_id_period
      FROM
        FEM_DIMENSION_GRPS_B G
      WHERE
        G.DIMENSION_GROUP_DISPLAY_CODE = pv_ogl_period_type_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_dimension_grp_id_period := NULL;
    END;

    --
    -- Check if a Calendar Period Hierarchy ID already exists
    --
    --dedutta : Bug 4992900 : Changed query to introduce additional filtration
    BEGIN
      SELECT
        h.HIERARCHY_OBJ_ID
      INTO
        v_cal_per_hier_obj_id
      FROM
        FEM_HIERARCHIES h,
        fem_object_catalog_b o
      WHERE
      h.CALENDAR_ID = NVL(v_calendar_id, -1)
      and h.PERIOD_TYPE = pv_period_type
      and h.personal_flag = 'N'
      and h.hierarchy_usage_code = 'STANDARD'
      and h.HIERARCHY_OBJ_ID=o.OBJECT_ID
      and o.folder_id=pv_folder_id ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_cal_per_hier_obj_id := NULL;
    END;

    --
    -- Check if the retrieved mapping record is valid,
    -- i.e.,check if the corresponding Calendar, Time Dimension Group,
    -- and hierarchy also exist. Note that unless the mapping record is
    -- tampered, this check should not fail.
    --
    IF pv_cal_per_hier_obj_def_id IS NOT NULL AND (
       NVL(v_calendar_id, -1) <> NVL(pv_calendar_id, -1) OR
       NVL(v_dimension_grp_id_period,-1)<>NVL(pv_dimension_grp_id_period,-1) OR
       NVL(v_cal_per_hier_obj_id, -1) <> NVL(pv_cal_per_hier_obj_id, -1)) THEN

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_error,
        p_module   => pc_module_name || 'init.invalid_cal_map',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_INVALID_CAL_MAP',
        p_token1   => 'PERIOD_SET_NAME',
        p_value1   => pv_period_set_name,
        p_token2   => 'PERIOD_TYPE',
        p_value2   => pv_period_type_name
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_INVALID_CAL_MAP',
        p_token1   => 'PERIOD_SET_NAME',
        p_value1   => pv_period_set_name,
        p_token2   => 'PERIOD_TYPE',
        p_value2   => pv_period_type_name
      );

      --
      -- Delete an invalid mapping record. The next run will create missing
      -- Calendar, Time Dimension Group, and/or hierarchy and will create a
      -- valid mapping record.
      --
      DELETE FROM FEM_INTG_CALENDAR_MAP
      WHERE CAL_PER_HIER_OBJ_DEF_ID = pv_cal_per_hier_obj_def_id;

      COMMIT;

      RAISE FEM_INTG_fatal_err;

    END IF;

    --
    -- Initialize other package level variables
    --
    SELECT DIMENSION_ID
    INTO pv_ledger_dim_id
    FROM FEM_DIMENSIONS_B
    WHERE DIMENSION_VARCHAR_LABEL = 'LEDGER';

    SELECT DIMENSION_ID
    INTO pv_calendar_dim_id
    FROM FEM_DIMENSIONS_B
    WHERE DIMENSION_VARCHAR_LABEL = 'CALENDAR';

    SELECT DIMENSION_ID
    INTO pv_cal_period_dim_id
    FROM FEM_DIMENSIONS_B
    WHERE DIMENSION_VARCHAR_LABEL = 'CAL_PERIOD';

    SELECT DIMENSION_ID
    INTO pv_time_group_type_dim_id
    FROM FEM_DIMENSIONS_B
    WHERE DIMENSION_VARCHAR_LABEL = 'TIME_GROUP_TYPE';

    SELECT DIMENSION_GROUP_ID
    INTO pv_dimension_grp_id_year
    FROM FEM_DIMENSION_GRPS_B
    WHERE DIMENSION_GROUP_DISPLAY_CODE = 'Year';

    SELECT DIMENSION_GROUP_ID
    INTO pv_dimension_grp_id_quarter
    FROM FEM_DIMENSION_GRPS_B
    WHERE DIMENSION_GROUP_DISPLAY_CODE = 'Quarter';

    SELECT SOURCE_SYSTEM_CODE
    INTO pv_source_system_code
    FROM FEM_SOURCE_SYSTEMS_B
    WHERE SOURCE_SYSTEM_DISPLAY_CODE = 'OGL';

    pv_row_count_tot := 0;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'init.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Init',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  EXCEPTION
    WHEN FEM_INTG_fatal_err THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'init.exception_fatal_err',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Init',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RAISE;

    WHEN OTHERS THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'init.exception_others' ,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'init.exception_others',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Init',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RAISE;

  END Init;


  -- ======================================================================
  -- Procedure
  --   New_Calendar
  -- Purpose
  --   Creates a new Calendar
  -- History
  --   02-02-05  Shintaro Okuda  Created
  -- Arguments
  --   None
  -- ======================================================================
  PROCEDURE New_Calendar
  IS
    FEM_INTG_fatal_err EXCEPTION;

    v_return_status VARCHAR2(1);
    v_msg_count     NUMBER;
    v_msg_data      VARCHAR2(2000);
  BEGIN

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'new_calendar.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.New_Calendar',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    --
    -- Note that pc_source_cd is used for FEM.C and
    -- pv_source_system_code is used for FEM.D and above.
    --
    FEM_DIM_CAL_UTIL_PKG.New_Calendar (
      x_return_status       => v_return_status,
      x_msg_count           => v_msg_count,
      x_msg_data            => v_msg_data,
      x_calendar_id         => pv_calendar_id,
      p_cal_disp_code       => pv_period_set_name,
      p_calendar_name       => pv_period_set_name,
      p_source_cd           => pv_source_system_code,
      p_period_set_name     => pv_period_set_name,
      p_ver_name            => pc_ver_name,
      p_ver_disp_cd         => pc_ver_disp_cd,
      p_calendar_desc       => pv_period_set_name,
      p_include_adj_per_flg => pc_adjustment_period_flag
    );

    IF v_return_status <> pc_success THEN

      FOR i IN 1 .. v_msg_count LOOP
        v_msg_data := FND_MSG_PUB.Get(
                        p_msg_index => i,
                        p_encoded => 'F'
                      );

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_error,
          p_module   => pc_module_name || 'new_calendar_error',
          p_app_name => 'FEM',
          p_msg_text => v_msg_data
        );
      END LOOP;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_error,
        p_module   => pc_module_name || 'new_calendar_error',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_NEW_CAL_ERROR',
        p_token1   => 'CALENDAR_DIMENSION',
        p_value1   => pv_period_set_name
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_NEW_CAL_ERROR',
        p_token1   => 'CALENDAR_DIMENSION',
        p_value1   => pv_period_set_name
      );

      RAISE FEM_INTG_fatal_err;

    END IF;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'new_calendar.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.New_Calendar',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  EXCEPTION
    WHEN FEM_INTG_fatal_err THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'new_calendar.exception_fatal_err',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.New_Calendar',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RAISE;

    WHEN OTHERS THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'new_calendar.exception_others' ,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'new_calendar.exception_others',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.New_Calendar',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RAISE;

  END New_Calendar;


  -- ======================================================================
  -- Procedure
  --   New_Time_Dimension_Group
  -- Purpose
  --   Creates a new Time Group Type and a new Time Dimension Group
  -- History
  --   02-02-05  Shintaro Okuda  Created
  -- Arguments
  --   None
  -- ======================================================================
  PROCEDURE New_Time_Dimension_Group
  IS
    FEM_INTG_fatal_err EXCEPTION;

    v_return_status VARCHAR2(1);
    v_msg_count     NUMBER;
    v_msg_data      VARCHAR2(2000);

    v_time_group_type_code VARCHAR2(30):= NULL;
  BEGIN

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'new_time_dimension_group.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.New_Time_Dimension_Group',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    --
    -- Check the existence of Time Group Type Code
    --
    BEGIN
      SELECT TIME_GROUP_TYPE_CODE
      INTO v_time_group_type_code
      FROM FEM_TIME_GROUP_TYPES_B
      WHERE TIME_GROUP_TYPE_CODE = pv_ogl_period_type_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => pc_module_name || 'new_time_group_type_create_new',
          p_app_name => 'FEM',
          p_msg_text => 'Creating a new Time Group Type Code.'
        );
    END;

    IF v_time_group_type_code IS NULL THEN

      FEM_DIM_CAL_UTIL_PKG.New_Time_Group_Type(
        x_return_status      => v_return_status,
        x_msg_count          => v_msg_count,
        x_msg_data           => v_msg_data,
        p_time_grp_type_code => pv_ogl_period_type_code,
        p_time_grp_type_name => pv_ogl_period_type_name,
        p_time_grp_type_desc => pv_ogl_period_type_desc,
        p_periods_in_year    => pv_ogl_number_per_fiscal_year,
        p_ver_name           => pc_ver_name,
        p_ver_disp_cd        => pc_ver_disp_cd,
        p_read_only_flag     => 'Y'
      );

      IF v_return_status <> pc_success THEN

        FOR i IN 1 .. v_msg_count LOOP

          v_msg_data := FND_MSG_PUB.Get(
                          p_msg_index => i,
                          p_encoded => 'F'
                        );
          FEM_ENGINES_PKG.Tech_Message(
            p_severity => pc_log_level_error,
            p_module   => pc_module_name || 'new_time_group_type_error',
            p_app_name => 'FEM',
            p_msg_text => v_msg_data
          );

        END LOOP;

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_error,
          p_module   => pc_module_name || 'new_time_group_type_error',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_INTG_CAL_NEW_TGT_ERROR',
          p_token1   => 'TIME_GROUP_TYPE',
          p_value1   => pv_ogl_period_type_name
        );

        FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_name => 'FEM_INTG_CAL_NEW_TGT_ERROR',
          p_token1   => 'TIME_GROUP_TYPE',
          p_value1   => pv_ogl_period_type_name
        );

        RAISE FEM_INTG_fatal_err;

      END IF;

    END IF;

    IF pv_dimension_grp_id_period IS NULL THEN

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => pc_module_name || 'new_time_dimension_group_create_new',
        p_app_name => 'FEM',
        p_msg_text => 'Creating a new Time Dimension Group.'
      );

      FEM_DIM_CAL_UTIL_PKG.New_Time_Dimension_Group(
        x_return_status      => v_return_status,
        x_msg_count          => v_msg_count,
        x_msg_data           => v_msg_data,
        x_dim_grp_id         => pv_dimension_grp_id_period,
        p_time_grp_type_code => pv_ogl_period_type_code,
        p_dim_grp_name       => pv_ogl_period_type_name,
        p_dim_grp_disp_cd    => pv_ogl_period_type_code,
        p_dim_grp_desc       => pv_ogl_period_type_desc,
        p_read_only_flag     => 'Y'
      );

      IF v_return_status <> pc_success THEN

        FOR i IN 1 .. v_msg_count LOOP

          v_msg_data := FND_MSG_PUB.Get(
                          p_msg_index => i,
                          p_encoded => 'F'
                        );
          FEM_ENGINES_PKG.Tech_Message(
            p_severity => pc_log_level_error,
            p_module   => pc_module_name || 'new_time_dimension_group_error',
            p_app_name => 'FEM',
            p_msg_text => v_msg_data
           );
        END LOOP;


        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_error,
          p_module   => pc_module_name || 'new_time_dimension_group_error',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_INTG_CAL_NEW_TDG_ERROR',
          p_token1   => 'TIME_DIMENSION_GROUP',
          p_value1   => pv_ogl_period_type_name
        );

        FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_name => 'FEM_INTG_CAL_NEW_TDG_ERROR',
          p_token1   => 'TIME_DIMENSION_GROUP',
          p_value1   => pv_ogl_period_type_name
        );

        RAISE FEM_INTG_fatal_err;

      END IF;

    END IF;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'new_time_dimension_group.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.New_Time_Dimension_Group',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  EXCEPTION
    WHEN FEM_INTG_fatal_err THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'new_time_dimension_group.exception_fatal_err',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.New_Time_Dimension_Group',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RAISE;

    WHEN OTHERS THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'new_time_dimension_group.exception_others' ,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'new_time_dimension_group.exception_others',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.New_Time_Dimension_Group',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RAISE;

  End New_Time_Dimension_Group;


  -- ======================================================================
  -- Procedure
  --   New_GL_Cal_Period_Hier
  -- Purpose
  --   Create a new GL Calendar Period Hierarchy
  -- History
  --   02-02-05  Shintaro Okuda  Created
  -- Arguments
  --   None
  -- ======================================================================
  PROCEDURE New_GL_Cal_Period_Hier
  IS
    FEM_INTG_fatal_err EXCEPTION;

    v_object_name VARCHAR2(200);

    v_return_status VARCHAR2(1);
    v_msg_count     NUMBER;
    v_msg_data      VARCHAR2(2000);
  BEGIN

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'new_gl_cal_period_hier.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.New_GL_Cal_Peroid_Hier',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    --
    -- Define a new hierarchy
    --
    v_object_name := pv_period_set_name || '-' || pv_period_type_name;

    FEM_DIM_HIER_UTIL_PKG.New_GL_Cal_Period_Hier(
      x_return_status        => v_return_status,
      x_msg_count            => v_msg_count,
      x_msg_data             => v_msg_data,
      x_hier_obj_id          => pv_cal_per_hier_obj_id,
      x_hier_obj_def_id      => pv_cal_per_hier_obj_def_id,
      p_folder_id            => pv_folder_id,
      p_object_access_code   => pc_object_access_code,
      p_object_origin_code   => pc_object_origin_code,
      p_object_name          => v_object_name,
      p_description          => v_object_name,
      p_effective_start_date => pv_effective_start_date,
      p_effective_end_date   => pv_effective_end_date,
      p_obj_def_name         => v_object_name,
      p_grp_seq_code         => pc_grp_seq_code,
      p_multi_top_flg        => pc_multi_top_flg,
      p_gl_period_type       => pv_period_type,
      p_dim_grp_id           => pv_dimension_grp_id_period,
      p_calendar_id          => pv_calendar_id
    );

    IF v_return_status <> pc_success THEN

      FOR i IN 1 .. v_msg_count LOOP
        v_msg_data := FND_MSG_PUB.Get(
                        p_msg_index => i,
                        p_encoded => 'F'
                      );

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_error,
          p_module   => pc_module_name || 'new_gl_cal_period_hier_error',
          p_app_name => 'FEM',
          p_msg_text => v_msg_data
        );
      END LOOP;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_error,
        p_module   => pc_module_name || 'new_gl_cal_period_hier_error',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_NEW_HIER_ERROR',
        p_token1   => 'TIME_DIMENSION_HIER_OBJ',
        p_value1   => v_object_name
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_CAL_NEW_HIER_ERROR',
        p_token1   => 'TIME_DIMENSION_HIER_OBJ',
        p_value1   => v_object_name
      );

      RAISE FEM_INTG_fatal_err;
    END IF;

    --
    -- Create a mapping record
    --
    INSERT INTO FEM_INTG_CALENDAR_MAP(
      PERIOD_SET_NAME,
      PERIOD_TYPE,
      CAL_PER_HIER_OBJ_DEF_ID,
      DIMENSION_GROUP_ID,
      CALENDAR_ID,
      EFFECTIVE_PERIOD_NUM_MIN,
      EFFECTIVE_PERIOD_NUM_MAX,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
    ) VALUES (
      pv_period_set_name,
      pv_period_type,
      pv_cal_per_hier_obj_def_id,
      pv_dimension_grp_id_period,
      pv_calendar_id,
      NULL,
      NULL,
      SYSDATE,
      pv_user_id,
      SYSDATE,
      pv_user_id,
      pv_login_id
    );

    pv_row_count_tot := pv_row_count_tot + SQL%ROWCOUNT;

    --
    -- Update a list of Ledgers' attribute which share the same
    -- Period Set Name/Period Type
    --
    -- Note that the sub query returning LEDGER_ID for H.PARENT_ID
    -- can potentially be replaced with a WHERE clause.
    --
    UPDATE FEM_LEDGERS_ATTR
    SET DIM_ATTRIBUTE_NUMERIC_MEMBER = pv_cal_per_hier_obj_def_id,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = pv_user_id,
        LAST_UPDATE_LOGIN = pv_login_id
    WHERE
      LEDGER_ID IN (
        SELECT
          H.CHILD_ID
        FROM
          FEM_LEDGERS_HIER H,
          GL_LEDGERS LGR
        WHERE
          H.PARENT_ID = (
            SELECT LEDGER_ID
            FROM FEM_LEDGERS_B
            WHERE LEDGER_DISPLAY_CODE = 'OGL_SOURCE_LEDGER_GROUP'
          ) AND
          H.HIERARCHY_OBJ_DEF_ID = 1505 AND -- a hard-coded value is to be
                                            -- replaced with a future
                                            -- FEM API return value
          LGR.LEDGER_ID = H.CHILD_ID AND
          LGR.PERIOD_SET_NAME = pv_period_set_name AND
          LGR.ACCOUNTED_PERIOD_TYPE = pv_period_type
      ) AND
      (ATTRIBUTE_ID, VERSION_ID) = (
        SELECT
          V.ATTRIBUTE_ID,
          V.VERSION_ID
        FROM
          FEM_DIM_ATTRIBUTES_B A,
          FEM_DIM_ATTR_VERSIONS_B V
        WHERE
          A.DIMENSION_ID = pv_ledger_dim_id AND
          A.ATTRIBUTE_VARCHAR_LABEL = 'CAL_PERIOD_HIER_OBJ_DEF_ID' AND
          V.ATTRIBUTE_ID = A.ATTRIBUTE_ID AND
          V.DEFAULT_VERSION_FLAG = 'Y'
      ) AND
      DIM_ATTRIBUTE_NUMERIC_MEMBER = -1;
/*
Removed the code below and replaced with -1 as part of bug 5486636
	(
        SELECT
          DIM_ATTRIBUTE_NUMERIC_MEMBER
        FROM
          FEM_DIM_ATTRIBUTES_B A,
          FEM_DIM_ATTR_VERSIONS_B V,
          FEM_LEDGERS_B L,
          FEM_LEDGERS_ATTR LA
        WHERE
          A.DIMENSION_ID = pv_ledger_dim_id AND
          A.ATTRIBUTE_VARCHAR_LABEL = 'CAL_PERIOD_HIER_OBJ_DEF_ID' AND
          V.ATTRIBUTE_ID = A.ATTRIBUTE_ID AND
          V.DEFAULT_VERSION_FLAG = 'Y' AND
          L.LEDGER_DISPLAY_CODE = 'OGL_SOURCE_LEDGER_GROUP' AND
          LA.LEDGER_ID = L.LEDGER_ID AND
          LA.ATTRIBUTE_ID = V.ATTRIBUTE_ID AND
          LA.VERSION_ID = V.VERSION_ID
	);
*/
    pv_row_count_tot := pv_row_count_tot + SQL%ROWCOUNT;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'new_gl_cal_period_hier.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.New_GL_Cal_Period_Hier',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  EXCEPTION
    WHEN FEM_INTG_fatal_err THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'new_gl_cal_period_hier.exception_fatal_err',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.New_GL_Cal_Period_Hier',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RAISE;

    WHEN OTHERS THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'new_gl_cal_period_hier.exception_others' ,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'new_gl_cal_period_hier.exception_others',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.New_GL_Cal_Period_Hier',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RAISE;

  END New_GL_Cal_Period_Hier;


  -- ======================================================================
  -- Procedure
  --   Generate_Member_IDs
  -- Purpose
  --   Generates CAL_PERIOD_IDs using FEM_DIMENSION_UTIL_PKG.Generate_Member_ID
  --   and stores them in Global Temporary table
  -- History
  --   02-02-05  Shintaro Okuda  Created
  --   08-02-05  Harikiran       Bug 4523730 - Made code changes to the query
  --                             which inserts values into the global temporary
  --                             table FEM_INTG_CAL_PERIODS_GT so that cal_period_id
  --                             and gl_period_num attribute are in sync
  -- Arguments
  --   None
  -- ======================================================================
  PROCEDURE Generate_Member_IDs
  IS
    v_err_code             NUMBER;
    v_num_msg              NUMBER;
  BEGIN

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'generate_member_ids.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Generate_Member_IDs',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    INSERT INTO FEM_INTG_CAL_PERIODS_GT(
      CAL_PERIOD_ID,
      DIMENSION_GROUP_ID,
      PERIOD_NAME,
      ENTERED_PERIOD_NAME,
      ADJUSTMENT_PERIOD_FLAG,
      START_DATE,
      END_DATE,
      PERIOD_NUM,
      QUARTER_NUM,
      PERIOD_YEAR
    )
    SELECT                                          -- Period members
      FEM_DIMENSION_UTIL_PKG.Generate_Member_ID(
        P.END_DATE,
        P.PERIOD_NUM,
        pv_calendar_id,
        G.DIMENSION_GROUP_ID
      ) CAL_PERIOD_ID,
      G.DIMENSION_GROUP_ID,
      P.PERIOD_NAME,
      P.ENTERED_PERIOD_NAME,
      P.ADJUSTMENT_PERIOD_FLAG,
      P.START_DATE,
      P.END_DATE,
      P.PERIOD_NUM,
      P.QUARTER_NUM,
      pv_period_year PERIOD_YEAR
    FROM
      GL_PERIODS P,
      FEM_DIMENSION_GRPS_B G
    WHERE
      P.PERIOD_SET_NAME = pv_period_set_name AND
      P.PERIOD_TYPE = pv_period_type AND
      P.PERIOD_YEAR = pv_period_year AND
      G.DIMENSION_GROUP_ID = pv_dimension_grp_id_period
    UNION ALL
    SELECT                                             -- Quater members
      FEM_DIMENSION_UTIL_PKG.Generate_Member_ID(
        Q.END_DATE,
        Q.QUARTER_NUM,
        pv_calendar_id,
        pv_dimension_grp_id_quarter
      ) CAL_PERIOD_ID,
      pv_dimension_grp_id_quarter,
      'Q' || Q.QUARTER_NUM || '-' || SUBSTR(pv_period_year, length(pv_period_year)-1, 2),
      'Q' || Q.QUARTER_NUM || '-' || SUBSTR(pv_period_year, length(pv_period_year)-1, 2),
      --dedutta : removed decode for fixed value N : 4970174
      'N' as  ADJUSTMENT_PERIOD_FLAG,
      Q.START_DATE,
      Q.END_DATE,
      Q.QUARTER_NUM,  -- Bug 4523730 hkaniven --
      Q.QUARTER_NUM,
      Q.PERIOD_YEAR
    FROM
     (
      SELECT
        pv_period_year PERIOD_YEAR,
        P.QUARTER_NUM,
        --dedutta : removed AP decode 4970174
        MIN(P.START_DATE) START_DATE,
        MAX(P.END_DATE) END_DATE
      FROM
        GL_PERIODS P
      WHERE
        P.PERIOD_SET_NAME = pv_period_set_name AND
        P.PERIOD_TYPE = pv_period_type AND
        P.PERIOD_YEAR = pv_period_year
      GROUP BY P.QUARTER_NUM
     ) Q,
     GL_PERIOD_TYPES PT
    WHERE
      PT.PERIOD_TYPE = pv_period_type
    UNION ALL
    SELECT                                           -- Year members
      FEM_DIMENSION_UTIL_PKG.Generate_Member_ID(
        Y.END_DATE,
        1,     -- Bug 4523730 hkaniven --
        pv_calendar_id,
        pv_dimension_grp_id_year
      ) CAL_PERIOD_ID,
      pv_dimension_grp_id_year,
      to_char(pv_period_year),
      to_char(pv_period_year),
       --dedutta : removed decode for fixed value N : 4970174
      'N'as ADJUSTMENT_PERIOD_FLAG,
      Y.START_DATE,
      Y.END_DATE,
      1,   -- Bug 4523730 hkaniven --
      Y.QUARTER_NUM,
      Y.PERIOD_YEAR
    FROM
     (
      SELECT
        pv_period_year PERIOD_YEAR,
         --dedutta : removed AP decode 4970174
        MIN(P.START_DATE) START_DATE,
        MAX(P.END_DATE) END_DATE,
        MIN(P.QUARTER_NUM) QUARTER_NUM
      FROM
        GL_PERIODS P
      WHERE
        P.PERIOD_SET_NAME = pv_period_set_name AND
        P.PERIOD_TYPE = pv_period_type AND
        P.PERIOD_YEAR = pv_period_year
     ) Y,
     GL_PERIOD_TYPES PT
    WHERE
      PT.PERIOD_TYPE = pv_period_type;

    pv_row_count_tot := pv_row_count_tot + SQL%ROWCOUNT;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'generate_member_ids.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Generate_Member_IDs',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'generate_member_ids.exception_others' ,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'generate_member_ids.exception_others',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Generate_Member_IDs',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RAISE;

  END Generate_Member_IDs;


  -- ======================================================================
  -- Procedure
  --   Populate_Time_Dimension
  -- Purpose
  --   Populates Time Dimension member and attribute tables
  --
  --   The following Time Dimension attributes are populated:
  --    'ACCOUNTING_YEAR',
  --    'ADJ_PERIOD_FLAG',
  --    'CAL_PERIOD_END_DATE',
  --    'CAL_PERIOD_PREFIX',
  --    'CAL_PERIOD_START_DATE',
  --    'CUR_PERIOD_FLAG',
  --    'GL_ORIGIN_FLAG',
  --    'GL_PERIOD_NUM',
  --    'SOURCE_SYSTEM_CODE'
  -- History
  --   02-02-05  Shintaro Okuda  Created
  --   07-15-05  Harikiran       Bug 4486878 - Populated Dimension_group_id
  --   08-29-05  Harikiran       Bug 4350620
  --                               - Get the calendar period hierarchy name
  --                                 and prefix it while inserting the
  --                                 calendar period name and description into
  --                                 the fem_cal_periods_tl table
  -- Arguments
  --   None
  -- ======================================================================
  PROCEDURE Populate_Time_Dimension
  IS
    v_err_code NUMBER;
    v_num_msg NUMBER;
  BEGIN

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'populate_time_dimension.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Populate_Time_Dimension',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    MERGE INTO FEM_CAL_PERIODS_B B
    USING (
      SELECT
        GT.CAL_PERIOD_ID         CAL_PERIOD_ID,
        GT.DIMENSION_GROUP_ID    DIMENSION_GROUP_ID,
        pv_calendar_id           CALENDAR_ID,
        'Y'                      ENABLED_FLAG,
        'N'                      PERSONAL_FLAG,
        CASE
          WHEN GT.DIMENSION_GROUP_ID = pv_dimension_grp_id_period THEN 'Y'
          ELSE 'N'
        END                      READ_ONLY_FLAG,
        pc_object_version_number OBJECT_VERSION_NUMBER,
        SYSDATE                  CREATION_DATE,
        pv_user_id               CREATED_BY,
        SYSDATE                  LAST_UPDATE_DATE,
        pv_user_id               LAST_UPDATED_BY,
        pv_login_id              LAST_UPDATE_LOGIN
      FROM
        FEM_INTG_CAL_PERIODS_GT GT
    ) S
    ON (
      B.CAL_PERIOD_ID = S.CAL_PERIOD_ID
    )
    WHEN MATCHED THEN UPDATE
      SET B.LAST_UPDATE_DATE = SYSDATE
    WHEN NOT MATCHED THEN INSERT(
      B.CAL_PERIOD_ID,
      B.DIMENSION_GROUP_ID,
      B.CALENDAR_ID,
      B.ENABLED_FLAG,
      B.PERSONAL_FLAG,
      B.READ_ONLY_FLAG,
      B.OBJECT_VERSION_NUMBER,
      B.CREATION_DATE,
      B.CREATED_BY,
      B.LAST_UPDATE_DATE,
      B.LAST_UPDATED_BY,
      B.LAST_UPDATE_LOGIN
    ) VALUES (
      S.CAL_PERIOD_ID,
      S.DIMENSION_GROUP_ID,
      S.CALENDAR_ID,
      S.ENABLED_FLAG,
      S.PERSONAL_FLAG,
      S.READ_ONLY_FLAG,
      S.OBJECT_VERSION_NUMBER,
      S.CREATION_DATE,
      S.CREATED_BY,
      S.LAST_UPDATE_DATE,
      S.LAST_UPDATED_BY,
      S.LAST_UPDATE_LOGIN
    );

    pv_row_count_tot := pv_row_count_tot + SQL%ROWCOUNT;

    --
    -- bug4335312: a source for DESCRIPTION column has been changed from
    --             GT.ENTERED_PERIOD_NAME to GT.PERIOD_NAME
    --

    --
    -- Bug 4486878: Insert a not null value to Dimension_group_id
    --

    --
    -- Bug 4350620 hkaniven --
    -- Prefix the calendar period hierarchy name to the period_name and description
    -- while inserting into the fem_cal_periods_tl table
    --


    MERGE INTO FEM_CAL_PERIODS_TL TL
    USING (
      SELECT
        GT.CAL_PERIOD_ID       CAL_PERIOD_ID,
        DECODE(GT.DIMENSION_GROUP_ID,
                        70, pv_cal_per_hier_name || '-' || GT.PERIOD_NAME,
                        10, pv_cal_per_hier_name || '-' || GT.PERIOD_NAME,
                        GT.PERIOD_NAME) CAL_PERIOD_NAME, -- Bug 4350620 hkaniven --
        GT.DIMENSION_GROUP_ID  DIMENSION_GROUP_ID, -- Bug 4486878 --
        DECODE(GT.DIMENSION_GROUP_ID,
                        70, pv_cal_per_hier_name || '-' || GT.PERIOD_NAME,
                        10, pv_cal_per_hier_name || '-' || GT.PERIOD_NAME,
                        GT.PERIOD_NAME) DESCRIPTION, -- Bug 4350620 hkaniven --
        pv_calendar_id         CALENDAR_ID,
        L.LANGUAGE_CODE        LANGUAGE,
        L.LANGUAGE_CODE        SOURCE_LANG,
        SYSDATE                CREATION_DATE,
        pv_user_id             CREATED_BY,
        SYSDATE                LAST_UPDATE_DATE,
        pv_user_id             LAST_UPDATED_BY,
        pv_login_id            LAST_UPDATE_LOGIN
      FROM
        FEM_INTG_CAL_PERIODS_GT GT,
        FND_LANGUAGES L
      WHERE
        L.INSTALLED_FLAG IN ('B','I')
    ) S
    ON (
      TL.CAL_PERIOD_ID = S.CAL_PERIOD_ID AND
      TL.LANGUAGE = S.LANGUAGE
    )
    WHEN MATCHED THEN UPDATE
      SET TL.LAST_UPDATE_DATE = SYSDATE
    WHEN NOT MATCHED THEN INSERT(
      TL.CAL_PERIOD_ID,
      TL.CAL_PERIOD_NAME,
      TL.DIMENSION_GROUP_ID, -- Bug 4486878 --
      TL.DESCRIPTION,
      TL.CALENDAR_ID,
      TL.LANGUAGE,
      TL.SOURCE_LANG,
      TL.CREATION_DATE,
      TL.CREATED_BY,
      TL.LAST_UPDATE_DATE,
      TL.LAST_UPDATED_BY,
      TL.LAST_UPDATE_LOGIN
    ) VALUES (
      S.CAL_PERIOD_ID,
      S.CAL_PERIOD_NAME,
      S.DIMENSION_GROUP_ID, -- Bug 4486878 --
      S.DESCRIPTION,
      S.CALENDAR_ID,
      S.LANGUAGE,
      S.SOURCE_LANG,
      S.CREATION_DATE,
      S.CREATED_BY,
      S.LAST_UPDATE_DATE,
      S.LAST_UPDATED_BY,
      S.LAST_UPDATE_LOGIN
    );

    pv_row_count_tot := pv_row_count_tot + SQL%ROWCOUNT;

    MERGE INTO FEM_CAL_PERIODS_ATTR ATTR
    USING (
    SELECT
      A.ATTRIBUTE_ID ATTRIBUTE_ID,
      V.VERSION_ID VERSION_ID,
      GT.CAL_PERIOD_ID CAL_PERIOD_ID,
      DECODE(
        A.ATTRIBUTE_VARCHAR_LABEL,
        'SOURCE_SYSTEM_CODE',NULL,
        'ADJ_PERIOD_FLAG', NULL,
        'GL_ORIGIN_FLAG', NULL,
        NULL
      ) DIM_ATTRIBUTE_VALUE_SET_ID,
      DECODE(
        A.ATTRIBUTE_VARCHAR_LABEL,
        'SOURCE_SYSTEM_CODE', pv_source_system_code,
        NULL
      ) DIM_ATTRIBUTE_NUMERIC_MEMBER,
      DECODE(
        A.ATTRIBUTE_VARCHAR_LABEL,
        'ADJ_PERIOD_FLAG', GT.ADJUSTMENT_PERIOD_FLAG,
        'CUR_PERIOD_FLAG', 'N',
        'GL_ORIGIN_FLAG', 'Y',
        NULL
      ) DIM_ATTRIBUTE_VARCHAR_MEMBER,
      DECODE(
        A.ATTRIBUTE_VARCHAR_LABEL,
        'ACCOUNTING_YEAR', GT.PERIOD_YEAR,
        'GL_PERIOD_NUM', GT.PERIOD_NUM,
        NULL
      ) NUMBER_ASSIGN_VALUE,
      DECODE(
        A.ATTRIBUTE_VARCHAR_LABEL,
        'CAL_PERIOD_PREFIX', GT.ENTERED_PERIOD_NAME,
        NULL
      ) VARCHAR_ASSIGN_VALUE,
      DECODE(
        A.ATTRIBUTE_VARCHAR_LABEL,
        'CAL_PERIOD_START_DATE', GT.START_DATE,
        'CAL_PERIOD_END_DATE', GT.END_DATE,
        NULL
      ) DATE_ASSIGN_VALUE,
      pc_object_version_number OBJECT_VERSION_NUMBER,
      pc_aw_snapshot_flag      AW_SNAPSHOT_FLAG,
      SYSDATE                  CREATION_DATE,
      pv_user_id               CREATED_BY,
      SYSDATE                  LAST_UPDATE_DATE,
      pv_user_id               LAST_UPDATED_BY,
      pv_login_id              LAST_UPDATE_LOGIN
    FROM
      FEM_INTG_CAL_PERIODS_GT GT,
      FEM_DIM_ATTRIBUTES_B A,
      FEM_DIM_ATTR_VERSIONS_B V
    WHERE
      A.DIMENSION_ID = pv_cal_period_dim_id AND
      V.ATTRIBUTE_ID = A.ATTRIBUTE_ID AND
      V.DEFAULT_VERSION_FLAG = 'Y' AND
      A.ATTRIBUTE_VARCHAR_LABEL IN (
        'ACCOUNTING_YEAR',
        'ADJ_PERIOD_FLAG',
        'CAL_PERIOD_END_DATE',
        'CAL_PERIOD_PREFIX',
        'CAL_PERIOD_START_DATE',
        'CUR_PERIOD_FLAG',
        'GL_ORIGIN_FLAG',
        'GL_PERIOD_NUM',
        'SOURCE_SYSTEM_CODE'
      )
    ) S
    ON (
      ATTR.ATTRIBUTE_ID = S.ATTRIBUTE_ID AND
      ATTR.VERSION_ID = S.VERSION_ID AND
      ATTR.CAL_PERIOD_ID = S.CAL_PERIOD_ID AND
      NVL(ATTR.DIM_ATTRIBUTE_NUMERIC_MEMBER, -1) =
        NVL(S.DIM_ATTRIBUTE_NUMERIC_MEMBER, -1) AND
      NVL(ATTR.DIM_ATTRIBUTE_VARCHAR_MEMBER, 'NULL') =
        NVL(S.DIM_ATTRIBUTE_VARCHAR_MEMBER, 'NULL')
    )
    WHEN MATCHED THEN UPDATE
      SET ATTR.LAST_UPDATE_DATE = SYSDATE
    WHEN NOT MATCHED THEN INSERT(
      ATTR.ATTRIBUTE_ID,
      ATTR.VERSION_ID,
      ATTR.CAL_PERIOD_ID,
      ATTR.DIM_ATTRIBUTE_NUMERIC_MEMBER,
      ATTR.DIM_ATTRIBUTE_VALUE_SET_ID,
      ATTR.DIM_ATTRIBUTE_VARCHAR_MEMBER,
      ATTR.NUMBER_ASSIGN_VALUE,
      ATTR.VARCHAR_ASSIGN_VALUE,
      ATTR.DATE_ASSIGN_VALUE,
      ATTR.OBJECT_VERSION_NUMBER,
      ATTR.AW_SNAPSHOT_FLAG,
      ATTR.CREATION_DATE,
      ATTR.CREATED_BY,
      ATTR.LAST_UPDATE_DATE,
      ATTR.LAST_UPDATED_BY,
      ATTR.LAST_UPDATE_LOGIN
    ) VALUES (
      S.ATTRIBUTE_ID,
      S.VERSION_ID,
      S.CAL_PERIOD_ID,
      S.DIM_ATTRIBUTE_NUMERIC_MEMBER,
      S.DIM_ATTRIBUTE_VALUE_SET_ID,
      S.DIM_ATTRIBUTE_VARCHAR_MEMBER,
      S.NUMBER_ASSIGN_VALUE,
      S.VARCHAR_ASSIGN_VALUE,
      S.DATE_ASSIGN_VALUE,
      S.OBJECT_VERSION_NUMBER,
      S.AW_SNAPSHOT_FLAG,
      S.CREATION_DATE,
      S.CREATED_BY,
      S.LAST_UPDATE_DATE,
      S.LAST_UPDATED_BY,
      S.LAST_UPDATE_LOGIN
    );

    pv_row_count_tot := pv_row_count_tot + SQL%ROWCOUNT;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'populate_time_dimension.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Populate_Time_Dimension',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'populate_time_dimension.exception_others' ,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'populate_time_dimension.exception_others',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Populate_Time_Dimension',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RAISE;

  END Populate_Time_Dimension;


  -- ======================================================================
  -- Procedure
  --   Populate_Time_Hierarchy
  -- Purpose
  --   Populates Time Dimension Hierarchy
  --
  --   Note that if full table scan in accessing a global temporary table
  --   twice causes a performance issue, an alternative is to generate
  --   Calendar Period ID using the FEM API when populating the Time Hierarchy
  --   table.
  --
  -- History
  --   02-02-05  Shintaro Okuda  Created
  -- Arguments
  --   None
  -- ======================================================================
  PROCEDURE Populate_Time_Hierarchy
  IS
    v_err_code NUMBER;
    v_num_msg NUMBER;
  BEGIN

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'populate_time_hierarchy.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Populate_Time_Hierarchy',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    --
    -- A record is created only if there is no existing relationship for a
    -- given child.
    --
    MERGE INTO FEM_CAL_PERIODS_HIER H
    USING (
      SELECT                              -- Termination points (Year)
        pv_cal_per_hier_obj_def_id HIERARCHY_OBJ_DEF_ID,
        1                          PARENT_DEPTH_NUM,
        GT.CAL_PERIOD_ID           PARENT_ID,
        1                          CHILD_DEPTH_NUM,
        GT.CAL_PERIOD_ID           CHILD_ID,
        'Y'                        SINGLE_DEPTH_FLAG,
        GT.PERIOD_YEAR             DISPLAY_ORDER_NUM,
        pc_weighting_pct           WEIGHTING_PCT,
        pc_object_version_number   OBJECT_VERSION_NUMBER,
        'Y'                        READ_ONLY_FLAG,
        SYSDATE                    CREATION_DATE,
        pv_user_id                 CREATED_BY,
        SYSDATE                    LAST_UPDATE_DATE,
        pv_user_id                 LAST_UPDATED_BY,
        pv_login_id                LAST_UPDATE_LOGIN
      FROM
        FEM_INTG_CAL_PERIODS_GT GT
      WHERE
        GT.DIMENSION_GROUP_ID = pv_dimension_grp_id_year
      UNION ALL
      SELECT                              -- Year and Quarter
        pv_cal_per_hier_obj_def_id HIERARCHY_OBJ_DEF_ID,
        1                          PARENT_DEPTH_NUM,
        Y.CAL_PERIOD_ID            PARENT_ID,
        2                          CHILD_DEPTH_NUM,
        Q.CAL_PERIOD_ID            CHILD_ID,
        'Y'                        SINGLE_DEPTH_FLAG,
        Q.QUARTER_NUM              DISPLAY_ORDER_NUM,
        pc_weighting_pct           WEIGHTING_PCT,
        pc_object_version_number   OBJECT_VERSION_NUMBER,
        'Y'                        READ_ONLY_FLAG,
        SYSDATE                    CREATION_DATE,
        pv_user_id                 CREATED_BY,
        SYSDATE                    LAST_UPDATE_DATE,
        pv_user_id                 LAST_UPDATED_BY,
        pv_login_id                LAST_UPDATE_LOGIN
      FROM
        FEM_INTG_CAL_PERIODS_GT Y,
        FEM_INTG_CAL_PERIODS_GT Q
      WHERE
        Y.DIMENSION_GROUP_ID = pv_dimension_grp_id_year AND
        Q.DIMENSION_GROUP_ID = pv_dimension_grp_id_quarter AND
        Y.PERIOD_YEAR = Q.PERIOD_YEAR
    ) S
    ON (
      H.HIERARCHY_OBJ_DEF_ID = S.HIERARCHY_OBJ_DEF_ID AND
      H.CHILD_ID = S.CHILD_ID
    )
    WHEN MATCHED THEN UPDATE
      SET H.LAST_UPDATE_DATE = SYSDATE
    WHEN NOT MATCHED THEN INSERT(
      H.HIERARCHY_OBJ_DEF_ID,
      H.PARENT_DEPTH_NUM,
      H.PARENT_ID,
      H.CHILD_DEPTH_NUM,
      H.CHILD_ID,
      H.SINGLE_DEPTH_FLAG,
      H.DISPLAY_ORDER_NUM,
      H.WEIGHTING_PCT,
      H.OBJECT_VERSION_NUMBER,
      H.READ_ONLY_FLAG,
      H.CREATION_DATE,
      H.CREATED_BY,
      H.LAST_UPDATE_DATE,
      H.LAST_UPDATED_BY,
      H.LAST_UPDATE_LOGIN
    ) VALUES (
      S.HIERARCHY_OBJ_DEF_ID,
      S.PARENT_DEPTH_NUM,
      S.PARENT_ID,
      S.CHILD_DEPTH_NUM,
      S.CHILD_ID,
      S.SINGLE_DEPTH_FLAG,
      S.DISPLAY_ORDER_NUM,
      S.WEIGHTING_PCT,
      S.OBJECT_VERSION_NUMBER,
      S.READ_ONLY_FLAG,
      S.CREATION_DATE,
      S.CREATED_BY,
      S.LAST_UPDATE_DATE,
      S.LAST_UPDATED_BY,
      S.LAST_UPDATE_LOGIN
    );

    pv_row_count_tot := pv_row_count_tot + SQL%ROWCOUNT;

    --
    -- A record is created only if there is no existing relationship for a
    -- given child.
    --
    MERGE INTO FEM_CAL_PERIODS_HIER H
    USING (
      SELECT
        pv_cal_per_hier_obj_def_id HIERARCHY_OBJ_DEF_ID,
        2                          PARENT_DEPTH_NUM,
        Q.CAL_PERIOD_ID            PARENT_ID,
        3                          CHILD_DEPTH_NUM,
        P.CAL_PERIOD_ID            CHILD_ID,
        'Y'                        SINGLE_DEPTH_FLAG,
        P.PERIOD_NUM               DISPLAY_ORDER_NUM,
        pc_weighting_pct           WEIGHTING_PCT,
        pc_object_version_number   OBJECT_VERSION_NUMBER,
        'N'                        READ_ONLY_FLAG,
        SYSDATE                    CREATION_DATE,
        pv_user_id                 CREATED_BY,
        SYSDATE                    LAST_UPDATE_DATE,
        pv_user_id                 LAST_UPDATED_BY,
        pv_login_id                LAST_UPDATE_LOGIN
      FROM
        FEM_INTG_CAL_PERIODS_GT P,
        FEM_INTG_CAL_PERIODS_GT Q
      WHERE
        P.DIMENSION_GROUP_ID = pv_dimension_grp_id_period AND
        Q.DIMENSION_GROUP_ID = pv_dimension_grp_id_quarter AND
        Q.QUARTER_NUM = P.QUARTER_NUM
    ) S
    ON (
      H.HIERARCHY_OBJ_DEF_ID = S.HIERARCHY_OBJ_DEF_ID AND
      H.CHILD_ID = S.CHILD_ID
    )
    WHEN MATCHED THEN UPDATE
      SET H.LAST_UPDATE_DATE = SYSDATE
    WHEN NOT MATCHED THEN INSERT(
      H.HIERARCHY_OBJ_DEF_ID,
      H.PARENT_DEPTH_NUM,
      H.PARENT_ID,
      H.CHILD_DEPTH_NUM,
      H.CHILD_ID,
      H.SINGLE_DEPTH_FLAG,
      H.DISPLAY_ORDER_NUM,
      H.WEIGHTING_PCT,
      H.OBJECT_VERSION_NUMBER,
      H.READ_ONLY_FLAG,
      H.CREATION_DATE,
      H.CREATED_BY,
      H.LAST_UPDATE_DATE,
      H.LAST_UPDATED_BY,
      H.LAST_UPDATE_LOGIN
    ) VALUES (
      S.HIERARCHY_OBJ_DEF_ID,
      S.PARENT_DEPTH_NUM,
      S.PARENT_ID,
      S.CHILD_DEPTH_NUM,
      S.CHILD_ID,
      S.SINGLE_DEPTH_FLAG,
      S.DISPLAY_ORDER_NUM,
      S.WEIGHTING_PCT,
      S.OBJECT_VERSION_NUMBER,
      S.READ_ONLY_FLAG,
      S.CREATION_DATE,
      S.CREATED_BY,
      S.LAST_UPDATE_DATE,
      S.LAST_UPDATED_BY,
      S.LAST_UPDATE_LOGIN
    );

    pv_row_count_tot := pv_row_count_tot + SQL%ROWCOUNT;

    MERGE INTO FEM_HIER_VALUE_SETS V
    USING DUAL
    ON (
      V.HIERARCHY_OBJ_ID = pv_cal_per_hier_obj_id AND
      V.VALUE_SET_ID = pv_calendar_id
    )
    WHEN MATCHED THEN UPDATE
      SET V.LAST_UPDATE_DATE = SYSDATE
    WHEN NOT MATCHED THEN INSERT (
      V.HIERARCHY_OBJ_ID,
      V.VALUE_SET_ID,
      V.OBJECT_VERSION_NUMBER,
      V.CREATION_DATE,
      V.CREATED_BY,
      V.LAST_UPDATE_DATE,
      V.LAST_UPDATED_BY,
      V.LAST_UPDATE_LOGIN
    ) VALUES (
      pv_cal_per_hier_obj_id,
      pv_calendar_id,
      pc_object_version_number,
      SYSDATE,
      pv_user_id,
      SYSDATE,
      pv_user_id,
      pv_login_id
    );

    pv_row_count_tot := pv_row_count_tot + SQL%ROWCOUNT;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'populate_time_hierarchy.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Populate_Time_Hierarchy',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'populate_time_hierarchy.exception_others' ,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'populate_time_hierarchy.exception_others',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Populate_Time_Hierarchy',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RAISE;

  END Populate_Time_Hierarchy;


  -- ======================================================================
  -- Procedure
  --   Update_Calenar_Map
  -- Purpose
  --   Updates Calendar Map table
  -- History
  --   02-02-05  Shintaro Okuda  Created
  -- Arguments
  --   None
  -- ======================================================================
  PROCEDURE Update_Calendar_Map
  IS
  BEGIN

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'update_calendar_map.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Update_Calendar_Map',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    UPDATE FEM_INTG_CALENDAR_MAP
    SET EFFECTIVE_PERIOD_NUM_MIN = pv_effective_period_num_low,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = pv_user_id,
        LAST_UPDATE_LOGIN = pv_login_id
    WHERE CAL_PER_HIER_OBJ_DEF_ID = pv_cal_per_hier_obj_def_id
    AND pv_effective_period_num_low < NVL(EFFECTIVE_PERIOD_NUM_MIN,3000*10000);

    pv_row_count_tot := pv_row_count_tot + SQL%ROWCOUNT;

    UPDATE FEM_INTG_CALENDAR_MAP
    SET EFFECTIVE_PERIOD_NUM_MAX = pv_effective_period_num_high,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = pv_user_id,
        LAST_UPDATE_LOGIN = pv_login_id
    WHERE CAL_PER_HIER_OBJ_DEF_ID = pv_cal_per_hier_obj_def_id
    AND pv_effective_period_num_high > NVL(EFFECTIVE_PERIOD_NUM_MAX, 0);

    pv_row_count_tot := pv_row_count_tot + SQL%ROWCOUNT;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'update_calendar_map.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Update_Calendar_Map',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'update_calendar_map.exception_others' ,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'update_calendar_map.exception_others',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Update_Calendar_Map',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RAISE;

  END Update_Calendar_Map;


  -- ======================================================================
  -- Procedure
  --   Print_Package_Variables
  -- Purpose
  --   Prints package variables in debug message
  -- History
  --   02-02-05  Shintaro Okuda  Created
  -- Arguments
  --   None
  -- ======================================================================
  PROCEDURE Print_Package_Variables
  IS
    cr CONSTANT VARCHAR2(1) := '
';
  BEGIN
    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'print_pkg_variable_values',
      p_msg_text => cr ||
        'pv_folder_id=' || pv_folder_id || cr ||
        'pv_cal_rule_obj_id=' || pv_cal_rule_obj_id || cr ||
        'pv_cal_rule_obj_def_id=' || pv_cal_rule_obj_def_id || cr ||
        'pv_req_id=' || pv_req_id || cr ||
        'pv_user_id=' || pv_user_id || cr ||
        'pv_resp_id=' || pv_resp_id || cr ||
        'pv_login_id=' || pv_login_id || cr ||
        'pv_pgm_id=' || pv_pgm_id || cr ||
        'pv_pgm_app_id=' || pv_pgm_app_id || cr ||
        'pv_effective_start_date=' || pv_effective_start_date || cr ||
        'pv_effective_end_date=' || pv_effective_end_date || cr ||
        'pv_period_set_name=' || pv_period_set_name || cr ||
        'pv_period_type=' || pv_period_type || cr ||
        'pv_period_type_name=' || pv_period_type_name || cr ||
        'pv_period_year=' || pv_period_year || cr ||
        'pv_effective_period_num_low=' || pv_effective_period_num_low || cr ||
        'pv_effective_period_num_high=' || pv_effective_period_num_high || cr||
        'pv_ogl_period_type_code=' || pv_ogl_period_type_code || cr ||
        'pv_ogl_period_type_name=' || pv_ogl_period_type_name || cr ||
        'pv_ogl_period_type_desc=' || pv_ogl_period_type_desc || cr ||
        'pv_ogl_number_per_fiscal_year=' || pv_ogl_number_per_fiscal_year||cr||
        'pv_cal_per_hier_obj_id=' || pv_cal_per_hier_obj_id || cr ||
        'pv_cal_per_hier_obj_def_id=' || pv_cal_per_hier_obj_def_id || cr ||
        'pv_dimension_grp_id_period=' || pv_dimension_grp_id_period || cr ||
        'pv_calendar_id=' || pv_calendar_id || cr ||
        'pv_effective_period_num_min=' || pv_effective_period_num_min || cr ||
        'pv_effective_period_num_max=' || pv_effective_period_num_max || cr ||
        'pv_new_periods_to_process=' || pv_new_periods_to_process || cr ||
        'pv_ledger_dim_id=' || pv_ledger_dim_id || cr ||
        'pv_calendar_dim_id=' || pv_calendar_dim_id || cr ||
        'pv_cal_period_dim_id=' || pv_cal_period_dim_id || cr ||
        'pv_time_group_type_dim_id=' || pv_time_group_type_dim_id || cr ||
        'pv_dimension_grp_id_quarter=' || pv_dimension_grp_id_quarter || cr ||
        'pv_dimension_grp_id_year=' || pv_dimension_grp_id_year || cr ||
        'pv_source_system_code=' || pv_source_system_code || cr ||
        'pv_row_count_tot=' || pv_row_count_tot || cr ||
        'pv_completion_status=' || pv_completion_status
      );

  END Print_Package_Variables;


  -- ======================================================================
  -- Procedure
  --   Main
  -- Purpose
  --   Executes the Calendar Engine
  -- History
  --   02-02-05  Shintaro Okuda  Created
  --   08-29-05  Harikiran       Bug 4350620
  --                             Get the calendar period hierarchy name
  -- Arguments
  --   x_errbuf                  Standard Concurrent Program parameter
  --   x_retcode                 Standard Concurrent Program parameter
  --   p_cal_rule_obj_def_id     Calendar Rule Object Definition ID
  --   p_period_set_name         Period Set Name
  --   p_period_type             Period Type
  --   p_period_year             Period Year
  -- ======================================================================
  PROCEDURE Main(
    x_errbuf               OUT NOCOPY  VARCHAR2,
    x_retcode              OUT NOCOPY VARCHAR2,
    p_cal_rule_obj_def_id  IN NUMBER,
    p_period_set_name      IN VARCHAR2,
    p_period_type          IN VARCHAR2,
    p_period_year          IN NUMBER
  ) IS
    FEM_INTG_fatal_err EXCEPTION;

    v_completion_code NUMBER;
    v_ret_status BOOLEAN;

  BEGIN

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'main.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Main',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    --
    -- Initialize Variables
    --
    Init(
      p_cal_rule_obj_def_id => p_cal_rule_obj_def_id,
      p_period_set_name     => p_period_set_name,
      p_period_type         => p_period_type,
      p_period_year         => p_period_year
    );

    FEM_INTG_PL_PKG.Register_Process_Execution(
      p_obj_id          => pv_cal_rule_obj_id,
      p_obj_def_id      => pv_cal_rule_obj_def_id,
      p_req_id          => pv_req_id,
      p_user_id         => pv_user_id,
      p_login_id        => pv_login_id,
      p_pgm_id          => pv_pgm_id,
      p_pgm_app_id      => pv_pgm_app_id,
      p_module_name     => pc_module_name || 'register_process_execution',
      x_completion_code => v_completion_code
    );

    IF v_completion_code = 2 THEN
      RAISE FEM_INTG_fatal_err;
    END IF;

    IF pv_new_periods_to_process = 'Y' THEN
      --
      -- If hierarchy object definition ID is not defined yet,
      -- create a new Calendar and a new Time Dimension Group if not
      -- created yet before creating a new hierarchy.
      --
      IF pv_cal_per_hier_obj_def_id IS NULL THEN
        --
        -- Create Calendar in FEM if not exist yet
        --
        IF pv_calendar_id IS NULL THEN
          New_Calendar();
        END IF;

        --
        -- Create Time Group Type and Time Dimension Group if not exists yet
        --
        IF pv_dimension_grp_id_period IS NULL THEN
          New_Time_Dimension_Group();
        END IF;

        --
        -- Create a new Calendar Period hierarchy
        --
        New_GL_Cal_Period_Hier();

      END IF;

      --
      -- Bug 4350620 hkaniven --
      -- Get the calendar period hierarchy name which will then be added as a
      -- prefix to the period_name while inserting into the table
      -- fem_cal_periods_tl
      --

      SELECT TRIM(display_name)
      INTO pv_cal_per_hier_name
      FROM fem_object_definition_vl
      WHERE object_id =   pv_cal_per_hier_obj_id
      AND   object_definition_id  =  pv_cal_per_hier_obj_def_id;

      --
      -- Generate cal_period_id in GT table
      --
      Generate_Member_IDs();

      --
      -- Populate Time Dimension Members and attributes
      --
      Populate_Time_Dimension();

      --
      -- Populate Time Dimension Hierarchy
      --
      Populate_Time_Hierarchy();

      --
      -- Update the mapping table for additionally processed periods by this
      -- run
      --
      Update_Calendar_Map();

      COMMIT;

    END IF;

    v_completion_code := 0;

    FEM_INTG_PL_PKG.Final_Process_Logging(
      p_obj_id          => pv_cal_rule_obj_id,
      p_obj_def_id      => pv_cal_rule_obj_def_id,
      p_req_id          => pv_req_id,
      p_user_id         => pv_user_id,
      p_login_id        => pv_login_id,
      p_exec_status     => 'SUCCESS',
      p_row_num_loaded  => pv_row_count_tot,
      p_err_num_count   => 0,
      p_final_msg_name  => 'FEM_INTG_PROC_SUCCESS',
      p_module_name     => pc_module_name || 'final_process_logging',
      x_completion_code => v_completion_code
    );

    IF v_completion_code = 2 THEN
      RAISE FEM_INTG_fatal_err;
    END IF;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || 'main.end' ,
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Main',
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_INTG_PROC_SUCCESS'
    );

    Print_Package_Variables();

    v_ret_status := FND_CONCURRENT.Set_Completion_Status(
                      status => pv_completion_status,
                      message => NULL
                    );

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      FEM_INTG_PL_PKG.Final_Process_Logging(
        p_obj_id          => pv_cal_rule_obj_id,
        p_obj_def_id      => pv_cal_rule_obj_def_id,
        p_req_id          => pv_req_id,
        p_user_id         => pv_user_id,
        p_login_id        => pv_login_id,
        p_exec_status     => 'ERROR_RERUN',
        p_row_num_loaded  => 0,
        p_err_num_count   => pv_row_count_tot,
        p_final_msg_name  => 'FEM_INTG_PROC_FAILURE',
        p_module_name     => pc_module_name || 'final_process_logging',
        x_completion_code => v_completion_code
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name || 'main.exception_others',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_CAL_RULE_ENG_PKG.Main',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_PROC_FAILURE'
      );

      Print_Package_Variables();

      v_ret_status := FND_CONCURRENT.Set_Completion_Status(
                        status => 'ERROR',
                        message => NULL
                      );

  END Main;

END FEM_INTG_CAL_RULE_ENG_PKG;

/
