--------------------------------------------------------
--  DDL for Package Body PFT_PROFCAL_RGNCNT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_PROFCAL_RGNCNT_PUB" AS
/* $Header: PFTPRCNTB.pls 120.3 2006/08/25 07:30:25 ssthiaga noship $ */

--------------------------------------------------------------------------------
-- Declare package constants --
--------------------------------------------------------------------------------

  g_object_version_number     CONSTANT    NUMBER        :=  1;
  g_pkg_name                  CONSTANT    VARCHAR2(30)  :=  'PFT_PROFCAL_RGNCNT_PUB';

  -- Constants for p_exec_status_code
  g_exec_status_error_rerun   CONSTANT    VARCHAR2(30)  :=  'ERROR_RERUN';
  g_exec_status_success       CONSTANT    VARCHAR2(30)  :=  'SUCCESS';

  --Constants for output table names being registered with fem_pl_pkg
  -- API register_table method.
  g_fem_customer_profit  CONSTANT    VARCHAR2(30)  :=  'FEM_CUSTOMER_PROFIT';
  g_fem_region_info      CONSTANT    VARCHAR2(30)  :=  'FEM_REGION_INFO';

  --constant for sql_stmt_type
  g_insert               CONSTANT    VARCHAR2(30)  :=  'INSERT';

  g_default_fetch_limit  CONSTANT    NUMBER        :=  99999;

  g_log_level_1          CONSTANT    NUMBER        :=  fnd_log.level_statement;
  g_log_level_2          CONSTANT    NUMBER        :=  fnd_log.level_procedure;
  g_log_level_3          CONSTANT    NUMBER        :=  fnd_log.level_event;
  g_log_level_4          CONSTANT    NUMBER        :=  fnd_log.level_exception;
  g_log_level_5          CONSTANT    NUMBER        :=  fnd_log.level_error;
  g_log_level_6          CONSTANT    NUMBER        :=  fnd_log.level_unexpected;

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
    p_request_id           IN  NUMBER
    ,p_user_id             IN  NUMBER
    ,p_login_id            IN  NUMBER
    ,p_rule_obj_id         IN  NUMBER
    ,p_num_output_rows     IN  NUMBER
    ,p_tbl_name            IN  VARCHAR2
    ,p_stmt_type           IN  VARCHAR2
  );

  PROCEDURE Update_Obj_Exec_Step_Status (
    p_request_id           IN  NUMBER
    ,p_user_id             IN  NUMBER
    ,p_login_id            IN  NUMBER
    ,p_rule_obj_id         IN  NUMBER
    ,p_exe_step            IN  VARCHAR2
    ,p_exe_status_code     IN  VARCHAR2
  );

  PROCEDURE Get_Nbr_RowsTable_Request (
    x_rows_processed       OUT NOCOPY NUMBER
    ,x_rows_loaded         OUT NOCOPY NUMBER
    ,x_rows_rejected       OUT NOCOPY NUMBER
    ,p_request_id          IN  NUMBER
  );

  PROCEDURE Process_Obj_Exec_Step (
    p_request_id           IN  NUMBER
    ,p_user_id             IN  NUMBER
    ,p_login_id            IN  NUMBER
    ,p_rule_obj_id         IN  NUMBER
    ,p_exe_step            IN  VARCHAR2
    ,p_exe_status_code     IN  VARCHAR2
    ,p_tbl_name            IN  VARCHAR2
    ,p_num_rows            IN NUMBER
  );

  PROCEDURE Get_Put_Messages (
    p_msg_count            IN  NUMBER
    ,p_msg_data            IN  VARCHAR2
  );

  FUNCTION Create_Region_Count_Stmt (
    p_rule_obj_id          IN  NUMBER
    ,p_table_name          IN  VARCHAR2
    ,p_cal_period_id       IN  NUMBER
    ,p_effective_date      IN  VARCHAR2
    ,p_dataset_code        IN  NUMBER
    ,p_ledger_id           IN  NUMBER
    ,p_source_system_code  IN  NUMBER
    ,p_total_customers     IN  NUMBER
    ,p_customer_level      IN  NUMBER
    ,p_value_set_id        IN  NUMBER
    ,p_ds_where_clause     IN  LONG)

  RETURN LONG;

  PROCEDURE Update_Nbr_Of_Input_Rows (
    p_request_id           IN  NUMBER
    ,p_user_id             IN  NUMBER
    ,p_last_update_login   IN  NUMBER
    ,p_rule_obj_id         IN  NUMBER
    ,p_num_of_input_rows   IN  NUMBER
  );

  FUNCTION Create_Rgn_Cnt_Wo_RCode_Stmt (
    p_rule_obj_id          IN NUMBER
    ,p_table_name          IN VARCHAR2
    ,p_cal_period_id       IN NUMBER
    ,p_effective_date      IN VARCHAR2
    ,p_dataset_code        IN NUMBER
    ,p_ledger_id           IN NUMBER
    ,p_source_system_code  IN NUMBER
    ,p_total_customers     IN NUMBER
    ,p_cust_wo_rgn_code    IN NUMBER
    ,p_customer_level      IN NUMBER
    ,p_value_set_id        IN NUMBER
    ,p_ds_where_clause     IN LONG)
   RETURN LONG;

/*======--=====================================================================+
 | PROCEDURE
 |   PROCESS SINGLE RULE
 |
 | DESCRIPTION
 |   Main engine procedure for region counting step in profit calculation in PFT.
 |
 | SCOPE - PUBLIC
 |
 +============================================================================*/

   PROCEDURE Process_Single_Rule ( p_rule_obj_id            IN  NUMBER
                                  ,p_cal_period_id          IN  NUMBER
                                  ,p_dataset_io_obj_def_id  IN  NUMBER
                                  ,p_output_dataset_code    IN  NUMBER
                                  ,p_effective_date         IN  VARCHAR2
                                  ,p_ledger_id              IN  NUMBER
                                  ,p_source_system_code     IN  NUMBER
                                  ,p_customer_level         IN  NUMBER
                                  ,p_exec_state             IN  VARCHAR2
                                  ,x_return_status          OUT NOCOPY VARCHAR2)
   IS

   l_api_name      CONSTANT     VARCHAR2(30)  := 'Process_Single_Rule';

   l_process_table              VARCHAR2(30) := 'FEM_CUSTOMERS_ATTR';
   l_table_alias                VARCHAR2(5)  := 'FCA';
   l_effective_date             DATE;
   l_dimension_grp_id           NUMBER;
   l_ds_where_clause            LONG := NULL;
   l_gvsc_id                    NUMBER;
   l_value_set_id               NUMBER;
   l_dim_grp_id                 NUMBER;
   l_attribute_id               NUMBER;
   l_num_rows_loaded            NUMBER := 0;
   l_err_code                   NUMBER := 0;
   l_num_msg                    NUMBER := 0;
   l_bulk_sql                   LONG;
   l_bulk_sql1                  LONG;
   l_err_msg                    VARCHAR2(255);
   l_reuse_slices               VARCHAR2(10);
   l_msg_count                  NUMBER;
   l_exception_code             VARCHAR2(50);
   l_msg_data                   VARCHAR2(200);
   l_return_status              VARCHAR2(50)  :=  NULL;
   l_total_customers            NUMBER;
   l_region_code                NUMBER;
   l_object_def_id              NUMBER;
   l_cust_wo_rgn_code           NUMBER;
   l_request_id                 NUMBER := FND_GLOBAL.Conc_Request_Id;
   l_user_id                    NUMBER := FND_GLOBAL.User_Id;
   l_login_id                   NUMBER := FND_GLOBAL.Login_Id;

   TYPE v_msg_list_type        IS VARRAY(20) OF
                               fem_mp_process_ctl_t.message%TYPE;
   v_msg_list                  v_msg_list_type;

   e_process_single_rule_error  EXCEPTION;
   e_register_rule_error        EXCEPTION;

   BEGIN
      -- Initialize the return status to SUCCESS
      x_return_status  := FND_API.G_RET_STS_SUCCESS;

      l_effective_date := FND_DATE.Canonical_To_Date(p_effective_date);

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_2
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Get The Level for which the
	                    Region Counting has to be performed');

      BEGIN
         SELECT  relative_dimension_group_seq
           INTO  l_dimension_grp_id
         FROM    fem_hier_dimension_grps
         WHERE   dimension_group_id = p_customer_level
           AND   ROWNUM = 1;

      EXCEPTION
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
         FROM   fem_global_vs_combo_defs gvsc,fem_dimensions_b dim
         WHERE  gvsc.dimension_id = dim.dimension_id
           AND  dim.dimension_varchar_label = 'CUSTOMER'
           AND  gvsc.global_vs_combo_id = l_gvsc_id;
      EXCEPTION
         WHEN no_data_found THEN
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

      -- Get the total no of customers at the given level
      SELECT COUNT(*)
        INTO l_total_customers
      FROM   fem_customers_b
      WHERE  value_set_id = l_value_set_id
        AND  dimension_group_id = p_customer_level;

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_3
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Generating the dataset where clause');

      FEM_DS_WHERE_CLAUSE_GENERATOR.Fem_Gen_DS_WClause_Pvt(
         p_api_version      => G_CALLING_API_VERSION
        ,p_init_msg_list    => FND_API.G_TRUE
        ,p_encoded          => FND_API.G_TRUE
        ,p_ds_io_def_id     => p_dataset_io_obj_def_id
        ,p_output_period_id => p_cal_period_id
        ,p_table_alias      => l_process_table
        ,p_table_name       => l_table_alias
        ,p_ledger_id        => p_ledger_id
        ,p_where_clause     => l_ds_where_clause
        ,x_return_status    => l_return_status
        ,x_msg_count        => l_msg_count
        ,x_msg_data         => l_msg_data);

      IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);

         FEM_ENGINES_PKG.User_Message (
            p_app_name => G_PFT
           ,p_msg_name => G_ENG_DS_WHERE_CLAUSE_ERR
           ,p_token1   => 'OUTPUT_DS_CODE'
           ,p_value1   => p_dataset_io_obj_def_id
           ,p_token2   => 'CAL_PERIOD_ID'
           ,p_value2   => p_cal_period_id);

         IF (l_ds_where_clause IS NULL) THEN
            FEM_ENGINES_PKG.User_Message (
               p_app_name => G_PFT
              ,p_msg_name => G_ENG_DS_WHERE_CLAUSE_ERR
              ,p_token1   => 'OUTPUT_DS_CODE'
              ,p_value1   => p_dataset_io_obj_def_id
              ,p_token2   => 'CAL_PERIOD_ID'
              ,p_value2   => p_cal_period_id);
         END IF;
         RAISE e_process_single_rule_error;

      END IF;

      -- CHECKPOINT RESTART
      -- check executed state and jump to appropriate statement
      -- depending on which step was last executed successfully
      IF(p_exec_state = 'RESTART') THEN
         l_reuse_slices := 'Y';
      ELSE
         l_reuse_slices := 'N';
      END IF;

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_3
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Getting the region code attribute id');

      -- Get the attribute id for the region code attribute
      SELECT dim_attr.attribute_id
        INTO l_attribute_id
      FROM   fem_dim_attributes_b dim_attr,fem_dimensions_b xdim
      WHERE dim_attr.dimension_id = xdim.dimension_id
        AND dim_attr.attribute_varchar_label = 'REGION_CODE'
        AND xdim.dimension_varchar_label = 'CUSTOMER';

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_3
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Get the total no. of customers who doesnt have a region code in the given level');

      -- Get all the customers in the level for whom region code is not assigned
      SELECT COUNT(customer_id)
        INTO l_cust_wo_rgn_code
      FROM   fem_customers_b
      WHERE dimension_group_id = p_customer_level
        AND value_set_id =  l_value_set_id
        AND customer_id NOT IN(SELECT customer_id
                               FROM   fem_customers_attr
                               WHERE attribute_id = l_attribute_id);

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_3
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Check whether region counting is already done for the given level and parameters');

      -- Region Counting has to be done only once for a level
      SELECT COUNT( dimension_group_id )
        INTO l_dim_grp_id
      FROM   fem_region_info
      WHERE  dimension_group_id = p_customer_level
        AND  ledger_id = p_ledger_id
        AND  cal_period_id = p_cal_period_id
        AND  dataset_code = p_output_dataset_code;

      IF l_dim_grp_id = 0 THEN
         -- To create the INSERT statement for the customers with region code.
         l_bulk_sql := Create_Region_Count_Stmt(
                             p_rule_obj_id        =>  p_rule_obj_id
                            ,p_table_name         =>  l_process_table
                            ,p_cal_period_id      =>  p_cal_period_id
                            ,p_effective_date     =>  p_effective_date
                            ,p_dataset_code       =>  p_output_dataset_code
                            ,p_ledger_id          =>  p_ledger_id
                            ,p_source_system_code =>  p_source_system_code
                            ,p_total_customers    =>  l_total_customers
                            ,p_customer_level     =>  p_customer_level
                            ,p_value_set_id       =>  l_value_set_id
                            ,p_ds_where_clause    =>  l_ds_where_clause);

         IF l_cust_wo_rgn_code <> 0 THEN
            -- To create the INSERT statement for the customers with out region code
            l_bulk_sql1 := Create_Rgn_Cnt_Wo_RCode_Stmt(
                             p_rule_obj_id        =>  p_rule_obj_id
                            ,p_table_name         =>  l_process_table
                            ,p_cal_period_id      =>  p_cal_period_id
                            ,p_effective_date     =>  p_effective_date
                            ,p_dataset_code       =>  p_output_dataset_code
                            ,p_ledger_id          =>  p_ledger_id
                            ,p_source_system_code =>  p_source_system_code
                            ,p_total_customers    =>  l_total_customers
                            ,p_cust_wo_rgn_code   =>  l_cust_wo_rgn_code
                            ,p_customer_level     =>  p_customer_level
                            ,p_value_set_id       =>  l_value_set_id
                            ,p_ds_where_clause    =>  l_ds_where_clause);
         END IF;

         -- Perform region counting for the customers for whom Region code is
         -- assigned
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_3
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Perform Region Counting for the region code assigned customers');

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_3
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'SQL:' ||l_bulk_sql );

         BEGIN
            EXECUTE IMMEDIATE l_bulk_sql;

         EXCEPTION
            WHEN OTHERS THEN
               fnd_file.put_line(fnd_file.log,'Error = ' || SQLERRM);

               Process_Obj_Exec_Step(
                  p_request_id      => l_request_id
                 ,p_user_id         => l_user_id
                 ,p_login_id        => l_login_id
                 ,p_rule_obj_id     => p_rule_obj_id
                 ,p_exe_step        => 'RGN_CNT'
                 ,p_exe_status_code => g_exec_status_error_rerun
                 ,p_tbl_name        => 'FEM_REGION_INFO'
                 ,p_num_rows        => l_num_rows_loaded);

            RAISE e_process_single_rule_error;
         END;

         l_num_rows_loaded := SQL%ROWCOUNT;

         IF l_cust_wo_rgn_code <> 0 THEN
            -- Perform region counting for the customers for whom Region code is
   	      -- not assigned(NULL)
            FEM_ENGINES_PKG.Tech_Message (
               p_severity  => g_log_level_3
              ,p_module    => G_BLOCK||'.'||l_api_name
              ,p_msg_text  => 'Perform Region Counting for the customers region code is null');

            FEM_ENGINES_PKG.Tech_Message (
               p_severity  => g_log_level_3
              ,p_module    => G_BLOCK||'.'||l_api_name
              ,p_msg_text  => 'SQL:' ||l_bulk_sql1 );
            BEGIN
               EXECUTE IMMEDIATE l_bulk_sql1;

            EXCEPTION
               WHEN OTHERS THEN
                  fnd_file.put_line(fnd_file.log,'Error = ' || SQLERRM);

                  Process_Obj_Exec_Step(
                     p_request_id      => l_request_id
                    ,p_user_id         => l_user_id
                    ,p_login_id        => l_login_id
                    ,p_rule_obj_id     => p_rule_obj_id
                    ,p_exe_step        => 'RGN_CNT'
                    ,p_exe_status_code => g_exec_status_error_rerun
                    ,p_tbl_name        => 'FEM_REGION_INFO'
                    ,p_num_rows        => l_num_rows_loaded);

               RAISE e_process_single_rule_error;
            END;

            l_num_rows_loaded := l_num_rows_loaded+SQL%ROWCOUNT;
         END IF;

         l_num_rows_loaded := NVL(l_num_rows_loaded,0);

         Process_Obj_Exec_Step( p_request_id      => l_request_id
                               ,p_user_id         => l_user_id
                               ,p_login_id        => l_login_id
                               ,p_rule_obj_id     => p_rule_obj_id
                               ,p_exe_step        => 'RGN_CNT'
                               ,p_exe_status_code => g_exec_status_success
                               ,p_tbl_name        => 'FEM_REGION_INFO'
                               ,p_num_rows        => l_num_rows_loaded);
         -- commit the work
         COMMIT;

      ELSE
         FEM_ENGINES_PKG.Tech_Message (
           p_severity => G_LOG_LEVEL_2
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Region Counting is already performed for this Level');
      END IF;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');

   EXCEPTION
      WHEN e_process_single_rule_error THEN

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Generate Region Counting Error:
                            Process Single Rule Exception');

         FEM_ENGINES_PKG.User_Message (p_app_name  => G_PFT
                                      ,p_msg_name  => G_ENG_SINGLE_RULE_ERR);

         x_return_status  := FND_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Generate Region Counting Error:
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
   PROCEDURE Update_Nbr_Of_Output_Rows( p_request_id       IN  NUMBER
                                       ,p_user_id          IN  NUMBER
                                       ,p_login_id         IN  NUMBER
                                       ,p_rule_obj_id      IN  NUMBER
                                       ,p_num_output_rows  IN  NUMBER
                                       ,p_tbl_name         IN  VARCHAR2
                                       ,p_stmt_type        IN  VARCHAR2)
   IS

   l_api_name         CONSTANT     VARCHAR2(30) := 'Update_Num_Of_Output_Rows';

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

      RAISE e_process_single_rule_error;

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
      FEM_PL_PKG.Update_Obj_Exec_Step_Status(
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
           ,p_msg_text  => 'No Rows returned by the Insert Statement');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_RCNT_NO_OP_ROWS_ERR);

         RAISE e_process_single_rule_error;
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
                                   ,p_tbl_name        IN VARCHAR2
                                   ,p_num_rows        IN NUMBER)
   IS
   l_api_name           VARCHAR2(30);

   BEGIN
      l_api_name           := 'Process_Obj_Exec_Step';

      FEM_ENGINES_PKG.Tech_Message( p_severity => g_log_level_2
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

      --update the status of the step
      Update_Obj_Exec_Step_Status( p_request_id      =>  p_request_id
                                  ,p_user_id         =>  p_user_id
                                  ,p_login_id        =>  p_login_id
                                  ,p_rule_obj_id     =>  p_rule_obj_id
                                  ,p_exe_step        =>  'RGN_CNT'
                                  ,p_exe_status_code =>  p_exe_status_code );

      IF (p_exe_status_code = g_exec_status_success) THEN
 /*        -- query table fem_mp_process_ctl_t to get the number of rows processed
         Get_Nbr_RowsTable_Request(x_rows_processed => l_nbr_output_rows,
                                   x_rows_loaded    => l_nbr_loaded_rows,
                                   x_rows_rejected  => l_nbr_rejected_rows,
                                   p_request_id     => p_request_id);*/

         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Rows processed for registered output table :'
                          ||p_tbl_name);

         -- update the number of rows processed in the registered table
         Update_Nbr_Of_Output_Rows(
               p_request_id       =>  p_request_id
              ,p_user_id          =>  p_user_id
              ,p_login_id         =>  p_login_id
              ,p_rule_obj_id      =>  p_rule_obj_id
              ,p_num_output_rows  =>  p_num_rows
              ,p_tbl_name         =>  g_fem_region_info
              ,p_stmt_type        =>  g_insert );

         -----------------------------------------------------------------------
         -- Call FEM_PL_PKG.update_num_of_input_rows();
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_1,
            p_module   => G_BLOCK||'.'||l_api_name,
            p_msg_text => 'No:of Rows processed from input table'
                          ||p_num_rows );

         -- update the number of rows processed in the registered table
         Update_Nbr_Of_Input_Rows(
             p_request_id        =>  p_request_id
            ,p_user_id           =>  p_user_id
            ,p_last_update_login =>  p_login_id
            ,p_rule_obj_id       =>  p_rule_obj_id
            ,p_num_of_input_rows =>  p_num_rows);

         FEM_ENGINES_PKG.User_Message(p_app_name => G_PFT,
                                      p_msg_name => 'PFT_PPROF_RCNT_ROW_SUMMARY',
                                      p_token1   => 'ROWSP',
                                      p_value1   => p_num_rows,
                                      p_token2   => 'ROWSL',
                                      p_value2   => p_num_rows);
      END IF;

      FEM_ENGINES_PKG.Tech_Message( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'END');

   EXCEPTION
      WHEN OTHERS THEN
      RAISE e_process_single_rule_error;

   END;

 /*============================================================================+
 | FUNCTION
 |   Create Region Count Statement
 |
 | DESCRIPTION
 |   Creates the Bulk SQL for Region Counting step for the customers who have
 | region code attribute defined
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   FUNCTION Create_Region_Count_Stmt ( p_rule_obj_id            IN NUMBER,
                                       p_table_name             IN VARCHAR2,
                                       p_cal_period_id          IN NUMBER,
                                       p_effective_date         IN VARCHAR2,
                                       p_dataset_code           IN NUMBER,
                                       p_ledger_id              IN NUMBER,
                                       p_source_system_code     IN NUMBER,
                                       p_total_customers        IN NUMBER,
                                       p_customer_level         IN NUMBER,
                                       p_value_set_id           IN NUMBER,
                                       p_ds_where_clause        IN LONG)
   RETURN LONG IS

   l_api_name       CONSTANT    VARCHAR2(30) := 'Create_Region_Count_Stmt';

   l_insert_head_stmt           LONG;
   l_select_stmt                LONG;
   l_from_stmt                  LONG;
   l_where_stmt                 LONG;
   l_group_by_stmt              VARCHAR2(100);
   l_rel_dimension_grp_seq      NUMBER;
   l_request_id                 NUMBER;
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(500);
   l_return_status              VARCHAR2(20);
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

      l_insert_head_stmt := ' INSERT INTO FEM_REGION_INFO ( ' ||
                            ' CAL_PERIOD_ID, ' ||
                            ' DATASET_CODE, ' ||
                            ' DIMENSION_GROUP_ID, ' ||
                            ' SOURCE_SYSTEM_CODE, ' ||
                            ' REGION_CODE, ' ||
                            ' LEDGER_ID, ' ||
                            ' REGION_PCT_TOTAL_CUST, ' ||
                            ' NUMBER_OF_CUSTOMERS, ' ||
                            ' CREATED_BY_OBJECT_ID, ' ||
                            ' CREATED_BY_REQUEST_ID, ' ||
                            ' LAST_UPDATED_BY_OBJECT_ID, ' ||
                            ' LAST_UPDATED_BY_REQUEST_ID ';

      l_select_stmt :=      ' ) SELECT '||
                            p_cal_period_id || ' , ' ||
                            p_dataset_code || ' , ' ||
                            p_customer_level || ' , ' ||
                            p_source_system_code || ' , ' ||
                            'fca.number_assign_value, ' ||
                            p_ledger_id || ' , ' ||
                            ' 100 * (COUNT(fca.number_assign_value)/'
			    || p_total_customers || ') , ' ||
                            'COUNT(fca.number_assign_value)' || ' , ' ||
                            p_rule_obj_id || ' , ' ||
                            l_request_id || ' , ' ||
                            l_user_id ||' , ' ||
                            l_request_id;

      l_from_stmt :=        ' FROM ' ||
                            ' FEM_CUSTOMERS_ATTR fca , ' ||
                            ' (' || ' SELECT dim_attr.attribute_id ' ||
                            ' FROM   fem_dim_attributes_b dim_attr, ' ||
                            ' fem_dimensions_b xdim ' ||
                            ' WHERE dim_attr.dimension_id = xdim.dimension_id'||
                            ' AND dim_attr.attribute_varchar_label = ' ||
                            '''REGION_CODE''' ||
                            ' AND xdim.dimension_varchar_label = ''CUSTOMER'''||
                            ' )' || 'T1 ';
      l_where_stmt :=       ' WHERE ' ||
                            ' fca.attribute_id = T1.attribute_id ' ||
                            ' AND fca.customer_id IN ( ' ||
                            ' SELECT customer_id ' ||
                            ' FROM fem_customers_b ' ||
                            ' WHERE dimension_group_id = ' ||
                            p_customer_level ||
                            ' AND value_set_id = ' ||
                            p_value_set_id || ' ) ';

      l_group_by_stmt := ' GROUP BY ' ||
                         ' fca.number_assign_value ';

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');
      -- add mapped columns
      RETURN l_insert_head_stmt || ' ' || l_select_stmt || ' ' || l_from_stmt
             || ' ' || l_where_stmt || ' ' || l_group_by_stmt;

      EXCEPTION
        WHEN OTHERS THEN
        RAISE;

   END Create_Region_Count_Stmt;

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

            FEM_ENGINES_PKG.Tech_Message (
               p_severity => g_log_level_2
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'msg_data = '||l_message);

         END LOOP;

      END IF;

      FND_MSG_PUB.Initialize;

   END Get_Put_Messages;

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

   l_api_name     CONSTANT      VARCHAR2(30) := 'Update_Num_Of_Input_Rows';

   l_return_status              VARCHAR2(2);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(240);

   e_upd_num_input_rows_error   EXCEPTION;

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

 /*============================================================================+
 | FUNCTION
 |   Create Region Count Statement
 |
 | DESCRIPTION
 |   Creates the Bulk SQL for Region Counting step for the customers who doesn't
 | have region code attribute defined
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   FUNCTION Create_Rgn_Cnt_Wo_RCode_Stmt ( p_rule_obj_id         IN NUMBER,
                                           p_table_name          IN VARCHAR2,
                                           p_cal_period_id       IN NUMBER,
                                           p_effective_date      IN VARCHAR2,
                                           p_dataset_code        IN NUMBER,
                                           p_ledger_id           IN NUMBER,
                                           p_source_system_code  IN NUMBER,
                                           p_total_customers     IN NUMBER,
                                           p_cust_wo_rgn_code    IN NUMBER,
                                           p_customer_level      IN NUMBER,
                                           p_value_set_id        IN NUMBER,
                                           p_ds_where_clause     IN LONG)
   RETURN LONG IS

   l_api_name       CONSTANT    VARCHAR2(30) := 'Create_Region_Count_Stmt';

   l_insert_head_stmt           LONG;
   l_select_stmt                LONG;
   l_from_stmt                  LONG;
   l_where_stmt                 LONG;
   l_group_by_stmt              VARCHAR2(100);
   l_rel_dimension_grp_seq      NUMBER;
   l_request_id                 NUMBER;
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(500);
   l_return_status              VARCHAR2(20);
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

      l_insert_head_stmt := ' INSERT INTO FEM_REGION_INFO ( ' ||
                            ' CAL_PERIOD_ID, ' ||
                            ' DATASET_CODE, ' ||
                            ' DIMENSION_GROUP_ID, ' ||
                            ' SOURCE_SYSTEM_CODE, ' ||
                            ' REGION_CODE, ' ||
                            ' LEDGER_ID, ' ||
                            ' REGION_PCT_TOTAL_CUST, ' ||
                            ' NUMBER_OF_CUSTOMERS, ' ||
                            ' CREATED_BY_OBJECT_ID, ' ||
                            ' CREATED_BY_REQUEST_ID, ' ||
                            ' LAST_UPDATED_BY_OBJECT_ID, ' ||
                            ' LAST_UPDATED_BY_REQUEST_ID ';

      l_select_stmt :=      ' ) SELECT '||
                            p_cal_period_id || ' , ' ||
                            p_dataset_code || ' , ' ||
                            p_customer_level || ' , ' ||
                            p_source_system_code || ' , ' ||
                            ' NULL, ' ||
                            p_ledger_id || ' , ' ||
                            ' 100 * (' ||p_cust_wo_rgn_code || '/'
			    || p_total_customers || ') , ' ||
                            p_cust_wo_rgn_code || ' , ' ||
                            p_rule_obj_id || ' , ' ||
                            l_request_id || ' , ' ||
                            l_user_id ||' , ' ||
                            l_request_id;

      l_from_stmt :=        ' FROM ' ||
                            ' DUAL';

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');
      -- add mapped columns
      RETURN l_insert_head_stmt || ' ' || l_select_stmt || ' ' || l_from_stmt;


      EXCEPTION
        WHEN OTHERS THEN
        RAISE;

   END Create_Rgn_Cnt_Wo_RCode_Stmt;



 END PFT_PROFCAL_RGNCNT_PUB;

/
