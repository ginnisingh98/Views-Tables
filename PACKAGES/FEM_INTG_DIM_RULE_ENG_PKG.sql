--------------------------------------------------------
--  DDL for Package FEM_INTG_DIM_RULE_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_INTG_DIM_RULE_ENG_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_intg_dim_eng.pls 120.1.12010000.3 2009/08/11 08:53:19 shrsriva ship $ */
  pv_dim_rule_obj_id                   NUMBER(9);
  pv_dim_rule_obj_def_id               NUMBER(9);
  pv_dim_id                            NUMBER(9);
  pv_dim_varchar_label                 VARCHAR2(30);
  pv_member_b_table_name               VARCHAR2(30);
  pv_member_tl_table_name              VARCHAR2(30);
  pv_member_vl_object_name             VARCHAR2(30);
  pv_member_col                        VARCHAR2(30);
  pv_cctr_org_member_col               VARCHAR2(30);
  pv_member_display_code_col           VARCHAR2(30);
  pv_member_name_col                   VARCHAR2(30);
  pv_member_desc_col                   VARCHAR2(30);
  pv_attr_table_name                   VARCHAR2(30);
  pv_coa_id                            NUMBER(10);
  pv_coa_name                          VARCHAR2(30);
  pv_com_vs_id                         NUMBER;
  pv_cc_vs_id                          NUMBER;
  pv_gvsc_id                           NUMBER(9);
  pv_fem_vs_id                         NUMBER;
  pv_ledger_attr_varchar_label         VARCHAR2(30);
  pv_com_dim_id                        NUMBER(9);
  pv_cc_dim_id                         NUMBER(9);
  pv_cctr_org_dim_id                   NUMBER(9);
  pv_fin_element_dim_id                NUMBER(9);
  pv_dim_mapping_option_code           VARCHAR2(10);
  pv_default_member_id                 NUMBER;
  pv_default_member_vs_id              NUMBER;
  pv_fin_element_vs_id                 NUMBER;
  pv_segment_count                     NUMBER;
  pv_source_system_code_id             NUMBER;
  pv_max_ccid_processed                NUMBER;
  pv_max_ccid_to_be_mapped             NUMBER;
  pv_max_ccid_in_map_table             NUMBER;
  pv_max_flex_value_id_processed       NUMBER;
  pv_req_id                            NUMBER;
  pv_user_id                           NUMBER;
  pv_login_id                          NUMBER;
  pv_pgm_id                            NUMBER;
  pv_pgm_app_id                        NUMBER;
  pv_folder_id                         NUMBER(9);
  pv_ext_acct_type_attr_id             NUMBER;
  pv_ext_acct_attr_version_id          NUMBER;
  pv_summary_flag                      VARCHAR2(1);
  pv_balancing_segment_num             NUMBER;
  pv_cost_center_segment_num           NUMBER;
  pv_natural_account_segment_num       NUMBER;

  TYPE map_seg_info IS RECORD(
    application_column_name     VARCHAR2(30),
    vs_id                       NUMBER(10),
    table_validated_flag        VARCHAR2(1),
    table_name                  VARCHAR2(30),
    id_col_name                VARCHAR2(240),
    val_col_name                VARCHAR2(240),
    compiled_attr_col_name      VARCHAR2(240),
    meaning_col_name            VARCHAR2(240),
    where_clause                VARCHAR2(4000),
    dependent_value_set_flag    VARCHAR2(1),
    dependent_vs_id             NUMBER,
    dependent_segment_column    VARCHAR2(30)
  );

  TYPE mapped_segments is VARRAY(5) OF map_seg_info;

  pv_mapped_segs mapped_segments := mapped_segments();


  PROCEDURE Init;

  PROCEDURE main(
    x_errbuf OUT NOCOPY  VARCHAR2,
    x_retcode OUT NOCOPY VARCHAR2,
    p_dim_rule_obj_def_id IN NUMBER,
    p_execution_mode IN VARCHAR2
  );

  PROCEDURE UNDO_DIM_RULE(
    x_errbuf OUT NOCOPY VARCHAR2,
    x_retcode OUT NOCOPY VARCHAR2,
    p_dim_rule_obj_id IN NUMBER
  );

  PROCEDURE SUBMIT_ALL_DIM_HIER_RULES(
    x_errbuf OUT NOCOPY VARCHAR2,
    x_retcode OUT NOCOPY VARCHAR2,
    p_coa_id IN NUMBER
  );
END;

/
