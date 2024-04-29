--------------------------------------------------------
--  DDL for Package Body PFT_PROFCAL_VALIDX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_PROFCAL_VALIDX_PUB" AS
/* $Header: PFTPVIDXB.pls 120.1 2006/05/25 10:32:44 ssthiaga noship $ */

--------------------------------------------------------------------------------
-- Declare package constants --
--------------------------------------------------------------------------------

  g_object_version_number     CONSTANT    NUMBER        :=  1;
  g_pkg_name                  CONSTANT    VARCHAR2(30)  :=  'PFT_PROFCAL_VALIDX_PUB';

  -- Constants for p_exec_status_code
  g_exec_status_error_rerun   CONSTANT    VARCHAR2(30)  :=  'ERROR_RERUN';
  g_exec_status_success       CONSTANT    VARCHAR2(30)  :=  'SUCCESS';

  --Constants for output table names being registered with fem_pl_pkg
  -- API register_table method.
  g_fem_customer_profit  CONSTANT    VARCHAR2(30) :=  'FEM_CUSTOMER_PROFIT';

  --constant for sql_stmt_type
  g_insert               CONSTANT    VARCHAR2(30) :=  'INSERT';
  g_update               CONSTANT    VARCHAR2(30) :=  'UPDATE';

  g_default_fetch_limit  CONSTANT    NUMBER       :=  99999;

  g_log_level_1           CONSTANT   NUMBER       :=  FND_LOG.Level_Statement;
  g_log_level_2           CONSTANT   NUMBER       :=  FND_LOG.Level_Procedure;
  g_log_level_3           CONSTANT   NUMBER       :=  FND_LOG.Level_Event;
  g_log_level_4           CONSTANT   NUMBER       :=  FND_LOG.Level_Exception;
  g_log_level_5           CONSTANT   NUMBER       :=  FND_LOG.Level_Error;
  g_log_level_6           CONSTANT   NUMBER       :=  FND_LOG.Level_Unexpected;

  g_num_rows              NUMBER := -1;

--------------------------------------------------------------------------------
-- Declare package variables --
--------------------------------------------------------------------------------
  -- Exception variables
  gv_prg_msg                  VARCHAR2(2000);
  gv_callstack                VARCHAR2(2000);
  -- Bulk Fetch Limit
  gv_fetch_limit              NUMBER;

  z_master_err_state          NUMBER;

--------------------------------------------------------------------------------
-- Declare package exceptions --
--------------------------------------------------------------------------------
  -- General profit Aggregation Engine Exception
  e_process_single_rule_error  EXCEPTION;
  USER_EXCEPTION               EXCEPTION;

--------------------------------------------------------------------------------
-- Declare private procedures and functions --
--------------------------------------------------------------------------------

  PROCEDURE Update_Nbr_Of_Output_Rows (
    p_request_id              IN  NUMBER
    ,p_user_id                IN  NUMBER
    ,p_login_id               IN  NUMBER
    ,p_rule_obj_id            IN  NUMBER
    ,p_num_output_rows        IN  NUMBER
    ,p_tbl_name               IN  VARCHAR2
    ,p_stmt_type              IN  VARCHAR2
  );

  PROCEDURE Update_Obj_Exec_Step_Status (
    p_request_id              IN  NUMBER
    ,p_user_id                IN  NUMBER
    ,p_login_id               IN  NUMBER
    ,p_rule_obj_id            IN  NUMBER
    ,p_exe_step               IN  VARCHAR2
    ,p_exe_status_code        IN  VARCHAR2
  );

  PROCEDURE Get_Nbr_RowsTable_Request (
    x_rows_processed          OUT NOCOPY NUMBER
    ,x_rows_loaded            OUT NOCOPY NUMBER
    ,x_rows_rejected          OUT NOCOPY NUMBER
    ,p_request_id             IN  NUMBER
  );

  PROCEDURE Process_Obj_Exec_Step (
    p_request_id              IN  NUMBER
    ,p_user_id                IN  NUMBER
    ,p_login_id               IN  NUMBER
    ,p_rule_obj_id            IN  NUMBER
    ,p_exe_step               IN  VARCHAR2
    ,p_exe_status_code        IN  VARCHAR2
    ,p_tbl_name               IN  VARCHAR2
  );

  PROCEDURE Get_Put_Messages (
    p_msg_count               IN  NUMBER
    ,p_msg_data               IN  VARCHAR2
  );

  FUNCTION Create_Region_Cnt_Index_Stmt (
    p_object_id               IN  NUMBER
    ,p_customer_level         IN  NUMBER
    ,p_output_column          IN  VARCHAR2
    ,p_cal_period_id          IN  NUMBER
    ,p_effective_date         IN  VARCHAR2
    ,p_dataset_code           IN  NUMBER
    ,p_ledger_id              IN  NUMBER
    ,p_source_system_code     IN  NUMBER
    ,p_condition_clause       IN  LONG
    ,p_value_index_formula_id IN  NUMBER
    ,p_rel_dimension_grp_seq  IN  NUMBER
    ,p_attribute_id           IN  NUMBER
    ,p_version_id             IN  NUMBER
    ,p_value_set_id           IN  NUMBER)
  RETURN LONG;

  FUNCTION Create_Profit_Pptile_Idx_Stmt (
    p_object_id               IN  NUMBER
    ,p_customer_level         IN  NUMBER
    ,p_output_column          IN  VARCHAR2
    ,p_cal_period_id          IN  NUMBER
    ,p_effective_date         IN  VARCHAR2
    ,p_dataset_code           IN  NUMBER
    ,p_ledger_id              IN  NUMBER
    ,p_source_system_code     IN  NUMBER
    ,p_condition_clause       IN  LONG
    ,p_value_index_formula_id IN  NUMBER
    ,p_rel_dimension_grp_seq  IN  NUMBER
    ,p_attribute_id           IN  NUMBER
    ,p_version_id             IN  NUMBER
    ,p_value_set_id           IN  NUMBER)
   RETURN LONG;

  FUNCTION Create_Product_Id_Index_Stmt (
    p_object_id               IN  NUMBER
    ,p_customer_level         IN  NUMBER
    ,p_output_column          IN  VARCHAR2
    ,p_cal_period_id          IN  NUMBER
    ,p_effective_date         IN  VARCHAR2
    ,p_dataset_code           IN  NUMBER
    ,p_ledger_id              IN  NUMBER
    ,p_source_system_code     IN  NUMBER
    ,p_condition_clause       IN  LONG
    ,p_value_index_formula_id IN  NUMBER
    ,p_rel_dimension_grp_seq  IN  NUMBER
    ,p_attribute_id           IN  NUMBER
    ,p_version_id             IN  NUMBER
    ,p_value_set_id           IN  NUMBER)
   RETURN LONG;

   PROCEDURE Update_Nbr_Of_Input_Rows (
    p_request_id              IN  NUMBER
    ,p_user_id                IN  NUMBER
    ,p_last_update_login      IN  NUMBER
    ,p_rule_obj_id            IN  NUMBER
    ,p_num_of_input_rows      IN  NUMBER
  );

  PROCEDURE Register_Updated_Column(
    p_request_id              IN  NUMBER
    ,p_object_id              IN  NUMBER
    ,p_user_id                IN  NUMBER
    ,p_last_update_login      IN  NUMBER
    ,p_table_name             IN  VARCHAR2
    ,p_statement_type         IN  VARCHAR2
    ,p_column_name            IN  VARCHAR2
  );

/*======--=====================================================================+
 | PROCEDURE
 |   PROCESS SINGLE RULE
 |
 | DESCRIPTION
 |   Main engine procedure for Value Index step in profit calcution in PFT.
 |
 | SCOPE - PUBLIC
 |
 +============================================================================*/

  PROCEDURE Process_Single_Rule (p_rule_obj_id              IN  NUMBER
                                ,p_cal_period_id            IN  NUMBER
                                ,p_dataset_io_obj_def_id    IN  NUMBER
                                ,p_output_dataset_code      IN  NUMBER
                                ,p_effective_date           IN  VARCHAR2
                                ,p_ledger_id                IN  NUMBER
                                ,p_source_system_code       IN  NUMBER
                                ,p_value_index_formula_id   IN  NUMBER
                                ,p_rule_obj_def_id          IN  NUMBER
                                ,p_region_counting_flag     IN  VARCHAR2
                                ,p_proft_percentile_flag    IN  VARCHAR2
                                ,p_customer_level           IN  NUMBER
                                ,p_cond_obj_id              IN  NUMBER
                                ,p_output_column            IN  VARCHAR2
                                ,p_exec_state               IN  VARCHAR2
                                ,x_return_status            OUT NOCOPY VARCHAR2)

   IS

   l_api_name      CONSTANT     VARCHAR2(30)  := 'Process_Single_Rule';

   l_process_table              VARCHAR2(30) := 'FEM_CUSTOMER_PROFIT';
   l_table_alias                VARCHAR2(5)  := 'FCP';
   l_ds_where_clause            LONG := NULL;
   l_measure_type               VARCHAR2(50);
   l_err_msg                    VARCHAR2(255);
   l_reuse_slices               VARCHAR2(10);
   l_msg_count                  NUMBER;
   l_exception_code             VARCHAR2(50);
   l_msg_data                   VARCHAR2(200);
   l_return_status              VARCHAR2(50)  :=  NULL;
   l_product_id                 NUMBER;
   l_condition_clause           LONG;
   l_rgn_cnt_sql                LONG;
   l_prof_ptile_sql             LONG;
   l_prod_cd_sql                LONG;
   l_rel_dimension_grp_seq      NUMBER;
   l_attribute_id               NUMBER;
   l_version_id                 NUMBER;
   l_effective_date             DATE;
   l_region_exists              BOOLEAN;
   l_profit_exists              BOOLEAN;
   l_product_exists             BOOLEAN;
   l_chaining_flag              BOOLEAN;
   l_region_counting_flag       VARCHAR2(1);
   l_proft_percentile_flag      VARCHAR2(1);
   l_last_row                   NUMBER;
   l_gvsc_id                    NUMBER;
   l_err_code                   NUMBER := 0;
   l_num_msg                    NUMBER := 0;
   l_value_set_id               NUMBER;

   l_request_id                 NUMBER := FND_GLOBAL.Conc_Request_Id;
   l_user_id                    NUMBER := FND_GLOBAL.User_Id;
   l_login_id                   NUMBER := FND_GLOBAL.Login_Id;

   TYPE number_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_created_by_request_id_tbl     number_type;
   l_created_by_object_id_tbl      number_type;

   TYPE chaining_cursor IS REF CURSOR;
   l_cv_chains chaining_cursor;

   TYPE v_msg_list_type        IS VARRAY(20) OF
                               fem_mp_process_ctl_t.message%TYPE;
   v_msg_list                  v_msg_list_type;

   e_process_single_rule_error  EXCEPTION;
   e_register_rule_error        EXCEPTION;

   l_rc_chain_stmt CONSTANT LONG :=
    'SELECT distinct r.created_by_request_id'||
    ',r.created_by_object_id '||
    'FROM FEM_REGION_INFO r '||
    'where r.ledger_id = :b_ledger_id '||
    'and r.cal_period_id = :b_cal_period_id '||
    'and r.dataset_code = :b_output_dataset_code '||
    'and r.source_system_code = :b_source_system_code '||
    'and r.dimension_group_id = :b_customer_level '||
    'and not ('||
    'r.created_by_request_id = :b_request_id '||
    'and r.created_by_object_id = :b_rule_obj_id '||
    ' )'||
    ' and not exists ('||
    '   select 1 '||
    '   from fem_pl_chains c '||
    '   where c.request_id = :b_request_id '||
    '   and c.object_id = :b_rule_obj_id '||
    '   and c.source_created_by_request_id = r.created_by_request_id '||
    '   and c.source_created_by_object_id = r.created_by_object_id '||
    ' )';

   l_pp_chain_stmt CONSTANT LONG :=
    'SELECT distinct cp.last_updated_by_request_id '||
    ',cp.created_by_object_id '||
    'FROM FEM_CUSTOMER_PROFIT cp '||
    'where cp.ledger_id = :b_ledger_id '||
    'and cp.cal_period_id = :b_cal_period_id '||
    'and cp.dataset_code = :b_output_dataset_code '||
    'and cp.source_system_code = :b_source_system_code '||
    'AND (SELECT customer_level FROM  pft_pprof_calc_rules '||
    'WHERE pprof_calc_obj_def_id = :b_rule_obj_defn_id) = :b_customer_level '||
    'and not ( '||
    'cp.last_updated_by_request_id = :b_request_id '||
    'and cp.created_by_object_id = :b_rule_obj_id '||
    ' )'||
    ' and not exists ( '||
    '   select 1 '||
    '   from fem_pl_chains c '||
    '   where c.request_id = :b_request_id '||
    '   and c.object_id = :b_rule_obj_id '||
    '   and c.source_created_by_request_id = cp.last_updated_by_request_id '||
    '   and c.source_created_by_object_id = cp.created_by_object_id '||
    ' ) ';

   BEGIN

      -- Initialize the return status to SUCCESS
      x_return_status  := FND_API.G_RET_STS_SUCCESS;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      l_effective_date  :=  FND_DATE.Canonical_To_Date(p_effective_date);

      l_region_exists  := TRUE;
      l_profit_exists  := TRUE;
      l_product_exists := TRUE;
      l_chaining_flag  := FALSE;

      l_last_row := 0;
      l_region_counting_flag  := p_region_counting_flag ;
      l_proft_percentile_flag := p_proft_percentile_flag;

      BEGIN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_2
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Value Index Formula ' || p_value_index_formula_id);

         SELECT COUNT(measure_type)
           INTO l_measure_type
         FROM   pft_val_index_ranges
         WHERE  value_index_formula_id = p_value_index_formula_id
           AND  measure_type = 'REGION_COUNTING';

         IF l_measure_type = 0 THEN
           l_region_exists  := FALSE;

           FEM_ENGINES_PKG.Tech_Message (
              p_severity  => g_log_level_2
             ,p_module    => G_BLOCK||'.'||l_api_name
             ,p_msg_text  => 'Region Counting Formula does not Exist');

           FEM_ENGINES_PKG.User_Message (
              p_app_name  => G_PFT
             ,p_msg_name  => G_ENG_RCNT_NO_FORMULA_ERR);
         END IF;

      EXCEPTION
         WHEN no_data_found THEN
            l_region_exists  := FALSE;
         RAISE;
         WHEN OTHERS THEN
         RAISE;
      END;

      BEGIN
         SELECT COUNT(measure_type)
           INTO l_measure_type
         FROM   pft_val_index_ranges
         WHERE  value_index_formula_id = p_value_index_formula_id
           AND  measure_type = 'PROFIT_PERCENTILE';

         IF l_measure_type = 0 THEN

           l_profit_exists   := FALSE;

           FEM_ENGINES_PKG.Tech_Message (
              p_severity  => g_log_level_2
             ,p_module    => G_BLOCK||'.'||l_api_name
             ,p_msg_text  => 'Profit Percentile Formula does not Exist');

           FEM_ENGINES_PKG.User_Message (
              p_app_name  => G_PFT
             ,p_msg_name  => G_ENG_PPTILE_NO_FORMULA_ERR);

         END IF;

      EXCEPTION
         WHEN no_data_found THEN
            l_profit_exists  := FALSE;
         RAISE;
         WHEN OTHERS THEN
         RAISE;
      END;

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_2
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Getting Global VS Combo ID');

      l_gvsc_id := FEM_DIMENSION_UTIL_PKG.Global_VS_Combo_ID (
                      p_ledger_id => p_ledger_id
                     ,x_err_code  => l_err_code
                     ,x_num_msg   => l_num_msg);

      IF(l_err_code <> 0)THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_2
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'No GVSC Id for the Given Ledger' || p_ledger_id);

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_INVALID_LEDGER_ERR
           ,p_token1    => 'LEDGER_ID'
           ,p_value1    => p_ledger_id);

         RAISE e_process_single_rule_error;
      END IF;

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_2
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Getting Customer Value Set Id');

      BEGIN
         SELECT gvsc.value_set_id
           INTO l_value_set_id
         FROM   fem_global_vs_combo_defs gvsc,
                fem_dimensions_b dim
         WHERE  gvsc.dimension_id = dim.dimension_id
           AND  dim.dimension_varchar_label = 'CUSTOMER'
           AND  gvsc.global_vs_combo_id = l_gvsc_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FEM_ENGINES_PKG.Tech_Message (
               p_severity => g_log_level_2
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'No Value Set Id for the Given GVSC '|| l_gvsc_id);

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_INVALID_GVSC_ERR
              ,p_token1    => 'GVSC_ID'
              ,p_value1    => l_gvsc_id);

         RAISE e_process_single_rule_error;

         WHEN OTHERS THEN
         RAISE;
      END;

      BEGIN
         SELECT COUNT(product_id)
           INTO l_product_id
         FROM   pft_val_index_counting
         WHERE  value_index_formula_id = p_value_index_formula_id;

         IF l_product_id = 0 THEN
            l_product_exists   := FALSE;

            FEM_ENGINES_PKG.Tech_Message (
              p_severity  => g_log_level_2
             ,p_module    => G_BLOCK||'.'||l_api_name
             ,p_msg_text  => 'Product Formula does not Exist');

           --FEM_ENGINES_PKG.User_Message (
           --   p_app_name  => G_PFT
           --  ,p_msg_name  => 'Product Formula does not Exist');

         END IF;

      EXCEPTION
         WHEN no_data_found THEN
            l_product_exists  := FALSE;
         WHEN OTHERS THEN
            RAISE;
      END;

      FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Register update colmn:Value Index');

      Register_Updated_Column( p_request_id        =>  l_request_id
                              ,p_object_id         =>  p_rule_obj_id
                              ,p_user_id           =>  l_user_id
                              ,p_last_update_login =>  l_login_id
                              ,p_table_name        =>  g_fem_customer_profit
                              ,p_statement_type    =>  g_update
                              ,p_column_name       =>  p_output_column);

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_2
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Get The Level for which the
	                    Value Index has to be calculated');
      BEGIN
         SELECT  relative_dimension_group_seq
           INTO  l_rel_dimension_grp_seq
         FROM    fem_hier_dimension_grps
         WHERE   dimension_group_id = p_customer_level
           AND   ROWNUM = 1;

      EXCEPTION
         WHEN OTHERS THEN
         RAISE;
      END;

      IF (p_cond_obj_id IS NOT NULL) THEN

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_3
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Generating the Condition where clause');

         Fem_Conditions_Api.Generate_Condition_Predicate(
            p_api_version           =>  g_api_version,
            p_init_msg_list         =>  g_false,
            p_commit                =>  g_false,
            p_encoded               =>  g_true,
            p_condition_obj_id      =>  p_cond_obj_id,
            p_rule_effective_date   =>  p_effective_date,
            p_input_fact_table_name =>  l_process_table,
            p_table_alias           =>  l_table_alias,
            p_display_predicate     =>  'N',                   -- Display Predicate
            p_return_predicate_type =>  'BOTH',
            p_logging_turned_on     =>  'Y',
            x_return_status         =>  l_return_status,
            x_msg_count             =>  l_msg_count,
            x_msg_data              =>  l_msg_data,
            x_predicate_string      =>  l_condition_clause);

         IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            Get_Put_Messages ( p_msg_count => l_msg_count
                              ,p_msg_data  => l_msg_data);

            FEM_ENGINES_PKG.User_Message (
               p_app_name => G_PFT
              ,p_msg_name => G_ENG_COND_PRED_CLAUSE_ERR
              ,p_token1   => 'CONDITION_OBJ_ID'
              ,p_value1   => p_cond_obj_id);

            IF (l_condition_clause IS NULL) THEN
               FEM_ENGINES_PKG.User_Message (
                  p_app_name => G_PFT
                 ,p_msg_name => G_ENG_COND_PRED_CLAUSE_ERR
                 ,p_token1   => 'CONDITION_OBJ_ID'
                 ,p_value1   => p_cond_obj_id);
            END IF;
            RAISE e_process_single_rule_error;

         END IF;
      END IF;

      -------------------- Register the chain if required  ---------------------
      --Step :1: Set The l_Chaining_flag
      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_1
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Register Chain Step:1:
                         Identify whether chaining is needed ');

      IF l_region_counting_flag = 'N' AND l_proft_percentile_flag = 'N' THEN

         IF  (l_region_exists  AND l_profit_exists ) OR
             (l_region_exists) OR (l_profit_exists) THEN
            l_chaining_flag := TRUE;
         END IF;

      ELSIF l_region_counting_flag = 'Y' AND l_proft_percentile_flag = 'N' THEN

         IF l_profit_exists THEN
            l_chaining_flag := TRUE;
         END IF;

      ELSIF l_region_counting_flag = 'N' AND l_proft_percentile_flag = 'Y' THEN

         IF l_region_exists THEN
            l_chaining_flag := TRUE;
         END IF;

      END IF;
      --------------------------------------------------------------------------
      --Step 2: If the  l_chaining flag := TRUE call Register_Chain
      --------------------------------------------------------------------------
      IF (l_chaining_flag) THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_1
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Chain Step:2:Call PL_Chains:');

         IF l_region_exists THEN
            OPEN  l_cv_chains
             FOR  l_rc_chain_stmt
            USING p_ledger_id,
                  p_cal_period_id,
                  p_output_dataset_code,
                  p_source_system_code,
                  p_customer_level,
                  l_request_id,
                  p_rule_obj_id,
                  l_request_id,
                  p_rule_obj_id;

            LOOP
               EXIT WHEN l_cv_chains%NOTFOUND;

               FETCH l_cv_chains BULK COLLECT INTO l_created_by_request_id_tbl,
                                                   l_created_by_object_id_tbl;

               l_last_row := l_created_by_object_id_tbl.COUNT;

               FOR i IN 1 .. l_last_row LOOP
               -- Call the FEM_PL_PKG.Register_Chain API procedure to register
               -- the specified chain.
               FEM_PL_PKG.Register_Chain (
                p_api_version                  => 1.0
               ,p_commit                       => FND_API.G_FALSE
               ,p_request_id                   => l_request_id
               ,p_object_id                    => p_rule_obj_id
               ,p_source_created_by_request_id => l_created_by_request_id_tbl(i)
               ,p_source_created_by_object_id  => l_created_by_object_id_tbl(i)
               ,p_user_id                      => l_user_id
               ,p_last_update_login            => l_login_id
               ,x_msg_count                    => l_msg_count
               ,x_msg_data                     => l_msg_data
               ,x_return_status                => l_return_status);

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  FEM_ENGINES_PKG.User_Message (
                     p_app_name  => G_PFT
                    ,p_msg_name  => G_PL_REG_CHAIN_ERR);

                  RAISE e_process_single_rule_error;
               END IF;

               END LOOP; --End for loop

            END LOOP; -- End Fetch Loop

            CLOSE l_cv_chains;

         END IF;

         --if profit percentile rule is run
         IF l_profit_exists THEN

            OPEN  l_cv_chains
             FOR  l_pp_chain_stmt
            USING p_ledger_id,
                  p_cal_period_id,
                  p_output_dataset_code,
                  p_source_system_code,
                  p_rule_obj_def_id,
                  p_customer_level,
                  l_request_id,
                  p_rule_obj_id,
                  l_request_id,
                  p_rule_obj_id;

            LOOP
               EXIT WHEN l_cv_chains%NOTFOUND;

               FETCH l_cv_chains BULK COLLECT INTO l_created_by_request_id_tbl,
                                                   l_created_by_object_id_tbl;

               l_last_row := l_created_by_object_id_tbl.COUNT;

               FOR i IN 1 .. l_last_row LOOP
               -- Call the FEM_PL_PKG.Register_Chain API procedure to register
               -- the specified chain.
               FEM_PL_PKG.Register_Chain (
                p_api_version                   => 1.0
               ,p_commit                       => FND_API.G_FALSE
               ,p_request_id                   => l_request_id
               ,p_object_id                    => p_rule_obj_id
               ,p_source_created_by_request_id => l_created_by_request_id_tbl(i)
               ,p_source_created_by_object_id  => l_created_by_object_id_tbl(i)
               ,p_user_id                      => l_user_id
               ,p_last_update_login            => l_login_id
               ,x_msg_count                    => l_msg_count
               ,x_msg_data                     => l_msg_data
               ,x_return_status                => l_return_status);

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  FEM_ENGINES_PKG.User_Message (
                     p_app_name  => G_PFT
                    ,p_msg_name  => G_PL_REG_CHAIN_ERR);

                  RAISE e_process_single_rule_error;
               END IF;

               END LOOP; --End for loop

            END LOOP; -- End fetch loop

            CLOSE l_cv_chains;

         END IF;  --if region counting rule is run

         l_created_by_request_id_tbl.DELETE;
         l_created_by_object_id_tbl.DELETE;

  --sshanmug
  --   This Case is to be addressed for PFT.B

  -- Issue:
  --  Throwing error when l_profit_exists/l_region_exists flags are true and
  --  there is no corresponding Concurrent_Req_id / Obj_id for the same.
  --Detailed description:
  --If Rule A is created for Region counting and Profit Percentile and let us
  --assume that the Rule A is not run or did not complete succesfully.Now if
  --we create a Rule B, which is run for Value Index and its value index formula
  --refers 'Region counting and Profit Percentile'(of Rule A)
  --then the Rule B will still run but the result data has no meaning.
  --This can be avoided by chcking the return values of the cursor 'l_cv_chains'
  --and throw the error message when no data found so that Rule B can never run.

   END IF;  --if chaining exists

      -- When the given formula has Region Counting Formula defined
      IF l_region_exists THEN

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_3
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Building Region Count Value Index SQL');

         -- Get the attribute and Version Ids of the Region Code of Customer
	 -- Dimension
         SELECT dim_attr.attribute_id,ver.version_id
           INTO l_attribute_id
                ,l_version_id
           FROM fem_dim_attributes_b dim_attr,
                fem_dimensions_b xdim,
                fem_dim_attr_versions_b ver
         WHERE  dim_attr.dimension_id = xdim.dimension_id
           AND  dim_attr.attribute_id = ver.attribute_id
           AND  dim_attr.attribute_varchar_label = 'REGION_CODE'
           AND  xdim.dimension_varchar_label = 'CUSTOMER';

       -- To Create the bulk SQL to calcualte Value Index
       --based on the Region Counting details
       l_rgn_cnt_sql := Create_Region_Cnt_Index_Stmt(
                            p_object_id              => p_rule_obj_id
                           ,p_customer_level         => p_customer_level
                           ,p_output_column          => p_output_column
                           ,p_cal_period_id          => p_cal_period_id
                           ,p_effective_date         => p_effective_date
                           ,p_dataset_code           => p_output_dataset_code
                           ,p_ledger_id              => p_ledger_id
                           ,p_source_system_code     => p_source_system_code
                           ,p_condition_clause       => l_condition_clause
                           ,p_value_index_formula_id => p_value_index_formula_id
                           ,p_rel_dimension_grp_seq  => l_rel_dimension_grp_seq
                           ,p_attribute_id           => l_attribute_id
                           ,p_version_id             => l_version_id
                           ,p_value_set_id           => l_value_set_id);

         IF(p_exec_state = 'RESTART') THEN
            l_reuse_slices := 'Y';
         ELSE
            l_reuse_slices := 'N';
         END IF;

         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_1
           ,p_module   => G_BLOCK ||'.' || l_api_name
           ,p_msg_text => l_rgn_cnt_sql);

         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Registering step: VALUE_INDEX');

         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Submitting to MP Master.p_rule_id: '
                          ||p_rule_obj_id);

         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Submitting Region Count SQL to MP Master.p_eng_sql: '
                          ||l_rgn_cnt_sql);

         FEM_MULTI_PROC_PKG.Master(
            p_rule_id        =>  p_rule_obj_id
           ,p_eng_step       =>  'VAL_IDX'
           ,p_eng_sql        =>  l_rgn_cnt_sql
           ,p_data_table     =>  l_process_table
           ,p_table_alias    =>  l_table_alias
           ,p_run_name       =>  NULL
           ,p_eng_prg        =>  NULL
           ,p_condition      =>  NULL
           ,p_failed_req_id  =>  NULL
           ,p_reuse_slices   =>  l_reuse_slices
           ,x_prg_stat       =>  l_err_msg
           ,x_Exception_code =>  l_exception_code);

         IF (l_err_msg <> G_COMPLETE_NORMAL) THEN
            v_msg_list := v_msg_list_type();

            SELECT DISTINCT(message)
            BULK COLLECT INTO v_msg_list
            FROM fem_mp_process_ctl_t
            WHERE req_id = l_request_id
              AND status = 2;

            FEM_ENGINES_PKG.Tech_Message(
               p_severity => g_log_level_1
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'Total Errors : ' || TO_CHAR(v_msg_list.COUNT));

            -- Log all of the messages
            FOR i IN 1..v_msg_list.COUNT LOOP

               FEM_ENGINES_PKG.Tech_Message(
                  p_severity => g_log_level_5
                 ,p_module   => G_BLOCK||'.'||l_api_name
                 ,p_msg_text => v_msg_list(i));

               FND_FILE.Put_Line(FND_FILE.log, v_msg_list(i));


            END LOOP;

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_MULTI_PROC_ERR);

            Process_Obj_Exec_Step(
                 p_request_id      => l_request_id
                ,p_user_id         => l_user_id
                ,p_login_id        => l_login_id
                ,p_rule_obj_id     => p_rule_obj_id
                ,p_exe_step        => 'VAL_IDX'
                ,p_exe_status_code => g_exec_status_error_rerun
                ,p_tbl_name        => 'FEM_CUSTOMER_PROFIT');

            RAISE e_process_single_rule_error;

         ELSIF(l_err_msg = G_COMPLETE_NORMAL) THEN

            Process_Obj_Exec_Step( p_request_id      => l_request_id
                                  ,p_user_id         => l_user_id
                                  ,p_login_id        => l_login_id
                                  ,p_rule_obj_id     => p_rule_obj_id
                                  ,p_exe_step        => 'VAL_IDX'
                                  ,p_exe_status_code => g_exec_status_success
                                  ,p_tbl_name        => 'FEM_CUSTOMER_PROFIT');

            -- commit the work
            COMMIT;

            -- Purge Data Slices
            FEM_MULTI_PROC_PKG.Delete_Data_Slices (
               p_req_id => l_request_id);

         END IF;
      END IF;

      -- When the given formula has Profit Percentile formula defined
      IF l_profit_exists THEN

       FEM_ENGINES_PKG.Tech_Message (
          p_severity  => g_log_level_3
         ,p_module    => G_BLOCK||'.'||l_api_name
         ,p_msg_text  => 'Building Profit Percentile Value Index SQL');

       -- To Create the bulk SQL to calcualte Value Index
       --based on the Profit Percentile details
       l_prof_ptile_sql := Create_Profit_Pptile_Idx_Stmt(
                            p_object_id              => p_rule_obj_id
                           ,p_customer_level         => p_customer_level
                           ,p_output_column          => p_output_column
                           ,p_cal_period_id          => p_cal_period_id
                           ,p_effective_date         => p_effective_date
                           ,p_dataset_code           => p_output_dataset_code
                           ,p_ledger_id              => p_ledger_id
                           ,p_source_system_code     => p_source_system_code
                           ,p_condition_clause       => l_condition_clause
                           ,p_value_index_formula_id => p_value_index_formula_id
                           ,p_rel_dimension_grp_seq  => l_rel_dimension_grp_seq
                           ,p_attribute_id           => l_attribute_id
                           ,p_version_id             => l_version_id
                           ,p_value_set_id           => l_value_set_id);

         IF(p_exec_state = 'RESTART') THEN
            l_reuse_slices := 'Y';
         ELSE
            l_reuse_slices := 'N';
         END IF;

         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_1
           ,p_module   => G_BLOCK ||'.' || l_api_name
           ,p_msg_text => l_prof_ptile_sql);

         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Registering step: VALUE_INDEX');

         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Submitting to MP Master.p_rule_id: '
                          ||p_rule_obj_id);

         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Submitting Percentile SQL to MP Master.p_eng_sql: '
                          ||l_prof_ptile_sql);

         FEM_MULTI_PROC_PKG.Master(
            p_rule_id        =>  p_rule_obj_id
           ,p_eng_step       =>  'VAL_IDX'
           ,p_eng_sql        =>  l_prof_ptile_sql
           ,p_data_table     =>  l_process_table
           ,p_table_alias    =>  l_table_alias
           ,p_run_name       =>  NULL
           ,p_eng_prg        =>  NULL
           ,p_condition      =>  NULL
           ,p_failed_req_id  =>  NULL
           ,p_reuse_slices   =>  l_reuse_slices
           ,x_prg_stat       =>  l_err_msg
           ,x_Exception_code =>  l_exception_code);

         IF (l_err_msg <> G_COMPLETE_NORMAL) THEN
            v_msg_list := v_msg_list_type();

            SELECT DISTINCT(message)
             BULK COLLECT INTO v_msg_list
            FROM fem_mp_process_ctl_t
            WHERE req_id = l_request_id
              AND status = 2;

            FEM_ENGINES_PKG.Tech_Message(
               p_severity => g_log_level_1
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'Total Errors : ' || TO_CHAR(v_msg_list.COUNT));

            -- Log all of the messages
            FOR i IN 1..v_msg_list.COUNT LOOP

               FEM_ENGINES_PKG.Tech_Message(
                  p_severity => g_log_level_5
                 ,p_module   => G_BLOCK||'.'||l_api_name
                 ,p_msg_text => v_msg_list(i));

               FND_FILE.Put_Line(FND_FILE.log, v_msg_list(i));

            END LOOP;

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_MULTI_PROC_ERR);

            Process_Obj_Exec_Step(
                 p_request_id      => l_request_id
                ,p_user_id         => l_user_id
                ,p_login_id        => l_login_id
                ,p_rule_obj_id     => p_rule_obj_id
                ,p_exe_step        => 'VAL_IDX'
                ,p_exe_status_code => g_exec_status_error_rerun
                ,p_tbl_name        => 'FEM_CUSTOMER_PROFIT');

            RAISE e_process_single_rule_error;

         ELSIF(l_err_msg = G_COMPLETE_NORMAL) THEN

            Process_Obj_Exec_Step( p_request_id      => l_request_id
                                  ,p_user_id         => l_user_id
                                  ,p_login_id        => l_login_id
                                  ,p_rule_obj_id     => p_rule_obj_id
                                  ,p_exe_step        => 'VAL_IDX'
                                  ,p_exe_status_code => g_exec_status_success
                                  ,p_tbl_name        => 'FEM_CUSTOMER_PROFIT');

            -- commit the work
            COMMIT;

            -- Purge Data Slices
            FEM_MULTI_PROC_PKG.Delete_Data_Slices (
               p_req_id => l_request_id);

         END IF;
      END IF;

      ------- Get all the product that matches the criteria --------------------

      -- When the given formula has Product formula defined
      IF l_product_exists THEN

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_3
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Building Product attribute Value Index SQL');

         -- Get the Attribute and Version Ids of the Product id of Customer
	 -- Dimension
         SELECT  dim_attr.attribute_id
                ,ver.version_id
           INTO  l_attribute_id
                ,l_version_id
         FROM   fem_dim_attributes_b dim_attr,
                fem_dimensions_b xdim,
                fem_dim_attr_versions_b ver
         WHERE  dim_attr.dimension_id = xdim.dimension_id
           AND  dim_attr.attribute_id = ver.attribute_id
           AND  dim_attr.attribute_varchar_label = 'PRODUCT_ID'
           AND  xdim.dimension_varchar_label = 'CUSTOMER';

         -- To Create the bulk SQL to calcualte Value Index
         --based on the Product Dimension details
         l_prod_cd_sql := Create_Product_Id_Index_Stmt(
                            p_object_id              => p_rule_obj_id
                           ,p_customer_level         => p_customer_level
                           ,p_output_column          => p_output_column
                           ,p_cal_period_id          => p_cal_period_id
                           ,p_effective_date         => p_effective_date
                           ,p_dataset_code           => p_output_dataset_code
                           ,p_ledger_id              => p_ledger_id
                           ,p_source_system_code     => p_source_system_code
                           ,p_condition_clause       => l_condition_clause
                           ,p_value_index_formula_id => p_value_index_formula_id
                           ,p_rel_dimension_grp_seq  => l_rel_dimension_grp_seq
                           ,p_attribute_id           => l_attribute_id
                           ,p_version_id             => l_version_id
                           ,p_value_set_id           => l_value_set_id);

         IF(p_exec_state = 'RESTART') THEN
            l_reuse_slices := 'Y';
         ELSE
            l_reuse_slices := 'N';
         END IF;

         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_1
           ,p_module   => G_BLOCK ||'.' || l_api_name
           ,p_msg_text => l_prod_cd_sql);

         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Registering step: VALUE_INDEX');

         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Submitting to MP Master.p_rule_id: '
                          ||p_rule_obj_id);

         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Submitting Region Count SQL to MP Master.p_eng_sql: '
                          ||l_prod_cd_sql);

         FEM_MULTI_PROC_PKG.Master(
            p_rule_id        =>  p_rule_obj_id
           ,p_eng_step       =>  'VAL_IDX'
           ,p_eng_sql        =>  l_prod_cd_sql
           ,p_data_table     =>  l_process_table
           ,p_table_alias    =>  l_table_alias
           ,p_run_name       =>  NULL
           ,p_eng_prg        =>  NULL
           ,p_condition      =>  NULL
           ,p_failed_req_id  =>  NULL
           ,p_reuse_slices   =>  l_reuse_slices
           ,x_prg_stat       =>  l_err_msg
           ,x_Exception_code =>  l_exception_code);

         IF (l_err_msg <> G_COMPLETE_NORMAL) THEN
            v_msg_list := v_msg_list_type();

            SELECT DISTINCT(message)
             BULK COLLECT INTO v_msg_list
            FROM fem_mp_process_ctl_t
            WHERE req_id = l_request_id
              AND status = 2;

            FEM_ENGINES_PKG.Tech_Message(
               p_severity => g_log_level_1
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'Total Errors : ' || TO_CHAR(v_msg_list.COUNT));

            -- Log all of the messages
            FOR i IN 1..v_msg_list.COUNT LOOP

               FEM_ENGINES_PKG.Tech_Message(
                  p_severity => g_log_level_5
                 ,p_module   => G_BLOCK||'.'||l_api_name
                 ,p_msg_text => v_msg_list(i));

               FND_FILE.Put_Line(FND_FILE.log, v_msg_list(i));

            END LOOP;

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_MULTI_PROC_ERR);

            Process_Obj_Exec_Step(
                p_request_id      => l_request_id
               ,p_user_id         => l_user_id
               ,p_login_id        => l_login_id
               ,p_rule_obj_id     => p_rule_obj_id
               ,p_exe_step        => 'VAL_IDX'
               ,p_exe_status_code => g_exec_status_error_rerun
               ,p_tbl_name        => 'FEM_CUSTOMER_PROFIT');

            RAISE e_process_single_rule_error;

         ELSIF(l_err_msg = G_COMPLETE_NORMAL) THEN

            Process_Obj_Exec_Step( p_request_id      => l_request_id
                                  ,p_user_id         => l_user_id
                                  ,p_login_id        => l_login_id
                                  ,p_rule_obj_id     => p_rule_obj_id
                                  ,p_exe_step        => 'VAL_IDX'
                                  ,p_exe_status_code => g_exec_status_success
                                  ,p_tbl_name        => 'FEM_CUSTOMER_PROFIT');

            -- commit the work
            COMMIT;

            -- Purge Data Slices
            FEM_MULTI_PROC_PKG.Delete_Data_Slices (
               p_req_id => l_request_id);

         END IF;
      END IF;

      IF g_num_rows = 0 THEN
         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_NO_OP_ROWS_ERR);
      END IF;

      FEM_ENGINES_PKG.Tech_Message ( p_severity => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');

   EXCEPTION
      WHEN e_process_single_rule_error THEN

         IF l_cv_chains%ISOPEN THEN
           CLOSE l_cv_chains;
         END IF;

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Generate Value Index Error:
                            Process Single Rule Exception');

         FEM_ENGINES_PKG.User_Message (p_app_name  => G_PFT
                                      ,p_msg_name  => G_ENG_SINGLE_RULE_ERR);

         x_return_status  := FND_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN

         IF l_cv_chains%ISOPEN THEN
           CLOSE l_cv_chains;
         END IF;

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Generate Value Index Error:
                            Process Single Rule Exception');

         FEM_ENGINES_PKG.User_Message (p_app_name  => G_PFT
                                      ,p_msg_name  => G_ENG_SINGLE_RULE_ERR);

         x_return_status  := FND_API.G_RET_STS_ERROR;

   END Process_Single_Rule;

 /*============================================================================+
 | PROCEDURE
 |   Update_Num_Of_Output_Rows
 |
 | DESCRIPTION
 |   Updates the rows successfully processed by calling
 |   fem_pl_pkg.Update_Num_Of_Output_Rows in fem_pl_tables.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Update_Nbr_Of_Output_Rows( p_request_id       IN NUMBER
                                       ,p_user_id          IN NUMBER
                                       ,p_login_id         IN NUMBER
                                       ,p_rule_obj_id      IN NUMBER
                                       ,p_num_output_rows  IN  NUMBER
                                       ,p_tbl_name         IN  VARCHAR2
                                       ,p_stmt_type        IN  VARCHAR2)
   IS

   l_api_name          CONSTANT    VARCHAR2(30) := 'Update_Num_Of_Output_Rows';

   l_return_status                 VARCHAR2(2);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(240);

   e_upd_num_output_rows_error     EXCEPTION;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Set the number of output rows for the output table.
      FEM_PL_PKG.Update_Num_Of_Output_Rows(
         p_api_version          =>  1.0
        ,p_commit               =>  FND_API.G_TRUE
        ,p_request_id           =>  p_request_id
        ,p_object_id            =>  p_rule_obj_id
        ,p_table_name           =>  p_tbl_name
        ,p_statement_type       =>  p_stmt_type
        ,p_num_of_output_rows   =>  p_num_output_rows
        ,p_user_id              =>  p_user_id
        ,p_last_update_login    =>  p_login_id
        ,x_msg_count            =>  l_msg_count
        ,x_msg_data             =>  l_msg_data
        ,x_return_status        =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         Get_Put_Messages( p_msg_count => l_msg_count
                          ,p_msg_data  => l_msg_data);
         RAISE e_upd_num_output_rows_error;
      END IF;

      FEM_ENGINES_PKG.Tech_Message( p_severity  => g_log_level_2
                                   ,p_module    => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_upd_num_output_rows_error THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Update Rows Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_OP_UPD_ROWS_ERR);

      RAISE e_process_single_rule_error;

      WHEN OTHERS THEN
         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_OP_UPD_ROWS_ERR);

      RAISE;

   END Update_Nbr_Of_Output_Rows;

 /*============================================================================+
 | PROCEDURE
 |   Update_Obj_Exec_Step_Status
 |
 | DESCRIPTION
 |   Updates the status of the executuon of the object by calling
 |   fem_pl_pkg.Update_obj_exec_step_status in fem_pl_obj_steps.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Update_Obj_Exec_Step_Status( p_request_id       IN NUMBER
                                         ,p_user_id          IN NUMBER
                                         ,p_login_id         IN NUMBER
                                         ,p_rule_obj_id      IN NUMBER
                                         ,p_exe_step         IN VARCHAR2
                                         ,p_exe_status_code  IN VARCHAR2)
   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Update_Obj_Exe_Step_Status';

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(240);

   e_upd_obj_exec_step_stat_error  EXCEPTION;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      --Call the FEM_PL_PKG.Update_obj_exec_step_status API procedure
      --to update step staus in fem_pl_obj_steps.
      FEM_PL_PKG.Update_obj_Exec_Step_Status(
         p_api_version          =>  1.0
        ,p_commit               =>  FND_API.G_TRUE
        ,p_request_id           =>  p_request_id
        ,p_object_id            =>  p_rule_obj_id
        ,p_exec_step            =>  p_exe_step
        ,p_exec_status_code     =>  p_exe_status_code
        ,p_user_id              =>  p_user_id
        ,p_last_update_login    =>  p_login_id
        ,x_msg_count            =>  l_msg_count
        ,x_msg_data             =>  l_msg_data
        ,x_return_status        =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         RAISE e_upd_obj_exec_step_stat_error;

      END IF;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN  e_upd_obj_exec_step_stat_error   THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Update Obj Exec Step API Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_UPD_EXEC_STEP_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_rule_obj_id);

      RAISE e_process_single_rule_error;

      WHEN OTHERS THEN
         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_UPD_EXEC_STEP_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_rule_obj_id);

      RAISE e_process_single_rule_error;

   END Update_Obj_Exec_Step_Status;

 /*============================================================================+
 | PROCEDURE
 |   Get_Nbr_RowsTable_For_Request
 |
 | DESCRIPTION
 |   To find the number rows processed by the request.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Get_Nbr_RowsTable_Request( x_rows_processed    OUT NOCOPY NUMBER,
                    x_rows_loaded       OUT NOCOPY NUMBER,
                    x_rows_rejected     OUT NOCOPY NUMBER,
                    p_request_id        IN  NUMBER)
   IS

   l_api_name      CONSTANT VARCHAR2(30) := 'Get_Nbr_RowsTable_Request';

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      --Query the fem_mp_process_ctl_t table to get the number of rows
      --processed per request
      SELECT  NVL(SUM(rows_processed),0),
              NVL(SUM(rows_rejected),0),
	      NVL(SUM(rows_loaded),0)
        INTO  x_rows_processed,
	      x_rows_rejected,
	      x_rows_loaded
       FROM   fem_mp_process_ctl_t t
       WHERE  t.req_id = p_request_id
	 AND  t.process_num > 0;


      IF (x_rows_processed = 0) THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'No Rows returned by the  Insert Statement');

         IF g_num_rows <= 0 THEN
            g_num_rows := 0;
         END IF;

      ELSE
         g_num_rows := x_rows_processed;
      END IF;

      FEM_ENGINES_PKG.Tech_Message( p_severity  => g_log_level_2
                                   ,p_module    => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text  => 'END');

   EXCEPTION
      WHEN OTHERS THEN

      RAISE;
   END Get_Nbr_RowsTable_Request;

 /*============================================================================+
 | PROCEDURE
 |   Process_Obj_Exec_Step
 | DESCRIPTION
 |   Processes the execution of the Object.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Process_Obj_Exec_Step( p_request_id      IN NUMBER
                                   ,p_user_id         IN NUMBER
                                   ,p_login_id        IN NUMBER
                                   ,p_rule_obj_id     IN NUMBER
                                   ,p_exe_step        IN VARCHAR2
                                   ,p_exe_status_code IN VARCHAR2
                                   ,p_tbl_name        IN VARCHAR2)
   IS
   l_api_name           VARCHAR2(30);
   l_nbr_output_rows    NUMBER;
   l_nbr_input_rows     NUMBER;
   l_nbr_rejected_rows  NUMBER;
   l_nbr_loaded_rows    NUMBER;

   BEGIN
      l_api_name           := 'Process_Obj_Exec_Step';
      l_nbr_output_rows    := NULL;
      l_nbr_input_rows     := NULL;

      FEM_ENGINES_PKG.TECH_MESSAGE( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'BEGIN');

      ------------------------------------------------------------------------
      --Update the status of the step
      ------------------------------------------------------------------------

      FEM_ENGINES_PKG.Tech_Message(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Update the status of the step with execution status :'
                       ||p_exe_status_code);

      Update_Obj_Exec_Step_Status( p_request_id       => p_request_id
                                  ,p_user_id          => p_user_id
                                  ,p_login_id         => p_login_id
                                  ,p_rule_obj_id      => p_rule_obj_id
                                  ,p_exe_step         => 'VAL_IDX'
                                  ,p_exe_status_code  => p_exe_status_code );

      IF (p_exe_status_code = g_exec_status_success) THEN
         -- query table fem_mp_process_ctl_t to get the number of rows processed
         Get_Nbr_RowsTable_Request( x_rows_processed => l_nbr_output_rows,
                                    x_rows_loaded    => l_nbr_loaded_rows,
                                    x_rows_rejected  => l_nbr_rejected_rows,
                                    p_request_id     => p_request_id);

         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Rows processed for registered output table :'
                          ||p_tbl_name);

         -- update the number of rows processed in the registered table
         Update_Nbr_Of_Output_Rows(p_request_id       =>  p_request_id
                                  ,p_user_id          =>  p_user_id
                                  ,p_login_id         =>  p_login_id
                                  ,p_rule_obj_id      =>  p_rule_obj_id
                                  ,p_num_output_rows  =>  l_nbr_output_rows
                                  ,p_tbl_name         =>  p_tbl_name
                                  ,p_stmt_type        =>  g_update );

         -----------------------------------------------------------------------
         -- Call FEM_PL_PKG.update_num_of_input_rows();
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_1,
            p_module   => G_BLOCK||'.'||l_api_name,
            p_msg_text => 'No:of Rows processed from input table'
                          ||l_nbr_loaded_rows );

         -- update the number of rows processed in the registered table
         Update_Nbr_Of_Input_Rows(  p_request_id        =>  p_request_id
                                   ,p_user_id           =>  p_user_id
                                   ,p_last_update_login =>  p_login_id
                                   ,p_rule_obj_id       =>  p_rule_obj_id
                                   ,p_num_of_input_rows =>  l_nbr_output_rows);

         IF l_nbr_output_rows > 0 THEN
            FEM_ENGINES_PKG.User_Message(
               p_app_name => G_PFT,
               p_msg_name => 'PFT_PPROF_VIDX_ROW_SUMMARY',
               p_token1   => 'ROWSP',
               p_value1   => l_nbr_output_rows,
               p_token2   => 'ROWSL',
               p_value2   => l_nbr_output_rows);
         END IF;

      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'END');

      EXCEPTION
      WHEN OTHERS THEN
      RAISE e_process_single_rule_error;

   END;


/*=============================================================================+
 | FUNCTION
 |   Create Region Count Value Index Statement
 |
 | DESCRIPTION
 |   Creates the Bulk SQL for Region Counting Value Index
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

  FUNCTION Create_Region_Cnt_Index_Stmt ( p_object_id              IN NUMBER
                                         ,p_customer_level         IN NUMBER
                                         ,p_output_column          IN VARCHAR2
                                         ,p_cal_period_id          IN NUMBER
                                         ,p_effective_date         IN VARCHAR2
                                         ,p_dataset_code           IN NUMBER
                                         ,p_ledger_id              IN NUMBER
                                         ,p_source_system_code     IN NUMBER
                                         ,p_condition_clause       IN LONG
                                         ,p_value_index_formula_id IN NUMBER
                                         ,p_rel_dimension_grp_seq  IN NUMBER
                                         ,p_attribute_id           IN NUMBER
                                         ,p_version_id             IN NUMBER
                                         ,p_value_set_id           IN NUMBER)
   RETURN LONG IS

   l_api_name       CONSTANT    VARCHAR2(30) := 'Create_Region_Cnt_Index_Stmt';

   l_update_stmt                LONG;
   l_select_stmt                LONG;
   l_from_stmt                  LONG;
   l_where_stmt                 LONG;
   l_request_id                 NUMBER;
   l_effective_date             DATE;
   l_user_id                    NUMBER;
   l_login_id                   NUMBER := FND_GLOBAL.Login_Id;

   BEGIN
      l_request_id             :=  FND_GLOBAL.Conc_Request_Id;
      l_user_id                :=  FND_GLOBAL.User_Id;
      l_effective_date         :=  FND_DATE.Canonical_To_Date(p_effective_date);



      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

        l_update_stmt := ' UPDATE fem_customer_profit fcp' ||
                         ' SET fcp.' || p_output_column ||' =  NVL('||
                         p_output_column || ',0) + ' ||
                         ' ( SELECT NVL(factor_weight,0) ' ||
                         ' FROM pft_val_index_ranges a, ';

        l_select_stmt := ' ( SELECT region_pct_total_cust, ' ||
                         ' cust.customer_id ' ||
                         ' FROM fem_customers_b cust, ' ||
                         ' fem_region_info fri, ' ||
                         ' fem_customers_attr fca ';

        l_where_stmt :=  ' WHERE cust.dimension_group_id = fri.dimension_group_id ' ||
                         ' AND cust.value_set_id = ' || p_value_set_id ||
                         ' AND fri.region_code = fca.number_assign_value ' ||
                         ' AND fca.customer_id = cust.customer_id ' ||
                         ' AND fca.attribute_id = ' || p_attribute_id ||
                         ' AND fca.version_id =  ' || p_version_id ||
                         ' AND fri.cal_period_id = ' || p_cal_period_id ||
                         ' AND fri.dataset_code  = ' || p_dataset_code ||
                         ' AND fri.source_system_code = ' ||  p_source_system_code ||
                         ' AND fri.ledger_id = ' || p_ledger_id ||
                         ' AND fri.dimension_group_id = ' ||  p_customer_level || ' )b ' ||
                         ' WHERE b.region_pct_total_cust BETWEEN ' ||
                         ' low_range AND high_range ' ||
                         ' AND measure_type = ''REGION_COUNTING''' ||
                         ' AND value_index_formula_id = ' || p_value_index_formula_id ||
                         ' AND fcp.ledger_id = ' || p_ledger_id ||
                         ' AND fcp.dataset_code = ' || p_dataset_code ||
                         ' AND fcp.source_system_code = ' || p_source_system_code ||
                         ' AND fcp.cal_period_id = ' || p_cal_period_id ||
                         ' AND b.customer_id = fcp.customer_id)' || ' , ' ||
                         ' fcp.LAST_UPDATED_BY_REQUEST_ID = ' || l_request_id || ', ' ||
                         ' fcp.LAST_UPDATED_BY_OBJECT_ID = ' || p_object_id ||
                         ' WHERE fcp.cal_period_id = ' || p_cal_period_id ||
                         ' AND fcp.dataset_code  = ' || p_dataset_code||
                         ' AND fcp.source_system_code = ' || p_source_system_code ||
                         ' AND fcp.ledger_id = ' || p_ledger_id ||
                         ' AND fcp.customer_id IN ( SELECT cust.customer_id '||
                         ' FROM fem_customers_b cust, ' ||
                         ' fem_region_info fri, ' ||
                         ' fem_customers_attr fca ' ||
                         ' WHERE cust.dimension_group_id = fri.dimension_group_id ' ||
                         ' AND cust.value_set_id = ' || p_value_set_id ||
                         ' AND fri.region_code = fca.number_assign_value ' ||
                         ' AND fca.customer_id = cust.customer_id ' ||
                         ' AND fca.attribute_id = ' || p_attribute_id ||
                         ' AND fca.version_id =  ' || p_version_id ||
                         ' AND fri.cal_period_id = ' || p_cal_period_id ||
                         ' AND fri.dataset_code  = ' || p_dataset_code ||
                         ' AND fri.source_system_code = ' ||  p_source_system_code ||
                         ' AND fri.ledger_id = ' || p_ledger_id ||
                         ' AND fri.dimension_group_id = ' || p_customer_level ||' ) ' ||
                         ' AND fcp.data_aggregation_type_code = ' || '''CUSTOMER_AGGREGATION''';

      IF p_condition_clause IS NOT NULL THEN
         l_where_stmt := l_where_stmt || ' AND ' || p_condition_clause;
      END IF;

      -- Creates the final where clause
      l_where_stmt := l_where_stmt || ' AND '|| ' {{data_slice}} ';

      -- add mapped columns
      RETURN l_update_stmt || ' ' || l_select_stmt || ' ' || l_where_stmt;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');

      EXCEPTION
        WHEN OTHERS THEN
        RAISE e_process_single_rule_error;

   END Create_Region_Cnt_Index_Stmt;

/*=============================================================================+
 | FUNCTION
 |   Create Profit Percentile Value Index Statement
 |
 | DESCRIPTION
 |   Creates the Bulk SQL for Profit Percentile Value Index
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

  FUNCTION Create_Profit_Pptile_Idx_Stmt ( p_object_id              IN NUMBER
                                          ,p_customer_level         IN NUMBER
                                          ,p_output_column          IN VARCHAR2
                                          ,p_cal_period_id          IN NUMBER
                                          ,p_effective_date         IN VARCHAR2
                                          ,p_dataset_code           IN NUMBER
                                          ,p_ledger_id              IN NUMBER
                                          ,p_source_system_code     IN NUMBER
                                          ,p_condition_clause       IN LONG
                                          ,p_value_index_formula_id IN NUMBER
                                          ,p_rel_dimension_grp_seq  IN NUMBER
                                          ,p_attribute_id           IN NUMBER
                                          ,p_version_id             IN NUMBER
                                          ,p_value_set_id           IN NUMBER)
   RETURN LONG IS

   l_api_name       CONSTANT    VARCHAR2(30) := 'Create_Profit_Pptile_Idx_Stmt';

   l_update_stmt                LONG;
   l_select_stmt                LONG;
   l_from_stmt                  LONG;
   l_where_stmt                 LONG;
   l_request_id                 NUMBER;
   l_effective_date             DATE;
   l_user_id                    NUMBER;
   l_login_id                   NUMBER := FND_GLOBAL.Login_Id;

   BEGIN
      l_request_id             :=  FND_GLOBAL.Conc_Request_Id;
      l_user_id                :=  FND_GLOBAL.user_Id;
      l_effective_date         :=  FND_DATE.Canonical_To_Date(p_effective_date);

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      l_update_stmt := ' UPDATE fem_customer_profit fcp' ||
                       ' SET fcp.' || p_output_column ||' =  NVL('||
                       p_output_column || ',0) + ' ||
                       ' ( SELECT NVL(factor_weight,0) ' ||
                       ' FROM pft_val_index_ranges a, ';

      l_select_stmt := ' (SELECT profit_percentile,cust.customer_id' ||
                       ' FROM fem_customers_b cust, ' ||
                       ' fem_customer_profit fcp ';

      l_where_stmt  := ' WHERE cust.dimension_group_id = ' || p_customer_level ||
                       ' AND cust.value_set_id = ' || p_value_set_id ||
                       ' AND fcp.customer_id = cust.customer_id ' ||
                       ' AND fcp.cal_period_id = ' || p_cal_period_id ||
                       ' AND fcp.dataset_code  = ' || p_dataset_code ||
                       ' AND fcp.source_system_code = ' || p_source_system_code ||
                       ' AND fcp.ledger_id = ' || p_ledger_id ||
                       ' AND fcp.data_aggregation_type_code = ' ||
                       '''CUSTOMER_AGGREGATION''' || ' )b ' ||
                       ' WHERE b.profit_percentile BETWEEN ' ||
                       ' low_range AND high_range ' ||
                       ' AND measure_type = ''PROFIT_PERCENTILE''' ||
                       ' AND value_index_formula_id = ' || p_value_index_formula_id ||
                       ' AND b.customer_id = fcp.customer_id )' || ' , '||
                       ' fcp.LAST_UPDATED_BY_REQUEST_ID = ' || l_request_id || ', ' ||
                       ' fcp.LAST_UPDATED_BY_OBJECT_ID = ' || p_object_id ||
                       ' WHERE fcp.cal_period_id = ' || p_cal_period_id ||
                       ' AND fcp.dataset_code  = ' || p_dataset_code||
                       ' AND fcp.source_system_code = ' || p_source_system_code ||
                       ' AND fcp.ledger_id = ' || p_ledger_id ||
                       ' AND fcp.customer_id IN ( SELECT cust.customer_id '||
                       ' FROM fem_customers_b cust ' ||
                       ' WHERE cust.dimension_group_id = ' || p_customer_level ||
                       ' AND cust.value_set_id = ' || p_value_set_id || ' ) ' ||
                       ' AND fcp.data_aggregation_type_code = ' || '''CUSTOMER_AGGREGATION''';

      IF p_condition_clause IS NOT NULL THEN
         l_where_stmt := l_where_stmt || ' AND ' || p_condition_clause;
      END IF;

      -- Creates the final where clause
      l_where_stmt := l_where_stmt || ' AND '|| ' {{data_slice}} ';

      -- add mapped columns
      RETURN l_update_stmt || ' ' || l_select_stmt || ' ' || l_where_stmt;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');

      EXCEPTION
        WHEN OTHERS THEN
        RAISE e_process_single_rule_error;

   END Create_Profit_Pptile_Idx_Stmt;

/*=============================================================================+
 | FUNCTION
 |   Create Product ID Value Index Statement
 |
 | DESCRIPTION
 |   Creates the Bulk SQL for Product Dimension based Value Index
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

  FUNCTION Create_Product_Id_Index_Stmt ( p_object_id              IN NUMBER
                                         ,p_customer_level         IN NUMBER
                                         ,p_output_column          IN VARCHAR2
                                         ,p_cal_period_id          IN NUMBER
                                         ,p_effective_date         IN VARCHAR2
                                         ,p_dataset_code           IN NUMBER
                                         ,p_ledger_id              IN NUMBER
                                         ,p_source_system_code     IN NUMBER
                                         ,p_condition_clause       IN LONG
                                         ,p_value_index_formula_id IN NUMBER
                                         ,p_rel_dimension_grp_seq  IN NUMBER
                                         ,p_attribute_id           IN NUMBER
                                         ,p_version_id             IN NUMBER
                                         ,p_value_set_id           IN NUMBER)
   RETURN LONG IS

   l_api_name       CONSTANT    VARCHAR2(30) := 'Create_Product_Id_Index_Stmt';

   l_update_stmt                LONG;
   l_select_stmt                LONG;
   l_where_stmt                 LONG;
   l_request_id                 NUMBER;
   l_effective_date             DATE;
   l_user_id                    NUMBER;
   l_login_id                   NUMBER := FND_GLOBAL.login_id;

   BEGIN
      l_request_id             :=  FND_GLOBAL.Conc_Request_Id;
      l_user_id                :=  FND_GLOBAL.User_Id;
      l_effective_date         :=  FND_DATE.Canonical_To_Date(p_effective_date);



      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

        l_update_stmt := ' UPDATE fem_customer_profit fcp' ||
                         ' SET fcp.' || p_output_column ||' =  NVL('||
                         p_output_column || ',0) + ' ||
                         ' ( SELECT NVL(factor_weight,0) ' ||
                         ' FROM pft_val_index_counting a, ';
        l_select_stmt := ' (SELECT fca.dim_attribute_numeric_member product_id'||
                         ' , cust.customer_id ' ||
                         ' FROM fem_customers_b cust, ' ||
                         ' fem_customers_attr fca';
        l_where_stmt :=  ' WHERE cust.dimension_group_id = ' || p_customer_level ||
                         ' AND cust.value_set_id = ' || p_value_set_id ||
                         ' AND fca.customer_id = cust.customer_id ' ||
                         ' AND fca.attribute_id = ' || p_attribute_id ||
                         ' AND fca.version_id =  ' || p_version_id || ' )b ' ||
                         ' WHERE b.product_id = a.product_id ' ||
                         ' AND value_index_formula_id = ' || p_value_index_formula_id ||
                         ' AND fcp.ledger_id = ' || p_ledger_id ||
                         ' AND fcp.dataset_code = ' || p_dataset_code ||
                         ' AND fcp.source_system_code = ' || p_source_system_code ||
                         ' AND fcp.cal_period_id = ' || p_cal_period_id ||
                         ' AND b.customer_id = fcp.customer_id)' || ' , ' ||
                         ' fcp.LAST_UPDATED_BY_REQUEST_ID = ' || l_request_id || ', ' ||
                         ' fcp.LAST_UPDATED_BY_OBJECT_ID = ' || p_object_id ||
                         ' WHERE fcp.cal_period_id = ' || p_cal_period_id ||
                         ' AND fcp.dataset_code  = ' || p_dataset_code||
                         ' AND fcp.source_system_code = ' || p_source_system_code ||
                         ' AND fcp.ledger_id = ' || p_ledger_id ||
                         ' AND fcp.customer_id IN ( SELECT cust.customer_id '||
                         ' FROM fem_customers_b cust, ' ||
                         ' fem_customers_attr fca ' ||
                         ' WHERE cust.dimension_group_id = ' || p_customer_level ||
                         ' AND cust.value_set_id = ' || p_value_set_id ||
                         ' AND fca.customer_id = cust.customer_id ' ||
                         ' AND fca.attribute_id = ' || p_attribute_id ||
                         ' AND fca.version_id =  ' || p_version_id ||' ) ' ||
                         ' AND fcp.data_aggregation_type_code = ' || '''CUSTOMER_AGGREGATION''';


      IF p_condition_clause IS NOT NULL THEN
         l_where_stmt := l_where_stmt || ' AND ' || p_condition_clause;
      END IF;

      -- Creates the final where clause
      l_where_stmt := l_where_stmt || ' AND '|| ' {{data_slice}} ';

      -- add mapped columns
      RETURN l_update_stmt || ' ' || l_select_stmt || ' ' || l_where_stmt;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');

      EXCEPTION
        WHEN OTHERS THEN
        RAISE e_process_single_rule_error;

   END Create_Product_Id_Index_Stmt;

 /*============================================================================+
 | PROCEDURE
 |   Get_Put_Messages
 |
 | DESCRIPTION
 |   To put the User messages,to be placed in common loader package.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   PROCEDURE Get_Put_Messages ( p_msg_count         IN NUMBER
                               ,p_msg_data          IN VARCHAR2)
   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Get_Put_Messages';
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(4000);
   l_msg_out                       NUMBER;
   l_message                       VARCHAR2(4000);

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'msg_count='||p_msg_count);

      l_msg_data := p_msg_data;

      IF (p_msg_count = 1) THEN

         FND_MESSAGE.Set_Encoded(l_msg_data);
         l_message := FND_MESSAGE.Get;

         FEM_ENGINES_PKG.User_Message ( p_msg_text => l_message );

         FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                       ,p_module    => G_BLOCK||'.'||l_api_name
                                       ,p_msg_text  => 'msg_data='||l_message);

      ELSIF (p_msg_count > 1) THEN

         FOR i IN 1..p_msg_count LOOP
            FND_MSG_PUB.Get ( p_msg_index     => i
                             ,p_encoded       => FND_API.G_FALSE
                             ,p_data          => l_message
                             ,p_msg_index_out => l_msg_out);

            FEM_ENGINES_PKG.User_Message ( p_msg_text => l_message );

            FEM_ENGINES_PKG.Tech_Message ( p_severity => g_log_level_2
                                          ,p_module   => G_BLOCK||'.'||l_api_name
                                          ,p_msg_text => 'msg_data = '||l_message);

         END LOOP;

      END IF;

      FND_MSG_PUB.Initialize;

   END Get_Put_Messages;

 /*============================================================================+
 | PROCEDURE
 |   Register_Updated_Column
 |
 | DESCRIPTION
 |   This procedure is used to register a column updated during object execution
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Register_Updated_Column( p_request_id         IN NUMBER
                                     ,p_object_id          IN NUMBER
                                     ,p_user_id            IN NUMBER
                                     ,p_last_update_login  IN NUMBER
                                     ,p_table_name         IN  VARCHAR2
                                     ,p_statement_type     IN  VARCHAR2
                                     ,p_column_name        IN  VARCHAR2)
   IS

   l_api_name         CONSTANT    VARCHAR2(30) := 'Register_Updated_Column';

   l_return_status                VARCHAR2(2);
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2(240);

   e_reg_updated_column_error     EXCEPTION;

    BEGIN
       FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                     ,p_module    => G_BLOCK||'.'||l_api_name
                                     ,p_msg_text  => 'BEGIN');

       -- Set the number of output rows for the output table.
       FEM_PL_PKG.register_updated_column(
          p_api_version          =>  1.0
         ,p_commit               =>  FND_API.G_TRUE
         ,p_request_id           =>  p_request_id
         ,p_object_id            =>  p_object_id
         ,p_table_name           =>  p_table_name
         ,p_statement_type       =>  p_statement_type
         ,p_column_name          =>  p_column_name
         ,p_user_id              =>  p_user_id
         ,p_last_update_login    =>  p_last_update_login
         ,x_msg_count            =>  l_msg_count
         ,x_msg_data             =>  l_msg_data
         ,x_return_status        =>  l_return_status);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

          Get_Put_Messages( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
          RAISE e_reg_updated_column_error;
       END IF;

       FEM_ENGINES_PKG.Tech_Message( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

    EXCEPTION
       WHEN e_reg_updated_column_error THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register_Updated_Column_Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_UPD_COL_ERR
           ,p_token1    => 'TABLE_NAME'
           ,p_value1    => p_table_name
           ,p_token2    => 'COLUMN_NAME'
           ,p_value2    => p_column_name);

       RAISE e_process_single_rule_error;

       WHEN OTHERS THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register_Updated_Column_Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_UPD_COL_ERR
           ,p_token1    => 'TABLE_NAME'
           ,p_value1    => p_table_name
           ,p_token2    => 'COLUMN_NAME'
           ,p_value2    => p_column_name);

       RAISE e_process_single_rule_error;

    END Register_Updated_Column;

 /*============================================================================+
 | PROCEDURE
 |   Update_Num_Of_Input_Rows
 |
 | DESCRIPTION
 |   This procedure logs the total number of rows used as input into
 | an object execution
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   PROCEDURE Update_Nbr_Of_Input_Rows( p_request_id             IN  NUMBER
                                      ,p_user_id                IN  NUMBER
                                      ,p_last_update_login      IN  NUMBER
                                      ,p_rule_obj_id            IN  NUMBER
                                      ,p_num_of_input_rows      IN  NUMBER )
   IS

   l_api_name   CONSTANT VARCHAR2(30) := 'Update_Num_Of_Input_Rows';

   l_return_status       VARCHAR2(2);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(240);

   e_upd_num_input_rows_error     EXCEPTION;

    BEGIN

       FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                     ,p_module    => G_BLOCK||'.'||l_api_name
                                     ,p_msg_text  => 'BEGIN');

       -- Set the number of output rows for the output table.
       FEM_PL_PKG.Update_Num_Of_Input_Rows(
          p_api_version          =>  1.0
         ,p_commit               =>  FND_API.G_TRUE
         ,p_request_id           =>  p_request_id
         ,p_object_id            =>  p_rule_obj_id
         ,p_num_of_input_rows    =>  p_num_of_input_rows
         ,p_user_id              =>  p_user_id
         ,p_last_update_login    =>  p_last_update_login
         ,x_msg_count            =>  l_msg_count
         ,x_msg_data             =>  l_msg_data
         ,x_return_status        =>  l_return_status);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

          Get_Put_Messages( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
          RAISE e_upd_num_input_rows_error;
       END IF;

       FEM_ENGINES_PKG.Tech_Message( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

    EXCEPTION
       WHEN e_upd_num_input_rows_error THEN
          FEM_ENGINES_PKG.Tech_Message (
	     p_severity  => g_log_level_5
            ,p_module    => G_BLOCK||'.'||l_api_name
            ,p_msg_text  => 'Update Input Rows Exception');

          FEM_ENGINES_PKG.User_Message (
             p_app_name  => G_PFT
            ,p_msg_name  => G_PL_IP_UPD_ROWS_ERR);

       RAISE e_process_single_rule_error;

       WHEN OTHERS THEN
          FEM_ENGINES_PKG.Tech_Message (
             p_severity  => g_log_level_5
            ,p_module    => G_BLOCK||'.'||l_api_name
            ,p_msg_text  => 'Update Input Rows Exception');

          FEM_ENGINES_PKG.User_Message (
             p_app_name  => G_PFT
            ,p_msg_name  => G_PL_IP_UPD_ROWS_ERR);

       RAISE e_process_single_rule_error;

    END Update_Nbr_Of_Input_Rows;

 END PFT_PROFCAL_VALIDX_PUB;

/
