--------------------------------------------------------
--  DDL for Package Body FEM_DATAX_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DATAX_LOADER_PKG" AS
-- $Header: fem_data_loader.plb 120.2 2005/08/23 12:13:04 appldev ship $

----------------------------------------------------
-- Dev Modes: 'D'=development 'P'=production
----------------------------------------------------
c_dev_mode     CONSTANT  VARCHAR2(2) := 'P';

-----------------------
-- Package Constants --
-----------------------
c_fetch_limit  CONSTANT  NUMBER  := 10000; -- default

c_user_id      CONSTANT  NUMBER := FND_GLOBAL.User_ID;
c_login_id     CONSTANT  NUMBER := FND_GLOBAL.Login_ID;
c_conc_prg_id  CONSTANT  NUMBER := FND_GLOBAL.Conc_Program_ID;
c_prg_app_id   CONSTANT  NUMBER := FND_GLOBAL.Prog_Appl_ID;

c_fem_schema   CONSTANT  VARCHAR2(3) := 'FEM';

c_false        CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true         CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
c_success      CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
c_error        CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
c_unexp        CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
c_api_version  CONSTANT  NUMBER       := 1.0;

c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

---------------------
-- Package Globals --
---------------------
g_rows_processed         NUMBER;
g_rows_loaded            NUMBER;
g_rows_rejected          NUMBER;
g_exec_status            VARCHAR2(80);
g_upd_pl_on_err          VARCHAR2(1) := 'N';

f_set_status             BOOLEAN;
g_req_id                 NUMBER;
g_obj_def_id             NUMBER;
g_table_name             VARCHAR2(30);
g_ledger_id              NUMBER;
g_dataset_cd             NUMBER;
g_cal_per_id             NUMBER;
g_source_cd              NUMBER;
g_exec_mode              VARCHAR2(1);

g_object_id              NUMBER;
g_data_table             VARCHAR2(30);
g_data_t_table           VARCHAR2(30);
g_gvc_id                 NUMBER;

g_cctr_org_sql           VARCHAR2(4196);
g_fin_elem_sql           VARCHAR2(4196);
g_product_sql            VARCHAR2(4196);
g_nat_acct_sql           VARCHAR2(4196);
g_channel_sql            VARCHAR2(4196);
g_line_item_sql          VARCHAR2(4196);
g_project_sql            VARCHAR2(4196);
g_customer_sql           VARCHAR2(4196);
g_entity_sql             VARCHAR2(4196);
g_geography_sql          VARCHAR2(4196);
g_task_sql               VARCHAR2(4196);
g_interco_sql            VARCHAR2(4196);
g_user_dim1_sql          VARCHAR2(4196);
g_user_dim2_sql          VARCHAR2(4196);
g_user_dim3_sql          VARCHAR2(4196);
g_user_dim4_sql          VARCHAR2(4196);
g_user_dim5_sql          VARCHAR2(4196);
g_user_dim6_sql          VARCHAR2(4196);
g_user_dim7_sql          VARCHAR2(4196);
g_user_dim8_sql          VARCHAR2(4196);
g_user_dim9_sql          VARCHAR2(4196);
g_user_dim10_sql         VARCHAR2(4196);

g_condition              VARCHAR2(4196);
g_select_stmt            VARCHAR2(32767);

g_phase_stat             VARCHAR2(80);
g_message                VARCHAR2(4196);

g_msg_no                 NUMBER;

g_block                  VARCHAR2(30);

------------------------
-- Package Exceptions --
------------------------
e_validation_error       EXCEPTION;
e_process_lock_error     EXCEPTION;

/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                           =================                             *
 *                                 Master                                  *
 *                           =================                             *
 *                                                                         *
 ***************************************************************************
 **************************************************************************/

PROCEDURE Master (
   errbuf          OUT NOCOPY VARCHAR2,
   retcode         OUT NOCOPY VARCHAR2,
   p_exec_mode     IN         VARCHAR2,
   p_obj_def_id    IN         NUMBER,
   p_ledger_id     IN         NUMBER,
   p_dataset_cd    IN         NUMBER,
   p_source_cd     IN         NUMBER,
   p_cal_per_id    IN         NUMBER
)
IS

---------------------
-- Local Variables --
---------------------
v_prg_stat         VARCHAR2(80);
v_exception_code   VARCHAR2(80);
v_status           NUMBER;
v_message          VARCHAR2(4000);

v_block  CONSTANT  VARCHAR2(80) :=
   'fem.plsql.fem_datax_loader_pkg.master';

---------------------
-- Execution Block --
---------------------
BEGIN

g_block := 'Master';

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.Begin{100}',
  p_msg_text => 'Begin FEM_DATAX_LOADER.Master');

g_req_id := FND_GLOBAL.Conc_Request_ID;
g_obj_def_id := p_obj_def_id;
g_table_name := null;  -- := p_table_name (future use)
g_ledger_id  := p_ledger_id;
g_dataset_cd := p_dataset_cd;
g_cal_per_id := p_cal_per_id;
g_source_cd  := p_source_cd;
g_exec_mode  := p_exec_mode;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_req_id{101}',
  p_msg_text => g_req_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.c_user_id{102}',
  p_msg_text => c_user_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_obj_def_id{103}',
  p_msg_text => g_obj_def_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_ledger_id{104}',
  p_msg_text => g_ledger_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_dataset_cd{105}',
  p_msg_text => g_dataset_cd);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_cal_per_id{106}',
  p_msg_text => g_cal_per_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_source_cd{107}',
  p_msg_text => g_source_cd);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_exec_mode{108}',
  p_msg_text => g_exec_mode);

-------------------------------
-- Call Validation Procedure --
-------------------------------
g_block := 'Validation';
Validation;

---------------------------------
-- Call Registration Procedure --
---------------------------------
g_block := 'Registration';
Registration;
COMMIT;

--------------------------------
-- Call Pre_Process Procedure --
--------------------------------
g_block := 'Pre_Process';
Pre_Process;

-- ------------------------------------------------
-- Call FEM_MP.Master to run Process_Rows Procedure
-- ------------------------------------------------
g_block := 'Process_Rows';

FEM_Multi_Proc_Pkg.Master(
  x_prg_stat => v_prg_stat,
  x_exception_code => v_exception_code,
  p_rule_id => g_object_id,
  p_eng_step => 'ALL',
  p_data_table => g_data_t_table,
  p_eng_sql => g_select_stmt,
  p_eng_prg => 'FEM_DATAX_LOADER_PKG.Process_Rows',
  p_condition => g_condition,
  p_failed_req_id => null,
  p_arg1 => g_data_table,
  p_arg2 => g_object_id,
  p_arg3 => g_ledger_id,
  p_arg4 => g_dataset_cd,
  p_arg5 => g_cal_per_id,
  p_arg6 => g_source_cd,
  p_arg7 => g_exec_mode,
  p_arg8 => g_req_id,
  p_arg9 => g_cctr_org_sql,
  p_arg10 => g_fin_elem_sql,
  p_arg11 => g_product_sql,
  p_arg12 => g_nat_acct_sql,
  p_arg13 => g_channel_sql,
  p_arg14 => g_line_item_sql,
  p_arg15 => g_project_sql,
  p_arg16 => g_customer_sql,
  p_arg17 => g_entity_sql,
  p_arg18 => g_geography_sql,
  p_arg19 => g_task_sql,
  p_arg20 => g_interco_sql,
  p_arg21 => g_user_dim1_sql,
  p_arg22 => g_user_dim2_sql,
  p_arg23 => g_user_dim3_sql,
  p_arg24 => g_user_dim4_sql,
  p_arg25 => g_user_dim5_sql,
  p_arg26 => g_user_dim6_sql,
  p_arg27 => g_user_dim7_sql,
  p_arg28 => g_user_dim8_sql,
  p_arg29 => g_user_dim9_sql,
  p_arg30 => g_user_dim10_sql);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_prg_stat{109}',
  p_msg_text => v_prg_stat);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_exception_code{110}',
  p_msg_text => v_exception_code);

IF (v_exception_code = 'FEM_MP_NO_DATA_SLICES_ERR')
THEN

   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_NULL_SLICES_ERR',
     p_token1 => 'TABLE',
     p_value1 => g_data_t_table);
   g_message := FND_MSG_PUB.GET(p_encoded => c_false);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.null_slices{111}',
     p_msg_text => g_message);
   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => g_message);
END IF;

SELECT NVL(SUM(rows_processed),0),
       NVL(SUM(rows_loaded),0),
       NVL(SUM(rows_rejected),0)
INTO   g_rows_processed,
       g_rows_loaded,
       g_rows_rejected
FROM   fem_mp_process_ctl_t
WHERE  req_id = g_req_id;

IF (v_prg_stat = 'COMPLETE:NORMAL')
THEN
   IF (g_rows_rejected = 0)
   THEN
      v_status := 0;
      g_exec_status := 'SUCCESS';
   ELSE
      v_status := 1;
      g_exec_status := 'ERROR_RERUN';
   END IF;
ELSIF (v_prg_stat = 'COMPLETE:WARNING')
THEN
   v_status := 1;
   g_exec_status := 'ERROR_RERUN';
   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',null);
ELSE
   v_status := 2;
   g_exec_status := 'ERROR_RERUN';
   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);
END IF;

IF (c_dev_mode = 'P') AND
   (v_status IN (0,1))
THEN
   FEM_Multi_Proc_Pkg.Delete_Data_Slices(
      p_req_id => g_req_id);
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_rows_processed{112}',
  p_msg_text => g_rows_processed);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_rows_loaded{113}',
  p_msg_text => g_rows_loaded);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_rows_rejected{114}',
  p_msg_text => g_rows_rejected);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_exec_status{115}',
  p_msg_text => g_exec_status);

g_upd_pl_on_err := 'N';

---------------------------------
-- Call Post_Process Procedure --
---------------------------------
g_block := 'Post_Process';
Post_Process;

g_block := 'Master';

-------------------
-- Post Messages --
-------------------
IF (g_exec_status = 'SUCCESS')
THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_EXEC_SUCCESS');
ELSE
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_EXEC_RERUN');
END IF;

g_message := FND_MSG_PUB.GET(p_encoded => c_false);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.exec_status{120}',
  p_msg_text => g_message);
FEM_ENGINES_PKG.USER_MESSAGE
 (p_msg_text => g_message);

IF (g_rows_rejected > 0)
THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_BAD_DATA_ERR',
     p_token1 => 'COUNT',
     p_value1 => g_rows_rejected);
   g_message := FND_MSG_PUB.GET(p_encoded => c_false);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.exec_status{121}',
     p_msg_text => g_message);
   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => g_message);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.End{130}',
  p_msg_text => 'End FEM_DATAX_LOADER.Master');

---------------------
-- Exception Block --
---------------------
EXCEPTION

WHEN e_process_lock_error THEN

   ------- Clean-up -------
   g_exec_status := 'ERROR_RERUN';

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.g_upd_pl_on_err{190}',
     p_msg_text => g_upd_pl_on_err);

   IF (g_upd_pl_on_err = 'Y')
   THEN
      g_upd_pl_on_err := 'N';
      Post_Process;
   END IF;

   ------- Post Error -------
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_PROCESS_LOCK_ERR',
     p_token1 => 'BLOCK',
     p_value1 => g_block);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_5,
     p_module => v_block||'.Exception{191}',
     p_msg_text => g_message);

   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => g_message);

   ------- Post Status -------
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_EXEC_RERUN');

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.Process_Lock_Error{192}',
     p_msg_text => g_message);

   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => g_message);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

WHEN e_validation_error THEN

   ------- Clean-up -------
   g_exec_status := 'ERROR_RERUN';

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.g_upd_pl_on_err{190}',
     p_msg_text => g_upd_pl_on_err);

   IF (g_upd_pl_on_err = 'Y')
   THEN
      g_upd_pl_on_err := 'N';
      Post_Process;
   END IF;

   ------- Post Error -------
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_5,
     p_module => v_block||'.Exception{'||g_msg_no||'}',
     p_msg_text => g_message);

   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => g_message);

   ------- Post Status -------
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_EXEC_RERUN');

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.Validation_Error{192}',
     p_msg_text => g_message);

   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => g_message);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

WHEN others THEN
   g_message := sqlerrm;

   ------- Clean-up -------
   g_exec_status := 'ERROR_RERUN';

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.g_upd_pl_on_err{190}',
     p_msg_text => g_upd_pl_on_err);

   IF (g_upd_pl_on_err = 'Y')
   THEN
      g_upd_pl_on_err := 'N';
      Post_Process;
   END IF;

   ------- Post Error -------
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_UNEXPECTED_ERROR',
     p_token1 => 'ERR_MSG',
     p_value1 => g_message);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.Exception{194}',
     p_msg_text => g_message);

   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => g_message);

   ------- Post Status -------
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_EXEC_RERUN');

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.Unexpected_Error{195}',
     p_msg_text => g_message);

   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => g_message);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

END Master;


/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                           =================                             *
 *                               Validation                                *
 *                           =================                             *
 *                                                                         *
 ***************************************************************************
 **************************************************************************/

PROCEDURE Validation
IS

---------------------
-- Local Variables --
---------------------
v_proc_col VARCHAR2(30);
v_dc_col VARCHAR2(1024);
v_proc_cols VARCHAR2(1024);
v_uniq_idx VARCHAR2(30);
v_idx_col VARCHAR2(30);
v_proc_key_ok NUMBER;
v_pk_count NUMBER;
v_pk_add   NUMBER := 0;
v_ui_count NUMBER;

v_ledger_dc VARCHAR2(150);
v_ledger_name VARCHAR2(150);
v_dataset_dc VARCHAR2(150);
v_dataset_name VARCHAR2(150);
v_source_dc VARCHAR2(150);
v_source_name VARCHAR2(150);

v_cal_per_end_date DATE;
v_dim_grp_cd VARCHAR2(150);
v_cal_per_num NUMBER;
v_cal_per_name VARCHAR2(150);
v_cal_period VARCHAR2(150);

v_count NUMBER;
v_member VARCHAR2(150);

v_return_status  VARCHAR2(1);
v_msg_count   NUMBER;

v_block  CONSTANT  VARCHAR2(80) :=
   'fem.plsql.fem_datax_loader_pkg.validation';

----------------------
-- Cursor Variables --
----------------------
CURSOR c_proc_key IS
   SELECT column_name
   FROM fem_tab_column_prop
   WHERE table_name = g_data_table
   AND column_property_code = 'PROCESSING_KEY'
   AND column_name not in ('CREATED_BY_OBJECT_ID')
   ORDER BY column_name;

CURSOR c_uniq_idx IS
   SELECT index_name
   FROM all_indexes
   WHERE owner = c_fem_schema
   AND table_name = g_data_t_table
   AND uniqueness = 'UNIQUE';

CURSOR c_idx_col IS
   SELECT column_name
   FROM all_ind_columns
   WHERE index_owner = c_fem_schema
   AND index_name = v_uniq_idx
   ORDER BY column_position;

----------------
-- Exceptions --
----------------
e_bad_exec_mode            EXCEPTION;
e_bad_obj_def              EXCEPTION;
e_bad_target_table         EXCEPTION;
e_no_proc_key              EXCEPTION;
e_bad_proc_key             EXCEPTION;
e_no_unq_idx               EXCEPTION;
e_no_pk_match              EXCEPTION;
e_bad_ledger_id            EXCEPTION;
e_bad_ledger_attr          EXCEPTION;
e_no_ledger_dc             EXCEPTION;
e_bad_gvc_id               EXCEPTION;
e_bad_dataset_cd           EXCEPTION;
e_bad_dataset_attr         EXCEPTION;
e_no_dataset_dc            EXCEPTION;
e_bad_source_cd            EXCEPTION;
e_no_source_dc             EXCEPTION;
e_bad_cal_per_id           EXCEPTION;
e_no_cal_period            EXCEPTION;
e_no_data_match         EXCEPTION;

BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.Begin{200}',
  p_msg_text => 'Begin FEM_DATAX_LOADER.Validation');

----------------------------
-- Verify Processing Mode --
----------------------------
CASE g_exec_mode
   WHEN 'S' THEN NULL;
   WHEN 'E' THEN NULL;
   ELSE RAISE e_bad_exec_mode;
END CASE;

------------------------------
-- Verify Object Definition --
------------------------------
BEGIN
   SELECT C.object_id
   INTO   g_object_id
   FROM   fem_object_catalog_vl C,
          fem_object_definition_vl D
   WHERE  D.object_definition_id = g_obj_def_id
   AND    C.object_id = D.object_id
   AND    C.folder_id IN
      (SELECT folder_id
       FROM fem_user_folders
       WHERE user_id =  c_user_id);
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_obj_def;
END;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_object_id{201}',
  p_msg_text => g_object_id);

CASE g_object_id
   WHEN 1301 THEN g_data_table := 'FEM_DATA1';
   WHEN 1302 THEN g_data_table := 'FEM_DATA2';
   WHEN 1303 THEN g_data_table := 'FEM_DATA3';
   WHEN 1304 THEN g_data_table := 'FEM_DATA4';
   WHEN 1305 THEN g_data_table := 'FEM_DATA5';
   WHEN 1306 THEN g_data_table := 'FEM_DATA6';
   WHEN 1307 THEN g_data_table := 'FEM_DATA7';
   WHEN 1308 THEN g_data_table := 'FEM_DATA8';
   WHEN 1309 THEN g_data_table := 'FEM_DATA9';
   WHEN 1310 THEN g_data_table := 'FEM_DATA10';
   WHEN 1311 THEN g_data_table := 'FEM_DATA11';
   WHEN 1312 THEN g_data_table := 'FEM_DATA12';
   WHEN 1313 THEN g_data_table := 'FEM_DATA13';
   WHEN 1314 THEN g_data_table := 'FEM_DATA14';
   WHEN 1315 THEN g_data_table := 'FEM_DATA15';
   WHEN 1316 THEN g_data_table := 'FEM_DATA16';
   WHEN 1317 THEN g_data_table := 'FEM_DATA17';
   WHEN 1318 THEN g_data_table := 'FEM_DATA18';
   WHEN 1319 THEN g_data_table := 'FEM_DATA19';
   WHEN 1320 THEN g_data_table := 'FEM_DATA20';
   ELSE RAISE e_bad_obj_def;
END CASE;

IF (g_table_name IS NOT NULL)
THEN
   g_data_table := g_table_name;
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_data_table{202}',
  p_msg_text => g_data_table);

-------------------------
-- Verify Target Table --
-------------------------
SELECT COUNT(*)
INTO v_count
FROM fem_table_class_assignmt
WHERE table_name = g_data_table
AND table_classification_code = 'GENERIC_DATA_TABLE';

IF (v_count <> 1)
THEN
   RAISE e_bad_target_table;
END IF;
g_data_t_table := g_data_table||'_T';

---------------------------
-- Verify Processing Key --
---------------------------
FOR r_proc_key IN c_proc_key
LOOP
   v_proc_col := r_proc_key.column_name;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_1,
     p_module => v_block||'.v_proc_col{204}',
     p_msg_text => v_proc_col);

   IF (v_proc_col = 'CAL_PERIOD_ID')
   THEN
      v_pk_add := 2;
      v_dc_col := 'CALP_DIM_GRP_DISPLAY_CODE'','||
                   '''CAL_PERIOD_END_DATE'','||
                   '''CAL_PERIOD_NUMBER';
   ELSE
      CASE v_proc_col
         WHEN 'DATASET_CODE' THEN
            v_dc_col := 'DATASET_DISPLAY_CODE';
         WHEN 'SOURCE_SYSTEM_CODE' THEN
            v_dc_col := 'SOURCE_SYSTEM_DISPLAY_CODE';
         WHEN 'LEDGER_ID' THEN
            v_dc_col := 'LEDGER_DISPLAY_CODE';
         WHEN 'COMPANY_COST_CENTER_ORG_ID' THEN
            v_dc_col := 'CCTR_ORG_DISPLAY_CODE';
         WHEN 'CURRENCY_CODE' THEN
            v_dc_col := 'CURRENCY_CODE';
         WHEN 'FINANCIAL_ELEM_ID' THEN
            v_dc_col := 'FINANCIAL_ELEM_DISPLAY_CODE';
         WHEN 'PRODUCT_ID' THEN
            v_dc_col := 'PRODUCT_DISPLAY_CODE';
         WHEN 'NATURAL_ACCOUNT_ID' THEN
            v_dc_col := 'NATURAL_ACCOUNT_DISPLAY_CODE';
         WHEN 'CHANNEL_ID' THEN
            v_dc_col := 'CHANNEL_DISPLAY_CODE';
         WHEN 'LINE_ITEM_ID' THEN
            v_dc_col := 'LINE_ITEM_DISPLAY_CODE';
         WHEN 'PROJECT_ID' THEN
            v_dc_col := 'PROJECT_DISPLAY_CODE';
         WHEN 'CUSTOMER_ID' THEN
            v_dc_col := 'CUSTOMER_DISPLAY_CODE';
         WHEN 'ENTITY_ID' THEN
            v_dc_col := 'ENTITY_DISPLAY_CODE';
         WHEN 'INTERCOMPANY_ID' THEN
            v_dc_col := 'INTERCOMPANY_DISPLAY_CODE';
         WHEN 'GEOGRAPHY_ID' THEN
            v_dc_col := 'GEOGRAPHY_DISPLAY_CODE';
         WHEN 'TASK_ID' THEN
            v_dc_col := 'TASK_DISPLAY_CODE';
         WHEN 'USER_DIM1_ID' THEN
            v_dc_col := 'USER_DIM1_DISPLAY_CODE';
         WHEN 'USER_DIM2_ID' THEN
            v_dc_col := 'USER_DIM2_DISPLAY_CODE';
         WHEN 'USER_DIM3_ID' THEN
            v_dc_col := 'USER_DIM3_DISPLAY_CODE';
         WHEN 'USER_DIM4_ID' THEN
            v_dc_col := 'USER_DIM4_DISPLAY_CODE';
         WHEN 'USER_DIM5_ID' THEN
            v_dc_col := 'USER_DIM5_DISPLAY_CODE';
         WHEN 'USER_DIM6_ID' THEN
            v_dc_col := 'USER_DIM6_DISPLAY_CODE';
         WHEN 'USER_DIM7_ID' THEN
            v_dc_col := 'USER_DIM7_DISPLAY_CODE';
         WHEN 'USER_DIM8_ID' THEN
            v_dc_col := 'USER_DIM8_DISPLAY_CODE';
         WHEN 'USER_DIM9_ID' THEN
            v_dc_col := 'USER_DIM9_DISPLAY_CODE';
         WHEN 'USER_DIM10_ID' THEN
            v_dc_col := 'USER_DIM10_DISPLAY_CODE';
         ELSE
            RAISE e_bad_proc_key;
      END CASE;

   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_1,
     p_module => v_block||'.v_dc_col{205}',
     p_msg_text => v_dc_col);

   v_pk_count := c_proc_key%ROWCOUNT;
   IF (v_pk_count > 1)
   THEN
      v_proc_cols := v_proc_cols||','''||v_dc_col||'''';
   ELSE
      v_proc_cols := ''''||v_dc_col||'''';
   END IF;
END LOOP;
v_pk_count := v_pk_count + v_pk_add;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_proc_cols{207}',
  p_msg_text => v_proc_cols);

IF (v_proc_cols IS NULL)
THEN
   RAISE e_no_proc_key;
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_pk_count{208}',
  p_msg_text => v_pk_count);

--------------------------------
-- Find Matching Unique Index --
--------------------------------
FOR r_uniq_idx IN c_uniq_idx
LOOP
   v_uniq_idx := r_uniq_idx.index_name;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_uniq_idx{211}',
     p_msg_text => v_uniq_idx);

   FOR r_idx_col IN c_idx_col
   LOOP
      v_idx_col := r_idx_col.column_name;

      BEGIN
         EXECUTE IMMEDIATE
           'SELECT 1 FROM dual'||
           ' WHERE '''||v_idx_col||''' IN ('||v_proc_cols||')'
         INTO v_proc_key_ok;
      EXCEPTION
         WHEN others THEN
            v_proc_key_ok := 0;
            EXIT;
      END;
   v_ui_count := c_idx_col%ROWCOUNT;
   END LOOP;
   IF (v_proc_key_ok = 1)
   THEN
      IF (v_pk_count = v_ui_count)
      THEN
         EXIT;
      ELSE
         v_proc_key_ok := 0;
      END IF;
   END IF;
END LOOP;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_ui_count{212}',
  p_msg_text => v_ui_count);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_proc_key_ok{213}',
  p_msg_text => v_proc_key_ok);

IF (v_uniq_idx IS NULL)
THEN
   RAISE e_no_unq_idx;
END IF;

IF (v_proc_key_ok = 0)
THEN
   RAISE e_no_pk_match;
END IF;

----------------------
-- Verify Ledger ID --
----------------------
BEGIN
   SELECT ledger_display_code,ledger_name
   INTO   v_ledger_dc,v_ledger_name
   FROM   fem_ledgers_vl
   WHERE  ledger_id = g_ledger_id;
EXCEPTION
   WHEN no_data_found THEN
   RAISE e_bad_ledger_id;
END;

SELECT count(*)
INTO   v_count
FROM   fem_ledgers_b B,
       fem_ledgers_attr A,
       fem_dim_attributes_b T,
       fem_dimensions_b D,
       fem_dim_attr_versions_b V
WHERE  B.ledger_id = g_ledger_id
AND    B.enabled_flag = 'Y'
AND    A.ledger_id = B.ledger_id
AND    T.attribute_id = A.attribute_id
AND    T.attribute_varchar_label = 'CAL_PERIOD_HIER_OBJ_DEF_ID'
AND    V.version_id = A.version_id
AND    V.default_version_flag = 'Y'
AND    D.dimension_id = T.dimension_id
AND    D.dimension_varchar_label = 'LEDGER';

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_ledger_id{215}',
  p_msg_text => g_ledger_id||':COUNT='||v_count);

IF (v_count <> 1)
THEN
   RAISE e_bad_ledger_attr;
END IF;

-------------------------------
-- Verify Global VS Combo ID --
-------------------------------
FND_MSG_PUB.Initialize;
g_gvc_id := FEM_DIMENSION_UTIL_PKG.GLOBAL_VS_COMBO_ID
            (p_encoded => c_false,
             x_return_status => v_return_status,
             x_msg_count => v_msg_count,
             x_msg_data => g_message,
             p_ledger_id => g_ledger_id);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_gvc_id{217}',
  p_msg_text => g_gvc_id);

IF (g_gvc_id = -1)
THEN
   RAISE e_bad_gvc_id;
END IF;

-------------------------
-- Verify DataSet Code --
-------------------------
BEGIN
   SELECT dataset_display_code,dataset_name
   INTO   v_dataset_dc,v_dataset_name
   FROM   fem_datasets_vl
   WHERE  dataset_code = g_dataset_cd;
EXCEPTION
   WHEN no_data_found THEN
   RAISE e_bad_dataset_cd;
END;

SELECT count(*)
INTO   v_count
FROM   fem_datasets_b B,
       fem_datasets_attr A,
       fem_dim_attributes_b T,
       fem_dimensions_b D,
       fem_dim_attr_versions_b V
WHERE  B.dataset_code = g_dataset_cd
AND    B.enabled_flag = 'Y'
AND    A.dataset_code = B.dataset_code
AND    T.attribute_id = A.attribute_id
AND    T.attribute_varchar_label = 'DATASET_BALANCE_TYPE_CODE'
AND    V.version_id = A.version_id
AND    V.default_version_flag = 'Y'
AND    D.dimension_id = T.dimension_id
AND    D.dimension_varchar_label = 'DATASET';

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_dataset_cd{218}',
  p_msg_text => g_dataset_cd||':COUNT='||v_count);

IF (v_count <> 1)
THEN
   RAISE e_bad_dataset_attr;
END IF;

------------------------
-- Verify Source Code --
------------------------
BEGIN
   SELECT source_system_display_code,source_system_name
   INTO v_source_dc,v_source_name
   FROM fem_source_systems_vl
   WHERE source_system_code = g_source_cd;
EXCEPTION
   WHEN no_data_found THEN
   RAISE e_bad_source_cd;
END;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_source_dc{220}',
  p_msg_text => v_source_dc);

-------------------------------
-- Verify Calendar Period ID --
-------------------------------
BEGIN
   SELECT cal_period_name
   INTO   v_cal_per_name
   FROM   fem_cal_periods_vl
   WHERE  cal_period_id = g_cal_per_id;
EXCEPTION
   WHEN no_data_found THEN
      v_cal_period := g_cal_per_id;
      RAISE e_bad_cal_per_id;
END;

BEGIN
   SELECT G.dimension_group_display_code,
          D.date_assign_value,
          N.number_assign_value
   INTO   v_dim_grp_cd,
          v_cal_per_end_date,
          v_cal_per_num
   FROM   fem_cal_periods_b C,
          fem_cal_periods_attr N,
          fem_cal_periods_attr D,
          fem_dimension_grps_b G,
          fem_dim_attr_versions_b NV,
          fem_dim_attr_versions_b DV
   WHERE  C.cal_period_id = g_cal_per_id
   AND    C.dimension_group_id = G.dimension_group_id
   AND    N.attribute_id =
             (SELECT attribute_id FROM fem_dim_attributes_b
              WHERE attribute_varchar_label = 'GL_PERIOD_NUM')
   AND    N.version_id = NV.version_id
   AND    N.cal_period_id = g_cal_per_id
   AND    NV.default_version_flag = 'Y'
   AND    D.attribute_id =
             (SELECT attribute_id FROM fem_dim_attributes_b
              WHERE attribute_varchar_label = 'CAL_PERIOD_END_DATE')
   AND    D.version_id = DV.version_id
   AND    D.cal_period_id = g_cal_per_id
   AND    DV.default_version_flag = 'Y';

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_dim_grp_cd{230}',
     p_msg_text => v_dim_grp_cd);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_cal_per_end_date{232}',
     p_msg_text => TO_CHAR(v_cal_per_end_date,'YYYY/MM/DD HH24:MI:SS'));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_cal_per_num{234}',
     p_msg_text => v_cal_per_num);

EXCEPTION
   WHEN no_data_found THEN
      v_cal_period := v_cal_per_name;
      RAISE e_bad_cal_per_id;
END;

------------------------------
-- Verify Parameter Data Match
------------------------------
EXECUTE IMMEDIATE
  'SELECT COUNT(*)'||
  ' FROM '||g_data_t_table||
  ' WHERE calp_dim_grp_display_code = :b_dim_grp_cd'||
  ' AND cal_period_end_date = :b_cal_per_end_date'||
  ' AND cal_period_number = :b_cal_per_num'||
  ' AND ledger_display_code = :b_ledger_dc'||
  ' AND dataset_display_code = :b_dataset_dc'||
  ' AND source_system_display_code = :b_source_dc'||
  ' AND rownum = 1'
INTO v_count
USING v_dim_grp_cd,
      TO_DATE(TO_CHAR(v_cal_per_end_date,'YYYY/MM/DD HH24:MI:SS'),'YYYY/MM/DD HH24:MI:SS'),
      v_cal_per_num,
      v_ledger_dc,
      v_dataset_dc,
      v_source_dc;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.data_match{236}',
  p_msg_text => 'data_match='||v_count);

IF (v_count = 0)
THEN
   RAISE e_no_data_match;
END IF;

----------------------------------
-- Build Data Slicing Condition --
----------------------------------
g_condition := ' dataset_display_code = '''||v_dataset_dc||''''||
         ' AND   calp_dim_grp_display_code = '''||v_dim_grp_cd||''''||
         ' AND   cal_period_end_date = TO_DATE('''||TO_CHAR(v_cal_per_end_date,'YYYY/MM/DD HH24:MI:SS')||''',''YYYY/MM/DD HH24:MI:SS'')'||
         ' AND   cal_period_number = '||v_cal_per_num||
         ' AND   ledger_display_code = '''||v_ledger_dc||''''||
         ' AND   source_system_display_code = '''||v_source_dc||'''';

IF (g_exec_mode = 'S')
THEN
   g_condition := g_condition||' AND   status = ''LOAD''';
ELSE
   g_condition := g_condition||' AND   status <> ''LOAD''';
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.End{240}',
  p_msg_text => 'End FEM_DATAX_LOADER.Validation');

---------------------
-- Exception Block --
---------------------
EXCEPTION

WHEN e_bad_exec_mode THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_BAD_EXEC_ERR');

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 241;

   RAISE e_validation_error;

WHEN e_bad_obj_def THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_BAD_OBJ_ERR',
     p_token1 => 'OBJECT',
     p_value1 => g_obj_def_id);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 242;

   RAISE e_validation_error;

WHEN e_bad_target_table THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_BAD_TABLE_ERR',
     p_token1 => 'TABLE',
     p_value1 => g_data_table);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 243;

   RAISE e_validation_error;

WHEN e_no_proc_key THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_NO_PROC_KEY_ERR',
     p_token1 => 'TABLE',
     p_value1 => g_data_table);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 244;

   RAISE e_validation_error;

WHEN e_bad_proc_key THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_BAD_PROC_KEY_ERR',
     p_token1 => 'COLUMN',
     p_value1 => v_proc_col);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 245;

   RAISE e_validation_error;

WHEN e_no_unq_idx THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_NO_UNIQ_IDX_ERR',
     p_token1 => 'TABLE',
     p_value1 => g_data_t_table);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 246;

   RAISE e_validation_error;

WHEN e_no_pk_match THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_NO_PK_MATCH_ERR');

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 247;

   RAISE e_validation_error;

WHEN e_bad_ledger_id THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_BAD_LEDGER_ERR',
     p_token1 => 'LEDGER',
     p_value1 => g_ledger_id);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 248;

   RAISE e_validation_error;

WHEN e_bad_ledger_attr THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_LEDGER_ATTR_ERR',
     p_token1 => 'LEDGER',
     p_value1 => v_ledger_name);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 249;

   RAISE e_validation_error;

WHEN e_bad_gvc_id THEN

   g_msg_no := 250;
   RAISE e_validation_error;

WHEN e_bad_dataset_cd THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_BAD_DATASET_ERR',
     p_token1 => 'DATASET',
     p_value1 => g_dataset_cd);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 251;

   RAISE e_validation_error;

WHEN e_bad_dataset_attr THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_DATASET_ATTR_ERR',
     p_token1 => 'DATASET',
     p_value1 => v_dataset_name);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 252;

   RAISE e_validation_error;

WHEN e_bad_source_cd THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_BAD_SOURCE_ERR',
     p_token1 => 'SOURCE',
     p_value1 => g_source_cd);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 253;

   RAISE e_validation_error;

WHEN e_bad_cal_per_id THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_BAD_CAL_PER_ERR',
     p_token1 => 'CAL_PER',
     p_value1 => v_cal_period);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 254;

   RAISE e_validation_error;

WHEN e_no_data_match THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_DATA_MATCH_ERR',
     p_token1 => 'TABLE',
     p_value1 => g_data_t_table,
     p_token2 => 'DIM_GRP',
     p_value2 => v_dim_grp_cd,
     p_token3 => 'PER_NUM',
     p_value3 => v_cal_per_num,
     p_token4 => 'END_DATE',
     p_value4 => TO_CHAR(v_cal_per_end_date,'YYYY/MM/DD HH24:MI:SS'),
     p_token5 => 'LEDGER_DC',
     p_value5 => v_ledger_dc,
     p_token6 => 'DATASET_DC',
     p_value6 => v_dataset_dc,
     p_token7 => 'SOURCE_DC',
     p_value7 => v_source_dc);

   g_message := FND_MSG_PUB.GET(p_encoded => c_false);
   g_msg_no := 255;

   RAISE e_validation_error;

END Validation;


/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                           ================                              *
 *                             Registration                                *
 *                           ================                              *
 *                                                                         *
 ***************************************************************************
 **************************************************************************/

PROCEDURE Registration
IS

v_exec_state       VARCHAR2(30);
v_retcode          NUMBER;
v_num_msg          NUMBER;
v_msg_count        NUMBER;
v_msg_data         VARCHAR2(4196);
v_return_status    VARCHAR2(1);
v_prev_req_id      NUMBER;

v_block  CONSTANT  VARCHAR2(80) :=
   'fem.plsql.fem_datax_loader_pkg.registration';

BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.Begin{300}',
  p_msg_text => 'Begin FEM_DATAX_LOADER.Registration');

----------------------
-- Register Request --
----------------------
FEM_PL_PKG.Register_Request(
  p_api_version => c_api_version,
  p_cal_period_id => g_cal_per_id,
  p_ledger_id => g_ledger_id,
  p_dataset_io_obj_def_id => null,
  p_output_dataset_code => g_dataset_cd,
  p_source_system_code => g_source_cd,
  p_effective_date => null,
  p_rule_set_obj_def_id => null,
  p_rule_set_name => null,
  p_request_id => g_req_id,
  p_user_id => c_user_id,
  p_last_update_login => null,
  p_program_id => c_conc_prg_id,
  p_program_login_id => c_login_id,
  p_program_application_id => c_prg_app_id,
  p_exec_mode_code => g_exec_mode,
  p_dimension_id => null,
  p_table_name => g_data_table,
  p_hierarchy_name => null,
  x_msg_count => v_msg_count,
  x_msg_data => v_msg_data,
  x_return_status => v_return_status);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.register_request.return_status{301}',
  p_msg_text => v_return_status);

Get_Put_Messages (
  p_msg_count => v_msg_count,
  p_msg_data => v_msg_data);

IF (v_return_status <> c_success)
THEN
   RAISE e_process_lock_error;
END IF;

-------------------------------
-- Register Object Execution --
-------------------------------
FEM_PL_PKG.Register_Object_Execution(
  p_api_version => c_api_version,
  p_request_id => g_req_id,
  p_object_id => g_object_id,
  p_exec_object_definition_id => g_obj_def_id,
  p_user_id => c_user_id,
  p_last_update_login => null,
  p_exec_mode_code => g_exec_mode,
  x_exec_state => v_exec_state,
  x_prev_request_id => v_prev_req_id,
  x_msg_count => v_msg_count,
  x_msg_data => v_msg_data,
  x_return_status => v_return_status);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_exec_state{302}',
  p_msg_text => v_exec_state);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_prev_req_id{303}',
  p_msg_text => v_prev_req_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.object_execution.return_status{304}',
  p_msg_text => v_return_status);

Get_Put_Messages (
  p_msg_count => v_msg_count,
  p_msg_data => v_msg_data);

IF (v_return_status <> c_success)
THEN
   FEM_PL_PKG.Unregister_Request(
     p_api_version => c_api_version,
     p_commit => c_true,
     p_request_id => g_req_id,
     x_msg_count => v_msg_count,
     x_msg_data => v_msg_data,
     x_return_status => v_return_status);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.unregister_request.return_status{305}',
     p_msg_text => v_return_status);

   Get_Put_Messages (
     p_msg_count => v_msg_count,
     p_msg_data => v_msg_data);

   RAISE e_process_lock_error;
END IF;

g_upd_pl_on_err := 'Y';

--------------------------------
-- Register Object Definition --
--------------------------------
FEM_PL_PKG.Register_Object_Def(
  p_api_version => c_api_version,
  p_request_id => g_req_id,
  p_object_id => g_object_id,
  p_object_definition_id => g_obj_def_id,
  p_user_id => c_user_id,
  p_last_update_login => null,
  x_msg_count => v_msg_count,
  x_msg_data => v_msg_data,
  x_return_status => v_return_status);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.register_object_def.return_status{306}',
  p_msg_text => v_return_status);

Get_Put_Messages (
  p_msg_count => v_msg_count,
  p_msg_data => v_msg_data);

IF (v_return_status <> c_success)
THEN
   RAISE e_process_lock_error;
END IF;

--------------------
-- Register Table --
--------------------
FEM_PL_PKG.Register_Table(
  p_api_version => c_api_version,
  p_request_id => g_req_id,
  p_object_id => g_object_id,
  p_table_name => g_data_table,
  p_statement_type => 'INSERT',
  p_num_of_output_rows => 0,
  p_user_id => c_user_id,
  p_last_update_login => null,
  x_msg_count => v_msg_count,
  x_msg_data => v_msg_data,
  x_return_status => v_return_status);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.register_table.return_status{307}',
  p_msg_text => v_return_status);

Get_Put_Messages (
  p_msg_count => v_msg_count,
  p_msg_data => v_msg_data);

IF (v_return_status <> c_success)
THEN
   RAISE e_process_lock_error;
END IF;

----------------------------
-- Register Data Location --
----------------------------
FEM_DIMENSION_UTIL_PKG.REGISTER_DATA_LOCATION
   (p_request_id => g_req_id,
    p_object_id => g_object_id,
    p_table_name => g_data_table,
    p_ledger_id => g_ledger_id,
    p_cal_per_id => g_cal_per_id,
    p_dataset_cd => g_dataset_cd,
    p_source_cd => g_source_cd,
    p_load_status => 'INCOMPLETE');

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.End{320}',
  p_msg_text => 'End FEM_DATAX_LOADER.Registration');

END Registration;


/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                           ================                              *
 *                              Pre_Process                                *
 *                           ================                              *
 *                                                                         *
 ***************************************************************************
 **************************************************************************/

PROCEDURE Pre_Process
IS

v_cctr_org_col VARCHAR2(30);
v_cctr_org_dc_col VARCHAR2(30);
v_cctr_org_b_tab VARCHAR2(30);

v_fin_elem_col VARCHAR2(30);
v_fin_elem_dc_col VARCHAR2(30);
v_fin_elem_b_tab VARCHAR2(30);

v_product_col VARCHAR2(30);
v_product_dc_col VARCHAR2(30);
v_product_b_tab VARCHAR2(30);

v_nat_acct_col VARCHAR2(30);
v_nat_acct_dc_col VARCHAR2(30);
v_nat_acct_b_tab VARCHAR2(30);

v_channel_col VARCHAR2(30);
v_channel_dc_col VARCHAR2(30);
v_channel_b_tab VARCHAR2(30);

v_line_item_col VARCHAR2(30);
v_line_item_dc_col VARCHAR2(30);
v_line_item_b_tab VARCHAR2(30);

v_project_col VARCHAR2(30);
v_project_dc_col VARCHAR2(30);
v_project_b_tab VARCHAR2(30);

v_customer_col VARCHAR2(30);
v_customer_dc_col VARCHAR2(30);
v_customer_b_tab VARCHAR2(30);

v_entity_col VARCHAR2(30);
v_entity_dc_col VARCHAR2(30);
v_entity_b_tab VARCHAR2(30);

v_geography_col VARCHAR2(30);
v_geography_dc_col VARCHAR2(30);
v_geography_b_tab VARCHAR2(30);

v_task_col VARCHAR2(30);
v_task_dc_col VARCHAR2(30);
v_task_b_tab VARCHAR2(30);

v_interco_col VARCHAR2(30);
v_interco_dc_col VARCHAR2(30);
v_interco_b_tab VARCHAR2(30);

v_user_dim1_col VARCHAR2(30);
v_user_dim1_dc_col VARCHAR2(30);
v_user_dim1_b_tab VARCHAR2(30);

v_user_dim2_col VARCHAR2(30);
v_user_dim2_dc_col VARCHAR2(30);
v_user_dim2_b_tab VARCHAR2(30);

v_user_dim3_col VARCHAR2(30);
v_user_dim3_dc_col VARCHAR2(30);
v_user_dim3_b_tab VARCHAR2(30);

v_user_dim4_col VARCHAR2(30);
v_user_dim4_dc_col VARCHAR2(30);
v_user_dim4_b_tab VARCHAR2(30);

v_user_dim5_col VARCHAR2(30);
v_user_dim5_dc_col VARCHAR2(30);
v_user_dim5_b_tab VARCHAR2(30);

v_user_dim6_col VARCHAR2(30);
v_user_dim6_dc_col VARCHAR2(30);
v_user_dim6_b_tab VARCHAR2(30);

v_user_dim7_col VARCHAR2(30);
v_user_dim7_dc_col VARCHAR2(30);
v_user_dim7_b_tab VARCHAR2(30);

v_user_dim8_col VARCHAR2(30);
v_user_dim8_dc_col VARCHAR2(30);
v_user_dim8_b_tab VARCHAR2(30);

v_user_dim9_col VARCHAR2(30);
v_user_dim9_dc_col VARCHAR2(30);
v_user_dim9_b_tab VARCHAR2(30);

v_user_dim10_col VARCHAR2(30);
v_user_dim10_dc_col VARCHAR2(30);
v_user_dim10_b_tab VARCHAR2(30);

v_block  CONSTANT  VARCHAR2(80) :=
   'fem.plsql.fem_datax_loader_pkg.pre_process';

BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.Begin{400}',
  p_msg_text => 'Begin FEM_DATAX_LOADER.Pre_Process');

------------------------------------------------------------------
-- Build a SQL statement for each dimension to retrieve ID members
------------------------------------------------------------------
BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_cctr_org_b_tab,v_cctr_org_col,v_cctr_org_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'COMPANY_COST_CENTER_ORG_ID'
   AND    C.dimension_id = X.dimension_id;

   g_cctr_org_sql :=
    'SELECT '||v_cctr_org_col||
    ' FROM '||v_cctr_org_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_cctr_org_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_cctr_org_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_fin_elem_b_tab,v_fin_elem_col,v_fin_elem_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'FINANCIAL_ELEM_ID'
   AND    C.dimension_id = X.dimension_id;

   g_fin_elem_sql :=
    'SELECT '||v_fin_elem_col||
    ' FROM '||v_fin_elem_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_fin_elem_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_fin_elem_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_product_b_tab,v_product_col,v_product_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'PRODUCT_ID'
   AND    C.dimension_id = X.dimension_id;

   g_product_sql :=
    'SELECT '||v_product_col||
    ' FROM '||v_product_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_product_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_product_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_nat_acct_b_tab,v_nat_acct_col,v_nat_acct_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'NATURAL_ACCOUNT_ID'
   AND    C.dimension_id = X.dimension_id;

   g_nat_acct_sql :=
    'SELECT '||v_nat_acct_col||
    ' FROM '||v_nat_acct_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_nat_acct_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_nat_acct_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_channel_b_tab,v_channel_col,v_channel_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'CHANNEL_ID'
   AND    C.dimension_id = X.dimension_id;

   g_channel_sql :=
    'SELECT '||v_channel_col||
    ' FROM '||v_channel_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_channel_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_channel_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_line_item_b_tab,v_line_item_col,v_line_item_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'LINE_ITEM_ID'
   AND    C.dimension_id = X.dimension_id;

   g_line_item_sql :=
    'SELECT '||v_line_item_col||
    ' FROM '||v_line_item_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_line_item_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_line_item_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_project_b_tab,v_project_col,v_project_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'PROJECT_ID'
   AND    C.dimension_id = X.dimension_id;

   g_project_sql :=
    'SELECT '||v_project_col||
    ' FROM '||v_project_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_project_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_project_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_customer_b_tab,v_customer_col,v_customer_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'CUSTOMER_ID'
   AND    C.dimension_id = X.dimension_id;

   g_customer_sql :=
    'SELECT '||v_customer_col||
    ' FROM '||v_customer_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_customer_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_customer_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_entity_b_tab,v_entity_col,v_entity_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'ENTITY_ID'
   AND    C.dimension_id = X.dimension_id;

   g_entity_sql :=
    'SELECT '||v_entity_col||
    ' FROM '||v_entity_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_entity_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_entity_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_geography_b_tab,v_geography_col,v_geography_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'GEOGRAPHY_ID'
   AND    C.dimension_id = X.dimension_id;

   g_geography_sql :=
    'SELECT '||v_geography_col||
    ' FROM '||v_geography_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_geography_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_geography_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_task_b_tab,v_task_col,v_task_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'TASK_ID'
   AND    C.dimension_id = X.dimension_id;

   g_task_sql :=
    'SELECT '||v_task_col||
    ' FROM '||v_task_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_task_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_task_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_interco_b_tab,v_interco_col,v_interco_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'INTERCOMPANY_ID'
   AND    C.dimension_id = X.dimension_id;

   g_interco_sql :=
    'SELECT '||v_interco_col||
    ' FROM '||v_interco_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_interco_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_interco_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_user_dim1_b_tab,v_user_dim1_col,v_user_dim1_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'USER_DIM1_ID'
   AND    C.dimension_id = X.dimension_id;

   g_user_dim1_sql :=
    'SELECT '||v_user_dim1_col||
    ' FROM '||v_user_dim1_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_user_dim1_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_user_dim1_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_user_dim2_b_tab,v_user_dim2_col,v_user_dim2_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'USER_DIM2_ID'
   AND    C.dimension_id = X.dimension_id;

   g_user_dim2_sql :=
    'SELECT '||v_user_dim2_col||
    ' FROM '||v_user_dim2_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_user_dim2_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_user_dim2_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_user_dim3_b_tab,v_user_dim3_col,v_user_dim3_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'USER_DIM3_ID'
   AND    C.dimension_id = X.dimension_id;

   g_user_dim3_sql :=
    'SELECT '||v_user_dim3_col||
    ' FROM '||v_user_dim3_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_user_dim3_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_user_dim3_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_user_dim4_b_tab,v_user_dim4_col,v_user_dim4_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'USER_DIM4_ID'
   AND    C.dimension_id = X.dimension_id;

   g_user_dim4_sql :=
    'SELECT '||v_user_dim4_col||
    ' FROM '||v_user_dim4_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_user_dim4_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_user_dim4_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_user_dim5_b_tab,v_user_dim5_col,v_user_dim5_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'USER_DIM5_ID'
   AND    C.dimension_id = X.dimension_id;

   g_user_dim5_sql :=
    'SELECT '||v_user_dim5_col||
    ' FROM '||v_user_dim5_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_user_dim5_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_user_dim5_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_user_dim6_b_tab,v_user_dim6_col,v_user_dim6_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'USER_DIM6_ID'
   AND    C.dimension_id = X.dimension_id;

   g_user_dim6_sql :=
    'SELECT '||v_user_dim6_col||
    ' FROM '||v_user_dim6_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_user_dim6_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_user_dim6_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_user_dim7_b_tab,v_user_dim7_col,v_user_dim7_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'USER_DIM7_ID'
   AND    C.dimension_id = X.dimension_id;

   g_user_dim7_sql :=
    'SELECT '||v_user_dim7_col||
    ' FROM '||v_user_dim7_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_user_dim7_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_user_dim7_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_user_dim8_b_tab,v_user_dim8_col,v_user_dim8_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'USER_DIM8_ID'
   AND    C.dimension_id = X.dimension_id;

   g_user_dim8_sql :=
    'SELECT '||v_user_dim8_col||
    ' FROM '||v_user_dim8_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_user_dim8_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_user_dim8_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_user_dim9_b_tab,v_user_dim9_col,v_user_dim9_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'USER_DIM9_ID'
   AND    C.dimension_id = X.dimension_id;

   g_user_dim9_sql :=
    'SELECT '||v_user_dim9_col||
    ' FROM '||v_user_dim9_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_user_dim9_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_user_dim9_sql := '';
END;

BEGIN
   SELECT member_b_table_name,member_col,member_display_code_col
   INTO   v_user_dim10_b_tab,v_user_dim10_col,v_user_dim10_dc_col
   FROM   fem_tab_columns_b C,
          fem_xdim_dimensions X
   WHERE  C.table_name = g_data_table
   AND    C.column_name = 'USER_DIM10_ID'
   AND    C.dimension_id = X.dimension_id;

   g_user_dim10_sql :=
    'SELECT '||v_user_dim10_col||
    ' FROM '||v_user_dim10_b_tab||' B,'||
    '      fem_global_vs_combo_defs G'||
    ' WHERE G.global_vs_combo_id = '||g_gvc_id||
    ' AND   G.value_set_id = B.value_set_id'||
    ' AND   B.'||v_user_dim10_dc_col||' = :b_dc_val'||
    ' AND   B.enabled_flag = ''Y''';
EXCEPTION
   WHEN no_data_found THEN g_user_dim10_sql := '';
END;

----------------------
-- Build Engine SQL --
----------------------
g_select_stmt :=
   'SELECT rowid,'||
         ' cctr_org_display_code,'||
         ' currency_code,'||
         ' financial_elem_display_code,'||
         ' product_display_code,'||
         ' natural_account_display_code,'||
         ' channel_display_code,'||
         ' line_item_display_code,'||
         ' project_display_code,'||
         ' customer_display_code,'||
         ' entity_display_code,'||
         ' geography_display_code,'||
         ' task_display_code,'||
         ' intercompany_display_code,'||
         ' user_dim1_display_code,'||
         ' user_dim2_display_code,'||
         ' user_dim3_display_code,'||
         ' user_dim4_display_code,'||
         ' user_dim5_display_code,'||
         ' user_dim6_display_code,'||
         ' user_dim7_display_code,'||
         ' user_dim8_display_code,'||
         ' user_dim9_display_code,'||
         ' user_dim10_display_code,'||
         ' numeric_measure,'||
         ' alphanumeric_measure,'||
         ' date_measure,'||
         ' status'||
   ' FROM '||g_data_t_table||
   ' WHERE '||g_condition||
   ' AND   {{data_slice}} ';

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.End{410}',
  p_msg_text => 'End FEM_DATAX_LOADER.Pre_Process');

END Pre_Process;


/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                      =======================                            *
 *                             Process Rows                                *
 *                      =======================                            *
 *                                                                         *
 ***************************************************************************
 **************************************************************************/

PROCEDURE Process_Rows (
   p_eng_sql         IN         VARCHAR2,
   p_slc_pred        IN         VARCHAR2,
   p_proc_num        IN         NUMBER,
   p_part_code       IN         NUMBER,
   p_fetch_limit     IN         NUMBER,
   p_data_table      IN         VARCHAR2,
   p_object_id       IN         NUMBER,
   p_ledger_id       IN         NUMBER,
   p_dataset_cd      IN         NUMBER,
   p_cal_per_id      IN         NUMBER,
   p_source_cd       IN         NUMBER,
   p_exec_mode       IN         VARCHAR2,
   p_req_id          IN         NUMBER,
   p_cctr_org_sql    IN         VARCHAR2,
   p_fin_elem_sql    IN         VARCHAR2,
   p_product_sql     IN         VARCHAR2,
   p_nat_acct_sql    IN         VARCHAR2,
   p_channel_sql     IN         VARCHAR2,
   p_line_item_sql   IN         VARCHAR2,
   p_project_sql     IN         VARCHAR2,
   p_customer_sql    IN         VARCHAR2,
   p_entity_sql      IN         VARCHAR2,
   p_geography_sql   IN         VARCHAR2,
   p_task_sql        IN         VARCHAR2,
   p_interco_sql     IN         VARCHAR2,
   p_user_dim1_sql   IN         VARCHAR2,
   p_user_dim2_sql   IN         VARCHAR2,
   p_user_dim3_sql   IN         VARCHAR2,
   p_user_dim4_sql   IN         VARCHAR2,
   p_user_dim5_sql   IN         VARCHAR2,
   p_user_dim6_sql   IN         VARCHAR2,
   p_user_dim7_sql   IN         VARCHAR2,
   p_user_dim8_sql   IN         VARCHAR2,
   p_user_dim9_sql   IN         VARCHAR2,
   p_user_dim10_sql  IN         VARCHAR2
)
IS

---------------------
-- Local variables --
---------------------
v_data_t_table VARCHAR2(30) := p_data_table||'_T';

v_block  VARCHAR2(160);

v_slc_id  NUMBER;
v_part_name VARCHAR2(30);
p_part_name VARCHAR2(30);

v_slc_num  NUMBER;

v_slc_val1 VARCHAR2(240);
v_slc_val2 VARCHAR2(240);
v_slc_val3 VARCHAR2(240);
v_slc_val4 VARCHAR2(240);
v_num_vals  NUMBER;

v_fetch_limit NUMBER;

v_rerun_error NUMBER := 0;

v_rows_processed NUMBER;
v_rows_rejected NUMBER;
v_rows_loaded NUMBER;

v_varchar VARCHAR2(150);

v_status  NUMBER;
v_message VARCHAR2(4000);

-------------------------------------
-- Declare bulk collection columns --
-------------------------------------

v_last_row   NUMBER;

TYPE rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
t_rowid rowid_type;

TYPE number_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
t_num_measure    number_type;
t_cctr_org_id    number_type;
t_fin_elem_id    number_type;
t_product_id     number_type;
t_nat_acct_id    number_type;
t_channel_id     number_type;
t_line_item_id   number_type;
t_project_id     number_type;
t_customer_id    number_type;
t_entity_id      number_type;
t_geography_id   number_type;
t_task_id        number_type;
t_interco_id     number_type;
t_user_dim1_id   number_type;
t_user_dim2_id   number_type;
t_user_dim3_id   number_type;
t_user_dim4_id   number_type;
t_user_dim5_id   number_type;
t_user_dim6_id   number_type;
t_user_dim7_id   number_type;
t_user_dim8_id   number_type;
t_user_dim9_id   number_type;
t_user_dim10_id  number_type;

TYPE date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
t_date_measure   date_type;

TYPE varchar2_std_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
t_status        varchar2_std_type;
t_currency_cd   varchar2_std_type;

TYPE display_code_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
t_cctr_org_dc   display_code_type;
t_fin_elem_dc   display_code_type;
t_product_dc    display_code_type;
t_nat_acct_dc   display_code_type;
t_channel_dc    display_code_type;
t_line_item_dc  display_code_type;
t_project_dc    display_code_type;
t_customer_dc   display_code_type;
t_entity_dc     display_code_type;
t_geography_dc  display_code_type;
t_task_dc       display_code_type;
t_interco_dc    display_code_type;
t_user_dim1_dc  display_code_type;
t_user_dim2_dc  display_code_type;
t_user_dim3_dc  display_code_type;
t_user_dim4_dc  display_code_type;
t_user_dim5_dc  display_code_type;
t_user_dim6_dc  display_code_type;
t_user_dim7_dc  display_code_type;
t_user_dim8_dc  display_code_type;
t_user_dim9_dc  display_code_type;
t_user_dim10_dc display_code_type;
t_alpha_measure display_code_type;

x_select_stmt VARCHAR2(32767);
x_insert_stmt VARCHAR2(32767);
x_update_stmt VARCHAR2(32767);
x_delete_stmt VARCHAR2(32767);

TYPE cv_curs IS REF CURSOR;
cv_get_rows cv_curs;

---------------------
-- Execution Block --
---------------------
BEGIN

-- DBMS_SESSION.SET_SQL_TRACE (sql_trace => TRUE);

v_block := 'fem.plsql.fem_datax_loader_pkg.process_rows'||
           '{p'||p_proc_num||'}';

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.Begin{800}',
  p_msg_text => 'Begin FEM_DATAX_LOADER.Process_Rows');
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.p_eng_sql{801}',
  p_msg_text => p_eng_sql);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_slc_pred{802}',
  p_msg_text => p_slc_pred);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_proc_num{803}',
  p_msg_text => p_proc_num);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_part_code{804}',
  p_msg_text => p_part_code);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_fetch_limit{805}',
  p_msg_text => p_fetch_limit);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_data_table{806}',
  p_msg_text => p_data_table);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_object_id{807}',
  p_msg_text => p_object_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_ledger_id{808}',
  p_msg_text => p_ledger_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_dataset_cd{809}',
  p_msg_text => p_dataset_cd);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_cal_per_id{810}',
  p_msg_text => p_cal_per_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_source_cd{811}',
  p_msg_text => p_source_cd);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_req_id{812}',
  p_msg_text => p_req_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.p_cctr_org_sql{813.1}',
  p_msg_text => p_cctr_org_sql);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.p_fin_elem_sql{813.2}',
  p_msg_text => p_fin_elem_sql);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.p_product_sql{813.3}',
  p_msg_text => p_product_sql);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.p_nat_acct_sql{813.4}',
  p_msg_text => p_nat_acct_sql);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.p_channel_sql{813.5}',
  p_msg_text => p_channel_sql);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.p_line_item_sql{813.6}',
  p_msg_text => p_line_item_sql);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.p_project_sql{813.7}',
  p_msg_text => p_project_sql);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.p_customer_sql{813.8}',
  p_msg_text => p_customer_sql);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.p_entity_sql{813.9}',
  p_msg_text => p_entity_sql);

v_status := 0;
v_message := 'Data loaded successfully';

IF (p_fetch_limit IS NOT NULL)
THEN
   v_fetch_limit := p_fetch_limit;
ELSE
   v_fetch_limit := c_fetch_limit;
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.v_fetch_limit{820}',
  p_msg_text => v_fetch_limit);

IF (p_slc_pred IS NOT NULL)
THEN
   x_select_stmt := REPLACE(p_eng_sql,'{{data_slice}}',p_slc_pred);
ELSE
   x_select_stmt := REPLACE(p_eng_sql,'{{data_slice}}','1=1');
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.x_select_stmt{821}',
  p_msg_text => x_select_stmt);

------------------------------------
-- Build Dynamic INSERT Statement --
------------------------------------
x_insert_stmt :=
   'INSERT INTO '||p_data_table||
          '(created_by_object_id,'||
          ' dataset_code,'||
          ' cal_period_id,'||
          ' source_system_code,'||
          ' ledger_id,'||
          ' company_cost_center_org_id,'||
          ' currency_code,'||
          ' financial_elem_id,'||
          ' product_id,'||
          ' natural_account_id,'||
          ' channel_id,'||
          ' line_item_id,'||
          ' project_id,'||
          ' customer_id,'||
          ' entity_id,'||
          ' geography_id,'||
          ' task_id,'||
          ' intercompany_id,'||
          ' user_dim1_id,'||
          ' user_dim2_id,'||
          ' user_dim3_id,'||
          ' user_dim4_id,'||
          ' user_dim5_id,'||
          ' user_dim6_id,'||
          ' user_dim7_id,'||
          ' user_dim8_id,'||
          ' user_dim9_id,'||
          ' user_dim10_id,'||
          ' created_by_request_id,'||
          ' last_updated_by_request_id,'||
          ' last_updated_by_object_id,'||
          ' numeric_measure,'||
          ' alphanumeric_measure,'||
          ' date_measure)'||
   ' SELECT :b_object_id,'||
          ' :b_dataset_cd,'||
          ' :b_cal_per_id,'||
          ' :b_source_cd,'||
          ' :b_ledger_id,'||
          ' :b_cctr_org_id,'||
          ' :b_currency_cd,'||
          ' :b_fin_elem_dc,'||
          ' :b_product_id,'||
          ' :b_nat_acct_id,'||
          ' :b_channel_id,'||
          ' :b_line_item_id,'||
          ' :b_project_id,'||
          ' :b_customer_id,'||
          ' :b_entity_id,'||
          ' :b_geography_id,'||
          ' :b_task_id,'||
          ' :b_interco_id,'||
          ' :b_user_dim1_id,'||
          ' :b_user_dim2_id,'||
          ' :b_user_dim3_id,'||
          ' :b_user_dim4_id,'||
          ' :b_user_dim5_id,'||
          ' :b_user_dim6_id,'||
          ' :b_user_dim7_id,'||
          ' :b_user_dim8_id,'||
          ' :b_user_dim9_id,'||
          ' :b_user_dim10_id,'||
          ' :b1_req_id,'||
          ' :b2_req_id,'||
          ' :b_object_id,'||
          ' :b_num_measure,'||
          ' :b_alpha_measure,'||
          ' :b_date_measure'||
   ' FROM dual'||
   ' WHERE :b_status = ''LOAD''';

-----------------------------------------------------------------
-- Build Dynamic UPDATE Statement to Update STATUS in FEM_DATAn_T
-- Where Rows have Invalid Dimension Values
-----------------------------------------------------------------
x_update_stmt :=
   'UPDATE '||v_data_t_table||
   ' SET status = :b1_status'||
   ' WHERE rowid = :b_rowid';

-----------------------------------------------------------------
-- Build Dynamic DELETE Statement to Delete Rows
--  from FEM_DATAn_T that were Loaded into FEM_DATAn
-----------------------------------------------------------------
x_delete_stmt :=
   'DELETE FROM '||v_data_t_table||
   ' WHERE rowid = :b_rowid'||
   ' AND   :b_status = ''LOAD''';

------------------------------
-- Loop through data slices --
------------------------------
LOOP

FEM_Multi_Proc_Pkg.Get_Data_Slice(
  x_slc_id => v_slc_id,
  x_slc_val1 => v_slc_val1,
  x_slc_val2 => v_slc_val2,
  x_slc_val3 => v_slc_val3,
  x_slc_val4 => v_slc_val4,
  x_num_vals  => v_num_vals,
  x_part_name => p_part_name,
  p_req_id => p_req_id,
  p_proc_num => p_proc_num);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_slc_id{822.1}',
  p_msg_text => v_slc_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_num_vals{822.2}',
  p_msg_text => v_num_vals);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_slc_val1{823.1}',
  p_msg_text => v_slc_val1);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_slc_val2{823.2}',
  p_msg_text => v_slc_val2);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_slc_val3{823.3}',
  p_msg_text => v_slc_val3);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_slc_val4{823.4}',
  p_msg_text => v_slc_val4);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_part_name{824}',
  p_msg_text => p_part_name);

EXIT WHEN (v_slc_id IS NULL);

IF (p_part_code > 0) AND
   (NVL(v_part_name,'null') <> NVL(v_part_name,'null'))
THEN
   v_part_name := p_part_name;
   x_select_stmt := REPLACE(x_select_stmt,'{{table_partition}}',v_part_name);
END IF;

IF (v_num_vals = 4)
THEN
   OPEN cv_get_rows FOR
      x_select_stmt
      USING v_slc_val1,v_slc_val2,v_slc_val3,v_slc_val4;
ELSIF (v_num_vals = 3)
THEN
   OPEN cv_get_rows FOR
      x_select_stmt
      USING v_slc_val1,v_slc_val2,v_slc_val3;
ELSIF (v_num_vals = 2)
THEN
   OPEN cv_get_rows FOR
      x_select_stmt
      USING v_slc_val1,v_slc_val2;
ELSIF (v_num_vals = 1)
THEN
   OPEN cv_get_rows FOR
      x_select_stmt
      USING v_slc_val1;
ELSE
   EXIT;
END IF;

---------------------------------
-- Loop through DATA_T Records --
---------------------------------
v_rows_processed := 0;
v_rows_rejected := 0;
v_rows_loaded := 0;

LOOP

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_3,
     p_module => v_block||'.Begin fetch{830}',
     p_msg_text => v_last_row);

   -------------------------------------------
   -- Bulk Fetch Rows from FEM_DATAn_T Table
   -------------------------------------------
   FETCH cv_get_rows BULK COLLECT INTO
         t_rowid,
         t_cctr_org_dc,
         t_currency_cd,
         t_fin_elem_dc,
         t_product_dc,
         t_nat_acct_dc,
         t_channel_dc,
         t_line_item_dc,
         t_project_dc,
         t_customer_dc,
         t_entity_dc,
         t_geography_dc,
         t_task_dc,
         t_interco_dc,
         t_user_dim1_dc,
         t_user_dim2_dc,
         t_user_dim3_dc,
         t_user_dim4_dc,
         t_user_dim5_dc,
         t_user_dim6_dc,
         t_user_dim7_dc,
         t_user_dim8_dc,
         t_user_dim9_dc,
         t_user_dim10_dc,
         t_num_measure,
         t_alpha_measure,
         t_date_measure,
         t_status
   LIMIT v_fetch_limit;

   v_last_row := t_status.LAST;

   IF (v_last_row IS NULL)
   THEN
      EXIT;
   END IF;

   v_rows_processed := cv_get_rows%ROWCOUNT;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.Rows this fetch{831}',
     p_msg_text => v_last_row);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.Total rows fetched{832}',
     p_msg_text => v_rows_processed);

   -------------------------------
   -- Validate Dimension Values --
   -------------------------------

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_3,
     p_module => v_block||'.Begin validation{833}',
     p_msg_text => v_last_row);

   FOR i IN 1..v_last_row
   LOOP
      t_status(i) := 'LOAD';

      IF (t_currency_cd(i) IS NOT NULL)
      THEN
         BEGIN
            SELECT currency_code
            INTO   v_varchar
            FROM   fem_currencies_vl
            WHERE  currency_code = t_currency_cd(i)
            AND    enabled_flag = 'Y';
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_CURRENCY';
               t_currency_cd(i) := '';
         END;
      ELSE
         t_currency_cd(i) := '';
      END IF;

      IF (t_cctr_org_dc(i) IS NOT NULL) AND
         (p_cctr_org_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_cctr_org_sql
            INTO  t_cctr_org_id(i)
            USING t_cctr_org_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_CCTR_ORG';
               t_cctr_org_id(i) := '';
         END;
      ELSE
         t_cctr_org_id(i) := '';
      END IF;

      IF (t_fin_elem_dc(i) IS NOT NULL) AND
         (p_fin_elem_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_fin_elem_sql
            INTO  t_fin_elem_id(i)
            USING t_fin_elem_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_FIN_ELEM';
               t_fin_elem_id(i) := '';
         END;
      ELSE
         t_fin_elem_id(i) := '';
      END IF;

      IF (t_product_dc(i) IS NOT NULL) AND
         (p_product_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_product_sql
            INTO  t_product_id(i)
            USING t_product_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_PRODUCT';
               t_product_id(i) := '';
         END;
      ELSE
         t_product_id(i) := '';
      END IF;

      IF (t_nat_acct_dc(i) IS NOT NULL) AND
         (p_nat_acct_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_nat_acct_sql
            INTO  t_nat_acct_id(i)
            USING t_nat_acct_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_NAT_ACCT';
               t_nat_acct_id(i) := '';
         END;
      ELSE
         t_nat_acct_id(i) := '';
      END IF;

      IF (t_channel_dc(i) IS NOT NULL) AND
         (p_channel_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_channel_sql
            INTO  t_channel_id(i)
            USING t_channel_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_CHANNEL';
               t_channel_id(i) := '';
         END;
      ELSE
         t_channel_id(i) := '';
      END IF;

      IF (t_line_item_dc(i) IS NOT NULL) AND
         (p_line_item_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_line_item_sql
            INTO  t_line_item_id(i)
            USING t_line_item_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_LINE_ITEM';
               t_line_item_id(i) := '';
         END;
      ELSE
         t_line_item_id(i) := '';
      END IF;

      IF (t_project_dc(i) IS NOT NULL) AND
         (p_project_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_project_sql
            INTO  t_project_id(i)
            USING t_project_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_PROJECT';
               t_project_id(i) := '';
         END;
      ELSE
         t_project_id(i) := '';
      END IF;

      IF (t_customer_dc(i) IS NOT NULL) AND
         (p_customer_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_customer_sql
            INTO  t_customer_id(i)
            USING t_customer_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_CUSTOMER';
               t_customer_id(i) := '';
         END;
      ELSE
         t_customer_id(i) := '';
      END IF;

      IF (t_entity_dc(i) IS NOT NULL) AND
         (p_entity_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_entity_sql
            INTO  t_entity_id(i)
            USING t_entity_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_ENTITY';
               t_entity_id(i) := '';
         END;
      ELSE
         t_entity_id(i) := '';
      END IF;

      IF (t_geography_dc(i) IS NOT NULL) AND
         (p_geography_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_geography_sql
            INTO  t_geography_id(i)
            USING t_geography_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_GEOGRAPHY';
               t_geography_id(i) := '';
         END;
      ELSE
         t_geography_id(i) := '';
      END IF;

      IF (t_task_dc(i) IS NOT NULL) AND
         (p_task_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_task_sql
            INTO  t_task_id(i)
            USING t_task_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_TASK';
               t_task_id(i) := '';
         END;
      ELSE
         t_task_id(i) := '';
      END IF;

      IF (t_interco_dc(i) IS NOT NULL) AND
         (p_interco_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_interco_sql
            INTO  t_interco_id(i)
            USING t_interco_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_INTERCOMPANY';
               t_interco_id(i) := '';
         END;
      ELSE
         t_interco_id(i) := '';
      END IF;

      IF (t_user_dim1_dc(i) IS NOT NULL) AND
         (p_user_dim1_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_user_dim1_sql
            INTO  t_user_dim1_id(i)
            USING t_user_dim1_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_USER_DIM1';
               t_user_dim1_id(i) := '';
         END;
      ELSE
         t_user_dim1_id(i) := '';
      END IF;

      IF (t_user_dim2_dc(i) IS NOT NULL) AND
         (p_user_dim2_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_user_dim2_sql
            INTO  t_user_dim2_id(i)
            USING t_user_dim2_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_USER_DIM2';
               t_user_dim2_id(i) := '';
         END;
      ELSE
         t_user_dim2_id(i) := '';
      END IF;

      IF (t_user_dim3_dc(i) IS NOT NULL) AND
         (p_user_dim3_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_user_dim3_sql
            INTO  t_user_dim3_id(i)
            USING t_user_dim3_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_USER_DIM3';
               t_user_dim3_id(i) := '';
         END;
      ELSE
         t_user_dim3_id(i) := '';
      END IF;

      IF (t_user_dim4_dc(i) IS NOT NULL) AND
         (p_user_dim4_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_user_dim4_sql
            INTO  t_user_dim4_id(i)
            USING t_user_dim4_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_USER_DIM4';
               t_user_dim4_id(i) := '';
         END;
      ELSE
         t_user_dim4_id(i) := '';
      END IF;

      IF (t_user_dim5_dc(i) IS NOT NULL) AND
         (p_user_dim5_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_user_dim5_sql
            INTO  t_user_dim5_id(i)
            USING t_user_dim5_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_USER_DIM5';
               t_user_dim5_id(i) := '';
         END;
      ELSE
         t_user_dim5_id(i) := '';
      END IF;

      IF (t_user_dim6_dc(i) IS NOT NULL) AND
         (p_user_dim6_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_user_dim6_sql
            INTO  t_user_dim6_id(i)
            USING t_user_dim6_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_USER_DIM6';
               t_user_dim6_id(i) := '';
         END;
      ELSE
         t_user_dim6_id(i) := '';
      END IF;

      IF (t_user_dim7_dc(i) IS NOT NULL) AND
         (p_user_dim7_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_user_dim7_sql
            INTO  t_user_dim7_id(i)
            USING t_user_dim7_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_USER_DIM7';
               t_user_dim7_id(i) := '';
         END;
      ELSE
         t_user_dim7_id(i) := '';
      END IF;

      IF (t_user_dim8_dc(i) IS NOT NULL) AND
         (p_user_dim8_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_user_dim8_sql
            INTO  t_user_dim8_id(i)
            USING t_user_dim8_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_USER_DIM8';
               t_user_dim8_id(i) := '';
         END;
      ELSE
         t_user_dim8_id(i) := '';
      END IF;

      IF (t_user_dim9_dc(i) IS NOT NULL) AND
         (p_user_dim9_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_user_dim9_sql
            INTO  t_user_dim9_id(i)
            USING t_user_dim9_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_USER_DIM9';
               t_user_dim9_id(i) := '';
         END;
      ELSE
         t_user_dim9_id(i) := '';
      END IF;

      IF (t_user_dim10_dc(i) IS NOT NULL) AND
         (p_user_dim10_sql IS NOT NULL)
      THEN
         BEGIN
            EXECUTE IMMEDIATE p_user_dim10_sql
            INTO  t_user_dim10_id(i)
            USING t_user_dim10_dc(i);
         EXCEPTION
            WHEN no_data_found THEN
               t_status(i) := 'INVALID_USER_DIM10';
               t_user_dim10_id(i) := '';
         END;
      ELSE
         t_user_dim10_id(i) := '';
      END IF;

      IF (t_status(i) <> 'LOAD')
      THEN
         v_rows_rejected := v_rows_rejected + 1;
      END IF;

   END LOOP;

   -----------------------------------------
   -- Bulk Insert Rows in FEM_DATAn table --
   -----------------------------------------

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_3,
     p_module => v_block||'.Begin bulk insert{834}',
     p_msg_text => v_last_row);

   FORALL i IN 1..v_last_row
      EXECUTE IMMEDIATE x_insert_stmt
      USING p_object_id,
            p_dataset_cd,
            p_cal_per_id,
            p_source_cd,
            p_ledger_id,
            t_cctr_org_id(i),
            t_currency_cd(i),
            t_fin_elem_id(i),
            t_product_id(i),
            t_nat_acct_id(i),
            t_channel_id(i),
            t_line_item_id(i),
            t_project_id(i),
            t_customer_id(i),
            t_entity_id(i),
            t_geography_id(i),
            t_task_id(i),
            t_interco_id(i),
            t_user_dim1_id(i),
            t_user_dim2_id(i),
            t_user_dim3_id(i),
            t_user_dim4_id(i),
            t_user_dim5_id(i),
            t_user_dim6_id(i),
            t_user_dim7_id(i),
            t_user_dim8_id(i),
            t_user_dim9_id(i),
            t_user_dim10_id(i),
            p_req_id,
            p_req_id,
            p_object_id,
            t_num_measure(i),
            t_alpha_measure(i),
            t_date_measure(i),
            t_status(i);

   -----------------------------------
   -- Update Rows in FEM_DATAn_T Table
   -----------------------------------
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_3,
     p_module => v_block||'.Begin bulk update{835}',
     p_msg_text => v_last_row);

   FORALL i IN 1..v_last_row
      EXECUTE IMMEDIATE x_update_stmt
      USING t_status(i),
            t_rowid(i);

   -------------------------------------
   -- Delete Rows from FEM_DATAn_T Table
   -------------------------------------
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_3,
     p_module => v_block||'.Begin bulk delete{836}',
     p_msg_text => v_last_row);

   FORALL i IN 1..v_last_row
      EXECUTE IMMEDIATE x_delete_stmt
      USING t_rowid(i),
            t_status(i);

   --------------------------
   -- Commit the transaaction
   --------------------------
   COMMIT;

   --------------------------------------------
   -- Delete Collections for Next Bulk Fetch --
   --------------------------------------------
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_3,
     p_module => v_block||'.Begin array delete{837}',
     p_msg_text => v_last_row);

   t_rowid.DELETE;
   t_cctr_org_dc.DELETE;
   t_currency_cd.DELETE;
   t_fin_elem_dc.DELETE;
   t_product_dc.DELETE;
   t_nat_acct_dc.DELETE;
   t_channel_dc.DELETE;
   t_line_item_dc.DELETE;
   t_project_dc.DELETE;
   t_customer_dc.DELETE;
   t_entity_dc.DELETE;
   t_geography_dc.DELETE;
   t_task_dc.DELETE;
   t_interco_dc.DELETE;
   t_user_dim1_dc.DELETE;
   t_user_dim2_dc.DELETE;
   t_user_dim3_dc.DELETE;
   t_user_dim4_dc.DELETE;
   t_user_dim5_dc.DELETE;
   t_user_dim6_dc.DELETE;
   t_user_dim7_dc.DELETE;
   t_user_dim8_dc.DELETE;
   t_user_dim9_dc.DELETE;
   t_user_dim10_dc.DELETE;
   t_num_measure.DELETE;
   t_alpha_measure.DELETE;
   t_date_measure.DELETE;
   t_status.DELETE;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_3,
     p_module => v_block||'.End fetch{838}',
     p_msg_text => v_last_row);

END LOOP;
CLOSE cv_get_rows;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.Close fetch cursor{839}',
  p_msg_text => v_rows_processed);

---------------------
-- Post Statistics --
---------------------

v_rows_loaded := v_rows_processed - v_rows_rejected;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_rows_processed{840}',
  p_msg_text => v_rows_processed);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_rows_loaded{841}',
  p_msg_text => v_rows_loaded);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_rows_rejected{842}',
  p_msg_text => v_rows_rejected);

IF (v_rows_rejected > 0)
THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_DATAX_LDR_BAD_DATA_ERR',
     p_token1 => 'COUNT',
     p_value1 => v_rows_rejected);
   v_message := FND_MSG_PUB.GET(p_encoded => c_false);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.data_errors{843}',
     p_msg_text => v_message);

   v_status := 1;
END IF;

FEM_Multi_Proc_Pkg.Post_Data_Slice(
  p_req_id => p_req_id,
  p_slc_id => v_slc_id,
  p_status => v_status,
  p_message => v_message,
  p_rows_processed => v_rows_processed,
  p_rows_loaded => v_rows_loaded,
  p_rows_rejected => v_rows_rejected);

END LOOP;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.End{844}',
  p_msg_text => 'End FEM_DATAX_LOADER.Process_Rows');

---------------------
-- Exception Block --
---------------------
EXCEPTION

WHEN others THEN
   CLOSE cv_get_rows;

   v_status := 2;
   v_message := sqlerrm;

   FEM_Multi_Proc_Pkg.Post_Data_Slice(
     p_req_id => p_req_id,
     p_slc_id => v_slc_id,
     p_status => v_status,
     p_message => v_message);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_6,
     p_module => v_block||'.Exception{845}',
     p_msg_text => sqlerrm);

   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => v_message);

END Process_Rows;

/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                          ================                               *
 *                            Post_Process                                 *
 *                          ================                               *
 *                                                                         *
 ***************************************************************************
 **************************************************************************/

PROCEDURE Post_Process
IS

v_msg_count        NUMBER;
v_msg_data         VARCHAR2(4196);
v_return_status    VARCHAR2(1);

v_block  CONSTANT  VARCHAR2(80) :=
   'fem.plsql.fem_datax_loader_pkg.post_process_rows';

BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.Begin{900}',
  p_msg_text => 'Begin FEM_DATAX_LOADER.Post_Process');
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.c_user_id{901}',
  p_msg_text => c_user_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_req_id{902}',
  p_msg_text => g_req_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_object_id{903}',
  p_msg_text => g_object_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_data_table{904}',
  p_msg_text => g_data_table);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_data_t_table{905}',
  p_msg_text => g_data_t_table);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_rows_processed{906}',
  p_msg_text => g_rows_processed);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_rows_loaded{907}',
  p_msg_text => g_rows_loaded);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_rows_rejected{908}',
  p_msg_text => g_rows_rejected);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.g_exec_status{909}',
  p_msg_text => g_exec_status);

g_rows_processed := NVL(g_rows_processed,0);
g_rows_loaded := NVL(g_rows_loaded,0);
g_rows_rejected := NVL(g_rows_rejected,0);

----------------------------
-- Register Data Location --
----------------------------
IF (g_rows_rejected = 0)
THEN
   FEM_DIMENSION_UTIL_PKG.REGISTER_DATA_LOCATION
      (p_request_id => g_req_id,
       p_object_id => g_object_id,
       p_table_name => g_data_table,
       p_ledger_id => g_ledger_id,
       p_cal_per_id => g_cal_per_id,
       p_dataset_cd => g_dataset_cd,
       p_source_cd => g_source_cd,
       p_load_status => 'COMPLETE');
END IF;

------------------------------------
-- Update Object Execution Errors --
------------------------------------
FEM_PL_PKG.Update_Obj_Exec_Errors(
  p_api_version => c_api_version,
  p_request_id => g_req_id,
  p_object_id => g_object_id,
  p_errors_reported => g_rows_rejected,
  p_errors_reprocessed => 0,
  p_user_id => c_user_id,
  p_last_update_login => null,
  x_msg_count => v_msg_count,
  x_msg_data => v_msg_data,
  x_return_status => v_return_status);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.update_obj_exec_errors.return_status{910}',
  p_msg_text => v_return_status);

Get_Put_Messages (
  p_msg_count => v_msg_count,
  p_msg_data => v_msg_data);

IF (v_return_status <> c_success)
THEN
   RAISE e_process_lock_error;
END IF;

----------------------------------
-- Update Number of Output Rows --
----------------------------------
FEM_PL_PKG.Update_Num_of_Output_Rows(
  p_api_version => c_api_version,
  p_request_id => g_req_id,
  p_object_id => g_object_id,
  p_table_name => g_data_table,
  p_statement_type => 'INSERT',
  p_num_of_output_rows => g_rows_loaded,
  p_user_id => c_user_id,
  p_last_update_login => null,
  x_msg_count => v_msg_count,
  x_msg_data => v_msg_data,
  x_return_status => v_return_status);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.update_num_of_output_rows.return_status{911}',
  p_msg_text => v_return_status);

Get_Put_Messages (
  p_msg_count => v_msg_count,
  p_msg_data => v_msg_data);

IF (v_return_status <> c_success)
THEN
   RAISE e_process_lock_error;
END IF;

------------------------------------
-- Update Object Execution Status --
------------------------------------
FEM_PL_PKG.Update_Obj_Exec_Status(
  p_api_version => c_api_version,
  p_request_id => g_req_id,
  p_object_id => g_object_id,
  p_exec_status_code => g_exec_status,
  p_user_id => c_user_id,
  p_last_update_login => null,
  x_msg_count => v_msg_count,
  x_msg_data => v_msg_data,
  x_return_status => v_return_status);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.update_obj_exec_status.return_status{912}',
  p_msg_text => v_return_status);

Get_Put_Messages (
  p_msg_count => v_msg_count,
  p_msg_data => v_msg_data);

IF (v_return_status <> c_success)
THEN
   RAISE e_process_lock_error;
END IF;

---------------------------
-- Update Request Status --
---------------------------
FEM_PL_PKG.Update_Request_Status(
  p_api_version => c_api_version,
  p_request_id => g_req_id,
  p_exec_status_code => g_exec_status,
  p_user_id => c_user_id,
  p_last_update_login => null,
  x_msg_count => v_msg_count,
  x_msg_data => v_msg_data,
  x_return_status => v_return_status);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.update_request_status.return_status{913}',
  p_msg_text => v_return_status);

Get_Put_Messages (
  p_msg_count => v_msg_count,
  p_msg_data => v_msg_data);

IF (v_return_status <> c_success)
THEN
   RAISE e_process_lock_error;
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.End{930}',
  p_msg_text => 'End FEM_DATAX_LOADER.Post_Process');

END Post_Process;

/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                          ================                               *
 *                          Get_Put_Messages                               *
 *                          ================                               *
 *                                                                         *
 ***************************************************************************
 **************************************************************************/

PROCEDURE Get_Put_Messages (
   p_msg_count       IN   NUMBER,
   p_msg_data        IN   VARCHAR2
)
IS

v_msg_count        NUMBER;
v_msg_data         VARCHAR2(4196);
v_msg_out          NUMBER;
v_message          VARCHAR2(4196);

v_block  CONSTANT  VARCHAR2(80) :=
   'fem.plsql.fem_datax_loader_pkg.get_put_messages';

BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.msg_count{920}',
  p_msg_text => p_msg_count);

v_msg_data := p_msg_data;

IF (p_msg_count = 1)
THEN
   FND_MESSAGE.Set_Encoded(v_msg_data);
   v_message := FND_MESSAGE.Get;

   FEM_ENGINES_PKG.User_Message(
     p_msg_text => v_message);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.msg_data{921}',
     p_msg_text => v_message);

ELSIF (p_msg_count > 1)
THEN
   FOR i IN 1..p_msg_count
   LOOP
      FND_MSG_PUB.Get(
      p_msg_index => i,
      p_encoded => c_false,
      p_data => v_message,
      p_msg_index_out => v_msg_out);

      FEM_ENGINES_PKG.User_Message(
        p_msg_text => v_message);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.msg_data{922}',
        p_msg_text => v_message);

   END LOOP;
END IF;

FND_MSG_PUB.Initialize;

END Get_Put_Messages;

/***************************************************************************/

END Fem_DataX_Loader_Pkg;

/
