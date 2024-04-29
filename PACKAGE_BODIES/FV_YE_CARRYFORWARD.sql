--------------------------------------------------------
--  DDL for Package Body FV_YE_CARRYFORWARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_YE_CARRYFORWARD" AS
--$Header: FVXYECFB.pls 120.22.12010000.1 2008/07/28 06:33:42 appldev ship $
      --  ======================================================================
    --                  Variable Naming Conventions
    --  ======================================================================
    --  1. Input/Output Parameter global variables
    --     have the format                                   "vp_<Variable Name>"
    --  2. Other Global Variables have the format            "vg_<Variable_Name>"
    --  3. Procedure Level local variables have
    --     the format                                        "vl_<Variable_Name>"
    --  4. PL/SQL Table variables have                       "vt_<Variable_Name>"
    --  5. User Defined Exceptions have                      "e_<Exception_Name>"
    --  6. Variable Cursors have                             "vc_<Variable_Name>"
    --  ======================================================================
    --                          Parameter Global Variable Declarations
    --  ======================================================================
    vp_errbuf           VARCHAR2(1000)                          ;
    vp_retcode          NUMBER := 0                             ;
    vp_sob_id           Gl_Sets_Of_Books.set_of_books_id%TYPE  ;
    vp_carryfor_fyr     Gl_Periods.period_year%TYPE             ;
    --  ======================================================================
    --                           Other Global Variable Declarations
    --  ======================================================================
    vg_coa_id           Gl_Sets_Of_Books.chart_of_accounts_id%TYPE;
    vg_bal_seg_value    varchar2(30);
    vg_period_set_name  Gl_Sets_Of_Books.period_set_name%TYPE;
    vg_currency         Gl_Sets_Of_Books.currency_code%TYPE;
    vg_closing_period   Gl_Period_Statuses.period_name%TYPE;
    vg_carryfor_period  Gl_Period_Statuses.period_name%TYPE;
    vg_start_date       Gl_Period_Statuses.start_date%TYPE;
    vg_closing_fyr      Gl_Periods.period_year%TYPE;
    vg_jrnl_group_id    NUMBER;
    vg_interface_run_id NUMBER;
    vg_bal_seg_val_opt_code VARCHAR2(1);
    vg_acct_seg_name varchar2(250);
    TYPE t_numbertable IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;
    TYPE t_reference IS TABLE OF VARCHAR2(250)
  INDEX BY BINARY_INTEGER;
    vt_dr_balances   t_numbertable;
    vt_cr_balances   t_numbertable;
    vt_ccids          t_numbertable;
    vt_reference       t_reference;
    e_error    EXCEPTION;

    vg_public_law_attribute    fv_system_parameters.factsii_pub_law_code_attribute%TYPE;
    vg_advance_type_attribute  fv_system_parameters.factsii_advance_type_attribute%TYPE;
    vg_trf_dept_id_attribute   fv_system_parameters.factsii_tr_dept_id_attribute%TYPE;
    vg_trf_main_acct_attribute fv_system_parameters.factsii_tr_main_acct_attribute%TYPE;

    vg_facts_attributes_setup  BOOLEAN ;
    g_module_name VARCHAR2(100);
    c_gl_line_cur      INTEGER;

-- ------------------------------------------------------------------
--                      Procedure Main
-- ------------------------------------------------------------------
-- Main procedure that is called from the Carry Forward budgetary
-- account balances concurrent request. This procedure calls all the
-- subsequent procedures in the Carry forward process.
-- ------------------------------------------------------------------
PROCEDURE Main( errbuf                  OUT NOCOPY VARCHAR2,
                retcode                 OUT NOCOPY NUMBER,
                sob                      NUMBER,
                carryfor_fyr                NUMBER) IS
     l_module_name         VARCHAR2(200) ;
     l_bc_count            NUMBER;
BEGIN
l_module_name         :=  g_module_name || 'main ';
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'STARTING THE CARRY FORWARD BUDGETARY ACCOUNT ' ||
    'Balances Process.....');
         END IF;
   -- Assign initial values
   vp_retcode := 0;
   vp_errbuf  := NULL;
   -- Load the parameter global variables
   vp_sob_id            := sob;
   vp_carryfor_fyr      := carryfor_fyr;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THE PARAMETERS PASSED TO THE CARRY FORWARD PROCESS ARE: '||
                'Set of books id = '||TO_CHAR(vp_sob_id)||
    ',Carry Forward Fiscal Year = '||TO_CHAR(vp_carryfor_fyr));
       END IF;

       SELECT count(*)
         INTO l_bc_count
         FROM gl_period_statuses
         WHERE application_id = 101
           AND ledger_id = vp_sob_id
           AND period_year = vp_carryfor_fyr
           AND NVL(track_bc_ytd_flag, 'N') = 'Y';

       IF (l_bc_count > 0) THEN
         FV_UTILITY.LOG_MESG (FND_LOG.LEVEL_ERROR, l_module_name, 'Carry forward process is not allowed for this year.');
         vp_retcode := -1;
         retcode := vp_retcode;
         RETURN;
       END IF;
    -- Get the Coa and Currency Code
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'GETTING THE CHART OF ACCOUNTS AND CURRENCY CODE');
 END IF;
   Get_Required_Parameters;
   IF (vp_retcode = 0) THEN
      -- Get the Closing Fyr,Last Period for the Closing Fyr and
      -- First Period for the Carry Forward Fyr
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'GETTING THE CLOSING FYR, LAST PERIOD '||
                                'of the Closing Fiscal Year and '||
        'First Period of the Carry Forward Fiscal Year');
            END IF;
      Get_Period_Details;
   END IF;
   IF (vp_retcode = 0) THEN
      -- Clean up gl_interface table,if any records exist in the interface
      -- from the previous run of the process.
      Cleanup_Gl_Interface;
   END IF;
   IF (vp_retcode = 0) THEN
      -- Check if the Carry Forward process has been run earlier
      -- for the same period.
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CHECKING IF THE CARRYFORWARD PROCESS HAS BEEN '||
    'run earlier for the same period.');
 END IF;

      Check_Carryforward_Process;
   END IF;
   IF vp_retcode <> 0 THEN
        -- Check for errors
        errbuf := vp_errbuf;
        retcode := vp_retcode;
        ROLLBACK;
   ELSE
        COMMIT;
        retcode := 0;
        errbuf  := '** Carry Forward Budgetary Account Balances Process '||
      'completed successfully **';
   END IF;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ENDING THE CARRY FORWARD BUGETARY ACCOUNT BALANCES '||
      'Process ......');
             END IF;
EXCEPTION
   WHEN OTHERS THEN
        ROLLBACK;
        errbuf := '** Carry Forward Budgetary Account Balances Process Failed ** '
        ||SQLERRM;

        retcode := 2;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name
                                                           ,errbuf);
        END IF;
END Main;
-- ------------------------------------------------------------------
--                      Procedure Get_Required_Parameters
-- ------------------------------------------------------------------
-- Get_Required_Parameters procedure is called from Main procedure.
-- It gets the coa and the currency code.
-- ------------------------------------------------------------------
PROCEDURE Get_Required_Parameters IS
    l_module_name         VARCHAR2(200) ;
    l_err_code            BOOLEAN;
BEGIN
 l_module_name        :=  g_module_name || 'Get_Required_Parameters ';
   -- Get the Coa and Currency code
   BEGIN
        SELECT currency_code ,
               CHART_OF_ACCOUNTS_ID,
               BAL_SEG_VALUE_OPTION_CODE
        INTO vg_currency ,
             vg_coa_id  ,
             vg_bal_seg_val_opt_code
        FROM gl_ledgers_public_v
        WHERE ledger_id = vp_sob_id;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   CHART OF ACCOUNTS ID = '||TO_CHAR(VG_COA_ID));
     END IF;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   CURRENCY CODE = '||VG_CURRENCY);
        END IF;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            vp_errbuf := 'Error in Get_Required_Parameters:'||
                        ' Currency Code or Chart of Account is not defined';
            vp_retcode := 1;
            RETURN;
   END;

FV_UTILITY.get_segment_col_names(                       vg_coa_id,
                                                         vg_acct_seg_name,                                                                 Vg_bal_seg_value ,
                                                         l_err_code,
                                                         vp_errbuf) ;


   BEGIN
        SELECT factsii_pub_law_code_attribute,
         factsii_advance_type_attribute, factsii_tr_dept_id_attribute,
         factsii_tr_main_acct_attribute
        INTO   vg_public_law_attribute,
               vg_advance_type_attribute, vg_trf_dept_id_attribute,
               vg_trf_main_acct_attribute
        FROM   Fv_System_Parameters;

        -- Set the global variable to false if public law code and other parameters
        -- are not setup in the define system parameters form.
        IF (vg_public_law_attribute IS NULL OR
            vg_advance_type_attribute IS NULL OR
            vg_trf_dept_id_attribute IS NULL OR
            vg_trf_main_acct_attribute IS NULL)
          THEN
            vg_facts_attributes_setup := FALSE;
         ELSE
            vg_facts_attributes_setup := TRUE;
        END IF;

   EXCEPTION
        WHEN OTHERS THEN
            vp_errbuf := 'Error in Get_Required_Parameters:'||
                  ' While determining the FACTS I Journal Attribute.';
            vp_retcode := 2;
   END;

EXCEPTION
     WHEN OTHERS THEN
            vp_retcode := 2 ;
            vp_errbuf  := SQLERRM ||' -- Error in Get_Required_Parameters procedure.';
           IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name
                                                           ,vp_errbuf );
           END IF;
            RETURN ;
END Get_Required_Parameters;
-- ------------------------------------------------------------------
--                      Procedure Get_Period_Details
-- ------------------------------------------------------------------
-- Get_Period_Details procedure is called from Main procedure.
-- It gets the closing_fyr,last_period of the closing fyr,first period
-- of the carry forward fyr.
-- ------------------------------------------------------------------
PROCEDURE Get_Period_Details IS
   l_module_name         VARCHAR2(200) ;
   vl_adj_flag    Gl_Period_Statuses.adjustment_period_flag%TYPE;
   vl_closing_status  Gl_Period_Statuses.closing_status%TYPE;
BEGIN
l_module_name    :=  g_module_name ||
                                       'Get_Period_Details ';
   -- Get the Closing Fyr
   vg_closing_fyr := vp_carryfor_fyr - 1;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   CLOSING FISCAL YEAR IS = '||TO_CHAR(VG_CLOSING_FYR));
 END IF;
   -- Get the Last Period of the Closing Fyr
   BEGIN
        SELECT period_name
        INTO vg_closing_period
        FROM Gl_Period_Statuses
        WHERE ledger_id = vp_sob_id
        AND application_id = 101
        AND period_year = vg_closing_fyr
        AND period_num = (SELECT MAX(period_num)
                          FROM gl_period_statuses
                          WHERE ledger_id = vp_sob_id
                          AND application_id = 101
                          AND period_year = vg_closing_fyr);
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   LAST PERIOD OF THE CLOSING FISCAL YEAR = '
                                ||vg_closing_period);
    END IF;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            vp_retcode := 1;
            vp_errbuf  := 'Error in Get_Period_Details: '||
                        'Last period is not defined for the Closing Fiscal Year.';
            RETURN;
        WHEN OTHERS THEN
            vp_retcode := 2 ;
            vp_errbuf  := SQLERRM||' -- Error in Get_Period_Details procedure,'||
                        'while getting the last period of closing fiscal year.' ;
            RETURN ;
   END;
   -- Get the First Period of the Carry Forward Fyr
   BEGIN
        SELECT period_name, adjustment_period_flag,
    closing_status,start_date
        INTO vg_carryfor_period,vl_adj_flag,
    vl_closing_status, vg_start_date
        FROM Gl_Period_Statuses
        WHERE ledger_id = vp_sob_id
        AND application_id = 101
        AND period_year = vp_carryfor_fyr
        AND period_num = (SELECT MIN(period_num)
                          FROM gl_period_statuses
                          WHERE ledger_id = vp_sob_id
                          AND application_id = 101
                          AND period_year = vp_carryfor_fyr);
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   FIRST PERIOD OF THE CARRY FORWARD FISCAL YEAR = '
                            ||vg_carryfor_period||', adjustment period flag = '
          ||vl_adj_flag||', and closing status = '
          ||vl_closing_status);
    END IF;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            vp_retcode := 1;
            vp_errbuf  := 'Error in Get_Period_Details: '||
                 'First period is not defined for the Carry Forward Fiscal Year.';
            RETURN;
        WHEN OTHERS THEN
            vp_retcode := 2 ;
            vp_errbuf  := SQLERRM||' -- Error in Get_Period_Details procedure,'||
                 'while getting the first period of carry forward fiscal year.' ;
            RETURN ;
   END;
   IF (vl_adj_flag = 'N') THEN
  vp_retcode := 2;
  vp_errbuf  := 'The first period of the Carry Forward Fiscal Year is '||
    ' not specified as an adjusting period.';
  RETURN;
   END IF;
   IF (vl_closing_status <> 'O') THEN
  vp_retcode := 2;
  vp_errbuf  := 'The first period of the Carry Forward Fiscal Year is '||
    'not an open period.';
  RETURN;
   END IF;
   BEGIN
  SELECT period_set_name
  INTO vg_period_set_name
  FROM Gl_Sets_Of_Books
  WHERE set_of_books_id = vp_sob_id;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   PERIOD SET NAME = '||VG_PERIOD_SET_NAME);
 END IF;
   EXCEPTION
        WHEN OTHERS THEN
            vp_retcode := 2 ;
            vp_errbuf  := SQLERRM||' -- Error in Get_Period_Details procedure,'||
                        'while getting the period set name.' ;
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name
                                                           ,vp_errbuf );
            END IF;
            RETURN ;
   END;


EXCEPTION
     WHEN OTHERS THEN
            vp_retcode := 2 ;
            vp_errbuf  := SQLERRM ||' -- Error in Get_Period_Details procedure.';
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name
                                                           ,vp_errbuf );
            END IF;
            RETURN ;
END Get_Period_Details;
-- ------------------------------------------------------------------
--                      Procedure Check_Carryforward_Process
-- ------------------------------------------------------------------
-- Check_Carryforward_Process procedure is called from Main procedure.
-- It checks whether the carryforward process has been run earlier for
-- the same period. If it has been run, then it checks to see if the
-- journal entries have been reversed or not.
-- ------------------------------------------------------------------
PROCEDURE Check_Carryforward_Process IS
   vl_cnt     NUMBER;
   vl_header_id    Gl_Je_Headers.je_header_id%TYPE;
   vl_accrrev_status    Gl_Je_Headers.accrual_rev_status%TYPE;
   vl_rev_header_id    Gl_Je_Headers.accrual_rev_je_header_id%TYPE;
   vl_rev_status    Gl_Je_Headers.status%TYPE;
   vl_status      Gl_Je_Headers.status%TYPE;
   CURSOR get_count_cur IS
  SELECT COUNT(*)
  FROM Gl_Je_Headers
  WHERE ledger_id = vp_sob_id
  AND je_source = 'Year End Close'
  AND je_category = 'Federal Carry Forward'
  AND period_name = vg_carryfor_period;
   CURSOR get_hdrs_cur IS
  SELECT je_header_id,accrual_rev_status,
    accrual_rev_je_header_id,status
  FROM Gl_Je_Headers
  WHERE ledger_id = vp_sob_id
  AND je_source = 'Year End Close'
  AND je_category = 'Federal Carry Forward'
  AND period_name = vg_carryfor_period;
   CURSOR get_revstat_cur IS
  SELECT status
  FROM Gl_Je_Headers
  WHERE ledger_id = vp_sob_id
  AND je_header_id = vl_rev_header_id;
     l_module_name         VARCHAR2(200);
BEGIN
 l_module_name         :=  g_module_name ||
                                         'Check_Carryforward_Process ';
   -- Check to see if there are any records existing in the headers table
   -- for the same period.
   OPEN get_count_cur;
   FETCH get_count_cur INTO vl_cnt;
   CLOSE get_count_cur;
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   THE NUMBER OF RECORDS EXISTING IN GL ARE '
      ||TO_CHAR(vl_cnt));
             END IF;
   IF (vl_cnt > 0) THEN
  FOR vc_hdrs IN get_hdrs_cur LOOP
     vl_header_id := vc_hdrs.je_header_id;
     vl_accrrev_status := vc_hdrs.accrual_rev_status;
     vl_rev_header_id := vc_hdrs.accrual_rev_je_header_id;
     vl_status := vc_hdrs.status;
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   IN THE LOOP FOR GETTING HEADERS, '||
      'processing the following:');
     END IF;
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   JE_HEADER_ID: '||TO_CHAR(VL_HEADER_ID) ||
      ', accrual_rev_status: '||vl_accrrev_status||
      ', accrual_rev_je_header_id: '||TO_CHAR(vl_rev_header_id));
     END IF;
           IF (vc_hdrs.accrual_rev_status IS NULL) THEN
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   ACCRUAL REV STATUS IS NULL, I.E. <> R');
          END IF;
    IF (vc_hdrs.accrual_rev_je_header_id IS NULL) THEN
             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   ACCRUAL REV JE HEADER ID IS NULL');
             END IF;
       vp_retcode := 1;
       IF (vc_hdrs.status = 'P') THEN
          vp_errbuf  := 'Carry Forward journal entries exist in GL:'||
        'Please reverse and post those entries and '||
        'then re-run the Carry Forward process.';
       ELSE
          vp_errbuf  := 'Carry Forward journal entries exist in GL:'||
        'Please delete the unposted journal entries and '||
        'then re-run the Carry Forward process.';
       END IF;
       RETURN;
    END IF;
     ELSE
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   ACCRUAL REV STATUS = R');
          END IF;
    OPEN get_revstat_cur;
    FETCH get_revstat_cur INTO vl_rev_status;
    CLOSE get_revstat_cur;
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   THE STATUS OF THE REVERSED JE IS = '||
        vl_rev_status);
          END IF;
    IF (vl_rev_status <> 'P') THEN
             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   STATUS <> POSTED');
             END IF;
       vp_retcode := 1;
       vp_errbuf  := 'Reverse Carry Forward journal entries exist '||
        'in GL, which are not posted.'||
        'Please post those entries and re-run the '||
        'Carry Forward process.';
       RETURN;
    END IF;
     END IF;
  END LOOP;
   END IF;
   -- Get Balances and ccid's
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   CALLING GET_BALANCES PROCEDURE');
 END IF;
   Get_Balances;
   IF (vp_retcode <> 0) THEN
       RAISE e_error;
   END IF;
EXCEPTION
     WHEN e_error THEN
            RETURN;
     WHEN OTHERS THEN
            vp_retcode := 2 ;
            vp_errbuf  := SQLERRM||' -- Error in Get_Carryforward_process procedure.';
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name
                                                           ,vp_errbuf );
            END IF;
            RETURN ;
END Check_Carryforward_Process;
-- ------------------------------------------------------------------
--                      Procedure Get_Balances
-- ------------------------------------------------------------------
-- Get_Balances procedure is called from Check_Carryforward_Process
-- procedure.It gets the balances and ccids for all the budgetary
-- accounts for the last period of the closing fyr.
-- ------------------------------------------------------------------
PROCEDURE Get_Balances IS
   vl_rec_found_flag   VARCHAR2(1) ;
   l_module_name       VARCHAR2(200);

 -- Dynamic Sql variables
   l_insert_stmt     VARCHAR2(2000);
   vl_attribute_cols    VARCHAR2(1024);
   vl_group_by_clause    VARCHAR2(1024);
   l_user_id       NUMBER(15) ;
   l_select_stmt        VARCHAR2(6000);
   vl_exec_cur       INTEGER ;
BEGIN
    vl_rec_found_flag  := 'N';
    l_user_id :=  fnd_global.user_id ;
   l_module_name         :=  g_module_name || 'Get_Balances ';
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      IN GET_BALANCES PROCEDURE');
   END IF;

   -- Setup Gl Interface
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      CALLING SETUP_GL_INTERFACE PROCEDURE');
   END IF;
   Setup_Gl_Interface;
   IF (vp_retcode <> 0) THEN
       RAISE e_error;
   END IF;

    IF vg_public_law_attribute IS NOT NULL THEN
       vl_attribute_cols := vl_attribute_cols||', NVL(b.public_law_code, l.'||vg_public_law_attribute||') ';
    ELSE
      vl_attribute_cols := vl_attribute_cols||', NULL';
    END IF;

   IF vg_advance_type_attribute IS NOT NULL THEN
       vl_attribute_cols := vl_attribute_cols||', NVL(b.advance_type, l.'||vg_advance_type_attribute||') ';
   ELSE
       vl_attribute_cols := vl_attribute_cols||', NULL';
   END IF;

   IF vg_trf_dept_id_attribute IS NOT NULL THEN
       vl_attribute_cols := vl_attribute_cols||', NVL(b.dept_id, l.'||vg_trf_dept_id_attribute||') ';
   ELSE
       vl_attribute_cols := vl_attribute_cols||', NULL';
   END IF;

   IF vg_trf_main_acct_attribute IS NOT NULL THEN
       vl_attribute_cols  := vl_attribute_cols||', NVL(b.main_account, l.'|| vg_trf_main_acct_attribute ||') ';
   ELSE
      vl_attribute_cols := vl_attribute_cols||', NULL';
   END IF;

  IF (vl_attribute_cols IS NOT NULL) THEN
      vl_group_by_clause := ' GROUP BY  gcc.code_combination_id ,' ||SUBSTR(vl_attribute_cols, 2);
  END IF;

 BEGIN
    c_gl_line_cur := DBMS_SQL.OPEN_CURSOR  ;
  EXCEPTION
    WHEN OTHERS THEN
      vp_retcode := 2;
      vp_errbuf  := SQLERRM|| ' Open cursor error in Populate_Gl_Interface procedure.';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,vp_errbuf);
      RAISE e_error;
  END ;

-- Constructing the insert into Gl interface from the select of the query
 BEGIN
 l_insert_stmt :=  ' INSERT INTO Gl_Interface(status,
                ledger_id    ,
                accounting_date    ,
                currency_code      ,
                date_created    ,
                created_by      ,
                actual_flag      ,
                user_je_category_name,
                user_je_source_name ,
                entered_dr      ,
                entered_cr      ,
                group_id      ,
                period_name      ,
                chart_of_accounts_id,
                code_combination_id ,
                reference21      ,
                attribute' || NVL(SUBSTR(vg_public_law_attribute   , 10),17) || ' ,
                attribute' || NVL(SUBSTR(vg_advance_type_attribute , 10),18) || ' ,
                attribute' || NVL(SUBSTR(vg_trf_dept_id_attribute  , 10),19) || ' ,
                attribute' || NVL(SUBSTR(vg_trf_main_acct_attribute, 10),20) || '  ) ';

 l_select_stmt :=
              ' SELECT
              ''NEW''  , '
              || vp_sob_id  || ' , '''
              || vg_start_date  || ''' , '''
              || vg_currency
              || ''' ,  SYSDATE , ' ||
               l_user_id || ' ,
               ''A''  ,
               ''Federal Carry Forward'' ,
               ''Year End Close'' , '
              || ' SUM(NVL(xl.unrounded_entered_dr,0)) debit,
              SUM(NVL(xl.unrounded_entered_cr,0)) credit  , '
              || vg_jrnl_group_id || ' , '''
              ||  vg_carryfor_period || ''' , '
              ||  vg_coa_id
              || ' ,   gcc.code_combination_id  , '
              || '  MAX(xdl.SOURCE_DISTRIBUTION_ID_NUM_1) reference_1 '
              || vl_attribute_cols || '
                      FROM  fv_be_trx_dtls B, xla_ae_lines xl ,
               xla_distribution_links xdl,   gl_je_lines l,
               gl_je_headers h , gl_code_combinations gcc,
               gl_import_references gir
              WHERE l.code_combination_id = gcc.code_combination_id
              AND l.je_header_id = h.je_header_id



       AND FV_YE_CARRYFORWARD.Check_bal_seg_value(GCC.'||VG_BAL_SEG_VALUE||',
                                                :sob_id,
                                :bal_seg_val_opt_code) = '||''''||'Y'||''''||
    '   AND  xl.code_combination_id = l.code_combination_id
      AND  gir.je_header_id = h.je_header_id
      AND  gir.je_batch_id = h.je_batch_id
      AND  gir.je_line_num = l.je_line_num
      AND  xl.ae_header_id = xdl.ae_header_id
      AND  xl.ae_line_num = xdl.ae_line_num
      AND  xl.gl_sl_link_id = gir.gl_sl_link_id
      AND  xl.currency_code = h.currency_code
      AND  NVL(h.je_from_sla_flag, ''N'')  =  ''Y''
      AND  EXISTS (SELECT 1
                                      FROM   gl_periods
                                      WHERE  period_year = :closing_fyr
                                      AND    period_set_name = :period_set_name
                                      AND    period_name = l.period_name)
                                                   AND  nvl(xdl.SOURCE_DISTRIBUTION_ID_NUM_1,-99)=b.transaction_id(+)
             AND b.set_of_books_id (+) = :sob_id
              AND l.status = ''P''
              AND h.actual_flag = ''A''
             AND h.ledger_id = :sob_id
              --AND h.currency_code = :vg_currency --bug 5570564
               AND h.currency_code <> ''STAT''
              AND  gcc.summary_flag = '||''''||'N'||''''||
              ' AND gcc.template_id IS NULL
               AND gcc.chart_of_accounts_id = :c_coa
                   AND gcc.account_type IN ('||''''||'C'||''''||','||
                   ''''||'D'||''''||')'||  vl_group_by_clause  ||
        ' UNION
 SELECT
              ''NEW''  , '
              || vp_sob_id  || ' , '''
              || vg_start_date  || ''' , '''
              || vg_currency
              || ''' ,  SYSDATE , ' ||
               l_user_id || ' ,
               ''A''  ,
               ''Federal Carry Forward'' ,
               ''Year End Close'' , '
              || ' SUM(NVL(l.accounted_dr,0)) debit,
              SUM(NVL(l.accounted_cr,0)) credit  , '
              || vg_jrnl_group_id || ' , '''
              ||  vg_carryfor_period || ''' , '
              ||  vg_coa_id
              || ' ,   gcc.code_combination_id  , '
              || '  MAX(fv_ye_carryforward.convert_to_num(l.reference_1)) '
              || vl_attribute_cols || '
                      FROM  gl_je_lines l , fv_be_trx_dtls b, gl_je_headers h , gl_code_combinations gcc
              WHERE l.code_combination_id = gcc.code_combination_id
               AND FV_YE_CARRYFORWARD.Check_bal_seg_value(GCC.'|| VG_BAL_SEG_VALUE||', :sob_id,:bal_seg_val_opt_code ) = '||''''||'Y'||''''||
    '          AND l.je_header_id = h.je_header_id
              AND  NVL(h.je_from_sla_flag, ''N'') IN (''N'',''U'')
              AND  EXISTS (SELECT 1
                                         FROM   gl_periods
                                      WHERE  period_year = :closing_fyr
                                      AND    period_set_name = :period_set_name
                                      AND    period_name = l.period_name)
              AND  nvl(Fv_Ye_Carryforward.Convert_To_Num(l.reference_1),-99)=b.transaction_id(+)
AND l.ledger_id = b.set_of_books_id(+)
AND l.status = ''P''
              AND h.actual_flag = ''A''
              AND h.ledger_id = :sob_id
              -- AND h.currency_code = :vg_currency --bug 5570564
              AND h.currency_code <> ''STAT''
              AND  gcc.summary_flag = '||''''||'N'||''''||
              ' AND gcc.template_id IS NULL
               AND gcc.chart_of_accounts_id = :c_coa
                   AND gcc.account_type IN ('||''''||'C'||''''||','||
                   ''''||'D'||''''||')'||  vl_group_by_clause ;




        l_select_stmt :=   l_insert_stmt  || '( ' ||  l_select_stmt || ')';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_select_stmt);
       END IF;
       dbms_sql.parse(c_gl_line_cur, l_select_stmt, DBMS_SQL.V7) ;
       --dbms_sql.bind_variable(c_gl_line_cur,':vg_currency', vg_currency); -- 5570564
         dbms_sql.bind_variable(c_gl_line_cur,':c_coa', vg_coa_id);
      dbms_sql.bind_variable(c_gl_line_cur,':sob_id', vp_sob_id);
      dbms_sql.bind_variable(c_gl_line_cur,':closing_fyr', vg_closing_fyr);
      dbms_sql.bind_variable(c_gl_line_cur,':period_set_name', vg_period_set_name);
      dbms_sql.bind_variable(c_gl_line_cur,':bal_seg_val_opt_code', vg_bal_seg_val_opt_code);

      vl_exec_cur := dbms_sql.EXECUTE(c_gl_line_cur);

     fnd_file.put_line(FND_FILE.LOG,'No of Records inserted into GL_interface :' || to_char(vl_exec_cur));
  EXCEPTION
    WHEN OTHERS THEN
      vp_retcode := 2;
      vp_errbuf  := SQLERRM|| ' Parse cursor error in Get_Balances procedure.';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,vp_errbuf);
      RAISE e_error;
  END ;

    IF dbms_sql.is_open(c_gl_line_cur) THEN
      dbms_sql.close_cursor(c_gl_line_cur);
    END IF;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'      SUBMITTING JOURNAL IMPORT.');
   END IF;
   Submit_Journal_Import;
   IF (vp_retcode <> 0) THEN
       RAISE e_error;
   END IF;

EXCEPTION
     WHEN e_error THEN
            IF dbms_sql.is_open(c_gl_line_cur) THEN
              dbms_sql.close_cursor(c_gl_line_cur);
          END IF;
            RETURN;
     WHEN OTHERS THEN
            IF dbms_sql.is_open(c_gl_line_cur) THEN
              dbms_sql.close_cursor(c_gl_line_cur);
          END IF;
            vp_retcode := 2 ;
            vp_errbuf  := l_select_stmt || SQLERRM||' -- Error in Get_Balances procedure.';
            RETURN ;
END Get_Balances;


-- ------------------------------------------------------------------
--                      Procedure Setup_Gl_Interface
-- ------------------------------------------------------------------
-- Setup_Gl_Interface procedure is called from Get_Balances procedure.
-- This proc inserts records in the gl_interface table, getting the ccids
-- and balances from the pl/sql tables and then runs journal import program.
-- ------------------------------------------------------------------
PROCEDURE Setup_Gl_Interface IS
   vl_req_id       NUMBER;
   vl_call_status  BOOLEAN;
   vl_rphase       VARCHAR2(30);
   vl_rstatus      VARCHAR2(30);
   vl_dphase       VARCHAR2(30);
   vl_dstatus      VARCHAR2(30);
   vl_message      VARCHAR2(240);
   vl_cnt      NUMBER;
    l_module_name         VARCHAR2(200);
BEGIN
     l_module_name          :=  g_module_name ||
                                        'Setup_Gl_Interface ';
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         IN SETUP_GL_INTERFACE PROCEDURE....');
 END IF;
   -- Get the interface_run_id
   vg_interface_run_id := Gl_Interface_Control_Pkg.Get_Unique_Run_Id;
   -- Get the journal group_id
   SELECT Gl_Interface_Control_S.NEXTVAL
   INTO vg_jrnl_group_id
   FROM DUAL;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         INTERFACE RUN ID: '
    ||TO_CHAR(vg_interface_run_id));
   END IF;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         JOURNAL GROUP ID: '
    ||TO_CHAR(vg_jrnl_group_id));
   END IF;
   --Insert a control record in gl_interface_control for gl_import to work
   INSERT INTO Gl_Interface_Control
        (je_source_name,
        status,
        interface_run_id,
        group_id,
        set_of_books_id)
   VALUES ('Year End Close',
        'S',
        vg_interface_run_id,
        vg_jrnl_group_id,
        vp_sob_id);
EXCEPTION
   WHEN OTHERS THEN
        vp_retcode := 2;
        vp_errbuf  := SQLERRM || '--Error in Setup_Gl_Interface procedure.';
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name
                                                           ,vp_errbuf);
        END IF;
        RETURN;
END Setup_Gl_Interface;

-- --------------------------------
-- Procedure Submit_Journal_Import
-- -------------------------------
PROCEDURE Submit_Journal_Import IS
  vl_req_id       NUMBER;
   vl_call_status  BOOLEAN;
   vl_rphase       VARCHAR2(30);
   vl_rstatus      VARCHAR2(30);
   vl_dphase       VARCHAR2(30);
   vl_dstatus      VARCHAR2(30);
   vl_message      VARCHAR2(240);
   l_module_name  VARCHAR2(200);

BEGIN
   l_module_name :=  g_module_name || 'Submit_Journal_Import ';
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         AFTER INSERTING INTO GL_INTERFACE....');
   END IF;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         CALLING THE JOURNAL IMPORT PROGRAM....');
   END IF;
   -- Submit a Concurrent request to invoke journal import
   vl_req_id := FND_REQUEST.SUBMIT_REQUEST('SQLGL',
                                    'GLLEZL',
                                     '',
                                     '',
                                     FALSE,
                                     TO_CHAR(vg_interface_run_id),
                                     TO_CHAR(vp_sob_id),
                                     'N', '', '', 'N', 'W');
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         THE REQUEST_ID IS '||VL_REQ_ID);
   END IF;
   -- if concurrent request submission failed then abort process
   IF (vl_req_id = 0) THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         JOURNAL IMPORT REQUEST NOT SUBMITTED.');
        END IF;
        vp_errbuf := 'Cannot submit journal import program';
        vp_retcode := 1;
        ROLLBACK;
        RETURN;
   ELSE
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'         JOURNAL IMPORT REQUEST SUBMITTED '||
                        'successfully.');
        END IF;
        COMMIT;
   END IF;

   -- Check status of completed concurrent program
   -- and if complete exit
   vl_call_status := Fnd_Concurrent.Wait_For_Request(
                vl_req_id, 20, 0, vl_rphase, vl_rstatus,
                vl_dphase, vl_dstatus, vl_message);
   IF (vl_call_status = FALSE) THEN
        vp_errbuf := 'Cannot wait for the status of journal import';
        vp_retcode := 1;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
        vp_retcode := 2;
        vp_errbuf  := SQLERRM || '--Error in Submit_Journal_Import procedure.';
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name
                                                         ,vp_errbuf);
        END IF;
        RETURN;
END Submit_Journal_Import;

-- ------------------------------------------------------------------
--                      Procedure Cleanup_Gl_Interface
-- ------------------------------------------------------------------
-- Cleanup_Gl_Interface procedure is called from Main
-- procedure. This cleans up the gl_interface table.
-- ------------------------------------------------------------------
PROCEDURE Cleanup_Gl_Interface IS
 l_module_name   VARCHAR2(200) ;
BEGIN
  l_module_name   :=  g_module_name ||  'Cleanup_Gl_Interface';
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'   IN THE CLEANUP_GL_INTERFACE PROCEDURE....');
 END IF;
   -- Delete from Gl_Interface table
   DELETE FROM Gl_Interface
   WHERE user_je_source_name = 'Year End Close'
   AND user_je_category_name = 'Federal Carry Forward'
   AND ledger_id = vp_sob_id;
EXCEPTION
   WHEN OTHERS THEN
        vp_retcode := 2;
        vp_errbuf  := SQLERRM || '-- Error in Cleanup_Gl_Interface procedure.';
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name
                                                           ,vp_errbuf);
        END IF;
        RETURN;
END Cleanup_Gl_Interface;
-- + --------------------------------------------------------------------- +
-- + Function to convert a cloumn value to Number                +
-- + This function returns Number if it a number else NULL            +
-- + --------------------------------------------------------------------- +
FUNCTION Convert_To_Num ( p_instr VARCHAR2) RETURN NUMBER
IS
 l_outnum number;
BEGIN
IF (p_instr IS NULL) THEN
  RETURN NULL;
END IF;
 l_outnum := p_instr;
 return l_outnum;
EXCEPTION
WHEN OTHERS THEN
 l_outnum:=0;
 return l_outnum;
END Convert_To_Num;

-- ------------------------------------------------------------------
--              Function Check_bal_seg_value
-- ------------------------------------------------------------------
--  BSV's are not always assigned to ledgers. Therefore we should not
--  enforce BSV assignemnt if there is no BSV flex value set
--  is assigned to a ledger.
--  IF bal_seg_value_option_code column value in GL_LEDGER table is
--  'A' that means all BSV's are valid. If the column is 'I',
--  then some BSV's are valid.
--  ------------------------------------------------------------------
FUNCTION Check_bal_seg_value(Vp_fund_value  VARCHAR2 ,
                                Vp_sob_id NUMBER,
                                Vp_bal_seg_val_opt_code VARCHAR)
RETURN  VARCHAR       IS

   l_module_name         VARCHAR2(200)  ;
   vl_valid_fund     VARCHAR2(1);
BEGIN
l_module_name    :=  g_module_name ||  'Check_bal_seg_value  ';
vl_valid_fund      := 'N';

IF Vp_bal_seg_val_opt_code <> 'I'  THEN
  RETURN 'Y';
END IF;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
      l_module_name,
      '   IN CHECK_BAL_SEG_VALUE PROCEDURE '||
        'with the following Parameters passed to the process:');
   END IF;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
       l_module_name,
      '   FUND VALUE= '||VP_FUND_VALUE);
   END IF;

BEGIN
      SELECT  'Y'
      INTO    vl_valid_fund
      FROM    gl_ledger_segment_values glsv
      WHERE   glsv.ledger_id = vp_sob_id
       AND     glsv.segment_type_code (+) = 'B'
      AND     NVL(glsv.status_code (+), 'X') <> 'I'
      AND     NVL(glsv.start_date (+),TO_DATE('1950/01/01','YYYY/MM/DD'))
               <= NVL(sysdate,TO_DATE('9999/12/31','YYYY/MM/DD'))
      AND     NVL(glsv.end_date (+),TO_DATE('9999/12/31','YYYY/MM/DD'))
               >= NVL(sysdate, TO_DATE('1950/01/01','YYYY/MM/DD'))
      AND     glsv.segment_value   = Vp_fund_value;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       vl_valid_fund := 'N' ;
END ;
       RETURN vl_valid_fund ;

EXCEPTION
      WHEN OTHERS THEN
        vp_retcode := 2 ;
        vp_errbuf  := SQLERRM  ||
    ' -- Error in Check Check_bal_seg_value procedure.' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,
       l_module_name,
                         'When Others Exception ' || vp_errbuf );
        END IF;
        RETURN 'N';
END Check_bal_seg_value;

BEGIN
  g_module_name := 'fv.plsql.Fv_Ye_Carryforward.';
END Fv_Ye_Carryforward;

/
