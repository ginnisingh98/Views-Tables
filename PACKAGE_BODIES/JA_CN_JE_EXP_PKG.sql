--------------------------------------------------------
--  DDL for Package Body JA_CN_JE_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_JE_EXP_PKG" AS
  --$Header: JACNJEEB.pls 120.0.12000000.1 2007/08/13 14:09:43 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 1998 Oracle Corporation
  --|                       Redwood Shores, CA, USA
  --|                         All rights reserved.
  --+=======================================================================
  --| FILENAME
  --|     JACNJEES.pls
  --|
  --| DESCRIPTION
  --|
  --|      This package is to provide share procedures for CNAO programs
  --|
  --| PROCEDURE LIST
  --|
  --|   PROCEDURE run_export
  --|   PROCEDURE gen_clauses
  --|   FUNCTION get_subsidiary_desc
  --|
  --|
  --| HISTORY
  --|   07-May-2006     Shujuan Yan Created
  --|
  --+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    run_export                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to export the journal entries.
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf                     Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode                    Mandatory parameter for PL/SQL concurrent programs
  --      In         p_coa_id                   Chart of Accounts Id
  --      In         p_ledger_id                Ledger Id
  --      In:        p_legal_entity             Legal entity ID
  --      In:        p_start_period             start period name
  --      In:        P_end_period               end period name
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      07-May-2006     Shujuan Yan Created
  --
  --===========================================================================

  PROCEDURE Run_Export(errbuf         OUT NOCOPY VARCHAR2
                      ,retcode        OUT NOCOPY VARCHAR2
                      ,p_coa_id       IN NUMBER
                      ,p_ledger_id    IN NUMBER
                      ,p_legal_entity_id IN NUMBER
                      ,p_start_period IN VARCHAR2
                      ,p_end_period   IN VARCHAR2) IS

    --variables start here
    l_runtime_level   NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_procedure_level NUMBER := FND_LOG.LEVEL_PROCEDURE;
    l_statement_level NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_exception_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
    l_flag            VARCHAR2(15);

    l_module_name CONSTANT VARCHAR2(300) := 'JA_CN_JE_EXP_PKG.Run_Export';
    l_message                      VARCHAR2(300);
    --l_set_of_books_id              ja_cn_system_parameters_all.legal_entity_id%TYPE;
    --l_chart_of_accounts_id         gl_sets_of_books.chart_of_accounts_id%TYPE;
    l_flex_value_set_id            fnd_id_flex_segments.flex_value_set_id%TYPE;
    l_ja_cn_dff_assignments_row    ja_cn_dff_assignments%ROWTYPE;
    l_context_code                 ja_cn_dff_assignments.context_code%TYPE;
    l_attribute_column4cost_center ja_cn_dff_assignments.attribute_column%TYPE;
    l_attribute_column4third_party ja_cn_dff_assignments.attribute_column%TYPE;
    l_attribute_column4personnel   ja_cn_dff_assignments.attribute_column%TYPE;
    l_attribute_column4project     ja_cn_dff_assignments.attribute_column%TYPE;
    l_account_segment              ja_cn_journal_lines.account_segment%TYPE;
    l_ja_cn_subsidiary_gbl_tmp_row ja_cn_subsidiary_gt%ROWTYPE;
    l_journal_lines_gbl_tmp_row    ja_cn_journal_lines_gt%ROWTYPE;
    l_sql_stmt                     VARCHAR2(30000) := '';
    l_journal_number               ja_cn_journal_lines_gt.journal_number%TYPE := '';
    l_journal_line_number          NUMBER := 0;
    l_functional_currency          fnd_currencies_vl.NAME%TYPE;

    l_start_date         DATE;
    l_end_date           DATE;
    l_current_period     GL_PERIOD_STATUSES.Period_Name%TYPE;
    l_current_start_date DATE;

    l_sql_stmt4insert_j_line CONSTANT VARCHAR2(30000) := 'INSERT INTO ja_cn_journal_lines_gt
                                                (journal_number,
                                                 je_category,
                                                 description,
                                                 default_effective_date,
                                                 je_line_num,
                                                 account_segment_value,
                                                 accounted_dr,
                                                 accounted_cr,
                                                 entered_dr,
                                                 entered_cr,
                                                 currency_code,
                                                 currency_conversion_rate,
                                                 journal_preparer,
                                                 JOURNAL_APPROVER,
                                                 JOURNAL_POSTER,
                                                 PERIOD_NAME,
                                                 START_DATE,
                                                 has_third_party,
                                                 has_cost_center,
                                                 has_personnel,
                                                 has_project
                                                 @COLUMN_CLAUSE)

                                                SELECT ' ||
                                                         prefix_a ||
                                                         '.journal_number,' ||
                                                         prefix_b ||
                                                         '.USER_JE_CATEGORY_NAME,' ||
                                                         prefix_a ||
                                                         '.description,' ||
                                                         prefix_a ||
                                                         '.default_effective_date,' ||
                                                         prefix_a ||
                                                         '.je_line_num,' ||
                                                         prefix_a ||
                                                         '.account_segment,' ||
                                                         prefix_a ||
                                                         '.accounted_dr,' ||
                                                         prefix_a ||
                                                         '.accounted_cr,' ||
                                                         prefix_a ||
                                                         '.entered_dr,' ||
                                                         prefix_a ||
                                                         '.entered_cr,' ||
                                                         prefix_c || '.name,' ||
                                                         prefix_a ||
                                                         '.currency_conversion_rate,' ||
                                                         prefix_a ||
                                                         '.JOURNAL_CREATOR,' ||
                                                         prefix_a ||
                                                         '.JOURNAL_APPROVER,' ||
                                                         prefix_a ||
                                                         '.JOURNAL_POSTER,' ||
                                                         prefix_a ||
                                                         '.PERIOD_NAME, :1,
                                                s.has_third_party,
                                                s.has_cost_center,
                                                s.has_personnel,
                                                s.has_project
                                                @PREFIX_COLUMN_CLAUSE
                                                FROM (SELECT journal_number,
                                                             je_category,
                                                             description,
                                                             default_effective_date,
                                                             je_line_num,
                                                             account_segment,
                                                             SUM(accounted_dr) accounted_dr,
                                                             SUM(accounted_cr) accounted_cr,
                                                             SUM(entered_dr) entered_dr,
                                                             SUM(entered_cr) entered_cr,
                                                             currency_code,
                                                             currency_conversion_rate,
                                                             JOURNAL_CREATOR,
                                                             JOURNAL_APPROVER,
                                                             JOURNAL_POSTER,
                                                             PERIOD_NAME
                                                             @COLUMN_CLAUSE
                                                        FROM ja_cn_journal_lines
                                                       WHERE period_name = :2
                                                             AND account_segment = :3
                                                             @AND_CONDITION
                                                             AND ledger_id = :4
                                                         AND company_segment IN
                                                             (SELECT bal_seg_value
                                                                FROM ja_cn_ledger_le_bsv_gt
                                                               WHERE legal_entity_id = :5)
                                                       GROUP BY journal_number,
                                                                account_segment,
                                                                je_category,
                                                                description,
                                                                default_effective_date,
                                                                je_line_num,
                                                                currency_code,
                                                                currency_conversion_rate,
                                                                JOURNAL_CREATOR,
                                                                JOURNAL_APPROVER,
                                                                JOURNAL_POSTER,
                                                                period_name
                                                                @COLUMN_CLAUSE
                                                                ) ' ||
                                                         prefix_a ||
                                                         ' left join JA_CN_SUBSIDIARY_GT s on ' ||
                                                         prefix_a ||
                                                         '.account_segment=s.ACCOUNT_SEGMENT_VALUE' ||
                                                         ' LEFT JOIN gl_je_categories_vl ' ||
                                                         prefix_b || ' ON ' ||
                                                         prefix_a ||
                                                         '.je_category=' ||
                                                         prefix_b ||
                                                         '.JE_CATEGORY_NAME' ||
                                                         ' LEFT JOIN fnd_currencies_vl ' ||
                                                         prefix_c || ' ON ' ||
                                                         prefix_a ||
                                                         '.currency_code=' ||
                                                         prefix_c ||
                                                         '.currency_code ';

    l_column_clauses        assoc_array_varchar1000_type;
    l_prefix_column_clauses assoc_array_varchar1000_type;
    l_column_clause         VARCHAR2(500);
    l_prefix_column_clause  VARCHAR2(500);

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
              OR dff_title_code = 'SAPA');

    CURSOR c_in_ja_cn_journal_lines IS
      SELECT DISTINCT account_segment
        FROM ja_cn_journal_lines
       WHERE company_segment IN
             (SELECT bal_seg_value--segment_value
                FROM ja_cn_ledger_le_bsv_gt--ja_cn_legal_companies_all
               WHERE legal_entity_id = p_legal_entity_id
               AND   chart_of_accounts_id = p_coa_id)
         AND period_name IN
             (SELECT period_name
                FROM GL_PERIOD_STATUSES
               WHERE ledger_id = p_ledger_id
                 AND application_id = 101
                 AND ((start_date BETWEEN l_start_date AND l_end_date) AND
                     (end_date BETWEEN l_start_date AND l_end_date)))
         AND ledger_id = p_ledger_id;--set_of_books_id = l_set_of_books_id;

    CURSOR c_in_ja_cn_subsidiary_gbl_tmp IS
      SELECT * FROM ja_cn_subsidiary_gt;

    CURSOR c_in_journal_lines_gbl_tmp IS
      SELECT *
        FROM ja_cn_journal_lines_gt
       ORDER BY start_date, to_number(journal_number), to_number(je_line_num);

    CURSOR c_in_closed_periods IS
      SELECT period_name
        FROM GL_PERIOD_STATUSES
       WHERE ledger_id = p_ledger_id--set_of_books_id = l_set_of_books_id
         AND application_id = 101
         AND ((start_date BETWEEN l_start_date AND l_end_date) AND
             (end_date BETWEEN l_start_date AND l_end_date))
       ORDER BY start_date;

  BEGIN

    --log the parameters
    IF (l_procedure_level >= l_runtime_level) THEN

      FND_LOG.STRING(l_procedure_level,
                     l_module_name,
                     'Start to run ' || l_module_name ||
                     'with parameter: p_coa_id=' ||
                     nvl(to_char(p_coa_id), 'null') || ' p_ledger_id=' ||
                     nvl(to_char(p_ledger_id), 'null') || ' p_legal_entity_id=' ||
                     nvl(to_char(p_legal_entity_id), 'null') || ' p_start_period=' ||
                     nvl(to_char(p_start_period), 'null') || ' p_end_period=' ||
                     nvl(to_char(p_end_period), 'null'));

    END IF;

    --call JA_CN_UTILITY.Check_Profile, if it doesn't return true, exit
    IF JA_CN_UTILITY.Check_Profile() <> TRUE THEN
      IF (l_exception_level >= l_runtime_level) THEN
        FND_LOG.STRING(l_exception_level,
                       l_module_name,
                       'Check profile failed!');
      END IF;
      retcode := 1;
      RETURN;
    END IF;

    l_flag := Ja_Cn_Utility.Populate_Ledger_Le_Bsv_Gt(p_Ledger_Id,p_Legal_Entity_Id);

    --call JA_CN_UTILITY.Check_Accounting_Period_Range, if it doesn't return true, exit
    IF ja_cn_utility.Check_Accounting_Period_Range(p_start_period,
                                                   p_end_period,
                                                   p_legal_entity_id,
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
 /*
    --fetch set of books id and chart of account id
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
     WHERE ledger_id = p_ledger_id --set_of_books_id = l_set_of_books_id
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
    END IF;

    --fetch context code, attribute column for cost center, third party, personnel and project
    OPEN c_in_ja_cn_dff_assignments;
    LOOP
      FETCH c_in_ja_cn_dff_assignments
        INTO l_ja_cn_dff_assignments_row;
      EXIT WHEN c_in_ja_cn_dff_assignments%NOTFOUND;
      IF l_ja_cn_dff_assignments_row.context_code IS NOT NULL THEN
        l_context_code := l_ja_cn_dff_assignments_row.context_code;
      END IF;
      CASE l_ja_cn_dff_assignments_row.dff_title_code
        WHEN 'SACC' THEN
          l_attribute_column4cost_center := l_ja_cn_dff_assignments_row.attribute_column;
        WHEN 'SATP' THEN
          l_attribute_column4third_party := l_ja_cn_dff_assignments_row.attribute_column;
        WHEN 'SAEE' THEN
          l_attribute_column4personnel := l_ja_cn_dff_assignments_row.attribute_column;
        WHEN 'SAPA' THEN
          l_attribute_column4project := l_ja_cn_dff_assignments_row.attribute_column;
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

    END IF;

    --fetch the account subsidiary info and save to temp table
    OPEN c_in_ja_cn_journal_lines;
    --log
    IF (l_statement_level >= l_runtime_level) THEN
      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched account segments start below:');

    END IF;
    --the context code is not necessary to be a condition to query out the signs for subsidiary
    l_sql_stmt := 'insert into JA_CN_SUBSIDIARY_GT (ACCOUNT_SEGMENT_VALUE, HAS_THIRD_PARTY,HAS_COST_CENTER,HAS_PERSONNEL,HAS_PROJECT) select flex_value,' ||
                  nvl(to_char(l_attribute_column4third_party), 'null') || ',' ||
                  nvl(to_char(l_attribute_column4cost_center), 'null') || ',' ||
                  nvl(to_char(l_attribute_column4personnel), 'null') || ',' ||
                  nvl(to_char(l_attribute_column4project), 'null') ||
                  ' from FND_FLEX_VALUES where flex_value_set_id=:1 and flex_value=:2';

    LOOP
      FETCH c_in_ja_cn_journal_lines
        INTO l_account_segment;
      EXIT WHEN c_in_ja_cn_journal_lines%NOTFOUND;
      --log
      IF (l_statement_level >= l_runtime_level) THEN
        FND_LOG.STRING(l_statement_level,
                       l_module_name,
                       'about to insert subsidiary info of account: ' ||
                       l_account_segment || ' to temp table');

      END IF;

      EXECUTE IMMEDIATE l_sql_stmt
        USING l_flex_value_set_id, l_account_segment;

    END LOOP;

    --no data found with the requested parameters
    IF (c_in_ja_cn_journal_lines%ROWCOUNT = 0) THEN
      FND_MESSAGE.set_name('JA', 'JA_CN_NO_DATA_FOUND');
      l_message := FND_MESSAGE.get();
      FND_FILE.put_line(FND_FILE.LOG, l_message);
      IF (l_exception_level >= l_runtime_level) THEN
        FND_LOG.STRING(l_exception_level, l_module_name, l_message);
      END IF;
      retcode := 1;
      errbuf  := l_message;
      RETURN;

    END IF;
    CLOSE c_in_ja_cn_journal_lines;

    --combine the journal lines and save them to the JA_CN_JOURNAL_LINES_GT
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

        END IF;

        Gen_Clauses(l_column_clauses,
                    l_prefix_column_clauses,
                    l_ja_cn_subsidiary_gbl_tmp_row.has_cost_center,
                    l_ja_cn_subsidiary_gbl_tmp_row.has_third_party,
                    l_ja_cn_subsidiary_gbl_tmp_row.has_personnel,
                    l_ja_cn_subsidiary_gbl_tmp_row.has_project,
                    l_column_clause,
                    l_prefix_column_clause);

        --dbms_output.put_line(l_column_clause);
        --dbms_output.put_line(l_prefix_column_clause);
        --dbms_output.put_line(l_where_clause);
        l_sql_stmt := REPLACE(l_sql_stmt4insert_j_line,
                              '@COLUMN_CLAUSE',
                              l_column_clause);
        l_sql_stmt := REPLACE(l_sql_stmt,
                              '@PREFIX_COLUMN_CLAUSE',
                              l_prefix_column_clause);
        /*IF (l_exception_level >= l_runtime_level)
        THEN
          fnd_log.STRING(fnd_log.level_statement, l_module_name, l_sql_stmt);
        END IF;*/
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_sql_stmt);
        EXECUTE IMMEDIATE REPLACE(l_sql_stmt,
                                  '@AND_CONDITION',
                                  'AND accounted_dr IS NOT NULL')
          USING l_current_start_date, l_current_period, l_ja_cn_subsidiary_gbl_tmp_row.account_segment_value, p_ledger_id, p_legal_entity_id;

        EXECUTE IMMEDIATE REPLACE(l_sql_stmt,
                                  '@AND_CONDITION',
                                  'AND accounted_cr IS NOT NULL')
          USING l_current_start_date, l_current_period, l_ja_cn_subsidiary_gbl_tmp_row.account_segment_value, p_ledger_id, p_legal_entity_id;

      END LOOP;
      CLOSE c_in_ja_cn_subsidiary_gbl_tmp;

    END LOOP;

    CLOSE c_in_closed_periods;

    --fetch functional currency
    SELECT fnd_currencies_vl.NAME
      INTO l_functional_currency
      FROM fnd_currencies_vl
     WHERE currency_code =
           (SELECT currency_code
              FROM gl_ledgers--gl_sets_of_books
             WHERE ledger_id = p_ledger_id );--set_of_books_id = l_set_of_books_id);
    --log
    IF (l_statement_level >= l_runtime_level) THEN
      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Fetched: l_functional_currency=' ||
                     nvl(to_char(l_functional_currency), 'null'));
    END IF;

    --output
    OPEN c_in_journal_lines_gbl_tmp;
    LOOP
      FETCH c_in_journal_lines_gbl_tmp
        INTO l_journal_lines_gbl_tmp_row;
      EXIT WHEN c_in_journal_lines_gbl_tmp%NOTFOUND;
      IF l_journal_number = l_journal_lines_gbl_tmp_row.journal_number THEN
        l_journal_line_number := l_journal_line_number + 1;
      ELSE
        l_journal_number      := l_journal_lines_gbl_tmp_row.journal_number;
        l_journal_line_number := 1;
      END IF;

      IF l_functional_currency = l_journal_lines_gbl_tmp_row.currency_code THEN
        l_journal_lines_gbl_tmp_row.entered_dr := 0;
        l_journal_lines_gbl_tmp_row.entered_cr := 0;
      END IF;

      FND_FILE.put_line(FND_FILE.output,
                        '"' || to_char(l_journal_lines_gbl_tmp_row.default_effective_date,
                                       'YYYYMMDD') --journal date
                        || '"' || FND_GLOBAL.Local_Chr(9) || '"' ||
                        l_journal_lines_gbl_tmp_row.je_category --category
                        || '"' || FND_GLOBAL.Local_Chr(9) || '"' ||
                        l_journal_number --journal number
                        || '"' || FND_GLOBAL.Local_Chr(9) || '' ||
                        l_journal_line_number --journal line number
                        || '' || FND_GLOBAL.Local_Chr(9) || '"' ||
                        l_journal_lines_gbl_tmp_row.description --description
                        || '"' || FND_GLOBAL.Local_Chr(9) || '"' ||
                        l_journal_lines_gbl_tmp_row.account_segment_value --account
                        || '"' || FND_GLOBAL.Local_Chr(9) || '' ||
                        TRIM(to_char(nvl(l_journal_lines_gbl_tmp_row.accounted_dr,
                                         0),
                                     '999999999999999990.99')) --debit
                        || '' || FND_GLOBAL.Local_Chr(9) || '' ||
                        TRIM(to_char(nvl(l_journal_lines_gbl_tmp_row.accounted_cr,
                                         0),
                                     '999999999999999990.99')) --credit
                        || '' || FND_GLOBAL.Local_Chr(9) || '"' ||
                        l_journal_lines_gbl_tmp_row.currency_code --currency
                        || '"' || FND_GLOBAL.Local_Chr(9) || '' ||
                        TRIM(to_char(nvl(l_journal_lines_gbl_tmp_row.entered_dr,
                                         0),
                                     '999999999999999990.99')) --debit abount in foreign currency
                        || '' || FND_GLOBAL.Local_Chr(9) || '' ||
                        TRIM(to_char(nvl(l_journal_lines_gbl_tmp_row.entered_cr,
                                         0),
                                     '999999999999999990.99')) --credit abount in foreign currency
                        || '' || FND_GLOBAL.Local_Chr(9) || '' ||
                        TRIM(to_char(nvl(l_journal_lines_gbl_tmp_row.currency_conversion_rate,
                                         0),
                                     '9999999999990.999999')) --exchange rate
                        || '' || FND_GLOBAL.Local_Chr(9) || '' || '0.0000' --quantity
                        || '' || FND_GLOBAL.Local_Chr(9) || '' || '0.0000' --unit price
                        || '' || FND_GLOBAL.Local_Chr(9) || '"' ||
                        Get_Subsidiary_Desc(p_cost_center        => l_journal_lines_gbl_tmp_row.cost_center,
                                            p_third_party_number => l_journal_lines_gbl_tmp_row.third_party_number,
                                            p_personnel_number   => l_journal_lines_gbl_tmp_row.personnel_number,
                                            p_project_number     => l_journal_lines_gbl_tmp_row.project_number,
                                            p_has_cost_center    => l_journal_lines_gbl_tmp_row.has_cost_center,
                                            p_has_third_party    => l_journal_lines_gbl_tmp_row.has_third_party,
                                            p_has_personnel      => l_journal_lines_gbl_tmp_row.has_personnel,
                                            p_has_project        => l_journal_lines_gbl_tmp_row.has_project) --subsidiary account group
                        || '"' || FND_GLOBAL.Local_Chr(9) || '"' || '' --settlement method
                        || '"' || FND_GLOBAL.Local_Chr(9) || '"' || '' --bill type
                        || '"' || FND_GLOBAL.Local_Chr(9) || '"' || '' --bill number
                        || '"' || FND_GLOBAL.Local_Chr(9) || '"' || '' --bill date
                        || '"' || FND_GLOBAL.Local_Chr(9) || '' || '0' --attachment quantity
                        || '' || FND_GLOBAL.Local_Chr(9) || '"' ||
                        l_journal_lines_gbl_tmp_row.journal_preparer --preparer
                        || '"' || FND_GLOBAL.Local_Chr(9) || '"' ||
                        l_journal_lines_gbl_tmp_row.JOURNAL_APPROVER -- journal approver
                        || '"' || FND_GLOBAL.Local_Chr(9) || '"' ||
                        l_journal_lines_gbl_tmp_row.journal_poster --bookkeeper
                        || '"' || FND_GLOBAL.Local_Chr(9) || '"' || '' --cashier
                        || '"' || FND_GLOBAL.Local_Chr(9) || '"' || '1' --closing flag
                        || '"' || FND_GLOBAL.Local_Chr(9) || '"' || '0' --cancel flag
                        || '"');

    END LOOP;
    CLOSE c_in_journal_lines_gbl_tmp;
    IF (l_procedure_level >= l_runtime_level) THEN

      FND_LOG.STRING(l_procedure_level,
                     l_module_name,
                     'Stop running ' || l_module_name);

    END IF;
  END Run_Export;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    gen_clauses                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to generate the column names with or withouot
  --    prefix in order to complete the SQL statements which are used to query
  --    journal entries.
  --
  --  PARAMETERS:
  --      In Out:       p_column_clauses               Collection stores generated column clauses
  --      In Out:       p_prefix_column_clauses        Collection stores generated prefix column clauses
  --      In:           p_has_cost_center              'Y' or not indicates whether it is cost center subsidiary
  --      In:           p_has_third_party              'C or S' or not indicates whether it is third party subsidiary
  --      In:           p_has_personnel                'Y' or not indicates whether it is personnel subsidiary
  --      In:           p_has_project                  'Y' or not indicates whether it is project subsidiary
  --      Out:          p_return_column_clause         Return value of generated column clause
  --      Out:          p_return_prefix_column_clause  Return value of generated prefix column clause
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      01-May-2007     Shujuan Yan Created
  --
  --===========================================================================

  PROCEDURE Gen_Clauses(p_column_clauses              IN OUT NOCOPY assoc_array_varchar1000_type
                       ,p_prefix_column_clauses       IN OUT NOCOPY assoc_array_varchar1000_type
                       ,p_has_cost_center             VARCHAR2
                       ,p_has_third_party             VARCHAR2
                       ,p_has_personnel               VARCHAR2
                       ,p_has_project                 VARCHAR2
                       ,p_return_column_clause        OUT NOCOPY VARCHAR2
                       ,p_return_prefix_column_clause OUT NOCOPY VARCHAR2) IS

    l_runtime_level   NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_procedure_level NUMBER := FND_LOG.Level_Procedure;
    l_statement_level NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_module_name CONSTANT VARCHAR2(300) := 'JA_CN_JE_EXP_PKG.Gen_Clauses';

    key                  PLS_INTEGER := 0;
    column_clause        VARCHAR2(500) := '';
    prefix_column_clause VARCHAR2(500) := '';
  BEGIN
    IF (l_procedure_level >= l_runtime_level) THEN
      FND_LOG.STRING(l_procedure_level,
                     l_module_name,
                     'Start to generate clauses by ' || l_module_name ||
                     ' in sequence of [CC][TP][PL][PT] with: ' ||
                     nvl(p_has_cost_center, 'null') ||
                     nvl(p_has_third_party, 'null') ||
                     nvl(p_has_personnel, 'null') || nvl(p_has_project, 'null'));

    END IF;

    IF (p_has_cost_center = 'Y') THEN
      key := key + 8;
    END IF;
    IF (p_has_third_party = 'C' OR p_has_third_party = 'S') THEN
      key := key + 4;
    END IF;
    IF (p_has_personnel = 'Y') THEN
      key := key + 2;
    END IF;
    IF (p_has_project = 'Y') THEN
      key := key + 1;
    END IF;
    IF (l_statement_level >= l_runtime_level) THEN
      FND_LOG.STRING(l_statement_level,
                     l_module_name,
                     'Generated key is: ' || key);
    END IF;

    IF p_column_clauses.EXISTS(key) = FALSE THEN
      IF (l_statement_level >= l_runtime_level) THEN
        FND_LOG.STRING(l_statement_level,
                       l_module_name,
                       'There is no clauses pre-generated with key: ' || key ||
                       ' so, generate it right now!');
      END IF;

      IF (p_has_cost_center = 'Y') THEN
        column_clause        := column_clause || ', COST_CENTER ';
        prefix_column_clause := prefix_column_clause || ', ' || prefix_a ||
                                '.COST_CENTER ';

      END IF;
      IF (p_has_third_party = 'C' OR p_has_third_party = 'S') THEN
        column_clause        := column_clause || ', THIRD_PARTY_NUMBER ';
        prefix_column_clause := prefix_column_clause || ', ' || prefix_a ||
                                '.THIRD_PARTY_NUMBER ';

      END IF;
      IF (p_has_personnel = 'Y') THEN
        column_clause        := column_clause || ', PERSONNEL_NUMBER ';
        prefix_column_clause := prefix_column_clause || ', ' || prefix_a ||
                                '.PERSONNEL_NUMBER ';

      END IF;
      IF (p_has_project = 'Y') THEN
        column_clause        := column_clause || ', PROJECT_NUMBER ';
        prefix_column_clause := prefix_column_clause || ', ' || prefix_a ||
                                '.PROJECT_NUMBER ';

      END IF;
      p_column_clauses(key) := column_clause;
      p_prefix_column_clauses(key) := prefix_column_clause;

    END IF;

    p_return_prefix_column_clause := p_prefix_column_clauses(key);
    p_return_column_clause        := p_column_clauses(key);
    IF (l_procedure_level >= l_runtime_level) THEN

      FND_LOG.STRING(l_procedure_level,
                     l_module_name,
                     'Stop running ' || l_module_name);

    END IF;
  END Gen_Clauses;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    get_subsidiary_desc                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to generate the subsidiary description.
  --
  --
  --  PARAMETERS:
  --      In:          p_cost_center           Cost center segment
  --      In:          p_third_party_number    Number of third party
  --      In:          p_personnel_number      Personnel number
  --      In:          p_project_number        Number of project
  --      In:          p_has_cost_center       'Y' or not indicates whether it is cost center subsidiary.
  --      In:          p_has_third_party       'C or S' or not indicates whether it is third party subsidiary.
  --      In:          p_has_personnel         'Y' or not indicates whether it is personnel subsidiary.
  --      In:          p_has_project           'Y' or not indicates whether it is project subsidiary.
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      07-May-2007     Shujuan Yan Created
  --
  --===========================================================================
  FUNCTION Get_Subsidiary_Desc(p_cost_center        VARCHAR2
                              ,p_third_party_number VARCHAR2
                              ,p_personnel_number   VARCHAR2
                              ,p_project_number     VARCHAR2
                              ,p_has_cost_center    VARCHAR2
                              ,p_has_third_party    VARCHAR2
                              ,p_has_personnel      VARCHAR2
                              ,p_has_project        VARCHAR2) RETURN VARCHAR2 IS

    l_subsidiary_desc VARCHAR2(500) := '';
  BEGIN

    IF (p_has_project = 'Y') THEN
      l_subsidiary_desc := l_subsidiary_desc || p_project_number || '/';
    END IF;
    IF (p_has_third_party = 'C' OR p_has_third_party = 'S') THEN
      l_subsidiary_desc := l_subsidiary_desc || p_third_party_number || '/';
    END IF;
    IF (p_has_cost_center = 'Y') THEN
      l_subsidiary_desc := l_subsidiary_desc || p_cost_center || '/';
    END IF;
    IF (p_has_personnel = 'Y') THEN
      l_subsidiary_desc := l_subsidiary_desc || p_personnel_number || '/';
    END IF;

    IF (l_subsidiary_desc IS NOT NULL) THEN

      l_subsidiary_desc := substr(l_subsidiary_desc,
                                  1,
                                  length(l_subsidiary_desc) - 1);
    END IF;
    RETURN l_subsidiary_desc;
  END Get_Subsidiary_Desc;

END JA_CN_JE_EXP_PKG;

/
