--------------------------------------------------------
--  DDL for Package Body GCS_CONS_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_CONS_ENGINE_PKG" as
/* $Header: gcs_eng_wfb.pls 120.12 2007/12/13 11:50:10 cdesouza noship $ */

  -- Declaration of package body global variables

     g_api			VARCHAR2(200)	:=	'gcs.plsql.GCS_CONS_ENGINE_PKG';
     g_cons_item_type		VARCHAR2(200)	:=	'GCSENGNE';
     g_cons_entity_process	VARCHAR2(200)	:=	'CONS_ENTITY_PROCESS';
     g_oper_item_type		VARCHAR2(200)	:=	'GCSOPRWF';
     g_oper_entity_process	VARCHAR2(200)	:=	'OPER_ENTITY_PROCESS';
     g_entity_type_attr		NUMBER(15)	:=	gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').attribute_id;
     g_entity_type_version	NUMBER(15)	:=      gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').version_id;
     g_source_system_attr	NUMBER(15)	:=	gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-SOURCE_SYSTEM_CODE').attribute_id;
     g_end_date_attr		NUMBER(15)	:=	gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').attribute_id;

  -- End of package body global variables


  -- bugfix 5569522: p_analysis_cycle_id will also be passed from raise_completion_event
  -- procedure.
  PROCEDURE submit_epb_data_transfer(	p_hierarchy_id         	IN NUMBER,
					p_balance_type_code	IN VARCHAR2,
                                      	p_cal_period_id      IN NUMBER,
                                        p_analysis_cycle_id  IN NUMBER )
  IS PRAGMA AUTONOMOUS_TRANSACTION;


   l_request_id NUMBER(15);
   -- Bugfix 5187689: Only call data transfer if Analytical Reporting Step is complete
   l_table_name VARCHAR2(30);
   l_conc_request_status BOOLEAN;

   BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_EPB_DATA_TRANSFER.begin', '<<Enter>>');
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_EPB_DATA_TRANSFER', 'Hierarchy           :  ' || p_hierarchy_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_EPB_DATA_TRANSFER', 'Consoliation Entity :  ' || p_cal_period_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_EPB_DATA_TRANSFER', 'Analysis Cycle ID: ' ||  p_analysis_cycle_id);
    END IF;

    -- Bugfix 5187689: Make sure the table has been selected before submitting the program
    SELECT epb_table_name
    INTO   l_table_name
    FROM   gcs_system_options;

    IF (l_table_name IS NOT NULL) THEN
      -- bugfix 5569522: Added the analysis_cycle_id as an argument to the concurrent
      -- request.
      l_request_id :=     fnd_request.submit_request(
                                        application     => 'GCS',
                                        program         => 'FCH_DATA_TRANSFER',
                                        sub_request     => FALSE,
                                        argument1       => p_hierarchy_id,
                                        argument2       => p_balance_type_code,
                                        argument3       => p_cal_period_id,
                                        argument4       => p_analysis_cycle_id);

    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_EPB_DATA_TRANSFER.end', '<<Exit>>');
    END IF;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE prepare_immediate_children(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)
  IS

     l_entities_to_process		VARCHAR2(30)	:= 'FALSE';
     cons_entity_wf_info		gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     l_xlate_entry_id			NUMBER(15);
     l_run_detail_id			NUMBER(15);
     l_xlate_request_error_code		VARCHAR2(30);
     l_bp_xlate_request_error_code	VARCHAR2(30);

     CURSOR c_immediate_children (p_hierarchy_id 	IN NUMBER,
     				  p_entity_id	 	IN NUMBER,
     				  p_cal_period_end_date IN DATE) IS
     	SELECT	gcr.child_entity_id,
     		gcr.cons_relationship_id,
     		geca_child.currency_code		child_currency_code,
     		geca_parent.currency_code		parent_currency_code,
     		fea.dim_attribute_varchar_member	entity_type_code
     	FROM    gcs_cons_relationships gcr,
     		fem_entities_attr      fea,
     		gcs_entity_cons_attrs  geca_child,
     		gcs_entity_cons_attrs  geca_parent
     	WHERE   gcr.hierarchy_id		=	p_hierarchy_id
     	AND     gcr.parent_entity_id		=	p_entity_id
     	AND     geca_child.hierarchy_id		=	p_hierarchy_id
     	AND	geca_child.entity_id		=	gcr.child_entity_id
 	AND	gcr.dominant_parent_flag	=	'Y'
     	AND	geca_parent.hierarchy_id	=	p_hierarchy_id
     	AND	geca_parent.entity_id		=	gcr.parent_entity_id
     	AND	p_cal_period_end_date		BETWEEN	gcr.start_date and NVL(end_date,to_date(p_cal_period_end_date,'DD-MM-RR'))
     	AND     gcr.child_entity_id		=	fea.entity_id
     	AND     fea.attribute_id		=	g_entity_type_attr
        AND	fea.version_id			=	g_entity_type_version
     	AND     fea.dim_attribute_varchar_member	IN	('O','X','C');

     CURSOR c_oper_entity_child	(p_hierarchy_id		IN NUMBER,
				 p_entity_id		IN NUMBER,
				 p_cal_period_end_date	IN DATE) IS
        SELECT  gcr.child_entity_id,
                gcr.cons_relationship_id,
                geca_child.currency_code                child_currency_code,
                geca_parent.currency_code               parent_currency_code
        FROM    gcs_cons_relationships gcr,
                gcs_entity_cons_attrs  geca_child,
                gcs_entity_cons_attrs  geca_parent,
		fem_entities_attr      fea
        WHERE   gcr.hierarchy_id                =       p_hierarchy_id
        AND     gcr.parent_entity_id            =       p_entity_id
        AND     geca_child.hierarchy_id         =       p_hierarchy_id
        AND     geca_child.entity_id            =       gcr.child_entity_id
        AND     gcr.dominant_parent_flag        =       'Y'
        AND     geca_parent.hierarchy_id        =       p_hierarchy_id
        AND     geca_parent.entity_id           =       gcr.parent_entity_id
	AND	gcr.child_entity_id		=	fea.entity_id
	AND	fea.attribute_id		=	g_entity_type_attr
	AND	fea.version_id			=	g_entity_type_version
	AND	fea.dim_attribute_varchar_member	IN	('O','X')
        AND     p_cal_period_end_date           BETWEEN gcr.start_date and NVL(end_date,to_date(p_cal_period_end_date,'DD-MM-RR'));

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PREPARE_IMMEDIATE_CHILDREN.begin', '<<Enter for item key : ' || itemkey || '>>');
    END IF;

     gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype, itemkey, cons_entity_wf_info);

     FOR v_immediate_children IN c_immediate_children(cons_entity_wf_info.consolidation_hierarchy,
     						      cons_entity_wf_info.consolidation_entity,
     						      cons_entity_wf_info.cal_period_end_date)
     LOOP
       l_xlate_request_error_code  	:=	'NOT_STARTED';

       IF (v_immediate_children.parent_currency_code = v_immediate_children.child_currency_code) THEN
     	    l_xlate_request_error_code		:=	'NOT_APPLICABLE';
       END IF;

    	gcs_cons_eng_run_dtls_pkg.insert_row(p_run_name			=>	cons_entity_wf_info.run_identifier,
    					     p_consolidation_entity_id	=>	cons_entity_wf_info.consolidation_entity,
    					     p_category_code		=>	'DATAPREPARATION',
    					     p_child_entity_id		=>	v_immediate_children.child_entity_id,
    					     p_entry_id			=>	NULL,
    					     p_stat_entry_id		=>	null,
    					     p_cons_relationship_id	=>	v_immediate_children.cons_relationship_id,
    					     p_run_detail_id		=>	l_run_detail_id,
    					     p_request_error_code	=>	'NOT_STARTED',
    					     p_bp_request_error_code	=>	'NOT_STARTED');

        IF (l_xlate_request_error_code	=	'NOT_STARTED') THEN
          gcs_cons_eng_run_dtls_pkg.insert_row(p_run_name                 =>      cons_entity_wf_info.run_identifier,
                                               p_consolidation_entity_id  =>      cons_entity_wf_info.consolidation_entity,
                                               p_category_code            =>      'TRANSLATION',
                                               p_child_entity_id          =>      v_immediate_children.child_entity_id,
                                               p_entry_id                 =>      NULL,
                                               p_stat_entry_id            =>      null,
                                               p_cons_relationship_id     =>      v_immediate_children.cons_relationship_id,
                                               p_run_detail_id            =>      l_run_detail_id,
                                               p_request_error_code       =>      l_xlate_request_error_code,
                                               p_bp_request_error_code    =>      l_xlate_request_error_code);
        END IF;

	IF (v_immediate_children.entity_type_code IN ('O', 'X')) THEN
          -- Bugfix 4122843 : Support for Operating Entities Owning Other Operating Entities
          FOR v_oper_entity IN c_oper_entity_child (cons_entity_wf_info.consolidation_hierarchy,
						          v_immediate_children.child_entity_id,
						          cons_entity_wf_info.cal_period_end_date)
          LOOP

	   l_xlate_request_error_code		:=	'NOT_STARTED';

           IF (v_oper_entity.child_currency_code	= v_immediate_children.child_currency_code) THEN
   	      l_xlate_request_error_code		:=	'NOT_APPLICABLE';
	   END IF;

           gcs_cons_eng_run_dtls_pkg.insert_row(p_run_name                 =>      cons_entity_wf_info.run_identifier,
                                                p_consolidation_entity_id  =>      cons_entity_wf_info.consolidation_entity,
                                                p_category_code            =>      'DATAPREPARATION',
                                                p_child_entity_id          =>      v_oper_entity.child_entity_id,
                                                p_cons_relationship_id     =>      v_oper_entity.cons_relationship_id,
                                                p_run_detail_id            =>      l_run_detail_id,
                                                p_request_error_code       =>      'NOT_STARTED',
                                                p_bp_request_error_code    =>      'NOT_STARTED');

           IF (l_xlate_request_error_code  =       'NOT_STARTED') THEN
             gcs_cons_eng_run_dtls_pkg.insert_row(p_run_name                 =>      cons_entity_wf_info.run_identifier,
                                                  p_consolidation_entity_id  =>      cons_entity_wf_info.consolidation_entity,
                                                  p_category_code            =>      'TRANSLATION',
                                                  p_child_entity_id          =>      v_oper_entity.child_entity_id,
                                                  p_cons_relationship_id     =>      v_oper_entity.cons_relationship_id,
                                                  p_run_detail_id            =>      l_run_detail_id,
                                                  p_request_error_code       =>      l_xlate_request_error_code,
                                                  p_bp_request_error_code    =>      l_xlate_request_error_code);
	    END IF;
          END LOOP;
        END IF;

     END LOOP;

     result := 'COMPLETE';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PREPARE_IMMEDIATE_CHILDREN.end', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

  END prepare_immediate_children;

  PROCEDURE spawn_oper_entity_process(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)

  IS

     TYPE t_childkey_list	IS TABLE OF VARCHAR2(200);

     l_childkey_list		t_childkey_list := t_childkey_list(null);
     l_child_key		VARCHAR2(200);
     counter			NUMBER(15)	:= 0;
     l_entities_to_process	BOOLEAN		:= FALSE;
     cons_entity_wf_info	gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     l_workflow_item_key	VARCHAR2(200);
     l_translated_required	VARCHAR2(1);

     CURSOR c_operating_entities (p_run_name 		IN VARCHAR2,
     				  p_cons_entity_id	IN NUMBER) IS
     	SELECT	gcerd.child_entity_id,
     		gcerd.cons_relationship_id,
     		gcerd.run_detail_id,
     		fev.entity_name,
		DECODE(geca_parent.currency_code, geca_child.currency_code, 'N', 'Y') translation_required
     	FROM    gcs_cons_eng_run_dtls  	gcerd,
     		fem_entities_attr	fea,
     		fem_entities_vl		fev,
		gcs_entity_cons_attrs	geca_parent,
		gcs_entity_cons_attrs	geca_child,
		gcs_cons_eng_runs	gcer
     	WHERE   gcerd.run_name			=	p_run_name
     	AND	gcerd.consolidation_entity_id	=	p_cons_entity_id
     	AND     gcerd.entry_id			IS NULL
     	AND	gcerd.category_code 		=	'DATAPREPARATION'
     	AND	gcerd.child_entity_id		=	fev.entity_id
     	AND     gcerd.child_entity_id		=	fea.entity_id
     	AND     fea.attribute_id		=	g_entity_type_attr
        AND	fea.version_id			=	g_entity_type_version
     	AND     fea.dim_attribute_varchar_member	IN	('O','X')
	AND	geca_parent.entity_id		=	p_cons_entity_id
	AND	geca_child.entity_id		=	fev.entity_id
	AND	geca_parent.hierarchy_id	=	geca_child.hierarchy_id
	AND	gcer.hierarchy_id		=	geca_child.hierarchy_id
	AND	gcer.run_name			=	gcerd.run_name
	ANd	gcer.run_entity_id		=	gcerd.consolidation_entity_id;

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SPAWN_OPER_ENTITY_PROCESS', '<<Enter for item key : ' || itemkey || '>>');
    END IF;

     gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype, itemkey, cons_entity_wf_info);

     FOR v_operating_entity IN c_operating_entities(cons_entity_wf_info.run_identifier, cons_entity_wf_info.consolidation_entity)
     LOOP

     	counter := counter + 1;
     	l_child_key	:=	v_operating_entity.entity_name || ' (' || cons_entity_wf_info.request_id || ')';

     	l_childkey_list.extend(1);
     	l_childkey_list(counter) := l_child_key;

        --Bugfix 5197891: Assign appropriate user rather than null value
  	WF_ENGINE.CreateProcess(g_oper_item_type, l_childkey_list(counter), g_oper_entity_process, l_childkey_list(counter), FND_GLOBAL.USER_NAME);
	WF_ENGINE.SetItemAttrNumber(g_oper_item_type, l_childkey_list(counter), 'OPER_ENTITY', v_operating_entity.child_entity_id);
	WF_ENGINE.SetItemAttrNumber(g_oper_item_type, l_childkey_list(counter), 'RUN_DETAIL_ID', v_operating_entity.run_detail_id);
	WF_ENGINE.SetItemAttrNumber(g_oper_item_type, l_childkey_list(counter), 'CONS_RELATIONSHIP_ID', v_operating_entity.cons_relationship_id);
	WF_ENGINE.SetItemAttrText(g_oper_item_type, l_childkey_list(counter), 'PARENT_WORKFLOW_KEY', itemkey);
	WF_ENGINE.SetItemAttrText(g_oper_item_type, l_childkey_list(counter), 'TRANSLATION_REQUIRED', v_operating_entity.translation_required);
  	WF_ENGINE.Set_Item_Parent(g_oper_item_type, l_childkey_list(counter), itemtype, itemkey,'WAITFORFLOW');
     END LOOP;

     WHILE (counter > 0)
     LOOP
        l_entities_to_process := TRUE;
	WF_ENGINE.StartProcess(g_oper_item_type, l_childkey_list(counter));

	counter := counter - 1;

     END LOOP;

     IF (l_entities_to_process) THEN
       result := 'COMPLETE:T';
     ELSE
       result := 'COMPLETE:F';
     END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SPAWN_OPER_ENTITY_PROCESS.end', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

  END spawn_oper_entity_process;

  PROCEDURE execute_data_preparation(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)
  IS

     x_errbuf			VARCHAR2(2000);
     x_retcode			VARCHAR2(2000);
     l_execution_mode		VARCHAR2(30)	:=	'FULL';
     cons_entity_wf_info	gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     oper_entity_wf_info	gcs_cons_eng_utility_pkg.r_oper_entity_wf_info;
     l_data_exists_flag		VARCHAR2(1)	:=	'N';
     l_entry_id			NUMBER(15);
     l_stat_entry_id		NUMBER(15);
     l_parameter_list		gcs_cons_eng_utility_pkg.r_module_parameters;
     l_request_error_code	VARCHAR2(2000);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.EXECUTE_DATA_PREPARATION', '<<Enter for item key : ' || itemkey || '>>');
    END IF;


   l_execution_mode	:=	WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid, 'EXECUTION_MODE', FALSE);


   gcs_cons_eng_utility_pkg.get_oper_entity_wf_info (itemtype,
   						     itemkey,
   						     cons_entity_wf_info,
   						     oper_entity_wf_info);

   IF (l_execution_mode		=	'FULL') THEN

     -- Bugfix 3750740 : Remove Check to See if Data Exists to Support Calendar Mapping (Dataprep already does this check)

     l_parameter_list.hierarchy_id		:=	cons_entity_wf_info.consolidation_hierarchy;
     l_parameter_list.child_entity_id		:=	oper_entity_wf_info.operating_entity;
     l_parameter_list.cal_period_id		:=	cons_entity_wf_info.cal_period_id;
     l_parameter_list.run_detail_id		:=	oper_entity_wf_info.run_detail_id;
     l_parameter_list.cons_relationship_id	:=	oper_entity_wf_info.cons_relationship_id;
     l_parameter_list.balance_type_code		:=	cons_entity_wf_info.balance_type_code;
     --Bugfix 5017120: Added support for additional data types
     l_parameter_list.source_dataset_code       :=      cons_entity_wf_info.source_dataset_code;

     gcs_cons_eng_utility_pkg.execute_module (  module_code		=> 'DATAPREPARATION',
   			     	 		p_parameter_list	=> l_parameter_list,
   			     	 		p_item_key		=> itemkey);


     SELECT entry_id, stat_entry_id
     INTO   l_entry_id, l_stat_entry_id
     FROM   gcs_cons_eng_run_dtls
     WHERE  run_detail_id	=	oper_entity_wf_info.run_detail_id;

     --Bugfix 3666700: Added code to insert into intercompany temporary table
     gcs_interco_dynamic_pkg.insert_interco_trx(    p_entry_id		=>	l_entry_id,
	 				            p_stat_entry_id	=>	NVL(l_stat_entry_id, -1),
						    p_hierarchy_id	=>	l_parameter_list.hierarchy_id,
						    p_period_end_date	=>	cons_entity_wf_info.cal_period_end_date,
						    x_errbuf		=>	l_parameter_list.errbuf,
						    x_retcode		=>	l_parameter_list.retcode);
     IF (l_parameter_list.errbuf IS NULL) THEN
       result := 'COMPLETE:T';
       --Bugfix 4874306: Eliminate calls to XML Generation in order to leverage data templates
       --gcs_cons_eng_utility_pkg.submit_xml_ntf_program( p_run_name     		=> 	cons_entity_wf_info.run_identifier,
       --                             			  p_cons_entity_id              =>	cons_entity_wf_info.consolidation_entity,
       --						  p_category_code		=>	'DATAPREPARATION',
       --						  p_run_detail_id		=>	oper_entity_wf_info.run_detail_id);
     ELSE
       result := 'COMPLETE:F';
     END IF;

   ELSE -- Execution Mode is Incremental

     BEGIN
       SELECT gcia.entry_id,
	      gcia.stat_entry_id
       INTO   l_entry_id,
	      l_stat_entry_id
       FROM   gcs_cons_impact_analyses gcia,
	      gcs_entry_headers	       geh,
	      gcs_data_sub_dtls	       gdsd
       WHERE  gcia.run_name			=	cons_entity_wf_info.prior_run_identifier
       AND    gcia.consolidation_entity_id	=	cons_entity_wf_info.consolidation_entity
       AND    gcia.child_entity_id		=	oper_entity_wf_info.operating_entity
       AND    gdsd.load_id			=	gcia.load_id
       AND    gdsd.most_recent_flag		=	'Y'
       AND    gcia.message_name			IN	('GCS_PRISTINE_DATA_INC_LOAD','GCS_PRISTINE_DATA_FULL_LOAD')
       AND    gcia.entry_id			=	geh.entry_id
       AND    geh.disabled_flag			=	'N';


       --Bugfix 3666700: Added code to insert into intercompany temporary table
       gcs_interco_dynamic_pkg.insert_interco_trx(    p_entry_id          =>      l_entry_id,
                                                      p_stat_entry_id     =>      NVL(l_stat_entry_id, -1),
                                                      p_hierarchy_id      =>      l_parameter_list.hierarchy_id,
                                                      p_period_end_date   =>      cons_entity_wf_info.cal_period_end_date,
                                                      x_errbuf            =>      l_parameter_list.errbuf,
                                                      x_retcode           =>      l_parameter_list.retcode);

       gcs_cons_eng_run_dtls_pkg.update_entry_headers_async(	p_run_detail_id			=>	oper_entity_wf_info.run_detail_id,
       								p_entry_id			=>	l_entry_id,
       								p_stat_entry_id			=>	l_stat_entry_id,
       								p_request_error_code		=>	'COMPLETED',
								p_bp_request_error_code		=>	'COMPLETED');

       result := 'COMPLETE:T';

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         result := 'COMPLETE:F';

     END;

   END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.EXECUTE_DATA_PREPARATION.end', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

   END execute_data_preparation;

  PROCEDURE init_oper_entity_process(		itemtype		IN VARCHAR2,
  						itemkey			IN VARCHAR2,
  						actid			IN NUMBER,
  						funcmode		IN varchar2,
  						result			IN OUT NOCOPY varchar2)

  IS

     x_errbuf			VARCHAR2(2000);
     x_retcode			VARCHAR2(2000);
     l_process_code		VARCHAR2(30);
     l_prior_dataprep_exists	VARCHAR2(1)	:=	'X';
     cons_entity_wf_info	gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     oper_entity_wf_info	gcs_cons_eng_utility_pkg.r_oper_entity_wf_info;
     l_entry_id			NUMBER(15);
     l_stat_entry_id		NUMBER(15);
     l_request_error_code	VARCHAR2(200);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.INIT_OPER_ENTITY_PROCESS.end', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

    gcs_cons_eng_utility_pkg.get_oper_entity_wf_info (itemtype,
   						      itemkey,
   						      cons_entity_wf_info,
   						      oper_entity_wf_info);

     IF (cons_entity_wf_info.prior_run_identifier	<>	'NO_PRIOR_RUN') THEN
       -- Prior run exists
       BEGIN
         SELECT   DECODE(gcerd.entry_id, NULL, 'COMPLETE:FULL', -1, 'COMPLETE:FULL', 'COMPLETE:INCREMENTAL'),
		  gcerd.entry_id,
		  gcerd.stat_entry_id,
		  gcerd.request_error_code
         INTO     result,
		  l_entry_id,
		  l_stat_entry_id,
		  l_request_error_code
         FROM     gcs_cons_eng_run_dtls 	gcerd,
     	          gcs_cons_eng_runs		gcer
         WHERE    gcer.run_entity_id		=	cons_entity_wf_info.consolidation_entity
         AND	  gcerd.category_code		=	'DATAPREPARATION'
         AND	  gcer.run_name			=	gcerd.run_name
	 AND	  gcerd.request_error_code	IN	('COMPLETED', 'WARNING')
         AND      gcer.run_name			=	cons_entity_wf_info.prior_run_identifier
         AND      gcer.balance_type_code	=	cons_entity_wf_info.balance_type_code
         AND      gcer.run_entity_id		=	gcerd.consolidation_entity_id
         AND	  gcerd.child_entity_id		=	oper_entity_wf_info.operating_entity;
       EXCEPTION
	 WHEN OTHERS THEN
	   result   := 'COMPLETE:FULL';
       END;

       BEGIN
       IF (result	=	'COMPLETE:INCREMENTAL') THEN
           SELECT 'COMPLETE:FULL'
           INTO   result
           FROM   gcs_cons_impact_analyses
           WHERE  run_name				=	cons_entity_wf_info.prior_run_identifier
           AND    consolidation_entity_id		=	cons_entity_wf_info.consolidation_entity
           AND    child_entity_id			=	oper_entity_wf_info.operating_entity
	   --Bugfix 4665921: Added GCS_VS_MAP_UPDATED check to support impact for value set assignments
           AND    message_name				IN	('GCS_VS_MAP_UPDATED', 'GCS_PRISTINE_DATA_INC_LOAD', 'GCS_PRISTINE_DATA_FULL_LOAD')
           AND    ROWNUM				< 	2;
       END IF;
       EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	   result := 'COMPLETE:NONE';

           gcs_cons_eng_run_dtls_pkg.update_entry_headers_async(  p_run_detail_id                 =>      oper_entity_wf_info.run_detail_id,
                                                                  p_entry_id                      =>      l_entry_id,
                                                                  p_stat_entry_id                 =>      l_stat_entry_id,
                                                                  p_request_error_code            =>      l_request_error_code,
                                                                  p_bp_request_error_code         =>      l_request_error_code
                                                                );
       END;
     ELSE
       result := 'COMPLETE:FULL';
     END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.INIT_OPER_ENTITY_PROCESS', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

  END init_oper_entity_process;

  PROCEDURE check_aggregation_required(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)

  IS

     l_aggregation_required	VARCHAR2(1) := 'N';
     l_run_identifier		VARCHAR2(200);
     l_entity_id		NUMBER(15);
     l_entry_count		NUMBER(15);

     cons_entity_wf_info        gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     l_run_detail_id            NUMBER(15);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CHECK_AGGREGATION_REQUIRED', '<<Enter for item key : ' || itemkey || '>>');
    END IF;

     l_entity_id	:=	WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'CONS_ENTITY', FALSE);
     l_run_identifier	:=	WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'RUN_IDENTIFIER', FALSE);

     gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype, itemkey, cons_entity_wf_info);

     SELECT COUNT(entry_id)
     INTO   l_entry_count
     FROM   gcs_cons_eng_run_dtls
     WHERE  run_name			=	l_run_identifier
     AND    NVL(entry_id,-1)		>	0
     AND    consolidation_entity_id	=	l_entity_id
     AND    category_code		<>	'AGGREGATION';

     IF (l_entry_count > 0) THEN
     	result := 'COMPLETE:T';
     ELSE
        result := 'COMPLETE:F';

        --Bugfix 5288100: If aggregation is not required then insert not applicable into gcs_cons_eng_run_dtls
        GCS_CONS_ENG_RUN_DTLS_PKG.insert_row(p_run_name                   =>      cons_entity_wf_info.run_identifier,
                                             p_consolidation_entity_id    =>      cons_entity_wf_info.consolidation_entity,
                                             p_category_code              =>      'AGGREGATION',
                                             p_child_entity_id            =>      cons_entity_wf_info.consolidation_entity,
                                             p_cons_relationship_id       =>      -1,
                                             p_request_error_code         =>      'NOT_APPLICABLE',
                                             p_run_detail_id              =>      l_run_detail_id);

        WF_ENGINE.SetItemAttrNumber(itemtype, itemkey, 'RUN_DETAIL_ID', l_run_detail_id);

     END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CHECK_AGGREGATION_REQUIRED', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

  END check_aggregation_required;

  PROCEDURE execute_aggregation(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)

  IS

     l_aggregation_required		VARCHAR2(1) := 'N';
     l_cons_relationship_id		NUMBER(15);
     l_run_detail_id			NUMBER(15);
     x_errbuf				VARCHAR2(200);
     x_retcode				VARCHAR2(200);

     cons_entity_wf_info		gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     l_parameter_list			gcs_cons_eng_utility_pkg.r_module_parameters;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.EXECUTE_AGGREGATION', '<<Enter for item key : ' || itemkey || '>>');
    END IF;


    gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype, itemkey, cons_entity_wf_info);

   BEGIN
    SELECT cons_relationship_id
    INTO   l_cons_relationship_id
    FROM   gcs_cons_relationships
    WHERE  child_entity_id	=	cons_entity_wf_info.consolidation_entity
    AND	   dominant_parent_flag	=	'Y'
    AND	   hierarchy_id		=	cons_entity_wf_info.consolidation_hierarchy
    AND    cons_entity_wf_info.cal_period_end_date	BETWEEN start_date 	AND	NVL(end_date, cons_entity_wf_info.cal_period_end_date)
    AND	   ROWNUM		< 	2;
   EXCEPTION
    WHEN OTHERS THEN
      l_cons_relationship_id := -1;
   END;


    GCS_CONS_ENG_RUN_DTLS_PKG.insert_row(p_run_name			=>	cons_entity_wf_info.run_identifier,
    					 p_consolidation_entity_id	=>	cons_entity_wf_info.consolidation_entity,
    					 p_category_code		=>	'AGGREGATION',
    					 p_child_entity_id		=>	cons_entity_wf_info.consolidation_entity,
    					 p_cons_relationship_id		=>	l_cons_relationship_id,
    					 p_request_error_code		=>	'IN_PROGRESS',
    					 p_run_detail_id		=>	l_run_detail_id);


    SELECT DECODE(COUNT(*), 0, 'N', 'Y')
    INTO   l_parameter_list.stat_required
    FROM   gcs_cons_eng_run_dtls
    WHERE  run_name				=	cons_entity_wf_info.run_identifier
    AND	   consolidation_entity_id		=	cons_entity_wf_info.consolidation_entity
    AND	   NVL(stat_entry_id,0)			>	0;

    l_parameter_list.run_detail_id		:=	l_run_detail_id;
    l_parameter_list.hierarchy_id		:=	cons_entity_wf_info.consolidation_hierarchy;
    l_parameter_list.cons_relationship_id	:=	l_cons_relationship_id;
    l_parameter_list.cons_entity_id		:=	cons_entity_wf_info.consolidation_entity;
    l_parameter_list.cal_period_id		:=	cons_entity_wf_info.cal_period_id;
    l_parameter_list.period_end_date		:=	cons_entity_wf_info.cal_period_end_date;
    l_parameter_list.balance_type_code		:=	cons_entity_wf_info.balance_type_code;
    --Bugfix 5017120: Added support for additional data types
    l_parameter_list.hierarchy_dataset_code     :=      cons_entity_wf_info.hierarchy_dataset_code;

    gcs_cons_eng_utility_pkg.execute_module('AGGREGATION', l_parameter_list, itemkey);

    WF_ENGINE.SetItemAttrNumber(itemtype, itemkey, 'RUN_DETAIL_ID', l_run_detail_id);

     --Bugfix 4874306: Eliminate calls to XML Generation in order to leverage data templates
     --gcs_cons_eng_utility_pkg.submit_xml_ntf_program(
     --					p_run_name                    =>	cons_entity_wf_info.run_identifier,
     --                               	p_cons_entity_id              =>	cons_entity_wf_info.consolidation_entity,
     --                               	p_category_code               =>	'AGGREGATION',
     --                               	p_run_detail_id               =>	l_run_detail_id);

    result := 'COMPLETE';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.EXECUTE_AGGREGATION', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

  END execute_aggregation;

  PROCEDURE delete_flattened_relns(cons_entity_wf_info IN gcs_cons_eng_utility_pkg.r_cons_entity_wf_info)

  IS PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.DELETE_FLATTENED_RELNS', '<<Enter>>');
    END IF;

    --Bugfix 4928211: For performance purposes deleting from gcs_flattened relations when parent node is fully complete with consolidation
    DELETE FROM gcs_flattened_relns
    WHERE  run_name           =    cons_entity_wf_info.run_identifier;

    COMMIT;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.DELETE_FLATTENED_RELNS', '<<Exit>>');
    END IF;

  END;

  PROCEDURE raise_completion_event(		itemtype		IN VARCHAR2,
  						itemkey			IN VARCHAR2,
  						actid			IN NUMBER,
  						funcmode		IN varchar2,
  						result			IN OUT NOCOPY varchar2)

  IS

     l_run_identifier		VARCHAR2(200);
     l_entity_id		NUMBER(15);
     l_event_name               VARCHAR2(200)   :=      'oracle.apps.gcs.consolidation.engine.finishconsentitywf';
     l_event_key		VARCHAR2(2000);
     l_parameter_list           wf_parameter_list_t;
     l_parent_entity_id		NUMBER(15);
     l_dependent_count		NUMBER(15);
     l_entry_id			NUMBER(15);
     l_stat_entry_id		NUMBER(15);
     cons_entity_wf_info	gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     l_warning_exists		VARCHAR2(1) 	:=	'N';
     l_status_code		VARCHAR2(30);
     l_run_detail_id		NUMBER(15);
     l_top_entity_id		NUMBER;

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RAISE_COMPLETION_EVENT', '<<Enter for item key : ' || itemkey || '>>');
    END IF;

     gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype, itemkey, cons_entity_wf_info);


    BEGIN
     SELECT 	'Y'
     INTO	l_warning_exists
     FROM	gcs_cons_eng_run_dtls
     WHERE	run_name			=	cons_entity_wf_info.run_identifier
     AND	consolidation_entity_id		=	cons_entity_wf_info.consolidation_entity
     AND	child_entity_id			IS	NULL
     AND	request_error_code 		NOT IN	('COMPLETED', 'NOT_APPLICABLE')
--STK: Added Condition for Excluding Category Code of Aggregation 5/6/03
     AND        category_code			<>	'AGGREGATION'
     AND	ROWNUM				< 	2;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      l_warning_exists 	:=	'N';
    END;

      IF (l_warning_exists = 'Y') THEN
        l_status_code	:=	'WARNING';
      ELSE
        l_status_code	:=	'COMPLETED';
      END IF;

     gcs_cons_eng_runs_pkg.update_status(
                            p_run_name           => cons_entity_wf_info.run_identifier,
                                                        p_most_recent_flag      => 'Y',
                                                        p_status_code           => l_status_code,
                                                        p_run_entity_id         => cons_entity_wf_info.consolidation_entity,
							p_end_time		=> sysdate);

     SELECT	top_entity_id
     INTO	l_top_entity_id
     FROM	gcs_hierarchies_b
     WHERE	hierarchy_id		=	cons_entity_wf_info.consolidation_hierarchy;


     BEGIN
      gcs_cons_eng_run_dtls_pkg.update_category_status(
                            p_run_name			        =>	cons_entity_wf_info.run_identifier,
  							p_consolidation_entity_id	=>	cons_entity_wf_info.consolidation_entity,
  							p_category_code			=>	'AGGREGATION',
  							p_status			=>	l_status_code);

      gcs_eng_cp_utility_pkg.submit_xml_ntf_program(
                                    			p_execution_type               	=>	'NTF_ONLY',
							p_run_name		  	=>	cons_entity_wf_info.run_identifier,
							p_cons_entity_id		=>	cons_entity_wf_info.consolidation_entity,
							p_category_code			=>	'AGGREGATION',
							p_run_detail_id			=>	cons_entity_wf_info.run_detail_id);

      IF (l_top_entity_id                =       cons_entity_wf_info.consolidation_entity) THEN
        -- bugfix 5569522: pass p_analysis_cycle_id for launching business process.
        submit_epb_data_transfer(        p_hierarchy_id          =>      cons_entity_wf_info.consolidation_hierarchy,
                                         p_balance_type_code     =>      cons_entity_wf_info.balance_type_code,
                                         p_cal_period_id        =>    cons_entity_wf_info.cal_period_id,
                                         p_analysis_cycle_id    =>    cons_entity_wf_info.analysis_cycle_id);
      END IF;

      --Bugfix 4928211: If this is the topmost parent for the specifc run then delete data from gcs_flattened_relns
      SELECT parent_entity_id
      INTO   l_top_entity_id
      FROM   gcs_cons_eng_runs
      WHERE  run_name                    = cons_entity_wf_info.run_identifier
      AND    run_entity_id               = cons_entity_wf_info.consolidation_entity;

      IF (l_top_entity_id = -1) THEN
        delete_flattened_relns(cons_entity_wf_info);
      END IF;

      SELECT entry_id,
      	     stat_entry_id
      INTO   l_entry_id,
      	     l_stat_entry_id
      FROM   gcs_cons_eng_run_dtls
      WHERE  run_detail_id 		=	cons_entity_wf_info.run_detail_id;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_entry_id 			:= 	-1;
       l_stat_entry_id			:=	-1;
     END;

    gcs_cons_impact_analysis_pkg.consolidation_completed(       p_run_name              =>      cons_entity_wf_info.run_identifier,
                                                                p_run_entity_id         =>      cons_entity_wf_info.consolidation_entity,
                                                                p_cal_period_id         =>      cons_entity_wf_info.cal_period_id,
                                                                p_cal_period_end_date   =>      cons_entity_wf_info.cal_period_end_date,
                                                                p_hierarchy_id          =>      cons_entity_wf_info.consolidation_hierarchy,
                                                                p_balance_type_code     =>      cons_entity_wf_info.balance_type_code);

    SELECT gcerd.run_detail_id
    INTO   l_run_detail_id
    FROM   gcs_cons_eng_run_dtls gcerd
    WHERE  gcerd.category_code 		= 'DATAPREPARATION'
    AND    gcerd.child_entity_id	= cons_entity_wf_info.consolidation_entity
    AND    gcerd.run_name		= cons_entity_wf_info.run_identifier;

    gcs_cons_eng_run_dtls_pkg.update_entry_headers_async(	p_run_detail_id		=>	l_run_detail_id,
  								p_entry_id		=>	l_entry_id,
  								p_stat_entry_id		=> 	l_stat_entry_id,
  								p_request_error_code	=>	l_status_code,
  								p_bp_request_error_code	=>	l_status_code);

    result := 'COMPLETE';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RAISE_COMPLETION_EVENT', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      result := 'COMPLETE';
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RAISE_COMPLETION_EVENt', SQLERRM);
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RAISE_COMPLETION_EVENT', '<<Exit for item key : ' || itemkey || '>>');
      END IF;

  END raise_completion_event;

  PROCEDURE create_flattened_relns(cons_entity_wf_info    IN gcs_cons_eng_utility_pkg.r_cons_entity_wf_info,
                                   cons_entity_id         IN NUMBER)

  IS PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CREATE_FLATTENED_RELNS', '<<Enter>>');
    END IF;

    --Bugfix 4928211: For performance benefit store all children of consolidation hierarchy into gcs_flattened_relns

    INSERT INTO gcs_flattened_relns
    (run_name,
     parent_entity_id,
     child_entity_id,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     object_version_number,
     --Bugfix 5091093: Added consolidation type code
     consolidation_type_code
    )
    SELECT     cons_entity_wf_info.run_identifier,
               cons_entity_id,
               gcr.child_entity_id,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               fnd_global.login_id,
               1,
    --Bugfix 5091093: Added consolidation type code
               gtb.consolidation_type_code
    FROM        gcs_cons_relationships gcr,
                gcs_treatments_b gtb
    WHERE       gtb.treatment_id(+)         =    gcr.treatment_id
    START WITH  gcr.parent_entity_id        =    cons_entity_id
    AND         gcr.hierarchy_id            =    cons_entity_wf_info.consolidation_hierarchy
    --Bugfix 5192720: Added dominant parent flag join condition
    AND         gcr.dominant_parent_flag    =    'Y'
    AND         cons_entity_wf_info.cal_period_end_date
                BETWEEN gcr.start_date AND NVL(gcr.end_date, cons_entity_wf_info.cal_period_end_date)
    CONNECT BY  PRIOR gcr.child_entity_id   =    gcr.parent_entity_id
    AND         gcr.hierarchy_id            =    cons_entity_wf_info.consolidation_hierarchy
    AND         gcr.dominant_parent_flag    =    'Y'
    AND         cons_entity_wf_info.cal_period_end_date
                BETWEEN gcr.start_date AND NVL(gcr.end_date, cons_entity_wf_info.cal_period_end_date);

    COMMIT;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CREATE_FLATTENED_RELNS', '<<Exit>>');
    END IF;

  END;

  PROCEDURE spawn_cons_entity_process(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)

  IS

     TYPE t_childkey_list	IS TABLE OF VARCHAR2(200);
     l_childkey_list		t_childkey_list	:=	t_childkey_list(NULL);
     l_child_key		VARCHAR2(200);
     counter			NUMBER(15)	:= 0;
     l_entities_to_process	BOOLEAN		:= FALSE;
     cons_entity_wf_info	gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;

     CURSOR c_cons_entities 	 (p_run_name 		IN VARCHAR2,
     				  p_cons_entity_id	IN NUMBER) IS
     	SELECT	gcerd.child_entity_id,
     		gcerd.cons_relationship_id,
     		gcerd.run_detail_id,
     		fev.entity_name,
		DECODE(geca_parent.currency_code, geca_child.currency_code, 'N', 'Y') translation_required
     	FROM    gcs_cons_eng_run_dtls  	gcerd,
     		fem_entities_attr	fea,
     		fem_entities_vl		fev,
		gcs_entity_cons_attrs	geca_parent,
		gcs_entity_cons_attrs	geca_child,
		gcs_cons_eng_runs	gcer
     	WHERE   gcerd.run_name			=	p_run_name
     	AND	gcerd.consolidation_entity_id	=	p_cons_entity_id
     	AND     gcerd.entry_id			IS NULL
     	AND	category_code 			=	'DATAPREPARATION'
     	AND	gcerd.child_entity_id		=	fev.entity_id
     	AND     gcerd.child_entity_id		=	fea.entity_id
     	AND     fea.attribute_id		=	g_entity_type_attr
        AND	fea.version_id			=	g_entity_type_version
     	AND     fea.dim_attribute_varchar_member	IN	('C')
	AND	geca_parent.entity_id		=	p_cons_entity_id
	AND	geca_child.entity_id		=	fev.entity_id
	AND	geca_parent.hierarchy_id	=	geca_child.hierarchy_id
	AND	gcer.run_name			=	gcerd.run_name
	AND	gcer.run_entity_id		=	gcerd.consolidation_entity_id
	AND	gcer.hierarchy_id		=	geca_child.hierarchy_id;


  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SPAWN_CONS_ENTITY_PROCESS', '<<Exit for item key : ' || itemkey || '>>');
    END IF;


     gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype, itemkey, cons_entity_wf_info);

     FOR v_cons_entity IN c_cons_entities(cons_entity_wf_info.run_identifier, cons_entity_wf_info.consolidation_entity)
     LOOP

     	counter := counter + 1;
     	SELECT to_char(sysdate,'DD-MM-RR HH:MI:SS')
     	INTO   l_child_key
     	FROM   dual;

     	l_child_key	:=	v_cons_entity.entity_name || ' (' || cons_entity_wf_info.request_id || ')';

     	l_childkey_list.extend(1);
     	l_childkey_list(counter) := l_child_key;

  	GCS_CONS_ENG_RUNS_PKG.insert_row
  	(
  	  p_run_name		=>	cons_entity_wf_info.run_identifier,
   	  p_hierarchy_id	=>	cons_entity_wf_info.consolidation_hierarchy,
  	  p_process_method_code	=>	cons_entity_wf_info.process_method,
  	  p_run_entity_id	=>	v_cons_entity.child_entity_id,
  	  p_cal_period_id	=>	cons_entity_wf_info.cal_period_id,
  	  p_balance_type_code	=>	cons_entity_wf_info.balance_type_code,
	  p_parent_entity_id	=>	cons_entity_wf_info.consolidation_entity,
	  p_item_key		=>	l_child_key,
	  p_request_id		=>	cons_entity_wf_info.request_id
        );

        --Bugfix 5197891: Assign appropriate user rather than null value
  	WF_ENGINE.CreateProcess(g_cons_item_type, l_childkey_list(counter), g_cons_entity_process, l_childkey_list(counter), FND_GLOBAL.USER_NAME);
	WF_ENGINE.SetItemAttrNumber(g_cons_item_type, l_childkey_list(counter), 'CONS_HIERARCHY', cons_entity_wf_info.consolidation_hierarchy);
	WF_ENGINE.SetItemAttrNumber(g_cons_item_type, l_childkey_list(counter), 'CONS_ENTITY', v_cons_entity.child_entity_id);
	WF_ENGINE.SetItemAttrText(g_cons_item_type, l_childkey_list(counter), 'RUN_IDENTIFIER', cons_entity_wf_info.run_identifier);
	WF_ENGINE.SetItemAttrText(g_cons_item_type, l_childkey_list(counter), 'CAL_PERIOD', cons_entity_wf_info.cal_period_id);
        WF_ENGINE.SetItemAttrText(g_cons_item_type, l_childkey_list(counter), 'PROCESS_METHOD', cons_entity_wf_info.process_method);
        WF_ENGINE.SetItemAttrText(g_cons_item_type, l_childkey_list(counter), 'CAL_PERIOD_END_DATE', cons_entity_wf_info.cal_period_end_date);
	WF_ENGINE.SetItemAttrText(g_cons_item_type, l_childkey_list(counter), 'BALANCE_TYPE_CODE', cons_entity_wf_info.balance_type_code);
 	WF_ENGINE.SetItemAttrText(g_cons_item_type, l_childkey_list(counter), 'TRANSLATION_REQUIRED', v_cons_entity.translation_required);
        WF_ENGINE.SetItemAttrNumber(g_cons_item_type, l_childkey_list(counter), 'CONC_REQUEST_ID', cons_entity_wf_info.request_id);
        --Bugfix 5017120: Added support for additional data types
        WF_ENGINE.SetItemAttrNumber(g_cons_item_type, l_childkey_list(counter), 'SOURCE_DATASET_CODE', cons_entity_wf_info.source_dataset_code);
        WF_ENGINE.SetItemAttrNumber(g_cons_item_type, l_childkey_list(counter), 'HIERARCHY_DATASET_CODE', cons_entity_wf_info.hierarchy_dataset_code);
  	WF_ENGINE.Set_Item_Parent(g_cons_item_type, l_childkey_list(counter), itemtype, itemkey,'WAITFORFLOW-1');

        l_entities_to_process := TRUE;

        --Bugfix 4928211: For performance benefit store all children of consolidation hierarchy into gcs_flattened_relns
        create_flattened_relns(cons_entity_wf_info,
                               v_cons_entity.child_entity_id);

     END LOOP;

     WHILE (counter > 0)
     LOOP
        l_entities_to_process := TRUE;
	WF_ENGINE.StartProcess(g_cons_item_type, l_childkey_list(counter));
	counter := counter - 1;
     END LOOP;

     IF (l_entities_to_process) THEN
       result := 'COMPLETE:T';
     ELSE
       result := 'COMPLETE:F';
     END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SPAWN_CONS_ENTITY_PROCESS', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

  END spawn_cons_entity_process;

  PROCEDURE initialize_cons_process(		itemtype		IN VARCHAR2,
  						itemkey			IN VARCHAR2,
  						actid			IN NUMBER,
						funcmode		IN varchar2,
  						result			IN OUT NOCOPY varchar2)

  IS
   cons_entity_wf_info	gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
   l_run_detail_id	NUMBER(15);

   CURSOR c_categories_to_process IS
   	        SELECT 	cons_entity_wf_info.run_identifier,
     			cons_entity_wf_info.consolidation_entity,
     			DECODE(category_code, 'DATAPREPARATION', 'IN_PROGRESS', 'NOT_STARTED')	request_error_code,
     			category_code
     		FROM    gcs_categories_b
     		WHERE	category_number	>	0
		AND	enabled_flag	=	'Y';

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.INITIALIZE_CONS_PROCESS', '<<Enter for item key : ' || itemkey || '>>');
    END IF;

    gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype, itemkey, cons_entity_wf_info);

    FOR v_categories_to_process IN c_categories_to_process LOOP
      gcs_cons_eng_run_dtls_pkg.insert_row(
                                           p_run_name			=>	cons_entity_wf_info.run_identifier,
                                           p_consolidation_entity_id	=>	cons_entity_wf_info.consolidation_entity,
                                           p_category_code		=>	v_categories_to_process.category_code,
                                           p_request_error_code		=>	v_categories_to_process.request_error_code,
                                           p_run_detail_id		=>	l_run_detail_id);
    END LOOP;

    result	:=	'COMPLETE';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.INITIALIZE_CONS_PROCESS', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

  END initialize_cons_process;

  PROCEDURE check_cons_entity_status(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)

  IS

     cons_entity_wf_info	gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     l_prior_run_name		VARCHAR2(240);
     l_status_code		VARCHAR2(30);
     l_locked_flag		VARCHAR2(1);
     l_impacted_flag		VARCHAr2(1);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CHECK_CONS_ENTITY_STATUS', '<<Enter for item key : ' || itemkey || '>>');
    END IF;

     gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype, itemkey, cons_entity_wf_info);

     SELECT run_name,
     	    status_code,
	    locked_flag,
	    impacted_flag
     INTO   l_prior_run_name,
     	    l_status_code,
	    l_locked_flag,
	    l_impacted_flag
     FROM   gcs_cons_eng_runs
     WHERE  run_entity_id	=	cons_entity_wf_info.consolidation_entity
--   Bugfix 3659810 : Added condition for hierarchy_id
     AND    hierarchy_id	=	cons_entity_wf_info.consolidation_hierarchy
     AND    most_recent_flag	=	'X'
     AND    cal_period_id	=	cons_entity_wf_info.cal_period_id;

     WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'PRIOR_RUN_NAME', l_prior_run_name);
     result	:=	'COMPLETE:F';

     --Bugfix 3750740 : Update Prior Run To MOST_RECENT_FLAG = 'N'
     gcs_cons_eng_runs_pkg.update_status	(	p_run_name		=> l_prior_run_name,
  							p_most_recent_flag	=> 'N',
  							p_status_code		=> NULL,
  							p_run_entity_id		=> cons_entity_wf_info.consolidation_entity);

     gcs_cons_eng_runs_pkg.update_status	(	p_run_name		=> cons_entity_wf_info.run_identifier,
  							p_most_recent_flag	=> 'Y',
  							p_status_code		=> 'IN_PROGRESS',
  							p_run_entity_id		=> cons_entity_wf_info.consolidation_entity);


     IF (l_locked_flag = 'Y' OR (cons_entity_wf_info.process_method = 'INCREMENTAL' AND l_impacted_flag = 'N')) THEN
	result  :=	'COMPLETE:T';
     END IF;


    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.CHECK_CONS_ENTITY_STATUS', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'PRIOR_RUN_NAME', 'NO_PRIOR_RUN');

       gcs_cons_eng_runs_pkg.update_status       (       p_run_name              =>      cons_entity_wf_info.run_identifier,
                                                         p_most_recent_flag      =>      'Y',
                                                         p_status_code           =>      'IN_PROGRESS',
                                                         p_run_entity_id         =>      cons_entity_wf_info.consolidation_entity);
       result   := 'COMPLETE:F';
  END check_cons_entity_status;

  PROCEDURE update_run_information(	cons_entity_wf_info	IN gcs_cons_eng_utility_pkg.r_cons_entity_wf_info,
					p_run_detail_id		IN OUT NOCOPY NUMBER)

  IS PRAGMA AUTONOMOUS_TRANSACTION;

     l_status_code	VARCHAR2(30);
     l_impacted_flag	VARCHAR2(1);
     l_locked_flag	VARCHAR2(1);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_RUN_INFORMATION.begin', '<<Enter>>');
    END IF;

     UPDATE gcs_cons_eng_runs
     SET    most_recent_flag 	= 	'Y'
     WHERE  run_name		=	cons_entity_wf_info.prior_run_identifier
     AND    run_entity_id	=	cons_entity_wf_info.consolidation_entity
     RETURNING status_code, impacted_flag, locked_flag INTO l_status_code, l_impacted_flag, l_locked_flag;

     UPDATE gcs_cons_eng_runs
     SET    most_recent_flag 	=	'N',
	    associated_run_name =	cons_entity_wf_info.prior_run_identifier,
	    status_code		=	l_status_code,
	    impacted_flag	=	l_impacted_flag,
	    locked_flag		=	l_locked_flag,
	    end_time		=	sysdate,
	    last_updated_by	=	FND_GLOBAL.USER_ID,
	    last_update_date	=	sysdate,
	    last_update_login	=	FND_GLOBAL.LOGIN_ID
     WHERE  run_name		=	cons_entity_wf_info.run_identifier
     AND    run_entity_id	=	cons_entity_wf_info.consolidation_entity;

     UPDATE gcs_cons_eng_runs gcer
     SET    gcer.most_recent_flag  =       'Y'
     WHERE  gcer.most_recent_flag  =       'X'
     AND    gcer.hierarchy_id      =       cons_entity_wf_info.consolidation_hierarchy
     AND    gcer.cal_period_id     =       cons_entity_wf_info.cal_period_id
     AND    gcer.balance_type_code =       cons_entity_wf_info.balance_type_code
     AND    EXISTS                         (	SELECT 'X'
                                         	FROM   gcs_cons_relationships gcr
                                         	WHERE  gcr.child_entity_id = gcer.run_entity_id
                                         	START WITH gcr.parent_entity_id = cons_entity_wf_info.consolidation_entity
                                         	AND    gcr.hierarchy_id         = cons_entity_wf_info.consolidation_hierarchy
                                         	AND    cons_entity_wf_info.cal_period_end_date
                                                        BETWEEN gcr.start_date AND     NVL(gcr.end_date,
                                                                			   cons_entity_wf_info.cal_period_end_date)
                                         	CONNECT BY PRIOR gcr.child_entity_id = gcr.parent_entity_id
                                         	AND    gcr.hierarchy_id         = cons_entity_wf_info.consolidation_hierarchy
						AND    gcr.dominant_parent_flag = 'Y'
                                         	AND    cons_entity_wf_info.cal_period_end_date
                                                        BETWEEN gcr.start_date AND     NVL(gcr.end_date,
                                                                			   cons_entity_wf_info.cal_period_end_date));


     UPDATE gcs_cons_eng_run_dtls gcerd
     SET    (entry_id,
	     stat_entry_id,
	     request_error_code,
	     bp_request_error_code
	     ) =
                                        (SELECT gcerd_inner.entry_id,
						gcerd_inner.stat_entry_id,
						gcerd_inner.request_error_code,
						gcerd_inner.bp_request_error_code
                                         FROM   gcs_cons_eng_run_dtls gcerd_inner
                                         WHERE  gcerd_inner.run_name                    = cons_entity_wf_info.prior_run_identifier
                                         AND    gcerd_inner.consolidation_entity_id     = cons_entity_wf_info.consolidation_entity
                                         AND    gcerd_inner.category_code               = 'AGGREGATION'
                                         AND    gcerd_inner.child_entity_id             = cons_entity_wf_info.consolidation_entity)
     WHERE  gcerd.run_name              =       cons_entity_wf_info.run_identifier
     AND    gcerd.category_code         =       'DATAPREPARATION'
     AND    gcerd.child_entity_id       =       cons_entity_wf_info.consolidation_entity
     RETURN run_detail_id       INTO    p_run_detail_id;

     COMMIT;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_RUN_INFORMATION.end', '<<Exit>>');
    END IF;
  END;

  PROCEDURE retrieve_prior_runs(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2)

  IS

     cons_entity_wf_info	gcs_cons_eng_utility_pkg.r_cons_entity_wf_info;
     l_prior_run_name		VARCHAR2(200);
     l_status_code		VARCHAR2(30);
     l_run_detail_id		NUMBER(15);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RETRIEVE_PRIOR_RUNS', '<<Enter for item key : ' || itemkey || '>>');
    END IF;


     gcs_cons_eng_utility_pkg.get_cons_entity_wf_info(itemtype, itemkey, cons_entity_wf_info);

     update_run_information(cons_entity_wf_info,
			    l_run_detail_id);

     WF_ENGINE.SetItemAttrNumber(itemtype, itemkey, 'RUN_DETAIL_ID', l_run_detail_id);

     result := 'COMPLETE';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RETRIEVE_PRIOR_RUNS', '<<Exit for item key : ' || itemkey || '>>');
    END IF;

   END retrieve_prior_runs;


END GCS_CONS_ENGINE_PKG;


/
