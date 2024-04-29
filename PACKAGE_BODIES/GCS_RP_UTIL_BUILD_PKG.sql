--------------------------------------------------------
--  DDL for Package Body GCS_RP_UTIL_BUILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_RP_UTIL_BUILD_PKG" AS
/* $Header: gcsrputbldb.pls 120.4 2008/01/25 10:42:22 hakumar ship $ */
  --Global Variables
    g_api	VARCHAR2(50)	:=	'gcs.plsql.GCS_RP_UTIL_BUILD_PKG';
    g_nl	VARCHAR2(1)	:=	'''';

  PROCEDURE add_insert_clause_to_list  ( p_dimension_required   IN VARCHAR2,
                                         p_prefix               IN VARCHAR2,
                                         p_rownum               IN OUT NOCOPY NUMBER,
                                         p_column_name          IN VARCHAR2)
  IS
  BEGIN
    IF (p_dimension_required = 'Y') THEN
       ad_ddl.build_statement('           ' || p_prefix || p_column_name || ',     ', p_rownum); p_rownum:=p_rownum+1;
    END IF;
  END add_insert_clause_to_list;

  PROCEDURE build_insert_clause_list (p_rownum   	IN OUT NOCOPY NUMBER,
                                      p_prefix          IN VARCHAR2)
  IS
  l_dim_info gcs_utility_pkg.t_hash_gcs_dimension_info := gcs_utility_pkg.g_gcs_dimension_info;
  BEGIN

      add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('CHANNEL_ID'),
                                p_prefix,
                                p_rownum,
				'channel_id');

      add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('CUSTOMER_ID'),
                                p_prefix,
                                p_rownum,
				'customer_id');

      add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('FINANCIAL_ELEM_ID'),
                                p_prefix,
                                p_rownum,
                                'financial_elem_id');

      add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('LINE_ITEM_ID'),
                                p_prefix,
                                p_rownum,
                                'line_item_id');

      add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('NATURAL_ACCOUNT_ID'),
                                p_prefix,
                                p_rownum,
				'natural_account_id');

      add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('PRODUCT_ID'),
                                p_prefix,
                                p_rownum,
				'product_id');

      add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('PROJECT_ID'),
                                p_prefix,
                                p_rownum,
				'project_id');

      add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('TASK_ID'),
                                p_prefix,
                                p_rownum,
				'task_id');

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM10_ID'),
                                  p_prefix,
                                  p_rownum,
				  'user_dim10_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM1_ID'),
                                  p_prefix,
                                  p_rownum,
                                  'user_dim1_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM2_ID'),
                                  p_prefix,
                                  p_rownum,
                                  'user_dim2_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM3_ID'),
                                  p_prefix,
                                  p_rownum,
                                  'user_dim3_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM4_ID'),
                                  p_prefix,
                                  p_rownum,
                                  'user_dim4_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM5_ID'),
                                  p_prefix,
                                  p_rownum,
                                  'user_dim5_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM6_ID'),
                                  p_prefix,
                                  p_rownum,
                                  'user_dim6_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM7_ID'),
                                  p_prefix,
                                  p_rownum,
                                  'user_dim7_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM8_ID'),
                                  p_prefix,
                                  p_rownum,
                                  'user_dim8_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_insert_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM9_ID'),
                                  p_prefix,
                                  p_rownum,
                                  'user_dim9_id');
      END IF;

  END build_insert_clause_list;

  PROCEDURE add_select_clause_to_list  ( p_dimension_required   IN VARCHAR2,
					 p_table_alias		IN VARCHAR2,
                                         p_rownum               IN OUT NOCOPY NUMBER,
					 p_column_name          IN VARCHAR2)
  IS
  BEGIN
    IF (p_dimension_required = 'Y') THEN
       ad_ddl.build_statement(' , ' || p_table_alias || p_column_name, p_rownum); p_rownum := p_rownum +1;
    END IF;
  END add_select_clause_to_list;

  PROCEDURE build_select_clause_list (p_rownum   	IN OUT NOCOPY NUMBER,
				      p_table_alias	IN VARCHAR2)
  IS
  l_dim_info gcs_utility_pkg.t_hash_gcs_dimension_info := gcs_utility_pkg.g_gcs_dimension_info;
  BEGIN

      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('CHANNEL_ID'),
                                p_table_alias,
                                p_rownum,
				'channel_id');

      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('CUSTOMER_ID'),
                                p_table_alias,
                                p_rownum,
				'customer_id');

      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('FINANCIAL_ELEM_ID'),
                                p_table_alias,
                                p_rownum,
                                'financial_elem_id');

      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('LINE_ITEM_ID'),
                                p_table_alias,
                                p_rownum,
                                'line_item_id');

      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('NATURAL_ACCOUNT_ID'),
				p_table_alias,
                                p_rownum,
				'natural_account_id');

      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('PRODUCT_ID'),
                                p_table_alias,
                                p_rownum,
				'product_id');

      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('PROJECT_ID'),
                                p_table_alias,
                                p_rownum,
				'project_id');

      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('TASK_ID'),
				p_table_alias,
                                p_rownum,
				'task_id');

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM10_ID'),
                                  p_table_alias,
                                  p_rownum,
				  'user_dim10_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM1_ID'),
                                  p_table_alias,
                                  p_rownum,
                                  'user_dim1_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM2_ID'),
                                  p_table_alias,
                                  p_rownum,
                                  'user_dim2_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM3_ID'),
                                  p_table_alias,
                                  p_rownum,
                                  'user_dim3_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM4_ID'),
                                  p_table_alias,
                                  p_rownum,
                                  'user_dim4_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM5_ID'),
                                  p_table_alias,
                                  p_rownum,
                                  'user_dim5_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM6_ID'),
                                  p_table_alias,
                                  p_rownum,
                                  'user_dim6_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM7_ID'),
                                  p_table_alias,
                                  p_rownum,
                                  'user_dim7_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM8_ID'),
                                  p_table_alias,
                                  p_rownum,
                                  'user_dim8_id');
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM9_ID'),
                                  p_table_alias,
                                  p_rownum,
                                  'user_dim9_id');
      END IF;

  END build_select_clause_list;

  PROCEDURE add_column_to_group (        p_dimension_required   IN VARCHAR2,
                                         p_table_alias          IN VARCHAR2,
                                         p_rownum               IN OUT NOCOPY NUMBER,
					 p_column_name          IN VARCHAR2,
                                         p_assign_type          IN VARCHAR2)
  IS
  BEGIN
    IF (p_dimension_required = 'Y') THEN
       if (p_assign_type =  'variableassignment') then
         ad_ddl.build_statement('   ,' || p_table_alias || '.' || p_column_name , p_rownum); p_rownum := p_rownum + 1;
       else
         if (p_column_name <> 'line_item_id') then
           ad_ddl.build_statement('           ,' || p_table_alias || p_column_name, p_rownum); p_rownum := p_rownum + 1;
         end if;
       end if;
    END IF;
  END add_column_to_group;

  PROCEDURE build_group_by_clause (   p_rownum   	IN OUT NOCOPY NUMBER,
                                      p_table_alias     IN VARCHAR2,
                                      p_assign_type     IN VARCHAR2)

  IS
  l_dim_info gcs_utility_pkg.t_hash_gcs_dimension_info := gcs_utility_pkg.g_gcs_dimension_info;
  BEGIN

      add_column_to_group(gcs_utility_pkg.get_dimension_required('CHANNEL_ID'),
                          p_table_alias,
                          p_rownum,
			  'channel_id',
                          p_assign_type);

      add_column_to_group(gcs_utility_pkg.get_dimension_required('CUSTOMER_ID'),
                          p_table_alias,
                          p_rownum,
			  'customer_id',
                          p_assign_type);

      add_column_to_group(gcs_utility_pkg.get_dimension_required('FINANCIAL_ELEM_ID'),
                          p_table_alias,
                          p_rownum,
                          'financial_elem_id',
                          p_assign_type);

      add_column_to_group(gcs_utility_pkg.get_dimension_required('LINE_ITEM_ID'),
                          p_table_alias,
                          p_rownum,
                          'line_item_id',
                          p_assign_type);

      add_column_to_group(gcs_utility_pkg.get_dimension_required('NATURAL_ACCOUNT_ID'),
			  p_table_alias,
                          p_rownum,
		          'natural_account_id',
                          p_assign_type);

      add_column_to_group(gcs_utility_pkg.get_dimension_required('PRODUCT_ID'),
                          p_table_alias,
                          p_rownum,
			  'product_id',
                          p_assign_type);

      add_column_to_group(gcs_utility_pkg.get_dimension_required('PROJECT_ID'),
                          p_table_alias,
                          p_rownum,
			  'project_id',
                          p_assign_type);

      add_column_to_group(gcs_utility_pkg.get_dimension_required('TASK_ID'),
			  p_table_alias,
                          p_rownum,
			  'task_id',
                          p_assign_type);

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_column_to_group(gcs_utility_pkg.get_dimension_required('USER_DIM10_ID'),
                            p_table_alias,
                            p_rownum,
			    'user_dim10_id',
                            p_assign_type);
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_column_to_group(gcs_utility_pkg.get_dimension_required('USER_DIM1_ID'),
                            p_table_alias,
                            p_rownum,
                            'user_dim1_id',
                            p_assign_type);
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_column_to_group(gcs_utility_pkg.get_dimension_required('USER_DIM2_ID'),
                            p_table_alias,
                            p_rownum,
                            'user_dim2_id',
                            p_assign_type);
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_column_to_group(gcs_utility_pkg.get_dimension_required('USER_DIM3_ID'),
                            p_table_alias,
                            p_rownum,
                            'user_dim3_id',
                            p_assign_type);
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_column_to_group(gcs_utility_pkg.get_dimension_required('USER_DIM4_ID'),
                            p_table_alias,
                            p_rownum,
                            'user_dim4_id',
                            p_assign_type);
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_column_to_group(gcs_utility_pkg.get_dimension_required('USER_DIM5_ID'),
                            p_table_alias,
                            p_rownum,
                            'user_dim5_id',
                            p_assign_type);
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_column_to_group(gcs_utility_pkg.get_dimension_required('USER_DIM6_ID'),
                            p_table_alias,
                            p_rownum,
                            'user_dim6_id',
                            p_assign_type);
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_column_to_group(gcs_utility_pkg.get_dimension_required('USER_DIM7_ID'),
                            p_table_alias,
                            p_rownum,
                            'user_dim7_id',
                            p_assign_type);
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_column_to_group(gcs_utility_pkg.get_dimension_required('USER_DIM8_ID'),
                            p_table_alias,
                            p_rownum,
                            'user_dim8_id',
                            p_assign_type);
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_column_to_group(gcs_utility_pkg.get_dimension_required('USER_DIM9_ID'),
                            p_table_alias,
                            p_rownum,
                            'user_dim9_id',
                            p_assign_type);
      END IF;

  END build_group_by_clause;

  PROCEDURE create_rp_utility_pkg      (p_retcode	NUMBER,
                                        p_errbuf	VARCHAR2)
  IS
    r		NUMBER(15) 	:=	1;
    comp_err	VARCHAR2(200)	:=	NULL;
  BEGIN

    --Create Package Specification for RP Utility Package
    ad_ddl.build_statement('CREATE OR REPLACE PACKAGE GCS_RP_UTILITY_PKG AS', r); r := r+1;
    ad_ddl.build_statement(' ', r); r := r+1;
    ad_ddl.build_statement('--API Name', r); r := r+1;
    ad_ddl.build_statement('  g_api		VARCHAR2(50) :=	''gcs.plsql.GCS_RP_UTILITY_PKG'';', r); r := r+1;
    ad_ddl.build_statement(' ', r); r := r+1;
    ad_ddl.build_statement('  -- Action types for writing module information to the log file. Used for', r); r:=r+1;
    ad_ddl.build_statement('  -- the procedure log_file_module_write.', r); r:=r+1;
    ad_ddl.build_statement('  g_module_enter      VARCHAR2(2) := ''>>'';', r); r:=r+1;
    ad_ddl.build_statement('  g_module_success    VARCHAR2(2) := ''<<'';', r); r:=r+1;
    ad_ddl.build_statement('  g_module_failure    VARCHAR2(2) := ''<x'';', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  g_rp_selColumnList  VARCHAR2(10000) := ''', r); r:=r+1;
    build_select_clause_list(r,'b.');
    ad_ddl.build_statement(' ''; ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  g_rp_srcColumnList  VARCHAR2(10000) := ''', r); r:=r+1;
    build_select_clause_list(r,'src_');
    ad_ddl.build_statement(' ''; ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  g_rp_tgtColumnList  VARCHAR2(10000) := ''', r); r:=r+1;
    build_select_clause_list(r,'tgt_');
    ad_ddl.build_statement(' ''; ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  g_rp_offColumnList  VARCHAR2(10000) := ''', r); r:=r+1;
    build_select_clause_list(r, 'off_');
    ad_ddl.build_statement(' ) ''; ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  g_core_insert_stmt VARCHAR2(2000) := ', r); r:=r+1;
    ad_ddl.build_statement('  ''INSERT INTO gcs_entries_gt(   ', r); r:=r+1;
    ad_ddl.build_statement('    rule_id                   , ', r); r:=r+1;
    ad_ddl.build_statement('    step_seq                  , ', r); r:=r+1;
    ad_ddl.build_statement('    step_name                 , ', r); r:=r+1;
    ad_ddl.build_statement('    formula_text              , ', r); r:=r+1;
    ad_ddl.build_statement('    rule_step_id              , ', r); r:=r+1;
    ad_ddl.build_statement('    offset_flag               , ', r); r:=r+1;
    ad_ddl.build_statement('    sql_statement_num         , ', r); r:=r+1;
    ad_ddl.build_statement('    currency_code             , ', r); r:=r+1;
    ad_ddl.build_statement('    ad_input_amount           , ', r); r:=r+1;
    ad_ddl.build_statement('    pe_input_amount           , ', r); r:=r+1;
    ad_ddl.build_statement('    ce_input_amount           , ', r); r:=r+1;
    ad_ddl.build_statement('    ee_input_amount		  , ', r); r:=r+1;
    ad_ddl.build_statement('    output_amount             , ', r); r:=r+1;
    ad_ddl.build_statement('    entity_id                 , ', r); r:=r+1;
    ad_ddl.build_statement('    ytd_credit_balance_e      , ', r); r:=r+1;
    ad_ddl.build_statement('    ytd_debit_balance_e       , ', r); r:=r+1;
    ad_ddl.build_statement('    src_company_cost_center_org_id , ', r); r:=r+1;
    ad_ddl.build_statement('    src_intercompany_id       , ', r); r:=r+1;
    ad_ddl.build_statement('    tgt_company_cost_center_org_id , ', r); r:=r+1;
    ad_ddl.build_statement('    tgt_intercompany_id       ''; ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  g_core_sel_stmt VARCHAR2(2000)      := ', r); r:=r+1;
    ad_ddl.build_statement('  ''SELECT :rid                              , ', r); r:=r+1;
    ad_ddl.build_statement('           :seq                              , ', r); r:=r+1;
    ad_ddl.build_statement('           :sna                              , ', r); r:=r+1;
    ad_ddl.build_statement('           :ftx                              , ', r); r:=r+1;
    ad_ddl.build_statement('           :rsi                              , ', r); r:=r+1;
    ad_ddl.build_statement('           :osf                              , ', r); r:=r+1;
    ad_ddl.build_statement('           :stn                              , ', r); r:=r+1;
    ad_ddl.build_statement('           :ccy                              , ', r); r:=r+1;
    ad_ddl.build_statement('           0                                 , ', r); r:=r+1;
    ad_ddl.build_statement('           SUM(                                ', r); r:=r+1;
    ad_ddl.build_statement('             DECODE(b.entity_id, :pid,         ', r); r:=r+1;
    ad_ddl.build_statement('               b.ytd_balance_e, 0))          , ', r); r:=r+1;
    ad_ddl.build_statement('           SUM(                                ', r); r:=r+1;
    ad_ddl.build_statement('             DECODE(b.entity_id, :cid,         ', r); r:=r+1;
    ad_ddl.build_statement('               b.ytd_balance_e, 0))          , ', r); r:=r+1;
    ad_ddl.build_statement('           SUM(                                ', r); r:=r+1;
    ad_ddl.build_statement('             DECODE(b.entity_id, :eid,         ', r); r:=r+1;
    ad_ddl.build_statement('               b.ytd_balance_e, 0))          , ', r); r:=r+1;
    ad_ddl.build_statement('           0                                 , ', r); r:=r+1;
    ad_ddl.build_statement('           0                                 , ', r); r:=r+1;
    ad_ddl.build_statement('           0                                 , ', r); r:=r+1;
    ad_ddl.build_statement('           0                                 ,  ', r); r:=r+1;
    ad_ddl.build_statement('           b.company_cost_center_org_id      , ', r); r:=r+1;
    ad_ddl.build_statement('           b.intercompany_id                 , ', r); r:=r+1;
    ad_ddl.build_statement('           :tgt_cctr_org_id                  , ', r); r:=r+1;
    ad_ddl.build_statement('           :tgt_intercompany_id              '';', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' g_core_frm_stmt VARCHAR2(2000)       :=    '' ', r); r:=r+1;
    ad_ddl.build_statement('   FROM   fem_balances b                    '';', r); r:=r+1;
    ad_ddl.build_statement(' g_core_whr_stmt VARCHAR2(2000)       :=     ''', r); r:=r+1;
    ad_ddl.build_statement('   WHERE  b.dataset_code       =   :dci        ', r); r:=r+1;
    ad_ddl.build_statement('   AND    b.cal_period_id      =   :cpi        ', r); r:=r+1;
    ad_ddl.build_statement('   AND    b.source_system_code =   70          ', r); r:=r+1;
    ad_ddl.build_statement('   AND    b.ledger_id          =   :ledger     ', r); r:=r+1;
    ad_ddl.build_statement('   AND    b.currency_code      =   :ccy '';    ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' g_core_grp_stmt VARCHAR2(2000)       := ''    ', r); r:=r+1;
    ad_ddl.build_statement('   group by b.company_cost_center_org_id       ', r); r:=r+1;
    build_group_by_clause(r,'b', 'variableassignment');
    ad_ddl.build_statement('   ,b.intercompany_id'';               ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  --Public Procedure and Function Definitions ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  --                                                                                     ', r); r:=r+1;
    ad_ddl.build_statement('  -- Procedure                                                                           ', r); r:=r+1;
    ad_ddl.build_statement('  --   create_entry_lines                                                                ', r); r:=r+1;
    ad_ddl.build_statement('  -- Purpose                                                                             ', r); r:=r+1;
    ad_ddl.build_statement('  --   Generated SQL statement to insert data into gcs_entry_lines from gcs_entries_gt   ', r); r:=r+1;
    ad_ddl.build_statement('  --                                                                                     ', r); r:=r+1;
    ad_ddl.build_statement('  -- Arguments                                                                           ', r); r:=r+1;
    ad_ddl.build_statement('  -- p_entry_id: entry identifier                                                        ', r); r:=r+1;
    ad_ddl.build_statement('  -- p_row_count: #of rows inserted                                                      ', r); r:=r+1;
    ad_ddl.build_statement('  --                                                                                     ', r); r:=r+1;
    ad_ddl.build_statement('  PROCEDURE create_entry_lines (p_entry_id IN NUMBER,                                    ', r); r:=r+1;
    ad_ddl.build_statement('                                p_offset_flag IN VARCHAR2,                               ', r); r:=r+1;
    ad_ddl.build_statement('                                p_row_count IN OUT NOCOPY NUMBER);                       ', r); r:=r+1;
    ad_ddl.build_statement('  --                                                                                     ', r); r:=r+1;
    ad_ddl.build_statement('  -- Procedure                                                                           ', r); r:=r+1;
    ad_ddl.build_statement('  --   create_off_gt_lines                                                               ', r); r:=r+1;
    ad_ddl.build_statement('  -- Purpose                                                                             ', r); r:=r+1;
    ad_ddl.build_statement('  --   creates offset lines in gcs_entries_gt for performance                            ', r); r:=r+1;
    ad_ddl.build_statement('  --                                                                                     ', r); r:=r+1;
    ad_ddl.build_statement('  -- Arguments                                                                           ', r); r:=r+1;
    ad_ddl.build_statement('  -- p_rule_id:  rule identifier                                                         ', r); r:=r+1;
    ad_ddl.build_statement('  -- p_step_seq: step seq identifier                                                     ', r); r:=r+1;
    ad_ddl.build_statement('  -- p_offset_members: offset member object                                              ', r); r:=r+1;
    ad_ddl.build_statement('  --                                                                                     ', r); r:=r+1;
    ad_ddl.build_statement('  --PROCEDURE create_off_gt_lines(p_entry_id IN NUMBER,                                  ', r); r:=r+1;
    ad_ddl.build_statement('  --                              p_row_count IN OUT NOCOPY NUMBER);                     ', r); r:=r+1;
    ad_ddl.build_statement('  --                                                                                     ', r); r:=r+1;

    ad_ddl.build_statement('END GCS_RP_UTILITY_PKG;', r);
    ad_ddl.create_plsql_object(GCS_DYNAMIC_UTIL_PKG.g_applsys_username,
                               'GCS', 'GCS_RP_UTILITY_PKG',
                               1, r , 'TRUE', comp_err);

    -- Create Package Body for GCS_RP_UTILITY_PKG
    r := 1;
    ad_ddl.build_statement('CREATE OR REPLACE PACKAGE BODY GCS_RP_UTILITY_PKG AS                                     ', r); r := r+1;
    ad_ddl.build_statement('                                                                                         ', r); r := r+1;
    ad_ddl.build_statement('  --Public Procedure and Function Definitions ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  --                                                                                     ', r); r:=r+1;
    ad_ddl.build_statement('  -- Procedure                                                                           ', r); r:=r+1;
    ad_ddl.build_statement('  --   create_entry_lines                                                                ', r); r:=r+1;
    ad_ddl.build_statement('  -- Purpose                                                                             ', r); r:=r+1;
    ad_ddl.build_statement('  --   Generated SQL statement to insert data into gcs_entry_lines from gcs_entries_gt   ', r); r:=r+1;
    ad_ddl.build_statement('  --                                                                                     ', r); r:=r+1;
    ad_ddl.build_statement('  -- Arguments                                                                           ', r); r:=r+1;
    ad_ddl.build_statement('  -- p_entry_id: entry identifier                                                        ', r); r:=r+1;
    ad_ddl.build_statement('  -- p_row_count: #of rows inserted                                                      ', r); r:=r+1;
    ad_ddl.build_statement('  --                                                                                     ', r); r:=r+1;
    ad_ddl.build_statement('  PROCEDURE create_entry_lines (p_entry_id IN NUMBER,                                    ', r); r:=r+1;
    ad_ddl.build_statement('                                p_offset_flag IN VARCHAR2,                               ', r); r:=r+1;
    ad_ddl.build_statement('                                p_row_count IN OUT NOCOPY NUMBER)                        ', r); r:=r+1;
    ad_ddl.build_statement('  IS                                                                                     ', r); r:=r+1;
    ad_ddl.build_statement('    l_elimtb_y_n VARCHAR2(1) := ''Y'';                                                   ', r); r:=r+1;
    ad_ddl.build_statement('  BEGIN                                                                                  ', r); r:=r+1;
    ad_ddl.build_statement('                                                                                         ', r); r:=r+1;
    ad_ddl.build_statement('    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then                 ', r); r:=r+1;
    ad_ddl.build_statement('      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, ''gcs_rp_utility_pkg.begin'', null);       ', r); r:=r+1;
    ad_ddl.build_statement('    end if;                                                                              ', r); r:=r+1;
    ad_ddl.build_statement('                                                                                         ', r); r:=r+1;
    ad_ddl.build_statement('    begin                                                                                ', r); r:=r+1;
    ad_ddl.build_statement('      select ''N''                                                                       ', r); r:=r+1;
    ad_ddl.build_statement('      into l_elimtb_y_n                                                                  ', r); r:=r+1;
    ad_ddl.build_statement('      from gcs_entries_gt geg                                                            ', r); r:=r+1;
    ad_ddl.build_statement('      where formula_text NOT LIKE ''%ELIMTB%''                                                   ', r); r:=r+1;
    ad_ddl.build_statement('      and rownum < 2;                                                                    ', r); r:=r+1;
    ad_ddl.build_statement('      exception when others then l_elimtb_y_n := ''Y'';                                      ', r); r:=r+1;
    ad_ddl.build_statement('    end;                                                                                 ', r); r:=r+1;
    ad_ddl.build_statement('                                                                                         ', r); r:=r+1;
    ad_ddl.build_statement('    if (l_elimtb_y_n = ''N'') then                                                       ', r); r:=r+1;
    ad_ddl.build_statement('    insert into gcs_entry_lines                                                          ', r); r:=r+1;
    ad_ddl.build_statement('    (      entry_id,                                                                     ', r); r:=r+1;
    ad_ddl.build_statement('           company_cost_center_org_id,                                                   ', r); r:=r+1;
    build_insert_clause_list(p_rownum          => r,
                             p_prefix          => null);
    ad_ddl.build_statement('           intercompany_id,                                                              ', r); r:=r+1;
    ad_ddl.build_statement('           ytd_debit_balance_e,                                                          ', r); r:=r+1;
    ad_ddl.build_statement('           ytd_credit_balance_e,                                                         ', r); r:=r+1;
    ad_ddl.build_statement('           ytd_balance_e,                                                                ', r); r:=r+1;
    ad_ddl.build_statement('           creation_date,                                                                ', r); r:=r+1;
    ad_ddl.build_statement('           created_by,                                                                   ', r); r:=r+1;
    ad_ddl.build_statement('           last_updated_by,                                                              ', r); r:=r+1;
    ad_ddl.build_statement('           last_update_date,                                                             ', r); r:=r+1;
    ad_ddl.build_statement('           last_update_login                                                             ', r); r:=r+1;
    ad_ddl.build_statement('    )                                                                                    ', r); r:=r+1;
    ad_ddl.build_statement('    SELECT p_entry_id,                                                                   ', r); r:=r+1;
    ad_ddl.build_statement('           min(geg.tgt_company_cost_center_org_id),                                      ', r); r:=r+1;
    build_insert_clause_list(p_rownum          => r,
                             p_prefix          => 'geg.tgt_');
    ad_ddl.build_statement('           min(geg.tgt_intercompany_id),                                                 ', r); r:=r+1;
    ad_ddl.build_statement('           sum(decode(sign(geg.output_amount), 1,                                        ', r); r:=r+1;
    ad_ddl.build_statement('                                               geg.output_amount, 0)),                   ', r); r:=r+1;
    ad_ddl.build_statement('           sum(decode(sign(geg.output_amount), -1,                                       ', r); r:=r+1;
    ad_ddl.build_statement('                                               -1 *geg.output_amount, 0)),               ', r); r:=r+1;
    ad_ddl.build_statement('           sum(geg.output_amount),                                                       ', r); r:=r+1;
    ad_ddl.build_statement('           sysdate,                                                                      ', r); r:=r+1;
    ad_ddl.build_statement('           fnd_global.user_id,                                                           ', r); r:=r+1;
    ad_ddl.build_statement('           fnd_global.user_id,                                                           ', r); r:=r+1;
    ad_ddl.build_statement('           sysdate,                                                                      ', r); r:=r+1;
    ad_ddl.build_statement('           fnd_global.login_id                                                           ', r); r:=r+1;
    ad_ddl.build_statement('    FROM   gcs_entries_gt geg                                                            ', r); r:=r+1;
    ad_ddl.build_statement('    GROUP BY geg.tgt_line_item_id                                                        ', r); r:=r+1;
    build_group_by_clause(r,'geg.tgt_', 'insertassignment');
    ad_ddl.build_statement('    ;                                                                                    ', r); r:=r+1;
    ad_ddl.build_statement('                                                                                         ', r); r:=r+1;
    ad_ddl.build_statement('    --check number of rows inserted                                                      ', r); r:=r+1;
    ad_ddl.build_statement('    p_row_count  := SQL%ROWCOUNT;                                                        ', r); r:=r+1;
    ad_ddl.build_statement('                                                                                         ', r); r:=r+1;
    ad_ddl.build_statement('    --insert rows if the offset flag was used                                            ', r); r:=r+1;
    ad_ddl.build_statement('    if (p_offset_flag = ''Y'') then                                                      ', r); r:=r+1;
    ad_ddl.build_statement('      insert into gcs_entry_lines                                                        ', r); r:=r+1;
    ad_ddl.build_statement('      (      entry_id,                                                                   ', r); r:=r+1;
    ad_ddl.build_statement('             company_cost_center_org_id,                                                 ', r); r:=r+1;
    build_insert_clause_list(p_rownum          => r,
                             p_prefix          => null);
    ad_ddl.build_statement('             intercompany_id,                                                            ', r); r:=r+1;
    ad_ddl.build_statement('             ytd_debit_balance_e,                                                        ', r); r:=r+1;
    ad_ddl.build_statement('             ytd_credit_balance_e,                                                       ', r); r:=r+1;
    ad_ddl.build_statement('             ytd_balance_e,                                                              ', r); r:=r+1;
    ad_ddl.build_statement('             creation_date,                                                              ', r); r:=r+1;
    ad_ddl.build_statement('             created_by,                                                                 ', r); r:=r+1;
    ad_ddl.build_statement('             last_updated_by,                                                            ', r); r:=r+1;
    ad_ddl.build_statement('             last_update_date,                                                           ', r); r:=r+1;
    ad_ddl.build_statement('             last_update_login                                                           ', r); r:=r+1;
    ad_ddl.build_statement('      )                                                                                  ', r); r:=r+1;
    ad_ddl.build_statement('      SELECT p_entry_id,                                                                 ', r); r:=r+1;
    ad_ddl.build_statement('             min(geg.tgt_company_cost_center_org_id),                                    ', r); r:=r+1;
    build_insert_clause_list(p_rownum          => r,
                             p_prefix          => 'geg.off_');
    ad_ddl.build_statement('             min(geg.tgt_intercompany_id),                                               ', r); r:=r+1;
    ad_ddl.build_statement('             sum(decode(sign(geg.output_amount), -1,                                     ', r); r:=r+1;
    ad_ddl.build_statement('                                                 -1 * geg.output_amount, 0)),            ', r); r:=r+1;
    ad_ddl.build_statement('             sum(decode(sign(geg.output_amount), 1,                                      ', r); r:=r+1;
    ad_ddl.build_statement('                                                 geg.output_amount, 0)),                 ', r); r:=r+1;
    ad_ddl.build_statement('             -1 * sum(geg.output_amount),                                                ', r); r:=r+1;
    ad_ddl.build_statement('             sysdate,                                                                    ', r); r:=r+1;
    ad_ddl.build_statement('             fnd_global.user_id,                                                         ', r); r:=r+1;
    ad_ddl.build_statement('             fnd_global.user_id,                                                         ', r); r:=r+1;
    ad_ddl.build_statement('             sysdate,                                                                    ', r); r:=r+1;
    ad_ddl.build_statement('             fnd_global.login_id                                                         ', r); r:=r+1;
    ad_ddl.build_statement('      FROM   gcs_entries_gt geg                                                          ', r); r:=r+1;
    ad_ddl.build_statement('      GROUP BY geg.off_line_item_id                                                      ', r); r:=r+1;
    build_group_by_clause(r,'geg.off_', 'insertassignment');
    ad_ddl.build_statement('      ;                                                                                  ', r); r:=r+1;
    ad_ddl.build_statement('    end if; --p_offset_flag = Y                                                          ', r); r:=r+1;
    ad_ddl.build_statement('    else                                                                                 ', r); r:=r+1;
    ad_ddl.build_statement('    insert into gcs_entry_lines                                                          ', r); r:=r+1;
    ad_ddl.build_statement('    (      entry_id,                                                                     ', r); r:=r+1;
    ad_ddl.build_statement('           company_cost_center_org_id,                                                   ', r); r:=r+1;
    build_insert_clause_list(p_rownum          => r,
                             p_prefix          => null);
    ad_ddl.build_statement('           intercompany_id,                                                              ', r); r:=r+1;
    ad_ddl.build_statement('           ytd_debit_balance_e,                                                          ', r); r:=r+1;
    ad_ddl.build_statement('           ytd_credit_balance_e,                                                         ', r); r:=r+1;
    ad_ddl.build_statement('           ytd_balance_e,                                                                ', r); r:=r+1;
    ad_ddl.build_statement('           creation_date,                                                                ', r); r:=r+1;
    ad_ddl.build_statement('           created_by,                                                                   ', r); r:=r+1;
    ad_ddl.build_statement('           last_updated_by,                                                              ', r); r:=r+1;
    ad_ddl.build_statement('           last_update_date,                                                             ', r); r:=r+1;
    ad_ddl.build_statement('           last_update_login                                                             ', r); r:=r+1;
    ad_ddl.build_statement('    )                                                                                    ', r); r:=r+1;
    ad_ddl.build_statement('    SELECT p_entry_id,                                                                   ', r); r:=r+1;
    ad_ddl.build_statement('           geg.src_company_cost_center_org_id,                                           ', r); r:=r+1;
    build_insert_clause_list(p_rownum          => r,
                             p_prefix          => 'geg.tgt_');
    ad_ddl.build_statement('           min(geg.tgt_intercompany_id),                                                 ', r); r:=r+1;
    ad_ddl.build_statement('           sum(decode(sign(geg.output_amount), 1,                                        ', r); r:=r+1;
    ad_ddl.build_statement('                                               geg.output_amount, 0)),                   ', r); r:=r+1;
    ad_ddl.build_statement('           sum(decode(sign(geg.output_amount), -1,                                       ', r); r:=r+1;
    ad_ddl.build_statement('                                               -1 *geg.output_amount, 0)),               ', r); r:=r+1;
    ad_ddl.build_statement('           sum(geg.output_amount),                                                       ', r); r:=r+1;
    ad_ddl.build_statement('           sysdate,                                                                      ', r); r:=r+1;
    ad_ddl.build_statement('           fnd_global.user_id,                                                           ', r); r:=r+1;
    ad_ddl.build_statement('           fnd_global.user_id,                                                           ', r); r:=r+1;
    ad_ddl.build_statement('           sysdate,                                                                      ', r); r:=r+1;
    ad_ddl.build_statement('           fnd_global.login_id                                                           ', r); r:=r+1;
    ad_ddl.build_statement('    FROM   gcs_entries_gt geg                                                            ', r); r:=r+1;
    ad_ddl.build_statement('    GROUP BY geg.src_company_cost_center_org_id, geg.tgt_line_item_id                    ', r); r:=r+1;
    build_group_by_clause(r,'geg.tgt_', 'insertassignment');
    ad_ddl.build_statement('    ;                                                                                    ', r); r:=r+1;
    ad_ddl.build_statement('                                                                                         ', r); r:=r+1;
    ad_ddl.build_statement('    --check number of rows inserted                                                      ', r); r:=r+1;
    ad_ddl.build_statement('    p_row_count  := SQL%ROWCOUNT;                                                        ', r); r:=r+1;
    ad_ddl.build_statement('                                                                                         ', r); r:=r+1;
    ad_ddl.build_statement('    --insert rows if the offset flag was used                                            ', r); r:=r+1;
    ad_ddl.build_statement('    if (p_offset_flag = ''Y'') then                                                      ', r); r:=r+1;
    ad_ddl.build_statement('      insert into gcs_entry_lines                                                        ', r); r:=r+1;
    ad_ddl.build_statement('      (      entry_id,                                                                   ', r); r:=r+1;
    ad_ddl.build_statement('             company_cost_center_org_id,                                                 ', r); r:=r+1;
    build_insert_clause_list(p_rownum          => r,
                             p_prefix          => null);
    ad_ddl.build_statement('             intercompany_id,                                                            ', r); r:=r+1;
    ad_ddl.build_statement('             ytd_debit_balance_e,                                                        ', r); r:=r+1;
    ad_ddl.build_statement('             ytd_credit_balance_e,                                                       ', r); r:=r+1;
    ad_ddl.build_statement('             ytd_balance_e,                                                              ', r); r:=r+1;
    ad_ddl.build_statement('             creation_date,                                                              ', r); r:=r+1;
    ad_ddl.build_statement('             created_by,                                                                 ', r); r:=r+1;
    ad_ddl.build_statement('             last_updated_by,                                                            ', r); r:=r+1;
    ad_ddl.build_statement('             last_update_date,                                                           ', r); r:=r+1;
    ad_ddl.build_statement('             last_update_login                                                           ', r); r:=r+1;
    ad_ddl.build_statement('      )                                                                                  ', r); r:=r+1;
    ad_ddl.build_statement('      SELECT p_entry_id,                                                                 ', r); r:=r+1;
    ad_ddl.build_statement('             geg.src_company_cost_center_org_id,                                         ', r); r:=r+1;
    build_insert_clause_list(p_rownum          => r,
                             p_prefix          => 'geg.off_');
    ad_ddl.build_statement('             min(geg.tgt_intercompany_id),                                               ', r); r:=r+1;
    ad_ddl.build_statement('             sum(decode(sign(geg.output_amount), -1,                                     ', r); r:=r+1;
    ad_ddl.build_statement('                                                 -1 * geg.output_amount, 0)),            ', r); r:=r+1;
    ad_ddl.build_statement('             sum(decode(sign(geg.output_amount), 1,                                      ', r); r:=r+1;
    ad_ddl.build_statement('                                                 geg.output_amount, 0)),                 ', r); r:=r+1;
    ad_ddl.build_statement('             -1 * sum(geg.output_amount),                                                ', r); r:=r+1;
    ad_ddl.build_statement('             sysdate,                                                                    ', r); r:=r+1;
    ad_ddl.build_statement('             fnd_global.user_id,                                                         ', r); r:=r+1;
    ad_ddl.build_statement('             fnd_global.user_id,                                                         ', r); r:=r+1;
    ad_ddl.build_statement('             sysdate,                                                                    ', r); r:=r+1;
    ad_ddl.build_statement('             fnd_global.login_id                                                         ', r); r:=r+1;
    ad_ddl.build_statement('      FROM   gcs_entries_gt geg                                                          ', r); r:=r+1;
    ad_ddl.build_statement('      GROUP BY geg.src_company_cost_center_org_id, geg.off_line_item_id                  ', r); r:=r+1;
    build_group_by_clause(r,'geg.off_', 'insertassignment');
    ad_ddl.build_statement('      ;                                                                                  ', r); r:=r+1;
    ad_ddl.build_statement('    end if; --p_offset_flag = Y                                                          ', r); r:=r+1;
    ad_ddl.build_statement('    end if;                                                                              ', r); r:=r+1;
    ad_ddl.build_statement('                                                                                         ', r); r:=r+1;
    ad_ddl.build_statement('    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then                 ', r); r:=r+1;
    ad_ddl.build_statement('      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, ''gcs_rp_utility_pkg.end'', null);         ', r); r:=r+1;
    ad_ddl.build_statement('    end if;                                                                              ', r); r:=r+1;
    ad_ddl.build_statement('                                                                                         ', r); r:=r+1;
    ad_ddl.build_statement('  end create_entry_lines;                                                                ', r); r:=r+1;
    ad_ddl.build_statement('END GCS_RP_UTILITY_PKG;', r);
    ad_ddl.create_plsql_object(GCS_DYNAMIC_UTIL_PKG.g_applsys_username,
                               'GCS', 'GCS_RP_UTILITY_PKG',
                               1, r , 'TRUE', comp_err);

  END create_rp_utility_pkg;

END GCS_RP_UTIL_BUILD_PKG;

/
