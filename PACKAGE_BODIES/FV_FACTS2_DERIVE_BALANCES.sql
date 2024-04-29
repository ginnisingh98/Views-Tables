--------------------------------------------------------
--  DDL for Package Body FV_FACTS2_DERIVE_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FACTS2_DERIVE_BALANCES" AS
/* $Header: FVFCT2BB.pls 120.0.12000000.4 2007/10/05 20:08:17 sasukuma noship $*/

  g_module_name         VARCHAR2(100);
  g_FAILURE             NUMBER;
  g_SUCCESS             NUMBER;
  g_WARNING             NUMBER;
  g_request_id          NUMBER;
  g_user_id             NUMBER;
  g_login_id            NUMBER;
  g_enter               VARCHAR2(10);
  g_exit                VARCHAR2(10);

  PROCEDURE report
  (
    p_msg IN VARCHAR2
  )
  IS
  BEGIN
    fnd_file.put_line (fnd_file.output, p_msg);
  END;

  PROCEDURE generate_output_report
  (
    p_ledger_id       IN  gl_ledgers_public_v.ledger_id%TYPE,
    p_fiscal_year     IN  gl_period_statuses.period_year%TYPE,
    p_error_code      OUT NOCOPY NUMBER,
    p_error_desc      OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'generate_output_report';
    p_error_code  := g_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ledger_id = '||p_ledger_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_fiscal_year       = '||p_fiscal_year);
    END IF;

    report ('                                FACTS II Ending Balances');
    report ('Ledger Id: '||p_ledger_id);
    report ('Fiscal Year: '||p_fiscal_year);
    report ('+-------+----------+-------+---------+--------------+-----------------+-----------------+');
    report ('|Account|Public Law|Adv Flg|Txfr Dept|Txfr Main Acct|Ending Balance Cr|Ending Balance Cr|');
    report ('|-------+----------+-------+---------+--------------+-----------------+-----------------|');
    FOR factsii_rec IN (SELECT *
                          FROM fv_factsii_ending_balances
                         WHERE set_of_books_id = p_ledger_id
                           AND fiscal_year = p_fiscal_year) LOOP
      report ('|'||
              RPAD (factsii_rec.ussgl_account, 7, ' ')||
              '|'||
              RPAD (NVL(factsii_rec.public_law, ' '), 10, ' ')||
              '|'||
              RPAD (NVL(factsii_rec.advance_flag, ' '), 7, ' ')||
              '|'||
              RPAD (NVL(factsii_rec.transfer_dept_id, ' '), 9, ' ')||
              '|'||
              RPAD (NVL(factsii_rec.transfer_main_acct, ' '), 14, ' ')||
              '|'||
              LPAD (NVL(TO_CHAR(factsii_rec.ending_balance_dr), ' '), 17, ' ')||
              '|'||
              LPAD (NVL(TO_CHAR(factsii_rec.ending_balance_cr), ' '), 17, ' ')||
              '|');

    END LOOP;
    report ('+-------+----------+-------+---------+--------------+-----------------+-----------------+');

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;


  --****************************************************************************************--
  --*          Name : initialize_global_variables                                          *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : To initialize all global variables                                   *--
  --*    Parameters : None                                                                 *--
  --*   Global Vars : As in procedure                                                      *--
  --*   Called from : Called when initializing the package                                 *--
  --*         Calls : None                                                                 *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : No Logic                                                             *--
  --****************************************************************************************--
  PROCEDURE initialize_global_variables
  IS
  BEGIN
    g_module_name         := 'fv.plsql.fv_facts2_derive_balances.';
    g_FAILURE             := -1;
    g_SUCCESS             := 0;
    g_WARNING             := -2;
    g_request_id          := fnd_global.conc_request_id;
    g_user_id             := fnd_global.user_id;
    g_login_id            := fnd_global.login_id;
    g_enter               := 'ENTER';
    g_exit                := 'EXIT';
  END;

  --****************************************************************************************--
  --*          Name : explode_accounts                                                     *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Looks at all the FACTSII accounts and puts those accounts along with *--
  --*               : their child accounts into the temporary table fv_factsii_accounts_gt *--
  --*    Parameters : p_ledger_id   Set Of Books Id                                        *--
  --*               : p_acct_value_set_id Account Value Set Id                             *--
  --*               : p_error_code        Return Error Code                                *--
  --*               : p_error_desc        Return Error Description                         *--
  --*   Global Vars : fnd_log.g_current_runtime_level                                      *--
  --*               : fnd_log.level_procedure                                              *--
  --*               : fnd_log.level_statement                                              *--
  --*               : fnd_log.level_unexpected                                             *--
  --*               : g_module_name                                                        *--
  --*               : g_SUCCESS                                                            *--
  --*   Called from : derive_balances                                                      *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : fnd_flex_value_hierarchies SELECT                                    *--
  --*               : fnd_flex_values_vl         SELECT                                    *--
  --*               : fv_facts_attributes        SELECT                                    *--
  --*               : fv_facts_ussgl_accounts    SELECT                                    *--
  --*               : fv_factsii_accounts_gt     INSERT                                    *--
  --*         Logic : 1. Get all the FACTSII accounts from table fv_facts_ussgl_accounts   *--
  --*               :    and select only those accounts from table fv_facts_attributes     *--
  --*               :    where the following attributes are set to Y. public_law_code,     *--
  --*               :    advance_flag and transfer_flag                                    *--
  --*               : 2. Insert that account into table fv_factsii_accounts_gt             *--
  --*               : 3. Find all the child accounts using the tables fnd_flex_values_vl   *--
  --*               :    and fnd_flex_value_hierarchies and insert those too into the      *--
  --*               :    temporary table fv_factsii_accounts_gt                            *--
  --****************************************************************************************--
  PROCEDURE explode_accounts
  (
    p_ledger_id         IN  gl_ledgers_public_v.ledger_id%TYPE,
    p_acct_value_set_id IN NUMBER,
    p_error_code        OUT NOCOPY NUMBER,
    p_error_desc        OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(200);


    CURSOR get_hierarchies_cursor
    (
      c_account VARCHAR2,
      c_flex_value_set_id NUMBER
    )
    IS
    SELECT child_flex_value_low,
           child_flex_value_high
      FROM fnd_flex_value_hierarchies
     WHERE parent_flex_value = c_account
       AND flex_value_set_id = c_flex_value_set_id;


    CURSOR get_child_values_cursor
    (
      c_flex_value_set_id NUMBER,
      c_flex_value_low    VARCHAR2,
      c_flex_value_hi     VARCHAR2
    )
    IS
    SELECT flex_value account
      FROM fnd_flex_values_vl
     WHERE flex_value_set_id = c_flex_value_set_id
       AND flex_value BETWEEN c_flex_value_low AND c_flex_value_hi;


  BEGIN
    l_module_name := g_module_name || 'explode_accounts';
    p_error_code  := g_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ledger_id   = '||p_ledger_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_acct_value_set_id = '||p_acct_value_set_id);
    END IF;

    FOR account_rec IN (SELECT fsgl.ussgl_account,
                               fa.public_law_code,
                               fa.advance_flag,
                               fa.transfer_flag
                          FROM fv_facts_attributes fa,
                               fv_facts_ussgl_accounts fsgl
                         WHERE fa.set_of_books_id = p_ledger_id
                           AND fsgl.reporting_type in (2,3)
                           AND fsgl.ussgl_account = fa.ussgl_acct_number
                           AND (fa.public_law_code = 'Y' OR
                                fa.advance_flag = 'Y' OR
                                fa.transfer_flag = 'Y')) LOOP
      BEGIN
        INSERT INTO fv_factsii_accounts_gt
        (
          ussgl_account,
          account,
          public_law_code,
          advance_flag,
          transfer_flag
        )
        VALUES
        (
          account_rec.ussgl_account,
          account_rec.ussgl_account,
          account_rec.public_law_code,
          account_rec.advance_flag,
          account_rec.transfer_flag
        );
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'insert_fv_factsii_accounts_gt';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;

      IF (p_error_code = g_SUCCESS) THEN
        FOR get_hierarchies_rec IN get_hierarchies_cursor(account_rec.ussgl_account,
                                                          p_acct_value_set_id) LOOP
          FOR get_child_values_rec IN get_child_values_cursor(p_acct_value_set_id,
                                                              get_hierarchies_rec.child_flex_value_low,
                                                              get_hierarchies_rec.child_flex_value_high) LOOP
            BEGIN
              INSERT INTO fv_factsii_accounts_gt
              (
                ussgl_account,
                account,
                public_law_code,
                advance_flag,
                transfer_flag
              )
              VALUES
              (
                account_rec.ussgl_account,
                get_child_values_rec.account,
                account_rec.public_law_code,
                account_rec.advance_flag,
                account_rec.transfer_flag
              );
            EXCEPTION
              WHEN OTHERS THEN
                p_error_code := g_FAILURE;
                p_error_desc := SQLERRM;
                l_location   := l_module_name||'insert_fv_factsii_accounts_gt2';
                fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
                fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
            END;
            IF (p_error_code <> g_SUCCESS) THEN
              EXIT;
            END IF;
          END LOOP;
          IF (p_error_code <> g_SUCCESS) THEN
            EXIT;
          END IF;
        END LOOP;
      END IF;


      IF (p_error_code <> g_SUCCESS) THEN
        EXIT;
      END IF;
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : initialize_program_variables                                         *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : One time initialization of all the variables required by this        *--
  --*               : concurrent program.                                                  *--
  --*    Parameters : p_ledger_id            IN Set Of Books Id                            *--
  --*               : p_fiscal_year          IN Fiscal Year                                *--
  --*               : p_last_period_num      OUT Returns the last non adjusting period num *--
  --*               :                            for the fiscal year                       *--
  --*               : p_chart_of_accounts_id OUT Returns Chart of Accounts Id for the SOB  *--
  --*               : p_acct_segment         OUT Returns the Accounting Segment for the    *--
  --*               :                            chart of accounts                         *--
  --*               : p_acct_value_set_id    OUT Returns the Accounting Segment Value Set  *--
  --*               :                            Id for the chart of accounts              *--
  --*               : p_bal_segment          OUT Returns the Balancing Segment for the     *--
  --*               :                            chart of accounts                         *--
  --*               : p_fyr_segment          OUT Returns the Fiscal Year Segment           *--
  --*               : p_pub_law_code_col     OUT Returns the public law code attribute col *--
  --*               : p_advance_type_col     OUT Returns the advance type attribute col    *--
  --*               : p_tr_main_acct_col     OUT Returns the Main Account attribute col    *--
  --*               : p_tr_dept_id_col       OUT Returns the Department Id attribute col   *--
  --*               : p_error_code           OUT Return Error Code                         *--
  --*               : p_error_desc           OUT Return Error Description                  *--
  --*   Global Vars : fnd_log.g_current_runtime_level                                      *--
  --*               : fnd_log.level_procedure                                              *--
  --*               : fnd_log.level_statement                                              *--
  --*               : fnd_log.level_unexpected                                             *--
  --*               : g_module_name                                                        *--
  --*               : g_SUCCESS                                                            *--
  --*   Called from : derive_balances                                                      *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*               : fnd_flex_apis.get_segment_column                                     *--
  --*   Tables Used : gl_sets_of_books           SELECT                                    *--
  --*               : fnd_id_flex_segments       SELECT                                    *--
  --*               : gl_period_statuses         SELECT                                    *--
  --*               : fv_system_parameters       SELECT                                    *--
  --*         Logic : 1. Get the chart of accounts id from gl_sets_of_books using the      *--
  --*               :    set of books id.                                                  *--
  --*               : 2. Call fnd_flex_apis.get_segment_column with the chart of accounts  *--
  --*               :    id and get the GL_ACCOUNT segment name                            *--
  --*               : 3. From fnd_id_flex_segments using the chart of acconts id and the   *--
  --*               :    accounting segment name, get the Account value set id             *--
  --*               : 4. From gl_period_statuses get the last non adjusting period for the *--
  --*               :    Fiscal year and set of books id.                                  *--
  --*               : 5. From fv_system_parameters get the following attributes.           *--
  --*               :    factsii_advance_type_attribute,factsii_tr_main_acct_attribute,    *--
  --*               :    factsii_tr_dept_id_attribute and factsii_pub_law_code_attribute   *--
  --****************************************************************************************--
  PROCEDURE initialize_program_variables
  (
    p_ledger_id                    IN  gl_ledgers_public_v.ledger_id%TYPE,
    p_fiscal_year                  IN  gl_period_statuses.period_year%TYPE,
    p_last_period_num              OUT NOCOPY gl_period_statuses.period_num%TYPE,
    p_chart_of_accounts_id         OUT NOCOPY gl_ledgers_public_v.chart_of_accounts_id%TYPE,
    p_acct_segment                 OUT NOCOPY fnd_id_flex_segments.application_column_name%TYPE,
    p_acct_value_set_id            OUT NOCOPY fnd_id_flex_segments.flex_value_set_id%TYPE,
    p_bal_segment                  OUT NOCOPY fnd_id_flex_segments.application_column_name%TYPE,
    p_fyr_segment                  OUT NOCOPY fnd_id_flex_segments.application_column_name%TYPE,
    p_pub_law_code_col             OUT NOCOPY fv_system_parameters.factsii_pub_law_code_attribute%TYPE,
    p_advance_type_col             OUT NOCOPY fv_system_parameters.factsii_advance_type_attribute%TYPE,
    p_tr_main_acct_col             OUT NOCOPY fv_system_parameters.factsii_tr_main_acct_attribute%TYPE,
    p_tr_dept_id_col               OUT NOCOPY fv_system_parameters.factsii_tr_dept_id_attribute%TYPE,
    p_error_code                   OUT NOCOPY NUMBER,
    p_error_desc                   OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name          VARCHAR2(200);
    l_location             VARCHAR2(200);
    l_application_id       NUMBER := 101;
    l_id_flex_code         VARCHAR2(25) := 'GL#';
    l_acct_seg_attr_type   VARCHAR2(30) := 'GL_ACCOUNT';
    l_bal_seg_attr_type    VARCHAR2(30) := 'GL_BALANCING';
    l_retval               BOOLEAN;

  BEGIN
    l_module_name := g_module_name || 'initialize_program_variables';
    p_error_code  := g_SUCCESS;

    p_chart_of_accounts_id := NULL;
    p_acct_segment         := NULL;
    p_acct_value_set_id    := NULL;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ledger_id   = '||p_ledger_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_fiscal_year       = '||p_fiscal_year);
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN

      SELECT glp.chart_of_accounts_id
      INTO p_chart_of_accounts_id
      FROM gl_ledgers_public_v glp
      WHERE glp.ledger_id = p_ledger_id;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_chart_of_accounts_id='||p_chart_of_accounts_id);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'select chart_of_accounts_id';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling fnd_flex_apis.get_segment_column');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_application_id       ='||l_application_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_id_flex_code         ='||l_id_flex_code);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_chart_of_accounts_id ='||p_chart_of_accounts_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_acct_seg_attr_type   ='||l_acct_seg_attr_type);
      END IF;
      l_retval := fnd_flex_apis.get_segment_column
                  (
                    x_application_id  => l_application_id,
                    x_id_flex_code    => l_id_flex_code,
                    x_id_flex_num     => p_chart_of_accounts_id,
                    x_seg_attr_type   => l_acct_seg_attr_type,
                    x_app_column_name => p_acct_segment
                  );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_acct_segment  ='||p_acct_segment);
      END IF;
      IF (NOT l_retval) THEN
        p_error_code := g_FAILURE;
        p_error_desc := fnd_message.get;
        l_location   := l_module_name||'call_fnd_flex_apis.get_segment_column';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling fnd_flex_apis.get_segment_column');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_application_id       ='||l_application_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_id_flex_code         ='||l_id_flex_code);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_chart_of_accounts_id ='||p_chart_of_accounts_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_acct_seg_attr_type   ='||l_bal_seg_attr_type);
      END IF;
      l_retval := fnd_flex_apis.get_segment_column
                  (
                    x_application_id  => l_application_id,
                    x_id_flex_code    => l_id_flex_code,
                    x_id_flex_num     => p_chart_of_accounts_id,
                    x_seg_attr_type   => l_bal_seg_attr_type,
                    x_app_column_name => p_bal_segment
                  );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_acct_segment  ='||p_acct_segment);
      END IF;
      IF (NOT l_retval) THEN
        p_error_code := g_FAILURE;
        p_error_desc := fnd_message.get;
        l_location   := l_module_name||'call_fnd_flex_apis.get_segment_column';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        SELECT flex_value_set_id
          INTO p_acct_value_set_id
          FROM fnd_id_flex_segments
         WHERE application_column_name = p_acct_segment
           AND application_id = l_application_id
           AND id_flex_code = l_id_flex_code
           AND id_flex_num = p_chart_of_accounts_id
           AND enabled_flag = 'Y';
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'select_fnd_id_flex_segments';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        SELECT MAX(period_num)
          INTO p_last_period_num
          FROM gl_period_statuses gps
         WHERE gps.ledger_id = p_ledger_id
           AND gps.application_id = l_application_id
           AND gps.period_year = p_fiscal_year;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'select_gl_period_statuses';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        SELECT factsii_pub_law_code_attribute,
               factsii_advance_type_attribute,
               factsii_tr_main_acct_attribute,
               factsii_tr_dept_id_attribute
          INTO p_pub_law_code_col,
               p_advance_type_col,
               p_tr_main_acct_col,
               p_tr_dept_id_col
          FROM fv_system_parameters;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'select_gl_period_statuses';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        SELECT application_column_name
          INTO p_fyr_segment
          FROM fv_pya_fiscalyear_segment
         WHERE set_of_books_id = p_ledger_id;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'select_fv_pya_fiscalyear_segment';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : purge_balances                                                       *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Purges data from the table fv_factsii_ending_balances for the given  *--
  --*               : set of books id and fiscal year.                                     *--
  --*    Parameters : p_ledger_id         IN Set Of Books Id                               *--
  --*               : p_fiscal_year       IN Fiscal Year                                   *--
  --*               : p_error_code        OUT Return Error Code                            *--
  --*               : p_error_desc        OUT Return Error Descion                         *--
  --*   Global Vars : fnd_log.g_current_runtime_level                                      *--
  --*               : fnd_log.level_procedure                                              *--
  --*               : fnd_log.level_statement                                              *--
  --*               : fnd_log.level_unexpected                                             *--
  --*               : g_module_name                                                        *--
  --*               : g_SUCCESS                                                            *--
  --*   Called from : derive_balances                                                      *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : fv_factsii_ending_balances DELETE                                    *--
  --*         Logic : 1. Delete data from table fv_factsii_ending_balances for the given   *--
  --*               :    set of books id and fiscal year.
  --****************************************************************************************--
  PROCEDURE purge_balances
  (
    p_ledger_id       IN  gl_ledgers_public_v.ledger_id%TYPE,
    p_fiscal_year     IN  gl_period_statuses.period_year%TYPE,
    p_error_code      OUT NOCOPY NUMBER,
    p_error_desc      OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'purge_balances';
    p_error_code  := g_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ledger_id   = '||p_ledger_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_fiscal_year       = '||p_fiscal_year);
    END IF;

    BEGIN
      DELETE fv_factsii_ending_balances
       WHERE set_of_books_id = p_ledger_id
         AND fiscal_year = p_fiscal_year;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_code := g_FAILURE;
        p_error_desc := SQLERRM;
        l_location   := l_module_name||'delete_fv_factsii_ending_balances';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    END;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;


  --****************************************************************************************--
  --*          Name : get_treasury_info                                                    *--
  --*          Type : Procedure                                                            *--
  --*       Purpose :
  --*    Parameters :
  --*               : p_error_code        OUT Return Error Code                            *--
  --*               : p_error_desc        OUT Return Error Descion                         *--
  --*   Global Vars : fnd_log.g_current_runtime_level                                      *--
  --*               : fnd_log.level_procedure                                              *--
  --*               : fnd_log.level_statement                                              *--
  --*               : fnd_log.level_unexpected                                             *--
  --*               : g_module_name                                                        *--
  --*               : g_SUCCESS                                                            *--
  --*   Called from : start_processing                                                     *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used :
  --*         Logic :
  --****************************************************************************************--
  PROCEDURE get_treasury_info
  (
    p_ledger_id          IN  NUMBER,
    p_fund_value         IN  VARCHAR2,
    p_treasury_symbol_id OUT NOCOPY fv_treasury_symbols.treasury_symbol_id%TYPE,
    p_cohort_segment     OUT NOCOPY VARCHAR2,
    p_error_code         OUT NOCOPY NUMBER,
    p_error_desc         OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'get_treasury_info';
    p_error_code  := g_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ledger_id   = '||p_ledger_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_fund_value        = '||p_fund_value);
    END IF;

    BEGIN
      SELECT fp.treasury_symbol_id,
             ffa.cohort_segment_name
        INTO p_treasury_symbol_id,
             p_cohort_segment
        FROM fv_fund_parameters fp,
             fv_treasury_symbols fts,
             fv_facts_federal_accounts ffa
       WHERE fp.set_of_books_id = p_ledger_id
         AND fp.fund_value = p_fund_value
         AND fts.treasury_symbol_id = fp.treasury_symbol_id
         AND fts.federal_acct_symbol_id = ffa.federal_acct_symbol_id
         AND fts.set_of_books_id = p_ledger_id
         AND ffa.set_of_books_id = p_ledger_id;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_code := g_FAILURE;
        p_error_desc := SQLERRM;
        l_location   := l_module_name||'select_fv_fund_parameters';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    END;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : start_processing                                                     *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure does tha main processing of deriving the actual       *--
  --*                 actual FACTSII balances                                              *--
  --*    Parameters : p_ledger_id         IN Set Of Books Id                               *--
  --*               : p_acct_segment      IN Accounting Segment                            *--
  --*               : p_bal_segment       IN Balancing Segment                             *--
  --*               : p_bal_segment       IN Fiscal Year Segment                           *--
  --*               : p_fiscal_year       IN Fiscal Year                                   *--
  --*               : p_last_period_num   IN Last Non Adjusting Period for the Fiscal Year *--
  --*               : p_pub_law_code_col  IN Public Law Code Attribute column              *--
  --*               : p_advance_type_col  IN Advance Type Attribute column                 *--
  --*               : p_tr_main_acct_col  IN Transfer Main Account Attribute column        *--
  --*               : p_tr_dept_id_col    IN Department Id Attribute column                *--
  --*               : p_error_code        OUT Return Error Code                            *--
  --*               : p_error_desc        OUT Return Error Descion                         *--
  --*   Global Vars : fnd_log.g_current_runtime_level                                      *--
  --*               : fnd_log.level_procedure                                              *--
  --*               : fnd_log.level_statement                                              *--
  --*               : fnd_log.level_unexpected                                             *--
  --*               : g_module_name                                                        *--
  --*               : g_SUCCESS                                                            *--
  --*   Called from : derive_balances                                                      *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : fv_factsii_ending_balances INSERT                                    *--
  --*               : gl_je_lines gll            SELECT                                    *--
  --*               : gl_je_headers gjh          SELECT                                    *--
  --*               : gl_period_statuses gps     SELECT                                    *--
  --*               : fv_be_trx_dtls             SELECT                                    *--
  --*               : gl_balances glbal          SELECT                                    *--
  --*               : gl_code_combinations gcc   SELECT                                    *--
  --*               : fv_factsii_accounts_gt     SELECT                                    *--
  --*         Logic : 1.
  --****************************************************************************************--
  PROCEDURE start_processing
  (
    p_ledger_id        IN gl_ledgers_public_v.ledger_id%TYPE,
    p_acct_segment     IN fnd_id_flex_segments.application_column_name%TYPE,
    p_bal_segment      IN fnd_id_flex_segments.application_column_name%TYPE,
    p_fyr_segment      IN fnd_id_flex_segments.application_column_name%TYPE,
    p_fiscal_year      IN gl_period_statuses.period_year%TYPE,
    p_last_period_num  IN NUMBER,
    p_pub_law_code_col IN fv_system_parameters.factsii_pub_law_code_attribute%TYPE,
    p_advance_type_col IN fv_system_parameters.factsii_advance_type_attribute%TYPE,
    p_tr_main_acct_col IN fv_system_parameters.factsii_tr_main_acct_attribute%TYPE,
    p_tr_dept_id_col   IN fv_system_parameters.factsii_tr_dept_id_attribute%TYPE,
    p_error_code       OUT NOCOPY NUMBER,
    p_error_desc       OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name          VARCHAR2(200);
    l_location             VARCHAR2(200);
    TYPE balances_cur_type IS REF CURSOR;
    balances_cur           balances_cur_type;
    l_code_combination_id  gl_balances.code_combination_id%TYPE;
    l_ending_balance_dr    NUMBER;
    l_ending_balance_cr    NUMBER;
    l_period_num           gl_balances.period_num%TYPE;
    l_account              VARCHAR2(30);
    l_fund                 VARCHAR2(30);
    l_fyr                  VARCHAR2(30);
    l_ussgl_account        VARCHAR2(30);
    l_gl_cursor_str        VARCHAR2(10240);
    l_attribute_columns    VARCHAR2(1024);
    l_attr_group_columns   VARCHAR2(1024);
    l_where_columns        VARCHAR2(1024);
    l_system_date          DATE := SYSDATE;
    l_public_law_code      VARCHAR2(1);
    l_advance_flag         VARCHAR2(1);
    l_transfer_flag        VARCHAR2(1);
    l_cohort_segment       fnd_id_flex_segments.application_column_name%TYPE;
    l_cohort               VARCHAR2(30);
    TYPE l_segment_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    l_segment              l_segment_type;
    l_treasury_symbol_id   NUMBER;
    l_gl_cursor_id         INTEGER;
    l_gl_cursor_ret        INTEGER;
    l_count_ccid           NUMBER := 0;
    l_insert_required      BOOLEAN := FALSE;



  BEGIN
    l_module_name := g_module_name || 'start_processing';
    p_error_code  := g_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ledger_id         = '||p_ledger_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_acct_segment      = '||p_acct_segment);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_bal_segment       = '||p_bal_segment);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_fyr_segment       = '||p_fyr_segment);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_fiscal_year       = '||p_fiscal_year);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_last_period_num   = '||p_last_period_num);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_pub_law_code_col  = '||p_pub_law_code_col);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_advance_type_col  = '||p_advance_type_col);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_tr_main_acct_col  = '||p_tr_main_acct_col);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_tr_dept_id_col    = '||p_tr_dept_id_col);
    END IF;


    l_attribute_columns := NULL;
    l_attr_group_columns := NULL;
    l_where_columns := NULL;


    IF (p_pub_law_code_col IS NOT NULL) THEN
      l_attribute_columns := l_attribute_columns||'DECODE(:b_public_law_code, ''Y'', NVL(be.public_law_code, gll.'||p_pub_law_code_col||'), NULL), ';
      l_attr_group_columns := l_attr_group_columns||' NVL(be.public_law_code, gll.'||p_pub_law_code_col||') ';
      l_where_columns := l_where_columns||'AND ((DECODE(:b_public_law_code, ''Y'', NVL(be.public_law_code, gll.'||p_pub_law_code_col||'), NULL) IS NOT NULL) OR ';
    ELSE
      l_attribute_columns := l_attribute_columns||'DECODE(:b_public_law_code, ''Y'', be.public_law_code, NULL), ';
      l_attr_group_columns := l_attr_group_columns||' be.public_law_code ';
      l_where_columns := l_where_columns||'AND ((DECODE(:b_public_law_code, ''Y'', be.public_law_code, NULL) IS NOT NULL) OR ';
    END IF;

    IF (p_advance_type_col IS NOT NULL) THEN
      l_attribute_columns := l_attribute_columns||'DECODE(:b_advance_flag, ''Y'', NVL(be.advance_type, gll.'||p_advance_type_col||'), NULL), ';
      l_attr_group_columns := l_attr_group_columns||',NVL(be.advance_type, gll.'||p_advance_type_col||') ';
      l_where_columns := l_where_columns||'(DECODE(:b_advance_flag, ''Y'', NVL(be.advance_type, gll.'||p_advance_type_col||'), NULL) IS NOT NULL) OR ';
    ELSE
      l_attribute_columns := l_attribute_columns||'DECODE(:b_advance_flag, ''Y'', be.advance_type, NULL), ';
      l_attr_group_columns := l_attr_group_columns||',be.advance_type ';
      l_where_columns := l_where_columns||'(DECODE(:b_advance_flag, ''Y'', be.advance_type, NULL) IS NOT NULL) OR ';
    END IF;

    IF (p_tr_main_acct_col IS NOT NULL) THEN
      l_attribute_columns := l_attribute_columns||'DECODE(:b_transfer_flag, ''Y'', NVL(be.main_account, gll.'||p_tr_main_acct_col||'), NULL), ';
      l_attr_group_columns := l_attr_group_columns||',NVL(be.main_account, gll.'||p_tr_main_acct_col||') ';
      l_where_columns := l_where_columns||'(DECODE(:b_transfer_flag, ''Y'', NVL(be.main_account, gll.'||p_tr_main_acct_col||'), NULL) IS NOT NULL) OR ';
    ELSE
      l_attribute_columns := l_attribute_columns||'DECODE(:b_transfer_flag, ''Y'', be.main_account, NULL), ';
      l_attr_group_columns := l_attr_group_columns||',be.main_account ';
      l_where_columns := l_where_columns||'(DECODE(:b_transfer_flag, ''Y'', be.main_account, NULL) IS NOT NULL) OR ';
    END IF;

    IF (p_tr_dept_id_col IS NOT NULL) THEN
      l_attribute_columns := l_attribute_columns||'DECODE(:b_transfer_flag, ''Y'', NVL(be.dept_id, gll.'||p_tr_dept_id_col||'), NULL), ';
      l_attr_group_columns := l_attr_group_columns||',NVL(be.dept_id, gll.'||p_tr_dept_id_col||') ';
      l_where_columns := l_where_columns||'(DECODE(:b_transfer_flag, ''Y'', NVL(be.dept_id, gll.'||p_tr_dept_id_col||'), NULL) IS NOT NULL)) ';
    ELSE
      l_attribute_columns := l_attribute_columns||'DECODE(:b_transfer_flag, ''Y'', be.dept_id, NULL), ';
      l_attr_group_columns := l_attr_group_columns||',be.dept_id ';
      l_where_columns := l_where_columns||'(DECODE(:b_transfer_flag, ''Y'', be.dept_id, NULL) IS NOT NULL)) ';
    END IF;

    l_gl_cursor_str := 'INSERT INTO fv_factsii_ending_balances
                        (
                          set_of_books_id,
                          fiscal_year,
                          ccid,
                          account,
                          ussgl_account,
                          fund,
                          fyr,
                          cohort,
                          ending_balance_cr,
                          ending_balance_dr,
                          public_law,
                          advance_flag,
                          transfer_main_acct,
                          transfer_dept_id,
                          record_category,
                          creation_date,
                          created_by,
                          last_update_date,
                          last_update_by,
                          request_id,
                          treasury_symbol_id
                        )
                           SELECT :b_set_of_books_id,
                               :b_period_year,
                               :b_code_combination_id,
                               :b_account,
                               :b_ussgl_account,
                               :b_fund,
                               :b_fyr,
                               :b_cohort,
                               SUM(NVL(gll.entered_cr, 0)),
                               SUM(NVL(gll.entered_dr, 0)),'||
                               l_attribute_columns||
                              '''E'',
                              :b_curr_date,
                              :b_user_id,
                              :b_curr_date,
                              :b_user_id,
                              :b_request_id,
                              :b_treasury_symbol_id
                          FROM gl_je_lines gll,
                               gl_je_headers gjh,
                               gl_period_statuses gps,
                               fv_be_trx_dtls be
                         WHERE gjh.ledger_id = gps.ledger_id
                           AND gll.code_combination_id = :b_code_combination_id
                           AND gjh.status=''P''
                           AND gll.ledger_id = gjh.ledger_id
                           AND gll.je_header_id = gjh.je_header_id
                           AND  NVL(gjh.je_from_sla_flag, ''N'') IN (''N'',''U'')
                           AND gjh.actual_flag = ''A''
                           AND gps.application_id = 101
                           AND gps.ledger_id = :b_set_of_books_id
                           AND gjh.period_name = gps.period_name '||
                           l_where_columns ||'
                           AND gps.period_year = :b_period_year
                           AND gll.reference_1 = be.transaction_id (+)
                           AND be.set_of_books_id (+) = :b_set_of_books_id
                         GROUP BY '|| l_attr_group_columns||
                         ' HAVING SUM(NVL(gll.entered_dr, 0))-SUM(NVL(gll.entered_cr, 0)) <> 0
                         UNION
                         SELECT :b_set_of_books_id,
                               :b_period_year,
                               :b_code_combination_id,
                               :b_account,
                               :b_ussgl_account,
                               :b_fund,
                               :b_fyr,
                               :b_cohort,
                               SUM(NVL(gll.entered_cr, 0)),
                               SUM(NVL(gll.entered_dr, 0)),'||
                               l_attribute_columns||
                              '''E'',
                              :b_curr_date,
                              :b_user_id,
                              :b_curr_date,
                              :b_user_id,
                              :b_request_id,
                              :b_treasury_symbol_id
                          FROM gl_je_lines gll,
                               gl_je_headers gjh,
                               xla_ae_lines xl ,
                               xla_distribution_links xdl,
                               gl_period_statuses gps,
                               fv_be_trx_dtls be,
                               gl_import_references glir
                         WHERE  xl.code_combination_id = :b_code_combination_id
                                AND  xl.ae_header_id = xdl.ae_header_id
                                AND  xl.ae_line_num = xdl.ae_line_num
                                AND  NVL(gjh.je_from_sla_flag, ''N'') = ''Y''
                                AND gjh.ledger_id = gps.ledger_id
                                AND gjh.status=''P''
                                AND gll.ledger_id = gjh.ledger_id
                                AND gll.je_header_id = gjh.je_header_id
                                AND gjh.actual_flag = ''A''
                                AND gps.application_id = 101
                                AND gps.ledger_id = :b_set_of_books_id
                                AND glir.je_header_id = gjh.je_header_id
                                AND glir.je_line_num = gll.je_line_num
                                AND glir.je_batch_id = gjh.je_batch_id
                                AND glir.gl_sl_link_id = xl.gl_sl_link_id
                                AND glir.gl_sl_link_table = xl.gl_sl_link_table
                                AND gjh.period_name = gps.period_name '||
                                l_where_columns ||'
                                AND gps.period_year = :b_period_year
                                AND  nvl(xdl.SOURCE_DISTRIBUTION_ID_NUM_1,-99) = be.transaction_id (+)
                                AND be.set_of_books_id (+) = :b_set_of_books_id
                                GROUP BY '|| l_attr_group_columns||
                              ' HAVING SUM(NVL(gll.entered_dr, 0))-SUM(NVL(gll.entered_cr, 0)) <> 0';

    BEGIN
      OPEN balances_cur
       FOR 'SELECT glbal.code_combination_id,
                   NVL(glbal.begin_balance_dr,0)+NVL(glbal.period_net_dr,0),
                   NVL(glbal.begin_balance_cr,0)+NVL(glbal.period_net_cr,0),
                   glbal.period_num,
                   fa.public_law_code,
                   fa.advance_flag,
                   fa.transfer_flag,
                   fa.account,
                   fa.ussgl_account,
                   gcc.segment1,
                   gcc.segment2,
                   gcc.segment3,
                   gcc.segment4,
                   gcc.segment5,
                   gcc.segment6,
                   gcc.segment7,
                   gcc.segment8,
                   gcc.segment9,
                   gcc.segment10,
                   gcc.segment11,
                   gcc.segment12,
                   gcc.segment13,
                   gcc.segment14,
                   gcc.segment15,
                   gcc.segment16,
                   gcc.segment17,
                   gcc.segment18,
                   gcc.segment19,
                   gcc.segment20,
                   gcc.segment21,
                   gcc.segment22,
                   gcc.segment23,
                   gcc.segment24,
                   gcc.segment25,
                   gcc.segment26,
                   gcc.segment27,
                   gcc.segment28,
                   gcc.segment29,
                   gcc.segment30,'||
                   'gcc.'||p_bal_segment||'
              FROM gl_balances glbal,
                   gl_code_combinations gcc,
                   fv_factsii_accounts_gt fa
             WHERE glbal.ledger_id = :b_set_of_books_id
               AND glbal.period_year = :b_period_year
               AND glbal.period_num = :b_period_num
               AND glbal.template_id IS NULL
               AND glbal.actual_flag = ''A''
               AND glbal.currency_code = :b_currency_code
               AND gcc.code_combination_id = glbal.code_combination_id
               AND gcc.'||p_acct_segment||' = fa.account
               AND ((NVL(glbal.begin_balance_dr,0)+NVL(glbal.period_net_dr,0))-
                   (NVL(glbal.begin_balance_cr,0)+NVL(glbal.period_net_cr,0))) <> 0
                   order by gcc.'||p_bal_segment
      USING p_ledger_id,
            p_fiscal_year,
            p_last_period_num,
            'USD';

    EXCEPTION
      WHEN OTHERS THEN
        p_error_code := g_FAILURE;
        p_error_desc := SQLERRM;
        l_location   := l_module_name||'open_balances_cur';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    END;

    IF (p_error_code = g_SUCCESS) THEN
      LOOP
        BEGIN
          FETCH balances_cur
           INTO l_code_combination_id,
                l_ending_balance_dr,
                l_ending_balance_cr,
                l_period_num,
                l_public_law_code,
                l_advance_flag,
                l_transfer_flag,
                l_account,
                l_ussgl_account,
                l_segment(1),
                l_segment(2),
                l_segment(3),
                l_segment(4),
                l_segment(5),
                l_segment(6),
                l_segment(7),
                l_segment(8),
                l_segment(9),
                l_segment(10),
                l_segment(11),
                l_segment(12),
                l_segment(13),
                l_segment(14),
                l_segment(15),
                l_segment(16),
                l_segment(17),
                l_segment(18),
                l_segment(19),
                l_segment(20),
                l_segment(21),
                l_segment(22),
                l_segment(23),
                l_segment(24),
                l_segment(25),
                l_segment(26),
                l_segment(27),
                l_segment(28),
                l_segment(29),
                l_segment(30),
                l_fund;
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := g_FAILURE;
            p_error_desc := SQLERRM;
            l_location   := l_module_name||'open_balances_cur';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
        END;

        IF (p_error_code = g_SUCCESS) THEN
          IF balances_cur%NOTFOUND THEN
            EXIT;
          END IF;
        END IF;

        IF (p_error_code = g_SUCCESS) THEN
          get_treasury_info
          (
            p_ledger_id          => p_ledger_id,
            p_fund_value         => l_fund,
            p_treasury_symbol_id => l_treasury_symbol_id,
            p_cohort_segment     => l_cohort_segment,
            p_error_code         => p_error_code,
            p_error_desc         => p_error_desc
          );
        END IF;

        IF (p_error_code = g_SUCCESS) THEN
          l_fyr := l_segment(SUBSTR(p_fyr_segment, 8));
          IF (l_cohort_segment IS NOT NULL) THEN
            l_cohort := l_segment(SUBSTR(l_cohort_segment, 8));
          ELSE
            l_cohort := NULL;
          END IF;
        END IF;

        IF (p_error_code = g_SUCCESS) THEN
          BEGIN
            l_gl_cursor_id := dbms_sql.open_cursor;
          EXCEPTION
            WHEN OTHERS THEN
              p_error_code := g_FAILURE;
              p_error_desc := SQLERRM;
              l_location   := l_module_name||'open_gl_cur';
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
          END;
        END IF;

        IF (p_error_code = g_SUCCESS) THEN
          BEGIN
            dbms_sql.parse(l_gl_cursor_id, l_gl_cursor_str, dbms_sql.v7);
          EXCEPTION
            WHEN OTHERS THEN
              p_error_code := g_FAILURE;
              p_error_desc := SQLERRM;
              l_location   := l_module_name||'parse_gl_cur';
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
          END;
        END IF;

        IF (p_error_code = g_SUCCESS) THEN
          BEGIN
            dbms_sql.bind_variable(l_gl_cursor_id,':b_period_year', p_fiscal_year);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_code_combination_id', l_code_combination_id);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_account', l_account);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_ussgl_account', l_ussgl_account);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_fund', l_fund);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_fyr', l_fyr);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_cohort', l_cohort);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_public_law_code', l_public_law_code);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_advance_flag', l_advance_flag);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_transfer_flag', l_transfer_flag);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_curr_date', l_system_date);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_user_id', g_user_id);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_request_id', g_request_id);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_treasury_symbol_id', l_treasury_symbol_id);
            dbms_sql.bind_variable(l_gl_cursor_id,':b_set_of_books_id', p_ledger_id);
          EXCEPTION
            WHEN OTHERS THEN
              p_error_code := g_FAILURE;
              p_error_desc := SQLERRM;
              l_location   := l_module_name||'bind_gl_cur';
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
          END;
        END IF;

        IF (p_error_code = g_SUCCESS) THEN
          BEGIN
            l_gl_cursor_ret := dbms_sql.execute(l_gl_cursor_id);
          EXCEPTION
            WHEN OTHERS THEN
              p_error_code := g_FAILURE;
              p_error_desc := SQLERRM;
              l_location   := l_module_name||'execute_gl_cur';
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
          END;
        END IF;

        IF (p_error_code = g_SUCCESS) THEN
          BEGIN
            dbms_sql.close_cursor(l_gl_cursor_id);
          EXCEPTION
            WHEN OTHERS THEN
              p_error_code := g_FAILURE;
              p_error_desc := SQLERRM;
              l_location   := l_module_name||'close_gl_cur';
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
          END;
        END IF;
        IF (p_error_code = g_SUCCESS) THEN
          FOR previous_year_rec IN (SELECT *
                                      FROM fv_factsii_ending_balances ffeb
                                     WHERE ffeb.set_of_books_id = p_ledger_id
                                       AND ffeb.fiscal_year = p_fiscal_year-1
                                       AND ffeb.ccid = l_code_combination_id) LOOP
            BEGIN
              UPDATE fv_factsii_ending_balances ffeb
                 SET ffeb.ending_balance_cr = NVL(ffeb.ending_balance_cr, 0) + NVL(previous_year_rec.ending_balance_cr, 0),
                     ffeb.ending_balance_dr = NVL(ffeb.ending_balance_dr, 0) + NVL(previous_year_rec.ending_balance_dr, 0)
               WHERE ffeb.set_of_books_id = previous_year_rec.set_of_books_id
                 AND ffeb.fiscal_year = p_fiscal_year
                 AND ffeb.ccid = previous_year_rec.ccid
                 AND ffeb.public_law = previous_year_rec.public_law
                 AND ffeb.advance_flag = previous_year_rec.advance_flag
                 AND ffeb.transfer_dept_id = previous_year_rec.transfer_dept_id
                 AND ffeb.transfer_main_acct = previous_year_rec.transfer_main_acct;
              l_insert_required := FALSE;
              IF (SQL%ROWCOUNT = 0) THEN
                l_insert_required := TRUE;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                p_error_code := g_FAILURE;
                p_error_desc := SQLERRM;
                l_location   := l_module_name||'update_fv_factsii_ending_balances';
                fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
                fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
            END;

            IF (p_error_code = g_SUCCESS) THEN
              IF (l_insert_required) THEN
                BEGIN
                  INSERT INTO fv_factsii_ending_balances
                  (
                    set_of_books_id,
                    fiscal_year,
                    ccid,
                    account,
                    fund,
                    fyr,
                    cohort,
                    ussgl_account,
                    ending_balance_cr,
                    ending_balance_dr,
                    public_law,
                    advance_flag,
                    transfer_dept_id,
                    transfer_main_acct,
                    record_category,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_update_by,
                    request_id,
                    treasury_symbol_id
                  )
                  VALUES
                  (
                    previous_year_rec.set_of_books_id,
                    p_fiscal_year,
                    previous_year_rec.ccid,
                    previous_year_rec.account,
                    previous_year_rec.fund,
                    previous_year_rec.fyr,
                    previous_year_rec.cohort,
                    previous_year_rec.ussgl_account,
                    previous_year_rec.ending_balance_cr,
                    previous_year_rec.ending_balance_dr,
                    previous_year_rec.public_law,
                    previous_year_rec.advance_flag,
                    previous_year_rec.transfer_dept_id,
                    previous_year_rec.transfer_main_acct,
                    'E',
                    l_system_date,
                    g_user_id,
                    l_system_date,
                    g_user_id,
                    g_request_id,
                    previous_year_rec.treasury_symbol_id
                  );
                EXCEPTION
                  WHEN OTHERS THEN
                    p_error_code := g_FAILURE;
                    p_error_desc := SQLERRM;
                    l_location   := l_module_name||'insert_fv_factsii_ending_balances1';
                    fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
                    fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
                END;
              END IF;
            END IF;

          END LOOP;
        END IF;

        IF (p_error_code = g_SUCCESS) THEN
          BEGIN
            l_count_ccid := 0;
            SELECT COUNT (*)
              INTO l_count_ccid
              FROM fv_factsii_ending_balances ffeb
             WHERE ffeb.set_of_books_id = p_ledger_id
               AND ffeb.fiscal_year = p_fiscal_year
               AND ccid = l_code_combination_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_count_ccid := 0;
            WHEN OTHERS THEN
              p_error_code := g_FAILURE;
              p_error_desc := SQLERRM;
              l_location   := l_module_name||'select_fv_factsii_ending_balances';
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
          END;
        END IF;

        IF (p_error_code = g_SUCCESS) THEN
          IF (l_count_ccid <> 0) THEN
            BEGIN
              INSERT INTO fv_factsii_ending_balances
              (
                set_of_books_id,
                fiscal_year,
                ccid,
                account,
                fund,
                fyr,
                cohort,
                ussgl_account,
                ending_balance_cr,
                ending_balance_dr,
                public_law,
                advance_flag,
                transfer_dept_id,
                transfer_main_acct,
                record_category,
                creation_date,
                created_by,
                last_update_date,
                last_update_by,
                request_id,
                treasury_symbol_id
              )
              SELECT p_ledger_id,
                     p_fiscal_year,
                     ccid,
                     l_account,
                     l_fund,
                     l_fyr,
                     l_cohort,
                     l_ussgl_account,
                     l_ending_balance_cr-SUM(ending_balance_cr),
                     l_ending_balance_dr-SUM(ending_balance_dr),
                     DECODE (l_public_law_code, 'Y', '       ', NULL),
                     DECODE (l_advance_flag, 'Y', 'X', NULL),
                     DECODE (l_transfer_flag, 'Y','  ',NULL),
                     DECODE (l_transfer_flag, 'Y','    ',NULL),
                     'D',
                     l_system_date,
                     g_user_id,
                     l_system_date,
                     g_user_id,
                     g_request_id,
                     l_treasury_symbol_id
                FROM fv_factsii_ending_balances ffeb
               WHERE ffeb.set_of_books_id = p_ledger_id
                 AND ffeb.fiscal_year = p_fiscal_year
                 AND ccid = l_code_combination_id
               GROUP BY ccid
              HAVING (((l_ending_balance_cr-SUM(ending_balance_cr)) <> 0) OR
                      ((l_ending_balance_dr-SUM(ending_balance_dr)) <> 0)) AND
                      (l_ending_balance_cr-SUM(ending_balance_cr)) <> (l_ending_balance_dr-SUM(ending_balance_dr));
            EXCEPTION
              WHEN OTHERS THEN
                p_error_code := g_FAILURE;
                p_error_desc := SQLERRM;
                l_location   := l_module_name||'INSERT INTO fv_factsii_ending_balances';
                fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
                fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
            END;
          END IF;
        END IF;

        IF (p_error_code <> g_SUCCESS) THEN
          EXIT;
        END IF;

      END LOOP;
    END IF;

    IF balances_cur%ISOPEN THEN
      CLOSE balances_cur;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        DELETE fv_factsii_ending_balances ffeb1
         WHERE EXISTS (SELECT ffeb2.set_of_books_id,
                              ffeb2.ccid,
                              ffeb2.fiscal_year,
                              count(*)
                         FROM fv_factsii_ending_balances ffeb2
                        WHERE ffeb2.set_of_books_id = ffeb1.set_of_books_id
                          AND ffeb2.ccid = ffeb1.ccid
                          AND ffeb2.fiscal_year = ffeb1.fiscal_year
                        GROUP BY ffeb2.set_of_books_id,
                                 ffeb2.ccid,
                                 ffeb2.fiscal_year
                       HAVING count(*) = 1)
           AND RTRIM(ffeb1.public_law) IS NULL
           AND RTRIM(ffeb1.advance_flag) IS NULL
           AND RTRIM(ffeb1.transfer_dept_id) IS NULL
           AND RTRIM(ffeb1.transfer_main_acct) IS NULL;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'DELETE FROM fv_factsii_ending_balances1';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;


    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;


  --****************************************************************************************--
  --*          Name : derive_balances                                                      *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Main Entry point for the concurent program FVFCT2BB                  *--
  --*               : (FACTS II Ending Balance Detail)                                     *--
  --*               : set of books id and fiscal year.                                     *--
  --*    Parameters : p_ledger_id         IN Set Of Books Id                               *--
  --*               : p_fiscal_year       IN Fiscal Year                                   *--
  --*               : p_error_code        OUT Return Error Code                            *--
  --*               : p_error_desc        OUT Return Error Descion                         *--
  --*   Global Vars : fnd_log.g_current_runtime_level                                      *--
  --*               : fnd_log.level_procedure                                              *--
  --*               : fnd_log.level_statement                                              *--
  --*               : fnd_log.level_unexpected                                             *--
  --*               : g_module_name                                                        *--
  --*               : g_SUCCESS                                                            *--
  --*   Called from : derive_balances                                                      *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*               : initialize_program_variables                                         *--
  --*               : purge_balances                                                       *--
  --*               : explode_accounts                                                     *--
  --*               : start_processing                                                     *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : 1.
  --****************************************************************************************--
  PROCEDURE derive_balances
  (
    p_errbuff         OUT NOCOPY  VARCHAR2,
    p_retcode         OUT NOCOPY  NUMBER,
    p_ledger_id       IN NUMBER,
    p_fiscal_year     IN NUMBER
  )
  IS
    l_module_name            VARCHAR2(200);
    l_location               VARCHAR2(200);
    l_acct_segment           fnd_id_flex_segments.application_column_name%TYPE;
    l_bal_segment            fnd_id_flex_segments.application_column_name%TYPE;
    l_fyr_segment            fnd_id_flex_segments.application_column_name%TYPE;
    l_chart_of_accounts_id   gl_ledgers_public_v.chart_of_accounts_id%TYPE;
    l_acct_value_set_id      fnd_id_flex_segments.flex_value_set_id%TYPE;
    l_last_period_num        gl_balances.period_num%TYPE;
    l_pub_law_code_col       fv_system_parameters.factsii_pub_law_code_attribute%TYPE;
    l_advance_type_col       fv_system_parameters.factsii_advance_type_attribute%TYPE;
    l_tr_main_acct_col       fv_system_parameters.factsii_tr_main_acct_attribute%TYPE;
    l_tr_dept_id_col         fv_system_parameters.factsii_tr_dept_id_attribute%TYPE;
  BEGIN
    l_module_name := g_module_name || 'derive_balances';
    p_retcode     := g_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ledger_id = '||p_ledger_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_fiscal_year = '||p_fiscal_year);
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling initialize_program_variables');
      END IF;
      initialize_program_variables
      (
        p_ledger_id              => p_ledger_id,
        p_fiscal_year            => p_fiscal_year,
        p_last_period_num        => l_last_period_num,
        p_chart_of_accounts_id   => l_chart_of_accounts_id,
        p_acct_segment           => l_acct_segment,
        p_acct_value_set_id      => l_acct_value_set_id,
        p_bal_segment            => l_bal_segment,
        p_fyr_segment            => l_fyr_segment,
        p_pub_law_code_col       => l_pub_law_code_col,
        p_advance_type_col       => l_advance_type_col,
        p_tr_main_acct_col       => l_tr_main_acct_col,
        p_tr_dept_id_col         => l_tr_dept_id_col,
        p_error_code             => p_retcode,
        p_error_desc             => p_errbuff
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'initialize_program_variables returned '||p_retcode);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_chart_of_accounts_id='||l_chart_of_accounts_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_acct_segment='||l_acct_segment);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_acct_value_set_id='||l_acct_value_set_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_bal_segment='||l_bal_segment);
      END IF;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling purge_balances');
      END IF;
      purge_balances
      (
        p_ledger_id       => p_ledger_id,
        p_fiscal_year     => p_fiscal_year,
        p_error_code      => p_retcode,
        p_error_desc      => p_errbuff
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'purge_balances returned '||p_retcode);
      END IF;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling purge_balances');
      END IF;
      explode_accounts
      (
        p_ledger_id         => p_ledger_id,
        p_acct_value_set_id => l_acct_value_set_id,
        p_error_code        => p_retcode,
        p_error_desc        => p_errbuff
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'purge_balances returned '||p_retcode);
      END IF;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling start_processing');
      END IF;
      start_processing
      (
        p_ledger_id         => p_ledger_id,
        p_acct_segment      => l_acct_segment,
        p_bal_segment       => l_bal_segment,
        p_fyr_segment       => l_fyr_segment,
        p_fiscal_year       => p_fiscal_year,
        p_last_period_num   => l_last_period_num,
        p_pub_law_code_col  => l_pub_law_code_col,
        p_advance_type_col  => l_advance_type_col,
        p_tr_main_acct_col  => l_tr_main_acct_col,
        p_tr_dept_id_col    => l_tr_dept_id_col,
        p_error_code        => p_retcode,
        p_error_desc        => p_errbuff
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'start_processing returned '||p_retcode);
      END IF;
    END IF;

    IF (p_retcode = g_SUCCESS OR p_retcode = g_WARNING) THEN
      COMMIT;
    ELSE
      ROLLBACK;
    END IF;

    generate_output_report
    (
      p_ledger_id       => p_ledger_id,
      p_fiscal_year     => p_fiscal_year,
      p_error_code      => p_retcode,
      p_error_desc      => p_errbuff
    );

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuff := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuff) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
      END IF;
      ROLLBACK;
  END;
BEGIN
  initialize_global_variables;
END fv_facts2_derive_balances;

/
