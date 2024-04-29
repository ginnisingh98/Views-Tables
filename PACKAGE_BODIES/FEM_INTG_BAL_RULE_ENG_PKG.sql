--------------------------------------------------------
--  DDL for Package Body FEM_INTG_BAL_RULE_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_INTG_BAL_RULE_ENG_PKG" AS
/* $Header: fem_intg_bal_eng.plb 120.5 2006/11/21 11:37:38 hakumar noship $ */

-- -------------------------
-- Private Package Variables
-- -------------------------

  pc_log_level_statement  CONSTANT NUMBER := FND_LOG.level_statement;
  pc_log_level_procedure  CONSTANT NUMBER := FND_LOG.level_procedure;
  pc_log_level_event      CONSTANT NUMBER := FND_LOG.level_event;
  pc_log_level_exception  CONSTANT NUMBER := FND_LOG.level_exception;
  pc_log_level_error      CONSTANT NUMBER := FND_LOG.level_error;
  pc_log_level_unexpected CONSTANT NUMBER := FND_LOG.level_unexpected;
  pc_page_line_no         CONSTANT NUMBER := 45;

  pv_page_count NUMBER;
  pv_line_count NUMBER;
  pv_curr_list  VARCHAR2(30);

  OGLEngMain_FatalErr EXCEPTION;
  OGLEngMain_NoData   EXCEPTION;

-- -------------------------------
-- Private Procedures Declarations
-- -------------------------------
  PROCEDURE Generate_Report
            (  x_completion_code   OUT NOCOPY VARCHAR2
             , p_from_period       IN         VARCHAR2
             , p_to_period         IN         VARCHAR2
             , p_effective_date    IN         VARCHAR2
             , p_bsv_range_low     IN         VARCHAR2
             , p_bsv_range_high    IN         VARCHAR2
             , p_tot_rows_inserted IN         NUMBER
             , p_tot_rows_valid    IN         NUMBER
			 , p_tot_rows_posted   IN         NUMBER);

  PROCEDURE Print_Report_Hdr;

  PROCEDURE Write_Message
            (  p_app_name     IN   VARCHAR2
			 , p_msg_name     IN   VARCHAR2
			 , p_token1       IN   VARCHAR2 DEFAULT NULL
			 , p_value1       IN   VARCHAR2 DEFAULT NULL
			 , p_trans1       IN   VARCHAR2 DEFAULT NULL
			 , p_token2       IN   VARCHAR2 DEFAULT NULL
			 , p_value2       IN   VARCHAR2 DEFAULT NULL
			 , p_trans2       IN   VARCHAR2 DEFAULT NULL
			 , p_token3       IN   VARCHAR2 DEFAULT NULL
			 , p_value3       IN   VARCHAR2 DEFAULT NULL
			 , p_trans3       IN   VARCHAR2 DEFAULT NULL
			 , p_token4       IN   VARCHAR2 DEFAULT NULL
			 , p_value4       IN   VARCHAR2 DEFAULT NULL
			 , p_trans4       IN   VARCHAR2 DEFAULT NULL
			 , p_token5       IN   VARCHAR2 DEFAULT NULL
			 , p_value5       IN   VARCHAR2 DEFAULT NULL
			 , p_trans5       IN   VARCHAR2 DEFAULT NULL
			 , p_token6       IN   VARCHAR2 DEFAULT NULL
			 , p_value6       IN   VARCHAR2 DEFAULT NULL
			 , p_trans6       IN   VARCHAR2 DEFAULT NULL
			 , p_token7       IN   VARCHAR2 DEFAULT NULL
			 , p_value7       IN   VARCHAR2 DEFAULT NULL
			 , p_trans7       IN   VARCHAR2 DEFAULT NULL
			 , p_token8       IN   VARCHAR2 DEFAULT NULL
			 , p_value8       IN   VARCHAR2 DEFAULT NULL
			 , p_trans8       IN   VARCHAR2 DEFAULT NULL
			 , p_token9       IN   VARCHAR2 DEFAULT NULL
			 , p_value9       IN   VARCHAR2 DEFAULT NULL
			 , p_trans9       IN   VARCHAR2 DEFAULT NULL);

  PROCEDURE Write_New_Line;

  PROCEDURE Write_Line
            (p_line_text IN VARCHAR2);

-- -----------------
-- Public Procedures
-- -----------------

  --
  -- Procedure
  --   Main
  -- Purpose
  --   This is the main routine of the FEM-OGL Integration Balances Rule
  --   Processing Engine program
  -- History
  --   11-12-04   L Poon      Created
  -- Arguments
  --   x_errbuf             : Output parameter required by Concurrent Manager
  --   x_retcode            : Output parameter required by Concurrent Manager
  --   p_bal_rule_obj_def_id: Balances rule version to be run
  --   p_from_period        : First period from which balances will be loaded
  --   p_to_period          : Last period from which balances will be loaded
  --   p_effective_date     : Effective date to calculate the average balances
  --   p_bsv_range_low      : First balancing segment value which balances will
  --                          be loaded
  --   p_bsv_range_high     : Last balancing segment value which balances will
  --                          be loaded
  PROCEDURE Main
             (  x_errbuf              OUT NOCOPY VARCHAR2
			  , x_retcode             OUT NOCOPY VARCHAR2
			  , p_bal_rule_obj_def_id IN         VARCHAR2
			  , p_coa_id              IN         VARCHAR2
			  , p_from_period         IN         VARCHAR2
			  , p_to_period           IN         VARCHAR2
			  , p_effective_date      IN         VARCHAR2
			  , p_bsv_range_low       IN         VARCHAR2
			  , p_bsv_range_high      IN         VARCHAR2) IS
    v_module            VARCHAR2(100);
    v_func_name         VARCHAR2(80);

    v_completion_code   NUMBER;
    v_completion_status VARCHAR2(30);
    v_return_status     BOOLEAN;

	v_effective_date    DATE;
    v_num_rows_inserted NUMBER;
    v_num_rows_deleted	NUMBER;
    v_tot_rows_inserted NUMBER;
    v_tot_rows_valid    NUMBER;
    v_tot_rows_posted   NUMBER;

    v_generate_report_flag  VARCHAR2(1);
    v_require_rollback_flag VARCHAR2(1);

    v_param_list wf_parameter_list_t;

    CURSOR req_cur IS
      SELECT TO_CHAR(REQUEST_ID) REQUEST_ID,
             PERIOD_NAME,
             TO_CHAR(CAL_PERIOD_ID) CAL_PERIOD_ID,
             LOAD_METHOD_CODE
      FROM FEM_INTG_EXEC_PARAMS_GT
      WHERE REQUEST_ID IS NOT NULL
	  AND NUM_OF_ROWS_POSTED > 0;

    v_bsv_range_low	VARCHAR2(200);
    v_bsv_range_high	VARCHAR2(200);

  BEGIN
    v_module    := 'fem.plsql.fem_intg_bal_eng.main';
    v_func_name := 'FEM_INTG_BAL_RULE_ENG_PKG.Main';

    -- Log the function entry time to FND_LOG
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    -- ---------------------------------------------------------
    -- 1. List the engine parameters and their values to FND_LOG
    -- ---------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
	   p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'p_bal_rule_obj_def_id',
       p_token2   => 'VAR_VAL',
       p_value2   => p_bal_rule_obj_def_id);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'p_from_period',
       p_token2   => 'VAR_VAL',
       p_value2   => p_from_period);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'p_to_period',
       p_token2   => 'VAR_VAL',
       p_value2   => p_to_period);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'p_effective_date',
       p_token2   => 'VAR_VAL',
       p_value2   => p_effective_date);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'p_bsv_range_low',
       p_token2   => 'VAR_VAL',
       p_value2   => p_bsv_range_low);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'p_bsv_range_high',
       p_token2   => 'VAR_VAL',
       p_value2   => p_bsv_range_high);

    -- -----------------------------
    -- 2. Initialize local variables
    -- -----------------------------
    IF p_bsv_range_low IS NOT NULL AND p_bsv_range_high IS NOT NULL THEN
      v_bsv_range_low := '''' || REPLACE(p_bsv_range_low, '''', '''''') || '''';
      v_bsv_range_high := '''' || REPLACE(p_bsv_range_high, '''', '''''') || '''';
    END IF;

    v_completion_status     := 'NORMAL';
    v_effective_date        := TO_DATE(substr(p_effective_date, 1, 10), 'YYYY/MM/DD');
    v_num_rows_inserted     := 0;
    v_tot_rows_inserted     := 0;
    v_tot_rows_valid        := 0;
    v_tot_rows_posted       := 0;
    -- Set Generate Report Flag to No i.e. indicating report should not be
    -- generated when erroring out
    v_generate_report_flag  := 'N';
    -- Set Require Rollback Flag to No i.e. indicating it doesn't need to
	-- rollback changes when erroring out
    v_require_rollback_flag := 'N';

    -- -----------------------------
    -- 3. Validate engine parameters
    -- -----------------------------
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_event,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_207');
    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_207');

    -- Initalize v_completion_code to 0 before calling the API
    v_completion_code := 0;
    FEM_GL_POST_PROCESS_PKG.Validate_OGL_Eng_Parameters
      (p_bal_rule_obj_def_id  => TO_NUMBER(p_bal_rule_obj_def_id),
       p_from_period          => p_from_period,
       p_to_period            => p_to_period,
	   p_effective_date       => v_effective_date,
       p_bsv_range_low        => p_bsv_range_low,
       p_bsv_range_high       => p_bsv_range_high,
	   x_generate_report_flag => v_generate_report_flag,
       x_completion_code      => v_completion_code);

    IF v_completion_code = 1
	THEN
      v_completion_status := 'WARNING';
    ELSIF v_completion_code = 2
	THEN
      RAISE OGLEngMain_FatalErr;
    END IF; -- IF v_completion_code = 1

    -- -----------------------------
    -- 4. Register process execution
    -- -----------------------------
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_event,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_208');
    FND_FILE.NEW_LINE(fnd_file.log);
    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_208');

    -- Reset v_completion_code to 0 before calling the API
    v_completion_code := 0;
    FEM_GL_POST_PROCESS_PKG.Register_OGL_Process_Execution
      (x_completion_code     => v_completion_code);

    IF v_completion_code = 1
	THEN
      v_completion_status := 'WARNING';
    ELSIF v_completion_code = 2
	THEN
      RAISE OGLEngMain_FatalErr;
    END IF; -- IF v_completion_code = 1

    -- -------------------------
    -- 5. Load standard balances
    -- -------------------------
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_event,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_INTG_BAL_LOAD_STD');
    FND_FILE.NEW_LINE(fnd_file.log);
    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_INTG_BAL_LOAD_STD');

    -- Reset v_completion_code to 0 before calling the API
    v_completion_code := 0;
    FEM_INTG_BAL_ENG_LOAD_PKG.Load_Std_Balances
      (x_completion_code   => v_completion_code,
	   x_num_rows_inserted => v_num_rows_inserted,
       p_bsv_range_low     => v_bsv_range_low,
       p_bsv_range_high    => v_bsv_range_high,
       p_maintain_qtd      => FEM_GL_POST_PROCESS_PKG.pv_maintain_qtd_flag);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_num_rows_inserted',
       p_token2   => 'VAR_VAL',
       p_value2   => v_num_rows_inserted);

    -- Set the total number of rows inserted
    v_tot_rows_inserted := v_num_rows_inserted;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_tot_rows_inserted',
       p_token2   => 'VAR_VAL',
       p_value2   => v_tot_rows_inserted);

    IF v_completion_code = 1
	THEN
      v_completion_status := 'WARNING';
    ELSIF v_completion_code = 2
	THEN
      RAISE OGLEngMain_FatalErr;
    END IF; -- IF v_completion_code = 1

    -- --------------------------------------------------------------------
    -- 6. Load average balances if the Include Average Balances Flag is Yes
    -- --------------------------------------------------------------------
    IF (FEM_GL_POST_PROCESS_PKG.pv_include_avg_bal = 'Y')
    THEN
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_LOAD_AVG');
      FND_FILE.NEW_LINE(fnd_file.log);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_LOAD_AVG');

      -- Reset v_completion_code to 0 before calling the API
      v_completion_code := 0;
      FEM_INTG_BAL_ENG_LOAD_PKG.Load_Avg_Balances
        (x_completion_code   => v_completion_code,
	     x_num_rows_inserted => v_num_rows_inserted,
		 p_effective_date    => v_effective_date,
         p_bsv_range_low     => v_bsv_range_low,
         p_bsv_range_high    => v_bsv_range_high);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_num_rows_inserted',
         p_token2   => 'VAR_VAL',
         p_value2   => v_num_rows_inserted);

      -- Set the total number of rows inserted
      v_tot_rows_inserted := v_tot_rows_inserted + v_num_rows_inserted;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_tot_rows_inserted',
         p_token2   => 'VAR_VAL',
         p_value2   => v_tot_rows_inserted);

      IF v_completion_code = 1
  	  THEN
        v_completion_status := 'WARNING';
      ELSIF v_completion_code = 2
  	  THEN
        RAISE OGLEngMain_FatalErr;
      END IF; -- IF v_completion_code = 1

	END IF; -- IF (FEM_GL_POST_PROCESS_PKG.pv_include_avg_bal = 'Y')

    -- ------------------------------------------------------------
    -- 9. Perform post-processing if the Currency Option is Entered
    -- ------------------------------------------------------------

    -- Bug fix 4330205: Changed to perform post-processing if the Balacne Type
	--                  Actual and the Currency Option is Entered
    IF (FEM_GL_POST_PROCESS_PKG.pv_curr_option = 'ENTERED'
	    AND FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd = 'ACTUAL')
    THEN
	  -- Perform post-processing on FEM_BAL_POST_INTERIM_GT to back out foreign
	  -- converted amounts from the functional entered balances
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_POST_PROC');
      FND_FILE.NEW_LINE(fnd_file.log);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_POST_PROC');

      -- Reset v_completion_code to 0 before calling the API
      v_completion_code := 0;
      FEM_INTG_BAL_ENG_LOAD_PKG.Load_Post_Process
        (x_completion_code   => v_completion_code);

      IF v_completion_code = 1
  	  THEN
        v_completion_status := 'WARNING';
      ELSIF v_completion_code = 2
  	  THEN
        RAISE OGLEngMain_FatalErr;
      END IF; -- IF v_completion_code = 1

    END IF; -- IF (FEM_GL_POST_PROCESS_PKG.pv_curr_option = 'ENTERED')

    -- -------------------------------------------
    -- 6.9. Remove zero-balance rows
    -- -------------------------------------------

    DELETE FROM fem_bal_post_interim_gt
    WHERE nvl(xtd_balance_e,0) = 0
    AND   nvl(xtd_balance_f,0) = 0
    AND   nvl(ytd_balance_e,0) = 0
    AND   nvl(ytd_balance_f,0) = 0
    AND   nvl(qtd_balance_e,0) = 0
    AND   nvl(qtd_balance_f,0) = 0
    AND   nvl(ptd_debit_balance_e,0) = 0
    AND   nvl(ptd_credit_balance_e,0) = 0
    AND   nvl(ytd_debit_balance_e,0) = 0
    AND   nvl(ytd_credit_balance_e,0) = 0;

    v_num_rows_deleted := SQL%ROWCOUNT;

    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_event,
        p_module   => v_module,
        p_app_name => 'FEM',
        p_msg_text => 'Removed ' || TO_CHAR(v_num_rows_deleted) ||
                      ' zero-balance rows from FEM_BAL_POST_INTERIM_GT');

    v_tot_rows_inserted := v_tot_rows_inserted - v_num_rows_deleted;

    -- -------------------------------------------
    -- 7. Check if there are any rows to be posted
    -- -------------------------------------------

    -- Bug fix 4330346: Changed to update the number of rows selected and
    --                  balances selected to 0 for each valid execution
    --                  parameter if no rows are inserted; else, update them
    --                  according to the rows inserted into the posting interim
    --                  table

    -- If there are no rows inserted i.e. no data to be posted
    IF (v_tot_rows_inserted = 0)
    THEN
      -- There are no rows inserted from OGL into the posting interim table,
	  -- so set the number of rows selected and balances selected for each
	  -- valid execution parameter to 0
      UPDATE FEM_INTG_EXEC_PARAMS_GT
         SET NUM_OF_ROWS_SELECTED = 0
           , SELECTED_PTD_DR_BAL  = 0
           , SELECTED_PTD_CR_BAL  = 0
       WHERE ERROR_CODE IS NULL
         AND REQUEST_ID IS NOT NULL;

      -- Log the number of rows updated in FEM_INTG_EXEC_PARAMS_GT
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_217',
         p_token1   => 'NUM',
         p_value1   => TO_CHAR(SQL%ROWCOUNT),
         p_token2   => 'TABLE',
         p_value2   => 'FEM_INTG_EXEC_PARAMS_GT');

      -- Raise exception to skip all posting process and jump to print the
	  -- report, perform final process logging, and exit the program with
	  -- Warning status
      Raise OGLEngMain_NoData;

    ELSE
	  -- At least one row is inserted from OGL into the posting interim table,
	  -- so find the number of rows selected and balances selected for each
	  -- valid execution parameter
	  UPDATE FEM_INTG_EXEC_PARAMS_GT param
	     SET (  NUM_OF_ROWS_SELECTED
	          , SELECTED_PTD_DR_BAL
  	          , SELECTED_PTD_CR_BAL) =
        (SELECT COUNT(*)
              , SUM(NVL(bpi.PTD_DEBIT_BALANCE_E, 0))
              , SUM(NVL(bpi.PTD_CREDIT_BALANCE_E, 0))
           FROM FEM_BAL_POST_INTERIM_GT bpi
          WHERE bpi.DATASET_CODE = param.OUTPUT_DATASET_CODE
            AND bpi.CAL_PERIOD_ID = param.CAL_PERIOD_ID)
      WHERE param.ERROR_CODE IS NULL
        AND param.REQUEST_ID IS NOT NULL;

      -- Log the number of rows updated in FEM_INTG_EXEC_PARAMS_GT
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_217',
         p_token1   => 'NUM',
         p_value1   => TO_CHAR(SQL%ROWCOUNT),
         p_token2   => 'TABLE',
         p_value2   => 'FEM_INTG_EXEC_PARAMS_GT');

    END IF;

    -- ---------------------------------------
    -- 8. Check if there are any invalid CCIDs
    -- ---------------------------------------

    -- Get the number of valid rows in the posting interim table
    SELECT COUNT(*)
    INTO   v_tot_rows_valid
    FROM  FEM_BAL_POST_INTERIM_GT
    WHERE POSTING_ERROR_FLAG = 'N';

    IF (v_tot_rows_valid = 0)
    THEN
      -- All CCIDs are not properly mapped
      -- Log the error messages
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_ALL_CCID_ERR',
         p_token1   => 'COA_NAME',
         p_value1   => FEM_GL_POST_PROCESS_PKG.pv_coa_name);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_ALL_CCID_ERR',
         p_token1   => 'COA_NAME',
         p_value1   => FEM_GL_POST_PROCESS_PKG.pv_coa_name);

      RAISE OGLEngMain_FatalErr;

    -- Bug fix 4313386: Changed to raise error if any CCID is not mapped
    -- properly regardless the execution mode
    ELSIF (v_tot_rows_inserted > v_tot_rows_valid)
    THEN
      -- There is at least one CCIDs not properly mapped
      -- Log the error messags
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_SNAP_CCID_ERR',
         p_token1   => 'COA_NAME',
         p_value1   => FEM_GL_POST_PROCESS_PKG.pv_coa_name);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_SNAP_CCID_ERR',
         p_token1   => 'COA_NAME',
         p_value1   => FEM_GL_POST_PROCESS_PKG.pv_coa_name);

      RAISE OGLEngMain_FatalErr;
    END IF; -- IF (v_tot_rows_valid = 0)

    -- -----------------------------------------------------------------------
    -- 10. Perform advanced Line Item and Financial Element Mappings if needed
    -- -----------------------------------------------------------------------
	IF (FEM_GL_POST_PROCESS_PKG.pv_adv_li_fe_mappings_flag = 'Y')
	THEN
	  -- Override the default Line Item and Financial Element dimension mappings
	  -- based on the Natural Account dimension
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_MAP_ADV_LI_FE');
      FND_FILE.NEW_LINE(fnd_file.log);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_MAP_ADV_LI_FE');

      -- Reset v_completion_code to 0 before calling the API
      v_completion_code := 0;
      FEM_INTG_BAL_ENG_LOAD_PKG.Map_Adv_LI_FE
        (x_completion_code   => v_completion_code);

      IF v_completion_code = 1
  	  THEN
        v_completion_status := 'WARNING';
      ELSIF v_completion_code = 2
  	  THEN
        RAISE OGLEngMain_FatalErr;
      END IF; -- IF v_completion_code = 1

	END IF; -- IF (FEM_GL_POST_PROCESS_PKG.pv_adv_li_fe_mappings_flag = 'Y')

	-- Set up a save point before inserting/updating tables other than the
	-- global temporary tables such that we can roll back to here as needed
    SAVEPOINT OGLEngSavePt;

    -- Set Require Rollback Flag to Yes i.e. indicating it needs to rollback
	-- to the save point when erroring out
	v_require_rollback_flag := 'Y';

    -- ---------------------------------------------------------------
    -- 11. Mark the posted incremental balances if the Balance Type is
	--     Actual/Encumbrance
    -- ---------------------------------------------------------------

    IF (FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd IN ('ACTUAL', 'ENCUMBRANCE'))
	THEN
	  -- Mark the posted incremental balances
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_MARK_INCR_BAL');
      FND_FILE.NEW_LINE(fnd_file.log);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_MARK_INCR_BAL');

      -- Reset v_completion_code to 0 before calling the API
      v_completion_code := 0;
      FEM_INTG_BAL_ENG_LOAD_PKG.Mark_Posted_Incr_Bal
        (x_completion_code   => v_completion_code,
         p_bsv_range_low     => v_bsv_range_low,
         p_bsv_range_high    => v_bsv_range_high);

      IF v_completion_code = 1
  	  THEN
        v_completion_status := 'WARNING';
      ELSIF v_completion_code = 2
  	  THEN
        RAISE OGLEngMain_FatalErr;
      END IF; -- IF v_completion_code = 1

	END IF;

    -- ----------------------------------------------------------
    -- 12. Post data from FEM_BAL_POST_INTERIM_GT to FEM_BALANCES
    -- ----------------------------------------------------------

    -- Posting balances into FEM
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_event,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_214');
    FND_FILE.NEW_LINE(fnd_file.log);
    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_214');

    IF (FEM_GL_POST_PROCESS_PKG.pv_stmt_type = 'INSERT')
    THEN
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'Posting in Snapshot mode');

      -- Reset v_completion_code to 0 before calling the API
      v_completion_code := 0;
       FEM_GL_POST_BAL_PKG.Post_Fem_Balances
         (p_execution_mode  => 'S',
          p_process_slice   => 'ogl',
          x_rows_posted     => v_tot_rows_posted,
          x_completion_code => v_completion_code,
          p_load_type       => 'OGL',
          p_maintain_qtd    => FEM_GL_POST_PROCESS_PKG.pv_maintain_qtd_flag,
          p_bsv_range_low   => v_bsv_range_low,
          p_bsv_range_high  => v_bsv_range_high);
    ELSE
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'Posting in Incremental mode');

       FEM_GL_POST_BAL_PKG.Post_Fem_Balances
         (p_execution_mode  => 'I',
          p_process_slice   => 'ogl',
          x_rows_posted     => v_tot_rows_posted,
          x_completion_code => v_completion_code,
          p_load_type       => 'OGL',
          p_maintain_qtd    => FEM_GL_POST_PROCESS_PKG.pv_maintain_qtd_flag,
          p_bsv_range_low   => v_bsv_range_low,
          p_bsv_range_high  => v_bsv_range_high);
    END IF; -- IF (FEM_GL_POST_PROCESS_PKG.pv_stmt_type = 'INSERT')

    IF v_completion_code = 1
    THEN
      v_completion_status := 'WARNING';
    ELSIF v_completion_code = 2
    THEN
      RAISE OGLEngMain_FatalErr;
    END IF; -- IF v_completion_code = 1

    -- Bug fix 4313386: Since it has been changed to raise error if any CCID is
    -- not mapped properly regardless the execution mode, we can remove the
    -- codes to raise posting error or invalid CCID warning for incremental load

    -- -------------------
    -- 13. Generate Report
    -- -------------------
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_event,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_INTG_BAL_GENERATE_REPORT');
    FND_FILE.NEW_LINE(fnd_file.log);
    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_INTG_BAL_GENERATE_REPORT');

    -- Set Generate Report Flag to No i.e. indicating report should not be
    -- generated when erroring out
	v_generate_report_flag := 'N';

    -- Reset v_completion_code to 0 before calling the API
    v_completion_code := 0;
    Generate_Report(x_completion_code   => v_completion_code,
                    p_from_period       => p_from_period,
                    p_to_period         => p_to_period,
                    p_effective_date    => p_effective_date,
                    p_bsv_range_low     => p_bsv_range_low,
                    p_bsv_range_high    => p_bsv_range_high,
	                p_tot_rows_inserted => v_tot_rows_inserted,
	                p_tot_rows_valid    => v_tot_rows_valid,
					p_tot_rows_posted   => v_tot_rows_posted);

    IF v_completion_code = 1
    THEN
      v_completion_status := 'WARNING';
    ELSIF v_completion_code = 2
    THEN
      RAISE OGLEngMain_FatalErr;
    END IF; -- IF v_completion_code = 1

    -- ------------------------------------------------------------------------
    -- 14. Raise business event, perform final process logging, commit and exit
    -- ------------------------------------------------------------------------

    -- Raise business events to notify other CPM products that new balances have
	-- been loaded into FEM
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_event,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_INTG_BAL_RAISE_EVENT');
    FND_FILE.NEW_LINE(fnd_file.log);
    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_INTG_BAL_RAISE_EVENT');

    -- Loop for each request which has posted at least one row into FEM and
    -- raise a business event to notify other CPM products that OGL balances has
    -- been loaded into FEM
    FOR v_req IN req_cur LOOP
      -- List the request ID for raising event to FND_LOG
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_req.request_id',
         p_token2   => 'VAR_VAL',
         p_value2   => v_req.request_id);

      -- Add Request ID to the parameter list
      WF_EVENT.addparametertolist
	    (p_name          => 'REQUEST_ID',
         p_value         => v_req.request_id,
         p_parameterlist => v_param_list);

      -- Add Balance Rule Object Definition ID to the parameter list
      WF_EVENT.addparametertolist
	    (p_name          => 'BAL_RULE_OBJ_DEF_ID',
         p_value         => p_bal_rule_obj_def_id,
         p_parameterlist => v_param_list);

      -- Add Period Name to the parameter list
      WF_EVENT.addparametertolist
	    (p_name          => 'PERIOD_NAME',
         p_value         => v_req.period_name,
         p_parameterlist => v_param_list);

      -- Add Cal Period ID to the parameter list
      WF_EVENT.addparametertolist
	    (p_name          => 'CAL_PERIOD_ID',
         p_value         => v_req.cal_period_id,
         p_parameterlist => v_param_list);

      -- Add Load Method Code to the parameter list
      WF_EVENT.addparametertolist
	    (p_name          => 'LOAD_METHOD_CODE',
         p_value         => v_req.load_method_code,
         p_parameterlist => v_param_list);

      -- Add As-of Date to the parameter list
      WF_EVENT.addparametertolist
	    (p_name          => 'AS_OF_DATE',
         p_value         => p_effective_date,
         p_parameterlist => v_param_list);

      -- Add BSV Range Low to the parameter list
      WF_EVENT.addparametertolist
	    (p_name          => 'BSV_RANGE_LOW',
         p_value         => p_bsv_range_low,
         p_parameterlist => v_param_list);

      -- Add BSV Range High to the parameter list
      WF_EVENT.addparametertolist
	    (p_name          => 'BSV_RANGE_HIGH',
         p_value         => p_bsv_range_high,
         p_parameterlist => v_param_list);

      -- Add Completion Status to the parameter list
      WF_EVENT.addparametertolist
	    (p_name          => 'STATUS_CODE',
         p_value         => v_completion_status,
         p_parameterlist => v_param_list);

      -- Add Base Request Id (as opposed to pseudo-request id) to the parameter list
      WF_EVENT.addparametertolist
	    (p_name          => 'BASE_REQUEST_ID',
         p_value         => fnd_global.conc_request_id,
         p_parameterlist => v_param_list);

      -- Raise the event
      WF_EVENT.RAISE
   	    (p_event_name => 'oracle.apps.fem.oglintg.balrule.execute',
	     p_event_key  => NULL,
	     p_parameters => v_param_list);

    END LOOP; -- req_cur Loop

    -- Clean up the event parameter list if necessary
    IF (v_param_list IS NOT NULL)
    THEN
   	  v_param_list.DELETE;
    END IF;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_event,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_INTG_BAL_FINAL_LOG');
    FND_FILE.NEW_LINE(fnd_file.log);
    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_INTG_BAL_FINAL_LOG');

    IF (v_completion_status = 'WARNING')
    THEN
      -- Perform post-process logging with an warning message
      FEM_GL_POST_PROCESS_PKG.Final_OGL_Process_Logging
        (p_exec_status        => 'SUCCESS',
         p_final_message_name => 'FEM_GL_POST_206');
    ELSE
      -- Perform post-process logging
      FEM_GL_POST_PROCESS_PKG.Final_OGL_Process_Logging
        (p_exec_status        => 'SUCCESS',
         p_final_message_name => 'FEM_GL_POST_220');
    END IF; -- IF (v_completion_status = 'WARNING')

    -- Log the function exit time to FND_LOG (successful completion)
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    -- Set the concurrent program completion status before exit
    v_return_status := FND_CONCURRENT.Set_Completion_Status
                         (status => v_completion_status,
						  message => NULL);

    -- Commit the changes and exit
    Commit;

  EXCEPTION
    WHEN OGLEngMain_FatalErr THEN
      -- <<< Fatal error >>>

	  -- Check if we need to rollback to the save point before marking the
	  -- posted incremental balances and posting balances into FEM
	  IF (v_require_rollback_flag = 'Y')
	  THEN
	    Rollback To OGLEngSavePt;
	  END IF;

      -- Check if we need to generate the report
	  IF (v_generate_report_flag = 'Y')
	  THEN
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_event,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_GENERATE_REPORT');
        FND_FILE.NEW_LINE(fnd_file.log);
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_GENERATE_REPORT');

	    Generate_Report(x_completion_code   => v_completion_code,
                        p_from_period       => p_from_period,
                        p_to_period         => p_to_period,
                        p_effective_date    => p_effective_date,
                        p_bsv_range_low     => p_bsv_range_low,
                        p_bsv_range_high    => p_bsv_range_high,
		                p_tot_rows_inserted => v_tot_rows_inserted,
    	                p_tot_rows_valid    => v_tot_rows_valid,
						p_tot_rows_posted   => 0);
	  END IF;

      -- Perform post-process logging with an error message
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_FINAL_LOG');
      FND_FILE.NEW_LINE(fnd_file.log);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_FINAL_LOG');

      FEM_GL_POST_PROCESS_PKG.Final_OGL_Process_Logging
        (p_exec_status        => 'ERROR_RERUN',
         p_final_message_name => 'FEM_GL_POST_205');

      -- Set the output parameters for the concurrent program
      x_errbuf := FND_MESSAGE.Get_String('FEM', 'FEM_GL_POST_205');

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
      (p_severity  => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
      -- Set the concurrent program completion status to ERROR
      v_return_status := FND_CONCURRENT.Set_Completion_Status
                          (status  => 'ERROR',
				  		   message => NULL);
      -- Commit the changes and exit
      Commit;

    WHEN OGLEngMain_NoData THEN
      -- <<< No data to be loaded >>>

      -- Log the error messages
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_exception,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_NO_DATA');
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_NO_DATA');

      -- Generate report to list the parameters
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_GENERATE_REPORT');
      FND_FILE.NEW_LINE(fnd_file.log);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_GENERATE_REPORT');

      Generate_Report(x_completion_code   => v_completion_code,
                      p_from_period       => p_from_period,
                      p_to_period         => p_to_period,
                      p_effective_date    => p_effective_date,
                      p_bsv_range_low     => p_bsv_range_low,
                      p_bsv_range_high    => p_bsv_range_high,
		              p_tot_rows_inserted => v_tot_rows_inserted,
  	                  p_tot_rows_valid    => v_tot_rows_valid,
  			   	 	  p_tot_rows_posted   => v_tot_rows_posted);

      -- Log message to show the next step is Final Process Logging
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_FINAL_LOG');
      FND_FILE.NEW_LINE(fnd_file.log);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_FINAL_LOG');

      -- Start bug fix 5623102
      IF (FEM_GL_POST_PROCESS_PKG.pv_stmt_type = 'INSERT') THEN
      -- Bug fix 4330346: Changed to raise warning even when it is a pure
      --                  snapshot load i.e. pv_stmt_type = 'INSERT'

      -- Perform post-process logging with a warning message
      FEM_GL_POST_PROCESS_PKG.Final_OGL_Process_Logging
        (p_exec_status        => 'SUCCESS',
         p_final_message_name => 'FEM_GL_POST_206');

      -- Log the function exit time to FND_LOG (successful completion)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_202',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      -- Set the concurrent program completion status to WARNING
      v_return_status := FND_CONCURRENT.Set_Completion_Status
                          (status  => 'WARNING',
                           message => NULL);

      ELSE

            FEM_GL_POST_PROCESS_PKG.Final_OGL_Process_Logging
              (p_exec_status        => 'SUCCESS',
               p_final_message_name => 'FEM_GL_POST_220');

            -- Log the function exit time to FND_LOG (successful completion)
            FEM_ENGINES_PKG.Tech_Message
	        (p_severity => pc_log_level_procedure,
               p_module   => v_module,
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_202',
               p_token1   => 'FUNC_NAME',
               p_value1   => v_func_name,
               p_token2   => 'TIME',
               p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

            -- Set the concurrent program completion status to NORMAL
            -- Set return code to 1 for FCH data submission to use
            x_retcode := 1;
            v_return_status := FND_CONCURRENT.Set_Completion_Status
                                (status  => 'NORMAL',
                                 message => NULL);

      END IF;
      -- End bug fix 5623102

      -- Commit the changes
      Commit;

    WHEN Others THEN
      -- <<< Unexpected database exceptions >>>

      -- Rollback all the changes
      Rollback;

      -- Set the output parameters for the concurrent program
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;

      -- Log the unexpected error message
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => x_errbuf);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => x_errbuf);

      -- Log message to show the next step is Final Process Logging
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_FINAL_LOG');
      FND_FILE.NEW_LINE(fnd_file.log);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_FINAL_LOG');

      -- Perform post-process logging with an error message
      FEM_GL_POST_PROCESS_PKG.Final_OGL_Process_Logging
        (p_exec_status        => 'ERROR_RERUN',
         p_final_message_name => 'FEM_GL_POST_205');

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
      (p_severity  => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
      -- Set the concurrent program completion status to ERROR
      v_return_status := FND_CONCURRENT.Set_Completion_Status
                          (status  => 'ERROR',
						   message => NULL);
      -- Commit the changes
      Commit;

  END Main;

-- ------------------
-- Private Procedures
-- ------------------

  --
  -- Procedure
  --   Generate_Report
  -- Purpose
  --   This routine generates the FEM-OGL Integration Balances Rule
  --   Processing Engine execution report
  -- History
  --   11-19-04   L Poon      Created
  --   06-22-05   Harikiran   Bug 4394404 - Modified code so that invalid periods
  --                          related to Budget Balance Rules are reported
  -- Arguments
  --   x_completion_code    : 0 for success, 1 for warning, 2 for failure
  --   p_from_period        : First period from which balances will be loaded
  --   p_to_period          : Last period from which balances will be loaded
  --   p_effective_date     : Effective date to calculate the average balances
  --   p_bsv_range_low      : First balancing segment value which balances will
  --                          be loaded
  --   p_bsv_range_high     : Last balancing segment value which balances will
  --                          be loaded
  --   p_tot_rows_inserted  : Total number of rows inserted into the posting
  --                          interim table
  --   p_tot_rows_valid     : Total number of valid rows of the posting interim
  --                          table
  --   p_tot_rows_posted    : Total number of rows posted into FEM
  PROCEDURE Generate_Report
            (  x_completion_code   OUT NOCOPY VARCHAR2
             , p_from_period       IN         VARCHAR2
             , p_to_period         IN         VARCHAR2
			 , p_effective_date    IN         VARCHAR2
			 , p_bsv_range_low     IN         VARCHAR2
			 , p_bsv_range_high    IN         VARCHAR2
             , p_tot_rows_inserted IN         NUMBER
             , p_tot_rows_valid    IN         NUMBER
			 , p_tot_rows_posted   IN         NUMBER) IS
    v_module          VARCHAR2(100);
    v_func_name       VARCHAR2(80);

    v_line_text       VARCHAR2(1000);
    v_message         FND_NEW_MESSAGES.message_text%TYPE;
    v_dim_name        FEM_DIMENSIONS_TL.dimension_name%TYPE;
    v_ds_code         FEM_DATASETS_B.DATASET_CODE%TYPE;
    v_ds_name         FEM_DATASETS_TL.dataset_name%TYPE;
    v_registered_flag VARCHAR2(1);
    v_print_exec_list VARCHAR2(1);
    v_eff_per_num     FEM_INTG_EXEC_PARAMS_GT.effective_period_num%TYPE;

    CURSOR Cur_PerList_Line (p_errText1 IN VARCHAR2,
 	                         p_errText2 IN VARCHAR2,
                             p_errText3 IN VARCHAR2) IS
      SELECT DISTINCT
             RPAD(PERIOD_NAME, 17, ' ')
  	          || DECODE(ERROR_CODE
				  , 'INVALID_PERIOD_STATUS', p_errText1
				                             || DECODE(CAL_PERIOD_ID
											     , -1, ', ' || p_errText2
												     , '')
  	              , 'PERIOD_NOT_MAPPED'    , p_errText2
  	              , 'OTHER_DS_LOADED'      , p_errText3)
		   , EFFECTIVE_PERIOD_NUM
        FROM FEM_INTG_EXEC_PARAMS_GT
       WHERE ERROR_CODE IN
	           ('INVALID_PERIOD_STATUS', 'PERIOD_NOT_MAPPED', 'OTHER_DS_LOADED')
       ORDER BY EFFECTIVE_PERIOD_NUM;

    CURSOR Cur_DS (p_ds_dim_name IN VARCHAR2) IS
      SELECT ds.DATASET_CODE,
	         p_ds_dim_name || ' ' || ds.DATASET_NAME
        FROM FEM_DATASETS_TL ds
       WHERE ds.DATASET_CODE IN (SELECT DISTINCT OUTPUT_DATASET_CODE
                                   FROM FEM_INTG_EXEC_PARAMS_GT)
         AND ds.LANGUAGE = USERENV('LANG');

    CURSOR Cur_RegList_Line (p_ds_code  IN NUMBER,
	                         p_succText IN VARCHAR2,
	                         p_errText1 IN VARCHAR2,
 	                         p_errText2 IN VARCHAR2) IS

      SELECT '  ' || RPAD(gt.PERIOD_NAME, 17, ' ')
	              || DECODE(gt.ERROR_CODE, NULL, p_succText
			                             , 'PERIOD_GAP_EXISTS', p_errText1
	                                     , 'EXEC_LOCK_EXISTS' , p_errText2)
	      ,  DECODE(gt.ERROR_CODE, NULL, 'Y', 'N')
        FROM FEM_INTG_EXEC_PARAMS_GT gt
       WHERE (gt.REQUEST_ID IS NOT NULL
	          OR gt.ERROR_CODE IN ('PERIOD_GAP_EXISTS', 'EXEC_LOCK_EXISTS'))
         AND gt.OUTPUT_DATASET_CODE = p_ds_code
       ORDER BY gt.EFFECTIVE_PERIOD_NUM;

    CURSOR Cur_ExecList_Line (p_ds_code  IN NUMBER) IS
      SELECT '  ' || RPAD(gt.PERIOD_NAME, 17, ' ')
     	          || LPAD(TO_CHAR(NVL(gt.SELECTED_PTD_DR_BAL, '')), 16) || '  '
	              || LPAD(TO_CHAR(NVL(gt.SELECTED_PTD_CR_BAL, '')), 16) || '  '
	              || LPAD(TO_CHAR(NVL(gt.POSTED_PTD_DR_BAL, '')), 16) || '  '
	              || LPAD(TO_CHAR(NVL(gt.POSTED_PTD_CR_BAL, '')), 16)
        FROM FEM_INTG_EXEC_PARAMS_GT gt
       WHERE gt.REQUEST_ID IS NOT NULL
	     AND gt.ERROR_CODE IS NULL
         AND gt.OUTPUT_DATASET_CODE = p_ds_code
       ORDER BY gt.EFFECTIVE_PERIOD_NUM;

    CURSOR Cur_AcctList_Line IS
      SELECT SUBSTR(NVL(FND_FLEX_EXT.Get_Segs
                         ('SQLGL', 'GL#', FEM_GL_POST_PROCESS_PKG.pv_coa_id,
                          errAcct.CODE_COMBINATION_ID),
						errAcct.CODE_COMBINATION_ID), 1, 100)
        FROM (SELECT DISTINCT CODE_COMBINATION_ID
                FROM FEM_BAL_POST_INTERIM_GT gt
               WHERE gt.POSTING_ERROR_FLAG = 'Y') errAcct;

    CURSOR Cur_NoDataPerList_Line (p_ds_code  IN NUMBER) IS
      SELECT '  ' || RPAD(gt.PERIOD_NAME, 17, ' ')
        FROM FEM_INTG_EXEC_PARAMS_GT gt
       WHERE gt.REQUEST_ID IS NOT NULL
	     AND gt.ERROR_CODE IS NULL
         AND gt.OUTPUT_DATASET_CODE = p_ds_code
         AND gt.NUM_OF_ROWS_SELECTED = 0
         AND gt.LOAD_METHOD_CODE = 'S'
       ORDER BY gt.EFFECTIVE_PERIOD_NUM;

  BEGIN
    v_module    := 'fem.plsql.fem_intg_bal_eng.generate_report';
    v_func_name := 'FEM_INTG_BAL_RULE_ENG_PKG.Generate_Report';

    -- Log the function entry time to FND_LOG
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    -- -----------------------------------------------------
    -- 1. List the IN parameters and their values to FND_LOG
    -- -----------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'p_tot_rows_inserted',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(p_tot_rows_inserted));
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'p_tot_rows_valid',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(p_tot_rows_valid));
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'p_tot_rows_posted',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(p_tot_rows_posted));

    -- ---------------------------------------------------
    -- 2. Initialize package variables and local variables
    -- ---------------------------------------------------
    pv_page_count  := 0;
    pv_curr_list   := 'NONE';
    v_dim_name     := NULL;
    v_ds_name      := NULL;

    -- ---------------------------------------------------------
    -- 3. Populate the number of rows posted and balances posted
    --    by each valid request if any rows are posted
    -- ---------------------------------------------------------
    IF (p_tot_rows_posted > 0)
    THEN
      -- At least one row is posted into FEM, so find the number of rows
      -- posted and balances posted for each valid execution parameter
      UPDATE FEM_INTG_EXEC_PARAMS_GT param
         SET (  NUM_OF_ROWS_POSTED
              , POSTED_PTD_DR_BAL
              , POSTED_PTD_CR_BAL) =
          (SELECT COUNT(*)
                , SUM(NVL(bpi.PTD_DEBIT_BALANCE_E, 0))
                , SUM(NVL(bpi.PTD_CREDIT_BALANCE_E, 0))
             FROM FEM_BAL_POST_INTERIM_GT bpi
            WHERE bpi.DATASET_CODE = param.OUTPUT_DATASET_CODE
              AND bpi.CAL_PERIOD_ID = param.CAL_PERIOD_ID
			  AND bpi.POSTING_ERROR_FLAG = 'N'
			  AND NOT EXISTS
                  (SELECT 'Invalid Delta Load'
                     FROM FEM_INTG_DELTA_LOADS dl
                    WHERE dl.LEDGER_ID = bpi.LEDGER_ID
                      AND dl.DATASET_CODE = bpi.DATASET_CODE
                      AND dl.CAL_PERIOD_ID = bpi.CAL_PERIOD_ID
                      AND dl.DELTA_RUN_ID = bpi.DELTA_RUN_ID
                      AND dl.LOADED_FLAG = 'N'))
      WHERE param.ERROR_CODE IS NULL
        AND param.REQUEST_ID IS NOT NULL;

      -- Log the number of rows updated in FEM_INTG_EXEC_PARAMS_GT
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_217',
         p_token1   => 'NUM',
         p_value1   => TO_CHAR(SQL%ROWCOUNT),
         p_token2   => 'TABLE',
         p_value2   => 'FEM_INTG_EXEC_PARAMS_GT');

    END IF; -- IF (p_tot_rows_posted > 0)

    -- --------------------------------------------
    -- 4. Print the report header of the first page
    -- --------------------------------------------
    Print_Report_Hdr;

    -- ------------------------------------
    -- 5. List the passed engine parameters
    -- ------------------------------------

	-- List the name of the passed Balances Rule Version
    v_message := FND_MESSAGE.get_string('FEM', 'FEM_INTG_BAL_RULE_DEF_TXT');
    v_line_text := ' ' || RPAD(v_message, 40, ' ') || ': '
	                   || FEM_GL_POST_PROCESS_PKG.pv_rule_obj_def_name;
    Write_Line(p_line_text => v_line_text);

    -- List the From Period
    v_message := FND_MESSAGE.get_string('FEM', 'FEM_FROM_PERIOD_TXT');
    v_line_text := ' ' || RPAD(v_message, 40, ' ') || ': ' || p_from_period;
    Write_Line(p_line_text => v_line_text);

    -- List the To Period
    v_message := FND_MESSAGE.get_string('FEM', 'FEM_TO_PERIOD_TXT');
    v_line_text := ' ' || RPAD(v_message, 40, ' ') || ': ' || p_to_period;
    Write_Line(p_line_text => v_line_text);

    -- List the Period
    v_message := FND_MESSAGE.get_string('FEM', 'FEM_INTG_BAL_EFF_DATE_TXT');
    v_line_text := ' ' || RPAD(v_message, 40, ' ') || ': ' || p_effective_date;
    Write_Line(p_line_text => v_line_text);

    -- List the From BSV
    v_message := FND_MESSAGE.get_string('FEM', 'FEM_INTG_BAL_FROM_BSV_TXT');
    v_line_text := ' ' || RPAD(v_message, 40, ' ') || ': ' || p_bsv_range_low;
    Write_Line(p_line_text => v_line_text);

    -- List the To BSV
    v_message := FND_MESSAGE.get_string('FEM', 'FEM_INTG_BAL_TO_BSV_TXT');
    v_line_text := ' ' || RPAD(v_message, 40, ' ') || ': ' || p_bsv_range_high;
    Write_Line(p_line_text => v_line_text);

    -- ------------------------------------
    -- 6. List the invalid period(s) if any
    -- ------------------------------------

    -- Check if there are any invalid periods
    IF ((FEM_GL_POST_PROCESS_PKG.pv_min_valid_period_eff_num
	      <> FEM_GL_POST_PROCESS_PKG.pv_from_period_eff_num
	        OR FEM_GL_POST_PROCESS_PKG.pv_max_valid_period_eff_num
		    <> FEM_GL_POST_PROCESS_PKG.pv_to_period_eff_num)
    -- Bug 4394404 hkaniven start - Report invalid periods belonging to
    -- Budget Balances Rules
        OR
       (FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd = 'BUDGET'
           AND FEM_GL_POST_PROCESS_PKG.pv_num_rows
               <> FEM_GL_POST_PROCESS_PKG.pv_num_rows_valid))

    -- Bug 4394404 hkaniven end - Report invalid periods belonging to
    -- Budget Balances Rules

    THEN
      -- There are invalid periods, so print the error/warning message and
	  -- the invalid period list

      -- Print 2 blanks line
      Write_New_Line;
      Write_New_Line;

	  IF (FEM_GL_POST_PROCESS_PKG.pv_min_valid_period_eff_num = -1)
      THEN
        -- All periods are invalid, so print the error message
		-- FEM_INTG_BAL_NO_VALID_PER
        -- Bug fix 4170124: The message is changed and doesn't have any tockens.
        Write_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_NO_VALID_PER');

      ELSE
        -- Not all periods are invalid, so print the warning message
        -- FEM_INTG_BAL_INVALID_PER
        -- Bug fix 4170124: The message is changed and doesn't have any tockens.
        Write_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_INVALID_PER');

      END IF; -- IF (FEM_GL_POST_PROCESS_PKG.pv_min_valid_period_eff_num = -1)

      -- Print the invalid period list prompt
      Write_New_Line;
      Write_Message
	    (p_app_name => 'FEM',
	     p_msg_name => 'FEM_INTG_BAL_PER_LIST');
      Write_New_Line;

      -- Set the current list for printing is Invalid Periods
      pv_curr_list := 'INVALID_PERIODS';
      -- Check if we need to start a new page to print the list
      IF (pv_line_count <= pc_page_line_no - 2)
	  THEN
        -- Since at least 3 lines are left for this page, print Invalid Periods
		-- list header
        Write_Message
  	      (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_PER_TABLE_COLS');
        Write_Message
  	      (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_PER_TABLE_COL_LN');

   	  ELSE
        -- Since less than 3 lines are left for this page, start a new page and
        -- print the list header on the new page
		Print_Report_Hdr;

   	  END IF; -- IF (pv_line_count <= pc_page_line_no - 2)

   	  -- Open the cursor for Invalid Periods list line text
      OPEN Cur_PerList_Line
	        (FND_MESSAGE.get_string('FEM', 'FEM_INTG_BAL_PER_STATUS_ERR'),
 	         FND_MESSAGE.get_string('FEM', 'FEM_INTG_BAL_PER_UNMAPPED_ERR'),
             FND_MESSAGE.get_string('FEM', 'FEM_INTG_BAL_PER_DS_ERR'));
	  -- Loop for each line and write it to the report
      LOOP
        FETCH Cur_PerList_Line INTO v_line_text, v_eff_per_num;
        EXIT WHEN Cur_PerList_Line%NOTFOUND;
        Write_Line(v_line_text);
      END LOOP;
      -- Finish printing the list so set it back to NONE
      pv_curr_list := 'NONE';
      -- Close the cursor
      CLOSE Cur_PerList_Line;

    END IF; -- IF (pv_min_valid_period_eff_num <> pv_from_period_eff_num ...

    -- Check if there is at least one valid period
    IF (FEM_GL_POST_PROCESS_PKG.pv_min_valid_period_eff_num <> -1)
    THEN
      -- At least one valid periods exist

      -- ---------------------------------------------------------------
      -- 7. If there are at least one registered periods/datasets, check
      --      - if any data are selected for all datasets/periods
      --      - if there are any no-data-found datasets/snapshot periods
      --      - if there are any unmapped accounts and list them if any
      --        but not all
      -- ---------------------------------------------------------------

      -- Check if any period/dataset is registered successfully
      IF (FEM_GL_POST_PROCESS_PKG.pv_stmt_type IS NOT NULL)
      THEN
        -- -----------------------------------------------------------
        -- 7.1 Check if any data are selected for all datasets/periods
        -- -----------------------------------------------------------
        IF (p_tot_rows_inserted = 0)
        THEN
          -- No data are selected for all datasets/periods, so it is no need to
		  -- perform further checks and print message FEM_INTG_BAL_NO_DATA
          Write_New_Line;
          Write_New_Line;
          Write_Message
            (p_app_name => 'FEM',
             p_msg_name => 'FEM_INTG_BAL_NO_DATA');

     	ELSE
     	  -- Some data are selected, so we need to perform further checks

          -- ------------------------------------------------------------------
 	      -- 7.2 Check if there are any no-data-found datasets/snapshot periods
          -- ------------------------------------------------------------------
          BEGIN
            SELECT 'No-data-found dataset/snapshot period exists'
              INTO v_line_text
              FROM DUAL
             WHERE EXISTS (SELECT 'X'
                             FROM FEM_INTG_EXEC_PARAMS_GT
                            WHERE ERROR_CODE IS NULL
                              AND REQUEST_ID IS NOT NULL
                              AND NUM_OF_ROWS_SELECTED = 0
                              AND LOAD_METHOD_CODE = 'S');
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              -- All datasets/snapshot periods have data found for posting
              v_line_text := NULL;
          END;

          IF (v_line_text IS NOT NULL)
          THEN
            -- No-data-found datasets/snapshot periods exist

            -- Log warning message FEM_INTG_BAL_NO_DATA_PER
            FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_exception,
              p_module   => v_module,
              p_app_name => 'FEM',
              p_msg_name => 'FEM_INTG_BAL_NO_DATA_PER');
            FEM_ENGINES_PKG.User_Message
             (p_app_name => 'FEM',
              p_msg_name => 'FEM_INTG_BAL_NO_DATA_PER');

			-- Print message FEM_INTG_BAL_NO_DATA_PER to report
            Write_New_Line;
            Write_New_Line;
            Write_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_INTG_BAL_NO_DATA_PER');

            -- Set the return code to indicate warning
            x_completion_code := 1;

            -- Log that we have set x_completion_code to 1 to FND Log
            FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_statement,
              p_module   => v_module,
              p_app_name => 'FEM',
              p_msg_name => 'FEM_GL_POST_204',
              p_token1   => 'VAR_NAME',
              p_value1   => 'x_completion_code',
              p_token2   => 'VAR_VAL',
              p_value2   => x_completion_code);

          END IF;

          -- --------------------------------------------
 	      -- 7.3 Check if there are any unmapped accounts
          -- --------------------------------------------
		  IF (p_tot_rows_inserted > p_tot_rows_valid)
     	  THEN
            -- At least one unmapped account exists

            -- Print 2 blanks line
            Write_New_Line;
            Write_New_Line;

            -- Check if all accounts are unmapped
            IF (p_tot_rows_valid = 0)
            THEN
              -- Since all accounts are unmapped, we won't list all unmapped
              -- accounts and just print message FEM_INTG_BAL_ALL_CCID_ERR
              Write_Message
                (p_app_name => 'FEM',
                 p_msg_name => 'FEM_INTG_BAL_ALL_CCID_ERR',
                 p_token1   => 'COA_NAME',
                 p_value1   => FEM_GL_POST_PROCESS_PKG.pv_coa_name);

            ELSE

              -- Since only some accounts are invalid, so print error message
              -- and list the unmapped accounts

              -- Bug fix 4313386: Since it has been changed to raise error if any
              -- invalid account exists regardless the execution mode, we always
              -- print the same error message, FEM_INTG_BAL_SNAP_CCID_ERR.
              Write_Message
                (p_app_name => 'FEM',
                 p_msg_name => 'FEM_INTG_BAL_SNAP_CCID_ERR',
                 p_token1   => 'COA_NAME',
                 p_value1   => FEM_GL_POST_PROCESS_PKG.pv_coa_name);

              -- Print the unmapped account list prompt
              Write_New_Line;
              Write_Message
    	        (p_app_name => 'FEM',
                 p_msg_name => 'FEM_INTG_BAL_ACCT_LIST');
              Write_New_Line;

              -- Set the current list for printing is Unmapped Accounts
              pv_curr_list := 'UNMAPPED_ACCOUNTS';
              -- Check if we need to start a new page to print the list
              IF (pv_line_count <= pc_page_line_no - 2)
	          THEN
                -- Since at least 3 lines are left for this page, print Unmapped
  	     	    -- Accounts list header
                Write_Message
                  (p_app_name => 'FEM',
	               p_msg_name => 'FEM_INTG_BAL_ACCT_TABLE_COLS');
                Write_Message
  	              (p_app_name => 'FEM',
	               p_msg_name => 'FEM_INTG_BAL_ACCT_TABLE_COL_LN');

    	      ELSE
                -- Since less than 3 lines are left for this page, start a new
			    -- page and print the list header on the new page
                Print_Report_Hdr;

              END IF; -- IF (pv_line_count <= pc_page_line_no - 2)

   	          -- Open the cursor for Unmapped Accounts list line text
              OPEN Cur_AcctList_Line;
              -- Loop for each line and write it to the report
              LOOP
                FETCH Cur_AcctList_Line INTO v_line_text;
                EXIT WHEN Cur_AcctList_Line%NOTFOUND;
                Write_Line(v_line_text);
              END LOOP;
              -- Finish printing the list so set it back to NONE
              pv_curr_list := 'NONE';
              -- Close the cursor
              CLOSE Cur_AcctList_Line;

            END IF; -- IF (p_tot_rows_valid = 0)
          END IF; -- IF (p_tot_rows_inserted > p_tot_rows_valid)

        END IF; -- IF (p_tot_rows_inserted = 0)
      END IF; -- IF (FEM_GL_POST_PROCESS_PKG.pv_stmt_type IS NOT NULL)

      -- --------------------------------------------------
      -- 8. If there are at least one valid periods, list
	  --    registration status, no-data-found snapshot
	  --    periods, and execution summary for each Dataset
      -- --------------------------------------------------

      -- Get the name of Dataset dimension
      v_dim_name := NULL;
      v_dim_name := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                        (p_dim_id => FEM_GL_POST_PROCESS_PKG.pv_dataset_dim_id);
      IF (v_dim_name IS NULL)
      THEN
        v_dim_name := 'Dataset';
      END IF;

      OPEN Cur_DS (v_dim_name);
      -- Loop for each Dataset to list its registration statuses and execution
      -- summary
      LOOP
        FETCH Cur_DS INTO v_ds_code, v_ds_name;
        EXIT WHEN Cur_DS%NOTFOUND;

        -- Print the Dataset name
        Write_New_Line;
        Write_New_Line;
        Write_Line(v_ds_name);
        Write_New_Line;

        -- --------------------------------------------------------
        -- 8.1 List the registration status for the current Dataset
        -- --------------------------------------------------------

        -- Print the Registration Status list prompt
        Write_New_Line;
        Write_Message
          (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_REG_LIST');
        Write_New_Line;

        -- Set the current list for printing is Registration Status
        pv_curr_list := 'REG_STATUS';
        -- Check if we need to start a new page to print the list
        IF (pv_line_count <= pc_page_line_no - 2)
        THEN
          -- At least 3 lines are left for this page, so print the list header
          Write_Message
            (p_app_name => 'FEM',
             p_msg_name => 'FEM_INTG_BAL_REG_TABLE_COLS');
          Write_Message
            (p_app_name => 'FEM',
             p_msg_name => 'FEM_INTG_BAL_REG_TABLE_COL_LN');

  	    ELSE
          -- Less than 3 lines are left for this page, so start a new page and
		  -- print the list header on the new page
	      Print_Report_Hdr;

        END IF; -- IF (pv_line_count <= pc_page_line_no - 2)

        -- Open the cursor for Registration Status list line text for the
        -- current Dataset
        OPEN Cur_RegList_Line
     	       (v_ds_code,
			    FND_MESSAGE.get_string('FEM', 'FEM_INTG_BAL_REG_SUCC'),
 	            FND_MESSAGE.get_string('FEM', 'FEM_INTG_BAL_REG_GAP_ERR'),
    	        FND_MESSAGE.get_string('FEM', 'FEM_INTG_BAL_REG_LOCK_ERR'));
        -- Initialize it as not printing the execution summary
        v_print_exec_list := 'N';
        -- Loop for each line and write it to the report
        LOOP
          FETCH Cur_RegList_Line INTO v_line_text, v_registered_flag;
          EXIT WHEN Cur_RegList_Line%NOTFOUND;
          Write_Line(v_line_text);
          IF (v_registered_flag = 'Y')
          THEN
            v_print_exec_list := 'Y';
          END IF;
        END LOOP;
        -- Finish printing the list so set it back to NONE
        pv_curr_list := 'NONE';
        -- Close the cursor
        CLOSE Cur_RegList_Line;

        IF (v_print_exec_list = 'Y')
        THEN
          -- At least one periods are registered successfully for the current
		  -- Dataset

          -- ------------------------------------------------------------
          -- 8.2 List the no-data-found snapshot periods if at least one
          --     rows are inserted into the balance posting interim table
          -- ------------------------------------------------------------
          IF (p_tot_rows_inserted > 0)
          THEN
            -- Print the No-Data-Found Snapshot Periods list prompt
            Write_New_Line;
            Write_Message
              (p_app_name => 'FEM',
	           p_msg_name => 'FEM_INTG_BAL_NODATA_PER_LIST');
            Write_New_Line;

            -- Set the current list for printing is No-data-found Snapshot
			-- Periods
            pv_curr_list := 'NODATA_PERIODS';
            -- Check if we need to start a new page to print the list
            IF (pv_line_count <= pc_page_line_no - 2)
            THEN
              -- At least 3 lines are left for this page, so print the list
			  -- header
              Write_Message
                (p_app_name => 'FEM',
                 p_msg_name => 'FEM_INTG_BAL_NODA_TABLE_COLS');
              Write_Message
                (p_app_name => 'FEM',
                 p_msg_name => 'FEM_INTG_BAL_NODA_TABLE_COL_LN');

            ELSE
              -- Less than 3 lines are left for this page, so start a new page
              -- and print the list header on the new page
  	          Print_Report_Hdr;

            END IF; -- IF (pv_line_count <= pc_page_line_no - 2)

            -- Open the cursor for No-data-found Snapshot Periods list line text
            -- for the current Dataset
            OPEN Cur_NoDataPerList_Line(v_ds_code);
            -- Loop for each line and write it to the report
            LOOP
              FETCH Cur_NoDataPerList_Line INTO v_line_text;
              EXIT WHEN Cur_NoDataPerList_Line%NOTFOUND;
              Write_Line(v_line_text);
            END LOOP;
            -- Finish printing the list so set it back to NONE
            pv_curr_list := 'NONE';
            -- Close the cursor
            CLOSE Cur_NoDataPerList_Line;

          END IF; -- IF (p_tot_rows_inserted > 0)

-- Bug fix 4313353: Commented out the codes to print selected and posted amounts
/*
          -- ------------------------------------------------------
          -- 8.3 List the execution summary for the current Dataset
          -- ------------------------------------------------------

          -- Print the Execution Summary list prompt
          Write_New_Line;
          Write_Message
            (p_app_name => 'FEM',
	         p_msg_name => 'FEM_INTG_BAL_EXE_SUMMARY');
          Write_New_Line;

          -- Set the current list for printing is Execution Summary
          pv_curr_list := 'EXEC_SUMMARY';
          -- Check if we need to start a new page to print the list
          IF (pv_line_count <= pc_page_line_no - 2)
          THEN
            -- At least 3 lines are left for this page, so print the list header
            Write_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_INTG_BAL_EXE_TABLE_COLS');
            Write_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_INTG_BAL_EXE_TABLE_COL_LN');

          ELSE
            -- Less than 3 lines are left for this page, so start a new page and
		    -- print the list header on the new page
  	        Print_Report_Hdr;

          END IF; -- IF (pv_line_count <= pc_page_line_no - 2)

          -- Open the cursor for Execution Summary list line text for the
          -- current Dataset
          OPEN Cur_ExecList_Line(v_ds_code);
          -- Loop for each line and write it to the report
          LOOP
            FETCH Cur_ExecList_Line INTO v_line_text;
            EXIT WHEN Cur_ExecList_Line%NOTFOUND;
            Write_Line(v_line_text);
          END LOOP;
          -- Finish printing the list so set it back to NONE
          pv_curr_list := 'NONE';
          -- Close the cursor
          CLOSE Cur_ExecList_Line;
*/
        END IF; -- IF (v_print_exec_list = 'Y')

	  END LOOP; -- End of Dataset cursor loop
    END IF; -- IF (FEM_GL_POST_PROCESS_PKG.pv_min_valid_period_eff_num <> -1)

    -- Log the function exit time to FND_LOG (successful completion)
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  EXCEPTION
    WHEN OGLEngMain_FatalErr THEN
      -- <<< Fatal error >>>

      -- Set the return code to indicate fatal error
      x_completion_code := 2;

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    WHEN Others THEN
      -- <<< Unexpected database exceptions >>>

      -- Set the return code to indicate fatal error
      x_completion_code := 2;

      -- Log the unexpected error message
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  END Generate_Report;

  --
  -- Procedure
  --   Print_Report_Hdr
  -- Purpose
  --   This routine prints the execution report header
  -- History
  --   01-04-05   L Poon      Created
  -- Arguments
  --   None
  PROCEDURE Print_Report_Hdr IS
    v_module    VARCHAR2(100);
    v_func_name VARCHAR2(80);

    v_line_text  VARCHAR2(1000);
    v_message    VARCHAR2(1000);
  BEGIN
    v_module    := 'fem.plsql.fem_intg_bal_eng.print_report_hdr';
    v_func_name := 'FEM_INTG_BAL_RULE_ENG_PKG.Print_Report_Hdr';

    -- Log the function entry time to FND_LOG
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    -- If this is not the first page and it needs to print blanks lines before
    -- going to a new page
    IF (pv_page_count <> 0 AND pv_line_count <= pc_page_line_no)
    THEN
      FND_FILE.new_line(FND_FILE.output, (pc_page_line_no - pv_line_count + 1));
    END IF; -- IF (pv_page_count <> 0 AND pv_line_count <= pc_page_line_no)

    -- Increment the page count by 1 and set line count to 1 for a new page
    pv_page_count := pv_page_count + 1;
    pv_line_count := 1;

    -- Print 1 blank line
    FND_FILE.new_line(FND_FILE.output, 1);

    -- Set the line starting with the report date (i.e. current date)
    v_message := FND_MESSAGE.get_string('FND', 'DATE') || ': '
                  || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MM:SS');
    v_line_text := RPAD(v_message, 36, ' ');
    -- Append report title
    v_message := FND_MESSAGE.get_string('FEM', 'FEM_INTG_BAL_RPT_TITLE');
    v_line_text := v_line_text || LPAD(v_message, 48, ' ');
    -- Append page number
    v_message := FND_MESSAGE.get_string('FEM', 'FEM_INTG_BAL_PAGE_PROMPT')
	              || ' ' || TO_CHAR(pv_page_count);
    v_line_text := v_line_text || LPAD(v_message, 48, ' ');

    -- Print the report header line
    FND_FILE.put_line(FND_FILE.output, v_line_text);

    -- Print 1 blank line
    FND_FILE.new_line(FND_FILE.output, 1);

    -- Added 3 more lines
    pv_line_count := pv_line_count + 3;

    -- Check if we need to print any list header for the new page
    IF (pv_curr_list = 'INVALID_PERIODS')
    THEN
        -- We're printing the Invalid Periods list, so print its header
        Write_Message
  	      (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_PER_TABLE_COLS');
        Write_Message
  	      (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_PER_TABLE_COL_LN');
        -- Added 2 more lines
        pv_line_count := pv_line_count + 2;
    ELSIF (pv_curr_list = 'REG_STATUS')
    THEN
        -- We're printing the Registration Statuses, so print its header
        Write_Message
  	      (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_REG_TABLE_COLS');
        Write_Message
  	      (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_REG_TABLE_COL_LN');
        -- Added 2 more lines
        pv_line_count := pv_line_count + 2;
    ELSIF (pv_curr_list = 'UNMAPPED_ACCOUNTS')
    THEN
        -- We're printing the Unmapped Accounts list, so print its header
        Write_Message
  	      (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_ACCT_TABLE_COLS');
        Write_Message
  	      (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_ACCT_TABLE_COL_LN');
        -- Added 2 more lines
        pv_line_count := pv_line_count + 2;
    ELSIF (pv_curr_list = 'NODATA_PERIODS')
    THEN
        -- We're printing the No-data-found Snapshot Periods list, so print its
		-- header
        Write_Message
  	      (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_NODA_TABLE_COLS');
        Write_Message
  	      (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_NODA_TABLE_COL_LN');
        -- Added 2 more lines
        pv_line_count := pv_line_count + 2;

-- Bug fix 4313353: Commented out the codes to print Execution Summary list
--                  header
/*
    ELSIF (pv_curr_list = 'EXEC_SUMMARY')
    THEN
        -- We're printing the Execution Summary list, so print its header
        Write_Message
  	      (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_EXE_TABLE_COLS');
        Write_Message
  	      (p_app_name => 'FEM',
	       p_msg_name => 'FEM_INTG_BAL_EXE_TABLE_COL_LN');
        -- Added 2 more lines
        pv_line_count := pv_line_count + 2;
*/
    END IF;

    -- Log the function exit time to FND_LOG (successful completion)
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  EXCEPTION
    WHEN Others THEN
      -- <<< Unexpected database exceptions >>>

      -- Log the unexpected error message
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      Raise OGLEngMain_FatalErr;

  END Print_Report_Hdr;

  --
  -- Procedure
  --   Write_Message
  -- Purpose
  --   This routine write the message text to the output file. If the message
  --   length is longer than 132 i.e. the report width, it will write the text
  --   into multiple lines.
  -- History
  --   01-04-05   L Poon      Created
  -- Arguments
  --   p_app_name  Applicaiton name of the message to be written into the report
  --   p_msg_name  Name of the message to be written into the report
  --   p_token<i>  Name of <i>th message token
  --   p_value<i>  Value of <i>th message token
  --   p_trans<i>  Indicate if the translation is needed for <i>th message token
  PROCEDURE Write_Message
            (  p_app_name     IN   VARCHAR2
			 , p_msg_name     IN   VARCHAR2
			 , p_token1       IN   VARCHAR2 DEFAULT NULL
			 , p_value1       IN   VARCHAR2 DEFAULT NULL
			 , p_trans1       IN   VARCHAR2 DEFAULT NULL
			 , p_token2       IN   VARCHAR2 DEFAULT NULL
			 , p_value2       IN   VARCHAR2 DEFAULT NULL
			 , p_trans2       IN   VARCHAR2 DEFAULT NULL
			 , p_token3       IN   VARCHAR2 DEFAULT NULL
			 , p_value3       IN   VARCHAR2 DEFAULT NULL
			 , p_trans3       IN   VARCHAR2 DEFAULT NULL
			 , p_token4       IN   VARCHAR2 DEFAULT NULL
			 , p_value4       IN   VARCHAR2 DEFAULT NULL
			 , p_trans4       IN   VARCHAR2 DEFAULT NULL
			 , p_token5       IN   VARCHAR2 DEFAULT NULL
			 , p_value5       IN   VARCHAR2 DEFAULT NULL
			 , p_trans5       IN   VARCHAR2 DEFAULT NULL
			 , p_token6       IN   VARCHAR2 DEFAULT NULL
			 , p_value6       IN   VARCHAR2 DEFAULT NULL
			 , p_trans6       IN   VARCHAR2 DEFAULT NULL
			 , p_token7       IN   VARCHAR2 DEFAULT NULL
			 , p_value7       IN   VARCHAR2 DEFAULT NULL
			 , p_trans7       IN   VARCHAR2 DEFAULT NULL
			 , p_token8       IN   VARCHAR2 DEFAULT NULL
			 , p_value8       IN   VARCHAR2 DEFAULT NULL
			 , p_trans8       IN   VARCHAR2 DEFAULT NULL
			 , p_token9       IN   VARCHAR2 DEFAULT NULL
			 , p_value9       IN   VARCHAR2 DEFAULT NULL
			 , p_trans9       IN   VARCHAR2 DEFAULT NULL) IS
    v_module        VARCHAR2(100);
    v_func_name     VARCHAR2(80);

    v_token         VARCHAR2(30);
    v_value         VARCHAR2(4000);
    v_trans         BOOLEAN;

    TYPE msg_array IS VARRAY(27) OF VARCHAR2(4000);
    tokens_values   msg_array;
    v_msg_text      VARCHAR2(2000);
    v_str_buf       VARCHAR2(200);
	v_str_len       NUMBER;
	v_str_i         NUMBER;

  BEGIN
    v_module    := 'fem.plsql.fem_intg_bal_eng.write_message';
    v_func_name := 'FEM_INTG_BAL_RULE_ENG_PKG.Write_Message';

    -- Log the function entry time to FND_LOG
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    -- Set application short name and message name
    FND_MESSAGE.SET_NAME(p_app_name, p_msg_name);

    -- Load message token/value array
    tokens_values := msg_array
                      (p_token1,p_value1,p_trans1,
                       p_token2,p_value2,p_trans2,
                       p_token3,p_value3,p_trans3,
                       p_token4,p_value4,p_trans4,
                       p_token5,p_value5,p_trans5,
                       p_token6,p_value6,p_trans6,
                       p_token7,p_value7,p_trans7,
                       p_token8,p_value8,p_trans8,
                       p_token9,p_value9,p_trans9);

    -- Substitute values for tokens
    FOR i IN 1..27 LOOP
      IF (MOD(i,3) = 1)
      THEN
        v_token := tokens_values(i);
        IF (v_token IS NOT NULL)
        THEN
          v_value := tokens_values(i+1);
          IF (tokens_values(i+2) = 'Y')
          THEN
            v_trans := TRUE;
          ELSE
            v_trans := FALSE;
          END IF;
          FND_MESSAGE.SET_TOKEN(v_token,v_value,v_trans);
         ELSE
           EXIT;
         END IF; -- IF (v_token IS NOT NULL)
      END IF; -- IF (MOD(i,3) = 1)
    END LOOP;

    -- Get the message text
    v_msg_text := FND_MESSAGE.Get;

    -- Write the message text line by line into the report
    v_str_i := 1;
    WHILE (v_str_i <= LENGTHB(v_msg_text))
    LOOP
      v_str_buf := SUBSTRB(v_msg_text, v_str_i, 133);
      v_str_len := 132;

      IF (LENGTHB(v_str_buf) >= 133)
      THEN
        FOR j IN 0..132 LOOP
          IF (SUBSTRB(v_str_buf, 133 - j, 1) = ' ')
          THEN

			IF (j > 0)
            THEN
              v_str_len := 133 - j;
            END IF;

            EXIT;
          END IF;
        END LOOP;
      END IF;

      Write_Line(SUBSTRB(v_str_buf, 1, v_str_len));
      v_str_i := v_str_i + v_str_len;
    END LOOP;

    -- Log the function exit time to FND_LOG (successful completion)
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  EXCEPTION
    WHEN Others THEN
      -- <<< Unexpected database exceptions >>>

      -- Log the unexpected error message
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      Raise OGLEngMain_FatalErr;

  END Write_Message;

  --
  -- Procedure
  --   Write_New_Line
  -- Purpose
  --   This routine write a blank line to the report
  -- History
  --   01-04-05   L Poon      Created
  -- Arguments
  --   None
  PROCEDURE Write_New_Line IS
    v_module        VARCHAR2(100);
    v_func_name     VARCHAR2(80);

  BEGIN
    v_module    := 'fem.plsql.fem_intg_bal_eng.write_new_line';
    v_func_name := 'FEM_INTG_BAL_RULE_ENG_PKG.Write_New_Line';

    -- Log the function entry time to FND_LOG
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    -- Check if the line count is more than the number of lines per page
    IF (pv_line_count > pc_page_line_no)
    THEN
      -- A new page is needed to print this new line, so call Print_Report_Hdr
      -- to print the report header for the new page, set pv_line_count to 1,
      -- and increment pv_page_count by 1.
      Print_Report_Hdr;
    END IF;

    -- Write a new line to the output and increment the line count by 1
    FND_FILE.new_line(FND_FILE.output, 1);
    pv_line_count := pv_line_count + 1;

    -- Log the function exit time to FND_LOG (successful completion)
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  EXCEPTION
    WHEN Others THEN
      -- <<< Unexpected database exceptions >>>

      -- Log the unexpected error message
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      Raise OGLEngMain_FatalErr;

  END Write_New_line;

  --
  -- Procedure
  --   Write_Line
  -- Purpose
  --   This routine write a line to the report
  -- History
  --   01-04-05   L Poon      Created
  -- Arguments
  --   None
  PROCEDURE Write_Line
            (p_line_text IN VARCHAR2) IS
    v_module        VARCHAR2(100);
    v_func_name     VARCHAR2(80);

  BEGIN
    v_module    := 'fem.plsql.fem_intg_bal_eng.write_line';
    v_func_name := 'FEM_INTG_BAL_RULE_ENG_PKG.Write_Line';

    -- Log the function entry time to FND_LOG
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    -- Check if the line count is more than the number of lines per page
    IF (pv_line_count > pc_page_line_no)
    THEN
      -- A new page is needed to print this line, so call Print_Report_Hdr to
      -- print the report header for the new page, set pv_line_count to 1, and
      -- increment pv_page_count by 1.
      Print_Report_Hdr;
    END IF;

    -- Write the line text to the output and increment the line count by 1
    FND_FILE.put_line(FND_FILE.output, p_line_text);
    pv_line_count := pv_line_count + 1;

    -- Log the function exit time to FND_LOG (successful completion)
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  EXCEPTION
    WHEN Others THEN
      -- <<< Unexpected database exceptions >>>

      -- Log the unexpected error message
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      Raise OGLEngMain_FatalErr;

  END Write_line;

END FEM_INTG_BAL_RULE_ENG_PKG;

/
