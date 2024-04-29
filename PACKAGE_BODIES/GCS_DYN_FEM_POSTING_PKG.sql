--------------------------------------------------------
--  DDL for Package Body GCS_DYN_FEM_POSTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DYN_FEM_POSTING_PKG" AS

     -- Store the log level
     runtimeLogLevel     NUMBER := FND_LOG.g_current_runtime_level;
     statementLogLevel   CONSTANT NUMBER := FND_LOG.level_statement;
     procedureLogLevel   CONSTANT NUMBER := FND_LOG.level_procedure;
     exceptionLogLevel   CONSTANT NUMBER := FND_LOG.level_exception;
     errorLogLevel       CONSTANT NUMBER := FND_LOG.level_error;
     unexpectedLogLevel  CONSTANT NUMBER := FND_LOG.level_unexpected;

     g_src_sys_code NUMBER := GCS_UTILITY_PKG.g_gcs_source_system_code;
     g_dimension_attr_info    gcs_utility_pkg.t_hash_dimension_attr_info
                                    := gcs_utility_pkg.g_dimension_attr_info;

     no_proc_data_err                     EXCEPTION;



   PROCEDURE Populate_GT_Table(
                             p_category_code      VARCHAR2,
                             p_cons_entity_id     NUMBER,
                             p_child_entity_id    NUMBER,
                             p_run_name           VARCHAR2,
                             p_run_detail_id      NUMBER,
                             p_entry_id           NUMBER,
                             p_cal_period_year    NUMBER,
                             errbuf IN OUT NOCOPY  VARCHAR2,
                             retcode IN OUT NOCOPY VARCHAR2 ) IS

  l_recur_entry_flag VARCHAR2(1);
  l_entry_id_list DBMS_SQL.NUMBER_TABLE;
  l_entity_id_list DBMS_SQL.NUMBER_TABLE;
  l_currency_code_list DBMS_SQL.VARCHAR2_TABLE;

  BEGIN

   IF (procedureloglevel >= runtimeloglevel ) THEN
     FND_LOG.STRING(procedureloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.POPULATE_GT_TABLE.begin', to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
   END IF;

   IF (p_entry_id IS NOT NULL OR p_run_detail_id IS NOT NULL) THEN
     IF (p_entry_id IS NOT NULL) THEN
       SELECT entry_id, entity_id, currency_code
         BULK COLLECT INTO l_entry_id_list, l_entity_id_list, l_currency_code_list
         FROM GCS_ENTRY_HEADERS
        WHERE entry_id = p_entry_id;

     ELSE -- p_run_detail_id is not null
       SELECT ghd.entry_id, ghd.entity_id, ghd.currency_code
         BULK COLLECT INTO l_entry_id_list, l_entity_id_list, l_currency_code_list
         FROM GCS_CONS_ENG_RUN_DTLS GCR,
              GCS_ENTRY_HEADERS GHD
        WHERE GCR.run_detail_id = p_run_detail_id
          AND GHD.entry_id in ( GCR.entry_id, GCR.stat_entry_id);
     END IF;

     IF (SQL%ROWCOUNT = 0) THEN
        RAISE no_proc_data_err;
     END IF;

     FORALL i IN l_entry_id_list.FIRST..l_entry_id_list.LAST
     INSERT
      INTO GCS_FEM_POSTING_GT(
   	ENTRY_ID,
   	SEQUENCE_NUM,
        CURRENCY_CODE,
   	COMPANY_COST_CENTER_ORG_ID,
  	INTERCOMPANY_ID,
        ENTITY_ID,
        LINE_ITEM_ID,
   	XTD_BALANCE_E,
   	YTD_BALANCE_E,
   	PTD_DEBIT_BALANCE_E,
   	PTD_CREDIT_BALANCE_E,
   	YTD_DEBIT_BALANCE_E,
   	YTD_CREDIT_BALANCE_E
   	)
      SELECT
         l_entry_id_list(i),
         GCS_FEM_BAL_S.nextval,
         l_currency_code_list(i),
    	 GLE.COMPANY_COST_CENTER_ORG_ID,
         GLE.INTERCOMPANY_ID,
         l_entity_id_list(i),
         GLE.LINE_ITEM_ID,
  	nvl(GLE.XTD_BALANCE_E, GLE.YTD_BALANCE_E),
   	GLE.YTD_BALANCE_E,
   	nvl(GLE.PTD_DEBIT_BALANCE_E, GLE.YTD_DEBIT_BALANCE_E),
   	nvl(GLE.PTD_CREDIT_BALANCE_E, GLE.YTD_CREDIT_BALANCE_E),
   	GLE.YTD_DEBIT_BALANCE_E,
   	GLE.YTD_CREDIT_BALANCE_E
    FROM GCS_ENTRY_LINES GLE
    WHERE GLE.entry_id = l_entry_id_list(i);

    -- The following is happening when consolidating adjustments on operating entities
    ELSIF (p_child_entity_id is not null) THEN

      BEGIN
        SELECT 'Y'
          INTO l_recur_entry_flag
          FROM dual
         WHERE EXISTS
               (SELECT 1
                  FROM GCS_CONS_ENG_RUN_DTLS GCERD,
	               GCS_ENTRY_HEADERS GHD
                 WHERE GCERD.run_name = p_run_name
                   AND GCERD.consolidation_entity_id = p_cons_entity_id
                   AND GCERD.child_entity_id = p_child_entity_id
                   AND GCERD.category_code = p_category_code
                   AND GHD.entry_id in (GCERD.entry_id, GCERD.stat_entry_id)
                   AND (GHD.end_cal_period_id IS NULL OR ghd.start_cal_period_id <> ghd.end_cal_period_id));

        -- bug fix 5080422: swap position of line_item_id and intercompany_id
        INSERT
          INTO GCS_FEM_POSTING_GT(
               ENTRY_ID,
   	       SEQUENCE_NUM,
   	       CURRENCY_CODE,
   	       COMPANY_COST_CENTER_ORG_ID,
  	       INTERCOMPANY_ID,
               ENTITY_ID,
               LINE_ITEM_ID,
   	       XTD_BALANCE_E,
   	       YTD_BALANCE_E,
   	       PTD_DEBIT_BALANCE_E,
   	       PTD_CREDIT_BALANCE_E,
   	       YTD_DEBIT_BALANCE_E,
   	       YTD_CREDIT_BALANCE_E
   	       )
        SELECT
	       GFB.ENTRY_ID,
               GCS_FEM_BAL_S.nextval,
	       GFB.CURRENCY_CODE,
	       GFB.COMPANY_COST_CENTER_ORG_ID,
	       GFB.INTERCOMPANY_ID,
	       GFB.ENTITY_ID,
	       GFB.LINE_ITEM_ID,

  	        GFB.XTD_BALANCE_E,
  	        GFB.YTD_BALANCE_E,
  	        GFB.PTD_DEBIT_BALANCE_E,
  	        GFB.PTD_CREDIT_BALANCE_E,
  	        GFB.YTD_DEBIT_BALANCE_E,
  	        GFB.YTD_CREDIT_BALANCE_E
           FROM (
                SELECT max(GHD.entry_id) entry_id,
                       GHD.currency_code,
   	               GLE.COMPANY_COST_CENTER_ORG_ID,
                       GLE.INTERCOMPANY_ID,
                       GLE.LINE_ITEM_ID,
                      max(GHD.ENTITY_ID) ENTITY_ID,
	               sum(nvl(GLE.XTD_BALANCE_E, GLE.YTD_BALANCE_E)) XTD_BALANCE_E,
	               sum(GLE.YTD_BALANCE_E) YTD_BALANCE_E,
	               sum(nvl(GLE.PTD_DEBIT_BALANCE_E, GLE.YTD_DEBIT_BALANCE_E)) PTD_DEBIT_BALANCE_E,
	               sum(nvl(GLE.PTD_CREDIT_BALANCE_E, GLE.YTD_CREDIT_BALANCE_E)) PTD_CREDIT_BALANCE_E,
	               sum(GLE.YTD_DEBIT_BALANCE_E) YTD_DEBIT_BALANCE_E,
	               sum(GLE.YTD_CREDIT_BALANCE_E) YTD_CREDIT_BALANCE_E
                  FROM GCS_CONS_ENG_RUN_DTLS GCERD,
	               GCS_ENTRY_HEADERS GHD,
	               GCS_ENTRY_LINES GLE
                 WHERE GCERD.run_name = p_run_name
                   AND GCERD.consolidation_entity_id = p_cons_entity_id
                   AND GCERD.child_entity_id = p_child_entity_id
                   AND GCERD.category_code = p_category_code
                   AND GHD.entry_id in (GCERD.entry_id, GCERD.stat_entry_id)
                   AND GLE.entry_id = GHD.entry_id
                   AND ((GHD.start_cal_period_id = GHD.end_cal_period_id)
                       OR ((GHD.start_cal_period_id <> GHD.end_cal_period_id OR GHD.end_cal_period_id is NULL)
                           AND (GHD.year_to_apply_re IS NULL OR (p_cal_period_year >= GHD.year_to_apply_re AND GLE.line_type_code <> 'PROFIT_LOSS')
                           OR (p_cal_period_year < GHD.year_to_apply_re AND GLE.line_type_code <> 'CALCULATED'))))
              GROUP BY GHD.currency_code, GLE.company_cost_center_org_id, GLE.line_item_id,
GLE.intercompany_id ) GFB;

      EXCEPTION
       WHEN NO_DATA_FOUND THEN

        -- bug fix 5080422: swap position of line_item_id and intercompany_id
        INSERT
          INTO GCS_FEM_POSTING_GT(
               ENTRY_ID,
   	       SEQUENCE_NUM,
   	       CURRENCY_CODE,
   	       COMPANY_COST_CENTER_ORG_ID,
  	       INTERCOMPANY_ID,
               ENTITY_ID,
               LINE_ITEM_ID,
   	       XTD_BALANCE_E,
   	       YTD_BALANCE_E,
   	       PTD_DEBIT_BALANCE_E,
   	       PTD_CREDIT_BALANCE_E,
   	       YTD_DEBIT_BALANCE_E,
   	       YTD_CREDIT_BALANCE_E
   	       )
        SELECT
	       GFB.ENTRY_ID,
               GCS_FEM_BAL_S.nextval,
	       GFB.CURRENCY_CODE,
	       GFB.COMPANY_COST_CENTER_ORG_ID,
	       GFB.INTERCOMPANY_ID,
	       GFB.ENTITY_ID,
	       GFB.LINE_ITEM_ID,

  	        GFB.XTD_BALANCE_E,
  	        GFB.YTD_BALANCE_E,
  	        GFB.PTD_DEBIT_BALANCE_E,
  	        GFB.PTD_CREDIT_BALANCE_E,
  	        GFB.YTD_DEBIT_BALANCE_E,
  	        GFB.YTD_CREDIT_BALANCE_E
           FROM (
                SELECT max(GHD.entry_id) entry_id,
                       GHD.currency_code,
   	               GLE.COMPANY_COST_CENTER_ORG_ID,
                       GLE.INTERCOMPANY_ID,
                       GLE.LINE_ITEM_ID,
                      max(GHD.ENTITY_ID) ENTITY_ID,
	               sum(nvl(GLE.XTD_BALANCE_E, GLE.YTD_BALANCE_E)) XTD_BALANCE_E,
	               sum(GLE.YTD_BALANCE_E) YTD_BALANCE_E,
	               sum(nvl(GLE.PTD_DEBIT_BALANCE_E, GLE.YTD_DEBIT_BALANCE_E)) PTD_DEBIT_BALANCE_E,
	               sum(nvl(GLE.PTD_CREDIT_BALANCE_E, GLE.YTD_CREDIT_BALANCE_E)) PTD_CREDIT_BALANCE_E,
	               sum(GLE.YTD_DEBIT_BALANCE_E) YTD_DEBIT_BALANCE_E,
	               sum(GLE.YTD_CREDIT_BALANCE_E) YTD_CREDIT_BALANCE_E
                  FROM GCS_CONS_ENG_RUN_DTLS GCERD,
	               GCS_ENTRY_HEADERS GHD,
	               GCS_ENTRY_LINES GLE
                 WHERE GCERD.run_name = p_run_name
                   AND GCERD.consolidation_entity_id = p_cons_entity_id
                   AND GCERD.child_entity_id = p_child_entity_id
                   AND GCERD.category_code = p_category_code
                   AND GHD.entry_id in (GCERD.entry_id, GCERD.stat_entry_id)
                   AND GLE.entry_id = GHD.entry_id
              GROUP BY GHD.currency_code, GLE.company_cost_center_org_id, GLE.line_item_id,
GLE.intercompany_id ) GFB;
       END;

    -- The following is happening when consolidating adjustments on consolidation entities
    ELSE

      BEGIN
        SELECT 'Y'
          INTO l_recur_entry_flag
          FROM dual
         WHERE EXISTS
               (SELECT 1
                  FROM GCS_CONS_ENG_RUN_DTLS GCERD,
	               GCS_ENTRY_HEADERS GHD
                 WHERE GCERD.run_name = p_run_name
                   AND GCERD.consolidation_entity_id = p_cons_entity_id
                   AND GCERD.category_code = p_category_code
                   AND GHD.entry_id in (GCERD.entry_id, GCERD.stat_entry_id)
                   AND (GHD.end_cal_period_id IS NULL OR ghd.start_cal_period_id <> ghd.end_cal_period_id));

        -- bug fix 5080422: swap position of line_item_id and intercompany_id
        INSERT
          INTO GCS_FEM_POSTING_GT(
               ENTRY_ID,
   	       SEQUENCE_NUM,
   	       CURRENCY_CODE,
   	       COMPANY_COST_CENTER_ORG_ID,
  	       INTERCOMPANY_ID,
               ENTITY_ID,
               LINE_ITEM_ID,
   	       XTD_BALANCE_E,
   	       YTD_BALANCE_E,
   	       PTD_DEBIT_BALANCE_E,
   	       PTD_CREDIT_BALANCE_E,
   	       YTD_DEBIT_BALANCE_E,
   	       YTD_CREDIT_BALANCE_E
   	       )
        SELECT
	       GFB.ENTRY_ID,
               GCS_FEM_BAL_S.nextval,
	       GFB.CURRENCY_CODE,
	       GFB.COMPANY_COST_CENTER_ORG_ID,
	       GFB.INTERCOMPANY_ID,
	       GFB.ENTITY_ID,
	       GFB.LINE_ITEM_ID,

  	        GFB.XTD_BALANCE_E,
  	        GFB.YTD_BALANCE_E,
  	        GFB.PTD_DEBIT_BALANCE_E,
  	        GFB.PTD_CREDIT_BALANCE_E,
  	        GFB.YTD_DEBIT_BALANCE_E,
  	        GFB.YTD_CREDIT_BALANCE_E
           FROM (
                SELECT max(GHD.entry_id) entry_id,
                       GHD.currency_code,
   	               GLE.COMPANY_COST_CENTER_ORG_ID,
                       GLE.INTERCOMPANY_ID,
                       GLE.LINE_ITEM_ID,
                      max(GHD.ENTITY_ID) ENTITY_ID,
	               sum(nvl(GLE.XTD_BALANCE_E, GLE.YTD_BALANCE_E)) XTD_BALANCE_E,
	               sum(GLE.YTD_BALANCE_E) YTD_BALANCE_E,
	               sum(nvl(GLE.PTD_DEBIT_BALANCE_E, GLE.YTD_DEBIT_BALANCE_E)) PTD_DEBIT_BALANCE_E,
	               sum(nvl(GLE.PTD_CREDIT_BALANCE_E, GLE.YTD_CREDIT_BALANCE_E)) PTD_CREDIT_BALANCE_E,
	               sum(GLE.YTD_DEBIT_BALANCE_E) YTD_DEBIT_BALANCE_E,
	               sum(GLE.YTD_CREDIT_BALANCE_E) YTD_CREDIT_BALANCE_E
                  FROM GCS_CONS_ENG_RUN_DTLS GCERD,
	               GCS_ENTRY_HEADERS GHD,
	               GCS_ENTRY_LINES GLE
                 WHERE GCERD.run_name = p_run_name
                   AND GCERD.consolidation_entity_id = p_cons_entity_id
                   AND GCERD.category_code = p_category_code
                   AND GHD.entry_id in (GCERD.entry_id, GCERD.stat_entry_id)
                   AND GLE.entry_id = GHD.entry_id
                   AND ((GHD.start_cal_period_id = GHD.end_cal_period_id)
                       OR ((GHD.start_cal_period_id <> GHD.end_cal_period_id OR GHD.end_cal_period_id is NULL)
                           AND (GHD.year_to_apply_re IS NULL OR (p_cal_period_year >= GHD.year_to_apply_re AND GLE.line_type_code <> 'PROFIT_LOSS')
                           OR (p_cal_period_year < GHD.year_to_apply_re AND GLE.line_type_code <> 'CALCULATED'))))
              GROUP BY GHD.currency_code, GLE.company_cost_center_org_id, GLE.line_item_id,
GLE.intercompany_id ) GFB;

      EXCEPTION
       WHEN NO_DATA_FOUND THEN

        -- bug fix 5080422: swap position of line_item_id and intercompany_id
        INSERT
          INTO GCS_FEM_POSTING_GT(
               ENTRY_ID,
   	       SEQUENCE_NUM,
   	       CURRENCY_CODE,
   	       COMPANY_COST_CENTER_ORG_ID,
  	       INTERCOMPANY_ID,
               ENTITY_ID,
               LINE_ITEM_ID,
   	       XTD_BALANCE_E,
   	       YTD_BALANCE_E,
   	       PTD_DEBIT_BALANCE_E,
   	       PTD_CREDIT_BALANCE_E,
   	       YTD_DEBIT_BALANCE_E,
   	       YTD_CREDIT_BALANCE_E
   	       )
        SELECT
	       GFB.ENTRY_ID,
               GCS_FEM_BAL_S.nextval,
	       GFB.CURRENCY_CODE,
	       GFB.COMPANY_COST_CENTER_ORG_ID,
	       GFB.INTERCOMPANY_ID,
	       GFB.ENTITY_ID,
	       GFB.LINE_ITEM_ID,

  	        GFB.XTD_BALANCE_E,
  	        GFB.YTD_BALANCE_E,
  	        GFB.PTD_DEBIT_BALANCE_E,
  	        GFB.PTD_CREDIT_BALANCE_E,
  	        GFB.YTD_DEBIT_BALANCE_E,
  	        GFB.YTD_CREDIT_BALANCE_E
           FROM (
                SELECT max(GHD.entry_id) entry_id,
                       GHD.currency_code,
   	               GLE.COMPANY_COST_CENTER_ORG_ID,
                       GLE.INTERCOMPANY_ID,
                       GLE.LINE_ITEM_ID,
                      max(GHD.ENTITY_ID) ENTITY_ID,
	               sum(nvl(GLE.XTD_BALANCE_E, GLE.YTD_BALANCE_E)) XTD_BALANCE_E,
	               sum(GLE.YTD_BALANCE_E) YTD_BALANCE_E,
	               sum(nvl(GLE.PTD_DEBIT_BALANCE_E, GLE.YTD_DEBIT_BALANCE_E)) PTD_DEBIT_BALANCE_E,
	               sum(nvl(GLE.PTD_CREDIT_BALANCE_E, GLE.YTD_CREDIT_BALANCE_E)) PTD_CREDIT_BALANCE_E,
	               sum(GLE.YTD_DEBIT_BALANCE_E) YTD_DEBIT_BALANCE_E,
	               sum(GLE.YTD_CREDIT_BALANCE_E) YTD_CREDIT_BALANCE_E
                  FROM GCS_CONS_ENG_RUN_DTLS GCERD,
	               GCS_ENTRY_HEADERS GHD,
	               GCS_ENTRY_LINES GLE
                 WHERE GCERD.run_name = p_run_name
                   AND GCERD.consolidation_entity_id = p_cons_entity_id
                   AND GCERD.category_code = p_category_code
                   AND GHD.entry_id in (GCERD.entry_id, GCERD.stat_entry_id)
                   AND GLE.entry_id = GHD.entry_id
              GROUP BY GHD.currency_code, GLE.company_cost_center_org_id, GLE.line_item_id,
GLE.intercompany_id ) GFB;

    END;
  END IF;

   IF (procedureloglevel >= runtimeloglevel ) THEN
     FND_LOG.STRING(procedureloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.POPULATE_GT_TABLE.end', to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
   END IF;

END  Populate_GT_Table;


   PROCEDURE Process_Insert( p_hier_dataset_code   NUMBER,
                             p_object_id           NUMBER,
                             p_category_code       VARCHAR2,
                             p_cons_entity_id      NUMBER,
                             p_child_entity_id     NUMBER,
                             p_cal_period_id       NUMBER,
                             p_cal_period_year     NUMBER,
                             p_ledger_id           NUMBER,
                             p_run_name            VARCHAR2,
                             p_run_detail_id       NUMBER,
                             p_entry_id            NUMBER,
                             p_undo                VARCHAR2,
                             p_xlate               VARCHAR2,
                             --Bugfix 5646770: Added parameter for topmost entity flag
                             p_topmost_entity_flag VARCHAR2,
                             errbuf IN OUT NOCOPY  VARCHAR2,
                             retcode IN OUT NOCOPY VARCHAR2
                          ) IS

  l_req_id   NUMBER := FND_GLOBAL.conc_request_id;
  l_login_id NUMBER := FND_GLOBAL.login_id;
  l_user_id  NUMBER := FND_GLOBAL.user_id;
  l_entries_id DBMS_SQL.number_table;
  l_currencies_code DBMS_SQL.varchar2_table;
  l_entities_id DBMS_SQL.number_table;

  BEGIN

    IF (procedureloglevel >= runtimeloglevel ) THEN
      FND_LOG.STRING(procedureloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.PROCESS_INSERT.begin', to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

    Populate_Gt_Table(p_category_code => p_category_code,
                      p_cons_entity_id => p_cons_entity_id,
                      p_child_entity_id => p_child_entity_id,
                      p_run_name => p_run_name,
                      p_run_detail_id => p_run_detail_id,
                      p_entry_id => p_entry_id,
                      p_cal_period_year => p_cal_period_year,
                      errbuf => errbuf,
                      retcode => retcode);

     INSERT INTO FEM_BALANCES(
        DATASET_CODE,
        CAL_PERIOD_ID,
        CREATION_ROW_SEQUENCE,
        SOURCE_SYSTEM_CODE,
        LEDGER_ID,
        COMPANY_COST_CENTER_ORG_ID,
        CURRENCY_CODE,
        CURRENCY_TYPE_CODE,
        INTERCOMPANY_ID,
        ENTITY_ID,
        LINE_ITEM_ID,
     	CREATED_BY_REQUEST_ID,
        CREATED_BY_OBJECT_ID,
        LAST_UPDATED_BY_REQUEST_ID,
        LAST_UPDATED_BY_OBJECT_ID,
        XTD_BALANCE_E,
        YTD_BALANCE_E,
        PTD_DEBIT_BALANCE_E,
        PTD_CREDIT_BALANCE_E,
        YTD_DEBIT_BALANCE_E,
        YTD_CREDIT_BALANCE_E,
        --Bugfix 5646770: Added _F Columns for Top Most Entity
        XTD_BALANCE_F,
        YTD_BALANCE_F
   	)
      SELECT
         p_hier_dataset_code,
         p_cal_period_id,
         sequence_num,
         g_src_sys_code,
         p_ledger_id,
         company_cost_center_org_id,
         currency_code,
         'TOTAL',
         intercompany_id,
         entity_id,
         line_item_id,
       l_req_id,
        p_object_id,
        l_req_id,
        p_object_id,
        XTD_BALANCE_E,
        YTD_BALANCE_E,
        PTD_DEBIT_BALANCE_E,
        PTD_CREDIT_BALANCE_E,
        YTD_DEBIT_BALANCE_E,
        YTD_CREDIT_BALANCE_E,
        --Bugfix 5646770: Added _F Columns for topmost entity
        DECODE(p_topmost_entity_flag, 'Y', XTD_BALANCE_E, NULL) XTD_BALANCE_F,
        DECODE(p_topmost_entity_flag, 'Y', YTD_BALANCE_E, NULL) YTD_BALANCE_F
      FROM GCS_FEM_POSTING_GT;

      IF (procedureloglevel >= runtimeloglevel ) THEN
      	FND_LOG.STRING(procedureloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.PROCESS_INSERT.end', to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
      END IF;

      EXCEPTION
       WHEN NO_DATA_FOUND THEN
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
      	  FND_LOG.STRING(unexpectedloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.PROCESS_INSERT', 'GCS_NO_DATA_FOUND');
         END IF;
         retcode := '0';
         errbuf := 'GCS_NO_DATA_FOUND';
         RAISE NO_DATA_FOUND;

       WHEN OTHERS THEN
         errbuf := substr( SQLERRM, 1, 2000);
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
      	  FND_LOG.STRING(unexpectedloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.PROCESS_INSERT', errbuf);
         END IF;
         retcode := '0';
         RAISE;

   END Process_Insert;
PROCEDURE Process_Merge(p_hier_dataset_code       NUMBER,
			p_mode               VARCHAR2,
			p_object_id          NUMBER,
                        p_category_code       VARCHAR2,
                        p_cons_entity_id     NUMBER,
                        p_child_entity_id    NUMBER,
			p_cal_period_id      NUMBER,
			p_cal_period_year    NUMBER,
			p_ledger_id          NUMBER,
			p_run_name           VARCHAR2,
                        p_run_detail_id      NUMBER,
			p_entry_id           NUMBER,
                        p_undo               VARCHAR2,
                        p_xlate              VARCHAR2,
			errbuf IN OUT NOCOPY  VARCHAR2,
			retcode IN OUT NOCOPY VARCHAR2 ) IS

   l_req_id   NUMBER := FND_GLOBAL.conc_request_id;
   l_login_id NUMBER := FND_GLOBAL.login_id;
   l_user_id  NUMBER := FND_GLOBAL.user_id;

  BEGIN

   IF (procedureloglevel >= runtimeloglevel ) THEN
     FND_LOG.STRING(procedureloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.PROCESS_MERGE.begin', to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
   END IF;

    Populate_Gt_Table(p_category_code => p_category_code,
                      p_cons_entity_id => p_cons_entity_id,
                      p_child_entity_id => p_child_entity_id,
                      p_run_name => p_run_name,
                      p_run_detail_id => p_run_detail_id,
                      p_entry_id => p_entry_id,
                      p_cal_period_year => p_cal_period_year,
                      errbuf => errbuf,
                      retcode => retcode);

   IF (p_mode = 'M') THEN
     MERGE INTO FEM_BALANCES FB
     USING(
     SELECT
	p_hier_dataset_code DATASET_CODE,
	p_cal_period_id CAL_PERIOD_ID,
	g_src_sys_code SOURCE_SYSTEM_CODE,
	p_ledger_id LEDGER_ID,
        GLE.SEQUENCE_NUM CREATION_ROW_SEQUENCE,
        l_req_id CREATED_BY_REQUEST_ID,
	p_object_id CREATED_BY_OBJECT_ID,
	l_req_id LAST_UPDATED_BY_REQUEST_ID,
	p_object_id LAST_UPDATED_BY_OBJECT_ID,
	GLE.COMPANY_COST_CENTER_ORG_ID COMPANY_COST_CENTER_ORG_ID,
	GLE.LINE_ITEM_ID LINE_ITEM_ID,
	GLE.INTERCOMPANY_ID INTERCOMPANY_ID,
	GLE.CURRENCY_CODE CURRENCY_CODE,
        GLE.ENTITY_ID ENTITY_ID,
	GLE.XTD_BALANCE_E,
	GLE.YTD_BALANCE_E YTD_BALANCE_E,
	GLE.PTD_DEBIT_BALANCE_E,
	GLE.PTD_CREDIT_BALANCE_E,
	GLE.YTD_DEBIT_BALANCE_E YTD_DEBIT_BALANCE_E,
	GLE.YTD_CREDIT_BALANCE_E YTD_CREDIT_BALANCE_E
    FROM GCS_FEM_POSTING_GT GLE) GFB
    ON (
	FB.CREATED_BY_OBJECT_ID = GFB.CREATED_BY_OBJECT_ID
	AND FB.CREATED_BY_REQUEST_ID = GFB.CREATED_BY_REQUEST_ID
	AND FB.CREATION_ROW_SEQUENCE = GFB.CREATION_ROW_SEQUENCE)
     WHEN MATCHED THEN UPDATE SET
	FB.xtd_balance_e = GFB.xtd_balance_e,
	FB.ptd_credit_balance_e = GFB.ptd_credit_balance_e,
	FB.ptd_debit_balance_e = GFB.ptd_debit_balance_e,
	FB.ytd_balance_e = GFB.ytd_balance_e,
	FB.ytd_credit_balance_e = GFB.ytd_credit_balance_e,
	FB.ytd_debit_balance_e = GFB.ytd_debit_balance_e
     WHEN NOT MATCHED THEN INSERT
	(
	FB.DATASET_CODE,
	FB.CAL_PERIOD_ID,
	FB.CREATION_ROW_SEQUENCE,
	FB.SOURCE_SYSTEM_CODE,
	FB.LEDGER_ID,
	FB.COMPANY_COST_CENTER_ORG_ID,
	FB.CURRENCY_CODE,
	FB.CURRENCY_TYPE_CODE,
	FB.LINE_ITEM_ID,
	FB.ENTITY_ID,
	FB.INTERCOMPANY_ID,
FB.CREATED_BY_REQUEST_ID,
	FB.CREATED_BY_OBJECT_ID,
	FB.LAST_UPDATED_BY_REQUEST_ID,
	FB.LAST_UPDATED_BY_OBJECT_ID,
	FB.XTD_BALANCE_E,
	FB.YTD_BALANCE_E,
	FB.PTD_DEBIT_BALANCE_E,
	FB.PTD_CREDIT_BALANCE_E,
	FB.YTD_DEBIT_BALANCE_E,
	FB.YTD_CREDIT_BALANCE_E
	)
    VALUES
	(
	GFB.DATASET_CODE,
	GFB.CAL_PERIOD_ID,
	GFB.CREATION_ROW_SEQUENCE,
	GFB.SOURCE_SYSTEM_CODE,
	GFB.LEDGER_ID,
	GFB.COMPANY_COST_CENTER_ORG_ID,
	GFB.CURRENCY_CODE,
	'TOTAL',
	GFB.LINE_ITEM_ID,
	GFB.ENTITY_ID,
	GFB.INTERCOMPANY_ID,
 GFB.CREATED_BY_REQUEST_ID,
  	GFB.CREATED_BY_OBJECT_ID,
  	GFB.LAST_UPDATED_BY_REQUEST_ID,
  	GFB.LAST_UPDATED_BY_OBJECT_ID,
  	GFB.XTD_BALANCE_E,
  	GFB.YTD_BALANCE_E,
  	GFB.PTD_DEBIT_BALANCE_E,
  	GFB.PTD_CREDIT_BALANCE_E,
  	GFB.YTD_DEBIT_BALANCE_E,
  	GFB.YTD_CREDIT_BALANCE_E);

    ELSE
     MERGE INTO FEM_BALANCES FB
     USING(
     SELECT
	p_hier_dataset_code DATASET_CODE,
	p_cal_period_id CAL_PERIOD_ID,
	g_src_sys_code SOURCE_SYSTEM_CODE,
	p_ledger_id LEDGER_ID,
        GLE.SEQUENCE_NUM CREATION_ROW_SEQUENCE,
        l_req_id CREATED_BY_REQUEST_ID,
	p_object_id CREATED_BY_OBJECT_ID,
	l_req_id LAST_UPDATED_BY_REQUEST_ID,
	p_object_id LAST_UPDATED_BY_OBJECT_ID,
	GLE.COMPANY_COST_CENTER_ORG_ID COMPANY_COST_CENTER_ORG_ID,
	GLE.LINE_ITEM_ID LINE_ITEM_ID,
	GLE.INTERCOMPANY_ID INTERCOMPANY_ID,
	GLE.CURRENCY_CODE CURRENCY_CODE,
        GLE.ENTITY_ID ENTITY_ID,
	GLE.XTD_BALANCE_E,
	GLE.YTD_BALANCE_E YTD_BALANCE_E,
	GLE.PTD_DEBIT_BALANCE_E,
	GLE.PTD_CREDIT_BALANCE_E,
	GLE.YTD_DEBIT_BALANCE_E YTD_DEBIT_BALANCE_E,
	GLE.YTD_CREDIT_BALANCE_E YTD_CREDIT_BALANCE_E
    FROM GCS_FEM_POSTING_GT GLE) GFB
    ON (
	FB.CREATED_BY_OBJECT_ID = GFB.CREATED_BY_OBJECT_ID
	AND FB.CREATED_BY_REQUEST_ID = GFB.CREATED_BY_REQUEST_ID
	AND FB.CREATION_ROW_SEQUENCE = GFB.CREATION_ROW_SEQUENCE)
     WHEN MATCHED THEN UPDATE SET
	FB.xtd_balance_e = FB.xtd_balance_e + GFB.xtd_balance_e,
	FB.ptd_credit_balance_e = FB.ptd_credit_balance_e + GFB.ptd_credit_balance_e,
	FB.ptd_debit_balance_e = FB.ptd_debit_balance_e + GFB.ptd_debit_balance_e,
	FB.ytd_balance_e = FB.ytd_balance_e +  GFB.ytd_balance_e,
	FB.ytd_credit_balance_e = FB.ytd_credit_balance_e + GFB.ytd_credit_balance_e,
	FB.ytd_debit_balance_e = FB.ytd_debit_balance_e + GFB.ytd_debit_balance_e
     WHEN NOT MATCHED THEN INSERT
	(
	FB.DATASET_CODE,
	FB.CAL_PERIOD_ID,
	FB.CREATION_ROW_SEQUENCE,
	FB.SOURCE_SYSTEM_CODE,
	FB.LEDGER_ID,
	FB.COMPANY_COST_CENTER_ORG_ID,
	FB.CURRENCY_CODE,
	FB.CURRENCY_TYPE_CODE,
	FB.LINE_ITEM_ID,
	FB.ENTITY_ID,
	FB.INTERCOMPANY_ID,
FB.CREATED_BY_REQUEST_ID,
	FB.CREATED_BY_OBJECT_ID,
	FB.LAST_UPDATED_BY_REQUEST_ID,
	FB.LAST_UPDATED_BY_OBJECT_ID,
	FB.XTD_BALANCE_E,
	FB.YTD_BALANCE_E,
	FB.PTD_DEBIT_BALANCE_E,
	FB.PTD_CREDIT_BALANCE_E,
	FB.YTD_DEBIT_BALANCE_E,
	FB.YTD_CREDIT_BALANCE_E
	)
    VALUES
	(
	GFB.DATASET_CODE,
	GFB.CAL_PERIOD_ID,
	GFB.CREATION_ROW_SEQUENCE,
	GFB.SOURCE_SYSTEM_CODE,
	GFB.LEDGER_ID,
	GFB.COMPANY_COST_CENTER_ORG_ID,
	GFB.CURRENCY_CODE,
	'TOTAL',
	GFB.LINE_ITEM_ID,
	GFB.ENTITY_ID,
	GFB.INTERCOMPANY_ID,
 GFB.CREATED_BY_REQUEST_ID,
  	GFB.CREATED_BY_OBJECT_ID,
  	GFB.LAST_UPDATED_BY_REQUEST_ID,
  	GFB.LAST_UPDATED_BY_OBJECT_ID,
  	GFB.XTD_BALANCE_E,
  	GFB.YTD_BALANCE_E,
  	GFB.PTD_DEBIT_BALANCE_E,
  	GFB.PTD_CREDIT_BALANCE_E,
  	GFB.YTD_DEBIT_BALANCE_E,
  	GFB.YTD_CREDIT_BALANCE_E);

     END IF; -- p_mode


       INSERT
         INTO GCS_FEM_CONTRIBUTIONS_H(
	   DATASET_CODE,
	   CAL_PERIOD_ID,
	   CREATED_BY_OBJECT_ID,
	   CREATION_ROW_SEQUENCE,
	   ENTRY_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN )
	SELECT
	   p_hier_dataset_code,
           p_cal_period_id,
           P_object_id,
           GFPG.sequence_num,
           GFPG.entry_id,
           sysdate,
           l_user_id,
           sysdate,
           l_user_id,
           l_login_id
        FROM GCS_FEM_POSTING_GT GFPG;

      IF (statementloglevel >= runtimeloglevel ) THEN
        FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST.PROCESS_MERGE.rowcount ', to_char(SQL%ROWCOUNT));
      END IF;

      -- If there are any rows processed, then register to FEM_DATA_LOCATIONS
      IF (SQL%ROWCOUNT <> 0) THEN
        FEM_DIMENSION_UTIL_PKG.Register_Data_Location
                 (P_REQUEST_ID  => l_req_id,
                  P_OBJECT_ID   => p_object_id,
                  P_TABLE_NAME  => 'FEM_BALANCES',
                  P_LEDGER_ID   => p_ledger_id,
                  P_CAL_PER_ID  => p_cal_period_id,
                  P_DATASET_CD  => p_hier_dataset_code,
                  P_SOURCE_CD   => g_src_sys_code,
                  P_LOAD_STATUS => 'COMPLETE');

      END IF;

      IF (procedureloglevel >= runtimeloglevel ) THEN
    	FND_LOG.STRING(procedureloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.PROCESS_MERGE.end', to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
      END IF;

      -- FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success || 'PROCESS_MERGE' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

      EXCEPTION
       WHEN NO_DATA_FOUND THEN
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST', 'GCS_NO_DATA_FOUND');
         END IF;
         --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
         --               'PROCESS_MERGE' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
         retcode := '0';
         errbuf := 'GCS_NO_DATA_FOUND';
         RAISE NO_DATA_FOUND;

       WHEN OTHERS THEN
         errbuf := substr( SQLERRM, 1, 2000);
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST', errbuf);
         END IF;
         --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
         --               'PROCESS_MERGE' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
         retcode := '0';
         RAISE;

  END Process_Merge;

   PROCEDURE Gcs_Fem_Post (
                errbuf       OUT NOCOPY VARCHAR2,
                retcode      OUT NOCOPY VARCHAR2,
                p_run_name              VARCHAR2,
                p_hierarchy_id          NUMBER,
                p_balance_type_code     VARCHAR2,
                p_category_code         VARCHAR2,
                p_cons_entity_id        NUMBER,
                p_child_entity_id       NUMBER,
                p_cal_period_id         NUMBER,
                p_undo                  VARCHAR2,
                p_xlate                 VARCHAR2,
                p_run_detail_id         NUMBER,
                p_mode			VARCHAR2,
                p_entry_id              NUMBER,
                p_hier_dataset_code     NUMBER) IS

	l_ledger_id           NUMBER;
	l_cal_period_info     GCS_UTILITY_PKG.r_cal_period_info;
	l_cal_period_year     NUMBER;
	l_object_id           NUMBER;
	module	              VARCHAR2(30) := 'GCS_FEM_POST';

        --Bugfix 5646770: Flag to state whether entity is topmost
        l_topmost_entity_flag VARCHAR2(1)  := 'N';

        --Bugfix 5704055: Delete Translated Balances at the Same time as Aggregated Balances
        l_entity_id             NUMBER;

   BEGIN

     runtimeLogLevel := FND_LOG.g_current_runtime_level;

     IF (procedureloglevel >= runtimeloglevel ) THEN
    	 FND_LOG.STRING(procedureloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST.begin' || GCS_UTILITY_PKG.g_module_enter, to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
     END IF;
     IF (statementloglevel >= runtimeloglevel ) THEN
         FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST', 'p_run_name = ' || p_run_name);
         FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST', 'p_hierarchy_id = ' || to_char(p_hierarchy_id));
         FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST', 'p_balance_type_code = ' || p_balance_type_code);
         FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST', 'p_mode = ' || p_mode);
         FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST', 'p_category_code = ' || p_category_code);
         FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST', 'p_entry_id = ' || to_char(p_entry_id));
     END IF;

     --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter || 'GCS_FEM_POST' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

     -- get ledger_id
     SELECT fem_ledger_id
     INTO l_ledger_id
     FROM GCS_HIERARCHIES_B
     WHERE hierarchy_id = p_hierarchy_id;

     -- Get current and previous period information.
     GCS_UTILITY_PKG.get_cal_period_details(p_cal_period_id, l_cal_period_info);

     l_cal_period_year := l_cal_period_info.cal_period_year;

     -- Get object_id
     SELECT associated_object_id
       INTO l_object_id
       FROM GCS_CATEGORIES_B
       WHERE category_code = p_category_code;

     -- Bugfix 5646770: Add check to determine if its the topmost entity
     IF (p_category_code = 'AGGREGATION') THEN
       SELECT DECODE(top_entity_id, p_cons_entity_id, 'Y', 'N')
       INTO   l_topmost_entity_flag
       FROM   gcs_hierarchies_b
       WHERE  hierarchy_id = p_hierarchy_id;
     END IF;

     BEGIN

       -- Delete data from FEM_BALANCES for UNDO mode
       -- Bugfix 5704055: This mode will only be called when removing Data Prep and Aggregation Rows
       IF p_undo = 'Y' AND p_entry_id IS NULL THEN
          SELECT child_entity_id
          INTO   l_entity_id
          FROM   gcs_cons_eng_run_dtls
          WHERE  run_detail_id = p_run_detail_id;

          DELETE /*+ INDEX(FEM_BALANCES FEM_BALANCES_N4) */ FROM FEM_BALANCES
          WHERE dataset_code           = p_hier_dataset_code
            AND cal_period_id          = p_cal_period_id
            AND ledger_id              = l_ledger_id
            AND created_by_object_id   = l_object_id
            AND source_system_code     = g_src_sys_code
            AND entity_id              = l_entity_id;

          IF (statementloglevel >= runtimeloglevel ) THEN
            FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.undo.balrowcount ', to_char(SQL%ROWCOUNT));
          END IF;
       --Bugfix 5704055: Removed Deletion from GCS_FEM_CONTRIBUTIONS_H
       --This mode will only be called for removal of Translation Rows
       ELSIF p_undo = 'Y' AND p_entry_id IS NOT NULL THEN
         SELECT entity_id
         INTO   l_entity_id
         FROM   gcs_entry_headers
         WHERE  entry_id = p_entry_id;

         DELETE /*+ INDEX(FEM_BALANCES FEM_BALANCES_N4) */ FROM FEM_BALANCES
         WHERE dataset_code           = p_hier_dataset_code
           AND cal_period_id          = p_cal_period_id
           AND ledger_id              = l_ledger_id
           AND created_by_object_id   = l_object_id
           AND source_system_code     = g_src_sys_code
           AND entity_id              = l_entity_id;

         IF (statementloglevel >= runtimeloglevel ) THEN
           FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.undo.balrowcount ', to_char(SQL%ROWCOUNT));
         END IF;
         --Bugfix 5704055: Removed Deletion from GCS_FEM_CONTRIBUTIONS_H
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         NULL;
     END;

     IF p_mode = 'I' THEN
       process_insert( p_hier_dataset_code   => p_hier_dataset_code,
                       p_object_id           => l_object_id,
                       p_category_code       => p_category_code,
                       p_cons_entity_id      => p_cons_entity_id,
                       p_child_entity_id     => p_child_entity_id,
                       p_cal_period_id       => p_cal_period_id,
                       p_cal_period_year     => l_cal_period_year,
                       p_ledger_id           => l_ledger_id,
                       p_run_name            => p_run_name,
                       p_run_detail_id       => p_run_detail_id,
                       p_entry_id            => p_entry_id,
                       p_undo                => p_undo,
                       p_xlate               => p_xlate,
                       --Bugfix 5646770: Added parameter for topmost entity flag
                       p_topmost_entity_flag => l_topmost_entity_flag,
                       errbuf                => errbuf,
                       retcode               => retcode);

        retcode := '1';
      ELSIF (p_mode = 'M' OR p_mode = 'D') THEN
         process_merge(
          p_hier_dataset_code,
          p_mode,
          l_object_id,
          p_category_code,
          p_cons_entity_id,
          p_child_entity_id,
          p_cal_period_id,
          l_cal_period_year,
          l_ledger_id,
          p_run_name,
          p_run_detail_id,
          p_entry_id,
          p_undo,
          p_xlate,
          errbuf,
          retcode);
        retcode := '1';
      END IF;


     IF (procedureloglevel >= runtimeloglevel ) THEN
     	FND_LOG.STRING(procedureloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST.end', to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
     END IF;
     --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
     --                   'gcs_fem_post' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
     	  FND_LOG.STRING(unexpectedloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST', 'GCS_NO_DATA_FOUND');
         END IF;
         --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
         --               'GCS_FEM_POST' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
         retcode := '0';
         errbuf := 'GCS_NO_DATA_FOUND';
        RAISE NO_DATA_FOUND;

       WHEN no_proc_data_err THEN
         retcode := gcs_utility_pkg.g_ret_sts_warn;
         errbuf := 'No processing data found.';
         IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR THEN
           fnd_log.STRING (fnd_log.level_error,
                           'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST',
                            gcs_utility_pkg.g_module_failure
                            || ' '
                            || errbuf
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
         END IF;

       WHEN OTHERS THEN
         errbuf := substr( SQLERRM, 1, 2000);
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
     	  FND_LOG.STRING(unexpectedloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_POST', errbuf);
         END IF;
         --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
         --               'GCS_FEM_POST' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
         retcode := '0';
         RAISE;

   END Gcs_Fem_Post;

  PROCEDURE Gcs_Fem_Delete(
			errbuf       OUT NOCOPY VARCHAR2,
			retcode      OUT NOCOPY VARCHAR2,
			p_hierarchy_id          NUMBER,
                        p_balance_type_code     VARCHAR2,
			p_cal_period_id         NUMBER,
                        p_entity_type           VARCHAR2,
                        p_entity_id             NUMBER,
                        p_hier_dataset_code     NUMBER) IS
	l_ledger_id   NUMBER;
	l_objects_id   DBMS_SQL.NUMBER_TABLE;
        l_oper_entity_id  NUMBER;
        l_elim_entity_id    NUMBER;
        g_oper_entity_attr  NUMBER(15)	:=	gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-OPERATING_ENTITY').attribute_id;
        g_elim_entity_attr  NUMBER(15)	:=	gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').attribute_id;
        g_oper_entity_ver   NUMBER(15)	:=	gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-OPERATING_ENTITY').version_id;
        g_elim_entity_ver   NUMBER(15)	:=	gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').version_id;
   BEGIN

     IF (procedureloglevel >= runtimeloglevel ) THEN
       FND_LOG.STRING(procedureloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_DELETE.begin' || GCS_UTILITY_PKG.g_module_enter, to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
     END IF;
     IF (statementloglevel >= runtimeloglevel ) THEN
       FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_DELETE', 'p_hierarchy_id = ' || to_char(p_hierarchy_id));
       FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_DELETE', 'p_cal_period_id = ' || to_char(p_cal_period_id));
       FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_DELETE', 'p_balance_type_code = ' || p_balance_type_code);
       FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_DELETE', 'p_entity_id = ' || to_char(p_entity_id));
       FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_DELETE', 'p_entity_type = ' || p_entity_type);
     END IF;

    -- Get the ledger_id
     SELECT ghb.fem_ledger_id
     INTO l_ledger_id
     FROM gcs_hierarchies_b ghb
     WHERE ghb.hierarchy_id = p_hierarchy_id;

     -- 'E' is for consolidation entities
     IF p_entity_type = 'E' THEN
       BEGIN
         -- Get the operating entity
         SELECT nvl(dim_attribute_numeric_member, -1)
           INTO l_oper_entity_id
           FROM fem_entities_attr
          WHERE entity_id	= p_entity_id
            AND version_id =  g_oper_entity_ver
	    AND attribute_id = g_oper_entity_attr;
       EXCEPTION
         WHEN no_data_found THEN
          l_oper_entity_id := -1;
       END;

       -- Get the elim entity
       SELECT dim_attribute_numeric_member
         INTO l_elim_entity_id
         FROM fem_entities_attr
        WHERE entity_id	= p_entity_id
          AND version_id =  g_elim_entity_ver
	  AND attribute_id = g_elim_entity_attr;

       BEGIN
       SELECT associated_object_id
         BULK COLLECT INTO  l_objects_id
         FROM gcs_categories_b
        WHERE category_type_code IN ('ELIMINATION_RULE', 'CONSOLIDATION_RULE')
          AND target_entity_code IN ('PARENT', 'ELIMINATION');
       EXCEPTION
         WHEN no_data_found THEN
           RETURN;
       END;

       -- Delete data from FEM_BALANCES for both the operating and elim entity
       --Bugfix 5704055: Added hints for the deletion
       FORALL i in l_objects_id.FIRST..l_objects_id.LAST
       DELETE /*+ INDEX(FEM_BALANCES FEM_BALANCES_N4) */ FROM FEM_BALANCES
        WHERE dataset_code = p_hier_dataset_code
        AND cal_period_id = p_cal_period_id
        AND source_system_code = g_src_sys_code
        AND ledger_id = l_ledger_id
        AND entity_id IN (l_oper_entity_id, l_elim_entity_id)
        AND created_by_object_id = l_objects_id(i);

     ELSE
       BEGIN
       SELECT associated_object_id
         BULK COLLECT INTO  l_objects_id
         FROM gcs_categories_b
        WHERE category_type_code IN ('ELIMINATION_RULE', 'CONSOLIDATION_RULE')
          AND target_entity_code = 'CHILD';
       EXCEPTION
         WHEN no_data_found THEN
           RETURN;
       END;

       -- Delete data from FEM_BALANCES for the operating entity
       --Bugfix 5704055: Added hints for the deletion
       FORALL i in l_objects_id.FIRST..l_objects_id.LAST
       DELETE /*+ INDEX(FEM_BALANCES FEM_BALANCES_N4) */ FROM FEM_BALANCES
        WHERE dataset_code = p_hier_dataset_code
        AND cal_period_id = p_cal_period_id
        AND source_system_code = g_src_sys_code
        AND ledger_id = l_ledger_id
        AND entity_id = p_entity_id
        AND created_by_object_id = l_objects_id(i);

     END IF;

      IF (statementloglevel >= runtimeloglevel ) THEN
        FND_LOG.STRING(statementloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_DELETE.rowcount ', to_char(SQL%ROWCOUNT));
      END IF;

 EXCEPTION
        WHEN NO_DATA_FOUND THEN
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
     	  FND_LOG.STRING(unexpectedloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_DELETE', 'GCS_NO_DATA_FOUND');
         END IF;
         --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
         --               'GCS_FEM_DELETE' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
         retcode := '0';
         errbuf := 'GCS_NO_DATA_FOUND';
        RAISE NO_DATA_FOUND;

       WHEN OTHERS THEN
         errbuf := substr( SQLERRM, 1, 2000);
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
     	  FND_LOG.STRING(unexpectedloglevel, 'gcs.plsql.GCS_FEM_POSTING_PKG.GCS_FEM_DELETE', errbuf);
         END IF;
         --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
         --               'GCS_FEM_DELETE' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
         retcode := '0';
         RAISE;

   END Gcs_Fem_Delete;

END GCS_DYN_FEM_POSTING_PKG;


/
