--------------------------------------------------------
--  DDL for Package Body GCS_RAISE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_RAISE_EVENT_PKG" as
/* $Header: gcs_raise_eventb.pls 120.11 2007/12/05 14:38:11 rthati noship $ */

  g_api		VARCHAR2(200)		:=	'gcs.plsql.GCS_RAISE_EVENT_PKG';

  PROCEDURE	raise_hierarchy_alt_event	(p_pre_cons_relationship_id	IN	NUMBER,
  						 p_post_cons_relationship_id	IN	NUMBER,
  						 p_trx_type_code		IN	VARCHAR2,
  						 p_trx_date_day			IN	NUMBER,
  						 p_trx_date_month		IN	NUMBER,
  						 p_trx_date_year		IN	NUMBER,
  						 p_hidden_flag			IN	VARCHAR2,
  						 p_intermediate_trtmnt_id	IN	NUMBER,
  						 p_intermediate_pct_owned	IN	NUMBER)

  IS

    l_success		VARCHAR2(30);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RAISE_HIERARCHY_ALT_EVENT.begin', '<<Enter>>');
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.RAISE_HIERARCHY_ALT_EVENT', 'Pre-Cons Relationship ID	:	' || p_pre_cons_relationship_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.RAISE_HIERARCHY_ALT_EVENT', 'Post-Cons Relationship ID	:	' || p_post_cons_relationship_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.RAISE_HIERARCHY_ALT_EVENT', 'Transaction Type Code	:	' || p_trx_type_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.RAISE_HIERARCHY_ALT_EVENT', 'Transaction Date Day	:	' || p_trx_date_day);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.RAISE_HIERARCHY_ALT_EVENT', 'Transaction Date Month	:	' || p_trx_date_month);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.RAISE_HIERARCHY_ALT_EVENT', 'Transaction Date Year	:	' || p_trx_date_year);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.RAISE_HIERARCHY_ALT_EVENT', 'Hidden Flag		:	' || p_hidden_flag);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.RAISE_HIERARCHY_ALT_EVENT', 'Intermediate Trtmnt Id	:	' || p_intermediate_trtmnt_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.RAISE_HIERARCHY_ALT_EVENT', 'Intermeidate Pct Owned	:	' || p_intermediate_pct_owned);
    END IF;

    l_success  :=   gcs_cons_impact_analysis_pkg.hierarchy_altered
      					(p_pre_cons_relationship_id	=> 	p_pre_cons_relationship_id,
  					 p_post_cons_relationship_id	=>	p_post_cons_relationship_id,
  					 p_trx_type_code		=>	p_trx_type_code,
  					 p_trx_date_day			=>	p_trx_date_day,
  					 p_trx_date_month		=>	p_trx_date_month,
  					 p_trx_date_year		=>	p_trx_date_year,
  					 p_hidden_flag			=>	p_hidden_flag,
  					 p_intermediate_trtmnt_id	=>	p_intermediate_trtmnt_id,
  					 p_intermediate_pct_owned	=>	p_intermediate_pct_owned);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RAISE_HIERARCHY_ALT_EVENT.begin', '<<Exit>>');
    END IF;

  END;

  -- bugfix 5569522: Added parameter p_analysis_cycle_id that will be passed
  -- to the execute_consolidation cocurrent program.
  PROCEDURE	raise_execute_eng_event	(p_consolidation_hierarchy	IN	NUMBER,
  						 p_consolidation_entity	IN	NUMBER,
  						 p_run_identifier		IN	VARCHAR2,
  						 p_cal_period_id		IN	VARCHAR2,
  						 p_balance_type_code	IN	VARCHAR2,
  						 p_process_method		IN	VARCHAR2,
  						 p_request_id			OUT	NOCOPY NUMBER,
                         p_analysis_cycle_id    IN  NUMBER)
  IS
    l_cal_period_end_date		VARCHAR2(30);
    l_end_date_attribute_id    	NUMBER  :=
					gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').attribute_id;
    l_end_date_version_id      	NUMBER  :=
					gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').version_id;
  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RAISE_EXECUTE_ENG_EVENT.begin', '<<Enter>>');
    END IF;

    SELECT  to_char(date_assign_value, 'DD-MM-RR')
    INTO    l_cal_period_end_date
    FROM    fem_cal_periods_attr
    WHERE   attribute_id 	= l_end_date_attribute_id
    AND	    version_id		= l_end_date_version_id
    AND	    cal_period_id	= p_cal_period_id;

    -- Bugfix : Change All Icons to Not Started

    UPDATE gcs_cons_eng_runs
    SET    most_recent_flag	=	'X'
    WHERE  most_recent_flag	=	'Y'
    AND	   run_entity_id	=	p_consolidation_entity
    AND	   hierarchy_id		=	p_consolidation_hierarchy
    AND	   cal_period_id	=       p_cal_period_id
    AND	   balance_type_code	=	p_balance_type_code;

    UPDATE gcs_cons_eng_runs gcer
    SET    gcer.most_recent_flag	=	'X'
    WHERE  gcer.most_recent_flag	=	'Y'
    AND	   gcer.hierarchy_id		=	p_consolidation_hierarchy
    AND	   gcer.cal_period_id		=	p_cal_period_id
    AND	   gcer.balance_type_code	=	p_balance_type_code
    AND    EXISTS 			(SELECT 'X'
					 FROM   gcs_cons_relationships gcr
					 WHERE  gcr.child_entity_id = gcer.run_entity_id
  					 START WITH gcr.parent_entity_id = p_consolidation_entity
				         AND    gcr.hierarchy_id	 = p_consolidation_hierarchy
  					 AND    TO_DATE(l_cal_period_end_date, 'DD-MM-RR')
							BETWEEN gcr.start_date AND     NVL(gcr.end_date,
										       TO_DATE(l_cal_period_end_date, 'DD-MM-RR'))
					 CONNECT BY PRIOR gcr.child_entity_id = gcr.parent_entity_id
					 AND    gcr.hierarchy_id	 = p_consolidation_hierarchy
 					 -- Bugfix 4122843: Added dominant parent flag condition
					 AND	gcr.dominant_parent_flag = 'Y'
                                         AND    TO_DATE(l_cal_period_end_date, 'DD-MM-RR')
                                                        BETWEEN gcr.start_date AND     NVL(gcr.end_date,
                                                                                       TO_DATE(l_cal_period_end_date, 'DD-MM-RR')));

    -- bugfix 5569522: pass p_analysis_cycle_id as argument to the concurrent request.
    p_request_id :=	fnd_request.submit_request(
           				application => 'GCS',
           				program 	=> 'FCH_SUBMIT_CONSOLIDATION',
           				sub_request => FALSE,
           				argument1 	=> p_run_identifier,
           				argument2 	=> p_consolidation_hierarchy,
           				argument3 	=> p_consolidation_entity,
           				argument4	=> p_cal_period_id,
           				argument5	=> p_balance_type_code,
           				argument6	=> NVL(p_process_method,'FULL'),
           				argument7	=> 'N',
                        argument8   => p_analysis_cycle_id);

    COMMIT;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RAISE_EXECUTE_ENG_EVENT.end', '<<Exit>>');
    END IF;

  END;



  PROCEDURE	raise_execute_eng_event		(p_consolidation_hierarchy	IN	NUMBER,
  						 p_consolidation_entity		IN	NUMBER,
  						 p_run_identifier		IN	VARCHAR2,
  						 p_cal_period_id		IN	VARCHAR2,
  						 p_balance_type_code		IN	VARCHAR2,
  						 p_process_method		IN	VARCHAR2)

  IS
  	l_event_key			VARCHAR2(200);
  	l_cal_period_end_date		VARCHAR2(30);
	l_threshold			NUMBER;
        l_end_date_attribute_id    	NUMBER  :=
					gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').attribute_id;
        l_end_date_version_id      	NUMBER  :=
					gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').version_id;
  BEGIN

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RAISE_EXECUTE_ENG_EVENT.begin', '<<Enter>>');
  END IF;

  SELECT entity_name || ' on ' || to_char(sysdate, 'DD-MM-RR HH24:MI:SS')
  INTO   l_event_key
  FROM   fem_entities_vl
  WHERE  entity_id 	=	p_consolidation_entity;

  SELECT  to_char(date_assign_value, 'DD-MM-RR')
  INTO    l_cal_period_end_date
  FROM    fem_cal_periods_attr
  WHERE   attribute_id 	= l_end_date_attribute_id
  AND	  version_id	= l_end_date_version_id
  AND	  cal_period_id	= p_cal_period_id;

  GCS_CONS_ENG_RUNS_PKG.insert_row
  (
  	p_run_name		=>	p_run_identifier,
  	p_hierarchy_id		=>	p_consolidation_hierarchy,
  	p_process_method_code	=>	NVL(p_process_method, 'FULL'),
  	p_run_entity_id		=>	p_consolidation_entity,
  	p_cal_period_id		=>	p_cal_period_id,
  	p_balance_type_code	=>	p_balance_type_code,
	p_parent_entity_id	=>	-1,
	p_item_key		=>	l_event_key,
	p_request_id		=>	-1
  );

  COMMIT;

  -- Bugfix : Change All Icons to Not Started

  UPDATE gcs_cons_eng_runs
  SET    most_recent_flag	=	'X'
  WHERE  most_recent_flag	=	'Y'
  AND	 run_entity_id		=	p_consolidation_entity
  AND	 hierarchy_id		=	p_consolidation_hierarchy
  AND	 cal_period_id		=       p_cal_period_id
  AND	 balance_type_code	=	p_balance_type_code;

  UPDATE gcs_cons_eng_runs gcer
  SET    gcer.most_recent_flag	=	'X'
  WHERE  gcer.most_recent_flag	=	'Y'
  AND	 gcer.hierarchy_id	=	p_consolidation_hierarchy
  AND	 gcer.cal_period_id	=	p_cal_period_id
  AND	 gcer.balance_type_code	=	p_balance_type_code
  AND    EXISTS 			(SELECT 'X'
					 FROM   gcs_cons_relationships gcr
					 WHERE  gcr.child_entity_id = gcer.run_entity_id
  					 START WITH gcr.parent_entity_id = p_consolidation_entity
				         AND    gcr.hierarchy_id	 = p_consolidation_hierarchy
  					 AND    TO_DATE(l_cal_period_end_date, 'DD-MM-RR')
							BETWEEN gcr.start_date AND     NVL(gcr.end_date,
										       TO_DATE(l_cal_period_end_date, 'DD-MM-RR'))
					 CONNECT BY PRIOR gcr.child_entity_id = gcr.parent_entity_id
					 -- Bugfix 4122843: Added dominant parent flag
					 AND	gcr.dominant_parent_flag = 'Y'
					 AND    gcr.hierarchy_id	 = p_consolidation_hierarchy
                                         AND    TO_DATE(l_cal_period_end_date, 'DD-MM-RR')
                                                        BETWEEN gcr.start_date AND     NVL(gcr.end_date,
                                                                                       TO_DATE(l_cal_period_end_date, 'DD-MM-RR')));

  -- Bugfix 3629541 : Set the Workflow Threshold to -1 to Defer the Process to the Background Engine. Remove
  -- all thresholds from the Workflow Definition

  l_threshold		:=	WF_ENGINE.THRESHOLD;
  WF_ENGINE.THRESHOLD	:=	-1;

  --Bugfix 5197891: Assign the correct owner rather than null
  WF_ENGINE.CreateProcess('GCSENGNE', l_event_key, 'CONS_ENTITY_PROCESS', l_event_key, FND_GLOBAL.USER_NAME);
  WF_ENGINE.SetItemAttrNumber('GCSENGNE', l_event_key, 'CONS_HIERARCHY', p_consolidation_hierarchy);
  WF_ENGINE.SetItemAttrNumber('GCSENGNE', l_event_key, 'CONS_ENTITY', p_consolidation_entity);
  WF_ENGINE.SetItemAttrText('GCSENGNE', l_event_key, 'RUN_IDENTIFIER', p_run_identifier);
  WF_ENGINE.SetItemAttrText('GCSENGNE', l_event_key, 'CAL_PERIOD', p_cal_period_id);
  WF_ENGINE.SetItemAttrText('GCSENGNE', l_event_key, 'PROCESS_METHOD', NVL(p_process_method, 'FULL'));
  WF_ENGINE.SetItemAttrText('GCSENGNE', l_event_key, 'CAL_PERIOD_END_DATE', l_cal_period_end_date);
  WF_ENGINE.SetItemAttrText('GCSENGNE', l_event_key, 'BALANCE_TYPE_CODE', p_balance_type_code);
  WF_ENGINE.StartProcess('GCSENGNE', l_event_key);

  COMMIT;

  WF_ENGINE.THRESHOLD	:=	l_threshold;

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RAISE_EXECUTE_ENG_EVENT.end', '<<Exit>>');
  END IF;

  END;


  -- bugfix 5569522: added parameter p_analysis_cycle_id that will be passed to
  -- the consolidation workflow to launch the business process.
  PROCEDURE execute_consolidation (x_retcode OUT NOCOPY VARCHAR2,
                                   x_errbuf  OUT NOCOPY VARCHAR2,
		                           p_run_identifier IN OUT NOCOPY VARCHAR2,
                                   p_consolidation_hierarchy IN  NUMBER,
                                   p_consolidation_entity    IN  NUMBER,
                                   p_cal_period_id           IN  VARCHAR2,
                                   p_balance_type_code       IN  VARCHAR2,
                                   p_process_method          IN  VARCHAR2,
		                           p_called_via_srs		     IN	 VARCHAR2,
                                   p_analysis_cycle_id       IN  NUMBER)
  IS

   l_event_key                     VARCHAR2(200);
   l_cal_period_end_date           VARCHAR2(30);
   l_threshold                     NUMBER;
   l_end_date_attribute_id         NUMBER  :=
                                        gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').attribute_id;
   l_end_date_version_id           NUMBER  :=
                                        gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').version_id;
   l_source_dataset_code           NUMBER;
   l_hierarchy_dataset_code        NUMBER;

   --Bugfix 5505707: Add variables to store information required for default member setup
   l_dimension_info                gcs_utility_pkg.t_hash_gcs_dimension_info;
   l_column_name                   VARCHAR2(30);
   l_value_set_tokens              VARCHAR2(4000);
   l_value_set_name                VARCHAR2(150);
   l_error_message                 VARCHAR2(32767);
   l_ret_status                    BOOLEAN;
   l_process_identifier_exists     NUMBER:=0;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.EXECUTE_CONSOLIDATION.begin', '<<Enter>>');
    END IF;
    --Bugfix 6195807: To check if the process_identifier is already exists in gcs_cons_eng_runs.
    --This fix is for running REQUEST SET.
    BEGIN
      SELECT 1
      INTO   l_process_identifier_exists
      FROM   gcs_cons_eng_runs
      WHERE  run_name=p_run_identifier;

      IF l_process_identifier_exists=1 THEN
        SELECT gcs_cons_eng_run_dtls_s.NEXTVAL
        INTO   p_run_identifier
        FROM   dual;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    --Bugfix 6195807: To check if the process_identifier is already exists in gcs_cons_eng_runs.
    fnd_file.put_line(fnd_file.log, 'Beginning Consolidation Submission Execution');

    fnd_file.put_line(fnd_file.log, '<<Parameter Listings>>');
    fnd_file.put_line(fnd_file.log, 'Consolidation Hierarchy	:	' || p_consolidation_hierarchy);
    fnd_file.put_line(fnd_file.log, 'Consolidation Entity	:	' || p_consolidation_entity);
    fnd_file.put_line(fnd_file.log, 'Process Identifier		:	' || p_run_identifier);
    fnd_file.put_line(fnd_file.log, 'Calendar Period		:	' || p_cal_period_id);
    fnd_file.put_line(fnd_file.log, 'Balance Type		:	' || p_balance_type_code);
    fnd_file.put_line(fnd_file.log, 'Process Method		:	' || p_process_method);
    fnd_file.put_line(fnd_file.log, 'Called via SRS		:	' || p_called_via_srs);
    fnd_file.put_line(fnd_file.log, 'Analysis Cycle Id	:	' || p_analysis_cycle_id);
    fnd_file.put_line(fnd_file.log, '<<End of Parameter Listings>>');

    --Bugfix 5505707: Validating Default Member Setup
    fnd_file.put_line(fnd_file.log, '<<Beginning Validation of Default Member Setup>>');
    l_dimension_info := gcs_utility_pkg.g_gcs_dimension_info;
    l_column_name    := l_dimension_info.FIRST;

    WHILE (l_column_name <= l_dimension_info.LAST) LOOP

      IF ((l_dimension_info(l_column_name).required_for_gcs = 'N')  AND
          (l_dimension_info(l_column_name).required_for_fem = 'Y')  AND
          (l_dimension_info(l_column_name).default_value IS NULL))  THEN

        SELECT value_set_name
        INTO   l_value_set_name
        FROM   fem_value_sets_vl
        WHERE  value_set_id  = l_dimension_info(l_column_name).associated_value_set_id;

        IF (l_value_set_tokens IS NULL) THEN
          l_value_set_tokens := l_value_set_name;
        ELSE
          l_value_set_tokens := l_value_set_tokens || ', ' || l_value_set_name;
        END IF;
      END IF;

      l_column_name := l_dimension_info.NEXT(l_column_name);
    END LOOP;

    IF (LENGTH(l_value_set_tokens) <> 0)  THEN
      fnd_message.set_name('GCS', 'GCS_CONS_PROC_INV_VALUESETS');
      fnd_message.set_token('VALUESETS', l_value_set_tokens);
      l_error_message := fnd_message.get;

      fnd_file.put_line(fnd_file.log, '<<<<Beginning of Validation Error>>>>>');
      fnd_file.put_line(fnd_file.log, l_error_message);
      fnd_file.put_line(fnd_file.log, '<<<<End of Validation Error>>>>>');

      l_ret_status := fnd_concurrent.set_completion_status(status  => 'ERROR',
                                                           message => l_error_message);
      GOTO endofprogram;
    END IF;
    --End of Bugfix 5505707: Validating Default Member Setup

    fnd_file.put_line(fnd_file.log, '<<End Validation of Default Member Setup>>');

    --Bugfix 5017120: Added support for additional data types
    fnd_file.put_line(fnd_file.log, '<<Data Type Specific Parameters>>');

    --Bugfix 5505707: Added validation for source dataset and hierarchy dataset
    BEGIN
      SELECT  source_dataset_code
      INTO    l_source_dataset_code
      FROM    gcs_data_type_codes_b
      WHERE   data_type_code      =   p_balance_type_code;

      SELECT  dataset_code
      INTO    l_hierarchy_dataset_code
      FROM    gcs_dataset_codes
      WHERE   hierarchy_id        =   p_consolidation_hierarchy
      AND     balance_type_code   =   p_balance_type_code;

      fnd_file.put_line(fnd_file.log, 'Source Dataset            :        ' || l_source_dataset_code);
      fnd_file.put_line(fnd_file.log,' Hierarchy Dataset         :        ' || l_hierarchy_dataset_code);
    EXCEPTION
      WHEN OTHERS THEN
        IF (l_source_dataset_code IS NULL) THEN
          fnd_message.set_name('GCS', 'GCS_CONS_PROC_INV_SRC_DATASET');
          l_error_message := fnd_message.get;
        ELSIF (l_hierarchy_dataset_code IS NULL) THEN
          fnd_message.set_name('GCS', 'GCS_CONS_PROC_INV_HIER_DATASET');
          l_error_message := fnd_message.get;
        END IF;

        fnd_file.put_line(fnd_file.log, '<<<<Beginning of Data Types Error>>>>>');
        fnd_file.put_line(fnd_file.log, l_error_message);
        fnd_file.put_line(fnd_file.log, '<<<<End of Data Types Error>>>>>');

        l_ret_status := fnd_concurrent.set_completion_status(status  => 'ERROR',
                                                             message => l_error_message);
        GOTO endofprogram;
    END;
    --End of Bugfix 5505707

    fnd_file.put_line(fnd_file.log, '<<End of Data Type Specific Parameters>>');

    SELECT  to_char(date_assign_value, 'DD-MM-RR')
    INTO    l_cal_period_end_date
    FROM    fem_cal_periods_attr
    WHERE   attribute_id  = l_end_date_attribute_id
    AND     version_id    = l_end_date_version_id
    AND     cal_period_id = p_cal_period_id;

    IF (p_called_via_srs  = 'Y') THEN
      fnd_file.put_line(fnd_file.log, 'Resetting consolidation status to IN_PROGRESS');

      fnd_file.put_line(fnd_file.log, 'End Date : ' || l_cal_period_end_date);
      UPDATE gcs_cons_eng_runs
      SET    most_recent_flag       =       'X'
      WHERE  most_recent_flag       =       'Y'
      AND    run_entity_id          =       p_consolidation_entity
      AND    hierarchy_id           =       p_consolidation_hierarchy
      AND    cal_period_id          =       p_cal_period_id
      AND    balance_type_code      =       p_balance_type_code;

      UPDATE gcs_cons_eng_runs gcer
      SET    gcer.most_recent_flag  =       'X'
      WHERE  gcer.most_recent_flag  =       'Y'
      AND    gcer.hierarchy_id      =       p_consolidation_hierarchy
      AND    gcer.cal_period_id     =       p_cal_period_id
      AND    gcer.balance_type_code =       p_balance_type_code
      AND    EXISTS                         (SELECT 'X'
                                             FROM   gcs_cons_relationships gcr
                                             WHERE  gcr.child_entity_id = gcer.run_entity_id
                                             START WITH gcr.parent_entity_id = p_consolidation_entity
                                             AND    gcr.hierarchy_id         = p_consolidation_hierarchy
                                             AND    TO_DATE(l_cal_period_end_date, 'DD-MM-RR')
                                                        BETWEEN gcr.start_date AND     NVL(gcr.end_date,
                                                                                       TO_DATE(l_cal_period_end_date, 'DD-MM-RR'))
                                             CONNECT BY PRIOR gcr.child_entity_id = gcr.parent_entity_id
					     --Bugfix 4122843: Added dominant parent flag condition
					     AND    gcr.dominant_parent_flag = 'Y'
                                             AND    gcr.hierarchy_id         = p_consolidation_hierarchy
                                             AND    TO_DATE(l_cal_period_end_date, 'DD-MM-RR')
                                                        BETWEEN gcr.start_date AND     NVL(gcr.end_date,
                                                                                       TO_DATE(l_cal_period_end_date, 'DD-MM-RR')));
     fnd_file.put_line(fnd_file.log, 'End of resetting consolidation status to IN_PROGRESS');
   END IF;


   SELECT entity_name || ' (' || FND_GLOBAL.CONC_REQUEST_ID || ')'
   INTO   l_event_key
   FROM   fem_entities_vl
   WHERE  entity_id      =       p_consolidation_entity;

   fnd_file.put_line(fnd_file.log, 'The event key is : ' || l_event_key);

   GCS_CONS_ENG_RUNS_PKG.insert_row
   (
     p_run_name              =>      p_run_identifier,
     p_hierarchy_id          =>      p_consolidation_hierarchy,
     p_process_method_code   =>      NVL(p_process_method, 'FULL'),
     p_run_entity_id         =>      p_consolidation_entity,
     p_cal_period_id         =>      p_cal_period_id,
     p_balance_type_code     =>      p_balance_type_code,
     p_parent_entity_id      =>      -1,
     p_item_key              =>      l_event_key,
     p_request_id	     =>	     FND_GLOBAL.CONC_REQUEST_ID
   );

   --Bugfix 4928211: Inserting data into gcs_flattend_relns for performance purposes
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
   SELECT     p_run_identifier,
              p_consolidation_entity,
              gcr.child_entity_id,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              1,
              gtb.consolidation_type_code
   FROM        gcs_cons_relationships gcr,
    --Bugfix 5091093: Added join for consolidation type code
               gcs_treatments_b gtb
   WHERE       gtb.treatment_id(+)         =    gcr.treatment_id
   START WITH  gcr.parent_entity_id        =    p_consolidation_entity
   AND         gcr.hierarchy_id            =    p_consolidation_hierarchy
   --Bugfix 5192720: Added dominant parent flag join condition
   AND         gcr.dominant_parent_flag    =    'Y'
   AND         TO_DATE(l_cal_period_end_date, 'DD-MM-RR')
               BETWEEN gcr.start_date AND NVL(gcr.end_date,  TO_DATE(l_cal_period_end_date, 'DD-MM-RR'))
   CONNECT BY  PRIOR gcr.child_entity_id   =    gcr.parent_entity_id
   AND         gcr.hierarchy_id            =    p_consolidation_hierarchy
   AND         gcr.dominant_parent_flag    =    'Y'
   AND         TO_DATE(l_cal_period_end_date, 'DD-MM-RR')
               BETWEEN gcr.start_date AND NVL(gcr.end_date,  TO_DATE(l_cal_period_end_date, 'DD-MM-RR'));

   COMMIT;

   fnd_file.put_line(fnd_file.log, 'Submitting Workflow');

   --Bugfix 5197891: Assign the correct user rather than putting a null value
   WF_ENGINE.CreateProcess('GCSENGNE', l_event_key, 'CONS_ENTITY_PROCESS', l_event_key, FND_GLOBAL.USER_NAME);
   WF_ENGINE.SetItemAttrNumber('GCSENGNE', l_event_key, 'CONS_HIERARCHY', p_consolidation_hierarchy);
   WF_ENGINE.SetItemAttrNumber('GCSENGNE', l_event_key, 'CONS_ENTITY', p_consolidation_entity);
   WF_ENGINE.SetItemAttrText('GCSENGNE', l_event_key, 'RUN_IDENTIFIER', p_run_identifier);
   WF_ENGINE.SetItemAttrText('GCSENGNE', l_event_key, 'CAL_PERIOD', p_cal_period_id);
   WF_ENGINE.SetItemAttrText('GCSENGNE', l_event_key, 'PROCESS_METHOD', NVL(p_process_method, 'FULL'));
   WF_ENGINE.SetItemAttrText('GCSENGNE', l_event_key, 'CAL_PERIOD_END_DATE', l_cal_period_end_date);
   WF_ENGINE.SetItemAttrText('GCSENGNE', l_event_key, 'BALANCE_TYPE_CODE', p_balance_type_code);
   WF_ENGINE.SetItemAttrText('GCSENGNE', l_event_key, 'CONC_REQUEST_ID', FND_GLOBAL.CONC_REQUEST_ID);
   --Bugfix 5017120: Added support for multiple data types
   WF_ENGINE.SetItemAttrNumber('GCSENGNE', l_event_key, 'SOURCE_DATASET_CODE', l_source_dataset_code);
   WF_ENGINE.SetItemAttrNumber('GCSENGNE', l_event_key, 'HIERARCHY_DATASET_CODE', l_hierarchy_dataset_code);
   -- Bugfix 5569522: Added Analysis ID as an attribute to the consolidation workflow.
   -- set the value passed from the Submit Consolidation UI.
   WF_ENGINE.SetItemAttrNumber('GCSENGNE', l_event_key, 'ANALYSIS_CYCLE_ID', p_analysis_cycle_id);
   WF_ENGINE.StartProcess('GCSENGNE', l_event_key);

   fnd_file.put_line(fnd_file.log, 'End of Workflow');

   COMMIT;

   --Bugfix 5505707: Added label to end at and reset status of UI if consolidation kicked off from the self service interface
   <<ENDOFPROGRAM>>

   IF (l_error_message IS NOT NULL) AND (p_called_via_srs <> 'Y') THEN

      UPDATE gcs_cons_eng_runs
      SET    most_recent_flag       =       'Y'
      WHERE  most_recent_flag       =       'X'
      AND    run_entity_id          =       p_consolidation_entity
      AND    hierarchy_id           =       p_consolidation_hierarchy
      AND    cal_period_id          =       p_cal_period_id
      AND    balance_type_code      =       p_balance_type_code;

      UPDATE gcs_cons_eng_runs gcer
      SET    gcer.most_recent_flag  =       'Y'
      WHERE  gcer.most_recent_flag  =       'X'
      AND    gcer.hierarchy_id      =       p_consolidation_hierarchy
      AND    gcer.cal_period_id     =       p_cal_period_id
      AND    gcer.balance_type_code =       p_balance_type_code
      AND    EXISTS                         (SELECT 'X'
                                             FROM   gcs_cons_relationships gcr
                                             WHERE  gcr.child_entity_id = gcer.run_entity_id
                                             START WITH gcr.parent_entity_id = p_consolidation_entity
                                             AND    gcr.hierarchy_id         = p_consolidation_hierarchy
                                             AND    TO_DATE(l_cal_period_end_date, 'DD-MM-RR')
                                                        BETWEEN gcr.start_date AND     NVL(gcr.end_date,
                                                                                       TO_DATE(l_cal_period_end_date, 'DD-MM-RR'))
                                             CONNECT BY PRIOR gcr.child_entity_id = gcr.parent_entity_id
                                             --Bugfix 4122843: Added dominant parent flag condition
                                             AND    gcr.dominant_parent_flag = 'Y'
                                             AND    gcr.hierarchy_id         = p_consolidation_hierarchy
                                             AND    TO_DATE(l_cal_period_end_date, 'DD-MM-RR')
                                                        BETWEEN gcr.start_date AND     NVL(gcr.end_date,
                                                                                       TO_DATE(l_cal_period_end_date, 'DD-MM-RR')));
   END IF;

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.EXECUTE_CONSOLIDATION.end', '<<Exit>>');
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log, 'Error message is ' || SQLERRM);
      x_retcode := '2';
  END;

END;

/
