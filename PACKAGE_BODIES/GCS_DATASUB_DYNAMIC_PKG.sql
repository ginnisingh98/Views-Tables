--------------------------------------------------------
--  DDL for Package Body GCS_DATASUB_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DATASUB_DYNAMIC_PKG" as
  /* $Header: gcs_datasub_dynb.pls 120.6 2006/06/28 05:08:30 vkosuri noship $ */

    --Global Variables
      g_api	VARCHAR2(50)	:=	'gcs.plsql.GCS_DATASUB_DYNAMIC_PKG';
      g_nl	VARCHAR2(1)	:=	'''';
    --
    -- Procedure
    --   Write_To_Log
    -- Purpose
    --   Write the text given to the log in 3500 character increments
    --   this happened. Write it to the log repository.
    -- Arguments
    --   p_module         Name of the module
    --   p_level          Logging level
    --   p_text           Text to write
    -- Example
    --
    -- Notes
    --
    PROCEDURE write_to_log
      (p_module   VARCHAR2,
       p_level    NUMBER,
       p_text     VARCHAR2)
    IS
      api_module_concat   VARCHAR2(200);
      text_with_date      VARCHAR2(32767);
      text_with_date_len  NUMBER;
      curr_index          NUMBER;
    BEGIN
      -- Only print if the log level is set at the appropriate level
      IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= p_level THEN
        api_module_concat := g_api || '.' || p_module;
        text_with_date := to_char(sysdate,'DD-MON-YYYY HH:MI:SS')||g_nl||p_text;
        text_with_date_len := length(text_with_date);
        curr_index := 1;
        WHILE curr_index <= text_with_date_len LOOP
          fnd_log.string(p_level, api_module_concat,
                         substr(text_with_date, curr_index, 3500));
          curr_index := curr_index + 3500;
        END LOOP;
      END IF;
    END write_to_log;



    PROCEDURE add_clause_to_list  (p_dimension_required   	IN VARCHAR2,
                                   p_id_column_name           	IN VARCHAR2,
                                   p_disp_code_col_name          	IN VARCHAR2,
           p_table_alias			IN VARCHAR2,
                                   p_rownum               	IN OUT NOCOPY NUMBER) IS

    BEGIN
      IF (p_dimension_required = 'Y') THEN


        ad_ddl.build_statement('                    AND   fb.'||p_id_column_name||' 	  =       '||p_table_alias|| '.' || p_id_column_name, p_rownum); p_rownum:=p_rownum+1;
        ad_ddl.build_statement('		          AND	gbit.' || p_disp_code_col_name || ' = 	  ' || p_table_alias || '.' || p_disp_code_col_name, p_rownum); p_rownum:=p_rownum+1;
      END IF;
    END add_clause_to_list;

    PROCEDURE build_where_clause_list (p_rownum        IN OUT NOCOPY NUMBER)  IS

      l_dim_info 	gcs_utility_pkg.t_hash_gcs_dimension_info	:=
            gcs_utility_pkg.g_gcs_dimension_info;

    BEGIN
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'), 'FINANCIAL_ELEM_ID',
                        'FINANCIAL_ELEM_DISPLAY_CODE',
                        'ffeb',
                       p_rownum);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'), 'PRODUCT_ID',
                       'PRODUCT_DISPLAY_CODE',
                       'fpb',
                       p_rownum);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'), 'NATURAL_ACCOUNT_ID',
                         'NATURAL_ACCOUNT_DISPLAY_CODE',
                         'fnab', p_rownum);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'), 'CHANNEL_ID',
                       'CHANNEL_DISPLAY_CODE',
                       'fchb', p_rownum);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'), 'PROJECT_ID',
                       'PROJECT_DISPLAY_CODE',
                       'fpjb', p_rownum);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'), 'CUSTOMER_ID',
                        'CUSTOMER_DISPLAY_CODE',
                        'fcb', p_rownum);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'), 'TASK_ID',
                    'TASK_DISPLAY_CODE',
                    'ftb', p_rownum);
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'), l_dim_info('USER_DIM1_ID').dim_member_col,
                         l_dim_info('USER_DIM1_ID').dim_member_display_code,
                         'fud1', p_rownum);
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'), l_dim_info('USER_DIM2_ID').dim_member_col,
                         l_dim_info('USER_DIM2_ID').dim_member_display_code,
                         'fud2', p_rownum);
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'), l_dim_info('USER_DIM3_ID').dim_member_col,
                         l_dim_info('USER_DIM3_ID').dim_member_display_code,
                                                                                     'fud3', p_rownum);
      END IF;

      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'), l_dim_info('USER_DIM4_ID').dim_member_col,
                       l_dim_info('USER_DIM4_ID').dim_member_display_code,
                                                                                  'fud4', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'), l_dim_info('USER_DIM5_ID').dim_member_col,
                       l_dim_info('USER_DIM5_ID').dim_member_display_code,
                                                                                  'fud5', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'), l_dim_info('USER_DIM6_ID').dim_member_col,
                       l_dim_info('USER_DIM6_ID').dim_member_display_code,
                                                                                  'fud6', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'), l_dim_info('USER_DIM7_ID').dim_member_col,
                       l_dim_info('USER_DIM7_ID').dim_member_display_code,
                                                                                  'fud7', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'), l_dim_info('USER_DIM8_ID').dim_member_col,
                       l_dim_info('USER_DIM8_ID').dim_member_display_code,
                       'fud8', p_rownum);
       END IF;
       IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'), l_dim_info('USER_DIM9_ID').dim_member_col,
                       l_dim_info('USER_DIM9_ID').dim_member_display_code,
                                                                                  'fud9', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),l_dim_info('USER_DIM10_ID').dim_member_col,
                         l_dim_info('USER_DIM10_ID').dim_member_display_code,
                                                                                     'fud10', p_rownum);
      END IF;
    END build_where_clause_list;

    PROCEDURE add_table_to_list	(p_dimension_required	IN VARCHAR2,
           p_table_name		IN VARCHAR2,
           p_table_alias		IN VARCHAR2,
           p_rownum		IN OUT NOCOPY NUMBER) IS

    BEGIN
      IF (p_dimension_required = 'Y') THEN
        ad_ddl.build_statement('                           ,' || p_table_name || ' ' || p_table_alias , p_rownum); p_rownum:=p_rownum+1;
      END IF;
    END add_table_to_list;

    PROCEDURE build_table_list	       (p_rownum	IN OUT NOCOPY NUMBER)  IS

      l_dim_info  gcs_utility_pkg.t_hash_gcs_dimension_info       :=
                                          gcs_utility_pkg.g_gcs_dimension_info;

    BEGIN
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'), 'fem_fin_elems_b', 'ffeb', p_rownum);
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'), 'fem_products_b', 'fpb', p_rownum);
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'), 'fem_nat_accts_b', 'fnab', p_rownum);
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'), 'fem_channels_b', 'fchb', p_rownum);
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'), 'fem_projects_b', 'fpjb', p_rownum);
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'), 'fem_customers_b', 'fcb', p_rownum);
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'), 'fem_tasks_b', 'ftb', p_rownum);
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'), l_dim_info('USER_DIM1_ID').dim_b_table_name,
                      'fud1', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'), l_dim_info('USER_DIM2_ID').dim_b_table_name,
                      'fud2', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'), l_dim_info('USER_DIM3_ID').dim_b_table_name,
                      'fud3', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'), l_dim_info('USER_DIM4_ID').dim_b_table_name,
                      'fud4', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'), l_dim_info('USER_DIM5_ID').dim_b_table_name,
                      'fud5', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'), l_dim_info('USER_DIM6_ID').dim_b_table_name,
                      'fud6', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'), l_dim_info('USER_DIM7_ID').dim_b_table_name,
                      'fud7', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'), l_dim_info('USER_DIM8_ID').dim_b_table_name,
                      'fud8', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'), l_dim_info('USER_DIM9_ID').dim_b_table_name,
                      'fud9', p_rownum);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),l_dim_info('USER_DIM10_ID').dim_b_table_name,
                      'fud10', p_rownum);
      END IF;
    END;

    PROCEDURE create_datasub_utility_pkg (p_retcode	NUMBER,
            p_errbuf	VARCHAR2) IS

      r		NUMBER(15) 	:=	1;
      comp_err	VARCHAR2(200)	:=	NULL;

    BEGIN

      ad_ddl.build_statement('CREATE OR REPLACE PACKAGE BODY GCS_DATASUB_UTILITY_PKG AS', r); r := r+1;
      ad_ddl.build_statement(' ', r); r := r+1;
      ad_ddl.build_statement('--API Name', r); r := r+1;
      ad_ddl.build_statement('  g_api		VARCHAR2(50) :=	''gcs.plsql.GCS_DATASUB_UTILITY_PKG'';', r); r := r+1;
      ad_ddl.build_statement(' ', r); r := r+1;
      ad_ddl.build_statement('  -- Action types for writing module information to the log file. Used for', r); r:=r+1;
      ad_ddl.build_statement('  -- the procedure log_file_module_write.', r); r:=r+1;
      ad_ddl.build_statement('  g_module_enter    VARCHAR2(2) := ''>>'';', r); r:=r+1;
      ad_ddl.build_statement('  g_module_success  VARCHAR2(2) := ''<<'';', r); r:=r+1;
      ad_ddl.build_statement('  g_module_failure  VARCHAR2(2) := ''<x'';', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('-- Beginning of private procedures ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement(' PROCEDURE update_ytd_balances (p_load_id			IN	NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('				    p_source_system_code	IN	NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('				    p_dataset_code		IN	NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('				    p_cal_period_id		IN	NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('				    p_ledger_id			IN	NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('				    p_currency_type		IN	VARCHAR2, ' , r); r:=r+1;
      ad_ddl.build_statement('				    p_currency_code		IN	VARCHAR2) ' , r); r:=r+1;
      ad_ddl.build_statement(' IS PRAGMA AUTONOMOUS_TRANSACTION; ', r); r:=r+1;
      ad_ddl.build_statement(' BEGIN ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL	<=	FND_LOG.LEVEL_PROCEDURE) THEN ', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.UPDATE_YTD_BALANCES.begin'', ''<<Enter>>'' ); ', r); r:=r+1;
      ad_ddl.build_statement('   END IF; ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL	<=	FND_LOG.LEVEL_STATEMENT) THEN ', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_YTD_BALANCES'',
            ''Load Id : '' || p_load_id );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_YTD_BALANCES'',
            ''Source System : '' || p_source_system_code );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_YTD_BALANCES'',
            ''Dataset Code : '' || p_dataset_code );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_YTD_BALANCES'',
            ''Cal Period Id : '' || p_cal_period_id );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_YTD_BALANCES'',
            ''Ledger Id : '' || p_ledger_id );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_YTD_BALANCES'',
            ''Currency Type : '' || p_currency_type );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_YTD_BALANCES'',
            ''Currency Code : '' || p_currency_code );', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   END IF;', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('   SET    (ytd_debit_balance_e, ', r); r:=r+1;
      ad_ddl.build_statement(' 	       ytd_credit_balance_e, ', r); r:=r+1;
      ad_ddl.build_statement('	       ytd_balance_e, ', r); r:=r+1;
      ad_ddl.build_statement('	       ytd_balance_f) = (', r); r:=r+1;
      ad_ddl.build_statement('			SELECT fb.ytd_debit_balance_e  + NVL(gbit.ptd_debit_balance_e,0)  , ', r); r:=r+1;
      ad_ddl.build_statement('			       fb.ytd_credit_balance_e + NVL(gbit.ptd_credit_balance_e,0) , ', r); r:=r+1;
      ad_ddl.build_statement('			       fb.ytd_balance_e + NVL(gbit.ptd_debit_balance_e, 0) - ', r); r:=r+1;
      ad_ddl.build_statement('				 		  NVL(gbit.ptd_credit_balance_e, 0), ', r); r:=r+1;
      ad_ddl.build_statement('			       fb.ytd_balance_f + NVL(gbit.ptd_debit_balance_f, 0) - ', r); r:=r+1;
      ad_ddl.build_statement('						  NVL(gbit.ptd_credit_balance_f, 0) ', r); r:=r+1;
      ad_ddl.build_statement('			FROM   fem_balances fb ', r); r:=r+1;
      ad_ddl.build_statement('			      ,fem_cctr_orgs_b fcob ', r); r:=r+1;
      ad_ddl.build_statement('			      ,fem_ln_items_b  flib ', r); r:=r+1;
      ad_ddl.build_statement('			      ,fem_cctr_orgs_b fcib ', r); r:=r+1;
      -- Build the additional components of the from clause
      build_table_list(r);
      ad_ddl.build_statement('			WHERE fb.ledger_id			=	p_ledger_id ', r); r:=r+1;
      ad_ddl.build_statement('			AND   fb.cal_period_id			=	p_cal_period_id ', r); r:=r+1;
      ad_ddl.build_statement('			AND   fb.dataset_code			=	p_dataset_code ' , r); r:=r+1;
      ad_ddl.build_statement('			AND   fb.source_system_code		=	p_source_system_code ', r);  r:=r+1;
      ad_ddl.build_statement('			AND   fb.currency_type_code		=	p_currency_type	' , r); r:=r+1;
      ad_ddl.build_statement('			AND   fb.currency_code			=	DECODE(p_currency_code, NULL, ', r); r:=r+1;
      ad_ddl.build_statement('			    					        gbit.currency_code, ', r); r:=r+1;
      ad_ddl.build_statement('		     						        p_currency_code)', r); r:=r+1;
      ad_ddl.build_statement('			AND   fb.company_cost_center_org_id	=       fcob.company_cost_center_org_id', r); r:=r+1;

      ad_ddl.build_statement('			AND   fcob.cctr_org_display_code	=	gbit.cctr_org_display_code', r); r:=r+1;
      ad_ddl.build_statement('			AND   fb.line_item_id			=	flib.line_item_id', r); r:=r+1;
      ad_ddl.build_statement('			AND   flib.line_item_display_code	=  	gbit.line_item_display_code', r);  r:=r+1;
      ad_ddl.build_statement('			AND   fb.intercompany_id		=	fcib.company_cost_center_org_id', r); r:=r+1;
      ad_ddl.build_statement('			AND   fcib.cctr_org_display_code	=	gbit.intercompany_display_code', r); r:=r+1;
      -- Build the additiona components of the where clause
      build_where_clause_list(r);
      ad_ddl.build_statement('			)', r); r:=r+1;
      ad_ddl.build_statement('   WHERE  load_id	=	p_load_id;', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN ', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.UPDATE_YTD_BALANCES.end'', ''<<Exit>>''); ', r); r:=r+1;
      ad_ddl.build_statement('   END IF; ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   COMMIT;', r); r:=r+1;
      ad_ddl.build_statement('   END    update_ytd_balances;', r); r:=r+1;
      ad_ddl.build_statement(' --	', r); r:=r+1;
      ad_ddl.build_statement(' -- ', r); r:=r+1;
      ad_ddl.build_statement(' PROCEDURE update_ptd_balances (p_load_id			IN	NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('				    p_source_system_code	IN	NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('				    p_dataset_code		IN	NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('				    p_cal_period_id		IN	NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('				    p_ledger_id			IN	NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('				    p_currency_type		IN	VARCHAR2, ' , r); r:=r+1;
      ad_ddl.build_statement('				    p_currency_code		IN	VARCHAR2) ' , r); r:=r+1;
      ad_ddl.build_statement(' IS PRAGMA AUTONOMOUS_TRANSACTION; ', r); r:=r+1;
      ad_ddl.build_statement(' BEGIN ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN ', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.UPDATE_PTD_BALANCES.begin'',
            ''<<Enter>>'' ); ', r); r:=r+1;
      ad_ddl.build_statement('   END IF; ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_STATEMENT) THEN ', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCES'',
                                          ''Load Id : '' || p_load_id );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCES'',
                                          ''Source System : '' || p_source_system_code );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCES'',
                                          ''Dataset Code : '' || p_dataset_code );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCES'',
                                          ''Cal Period Id : '' || p_cal_period_id );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCES'',
                                          ''Ledger Id : '' || p_ledger_id );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCES'',
                                          ''Currency Type : '' || p_currency_type );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCES'',
                                          ''Currency Code : '' || p_currency_code );', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   END IF;', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('   SET    (ptd_debit_balance_e, ', r); r:=r+1;
      ad_ddl.build_statement(' 	       ptd_credit_balance_e, ', r); r:=r+1;
      ad_ddl.build_statement('	       ptd_balance_e, ', r); r:=r+1;
      ad_ddl.build_statement('	       ptd_balance_f) = (', r); r:=r+1;
      ad_ddl.build_statement('			SELECT gbit.ytd_debit_balance_e  - NVL(fb.ytd_debit_balance_e,0) , ', r); r:=r+1;
      ad_ddl.build_statement('			       gbit.ytd_credit_balance_e - NVL(fb.ytd_credit_balance_e,0) , ', r); r:=r+1;
      ad_ddl.build_statement('			       gbit.ytd_balance_e - NVL(fb.ytd_balance_e, 0), ', r); r:=r+1;
      ad_ddl.build_statement('			       gbit.ytd_balance_f - NVL(fb.ytd_balance_f, 0) ', r); r:=r+1;
      ad_ddl.build_statement('			FROM   fem_balances fb ', r); r:=r+1;
      ad_ddl.build_statement('			      ,fem_cctr_orgs_b fcob ', r); r:=r+1;
      ad_ddl.build_statement('			      ,fem_ln_items_b  flib ', r); r:=r+1;
      ad_ddl.build_statement('			      ,fem_cctr_orgs_b fcib ', r); r:=r+1;
      -- Build the additional components of the from clause
      build_table_list(r);
      ad_ddl.build_statement('			WHERE fb.ledger_id			=	p_ledger_id ', r); r:=r+1;
      ad_ddl.build_statement('			AND   fb.cal_period_id			=	p_cal_period_id ', r); r:=r+1;
      ad_ddl.build_statement('			AND   fb.dataset_code			=	p_dataset_code ' , r); r:=r+1;
      ad_ddl.build_statement('			AND   fb.source_system_code		=	p_source_system_code ', r);  r:=r+1;
      ad_ddl.build_statement('			AND   fb.currency_type_code		=	p_currency_type	' , r); r:=r+1;
      ad_ddl.build_statement('			AND   fb.currency_code			=	DECODE(p_currency_code, NULL, ', r); r:=r+1;
      ad_ddl.build_statement('			    					        gbit.currency_code, ', r); r:=r+1;
      ad_ddl.build_statement('		     						        p_currency_code)', r); r:=r+1;
      ad_ddl.build_statement('			AND   fb.company_cost_center_org_id	=       fcob.company_cost_center_org_id', r); r:=r+1;

      ad_ddl.build_statement('			AND   fcob.cctr_org_display_code	=	gbit.cctr_org_display_code', r); r:=r+1;
      ad_ddl.build_statement('			AND   fb.line_item_id			=	flib.line_item_id', r); r:=r+1;
      ad_ddl.build_statement('			AND   flib.line_item_display_code	=  	gbit.line_item_display_code', r);  r:=r+1;
      ad_ddl.build_statement('			AND   fb.intercompany_id		=	fcib.company_cost_center_org_id', r); r:=r+1;
      ad_ddl.build_statement('			AND   fcib.cctr_org_display_code	=	gbit.intercompany_display_code', r); r:=r+1;
      -- Build the additiona components of the where clause
      build_where_clause_list(r);
      ad_ddl.build_statement('			)', r); r:=r+1;
      ad_ddl.build_statement('   WHERE  gbit.load_id	=	p_load_id;', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.UPDATE_PTD_BALANCES.end'', ''<<Exit>>''); ', r); r:=r+1;
      ad_ddl.build_statement('   END IF; ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   COMMIT; ' , r); r:=r+1;
      ad_ddl.build_statement('   END    update_ptd_balances;', r); r:=r+1;
      ad_ddl.build_statement(' -- ', r); r:=r+1;
      ad_ddl.build_statement(' PROCEDURE update_ptd_balance_sheet (	p_load_id                   IN      NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('                                		p_source_system_code        IN      NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('                                		p_dataset_code              IN      NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('                                		p_cal_period_id             IN      NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('                                		p_ledger_id                 IN      NUMBER, ' , r); r:=r+1;
      ad_ddl.build_statement('                                		p_currency_type             IN      VARCHAR2, ' , r); r:=r+1;
      ad_ddl.build_statement('                                		p_currency_code             IN      VARCHAR2) ' , r); r:=r+1;
      ad_ddl.build_statement(' IS PRAGMA AUTONOMOUS_TRANSACTION; ', r); r:=r+1;
      ad_ddl.build_statement('   	l_line_item_vs_id		NUMBER;	', r); r:=r+1;
      ad_ddl.build_statement('	l_ledger_vs_combo_attr		NUMBER(15)	:= ', r); r:=r+1;
      ad_ddl.build_statement('		gcs_utility_pkg.g_dimension_attr_info(''LEDGER_ID-GLOBAL_VS_COMBO'').attribute_id;', r); r:=r+1;
      ad_ddl.build_statement('	l_ledger_vs_combo_version	NUMBER(15)	:= ', r); r:=r+1;
      ad_ddl.build_statement('		gcs_utility_pkg.g_dimension_attr_info(''LEDGER_ID-GLOBAL_VS_COMBO'').version_id;', r); r:=r+1;
      ad_ddl.build_statement('	l_line_item_type_attr		NUMBER(15)	:= ', r); r:=r+1;
      ad_ddl.build_statement('	        gcs_utility_pkg.g_dimension_attr_info(''LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE'').attribute_id;', r); r:=r+1;
      ad_ddl.build_statement('	l_line_item_type_version	NUMBER(15)	:= ', r); r:=r+1;
      ad_ddl.build_statement('		gcs_utility_pkg.g_dimension_attr_info(''LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE'').version_id;', r); r:=r+1;
      ad_ddl.build_statement('    l_acct_type_attr           	NUMBER(15)      := ', r); r:=r+1;
      ad_ddl.build_statement('            gcs_utility_pkg.g_dimension_attr_info(''EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE'').attribute_id;', r); r:=r+1;
      ad_ddl.build_statement('    l_acct_type_version        	NUMBER(15)      := ', r); r:=r+1;
      ad_ddl.build_statement('            gcs_utility_pkg.g_dimension_attr_info(''EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE'').version_id;', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement(' BEGIN ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN ', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.UPDATE_PTD_BALANCE_SHEET.begin'',
                                          ''<<Enter>>'' ); ', r); r:=r+1;
      ad_ddl.build_statement('   END IF; ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   SELECT      fgvcd.value_set_id ', r); r:=r+1;
      ad_ddl.build_statement('   INTO        l_line_item_vs_id ', r); r:=r+1;
      ad_ddl.build_statement('   FROM        fem_ledgers_attr                fla, ', r); r:=r+1;
      ad_ddl.build_statement('               fem_global_vs_combo_defs        fgvcd ', r); r:=r+1;
      ad_ddl.build_statement('   WHERE	   fla.ledger_id			=	p_ledger_id ', r); r:=r+1;
      ad_ddl.build_statement('   AND	   fgvcd.global_vs_combo_id		=	fla.dim_attribute_numeric_member ', r); r:=r+1;
      ad_ddl.build_statement('   AND	   fla.attribute_id			= 	l_ledger_vs_combo_attr ', r); r:=r+1;
      ad_ddl.build_statement('   AND	   fla.version_id			=	l_ledger_vs_combo_version ', r); r:=r+1;
      ad_ddl.build_statement('   AND	   fgvcd.dimension_id			=	14; ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_STATEMENT) THEN ', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCE_SHEET'',
                                          ''Load Id : '' || p_load_id );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCE_SHEET'',
                                          ''Source System : '' || p_source_system_code );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCE_SHEET'',
                                          ''Dataset Code : '' || p_dataset_code );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCE_SHEET'',
                                          ''Cal Period Id : '' || p_cal_period_id );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCE_SHEET'',
                                          ''Ledger Id : '' || p_ledger_id );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCE_SHEET'',
                                          ''Currency Type : '' || p_currency_type );', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.UPDATE_PTD_BALANCE_SHEET'',
                                          ''Currency Code : '' || p_currency_code );', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   END IF;', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('   SET    (ptd_debit_balance_e, ', r); r:=r+1;
      ad_ddl.build_statement('           ptd_credit_balance_e, ', r); r:=r+1;
      ad_ddl.build_statement('           ptd_balance_e, ', r); r:=r+1;
      ad_ddl.build_statement('           ptd_balance_f) = (', r); r:=r+1;
      ad_ddl.build_statement('                    SELECT gbit.ytd_debit_balance_e  - NVL(fb.ytd_debit_balance_e,0) , ', r); r:=r+1;
      ad_ddl.build_statement('                           gbit.ytd_credit_balance_e - NVL(fb.ytd_credit_balance_e,0) , ', r); r:=r+1;
      ad_ddl.build_statement('                           gbit.ytd_balance_e - NVL(fb.ytd_balance_e, 0), ', r); r:=r+1;
      ad_ddl.build_statement('                           gbit.ytd_balance_f - NVL(fb.ytd_balance_f, 0) ', r); r:=r+1;
      ad_ddl.build_statement('                    FROM   fem_balances fb ', r); r:=r+1;
      ad_ddl.build_statement('                          ,fem_cctr_orgs_b fcob ', r); r:=r+1;
      ad_ddl.build_statement('                          ,fem_ln_items_b  flib ', r); r:=r+1;
      ad_ddl.build_statement('                          ,fem_cctr_orgs_b fcib ', r); r:=r+1;
      -- Build the additional components of the from clause
      build_table_list(r);
      ad_ddl.build_statement('                    WHERE fb.ledger_id                      =       p_ledger_id ', r); r:=r+1;
      ad_ddl.build_statement('                    AND   fb.cal_period_id                  =       p_cal_period_id ', r); r:=r+1;
      ad_ddl.build_statement('                    AND   fb.dataset_code                   =       p_dataset_code ' , r); r:=r+1;
      ad_ddl.build_statement('                    AND   fb.source_system_code             =       p_source_system_code ', r);  r:=r+1;
      ad_ddl.build_statement('                    AND   fb.currency_type_code             =       p_currency_type ' , r); r:=r+1;
      ad_ddl.build_statement('                    AND   fb.currency_code                  =       DECODE(p_currency_code, NULL, ', r); r:=r+1;
      ad_ddl.build_statement('                                                                    gbit.currency_code, ', r); r:=r+1;
      ad_ddl.build_statement('                                                                    p_currency_code)', r); r:=r+1;
      ad_ddl.build_statement('                    AND   fb.company_cost_center_org_id     =       fcob.company_cost_center_org_id', r); r:=r+1;
      ad_ddl.build_statement('                    AND   fcob.cctr_org_display_code        =       gbit.cctr_org_display_code', r); r:=r+1;
      ad_ddl.build_statement('                    AND   fb.line_item_id                   =       flib.line_item_id', r); r:=r+1;
      ad_ddl.build_statement('                    AND   flib.line_item_display_code       =       gbit.line_item_display_code', r);  r:=r+1;
      ad_ddl.build_statement('                    AND   fb.intercompany_id                =       fcib.company_cost_center_org_id', r); r:=r+1;
      ad_ddl.build_statement('                    AND   fcib.cctr_org_display_code        =       gbit.intercompany_display_code', r); r:=r+1;
      -- Build the additiona components of the where clause
      build_where_clause_list(r);
      ad_ddl.build_statement('                    )', r); r:=r+1;
      ad_ddl.build_statement('   WHERE  gbit.load_id      =       p_load_id					', r); r:=r+1;
      ad_ddl.build_statement('   AND    EXISTS	(SELECT ''X''							', r); r:=r+1;
      ad_ddl.build_statement('   			 FROM	fem_ln_items_b 			flib,			', r); r:=r+1;
      ad_ddl.build_statement('			        fem_ln_items_attr 		flia,			', r); r:=r+1;
      ad_ddl.build_statement('				fem_ext_acct_types_attr      	fea_attr		', r); r:=r+1;
      ad_ddl.build_statement('			 WHERE  gbit.line_item_display_code = flib.line_item_display_code ', r); r:=r+1;
      ad_ddl.build_statement('			 AND    flib.line_item_id	    = flia.line_item_id		', r); r:=r+1;
      ad_ddl.build_statement('			 AND	flib.value_set_id	    = l_line_item_vs_id		', r); r:=r+1;
      ad_ddl.build_statement('			 AND	flib.value_set_id	    = flia.value_set_id		', r); r:=r+1;
      ad_ddl.build_statement('			 AND	flia.attribute_id	    = l_line_item_type_attr	', r); r:=r+1;
      ad_ddl.build_statement('			 AND	flia.version_id		    = l_line_item_type_version	', r); r:=r+1;
      ad_ddl.build_statement('			 AND	flia.dim_attribute_varchar_member = fea_attr.ext_account_type_code ', r); r:=r+1;
      ad_ddl.build_statement('			 AND    fea_attr.attribute_id	    = l_acct_type_attr		', r); r:=r+1;
      ad_ddl.build_statement('			 AND    fea_attr.version_id 	    = l_acct_type_version	', r); r:=r+1;
      ad_ddl.build_statement('			 AND	fea_attr.dim_attribute_varchar_member IN (''EQUITY'',   ', r); r:=r+1;
      ad_ddl.build_statement('			  						  ''ASSET'',    ', r); r:=r+1;
      ad_ddl.build_statement('									  ''LIABILITY''', r); r:=r+1;
      ad_ddl.build_statement('									 )		', r); r:=r+1;
      ad_ddl.build_statement('			);								', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.UPDATE_PTD_BALANCE_SHEET.end'', ''<<Exit>>''); ', r); r:=r+1;
      ad_ddl.build_statement('   END IF; ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   COMMIT; ' , r); r:=r+1;
      ad_ddl.build_statement('   END    update_ptd_balance_sheet;', r); r:=r+1;
      ad_ddl.build_statement(' -- ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      -- Bug Fix : 5234796, Start
      ad_ddl.build_statement(' PROCEDURE validate_dimension_members(p_load_id			IN	NUMBER ) ' , r); r:=r+1;
      ad_ddl.build_statement('  IS PRAGMA AUTONOMOUS_TRANSACTION; ', r); r:=r+1;
      ad_ddl.build_statement('   TYPE dim_vs_info_rec_type IS RECORD( ', r); r:=r+1;
      ad_ddl.build_statement('      vs_id   NUMBER , ', r); r:=r+1;
      ad_ddl.build_statement('      dim_display_code  VARCHAR2(50),', r); r:=r+1;
      ad_ddl.build_statement('      dim_id_col VARCHAR2(50) , ', r); r:=r+1;
      ad_ddl.build_statement('      dim_name  VARCHAR2(50) ); ', r); r:=r+1;
      ad_ddl.build_statement('   TYPE t_dim_vs_info IS TABLE OF dim_vs_info_rec_type; ', r); r:=r+1;
      ad_ddl.build_statement('   l_dim_vs_info       t_dim_vs_info; ', r); r:=r+1;
      ad_ddl.build_statement('   l_ledger_id         NUMBER(10); ', r); r:=r+1;
      ad_ddl.build_statement('   l_dim_id_col        VARCHAR2(50); ', r); r:=r+1;
      -- Bugfix 5358633, Start
      ad_ddl.build_statement('   l_invalid_err_msg   VARCHAR2(2000); ', r); r:=r+1;
      ad_ddl.build_statement('   l_null_err_msg      VARCHAR2(2000); ', r); r:=r+1;
      -- Bugfix 5358633, End
      ad_ddl.build_statement('  BEGIN ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN ', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.VALIDATE_DIMENSION_MEMBERS.begin'',
                                          ''<<Enter>>'' ); ', r); r:=r+1;
      ad_ddl.build_statement('     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.VALIDATE_DIMENSION_MEMBERS'',
                                          ''Load Id : '' || p_load_id );', r); r:=r+1;
      ad_ddl.build_statement('   END IF;', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      -- Bugfix 5358633, Start
      ad_ddl.build_statement('   UPDATE ', r); r:=r+1;
      ad_ddl.build_statement('   gcs_bal_interface_t ', r); r:=r+1;
      ad_ddl.build_statement('   SET error_message_code = NULL ', r); r:=r+1;
      ad_ddl.build_statement('   WHERE load_id = p_load_id; ', r); r:=r+1;
      -- Bugfix 5358633, End
      ad_ddl.build_statement('', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   SELECT fea.dim_attribute_numeric_member ', r); r:=r+1;
      ad_ddl.build_statement('   INTO   l_ledger_id ', r); r:=r+1;
      ad_ddl.build_statement('   FROM   fem_entities_attr fea, ', r); r:=r+1;
      ad_ddl.build_statement('          gcs_data_sub_dtls gdsd ', r); r:=r+1;
      ad_ddl.build_statement('   WHERE  gdsd.load_id     = p_load_id ', r); r:=r+1;
      ad_ddl.build_statement('   AND    fea.entity_id    = gdsd.entity_id   ', r); r:=r+1;
      ad_ddl.build_statement('   AND    fea.attribute_id = gcs_utility_pkg.g_dimension_attr_info(''ENTITY_ID-LEDGER_ID'').attribute_id   ', r); r:=r+1;
      ad_ddl.build_statement('   AND    fea.version_id   = gcs_utility_pkg.g_dimension_attr_info(''ENTITY_ID-LEDGER_ID'').version_id; ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
       ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   SELECT fgvcd.value_set_id, ', r); r:=r+1;
      ad_ddl.build_statement('       fxd.member_display_code_col, ', r); r:=r+1;
      ad_ddl.build_statement('       fxd.member_col, ', r); r:=r+1;
      ad_ddl.build_statement('       fdt.dimension_name ', r); r:=r+1;
      ad_ddl.build_statement('   BULK COLLECT ', r); r:=r+1;
      ad_ddl.build_statement('   INTO  l_dim_vs_info ', r); r:=r+1;
      ad_ddl.build_statement('   FROM  fem_global_vs_combo_defs fgvcd,  ', r); r:=r+1;
      ad_ddl.build_statement('         fem_ledgers_attr fla,    ', r); r:=r+1;
      ad_ddl.build_statement('         fem_xdim_dimensions fxd, ', r); r:=r+1;
      ad_ddl.build_statement('         fem_dimensions_tl  fdt ', r); r:=r+1;
      ad_ddl.build_statement('   WHERE gcs_utility_pkg.get_fem_dim_required(fxd.MEMBER_COL) = ''Y'' ', r); r:=r+1;
      ad_ddl.build_statement('     AND global_vs_combo_id  = fla.dim_attribute_numeric_member   ', r); r:=r+1;
      ad_ddl.build_statement('     AND fla.ledger_id       = l_ledger_id  ', r); r:=r+1;
      ad_ddl.build_statement('     AND fla.attribute_id    = gcs_utility_pkg.g_dimension_attr_info(''LEDGER_ID-GLOBAL_VS_COMBO'').attribute_id ', r); r:=r+1;
      ad_ddl.build_statement('     AND fla.version_id      = gcs_utility_pkg.g_dimension_attr_info(''LEDGER_ID-GLOBAL_VS_COMBO'').version_id ', r); r:=r+1;
      ad_ddl.build_statement('     AND fgvcd.dimension_id  = fxd.dimension_id   ', r); r:=r+1;
      ad_ddl.build_statement('     AND fxd.member_col IN (''COMPANY_COST_CENTER_ORG_ID'',''FINANCIAL_ELEM_ID'',''PRODUCT_ID'',''NATURAL_ACCOUNT_ID'',''CHANNEL_ID'', ', r); r:=r+1;
      ad_ddl.build_statement('                           ''LINE_ITEM_ID'',''PROJECT_ID'',''CUSTOMER_ID'',''TASK_ID'',''USER_DIM1_ID'',''USER_DIM10_ID'', ', r); r:=r+1;
      ad_ddl.build_statement('                           ''USER_DIM2_ID'',''USER_DIM3_ID'', ''USER_DIM4_ID'',''USER_DIM5_ID'', ', r); r:=r+1;
      ad_ddl.build_statement('                           ''USER_DIM6_ID'',''USER_DIM7_ID'',''USER_DIM8_ID'',''USER_DIM9_ID'') ', r); r:=r+1;
      ad_ddl.build_statement('     AND fdt.dimension_id    = fxd.dimension_id ', r); r:=r+1;
      ad_ddl.build_statement('     AND fdt.language        = userenv(''LANG''); ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
       ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   IF l_dim_vs_info.FIRST IS NOT NULL THEN ', r); r:=r+1;
      ad_ddl.build_statement('     FOR l_counter IN l_dim_vs_info.FIRST..l_dim_vs_info.LAST  LOOP ', r); r:=r+1;
      ad_ddl.build_statement('       FND_MESSAGE.set_name( ''GCS'', ''GCS_DS_DIM_INVALID_MSG'' ); ', r); r:=r+1;
      ad_ddl.build_statement('       FND_MESSAGE.set_token(''DIM_NAME'', l_dim_vs_info(l_counter).dim_name) ; ', r); r:=r+1;
      -- Bugfix 5358633, Start
      ad_ddl.build_statement('       l_invalid_err_msg := FND_MESSAGE.get ;', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('       FND_MESSAGE.set_name( ''GCS'', ''GCS_DS_DIM_NULL_MSG'' ); ', r); r:=r+1;
      ad_ddl.build_statement('       FND_MESSAGE.set_token(''COLUMN_NAME'', l_dim_vs_info(l_counter).dim_display_code) ; ', r); r:=r+1;
      ad_ddl.build_statement('       l_null_err_msg := FND_MESSAGE.get ; ', r); r:=r+1;
      -- Bugfix 5358633, End , Added messages(Null and Invalid cases) in all the below queries
      ad_ddl.build_statement('       l_dim_id_col := l_dim_vs_info(l_counter).dim_id_col ; ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('       IF ( l_dim_id_col = ''COMPANY_COST_CENTER_ORG_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('          UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('          SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                || DECODE (  cctr_org_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                l_invalid_err_msg  || ''('' || cctr_org_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE  load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND    NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                              FROM   fem_cctr_orgs_b fcob   ', r); r:=r+1;
      ad_ddl.build_statement('                              WHERE  fcob.cctr_org_display_code =  gbit.cctr_org_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                              AND    fcob.value_set_id = l_dim_vs_info(l_counter).vs_id ) ;   ', r); r:=r+1;
      ad_ddl.build_statement('       ELSIF ( l_dim_id_col = ''FINANCIAL_ELEM_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('          UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('          SET    error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  financial_elem_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || financial_elem_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('          WHERE  load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('          AND    NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                             FROM   fem_fin_elems_b ffeb  ', r); r:=r+1;
      ad_ddl.build_statement('                             WHERE  ffeb.financial_elem_display_code =  gbit.financial_elem_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                             AND    ffeb.value_set_id =  l_dim_vs_info(l_counter).vs_id ) ; ', r); r:=r+1;
      ad_ddl.build_statement('       ELSIF ( l_dim_id_col = ''LINE_ITEM_ID''  ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  line_item_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || line_item_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND   NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                             FROM   fem_ln_items_b flib  ', r); r:=r+1;
      ad_ddl.build_statement('                             WHERE  flib.line_item_display_code =  gbit.line_item_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                             AND    flib.value_set_id =  l_dim_vs_info(l_counter).vs_id ) ;  ', r); r:=r+1;
      ad_ddl.build_statement('       ELSIF (  l_dim_id_col = ''PRODUCT_ID'') THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  product_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || product_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND   NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                              FROM   fem_products_b fpb  ', r); r:=r+1;
      ad_ddl.build_statement('                              WHERE  fpb.product_display_code =  gbit.product_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                              AND    fpb.value_set_id = l_dim_vs_info(l_counter).vs_id ) ; ', r); r:=r+1;
      ad_ddl.build_statement('      ELSIF (  l_dim_id_col = ''NATURAL_ACCOUNT_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  natural_account_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || natural_account_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND   NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                             FROM   fem_nat_accts_b fnab  ', r); r:=r+1;
      ad_ddl.build_statement('                             WHERE  fnab.natural_account_display_code =  gbit.natural_account_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                             AND    fnab.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('       ELSIF (  l_dim_id_col = ''CHANNEL_ID'') THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  channel_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || channel_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND   NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                             FROM   fem_channels_b fcb  ', r); r:=r+1;
      ad_ddl.build_statement('                             WHERE  fcb.channel_display_code =  gbit.channel_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                             AND    fcb.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('       ELSIF ( l_dim_id_col = ''PROJECT_ID'') THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  project_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || project_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND   NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                             FROM   fem_projects_b fpb  ', r); r:=r+1;
      ad_ddl.build_statement('                             WHERE  fpb.project_display_code =  gbit.project_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                             AND    fpb.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('       ELSIF ( l_dim_id_col = ''CUSTOMER_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  customer_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || customer_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND   NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                             FROM   fem_customers_b fcb  ', r); r:=r+1;
      ad_ddl.build_statement('                             WHERE  fcb.customer_display_code =  gbit.customer_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                             AND    fcb.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('      ELSIF ( l_dim_id_col = ''TASK_ID'') THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  task_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || task_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND   NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                             FROM   fem_tasks_b ftb  ', r); r:=r+1;
      ad_ddl.build_statement('                             WHERE  ftb.task_display_code =  gbit.task_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                             AND    ftb.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('      ELSIF ( l_dim_id_col =  ''USER_DIM1_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  user_dim1_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || user_dim1_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND   NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                             FROM   fem_user_dim1_b fub  ', r); r:=r+1;
      ad_ddl.build_statement('                             WHERE  fub.user_dim1_display_code =  gbit.user_dim1_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                             AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('      ELSIF ( l_dim_id_col =  ''USER_DIM2_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  user_dim2_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || user_dim2_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND   NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                             FROM   fem_user_dim2_b fub  ', r); r:=r+1;
      ad_ddl.build_statement('                             WHERE  fub.user_dim2_display_code =  gbit.user_dim2_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                             AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('      ELSIF ( l_dim_id_col =  ''USER_DIM3_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  user_dim3_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || user_dim3_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND   NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                             FROM   fem_user_dim3_b fub  ', r); r:=r+1;
      ad_ddl.build_statement('                             WHERE  fub.user_dim3_display_code =  gbit.user_dim3_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                             AND    fub.value_set_id =l_dim_vs_info(l_counter).vs_id ) ; ', r); r:=r+1;
      ad_ddl.build_statement('       ELSIF ( l_dim_id_col =  ''USER_DIM4_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  user_dim4_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || user_dim4_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND   NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                             FROM   fem_user_dim4_b fub  ', r); r:=r+1;
      ad_ddl.build_statement('                             WHERE  fub.user_dim4_display_code =  gbit.user_dim4_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                             AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('       ELSIF ( l_dim_id_col =  ''USER_DIM5_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET   error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                 || DECODE (  user_dim5_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                 l_invalid_err_msg  || ''('' || user_dim5_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND   NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                                 FROM   fem_user_dim5_b fub  ', r); r:=r+1;
      ad_ddl.build_statement('                                 WHERE  fub.user_dim5_display_code =  gbit.user_dim5_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                                 AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('       ELSIF ( l_dim_id_col =  ''USER_DIM6_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET    error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                  || DECODE (  user_dim6_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                  l_invalid_err_msg  || ''('' || user_dim6_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE  load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND    NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                              FROM   fem_user_dim6_b fub  ', r); r:=r+1;
      ad_ddl.build_statement('                              WHERE  fub.user_dim6_display_code =  gbit.user_dim6_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                              AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('      ELSIF ( l_dim_id_col =  ''USER_DIM7_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET    error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                  || DECODE (  user_dim7_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                  l_invalid_err_msg  || ''('' || user_dim7_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE  load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND    NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                              FROM   fem_user_dim7_b fub  ', r); r:=r+1;
      ad_ddl.build_statement('                              WHERE  fub.user_dim7_display_code =  gbit.user_dim7_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                              AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id ) ; ', r); r:=r+1;
      ad_ddl.build_statement('       ELSIF ( l_dim_id_col =  ''USER_DIM8_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET    error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                  || DECODE (  user_dim8_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                  l_invalid_err_msg  || ''('' || user_dim8_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE  load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND    NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                              FROM   fem_user_dim8_b fub  ', r); r:=r+1;
      ad_ddl.build_statement('                              WHERE  fub.user_dim8_display_code =  gbit.user_dim8_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                              AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('       ELSIF ( l_dim_id_col =  ''USER_DIM9_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET    error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                  || DECODE (  user_dim9_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                  l_invalid_err_msg  || ''('' || user_dim9_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE  load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND    NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                              FROM   fem_user_dim9_b fub  ', r); r:=r+1;
      ad_ddl.build_statement('                              WHERE  fub.user_dim9_display_code =  gbit.user_dim9_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                              AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('       ELSIF ( l_dim_id_col =  ''USER_DIM10_ID'' ) THEN ', r); r:=r+1;
      ad_ddl.build_statement('           UPDATE gcs_bal_interface_t gbit ', r); r:=r+1;
      ad_ddl.build_statement('           SET    error_message_code = error_message_code ', r); r:=r+1;
      ad_ddl.build_statement('                  || DECODE (  user_dim10_display_code, NULL , l_null_err_msg , ', r); r:=r+1;
      ad_ddl.build_statement('                  l_invalid_err_msg  || ''('' || user_dim10_display_code || '').'' )', r); r:=r+1;
      ad_ddl.build_statement('           WHERE  load_id             = p_load_id  ', r); r:=r+1;
      ad_ddl.build_statement('           AND    NOT EXISTS (SELECT ''X''  ', r); r:=r+1;
      ad_ddl.build_statement('                              FROM   fem_user_dim10_b fub  ', r); r:=r+1;
      ad_ddl.build_statement('                              WHERE  fub.user_dim10_display_code =  gbit.user_dim10_display_code  ', r); r:=r+1;
      ad_ddl.build_statement('                              AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; ', r); r:=r+1;
      ad_ddl.build_statement('       END IF;  ', r); r:=r+1;
      ad_ddl.build_statement('     END LOOP; ', r); r:=r+1;
      ad_ddl.build_statement('   END IF;  ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   COMMIT; ' , r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN', r); r:=r+1;
      ad_ddl.build_statement('      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.VALIDATE_DIMENSION_MEMBERS.end'', ''<<Exit>>''); ', r); r:=r+1;
      ad_ddl.build_statement('   END IF; ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement(' END validate_dimension_members; ', r); r:=r+1;
      -- Bug Fix : 5234796, End
      ad_ddl.build_statement(' -- ', r); r:=r+1;
      ad_ddl.build_statement(' ', r); r:=r+1;
      ad_ddl.build_statement('END GCS_DATASUB_UTILITY_PKG; ', r);

      ad_ddl.create_plsql_object(GCS_DYNAMIC_UTIL_PKG.g_applsys_username,
                                 'GCS', 'GCS_DATASUB_UTILITY_PKG',
                                 1, r , 'TRUE', comp_err);

    END;


  END GCS_DATASUB_DYNAMIC_PKG;


/
