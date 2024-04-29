--------------------------------------------------------
--  DDL for Package Body JA_CN_AB_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_AB_EXP_PKG" AS
  --$Header: JACNABEB.pls 120.0.12000000.1 2007/08/13 14:09:04 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 1998 Oracle Corporation
  --|                       Redwood Shores, CA, USA
  --|                         All rights reserved.
  --+=======================================================================
  --| FILENAME
  --|     JACNABES.pls
  --|
  --| DESCRIPTION
  --|
  --|      This package is to provide share procedures for CNAO programs
  --|
  --| PROCEDURE LIST
  --|
  --|   PROCEDURE run_export
  --|
  --|
  --| HISTORY
  --|   01-May-2006     shujuan Yan Created
  --+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    run_export                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to export the account balances.
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf              Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode             Mandatory parameter for PL/SQL concurrent programs
  --      In         p_coa_id            Chart of Accounts Id
  --      In         p_ledger_id         Ledger Id
  --      In:        p_legal_entity      Legal entity ID
  --      In:        p_start_period      start period name
  --      In:        P_end_period        end period name
  --      In:        P_XML_TEMPLATE_LANGUAGE    template language of exception report
  --      In:        P_XML_TEMPLATE_TERRITORY   template territory of exception report
  --      In:        P_XML_OUTPUT_FORMAT        output format of exception report
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      07-May-2007     Shujuan Yan Created
  --
  --===========================================================================
  PROCEDURE Run_Export(errbuf                   OUT NOCOPY VARCHAR2
                      ,retcode                  OUT NOCOPY VARCHAR2
                      ,p_coa_id                 IN NUMBER
                      ,p_ledger_id              IN NUMBER
                      ,p_legal_entity           IN NUMBER
                      ,p_start_period           IN VARCHAR2
                      ,p_end_period             IN VARCHAR2
                      ,P_XML_TEMPLATE_LANGUAGE  IN VARCHAR2
                      ,P_XML_TEMPLATE_TERRITORY IN VARCHAR2
                      ,P_XML_OUTPUT_FORMAT      IN VARCHAR2) AS

    --variables start here
    l_module_name CONSTANT VARCHAR2(300) := 'JA_CN_AB_EXP_PKG.Run_Export';
    l_runtime_level   NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_procedure_level NUMBER := FND_LOG.LEVEL_PROCEDURE;
    l_statement_level NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_exception_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
    l_message         VARCHAR2(300);
    l_flag            VARCHAR2(15);
    l_number_a        NUMBER;
    l_number_b        NUMBER;

  --  l_set_of_books_id              ja_cn_system_parameters_all.legal_entity_id%TYPE;
    l_functional_currency          fnd_currencies_vl.NAME%TYPE;
    l_functional_currency_code     fnd_currencies_vl.CURRENCY_CODE%TYPE;
    --l_chart_of_accounts_id         gl_sets_of_books.chart_of_accounts_id%TYPE;
    l_flex_value_set_id            fnd_id_flex_segments.flex_value_set_id%TYPE;
    l_ja_cn_dff_assignments_row    ja_cn_dff_assignments%ROWTYPE;
    l_context_code                 ja_cn_dff_assignments.context_code%TYPE;
    l_attribute_column4cost_center ja_cn_dff_assignments.attribute_column%TYPE;
    l_attribute_column4third_party ja_cn_dff_assignments.attribute_column%TYPE;
    l_attribute_column4personnel   ja_cn_dff_assignments.attribute_column%TYPE;
    l_attribute_column4project     ja_cn_dff_assignments.attribute_column%TYPE;
    l_attribute_column4is_foreign  ja_cn_dff_assignments.attribute_column%TYPE;
    l_attribute_column4balanceside ja_cn_dff_assignments.attribute_column%TYPE;
    l_attribute_column4account_lev ja_cn_dff_assignments.attribute_column%TYPE;
    l_account_segment              ja_cn_journal_lines.account_segment%TYPE;
    l_ja_cn_subsidiary_gbl_tmp_row ja_cn_subsidiary_gt%ROWTYPE;
    l_account_balances_gbl_tmp_row ja_cn_account_balances_gt%ROWTYPE;
    l_sql_stmt                     VARCHAR2(30000) := '';

    l_sql_stmt4insert_j_line VARCHAR2(30000) := 'INSERT INTO ja_cn_account_balances_gt
                                                (account_segment,
                                                 currency_code,
                                                 func_begin_balance,
                                                 orig_begin_balance,
                                                 func_period_net_dr,
                                                 func_period_net_cr,
                                                 orig_period_net_dr,
                                                 orig_period_net_cr,
                                                 func_end_balance,
                                                 orig_end_balance,
                                                 period_mon,
                                                 PERIOD_NAME,
                                                 START_DATE,
                                                 has_third_party,
                                                 has_cost_center,
                                                 has_personnel,
                                                 has_project,
                                                 account_type,
                                                 is_foreign,
                                                 balance_side,
                                                 account_level
                                                 @COLUMN_CLAUSE
                                                )
                                                (SELECT ' ||
                                                prefix_a ||
                                                '.account_segment, ' ||
                                                prefix_b || '.name, ' ||
                                                prefix_a ||
                                                '.func_begin_balance,
                                                        ' ||
                                                prefix_a ||
                                                '.orig_begin_balance,
                                                        ' ||
                                                prefix_a ||
                                                '.func_period_net_dr,
                                                        ' ||
                                                prefix_a ||
                                                '.func_period_net_cr,
                                                        ' ||
                                                prefix_a ||
                                                '.orig_period_net_dr,
                                                        ' ||
                                                prefix_a ||
                                                '.orig_period_net_cr,
                                                        ' ||
                                                prefix_a ||
                                                '.func_end_balance,
                                                        ' ||
                                                prefix_a ||
                                                '.orig_end_balance,
                                                        ' ||
                                                prefix_a ||
                                                '.period_mon,
                                                        ' ||
                                                prefix_a ||
                                                '.PERIOD_NAME,:1,
                                                        s.has_third_party,
                                                        s.has_cost_center,
                                                        s.has_personnel,
                                                        s.has_project,
                                                         ' ||
                                                prefix_a ||
                                                '.account_type,s.is_foreign,s.balance_side,s.account_level
                                                        @PREFIX_COLUMN_CLAUSE ' || '
                                                   FROM (SELECT account_segment,
                                                                @CURRENCY_CLAUSE1
                                                                @SUM_CLAUSE
                                                                period_mon,
                                                                account_type,
                                                                PERIOD_NAME
                                                                @COLUMN_CLAUSE
                                                           FROM ja_cn_account_balances_v
                                                          WHERE period_name = :2
                                                            AND account_segment = :3
                                                            AND ledger_id = :4
                                                            AND company_segment IN
                                                                (SELECT bal_seg_value
                                                                   FROM ja_cn_ledger_le_bsv_gt
                                                                  WHERE legal_entity_id = :5)
                                                          GROUP BY account_segment,@CURRENCY_CLAUSE2 period_mon,account_type,PERIOD_NAME @COLUMN_CLAUSE) ' ||
                                                prefix_a ||
                                                ' LEFT JOIN ja_cn_subsidiary_gt s ON ' ||
                                                prefix_a ||
                                                '.account_segment =s.account_segment_value left join fnd_currencies_vl ' ||
                                                prefix_b || ' ON ' || prefix_a ||
                                                '.currency_code=' || prefix_b ||
                                                '.currency_code)';

    l_column_clauses        ja_cn_je_exp_pkg.assoc_array_varchar1000_type;
    l_prefix_column_clauses ja_cn_je_exp_pkg.assoc_array_varchar1000_type;
    l_column_clause         VARCHAR2(500);

    l_prefix_column_clause VARCHAR2(500);

    l_na_curr_req_id NUMBER;
    l_na_req_id      NUMBER;

    l_na_req_phase      fnd_lookup_values.meaning%TYPE;
    l_na_req_status     fnd_lookup_values.meaning%TYPE;
    l_na_req_dev_phase  VARCHAR2(30);
    l_na_req_dev_status VARCHAR2(30);
    l_na_req_message    VARCHAR2(100);

    l_xml_layout         BOOLEAN;
    l_template_language  VARCHAR2(10) := P_XML_TEMPLATE_LANGUAGE;
    l_template_territory VARCHAR2(10) := P_XML_TEMPLATE_TERRITORY;
    l_output_format      VARCHAR2(10) := P_XML_OUTPUT_FORMAT;

    l_start_date         DATE;
    l_end_date           DATE;
    l_current_period     GL_PERIOD_STATUSES.Period_Name%TYPE;
    l_current_start_date DATE;
    --exceptions start here
    --sob_unfetchable EXCEPTION;

    --cursors start here
    CURSOR c_in_ja_cn_dff_assignments IS
      SELECT *
        FROM ja_cn_dff_assignments
       WHERE chart_of_accounts_id = p_coa_id
          AND (dff_title_code = 'SACC'
               OR dff_title_code = 'SATP'
               OR dff_title_code = 'SAEE'
               OR dff_title_code = 'SAPA'
               OR dff_title_code = 'FCRA'
               OR dff_title_code = 'ACBS'
               OR dff_title_code = 'ACLE');

    CURSOR c_in_ja_cn_account_balances IS
      SELECT DISTINCT account_segment
        FROM ja_cn_account_balances_v
       WHERE company_segment IN
         (SELECT bal_seg_value--segment_value
                FROM ja_cn_ledger_le_bsv_gt--ja_cn_legal_companies_all
               WHERE legal_entity_id = p_legal_entity
               AND   chart_of_accounts_id = p_coa_id)
         AND period_name IN
             (SELECT period_name
                FROM GL_PERIOD_STATUSES
               WHERE ledger_id = p_ledger_id--set_of_books_id = l_set_of_books_id
                 AND application_id = 101
                 AND ((start_date BETWEEN l_start_date AND l_end_date) AND
                     (end_date BETWEEN l_start_date AND l_end_date)))
         AND ledger_id = p_ledger_id;--set_of_books_id = l_set_of_books_id;

    CURSOR c_in_ja_cn_subsidiary_gbl_tmp IS
      SELECT * FROM ja_cn_subsidiary_gt;

    CURSOR c_in_account_balances_gbl_tmp IS
      SELECT *
        FROM ja_cn_account_balances_gt
       ORDER BY start_date
               ,ACCOUNT_SEGMENT
               ,PROJECT_NUMBER
               ,THIRD_PARTY_NUMBER
               ,COST_CENTER
               ,PERSONNEL_NUMBER;

    CURSOR c_in_closed_periods IS
      SELECT period_name
        FROM GL_PERIOD_STATUSES
       WHERE ledger_id = p_ledger_id--set_of_books_id = l_set_of_books_id
         AND application_id = 101
         AND ((start_date BETWEEN l_start_date AND l_end_date) AND
             (end_date BETWEEN l_start_date AND l_end_date))
       ORDER BY start_date;

  BEGIN
    l_na_curr_req_id := FND_GLOBAL.CONC_REQUEST_ID;
    --log the parameters
    IF (l_procedure_level >= l_runtime_level) THEN

      FND_LOG.STRING(l_procedure_level,
                     l_module_name,
                     'Start to run ' || l_module_name ||
                     'with parameter: p_coa_id=' ||
                     nvl(to_char(p_coa_id), 'null') || ' p_ledger_id=' ||
                     nvl(to_char(p_ledger_id), 'null') || ' p_legal_entity=' ||
                     nvl(to_char(p_legal_entity), 'null') || ' p_start_period=' ||
                     nvl(to_char(p_start_period), 'null') || ' p_end_period=' ||
                     nvl(to_char(p_end_period), 'null'));

    END IF; --l_procedure_level >= l_runtime_level

    --call JA_CN_UTILITY.Check_Profile, if it doesn't return true, exit
    IF JA_CN_UTILITY.Check_Profile() <> TRUE THEN
      IF (l_exception_level >= l_runtime_level) THEN
        FND_LOG.STRING(l_exception_level,
                       l_module_name,
                       'Check profile failed!');
      END IF; --l_exception_level >= l_runtime_level
      retcode := 1;
      RETURN;
    END IF; --JA_CN_UTILITY.Check_Profile() != TRUE
     l_flag := Ja_Cn_Utility.Populate_Ledger_Le_Bsv_Gt(p_Ledger_Id,p_Legal_Entity);
    --call JA_CN_UTILITY.Check_Accounting_Period_Range, if it doesn't return true, exit
    IF ja_cn_utility.Check_Accounting_Period_Range(p_start_period,
                                                   p_end_period,
                                                   p_legal_entity,
                                                   p_ledger_id) <> TRUE THEN
      FND_MESSAGE.set_name('JA', 'JA_CN_PERIOD_OPEN');
      FND_MESSAGE.SET_TOKEN('PERIOD_FROM', p_start_period, TRUE);
      FND_MESSAGE.SET_TOKEN('PERIOD_TO', p_end_period, TRUE);
      l_message := FND_MESSAGE.get();
      FND_FILE.put_line(FND_FILE.LOG, l_message);

      IF (l_exception_level >= l_runtime_level) THEN
        FND_LOG.STRING(l_exception_level,
                       l_module_name,
                       'Check account period range failed!');
      END IF;
      retcode := 1;
      errbuf  := l_message;
      RETURN;
    END IF;

/*    --fetch set of books id and chart of account id
    JA_CN_UTILITY.Get_SOB_And_COA(p_legal_entity_id => p_legal_entity,
                                  x_sob_id          => l_set_of_books_id,
                                  x_coa_id          => l_chart_of_accounts_id,
                                  x_flag            => l_flag);

    IF l_flag = -1 THEN
      IF (l_exception_level >= l_runtime_level) THEN
        FND_LOG.STRING(l_exception_level,
                       l_module_name,
                       'Get SOB or COA failed!');
      END IF;
      retcode := 1;
      RETURN;
    END IF;

    --log the SOB
    IF (l_statement_level >= l_runtime_level) THEN
      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_set_of_books_id=' ||
                     nvl(to_char(l_set_of_books_id), 'null'));
    END IF;

    --log chat of account
    IF (l_statement_level >= l_runtime_level) THEN
      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_chart_of_accounts_id=' ||
                     nvl(to_char(l_chart_of_accounts_id), 'null'));
    END IF;
  */
    --fetch start data and end date
    SELECT start_date
      INTO l_start_date
      FROM GL_PERIOD_STATUSES
     WHERE ledger_id = p_ledger_id--set_of_books_id = l_set_of_books_id
       AND application_id = 101
       AND period_name = p_start_period;

    SELECT end_date
      INTO l_end_date
      FROM GL_PERIOD_STATUSES
     WHERE ledger_id = p_ledger_id--set_of_books_id = l_set_of_books_id
       AND application_id = 101
       AND period_name = p_end_period;

    --log start data and end date
    IF (l_statement_level >= l_runtime_level) THEN
      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: start date=' ||
                     nvl(to_char(l_start_date), 'null') || ' end date=' ||
                     nvl(to_char(l_end_date), 'null'));
    END IF;

    --fetch flex_value_set_id
    SELECT s.flex_value_set_id
      INTO l_flex_value_set_id
      FROM fnd_id_flex_segments s
     WHERE s.application_id = 101
       AND s.id_flex_num = p_coa_id--l_chart_of_accounts_id
       AND s.id_flex_code = 'GL#'
       AND s.application_column_name =
           (SELECT application_column_name
              FROM fnd_segment_attribute_values
             WHERE application_id = 101
               AND segment_attribute_type = 'GL_ACCOUNT'
               AND attribute_value = 'Y'
               AND id_flex_num = p_coa_id
               AND id_flex_code = 'GL#');--l_chart_of_accounts_id);

    --log
    IF (l_statement_level >= l_runtime_level) THEN
      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_flex_value_set_id=' ||
                     nvl(to_char(l_flex_value_set_id), 'null'));
    END IF; --l_statement_level >= l_runtime_level

    --fetch context code, attribute column for cost center, third party, personnel and project
    OPEN c_in_ja_cn_dff_assignments;
    LOOP
      FETCH c_in_ja_cn_dff_assignments
        INTO l_ja_cn_dff_assignments_row;
      EXIT WHEN c_in_ja_cn_dff_assignments%NOTFOUND;
      IF l_ja_cn_dff_assignments_row.context_code IS NOT NULL THEN
        l_context_code := l_ja_cn_dff_assignments_row.context_code;
      END IF; --l_ja_cn_dff_assignments_row.context_code IS NOT NULL
      CASE l_ja_cn_dff_assignments_row.dff_title_code
        WHEN 'SACC' THEN
          l_attribute_column4cost_center := l_ja_cn_dff_assignments_row.attribute_column;
        WHEN 'SATP' THEN
          l_attribute_column4third_party := l_ja_cn_dff_assignments_row.attribute_column;
        WHEN 'SAEE' THEN
          l_attribute_column4personnel := l_ja_cn_dff_assignments_row.attribute_column;
        WHEN 'SAPA' THEN
          l_attribute_column4project := l_ja_cn_dff_assignments_row.attribute_column;
        WHEN 'FCRA' THEN
          l_attribute_column4is_foreign := l_ja_cn_dff_assignments_row.attribute_column;
        WHEN 'ACBS' THEN
          l_attribute_column4balanceside := l_ja_cn_dff_assignments_row.attribute_column;
        WHEN 'ACLE' THEN
          l_attribute_column4account_lev := l_ja_cn_dff_assignments_row.attribute_column;
      END CASE; END LOOP;
    CLOSE c_in_ja_cn_dff_assignments;

    --log
    IF (l_statement_level >= l_runtime_level) THEN
      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_context_code=' ||
                     nvl(to_char(l_context_code), 'null'));
      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_attribute_column4cost_center=' ||
                     nvl(to_char(l_attribute_column4cost_center), 'null'));
      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_attribute_column4third_party=' ||
                     nvl(to_char(l_attribute_column4third_party), 'null'));

      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_attribute_column4personnel=' ||
                     nvl(to_char(l_attribute_column4personnel), 'null'));

      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_attribute_column4project=' ||
                     nvl(to_char(l_attribute_column4project), 'null'));

      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_attribute_column4is_foreign=' ||
                     nvl(to_char(l_attribute_column4is_foreign), 'null'));

      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_attribute_column4balanceside=' ||
                     nvl(to_char(l_attribute_column4balanceside), 'null'));

      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_attribute_column4account_lev=' ||
                     nvl(to_char(l_attribute_column4account_lev), 'null'));

    END IF; --l_statement_level >= l_runtime_level

    --fetch the account subsidiary info and save to temp table
    OPEN c_in_ja_cn_account_balances;

    --log
    IF (l_statement_level >= l_runtime_level) THEN
      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched account segments start below:');

    END IF; --l_statement_level >= l_runtime_level
    l_sql_stmt := 'insert into JA_CN_SUBSIDIARY_GT
                   (
                   ACCOUNT_SEGMENT_VALUE,
                   HAS_THIRD_PARTY,
                   HAS_COST_CENTER,
                   HAS_PERSONNEL,
                   HAS_PROJECT,
                   IS_FOREIGN,
                   BALANCE_SIDE,
                   account_level
                   )
                   select flex_value,' ||
                  nvl(to_char(l_attribute_column4third_party), 'null') || ',' ||
                  nvl(to_char(l_attribute_column4cost_center), 'null') || ',' ||
                  nvl(to_char(l_attribute_column4personnel), 'null') || ',' ||
                  nvl(to_char(l_attribute_column4project), 'null') || ',' ||
                  nvl(to_char(l_attribute_column4is_foreign), 'null') || ',' ||
                  nvl(to_char(l_attribute_column4balanceside), 'null') || ',' ||
                  nvl(to_char(l_attribute_column4account_lev), 'null') || '
                   from FND_FLEX_VALUES
                   where
                   flex_value_set_id=:1 and
                   flex_value=:2';
    --log
    /*IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(fnd_log.level_statement, l_module_name, l_sql_stmt);

    END IF;*/

    LOOP
      FETCH c_in_ja_cn_account_balances
        INTO l_account_segment;
      EXIT WHEN c_in_ja_cn_account_balances%NOTFOUND;
      --log
      IF (l_statement_level >= l_runtime_level) THEN
        FND_LOG.STRING(l_statement_level, l_module_name, l_account_segment);
      END IF; --l_statement_level >= l_runtime_level
      EXECUTE IMMEDIATE l_sql_stmt
        USING l_flex_value_set_id, l_account_segment;
    END LOOP;

    --no data found with the requested parameters
    IF (c_in_ja_cn_account_balances%ROWCOUNT = 0) THEN
      FND_MESSAGE.set_name('JA', 'JA_CN_NO_DATA_FOUND');
      l_message := FND_MESSAGE.get();
      FND_FILE.put_line(FND_FILE.output, l_message);
      IF (l_exception_level >= l_runtime_level) THEN
        FND_LOG.STRING(l_exception_level, l_module_name, l_message);
      END IF;
      retcode := 1;
      errbuf  := l_message;
      RETURN;
    END IF; --c_in_ja_cn_account_balances%ROWCOUNT = 0
    CLOSE c_in_ja_cn_account_balances;

    --fetch functional currency name
    SELECT fnd_currencies_vl.NAME
      INTO l_functional_currency
      FROM fnd_currencies_vl
     WHERE currency_code =
           (SELECT currency_code
              FROM gl_ledgers--gl_sets_of_books
             WHERE ledger_id = p_ledger_id);--set_of_books_id = l_set_of_books_id);

    --fetch functional currency code
    SELECT currency_code
      INTO l_functional_currency_code
      FROM gl_ledgers--gl_sets_of_books
     WHERE ledger_id = p_ledger_id;--set_of_books_id = l_set_of_books_id;

    --log currency name and currency code
    IF (l_statement_level >= l_runtime_level) THEN
      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_functional_currency=' ||
                     nvl(to_char(l_functional_currency), 'null'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, l_functional_currency);

    --combine the journal lines and save them to the JA_CN_JOURNAL_LINES_GBL_TMP
    OPEN c_in_closed_periods;
    LOOP
      FETCH c_in_closed_periods
        INTO l_current_period;
      EXIT WHEN c_in_closed_periods%NOTFOUND;

      --fetch start date of current period
      SELECT start_date
        INTO l_current_start_date
        FROM GL_PERIOD_STATUSES
       WHERE ledger_id = p_ledger_id--set_of_books_id = l_set_of_books_id
         AND application_id = 101
         AND period_name = l_current_period;

      --log current period and it's start date
      IF (l_statement_level >= l_runtime_level) THEN
        FND_LOG.STRING(l_statement_level,
                       l_module_name,
                       'about to generate journal lines info for period:' ||
                       l_current_period || ' start date:' ||
                       l_current_start_date);

      END IF;

      --FND_FILE.PUT_LINE(FND_FILE.LOG, l_current_start_date);

      OPEN c_in_ja_cn_subsidiary_gbl_tmp;
      LOOP
        FETCH c_in_ja_cn_subsidiary_gbl_tmp
          INTO l_ja_cn_subsidiary_gbl_tmp_row;
        EXIT WHEN c_in_ja_cn_subsidiary_gbl_tmp%NOTFOUND;
        --log
        IF (l_statement_level >= l_runtime_level) THEN
          FND_LOG.STRING(l_statement_level,
                         l_module_name,
                         'about to generate group clause for account:' ||
                         l_ja_cn_subsidiary_gbl_tmp_row.account_segment_value);

        END IF; --l_statement_level >= l_runtime_level

        JA_CN_JE_EXP_PKG.Gen_Clauses(l_column_clauses,
                                     l_prefix_column_clauses,
                                     l_ja_cn_subsidiary_gbl_tmp_row.has_cost_center,
                                     l_ja_cn_subsidiary_gbl_tmp_row.has_third_party,
                                     l_ja_cn_subsidiary_gbl_tmp_row.has_personnel,
                                     l_ja_cn_subsidiary_gbl_tmp_row.has_project,
                                     l_column_clause,
                                     l_prefix_column_clause);

        l_sql_stmt := REPLACE(l_sql_stmt4insert_j_line,
                              '@COLUMN_CLAUSE',
                              l_column_clause);
        l_sql_stmt := REPLACE(l_sql_stmt,
                              '@PREFIX_COLUMN_CLAUSE',
                              l_prefix_column_clause);

        --foreign currency disabled, the account is in functional currency, sum all the functional balances,
        --set foreign balances to zero, set functional currency to balance currency
        IF l_ja_cn_subsidiary_gbl_tmp_row.is_foreign IS NULL OR
           l_ja_cn_subsidiary_gbl_tmp_row.is_foreign =
           l_functional_currency_code THEN
          l_sql_stmt := REPLACE(l_sql_stmt,
                                '@CURRENCY_CLAUSE1',
                                '''' || l_functional_currency_code ||
                                ''' currency_code,');
          l_sql_stmt := REPLACE(l_sql_stmt, '@CURRENCY_CLAUSE2', ' ');
          l_sql_stmt := REPLACE(l_sql_stmt,
                                '@SUM_CLAUSE',
                                'SUM(FUNC_BEGIN_BALANCE) FUNC_BEGIN_BALANCE,
                            0 ORIG_BEGIN_BALANCE,
                            SUM(FUNC_PERIOD_NET_DR) FUNC_PERIOD_NET_DR,
                            SUM(FUNC_PERIOD_NET_CR) FUNC_PERIOD_NET_CR,
                            0 ORIG_PERIOD_NET_DR,
                            0 ORIG_PERIOD_NET_CR,
                            SUM(FUNC_END_BALANCE) FUNC_END_BALANCE,
                            0 ORIG_END_BALANCE,');
          --fnd_file.PUT_LINE(fnd_file.LOG,l_ja_cn_subsidiary_gbl_tmp_row.ACCOUNT_SEGMENT_VALUE);
          --foreign currency enabled
        ELSE
          l_sql_stmt := REPLACE(l_sql_stmt,
                                '@CURRENCY_CLAUSE1',
                                'currency_code,');
          l_sql_stmt := REPLACE(l_sql_stmt,
                                '@CURRENCY_CLAUSE2',
                                'currency_code,');
          l_sql_stmt := REPLACE(l_sql_stmt,
                                '@SUM_CLAUSE',
                                'SUM(func_begin_balance) func_begin_balance,
                           SUM(orig_begin_balance) orig_begin_balance,
                           SUM(func_period_net_dr) func_period_net_dr,
                           SUM(orig_period_net_dr) orig_period_net_dr,
                           SUM(func_period_net_cr) func_period_net_cr,
                           SUM(orig_period_net_cr) orig_period_net_cr,
                           SUM(func_end_balance) func_end_balance,
                           SUM(orig_end_balance) orig_end_balance,');
        END IF;
        /*IF l_ja_cn_subsidiary_gbl_tmp_row.account_segment_value = '6001' THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, l_sql_stmt);
        END IF;*/

        EXECUTE IMMEDIATE l_sql_stmt
          USING l_current_start_date, l_current_period, l_ja_cn_subsidiary_gbl_tmp_row.account_segment_value, p_ledger_id, p_legal_entity;
      END LOOP;
      CLOSE c_in_ja_cn_subsidiary_gbl_tmp;
    END LOOP;

    CLOSE c_in_closed_periods;

    --check error accounts, for those accounts which are foreign currency A enabled but have balances which are
    --not A and the begin and end balances are not zero.
    /*OPEN c_in_account_balances_gbl_tmp;
    LOOP
      FETCH c_in_account_balances_gbl_tmp
        INTO l_account_balances_gbl_tmp_row;
      EXIT WHEN c_in_account_balances_gbl_tmp%NOTFOUND;
      --is foreign account enabled
      --fnd_file.PUT_LINE(fnd_file.LOG,'is f: '||l_account_balances_gbl_tmp_row.is_foreign||' f c code: '||l_functional_currency_code);
      IF l_account_balances_gbl_tmp_row.is_foreign IS NOT NULL AND
         l_account_balances_gbl_tmp_row.is_foreign <>
         l_functional_currency_code THEN
        SELECT COUNT(*)
          INTO l_number_a
          FROM ja_cn_account_balances_gt
         WHERE account_segment = l_account_balances_gbl_tmp_row.account_segment
           AND nvl(COST_CENTER, 'NULL') =
               nvl(l_account_balances_gbl_tmp_row.COST_CENTER, 'NULL')
           AND nvl(THIRD_PARTY_NUMBER, 'NULL') =
               nvl(l_account_balances_gbl_tmp_row.THIRD_PARTY_NUMBER, 'NULL')
           AND nvl(PERSONNEL_NUMBER, 'NULL') =
               nvl(l_account_balances_gbl_tmp_row.PERSONNEL_NUMBER, 'NULL')
           AND nvl(PROJECT_NUMBER, 'NULL') =
               nvl(l_account_balances_gbl_tmp_row.PROJECT_NUMBER, 'NULL')
           AND currency_code <>
               (SELECT fnd_currencies_vl.NAME
                  FROM fnd_currencies_vl
                 WHERE currency_code = l_account_balances_gbl_tmp_row.is_foreign)
           AND FUNC_BEGIN_BALANCE <> 0
           AND FUNC_END_BALANCE <> 0;
        --fnd_file.PUT_LINE(fnd_file.LOG,l_number_a);
        IF l_number_a >= 1 THEN
          --error balance
          INSERT INTO JA_CN_ERROR_ACCOUNTS
            (request_id
            ,ACCOUNT_SEGMENT
            ,CURRENCY_CODE
            ,FUNC_BEGIN_BALANCE
            ,ORIG_BEGIN_BALANCE
            ,FUNC_PERIOD_NET_DR
            ,FUNC_PERIOD_NET_CR
            ,ORIG_PERIOD_NET_DR
            ,ORIG_PERIOD_NET_CR
            ,FUNC_END_BALANCE
            ,ORIG_END_BALANCE
            ,PERIOD_MON
            ,COST_CENTER
            ,THIRD_PARTY_NUMBER
            ,PERSONNEL_NUMBER
            ,PROJECT_NUMBER
            ,HAS_THIRD_PARTY
            ,HAS_COST_CENTER
            ,HAS_PERSONNEL
            ,HAS_PROJECT
            ,ACCOUNT_TYPE
            ,IS_FOREIGN
            ,BALANCE_SIDE
            ,ACCOUNT_LEVEL
            ,PERIOD_NAME
            ,START_DATE)
            SELECT l_na_curr_req_id
                  ,l_account_balances_gbl_tmp_row.account_segment
                  ,CURRENCY_CODE
                  ,FUNC_BEGIN_BALANCE
                  ,ORIG_BEGIN_BALANCE
                  ,FUNC_PERIOD_NET_DR
                  ,FUNC_PERIOD_NET_CR
                  ,ORIG_PERIOD_NET_DR
                  ,ORIG_PERIOD_NET_CR
                  ,FUNC_END_BALANCE
                  ,ORIG_END_BALANCE
                  ,PERIOD_MON
                  ,COST_CENTER
                  ,THIRD_PARTY_NUMBER
                  ,PERSONNEL_NUMBER
                  ,PROJECT_NUMBER
                  ,HAS_THIRD_PARTY
                  ,HAS_COST_CENTER
                  ,HAS_PERSONNEL
                  ,HAS_PROJECT
                  ,ACCOUNT_TYPE
                  ,IS_FOREIGN
                  ,BALANCE_SIDE
                  ,ACCOUNT_LEVEL
                  ,period_name
                  ,start_date
              FROM ja_cn_account_balances_gt
             WHERE account_segment =
                   l_account_balances_gbl_tmp_row.account_segment
               AND nvl(COST_CENTER, 'NULL') =
                   nvl(l_account_balances_gbl_tmp_row.COST_CENTER, 'NULL')
               AND nvl(THIRD_PARTY_NUMBER, 'NULL') =
                   nvl(l_account_balances_gbl_tmp_row.THIRD_PARTY_NUMBER,
                       'NULL')
               AND nvl(PERSONNEL_NUMBER, 'NULL') =
                   nvl(l_account_balances_gbl_tmp_row.PERSONNEL_NUMBER, 'NULL')
               AND nvl(PROJECT_NUMBER, 'NULL') =
                   nvl(l_account_balances_gbl_tmp_row.PROJECT_NUMBER, 'NULL')
               AND currency_code <>
                   (SELECT fnd_currencies_vl.NAME
                      FROM fnd_currencies_vl
                     WHERE currency_code =
                           l_account_balances_gbl_tmp_row.is_foreign)
               AND FUNC_BEGIN_BALANCE <> 0
               AND FUNC_END_BALANCE <> 0;

        END IF;
      END IF;
    END LOOP;
    CLOSE c_in_account_balances_gbl_tmp;*/

    OPEN c_in_ja_cn_subsidiary_gbl_tmp;
    LOOP
      FETCH c_in_ja_cn_subsidiary_gbl_tmp
        INTO l_ja_cn_subsidiary_gbl_tmp_row;
      EXIT WHEN c_in_ja_cn_subsidiary_gbl_tmp%NOTFOUND;
      --is foreign account enabled
      --fnd_file.PUT_LINE(fnd_file.LOG,'is f: '||l_account_balances_gbl_tmp_row.is_foreign||' f c code: '||l_functional_currency_code);
      IF l_ja_cn_subsidiary_gbl_tmp_row.is_foreign IS NOT NULL AND
         l_ja_cn_subsidiary_gbl_tmp_row.is_foreign <>
         l_functional_currency_code THEN
        INSERT INTO JA_CN_ERROR_ACCOUNTS
          (request_id
          ,ACCOUNT_SEGMENT
          ,CURRENCY_CODE
          ,FUNC_BEGIN_BALANCE
          ,ORIG_BEGIN_BALANCE
          ,FUNC_PERIOD_NET_DR
          ,FUNC_PERIOD_NET_CR
          ,ORIG_PERIOD_NET_DR
          ,ORIG_PERIOD_NET_CR
          ,FUNC_END_BALANCE
          ,ORIG_END_BALANCE
          ,PERIOD_MON
          ,COST_CENTER
          ,THIRD_PARTY_NUMBER
          ,PERSONNEL_NUMBER
          ,PROJECT_NUMBER
          ,HAS_THIRD_PARTY
          ,HAS_COST_CENTER
          ,HAS_PERSONNEL
          ,HAS_PROJECT
          ,ACCOUNT_TYPE
          ,IS_FOREIGN
          ,BALANCE_SIDE
          ,ACCOUNT_LEVEL
          ,PERIOD_NAME
          ,START_DATE)
          SELECT l_na_curr_req_id
                ,l_ja_cn_subsidiary_gbl_tmp_row.account_segment_value
                ,CURRENCY_CODE
                ,FUNC_BEGIN_BALANCE
                ,ORIG_BEGIN_BALANCE
                ,FUNC_PERIOD_NET_DR
                ,FUNC_PERIOD_NET_CR
                ,ORIG_PERIOD_NET_DR
                ,ORIG_PERIOD_NET_CR
                ,FUNC_END_BALANCE
                ,ORIG_END_BALANCE
                ,PERIOD_MON
                ,COST_CENTER
                ,THIRD_PARTY_NUMBER
                ,PERSONNEL_NUMBER
                ,PROJECT_NUMBER
                ,HAS_THIRD_PARTY
                ,HAS_COST_CENTER
                ,HAS_PERSONNEL
                ,HAS_PROJECT
                ,ACCOUNT_TYPE
                ,IS_FOREIGN
                ,BALANCE_SIDE
                ,ACCOUNT_LEVEL
                ,period_name
                ,start_date
            FROM ja_cn_account_balances_gt
           WHERE account_segment =
                 l_ja_cn_subsidiary_gbl_tmp_row.account_segment_value
             AND currency_code <>
                 (SELECT fnd_currencies_vl.NAME
                    FROM fnd_currencies_vl
                   WHERE currency_code =
                         l_ja_cn_subsidiary_gbl_tmp_row.is_foreign)
             AND FUNC_BEGIN_BALANCE <> 0
             AND FUNC_END_BALANCE <> 0;
      END IF;
    END LOOP;
    CLOSE c_in_ja_cn_subsidiary_gbl_tmp;

    --output error accounts if any
    SELECT COUNT(*)
      INTO l_number_b
      FROM JA_CN_ERROR_ACCOUNTS
     WHERE request_id = l_na_curr_req_id;
    IF l_number_b > 0 THEN
      l_xml_layout := FND_REQUEST.ADD_LAYOUT(template_appl_name => 'JA',
                                             template_code      => 'JACNABER',
                                             template_language  => l_template_language --'zh' ('en')
                                            ,
                                             template_territory => l_template_territory --'00' ('US')
                                            ,
                                             output_format      => l_output_format --'RTF' ('PDF')
                                             );
      l_na_req_id  := FND_REQUEST.Submit_Request(application => 'JA',
                                                 program     => 'JACNABER',
                                                 argument1   => l_na_curr_req_id,
                                                 argument2   => p_start_period,
                                                 argument3   => p_end_period);
      COMMIT;

      --Waiting for the 'Generating Natural Account Export Exception Report' completed.
      IF l_na_req_id <> 0 THEN
        IF FND_CONCURRENT.Wait_For_Request(request_id => l_na_req_id,
                                           INTERVAL   => 5,
                                           max_wait   => 0,
                                           phase      => l_na_req_phase,
                                           status     => l_na_req_status,
                                           dev_phase  => l_na_req_dev_phase,
                                           dev_status => l_na_req_dev_status,
                                           message    => l_na_req_message) THEN
          IF l_na_req_phase = 'Completed' THEN
            NULL;
          END IF; --l_na_req_phase = 'Completed'
        END IF; -- FND_CONCURRENT.Wait_For_Request ...
      END IF; --l_na_req_id<>0
      --DELETE rows with l_na_curr_req_id in TABLE JA_CN_ERROR_ACCOUNTS;
      DELETE FROM JA_CN_ERROR_ACCOUNTS WHERE REQUEST_ID = l_na_curr_req_id;
      retcode := 1;
      errbuf  := FND_MESSAGE.get;
      RETURN;
    END IF;

    --output
    OPEN c_in_account_balances_gbl_tmp;
    LOOP
      FETCH c_in_account_balances_gbl_tmp
        INTO l_account_balances_gbl_tmp_row;
      EXIT WHEN c_in_account_balances_gbl_tmp%NOTFOUND;
      --if acount level is not out of range, export
      IF JA_CN_UTILITY.Check_Account_Level(l_account_balances_gbl_tmp_row.account_level) THEN
        --modify the balance amount according to balance side
        IF l_account_balances_gbl_tmp_row.account_type = 'A' OR
           l_account_balances_gbl_tmp_row.account_type = 'E' THEN
          l_message := 'D';
        ELSE
          l_message := 'C';
        END IF;
        IF l_account_balances_gbl_tmp_row.balance_side IS NOT NULL AND
           l_message <> l_account_balances_gbl_tmp_row.balance_side THEN
          l_account_balances_gbl_tmp_row.func_begin_balance := l_account_balances_gbl_tmp_row.func_begin_balance * -1;
          l_account_balances_gbl_tmp_row.orig_begin_balance := l_account_balances_gbl_tmp_row.orig_begin_balance * -1;
          l_account_balances_gbl_tmp_row.func_end_balance   := l_account_balances_gbl_tmp_row.func_end_balance * -1;
          l_account_balances_gbl_tmp_row.orig_end_balance   := l_account_balances_gbl_tmp_row.orig_end_balance * -1;
        END IF;
        --if is functional currency, set original amounts to zero
        /*IF l_account_balances_gbl_tmp_row.CURRENCY_CODE = l_functional_currency THEN
          l_account_balances_gbl_tmp_row.orig_begin_balance := 0;
          l_account_balances_gbl_tmp_row.orig_period_net_dr := 0;
          l_account_balances_gbl_tmp_row.orig_period_net_cr := 0;
          l_account_balances_gbl_tmp_row.orig_end_balance   := 0;
        END IF;*/

        FND_FILE.put_line(FND_FILE.output,
                          '"' || l_account_balances_gbl_tmp_row.account_segment --account number
                          || '"' || FND_GLOBAL.Local_Chr(9) || '"' ||
                          l_account_balances_gbl_tmp_row.currency_code --currency
                          || '"' || FND_GLOBAL.Local_Chr(9) || '"' ||
                          JA_CN_JE_EXP_PKG.Get_Subsidiary_Desc(p_cost_center        => l_account_balances_gbl_tmp_row.cost_center,
                                                               p_third_party_number => l_account_balances_gbl_tmp_row.third_party_number,
                                                               p_personnel_number   => l_account_balances_gbl_tmp_row.personnel_number,
                                                               p_project_number     => l_account_balances_gbl_tmp_row.project_number,
                                                               p_has_cost_center    => l_account_balances_gbl_tmp_row.has_cost_center,
                                                               p_has_third_party    => l_account_balances_gbl_tmp_row.has_third_party,
                                                               p_has_personnel      => l_account_balances_gbl_tmp_row.has_personnel,
                                                               p_has_project        => l_account_balances_gbl_tmp_row.has_project) --subsidiary account group
                          || '"' || FND_GLOBAL.Local_Chr(9) || '' ||
                          TRIM(to_char(nvl(l_account_balances_gbl_tmp_row.func_begin_balance,
                                           0),
                                       '99999999999999999990.99')) --opening balance
                          || '' || FND_GLOBAL.Local_Chr(9) || '' || '0.00' --opening quantity
                          || '' || FND_GLOBAL.Local_Chr(9) || '' ||
                          TRIM(to_char(nvl(l_account_balances_gbl_tmp_row.orig_begin_balance,
                                           0),
                                       '99999999999999999990.99')) --opening foreign currency balance
                          || '' || FND_GLOBAL.Local_Chr(9) || '' ||
                          TRIM(to_char(nvl(l_account_balances_gbl_tmp_row.func_period_net_dr,
                                           0),
                                       '999999999999999990.99')) --period debit amount
                          || '' || FND_GLOBAL.Local_Chr(9) || '' || '0.00' --period debit quantity
                          || '' || FND_GLOBAL.Local_Chr(9) || '' ||
                          TRIM(to_char(nvl(l_account_balances_gbl_tmp_row.orig_period_net_dr,
                                           0),
                                       '999999999999999990.99')) --period foreign currency debit amount
                          || '' || FND_GLOBAL.Local_Chr(9) || '' ||
                          TRIM(to_char(nvl(l_account_balances_gbl_tmp_row.func_period_net_cr,
                                           0),
                                       '999999999999999990.99')) --period credit amount
                          || '' || FND_GLOBAL.Local_Chr(9) || '' || '0.00' --preiod credit quantity
                          || '' || FND_GLOBAL.Local_Chr(9) || '' ||
                          TRIM(to_char(nvl(l_account_balances_gbl_tmp_row.orig_period_net_cr,
                                           0),
                                       '999999999999999990.99')) --period foreign currency credit amount
                          || '' || FND_GLOBAL.Local_Chr(9) || '' ||
                          TRIM(to_char(nvl(l_account_balances_gbl_tmp_row.func_end_balance,
                                           0),
                                       '99999999999999999990.99')) --closing balance
                          || '' || FND_GLOBAL.Local_Chr(9) || '' || '0.00' --closing quantity
                          || '' || FND_GLOBAL.Local_Chr(9) || '' ||
                          TRIM(to_char(nvl(l_account_balances_gbl_tmp_row.orig_end_balance,
                                           0),
                                       '99999999999999999990.99')) --closing foreign currency balance
                          || '' || FND_GLOBAL.Local_Chr(9) || '"' ||
                          TRIM(to_char(l_account_balances_gbl_tmp_row.period_mon,
                                       '09')) --accounting month
                          || '"');
      END IF; --if JA_CN_UTILITY.Check_Account_Level(l_account_balances_gbl_tmp_row.balance_side)
    END LOOP;
    CLOSE c_in_account_balances_gbl_tmp;

    --log
    IF (l_procedure_level >= l_runtime_level) THEN

      FND_LOG.STRING(l_procedure_level,
                     l_module_name,
                     'Stop running ' || l_module_name);

    END IF;
  END Run_Export;

END JA_CN_AB_EXP_PKG;

/
