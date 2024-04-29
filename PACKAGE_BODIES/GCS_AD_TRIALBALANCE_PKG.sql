--------------------------------------------------------
--  DDL for Package Body GCS_AD_TRIALBALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_AD_TRIALBALANCE_PKG" AS
/* $Header: gcsadtbb.pls 120.3 2006/05/29 06:57:51 vkosuri noship $ */

   --
-- PRIVATE GLOBAL VARIABLES
--

   -- The API name
   g_pkg_name   VARCHAR2 (50) := 'gcs.plsql.GCS_AD_TRIALBALANCE_PKG';
   -- A newline character. Included for convenience when writing long strings.
   g_nl         VARCHAR2 (1)  := '
';

   import_header_error EXCEPTION;

---------------------------------------------------------------------------
--Bug fix 3843350 : populate elim_entity_id into the entry header
/*
** get_elim_entity_id
*/
   FUNCTION get_elim_entity_id (p_consolidation_entity_id IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR c_elim_entity
      IS
         SELECT dim_attribute_numeric_member
           FROM fem_entities_attr
          WHERE entity_id = p_consolidation_entity_id
            AND attribute_id =
                   gcs_utility_pkg.g_dimension_attr_info
                                               ('ENTITY_ID-ELIMINATION_ENTITY').attribute_id
            AND version_id =
                   gcs_utility_pkg.g_dimension_attr_info
                                               ('ENTITY_ID-ELIMINATION_ENTITY').version_id;

      l_elim_entity_id   NUMBER;
      l_api_name         VARCHAR2 (30) := 'GET_ELIM_ENTITY_ID';
   BEGIN
      OPEN c_elim_entity;

      FETCH c_elim_entity
       INTO l_elim_entity_id;

      CLOSE c_elim_entity;

      RETURN l_elim_entity_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Write the appropriate information to the execution report
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || SQLERRM
                            || ' '
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;

         RETURN 0;
   END get_elim_entity_id;

/*
** import_header
*/

   FUNCTION import_header (
      p_xns_id                    IN   NUMBER,
      p_entry_name                IN   VARCHAR2,
      p_description               IN   VARCHAR2,
      p_consideration_amount      IN   NUMBER,
      p_currency_code             IN   VARCHAR2,
      p_hierarchy_id              IN   NUMBER,
      p_entity_id                 IN   NUMBER,
      p_balance_type_code         IN   VARCHAR2,
      p_entry_type_code           IN   VARCHAR2 DEFAULT 'MANUAL'
   )
   RETURN NUMBER
   IS
      l_entry_id   NUMBER(15);
      l_new_entry_id   NUMBER(15);
      l_cal_period_id   NUMBER;
      l_year_to_apply_re   NUMBER (4)          := NULL;
      l_hierarchy_id    NUMBER(15);
      l_entity_id   NUMBER;
      l_errbuf           VARCHAR2 (200);
      l_retcode          VARCHAR2 (1);
      l_processed_entry_flag VARCHAR2 (1);
      l_api_name         VARCHAR2 (30)  := 'IMPORT_HEADER';
   BEGIN
      FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' ENTER');
      FND_FILE.NEW_LINE(FND_FILE.LOG);

      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' p_xns_id = '
                         || p_xns_id
                         || ' p_entry_name = '
                         || p_entry_name
                         || ' p_consideration_amount = '
                         || p_consideration_amount
                         || ' p_description = '
                         || p_description
                         || ' p_currency_code = '
                         || p_currency_code
                         || ' p_hierarchy_id = '
                         || p_hierarchy_id
                         || ' p_entity_id = '
                         || p_entity_id
                         || ' p_balance_type_code = '
                         || p_balance_type_code
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;

      -- select assoc_entry_id from gcs_ad_transactions table
      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'SELECT gat.assoc_entry_id, gat.cal_period_id, fcpa.number_assign_value + 1 '
                         || g_nl
                         || 'INTO l_entry_id, l_cal_period_id, l_year_to_apply_re '
                         || g_nl
                         || 'FROM fem_cal_periods_attr fcpa, gcs_ad_transactions gat'
                         || g_nl
                         || ' WHERE fcpa.cal_period_id = gat.cal_period_id
                                AND fcpa.attribute_id = ' ||
                gcs_utility_pkg.g_dimension_attr_info ('CAL_PERIOD_ID-ACCOUNTING_YEAR').attribute_id ||'
                                AND fcpa.version_id = ' ||
                gcs_utility_pkg.g_dimension_attr_info ('CAL_PERIOD_ID-ACCOUNTING_YEAR').version_id ||'
                         AND gat.AD_TRANSACTION_ID = '
                         || p_xns_id
                        );
      END IF;

      SELECT gat.assoc_entry_id, gat.cal_period_id, fcpa.number_assign_value + 1
        INTO l_entry_id, l_cal_period_id, l_year_to_apply_re
        FROM fem_cal_periods_attr fcpa, gcs_ad_transactions gat
       WHERE fcpa.cal_period_id = gat.cal_period_id
         AND fcpa.attribute_id =
                gcs_utility_pkg.g_dimension_attr_info ('CAL_PERIOD_ID-ACCOUNTING_YEAR').attribute_id
         AND fcpa.version_id =
                gcs_utility_pkg.g_dimension_attr_info ('CAL_PERIOD_ID-ACCOUNTING_YEAR').version_id
         AND gat.ad_transaction_id = p_xns_id;


      IF l_entry_id IS NULL
      THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' CREATE ENTRY');
        FND_FILE.NEW_LINE(FND_FILE.LOG);

         -- create an entry header if not exists
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'SELECT gcs_entry_headers_s.NEXTVAL'
                            || g_nl
                            || 'INTO l_entry_id'
                            || g_nl
                            || 'FROM dual'
                           );
         END IF;

         SELECT gcs_entry_headers_s.NEXTVAL
           INTO l_entry_id
           FROM DUAL;

         gcs_entry_pkg.insert_entry_header
                                 (p_entry_id                 => l_entry_id,
                                  p_hierarchy_id             => p_hierarchy_id,
                                  p_entity_id                => p_entity_id,
                                  p_year_to_apply_re         => l_year_to_apply_re,
                                  p_start_cal_period_id      => l_cal_period_id,
                                  p_end_cal_period_id        => NULL,
                                  p_entry_type_code          => p_entry_type_code,
                                  p_balance_type_code        => p_balance_type_code,
                                  p_currency_code            => p_currency_code,
                                  p_process_code             => 'ALL_RUN_FOR_PERIOD',
                                  p_description              => p_description,
                                  p_entry_name               => p_entry_name,
                                  p_category_code            => 'ACQ_DISP',
                                  x_errbuf                   => l_errbuf,
                                  x_retcode                  => l_retcode
                                 );

         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'UPDATE gcs_ad_transactions'
                            || g_nl
                            || 'SET ASSOC_ENTRY_ID = '
                            || l_entry_id
                            || ', total_consideration = '
                            || p_consideration_amount
                            || g_nl
                            || ', last_update_date = sysdate'
                            || g_nl
                            || 'WHERE AD_TRANSACTION_ID = '
                            || p_xns_id
                           );
         END IF;

         UPDATE gcs_ad_transactions
            SET assoc_entry_id = l_entry_id,
                total_consideration = p_consideration_amount,
                last_update_date = sysdate
          WHERE ad_transaction_id = p_xns_id;
      ELSE
         -- case 2: update an existing entry which has never been process before
         -- we simply update this entry
         BEGIN
            SELECT 'Y'
              INTO l_processed_entry_flag
              FROM DUAL
             WHERE EXISTS (SELECT run_detail_id
                             FROM gcs_cons_eng_run_dtls gcerd
                            WHERE gcerd.entry_id = l_entry_id);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' UPDATE EXISTING ENTRY');
                FND_FILE.NEW_LINE(FND_FILE.LOG);

            IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
            THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'UPDATE gcs_entry_headers'
                            || g_nl
                            || 'SET entry_name = '
                            || p_entry_name
                            || g_nl
                            || ', description = '
                            || p_description
                            || ', balance_type_code = '
                            || p_balance_type_code
                            || g_nl
                            || ', last_update_date = sysdate'
                            || g_nl
                            || 'WHERE entry_id = '
                            || l_entry_id
                           );
            END IF;

            UPDATE gcs_entry_headers
               SET entry_name = p_entry_name,
                   description = p_description,
                   balance_type_code = p_balance_type_code,
                   last_update_date = sysdate
             WHERE entry_id = l_entry_id;
            END;

            IF p_consideration_amount is not null THEN
            -- update total_consideration in gcs_ad_transactions table
                IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
                THEN
                fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'UPDATE gcs_ad_transactions'
                         || g_nl
                         || 'SET total_consideration = '
                         || p_consideration_amount
                         || g_nl
                         || ', last_update_date = sysdate'
                         || g_nl
                         || 'WHERE AD_TRANSACTION_ID = '
                         || p_xns_id
                        );
                END IF;

                UPDATE gcs_ad_transactions
                   SET total_consideration = p_consideration_amount,
                       last_update_date = sysdate
                 WHERE ad_transaction_id = p_xns_id;
            END IF;

      END IF;

      -- case 3: update an existing entry which has been process before
      -- we disable the existing entry and create a new one
      IF l_processed_entry_flag = 'Y'
      THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' DISABLE EXISTING ENTRY AND CREATE A NEW ONE');
      FND_FILE.NEW_LINE(FND_FILE.LOG);

         -- create a new entry header
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'SELECT gcs_entry_headers_s.NEXTVAL'
                            || g_nl
                            || 'INTO l_new_entry_id'
                            || g_nl
                            || 'FROM dual'
                           );
         END IF;

         SELECT gcs_entry_headers_s.NEXTVAL
           INTO l_new_entry_id
           FROM DUAL;

            IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
            THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'UPDATE gcs_entry_headers'
                            || g_nl
                            || 'SET disabled_flag = ''Y'''
                            || g_nl
                            || ',entry_name = substr(entry_name, 0, 55) || '' OLD ->'' || '
                            || l_new_entry_id
                            || ', last_update_date = sysdate '
                            || g_nl
                            || 'WHERE entry_id = '
                            || l_entry_id
                           );
            END IF;

            UPDATE gcs_entry_headers
               SET disabled_flag = 'Y',
                   entry_name = substr(entry_name, 0, 55) || ' OLD ->' || l_new_entry_id,
                   last_update_date = sysdate
             WHERE entry_id = l_entry_id;

         l_entry_id := l_new_entry_id;

         gcs_entry_pkg.insert_entry_header
                                 (p_entry_id                 => l_entry_id,
                                  p_hierarchy_id             => p_hierarchy_id,
                                  p_entity_id                => p_entity_id,
                                  p_year_to_apply_re         => l_year_to_apply_re,
                                  p_start_cal_period_id      => l_cal_period_id,
                                  p_end_cal_period_id        => NULL,
                                  p_entry_type_code          => p_entry_type_code,
                                  p_balance_type_code        => p_balance_type_code,
                                  p_currency_code            => p_currency_code,
                                  p_process_code             => 'ALL_RUN_FOR_PERIOD',
                                  p_description              => p_description,
                                  p_entry_name               => p_entry_name,
                                  p_category_code            => 'ACQ_DISP',
                                  x_errbuf                   => l_errbuf,
                                  x_retcode                  => l_retcode
                                 );

         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'UPDATE gcs_ad_transactions'
                            || g_nl
                            || 'SET ASSOC_ENTRY_ID = '
                            || l_entry_id
                            || ', total_consideration = '
                            || p_consideration_amount
                            || g_nl
                            || ', last_update_date = sysdate'
                            || g_nl
                            || 'WHERE AD_TRANSACTION_ID = '
                            || p_xns_id
                           );
         END IF;

         UPDATE gcs_ad_transactions
            SET assoc_entry_id = l_entry_id,
                total_consideration = p_consideration_amount,
                last_update_date = sysdate
          WHERE ad_transaction_id = p_xns_id;

      END IF;                                                 -- end of case 3

      FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' EXIT');
      FND_FILE.NEW_LINE(FND_FILE.LOG);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
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

      RETURN l_entry_id;

   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         fnd_message.set_name ('GCS', 'GCS_AD_TB_INVALID_ID');

         FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || SQLERRM);
         FND_FILE.NEW_LINE(FND_FILE.LOG);

         -- Write the appropriate information to the execution report
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || l_api_name
                            || '() ' || SQLERRM
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
         RETURN -1;
      WHEN OTHERS
      THEN
         fnd_message.set_name ('GCS', SQLERRM);

         FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || SQLERRM);
         FND_FILE.NEW_LINE(FND_FILE.LOG);

         -- Write the appropriate information to the execution report
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || l_api_name
                            || '() ' || SQLERRM
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
      RETURN -1;
   END import_header;

--
-- PUBLIC PROCEDURES
--
---------------------------------------------------------------------------
/*
** upload_header
*/
-- Bug fix : 5169619  -- data type of p_xns_id(_char) changed to VARCHAR2
   PROCEDURE upload_header (
      p_consolidation_entity_id   IN   NUMBER,
      p_hierarchy_id              IN   NUMBER,
      p_transaction_date          IN   VARCHAR2,
      p_currency_code             IN   VARCHAR2,
      p_xns_id_char               IN   VARCHAR2,
      p_category_code             IN   VARCHAR2,
      p_template_type             IN   VARCHAR2,
      p_entry_name                IN   VARCHAR2,
      p_operating_entity_id       IN   NUMBER,
      p_consideration_amount      IN   NUMBER,
      p_description               IN   VARCHAR2
   )
   IS
   BEGIN
      NULL;
   END upload_header;

---------------------------------------------------------------------------
/*
** import_entry
*/

-- Bug fix : 5169619  -- data type of p_xns_id(_char) changed to VARCHAR2

   PROCEDURE import_entry (
      x_errbuf    OUT NOCOPY      VARCHAR2,
      x_retcode   OUT NOCOPY      VARCHAR2,
      p_xns_id_char               IN   VARCHAR2,
      p_entry_name                IN   VARCHAR2,
      p_description               IN   VARCHAR2,
      p_consideration_amount      IN   NUMBER,
      p_currency_code             IN   VARCHAR2,
      p_hierarchy_id              IN   NUMBER,
      p_consolidation_entity_id   IN   NUMBER,
      p_operating_entity_id       IN   NUMBER
   )
   IS
      l_api_name   		VARCHAR2 (30) := 'IMPORT_ENTRY';
      l_entry_id   		NUMBER (15);
      l_orig_entry_id   	NUMBER (15);
      l_event_name         	VARCHAR2 (100) := 'oracle.apps.gcs.transaction.acqdisp.update';
      l_event_key          	VARCHAR2 (100)      := NULL;
      l_parameter_list     	wf_parameter_list_t;
      l_balance_type_code 	VARCHAR2 (30);
      l_elim_entity_id 		NUMBER;
      l_org_code 		VARCHAR2 (30);
      p_xns_id      NUMBER(15) := TO_NUMBER(p_xns_id_char);

      l_line_item_vs_id		NUMBER	:=
                                     gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id;
      l_ext_acct_type_attr      NUMBER  :=
            			     gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id;
      l_ext_acct_type_version   NUMBER  :=
            			     gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id;
      l_basic_acct_type_attr	NUMBER  :=
            			     gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id;
      l_basic_acct_type_version NUMBER  :=
				     gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id;
   BEGIN

      FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' ENTER');
      FND_FILE.NEW_LINE(FND_FILE.LOG);

      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' p_xns_id = '
                         || p_xns_id
                         || ' p_entry_name = '
                         || p_entry_name
                         || ' p_consideration_amount = '
                         || p_consideration_amount
                         || ' p_description = '
                         || p_description
                         || ' p_currency_code = '
                         || p_currency_code
                         || ' p_hierarchy_id = '
                         || p_hierarchy_id
                         || ' p_consolidation_entity_id = '
                         || p_consolidation_entity_id
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'select assoc_entry_id into l_orig_entry_id from gcs_ad_transactions
                            where ad_transaction_id = '
                            || p_xns_id
                           );
       END IF;

      select assoc_entry_id
      into l_orig_entry_id
      from gcs_ad_transactions
      where ad_transaction_id = p_xns_id;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'select decode(count(entry_id), 0, ''ACTUAL'', ''ADB'') into l_balance_type_code
      from gcs_entry_lines where entry_id = -1 and financial_elem_id = 140'
                           );
       END IF;
      select decode(count(entry_id), 0, 'ACTUAL', 'ADB')
      into l_balance_type_code
      from gcs_entry_lines
      where entry_id = -1
       and financial_elem_id = 140;

      l_elim_entity_id := get_elim_entity_id(p_consolidation_entity_id => p_consolidation_entity_id);

      l_entry_id := import_header(
              p_xns_id => p_xns_id,
              p_entry_name => p_entry_name,
              p_consideration_amount => p_consideration_amount,
              p_description => p_description,
              p_currency_code => p_currency_code,
              p_hierarchy_id => p_hierarchy_id,
              p_entity_id => l_elim_entity_id,
              p_balance_type_code => l_balance_type_code
        );

      IF l_entry_id < 0 THEN
        RAISE import_header_error;
      END IF;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'delete from gcs_entry_lines'
                            || g_nl
                            || 'where entry_id = '
                            || l_entry_id
                           );
       END IF;

       DELETE FROM gcs_entry_lines
             WHERE entry_id = l_entry_id;


      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'update gcs_entry_lines'
                            || g_nl
                            || 'set entry_id = '
                            || l_entry_id
                            || ', last_update_date = sysdate,'
             || g_nl
             || ' line_type_code = decode((SELECT feata.dim_attribute_varchar_member
                              FROM fem_ext_acct_types_attr feata,
                                   fem_ln_items_attr flia
                             WHERE gcs_entry_lines.line_item_id =
                                                             flia.line_item_id
                               AND flia.value_set_id =' ||
                                      gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id || '
                               AND flia.attribute_id = '||
            gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id || '
                               AND flia.version_id = '||
            gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id || '
                               AND feata.attribute_id = '||
            gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id || '
                               AND feata.version_id = '||
            gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id || '
                               AND feata.ext_account_type_code =
                                             flia.dim_attribute_varchar_member), ''REVENUE'', ''PROFIT_LOSS'',
                                ''EXPENSE'', ''PROFIT_LOSS'', ''BALANCE_SHEET'') '
                            || g_nl
                            || 'where entry_id = -1'
                           );
      END IF;

      --Bugfix 4332257 : Resolved the Issue with YTD_BALANCE_E not being populated
      UPDATE gcs_entry_lines
         SET 	entry_id 		= l_entry_id,
             	last_update_date 	= sysdate,
		ytd_balance_e		= NVL(ytd_debit_balance_e, 0) - NVL(ytd_credit_balance_e, 0),
                line_type_code 		= decode(
                         		(SELECT feata.dim_attribute_varchar_member
                              		 FROM 	fem_ext_acct_types_attr feata,
                                   		fem_ln_items_attr flia
                             		 WHERE 	gcs_entry_lines.line_item_id 	= 	flia.line_item_id
                               		 AND 	flia.value_set_id 		=	l_line_item_vs_id
                               		 AND 	flia.attribute_id 		=	l_ext_acct_type_attr
                               		 AND 	flia.version_id 		=	l_ext_acct_type_version
                               		 AND 	feata.attribute_id 		=	l_basic_acct_type_attr
                               		 AND 	feata.version_id 		=	l_basic_acct_type_version
                               		 AND 	feata.ext_account_type_code     =       flia.dim_attribute_varchar_member
					), 'REVENUE', 'PROFIT_LOSS', 'EXPENSE', 'PROFIT_LOSS', 'BALANCE_SHEET'
					)
       WHERE entry_id = -1;

      --Bugfix 4411633 : retained earnings should write to child base org
     IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                            'SELECT org_output_code INTO l_org_code '
                            || 'FROM gcs_categories_b WHERE category_code = ''ACQ_DISP'''
                           );
      END IF;

      SELECT org_output_code
        INTO l_org_code
        FROM gcs_categories_b
       WHERE category_code = 'ACQ_DISP';

      IF (l_org_code = 'CHILD_BASE_ORG') THEN
          gcs_templates_dynamic_pkg.calculate_re
                                          (p_entry_id           => l_entry_id,
                                           p_hierarchy_id       => p_hierarchy_id,
                                           p_bal_type_code      => l_balance_type_code,
                                           p_entity_id          => p_operating_entity_id
                                          );
      ELSE
          gcs_templates_dynamic_pkg.calculate_re
                                          (p_entry_id           => l_entry_id,
                                           p_hierarchy_id       => p_hierarchy_id,
                                           p_bal_type_code      => l_balance_type_code,
                                           p_entity_id          => l_elim_entity_id
                                          );
      END IF;
      --end of Bugfix 4411633

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'update gcs_ad_transactions'
                            || g_nl
                            || 'set request_id = '
                            || fnd_global.conc_request_id
                            || g_nl
                            || ', last_update_date = sysdate'
                            || g_nl
                            || 'where ad_transaction_id = ' || p_xns_id
                           );
      END IF;
      UPDATE gcs_ad_transactions
         SET request_id = fnd_global.conc_request_id,
             last_update_date = sysdate
       WHERE ad_transaction_id = p_xns_id;
/*
      BEGIN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' Calling entry XML Gen ');
         FND_FILE.NEW_LINE(FND_FILE.LOG);

         gcs_xml_gen_pkg.generate_entry_xml( p_entry_id => l_entry_id,
                p_category_code => 'ACQ_DISP',
                p_cons_rule_flag => 'N');
      EXCEPTION
      WHEN OTHERS
      THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' Generate XML error : ' || SQLERRM);
         FND_FILE.NEW_LINE(FND_FILE.LOG);

         -- Write the appropriate information to the execution report
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' entry XML Gen failed: '
                            || SQLERRM
                            || ' '
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
      END;
*/
      BEGIN
      IF (NVL(l_orig_entry_id,-1) <> l_entry_id) THEN

        IF (l_orig_entry_id IS NULL) THEN
           wf_event.addparametertolist(	p_name               => 'CHANGE_TYPE_CODE',
                                   	p_value              => 'NEW_ACQDISP',
                                   	p_parameterlist      => l_parameter_list
                                  	);
        ELSE
          wf_event.addparametertolist( 	p_name               => 'CHANGE_TYPE_CODE',
                                   	p_value              => 'ACQDISP_MODIFIED',
                                   	p_parameterlist      => l_parameter_list
                                  	);
        END IF;
        wf_event.addparametertolist(	p_name               => 'ENTRY_ID',
                                   	p_value              => l_entry_id,
                                   	p_parameterlist      => l_parameter_list
                                  	);
        wf_event.addparametertolist( 	p_name               => 'ORIG_ENTRY_ID',
                                   	p_value              => l_orig_entry_id,
                                   	p_parameterlist      => l_parameter_list
                                  	);
        FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' RAISE WF_EVENT');
        FND_FILE.NEW_LINE(FND_FILE.LOG);

        wf_event.RAISE(			p_event_name      => l_event_name,
                      			p_event_key       => l_event_key,
                      			p_parameters      => l_parameter_list
                     			);
      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' Raise impact error : ' || SQLERRM);
         FND_FILE.NEW_LINE(FND_FILE.LOG);

         -- Write the appropriate information to the execution report
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || SQLERRM
                            || ' '
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
      END;

      x_retcode := fnd_api.g_ret_sts_success;

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

      FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' EXIT');
      FND_FILE.NEW_LINE(FND_FILE.LOG);

   EXCEPTION
      WHEN import_header_error
      THEN
         x_errbuf := fnd_message.get;
         x_retcode := '2';

         FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' ERROR : ' || x_errbuf);
         FND_FILE.NEW_LINE(FND_FILE.LOG);
         -- Write the appropriate information to the execution report
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || x_errbuf
                            || ' '
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
      WHEN OTHERS
      THEN
         fnd_message.set_name ('GCS', SQLERRM);
         x_errbuf := fnd_message.get;
         x_retcode := '2';

         FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' ERROR : ' || x_errbuf);
         FND_FILE.NEW_LINE(FND_FILE.LOG);

         -- Write the appropriate information to the execution report
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || x_errbuf
                            || ' '
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
   END import_entry;

---------------------------------------------------------------------------
/*
** import
*/

-- Bug fix : 5169619  -- data type of p_xns_id(_char) changed to VARCHAR2
   PROCEDURE import (
      x_errbuf    OUT NOCOPY      VARCHAR2,
      x_retcode   OUT NOCOPY      VARCHAR2,
      p_xns_id_char               IN   VARCHAR2,
      p_entry_name                IN   VARCHAR2,
      p_description               IN   VARCHAR2,
      p_consideration_amount      IN   NUMBER,
      p_currency_code             IN   VARCHAR2,
      p_hierarchy_id              IN   NUMBER,
      p_consolidation_entity_id   IN   NUMBER
   )
   IS
      l_api_name   VARCHAR2 (30) := 'IMPORT';
      l_entry_id   NUMBER (15);
      l_orig_entry_id NUMBER (15);
      l_event_name         VARCHAR2 (100)
                           := 'oracle.apps.gcs.transaction.acqdisp.update';
      l_event_key          VARCHAR2 (100)      := NULL;
      l_parameter_list     wf_parameter_list_t;
      l_elim_entity_id NUMBER;
      l_balance_type_code VARCHAR2 (30);
      p_xns_id            NUMBER(15) := TO_NUMBER(p_xns_id_char) ;
   BEGIN
      FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' ENTER');
      FND_FILE.NEW_LINE(FND_FILE.LOG);

      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' p_xns_id = '
                         || p_xns_id
                         || ' p_entry_name = '
                         || p_entry_name
                         || ' p_consideration_amount = '
                         || p_consideration_amount
                         || ' p_description = '
                         || p_description
                         || ' p_currency_code = '
                         || p_currency_code
                         || ' p_hierarchy_id = '
                         || p_hierarchy_id
                         || ' p_consolidation_entity_id = '
                         || p_consolidation_entity_id
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;

      select assoc_entry_id
      into l_orig_entry_id
      from gcs_ad_transactions
      where ad_transaction_id = p_xns_id;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'Original entry id = ' || l_orig_entry_id
                           );
       END IF;

      select decode(count(ad_transaction_id), 0, 'ACTUAL', 'ADB')
      into l_balance_type_code
      from gcs_ad_trial_balances
      where ad_transaction_id = -1
       and financial_elem_id = 140;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'Balance type code is ' || l_balance_type_code
                           );
       END IF;

      l_elim_entity_id := get_elim_entity_id(p_consolidation_entity_id => p_consolidation_entity_id);

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'Elimination entity id = ' || l_elim_entity_id
                           );
       END IF;

      l_entry_id := import_header(
              p_xns_id => p_xns_id,
              p_entry_name => p_entry_name,
              p_consideration_amount => p_consideration_amount,
              p_description => p_description,
              p_currency_code => p_currency_code,
              p_hierarchy_id => p_hierarchy_id,
              p_entity_id => l_elim_entity_id,
              p_balance_type_code => l_balance_type_code,
              p_entry_type_code => 'AUTOMATIC'
        );

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_pkg_name || '.' || l_api_name,
                               'New entry id = ' || l_entry_id
                           );
       END IF;

      IF l_entry_id < 0 THEN
        RAISE import_header_error;
      END IF;

      -- Delete the existing trial balances
      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'DELETE FROM GCS_AD_TRIAL_BALANCES'
                         || g_nl
                         || 'WHERE AD_TRANSACTION_ID = '
                         || p_xns_id
                        );
      END IF;

      DELETE FROM gcs_ad_trial_balances
            WHERE ad_transaction_id = p_xns_id;

      -- Update the new load
      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'UPDATE GCS_AD_TRIAL_BALANCES'
                         || g_nl
                         || 'SET ad_transaction_id = '
                         || p_xns_id
                         || ', last_update_date = sysdate'
                         || g_nl
                         || 'WHERE AD_TRANSACTION_ID = -1'
                        );
      END IF;

      UPDATE gcs_ad_trial_balances
         SET ad_transaction_id = p_xns_id,
             last_update_date = sysdate
       WHERE ad_transaction_id = -1;
/*
      BEGIN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' Calling trial balance XML Gen ');
         FND_FILE.NEW_LINE(FND_FILE.LOG);

         gcs_xml_gen_pkg.generate_ad_xml( p_ad_transaction_id => p_xns_id);

      EXCEPTION
      WHEN OTHERS
      THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' Generate trial balance XML error : ' || SQLERRM);
         FND_FILE.NEW_LINE(FND_FILE.LOG);

         -- Write the appropriate information to the execution report
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' XML Gen failed: '
                            || SQLERRM
                            || ' '
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
      END;
*/
      -- invoke ad engine
      FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' CALL AD_ENGINE');
      FND_FILE.NEW_LINE(FND_FILE.LOG);

      gcs_ad_engine.process_transaction (errbuf                => x_errbuf,
                                         retcode               => x_retcode,
                                         p_transaction_id      => p_xns_id
                                        );
      -- bug fix 3870797
      IF (x_retcode = '2') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' AD_ENGINE FAILED: ' || x_errbuf);
        FND_FILE.NEW_LINE(FND_FILE.LOG);
           -- Write the appropriate information to the execution report
              IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
              THEN
                 fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                            || ' AD_ENGINE failed '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
              END IF;
      ELSE
/*        BEGIN
          FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' Calling entry XML Gen ');
          FND_FILE.NEW_LINE(FND_FILE.LOG);

          gcs_xml_gen_pkg.generate_entry_xml( p_entry_id => l_entry_id,
                p_category_code => 'ACQ_DISP',
                p_cons_rule_flag => 'N');
        EXCEPTION
        WHEN OTHERS
        THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' Generate entry XML error : ' || SQLERRM);
          FND_FILE.NEW_LINE(FND_FILE.LOG);

          -- Write the appropriate information to the execution report
          IF fnd_log.g_current_runtime_level <= fnd_log.level_error
          THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' XML Gen failed: '
                            || SQLERRM
                            || ' '
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
          END IF;
        END;*/

        BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' Raise Impact Analysis Event');
        FND_FILE.NEW_LINE(FND_FILE.LOG);

        IF (l_orig_entry_id <> l_entry_id) THEN

          IF (l_orig_entry_id IS NULL) THEN
            wf_event.addparametertolist (p_name               => 'CHANGE_TYPE_CODE',
                                   p_value              => 'NEW_ACQDISP',
                                   p_parameterlist      => l_parameter_list
                                  );
          ELSE
            wf_event.addparametertolist (p_name               => 'CHANGE_TYPE_CODE',
                                   p_value              => 'ACQDISP_MODIFIED',
                                   p_parameterlist      => l_parameter_list
                                  );
          END IF;
          wf_event.addparametertolist (p_name               => 'ENTRY_ID',
                                   p_value              => l_entry_id,
                                   p_parameterlist      => l_parameter_list
                                  );
          wf_event.addparametertolist (p_name               => 'ORIG_ENTRY_ID',
                                   p_value              => l_orig_entry_id,
                                   p_parameterlist      => l_parameter_list
                                  );
          wf_event.RAISE (p_event_name      => l_event_name,
                      p_event_key       => l_event_key,
                      p_parameters      => l_parameter_list
                     );
        END IF;

        EXCEPTION
        WHEN OTHERS
        THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' Raise impact error : ' || SQLERRM);
         FND_FILE.NEW_LINE(FND_FILE.LOG);

         -- Write the appropriate information to the execution report
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || SQLERRM
                            || ' '
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
        END;

        x_retcode := fnd_api.g_ret_sts_success;

        FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' EXIT');
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        -- Write the appropriate information to the execution report
        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
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
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK TO gcs_ad_tb_import_start;
         fnd_message.set_name ('GCS', SQLERRM);
         x_errbuf := fnd_message.get;
         x_retcode := '2';

         FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' ERROR : ' || x_errbuf);
         FND_FILE.NEW_LINE(FND_FILE.LOG);

         -- Write the appropriate information to the execution report
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || x_errbuf
                            || '() '
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
   END import;

   --
   -- Procedure
   --   undo_elim_adj
   -- Purpose
   --   An API to undo an elimination adjustment
   -- Arguments
   -- Notes
   --
   PROCEDURE undo_elim_adj (
      p_xns_id     IN              NUMBER,
      x_errbuf     OUT NOCOPY      VARCHAR2,
      x_retcode    OUT NOCOPY      VARCHAR2
   )
   IS
      cursor undo_c is
            SELECT decode(NVL(gcerd.run_detail_id, 0), 0, 'N', 'Y'), xns.assoc_entry_id
              FROM gcs_ad_transactions xns, gcs_cons_eng_run_dtls gcerd
             WHERE xns.ad_transaction_id = p_xns_id
             and gcerd.entry_id (+) = xns.assoc_entry_id;

      l_processed_flag VARCHAR2 (1);
      l_entry_id       NUMBER   (15);
      l_event_name         VARCHAR2 (100)
                           := 'oracle.apps.gcs.transaction.acqdisp.update';
      l_event_key          VARCHAR2 (100)      := NULL;
      l_parameter_list     wf_parameter_list_t;
      l_api_name   VARCHAR2 (30) := 'UNDO_ELIM_ADJ';
   BEGIN
      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' p_xns_id = '
                         || p_xns_id
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;

      open undo_c;
      fetch undo_c into l_processed_flag, l_entry_id;
      close undo_c;

      if (l_processed_flag = 'Y') then
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'UPDATE gcs_entry_headers set disabled_flag = ''Y'' WHERE entry_id = '
                         || l_entry_id
                        );
         END IF;
         update gcs_entry_headers set disabled_flag = 'Y' where entry_id = l_entry_id;
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'UPDATE gcs_ad_transactions set assoc_entry_id = null, request_id = null WHERE ad_transaction_id = '
                         || p_xns_id
                        );
         END IF;
         update gcs_ad_transactions set assoc_entry_id = null, request_id = null where ad_transaction_id = p_xns_id;

         begin
         wf_event.addparametertolist (p_name               => 'CHANGE_TYPE_CODE',
                                   p_value              => 'ACQDISP_UNDONE',
                                   p_parameterlist      => l_parameter_list
                                  );
         wf_event.addparametertolist (p_name               => 'ENTRY_ID',
                                   p_value              => l_entry_id,
                                   p_parameterlist      => l_parameter_list
                                  );
         wf_event.addparametertolist (p_name               => 'ORIG_ENTRY_ID',
                                   p_value              => NULL,
                                   p_parameterlist      => l_parameter_list
                                  );
         EXCEPTION
         WHEN OTHERS THEN
           null;
         END;

      elsif (l_processed_flag = 'N' and l_entry_id is not null) then
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'DELETE FROM gcs_entry_headers WHERE entry_id = '
                         || l_entry_id
                        );
         END IF;
         delete from gcs_entry_headers where entry_id = l_entry_id;
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'DELETE FROM gcs_entry_lines WHERE entry_id = '
                         || l_entry_id
                        );
         END IF;
         delete from gcs_entry_lines where entry_id = l_entry_id;
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'UPDATE gcs_ad_transactions set assoc_entry_id = null, request_id = null WHERE ad_transaction_id = '
                         || p_xns_id
                        );
         END IF;
         update gcs_ad_transactions set assoc_entry_id = null, request_id = null where ad_transaction_id = p_xns_id;
        ELSE
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            'UPDATE gcs_ad_transactions set request_id = null WHERE ad_transaction_id = '
                         || p_xns_id
                        );
         END IF;
         update gcs_ad_transactions set request_id = null where ad_transaction_id = p_xns_id;
      end if;

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
      WHEN OTHERS
      THEN
         x_errbuf := SQLERRM;
         x_retcode := fnd_api.g_ret_sts_unexp_error;

         -- Write the appropriate information to the execution report
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || x_errbuf
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
   END undo_elim_adj;

END gcs_ad_trialbalance_pkg;

/
