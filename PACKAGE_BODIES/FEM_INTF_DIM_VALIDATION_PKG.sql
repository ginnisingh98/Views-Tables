--------------------------------------------------------
--  DDL for Package Body FEM_INTF_DIM_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_INTF_DIM_VALIDATION_PKG" AS
/* $Header: fem_intf_val_eng.plb 120.1 2006/08/14 11:42:50 hkaniven ship $*/

-- ======================================================================
-- Private Package Variables
-- ======================================================================

  pc_log_level_statement    CONSTANT NUMBER := FND_LOG.level_statement;
  pc_log_level_procedure    CONSTANT NUMBER := FND_LOG.level_procedure;
  pc_log_level_event        CONSTANT NUMBER := FND_LOG.level_event;
  pc_log_level_exception    CONSTANT NUMBER := FND_LOG.level_exception;
  pc_log_level_error        CONSTANT NUMBER := FND_LOG.level_error;
  pc_log_level_unexpected   CONSTANT NUMBER := FND_LOG.level_unexpected;
  pc_date_format            CONSTANT VARCHAR2(10) := 'DD-MM-YYYY';
  pc_default_dim_grp_size   CONSTANT NUMBER := 5;

  pc_req_id                 CONSTANT NUMBER := FND_GLOBAL.Conc_Request_Id ;
  pc_user_id                CONSTANT NUMBER := FND_GLOBAL.User_Id;
  pc_login_id               CONSTANT NUMBER := FND_GLOBAL.Login_Id;
  pc_pgm_id                 CONSTANT NUMBER := FND_GLOBAL.Conc_Program_Id;
  pc_pgm_app_id             CONSTANT NUMBER := FND_GLOBAL.Prog_Appl_ID;

  pv_num_rec_to_print       NUMBER := 500;
  pv_log_current_level      NUMBER;
  pv_ledger_id              NUMBER;
  pv_cal_period_id          NUMBER;
  pv_dataset_code           NUMBER;
  pv_source_system_code     NUMBER;
  pv_num_dims               NUMBER;
  pv_table_name             VARCHAR2(30);
  pv_interface_table_name   VARCHAR2(30);
  pv_print_report           BOOLEAN := FALSE;
  pv_cal_per_number         FEM_CAL_PERIODS_ATTR.number_assign_value%TYPE;
  pv_ledger_dc              FEM_LEDGERS_B.ledger_display_code%TYPE;
  pv_time_dim_grp_dc        FEM_DIMENSION_GRPS_B.dimension_group_display_code%TYPE;
  pv_cal_per_end_date       FEM_CAL_PERIODS_ATTR.date_assign_value%TYPE;
  pv_dataset_dc             FEM_DATASETS_B.dataset_display_code%TYPE;
  pv_source_system_dc       FEM_SOURCE_SYSTEMS_B.source_system_display_code%TYPE;
  pv_num_rows               NUMBER;

  pv_obj_def_id             NUMBER;

  TYPE xdim_info_rec IS RECORD
     (
      int_disp_code_col     FEM_INT_COLUMN_MAP.interface_column_name%TYPE,
      vs_required_flag      FEM_XDIM_DIMENSIONS.value_set_required_flag%TYPE,
      vs_id                 FEM_GLOBAL_VS_COMBO_DEFS.value_set_id%TYPE,
      member_b_table_name   FEM_XDIM_DIMENSIONS.member_b_table_name%TYPE,
      member_col            FEM_XDIM_DIMENSIONS.member_col%TYPE,
      member_disp_code_col  FEM_XDIM_DIMENSIONS.member_display_code_col%TYPE,
      target_col_data_type  FEM_XDIM_DIMENSIONS.member_data_type_code%TYPE,
      target_col            FEM_TAB_COLUMNS_V.column_name%TYPE);

  TYPE xdim_info_table_type IS TABLE OF xdim_info_rec INDEX BY BINARY_INTEGER;

  pv_xdim_info_tbl          xdim_info_table_type;
  e_inv_obj_def             EXCEPTION;

  G_API_VERSION             CONSTANT NUMBER      := 1.0;
  G_RET_STS_SUCCESS         CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR           CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR     CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

-- ======================================================================
-- Procedure
--    Main
--
-- Purpose
--    This is the main procedure that controls the flow of the program
--
--    It initializes the package level variables and then calls the
--    sub-routines to validate parameters and to validate dimensional
--    information of the interface records.
--
--    If any of the sub-routine returns with an error status, this routine
--    will end the concurrent program in an error status with the
--    appropriate message.
--
-- Arguments
--    x_errbuf             : Standard Concurrent Program parameter
--    x_retcode            : Standard Concurrent Program parameter
--    p_obj_def_id         : Detail Client Data Table Name
--    p_ledger_id          : Ledger ID
--    p_cal_period_id      : Calendar Period ID
--    p_dataset_code       : Dataset Code
--    p_source_system_code : Source System Code
--    p_num_rows           : Number of rows to be validated
--    p_print_report_flag  : Flag indicating if program should print
--                           errors to concurrent output file
--    p_num_rec_to_print   : Maximum number of errors to print to the
--                           concurrent output file
--
-- HISTORY
--    04-21-06  Harikiran   Bug 5115380 - Inserted Value Too Large for Col
--    07-18-06  Harikiran   Bug 5398129 - No_data_found case will show up a
--                                        new message and end with a 'WARNING'
--					  status and Invalid Dimensions found
--					  case will end with a 'ERROR'
--					  Formatted the reporting sql that is
--					  displayed in the request log
--    07-24-06  Harikiran   Bug 5406315 - Max value of records that can be
--                                        validated and printed increased to
--                                        99999 from 9999
--
-- ======================================================================

PROCEDURE Main (
  x_errbuf              OUT NOCOPY  VARCHAR2,
  x_retcode             OUT NOCOPY  VARCHAR2,
  p_obj_def_id          IN          VARCHAR2,
  p_ledger_id           IN          VARCHAR2,
  p_cal_period_id       IN          VARCHAR2,
  p_dataset_code        IN          VARCHAR2,
  p_source_system_code  IN          VARCHAR2,
  p_num_rows            IN          VARCHAR2,
  p_print_report_flag   IN          VARCHAR2 default 'N',
  p_num_rec_to_print    IN          VARCHAR2 default '500'
) IS

  vc_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_intf_dim_validation_pkg.main';

  v_no_err_code         VARCHAR2(80);
  v_rec_count           NUMBER;
  v_id_num              NUMBER;
  v_warning_status      BOOLEAN := FALSE;
  v_has_id_number       BOOLEAN := TRUE;
  v_dummy_boolean       BOOLEAN;
  v_sql_stmt            VARCHAR2(32767);
  v_dummy               VARCHAR2(1);
  v_rowid               ROWID;

  TYPE v_err_rec_type IS REF CURSOR;
  v_err_records         v_err_rec_type;

  v_dimension_name      VARCHAR2(32767);
  v_return_status       VARCHAR2(1);
  v_completion_code     NUMBER;
  v_start               NUMBER;
  v_old                 NUMBER;
  v_end                 NUMBER;
  v_next_occurrence     NUMBER;
  v_dimension_name_part VARCHAR2(200);
  v_req_id              FND_CONCURRENT_REQUESTS.request_id%TYPE;
  v_main_sql_stmt       VARCHAR2(32767);
  v_table_update_stmt   VARCHAR2(32767);
  v_table_select_stmt   VARCHAR2(32767);
  v_count               NUMBER;
    -- Bug 5398129 hkaniven start
  v_no_data_found       BOOLEAN := FALSE;
  v_invalid_dims_found  BOOLEAN := FALSE;
  v_no_of_chars         NUMBER;
  -- Bug 5398129 hkaniven end


  FEM_PGM_fatal_err     EXCEPTION;

BEGIN

  pv_log_current_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  v_return_status      := G_RET_STS_UNEXP_ERROR;

  IF pc_log_level_procedure >= pv_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure,
        p_module   => vc_module,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_201',
        p_token1   => 'FUNC_NAME',
        p_value1   => vc_module ,
        p_token2   => 'TIME',
        p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  END IF;

  --
  -- Initalize package level Variables
  --
  pv_ledger_id            := to_number(p_ledger_id);
  pv_cal_period_id        := to_number(p_cal_period_id);
  pv_dataset_code         := to_number(p_dataset_code);
  pv_source_system_code   := to_number(p_source_system_code);
  pv_obj_def_id           := to_number(p_obj_def_id);
  pv_num_rec_to_print     := NULL;
  pv_num_rows             := NULL;

  IF p_print_report_flag = 'Y' THEN
     pv_print_report := TRUE;
  ELSE
     pv_print_report := FALSE;
  END IF;


  --
  -- Validate all input parameters
  --
  Validate_Params(x_completion_code => v_completion_code);

  --
  -- If any of the parameters is invalid error out the program
  --
  IF v_completion_code = 1 OR v_completion_code = 2 THEN
    RAISE FEM_PGM_fatal_err;
  END IF;

  --
  -- Check whether p_num_rec_to_print is a valid positive number or not
  --
  IF p_num_rec_to_print IS NOT NULL THEN
      Is_Number(p_num_rec_to_print, pv_num_rec_to_print);
  ELSE
      pv_num_rec_to_print     := 99999; --Bug 5406315 hkaniven
  END IF;

  --
  -- Check whether p_num_rows is a valid positive number or not
  --
  IF p_num_rows IS NOT NULL THEN
      Is_Number(p_num_rows, pv_num_rows);
  ELSE
      pv_num_rows             := 99999; --Bug 5406315 hkaniven
  END IF;

  --
  -- Error out the program if pv_num_rows in not a valid positive number
  --
  IF pv_num_rows IS NULL OR pv_num_rows = 0 THEN
     FEM_ENGINES_PKG.USER_MESSAGE(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_INTF_DIM_INVALID_POS_NUM',
            p_token1   => 'PARAM_NAME',
            p_value1   => 'FEM_INTF_DIM_PARAM_NAME1',
            p_trans1   => 'Y');

     RAISE FEM_PGM_fatal_err;
  END IF;

  --
  -- Error out the program if pv_num_rec_to_print in not a valid positive number
  --
  IF pv_num_rec_to_print IS NULL THEN
     FEM_ENGINES_PKG.USER_MESSAGE(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_INTF_DIM_INVALID_POS_NUM',
            p_token1   => 'PARAM_NAME',
            p_value1   => 'FEM_INTF_DIM_PARAM_NAME2',
            p_trans1   => 'Y');

     RAISE FEM_PGM_fatal_err;
  END IF;

  --Bug 5406315 hkaniven start
  IF pv_num_rows = 99999 THEN
    FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTF_PARAM_DEF_VAL',
         p_token1   => 'PARAM_NAME',
         p_value1   => 'Number of records to be Validated');

    FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => vc_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTF_PARAM_DEF_VAL',
         p_token1   => 'PARAM_NAME',
         p_value1   => 'Number of records to be Validated');
  END IF;

  IF pv_num_rec_to_print = 99999 THEN
    FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTF_PARAM_DEF_VAL',
         p_token1   => 'PARAM_NAME',
         p_value1   => 'Number of records to be Printed');

    FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => vc_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTF_PARAM_DEF_VAL',
         p_token1   => 'PARAM_NAME',
         p_value1   => 'Number of records to be Printed');
  END IF;
  --Bug 5406315 hkaniven end


  FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTF_VALIDATE_ERR_NUM',
           p_token1   => 'NUM',
           p_value1   => pv_num_rows);
  FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTF_PRINT_ERR_NUM',
           p_token1   => 'NUM',
           p_value1   => pv_num_rec_to_print);


  -- Bug 5398129 hkaniven start
  -- List out the parameter values
    FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTF_PARAMS',
         p_token1   => 'DIM_GRP',
         p_value1   => pv_time_dim_grp_dc,
         p_token2   => 'PER_NUM',
         p_value2   => pv_cal_per_number,
         p_token3   => 'END_DATE',
         p_value3   => pv_cal_per_end_date,
         p_token4   => 'LEDGER_DC',
         p_value4   => pv_ledger_dc,
         p_token5   => 'DATASET_DC',
         p_value5   => pv_dataset_dc,
         p_token6   => 'SOURCE_DC',
         p_value6   => pv_source_system_dc,
         p_token7   => 'NUM_ROWS',
         p_value7   => pv_num_rows,
         p_token8   => 'NUM_REC_TO_PRINT',
         p_value8   => pv_num_rec_to_print,
         p_token9   => 'TABLE_NAME',
         p_value9   => pv_table_name);

    FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => vc_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTF_PARAMS',
         p_token1   => 'DIM_GRP',
         p_value1   => pv_time_dim_grp_dc,
         p_token2   => 'PER_NUM',
         p_value2   => pv_cal_per_number,
         p_token3   => 'END_DATE',
         p_value3   => pv_cal_per_end_date,
         p_token4   => 'LEDGER_DC',
         p_value4   => pv_ledger_dc,
         p_token5   => 'DATASET_DC',
         p_value5   => pv_dataset_dc,
         p_token6   => 'SOURCE_DC',
         p_value6   => pv_source_system_dc,
         p_token7   => 'NUM_ROWS',
         p_value7   => pv_num_rows,
         p_token8   => 'NUM_REC_TO_PRINT',
         p_value8   => pv_num_rec_to_print,
         p_token9   => 'TABLE_NAME',
         p_value9   => pv_table_name);

  -- Bug 5398129 hkaniven end

  FEM_ENGINES_PKG.USER_MESSAGE(
          p_app_name => 'FEM',
          p_msg_text => 'PRINT_REPORT: ' || p_print_report_flag );

  FND_FILE.put_line(FND_FILE.LOG,null);

  --
  -- Validate the dimensional information of all interface records
  --
  Validate_Dims(x_completion_code => v_completion_code);

  -- Bug 5398129 hkaniven start
  IF v_completion_code = 1 THEN
    v_no_data_found := TRUE;
  ELSIF v_completion_code = 2 THEN
    v_invalid_dims_found := TRUE;
  ELSIF v_completion_code = 3 THEN
    RAISE FEM_PGM_fatal_err;
  END IF;
  -- Bug 5398129 hkaniven end

  --
  -- Only if there are invalid dimension values populate the fem_interface_fact_errs
  -- table and output the report containing invalid dimension values.
  --
  IF v_invalid_dims_found THEN
      --
      -- Check if the fact table contains the column ID_NUMBER
      --
      BEGIN
        v_sql_stmt := 'SELECT ''y''
                         FROM FEM_TAB_COLUMNS_B
                            WHERE table_name = '''||upper(pv_table_name)||'''
                              AND column_name = ''ID_NUMBER''';

        IF pc_log_level_statement >= pv_log_current_level THEN
           FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => pc_log_level_statement,
                p_module   => vc_module,
                  p_msg_text => 'SQL to check if ID_NUMBER column exist '||v_sql_stmt);
        END IF;

        EXECUTE IMMEDIATE v_sql_stmt into v_dummy;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_has_id_number := FALSE;
      END;

      -- Update Statement to transfer invalid values to the fem_interface_fact_errs will
      -- be constructed as two parts
      -- v_table_update_stmt - contains the first part - the columns which have to be
      --                       updated.
      -- v_table_select_stmt - contains the second part - the invalid values with which
      --                       the columns will be updated
      -- The full statement will be v_main_sql_stmt

      --
      -- Sample v_main_sql_stmt for the first five dimensions of 'FEM_CHECKING' table
      --
      -- UPDATE
      --     FEM_INTERFACE_FACT_ERRS fide
      --     SET
      --     (
      --         ID_NUMBER ,
      --         DIM1_NAME ,
      --         DIM1_VALUE ,
      --         DIM2_NAME ,
      --         DIM2_VALUE ,
      --         DIM3_NAME ,
      --         DIM3_VALUE ,
      --         DIM4_NAME ,
      --         DIM4_VALUE ,
      --         DIM5_NAME ,
      --         DIM5_VALUE
      --     )
      --     =
      --     (
      --     SELECT
      --         id_number ,
      --         'CURRENCY_CODE',
      --         DECODE(substr(error_code,1,1),'1',CURRENCY_CODE, NULL) ,
      --         'ATM_CARD_FLG',
      --         DECODE(substr(error_code,2,1),'1',ATM_CARD_FLG, NULL) ,
      --         'CREDIT_LINE_FLG',
      --         DECODE(substr(error_code,3,1),'1',CREDIT_LINE_FLG, NULL) ,
      --         'EMBEDDED_OPTIONS_FLG',
      --         DECODE(substr(error_code,4,1),'1',EMBEDDED_OPTIONS_FLG, NULL) ,
      --         'JOINT_ACCOUNT_FLG',
      --         DECODE(substr(error_code,5,1),'1',JOINT_ACCOUNT_FLG, NULL) ,
      --         'OPEN_ACCOUNT_FLG'
      --     FROM FEM_CHECKING_T t
      --     WHERE t.rowid = fide.interface_rowid
      --     )
      --     WHERE fide.request_id = 3171104
      --

      v_table_update_stmt := 'UPDATE FEM_INTERFACE_FACT_ERRS fide SET (ID_NUMBER ';

      --
      -- Build v_sql_stmt -  dynamic SQL statement to get problematic interface records
      -- from the fem_interface_fact_errs table
      -- This statement will be executed to display the problematic interface records
      -- stored in the fem_interface_fact_errs table, into the conc request output file
      --
      -- Sample reporting stmt - v_sql_stmt
      --
      -- SELECT
      --     id_number,
      --     DECODE(substr(error_code,1,1),'1',DIM1_NAME || '(' || DIM1_VALUE || '), ', NULL)
      --       || DECODE(substr(error_code,2,1),'1',DIM2_NAME || '(' || DIM2_VALUE || '), ', NULL)
      --       || DECODE(substr(error_code,3,1),'1',DIM3_NAME || '(' || DIM3_VALUE || '  ), ', NULL)
      --       || DECODE(substr(error_code,4,1),'1',DIM4_NAME || '(' || DIM4_VALUE || '), ', NULL)
      --       || DECODE(substr(error_code,5,1),'1',DIM5_NAME || '(' || DIM5_VALUE || '), ', NULL)
      -- FROM fem_interface_dim _errs
      -- WHERE request_id = 3119007
      -- AND rownum <= 2
      --

      --
      -- Build v_table_select_stmt - dynamic SQL statement to locate problematic interface
      -- records data from the detail client interface table.
      -- This statement will form the second part of the Update statement which will
      -- populate invalid data into the fem_interface_fact_errs table.
      --

      FOR v_dim_index IN 1..pv_num_dims LOOP
        IF v_dim_index = 1 THEN
          IF v_has_id_number THEN
            v_sql_stmt := 'SELECT id_number,';
            v_table_select_stmt := ' = (SELECT id_number ';
          ELSE
            v_sql_stmt := 'SELECT interface_rowid,';
            v_table_select_stmt := ' = (SELECT NULL ';
          END IF;
        ELSE
          v_sql_stmt := v_sql_stmt||'|| ';
        END IF;

        v_sql_stmt := v_sql_stmt||' DECODE(substr(error_code,'||to_char(v_dim_index)||',1),''1'','|| 'DIM' || to_char(v_dim_index) || '_NAME || ''(''' || ' || ' ;
        v_table_select_stmt := v_table_select_stmt ||  ', ' || '''' || pv_xdim_info_tbl(v_dim_index).int_disp_code_col || ''', ' ||
        ' DECODE(substr(error_code,'||to_char(v_dim_index)||',1),''1'',' ;

        v_sql_stmt := v_sql_stmt || 'DIM' || to_char(v_dim_index) || '_VALUE' || ' || ' || ''')'', NULL) ';
    	v_table_select_stmt := v_table_select_stmt || pv_xdim_info_tbl(v_dim_index).int_disp_code_col ||  ', NULL) ';

        v_table_update_stmt := v_table_update_stmt || ', DIM' || v_dim_index || '_NAME '
                        || ', DIM' || v_dim_index || '_VALUE ';

      END LOOP;

      v_table_update_stmt := v_table_update_stmt || ' ) ';

      v_sql_stmt := v_sql_stmt ||
                    'FROM FEM_INTERFACE_FACT_ERRS '
                    || ' WHERE request_id = ' || pc_req_id
                    || ' AND rownum <= ' || pv_num_rec_to_print;

      v_table_select_stmt := v_table_select_stmt ||
                   ' FROM '|| pv_interface_table_name || ' t '
                   || ' WHERE t.rowid = fide.interface_rowid  )';


      --
      -- Form the full update statement by combining the the two parts
      --
      v_main_sql_stmt := v_table_update_stmt || v_table_select_stmt
                         || ' WHERE fide.request_id = ' || pc_req_id ;

      IF pc_log_level_statement >= pv_log_current_level THEN
         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => pc_log_level_statement,
            p_module   => vc_module,
            p_msg_text => 'SQL to report is ');
      END IF;

      FND_FILE.put_line(FND_FILE.LOG,null);

          FEM_ENGINES_PKG.USER_MESSAGE(
            p_app_name => 'FEM',
            p_msg_text => 'SQL to report is ');

      FND_FILE.put_line(FND_FILE.LOG,null);

  -- Bug 5398129 hkaniven start
      v_count := 1;
      LOOP
          v_no_of_chars := INSTR(v_sql_stmt, 'NULL)', v_count);

          IF v_no_of_chars = 0 THEN

              IF pc_log_level_statement >= pv_log_current_level THEN
                FEM_ENGINES_PKG.TECH_MESSAGE(
                  p_severity => pc_log_level_statement,
                  p_module   => vc_module,
                  p_msg_text => SUBSTR(v_sql_stmt,v_count,LENGTH(v_sql_stmt) - v_count + 1));
              END IF;

              FEM_ENGINES_PKG.USER_MESSAGE(
                p_app_name => 'FEM',
                p_msg_text => SUBSTR(v_sql_stmt,v_count,LENGTH(v_sql_stmt) - v_count + 1));

              EXIT;
          END IF;

          v_no_of_chars := v_no_of_chars - v_count + 5 ;


          IF pc_log_level_statement >= pv_log_current_level THEN
            FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => pc_log_level_statement,
              p_module   => vc_module,
              p_msg_text => substr(v_sql_stmt,v_count,v_no_of_chars));
          END IF;

          FEM_ENGINES_PKG.USER_MESSAGE(
            p_app_name => 'FEM',
            p_msg_text => substr(v_sql_stmt,v_count,v_no_of_chars));

          v_count := v_count + v_no_of_chars ;

      END LOOP;
  -- Bug 5398129 hkaniven end

      IF pc_log_level_statement >= pv_log_current_level THEN
         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => pc_log_level_statement,
            p_module   => vc_module,
            p_msg_text => 'SQL to update target table is ');
      END IF;

      v_count := 1;
      LOOP
          IF pc_log_level_statement >= pv_log_current_level THEN
            FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => pc_log_level_statement,
              p_module   => vc_module,
              p_msg_text => substr(v_main_sql_stmt,v_count,255));
          END IF;

          EXIT WHEN LENGTH(v_main_sql_stmt) < v_count ;
          v_count := v_count + 255;
      END LOOP;

      EXECUTE IMMEDIATE v_main_sql_stmt;

      COMMIT;

      --
      -- Print out invalid dimensions in concurrent program output file
      --

      IF pv_print_report THEN
        FND_MESSAGE.set_name('FEM','FEM_INTF_VALIDATE_ERR_NUM');
        FND_MESSAGE.set_token('NUM',pv_num_rows);
        FND_FILE.put_line(FND_FILE.OUTPUT, FND_MESSAGE.get);
        FND_MESSAGE.set_name('FEM','FEM_INTF_PRINT_ERR_NUM');
        FND_MESSAGE.set_token('NUM',pv_num_rec_to_print);
        FND_FILE.put_line(FND_FILE.OUTPUT, FND_MESSAGE.get);

        FND_FILE.put_line(FND_FILE.OUTPUT,null);

        IF v_has_id_number THEN
           FND_MESSAGE.set_name('FEM','FEM_INTF_VALIDATE_REP1');
           FND_FILE.put_line(FND_FILE.OUTPUT, FND_MESSAGE.get);
        ELSE
           FND_MESSAGE.set_name('FEM','FEM_INTF_VALIDATE_REP2');
           FND_FILE.put_line(FND_FILE.OUTPUT, FND_MESSAGE.get);
        END IF;

        FND_FILE.put_line(FND_FILE.OUTPUT,'------------------  ----------------------------------------------------------------------------------------------------------------');
        FND_FILE.put_line(FND_FILE.OUTPUT,null);

        v_rec_count := 0;

        IF v_has_id_number THEN

          OPEN v_err_records FOR v_sql_stmt;
          LOOP
           FETCH v_err_records INTO v_id_num, v_dimension_name;
           EXIT WHEN v_err_records%NOTFOUND or
                  v_rec_count > pv_num_rec_to_print;

           --
           -- Print only one full dimension name/value pair on a single line in the
           -- output report listing
           --
           v_start := 1;

            LOOP
                v_end := INSTR(v_dimension_name, ')', v_start, 1);
                EXIT WHEN v_end = 0;

	    	    v_dimension_name_part := SUBSTR(v_dimension_name, v_start, v_end - v_start + 1);
                EXIT WHEN v_dimension_name_part IS NULL;

                IF v_start = 1 THEN
                  FND_FILE.put_line(FND_FILE.OUTPUT, rpad(v_id_num,20,' ') || v_dimension_name_part);
                ELSE
                  FND_FILE.put_line(FND_FILE.OUTPUT,'                    ' || v_dimension_name_part);
                END IF;

                v_start := v_end + 1 ;
            END LOOP;
           v_rec_count := v_rec_count + 1;
          END LOOP;
          CLOSE v_err_records;
        ELSE
          OPEN v_err_records FOR v_sql_stmt;
          LOOP
           FETCH v_err_records INTO v_rowid, v_dimension_name;
           EXIT WHEN v_err_records%NOTFOUND or
                  v_rec_count > pv_num_rec_to_print;

           --
           -- Print only one full dimension name/value pairs on a single line in the
           -- output report listing
           --
           v_start := 1;

           LOOP
                v_end := INSTR(v_dimension_name, ')', v_start, 1);
                EXIT WHEN v_end = 0;

	    	    v_dimension_name_part := SUBSTR(v_dimension_name, v_start, v_end - v_start + 1);
                EXIT WHEN v_dimension_name_part IS NULL;

                IF v_start = 1 THEN
                  FND_FILE.put_line(FND_FILE.OUTPUT, rpad(v_rowid,20,' ') || v_dimension_name_part);
                ELSE
                  FND_FILE.put_line(FND_FILE.OUTPUT,'                    ' || v_dimension_name_part);
                END IF;

                v_start := v_end + 1 ;
           END LOOP;
           v_rec_count := v_rec_count + 1;
          END LOOP;
          CLOSE v_err_records;
         END IF;
       END IF;
     ELSIF NOT v_no_data_found THEN
        FND_MESSAGE.set_name('FEM','FEM_INTF_VALIDATE_SUCC');
        FND_FILE.put_line(FND_FILE.OUTPUT, FND_MESSAGE.get);
        FND_FILE.put_line(FND_FILE.OUTPUT,null);

        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTF_VALIDATE_SUCC');
     END IF;

  IF pc_log_level_procedure >= pv_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure,
        p_module   => vc_module,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_202',
        p_token1   => 'FUNC_NAME',
        p_value1   => vc_module ,
        p_token2   => 'TIME',
        p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  END IF;

  --
  -- Bug 5398129 hkaniven start
  --
  -- End the concurrent program with the 'WARNING' 'ERROR' or 'NORMAL' status
  --
  IF v_no_data_found THEN
    v_dummy_boolean := FND_CONCURRENT.Set_Completion_Status
                      (status => 'WARNING', message => NULL);
  ELSIF v_invalid_dims_found THEN
    v_dummy_boolean := FND_CONCURRENT.Set_Completion_Status
                      (status => 'ERROR', message => NULL);
  ELSE
    v_dummy_boolean := FND_CONCURRENT.Set_Completion_Status
                      (status => 'NORMAL', message => NULL);
  END IF;
  -- Bug 5398129 hkaniven end

EXCEPTION
    WHEN FEM_PGM_fatal_err THEN
      ROLLBACK;

      IF pc_log_level_procedure >= pv_log_current_level THEN
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_procedure,
           p_module   => vc_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_GL_POST_203',
           p_token1   => 'FUNC_NAME',
           p_value1   => vc_module,
           p_token2   => 'TIME',
           p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
      END IF;

      v_dummy_boolean := FND_CONCURRENT.Set_Completion_Status
                          (status => 'ERROR', message => NULL);
    WHEN OTHERS THEN
      ROLLBACK;

      IF pc_log_level_unexpected >= pv_log_current_level THEN
        FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => vc_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);
      END IF;

      FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

      IF pc_log_level_procedure >= pv_log_current_level THEN
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_procedure,
           p_module   => vc_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_GL_POST_203',
           p_token1   => 'FUNC_NAME',
           p_value1   => vc_module,
           p_token2   => 'TIME',
           p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
      END IF;

      v_dummy_boolean := FND_CONCURRENT.Set_Completion_Status
                          (status => 'ERROR', message => NULL);
END Main;

-- ======================================================================
-- Procedure
--    Validate_Dims
--
-- Purpose
--   This routine will first move interface records into a global
--   temporary table (FEM_SOURCE_DATA_INTERIM_GT), run dimension validation
--   and mark interface records with invalid dimension information.
--   Records will be marked as long as one or more dimension columns are
--   found to contain invalid dimension members.
--
-- Arguments
--    x_completion_code    : Returning status of the routine
--
-- History
--   04-11-06  Harikiran   Bug 5106205 - Shouldn't filter on STATUS='LOAD'
--   07-18-06  Harikiran   Bug 5398129 - No_data_found case will show up a
--                                        new message and end with a 'WARNING'
--					  status and Invalid Dimensions found
--					  case will end with a 'ERROR'
-- ======================================================================

PROCEDURE Validate_Dims (
  x_completion_code       OUT NOCOPY  NUMBER
) IS
  vc_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_intf_dim_validation_pkg.validate_dims';

  v_dim_grp_size             NUMBER;
  v_curr_dim_count           NUMBER;
  v_return_status            VARCHAR2(1);
  v_dynamic_sql              VARCHAR2(30000);
  v_dummy1_sql               VARCHAR2(30000);
  v_dummy2_sql               VARCHAR2(30000);
  v_dummy3_sql               VARCHAR2(30000);
  v_dummy4_sql               VARCHAR2(30000);
  v_insert_interim_sql       VARCHAR2(30000);
  v_update_interim_error_sql VARCHAR2(30000);
  v_insert_target_sql        VARCHAR2(30000);

  FEM_INTF_INV_DIM_INFO      EXCEPTION;
  FEM_PGM_FATAL_ERR          EXCEPTION;
  v_completion_code          NUMBER;
  v_count                    NUMBER;

BEGIN

  IF pc_log_level_procedure >= pv_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure,
        p_module   => vc_module,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_201',
        p_token1   => 'FUNC_NAME',
        p_value1   => vc_module ,
        p_token2   => 'TIME',
        p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  END IF;

  x_completion_code := 0;

  --
  -- Populate dimension information into the PLSQL table
  --
  populate_dim_info(
     x_completion_code => v_completion_code);

  --
  -- Build SQL to insert into the interim table
  --

  -- for x_insert_interim_sql
  -- Bug 5106205 hkaniven start

  v_insert_interim_sql :=
    'INSERT INTO fem_source_data_interim_gt (INTERFACE_ROWID)
     SELECT rowid
     FROM '||pv_interface_table_name ||
     ' WHERE calp_dim_grp_display_code = '''||pv_time_dim_grp_dc||''''
    ||' AND cal_period_end_date = TO_DATE('''
              ||TO_CHAR(pv_cal_per_end_date, pc_date_format)
              ||''','''||pc_date_format||''')'
    ||' AND cal_period_number = '||TO_CHAR(pv_cal_per_number)
    ||' AND source_system_display_code = '''||pv_source_system_dc||''''
    ||' AND dataset_display_code = '''||pv_dataset_dc||''''
    ||' AND ledger_display_code = '''||pv_ledger_dc||''''
    ||' AND ROWNUM <= '|| pv_num_rows;

  -- Bug 5106205 hkaniven end

  -- Step 1:
  -- Copy rowid to interim table

  IF pc_log_level_statement >= pv_log_current_level THEN
     FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => pc_log_level_statement,
        p_module   => vc_module,
        p_msg_text => 'SQL to insert interim table is '||v_insert_interim_sql);
  END IF;

  EXECUTE IMMEDIATE v_insert_interim_sql;

  -- Bug 5398129 hkaniven start
  IF SQL%ROWCOUNT = 0 THEN
     FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => pc_log_level_statement,
        p_module   => vc_module,
        p_msg_name => 'FEM_INTF_NO_DATA_FOUND' );

     FEM_ENGINES_PKG.User_Message
     (p_app_name => 'FEM',
      p_msg_name => 'FEM_INTF_NO_DATA_FOUND');

     x_completion_code := 1;

     RETURN;
  END IF;
  -- Bug 5398129 hkaniven end

  -- Step 2:
  -- Update interim table with dimension value

  v_dim_grp_size := to_number(FND_PROFILE.Value('FEM_LOADER_DIM_GRP_SIZE'));

  IF nvl(v_dim_grp_size,0) <= 0 THEN
     v_dim_grp_size := pc_default_dim_grp_size;
  ELSIF nvl(v_dim_grp_size,0) > pv_num_dims THEN
     v_dim_grp_size := pv_num_dims;
  END IF;

  IF pc_log_level_statement >= pv_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => pc_log_level_statement,
      p_module   => vc_module,
      p_msg_text => 'Dimension grouping size is '||v_dim_grp_size);
  END IF;

  v_curr_dim_count := 1;

  --
  -- Sample v_dynamic_sql for the first five dimensions of 'FEM_CHECKING' table
  --
  -- UPDATE
  --  fem_source_data_interim_gt g
  --  SET
  --  (
  --      g.DIM1,
  --      g.DIM2,
  --      g.DIM3,
  --      g.DIM4,
  --      g.DIM5
  --  )
  --  =
  --  (
  --  SELECT
  --      d1.CURRENCY_CODE,
  --      d2.FLAG_CODE,
  --      d3.FLAG_CODE,
  --      d4.FLAG_CODE,
  --      d5.FLAG_CODE
  --  FROM FEM_CHECKING_T i,
  --     FEM_CURRENCIES_VL d1,
  --      FEM_FLAGS_B d2,
  --      FEM_FLAGS_B d3,
  --      FEM_FLAGS_B d4,
  --      FEM_FLAGS_B d5
  --  WHERE i.rowid=g.interface_rowid
  --      AND d1.CURRENCY_CODE(+)=i.CURRENCY_CODE
  --      AND d1.personal_flag(+)='N'
  --      AND d2.FLAG_CODE(+)=i.ATM_CARD_FLG
  --      AND d2.personal_flag(+)='N'
  --      AND d3.FLAG_CODE(+)=i.CREDIT_LINE_FLG
  --      AND d3.personal_flag(+)='N'
  --      AND d4.FLAG_CODE(+)=i.EMBEDDED_OPTIONS_FLG
  --      AND d4.personal_flag(+)='N'
  --      AND d5.FLAG_CODE(+)=i.JOINT_ACCOUNT_FLG
  --      AND d5.personal_flag(+)='N'
  --  )
  --
  --

  FOR v_dim_index IN 1..pv_num_dims LOOP
    IF v_curr_dim_count = 1 THEN
      v_dynamic_sql := 'UPDATE fem_source_data_interim_gt g SET (';
      v_dummy1_sql  := '(SELECT ';
      v_dummy2_sql  := ' FROM '||pv_interface_table_name||' i';
      v_dummy3_sql  := ' WHERE i.rowid=g.interface_rowid';
    END IF;

    -- UPDATE SET clause
    v_dynamic_sql := v_dynamic_sql||'g.DIM'||to_char(v_dim_index);

    -- SELECT clause (dimension ID lookup)
    -- Explicitly convert the data type of the member col to
    -- that of the DIMx columns (VARCHAR2) where necessary.

    IF pv_xdim_info_tbl(v_dim_index).target_col_data_type = 'NUMBER' THEN
       v_dummy1_sql := v_dummy1_sql||'to_char(d'||to_char(v_dim_index)||'.'
                       ||pv_xdim_info_tbl(v_dim_index).member_col||')';
    ELSIF pv_xdim_info_tbl(v_dim_index).target_col_data_type = 'DATE' THEN
       v_dummy1_sql := v_dummy1_sql||'to_char(d'||to_char(v_dim_index)||'.'
                       ||pv_xdim_info_tbl(v_dim_index).member_col
                       ||','''||pc_date_format||''')';
    ELSE
       v_dummy1_sql := v_dummy1_sql||'d'||to_char(v_dim_index)||'.'
                       ||pv_xdim_info_tbl(v_dim_index).member_col;
    END IF;

    -- FROM clause
    v_dummy2_sql := v_dummy2_sql||', '
                    ||pv_xdim_info_tbl(v_dim_index).member_b_table_name
                    ||' d'||to_char(v_dim_index);

    -- WHERE clause
    -- match display codes
    v_dummy3_sql := v_dummy3_sql||' AND d'||to_char(v_dim_index)||'.'
                   ||pv_xdim_info_tbl(v_dim_index).member_disp_code_col||'(+)'
                   ||'=i.'||pv_xdim_info_tbl(v_dim_index).int_disp_code_col;
    -- make sure personal flag is N
    v_dummy3_sql := v_dummy3_sql
                   ||' AND d'||to_char(v_dim_index)||'.'||'personal_flag(+)=''N''';
    -- if dimension has value set associated with it, make sure
    -- it matches with the value set tied to the global value set combo

    IF pv_xdim_info_tbl(v_dim_index).vs_id IS NOT NULL THEN
      v_dummy3_sql := v_dummy3_sql||' AND d'||to_char(v_dim_index)||'.'
                     ||'value_set_id(+)'
                     ||'='||to_char(pv_xdim_info_tbl(v_dim_index).vs_id);
    END IF;

    -- Execute the update statement when number of dimenions reach
    -- dimension group size

    IF v_curr_dim_count = v_dim_grp_size OR v_dim_index = pv_num_dims THEN

      v_dynamic_sql := v_dynamic_sql||')='||v_dummy1_sql||v_dummy2_sql
                      ||v_dummy3_sql||')';

      IF pc_log_level_statement >= pv_log_current_level THEN
         FEM_ENGINES_PKG.TECH_MESSAGE(
           p_severity => pc_log_level_statement,
           p_module   => vc_module,
           p_msg_text => 'SQL to update interim table '||v_dynamic_sql);
      END IF;

      EXECUTE IMMEDIATE v_dynamic_sql;
      -- Reset the dimension group counter after update statement executes
      v_curr_dim_count := 1;

      -- Commit to release any reserved rollback space.
      COMMIT;
    ELSE
      v_curr_dim_count := v_curr_dim_count+1;
      v_dynamic_sql := v_dynamic_sql||', ';
      v_dummy1_sql  := v_dummy1_sql||', ';
    END IF;
  END LOOP;

  --
  -- Build a dyanamic sql to insert only those rowids which are there in the interim
  -- table and which have invalid dimension information into the fem_interface_fact_errs
  -- table
  --

  --
  -- Sample SQL statement for the first five dimensions of the 'FEM_CHECKING' table
  --
  -- INSERT
  -- INTO FEM_INTERFACE_FACT_ERRS
  --  (
  --      request_id,
  --      interface_rowid,
  --      interface_table_name,
  --      error_code
  -- )
  -- SELECT
  --  3119007,
  --  interface_rowid,
  --  'FEM_CHECKING_T',
  --  DECODE(gt.dim1, NULL,DECODE(t.CURRENCY_CODE, NULL,'0','1'),'0')
  --   || DECODE(gt.dim2, NULL,DECODE(t.ATM_CARD_FLG, NULL,'0','1'),'0')
  --   || DECODE(gt.dim3, NULL,DECODE(t.CREDIT_LINE_FLG, NULL,'0','1'),'0')
  --   || DECODE(gt.dim4, NULL,DECODE(t.EMBEDDED_OPTIONS_FLG, NULL,'0','1'),'0')
  --   || DECODE(gt.dim5, NULL,DECODE(t.JOINT_ACCOUNT_FLG, NULL,'0','1'),'0')
  -- FROM fem_source_data_interim_gt gt,
  --     FEM_CHECKING_T t
  -- WHERE gt.interface_rowid = t.rowid
  --     AND RPAD('0',5,'0') <>
  --                 DECODE(gt.dim1, NULL,DECODE(t.CURRENCY_CODE, NULL,'0','1'),'0')
  --                 || DECODE(gt.dim2, NULL,DECODE(t.ATM_CARD_FLG, NULL,'0','1'),'0')
  --                 || DECODE(gt.dim3, NULL,DECODE(t.CREDIT_LINE_FLG, NULL,'0','1'),'0')
  --                 || DECODE(gt.dim4, NULL,DECODE(t.EMBEDDED_OPTIONS_FLG, NULL,'0','1'),'0')
  --                 || DECODE(gt.dim5, NULL,DECODE(t.JOINT_ACCOUNT_FLG, NULL,'0','1'),'0')
  --
  --

  FOR v_dim_index IN 1..pv_num_dims LOOP

    IF v_dim_index = 1 THEN
        v_dynamic_sql := 'INSERT INTO FEM_INTERFACE_FACT_ERRS(request_id, interface_rowid, interface_table_name, error_code) ';
        v_dummy1_sql := 'SELECT ' || pc_req_id || ', interface_rowid, '
                         || '''' || pv_interface_table_name || '''' || ', ';
        v_dummy2_sql := 'FROM fem_source_data_interim_gt gt, ' || pv_interface_table_name || ' t ';
        v_dummy3_sql := 'WHERE gt.interface_rowid = t.rowid '
                        || ' AND RPAD(' || '''' || '0' || '''' || ',' || pv_num_dims || ',' || '''' || '0' || '''' || ') <> ';
        v_dummy4_sql  := '';
    ELSE
        v_dummy4_sql := v_dummy4_sql || ' || ';
    END IF;

    --
    -- The error code combination is required at two places in the statement so
    -- create a separate variable to hold the error_code
    --
    v_dummy4_sql := v_dummy4_sql || ' DECODE(gt.dim'||to_char(v_dim_index)
                ||', NULL,DECODE(t.'||pv_xdim_info_tbl(v_dim_index).int_disp_code_col
                ||', NULL,''0'',''1''),''0'') ';

  END LOOP;
  v_dummy1_sql := v_dummy1_sql || v_dummy4_sql;
  v_dummy3_sql := v_dummy3_sql || v_dummy4_sql;

  v_dynamic_sql := v_dynamic_sql || v_dummy1_sql || v_dummy2_sql || v_dummy3_sql;

  IF pc_log_level_statement >= pv_log_current_level THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => pc_log_level_statement,
          p_module   => vc_module,
          p_msg_text => 'SQL to insert target table error_code column is ');
  END IF;

  v_count := 1;
  LOOP
      IF pc_log_level_statement >= pv_log_current_level THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => pc_log_level_statement,
          p_module   => vc_module,
          p_msg_text => substr(v_dynamic_sql,v_count,255));
      END IF;

     EXIT WHEN LENGTH(v_dynamic_sql) < v_count ;
     v_count := v_count + 255;
  END LOOP;

  EXECUTE IMMEDIATE v_dynamic_sql;

  -- Bug 5398129 hkaniven start

  IF SQL%ROWCOUNT > 0 THEN
    x_completion_code := 2;
    RAISE FEM_INTF_INV_DIM_INFO;
  END IF;

  -- Bug 5398129 hkaniven end

  COMMIT;

EXCEPTION

  WHEN FEM_INTF_INV_DIM_INFO THEN

    IF pc_log_level_exception >= pv_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_exception,
         p_module   => vc_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTF_INV_DIM_INFO');
    END IF;

    FEM_ENGINES_PKG.User_Message
     (p_app_name => 'FEM',
      p_msg_name => 'FEM_INTF_INV_DIM_INFO');

    IF pc_log_level_procedure >= pv_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
        ( p_severity => pc_log_level_procedure,
          p_module   => vc_module,
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_202',
          p_token1   => 'FUNC_NAME',
          p_value1   => vc_module ,
          p_token2   => 'TIME',
          p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    END IF;

    RETURN;

  WHEN OTHERS THEN
    ROLLBACK;
    IF pc_log_level_unexpected >= pv_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => vc_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);
    END IF;

    FEM_ENGINES_PKG.User_Message
     (p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_215',
      p_token1   => 'ERR_MSG',
      p_value1   => SQLERRM);

    IF pc_log_level_unexpected >= pv_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => vc_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => vc_module,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    END IF;

    -- Bug 5398129 hkaniven start
    x_completion_code := 3;
    -- Bug 5398129 hkaniven end

    RETURN;

END Validate_Dims;

-- ======================================================================
-- Procedure
--     Populate_Dim_Info
-- Purpose
--     This routine will run a set of queries that populate the following
--     information about each dimension column in the selected PLSQL table:
--         Interface display code column
--         Dimension value set ID
--         Dimension member_B table name
--         Dimension member column name
--         Dimension member display code column name
--         Target column data type
--         Target column name
--
-- Arguments
--    x_completion_code    : Returning status of the rountine
-- ======================================================================

PROCEDURE Populate_Dim_Info (
  x_completion_code       OUT NOCOPY  NUMBER
) IS
  vc_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_intf_dim_validation_pkg.populate_dim_info';

  v_gvsc_id             NUMBER;
  v_msg_count           NUMBER;
  v_return_status       VARCHAR2(1);
  v_msg_data            VARCHAR2(4000);

  FEM_PGM_FATAL_ERR    EXCEPTION;

BEGIN

  IF pc_log_level_procedure >= pv_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure,
        p_module   => vc_module,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_201',
        p_token1   => 'FUNC_NAME',
        p_value1   => vc_module ,
        p_token2   => 'TIME',
        p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  END IF;

  x_completion_code := 0;
  pv_num_dims :=0;

  -- In case this procedure is called twice in the same session
  -- make sure to remove the previous dimension elements.
  IF pv_xdim_info_tbl.COUNT > 0 THEN
    IF pc_log_level_statement >= pv_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => vc_module,
            p_msg_text => 'pv_xdim_info_tbl is not empty.  Deleting all elements'
                   ||' to ensure a fresh start when loading new dimension info.');
    END IF;
    pv_xdim_info_tbl.DELETE;
  END IF;

  --
  -- lookup the global value set combination id tied to the ledger
  --
  v_gvsc_id := FEM_DIMENSION_UTIL_PKG.GLOBAL_VS_COMBO_ID
            (p_encoded        => FND_API.G_FALSE,
             x_return_status  => v_return_status,
             x_msg_count      => v_msg_count,
             x_msg_data       => v_msg_data,
             p_ledger_id      => pv_ledger_id);

  IF v_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF pc_log_level_statement >= pv_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => vc_module,
            p_msg_text => 'Global Value Set Combination ID is '
              ||to_char(v_gvsc_id));
    END IF;
  ELSE
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => vc_module,
            p_msg_text => 'Could not find the Global Value Set Combination ID '
              ||'associated with the ledger');
    RAISE FEM_PGM_FATAL_ERR;
  END IF;

  --
  -- populate the dimension properties record table
  --
  BEGIN
	SELECT
	 cm.interface_column_name ,
	 xd.value_set_required_flag,
	 gv.value_set_id,
	       xd.member_b_table_name,
	       xd.member_col,
	       xd.member_display_code_col,
	       xd.member_data_type_code,
	       tc.column_name
	BULK COLLECT INTO pv_xdim_info_tbl
	FROM fem_tab_columns_v tc,
	     fem_int_column_map cm,
	     fem_xdim_dimensions xd,
	     fem_global_vs_combo_defs gv
	WHERE tc.table_name = pv_table_name
	AND tc.fem_data_type_code = 'DIMENSION'
	AND tc.column_name NOT IN
	('CREATED_BY_OBJECT_ID','LAST_UPDATED_BY_OBJECT_ID',
	 'LEDGER_ID', 'SOURCE_SYSTEM_CODE', 'DATASET_CODE')
	AND cm.target_column_name = tc.column_name
	AND cm.object_type_code = 'SOURCE_DATA_LOADER'
	AND xd.dimension_id  = tc.dimension_id
	AND xd.dimension_id  = gv.dimension_id (+)
	AND gv.global_vs_combo_id (+) = v_gvsc_id;


  EXCEPTION
    WHEN no_data_found THEN
      pv_num_dims := 0;
  END;

  pv_num_dims := SQL%ROWCOUNT;

  IF pc_log_level_statement >= pv_log_current_level THEN

    FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => vc_module,
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_214');

    FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => vc_module,
            p_msg_text => 'Number of dimenions is '
              ||to_char(pv_num_dims));
  END IF;

  IF pv_num_dims > 80 THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => pc_log_level_statement,
      p_module   => vc_module,
      p_msg_text => 'Number of dimensions for this table ('||to_number(pv_num_dims)
                  ||') exceeds the maximum number of supported dimensions (80).');
    RAISE FEM_PGM_FATAL_ERR;
  END IF;

  IF pc_log_level_procedure >= pv_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure,
        p_module   => vc_module,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_202',
        p_token1   => 'FUNC_NAME',
        p_value1   => vc_module ,
        p_token2   => 'TIME',
        p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  END IF;

EXCEPTION
  WHEN FEM_PGM_FATAL_ERR THEN

    ROLLBACK;

    IF pc_log_level_unexpected >= pv_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => vc_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => vc_module,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    END IF;

    x_completion_code := 2;

    RETURN;

  WHEN OTHERS THEN

    ROLLBACK;

    IF pc_log_level_unexpected >= pv_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => vc_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);
    END IF;

    FEM_ENGINES_PKG.User_Message
     (p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_215',
      p_token1   => 'ERR_MSG',
      p_value1   => SQLERRM);

    IF pc_log_level_unexpected >= pv_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => vc_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => vc_module,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    END IF;

    x_completion_code := 2;

    RETURN;
END Populate_Dim_Info;


-- ======================================================================
-- Procedure
--    Validate_Params
--
-- Purpose
--    This is the routine that validate program parameters and set
--    package level variables used throughout the program.
--
--    If any of the query fails, the routine will report the SQL
--    error and return 2 as the completion code.
--
-- Arguments
--    x_completion_code : Returning status of the routine
-- ======================================================================

PROCEDURE Validate_Params (
  x_completion_code       OUT NOCOPY  NUMBER
) IS
  vc_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_intf_dim_validation_pkg.validate_params';
  v_count NUMBER := 0;
  v_cal_per_dim_grp_id     NUMBER;
  v_ledger_dim_id          NUMBER;
  v_dim_attr_id            NUMBER;
  v_dim_attr_ver_id        NUMBER;
  v_calp_hier_obj_def_id   NUMBER;
  v_calp_hier_obj_id       NUMBER;
  v_ledger_calendar_id     NUMBER;
  v_cal_per_calendar_id    NUMBER;
  v_time_dim_grp_id        NUMBER;
  v_cal_per_dim_id         NUMBER;
  v_dummy                  VARCHAR2(1);

  FEM_INTF_INVALID_LEDGER       EXCEPTION;
  FEM_INTF_INVALID_CAL_PERIOD   EXCEPTION;
  FEM_INTF_MISMATCH_CALENDAR    EXCEPTION;
  FEM_INTG_CAL_PER_NOT_IN_HIER  EXCEPTION;

  C_OBJECT_TYPE          CONSTANT VARCHAR2(18) := 'SOURCE_DATA_LOADER';
  C_TABLE_CLASSIFICATION CONSTANT VARCHAR2(17) := 'SOURCE_DATA_TABLE';


  v_object_id               FEM_OBJECT_CATALOG_B.object_id%TYPE;
  v_table_name              FEM_TABLE_CLASS_ASSIGNMT_V.table_name%TYPE;
  v_ledger_dc               FEM_LEDGERS_B.ledger_display_code%TYPE;
  v_calp_dim_grp_dc         FEM_DIMENSION_GRPS_B.dimension_group_display_code%TYPE;
  v_cal_per_end_date        FEM_CAL_PERIODS_ATTR.date_assign_value%TYPE;
  v_cal_per_number          FEM_CAL_PERIODS_ATTR.number_assign_value%TYPE;
  v_dataset_dc              FEM_DATASETS_B.dataset_display_code%TYPE;
  v_source_system_dc        FEM_SOURCE_SYSTEMS_B.source_system_display_code%TYPE;
  v_ledger_per_hier_obj_def_id  NUMBER;
  v_return_status           VARCHAR2(1);
  v_msg_count               NUMBER;
  v_msg_data                VARCHAR2(4000);

BEGIN

  IF pc_log_level_procedure >= pv_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure,
        p_module   => vc_module,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_201',
        p_token1   => 'FUNC_NAME',
        p_value1   => vc_module ,
        p_token2   => 'TIME',
        p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  END IF;

  x_completion_code := 0;

  FEM_SOURCE_DATA_LOADER_PKG.Validate_Obj_Def(
    p_api_version     => G_API_VERSION,
    p_object_type     => C_OBJECT_TYPE,
    p_obj_def_id      => pv_obj_def_id,
    x_object_id       => v_object_id,
    x_table_name      => v_table_name,
    x_msg_count       => v_msg_count,
    x_msg_data        => v_msg_data,
    x_return_status   => v_return_status);

  IF v_msg_count > 0 THEN
     FEM_SOURCE_DATA_LOADER_PKG.Get_Put_Messages (
       p_msg_count => v_msg_count,
       p_msg_data => v_msg_data);
  END IF;

  pv_table_name           := v_table_name;
  pv_interface_table_name := v_table_name||'_T';

  IF v_return_status = G_RET_STS_SUCCESS THEN
    FEM_SOURCE_DATA_LOADER_PKG.Validate_Table(
      p_api_version   => G_API_VERSION,
      p_object_type   => C_OBJECT_TYPE,
      p_table_name    => pv_table_name,
      p_table_classification => C_TABLE_CLASSIFICATION,
      x_msg_count     => v_msg_count,
      x_msg_data      => v_msg_data,
      x_return_status => v_return_status);

    IF v_msg_count > 0 THEN
      FEM_SOURCE_DATA_LOADER_PKG.Get_Put_Messages (
        p_msg_count => v_msg_count,
        p_msg_data  => v_msg_data);
    END IF;

  END IF;

  IF v_return_status = G_RET_STS_SUCCESS THEN
    FEM_SOURCE_DATA_LOADER_PKG.Validate_Ledger(
      p_api_version   => G_API_VERSION,
      p_object_type   => C_OBJECT_TYPE,
      p_ledger_id     => pv_ledger_id,
      x_ledger_dc     => v_ledger_dc,
      x_ledger_calendar_id => v_ledger_calendar_id,
      x_ledger_per_hier_obj_def_id => v_ledger_per_hier_obj_def_id,
      x_msg_count     => v_msg_count,
      x_msg_data      => v_msg_data,
      x_return_status => v_return_status);

    IF v_msg_count > 0 THEN
      FEM_SOURCE_DATA_LOADER_PKG.Get_Put_Messages (
        p_msg_count => v_msg_count,
        p_msg_data  => v_msg_data);
    END IF;

  END IF;

  IF v_return_status = G_RET_STS_SUCCESS THEN
    FEM_SOURCE_DATA_LOADER_PKG.Validate_Cal_Period(
      p_api_version                 => G_API_VERSION,
      p_object_type                 => C_OBJECT_TYPE,
      p_cal_period_id               => pv_cal_period_id,
      p_ledger_id                   => pv_ledger_id,
      p_ledger_calendar_id          => v_ledger_calendar_id,
      p_ledger_per_hier_obj_def_id  => v_ledger_per_hier_obj_def_id,
      x_calp_dim_grp_dc             => v_calp_dim_grp_dc,
      x_cal_per_end_date            => v_cal_per_end_date,
      x_cal_per_number              => v_cal_per_number,
      x_msg_count                   => v_msg_count,
      x_msg_data                    => v_msg_data,
      x_return_status               => v_return_status);

    IF v_msg_count > 0 THEN
      FEM_SOURCE_DATA_LOADER_PKG.Get_Put_Messages (
        p_msg_count => v_msg_count,
        p_msg_data => v_msg_data);
    END IF;
  END IF;

  IF v_return_status = G_RET_STS_SUCCESS THEN
    FEM_SOURCE_DATA_LOADER_PKG.Validate_Dataset(
      p_api_version    => G_API_VERSION,
      p_object_type    => C_OBJECT_TYPE,
      p_dataset_code   => pv_dataset_code,
      x_dataset_dc     => v_dataset_dc,
      x_msg_count      => v_msg_count,
      x_msg_data       => v_msg_data,
      x_return_status  => v_return_status);

    IF v_msg_count > 0 THEN
      FEM_SOURCE_DATA_LOADER_PKG.Get_Put_Messages (
        p_msg_count => v_msg_count,
        p_msg_data => v_msg_data);
    END IF;
  END IF;

  IF v_return_status = G_RET_STS_SUCCESS THEN
    FEM_SOURCE_DATA_LOADER_PKG.Validate_Source_System(
      p_api_version        => G_API_VERSION,
      p_object_type        => C_OBJECT_TYPE,
      p_source_system_code => pv_source_system_code,
      x_source_system_dc   => v_source_system_dc,
      x_msg_count          => v_msg_count,
      x_msg_data           => v_msg_data,
      x_return_status      => v_return_status);

    IF v_msg_count > 0 THEN
      FEM_SOURCE_DATA_LOADER_PKG.Get_Put_Messages (
        p_msg_count => v_msg_count,
        p_msg_data  => v_msg_data);
    END IF;
  END IF;

  --
  --  Initialize package level variables
  --
  pv_cal_per_number          := v_cal_per_number;
  pv_ledger_dc               := v_ledger_dc;
  pv_time_dim_grp_dc         := v_calp_dim_grp_dc;
  pv_cal_per_end_date        := v_cal_per_end_date;
  pv_dataset_dc              := v_dataset_dc;
  pv_source_system_dc        := v_source_system_dc;

  IF v_return_status = G_RET_STS_ERROR THEN
  	  x_completion_code := 1;
  ELSIF   v_return_status = G_RET_STS_UNEXP_ERROR THEN
      x_completion_code := 2;
  END IF;

  IF pc_log_level_procedure >= pv_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure,
        p_module   => vc_module,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_202',
        p_token1   => 'FUNC_NAME',
        p_value1   => vc_module ,
        p_token2   => 'TIME',
        p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK;

    IF pc_log_level_unexpected >= pv_log_current_level THEN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => vc_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);
    END IF;

    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

    IF pc_log_level_procedure >= pv_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
        ( p_severity => pc_log_level_procedure,
          p_module   => vc_module,
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_203',
          p_token1   => 'FUNC_NAME',
          p_value1   => vc_module ,
          p_token2   => 'TIME',
          p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    END IF;

    x_completion_code := 2;

    RETURN;

END Validate_Params;

-- ======================================================================
-- Procedure
--    Is_Number
--
-- Purpose
--    This is the procedure that validates whether a string is a valid
--    positive number or not.
--
--    It checks whether it is a valid positive number and if it is then it
--    returns that value and if not it returns NULL for the OUT parameter
--
-- Arguments
--    p_string             : String which has to be validated as a positive
--                           number
--    x_string_value       : Contains the positive number value if the string
--                           is a positive number and if not it contains NULL
-- =========================================================================

PROCEDURE Is_Number(
                    p_string        IN         VARCHAR2,
                    x_string_value  OUT NOCOPY NUMBER)
IS
 v_check VARCHAR2(10);
 vc_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_intf_dim_validation_pkg.Is_Number';

BEGIN
 v_check := 0;

  IF pc_log_level_procedure >= pv_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure,
        p_module   => vc_module,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_201',
        p_token1   => 'FUNC_NAME',
        p_value1   => vc_module ,
        p_token2   => 'TIME',
        p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  END IF;

  SELECT DECODE(REPLACE(TRANSLATE(p_string, '0123456789','0000000000'),'0',''),'',1)
  INTO v_check
  FROM dual;

  --
  -- If v_check = 1 it is a valid positive number
  --
  IF v_check = 1 THEN
     x_string_value := to_number( p_string );
  ELSE
     x_string_value := NULL;
  END IF;

  IF pc_log_level_procedure >= pv_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure,
        p_module   => vc_module,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_202',
        p_token1   => 'FUNC_NAME',
        p_value1   => vc_module ,
        p_token2   => 'TIME',
        p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_string_value := NULL;
END;

END FEM_INTF_DIM_VALIDATION_PKG;

/
