--------------------------------------------------------
--  DDL for Package Body GCS_INTERCO_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_INTERCO_PROCESSING_PKG" as
/* $Header: gcsicpeb.pls 120.6 2007/04/18 14:11:00 spala ship $ */

 -- Definition of Global Data Types and Variables

   	g_period_start_date DATE;
        g_period_end_date DATE;
	g_match_rule_code VARCHAR2(30);
	g_currency_code VARCHAR2(30);
        g_dimension_attr_info   gcs_utility_pkg.t_hash_dimension_attr_info
                           := gcs_utility_pkg.g_dimension_attr_info;
        g_gcs_dimension_info    gcs_utility_pkg.t_hash_gcs_dimension_info
                           := gcs_utility_pkg.g_gcs_dimension_info;
	g_fnd_user_id           NUMBER     := fnd_global.user_id;
        g_fnd_login_id          NUMBER     := fnd_global.login_id;
	   -- Action types for writing module information to the log file.

	-- A newline character. Included for convenience when writing long
        -- strings.
        g_nl              CONSTANT VARCHAR2 (1) := fnd_global.newline;
        g_pkg_name        VARCHAR2(80) := 'gcs.plsql.GCS_INTERCO_PROCESSING_PKG';
        g_no_rows         NUMBER :=0;
        l_no_rows         NUMBER :=0;
        g_elim_entity_id  NUMBER :=0;
        g_consolidation_run_name VARCHAR2(80);
        g_elim_code       VARCHAR2(5);
        g_elim_entity_name  VARCHAR2(150);
        g_cons_entity_id    NUMBER; /* For intra company */
        g_sus_exceed_no_rate   BOOLEAN := FALSE;
         -- Use the following global variable to stop the process
         -- If there are no rows inserted into GCS_INTERCOHDR_GT table.
         -- Set a proper value in the INSR_INTERCO_HDRS() routine.

        g_stop_processing BOOLEAN := FALSE;

        g_entity_id          NUMBER;
        g_xlation_required   VARCHAR2(10);



  --
  -- Procedure
  --   interco_process_main
  -- Purpose
  --   This is the main routine in the intercompany elimination entry
  --   processing engine.
  --   Important steps in this routine.
	-- 1)	Get the period information.
	-- 2)	Get the consolidation entity information like currency,
        --      matching rule.
        -- 3)	Get all the subsidiaries for the given consolidation entity.
     	-- 4)	Based on the elimination mode
        --      populate GCS_INTERCO_HDR_GT
        --      with corresponding information.
	-- 5)   Copy all the Intercompany transactions into the
	--      GCS_ENTRY_LINES by calling Insr_Interco_Lines routine.
	-- 6)   After successful suspense plug-in insert the header
        --      entries into the GCS_ENTRY_HEADERS table by calling
        --      the Insert Elimination Header procedure.
        -- 7)   All the above processing has to be completed in one
        --      commit cycle. So here we may COMMIT.

  -- Arguments
  -- Notes
  -- p_hierarchy_id      Hierarchy id
  -- p_cal_period_id     calendar period id
  -- p_entity_id         Consolidation entity id.
  -- p_balance_type      balance type like 'ACTUAL' or 'ADB'
  -- p_elim_mode         Elimination  mode  Valid values are 'IE' for Intercompany
  --                     or 'IA' for Intracompany
  -- p_currency_code     Currency code like 'USD', 'EUR', etc..,
  -- P_run_name          Consolidation run name.
  -- x_errbuf            Returns error message to concurrent manager if there is an error.
  -- x_ret_code          Returns error code to concurrent manager if there is an error.

  -- Syntax for calling from an external package.

  -- GCS_INTERCO_PROCESSING_PKG.Interco_process_Main
  --                               (10041,
  --                               24534640000000000000031002200140,
  --                                1030682,
  --			           'ACTUAL',
  --			             'IE',
  --                               'EUR',
  --                              'Srini Run');

  PROCEDURE INTERCO_PROCESS_MAIN(p_hierarchy_id IN NUMBER,
                                 p_cal_period_id IN NUMBER,
                                 p_entity_id IN NUMBER,
				 p_balance_type  VARCHAR2,
				 p_elim_mode  IN VARCHAR2,
                                 p_currency_code IN VARCHAR2,
                                 p_run_name IN VARCHAR2,
                                 p_translation_required IN VARCHAR2,
                                 x_errbuf OUT NOCOPY VARCHAR2,
                                 x_retcode OUT NOCOPY VARCHAR2) IS

   	l_period_start_date DATE;
	l_period_end_date DATE;
	l_api_name VARCHAR2(50) := 'INTERCO_PROCESS_MAIN';
        l_success   BOOLEAN := FALSE;

        no_period_dates  		EXCEPTION;
        no_currency_or_match_code 	EXCEPTION;
        no_elim_entity 			EXCEPTION;
        no_data_set_code    		EXCEPTION;
        INTERCO_SUS_LINE_ERR            EXCEPTION;
        INTERCO_LINE_ERR                EXCEPTION;
        INTERCO_HDR_GT_ERR              EXCEPTION;
        INTERCO_ELIM_HDR_ERR            EXCEPTION;
        Hierarchy_date_Check_Failed     EXCEPTION;

        l_hierarchy_id  	NUMBER;
        l_cal_period_id  	NUMBER;
        l_entity_id          	NUMBER;
        l_match_rule_code 	VARCHAR2(30);
        l_lob_dim_col_name      VARCHAR2(30);
        l_lob_rpt_enabled_flag  VARCHAR2(1);
        l_lob_hier_obj_id       NUMBER;
        --Bugfix 5149868: Modified balance type to 30 characters
	l_balance_type  	VARCHAR2(30);
	l_elim_mode  		VARCHAR2(4);
        l_Currency_code 	VARCHAR2(30);
        l_fem_ledger_id         NUMBER;

        l_start_period_id       NUMBER;
        l_end_period_id		NUMBER;
        l_suspense_exceeded     BOOLEAN := FALSE;

       l_subs_gt  NUMBER := 0;
       l_hdr_gt   NUMBER := 0;
       l_data_set_code  NUMBER :=0;
       l_err_code   VARCHAR2(200);
       l_err_msg    VARCHAR2(2000);
       l_hierarchy_valid_id    NUMBER; -- hierarchy object id after validation

       l_sql_stmt    VARCHAR2(8000);
       l_sql_stmt1 VARCHAR2(4000);
       l_text        VARCHAR2(1000);
       l_dims_list DBMS_SQL.varchar2_table;




  BEGIN

--dbms_output.Put_line('Log Level: '||FND_LOG.LEVEL_PROCEDURE);
--dbms_output.Put_line('G Level: '||FND_LOG.G_CURRENT_RUNTIME_LEVEL);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
    END IF;



    -- Assign consolidation run name to a global varaible.

    g_consolidation_run_name := p_run_name;
    g_entity_id := p_entity_id;
    g_xlation_required := p_translation_required;

    -- Reassign 'FALSE' to this flag otherwise the cons engine is
    -- caching this flag and generating weird results.

    g_stop_processing  := FALSE;


   --Get the period start date and end date information
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Get the period start date and end date info..,'
                          );
    END IF;

   BEGIN



       SELECT DATE_ASSIGN_VALUE
       INTO   g_period_start_date
       FROM   fem_cal_periods_attr fcpa
       WHERE  fcpa.cal_period_id = p_cal_period_id
       AND    fcpa.attribute_id =
          g_dimension_attr_info ('CAL_PERIOD_ID-CAL_PERIOD_START_DATE').attribute_id
       AND    fcpa.version_id = g_dimension_attr_info ('CAL_PERIOD_ID-CAL_PERIOD_START_DATE').version_id;

       SELECT DATE_ASSIGN_VALUE
       INTO   g_period_end_date
       FROM   fem_cal_periods_attr fcpa
       WHERE  fcpa.cal_period_id = p_cal_period_id
       AND    fcpa.attribute_id =
           g_dimension_attr_info ('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').attribute_id
        AND    fcpa.version_id = g_dimension_attr_info ('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').version_id;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
--dbms_output.put_line (' first excpetion');
       RAISE  no_period_dates;

   END;


   -- Get the consolidation entity currency and matching rule
   -- for matching intercompany eliminations such as by organization,
   -- by company or by cost center.

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Get currency and matching rule information'
                          );
    END IF;
    BEGIN

      SELECT ghb.ie_by_org_code,
             ghb.lob_dim_column_name,
             ghb.lob_reporting_enabled_flag,
             ghb.lob_hierarchy_obj_id,
             ghb.fem_ledger_id
      INTO   g_match_rule_code,
             l_lob_dim_col_name,
             l_lob_rpt_enabled_flag,
             l_lob_hier_obj_id,
             l_fem_ledger_id
      FROM GCS_HIERARCHIES_B ghb
      WHERE ghb.hierarchy_id = p_hierarchy_id;

      SELECT gcea.currency_code
      INTO   g_currency_code
      FROM   GCS_ENTITY_CONS_ATTRS gcea
      WHERE  gcea.hierarchy_id = p_hierarchy_id
      AND    gcea.entity_id = p_entity_id;

   EXCEPTION

     WHEN NO_DATA_FOUND Then
      Raise NO_CURRENCY_OR_MATCH_CODE;
   END;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Get the elimination entity id for the '
                           ||' given consolidation entity'
                          );
    END IF;




   IF (p_elim_mode = 'IE') THEN
     BEGIN
       SELECT DIM_ATTRIBUTE_NUMERIC_MEMBER
       INTO g_elim_entity_id
       FROM FEM_ENTITIES_ATTR
       WHERE attribute_id =
       g_dimension_attr_info ('ENTITY_ID-ELIMINATION_ENTITY').attribute_id
       AND   entity_id =  p_entity_id
       AND  version_id = g_dimension_attr_info ('ENTITY_ID-ELIMINATION_ENTITY').version_id;

       SELECT entity_name
       INTO g_elim_entity_name
       FROM FEM_ENTITIES_TL
       WHERE  LANGUAGE = userenv('LANG')
       AND   entity_id = g_elim_entity_id;


     EXCEPTION
      WHEN NO_DATA_FOUND THEN
	Raise NO_ELIM_ENTITY;
     END;

   ELSIF (p_elim_mode = 'IA') THEN

       g_elim_entity_id := p_entity_id;

       SELECT parent_entity_id
       INTO g_cons_entity_id
       FROM GCS_CONS_RELATIONSHIPS
       WHERE hierarchy_id = p_hierarchy_id
       AND   child_entity_id =  p_entity_id
       AND   dominant_parent_flag = 'Y'
       AND   actual_ownership_flag ='Y'
       AND (g_period_end_date
                BETWEEN NVL(start_date,TO_DATE('01/01/1950', 'MM/DD/YYYY'))
		      AND NVL(END_DATE, TO_DATE('12/31/9999', 'MM/DD/YYYY')));


       SELECT entity_name
       INTO g_elim_entity_name
       FROM FEM_ENTITIES_TL
       WHERE  LANGUAGE = userenv('LANG')
       AND   entity_id = g_elim_entity_id;
    END IF;


    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Insert parent child entity relationships into'
			   ||'GCS_INTERCO_SUBS_GT'
                          );
    END IF;

   BEGIN

     SELECT dataset_code
     INTO l_data_set_code
    FROM GCS_DATASET_CODES
     WHERE hierarchy_id = p_hierarchy_id
     AND  balance_type_code = p_balance_type;

   EXCEPTION

    WHEN OTHERS THEN
      RAISE  no_data_set_code;

   END;

   -- Assign passed arguments to the local varibles.

        l_hierarchy_id 		:= p_hierarchy_id;
        l_cal_period_id  	:= p_cal_period_id;
        l_entity_id          	:= p_entity_id;
        l_match_rule_code       := g_match_rule_code;
	l_balance_type  	:= p_balance_type;
	l_elim_mode  		:= p_elim_mode;
        g_elim_code             := p_elim_mode;
        l_Currency_code 	:= p_currency_code;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

      SELECT count(*) into g_no_rows
      from GCS_INTERCO_HDR_GT;
      FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'Number of rows in GCS_INTERCO_HDR_GT: '||g_no_rows);

      g_no_rows :=0;

      SELECT count(*) into g_no_rows
      from GCS_INTERCO_SUBS_GT;
      FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
                    'Number of rows in GCS_INTERCO_SUBS_GT: '||g_no_rows);

      g_no_rows :=0;

   END IF;





    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                         ' Arguments l_hierarchy_id :'||p_hierarchy_id
                         ||' l_cal_period_id: '||p_cal_period_id
                         ||' l_entity_id: '||p_entity_id
                         ||' l_match_rule_code: '||g_match_rule_code
                         ||' l_balance_type: '||p_balance_type
                         ||' l_elim_mode: '||p_elim_mode
                         ||' l_currency_code: '||p_currency_code
                         ||' Period End Date: '||g_period_end_date
                         ||' Period Start Date: '||g_period_start_date
                         ||' Data set Code: '||l_data_set_code
                         ||'  Translation Reuired: '||p_translation_required
                         ||' LOB Dim Column Name: '|| l_lob_dim_col_name
                         ||' LOB Reporting Enabled: '||l_lob_rpt_enabled_flag
                         ||' LOB Hierarchy Object Id: '||l_lob_hier_obj_id);

    END IF;

        g_no_rows   := 0;




   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Call insert_interco_hdrs() routine'
                          );
   END IF;


   IF ((INSR_INTERCO_HDRS ( p_hierarchy_id 	=> l_hierarchy_id,
                            p_cal_period_id 	=> l_cal_period_id,
                            p_entity_id 	=> l_entity_id,
		            p_balance_type 	=> l_balance_type,
		            p_elim_mode		=> l_elim_mode,
                            p_xlation_required  => p_translation_required,
                            p_currency_code	=> l_currency_code)) = FALSE)
                                                                          THEN


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

         fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Error in inserting rows into temporary table '
		          ||' SQL error message: '||SUBSTR(SQLERRM, 1, 255));
       RAISE INTERCO_HDR_GT_ERR;

   End If;

   End If;


   If (g_stop_processing) THEN

         g_stop_processing := FALSE;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                         ' No rows to process');
         fnd_log.STRING (fnd_log.level_procedure,
                       g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
    END IF;
       RETURN;
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          ' Call GCS_INTERCO_DYNAMIC_PKG.INSR_INTERCO_LINES()'
                          || ' routine to insert intercompany eliminations'
                          );
   END IF;

   -- calling routine to insert intercompany elimination lines.
   -- This routine inserts all eligible intercompany/intracompany
   -- eliminations from GCS_INTERCO_ELM_TRX (dataprep temp table)
   -- into GCS_ENTRY_LINES.

--dbms_output.put_line ('Just before calling insert lines');


   IF ((GCS_INTERCO_DYNAMIC_PKG.INSR_INTERCO_LINES (
        		p_hierarchy_id		=> l_hierarchy_id,
        		p_cal_period_id 	=> l_cal_period_id,
        		p_entity_id 		=> l_entity_id,
        		p_match_rule_code 	=> l_match_rule_code,
			p_balance_type	 	=> l_balance_type,
			p_elim_mode 		=> l_elim_mode,
        		p_currency_code		=> l_Currency_code,
                        p_dataset_code          => l_data_set_code,
                        p_lob_dim_col_name      => l_lob_dim_col_name,
                        p_cons_run_name         => g_consolidation_run_name,
                        p_period_end_date       => g_period_end_date,
                        p_fem_ledger_id         => l_fem_ledger_id))
                        = FALSE) THEN

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                           'Error in inserting intercompany lines into '
                           ||' GCS_ENTRY_LINES '
                           ||' SQL error message: '||SUBSTR(SQLERRM, 1, 255));

       RAISE INTERCO_LINE_ERR;
    END IF;


   End If;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          ' Call GCS_INTERCO_DYNAMIC_PKG.INSR_INTERCO_LINES()'
                          || ' routine to insert suspense elimination'
                          || ' lines.');
   END IF;


  -- This routine inserts suspense lines for unbalanced matched rows and
   -- unmatched elimination entries to balance.
        -- EXAMPLE
        --   ORG_ID     Line	Interco_id	Cr	      Dr
	-------------------------------------------------------------
        --   01.1001   	2020	02.2004        100.00
        --   02.2004	2020    01.1001                     80.00

        --  In the above transactions there are matched transactions
	--  but the balances are off by 20. So a suspense line
	-- will be generated with balance 20.

	-- The second SQL statement generates suspense line for the unmatched
        -- intercompany transactions.

	-- EXAMPLE
        --   ORG_ID     Line	Interco_id	Cr	      Dr
	-------------------------------------------------------------
	--	01.6677 	3434		02.9978		100.00

 	-- If you look at the above transaction there is no matching
	-- intercompany transaction, so a suspense line has to be created
	-- to balance the above transaction.

  IF ((GCS_INTERCO_DYNAMIC_PKG.INSR_SUSPENSE_LINES (
        		p_hierarchy_id		=> l_hierarchy_id,
        		p_cal_period_id 	=> l_cal_period_id,
        		p_entity_id 		=> l_entity_id,
        		p_match_rule_code 	=> l_match_rule_code,
			p_balance_type	 	=> l_balance_type,
			p_elim_mode 		=> l_elim_mode,
        		p_currency_code		=> l_Currency_code,
                        p_data_set_code         => l_data_set_code,
                        p_err_code              => l_err_code,
                        p_err_msg               => l_err_msg)) = FALSE)
                                                                          THEN


     RAISE INTERCO_SUS_LINE_ERR;


   End If;


   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          ' Call GCS_INTERCO_DYNAMIC_PKG.INSR_INTERCO_LINES()'
                          || ' routine to insert suspense elimination'
                          || ' lines.');
   END IF;

   -- Insert elimination headers into GCS_ENTRY_HEADERS.

   IF( (INSR_ELIMINATION_HDRS(p_hierarchy_id 	=> l_hierarchy_id,
                         p_cal_period_id  	=> l_cal_period_id,
                         p_entity_id 		=> l_entity_id,
                         p_balance_type 	=> l_balance_type,
		         p_currency_code 	=> l_Currency_code)) = FALSE)
                                                                          THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                           'Error in inserting elimination headers '
                           ||' GCS_ENTRY_LINES '
		           ||' SQL error message: '||SUBSTR(SQLERRM, 1, 255));
      RAISE INTERCO_ELIM_HDR_ERR;
   End If;

   End If;


  -- This part of the code added as part of the JPMC LE/LOB support
  -- enhancement.
  -- IF Lob_Reporting is enabled then the lob_dim_col has to be
  -- populated with common elimination line of business (cost center value)
  -- for the suspense lines created by the intercompany processing.

     If ((l_lob_rpt_enabled_flag = 'Y') AND
                    (l_lob_dim_col_name IS NOT NULL)) THEN


        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          ' Entered into LE_LOB support  block');

        END IF;

       BEGIN

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          ' Checking Hierarchy Date effectivity');

        END IF;

        SELECT object_definition_id INTO l_hierarchy_valid_id
         FROM FEM_OBJECT_DEFINITION_B fod
         WHERE  fod.object_id = l_lob_hier_obj_id
         AND    (g_period_end_date
                BETWEEN NVL(fod.effective_start_date,
                      TO_DATE('01/01/1950','MM/DD/YYYY'))
	               AND NVL(fod.effective_end_date,
                         TO_DATE('12/31/9999','MM/DD/YYYY')));


       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_hierarchy_valid_id :=0;
           null;
           --Raise Hierarchy_date_Check_Failed;

        WHEN OTHERS THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
	                   g_pkg_name || '.' || l_api_name
                           ||' Hierarchy_Check  ',
                           SUBSTR(SQLERRM, 1, 255));

          END IF;

       END;

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          ' Finding required dimensions');

      END IF;

           SELECT member_col
             BULK COLLECT INTO l_dims_list
             FROM fem_xdim_dimensions
             WHERE gcs_utility_pkg.Get_Dimension_Required(member_col) = 'Y'
             AND member_col <> 'ENTITY_ID';

             FOR i in l_dims_list.first .. l_dims_list.last loop

	       l_text := l_text||g_nl|| '       AND   gel.'||l_dims_list(i)
                         ||' = gel1.'
                         ||l_dims_list(i);
             END LOOP;

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Required dimensions statement is : '
                          ||l_text
                          ||'  Lob_Dim_Col_Name is: '
                          || l_lob_dim_col_name);

      END IF;

     l_sql_stmt := 'UPDATE  GCS_ENTRY_LINES gel1
	    SET '||l_lob_dim_col_name||'  = (SELECT
                                    DECODE(
                                    fcoa2.dim_attribute_numeric_member,
                                    fcoa3.dim_attribute_numeric_member,
                                    fcoa2.dim_attribute_numeric_member,
                                    NVL(fcca.dim_attribute_numeric_member,
                                    gel1.'||l_lob_dim_col_name||'))
                               FROM GCS_ENTRY_LINES gel,
                                    fem_cctr_orgs_attr fcoa2,
                                    fem_cctr_orgs_attr fcoa3,
                                    fem_user_dim1_attr fcca
                                WHERE  gel.entry_id = gel1.entry_id
                                AND    gel.company_cost_center_org_id =
                                         gel1.company_cost_center_org_id
                                AND    gel.intercompany_id =
                                          gel1.intercompany_id
                                AND    gel.line_item_id = gel1.line_item_id
                AND    gel.company_cost_center_org_id =
                                           fcoa2.company_cost_center_org_id
                                                                           '
                ||l_text||
                 '
                  AND    fcoa2.attribute_id  = :attribute_id
                  AND    fcoa2.version_id    = :version_id
                  AND    gel.intercompany_id = fcoa3.company_cost_center_org_id
                  AND    fcoa3.attribute_id  = :attribute_id
                  AND    fcoa3.version_id    = :version_id
                  AND    fcca.user_dim1_id = ';
               l_sql_stmt1 := '(
                        SELECT fcch1.parent_id
                        FROM  fem_user_dim1_hier fcch1,
                              fem_user_dim1_hier fcch2
                        WHERE  fcch1.child_id =
                                            fcoa2.dim_attribute_numeric_member
                        AND    fcch1.hierarchy_obj_def_id =
                                     :hierarchy_id
                        AND    fcch1.parent_id <> fcch1.child_id
                         AND    fcch2.child_id =
                                        fcoa3.dim_attribute_numeric_member
                        AND    fcch2.hierarchy_obj_def_id =
                                      :hierarchy_id
                        AND    fcch2.parent_id <> fcch2.child_id
                         AND    fcch1.parent_id = fcch2.parent_id
                        AND    fcch1.parent_depth_num =
                               (SELECT MAX(fcch3.parent_depth_num)
                                FROM  fem_user_Dim1_hier fcch3,
                                      fem_user_dim1_hier fcch4
                                WHERE fcch3.child_id =
                                       fcoa2.dim_attribute_numeric_member
                                AND    fcch3.hierarchy_obj_def_id =
                                            :hierarchy_id
                                AND    fcch3.parent_id <> fcch3.child_id
                                 AND    fcch4.child_id =
                                           fcoa3.dim_attribute_numeric_member
                                AND    fcch4.hierarchy_obj_def_id =
                                            :hierarchy_id
                                AND    fcch4.parent_id <> fcch4.child_id
                                AND    fcch3.parent_id = fcch4.parent_id))
                 AND    fcca.attribute_id = :attribute_id
                 AND    fcca.version_id   = :version_id)
           WHERE ENTRY_ID IN ( SELECT ENTRY_ID FROM GCS_INTERCO_HDR_GT)
           AND  description = ''SUSPENSE_LINE''';

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

            fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                         'Updating '|| l_lob_dim_col_name
                          ||' in GCS_ENTRY_LINES with elimination LOB'
                        );

        END IF;

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                        l_sql_stmt
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                        l_sql_stmt1
                        );
        END IF;

          l_sql_stmt := l_sql_stmt||l_sql_stmt1;

          EXECUTE IMMEDIATE l_sql_stmt
                  USING
g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COST_CENTER').attribute_id,
g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COST_CENTER').version_id,
g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COST_CENTER').attribute_id,
g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COST_CENTER').version_id,
l_hierarchy_valid_id, l_hierarchy_valid_id,
l_hierarchy_valid_id, l_hierarchy_valid_id,
g_dimension_attr_info('USER_DIM1_ID-ELIMINATION_LOB').attribute_id,
g_dimension_attr_info('USER_DIM1_ID-ELIMINATION_LOB').version_id;


        g_no_rows   := NVL(SQL%ROWCOUNT,0);

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0118');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_LINES');


	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
          --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0118: '||FND_MESSAGE.get);
       END IF;




     END IF;


  -- Consolidation engine does not want to be commited these changes.
  -- Consolidation engine has its own logic to commit all these changes.

    --COMMIT;

    IF (g_sus_exceed_no_rate) THEN
      x_errbuf := 'WARNING';
    END IF;


 --Success:
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
    END IF;

  EXCEPTION

   WHEN no_period_dates THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

               fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                         ' No valid period information available '
                          );

       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_pkg_name || '.' || l_api_name,
                       SUBSTR(SQLERRM, 1, 255));

       fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
    END IF;
    x_errbuf := 'Error In the IntercoProcess_Routine';
    x_retcode:='2';

    RAISE;



   WHEN no_currency_or_match_code THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

               fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                         ' No currency or matching rule'
                          );

       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_pkg_name || '.' || l_api_name,
                       SUBSTR(SQLERRM, 1, 255));

       fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
    END IF;
    RAISE;

   WHEN  no_elim_entity THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

               fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                         ' No elimination entity associated '
                          );

       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_pkg_name || '.' || l_api_name,
                       SUBSTR(SQLERRM, 1, 255));

       fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
    END IF;
    RAISE;

  WHEN no_data_set_code  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

               fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                         ' No valid dataset code available '
                          );

       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_pkg_name || '.' || l_api_name,
                       SUBSTR(SQLERRM, 1, 255));

       fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
    END IF;
    x_errbuf := 'Error In the IntercoProcess_Routine';
    x_retcode:='2';

    RAISE;

   WHEN  INTERCO_SUS_LINE_ERR THEN
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

          fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                         ' Error In Insert_Suspense_lines() '
                         || SUBSTR(l_err_msg, 1, 255));

          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                          g_pkg_name || '.' || l_api_name,
                          SUBSTR(l_err_msg, 1, 255));

          fnd_log.STRING (fnd_log.level_unexpected,
                          g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
       END IF;

       ROLLBACK TO gcs_cons_eng_insr_warning;

       x_errbuf := 'Error in Insert_Suspense_lines()';
       x_retcode:='2';

    RAISE;


   WHEN  INTERCO_LINE_ERR THEN

       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

          fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                         ' Error In Insert_Interco_lines() '
                         || SUBSTR(SQLERRM, 1, 255));

          fnd_log.STRING (fnd_log.level_unexpected,
                          g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
       END IF;

       ROLLBACK TO gcs_cons_eng_insr_warning;

       x_errbuf := 'Error in Insert_Interco_lines()';
       x_retcode:='2';

    RAISE;


   WHEN  INTERCO_HDR_GT_ERR THEN

       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

          fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                         ' Error In Insert_Interco_Hdrs() '
                         || SUBSTR(SQLERRM, 1, 255));

          fnd_log.STRING (fnd_log.level_unexpected,
                          g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
       END IF;

       ROLLBACK TO gcs_cons_eng_insr_Hdr_warning;

       x_errbuf := 'Error in Insert_Interco_Hdrs()';
       x_retcode:='2';

    RAISE;


   WHEN  INTERCO_ELIM_HDR_ERR THEN

       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

          fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                         ' Error In Insert_Elimination_Hdrs() '
                         || SUBSTR(SQLERRM, 1, 255));

          fnd_log.STRING (fnd_log.level_unexpected,
                          g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
       END IF;

       ROLLBACK TO gcs_cons_eng_insr_warning;

       x_errbuf := 'Error in Insert_Elimination_Hdrs()';
       x_retcode:='2';

    RAISE;

    WHEN Hierarchy_Date_Check_Failed  THEN

      x_errbuf := SQLERRM;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED)
                                                                          THEN
           FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
	                   g_pkg_name || '.' || l_api_name
                           || ' Hierarchy_Check_Failed',
                           'Either hierarchy does not exist or the '
                           ||' hierarchy date affectivity has not been '
                           || ' passed ');


       END IF;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
	                   g_pkg_name || '.' || l_api_name,
                           SUBSTR(SQLERRM, 1, 255));


       END IF;


   WHEN NO_DATA_FOUND THEN

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_pkg_name || '.' || l_api_name,
                       SUBSTR(SQLERRM, 1, 255));

         fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
    END IF;

   RAISE;

   WHEN OTHERS THEN


     IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN


        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_pkg_name || '.' || l_api_name,
                       SUBSTR(SQLERRM, 1, 255));

        fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
    END IF;

   RAISE;

 END interco_process_main;




  --
  -- Function
  --   insr_interco_hdrs
  -- Purpose
  --   This routine is responsible for inserting distinct pairs of entities
  --   for each intercompany rule into the global temporary table
  --   GCS_INTERCO_HDR_GT.


  FUNCTION  INSR_INTERCO_HDRS   (p_hierarchy_id IN NUMBER,
                                 p_cal_period_id IN NUMBER,
                                 p_entity_id IN NUMBER,
				 p_balance_type  VARCHAR2,
				 p_elim_mode  IN VARCHAR2,
                                 p_xlation_required IN VARCHAR2,
                                 p_currency_code IN VARCHAR2) RETURN BOOLEAN IS

   -- l_dummy NUMBER;   /* Not in use */
   l_api_name VARCHAR2(30) := 'INSR_INTERCO_HDRS';

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
    END IF;

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                         ' Arguments passed to Insr_Interco_Hdr() '
                         ||' Hierarchy_Id :'||p_hierarchy_id
                         ||' Cal_Period_Id: '||p_cal_period_id
                         ||' Entity_Id: '||p_entity_id
                         ||' Balance_Type: '||p_balance_type
                         ||' Elim_Mode: '||p_elim_mode
                         ||' Currency_Code: '||p_currency_code);

    END IF;


   IF (p_elim_mode = 'IE') THEN
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Insert distinct pairs of entities for each rule '
			   || 'into GCS_INTERCO_HDR_GT in full '
                           || 'consolidation run mode and elim-mode=''IE'''
                           || '- Intercompany rule on Receivables side'
                          );
     END IF;


     -- Fixed bug# 4217286.
     -- Added DECODE(fc.currency_code,'STAT',10000,
     --                    gib.sus_financial_elem_id) "SUS_FINANCIAL_ELEM_ID"
     -- to the following statement.

             INSERT INTO GCS_INTERCO_HDR_GT
            (entry_id, source_entity_id, target_entity_id, rule_id,
             threshold_currency,threshold_amount,sus_financial_elem_id,
             sus_product_id,sus_natural_account_id,
             sus_channel_id,sus_line_item_id,sus_project_id,sus_customer_id,
             sus_task_id, sus_user_dim1_id, sus_user_dim2_id,sus_user_dim3_id,
             sus_user_dim4_id, sus_user_dim5_id, sus_user_dim6_id,
             sus_user_dim7_id, sus_user_dim8_id, sus_user_dim9_id,
             sus_user_dim10_id, creation_date, created_by,
             last_update_date, last_updated_by, last_update_login,
             currency_code)
             SELECT GCS_ENTRY_HEADERS_S.NEXTVAL, git.src_id,
                   git.tar_id, git.rule_id,
                   git.threshold_currency,
                   git.threshold_amount, git.sus_financial_elem_id,
                   git.sus_product_id,git.sus_natural_account_id,
                   git.sus_channel_id,git.sus_line_item_id,
                   git.sus_project_id,git.sus_customer_id,
                   git.sus_task_id,git.sus_user_dim1_id,
                   git.sus_user_dim2_id,git.sus_user_dim3_id,
                   git.sus_user_dim4_id, git.sus_user_dim5_id,
                   git.sus_user_dim6_id, git.sus_user_dim7_id,
                   git.sus_user_dim8_id, git.sus_user_dim9_id,
                   git.sus_user_dim10_id,SYSDATE,g_fnd_user_id,sysdate,
                   g_fnd_user_id,g_fnd_login_id, git.currency_code
            FROM (SELECT giet.src_entity_id
                        src_id,
                        giet.target_entity_id
                        tar_id,
                        gib.rule_id, gib.threshold_currency,
            		gib.threshold_amount,
                        DECODE(fc.currency_code,'STAT',10000,
                        gib.sus_financial_elem_id) "SUS_FINANCIAL_ELEM_ID",
            		gib.sus_product_id, gib.sus_natural_account_id,
            		gib.sus_channel_id, gib.sus_line_item_id,
            		gib.sus_project_id, gib.sus_customer_id,
            		gib.sus_task_id, gib.sus_user_dim1_id,
            		gib.sus_user_dim2_id, gib.sus_user_dim3_id,
            		gib.sus_user_dim4_id, gib.sus_user_dim5_id,
            		gib.sus_user_dim6_id, gib.sus_user_dim7_id,
            		gib.sus_user_dim8_id, gib.sus_user_dim9_id,
            		gib.sus_user_dim10_id, fc.currency_code
            		FROM 	GCS_INTERCO_ELM_TRX giet,
                                GCS_FLATTENED_RELNS gfr,
				GCS_FLATTENED_RELNS gfr1,
                 		GCS_INTERCO_MEMBERS gim,
                 		GCS_INTERCO_RULES_B gib ,
                                FND_CURRENCIES fc
            		WHERE giet.hierarchy_id = p_hierarchy_id
                        AND   giet.cal_period_id = p_cal_period_id
            		AND   fc.currency_code IN (p_currency_code,'STAT')
                        AND   gfr.run_name = g_consolidation_run_name
                        AND   gfr.parent_entity_id = p_entity_id
			AND   giet.src_entity_id = gfr.child_entity_ID
                        AND   NVL(gfr.consolidation_type_code,'X')  <> 'NONE'
                        AND   gfr1.run_name = g_consolidation_run_name
                        AND   gfr1.parent_entity_id = p_entity_id
			AND   giet.target_entity_id = gfr1.child_entity_id
                        AND   NVL(gfr1.consolidation_type_code,'X')  <> 'NONE'
                        AND   giet.src_entity_id <> giet.target_entity_id
            		AND   giet.line_item_id = gim.line_item_id
                        AND   gim.line_item_group = 1
            		AND   gim.rule_id = gib.rule_id
            		AND   gib.enabled_flag = 'Y'
                       AND NOT EXISTS
                              (SELECT 'X' FROM gcs_interco_elm_trx giet1,
                                               gcs_interco_members gim1
                               WHERE  giet1.hierarchy_id = p_hierarchy_id
                               AND    giet1.cal_period_id = p_cal_period_id
                               AND    giet1.src_entity_id =
                                                   giet.target_entity_id
                               AND    giet1.target_entity_id =
                                                     giet.src_entity_id
                               AND    gim1.rule_id = gim.rule_id
                               AND     giet1.company_cost_center_org_id >
                                                     giet1.intercompany_id
                               AND    gim1.line_item_group >
                                                 gim.line_item_group
                               AND    gim1.line_item_id = gim.line_item_id)

            		GROUP BY
                           giet.src_entity_id,
                           giet.target_entity_id,
                           gib.rule_id,gib.threshold_currency,
                           gib.threshold_amount,
                           gib.sus_financial_elem_id,
                     		gib.sus_product_id,gib.sus_natural_account_id,
                     		gib.sus_channel_id,gib.sus_line_item_id,
                     		gib.sus_project_id,gib.sus_customer_id,
                     		gib.sus_task_id,gib.sus_user_dim1_id,
                     		gib.sus_user_dim2_id,gib.sus_user_dim3_id,
                     		gib.sus_user_dim4_id, gib.sus_user_dim5_id,
                     		gib.sus_user_dim6_id, gib.sus_user_dim7_id,
                     		gib.sus_user_dim8_id, gib.sus_user_dim9_id,
                     		gib.sus_user_dim10_id, fc.currency_code) git
            WHERE NOT EXISTS
                      (SELECT 'X'
                       FROM   GCS_CONS_ENG_RUN_DTLS gcer
                       WHERE  gcer.child_entity_id =  git.src_id
                       AND    gcer.contra_child_entity_id = git.tar_id
                       AND    gcer.run_name = g_consolidation_run_name);


          g_no_rows   := NVL(SQL%ROWCOUNT,0);


       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
         FND_MESSAGE.Set_Token('NUM',TO_CHAR(NVL(SQL%ROWCOUNT,0)));
         FND_MESSAGE.Set_Token('TABLE','GCS_INTERCO_HDR_GT');



	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
       END IF;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Insert distinct pairs of entities for each rule '
			   || 'into GCS_INTERCO_HDR_GT in full '
                           || 'consolidation run mode and elim-mode=''IE'''
                           || '- Intercompany rule Payables  side'
                          );
     END IF;

     -- Fixed bug# 4217286.
     -- Added DECODE(fc.currency_code,'STAT',10000,
     --                    gib.sus_financial_elem_id) "SUS_FINANCIAL_ELEM_ID"
     -- to the following statement.

             INSERT INTO GCS_INTERCO_HDR_GT
            (entry_id, source_entity_id, target_entity_id, rule_id,
             threshold_currency,threshold_amount,sus_financial_elem_id,
             sus_product_id,sus_natural_account_id,
             sus_channel_id,sus_line_item_id,sus_project_id,sus_customer_id,
             sus_task_id, sus_user_dim1_id, sus_user_dim2_id,sus_user_dim3_id,
             sus_user_dim4_id, sus_user_dim5_id, sus_user_dim6_id,
             sus_user_dim7_id, sus_user_dim8_id, sus_user_dim9_id,
             sus_user_dim10_id, creation_date, created_by,
             last_update_date, last_updated_by, last_update_login,
             currency_code)
             SELECT GCS_ENTRY_HEADERS_S.NEXTVAL, git.src_id,
                   git.tar_id, git.rule_id,
                   git.threshold_currency,
                   git.threshold_amount, git.sus_financial_elem_id,
                   git.sus_product_id,git.sus_natural_account_id,
                   git.sus_channel_id,git.sus_line_item_id,
                   git.sus_project_id,git.sus_customer_id,
                   git.sus_task_id,git.sus_user_dim1_id,
                   git.sus_user_dim2_id,git.sus_user_dim3_id,
                   git.sus_user_dim4_id, git.sus_user_dim5_id,
                   git.sus_user_dim6_id, git.sus_user_dim7_id,
                   git.sus_user_dim8_id, git.sus_user_dim9_id,
                   git.sus_user_dim10_id,SYSDATE,g_fnd_user_id,sysdate,
                   g_fnd_user_id,g_fnd_login_id, git.currency_code
            FROM (SELECT giet.target_entity_id
                        src_id,
                        giet.src_entity_id
                        tar_id,
                        gib.rule_id, gib.threshold_currency,
            		gib.threshold_amount,
                        DECODE(fc.currency_code,'STAT',10000,
                        gib.sus_financial_elem_id) "SUS_FINANCIAL_ELEM_ID",
            		gib.sus_product_id, gib.sus_natural_account_id,
            		gib.sus_channel_id, gib.sus_line_item_id,
            		gib.sus_project_id, gib.sus_customer_id,
            		gib.sus_task_id, gib.sus_user_dim1_id,
            		gib.sus_user_dim2_id, gib.sus_user_dim3_id,
            		gib.sus_user_dim4_id, gib.sus_user_dim5_id,
            		gib.sus_user_dim6_id, gib.sus_user_dim7_id,
            		gib.sus_user_dim8_id, gib.sus_user_dim9_id,
            		gib.sus_user_dim10_id, fc.currency_code
            		FROM 	GCS_INTERCO_ELM_TRX giet,
                                GCS_FLATTENED_RELNS gfr,
				GCS_FLATTENED_RELNS gfr1,
                 		GCS_INTERCO_MEMBERS gim,
                 		GCS_INTERCO_RULES_B gib ,
                                FND_CURRENCIES fc
            		WHERE giet.hierarchy_id = p_hierarchy_id
                        AND   giet.cal_period_id = p_cal_period_id
            		AND   fc.currency_code IN (p_currency_code,'STAT')
                        AND   gfr.run_name = g_consolidation_run_name
                        AND   gfr.parent_entity_id = p_entity_id
			AND   giet.src_entity_id = gfr.child_entity_ID
                        AND   NVL(gfr.consolidation_type_code,'X')  <> 'NONE'
                        AND   gfr1.run_name = g_consolidation_run_name
                        AND   gfr1.parent_entity_id = p_entity_id
			AND   giet.target_entity_id = gfr1.child_entity_id
                        AND   NVL(gfr1.consolidation_type_code,'X')  <> 'NONE'
                        AND   giet.src_entity_id <> giet.target_entity_id
            		AND   giet.line_item_id = gim.line_item_id
                        AND   gim.line_item_group = 2
            		AND   gim.rule_id = gib.rule_id
            		AND   gib.enabled_flag = 'Y'
                        AND   NOT EXISTS
                                 (SELECT 'Y'
                                  FROM    GCS_INTERCO_HDR_GT gihg1,
                                          GCS_INTERCO_MEMBERS gim1
                                  WHERE   gihg1.target_entity_id =
                                          DECODE(gim1.line_item_id,
                                                    gim.line_item_id,
                                                     giet.target_entity_id,
                                                         giet.src_entity_id)
                                  AND     gihg1.source_entity_id =
                                            DECODE(gim1.line_item_id,
                                                     gim.line_item_id,
                                                       giet.src_entity_id,
                                                         giet.target_entity_id)
                                  AND     gihg1.rule_id = gim.rule_id
                                  AND     gihg1.rule_id = gim.rule_id
                                  AND     gim1.rule_id = gihg1.rule_id
                                  AND     gim1.line_item_group = 1)
            		GROUP BY
                           giet.src_entity_id,
                           giet.target_entity_id,
                           gib.rule_id,gib.threshold_currency,
                           gib.threshold_amount,
                           gib.sus_financial_elem_id,
                     		gib.sus_product_id,gib.sus_natural_account_id,
                     		gib.sus_channel_id,gib.sus_line_item_id,
                     		gib.sus_project_id,gib.sus_customer_id,
                     		gib.sus_task_id,gib.sus_user_dim1_id,
                     		gib.sus_user_dim2_id,gib.sus_user_dim3_id,
                     		gib.sus_user_dim4_id, gib.sus_user_dim5_id,
                     		gib.sus_user_dim6_id, gib.sus_user_dim7_id,
                     		gib.sus_user_dim8_id, gib.sus_user_dim9_id,
                     		gib.sus_user_dim10_id, fc.currency_code) git
            WHERE NOT EXISTS
                      (SELECT 'X'
                       FROM   GCS_CONS_ENG_RUN_DTLS gcer
                       WHERE  gcer.child_entity_id =  git.src_id
                       AND    gcer.contra_child_entity_id = git.tar_id
                       AND    gcer.run_name = g_consolidation_run_name);

      IF (NVL(SQL%ROWCOUNT,0) <> 0) THEN
         g_no_rows   := NVL(SQL%ROWCOUNT,0);
      END IF;

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
         FND_MESSAGE.Set_Token('NUM',TO_CHAR(NVL(SQL%ROWCOUNT,0)));
         FND_MESSAGE.Set_Token('TABLE','GCS_INTERCO_HDR_GT');



	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
       END IF;
    -- Start Bugfix 5974635

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Delete pair(s) of entities that are already'
			   || ' eliminated, for e.g. at a mid level parent'
                          );
     END IF;

         DELETE FROM GCS_INTERCO_HDR_GT gihg
         WHERE EXISTS
         (SELECT 'X'   FROM   GCS_CONS_ENG_RUN_DTLS gcer
                       WHERE  gcer.run_name = g_consolidation_run_name
                       AND    gcer.category_code = 'INTERCOMPANY'
                       AND    gcer.child_entity_id = gihg.target_entity_id
                       AND    gcer.contra_child_entity_id =
                                               gihg.source_entity_id
                       AND    gcer.rule_id = gihg.rule_id
                       AND    gcer.consolidation_entity_id <>
                                  g_entity_id);

     l_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0119');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(l_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_INTERCO_HDR_GT');


	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);

     END IF;

     -- End Bugfix 5974635

   ELSIF (p_elim_mode = 'IA') THEN

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Insert distinct pairs of entities for each rule '
			   || 'into GCS_INTERCO_HDR_GT in full '
                           || 'consolidation run mode and elim-mode=''IA'''
                          );
       END IF;

             INSERT INTO  GCS_INTERCO_HDR_GT
            (entry_id, source_entity_id, target_entity_id, rule_id,
             threshold_currency,threshold_amount,sus_financial_elem_id,
             sus_product_id,sus_natural_account_id,
             sus_channel_id,sus_line_item_id,sus_project_id,sus_customer_id,
             sus_task_id, sus_user_dim1_id, sus_user_dim2_id,sus_user_dim3_id,
             sus_user_dim4_id, sus_user_dim5_id, sus_user_dim6_id,
             sus_user_dim7_id, sus_user_dim8_id, sus_user_dim9_id,
             sus_user_dim10_id, creation_date, created_by,
             last_update_date, last_updated_by, last_update_login,
             currency_code)
             SELECT GCS_ENTRY_HEADERS_S.NEXTVAL, git.src_entity_id,
                   git.target_entity_id, git.rule_id,
                   git.threshold_currency,
                   git.threshold_amount, git.sus_financial_elem_id,
                   git.sus_product_id,git.sus_natural_account_id,
                   git.sus_channel_id,git.sus_line_item_id,
                   git.sus_project_id,git.sus_customer_id,
                   git.sus_task_id,git.sus_user_dim1_id,
                   git.sus_user_dim2_id,git.sus_user_dim3_id,
                   git.sus_user_dim4_id, git.sus_user_dim5_id,
                   git.sus_user_dim6_id, git.sus_user_dim7_id,
                   git.sus_user_dim8_id, git.sus_user_dim9_id,
                   git.sus_user_dim10_id,SYSDATE,g_fnd_user_id,SYSDATE,
                   g_fnd_user_id,g_fnd_login_id, git.currency_code
            FROM (SELECT giet.src_entity_id,giet.target_entity_id,
                        gib.rule_id, gib.threshold_currency,
            		gib.threshold_amount, gib.sus_financial_elem_id,
            		gib.sus_product_id, gib.sus_natural_account_id,
            		gib.sus_channel_id, gib.sus_line_item_id,
            		gib.sus_project_id, gib.sus_customer_id,
            		gib.sus_task_id, gib.sus_user_dim1_id,
            		gib.sus_user_dim2_id, gib.sus_user_dim3_id,
            		gib.sus_user_dim4_id, gib.sus_user_dim5_id,
            		gib.sus_user_dim6_id, gib.sus_user_dim7_id,
            		gib.sus_user_dim8_id, gib.sus_user_dim9_id,
            		gib.sus_user_dim10_id, fc.currency_code
            		FROM 	GCS_INTERCO_ELM_TRX giet,
                 		GCS_INTERCO_MEMBERS gim,
                 		GCS_INTERCO_RULES_B gib,
                                FND_CURRENCIES fc
            		WHERE giet.hierarchy_id = p_hierarchy_id
                        AND   giet.cal_period_id = p_cal_period_id
            		AND   fc.currency_code IN (P_currency_code, 'STAT')
			AND   giet.src_entity_id = p_entity_id
			AND   giet.target_entity_id = giet.src_entity_id
            		AND   giet.line_item_id = gim.line_item_id
            		AND   gim.rule_id = gib.rule_id
            		AND   gib.enabled_flag = 'Y'
            		GROUP BY giet.src_entity_id,giet.target_entity_id,
                     		gib.rule_id,gib.threshold_currency,
                     		gib.threshold_amount,
                                gib.sus_financial_elem_id,
                     		gib.sus_product_id,gib.sus_natural_account_id,
                     		gib.sus_channel_id,gib.sus_line_item_id,
                     		gib.sus_project_id,gib.sus_customer_id,
                     		gib.sus_task_id,gib.sus_user_dim1_id,
                     		gib.sus_user_dim2_id,gib.sus_user_dim3_id,
                     		gib.sus_user_dim4_id, gib.sus_user_dim5_id,
                     		gib.sus_user_dim6_id, gib.sus_user_dim7_id,
                     		gib.sus_user_dim8_id, gib.sus_user_dim9_id,
                     		gib.sus_user_dim10_id , fc.currency_code) git;

	g_no_rows   := NVL(SQL%ROWCOUNT,0);

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_INTERCO_HDR_GT');


	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
         --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
        END IF;

   END IF; -- End of Intercompany or intra company modes.

   IF (g_no_rows <= 0) THEN

      g_stop_processing := TRUE;


      RETURN TRUE;
   END IF;


       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Insert avialable information '
			   || 'into GCS_CONS_ENG_RUN_DTLS '
                           || ' if there is an error the information will be'
                           || ' saved upto this point.'
                          );
       END IF;

       INSERT INTO gcs_cons_eng_run_dtls
             (run_detail_id, run_name, Consolidation_entity_id
             , child_entity_id, contra_child_entity_id, entry_id, rule_id,
               request_error_code, bp_request_error_code, category_code,
               creation_date, created_by, last_update_date,
               last_updated_by, last_update_login)
      SELECT gcs_cons_eng_run_dtls_s.nextval,
             g_consolidation_run_name,
             DECODE(g_elim_code, 'IE',p_entity_id,'IA', g_cons_entity_id),
             gehg.source_entity_id, gehg.target_entity_id,
             gehg.entry_id, gehg.rule_id,
             'WARNING', 'WARNING',
             DECODE(g_elim_code, 'IE', 'INTERCOMPANY', 'IA', 'INTRACOMPANY'),
             SYSDATE, g_fnd_user_id,
             SYSDATE, g_fnd_user_id,
             g_fnd_login_id
       FROM  GCS_INTERCO_HDR_GT gehg
       WHERE gehg.currency_code <> 'STAT';


	g_no_rows   := NVL(SQL%ROWCOUNT,0);

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_CONS_ENG_RUN_DTLS');

	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
         --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
        END IF;

/* ------------------------------------------------------------------------+

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'STAT rows- with serate rule'
                           ||' Insert avialable information '
			   || 'into GCS_CONS_ENG_RUN_DTLS '
                           || ' if there is an error the information will be'
                           || ' saved upto this point.'
                          );
       END IF;

       INSERT INTO gcs_cons_eng_run_dtls
             (run_detail_id, run_name, Consolidation_entity_id
             , child_entity_id, contra_child_entity_id, entry_id, rule_id,
               request_error_code, bp_request_error_code, category_code,
               xlate_request_error_code, bp_xlate_request_error_code,
               creation_date, created_by, last_update_date,
               last_updated_by, last_update_login)
      SELECT gcs_cons_eng_run_dtls_s.nextval,
             g_consolidation_run_name,
             DECODE(g_elim_code, 'IE',p_entity_id,'IA', g_cons_entity_id),
             gehg.source_entity_id, gehg.target_entity_id,
             gehg.entry_id, gehg.rule_id,
             'WARNING', 'WARNING',
             DECODE(g_elim_code, 'IE', 'INTERCOMPANY', 'IA', 'INTRACOMPANY'),
             DECODE(g_elim_code, 'IA',
                   DECODE( p_xlation_required,'Y',
                           'NOT_STARTED','N','NOT_APPLICABLE'),NULL),
             DECODE(g_elim_code, 'IA',
                   DECODE( p_xlation_required,'Y',
                           'NOT_STARTED','N','NOT_APPLICABLE'),NULL),
             SYSDATE, g_fnd_user_id,
             SYSDATE, g_fnd_user_id,
             g_fnd_login_id
       FROM  GCS_INTERCO_HDR_GT gehg
       WHERE gehg.currency_code = 'STAT'
       AND  NOT EXISTS ( SELECT 1 FROM gcs_cons_eng_run_dtls gcr1
                         WHERE  gehg.source_entity_id = gcr1.child_entity_id
                         AND    gehg.target_entity_id =
                                         gcr1.contra_child_entity_id
                         AND    gehg.rule_id  = gcr1.rule_id);


	g_no_rows   := NVL(SQL%ROWCOUNT,0);

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_CONS_ENG_RUN_DTLS');

	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
         --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
        END IF;

*/
      -- In case of an error, we will roll back to this point in time.
      SAVEPOINT gcs_cons_eng_insr_warning;


    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
    END IF;


    RETURN TRUE;

  EXCEPTION

   WHEN NO_DATA_FOUND THEN


    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_pkg_name || '.' || l_api_name,
                       'Error in inserting intercompany headers'
                       ||' into the GCS_INTERCO_HDR_GT' );

        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_pkg_name || '.' || l_api_name,
                       SUBSTR(SQLERRM, 1, 255));

         fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
    END IF;

   Return FALSE;

   WHEN OTHERS THEN


     IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_pkg_name || '.' || l_api_name,
                       SUBSTR(SQLERRM, 1, 255));

         fnd_log.STRING (fnd_log.level_unexpected,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
    END IF;

      INSERT INTO gcs_cons_eng_run_dtls
             (run_detail_id, run_name, Consolidation_entity_id
             , child_entity_id, contra_child_entity_id, entry_id, rule_id,
               request_error_code, bp_request_error_code, category_code,
               creation_date, created_by, last_update_date,
               last_updated_by, last_update_login)
      SELECT gcs_cons_eng_run_dtls_s.nextval,
             g_consolidation_run_name,
             DECODE(g_elim_code, 'IE',p_entity_id,'IA', g_cons_entity_id),
             NULL, NULL,
             NULL, NULL,
             'WARNING','WARNING',
             DECODE(g_elim_code, 'IE', 'INTERCOMPANY', 'IA', 'INTRACOMPANY'),
             SYSDATE, g_fnd_user_id,
             SYSDATE, g_fnd_user_id,
             g_fnd_login_id
       FROM DUAL;


	g_no_rows   := NVL(SQL%ROWCOUNT,0);

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_CONS_ENG_RUN_DTLS');

	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
         --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
        END IF;



      SAVEPOINT gcs_cons_eng_insr_Hdr_warning;

   Return FALSE;



  END INSR_INTERCO_HDRS;

 --
  -- Function
  --   insr_elimination_hdrs
  -- Purpose
  --  Inserts elimination entry headers into GCS_ENTRY_HEADERS.
  --

  -- Process steps are as follows:
     --  If the threshold currency of a intercompany rule is diffrent from
     --  consolidation entity currency, then get the conversion rate for the
     --  target currency.

     --  Then insert elimination entries headers into GCS_ENTRY_HEADERS.

     --  Then raise a warning if suspense exceeded for a pair of entities.


  FUNCTION  INSR_ELIMINATION_HDRS(p_hierarchy_id IN NUMBER,
                                  p_cal_period_id IN NUMBER,
                                  p_entity_id IN NUMBER,
				  p_balance_type  VARCHAR2,
				  p_currency_code IN VARCHAR2)
            RETURN BOOLEAN IS

   l_api_name VARCHAR2(50) := 'INSR_ELIMINATION_HDRS';
   l_period_end_date DATE;
   l_warning NUMBER(4) := 0;
   x_corp_rate    	NUMBER := 0;
   x_errbuf   VARCHAR2(255);
   X_errcode  NUMBER;
   l_errbuf   VARCHAR2(100);
   l_errcode  NUMBER := 0;



   -- Used to get the minimum accountable unit for the currency given.

    CURSOR	threshold_conv_rate IS
    SELECT	gihg.entry_id, gihg.threshold_currency,
	        nvl(minimum_accountable_unit, power(10, -precision)) mau,
                NVL(precision,2) pres
    FROM	GCS_INTERCO_HDR_GT gihg, GCS_ENTRY_LINES gel,
                fnd_currencies fnc
    WHERE 	gihg.entry_id = gel.entry_id
    AND   	gihg.currency_code <> 'STAT'
    AND   	gihg.threshold_currency <> p_currency_code
    AND   	gihg.currency_code = fnc.currency_code
    GROUP BY 	gihg.entry_id, threshold_currency,
                nvl(minimum_accountable_unit, power(10, -precision)),
                NVL(precision,2);


   -- Used to get the minimum accountable unit for the currency given.
   -- The following cursor is not necessary, since we can merge
   -- the following join in the above sql statement.

 /*   CURSOR	ccy_mau_c(c_ccy VARCHAR2) IS
    SELECT	nvl(minimum_accountable_unit, power(10, -precision)) mau,
                NVL(precision,2) pres
    FROM	fnd_currencies
    WHERE	currency_code = c_ccy;
*/
  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                         ' Arguments passed to Insr_Interco_Hdr() '
                         ||' Hierarchy_Id :'||p_hierarchy_id
                         ||' Cal_Period_Id: '||p_cal_period_id
                         ||' Entity_Id: '||p_entity_id
                         ||' Balance_Type: '||p_balance_type
                         ||' Currency_Code: '||p_currency_code);

    END IF;

    g_no_rows   := 0;

    l_period_end_date := g_period_end_date;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          ' Intercompany- Getting conversion rate');
    END IF;


   for entries in threshold_conv_rate  loop
  --   for conv_rate in ccy_mau_c(entries.threshold_currency) loop

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Inside Loop'
			   || ' in GCS_INTERCO_HDR_GT'
                          );
    END IF;

    BEGIN

    /*   x_corp_rate :=  GL_CURRENCY_API.get_rate(entries.threshold_currency,
                                                p_currency_code,
                                                l_period_end_date,
                                                'Corporate'); */

      -- Call the gcs_utility_pkg.get_conversion_rate to get the
      -- conversion rate.

       GCS_UTILITY_PKG.Get_Conversion_Rate
                      (p_source_currency => entries.threshold_currency,
                       p_target_currency => p_currency_code,
                       p_cal_period_id   => p_cal_period_id,
                       p_conversion_rate => x_corp_rate,
                       P_errbuf          => l_errbuf,
                       p_errcode         => l_errcode);


      If ( x_corp_rate <> 1) THEN

       -- Suspense exceeded flag population.
       -- If the absolute net suspense exceeds threshold amount, then
       -- insert 'Y' otherwise 'N'. If there is no conversion rate, then
       -- insert 'X' into suspense exceeded flag of gcs_entry_headers
       -- For stat currency this flag is always 'N'

      --  Now Insert elimination entry headers into GCS_ENTRY_HEADERS.

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Inserting consolidation currency '
                           ||' entity entry '
			   ||' headers into GCS_ENTRY_HEADERS '
                           ||'- where legitimate conversion rate is available.'
                          );
          END IF;

         g_no_rows   := 0;

         INSERT INTO gcs_entry_headers
                  (entry_id, entry_name, hierarchy_id, disabled_flag,
                   entity_id, currency_code, balance_type_code,
                   start_cal_period_id, end_cal_period_id,
                   description, entry_type_code,
                   processed_run_name, category_code,
                   process_code, suspense_exceeded_flag,
                   creation_date, created_by, last_update_date,
                   last_updated_by, last_update_login, PERIOD_INIT_ENTRY_FLAG)
         SELECT   gehg.ENTRY_ID,
                  gehg.ENTRY_ID,
                  MAX(p_hierarchy_id), 'N',
                  MAX(g_elim_entity_id), gehg.currency_code,
                  p_balance_type, MAX(p_cal_period_id),
                  MAX(p_cal_period_id),
                  Decode(g_elim_code,'IE','Intercompany  ', 'Intracompany  ')
                  || MAX(girt.rule_name)
                   ||' executed for '||g_elim_entity_name,
                  'AUTOMATIC', g_consolidation_run_name,
                  DECODE(g_elim_code,'IE','INTERCOMPANY','IA','INTRACOMPANY'),
                  'SINGLE_RUN_FOR_PERIOD',
                  DECODE (GREATEST(ABS(SUM(NVL(giet.ytd_debit_balance_e,0))-
                                      SUM(NVL(giet.ytd_credit_balance_e,0))),
                     ROUND(((MAX(gehg.threshold_amount)*
                             NVL(x_corp_rate,1))/entries.mau),
                             NVL(entries.pres,2))* entries.mau),
                     ROUND(((MAX(gehg.threshold_amount)*
                             NVL(x_corp_rate,1))/entries.mau),
                             NVL(entries.pres,2))* entries.mau, 'N', 'Y'),
                 MAX(SYSDATE), MAX(g_fnd_user_id),
                 MAX(SYSDATE), MAX(g_fnd_user_id),
                 MAX(g_fnd_login_id), 'N'
        FROM  GCS_INTERCO_HDR_GT gehg,
              GCS_INTERCO_RULES_TL girt,
              GCS_ENTRY_LINES giet
        WHERE gehg.entry_id = entries.entry_id
        AND   gehg.rule_id = girt.rule_id
        AND   girt.language = USERENV('LANG')
        AND   gehg.entry_id = giet.entry_id(+)
        AND   giet.line_item_id (+) = gehg.sus_line_item_id
        AND   giet.description(+) = 'SUSPENSE_LINE'
        GROUP BY gehg.ENTRY_ID, gehg.currency_code;

        g_no_rows   := SQL%ROWCOUNT;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_HEADERS');


	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
          --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
        END IF;

     ELSIF (x_corp_rate = 1) THEN
       -- If the conversion rate is not available then there is no need to
       -- convert the threshold amount.

        -- Insert elimination entry headers into GCS_ENTRY_HEADERS.

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                              'Intercompany- Inserting consolidation currency '
                           ||' entity entry '
			   ||' headers into GCS_ENTRY_HEADERS '
                           ||'- where conversion rate is 1, that means valid '
                           ||' conversion rate is not available.'
                          );
       END IF;

       g_no_rows   := 0;

       INSERT INTO gcs_entry_headers
                  (entry_id, entry_name, hierarchy_id, disabled_flag,
                   entity_id, currency_code, balance_type_code,
                   start_cal_period_id, end_cal_period_id,
                   description, entry_type_code,
                   processed_run_name, category_code,
                   process_code, suspense_exceeded_flag,
                   creation_date, created_by, last_update_date,
                   last_updated_by, last_update_login, PERIOD_INIT_ENTRY_FLAG)
       SELECT     gehg.ENTRY_ID,
                   gehg.ENTRY_ID,
                  p_hierarchy_id, 'N',
                  g_elim_entity_id, gehg.currency_code,
                  p_balance_type, p_cal_period_id,
                  p_cal_period_id,
                  Decode(g_elim_code,'IE','Intercompany  ', 'Intracompany  ')
                  || girt.rule_name
                  ||' executed for '||g_elim_entity_name,
                  'AUTOMATIC', g_consolidation_run_name,
                  DECODE(g_elim_code,'IE','INTERCOMPANY','IA','INTRACOMPANY'),
                  'SINGLE_RUN_FOR_PERIOD',
                   'X',
                  SYSDATE, g_fnd_user_id,
                  SYSDATE, g_fnd_user_id,
                  g_fnd_login_id, 'N'
       FROM      GCS_INTERCO_HDR_GT gehg,
                 GCS_INTERCO_RULES_TL girt
       WHERE gehg.entry_id = entries.entry_id
       AND   gehg.rule_id = girt.rule_id
       AND   girt.language = USERENV('LANG');


       g_no_rows   := SQL%ROWCOUNT;

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_HEADERS');


	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
          --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
       END IF;


     END IF;

   EXCEPTION
      WHEN OTHERS THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_pkg_name || '.' || l_api_name,
                       SUBSTR(SQLERRM, 1, 255));
        END IF;


    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Corporate rate is not available'
			   || ' from from_currency:'
                           || entries.threshold_currency
                           ||' to to_currency : '|| p_currency_code
                           ||' and end date is: '||l_period_end_date
                          );
    END IF;

       -- If the conversion rate is not available then there is no need to
       -- convert the threshold amount.

     g_no_rows   := 0;

    INSERT INTO gcs_entry_headers
                  (entry_id, entry_name, hierarchy_id, disabled_flag,
                   entity_id, currency_code, balance_type_code,
                   start_cal_period_id, end_cal_period_id,
                   description, entry_type_code,
                   processed_run_name, category_code,
                   process_code, suspense_exceeded_flag,
                   creation_date, created_by, last_update_date,
                   last_updated_by, last_update_login, PERIOD_INIT_ENTRY_FLAG)

     SELECT      gehg.ENTRY_ID, gehg.ENTRY_ID,
                  p_hierarchy_id, 'N',
                  g_elim_entity_id, gehg.currency_code,
                  p_balance_type, p_cal_period_id,
                  p_cal_period_id,
                  Decode(g_elim_code,'IE','Intercompany  ', 'Intracompany  ')
                  ||girt.rule_name
                  ||' executed for '||g_elim_entity_name,
                  'AUTOMATIC', g_consolidation_run_name,
                  DECODE(g_elim_code,'IE','INTERCOMPANY','IA','INTRACOMPANY'),
                  'SINGLE_RUN_FOR_PERIOD',
                  'X',
                 SYSDATE, g_fnd_user_id,
                 SYSDATE, g_fnd_user_id,
                 g_fnd_login_id, 'N'
     FROM  GCS_INTERCO_HDR_GT gehg,
           GCS_INTERCO_RULES_TL girt
     WHERE gehg.entry_id = entries.entry_id
     AND   gehg.rule_id = girt.rule_id
     AND   girt.language = USERENV('LANG');



      g_no_rows   := SQL%ROWCOUNT;

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_HEADERS');


	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
          --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
       END IF;


     END;

    End Loop;

   --END Loop;



   -- Insert elimination entry headers into GCS_ENTRY_HEADERS for same
   -- currency.

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Inserting same currency '
			   || ' entry headers into GCS_ENTRY_HEADERS'
                          );
     END IF;

    -- Suspense exceeded flag population.
    -- Now insert the same currency  entries.

     --  Fixed bug#3691665

     INSERT INTO gcs_entry_headers
                 (entry_id, entry_name, hierarchy_id, disabled_flag,
                  entity_id, currency_code, balance_type_code,
                  start_cal_period_id, end_cal_period_id,
                  description, entry_type_code,
                  processed_run_name, category_code,
                  process_code, suspense_exceeded_flag,
                  creation_date, created_by, last_update_date,
                  last_updated_by, last_update_login, PERIOD_INIT_ENTRY_FLAG)
         SELECT   gehg.ENTRY_ID,
                  gehg.ENTRY_ID,
                  p_hierarchy_id, 'N',
                  g_elim_entity_id, gehg.currency_code,
                  p_balance_type, p_cal_period_id,
                  p_cal_period_id,
                  Decode(g_elim_code,'IE','Intercompany  ', 'Intracompany  ')
                  ||MAX(girt.rule_name)
                  ||' executed for '||g_elim_entity_name,
                  'AUTOMATIC', g_consolidation_run_name,
                  DECODE(g_elim_code,'IE','INTERCOMPANY','IA','INTRACOMPANY'),
                  'SINGLE_RUN_FOR_PERIOD',
                  DECODE (GREATEST(ABS(SUM(NVL(giet.ytd_debit_balance_e,0))-
                                        SUM(NVL(giet.ytd_credit_balance_e,0))),
                     MAX(gehg.threshold_amount)),
                     MAX(gehg.threshold_amount), 'N', 'Y'),
                 MAX(SYSDATE), MAX(g_fnd_user_id),
                 MAX(SYSDATE), MAX(g_fnd_user_id),
                 MAX(g_fnd_login_id), 'N'
        FROM  GCS_INTERCO_HDR_GT gehg,
              GCS_INTERCO_RULES_TL girt,
              GCS_ENTRY_LINES giet
        WHERE (gehg.currency_code = P_currency_code
                 AND gehg.threshold_currency = P_currency_code)
        AND   gehg.rule_id = girt.rule_id
        AND   girt.language = USERENV('LANG')
        AND   gehg.entry_id = giet.entry_id(+)
        AND   giet.line_item_id(+)  = gehg.sus_line_item_id
        AND   giet.description(+) = 'SUSPENSE_LINE'
        GROUP BY gehg.ENTRY_ID, gehg.currency_code;

     g_no_rows   := SQL%ROWCOUNT;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_HEADERS');


	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
          --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
     END IF;


   -- Insert elimination entry headers into GCS_ENTRY_HEADERS.

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Inserting stat currency entry '
			   || ' headers into GCS_ENTRY_HEADERS'
                          );
     END IF;

    -- Suspense exceeded flag population.
    -- Now insert the stat currency  entries.
    -- For stat currency this flag is always 'N'

     INSERT INTO gcs_entry_headers
                 (entry_id, entry_name, hierarchy_id, disabled_flag,
                  entity_id, currency_code, balance_type_code,
                  start_cal_period_id, end_cal_period_id,
                  description, entry_type_code,
                  processed_run_name, category_code,
                  process_code, suspense_exceeded_flag,
                  creation_date, created_by, last_update_date,
                  last_updated_by, last_update_login, PERIOD_INIT_ENTRY_FLAG)
     SELECT      gehg.ENTRY_ID,
                   gehg.ENTRY_ID,
                  p_hierarchy_id, 'N',
                  g_elim_entity_id, gehg.currency_code,
                  p_balance_type, p_cal_period_id,
                  p_cal_period_id,
                  Decode(g_elim_code,'IE','Intercompany  ', 'Intracompany  ')
                  ||girt.rule_name
                  ||' executed for '||g_elim_entity_name,
                  'AUTOMATIC', g_consolidation_run_name,
                  DECODE(g_elim_code,'IE','INTERCOMPANY','IA','INTRACOMPANY'),
                  'SINGLE_RUN_FOR_PERIOD',
                  'N',
                  SYSDATE, g_fnd_user_id,
                  SYSDATE, g_fnd_user_id,
                  g_fnd_login_id, 'N'
     FROM  GCS_INTERCO_HDR_GT gehg,
           GCS_ENTRY_LINES gel,
           GCS_INTERCO_RULES_TL girt
     WHERE gehg.entry_id = gel.entry_id
     AND   gehg.currency_code = 'STAT'
     AND   gehg.rule_id = girt.rule_id
     AND   girt.language = USERENV('LANG')
     GROUP BY gehg.entry_id, girt.rule_name, gehg.currency_code;

     g_no_rows   := SQL%ROWCOUNT;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_HEADERS');


	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
          --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
     END IF;

    -- Fix Bug #3682104

    g_no_rows   := 0;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Deleting entry headers '
                           || ' from gcs_entry_headers'
			   || ' where there are no entry lines '

                          );
     END IF;

     DELETE FROM gcs_entry_headers
     WHERE  entry_id IN
           (SELECT gihg.entry_id from gcs_interco_hdr_gt gihg
            WHERE  NOT EXISTS
                  (SELECT entry_id from gcs_entry_lines geh
                   WHERE  geh.entry_id = gihg.entry_id));


     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0119');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_HEADERS');


	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
          --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0119: '||FND_MESSAGE.get);
     END IF;



   -- Process Run details in gcs_cons_eng_run_dtls for the entered headers.

    g_no_rows   := 0;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Deleting run details'
			   || ' from gcs_cons_eng_run_dtls'
                           || ' which are not ended up into entry headers table'
                          );
     END IF;

     DELETE FROM gcs_cons_eng_run_dtls
     WHERE  entry_id IN
           (SELECT gihg.entry_id from gcs_interco_hdr_gt gihg
            WHERE  gihg.currency_code <> 'STAT'
            AND    NOT EXISTS
                  (SELECT entry_id from gcs_entry_headers geh
                   WHERE  geh.entry_id = gihg.entry_id));


     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0119');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_CONS_ENG_RUN_DTLS');


	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
          --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0119: '||FND_MESSAGE.get);
     END IF;


    g_no_rows   := 0;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Merge run details'
			   || ' for STAT rows in gcs_cons_eng_run_dtls'
                          );
     END IF;


      MERGE INTO gcs_cons_eng_run_dtls gcer
      USING (SELECT
           DECODE(g_elim_code, 'IE',g_entity_id,'IA', g_cons_entity_id)
                                                  cons_entity_id,
             gehg.rule_id rule_id,
             DECODE(g_elim_code, 'IE', 'INTERCOMPANY', 'IA', 'INTRACOMPANY')
                                                  category_code,
             DECODE(geh.suspense_exceeded_flag, 'X','WARNING','Y','WARNING',
                                 ' N','NO_ERROR', 'COMPLETED') req_err_code,
             DECODE(geh.suspense_exceeded_flag, 'X','WARNING','Y','WARNING',
                                 ' N','NO_ERROR', 'COMPLETED') bp_req_err_code,
             gehg.source_entity_id src_entity_id,
             gehg.target_entity_id target_entity_id,
             gehg.entry_id  entry_id
             FROM   GCS_INTERCO_HDR_GT gehg,
                    GCS_ENTRY_HEADERS geh
             WHERE  gehg.entry_id = geh.entry_id
             AND    gehg.currency_code = 'STAT') stat_result
       ON (stat_result.src_entity_id = gcer.child_entity_id
           AND   stat_result.target_entity_id =
                                         gcer.contra_child_entity_id
           AND    stat_result.rule_id  = gcer.rule_id
           AND    gcer.run_name = g_consolidation_run_name)
       WHEN MATCHED THEN UPDATE SET
               gcer.stat_entry_id = stat_result.entry_id,
               gcer.request_error_code =
                 NVL(stat_result.req_err_code,gcer.request_error_code),
                gcer.bp_request_error_code =
                   NVL(stat_result.bp_req_err_code,gcer.bp_request_error_code),
                last_update_date = SYSDATE,
                last_updated_by = g_fnd_user_id
     WHEN NOT MATCHED THEN INSERT (gcer.run_detail_id, gcer.run_name,
              gcer.Consolidation_entity_id,
              gcer.child_entity_id, gcer.contra_child_entity_id ,
              gcer.stat_entry_id, gcer.rule_id, gcer.request_error_code,
              gcer.bp_request_error_code, gcer.category_code,
              gcer.creation_date, gcer.created_by, gcer.last_update_date,
              gcer.last_updated_by, gcer.last_update_login)
          VALUES(gcs_cons_eng_run_dtls_s.nextval,
                 g_consolidation_run_name,
                 stat_result.cons_entity_id, stat_result.src_entity_id,
                 stat_result.target_entity_id,  stat_result.entry_id,
                 stat_result.rule_id, stat_result.req_err_code,
                 stat_result.bp_req_err_code,
                 stat_result.category_code,
                 SYSDATE, g_fnd_user_id,
                 SYSDATE, g_fnd_user_id,
                 g_fnd_login_id);

     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0118');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_CONS_ENG_RUN_DTLS');


	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
          --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0118: '||FND_MESSAGE.get);
     END IF;

-----##########-----

    g_no_rows   := 0;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Updating run details'
			   || ' for non STAT rows in gcs_cons_eng_run_dtls'
                          );
     END IF;



      UPDATE gcs_cons_eng_run_dtls gcer
      SET (request_error_code,
           bp_request_error_code, last_update_date,
           last_updated_by) =
             (SELECT
               --DECODE(gehg.currency_code, 'STAT', gehg.entry_id, NULL),
               DECODE(gcer.stat_entry_id, NULL,
                        DECODE(geh.suspense_exceeded_flag,
                                    'X','WARNING','Y','WARNING',
                                 ' N','NO_ERROR', 'COMPLETED'),
                                     gcer.request_error_code),
               DECODE(gcer.stat_entry_id, NULL,
               DECODE(geh.suspense_exceeded_flag, 'X','WARNING','Y','WARNING',
                                 ' N','NO_ERROR', 'COMPLETED'),
                                      gcer.bp_request_error_code),
               SYSDATE,
               g_fnd_user_id
              FROM   GCS_INTERCO_HDR_GT gehg,
                     GCS_ENTRY_HEADERS geh
              WHERE  gehg.entry_id = geh.entry_id
              AND    gehg.entry_id = gcer.entry_id)
     WHERE  gcer.entry_id IN (SELECT entry_id from gcs_interco_hdr_gt
                              WHERE currency_code <> 'STAT');


     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0118');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_CONS_ENG_RUN_DTLS');


	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
          --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0118: '||FND_MESSAGE.get);
     END IF;


    -- Consolidation engine requires x_errbuf being returnrd as 'WARNING'
    -- if suspense exceeded or could not found a conversion rate for a set
    -- of currencies.

   BEGIN

      SELECT 1 INTO l_warning
      FROM DUAL
      WHERE EXISTS (SELECT 1 FROM GCS_ENTRY_HEADERS
                  WHERE suspense_exceeded_flag = 'Y'
                  AND   entry_id IN (SELECT entry_id from gcs_interco_hdr_gt));

      IF (l_warning =1) THEN
         g_sus_exceed_no_rate := TRUE;
      END IF;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
         NULL;
     WHEN OTHERS THEN
         NULL;

  END;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
     END IF;


   RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_pkg_name || '.' || l_api_name,
                       SUBSTR(SQLERRM, 1, 255));
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_pkg_name || '.' || l_api_name,
                       GCS_UTILITY_PKG.g_module_failure || l_api_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;

    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure
    --                    ||l_api_name || to_char(sysdate
    --                    , ' DD-MON-YYYY HH:MI:SS'));
    RETURN FALSE;

END INSR_ELIMINATION_HDRS;


END GCS_INTERCO_PROCESSING_PKG;

/
