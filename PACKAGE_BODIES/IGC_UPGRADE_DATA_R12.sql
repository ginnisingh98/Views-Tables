--------------------------------------------------------
--  DDL for Package Body IGC_UPGRADE_DATA_R12
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_UPGRADE_DATA_R12" AS
/*$Header: IGCUPGDB.pls 120.13 2008/02/26 13:50:13 mbremkum noship $ */

/*Global Variables - Start*/

G_PKG_NAME                      CONSTANT VARCHAR2(30) := 'IGC_UPGRADE_DATA_R12';
g_debug_level                   NUMBER :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_state_level                   NUMBER :=  FND_LOG.LEVEL_STATEMENT;
g_proc_level                    NUMBER :=  FND_LOG.LEVEL_PROCEDURE;
g_event_level                   NUMBER :=  FND_LOG.LEVEL_EVENT;
g_excep_level                   NUMBER :=  FND_LOG.LEVEL_EXCEPTION;
g_error_level                   NUMBER :=  FND_LOG.LEVEL_ERROR;
g_unexp_level                   NUMBER :=  FND_LOG.LEVEL_UNEXPECTED;
g_path                          VARCHAR2(255) := 'IGC.PLSQL.IGCUPGDB.IGC_UPGRADE_DATA_R12.';
g_debug_mode                  VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_sob_id                  NUMBER := 0;
g_sob_name      VARCHAR2(50) := NULL;
g_cbc_ledger_id                 gl_ledgers.ledger_id%TYPE := 0;
g_cbc_ledger_name               VARCHAR2(50) := NULL;
g_conc_pr_user FND_CONCURRENT_PROGRAMS_VL.user_concurrent_program_name%TYPE;

TYPE t_typ_errors IS RECORD
(error_mesg VARCHAR2(4000)
);
TYPE  t_tbl_errors IS TABLE of t_typ_errors INDEX BY BINARY_INTEGER;

TYPE t_typ_bud_map IS RECORD
(old_budget_name GL_BUDGETS.BUDGET_NAME%Type,
new_budget_name GL_BUDGETS.BUDGET_NAME%Type
);
TYPE  t_tbl_bud_map IS TABLE of t_typ_bud_map INDEX BY BINARY_INTEGER;

TYPE t_typ_bud_entity_map IS RECORD
(old_bud_entity gl_budget_entities.NAME%Type,
new_bud_entity gl_budget_entities.NAME%Type
);
TYPE  t_tbl_bud_entity_map IS TABLE of t_typ_bud_entity_map INDEX BY BINARY_INTEGER;

g_tbl_basic_errors  t_tbl_errors;
g_tbl_warnings  t_tbl_errors;
g_tbl_bud_map t_tbl_bud_map ;
g_tbl_bud_entity_map t_tbl_bud_entity_map;

g_final_out VARCHAR2(20) := 'SUCCESS';

/*Global Variables - End*/

/*Private Procedures or Functions - Start*/


PROCEDURE add_error (
   p_error_mesg IN VARCHAR2
);

PROCEDURE add_warning (
   p_error_mesg IN VARCHAR2
);

PROCEDURE set_final_out (
   p_final_out IN VARCHAR2
);

PROCEDURE add_bud_map (
   p_old_budget_name GL_BUDGETS.BUDGET_NAME%Type,
   p_new_budget_name GL_BUDGETS.BUDGET_NAME%Type
);

PROCEDURE add_bud_entity_map (
   p_old_bud_entity gl_budget_entities.NAME%Type,
   p_new_bud_entity gl_budget_entities.NAME%Type
);

PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
);

PROCEDURE Populate_Interface (p_fiscal_year     IN NUMBER,
        p_org_id    IN NUMBER,
        p_cc_header_id    IN NUMBER,
        p_category_name   IN VARCHAR2,
        p_transaction_date  IN DATE,
        p_cbc_je_batch_id IN NUMBER,
                                x_doc_type              OUT NOCOPY VARCHAR2);

PROCEDURE Migrate_cbc_lines (   errbuf    OUT NOCOPY  VARCHAR2,
          retcode   OUT NOCOPY  VARCHAR2,
          p_fiscal_year     IN NUMBER,
          p_org_id    IN NUMBER);

PROCEDURE GET_NEW_NAME  ( P_OLD_NAME IN  VARCHAR2,
        P_LEN      IN  NUMBER,
        P_FLAG     IN VARCHAR2,
        P_NEW_NAME IN OUT NOCOPY VARCHAR2);

PROCEDURE MIGRATE_GL_BUDGETS (  P_OLD_BUD_NAME IN VARCHAR2,
        P_MASTER_BUD_VER_ID IN NUMBER,
  P_BUDGET_VERSION_ID OUT NOCOPY GL_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
        P_LATEST_OPENED_YEAR OUT NOCOPY Gl_BUDGETS_V.LATEST_OPENED_YEAR%TYPE);


PROCEDURE GL_BUDGET_ORG ( P_BUDGET_NAME IN GL_BUDGETS.BUDGET_NAME%TYPE,
        P_BUDGET_VERSION_ID IN NUMBER,
        P_BUDGET_ENTITY_ID OUT NOCOPY NUMBER);

PROCEDURE submit_open_year  (P_sec_ledger_id IN Number,
        Bud_Version_Id IN NUMBER,
                                p_latest_open_year IN GL_BUDGETS_V.Latest_opened_year%type,
                                p_fiscal_year     IN NUMBER);

PROCEDURE migrate_cbc_bud_jounals(p_fiscal_year IN NUMBER);

PROCEDURE submit_assign_ranges(P_sec_ledger_id IN Number,
p_bud_entity_id IN Number);

PROCEDURE migrate_sum_templates;

FUNCTION get_cbc_budget_name(p_pri_budget_name IN VARCHAR2) RETURN VARCHAR2;
/*Private Procedures or Functions - End*/

/*Moved this procedure definition from the package spec to the package body - Bug 6847410*/

PROCEDURE Migrate_Budgets(p_fiscal_year IN Number,
p_org_id IN Number,
p_period_set_name       IN gl_sets_of_books.period_set_name%type,
p_accounted_period_type  IN gl_sets_of_books.accounted_period_type%type);

PROCEDURE validate_basic(p_org_id IN Number,
  p_fin_year    IN NUMBER,
  p_balance_type IN VARCHAR2,
  x_return_code OUT NOCOPY  NUMBER,
  x_msg_buf     OUT NOCOPY  VARCHAR2
);

FUNCTION check_request(p_request_id IN NUMBER) RETURN NUMBER;

PROCEDURE print_header(p_balance_type    IN VARCHAR2,
          p_mode    IN VARCHAR2,
          p_fiscal_year IN NUMBER);

PROCEDURE print_errors;

PROCEDURE print_enc_stat(p_fiscal_year IN NUMBER);

PROCEDURE print_enc_exceptions(p_fiscal_year IN NUMBER);

PROCEDURE print_budget_stats;

PROCEDURE print_end_report;

PROCEDURE Validate_Setup_and_Migrate (  errbuf    OUT NOCOPY  VARCHAR2,
          retcode   OUT NOCOPY  VARCHAR2,
          p_balance_type    IN VARCHAR2,
          p_mode    IN VARCHAR2,
          p_fiscal_year IN NUMBER) IS

l_period_set_name               gl_sets_of_books.period_set_name%TYPE;
l_accounted_period_type         gl_sets_of_books.accounted_period_type%TYPE;
l_number_per_fiscal_year        gl_period_types.number_per_fiscal_year%TYPE;
l_open_periods                  NUMBER;

l_full_path VARCHAR2(255);
l_org_id  NUMBER;
l_return_num NUMBER := 1;


BEGIN
  retcode := 0;
  l_full_path := g_path || 'Validate_Setup_and_Migrate';

  l_org_id := MO_GLOBAL.get_current_org_id;

  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'ORG ID: ' || l_org_id);
  END IF;

    /*Obtain Set of Books Name and ID*/

    MO_UTILS.get_ledger_info(l_org_id, g_sob_id, g_sob_name);

  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'SOB ID: ' || g_sob_id);
    Put_Debug_Msg(l_full_path, 'Balance Type: ' || p_balance_type);
  END IF;

  print_header(p_balance_type,p_mode,p_fiscal_year);

  validate_basic(l_org_id,p_fiscal_year,p_balance_type,retcode,errbuf);
  IF retcode = 2 THEN
    print_errors;
    return;
    --APP_EXCEPTION.Raise_Exception;
  END IF;

  SELECT period_set_name, accounted_period_type
  INTO l_period_set_name, l_accounted_period_type
  FROM gl_sets_of_books
  WHERE set_of_books_id = g_sob_id;

  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'Accounting Period Type: ' || l_accounted_period_type);
  END IF;

IF (p_mode = 'P') THEN

  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'Preliminary Mode - Return after Validation');
  END IF;
  print_errors;
  RETURN;
ELSIF (p_mode = 'F') THEN
  /* Call Migrate Budgets procedure to migrate budgets and budget org information */
  IF p_balance_type = 'B' THEN
    Migrate_Budgets(p_fiscal_year, l_org_id,l_period_set_name,
    l_accounted_period_type);
    migrate_cbc_bud_jounals(p_fiscal_year);
    print_errors;
    print_budget_stats;
    print_end_report;

  ELSIF p_balance_type = 'E' THEN
    /*Reset all failure result codes in IGC_CBC_JE_LINES*/
    UPDATE igc_cbc_je_lines
    SET mig_result_code = NULL,
    mig_request_id = NULL
    WHERE set_of_books_id = g_sob_id
    AND substr(mig_result_code, 0, 1) = 'F'
    AND mig_result_code IS NOT NULL
    AND period_year = p_fiscal_year
    AND actual_flag = 'E';

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Reset Failure Result Codes: ' || SQL%ROWCOUNT);
    END IF;

    COMMIT;

    /*Call Migrate only if mode is FINAL*/
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Calling Migrate CBC lines - Final Mode');
    END IF;

    Migrate_cbc_lines(errbuf, retcode, p_fiscal_year, l_org_id);
    commit;
    print_errors;
    print_enc_stat(p_fiscal_year);
    print_enc_exceptions(p_fiscal_year);
    print_end_report;
  END IF;
END IF;

EXCEPTION
WHEN OTHERS THEN
        errbuf := SQLERRM;
        retcode := 2;
        IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'CBC Migration Failed with: ' || errbuf);
        END IF;

END Validate_Setup_and_Migrate;


PROCEDURE Migrate_cbc_lines (   errbuf    OUT NOCOPY  VARCHAR2,
          retcode   OUT NOCOPY  VARCHAR2,
          p_fiscal_year     IN NUMBER,
        p_org_id    IN NUMBER) IS

  CURSOR c_cbc_line IS
  SELECT DISTINCT reference_1, effective_date, je_category, cbc_je_batch_id,
  decode(je_category, 'Provisional', '1', 'Confirmed', '2', 'Budget', '3', 'Requisitions', '1', 'Purchases', '2', '99') seq
  FROM igc_cbc_je_lines
  WHERE mig_result_code IS NULL
  AND   mig_request_id IS NULL
  AND period_year = p_fiscal_year
  AND set_of_books_id = g_sob_id
  ORDER BY reference_1, seq;

  l_full_path VARCHAR2(255);
  l_cbc_line      c_cbc_line%ROWTYPE;
  x_ret_status    VARCHAR2(5);
  x_batch_result_code     VARCHAR2(5);
  l_doc_type      VARCHAR2(3);
  l_return_status BOOLEAN;

BEGIN

  l_full_path := g_path || 'Migrate_cbc_lines';

  retcode := 0;
  errbuf:= '';

  OPEN c_cbc_line;

  LOOP
    FETCH c_cbc_line INTO l_cbc_line;
    EXIT WHEN c_cbc_line%NOTFOUND;

    l_doc_type := NULL;

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'CC Header ID: ' || l_cbc_line.reference_1 || ' Category: ' || l_cbc_line.je_category || ' Effective Date: ' || l_cbc_line.effective_date || ' CBC JE Batch ID: ' || l_cbc_line.cbc_je_batch_id);
    END IF;

    Populate_Interface (p_fiscal_year,
                        p_org_id,
                        l_cbc_line.reference_1,
                        l_cbc_line.je_category,
                        l_cbc_line.effective_date,
                        l_cbc_line.cbc_je_batch_id,
                        l_doc_type);

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Document Type: ' || l_doc_type);
    END IF;

    -- commit after populating interface table
    COMMIT;

    l_return_status := IGC_CBC_FUNDS_CHECKER.IGCFCK (g_sob_id,         /*SOB ID*/
                               l_cbc_line.reference_1,                 /*CC Header ID*/
                               'R',                                    /*Call Funds Check in Reserve Mode*/
                               'E',                                    /*Actual Flag = 'E' i.e. Encumbrance*/
                               l_doc_type,
                               x_ret_status,
                               x_batch_result_code,
                               FND_API.G_FALSE,
                               FND_API.G_FALSE);

    IF x_batch_result_code IN ('H00','H04','H12') THEN

	FND_MESSAGE.set_name('IGC','IGC_CC_CBC_RESULT_CODE_'||x_batch_result_code);
        errbuf := FND_MESSAGE.get;
        retcode := 1;

    END IF;

    IF l_return_status = FALSE  and x_batch_result_code IS NULL THEN
        errbuf := 'Unexpected Error occured during Migration';
        retcode := 2;
	return;
    END IF;

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Funds Check Result Code for CC Header ID ' || l_cbc_line.reference_1 || ': ' || x_batch_result_code);
    END IF;

    /*Update Result Codes in igc_cbc_je_lines for Exception reporting and to ensure CP rerun does not cause issues*/

    /*Update Request ID of the CBC Upgrade Concurrent program*/

    UPDATE igc_cbc_je_lines
    SET mig_request_id = FND_GLOBAL.CONC_REQUEST_ID
    WHERE reference_1 = l_cbc_line.reference_1
    AND je_category = l_cbc_line.je_category
    AND effective_date = l_cbc_line.effective_date
    AND cbc_je_batch_id = l_cbc_line.cbc_je_batch_id;

    /*Update CBC result Codes into IGC_CBC_JE_LINES from IGC_CC_INTERFACE to print Exception Report*/

    UPDATE igc_cbc_je_lines ijl
    SET (mig_result_code) = (SELECT cbc_result_code
                                 FROM igc_cc_interface ict
                                 WHERE ijl.reference_1 = ict.cc_header_id
                                 AND ijl.effective_date = ict.cc_transaction_date
                                 AND NVL(ijl.je_category, '') = NVL(ict.je_category_name, '')
                                 AND ijl.code_combination_id = ict.code_combination_id)
    WHERE ijl.reference_1 = l_cbc_line.reference_1
    AND je_category = l_cbc_line.je_category
    AND effective_date = l_cbc_line.effective_date
    AND cbc_je_batch_id = l_cbc_line.cbc_je_batch_id;

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Updating Result Code. Number of rows updated: ' || SQL%ROWCOUNT);
    END IF;

    /*Entries in igc_cc_interface needs to be flushed as rerun of the CP may cause issues */
    DELETE FROM igc_cc_interface
    WHERE reference_8 = 'MIG';

    commit;
  END LOOP;

  EXCEPTION

  WHEN OTHERS THEN
          IF (g_debug_mode = 'Y') THEN
            Put_Debug_Msg(l_full_path, SQLERRM);
          END IF;
          /*Added by mbremkum*/
          APP_EXCEPTION.Raise_Exception;

END Migrate_cbc_lines;


PROCEDURE Populate_Interface (  p_fiscal_year     IN NUMBER,
        p_org_id    IN NUMBER,
        p_cc_header_id    IN NUMBER,
        p_category_name   IN VARCHAR2,
        p_transaction_date  IN DATE,
        p_cbc_je_batch_id IN NUMBER,
        x_doc_type        OUT NOCOPY VARCHAR2) IS

  CURSOR c_cbc_je_lines IS
  SELECT  icj.reference_1,
    icj.reference_3,
    icj.reference_2,
    icj.code_combination_id,
    icj.cbc_je_line_num,
    icj.effective_date,
    icj.entered_dr,
    icj.entered_cr,
    icj.je_source,
    icj.je_category,
    icj.period_name,
    icj.actual_flag,
    'C',
    icj.set_of_books_id,
    icj.description,
    icj.posted_date,
    DECODE(icj.je_source,'Contract Commitment','CC','Project Accounting','PA','Requisitions','REQ','Purchasing','PO','INV'),
    icj.currency_code
  FROM igc_cbc_je_lines icj, gl_code_combinations gcc
  WHERE icj.set_of_books_id = g_sob_id
  AND icj.reference_1 = p_cc_header_id
  AND icj.je_category = p_category_name
  AND icj.effective_date = p_transaction_date
  AND icj.cbc_je_batch_id = p_cbc_je_batch_id
  AND icj.period_year = p_fiscal_year
  AND icj.actual_flag = 'E'
  AND icj.mig_result_code IS NULL                      /*Only Records NOT migrated are processed*/
  AND icj.code_combination_id = gcc.code_combination_id
  AND gcc.summary_flag = 'N';       /*Migrate only for Detailed Records*/

  l_cbc_je_lines  c_cbc_je_lines%ROWTYPE;
  l_reference_4 VARCHAR2(240);
  l_full_path VARCHAR2(255);

BEGIN

  l_full_path := g_path || 'Populate_Interface';

  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'In Populate_Interface');
    Put_Debug_Msg(l_full_path, 'Parameters Fiscal Year:' || p_fiscal_year ||' CC Header ID: ' || p_cc_header_id || ' OrgID: ' ||p_org_id || ' CBC JE Batch ID: ' || p_cbc_je_batch_id || ' Category: ' || p_category_name);
  END IF;

  OPEN c_cbc_je_lines;
  LOOP

    FETCH c_cbc_je_lines INTO l_cbc_je_lines;
    EXIT WHEN c_cbc_je_lines%NOTFOUND;

    SELECT decode(l_cbc_je_lines.JE_SOURCE, 'Contract Commitment', 'CC', 'Project Accounting', 'PA', 'Requisitions', 'REQ', 'Purchasing', 'PO', 'INV')
    INTO x_doc_type
    FROM DUAL;

    INSERT INTO igc_cc_interface(
    CC_HEADER_ID,
    CC_VERSION_NUM,
    CC_ACCT_LINE_ID,
    CC_DET_PF_LINE_ID,
    CODE_COMBINATION_ID,
    BATCH_LINE_NUM,
    CC_TRANSACTION_DATE,
    CC_FUNC_DR_AMT,
    CC_FUNC_CR_AMT,
    JE_SOURCE_NAME,
    JE_CATEGORY_NAME,
    PERIOD_SET_NAME,
    PERIOD_NAME,
    ACTUAL_FLAG,
    BUDGET_DEST_FLAG,
    SET_OF_BOOKS_ID,
    CBC_RESULT_CODE,
    STATUS_CODE,
    REFERENCE_1,
    REFERENCE_2,
    REFERENCE_3,
    REFERENCE_8,
    BATCH_ID,
    BUDGET_VERSION_ID,
    TRANSACTION_DESCRIPTION,
    CC_ENCMBRNC_DATE,
    DOCUMENT_TYPE,
    CURRENCY_CODE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY
    )

    VALUES(
    l_cbc_je_lines.REFERENCE_1,
    l_cbc_je_lines.REFERENCE_3,
    l_cbc_je_lines.REFERENCE_2,
    NULL,
    l_cbc_je_lines.CODE_COMBINATION_ID,
    l_cbc_je_lines.CBC_JE_LINE_NUM,
    l_cbc_je_lines.EFFECTIVE_DATE,
    l_cbc_je_lines.ENTERED_DR,
    l_cbc_je_lines.ENTERED_CR,
    l_cbc_je_lines.JE_SOURCE,
    l_cbc_je_lines.JE_CATEGORY,
    NULL,
    l_cbc_je_lines.PERIOD_NAME,
    l_cbc_je_lines.ACTUAL_FLAG,
    'C',
    l_cbc_je_lines.SET_OF_BOOKS_ID,
    NULL,
    NULL,
    l_cbc_je_lines.REFERENCE_1,
    l_cbc_je_lines.REFERENCE_2,
    l_cbc_je_lines.REFERENCE_3,
          'MIG',
    NULL,
    NULL,
    l_cbc_je_lines.DESCRIPTION,
    l_cbc_je_lines.POSTED_DATE,
    x_doc_type,
    l_cbc_je_lines.CURRENCY_CODE ,
    sysdate,
    -1,
    sysdate,
    -1
    );

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Number of rows Inserted: ' || SQL%ROWCOUNT);
    END IF;

    IF (l_cbc_je_lines.JE_SOURCE = 'Project Accounting') THEN
      SELECT distinct segment1 INTO l_reference_4 FROM pa_projects_all p, pa_budget_versions bv
      WHERE p.project_id = bv.project_id AND bv.budget_version_id = p_cc_header_id;
    ELSIF (l_cbc_je_lines.JE_SOURCE = 'Purchasing') THEN
      SELECT distinct segment1 INTO l_reference_4 FROM PO_HEADERS_ALL
      WHERE po_header_id = p_cc_header_id;
    ELSIF (l_cbc_je_lines.JE_SOURCE = 'Requisitions') THEN
      SELECT distinct segment1 INTO l_reference_4 FROM PO_REQUISITION_HEADERS_ALL
      WHERE requisition_header_id = p_cc_header_id;
    ELSIF (l_cbc_je_lines.JE_SOURCE = 'Contract Commitment') THEN
      BEGIN
        SELECT distinct cc_num INTO l_reference_4 FROM igc_cc_headers_all
        WHERE cc_header_id = p_cc_header_id;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_reference_4 := null;
      END;
    END IF;

    IF l_reference_4 IS NULL THEN
      l_reference_4 := SUBSTR(l_cbc_je_lines.DESCRIPTION,0,INSTR(l_cbc_je_lines.DESCRIPTION, ' ')-1);
    END IF;

    IF (g_debug_mode = 'Y') THEN
            Put_Debug_Msg(l_full_path, 'Reference 4: ' || l_reference_4);
    END IF;

    UPDATE igc_cc_interface
    SET reference_4 = l_reference_4
    WHERE cc_header_id = p_cc_header_id;

  END LOOP;

  CLOSE c_cbc_je_lines;

  EXCEPTION

  WHEN OTHERS THEN
          IF (g_debug_mode = 'Y') THEN
            Put_Debug_Msg(l_full_path, SQLERRM);
          END IF;
          /*Added by mbremkum*/
          APP_EXCEPTION.Raise_Exception;

END Populate_Interface;


/* Start of changes for Budgets Migration */

PROCEDURE Migrate_Budgets(p_fiscal_year IN Number,
                p_org_id IN Number,
                p_period_set_name IN gl_sets_of_books.period_set_name%type,
                p_accounted_period_type IN gl_sets_of_books.accounted_period_type%type) IS

    v_period_start_num  gl_periods.period_num%type;
    v_period_end_num  gl_periods.period_num%type;
    v_period_start_name gl_budgets.first_valid_period_name%type;
    v_period_end_name  gl_budgets.last_valid_period_name%type;
    v_budget_version_id gl_budget_versions.budget_version_id%type;
    v_latest_opened_year  gl_budgets_v.LATEST_OPENED_YEAR%type;

    v_bud_entity_id gl_budget_entities.budget_entity_id%type;
    l_full_path VARCHAR2(255);

    cursor c_budget_cur is Select budget_name
    from gl_budgets_v
    where ledger_id =  g_sob_id
    and first_valid_period_name = v_period_start_name
    and last_valid_period_name = v_period_end_name
    and master_budget_version_id is null;

    cursor c_master_cur is Select budget_name,master_budget_version_id
    from gl_budgets_v
    where ledger_id =  g_sob_id
    and first_valid_period_name = v_period_start_name
    and last_valid_period_name = v_period_end_name
    and master_budget_version_id is not null;

  Begin

    l_full_path := g_path || 'Migrate_Budgets';
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Primary Ledger ID ' || g_sob_id );
    END IF;
    select min(period_num),max(period_num)
    into v_period_start_num,v_period_end_num
    from gl_periods
    where period_set_name = p_period_set_name
    and   period_year = p_fiscal_year
          and  Period_type = p_accounted_period_type ;

          select period_name into v_period_start_name from gl_periods where period_num = v_period_start_num
          and period_set_name = p_period_set_name
    and   period_year = p_fiscal_year
          and  Period_type = p_accounted_period_type;

          select period_name into v_period_end_name from gl_periods where period_num = v_period_end_num
          and period_set_name = p_period_set_name
    and   period_year = p_fiscal_year
          and  Period_type = p_accounted_period_type;

    For c1 in c_budget_cur
    Loop

      Migrate_GL_Budgets(c1.budget_name,NULL,v_budget_version_id,v_latest_opened_year);

      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'New Budget Version Id created for new budget ' || v_budget_version_id );
      END IF;
      submit_open_year(g_cbc_ledger_id,v_budget_version_id,v_latest_opened_year,p_fiscal_year);
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Completed GL Submit Open year');
      END IF;
      GL_Budget_Org(c1.budget_name,v_budget_version_id,v_bud_entity_id);
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Completed GL_Budget_Org');
      END IF;
      Commit; --Need to commit before submitting "assign Budget ranges " program.
      submit_assign_ranges(g_cbc_ledger_id,v_bud_entity_id);
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Completed submit_assign_ranges');
      END IF;
    end loop;
    Commit; --We need to commit all orphan budgets first .
    FOR  c2 in c_master_cur
    LOOP
      Migrate_GL_Budgets(c2.budget_name,c2.master_budget_version_id,
      v_budget_version_id,v_latest_opened_year);

      submit_open_year(g_cbc_ledger_id,v_budget_version_id,v_latest_opened_year,p_fiscal_year);
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Completed GL Submit Open year');
      END IF;
      GL_Budget_Org(c2.budget_name,v_budget_version_id,v_bud_entity_id);
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Completed GL_Budget_Org');
      END IF;
      Commit; --Need to commit before submitting "assign Budget ranges " program.
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Completed GL Budget Org');
      END IF;
      submit_assign_ranges(g_cbc_ledger_id,v_bud_entity_id);
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Completed submit_assign_ranges');
      END IF;
    END Loop;
    Commit;
    migrate_sum_templates;
EXCEPTION
  WHEN OTHERS THEN
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, SQLERRM);
  END IF;
  /*Added by mbremkum*/
  APP_EXCEPTION.Raise_Exception;
END Migrate_Budgets;

PROCEDURE get_new_name(p_old_name in varchar2,
                      p_len in number,p_flag IN varchar2,
                      p_new_name in out NOCOPY varchar2) IS
  cnt number;
  l_full_path VARCHAR2(255);
BEGIN
  l_full_path := g_path || 'get_new_name';

  if lengthb(p_old_name) <= p_len then
    select p_old_name||'_MIG' into p_new_name from dual;

  else
    select substrb(p_old_name,1,decode(instrb(p_old_name,'_',-1),p_len,p_len-1,p_len))||'_MIG' into p_new_name
    from dual;

  end if;
  IF p_flag = 'BUD' THEN
    select count(*) into cnt from gl_budgets
    where budget_name = p_new_name
    and description not like '%R12_MIG_'||p_old_name;
  ELSIF  p_flag = 'ORG' THEN
    select count(*) into cnt from  gl_budget_entities
    Where name = p_new_name
    and description not like '%R12_MIG_'||p_old_name;
  ELSE
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Input passed to p_flag parameter should be either BUD or ORG ');
    END IF;

    cnt := 0;
  END IF;

  IF cnt <>0 and p_len >1 then
    get_new_name(p_old_name,p_len-1,p_flag,p_new_name);
  else
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'If new name does not exist ,then exiting from recursive function');
    END IF;

  end if;
end get_new_name;


PROCEDURE Migrate_GL_Budgets(p_old_bud_name in varchar2, p_Master_Bud_Ver_Id in number,
                  p_budget_version_id Out NOCOPY gl_budget_versions.budget_version_id%type,
                  p_latest_opened_year OUT NOCOPY gl_budgets_v.LATEST_OPENED_YEAR%type) is

  v_new_budget gl_budgets.budget_name%type;

  --p_budget_version_id  gl_budget_versions.budget_version_id%type;

  V_Master_Budget_Version_Id  gl_budget_versions.budget_version_id%type;
  BUDGET gl_budgets%rowtype;

  v_row_id varchar2(50) := NULL;
  l_full_path VARCHAR2(255);
  CURSOR bud_cur(c_new_budget IN varchar2) IS
  select budget_version_id, latest_opened_year
  FROM    gl_budgets_v
  WHERE   budget_name = c_new_budget;
BEGIN
  l_full_path := g_path || 'Migrate_GL_Budgets';
  get_new_name(p_old_bud_name,11,'BUD',v_new_budget);

  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'New Budget Name created: ' || v_new_budget);
  END IF;

  OPEN bud_cur(v_new_budget);
  LOOP
    FETCH bud_cur
    into p_budget_version_id, p_latest_opened_year;
    IF bud_cur%rowcount = 0 THEN
    BEGIN
      select * into BUDGET
      from gl_budgets
      where budget_name = p_old_bud_name;
      p_budget_version_id := gl_budgets_pkg.get_unique_id;

      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'New Budget Version ID created: ' || p_budget_version_id );
      END IF;

      if length(BUDGET.Description) > 215 then
        BUDGET.Description := substrb(BUDGET.Description,1,215)||'R12_MIG_'||BUDGET.budget_name;
      else
        BUDGET.Description := BUDGET.Description||'R12_MIG_'||BUDGET.budget_name;
      End if;

     GL_BUDGETS_PKG.Insert_Row(
          X_Rowid                    => v_row_id,
          X_Budget_Type              => BUDGET.Budget_Type,
          X_Budget_Name              => v_new_budget,
          X_ledger_Id                => g_cbc_ledger_id,
          X_Status                   => 'O', --BUDGET.Status,
          X_Date_Created             => BUDGET.Date_Created,
          X_Require_Budget_Journals_flag => BUDGET.Require_Budget_Journals_Flag,
          X_Current_Version_Id       => BUDGET.Current_Version_Id,
          X_Latest_Opened_Year       => NULL,
          X_First_Valid_Period_Name  => BUDGET.First_Valid_Period_Name,
          X_Last_Valid_Period_Name   => BUDGET.Last_Valid_Period_Name,
          X_Description              => BUDGET.Description,
          X_Date_Closed              => BUDGET.Date_Closed,
          X_Attribute1               => BUDGET.Attribute1,
          X_Attribute2               => BUDGET.Attribute2,
          X_Attribute3               => BUDGET.Attribute3,
          X_Attribute4               => BUDGET.Attribute4,
          X_Attribute5               => BUDGET.Attribute5,
          X_Attribute6               => BUDGET.Attribute6,
          X_Attribute7               => BUDGET.Attribute7,
          X_Attribute8               => BUDGET.Attribute8,
          X_Context                  => BUDGET.Context,
          X_User_Id      => BUDGET.Created_By,
          X_Login_Id     => BUDGET.Last_Update_Login,
          X_Date       => BUDGET.Creation_Date,
          X_Budget_Version_Id        => p_budget_version_id,
          X_Master_Budget_Version_Id => p_Master_Bud_Ver_Id);

      add_bud_map(p_old_bud_name,v_new_budget);
    END;
    END IF;
    EXIT when bud_cur%notfound;
  END LOOP;
  CLOSE bud_cur;
EXCEPTION
  WHEN OTHERS THEN
    IF bud_cur%ISOPEN THEN
      CLOSE bud_cur;
    END IF;
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Exception occured in Migrate_GL_Budgets' || SQLERRM);
    END IF;
    /*Added by mbremkum*/
    APP_EXCEPTION.Raise_Exception;
END Migrate_GL_Budgets;


PROCEDURE GL_Budget_Org(P_BUDGET_NAME In gl_budgets.budget_name%type,
                        P_budget_version_id IN Number,
                        p_budget_entity_id out NOCOPY number) IS

  v_budget_entity_id gl_budget_entities.budget_entity_id%type;
  X_Name gl_budget_entities.name%type;
  bud_org_rec gl_budget_entities%rowtype;
  /* Cursor to loop through all account ranges defined for a budget organization */
  Cursor range_cur is SELECT *
  FROM GL_BUDGET_ASSIGNMENT_RANGES
  WHERE budget_entity_id = v_budget_entity_id;

  /* Cursor to loop through all funding budgets assigned to a specific account range */
  CURSOR BC_CUR(p_range_id IN Number)  IS
  Select * from GL_BUDORG_BC_OPTIONS
  Where RANGE_ID = p_range_id;
  v_range_id varchar2(100) := NULL;
  V_Org_Description gl_budget_entities.description%type;
  v_cbc_override gl_budorg_bc_options.funds_check_level_code%type;
  v_coa_id  gl_ledgers.chart_of_accounts_id%type;
  v_new_range_id GL_BUDGET_ASSIGNMENT_RANGES.range_id%type;
  l_full_path VARCHAR2(255);
  /* Cursor to check whether the new organization is already migrated */
  CURSOR budorg_cur(c_new_org_name IN VARCHAR2) IS
  SELECT budget_entity_id  from gl_budget_entities where name = c_new_org_name;

BEGIN

  l_full_path := g_path || 'GL_Budget_Org';

  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'Starting');
  END IF;

  BEGIN
    SELECT  distinct budget_entity_id  into v_budget_entity_id
    FROM GL_BUDGET_ASSIGNMENT_RANGES_V
    WHERE range_id IN
    ( Select  range_id  From  GL_BUDORG_BC_OPTIONS_V
    Where FUNDING_BUDGET_NAME= P_BUDGET_NAME);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return;
  END;

  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'Old Budget Entity ID: ' || v_budget_entity_id );
  END IF;

  select * into bud_org_rec from gl_budget_entities
  where budget_entity_id = v_budget_entity_id;

  get_new_name(bud_org_rec.name,21,'ORG',X_Name);
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'New Budget Entity ID: ' || p_budget_entity_id ||' New Budget Org Name: '|| X_Name );
  END IF;

  OPEN budorg_cur(x_name);
  LOOP
    FETCH budorg_cur into p_budget_entity_id;
    IF budorg_cur%rowcount =0 THEN
      /* Insert only if new bud org is not migrated already */
    BEGIN
      If lengthb(bud_org_rec.Description) > 207 then
        V_Org_Description  := substrb(bud_org_rec.Description,1,207)||'R12_MIG_'||bud_org_rec.name;

      Else
        V_Org_Description := bud_org_rec.Description||'R12_MIG_'||bud_org_rec.name;
      END IF;
      /************ Insert the corresponding rows in gl_entity_budgets.    */
      p_budget_entity_id := gl_budget_entities_pkg.get_unique_id;

      INSERT INTO GL_ENTITY_BUDGETS
      (budget_entity_id, budget_version_id, frozen_flag,
       created_by, creation_date,
       last_updated_by, last_update_date, last_update_login)
      SELECT p_budget_entity_id, bv.budget_version_id, 'N',
            bud_org_rec.last_updated_by, sysdate,
            bud_org_rec.last_updated_by, sysdate,
            bud_org_rec.last_update_login
      FROM  gl_budgets b, gl_budget_versions bv
      WHERE b.ledger_id = bud_org_rec.Ledger_Id
      AND   bv.budget_name = b.budget_name
      AND   bv.budget_type = b.budget_type;

      /************ Insert Budget Organization */

      INSERT INTO gl_budget_entities(
              budget_entity_id,
              name,
              ledger_id,
              last_update_date,
              last_updated_by,
              budget_password_required_flag,
              status_code,
              creation_date,
              created_by,
              last_update_login,
              encrypted_budget_password,
              description,
              start_date,
              end_date,
              segment1_type,
              segment2_type,
              segment3_type,
              segment4_type,
              segment5_type,
              segment6_type,
              segment7_type,
              segment8_type,
              segment9_type,
              segment10_type,
              segment11_type,
              segment12_type,
              segment13_type,
              segment14_type,
              segment15_type,
              segment16_type,
              segment17_type,
              segment18_type,
              segment19_type,
              segment20_type,
              segment21_type,
              segment22_type,
              segment23_type,
              segment24_type,
              segment25_type,
              segment26_type,
              segment27_type,
              segment28_type,
              segment29_type,
              segment30_type,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              context,
              security_flag)
            VALUES (

              p_budget_entity_id,
              X_Name,
              g_cbc_ledger_id,
              bud_org_rec.Last_Update_Date,
              bud_org_rec.Last_Updated_By,
              bud_org_rec.Budget_Password_Required_Flag,
              bud_org_rec.Status_Code,
              bud_org_rec.Creation_Date,
              bud_org_rec.Created_By,
              bud_org_rec.Last_Update_Login,
              bud_org_rec.Encrypted_Budget_Password,
              V_Org_Description,
              bud_org_rec.Start_Date,
              bud_org_rec.End_Date,
              bud_org_rec.Segment1_Type,
              bud_org_rec.Segment2_Type,
              bud_org_rec.Segment3_Type,
              bud_org_rec.Segment4_Type,
              bud_org_rec.Segment5_Type,
              bud_org_rec.Segment6_Type,
              bud_org_rec.Segment7_Type,
              bud_org_rec.Segment8_Type,
              bud_org_rec.Segment9_Type,
              bud_org_rec.Segment10_Type,
              bud_org_rec.Segment11_Type,
              bud_org_rec.Segment12_Type,
              bud_org_rec.Segment13_Type,
              bud_org_rec.Segment14_Type,
              bud_org_rec.Segment15_Type,
              bud_org_rec.Segment16_Type,
              bud_org_rec.Segment17_Type,
              bud_org_rec.Segment18_Type,
              bud_org_rec.Segment19_Type,
              bud_org_rec.Segment20_Type,
              bud_org_rec.Segment21_Type,
              bud_org_rec.Segment22_Type,
              bud_org_rec.Segment23_Type,
              bud_org_rec.Segment24_Type,
              bud_org_rec.Segment25_Type,
              bud_org_rec.Segment26_Type,
              bud_org_rec.Segment27_Type,
              bud_org_rec.Segment28_Type,
              bud_org_rec.Segment29_Type,
              bud_org_rec.Segment30_Type,
              bud_org_rec.Attribute1,
              bud_org_rec.Attribute2,
              bud_org_rec.Attribute3,
              bud_org_rec.Attribute4,
              bud_org_rec.Attribute5,
              bud_org_rec.Attribute6,
              bud_org_rec.Attribute7,
              bud_org_rec.Attribute8,
              bud_org_rec.Attribute9,
              bud_org_rec.Attribute10,
              bud_org_rec.Context,
              bud_org_rec.Security_Flag);


      /********** Open Ranges cursor to insert ranges */

      FOR Ranges in range_cur
      LOOP

        select chart_of_accounts_id into v_coa_id
        from gl_ledgers where ledger_id = g_cbc_ledger_id;

        select gl_budget_assignment_ranges_s.NEXTVAL into v_new_range_id
        from dual;
        BEGIN
          GL_BUD_ASSIGN_RANGE_PKG.Insert_Row(
                X_Rowid                => v_range_id,
                X_Budget_Entity_Id     => p_budget_entity_id,
                X_Ledger_Id            => g_cbc_ledger_id,
                X_Currency_Code        => RANGES.Currency_Code,
                X_Entry_Code           => RANGES.Entry_Code,
                X_Range_Id             => v_new_range_id,
                X_Status               => 'A', --RANGES.Status,
                X_Last_Update_Date     => RANGES.Last_Update_Date,
                X_Created_By           => RANGES.Created_By,
                X_Creation_Date        => RANGES.Creation_Date,
                X_Last_Updated_By      => RANGES.Last_Updated_By,
                X_Last_Update_Login    => RANGES.Last_Update_Login,
                X_Sequence_Number      => RANGES.Sequence_Number,
                X_Segment1_Low         => RANGES.Segment1_Low,
                X_Segment1_High        => RANGES.Segment1_High,
                X_Segment2_Low         => RANGES.Segment2_Low,
                X_Segment2_High        => RANGES.Segment2_High,
                X_Segment3_Low         => RANGES.Segment3_Low,
                X_Segment3_High        => RANGES.Segment3_High,
                X_Segment4_Low         => RANGES.Segment4_Low,
                X_Segment4_High        => RANGES.Segment4_High,
                X_Segment5_Low         => RANGES.Segment5_Low,
                X_Segment5_High        => RANGES.Segment5_High,
                X_Segment6_Low         => RANGES.Segment6_Low,
                X_Segment6_High        => RANGES.Segment6_High,
                X_Segment7_Low         => RANGES.Segment7_Low,
                X_Segment7_High        => RANGES.Segment7_High,
                X_Segment8_Low         => RANGES.Segment8_Low,
                X_Segment8_High        => RANGES.Segment8_High,
                X_Segment9_Low         => RANGES.Segment9_Low,
                X_Segment9_High        => RANGES.Segment9_High,
                X_Segment10_Low        => RANGES.Segment10_Low,
                X_Segment10_High       => RANGES.Segment10_High,
                X_Segment11_Low        => RANGES.Segment11_Low,
                X_Segment11_High       => RANGES.Segment11_High,
                X_Segment12_Low        => RANGES.Segment12_Low,
                X_Segment12_High       => RANGES.Segment12_High,
                X_Segment13_Low        => RANGES.Segment13_Low,
                X_Segment13_High       => RANGES.Segment13_High,
                X_Segment14_Low        => RANGES.Segment14_Low,
                X_Segment14_High       => RANGES.Segment14_High,
                X_Segment15_Low        => RANGES.Segment15_Low,
                X_Segment15_High       => RANGES.Segment15_High,
                X_Segment16_Low        => RANGES.Segment16_Low,
                X_Segment16_High       => RANGES.Segment16_High,
                X_Segment17_Low        => RANGES.Segment17_Low,
                X_Segment17_High       => RANGES.Segment17_High,
                X_Segment18_Low        => RANGES.Segment18_Low,
                X_Segment18_High       => RANGES.Segment18_High,
                X_Segment19_Low        => RANGES.Segment19_Low,
                X_Segment19_High       => RANGES.Segment19_High,
                X_Segment20_Low        => RANGES.Segment20_Low,
                X_Segment20_High       => RANGES.Segment20_High,
                X_Segment21_Low        => RANGES.Segment21_Low,
                X_Segment21_High       => RANGES.Segment21_High,
                X_Segment22_Low        => RANGES.Segment22_Low,
                X_Segment22_High       => RANGES.Segment22_High,
                X_Segment23_Low        => RANGES.Segment23_Low,
                X_Segment23_High       => RANGES.Segment23_High,
                X_Segment24_Low        => RANGES.Segment24_Low,
                X_Segment24_High       => RANGES.Segment24_High,
                X_Segment25_Low        => RANGES.Segment25_Low,
                X_Segment25_High       => RANGES.Segment25_High,
                X_Segment26_Low        => RANGES.Segment26_Low,
                X_Segment26_High       => RANGES.Segment26_High,
                X_Segment27_Low        => RANGES.Segment27_Low,
                X_Segment27_High       => RANGES.Segment27_High,
                X_Segment28_Low        => RANGES.Segment28_Low,
                X_Segment28_High       => RANGES.Segment28_High,
                X_Segment29_Low        => RANGES.Segment29_Low,
                X_Segment29_High       => RANGES.Segment29_High,
                X_Segment30_Low        => RANGES.Segment30_Low,
                X_Segment30_High       => RANGES.Segment30_High,
                X_Context              => RANGES.Context,
                X_Attribute1           => RANGES.Attribute1,
                X_Attribute2           => RANGES.Attribute2,
                X_Attribute3           => RANGES.Attribute3,
                X_Attribute4           => RANGES.Attribute4,
                X_Attribute5           => RANGES.Attribute5,
                X_Attribute6           => RANGES.Attribute6,
                X_Attribute7           => RANGES.Attribute7,
                X_Attribute8           => RANGES.Attribute8,
                X_Attribute9           => RANGES.Attribute9,
                X_Attribute10          => RANGES.Attribute10,
                X_Attribute11          => RANGES.Attribute11,
                X_Attribute12          => RANGES.Attribute12,
                X_Attribute13          => RANGES.Attribute13,
                X_Attribute14          => RANGES.Attribute14,
                X_Attribute15          => RANGES.Attribute15,
                X_Chart_Of_Accounts_Id => v_coa_id);

                  /********** Insert in to GL_BUDORG_BC_OPTIONS */
            FOR budctrl_rec in BC_CUR(RANGES.range_id)
            LOOP

              BEGIN
                SELECT CBC_OVERRIDE into v_cbc_override
                FROM IGC_CBC_BA_RANGES
                WHERE CBC_RANGE_ID= RANGES.range_id
                AND SET_OF_BOOKS_ID = g_sob_id
                AND BUDGET_ENTITY_ID = v_budget_entity_id;
              EXCEPTIOn
                when No_data_found then
                  v_cbc_override  := budctrl_rec.Funds_Check_Level_Code;
              END;

              GL_BUDORG_BC_OPTIONS_PKG.Insert_Row(
              X_Rowid                => v_range_id,
              X_Range_Id             => v_new_range_id,
              X_Last_Update_Date     => budctrl_rec.Last_Update_Date,
              X_Created_By           => budctrl_rec.Created_By,
              X_Creation_Date        => budctrl_rec.Creation_Date,
              X_Funds_Check_Level_Code=> v_cbc_override ,
              X_Last_Updated_By      => budctrl_rec.Last_Updated_By,
              X_Last_Update_Login    => budctrl_rec.Last_Update_Login,
              X_Amount_Type          => budctrl_rec.Amount_Type,
              X_Boundary_Code        => budctrl_rec.Boundary_Code,
              X_Funding_Budget_Version_Id=> p_budget_version_id);
            END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP; --Ranges cursor

    END ; /* End of rowcount =0 */
    add_bud_entity_map(bud_org_rec.name,X_name);
    END IF;
    EXIT WHEN budorg_cur%NOTFOUND;
  END LOOP; --BUDORG_CUR
  CLOSE budorg_cur;
EXCEPTION
  WHEN OTHERS THEN
    IF budorg_cur%ISOPEN THEN
      CLOSE budorg_cur;
    END IF;
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'while migrating budget org info' || SQLERRM);
  END IF;
  /*Added by mbremkum*/
  APP_EXCEPTION.Raise_Exception;
End GL_Budget_Org;


PROCEDURE submit_open_year(P_sec_ledger_id IN Number,
          Bud_Version_Id IN NUMBER,
          p_latest_open_year IN gl_budgets_v.latest_opened_year%type,
          p_fiscal_year     IN NUMBER)
IS
  req_id number;
  v_access_set_id number;
  User_Exception Exception;
  l_request_status NUMBER;
BEGIN
    v_access_set_id := fnd_profile.value('GL_ACCESS_SET_ID');
    If nvl(p_latest_open_year,0) < p_fiscal_year then
        req_id
              := fnd_request.submit_request(
                  'SQLGL',
                  'GLBOYR',
                  '',
                  '',
                  FALSE,
                  v_access_set_id,
                  to_char(p_sec_ledger_id),
                  to_char(Bud_Version_Id),
                  chr(0),
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '');
                commit;
      -- Verify that the concurrent request was launched
      -- successfully.
      IF (req_id = 0) THEN
        --fnd_message.retrieve;
       -- fnd_message.error;
        Raise User_Exception;
      ELSE
        COMMIT;
        l_request_status := check_request(req_id);
      END IF;
  END IF;
EXCEPTION
  When  User_exception then
  Raise_application_error(20010,'Open Budget Year concurrent request is failed');
END submit_open_year;


PROCEDURE submit_assign_ranges(P_sec_ledger_id IN Number,
p_bud_entity_id IN Number)
IS
v_req_id number;
User_Exception Exception;
l_request_status NUMBER;
BEGIN
IF p_bud_entity_id IS NULL THEN
  return;
END IF;
v_req_id
         := fnd_request.submit_request(
        'SQLGL',
              'GLBAAR',
              '',
              '',
              FALSE,
              to_char(P_sec_ledger_id),
              to_char(p_bud_entity_id),
        chr(0),
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '');
          commit;
      -- Verify that the concurrent request was launched
      -- successfully.
      IF (v_req_id = 0) THEN
        --fnd_message.retrieve;
        --fnd_message.error;
        Raise User_Exception;
      ELSE
        COMMIT;
        l_request_status := check_request(v_req_id);
      END IF;
EXCEPTION
  When  User_exception then
  Raise_application_error(20020,'Assign Budget Account Ranges concurrent request has failed');
END submit_assign_ranges;


/* Procedure to migrate summary templates data for all templates in a primary ledger */

PROCEDURE migrate_sum_templates IS

  /* Cursor to get all template ids, for which setup is done in CBC */
  Cursor template_cur is
  select template_id, CBC_OVERRIDE
  from IGC_CBC_SUMMARY_TEMPLATES
  where  set_of_books_id = g_sob_id
  and nvl(MIG_RESULT_CODE,'F') <> 'T';

  gl_temp_rec  GL_SUMMARY_TEMPLATES%rowtype;

/* cursor to get all budget records for which budgetroy control is set up for each template */
  Cursor bcoptions_cur(c_template_id IN NUMBER)  is
  Select *  from GL_SUMMARY_BC_OPTIONS
  where   template_id = c_template_id;

  v_template_id number;
  v_chart_of_accounts_id  gl_ledgers.chart_of_accounts_id%type;
  user_exception Exception;
  v_old_budget_name gl_budgets_v.budget_name%type;
  v_new_bud_ver_id gl_budgets_v.budget_version_id%type;
  req_id number;
  v_row_id varchar2(50) := NULL;
  l_full_path VARCHAR2(255);
  l_request_status NUMBER;
BEGIN
  l_full_path := g_path || 'migrate_sum_templates';

  select chart_of_accounts_id into v_chart_of_accounts_id from gl_ledgers where ledger_id = g_cbc_ledger_id;

/* Inserting template information in  GL_SUMMARY_TEMPLATES for which setup is made in CBC */

  For i in template_cur
  loop
    v_template_id := GL_SUMMARY_TEMPLATES_PKG.get_unique_id;
    select * into gl_temp_rec from GL_SUMMARY_TEMPLATES where template_id = i.template_id;
    INSERT INTO GL_SUMMARY_TEMPLATES(
        template_id,
        ledger_id,
        status,
        last_update_date,
        last_updated_by,
        template_name,
        concatenated_description,
        account_category_code,
        max_code_combination_id,
        start_actuals_period_name,
        created_by,
        creation_date,
        last_update_login,
        segment1_type,
        segment2_type,
        segment3_type,
        segment4_type,
        segment5_type,
        segment6_type,
        segment7_type,
        segment8_type,
        segment9_type,
        segment10_type,
        segment11_type,
        segment12_type,
        segment13_type,
        segment14_type,
        segment15_type,
        segment16_type,
        segment17_type,
        segment18_type,
        segment19_type,
        segment20_type,
        segment21_type,
        segment22_type,
        segment23_type,
        segment24_type,
        segment25_type,
        segment26_type,
        segment27_type,
        segment28_type,
        segment29_type,
        segment30_type,
        description,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        context)
    VALUES (
        V_Template_Id,
        g_cbc_Ledger_id,
        'A',
        gl_temp_rec.Last_Update_Date,
        gl_temp_rec.Last_Updated_By,
        gl_temp_rec.Template_Name,
        gl_temp_rec.Concatenated_Description,
        gl_temp_rec.Account_Category_Code,
        gl_temp_rec.MAX_Code_Combination_Id,
        gl_temp_rec.Start_Actuals_Period_Name,
        gl_temp_rec.Created_By,
        gl_temp_rec.Creation_Date,
        gl_temp_rec.Last_Update_Login,
        gl_temp_rec.Segment1_Type,
        gl_temp_rec.Segment2_Type,
        gl_temp_rec.Segment3_Type,
        gl_temp_rec.Segment4_Type,
        gl_temp_rec.Segment5_Type,
        gl_temp_rec.Segment6_Type,
        gl_temp_rec.Segment7_Type,
        gl_temp_rec.Segment8_Type,
        gl_temp_rec.Segment9_Type,
        gl_temp_rec.Segment10_Type,
        gl_temp_rec.Segment11_Type,
        gl_temp_rec.Segment12_Type,
        gl_temp_rec.Segment13_Type,
        gl_temp_rec.Segment14_Type,
        gl_temp_rec.Segment15_Type,
        gl_temp_rec.Segment16_Type,
        gl_temp_rec.Segment17_Type,
        gl_temp_rec.Segment18_Type,
        gl_temp_rec.Segment19_Type,
        gl_temp_rec.Segment20_Type,
        gl_temp_rec.Segment21_Type,
        gl_temp_rec.Segment22_Type,
        gl_temp_rec.Segment23_Type,
        gl_temp_rec.Segment24_Type,
        gl_temp_rec.Segment25_Type,
        gl_temp_rec.Segment26_Type,
        gl_temp_rec.Segment27_Type,
        gl_temp_rec.Segment28_Type,
        gl_temp_rec.Segment29_Type,
        gl_temp_rec.Segment30_Type,
        gl_temp_rec.Description,
        gl_temp_rec.Attribute1,
        gl_temp_rec.Attribute2,
        gl_temp_rec.Attribute3,
        gl_temp_rec.Attribute4,
        gl_temp_rec.Attribute5,
        gl_temp_rec.Attribute6,
        gl_temp_rec.Attribute7,
        gl_temp_rec.Attribute8,
        gl_temp_rec.Context);

/* Inserting budgetary control options into  GL_SUMMARY_BC_OPTIONS */
      FOR BUDCTRL_OPTIONS IN bcoptions_cur(i.template_id)
      LOOP

      select  budget_name into v_old_budget_name
      from gl_budgets_v where budget_version_id = BUDCTRL_OPTIONS.funding_budget_version_id;

      select budget_version_id into v_new_bud_ver_id
       from gl_budgets_v where  description like '%R12_MIG_'||v_old_budget_name;

       GL_SUMMARY_BC_OPTIONS_PKG.Insert_Row(
                X_Rowid                                 => v_row_id,
                X_Funds_Check_Level_Code                => i.CBC_OVERRIDE  ,
                X_Dr_Cr_Code                            => BUDCTRL_OPTIONS.dr_cr_code,
                X_Amount_Type                           => BUDCTRL_OPTIONS.amount_type,
                X_Boundary_Code                         => BUDCTRL_OPTIONS.boundary_code,
                X_Template_Id                           => v_template_id ,
                X_Last_Update_Date                      => BUDCTRL_OPTIONS.last_update_date,
                X_Last_Updated_By                       => BUDCTRL_OPTIONS.last_updated_by,
                X_Created_By                            => BUDCTRL_OPTIONS.created_by,
                X_Creation_Date                         => BUDCTRL_OPTIONS.creation_date,
                X_Last_Update_Login                     => BUDCTRL_OPTIONS.last_update_login,
                X_Funding_Budget_Version_Id             => v_new_bud_ver_id
                 );
      END LOOP; --For all records of GL_SUMMARY_BC_OPTIONS for each template.

    update igc_cbc_summary_templates set MIG_RESULT_CODE = 'T',
    MIG_REQUEST_ID = fnd_global.conc_request_id
    WHERE template_id = i.template_id;

/* Submitting "Add/Delete Summary Accounts" concurrent program */

    BEGIN
    req_id := fnd_request.submit_request(
                 'SQLGL',
                 'GLSTPM',
                  '',
                  '',
                  FALSE,
                  'A',
                  to_char(V_Template_Id),
                  to_char(g_cbc_ledger_id),
            to_char(v_chart_of_accounts_id),
            chr(0),
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '');

          -- Verify that the concurrent request was launched
          -- successfully.
          IF (req_id = 0) THEN
            --fnd_message.retrieve;
            --fnd_message.error;
            Raise user_exception;
          ELSE
            COMMIT;
            l_request_status := check_request(req_id);
          END IF;
    EXCEPTION WHEN user_exception THEN
      Raise_application_error(20030,'Add/Delete Summary Accounts concurrent request has failed');
    END;

  END LOOP; --FOr all template_id's in IGC_CBC_TEMPLATES table.
EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, SQLERRM);
  END IF;
   /*Added by mbremkum*/
   APP_EXCEPTION.Raise_Exception;
END migrate_sum_templates;


  PROCEDURE migrate_cbc_bud_jounals(p_fiscal_year IN NUMBER)
  IS
    l_user_id NUMBER := FND_GLOBAL.user_id;

    l_gl_data_access_set fnd_profile_option_values.profile_option_value%type;

    l_request_id_current NUMBER := fnd_global.conc_request_id;
    l_request_id_bud NUMBER;
    l_request_id_comp NUMBER;

    bln_request_status BOOLEAN;

    l_req_comp_phase VARCHAR2(50);
    l_req_comp_status VARCHAR2(50);
    l_req_comp_dev_phase VARCHAR2(50);
    l_req_comp_dev_status VARCHAR2(50);
    l_req_comp_mesg VARCHAR2(2000);

    bln_req_comp BOOLEAN := TRUE;

    l_full_path VARCHAR2(255);
    bln_missing_bud BOOLEAN := false;

    CURSOR c_cbc_source is
    SELECT  Distinct
            je_source
    FROM    IGC_CBC_JE_LINES cbl
    WHERE   set_of_books_id = g_sob_id
    AND     cbl.period_year = p_fiscal_year
    AND     mig_request_id is null
    AND     actual_flag = 'B'
    AND     detail_summary_code = 'D';

    Type t_tbl_cbc_source IS TABLE OF c_cbc_source%ROWTYPE INDEX BY BINARY_INTEGER;

    l_tbl_cbc_source t_tbl_cbc_source;

    l_request_status NUMBER;

    CURSOR c_bud_journals IS
    SELECT
      'NEW' status
      ,g_cbc_ledger_id ledger_id
      ,igc.je_source user_je_source_name
      ,igc.je_category user_je_category_name
      ,igc.effective_date accounting_date
      ,igc.currency_code currency_code
      ,sysdate date_created
      ,l_user_id created_by
      ,'B' actual_flag
      ,igc.budget_version_id old_budget_version_id
      ,BV.BUDGET_VERSION_ID new_budget_version_id
      ,decode(igc.entered_dr,0,null,entered_dr) entered_dr
      ,decode(igc.entered_cr,0,null,entered_cr) entered_cr
      ,igc.period_name period_name
      ,igc.code_combination_id code_combination_id
      ,'MIG-'||cbc_je_batch_id reference1
      ,'R11i MIGRATION - '||cbc_je_batch_id||' - '||cbc_je_line_num reference5
      ,'R11i MIGRATION - '||cbc_je_batch_id||' - '||cbc_je_line_num reference6
      ,igc.cbc_je_batch_id reference21
      ,igc.cbc_je_line_num reference22
    FROM igc_cbc_je_lines igc,
       gl_budget_assignments asg,
         GL_BUDORG_BC_OPTIONS boc,
         GL_BUDGET_VERSIONS BV ,
         gl_budgets bud,
         gl_period_statuses per_f,
         gl_period_statuses per_s
    WHERE  asg.range_id =  boc.range_id
    AND    BV.BUDGET_VERSION_ID = BOC.FUNDING_BUDGET_VERSION_ID
    AND    bud.budget_name = BV.budget_name
    AND    asg.code_combination_id = igc.code_combination_id
    AND    per_s.ledger_id = bud.ledger_id
    AND    per_f.ledger_id = bud.ledger_id
    AND    per_s.application_id = 101
    AND    per_f.application_id = 101
    AND    per_s.period_name = bud.first_valid_period_name
    AND    per_f.period_name = bud.last_valid_period_name
    AND    igc.effective_date between per_s.start_date and per_f.end_date
    AND    bud.ledger_id = g_cbc_ledger_id
    AND    igc.set_of_books_id = g_sob_id
    AND   igc.period_year = p_fiscal_year
    AND   igc.mig_result_code IS NULL
    AND   igc.actual_flag = 'B'
    AND   igc.detail_summary_code = 'D'
    AND   igc.mig_request_id is NULL
    AND   igc.budget_version_id IS NOT NULL;

    Type t_tbl_bud_journals IS TABLE OF c_bud_journals%ROWTYPE INDEX BY BINARY_INTEGER;

    l_tbl_bud_journals t_tbl_bud_journals;
    l_error VARCHAR2(2000);
    l_dummy VARCHAR2(1);

  BEGIN

    l_full_path := g_path || 'migrate_cbc_bud_jounals';

    l_gl_data_access_set := fnd_profile.value('GL_ACCESS_SET_ID');

    -- First Check all budget version exists in Secondary ledger

    BEGIN
      SELECT '1'
      INTO l_dummy
      FROM DUAL
      WHERE EXISTS
        (SELECT 1
         FROM  igc_cbc_je_lines igc
         where budget_version_id is NOT null
         AND   igc.actual_flag = 'B'
         AND   igc.DETAIL_SUMMARY_CODE = 'D'
         AND   igc.period_year = p_fiscal_year
         AND   set_of_books_id = g_sob_id
         AND   NOT EXISTS
         ( SELECT 1
          FROM  gl_budget_assignments asg,
                GL_BUDORG_BC_OPTIONS boc,
                GL_BUDGET_VERSIONS BV ,
                gl_budgets bud,
                gl_period_statuses per_f,
                gl_period_statuses per_s
          WHERE  asg.range_id =  boc.range_id
          AND    BV.BUDGET_VERSION_ID = BOC.FUNDING_BUDGET_VERSION_ID
          AND    bud.budget_name = BV.budget_name
          AND    asg.code_combination_id = igc.code_combination_id
          AND    per_s.ledger_id = bud.ledger_id
          AND    per_f.ledger_id = bud.ledger_id
          AND    per_s.application_id = 101
          AND    per_f.application_id = 101
          AND    per_s.period_name = bud.first_valid_period_name
          AND    per_f.period_name = bud.last_valid_period_name
          AND    igc.effective_date between per_s.start_date and per_f.end_date
          AND    bud.ledger_id = g_cbc_ledger_id
          )
         );
        IF l_dummy = '1' THEN
          FND_MESSAGE.set_name('IGC','IGC_CBC_BUD_DATA_MISS');
          FND_MESSAGE.SET_TOKEN('PROGRAM_NAME',g_conc_pr_user);
          l_error := FND_MESSAGE.get;
          add_error (l_error);
          return;
        END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Checked budget versions exists in CBC ledger');
    END IF;

    OPEN c_bud_journals;
    LOOP
      FETCH c_bud_journals BULK COLLECT INTO l_tbl_bud_journals;
      EXIT WHEN c_bud_journals%NOTFOUND;
    END LOOP;

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Number of budgets to migrate '||l_tbl_bud_journals.count);
    END IF;

    FOR i_ind in 1..l_tbl_bud_journals.COUNT
    LOOP
      INSERT INTO GL_INTERFACE
        (
         status
        ,ledger_id
        ,user_je_source_name
        ,user_je_category_name
        ,accounting_date
        ,currency_code
        ,date_created
        ,created_by
        ,actual_flag
        ,budget_version_id
        ,entered_dr
        ,entered_cr
        ,period_name
        ,code_combination_id
        ,reference1
        ,reference5
        ,reference6
        ,reference21
        ,reference22
        )
        VALUES
        (
         l_tbl_bud_journals(i_ind).status
        ,l_tbl_bud_journals(i_ind).ledger_id
        ,l_tbl_bud_journals(i_ind).user_je_source_name
        ,l_tbl_bud_journals(i_ind).user_je_category_name
        ,l_tbl_bud_journals(i_ind).accounting_date
        ,l_tbl_bud_journals(i_ind).currency_code
        ,l_tbl_bud_journals(i_ind).date_created
        ,l_tbl_bud_journals(i_ind).created_by
        ,l_tbl_bud_journals(i_ind).actual_flag
        ,l_tbl_bud_journals(i_ind).new_budget_version_id
        ,l_tbl_bud_journals(i_ind).entered_dr
        ,l_tbl_bud_journals(i_ind).entered_cr
        ,l_tbl_bud_journals(i_ind).period_name
        ,l_tbl_bud_journals(i_ind).code_combination_id
        ,l_tbl_bud_journals(i_ind).reference1
        ,l_tbl_bud_journals(i_ind).reference5
        ,l_tbl_bud_journals(i_ind).reference6
        ,l_tbl_bud_journals(i_ind).reference21
        ,l_tbl_bud_journals(i_ind).reference22
        );
    END LOOP;

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Inserted records into GL_INTERFACE table');
    END IF;

    /* Get all journal source */
    OPEN c_cbc_source;
    LOOP
      FETCH c_cbc_source BULK COLLECT INTO l_tbl_cbc_source;
      EXIT WHEN c_cbc_source%NOTFOUND;
    END LOOP;
    CLOSE c_cbc_source;

    COMMIT;

    FOR j in 1..l_tbl_cbc_source.COUNT
    LOOP
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Submitting Import Journal request for '||l_tbl_cbc_source(j).je_source);
      END IF;
      l_request_id_bud := fnd_request.submit_request
                          (application => 'SQLGL',
                          program => 'GLLEZLSRS',
                          description => NULL,
                          start_time => NULL,
                          sub_request => FALSE,
                          argument1 => l_gl_data_access_set,
                          argument2 => l_tbl_cbc_source(j).je_source,
                          argument3 => g_cbc_ledger_id,
                          argument4 => NULL,
                          argument5 => 'N',
                          argument6 => 'N',
                          argument7 => 'N',
                          argument8 => '',argument9 => '',argument10 => '',
                          argument11 => '',argument12 => '',argument13 => '',argument14 => '',argument15 => '',
                          argument16 => '',argument17 => '',argument18 => '',argument19 => '',argument20 => '',
                          argument21 => '',argument22 => '',argument23 => '',argument24 => '',argument25 => '',
                          argument26 => '',argument27 => '',argument28 => '',argument29 => '',argument30 => '',
                          argument31 => '',argument32 => '',argument33 => '',argument34 => '',argument35 => '',
                          argument36 => '',argument37 => '',argument38 => '',argument39 => '',argument40 => '',
                          argument41 => '',argument42 => '',argument43 => '',argument44 => '',argument45 => '',
                          argument46 => '',argument47 => '',argument48 => '',argument49 => '',argument50 => '',
                          argument51 => '',argument52 => '',argument53 => '',argument54 => '',argument55 => '',
                          argument56 => '',argument57 => '',argument58 => '',argument59 => '',argument60 => '',
                          argument61 => '',argument62 => '',argument63 => '',argument64 => '',argument65 => '',
                          argument66 => '',argument67 => '',argument68 => '',argument69 => '',argument70 => '',
                          argument71 => '',argument72 => '',argument73 => '',argument74 => '',argument75 => '',
                          argument76 => '',argument77 => '',argument78 => '',argument79 => '',argument80 => '',
                          argument81 => '',argument82 => '',argument83 => '',argument84 => '',argument85 => '',
                          argument86 => '',argument87 => '',argument88 => '',argument89 => '',argument90 => '',
                          argument91 => '',argument92 => '',argument93 => '',argument94 => '',argument95 => '',
                          argument96 => '',argument97 => '',argument98 => '',argument99 => '',argument100 => ''
                          );
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Submitted Import Journal request for '||l_tbl_cbc_source(j).je_source||' request Id '||l_request_id_bud);
      END IF;

      IF l_request_id_bud <= 0 THEN
        bln_req_comp := FALSE;
      ELSE
        COMMIT;
        l_request_status := check_request(l_request_id_bud);
        IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg(l_full_path, 'Updating igc_cbc_je_lines.. start');
        END IF;
        UPDATE igc_cbc_je_lines cbc
        SET   mig_result_code = 'P00'
              ,mig_request_id = l_request_id_current
        WHERE set_of_books_id = g_sob_id
        AND   period_year = p_fiscal_year
        AND   mig_result_code IS NULL
        AND   actual_flag = 'B'
        AND   detail_summary_code = 'D'
        AND   mig_request_id is NULL
        AND   budget_version_id IS NOT NULL
        AND   je_source = l_tbl_cbc_source(j).je_source
        AND   EXISTS
              (SELECT 1
                FROM  gl_je_lines l, gl_je_headers h, gl_je_batches b
                WHERE h.je_batch_id = b.je_batch_id
                AND   h.je_header_id = l.je_header_id
                AND   h.je_source = l_tbl_cbc_source(j).je_source
                AND   h.ledger_id = g_cbc_ledger_id
                AND   l.reference_1 = to_char(cbc.cbc_je_batch_id)
                AND   l.reference_2 = to_char(cbc.cbc_je_line_num)
              );

        IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg(l_full_path, 'Updating igc_cbc_je_lines.. complete');
        END IF;

        COMMIT;
      END IF;
    END LOOP;

  END migrate_cbc_bud_jounals;


  FUNCTION get_cbc_budget_name(p_pri_budget_name IN VARCHAR2) RETURN VARCHAR2 IS
    l_cbc_budget_name GL_BUDGETS.BUDGET_NAME%TYPE;
  BEGIN
    SELECT budget_name
    INTO   l_cbc_budget_name
    FROM   gl_budgets
    WHERE  description like '%R12_MIG_'||p_pri_budget_name;
    RETURN l_cbc_budget_name;
  END;

/* End of changes for Budgets Migration */

PROCEDURE add_error (
   p_error_mesg IN VARCHAR2
)IS
l_tbl_count NUMBER;
BEGIN
  l_tbl_count := g_tbl_basic_errors.count;
  g_tbl_basic_errors(l_tbl_count+1).error_mesg := p_error_mesg;
END add_error;

PROCEDURE add_warning (
   p_error_mesg IN VARCHAR2
)IS
l_tbl_count NUMBER;
BEGIN
  l_tbl_count := g_tbl_warnings.count;
  g_tbl_warnings(l_tbl_count+1).error_mesg := p_error_mesg;
END add_warning;

PROCEDURE set_final_out (
   p_final_out IN VARCHAR2
)IS
BEGIN
  IF g_final_out = 'ERROR' THEN
    return;
  END IF;
  IF p_final_out = 'ERROR' THEN
    g_final_out := p_final_out;
  ELSIF g_final_out = 'SUCCESS' THEN
    g_final_out := p_final_out;
  END IF;
END set_final_out;

PROCEDURE add_bud_map (
   p_old_budget_name GL_BUDGETS.BUDGET_NAME%Type,
   p_new_budget_name GL_BUDGETS.BUDGET_NAME%Type
) IS
l_tbl_count NUMBER;
BEGIN
  l_tbl_count := g_tbl_bud_map.count;
  g_tbl_bud_map(l_tbl_count+1).old_budget_name := p_old_budget_name;
  g_tbl_bud_map(l_tbl_count+1).new_budget_name := p_new_budget_name;
END add_bud_map;


PROCEDURE add_bud_entity_map (
   p_old_bud_entity gl_budget_entities.NAME%Type,
   p_new_bud_entity gl_budget_entities.NAME%Type
) IS
l_tbl_count NUMBER;
BEGIN
  l_tbl_count := g_tbl_bud_entity_map.count;
  g_tbl_bud_entity_map(l_tbl_count+1).old_bud_entity := p_old_bud_entity;
  g_tbl_bud_entity_map(l_tbl_count+1).new_bud_entity := p_new_bud_entity;
END add_bud_entity_map;

PROCEDURE validate_basic(p_org_id IN Number,
  p_fin_year    IN NUMBER,
  p_balance_type IN VARCHAR2,
  x_return_code                   OUT NOCOPY  NUMBER,
  x_msg_buf                       OUT NOCOPY  VARCHAR2
) IS
l_error VARCHAR2(2000);
l_option_name VARCHAR2(80);
l_dummy VARCHAR2(1);
l_gl_data_access_set fnd_profile_option_values.profile_option_value%type;
BEGIN

  IF NOT igi_gen.is_req_installed('CBC') THEN

    SELECT meaning
    INTO l_option_name
    FROM igi_lookups
    WHERE lookup_code = 'CBC'
    AND lookup_type = 'GCC_DESCRIPTION';

    FND_MESSAGE.SET_NAME('IGI', 'IGI_GEN_PROD_NOT_INSTALLED');
    FND_MESSAGE.SET_TOKEN('OPTION_NAME', l_option_name);
    l_error := fnd_message.get;
    add_error (l_error);
    x_msg_buf := l_error;
    x_return_code := 2;
    return;
  END IF;

  IGC_LEDGER_UTILS.get_cbc_ledger(p_primary_ledger_id => g_sob_id,  p_cbc_ledger_id => g_cbc_ledger_id, p_cbc_ledger_Name => g_cbc_ledger_name);
/*
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'Secondary Ledger Name: ' || g_cbc_ledger_name);
  END IF;
*/
  IF (g_cbc_ledger_id <= 0) THEN
    FND_MESSAGE.set_name('IGC','IGC_NO_CBC_LEDGER');
    FND_MESSAGE.SET_TOKEN('LEDGER_NAME',g_sob_name);
    x_return_code := 2;
    l_error := FND_MESSAGE.get;
    add_error (l_error);
    x_msg_buf := l_error ;
    return;
  END IF;
  Declare
    l_tot_count NUMBER := 0;
    l_open_count NUMBER := 0;
  BEGIN
    SELECT sum(decode(closing_status,'O',1,0)),sum(1)
    INTO  l_open_count,l_tot_count
    FROM  gl_period_statuses
    WHERE application_id = 101
    AND period_year = p_fin_year
    AND ledger_id = g_cbc_ledger_id
    AND adjustment_period_flag = 'N';
    IF nvl(l_tot_count,0) = 0 OR (l_open_count <> l_tot_count) THEN
      FND_MESSAGE.set_name('IGC','IGC_CBC_MIG_CLOSE_PERIOD');
      FND_MESSAGE.SET_TOKEN('YEAR',p_fin_year);
      FND_MESSAGE.SET_TOKEN('LEDGER_NAME',g_cbc_ledger_name);
      l_error := FND_MESSAGE.get;
      add_error (l_error);
      x_msg_buf := l_error ;
      x_return_code := 2;
    return;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  l_gl_data_access_set := fnd_profile.value('GL_ACCESS_SET_ID');

  BEGIN
    SELECT distinct '1'
    INTO   l_dummy
    FROM gl_access_set_ledgers acc, gl_ledgers lgr
    WHERE acc.access_set_id = l_gl_data_access_set
    AND lgr.ledger_id = acc.ledger_id
    AND lgr.object_type_code = 'L'
    AND acc.access_privilege_code in ('B','F')
    AND lgr.ledger_id = g_cbc_ledger_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('IGC','IGC_CBC_LEDG_ACCESS');
      FND_MESSAGE.SET_TOKEN('LEDGER_NAME',g_cbc_ledger_name);
      l_error := FND_MESSAGE.get;
      add_error (l_error);
      x_msg_buf := l_error ;
      x_return_code := 2;
  END;

  -- Check If budget data is migrated
  IF p_balance_type = 'E' THEN
    BEGIN
      SELECT '1'
      INTO l_dummy
      FROM DUAL
      WHERE EXISTS
        (SELECT 1
         FROM  igc_cbc_je_lines igc
         where budget_version_id is NOT null
         AND   igc.actual_flag = 'E'
         AND   igc.DETAIL_SUMMARY_CODE = 'D'
         AND   igc.period_year = p_fin_year
         AND   set_of_books_id = g_sob_id
         AND   mig_request_id IS NULL
         AND   NOT EXISTS
         ( SELECT 1
          FROM  gl_budget_assignments asg,
                GL_BUDORG_BC_OPTIONS boc,
                GL_BUDGET_VERSIONS BV ,
                gl_budgets bud,
                gl_period_statuses per_f,
                gl_period_statuses per_s
          WHERE  asg.range_id =  boc.range_id
          AND    BV.BUDGET_VERSION_ID = BOC.FUNDING_BUDGET_VERSION_ID
          AND    bud.budget_name = BV.budget_name
          AND    asg.code_combination_id = igc.code_combination_id
          AND    per_s.ledger_id = bud.ledger_id
          AND    per_f.ledger_id = bud.ledger_id
          AND    per_s.application_id = 101
          AND    per_f.application_id = 101
          AND    per_s.period_name = bud.first_valid_period_name
          AND    per_f.period_name = bud.last_valid_period_name
          AND    igc.effective_date between per_s.start_date and per_f.end_date
          AND    bud.ledger_id = g_cbc_ledger_id
          )
         );
        IF l_dummy = '1' THEN
          FND_MESSAGE.set_name('IGC','IGC_CBC_BUD_DATA_MISS');
          FND_MESSAGE.SET_TOKEN('PROGRAM_NAME',g_conc_pr_user);
          l_error := FND_MESSAGE.get;
          add_error (l_error);
        END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  END IF;



END validate_basic;

FUNCTION check_request(p_request_id IN NUMBER) RETURN NUMBER IS
  CURSOR c_req(c_request_id IN NUMBER) IS
  SELECT parent_request_id,
         request_id,level
  FROM   fnd_concurrent_requests
  CONNECT BY PRIOR request_id = parent_request_id
  START with request_id = c_request_id
  order by request_id;
  l_other_request NUMBER;
  bln_request_status BOOLEAN;

  l_req_comp_phase VARCHAR2(50);
  l_req_comp_status VARCHAR2(50);
  l_req_comp_dev_phase VARCHAR2(50);
  l_req_comp_dev_status VARCHAR2(50);
  l_req_comp_mesg VARCHAR2(2000);
  l_error VARCHAR2(2000);
  l_return NUMBER := 0;
BEGIN
    FOR l_req in c_req(p_request_id)
    LOOP
      l_other_request := l_req.request_id;
      bln_request_status := FND_CONCURRENT.WAIT_FOR_REQUEST
                        ( request_id =>l_other_request,
                        phase =>l_req_comp_phase,status => l_req_comp_status,
                        dev_phase =>l_req_comp_dev_phase,dev_status => l_req_comp_dev_status,
                        message=>l_req_comp_mesg);
      IF trim(l_req_comp_dev_phase) = 'COMPLETE' AND
         trim(l_req_comp_dev_status) = 'NORMAL' THEN
        IF l_return >= 0 THEN
          l_return := 1;
        END IF;
      ELSE
        FND_MESSAGE.set_name('IGC','IGC_CBC_CONC_FAIL');
        FND_MESSAGE.SET_TOKEN('REQUEST_ID',l_other_request);
        l_error := FND_MESSAGE.get;
        add_error (l_error);
        l_return := -1;
      END IF;
    END LOOP;
    return l_return;
END;

PROCEDURE print_header(p_balance_type    IN VARCHAR2,
          p_mode    IN VARCHAR2,
          p_fiscal_year IN NUMBER) IS
  l_conc_id NUMBER := fnd_global.CONC_PROGRAM_ID;
  l_conc_pr_name FND_CONCURRENT_PROGRAMS_VL.concurrent_program_name%TYPE;
  l_param_out NUMBER;
  l_balance_type_param VARCHAR2(240);
  l_mode_param VARCHAR2(240);
  l_fiscal_year_param VARCHAR2(240);
BEGIN
  SELECT concurrent_program_name,
         user_concurrent_program_name
  INTO   l_conc_pr_name,
         g_conc_pr_user
  FROM   fnd_concurrent_programs_vl
  WHERE  concurrent_program_id = l_conc_id;

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_conc_pr_name ||(rpad(' ',40,' '))||g_conc_pr_user );
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Process Run Id :'||fnd_global.CONC_REQUEST_ID);

  --l_param_out := FND_REQUEST_INFO.get_param_info(1,l_balance_type_param);
  --l_param_out := FND_REQUEST_INFO.get_param_info(10,l_mode_param);
  --l_param_out := FND_REQUEST_INFO.get_param_info(20,l_fiscal_year_param);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Balance Type'||' : '||p_balance_type);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Mode'||' : '||p_mode);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Fiscal Year'||' : '||p_fiscal_year);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  commit;
EXCEPTION
WHEN OTHERS THEN
  FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
END;

PROCEDURE print_enc_stat(p_fiscal_year IN NUMBER) IS
  CURSOR c_result IS
  SELECT period_name,
         SUM(1) total_count,
         SUM(decode(mig_request_id,fnd_global.CONC_REQUEST_ID,
              decode(substr(mig_result_code,1,1),'P',1,0)
              ,0)) migrated_count,
         SUM(decode(substr(mig_result_code,1,1),'P',0,1)) pending_count
  FROM igc_cbc_je_lines
  WHERE period_year = p_fiscal_year
  AND   set_of_books_id = g_sob_id
  AND   actual_flag = 'E'
  AND   DETAIL_SUMMARY_CODE = 'D'
  group by period_name;
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('=',40,'=')||'CBC Encumbrance Migration Result========================'||rpad('=',40,'='));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('Period Name',30,' ')||' '||rpad('Migrated Lines',25,' ')||' '||rpad('Pending Lines',25,' ')||' '||rpad('Total Lines',25,' '));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(' ',30,' ')||' '||rpad('In Request Id '||fnd_global.CONC_REQUEST_ID,25,' '));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('-',30,'-')||' '||rpad('-',25,'-')||' '||rpad('-',25,'-')||' '||rpad('-',25,'-'));
  FOR l_result IN c_result
  LOOP
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(l_result.period_name,30,' ')||' '||rpad(l_result.migrated_count,25,' ')||' '||rpad(l_result.pending_count,25,' ')||' '||rpad(l_result.total_count,25,' '));
  END LOOP;

END;

PROCEDURE print_enc_exceptions(p_fiscal_year IN NUMBER) IS
  CURSOR c_fail IS
  SELECT  b.name,to_char(l.cbc_je_line_num) cbc_je_line_num,
          gl.meaning
  FROM    igc_cbc_je_lines l,igc_cbc_je_batches b,
          gl_lookups gl
  WHERE   b.cbc_je_batch_id = l.cbc_je_batch_id
  AND     gl.lookup_type LIKE 'FUNDS_CHECK_RESULT_CODE'
  AND     l.mig_result_code like 'F%'
  AND     gl.lookup_code = l.mig_result_code
  AND     l.period_year = p_fiscal_year
  AND     l.actual_flag = 'E';
  bln_error_found BOOLEAN := FALSE;
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('=',40,'=')||'CBC Encumbrance details - Failed to Migrate to R12========================'||rpad('=',40,'='));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('Batch Name',50,' ')||' '||rpad('Line Num',10,' ')||' '||rpad('Failed Reason',60,' '));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('-',50,'-')||' '||rpad('-',10,'-')||' '||rpad('-',60,'-'));
  FOR l_fail in c_fail
  LOOP
    IF (NOT bln_error_found) THEN
      bln_error_found := TRUE;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(l_fail.name,1,50),50,' ')||' '||rpad(l_fail.cbc_je_line_num,10,' ')||' '||rpad(substr(l_fail.meaning,1,60),60,' '));
  END LOOP;
  IF NOT bln_error_found THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'NO DATA FOUND');
  END IF;
END;


PROCEDURE print_errors IS
BEGIN
  /* Print Header */
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('=',40,'=')||'Following Validation error(s) occured'||rpad('=',40,'='));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('SL NO.',10,' ')||' '||rpad('Error Description',60,' '));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('-',10,'-')||' '||rpad('-',100,'-'));
  IF g_tbl_basic_errors.COUNT <= 0 THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'NO DATA FOUND');
    return;
  END IF;
  FOR i in 1..g_tbl_basic_errors.COUNT
  LOOP
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lpad(to_char(i),10,' ')||' '||substr(g_tbl_basic_errors(i).error_mesg,1,100));
  END LOOP;


END print_errors;

PROCEDURE print_end_report IS
BEGIN

FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('=',63,'=')||'End of Report'||rpad('=',62,'='));

END print_end_report;

PROCEDURE print_budget_stats IS
BEGIN
  /* Print Header */
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'================Following Budget Data created in CBC ledger========================');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('Primary Ledger Budget Name',30,' ')||' '||rpad('CBC Ledger Budget Name',30,' '));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('-',30,'-')||' '||rpad('-',30,'-'));
  IF g_tbl_bud_map.COUNT < 1 THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'NO DATA FOUND');
  END IF;

  FOR i in 1..g_tbl_bud_map.COUNT
  LOOP
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(g_tbl_bud_map(i).old_budget_name,30,' ')||' '||rpad(g_tbl_bud_map(i).new_budget_name,30,' '));
  END LOOP;

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('Primary Ledger Budget Organization',40,' ')||' '||rpad('CBC Ledger Budget Organization',40,' '));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('-',40,'-')||' '||rpad('-',40,'-'));
  IF g_tbl_bud_entity_map.COUNT < 1 THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'NO DATA FOUND');
  END IF;

  FOR i in 1..g_tbl_bud_entity_map.COUNT
  LOOP
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(g_tbl_bud_entity_map(i).old_bud_entity,40,' ')||' '||rpad(g_tbl_bud_entity_map(i).new_bud_entity,40,' '));
  END LOOP;


END print_budget_stats;

PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
) IS
BEGIN
  IF(g_state_level >= g_debug_level) THEN
    FND_LOG.STRING(g_state_level, p_path, p_debug_msg);
  END IF;
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
          NULL;
        RETURN;
END Put_Debug_Msg;

END  IGC_UPGRADE_DATA_R12;

/
