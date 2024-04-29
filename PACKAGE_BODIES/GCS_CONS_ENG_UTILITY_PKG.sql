--------------------------------------------------------
--  DDL for Package Body GCS_CONS_ENG_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_CONS_ENG_UTILITY_PKG" as
/* $Header: gcs_eng_utilb.pls 120.15 2007/09/27 21:47:06 rguerrer noship $ */

   g_api	VARCHAR2(80)	:=	'gcs.plsql.GCS_CONS_ENG_UTILITY_PKG';

   PROCEDURE get_cons_entity_wf_info (itemtype			IN VARCHAR2,
   				      itemkey			IN VARCHAR2,
   				      cons_entity_wf_info	IN OUT NOCOPY r_cons_entity_wf_info)

   IS

   BEGIN

     cons_entity_wf_info.consolidation_hierarchy	:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CONS_HIERARCHY', FALSE);
     cons_entity_wf_info.consolidation_entity		:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CONS_ENTITY', FALSE);
     cons_entity_wf_info.run_identifier			:=	WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'RUN_IDENTIFIER', FALSE);
     cons_entity_wf_info.cal_period_id			:=	WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'CAL_PERIOD', FALSE);
     cons_entity_wf_info.cal_period_end_date		:=	TO_DATE(WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'CAL_PERIOD_END_DATE', FALSE), 'DD-MM-RR');
     cons_entity_wf_info.balance_type_code		:=	WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'BALANCE_TYPE_CODE', FALSE);
     cons_entity_wf_info.run_detail_id			:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'RUN_DETAIL_ID', FALSE);
     cons_entity_wf_info.process_method			:=	WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'PROCESS_METHOD', FALSE);
     cons_entity_wf_info.num_of_categories		:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'NUM_OF_CATEGORIES', FALSE);
     cons_entity_wf_info.curr_category_num		:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CURR_CATEGORY_NUM', FALSE);
     cons_entity_wf_info.prior_run_identifier		:=	WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'PRIOR_RUN_NAME', FALSE);
     cons_entity_wf_info.xlate_entry_id			:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'XLATE_ENTRY_ID', FALSE);
     cons_entity_wf_info.request_id			:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CONC_REQUEST_ID', FALSE);
     --Bugfix 5017120: Added support for additional data types
     cons_entity_wf_info.source_dataset_code            :=      WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'SOURCE_DATASET_CODE', FALSE);
     cons_entity_wf_info.hierarchy_dataset_code         :=      WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'HIERARCHY_DATASET_CODE', FALSE);
     -- Bugfix 5569522: Added for business process kick-off support
     cons_entity_wf_info.analysis_cycle_id       := WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'ANALYSIS_CYCLE_ID', FALSE);
   END get_cons_entity_wf_info;

   PROCEDURE get_oper_entity_wf_info (itemtype			IN VARCHAR2,
   				      itemkey			IN VARCHAR2,
   				      cons_entity_wf_info	IN OUT NOCOPY r_cons_entity_wf_info,
   				      oper_entity_wf_info	IN OUT NOCOPY r_oper_entity_wf_info)

   IS

   BEGIN
      oper_entity_wf_info.parent_workflow_key		:=	WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'PARENT_WORKFLOW_KEY', FALSE);
      oper_entity_wf_info.operating_entity		:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'OPER_ENTITY', FALSE);
      oper_entity_wf_info.cons_relationship_id		:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CONS_RELATIONSHIP_ID', FALSE);
      oper_entity_wf_info.run_detail_id			:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'RUN_DETAIL_ID', FALSE);
      oper_entity_wf_info.translation_required		:=	WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'TRANSLATION_REQUIRED', FALSE);
      oper_entity_wf_info.xlate_entry_id		:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'XLATE_ENTRY_ID', FALSE);

      get_cons_entity_wf_info('GCSENGNE', oper_entity_wf_info.parent_workflow_key, cons_entity_wf_info);
   END get_oper_entity_wf_info;

   PROCEDURE update_entry_headers(p_run_name			IN VARCHAR2,
   				  p_entry_id			IN NUMBER)

   IS PRAGMA AUTONOMOUS_TRANSACTION;

   BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_ENTRY_HEADERS.begin', '<<Enter>>');
    END IF;

     UPDATE gcs_entry_headers
     SET    processed_run_name		=	p_run_name,
     	    disabled_flag		=	'Y',
	    last_update_date		=	sysdate,
	    last_updated_by		=	FND_GLOBAL.USER_ID,
	    last_update_login		=	FND_GLOBAL.LOGIN_ID
     WHERE  entry_id			=	p_entry_id;

     COMMIT;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_ENTRY_HEADERS.end', '<<Exit>>');
    END IF;
   END update_entry_headers;

   PROCEDURE submit_xml_ntf_program(p_run_name                    IN VARCHAR2,
                                    p_cons_entity_id		  IN NUMBER,
				    p_category_code		  IN VARCHAR2,
				    p_child_entity_id		  IN NUMBER	DEFAULT NULL,
				    p_run_detail_id		  IN NUMBER 	DEFAULT NULL)
   IS PRAGMA AUTONOMOUS_TRANSACTION;

     l_request_id NUMBER(15);

   BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_XML_NTF_PROGRAM.begin', '<<Enter>>');
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL		<=	FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Run Name		: 	' || p_run_name);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Consoliation Entity 	:	' || p_cons_entity_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Category		:	' || p_category_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Child Entity		:	' || p_child_entity_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Run Detail ID	:	' || p_run_detail_id);
    END IF;

    fnd_file.put_line(fnd_file.log, 'Within submit_xml_ntf_program');

    l_request_id :=     fnd_request.submit_request(
                                        application     => 'GCS',
                                        program         => 'FCH_XML_NTF_UTILITY',
                                        sub_request     => FALSE,
					argument1	=> 'CONS_PROCESS',
                                        argument2       => p_run_name,
                                        argument3       => p_cons_entity_id,
                                        argument4       => p_category_code,
                                        argument5       => p_child_entity_id,
                                        argument6       => p_run_detail_id);

    fnd_file.put_line(fnd_file.log, 'Submitted request id : ' || l_request_id);


    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_XML_NTF_PROGRAM.end', '<<Exit>>');
    END IF;

    COMMIT;

   END submit_xml_ntf_program;

   PROCEDURE execute_module (module_code			IN VARCHAR2,
   			     p_parameter_list			IN OUT NOCOPY gcs_cons_eng_utility_pkg.r_module_parameters,
   			     p_item_key				IN VARCHAR2)

   IS PRAGMA AUTONOMOUS_TRANSACTION;

     l_entry_id		NUMBER(15);
     l_stat_entry_id	NUMBER(15);

   BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.EXECUTE_MODULE.begin', '<<Enter for item key : ' || p_item_key || '>>');
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Module Code		: ' || module_code);
    END IF;

    IF (module_code = 'TRANSLATION') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Entry ID	       : ' || p_parameter_list.entry_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Relationship      : ' || p_parameter_list.cons_relationship_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Xlate Mode	       : ' || p_parameter_list.xlate_mode);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Balance Type Code : ' || p_parameter_list.balance_type_code);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Xlate Entry ID    : ' || p_parameter_list.xlate_entry_id);
       END IF;

        BEGIN
  	  gcs_translation_pkg.translate(p_parameter_list.errbuf,
    				        p_parameter_list.retcode,
    				        p_parameter_list.cal_period_id,
    				        p_parameter_list.cons_relationship_id,
    				        p_parameter_list.balance_type_code,
                                        p_parameter_list.hierarchy_dataset_code,
    				        p_parameter_list.xlate_entry_id);
         EXCEPTION
           WHEN OTHERS THEN
             p_parameter_list.errbuf	:= 	SQLERRM;
         END;

        --Bugfix 4205986 : Set the Entry ID to Null if an error occurred during translation
        IF (p_parameter_list.errbuf IS NOT NULL) THEN
          p_parameter_list.xlate_entry_id := NULL;
        END IF;

  	gcs_cons_eng_run_dtls_pkg.update_entry_headers(
  					p_run_detail_id			=>	p_parameter_list.run_detail_id,
  					p_entry_id			=>	p_parameter_list.xlate_entry_id,
  					p_request_error_code		=>	NVL(p_parameter_list.errbuf, 'COMPLETED'),
  					p_bp_request_error_code		=>	NVL(p_parameter_list.errbuf, 'COMPLETED'));

     ELSIF (module_code = 'DATAPREPARATION') THEN

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Hierarchy 	       : ' || p_parameter_list.hierarchy_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Entity 	       : ' || p_parameter_list.child_entity_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Cal Period        : ' || p_parameter_list.cal_period_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Run Detail        : ' || p_parameter_list.run_detail_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Cons Relationship : ' || p_parameter_list.cons_relationship_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Balance Type Code : ' || p_parameter_list.balance_type_code);
       END IF;

      	gcs_data_prep_pkg.gcs_main_data_prep (
       				x_errbuf                  => p_parameter_list.errbuf,
       				x_retcode                 => p_parameter_list.retcode,
       				p_hierarchy_id            => p_parameter_list.hierarchy_id,
       				p_entity_id               => p_parameter_list.child_entity_id,
      	 			p_target_cal_period_id    => p_parameter_list.cal_period_id,
       				p_run_detail_id		  => p_parameter_list.run_detail_id,
       				p_cons_rel_id             => p_parameter_list.cons_relationship_id,
       				p_balance_type_code       => p_parameter_list.balance_type_code,
                                p_source_dataset_code     => p_parameter_list.source_dataset_code);

       --Bugfix 3666700: Removed call to insert intercompany transactions into temp table
       --Bugfix 4307627: Removed call to update status for data preparation

     ELSIF (module_code 	=	'BALANCES_PROCESSOR') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
    	 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Run Name		:	' ||	p_parameter_list.run_name);
    	 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Cal Period ID 	:	' || 	p_parameter_list.cal_period_id);
    	 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Category Code 	:	' || 	p_parameter_list.category_code);
    	 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Hierarchy Id	:	' ||	p_parameter_list.hierarchy_id);
    	 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Balance Type Code	:	' || 	p_parameter_list.balance_type_code);
    	 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Consolidation Entity ID :	' ||	p_parameter_list.cons_entity_id);
    	 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Child Entity ID	:	' ||	p_parameter_list.child_entity_id);
    	 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'BP Undo Prior	:	' ||	p_parameter_list.bp_undo_prior);
    	 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Run Detail ID	:	' ||	p_parameter_list.run_detail_id);
    	 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'BP Post Xlate	:	' ||	p_parameter_list.bp_post_xlate);
    	 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Entry ID		:	' ||	p_parameter_list.entry_id);
    	 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'BP Mode		:	' ||	p_parameter_list.bp_mode);
       END IF;

      gcs_dyn_fem_posting_pkg.gcs_fem_post(
    					errbuf			=>	p_parameter_list.errbuf,
    					retcode			=>	p_parameter_list.retcode,
    					p_run_name		=>	p_parameter_list.run_name,
    					p_cal_period_id		=>	p_parameter_list.cal_period_id,
    					p_category_code		=>	p_parameter_list.category_code,
    					p_hierarchy_id		=>	p_parameter_list.hierarchy_id,
    					p_balance_type_code	=>	p_parameter_list.balance_type_code,
    					p_cons_entity_id	=>	p_parameter_list.cons_entity_id,
    					p_child_entity_id	=>	p_parameter_list.child_entity_id,
    					p_undo			=>	p_parameter_list.bp_undo_prior,
    					p_run_detail_id		=>	p_parameter_list.run_detail_id,
    					p_xlate			=>	p_parameter_list.bp_post_xlate,
    					p_entry_id		=>	p_parameter_list.entry_id,
    					p_mode			=>	p_parameter_list.bp_mode,
                                        p_hier_dataset_code     =>      p_parameter_list.hierarchy_dataset_code);
     ELSIF (module_code		=	'AGGREGATION') THEN

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Hierarchy 	       : ' || p_parameter_list.hierarchy_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Entity 	       : ' || p_parameter_list.cons_entity_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Cal Period        : ' || p_parameter_list.cal_period_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Run Detail        : ' || p_parameter_list.run_detail_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Cons Relationship : ' || p_parameter_list.cons_relationship_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Balance Type Code : ' || p_parameter_list.balance_type_code);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'End Date	       : ' || p_parameter_list.period_end_date);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Stat Required     : ' || p_parameter_list.stat_required);
       END IF;

       gcs_aggregation_pkg.aggregate(	p_run_detail_id		=>	p_parameter_list.run_detail_id,
    					p_hierarchy_id		=>	p_parameter_list.hierarchy_id,
    				  	p_relationship_id	=>	p_parameter_list.cons_relationship_id,
    				  	p_cons_entity_id	=>	p_parameter_list.cons_entity_id,
    				  	p_cal_period_id		=>	p_parameter_list.cal_period_id,
    				  	p_period_end_date	=>	p_parameter_list.period_end_date,
    				  	p_balance_type_code	=>	p_parameter_list.balance_type_code,
    				  	p_stat_required		=>	p_parameter_list.stat_required,
    				  	p_errbuf		=>	p_parameter_list.errbuf,
    				  	p_retcode		=>	p_parameter_list.retcode,
                                        p_hier_dataset_code     =>      p_parameter_list.hierarchy_dataset_code);

	gcs_cons_eng_run_dtls_pkg.update_entry_headers(
					p_run_detail_id			=>	p_parameter_list.run_detail_id,
					p_request_error_code		=>	NVL(p_parameter_list.errbuf, 'COMPLETED'),
					p_bp_request_error_code		=>	NVL(p_parameter_list.errbuf, 'COMPLETED'));

     ELSIF (module_code		=	'INTERCOMPANY') THEN

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Hierarchy 		: ' || p_parameter_list.hierarchy_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Entity		: ' || p_parameter_list.child_entity_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Cal Period  	: ' || p_parameter_list.cal_period_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Intercompany Mode	: ' || p_parameter_list.intercompany_mode);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Currency Code	: ' || p_parameter_list.currency_code);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Run Identifier	: ' || p_parameter_list.run_name);
       END IF;


       gcs_interco_processing_pkg.interco_process_main
     	(
       	 p_hierarchy_id		=>	p_parameter_list.hierarchy_id,
       	 p_cal_period_id	=>	p_parameter_list.cal_period_id,
         p_balance_type		=>	p_parameter_list.balance_type_code,
       	 p_entity_id		=>	p_parameter_list.child_entity_id,
         p_elim_mode		=>	p_parameter_list.intercompany_mode,
       	 p_currency_code	=>	p_parameter_list.currency_code,
       	 p_run_name		=>	p_parameter_list.run_name,
         p_translation_required =>      p_parameter_list.bp_post_xlate,
       	 x_errbuf		=>	p_parameter_list.errbuf,
         x_retcode		=>	p_parameter_list.retcode);

     ELSIF (module_code		=	'RULES_PROCESSOR') THEN

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Event Category  : ' || p_parameter_list.rp_parameters.eventCategory);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Data Set Code   : ' || p_parameter_list.rp_parameters.datasetCode);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Parent Entity   : ' || p_parameter_list.rp_parameters.parentEntity);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Child Entity    : ' || p_parameter_list.rp_parameters.childEntity);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Elim Entity     : ' || p_parameter_list.rp_parameters.elimsEntity);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Currency  	     : ' || p_parameter_list.rp_parameters.currencyCode);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Event Type	     : ' || p_parameter_list.rp_parameters.eventType);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Rule Id 	     : ' || p_parameter_list.elim_rule_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Relationship    : ' || p_parameter_list.rp_parameters.relationship);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'To Percent	     : ' || p_parameter_list.rp_rule_data.toPercent);
       END IF;

       p_parameter_list.retcode := gcs_rules_processor.process_rule(
       					p_rule_id	=>	p_parameter_list.elim_rule_id,
       					p_stat_flag	=>	'N',
       					p_context	=>	p_parameter_list.rp_parameters,
       					p_rule_data	=>	p_parameter_list.rp_rule_data);

       --Bugfix 3920448 : Remove update of run details for fules processor

     ELSIF (module_code		=	'PERIOD_INITIALIZATION') THEN

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Run Name	       : ' || p_parameter_list.run_name);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Hierarchy	       : ' || p_parameter_list.hierarchy_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Child Entity      : ' || p_parameter_list.child_entity_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Calendar Period   : ' || p_parameter_list.cal_period_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Balance Type Code : ' || p_parameter_list.balance_type_code);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Relationship Id   : ' || p_parameter_list.cons_relationship_id);
       END IF;

        gcs_period_init_pkg.create_period_init_entries(
     	  p_errbuf			=>	p_parameter_list.errbuf,
     	  p_retcode			=>	p_parameter_list.retcode,
     	  p_run_name			=>	p_parameter_list.run_name,
     	  p_hierarchy_id		=>	p_parameter_list.hierarchy_id,
	  p_entity_id			=>	p_parameter_list.child_entity_id,
	  p_cal_period_id		=>	p_parameter_list.cal_period_id,
  	  p_balance_type_code		=>	p_parameter_list.balance_type_code,
  	  p_relationship_id		=>	p_parameter_list.cons_relationship_id,
	  p_cons_entity_id		=>	p_parameter_list.cons_entity_id,
	  p_translation_required	=>	p_parameter_list.bp_post_xlate
  	  );
     ELSIF (module_code		=	'UNDO_ELIMINATIONS') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Run Name           : ' || p_parameter_list.run_name);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Hierarchy 		: ' || p_parameter_list.hierarchy_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Calendar Period    : ' || p_parameter_list.cal_period_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Balance Type Code  : ' || p_parameter_list.balance_type_code);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Undo Entity Type   : ' || p_parameter_list.undo_entity_type);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXECUTE_MODULE', 'Undo Entity ID	: ' || p_parameter_list.undo_entity_id);

       END IF;
 	gcs_dyn_fem_posting_pkg.gcs_fem_delete(
                                        errbuf                  =>      p_parameter_list.errbuf,
                                        retcode                 =>      p_parameter_list.retcode,
                                        p_cal_period_id         =>      p_parameter_list.cal_period_id,
                                        p_hierarchy_id          =>      p_parameter_list.hierarchy_id,
                                        p_balance_type_code     =>      p_parameter_list.balance_type_code,
					p_entity_type		=>	p_parameter_list.undo_entity_type,
					p_entity_id		=>	p_parameter_list.undo_entity_id,
                                        p_hier_dataset_code     =>      p_parameter_list.hierarchy_dataset_code);

     END IF;

     COMMIT;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.EXECUTE_MODULE.end', '<<Exit for itemkey : ' || p_item_key || '>>');
    END IF;

  END execute_module;

  PROCEDURE balances_processor	(		itemtype		IN VARCHAR2,
  						itemkey			IN VARCHAR2,
  						actid			IN NUMBER,
  						funcmode		IN varchar2,
  						result			IN OUT NOCOPY varchar2)	IS

      cons_entity_wf_info	r_cons_entity_wf_info;
      oper_entity_wf_info	r_oper_entity_wf_info;
      l_category_code		VARCHAR2(30);
      x_errbuf			VARCHAR2(2000);
      x_retcode			VARCHAR2(30);
      l_child_entity_id		NUMBER(15);
      l_undo_flag		VARCHAR2(1)	:= 'N';
      l_run_detail_id		NUMBER(15);
      l_mode			VARCHAR2(30)	:= 'I';
      l_curr_category_num	NUMBER(15);
      l_rows_to_process		VARCHAR2(1)	:= 'Y';
      l_xlate_flag		VARCHAR2(1)	:= 'N';
      l_entry_id		NUMBER(15);
      l_parameter_list		gcs_cons_eng_utility_pkg.r_module_parameters;

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.BALANCES_PROCESSOR.begin', '<<Enter for itemkey : ' || itemkey || '>>');
    END IF;

    l_parameter_list.category_code	:=	WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid, 'CATEGORY_CODE', FALSE);
    l_parameter_list.bp_post_xlate	:=	'N';
    l_parameter_list.bp_mode		:=	'I';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.BALANCES_PROCESSOR', 'Category Code	:	'	|| l_parameter_list.category_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.BALANCES_PROCESSOR', 'Post Xlate	:	'	|| l_parameter_list.bp_post_xlate);
    END IF;

    IF (itemtype 	=	'GCSOPRWF') THEN

     gcs_cons_eng_utility_pkg.get_oper_entity_wf_info (itemtype,
                                                       itemkey,
                                                       cons_entity_wf_info,
                                                       oper_entity_wf_info);

       IF (cons_entity_wf_info.prior_run_identifier <> 'NO_PRIOR_RUN') THEN
         l_parameter_list.bp_undo_prior            :=      'Y';
       END IF;

       IF (l_parameter_list.category_code = 'DATAPREPARATION') THEN
         l_parameter_list.run_detail_id	:=	oper_entity_wf_info.run_detail_id;
       ELSIF (l_parameter_list.category_code = 'INCREMENTAL_DATAPREPARATION') THEN
         l_parameter_list.run_detail_id :=  	oper_entity_wf_info.run_detail_id;
	 l_parameter_list.bp_mode	:=	'D';
         l_parameter_list.bp_undo_prior	:=	'N';
	 l_parameter_list.category_code :=	'DATAPREPARATION';
       ELSIF (l_parameter_list.category_code = 'XLATE_DATAPREPARATION') THEN
         l_parameter_list.category_code		:=	'TRANSLATION';
         l_parameter_list.entry_id 		:=      oper_entity_wf_info.xlate_entry_id;
       ELSIF (l_parameter_list.category_code = 'ADJUSTMENT') THEN
         l_curr_category_num			:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CURR_CATEGORY_NUM', FALSE);
         l_parameter_list.child_entity_id	:=	oper_entity_wf_info.operating_entity;
         l_parameter_list.category_code		:=	gcs_categories_pkg.g_oper_category_info(l_curr_category_num).category_code;
         l_parameter_list.bp_undo_prior         :=      'N';

         SELECT DECODE(COUNT(*), 0, 'N', 'Y')
         INTO   l_rows_to_process
         FROM   gcs_cons_eng_run_dtls
         WHERE  consolidation_entity_id	= cons_entity_wf_info.consolidation_entity
         AND    run_name		= cons_entity_wf_info.run_identifier
         AND    child_entity_id		= oper_entity_wf_info.operating_entity
         AND    category_code		= l_parameter_list.category_code;
       END IF;

    ELSIF (itemtype	=	'GCSENGNE') THEN

     gcs_cons_eng_utility_pkg.get_cons_entity_wf_info (itemtype,
                                                       itemkey,
                                                       cons_entity_wf_info);

       IF (cons_entity_wf_info.prior_run_identifier <> 'NO_PRIOR_RUN') THEN
         l_parameter_list.bp_undo_prior            :=      'Y';
       END IF;

       IF (l_parameter_list.category_code = 'AGGREGATION') THEN

	   l_parameter_list.run_detail_id	:=	cons_entity_wf_info.run_detail_id;

       ELSIF (l_parameter_list.category_code = 'XLATE_AGGREGATE') THEN

           l_parameter_list.category_code	:=	'TRANSLATION';
	   l_parameter_list.entry_id		:=	cons_entity_wf_info.xlate_entry_id;

       ELSIF (l_parameter_list.category_code = 'ADJUSTMENT') THEN

         l_curr_category_num	:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CURR_CATEGORY_NUM', FALSE);
	 l_parameter_list.category_code	:=	gcs_categories_pkg.g_cons_category_info(l_curr_category_num).category_code;
         l_parameter_list.bp_undo_prior :=      'N';

         SELECT DECODE(COUNT(*), 0, 'N', 'Y')
         INTO   l_rows_to_process
         FROM   gcs_cons_eng_run_dtls
         WHERE  consolidation_entity_id	= cons_entity_wf_info.consolidation_entity
         AND    run_name		= cons_entity_wf_info.run_identifier
         AND    child_entity_id		IS NOT NULL
         AND    category_code		= l_parameter_list.category_code;

         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.BALANCES_PROCESSOR', 'Consolidation Rows to Process 		:	'	|| l_rows_to_process);
         END IF;

       END IF;

    END IF;

    l_parameter_list.run_name		    :=	cons_entity_wf_info.run_identifier;
    l_parameter_list.cal_period_id	    :=	cons_entity_wf_info.cal_period_id;
    l_parameter_list.hierarchy_id	    :=	cons_entity_wf_info.consolidation_hierarchy;
    l_parameter_list.balance_type_code	    :=	cons_entity_wf_info.balance_type_code;
    l_parameter_list.cons_entity_id	    :=	cons_entity_wf_info.consolidation_entity;
    --Bugfix 5039565: Passing hierarchy dataset code
    l_parameter_list.hierarchy_dataset_code :=  cons_entity_wf_info.hierarchy_dataset_code;

    IF (l_rows_to_process = 'Y') THEN
      execute_module('BALANCES_PROCESSOR', l_parameter_list, itemkey);
    END IF;

  result := 'COMPLETE';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.BALANCES_PROCESSOR.end', '<<Exit for itemkey : ' || itemkey || '>>');
    END IF;

  END balances_processor;

  PROCEDURE check_adj_required	(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2) IS



    l_categories_exist		VARCHAR2(1)		:=	'N';
    l_category_type		VARCHAR2(30)		:=	NULL;
    cons_entity_wf_info       	r_cons_entity_wf_info;
    oper_entity_wf_info       	r_oper_entity_wf_info;
    l_category_count		NUMBER(15);
    l_change_in_data		VARCHAR2(1);
    l_child_entity_id		NUMBER(15);
    l_parameter_list 	        gcs_cons_eng_utility_pkg.r_module_parameters;
  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CHECK_ADJ_REQUIRED.begin', '<<Enter for itemkey : ' || itemkey || ' >>');
    END IF;


   IF (itemtype = 'GCSOPRWF') THEN
     gcs_cons_eng_utility_pkg.get_oper_entity_wf_info (itemtype,
                                                       itemkey,
                                                       cons_entity_wf_info,
                                                       oper_entity_wf_info);
     l_category_count			:=	gcs_categories_pkg.g_oper_category_info.COUNT;
     l_child_entity_id			:=	oper_entity_wf_info.operating_entity;
     l_parameter_list.undo_entity_id	:=	l_child_entity_id;
     l_parameter_list.undo_entity_type	:=	'O';

   ELSE
     gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype,
                                                      itemkey,
                                                      cons_entity_wf_info);
     l_category_count			:=	gcs_categories_pkg.g_cons_category_info.COUNT;
     l_child_entity_id			:=	cons_entity_wf_info.consolidation_entity;
     l_parameter_list.undo_entity_id	:=	cons_entity_wf_info.consolidation_entity;
     l_parameter_list.undo_entity_type	:=	'E';
   END IF;

   result			:=	'COMPLETE:F';

   WF_ENGINE.SetItemAttrNumber(itemtype, itemkey, 'NUM_OF_CATEGORIES', l_category_count);
   WF_ENGINE.SetItemAttrNumber(itemtype, itemkey, 'CURR_CATEGORY_NUM', 0);

   --Initialize Workflow Attributes
   IF (l_category_count		>	0)		THEN
    IF ((cons_entity_wf_info.prior_run_identifier <> 'NO_PRIOR_RUN') AND (cons_entity_wf_info.process_method = 'INCREMENTAL')) THEN
      BEGIN
	  -- Check if any impact occurred
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CHECK_ADJ_REQUIRED', '<<Checking if any impact occurred>');
        END IF;

	IF (itemtype = 'GCSOPRWF') THEN
          SELECT 	'N'
	  INTO    l_change_in_data
          FROM    gcs_cons_impact_analyses
          WHERE   run_name			=	cons_entity_wf_info.prior_run_identifier
	  AND     consolidation_entity_id 	=	cons_entity_wf_info.consolidation_entity
	  AND     child_entity_id		=	oper_entity_wf_info.operating_entity
	  AND	  rownum			<	2;
	ELSE
	  SELECT 	'N'
	  INTO        l_change_in_data
	  FROM        gcs_cons_eng_runs
          WHERE       run_name		=	cons_entity_wf_info.prior_run_identifier
	  AND 	      run_entity_id	=	cons_entity_wf_info.consolidation_entity
	  AND	      impacted_flag	=	'Y';
	END IF;

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CHECK_ADJ_REQUIRED', 'Found an Impact');
        END IF;

	result   := 'COMPLETE:T';
	--Bugfix 3818829 : Must undo all prior eliminations
	l_parameter_list.hierarchy_id		:=	cons_entity_wf_info.consolidation_hierarchy;
	l_parameter_list.balance_type_code	:=	cons_entity_wf_info.balance_type_code;
	l_parameter_list.cal_period_id		:=	cons_entity_wf_info.cal_period_id;

        -- Bugfix 5065553 : Added hierarchy dataset code parameter
        l_parameter_list.hierarchy_dataset_code :=  cons_entity_wf_info.hierarchy_dataset_code;

   	execute_module (module_code                 =>	'UNDO_ELIMINATIONS',
                        p_parameter_list            =>  l_parameter_list,
                        p_item_key                  =>  itemkey);
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    -- Need to copy run details for the prior run
	    result := 'COMPLETE:F';
	    gcs_cons_eng_run_dtls_pkg.copy_prior_run_dtls(
			p_prior_run_name	=>	cons_entity_wf_info.prior_run_identifier,
			p_current_run_name	=>	cons_entity_wf_info.run_identifier,
			p_itemtype		=>	itemtype,
			p_entity_id		=>      l_child_entity_id);
        END;
      ELSIF (cons_entity_wf_info.prior_run_identifier	<>	'NO_PRIOR_RUN') THEN
	--Bugfix 3818829 : Must undo all prior eliminations
	result		:=	'COMPLETE:T';
        l_parameter_list.hierarchy_id           :=      cons_entity_wf_info.consolidation_hierarchy;
        l_parameter_list.balance_type_code      :=      cons_entity_wf_info.balance_type_code;
        l_parameter_list.cal_period_id          :=      cons_entity_wf_info.cal_period_id;

        -- Bugfix 5065553 : Added hierarchy dataset code parameter
        l_parameter_list.hierarchy_dataset_code :=  cons_entity_wf_info.hierarchy_dataset_code;

        execute_module (module_code                 =>  'UNDO_ELIMINATIONS',
                        p_parameter_list            =>  l_parameter_list,
                        p_item_key                  =>  itemkey);
      ELSE
        result	 	:=	'COMPLETE:T';
      END IF;
   END IF;

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CHECK_ADJ_REQUIRED.end', '<<Exit for itemkey : ' || itemkey || ' >>');
   END IF;

  END check_adj_required;

  PROCEDURE category_exists(		itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)

  IS

    l_curr_category_number	NUMBER(15)	:=	    NULL;
    l_max_category_number	NUMBER(15)	:=	    NULL;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CATEGORY_EXISTS.begin', '<<Enter for itemkey : ' || itemkey || ' >>');
    END IF;

    l_curr_category_number	:=	    WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CURR_CATEGORY_NUM', FALSE);
    l_max_category_number	:=	    WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'NUM_OF_CATEGORIES', FALSE);
    l_curr_category_number	:=	    l_curr_category_number + 1;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.CATEGORY_EXISTS', 'Current Category Number 	: ' || l_curr_category_number);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.CATEGORY_EXISTS', 'Max Category Number 	: ' || l_max_category_number);
    END IF;

    IF (l_curr_category_number > l_max_category_number) THEN
       result 	:=  'COMPLETE:F';
    ELSE
      WF_ENGINE.SetItemAttrNumber(itemtype, itemkey, 'CURR_CATEGORY_NUM', l_curr_category_number);
      result	:=  'COMPLETE:T';
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CATEGORY_EXISTS.end', '<<Exit for itemkey : ' || itemkey || ' >>');
    END IF;
  END category_exists;

  PROCEDURE check_max_category(		itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)

  IS
    l_curr_category_number	NUMBER(15)	:=	    NULL;
    l_max_category_number	NUMBER(15)	:=	    NULL;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CHECK_MAX_CATEGORY.begin', '<<Enter for itemkey : ' || itemkey || ' >>');
    END IF;

    l_curr_category_number	:=	    WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CURR_CATEGORY_NUM', FALSE);
    l_max_category_number	:=	    WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'NUM_OF_CATEGORIES', FALSE);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.CHECK_MAX_CATEGORY', 'Current Category Number	:	' || l_curr_category_number);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.CHECK_MAX_CATEGORY', 'Max Category Number	:	' || l_max_category_number);
    END IF;

    IF (l_curr_category_number = l_max_category_number) THEN
       result 	:=  'COMPLETE:F';
    ELSE
      result	:=  'COMPLETE:T';
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CHECK_MAX_CATEGORY.end', '<<Exit for itemkey : ' || itemkey || ' >>');
    END IF;

  END check_max_category;

  PROCEDURE extract_manual_adj(		itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)

  IS

    l_category_code		VARCHAR2(30);
    l_curr_category_number	NUMBER(15);
    l_entity_id			NUMBER(15);
    cons_entity_wf_info		gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
    oper_entity_wf_info		gcs_cons_eng_utility_pkg.r_oper_entity_wf_info;
    l_entry_id			NUMBER(15);
    l_stat_entry_id		NUMBER(15);
    x_errbuf			VARCHAR2(200);
    x_retcode			VARCHAR2(200);
    l_run_detail_id		NUMBER(15);

    -- Bugfix 4272275: Added fix to put correct child_entity_id in gcs_cons_eng_run_dtls
    -- Bugfix 5763719: Modified to fetch even entries with disbled_flag 'Y' (for entries
    -- which are disabled as of a period.

    CURSOR	c_acqdisp_headers	( p_cal_period_id	IN	NUMBER,
					  p_hierarchy_id	IN 	NUMBER,
					  p_entity_id		IN	NUMBER,
					  p_balance_type_code	IN	VARCHAR2)

    IS
  	SELECT	geh.entry_id,
		geh.currency_code,
		geh.process_code,
		geh.period_init_entry_flag,
		gcr.child_entity_id,
		DECODE(geh.suspense_exceeded_flag, 	'Y',
							'WARNING',
							'COMPLETED') request_status
	FROM	gcs_entry_headers	geh,
		gcs_ad_transactions	gad,
		gcs_cons_relationships	gcr
	WHERE	geh.entry_id			=	gad.assoc_entry_id
	AND	gcr.cons_relationship_id	=	NVL(gad.post_cons_relationship_id, gad.pre_cons_relationship_id)
	AND	geh.category_code		=	'ACQ_DISP'
	AND	geh.hierarchy_id		=	p_hierarchy_id
	AND	geh.entity_id			=	p_entity_id
   	AND ( geh.approval_status_code = 'APPROVED' or geh.approval_status_code is NULL)
        AND     geh.balance_type_code           =       p_balance_type_code
        AND     p_cal_period_id  BETWEEN  geh.start_cal_period_id
                                 AND      nvl(disabled_cal_period_id, NVL(geh.end_cal_period_id, p_cal_period_id))
        AND     'N' = DECODE(geh.start_cal_period_id, geh.end_cal_period_id, geh.disabled_flag, 'N');


    -- Bugfix 5763719: Modified to fetch even entries with disbled_flag 'Y' (for entries
    -- which are disabled as of a period.

    -- Bugfix 5974244: Modified condition to insure adjustment is not picked up on disabled period
    -- Modifed nvl(disabled_cal_period_id, to be disabled_cal_period_id - 1

    CURSOR	c_adjustment_headers	( p_cal_period_id	IN	NUMBER,
    					  p_hierarchy_id	IN	NUMBER,
    					  p_entity_id		IN	NUMBER,
    					  p_category_code	IN	VARCHAR2,
					  p_balance_type_code	IN	VARCHAR2)
    IS
    	SELECT	geh.entry_id,
    		geh.currency_code,
    		geh.process_code,
		geh.period_init_entry_flag
    	FROM 	gcs_entry_headers geh
    	WHERE 'MANUAL'	=	DECODE(geh.period_init_entry_flag, 'Y', 'MANUAL', geh.entry_type_code)
--      Bugfix 3718501 : Modified the Join Condition to Extract Automatically Generated A&D Entries
--    	AND     geh.entry_type_code		=  	'MANUAL'		-- Bugfix 3704972 : Extract Only Manual Adjustments
--      Bugfix 3827087 : Modifed the Join Condition to Extract Period Initialization Entries as well
    	AND	geh.category_code		=	p_category_code
    	AND	geh.hierarchy_id		=	p_hierarchy_id
    	AND	geh.entity_id			=	p_entity_id
        AND	geh.balance_type_code		=	p_balance_type_code
    	AND	geh.processed_run_name	IS NULL
    	AND ( geh.approval_status_code = 'APPROVED' or geh.approval_status_code is NULL)
        AND     p_cal_period_id   BETWEEN  geh.start_cal_period_id
                                  AND 	   NVL(disabled_cal_period_id - 1, NVL(geh.end_cal_period_id, p_cal_period_id))
        AND     'N' = DECODE(geh.start_cal_period_id, geh.end_cal_period_id, geh.disabled_flag, 'N');

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.EXTRACT_MANUAL_ADJ.begin', '<<Enter for itemkey : ' || itemkey || ' >>');
    END IF;

   l_curr_category_number	:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CURR_CATEGORY_NUM', FALSE);

   IF (itemtype = 'GCSOPRWF') THEN
     gcs_cons_eng_utility_pkg.get_oper_entity_wf_info (itemtype,
     						       itemkey,
   						       cons_entity_wf_info,
   						       oper_entity_wf_info);
     l_entity_id		:=	oper_entity_wf_info.operating_entity;
     l_category_code		:=	gcs_categories_pkg.g_oper_category_info(l_curr_category_number).category_code;
   ELSE
     gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype,
     						      itemkey,
     						      cons_entity_wf_info);
     l_category_code		:=	gcs_categories_pkg.g_cons_category_info(l_curr_category_number).category_code;
     l_entity_id		:=	cons_entity_wf_info.consolidation_entity;

     -- Bugfix 3870959 : Extract Appropriate Entity based off of Target Entity Code
     IF (gcs_categories_pkg.g_cons_category_info(l_curr_category_number).target_entity_code = 'ELIMINATION') THEN
       SELECT	fea.dim_attribute_numeric_member
       INTO	l_entity_id
       FROM     fem_entities_attr fea
       WHERE	fea.entity_id		=	cons_entity_wf_info.consolidation_entity
       AND	fea.attribute_id	=	gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').attribute_id
       AND	fea.version_id		=	gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').version_id;
     ELSE
       BEGIN
         SELECT   fea.dim_attribute_numeric_member
         INTO     l_entity_id
         FROM     fem_entities_attr fea
         WHERE    fea.entity_id           =       cons_entity_wf_info.consolidation_entity
         AND      fea.attribute_id        =       gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-OPERATING_ENTITY').attribute_id
	 AND	  fea.version_id	  =	  gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-OPERATING_ENTITY').version_id;
       EXCEPTION
	 WHEN OTHERS THEN
	   l_entity_id := -1;
       END;
     END IF;
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.EXTRACT_MANUAL_ADJ', 'Category Code	: '	|| l_category_code);
    END IF;

    IF (l_category_code		=	'ACQ_DISP') THEN

      FOR 	v_acqdisp_headers	IN	c_acqdisp_headers(	cons_entity_wf_info.cal_period_id,
									cons_entity_wf_info.consolidation_hierarchy,
									l_entity_id,
									cons_entity_wf_info.balance_type_code)	LOOP

        GCS_CONS_ENG_RUN_DTLS_PKG.insert_row(p_run_name                 =>      cons_entity_wf_info.run_identifier,
                                             p_consolidation_entity_id  =>      cons_entity_wf_info.consolidation_entity,
                                             p_category_code            =>      'ACQ_DISP',
                                             p_child_entity_id          =>      v_acqdisp_headers.child_entity_id,
                                             p_entry_id                 =>      v_acqdisp_headers.entry_id,
                                             p_stat_entry_id            =>      NULL,
                                             p_cons_relationship_id     =>      -1,
                                             p_request_error_code       =>      v_acqdisp_headers.request_status,
                                             p_bp_request_error_code    =>      v_acqdisp_headers.request_status,
                                             p_run_detail_id            =>      l_run_detail_id);

      END LOOP;

    ELSE

      FOR  	v_adjustment_headers	IN	c_adjustment_headers(	cons_entity_wf_info.cal_period_id,
     									cons_entity_wf_info.consolidation_hierarchy,
    								  	l_entity_id,
    									l_category_code,
									cons_entity_wf_info.balance_type_code)	LOOP
     	l_entry_id		:=	null;
     	l_stat_entry_id		:=	null;

     	IF (v_adjustment_headers.currency_code <> 'STAT') THEN
     	   l_entry_id		:=	v_adjustment_headers.entry_id;
     	ELSE
     	   l_stat_entry_id	:=	v_adjustment_headers.entry_id;
     	END IF;

    	GCS_CONS_ENG_RUN_DTLS_PKG.insert_row(p_run_name			=>	cons_entity_wf_info.run_identifier,
    					     p_consolidation_entity_id	=>	cons_entity_wf_info.consolidation_entity,
    					     p_category_code		=>	l_category_code,
    					     p_child_entity_id		=>	l_entity_id,
    					     p_entry_id			=>	l_entry_id,
    					     p_stat_entry_id		=>	l_stat_entry_id,
    					     p_cons_relationship_id	=>	-1,
					     p_request_error_code	=>	'COMPLETED',
					     p_bp_request_error_code	=>	'COMPLETED',
    					     p_run_detail_id		=>	l_run_detail_id);

	IF 	(v_adjustment_headers.period_init_entry_flag	=	'N') THEN
  	  GCS_INTERCO_DYNAMIC_PKG.Insert_Interco_Trx(p_entry_id		=>	NVL(l_entry_id, -1),
	 			               	     p_stat_entry_id	=>	NVL(l_stat_entry_id, -1),
						     p_hierarchy_id	=>	cons_entity_wf_info.consolidation_hierarchy,
	   -- Bugfix 3800083 : Added Period End Date as a parameter
						     p_period_end_date	=>	cons_entity_wf_info.cal_period_end_date,
						     x_errbuf		=>	x_errbuf,
						     x_retcode		=>	x_retcode);
	END IF;

    	IF	(v_adjustment_headers.process_code		=	'SINGLE_RUN_FOR_PERIOD') THEN
    	   update_entry_headers(cons_entity_wf_info.run_identifier,
    	   			v_adjustment_headers.entry_id);
    	END IF;
      END LOOP;
    END IF;

    result	:=	'COMPLETE';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.EXTRACT_MANUAL_ADJ.end', '<<Enter for itemkey : ' || itemkey || ' >>');
    END IF;

  END extract_manual_adj;

  PROCEDURE check_translation_required(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)

  IS

     cons_entity_wf_info		gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     oper_entity_wf_info		gcs_cons_eng_utility_pkg.r_oper_entity_wf_info;
     l_translation_required		VARCHAR2(1);
     l_xlate_mode			VARCHAR2(30);
     l_rate_change_occurred		VARCHAR2(1);

  BEGIN

   l_translation_required	:=	WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'TRANSLATION_REQUIRED', FALSE);
   l_xlate_mode			:=	WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid, 'TRANSLATION_MODE', FALSE);

   IF (itemtype = 'GCSOPRWF') THEN
     gcs_cons_eng_utility_pkg.get_oper_entity_wf_info (itemtype,
                                                       itemkey,
                                                       cons_entity_wf_info,
                                                       oper_entity_wf_info);
   ELSE
     gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype,
                                                      itemkey,
                                                      cons_entity_wf_info);
   END IF;

   IF (l_translation_required	= 'Y') THEN
     result := 'COMPLETE:T';
   ELSE
     result := 'COMPLETE:F';
   END IF;
  END check_translation_required;


  PROCEDURE execute_translation(	itemtype		IN VARCHAR2,
					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)
  IS

     --STK: Bugfix 5/5/2004 Resolved Issue with Accessing Balance Type Info for Operating Entities
     cons_entity_wf_info	r_cons_entity_wf_info;
     oper_entity_wf_info	r_oper_entity_wf_info;

     l_entry_id			NUMBER(15);
     l_xlate_entry_id		NUMBER(15);
     l_cons_relationship_id	NUMBER(15);
     l_run_detail_id		NUMBER(15);
     l_child_entity_id		NUMBER;
     x_errbuf			VARCHAR2(2000);
     x_retcode			VARCHAR2(2000);
     l_execution_mode		VARCHAR2(30);
     l_balance_type_code	VARCHAR2(30);
     l_parameter_list		gcs_cons_eng_utility_pkg.r_module_parameters;
     l_curr_category_number	NUMBER(15);
     l_category_code		VARCHAR2(30);

     -- Bugfix 3972840 : Remove code to translate adjustment entries

     --Bugfix 5287762: Check if there is data to translate prior to running translation
     l_translation_req_flag     VARCHAR2(1) := 'Y';

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.EXECUTE_TRANSLATION.begin', '<<Enter for itemkey : ' || itemkey || ' >>');
    END IF;

    IF (itemtype = 'GCSOPRWF') THEN
      gcs_cons_eng_utility_pkg.get_oper_entity_wf_info (itemtype,
       						         itemkey,
   						         cons_entity_wf_info,
   						         oper_entity_wf_info);

      l_child_entity_id			:=	oper_entity_wf_info.operating_entity;

    ELSE
      gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype,
     	 					        itemkey,
     						        cons_entity_wf_info);

      l_child_entity_id			:=	cons_entity_wf_info.consolidation_entity;
    END IF;

    l_execution_mode			    :=	WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid, 'EXECUTION_MODE', FALSE);
    l_parameter_list.balance_type_code	    :=	cons_entity_wf_info.balance_type_code;
    l_parameter_list.cal_period_id	    :=	cons_entity_wf_info.cal_period_id;
    -- Bugfix 5017120: Added support for translating additional data types
    l_parameter_list.hierarchy_dataset_code :=  cons_entity_wf_info.hierarchy_dataset_code;
    -- Remove Code to Translate Adjustments
    l_parameter_list.run_detail_id	    :=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'RUN_DETAIL_ID', FALSE);

    IF (itemtype 		=	'GCSOPRWF') THEN
       l_parameter_list.cons_relationship_id	:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CONS_RELATIONSHIP_ID', FALSE);
       l_parameter_list.xlate_mode		:=      cons_entity_wf_info.process_method;

       --Bugfix 5287762: Check to see if any data has been posted for the operational entity
       SELECT   DECODE(count(run_detail_id), 0, 'N', 'Y')
       INTO     l_translation_req_flag
       FROM     gcs_cons_eng_run_dtls
       WHERE    run_name                =        cons_entity_wf_info.run_identifier
       AND      child_entity_id         =        oper_entity_wf_info.operating_entity
       AND      consolidation_entity_id =        cons_entity_wf_info.consolidation_entity
       AND      entry_id                IS NOT   NULL;

    ELSE
       SELECT	cons_relationship_id
       INTO     l_parameter_list.cons_relationship_id
       FROM     gcs_cons_eng_run_dtls
       WHERE    run_detail_id	=	l_parameter_list.run_detail_id;
    END IF;

    SELECT      gcerd.run_detail_id,
		gcs_entry_headers_s.nextval
    INTO        l_parameter_list.run_detail_id,
		l_parameter_list.xlate_entry_id
    FROM        gcs_cons_eng_run_dtls gcerd
    WHERE       gcerd.run_name                  =       cons_entity_wf_info.run_identifier
    AND         gcerd.category_code             =       'TRANSLATION'
    AND         gcerd.child_entity_id           =       l_child_entity_id;

    WF_ENGINE.SetItemAttrNumber(itemtype, itemkey, 'XLATE_ENTRY_ID', l_parameter_list.xlate_entry_id);

    --Bugfix 5287762: Execute translation only if the translation required flag is set to 'Y'

    IF (l_translation_req_flag = 'Y') THEN
      execute_module (	     module_code			=> 'TRANSLATION',
   			     p_parameter_list			=> l_parameter_list,
   			     p_item_key				=> itemkey);
    ELSE
      gcs_cons_eng_run_dtls_pkg.update_entry_headers_async
                     (       p_run_detail_id                => l_parameter_list.run_detail_id,
                             p_request_error_code           => 'NOT_APPLICABLE',
                             p_bp_request_error_code        => 'NOT_APPLICABLE');
    END IF;


    --Bugfix 4874306: Eliminate calls to XML Generation in order to leverage data templates
    --submit_xml_ntf_program(  p_run_name                    	=> cons_entity_wf_info.run_identifier,
    --                         p_cons_entity_id              	=> cons_entity_wf_info.consolidation_entity,
    --                         p_category_code               	=> 'TRANSLATION',
    --                         p_run_detail_id               	=> l_parameter_list.run_detail_id);

    result := 'COMPLETE';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.EXECUTE_TRANSLATION.end', '<<Exit for itemkey : ' || itemkey || ' >>');
    END IF;

  END execute_translation;

  PROCEDURE update_process_status(		itemtype		IN VARCHAR2,
  					        itemkey			IN VARCHAR2,
  					        actid			IN NUMBER,
						funcmode		IN varchar2,
  					        result			IN OUT NOCOPY varchar2)

  IS
     l_category_code			VARCHAR2(30);
     l_curr_category_num		NUMBER(15);
     l_status_code			VARCHAR2(30);
     cons_entity_wf_info		gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     oper_entity_wf_info		gcs_cons_eng_utility_pkg.r_oper_entity_wf_info;

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_PROCESS_STATUS.begin', '<<Enter for itemkey : ' || itemkey || ' >>');
    END IF;

     IF (itemtype = 'GCSOPRWF') THEN
       gcs_cons_eng_utility_pkg.get_oper_entity_wf_info (itemtype,
       						         itemkey,
   						         cons_entity_wf_info,
   						         oper_entity_wf_info);
     ELSE
       gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype,
     	 					        itemkey,
     						        cons_entity_wf_info);
     END IF;

     l_category_code		:=	WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid, 'CATEGORY_CODE', FALSE);
     l_status_code		:=	WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid, 'STATUS_CODE', FALSE);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PROCESS_STATUS', 'Category Code		: ' || l_category_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PROCESS_STATUS', 'Item Type		: ' || itemtype);
    END IF;

     IF (l_category_code	=	'DATAPREPARATION') THEN

       gcs_cons_eng_run_dtls_pkg.update_category_status(
       					p_run_name			=>	cons_entity_wf_info.run_identifier,
       					p_consolidation_entity_id	=>	cons_entity_wf_info.consolidation_entity,
       					p_category_code			=>	l_category_code,
       					p_status			=>	l_status_code);


     ELSIF ((l_category_code	=	'CONS_ADJUSTMENT' AND itemtype	=	'GCSENGNE') OR
	   (itemtype		=	'GCSOPRWF'	  AND l_status_code =   'IN_PROGRESS')) THEN

       l_curr_category_num	:=	WF_Engine.GetItemAttrText(itemtype, itemkey, 'CURR_CATEGORY_NUM', FALSE);
       IF (itemtype		=	'GCSENGNE') THEN
         l_category_code	:=	gcs_categories_pkg.g_cons_category_info(l_curr_category_num).category_code;
       ELSE
	 l_category_code	:=	gcs_categories_pkg.g_oper_category_info(l_curr_category_num).category_code;
       END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PROCESS_STATUS', 'Actual Category Code         : ' || l_category_code);
    END IF;
       gcs_cons_eng_run_dtls_pkg.update_category_status(
       					p_run_name			=>	cons_entity_wf_info.run_identifier,
       					p_consolidation_entity_id	=>	cons_entity_wf_info.consolidation_entity,
       					p_category_code			=>	l_category_code,
       					p_status			=>	l_status_code);

     END IF;

     result	:=	'COMPLETE';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_PROCESS_STATUS', '<<Exit for itemkey : ' || itemkey || ' >>');
    END IF;
  END update_process_status;

  PROCEDURE eliminations_processor(		itemtype		IN VARCHAR2,
  					        itemkey			IN VARCHAR2,
  					        actid			IN NUMBER,
						funcmode		IN varchar2,
  					        result			IN OUT NOCOPY varchar2)

  IS

     cons_entity_wf_info		gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     oper_entity_wf_info		gcs_cons_eng_utility_pkg.r_oper_entity_wf_info;
     x_retcode				VARCHAR2(2000);
     x_errbuf				VARCHAR2(200);
     l_curr_category_num		NUMBER(15);
     l_category_code			VARCHAR2(30);
     l_currency_code			VARCHAR2(30);
     l_entity_id			NUMBER;
     l_elim_mode			VARCHAR2(2);
     l_parameter_list			gcs_cons_eng_utility_pkg.r_module_parameters;
     l_run_detail_id			NUMBER(15);
     l_tgt_entity_id			NUMBER(15);
     l_elim_entity_attr			NUMBER(15)	:=
					gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').attribute_id;
     l_elim_entity_version		NUMBER(15)	:=
					gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').version_id;
     l_oper_entity_attr			NUMBER(15)	:=
					gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-OPERATING_ENTITY').attribute_id;
     l_oper_entity_version		NUMBER(15)	:=
                                        gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-OPERATING_ENTITY').version_id;


     --Bugfix 5017120: Support for additional data types
     l_apply_elim_rules_flag            VARCHAR2(1);
     l_apply_cons_rules_flag            VARCHAR2(1);

     --Bugfix 3873087 : Added cursor to hit operating level adjustments

     CURSOR	c_oper_entity_rules	(p_hierarchy_id		IN NUMBER,
					 p_child_entity_id	IN NUMBER,
					 p_cal_period_end_date	IN DATE,
					 p_category_code	IN VARCHAR2,
					 p_balance_type_code	IN VARCHAR2)
     IS
        SELECT  gcr.parent_entity_id,
                gcr.child_entity_id,
                gcr.cons_relationship_id,
                gerr.rule_id,
                --Bugfix 5017120: Removing gdc.dataset_code from this query to support additional data types
                -1				        elimination_entity_id,
                geca.currency_code,
                gcr.ownership_percent / 100             ownership_percent,
                gcatb.target_entity_code
        FROM    gcs_cons_relationships gcr,
                gcs_entity_cons_attrs  geca,
                gcs_elim_rule_rels     gerr,
                gcs_dataset_codes      gdc,
                gcs_elim_rules_b       grb,
                gcs_categories_b       gcatb
        WHERE   gcr.hierarchy_id                =       p_hierarchy_id
 	AND	gcr.dominant_parent_flag	=	'Y'
        AND     gcr.child_entity_id            =        p_child_entity_id
        AND     gcatb.category_code             =       p_category_code
        AND     grb.transaction_type_code       =       gcatb.category_code
        AND     p_cal_period_end_date           BETWEEN gcr.start_date AND NVL(gcr.end_date, p_cal_period_end_date)
        AND     gcr.child_entity_id             =       geca.entity_id
        AND     gcr.hierarchy_id                =       geca.hierarchy_id
        AND     gcr.treatment_id                =       gerr.treatment_id
        AND     gcr.hierarchy_id                =       gdc.hierarchy_id
        AND     gdc.balance_type_code           =       p_balance_type_code
        AND     gerr.rule_id                    =       grb.rule_id
        AND     grb.enabled_flag                =       'Y';

     CURSOR	c_cons_entity_rules	(p_hierarchy_id		IN NUMBER,
     					 p_cons_entity_id	IN NUMBER,
     					 p_cal_period_end_date	IN DATE,
     					 p_category_code	IN VARCHAR2,
     					 p_balance_type_code	IN VARCHAR2)

     IS
     	SELECT	gcr.parent_entity_id,
     		gcr.child_entity_id,
     		gcr.cons_relationship_id,
     		gerr.rule_id,
                --Bugfix 5017120: Removing gcs.dataset_code from this query to support additional data types
		fea.dim_attribute_numeric_member	elimination_entity_id,
		geca.currency_code,
		gcr.ownership_percent / 100 		ownership_percent,
		gcatb.target_entity_code
     	FROM    gcs_cons_relationships gcr,
     		gcs_entity_cons_attrs  geca,
     		gcs_elim_rule_rels     gerr,
     		gcs_dataset_codes      gdc,
     		fem_entities_attr      fea,
     		gcs_elim_rules_b       grb,
     		gcs_categories_b       gcatb
        WHERE	gcr.hierarchy_id		=	p_hierarchy_id
     	AND	gcr.parent_entity_id		=	p_cons_entity_id
	AND	gcr.dominant_parent_flag	=	'Y'
     	AND     gcatb.category_code		=	p_category_code
     	AND 	grb.transaction_type_code	=	gcatb.category_code
     	AND	p_cal_period_end_date		BETWEEN gcr.start_date AND NVL(gcr.end_date, p_cal_period_end_date)
     	AND	gcr.parent_entity_id		=	geca.entity_id
     	AND	gcr.hierarchy_id		=	geca.hierarchy_id
     	AND	gcr.treatment_id		=	gerr.treatment_id
     	AND	gcr.hierarchy_id		=	gdc.hierarchy_id
     	AND	gdc.balance_type_code		=	p_balance_type_code
     	AND	fea.entity_id			=	gcr.parent_entity_id
     	AND	gerr.rule_id			=	grb.rule_id
     	AND     grb.enabled_flag		=	'Y'
     	AND	fea.attribute_id		=	l_elim_entity_attr
        AND     fea.version_id			=       l_elim_entity_version;

     -- Bugfix 5450725: Modified c_pm_entity_entries for multiple parents filtering

     CURSOR     c_mp_entity_entries     (p_hierarchy_id         IN NUMBER,
                                         p_category_code        IN VARCHAR2,
                                         p_balance_type_code    IN VARCHAR2,
					 p_cal_period_id	IN NUMBER,
					 p_target_entity_id	IN NUMBER)
     IS

        SELECT  gcerd.child_entity_id,
                gcerd.rule_id,
                geh.entry_id
        FROM    gcs_cons_eng_run_dtls   gcerd,
                gcs_entry_headers       geh,
                gcs_cons_eng_runs       gcer
        WHERE   geh.hierarchy_id                       =       p_hierarchy_id
        AND     geh.entity_id                          =       p_target_entity_id
        AND     geh.category_code                      =       p_category_code
        AND     geh.entry_type_code                    =       'MULTIPLE_PARENTS'
        AND     geh.start_cal_period_id                =       p_cal_period_id
        AND     geh.end_cal_period_id                  =       p_cal_period_id
        AND     geh.balance_type_code                  =       p_balance_type_code
        AND     geh.assoc_entry_id                     =       gcerd.entry_id
        AND     gcerd.category_code                    =       p_category_code
        AND     gcerd.consolidation_entity_id          =       gcer.run_entity_id
        AND     gcerd.run_name                         =       gcer.run_name
        AND     gcer.hierarchy_id                      =       p_hierarchy_id
        AND     gcer.cal_period_id                     =       p_cal_period_id
        AND     gcer.most_recent_flag                  =       'Y';

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.ELIMINATIONS_PROCESSOR.begin', '<<Enter Module for item key : ' || itemkey || '>>');
    END IF;
     l_curr_category_num := WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CURR_CATEGORY_NUM', FALSE);

     IF (itemtype = 'GCSOPRWF') THEN
       gcs_cons_eng_utility_pkg.get_oper_entity_wf_info (itemtype,
       						         itemkey,
   						         cons_entity_wf_info,
   						         oper_entity_wf_info);

       l_category_code		:=	gcs_categories_pkg.g_oper_category_info(l_curr_category_num).category_code;
       l_entity_id		:=	oper_entity_wf_info.operating_entity;

     ELSE
       gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype,
     	 					        itemkey,
     						        cons_entity_wf_info);
       l_category_code		:=	gcs_categories_pkg.g_cons_category_info(l_curr_category_num).category_code;
       l_entity_id		:=	cons_entity_wf_info.consolidation_entity;

     END IF;

     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.ELIMINATIONS_PROCESSOR', 'Processing Category Code : ' || l_category_code);
     END IF;

     --Bugfix 5017120: Retrieve the eliminiation rules flag and consolidation rules flag
     SELECT apply_elim_rules_flag,
            apply_cons_rules_flag
     INTO   l_apply_elim_rules_flag,
            l_apply_cons_rules_flag
     FROM   gcs_data_type_codes_b
     WHERE  data_type_code      =       cons_entity_wf_info.balance_type_code;

     IF ((l_apply_elim_rules_flag = 'Y') AND
        ((l_category_code = 'INTERCOMPANY') OR
        (l_category_code = 'INTRACOMPANY'))) THEN

       IF (l_category_code = 'INTERCOMPANY') THEN
         l_elim_mode					:= 'IE';
	 l_parameter_list.bp_post_xlate			:= 'N';
       ELSE
         l_elim_mode					:= 'IA';
         l_parameter_list.bp_post_xlate			:= oper_entity_wf_info.translation_required;
       END IF;

       SELECT 	currency_code
       INTO	l_currency_code
       FROM     gcs_entity_cons_attrs
       WHERE    hierarchy_id		=	cons_entity_wf_info.consolidation_hierarchy
       AND	entity_id		=	l_entity_id;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.ELIMINATIONS_PROCESSOR', 'Parameters for Intercompany Engine');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.ELIMINATIONS_PROCESSOR', 'Consolidation Hierarchy : ' || cons_entity_wf_info.consolidation_hierarchy );
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.ELIMINATIONS_PROCESSOR', 'Calendar Period : ' || cons_entity_wf_info.consolidation_hierarchy );
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.ELIMINATIONS_PROCESSOR', 'Balance Type : ' || cons_entity_wf_info.balance_type_code );
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.ELIMINATIONS_PROCESSOR', 'Entity  Identifier : ' || l_entity_id );
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.ELIMINATIONS_PROCESSOR', 'Elimination Mode : ' || l_elim_mode);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.ELIMINATIONS_PROCESSOR', 'Currency Code : ' || l_currency_code);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.ELIMINATIONS_PROCESSOR', 'Run Name : ' || cons_entity_wf_info.run_identifier);
      END IF;

       l_parameter_list.hierarchy_id		:=	cons_entity_wf_info.consolidation_hierarchy;
       l_parameter_list.cal_period_id		:=	cons_entity_wf_info.cal_period_id;
       l_parameter_list.balance_type_code	:=	cons_entity_wf_info.balance_type_code;
       l_parameter_list.child_entity_id		:=	l_entity_id;
       l_parameter_list.run_name		:=	cons_entity_wf_info.run_identifier;
       l_parameter_list.currency_code		:=	l_currency_code;
       l_parameter_list.intercompany_mode	:=	l_elim_mode;

       execute_module('INTERCOMPANY', l_parameter_list,itemkey);

       --Bugfix 4874306: Eliminate calls to XML Generation in order to leverage data templates
       --IF (l_elim_mode		=	'IA') THEN
       --Bugfix 4874306: Eliminate calls to XML Generation in order to leverage data templates
       --submit_xml_ntf_program(p_run_name                         => cons_entity_wf_info.run_identifier,
       --                       p_cons_entity_id                   => cons_entity_wf_info.consolidation_entity,
       --                       p_category_code                    => 'INTRACOMPANY',
       --                       p_child_entity_id                  => l_parameter_list.child_entity_id);
       --ELSE
       --Bugfix 4874306: Eliminate calls to XML Generation in order to leverage data templates
       --submit_xml_ntf_program(p_run_name                         => cons_entity_wf_info.run_identifier,
       --                       p_cons_entity_id                   => cons_entity_wf_info.consolidation_entity,
       --                       p_category_code                    => 'INTERCOMPANY');
       --END IF;

--  Bugfix 3873087 : Added code to support operating entity levle rules
     ELSIF (itemtype = 'GCSOPRWF') AND
           (l_apply_cons_rules_flag = 'Y') THEN -- Process Operating Entity Level Rules

       FOR v_oper_entity_rules IN      c_oper_entity_rules     ( cons_entity_wf_info.consolidation_hierarchy,
                                                                 oper_entity_wf_info.operating_entity,
                                                                 cons_entity_wf_info.cal_period_end_date,
                                                                 l_category_code,
                                                                 cons_entity_wf_info.balance_type_code)
        LOOP
          l_parameter_list.rp_parameters.parentEntity     := v_oper_entity_rules.parent_entity_id;

          GCS_CONS_ENG_RUN_DTLS_PKG.insert_row(p_run_name                       =>      cons_entity_wf_info.run_identifier,
                                               p_consolidation_entity_id        =>      cons_entity_wf_info.consolidation_entity,
                                               p_category_code                  =>      l_category_code,
                                               p_child_entity_id                =>      v_oper_entity_rules.child_entity_id,
                                               p_rule_id                        =>      v_oper_entity_rules.rule_id,
                                               p_cons_relationship_id           =>      v_oper_entity_rules.cons_relationship_id,
                                               p_run_detail_id                  =>      l_run_detail_id);


          l_parameter_list.rp_parameters.eventCategory    := l_category_code;
          l_parameter_list.rp_parameters.hierarchy        := cons_entity_wf_info.consolidation_hierarchy;
          --Bugfix 5017120: Modified dataset code assignments
          l_parameter_list.rp_parameters.datasetCode      := cons_entity_wf_info.hierarchy_dataset_code;
          l_parameter_list.rp_parameters.calPeriodId      := cons_entity_wf_info.cal_period_id;
          l_parameter_list.rp_parameters.calPeriodEndDate := cons_entity_wf_info.cal_period_end_date;
          l_parameter_list.rp_parameters.childEntity      := v_oper_entity_rules.child_entity_id;
          l_parameter_list.rp_parameters.elimsEntity      := v_oper_entity_rules.elimination_entity_id;
          l_parameter_list.rp_parameters.currencyCode     := v_oper_entity_rules.currency_code;
          l_parameter_list.rp_parameters.eventType        := 'C';
          l_parameter_list.rp_parameters.relationship     := v_oper_entity_rules.cons_relationship_id;
	  l_parameter_list.rp_parameters.runName	  := cons_entity_wf_info.run_identifier;
          l_parameter_list.elim_rule_id                   := v_oper_entity_rules.rule_id;
          l_parameter_list.rp_parameters.eventKey         := l_run_detail_id;
          l_parameter_list.rp_rule_data.toPercent         := v_oper_entity_rules.ownership_percent;
          --Bugfix 5103251: Added balance type parameter
          l_parameter_list.rp_parameters.balanceTypeCode  := cons_entity_wf_info.balance_type_code;

          execute_module('RULES_PROCESSOR', l_parameter_list, itemkey);
        END LOOP;

        --Bugfix 4874306: Eliminate calls to XML Generation in order to leverage data templates
        --submit_xml_ntf_program(p_run_name                         => cons_entity_wf_info.run_identifier,
        --                       p_cons_entity_id                   => cons_entity_wf_info.consolidation_entity,
        --                       p_category_code                    => l_category_code,
        --                       p_child_entity_id                  => oper_entity_wf_info.operating_entity);

     ELSIF (itemtype = 'GCSENGNE' AND
            l_category_code <> 'ACQ_DISP' AND
            l_apply_cons_rules_flag = 'Y') THEN -- Process Consolidation Level Rules

     	FOR v_cons_entity_rules IN	c_cons_entity_rules	(cons_entity_wf_info.consolidation_hierarchy,
     					 			 cons_entity_wf_info.consolidation_entity,
     					 			 cons_entity_wf_info.cal_period_end_date,
     					 			 l_category_code,
     					 			 cons_entity_wf_info.balance_type_code)
        LOOP
          BEGIN

	  IF (v_cons_entity_rules.target_entity_code = 'ELIMINATION') THEN
	    BEGIN
              SELECT dim_attribute_numeric_member
              INTO   l_parameter_list.rp_parameters.parentEntity
              FROM   fem_entities_attr
              WHERE  entity_id            =       v_cons_entity_rules.parent_entity_id
              AND    attribute_id         =       l_oper_entity_attr
	      AND    version_id		  = 	  l_oper_entity_version;
 	    EXCEPTION
	      WHEN OTHERS THEN
		l_parameter_list.rp_parameters.parentEntity	:= v_cons_entity_rules.parent_entity_id;
	    END;
	  ELSIF (v_cons_entity_rules.target_entity_code = 'PARENT') THEN
	    SELECT dim_attribute_numeric_member
	    INTO   l_parameter_list.rp_parameters.parentEntity
	    FROM   fem_entities_attr
	    WHERE  entity_id		=	v_cons_entity_rules.parent_entity_id
	    AND    attribute_id		=	l_oper_entity_attr
	    AND	   version_id		=	l_oper_entity_version;
	  END IF;

       	  GCS_CONS_ENG_RUN_DTLS_PKG.insert_row(p_run_name			=>	cons_entity_wf_info.run_identifier,
    					       p_consolidation_entity_id	=>	cons_entity_wf_info.consolidation_entity,
    					       p_category_code			=>	l_category_code,
    					       p_child_entity_id		=>	v_cons_entity_rules.child_entity_id,
    					       p_rule_id			=>	v_cons_entity_rules.rule_id,
    					       p_cons_relationship_id		=>	v_cons_entity_rules.cons_relationship_id,
    					       p_run_detail_id			=>	l_run_detail_id);


          l_parameter_list.rp_parameters.eventCategory 	  := l_category_code;
          l_parameter_list.rp_parameters.hierarchy     	  := cons_entity_wf_info.consolidation_hierarchy;
          --Bugfix 5017120: Changing assignment of dataset code to support multiple data types
          l_parameter_list.rp_parameters.datasetCode   	  := cons_entity_wf_info.hierarchy_dataset_code;
          l_parameter_list.rp_parameters.calPeriodId   	  := cons_entity_wf_info.cal_period_id;
          l_parameter_list.rp_parameters.calPeriodEndDate := cons_entity_wf_info.cal_period_end_date;
          l_parameter_list.rp_parameters.childEntity	  := v_cons_entity_rules.child_entity_id;
          l_parameter_list.rp_parameters.elimsEntity	  := v_cons_entity_rules.elimination_entity_id;
          l_parameter_list.rp_parameters.currencyCode	  := v_cons_entity_rules.currency_code;
          l_parameter_list.rp_parameters.eventType	  := 'C';
          l_parameter_list.rp_parameters.relationship	  := v_cons_entity_rules.cons_relationship_id;
          l_parameter_list.elim_rule_id			  := v_cons_entity_rules.rule_id;
	  l_parameter_list.rp_parameters.eventKey	  := l_run_detail_id;
       	  l_parameter_list.rp_rule_data.toPercent	  := v_cons_entity_rules.ownership_percent;
          l_parameter_list.rp_parameters.runName          := cons_entity_wf_info.run_identifier;
          --Bugfix 5103251: Added balance type parameter
          l_parameter_list.rp_parameters.balanceTypeCode  := cons_entity_wf_info.balance_type_code;

          execute_module('RULES_PROCESSOR', l_parameter_list, itemkey);

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             -- no operating entity was found, therefore, equity pick-up rule is just skipped
	     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL	<=	FND_LOG.LEVEL_PROCEDURE) THEN
	       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.ELIMINATIONS_PROCESSOR', SQLERRM);
             END IF;
             null;
         END;
        END LOOP;

	--Bugfix 4122843: Special Code to Handle Multiple Parent Entries
	IF (gcs_categories_pkg.g_cons_category_info(l_curr_category_num).support_multi_parents_flag	=	'Y'	) THEN
	  BEGIN
	    IF (gcs_categories_pkg.g_cons_category_info(l_curr_category_num).target_entity_code		=	'ELIMINATION') THEN
	      SELECT 	dim_attribute_numeric_member
	      INTO	l_tgt_entity_id
              FROM	fem_entities_attr
	      WHERE	entity_id		=	cons_entity_wf_info.consolidation_entity
	      AND	attribute_id		=	l_elim_entity_attr
	      AND	version_id		=	l_elim_entity_version;
	    ELSE
	      SELECT	dim_attribute_numeric_member
              INTO      l_tgt_entity_id
              FROM      fem_entities_attr
              WHERE     entity_id               =       cons_entity_wf_info.consolidation_entity
              AND       attribute_id            =       l_oper_entity_attr
              AND       version_id              =       l_oper_entity_version;
	    END IF;

            --Bugfix 5450725: Modified parameters passes to v_mp_entries

	    FOR v_mp_entries	IN	c_mp_entity_entries(
							cons_entity_wf_info.consolidation_hierarchy,
							l_category_code,
							cons_entity_wf_info.balance_type_code,
							cons_entity_wf_info.cal_period_id,
							l_tgt_entity_id)
   	    LOOP

              GCS_CONS_ENG_RUN_DTLS_PKG.insert_row(	p_run_name                       =>      cons_entity_wf_info.run_identifier,
                                               		p_consolidation_entity_id        =>      cons_entity_wf_info.consolidation_entity,
                                               		p_category_code                  =>      l_category_code,
                                               		p_child_entity_id                =>      v_mp_entries.child_entity_id,
                                               		p_rule_id                        =>      v_mp_entries.rule_id,
							p_request_error_code		 =>	'COMPLETED',
							p_bp_request_error_code		 => 	'COMPLETED',
							p_entry_id			 =>	v_mp_entries.entry_id,
							p_run_detail_id			 =>	l_run_detail_id);
	    END LOOP;
	  EXCEPTION
	    WHEN OTHERS THEN
	      NULL;
          END;
        END IF;

	--Bugfix 4874306: Eliminate calls to XML Generation in order to leverage data templates
        --submit_xml_ntf_program(p_run_name                         => cons_entity_wf_info.run_identifier,
        --                       p_cons_entity_id                   => cons_entity_wf_info.consolidation_entity,
        --                       p_category_code                    => l_category_code);

     END IF;

     result	:=	'COMPLETE';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.ELIMINATIONS_PROCESSOR.end', '<<End Module>>');
    END IF;

  END eliminations_processor;

  PROCEDURE create_initializing_journal(	itemtype		IN VARCHAR2,
  						itemkey			IN VARCHAR2,
  						actid			IN NUMBER,
  						funcmode		IN varchar2,
  						result			IN OUT NOCOPY varchar2)


  IS
     cons_entity_wf_info		gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     oper_entity_wf_info		gcs_cons_eng_utility_pkg.r_oper_entity_wf_info;
     x_retcode				VARCHAR2(2000);
     x_errbuf				VARCHAR2(200);
     l_entity_id			NUMBER;
     l_init_required			VARCHAR2(1);
     l_parameter_list			gcs_cons_eng_utility_pkg.r_module_parameters;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CREATE_INITIALIZING_JOURNAL.begin', '<<Enter for item key : ' || itemkey || '>>');
    END IF;

     IF (itemtype = 'GCSOPRWF') THEN
       gcs_cons_eng_utility_pkg.get_oper_entity_wf_info (itemtype,
       						         itemkey,
   						         cons_entity_wf_info,
   						         oper_entity_wf_info);

       l_entity_id				:=	oper_entity_wf_info.operating_entity;
       l_parameter_list.cons_relationship_id	:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CONS_RELATIONSHIP_ID', FALSE);
       --Bugfix 3922840 : We no longer need to create period initialization entries for Translated Results
       l_parameter_list.bp_post_xlate		:=	'N';

       SELECT 'Y'
       INTO   l_init_required
       FROM   gcs_cons_eng_run_dtls
       WHERE  run_name 			= 	cons_entity_wf_info.run_identifier
       AND    consolidation_entity_id	=	cons_entity_wf_info.consolidation_entity
       AND    child_entity_id		=	l_entity_id
       AND    category_code		NOT IN ('DATAPREPARATION')
       AND    ROWNUM 			< 	2;


     ELSE
       gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype,
     	 					        itemkey,
     						        cons_entity_wf_info);
       l_parameter_list.bp_post_xlate		:=	'N';

       SELECT dim_attribute_numeric_member
       INTO   l_entity_id
       FROM   fem_entities_attr
       WHERE  entity_id		=	cons_entity_wf_info.consolidation_entity
       AND    attribute_id	=	gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').attribute_id
       AND    version_id	=       gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').version_id;

       SELECT 'Y'
       INTO   l_init_required
       FROM   gcs_cons_eng_run_dtls
       WHERE  run_name 			= 	cons_entity_wf_info.run_identifier
       AND    consolidation_entity_id	=	cons_entity_wf_info.consolidation_entity
       AND    child_entity_id		IS NOT NULL
       AND    category_code		NOT IN ('AGGREGATION')
       AND    ROWNUM 			< 	2;

       SELECT cons_relationship_id
       INTO   l_parameter_list.cons_relationship_id
       FROM   gcs_cons_relationships
       WHERE  hierarchy_id				=	cons_entity_wf_info.consolidation_hierarchy
       AND    dominant_parent_flag			=	'Y'
       AND    child_entity_id				=	l_entity_id
       AND    cons_entity_wf_info.cal_period_end_date	BETWEEN	start_date AND NVL(end_date, cons_entity_wf_info.cal_period_end_date);

     END IF;

     IF (l_init_required = 'Y') THEN

          l_parameter_list.run_name		:=	cons_entity_wf_info.run_identifier;
          l_parameter_list.hierarchy_id		:=	cons_entity_wf_info.consolidation_hierarchy;
	  l_parameter_list.cons_entity_id	:=	cons_entity_wf_info.consolidation_entity;
          l_parameter_list.child_entity_id	:=	l_entity_id;
          l_parameter_list.cal_period_id	:=	cons_entity_wf_info.cal_period_id;
          l_parameter_list.balance_type_code	:=	cons_entity_wf_info.balance_type_code;

          execute_module('PERIOD_INITIALIZATION', l_parameter_list,itemkey);

    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CREATE_INITIALIZING_JOURNAL.end', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

    result := 'COMPLETE';
  EXCEPTION
    WHEN OTHERS THEN
      result := 'COMPLETE';
  END create_initializing_journal;

END GCS_CONS_ENG_UTILITY_PKG;


/
