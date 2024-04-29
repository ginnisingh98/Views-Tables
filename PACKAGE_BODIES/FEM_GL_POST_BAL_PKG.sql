--------------------------------------------------------
--  DDL for Package Body FEM_GL_POST_BAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_GL_POST_BAL_PKG" AS
/* $Header: fem_gl_post_bal.plb 120.3 2005/12/02 19:56:20 mikeward ship $  */

  FUNCTION Get_Next_Creation_Row_Seq RETURN NUMBER IS
   seq_number  NUMBER;
  BEGIN
    SELECT fem_gl_post_creation_row_s.nextval
    INTO   seq_number
    FROM   DUAL;

    RETURN seq_number;
  END Get_Next_Creation_Row_Seq;


  --  =========================================================================
  --  Procedure
  --     Post_Fem_Balances
  --
  --  Purpose
  --     This routine post data from FEM_BAL_POST_INTERIM_GT to FEM_BALANCES.
  --
  --     If execution mode is Snapshot, this procedure will do an insert into
  --     FEM_BALANCES from FEM_BAL_POST_INTERIM_GT.
  --
  --     If execution mode is Incremental, this procedure will do a merge into
  --     FEM_BALANCES from FEM_BAL_POST_INTERIM_GT.  It'll update the rows
  --     if the processing keys between the two tables match.  Otherwise, it'll
  --     do an insert into FEM_BALANCES.
  --
  --  History
  --     10-15-2003   W Wong Created
  --
  --  Arguments
  --     p_execution_mode  Execution Mode
  --     p_process_slice   A character string concatenation of the MP FW
  --                       subrequest process number and the data slice id
  --                       for distinguishing messages logged by different
  --                       executions of FEM_XGL_ENGINE_PKG.Process_Data_Slice.
  --     x_rows_posted     Total number of rows inserted/merged into
  --                       FEM_BALANCES
  --     x_completion_code 0 for success, 2 for failure
  --  ==========================================================================

  PROCEDURE Post_Fem_Balances
               (p_execution_mode     IN            VARCHAR2,
                p_process_slice      IN            VARCHAR2,
                x_rows_posted        IN OUT NOCOPY NUMBER,
                x_completion_code    IN OUT NOCOPY NUMBER) IS
  BEGIN
    Post_Fem_Balances(
   p_execution_mode  => p_execution_mode,
   p_process_slice      => p_process_slice,
   p_load_type    => 'XGL',
   p_maintain_qtd    => 'N',
        p_bsv_range_low    => NULL,
   p_bsv_range_high  => NULL,
   x_rows_posted     => x_rows_posted,
   x_completion_code => x_completion_code);
  END Post_Fem_Balances;




  --  =========================================================================
  --  Procedure
  --     Post_Fem_Balances
  --
  --  Purpose
  --     This routine post data from FEM_BAL_POST_INTERIM_GT to FEM_BALANCES.
  --
  --     If execution mode is Snapshot, this procedure will do an insert into
  --     FEM_BALANCES from FEM_BAL_POST_INTERIM_GT.
  --
  --     If execution mode is Incremental, this procedure will do a merge into
  --     FEM_BALANCES from FEM_BAL_POST_INTERIM_GT.  It'll update the rows
  --     if the processing keys between the two tables match.  Otherwise, it'll
  --     do an insert into FEM_BALANCES.
  --
  --  History
  --     10-15-2003   W Wong Created
  --
  --  Arguments
  --     p_execution_mode  Execution Mode
  --     p_process_slice   A character string concatenation of the MP FW
  --                       subrequest process number and the data slice id
  --                       for distinguishing messages logged by different
  --                       executions of FEM_XGL_ENGINE_PKG.Process_Data_Slice.
  --     p_bsv_range_low   Low value for the range of balancing segment
  --                       values to be filtered in
  --     p_bsv_range_high  High value for the range of balancing segment
  --                       values to be filtered in
  --     x_rows_posted     Total number of rows inserted/merged into
  --                       FEM_BALANCES
  --     x_completion_code 0 for success, 2 for failure
  --  ==========================================================================

  PROCEDURE Post_Fem_Balances
               (p_execution_mode     IN            VARCHAR2,
                p_process_slice      IN            VARCHAR2,
                p_load_type          IN            VARCHAR2,
                p_maintain_qtd       IN            VARCHAR2,
                p_bsv_range_low      IN            VARCHAR2,
                p_bsv_range_high     IN            VARCHAR2,
                x_rows_posted        IN OUT NOCOPY NUMBER,
                x_completion_code    IN OUT NOCOPY NUMBER) IS

    DATA_CORRUPTION                 EXCEPTION;
    PROC_KEY_ERROR                  EXCEPTION;

    v_log_level_1                   NUMBER;
    v_log_level_2                   NUMBER;
    v_log_level_3                   NUMBER;
    v_log_level_4                   NUMBER;
    v_log_level_5                   NUMBER;
    v_log_level_6                   NUMBER;

    v_sql_stmt                      VARCHAR2(8000);
    v_sql_stmt_2                    VARCHAR2(24000);
    v_key_stmt                      VARCHAR2(4000);
    v_first_time                    VARCHAR2(1);
    v_interim_row_count             NUMBER;
    v_count                         NUMBER;

    pv_req_id                       NUMBER;
    pv_rule_obj_id                  NUMBER;
    pv_proc_key_dim_num             NUMBER;
    pv_ledger_id                    NUMBER;
    pv_col                          VARCHAR2(30);

    v_merge_select                  VARCHAR2(4000);
    v_req_text                      VARCHAR2(100);

    v_na_dim_id         NUMBER;
    v_xat_dim_id     NUMBER;

    v_na_xat_attr_id    NUMBER;
    v_na_xat_v_id    NUMBER;
    v_xat_bat_attr_id      NUMBER;
    v_xat_bat_v_id      NUMBER;

    v_cp_period_num_attr_id         NUMBER;
    v_cp_period_num_v_id            NUMBER;
    v_cp_year_attr_id               NUMBER;
    v_cp_year_v_id                  NUMBER;

    v_ps_name        VARCHAR2(100);
    v_period_type    VARCHAR2(100);

    v_error_code                    NUMBER;

    v_completion_code               NUMBER;
  BEGIN

    v_log_level_1 := fnd_log.level_statement;
    v_log_level_2 := fnd_log.level_procedure;
    v_log_level_3 := fnd_log.level_event;
    v_log_level_4 := fnd_log.level_exception;
    v_log_level_5 := fnd_log.level_error;
    v_log_level_6 := fnd_log.level_unexpected;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => v_log_level_2,
       p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
       p_msg_text => 'BEGIN FEM_GL_POST_BAL_PKG.Post_FEM_Balances');

    IF p_load_type = 'OGL' THEN
      fem_gl_post_process_pkg.get_proc_key_info(p_process_slice, v_completion_code);
      IF v_completion_code = 2 THEN
        x_completion_code := 2;
        raise PROC_KEY_ERROR;
      END IF;
    END IF;
    -----------------------------------------------------------------------
    -- Retrive package variables from FEM_GL_POST_PROCESS_PKG and find
    -- out some attribute information before we insert/merge data into
    -- the FEM_BALANCES table
    -----------------------------------------------------------------------
    pv_req_id           := FEM_GL_POST_PROCESS_PKG.pv_req_id;
    pv_rule_obj_id      := FEM_GL_POST_PROCESS_PKG.pv_rule_obj_id;
    pv_proc_key_dim_num := FEM_GL_POST_PROCESS_PKG.pv_proc_key_dim_num;
    pv_ledger_id        := FEM_GL_POST_PROCESS_PKG.pv_ledger_id;

    -----------------------------------------------------------------------
    -- IF the executaion mode is Snapshot mode, we will insert data from
    -- the interim table to FEM_BALANCES.
    -- ELSE if the execution mode is Incremental, we will try to merge
    -- data into FEM_BALANCES if the processing keys between the interim
    -- table and FEM_BALANCES matches. Otherwise we'll insert the data.
    -----------------------------------------------------------------------

    IF (p_execution_mode = 'S') THEN

      IF p_load_type = 'XGL' THEN
        v_req_text := '   :pv_req_id, ';
      ELSE
        v_req_text := '   param.request_id, ';
      END IF;

      -- Insert data from FEM_BAL_POST_INTERIM_GT into FEM_BALANCES
      v_sql_stmt :=
      'INSERT INTO fem_balances '||
      ' ( '||
      '   dataset_code, '||
      '   cal_period_id, '||
      '   creation_row_sequence, '||
      '   source_system_code, '||
      '   ledger_id, '||
      '   company_cost_center_org_id, '||
      '   currency_code, '||
      '   currency_type_code, '||
      '   financial_elem_id, '||
      '   product_id,        '||
      '   natural_account_id, '||
      '   channel_id, '||
      '   line_item_id, '||
      '   project_id, '||
      '   customer_id, '||
      '   intercompany_id, '||
      '   entity_id, '||
      '   task_id, '||
      '   user_dim1_id, '||
      '   user_dim2_id, '||
      '   user_dim3_id, '||
      '   user_dim4_id, '||
      '   user_dim5_id, '||
      '   user_dim6_id, '||
      '   user_dim7_id, '||
      '   user_dim8_id, '||
      '   user_dim9_id, '||
      '   user_dim10_id, '||
      '   created_by_request_id, '||
      '   created_by_object_id, '||
      '   last_updated_by_request_id, '||
      '   last_updated_by_object_id, '||
      '   xtd_balance_e, '||
      '   xtd_balance_f, '||
      '   ytd_balance_e, '||
      '   ytd_balance_f, '||
      '   qtd_balance_e, '||
      '   qtd_balance_f, '||
      '   ptd_debit_balance_e, '||
      '   ptd_credit_balance_e, '||
      '   ytd_debit_balance_e, '||
      '   ytd_credit_balance_e) '||
      ' SELECT '||
      '   bpi.dataset_code, '||
      '   bpi.cal_period_id, '||
      '   fem_gl_post_bal_pkg.get_next_creation_row_seq, '||
      '   bpi.source_system_code, '||
      '   bpi.ledger_id, '||
      '   bpi.company_cost_center_org_id, '||
      '   bpi.currency_code, '||
      '   bpi.currency_type_code, '||
      '   bpi.financial_elem_id, '||
      '   bpi.product_id, '||
      '   bpi.natural_account_id, '||
      '   bpi.channel_id, '||
      '   bpi.line_item_id, '||
      '   bpi.project_id, '||
      '   bpi.customer_id, '||
      '   bpi.intercompany_id, '||
      '   bpi.entity_id, '||
      '   bpi.task_id, '||
      '   bpi.user_dim1_id, '||
      '   bpi.user_dim2_id, '||
      '   bpi.user_dim3_id, '||
      '   bpi.user_dim4_id, '||
      '   bpi.user_dim5_id, '||
      '   bpi.user_dim6_id, '||
      '   bpi.user_dim7_id, '||
      '   bpi.user_dim8_id, '||
      '   bpi.user_dim9_id, '||
      '   bpi.user_dim10_id, ' ||
      v_req_text ||
      '   :pv_rule_obj_id, '||
      v_req_text ||
      '   :pv_rule_obj_id, '||
      '   sum(bpi.xtd_balance_e), '||
      '   sum(bpi.xtd_balance_f), '||
      '   sum(bpi.ytd_balance_e), '||
      '   sum(bpi.ytd_balance_f), '||
      '   sum(bpi.qtd_balance_e), '||
      '   sum(bpi.qtd_balance_f), '||
      '   sum(bpi.ptd_debit_balance_e), '||
      '   sum(bpi.ptd_credit_balance_e), '||
      '   sum(bpi.ytd_debit_balance_e), '||
      '   sum(bpi.ytd_credit_balance_e) '||
      ' FROM fem_bal_post_interim_gt bpi';

      IF p_load_type = 'OGL' THEN
        v_sql_stmt := v_sql_stmt || ', fem_intg_exec_params_gt param' ||
                                    ', gl_code_combinations cc';
      END IF;

      v_sql_stmt := v_sql_stmt ||
      ' WHERE bpi.posting_error_flag = ''N'' ';


      IF p_load_type = 'OGL' THEN
        v_sql_stmt := v_sql_stmt ||
        ' AND param.output_dataset_code = bpi.dataset_code ' ||
        ' AND param.cal_period_id = bpi.cal_period_id ' ||
        ' AND param.error_code IS NULL ' ||
        ' AND param.request_id IS NOT NULL ' ||
        ' AND cc.code_combination_id = bpi.code_combination_id ' ||
        ' AND NOT EXISTS ' ||
        ' (SELECT 1 ' ||
        '  FROM   FEM_INTG_DELTA_LOADS dl ' ||
        '  WHERE  dl.ledger_id = bpi.ledger_id ' ||
        '  AND    dl.dataset_code = bpi.dataset_code ' ||
        '  AND    dl.cal_period_id = bpi.cal_period_id ' ||
        '  AND    dl.delta_run_id = bpi.delta_run_id ' ||
        '  AND    dl.balance_seg_value = cc.' || FEM_GL_POST_PROCESS_PKG.pv_bsv_app_col_name || ' ' ||
        '  AND    dl.loaded_flag = ''N'')';
      END IF;

      v_sql_stmt := v_sql_stmt ||
      ' GROUP BY ' ||
      '   bpi.dataset_code, '||
      '   bpi.cal_period_id, '||
      '   bpi.source_system_code, '||
      '   bpi.ledger_id, '||
      '   bpi.company_cost_center_org_id, '||
      '   bpi.currency_code, '||
      '   bpi.currency_type_code, '||
      '   bpi.financial_elem_id, '||
      '   bpi.product_id, '||
      '   bpi.natural_account_id, '||
      '   bpi.channel_id, '||
      '   bpi.line_item_id, '||
      '   bpi.project_id, '||
      '   bpi.customer_id, '||
      '   bpi.intercompany_id, '||
      '   bpi.entity_id, '||
      '   bpi.task_id, '||
      '   bpi.user_dim1_id, '||
      '   bpi.user_dim2_id, '||
      '   bpi.user_dim3_id, '||
      '   bpi.user_dim4_id, '||
      '   bpi.user_dim5_id, '||
      '   bpi.user_dim6_id, '||
      '   bpi.user_dim7_id, '||
      '   bpi.user_dim8_id, '||
      '   bpi.user_dim9_id, '||
      '   bpi.user_dim10_id';

      IF p_load_type = 'OGL' THEN
        v_sql_stmt := v_sql_stmt || ', param.request_id';
      END IF;



      FOR iterator IN 1..trunc((length(v_sql_stmt)+1499)/1500) LOOP
        FEM_ENGINES_PKG.Tech_Message
        (p_severity => v_log_level_2,
         p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_sql_stmt: ' || iterator,
         p_token2   => 'VAR_VAL',
         p_value2   => substr(v_sql_stmt, iterator*1500-1499, 1500));
      END LOOP;

      IF p_load_type = 'XGL' THEN
        EXECUTE IMMEDIATE v_sql_stmt
        USING pv_req_id, pv_rule_obj_id, pv_req_id, pv_rule_obj_id;
      ELSE
        EXECUTE IMMEDIATE v_sql_stmt
        USING pv_rule_obj_id, pv_rule_obj_id;
      END IF;

      x_rows_posted := SQL%ROWCOUNT;

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => v_log_level_1,
       p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_216',
       p_token1   => 'NUM',
       p_value1   => TO_CHAR(x_rows_posted),
       p_token2   => 'TABLE',
       p_value2   => 'FEM_BALANCES');

    ELSE
      -- Find out primary keys for FEM_BALANCES and construct the ON clause for
      -- the Merge statement
      v_first_time := 'Y';
      v_key_stmt := '';

      FOR v IN 1..pv_proc_key_dim_num LOOP
         pv_col := FEM_GL_POST_PROCESS_PKG.pv_proc_keys(v).dim_col_name;

         IF (v_first_time = 'N') THEN
            v_key_stmt := v_key_stmt || ' AND ';
         END IF;

         IF (pv_col <> 'CREATED_BY_OBJECT_ID') THEN
            v_key_stmt := v_key_stmt || 'bal.' || pv_col || ' = int.' || pv_col;
         ELSE
            v_key_stmt := v_key_stmt || 'bal.' || pv_col || ' = ' || pv_rule_obj_id;
         END IF;

         v_first_time := 'N';
      END LOOP;

      -- The select statement to be used in the USING part of the merge statement
      IF p_load_type = 'XGL' THEN
        v_merge_select := 'SELECT * FROM FEM_BAL_POST_INTERIM_GT ' ||
                          'WHERE posting_error_flag = ''N''';
        v_req_text := ':pv_req_id';
      ELSE
        v_merge_select :=
'SELECT param.request_id, pi.bal_post_type_code, ' ||
'pi.dataset_code, pi.cal_period_id, pi.ledger_id, pi.currency_type_code, ' ||
'pi.currency_code, pi.company_cost_center_org_id, pi.source_system_code, ' ||
'pi.financial_elem_id, pi.product_id, pi.natural_account_id, ' ||
'pi.channel_id, pi.line_item_id, pi.project_id, pi.customer_id, ' ||
'pi.entity_id, pi.intercompany_id, pi.task_id, pi.user_dim1_id, ' ||
'pi.user_dim2_id, pi.user_dim3_id, pi.user_dim4_id, pi.user_dim5_id, ' ||
'pi.user_dim6_id, pi.user_dim7_id, pi.user_dim8_id, pi.user_dim9_id, ' ||
'pi.user_dim10_id, ' ||
'sum(pi.xtd_balance_e) xtd_balance_e, ' ||
'sum(pi.xtd_balance_f) xtd_balance_f, ' ||
'sum(pi.ytd_balance_e) ytd_balance_e, ' ||
'sum(pi.ytd_balance_f) ytd_balance_f, ' ||
'sum(pi.qtd_balance_e) qtd_balance_e, ' ||
'sum(pi.qtd_balance_f) qtd_balance_f, ' ||
'sum(pi.ptd_debit_balance_e) ptd_debit_balance_e, ' ||
'sum(pi.ptd_credit_balance_e) ptd_credit_balance_e, ' ||
'sum(pi.ytd_debit_balance_e) ytd_debit_balance_e, ' ||
'sum(pi.ytd_credit_balance_e) ytd_credit_balance_e ' ||
'FROM FEM_BAL_POST_INTERIM_GT pi, ' ||
'     FEM_INTG_EXEC_PARAMS_GT param, ' ||
'     GL_CODE_COMBINATIONS cc ' ||
'WHERE pi.dataset_code = param.output_dataset_code ' ||
'AND   pi.cal_period_id = param.cal_period_id ' ||
'AND   pi.posting_error_flag = ''N'' ' ||
'AND   cc.code_combination_id = pi.code_combination_id ' ||
'AND NOT EXISTS ' ||
'(SELECT 1 ' ||
' FROM   FEM_INTG_DELTA_LOADS dl ' ||
' WHERE  dl.ledger_id = pi.ledger_id ' ||
' AND    dl.dataset_code = pi.dataset_code ' ||
' AND    dl.cal_period_id = pi.cal_period_id ' ||
' AND    dl.delta_run_id = pi.delta_run_id ' ||
' AND    dl.balance_seg_value = cc.' || FEM_GL_POST_PROCESS_PKG.pv_bsv_app_col_name || ' ' ||
' AND    dl.loaded_flag = ''N'') ' ||
'GROUP BY param.request_id, pi.bal_post_type_code, ' ||
'pi.dataset_code, pi.cal_period_id, pi.ledger_id, pi.currency_type_code, ' ||
'pi.currency_code, pi.company_cost_center_org_id, pi.source_system_code, ' ||
'pi.financial_elem_id, pi.product_id, pi.natural_account_id, ' ||
'pi.channel_id, pi.line_item_id, pi.project_id, pi.customer_id, ' ||
'pi.entity_id, pi.intercompany_id, pi.task_id, pi.user_dim1_id, ' ||
'pi.user_dim2_id, pi.user_dim3_id, pi.user_dim4_id, pi.user_dim5_id, ' ||
'pi.user_dim6_id, pi.user_dim7_id, pi.user_dim8_id, pi.user_dim9_id, ' ||
'pi.user_dim10_id ';
        v_req_text := 'int.request_id';
      END IF;

      -- Merge data from FEM_BAL_POST_INTERIM_GT into FEM_BALANCES
      v_sql_stmt_2 :=
      ' MERGE INTO FEM_BALANCES bal '||
      ' USING (' || v_merge_select || ') int '||
      ' ON ( ' || v_key_stmt ||
      ')' ||
      ' WHEN MATCHED THEN UPDATE SET '||
        ' bal.xtd_balance_e = ' ||
          ' DECODE(int.bal_post_type_code, ''R'', int.xtd_balance_e, ' ||
                  'DECODE(bal.xtd_balance_e, NULL, int.xtd_balance_e, ' ||
                         'DECODE(int.xtd_balance_e, NULL, bal.xtd_balance_e, ' ||
                                'bal.xtd_balance_e + int.xtd_balance_e))), ' ||
        ' bal.xtd_balance_f = ' ||
          ' DECODE(int.bal_post_type_code, ''R'', int.xtd_balance_f, ' ||
                  'DECODE(bal.xtd_balance_f, NULL, int.xtd_balance_f, ' ||
                         'DECODE(int.xtd_balance_f, NULL, bal.xtd_balance_f, ' ||
                                'bal.xtd_balance_f + int.xtd_balance_f))), ' ||
        ' bal.ytd_balance_e = ' ||
          ' DECODE(int.bal_post_type_code, ''R'', int.ytd_balance_e, ' ||
                  'DECODE(bal.ytd_balance_e, NULL, int.ytd_balance_e, ' ||
                         'DECODE(int.ytd_balance_e, NULL, bal.ytd_balance_e, ' ||
                                'bal.ytd_balance_e + int.ytd_balance_e))), ' ||
        ' bal.ytd_balance_f = ' ||
          ' DECODE(int.bal_post_type_code, ''R'', int.ytd_balance_f, ' ||
                  'DECODE(bal.ytd_balance_f, NULL, int.ytd_balance_f, ' ||
                         'DECODE(int.ytd_balance_f, NULL, bal.ytd_balance_f, ' ||
                                'bal.ytd_balance_f + int.ytd_balance_f))), ' ||
        ' bal.qtd_balance_e = ' ||
          ' DECODE(int.bal_post_type_code, ''R'', int.qtd_balance_e, ' ||
                  'DECODE(bal.qtd_balance_e, NULL, int.qtd_balance_e, ' ||
                         'DECODE(int.qtd_balance_e, NULL, bal.qtd_balance_e, ' ||
                                'bal.qtd_balance_e + int.qtd_balance_e))), ' ||
        ' bal.qtd_balance_f = ' ||
          ' DECODE(int.bal_post_type_code, ''R'', int.qtd_balance_f, ' ||
                  'DECODE(bal.qtd_balance_f, NULL, int.qtd_balance_f, ' ||
                         'DECODE(int.qtd_balance_f, NULL, bal.qtd_balance_f, ' ||
                                'bal.qtd_balance_f + int.qtd_balance_f))), ' ||
        ' bal.ptd_debit_balance_e = ' ||
          ' DECODE(int.bal_post_type_code, ''R'', int.ptd_debit_balance_e, ' ||
                  'DECODE(bal.ptd_debit_balance_e, NULL, int.ptd_debit_balance_e, ' ||
                         'DECODE(int.ptd_debit_balance_e, NULL, bal.ptd_debit_balance_e, ' ||
                                'bal.ptd_debit_balance_e + int.ptd_debit_balance_e))), ' ||
        ' bal.ptd_credit_balance_e = ' ||
          ' DECODE(int.bal_post_type_code, ''R'', int.ptd_credit_balance_e, ' ||
                  'DECODE(bal.ptd_credit_balance_e, NULL, int.ptd_credit_balance_e, ' ||
                         'DECODE(int.ptd_credit_balance_e, NULL, bal.ptd_credit_balance_e, ' ||
                                'bal.ptd_credit_balance_e + int.ptd_credit_balance_e))), ' ||
        ' bal.ytd_debit_balance_e = ' ||
          ' DECODE(int.bal_post_type_code, ''R'', int.ytd_debit_balance_e, ' ||
                  'DECODE(bal.ytd_debit_balance_e, NULL, int.ytd_debit_balance_e, ' ||
                         'DECODE(int.ytd_debit_balance_e, NULL, bal.ytd_debit_balance_e, ' ||
                                'bal.ytd_debit_balance_e + int.ytd_debit_balance_e))), ' ||
        ' bal.ytd_credit_balance_e = ' ||
          ' DECODE(int.bal_post_type_code, ''R'', int.ytd_credit_balance_e, ' ||
                  'DECODE(bal.ytd_credit_balance_e, NULL, int.ytd_credit_balance_e, ' ||
                         'DECODE(int.ytd_credit_balance_e, NULL, bal.ytd_credit_balance_e, ' ||
                                'bal.ytd_credit_balance_e + int.ytd_credit_balance_e))), ' ||
        ' bal.last_updated_by_request_id = ' || v_req_text || ', '||
        ' bal.last_updated_by_object_id  = :pv_rule_obj_id '||
      ' WHEN NOT MATCHED THEN INSERT '||
                        ' ( bal.dataset_code, '||
                          ' bal.cal_period_id, '||
                          ' bal.creation_row_sequence, '||
                          ' bal.source_system_code, '||
                          ' bal.ledger_id, '||
                          ' bal.company_cost_center_org_id, '||
                          ' bal.currency_code, '||
                          ' bal.currency_type_code, '||
                          ' bal.financial_elem_id, '||
                          ' bal.product_id, '||
                          ' bal.natural_account_id, '||
                          ' bal.channel_id, '||
                          ' bal.line_item_id, '||
                          ' bal.project_id, '||
                          ' bal.customer_id, '||
                          ' bal.intercompany_id, '||
                          ' bal.entity_id, '||
                          ' bal.task_id, '||
                          ' bal.user_dim1_id, '||
                          ' bal.user_dim2_id, '||
                          ' bal.user_dim3_id, '||
                          ' bal.user_dim4_id, '||
                          ' bal.user_dim5_id, '||
                          ' bal.user_dim6_id, '||
                          ' bal.user_dim7_id, '||
                          ' bal.user_dim8_id, '||
                          ' bal.user_dim9_id, '||
                          ' bal.user_dim10_id, '||
                          ' bal.created_by_request_id, '||
                          ' bal.created_by_object_id, '||
                          ' bal.last_updated_by_request_id, '||
                          ' bal.last_updated_by_object_id, '||
                          ' bal.xtd_balance_e, '||
                          ' bal.xtd_balance_f, '||
                          ' bal.ytd_balance_e, '||
                          ' bal.ytd_balance_f, '||
                          ' bal.qtd_balance_e, '||
                          ' bal.qtd_balance_f, '||
                          ' bal.ptd_debit_balance_e, '||
                          ' bal.ptd_credit_balance_e, '||
                          ' bal.ytd_debit_balance_e, '||
                          ' bal.ytd_credit_balance_e) '||
                   ' VALUES (int.dataset_code, '||
                          ' int.cal_period_id, '||
                          ' fem_gl_post_creation_row_s.nextval, '||
                          ' int.source_system_code, '||
                          ' int.ledger_id, '||
                          ' int.company_cost_center_org_id, '||
                          ' int.currency_code, '||
                          ' int.currency_type_code, '||
                          ' int.financial_elem_id, '||
                          ' int.product_id, '||
                          ' int.natural_account_id, '||
                          ' int.channel_id, '||
                          ' int.line_item_id, '||
                          ' int.project_id, '||
                          ' int.customer_id, '||
                          ' int.intercompany_id, '||
                          ' int.entity_id, '||
                          ' int.task_id, '||
                          ' int.user_dim1_id, '||
                          ' int.user_dim2_id, '||
                          ' int.user_dim3_id, '||
                          ' int.user_dim4_id, '||
                          ' int.user_dim5_id, '||
                          ' int.user_dim6_id, '||
                          ' int.user_dim7_id, '||
                          ' int.user_dim8_id, '||
                          ' int.user_dim9_id, '||
                          ' int.user_dim10_id, '||
                          ' ' || v_req_text || ', ' ||
                          ' :pv_rule_obj_id, '||
                          ' ' || v_req_text || ', ' ||
                          ' :pv_rule_obj_id, '||
                          ' int.xtd_balance_e, '||
                          ' int.xtd_balance_f, '||
                          ' int.ytd_balance_e, '||
                          ' int.ytd_balance_f, '||
                          ' int.qtd_balance_e, '||
                          ' int.qtd_balance_f, '||
                          ' int.ptd_debit_balance_e, '||
                          ' int.ptd_credit_balance_e, '||
                          ' int.ytd_debit_balance_e, '||
                          ' int.ytd_credit_balance_e)';

      -- Print out the merge statement for debugging purposes
      FOR iterator IN 1..trunc((length(v_sql_stmt_2)+1499)/1500) LOOP
        FEM_ENGINES_PKG.Tech_Message
        (p_severity => v_log_level_2,
         p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_sql_stmt_2: ' || iterator,
         p_token2   => 'VAR_VAL',
         p_value2   => substr(v_sql_stmt_2, iterator*1500-1499, 1500));
      END LOOP;

      -- Only bind the request id if we are in XGL mode
      IF p_load_type = 'XGL' THEN
        EXECUTE IMMEDIATE v_sql_stmt_2
        USING pv_req_id, pv_rule_obj_id, pv_req_id, pv_rule_obj_id,
              pv_req_id, pv_rule_obj_id;
      ELSE
        EXECUTE IMMEDIATE v_sql_stmt_2
        USING pv_rule_obj_id, pv_rule_obj_id, pv_rule_obj_id;
      END IF;

      x_rows_posted := SQL%ROWCOUNT;

      FEM_ENGINES_PKG.Tech_Message
        ( p_severity => v_log_level_1,
          p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
          p_app_name => 'FEM',
          p_msg_text => 'Merged ' || TO_CHAR(x_rows_posted) ||
                     ' rows into FEM_BALANCES');

    END IF;

    -- Find out number of rows in the interim table
    SELECT count(*)
    INTO v_interim_row_count
    FROM FEM_BAL_POST_INTERIM_GT bpi
    WHERE posting_error_flag = 'N'
    AND NOT EXISTS
    (SELECT 1
     FROM   FEM_INTG_DELTA_LOADS dl
     WHERE  dl.ledger_id = bpi.ledger_id
     AND    dl.dataset_code = bpi.dataset_code
     AND    dl.cal_period_id = bpi.cal_period_id
     AND    dl.delta_run_id = bpi.delta_run_id
     AND    dl.loaded_flag = 'N');

    IF (p_load_type = 'XGL' AND v_interim_row_count <> x_rows_posted) THEN

       -- This routine has failed with error
       x_completion_code := 2;
       RAISE DATA_CORRUPTION;

    END IF;


    -- Now, recalculate the QTD balances if applicable
    IF p_load_type = 'OGL' THEN
      SELECT dimension_id
      INTO v_na_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'NATURAL_ACCOUNT';

      SELECT dimension_id
      INTO v_xat_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'EXTENDED_ACCOUNT_TYPE';

      FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id(
        p_dim_id  => v_na_dim_id,
        p_attr_label => 'EXTENDED_ACCOUNT_TYPE',
        x_attr_id => v_na_xat_attr_id,
        x_ver_id  => v_na_xat_v_id,
        x_err_code   => v_error_code);

      FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id(
        p_dim_id  => v_xat_dim_id,
        p_attr_label => 'BASIC_ACCOUNT_TYPE_CODE',
        x_attr_id => v_xat_bat_attr_id,
        x_ver_id  => v_xat_bat_v_id,
        x_err_code   => v_error_code);

      FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id(
        p_dim_id  => FEM_GL_POST_PROCESS_PKG.pv_cal_per_dim_id,
        p_attr_label => 'GL_PERIOD_NUM',
        x_attr_id => v_cp_period_num_attr_id,
        x_ver_id  => v_cp_period_num_v_id,
        x_err_code   => v_error_code);

      FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id(
        p_dim_id  => FEM_GL_POST_PROCESS_PKG.pv_cal_per_dim_id,
        p_attr_label => 'ACCOUNTING_YEAR',
        x_attr_id => v_cp_year_attr_id,
        x_ver_id  => v_cp_year_v_id,
        x_err_code   => v_error_code);

      IF p_maintain_qtd = 'Y' THEN
        SELECT period_set_name, accounted_period_type
        INTO v_ps_name, v_period_type
        FROM gl_ledgers
        WHERE ledger_id = pv_ledger_id;

        UPDATE FEM_BALANCES fb
        SET    (qtd_balance_e, qtd_balance_f) =
        (SELECT
           fb.xtd_balance_e + nvl(sum(nvl(fb_in.xtd_balance_e,0)),0),
           fb.xtd_balance_f + nvl(sum(nvl(fb_in.xtd_balance_f,0)),0)
         FROM   FEM_BALANCES fb_in,
                FEM_CAL_PERIODS_B cp_curr,
                FEM_CAL_PERIODS_B cp_prev,
                FEM_CAL_PERIODS_ATTR cpa_curr,
                FEM_CAL_PERIODS_ATTR cpa_prev,
                FEM_CAL_PERIODS_ATTR cpa_curr_year,
                FEM_CAL_PERIODS_ATTR cpa_prev_year,
                GL_PERIODS per_curr,
                GL_PERIODS per_prev
         WHERE  fb_in.dataset_code = fb.dataset_code
         AND    fb_in.source_system_code = fb.source_system_code
         AND    fb_in.ledger_id = pv_ledger_id
         AND    fb.ledger_id = pv_ledger_id
         AND    fb_in.currency_code = fb.currency_code
         AND    fb_in.currency_type_code = fb.currency_type_code
         AND    fb_in.company_cost_center_org_id = fb.company_cost_center_org_id
         AND    fb_in.product_id = fb.product_id
         AND    fb_in.natural_account_id = fb.natural_account_id
         AND    fb_in.channel_id = fb.channel_id
         AND    fb_in.line_item_id = fb.line_item_id
         AND    fb_in.project_id = fb.project_id
         AND    fb_in.customer_id = fb.customer_id
         AND    fb_in.entity_id = fb.entity_id
         AND    fb_in.intercompany_id = fb.intercompany_id
         AND    fb_in.user_dim1_id = fb.user_dim1_id
         AND    fb_in.user_dim2_id = fb.user_dim2_id
         AND    fb_in.user_dim3_id = fb.user_dim3_id
         AND    fb_in.user_dim4_id = fb.user_dim4_id
         AND    fb_in.user_dim5_id = fb.user_dim5_id
         AND    fb_in.user_dim6_id = fb.user_dim6_id
         AND    fb_in.user_dim7_id = fb.user_dim7_id
         AND    fb_in.user_dim8_id = fb.user_dim8_id
         AND    fb_in.user_dim9_id = fb.user_dim9_id
         AND    fb_in.user_dim10_id = fb.user_dim10_id
         AND    nvl(fb_in.task_id, -1) = nvl(fb.task_id, -1)
         AND    nvl(fb_in.activity_id, -1) = nvl(fb.activity_id, -1)
         AND    nvl(fb_in.cost_object_id, -1) = nvl(fb.cost_object_id, -1)
         AND    nvl(fb_in.financial_elem_id, -1) = nvl(fb.financial_elem_id, -1)
         AND    cp_curr.cal_period_id = fb.cal_period_id
         AND    cp_prev.cal_period_id = fb_in.cal_period_id
         AND    cp_prev.dimension_group_id = cp_curr.dimension_group_id
         AND    cpa_curr.cal_period_id = cp_curr.cal_period_id
         AND    cpa_curr.attribute_id = v_cp_period_num_attr_id
         AND    cpa_curr.version_id = v_cp_period_num_v_id
         AND    cpa_prev.cal_period_id = cp_prev.cal_period_id
         AND    cpa_prev.attribute_id = v_cp_period_num_attr_id
         AND    cpa_prev.version_id = v_cp_period_num_v_id
         AND    cpa_prev.number_assign_value < cpa_curr.number_assign_value
         AND    cpa_curr_year.cal_period_id = cp_curr.cal_period_id
         AND    cpa_curr_year.attribute_id = v_cp_year_attr_id
         AND    cpa_curr_year.version_id = v_cp_year_v_id
         AND    cpa_prev_year.cal_period_id = cp_prev.cal_period_id
         AND    cpa_prev_year.attribute_id = v_cp_year_attr_id
         AND    cpa_prev_year.version_id = v_cp_year_v_id
         AND    cpa_prev_year.number_assign_value = cpa_curr_year.number_assign_value
         AND    per_curr.period_set_name = v_ps_name
         AND    per_curr.period_type = v_period_type
         AND    per_curr.period_year = cpa_curr_year.number_assign_value
         AND    per_curr.period_num = cpa_curr.number_assign_value
         AND    per_prev.period_set_name = v_ps_name
         AND    per_prev.period_type = v_period_type
         AND    per_prev.period_year = cpa_curr_year.number_assign_value
         AND    per_prev.period_num = cpa_prev.number_assign_value
         AND    per_prev.quarter_num = per_curr.quarter_num
        )
        WHERE  EXISTS
               (SELECT 1
                FROM   FEM_INTG_EXEC_PARAMS_GT param
                WHERE  param.output_dataset_code = fb.dataset_code
                AND    param.cal_period_id = fb.cal_period_id
                AND    param.error_code IS NULL
                AND    param.request_id IS NOT NULL)
        AND    EXISTS
               (SELECT 1
                FROM   FEM_NAT_ACCTS_ATTR naa,
                       FEM_EXT_ACCT_TYPES_ATTR xat
                WHERE  naa.attribute_id = v_na_xat_attr_id
                AND    naa.version_id = v_na_xat_v_id
                AND    naa.natural_account_id = fb.natural_account_id
                AND    xat.attribute_id = v_xat_bat_attr_id
                AND    xat.version_id = v_xat_bat_v_id
                AND    xat.ext_account_type_code = naa.dim_attribute_varchar_member
                AND    xat.dim_attribute_varchar_member IN ('REVENUE', 'EXPENSE'));

        FEM_ENGINES_PKG.Tech_Message
          ( p_severity => v_log_level_1,
            p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
            p_app_name => 'FEM',
            p_msg_text => 'Updated ' || TO_CHAR(x_rows_posted) ||
                        ' rows in FEM_BALANCES');
      END IF;
    END IF;


    -- This routine has completed successfully
    x_completion_code := 0;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => v_log_level_2,
       p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
       p_msg_text => 'END FEM_GL_POST_BAL_PKG.Post_FEM_Balances');

EXCEPTION
   WHEN DATA_CORRUPTION THEN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => v_log_level_6,
         p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_401');

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => v_log_level_6,
         p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
         p_msg_text => 'Data corruption in FEM_BALANCES!');

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_401');

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => v_log_level_2,
         p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
         p_msg_text => 'END FEM_GL_POST_BAL_PKG.Post_FEM_Balances');

   WHEN PROC_KEY_ERROR THEN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => v_log_level_2,
         p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
         p_msg_text => 'END FEM_GL_POST_BAL_PKG.Post_FEM_Balances');

    WHEN OTHERS THEN

      FEM_GL_POST_PROCESS_PKG.pv_sqlerrm := SQLERRM;

      IF p_load_type = 'XGL' THEN
        ROLLBACK;
      END IF;

      x_completion_code := 2;

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => v_log_level_6,
         p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => v_log_level_2,
         p_module   => 'fem.plsql.gl_post_bal.pfb.' || p_process_slice,
         p_msg_text => 'END FEM_GL_POST_BAL_PKG.Post_FEM_Balances');

END post_fem_balances;

END FEM_GL_POST_BAL_PKG;

/
