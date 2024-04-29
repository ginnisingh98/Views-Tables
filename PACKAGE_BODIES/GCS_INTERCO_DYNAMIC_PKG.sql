--------------------------------------------------------
--  DDL for Package Body GCS_INTERCO_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_INTERCO_DYNAMIC_PKG" AS
/* $Header $ */

  --
  -- PRIVATE GLOBAL VARIABLES
  --
  g_pkg_name    VARCHAR2(100) := 'gcs.plsql.GCS_INTERCO_DYNAMIC_PKG';
  g_fnd_user_id           NUMBER     := fnd_global.user_id;
  g_fnd_login_id          NUMBER     := fnd_global.login_id;
  g_no_rows  NUMBER :=0;
  g_intercompany_org_code VARCHAR2(30) := 'DIFFERENT_ORG' ;
  g_specific_intercompany_id  NUMBER:= 0;
  g_cons_run_name         VARCHAR2(80);
  gbl_period_end_date     DATE;
  --
  -- PUBLIC FUNCTIONS
  --
   FUNCTION  INSR_INTERCO_LINES (p_hierarchy_id IN NUMBER,
                                 p_cal_period_id IN NUMBER,
                                 p_entity_id IN NUMBER,
				 p_match_rule_code VARCHAR2,
				 p_balance_type  VARCHAR2,
				 p_elim_mode  IN VARCHAR2,
                                 P_Currency_code IN VARCHAR2,
                                 p_dataset_code IN NUMBER,
                                 p_lob_dim_col_name IN VARCHAR2,
                                 p_cons_run_name IN VARCHAR2,
                                 p_period_end_date IN DATE,
                                 p_fem_ledger_id  IN NUMBER)
                RETURN BOOLEAN IS

    l_api_name VARCHAR2(30) := 'INSR_INTERCO_LINES';

   -- Insert all eligible elimination lines from GCS_INTERCO_ELM_TRX
   --  GCS_ENTRY-LINES.
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
                         ' Arguments passed to Insr_Interco_Lines() '
                         ||' Hierarchy_Id: '||p_hierarchy_id
                         ||' Cal_Period_Id: '||p_cal_period_id
                         ||' Entity_Id: '||p_entity_id
                         ||' Match Rule Code: '||p_match_rule_code
                         ||' Balance_Type: '||p_balance_type
                         ||' Elim_Mode: '||p_elim_mode
                         ||' Currency_Code: '||p_currency_code
                         ||' Dataset Code:'||p_dataset_code
                         ||' LOB dim column name: '||p_lob_dim_col_name
                         ||' Consolidation Run name:'||p_cons_run_name
                         ||'Period end date: '||p_period_end_date
                         ||'Fem Ledger Id: '||p_fem_ledger_id);

       END IF;

    g_cons_run_name         := p_cons_run_name;
    gbl_period_end_date     := p_period_end_date;
   IF (P_ELIM_MODE = 'IE') THEN
     IF (p_match_rule_code = 'COMPANY') THEN   /* In Intercompany option */
       g_no_rows := 0;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Inserting entry lines'
			   || ' into GCS_ENTRY_LINES_GT'
                           || ' after matching by company-Receivables side'
                          );
       END IF;


       INSERT INTO  GCS_ENTRY_LINES_GT
       ( ENTRY_ID, COMPANY_COST_CENTER_ORG_ID
       , LINE_ITEM_Id, INTERCOMPANY_ID, FINANCIAL_ELEM_ID
       , PRODUCT_ID, NATURAL_ACCOUNT_ID, CHANNEL_ID
       , PROJECT_ID, CUSTOMER_ID, TASK_ID, USER_DIM1_ID
       , USER_DIM2_ID, USER_DIM3_ID, USER_DIM4_ID
       , USER_DIM5_ID, USER_DIM6_ID, USER_DIM7_ID
       , USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID
       , YTD_CREDIT_BALANCE_E , YTD_DEBIT_BALANCE_E
       , DESCRIPTION, YTD_BALANCE_E, RECEIVABLES_ORG_ID,
         PAYABLES_ORG_ID )
       SELECT /*+ ORDERED FULL(GIHG) INDEX(GIET GCS_INTERCO_ELM_TRX_U1)
          INDEX(GIM GCS_INTERCO_MEMBERS_U1) USE_NL(GIET GIM)
          INDEX(GCR GCS_CONS_RELATIONSHIPS_N1)
          INDEX (FB FEM_BALANCES_P)
          USE_NL(GCR FB)*/
          gihg.entry_id, giet.company_cost_center_org_id
              , giet.line_item_id
              , giet.intercompany_id,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         SUM(NVL(fb.ytd_debit_balance_e,0))
       , SUM(NVL(fb.ytd_credit_balance_e,0))
       , Max(gihg.rule_id)
      , (SUM(NVL(fb.ytd_credit_balance_e,0))
                - SUM(NVL(fb.ytd_debit_balance_e,0))),
       DECODE(MAX(gim.line_item_group), 1,
                giet.company_cost_center_org_id,
                     giet.Intercompany_id),
       DECODE(MAX(gim.line_item_group), 2,
                giet.company_cost_center_org_id,
                     giet.Intercompany_id)
       FROM    	GCS_INTERCO_HDR_GT gihg,
                GCS_INTERCO_ELM_TRX giet,
	    	GCS_INTERCO_MEMBERS gim,
                GCS_CONS_RELATIONSHIPS gcr,
	    	FEM_BALANCES fb
	WHERE   giet.cal_period_id = p_cal_period_id
	AND     giet.hierarchy_id  = p_hierarchy_id
	AND     gihg.currency_code IN (p_currency_code,'STAT')
	AND	giet.line_item_id = gim.line_item_id
        AND     (giet.src_entity_id = gihg.source_entity_id
                  AND   giet.target_entity_id = gihg.target_entity_id)
	AND     gim.rule_id = gihg.rule_id
        AND     gim.line_item_group = 1
	AND     gcr.hierarchy_id  = p_hierarchy_id
        AND     gcr.parent_entity_id = p_entity_id
        AND     gcr.actual_ownership_flag ='Y'
        AND     gcr.dominant_parent_flag = 'Y'
	AND     (gbl_period_end_date
               BETWEEN NVL(start_date,TO_DATE('01/01/1950', 'MM/DD/YYYY'))
	  AND NVL(END_DATE, TO_DATE('12/31/9999', 'MM/DD/YYYY')))
        AND     gcr.child_entity_id = fb.entity_id
	AND     giet.company_cost_center_org_id = fb.company_cost_center_org_id
	AND     giet.intercompany_id = fb.intercompany_id
	AND     giet.line_item_id = fb.line_item_id
	AND     fb.currency_code = gihg.currency_code
	AND     fb.cal_period_id = giet.cal_period_id
        AND     fb.dataset_code  = p_dataset_code
        AND     fb.ledger_id = P_fem_ledger_id
        AND     fb.source_system_code = 70

 GROUP BY gihg.entry_id, giet.company_cost_center_org_id,
         	giet.intercompany_id,

giet.line_item_id;
     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_LINES_GT');

	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
        END IF;

       --****************************----
       g_no_rows := 0;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Inserting entry lines'
			   || ' into GCS_ENTRY_LINES_GT'
                           || ' after matching by company - Payabales side'
                          );
       END IF;

       INSERT INTO  GCS_ENTRY_LINES_GT
       ( ENTRY_ID, COMPANY_COST_CENTER_ORG_ID
       , LINE_ITEM_Id, INTERCOMPANY_ID, FINANCIAL_ELEM_ID
       , PRODUCT_ID, NATURAL_ACCOUNT_ID, CHANNEL_ID
       , PROJECT_ID, CUSTOMER_ID, TASK_ID, USER_DIM1_ID
       , USER_DIM2_ID, USER_DIM3_ID, USER_DIM4_ID
       , USER_DIM5_ID, USER_DIM6_ID, USER_DIM7_ID
       , USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID
       , YTD_CREDIT_BALANCE_E , YTD_DEBIT_BALANCE_E
       , DESCRIPTION, YTD_BALANCE_E, RECEIVABLES_ORG_ID,
         PAYABLES_ORG_ID )
       SELECT /*+ ORDERED FULL(GIHG) INDEX(GIET GCS_INTERCO_ELM_TRX_U1)
          INDEX(GIM GCS_INTERCO_MEMBERS_U1) USE_NL(GIET GIM)
          INDEX(GCR GCS_CONS_RELATIONSHIPS_N1)
          INDEX (FB FEM_BALANCES_P)
          USE_NL(GCR FB)*/
              gihg.entry_id, giet.company_cost_center_org_id
              , giet.line_item_id
              , giet.intercompany_id,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         SUM(NVL(fb.ytd_debit_balance_e,0))
       , SUM(NVL(fb.ytd_credit_balance_e,0))
       , MAX(gihg.rule_id)
      , (SUM(NVL(fb.ytd_credit_balance_e,0))
                - SUM(NVL(fb.ytd_debit_balance_e,0))),
       DECODE(MAX(gim.line_item_group), 1,
                giet.company_cost_center_org_id,
                     giet.Intercompany_id),
       DECODE(MAX(gim.line_item_group), 2,
                giet.company_cost_center_org_id,
                     giet.Intercompany_id)
       FROM     GCS_INTERCO_HDR_GT gihg,
                GCS_INTERCO_ELM_TRX giet,
	    	GCS_INTERCO_MEMBERS gim,
                GCS_CONS_RELATIONSHIPS gcr,
	    	FEM_BALANCES fb
	WHERE   giet.cal_period_id = p_cal_period_id
	AND     giet.hierarchy_id  = p_hierarchy_id
	AND     gihg.currency_code IN (p_currency_code,'STAT')
	AND	giet.line_item_id = gim.line_item_id
        AND     (giet.src_entity_id = gihg.target_entity_id
                  AND     giet.target_entity_id  =  gihg.source_entity_id )
	AND     gim.rule_id = gihg.rule_id
        AND     gim.line_item_group = 2
        AND     gcr.hierarchy_id = p_hierarchy_id
        AND     gcr.parent_entity_id = p_entity_id
        AND     gcr.actual_ownership_flag ='Y'
        AND     gcr.dominant_parent_flag = 'Y'
	AND     (gbl_period_end_date
               BETWEEN NVL(start_date,TO_DATE('01/01/1950', 'MM/DD/YYYY'))
	  AND NVL(END_DATE, TO_DATE('12/31/9999', 'MM/DD/YYYY')))
        AND     gcr.child_entity_id = fb.entity_id
	AND     giet.company_cost_center_org_id = fb.company_cost_center_org_id
	AND     giet.intercompany_id = fb.intercompany_id
	AND     giet.line_item_id = fb.line_item_id
	AND     fb.currency_code = gihg.currency_code
	AND     fb.cal_period_id = giet.cal_period_id
        AND     fb.dataset_code  = p_dataset_code
        AND     fb.ledger_id = P_fem_ledger_id
        AND     fb.source_system_code = 70

 GROUP BY gihg.entry_id, giet.company_cost_center_org_id,
         	giet.intercompany_id,

giet.line_item_id;
     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_LINES_GT');

	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
        END IF;




  ELSIF (p_match_rule_code = 'ORGANIZATION') THEN
           --In Intercompany option
       g_no_rows := 0;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Inserting entry lines'
			   || ' into GCS_ENTRY_LINES_GT'
                           || ' after matching by Org-Receivables side'
                          );
       END IF;

       INSERT INTO  GCS_ENTRY_LINES_GT
       ( ENTRY_ID, COMPANY_COST_CENTER_ORG_ID
       , LINE_ITEM_Id, INTERCOMPANY_ID, FINANCIAL_ELEM_ID
       , PRODUCT_ID, NATURAL_ACCOUNT_ID, CHANNEL_ID
       , PROJECT_ID, CUSTOMER_ID, TASK_ID, USER_DIM1_ID
       , USER_DIM2_ID, USER_DIM3_ID, USER_DIM4_ID
       , USER_DIM5_ID, USER_DIM6_ID, USER_DIM7_ID
       , USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID
       , YTD_CREDIT_BALANCE_E , YTD_DEBIT_BALANCE_E
        , DESCRIPTION ,YTD_BALANCE_E, RECEIVABLES_ORG_ID,
         PAYABLES_ORG_ID)
       SELECT /*+ ORDERED FULL(GIHG) INDEX(GIET GCS_INTERCO_ELM_TRX_U1)
          INDEX(GIM GCS_INTERCO_MEMBERS_U1) USE_NL(GIET GIM)
          INDEX(GCR GCS_CONS_RELATIONSHIPS_N1)
          INDEX (FB FEM_BALANCES_P)
          USE_NL(GCR FB)*/
          gihg.entry_id, giet.company_cost_center_org_id
              , giet.line_item_id
              , giet.intercompany_id,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         SUM(NVL(fb.ytd_debit_balance_e,0))
       , SUM(NVL(fb.ytd_credit_balance_e,0))
       , MAX(gihg.rule_id)
      , (SUM(NVL(fb.ytd_credit_balance_e,0))
                - SUM(NVL(fb.ytd_debit_balance_e,0))),
       DECODE(MAX(gim.line_item_group), 1,
                giet.company_cost_center_org_id,
                     giet.Intercompany_id),
       DECODE(MAX(gim.line_item_group), 2,
                giet.company_cost_center_org_id,
                     giet.Intercompany_id)
       FROM  	GCS_INTERCO_HDR_GT gihg,
                GCS_INTERCO_ELM_TRX giet,
	    	GCS_INTERCO_MEMBERS gim,
                GCS_CONS_RELATIONSHIPS gcr,
	    	FEM_BALANCES fb
	WHERE   giet.cal_period_id = p_cal_period_id
	AND     giet.hierarchy_id  = p_hierarchy_id
	AND     gihg.currency_code IN (p_currency_code,'STAT')
	AND	giet.line_item_id = gim.line_item_id
        AND     (giet.src_entity_id =
                             gihg.source_entity_id
                  AND     giet.target_entity_id =
                             gihg.target_entity_id)
	AND     gim.rule_id = gihg.rule_id
        AND     gim.line_item_group  = 1
        AND     gcr.hierarchy_id = p_hierarchy_id
        AND     gcr.parent_entity_id = p_entity_id
        AND     gcr.actual_ownership_flag ='Y'
        AND     gcr.dominant_parent_flag = 'Y'
	AND     (gbl_period_end_date
               BETWEEN NVL(start_date,TO_DATE('01/01/1950', 'MM/DD/YYYY'))
	  AND NVL(END_DATE, TO_DATE('12/31/9999', 'MM/DD/YYYY')))
        AND     gcr.child_entity_id = fb.entity_id
	AND     giet.company_cost_center_org_id = fb.company_cost_center_org_id
	AND     giet.intercompany_id = fb.intercompany_id
	AND     giet.line_item_id = fb.line_item_id
	AND     fb.currency_code = gihg.currency_code
	AND     fb.cal_period_id = giet.cal_period_id
        AND     fb.dataset_code  = p_dataset_code
        AND     fb.ledger_id = P_fem_ledger_id
        AND     fb.source_system_code = 70

 GROUP BY gihg.entry_id, giet.company_cost_center_org_id,
         	giet.intercompany_id,

        giet.line_item_id;

     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_LINES_GT');

	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
        END IF;

 
      g_no_rows := 0;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Inserting entry lines'
			   || ' into GCS_ENTRY_LINES'
                           || ' after matching by Org-Payables side'
                          );
       END IF;

       INSERT INTO  GCS_ENTRY_LINES_GT
       ( ENTRY_ID, COMPANY_COST_CENTER_ORG_ID
       , LINE_ITEM_Id, INTERCOMPANY_ID, FINANCIAL_ELEM_ID
       , PRODUCT_ID, NATURAL_ACCOUNT_ID, CHANNEL_ID
       , PROJECT_ID, CUSTOMER_ID, TASK_ID, USER_DIM1_ID
       , USER_DIM2_ID, USER_DIM3_ID, USER_DIM4_ID
       , USER_DIM5_ID, USER_DIM6_ID, USER_DIM7_ID
       , USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID
       , YTD_CREDIT_BALANCE_E , YTD_DEBIT_BALANCE_E
       , DESCRIPTION ,YTD_BALANCE_E, RECEIVABLES_ORG_ID,
         PAYABLES_ORG_ID)
       SELECT /*+ ORDERED FULL(GIHG) INDEX(GIET GCS_INTERCO_ELM_TRX_U1)
          INDEX(GIM GCS_INTERCO_MEMBERS_U1) USE_NL(GIET GIM)
          INDEX(GCR GCS_CONS_RELATIONSHIPS_N1)
          INDEX (FB FEM_BALANCES_P)
          USE_NL(GCR FB)*/
               gihg.entry_id, giet.company_cost_center_org_id
              , giet.line_item_id
              , giet.intercompany_id,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         SUM(NVL(fb.ytd_debit_balance_e,0))
       , SUM(NVL(fb.ytd_credit_balance_e,0))
       , MAX(gihg.rule_id)
      , (SUM(NVL(fb.ytd_credit_balance_e,0))
                - SUM(NVL(fb.ytd_debit_balance_e,0))),
       DECODE(MAX(gim.line_item_group), 1,
                giet.company_cost_center_org_id,
                     giet.Intercompany_id),
       DECODE(MAX(gim.line_item_group), 2,
                giet.company_cost_center_org_id,
                     giet.Intercompany_id)
       FROM     GCS_INTERCO_HDR_GT gihg,
                GCS_INTERCO_ELM_TRX giet,
	    	GCS_INTERCO_MEMBERS gim,
                GCS_CONS_RELATIONSHIPS gcr,
	    	FEM_BALANCES fb
	WHERE   giet.cal_period_id = p_cal_period_id
	AND     giet.hierarchy_id  = p_hierarchy_id
	AND     gihg.currency_code IN (p_currency_code,'STAT')
	AND	giet.line_item_id = gim.line_item_id
        AND     (giet.src_entity_id =
                          gihg.target_entity_id
                  AND  giet.target_entity_id =
                          gihg.source_entity_id)
	AND     gim.rule_id = gihg.rule_id
        AND     gim.line_item_group  = 2
        AND     gcr.hierarchy_id = p_hierarchy_id
        AND     gcr.parent_entity_id = p_entity_id
        AND     gcr.actual_ownership_flag ='Y'
        AND     gcr.dominant_parent_flag = 'Y'
	AND     (gbl_period_end_date
               BETWEEN NVL(start_date,TO_DATE('01/01/1950', 'MM/DD/YYYY'))
	  AND NVL(END_DATE, TO_DATE('12/31/9999', 'MM/DD/YYYY')))
        AND     gcr.child_entity_id = fb.entity_id
	AND     giet.company_cost_center_org_id = fb.company_cost_center_org_id
	AND     giet.intercompany_id = fb.intercompany_id
	AND     giet.line_item_id = fb.line_item_id
	AND     fb.currency_code = gihg.currency_code
	AND     fb.cal_period_id = giet.cal_period_id
        AND     fb.dataset_code  = p_dataset_code
        AND     fb.ledger_id = P_fem_ledger_id
        AND     fb.source_system_code = 70

 GROUP BY gihg.entry_id, giet.company_cost_center_org_id,
         	giet.intercompany_id,

        giet.line_item_id;

     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_LINES_GT');

	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
        END IF;
       END IF;  -- End if for match by
 
     ELSIF (P_ELIM_MODE = 'IA') THEN
     IF (p_match_rule_code = 'COMPANY') THEN   --In Intracompany option
       g_no_rows := 0;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intracompany- Inserting entry lines'
			   || ' into GCS_ENTRY_LINES_GT'
                           || ' after matching by company'
                          );
       END IF;

       INSERT INTO  GCS_ENTRY_LINES_GT
       ( ENTRY_ID, COMPANY_COST_CENTER_ORG_ID
       , LINE_ITEM_Id, INTERCOMPANY_ID, FINANCIAL_ELEM_ID
       , PRODUCT_ID, NATURAL_ACCOUNT_ID, CHANNEL_ID
       , PROJECT_ID, CUSTOMER_ID, TASK_ID, USER_DIM1_ID
       , USER_DIM2_ID, USER_DIM3_ID, USER_DIM4_ID
       , USER_DIM5_ID, USER_DIM6_ID, USER_DIM7_ID
       , USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID
       , YTD_CREDIT_BALANCE_E , YTD_DEBIT_BALANCE_E
       , DESCRIPTION, YTD_BALANCE_E, RECEIVABLES_ORG_ID,
         PAYABLES_ORG_ID)
       SELECT /*+ ORDERED FULL(GIHG)
                INDEX(GIET GCS_INTERCO_ELM_TRX_U1)
                INDEX(GIM GCS_INTERCO_MEMBERS_U1)
                INDEX (FB FEM_BALANCES_P)
                USE_NL(GIET FB)*/
           gihg.entry_id, giet.company_cost_center_org_id
              , giet.line_item_id
              , giet.intercompany_id,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         SUM(fb.ytd_debit_balance_e)
       , SUM(fb.ytd_credit_balance_e)
       , MAX(gihg.rule_id)
      , (SUM(NVL(fb.ytd_credit_balance_e,0))
                - SUM(NVL(fb.ytd_debit_balance_e,0))),
        DECODE(MAX(gim.line_item_group), 1,
                giet.company_cost_center_org_id,
                     giet.Intercompany_id),
        DECODE(MAX(gim.line_item_group), 2,
                giet.company_cost_center_org_id,
                     giet.Intercompany_id)
       FROM     GCS_INTERCO_HDR_GT gihg,
                GCS_INTERCO_ELM_TRX giet,
	    	GCS_INTERCO_MEMBERS gim,
	    	FEM_BALANCES fb
	WHERE   giet.cal_period_id = p_cal_period_id
	AND     giet.hierarchy_id  = p_hierarchy_id
	AND     gihg.currency_code IN (p_currency_code,'STAT')
	AND	giet.line_item_id = gim.line_item_id
     	AND     giet.src_entity_id = giet.target_entity_id
	AND     giet.src_entity_id  = gihg.source_entity_id
        AND     giet.target_entity_id = gihg.target_entity_id
 	AND     gim.rule_id = gihg.rule_id
        AND     fb.entity_id = p_entity_id
	AND     giet.company_cost_center_org_id = fb.company_cost_center_org_id
	AND     giet.intercompany_id = fb.intercompany_id
	AND     giet.line_item_id = fb.line_item_id
	AND     fb.currency_code = gihg.currency_code
	AND     fb.cal_period_id = giet.cal_period_id
        AND     fb.dataset_code  = p_dataset_code
        AND     fb.ledger_id = P_fem_ledger_id
        AND     fb.source_system_code = 70

        AND NOT EXISTS (SELECT 1
                FROM   GCS_INTERCO_ELM_TRX giet3,
                       GCS_INTERCO_MEMBERS gim2
                WHERE giet3.hierarchy_id = p_hierarchy_id
                AND   giet3.cal_period_id = p_cal_period_id
                AND   giet3.src_entity_id = giet3.target_entity_id
                AND   giet3.src_entity_id = giet.src_entity_id
                AND   giet3.line_item_id = giet.line_item_id
                AND   giet3.src_company_id = giet.src_company_id
                AND   giet3.target_company_id = giet.target_company_id
 
                AND   gim2.line_item_id = giet3.line_item_id
                AND   gim2.rule_id = gihg.rule_id
                AND   gim2.line_item_group > gim.line_item_group)

 GROUP BY gihg.entry_id, giet.company_cost_center_org_id ,
         	giet.intercompany_id,

giet.line_item_id;
     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_LINES_GT');

	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
        END IF;



  ELSIF (p_match_rule_code = 'ORGANIZATION') THEN
           -- In Intracompany option
       g_no_rows := 0;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intracompany- Inserting entry lines'
			   || 'into GCS_ENTRY_LINES_GT'
                           || 'after matching by Org'
                          );
       END IF;

       INSERT INTO  GCS_ENTRY_LINES_GT
       ( ENTRY_ID, COMPANY_COST_CENTER_ORG_ID
       , LINE_ITEM_Id, INTERCOMPANY_ID, FINANCIAL_ELEM_ID
       , PRODUCT_ID, NATURAL_ACCOUNT_ID, CHANNEL_ID
       , PROJECT_ID, CUSTOMER_ID, TASK_ID, USER_DIM1_ID
       , USER_DIM2_ID, USER_DIM3_ID, USER_DIM4_ID
       , USER_DIM5_ID, USER_DIM6_ID, USER_DIM7_ID
       , USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID
       , YTD_CREDIT_BALANCE_E , YTD_DEBIT_BALANCE_E
       , DESCRIPTION , YTD_BALANCE_E,RECEIVABLES_ORG_ID,
         PAYABLES_ORG_ID )
       SELECT /*+ ORDERED FULL(GIHG)
                INDEX(GIET GCS_INTERCO_ELM_TRX_U1)
                INDEX(GIM GCS_INTERCO_MEMBERS_U1)
                INDEX (FB FEM_BALANCES_P)
                USE_NL(GIET FB)*/
                gihg.entry_id, giet.company_cost_center_org_id
              , giet.line_item_id
              , giet.intercompany_id,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         SUM(NVL(fb.ytd_debit_balance_e,0))
       , SUM(NVL(fb.ytd_credit_balance_e,0))
       , MAX(gihg.rule_id)
      , (SUM(NVL(fb.ytd_credit_balance_e,0))
                - SUM(NVL(fb.ytd_debit_balance_e,0))),
       DECODE(MAX(gim.line_item_group), 1,
                giet.company_cost_center_org_id,
                     giet.Intercompany_id),
       DECODE(MAX(gim.line_item_group), 2,
                giet.company_cost_center_org_id,
                     giet.Intercompany_id)
       FROM    	GCS_INTERCO_HDR_GT gihg,
                GCS_INTERCO_ELM_TRX giet,
	    	GCS_INTERCO_MEMBERS gim,
 	    	FEM_BALANCES fb
	WHERE   giet.cal_period_id = p_cal_period_id
	AND     giet.hierarchy_id  = p_hierarchy_id
	AND     gihg.currency_code IN (p_currency_code,'STAT')
	AND	giet.line_item_id = gim.line_item_id
    	AND     giet.src_entity_id = giet.target_entity_id
	AND     giet.src_entity_id  = gihg.source_entity_id
        AND     giet.target_entity_id = gihg.target_entity_id
 	AND     gim.rule_id = gihg.rule_id
        AND     fb.entity_id = p_entity_id
	AND     giet.company_cost_center_org_id = fb.company_cost_center_org_id
	AND     giet.intercompany_id = fb.intercompany_id
	AND     giet.line_item_id = fb.line_item_id
	AND     fb.currency_code = gihg.currency_code
	AND     fb.cal_period_id = giet.cal_period_id
        AND     fb.dataset_code  = p_dataset_code
        AND     fb.ledger_id = P_fem_ledger_id
        AND     fb.source_system_code = 70

        AND NOT EXISTS (SELECT 1
                FROM   GCS_INTERCO_ELM_TRX giet3,
                       GCS_INTERCO_MEMBERS gim2
                WHERE giet3.hierarchy_id = p_hierarchy_id
                AND   giet3.cal_period_id = p_cal_period_id
                AND     giet3.src_entity_id = giet3.target_entity_id
                AND     giet3.src_entity_id = giet.src_entity_id
                AND   giet3.line_item_id = giet.line_item_id
                 AND   giet3.company_cost_center_org_id =
                                      giet.company_cost_center_org_id
                AND   giet3.intercompany_id = giet.intercompany_id
               AND   gim2.line_item_id = giet3.line_item_id
                AND   gim2.rule_id = gihg.rule_id
                AND   gim2.line_item_group > gim.line_item_group)

 GROUP BY gihg.entry_id, giet.company_cost_center_org_id,
         	giet.intercompany_id,


        giet.line_item_id;

     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_LINES_GT');

	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
        END IF;
    End If; -- End of matching rule code in intracompany
 
     END If; -- End of elimination mode.
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     g_pkg_name || '.' || l_api_name,
                     GCS_UTILITY_PKG.g_module_success || l_api_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
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
      --                  ||l_api_name || to_char(sysdate
      --                  , ' DD-MON-YYYY HH:MI:SS'));
      RETURN FALSE;
   END INSR_INTERCO_LINES;

  --
  -- Function
  --   insr_sus_lines

  -- Purpose

  --   This routine is responsible for inserting the suspense plug in lines
  --   into the GCS_ENTRY_LINES table.

   FUNCTION  INSR_SUSPENSE_LINES (p_hierarchy_id IN NUMBER,
                                  p_cal_period_id IN NUMBER,
                                  p_entity_id IN NUMBER,
				  p_match_rule_code VARCHAR2,
				  p_balance_type  VARCHAR2,
				  p_elim_mode  IN VARCHAR2,
                                  P_Currency_code IN VARCHAR2,
                                  p_data_set_code IN NUMBER ,
                                  p_err_code OUT NOCOPY VARCHAR2,
                                  p_err_msg OUT NOCOPY VARCHAR2)
                               RETURN BOOLEAN IS

    l_api_name VARCHAR2(30) := 'INSR_SUSPENSE_LINES';

   -- Insert Suspense lines for unbalanced matched rows
   --  into GCS_ENTRY-LINES.
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
                         ' Arguments passed to Insr_Suspense_Lines() '
                         ||' Hierarchy_Id: '||p_hierarchy_id
                         ||' Cal_Period_Id: '||p_cal_period_id
                         ||' Entity_Id: '||p_entity_id
                         ||' Match Rule Code: '||p_match_rule_code
                         ||' Balance_Type: '||p_balance_type
                         ||' Elim_Mode: '||p_elim_mode
                         ||' Currency_Code: '||p_currency_code
                         ||' Dataset Code:'||p_data_set_code);

       END IF;

   IF ((P_ELIM_MODE = 'IE') OR
       (P_ELIM_MODE = 'IA')) THEN

     IF (p_match_rule_code = 'COMPANY') THEN
       g_no_rows := 0;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Inserting necessary suspense lines'
                           || ' into GCS_ENTRY_LINES_GT'
                           || ' after matching by company'
                          );
       END IF;

       INSERT INTO  GCS_ENTRY_LINES_GT
       ( ENTRY_ID, COMPANY_COST_CENTER_ORG_ID
       , FINANCIAL_ELEM_ID, LINE_ITEM_Id, INTERCOMPANY_ID
       , PRODUCT_ID, NATURAL_ACCOUNT_ID, CHANNEL_ID
       , PROJECT_ID, CUSTOMER_ID, TASK_ID, USER_DIM1_ID
       , USER_DIM2_ID, USER_DIM3_ID, USER_DIM4_ID
       , USER_DIM5_ID, USER_DIM6_ID, USER_DIM7_ID
       , USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID
       , YTD_DEBIT_BALANCE_E , YTD_CREDIT_BALANCE_E
       , DESCRIPTION, YTD_BALANCE_E)
       SELECT gihg1.entry_id
            , MAX(Receivables_org_id)
             , MAX(gihg1.sus_financial_elem_id), MAX(gihg1.sus_line_item_id)
            , MAX(payables_org_id),

     MAX(gihg1.SUS_PRODUCT_ID), MAX(gihg1.SUS_NATURAL_ACCOUNT_ID),
     MAX(gihg1.SUS_CHANNEL_ID), MAX(gihg1.SUS_PROJECT_ID),
     MAX(gihg1.SUS_CUSTOMER_ID), MAX(gihg1.SUS_TASK_ID),
     MAX(gihg1.SUS_USER_DIM1_ID), MAX(gihg1.SUS_USER_DIM2_ID),
     MAX(gihg1.SUS_USER_DIM3_ID), MAX(gihg1.SUS_USER_DIM4_ID),
     MAX(gihg1.SUS_USER_DIM5_ID), MAX(gihg1.SUS_USER_DIM6_ID),
     MAX(gihg1.SUS_USER_DIM7_ID), MAX(gihg1.SUS_USER_DIM8_ID),
     MAX(gihg1.SUS_USER_DIM9_ID), MAX(gihg1.SUS_USER_DIM10_ID),

              DECODE(GREATEST(SUM(NVL(ytd_credit_balance_e,0)),
                          SUM(NVL(ytd_debit_balance_e,0))),
                           SUM(NVL(ytd_debit_balance_e,0)), 0,
                             ABS(SUM(NVL(ytd_debit_balance_e,0))-
                                   SUM(NVL(ytd_credit_balance_e,0)))),
              DECODE(GREATEST(SUM(NVL(ytd_credit_balance_e,0)),
                          SUM(NVL(ytd_debit_balance_e,0))),
                            SUM(NVL(ytd_credit_balance_e,0)), 0,
                              ABS(SUM(NVL(ytd_debit_balance_e,0))-
                                    SUM(NVL(ytd_credit_balance_e,0))))
     , 'SUSPENSE_LINE'
     , (DECODE(GREATEST(SUM(NVL(ytd_credit_balance_e,0)),
                          SUM(NVL(ytd_debit_balance_e,0))),
                           SUM(NVL(ytd_debit_balance_e,0)), 0,
                             ABS(SUM(NVL(ytd_debit_balance_e,0))-
                                   SUM(NVL(ytd_credit_balance_e,0))))-
         DECODE(GREATEST(SUM(NVL(ytd_credit_balance_e,0)),
                          SUM(NVL(ytd_debit_balance_e,0))),
                            SUM(NVL(ytd_credit_balance_e,0)), 0,
                              ABS(SUM(NVL(ytd_debit_balance_e,0))-
                                    SUM(NVL(ytd_credit_balance_e,0)))))

                FROM    GCS_ENTRY_LINES_GT gel,
                        GCS_INTERCO_HDR_GT gihg1,
                        fem_cctr_orgs_attr  fcoa2 ,
                        fem_cctr_orgs_attr  fcoa3
                WHERE   gihg1.entry_id = gel.entry_id
                AND     gel.receivables_org_id =
                          fcoa2.company_cost_center_org_id
                AND    fcoa2.attribute_id  =
                         gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').attribute_id
                AND    fcoa2.version_id  =
                      gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').version_id
                AND    gel.payables_org_id = fcoa3.company_cost_center_org_id
                AND    fcoa3.attribute_id  =
                        gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').attribute_id
                AND    fcoa3.version_id  =
                       gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').version_id
               GROUP BY gihg1.entry_id, fcoa2.dim_attribute_numeric_member,
                           fcoa3.dim_attribute_numeric_member;

     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_LINES_GT');

	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
        END IF;

    ELSIF (p_match_rule_code = 'ORGANIZATION') THEN
        -- In Intercompany option
       g_no_rows := 0;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Inserting necessary suspense lines'
                           || ' into GCS_ENTRY_LINES_GT'
                           || ' after matching by org '
                          );
       END IF;

       INSERT INTO  GCS_ENTRY_LINES_GT
       ( ENTRY_ID, COMPANY_COST_CENTER_ORG_ID
       , FINANCIAL_ELEM_ID, LINE_ITEM_Id, INTERCOMPANY_ID
       , PRODUCT_ID, NATURAL_ACCOUNT_ID, CHANNEL_ID
       , PROJECT_ID, CUSTOMER_ID, TASK_ID, USER_DIM1_ID
       , USER_DIM2_ID, USER_DIM3_ID, USER_DIM4_ID
       , USER_DIM5_ID, USER_DIM6_ID, USER_DIM7_ID
       , USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID
       , YTD_DEBIT_BALANCE_E , YTD_CREDIT_BALANCE_E
       , DESCRIPTION , YTD_BALANCE_E)
       SELECT gihg1.entry_id, MAX(Receivables_org_id),
              MAX(gihg1.sus_financial_elem_id),
              MAX(gihg1.sus_line_item_id), MAX(payables_org_id),

     MAX(gihg1.SUS_PRODUCT_ID), MAX(gihg1.SUS_NATURAL_ACCOUNT_ID),
     MAX(gihg1.SUS_CHANNEL_ID), MAX(gihg1.SUS_PROJECT_ID),
     MAX(gihg1.SUS_CUSTOMER_ID), MAX(gihg1.SUS_TASK_ID),
     MAX(gihg1.SUS_USER_DIM1_ID), MAX(gihg1.SUS_USER_DIM2_ID),
     MAX(gihg1.SUS_USER_DIM3_ID), MAX(gihg1.SUS_USER_DIM4_ID),
     MAX(gihg1.SUS_USER_DIM5_ID), MAX(gihg1.SUS_USER_DIM6_ID),
     MAX(gihg1.SUS_USER_DIM7_ID), MAX(gihg1.SUS_USER_DIM8_ID),
     MAX(gihg1.SUS_USER_DIM9_ID), MAX(gihg1.SUS_USER_DIM10_ID),
  DECODE(GREATEST(SUM(NVL(ytd_credit_balance_e,0)),
                          SUM(NVL(ytd_debit_balance_e,0))),
                           SUM(NVL(ytd_debit_balance_e,0)), 0,
                             ABS(SUM(NVL(ytd_debit_balance_e,0))-
                                   SUM(NVL(ytd_credit_balance_e,0)))),
                  DECODE(GREATEST(SUM(NVL(ytd_credit_balance_e,0)),
                          SUM(NVL(ytd_debit_balance_e,0))),
                            SUM(NVL(ytd_credit_balance_e,0)), 0,
                              ABS(SUM(NVL(ytd_debit_balance_e,0))-
                                    SUM(NVL(ytd_credit_balance_e,0))))
                  , 'SUSPENSE_LINE',
                   (DECODE(GREATEST(SUM(NVL(ytd_credit_balance_e,0)),
                          SUM(NVL(ytd_debit_balance_e,0))),
                           SUM(NVL(ytd_debit_balance_e,0)), 0,
                             ABS(SUM(NVL(ytd_debit_balance_e,0))-
                                   SUM(NVL(ytd_credit_balance_e,0))))-
                  DECODE(GREATEST(SUM(NVL(ytd_credit_balance_e,0)),
                          SUM(NVL(ytd_debit_balance_e,0))),
                            SUM(NVL(ytd_credit_balance_e,0)), 0,
                              ABS(SUM(NVL(ytd_debit_balance_e,0))-
                                    SUM(NVL(ytd_credit_balance_e,0)))))
 FROM  GCS_ENTRY_LINES_GT gel,
                GCS_INTERCO_HDR_GT gihg1
                WHERE   gihg1.entry_id = gel.entry_id
                GROUP BY gihg1.entry_id, receivables_org_id, payables_org_id;
 
     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_LINES_GT');

	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);

      END IF;
    END IF; -- Ends matching rule code in intercompany.
  END IF; --Added to end the mode IF

       g_no_rows := 0;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                          'Intercompany- Inserting '
                           || ' into GCS_ENTRY_LINES'
                           || ' after processing'
                          );
       END IF;

       INSERT INTO  GCS_ENTRY_LINES
       ( ENTRY_ID, COMPANY_COST_CENTER_ORG_ID
       , FINANCIAL_ELEM_ID, LINE_ITEM_Id, INTERCOMPANY_ID
       , PRODUCT_ID, NATURAL_ACCOUNT_ID, CHANNEL_ID
       , PROJECT_ID, CUSTOMER_ID, TASK_ID, USER_DIM1_ID
       , USER_DIM2_ID, USER_DIM3_ID, USER_DIM4_ID
       , USER_DIM5_ID, USER_DIM6_ID, USER_DIM7_ID
       , USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID
       , YTD_DEBIT_BALANCE_E , YTD_CREDIT_BALANCE_E
       , CREATION_DATE , CREATED_BY , LAST_UPDATE_DATE
       , LAST_UPDATED_BY, LAST_UPDATE_LOGIN
       , DESCRIPTION, YTD_BALANCE_E)

        SELECT    ENTRY_ID, COMPANY_COST_CENTER_ORG_ID
       , FINANCIAL_ELEM_ID, LINE_ITEM_Id, INTERCOMPANY_ID
       , PRODUCT_ID, NATURAL_ACCOUNT_ID, CHANNEL_ID
       , PROJECT_ID, CUSTOMER_ID, TASK_ID, USER_DIM1_ID
       , USER_DIM2_ID, USER_DIM3_ID, USER_DIM4_ID
       , USER_DIM5_ID, USER_DIM6_ID, USER_DIM7_ID
       , USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID
       , YTD_DEBIT_BALANCE_E , YTD_CREDIT_BALANCE_E
       , SYSDATE, g_fnd_user_id
       , SYSDATE, g_fnd_user_id, g_fnd_login_id
       , DESCRIPTION, YTD_BALANCE_E
       FROM GCS_ENTRY_LINES_GT
       WHERE DESCRIPTION <> 'SUSPENSE_LINE'

       UNION ALL
         SELECT    ENTRY_ID, COMPANY_COST_CENTER_ORG_ID
       , FINANCIAL_ELEM_ID, LINE_ITEM_Id, INTERCOMPANY_ID
       , PRODUCT_ID, NATURAL_ACCOUNT_ID, CHANNEL_ID
       , PROJECT_ID, CUSTOMER_ID, TASK_ID, USER_DIM1_ID
       , USER_DIM2_ID, USER_DIM3_ID, USER_DIM4_ID
       , USER_DIM5_ID, USER_DIM6_ID, USER_DIM7_ID
       , USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID
       , YTD_DEBIT_BALANCE_E , YTD_CREDIT_BALANCE_E
       , SYSDATE, g_fnd_user_id
       , SYSDATE, g_fnd_user_id, g_fnd_login_id
       , DESCRIPTION, YTD_BALANCE_E
       FROM GCS_ENTRY_LINES_GT
       WHERE (DESCRIPTION = 'SUSPENSE_LINE' AND YTD_BALANCE_E <> 0);

     g_no_rows   := NVL(SQL%ROWCOUNT,0);

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
          FND_MESSAGE.Set_Token('NUM',TO_CHAR(g_no_rows));
          FND_MESSAGE.Set_Token('TABLE','GCS_ENTRY_LINES');

	  FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);

      END IF;


     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     g_pkg_name || '.' || l_api_name,
                     GCS_UTILITY_PKG.g_module_success || l_api_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
     END IF;
     Return TRUE;



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

      p_err_code := SQLCODE;
      p_err_msg  := SQLERRM;


      RETURN FALSE;
    END INSR_SUSPENSE_LINES;

  -- Procedure
  --   Insert_Interco_Trx
  -- Purpose
  --  Inserts eligible elimination transactions
  --   into GCS_INTERCO_ELM_TRX after dataprep operation.
  --   This procedure will be called from the Datapre package.
 -- Arguments
  -- P_entry_id         Entry_id (created by dataprep) for the
  --                    monetary currency
  -- p_stat_entry_id    Entry id (created by dataprep) for the stat currency
  -- p_Hierarchy_id     Hierarchy_id for the above entries.
  --                    This hierarchy id will

 --                    be used to determine the matching rule like
  -- 		        match by organization, match by company,
  --                    or match by cost center.
  -- x_errbuf           Returns error message to concurrent manager,
  --                    if there are any errors.
  -- x_retcode          Returns error code to concurrent manager,
  --                    if there are any errors.

  -- Synatx for Calling from external package.

     --  GCS_INTERCO_DYNAMIC_PKG.INSERT_INTERCO_TRX(1112,
     --					            1114,
     --  				            10041, err, err_code)
     --

     --



  PROCEDURE INSERT_INTERCO_TRX(p_entry_id In NUMBER,
                               p_stat_entry_id IN NUMBER,
                               p_hierarchy_id IN NUMBER,
                               p_period_end_date  IN  DATE,
                               x_errbuf OUT NOCOPY VARCHAR2,
                               x_retcode OUT NOCOPY VARCHAR2) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name 		VARCHAR2(50) := 'INSERT_INTERCO_TRX';
    x_match_rule_code  	VARCHAR2(30);
    l_no_rows   	NUMBER:= 0;
    x_intercompany_org_code VARCHAR2(30);
    x_specific_intercompany_id  NUMBER;
    x_lob_reporting_enabled   VARCHAR2(30);
    x_lob_hierarchy_obj_id    NUMBER;
    x_lob_dim_column_name     VARCHAR2(30);
    l_valid_hierarchy_id      NUMBER;


    NO_MATCH_RULE_CODE   Exception;
    Hierarchy_check_failed Exception;





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

          -- Get the matching rule for the given hierarchy_id
	  -- for matching intercompany eliminations such as by organization,
	  -- by company or by cost center.

	 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	            fnd_log.STRING (fnd_log.level_procedure,
	                            g_pkg_name || '.' || l_api_name,
	                           'Get the matching rule information'
	                           );
	 END IF;

	  BEGIN

	       SELECT  ghb.ie_by_org_code,
                       DECODE(gcb.specific_intercompany_id, NULL,
                                              'N', 'SPECIFIC_VALUE'),
                       gcb.specific_intercompany_id,
                       ghb.lob_reporting_enabled_flag,
                       ghb.lob_hierarchy_obj_id,
		       ghb.lob_dim_column_name
 	       INTO   x_match_rule_code,
                      x_intercompany_org_code,
                      x_specific_intercompany_id,
                      x_lob_reporting_enabled,
                      x_lob_hierarchy_obj_id,
		      x_lob_dim_column_name
 	       FROM GCS_HIERARCHIES_B ghb, gcs_categories_b gcb
	       WHERE ghb.hierarchy_id = p_hierarchy_id
               AND   gcb.category_code = 'INTRACOMPANY'
               AND   rownum = 1;


	  EXCEPTION

	      WHEN NO_DATA_FOUND Then
	       Raise NO_MATCH_RULE_CODE;
	  END;

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                         ' Arguments Hierarchy_id :'||p_hierarchy_id
                         ||' Stat Entry Id: '|| p_stat_entry_id
                         ||' Entry id: '||p_entry_id
                         ||' Matching Rule: '||x_match_rule_code
                         ||' Period End Date: '||p_period_end_date
                         ||' Intercompany code: '||x_intercompany_org_code
                         ||' Spec. interco value: '
                                     ||x_specific_intercompany_id
                         ||' LOB Reporting Enabled: '
                                     || x_lob_reporting_enabled
                         ||' Cost Center Hierarchy Obj Id: '
                                     ||x_lob_hierarchy_obj_id
                      );

      END IF;



  IF  (x_match_rule_code = 'ORGANIZATION') THEN

   IF ((x_lob_reporting_enabled = 'Y')
      AND (x_lob_hierarchy_obj_id IS NOT NULL)) THEN

	 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	            fnd_log.STRING (fnd_log.level_procedure,
	                            g_pkg_name || '.' || l_api_name,
	                           'Entered into LOB support block'
	                           );
	 END IF;

    BEGIN

	 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	            fnd_log.STRING (fnd_log.level_procedure,
	                            g_pkg_name || '.' || l_api_name,
	                           'Checking Hierarchy date effectivity'
	                           );
	 END IF;

        SELECT object_definition_id INTO l_valid_hierarchy_id
        FROM FEM_OBJECT_DEFINITION_B fod
        WHERE  fod.object_id = x_lob_hierarchy_obj_id
        AND    (p_period_end_date
                BETWEEN NVL(fod.effective_start_date,
                      TO_DATE('01/01/1950','MM/DD/YYYY'))
	               AND NVL(fod.effective_end_date,
                         TO_DATE('12/31/9999','MM/DD/YYYY')));


    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_valid_hierarchy_id :=0;

	 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	            fnd_log.STRING (fnd_log.level_procedure,
	                            g_pkg_name || '.' || l_api_name,
	                           'Hierarchy date effectivity failed'
                                   || ' either due to wrong hierarchy or '
                                   ||' period end date is not falling '
                                   ||' start date and end date'
	                           );
	 END IF;
          null;
          --Raise Hierarchy_Check_Failed;

       WHEN OTHERS THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
	                   g_pkg_name || '.' || l_api_name
                           ||' Hierarchy_Check  ',
                           SUBSTR(SQLERRM, 1, 255));

        END IF;

    END;


          IF (x_intercompany_org_code = 'SPECIFIC_VALUE') THEN

	  l_no_rows   := 0;

	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	            fnd_log.STRING (fnd_log.level_procedure,
	                  g_pkg_name || '.' || l_api_name,
	             'Inserting intercompany transactions for matching by'
	            || ' organization into GCS_INTERCO_ELM_TRX'
                    || ' - LOB REPORTING ENABLED ');
	   END IF;
	   Insert INTO gcs_interco_elm_trx
	         (hierarchy_id, cal_period_id,  company_cost_center_org_id,
                  src_entity_id, src_company_id, src_cost_center_id,
                  intercompany_id, target_company_id,
	          target_cost_center_id, target_entity_id,
                  currency_code,  line_item_id, financial_elem_id,
                  product_id, natural_account_id, channel_id,
                  project_id, customer_id, task_id,
	          user_dim1_id, user_dim2_id, user_dim3_id,
                  user_dim4_id, user_dim5_id, user_dim6_id,
	          user_dim7_id, user_dim8_id, user_dim9_id,
                  user_dim10_id,creation_date,
	          created_by, last_update_date, last_updated_by,
                  last_update_login, elim_lob_id)

	   SELECT DISTINCT geh.hierarchy_id, geh.start_cal_period_id,
                  gel.company_cost_center_org_id,
	          geo1.entity_id, NULL, NULL, gel.intercompany_id,
                  NULL,NULL, geo.entity_id, geh.currency_code,
	          gel.line_item_id,
  NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL, 
	          SYSDATE, g_fnd_user_id,
                  SYSDATE, g_fnd_user_id,
                  g_fnd_login_id,
                DECODE(fcoa2.dim_attribute_numeric_member,
                       fcoa3.dim_attribute_numeric_member,
                       fcoa2.dim_attribute_numeric_member,
                       fcca.dim_attribute_numeric_member)
	   FROM   GCS_ENTRY_HEADERS geh,
	          GCS_ENTRY_LINES  gel,
	          GCS_ENTITY_CCTR_ORGS geo,
	          GCS_ENTITY_CCTR_ORGS geo1,
                  GCS_CONS_RELATIONSHIPS  gcr,
                  GCS_CONS_RELATIONSHIPS  gcr1,
                  fem_cctr_orgs_attr fcoa2,
                  fem_cctr_orgs_attr fcoa3,
                  fem_user_dim1_attr fcca
	   WHERE  geh.entry_id IN (p_entry_id, p_stat_entry_id)
	   AND    geh.entry_id = gel.entry_id
           AND    gel.intercompany_id <> x_specific_intercompany_id
	   AND    gel.intercompany_id =
                                 geo.company_cost_center_org_id
	   AND    gel.company_cost_center_org_id =
                                 geo1.company_cost_center_org_id
           AND    geh.hierarchy_id = gcr.hierarchy_id
	   AND (p_period_end_date
           BETWEEN NVL(gcr.start_date, p_period_end_date)
	     AND NVL(gcr.end_date, p_period_end_date))
           AND    gcr.child_entity_id = geo.entity_id
           AND    gcr.actual_ownership_flag ='Y'
           AND    gcr.dominant_parent_flag = 'Y'
           AND    geh.hierarchy_id = gcr1.hierarchy_id
	   AND (p_period_end_date
           BETWEEN NVL(gcr1.start_date, p_period_end_date)
	     AND NVL(gcr1.end_date, p_period_end_date))
           AND    gcr1.child_entity_id = geo1.entity_id
           AND    gcr1.actual_ownership_flag ='Y'
           AND    gcr1.dominant_parent_flag = 'Y'

           AND    gel.company_cost_center_org_id =
                     fcoa2.company_cost_center_org_id
           AND    fcoa2.attribute_id  =
                   gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COST_CENTER').attribute_id
            AND    fcoa2.version_id  =
                   gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COST_CENTER').version_id
           AND    gel.intercompany_id = fcoa3.company_cost_center_org_id
           AND    fcoa3.attribute_id  =
gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COST_CENTER').attribute_id
           AND    fcoa3.version_id  =
gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COST_CENTER').version_id
           AND    fcca.attribute_id = gcs_utility_pkg.g_dimension_attr_info('USER_DIM1_ID-ELIMINATION_LOB').attribute_id
           AND    fcca.version_id = gcs_utility_pkg.g_dimension_attr_info('USER_DIM1_ID-ELIMINATION_LOB').version_id

       AND    fcca.user_dim1_id = (
                        SELECT fcch1.parent_id
                        FROM  fem_user_dim1_hier fcch1,
                              fem_user_dim1_hier fcch2
                        WHERE  fcch1.child_id =
                                            fcoa2.dim_attribute_numeric_member
                        AND    fcch1.hierarchy_obj_def_id =
                                     l_valid_hierarchy_id
                        AND    fcch1.parent_id <> fcch1.child_id
                                          -- *** To eliminte self rows
                        AND    fcch2.child_id =
                                        fcoa3.dim_attribute_numeric_member
                        AND    fcch2.hierarchy_obj_def_id =
                                                l_valid_hierarchy_id
                        AND    fcch2.parent_id <> fcch2.child_id
                                            -- *** To eliminte self rows
                        AND    fcch1.parent_id = fcch2.parent_id
                        AND    fcch1.parent_depth_num =
                               (SELECT MAX(fcch3.parent_depth_num)
                                FROM  fem_user_dim1_hier fcch3,
                                      fem_user_dim1_hier fcch4
                                WHERE fcch3.child_id =
                                       fcoa2.dim_attribute_numeric_member
                                AND    fcch3.hierarchy_obj_def_id =
                                                       l_valid_hierarchy_id
                                AND    fcch3.parent_id <> fcch3.child_id
                                          -- *** To eliminte self rows
                                AND    fcch4.child_id =
                                           fcoa3.dim_attribute_numeric_member
                                AND    fcch4.hierarchy_obj_def_id =
                                                    l_valid_hierarchy_id
                                AND    fcch4.parent_id <> fcch4.child_id
                                            -- *** To eliminte self rows
                                AND    fcch3.parent_id = fcch4.parent_id
                                                                   ))

                 AND NOT EXISTS ( SELECT 1 FROM GCS_INTERCO_ELM_TRX giet1
                 WHERE  giet1.hierarchy_id = geh.hierarchy_id
                 AND    giet1.cal_period_id = geh.start_cal_period_id
                 AND    giet1.company_cost_center_org_id =
                                       gel.company_cost_center_org_id
                 AND    giet1.src_entity_id = geo1.entity_id
                 AND    giet1.target_entity_id = geo.entity_id
                 AND    giet1.intercompany_id = gel.intercompany_id
                   AND    giet1.line_item_id = gel.line_item_id) ;

           l_no_rows   := NVL(SQL%ROWCOUNT,0);

	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
	       FND_MESSAGE.Set_Token('NUM',TO_CHAR(l_no_rows));
	       FND_MESSAGE.Set_Token('TABLE','GCS_INTERCO_ELM_TRX');

               FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
               --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
            END IF;

          ELSE

	  l_no_rows   := 0;

	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	            fnd_log.STRING (fnd_log.level_procedure,
	                  g_pkg_name || '.' || l_api_name,
	             'Inserting intercompany transactions for matching by'
	            || ' organization into GCS_INTERCO_ELM_TRX'
                    || ' - LOB REPORTING ENABLED ');
	   END IF;
	   Insert INTO gcs_interco_elm_trx
	         (hierarchy_id, cal_period_id,  company_cost_center_org_id,
                  src_entity_id, src_company_id, src_cost_center_id,
                  intercompany_id, target_company_id,
	          target_cost_center_id, target_entity_id,
                  currency_code,  line_item_id, financial_elem_id,
                  product_id, natural_account_id, channel_id,
                  project_id, customer_id, task_id,
	          user_dim1_id, user_dim2_id, user_dim3_id,
                  user_dim4_id, user_dim5_id, user_dim6_id,
	          user_dim7_id, user_dim8_id, user_dim9_id,
                  user_dim10_id,creation_date,
	          created_by, last_update_date, last_updated_by,
                  last_update_login, elim_lob_id)

	   SELECT DISTINCT geh.hierarchy_id, geh.start_cal_period_id,
                  gel.company_cost_center_org_id,
	          geo1.entity_id, NULL, NULL, gel.intercompany_id,
                  NULL,NULL, geo.entity_id, geh.currency_code,
	          gel.line_item_id,
  NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL, 
	          SYSDATE, g_fnd_user_id,
                  SYSDATE, g_fnd_user_id,
                  g_fnd_login_id,
                DECODE(fcoa2.dim_attribute_numeric_member,
                       fcoa3.dim_attribute_numeric_member,
                       fcoa2.dim_attribute_numeric_member,
                       fcca.dim_attribute_numeric_member)
	   FROM   GCS_ENTRY_HEADERS geh,
	          GCS_ENTRY_LINES  gel,
	          GCS_ENTITY_CCTR_ORGS geo,
	          GCS_ENTITY_CCTR_ORGS geo1,
                  GCS_CONS_RELATIONSHIPS  gcr,
                  GCS_CONS_RELATIONSHIPS  gcr1,
                  fem_cctr_orgs_attr fcoa2,
                  fem_cctr_orgs_attr fcoa3,
                  fem_user_dim1_attr fcca
	   WHERE  geh.entry_id IN (p_entry_id, p_stat_entry_id)
	   AND    geh.entry_id = gel.entry_id
           AND    gel.intercompany_id <> gel.company_cost_center_org_id
	   AND    gel.intercompany_id =
                                 geo.company_cost_center_org_id
	   AND    gel.company_cost_center_org_id =
                                 geo1.company_cost_center_org_id
           AND    geh.hierarchy_id = gcr.hierarchy_id
	   AND (p_period_end_date
           BETWEEN NVL(gcr.start_date, p_period_end_date)
	     AND NVL(gcr.end_date, p_period_end_date))
           AND    gcr.child_entity_id = geo.entity_id
           AND    gcr.actual_ownership_flag ='Y'
           AND    gcr.dominant_parent_flag = 'Y'
           AND    geh.hierarchy_id = gcr1.hierarchy_id
	   AND (p_period_end_date
           BETWEEN NVL(gcr1.start_date, p_period_end_date)
	     AND NVL(gcr1.end_date, p_period_end_date))
           AND    gcr1.child_entity_id = geo1.entity_id
           AND    gcr1.actual_ownership_flag ='Y'
           AND    gcr1.dominant_parent_flag = 'Y'

           AND    gel.company_cost_center_org_id =
                     fcoa2.company_cost_center_org_id
           AND    fcoa2.attribute_id  =
                   gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COST_CENTER').attribute_id
            AND    fcoa2.version_id  =
                   gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COST_CENTER').version_id
           AND    gel.intercompany_id = fcoa3.company_cost_center_org_id
           AND    fcoa3.attribute_id  =
gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COST_CENTER').attribute_id
           AND    fcoa3.version_id  =
gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COST_CENTER').version_id
           AND    fcca.attribute_id = gcs_utility_pkg.g_dimension_attr_info('USER_DIM1_ID-ELIMINATION_LOB').attribute_id
           AND    fcca.version_id = gcs_utility_pkg.g_dimension_attr_info('USER_DIM1_ID-ELIMINATION_LOB').version_id

       AND    fcca.user_dim1_id = (
                        SELECT fcch1.parent_id
                        FROM  fem_user_dim1_hier fcch1,
                              fem_user_dim1_hier fcch2
                        WHERE  fcch1.child_id =
                                            fcoa2.dim_attribute_numeric_member
                        AND    fcch1.hierarchy_obj_def_id =
                                     l_valid_hierarchy_id
                        AND    fcch1.parent_id <> fcch1.child_id
                                          -- *** To eliminte self rows
                        AND    fcch2.child_id =
                                        fcoa3.dim_attribute_numeric_member
                        AND    fcch2.hierarchy_obj_def_id =
                                                l_valid_hierarchy_id
                        AND    fcch2.parent_id <> fcch2.child_id
                                            -- *** To eliminte self rows
                        AND    fcch1.parent_id = fcch2.parent_id
                        AND    fcch1.parent_depth_num =
                               (SELECT MAX(fcch3.parent_depth_num)
                                FROM  fem_user_dim1_hier fcch3,
                                      fem_user_dim1_hier fcch4
                                WHERE fcch3.child_id =
                                       fcoa2.dim_attribute_numeric_member
                                AND    fcch3.hierarchy_obj_def_id =
                                                       l_valid_hierarchy_id
                                AND    fcch3.parent_id <> fcch3.child_id
                                          -- *** To eliminte self rows
                                AND    fcch4.child_id =
                                           fcoa3.dim_attribute_numeric_member
                                AND    fcch4.hierarchy_obj_def_id =
                                                    l_valid_hierarchy_id
                                AND    fcch4.parent_id <> fcch4.child_id
                                            -- *** To eliminte self rows
                                AND    fcch3.parent_id = fcch4.parent_id
                                                                   ))

                 AND NOT EXISTS ( SELECT 1 FROM GCS_INTERCO_ELM_TRX giet1
                 WHERE  giet1.hierarchy_id = geh.hierarchy_id
                 AND    giet1.cal_period_id = geh.start_cal_period_id
                 AND    giet1.company_cost_center_org_id =
                                       gel.company_cost_center_org_id
                 AND    giet1.src_entity_id = geo1.entity_id
                 AND    giet1.target_entity_id = geo.entity_id
                 AND    giet1.intercompany_id = gel.intercompany_id
                   AND    giet1.line_item_id = gel.line_item_id) ;

           l_no_rows   := NVL(SQL%ROWCOUNT,0);

	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
	       FND_MESSAGE.Set_Token('NUM',TO_CHAR(l_no_rows));
	       FND_MESSAGE.Set_Token('TABLE','GCS_INTERCO_ELM_TRX');

               FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
               --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
            END IF;
        END IF; -- end of x_intercompany_org_code if

     ELSE
        -- This is for LOB_REPORTING_ENABLED flag is N
        -- Regular matching by organization.
          IF (x_intercompany_org_code = 'SPECIFIC_VALUE') THEN
	  l_no_rows   := 0;

	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	            fnd_log.STRING (fnd_log.level_procedure,
	                  g_pkg_name || '.' || l_api_name,
	             'Inserting intercompany transactions for matching by'
	            || ' organization into GCS_INTERCO_ELM_TRX'
                    || ' - LOB REPORTING Disabled');
	   END IF;

	   Insert INTO gcs_interco_elm_trx
	         (hierarchy_id, cal_period_id,  company_cost_center_org_id,
                  src_entity_id, src_company_id, src_cost_center_id,
                  intercompany_id, target_company_id,
	          target_cost_center_id, target_entity_id,
                  currency_code,  line_item_id, financial_elem_id,
                  product_id, natural_account_id, channel_id,
                  project_id, customer_id, task_id,
	          user_dim1_id, user_dim2_id, user_dim3_id,
                  user_dim4_id, user_dim5_id, user_dim6_id,
	          user_dim7_id, user_dim8_id, user_dim9_id,
                  user_dim10_id,creation_date,
	          created_by, last_update_date, last_updated_by,
                  last_update_login)

	   SELECT DISTINCT geh.hierarchy_id, geh.start_cal_period_id,
                  gel.company_cost_center_org_id,
	          geo1.entity_id, NULL, NULL, gel.intercompany_id,
                  NULL,NULL, geo.entity_id, geh.currency_code,
	          gel.line_item_id,
  NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL, 
	          SYSDATE, g_fnd_user_id,
                  SYSDATE, g_fnd_user_id,
                  g_fnd_login_id
	   FROM   GCS_ENTRY_HEADERS geh,
	          GCS_ENTRY_LINES  gel,
	          GCS_ENTITY_CCTR_ORGS geo,
	          GCS_ENTITY_CCTR_ORGS geo1,
                  GCS_CONS_RELATIONSHIPS  gcr,
                  GCS_CONS_RELATIONSHIPS  gcr1
	   WHERE  geh.entry_id IN (p_entry_id, p_stat_entry_id)
	   AND    geh.entry_id = gel.entry_id
           AND    gel.intercompany_id <> x_specific_intercompany_id
	   AND    gel.intercompany_id =
                                 geo.company_cost_center_org_id
	   AND    gel.company_cost_center_org_id =
                                 geo1.company_cost_center_org_id
           AND    geh.hierarchy_id = gcr.hierarchy_id
	   AND (p_period_end_date
           BETWEEN NVL(gcr.start_date, p_period_end_date)
	     AND NVL(gcr.end_date, p_period_end_date))
           AND    gcr.child_entity_id = geo.entity_id
           AND    gcr.actual_ownership_flag ='Y'
           AND    gcr.dominant_parent_flag = 'Y'
           AND    geh.hierarchy_id = gcr1.hierarchy_id
	   AND (p_period_end_date
           BETWEEN NVL(gcr1.start_date, p_period_end_date)
	     AND NVL(gcr.end_date, p_period_end_date))
           AND    gcr1.child_entity_id = geo1.entity_id
           AND    gcr1.actual_ownership_flag ='Y'
           AND    gcr1.dominant_parent_flag = 'Y'

                 AND NOT EXISTS ( SELECT 1 FROM GCS_INTERCO_ELM_TRX giet1
                 WHERE  giet1.hierarchy_id = geh.hierarchy_id
                 AND    giet1.cal_period_id = geh.start_cal_period_id
                 AND    giet1.company_cost_center_org_id =
                                       gel.company_cost_center_org_id
                 AND    giet1.src_entity_id = geo1.entity_id
                 AND    giet1.target_entity_id = geo.entity_id
                 AND    giet1.intercompany_id = gel.intercompany_id
  
                AND    giet1.line_item_id = gel.line_item_id);

           l_no_rows   := NVL(SQL%ROWCOUNT,0);

	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
	       FND_MESSAGE.Set_Token('NUM',TO_CHAR(l_no_rows));
	       FND_MESSAGE.Set_Token('TABLE','GCS_INTERCO_ELM_TRX');

               FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
               --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
            END IF;

          ELSE
	  l_no_rows   := 0;

	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	            fnd_log.STRING (fnd_log.level_procedure,
	                  g_pkg_name || '.' || l_api_name,
	             'Inserting intercompany transactions for matching by'
	            || ' organization into GCS_INTERCO_ELM_TRX'
                    || ' - LOB REPORTING Disabled');
	   END IF;

	   Insert INTO gcs_interco_elm_trx
	         (hierarchy_id, cal_period_id,  company_cost_center_org_id,
                  src_entity_id, src_company_id, src_cost_center_id,
                  intercompany_id, target_company_id,
	          target_cost_center_id, target_entity_id,
                  currency_code,  line_item_id, financial_elem_id,
                  product_id, natural_account_id, channel_id,
                  project_id, customer_id, task_id,
	          user_dim1_id, user_dim2_id, user_dim3_id,
                  user_dim4_id, user_dim5_id, user_dim6_id,
	          user_dim7_id, user_dim8_id, user_dim9_id,
                  user_dim10_id,creation_date,
	          created_by, last_update_date, last_updated_by,
                  last_update_login)

	   SELECT DISTINCT geh.hierarchy_id, geh.start_cal_period_id,
                  gel.company_cost_center_org_id,
	          geo1.entity_id, NULL, NULL, gel.intercompany_id,
                  NULL,NULL, geo.entity_id, geh.currency_code,
	          gel.line_item_id,
  NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL, 
	          SYSDATE, g_fnd_user_id,
                  SYSDATE, g_fnd_user_id,
                  g_fnd_login_id
	   FROM   GCS_ENTRY_HEADERS geh,
	          GCS_ENTRY_LINES  gel,
	          GCS_ENTITY_CCTR_ORGS geo,
                  GCS_ENTITY_CCTR_ORGS geo1,
                  GCS_CONS_RELATIONSHIPS  gcr,
                  GCS_CONS_RELATIONSHIPS  gcr1
	   WHERE  geh.entry_id IN (p_entry_id, p_stat_entry_id)
	   AND    geh.entry_id = gel.entry_id
           AND    gel.intercompany_id <> gel.company_cost_center_org_id
	   AND    gel.intercompany_id =
                                 geo.company_cost_center_org_id
	   AND    gel.company_cost_center_org_id =
                                 geo1.company_cost_center_org_id
           AND    geh.hierarchy_id = gcr.hierarchy_id
	   AND (p_period_end_date
           BETWEEN NVL(gcr.start_date, p_period_end_date)
	     AND NVL(gcr.end_date, p_period_end_date))
           AND    gcr.child_entity_id = geo.entity_id
           AND    gcr.actual_ownership_flag ='Y'
           AND    gcr.dominant_parent_flag = 'Y'
           AND    geh.hierarchy_id = gcr1.hierarchy_id
	   AND (p_period_end_date
           BETWEEN NVL(gcr1.start_date, p_period_end_date)
	     AND NVL(gcr1.end_date, p_period_end_date))
           AND    gcr1.child_entity_id = geo1.entity_id
           AND    gcr1.actual_ownership_flag ='Y'
           AND    gcr1.dominant_parent_flag = 'Y'

                 AND NOT EXISTS ( SELECT 1 FROM GCS_INTERCO_ELM_TRX giet1
                 WHERE  giet1.hierarchy_id = geh.hierarchy_id
                 AND    giet1.cal_period_id = geh.start_cal_period_id
                 AND    giet1.company_cost_center_org_id =
                                       gel.company_cost_center_org_id
                 AND    giet1.src_entity_id = geo1.entity_id
                 AND    giet1.target_entity_id = geo.entity_id
                 AND    giet1.intercompany_id = gel.intercompany_id
  
                AND    giet1.line_item_id = gel.line_item_id);

           l_no_rows   := NVL(SQL%ROWCOUNT,0);

	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
	       FND_MESSAGE.Set_Token('NUM',TO_CHAR(l_no_rows));
	       FND_MESSAGE.Set_Token('TABLE','GCS_INTERCO_ELM_TRX');

               FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
               --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);
            END IF;
        END IF; -- end of x_intercompany_org_code if
    END IF; -- End of LOB_REPORTING_ENABLED IF clause.

         ELSIF  (x_match_rule_code = 'COMPANY') THEN

          if (x_intercompany_org_code = 'SPECIFIC_VALUE') THEN

            l_no_rows   := 0;
                	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
                  'Specific_Value - '
	          ||' Inserting intercompany transactions for matching by'
	          ||' company intercompany into GCS_INTERCO_ELM_TRX');
	   END IF;

	   Insert /* PARALLEL ( GCS_INTERCO_ELM_TRX) */
                  INTO gcs_interco_elm_trx
	         (hierarchy_id, cal_period_id,  company_cost_center_org_id,
                  src_entity_id, src_company_id, src_cost_center_id,
                  intercompany_id, target_company_id,
	          target_cost_center_id, target_entity_id,
                  currency_code, line_item_id, financial_elem_id,
                  product_id, natural_account_id, channel_id,
                  project_id, customer_id, task_id,
	          user_dim1_id, user_dim2_id, user_dim3_id,
                  user_dim4_id, user_dim5_id, user_dim6_id,
	          user_dim7_id, user_dim8_id, user_dim9_id,
                  user_dim10_id,creation_date,
	          created_by, last_update_date, last_updated_by,
                  last_update_login)

           SELECT DISTINCT geh.hierarchy_id, geh.start_cal_period_id,
                  gel.company_cost_center_org_id,
                  geo1.entity_id,fcoa2.dim_attribute_numeric_member, NULL,
                  gel.intercompany_id,
                  fcoa3.dim_attribute_numeric_member, NULL, geo.entity_id,
                  geh.currency_code, gel.line_item_id,

  NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL, 
                  SYSDATE, g_fnd_user_id,
                  SYSDATE, g_fnd_user_id,
                  g_fnd_login_id
	   FROM   GCS_ENTRY_HEADERS geh,
                  GCS_ENTRY_LINES  gel,
                  GCS_ENTITY_CCTR_ORGS geo,
                  GCS_ENTITY_CCTR_ORGS geo1,
                  GCS_CONS_RELATIONSHIPS  gcr,
                  GCS_CONS_RELATIONSHIPS  gcr1,
                 fem_cctr_orgs_attr fcoa2,
                 fem_cctr_orgs_attr fcoa3
	  WHERE  geh.entry_id IN (p_entry_id, p_stat_entry_id)
          AND    geh.entry_id = gel.entry_id
          AND    gel.intercompany_id <> x_specific_intercompany_id
          AND    gel.intercompany_id =
                       geo.company_cost_center_org_id
	  AND    gel.company_cost_center_org_id =
                                 geo1.company_cost_center_org_id
          AND    geh.hierarchy_id = gcr.hierarchy_id
	  AND (p_period_end_date
           BETWEEN NVL(gcr.start_date, p_period_end_date )
	     AND NVL(gcr.end_date, p_period_end_date ))
          AND    gcr.child_entity_id = geo.entity_id
          AND    gcr.actual_ownership_flag ='Y'
          AND    gcr.dominant_parent_flag = 'Y'
          AND    gel.company_cost_center_org_id =
                      fcoa2.company_cost_center_org_id
          AND    geh.hierarchy_id = gcr1.hierarchy_id
	  AND (p_period_end_date
           BETWEEN NVL(gcr1.start_date, p_period_end_date )
	     AND NVL(gcr1.end_date, p_period_end_date ))
          AND    gcr1.child_entity_id = geo1.entity_id
          AND    gcr1.actual_ownership_flag ='Y'
          AND    gcr1.dominant_parent_flag = 'Y'

          AND    fcoa2.attribute_id  =
gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').attribute_id
          AND    fcoa2.version_id  =
gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').version_id
          AND    gel.intercompany_id = fcoa3.company_cost_center_org_id
          AND    fcoa3.attribute_id  =
gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').attribute_id
          AND    fcoa3.version_id  =
gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').version_id


                 AND NOT EXISTS ( SELECT 1 FROM GCS_INTERCO_ELM_TRX giet1
                 WHERE  giet1.hierarchy_id = geh.hierarchy_id
                 AND    giet1.cal_period_id = geh.start_cal_period_id
                 AND    giet1.company_cost_center_org_id =
                                       gel.company_cost_center_org_id
                 AND    giet1.src_company_id =
                                fcoa2.dim_attribute_numeric_member
                 AND    giet1.src_entity_id = geo1.entity_id
                 AND    giet1.target_entity_id = geo.entity_id
                 AND    giet1.target_company_id =
                                fcoa3.dim_attribute_numeric_member
                 AND    giet1.intercompany_id = gel.intercompany_id

                AND    giet1.line_item_id = gel.line_item_id);

           l_no_rows   := NVL(SQL%ROWCOUNT,0);

	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
	       FND_MESSAGE.Set_Token('NUM',TO_CHAR(l_no_rows));
	       FND_MESSAGE.Set_Token('TABLE','GCS_INTERCO_ELM_TRX');

	        FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
	       --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);

            END IF;



       ELSE

            l_no_rows   := 0;
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
                  ' Org and Interco are different - '
	          ||'Inserting intercompany transactions for matching by'
	          ||' company intercompany into GCS_INTERCO_ELM_TRX');
	   END IF;

	   Insert /* PARALLEL ( GCS_INTERCO_ELM_TRX) */
                  INTO gcs_interco_elm_trx
	         (hierarchy_id, cal_period_id,  company_cost_center_org_id,
                  src_entity_id, src_company_id, src_cost_center_id,
                  intercompany_id, target_company_id,
	          target_cost_center_id, target_entity_id,
                  currency_code, line_item_id, financial_elem_id,
                  product_id, natural_account_id, channel_id,
                  project_id, customer_id, task_id,
	          user_dim1_id, user_dim2_id, user_dim3_id,
                  user_dim4_id, user_dim5_id, user_dim6_id,
	          user_dim7_id, user_dim8_id, user_dim9_id,
                  user_dim10_id,creation_date,
	          created_by, last_update_date, last_updated_by,
                  last_update_login)

           SELECT DISTINCT geh.hierarchy_id, geh.start_cal_period_id,
                  gel.company_cost_center_org_id,
                  geo1.entity_id,fcoa2.dim_attribute_numeric_member, NULL,
                  gel.intercompany_id,
                  fcoa3.dim_attribute_numeric_member, NULL, geo.entity_id,
                  geh.currency_code, gel.line_item_id,

  NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL, 
                  SYSDATE, g_fnd_user_id,
                  SYSDATE, g_fnd_user_id,
                  g_fnd_login_id
	   FROM   GCS_ENTRY_HEADERS geh,
                  GCS_ENTRY_LINES  gel,
                  GCS_ENTITY_CCTR_ORGS geo,
                  GCS_ENTITY_CCTR_ORGS geo1,
                  GCS_CONS_RELATIONSHIPS  gcr,
                  GCS_CONS_RELATIONSHIPS  gcr1,
                 fem_cctr_orgs_attr fcoa2,
                 fem_cctr_orgs_attr fcoa3
	  WHERE  geh.entry_id IN (p_entry_id, p_stat_entry_id)
          AND    geh.entry_id = gel.entry_id
          AND    gel.intercompany_id =
                       geo.company_cost_center_org_id
	  AND    gel.company_cost_center_org_id =
                                 geo1.company_cost_center_org_id
          AND    geh.hierarchy_id = gcr.hierarchy_id
	  AND (p_period_end_date
           BETWEEN NVL(gcr.start_date, p_period_end_date )
	     AND NVL(gcr.end_date, p_period_end_date ))
          AND    gcr.child_entity_id = geo.entity_id
          AND    gcr.actual_ownership_flag ='Y'
          AND    gcr.dominant_parent_flag = 'Y'
          AND    geh.hierarchy_id = gcr1.hierarchy_id
	  AND (p_period_end_date
           BETWEEN NVL(gcr1.start_date, p_period_end_date )
	     AND NVL(gcr1.end_date, p_period_end_date ))
          AND    gcr1.child_entity_id = geo1.entity_id
          AND    gcr1.actual_ownership_flag ='Y'
          AND    gcr1.dominant_parent_flag = 'Y'
          AND    gel.company_cost_center_org_id =
                      fcoa2.company_cost_center_org_id

          AND    fcoa2.attribute_id  =
gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').attribute_id
          AND    fcoa2.version_id  =
gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').version_id
          AND    gel.intercompany_id = fcoa3.company_cost_center_org_id
          AND    fcoa3.attribute_id  =
gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').attribute_id
          AND    fcoa3.version_id  =
gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').version_id
        AND  fcoa3.dim_attribute_numeric_member <>
                          fcoa2.dim_attribute_numeric_member


                 AND NOT EXISTS ( SELECT 1 FROM GCS_INTERCO_ELM_TRX giet1
                 WHERE  giet1.hierarchy_id = geh.hierarchy_id
                 AND    giet1.cal_period_id = geh.start_cal_period_id
                 AND    giet1.company_cost_center_org_id =
                                       gel.company_cost_center_org_id
                 AND    giet1.src_company_id =
                                fcoa2.dim_attribute_numeric_member
                 AND    giet1.src_entity_id = geo1.entity_id
                 AND    giet1.target_entity_id = geo.entity_id
                 AND    giet1.target_company_id =
                                fcoa3.dim_attribute_numeric_member
                 AND    giet1.intercompany_id = gel.intercompany_id

                AND    giet1.line_item_id = gel.line_item_id);

           l_no_rows   := NVL(SQL%ROWCOUNT,0);

	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_MESSAGE.Set_Name('SQLGL','SHRD0117');
	       FND_MESSAGE.Set_Token('NUM',TO_CHAR(l_no_rows));
	       FND_MESSAGE.Set_Token('TABLE','GCS_INTERCO_ELM_TRX');

	        FND_LOG.String (fnd_log.level_procedure,
	             g_pkg_name || '.' || l_api_name,
	           'SHRD0117: '||FND_MESSAGE.get);
	       --FND_FILE.Put_Line(FND_FILE.Log,'SHRD0117: '||FND_MESSAGE.get);

            END IF;
         END IF; -- Ends Company if specific value..
        END IF; -- Ends If matching by


     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
                                                                          THEN

         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        g_pkg_name || '.' || l_api_name,
                        GCS_UTILITY_PKG.g_module_success || l_api_name ||
                        to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
     END IF;

     COMMIT;

  EXCEPTION


    WHEN NO_MATCH_RULE_CODE THEN

      x_errbuf := SQLERRM;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
	                   g_pkg_name || '.' || l_api_name
                           ||' NO_MATCH_RULE_CODE',
                           SUBSTR(SQLERRM, 1, 255));


       END IF;

       x_retcode := 2;


    WHEN Hierarchy_Check_Failed  THEN

      x_errbuf := SQLERRM;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE)
                                                                          THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
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

       x_retcode := 2;




   WHEN OTHERS THEN

     x_errbuf := SQLERRM;

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
        x_retcode := 2;

        RAISE;


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

 END INSERT_INTERCO_TRX;

   END GCS_INTERCO_DYNAMIC_PKG;

/
