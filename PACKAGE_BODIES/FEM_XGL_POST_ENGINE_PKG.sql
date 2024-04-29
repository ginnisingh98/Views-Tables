--------------------------------------------------------
--  DDL for Package Body FEM_XGL_POST_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_XGL_POST_ENGINE_PKG" AS
/* $Header: fem_xgl_post_eng.plb 120.6.12010000.2 2009/06/27 00:31:57 ghall ship $ */

/***********************************************************************
 *              PACKAGE VARIABLES                                      *
 ***********************************************************************/

   pc_log_level_statement     CONSTANT NUMBER := FND_LOG.level_statement;
   pc_log_level_procedure     CONSTANT NUMBER := FND_LOG.level_procedure;
   pc_log_level_event         CONSTANT NUMBER := FND_LOG.level_event;
   pc_log_level_error         CONSTANT NUMBER := FND_LOG.level_error;
   pc_log_level_unexpected    CONSTANT NUMBER := FND_LOG.level_unexpected;

   pv_snapshot_rows_done      BOOLEAN;
   pv_incr_marking_sql_done   BOOLEAN;
   pv_pkg_variables_reset     BOOLEAN := FALSE;
   pv_req_id_slice            NUMBER;
   pv_process_slice           VARCHAR2(50);
   pv_data_slice_predicate    VARCHAR2(32767);
   pv_partition_clause        VARCHAR2(100);
   pv_schema_name             VARCHAR2(30);
   pv_allow_dis_mbrs_flag     VARCHAR2(30);
   pv_marking_sql             VARCHAR2(32767);


/***********************************************************************
 *              PRIVATE FUNCTIONS                                      *
 ***********************************************************************/

-- ======================================================================
-- Procedure
--     Finish_Condition_String
-- Purpose
--     Shared code between Main() and Mark_Rows_For_Process(), to
--     complete the common portion of SQL that is similar between
--     the two routines.
--  History
--     05-04-04  G Hall   Bug# 3597527: Created
-- Arguments
--    x_condition_string  Comes in as a partial condition string;
--                        goes out as a complete one.
-- ======================================================================

PROCEDURE Finish_Condition_String
             (x_condition_string IN OUT NOCOPY VARCHAR2) IS

  BEGIN

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.fcs.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Finish_Condition_String',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    x_condition_string := x_condition_string ||
      ' AND cal_per_dim_grp_display_code = ''' ||
            FEM_GL_POST_PROCESS_PKG.pv_cal_per_dim_grp_dsp_cd || '''' ||
      ' AND cal_period_end_date = TO_DATE(''' ||
            TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_cal_per_end_date, 'YYYY/MM/DD HH24:MI:SS') ||
            ''', ''YYYY/MM/DD HH24:MI:SS'')' ||
      ' AND cal_period_number = TO_NUMBER(''' ||
            TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_gl_per_number) || ''')' ||
      ' AND ledger_display_code = ''' ||
            FEM_GL_POST_PROCESS_PKG.pv_ledger_dsp_cd || '''' ||
      ' AND ds_balance_type_code = ''' ||
            FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd || '''';

    IF FEM_GL_POST_PROCESS_PKG.pv_budget_dsp_cd IS NOT NULL THEN

       x_condition_string := x_condition_string ||
         ' AND budget_display_code = ''' ||
               FEM_GL_POST_PROCESS_PKG.pv_budget_dsp_cd || '''';

    ELSIF FEM_GL_POST_PROCESS_PKG.pv_enc_type_dsp_cd IS NOT NULL THEN

       x_condition_string := x_condition_string ||
         ' AND encumbrance_type_code = ''' ||
               FEM_GL_POST_PROCESS_PKG.pv_enc_type_dsp_cd || '''';
    END IF;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.fcs.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Finish_Condition_String',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  END Finish_Condition_String;


-- ======================================================================
-- Procedure
--     Mark_Rows_For_Process
-- Purpose
--    This routine will mark all records in FEM_BAL_INTERFACE_T to be
--    processed by this posting run based on the execution mode.
-- History
--    11-03-03  S Kung   Created
--    05-05-04  G Hall   Bug# 3597527: Implemented changes for
--                       multiprocessing
-- Arguments
--    p_load_set_id      The Load Set ID being processed
--    x_row_count_in_set Passes back the number of rows marked
--    x_completion_code  Completion status of the routine
-- ======================================================================

PROCEDURE Mark_Rows_For_Process
            (p_load_set_id      IN  NUMBER,
             x_row_count_in_set OUT NOCOPY NUMBER,
             x_completion_code  OUT NOCOPY NUMBER) IS

  BEGIN

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.mrfp.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Mark_Rows_For_Process',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    x_completion_code  := 0;
    x_row_count_in_set := 0;

    -- ---------------------------------------------------------------------
    -- Prepare the dynamic SQL string for marking rows to be posted by
    -- this pass.  The SQL is built once for the snapshot pass.  It is
    -- rebuilt once in the first incremental pass (for the first load
    -- set). Subsequent incremental passes for subsequent load sets
    -- will reuse the same statement with a bind variable for Load Set ID.
    -- ---------------------------------------------------------------------

    IF (NOT pv_snapshot_rows_done) OR (NOT pv_incr_marking_sql_done) THEN

      pv_marking_sql :=
        'UPDATE fem_bal_interface_t ' || pv_partition_clause ||
       ' SET posting_request_id = :req_id_slice, ' ||
            'previous_error_flag = ' ||
              'DECODE(posting_error_code, NULL, NULL, ''Y''), ' ||
            'posting_error_code = NULL ';

    END IF;

    IF NOT pv_snapshot_rows_done THEN

      -- Mark records with load_method_code of 'S'.  We ignore
      -- LOAD_SET_ID when processing the snapshot rows.

      pv_marking_sql := pv_marking_sql || 'WHERE load_method_code = ''S'' ';

      IF FEM_GL_POST_PROCESS_PKG.pv_exec_mode <> 'S' THEN

        -- For Snapshot mode, we ignore the posting_error_code because
        -- we will process everything.
        -- For Incremental and Error Reprocessing modes, we will only pick
        -- up snapshot rows marked with an error before.

        pv_marking_sql := pv_marking_sql ||
          'AND posting_error_code IS NOT NULL ';

      END IF;

    ELSIF NOT pv_incr_marking_sql_done THEN

      -- If pv_snapshot_rows_done is TRUE and this routine is called,
      -- the program is being run in either Incremental or Error
      -- Reprocessing modes.  At this point in time, all snapshot rows
      -- would have been processed so we only need to look at rows
      -- with LOAD_METHOD_CODE of 'I' for the given load set.

      pv_marking_sql := pv_marking_sql ||
        'WHERE load_set_id = :load_set_id ' ||
          'AND load_method_code = ''I'' ';

      IF FEM_GL_POST_PROCESS_PKG.pv_exec_mode = 'E' THEN

        -- For Error Reprocessing mode, we will only pick up rows
        -- marked with an error before.

        pv_marking_sql := pv_marking_sql ||
          'AND posting_error_code IS NOT NULL ';

      END IF;

    END IF;

    IF (NOT pv_snapshot_rows_done) OR (NOT pv_incr_marking_sql_done) THEN

      Finish_Condition_String(pv_marking_sql);

      pv_marking_sql := pv_marking_sql || ' AND ' || pv_data_slice_predicate;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.xgl_eng.mrfp.' || pv_process_slice,
         p_msg_text => 'pv_marking_sql: ' || pv_marking_sql);

    END IF;

    -- ---------------------------------------------------------------------
    -- Execute the dynamic SQL to mark the rows for the current pass.
    -- ---------------------------------------------------------------------

    IF NOT pv_snapshot_rows_done THEN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.xgl_eng.mrfp.' || pv_process_slice,
         p_msg_text => 'Marking snapshot rows...');

      EXECUTE IMMEDIATE pv_marking_sql
      USING pv_req_id_slice;

    ELSE

      EXECUTE IMMEDIATE pv_marking_sql
      USING pv_req_id_slice, p_load_set_id;

    END IF;

    x_row_count_in_set := SQL%ROWCOUNT;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.xgl_eng.mrfp.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_217',
       p_token1   => 'NUM',
       p_value1   => TO_CHAR(x_row_count_in_set),
       p_token2   => 'TABLE',
       p_value2   => 'FEM_BAL_INTERFACE_T');

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.mrfp.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Mark_Rows_For_Process',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN

      ROLLBACK;

      x_completion_code := 2;

      FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected,
       p_module   => 'fem.plsql.xgl_eng.mrfp.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.mrfp.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Mark_Rows_For_Process',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  END Mark_Rows_For_Process;


-- =======================================================================
-- Procedure
--    Validate_Interface_Data
-- Purpose
--    This is the routine to validate data in the interface table
-- History
--    12-03-03   W Wong   Created
--    02-02-04   S Kung   Removed redundant validation points that
--                        are now covered by the unique index.
--    05-05-04   G Hall   Bug# 3597527: Implemented changes for
--                        multiprocessing.
--    05-25-04   G Hall   Removed building of v_key_stmt dynamic SQL which
--                        is no longer used anywhere; fixed treatment
--                        of CURRENCY_CODE and CURRENCY_TYPE_CODE as members
--                        of the FEM_BALANCES processing key (by including
--                        them in the mainstream logic in the building and
--                        usage of v_key_stmt2).
--    10-27-04   G Hall   Bug# 3952885: Created new processing key dimensions
--                        string v_key_stmt3 using NVL function for use in
--                        validation #5. Modified validation SQL for #5 to
--                        also mark rows in the current load set that have
--                        "potentially" matching error rows in a previous
--                        load set.
-- Arguments
--    p_load_set_id:          Current load set ID to process
--    p_total_row_num:        Total number of rows in the load set
--    x_records_to_post_flag: Output boolean indicating if there are any
--                            records ready to be posted
--    x_num_invalid_record:   Output parameter indicating the number of
--                            invalid records found during validation
--    x_completion_code:      Completion code of the procedure.
--                            (0 for Success; 1 for Warning; 2 for Failure)
-- =======================================================================

PROCEDURE Validate_Interface_Data
            (p_load_set_id          IN             NUMBER,
             p_total_row_num        IN             NUMBER,
             x_records_to_post_flag IN OUT NOCOPY  BOOLEAN,
             x_num_invalid_record   IN OUT NOCOPY  NUMBER,
             x_completion_code      IN OUT NOCOPY  NUMBER ) IS

    FEMXGL_mix_load_method EXCEPTION;

    v_proc_snapshot_rows   VARCHAR2(1);
    v_sql_stmt             VARCHAR2(32767);
    v_key_stmt2            VARCHAR2(32767);
    v_key_stmt3            VARCHAR2(32767);
    v_first_time           VARCHAR2(1);
    v_rows_updated         NUMBER;
    v                      PLS_INTEGER;
    pv_col                 VARCHAR2(30);

  BEGIN

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.vid.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Validate_Interface_Data',
       p_token2   => 'TIME',
       p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    -- Initialize variable
    x_num_invalid_record := 0;

    IF (not pv_snapshot_rows_done) THEN
      v_proc_snapshot_rows := 'Y';
    ELSE
      v_proc_snapshot_rows := 'N';
    END IF;

    ---------------------------------------------------------------------------
    -- 1. Verify that there is only one load_method_code in the given load set.
    --    (This is only needed for Incremental and Error Reprocessing loads)
    ---------------------------------------------------------------------------

    IF (FEM_GL_POST_PROCESS_PKG.pv_exec_mode <> 'S')
          AND (v_proc_snapshot_rows = 'N') THEN
      v_sql_stmt :=
       ' UPDATE fem_bal_interface_t ' ||
       ' SET    posting_error_code = ''FEM_GL_POST_MIX_LOAD_METHOD'' ' ||
       ' WHERE  EXISTS ( SELECT 1 ' ||
       '                 FROM   fem_bal_interface_t ' ||
       '                 WHERE  posting_request_id = :pv_req_id_slice '||
       '                 AND    load_set_id = :p_load_set_id ' ||
       '                 HAVING COUNT (DISTINCT load_method_code) > 1 ) ' ||
       ' AND    posting_request_id = :pv_req_id_slice ' ||
       ' AND    load_set_id        = :p_load_set_id ';

      -- Print out sql statement for debugging purposes
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.xgl_eng.vid.1.' || pv_process_slice,
         p_msg_text => 'v_sql_stmt: ' || v_sql_stmt);

      EXECUTE IMMEDIATE v_sql_stmt
      USING pv_req_id_slice, p_load_set_id,
            pv_req_id_slice, p_load_set_id;

      -- If mixed load_method_code is found in the set, no further validation
      -- will be done for the set.  We should return with a warning status.
      IF ( SQL%ROWCOUNT > 0 ) THEN
        raise FEMXGL_mix_load_method;
      END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- Construct strings with processing keys
    --   ( processing_key_1, ...  processing_key_N )
    ---------------------------------------------------------------------------
    v_first_time := 'Y';
    v_key_stmt2  := '';
    v_key_stmt3  := '';

    FEM_ENGINES_PKG.Tech_Message
     (p_severity => pc_log_level_statement,
      p_module   => 'fem.plsql.xgl_eng.vid.' || pv_process_slice,
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_204',
      p_token1   => 'VAR_NAME',
      p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_proc_key_dim_num',
      p_token2   => 'VAR_VAL',
      p_value2   => FEM_GL_POST_PROCESS_PKG.pv_proc_key_dim_num);

    FOR v IN 1..FEM_GL_POST_PROCESS_PKG.pv_proc_key_dim_num LOOP

      IF (FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_int_disp_code_col IN
           ('CCTR_ORG_DISPLAY_CODE', 'FINANCIAL_ELEM_DISPLAY_CODE',
            'PRODUCT_DISPLAY_CODE', 'NATURAL_ACCOUNT_DISPLAY_CODE',
            'CHANNEL_DISPLAY_CODE', 'LINE_ITEM_DISPLAY_CODE', 'CURRENCY_CODE',
            'CURRENCY_TYPE_CODE', 'PROJECT_DISPLAY_CODE',
            'CUSTOMER_DISPLAY_CODE', 'SOURCE_SYSTEM_DISPLAY_CODE',
            'LEDGER_DISPLAY_CODE', 'ENTITY_DISPLAY_CODE',
            'INTERCOMPANY_DISPLAY_CODE', 'TASK_DISPLAY_CODE',
            'USER_DIM1_DISPLAY_CODE', 'USER_DIM2_DISPLAY_CODE',
            'USER_DIM3_DISPLAY_CODE', 'USER_DIM4_DISPLAY_CODE',
            'USER_DIM5_DISPLAY_CODE', 'USER_DIM6_DISPLAY_CODE',
            'USER_DIM7_DISPLAY_CODE', 'USER_DIM8_DISPLAY_CODE',
            'USER_DIM9_DISPLAY_CODE', 'USER_DIM10_DISPLAY_CODE')) THEN

        pv_col :=
          FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_int_disp_code_col;

        IF v_first_time = 'N' THEN
          v_key_stmt2 := v_key_stmt2 || ', ';
          v_key_stmt3 := v_key_stmt3 || ', ';
        ELSE
          v_first_time := 'N';
        END IF;

        v_key_stmt2 := v_key_stmt2 || pv_col;
        v_key_stmt3 := v_key_stmt3 || 'NVL(s.' || pv_col || ', u.' || pv_col || ')';

      END IF;

    END LOOP;

    FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.vid.' || pv_process_slice,
        p_msg_text => 'v_key_stmt2: ' || v_key_stmt2);

    FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.vid.' || pv_process_slice,
        p_msg_text => 'v_key_stmt3: ' || v_key_stmt3);

    ---------------------------------------------------------------------------
    -- 2. Check for duplicate rows, according to the FEM_BALANCES processing
    --    key columns combination.
    --    This check is always needed because:
    --    1) We definitely need to check this for Snapshot loads
    --    2) Incremental and Error Reprocessing loads can still pick up
    --       snapshot rows that are marked with error from a prior Snapshot
    --       load.
    ---------------------------------------------------------------------------
    IF v_proc_snapshot_rows = 'Y' THEN

       v_sql_stmt :=
          ' UPDATE fem_bal_interface_t ' ||
          ' SET posting_error_code = ''FEM_GL_POST_DUP_PROC_KEYS'' ' ||
          ' WHERE ( ' || v_key_stmt2 || ') IN' ||
          ' ( SELECT ' || v_key_stmt2 ||
          '   FROM   fem_bal_interface_t ' ||
          '   WHERE  posting_request_id = :pv_req_id_slice ' ||
          '   GROUP BY ' || v_key_stmt2 ||
          '   HAVING COUNT(*) > 1) ' ||
          ' AND posting_error_code IS NULL ' ||
          ' AND load_method_code = ''S''' ||
          ' AND posting_request_id = :pv_req_id_slice ';

       -- Print out sql statement for debugging purposes
       FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => 'fem.plsql.xgl_eng.vid.2.' || pv_process_slice,
           p_msg_text => 'v_sql_stmt: ' || v_sql_stmt);

       EXECUTE IMMEDIATE v_sql_stmt
       USING pv_req_id_slice,
             pv_req_id_slice;

       -- Keep track of how many invalid rows marked
       x_num_invalid_record := x_num_invalid_record + SQL%ROWCOUNT;

    END IF;

    ---------------------------------------------------------------------------
    -- 3. Verify that BAL_POST_TYPE_CODE, CURRENCY_TYPE_CODE are filled
    --    in and are valid.
    --    Valid values for BAL_POST_TYPE_CODE are R and A,
    --    valid values for CURRENCY_TYPE_CODE are ENTERED and TRANSLATED
    ---------------------------------------------------------------------------
    v_sql_stmt :=
     ' UPDATE fem_bal_interface_t ' ||
     ' SET    posting_error_code = ' ||
     '          DECODE(currency_type_code, ' ||
     '            ''ENTERED'', ' ||
     '              DECODE(bal_post_type_code, ''A'', NULL, ' ||
     '                 ''R'', NULL, ''FEM_GL_POST_INVALID_POST_TYPE''), ' ||
     '        ''TRANSLATED'', ' ||
     '              DECODE(bal_post_type_code, ''A'', NULL, ' ||
     '                 ''R'', NULL, ''FEM_GL_POST_INVALID_POST_TYPE''), ' ||
     '        ''FEM_GL_POST_INVALID_CURR_TYPE'') ' ||
     ' WHERE  (bal_post_type_code NOT IN (''A'', ''R'') OR ' ||
     '         currency_type_code NOT IN (''ENTERED'', ''TRANSLATED'')) ' ||
     ' AND    posting_request_id = :pv_req_id_slice ' ||
     ' AND    posting_error_code IS NULL ' ||
     ' AND    (load_set_id  = :p_load_set_id OR ' ||
     '         :p_proc_snapshot_rows = ''Y'')';

    -- Print out sql statement for debugging purposes
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.xgl_eng.vid.3.' || pv_process_slice,
       p_msg_text => 'v_sql_stmt: ' || v_sql_stmt);

    EXECUTE IMMEDIATE v_sql_stmt
    USING pv_req_id_slice, p_load_set_id,
          v_proc_snapshot_rows;

    -- Keep track of how many invalid rows marked
    x_num_invalid_record := x_num_invalid_record + SQL%ROWCOUNT;

    ---------------------------------------------------------------------------
    -- 4. Check for missing QTD/YTD values, according to the QTD-YTD parameter
    --    specification and currency_type_code.
    --    Also, check for missing _E data if pv_entered_crncy_flag is set to
    --    Y.
    ---------------------------------------------------------------------------
    v_sql_stmt :=
     ' UPDATE fem_bal_interface_t ' ||
     ' SET posting_error_code = ''FEM_GL_POST_MISSING_BAL_COL'' ';

    -- Contruct the where clause based on the QTD-YTD parameter specification
    IF (FEM_GL_POST_PROCESS_PKG.pv_qtd_ytd_code = 'ALL') THEN
      v_sql_stmt := v_sql_stmt ||
       ' WHERE ((currency_type_code = ''ENTERED'' AND ' ||
       '         (xtd_balance_f IS NULL OR qtd_balance_f IS NULL OR '||
                ' ytd_balance_f IS NULL)) OR ' ||
       '        ((currency_type_code = ''TRANSLATED'' OR ' ||
                 ':pv_entered_crncy_flag = ''Y'') AND ' ||
       '         (xtd_balance_e IS NULL OR qtd_balance_e IS NULL OR '||
                ' ytd_balance_e IS NULL))) ';

    ELSIF (FEM_GL_POST_PROCESS_PKG.pv_qtd_ytd_code = 'YTD') THEN
      v_sql_stmt := v_sql_stmt ||
       ' WHERE ((currency_type_code = ''ENTERED'' AND ' ||
       '         (xtd_balance_f IS NULL OR ytd_balance_f IS NULL)) OR '||
       '        ((currency_type_code = ''TRANSLATED'' OR ' ||
                 ':pv_entered_crncy_flag = ''Y'') AND ' ||
       '         (xtd_balance_e IS NULL OR ytd_balance_e IS NULL))) ';

    ELSIF (FEM_GL_POST_PROCESS_PKG.pv_qtd_ytd_code = 'QTD') THEN
      v_sql_stmt := v_sql_stmt ||
       ' WHERE ((currency_type_code = ''ENTERED'' AND ' ||
       '         (xtd_balance_f IS NULL OR qtd_balance_f IS NULL)) OR '||
       '        ((currency_type_code = ''TRANSLATED'' OR ' ||
                 ':pv_entered_crncy_flag = ''Y'') AND ' ||
       '         (xtd_balance_e IS NULL OR qtd_balance_e IS NULL))) ';

    ELSIF (FEM_GL_POST_PROCESS_PKG.pv_qtd_ytd_code = 'PTD') THEN
      v_sql_stmt := v_sql_stmt ||
       ' WHERE ((currency_type_code = ''ENTERED''' ||
       ' AND xtd_balance_f IS NULL) OR ' ||
       '        ((currency_type_code = ''TRANSLATED'' OR ' ||
                 ':pv_entered_crncy_flag = ''Y'') AND ' ||
       '        xtd_balance_e IS NULL)) ';

    END IF;

    v_sql_stmt := v_sql_stmt ||
       ' AND   posting_error_code IS NULL ' ||
       ' AND   posting_request_id = :pv_req_id_slice ' ||
       ' AND   (load_set_id        = :p_load_set_id OR ' ||
       ' :p_proc_snapshot_rows = ''Y'') ';

    -- Print out sql statement for debugging purposes
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.xgl_eng.vid.4.' || pv_process_slice,
       p_msg_text => 'v_sql_stmt: ' || v_sql_stmt);

    EXECUTE IMMEDIATE v_sql_stmt
    USING FEM_GL_POST_PROCESS_PKG.pv_entered_crncy_flag,
          pv_req_id_slice, p_load_set_id,
          v_proc_snapshot_rows;

    -- Keep track of how many invalid rows marked
    x_num_invalid_record := x_num_invalid_record + SQL%ROWCOUNT;

    ---------------------------------------------------------------------------
    -- 5. When validating a subsequent load set, we need to look back at errors
    --    in matching rows or potentially matching rows from previous load sets
    --    and mark the FEM_GL_POST_PREV_SET_ERROR into rows in the current load
    --    set where previous matching or potentially matching error rows are
    --    found.
    --    (This is only needed for Incremental and Error Reprocessing loads,
    --     since for Snapshot loads, everything is processed in a single
    --     shot)
    ---------------------------------------------------------------------------
    IF (FEM_GL_POST_PROCESS_PKG.pv_exec_mode <> 'S') THEN
      v_sql_stmt :=
       ' UPDATE fem_bal_interface_t u' ||
       ' SET posting_error_code = ''FEM_GL_POST_PREV_SET_ERROR'' ' ||
       ' WHERE ( ' || v_key_stmt2 || ') IN' ||
           ' ( SELECT ' || v_key_stmt3 ||
           '   FROM   fem_bal_interface_t s' ||
           '   WHERE  s.posting_error_code IS NOT NULL ' ||
           '   AND    s.posting_request_id = :pv_req_id_slice ' ||
           '   AND    s.load_set_id < :p_load_set_id ) ' ||
       ' AND u.posting_error_code IS NULL ' ||
       ' AND u.posting_request_id = :pv_req_id_slice ' ||
       ' AND u.load_set_id        = :p_load_set_id ';

      FEM_ENGINES_PKG.TECH_MESSAGE(
       p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.xgl_eng.vid.5' || pv_process_slice,
       p_msg_text => 'v_sql_stmt: ' || v_sql_stmt);

      EXECUTE IMMEDIATE v_sql_stmt
      USING pv_req_id_slice, p_load_set_id,
            pv_req_id_slice, p_load_set_id;

      -- Keep track of how many invalid rows marked
      x_num_invalid_record := x_num_invalid_record + SQL%ROWCOUNT;

    END IF;

    IF x_num_invalid_record > 0 THEN

      FEM_ENGINES_PKG.Tech_Message
       (p_severity  => pc_log_level_error,
        p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
        p_app_name  => 'FEM',
        p_msg_name  => 'FEM_GL_POST_223');

    END IF;

    -- Check if there is any record left to post
    IF ((p_total_row_num - x_num_invalid_record) > 0) THEN
      x_records_to_post_flag := TRUE;
    ELSE
      x_records_to_post_flag := FALSE;
    END IF;

    COMMIT;

    x_completion_code := 0;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.vid.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Validate_Interface_Data',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  EXCEPTION
    WHEN FEMXGL_mix_load_method THEN

      COMMIT;

      x_num_invalid_record   := p_total_row_num;
      x_records_to_post_flag := FALSE;
      x_completion_code      := 0;

      FEM_ENGINES_PKG.TECH_MESSAGE
        (p_severity => pc_log_level_error,
         p_module   => 'fem.plsql.xgl_eng.vid.' || pv_process_slice,
         p_msg_text => 'Mixed LOAD_METHOD_CODE values for load set: ' ||
                       TO_CHAR(p_load_set_id) ||
                       '. Skipping processing for this load set.');

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.vid.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Validate_Interface_Data',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    WHEN OTHERS THEN

      ROLLBACK;

      x_completion_code := 2;

      FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected,
       p_module   => 'fem.plsql.xgl_eng.vid.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.vid.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Validate_Interface_Data',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  END Validate_Interface_Data;


-- =======================================================================
-- Procedure
--     Post_To_Interim
-- Purpose
--     This routine will purge all records for the given plan type
--    in a given time period from FII_BUDGET_BASE.
-- History
--     06-20-02  S Kung   Created
--     05-05-04  G Hall   Bug# 3597527: Implemented changes for
--                        multiprocessing
--     05-25-04  G Hall   Included CURRENCY_CODE in dimensions validation and
--                        transformation (for free, at least in a coding
--                        sense -- the metadata for it is already there; only
--                        had to make CURRENCY_CODE nullable in
--                        FEM_BAL_POST_INTERIM_GT.  Fixed logic in building of
--                        dynamic SQL for dimensions transformation for when
--                        the last member of the processing key list is not
--                        really a dimension and is not included in the
--                        dimension validation/transformation (e.g.
--                        CURRENCY_TYPE_CODE).
--     06-25-09  G Hall   Bug 8543579 (FP for 11i bug 6826759/6007033):
--                        If pv_allow_dis_mbrs_flag = 'Y',
--                        exclude "and enabled_flag = 'Y'" from dimension
--                        lookkup queries.
-- Arguments
--    p_load_set_id
--    x_completion_code
--    x_nothing_to_post
--    x_prev_err_rows_reproc
--    x_cur_data_err_rows
-- =======================================================================

PROCEDURE Post_To_Interim
            (p_load_set_id          IN  NUMBER,
             x_completion_code      OUT NOCOPY NUMBER,
             x_nothing_to_post      OUT NOCOPY BOOLEAN,
             x_prev_err_rows_reproc OUT NOCOPY NUMBER,
             x_cur_data_err_rows    OUT NOCOPY NUMBER) IS

    v_proc_snapshot_rows   VARCHAR2(1);
    v_sql_stmt             VARCHAR2(32767);
    v_upd_cols             VARCHAR2(32767);
    v_sel_stmt             VARCHAR2(32767);
    v_tab_list             VARCHAR2(32767);
    v_join_stmt            VARCHAR2(32767);
    v                      NUMBER;
    v_dim_count            NUMBER;
    v_rows_ins_count       NUMBER;
    v_rows_upd_count       NUMBER;

  BEGIN

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Post_To_Interim',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    -- Initialize all output counters for this load set
    x_prev_err_rows_reproc := 0;
    x_cur_data_err_rows    := 0;
    x_completion_code      := 0;
    x_nothing_to_post      := FALSE;

    v_proc_snapshot_rows := NULL;
    v_sql_stmt  := NULL;
    v_upd_cols  := NULL;
    v_sel_stmt  := NULL;
    v_tab_list  := NULL;
    v_join_stmt := NULL;
    v_dim_count := 1;

    IF (not pv_snapshot_rows_done) THEN
      v_proc_snapshot_rows := 'Y';
    ELSE
      v_proc_snapshot_rows := 'N';
    END IF;

    -- Move all records in the current load set into FEM_BAL_POST_INTERIM_GT
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_event,
       p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
       p_msg_text =>
         'Moving data from interface table to the interim table...');

    FEM_ENGINES_PKG.Tech_Message
    (p_severity => pc_log_level_statement,
     p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
     p_app_name => 'FEM',
     p_msg_name => 'FEM_GL_POST_204',
     p_token1   => 'VAR_NAME',
     p_value1   => 'Start Time',
     p_token2   => 'VAR_VAL',
     p_value2   => TO_CHAR(SYSDATE, 'HH24:MI:SS'));

    -- Only interface records with a NULL posting_error_code will be moved
    -- over because we have cleaned up this code when marking rows for
    -- processing.  So any not null posting error code at this point in time
    -- comes from data validation.
    --
    -- Changes on 02/05/04:
    -- For Snapshot loads, we will process all load sets together.
    --
    -- Bug Fix 3559506
    --   Instead of using pv_exec_mode in the filter to determine if
    --   load_set_id can be ignored, we now use variable v_proc_snapshot_rows
    --   for this.

    INSERT INTO fem_bal_post_interim_gt
      (interface_rowid,
       bal_post_type_code,
       dataset_code,
       cal_period_id,
       ledger_id,
       company_cost_center_org_id,
       currency_code,
       currency_type_code,
       xtd_balance_e,
       xtd_balance_f,
       ytd_balance_e,
       ytd_balance_f,
       qtd_balance_e,
       qtd_balance_f,
       ptd_debit_balance_e,
       ptd_credit_balance_e,
       ytd_debit_balance_e,
       ytd_credit_balance_e,
       previous_error_flag,
       posting_error_flag)
    SELECT
       rowid,
       bal_post_type_code,
       FEM_GL_POST_PROCESS_PKG.pv_dataset_code,
       FEM_GL_POST_PROCESS_PKG.pv_cal_period_id,
       FEM_GL_POST_PROCESS_PKG.pv_ledger_id,
       -1,
       currency_code,
       currency_type_code,
       xtd_balance_e,
       xtd_balance_f,
       DECODE(FEM_GL_POST_PROCESS_PKG.pv_qtd_ytd_code,
         'PTD', NULL, 'QTD', NULL, ytd_balance_e),
       DECODE(FEM_GL_POST_PROCESS_PKG.pv_qtd_ytd_code,
         'PTD', NULL, 'QTD', NULL, ytd_balance_f),
       DECODE(FEM_GL_POST_PROCESS_PKG.pv_qtd_ytd_code,
         'PTD', NULL, 'YTD', NULL, qtd_balance_e),
       DECODE(FEM_GL_POST_PROCESS_PKG.pv_qtd_ytd_code,
         'PTD', NULL, 'YTD', NULL, qtd_balance_e),
       ptd_debit_balance_e,
       ptd_credit_balance_e,
       ytd_debit_balance_e,
       ytd_credit_balance_e,
       previous_error_flag,
       'N'
    FROM fem_bal_interface_t
    WHERE (v_proc_snapshot_rows = 'Y' OR load_set_id = p_load_set_id)
      AND  posting_request_id = pv_req_id_slice
      AND  posting_error_code is NULL;

    v_rows_ins_count := SQL%ROWCOUNT;

    COMMIT;

    FEM_ENGINES_PKG.Tech_Message
    (p_severity => pc_log_level_statement,
     p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
     p_app_name => 'FEM',
     p_msg_name => 'FEM_GL_POST_204',
     p_token1   => 'VAR_NAME',
     p_value1   => 'End Time',
     p_token2   => 'VAR_VAL',
     p_value2   => TO_CHAR(SYSDATE, 'HH24:MI:SS'));

    FEM_ENGINES_PKG.Tech_Message
    (p_severity => pc_log_level_statement,
     p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
     p_app_name => 'FEM',
     p_msg_name => 'FEM_GL_POST_216',
     p_token1   => 'NUM',
     p_value1   => TO_CHAR(v_rows_ins_count),
     p_token2   => 'TABLE',
     p_value2   => 'FEM_BAL_POST_INTERIM_GT');

    -- Start building SQL statement to look up numeric IDs for the
    -- dimension members.  We will process 5 dimensions at a time
    -- due to potential performance implications when joining to
    -- too many tables at a time

    FEM_ENGINES_PKG.Tech_Message
    (p_severity => pc_log_level_event,
     p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
     p_msg_text =>
      'Looking up member numeric IDs for 5 dimensions at a time...');

    FOR v IN 1..FEM_GL_POST_PROCESS_PKG.pv_proc_key_dim_num LOOP

      IF (v_dim_count = 1) THEN

        -- This is the start of a new statement after one execution,
        -- so re-initialize all buffers
        v_sql_stmt  := 'UPDATE fem_bal_post_interim_gt g SET ';
        v_upd_cols  := '(';
        v_sel_stmt  := '(SELECT ';
        v_tab_list  := 'FROM fem_bal_interface_t i, ';
        v_join_stmt := 'WHERE i.rowid = g.interface_rowid ';

      END IF;

      IF (FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_col_name IN
           ('COMPANY_COST_CENTER_ORG_ID', 'FINANCIAL_ELEM_ID', 'CURRENCY_CODE',
            'PRODUCT_ID', 'NATURAL_ACCOUNT_ID', 'CHANNEL_ID', 'LINE_ITEM_ID',
            'PROJECT_ID', 'CUSTOMER_ID', 'ENTITY_ID', 'INTERCOMPANY_ID',
            'TASK_ID', 'USER_DIM1_ID', 'USER_DIM2_ID', 'USER_DIM3_ID',
            'USER_DIM4_ID', 'USER_DIM5_ID', 'USER_DIM6_ID', 'USER_DIM7_ID',
            'USER_DIM8_ID', 'USER_DIM9_ID', 'USER_DIM10_ID',
            'SOURCE_SYSTEM_CODE')) THEN

        FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'v',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(v));

        FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'v_dim_count',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAr(v_dim_count));

        FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'dim column name',
          p_token2   => 'VAR_VAL',
          p_value2   => FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_col_name);

        -- Build the list of columns for updating
        v_upd_cols := v_upd_cols || 'g.' ||
          FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_col_name || ', ';

        -- Build SELECT column lists
        v_sel_stmt := v_sel_stmt ||
          'dm' || TO_CHAR(v_dim_count) || '.' ||
          FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_member_col || ', ';

        -- Build table list
        v_tab_list := v_tab_list ||
          FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_member_b_table_name ||
          ' dm' || v_dim_count || ', ';

        -- Build related join conditions
        v_join_stmt :=
           v_join_stmt ||
           'AND dm' || v_dim_count || '.' ||
           FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_member_disp_code_col ||
           ' = i.' ||
           FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_int_disp_code_col ||
           ' AND dm' || v_dim_count || '.personal_flag = ''N'' ';

        IF pv_allow_dis_mbrs_flag = 'Y' THEN
           NULL;
        ELSE
           v_join_stmt := v_join_stmt ||
           'AND dm' || v_dim_count || '.enabled_flag = ''Y'' ';
        END IF;

        IF (FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_vsr_flag = 'Y') THEN
            v_join_stmt := v_join_stmt ||
            'AND dm' || v_dim_count || '.value_set_id = ' ||
            TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_vs_id) || ' ';
        END IF;

        v_dim_count := v_dim_count + 1;

      END IF;

      -- If 5 dimensions have been built into the statement
      -- (i.e. v_dim_count = 6), put the parts together
      -- and execute the UPDATE

      IF (v_dim_count = 6 or v = FEM_GL_POST_PROCESS_PKG.pv_proc_key_dim_num) THEN

        v_sql_stmt := v_sql_stmt ||
                      RTRIM(v_upd_cols, ', ') || ') = ' ||
                      RTRIM(v_sel_stmt, ', ') || ' ' ||
                      RTRIM(v_tab_list, ', ') || ' ' ||
                      v_join_stmt || ')';

        FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
         p_msg_text => 'v_sql_stmt: ' || v_sql_stmt);

        FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'Start Time',
         p_token2   => 'VAR_VAL',
         p_value2   => TO_CHAR(SYSDATE, 'HH24:MI:SS'));

        EXECUTE IMMEDIATE v_sql_stmt;

        v_rows_upd_count := SQL%ROWCOUNT;

        FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'End Time',
         p_token2   => 'VAR_VAL',
         p_value2   => TO_CHAR(SYSDATE, 'HH24:MI:SS'));

        FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_217',
         p_token1   => 'NUM',
         p_value1   => TO_CHAR(v_rows_upd_count),
         p_token2   => 'TABLE',
         p_value2   => 'FEM_BAL_POST_INTERIM_GT');

        v_dim_count := 1;

        COMMIT;

      END IF;

    END LOOP;

    -- Check all records in FEM_BAL_POST_INTERIM_GT and see if any
    -- records have missing dimension member ID.
    -- If so, mark them with error code.

    FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
        p_msg_text => 'Checking for missing dimension member ID...');

    v_sql_stmt := 'UPDATE fem_bal_post_interim_gt g ' ||
      'SET posting_error_flag = ''Y'' ' || 'WHERE ';

    v_dim_count := 1;

    FOR v IN 1..FEM_GL_POST_PROCESS_PKG.pv_proc_key_dim_num LOOP

      IF (FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_col_name IN
         ('COMPANY_COST_CENTER_ORG_ID', 'FINANCIAL_ELEM_ID', 'CURRENCY_CODE',
          'PRODUCT_ID', 'NATURAL_ACCOUNT_ID', 'CHANNEL_ID', 'LINE_ITEM_ID',
          'PROJECT_ID', 'CUSTOMER_ID', 'ENTITY_ID', 'INTERCOMPANY_ID',
          'TASK_ID', 'USER_DIM1_ID', 'USER_DIM2_ID', 'USER_DIM3_ID',
          'USER_DIM4_ID', 'USER_DIM5_ID', 'USER_DIM6_ID', 'USER_DIM7_ID',
          'USER_DIM8_ID', 'USER_DIM9_ID', 'USER_DIM10_ID',
          'SOURCE_SYSTEM_CODE')) THEN

        IF (v_dim_count = 1) THEN

          v_sql_stmt := v_sql_stmt ||
            FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_col_name || ' IS NULL ';
          v_dim_count := 0;

        ELSE

          v_sql_stmt := v_sql_stmt || 'OR ' ||
            FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_col_name || ' IS NULL ';

        END IF;

      END IF;

    END LOOP;

    FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
        p_msg_text => 'v_sql_stmt: ' || v_sql_stmt);

    BEGIN

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'Start Time',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(SYSDATE, 'HH24:MI:SS'));

      EXECUTE IMMEDIATE v_sql_stmt;

      x_cur_data_err_rows := SQL%ROWCOUNT;

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'End Time',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(SYSDATE, 'HH24:MI:SS'));

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_217',
        p_token1   => 'NUM',
        p_value1   => TO_CHAR(x_cur_data_err_rows),
        p_token2   => 'TABLE',
        p_value2   => 'FEM_BAL_POST_INTERIM_GT');

      COMMIT;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    IF (x_cur_data_err_rows > 0) THEN

      IF pv_snapshot_rows_done THEN

         FEM_ENGINES_PKG.Tech_Message
          (p_severity  => pc_log_level_error,
           p_module    => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
           p_app_name  => 'FEM',
           p_msg_name  => 'FEM_GL_POST_223');

      ELSE

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_event,
            p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
            p_app_name => 'FEM',
            p_msg_text => 'Invalid records are found in the snapshot pass');

      END IF;

      -- Update corresponding error code column in FEM_BAL_INTERFACE_T
      -- based on FEM_BAL_POST_INTERIM_GT

      FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_event,
          p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
          p_msg_text => 'Updating interface table with error codes...');

      UPDATE fem_bal_interface_t
      SET posting_error_code = 'FEM_GL_POST_INVALID_DIM_MEMBER'
      WHERE rowid IN
           (SELECT interface_rowid
            FROM fem_bal_post_interim_gt
            WHERE posting_error_flag = 'Y');

      FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_217',
          p_token1   => 'NUM',
          p_value1   => TO_CHAR(SQL%ROWCOUNT),
          p_token2   => 'TABLE',
          p_value2   => 'FEM_BAL_INTERFACE_T');

      COMMIT;

    END IF;

    IF (x_cur_data_err_rows = v_rows_ins_count) THEN
      -- If number of records with invalid data is equal to
      -- the number of rows inserted into the interim table originally,
      -- set x_nothing_to_post to TRUE
      x_nothing_to_post := TRUE;
    END IF;

    -- Count number of previous error processed successfully
    FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
        p_msg_text => 'Counting number of previous error rows reprocessed...');

    BEGIN
      SELECT count(*)
      INTO x_prev_err_rows_reproc
      FROM fem_bal_post_interim_gt
      WHERE posting_error_flag = 'N'
      AND previous_error_flag = 'Y';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_prev_err_rows_reproc := 0;
    END;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Post_To_Interim',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  EXCEPTION
    WHEN OTHERS THEN

      ROLLBACK;

      x_completion_code := 2;

      FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected,
       p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.pti.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Post_To_Interim',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  END Post_To_Interim;


-- ======================================================================
-- Procedure
--     Post_Cycle_Handler
-- Purpose
--     This is the wrapper routine for a post cycle.  It calls the
--    following routines in order:
--      1) Mark_Rows_For_Process
--      2) Validate_Interface_Data
--      3) Post_To_Interim
--      4) FEM_GL_POST_BAL_PKG.Post_Fem_Balances
-- History
--     02-19-04  S Kung   Created
--     05-06-04  G Hall   Bug# 3597527: Implemented changes for
--                        multiprocessing
-- Arguments
--    p_load_set_id           The Load Set ID being processed
--    x_completion_code       Completion status of the routine
--    x_rows_marked           Number of rows marked for processing
--    x_posted_row_num        Number of records posted
--    x_prev_err_rows_reproc  Number of previous error records sucessfully
--                            reprocessed
--    x_cur_data_err_rows     Nunber of current error rows found,
--                            including previous error rows that are still
--                            in error.
-- ========================================================================

PROCEDURE Post_Cycle_Handler
            (p_load_set_id           IN  NUMBER,
             x_completion_code       OUT NOCOPY NUMBER,
             x_rows_marked           OUT NOCOPY NUMBER,
             x_posted_row_num        OUT NOCOPY NUMBER,
             x_prev_err_rows_reproc  OUT NOCOPY NUMBER,
             x_cur_data_err_rows     OUT NOCOPY NUMBER) IS

    FEMXGL_fatal_err          EXCEPTION;
    FEMXGL_skip_the_rest      EXCEPTION;
    v_compl_code              NUMBER;
    v_posted_rows             NUMBER;
    v_prev_err_rows_reproc    NUMBER;
    v_err_count               NUMBER;
    v_curr_set_row_count      NUMBER;
    v_any_valid_data_to_post  BOOLEAN;
    v_nothing_to_post         BOOLEAN;

  BEGIN

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Post_Cycle_Handler',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    x_completion_code      := 0;
    x_posted_row_num       := 0;
    x_prev_err_rows_reproc := 0;
    x_cur_data_err_rows    := 0;

    v_posted_rows            := 0;
    v_prev_err_rows_reproc   := 0;
    v_curr_set_row_count     := 0;
    v_any_valid_data_to_post := FALSE;
    v_nothing_to_post        := FALSE;

    -- --------------------------------------------------------------
    -- *** Mark rows for processing by populating the request ID ***
    -- --------------------------------------------------------------

    FEM_ENGINES_PKG.Tech_Message
    (p_severity => pc_log_level_event,
     p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
     p_app_name => 'FEM',
     p_msg_name => 'FEM_GL_POST_222');

    Mark_Rows_For_Process
     (p_load_set_id       => p_load_set_id,
      x_row_count_in_set  => v_curr_set_row_count,
      x_completion_code   => v_compl_code);

    x_rows_marked := v_curr_set_row_count;

    IF v_compl_code = 2 THEN
       RAISE FEMXGL_fatal_err;
    ELSIF v_curr_set_row_count = 0 THEN
       RAISE FEMXGL_skip_the_rest;
    END IF;

    -- -------------------------------------------
    -- *** Validate Interface Data ***
    -- -------------------------------------------

    FEM_ENGINES_PKG.Tech_Message
     (p_severity  => pc_log_level_event,
      p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
      p_app_name  => 'FEM',
      p_msg_name  => 'FEM_GL_POST_211');

    v_err_count := 0;

    Validate_Interface_Data
      (p_load_set_id          => p_load_set_id,
       p_total_row_num        => v_curr_set_row_count,
       x_records_to_post_flag => v_any_valid_data_to_post,
       x_num_invalid_record   => v_err_count,
       x_completion_code      => v_compl_code);

    x_cur_data_err_rows := v_err_count;

    FEM_ENGINES_PKG.Tech_Message
    (p_severity  => pc_log_level_statement,
     p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
     p_app_name  => 'FEM',
     p_msg_name  => 'FEM_GL_POST_204',
     p_token1 => 'VAR_NAME',
     p_value1 => 'v_err_count',
     p_token2 => 'VAR_VAL',
     p_value2 => TO_CHAR(v_err_count));

    IF v_compl_code = 2 THEN
      RAISE FEMXGL_fatal_err;
    ELSIF NOT v_any_valid_data_to_post THEN
      RAISE FEMXGL_skip_the_rest;
    END IF;

    -- ------------------------------
    -- *** Post to Interim table ***
    -- ------------------------------

    FEM_ENGINES_PKG.Tech_Message
    (p_severity  => pc_log_level_event,
     p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
     p_app_name  => 'FEM',
     p_msg_name  => 'FEM_GL_POST_212');

    v_err_count := 0;

    Post_To_Interim
       (p_load_set_id          => p_load_set_id,
        x_completion_code      => v_compl_code,
        x_nothing_to_post      => v_nothing_to_post,
        x_prev_err_rows_reproc => v_prev_err_rows_reproc,
        x_cur_data_err_rows    => v_err_count);

    x_prev_err_rows_reproc := v_prev_err_rows_reproc;
    x_cur_data_err_rows := x_cur_data_err_rows + v_err_count;

    FEM_ENGINES_PKG.Tech_Message
    (p_severity  => pc_log_level_statement,
     p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
     p_app_name  => 'FEM',
     p_msg_name  => 'FEM_GL_POST_204',
     p_token1 => 'VAR_NAME',
     p_value1 => 'v_prev_err_rows_reproc',
     p_token2 => 'VAR_VAL',
     p_value2 => TO_CHAR(v_prev_err_rows_reproc));

    FEM_ENGINES_PKG.Tech_Message
    (p_severity  => pc_log_level_statement,
     p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
     p_app_name  => 'FEM',
     p_msg_name  => 'FEM_GL_POST_204',
     p_token1 => 'VAR_NAME',
     p_value1 => 'v_err_count',
     p_token2 => 'VAR_VAL',
     p_value2 => TO_CHAR(v_err_count));

    IF v_compl_code = 2 THEN
      RAISE FEMXGL_fatal_err;
    ELSIF v_nothing_to_post THEN
      RAISE FEMXGL_skip_the_rest;
    END IF;

    -- -----------------------------
    -- *** Post to FEM_BALANCES ***
    -- -----------------------------

    FEM_ENGINES_PKG.Tech_Message
     (p_severity   => pc_log_level_event,
      p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
      p_app_name   => 'FEM',
      p_msg_name   => 'FEM_GL_POST_214');

    FEM_GL_POST_BAL_PKG.Post_Fem_Balances
     (p_execution_mode  => FEM_GL_POST_PROCESS_PKG.pv_exec_mode,
      p_process_slice   => pv_process_slice,
      x_rows_posted     => v_posted_rows,
      x_completion_code => v_compl_code);

    IF v_compl_code = 2 THEN
      RAISE FEMXGL_fatal_err;
    END IF;

    x_posted_row_num := v_posted_rows;

    FEM_ENGINES_PKG.Tech_Message
     (p_severity  => pc_log_level_statement,
      p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
      p_app_name  => 'FEM',
      p_msg_name  => 'FEM_GL_POST_204',
      p_token1 => 'VAR_NAME',
      p_value1 => 'x_posted_row_num',
      p_token2 => 'VAR_VAL',
      p_value2 => TO_CHAR(x_posted_row_num));

    FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Post_Cycle_Handler',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  EXCEPTION
    WHEN FEMXGL_skip_the_rest THEN

      x_completion_code := 0;

      IF pv_snapshot_rows_done THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_event,
            p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
            p_app_name   => 'FEM',
            p_msg_name   => 'FEM_GL_POST_219',
            p_token1  => 'LOAD_SET_ID',
            p_value1  => TO_CHAR(p_load_set_id));

      ELSE

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_event,
            p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
            p_app_name => 'FEM',
            p_msg_text => 'Posting process found nothing to post for ' ||
                          'the snapshot pass');

      END IF;

      FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_procedure,
          p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_202',
          p_token1   => 'FUNC_NAME',
          p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Post_Cycle_Handler',
          p_token2   => 'TIME',
          p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    WHEN FEMXGL_fatal_err THEN

      ROLLBACK;

      x_completion_code := 2;

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Post_Cycle_Handler',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    WHEN OTHERS THEN

      ROLLBACK;

      x_completion_code := 2;

      FEM_ENGINES_PKG.User_Message
       (p_app_name   => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_unexpected,
       p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.pch.' || pv_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.post_cycle_handler',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  END Post_Cycle_Handler;

-- =======================================================================


-- ======================================================================
-- Procedure
--    Log_Data_Error_Help_Msgs
-- Purpose
--    Log help messages to the concurrent request log file when terminating
--    with any data validation errors.
-- History
--     07-11-05  G Hall   Bug# 3574347: Created
-- ========================================================================

PROCEDURE Log_Data_Error_Help_Msgs IS

   CURSOR c1 IS
      SELECT cm.interface_column_name, d.dimension_name
      FROM fem_tab_columns_b tc,
           fem_xdim_dimensions xd,
           fem_dimensions_vl d,
           fem_int_column_map cm
      WHERE tc.table_name = 'FEM_BALANCES'
        AND tc.column_name NOT IN ('CAL_PERIOD_ID', 'DATASET_CODE', 'LEDGER_ID')
        AND xd.dimension_id = tc.dimension_id
        AND xd.value_set_required_flag = 'N'
        AND d.dimension_id = tc.dimension_id
        AND cm.object_type_code = 'XGL_INTEGRATION'
        AND cm.target_column_name = tc.column_name
      ORDER BY 1;

   CURSOR c2 IS
      SELECT cm.interface_column_name, d.dimension_name, vs.value_set_name
      FROM fem_tab_columns_b tc,
           fem_xdim_dimensions xd,
           fem_dimensions_vl d,
           fem_int_column_map cm,
           fem_global_vs_combo_defs gvscd,
           fem_value_sets_vl vs
      WHERE tc.table_name = 'FEM_BALANCES'
        AND tc.column_name NOT IN ('CAL_PERIOD_ID', 'DATASET_CODE', 'LEDGER_ID')
        AND xd.dimension_id = tc.dimension_id
        AND xd.value_set_required_flag = 'Y'
        AND d.dimension_id = tc.dimension_id
        AND cm.object_type_code = 'XGL_INTEGRATION'
        AND cm.target_column_name = tc.column_name
        AND gvscd.global_vs_combo_id = FEM_GL_POST_PROCESS_PKG.pv_global_vs_combo_id
        AND gvscd.dimension_id = tc.dimension_id
        AND vs.dimension_id = gvscd.dimension_id
        AND vs.value_set_id = gvscd.value_set_id
      ORDER BY 1;

   BEGIN

   -- Log explanation about checking the POSTING_ERROR_CODE column, and
   -- info about the FEM_GL_POST_INVALID_DIM_MEMBER error code and the
   -- dimension display code columns in the interface table to which it may
   -- apply.

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_229');

   -- List each of the non-VSR dimension display code interface columns to
   -- which the FEM_GL_POST_INVALID_DIM_MEMBER error code may apply, and
   -- the Dimension Name against which it is validated.

      FOR non_vsr_dim IN c1 LOOP

         FEM_ENGINES_PKG.User_Message
          (p_app_name   => 'FEM',
           p_msg_name => 'FEM_GL_POST_230',
           p_token1   => 'DIM_DC_COL',
           p_value1   => non_vsr_dim.interface_column_name,
           p_token2   => 'DIM_NAME',
           p_value2   => non_vsr_dim.dimension_name);

      END LOOP;

   -- List each of the VSR dimension display code interface columns to
   -- which the FEM_GL_POST_INVALID_DIM_MEMBER error code may apply, and
   -- the Dimension Name and Value Set against which it is validated.

      FOR vsr_dim IN c2 LOOP

         FEM_ENGINES_PKG.User_Message
          (p_app_name   => 'FEM',
           p_msg_name => 'FEM_GL_POST_231',
           p_token1   => 'DIM_DC_COL',
           p_value1   => vsr_dim.interface_column_name,
           p_token2   => 'DIM_NAME',
           p_value2   => vsr_dim.dimension_name,
           p_token3   => 'VALUE_SET_NAME',
           p_value3   => vsr_dim.value_set_name);

      END LOOP;

   -- Other data validation error codes that may be reported in
   -- POSTING_ERROR_CODE are listed below with their descriptions,
   -- to aid in correcting the data errors in the interface table:

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_232');

   -- List descriptions for the following data validation error codes:
   --  FEM_GL_POST_DUP_PROC_KEYS
   --  FEM_GL_POST_INVALID_CURR_TYPE
   --  FEM_GL_POST_INVALID_POST_TYPE
   --  FEM_GL_POST_MISSING_BAL_COL
   --  FEM_GL_POST_MIX_LOAD_METHOD
   --  FEM_GL_POST_PREV_SET_ERROR
   --  FEM_GL_POST_TO_BE_REPROCESSED

      FEM_ENGINES_PKG.User_Message
       (p_app_name   => 'FEM',
        p_msg_name => 'FEM_GL_POST_233',
        p_token1   => 'DATA_ERROR_MSG_NAME',
        p_value1   => 'FEM_GL_POST_DUP_PROC_KEYS',
        p_trans1   => 'N',
        p_token2   => 'DATA_ERROR_MSG_TEXT',
        p_value2   => 'FEM_GL_POST_DUP_PROC_KEYS',
        p_trans2   => 'Y');

      FEM_ENGINES_PKG.User_Message
       (p_app_name   => 'FEM',
        p_msg_name => 'FEM_GL_POST_233',
        p_token1   => 'DATA_ERROR_MSG_NAME',
        p_value1   => 'FEM_GL_POST_INVALID_CURR_TYPE',
        p_trans1   => 'N',
        p_token2   => 'DATA_ERROR_MSG_TEXT',
        p_value2   => 'FEM_GL_POST_INVALID_CURR_TYPE',
        p_trans2   => 'Y');

      FEM_ENGINES_PKG.User_Message
       (p_app_name   => 'FEM',
        p_msg_name => 'FEM_GL_POST_233',
        p_token1   => 'DATA_ERROR_MSG_NAME',
        p_value1   => 'FEM_GL_POST_INVALID_POST_TYPE',
        p_trans1   => 'N',
        p_token2   => 'DATA_ERROR_MSG_TEXT',
        p_value2   => 'FEM_GL_POST_INVALID_POST_TYPE',
        p_trans2   => 'Y');

      FEM_ENGINES_PKG.User_Message
       (p_app_name   => 'FEM',
        p_msg_name => 'FEM_GL_POST_233',
        p_token1   => 'DATA_ERROR_MSG_NAME',
        p_value1   => 'FEM_GL_POST_MISSING_BAL_COL',
        p_trans1   => 'N',
        p_token2   => 'DATA_ERROR_MSG_TEXT',
        p_value2   => 'FEM_GL_POST_MISSING_BAL_COL',
        p_trans2   => 'Y');

      FEM_ENGINES_PKG.User_Message
       (p_app_name   => 'FEM',
        p_msg_name => 'FEM_GL_POST_233',
        p_token1   => 'DATA_ERROR_MSG_NAME',
        p_value1   => 'FEM_GL_POST_MIX_LOAD_METHOD',
        p_trans1   => 'N',
        p_token2   => 'DATA_ERROR_MSG_TEXT',
        p_value2   => 'FEM_GL_POST_MIX_LOAD_METHOD',
        p_trans2   => 'Y');

      FEM_ENGINES_PKG.User_Message
       (p_app_name   => 'FEM',
        p_msg_name => 'FEM_GL_POST_233',
        p_token1   => 'DATA_ERROR_MSG_NAME',
        p_value1   => 'FEM_GL_POST_PREV_SET_ERROR',
        p_trans1   => 'N',
        p_token2   => 'DATA_ERROR_MSG_TEXT',
        p_value2   => 'FEM_GL_POST_PREV_SET_ERROR',
        p_trans2   => 'Y');

      FEM_ENGINES_PKG.User_Message
       (p_app_name   => 'FEM',
        p_msg_name => 'FEM_GL_POST_233',
        p_token1   => 'DATA_ERROR_MSG_NAME',
        p_value1   => 'FEM_GL_POST_TO_BE_REPROCESSED',
        p_trans1   => 'N',
        p_token2   => 'DATA_ERROR_MSG_TEXT',
        p_value2   => 'FEM_GL_POST_TO_BE_REPROCESSED',
        p_trans2   => 'Y');

   END Log_Data_Error_Help_Msgs;

-- ========================================================================


/*****************************************************************
 *              PUBLIC PROCEDURES                       *
 *****************************************************************/

-- =======================================================================
-- Procedure
--    Main
-- Purpose
--    This is the "engine master" routine of the XGL Posting Engine
-- History
--    10-23-03  S Kung  Created
--    05-06-04  G Hall  Bug# 3597527: Implemented changes for
--                      multiprocessing
--    05-13-04  G Hall  Bug# 3597495: Added call to Get_SSC_To_Be_Processed,
--                      to be used by Final_Process_Logging to log Data
--                      Locations entries for all valid Source System Codes
--                      processed in the current set.
--    05-25-04  G Hall  Changed call to Get_SSC_To_Be_Processed to
--                      parameterized call to Get_SSC.
--    06-26-09  G Hall  Bug# 7691287 (FP of 11i bug 6970161):
--                      Changed the FEMXGL_Warn exception handler
--                      to report the 'LOAD_STATUS' event as INCOMPLETE only
--                      when the warning is for data errors, but as COMPLETE
--                      for other warning cases that include full loading of
--                      data.
--- Arguments
--    p_errbuf:             Output parameter required by
--                          Concurrent Manager
--    p_retcode:            Output parameter required by
--                          Concurrent Manager
--    p_ledger_id:          Ledger to load data for
--    p_cal_period_id:      Period to load data for
--    p_dataset_code:       Target dataset to load data into
--    p_xgl_int_obj_def_id: XGL/FEM integration rule object definition ID
--    p_execution_mode:     Execution mode, S (Snapshot)/I (Incremental)
--    p_qtd_ytd_code:       Specifies whether period-specific QTD and
--                          YTD balances will be maintained
--    p_budget_id:          Budget to be loaded
--    p_enc_type_id:        Encumbrance type to be loaded
--    p_allow_dis_mbrs_flag DEFAULT is 'N'.  'Y' means do not reject
--                          disabled members as errors, but allow balances
--                          to be loaded.
-- =======================================================================

PROCEDURE Main
           (x_errbuf             OUT NOCOPY  VARCHAR2,
            x_retcode            OUT NOCOPY  VARCHAR2,
            p_execution_mode     IN          VARCHAR2,
            p_ledger_id          IN          VARCHAR2,
            p_cal_period_id      IN          VARCHAR2,
            p_budget_id          IN          VARCHAR2,
            p_enc_type_id        IN          VARCHAR2,
            p_dataset_code       IN          VARCHAR2,
            p_xgl_int_obj_def_id IN          VARCHAR2,
            p_qtd_ytd_code       IN          VARCHAR2,
            p_allow_dis_mbrs_flag IN         VARCHAR2 DEFAULT 'N') IS

    FEMXGL_fatal_err            EXCEPTION;
    FEMXGL_warn                 EXCEPTION;
    FEMXGL_no_data_to_load      EXCEPTION;
    FEMXGL_all_data_invalid     EXCEPTION;

    v_status                    VARCHAR2(30);
    v_industry                  VARCHAR2(30);

    v_cp_status                 VARCHAR2(30);
    v_exception_code            VARCHAR2(30);
    v_eng_step                  VARCHAR2(12);
    v_slices_condition          VARCHAR2(32767);
    v_reuse_slices              VARCHAR2(1);

    v_tot_cur_data_err_rows     NUMBER;
    v_tot_prev_err_rows_reproc  NUMBER;
    v_tot_posted_rows           NUMBER;

    TYPE v_msg_list_type        IS VARRAY(20) OF
                                fem_mp_process_ctl_t.message%TYPE;
    v_msg_list                  v_msg_list_type;
    i                           NUMBER;

    v_compl_code                NUMBER;
    v_ret_status                BOOLEAN;
    v_warn_flag                 VARCHAR2(1);

    v_param_list                wf_parameter_list_t;

    v_ds_bal_type_attr_name     fem_dim_attributes_tl.attribute_name%TYPE;
    v_dataset_dim_name          fem_dimensions_tl.dimension_name%TYPE;
    v_xgl_rule_type_name        fem_object_types_tl.object_type_name%TYPE;

  BEGIN

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.main',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Main',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_207');

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_event,
       p_module   => 'fem.plsql.xgl_eng.main',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_207');

    -- -----------------------------------
    -- *** Validate Engine Parameters ***
    -- -----------------------------------

    v_warn_flag := 'N';

    FEM_GL_POST_PROCESS_PKG.Validate_XGL_Eng_Parameters
      (p_ledger_id       => TO_NUMBER(p_ledger_id),
       p_cal_period_id   => TO_NUMBER(p_cal_period_id),
       p_dataset_code    => TO_NUMBER(p_dataset_code),
       p_xgl_obj_def_id  => TO_NUMBER(p_xgl_int_obj_def_id),
       p_exec_mode       => p_execution_mode,
       p_qtd_ytd_code    => p_qtd_ytd_code,
       p_budget_id       => TO_NUMBER(p_budget_id),
       p_enc_type_id     => TO_NUMBER(p_enc_type_id),
       x_completion_code => v_compl_code);

    IF v_compl_code = 1 THEN
      v_warn_flag := 'Y';
    ELSIF v_compl_code = 2 THEN
      v_cp_status := 'ERROR';
      RAISE FEMXGL_fatal_err;
    END IF;

    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_208');

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_event,
       p_module   => 'fem.plsql.xgl_eng.main',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_208');

    -- -----------------------------------
    -- *** Register Process Execution ***
    -- -----------------------------------

    FEM_GL_POST_PROCESS_PKG.Register_Process_Execution
      (x_completion_code   => v_compl_code);

    IF v_compl_code = 2 THEN
      v_cp_status := 'ERROR';
      RAISE FEMXGL_fatal_err;
    END IF;

    -- -----------------------------------
    -- Get schema name for FEM
    -- -----------------------------------

    IF NOT FND_INSTALLATION.Get_App_Info
           (application_short_name => 'FEM',
            status                 => v_status,
            industry               => v_industry,
            oracle_schema          => pv_schema_name) THEN

       FEM_ENGINES_PKG.User_Message
         (p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_227');

       FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_error,
          p_module   => 'fem.plsql.xgl_eng.main',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_227');

      v_cp_status := 'ERROR';
      RAISE FEMXGL_fatal_err;

    END IF;

    -- ---------------------------------------------------------------------
    -- Prepare the Condition SQL string to be passed to the MP master to be
    -- used as a filter for determining the data slices.  For snaphot loads,
    -- the condition only needs to include the criteria for selecting the
    -- snapshot rows, without distinction between errored rows and new rows.
    -- For Incremental and Error Reprocessing modes, the engine will first
    -- process snapshot error rows, then it will process incremental rows,
    -- so these criteria need to be combined in the condition.
    -- ---------------------------------------------------------------------

    IF p_execution_mode = 'S' THEN

      -- one pass, only for snapshot rows, error and new

      v_slices_condition := 'load_method_code = ''S'' ';

    ELSIF p_execution_mode = 'I' THEN

      -- two passes, first for snapshot errors, second for all incremental

      v_slices_condition := '((load_method_code = ''I'') OR' ||
                             ' (load_method_code = ''S'' AND' ||
                             ' posting_error_code IS NOT NULL)) ';

    ELSIF p_execution_mode = 'E' THEN

      -- two passes, first for snapshot errors, second for incremental
      -- error rows

      v_slices_condition := 'posting_error_code IS NOT NULL';

    END IF;

    Finish_Condition_String(x_condition_string => v_slices_condition);

    -- Print out v_slices_condition for debugging purposes
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.xgl_eng.main',
       p_msg_text => 'v_slices_condition: ' || v_slices_condition);

    FEM_GL_POST_PROCESS_PKG.pv_ssc_where := v_slices_condition;

    -- ---------------------------------------------------------------------
    -- Get the list of distinct Source System Display Codes from the set
    -- of data to be processed.  It will be used later by
    -- Final_Process_Logging to determine what to log in Data Locations.
    -- ---------------------------------------------------------------------

    FEM_GL_POST_PROCESS_PKG.Get_SSC (p_dest_code => 'TBP');

    -- ---------------------------------------------------------------------
    -- Call the Multiprocessing Framework master procedure. It will look up
    -- the multiprocessing parameters, determine the data slices, and start
    -- up one or more concurrent processes which will each invoke the
    -- Process_Data_Slice procedure for one data slice at a time, until all
    -- the data slices have been processed.
    -- ---------------------------------------------------------------------

    IF p_execution_mode = 'S' THEN
      v_eng_step := 'SNAPSHOT';
    ELSE
      -- For Incremental mode and for Error Reprocessing mode, use the
      -- MP parameters set for the INCREMENTAL step.
      v_eng_step := 'INCREMENTAL';
    END IF;

    IF FEM_GL_POST_PROCESS_PKG.pv_exec_state = 'RESTART' THEN
      -- The MP framework picks up where it left off in the previous
      -- attempt, with the next unprocessed data slice.
      v_reuse_slices := 'Y';
    ELSE
      -- For NORMAL or RERUN, the MP framework must re-compute the data
      -- slices.  Some RERUN cases may be able to reuse the previous
      -- run's slices, but it's not guaranteed that the data in the table
      -- hasn't changed between runs.
      v_reuse_slices := 'N';
    END IF;

-- Bug 5734885. For each call to Process_Data_Slice, the MP FW will replace
-- the '{{table_partition}}' placeholder value sent in the p_eng_sql parameter
-- with the table partition clause appropriate for that data slice (NULL for
-- no table partitioning).

    FEM_MULTI_PROC_PKG.Master
     (X_PRG_STAT       => v_cp_status,
      X_EXCEPTION_CODE => v_exception_code,
      P_RULE_ID        => FEM_GL_POST_PROCESS_PKG.pv_rule_obj_id,
      P_ENG_STEP       => v_eng_step,
      P_DATA_TABLE     => 'FEM_BAL_INTERFACE_T',
      P_ENG_SQL        => '{{table_partition}}',
      P_TABLE_ALIAS    => NULL,
      P_RUN_NAME       => 'XGL Integration ' ||
                           TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'),
      P_ENG_PRG        => 'FEM_XGL_POST_ENGINE_PKG.PROCESS_DATA_SLICE',
      P_CONDITION      => v_slices_condition,
      P_FAILED_REQ_ID  => FEM_GL_POST_PROCESS_PKG.pv_prev_req_id,
      P_REUSE_SLICES   => v_reuse_slices,
      P_ARG1  => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_req_id),
      P_ARG2  => FEM_GL_POST_PROCESS_PKG.pv_exec_mode,
      P_ARG3  => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_rule_obj_id),
      P_ARG4  => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_dataset_code),
      P_ARG5  => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_cal_period_id),
      P_ARG6  => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_ledger_id),
      P_ARG7  => FEM_GL_POST_PROCESS_PKG.pv_qtd_ytd_code,
      P_ARG8  => FEM_GL_POST_PROCESS_PKG.pv_entered_crncy_flag,
      P_ARG9  => FEM_GL_POST_PROCESS_PKG.pv_cal_per_dim_grp_dsp_cd,
      P_ARG10 => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_cal_per_end_date,
                         'YYYY/MM/DD HH24:MI:SS'),
      P_ARG11 => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_gl_per_number),
      P_ARG12 => FEM_GL_POST_PROCESS_PKG.pv_ledger_dsp_cd,
      P_ARG13 => FEM_GL_POST_PROCESS_PKG.pv_budget_dsp_cd,
      P_ARG14 => FEM_GL_POST_PROCESS_PKG.pv_enc_type_dsp_cd,
      P_ARG15 => FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd,
      P_ARG16 => pv_schema_name,
      P_ARG17 => p_allow_dis_mbrs_flag);

    FEM_ENGINES_PKG.Tech_Message
     (p_severity => pc_log_level_statement,
      p_module   => 'fem.plsql.xgl_eng.main',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_204',
      p_token1   => 'VAR_NAME',
      p_value1   => 'v_cp_status',
      p_token2   => 'VAR_VAL',
      p_value2   => v_cp_status);

    v_cp_status := REPLACE(v_cp_status, 'COMPLETE:', '');

    IF v_cp_status IN ('ERROR', 'CANCELLED', 'TERMINATED') THEN

      -- -------------------------------------------------------------------
      -- The following two cases indicate that no data slice
      -- processing was done, either because there was no data
      -- found to process, or because of a fatal error in the
      -- MP Master.
      -- -------------------------------------------------------------------

      IF v_exception_code = 'FEM_MP_NO_DATA_SLICES_ERR' THEN

        RAISE FEMXGL_no_data_to_load;

      ELSIF v_exception_code IS NOT NULL THEN

        FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.xgl_eng.main',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'v_exception_code',
          p_token2   => 'VAR_VAL',
          p_value2   => v_exception_code);

        v_tot_posted_rows := 0;
        v_tot_prev_err_rows_reproc := 0;
        v_tot_cur_data_err_rows := 0;

        RAISE FEMXGL_fatal_err;

      END IF;

    END IF;

    -- ---------------------------------------------------------------------
    -- There should be some data slices; get row totals from the data
    -- slices table.
    -- ---------------------------------------------------------------------

    SELECT SUM(rows_loaded), SUM(rows_processed), SUM(rows_rejected)
    INTO v_tot_posted_rows, v_tot_prev_err_rows_reproc, v_tot_cur_data_err_rows
    FROM fem_mp_process_ctl_t
    WHERE req_id = FEM_GL_POST_PROCESS_PKG.pv_req_id;

    FEM_ENGINES_PKG.Tech_Message
     (p_severity => pc_log_level_statement,
      p_module   => 'fem.plsql.xgl_eng.main',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_204',
      p_token1   => 'VAR_NAME',
      p_value1   => 'v_tot_posted_rows',
      p_token2   => 'VAR_VAL',
      p_value2   => TO_CHAR(v_tot_posted_rows));

    FEM_ENGINES_PKG.Tech_Message
     (p_severity => pc_log_level_statement,
      p_module   => 'fem.plsql.xgl_eng.main',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_204',
      p_token1   => 'VAR_NAME',
      p_value1   => 'v_tot_prev_err_rows_reproc',
      p_token2   => 'VAR_VAL',
      p_value2   => TO_CHAR(v_tot_prev_err_rows_reproc));

    FEM_ENGINES_PKG.Tech_Message
     (p_severity => pc_log_level_statement,
      p_module   => 'fem.plsql.xgl_eng.main',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_204',
      p_token1   => 'VAR_NAME',
      p_value1   => 'v_tot_cur_data_err_rows',
      p_token2   => 'VAR_VAL',
      p_value2   => TO_CHAR(v_tot_cur_data_err_rows));

    -- -------------------------------------------------------------------
    -- Log any fatal errors that occurred during data slice processing.
    -- -------------------------------------------------------------------

    IF v_cp_status IN ('ERROR', 'CANCELLED', 'TERMINATED') THEN

      -- Get the error messages from all data slice entries with an error status.

      v_msg_list := v_msg_list_type();

      SELECT DISTINCT(message)
      BULK COLLECT INTO v_msg_list
      FROM fem_mp_process_ctl_t
      WHERE req_id = FEM_GL_POST_PROCESS_PKG.pv_req_id
        AND status = 2;

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.main',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'v_msg_list.count',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(v_msg_list.count));

      -- Log all of the messages

      FOR i IN 1..v_msg_list.count LOOP

        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_error,
           p_module   => 'fem.plsql.xgl_eng.main',
           p_app_name => 'FEM',
           p_msg_text => v_msg_list(i));

        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_text => v_msg_list(i));

      END LOOP;

      -- Delete this process' data slice entries from the data slices table
      FEM_MULTI_PROC_PKG.Delete_Data_Slices(FEM_GL_POST_PROCESS_PKG.pv_req_id);

      RAISE FEMXGL_fatal_err;

    END IF;

    -- Delete this process' data slice entries from the data slices table
    FEM_MULTI_PROC_PKG.Delete_Data_Slices(FEM_GL_POST_PROCESS_PKG.pv_req_id);

    -- -------------------------------------------------------------------
    -- At this point, no fatal error has occurred, but there may be error
    -- conditions or warnings based on how much data was (or wasn't)
    -- successfully processed.
    -- -------------------------------------------------------------------

    IF v_tot_posted_rows = 0
          AND FEM_GL_POST_PROCESS_PKG.pv_exec_mode = 'S' THEN

      -- -------------------------------------------------------------------
      -- Since No Data to Post has already been trapped, at this point if
      -- Rows_Loaded = 0 it means there was data to post but it all had
      -- data errors.  This is treated as an error for snapshot mode.
      -- -------------------------------------------------------------------

      RAISE FEMXGL_all_data_invalid;

    END IF;

    -- -------------------------------------------------------------------
    -- Prepare parameters for raising the business event
    -- -------------------------------------------------------------------

    WF_EVENT.addparametertolist
      (p_name          => 'REQUEST_ID',
       p_value         => FEM_GL_POST_PROCESS_PKG.pv_req_id,
       p_parameterlist => v_param_list);

    WF_EVENT.addparametertolist
      (p_name          => 'EXECUTION_MODE',
       p_value         => p_execution_mode,
       p_parameterlist => v_param_list);

    WF_EVENT.addparametertolist
      (p_name          => 'LEDGER_ID',
       p_value         => p_ledger_id,
       p_parameterlist => v_param_list);

    WF_EVENT.addparametertolist
      (p_name          => 'CAL_PERIOD_ID',
       p_value         => p_cal_period_id,
       p_parameterlist => v_param_list);

    WF_EVENT.addparametertolist
      (p_name          => 'DATASET_CODE',
       p_value         => p_dataset_code,
       p_parameterlist => v_param_list);

    WF_EVENT.addparametertolist
      (p_name          => 'OBJECT_DEFINITION_ID',
       p_value         => p_xgl_int_obj_def_id,
       p_parameterlist => v_param_list);

    WF_EVENT.addparametertolist
      (p_name          => 'QTD_YTD_CODE',
       p_value         => p_qtd_ytd_code,
       p_parameterlist => v_param_list);

    WF_EVENT.addparametertolist
      (p_name          => 'BUDGET_ID',
       p_value         => p_budget_id,
       p_parameterlist => v_param_list);

    WF_EVENT.addparametertolist
      (p_name          => 'ENCUMBRANCE_TYPE_ID',
       p_value         => p_enc_type_id,
       p_parameterlist => v_param_list);

    -- -------------------------------------------------------------------
    -- Check for WARNING Status
    -- -------------------------------------------------------------------

    IF v_tot_cur_data_err_rows > 0 THEN

      -- WARNING:  Some rows from the interface table have data errors
      -- and could not be loaded.  Correct the errors in the remaining
      -- interface rows and resubmit them for processing.

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_226');

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error,
         p_module   => 'fem.plsql.xgl_eng.main',
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_226');

      Log_Data_Error_Help_Msgs;

      RAISE FEMXGL_warn;

    ELSIF v_warn_flag = 'Y' THEN

      RAISE FEMXGL_warn;

    END IF;

    -- ------------------------------
    -- *** Final Process Logging ***
    -- ------------------------------

    -- Not ending in WARNING status, so Load Status for the business
    -- event is COMPLETE.

    WF_EVENT.addparametertolist
      (p_name          => 'LOAD_STATUS',
       p_value         => 'COMPLETE',
       p_parameterlist => v_param_list);

    -- Raise the event

    WF_EVENT.RAISE
      (p_event_name => 'oracle.apps.fem.xglintg.balrule.execute',
       p_event_key  => NULL,
       p_parameters => v_param_list);

    v_param_list.DELETE;

    -- Perform final process logging, including Data Locations entries

    FEM_GL_POST_PROCESS_PKG.Final_Process_Logging
      (p_exec_status            => 'SUCCESS',
       p_num_data_errors        => v_tot_cur_data_err_rows,
       p_num_data_errors_reproc => v_tot_prev_err_rows_reproc,
       p_num_output_rows        => v_tot_posted_rows,
       p_final_message_name     => 'FEM_GL_POST_220');

    FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.main',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Main',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    v_ret_status := FND_CONCURRENT.Set_Completion_Status
                      (status => 'NORMAL', message => NULL);

  EXCEPTION
    WHEN FEMXGL_fatal_err THEN

      -- Perform post-process logging
      FEM_GL_POST_PROCESS_PKG.Final_Process_Logging
      (p_exec_status            => 'ERROR_RERUN',
       p_num_data_errors        => v_tot_cur_data_err_rows,
       p_num_data_errors_reproc => v_tot_prev_err_rows_reproc,
       p_num_output_rows        => v_tot_posted_rows,
       p_final_message_name     => 'FEM_GL_POST_205');

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.main',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Main',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      v_ret_status := FND_CONCURRENT.Set_Completion_Status
         (status  => v_cp_status, message => NULL);

      COMMIT;

    WHEN FEMXGL_warn THEN

      IF v_tot_cur_data_err_rows > 0 THEN
        -- There were data errors, so Load Status for the business
        -- event is INCOMPLETE.

        WF_EVENT.addparametertolist
          (p_name          => 'LOAD_STATUS',
           p_value         => 'INCOMPLETE',
           p_parameterlist => v_param_list);

      ELSE

        WF_EVENT.addparametertolist
          (p_name          => 'LOAD_STATUS',
           p_value         => 'COMPLETE',
           p_parameterlist => v_param_list);

      END IF;

      -- Raise the event

      WF_EVENT.RAISE
        (p_event_name => 'oracle.apps.fem.xglintg.balrule.execute',
         p_event_key  => NULL,
         p_parameters => v_param_list);

      v_param_list.DELETE;

      -- Perform post-process logging, including Data Locations entries

      FEM_GL_POST_PROCESS_PKG.Final_Process_Logging
      (p_exec_status            => 'SUCCESS',
       p_num_data_errors        => v_tot_cur_data_err_rows,
       p_num_data_errors_reproc => v_tot_prev_err_rows_reproc,
       p_num_output_rows        => v_tot_posted_rows,
       p_final_message_name     => 'FEM_GL_POST_206');

      -- Logging final messages

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.main',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Main',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      v_ret_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'WARNING', message => NULL);

      COMMIT;

    WHEN FEMXGL_no_data_to_load THEN

      SELECT attribute_name
      INTO v_ds_bal_type_attr_name
      FROM fem_dim_attributes_vl
      WHERE attribute_varchar_label = 'DATASET_BALANCE_TYPE_CODE';

      SELECT dimension_name
      INTO v_dataset_dim_name
      FROM fem_dimensions_vl
      WHERE dimension_varchar_label = 'DATASET';

      SELECT object_type_name
      INTO v_xgl_rule_type_name
      FROM fem_object_types_vl
      WHERE object_type_code = 'XGL_INTEGRATION';

      FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_225',
       p_token1   => 'LOAD_METHOD_CODE',
       p_value1   => FEM_GL_POST_PROCESS_PKG.pv_exec_mode,
       p_token2   => 'CAL_PER_DIM_GRP_DISPLAY_CODE',
       p_value2   => FEM_GL_POST_PROCESS_PKG.pv_cal_per_dim_grp_dsp_cd,
       p_token3   => 'CAL_PERIOD_END_DATE',
       p_value3   => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_cal_per_end_date) || ' ' ||
                     TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_cal_per_end_date, 'HH24:MI:SS'),
       p_token4   => 'CAL_PERIOD_NUMBER',
       p_value4   => FEM_GL_POST_PROCESS_PKG.pv_gl_per_number,
       p_token5   => 'LEDGER_DISPLAY_CODE',
       p_value5   => FEM_GL_POST_PROCESS_PKG.pv_ledger_dsp_cd,
       p_token6   => 'DS_BALANCE_TYPE_CODE',
       p_value6   => FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd,
       p_token7   => 'BUDGET_DISPLAY_CODE',
       p_value7   => FEM_GL_POST_PROCESS_PKG.pv_budget_dsp_cd,
       p_token8   => 'ENCUMBRANCE_TYPE_CODE',
       p_value8   => FEM_GL_POST_PROCESS_PKG.pv_enc_type_dsp_cd);

      FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_228',
       p_token1   => 'DS_BAL_TYPE_ATTR_NAME',
       p_value1   => v_ds_bal_type_attr_name,
       p_token2   => 'DATASET_PARAM_NAME',
       p_value2   => v_dataset_dim_name,
       p_token3   => 'XGL_RULE_TYPE_NAME',
       p_value3   => v_xgl_rule_type_name);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected,
       p_module   => 'fem.plsql.xgl_eng.main',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_225',
       p_token1   => 'LOAD_METHOD_CODE',
       p_value1   => FEM_GL_POST_PROCESS_PKG.pv_exec_mode,
       p_token2   => 'CAL_PER_DIM_GRP_DISPLAY_CODE',
       p_value2   => FEM_GL_POST_PROCESS_PKG.pv_cal_per_dim_grp_dsp_cd,
       p_token3   => 'CAL_PERIOD_END_DATE',
       p_value3   => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_cal_per_end_date) || ' ' ||
                     TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_cal_per_end_date, 'HH24:MI:SS'),
       p_token4   => 'CAL_PERIOD_NUMBER',
       p_value4   => FEM_GL_POST_PROCESS_PKG.pv_gl_per_number,
       p_token5   => 'LEDGER_DISPLAY_CODE',
       p_value5   => FEM_GL_POST_PROCESS_PKG.pv_ledger_dsp_cd,
       p_token6   => 'DS_BALANCE_TYPE_CODE',
       p_value6   => FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd,
       p_token7   => 'BUDGET_DISPLAY_CODE',
       p_value7   => FEM_GL_POST_PROCESS_PKG.pv_budget_dsp_cd,
       p_token8   => 'ENCUMBRANCE_TYPE_CODE',
       p_value8   => FEM_GL_POST_PROCESS_PKG.pv_enc_type_dsp_cd);

      IF FEM_GL_POST_PROCESS_PKG.pv_exec_mode IN ('I', 'E') THEN

      -- For Incremental and Error Reprocessing modes, no data found to
      -- load may be a common occurrence and is not treated as an error.

         FEM_GL_POST_PROCESS_PKG.Final_Process_Logging
         (p_exec_status            => 'SUCCESS',
          p_num_data_errors        => 0,
          p_num_data_errors_reproc => 0,
          p_num_output_rows        => 0,
          p_final_message_name     => 'FEM_GL_POST_220');

         v_ret_status := FND_CONCURRENT.Set_Completion_Status
            (status  => 'WARNING', message => NULL);

      ELSE

      -- For Snapshot execution mode, no data found to load is treated
      -- as an error.

         FEM_GL_POST_PROCESS_PKG.Final_Process_Logging
         (p_exec_status            => 'ERROR_RERUN',
          p_num_data_errors        => 0,
          p_num_data_errors_reproc => 0,
          p_num_output_rows        => 0,
          p_final_message_name     => 'FEM_GL_POST_205');

         v_ret_status := FND_CONCURRENT.Set_Completion_Status
            (status  => 'ERROR', message => NULL);

      END IF;

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.main',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Main',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      COMMIT;

    WHEN FEMXGL_all_data_invalid THEN

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_224');

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error,
         p_module   => 'fem.plsql.xgl_eng.main',
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_224');

      Log_Data_Error_Help_Msgs;

      -- Perform post-process logging
      FEM_GL_POST_PROCESS_PKG.Final_Process_Logging
      (p_exec_status            => 'ERROR_RERUN',
       p_num_data_errors        => v_tot_cur_data_err_rows,
       p_num_data_errors_reproc => v_tot_prev_err_rows_reproc,
       p_num_output_rows        => v_tot_posted_rows,
       p_final_message_name     => 'FEM_GL_POST_205');

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.main',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Main',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      v_ret_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      COMMIT;

    WHEN OTHERS THEN

      ROLLBACK;

      FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_unexpected,
       p_module   => 'fem.plsql.xgl_eng.main',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

      -- Perform post-process logging
      FEM_GL_POST_PROCESS_PKG.Final_Process_Logging
      (p_exec_status            => 'ERROR_RERUN',
       p_num_data_errors        => v_tot_cur_data_err_rows,
       p_num_data_errors_reproc => v_tot_prev_err_rows_reproc,
       p_num_output_rows        => v_tot_posted_rows,
       p_final_message_name     => 'FEM_GL_POST_205');

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_procedure,
       p_module   => 'fem.plsql.xgl_eng.main',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Main',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      v_ret_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      COMMIT;

  END Main;


-- =======================================================================
-- Procedure
--    Log_Pkg_Variables
-- Purpose
--    Log the values of the FEM_GL_POST_PROCESS_PKG package variables
--    which have been reset from the last 16 parameters.
-- History
--    05-05-04   G Hall   Bug# 3597527: Created
-- =======================================================================

   PROCEDURE Log_Pkg_Variables IS

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
       (p_severity    => pc_log_level_procedure,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_201',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Log_Package_Variables',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'pv_process_slice',
        p_token2   => 'VAR_VAL',
        p_value2   => pv_process_slice);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_req_id',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_req_id));

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_exec_mode',
        p_token2   => 'VAR_VAL',
        p_value2   => FEM_GL_POST_PROCESS_PKG.pv_exec_mode);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_rule_obj_id',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_rule_obj_id));

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_dataset_code',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_dataset_code));

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_cal_period_id',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_cal_period_id));

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_ledger_id',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_ledger_id));

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_qtd_ytd_code',
        p_token2   => 'VAR_VAL',
        p_value2   => FEM_GL_POST_PROCESS_PKG.pv_qtd_ytd_code);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_entered_crncy_flag',
        p_token2   => 'VAR_VAL',
        p_value2   => FEM_GL_POST_PROCESS_PKG.pv_entered_crncy_flag);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_cal_per_dim_grp_dsp_cd',
        p_token2   => 'VAR_VAL',
        p_value2   => FEM_GL_POST_PROCESS_PKG.pv_cal_per_dim_grp_dsp_cd);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_cal_per_end_date',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_cal_per_end_date,
                              'YYYY/MM/DD HH24:MI:SS'));

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_gl_per_number',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_gl_per_number));

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_ledger_dsp_cd',
        p_token2   => 'VAR_VAL',
        p_value2   => FEM_GL_POST_PROCESS_PKG.pv_ledger_dsp_cd);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_budget_dsp_cd',
        p_token2   => 'VAR_VAL',
        p_value2   => FEM_GL_POST_PROCESS_PKG.pv_budget_dsp_cd);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_enc_type_dsp_cd',
        p_token2   => 'VAR_VAL',
        p_value2   => FEM_GL_POST_PROCESS_PKG.pv_enc_type_dsp_cd);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd',
        p_token2   => 'VAR_VAL',
        p_value2   => FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'pv_schema_name',
        p_token2   => 'VAR_VAL',
        p_value2   => pv_schema_name);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'pv_allow_dis_mbrs_flag',
        p_token2   => 'VAR_VAL',
        p_value2   => pv_allow_dis_mbrs_flag);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity    => pc_log_level_procedure,
        p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_202',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Log_Package_Variables',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

   END Log_Pkg_Variables;


-- =======================================================================
-- Procedure
--   Process_Data_Slice
-- Purpose
--   This is the "engine push procedure" of the XGL Posting Engine
-- History
--   04-27-04   G Hall   Bug# 3597527: Created (moved code from Main)
--   05-25-04   G Hall   Added v_compl_code in call to Get_Proc_Key_Info.
--   06-25-09   G Hall   Bug 8543579 (FP for 11i bug 6826759/6007033):
--                       Added p_allow_dis_mbrs_flag parameter.
-- Arguments
--   x_slice_status_cd          0 = Successful; 1 = Warning; 2 = Failed. The
--                              subrequest will put this value into the
--                              STATUS colum in FEM_MP_PROCESS_CTL_T.
--   x_slice_msg                NULL if successful; end-user error message
--                              if failed with unexpected error. The
--                              subrequest will put this value into the
--                              MESSAGE colum in FEM_MP_PROCESS_CTL_T.
--   x_slice_errors_reprocessed For XGL, used for reporting the number of
--                              previous data errors successfully reprocessed.
--                              The subrequest will put this value into the
--                              ROWS_PROCESSED column in FEM_MP_PROCESS_CTL_T.
--   x_slice_output_rows        The number of rows inserted or merged into
--                              FEM_BALANCES for the current data slice. The
--                              subrequest will put this value into the
--                              ROWS_LOADED column in FEM_MP_PROCESS_CTL_T.
--   x_slice_errors_reported    The total number of rows not loaded due to
--                              data errors (whether it's a new error or an
--                              old one still not successfully reprocessed).
--                              The subrequest will put this value into the
--                              ROWS_REJECTED column in FEM_MP_PROCESS_CTL_T.
--   p_eng_sql                  Engine SQL statement shell.  From the P_ENG_SQL
--                              parameter passed to the MP Master. For XGL, it
--                              contains a table partitioning clause appropriate
--                              for the data slice (or will be NULL for no table
--                              partitioning).
--   p_data_slice_predicate     Example:
--                                NATURAL_ACCOUNT_DISPLAY_CODE IS BETWEEN
--                                'AAA-XXX-192' AND 'BBB-YYY-104'
--   p_process_number           Identifies the calling Subrequest.
--   p_slice_id                 Uniquely identifies the data slice.
--   p_fetch_limit              For use with BULK COLLECT INTO; not used by the
--                              XGL engine.
--   The following parameters are the ones passed to the MP Master procedure
--   as P_ARG1 to P_ARG17.  The concurrent subrequests pass these parameters
--   positionally to Process_Data_Slice.
--                              Corresponding FEM_GL_POST_PROCESS_PKG
--                              Package Variable:
--   p_req_id                   pv_req_id
--   p_exec_mode                pv_exec_mode
--   p_rule_obj_id              pv_rule_obj_id
--   p_dataset_code             pv_dataset_code
--   p_cal_period_id            pv_cal_period_id
--   p_ledger_id                pv_ledger_id
--   p_qtd_ytd_code             pv_qtd_ytd_code
--   p_entered_crncy_flag       pv_entered_crncy_flag
--   p_cal_per_dim_grp_dsp_cd   pv_cal_per_dim_grp_dsp_cd
--   p_cal_per_end_date         pv_cal_per_end_date
--   p_gl_per_number            pv_gl_per_number
--   p_ledger_dsp_cd            pv_ledger_dsp_cd
--   p_budget_dsp_cd            pv_budget_dsp_cd
--   p_enc_type_dsp_cd          pv_enc_type_dsp_cd
--   p_ds_balance_type_cd       pv_ds_balance_type_cd
--   p_schema_name              pv_schema_name (in this package)
--   p_allow_dis_mbrs_flag      pv_allow_dis_mbrs_flag (in this package)
-- =======================================================================

   PROCEDURE Process_Data_Slice
              (x_slice_status_cd          OUT NOCOPY NUMBER,
               x_slice_msg                OUT NOCOPY VARCHAR2,
               x_slice_errors_reprocessed OUT NOCOPY NUMBER,
               x_slice_output_rows        OUT NOCOPY NUMBER,
               x_slice_errors_reported    OUT NOCOPY NUMBER,
               p_eng_sql                  IN  VARCHAR2,
               p_data_slice_predicate     IN  VARCHAR2,
               p_process_number           IN  NUMBER,
               p_slice_id                 IN  NUMBER,
               p_fetch_limit              IN  NUMBER,
               p_req_id                   IN  VARCHAR2,
               p_exec_mode                IN  VARCHAR2,
               p_rule_obj_id              IN  VARCHAR2,
               p_dataset_code             IN  VARCHAR2,
               p_cal_period_id            IN  VARCHAR2,
               p_ledger_id                IN  VARCHAR2,
               p_qtd_ytd_code             IN  VARCHAR2,
               p_entered_crncy_flag       IN  VARCHAR2,
               p_cal_per_dim_grp_dsp_cd   IN  VARCHAR2,
               p_cal_per_end_date         IN  VARCHAR2,
               p_gl_per_number            IN  VARCHAR2,
               p_ledger_dsp_cd            IN  VARCHAR2,
               p_budget_dsp_cd            IN  VARCHAR2,
               p_enc_type_dsp_cd          IN  VARCHAR2,
               p_ds_balance_type_cd       IN  VARCHAR2,
               p_schema_name              IN  VARCHAR2,
               p_allow_dis_mbrs_flag      IN  VARCHAR2) IS

       v_compl_code                NUMBER;

       v_rows_marked               NUMBER;
       v_posted_rows               NUMBER;
       v_prev_err_rows_reproc      NUMBER;
       v_cur_data_err_rows         NUMBER;

       v_tot_rows_marked           NUMBER;
       v_tot_posted_rows           NUMBER;
       v_tot_prev_err_rows_reproc  NUMBER;
       v_tot_cur_data_err_rows     NUMBER;

       TYPE LoadSetCursor IS REF CURSOR;
       GetLoadSet_Cursor  LoadSetCursor;

       v_incr_cursor_stmt          VARCHAR2(32767);
       v_err_cursor_stmt           VARCHAR2(32767);

       v_curr_load_set_id          NUMBER;

       FEMXGL_fatal_err            EXCEPTION;

   BEGIN

      FEM_GL_POST_PROCESS_PKG.pv_sqlerrm := NULL;

      pv_process_slice := '{p' || TO_CHAR(p_process_number) || ':s' ||
                          TO_CHAR(p_slice_id) || '}';

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_procedure,
        p_module   => 'fem.plsql.xgl_eng.pds.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_201',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Process_Data_Slice',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.pds.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'p_process_number',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(p_process_number));

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.pds.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'p_slice_id',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(p_slice_id));

      v_tot_rows_marked          := 0;
      v_tot_cur_data_err_rows    := 0;
      v_tot_prev_err_rows_reproc := 0;
      v_tot_posted_rows          := 0;

      IF NOT pv_pkg_variables_reset THEN

      -- Reset the FEM_GL_POST_PROCESS_PKG package variables from the last
      -- 16 parameters to Process_Data_Slice, for use by this procedure and/
      -- or the procedures it calls, and populate the processing key info
      -- structure.  The values will be available for the duration of the
      -- calling subrequst's session, i.e. for subsequent invocations of
      -- Process_Data_Slice, so this only needs to be done once per subrequest.

         FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_event,
           p_module   => 'fem.plsql.xgl_eng.lpv.' || pv_process_slice,
           p_msg_text => 'First data slice for subrequest; ' ||
                         'resetting package variables from input parameters.');

         FEM_GL_POST_PROCESS_PKG.pv_req_id :=
           TO_NUMBER(p_req_id);
         FEM_GL_POST_PROCESS_PKG.pv_exec_mode :=
           p_exec_mode;
         FEM_GL_POST_PROCESS_PKG.pv_rule_obj_id :=
           TO_NUMBER(p_rule_obj_id);
         FEM_GL_POST_PROCESS_PKG.pv_dataset_code :=
           TO_NUMBER(p_dataset_code);
         FEM_GL_POST_PROCESS_PKG.pv_cal_period_id :=
           TO_NUMBER(p_cal_period_id);
         FEM_GL_POST_PROCESS_PKG.pv_ledger_id :=
           TO_NUMBER(p_ledger_id);
         FEM_GL_POST_PROCESS_PKG.pv_qtd_ytd_code :=
           p_qtd_ytd_code;
         FEM_GL_POST_PROCESS_PKG.pv_entered_crncy_flag :=
           p_entered_crncy_flag;
         FEM_GL_POST_PROCESS_PKG.pv_cal_per_dim_grp_dsp_cd :=
           p_cal_per_dim_grp_dsp_cd;
         FEM_GL_POST_PROCESS_PKG.pv_cal_per_end_date :=
           TO_DATE(p_cal_per_end_date, 'YYYY/MM/DD HH24:MI:SS');
         FEM_GL_POST_PROCESS_PKG.pv_gl_per_number :=
           TO_NUMBER(p_gl_per_number);
         FEM_GL_POST_PROCESS_PKG.pv_ledger_dsp_cd :=
           p_ledger_dsp_cd;
         FEM_GL_POST_PROCESS_PKG.pv_budget_dsp_cd :=
           p_budget_dsp_cd;
         FEM_GL_POST_PROCESS_PKG.pv_enc_type_dsp_cd :=
           p_enc_type_dsp_cd;
         FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd :=
           p_ds_balance_type_cd;

         pv_schema_name := p_schema_name;
         pv_allow_dis_mbrs_flag := p_allow_dis_mbrs_flag;

         Log_Pkg_Variables;

      -- Get the Processing Key information

         FEM_GL_POST_PROCESS_PKG.pv_sqlerrm := NULL;

         FEM_GL_POST_PROCESS_PKG.Get_Proc_Key_Info
           (p_process_slice   => pv_process_slice,
            x_completion_code => v_compl_code);

         IF v_compl_code = 2 THEN
            RAISE FEMXGL_fatal_err;
         END IF;

         pv_pkg_variables_reset := TRUE;

      END IF;

      pv_data_slice_predicate := p_data_slice_predicate;
      pv_partition_clause := p_eng_sql;

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_event,
        p_module   => 'fem.plsql.xgl_eng.pds.' || pv_process_slice,
        p_msg_text => 'pv_data_slice_predicate: ' || pv_data_slice_predicate);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_event,
        p_module   => 'fem.plsql.xgl_eng.pc.' || pv_process_slice,
        p_msg_text => 'pv_partition_clause: ' || pv_partition_clause);

   -- Set the unique Request ID for this data slice:
      pv_req_id_slice := p_req_id + p_slice_id / 100000;

      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => 'fem.plsql.xgl_eng.pds.' || pv_process_slice,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'pv_req_id_slice',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(pv_req_id_slice));

   -- -------------------------------------------------------------------
   -- Comment by SKUNG for Initial 5i Release:
   --   First, we will process all snapshot rows.  This is because
   --   we need to ignore the LOAD_SET_ID column and process all
   --   snapshot rows in a single pass.
   --   For Snapshot loads, this pass will process everything relevant.
   --   For Incremental and Error Reprocessing loads, this pass will
   --   process all Snapshot rows marked with errors from a previous
   --   run.  This is because we need to post all Snapshot rows before
   --   posting the incremental rows.
   --
   --   In this pass, rows will be marked for processing according
   --   to the following rules:
   --   1) Snapshot loads
   --      All snapshot rows for this ledger/Cal. Period/Dataset
   --      will be picked up, regardless of whether it is a brand
   --      new record or whether it is marked with an error from
   --      previous runs.
   --   2) Incremental and Error Reprocessing loads
   --      All snapshot rows for this ledger/Cal. Period/Dataset
   --      marked with errors will be picked up.
   --
   --  This pass is done by calling sub-routine Post_Cycle_Handler
   --  when package variable pv_snapshot_rows_done is FALSE
   -- -------------------------------------------------------------------

      pv_snapshot_rows_done    := FALSE;
      pv_incr_marking_sql_done := FALSE;

      v_rows_marked          := 0;
      v_posted_rows          := 0;
      v_cur_data_err_rows    := 0;
      v_prev_err_rows_reproc := 0;

      Post_Cycle_Handler
        (p_load_set_id          => 1,
         x_completion_code      => v_compl_code,
         x_rows_marked          => v_rows_marked,
         x_posted_row_num       => v_posted_rows,
         x_prev_err_rows_reproc => v_prev_err_rows_reproc,
         x_cur_data_err_rows    => v_cur_data_err_rows);

      IF v_compl_code = 2 THEN
         RAISE FEMXGL_fatal_err;
      END IF;

      pv_snapshot_rows_done := TRUE;

      v_tot_rows_marked := v_tot_rows_marked + v_rows_marked;
      v_tot_posted_rows := v_tot_posted_rows + v_posted_rows;
      v_tot_prev_err_rows_reproc :=
         v_tot_prev_err_rows_reproc + v_prev_err_rows_reproc;
      v_tot_cur_data_err_rows :=
         v_tot_cur_data_err_rows + v_cur_data_err_rows;

   -- ------------------------------------------------------------
   -- Delete successfully posted rows (snapshot) from
   -- FEM_BAL_INTERFACE_T.
   -- ------------------------------------------------------------

      DELETE FROM fem_bal_interface_t
      WHERE posting_request_id = pv_req_id_slice
        AND posting_error_code is NULL
        AND load_method_code = 'S';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.xgl_eng.pds.' ||
                       pv_process_slice || '.ss_rows_del',
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_218',
         p_token1   => 'NUM',
         p_value1   => TO_CHAR(SQL%ROWCOUNT),
         p_token2   => 'TABLE',
         p_value2   => 'FEM_BAL_INTERFACE_T');

   -- ------------------------------------------------------------
   -- Truncate FEM_BAL_POST_INTERIM_GT for the next set
   -- ------------------------------------------------------------

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.xgl_eng.pds.' ||
                       pv_process_slice || '.ss_trunc',
         p_msg_text =>
           'Truncating FEM_BAL_POST_INTERIM_GT for the next set');

      EXECUTE IMMEDIATE
            'TRUNCATE TABLE ' || pv_schema_name || '.fem_bal_post_interim_gt';

      COMMIT;

   -- ---------------------------------------------------------
   -- Comment by SKUNG for Initial 5i Release:
   --   Now for Incremental or Error Reprocessing loads, start
   --   posting records one load set at a time
   -- ---------------------------------------------------------

      IF (FEM_GL_POST_PROCESS_PKG.pv_exec_mode <> 'S') THEN

      -- -------------------------------------------------------------------
      -- Open the appropriate cursor based on execution mode to get load
      -- sets for processing.
      -- NOTE: We really should include the data slice predicate in these
      --       queries, to eliminate all the load sets that do not have
      --       any data for the current data slice.  This will reduce the
      --       number of loop iterations.  The reduction can be significant
      --       depending on the data slicing columns chosen and other
      --       factors.  However, the statements are using bind variables,
      --       which enables statement reuse in the SGA.  But until we
      --       implement the Bind Variables Push method in the MP Framework,
      --       we can't include the data slice predicate without making
      --       the statement different for each data slice.
      --       These cursor statements can also be made more efficient by
      --       implementing separate code paths for actuals, budget, and
      --       encumbrance type.
      -- -------------------------------------------------------------------

      -- IF (NOT GetLoadSet_Cursor%ISOPEN) THEN        Why do we need this?

         IF (FEM_GL_POST_PROCESS_PKG.pv_exec_mode = 'I') THEN

            v_incr_cursor_stmt :=
              'SELECT DISTINCT load_set_id ' ||
              'FROM fem_bal_interface_t ' ||
              'WHERE load_method_code = ''I'' ' ||
              'AND cal_per_dim_grp_display_code = :cal_per_dim_grp_dsp_cd ' ||
              'AND cal_period_end_date = :cal_per_end_date ' ||
              'AND cal_period_number = :cal_gl_per_num ' ||
              'AND ledger_display_code = :ledger_dsp_cd ' ||
              'AND (budget_display_code = :budget_dsp_cd ' ||
              'OR :budget_dsp_cd is NULL) ' ||
              'AND (encumbrance_type_code = :enc_type_dsp_cd ' ||
              'OR :enc_type_dsp_cd is NULL) ' ||
              'ORDER BY load_set_id ASC';

            FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_statement,
              p_module   => 'fem.plsql.xgl_eng.pds.' ||
                            pv_process_slice || '.incr_crs_stmt',
              p_app_name => 'FEM',
              p_msg_name => 'FEM_GL_POST_204',
              p_token1   => 'VAR_NAME',
              p_value1   => 'v_incr_cursor_stmt',
              p_token2   => 'VAR_VAL',
              p_value2   => v_incr_cursor_stmt);

            OPEN GetLoadSet_Cursor FOR v_incr_cursor_stmt
            USING  FEM_GL_POST_PROCESS_PKG.pv_cal_per_dim_grp_dsp_cd,
                   TO_DATE(TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_cal_per_end_date, 'YYYY/MM/DD HH24:MI:SS'),
                           'YYYY/MM/DD HH24:MI:SS'),
                   FEM_GL_POST_PROCESS_PKG.pv_gl_per_number,
                   FEM_GL_POST_PROCESS_PKG.pv_ledger_dsp_cd,
                   FEM_GL_POST_PROCESS_PKG.pv_budget_dsp_cd,
                   FEM_GL_POST_PROCESS_PKG.pv_budget_dsp_cd,
                   FEM_GL_POST_PROCESS_PKG.pv_enc_type_dsp_cd,
                   FEM_GL_POST_PROCESS_PKG.pv_enc_type_dsp_cd;

         ELSIF (FEM_GL_POST_PROCESS_PKG.pv_exec_mode = 'E') THEN

            v_err_cursor_stmt :=
              'SELECT DISTINCT load_set_id ' ||
              'FROM fem_bal_interface_t ' ||
              'WHERE posting_error_code is NOT NULL ' ||
              'AND load_method_code = ''I'' ' ||
              'AND cal_per_dim_grp_display_code = :cal_per_dim_grp_dsp_cd ' ||
              'AND cal_period_end_date = :cal_per_end_date ' ||
              'AND cal_period_number = :cal_gl_per_num ' ||
              'AND ledger_display_code = :ledger_dsp_cd ' ||
              'AND (budget_display_code = :budget_dsp_cd ' ||
              'OR :budget_dsp_cd is NULL) ' ||
              'AND (encumbrance_type_code = :enc_type_dsp_cd ' ||
              'OR :enc_type_dsp_cd is NULL) ' ||
              'ORDER BY load_set_id ASC';

            FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_statement,
              p_module   => 'fem.plsql.xgl_eng.pds.' ||
                            pv_process_slice || '.err_crs_stmt',
              p_msg_text => 'v_err_cursor_stmt: ' || v_err_cursor_stmt);

            OPEN GetLoadSet_Cursor FOR v_err_cursor_stmt
            USING  FEM_GL_POST_PROCESS_PKG.pv_cal_per_dim_grp_dsp_cd,
                   TO_DATE(TO_CHAR(FEM_GL_POST_PROCESS_PKG.pv_cal_per_end_date, 'YYYY/MM/DD HH24:MI:SS'),
                           'YYYY/MM/DD HH24:MI:SS'),
                   FEM_GL_POST_PROCESS_PKG.pv_gl_per_number,
                   FEM_GL_POST_PROCESS_PKG.pv_ledger_dsp_cd,
                   FEM_GL_POST_PROCESS_PKG.pv_budget_dsp_cd,
                   FEM_GL_POST_PROCESS_PKG.pv_budget_dsp_cd,
                   FEM_GL_POST_PROCESS_PKG.pv_enc_type_dsp_cd,
                   FEM_GL_POST_PROCESS_PKG.pv_enc_type_dsp_cd;
         END IF;

      -- END IF; If cursor is open  -- why needed?

      -- -------------------------------------------------------------------
      -- Post incremental rows one load set at a time, in load set order.
      -- -------------------------------------------------------------------

         LOOP

            FETCH GetLoadSet_Cursor INTO v_curr_load_set_id;

         EXIT WHEN GetLoadSet_Cursor%NOTFOUND OR
                   GetLoadSet_Cursor%NOTFOUND IS NULL;

            FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_statement,
              p_module   => 'fem.plsql.xgl_eng.pds.' ||
                            pv_process_slice || '.load_set',
              p_app_name => 'FEM',
              p_msg_name => 'FEM_GL_POST_210',
              p_token1   => 'LOAD_SET_ID',
              p_value1   => TO_CHAR(v_curr_load_set_id));

         -- ------------------------------------------------------
         -- Process incremental rows for current load set
         -- ------------------------------------------------------

            v_rows_marked          := 0;
            v_posted_rows          := 0;
            v_cur_data_err_rows    := 0;
            v_prev_err_rows_reproc := 0;

            Post_Cycle_Handler
              (p_load_set_id          => v_curr_load_set_id,
               x_completion_code      => v_compl_code,
               x_rows_marked          => v_rows_marked,
               x_posted_row_num       => v_posted_rows,
               x_prev_err_rows_reproc => v_prev_err_rows_reproc,
               x_cur_data_err_rows    => v_cur_data_err_rows);

            IF v_compl_code = 2 THEN
               RAISE FEMXGL_fatal_err;
            END IF;

            pv_incr_marking_sql_done := TRUE;

            v_tot_rows_marked := v_tot_rows_marked + v_rows_marked;
            v_tot_posted_rows := v_tot_posted_rows + v_posted_rows;
            v_tot_prev_err_rows_reproc :=
               v_tot_prev_err_rows_reproc + v_prev_err_rows_reproc;
            v_tot_cur_data_err_rows :=
               v_tot_cur_data_err_rows + v_cur_data_err_rows;

         -- ------------------------------------------------------------
         -- Delete successfully posted rows (incremental) from
         -- FEM_BAL_INTERFACE_T.
         -- ------------------------------------------------------------

            DELETE FROM fem_bal_interface_t
            WHERE posting_request_id = pv_req_id_slice
              AND posting_error_code is NULL
              AND load_method_code = 'I'
              AND load_set_id = v_curr_load_set_id;

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.xgl_eng.pds.' ||
                             pv_process_slice || '.incr_rows_del',
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_218',
               p_token1   => 'NUM',
               p_value1   => TO_CHAR(SQL%ROWCOUNT),
               p_token2   => 'TABLE',
               p_value2   => 'FEM_BAL_INTERFACE_T');

         -- ------------------------------------------------------------
         -- Truncate FEM_BAL_POST_INTERIM_GT for the next set
         -- ------------------------------------------------------------

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.xgl_eng.pds.' ||
                             pv_process_slice || '.incr_trunc',
               p_msg_text =>
                 'Truncating FEM_BAL_POST_INTERIM_GT for the next set');

            EXECUTE IMMEDIATE
              'TRUNCATE TABLE ' || pv_schema_name || '.fem_bal_post_interim_gt';

            COMMIT;

         END LOOP;  -- For Load set looping

         CLOSE GetLoadSet_Cursor;

      END IF;  -- IF (FEM_GL_POST_PROCESS_PKG.pv_exec_mode <> 'S')...

      x_slice_errors_reprocessed := v_tot_prev_err_rows_reproc;
      x_slice_output_rows        := v_tot_posted_rows;
      x_slice_errors_reported    := v_tot_cur_data_err_rows;

      IF v_tot_posted_rows = 0 THEN

         IF v_tot_rows_marked = 0 THEN
         -- Note: this should never happen!
            x_slice_msg := 'NO_DATA';
         ELSIF v_tot_cur_data_err_rows = v_rows_marked THEN
            x_slice_msg := 'ALL_ERRORS';
         END IF;

         x_slice_status_cd := 1;

      ELSIF v_tot_cur_data_err_rows > 0 THEN

         x_slice_msg := 'SOME_ERRORS';
         x_slice_status_cd := 1;

      ELSE

         x_slice_msg := NULL;
         x_slice_status_cd := 0;

      END IF;

      FEM_ENGINES_PKG.Tech_Message
       (p_severity    => pc_log_level_procedure,
        p_module   => 'fem.plsql.xgl_eng.pds',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_202',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Process_Data_Slice',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

   EXCEPTION

      WHEN FEMXGL_fatal_err THEN

      -- Messages have already been logged where they occurred

      -- Set the OUT parameters

         x_slice_errors_reprocessed := v_tot_prev_err_rows_reproc;
         x_slice_output_rows        := v_tot_posted_rows;
         x_slice_errors_reported    := v_tot_cur_data_err_rows;
         x_slice_msg                := FEM_GL_POST_PROCESS_PKG.pv_sqlerrm;
         x_slice_status_cd          := 2;

      -- Reset error code for remaing rows not processed which were
      -- errors before, so they'll be reprocessed by the next run.

         UPDATE fem_bal_interface_t
         SET posting_error_code = 'FEM_GL_POST_TO_BE_REPROCESSED'
         WHERE posting_request_id = pv_req_id_slice
           AND posting_error_code is NULL
           AND previous_error_flag = 'Y';

         COMMIT;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_procedure,
          p_module   => 'fem.plsql.xgl_eng.pds.' ||
                        pv_process_slice || '.fatal_err',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_203',
          p_token1   => 'FUNC_NAME',
          p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Process_Data_Slice',
          p_token2   => 'TIME',
          p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      WHEN OTHERS THEN

         IF FEM_GL_POST_PROCESS_PKG.pv_sqlerrm IS NULL THEN
            FEM_GL_POST_PROCESS_PKG.pv_sqlerrm := SQLERRM;
         END IF;

         ROLLBACK;

      -- Log the Oracle error message to FND_LOG with the
      -- "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.xgl_eng.pds.' ||
                          pv_process_slice || '.unexpected_exception',
            p_msg_text => FEM_GL_POST_PROCESS_PKG.pv_sqlerrm);

      -- Log the Oracle error message to the Concurrent Request Log.

         FEM_ENGINES_PKG.User_Message
           (p_msg_text => FEM_GL_POST_PROCESS_PKG.pv_sqlerrm);

      -- Set the OUT parameters

         x_slice_errors_reprocessed := v_tot_prev_err_rows_reproc;
         x_slice_output_rows        := v_tot_posted_rows;
         x_slice_errors_reported    := v_tot_cur_data_err_rows;
         x_slice_msg                := FEM_GL_POST_PROCESS_PKG.pv_sqlerrm;
         x_slice_status_cd          := 2;

      -- Reset error code for remaing rows not processed which were
      -- errors before, so they'll be reprocessed by the next run.

         UPDATE fem_bal_interface_t
         SET posting_error_code = 'FEM_GL_POST_TO_BE_REPROCESSED'
         WHERE posting_request_id = pv_req_id_slice
           AND posting_error_code is NULL
           AND previous_error_flag = 'Y';

         COMMIT;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_procedure,
          p_module   => 'fem.plsql.xgl_eng.pds.' ||
                        pv_process_slice || '.unexpected_exception',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_203',
          p_token1   => 'FUNC_NAME',
          p_value1   => 'FEM_XGL_POST_ENGINE_PKG.Process_Data_Slice',
          p_token2   => 'TIME',
          p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

   END Process_Data_Slice;
-- =======================================================================

END FEM_XGL_POST_ENGINE_PKG;

/
