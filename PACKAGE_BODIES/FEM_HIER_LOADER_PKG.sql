--------------------------------------------------------
--  DDL for Package Body FEM_HIER_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_HIER_LOADER_PKG" AS
/* $Header: femhierldr_phb.plb 120.7 2008/02/14 16:49:47 gcheng ship $ */


-------------------------------
-- Declare package constants --
-------------------------------
  g_object_version_number     constant number := 1;
  g_connect_by_loop           constant number := -1436;

  -- Constants for p_exec_status_code
  g_exec_status_error_rerun   constant varchar2(30) := 'ERROR_RERUN';
  g_exec_status_success       constant varchar2(30) := 'SUCCESS';

  -- Constants for p_execution_mode
  g_snapshot                  constant varchar2(1) := 'S';
  g_error_reprocessing        constant varchar2(1) := 'E';

  -- Constants for ld_load_type
  g_new_hier                  constant varchar2(30) := 'NEW_HIER';
  g_new_hier_def              constant varchar2(30) := 'NEW_HIER_DEF';
  g_update_hier_def           constant varchar2(30) := 'UPDATE_HIER_DEF';

  g_default_fetch_limit       constant number := 99999;

  g_log_level_1               constant number := fnd_log.level_statement;
  g_log_level_2               constant number := fnd_log.level_procedure;
  g_log_level_3               constant number := fnd_log.level_event;
  g_log_level_4               constant number := fnd_log.level_exception;
  g_log_level_5               constant number := fnd_log.level_error;
  g_log_level_6               constant number := fnd_log.level_unexpected;


------------------------------
-- Declare package messages --
------------------------------
  G_UNEXPECTED_ERROR           constant varchar2(30) := 'FEM_UNEXPECTED_ERROR';
  G_DIM_NOT_FOUND_ERR          constant varchar2(30) := 'FEM_DIM_NOT_FOUND';
  G_PL_REG_REQUEST_ERR         constant varchar2(30) := 'FEM_PL_REG_REQUEST_ERR';
  G_PL_OBJ_EXEC_LOCK_ERR       constant varchar2(30) := 'FEM_PL_OBJ_EXEC_LOCK_ERR';
  G_PL_OBJ_EXECLOCK_EXISTS_ERR constant varchar2(30) := 'FEM_PL_OBJ_EXECLOCK_EXISTS_ERR';
  G_EXEC_RERUN                 constant varchar2(30) := 'FEM_EXEC_RERUN';
  G_EXEC_SUCCESS               constant varchar2(30) := 'FEM_EXEC_SUCCESS';
  G_EXEC_NO_FOLDER_ACCESS_ERR  constant varchar2(30) := 'FEM_EXEC_NO_FOLDER_ACCESS_ERR';
  G_EXT_LDR_POST_PROC_ERR      constant varchar2(30) := 'FEM_EXT_LDR_POST_PROC_ERR';
  G_EXT_LDR_BAD_LDR_OBJ_ERR    constant varchar2(30) := 'FEM_EXT_LDR_BAD_LDR_OBJ_ERR';
  G_EXT_LDR_EXEC_MODE_ERR      constant varchar2(30) := 'FEM_EXT_LDR_EXEC_MODE_ERR';
  G_EXT_LDR_INV_MEMBER_ERR     constant varchar2(30) := 'FEM_EXT_LDR_INV_MEMBER_ERR';
  G_EXT_LDR_INV_DIM_GRP_ERR    constant varchar2(30) := 'FEM_EXT_LDR_INV_DIM_GRP_ERR';
  G_EXT_LDR_INV_VALUE_SET_ERR  constant varchar2(30) := 'FEM_EXT_LDR_INV_VALUE_SET_ERR';
  G_HIER_LDR_MULTI_PARENT_ERR  constant varchar2(30) := 'FEM_HIER_LDR_MULTI_PARENT_ERR';
  G_HIER_LDR_INV_ROOT_NODE_ERR constant varchar2(30) := 'FEM_HIER_LDR_INV_ROOT_NODE_ERR';
  G_HIER_LDR_MULTI_TOP_ERR     constant varchar2(30) := 'FEM_HIER_LDR_MULTI_TOP_ERR';
  G_HIER_LDR_GRP_SEQ_RULE_ERR  constant varchar2(30) := 'FEM_HIER_LDR_GRP_SEQ_RULE_ERR';
  G_HIER_LDR_INV_HIER_ERR      constant varchar2(30) := 'FEM_HIER_LDR_INV_HIER_ERR';
  G_HIER_LDR_CIRC_HIER_ERR     constant varchar2(30) := 'FEM_HIER_LDR_CIRC_HIER_ERR';
  G_HIER_LDR_RECON_LEAF_ERR    constant varchar2(30) := 'FEM_HIER_LDR_RECON_LEAF_ERR';
  G_HIER_LDR_RECON_NODE_ERR    constant varchar2(30) := 'FEM_HIER_LDR_RECON_NODE_ERR';
  G_HIER_LDR_INV_CALENDAR_ERR  constant varchar2(30) := 'FEM_HIER_LDR_INV_CALENDAR_ERR';
  G_HIER_LDR_MULTI_VS_ERR      constant varchar2(30) := 'FEM_HIER_LDR_MULTI_VS_ERR';
  G_HIER_LDR_DIM_GRPS_REQ_ERR  constant varchar2(30) := 'FEM_HIER_LDR_DIM_GRPS_REQ_ERR';
  G_HIER_LDR_MISSING_ROOT_ERR  constant varchar2(30) := 'FEM_HIER_LDR_MISSING_ROOT_ERR';
  G_HIER_LDR_NO_HIER_ERR       constant varchar2(30) := 'FEM_HIER_LDR_NO_HIER_ERR';
  G_HIER_LDR_MULTI_HIER_ERR    constant varchar2(30) := 'FEM_HIER_LDR_MULTI_HIER_ERR';
  G_HIER_LDR_FOLDER_ERR        constant varchar2(30) := 'FEM_HIER_LDR_FOLDER_ERR';
  G_HIER_LDR_EFF_DATE_RANG_ERR constant varchar2(30) := 'FEM_HIER_LDR_EFF_DATE_RANG_ERR';
  G_HIER_LDR_EFF_DATE_OVLP_ERR constant varchar2(30) := 'FEM_HIER_LDR_EFF_DATE_OVLP_ERR';
  G_HIER_LDR_DEF_DATA_LOCK_ERR constant varchar2(30) := 'FEM_HIER_LDR_DEF_DATA_LOCK_ERR';
  G_HIER_LDR_DEF_DATA_RANG_ERR constant varchar2(30) := 'FEM_HIER_LDR_DEF_DATA_RANG_ERR';
  G_HIER_LDR_HIER_TYPE_CD_ERR  constant varchar2(30) := 'FEM_HIER_LDR_HIER_TYPE_CD_ERR';
  G_HIER_LDR_HIER_USG_CD_ERR   constant varchar2(30) := 'FEM_HIER_LDR_HIER_USG_CD_ERR';
  G_HIER_LDR_GRP_SQ_ENF_CD_ERR constant varchar2(30) := 'FEM_HIER_LDR_GRP_SQ_ENF_CD_ERR';
  G_HIER_LDR_GRP_SQ_REQ_ERR    constant varchar2(30) := 'FEM_HIER_LDR_GRP_SQ_REQ_ERR';
  G_HIER_LDR_MULTI_TOP_FLG_ERR constant varchar2(30) := 'FEM_HIER_LDR_MULTI_TOP_FLG_ERR';
  G_HIER_LDR_MULTI_VS_FLG_ERR  constant varchar2(30) := 'FEM_HIER_LDR_MULTI_VS_FLG_ERR';
  G_HIER_LDR_FLAT_ROWS_FLG_ERR constant varchar2(30) := 'FEM_HIER_LDR_FLAT_ROWS_FLG_ERR';
  G_HIER_LDR_CALENDAR_ERR      constant varchar2(30) := 'FEM_HIER_LDR_CALENDAR_ERR';
  G_HIER_LDR_NO_HIER_VS_ERR    constant varchar2(30) := 'FEM_HIER_LDR_NO_HIER_VS_ERR';
  G_HIER_LDR_HIER_DETAILS_ERR  constant varchar2(30) := 'FEM_HIER_LDR_HIER_DETAILS_ERR';
  G_HIER_LDR_HIER_FLATTEN_ERR  constant varchar2(30) := 'FEM_HIER_LDR_HIER_FLATTEN_ERR';
  G_HIER_LDR_NO_LEAF_ATTR_ERR  constant varchar2(30) := 'FEM_HIER_LDR_NO_LEAF_ATTR_ERR';
  G_HIER_LDR_READONLY_HIER_ERR constant varchar2(30) := 'FEM_HIER_LDR_READONLY_HIER_ERR';
  G_HIER_LDR_GRP_SQ_VAL_ERR    constant varchar2(30) := 'FEM_HIER_LDR_GRP_SQ_VAL_ERR';
  G_HIER_LDR_MULT_VS_FLG_V_ERR constant varchar2(30) := 'FEM_HIER_LDR_MULT_VS_FLG_V_ERR';
  G_HIER_LDR_HIER_TYPE_VAL_ERR constant varchar2(30) := 'FEM_HIER_LDR_HIER_TYPE_VAL_ERR';


--------------------------------------
-- Declare package type definitions --
--------------------------------------
  t_return_status             varchar2(1);
  t_msg_count                 number;
  t_msg_data                  varchar2(2000);


-------------------------------
-- Declare package variables --
-------------------------------
  -- Exception variables
  gv_prg_msg                  varchar2(2000);
  gv_callstack                varchar2(2000);

  -- Bulk Fetch Limit
  gv_fetch_limit              number;

  -- Default Effective Start and End dates
  gv_default_start_date       date;
  gv_default_end_date         date;


-----------------------------------------------
-- Declare private procedures and functions --
-----------------------------------------------
PROCEDURE get_dimension_info (
  p_dimension_varchar_label      in varchar2
  ,x_dimension_id                out nocopy number
  ,x_target_hier_table           out nocopy varchar2
  ,x_source_hier_table           out nocopy varchar2
  ,x_member_b_table              out nocopy varchar2
  ,x_member_attr_table           out nocopy varchar2
  ,x_member_col                  out nocopy varchar2
  ,x_member_dc_col               out nocopy varchar2
  ,x_group_use_code              out nocopy varchar2
  ,x_value_set_required_flag     out nocopy varchar2
  ,x_hier_type_allowed_code      out nocopy varchar2
  ,x_hier_versioning_type_code   out nocopy varchar2
);

PROCEDURE register_process_execution (
  p_request_id                   in number
  ,p_object_id                   in number
  ,p_obj_def_id                  in number
  ,p_execution_mode              in varchar
  ,p_user_id                     in number
  ,p_login_id                    in number
  ,p_pgm_id                      in number
  ,p_pgm_app_id                  in number
  ,p_hierarchy_object_name       in varchar2
);

PROCEDURE eng_master_post_proc (
  p_request_id                   in number
  ,p_object_id                   in number
  ,p_exec_status_code            in varchar2
  ,p_user_id                     in number
  ,p_login_id                    in number
  ,p_dimension_varchar_label     in varchar2
  ,p_execution_mode              in varchar2
  ,p_target_hierval_table        in varchar2
);

PROCEDURE get_put_messages (
  p_msg_count                    in number
  ,p_msg_data                    in varchar2
);

FUNCTION get_default_start_date
RETURN date;

FUNCTION get_default_end_date
RETURN date;

PROCEDURE set_hier_table_err_msg (
  p_hier_table_name              in varchar2
  ,p_status                    in varchar2
);

PROCEDURE bld_bad_value_sets_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,x_bad_value_sets_stmt         out nocopy varchar2
);

PROCEDURE bld_bad_dim_groups_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,x_bad_dim_groups_stmt         out nocopy varchar2
);

PROCEDURE bld_bad_hier_calendars_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_source_hier_table           in varchar2
  ,x_bad_hier_calendars_stmt     out nocopy varchar2
);

PROCEDURE bld_bad_hier_value_sets_t_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,x_bad_hier_value_sets_t_stmt  out nocopy varchar2
);

PROCEDURE bld_bad_hier_value_sets_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,x_bad_hier_value_sets_stmt    out nocopy varchar2
);

PROCEDURE bld_bad_hier_multi_vs_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,x_bad_hier_multi_vs_stmt      out nocopy varchar2
);

PROCEDURE bld_bad_hier_members_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,p_member_b_table              in varchar2
  ,p_member_col                  in varchar2
  ,p_member_dc_col               in varchar2
  ,x_bad_hier_members_stmt       out nocopy varchar2
);

PROCEDURE bld_bad_hier_dups_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,x_bad_hier_dups_stmt          out nocopy varchar2
);

PROCEDURE bld_bad_hier_rec_leafs_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_target_hierval_table        in varchar2
  ,p_member_attr_table           in varchar2
  ,p_member_col                  in varchar2
  ,x_bad_hier_rec_leafs_stmt     out nocopy varchar2
);

PROCEDURE bld_bad_hier_rec_nodes_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_target_hierval_table        in varchar2
  ,p_member_attr_table           in varchar2
  ,p_member_col                  in varchar2
  ,x_bad_hier_rec_nodes_stmt     out nocopy varchar2
);

PROCEDURE bld_bad_hier_roots_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,p_member_b_table              in varchar2
  ,p_member_col                  in varchar2
  ,p_member_dc_col               in varchar2
  ,x_bad_hier_roots_stmt         out nocopy varchar2
);

PROCEDURE bld_bad_hier_dim_groups_t_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_target_hierval_table        in varchar2
  ,x_bad_hier_dim_groups_t_stmt  out nocopy varchar2
);

PROCEDURE bld_bad_hier_dim_groups_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_target_hierval_table        in varchar2
  ,x_bad_hier_dim_groups_stmt    out nocopy varchar2
);

PROCEDURE bld_bad_hier_dim_grp_skp_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_target_hierval_table        in varchar2
  ,x_bad_hier_dim_grp_skp_stmt   out nocopy varchar2
);

PROCEDURE bld_bad_hier_dim_grp_reg_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_target_hierval_table        in varchar2
  ,x_bad_hier_dim_grp_reg_stmt   out nocopy varchar2
);

PROCEDURE bld_root_node_count_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,x_root_node_count_stmt        out nocopy varchar2
);

PROCEDURE bld_get_value_sets_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,x_get_value_sets_stmt         out nocopy varchar2
);

PROCEDURE bld_get_dim_groups_t_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,x_get_dim_groups_t_stmt       out nocopy varchar2
);

PROCEDURE bld_get_dim_groups_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,x_get_dim_groups_stmt         out nocopy varchar2
);

PROCEDURE bld_get_hier_defs_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,x_get_hier_defs_stmt          out nocopy varchar2
);

PROCEDURE bld_get_hier_roots_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_group_use_code              in varchar2
  ,p_source_hier_table           in varchar2
  ,p_member_b_table              in varchar2
  ,p_member_col                  in varchar2
  ,p_member_dc_col               in varchar2
  ,x_get_hier_roots_stmt         out nocopy varchar2
);

PROCEDURE bld_get_hier_rels_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_group_use_code              in varchar2
  ,p_source_hier_table           in varchar2
  ,p_member_b_table              in varchar2
  ,p_member_col                  in varchar2
  ,p_member_dc_col               in varchar2
  ,x_get_hier_rels_stmt          out nocopy varchar2
);

PROCEDURE bld_insert_hier_rels_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_target_hier_table           in varchar2
  ,p_target_hierval_table        in varchar2
  ,x_insert_hier_rels_stmt       out nocopy varchar2
);

PROCEDURE bld_delete_hier_rels_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_source_hier_table           in varchar2 := null
  ,p_target_hier_table           in varchar2 := null
  ,p_target_hierval_table        in varchar2 := null
  ,x_delete_hier_rels_stmt       out nocopy varchar2
);

PROCEDURE bld_insert_hierval_rels_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_target_hierval_table        in varchar2
  ,x_insert_hierval_rels_stmt    out nocopy varchar2
);

FUNCTION bld_update_status_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2 := null
  ,p_source_hier_table           in varchar2
  ,p_rowid_flag                  in varchar2 := null
  ,p_hier_object_name_flag       in varchar2 := null
  ,p_hier_obj_def_name_flag      in varchar2 := null
  ,p_parent_flag                 in varchar2 := null
  ,p_child_flag                  in varchar2 := null
)
RETURN varchar2;


-----------------------------------------------------------------------------
--  Package bodies for functions/procedures
-----------------------------------------------------------------------------

/*===========================================================================+
 | PROCEDURE
 |              Main
 |
 | DESCRIPTION
 |              Main engine procedure for loading dimension hierarchies
 |              into FEM
 |
 | SCOPE - PUBLIC
 |
 | MODIFICATION HISTORY
 |    nmartine   24-NOV-2003  Created
 |
 +===========================================================================*/

PROCEDURE Main (
  errbuf                        out nocopy varchar2
  ,retcode                      out nocopy varchar2
  ,p_object_definition_id       in number
  ,p_execution_mode             in varchar2
  ,p_dimension_varchar_label    in varchar2
  ,p_hierarchy_object_name      in varchar2
  ,p_hier_obj_def_display_name  in varchar2
)
IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name               constant varchar2(30) := 'Main';

  -----------------------
  -- Declare variables --
  -----------------------

  ----------------------------
  -- Common abbreviations:
  ----------------------------
  -- dc = display_code
  -- _t = interface table
  -- source = interface table
  -- target = FEM table
  ----------------------------

  -- Rowid parameter for PKG API's used when inserting rows.
  l_rowid                           rowid;

  -- Concurrent Request Parameters
  l_user_id                         number;
  l_login_id                        number;
  l_request_id                      number;
  l_pgm_id                          number;
  l_pgm_app_id                      number;

  -- Hierarchy Loader Object ID and Object Definition ID
  l_loader_object_id                number;
  l_loader_obj_def_id               number;
  l_loader_folder_name              varchar2(150);

  -- FEM_HIERARCHIES_T Parameters and their corresponding ID values
  ld_rowid                          rowid;
  ld_hierarchy_object_id            number;
  ld_hier_obj_def_id                number;
  ld_folder_id                      number;
  ld_value_set_id                   number;
  ld_calendar_id                    number;
  ld_effective_start_date           date;
  ld_effective_end_date             date;
  ld_status                         varchar2(30);
  ld_dimension_varchar_label        varchar2(30);
  ld_hierarchy_type_code            varchar2(30);
  ld_group_seq_enforced_code        varchar2(30);
  ld_hierarchy_usage_code           varchar2(30);
  ld_load_type                      varchar2(30);
  ld_folder_name                    varchar2(150); -- bug#3657227
  ld_hierarchy_object_name          varchar2(150);
  ld_hier_obj_def_display_name      varchar2(150);
  ld_calendar_dc                    varchar2(150);
  ld_multi_top_flag                 varchar2(1);
  ld_multi_value_set_flag           varchar2(1);
  ld_flattened_rows_flag            varchar2(1);
  ld_language                       varchar2(4);

  -- Helper parameters for specific validation queries
  l_count                           number;
  l_vs_count                        number;
  l_num_roots                       number;

  l_attribute_id                    number;
  l_attr_version_id                 number;

  l_max_object_definition_id        number;
  l_new_max_obj_def_id              number;

  l_dummy                           number;
  l_sql_err_code                    number;

  l_max_effective_start_date        date;
  l_max_effective_end_date          date;
  l_new_max_eff_end_date            date;
  l_current_date                    date;

  l_completion_status               boolean;
  l_hierarchy_error_flag            boolean;

  l_date_incl_rslt_data             varchar2(1);
  l_approval_edit_lock_exists       varchar2(1);
  l_data_edit_lock_exists           varchar2(1);

  -- These variables are retrieved as part of GET_DIMENSION_INFO
  l_dimension_id                    number;
  l_target_hier_table               varchar2(30);
  l_source_hier_table               varchar2(30);
  l_member_b_table                  varchar2(30);
  l_member_attr_table               varchar2(30);
  l_member_col                      varchar2(30);
  l_member_dc_col                   varchar2(30);
  l_group_use_code                  varchar2(30);
  l_value_set_required_flag         varchar2(1);
  l_hier_type_allowed_code          varchar2(30);
  l_hier_versioning_type_code       varchar2(30);

  -- Variable to store the HIERVAL table.
  l_target_hierval_table            varchar2(30);

  -- Variables storing return status, message count, and message data for
  -- internal procedure calls
  l_return_status                   t_return_status%TYPE;
  l_msg_count                       t_msg_count%TYPE;
  l_msg_data                        t_msg_data%TYPE;

  -- Dynamic SQL: statement variables
  l_bad_value_sets_stmt             varchar2(10000);
  l_bad_dim_groups_stmt             varchar2(10000);
  l_bad_hier_calendars_stmt         varchar2(10000);
  l_bad_hier_value_sets_t_stmt      varchar2(10000);
  l_bad_hier_value_sets_stmt        varchar2(10000);
  l_bad_hier_multi_vs_stmt          varchar2(10000);
  l_bad_hier_members_stmt           varchar2(10000);
  l_bad_hier_dups_stmt              varchar2(10000);
  l_bad_hier_rec_leafs_stmt         varchar2(10000);
  l_bad_hier_rec_nodes_stmt         varchar2(10000);
  l_bad_hier_roots_stmt             varchar2(10000);
  l_bad_hier_dim_groups_t_stmt      varchar2(10000);
  l_bad_hier_dim_groups_stmt        varchar2(10000);
  l_bad_hier_dim_grp_skp_stmt       varchar2(10000);
  l_bad_hier_dim_grp_reg_stmt       varchar2(10000);
  l_root_node_count_stmt            varchar2(10000);
  l_get_value_sets_stmt             varchar2(10000);
  l_get_dim_groups_t_stmt           varchar2(10000);
  l_get_dim_groups_stmt             varchar2(10000);
  l_get_hier_defs_stmt              varchar2(10000);
  l_get_hier_roots_stmt             varchar2(10000);
  l_get_hier_rels_stmt              varchar2(10000);
  l_insert_hier_rels_stmt           varchar2(10000);
  l_delete_hier_t_rels_stmt         varchar2(10000);
  l_delete_hier_rels_stmt           varchar2(10000);
  l_insert_hierval_rels_stmt        varchar2(10000);

  -- Dynamic SQL: STATUS column where clause
  l_status_clause    varchar2(100) := '';


  -------------------------------------
  -- Declare bulk collection columns --
  -------------------------------------

  ------------------------------------------------
  -- Common abbreviations:
  ------------------------------------------------
  --   t_ = array of FEM_HIERARCHY_T rows
  --   tg_ = array of FEM_HIER_DIM_GRPS_T rows
  --   tv_ = array of FEM_HIER_VALUES_SETS_T rows
  --   th_ = array of FEM_xName_HIER_T rows
  ------------------------------------------------

  tg_rowid                          rowid_type;
  tv_rowid                          rowid_type;
  th_rowid                          rowid_type;

  tg_dimension_group_id             number_type;
  tg_relative_dim_group_seq         number_type;
  tg_depth_num                      number_type;

  tv_value_set_id                   number_type;

  th_parent_depth_num               number_type;
  th_parent_id                      number_type;
  th_parent_value_set_id            number_type;
  th_parent_cal_period_number       number_type;
  th_parent_dimension_grp_id        number_type;
  th_child_depth_num                number_type;
  th_child_id                       number_type;
  th_child_value_set_id             number_type;
  th_child_cal_period_number        number_type;
  th_child_dimension_grp_id         number_type;
  th_display_order_num              number_type;

  th_wt_pct                         pct_type;

  th_parent_cal_period_end_date     date_type;
  th_child_cal_period_end_date      date_type;

  tg_status                         varchar2_std_type;
  tv_status                         varchar2_std_type;
  th_status                         varchar2_std_type;

  th_parent_dc                      varchar2_150_type;
  th_parent_value_set_dc            varchar2_150_type;
  th_parent_dim_grp_dc              varchar2_150_type;
  th_child_dc                       varchar2_150_type;
  th_child_value_set_dc             varchar2_150_type;
  th_child_dim_grp_dc               varchar2_150_type;

  -----------------------------
  -- Declare dynamic cursors --
  -----------------------------
  cv_bad_value_sets                 cv_curs;
  cv_bad_dim_groups                 cv_curs;
  cv_bad_hier_calendars             cv_curs;
  cv_bad_hier_value_sets            cv_curs;
  cv_bad_hier_members               cv_curs;
  cv_bad_hier_dups                  cv_curs;
  cv_bad_hier_rec_leafs             cv_curs;
  cv_bad_hier_rec_nodes             cv_curs;
  cv_bad_hier_roots                 cv_curs;
  cv_bad_hier_dim_groups            cv_curs;
  cv_bad_hier_dim_grp_sq            cv_curs;
  cv_get_value_sets                 cv_curs;
  cv_get_dim_groups                 cv_curs;
  cv_get_hier_defs                  cv_curs;
  cv_get_hier_roots                 cv_curs;
  cv_get_hier_rels                  cv_curs;

  ----------------------------
  -- Declare static cursors --
  ----------------------------


  -----------------------------------------------------------
  -- Declare flags to keep track of which cursors are open --
  -----------------------------------------------------------
  l_bad_value_sets_is_open          boolean := false;
  l_bad_dim_groups_is_open          boolean := false;
  l_bad_hier_calendars_is_open      boolean := false;
  l_bad_hier_value_sets_is_open     boolean := false;
  l_bad_hier_members_is_open        boolean := false;
  l_bad_hier_dups_is_open           boolean := false;
  l_bad_hier_rec_leafs_is_open      boolean := false;
  l_bad_hier_rec_nodes_is_open      boolean := false;
  l_bad_hier_roots_is_open          boolean := false;
  l_bad_hier_dim_groups_is_open     boolean := false;
  l_bad_hier_dim_grp_sq_is_open     boolean := false;
  l_get_value_sets_is_open          boolean := false;
  l_get_dim_groups_is_open          boolean := false;
  l_get_hier_defs_is_open           boolean := false;
  l_get_hier_roots_is_open          boolean := false;
  l_get_hier_rels_is_open           boolean := false;

  -----------------------------------------------------------
  -- Index indicating last row number for a cursor.
  -----------------------------------------------------------
  l_bad_value_sets_last_row         number := 0;
  l_bad_dim_groups_last_row         number := 0;
  l_bad_hier_calendars_last_row     number := 0;
  l_bad_hier_value_sets_last_row    number := 0;
  l_bad_hier_members_last_row       number := 0;
  l_bad_hier_dups_last_row          number := 0;
  l_bad_hier_rec_leafs_last_row     number := 0;
  l_bad_hier_rec_nodes_last_row     number := 0;
  l_bad_hier_roots_last_row         number := 0;
  l_bad_hier_dim_groups_last_row    number := 0;
  l_bad_hier_dim_grp_sq_last_row    number := 0;
  l_get_value_sets_last_row         number := 0;
  l_get_dim_groups_last_row         number := 0;
  l_get_hier_roots_last_row         number := 0;
  l_get_hier_rels_last_row          number := 0;



/**************************************************************************
*                                                                         *
*                          Load Dim Hierarchies                           *
*                          Execution Block                                *
*                                                                         *
**************************************************************************/

BEGIN

  -- Necessary defaulting of loader object definition id as OA Fwk cannot
  -- handle defaults in the concurrent program registration.
  l_loader_obj_def_id := p_object_definition_id;
  if (l_loader_obj_def_id is null) then
    l_loader_obj_def_id := 1400;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  FND_MSG_PUB.Initialize;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text =>
      ' p_execution_mode='||p_execution_mode||
      ' p_object_definition_id='||p_object_definition_id||
      ' p_dimension_varchar_label='||p_dimension_varchar_label||
      ' p_hierarchy_object_name='||p_hierarchy_object_name||
      ' p_hier_obj_def_display_name='||p_hier_obj_def_display_name
  );

  -- Get all Global Parameters
  l_user_id := FND_GLOBAL.user_id;
  l_login_id := FND_GLOBAL.login_id;
  l_request_id := FND_GLOBAL.conc_request_id;
  l_pgm_id := FND_GLOBAL.conc_program_id;
  l_pgm_app_id := FND_GLOBAL.prog_appl_id;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text =>
      ' l_user_id='||l_user_id||
      ' l_login_id='||l_login_id||
      ' l_request_id='||l_request_id||
      ' l_pgm_id='||l_pgm_id||
      ' l_pgm_app_id='||l_pgm_app_id
  );

   -- Get the limit for bulk fetches
  gv_fetch_limit :=
    nvl(FND_PROFILE.value_specific('FEM_BULK_FETCH_LIMIT',l_user_id,null,null)
        ,g_default_fetch_limit);

  ------------------------------------------------------------------------------
  -- Get the object id for the specified object definition id.  Needed for
  -- process locking.
  ------------------------------------------------------------------------------
  begin
    select object_id
    into l_loader_object_id
    from fem_object_definition_b
    where object_definition_id = l_loader_obj_def_id
    and object_id in (
      select object_id
      from fem_object_catalog_b
      where object_type_code = 'HIERARCHY_LOADER'
    );
  exception
    when no_data_found then
      l_loader_object_id := 1400;
    when others then
      FEM_ENGINES_PKG.user_message (
        p_app_name  => G_FEM
        ,p_msg_name => G_EXT_LDR_BAD_LDR_OBJ_ERR
        ,p_token1   => 'OBJECT_DEFINITION_ID'
        ,p_value1   => l_loader_obj_def_id
      );
      raise e_loader_error;
  end;

  ------------------------------------------------------------------------------
  -- Check to see if the user can execute the hier loader.  In FEM.D, if a user
  -- can read a rule, then they can execute a rule.
  ------------------------------------------------------------------------------
  select count(*)
  into l_count
  from fem_object_catalog_b o
  ,fem_user_folders u
  where o.object_id = l_loader_object_id
  and u.folder_id = o.folder_id
  and u.user_id = l_user_id;

  if (l_count = 0) then

    select f.folder_name
    into l_loader_folder_name
    from fem_folders_vl f
    ,fem_object_catalog_b o
    where o.object_id = l_loader_object_id
    and f.folder_id = o.folder_id;

    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_EXEC_NO_FOLDER_ACCESS_ERR
      ,p_token1   => 'FOLDER_NAME'
      ,p_value1   => l_loader_folder_name
    );
    raise e_loader_error;

  end if;

  ------------------------------------------------------------------------------
  -- Validate the execution mode input parameter.
  ------------------------------------------------------------------------------
  if p_execution_mode not in (g_snapshot,g_error_reprocessing) then
    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_EXT_LDR_EXEC_MODE_ERR
    );
    raise e_loader_error;
  end if;

  ------------------------------------------------------------------------------
  -- Validate the Dimension input parameter and get the source and target
  -- hierarchy table names and other hierarchy information
  ------------------------------------------------------------------------------
  get_dimension_info (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,x_dimension_id                => l_dimension_id
    ,x_target_hier_table           => l_target_hier_table
    ,x_source_hier_table           => l_source_hier_table
    ,x_member_b_table              => l_member_b_table
    ,x_member_attr_table           => l_member_attr_table
    ,x_member_col                  => l_member_col
    ,x_member_dc_col               => l_member_dc_col
    ,x_group_use_code              => l_group_use_code
    ,x_value_set_required_flag     => l_value_set_required_flag
    ,x_hier_type_allowed_code      => l_hier_type_allowed_code
    ,x_hier_versioning_type_code   => l_hier_versioning_type_code
  );

  -- If execution mode is Snapshot, then we must add the status where clause
  -- to all queries on interface tables.
  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and status = ''LOAD''';
  end if;

  bld_bad_value_sets_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_value_set_required_flag     => l_value_set_required_flag
    ,x_bad_value_sets_stmt         => l_bad_value_sets_stmt
  );

  bld_bad_dim_groups_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,x_bad_dim_groups_stmt         => l_bad_dim_groups_stmt
  );

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    bld_bad_hier_calendars_stmt (
      p_dimension_varchar_label      => p_dimension_varchar_label
      ,p_execution_mode              => p_execution_mode
      ,p_source_hier_table           => l_source_hier_table
      ,x_bad_hier_calendars_stmt     => l_bad_hier_calendars_stmt
    );

    -- HIERVAL table for the CAL_PERIOD dimension
    l_target_hierval_table := 'FEM_HIERVAL_CALP_T';

  else

    -- HIERVAL table for all VSR dimensions
    l_target_hierval_table := 'FEM_HIERVAL_VSR_T';

  end if;

  bld_bad_hier_value_sets_t_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_value_set_required_flag     => l_value_set_required_flag
    ,p_source_hier_table           => l_source_hier_table
    ,x_bad_hier_value_sets_t_stmt  => l_bad_hier_value_sets_t_stmt
  );

  bld_bad_hier_value_sets_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_value_set_required_flag     => l_value_set_required_flag
    ,p_source_hier_table           => l_source_hier_table
    ,x_bad_hier_value_sets_stmt    => l_bad_hier_value_sets_stmt
  );

  bld_bad_hier_multi_vs_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_value_set_required_flag     => l_value_set_required_flag
    ,p_source_hier_table           => l_source_hier_table
    ,x_bad_hier_multi_vs_stmt      => l_bad_hier_multi_vs_stmt
  );

  bld_bad_hier_members_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_value_set_required_flag     => l_value_set_required_flag
    ,p_source_hier_table           => l_source_hier_table
    ,p_member_b_table              => l_member_b_table
    ,p_member_col                  => l_member_col
    ,p_member_dc_col               => l_member_dc_col
    ,x_bad_hier_members_stmt       => l_bad_hier_members_stmt
  );

  bld_bad_hier_dups_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_value_set_required_flag     => l_value_set_required_flag
    ,p_source_hier_table           => l_source_hier_table
    ,x_bad_hier_dups_stmt          => l_bad_hier_dups_stmt
  );

  bld_bad_hier_rec_leafs_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_target_hierval_table        => l_target_hierval_table
    ,p_member_attr_table           => l_member_attr_table
    ,p_member_col                  => l_member_col
    ,x_bad_hier_rec_leafs_stmt     => l_bad_hier_rec_leafs_stmt
  );

  bld_bad_hier_rec_nodes_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_target_hierval_table        => l_target_hierval_table
    ,p_member_attr_table           => l_member_attr_table
    ,p_member_col                  => l_member_col
    ,x_bad_hier_rec_nodes_stmt     => l_bad_hier_rec_nodes_stmt
  );

  bld_bad_hier_roots_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_value_set_required_flag     => l_value_set_required_flag
    ,p_source_hier_table           => l_source_hier_table
    ,p_member_b_table              => l_member_b_table
    ,p_member_col                  => l_member_col
    ,p_member_dc_col               => l_member_dc_col
    ,x_bad_hier_roots_stmt         => l_bad_hier_roots_stmt
  );

  bld_bad_hier_dim_groups_t_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_target_hierval_table        => l_target_hierval_table
    ,x_bad_hier_dim_groups_t_stmt  => l_bad_hier_dim_groups_t_stmt
  );

  bld_bad_hier_dim_groups_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_target_hierval_table        => l_target_hierval_table
    ,x_bad_hier_dim_groups_stmt    => l_bad_hier_dim_groups_stmt
  );

  bld_bad_hier_dim_grp_skp_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_target_hierval_table        => l_target_hierval_table
    ,x_bad_hier_dim_grp_skp_stmt   => l_bad_hier_dim_grp_skp_stmt
  );

  bld_bad_hier_dim_grp_reg_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_target_hierval_table        => l_target_hierval_table
    ,x_bad_hier_dim_grp_reg_stmt   => l_bad_hier_dim_grp_reg_stmt
  );

  bld_root_node_count_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_value_set_required_flag     => l_value_set_required_flag
    ,p_source_hier_table           => l_source_hier_table
    ,x_root_node_count_stmt        => l_root_node_count_stmt
  );

  bld_get_value_sets_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_value_set_required_flag     => l_value_set_required_flag
    ,x_get_value_sets_stmt         => l_get_value_sets_stmt
  );

  bld_get_dim_groups_t_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,x_get_dim_groups_t_stmt       => l_get_dim_groups_t_stmt
  );

  bld_get_dim_groups_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,x_get_dim_groups_stmt         => l_get_dim_groups_stmt
  );

  bld_get_hier_defs_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,x_get_hier_defs_stmt          => l_get_hier_defs_stmt
  );

  bld_get_hier_roots_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_value_set_required_flag     => l_value_set_required_flag
    ,p_group_use_code              => l_group_use_code
    ,p_source_hier_table           => l_source_hier_table
    ,p_member_b_table              => l_member_b_table
    ,p_member_col                  => l_member_col
    ,p_member_dc_col               => l_member_dc_col
    ,x_get_hier_roots_stmt         => l_get_hier_roots_stmt
  );

  bld_get_hier_rels_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_value_set_required_flag     => l_value_set_required_flag
    ,p_group_use_code              => l_group_use_code
    ,p_source_hier_table           => l_source_hier_table
    ,p_member_b_table              => l_member_b_table
    ,p_member_col                  => l_member_col
    ,p_member_dc_col               => l_member_dc_col
    ,x_get_hier_rels_stmt          => l_get_hier_rels_stmt
  );

  bld_insert_hier_rels_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_value_set_required_flag     => l_value_set_required_flag
    ,p_target_hier_table           => l_target_hier_table
    ,p_target_hierval_table        => l_target_hierval_table
    ,x_insert_hier_rels_stmt       => l_insert_hier_rels_stmt
  );

  bld_delete_hier_rels_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_source_hier_table           => l_source_hier_table
    ,x_delete_hier_rels_stmt       => l_delete_hier_t_rels_stmt
  );

  bld_delete_hier_rels_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_execution_mode              => p_execution_mode
    ,p_target_hier_table           => l_target_hier_table
    ,x_delete_hier_rels_stmt       => l_delete_hier_rels_stmt
  );

  bld_insert_hierval_rels_stmt (
    p_dimension_varchar_label      => p_dimension_varchar_label
    ,p_target_hierval_table        => l_target_hierval_table
    ,x_insert_hierval_rels_stmt    => l_insert_hierval_rels_stmt
  );


  ------------------------------------------------------------------------------
  -- STEP 1: Check to see that the specified hierarchy object name and
  -- hierarchy object definition name exist in FEM_HIERARCHIES_T for the
  -- given dimension.
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 1: Hierarchy Count in FEM_HIERARCHIES_T'
  );

  execute immediate
  ' select count(*)'||
  ' from fem_hierarchies_t'||
  ' where hierarchy_object_name = :b_hierarchy_object_name'||
  ' and hier_obj_def_display_name = :b_hier_obj_def_display_name'||
  ' and dimension_varchar_label = :b_dimension_varchar_label'||
    l_status_clause||
  ' and language = userenv(''LANG'')'
  into l_count
  using p_hierarchy_object_name
  ,p_hier_obj_def_display_name
  ,p_dimension_varchar_label;

  if (l_count = 0) then
    -- Hierarchy not found in FEM_HIERARCHIES_T
    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_HIER_LDR_NO_HIER_ERR
      ,p_token1   => 'HIERARCHY_OBJECT_NAME'
      ,p_value1   => p_hierarchy_object_name
      ,p_token2   => 'HIER_OBJ_DEF_DISPLAY_NAME'
      ,p_value2   => p_hier_obj_def_display_name
    );
    raise e_loader_error;
  elsif (l_count > 1) then
    -- Multiple hierarchy definitions found in FEM_HIERARCHIES_T
    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_HIER_LDR_MULTI_HIER_ERR
      ,p_token1   => 'HIERARCHY_OBJECT_NAME'
      ,p_value1   => p_hierarchy_object_name
      ,p_token2   => 'HIER_OBJ_DEF_DISPLAY_NAME'
      ,p_value2   => p_hier_obj_def_display_name
    );
    raise e_loader_error;
  end if;


  ------------------------------------------------------------------------------
  -- STEP 2: Register the process execution in the Processing Locks data model
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 2: Register Process Execution'
  );

  register_process_execution (
    p_request_id                 => l_request_id
    ,p_object_id                 => l_loader_object_id
    ,p_obj_def_id                => l_loader_obj_def_id
    ,p_execution_mode            => p_execution_mode
    ,p_user_id                   => l_user_id
    ,p_login_id                  => l_login_id
    ,p_pgm_id                    => l_pgm_id
    ,p_pgm_app_id                => l_pgm_app_id
    ,p_hierarchy_object_name     => p_hierarchy_object_name
  );


  ------------------------------------------------------------------------------
  -- Load all hierarchy information.
  ------------------------------------------------------------------------------
  open cv_get_hier_defs
  for l_get_hier_defs_stmt
  using p_dimension_varchar_label
  ,p_hierarchy_object_name
  ,p_hier_obj_def_display_name;

  l_get_hier_defs_is_open := true;

  loop

    fetch cv_get_hier_defs into
    ld_rowid
    ,ld_folder_name
    ,ld_hierarchy_object_name
    ,ld_hier_obj_def_display_name
    ,ld_effective_start_date
    ,ld_effective_end_date
    ,ld_calendar_dc
    ,ld_language
    ,ld_dimension_varchar_label
    ,ld_hierarchy_type_code
    ,ld_group_seq_enforced_code
    ,ld_multi_top_flag
    ,ld_multi_value_set_flag
    ,ld_hierarchy_usage_code
    ,ld_flattened_rows_flag
    ,ld_status;

    exit when cv_get_hier_defs%NOTFOUND;

    -- Initialize hierarchy error flag to false
    l_hierarchy_error_flag := false;

    <<to_next_hier_for_loading>>
    loop

      FEM_ENGINES_PKG.tech_message (
        p_severity => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name||'.cv_get_hier_defs'
        ,p_msg_text =>
          ' ld_folder_name='||ld_folder_name||
          ' ld_hierarchy_object_name='||ld_hierarchy_object_name||
          ' ld_hier_obj_def_display_name='||ld_hier_obj_def_display_name||
          ' ld_effective_start_date='||ld_effective_start_date||
          ' ld_effective_end_date='||ld_effective_end_date||
          ' ld_calendar_dc='||ld_calendar_dc||
          ' ld_language='||ld_language||
          ' ld_dimension_varchar_label='||ld_dimension_varchar_label||
          ' ld_hierarchy_type_code='||ld_hierarchy_type_code||
          ' ld_group_seq_enforced_code='||ld_group_seq_enforced_code||
          ' ld_multi_top_flag='||ld_multi_top_flag||
          ' ld_multi_value_set_flag='||ld_multi_value_set_flag||
          ' ld_hierarchy_usage_code='||ld_hierarchy_usage_code||
          ' ld_flattened_rows_flag='||ld_flattened_rows_flag||
          ' ld_status='||ld_status
      );

  ------------------------------------------------------------------------------
  -- STEP 3: Check for Existing Object ID and Object Definition ID, and check
  -- Effective Dates.
  ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.tech_message (
        p_severity  => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 3: Catalog of Objects record and effective date checks'
      );

  ------------------------------------------------------------------------------
  -- STEP 3.1: Check to see if there is an existing object id with the same
  -- hierarchy object name and dimension id.
  ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.tech_message (
        p_severity  => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 3.1: Check for Existing Object ID'
      );

      -- Start by assuming that the load will be an update to an existing
      -- hierarchy definition.
      ld_load_type := g_update_hier_def;

      begin

        select h.hierarchy_obj_id
        ,h.hierarchy_type_code
        ,h.group_sequence_enforced_code
        ,h.multi_top_flag
        ,h.multi_value_set_flag
        ,h.hierarchy_usage_code
        ,h.flattened_rows_flag
        ,h.calendar_id
        into ld_hierarchy_object_id
        ,ld_hierarchy_type_code
        ,ld_group_seq_enforced_code
        ,ld_multi_top_flag
        ,ld_multi_value_set_flag
        ,ld_hierarchy_usage_code
        ,ld_flattened_rows_flag
        ,ld_calendar_id
        from fem_object_catalog_vl cat
        ,fem_hierarchies h
        where cat.object_name = ld_hierarchy_object_name
        and cat.object_type_code = 'HIERARCHY'
        and h.hierarchy_obj_id = cat.object_id
        and h.dimension_id = l_dimension_id;

        FEM_ENGINES_PKG.tech_message (
          p_severity => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name||'.get_hier_obj_id'
          ,p_msg_text =>
            ' ld_hierarchy_object_id='||ld_hierarchy_object_id||
            ' ld_hierarchy_type_code='||ld_hierarchy_type_code||
            ' ld_group_seq_enforced_code='||ld_group_seq_enforced_code||
            ' ld_multi_top_flag='||ld_multi_top_flag||
            ' ld_multi_value_set_flag='||ld_multi_value_set_flag||
            ' ld_hierarchy_usage_code='||ld_hierarchy_usage_code||
            ' ld_flattened_rows_flag='||ld_flattened_rows_flag
        );

      exception
        when no_data_found then
          -- No hierarchy object id found.  New Hierarchy Load.
          ld_load_type := g_new_hier;
      end;

  ------------------------------------------------------------------------------
  -- STEP 3.2: For an existing object id, check to see if there is an existing
  -- object definition id with the same hierarchy object definition display
  -- name.
  ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.tech_message (
        p_severity  => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 3.2: Check for Existing Object Definition ID'
      );

      if (ld_load_type <> g_new_hier) then

        begin

          select object_definition_id
          ,effective_start_date
          ,effective_end_date
          into ld_hier_obj_def_id
          ,ld_effective_start_date
          ,ld_effective_end_date
          from fem_object_definition_vl
          where object_id = ld_hierarchy_object_id
          and display_name = ld_hier_obj_def_display_name
          and old_approved_copy_flag = 'N';

          FEM_ENGINES_PKG.tech_message (
            p_severity => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name||'.get_hier_obj_def_id'
            ,p_msg_text =>
              ' ld_hier_obj_def_id='||ld_hier_obj_def_id||
              ' ld_effective_start_date='||ld_effective_start_date||
              ' ld_effective_end_date='||ld_effective_end_date
          );

        exception
          when no_data_found then
          -- No hierarchy object definition id found.  New Hierarchy Load.
            ld_load_type := g_new_hier_def;
        end;

      end if;

--BEGIN:effective_date_validation
  ------------------------------------------------------------------------------
  -- STEP 3.3: Effective Date Validations.  We must make sure that there are no
  -- overlaps with existing object definitions.  If the user does not specify
  -- values for the effective start and end dates, then we must try to provide
  -- default values.
  ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.tech_message (
        p_severity  => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 3.3: Effective Date Validations'
      );

      l_new_max_obj_def_id := null;
      l_new_max_eff_end_date := null;

      if (ld_load_type = g_new_hier) then

        -- If end date is null, then use the default end date.
        if (ld_effective_end_date is null) then
          ld_effective_end_date := get_default_end_date;
        end if;
        -- Make sure that the end date does not have a time component.
        ld_effective_end_date := trunc(ld_effective_end_date);

        -- If start date is null, then use the default start date.
        if (ld_effective_start_date is null) then
          ld_effective_start_date := get_default_start_date;
        end if;
        -- Make sure that the start date does not have a time component.
        ld_effective_start_date := trunc(ld_effective_start_date);

        -- Check that start date is not greater than end date
        if (ld_effective_start_date > ld_effective_end_date) then

          FEM_ENGINES_PKG.user_message (
            p_app_name  => G_FEM
            ,p_msg_name => G_HIER_LDR_EFF_DATE_RANG_ERR
            ,p_token1   => 'END_DATE'
            ,p_value1   => FND_DATE.date_to_chardate(ld_effective_end_date)
            ,p_token2   => 'START_DATE'
            ,p_value2   => FND_DATE.date_to_chardate(ld_effective_start_date)
          );
          l_hierarchy_error_flag := true;

        end if;

      elsif (ld_load_type = g_new_hier_def) then

        -- if end date is null, then use the default end date.
        if (ld_effective_end_date is null) then
          ld_effective_end_date := get_default_end_date;
        end if;
        -- Make sure that the end date does not have a time component.
        ld_effective_end_date := trunc(ld_effective_end_date);

        -- If the start date is null, then we must find the existing object
        -- definition with the largest end date.
        if (ld_effective_start_date is null) then

          select object_definition_id
          ,trunc(effective_start_date)
          ,trunc(effective_end_date)
          into l_max_object_definition_id
          ,l_max_effective_start_date
          ,l_max_effective_end_date
          from fem_object_definition_b b1
          where object_id = ld_hierarchy_object_id
          and old_approved_copy_flag = 'N'
          and effective_end_date = (
            select max(effective_end_date)
            from fem_object_definition_b b2
            where b2.object_id = b1.object_id
            and b2.old_approved_copy_flag = b1.old_approved_copy_flag
          );

          -- If the largest end date is greater than the default end date, then
          -- the largest object definition is invalid.
          if (l_max_effective_end_date > get_default_end_date) then

            FEM_ENGINES_PKG.user_message (
              p_app_name  => G_FEM
              ,p_msg_name => G_HIER_LDR_EFF_DATE_OVLP_ERR
              ,p_token1   => 'HIERARCHY_OBJECT_NAME'
              ,p_value1   => ld_hierarchy_object_name
            );
            l_hierarchy_error_flag := true;

          -- If the largest end date is equal to the default end date, then
          -- then we must adjust the largest end date to be the sysdate.  This
          -- will leave room for the new object definition to have a date range
          -- from sysdate+1 to default end date.
          elsif (l_max_effective_end_date = get_default_end_date) then

            -- Get the sysdate without any time component.
            l_current_date := trunc(sysdate);

            -- Do not allow an update on the largest object definition if its
            -- start date is greater than the sysdate.  Otherwise
            -- the largest object definition will be updated to have an
            -- end date that is smaller than its start date.
            if (l_max_effective_start_date > l_current_date) then

              FEM_ENGINES_PKG.user_message (
                p_app_name  => G_FEM
                ,p_msg_name => G_HIER_LDR_EFF_DATE_OVLP_ERR
                ,p_token1   => 'HIERARCHY_OBJECT_NAME'
                ,p_value1   => ld_hierarchy_object_name
              );
              l_hierarchy_error_flag := true;

            else

              l_max_effective_end_date := l_current_date;
              ld_effective_start_date := l_current_date + 1;

              -- Check that an update to the end date of the largest object
              -- definition will not invalidate any dependent data.
              FEM_PL_PKG.effective_date_incl_rslt_data(
                p_object_definition_id       => l_max_object_definition_id
                ,p_new_effective_start_date  => l_max_effective_start_date
                ,p_new_effective_end_date    => l_max_effective_end_date
                ,x_msg_count                 => l_msg_count
                ,x_msg_data                  => l_msg_data
                ,x_date_incl_rslt_data       => l_date_incl_rslt_data
              );

              -- If true, then largest object definition is still valid and it
              -- is OK to update max object definition.
              if (FND_API.To_Boolean(l_date_incl_rslt_data)) then

                l_new_max_obj_def_id := l_max_object_definition_id;
                l_new_max_eff_end_date := l_max_effective_end_date;

              else

                --todo: this API should be put in a common loader package.
                get_put_messages (
                  p_msg_count => l_msg_count
                  ,p_msg_data => l_msg_data
                );

                FEM_ENGINES_PKG.user_message (
                  p_app_name  => G_FEM
                  ,p_msg_name => G_HIER_LDR_DEF_DATA_RANG_ERR
                  ,p_token1   => 'HIERARCHY_OBJECT_NAME'
                  ,p_value1   => ld_hierarchy_object_name
                );
                l_hierarchy_error_flag := true;

              end if;

            end if;

          -- If the largest end date is less that the default end date, then
          -- only need to set the new start date to be the day after the
          -- end date of the largest object definition.
          else -- (l_max_effective_end_date < DEFAULT_END_DATE)

            ld_effective_start_date := l_max_effective_end_date + 1;

          end if;

        -- As the user specified a start date, we must check that the date
        -- range of the new object definition will not overlap with any other
        -- object definitions.
        else -- (ld_effective_start_date is not null)

          -- Make sure that the start date does not have a time component.
          ld_effective_start_date := trunc(ld_effective_start_date);

          -- Check that start date is not greater than end date
          if (ld_effective_start_date > ld_effective_end_date) then

            FEM_ENGINES_PKG.user_message (
              p_app_name  => G_FEM
              ,p_msg_name => G_HIER_LDR_EFF_DATE_RANG_ERR
              ,p_token1   => 'END_DATE'
              ,p_value1   => FND_DATE.date_to_chardate(ld_effective_end_date)
              ,p_token2   => 'START_DATE'
              ,p_value2   => FND_DATE.date_to_chardate(ld_effective_start_date)
            );
            l_hierarchy_error_flag := true;

          else

            -- Perform the overlap check by calling the appropriate API
            -- from the business rule framework.
            FEM_BUSINESS_RULE_PVT.CheckOverlapObjDefs(
              p_obj_id                 => ld_hierarchy_object_id
              ,p_exclude_obj_def_id    => null
              ,p_effective_start_date  => ld_effective_start_date
              ,p_effective_end_date    => ld_effective_end_date
              ,p_init_msg_list         => FND_API.G_TRUE
              ,x_return_status         => l_return_status
              ,x_msg_count             => l_msg_count
              ,x_msg_data              => l_msg_data
            );

            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

              --todo: this API should be put in a common loader package.
              get_put_messages (
                p_msg_count => l_msg_count
                ,p_msg_data => l_msg_data
              );

              FEM_ENGINES_PKG.user_message (
                p_app_name  => G_FEM
                ,p_msg_name => G_HIER_LDR_EFF_DATE_OVLP_ERR
                ,p_token1   => 'HIERARCHY_OBJECT_NAME'
                ,p_value1   => ld_hierarchy_object_name
              );
              l_hierarchy_error_flag := true;

            end if;

          end if;

        end if;

      end if;
--END:effective_date_validation

  ------------------------------------------------------------------------------
  -- STEP 3.4: Update Hierarchy Definition Validations.
  ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.tech_message (
        p_severity  => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 3.4: Update Hierarchy Definition Validations'
      );

      if (ld_load_type = g_update_hier_def) then

  ------------------------------------------------------------------------------
  -- STEP 3.4.1: Check for Edit or Approval Lock.
  ------------------------------------------------------------------------------
        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 3.4.1: Check for Edit or Approval Lock'
        );

        FEM_PL_PKG.get_object_def_edit_locks(
          p_object_definition_id        => ld_hier_obj_def_id
          ,x_approval_edit_lock_exists  => l_approval_edit_lock_exists
          ,x_data_edit_lock_exists      => l_data_edit_lock_exists
        );

        FEM_ENGINES_PKG.tech_message (
          p_severity => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name||'.get_object_def_edit_locks'
          ,p_msg_text => 'l_approval_edit_lock_exists='||l_approval_edit_lock_exists||' l_data_edit_lock_exists='||l_data_edit_lock_exists
        );

        if ( FND_API.To_Boolean(l_approval_edit_lock_exists)
          or FND_API.To_Boolean(l_data_edit_lock_exists) ) then

          FEM_ENGINES_PKG.user_message (
            p_app_name  => G_FEM
            ,p_msg_name => G_HIER_LDR_DEF_DATA_LOCK_ERR
            ,p_token1   => 'HIERARCHY_OBJECT_NAME'
            ,p_value1   => ld_hierarchy_object_name
            ,p_token2   => 'HIER_OBJ_DEF_DISPLAY_NAME'
            ,p_value2   => ld_hier_obj_def_display_name
          );
          -- Raise exception as we cannot allow the hierarchy to be updated.
          -- No need for further validations.
          raise e_hierarchy_error;

        end if;

  ------------------------------------------------------------------------------
  -- STEP 3.4.2: Check for Read Only Relationships.
  ------------------------------------------------------------------------------
        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 3.4.2: Check for Read Only Relationships'
        );

        execute immediate
        ' select count(*)'||
        ' from '||l_target_hier_table||
        ' where hierarchy_obj_def_id = :b_hier_obj_def_id'||
        ' and read_only_flag = ''Y'''
        into l_count
        using ld_hier_obj_def_id;

        if (l_count > 0) then

          -- Cannot update an existing hierarchy object definition if it
          -- has read only parent-child relationships.
          FEM_ENGINES_PKG.user_message (
            p_app_name  => G_FEM
            ,p_msg_name => G_HIER_LDR_READONLY_HIER_ERR
          );

          -- Raise exception as we cannot allow the hierarchy to be updated.
          -- No need for further validations.
          raise e_hierarchy_error;

        end if;

      end if;

--BEGIN:eng_master_prep
  ------------------------------------------------------------------------------
  -- STEP 4: Check to see if the user executing the hierarchy load has write
  -- access to the folder.  If yes, the obtain the folder id.
  ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.tech_message (
        p_severity  => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 4: Folder Validation'
      );

      begin
        -- Bug Fix 3584893: HIER LOADER - ADD FOLDER SECURITY CHECK
        select f.folder_id
        into ld_folder_id
        from fem_folders_vl f
        ,fem_user_folders uf
        where uf.folder_id = f.folder_id
        and uf.user_id = l_user_id
        and uf.write_flag = 'Y'
        and f.folder_name = ld_folder_name;
      exception
        when no_data_found then
          FEM_ENGINES_PKG.user_message (
            p_app_name  => G_FEM
            ,p_msg_name => G_HIER_LDR_FOLDER_ERR
            ,p_token1   => 'FOLDER_NAME'
            ,p_value1   => ld_folder_name
          );
          l_hierarchy_error_flag := true;
      end;


  ------------------------------------------------------------------------------
  -- STEP 5: New hierarchies listed in FEM_HIERARCHIES_T must pass all
  -- hierarchy object validations.
  ------------------------------------------------------------------------------
      if (ld_load_type = g_new_hier) then

        FEM_ENGINES_PKG.tech_message (
          p_severity => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 5: New Hierarchy Validations'
        );

  ------------------------------------------------------------------------------
  -- STEP 5.1: Verify that HIERARCHY_TYPE_CODE on FEM_HIERARCHIES_T
  -- is valid (OPEN, RECONCILIATION, DAG).
  ------------------------------------------------------------------------------
        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 5.1: HIERARCHY_TYPE_CODE Validation'
        );

        begin
          select 1
          into l_dummy
          from fem_lookups
          where lookup_type = 'FEM_HIERARCHY_TYPE_DSC'
          and lookup_code = ld_hierarchy_type_code;
        exception
          when no_data_found then
            FEM_ENGINES_PKG.user_message (
              p_app_name  => G_FEM
              ,p_msg_name => G_HIER_LDR_HIER_TYPE_CD_ERR
              ,p_token1   => 'HIERARCHY_TYPE_CODE'
              ,p_value1   => ld_hierarchy_type_code
            );
            l_hierarchy_error_flag := true;
        end;

        if ( ( l_hier_type_allowed_code <> 'ALL')
         and ( l_hier_type_allowed_code <> ld_hierarchy_type_code) ) then

            FEM_ENGINES_PKG.user_message (
              p_app_name  => G_FEM
              ,p_msg_name => G_HIER_LDR_HIER_TYPE_VAL_ERR
              ,p_token1   => 'HIERARCHY_TYPE_CODE'
              ,p_value1   => l_hier_type_allowed_code
            );
            l_hierarchy_error_flag := true;

        end if;

  ------------------------------------------------------------------------------
  -- STEP 5.2: Verify that HIERARCHY_USAGE_CODE on FEM_HIERARCHIES_T
  -- is valid (PLANNING, STANDARD, CONSOLIDATION).
  ------------------------------------------------------------------------------
        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 5.2: HIERARCHY_USAGE_CODE Validation'
        );

        begin
          select 1
          into l_dummy
          from fem_lookups
          where lookup_type = 'FEM_HIERARCHY_USAGE_DSC'
          and lookup_code = ld_hierarchy_usage_code;
        exception
          when no_data_found then
            FEM_ENGINES_PKG.user_message (
              p_app_name  => G_FEM
              ,p_msg_name => G_HIER_LDR_HIER_USG_CD_ERR
              ,p_token1   => 'HIERARCHY_USAGE_CODE'
              ,p_value1   => ld_hierarchy_usage_code
            );
            l_hierarchy_error_flag := true;
        end;

  ------------------------------------------------------------------------------
  -- STEP 5.3: Verify that GROUP_SEQUENCE_ENFORCED_CODE on FEM_HIERARCHIES_T
  -- is valid.
  ------------------------------------------------------------------------------
        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 5.3: GROUP_SEQUENCE_ENFORCED_CODE Validation'
        );

        begin
          select 1
          into l_dummy
          from fem_lookups
          where lookup_type = 'FEM_GROUP_SEQ_ENFORCED_DSC'
          and lookup_code = ld_group_seq_enforced_code;
        exception
          when no_data_found then
            FEM_ENGINES_PKG.user_message (
              p_app_name  => G_FEM
              ,p_msg_name => G_HIER_LDR_GRP_SQ_ENF_CD_ERR
              ,p_token1   => 'GROUP_SEQ_ENFORCED_CODE'
              ,p_value1   => ld_group_seq_enforced_code
            );
            l_hierarchy_error_flag := true;
        end;

        if (l_group_use_code = 'REQUIRED') then

          if (ld_group_seq_enforced_code = 'NO_GROUPS') then

            FEM_ENGINES_PKG.user_message (
              p_app_name  => G_FEM
              ,p_msg_name => G_HIER_LDR_GRP_SQ_REQ_ERR
            );
            l_hierarchy_error_flag := true;

          end if;

        elsif (l_group_use_code = 'NOT_SUPPORTED') then

          if (ld_group_seq_enforced_code <> 'NO_GROUPS') then

            FEM_ENGINES_PKG.user_message (
              p_app_name  => G_FEM
              ,p_msg_name => G_HIER_LDR_GRP_SQ_VAL_ERR
              ,p_token1   => 'GROUP_SEQ_ENFORCED_CODE'
              ,p_value1   => 'NO_GROUPS'
            );
            l_hierarchy_error_flag := true;

          end if;

        end if;

  ------------------------------------------------------------------------------
  -- STEP 5.4: Verify that MULTI_TOP_FLAG on FEM_HIERARCHIES_T is valid (Y,N).
  ------------------------------------------------------------------------------
        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 5.4: MULTI_TOP_FLAG Validation'
        );

        if (ld_multi_top_flag not in ('Y','N')) then

          FEM_ENGINES_PKG.user_message (
            p_app_name  => G_FEM
            ,p_msg_name => G_HIER_LDR_MULTI_TOP_FLG_ERR
            ,p_token1   => 'MULTI_TOP_FLAG'
            ,p_value1   => ld_multi_top_flag
          );
          l_hierarchy_error_flag := true;

        end if;

  ------------------------------------------------------------------------------
  -- STEP 5.5: Verify that MULTI_VALUE_SET_FLAG on FEM_HIERARCHIES_T is
  -- valid (Y,N).
  ------------------------------------------------------------------------------
        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 5.5: MULTI_VALUE_SET_FLAG Validation'
        );

        if (ld_multi_value_set_flag not in ('Y','N')) then

          FEM_ENGINES_PKG.user_message (
            p_app_name  => G_FEM
            ,p_msg_name => G_HIER_LDR_MULTI_VS_FLG_ERR
            ,p_token1   => 'MULTI_VALUE_SET_FLAG'
            ,p_value1   => ld_multi_value_set_flag
          );
          l_hierarchy_error_flag := true;

        else

          if ( (l_value_set_required_flag = 'N')
           and (ld_multi_value_set_flag = 'Y') ) then

            FEM_ENGINES_PKG.user_message (
              p_app_name  => G_FEM
              ,p_msg_name => G_HIER_LDR_MULT_VS_FLG_V_ERR
              ,p_token1   => 'MULTI_VALUE_SET_FLAG'
              ,p_value1   => 'Y'
            );
            l_hierarchy_error_flag := true;

          end if;

        end if;

  ------------------------------------------------------------------------------
  -- STEP 5.6: Verify that FLATTENED_ROWS_FLAG on FEM_HIERARCHIES_T is
  -- valid (Y,N).
  ------------------------------------------------------------------------------
        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 5.6: FLATTENED_ROWS_FLAG Validation'
        );

        if (ld_flattened_rows_flag not in ('Y','N')) then

          FEM_ENGINES_PKG.user_message (
            p_app_name  => G_FEM
            ,p_msg_name => G_HIER_LDR_FLAT_ROWS_FLG_ERR
            ,p_token1   => 'FLATTENED_ROWS_FLAG'
            ,p_value1   => ld_flattened_rows_flag
          );
          l_hierarchy_error_flag := true;

        end if;

  ------------------------------------------------------------------------------
  -- STEP 5.7: Only for the CAL_PERIOD dimension, verify that a valid
  -- CALENDAR_DISPLAY_CODE has been specified for the hierarchy in
  -- FEM_HIERARCHIES_T.
  ------------------------------------------------------------------------------
        if (p_dimension_varchar_label = 'CAL_PERIOD') then

          FEM_ENGINES_PKG.tech_message (
            p_severity  => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 5.7: CALENDAR_DISPLAY_CODE Validation'
          );

          begin
            select calendar_id
            into ld_calendar_id
            from fem_calendars_b
            where calendar_display_code = ld_calendar_dc;
          exception
            when no_data_found then
              FEM_ENGINES_PKG.user_message (
                p_app_name  => G_FEM
                ,p_msg_name => G_HIER_LDR_CALENDAR_ERR
                ,p_token1   => 'CALENDAR_DISPLAY_CODE'
                ,p_value1   => ld_calendar_dc
              );
              l_hierarchy_error_flag := true;
          end;

        end if;

  ------------------------------------------------------------------------------
  -- STEP 5.8: Value Set validations for new hierarchies.
  ------------------------------------------------------------------------------
        if (l_value_set_required_flag = 'Y') then

          FEM_ENGINES_PKG.tech_message (
            p_severity  => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 5.8: Value Set Validations'
          );

  ------------------------------------------------------------------------------
  -- STEP 5.8.1: Verify that MULTI_VALUE_SET_FLAG on FEM_HIERARCHIES_T
  -- is valid.  If flag ='N', check that only one value set row is listed in
  -- FEM_HIER_VALUE_SETS_T for that hierarchy.
  ------------------------------------------------------------------------------
          FEM_ENGINES_PKG.tech_message (
            p_severity  => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 5.8.1: MULTI_VALUE_SET_FLAG Validation'
          );

          execute immediate
          ' select count(*)'||
          ' from fem_hier_value_sets_t'||
          ' where hierarchy_object_name = :b_hierarchy_object_name'||
            l_status_clause||
          ' and language = userenv(''LANG'')'
          into l_vs_count
          using ld_hierarchy_object_name;

          if (l_vs_count = 0) then

            FEM_ENGINES_PKG.user_message (
              p_app_name  => G_FEM
              ,p_msg_name => G_HIER_LDR_NO_HIER_VS_ERR
              ,p_token1   => 'HIERARCHY_OBJECT_NAME'
              ,p_value1   => ld_hierarchy_object_name
            );
            l_hierarchy_error_flag := true;

          elsif ((l_vs_count > 1) and (ld_multi_value_set_flag = 'N')) then

            l_hierarchy_error_flag := true;
            ld_status := 'MULTIPLE_VALUE_SETS';

            set_hier_table_err_msg (
              p_hier_table_name => 'FEM_HIER_VALUE_SETS_T'
              ,p_status         => ld_status
            );

            execute immediate
            ' update fem_hier_value_sets_t'||
            ' set status = :b_status'||
            ' where hierarchy_object_name = :b_hierarchy_object_name'||
              l_status_clause||
            ' and language = userenv(''LANG'')'
            using ld_status
            ,ld_hierarchy_object_name;

            commit;

          end if;

          exit to_next_hier_for_loading when l_hierarchy_error_flag;

        end if; -- End of value set validations for new hierarchies

  ------------------------------------------------------------------------------
  -- STEP 5.9: Dimension Group validations.
  ------------------------------------------------------------------------------
        if (ld_group_seq_enforced_code <> 'NO_GROUPS') then

          FEM_ENGINES_PKG.tech_message (
            p_severity  => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 5.9: Dimension Group Validations'
          );

  ------------------------------------------------------------------------------
  -- STEP 5.9.1: Verify that FEM_HIER_DIM_GRPS_T is not empty
  ------------------------------------------------------------------------------
          FEM_ENGINES_PKG.tech_message (
            p_severity  => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 5.9.1: FEM_HIER_DIM_GRPS_T Not Empty Validation'
          );

          -- Validation added with bug 4449780
          execute immediate
          ' select count(*)'||
          ' from fem_hier_dim_grps_t'||
          ' where hierarchy_object_name = :b_hierarchy_object_name'||
            l_status_clause||
          ' and language = userenv(''LANG'')'
          into l_count
          using p_hierarchy_object_name;

          if (l_count = 0) then

            FEM_ENGINES_PKG.user_message (
              p_app_name  => G_FEM
              ,p_msg_name => G_HIER_LDR_DIM_GRPS_REQ_ERR
            );
            l_hierarchy_error_flag := true;

          end if;

          exit to_next_hier_for_loading when l_hierarchy_error_flag;

  ------------------------------------------------------------------------------
  -- STEP 5.9.2: Verify that DIMENSION_GROUP_DISPLAY_CODE on FEM_HIER_DIM_GRPS_T
  -- is a valid dimension group for the dimension.
  ------------------------------------------------------------------------------
          FEM_ENGINES_PKG.tech_message (
            p_severity  => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 5.9.2: DIMENSION_GROUP_DISPLAY_CODE in FEM_HIER_DIM_GRPS_T Validation'
          );

          open cv_bad_dim_groups
          for l_bad_dim_groups_stmt
          using ld_hierarchy_object_name
          ,l_dimension_id;

          l_bad_dim_groups_is_open := true;

          loop

            fetch cv_bad_dim_groups
            bulk collect into
            tg_rowid
            ,tg_status
            limit gv_fetch_limit;

            l_bad_dim_groups_last_row := tg_rowid.LAST;
            if (l_bad_dim_groups_last_row is null) then
              exit;
            end if;

            l_hierarchy_error_flag := true;
            ld_status := tg_status(1);

            set_hier_table_err_msg (
              p_hier_table_name => 'FEM_HIER_DIM_GRPS_T'
              ,p_status         => ld_status
            );

            forall j in 1..l_bad_dim_groups_last_row
              execute immediate
              ' update fem_hier_dim_grps_t'||
              ' set status = :b_status'||
              ' where rowid = :b_rowid'||
                l_status_clause||
              ' and language = userenv(''LANG'')'
              using tg_status(j)
              ,tg_rowid(j);

            commit;

            tg_rowid.DELETE;
            tg_status.DELETE;

          end loop;

          close cv_bad_dim_groups;
          l_bad_dim_groups_is_open := false;

          exit to_next_hier_for_loading when l_hierarchy_error_flag;

        end if; -- End of dimension group validations

      end if; -- End of new hierarchy validations
--END:eng_master_prep

  ------------------------------------------------------------------------------
  -- STEP 5.10: Value Set validations for new and updated hierarchies.
  ------------------------------------------------------------------------------
      if (l_value_set_required_flag = 'Y') then

  ------------------------------------------------------------------------------
  -- STEP 5.10.1: Verify that VALUE_SET_DISPLAY_CODE on FEM_HIER_VALUE_SETS_T
  -- is a valid value set for the dimension.  This is needed for all new
  -- hiearchies, and for updates on multi value set hierarchies where we allow
  -- more value sets to be added (Bug 4661474).
  ------------------------------------------------------------------------------
        if ( (ld_load_type = g_new_hier) or (ld_multi_value_set_flag = 'Y') ) then

          FEM_ENGINES_PKG.tech_message (
            p_severity  => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 5.10.1: VALUE_SET_DISPLAY_CODE in FEM_HIER_VALUE_SETS_T Validation'
          );

          open cv_bad_value_sets
          for l_bad_value_sets_stmt
          using ld_hierarchy_object_name
          ,l_dimension_id;

          l_bad_value_sets_is_open := true;

          loop

            fetch cv_bad_value_sets
            bulk collect into
            tv_rowid
            ,tv_status
            limit gv_fetch_limit;

            l_bad_value_sets_last_row := tv_rowid.LAST;
            if (l_bad_value_sets_last_row is null) then
              exit;
            end if;

            l_hierarchy_error_flag := true;
            ld_status := tv_status(1);

            set_hier_table_err_msg (
              p_hier_table_name => 'FEM_HIER_VALUE_SETS_T'
              ,p_status         => ld_status
            );

            forall j in 1..l_bad_value_sets_last_row
              execute immediate
              ' update fem_hier_value_sets_t'||
              ' set status = :b_status'||
              ' where rowid = :b_rowid'||
                l_status_clause||
              ' and language = userenv(''LANG'')'
              using tv_status(j)
              ,tv_rowid(j);

            commit;

            tv_rowid.DELETE;
            tv_status.DELETE;

          end loop;

          close cv_bad_value_sets;
          l_bad_value_sets_is_open := false;

          exit to_next_hier_for_loading when l_hierarchy_error_flag;

        end if;

      end if; -- End of value set validations


      -- Must raise hierarchy exception if any hierarchy errors were found.
      -- No further hierarchy validations are performed.
      if (l_hierarchy_error_flag) then
        raise e_hierarchy_error;
      end if;


--BEGIN:multi_thread_validation
  ------------------------------------------------------------------------------
  -- STEP 6: Parent-Child relationship validations.  All hierarchy load types
  -- must pass this validation (new hierarchy, new hierarchy definition, and
  -- update hierarchy definition).
  ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.tech_message (
        p_severity => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 6: Parent-Child Validations'
      );

  ------------------------------------------------------------------------------
  -- STEP 6.1: Only for the CAL_PERIOD dimension, verify that the
  -- CALENDAR_DISPLAY_CODE is valid for the hierarchy in FEM_CAL_PERIODS_HIER_T
  ------------------------------------------------------------------------------
      if (p_dimension_varchar_label = 'CAL_PERIOD') then

        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 6.1: CALENDAR_DISPLAY_CODE in FEM_CAL_PERIODS_HIER_T Validation'
        );

        open cv_bad_hier_calendars
        for l_bad_hier_calendars_stmt
        using ld_hierarchy_object_name
        ,ld_hier_obj_def_display_name
        ,ld_calendar_dc;

        l_bad_hier_calendars_is_open := true;

        loop

          fetch cv_bad_hier_calendars
          bulk collect into
          th_rowid
          ,th_status
          limit gv_fetch_limit;

          l_bad_hier_calendars_last_row := th_rowid.LAST;
          if (l_bad_hier_calendars_last_row is null) then
            exit;
          end if;

          l_hierarchy_error_flag := true;
          ld_status := th_status(1);

          set_hier_table_err_msg (
            p_hier_table_name => l_source_hier_table
            ,p_status         => ld_status
          );

          forall j in 1..l_bad_hier_calendars_last_row
            execute immediate
            bld_update_status_stmt (
              p_dimension_varchar_label    => p_dimension_varchar_label
              ,p_execution_mode            => p_execution_mode
              ,p_source_hier_table         => l_source_hier_table
              ,p_rowid_flag                => 'Y'
            )
            using th_status(j)
            ,th_rowid(j);

          commit;

          th_rowid.DELETE;
          th_status.DELETE;

        end loop;

        close cv_bad_hier_calendars;
        l_bad_hier_calendars_is_open := false;

        exit to_next_hier_for_loading when l_hierarchy_error_flag;

      end if;

  ------------------------------------------------------------------------------
  -- STEP 6.2: Verify that the PARENT_VALUE_SET_DISPLAY_CODE and
  -- CHILD_VALUE_SET_DISPLAY_CODE are valid for the hierarchy in
  -- FEM_HIER_VALUE_SETS_T (new) or FEM_HIER_VALUE_SETS (existing)
  ------------------------------------------------------------------------------
      if (l_value_set_required_flag = 'Y') then

        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 6.2: PARENT_VALUE_SET_DISPLAY_CODE and CHILD_VALUE_SET_DISPLAY_CODE Validations'
        );

        if (ld_load_type = g_new_hier) then
          open cv_bad_hier_value_sets
          for l_bad_hier_value_sets_t_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name;
        elsif (ld_multi_value_set_flag = 'Y') then
          open cv_bad_hier_value_sets
          for l_bad_hier_multi_vs_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name
          ,ld_hierarchy_object_id
          ,ld_hierarchy_object_id;
        else
          open cv_bad_hier_value_sets
          for l_bad_hier_value_sets_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name
          ,ld_hierarchy_object_id
          ,ld_hierarchy_object_id;
        end if;

        l_bad_hier_value_sets_is_open := true;

        loop

          fetch cv_bad_hier_value_sets
          bulk collect into
          th_rowid
          ,th_status
          limit gv_fetch_limit;

          l_bad_hier_value_sets_last_row := th_rowid.LAST;
          if (l_bad_hier_value_sets_last_row is null) then
            exit;
          end if;

          l_hierarchy_error_flag := true;
          ld_status := th_status(1);

          set_hier_table_err_msg (
            p_hier_table_name => l_source_hier_table
            ,p_status         => ld_status
          );

          forall j in 1..l_bad_hier_value_sets_last_row
            execute immediate
            bld_update_status_stmt (
              p_dimension_varchar_label    => p_dimension_varchar_label
              ,p_execution_mode            => p_execution_mode
              ,p_source_hier_table         => l_source_hier_table
              ,p_rowid_flag                => 'Y'
            )
            using th_status(j)
            ,th_rowid(j);

          commit;

          th_rowid.DELETE;
          th_status.DELETE;

        end loop;

        close cv_bad_hier_value_sets;
        l_bad_hier_value_sets_is_open := false;

        exit to_next_hier_for_loading when l_hierarchy_error_flag;

      end if;

  ------------------------------------------------------------------------------
  -- STEP 6.3: Verify that all PARENT_DISPLAY_CODE and CHILD_DISPLAY_CODE values
  -- are valid dimension members in the appropriate FEM_xName_B table.
  ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.tech_message (
        p_severity  => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 6.3: PARENT_ID and CHILD_ID Validations'
      );

      if (p_dimension_varchar_label = 'CAL_PERIOD') then
        open cv_bad_hier_members
        for l_bad_hier_members_stmt
        using ld_hierarchy_object_name
        ,ld_hier_obj_def_display_name
        ,ld_calendar_dc
        ,l_dimension_id
        ,ld_calendar_id
        ,l_dimension_id
        ,ld_calendar_id;
      else
        if (l_value_set_required_flag = 'Y') then
          open cv_bad_hier_members
          for l_bad_hier_members_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name
          ,l_dimension_id
          ,l_dimension_id;
        else
          open cv_bad_hier_members
          for l_bad_hier_members_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name;
        end if;
      end if;

      l_bad_hier_members_is_open := true;

      loop

        fetch cv_bad_hier_members
        bulk collect into
        th_rowid
        ,th_status
        limit gv_fetch_limit;

        l_bad_hier_members_last_row := th_rowid.LAST;
        if (l_bad_hier_members_last_row is null) then
          exit;
        end if;

        l_hierarchy_error_flag := true;
        ld_status := th_status(1);

        set_hier_table_err_msg (
          p_hier_table_name => l_source_hier_table
          ,p_status         => ld_status
        );

        forall j in 1..l_bad_hier_members_last_row
          execute immediate
          bld_update_status_stmt (
            p_dimension_varchar_label    => p_dimension_varchar_label
            ,p_execution_mode            => p_execution_mode
            ,p_source_hier_table         => l_source_hier_table
            ,p_rowid_flag                => 'Y'
          )
          using th_status(j)
          ,th_rowid(j);

        commit;

        th_rowid.DELETE;
        th_status.DELETE;

      end loop;

      close cv_bad_hier_members;
      l_bad_hier_members_is_open := false;

      exit to_next_hier_for_loading when l_hierarchy_error_flag;

  ------------------------------------------------------------------------------
  -- STEP 6.4: Verify for HIERARCHY_TYPE_CODE = (OPEN, RECONCILIATION) that
  -- each child only has a single parent in the FEM_xName_HIER_T table.
  ------------------------------------------------------------------------------
      if (ld_hierarchy_type_code in ('OPEN','RECONCILIATION')) then

        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 6.4: Single Parent Validation'
        );

        if (p_dimension_varchar_label = 'CAL_PERIOD') then
          open cv_bad_hier_dups
          for l_bad_hier_dups_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name
          ,ld_calendar_dc;
        else
          open cv_bad_hier_dups
          for l_bad_hier_dups_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name;
        end if;

        l_bad_hier_dups_is_open := true;

        loop

          fetch cv_bad_hier_dups
          bulk collect into
          th_child_dc
          ,th_child_value_set_dc
          ,th_child_dim_grp_dc
          ,th_child_cal_period_end_date
          ,th_child_cal_period_number
          ,th_status
          limit gv_fetch_limit;

          l_bad_hier_dups_last_row := th_child_dc.LAST;
          if (l_bad_hier_dups_last_row is null) then
            exit;
          end if;

          l_hierarchy_error_flag := true;
          ld_status := th_status(1);

          set_hier_table_err_msg (
            p_hier_table_name => l_source_hier_table
            ,p_status         => ld_status
          );

          if (p_dimension_varchar_label = 'CAL_PERIOD') then
            forall j in 1..l_bad_hier_dups_last_row
              execute immediate
              bld_update_status_stmt (
                p_dimension_varchar_label    => p_dimension_varchar_label
                ,p_execution_mode            => p_execution_mode
                ,p_source_hier_table         => l_source_hier_table
                ,p_hier_object_name_flag     => 'Y'
                ,p_hier_obj_def_name_flag    => 'Y'
                ,p_child_flag                => 'Y'
              )
              using th_status(j)
              ,ld_hierarchy_object_name
              ,ld_hier_obj_def_display_name
              ,ld_calendar_dc
              ,th_child_dim_grp_dc(j)
              ,th_child_cal_period_end_date(j)
              ,th_child_cal_period_number(j);
          else
            if (l_value_set_required_flag = 'Y') then
              forall j in 1..l_bad_hier_dups_last_row
                execute immediate
                bld_update_status_stmt (
                  p_dimension_varchar_label    => p_dimension_varchar_label
                  ,p_execution_mode            => p_execution_mode
                  ,p_value_set_required_flag   => l_value_set_required_flag
                  ,p_source_hier_table         => l_source_hier_table
                  ,p_hier_object_name_flag     => 'Y'
                  ,p_hier_obj_def_name_flag    => 'Y'
                  ,p_child_flag                => 'Y'
                )
                using th_status(j)
                ,ld_hierarchy_object_name
                ,ld_hier_obj_def_display_name
                ,th_child_dc(j)
                ,th_child_value_set_dc(j);
            else
              forall j in 1..l_bad_hier_dups_last_row
                execute immediate
                bld_update_status_stmt (
                  p_dimension_varchar_label    => p_dimension_varchar_label
                  ,p_execution_mode            => p_execution_mode
                  ,p_value_set_required_flag   => l_value_set_required_flag
                  ,p_source_hier_table         => l_source_hier_table
                  ,p_hier_object_name_flag     => 'Y'
                  ,p_hier_obj_def_name_flag    => 'Y'
                  ,p_child_flag                => 'Y'
                )
                using th_status(j)
                ,ld_hierarchy_object_name
                ,ld_hier_obj_def_display_name
                ,th_child_dc(j);
            end if;
          end if;

          commit;

          th_child_dc.DELETE;
          th_child_value_set_dc.DELETE;
          th_child_dim_grp_dc.DELETE;
          th_child_cal_period_end_date.DELETE;
          th_child_cal_period_number.DELETE;
          th_status.DELETE;

        end loop;

        close cv_bad_hier_dups;
        l_bad_hier_dups_is_open := false;

        exit to_next_hier_for_loading when l_hierarchy_error_flag;

      end if;
--END:multi_thread_validation


--BEGIN:single_thread_validation
  ------------------------------------------------------------------------------
  -- STEP 6.5: Verify for MULTI_TOP_FLAG = N that there is a single top node
  -- for the hierarchy in FEM_xName_HIER_T.
  ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.tech_message (
        p_severity  => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 6.5: Missing and Single Root Node Validations'
      );

      if (p_dimension_varchar_label = 'CAL_PERIOD') then
        execute immediate l_root_node_count_stmt
        into l_num_roots
        using ld_hierarchy_object_name
        ,ld_hier_obj_def_display_name
        ,ld_calendar_dc;
      else
        execute immediate l_root_node_count_stmt
        into l_num_roots
        using ld_hierarchy_object_name
        ,ld_hier_obj_def_display_name;
      end if;

      if (l_num_roots = 0) then

        FEM_ENGINES_PKG.user_message (
          p_app_name  => G_FEM
          ,p_msg_name => G_HIER_LDR_MISSING_ROOT_ERR
        );
        l_hierarchy_error_flag := true;

      elsif ((l_num_roots > 1) and (ld_multi_top_flag = 'N')) then

        if (p_dimension_varchar_label = 'CAL_PERIOD') then
          open cv_get_hier_roots
          for l_get_hier_roots_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name
          ,ld_calendar_dc
          ,l_dimension_id
          ,ld_calendar_id;
        else
          if (l_value_set_required_flag = 'Y') then
            open cv_get_hier_roots
            for l_get_hier_roots_stmt
            using ld_hierarchy_object_name
            ,ld_hier_obj_def_display_name
            ,l_dimension_id;
          else
            open cv_get_hier_roots
            for l_get_hier_roots_stmt
            using ld_hierarchy_object_name
            ,ld_hier_obj_def_display_name;
          end if;
        end if;

        l_get_hier_roots_is_open := true;

        loop

          fetch cv_get_hier_roots
          bulk collect into
          th_rowid
          ,th_child_id
          ,th_child_value_set_id
          ,th_child_dimension_grp_id
          ,th_display_order_num
          limit gv_fetch_limit;

          l_get_hier_roots_last_row := th_rowid.LAST;
          if (l_get_hier_roots_last_row is null) then
            exit;
          end if;

          l_hierarchy_error_flag := true;
          ld_status := 'MULTIPLE_TOP';

          set_hier_table_err_msg (
            p_hier_table_name => l_source_hier_table
            ,p_status         => ld_status
          );

          forall j in 1..l_get_hier_roots_last_row
            execute immediate
            bld_update_status_stmt (
              p_dimension_varchar_label    => p_dimension_varchar_label
              ,p_execution_mode            => p_execution_mode
              ,p_source_hier_table         => l_source_hier_table
              ,p_rowid_flag                => 'Y'
            )
            using ld_status
            ,th_rowid(j);

          commit;

          th_rowid.DELETE;
          th_child_id.DELETE;
          th_child_value_set_id.DELETE;
          th_child_dimension_grp_id.DELETE;
          th_display_order_num.DELETE;

        end loop;

        close cv_get_hier_roots;
        l_get_hier_roots_is_open := false;

      end if;

      exit to_next_hier_for_loading when l_hierarchy_error_flag;
--END:single_thread_validation

--BEGIN:build_root_node_slices
  ------------------------------------------------------------------------------
  -- STEP 6.6: Verify that root nodes do not appear as children of other
  -- nodes for the hierarchy in FEM_xName_HIER_T.
  ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.tech_message (
        p_severity  => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 6.6: Invalid Root Node Validation'
      );

      if (p_dimension_varchar_label = 'CAL_PERIOD') then
        open cv_bad_hier_roots
        for l_bad_hier_roots_stmt
        using ld_hierarchy_object_name
        ,ld_hier_obj_def_display_name
        ,ld_calendar_dc
        ,l_dimension_id
        ,ld_calendar_id;
      else
        if (l_value_set_required_flag = 'Y') then
          open cv_bad_hier_roots
          for l_bad_hier_roots_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name
          ,l_dimension_id;
        else
          open cv_bad_hier_roots
          for l_bad_hier_roots_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name;
        end if;
      end if;

      l_bad_hier_roots_is_open := true;

      loop

        fetch cv_bad_hier_roots
        bulk collect into
        th_rowid
        ,th_status
        limit gv_fetch_limit;

        l_bad_hier_roots_last_row := th_rowid.LAST;
        if (l_bad_hier_roots_last_row is null) then
          exit;
        end if;

        l_hierarchy_error_flag := true;
        ld_status := th_status(1);

        set_hier_table_err_msg (
          p_hier_table_name => l_source_hier_table
          ,p_status         => ld_status
        );

        forall j in 1..l_bad_hier_roots_last_row
          execute immediate
          bld_update_status_stmt (
            p_dimension_varchar_label    => p_dimension_varchar_label
            ,p_execution_mode            => p_execution_mode
            ,p_source_hier_table         => l_source_hier_table
            ,p_rowid_flag                => 'Y'
          )
          using th_status(j)
          ,th_rowid(j);

        commit;

        th_rowid.DELETE;
        th_status.DELETE;

      end loop;

      close cv_bad_hier_roots;
      l_bad_hier_roots_is_open := false;

      exit to_next_hier_for_loading when l_hierarchy_error_flag;

  ------------------------------------------------------------------------------
  -- STEP 7: Load hierarchy records from FEM_xNAME_HIER_T into
  -- FEM_HIERVAL_VSR_T/_CALP_T by flattening hierarchy.
  ------------------------------------------------------------------------------

      FEM_ENGINES_PKG.tech_message (
        p_severity => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 7: Inserting Flattened Hierarchy Records in '||l_target_hierval_table
      );

  ------------------------------------------------------------------------------
  -- STEP 7.1: Insert root node records from FEM_xNAME_HIER_T into
  -- FEM_HIERVAL_VSR_T/_CALP_T.
  ------------------------------------------------------------------------------

      FEM_ENGINES_PKG.tech_message (
        p_severity => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 7.1: Inserting Root Nodes Records in '||l_target_hierval_table
      );

      if (p_dimension_varchar_label = 'CAL_PERIOD') then
        open cv_get_hier_roots
        for l_get_hier_roots_stmt
        using ld_hierarchy_object_name
        ,ld_hier_obj_def_display_name
        ,ld_calendar_dc
        ,l_dimension_id
        ,ld_calendar_id;
      else
        if (l_value_set_required_flag = 'Y') then
          open cv_get_hier_roots
          for l_get_hier_roots_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name
          ,l_dimension_id;
        else
          open cv_get_hier_roots
          for l_get_hier_roots_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name;
        end if;
      end if;

      l_get_hier_roots_is_open := true;

      loop

        fetch cv_get_hier_roots
        bulk collect into
        th_rowid
        ,th_child_id
        ,th_child_value_set_id
        ,th_child_dimension_grp_id
        ,th_display_order_num
        limit gv_fetch_limit;

        l_get_hier_roots_last_row := th_rowid.LAST;
        if (l_get_hier_roots_last_row is null) then
          exit;
        end if;

        if (p_dimension_varchar_label = 'CAL_PERIOD') then
          forall j in 1..l_get_hier_roots_last_row
            execute immediate l_insert_hierval_rels_stmt
            using l_request_id
            ,th_rowid(j)
            ,1
            ,th_child_id(j)
            ,th_child_dimension_grp_id(j)
            ,1
            ,th_child_id(j)
            ,th_child_dimension_grp_id(j)
            ,th_display_order_num(j)
            ,to_number(null);
        else
          forall j in 1..l_get_hier_roots_last_row
            execute immediate l_insert_hierval_rels_stmt
            using l_request_id
            ,th_rowid(j)
            ,1
            ,th_child_id(j)
            ,th_child_value_set_id(j)
            ,th_child_dimension_grp_id(j)
            ,1
            ,th_child_id(j)
            ,th_child_value_set_id(j)
            ,th_child_dimension_grp_id(j)
            ,th_display_order_num(j)
            ,to_number(null);
        end if;

        th_rowid.DELETE;
        th_child_id.DELETE;
        th_child_value_set_id.DELETE;
        th_child_dimension_grp_id.DELETE;
        th_display_order_num.DELETE;

      end loop;

      close cv_get_hier_roots;
      l_get_hier_roots_is_open := false;

      commit;
--END:build_root_node_slices


--BEGIN:connect_by_processing
  ------------------------------------------------------------------------------
  -- STEP 7.2: Insert parent/child relationships from FEM_xName_HIER_T into
  -- FEM_HIERVAL_VSR_T/_CALP_T.  Only the "connect by" records need to be
  -- created at this stage.
  ------------------------------------------------------------------------------

      FEM_ENGINES_PKG.tech_message (
        p_severity => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 7.2: Inserting Relationship Records in '||l_target_hierval_table
      );

      if (p_dimension_varchar_label = 'CAL_PERIOD') then
        open cv_get_hier_rels
        for l_get_hier_rels_stmt
        using ld_hierarchy_object_name
        ,ld_hier_obj_def_display_name
        ,ld_calendar_dc
        ,ld_hierarchy_object_name
        ,ld_hier_obj_def_display_name
        ,ld_calendar_dc
        ,l_dimension_id
        ,ld_calendar_id
        ,ld_calendar_id;
      else
        if (l_value_set_required_flag = 'Y') then
          open cv_get_hier_rels
          for l_get_hier_rels_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name
          ,ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name
          ,l_dimension_id;
        else
          open cv_get_hier_rels
          for l_get_hier_rels_stmt
          using ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name
          ,ld_hierarchy_object_name
          ,ld_hier_obj_def_display_name;
        end if;
      end if;

      l_get_hier_rels_is_open := true;

      loop

        -- This fetch can throw an exception if there are circular references
        -- in the FEM_xName_HIER_T table.  Catch this exception to display it
        -- to user with a user friendly message.
        begin

          fetch cv_get_hier_rels
          bulk collect into
          th_rowid
          ,th_parent_depth_num
          ,th_parent_id
          ,th_parent_value_set_id
          ,th_parent_dimension_grp_id
          ,th_child_depth_num
          ,th_child_id
          ,th_child_value_set_id
          ,th_child_dimension_grp_id
          ,th_display_order_num
          ,th_wt_pct
          ,th_status
          limit gv_fetch_limit;

        exception

          when others then

            -- If the error code corresponds to a circular reference in a
            -- connect-by query, then update hierarchy status to indicate
            -- error.
            l_sql_err_code := SQLCODE;
            if (l_sql_err_code = g_connect_by_loop) then

              close cv_get_hier_rels;
              l_get_hier_rels_is_open := false;

              l_hierarchy_error_flag := true;
              ld_status := 'CIRCULAR_HIERARCHY';

              set_hier_table_err_msg (
                p_hier_table_name => l_source_hier_table
                ,p_status         => ld_status
              );

              execute immediate
              bld_update_status_stmt (
                p_dimension_varchar_label    => p_dimension_varchar_label
                ,p_execution_mode            => p_execution_mode
                ,p_source_hier_table         => l_source_hier_table
                ,p_hier_object_name_flag     => 'Y'
                ,p_hier_obj_def_name_flag    => 'Y'
              )
              using ld_status
              ,ld_hierarchy_object_name
              ,ld_hier_obj_def_display_name;

              commit;

              -- Do not perform any further hierarchy validations.  Exit out
              -- gracefully.
              exit to_next_hier_for_loading;

            else
              raise;
            end if;

        end;

        l_get_hier_rels_last_row := th_rowid.LAST;
        if (l_get_hier_rels_last_row is null) then
          exit;
        end if;

        if (p_dimension_varchar_label = 'CAL_PERIOD') then
          forall j in 1..l_get_hier_rels_last_row
            execute immediate l_insert_hierval_rels_stmt
            using l_request_id
            ,th_rowid(j)
            ,th_parent_depth_num(j)
            ,th_parent_id(j)
            ,th_parent_dimension_grp_id(j)
            ,th_child_depth_num(j)
            ,th_child_id(j)
            ,th_child_dimension_grp_id(j)
            ,th_display_order_num(j)
            ,th_wt_pct(j);
        else
          forall j in 1..l_get_hier_rels_last_row
            execute immediate l_insert_hierval_rels_stmt
            using l_request_id
            ,th_rowid(j)
            ,th_parent_depth_num(j)
            ,th_parent_id(j)
            ,th_parent_value_set_id(j)
            ,th_parent_dimension_grp_id(j)
            ,th_child_depth_num(j)
            ,th_child_id(j)
            ,th_child_value_set_id(j)
            ,th_child_dimension_grp_id(j)
            ,th_display_order_num(j)
            ,th_wt_pct(j);
        end if;

        commit;

        th_rowid.DELETE;
        th_parent_depth_num.DELETE;
        th_parent_id.DELETE;
        th_parent_value_set_id.DELETE;
        th_parent_dimension_grp_id.DELETE;
        th_child_depth_num.DELETE;
        th_child_id.DELETE;
        th_child_value_set_id.DELETE;
        th_child_dimension_grp_id.DELETE;
        th_display_order_num.DELETE;
        th_wt_pct.DELETE;
        th_status.DELETE;

      end loop;

      close cv_get_hier_rels;
      l_get_hier_rels_is_open := false;
--END:connect_by_processing

--BEGIN:final_hierval
  ------------------------------------------------------------------------------
  -- STEP 8: Verify for HIERARCHY_TYPE_CODE = RECONCILIATION that
  -- all dimension members have the correct "Reconciliation Child"
  -- attribute assignment.
  ------------------------------------------------------------------------------
      if (ld_hierarchy_type_code = 'RECONCILIATION') then

  ------------------------------------------------------------------------------
  -- STEP 8.1: Verify that all leaf nodes have RECON_LEAF_NODE_FLAG = Y
  ------------------------------------------------------------------------------
        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 8.1: Reconciliation Leaf Validation'
        );

        begin
          select att.attribute_id
          ,ver.version_id
          into l_attribute_id
          ,l_attr_version_id
          from fem_dim_attributes_b att
          ,fem_dim_attr_versions_b ver
          where att.attribute_varchar_label = 'RECON_LEAF_NODE_FLAG'
          and att.dimension_id = l_dimension_id
          and ver.attribute_id = att.attribute_id
          and ver.default_version_flag = 'Y';
        exception
          when others then
            FEM_ENGINES_PKG.user_message (
              p_app_name  => G_FEM
              ,p_msg_name => G_HIER_LDR_NO_LEAF_ATTR_ERR
              ,p_token1   => 'DIMENSION'
              ,p_value1   => p_dimension_varchar_label
            );
            l_hierarchy_error_flag := true;
            -- Do not perform any further hierarchy validations.  Exit out
            -- gracefully.
            exit to_next_hier_for_loading;
        end;

        open cv_bad_hier_rec_leafs
        for l_bad_hier_rec_leafs_stmt
        using l_request_id
        ,l_attribute_id
        ,l_attr_version_id;

        l_bad_hier_rec_leafs_is_open := true;

        loop

          fetch cv_bad_hier_rec_leafs
          bulk collect into
          th_rowid
          ,th_status
          limit gv_fetch_limit;

          l_bad_hier_rec_leafs_last_row := th_rowid.LAST;
          if (l_bad_hier_rec_leafs_last_row is null) then
            exit;
          end if;

          l_hierarchy_error_flag := true;
          ld_status := th_status(1);

          set_hier_table_err_msg (
            p_hier_table_name => l_source_hier_table
            ,p_status         => ld_status
          );

          forall j in 1..l_bad_hier_rec_leafs_last_row
            execute immediate
            bld_update_status_stmt (
              p_dimension_varchar_label    => p_dimension_varchar_label
              ,p_execution_mode            => p_execution_mode
              ,p_source_hier_table         => l_source_hier_table
              ,p_rowid_flag                => 'Y'
            )
            using th_status(j)
            ,th_rowid(j);

          commit;

          th_rowid.DELETE;
          th_status.DELETE;

        end loop;

        close cv_bad_hier_rec_leafs;
        l_bad_hier_rec_leafs_is_open := false;

        exit to_next_hier_for_loading when l_hierarchy_error_flag;

  ------------------------------------------------------------------------------
  -- STEP 8.2: Verify that all parent nodes have RECON_LEAF_NODE_FLAG = N
  ------------------------------------------------------------------------------
        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 8.2: Reconciliation Non-Leaf Validation'
        );

        open cv_bad_hier_rec_nodes
        for l_bad_hier_rec_nodes_stmt
        using l_request_id
        ,l_attribute_id
        ,l_attr_version_id;

        l_bad_hier_rec_nodes_is_open := true;

        loop

          fetch cv_bad_hier_rec_nodes
          bulk collect into
          th_rowid
          ,th_status
          limit gv_fetch_limit;

          l_bad_hier_rec_nodes_last_row := th_rowid.LAST;
          if (l_bad_hier_rec_nodes_last_row is null) then
            exit;
          end if;

          l_hierarchy_error_flag := true;
          ld_status := th_status(1);

          set_hier_table_err_msg (
            p_hier_table_name => l_source_hier_table
            ,p_status         => ld_status
          );

          forall j in 1..l_bad_hier_rec_nodes_last_row
            execute immediate
            bld_update_status_stmt (
              p_dimension_varchar_label    => p_dimension_varchar_label
              ,p_execution_mode            => p_execution_mode
              ,p_source_hier_table         => l_source_hier_table
              ,p_rowid_flag                => 'Y'
            )
            using th_status(j)
            ,th_rowid(j);

          commit;

          th_rowid.DELETE;
          th_status.DELETE;

        end loop;

        close cv_bad_hier_rec_nodes;
        l_bad_hier_rec_nodes_is_open := false;

        exit to_next_hier_for_loading when l_hierarchy_error_flag;

      end if;


  ------------------------------------------------------------------------------
  -- STEP 9: Verify for GROUP_SEQUENCE_ENFORCED_CODE <> NO_GROUPS
  -- that all parent/child relationships obey the Group sequence rules.
  ------------------------------------------------------------------------------
      if (ld_group_seq_enforced_code <> 'NO_GROUPS') then

        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 9: Group Sequencing Validation'
        );

  ------------------------------------------------------------------------------
  -- STEP 9.1: Validating that all hierarchy Nodes belong to a hierarchy
  -- dimension group.
  ------------------------------------------------------------------------------

        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 9.1: Validating that all Hierarchy Nodes belong to a Hierarchy Dimension Group'
        );

        if (ld_load_type = g_new_hier) then
          open cv_bad_hier_dim_groups
          for l_bad_hier_dim_groups_t_stmt
          using l_request_id
          ,ld_hierarchy_object_name
          ,l_dimension_id;
        else
          open cv_bad_hier_dim_groups
          for l_bad_hier_dim_groups_stmt
          using l_request_id
          ,ld_hierarchy_object_id;
        end if;

        l_bad_hier_dim_groups_is_open := true;

        loop

          fetch cv_bad_hier_dim_groups
          bulk collect into
          th_rowid
          ,th_status
          limit gv_fetch_limit;

          l_bad_hier_dim_groups_last_row := th_rowid.LAST;
          if (l_bad_hier_dim_groups_last_row is null) then
            exit;
          end if;

          l_hierarchy_error_flag := true;
          ld_status := th_status(1);

          set_hier_table_err_msg (
            p_hier_table_name => l_source_hier_table
            ,p_status         => ld_status
          );

          forall j in 1..l_bad_hier_dim_groups_last_row
            execute immediate
            bld_update_status_stmt (
              p_dimension_varchar_label    => p_dimension_varchar_label
              ,p_execution_mode            => p_execution_mode
              ,p_source_hier_table         => l_source_hier_table
              ,p_rowid_flag                => 'Y'
            )
            using th_status(j)
            ,th_rowid(j);

          commit;

          th_rowid.DELETE;
          th_status.DELETE;

        end loop;

        close cv_bad_hier_dim_groups;
        l_bad_hier_dim_groups_is_open := false;

        exit to_next_hier_for_loading when l_hierarchy_error_flag;

  ------------------------------------------------------------------------------
  -- STEP 9.2: Validating that all hierarchy nodes follow the correct hierarchy
  -- group sequencing order
  ------------------------------------------------------------------------------

        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 9.2: Validating that all Hierarchy Nodes follow the correct Hierarchy Group Sequencing Order'
        );

        -- Bug Fix 3923880: Provided support for skip-level hierarchies
        -- after DHM added SEQUENCE_ENFORCED_SKIP_LEVEL.  This bug fix is an
        -- enhancement to Bug Fix 3638231, where skip-level hierarchies
        -- were first implemented in the hierarchy loader.

        if (ld_group_seq_enforced_code = 'SEQUENCE_ENFORCED_SKIP_LEVEL') then

  ------------------------------------------------------------------------------
  -- STEP 9.2.1: Skip-Level Hierarchy Group Sequence Validation
  ------------------------------------------------------------------------------

          FEM_ENGINES_PKG.tech_message (
            p_severity  => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 9.2.1: Skip-Level Hierarchy Group Sequence validation'
          );

          open cv_bad_hier_dim_grp_sq
          for l_bad_hier_dim_grp_skp_stmt
          using l_request_id;

          l_bad_hier_dim_grp_sq_is_open := true;

          loop

            fetch cv_bad_hier_dim_grp_sq
            bulk collect into
            th_rowid
            ,th_status
            limit gv_fetch_limit;

            l_bad_hier_dim_grp_sq_last_row := th_rowid.LAST;
            if (l_bad_hier_dim_grp_sq_last_row is null) then
              exit;
            end if;

            l_hierarchy_error_flag := true;
            ld_status := th_status(1);

            set_hier_table_err_msg (
              p_hier_table_name => l_source_hier_table
              ,p_status         => ld_status
            );

            forall j in 1..l_bad_hier_dim_grp_sq_last_row
              execute immediate
              bld_update_status_stmt (
                p_dimension_varchar_label    => p_dimension_varchar_label
                ,p_execution_mode            => p_execution_mode
                ,p_source_hier_table         => l_source_hier_table
                ,p_rowid_flag                => 'Y'
              )
              using th_status(j)
              ,th_rowid(j);

            commit;

            th_rowid.DELETE;
            th_status.DELETE;

          end loop;

          close cv_bad_hier_dim_grp_sq;
          l_bad_hier_dim_grp_sq_is_open := false;

        elsif (ld_group_seq_enforced_code = 'SEQUENCE_ENFORCED') then

  ------------------------------------------------------------------------------
  -- STEP 9.2.2: Standard Hierarchy Group Sequence Validation
  ------------------------------------------------------------------------------

          FEM_ENGINES_PKG.tech_message (
            p_severity  => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 9.2.2: Standard Hierarchy Group Sequence validation'
          );

          if (ld_load_type = g_new_hier) then
            open cv_get_dim_groups
            for l_get_dim_groups_t_stmt
            using ld_hierarchy_object_name
            ,l_dimension_id;
          else
            open cv_get_dim_groups
            for l_get_dim_groups_stmt
            using ld_hierarchy_object_id;
          end if;

          l_get_dim_groups_is_open := true;

          loop

            fetch cv_get_dim_groups
            bulk collect into
            tg_dimension_group_id
            ,tg_depth_num
            limit gv_fetch_limit;

            l_get_dim_groups_last_row := tg_dimension_group_id.LAST;
            if (l_get_dim_groups_last_row is null) then
              exit;
            end if;

            -- Loop through all dimension groups specified for this hierarchy
            for i in 1..l_get_dim_groups_last_row loop

              open cv_bad_hier_dim_grp_sq
              for l_bad_hier_dim_grp_reg_stmt
              using l_request_id
              ,tg_depth_num(i)
              ,tg_dimension_group_id(i);

              l_bad_hier_dim_grp_sq_is_open := true;

              loop

                fetch cv_bad_hier_dim_grp_sq
                bulk collect into
                th_rowid
                ,th_status
                limit gv_fetch_limit;

                l_bad_hier_dim_grp_sq_last_row := th_rowid.LAST;
                if (l_bad_hier_dim_grp_sq_last_row is null) then
                  exit;
                end if;

                l_hierarchy_error_flag := true;
                ld_status := th_status(1);

                set_hier_table_err_msg (
                  p_hier_table_name => l_source_hier_table
                  ,p_status         => ld_status
                );

                forall j in 1..l_bad_hier_dim_grp_sq_last_row
                  execute immediate
                  bld_update_status_stmt (
                    p_dimension_varchar_label    => p_dimension_varchar_label
                    ,p_execution_mode            => p_execution_mode
                    ,p_source_hier_table         => l_source_hier_table
                    ,p_rowid_flag                => 'Y'
                  )
                  using th_status(j)
                  ,th_rowid(j);

                commit;

                th_rowid.DELETE;
                th_status.DELETE;

              end loop; -- cv_bad_hier_dim_grp_sq

              close cv_bad_hier_dim_grp_sq;
              l_bad_hier_dim_grp_sq_is_open := false;

            end loop;

            tg_dimension_group_id.DELETE;
            tg_depth_num.DELETE;

          end loop; -- cv_get_dim_groups

          close cv_get_dim_groups;
          l_get_dim_groups_is_open := false;

        end if;

        exit to_next_hier_for_loading when l_hierarchy_error_flag;

      end if;
--END:final_hierval

--BEGIN:multi_thread_final_insert
  ------------------------------------------------------------------------------
  -- STEP 10: If HIERARCHY_OBJECT_NAME does not exist, then insert the
  -- necessary rows in FEM_OBJECT_CATALOG_B/_TL, FEM_HIERARCHIES,
  -- FEM_HIER_DIMENSION_GRPS, and FEM_HIER_VALUE_SETS
  ------------------------------------------------------------------------------

      if (ld_load_type = g_new_hier) then

        -- Bug Fix 3920423: SINGLE VALUE_SET_ID HIERARCHY DOES NOT SHOW UP IN
        -- DEF LOV
        --
        -- If the hierarchy has a single value set defined, we must get the
        -- VALUE_SET_ID for FEM_HIERARCHIES.  This must be done before any
        -- inserts are made in FEM_OBJECT_CATALOG_B/_TL, as we can have an
        -- exception when trying to get the VALUE_SET_ID.
        if ( (l_value_set_required_flag = 'Y')
         and (ld_multi_value_set_flag = 'N') ) then

  ------------------------------------------------------------------------------
  -- STEP 10.1: Get the VALUE_SET_ID for FEM_HIERARCHIES
  ------------------------------------------------------------------------------
          FEM_ENGINES_PKG.tech_message (
            p_severity  => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 10.1: Get the VALUE_SET_ID for FEM_HIERARCHIES'
          );

          begin

            execute immediate l_get_value_sets_stmt
            into ld_value_set_id
            using ld_hierarchy_object_name
            ,l_dimension_id;

          exception

            when no_data_found then
              FEM_ENGINES_PKG.user_message (
                p_app_name  => G_FEM
                ,p_msg_name => G_HIER_LDR_NO_HIER_VS_ERR
                ,p_token1   => 'HIERARCHY_OBJECT_NAME'
                ,p_value1   => ld_hierarchy_object_name
              );
              l_hierarchy_error_flag := true;

            when too_many_rows then
              l_hierarchy_error_flag := true;
              ld_status := 'MULTIPLE_VALUE_SETS';

              set_hier_table_err_msg (
                p_hier_table_name => 'FEM_HIER_VALUE_SETS_T'
                ,p_status         => ld_status
              );

              execute immediate
              ' update fem_hier_value_sets_t'||
              ' set status = :b_status'||
              ' where hierarchy_object_name = :b_hierarchy_object_name'||
                l_status_clause||
              ' and language = userenv(''LANG'')'
              using ld_status
              ,ld_hierarchy_object_name;

          end;

          -- Exit immediately in an exception occurred to prevent any
          -- hierarchy inserts from happening.
          exit to_next_hier_for_loading when l_hierarchy_error_flag;

        else

          ld_value_set_id := null;

        end if;

  ------------------------------------------------------------------------------
  -- STEP 10.2: Insert into FEM_OBJECT_CATALOG_B/_TL
  ------------------------------------------------------------------------------
        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 10.2: Insert into FEM_OBJECT_CATALOG_B/_TL'
        );

        select fem_object_id_seq.nextval
        into ld_hierarchy_object_id
        from dual;

        FEM_OBJECT_CATALOG_PKG.INSERT_ROW (
          x_rowid => l_rowid
          ,x_object_id => ld_hierarchy_object_id
          ,x_object_type_code => 'HIERARCHY'
          ,x_folder_id => ld_folder_id
          ,x_local_vs_combo_id => null
          ,x_object_access_code => 'W' --todo
          ,x_object_origin_code => 'IMPORT' --todo
          ,x_object_version_number => g_object_version_number
          ,x_object_name => ld_hierarchy_object_name
          ,x_description => ld_hierarchy_object_name
          ,x_creation_date => sysdate
          ,x_created_by => l_user_id
          ,x_last_update_date => sysdate
          ,x_last_updated_by => l_user_id
          ,x_last_update_login => l_login_id
        );

  ------------------------------------------------------------------------------
  -- STEP 10.3: Insert into FEM_HIERARCHIES
  ------------------------------------------------------------------------------
        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 10.3: Insert into FEM_HIERARCHIES'
        );

        insert into fem_hierarchies (
          hierarchy_obj_id
          ,dimension_id
          ,hierarchy_type_code
          ,group_sequence_enforced_code
          ,multi_top_flag
          ,financial_category_flag
          ,value_set_id
          ,calendar_id
          ,period_type
          ,personal_flag
          ,flattened_rows_flag
          ,creation_date
          ,created_by
          ,last_updated_by
          ,last_update_date
          ,last_update_login
          ,hierarchy_usage_code
          ,multi_value_set_flag
          ,object_version_number
        ) values (
          ld_hierarchy_object_id
          ,l_dimension_id
          ,ld_hierarchy_type_code
          ,ld_group_seq_enforced_code
          ,ld_multi_top_flag
          ,'N'
          ,ld_value_set_id
          ,ld_calendar_id
          ,null
          ,'N'
          ,ld_flattened_rows_flag
          ,sysdate
          ,l_user_id
          ,l_user_id
          ,sysdate
          ,l_login_id
          ,ld_hierarchy_usage_code
          ,ld_multi_value_set_flag
          ,g_object_version_number
        );

  ------------------------------------------------------------------------------
  -- STEP 10.4: Insert into FEM_HIER_DIMENSION_GRPS
  ------------------------------------------------------------------------------
        if (ld_group_seq_enforced_code <> 'NO_GROUPS') then

          FEM_ENGINES_PKG.tech_message (
            p_severity  => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 10.4: Insert into FEM_HIER_DIMENSION_GRPS'
          );

          open cv_get_dim_groups
          for l_get_dim_groups_t_stmt
          using ld_hierarchy_object_name
          ,l_dimension_id;

          l_get_dim_groups_is_open := true;

          loop

            fetch cv_get_dim_groups
            bulk collect into
            tg_dimension_group_id
            ,tg_relative_dim_group_seq
            limit gv_fetch_limit;

            l_get_dim_groups_last_row := tg_dimension_group_id.LAST;
            if (l_get_dim_groups_last_row is null) then
              exit;
            end if;

            forall j in 1..l_get_dim_groups_last_row
              insert into fem_hier_dimension_grps (
                dimension_group_id
                ,hierarchy_obj_id
                ,relative_dimension_group_seq
                ,creation_date
                ,created_by
                ,last_updated_by
                ,last_update_date
                ,last_update_login
                ,object_version_number
              ) values (
                tg_dimension_group_id(j)
                ,ld_hierarchy_object_id
                ,tg_relative_dim_group_seq(j)
                ,sysdate
                ,l_user_id
                ,l_user_id
                ,sysdate
                ,l_login_id
                ,g_object_version_number
              );

            tg_dimension_group_id.DELETE;
            tg_relative_dim_group_seq.DELETE;

          end loop;

          close cv_get_dim_groups;
          l_get_dim_groups_is_open := false;

        end if;

        commit;

      end if;

  ------------------------------------------------------------------------------
  -- STEP 10.5: Insert into FEM_HIER_VALUE_SETS for new and updated hierarchies
  -- that must have value sets or that have a calendar context.
  ------------------------------------------------------------------------------
      if (l_value_set_required_flag = 'Y') then

        -- Insert for all new single or multi value set hiearchies, and for
        -- updates on multi value set hierarchies where we allow more value sets
        -- to be added (Bug 4661474).
        if ( (ld_load_type = g_new_hier) or (ld_multi_value_set_flag = 'Y') ) then

          FEM_ENGINES_PKG.tech_message (
            p_severity  => g_log_level_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 10.5: Insert into FEM_HIER_VALUE_SETS'
          );

          -- For updates on multi value set hierarchies, we must first delete
          -- all the hierarchy value sets in FEM_HIER_VALUE_SETS_T hat have
          -- already been assigned to the existing hierarchy (Bug 4661474).
          if (ld_load_type <> g_new_hier) then

            execute immediate
            ' delete from fem_hier_value_sets_t hvst'||
            ' where hvst.hierarchy_object_name = :b_hierarchy_object_name'||
              l_status_clause||
            ' and hvst.language = userenv(''LANG'')'||
            ' and exists ('||
            '   select 1'||
            '   from fem_hier_value_sets hvs'||
            '   ,fem_value_sets_b vsb'||
            '   where hvs.hierarchy_obj_id = :b_hierarchy_object_id'||
            '   and vsb.value_set_id = hvs.value_set_id'||
            '   and vsb.value_set_display_code = hvst.value_set_display_code'||
            ' )'
            using ld_hierarchy_object_name
            ,ld_hierarchy_object_id;

          end if;

          open cv_get_value_sets
          for l_get_value_sets_stmt
          using ld_hierarchy_object_name
          ,l_dimension_id;

          l_get_value_sets_is_open := true;

          loop

            fetch cv_get_value_sets
            bulk collect into
            tv_value_set_id
            limit gv_fetch_limit;

            l_get_value_sets_last_row := tv_value_set_id.LAST;
            if (l_get_value_sets_last_row is null) then
              exit;
            end if;

            forall j in 1..l_get_value_sets_last_row
              insert into fem_hier_value_sets (
                hierarchy_obj_id
                ,value_set_id
                ,creation_date
                ,created_by
                ,last_updated_by
                ,last_update_date
                ,last_update_login
                ,object_version_number
              ) values (
                ld_hierarchy_object_id
                ,tv_value_set_id(j)
                ,sysdate
                ,l_user_id
                ,l_user_id
                ,sysdate
                ,l_login_id
                ,g_object_version_number
              );

            tv_value_set_id.DELETE;

          end loop;

          close cv_get_value_sets;
          l_get_value_sets_is_open := false;

          commit;

        end if;

      -- Bug Fix 3789176: Add Calendar ID row in FEM_HIER_VALUE_SETS
      -- table for DHM when loading a new CAL_PERIOD hierarchy.
      elsif (p_dimension_varchar_label = 'CAL_PERIOD') then

        if (ld_load_type = g_new_hier) then

          insert into fem_hier_value_sets (
            hierarchy_obj_id
            ,value_set_id
            ,creation_date
            ,created_by
            ,last_updated_by
            ,last_update_date
            ,last_update_login
            ,object_version_number
          ) values (
            ld_hierarchy_object_id
            ,ld_calendar_id
            ,sysdate
            ,l_user_id
            ,l_user_id
            ,sysdate
            ,l_login_id
            ,g_object_version_number
          );

          commit;

        end if;

      end if;


  ------------------------------------------------------------------------------
  -- STEP 11: For each HIERARCHY_OBJ_DEF_DISPLAY_NAME check to see if it exists
  -- in FEM_OBJECT_DEFINITION_B/_TL for the designated language.  Create
  -- the necessary rows in FEM_OBJECT_DEFINITION_B/_TL and FEM_HIER_DEFINITIONS
  -- it does not exist.
  ------------------------------------------------------------------------------

      if (ld_load_type in (g_new_hier, g_new_hier_def)) then

        FEM_ENGINES_PKG.tech_message (
          p_severity  => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 11: Insert Hierarchy Object Definition Records'
        );

        if (l_new_max_obj_def_id is not null) then

          update fem_object_definition_b
          set effective_end_date = l_new_max_eff_end_date
          where object_definition_id = l_new_max_obj_def_id;

          l_new_max_obj_def_id := null;
          l_new_max_eff_end_date := null;

        end if;

        select fem_object_definition_id_seq.nextval
        into ld_hier_obj_def_id
        from dual;

        FEM_OBJECT_DEFINITION_PKG.INSERT_ROW (
          x_rowid => l_rowid
          ,x_object_definition_id => ld_hier_obj_def_id
          ,x_object_id => ld_hierarchy_object_id
          ,x_effective_start_date => ld_effective_start_date
          ,x_effective_end_date => ld_effective_end_date
          ,x_object_origin_code => 'IMPORT' --todo
          ,x_approval_status_code => 'NOT_APPLICABLE'
          ,x_old_approved_copy_flag => 'N'
          ,x_old_approved_copy_obj_def_id => null
          ,x_approved_by => null
          ,x_approval_date => null
          ,x_display_name => ld_hier_obj_def_display_name
          ,x_description => ld_hier_obj_def_display_name
          ,x_creation_date => sysdate
          ,x_created_by => l_user_id
          ,x_last_update_date => sysdate
          ,x_last_updated_by => l_user_id
          ,x_last_update_login => l_login_id
          ,x_object_version_number => g_object_version_number
        );

        insert into fem_hier_definitions (
          hierarchy_obj_def_id
          ,flattened_rows_completion_code
          ,creation_date
          ,created_by
          ,last_updated_by
          ,last_update_date
          ,last_update_login
          ,object_version_number
        ) values (
          ld_hier_obj_def_id
          ,decode(ld_flattened_rows_flag,'Y','PENDING','COMPLETED')
          ,sysdate
          ,l_user_id
          ,l_user_id
          ,sysdate
          ,l_login_id
          ,g_object_version_number
        );

        commit;

      end if;


  ------------------------------------------------------------------------------
  -- STEP 12: If the object definition already existed, then delete all rows in
  -- FEM_xName_HIER for that object definition.
  ------------------------------------------------------------------------------

      if (ld_load_type = g_update_hier_def) then

        FEM_ENGINES_PKG.tech_message (
          p_severity => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 12: Deleting Hierarchy Relationship Records'
        );

        execute immediate l_delete_hier_rels_stmt
        using ld_hier_obj_def_id;

        commit;

        -- Also update the Hierarchy Definition to 'PENDING' if the hierarchy
        -- will be flattened after loading completes.
        if (ld_flattened_rows_flag = 'Y') then

          update fem_hier_definitions
          set flattened_rows_completion_code = 'PENDING'
          ,last_updated_by = l_user_id
          ,last_update_date = sysdate
          ,last_update_login = l_login_id
          where hierarchy_obj_def_id = ld_hier_obj_def_id;

          commit;

        end if;

      end if;


  ------------------------------------------------------------------------------
  -- STEP 13: Insert all records for this request id from
  -- FEM_HIERVAL_VSR_T/_CALP_T into FEM_xName_HIER.
  ------------------------------------------------------------------------------

      FEM_ENGINES_PKG.tech_message (
        p_severity => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 13: Inserting Relationship Records into '||l_target_hierval_table
      );

      execute immediate l_insert_hier_rels_stmt
      using ld_hier_obj_def_id
      ,l_user_id
      ,l_user_id
      ,l_login_id
      ,g_object_version_number
      ,l_request_id;

      commit;


  ------------------------------------------------------------------------------
  -- STEP 14: Delete from the FEM_xName_HIER_T table rows for each hierarchy
  -- object definition that was successfully loaded.
  ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.tech_message (
        p_severity => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 14: Purging Relationship Interface Records in '||l_source_hier_table
      );

      execute immediate l_delete_hier_t_rels_stmt
      using ld_hierarchy_object_name
      ,ld_hier_obj_def_display_name;

      commit;


  ------------------------------------------------------------------------------
  -- STEP 15: Delete from the FEM_HIERARCHIES_T table rows for each hierarchy
  -- object definition that was successfully loaded.
  ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.tech_message (
        p_severity => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 15: Purging all other Hierarchy Interface tables'
      );

      -- Only delete hierarchy value sets from interface tables if they
      -- were inserted because a new hierarchy was loaded or an existing
       -- multi value set hierarchy was updated (Bug 4661474).
      if (l_value_set_required_flag = 'Y') then

        if ( (ld_load_type = g_new_hier) or (ld_multi_value_set_flag = 'Y') ) then

          execute immediate
          ' delete from fem_hier_value_sets_t'||
          ' where hierarchy_object_name = :b_hierarchy_object_name'||
            l_status_clause
          using ld_hierarchy_object_name;

        end if;

      end if;

      -- Only delete hierarchy dimension groups from interface tables if
      -- they were inserted because a new hierarchy was loaded.
      if (ld_load_type = g_new_hier) then

        if (ld_group_seq_enforced_code <> 'NO_GROUPS') then
          execute immediate
          ' delete from fem_hier_dim_grps_t'||
          ' where hierarchy_object_name = :b_hierarchy_object_name'||
            l_status_clause
          using ld_hierarchy_object_name;
        end if;

      end if;

      execute immediate
      ' delete from fem_hierarchies_t'||
      ' where rowid = :b_rowid'||
        l_status_clause
      using ld_rowid;

      commit;


  ------------------------------------------------------------------------------
  -- STEP 16: If FLATTENED_ROWS_FLAG = Y, then create all of the additional
  -- exploded rows by calling the DHM api.
  ------------------------------------------------------------------------------
      if (ld_flattened_rows_flag = 'Y') then

        FEM_ENGINES_PKG.tech_message (
          p_severity => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 16: Flattening Hierarchy'
        );

        FEM_HIER_UTILS_PVT.Flatten_Whole_Hier_Version (
          p_api_version        => 1.0
          ,p_commit            => FND_API.G_TRUE
          ,p_hier_obj_defn_id  => ld_hier_obj_def_id
          ,x_return_status     => l_return_status
          ,x_msg_count         => l_msg_count
          ,x_msg_data          => l_msg_data
        );

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

          --todo: this API should be put in a common loader package.
          get_put_messages (
            p_msg_count => l_msg_count
            ,p_msg_data => l_msg_data
          );

          FEM_ENGINES_PKG.user_message (
            p_app_name  => G_FEM
            ,p_msg_name => G_HIER_LDR_HIER_FLATTEN_ERR
          );

          -- Set the Concurrent Process to WARNING.
          l_completion_status := FND_CONCURRENT.set_completion_status('WARNING',null);

          exit to_next_hier_for_loading;

        end if;

      end if;

--END:multi_thread_final_insert

      -- Always exit the to_next_hier_for_loading loop at the end to ensure
      -- only one pass.
      exit to_next_hier_for_loading;

    end loop to_next_hier_for_loading;


    if (l_hierarchy_error_flag) then

      FEM_ENGINES_PKG.tech_message (
        p_severity => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Validation Error.  Updating Status on Interface Tables.'
      );

      execute immediate
      ' update fem_hierarchies_t'||
      ' set status = :b_status'||
      ' where rowid = :b_rowid'||
        l_status_clause
      using ld_status
      ,ld_rowid;

      -- For performance reasons, do not update all other tables and records
      -- to INVALID_HIERARCHY.
      --
      -- execute immediate
      -- ' update fem_hier_value_sets_t'||
      -- ' set status = ''INVALID_HIERARCHY'''||
      -- ' where hierarchy_object_name = ld_hierarchy_object_name'||
      --   l_status_clause
      -- using ld_hierarchy_object_name;
      --
      -- execute immediate
      -- ' update fem_hier_dim_grps_t'||
      -- ' set status = ''INVALID_HIERARCHY'''||
      -- ' where hierarchy_object_name = ld_hierarchy_object_name'||
      --   l_status_clause
      -- using ld_hierarchy_object_name;
      --
      -- execute immediate
      -- bld_update_status_stmt (
      --   p_dimension_varchar_label    => p_dimension_varchar_label
      --   ,p_execution_mode            => p_execution_mode
      --   ,p_source_hier_table         => l_source_hier_table
      --   ,p_hier_object_name_flag     => 'Y'
      --   ,p_hier_obj_def_name_flag    => 'Y'
      -- )
      -- using 'INVALID_HIERARCHY'
      -- ,ld_hierarchy_object_name
      -- ,ld_hier_obj_def_display_name;

      commit;

      -- Raise exception to perform engine post processing for an error.
      raise e_hierarchy_error;

    end if;

  end loop;

  close cv_get_hier_defs;
  l_get_hier_defs_is_open := false;

  ------------------------------------------------------------------------------
  -- STEP 17: Engine Master Post Processing.
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity => g_log_level_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 17: Post Processing'
  );

  eng_master_post_proc (
    p_request_id                 => l_request_id
    ,p_object_id                 => l_loader_object_id
    ,p_exec_status_code          => g_exec_status_success
    ,p_user_id                   => l_user_id
    ,p_login_id                  => l_login_id
    ,p_dimension_varchar_label   => p_dimension_varchar_label
    ,p_execution_mode            => p_execution_mode
    ,p_target_hierval_table      => l_target_hierval_table
  );

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when e_loader_error then

    FEM_ENGINES_PKG.tech_message(
      p_severity => g_log_level_6
      ,p_module => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Dimension Hierarchy Loader Exception'
    );

    l_completion_status := FND_CONCURRENT.set_completion_status('ERROR',null);

    eng_master_post_proc (
      p_request_id                 => l_request_id
      ,p_object_id                 => l_loader_object_id
      ,p_exec_status_code          => g_exec_status_error_rerun
      ,p_user_id                   => l_user_id
      ,p_login_id                  => l_login_id
      ,p_dimension_varchar_label   => p_dimension_varchar_label
      ,p_execution_mode            => p_execution_mode
      ,p_target_hierval_table      => l_target_hierval_table
    );

  when e_hierarchy_error then

    FEM_ENGINES_PKG.tech_message(
      p_severity => g_log_level_6
      ,p_module => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Hierarchy Exception'
    );

    l_completion_status := FND_CONCURRENT.set_completion_status('ERROR',null);

    if (l_get_hier_defs_is_open) then
     close cv_get_hier_defs;
    end if;

    eng_master_post_proc (
      p_request_id                 => l_request_id
      ,p_object_id                 => l_loader_object_id
      ,p_exec_status_code          => g_exec_status_error_rerun
      ,p_user_id                   => l_user_id
      ,p_login_id                  => l_login_id
      ,p_dimension_varchar_label   => p_dimension_varchar_label
      ,p_execution_mode            => p_execution_mode
      ,p_target_hierval_table      => l_target_hierval_table
    );

  when others then

    gv_prg_msg := sqlerrm;
    gv_callstack := dbms_utility.format_call_stack;

    FEM_ENGINES_PKG.tech_message(
      p_severity => g_log_level_6
      ,p_module => G_BLOCK||'.'||l_api_name||'.Unexpected_Exception.Error_Message'
      ,p_msg_text => gv_prg_msg
    );

    FEM_ENGINES_PKG.tech_message(
      p_severity => g_log_level_6
      ,p_module => G_BLOCK||'.'||l_api_name||'.Unexpected_Exception.Callstack'
      ,p_msg_text => gv_callstack
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_UNEXPECTED_ERROR
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => gv_prg_msg
    );

    l_completion_status := FND_CONCURRENT.set_completion_status('ERROR',null);

    if (l_bad_value_sets_is_open) then
     close cv_bad_value_sets;
    end if;
    if (l_bad_dim_groups_is_open) then
     close cv_bad_dim_groups;
    end if;
    if (l_bad_hier_calendars_is_open) then
     close cv_bad_hier_calendars;
    end if;
    if (l_bad_hier_value_sets_is_open) then
     close cv_bad_hier_value_sets;
    end if;
    if (l_bad_hier_members_is_open) then
     close cv_bad_hier_members;
    end if;
    if (l_bad_hier_dups_is_open) then
     close cv_bad_hier_dups;
    end if;
    if (l_bad_hier_rec_leafs_is_open) then
     close cv_bad_hier_rec_leafs;
    end if;
    if (l_bad_hier_rec_nodes_is_open) then
     close cv_bad_hier_rec_nodes;
    end if;
    if (l_bad_hier_roots_is_open) then
     close cv_bad_hier_roots;
    end if;
    if (l_bad_hier_dim_groups_is_open) then
     close cv_bad_hier_dim_groups;
    end if;
    if (l_bad_hier_dim_grp_sq_is_open) then
     close cv_bad_hier_dim_grp_sq;
    end if;
    if (l_get_dim_groups_is_open) then
     close cv_get_dim_groups;
    end if;
    if (l_get_value_sets_is_open) then
     close cv_get_value_sets;
    end if;
    if (l_get_hier_defs_is_open) then
     close cv_get_hier_defs;
    end if;
    if (l_get_hier_roots_is_open) then
     close cv_get_hier_roots;
    end if;
    if (l_get_hier_rels_is_open) then
     close cv_get_hier_rels;
    end if;

    eng_master_post_proc (
      p_request_id                 => l_request_id
      ,p_object_id                 => l_loader_object_id
      ,p_exec_status_code          => g_exec_status_error_rerun
      ,p_user_id                   => l_user_id
      ,p_login_id                  => l_login_id
      ,p_dimension_varchar_label   => p_dimension_varchar_label
      ,p_execution_mode            => p_execution_mode
      ,p_target_hierval_table      => l_target_hierval_table
    );

    -- Bug Fix 3657227: removing this raise statement because it causes
    -- ORACLE error 6502 in FDPSTP when it is called.
    --
    -- raise;

END Main;



/*===========================================================================+
 | PROCEDURE
 |    GET_DIMENSION_INFO
 |
 | DESCRIPTION
 |    Validates the input dimension and obtains object and column names
 |    for the dimension
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE get_dimension_info (
  p_dimension_varchar_label     in varchar2
  ,x_dimension_id               out nocopy number
  ,x_target_hier_table          out nocopy varchar2
  ,x_source_hier_table          out nocopy varchar2
  ,x_member_b_table             out nocopy varchar2
  ,x_member_attr_table          out nocopy varchar2
  ,x_member_col                 out nocopy varchar2
  ,x_member_dc_col              out nocopy varchar2
  ,x_group_use_code             out nocopy varchar2
  ,x_value_set_required_flag    out nocopy varchar2
  ,x_hier_type_allowed_code     out nocopy varchar2
  ,x_hier_versioning_type_code  out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'get_dimension_info';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  select dimension_id
  ,hierarchy_table_name
  ,hierarchy_table_name||'_T'
  ,member_b_table_name
  ,attribute_table_name
  ,member_col
  ,member_display_code_col
  ,group_use_code
  ,value_set_required_flag
  ,hier_type_allowed_code
  ,hier_versioning_type_code
  into x_dimension_id
  ,x_target_hier_table
  ,x_source_hier_table
  ,x_member_b_table
  ,x_member_attr_table
  ,x_member_col
  ,x_member_dc_col
  ,x_group_use_code
  ,x_value_set_required_flag
  ,x_hier_type_allowed_code
  ,x_hier_versioning_type_code
  from fem_xdim_dimensions_vl
  where dimension_varchar_label = p_dimension_varchar_label
  and composite_dimension_flag = 'N'
  and hierarchy_table_name is not null
  and read_only_flag = 'N';

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when no_data_found then
    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_DIM_NOT_FOUND_ERR
    );
    raise e_loader_error;

END get_dimension_info;



/*===========================================================================+
 | PROCEDURE
 |    REGISTER_PROCESS_EXECUTION
 |
 | DESCRIPTION
 |    Registers the request, object execution and object definition in the
 |    processing locks tables.
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE register_process_execution (
  p_request_id                 in number
  ,p_object_id                 in number
  ,p_obj_def_id                in number
  ,p_execution_mode            in varchar
  ,p_user_id                   in number
  ,p_login_id                  in number
  ,p_pgm_id                    in number
  ,p_pgm_app_id                in number
  ,p_hierarchy_object_name     in varchar2
)
IS

  l_api_name         constant varchar2(30) := 'register_process_execution';

  l_exec_state       varchar2(30); -- normal, restart, rerun
  l_stmt_type        fem_pl_tables.statement_type%TYPE;
  l_prev_request_id  number;

  l_return_status              t_return_status%TYPE;
  l_msg_count                  t_msg_count%TYPE;
  l_msg_data                   t_msg_data%TYPE;

  e_pl_register_req_failed     exception;
  e_pl_register_exec_failed    exception;
  e_pl_register_obj_def_failed exception;

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  savepoint register_process_execution_pub;

  -- Call the FEM_PL_PKG.Register_Request API procedure to register
  -- the concurrent request in FEM_PL_REQUESTS.  For hierarchy loader process
  -- locks, we must pass hierarchy_object_name to make sure that specified
  -- hierarchy object can only be loaded by one user at a time.  Do not pass
  -- dimension id, as the PL fwk uses that for dimension loader process locks.
  FEM_PL_PKG.register_request (
    p_api_version                => 1.0
    ,p_request_id                => p_request_id
    ,p_user_id                   => p_user_id
    ,p_last_update_login         => p_login_id
    ,p_program_id                => p_pgm_id
    ,p_program_login_id          => p_login_id
    ,p_program_application_id    => p_pgm_app_id
    ,p_exec_mode_code            => p_execution_mode
    ,p_hierarchy_name            => p_hierarchy_object_name
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data
    ,x_return_status             => l_return_status
  );

  -- Request Lock exists
  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    --todo: this API should be put in a common loader package.
    get_put_messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise e_pl_register_req_failed;
  end if;

  -- Call the FEM_PL_PKG.Register_Object_Execution API procedure to register
  -- the object execution in FEM_PL_OBJECT_EXECUTIONS to obtain an execution
  -- lock.
  FEM_PL_PKG.register_object_execution (
    p_api_version                => 1.0
    ,p_request_id                => p_request_id
    ,p_object_id                 => p_object_id
    ,p_exec_object_definition_id => p_obj_def_id
    ,p_user_id                   => p_user_id
    ,p_last_update_login         => p_login_id
    ,p_exec_mode_code            => p_execution_mode
    ,x_exec_state                => l_exec_state
    ,x_prev_request_id           => l_prev_request_id
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data
    ,x_return_status             => l_return_status
  );

  -- Object Execution Lock exists
  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    --todo: this API should be put in a common loader package.
    get_put_messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise e_pl_register_exec_failed;
  end if;

  FEM_PL_PKG.register_object_def (
    p_api_version                => 1.0
    ,p_request_id                => p_request_id
    ,p_object_id                 => p_object_id
    ,p_object_definition_id      => p_obj_def_id
    ,p_user_id                   => p_user_id
    ,p_last_update_login         => p_login_id
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data
    ,x_return_status             => l_return_status
  );

  -- Object Definition Lock exists
  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    --todo: this API should be put in a common loader package.
    get_put_messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise e_pl_register_obj_def_failed;
  end if;

  commit;

  FEM_ENGINES_PKG.tech_message (
    p_severity => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when e_pl_register_req_failed then

    rollback to register_process_execution_pub;
    FEM_ENGINES_PKG.tech_message(
      p_severity => g_log_level_6
      ,p_module => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Reqister Request Exception'
    );
    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_PL_REG_REQUEST_ERR
    );
    raise e_loader_error;

  when e_pl_register_exec_failed then

    rollback to register_process_execution_pub;
    FEM_ENGINES_PKG.tech_message(
      p_severity => g_log_level_6
      ,p_module => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Reqister Object Execution Exception'
    );
    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_PL_OBJ_EXEC_LOCK_ERR
    );
    raise e_loader_error;

  when e_pl_register_obj_def_failed then

    rollback to register_process_execution_pub;
    FEM_ENGINES_PKG.tech_message(
      p_severity => g_log_level_6
      ,p_module => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Reqister Object Definition Exception'
    );
    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_PL_OBJ_EXECLOCK_EXISTS_ERR
      ,p_token1   => 'OBJECT_ID'
      ,p_value1   => p_object_id
    );
    raise e_loader_error;

END register_process_execution;



/*===========================================================================+
 | PROCEDURE
 |    ENG_MASTER_POST_PROC
 |
 | DESCRIPTION
 |    Updates the status of the request and object execution in the
 |    processing locks tables.
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE eng_master_post_proc (
  p_request_id                 in number
  ,p_object_id                 in number
  ,p_exec_status_code          in varchar2
  ,p_user_id                   in number
  ,p_login_id                  in number
  ,p_dimension_varchar_label   in varchar2
  ,p_execution_mode            in varchar2
  ,p_target_hierval_table      in varchar2
)
IS

  l_api_name         constant varchar2(30) := 'register_process_execution';

  l_delete_hierval_rels_stmt        varchar2(10000);

  l_return_status                   t_return_status%TYPE;
  l_msg_count                       t_msg_count%TYPE;
  l_msg_data                        t_msg_data%TYPE;

  l_completion_status               boolean;

  e_post_process exception;

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------------------------------------
  -- STEP 1: Delete all records for this request id in the
  -- FEM_HIERVAL_VSR_T/_CALP_T table.
  ------------------------------------------------------------------------------
  if (p_target_hierval_table is not null) then

    FEM_ENGINES_PKG.tech_message (
      p_severity => g_log_level_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 1:  Purging Relationship Records in '||p_target_hierval_table
    );

    bld_delete_hier_rels_stmt (
      p_dimension_varchar_label      => p_dimension_varchar_label
      ,p_execution_mode              => p_execution_mode
      ,p_target_hierval_table        => p_target_hierval_table
      ,x_delete_hier_rels_stmt       => l_delete_hierval_rels_stmt
    );

    execute immediate l_delete_hierval_rels_stmt
    using p_request_id;

    commit;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 2: Update Object Execution Errors and Status.
  ------------------------------------------------------------------------------

  FEM_ENGINES_PKG.tech_message (
    p_severity => g_log_level_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 2:  Update Object Execution Errors and the Status'
  );

  if (p_exec_status_code <> g_exec_status_success) then

    -- Since a hierarchy load is an all or nothing process, the number
    -- of errors reported will be 1.
    FEM_PL_PKG.update_obj_exec_errors (
      p_api_version               => 1.0
      ,p_request_id               => p_request_id
      ,p_object_id                => p_object_id
      ,p_errors_reported          => 1
      ,p_errors_reprocessed       => 0
      ,p_user_id                  => p_user_id
      ,p_last_update_login        => p_login_id
      ,x_msg_count                => l_msg_count
      ,x_msg_data                 => l_msg_data
      ,x_return_status            => l_return_status
    );

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      --todo: this API should be put in a common loader package.
      get_put_messages (
        p_msg_count => l_msg_count
        ,p_msg_data => l_msg_data
      );
      raise e_post_process;
    end if;

  end if;

  ------------------------------------
  -- Update Object Execution Status --
  ------------------------------------
  FEM_PL_PKG.update_obj_exec_status (
    p_api_version               => 1.0
    ,p_request_id               => p_request_id
    ,p_object_id                => p_object_id
    ,p_exec_status_code         => p_exec_status_code
    ,p_user_id                  => p_user_id
    ,p_last_update_login        => p_login_id
    ,x_msg_count                => l_msg_count
    ,x_msg_data                 => l_msg_data
    ,x_return_status            => l_return_status
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    --todo: this API should be put in a common loader package.
    get_put_messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise e_post_process;
  end if;

  ---------------------------
  -- Update Request Status --
  ---------------------------
  FEM_PL_PKG.update_request_status (
    p_api_version               => 1.0
    ,p_request_id               => p_request_id
    ,p_exec_status_code         => p_exec_status_code
    ,p_user_id                  => p_user_id
    ,p_last_update_login        => p_login_id
    ,x_msg_count                => l_msg_count
    ,x_msg_data                 => l_msg_data
    ,x_return_status            => l_return_status
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    --todo: this API should be put in a common loader package.
    get_put_messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise e_post_process;
  end if;

  commit;

  -- Set the final execution status message in the Log File
  if (p_exec_status_code = g_exec_status_success) then
    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_EXEC_SUCCESS
    );
  else
    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_EXEC_RERUN
    );
  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when e_post_process then

    FEM_ENGINES_PKG.tech_message(
      p_severity => g_log_level_6
      ,p_module => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Post Process Exception'
    );

    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_EXT_LDR_POST_PROC_ERR
    );

    -- Set the final execution status message in the Log File to RERUN
    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_EXEC_RERUN
    );

    -- Set the Concurrent Request status to ERROR
    l_completion_status := FND_CONCURRENT.set_completion_status('ERROR',null);

END eng_master_post_proc;



/*===========================================================================+
 | PROCEDURE
 |    GET_PUT_MESSAGES
 |
 | DESCRIPTION
 |    Copied from FEM_DATAX_LOADER_PKG.  Will be replaced when GET_PUT_MESSAGES
 |    is placed in the common loader package.
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE get_put_messages (
  p_msg_count                 in number
  ,p_msg_data                 in varchar2
)
IS

  l_msg_count        t_msg_count%TYPE;
  l_msg_data         t_msg_data%TYPE;
  l_msg_out          t_msg_count%TYPE;
  l_message          t_msg_data%TYPE;

  l_api_name         constant varchar2(80) := 'get_put_messages';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'msg_count='||p_msg_count
  );

  l_msg_data := p_msg_data;

  if (p_msg_count = 1) then

    FND_MESSAGE.set_encoded(l_msg_data);
    l_message := FND_MESSAGE.get;

    FEM_ENGINES_PKG.user_message(
      p_msg_text => l_message
    );

    FEM_ENGINES_PKG.tech_message (
      p_severity  => g_log_level_2
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'msg_data='||l_message
    );

  elsif (p_msg_count > 1) then

    for i in 1..p_msg_count loop

      FND_MSG_PUB.get (
        p_msg_index      => i
        ,p_encoded       => FND_API.G_FALSE
        ,p_data          => l_message
        ,p_msg_index_out => l_msg_out
      );

      FEM_ENGINES_PKG.user_message (
        p_msg_text => l_message
      );

      FEM_ENGINES_PKG.tech_message (
        p_severity  => g_log_level_2
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'msg_data='||l_message
      );

    end loop;

  end if;

  FND_MSG_PUB.Initialize;

END get_put_messages;



/*===========================================================================+
 | PROCEDURE
 |    GET_DEFAULT_START_DATE
 |
 | DESCRIPTION
 |    Gets the default start date.
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

FUNCTION get_default_start_date
RETURN date
IS

  l_api_name            constant varchar2(80) := 'get_default_start_date';

BEGIN

  if (gv_default_start_date is null) then
    gv_default_start_date := FEM_BUSINESS_RULE_PVT.GetDefaultStartDate;
  end if;

  return gv_default_start_date;

END get_default_start_date;



/*===========================================================================+
 | PROCEDURE
 |    GET_DEFAULT_END_DATE
 |
 | DESCRIPTION
 |    Gets the default end date.
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

FUNCTION get_default_end_date
RETURN date
IS

  l_api_name            constant varchar2(80) := 'get_default_end_date';

BEGIN

  if (gv_default_end_date is null) then
    gv_default_end_date := FEM_BUSINESS_RULE_PVT.GetDefaultEndDate;
  end if;

  return gv_default_end_date;

END get_default_end_date;



/*===========================================================================+
 | PROCEDURE
 |    SET_HIER_TABLE_ERR_MSG
 |
 | DESCRIPTION
 |    Set a user message to indicate that a hierarchy validition exception
 |    occurred in the specified hierarchy interface table.  Users will have to
 |    check the STATUS column of the specified table for details on the
 |    validation exception.
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE set_hier_table_err_msg (
  p_hier_table_name            in varchar2
  ,p_status                    in varchar2
)
IS

  l_message_name               varchar2(30);

BEGIN

  l_message_name :=
    case p_status
      when 'CHILD_WITH_MULTIPLE_PARENTS' then G_HIER_LDR_MULTI_PARENT_ERR
      when 'CIRCULAR_HIERARCHY' then G_HIER_LDR_CIRC_HIER_ERR
      when 'GROUP_SEQ_RULE_VIOLATED' then G_HIER_LDR_GRP_SEQ_RULE_ERR
      when 'INVALID_CALENDAR' then G_HIER_LDR_INV_CALENDAR_ERR
      when 'INVALID_DIMENSION_GROUP' then G_EXT_LDR_INV_DIM_GRP_ERR
      when 'INVALID_MEMBER' then G_EXT_LDR_INV_MEMBER_ERR
      when 'INVALID_ROOT_NODE' then G_HIER_LDR_INV_ROOT_NODE_ERR
      when 'INVALID_RECONCILIATION_LEAF' then G_HIER_LDR_RECON_LEAF_ERR
      when 'INVALID_RECONCILIATION_NODE' then G_HIER_LDR_RECON_NODE_ERR
      when 'INVALID_VALUE_SET' then G_EXT_LDR_INV_VALUE_SET_ERR
      when 'MULTIPLE_TOP' then G_HIER_LDR_MULTI_TOP_ERR
      when 'MULTIPLE_VALUE_SETS' then G_HIER_LDR_MULTI_VS_ERR
    end;

  if (l_message_name is not null) then
    FND_MESSAGE.Set_Name(G_FEM,l_message_name);
  end if;

  FEM_ENGINES_PKG.user_message (
    p_app_name  => G_FEM
    ,p_msg_name => G_HIER_LDR_HIER_DETAILS_ERR
    ,p_token1   => 'HIER_TABLE_NAME'
    ,p_value1   => p_hier_table_name
    ,p_token2   => 'ERROR_MESSAGE_TEXT'
    ,p_value2   => FND_MESSAGE.Get
    ,p_token3   => 'STATUS_CODE'
    ,p_value3   => p_status
  );

END set_hier_table_err_msg;


/******************************************************************************/

PROCEDURE bld_bad_value_sets_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,x_bad_value_sets_stmt         out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_value_sets_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and hvst.status = ''LOAD''';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_bad_value_sets_stmt := '';

  else

    if (p_value_set_required_flag = 'Y') then

      x_bad_value_sets_stmt :=
      ' select hvst.rowid'||
      ' ,''INVALID_VALUE_SET'''||
      ' from fem_hier_value_sets_t hvst'||
      ' where hvst.hierarchy_object_name = :b_hierarchy_object_name'||
        l_status_clause||
      ' and hvst.language = userenv(''LANG'')'||
      ' and not exists ('||
      '   select 1'||
      '   from fem_value_sets_b vs'||
      '   where vs.value_set_display_code = hvst.value_set_display_code'||
      '   and vs.dimension_id = :b_dimension_id'||
      ' )';

    else

      x_bad_value_sets_stmt := '';

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_value_sets_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_dim_groups_stmt (
  p_dimension_varchar_label    in varchar2
  ,p_execution_mode            in varchar2
  ,x_bad_dim_groups_stmt       out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_dim_groups_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and hdgt.status = ''LOAD''';
  end if;

  x_bad_dim_groups_stmt :=
  ' select hdgt.rowid'||
  ' ,''INVALID_DIMENSION_GROUP'''||
  ' from fem_hier_dim_grps_t hdgt'||
  ' where hdgt.hierarchy_object_name = :b_hierarchy_object_name'||
    l_status_clause||
  ' and hdgt.language = userenv(''LANG'')'||
  ' and not exists ('||
  '   select 1'||
  '   from fem_dimension_grps_b dg'||
  '   where dg.dimension_group_display_code = hdgt.dimension_group_display_code'||
  '   and dg.dimension_id = :b_dimension_id'||
  ' )';

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_dim_groups_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_calendars_stmt (
  p_dimension_varchar_label    in varchar2
  ,p_execution_mode            in varchar2
  ,p_source_hier_table         in varchar2
  ,x_bad_hier_calendars_stmt   out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_calendars_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and ht.status = ''LOAD''';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_bad_hier_calendars_stmt :=
    ' select ht.rowid'||
    ' ,''INVALID_CALENDAR'''||
    ' from '||p_source_hier_table||' ht'||
    ' where ht.hierarchy_object_name = :b_hierarchy_object_name'||
    ' and ht.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
    ' and ht.calendar_display_code <> :b_calendar_display_code'||
      l_status_clause||
    ' and ht.language = userenv(''LANG'')';

  else

    x_bad_hier_calendars_stmt := '';

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_calendars_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_value_sets_t_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,x_bad_hier_value_sets_t_stmt  out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_value_sets_t_stmt';
  l_status_clause_1  varchar2(100) := '';
  l_status_clause_2  varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause_1 := ' and ht.status = ''LOAD''';
    l_status_clause_2 := ' and hvst.status = ''LOAD''';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_bad_hier_value_sets_t_stmt := '';

  else

    if (p_value_set_required_flag = 'Y') then

      x_bad_hier_value_sets_t_stmt :=
      ' select ht.rowid'||
      ' ,''INVALID_VALUE_SET'''||
      ' from '||p_source_hier_table||' ht'||
      ' where ht.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and ht.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause_1||
      ' and ht.language = userenv(''LANG'')'||
      ' and ('||
      '   not exists ('||
      '     select 1'||
      '     from fem_hier_value_sets_t hvst'||
      '     where hvst.hierarchy_object_name = ht.hierarchy_object_name'||
      '     and hvst.value_set_display_code = ht.parent_value_set_display_code'||
            l_status_clause_2||
      '     and hvst.language = userenv(''LANG'')'||
      '   )'||
      '   or'||
      '   not exists ('||
      '     select 1'||
      '     from fem_hier_value_sets_t hvst'||
      '     where hvst.hierarchy_object_name = ht.hierarchy_object_name'||
      '     and hvst.value_set_display_code = ht.child_value_set_display_code'||
            l_status_clause_2||
      '     and hvst.language = userenv(''LANG'')'||
      '   )'||
      ' )';

    else

      x_bad_hier_value_sets_t_stmt := '';

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_value_sets_t_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_value_sets_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,x_bad_hier_value_sets_stmt    out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_value_sets_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and ht.status = ''LOAD''';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_bad_hier_value_sets_stmt := '';

  else

    if (p_value_set_required_flag = 'Y') then

      x_bad_hier_value_sets_stmt :=
      ' select ht.rowid'||
      ' ,''INVALID_VALUE_SET'''||
      ' from '||p_source_hier_table||' ht'||
      ' where ht.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and ht.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause||
      ' and ht.language = userenv(''LANG'')'||
      ' and ('||
      '   not exists ('||
      '     select 1'||
      '     from fem_hier_value_sets hvs'||
      '     ,fem_value_sets_b vsb'||
      '     where hvs.hierarchy_obj_id = :b_hierarchy_object_id'||
      '     and vsb.value_set_id = hvs.value_set_id'||
      '     and vsb.value_set_display_code = ht.parent_value_set_display_code'||
      '   )'||
      '   or'||
      '   not exists ('||
      '     select 1'||
      '     from fem_hier_value_sets hvs'||
      '     ,fem_value_sets_b vsb'||
      '     where hvs.hierarchy_obj_id = :b_hierarchy_object_id'||
      '     and vsb.value_set_id = hvs.value_set_id'||
      '     and vsb.value_set_display_code = ht.child_value_set_display_code'||
      '   )'||
      ' )';

    else

      x_bad_hier_value_sets_stmt := '';

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_value_sets_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_multi_vs_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,x_bad_hier_multi_vs_stmt      out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_multi_vs_stmt';
  l_status_clause_1  varchar2(100) := '';
  l_status_clause_2  varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause_1 := ' and ht.status = ''LOAD''';
    l_status_clause_2 := ' and hvst.status = ''LOAD''';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_bad_hier_multi_vs_stmt := '';

  else

    if (p_value_set_required_flag = 'Y') then

      x_bad_hier_multi_vs_stmt :=
      ' select ht.rowid'||
      ' ,''INVALID_VALUE_SET'''||
      ' from '||p_source_hier_table||' ht'||
      ' where ht.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and ht.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause_1||
      ' and ht.language = userenv(''LANG'')'||
      ' and ('||
      '   ('||
      '     not exists ('||
      '       select 1'||
      '       from fem_hier_value_sets hvs'||
      '       ,fem_value_sets_b vsb'||
      '       where hvs.hierarchy_obj_id = :b_hierarchy_object_id'||
      '       and vsb.value_set_id = hvs.value_set_id'||
      '       and vsb.value_set_display_code = ht.parent_value_set_display_code'||
      '     )'||
      '     and'||
      '     not exists ('||
      '       select 1'||
      '       from fem_hier_value_sets_t hvst'||
      '       where hvst.hierarchy_object_name = ht.hierarchy_object_name'||
      '       and hvst.value_set_display_code = ht.parent_value_set_display_code'||
              l_status_clause_2||
      '       and hvst.language = userenv(''LANG'')'||
      '     )'||
      '   )'||
      '   or ('||
      '     not exists ('||
      '       select 1'||
      '       from fem_hier_value_sets hvs'||
      '       ,fem_value_sets_b vsb'||
      '       where hvs.hierarchy_obj_id = :b_hierarchy_object_id'||
      '       and vsb.value_set_id = hvs.value_set_id'||
      '       and vsb.value_set_display_code = ht.child_value_set_display_code'||
      '     )'||
      '     and'||
      '     not exists ('||
      '       select 1'||
      '       from fem_hier_value_sets_t hvst'||
      '       where hvst.hierarchy_object_name = ht.hierarchy_object_name'||
      '       and hvst.value_set_display_code = ht.child_value_set_display_code'||
              l_status_clause_2||
      '       and hvst.language = userenv(''LANG'')'||
      '     )'||
      '   )'||
      ' )';

    else

      x_bad_hier_multi_vs_stmt := '';

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_multi_vs_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_members_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,p_member_b_table              in varchar2
  ,p_member_col                  in varchar2
  ,p_member_dc_col               in varchar2
  ,x_bad_hier_members_stmt       out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_members_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and ht.status = ''LOAD''';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_bad_hier_members_stmt :=
    ' select ht.rowid'||
    ' ,''INVALID_MEMBER'''||
    ' from '||p_source_hier_table||' ht'||
    ' where ht.hierarchy_object_name = :b_hierarchy_object_name'||
    ' and ht.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
    ' and ht.calendar_display_code = :b_calendar_display_code'||
      l_status_clause||
    ' and ht.language = userenv(''LANG'')'||
    ' and ('||
    '   not exists ('||
    '     select 1'||
    '     from fem_dimension_grps_b dg'||
    '     ,'||p_member_b_table||' b'||
    '     where dg.dimension_group_display_code = ht.parent_dim_grp_display_code'||
    '     and dg.dimension_id = :b_dimension_id'||
    '     and b.'||p_member_col||' = FEM_DIMENSION_UTIL_PKG.Generate_Member_ID(ht.parent_cal_period_end_date,ht.parent_cal_period_number,:b_calendar_id,dg.dimension_group_id)'||
    -- Bug 5083961 -- UNABLE TO CREATE HIERARCHIES WITH DISABLED MEMBERS
    -- '     and b.enabled_flag = ''Y'''||
    '     and b.personal_flag = ''N'''||
    '   )'||
    '   or'||
    '   not exists ('||
    '     select 1'||
    '     from fem_dimension_grps_b dg'||
    '     ,'||p_member_b_table||' b'||
    '     where dg.dimension_group_display_code = ht.child_dim_grp_display_code'||
    '     and dg.dimension_id = :b_dimension_id'||
    '     and b.'||p_member_col||' = FEM_DIMENSION_UTIL_PKG.Generate_Member_ID(ht.child_cal_period_end_date,ht.child_cal_period_number,:b_calendar_id,dg.dimension_group_id)'||
    -- Bug 5083961 -- UNABLE TO CREATE HIERARCHIES WITH DISABLED MEMBERS
    --'     and b.enabled_flag = ''Y'''||
    '     and b.personal_flag = ''N'''||
    '   )'||
    ' )';

  else

    if (p_value_set_required_flag = 'Y') then

      x_bad_hier_members_stmt :=
      ' select ht.rowid'||
      ' ,''INVALID_MEMBER'''||
      ' from '||p_source_hier_table||' ht'||
      ' where ht.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and ht.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause||
      ' and ht.language = userenv(''LANG'')'||
      ' and ('||
      '   not exists ('||
      '     select 1'||
      '     from '||p_member_b_table||' b'||
      '     ,fem_value_sets_b vs'||
      '     where b.'||p_member_dc_col||' = ht.parent_display_code'||
      '     and b.value_set_id = vs.value_set_id'||
      -- Bug 5083961 -- UNABLE TO CREATE HIERARCHIES WITH DISABLED MEMBERS
      -- '     and b.enabled_flag = ''Y'''||
      '     and b.personal_flag = ''N'''||
      '     and vs.value_set_display_code = ht.parent_value_set_display_code'||
      '     and vs.dimension_id = :b_dimension_id'||
      '   )'||
      '   or'||
      '   not exists ('||
      '     select 1'||
      '     from '||p_member_b_table||' b'||
      '     ,fem_value_sets_b vs'||
      '     where b.'||p_member_dc_col||' = ht.child_display_code'||
      '     and b.value_set_id = vs.value_set_id'||
      -- Bug 5083961 -- UNABLE TO CREATE HIERARCHIES WITH DISABLED MEMBERS
      -- '     and b.enabled_flag = ''Y'''||
      '     and b.personal_flag = ''N'''||
      '     and vs.value_set_display_code = ht.child_value_set_display_code'||
      '     and vs.dimension_id = :b_dimension_id'||
      '   )'||
      ' )';

    else

      x_bad_hier_members_stmt :=
      ' select ht.rowid'||
      ' ,''INVALID_MEMBER'''||
      ' from '||p_source_hier_table||' ht'||
      ' where ht.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and ht.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause||
      ' and ht.language = userenv(''LANG'')'||
      ' and ('||
      '   not exists ('||
      '     select 1'||
      '     from '||p_member_b_table||' b'||
      '     where b.'||p_member_dc_col||' = ht.parent_display_code'||
      -- Bug 5083961 -- UNABLE TO CREATE HIERARCHIES WITH DISABLED MEMBERS
      -- '     and b.enabled_flag = ''Y'''||
      '     and b.personal_flag = ''N'''||
      '   )'||
      '   or'||
      '   not exists ('||
      '     select 1'||
      '     from '||p_member_b_table||' b'||
      '     where b.'||p_member_dc_col||' = ht.child_display_code'||
      -- Bug 5083961 -- UNABLE TO CREATE HIERARCHIES WITH DISABLED MEMBERS
      -- '     and b.enabled_flag = ''Y'''||
      '     and b.personal_flag = ''N'''||
      '   )'||
      ' )';

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_members_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_dups_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,x_bad_hier_dups_stmt          out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_dups_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and ht.status = ''LOAD''';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_bad_hier_dups_stmt :=
    ' select null'||
    ' ,null'||
    ' ,ht.child_dim_grp_display_code'||
    ' ,ht.child_cal_period_end_date'||
    ' ,ht.child_cal_period_number'||
    ' ,''CHILD_WITH_MULTIPLE_PARENTS'''||
    ' from '||p_source_hier_table||' ht'||
    ' where ht.hierarchy_object_name = :b_hierarchy_object_name'||
    ' and ht.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
    ' and ht.calendar_display_code = :b_calendar_display_code'||
      l_status_clause||
    ' and ht.language = userenv(''LANG'')'||
    ' and not ('||
    '   ht.parent_dim_grp_display_code = ht.child_dim_grp_display_code'||
    '   and ht.parent_cal_period_end_date = ht.child_cal_period_end_date'||
    '   and ht.parent_cal_period_number = ht.child_cal_period_number'||
    ' )'||
    ' group by ht.child_dim_grp_display_code'||
    ' ,ht.child_cal_period_end_date'||
    ' ,ht.child_cal_period_number'||
    ' having count(ht.parent_cal_period_number) > 1';

  else

    if (p_value_set_required_flag = 'Y') then

      x_bad_hier_dups_stmt :=
      ' select ht.child_display_code'||
      ' ,ht.child_value_set_display_code'||
      ' ,null'||
      ' ,null'||
      ' ,null'||
      ' ,''CHILD_WITH_MULTIPLE_PARENTS'''||
      ' from '||p_source_hier_table||' ht'||
      ' where ht.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and ht.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause||
      ' and ht.language = userenv(''LANG'')'||
      ' and not ('||
      '   ht.parent_display_code = ht.child_display_code'||
      '   and ht.parent_value_set_display_code = ht.child_value_set_display_code'||
      ' )'||
      ' group by ht.child_display_code'||
      ' ,ht.child_value_set_display_code'||
      ' having count(ht.parent_display_code) > 1';

    else

      x_bad_hier_dups_stmt :=
      ' select ht.child_display_code'||
      ' ,null'||
      ' ,null'||
      ' ,null'||
      ' ,null'||
      ' ,''CHILD_WITH_MULTIPLE_PARENTS'''||
      ' from '||p_source_hier_table||' ht'||
      ' where ht.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and ht.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause||
      ' and ht.language = userenv(''LANG'')'||
      ' and ht.parent_display_code <> ht.child_display_code'||
      ' group by ht.child_display_code'||
      ' having count(ht.parent_display_code) > 1';

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_dups_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_rec_leafs_stmt (
  p_dimension_varchar_label    in varchar2
  ,p_target_hierval_table      in varchar2
  ,p_member_attr_table         in varchar2
  ,p_member_col                in varchar2
  ,x_bad_hier_rec_leafs_stmt   out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_rec_leafs_stmt';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_bad_hier_rec_leafs_stmt :=
    ' select leaf.row_id'||
    ' ,''INVALID_RECONCILIATION_LEAF'''||
    ' from ('||
    '   select root.source_hier_t_rowid as row_id'||
    '   ,root.child_id'||
    '   from '||p_target_hierval_table||' root'||
    '   where root.request_id = :b_request_id'||
    '   and root.child_depth_num <> 1'||
    '   and not exists ('||
    '     select 1'||
    '     from '||p_target_hierval_table||' parent'||
    '     where parent.request_id = root.request_id'||
    '     and parent.parent_id = root.child_id'||
    '   )'||
    ' ) leaf'||
    ' where not exists ('||
    '   select 1'||
    '   from '||p_member_attr_table||' attv'||
    '   where attv.'||p_member_col||' = leaf.child_id'||
    '   and attv.dim_attribute_varchar_member = ''Y'''||
    '   and attv.attribute_id = :b_attribute_id'||
    '   and attv.version_id = :b_attr_version_id'||
    ' )';

  else

    x_bad_hier_rec_leafs_stmt :=
    ' select leaf.row_id'||
    ' ,''INVALID_RECONCILIATION_LEAF'''||
    ' from ('||
    '   select root.source_hier_t_rowid as row_id'||
    '   ,root.child_id'||
    '   ,root.child_value_set_id'||
    '   from '||p_target_hierval_table||' root'||
    '   where root.request_id = :b_request_id'||
    '   and root.child_depth_num <> 1'||
    '   and not exists ('||
    '     select 1'||
    '     from '||p_target_hierval_table||' parent'||
    '     where parent.request_id = root.request_id'||
    '     and parent.parent_id = root.child_id'||
    '     and parent.parent_value_set_id = root.child_value_set_id'||
    '   )'||
    ' ) leaf'||
    ' where not exists ('||
    '   select 1'||
    '   from '||p_member_attr_table||' attv'||
    '   where attv.value_set_id = leaf.child_value_set_id'||
    '   and attv.'||p_member_col||' = leaf.child_id'||
    '   and attv.dim_attribute_varchar_member = ''Y'''||
    '   and attv.attribute_id = :b_attribute_id'||
    '   and attv.version_id = :b_attr_version_id'||
    ' )';

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_rec_leafs_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_rec_nodes_stmt (
  p_dimension_varchar_label    in varchar2
  ,p_target_hierval_table      in varchar2
  ,p_member_attr_table         in varchar2
  ,p_member_col                in varchar2
  ,x_bad_hier_rec_nodes_stmt   out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_rec_nodes_stmt';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_bad_hier_rec_nodes_stmt :=
    ' select node.row_id'||
    ' ,''INVALID_RECONCILIATION_NODE'''||
    ' from ('||
    '   select min(parent.source_hier_t_rowid) as row_id'||
    '   ,parent.parent_id'||
    '   from '||p_target_hierval_table||' parent'||
    '   where parent.request_id = :b_request_id'||
    '   and parent.child_depth_num <> 1'||
    '   group by parent.parent_id'||
    ' ) node'||
    ' where not exists ('||
    '   select 1'||
    '   from '||p_member_attr_table||' attv'||
    '   where attv.'||p_member_col||' = node.parent_id'||
    '   and attv.dim_attribute_varchar_member = ''N'''||
    '   and attv.attribute_id = :b_attribute_id'||
    '   and attv.version_id = :b_attr_version_id'||
    ' )';

  else

    x_bad_hier_rec_nodes_stmt :=
    ' select node.row_id'||
    ' ,''INVALID_RECONCILIATION_NODE'''||
    ' from ('||
    '   select min(parent.source_hier_t_rowid) as row_id'||
    '   ,parent.parent_id'||
    '   ,parent.parent_value_set_id'||
    '   from '||p_target_hierval_table||' parent'||
    '   where parent.request_id = :b_request_id'||
    '   and parent.child_depth_num <> 1'||
    '   group by parent.parent_id'||
    '   ,parent.parent_value_set_id'||
    ' ) node'||
    ' where not exists ('||
    '   select 1'||
    '   from '||p_member_attr_table||' attv'||
    '   where attv.value_set_id = node.parent_value_set_id'||
    '   and attv.'||p_member_col||' = node.parent_id'||
    '   and attv.dim_attribute_varchar_member = ''N'''||
    '   and attv.attribute_id = :b_attribute_id'||
    '   and attv.version_id = :b_attr_version_id'||
    ' )';

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_rec_nodes_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_roots_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,p_member_b_table              in varchar2
  ,p_member_col                  in varchar2
  ,p_member_dc_col               in varchar2
  ,x_bad_hier_roots_stmt         out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_roots_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and root.status = ''LOAD''';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_bad_hier_roots_stmt :=
    ' select root.rowid'||
    ' ,''INVALID_ROOT_NODE'''||
    ' from '||p_source_hier_table||' root'||
    ' ,'||p_member_b_table||' b'||
    ' ,fem_dimension_grps_b dg'||
    ' where root.child_dim_grp_display_code = root.parent_dim_grp_display_code'||
    ' and root.child_cal_period_end_date = root.parent_cal_period_end_date'||
    ' and root.child_cal_period_number = root.parent_cal_period_number'||
    ' and root.hierarchy_object_name = :b_hierarchy_object_name'||
    ' and root.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
    ' and root.calendar_display_code = :b_calendar_display_code'||
      l_status_clause||
    ' and root.language = userenv(''LANG'')'||
    ' and dg.dimension_group_display_code = root.parent_dim_grp_display_code'||
    ' and dg.dimension_id = :b_dimension_id'||
    ' and b.'||p_member_col||' = FEM_DIMENSION_UTIL_PKG.Generate_Member_ID(root.parent_cal_period_end_date,root.parent_cal_period_number,:b_calendar_id,dg.dimension_group_id)'||
    ' and exists ('||
    '   select 1'||
    '   from '||p_source_hier_table||' child'||
    '   where child.child_dim_grp_display_code = root.parent_dim_grp_display_code'||
    '   and child.child_cal_period_end_date = root.parent_cal_period_end_date'||
    '   and child.child_cal_period_number = root.parent_cal_period_number'||
    '   and child.hierarchy_object_name = root.hierarchy_object_name'||
    '   and child.hierarchy_obj_def_display_name = root.hierarchy_obj_def_display_name'||
    '   and child.calendar_display_code = root.calendar_display_code'||
    '   and child.status = root.status'||
    '   and child.language = root.language'||
    '   and not ('||
    '     child.parent_dim_grp_display_code = child.child_dim_grp_display_code'||
    '     and child.parent_cal_period_end_date = child.child_cal_period_end_date'||
    '     and child.parent_cal_period_number = child.child_cal_period_number'||
    '   )'||
    ' )';

  else

    if (p_value_set_required_flag = 'Y') then

      x_bad_hier_roots_stmt :=
      ' select root.rowid'||
      ' ,''INVALID_ROOT_NODE'''||
      ' from '||p_source_hier_table||' root'||
      ' ,'||p_member_b_table||' b'||
      ' ,fem_value_sets_b vs'||
      ' where root.child_display_code = root.parent_display_code'||
      ' and root.child_value_set_display_code = root.parent_value_set_display_code'||
      ' and root.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and root.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause||
      ' and root.language = userenv(''LANG'')'||
      ' and vs.value_set_display_code = root.parent_value_set_display_code'||
      ' and vs.dimension_id = :b_dimension_id'||
      ' and b.value_set_id = vs.value_set_id'||
      ' and b.'||p_member_dc_col||' = root.parent_display_code'||
      ' and exists ('||
      '   select 1'||
      '   from '||p_source_hier_table||' child'||
      '   where child.child_display_code = root.parent_display_code'||
      '   and child.child_value_set_display_code = root.parent_value_set_display_code'||
      '   and child.hierarchy_object_name = root.hierarchy_object_name'||
      '   and child.hierarchy_obj_def_display_name = root.hierarchy_obj_def_display_name'||
      '   and child.status = root.status'||
      '   and child.language = root.language'||
      '   and not ('||
      '     child.parent_display_code = child.child_display_code'||
      '     and child.parent_value_set_display_code = child.child_value_set_display_code'||
      '   )'||
      ' )';

    else

      x_bad_hier_roots_stmt :=
      ' select root.rowid'||
      ' ,''INVALID_ROOT_NODE'''||
      ' from '||p_source_hier_table||' root'||
      ' ,'||p_member_b_table||' b'||
      ' where root.child_display_code = root.parent_display_code'||
      ' and root.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and root.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause||
      ' and root.language = userenv(''LANG'')'||
      ' and b.'||p_member_dc_col||' = root.parent_display_code'||
      ' and exists ('||
      '   select 1'||
      '   from '||p_source_hier_table||' child'||
      '   where child.child_display_code = root.parent_display_code'||
      '   and child.hierarchy_object_name = root.hierarchy_object_name'||
      '   and child.hierarchy_obj_def_display_name = root.hierarchy_obj_def_display_name'||
      '   and child.status = root.status'||
      '   and child.language = root.language'||
      '   and child.parent_display_code <> child.child_display_code'||
      ' )';

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_roots_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_dim_groups_t_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_target_hierval_table        in varchar2
  ,x_bad_hier_dim_groups_t_stmt  out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_dim_groups_t_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and hdgt.status = ''LOAD''';
  end if;

  x_bad_hier_dim_groups_t_stmt :=
  ' select hv.source_hier_t_rowid'||
  ' ,''GROUP_SEQ_RULE_VIOLATED'''||
  ' from '||p_target_hierval_table||' hv'||
  ' where hv.request_id = :b_request_id'||
  ' and not exists ('||
  '   select 1'||
  '   from fem_hier_dim_grps_t hdgt'||
  '   ,fem_dimension_grps_b dg'||
  '   where hdgt.hierarchy_object_name = :b_hierarchy_object_name'||
      l_status_clause||
  '   and hdgt.language = userenv(''LANG'')'||
  '   and dg.dimension_group_display_code = hdgt.dimension_group_display_code'||
  '   and dg.dimension_id = :b_dimension_id'||
  '   and dg.dimension_group_id = hv.child_dimension_grp_id'||
  ' )';

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_dim_groups_t_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_dim_groups_stmt (
  p_dimension_varchar_label    in varchar2
  ,p_target_hierval_table      in varchar2
  ,x_bad_hier_dim_groups_stmt  out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_dim_groups_stmt';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  x_bad_hier_dim_groups_stmt :=
  ' select hv.source_hier_t_rowid'||
  ' ,''GROUP_SEQ_RULE_VIOLATED'''||
  ' from '||p_target_hierval_table||' hv'||
  ' where hv.request_id = :b_request_id'||
  ' and not exists ('||
  '   select 1'||
  '   from fem_hier_dimension_grps hdg'||
  '   where hdg.hierarchy_obj_id = :b_hierarchy_object_id'||
  '   and hdg.dimension_group_id = hv.child_dimension_grp_id'||
  ' )';

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_dim_groups_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_dim_grp_skp_stmt (
  p_dimension_varchar_label    in varchar2
  ,p_target_hierval_table      in varchar2
  ,x_bad_hier_dim_grp_skp_stmt  out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_dim_grp_skp_stmt';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_bad_hier_dim_grp_skp_stmt :=
    ' select hv.source_hier_t_rowid'||
    ' ,''GROUP_SEQ_RULE_VIOLATED'''||
    ' from '||p_target_hierval_table||' hv'||
    ' ,fem_dimension_grps_b dgp'||
    ' ,fem_dimension_grps_b dgc'||
    ' where hv.request_id = :b_request_id'||
    ' and not ('||
    '   hv.parent_id = hv.child_id'||
    ' )'||
    ' and dgp.dimension_group_id = hv.parent_dimension_grp_id'||
    ' and dgc.dimension_group_id = hv.child_dimension_grp_id'||
    ' and dgp.dimension_group_seq >= dgc.dimension_group_seq';

  else

    x_bad_hier_dim_grp_skp_stmt :=
    ' select hv.source_hier_t_rowid'||
    ' ,''GROUP_SEQ_RULE_VIOLATED'''||
    ' from '||p_target_hierval_table||' hv'||
    ' ,fem_dimension_grps_b dgp'||
    ' ,fem_dimension_grps_b dgc'||
    ' where hv.request_id = :b_request_id'||
    ' and not ('||
    '   hv.parent_id = hv.child_id'||
    '   and hv.parent_value_set_id = hv.child_value_set_id'||
    ' )'||
    ' and dgp.dimension_group_id = hv.parent_dimension_grp_id'||
    ' and dgc.dimension_group_id = hv.child_dimension_grp_id'||
    ' and dgp.dimension_group_seq >= dgc.dimension_group_seq';

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_dim_grp_skp_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_bad_hier_dim_grp_reg_stmt (
  p_dimension_varchar_label    in varchar2
  ,p_target_hierval_table      in varchar2
  ,x_bad_hier_dim_grp_reg_stmt  out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_bad_hier_dim_grp_reg_stmt';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  x_bad_hier_dim_grp_reg_stmt :=
  ' select source_hier_t_rowid'||
  ' ,''GROUP_SEQ_RULE_VIOLATED'''||
  ' from '||p_target_hierval_table||
  ' where request_id = :b_request_id'||
  ' and child_depth_num = :b_depth_num'||
  ' and child_dimension_grp_id <> :b_dimension_group_id';

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_bad_hier_dim_grp_reg_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_root_node_count_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_source_hier_table           in varchar2
  ,x_root_node_count_stmt        out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_root_node_count_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and root.status = ''LOAD''';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_root_node_count_stmt :=
    ' select count(*)'||
    ' from '||p_source_hier_table||' root'||
    ' where root.child_dim_grp_display_code = root.parent_dim_grp_display_code'||
    ' and root.child_cal_period_end_date = root.parent_cal_period_end_date'||
    ' and root.child_cal_period_number = root.parent_cal_period_number'||
    ' and root.hierarchy_object_name = :b_hierarchy_object_name'||
    ' and root.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
    ' and root.calendar_display_code = :b_calendar_display_code'||
      l_status_clause||
    ' and root.language = userenv(''LANG'')';

  else

    if (p_value_set_required_flag = 'Y') then

      x_root_node_count_stmt :=
      ' select count(*)'||
      ' from '||p_source_hier_table||' root'||
      ' where root.child_display_code = root.parent_display_code'||
      ' and root.child_value_set_display_code = root.parent_value_set_display_code'||
      ' and root.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and root.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause||
      ' and root.language = userenv(''LANG'')';

    else

      x_root_node_count_stmt :=
      ' select count(*)'||
      ' from '||p_source_hier_table||' root'||
      ' where root.child_display_code = root.parent_display_code'||
      ' and root.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and root.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause||
      ' and root.language = userenv(''LANG'')';

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_root_node_count_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_get_value_sets_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,x_get_value_sets_stmt         out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_get_value_sets_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and hvst.status = ''LOAD''';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_get_value_sets_stmt := '';

  else

    if (p_value_set_required_flag = 'Y') then

      x_get_value_sets_stmt :=
      ' select vs.value_set_id'||
      ' from fem_hier_value_sets_t hvst'||
      ' ,fem_value_sets_b vs'||
      ' where hvst.hierarchy_object_name = :b_hierarchy_object_name'||
        l_status_clause||
      ' and hvst.language = userenv(''LANG'')'||
      ' and vs.value_set_display_code = hvst.value_set_display_code'||
      ' and vs.dimension_id = :b_dimension_id';

    else

      x_get_value_sets_stmt := '';

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_get_value_sets_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_get_dim_groups_t_stmt (
  p_dimension_varchar_label    in varchar2
  ,p_execution_mode            in varchar2
  ,x_get_dim_groups_t_stmt     out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_get_dim_groups_t_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and hdgt.status = ''LOAD''';
  end if;

  x_get_dim_groups_t_stmt :=
  ' select dimension_group_id'||
  ' ,rownum as depth_num'||
  ' from ('||
  '   select dg.dimension_group_id'||
  '   from fem_hier_dim_grps_t hdgt'||
  '   ,fem_dimension_grps_b dg'||
  '   where hdgt.hierarchy_object_name = :b_hierarchy_object_name'||
      l_status_clause||
  '   and hdgt.language = userenv(''LANG'')'||
  '   and dg.dimension_group_display_code = hdgt.dimension_group_display_code'||
  '   and dg.dimension_id = :b_dimension_id'||
  '   order by dg.dimension_group_seq'||
  ' )';

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_get_dim_groups_t_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_get_dim_groups_stmt (
  p_dimension_varchar_label    in varchar2
  ,p_execution_mode            in varchar2
  ,x_get_dim_groups_stmt       out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_get_dim_groups_stmt';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  x_get_dim_groups_stmt :=
  ' select dimension_group_id'||
  ' ,rownum as depth_num'||
  ' from ('||
  '   select hdg.dimension_group_id'||
  '   from fem_hier_dimension_grps hdg'||
  '   where hdg.hierarchy_obj_id = :b_hierarchy_object_id'||
  '   order by hdg.relative_dimension_group_seq'||
  ' )';

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_get_dim_groups_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_get_hier_defs_stmt (
  p_dimension_varchar_label    in varchar2
  ,p_execution_mode            in varchar2
  ,x_get_hier_defs_stmt        out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_get_hier_defs_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and ht.status = ''LOAD''';
  end if;

  x_get_hier_defs_stmt :=
  ' select ht.rowid'||
  ' ,ht.folder_name'||
  ' ,ht.hierarchy_object_name'||
  ' ,ht.hier_obj_def_display_name'||
  ' ,ht.effective_start_date'||
  ' ,ht.effective_end_date'||
  ' ,ht.calendar_display_code'||
  ' ,ht.language'||
  ' ,ht.dimension_varchar_label'||
  ' ,ht.hierarchy_type_code'||
  ' ,ht.group_sequence_enforced_code'||
  ' ,ht.multi_top_flag'||
  ' ,ht.multi_value_set_flag'||
  ' ,ht.hierarchy_usage_code'||
  ' ,ht.flattened_rows_flag'||
  ' ,ht.status'||
  ' from fem_hierarchies_t ht'||
  ' where ht.dimension_varchar_label = :b_dimension_varchar_label'||
  ' and ht.hierarchy_object_name = :b_hierarchy_object_name'||
  ' and ht.hier_obj_def_display_name = :b_hier_obj_def_display_name'||
    l_status_clause||
  ' and ht.language = userenv(''LANG'')';

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_get_hier_defs_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_get_hier_roots_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_group_use_code              in varchar2
  ,p_source_hier_table           in varchar2
  ,p_member_b_table              in varchar2
  ,p_member_col                  in varchar2
  ,p_member_dc_col               in varchar2
  ,x_get_hier_roots_stmt         out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_get_hier_roots_stmt';

  l_status_clause             varchar2(100) := '';
  l_dim_grp_clause            varchar2(100);

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and root.status = ''LOAD''';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_get_hier_roots_stmt :=
    ' select root.rowid'||
    ' ,b.'||p_member_col||
    ' ,null'||
    ' ,b.dimension_group_id'||
    ' ,root.display_order_num'||
    ' from '||p_source_hier_table||' root'||
    ' ,'||p_member_b_table||' b'||
    ' ,fem_dimension_grps_b dg'||
    ' where root.child_dim_grp_display_code = root.parent_dim_grp_display_code'||
    ' and root.child_cal_period_end_date = root.parent_cal_period_end_date'||
    ' and root.child_cal_period_number = root.parent_cal_period_number'||
    ' and root.hierarchy_object_name = :b_hierarchy_object_name'||
    ' and root.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
    ' and root.calendar_display_code = :b_calendar_display_code'||
      l_status_clause||
    ' and root.language = userenv(''LANG'')'||
    ' and dg.dimension_group_display_code = root.parent_dim_grp_display_code'||
    ' and dg.dimension_id = :b_dimension_id'||
    ' and b.'||p_member_col||' = FEM_DIMENSION_UTIL_PKG.Generate_Member_ID(root.parent_cal_period_end_date,root.parent_cal_period_number,:b_calendar_id,dg.dimension_group_id)';

  else

    if (p_group_use_code = 'NOT_SUPPORTED') then
      l_dim_grp_clause := ' ,null';
    else
      l_dim_grp_clause := ' ,b.dimension_group_id';
    end if;

    if (p_value_set_required_flag = 'Y') then

      x_get_hier_roots_stmt :=
      ' select root.rowid'||
      ' ,b.'||p_member_col||
      ' ,vs.value_set_id'||
        l_dim_grp_clause||
      ' ,root.display_order_num'||
      ' from '||p_source_hier_table||' root'||
      ' ,'||p_member_b_table||' b'||
      ' ,fem_value_sets_b vs'||
      ' where root.child_display_code = root.parent_display_code'||
      ' and root.child_value_set_display_code = root.parent_value_set_display_code'||
      ' and root.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and root.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause||
      ' and root.language = userenv(''LANG'')'||
      ' and vs.value_set_display_code = root.parent_value_set_display_code'||
      ' and vs.dimension_id = :b_dimension_id'||
      ' and b.value_set_id = vs.value_set_id'||
      ' and b.'||p_member_dc_col||' = root.parent_display_code';

    else

      -- FEM_HIERVAL_VSR_T_PK requires PARENT_VALUE_SET_ID and CHILD_VALUES_SET_ID
      x_get_hier_roots_stmt :=
      ' select root.rowid'||
      ' ,b.'||p_member_col||
      ' ,-1'||
        l_dim_grp_clause||
      ' ,root.display_order_num'||
      ' from '||p_source_hier_table||' root'||
      ' ,'||p_member_b_table||' b'||
      ' where root.child_display_code = root.parent_display_code'||
      ' and root.hierarchy_object_name = :b_hierarchy_object_name'||
      ' and root.hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
        l_status_clause||
      ' and root.language = userenv(''LANG'')'||
      ' and b.'||p_member_dc_col||' = root.parent_display_code';

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_get_hier_roots_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_get_hier_rels_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_group_use_code              in varchar2
  ,p_source_hier_table           in varchar2
  ,p_member_b_table              in varchar2
  ,p_member_col                  in varchar2
  ,p_member_dc_col               in varchar2
  ,x_get_hier_rels_stmt          out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_get_hier_rels_stmt';

  l_status_clause             varchar2(100) := '';
  l_parent_dim_grp_clause     varchar2(100);
  l_child_dim_grp_clause      varchar2(100);

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and status = ''LOAD''';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_get_hier_rels_stmt :=
    ' select rel.row_id'||
    ' ,rel.depth_num'||
    ' ,bp.'||p_member_col||
    ' ,null'||
    ' ,bp.dimension_group_id'||
    ' ,rel.depth_num+1'||
    ' ,bc.'||p_member_col||
    ' ,null'||
    ' ,bc.dimension_group_id'||
    ' ,rel.display_order_num'||
    ' ,rel.weighting_pct'||
    ' ,rel.status'||
    ' from ('||
    '   select row_id'||
    '   ,level as depth_num'||
    '   ,display_order_num'||
    '   ,weighting_pct'||
    '   ,status'||
    '   ,parent_dim_grp_display_code'||
    '   ,parent_cal_period_end_date'||
    '   ,parent_cal_period_number'||
    '   ,child_dim_grp_display_code'||
    '   ,child_cal_period_end_date'||
    '   ,child_cal_period_number'||
    '   from ('||
    '     select rowid as row_id'||
    '     ,display_order_num'||
    '     ,weighting_pct'||
    '     ,status'||
    '     ,parent_dim_grp_display_code'||
    '     ,parent_cal_period_end_date'||
    '     ,parent_cal_period_number'||
    '     ,child_dim_grp_display_code'||
    '     ,child_cal_period_end_date'||
    '     ,child_cal_period_number'||
    '     from '||p_source_hier_table||
    '     where hierarchy_object_name = :b_hierarchy_object_name'||
    '     and hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
    '     and calendar_display_code = :b_calendar_display_code'||
    '     and not ('||
    '       parent_dim_grp_display_code = child_dim_grp_display_code'||
    '       and parent_cal_period_end_date = child_cal_period_end_date'||
    '       and parent_cal_period_number = child_cal_period_number'||
    '     )'||
          l_status_clause||
    '     and language = userenv(''LANG'')'||
    '   )'||
    '   start with (parent_dim_grp_display_code,parent_cal_period_end_date,parent_cal_period_number) in ('||
    '     select parent_dim_grp_display_code'||
    '     ,parent_cal_period_end_date'||
    '     ,parent_cal_period_number'||
    '     from '||p_source_hier_table||
    '     where hierarchy_object_name = :b_hierarchy_object_name'||
    '     and hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
    '     and calendar_display_code = :b_calendar_display_code'||
    '     and child_dim_grp_display_code = parent_dim_grp_display_code'||
    '     and child_cal_period_end_date = parent_cal_period_end_date'||
    '     and child_cal_period_number = parent_cal_period_number'||
          l_status_clause||
    '     and language = userenv(''LANG'')'||
    '   )'||
    '   connect by prior child_dim_grp_display_code = parent_dim_grp_display_code'||
    '   and prior child_cal_period_end_date = parent_cal_period_end_date'||
    '   and prior child_cal_period_number = parent_cal_period_number'||
    ' ) rel'||
    ' ,'||p_member_b_table||' bp'||
    ' ,'||p_member_b_table||' bc'||
    ' ,fem_dimension_grps_b dgp'||
    ' ,fem_dimension_grps_b dgc'||
    ' where dgp.dimension_group_display_code = rel.parent_dim_grp_display_code'||
    ' and dgp.dimension_id = :b_dimension_id'||
    ' and dgc.dimension_group_display_code = rel.child_dim_grp_display_code'||
    ' and dgc.dimension_id = dgp.dimension_id'||
    ' and bp.'||p_member_col||' = FEM_DIMENSION_UTIL_PKG.Generate_Member_ID(rel.parent_cal_period_end_date,rel.parent_cal_period_number,:b_calendar_id,dgp.dimension_group_id)'||
    ' and bc.'||p_member_col||' = FEM_DIMENSION_UTIL_PKG.Generate_Member_ID(rel.child_cal_period_end_date,rel.child_cal_period_number,:b_calendar_id,dgc.dimension_group_id)';

  else

    if (p_group_use_code = 'NOT_SUPPORTED') then
      l_parent_dim_grp_clause := ' ,null';
      l_child_dim_grp_clause := ' ,null';
    else
      l_parent_dim_grp_clause := ' ,bp.dimension_group_id';
      l_child_dim_grp_clause := ' ,bc.dimension_group_id';
    end if;

    if (p_value_set_required_flag = 'Y') then

      x_get_hier_rels_stmt :=
      ' select rel.row_id'||
      ' ,rel.depth_num'||
      ' ,bp.'||p_member_col||
      ' ,vp.value_set_id'||
        l_parent_dim_grp_clause||
      ' ,rel.depth_num+1'||
      ' ,bc.'||p_member_col||
      ' ,vc.value_set_id'||
        l_child_dim_grp_clause||
      ' ,rel.display_order_num'||
      ' ,rel.weighting_pct'||
      ' ,rel.status'||
      ' from ('||
      '   select row_id'||
      '   ,level as depth_num'||
      '   ,display_order_num'||
      '   ,weighting_pct'||
      '   ,status'||
      '   ,parent_display_code'||
      '   ,parent_value_set_display_code'||
      '   ,child_display_code'||
      '   ,child_value_set_display_code'||
      '   from ('||
      '     select rowid as row_id'||
      '     ,display_order_num'||
      '     ,weighting_pct'||
      '     ,status'||
      '     ,parent_display_code'||
      '     ,parent_value_set_display_code'||
      '     ,child_display_code'||
      '     ,child_value_set_display_code'||
      '     from '||p_source_hier_table||
      '     where hierarchy_object_name = :b_hierarchy_object_name'||
      '     and hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
      '     and not ('||
      '       parent_display_code = child_display_code'||
      '       and parent_value_set_display_code = child_value_set_display_code'||
      '     )'||
            l_status_clause||
      '     and language = userenv(''LANG'')'||
      '   )'||
      '   start with (parent_display_code, parent_value_set_display_code) in ('||
      '     select parent_display_code'||
      '     ,parent_value_set_display_code'||
      '     from '||p_source_hier_table||
      '     where hierarchy_object_name = :b_hierarchy_object_name'||
      '     and hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
      '     and child_display_code = parent_display_code'||
      '     and child_value_set_display_code = parent_value_set_display_code'||
            l_status_clause||
      '     and language = userenv(''LANG'')'||
      '   )'||
      '   connect by prior child_display_code = parent_display_code'||
      '   and prior child_value_set_display_code = parent_value_set_display_code'||
      ' ) rel'||
      ' ,'||p_member_b_table||' bp'||
      ' ,fem_value_sets_b vp'||
      ' ,'||p_member_b_table||' bc'||
      ' ,fem_value_sets_b vc'||
      ' where bp.'||p_member_dc_col||' = rel.parent_display_code'||
      ' and bp.value_set_id = vp.value_set_id'||
      ' and vp.value_set_display_code = rel.parent_value_set_display_code'||
      ' and vp.dimension_id = :b_dimension_id'||
      ' and bc.'||p_member_dc_col||' = rel.child_display_code'||
      ' and bc.value_set_id = vc.value_set_id'||
      ' and vc.value_set_display_code = rel.child_value_set_display_code'||
      ' and vc.dimension_id = vp.dimension_id';

    else

      -- FEM_HIERVAL_VSR_T_PK requires PARENT_VALUE_SET_ID and CHILD_VALUES_SET_ID
      x_get_hier_rels_stmt :=
      ' select rel.row_id'||
      ' ,rel.depth_num'||
      ' ,bp.'||p_member_col||
      ' ,-1'||
        l_parent_dim_grp_clause||
      ' ,rel.depth_num+1'||
      ' ,bc.'||p_member_col||
      ' ,-1'||
        l_child_dim_grp_clause||
      ' ,rel.display_order_num'||
      ' ,rel.weighting_pct'||
      ' ,rel.status'||
      ' from ('||
      '   select row_id'||
      '   ,level as depth_num'||
      '   ,display_order_num'||
      '   ,weighting_pct'||
      '   ,status'||
      '   ,parent_display_code'||
      '   ,child_display_code'||
      '   from ('||
      '     select rowid as row_id'||
      '     ,display_order_num'||
      '     ,weighting_pct'||
      '     ,status'||
      '     ,parent_display_code'||
      '     ,child_display_code'||
      '     from '||p_source_hier_table||
      '     where hierarchy_object_name = :b_hierarchy_object_name'||
      '     and hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
      '     and parent_display_code <> child_display_code'||
            l_status_clause||
      '     and language = userenv(''LANG'')'||
      '   )'||
      '   start with parent_display_code in ('||
      '     select parent_display_code'||
      '     from '||p_source_hier_table||
      '     where hierarchy_object_name = :b_hierarchy_object_name'||
      '     and hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
      '     and child_display_code = parent_display_code'||
            l_status_clause||
      '     and language = userenv(''LANG'')'||
      '   )'||
      '   connect by prior child_display_code = parent_display_code'||
      ' ) rel'||
      ' ,'||p_member_b_table||' bp'||
      ' ,'||p_member_b_table||' bc'||
      ' where bp.'||p_member_dc_col||' = rel.parent_display_code'||
      ' and bc.'||p_member_dc_col||' = rel.child_display_code';

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_get_hier_rels_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_insert_hier_rels_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_value_set_required_flag     in varchar2
  ,p_target_hier_table           in varchar2
  ,p_target_hierval_table        in varchar2
  ,x_insert_hier_rels_stmt       out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_insert_hier_rels_stmt';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_insert_hier_rels_stmt :=
    ' insert into '||p_target_hier_table||' ('||
    '   hierarchy_obj_def_id'||
    '   ,parent_depth_num'||
    '   ,parent_id'||
    '   ,child_depth_num'||
    '   ,child_id'||
    '   ,single_depth_flag'||
    '   ,display_order_num'||
    '   ,weighting_pct'||
    '   ,read_only_flag'||
    '   ,creation_date'||
    '   ,created_by'||
    '   ,last_updated_by'||
    '   ,last_update_date'||
    '   ,last_update_login'||
    '   ,object_version_number'||
    ' )'||
    ' select :b_hier_obj_def_id'||
    ' ,parent_depth_num'||
    ' ,parent_id'||
    ' ,child_depth_num'||
    ' ,child_id'||
    ' ,''Y'''||
    ' ,display_order_num'||
    ' ,weighting_pct'||
    ' ,''N'''||
    ' ,sysdate'||
    ' ,:b_user_id'||
    ' ,:b_user_id'||
    ' ,sysdate'||
    ' ,:b_login_id'||
    ' ,:b_object_version_number'||
    ' from '||p_target_hierval_table||
    ' where request_id = :b_request_id';

  else

    if (p_value_set_required_flag = 'Y') then

      x_insert_hier_rels_stmt :=
      ' insert into '||p_target_hier_table||' ('||
      '   hierarchy_obj_def_id'||
      '   ,parent_depth_num'||
      '   ,parent_id'||
      '   ,parent_value_set_id'||
      '   ,child_depth_num'||
      '   ,child_id'||
      '   ,child_value_set_id'||
      '   ,single_depth_flag'||
      '   ,display_order_num'||
      '   ,weighting_pct'||
      '   ,read_only_flag'||
      '   ,creation_date'||
      '   ,created_by'||
      '   ,last_updated_by'||
      '   ,last_update_date'||
      '   ,last_update_login'||
      '   ,object_version_number'||
      ' )'||
      ' select :b_hier_obj_def_id'||
      ' ,parent_depth_num'||
      ' ,parent_id'||
      ' ,parent_value_set_id'||
      ' ,child_depth_num'||
      ' ,child_id'||
      ' ,child_value_set_id'||
      ' ,''Y'''||
      ' ,display_order_num'||
      ' ,weighting_pct'||
      ' ,''N'''||
      ' ,sysdate'||
      ' ,:b_user_id'||
      ' ,:b_user_id'||
      ' ,sysdate'||
      ' ,:b_login_id'||
      ' ,:b_object_version_number'||
      ' from '||p_target_hierval_table||
      ' where request_id = :b_request_id';

    else

      x_insert_hier_rels_stmt :=
      ' insert into '||p_target_hier_table||' ('||
      '   hierarchy_obj_def_id'||
      '   ,parent_depth_num'||
      '   ,parent_id'||
      '   ,child_depth_num'||
      '   ,child_id'||
      '   ,single_depth_flag'||
      '   ,display_order_num'||
      '   ,weighting_pct'||
      '   ,read_only_flag'||
      '   ,creation_date'||
      '   ,created_by'||
      '   ,last_updated_by'||
      '   ,last_update_date'||
      '   ,last_update_login'||
      '   ,object_version_number'||
      ' )'||
      ' select :b_hier_obj_def_id'||
      ' ,parent_depth_num'||
      ' ,parent_id'||
      ' ,child_depth_num'||
      ' ,child_id'||
      ' ,''Y'''||
      ' ,display_order_num'||
      ' ,weighting_pct'||
      ' ,''N'''||
      ' ,sysdate'||
      ' ,:b_user_id'||
      ' ,:b_user_id'||
      ' ,sysdate'||
      ' ,:b_login_id'||
      ' ,:b_object_version_number'||
      ' from '||p_target_hierval_table||
      ' where request_id = :b_request_id';

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_insert_hier_rels_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_delete_hier_rels_stmt (
  p_dimension_varchar_label    in varchar2
  ,p_execution_mode            in varchar2
  ,p_source_hier_table         in varchar2 := null
  ,p_target_hier_table         in varchar2 := null
  ,p_target_hierval_table      in varchar2 := null
  ,x_delete_hier_rels_stmt     out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_delete_hier_rels_stmt';
  l_status_clause    varchar2(100) := '';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  x_delete_hier_rels_stmt := null;

  if (p_source_hier_table is not null) then

    if (p_execution_mode = g_snapshot) then
      l_status_clause := ' and status = ''LOAD''';
    end if;

    x_delete_hier_rels_stmt :=
    ' delete from '||p_source_hier_table||
    ' where hierarchy_object_name = :b_hierarchy_object_name'||
    ' and hierarchy_obj_def_display_name = :b_hier_obj_def_display_name'||
      l_status_clause||
    ' and language = userenv(''LANG'')';

  elsif (p_target_hier_table is not null) then

    x_delete_hier_rels_stmt :=
    ' delete from '||p_target_hier_table||
    ' where hierarchy_obj_def_id = :b_hier_obj_def_id';

  elsif (p_target_hierval_table is not null) then

    x_delete_hier_rels_stmt :=
    ' delete from '||p_target_hierval_table||
    ' where request_id = :b_request_id';

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_delete_hier_rels_stmt;

--------------------------------------------------------------------------------

PROCEDURE bld_insert_hierval_rels_stmt (
  p_dimension_varchar_label    in varchar2
  ,p_target_hierval_table      in varchar2
  ,x_insert_hierval_rels_stmt  out nocopy varchar2
)
IS

  l_api_name         constant varchar2(30) := 'bld_insert_hierval_rels_stmt';

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    x_insert_hierval_rels_stmt :=
    ' insert into '||p_target_hierval_table||' ('||
    '   request_id'||
    '   ,source_hier_t_rowid'||
    '   ,parent_depth_num'||
    '   ,parent_id'||
    '   ,parent_dimension_grp_id'||
    '   ,child_depth_num'||
    '   ,child_id'||
    '   ,child_dimension_grp_id'||
    '   ,display_order_num'||
    '   ,weighting_pct'||
    ' ) values ('||
    '   :request_id'||
    '   ,:b_rowid'||
    '   ,:b_parent_depth_num'||
    '   ,:b_parent_id'||
    '   ,:b_parent_dimension_grp_id'||
    '   ,:b_child_depth_num'||
    '   ,:b_child_id'||
    '   ,:b_child_dimension_grp_id'||
    '   ,:b_display_order_num'||
    '   ,:b_wt_pct'||
    ' )';

  else

    x_insert_hierval_rels_stmt :=
    ' insert into '||p_target_hierval_table||' ('||
    '   request_id'||
    '   ,source_hier_t_rowid'||
    '   ,parent_depth_num'||
    '   ,parent_id'||
    '   ,parent_value_set_id'||
    '   ,parent_dimension_grp_id'||
    '   ,child_depth_num'||
    '   ,child_id'||
    '   ,child_value_set_id'||
    '   ,child_dimension_grp_id'||
    '   ,display_order_num'||
    '   ,weighting_pct'||
    ' ) values ('||
    '   :request_id'||
    '   ,:b_rowid'||
    '   ,:b_parent_depth_num'||
    '   ,:b_parent_id'||
    '   ,:b_parent_value_set_id'||
    '   ,:b_parent_dimension_grp_id'||
    '   ,:b_child_depth_num'||
    '   ,:b_child_id'||
    '   ,:b_child_value_set_id'||
    '   ,:b_child_dimension_grp_id'||
    '   ,:b_display_order_num'||
    '   ,:b_wt_pct'||
    ' )';

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

END bld_insert_hierval_rels_stmt;

--------------------------------------------------------------------------------

FUNCTION bld_update_status_stmt (
  p_dimension_varchar_label      in varchar2
  ,p_execution_mode              in varchar2
  ,p_value_set_required_flag     in varchar2 := null
  ,p_source_hier_table           in varchar2
  ,p_rowid_flag                  in varchar2 := null
  ,p_hier_object_name_flag       in varchar2 := null
  ,p_hier_obj_def_name_flag      in varchar2 := null
  ,p_parent_flag                 in varchar2 := null
  ,p_child_flag                  in varchar2 := null
)
RETURN varchar2
IS

  l_api_name         constant varchar2(30) := 'bld_update_status_stmt';
  l_status_clause    varchar2(100) := '';
  l_update_status_stmt    varchar2(4000);

BEGIN

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_execution_mode = g_snapshot) then
    l_status_clause := ' and status = ''LOAD''';
  end if;

  l_update_status_stmt :=
  ' update '||p_source_hier_table||
  ' set status = :b_status'||
  ' where language = userenv(''LANG'')'||
    l_status_clause;

  if (p_rowid_flag is not null) then
    l_update_status_stmt := l_update_status_stmt ||
    ' and rowid = :b_rowid';
  end if;

  if (p_hier_object_name_flag is not null) then
    l_update_status_stmt := l_update_status_stmt ||
    ' and hierarchy_object_name = :b_hierarchy_object_name';
  end if;

  if (p_hier_obj_def_name_flag is not null) then
    l_update_status_stmt := l_update_status_stmt ||
    ' and hierarchy_obj_def_display_name = :b_hier_obj_def_display_name';
  end if;

  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    if (p_parent_flag is not null) then
      l_update_status_stmt := l_update_status_stmt ||
      ' and calendar_display_code = :b_calendar_display_code'||
      ' and parent_dim_grp_display_code = :b_parent_dim_grp_dc'||
      ' and parent_cal_period_end_date = :b_parent_cal_period_end_date'||
      ' and parent_cal_period_number = :b_parent_cal_period_number'||
      ' and not ('||
      '   parent_dim_grp_display_code = child_dim_grp_display_code'||
      '   and parent_cal_period_end_date = child_cal_period_end_date'||
      '   and parent_cal_period_number = child_cal_period_number'||
      ' )';
    elsif (p_child_flag is not null) then
      l_update_status_stmt := l_update_status_stmt ||
      ' and calendar_display_code = :b_calendar_display_code'||
      ' and child_dim_grp_display_code = :b_child_dim_grp_dc'||
      ' and child_cal_period_end_date = :b_child_cal_period_end_date'||
      ' and child_cal_period_number = :b_child_cal_period_number'||
      ' and not ('||
      '   parent_dim_grp_display_code = child_dim_grp_display_code'||
      '   and parent_cal_period_end_date = child_cal_period_end_date'||
      '   and parent_cal_period_number = child_cal_period_number'||
      ' )';
    end if;

  else

    if (p_value_set_required_flag = 'Y') then

      if (p_parent_flag is not null) then
        l_update_status_stmt := l_update_status_stmt ||
        ' and parent_display_code = :b_parent_dc'||
        ' and parent_value_set_display_code = :b_parent_value_set_dc'||
        ' and not ('||
        '   parent_display_code = child_display_code'||
        '   and parent_value_set_display_code = child_value_set_display_code'||
        ' )';
      elsif (p_child_flag is not null) then
        l_update_status_stmt := l_update_status_stmt ||
        ' and child_display_code = :b_child_dc'||
        ' and child_value_set_display_code = :b_child_value_set_dc'||
        ' and not ('||
        '   parent_display_code = child_display_code'||
        '   and parent_value_set_display_code = child_value_set_display_code'||
        ' )';
      end if;

    else

      if (p_parent_flag is not null) then
        l_update_status_stmt := l_update_status_stmt ||
        ' and parent_display_code = :b_parent_dc'||
        ' and parent_display_code <> child_display_code';
      elsif (p_child_flag is not null) then
        l_update_status_stmt := l_update_status_stmt ||
        ' and child_display_code = :b_child_dc'||
        ' and parent_display_code <> child_display_code';
      end if;

    end if;

  end if;

  FEM_ENGINES_PKG.tech_message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

  return l_update_status_stmt;

END bld_update_status_stmt;



END FEM_HIER_LOADER_PKG;

/
