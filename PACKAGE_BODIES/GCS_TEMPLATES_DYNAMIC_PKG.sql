--------------------------------------------------------
--  DDL for Package Body GCS_TEMPLATES_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_TEMPLATES_DYNAMIC_PKG" AS
/* $Header: gcstempb.pls 120.4 2007/10/08 21:23:03 skamdar ship $ */
   gcs_tmp_invalid_hierarchy    EXCEPTION;
   gcs_tmp_invalid_sign         EXCEPTION;
   gcs_tmp_balancing_failed     EXCEPTION;
   -- The API name
   g_pkg_name                   VARCHAR2 (50) := 'gcs.plsql.GCS_TEMPLATES_DYNAMIC_PKG';
   -- A newline character. Included for convenience when writing long strings.
   g_nl                         VARCHAR2 (1)  := '
';

   -- Used to obtain specific intercompany id
   CURSOR intercompany_c IS
   SELECT SPECIFIC_INTERCOMPANY_ID
     FROM GCS_CATEGORIES_B
    WHERE CATEGORY_CODE = 'INTRACOMPANY';

--
-- Public Procedures
--
   PROCEDURE calculate_re (
      p_entry_id        NUMBER,
      p_hierarchy_id    NUMBER,
      p_bal_type_code   VARCHAR2,
      p_entity_id       NUMBER,
      p_data_prep_flag  VARCHAR2 DEFAULT 'N'
   )
   IS
      l_merge_statement            VARCHAR2 (5000);

      -- Used to obtain hierarchy information
      CURSOR hierarchy_c
      IS
         SELECT hb.balance_by_org_flag, hb.column_name
           FROM gcs_hierarchies_b hb
          WHERE hb.hierarchy_id = p_hierarchy_id;

      org_tracking_flag            VARCHAR2 (1);
      secondary_dimension_column   VARCHAR2 (30);

      -- Used to obtain sign information
      CURSOR sign_c IS
      SELECT fxata.number_assign_value
      FROM   gcs_dimension_templates dt,
             fem_ln_items_attr flia,
             fem_ext_acct_types_attr fxata
      WHERE  dt.hierarchy_id = p_hierarchy_id
      AND    dt.template_code = 'RE'
      AND    flia.line_item_id = dt.line_item_id
      AND    flia.attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id
      AND    flia.version_id = GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id
      AND    fxata.ext_account_type_code = flia.dim_attribute_varchar_member
      AND    fxata.attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').attribute_id
      AND    fxata.version_id = GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').version_id;

      sign_value NUMBER;
      l_intercompany_id NUMBER(15);

      -- Used to get the org and secondary dimension value IDs to use
      -- in the balancing account, and the credit excess amount.
      l_org_id                     NUMBER;
      l_re_required                VARCHAR2(1);
      l_api_name                   VARCHAR2 (30)   := 'CALCULATE_RE';
   BEGIN
      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'SELECT ''X'''
                         || g_nl
                         || 'FROM	gcs_entry_headers '
                         || g_nl
                         || 'WHERE  entry_id = '
                         || p_entry_id
                         || g_nl
                         || 'AND start_cal_period_id <> end_cal_period_id '
                        );
      END IF;

      IF p_data_prep_flag = 'N' THEN
      BEGIN
      SELECT 'Y'
      INTO l_re_required
      FROM gcs_entry_headers
      WHERE entry_id = p_entry_id
      AND start_cal_period_id <> nvl(end_cal_period_id, 0);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN;
      END;
      ELSE
        l_re_required := 'Y';
      END IF;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'SELECT hb.balance_by_org_flag, hb.column_name'
                         || g_nl
                         || 'FROM	gcs_hierarchies_b hb '
                         || g_nl
                         || 'WHERE  hb.hierarchy_id = '
                         || p_hierarchy_id
                        );
      END IF;

      -- Get org tracking and secondary tracking information.
      OPEN hierarchy_c;

      FETCH hierarchy_c
       INTO org_tracking_flag, secondary_dimension_column;

      IF hierarchy_c%NOTFOUND
      THEN
         CLOSE hierarchy_c;

         RAISE gcs_tmp_invalid_hierarchy;
      END IF;

      CLOSE hierarchy_c;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                        'SELECT specific_intercompany_id FROM gcs_hierarchies_b '
                        || ' WHERE hierarchy_id =  ' || p_hierarchy_id
                        || ' AND INTERCOMPANY_ORG_TYPE_CODE = ''SPECIFIC_VALUE''');
      END IF;

      -- Get specific intercompany_id, if null, using orgs
      OPEN intercompany_c;

      FETCH intercompany_c
       INTO l_intercompany_id;

      CLOSE intercompany_c;

      -- Get the signage of the suspense line item
     IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                         'SELECT fxata.number_assign_value' || g_nl ||
                         'FROM   gcs_dimension_templates dt, ' || g_nl ||
                         '       fem_ln_items_attr flia,' || g_nl ||
                         '       fem_ext_acct_types_attr fxata' || g_nl ||
                         'WHERE  dt.hierarchy_id = ' || p_hierarchy_id || g_nl ||
                         'AND    dt.template_code = ''RE''' || g_nl ||
                         'AND    flia.line_item_id = dt.line_item_id' || g_nl ||
                         'AND    flia.attribute_id = ' ||
                         GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id || g_nl ||
                         'AND    flia.version_id = ' ||
                         GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id || g_nl ||
                         'AND    fxata.ext_account_type_code = flia.dim_attribute_varchar_member' || g_nl ||
                         'AND    fxata.attribute_id = ' ||
                         GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').attribute_id || g_nl ||
                         'AND    fxata.version_id = ' ||
                         GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').version_id
                        );
      END IF;

      -- Get signage information
      OPEN sign_c;
      FETCH sign_c INTO sign_value;
      IF sign_c%NOTFOUND
      THEN
         CLOSE sign_c;
         RAISE gcs_tmp_invalid_sign;
      END IF;
      CLOSE sign_c;


      IF org_tracking_flag = 'N'
      THEN
         l_org_id := gcs_utility_pkg.Get_Org_Id(p_entity_id => p_entity_id,
                                    p_hierarchy_id => p_hierarchy_id);
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
                fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_org_id = '  || l_org_id
                        );
         END IF;

      END IF;
        

      IF org_tracking_flag = 'Y' AND secondary_dimension_column IS NOT NULL
      THEN
         l_merge_statement :=
               'MERGE INTO gcs_entry_lines gel
       USING (
SELECT gel_1.company_cost_center_org_id,

                     SUM (  NVL (gel_1.ytd_credit_balance_e, 0)
                          - NVL (gel_1.ytd_debit_balance_e, 0)
                         ) amount
FROM gcs_dimension_templates gdt, gcs_entry_lines gel_1, fem_ln_items_attr flia,
fem_ext_acct_types_attr feata
WHERE gdt.hierarchy_id = :1
AND gdt.template_code = ''RE''
AND gel_1.entry_id = :2
AND  feata.dim_attribute_varchar_member IN (''REVENUE'', ''EXPENSE'')
AND  feata.dim_attribute_numeric_member IS NULL
AND flia.value_set_id = '
            || gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id
            || '
AND feata.ext_account_type_code = flia.dim_attribute_varchar_member
AND flia.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id
            || '
AND feata.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id
            || '
AND flia.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id
            || '
AND feata.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id
            || '
AND gel_1.line_item_id = flia.line_item_id
GROUP BY
, gel_1.company_cost_center_org_id ) src
        ON (    gel.entry_id = :2
 AND gel.line_type_code = ''CALCULATED'' )
   WHEN MATCHED THEN
      UPDATE
         SET gel.ytd_balance_e = gel.ytd_balance_e + ' || sign_value || ' * -src.amount,
             gel.xtd_balance_e = gel.xtd_balance_e + ' || sign_value || ' * -src.amount,
             gel.ytd_debit_balance_e = gel.ytd_debit_balance_e + decode(sign(src.amount), 1, 0,-src.amount),
             gel.ytd_credit_balance_e = gel.ytd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.ptd_debit_balance_e = gel.ptd_debit_balance_e + decode(sign(src.amount), 1, 0,-src.amount),
             gel.ptd_credit_balance_e = gel.ptd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.last_update_date = SYSDATE,
             gel.last_updated_by = :3
   WHEN NOT MATCHED THEN
      INSERT (entry_id, line_type_code, description, gel.xtd_balance_e, gel.ytd_balance_e,
              gel.ptd_debit_balance_e, gel.ptd_credit_balance_e,
              gel.ytd_debit_balance_e, gel.ytd_credit_balance_e,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (:2, ''CALCULATED'', ''RE_LINE'',  -src.amount * ' || sign_value || ', -src.amount * ' || sign_value || ',
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              SYSDATE, :3, SYSDATE, :3, :4)
';

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_merge_statement = '|| l_merge_statement
                        );
      END IF;

         EXECUTE IMMEDIATE l_merge_statement
                     USING    p_hierarchy_id,
                           p_entry_id,
                              p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           fnd_global.user_id,
                           fnd_global.login_id;
      ELSIF secondary_dimension_column IS NOT NULL
      THEN
         l_merge_statement :=
               'MERGE INTO gcs_entry_lines gel
       USING (
SELECT :6 company_cost_center_org_id,

                     SUM (  NVL (gel_1.ytd_credit_balance_e, 0)
                          - NVL (gel_1.ytd_debit_balance_e, 0)) amount
FROM gcs_dimension_templates gdt, gcs_entry_lines gel_1, fem_ln_items_attr flia,
fem_ext_acct_types_attr feata
WHERE gdt.hierarchy_id = :1
AND gdt.template_code = ''RE''
AND gel_1.entry_id = :2
AND  feata.dim_attribute_varchar_member IN (''REVENUE'', ''EXPENSE'')
AND  feata.dim_attribute_numeric_member IS NULL
AND flia.value_set_id = '
            || gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id
            || '
AND feata.ext_account_type_code = flia.dim_attribute_varchar_member
AND flia.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id
            || '
AND feata.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id
            || '
AND flia.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id
            || '
AND feata.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id
            || '
AND gel_1.line_item_id = flia.line_item_id
            GROUP BY
) src
        ON (    gel.entry_id = :2
 AND gel.line_type_code = ''CALCULATED'' )
   WHEN MATCHED THEN
      UPDATE
         SET gel.ytd_balance_e = gel.ytd_balance_e + ' || sign_value || ' * -src.amount,
             gel.xtd_balance_e = gel.xtd_balance_e + ' || sign_value || ' * -src.amount,
             gel.ytd_debit_balance_e = gel.ytd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ytd_credit_balance_e = gel.ytd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.ptd_debit_balance_e = gel.ptd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ptd_credit_balance_e = gel.ptd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.last_update_date = SYSDATE,
             gel.last_updated_by = :3
   WHEN NOT MATCHED THEN
      INSERT (entry_id, line_type_code, description,  gel.xtd_balance_e, gel.ytd_balance_e,
              gel.ptd_debit_balance_e, gel.ptd_credit_balance_e,
              gel.ytd_debit_balance_e, gel.ytd_credit_balance_e,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (:2, ''CALCULATED'', ''RE_LINE'',  -src.amount * ' || sign_value || ', -src.amount * ' || sign_value || ',
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              SYSDATE, :3, SYSDATE, :3, :4)
';

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_merge_statement = '|| l_merge_statement
                        );
      END IF;

         EXECUTE IMMEDIATE l_merge_statement
                     USING l_org_id,
                              p_hierarchy_id,
                           p_entry_id,
                              p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           fnd_global.user_id,
                           fnd_global.login_id;
      ELSIF org_tracking_flag = 'Y'
      THEN
         l_merge_statement :=
               'MERGE INTO gcs_entry_lines gel
     USING (SELECT   gel_1.company_cost_center_org_id, 
                     SUM (  NVL (gel_1.ytd_credit_balance_e, 0)
                          - NVL (gel_1.ytd_debit_balance_e, 0)
                         ) amount
FROM gcs_dimension_templates gdt, gcs_entry_lines gel_1, fem_ln_items_attr flia,
fem_ext_acct_types_attr feata
WHERE gdt.hierarchy_id = :1
AND gdt.template_code = ''RE''
AND gel_1.entry_id = :2
AND  feata.dim_attribute_varchar_member IN (''REVENUE'', ''EXPENSE'')
AND  feata.dim_attribute_numeric_member IS NULL
AND flia.value_set_id = '
            || gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id
            || '
AND feata.ext_account_type_code = flia.dim_attribute_varchar_member
AND flia.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id
            || '
AND feata.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id
            || '
AND flia.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id
            || '
AND feata.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id
            || '
AND gel_1.line_item_id = flia.line_item_id
            GROUP BY gel_1.company_cost_center_org_id) src
        ON (    gel.entry_id = :2
 AND gel.line_type_code = ''CALCULATED'' )
   WHEN MATCHED THEN
      UPDATE
         SET gel.ytd_balance_e = gel.ytd_balance_e + ' || sign_value || ' * -src.amount,
             gel.xtd_balance_e = gel.xtd_balance_e + ' || sign_value || ' * -src.amount,
             gel.ytd_debit_balance_e = gel.ytd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ytd_credit_balance_e = gel.ytd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.ptd_debit_balance_e = gel.ptd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ptd_credit_balance_e = gel.ptd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.last_update_date = SYSDATE,
             gel.last_updated_by = :5
   WHEN NOT MATCHED THEN
      INSERT (entry_id, line_type_code, description, gel.xtd_balance_e, gel.ytd_balance_e,
              gel.ptd_debit_balance_e, gel.ptd_credit_balance_e,
              gel.ytd_debit_balance_e, gel.ytd_credit_balance_e,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (:2, ''CALCULATED'', ''RE_LINE'',  -src.amount * ' || sign_value || ', -src.amount * ' || sign_value || ',
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              SYSDATE, :3, SYSDATE, :3, :4)
';

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_merge_statement = '|| l_merge_statement
                        );
      END IF;

         EXECUTE IMMEDIATE l_merge_statement
                     USING p_hierarchy_id,
                           p_entry_id,
                           p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           fnd_global.user_id,
                           fnd_global.login_id;
      ELSE
         l_merge_statement :=
               'MERGE INTO gcs_entry_lines gel
     USING (SELECT   :6 company_cost_center_org_id, 
                     SUM (  NVL (gel_1.ytd_credit_balance_e, 0)
                          - NVL (gel_1.ytd_debit_balance_e, 0)
                         ) amount
FROM gcs_dimension_templates gdt, gcs_entry_lines gel_1, fem_ln_items_attr flia,
fem_ext_acct_types_attr feata
WHERE gdt.hierarchy_id = :1
AND gdt.template_code = ''RE''
AND gel_1.entry_id = :2
AND feata.dim_attribute_varchar_member IN (''REVENUE'', ''EXPENSE'')
AND feata.dim_attribute_numeric_member IS NULL
AND flia.value_set_id = '
            || gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id
            || '
AND feata.ext_account_type_code = flia.dim_attribute_varchar_member
AND flia.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id
            || '
AND feata.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id
            || '
AND flia.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id
            || '
AND feata.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id
            || '
AND gel_1.line_item_id = flia.line_item_id
            GROUP BY ) src
        ON (    gel.entry_id = :2
 AND gel.line_type_code = ''CALCULATED'' )
   WHEN MATCHED THEN
      UPDATE
         SET gel.ytd_balance_e = gel.ytd_balance_e + ' || sign_value || ' * -src.amount,
             gel.xtd_balance_e = gel.xtd_balance_e + ' || sign_value || ' * -src.amount,
             gel.ytd_debit_balance_e = gel.ytd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ytd_credit_balance_e = gel.ytd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.ptd_debit_balance_e = gel.ptd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ptd_credit_balance_e = gel.ptd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.last_update_date = SYSDATE,
             gel.last_updated_by = :5
   WHEN NOT MATCHED THEN
      INSERT (entry_id, line_type_code, description, gel.xtd_balance_e, gel.ytd_balance_e,
              gel.ptd_debit_balance_e, gel.ptd_credit_balance_e,
              gel.ytd_debit_balance_e, gel.ytd_credit_balance_e,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (:2, ''CALCULATED'', ''RE_LINE'',  -src.amount * ' || sign_value || ', -src.amount * ' || sign_value || ',
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              SYSDATE, :3, SYSDATE, :3, :4)
';

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_merge_statement = '|| l_merge_statement
                        );
      END IF;

         EXECUTE IMMEDIATE l_merge_statement
                     USING l_org_id,
                           p_hierarchy_id,
                           p_entry_id,
                           p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           fnd_global.user_id,
                           fnd_global.login_id;
      END IF;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
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
      WHEN gcs_tmp_invalid_sign
      THEN
         fnd_message.set_name ('GCS', 'GCS_TMP_INVALID_SIGN');

        IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
        THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                              gcs_utility_pkg.g_module_failure
                           || ' '
                           || l_api_name
                           || '() '
                           || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
        END IF;
        RAISE gcs_tmp_balancing_failed;
   END calculate_re;
        
   PROCEDURE calculate_dp_re (
      p_entry_id        NUMBER,
      p_hierarchy_id    NUMBER,
      p_bal_type_code   VARCHAR2,
      p_entity_id       NUMBER,
      p_pre_cal_period_id    NUMBER,
      p_first_ever_data_prep    VARCHAR2
   )
   IS
      l_merge_statement            VARCHAR2 (5000);

      -- Used to obtain hierarchy information
      CURSOR hierarchy_c
      IS
         SELECT hb.balance_by_org_flag, hb.column_name
           FROM gcs_hierarchies_b hb
          WHERE hb.hierarchy_id = p_hierarchy_id;

      org_tracking_flag            VARCHAR2 (1);
      secondary_dimension_column   VARCHAR2 (30);

      -- Used to obtain sign information
      CURSOR sign_c IS
      SELECT fxata.number_assign_value
      FROM   gcs_dimension_templates dt,
             fem_ln_items_attr flia,
             fem_ext_acct_types_attr fxata
      WHERE  dt.hierarchy_id = p_hierarchy_id
      AND    dt.template_code = 'RE'
      AND    flia.line_item_id = dt.line_item_id
      AND    flia.attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id
      AND    flia.version_id = GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id
      AND    fxata.ext_account_type_code = flia.dim_attribute_varchar_member
      AND    fxata.attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').attribute_id
      AND    fxata.version_id = GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').version_id;

      sign_value NUMBER;
      l_intercompany_id NUMBER(15);

      -- Used to get the org and secondary dimension value IDs to use
      -- in the balancing account, and the credit excess amount.
      l_org_id                     NUMBER;
      l_api_name                   VARCHAR2 (30)   := 'CALCULATE_DP_RE';
   BEGIN

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'SELECT hb.balance_by_org_flag, hb.column_name'
                         || g_nl
                         || 'FROM	gcs_hierarchies_b hb '
                         || g_nl
                         || 'WHERE  hb.hierarchy_id = '
                         || p_hierarchy_id
                        );
      END IF;

      IF p_first_ever_data_prep = 'Y' THEN
          calculate_re(      p_entry_id     => p_entry_id,
              p_hierarchy_id    => p_hierarchy_id,
              p_bal_type_code   => p_bal_type_code,
              p_entity_id       => p_entity_id,
              p_data_prep_flag  => 'Y'
          );
          RETURN;
      END IF;

      -- Get org tracking and secondary tracking information.
      OPEN hierarchy_c;

      FETCH hierarchy_c
       INTO org_tracking_flag, secondary_dimension_column;

      IF hierarchy_c%NOTFOUND
      THEN
         CLOSE hierarchy_c;

         RAISE gcs_tmp_invalid_hierarchy;
      END IF;

      CLOSE hierarchy_c;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                        'SELECT specific_intercompany_id FROM gcs_hierarchies_b '
                        || ' WHERE hierarchy_id =  ' || p_hierarchy_id
                        || ' AND INTERCOMPANY_ORG_TYPE_CODE = ''SPECIFIC_VALUE''');
      END IF;

      -- Get specific intercompany_id, if null, using orgs
      OPEN intercompany_c;

      FETCH intercompany_c
       INTO l_intercompany_id;

      CLOSE intercompany_c;

      -- Get the signage of the suspense line item
     IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                         'SELECT fxata.number_assign_value' || g_nl ||
                         'FROM   gcs_dimension_templates dt' || g_nl ||
                         '       fem_ln_items_attr flia,' || g_nl ||
                         '       fem_ext_acct_types_attr fxata' || g_nl ||
                         'WHERE  dt.hierarchy_id = ' || p_hierarchy_id || g_nl ||
                         'AND    dt.template_code = ''RE''' || g_nl ||
                         'AND    flia.line_item_id = dt.line_item_id' || g_nl ||
                         'AND    flia.attribute_id = ' ||
                         GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id || g_nl ||
                         'AND    flia.version_id = ' ||
                         GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id || g_nl ||
                         'AND    fxata.ext_account_type_code = flia.dim_attribute_varchar_member' || g_nl ||
                         'AND    fxata.attribute_id = ' ||
                         GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').attribute_id|| g_nl ||
                         'AND    fxata.version_id = ' ||
                         GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').version_id
                        );
      END IF;

      -- Get signage information
      OPEN sign_c;
      FETCH sign_c INTO sign_value;
      IF sign_c%NOTFOUND
      THEN
         CLOSE sign_c;
         RAISE gcs_tmp_invalid_sign;
      END IF;
      CLOSE sign_c;


      IF org_tracking_flag = 'N'
      THEN
         l_org_id := gcs_utility_pkg.Get_Org_Id(p_entity_id => p_entity_id,
                                    p_hierarchy_id => p_hierarchy_id);
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
                fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_org_id = '  || l_org_id
                        );
         END IF;
      END IF;

        

      IF org_tracking_flag = 'Y' AND secondary_dimension_column IS NOT NULL
      THEN
         l_merge_statement :=
               'MERGE INTO gcs_entry_lines gel
       USING (
SELECT fb.company_cost_center_org_id,

                     SUM (  NVL (fb.ytd_credit_balance_e, 0)
                          - NVL (fb.ytd_debit_balance_e, 0)
                         ) amount
FROM gcs_dimension_templates gdt, fem_balances fb, fem_ln_items_attr flia,
fem_ext_acct_types_attr feata, FEM_SOURCE_SYSTEMS_B fssb
WHERE gdt.hierarchy_id = :1
AND gdt.template_code = ''RE''
AND fb.cal_period_id = :2
AND fb.line_item_id = flia.line_item_id
AND fssb.source_system_display_code = ''GCS''
AND fb.hierarchy_id = gdt.hierarchy_id
AND fb.source_system_code = fssb.source_system_code
AND  feata.dim_attribute_varchar_member IN (''REVENUE'', ''EXPENSE'')
AND  feata.dim_attribute_numeric_member IS NULL
AND flia.value_set_id = '
            || gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id
            || '
AND feata.ext_account_type_code = flia.dim_attribute_varchar_member
AND flia.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id
            || '
AND feata.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id
            || '
AND flia.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id
            || '
AND feata.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id
            || '
AND fb.line_item_id = flia.line_item_id
GROUP BY
, fb.company_cost_center_org_id ) src
        ON (    gel.entry_id = :2
 AND gel.line_type_code = ''CALCULATED'' )
   WHEN MATCHED THEN
      UPDATE
         SET gel.ytd_balance_e = gel.ytd_balance_e + ' || sign_value || ' * -src.amount,
             gel.xtd_balance_e = gel.xtd_balance_e + ' || sign_value || ' * -src.amount,
             gel.ytd_debit_balance_e = gel.ytd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ytd_credit_balance_e = gel.ytd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.ptd_debit_balance_e = gel.ptd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ptd_credit_balance_e = gel.ptd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.last_update_date = SYSDATE,
             gel.last_updated_by = :3
   WHEN NOT MATCHED THEN
      INSERT (entry_id, line_type_code, description, gel.xtd_balance_e, gel.ytd_balance_e,
              gel.ptd_debit_balance_e, gel.ptd_credit_balance_e,
              gel.ytd_debit_balance_e, gel.ytd_credit_balance_e,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (:2, ''CALCULATED'', ''RE_LINE'',  -src.amount * ' || sign_value || ', -src.amount * ' || sign_value || ',
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              SYSDATE, :3, SYSDATE, :3, :4)
';

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_merge_statement = '|| l_merge_statement
                        );
      END IF;

         EXECUTE IMMEDIATE l_merge_statement
                     USING    p_hierarchy_id,
                           p_pre_cal_period_id,
                              p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           fnd_global.user_id,
                           fnd_global.login_id;
      ELSIF secondary_dimension_column IS NOT NULL
      THEN
         l_merge_statement :=
               'MERGE INTO gcs_entry_lines gel
       USING (
SELECT :6 company_cost_center_org_id,

                     SUM (  NVL (fb.ytd_credit_balance_e, 0)
                          - NVL (fb.ytd_debit_balance_e, 0)
                         ) amount
FROM gcs_dimension_templates gdt, fem_balances fb, fem_ln_items_attr flia,
fem_ext_acct_types_attr feata, FEM_SOURCE_SYSTEMS_B fssb
WHERE gdt.hierarchy_id = :1
AND gdt.template_code = ''RE''
AND fb.cal_period_id = :2
AND fb.line_item_id = flia.line_item_id
AND fssb.source_system_display_code = ''GCS''
AND fb.hierarchy_id = gdt.hierarchy_id
AND fb.source_system_code = fssb.source_system_code
AND  feata.dim_attribute_varchar_member IN (''REVENUE'', ''EXPENSE'')
AND  feata.dim_attribute_numeric_member IS NULL
AND flia.value_set_id = '
            || gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id
            || '
AND feata.ext_account_type_code = flia.dim_attribute_varchar_member
AND flia.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id
            || '
AND feata.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id
            || '
AND flia.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id
            || '
AND feata.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id
            || '
AND fb.line_item_id = flia.line_item_id
            GROUP BY
) src
        ON (    gel.entry_id = :2
 AND gel.line_type_code = ''CALCULATED'' )
   WHEN MATCHED THEN
      UPDATE
         SET gel.ytd_balance_e = gel.ytd_balance_e + ' || sign_value || ' * -src.amount,
             gel.xtd_balance_e = gel.xtd_balance_e + ' || sign_value || ' * -src.amount,
             gel.ytd_debit_balance_e = gel.ytd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ytd_credit_balance_e = gel.ytd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.ptd_debit_balance_e = gel.ptd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ptd_credit_balance_e = gel.ptd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.last_update_date = SYSDATE,
             gel.last_updated_by = :3
   WHEN NOT MATCHED THEN
      INSERT (entry_id, line_type_code, description,  gel.xtd_balance_e, gel.ytd_balance_e,
              gel.ptd_debit_balance_e, gel.ptd_credit_balance_e,
              gel.ytd_debit_balance_e, gel.ytd_credit_balance_e,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (:2, ''CALCULATED'', ''RE_LINE'',  -src.amount * ' || sign_value || ', -src.amount * ' || sign_value || ',
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              SYSDATE, :3, SYSDATE, :3, :4)
';

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_merge_statement = '|| l_merge_statement
                        );
      END IF;

         EXECUTE IMMEDIATE l_merge_statement
                     USING l_org_id,
                              p_hierarchy_id,
                           p_pre_cal_period_id,
                              p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           fnd_global.user_id,
                           fnd_global.login_id;
      ELSIF org_tracking_flag = 'Y'
      THEN
         l_merge_statement :=
               'MERGE INTO gcs_entry_lines gel
     USING (SELECT   fb.company_cost_center_org_id, 
                     SUM (  NVL (fb.ytd_credit_balance_e, 0)
                          - NVL (fb.ytd_debit_balance_e, 0)
                         ) amount
FROM gcs_dimension_templates gdt, fem_balances fb, fem_ln_items_attr flia,
fem_ext_acct_types_attr feata, FEM_SOURCE_SYSTEMS_B fssb
WHERE gdt.hierarchy_id = :1
AND gdt.template_code = ''RE''
AND fb.cal_period_id = :2
AND fb.line_item_id = flia.line_item_id
AND fssb.source_system_display_code = ''GCS''
AND fb.hierarchy_id = gdt.hierarchy_id
AND fb.source_system_code = fssb.source_system_code
AND  feata.dim_attribute_varchar_member IN (''REVENUE'', ''EXPENSE'')
AND  feata.dim_attribute_numeric_member IS NULL
AND flia.value_set_id = '
            || gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id
            || '
AND feata.ext_account_type_code = flia.dim_attribute_varchar_member
AND flia.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id
            || '
AND feata.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id
            || '
AND flia.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id
            || '
AND feata.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id
            || '
AND fb.line_item_id = flia.line_item_id
            GROUP BY fb.company_cost_center_org_id) src
        ON (    gel.entry_id = :2
 AND gel.line_type_code = ''CALCULATED'' )
   WHEN MATCHED THEN
      UPDATE
         SET gel.ytd_balance_e = gel.ytd_balance_e + ' || sign_value || ' * -src.amount,
             gel.xtd_balance_e = gel.xtd_balance_e + ' || sign_value || ' * -src.amount,
             gel.ytd_debit_balance_e = gel.ytd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ytd_credit_balance_e = gel.ytd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.ptd_debit_balance_e = gel.ptd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ptd_credit_balance_e = gel.ptd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.last_update_date = SYSDATE,
             gel.last_updated_by = :5
   WHEN NOT MATCHED THEN
      INSERT (entry_id, line_type_code, description, gel.xtd_balance_e, gel.ytd_balance_e,
              gel.ptd_debit_balance_e, gel.ptd_credit_balance_e,
              gel.ytd_debit_balance_e, gel.ytd_credit_balance_e,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (:2, ''CALCULATED'', ''RE_LINE'',  -src.amount * ' || sign_value || ', -src.amount * ' || sign_value || ',
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              SYSDATE, :3, SYSDATE, :3, :4)
';

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_merge_statement = '|| l_merge_statement
                        );
      END IF;

         EXECUTE IMMEDIATE l_merge_statement
                     USING p_hierarchy_id,
                           p_pre_cal_period_id,
                           p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           fnd_global.user_id,
                           fnd_global.login_id;
      ELSE
         l_merge_statement :=
               'MERGE INTO gcs_entry_lines gel
     USING (SELECT   :6 company_cost_center_org_id, 
                     SUM (  NVL (fb.ytd_credit_balance_e, 0)
                          - NVL (fb.ytd_debit_balance_e, 0)
                         ) amount
FROM gcs_dimension_templates gdt, fem_balances fb, fem_ln_items_attr flia,
fem_ext_acct_types_attr feata, FEM_SOURCE_SYSTEMS_B fssb
WHERE gdt.hierarchy_id = :1
AND gdt.template_code = ''RE''
AND fb.cal_period_id = :2
AND fb.line_item_id = flia.line_item_id
AND fssb.source_system_display_code = ''GCS''
AND fb.hierarchy_id = gdt.hierarchy_id
AND fb.source_system_code = fssb.source_system_code
AND  feata.dim_attribute_varchar_member IN (''REVENUE'', ''EXPENSE'')
AND  feata.dim_attribute_numeric_member IS NULL
AND flia.value_set_id = '
            || gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id
            || '
AND feata.ext_account_type_code = flia.dim_attribute_varchar_member
AND flia.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id
            || '
AND feata.attribute_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id
            || '
AND flia.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info
                                         ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id
            || '
AND feata.version_id = '
            || gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id
            || '
AND fb.line_item_id = flia.line_item_id
            GROUP BY ) src
        ON (    gel.entry_id = :2
 AND gel.line_type_code = ''CALCULATED'' )
   WHEN MATCHED THEN
      UPDATE
         SET gel.ytd_balance_e = gel.ytd_balance_e + ' || sign_value || ' * -src.amount,
             gel.xtd_balance_e = gel.xtd_balance_e + ' || sign_value || ' * -src.amount,
             gel.ytd_debit_balance_e = gel.ytd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ytd_credit_balance_e = gel.ytd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.ptd_debit_balance_e = gel.ptd_debit_balance_e + decode(sign(src.amount), 1, 0, -src.amount),
             gel.ptd_credit_balance_e = gel.ptd_credit_balance_e + decode(sign(src.amount), 1, src.amount, 0),
             gel.last_update_date = SYSDATE,
             gel.last_updated_by = :5
   WHEN NOT MATCHED THEN
      INSERT (entry_id, line_type_code, description, gel.xtd_balance_e, gel.ytd_balance_e,
              gel.ptd_debit_balance_e, gel.ptd_credit_balance_e,
              gel.ytd_debit_balance_e, gel.ytd_credit_balance_e,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (:2, ''CALCULATED'', ''RE_LINE'',  -src.amount * ' || sign_value || ', -src.amount * ' || sign_value || ',
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              decode(sign(src.amount), 1, 0, -src.amount), decode(sign(src.amount), 1, src.amount, 0),
              SYSDATE, :3, SYSDATE, :3, :4)
';

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_merge_statement = '|| l_merge_statement
                        );
      END IF;

         EXECUTE IMMEDIATE l_merge_statement
                     USING l_org_id,
                           p_hierarchy_id,
                           p_pre_cal_period_id,
                           p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           p_entry_id,
                           l_intercompany_id,
                           fnd_global.user_id,
                           fnd_global.user_id,
                           fnd_global.login_id;
      END IF;

    EXCEPTION
      WHEN gcs_tmp_invalid_sign
      THEN
         fnd_message.set_name ('GCS', 'GCS_TMP_INVALID_SIGN');

        IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
        THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                              gcs_utility_pkg.g_module_failure
                           || ' '
                           || l_api_name
                           || '() '
                           || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
        END IF;
        RAISE gcs_tmp_balancing_failed;
   END calculate_dp_re;
        
   PROCEDURE balance (
      p_entry_id          NUMBER,
      p_template          gcs_templates_pkg.templaterecord,
      p_bal_type_code     VARCHAR2,
      p_hierarchy_id      NUMBER,
      p_entity_id         NUMBER,
      p_threshold         NUMBER DEFAULT 0,
      p_threshold_currency_code  VARCHAR2 DEFAULT NULL
   )
   IS
      l_merge_statement            VARCHAR2 (5000);

      -- Used to obtain hierarchy information
      CURSOR hierarchy_c
      IS
         SELECT hb.balance_by_org_flag, hb.column_name
           FROM gcs_hierarchies_b hb
          WHERE hb.hierarchy_id = p_hierarchy_id;

      -- Used to get the category cdoe
      CURSOR category_c
      IS
         SELECT cb.category_code,
		cb.category_type_code
           FROM gcs_entry_headers eh,
		gcs_categories_b cb
          WHERE eh.entry_id = p_entry_id
            AND cb.category_code = eh.category_code;

      org_tracking_flag            VARCHAR2 (1);
      secondary_dimension_column   VARCHAR2 (30);

      -- Used to obtain sign information
      CURSOR sign_c IS
      SELECT fxata.number_assign_value
      FROM   fem_ln_items_attr flia,
             fem_ext_acct_types_attr fxata
      WHERE  flia.line_item_id = p_template.line_item_id
      AND    flia.attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id
      AND    flia.version_id = GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id
      AND    fxata.ext_account_type_code = flia.dim_attribute_varchar_member
      AND    fxata.attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').attribute_id
      AND    fxata.version_id = GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').version_id;

      sign_value NUMBER;
      l_intercompany_id NUMBER(15);
      l_category VARCHAR2(50);
      l_category_type VARCHAR2(50);
      l_currency_code VARCHAR2(30);
      l_cal_period_id NUMBER;
      l_errbuf VARCHAR2(4000);
      l_errcode VARCHAR2 (50);
      l_corp_rate NUMBER;
      -- Used to get the org and secondary dimension value IDs to use
      -- in the balancing account, and the credit excess amount.
      l_org_id                     NUMBER;
      l_threshold_passed_flag     VARCHAR2 (1);
      l_threshold_amount           NUMBER;
      l_api_name                   VARCHAR2 (30)   := 'BALANCE';
      l_enforce_balancing_flag VARCHAR2(1); -- Bug 5085697 : SMATAM
   BEGIN
      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;
      -- Bug 5085697 : start : SMATAM
      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement THEN
         fnd_log.STRING(fnd_log.level_statement,
                     g_pkg_name || '.' || l_api_name,
                     'SELECT enforce_balancing_flag' || g_nl ||
                     'FROM	gcs_data_type_codes_b ' || g_nl ||
                     'WHERE  data_type_code = ' || p_bal_type_code);
      END IF;
      SELECT enforce_balancing_flag
      INTO l_enforce_balancing_flag
      FROM gcs_data_type_codes_b
      WHERE data_type_code = p_bal_type_code;

      IF (l_enforce_balancing_flag IS NULL OR l_enforce_balancing_flag = 'N') THEN
          --Log that no balancing is needed
          IF fnd_log.g_current_runtime_level <= fnd_log.level_statement THEN
          fnd_log.STRING(fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                         'No Balancing is required for the balance_type_code, ' || p_bal_type_code);
          END IF;
        return;
      END IF;

    -- Bug 5085697 : End : SMATAM
      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'SELECT hb.balance_by_org_flag, hb.column_name'
                         || g_nl
                         || 'FROM	gcs_hierarchies_b hb '
                         || g_nl
                         || 'WHERE  hb.hierarchy_id = '
                         || p_hierarchy_id
                        );
      END IF;

      -- Get org tracking and secondary tracking information.
      OPEN hierarchy_c;

      FETCH hierarchy_c
       INTO org_tracking_flag, secondary_dimension_column;

      IF hierarchy_c%NOTFOUND
      THEN
         CLOSE hierarchy_c;

         RAISE gcs_tmp_invalid_hierarchy;
      END IF;

      CLOSE hierarchy_c;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'SELECT category_code'
                         || g_nl
                         || 'FROM	gcs_entry_headers '
                         || g_nl
                         || 'WHERE  entry_id = '
                         || p_entry_id
                        );
      END IF;

      -- bug fix 3797306
      -- Get category code
      OPEN category_c;

      FETCH category_c
       INTO l_category, l_category_type;
      CLOSE category_c;

      -- end of bug fix 3797306

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                        'SELECT specific_intercompany_id FROM gcs_hierarchies_b '
                        || ' WHERE hierarchy_id =  ' || p_hierarchy_id
                        || ' AND INTERCOMPANY_ORG_TYPE_CODE = ''SPECIFIC_VALUE''');
      END IF;

      -- Get specific intercompany_id, if null, using orgs
      OPEN intercompany_c;

      FETCH intercompany_c
       INTO l_intercompany_id;

      CLOSE intercompany_c;

      -- Get the signage of the suspense line item
     IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                         'SELECT fxata.number_assign_value' || g_nl ||
                         'FROM   fem_ln_items_attr flia,' || g_nl ||
                         '       fem_ext_acct_types_attr fxata' || g_nl ||
                         'WHERE  flia.line_item_id = ' || p_template.line_item_id || g_nl ||
                         'AND    flia.attribute_id = ' ||
                         GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id || g_nl ||
                         'AND    flia.version_id = ' ||
                         GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id || g_nl ||
                         'AND    fxata.ext_account_type_code = flia.dim_attribute_varchar_member' || g_nl ||
                         'AND    fxata.attribute_id = ' ||
                         GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').attribute_id || g_nl ||
                         'AND    fxata.version_id = ' ||
                         GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').version_id
                        );
      END IF;

      -- Get signage information
      OPEN sign_c;
      FETCH sign_c INTO sign_value;
      IF sign_c%NOTFOUND
      THEN
         CLOSE sign_c;
         RAISE gcs_tmp_invalid_sign;
      END IF;
      CLOSE sign_c;

      l_threshold_amount := p_threshold;
      IF p_threshold_currency_code IS NOT NULL
      THEN
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
                fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            ' select start_cal_period_id, currency_code
        into l_cal_period_id, l_currency_code
        from gcs_entry_headers
        where entry_id = '  || p_entry_id
                        );
         END IF;

        select start_cal_period_id, currency_code
        into l_cal_period_id, l_currency_code
        from gcs_entry_headers
        where entry_id = p_entry_id;

        IF l_currency_code <> p_threshold_currency_code THEN

          GCS_UTILITY_PKG.Get_Conversion_Rate
                      (p_source_currency => p_threshold_currency_code,
                       p_target_currency => l_currency_code,
                       p_cal_period_id   => l_cal_period_id,
                       p_conversion_rate => l_corp_rate,
                       P_errbuf          => l_errbuf,
                       p_errcode         => l_errcode);

          l_threshold_amount := l_corp_rate * p_threshold;
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
                fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'p_threshold = '||p_threshold||', l_corp_rate = '  || l_corp_rate
                            || ', l_threshold_amount = ' || l_threshold_amount
                        );
         END IF;
        END IF;
      END IF;


      IF org_tracking_flag = 'N'
      THEN
         l_org_id := gcs_utility_pkg.Get_Org_Id(p_entity_id => p_entity_id,
                                    p_hierarchy_id => p_hierarchy_id);
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
                fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_org_id = '  || l_org_id
                        );
         END IF;
      END IF;


      IF org_tracking_flag = 'Y' AND secondary_dimension_column IS NOT NULL
      THEN
         l_merge_statement :=
               'MERGE INTO gcs_entry_lines gel
       USING (
SELECT gel_1.company_cost_center_org_id,

                     SUM (  NVL (gel_1.ytd_credit_balance_e, 0)
                          - NVL (gel_1.ytd_debit_balance_e, 0)
                         ) ytd_amount,
                     SUM (  NVL (gel_1.ptd_credit_balance_e, 0)
                          - NVL (gel_1.ptd_debit_balance_e, 0)
                         ) ptd_amount
FROM gcs_entry_lines gel_1
WHERE gel_1.entry_id = :2
GROUP BY gel_1.company_cost_center_org_id, '||secondary_dimension_column||'
HAVING SUM (  NVL (gel_1.ytd_credit_balance_e, 0) - NVL (gel_1.ytd_debit_balance_e, 0) ) <>0 ) src
        ON (    gel.entry_id = :2
 AND gel.line_type_code = ''CALCULATED'' )
   WHEN MATCHED THEN
      UPDATE
         SET gel.ytd_balance_e = gel.ytd_balance_e + ' || sign_value || ' * src.ytd_amount,
             gel.ytd_debit_balance_e = gel.ytd_debit_balance_e + decode(sign(src.ytd_amount), -1, 0, src.ytd_amount),
             gel.ytd_credit_balance_e = gel.ytd_credit_balance_e + decode(sign(src.ytd_amount), -1, -src.ytd_amount, 0),';

         IF l_category_type <> 'CONSOLIDATION_RULE' THEN
           l_merge_statement := l_merge_statement || '
             gel.xtd_balance_e = gel.xtd_balance_e + ' || sign_value || ' * src.ptd_amount,
             gel.ptd_debit_balance_e = gel.ptd_debit_balance_e + decode(sign(src.ptd_amount), -1, 0, src.ptd_amount),
             gel.ptd_credit_balance_e = gel.ptd_credit_balance_e + decode(sign(src.ptd_amount), -1, -src.ptd_amount, 0),';
         ELSE
           l_merge_statement := l_merge_statement || '
             gel.xtd_balance_e = null,
             gel.ptd_debit_balance_e = null,
             gel.ptd_credit_balance_e = null,';
         END IF;

         l_merge_statement := l_merge_statement || '
             gel.last_update_date = SYSDATE,
             gel.description = decode(sign(abs(gel.ytd_balance_e + src.ytd_amount)-nvl(:11, 0)), 1, decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_EXCEEDED''),
      decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_LINE'')),
             gel.last_updated_by = :3
   WHEN NOT MATCHED THEN
      INSERT (entry_id, description,  gel.xtd_balance_e,
              gel.ptd_debit_balance_e, gel.ptd_credit_balance_e,
              gel.ytd_balance_e, gel.ytd_debit_balance_e, gel.ytd_credit_balance_e,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (:2, decode(sign(abs(src.ytd_amount)-nvl(:11,0)), 1, decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_EXCEEDED''),
      decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_LINE'')),  ';

         IF l_category_type <> 'CONSOLIDATION_RULE' THEN
           l_merge_statement := l_merge_statement || '
              src.ptd_amount * ' || sign_value || ',
              decode(sign(src.ptd_amount), -1, 0, src.ptd_amount), decode(sign(src.ptd_amount), -1, -src.ptd_amount, 0),';
         ELSE
           l_merge_statement := l_merge_statement || '
              null,
              null, null,';
         END IF;

         l_merge_statement := l_merge_statement || '
              src.ytd_amount * ' || sign_value || ',
              decode(sign(src.ytd_amount), -1, 0, src.ytd_amount), decode(sign(src.ytd_amount), -1, -src.ytd_amount, 0),
              SYSDATE, :3, SYSDATE, :3, :4)
';

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_merge_statement = '|| l_merge_statement
                        );
      END IF;

         EXECUTE IMMEDIATE l_merge_statement
                     USING    p_entry_id,
                           p_entry_id,
                           l_intercompany_id,
                           l_threshold_amount,
                           l_category,
                           l_category,
                           fnd_global.user_id,
                           p_entry_id,
                           l_threshold_amount,
                           l_category,
                           l_category,
                           l_intercompany_id,
                           fnd_global.user_id,
                           fnd_global.user_id,
                           fnd_global.login_id;
  
      ELSIF secondary_dimension_column IS NOT NULL
      THEN
         l_merge_statement :=
               'MERGE INTO gcs_entry_lines gel
       USING (
SELECT :6 company_cost_center_org_id,

                     SUM (  NVL (gel_1.ytd_credit_balance_e, 0)
                          - NVL (gel_1.ytd_debit_balance_e, 0)) ytd_amount,
                     SUM (  NVL (gel_1.ptd_credit_balance_e, 0)
                          - NVL (gel_1.ptd_debit_balance_e, 0)) ptd_amount
FROM gcs_entry_lines gel_1
WHERE gel_1.entry_id = :2
GROUP BY '||secondary_dimension_column||'
HAVING SUM (  NVL (gel_1.ytd_credit_balance_e, 0) - NVL (gel_1.ytd_debit_balance_e, 0) ) <>0 ) src
        ON (    gel.entry_id = :2
 AND gel.line_type_code = ''CALCULATED'' )
   WHEN MATCHED THEN
      UPDATE
         SET gel.ytd_balance_e = gel.ytd_balance_e + ' || sign_value || ' * src.ytd_amount,
             gel.ytd_debit_balance_e = gel.ytd_debit_balance_e + decode(sign(src.ytd_amount), -1, 0, src.ytd_amount),
             gel.ytd_credit_balance_e = gel.ytd_credit_balance_e + decode(sign(src.ytd_amount), -1, -src.ytd_amount, 0),';

         IF l_category_type <> 'CONSOLIDATION_RULE' THEN
           l_merge_statement := l_merge_statement || '
             gel.xtd_balance_e = gel.xtd_balance_e + ' || sign_value || ' * src.ptd_amount,
             gel.ptd_debit_balance_e = gel.ptd_debit_balance_e + decode(sign(src.ptd_amount), -1, 0, src.ptd_amount),
             gel.ptd_credit_balance_e = gel.ptd_credit_balance_e + decode(sign(src.ptd_amount), -1, -src.ptd_amount, 0),';
         ELSE
           l_merge_statement := l_merge_statement || '
             gel.xtd_balance_e = null,
             gel.ptd_debit_balance_e = null,
             gel.ptd_credit_balance_e = null,';
         END IF;

         l_merge_statement := l_merge_statement || '
             gel.last_update_date = SYSDATE,
             gel.description = decode(sign(abs(gel.ytd_balance_e + src.ytd_amount)-nvl(:11, 0)), 1, decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_EXCEEDED''),
      decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_LINE'')),
             gel.last_updated_by = :3
   WHEN NOT MATCHED THEN
      INSERT (entry_id, description,  gel.xtd_balance_e,
              gel.ptd_debit_balance_e, gel.ptd_credit_balance_e,
              gel.ytd_balance_e, gel.ytd_debit_balance_e, gel.ytd_credit_balance_e,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (:2, decode(sign(abs(src.ytd_amount)-nvl(:11, 0)), 1, decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_EXCEEDED''),
      decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_LINE'')),  ';

         IF l_category_type <> 'CONSOLIDATION_RULE' THEN
           l_merge_statement := l_merge_statement || '
              src.ptd_amount * ' || sign_value || ', src.ytd_amount * ' || sign_value || ',
              decode(sign(src.ptd_amount), -1, 0, src.ptd_amount), decode(sign(src.ptd_amount), -1, -src.ptd_amount, 0),';
         ELSE
           l_merge_statement := l_merge_statement || '
              null,
              null, null,';
         END IF;

         --Bugfix 6193096: Merge Statement is incorrectly defined
         l_merge_statement := l_merge_statement || '
              src.ytd_amount * ' || sign_value || ',
              decode(sign(src.ytd_amount), -1, 0, src.ytd_amount), decode(sign(src.ytd_amount), -1, -src.ytd_amount, 0),
              SYSDATE, :3, SYSDATE, :3, :4)
';

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_merge_statement = '|| l_merge_statement
                        );
      END IF;

         EXECUTE IMMEDIATE l_merge_statement
                     USING l_org_id,
                              p_entry_id,
                           p_entry_id,
                           l_intercompany_id,
                           l_threshold_amount,
                           l_category,
                           l_category,
                           fnd_global.user_id,
                           p_entry_id,
                           l_threshold_amount,
                           l_category,
                           l_category,
                           l_intercompany_id,
                           fnd_global.user_id,
                           fnd_global.user_id,
                           fnd_global.login_id;
      ELSIF org_tracking_flag = 'Y'
      THEN
         l_merge_statement :=
               'MERGE INTO gcs_entry_lines gel
     USING (SELECT   gel_1.company_cost_center_org_id,              SUM (  NVL (gel_1.ytd_credit_balance_e, 0)
                          - NVL (gel_1.ytd_debit_balance_e, 0)
                         ) ytd_amount,
                     SUM (  NVL (gel_1.ptd_credit_balance_e, 0)
                          - NVL (gel_1.ptd_debit_balance_e, 0)
                         ) ptd_amount
FROM gcs_entry_lines gel_1
WHERE gel_1.entry_id = :2
GROUP BY company_cost_center_org_id
HAVING SUM (  NVL (gel_1.ytd_credit_balance_e, 0) - NVL (gel_1.ytd_debit_balance_e, 0) ) <>0 ) src
        ON (    gel.entry_id = :2
 AND gel.line_type_code = ''CALCULATED'' )
   WHEN MATCHED THEN
      UPDATE
         SET gel.ytd_balance_e = gel.ytd_balance_e + ' || sign_value || ' * src.ytd_amount,
             gel.ytd_debit_balance_e = gel.ytd_debit_balance_e + decode(sign(src.ytd_amount), -1, 0, src.ytd_amount),
             gel.ytd_credit_balance_e = gel.ytd_credit_balance_e + decode(sign(src.ytd_amount), -1, -src.ytd_amount, 0),';

         IF l_category_type <> 'CONSOLIDATION_RULE' THEN
           l_merge_statement := l_merge_statement || '
             gel.xtd_balance_e = gel.xtd_balance_e + ' || sign_value || ' * src.ptd_amount,
             gel.ptd_debit_balance_e = gel.ptd_debit_balance_e + decode(sign(src.ptd_amount), -1, 0, src.ptd_amount),
             gel.ptd_credit_balance_e = gel.ptd_credit_balance_e + decode(sign(src.ptd_amount), -1, -src.ptd_amount, 0),';
         ELSE
           l_merge_statement := l_merge_statement || '
             gel.xtd_balance_e = null,
             gel.ptd_debit_balance_e = null,
             gel.ptd_credit_balance_e = null,';
         END IF;

         l_merge_statement := l_merge_statement || '
             gel.last_update_date = SYSDATE,
             gel.description = decode(sign(abs(gel.ytd_balance_e + src.ytd_amount)-nvl(:11, 0)), 1, decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_EXCEEDED''),
      decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_LINE'')),
             gel.last_updated_by = :5
   WHEN NOT MATCHED THEN
      INSERT (entry_id, description,  gel.xtd_balance_e,
              gel.ptd_debit_balance_e, gel.ptd_credit_balance_e,
              gel.ytd_balance_e, gel.ytd_debit_balance_e, gel.ytd_credit_balance_e,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (:2, decode(sign(abs(src.ytd_amount)-nvl(:11, 0)), 1, decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_EXCEEDED''),
      decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_LINE'')),  ';

         IF l_category_type <> 'CONSOLIDATION_RULE' THEN
           l_merge_statement := l_merge_statement || '
              src.ptd_amount * ' || sign_value || ',
              decode(sign(src.ptd_amount), -1, 0, src.ptd_amount), decode(sign(src.ptd_amount), -1, -src.ptd_amount, 0),';
         ELSE
           l_merge_statement := l_merge_statement || '
              null,
              null, null,';
         END IF;

         l_merge_statement := l_merge_statement || '
              src.ytd_amount * ' || sign_value || ',
              decode(sign(src.ytd_amount), -1, 0, src.ytd_amount), decode(sign(src.ytd_amount), -1, -src.ytd_amount, 0),
              SYSDATE, :3, SYSDATE, :3, :4)
';

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_merge_statement = '|| l_merge_statement
                        );
      END IF;

         EXECUTE IMMEDIATE l_merge_statement
                     USING    p_entry_id,
                           p_entry_id,
                           l_intercompany_id,
                           l_threshold_amount,
                           l_category,
                           l_category,
                           fnd_global.user_id,
                           p_entry_id,
                           l_threshold_amount,
                           l_category,
                           l_category,
                           l_intercompany_id,
                           fnd_global.user_id,
                           fnd_global.user_id,
                           fnd_global.login_id;
  
      ELSE
         l_merge_statement :=
               'MERGE INTO gcs_entry_lines gel
     USING (SELECT   :4 company_cost_center_org_id,  
                  SUM (  NVL (gel_1.ytd_credit_balance_e, 0)
                          - NVL (gel_1.ytd_debit_balance_e, 0)
                         ) ytd_amount,
                  SUM (  NVL (gel_1.ptd_credit_balance_e, 0)
                          - NVL (gel_1.ptd_debit_balance_e, 0)
                         ) ptd_amount
FROM gcs_entry_lines gel_1
WHERE gel_1.entry_id = :2
HAVING SUM (  NVL (gel_1.ytd_credit_balance_e, 0) - NVL (gel_1.ytd_debit_balance_e, 0) ) <>0 ) src
        ON (    gel.entry_id = :2
 AND gel.line_type_code = ''CALCULATED'' )
   WHEN MATCHED THEN
      UPDATE
         SET gel.ytd_balance_e = gel.ytd_balance_e + ' || sign_value || ' * src.ytd_amount,
             gel.ytd_debit_balance_e = gel.ytd_debit_balance_e + decode(sign(src.ytd_amount), -1, 0, src.ytd_amount),
             gel.ytd_credit_balance_e = gel.ytd_credit_balance_e + decode(sign(src.ytd_amount), -1, -src.ytd_amount, 0),';

         IF l_category_type <> 'CONSOLIDATION_RULE' THEN
           l_merge_statement := l_merge_statement || '
             gel.xtd_balance_e = gel.xtd_balance_e + ' || sign_value || ' * src.ptd_amount,
             gel.ptd_debit_balance_e = gel.ptd_debit_balance_e + decode(sign(src.ptd_amount), -1, 0, src.ptd_amount),
             gel.ptd_credit_balance_e = gel.ptd_credit_balance_e + decode(sign(src.ptd_amount), -1, -src.ptd_amount, 0),';
         ELSE
           l_merge_statement := l_merge_statement || '
             gel.xtd_balance_e = null,
             gel.ptd_debit_balance_e = null,
             gel.ptd_credit_balance_e = null,';
         END IF;

         l_merge_statement := l_merge_statement || '
             gel.last_update_date = SYSDATE,
             gel.description = decode(sign(abs(gel.ytd_balance_e + src.ytd_amount)-nvl(:11, 0)), 1, decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_EXCEEDED''),
      decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_LINE'')),
             gel.last_updated_by = :5
   WHEN NOT MATCHED THEN
      INSERT (entry_id, description,  gel.xtd_balance_e,
              gel.ptd_debit_balance_e, gel.ptd_credit_balance_e,
              gel.ytd_balance_e, gel.ytd_debit_balance_e, gel.ytd_credit_balance_e,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (:2, decode(sign(abs(src.ytd_amount)-nvl(:11,0)), 1, decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_EXCEEDED''),
      decode(:CATEGORY, ''TRANSLATION'', ''CTA_LINE'', ''SUSPENSE_LINE'')),  ';

         IF l_category_type <> 'CONSOLIDATION_RULE' THEN
           l_merge_statement := l_merge_statement || '
              src.ptd_amount * ' || sign_value || ',
              decode(sign(src.ptd_amount), -1, 0, src.ptd_amount), decode(sign(src.ptd_amount), -1, -src.ptd_amount, 0),';
         ELSE
           l_merge_statement := l_merge_statement || '
              null,
              null, null,';
         END IF;

         l_merge_statement := l_merge_statement || '
              src.ytd_amount * ' || sign_value || ',
              decode(sign(src.ytd_amount), -1, 0, src.ytd_amount), decode(sign(src.ytd_amount), -1, -src.ytd_amount, 0),
              SYSDATE, :3, SYSDATE, :3, :4)
';

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'l_merge_statement = '|| l_merge_statement
                        );
      END IF;

         EXECUTE IMMEDIATE l_merge_statement
                     USING l_org_id,
                             p_entry_id,
                           p_entry_id,
                           l_intercompany_id,
                           l_threshold_amount,
                           l_category,
                           l_category,
                           fnd_global.user_id,
                           p_entry_id,
                           l_threshold_amount,
                           l_category,
                           l_category,
                           l_intercompany_id,
                           fnd_global.user_id,
                           fnd_global.user_id,
                           fnd_global.login_id;
      END IF;

         BEGIN
         SELECT 'Y'
         INTO l_threshold_passed_flag
         FROM dual
         WHERE EXISTS(
                SELECT 'X'
                FROM gcs_entry_lines
                WHERE entry_id = p_entry_id
                AND description = 'SUSPENSE_EXCEEDED');

         UPDATE gcs_entry_lines
         SET description = 'SUSPENSE_LINE'
         WHERE description = 'SUSPENSE_EXCEEDED'
         AND entry_id = p_entry_id;

         EXCEPTION
         WHEN no_data_found THEN
            null;
         END;

         IF l_threshold_passed_flag = 'Y' THEN
         UPDATE gcs_entry_headers
            SET suspense_exceeded_flag = 'Y'
          WHERE entry_id = p_entry_id;
          END IF;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
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
      WHEN gcs_tmp_invalid_hierarchy
      THEN
         fnd_message.set_name ('GCS', 'GCS_TMP_NO_HIERARCHY');
         fnd_message.set_token ('ENTRY_ID', p_entry_id);

      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;

         RAISE gcs_tmp_balancing_failed;
      WHEN gcs_tmp_invalid_sign
      THEN
         fnd_message.set_name ('GCS', 'GCS_TMP_INVALID_SIGN');

        IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
        THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                              gcs_utility_pkg.g_module_failure
                           || ' '
                           || l_api_name
                           || '() '
                           || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                          );
        END IF;

        RAISE gcs_tmp_balancing_failed;
      WHEN OTHERS
      THEN
         fnd_file.put_line (fnd_file.LOG, SQLERRM);
         fnd_message.set_name ('GCS', 'GCS_TMP_UNEXPECTED');
      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                         || ' '
                         || l_api_name
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;


         RAISE gcs_tmp_balancing_failed;
   END balance;
END gcs_templates_dynamic_pkg;

/
