--------------------------------------------------------
--  DDL for Package Body GCS_CREATE_DYN_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_CREATE_DYN_INDEX_PKG" AS
/* $Header: gcsdynidxb.pls 120.11 2007/06/28 12:22:21 vkosuri noship $ */


  -- Private procedure

  PROCEDURE	Generate_Data_Sub_Index(l_column_list OUT NOCOPY VARCHAR2) IS

    CURSOR v_active_dims IS
			SELECT  DECODE(ftcp.column_name, 'INTERCOMPANY_ID', 'INTERCOMPANY_DISPLAY_CODE',
      				                               dtc.column_name) active_columns
			FROM    fem_tab_column_prop ftcp,
            			fem_tab_columns_b   ftcb,
            			fem_xdim_dimensions fxd,
            			dba_tab_columns     dtc
			WHERE   ftcp.table_name             =   'FEM_BALANCES'
			AND     ftcp.column_name            =   ftcb.column_name
			AND     ftcp.column_property_code   =   'PROCESSING_KEY'
			AND     ftcb.table_name             =   ftcp.table_name
			AND     ftcb.dimension_id           =   fxd.dimension_id
			AND     dtc.column_name             =   fxd.member_display_code_col
			AND     dtc.table_name              =   'GCS_BAL_INTERFACE_T'
			AND     dtc.owner                   =   'GCS';

  BEGIN
    l_column_list		:=	'LOAD_ID ';
    FOR c_active_dims in v_active_dims LOOP
      l_column_list	:=	l_column_list 	||	' , ' || c_active_dims.active_columns;
    END LOOP;
  END;

  PROCEDURE Drop_Index ( x_errbuf	OUT NOCOPY VARCHAR2,
			 x_retcode	OUT NOCOPY VARCHAR2,
                         index_name     VARCHAR2)IS
    body                VARCHAR2(5000);
    NO_INDEX            exception;
    PRAGMA              EXCEPTION_INIT (NO_INDEX, -1418);
  BEGIN
    body := 'DROP INDEX '||index_name;
    ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username, 'GCS', ad_ddl.drop_index, body, index_name);

  EXCEPTION
    WHEN NO_INDEX THEN
      fnd_file.put_line(fnd_file.log, 'Index to be dropped not found');
    WHEN OTHERS THEN
      x_errbuf := substr( SQLERRM, 1, 2000);
      x_retcode := '2';
  END Drop_Index;

  FUNCTION generate_epb_index RETURN VARCHAR2 IS

   l_data_table     VARCHAR2(30);
   l_index          VARCHAR2(30);
   len              NUMBER;
   body             VARCHAR2(5000);
   rowcount         NUMBER;
   l_table_owner    VARCHAR2(30);

   CURSOR epb_dims IS
      SELECT epb_column colname
      FROM GCS_EPB_DIM_MAPS
      WHERE enabled_flag = 'Y';

   CURSOR c_index_names (p_data_table VARCHAR2,
                         p_index_owner VARCHAR2) IS
      SELECT owner,
             index_name
      FROM   dba_indexes
      WHERE  table_name  = p_data_table
      AND    owner       = p_index_owner;

  BEGIN

      --Bugfix 5498824: Adding additional logging information
      fnd_file.put_line(fnd_file.log, 'Beginning of Generate EPB Index');

      SELECT epb_table_name
      INTO l_data_table
      FROM gcs_system_options;

      SELECT oracle_username
      INTO   l_table_owner
      FROM   fnd_oracle_userid
      WHERE  oracle_id     =    274;

      fnd_file.put_line(fnd_file.log, 'Data will be written to table: ' || l_data_table);

      --Bugfix 5498824: Remove the index initialization and search in data directionary
      --l_index := l_data_table || '_U1';

      --Bugfix 5498824: No longer check if processing key has been set. Check if rows exist in the data table
      /*
      SELECT  count(*)
      INTO rowcount
      FROM FEM_TAB_COLUMN_PROP
      WHERE table_name = l_data_table
      AND column_property_code = 'PROCESSING_KEY';
      */
      EXECUTE IMMEDIATE 'select count(1) from ' || l_data_table INTO rowcount;

      fnd_file.put_line(fnd_file.log, 'Number of rows in data table: ' || rowcount);

      --Bugfix 5498824- No longer check if processing key has been setup. If there are no rows in the table always re-initialize
      IF (rowcount = 0) THEN

        --Bugfix 5498824: Clean up formatting and drop all indices in data directionary
        -- generate the processing key
        DELETE FROM fem_tab_column_prop
        WHERE       table_name = l_data_table
        AND         column_property_code = 'PROCESSING_KEY';

        INSERT INTO FEM_TAB_COLUMN_PROP
        ( table_name,
          column_name,
          column_property_code,
          creation_date, created_by,
          last_updated_by,
          last_update_date,
          last_update_login,
          object_version_number)
        (
          SELECT l_data_table,
                 epb_column,
                 'PROCESSING_KEY',
                 sysdate,
                 FND_GLOBAL.user_id,
                 FND_GLOBAL.user_id,
                 sysdate,
                 FND_GLOBAL.login_id,
                 1
          FROM   GCS_EPB_DIM_MAPS
          WHERE  enabled_flag = 'Y'
         );

         fnd_file.put_line(fnd_file.log, 'Starting to Drop Indices');
         --Bugfix 5499824:  Using cursor to determine indices to drop
         FOR v_indices in c_index_names(l_data_table,
                                        l_table_owner) LOOP

           fnd_file.put_line(fnd_file.log, 'Starting to drop index: ' || v_indices.index_name);

           ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username,
                         v_indices.owner,
                         ad_ddl.drop_index,
                         'DROP INDEX ' || v_indices.index_name,
                         v_indices.index_name);

           fnd_file.put_line(fnd_file.log, 'Completed dropping of index');

         END LOOP;
         fnd_file.put_line(fnd_file.log, 'Completed Dropping Indices');
         -- generate the index
         body:= ' CREATE UNIQUE INDEX ' || l_data_table || '_P ON ' || l_data_table || ' ( ';
         FOR active_dims IN epb_dims LOOP
           body := body || active_dims.colname || ', ';
         END LOOP;
         len := length(body);
         body := substr(body, 1, len-2);
         body:= body || ' )';
         ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username, l_table_owner, ad_ddl.create_index, body, l_data_table || '_P');
      ELSE
         fnd_file.put_line(fnd_file.log, '<<<<<<<<<<Warning during EPB Code Generation>>>>>>>>>>>>>>>>>>>>>');
         fnd_file.put_line(fnd_file.log, 'The indices and processing key on ' || l_data_table || ' were not regenerated since data already exists in the table.');
         fnd_file.put_line(fnd_file.log, 'If you are ok with the analytical reporting setup, please ignore this warning. Otherwise, please undo the data in the tables');
         fnd_file.put_line(fnd_file.log, 'and re-run Module Initialization.');
         fnd_file.put_line(fnd_file.log, '<<<<<<<<<<<<<<<<<<End of Warning>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
         RETURN 'WARNING';
      END IF;

    RETURN 'SUCCESS';

    EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log, '<<<<<<<<<<<<<<<<<<<<Error During EPB Code Generation>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
      fnd_file.put_line(fnd_file.log, SQLERRM);
      fnd_file.put_line(fnd_file.log, '<<<<<<<<<<<<<<<<<<<<End of Error Details>>>>>>>>>>>>>>>>>>>>');
      RETURN 'WARNING';
  END;

  PROCEDURE Create_Index(	x_errbuf	OUT NOCOPY VARCHAR2,
				x_retcode	OUT NOCOPY VARCHAR2) IS
    collist             VARCHAR2(2000);
    index_list          VARCHAR2(4000);
    body                VARCHAR2(5000);
    retwebadi           VARCHAR2(100);
    -- subscription_guid RAW := null;
    event             wf_event_t := null;
    l_ret_status       BOOLEAN;
    l_sys_option       NUMBER;
    l_epb_table        VARCHAR2(30);

     -- Store the log level
     runtimeLogLevel     NUMBER := FND_LOG.g_current_runtime_level;
     procedureLogLevel   CONSTANT NUMBER := FND_LOG.level_procedure;
     statementLogLevel   CONSTANT NUMBER := FND_LOG.level_statement;

     -- Bugfix 5498824: Status of EPB Code Generation
     l_status_code       VARCHAR2(30);
   BEGIN

    fnd_file.put_line(fnd_file.log, 'Starting to Drop Indices');
    -- Drop indexes before we recreate them
    GCS_CREATE_DYN_INDEX_PKG.Drop_Index(x_errbuf, x_retcode, 'GCS_INTERCO_ELM_TRX_U1');
    GCS_CREATE_DYN_INDEX_PKG.Drop_Index(x_errbuf, x_retcode, 'GCS_HISTORICAL_RATES_U1');
    GCS_CREATE_DYN_INDEX_PKG.Drop_Index(x_errbuf, x_retcode, 'GCS_TRANSLATION_GT_U1');
    GCS_CREATE_DYN_INDEX_PKG.Drop_Index(x_errbuf, x_retcode, 'GCS_ENTRY_LINES_U1');
    GCS_CREATE_DYN_INDEX_PKG.Drop_Index(x_errbuf, x_retcode, 'GCS_AD_TRIAL_BALANCES_U1');
    -- Bugfix 4281391 : Added dropping of index GCS_BAL_INTERFACE_T_U1
    GCS_CREATE_DYN_INDEX_PKG.Drop_Index(x_errbuf, x_retcode, 'GCS_BAL_INTERFACE_T_U1');
    fnd_file.put_line(fnd_file.log, 'Completed Dropping Indices');

    index_list := rtrim(GCS_DYNAMIC_UTIL_PKG.index_col_list(collist), ', ');
    IF index_list IS NOT NULL THEN
      index_list := ', ' || index_list;
    END IF;

    fnd_file.put_line(fnd_file.log, 'Starting to Create Indices');
    fnd_file.put_line(fnd_file.log, 'Generating GCS_INTERCO_ELM_TRX_U1');
    -- Recreate the indices
    body:= ' CREATE UNIQUE INDEX GCS_INTERCO_ELM_TRX_U1 ON GCS_INTERCO_ELM_TRX (hierarchy_id, src_entity_id, target_entity_id,';
    body:= body || 'cal_period_id, company_cost_center_org_id, intercompany_id, line_item_id';
    body := body || index_list || ')';
    ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username, 'GCS', ad_ddl.create_index, body, 'GCS_INTERCO_ELM_TRX_U1');

    fnd_file.put_line(fnd_file.log, 'Generating GCS_HISTORICAL_RATES_U1');
    body:= ' CREATE UNIQUE INDEX GCS_HISTORICAL_RATES_U1 ON GCS_HISTORICAL_RATES (hierarchy_id, entity_id, from_currency, to_currency, update_flag, ';
    body:= body || 'cal_period_id, company_cost_center_org_id, intercompany_id, line_item_id';
    body := body || index_list || ')';
    ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username, 'GCS', ad_ddl.create_index, body, 'GCS_HISTORICAL_RATES_U1');

    fnd_file.put_line(fnd_file.log, 'Generating GCS_TRANSLATION_GT_U1');
    body:= ' CREATE UNIQUE INDEX GCS_TRANSLATION_GT_U1 ON GCS_TRANSLATION_GT (';
    body:= body || 'company_cost_center_org_id, intercompany_id, line_item_id';
    body := body || index_list || ')';
    ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username, 'GCS', ad_ddl.create_index, body, 'GCS_TRANSLATION_GT_U1');

    fnd_file.put_line(fnd_file.log, 'Generating GCS_ENTRY_LINES_U1');
    body:= ' CREATE UNIQUE INDEX GCS_ENTRY_LINES_U1 ON GCS_ENTRY_LINES (entry_id, ';
    body:= body || 'company_cost_center_org_id, intercompany_id, line_item_id';
    --Bugfix 5532657: Added entry_line_number to the unique index
    body := body || index_list || ', entry_line_number)';
    ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username, 'GCS', ad_ddl.create_index, body, 'GCS_ENTRY_LINES_U1');

    fnd_file.put_line(fnd_file.log, 'Generating GCS_AD_TRIAL_BALANCES_U1');
    body:= ' CREATE UNIQUE INDEX GCS_AD_TRIAL_BALANCES_U1 ON GCS_AD_TRIAL_BALANCES (ad_transaction_id, trial_balance_seq, ';
    body:= body || 'company_cost_center_org_id, intercompany_id, line_item_id';
    body := body || index_list || ')';
    ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username, 'GCS', ad_ddl.create_index, body, 'GCS_AD_TRIAL_BALANCES_U1');

    fnd_file.put_line(fnd_file.log, 'Generating GCS_BAL_INTERFACE_T_U1');
    Generate_Data_Sub_Index(collist);
    body := ' CREATE UNIQUE INDEX GCS_BAL_INTERFACE_T_U1 ON GCS_BAL_INTERFACE_T ( ' || collist || ') ';
    ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username, 'GCS', ad_ddl.create_index, body, 'GCS_BAL_INTERFACE_T_U1');

    fnd_file.put_line(fnd_file.log, 'Completed Creation of Indices');

    fnd_file.put_line(fnd_file.log, 'Starting to Generate PL/SQL Packages');

    -- Check if system options is set
    SELECT nvl(fch_global_vs_combo_id, -1)
     INTO  l_sys_option
     FROM gcs_system_options;

    IF l_sys_option <> -1 THEN
      fnd_file.put_line(fnd_file.log, 'Generating Dimension Transfer');
      GCS_BUILD_EPB_DIM_TR_PKG.build_epb_dimtr_pkg;
    END IF;

    --Bugfix 5498824: Removing the reference to ln_item_hierarchy_obj_id
    SELECT nvl(epb_table_name, 'INVALID')
      INTO l_epb_table
      FROM gcs_system_options;

    IF ( l_epb_table <> 'INVALID' ) THEN
      fnd_file.put_line(fnd_file.log, 'Generating EPB/FCH Data Transfer');
      GCS_BUILD_EPB_DATA_TR_PKG.build_epb_datatr_pkg;
      fnd_file.put_line(fnd_file.log, 'Generating Index and Processing key for data table');
      l_status_code := generate_epb_index;
    ELSE
      fnd_file.put_line(fnd_file.log, '<<<<<<<<<<<<<<<<<<<<Warning Message>>>>>>>>>>>>>>>>>>>>>>>>>>');
      fnd_file.put_line(fnd_file.log, 'Please make sure you complete the analytical reporting step in Foundation prior to running Consolidation');
      fnd_file.put_line(fnd_file.log, '<<<<<<<<<<<<<<<<<<<<<End of Warning>>>>>>>>>>>>>>>>>>>>>>>>>>');
      l_status_code := 'WARNING';
    END IF;

    fnd_file.put_line(fnd_file.log, 'Generating Aggregation');
    GCS_AGGREGATION_DYN_BUILD_PKG.create_package;

    fnd_file.put_line(fnd_file.log, 'Generating Data Preparation');
    GCS_DATA_PREP_PKG.create_process(x_errbuf, x_retcode);

    fnd_file.put_line(fnd_file.log, 'Generating Balances Processor');
    GCS_BUILD_FEM_POSTING_PKG.create_package;

    fnd_file.put_line(fnd_file.log, 'Generating Intercompany');
    GCS_INTERCO_DYN_BUILD_PKG.Interco_Create_Package(x_errbuf, x_retcode);

    fnd_file.put_line(fnd_file.log, 'Generating Period Initialization');
    GCS_PERIOD_INIT_DYN_BUILD_PKG.create_package;

    fnd_file.put_line(fnd_file.log, 'Generating Balancing Routine');
    GCS_TEMPLATES_PKG.create_dynamic_pkg(x_errbuf, x_retcode);

    -- Bugfix 5707630: Start
    fnd_file.put_line(fnd_file.log, 'Generating Translation');
    GCS_TRANS_HRATES_DYN_BUILD_PKG.create_package(x_errbuf, x_retcode);

    fnd_file.put_line(fnd_file.log, 'Generating Translation for Historical Rates');
    GCS_TRANS_RE_DYN_BUILD_PKG.create_package(x_errbuf, x_retcode);
    -- Bugfix 5707630: End

    fnd_file.put_line(fnd_file.log, 'Generating Translation for Retained Earnings');
    GCS_TRANS_DYN_BUILD_PKG.create_package(x_errbuf, x_retcode);

    fnd_file.put_line(fnd_file.log, 'Generating Data Submission');
    GCS_DATASUB_DYNAMIC_PKG.create_datasub_utility_pkg(x_errbuf, x_retcode);

    fnd_file.put_line(fnd_file.log, 'Generating XML Generation Package');
    GCS_XML_DYNAMIC_PKG.create_xml_utility_pkg(x_errbuf, x_retcode);

    fnd_file.put_line(fnd_file.log, 'Manipulating XML Publisher Data Templates');
    GCS_DATA_TEMPLATE_UTIL_PKG.gcs_replace_dt_proc(x_errbuf, x_retcode);

    fnd_file.put_line(fnd_file.log, 'Generating Web-ADI');
    retwebadi := GCS_WEBADI_PKG.execute_event(NULL, event);

    --Bugfix 5190565: Calling Rules Processor Utility to Inser Data
    fnd_file.put_line(fnd_file.log, 'Generating Rules Process Utility');
    gcs_rp_util_build_pkg.create_rp_utility_pkg( p_errbuf  =>    x_errbuf , p_retcode =>   x_retcode);

    fnd_file.put_line(fnd_file.log, 'Completed Generation of PL/SQL Packages');


    fnd_file.put_line(fnd_file.log, 'Generating Data Submission Trial Balance View');
    GCS_DYN_TB_VIEW_PKG.create_view(x_errbuf, x_retcode);
    fnd_file.put_line(fnd_file.log, 'Completed Generation of Views');


    x_retcode := '0';

    IF (l_status_code = 'WARNING') THEN
      x_retcode := '1';
      l_ret_status := fnd_concurrent.set_completion_status(
                                                status => 'WARNING',
                                                message => 'NULL');
    END IF;


  EXCEPTION
     WHEN OTHERS THEN
      x_errbuf := substr( SQLERRM, 1, 2000);
      x_retcode := '2';
      fnd_file.put_line(fnd_file.log, 'Fatal Error Occurred : ' || SQLERRM);
      l_ret_status         :=      fnd_concurrent.set_completion_status(
                                                status  =>      'ERROR',
                                                message =>      NULL);

  END Create_Index;

 -- Bug fix : 5289002
  PROCEDURE submit_request (p_request_id OUT NOCOPY NUMBER) IS

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.GCS_CREATE_DYN_INDEX_PKG.submit_request.begin', '<<Enter>>');
    END IF;

    p_request_id :=     fnd_request.submit_request(
                                        application     => 'GCS',
                                        program         => 'GCS_DYNAMIC_INDEX',
                                        sub_request     => FALSE);

    --Bugfix 4333250: Add commit in order for request to be submitted

    COMMIT;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.GCS_CREATE_DYN_INDEX_PKG.submit_request', 'Submitted Request ID : '  || p_request_id);
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.GCS_CREATE_DYN_INDEX_PKG.submit_request.end', '<<Exit>>');
    END IF;

  END;

END GCS_CREATE_DYN_INDEX_PKG;

/
