--------------------------------------------------------
--  DDL for Package FEM_GL_POST_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_GL_POST_PROCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_gl_post_proc.pls 120.3 2006/04/26 17:24:48 ghall ship $ */

----------------------------
-- Public Package Variables
----------------------------

   pv_sqlerrm                 VARCHAR2(512);
   pv_callstack               VARCHAR2(2000);

-- Populated from engine parameters by Validate_XGL_Eng_Parameters
-- or by Validate_OGL_Eng_Parameters

   pv_ledger_id               fem_ledgers_b.ledger_id%TYPE;
   pv_cal_period_id           fem_cal_periods_b.cal_period_id%TYPE;
   pv_dataset_code            fem_datasets_b.dataset_code%TYPE;
   pv_rule_obj_def_id         fem_object_definition_b.object_definition_id%TYPE;
   pv_exec_mode               VARCHAR2(30);
   pv_qtd_ytd_code            VARCHAR2(30);
   pv_budget_id               fem_budgets_b.budget_id%TYPE;
   pv_enc_type_id             fem_encumbrance_types_b.encumbrance_type_id%TYPE;

-- Populated by Get_Dim_IDs (called from Validate_Engine_Parameters)

   pv_cal_per_dim_id          fem_dimensions_b.dimension_id%TYPE;
   pv_ledger_dim_id           fem_dimensions_b.dimension_id%TYPE;
   pv_dataset_dim_id          fem_dimensions_b.dimension_id%TYPE;
   pv_budget_dim_id           fem_dimensions_b.dimension_id%TYPE;
   pv_enc_type_dim_id         fem_dimensions_b.dimension_id%TYPE;

   -- Added for FEM-OGL Integration Project
   pv_ext_acct_type_dim_id    fem_dimensions_b.dimension_id%TYPE;
   pv_nat_acct_dim_id         fem_dimensions_b.dimension_id%TYPE;

-- Populated by Validate_Engine_Parameters

   pv_req_id                  NUMBER;
   pv_user_id                 NUMBER(15);
   pv_login_id                NUMBER(15);
   pv_pgm_id                  NUMBER(15);
   pv_pgm_app_id              NUMBER(15);

   pv_rule_obj_id             fem_object_definition_b.object_id%TYPE;

   pv_cal_per_dim_grp_dsp_cd  fem_dimension_grps_b.dimension_group_display_code%TYPE;
   pv_cal_per_end_date        fem_cal_periods_attr.date_assign_value%TYPE;
   pv_gl_per_number           fem_cal_periods_attr.number_assign_value%TYPE;

   pv_ledger_dsp_cd                fem_ledgers_b.ledger_display_code%TYPE;
   pv_ledger_per_hier_obj_id       fem_object_catalog_b.object_id%TYPE;
   pv_ledger_per_hier_obj_def_id   fem_ledgers_attr.number_assign_value%TYPE;

   pv_ds_balance_type_cd      fem_datasets_attr.dim_attribute_varchar_member%TYPE;
   pv_budget_dsp_cd           fem_budgets_b.budget_display_code%TYPE;
   pv_enc_type_dsp_cd         fem_encumbrance_types_b.encumbrance_type_code%TYPE;
   pv_entered_crncy_flag      fem_flags_vl.flag_code%TYPE;

-- Populated by Validate_OGL_Eng_Parameters (Added for FEM-OGL Integration Project)
--   pv_signage_method          VARCHAR2(30);
   pv_adv_li_fe_mappings_flag VARCHAR2(1);
   pv_global_vs_combo_id      FEM_GLOBAL_VS_COMBOS_B.GLOBAL_VS_COMBO_ID%TYPE;
   pv_max_delta_run_id        NUMBER(15);
   pv_gl_source_system_code   FEM_SOURCE_SYSTEMS_B.SOURCE_SYSTEM_CODE%TYPE;

   pv_rule_obj_def_name   FEM_OBJECT_DEFINITION_TL.DISPLAY_NAME%TYPE;
   pv_ledger_name         GL_SETS_OF_BOOKS.NAME%TYPE;
   pv_coa_id              FEM_INTG_BAL_RULES.CHART_OF_ACCOUNTS_ID%TYPE;
   pv_coa_name            FND_ID_FLEX_STRUCTURES_TL.ID_FLEX_STRUCTURE_NAME%TYPE;
   pv_include_avg_bal     FEM_INTG_BAL_RULES.INCLUDE_AVG_BAL_FLAG%TYPE;
   pv_bsv_app_col_name    FEM_INTG_BAL_RULES.BAL_SEG_COLUMN_NAME%TYPE;
   pv_maintain_qtd_flag   FEM_INTG_BAL_RULES.MAINTAIN_QTD_FLAG%TYPE;

   pv_bsv_option          FEM_INTG_BAL_RULE_DEFS.BAL_SEG_VALUE_OPTION_CODE%TYPE;
   pv_curr_option         FEM_INTG_BAL_RULE_DEFS.CURRENCY_OPTION_CODE%TYPE;
   pv_xlated_bal_option   FEM_INTG_BAL_RULE_DEFS.XLATED_BAL_OPTION_CODE%TYPE;

   pv_rule_eff_start_date FEM_OBJECT_DEFINITION_B.EFFECTIVE_START_DATE%TYPE;
   pv_rule_eff_end_date   FEM_OBJECT_DEFINITION_B.EFFECTIVE_START_DATE%TYPE;

   pv_from_date                DATE;
   pv_to_date                  DATE;
   pv_from_period_eff_num      NUMBER(15);
   pv_to_period_eff_num	       NUMBER(15);
   pv_min_valid_period_eff_num NUMBER(15);
   pv_max_valid_period_eff_num NUMBER(15);


-- Bug 4394404 hkaniven start - package variables to store the no of rows and the no
-- of valid rows, in the FEM_INTG_EXEC_PARAMS_GT
   pv_num_rows                 NUMBER;
   pv_num_rows_valid           NUMBER;
-- Bug 4394404 hkaniven end - package variables to store the no of rows and the no
-- of valid rows, in the FEM_INTG_EXEC_PARAMS_GT

-- Populated by Get_Proc_Key_Info (called from Validate_Engine_Parameters)

   TYPE xdim_info IS RECORD
     (dimension_id               NUMBER,
      dim_vs_id                  NUMBER,
      dim_vsr_flag               VARCHAR2(1),
      dim_col_name               VARCHAR2(30),
      dim_member_b_table_name    VARCHAR2(30),
      dim_member_col             VARCHAR2(30),
      dim_member_disp_code_col   VARCHAR2(30),
      dim_int_disp_code_col      VARCHAR2(30),
      dim_attr_table_name        VARCHAR2(30));

   TYPE proc_key_list IS VARRAY(50) OF xdim_info;

   pv_proc_keys               proc_key_list := proc_key_list();

   pv_proc_key_dim_num        NUMBER;

-- Populated by Main for Get_SSC

   pv_ssc_where               VARCHAR2(1100);

-- Populated by Get_SSC

   TYPE src_sys_dsp_cd_rec IS RECORD
       (display_code   fem_source_systems_b.source_system_display_code%TYPE,
        row_count      NUMBER);

   TYPE src_sys_dsp_cd_list IS TABLE OF src_sys_dsp_cd_rec
                            INDEX BY PLS_INTEGER;

   pv_ssc_tbp          src_sys_dsp_cd_list;
   pv_ssc_np           src_sys_dsp_cd_list;

-- Populated by Register_Process_Execution

   pv_exec_state       VARCHAR2(30); -- NORMAL, RESTART, RERUN
   pv_prev_req_id      NUMBER;

-- Added for FEM-OGL Integration Project
   pv_stmt_type          FEM_PL_TABLES.STATEMENT_TYPE%TYPE;
   pv_from_gl_bal_flag   VARCHAR2(1);
   pv_from_gl_delta_flag VARCHAR2(1);
   pv_func_ccy_code      FND_CURRENCIES.CURRENCY_CODE%TYPE;

---------------------
-- Public Procedures
---------------------

   PROCEDURE Get_Proc_Key_Info
                (p_process_slice           IN  VARCHAR2,
                 x_completion_code         OUT NOCOPY NUMBER);

   PROCEDURE Get_SSC
                (p_dest_code               IN  VARCHAR2);

   PROCEDURE Final_Process_Logging
                (p_exec_status             IN  VARCHAR2,
                 p_num_data_errors         IN  NUMBER,
                 p_num_data_errors_reproc  IN  NUMBER,
                 p_num_output_rows         IN  NUMBER,
                 p_final_message_name      IN  VARCHAR2);

   PROCEDURE Register_Process_Execution
                (x_completion_code         OUT NOCOPY NUMBER);


   PROCEDURE Validate_XGL_Eng_Parameters
                (p_ledger_id               IN  NUMBER,
                 p_cal_period_id           IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 p_xgl_obj_def_id          IN  NUMBER,
                 p_exec_mode               IN  VARCHAR2,
-- Updated by L Poon to fix the GSCC warning - File.Sql.35
                 p_qtd_ytd_code            IN  VARCHAR2 DEFAULT NULL,
                 p_budget_id               IN  NUMBER DEFAULT NULL,
                 p_enc_type_id             IN  NUMBER DEFAULT NULL,
                 x_completion_code         OUT NOCOPY NUMBER);

   PROCEDURE Undo_XGL_Interface_Error_Rows
                (p_request_id              IN  NUMBER,
                 x_return_status           OUT NOCOPY VARCHAR2,
                 x_msg_data                OUT NOCOPY VARCHAR2,
                 x_msg_count               OUT NOCOPY NUMBER);

   -- Added for FEM-OGL Integration Project
   PROCEDURE Validate_OGL_Eng_Parameters
                (p_bal_rule_obj_def_id     IN            NUMBER,
                 p_from_period             IN            VARCHAR2,
                 p_to_period               IN            VARCHAR2,
                 p_effective_date          IN OUT NOCOPY DATE,
                 p_bsv_range_low           IN            VARCHAR2,
                 p_bsv_range_high          IN            VARCHAR2,
                 x_generate_report_flag    OUT    NOCOPY VARCHAR2,
                 x_completion_code         OUT    NOCOPY NUMBER);

   -- Added for FEM-OGL Integration Project
   PROCEDURE Register_OGL_Process_Execution
                (x_completion_code         OUT    NOCOPY NUMBER);

   -- Added for FEM-OGL Integration Project
   PROCEDURE Final_OGL_Process_Logging
                (p_exec_status             IN     VARCHAR2,
                 p_final_message_name      IN     VARCHAR2);

END FEM_GL_POST_PROCESS_PKG;

 

/
