--------------------------------------------------------
--  DDL for Package CZ_PB_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_PB_MGR" AUTHID CURRENT_USER AS
/*  $Header: czpbmgrs.pls 120.59.12010000.5 2010/04/21 19:45:45 smanna ship $  */
/*
   Introducing custom error message to handle remote exception
   from insert_jrad_doc.

   Copying this help message to describe the use of
   custom error message.

   'Package DBMS_STANDARD, which is supplied with Oracle,
   provides language facilities that help your application interact with Oracle.
   For example, the procedure raise_application_error lets you
   issue user-defined error messages from stored subprograms.
   That way, you can report errors to your application
   and avoid returning unhandled exceptions.
   To call raise_application_error, use the syntax
   raise_application_error(error_number, message[, {TRUE | FALSE}]);
   where error_number is a negative integer in the range -20000 .. -20999
   and message is a character string up to 2048 bytes long.
   If the optional third parameter is TRUE, the error is placed
   on the stack of previous errors. If the parameter is FALSE (the default),
   the error replaces all previous errors.
   Package DBMS_STANDARD is an extension of package STANDARD,
   so you need not qualify references to its contents.'

*/

   EXPLORETREE_ERROR EXCEPTION;
   PRAGMA EXCEPTION_INIT(EXPLORETREE_ERROR, -20001);
   v_server_id cz_model_publications.server_id%TYPE;
   v_ui_def_id cz_model_publications.ui_def_id%TYPE;
   v_export_id cz_pb_model_exports.export_id%TYPE;
   v_publication_id cz_model_publications.publication_id%TYPE;
   v_root_model_id cz_model_publications.model_id%TYPE;
   v_root_ui_def_id cz_model_publications.ui_def_id%TYPE;
   target_root_model_id cz_model_publications.model_id%TYPE;
   v_status_code cz_model_publications.export_status%TYPE;
   v_remote_comp_id cz_model_ref_expls.component_id%TYPE;
   v_child_expl_id cz_model_ref_expls.child_model_expl_id%TYPE;
   v_server_local_name cz_servers.local_name%TYPE;
   v_target_ui_def_id cz_ui_defs.ui_def_id%TYPE;
   v_ui_name cz_ui_defs.NAME%TYPE;
   v_pb_run_id cz_xfr_run_infos.run_id%TYPE;
   loguser cz_db_logs.loguser%TYPE;
   v_deep_project_name cz_devl_projects.NAME%TYPE;
   v_err_message cz_db_logs.MESSAGE%TYPE;
   v_rp_folder_id cz_rp_entries.enclosing_folder%TYPE;
   v_rp_name cz_rp_entries.NAME%TYPE;
   v_rp_desc cz_rp_entries.description%TYPE;
   v_sql_err_msg cz_db_logs.MESSAGE%TYPE;
   v_db_link cz_servers.fndnam_link_name%TYPE;
   v_prev_remote_publication_id cz_model_publications.publication_id%TYPE;
   v_new_devl_id cz_devl_projects.devl_project_id%TYPE;
   new_ui_def_id cz_ui_defs.ui_def_id%TYPE;
   sequence_no NUMBER := 0;
   v_oraclesequenceincr PLS_INTEGER := 0.0;
   msg_count PLS_INTEGER := 0.0;
   v_expr_count PLS_INTEGER := 0.0;
   v_pb_log_flag VARCHAR2(5);
   v_insert_string VARCHAR2(2000) := '';
   sequence_const NUMBER := 0.0;
   index_variable NUMBER := 0.0;
-----table_name variable used in insert_into_table procedure
   v_insert_table_name VARCHAR2(128);
   v_insert_error VARCHAR2(2000);
   remote_publication_id cz_model_publications.remote_publication_id%TYPE;
   v_ui_str VARCHAR2(6) := 'x';
------------parameters of delete publication
   d_pbid NUMBER;
   vPubSingleLang cz_db_settings.value%TYPE := NULL;

------------msg record
   TYPE t_messagerecord IS RECORD(
      msg_text cz_db_logs.MESSAGE%TYPE
     ,called_proc cz_db_logs.caller%TYPE
     ,sql_code cz_db_logs.statuscode%TYPE
   );

   TYPE t_columnrecord IS RECORD(
      col_name VARCHAR2(100)
     ,table_name VARCHAR2(100)
   );

   TYPE t_collisionrecord IS RECORD(
      old_value NUMBER
     ,new_value NUMBER
   );

   TYPE t_jradchunk IS RECORD(
      jrad_doc VARCHAR2(2000)
     ,seq_nbr NUMBER
     ,CHUNK VARCHAR2(32767)
   );

   TYPE jrad_chunks_tbl IS TABLE OF t_jradchunk
      INDEX BY BINARY_INTEGER;

   cz_jrad_tbl jrad_chunks_tbl;

   TYPE collision_tbl IS TABLE OF t_collisionrecord
      INDEX BY BINARY_INTEGER;

   TYPE col_plsql_table_list IS TABLE OF t_columnrecord
      INDEX BY BINARY_INTEGER;

   TYPE propertytype IS TABLE OF cz_item_property_values.property_value%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE exprstrtype IS TABLE OF cz_expressions.expr_str%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE exprflgtype IS TABLE OF cz_expressions.parsed_flag%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE rulesusagetype IS TABLE OF cz_rules.effective_usage_mask%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE rulesefftype IS TABLE OF cz_rules.effective_from%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE propdatatype IS TABLE OF cz_ps_prop_vals.data_value%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE lcetexttype IS TABLE OF cz_lce_texts.lce_text%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE orig_sys_ref_type IS TABLE OF VARCHAR2(255)
      INDEX BY BINARY_INTEGER;

   TYPE orig_sys_ref_type_vc2 IS TABLE OF VARCHAR2(255)
      INDEX BY VARCHAR2(255);

   TYPE t_lang_code IS TABLE OF fnd_languages.language_code%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE ref_cursor IS REF CURSOR;

   TYPE model_id_table IS TABLE OF cz_model_publications.model_id%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE t_ref IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE t_ref_idx_vc2 IS TABLE OF NUMBER
      INDEX BY VARCHAR2(15);

   TYPE usage_name_list IS TABLE OF cz_model_usages.NAME%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE msg_text_list IS TABLE OF t_messagerecord
      INDEX BY BINARY_INTEGER;

   TYPE t_alias_name IS TABLE OF VARCHAR2(255)
      INDEX BY BINARY_INTEGER;

   TYPE keystrtype IS TABLE OF cz_ui_node_props.key_str%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE number_type_tbl IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE varchar_type_tbl IS TABLE OF VARCHAR2(2000)
      INDEX BY BINARY_INTEGER;

   TYPE jraddoc_type_tbl IS TABLE OF cz_ui_pages.jrad_doc%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE objtype IS TABLE OF cz_rule_folders.object_type%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE varchar_type_1_tbl IS TABLE OF VARCHAR2(1)
      INDEX BY BINARY_INTEGER;

   TYPE varchar_type_8_tbl IS TABLE OF VARCHAR2(8)
      INDEX BY BINARY_INTEGER;

   TYPE varchar_type_1000_tbl IS TABLE OF VARCHAR2(1000)
      INDEX BY BINARY_INTEGER;

   TYPE varchar_type_4000_tbl IS TABLE OF VARCHAR2(4000)
      INDEX BY BINARY_INTEGER;

   TYPE t_propertyrecord IS RECORD(
      NAME cz_properties.NAME%TYPE
     ,data_type cz_properties.data_type%TYPE
     ,src_application_id cz_properties.src_application_id%TYPE
   );

   TYPE t_typerecord IS RECORD(
      NAME cz_item_types.NAME%TYPE
     ,src_application_id cz_item_types.src_application_id%TYPE
   );

   TYPE t_propertytable IS TABLE OF t_propertyrecord
      INDEX BY BINARY_INTEGER;

   TYPE t_typetable IS TABLE OF t_typerecord
      INDEX BY BINARY_INTEGER;

   TYPE table_of_propertytables IS TABLE OF t_propertytable
      INDEX BY BINARY_INTEGER;

   TYPE date_tbl_type IS TABLE OF DATE
      INDEX BY PLS_INTEGER;

   g_ps_uits_add_tbl date_tbl_type;         -- cz_ps_nodes.UI_TIMESTAMP_ADD
   v_specs_alias_name_ref t_alias_name;
---------------------------------------
   v_cz_ps_nodes_new_tbl t_ref;
   v_cz_ps_nodes_old_tbl t_ref;
   v_cz_ps_nodes_idx_tbl t_ref_idx_vc2;
   v_ps_parent_id_tbl t_ref;
   v_ps_refid_old_tbl t_ref;
   v_devl_project_tbl t_ref;
   v_ref_model_id_tbl t_ref;
   v_cz_ps_nodes_comp_tbl t_ref;
   v_ps_item_id_tbl t_ref;
   v_ps_item_id_ref t_ref;
   v_cz_ps_nodes_new_ref t_ref;
   v_cz_ps_nodes_old_ref t_ref;
   v_ps_parent_id_ref t_ref;
   v_ps_ref_id_ref t_ref;
   v_ref_model_id_ref t_ref;
   v_cz_ps_nodes_comp_ref t_ref;
   v_ps_eff_set_id_ref t_ref;
   v_ps_eff_set_id_tbl t_ref;
   v_ps_intl_old_tbl t_ref;
   v_ps_intl_old_ref t_ref;
   v_ps_viol_old_tbl t_ref;
   v_ps_viol_old_ref t_ref;
   v_ps_capt_rule_ref t_ref;
   v_ps_capt_rule_tbl t_ref;
   v_ps_type_old_tbl t_ref;
   v_ps_type_old_ref t_ref;
   v_ps_src_appl_id_old_tbl t_ref; -- Bug9619157 Two new arrays to resolve item for reference BOM Node.
   v_ps_src_appl_id_old_ref t_ref;
   v_cz_model_ref_expls_new_ref t_ref;
   v_cz_model_ref_expls_old_ref t_ref;
   v_component_id_old_ref t_ref;
   v_parent_expl_id_ref t_ref;
   v_child_expl_id_ref t_ref;
   v_referring_node_id_ref t_ref;
   v_component_id_old_tbl t_ref;
   v_parent_expl_id_tbl t_ref;
   v_child_expl_id_tbl t_ref;
   v_referring_node_id_tbl t_ref;
   v_cz_model_ref_expls_idx_ref t_ref_idx_vc2;
   v_cz_ui_defs_new_ref t_ref;
   v_cz_ui_defs_old_ref t_ref;
   v_cz_ui_defs_old_oa_ref t_ref;
   v_cz_ui_defs_old_tbl t_ref;
   v_ui_devl_id_ref t_ref;
   v_ui_comp_id_ref t_ref;
   v_ui_devl_id_tbl t_ref;
   v_ui_comp_id_tbl t_ref;
   v_ui_defs_mcpt_rule_ref t_ref;
   v_ui_defs_pcpt_rule_ref t_ref;
   v_cz_ui_nodes_new_ref t_ref;
   v_cz_ui_nodes_old_ref t_ref;
   v_cz_ui_nodes_ui_def_id_ref t_ref;
   v_cz_ui_nodes_parent_id_ref t_ref;
   v_cz_ui_nodes_ui_ref_id_ref t_ref;
   v_cz_ui_nodes_ps_node_id_ref t_ref;
   v_cz_ui_nodes_component_id_ref t_ref;
   v_cz_ui_nodes_ui_dref_id_ref t_ref;
   v_cz_ui_nodes_expl_id_ref t_ref;
   v_cz_ui_nodes_fcomp_id_ref t_ref;
   v_cz_ui_nodes_capt_id_ref t_ref;
   v_cz_ui_nodes_tool_id_ref t_ref;
   g_ui_node_prop_new_node_tbl t_ref;
   g_ui_node_prop_old_node_tbl t_ref;
   g_ui_node_prop_new_uidf_tbl t_ref;
   g_ui_node_prop_old_uidf_tbl t_ref;
   v_cz_intl_text_new_ref t_ref;
   v_cz_intl_text_old_ref t_ref;
   v_cz_folders_id_old_ref t_ref;
   v_cz_folders_id_idx_ref t_ref_idx_vc2;
   v_cz_folders_id_new_ref t_ref;
   v_cz_folders_pf_id_ref t_ref;
   v_cz_folders_pj_id_ref t_ref;
   v_cz_folders_id_old_tbl t_ref;
   v_cz_folders_id_new_tbl t_ref;
   v_cz_folders_eff_ref t_ref;
   v_cz_folders_orig_ref orig_sys_ref_type;
   v_cz_folders_obj_ref objtype;
   v_cz_rules_obj_ref objtype;
   v_cz_rules_ui_ref t_ref;
   v_cz_enodes_enode_id_idx_ref t_ref_idx_vc2;
   v_cz_enodes_enode_id_old_ref t_ref;
   v_cz_enodes_enode_id_new_ref t_ref;
   v_cz_enodes_expr_id_ref t_ref;
   v_cz_enodes_psnode_id_ref t_ref;
   v_cz_enodes_gcol_id_ref t_ref;
   v_cz_enodes_pexpr_id_ref t_ref;
   v_cz_enodes_mrefl_id_ref t_ref;
   v_cz_enodes_rule_id_tbl t_ref;
   v_cz_enodes_rule_id_ref t_ref;
   v_cz_enodes_arg_sig_id_tbl t_ref;
   v_cz_enodes_par_sig_id_tbl t_ref;
   v_cz_enodes_prop_id_tbl t_ref;
   v_cz_enodes_arg_sig_id_ref t_ref;
   v_cz_enodes_par_sig_id_ref t_ref;
   v_cz_enodes_prop_id_ref t_ref;
   v_cz_expr_sig_ref t_ref;
   v_cz_expr_sig_idx_ref t_ref_idx_vc2;
   v_cz_enodes_expr_id_tbl t_ref;
   v_cz_enodes_psnode_id_tbl t_ref;
   v_cz_enodes_gcol_id_tbl t_ref;
   v_cz_enodes_pexpr_id_tbl t_ref;
   v_cz_enodes_mrefl_id_tbl t_ref;
   v_cz_enodes_enode_id_new_tbl t_ref;
   v_cz_enodes_enode_id_old_tbl t_ref;
   v_cz_rules_persistent_id_ref t_ref;
   v_cz_rules_rule_id_old_ref t_ref;
   v_cz_rules_rule_id_new_ref t_ref;
   v_cz_rules_rule_id_idx_ref t_ref_idx_vc2;
   v_cz_rules_grid_id_ref t_ref;
   v_cz_rules_rf_id_ref t_ref;
   v_cz_rules_proj_id_ref t_ref;
   v_cz_rules_comp_id_ref t_ref;
   v_cz_rules_ant_id_ref t_ref;
   v_cz_rules_con_id_ref t_ref;
   v_cz_rules_rea_id_ref t_ref;
   v_cz_rules_unmsg_id_ref t_ref;
   v_cz_intl_unmsg_idx_ref t_ref;
   v_cz_rules_eff_id_ref t_ref;
   v_cz_rules_expl_ref t_ref;
   v_cz_rules_sig_ref t_ref;
   v_cz_rules_sig_idx_ref t_ref;
   v_sig_new_ref t_ref;
   v_sig_old_ref t_ref;
   v_sig_idx_ref t_ref_idx_vc2;
   v_arg_sig_tbl t_ref;
   v_data_sig_tbl t_ref;
   v_arg_sig_old_tbl t_ref;
   v_arg_ind_old_tbl t_ref;
   v_cz_des_feature_id_old_ref t_ref;
   v_cz_des_feature_id_new_ref t_ref;
   v_cz_des_feature_rid_new_ref t_ref;
   v_cz_des_feature_rule_id_ref t_ref;
   v_cz_des_feature_mrefl_id_ref t_ref;
   v_cz_des_feature_ft_typ_ref t_ref;
   v_cz_des_cells_rule_id_new_ref t_ref;
   v_cz_des_cells_rule_id_old_ref t_ref;
   v_cz_des_cells_sf_id_ref t_ref;
   v_cz_des_cells_sopt_id_ref t_ref;
   v_cz_des_cells_popt_id_ref t_ref;
   v_cz_des_cells_sexpl_id_ref t_ref;
   v_cz_des_cells_mark_char_ref exprflgtype;
   v_cz_eff_sets_old_tbl t_ref;
   v_cz_eff_sets_new_tbl t_ref;
   v_ref_child_remote_model t_ref;
   v_ref_child_remote_ref t_ref;
   v_remote_ref_expl_ref t_ref;
   v_ref_child_source_model t_ref;
   v_ref_child_source_ref t_ref;
   v_source_ref_expl_ref t_ref;
   v_prop_vals_node_tbl t_ref;
   v_prop_vals_prop_tbl t_ref;
   v_prop_vals_data_tbl propdatatype;
   v_prop_vals_num_tbl t_ref;
   v_prop_vals_origsys_tbl propdatatype;
   v_prop_vals_datanum_tbl t_ref;
   v_prop_vals_num_ref t_ref;
   v_prop_vals_origsys_ref propdatatype;
   v_prop_vals_datanum_ref t_ref;
   v_prop_vals_node_ref t_ref;
   v_prop_vals_prop_ref t_ref;
   v_prop_vals_data_ref propdatatype;
   v_prop_vals_data_typ_ref t_ref;
   v_prop_vals_data_num_ref t_ref;
   v_prop_vals_intl_text_ref t_ref;
   v_propval_node_id cz_ps_prop_vals.ps_node_id%TYPE;
   v_propval_prop_id cz_ps_prop_vals.property_id%TYPE;
   v_propval_data_value cz_ps_prop_vals.data_value%TYPE;
   v_propval_data_num_value cz_ps_prop_vals.data_num_value%TYPE;
   v_model_usages_tbl t_ref;
   v_cz_ui_nodes_idx_ref t_ref_idx_vc2;
   v_cz_ui_defs_idx_ref t_ref_idx_vc2;
   v_intl_text_model_tbl t_ref;
   v_intl_text_ui_tbl t_ref;
-------mls implementation
   v_src_lang_code_tbl propertytype;
   v_tgt_lang_code_tbl propertytype;
   v_pb_lang_ref propertytype;
   v_src_lang_ref propertytype;
   v_remote_prop_ref t_ref;
   v_property_record_ref t_propertytable;
   v_type_property_record_ref table_of_propertytables;
   v_type_record_ref t_typetable;
   v_cz_model_pub_new_id cz_model_publications.publication_id%TYPE;
   v_cz_model_pub_old_id cz_model_publications.publication_id%TYPE;
   v_models_to_be_exported t_ref;
   v_models_not_to_be_exported t_ref;
   v_models_to_be_exported_new t_ref;
   v_cz_express_expr_id_new_ref1 t_ref;
   array_uis t_ref;
   v_cz_func_comp_new_tbl t_ref;
   v_cz_func_comp_old_tbl t_ref;
   v_cz_func_devl_old_tbl t_ref;
   v_cz_func_rule_old_tbl t_ref;
   v_cz_func_expl_old_tbl t_ref;
   v_cz_func_comp_idx_ref t_ref_idx_vc2;
   v_cz_func_comp_new_ref t_ref;
   v_cz_func_comp_old_ref t_ref;
   v_cz_func_devl_old_ref t_ref;
   v_cz_func_cid_old_ref t_ref;
   v_cz_func_expl_old_ref t_ref;
   v_cz_func_fld_old_ref t_ref;
   v_cz_func_obj_ref objtype;
   v_cz_enodes_seq_nbr_ref t_ref;
   v_cz_enodes_item_type_id_ref t_ref;
   v_cz_enodes_item_id_ref t_ref;
   v_cz_enodes_filter_set_id_ref t_ref;
   v_cz_enodes_property_id_ref t_ref;
   v_cz_enodes_compile_advice_ref t_ref;
   v_cz_enodes_expr_type_ref t_ref;
   v_cz_enodes_expr_subtype_ref t_ref;
   v_cz_enodes_token_list_seq_ref t_ref;
   v_cz_enodes_col_ref t_ref;
   v_cz_enodes_seq_nbr_tbl t_ref;
   v_cz_enodes_item_type_id_tbl t_ref;
   v_cz_enodes_item_id_tbl t_ref;
   v_cz_enodes_filter_set_id_tbl t_ref;
   v_cz_enodes_property_id_tbl t_ref;
   v_cz_enodes_compile_advice_tbl t_ref;
   v_cz_enodes_col_tbl t_ref;
   v_cz_enodes_expr_type_tbl t_ref;
   v_cz_enodes_expr_subtype_tbl t_ref;
   v_cz_enodes_token_list_seq_tbl t_ref;
   v_item_masters_tbl t_ref;
   v_item_masters_ref t_ref;
   v_item_prop_data_typ_ref t_ref;
   v_item_types_tbl t_ref;
   v_item_types_new_ref t_ref;
   v_item_types_ref t_ref;
   v_item_prop_id_tbl t_ref;
   v_item_prop_type_tbl t_ref;
   v_item_prop_num_val_tbl t_ref;
   v_item_prop_id_ref t_ref;
   v_item_prop_type_ref t_ref;
   v_item_prop_num_val_ref t_ref;
   v_item_prop_data_typ_tbl t_ref;
   v_it_prop_vals_id_tbl t_ref;
   v_it_prop_vals_id_ref t_ref;
   v_it_prop_vals_item_tbl t_ref;
   v_it_prop_vals_item_ref t_ref;
   v_it_prop_value_tbl propertytype;
   v_it_prop_value_ref propertytype;
   v_item_types_orig_ref orig_sys_ref_type;
   v_items_orig_ref orig_sys_ref_type;
   v_enodes_values_tbl propertytype;
   v_enodes_values_ref propertytype;
   v_enodes_fldname_tbl propertytype;
   v_enodes_fldname_ref propertytype;
   v_cz_express_name_ref propertytype;
   v_cz_express_expr_str_ref exprstrtype;
   v_cz_express_desc_text_ref propertytype;
   v_cz_express_present_typ_ref t_ref;
   v_cz_express_parsed_flg_ref exprflgtype;
   v_cz_express_pers_id_ref t_ref;
   v_cz_lce_headers_old_tbl t_ref;
   v_cz_lce_headers_new_tbl t_ref;
   v_cz_lce_headers_new_ref t_ref;
   v_cz_lce_headers_old_ref t_ref;
   v_cz_lce_headers_idx_ref t_ref_idx_vc2;
   v_cz_lce_comp_id_ref t_ref;
   v_cz_lce_expl_id_ref t_ref;
   v_cz_lce_devl_id_ref t_ref;
   v_specs_attach_expl_id_ref t_ref;
   v_specs_lce_header_id_ref t_ref;
   v_specs_required_expl_id_ref t_ref;
   v_specs_attach_comp_id_ref t_ref;
   v_specs_model_id_ref t_ref;
   v_specs_net_type_ref t_ref;
   v_cz_eff_sets_idx_tbl t_ref_idx_vc2;
   v_cz_intl_text_idx_ref t_ref_idx_vc2;
   v_imported_ps_ref t_ref;
   v_imported_ps_node NUMBER := 0.0;
-----bomsynch
   v_cz_intl_orig_sys_ref orig_sys_ref_type;
   v_ps_orig_sys_ref orig_sys_ref_type;
   v_ps_comp_seq_path_ref orig_sys_ref_type;
   v_ps_comp_seq_id_ref t_ref;
   v_ps_orig_sys_tbl orig_sys_ref_type;
   v_ps_comp_seq_path_tbl orig_sys_ref_type;
   v_ps_comp_seq_id_tbl t_ref;
   bomsynch_flag VARCHAR2(1) := 'N';
   l_intl_text_id NUMBER := 0;
   l_bom_caption_rule NUMBER := 0;
   l_nonbom_capt_rule_id NUMBER := 0;
   l_devl_proj_inv_id NUMBER := 0;
   l_devl_proj_org_id NUMBER := 0;
   l_devl_proj_product_key cz_devl_projects.product_key%TYPE;
   l_bom_caption_text_id cz_devl_projects.bom_caption_text_id%TYPE;
   l_nonbom_caption_text_id cz_devl_projects.nonbom_caption_text_id%TYPE;
-----new tech stack arrays
   v_templates_tobe_exported t_ref;
   v_templates_not_exported t_ref;
   v_global_templs_ref t_ref;
   v_global_templs_exported t_ref;
   l_template_id_ref t_ref;
   l_ui_def_id_ref t_ref;
   l_element_type_ref t_ref;
   l_element_id_ref t_ref;
   l_pers_elem_ref t_ref;
   v_usages_lang_tbl t_lang_code;
--------------------commit size variables
   end_count NUMBER := 0;
   start_count NUMBER := 0;
   last_set BOOLEAN;
----------constants for sequences
   CZ_PS_NODES_SEQ CONSTANT PLS_INTEGER := 1;
   CZ_MODEL_REF_EXPLS_SEQ CONSTANT PLS_INTEGER := 2;
   CZ_FUNC_COMP_SPECS_SEQ CONSTANT PLS_INTEGER := 3;
   CZ_UI_DEFS_SEQ CONSTANT PLS_INTEGER := 4;
   CZ_UI_NODES_SEQ CONSTANT PLS_INTEGER := 5;
   CZ_INTL_TEXTS_SEQ CONSTANT PLS_INTEGER := 6;
   CZ_RULE_FOLDERS_SEQ CONSTANT PLS_INTEGER := 7;
   CZ_GRID_DEFS_SEQ CONSTANT PLS_INTEGER := 8;
   CZ_GRID_COLS_SEQ CONSTANT PLS_INTEGER := 9;
   CZ_EXPRESSIONS_SEQ CONSTANT PLS_INTEGER := 10;
   CZ_EXPRESSION_NODES_SEQ CONSTANT PLS_INTEGER := 11;
   CZ_RULES_SEQ CONSTANT PLS_INTEGER := 12;
   CZ_GRID_CELLS_SEQ CONSTANT PLS_INTEGER := 13;
   CZ_LCE_HEADERS_SEQ CONSTANT PLS_INTEGER := 14;
   CZ_MODEL_PUBLICATIONS_SEQ CONSTANT PLS_INTEGER := 15;
   CZ_EFFECTIVITY_SETS_SEQ CONSTANT PLS_INTEGER := 16;
   CZ_CONFIG_MESSAGES_SEQ CONSTANT PLS_INTEGER := 17;
   CZ_UI_TEMPLATES CONSTANT PLS_INTEGER := 18;
   CZ_SIGNATURES_SEQ CONSTANT PLS_INTEGER := 19;
   CZ_ARCHIVES_SEQ CONSTANT PLS_INTEGER := 20;
   CZ_FILTER_SETS_SEQ CONSTANT PLS_INTEGER := 21;
   CZ_POPULATORS_SEQ CONSTANT PLS_INTEGER := 22;
   CZ_UI_ACTIONS_SEQ CONSTANT PLS_INTEGER := 23;
   CZ_PROPERTIES_SEQ CONSTANT PLS_INTEGER := 24;
   CZ_ITEM_MASTERS_SEQ CONSTANT PLS_INTEGER := 25;
   CZ_ITEM_TYPES_SEQ CONSTANT PLS_INTEGER := 26;
   CZ_FCE_FILES_SEQ CONSTANT PLS_INTEGER := 27;

   v_msg_tbl msg_text_list;
----variables used for orig_sys_ref returned by bomsynch
   v_devl_orig_sys_ref cz_devl_projects.orig_sys_ref%TYPE;
   v_it_masters_sys_ref VARCHAR2(255);
   v_it_types_sys_ref VARCHAR2(255);
   v_bomsynch_product_key cz_model_publications.product_key%TYPE;
   v_bomsynch_org_id cz_model_publications.organization_id%TYPE;
   v_bomsynch_item_id cz_model_publications.top_item_id%TYPE;
---variables used by republish model
   v_orig_start_date DATE;
   v_orig_end_date DATE;
   v_repub_appl_from DATE;
   v_repub_appl_until DATE;
   v_republish_model NUMBER := -1;
   v_repub_remote_pb_id cz_model_publications.remote_publication_id%TYPE;
------------variables used in publication functions
   model_ref_expl_id_table t_ref;
   v_last_struct_update DATE;
----global declarations for item schema bug# 2463594
----avoid using literals
   g_item_type_id cz_item_types.item_type_id%TYPE;
   g_item_id cz_item_masters.item_id%TYPE;
-- Array define to hold sequence count for each sequencer
   v_sequence_count t_ref;
   v_next_sequence_gen t_ref;
------exceptions
   pb_upload_ps_schema EXCEPTION;
   pb_upload_ui_schema EXCEPTION;
   pb_upload_rule_schema EXCEPTION;
   pb_upload_item_schema EXCEPTION;
   no_load_specs_data EXCEPTION;
   insert_table_error EXCEPTION;
   run_id_error EXCEPTION;
   verify_model_error EXCEPTION;
   proc_export_error EXCEPTION;
   cz_pb_global_synch EXCEPTION;
------------------------------------
   PUBLICATION_ERROR CONSTANT VARCHAR2(3) := 'ERR';
   PUBLICATION_OK CONSTANT VARCHAR2(3) := 'OK';
   PUBLICATION_PROCESSING CONSTANT VARCHAR2(3) := 'PRC';
   PUBLICATION_PENDING CONSTANT VARCHAR2(3) := 'PEN';
   PUBLICATION_PEN_UPDATE CONSTANT VARCHAR2(3) := 'PUP';
   PUB_SOURCE_TARGET_FLAG CONSTANT VARCHAR2(1) := 'T';
   PS_NODE_REF_TYPE CONSTANT NUMBER := 263;
   SEQUENCE_INCR_STR CONSTANT VARCHAR2(20) := 'OracleSequenceIncr';
   record_commit_str CONSTANT VARCHAR2(20) := 'CommitSize';
   publication_log CONSTANT VARCHAR2(20) := 'PublicationLogging';
   pb_timing_log CONSTANT VARCHAR2(20) := 'PublicationTiming';
   rule_copy CONSTANT VARCHAR2(20) := 'PublishingCopyRules';
   empty_string CONSTANT VARCHAR2(5) := '  ';
   null_string CONSTANT VARCHAR2(4) := 'NULL';
   reasonid CONSTANT VARCHAR2(4) := '... ';
   unmsgid CONSTANT VARCHAR2(3) := 'GS ';
   pbnewline CONSTANT VARCHAR2(25) := fnd_global.NEWLINE;
   non_virtual_component CONSTANT NUMBER := 259;
   model_connector CONSTANT NUMBER := 264;
   record_not_deleted CONSTANT VARCHAR2(1) := '0';
   record_commit_size PLS_INTEGER := 500;
   global_export_retcode PLS_INTEGER := 0;
   global_process_retcode PLS_INTEGER := 0;
   publication_timing CONSTANT NUMBER := 0;
   v_new_object_id cz_rp_entries.object_id%TYPE;
   model_copy CONSTANT VARCHAR2(20) := 'DEEP_MODEL_COPY';
   pub_model CONSTANT VARCHAR2(20) := 'PUBLISHMODEL';
   cz_publish CONSTANT VARCHAR2(30) := 'PUBLISH_NEW_MODEL';
   cz_republish CONSTANT VARCHAR2(30) := 'REPUBLISH_EXISTING_MODEL';
   copy_rules VARCHAR2(3) := 'YES';
   copy_uis VARCHAR2(3) := 'YES';
   copy_root_only VARCHAR2(3) := 'YES';
   bom_synch_flag VARCHAR2(3) := 'NO';
   v_session_parameter VARCHAR2(20) := empty_string;
   new_copy_mode CONSTANT NUMBER := 0;
   rebublish_mode CONSTANT NUMBER := 1;
   repub_new_copy CONSTANT NUMBER := 2;
   no_mode CONSTANT NUMBER := -1;
   new_copy_str CONSTANT VARCHAR2(20) := 'new copy';
   repub_str CONSTANT VARCHAR2(20) := 'republish model';
   v_repub_parameter VARCHAR2(20) := empty_string;
   refresh_rules_count CONSTANT NUMBER := -666;
   v_refresh_rules VARCHAR2(3) := 'NO';
   g_log_timing NUMBER := 1;
   bom_item CONSTANT NUMBER := 0;
   nonbom_item CONSTANT NUMBER := 1;
   PUB_LANGUAGE CONSTANT VARCHAR2(50) := 'APPS_PREFER_LANG';
------->>>>>>rewrite variables
   template_publication CONSTANT VARCHAR2(3) := 'UIT';
   model_publication CONSTANT VARCHAR2(3) := 'PRJ';
   seed_data CONSTANT VARCHAR2(1) := '1';
   oa_ui_style CONSTANT VARCHAR2(3) := '7';
   locks_in_prod_mode CONSTANT VARCHAR2(200) := 'CZ_ALLOW_PUBLISH_TO_PRODUCTION_WHEN_LOCKED';
   locks_in_test_mode CONSTANT VARCHAR2(200) := 'CZ_ALLOW_PUBLISH_TO_TEST_WHEN_LOCKED';
-----priv constants
   publish_model_function CONSTANT VARCHAR2(100) := 'CZDEVPUBLISHFUNC';
   has_no_privilege CONSTANT VARCHAR2(1) := 'F';
   has_privilege CONSTANT VARCHAR2(1) := 'T';
   use_entity_access_control CONSTANT VARCHAR2(100) := 'CZ_USE_ENTITY_ACCESS_CONTROL';

   TYPE varchar_tbl_type IS TABLE OF VARCHAR2(255)
      INDEX BY BINARY_INTEGER;

   TYPE varchar_tbl_type_3 IS TABLE OF cz_rp_entries.object_type%TYPE
      INDEX BY BINARY_INTEGER;

   g_source_flag cz_model_publications.source_target_flag%TYPE;
   g_target_flag cz_model_publications.source_target_flag%TYPE;
   g_migration_group_id cz_model_publications.migration_group_id%TYPE;
   g_object_type cz_model_publications.object_type%TYPE;
   g_template_id cz.cz_ui_templates.template_id%TYPE;
   g_jrad_doc cz.cz_ui_templates.jrad_doc%TYPE;
   g_button_tmpl_id cz.cz_ui_templates.template_id%TYPE;
   g_main_msg_id cz.cz_ui_templates.main_message_id%TYPE;
   g_title_id cz.cz_ui_templates.title_id%TYPE;
   pbdebug NUMBER := 0;
   g_button_tbl t_ref;
   g_message_tbl t_ref;
   g_title_tbl t_ref;
   g_jrad_doc_tbl varchar_tbl_type;
   g_cz_ui_pages_ui_def_ref t_ref;
   g_pages_ui_def_old_ref t_ref;
   g_cz_ui_pages_jrad_doc_ref varchar_tbl_type;
   g_cz_ui_old_jrad_doc_ref varchar_tbl_type;
   g_cz_ui_pages_capt_id_ref t_ref;
   g_cz_ui_pages_stat_templ t_ref;
   g_cz_ui_pages_stat_ui t_ref;
   g_cz_uipg_tmplid_tbl t_ref;
   g_cz_uipg_tmplui_tbl t_ref;
   g_intl_text_id_ref t_ref;
   g_cz_ui_pages_ui_def_tbl t_ref;
   g_cz_ui_pages_jrad_doc_tbl varchar_tbl_type;
   g_cz_ui_pages_capt_id_tbl t_ref;
   g_cz_ui_pages_dis_cond_tbl t_ref;
   g_cz_ui_pages_enb_cond_tbl t_ref;
   g_cz_ui_pages_expl_tbl t_ref;
   g_page_sets_ui_old_ref t_ref;
   g_page_sets_ui_ref t_ref;
   g_page_sets_pg_tbl t_ref;
   g_page_sets_jrad_doc_ref varchar_type_tbl;
   g_page_sets_expl_tbl t_ref;
   g_page_refs_ui_def_old_ref t_ref;
   g_page_refs_ui_def_new_ref t_ref;
   g_page_refs_pg_set_ref t_ref;
   g_page_refs_pg_ref_ref t_ref;
   g_page_refs_tgt_expl_tbl t_ref;
   g_page_refs_cond_id_ref t_ref;
   g_page_refs_capt_id_ref t_ref;
   g_page_refs_tgt_ui_ref t_ref;
   g_page_refs_cpt_rule_tbl t_ref;
   g_ui_refs_old_ui_def_ref t_ref;
   g_ui_refs_new_ui_def_ref t_ref;
   g_ui_refs_ref_ui_def_ref t_ref;
   g_ui_refs_expl_id_ref t_ref;
   g_ui_refs_ref_ui_def_old_ref t_ref;
   g_ui_refs_expl_id_old_ref t_ref;
   g_ui_ps_maps_old_ui_def_ref t_ref;
   g_ui_ps_maps_new_ui_def_ref t_ref;
   g_ui_ps_maps_ctrl_tmp_ref t_ref;
   g_ui_ps_maps_elem_sig_tbl t_ref;
   g_ui_ps_maps_tgt_pg_ui_def_tbl t_ref;
   g_ui_ps_maps_page_id_tbl t_ref;
   g_ui_ps_maps_expl_id_tbl t_ref;
   g_ui_ps_maps_templ_ui_tbl t_ref;
   g_ui_ps_maps_element_tbl varchar_type_tbl;

   -- g_ui_templates_jrad_new_ref/g_ui_templates_jrad_old_ref: not published before, or exported
   --      before but changed since, used for isnertion or updates, and for replace_enxtends
   -- g_tmpl_jrad_old_tbl/g_tmpl_jrad_new_tbl, exported and no change since, used in replace_extends
   g_tmpl_jrad_old_tbl varchar_type_tbl;
   g_tmpl_jrad_new_tbl varchar_type_tbl;
   g_ui_templates_old_temp_id_ref t_ref;
   g_ui_templates_new_temp_id_ref t_ref;
   g_ui_templates_idx_temp_ref t_ref_idx_vc2;
   g_ui_templates_ui_def_old_ref t_ref;
   mm_ui_tmpls_ui_def_old_ref t_ref;
   g_ui_templates_ui_def_new_ref t_ref;
   g_template_id_ref t_ref;
   g_ref_template_id_ref t_ref;
   g_ref_template_id_old_ref t_ref;
   g_template_ui_ref t_ref;
   g_ref_templ_ui_ref t_ref;
   g_template_id_old_ref t_ref;
   g_ui_templates_msg_id_ref t_ref;
   g_ui_templates_title_ref t_ref;
   g_ui_templates_jrad_new_ref varchar_type_tbl;
   g_ui_templates_jrad_old_ref varchar_type_tbl;
   g_ui_templates_button_tbl t_ref;
   g_ui_templates_but_uidef_id t_ref;
   g_cnt_typ_tmpls_old_uidef_ref t_ref;
   g_cnt_typ_tmpls_new_uidef_ref t_ref;
   g_cnt_typ_tmpls_tmpid_ref t_ref;
   g_cnt_typ_tmpls_tgtuidef_ref t_ref;
   g_cnt_typ_tmpls_cont_ref t_ref;
   g_ui_actns_ui_act_id_ref t_ref;
   g_ui_actns_ui_act_id_old_ref t_ref;
   g_ui_actions_id_idx_ref t_ref_idx_vc2;
   g_ui_actns_ui_uidef_ref t_ref;
   g_ui_actns_ui_tgtui_ref t_ref;
   g_ui_actns_ui_uidef_old_ref t_ref;
   g_ui_actns_tgtexpl_ref t_ref;
   g_ui_actns_ctx_comp_tbl t_ref;
   g_ui_actns_ren_cond_tbl t_ref;
   g_intl_text_model_tbl t_ref;
   g_intl_text_ui_tbl t_ref;
   g_archive_id_ref t_ref;
   g_devl_proj_ref t_ref;
   g_archives_new_ref t_ref;
   g_archives_old_ref t_ref;
   g_archives_old_tbl t_ref;
   g_archives_idx_ref t_ref_idx_vc2;
   g_archive_id_old_ref t_ref;
   g_devl_proj_old_ref t_ref;
   g_archives_obj_type varchar_tbl_type_3;
   g_archives_mig_idx_ref t_ref_idx_vc2;
   -- Bug 5514199; 12-Sep-2006; kdande; Moved the following plsql table declarations from package body
   -- in order to use these plsql tables in dynamic sqls of package body
   l_cnt_typ_tmpls_cont_ref cz_pb_mgr.t_ref;
   l_cnt_typ_tmpls_new_uidef_ref cz_pb_mgr.t_ref;
   l_ui_images_ui_ref cz_pb_mgr.t_ref;
   l_ui_images_enty_tbl cz_pb_mgr.t_ref;
   l_ui_images_usg_tbl cz_pb_mgr.t_ref;
   h_devl_prj_by_intl_text t_ref_idx_vc2;
   l_intl_text_id_tbl t_ref;
   l_bom_caption_rule_tbl t_ref;
   l_nonbom_caption_rule_tbl t_ref;
   v_ui_images_ui_ref t_ref;
   v_ui_images_ui_tbl t_ref;
   v_ui_images_usg_tbl t_ref;
   v_ui_images_enty_tbl t_ref;
   v_filter_sets_new_id_ref t_ref;
   v_filter_sets_id_ref t_ref;
   v_filter_sets_devl_ref t_ref;
   v_filter_sets_rule_ref t_ref;
   v_filter_sets_idx_ref t_ref_idx_vc2;
   v_populators_new_id_ref t_ref;
   v_populators_id_ref t_ref;
   v_populators_node_ref t_ref;
   v_populators_set_id_ref t_ref;
   g_jrad_trans_list jdr_utils.translationlist := jdr_utils.translationlist();
   g_migration_tgt_folder_id cz_model_publications.migration_tgt_folder%TYPE;
   g_mt_obj_type varchar_tbl_type_3;
   g_mt_enclosing_fld_rp_entry t_ref;
   g_ui_templates_obj_type varchar_tbl_type_3;
   g_enclosing_fld_rp_entry t_ref;
   g_eff_set_obj_type varchar_tbl_type_3;

   mm_intl_text_model_id_ref t_ref;

   -- 28b change
   g_ps_reverse_connector_tbl t_ref;
   g_uiact_prcpg_templ_tbl    t_ref;
   g_uiact_prcpg_tmpui_tbl    t_ref;
   g_uiact_prc_caption_tbl    t_ref;
   g_uiact_pg_title_tbl       t_ref;
   g_uiact_main_msg_tbl       t_ref;
   g_fcefile_old_id_tbl       t_ref;
   g_fcefile_new_id_tbl       t_ref;
   g_fcefile_compid_tbl       t_ref;

--Arrays for handling usage synch and re-keying during migration
   TYPE t_eff_usage_mask IS TABLE OF cz_ps_nodes.effective_usage_mask%TYPE
      INDEX BY BINARY_INTEGER;

   v_cz_effective_usage_mask_ref t_eff_usage_mask;
   v_cz_effective_usage_mask_tbl t_eff_usage_mask;
   v_cz_rule_usage_mask_tbl t_eff_usage_mask;
   v_cz_ps_to_eff_usg_mask t_eff_usage_mask;
   v_new_eff_usg_msk_tbl t_eff_usage_mask;
   v_new_rul_usg_msk_tbl t_eff_usage_mask;

   TYPE t_usage_name IS TABLE OF cz_model_usages.NAME%TYPE
      INDEX BY BINARY_INTEGER;

   v_old_usage_name_to_id_map t_usage_name;

   TYPE t_usage_name_1 IS TABLE OF cz_model_usages.model_usage_id%TYPE
      INDEX BY VARCHAR2(2000);

   v_new_usage_name_to_id_map t_usage_name_1;
   g_usg_name_processed t_usage_name_1;

   --Arrays for Mater template synch.
   v_master_template_id_ref t_ref;

   TYPE t_mt_name IS TABLE OF cz_ui_defs.NAME%TYPE
      INDEX BY BINARY_INTEGER;

   v_mt_name t_mt_name;
   v_mt_old_id_tbl t_ref;
   v_mt_old_id_ref t_ref;
   v_mt_gen_id t_ref;
   v_mt_old_only t_ref;

   TYPE t_mt_name_ref IS TABLE OF NUMBER
      INDEX BY cz_ui_defs.NAME%TYPE;

   v_mt_name_ref t_mt_name_ref;

   TYPE t_mt_name_to_id_map IS TABLE OF cz_ui_defs.ui_def_id%TYPE
      INDEX BY VARCHAR2(2000);

   v_new_mt_name_to_id_map t_mt_name_to_id_map;
   v_mt_id_ref t_ref;
   v_new_mt_id_ref t_ref;
   v_new_mt_id_tbl t_ref;
   v_mt_old_to_new_id t_ref_idx_vc2;

--->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--------sequence generator
   FUNCTION sequence_generate(seq_const PLS_INTEGER, seq_name VARCHAR2, p_oraclesequenceincr NUMBER)
      RETURN NUMBER;

----->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------------- procedure to publish a single model
   PROCEDURE publish_model(publicationid IN NUMBER, x_run_id IN OUT NOCOPY NUMBER, x_pb_status IN OUT NOCOPY VARCHAR2);

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---------procedure to publish all models
   PROCEDURE publish_all_models;

------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-------procedure to check if model is upto date
   PROCEDURE model_upto_date(modelid IN NUMBER, uidefid IN NUMBER, status IN OUT NOCOPY VARCHAR2);

-------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---------deep model copy
   PROCEDURE deep_model_copy(
      p_model_id IN NUMBER
     ,p_server_id IN NUMBER
     ,p_folder IN NUMBER
     ,p_copy_rules IN NUMBER
     ,p_copy_uis IN NUMBER
     ,p_copy_root IN NUMBER
     ,x_model_id OUT NOCOPY NUMBER
     ,x_run_id OUT NOCOPY NUMBER
     ,x_status OUT NOCOPY VARCHAR2
   );

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   PROCEDURE deep_model_copy(
      p_model_id IN NUMBER
     ,p_server_id IN NUMBER
     ,p_folder IN NUMBER
     ,p_copy_rules IN NUMBER
     ,p_copy_uis IN NUMBER
     ,p_copy_root IN NUMBER
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
     ,p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_TRUE
);

-------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--------check overlap publications
   PROCEDURE check_publication_overlap(
      productkey IN VARCHAR2
     ,publicationmode IN VARCHAR2
     ,applicationid IN VARCHAR2
     ,languageid IN VARCHAR2
     ,usageid IN VARCHAR2
     ,serverid IN NUMBER
     ,startdate IN DATE
     ,disabledate IN DATE
     ,sourcetargetflag IN VARCHAR2
     ,pubrecid IN NUMBER
     ,publicationidstring OUT NOCOPY VARCHAR2
   );

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----------------edit publication
   PROCEDURE edit_publication(
      publicationid IN NUMBER
     ,applicationid IN OUT NOCOPY VARCHAR2
     ,languageid IN OUT NOCOPY VARCHAR2
     ,usageid IN OUT NOCOPY VARCHAR2
     ,startdate IN DATE
     ,disabledate IN DATE
     ,publicationmode IN VARCHAR2
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
   );

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--------------
   PROCEDURE edit_tgt_pub(
      publicationid IN NUMBER
     ,applicationid IN OUT NOCOPY VARCHAR2
     ,languageid IN OUT NOCOPY VARCHAR2
     ,usageid IN OUT NOCOPY VARCHAR2
     ,startdate IN DATE
     ,disabledate IN DATE
     ,publicationmode IN VARCHAR2
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
   );

-------------------------------
---------------enable publication
   PROCEDURE enable_publication(
      publicationid IN NUMBER
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
   );

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--------------disable publication
   PROCEDURE disable_publication(
      publicationid IN NUMBER
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
   );

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
----------delete publication
   PROCEDURE delete_publication(
      publicationid IN NUMBER
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
   );

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---------wrapper called by concurrent manager to publish models
---------
   PROCEDURE publish_single_model_cp(errbuf IN OUT NOCOPY VARCHAR2, retcode IN OUT NOCOPY PLS_INTEGER, p_publication_id NUMBER);

   PROCEDURE publish_models_cp(errbuf IN OUT NOCOPY VARCHAR2, retcode IN OUT NOCOPY PLS_INTEGER);

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
----------------log errors
---------------
   PROCEDURE log_pb_errors(p_message IN VARCHAR2, p_urgency IN VARCHAR2, p_caller IN VARCHAR2, p_statuscode IN PLS_INTEGER);

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   PROCEDURE reset_processing_pubs;

   FUNCTION retrieve_db_link(p_server_id PLS_INTEGER)
      RETURN VARCHAR2;

   FUNCTION is_val_number (p_str IN VARCHAR2) RETURN VARCHAR2;

   PROCEDURE republish_model(
      p_publication_id IN OUT NOCOPY NUMBER
     ,p_start_date IN OUT NOCOPY DATE
     ,p_end_date IN OUT NOCOPY DATE
     ,x_run_id OUT NOCOPY NUMBER
     ,x_status OUT NOCOPY cz_model_publications.export_status%TYPE
   );

   PROCEDURE create_republish_publication(
      p_publication_id IN NUMBER
     ,x_new_publication_id OUT NOCOPY NUMBER
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
   );

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----procedure to copy single UI
   PROCEDURE export_single_oa_ui(
      p_ui_def_id IN NUMBER
     ,x_ui_def_id OUT NOCOPY NUMBER
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
   );

   PROCEDURE is_ui_upto_date(p_ui_def_id IN NUMBER, x_return_status OUT NOCOPY NUMBER, x_msg_data OUT NOCOPY VARCHAR2);

   FUNCTION is_ui_upto_date(p_ui_def_id IN NUMBER)
      RETURN VARCHAR2;

   PROCEDURE is_model_upto_date(p_model_id IN NUMBER, x_return_status IN OUT NOCOPY NUMBER, x_msg_data IN OUT NOCOPY VARCHAR2);

   PROCEDURE export_jrad_docs(
      p_document_name IN VARCHAR2
     ,p_link_name IN VARCHAR2
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
   );

   PROCEDURE insert_jrad_docs;

   PROCEDURE export_jrad_docs(
      p_ui_def_id IN NUMBER
     ,p_link_name IN VARCHAR2
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
   );

   PROCEDURE export_template_jrad_docs(
      p_link_name IN VARCHAR2
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
   );

   PROCEDURE exploretree(
      p_jrad_parent_element IN jdr_docbuilder.ELEMENT
     ,p_dom_parent_element IN xmldom.domnode
     ,p_grouping_tag IN VARCHAR2
     ,p_link_name IN VARCHAR2
   );

   FUNCTION copy_name(p_devl_project_id IN NUMBER)
      RETURN VARCHAR2;

   PROCEDURE create_publication_request(
      p_model_id IN NUMBER
     ,p_ui_def_id IN NUMBER
     ,p_publication_mode IN VARCHAR2
     ,p_server_id IN NUMBER
     ,p_appl_id_tbl IN cz_pb_mgr.t_ref
     ,p_usg_id_tbl IN cz_pb_mgr.t_ref
     ,p_lang_tbl IN cz_pb_mgr.t_lang_code
     ,p_start_date IN DATE
     ,p_end_date IN DATE
     ,x_publication_id OUT NOCOPY NUMBER
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
   );

   PROCEDURE edit_publication(
      publicationid IN NUMBER
     ,applicationid IN OUT NOCOPY cz_pb_mgr.t_ref
     ,languageid IN OUT NOCOPY cz_pb_mgr.t_lang_code
     ,usageid IN OUT NOCOPY cz_pb_mgr.t_ref
     ,startdate IN DATE
     ,disabledate IN DATE
     ,publicationmode IN VARCHAR2
     ,x_return_status OUT NOCOPY VARCHAR2
     ,x_msg_count OUT NOCOPY NUMBER
     ,x_msg_data OUT NOCOPY VARCHAR2
   );

   PROCEDURE seed_fnd_application_cp(errbuf IN OUT NOCOPY VARCHAR2, retcode IN OUT NOCOPY PLS_INTEGER, p_application_name VARCHAR2);

--model migration
--more columns required for property resolution
   v_prop_vals_item_type_id_ref t_ref;
   v_prop_vals_item_id_ref t_ref;
   v_prop_vals_valuesource_ref varchar_type_8_tbl;
   v_prop_vals_inherited_flag_ref varchar_type_1_tbl;
   model_publication_obselete CONSTANT VARCHAR2(3) := 'OBS';
   pub_maybe_obsoleted EXCEPTION;
   prop_valuesource_itemdefault CONSTANT VARCHAR2(7) := 'ItmDflt';
   prop_valuesource_item CONSTANT VARCHAR2(4) := 'Item';
   prop_valuesource_itemtype CONSTANT VARCHAR2(6) := 'ItmTyp';
   prop_valuesource_psdefault CONSTANT VARCHAR2(6) := 'PsDflt';
   prop_valuesource_psvalue CONSTANT VARCHAR2(7) := 'PsValue';
   mm_v_tbl_sync_prop_type varchar_tbl_type_3;
   mm_v_tbl_sync_prop_folder t_ref;
   mm_v_ui_from_msttmp_id_tbl t_ref;
   mm_v_tbl_sync_prop t_ref_idx_vc2;
   mm_v_tbl_sync_prop_vals_num t_ref_idx_vc2;
   mm_v_tbl_prop_vals_trans_old t_ref;
   mm_v_tbl_prop_vals_trans_new t_ref;
   mm_v_ht_sync_all_prop t_ref_idx_vc2;
   mm_v_ht_sync_all_prop_val_num t_ref;
   mm_v_ht_sync_item_type t_ref_idx_vc2;
   mm_v_ht_sync_item_type_items t_ref_idx_vc2;
   mm_v_ht_sync_items t_ref_idx_vc2;
   mm_v_ht_sync_it_propval_itm t_ref_idx_vc2;
   mm_v_ht_sync_exist_items t_ref;
   mm_v_ht_sync_exist_item_types t_ref;  --Bug9180063
   mm_v_ps_item_id_tbl t_ref;
   mm_v_ps_item_type_id_tbl t_ref; --Bug9180063
   mm_v_ht_sync_item_prop t_ref;
   mm_v_ht_sync_item_type_prop t_ref_idx_vc2;
   mm_v_ht_sync_itmtype_for_prop t_ref_idx_vc2;
   mm_v_ht_sync_ps_propval t_ref;
   mm_v_ht_sync_it_propval t_ref_idx_vc2;
   mm_v_ht_sync_archives t_ref;
   mm_v_ht_sync_archive_refs t_ref;
   mm_v_itmst_ref_part_nbr_ref varchar_type_1000_tbl;
   mm_v_itmst_ref_part_nbr_tbl varchar_type_1000_tbl;
   mm_v_itmst_src_app_id_ref t_ref;
   mm_v_itmst_src_app_id_tbl t_ref;
   mm_v_ht_eff_set_tbl_t t_ref;
   mm_v_ht_eff_set_tbl_s t_ref;
   mm_v_tbl_rule_seq t_ref;
   mm_v_ht_rule_rule_seq t_ref;
   mm_v_ht_item_types_orig_ref orig_sys_ref_type;
   mm_v_ht_items_orig_ref orig_sys_ref_type;
   mm_v_ht_item_typ_prop_orig_ref orig_sys_ref_type_vc2; --Bug9031588
   mm_v_ht_item_prop_val_orig_ref orig_sys_ref_type_vc2; --Bug9031588
   v_src_type_prop_orig_tbl cz_pb_mgr.orig_sys_ref_type;  --Bug9031588
   v_tgt_type_prop_orig_tbl cz_pb_mgr.orig_sys_ref_type;  --Bug9031588
   v_src_item_type_prop_orig_ref cz_pb_mgr.orig_sys_ref_type;  --Bug9031588
   v_tgt_item_type_prop_orig_ref cz_pb_mgr.orig_sys_ref_type;  --Bug9031588
   v_src_prop_val_orig_tbl cz_pb_mgr.orig_sys_ref_type;  --Bug9031588
   v_tgt_prop_val_orig_tbl cz_pb_mgr.orig_sys_ref_type;  --Bug9031588
   v_src_item_prop_val_orig_ref cz_pb_mgr.orig_sys_ref_type;  --Bug9031588
   v_tgt_item_prop_val_orig_ref cz_pb_mgr.orig_sys_ref_type;  --Bug9031588
   mm_insert_array1 t_ref;
   mm_insert_array2 t_ref;
   mm_insert_array3 orig_sys_ref_type;
   mm_source_array1 t_ref;
   mm_source_array2 t_ref;
   mm_source_array3 orig_sys_ref_type;
   mm_objtype_array varchar_tbl_type_3;
   mm_tgtfldr_array t_ref;

   PROCEDURE mm_loadoldpsnodesforitems;

   PROCEDURE mm_raiseallpossiblesyncerrors;

   PROCEDURE get_all_properties;

   PROCEDURE mm_sync_properties;

   PROCEDURE mm_migrate_into_ps_prop_vals;

   PROCEDURE mm_sync_itemschema;

   PROCEDURE mm_insert_archives;

   PROCEDURE mm_sync_archives;


   PROCEDURE mm_insert_archives_for_pb;

   PROCEDURE mm_get_ifexists_on_target(source_id IN NUMBER, target_id IN OUT NOCOPY NUMBER, what_exists IN VARCHAR2);

   FUNCTION mm_sync_eff_sets(old_eff_set_id NUMBER, new_eff_set_id NUMBER)
      RETURN NUMBER;

   FUNCTION mm_get_ifexists_on_source(source_id IN NUMBER, what_exists VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION mm_get_newid(what_id IN VARCHAR2)
      RETURN NUMBER;

   mm_v_rootmodels_tobe_exported t_ref;
   mm_v_rootmodels_notbe_exported t_ref;

   PROCEDURE mm_get_models_tobe_exported(rootmodelid_tbl IN cz_pb_mgr.t_ref);

   FUNCTION mm_chkifmodelselectedforexport(input_model NUMBER)
      RETURN NUMBER;

   FUNCTION get_rootmodel_and_mig_tgt_fldr(p_publication_id NUMBER)
      RETURN t_ref;

   PROCEDURE mm_break_long_str(v_inp_str IN VARCHAR2);

   PROCEDURE mm_resolve_ids(
      array_to_resolve IN cz_pb_mgr.t_ref
     ,array_of_new_keys IN cz_pb_mgr.t_ref_idx_vc2
     ,resolving_id IN VARCHAR2
     ,resolved_array IN OUT NOCOPY cz_pb_mgr.t_ref
     ,source_array IN OUT NOCOPY cz_pb_mgr.t_ref
   );

   PROCEDURE mm_resolve_ids_w_rp_entries(
      array_to_resolve IN cz_pb_mgr.t_ref
     ,array_of_new_keys IN cz_pb_mgr.t_ref_idx_vc2
     ,object_type IN VARCHAR2
     ,target_folder IN NUMBER
     ,resolving_id IN VARCHAR2
     ,resolved_array IN OUT NOCOPY cz_pb_mgr.t_ref
     ,object_type_array IN OUT NOCOPY cz_pb_mgr.varchar_tbl_type_3
     ,tgt_folder_array IN OUT NOCOPY cz_pb_mgr.t_ref
     ,source_array IN OUT NOCOPY cz_pb_mgr.t_ref
   );

   PROCEDURE mm_resolve_orig_refs(
      array_to_resolve IN cz_pb_mgr.t_ref
     ,array_of_new_keys IN cz_pb_mgr.orig_sys_ref_type
     ,resolving_id IN VARCHAR2
     ,resolved_array IN OUT NOCOPY cz_pb_mgr.orig_sys_ref_type
     ,source_array IN OUT NOCOPY cz_pb_mgr.orig_sys_ref_type
   );
--Bug9031588
   PROCEDURE mm_resolve_orig_refs(
      array_to_resolve IN cz_pb_mgr.orig_sys_ref_type
     ,array_of_new_keys IN cz_pb_mgr.orig_sys_ref_type_vc2
     ,resolving_id IN VARCHAR2
     ,resolved_array IN OUT NOCOPY cz_pb_mgr.orig_sys_ref_type
     ,source_array IN OUT NOCOPY cz_pb_mgr.orig_sys_ref_type
   );

   PROCEDURE mm_resync_ps_items;

   PROCEDURE mm_resync_ps_item_types; --Bug9180063


   PROCEDURE insert_into_rp_entries(
      table_name IN VARCHAR2
     ,primary_key1 IN VARCHAR2
     ,primary_key2 IN VARCHAR2
     ,db_link IN VARCHAR2
     ,plsql_table_list IN cz_pb_mgr.col_plsql_table_list
     ,plsql_table_name1 IN VARCHAR2
     ,plsql_table_name2 IN VARCHAR2
     ,primary_key_plsql_table1 IN OUT NOCOPY cz_pb_mgr.t_ref
     ,primary_key_plsql_table2 IN OUT NOCOPY cz_pb_mgr.varchar_tbl_type_3
   );

   PROCEDURE mm_resolve_rule_seq_effsetid;
   FUNCTION getRemoteImportServer(x_import_server_on_local IN OUT NOCOPY cz_servers.server_local_id%TYPE) RETURN NUMBER;
   FUNCTION has_ui_inany_chld_mdl_changed(rootmodelid IN NUMBER)RETURN boolean;
   FUNCTION get_mdl_last_xfr_activity(
      p_model_id IN cz_model_publications.model_id%TYPE
     ,p_server_id IN cz_model_publications.server_id%TYPE

   ) RETURN DATE;
END cz_pb_mgr;

/
