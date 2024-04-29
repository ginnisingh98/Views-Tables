--------------------------------------------------------
--  DDL for Package Body GCS_AGGREGATION_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_AGGREGATION_DYNAMIC_PKG" AS
/* $Header: gcsaggbb.pls 120.3 2006/03/06 23:05:29 yingliu noship $ */

  --
  -- PRIVATE GLOBAL VARIABLES
  --
  g_api    VARCHAR2(40) := 'gcs.plsql.GCS_AGGREGATION_DYNAMIC_PKG';

  TYPE t_entity_org_info IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_entity_org_info      T_ENTITY_ORG_INFO;

  --
  -- PUBLIC FUNCTIONS
  --

  FUNCTION retrieve_org_id(p_entity_id NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN g_entity_org_info(p_entity_id);
  END retrieve_org_id;

  --
  -- Procedure
  --   insert_full_entry_lines
  -- Notes
  --   The QRY select table has the following structure:
  --    <entity id> <CTA template dimensions> <default org id>
  --    Entity id                Child entities of the consolidation entity
  --                             that has any CTAs from the hierarchy under it
  --    Default org id           Default org id for the entity id
  --    CTA template dimensions  All CTAs from the hierarchy under the entity
  --
  PROCEDURE insert_full_entry_lines(
    p_entry_id           NUMBER,
    p_stat_entry_id      NUMBER,
    p_cons_entity_id     NUMBER,
    p_hierarchy_id       NUMBER,
    p_relationship_id    NUMBER,
    p_cal_period_id      NUMBER,
    p_period_end_date    DATE,
    p_currency_code      VARCHAR2,
    p_balance_type_code  VARCHAR2,
    p_dataset_code       NUMBER)
  IS
    fn_name               VARCHAR2(30) := 'INSERT_FULL_ENTRY_LINES';

    l_bal_by_org_flag     VARCHAR2(1);
    l_default_org_id      NUMBER;
    l_intercompany_id     NUMBER;

    l_re_template         GCS_TEMPLATES_PKG.TemplateRecord;
    l_sus_template        GCS_TEMPLATES_PKG.TemplateRecord;

    CURSOR get_child_info IS
      SELECT child_entity_id,
             gcs_utility_pkg.get_org_id(child_entity_id, hierarchy_id) org_id
      FROM  gcs_cons_relationships
      WHERE hierarchy_id = p_hierarchy_id
      AND   parent_entity_id = p_cons_entity_id
      AND   actual_ownership_flag = 'Y';

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- Get information of the hierarchy
    SELECT balance_by_org_flag
    INTO   l_bal_by_org_flag
    FROM   gcs_hierarchies_b
    WHERE  hierarchy_id = p_hierarchy_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.' || fn_name,
                     'l_bal_by_org_flag = ' || l_bal_by_org_flag || ' ' ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;

    -- Balancing by org or by entity
    IF (l_bal_by_org_flag = 'Y') THEN  -- Balancing by org

      -- Create entry lines
      -- bug fix 5066467: removed ordered hint
      INSERT /*+ APPEND */ INTO GCS_ENTRY_LINES
        (entry_id, line_type_code,
         company_cost_center_org_id, line_item_id, intercompany_id,
         xtd_balance_e, ytd_balance_e,
         ptd_debit_balance_e, ptd_credit_balance_e,
         ytd_debit_balance_e, ytd_credit_balance_e,
         creation_date, created_by,
         last_update_date, last_updated_by, last_update_login)
      SELECT
        decode(currency_code, 'STAT', p_stat_entry_id, p_entry_id), null,
        company_cost_center_org_id, line_item_id, intercompany_id,
        sum(xtd_balance_e), sum(ytd_balance_e),
        sum(ptd_debit_balance_e), sum(ptd_credit_balance_e),
        sum(ytd_debit_balance_e), sum(ytd_credit_balance_e),
        sysdate, GCS_AGGREGATION_PKG.g_fnd_user_id,
        sysdate, GCS_AGGREGATION_PKG.g_fnd_user_id,
        GCS_AGGREGATION_PKG.g_fnd_login_id
      FROM
        GCS_HIERARCHIES_B      ghb,
        FEM_BALANCES           fb,
        GCS_CONS_RELATIONSHIPS gcr,
        GCS_TREATMENTS_B       gt
      WHERE
          ghb.hierarchy_id = p_hierarchy_id
      AND gcr.hierarchy_id = ghb.hierarchy_id
      AND gcr.parent_entity_id = p_cons_entity_id
      AND gcr.actual_ownership_flag = 'Y'
      AND p_period_end_date BETWEEN gcr.start_date
                                AND nvl(gcr.end_date, p_period_end_date)
      AND gt.treatment_id (+) = gcr.treatment_id
      AND nvl(gt.consolidation_type_code, 'FULL') <> 'NONE'
      AND fb.dataset_code = p_dataset_code
      AND fb.ledger_id = ghb.fem_ledger_id
      AND fb.cal_period_id = p_cal_period_id
      AND fb.source_system_code = GCS_UTILITY_PKG.g_gcs_source_system_code
      AND fb.currency_code IN (p_currency_code, 'STAT')
      AND fb.entity_id = gcr.child_entity_id
      GROUP BY
        fb.currency_code,
        fb.company_cost_center_org_id,
        fb.intercompany_id,
        fb.line_item_id;

    ELSE  -- Balancing by Entity: need special handling of RE/Suspense/CTA

      -- Values used for the special processing:
      -- * default org id for the consolidation entity
      l_default_org_id := GCS_UTILITY_PKG.get_org_id(p_cons_entity_id,
                                                     p_hierarchy_id);

      -- * For determining intercompany type
      SELECT specific_intercompany_id
      INTO   l_intercompany_id
      FROM   GCS_CATEGORIES_B
      WHERE  category_code = 'AGGREGATION';

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.' || fn_name,
                       'l_intercompany_id = ' || l_intercompany_id || ' ' ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;

      -- * Retained earnings account template
      GCS_TEMPLATES_PKG.get_dimension_template(p_hierarchy_id, 'RE',
                                               p_balance_type_code,
                                               l_re_template);

      -- * Suspense account template
      GCS_TEMPLATES_PKG.get_dimension_template(p_hierarchy_id, 'SUSPENSE',
                                               p_balance_type_code,
                                               l_sus_template);

      -- For CTA processing: find default org id of all direct child entities
      FOR rec IN get_child_info LOOP
        g_entity_org_info(rec.child_entity_id) := rec.org_id;
      END LOOP;


      -- bug fix 5066467: rewrite the code for hanlding RE/SUSPENSE/CTA
      -- Now we first select the rows from fb to gcs_entry_lines_gt table, RE/SUSPENSE will be handled in this step
      -- Then we update gcs_entry_lines_gt for CTA lines
      -- Lastly, we move everything from gcs_entry_lines_gt to gcs_entry_lines
      INSERT INTO gcs_entry_lines_gt
        (entry_id, line_item_id, company_cost_center_org_id, intercompany_id,
         xtd_balance_e, ytd_balance_e,
         ptd_debit_balance_e, ptd_credit_balance_e,
         ytd_debit_balance_e, ytd_credit_balance_e)
      SELECT
        decode(currency_code, 'STAT', p_stat_entry_id, p_entry_id),
        fb.line_item_id,
        -- company_cost_center_org_id
        decode('Y',
         -- matching against Retained Earnings Account template
         l_default_org_id,
         -- matching against Suspense Account template
         l_default_org_id,
        company_cost_center_org_id),
        -- intercompany_id
        decode(intercompany_id, company_cost_center_org_id,
        decode(l_intercompany_id, NULL,
        decode('Y',
         -- matching against Retained Earnings Account template
         l_default_org_id,
         -- matching against Suspense Account template
         l_default_org_id,
        company_cost_center_org_id),
        intercompany_id), intercompany_id),
        sum(xtd_balance_e), sum(ytd_balance_e),
        sum(ptd_debit_balance_e), sum(ptd_credit_balance_e),
        sum(ytd_debit_balance_e), sum(ytd_credit_balance_e)
      FROM
        GCS_HIERARCHIES_B      ghb,
        FEM_BALANCES           fb,
        GCS_CONS_RELATIONSHIPS gcr,
        GCS_TREATMENTS_B       gt
      WHERE ghb.hierarchy_id = p_hierarchy_id
        AND gcr.hierarchy_id = p_hierarchy_id
        AND gcr.parent_entity_id = p_cons_entity_id
        AND gcr.actual_ownership_flag = 'Y'
        AND p_period_end_date BETWEEN gcr.start_date AND
                              NVL (gcr.end_date, p_period_end_date)
        AND gt.treatment_id(+) = gcr.treatment_id
        AND NVL(gt.consolidation_type_code, 'FULL') <> 'NONE'
        AND fb.dataset_code = p_dataset_code
        AND fb.ledger_id = ghb.fem_ledger_id
        AND fb.cal_period_id = p_cal_period_id
        AND fb.source_system_code = gcs_utility_pkg.g_gcs_source_system_code
        AND fb.currency_code IN (p_currency_code, 'STAT')
        AND fb.entity_id = gcr.child_entity_id
      GROUP BY
        fb.currency_code,
        -- company_cost_center_org_id
        decode('Y',
         -- matching against Retained Earnings Account template
         l_default_org_id,
         -- matching against Suspense Account template
         l_default_org_id,
        company_cost_center_org_id),
        -- intercompany_id
        decode(intercompany_id, company_cost_center_org_id,
        decode(l_intercompany_id, NULL,
        decode('Y',
         -- matching against Retained Earnings Account template
         l_default_org_id,
         -- matching against Suspense Account template
         l_default_org_id,
        company_cost_center_org_id),
        intercompany_id), intercompany_id),
        fb.line_item_id;

    UPDATE gcs_entry_lines_gt gelg
       SET company_cost_center_org_id = l_default_org_id,
           intercompany_id = DECODE(intercompany_id, company_cost_center_org_id,
                                    DECODE(l_intercompany_id, NULL, l_default_org_id),
                                    intercompany_id)
     WHERE (
 line_item_id, company_cost_center_org_id) IN (
                   SELECT
                           line_item_id,
                            retrieve_org_id (cr2.child_entity_id)
                       FROM gcs_cons_relationships cr2,
                            gcs_curr_treatments_b gctb
                      WHERE cr2.parent_entity_id = p_cons_entity_id
                        AND cr2.hierarchy_id = p_hierarchy_id
                        AND cr2.actual_ownership_flag = 'Y'
                        AND p_period_end_date BETWEEN cr2.start_date
                                                  AND NVL (cr2.end_date,
                                                           p_period_end_date
                                                          )
                        AND gctb.curr_treatment_id IN (
                               SELECT     gcr.curr_treatment_id
                                     FROM gcs_cons_relationships gcr
                               START WITH gcr.hierarchy_id = p_hierarchy_id
                                      AND gcr.parent_entity_id =
                                                              p_cons_entity_id
                                      AND gcr.actual_ownership_flag = 'Y'
                                      AND p_period_end_date
                                             BETWEEN gcr.start_date
                                                 AND NVL (gcr.end_date,
                                                          p_period_end_date
                                                         )
                               CONNECT BY PRIOR gcr.child_entity_id =
                                                          gcr.parent_entity_id
                                      AND gcr.hierarchy_id = p_hierarchy_id
                                      AND gcr.actual_ownership_flag = 'Y'
                                      AND p_period_end_date
                                             BETWEEN gcr.start_date
                                                 AND NVL (gcr.end_date,
                                                          p_period_end_date
                                                         ))
                   GROUP BY
  line_item_id, cr2.child_entity_id);

         INSERT /*+ append */INTO gcs_entry_lines
                     (entry_id, company_cost_center_org_id, line_item_id,
                      intercompany_id,
  xtd_balance_e, ytd_balance_e,
                      ptd_debit_balance_e, ptd_credit_balance_e,
                      ytd_debit_balance_e, ytd_credit_balance_e,
                      creation_date, created_by, last_update_date,
                      last_updated_by, last_update_login)
            SELECT   entry_id, company_cost_center_org_id, line_item_id,
                     intercompany_id,
 
                     SUM (xtd_balance_e), SUM (ytd_balance_e),
                     SUM (ptd_debit_balance_e), SUM (ptd_credit_balance_e),
                     SUM (ytd_debit_balance_e), SUM (ytd_credit_balance_e),
                     SYSDATE, gcs_aggregation_pkg.g_fnd_user_id, SYSDATE,
                     gcs_aggregation_pkg.g_fnd_user_id,
                     gcs_aggregation_pkg.g_fnd_login_id
                FROM gcs_entry_lines_gt
            GROUP BY entry_id,
                      company_cost_center_org_id,
                     line_item_id,
                     intercompany_id;
    END IF; -- l_bal_by_org_flag

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.' || fn_name,
                     'Inserted ' || to_char(SQL%ROWCOUNT) || ' row(s)');
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_success || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      RAISE;
  END insert_full_entry_lines;

END GCS_AGGREGATION_DYNAMIC_PKG;

/
