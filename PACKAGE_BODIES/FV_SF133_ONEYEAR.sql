--------------------------------------------------------
--  DDL for Package Body FV_SF133_ONEYEAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SF133_ONEYEAR" AS
--$Header: FVSF133B.pls 120.28.12010000.13 2010/02/26 15:28:13 snama ship $
--    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
  g_module_name VARCHAR2(100) ;

-- ------------------------------------
-- Stored Input Parameters
-- ------------------------------------
  v_debug  BOOLEAN  := TRUE;
  parm_application_id        NUMBER;
  parm_set_of_books_id       NUMBER;
  parm_gl_period_year        NUMBER;
  parm_gl_period_num         NUMBER;
  parm_treasury_value_r1         VARCHAR2(35);
  parm_run_mode                  VARCHAR2(10);

-- New Variable declared by Surya on 04/30/98 to receive the value of
-- the passed quarter number
   parm_gl_period_name        gl_period_statuses.period_name%TYPE;
  parm_treasury_symbol_id     fv_treasury_symbols.treasury_symbol_id%TYPE;

-- ------------------------------------
-- All Pre-build Query Variables
-- ------------------------------------
  g_chart_of_accounts_id      gl_ledgers_public_v.chart_of_accounts_id%TYPE;
  g_fund_segment_name           VARCHAR2(10);
--
-- ------------------------------------
-- Stored Global Variables
-- ------------------------------------
  g_treasury_symbol_id     fv_treasury_symbols.treasury_symbol_id%TYPE;
  g_federal_acct_symbol_id  number(15);
  g_insert_count                NUMBER;
  g_error_code                  NUMBER;
  g_error_message               VARCHAR2(400);
--
  g_period_num          NUMBER;
  g_ts_value_in_process         VARCHAR2(25);
  g_total_start_line_number     NUMBER;
  g_subtotal_start_line_number     NUMBER;
  g_column_number               NUMBER;
  g_currency_code               VARCHAR2(15);
--g_currency_code added for bug No. 1553099

  c_total_balance       NUMBER;
  c_ending_balance      NUMBER;
  c_begin_balance       NUMBER;
--  c_begin_select        VARCHAR2(200);
--  c_end_select          VARCHAR2(200);
  c_begin_period        VARCHAR2(40);
  c_end_period          VARCHAR2(40);

--  New variables declared by Narsimha to get the resource type from fv_treasury_sybols.

    c_resource_type       fv_treasury_symbols.resource_type%TYPE;
    c_rescission_flag     varchar2(10);

-- New variables declared by Narsimha Balakkari on 04/07/99 to capture
-- Established Year and Cancellation Year for given treasury symbol

       g_established_year   NUMBER;
       g_cancellation_year  NUMBER;

-- ---------- Flex Segment Name Cursor Variables ---------
  c_segment_name         fnd_id_flex_segments.segment_name%TYPE;
  c_flex_column_name     fnd_id_flex_segments.application_column_name%TYPE;
--
  v_balance_column_name  	fnd_id_flex_segments.application_column_name%TYPE;
  g_seg_value_set_id FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_ID%TYPE;
-- ---------- Treasury Symbol Report Line Cursor Vaiables -----------
  c_sf133_ts_value     gl_code_combinations.segment1%TYPE;
  c_sf133_line_id        fv_sf133_definitions_lines.sf133_line_id%TYPE;
  c_sf133_line_number    fv_sf133_definitions_lines.sf133_line_number%TYPE;
  c_sf133_prev_line_number    fv_sf133_definitions_lines.sf133_line_number%TYPE;
  c_sf133_line_type_code fv_sf133_definitions_lines.sf133_line_type_code%TYPE;
  c_sf133_natural_bal_type fv_sf133_definitions_lines.sf133_natural_balance_type%TYPE;
  c_sf133_line_category  fv_sf133_definitions_lines.sf133_fund_category%TYPE;

-- New variable declared by pkpatel to fix Bug 1575992
    c_sf133_treasury_symbol_id  fv_treasury_symbols.treasury_symbol_id%TYPE;
--sf133 begin
    c_acct_number fv_sf133_definitions_accts.acct_number%TYPE;
    c_direct_or_reimb_code fv_sf133_definitions_accts.direct_or_reimb_code%TYPE;
    c_apportionment_category_code fv_sf133_definitions_accts.apportionment_category_code%TYPE;
    c_category_b_code fv_sf133_definitions_accts.category_b_code%TYPE;
    c_prc_code fv_sf133_definitions_accts. prc_code%TYPE;
    c_advance_code fv_sf133_definitions_accts.advance_code%TYPE;
    c_availability_time fv_sf133_definitions_accts.availability_time%TYPE;
    c_bea_category_code fv_sf133_definitions_accts.bea_category_code%TYPE;
    c_borrowing_source_code fv_sf133_definitions_accts.borrowing_source_code%TYPE;
    c_transaction_partner fv_sf133_definitions_accts.transaction_partner%TYPE;
    c_year_of_budget_authority fv_sf133_definitions_accts.year_of_budget_authority%TYPE;
    c_prior_year_adjustment fv_sf133_definitions_accts.prior_year_adjustment%TYPE;
    c_authority_type fv_sf133_definitions_accts.authority_type%TYPE;
    c_tafs_status fv_sf133_definitions_accts.tafs_status%TYPE;
    c_availability_type fv_sf133_definitions_accts.availability_type%TYPE;
    c_expiration_flag fv_sf133_definitions_accts.expiration_flag%TYPE;
    c_fund_type fv_sf133_definitions_accts.fund_type%TYPE;
    c_financing_account_code fv_sf133_definitions_accts.financing_account_code%TYPE;

    exp_date date;
    beg_date date;
    close_date date;
    whether_Exp varchar2(1);
    report_period_num       NUMBER  ;

    whether_Exp_SameYear varchar2(1);
  expiring_year number;

  errbuf_facts        VARCHAR2(1000);
  retcode_facts      NUMBER;
  p_ledger_id     	NUMBER;
  treasury_symbol         VARCHAR2(15);
  report_fiscal_yr        NUMBER  ;

  run_mode_fact                VARCHAR2(15);
  contact_fname       	VARCHAR2(15);
  contact_lname       	VARCHAR2(15);
  contact_phone       	NUMBER  ;
  contact_extn        	NUMBER  ;
  contact_email       	VARCHAR2(15);
  contact_fax     	NUMBER;
  contact_maiden      	VARCHAR2(15);
  supervisor_name     	VARCHAR2(15);
  supervisor_phone    	NUMBER  ;
  supervisor_extn     	NUMBER  ;
  agency_name_1       	VARCHAR2(15);
  agency_name_2       	VARCHAR2(15);
  address_1       	VARCHAR2(15);
  address_2       	VARCHAR2(15);
  city            	VARCHAR2(15);
  state           	VARCHAR2(15);
  zip         		VARCHAR2(15);
  currency_code           VARCHAR2(15);


  l_year_counter  Number ;  --  FOR loop counter
    l_process_year  Number ;  --  Process Year for Previous Years
    L_BEG_PERIOD_PREV NUMBER ;  --  Beginning Period-Previous Year
    L_END_PERIOD_PREV NUMBER ;  --  Ending  period-previous year
    L_LOOP_YEAR   NUMBER;
    l_federal_acct_symbol_id  number(15);

--   new variabla declared by Narsimha.

  c_sf133_report_line_number   fv_sf133_definitions_lines.sf133_report_line_number%TYPE;
--
-- ---------- Balance Type Cursor Vaiables ---------
  c_sf133_line_acct_id  fv_sf133_definitions_accts.sf133_line_acct_id%TYPE;
  c_sf133_balance_type  fv_sf133_definitions_accts.sf133_balance_type%TYPE;

--  new variables declared by Narsimha.

-- c_sf133_apportion_amt    number;
 c_sf133_additional_info  fv_sf133_definitions_accts.sf133_additional_info%TYPE;

-- ---------- Treasury Symbol Accummulation Cursor Vaiables ---------
  c_sf133_column_amount fv_sf133_definitions_cols_temp.sf133_column_amount%TYPE;
  c_sf133_amount_not_shown fv_sf133_definitions_cols_temp.sf133_amount_not_shown%TYPE;
--
-- ---------- Output Report Line Column Data -------------
  o_sf133_ts_value    fv_sf133_definitions_cols_temp.sf133_fund_value%TYPE;
  o_sf133_line_id       fv_sf133_definitions_cols_temp.sf133_line_id%TYPE;
  o_sf133_column_number fv_sf133_definitions_cols_temp.sf133_column_number%TYPE;
  o_sf133_column_amount fv_sf133_definitions_cols_temp.sf133_column_amount%TYPE;
  o_sf133_amt_not_shown fv_sf133_definitions_cols_temp.sf133_amount_not_shown%TYPE;

-- New variable declared by pkpatel to fix Bug 1575992
    o_sf133_treasury_symbol_id fv_treasury_symbols.treasury_symbol_id%TYPE;
-- New Variables for using dynamic SQL
 v_select                   VARCHAR2(30000);
 v_cursor_id                    INTEGER;
 v_cursor_id_ind     INTEGER;


    c_sf133_amt2_not_shown      Number ;
    c_sf133_amt3_not_shown      Number ;
    c_sf133_amt4_not_shown      Number ;
    c_sf133_amt5_not_shown      Number ;
    c_sf133_amt6_not_shown      Number ;

    c_sf133_column_amount2      Number ;
    c_sf133_column_amount3      Number ;
    c_sf133_column_amount4      Number ;
    c_sf133_column_amount5      Number ;
    c_sf133_column_amount6      Number ;

--
--Added ts_range_cursor as part of Enh #2129123
/* Cursor to select treasury symbols which fall in specified range */
   CURSOR ts_range_cursor(tsymbol_r1 VARCHAR2,tsymbol_r2 VARCHAR2) IS
       SELECT treasury_symbol,treasury_symbol_id
       FROM fv_treasury_symbols
       WHERE treasury_symbol BETWEEN tsymbol_r1 AND tsymbol_r2
       AND  time_frame ='SINGLE'
       AND (fund_group_code NOT BETWEEN '3800' AND '3899')
       AND (fund_group_code NOT BETWEEN '6001' AND '6999')
       AND  set_of_books_id = parm_set_of_books_id
       ORDER BY treasury_symbol;

    DSum_E NUMBER;
    CSum_E NUMBER;
    DSum_B NUMBER;
    CSum_B NUMBER;
e_bal_indicator VARCHAR2(1);
b_bal_indicator VARCHAR2(1);

-- ---------- Define Segment Name Cursor -----------------
  CURSOR flex_field_column_name_cursor
      IS
    SELECT UPPER(glflex.segment_name)             segment_name,
           UPPER(glflex.application_column_name)  flex_column_name
      FROM fnd_id_flex_segments      glflex
     WHERE glflex.application_id = 101
       AND glflex.id_flex_num    = g_chart_of_accounts_id
       AND glflex.id_flex_code   = 'GL#'
  ORDER BY glflex.application_column_name;
--
-- ---------- Define Report Treasury Symbol Line Cursor -------------
  -- MODIFIED BY SURYA ON 5/6/98 TO REPLACE FV_FUND_PARAMETERS WITH
  -- FV_TREASURY_SYMBOLS

  -- Modified by Surya on 1/20/99 to add another join for SOB to fix
  -- data duplication
  --pkpatel :Changed to fix Bug 1575992
  CURSOR ts_report_line_cursor
      IS
     SELECT
           FTS.treasury_symbol               sf133_ts_value,
       FTS.treasury_symbol_id       sf133_treasury_symbol_id,
           line.sf133_line_id                sf133_line_id,
           line.sf133_line_number            sf133_line_number,
           line.sf133_line_type_code         sf133_line_type_code,
       line.sf133_natural_balance_type   sf133_natural_balance_type,
       line.sf133_fund_category      sf133_line_category,
           line.sf133_report_line_number      sf133_report_line_number
     FROM fv_sf133_definitions_lines    line,
         FV_TREASURY_SYMBOLS    FTS
    WHERE FTS.Treasury_symbol   = parm_treasury_value_r1
       AND FTS.set_of_books_id      = parm_set_of_books_id
       AND (line.sf133_line_type_code) IN ('T', 'D', 'D2')
       AND line.set_of_books_id         =  FTS.set_of_books_id
    ORDER BY FTS.treasury_symbol,
           line.sf133_line_number ;
--
-- ---------- Determine Balance Type of Acct   -------------
--
    CURSOR balance_type_cursor
    IS
      SELECT sf133_line_acct_id,
      sf133_balance_type,
      acct_number,
      direct_or_reimb_code,
      apportionment_category_code,
      category_b_code,
      prc_code,
      advance_code,
      availability_time,
      bea_category_code,
      borrowing_source_code,
      transaction_partner,
      year_of_budget_authority,
      prior_year_adjustment,
      authority_type,
      tafs_status,
      availability_type,
      expiration_flag,
      fund_type,
      financing_account_code
    FROM fv_sf133_definitions_accts
    WHERE sf133_line_id = c_sf133_line_id ;

 PROCEDURE determine_acct_flex_segments;
 PROCEDURE purge_temp_table;
 PROCEDURE build_report_lines;
 PROCEDURE build_fiscal_line_columns(c_begin_period Number,
        c_end_period Number, c_fiscal_year Number);
 PROCEDURE build_total_line_columns;
 PROCEDURE populate_temp_table;
 PROCEDURE populate_gtt_with_ccid
 (
   p_treasury_symbol_id NUMBER
 );

 PROCEDURE GET_BAL_TYPE;
 PROCEDURE process_total_line;

--
-- Added by Surya on 05/08/98 to get beginning and ending periods
-- for a given Fiscal year.
PROCEDURE GET_BEGIN_ENDING_PERIODS(  V_PROCESS_YEAR         NUMBER,
                         V_BEGIN_PERIOD IN OUT NOCOPY NUMBER,
                         V_END_PERIOD   IN OUT NOCOPY NUMBER ) ;
 abort_error                     EXCEPTION ;
 --
-- ---------- End of Package Level Declaritives -----------------------------
--
-- ------------------------------------------------------------------
PROCEDURE Main
         (
          errbuf     OUT NOCOPY VARCHAR2,
          retcode    OUT NOCOPY NUMBER,
          run_mode      IN VARCHAR2,
          set_of_books_id   IN NUMBER,
          gl_period_year    IN NUMBER,
          gl_period_name    IN VARCHAR2,
          treasury_symbol_r1    IN VARCHAR2,
          treasury_symbol_r2    IN VARCHAR2)
--
IS
--
  l_module_name VARCHAR2(200) ;
/*Variables used to store Request Details */
l_req_id        NUMBER :=NULL;
--l_status        VARCHAR2(30);
--l_phase         VARCHAR2(30);
--l_devphase      VARCHAR2(30);
--l_devstatus         VARCHAR2(30);
--l_message           VARCHAR2(300);
--l_boolean       BOOLEAN;


BEGIN
    l_module_name := g_module_name || 'Main';
--

-- ------------------------------------
-- Store Input Parameters in Global Variables
-- ------------------------------------
  if v_debug then
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'START OF PROGRAM');
  END IF;
  end if;
  parm_application_id  := '101';
  parm_set_of_books_id := set_of_books_id;
  parm_gl_period_year  := gl_period_year;
  parm_gl_period_name := gl_period_name;
  parm_run_mode        :=  UPPER(run_mode);



 select currency_code,
        chart_of_accounts_id
 into   g_currency_code,
        g_chart_of_accounts_id
 from   gl_ledgers_public_v
 where  ledger_id = parm_set_of_books_id;
--Added for bug No. 1553099

-- ----------------------------------------
-- Display Program Initialization
-- ----------------------------------------

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FVSF133 STARTING, '
                          ||' Run Mode is '||parm_run_mode);
  END IF;


  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'-- APID('||NVL(PARM_APPLICATION_ID,0)     ||')'
                        ||' SoB('||NVL(parm_set_of_books_id,0)    ||')'
                       ||' Year('||NVL(parm_gl_period_year,0)     ||')'
                     ||' Period('||NVL(parm_gl_period_num,0)      ||')'
                  ||' Fund Code('||NVL(parm_treasury_value_r1,'Null')
                             ||')');
  END IF;


--
-- ----------------------------------------
-- Initialize Program Row Counts and Variables
-- ----------------------------------------
  g_insert_count     := 0;
  g_error_code       := 0;
  g_error_message    := NULL;
  retcode := 0;
  errbuf := '';
  --
  IF g_error_code = 0 THEN
-- ------------------------------------
-- Delete All Entries from Report Temp Table
-- ------------------------------------
    purge_temp_table;
    END IF;

IF g_error_code = 0 THEN
-- ----------------------------------------
-- Build Report Lines
-- ----------------------------------------
sf133_runmode := 'YES';

 /* Processing for Treasury symbols done in a LOOP to handle Multiple Treasury symbols */
FOR ts_rec IN ts_range_cursor(treasury_symbol_r1,treasury_symbol_r2)
  LOOP
      -- New code added by Narsimha Balakkari to get the established year and
      -- cancellation year for specific treasury symbol
      parm_treasury_value_r1 := ts_rec.treasury_symbol;
      parm_treasury_symbol_id := ts_rec.treasury_symbol_id;
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'parm_treasury_value_r1.......'||  parm_treasury_value_r1);

      --populate_gtt_with_ccid (parm_treasury_symbol_id);

      SELECT established_fiscal_yr, substr(cancellation_date,8,4)
      INTO g_established_year, g_cancellation_year
      FROM fv_treasury_symbols
      WHERE treasury_symbol = parm_treasury_value_r1
      AND   set_of_books_id = parm_set_of_books_id ;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'PROCESSING FOR TREASURY SYMBOL .......'||  PARM_TREASURY_VALUE_R1);
      END IF;

       --Fetch the Federal Acct Symbol Id for the TS

        SELECT federal_acct_symbol_id
        INTO   g_federal_acct_symbol_id
        FROM   fv_treasury_symbols
        WHERE  set_of_books_id = parm_set_of_books_id
        AND    treasury_symbol_id = parm_treasury_symbol_id;
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'g_federal_acct_symbol_id.......'||  g_federal_acct_symbol_id);

        -- SF133: check if the treasury symbols for the previous 5 years pass factsii edit checks

        L_LOOP_YEAR := g_established_year ;

        SELECT   PERIOD_NUM
        INTO     parm_gl_period_num
        FROM GL_PERIOD_STATUSES
        WHERE    LEDGER_ID    = parm_set_of_books_id AND
        PERIOD_YEAR           = parm_gl_period_year  AND
        APPLICATION_ID        = '101' AND
        CLOSING_STATUS in ('O','C') AND
        PERIOD_NAME           = parm_gl_period_name;

         For l_year_counter IN 1..6 Loop --run FACTS for current year + previous 5 years' treasury symbols
          -- Determine the Previous Year
          L_PROCESS_YEAR := PARM_GL_PERIOD_YEAR ;

        --Fetch the Treasury symbol for previous year
        begin
            select treasury_symbol,treasury_symbol_id
            into   c_sf133_ts_value,g_treasury_symbol_id
            from   fv_treasury_symbols
            WHERE  set_of_books_id = parm_set_of_books_id
            and    federal_acct_symbol_id = g_federal_acct_symbol_id
            and    established_fiscal_yr = l_loop_year
            and    time_frame = 'SINGLE';

        exception
            when no_data_found then
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,SQLERRM);
            exit;
        end;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TREASURY SYMBOL IS '||C_SF133_TS_VALUE );
          --FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'L_BEG_PERIOD_PREV IS '||L_BEG_PERIOD_PREV );
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'L_LOOP_YEAR IS '||l_loop_year );
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PARM_GL_PERIOD_NUM IS '||parm_gl_period_num );
        END IF;


       FV_FACTS_TRANSACTIONS.main(errbuf_facts, retcode_facts, parm_set_of_books_id, c_sf133_ts_value, L_PROCESS_YEAR, parm_gl_period_num, run_mode_fact, contact_fname,
        contact_lname, contact_phone, contact_extn, contact_email, contact_fax,
        contact_maiden, supervisor_name, supervisor_phone, supervisor_extn,  agency_name_1,
        agency_name_2, address_1, address_2, city,  state, zip, g_currency_code);

        IF(retcode_facts <> 0 )then
               IF(retcode_facts = 1 )then
                   if (FV_FACTS_TRANSACTIONS.v_g_edit_check_code = 2)then
                      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'Required Edits failed for the Treasury Symbol...'|| PARM_TREASURY_VALUE_R1||errbuf_facts);
                        retcode :=1;
                   END IF;
               END IF;
       END IF;

       exit when FV_FACTS_TRANSACTIONS.v_g_edit_check_code = 2; --hardedit check failed
        L_LOOP_YEAR := L_LOOP_YEAR - 1;
       end loop;

     if( FV_FACTS_TRANSACTIONS.v_g_edit_check_code <> 2 ) then -- hard edit did not fail for all 6 years' treasury symbols
        build_report_lines;
        IF g_error_code <> 0 THEN
          errbuf := errbuf || 'Processing for Treasury Symbol .......'|| parm_treasury_value_r1 || 'FAILED'|| g_error_message;
        ELSE
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SUBMITTING SF133 REPORT FOR TREASURY SYMBOL......' || PARM_TREASURY_VALUE_R1);
          END IF;
          l_req_id := FND_REQUEST.SUBMIT_REQUEST('FV','FVXBEGLP','','',FALSE,parm_set_of_books_id,--g_chart_of_accounts_id,
          parm_gl_period_year,parm_gl_period_name,parm_treasury_value_r1);
          IF l_req_id = 0 THEN
            errbuf :=   'Error submitting SF133 Report for Treasury Symbol'|| parm_treasury_value_r1 ;
            retcode := -1;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1', errbuf) ;
            return;
          ELSE
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CONCURRENT REQUEST ID FOR SF133 REPORT - ' || L_REQ_ID);
            END IF;
          END IF;
        END IF;
        -- Committing here to avoid deleting the temporary table
        COMMIT;
    end if; --sf133; end for  if( FV_FACTS_TRANSACTIONS.v_g_edit_check_code <> 2 )
END LOOP;

if ts_range_cursor%ISOPEN then
close ts_range_cursor;
end if;

END IF;

IF g_error_code <> 0 THEN
    RAISE abort_error;
END IF;
--

IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'-- INSERT COUNT('||G_INSERT_COUNT||')');
END IF;
IF errbuf IS NOT null THEN
    errbuf := 'Normal End of FVSF133 package';
END IF;
IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,ERRBUF);
END IF;
-- ------------------------------------
-- Exceptions
-- ------------------------------------
 sf133_runmode := 'NO';

EXCEPTION
--
  WHEN abort_error THEN
   retcode := g_error_code;
   errbuf := g_error_message;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception1', errbuf) ;
   WHEN OTHERS THEN
     g_error_code    := SQLCODE;
     g_error_message := SQLERRM;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', g_error_message) ;
     RAISE_APPLICATION_ERROR(-20222,'FVSF133 Exception-'||SQLERRM);
END Main;
-- ------------------------------------------------------------------
-- --------------------------------------------------------
PROCEDURE determine_acct_flex_segments
--
AS
  l_module_name VARCHAR2(200);

   -- for data access security
   das_id              NUMBER;
   das_where           VARCHAR2(600);
--
BEGIN
   l_module_name  := g_module_name || 'determine_acct_flex_segments';
--
  IF parm_run_mode = 'T' THEN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'START DETERMINE_ACCT_FLEX_SEGMENTS');
    END IF;
  END IF;
--
-- -------------------------------------
-- Store SoB's Chart of Accounts Id
-- -------------------------------------
  SELECT chart_of_accounts_id
    INTO g_chart_of_accounts_id
    FROM gl_ledgers_public_v
   WHERE ledger_id = parm_set_of_books_id;
--
/* SELECT statement brought OUT NOCOPY of the LOOP as it does nto use any of the loop variables  */
-- find the balance segment (fund) application_column_name
    SELECT application_column_name
          INTO v_balance_column_name
          FROM fnd_segment_attribute_values
         WHERE application_id = 101
           AND id_flex_code = 'GL#'
           AND id_flex_num  = g_chart_of_accounts_id
           AND segment_attribute_type = 'GL_BALANCING'
           AND attribute_value = 'Y';

/* Used dynamic SQL instead of balance_cursor to improve performance  */
v_select := 'SELECT decode(:cv_balance_type, ' ||
                ''''|| 'B' || '''' || ',' || '
        ROUND(NVL(SUM(NVL(glbal.begin_balance_dr,0) -
                     NVL(glbal.begin_balance_cr,0)
                     ),0),2),' ||
                ''''|| 'E' || '''' || ',' || '
        ROUND(NVL(SUM((NVL(glbal.begin_balance_dr,0) -
                      NVL(glbal.begin_balance_cr,0))
              +      (NVL(glbal.period_net_dr,0) -
                      NVL(glbal.period_net_cr,0))),0),2),'||
                ''''|| 'P' || '''' || ',' || '
        DECODE(SIGN(ROUND(NVL(SUM((NVL(glbal.period_net_dr,0)-NVL(glbal.period_net_cr,0))
	+
                       (NVL(glbal.begin_balance_dr,0)-NVL(glbal.begin_balance_cr,0))),0),2)),-1,0,
		    ROUND(NVL(SUM((NVL(glbal.period_net_dr,0)-NVL(glbal.period_net_cr,0))
        +
                       (NVL(glbal.begin_balance_dr,0)-NVL(glbal.begin_balance_cr,0))),0),2)),'||
                      ''''|| 'N' || '''' || ',' || '
         DECODE(SIGN(ROUND(NVL(SUM((NVL(glbal.period_net_dr,0)-NVL(glbal.period_net_cr,0))
	+
                       (NVL(glbal.begin_balance_dr,0)-NVL(glbal.begin_balance_cr,0))),0),2)),1,0,
		    ROUND(NVL(SUM((NVL(glbal.period_net_dr,0)-NVL(glbal.period_net_cr,0))
        +
                       (NVL(glbal.begin_balance_dr,0)-NVL(glbal.begin_balance_cr,0))),0),2))) ' ||  '
        FROM gl_balances glbal,
              fv_sf133_definitions_accts acct,
              fv_sf133_ccids_gt fscg
            WHERE glbal.ledger_id =  :cv_set_of_books_id
        AND glbal.period_year = :cv_fiscal_year
         AND glbal.period_num = :cv_period
         AND glbal.currency_code = :cv_currency_code
         AND glbal.actual_flag          = '||''''||'A'||''''||'
         AND glbal.code_combination_id = fscg.ccid
          AND acct.sf133_line_id = :cv_sf133_line_id
         AND acct.sf133_line_acct_id = :cv_sf133_line_acct_id
         AND fscg.sf133_line_acct_id = acct.sf133_line_acct_id';

  -- Data Access Security:
  das_id := fnd_profile.value('GL_ACCESS_SET_ID');
  das_where := gl_access_set_security_pkg.get_security_clause
                 (das_id, gl_access_set_security_pkg.READ_ONLY_ACCESS,
                  gl_access_set_security_pkg.CHECK_LEDGER_ID,
                  to_char(parm_set_of_books_id), null,
                  gl_access_set_security_pkg.CHECK_SEGVALS,
                  null, 'glcc', null);
  IF (das_where IS NOT NULL) THEN
    v_select := v_select || '
     AND ' || das_where;
  END IF;


/*
-- -------------------------------------
-- Store Flex Segment Names in Table
-- -------------------------------------
  FOR flex_field_column_name_entry IN flex_field_column_name_cursor LOOP
    EXIT WHEN flex_field_column_name_cursor%NOTFOUND;
    c_segment_name     := flex_field_column_name_entry.segment_name;
    c_flex_column_name := flex_field_column_name_entry.flex_column_name;
--
--    t_segment_number   := TO_NUMBER(SUBSTR(c_flex_column_name,08,02));
  --   t_segment_name(t_segment_number) := c_flex_column_name;
--
    	BEGIN
		SELECT  flex_value_set_id
  	        	INTO  g_seg_value_set_id
   	            FROM  fnd_id_flex_segments
    	            WHERE application_column_name = c_flex_column_name
    	            AND   application_id = 101
     	            AND   id_flex_code = 'GL#'
                    AND   id_flex_num = g_chart_of_accounts_id;
	EXCEPTION
		WHEN OTHERS THEN
			FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'Error in getting the Value set attched ' ||
											 ' to the  segemnt => ' || c_flex_column_name);
			FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,' SQLCODE => ' || SQLCODE ||
																   ' SQLERRM => ' || SQLERRM);
 			RAISE;
	END;
   -- + Rollup for the amount is the segment is a parent segment +
    	v_select := v_select || '
    			AND ( NVL(glcc.'|| c_flex_column_name ||
                    	 ',' || '''' || '-1' || '''' || ') = ' || 'NVL(acct.' || c_flex_column_name
                 		 ||',NVL(glcc.'||c_flex_column_name ||
            			 ','||''''||'-1'||''''||')) ' || '
            			  OR glcc.'||c_flex_column_name ||' IN (SELECT flex_value '||
                     				'FROM fnd_flex_values ffv, fnd_flex_value_hierarchies ffvh '||
                     				'WHERE ffv.flex_value BETWEEN  ffvh.child_flex_value_low
                                         AND  ffvh.child_flex_value_high
                        			AND ffv.flex_value_set_id = ' ||  g_seg_value_set_id  ||
                        			' AND ffv.flex_value_set_id = ffvh.flex_value_set_id'||
                        			' AND parent_flex_value = acct.' || c_flex_column_name  || '))';

   -- + commented the below code to roll up the amount for all segments +
      	v_select := v_select || '
    			AND NVL(glcc.'|| c_flex_column_name ||
                    	 ',' || '''' || '-1' || '''' || ') = ' || 'NVL(acct.' || c_flex_column_name
                 		 ||',NVL(glcc.'||c_flex_column_name ||
            			 ','||''''||'-1'||''''||'))';

    IF c_flex_column_name =  v_balance_column_name THEN
      -- the segment application_column_name being processed = the balancing
      -- segment application_column_name.
      g_fund_segment_name := c_flex_column_name;
    END IF;
--
  END LOOP;
*/

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,V_SELECT);
  END IF;
--
 v_cursor_id := DBMS_SQL.OPEN_CURSOR();
 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'T1');
 END IF;

 fnd_file.put_line (fnd_file.log, v_select);

 dbms_sql.parse(v_cursor_id,v_select,dbms_sql.v7);

 dbms_sql.bind_variable(v_cursor_id,':cv_set_of_books_id',parm_set_of_books_id);
-- dbms_sql.bind_variable(v_cursor_id,':cv_chart_of_accounts_id',g_chart_of_accounts_id);
 dbms_sql.bind_variable(v_cursor_id,':cv_currency_code',g_currency_code);

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'T2');
  END IF;
 dbms_sql.define_column(v_cursor_id,1,c_total_balance);
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'T3');
  END IF;


--
-- ------------------------------------
-- Exceptions
-- ------------------------------------
EXCEPTION
--
  WHEN OTHERS THEN
    g_error_code    := SQLCODE;
    g_error_message := 'determine_acct_flex_segments/'||SQLERRM;
    IF flex_field_column_name_cursor%ISOPEN THEN
       close flex_field_column_name_cursor;
    END IF;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', g_error_message) ;
--
END determine_acct_flex_segments;
-- --------------------------------------------------------
-- --------------------------------------------------------
PROCEDURE purge_temp_table
--
IS
  l_module_name VARCHAR2(200);
--
BEGIN
   l_module_name := g_module_name || 'purge_temp_table';
--
  IF parm_run_mode = 'T' THEN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'START PURGE_TEMP_TABLE');
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  FUND SEGMENT ('||G_FUND_SEGMENT_NAME ||')');
    END IF;
  END IF;
--
  DELETE
    FROM fv_sf133_definitions_cols_temp
   WHERE (sf133_line_id)
            IN
         (SELECT sf133_line_id
            FROM fv_sf133_definitions_lines
           WHERE set_of_books_id = parm_set_of_books_id);
--
  COMMIT;
--
-- ------------------------------------
-- Exceptions
-- ------------------------------------
EXCEPTION
--
  WHEN NO_DATA_FOUND THEN
    NULL;
--
  WHEN OTHERS THEN
    g_error_code    := SQLCODE;
    g_error_message := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', g_error_message) ;
--
END purge_temp_table;
-- --------------------------------------------------------
-- --------------------------------------------------------
PROCEDURE build_report_lines
--
AS
--
  l_module_name VARCHAR2(200) ;
    -- New Variables added by Surya on 04/07/98
   -- l_year_counter  Number ;  --  FOR loop counter
  --  l_process_year  Number ;  --  Process Year for Previous Years
  --  L_BEG_PERIOD_PREV NUMBER ;  --  Beginning Period-Previous Year
  --  L_END_PERIOD_PREV NUMBER ;  --  Ending  period-previous year
  --  L_LOOP_YEAR   NUMBER;
  --  l_federal_acct_symbol_id  number(15);
    l_sf133_ts_value    fv_sf133_definitions_cols_temp.sf133_fund_value%TYPE;
    l_line_cnt number;
-- ---------------------------------------------------------
BEGIN
   l_module_name := g_module_name || 'build_report_lines';
--
  IF parm_run_mode = 'T' THEN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'START BUILD_REPORT_LINES');
    END IF;
  END IF;
--
-- ----------------------------------------------------------
-- Find period_number that is not an adjusting period
-- ----------------------------------------------------------
--
--
  SELECT min(period_num)
    INTO g_period_num
    FROM gl_period_statuses
    WHERE ledger_id        = parm_set_of_books_id
    AND adjustment_period_flag = 'N'
    AND period_year            = parm_gl_period_year
    AND application_id         = '101' ;


--  Added on 5/6/98 by Surya Padmanabhan to get the Period Number For
--  the Quarter.
   SELECT   PERIOD_NUM
   INTO     parm_gl_period_num
   FROM GL_PERIOD_STATUSES
   WHERE    LEDGER_ID     = parm_set_of_books_id AND
        PERIOD_YEAR     = parm_gl_period_year  AND
        APPLICATION_ID  = '101' AND
        CLOSING_STATUS in ('O','C') AND
        PERIOD_NAME = parm_gl_period_name;
-- for bug  2642032
-- AND adjustment_period_flag = 'N' ;

-- ----------------------------------------------------
-- Get Next SF133 Treasury Symbol Line from Cursor
-- ----------------------------------------------------
--
  g_ts_value_in_process   := NULL;
--
  FOR ts_report_line_entry IN ts_report_line_cursor LOOP
--
        if v_debug then
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'LG 3 INSIDE LOOP ') ;
          END IF;
        end if;

    c_sf133_ts_value       := ts_report_line_entry.sf133_ts_value;
    c_sf133_line_id        := ts_report_line_entry.sf133_line_id;
    c_sf133_line_number    := ts_report_line_entry.sf133_line_number;
    c_sf133_line_type_code := ts_report_line_entry.sf133_line_type_code;
    c_sf133_natural_bal_type
            := ts_report_line_entry.sf133_natural_balance_type;
    c_sf133_line_category  := ts_report_line_entry.sf133_line_category;
    c_sf133_report_line_number
             := ts_report_line_entry.sf133_report_line_number;
    c_sf133_treasury_symbol_id := ts_report_line_entry.sf133_treasury_symbol_id; --Bug 1575992

    g_column_number := 1;

    IF g_error_code = 0 THEN
      IF (c_sf133_line_type_code = 'D' or c_sf133_line_type_code = 'D2') THEN
            g_column_number := 1;

        /***********    Modifications Start  *****************/

          -- Get the Beginning and Ending Periods
       L_PROCESS_YEAR := parm_gl_period_year;
       IF g_established_year = parm_gl_period_year THEN
        L_BEG_PERIOD_PREV := g_period_num;
        L_END_PERIOD_PREV := parm_gl_period_num;
       ELSE
        GET_BEGIN_ENDING_PERIODS
          (L_PROCESS_YEAR, L_BEG_PERIOD_PREV, L_END_PERIOD_PREV) ;
       END IF;

        -- Get the amount for the First Column.(Passed Quarter)
      build_fiscal_line_columns(L_BEG_PERIOD_PREV, L_END_PERIOD_PREV, L_PROCESS_YEAR) ;

        -- Call Insert Procedure to insert the derived amount values
        -- for the first column.
        populate_temp_table;
        -- Loop to Calculate amounts for next 5 years from established year
        --LGOEL: Fix for bug 1470537 decrement the loop year

        --L_LOOP_YEAR := g_established_year + 1;
        L_LOOP_YEAR := g_established_year - 1;

        l_sf133_ts_value := c_sf133_ts_value;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FEDERAL ACCT SYMBOL ID IS'|| TO_CHAR(L_FEDERAL_ACCT_SYMBOL_ID)) ;
        END IF;

        For l_year_counter IN 1..5 Loop

          -- Determine the Previous Year

               -- replaced L_PROCESS_YEAR := PARM_GL_PERIOD_YEAR -
               -- l_year_counter statement
            -- with L_PROCESS_YEAR := L_LOOP_YEAR by Narsimha Balakkari ;

        /*1584188 :pkpatel - Do not decrement the Process Year */

        --  L_PROCESS_YEAR := L_LOOP_YEAR ;
          L_PROCESS_YEAR := PARM_GL_PERIOD_YEAR ;

          -- Get the Beginning and Ending Periods
          /*GET_BEGIN_ENDING_PERIODS
          (L_PROCESS_YEAR, L_BEG_PERIOD_PREV, L_END_PERIOD_PREV) ;*/

        IF L_PROCESS_YEAR = parm_gl_period_year THEN
            L_BEG_PERIOD_PREV := g_period_num;
            L_END_PERIOD_PREV := parm_gl_period_num;
        END IF;

        --LGOEL: Fetch the Treasury symbol for previous year
                -- added  check for established fiscal year  - 1584188
                -- added time frame condition    - 1633861
        begin
          select treasury_symbol,treasury_symbol_id
          into   c_sf133_ts_value,g_treasury_symbol_id
          from   fv_treasury_symbols
          WHERE  set_of_books_id = parm_set_of_books_id
          and    federal_acct_symbol_id = g_federal_acct_symbol_id
          and    established_fiscal_yr = l_loop_year
          and    time_frame = 'SINGLE';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TREASURY SYMBOL IS '||C_SF133_TS_VALUE );
        END IF;

         c_sf133_treasury_symbol_id := g_treasury_symbol_id;
--        dbms_sql.bind_variable(v_cursor_id,':cv_treasury_symbol_id',
--                                 g_treasury_symbol_id);
          -- Derive the Amount Values for the Previous Year
          build_fiscal_line_columns
          (L_BEG_PERIOD_PREV, L_END_PERIOD_PREV, L_PROCESS_YEAR) ;

        exception when no_data_found then
          o_sf133_column_amount := 0;
          o_sf133_amt_not_shown := 0;
        end;

        --LGOEL: Restore the treasury symbol variable value
        c_sf133_ts_value := l_sf133_ts_value;


IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PROCESS YEAR - ' || TO_CHAR(L_PROCESS_YEAR) ||
               'Beginning Period - ' || to_char(l_beg_period_prev) ||
               'Ending Period    - ' || to_char(l_end_period_prev)) ;
END IF;

          -- Update the Current Row with derived values.

          -- Since Decode cannot be used in the left side of the
          -- assignment after SET phrase, a litle round about way
          -- is used by using Decode on the right side. Still one
          -- SQL statement !!

IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'LOOP COUNTER ' || TO_CHAR(L_YEAR_COUNTER) || ' AMOUNT VALUE ' || TO_CHAR(O_SF133_COLUMN_AMOUNT)) ;
END IF;
          UPDATE FV_SF133_DEFINITIONS_COLS_TEMP
          SET
          SF133_COLUMN_2_AMOUNT = DECODE(L_YEAR_COUNTER, 1,
                O_SF133_COLUMN_AMOUNT, SF133_COLUMN_2_AMOUNT),
          SF133_COLUMN_3_AMOUNT = DECODE(L_YEAR_COUNTER, 2,
                O_SF133_COLUMN_AMOUNT, SF133_COLUMN_3_AMOUNT),
          SF133_COLUMN_4_AMOUNT = DECODE(L_YEAR_COUNTER, 3,
                O_SF133_COLUMN_AMOUNT, SF133_COLUMN_4_AMOUNT),
          SF133_COLUMN_5_AMOUNT = DECODE(L_YEAR_COUNTER, 4,
                O_SF133_COLUMN_AMOUNT, SF133_COLUMN_5_AMOUNT),
          SF133_COLUMN_6_AMOUNT = DECODE(L_YEAR_COUNTER, 5,
                O_SF133_COLUMN_AMOUNT, SF133_COLUMN_6_AMOUNT),

          SF133_AMT_2_NOT_SHOWN = DECODE(L_YEAR_COUNTER, 1,
                O_SF133_AMT_NOT_SHOWN, SF133_AMT_2_NOT_SHOWN),
          SF133_AMT_3_NOT_SHOWN = DECODE(L_YEAR_COUNTER, 2,
                O_SF133_AMT_NOT_SHOWN, SF133_AMT_3_NOT_SHOWN),
          SF133_AMT_4_NOT_SHOWN = DECODE(L_YEAR_COUNTER, 3,
                O_SF133_AMT_NOT_SHOWN, SF133_AMT_4_NOT_SHOWN),
          SF133_AMT_5_NOT_SHOWN = DECODE(L_YEAR_COUNTER, 4,
                O_SF133_AMT_NOT_SHOWN, SF133_AMT_5_NOT_SHOWN),
          SF133_AMT_6_NOT_SHOWN = DECODE(L_YEAR_COUNTER, 5,
                O_SF133_AMT_NOT_SHOWN, SF133_AMT_6_NOT_SHOWN)

          WHERE
            SF133_FUND_VALUE    = L_SF133_TS_VALUE  AND
            SF133_LINE_ID       = O_SF133_LINE_ID        ;

        L_LOOP_YEAR := L_LOOP_YEAR - 1;

        End Loop ;

        -- Update the Current Row with the total.
        UPDATE FV_SF133_DEFINITIONS_COLS_TEMP
        SET
            SF133_AMT_TOTAL_NOT_SHOWN =
            SF133_AMOUNT_NOT_SHOWN  + SF133_AMT_2_NOT_SHOWN +
            SF133_AMT_3_NOT_SHOWN   + SF133_AMT_4_NOT_SHOWN +
            SF133_AMT_5_NOT_SHOWN   + SF133_AMT_6_NOT_SHOWN ,

            SF133_COLUMN_TOTAL_AMT    =
            SF133_COLUMN_AMOUNT   + SF133_COLUMN_2_AMOUNT   +
            SF133_COLUMN_3_AMOUNT + SF133_COLUMN_4_AMOUNT   +
            SF133_COLUMN_5_AMOUNT + SF133_COLUMN_6_AMOUNT

          WHERE
            SF133_FUND_VALUE    = L_SF133_TS_VALUE  AND
            SF133_LINE_ID       = O_SF133_LINE_ID       ;

         ELSIF c_sf133_line_type_code = 'T' THEN
                SELECT count(*)
                INTO l_line_cnt
                FROM fv_sf133_rep_line_calc
                WHERE line_id = c_sf133_line_id;
                IF l_line_cnt = 0 THEN
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1','Total line does not contain calculations. SEED Data not properly Loaded. Please Verify and reinvoke the Process.');
                    RETURN;
                END IF;
                process_total_line;

      END IF;
--
    END IF;
--
  END LOOP;
--
-- ------------------------------------
-- Exceptions
-- ------------------------------------
EXCEPTION
--
  WHEN OTHERS THEN
    g_error_code    := SQLCODE;
    g_error_message := SQLERRM;

    IF ts_report_line_cursor%ISOPEN THEN
       close ts_report_line_cursor;
    END IF;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', g_error_message) ;
--
END build_report_lines;
-- --------------------------------------------------------
-- ----------------------------------------------
PROCEDURE build_fiscal_line_columns
(c_begin_period Number, c_end_period Number, c_fiscal_year Number)
--
IS
--
l_module_name VARCHAR2(200) ;
l_ignore INTEGER;
query_fetch_bal  VARCHAR2(8600);
where_clause VARCHAR2(8600);
financing_account_treas FV_FACTS_FEDERAL_ACCOUNTS.financing_account%TYPE;
availability_type_treas fv_sf133_definitions_accts.availability_type%TYPE;
fund_type_treas fv_treasury_symbols.fund_group_code%TYPE;

-- ----------------------------------------------
BEGIN
  l_module_name  := g_module_name || 'build_fiscal_line_columns';
--
  IF parm_run_mode = 'T' THEN

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'START BUILD_FISCAL_LINE_COLUMNS');
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'-- LINE('||C_SF133_LINE_NUMBER||')'
                        || ' Tresury Symbol('||c_sf133_ts_value ||')'
                        ||      ' '||to_char(SYSDATE,'mm/dd/yyyy hh:mi:ss'));
    END IF;
  END IF;
--
-- ----------------------------------------
-- Get Fund Accummulation
-- ----------------------------------------
  c_total_balance := 0;
  c_sf133_amount_not_shown := 0;
  c_begin_balance  := 0;
  c_ending_balance := 0;


  -- Removed the Following Statements, since the Beginning and Ending
  -- periods are passed as parameters.
  --               c_begin_period   := g_period_num;
  --               c_end_period     := parm_gl_period_num;
  --
  CSum_E :=0;
  DSum_E :=0;
  CSum_B :=0;
  CSum_B :=0;


  -- for the line find all accounts and sum
  FOR balance_type_rec in balance_type_cursor LOOP
      c_sf133_line_acct_id := balance_type_rec.sf133_line_acct_id;
      c_sf133_balance_type := balance_type_rec.sf133_balance_type;
      c_acct_number :=balance_type_rec.acct_number;
      c_direct_or_reimb_code := balance_type_rec.direct_or_reimb_code;
      c_apportionment_category_code := balance_type_rec.apportionment_category_code;
      c_category_b_code:= balance_type_rec.category_b_code;
       c_prc_code:= balance_type_rec. prc_code;
       c_advance_code:= balance_type_rec.advance_code;
       c_availability_time:= balance_type_rec.availability_time;
       c_bea_category_code:= balance_type_rec.bea_category_code;
       c_borrowing_source_code:= balance_type_rec.borrowing_source_code;
       c_transaction_partner:= balance_type_rec. transaction_partner;
       c_year_of_budget_authority:= balance_type_rec.year_of_budget_authority;
       c_prior_year_adjustment:= balance_type_rec.prior_year_adjustment;
       c_authority_type:= balance_type_rec.authority_type;
       c_tafs_status:= balance_type_rec.tafs_status;
       c_availability_type:= balance_type_rec. availability_type;
       c_expiration_flag:= balance_type_rec.expiration_flag;
       c_fund_type:= balance_type_rec.fund_type;
       c_financing_account_code:= balance_type_rec.financing_account_code;

--     New code added written by Narsimha Balakkari to solve the Rescission
--     problem.
                    c_rescission_flag := 'FALSE';
           IF upper(c_sf133_additional_info) = 'RESCISSION' THEN

        select upper(resource_type) into c_resource_type
        from fv_treasury_symbols
        where treasury_symbol = parm_treasury_value_r1
        and   set_of_books_id = parm_set_of_books_id;

        IF c_resource_type like '%APPROPRIATION%' THEN
           IF ltrim(rtrim(c_sf133_report_line_number)) = '1A' THEN
            c_rescission_flag := 'TRUE';
           ELSE
            c_rescission_flag := 'FALSE';
                   END IF;
        ELSIF c_resource_type like '%BORROWING%' THEN
           IF c_sf133_report_line_number = '1B' THEN
                        c_rescission_flag := 'TRUE';
           ELSE
                c_rescission_flag := 'FALSE';
                   END IF;
            ELSIF c_resource_type like '%CONTRACT%' THEN
                   IF c_sf133_report_line_number = '1C' THEN
            c_rescission_flag := 'TRUE';
           ELSE
            c_rescission_flag := 'FALSE';
           END IF;
        END IF;
        ELSE
            c_rescission_flag := 'TRUE';
        END IF;
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'LINE NUMBER IS  ' || C_SF133_REPORT_LINE_NUMBER);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RESOURCE TYPE IS  ' || C_RESOURCE_TYPE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RESOURCE FLAG IS  ' || C_RESCISSION_FLAG);
       END IF;
   IF c_rescission_flag = 'TRUE' THEN

   SELECT start_date,
    end_date
    INTO beg_date,
    close_date
    FROM gl_period_statuses
    WHERE period_year   = parm_gl_period_year
    AND period_num      = parm_gl_period_num
    AND application_id  = 101
    AND set_of_books_id = parm_set_of_books_id;


select decode(time_frame,'NO_YEAR','X',null) , ffg.fund_type, expiration_Date into availability_type_treas,  fund_type_treas,
 exp_date  from fv_treasury_symbols fts, fv_fund_groups ffg
 where fts.treasury_symbol_id=c_sf133_treasury_symbol_id--g_treasury_symbol_id
and fts.set_of_books_id = parm_set_of_books_id
and fts.set_of_books_id = ffg.set_of_books_id
and ffg.fund_group_code = fts.fund_group_code;

-- Extract expiration date of treasury symbol and determine if the TS expired
-- or will it expire in the year for which the process is run
-- Bug9415373.
IF(exp_date    < close_date ) THEN
  whether_Exp  := 'E';
ELSE
  whether_Exp  := 'U';
END IF;

if (exp_date is null) then
      whether_Exp  := 'U';
      whether_Exp_SameYear := 'N';
end if;

IF (exp_date is not null) then
  select extract ( year from  expiration_date)into expiring_year
  from fv_treasury_symbols where treasury_symbol_id=c_sf133_treasury_symbol_id;--g_treasury_symbol_id;
  if (expiring_year is not null and  expiring_year = parm_gl_period_year) then
    whether_Exp_SameYear := 'Y';
  elsif ( expiring_year > parm_gl_period_year) then
    whether_Exp_SameYear := 'N';
  end if;
end if;

select financing_account  into financing_account_treas from FV_FACTS_FEDERAL_ACCOUNTS fed, fv_treasury_symbols treas
where fed.federal_acct_symbol_id = treas.federal_acct_symbol_id
and treas.treasury_symbol_id=c_sf133_treasury_symbol_id--g_treasury_symbol_id
and treas.set_of_books_id = parm_set_of_books_id;

query_fetch_bal:=null;

   where_clause := ' ';
    if (c_direct_or_reimb_code is not null) then
    where_clause:= where_clause||' '||' and trim(reimburseable_flag) = '''||c_direct_or_reimb_code|| '''  ';
    end if;

   if (c_apportionment_category_code is not null) then
    where_clause:= where_clause||' '||' and trim(appor_cat_code) = '''||c_apportionment_category_code|| '''  ';
   end if;

   IF (c_category_b_code IS NOT NULL) THEN
    where_clause:= where_clause||' '||' and trim(appor_cat_b_dtl) = '''||c_category_b_code|| '''  ';
   END IF;

   IF (c_advance_code IS NOT NULL) THEN
    where_clause:= where_clause||' '||' and trim(advance_flag) = '''||c_advance_code|| '''  ';

   END IF;

   IF (c_availability_time IS NOT NULL) THEN
    where_clause:= where_clause||' '||' and trim(availability_flag) = '''||c_availability_time|| '''  ';

   END IF;

  IF (c_bea_category_code IS NOT NULL) THEN
    where_clause:= where_clause||' '||' and trim(bea_category) = '''||c_bea_category_code|| '''  ';

   END IF;

   IF (c_borrowing_source_code IS NOT NULL) THEN
    where_clause:= where_clause||' '||' and trim(borrowing_source) = '''||c_borrowing_source_code|| '''  ';

   END IF;

   IF (c_transaction_partner IS NOT NULL) THEN
    where_clause:= where_clause||' '||' and trim(fac.transaction_partner) = '''||c_transaction_partner|| '''  ';

   END IF;

   IF (c_year_of_budget_authority IS NOT NULL) THEN
    where_clause:= where_clause||' '||' and trim(year_budget_auth) = '''||c_year_of_budget_authority|| '''  ';

   END IF;

    IF (c_prior_year_adjustment IS NOT NULL) THEN
    where_clause:= where_clause||' '||' and trim(pya_flag) = '''||c_prior_year_adjustment|| '''  ';

   END IF;

   IF (c_prc_code IS NOT NULL) THEN
    where_clause:= where_clause||' '||' and trim(PROGRAM_RPT_CAT_NUM) = '''||c_prc_code|| '''  ';

   END IF;

   IF (c_authority_type IS NOT NULL) THEN
    where_clause:= where_clause||' '||' and trim(fac.authority_type) = '''||c_authority_type|| '''  ';

   END IF;

   if (c_tafs_status is not null) then
    where_clause:= where_clause||' '||'and trim(tafs_status) = '''||whether_Exp|| '''  ';

   end if;
   if (c_availability_type is not null and c_availability_type ='X' ) then
    where_clause:= where_clause||' '||'and trim(availability_type) = '''||availability_type_treas||''' ';

   end if;

   if (c_fund_type is not null ) then
    where_clause:= where_clause||' '||'and trim(fund_type) = '''||fund_type_treas||''' ';

   end if;

   if (c_financing_account_code is not null ) then
    where_clause:= where_clause||' '||'and trim(financing_account_code) = '''||financing_account_treas||''' ';

   end if;

   if (c_expiration_flag is not null ) then
    where_clause:= where_clause||' '||'and expiration_flag = '''||whether_Exp_SameYear||''' ';

   end if;

if( c_sf133_balance_type = 'B' OR c_sf133_balance_type = 'E') then

  if(( c_sf133_line_type_code = 'D' AND c_sf133_natural_bal_type ='D')
    or ( c_sf133_line_type_code = 'D2' AND c_sf133_natural_bal_type ='C'))then
    query_fetch_bal := 'select  sum(nvl(amount,0)) from fv_facts_temp fac, fv_sf133_definitions_accts   acct
      where fac.treasury_symbol_id = :cv_treasury_symbol_id
      AND acct.sf133_line_id         = :cv_sf133_line_id
      AND acct.sf133_line_acct_id    = :cv_sf133_line_acct_id
      and acct_number like fac.sgl_acct_number||''%'' and fac.sgl_acct_number is not null
      and fac.fct_int_record_category =  ''REPORTED_NEW'' and fac.fct_int_record_tYPE = ''BLK_DTL''
      AND begin_end =  '''||c_sf133_balance_type||'''';

  elsif (( c_sf133_line_type_code = 'D' AND c_sf133_natural_bal_type ='C') or
    ( c_sf133_line_type_code = 'D2' AND c_sf133_natural_bal_type ='D') )  then
      query_fetch_bal := 'select  sum(nvl(amount,0)*(-1)) from fv_facts_temp fac, fv_sf133_definitions_accts   acct
        where fac.treasury_symbol_id = :cv_treasury_symbol_id
        AND acct.sf133_line_id         = :cv_sf133_line_id
        AND acct.sf133_line_acct_id    = :cv_sf133_line_acct_id
        and acct_number like fac.sgl_acct_number||''%'' and fac.sgl_acct_number is not null
        and fac.fct_int_record_category =  ''REPORTED_NEW'' and fac.fct_int_record_tYPE = ''BLK_DTL''
        AND begin_end =  '''||c_sf133_balance_type||'''';
  end if;

  if (query_fetch_bal is not null) then

  v_cursor_id := dbms_sql.open_cursor;
  query_fetch_bal := query_fetch_bal ||' '|| where_clause;
  -- print query
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,query_fetch_bal);

  dbms_sql.parse(v_cursor_id, query_fetch_bal, dbms_sql.v7);
  dbms_sql.define_column(v_cursor_id, 1, c_total_balance);
  dbms_sql.bind_variable(v_cursor_id,':cv_sf133_line_acct_id',c_sf133_line_acct_id);
  --dbms_sql.bind_variable(v_cursor_id,':cv_treasury_symbol_id',g_treasury_symbol_id);
  dbms_sql.bind_variable(v_cursor_id,':cv_treasury_symbol_id',c_sf133_treasury_symbol_id);
  dbms_sql.bind_variable(v_cursor_id,':cv_sf133_line_id',c_sf133_line_id);

  --print bind variables
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sf133_balance_type:'||c_sf133_balance_type);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_treasury_symbol_id:'||c_sf133_treasury_symbol_id);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_sf133_line_acct_id:'||c_sf133_line_acct_id);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sf133_line_id:'||c_sf133_line_id);


  l_ignore := dbms_sql.execute_and_fetch(v_cursor_id);

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_ignore := '||l_ignore);
  END IF;

  dbms_sql.column_value(v_cursor_id, 1, c_total_balance);
  dbms_sql.close_cursor(v_cursor_id);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance:'||c_total_balance);
  end if;

  -- End the code for bal type beginning and ending

elsif c_sf133_balance_type = 'E-B' then -- balance type is end-begin

 if(( c_sf133_line_type_code = 'D' AND c_sf133_natural_bal_type ='D') or
  ( c_sf133_line_type_code = 'D2' AND c_sf133_natural_bal_type ='C') ) then

      query_fetch_bal := ' select
      SUM(DECODE (begin_end,''E'',nvl(AMOUNT,0),''B'',nvl(AMOUNT,0)*(-1)) )
      from fv_facts_temp fac, fv_sf133_definitions_accts   acct
      where fac.treasury_symbol_id = :cv_treasury_symbol_id
      AND acct.sf133_line_id         = :cv_sf133_line_id
      AND acct.sf133_line_acct_id    = :cv_sf133_line_acct_id
      and acct_number like fac.sgl_acct_number||''%'' and fac.sgl_acct_number is not null
      and fac.fct_int_record_category =  ''REPORTED_NEW'' and fac.fct_int_record_tYPE = ''BLK_DTL'' ';

  v_cursor_id := dbms_sql.open_cursor;

  query_fetch_bal := query_fetch_bal ||' '|| where_clause;

  dbms_sql.parse(v_cursor_id, query_fetch_bal, dbms_sql.v7);
  dbms_sql.define_column(v_cursor_id, 1, c_total_balance);
  dbms_sql.bind_variable(v_cursor_id,':cv_sf133_line_acct_id',c_sf133_line_acct_id);
  dbms_sql.bind_variable(v_cursor_id,':cv_treasury_symbol_id',c_sf133_treasury_symbol_id);
  dbms_sql.bind_variable(v_cursor_id,':cv_sf133_line_id',c_sf133_line_id);
  -- print query
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,query_fetch_bal);

  --print bind variables
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sf133_balance_type:'||c_sf133_balance_type);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_treasury_symbol_id:'||c_sf133_treasury_symbol_id);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_sf133_line_acct_id:'||c_sf133_line_acct_id);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sf133_line_id:'||c_sf133_line_id);

  l_ignore := dbms_sql.execute_and_fetch(v_cursor_id);

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_ignore := '||l_ignore);
  END IF;

  dbms_sql.column_value(v_cursor_id, 1, c_total_balance);
  dbms_sql.close_cursor(v_cursor_id);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance:'||c_total_balance);

  elsif (( c_sf133_line_type_code = 'D' AND c_sf133_natural_bal_type ='C') or
    ( c_sf133_line_type_code = 'D2' AND c_sf133_natural_bal_type ='D'))then

  query_fetch_bal := ' select
      SUM(DECODE (begin_end,''E'',nvl(AMOUNT,0),''B'',nvl(AMOUNT,0)*(-1)) )*(-1)
      from fv_facts_temp fac, fv_sf133_definitions_accts   acct
      where fac.treasury_symbol_id = :cv_treasury_symbol_id
      AND acct.sf133_line_id         = :cv_sf133_line_id
      AND acct.sf133_line_acct_id    = :cv_sf133_line_acct_id
      and acct_number like fac.sgl_acct_number||''%'' and fac.sgl_acct_number is not null
      and fac.fct_int_record_category =  ''REPORTED_NEW'' and fac.fct_int_record_tYPE = ''BLK_DTL'' ';

     v_cursor_id := dbms_sql.open_cursor;
     query_fetch_bal := query_fetch_bal ||' '|| where_clause;

    dbms_sql.parse(v_cursor_id, query_fetch_bal, dbms_sql.v7);
    dbms_sql.define_column(v_cursor_id, 1, c_total_balance);
    dbms_sql.bind_variable(v_cursor_id,':cv_sf133_line_acct_id',c_sf133_line_acct_id);
    dbms_sql.bind_variable(v_cursor_id,':cv_treasury_symbol_id',c_sf133_treasury_symbol_id);
    dbms_sql.bind_variable(v_cursor_id,':cv_sf133_line_id',c_sf133_line_id);
    -- print query
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,query_fetch_bal);

    --print bind variables
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sf133_balance_type:'||c_sf133_balance_type);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_treasury_symbol_id:'||c_sf133_treasury_symbol_id);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_sf133_line_acct_id:'||c_sf133_line_acct_id);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sf133_line_id:'||c_sf133_line_id);

    l_ignore := dbms_sql.execute_and_fetch(v_cursor_id);

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_ignore := '||l_ignore);
    END IF;

    dbms_sql.column_value(v_cursor_id, 1, c_total_balance);
    dbms_sql.close_cursor(v_cursor_id);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance:'||c_total_balance);
 END IF;

elsif (( c_sf133_balance_type= 'ED')  or( c_sf133_balance_type= 'EC')) then -- bal type is ending debit or ending credit only

 query_fetch_bal := 'select  sum(nvl(amount,0)) from fv_facts_temp fac, fv_sf133_definitions_accts   acct
    where fac.treasury_symbol_id = :cv_treasury_symbol_id
    AND acct.sf133_line_id         = :cv_sf133_line_id
    AND acct.sf133_line_acct_id    = :cv_sf133_line_acct_id
    and acct_number like fac.sgl_acct_number||''%'' and fac.sgl_acct_number is not null
    and fac.fct_int_record_category =  ''REPORTED_NEW'' and fac.fct_int_record_tYPE = ''BLK_DTL''
    AND begin_end = ''E''';

    if (query_fetch_bal is not null) then
       v_cursor_id := dbms_sql.open_cursor;
       query_fetch_bal := query_fetch_bal ||' '|| where_clause;

        dbms_sql.parse(v_cursor_id, query_fetch_bal, dbms_sql.v7);
        dbms_sql.define_column(v_cursor_id, 1, c_total_balance);
        dbms_sql.bind_variable(v_cursor_id,':cv_sf133_line_acct_id',c_sf133_line_acct_id);
        dbms_sql.bind_variable(v_cursor_id,':cv_treasury_symbol_id',c_sf133_treasury_symbol_id);
        dbms_sql.bind_variable(v_cursor_id,':cv_sf133_line_id',c_sf133_line_id);

        -- print query
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,query_fetch_bal);
         --print bind variables
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sf133_balance_type:'||c_sf133_balance_type);
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'parm_tsymbol_id:'||c_sf133_treasury_symbol_id);
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_sf133_line_acct_id:'||c_sf133_line_acct_id);
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sf133_line_id:'||c_sf133_line_id);

        l_ignore := dbms_sql.execute_and_fetch(v_cursor_id);

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_ignore := '||l_ignore);
        END IF;

        dbms_sql.column_value(v_cursor_id, 1, c_total_balance);
        dbms_sql.close_cursor(v_cursor_id);
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance:'||c_total_balance);

        if ( c_sf133_balance_type = 'ED')then
          if (c_total_balance < 0) then
            c_total_balance := 0;
          end if;
        elsif ( c_sf133_balance_type = 'EC')then
          if (c_total_balance > 0) then
            c_total_balance := 0;
          end if;
        end if;
        if(( c_sf133_line_type_code = 'D' AND c_sf133_natural_bal_type ='D') or
          ( c_sf133_line_type_code = 'D2' AND c_sf133_natural_bal_type ='C'))then
            c_total_balance := c_total_balance;
        end if;

        if (( c_sf133_line_type_code = 'D' AND c_sf133_natural_bal_type ='C') or
          ( c_sf133_line_type_code = 'D2' AND c_sf133_natural_bal_type ='D'))  then
            c_total_balance := c_total_balance*(-1);
        end if;

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance after modification:'||c_total_balance);
  end if;

elsif( (c_sf133_balance_type= 'E-BD') or (c_sf133_balance_type='E-BC')) then -- bal type is end begin debit only

      query_fetch_bal := ' select
      SUM(DECODE (begin_end,''E'',nvl(AMOUNT,0),''B'',nvl(AMOUNT,0)*(-1)) )
      from fv_facts_temp fac, fv_sf133_definitions_accts   acct
      where fac.treasury_symbol_id = :cv_treasury_symbol_id
      AND acct.sf133_line_id         = :cv_sf133_line_id
      AND acct.sf133_line_acct_id    = :cv_sf133_line_acct_id
      and acct_number like fac.sgl_acct_number||''%'' and fac.sgl_acct_number is not null
      and fac.fct_int_record_category =  ''REPORTED_NEW'' and fac.fct_int_record_tYPE = ''BLK_DTL'' ';

   v_cursor_id := dbms_sql.open_cursor;

  query_fetch_bal := query_fetch_bal ||' '|| where_clause;

  dbms_sql.parse(v_cursor_id, query_fetch_bal, dbms_sql.v7);
  dbms_sql.define_column(v_cursor_id, 1, c_total_balance);
  dbms_sql.bind_variable(v_cursor_id,':cv_sf133_line_acct_id',c_sf133_line_acct_id);
  dbms_sql.bind_variable(v_cursor_id,':cv_treasury_symbol_id',c_sf133_treasury_symbol_id);
  dbms_sql.bind_variable(v_cursor_id,':cv_sf133_line_id',c_sf133_line_id);
  -- print query
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,query_fetch_bal);

  --print bind variables
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sf133_balance_type:'||c_sf133_balance_type);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_treasury_symbol_id:'||c_sf133_treasury_symbol_id);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_sf133_line_acct_id:'||c_sf133_line_acct_id);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sf133_line_id:'||c_sf133_line_id);

  l_ignore := dbms_sql.execute_and_fetch(v_cursor_id);

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_ignore := '||l_ignore);
  END IF;

  dbms_sql.column_value(v_cursor_id, 1, c_total_balance);
  dbms_sql.close_cursor(v_cursor_id);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance:'||c_total_balance);

if (c_sf133_balance_type= 'E-BD') then
 if (c_total_balance > 0) then
     if(( c_sf133_line_type_code = 'D' AND c_sf133_natural_bal_type ='D') or
      ( c_sf133_line_type_code = 'D2' AND c_sf133_natural_bal_type ='C') ) then
        c_total_balance :=c_total_balance;
     end if;

      if(( c_sf133_line_type_code = 'D' AND c_sf133_natural_bal_type ='C') or
      ( c_sf133_line_type_code = 'D2' AND c_sf133_natural_bal_type ='D') ) then
          c_total_balance :=c_total_balance*-1;
      end if;
  else
    c_total_balance :=0; -- consider the balance only if E-B is positive
  end if;
end if; -- end for if (c_sf133_balance_type= 'E-BD') then


if (c_sf133_balance_type= 'E-BC') then
 if (c_total_balance < 0) then
     if(( c_sf133_line_type_code = 'D' AND c_sf133_natural_bal_type ='D') or
      ( c_sf133_line_type_code = 'D2' AND c_sf133_natural_bal_type ='C') ) then
        c_total_balance :=c_total_balance;
     end if;

      if(( c_sf133_line_type_code = 'D' AND c_sf133_natural_bal_type ='C') or
      ( c_sf133_line_type_code = 'D2' AND c_sf133_natural_bal_type ='D') ) then
          c_total_balance :=c_total_balance*-1;
      end if;
  else
    c_total_balance :=0; -- consider the balance only if E-B is negative
  end if;
end if;

END IF; -- end checking for balance types
end if; -- end for if rescission condition

 -- sum the line amount
if (c_total_balance is null) then
  c_total_balance :=0;
end if;
-- sum the line amount
c_sf133_amount_not_shown := c_sf133_amount_not_shown + c_total_balance;
--    fv_utility.debug_mesg('amt not shown = '||c_sf133_amount_not_shown);

 END LOOP;
--
-- set up correct display sign
--
-- fv_utility.debug_mesg('natural bal type = '||c_sf133_natural_bal_type);

--
    o_sf133_ts_value      := c_sf133_ts_value;
    o_sf133_line_id       := c_sf133_line_id;
    o_sf133_column_number := g_column_number;
    o_sf133_column_amount := c_sf133_amount_not_shown;
    o_sf133_amt_not_shown := c_sf133_amount_not_shown;
    o_sf133_treasury_symbol_id := c_sf133_treasury_symbol_id; --Bug 1575992

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'COL AMT ='||O_SF133_COLUMN_AMOUNT);
    END IF;
--
-- ------------------------------------
-- Exceptions
-- ------------------------------------
EXCEPTION
--
--
  WHEN OTHERS THEN

    g_error_code    := SQLCODE;
    g_error_message := SQLERRM;

    IF balance_type_cursor%ISOPEN THEN
       close balance_type_cursor;
/*    ELSIF balance_cursor%ISOPEN THEN
       close balance_cursor;*/
    END IF;

    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', g_error_message) ;
--
END build_fiscal_line_columns;
-- ----------------------------------------------
-- ----------------------------------------------
PROCEDURE build_total_line_columns
--
IS
  l_module_name VARCHAR2(200) ;
  -- Variables added by Surya to accomodate Previous Year Column totals

    c_sf133_amt2_not_shown      Number ;
    c_sf133_amt3_not_shown      Number ;
    c_sf133_amt4_not_shown      Number ;
    c_sf133_amt5_not_shown      Number ;
    c_sf133_amt6_not_shown      Number ;
    c_sf133_amt_total_not_shown Number ;


    c_sf133_column_amount2      Number ;
    c_sf133_column_amount3      Number ;
    c_sf133_column_amount4      Number ;
    c_sf133_column_amount5      Number ;
    c_sf133_column_amount6      Number ;
    c_sf133_column_amount_total Number ;

--
-- ----------------------------------------------
BEGIN
   l_module_name := g_module_name || 'build_total_line_columns';
--
  IF parm_run_mode = 'T' THEN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'START BUILD_TOTAL_LINE_COLUMNS');
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'-- LINE='||C_SF133_LINE_NUMBER
             ||' Start Total Line('||g_total_start_line_number||')'
             || ' Treasury Symbol('||c_sf133_ts_value||')');
    END IF;
  END IF;
--
-- ----------------------------------------
-- Get Treasury Symbol Accummulation for Total using column with true sign.
-- ----------------------------------------
-- Modified By Surya to get the total of Past Year Columns

    SELECT  NVL(SUM(NVL(sf133_amount_not_shown,0)),0),
        NVL(SUM(NVL(sf133_amt_2_not_shown,0)),0),
        NVL(SUM(NVL(sf133_amt_3_not_shown,0)),0),
        NVL(SUM(NVL(sf133_amt_4_not_shown,0)),0),
        NVL(SUM(NVL(sf133_amt_5_not_shown,0)),0),
        NVL(SUM(NVL(sf133_amt_6_not_shown,0)),0),
        NVL(SUM(NVL(sf133_amt_total_not_shown,0)),0)

      INTO  c_sf133_amount_not_shown,
        c_sf133_amt2_not_shown ,
        c_sf133_amt3_not_shown ,
        c_sf133_amt4_not_shown ,
        c_sf133_amt5_not_shown ,
        c_sf133_amt6_not_shown ,
        c_sf133_amt_total_not_shown

      FROM fv_sf133_definitions_cols_temp
     WHERE sf133_column_number = g_column_number
       AND sf133_fund_value    = c_sf133_ts_value
       AND (sf133_line_id)
              IN
           (SELECT sf133_line_id
              FROM fv_sf133_definitions_lines
             WHERE set_of_books_id   = parm_set_of_books_id
               AND sf133_line_number >
                DECODE(c_sf133_line_type_code, 'T', g_total_start_line_number, g_subtotal_start_line_number)
               AND sf133_line_number < c_sf133_line_number);


 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NATURAL BAL TYPE = '||C_SF133_NATURAL_BAL_TYPE);
 END IF;
/* IF c_sf133_natural_bal_type = 'C' THEN

    -- Credit, so display opposite
    c_sf133_column_amount       := c_sf133_amount_not_shown * -1;
    c_sf133_column_amount2      := c_sf133_amt2_not_shown * -1;
    c_sf133_column_amount3      := c_sf133_amt3_not_shown * -1;
    c_sf133_column_amount4      := c_sf133_amt4_not_shown * -1;
    c_sf133_column_amount5      := c_sf133_amt5_not_shown * -1;
    c_sf133_column_amount6      := c_sf133_amt6_not_shown * -1;
    c_sf133_column_amount_total     := c_sf133_amt_total_not_shown * -1;

 ELSIF c_sf133_natural_bal_type = 'D' THEN

    -- Debit so display as is
    c_sf133_column_amount       := c_sf133_amount_not_shown;
    c_sf133_column_amount2      := c_sf133_amt2_not_shown ;
    c_sf133_column_amount3      := c_sf133_amt3_not_shown ;
    c_sf133_column_amount4      := c_sf133_amt4_not_shown ;
    c_sf133_column_amount5      := c_sf133_amt5_not_shown ;
    c_sf133_column_amount6      := c_sf133_amt6_not_shown ;
    c_sf133_column_amount_total     := c_sf133_amt_total_not_shown ;

 ELSIF c_sf133_natural_bal_type = 'A' THEN

    -- Display the absolute value
    c_sf133_column_amount     := ABS(c_sf133_amount_not_shown);
    c_sf133_column_amount2    := ABS(c_sf133_amt2_not_shown) ;
    c_sf133_column_amount3    := ABS(c_sf133_amt3_not_shown) ;
    c_sf133_column_amount4    := ABS(c_sf133_amt4_not_shown) ;
    c_sf133_column_amount5    := ABS(c_sf133_amt5_not_shown) ;
    c_sf133_column_amount6    := ABS(c_sf133_amt6_not_shown) ;
    c_sf133_column_amount_total := ABS(c_sf133_amt_total_not_shown) ;

 ELSIF c_sf133_natural_bal_type = 'N' THEN

    -- Display as negative
    c_sf133_column_amount     := '-'||ABS(c_sf133_amount_not_shown);
    c_sf133_column_amount2    := '-'||ABS(c_sf133_amt2_not_shown) ;
    c_sf133_column_amount3    := '-'||ABS(c_sf133_amt3_not_shown) ;
    c_sf133_column_amount4    := '-'||ABS(c_sf133_amt4_not_shown) ;
    c_sf133_column_amount5    := '-'||ABS(c_sf133_amt5_not_shown) ;
    c_sf133_column_amount6    := '-'||ABS(c_sf133_amt6_not_shown) ;
    c_sf133_column_amount_total :=
                    '-'||ABS(c_sf133_amt_total_not_shown) ;

 END IF;*/

--  NOTE  ----
-- No Specific Output variables starting with 'O' are used for inserting
-- data. Original variables are used instead.
-- (Refer 'populate_temp_table' Procedure for Output variables)

--  Column amount and Column not shown has the same value in the table

-- ------------------------------------
-- Insert the Values into Report
-- ------------------------------------
    INSERT
      INTO fv_sf133_definitions_cols_temp
          ( sf133_fund_value,
        treasury_symbol_id,--Bug 1575992
            sf133_line_id,
            sf133_column_number,
            sf133_column_amount,
            sf133_amount_not_shown,
        SF133_COLUMN_2_AMOUNT ,
        SF133_AMT_2_NOT_SHOWN ,
        SF133_COLUMN_3_AMOUNT ,
        SF133_AMT_3_NOT_SHOWN ,
        SF133_COLUMN_4_AMOUNT ,
        SF133_AMT_4_NOT_SHOWN ,
        SF133_COLUMN_5_AMOUNT ,
        SF133_AMT_5_NOT_SHOWN ,
        SF133_COLUMN_6_AMOUNT ,
        SF133_AMT_6_NOT_SHOWN ,
        SF133_COLUMN_TOTAL_AMT,
        SF133_AMT_TOTAL_NOT_SHOWN )

      VALUES(
        c_sf133_ts_value,
        c_sf133_treasury_symbol_id, --Bug 1575992
        c_sf133_line_id,
        g_column_number,
        c_sf133_amount_not_shown,
        c_sf133_amount_not_shown,
        c_sf133_amt2_not_shown,
        c_sf133_amt2_not_shown,
        c_sf133_amt3_not_shown,
        c_sf133_amt3_not_shown,
        c_sf133_amt4_not_shown,
        c_sf133_amt4_not_shown,
        c_sf133_amt5_not_shown,
        c_sf133_amt5_not_shown,
        c_sf133_amt6_not_shown,
        c_sf133_amt6_not_shown,
        c_sf133_amt_total_not_shown,
        c_sf133_amt_total_not_shown);

--
  g_insert_count := g_insert_count + 1;
--

-- ------------------------------------
-- Exceptions
-- ------------------------------------
EXCEPTION
--
  WHEN OTHERS THEN
    g_error_code    := SQLCODE;
    g_error_message := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', g_error_message) ;
--
END build_total_line_columns;
-- ----------------------------------------------
-- --------------------------------------------------------
PROCEDURE populate_temp_table
--
IS
--
  l_module_name VARCHAR2(200);
-- ----------------------------------------------
BEGIN
    l_module_name := g_module_name || 'populate_temp_table';
--
    IF parm_run_mode = 'T' THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'START POPULATE_TEMP_TABLE');
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, '-- '||C_SF133_LINE_NUMBER
                           ||' ('||o_sf133_column_number||')'
                           ||' ('||o_sf133_column_amount||')'
                           ||' ('||o_sf133_amt_not_shown||')');
      END IF;
    END IF;

-- ------------------------------------
-- Insert into Line Column Table
-- ------------------------------------
    INSERT
      INTO fv_sf133_definitions_cols_temp
          (sf133_fund_value,
           treasury_symbol_id, --Bug 1575992
           sf133_line_id,
           sf133_column_number,
           sf133_column_amount,
           sf133_amount_not_shown,
           sf133_column_2_amount,
           sf133_column_3_amount,
           sf133_column_4_amount,
           sf133_column_5_amount,
           sf133_column_6_amount
           )
    VALUES(o_sf133_ts_value,
           o_sf133_treasury_symbol_id, --Bug 1575992
           o_sf133_line_id,
           o_sf133_column_number,
           o_sf133_amt_not_shown,
           o_sf133_amt_not_shown,
           c_sf133_column_amount2,
           c_sf133_column_amount3,
           c_sf133_column_amount4,
           c_sf133_column_amount5,
           c_sf133_column_amount6
           );
--
  g_insert_count := g_insert_count + 1;
--
-- ------------------------------------
-- Exceptions
-- ------------------------------------
EXCEPTION
--
  WHEN OTHERS THEN
    g_error_code    := SQLCODE;
    g_error_message := SQLERRM;

    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', g_error_message) ;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'-- POPULATE_TEMP_TABLE');
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'---- TREASURY SYMBOL:'||O_SF133_TS_VALUE
                             ||' Line Id:'||o_sf133_line_id
                             ||' Col:'    ||o_sf133_column_number
                             ||' Amt:'    ||o_sf133_column_amount);
--
END populate_temp_table;
-- --------------------------------------------------------


-- --------------------------------------------------------

PROCEDURE GET_BEGIN_ENDING_PERIODS(  V_PROCESS_YEAR         NUMBER,
                         V_BEGIN_PERIOD IN OUT NOCOPY NUMBER,
                         V_END_PERIOD   IN OUT NOCOPY NUMBER )
IS
  l_module_name VARCHAR2(200);
BEGIN
    l_module_name  := g_module_name || 'GET_BEGIN_ENDING_PERIODS';

    SELECT  MIN(PERIOD_NUM)
        INTO  V_BEGIN_PERIOD
    FROM gl_period_statuses
        WHERE set_of_books_id      = parm_set_of_books_id
        AND period_year            = V_PROCESS_YEAR
        AND adjustment_period_flag = 'N'
        AND application_id         = '101' ;

    SELECT  MAX(PERIOD_NUM)
        INTO  V_END_PERIOD
    FROM gl_period_statuses
        WHERE set_of_books_id      = parm_set_of_books_id
        AND period_year            = V_PROCESS_YEAR
    AND closing_status in ('C','O')
        AND application_id         = '101' ;
EXCEPTION
  WHEN OTHERS THEN
    g_error_code    := SQLCODE;
    g_error_message := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', g_error_message) ;
    RAISE ;

END GET_BEGIN_ENDING_PERIODS ;

PROCEDURE populate_gtt_with_ccid
(
  p_treasury_symbol_id NUMBER
)
IS
  l_module_name VARCHAR2(200);

  TYPE t_seg_str_table IS   TABLE OF VARCHAR2(10000)  INDEX BY BINARY_INTEGER;
  TYPE t_seg_name_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  v_seg t_seg_name_table;
  v_seg_str t_seg_str_table;
  v_statement  VARCHAR2(25000);
  v_insert_statement VARCHAR2(30000);

  CURSOR crec_cursor
  (
    p_sobid NUMBER
  ) IS
  SELECT fsda.sf133_line_acct_id,
         fsda.sf133_line_id,
         fsdl.sf133_fund_category,
         fsda.segment1,
         fsda.segment2,
         fsda.segment3,
         fsda.segment4,
         fsda.segment5,
         fsda.segment6,
         fsda.segment7,
         fsda.segment8,
         fsda.segment9,
         fsda.segment10,
         fsda.segment11,
         fsda.segment12,
         fsda.segment13,
         fsda.segment14,
         fsda.segment15,
         fsda.segment16,
         fsda.segment17,
         fsda.segment18,
         fsda.segment19,
         fsda.segment20,
         fsda.segment21,
         fsda.segment22,
         fsda.segment23,
         fsda.segment24,
         fsda.segment25,
         fsda.segment26,
         fsda.segment27,
         fsda.segment28,
         fsda.segment29,
         fsda.segment30
    FROM fv_sf133_definitions_accts fsda,
         fv_sf133_definitions_lines fsdl
   WHERE fsdl.sf133_line_id = fsda.sf133_line_id
     AND fsdl.set_of_books_id=p_sobid
   ORDER BY 2,1;

  CURSOR flex_cursor
  (
    p_chart_of_accounts_id NUMBER
  )
  IS
  SELECT application_column_name ,
         flex_value_set_id
    FROM fnd_id_flex_segments
   WHERE id_flex_code = 'GL#'
     AND id_flex_num  =  p_chart_of_accounts_id;

  CURSOR child_value_cursor
  (
    p_seg VARCHAR2,
    p_sid NUMBER
  ) IS
  SELECT child_flex_value_low,
         child_flex_value_high
    FROM fnd_flex_value_hierarchies
   WHERE parent_FLEX_value = p_seg
     AND flex_value_set_id = p_sid;

  child_rec child_value_cursor%ROWTYPE;

  l_and VARCHAR2(5);
  l_child VARCHAR2(32000);
  l_no_of_child NUMBER;
  l_no_of_seg NUMBER;
  l_segno NUMBER;
  l_cnt NUMBER;

BEGIN
  l_module_name := g_module_name || 'populate_gtt_with_ccid';

  IF ( fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Entering Module '||l_module_name);
  END IF;

  FOR crec_rec IN crec_cursor (parm_set_of_books_id) LOOP

    IF ( fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'sf133_line_acct_id = '||crec_rec.sf133_line_acct_id);
    END IF;

    v_seg(1) := crec_rec.segment1;
    v_seg(2) := crec_rec.segment2;
    v_seg(3) := crec_rec.segment3;
    v_seg(4) := crec_rec.segment4;
    v_seg(5) := crec_rec.segment5;
    v_seg(6) := crec_rec.segment6;
    v_seg(7) := crec_rec.segment7;
    v_seg(8) := crec_rec.segment8;
    v_seg(9) := crec_rec.segment9;
    v_seg(10) := crec_rec.segment10;
    v_seg(11) := crec_rec.segment11;
    v_seg(12) := crec_rec.segment12;
    v_seg(13) := crec_rec.segment13;
    v_seg(14) := crec_rec.segment14;
    v_seg(15) := crec_rec.segment15;
    v_seg(16) := crec_rec.segment16;
    v_seg(17) := crec_rec.segment17;
    v_seg(18) := crec_rec.segment18;
    v_seg(19) := crec_rec.segment19;
    v_seg(20) := crec_rec.segment20;
    v_seg(21) := crec_rec.segment21;
    v_seg(22) := crec_rec.segment22;
    v_seg(23) := crec_rec.segment23;
    v_seg(24) := crec_rec.segment24;
    v_seg(25) := crec_rec.segment25;
    v_seg(26) := crec_rec.segment26;
    v_seg(27) := crec_rec.segment27;
    v_seg(28) := crec_rec.segment28;
    v_seg(29) := crec_rec.segment29;
    v_seg(30) := crec_rec.segment30;

    v_statement := NULL;

    FOR i IN 1 ..30 LOOP
      v_seg_str(i) := NULL;
      IF ( fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'v_seg('||i||')='||v_seg(i));
      END IF;
    END LOOP;

    l_no_of_seg   := 0;

    FOR flex_rec IN flex_cursor (g_chart_of_accounts_id) LOOP
      IF ( fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'application_column_name = '||flex_rec.application_column_name);
      END IF;
      l_no_of_child   := 0;
      l_and := NULL;

      /* check the segment values is parent */
      l_segno := SUBSTR(flex_rec.application_column_name,8,2);
      IF ( fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_segno = '||l_segno);
      END IF;

      IF (v_seg(l_segno) IS NOT NULL) THEN
        SELECT COUNT(*)
          INTO l_cnt
          FROM fnd_flex_value_hierarchies
         WHERE parent_flex_value = v_seg(l_segno)
           AND flex_value_set_id =   flex_rec.flex_value_set_id;

        IF ( fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_cnt = '||l_cnt);
        END IF;

        OPEN child_value_cursor(v_seg(l_segno) , flex_rec.flex_value_set_id);

        IF (l_cnt > 0) THEN
          IF ( fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_cnt > 0');
          END IF;

          l_and := NULL;

          IF (l_no_of_seg > 0) THEN
            l_and := ' AND ';
          END IF;

          l_child :=  l_and || ' ( ';

          LOOP
            FETCH child_value_cursor INTO  child_rec;
            EXIT WHEN child_value_cursor%NOTFOUND ;

            IF (l_no_of_child > 0) THEN
              l_child  := l_child   || ' OR ';
            END IF;

            l_child := l_child ||
                       flex_rec.application_column_name ||
                       ' between '||
                       '''' ||
                       child_rec.child_flex_value_low ||
                       '''  and  ''' ||
                       child_rec.child_flex_value_high ||
                       '''' ||
                       fnd_global.local_chr(10);
            l_no_of_child := l_no_of_child + 1;
          END LOOP;

          l_child := l_child || ' )' ;
          l_and := NULL;
          v_statement := v_statement || l_and ||  l_child   ||  fnd_global.local_chr(10);

        ELSE
          IF ( fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_cnt not > 0');
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_no_of_seg='||l_no_of_seg);
          END IF;
          IF (l_no_of_seg > 0) THEN
            l_and := ' AND ';
          END IF;
          v_statement :=   v_statement || l_and ||
          flex_rec.application_column_name || ' = ''' || v_seg(l_segno) || ''' ' || fnd_global.local_chr(10);
        END IF;  --cnt > 0


        CLOSE child_value_cursor;
        l_no_of_seg := l_no_of_seg + 1;

      END IF; --v_seg(l_segno) IS NOT NULL

    END LOOP; --FLEX_CURSOR

    IF ( fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'v_statement = '||v_statement);
    END IF;

    IF (v_statement IS NOT NULL) THEN
      v_insert_statement := 'INSERT INTO fv_sf133_ccids_gt
                             (
                               sf133_line_acct_id,
                               ccid
                             )
                             SELECT :b_sf133_line_acct_id,
                                    gcc.code_combination_id
                               FROM gl_code_combinations gcc,
                                    fv_fund_parameters FFP
                              WHERE gcc.' || v_balance_column_name ||' = ffp.fund_value
                                AND ffp.treasury_symbol_id = :b_treasury_symbol_id
                                AND ffp.set_of_books_id = :b_set_of_books_id
                                AND fund_category like nvl(:b_sf133_line_category, ' || '''' ||'%' || ''''||')
                                AND '|| v_statement || '
                                AND gcc.template_id is null
                                AND gcc.chart_of_accounts_id  = :b_chart_of_accounts_id
                                AND NOT EXISTS (SELECT 1
                                                   FROM fv_sf133_ccids_gt fct
                                                  WHERE fct.sf133_line_acct_id =  :b_sf133_line_acct_id
                                                    AND fct.ccid = gcc.code_combination_id)';


      EXECUTE IMMEDIATE v_insert_statement
        USING crec_rec.sf133_line_acct_id,
              p_treasury_symbol_id,
              parm_set_of_books_id,
              crec_rec.sf133_fund_category,
              g_chart_of_accounts_id,
              crec_rec.sf133_line_acct_id;
    END IF;
  END LOOP; --crec_cursor

  IF ( fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Exiting Module = '||l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_code    := SQLCODE;
    g_error_message := SQLERRM;
    fv_utility.log_mesg(fnd_log.level_unexpected, l_module_name||'.exception',g_error_message);
    fv_utility.log_mesg(fnd_log.level_unexpected, l_module_name||'.exception','-- populate_gtt_with_ccid');
END;
 /*Procedure to fetch balance type for accounts which contain ending and/or begining balances
    of type either credit or debit or both*/
     PROCEDURE GET_BAL_TYPE
     IS
       query_Ending_Indicator VARCHAR2(8600);
       query_Beg_Indicator VARCHAR2(8600);
       l_ignore1 INTEGER;
     BEGIN
     -- get the bal indicator of all E records if there are records of multiple bal types
         query_Ending_Indicator := 'select sum(decode(facE.debit_credit,''D'',amount)),
         sum(decode(facE.debit_credit,''C'',amount))  from
         fv_facts_temp facE, fv_sf133_definitions_accts   acct
         where facE.treasury_symbol_id = '||g_treasury_symbol_id||
         'AND acct.sf133_line_id         = '||c_sf133_line_id||
         'AND acct.sf133_line_acct_id    = '||c_sf133_line_acct_id||
         'and acct_number like facE.sgl_acct_number||''%'' and facE.sgl_acct_number is not null
         and facE.begin_end=''E''' ;

         v_cursor_id_ind := dbms_sql.open_cursor;
         dbms_sql.parse(v_cursor_id_ind, query_Ending_Indicator, dbms_sql.v7);
         dbms_sql.define_column(v_cursor_id_ind, 1,DSum_E);
         dbms_sql.define_column(v_cursor_id_ind, 2,CSum_E);

         l_ignore1 := dbms_sql.execute_and_fetch(v_cursor_id_ind);
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, 'testsf133','l_ignore1 := '||l_ignore1);
            END IF;
            dbms_sql.column_value(v_cursor_id_ind, 1, DSum_E);
            dbms_sql.column_value(v_cursor_id_ind, 2, CSum_E);
           --dbms_sql.close_cursor(v_cursor_id_ind);

         if DSum_E >= CSum_E then
           e_bal_indicator:='D';
         else
           e_bal_indicator:='C';
         end if;

         -- get the bal indicator of all E records if there are records of multiple bal types
         query_Beg_Indicator:= 'select sum(decode(facB.debit_credit,''D'',amount)) ,
         sum(decode(facB.debit_credit,''C'',amount))   from
         fv_facts_temp facB, fv_sf133_definitions_accts   acct
         where facB.treasury_symbol_id = '||g_treasury_symbol_id||
         'AND acct.sf133_line_id         = '||c_sf133_line_id||
         'AND acct.sf133_line_acct_id    = '||c_sf133_line_acct_id||
         'and acct_number like facB.sgl_acct_number||''%'' and facB.sgl_acct_number is not null
         and facB.begin_end=''B''' ;

         v_cursor_id_ind := dbms_sql.open_cursor;
         dbms_sql.parse(v_cursor_id_ind, query_Beg_Indicator, dbms_sql.v7);
         dbms_sql.define_column(v_cursor_id_ind, 1,DSum_B);
         dbms_sql.define_column(v_cursor_id_ind, 2,CSum_B);

         l_ignore1 := dbms_sql.execute_and_fetch(v_cursor_id_ind);
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, 'testsf133','l_ignore1 := '||l_ignore1);
            END IF;
            dbms_sql.column_value(v_cursor_id_ind, 1, DSum_B);
            dbms_sql.column_value(v_cursor_id_ind, 2, CSum_B);
            --dbms_sql.close_cursor(v_cursor_id_ind);

         if DSum_B >= CSum_B then
         b_bal_indicator:='D';
         else
         b_bal_indicator:='C';
         end if;
         DBMS_SQL.CLOSE_CURSOR(v_cursor_id_ind);
     EXCEPTION
      WHEN OTHERS THEN
    g_error_code    := SQLCODE;
    g_error_message := SQLERRM;
    fv_utility.log_mesg(fnd_log.level_unexpected, 'testsf133'||'.exception',g_error_message);
    fv_utility.log_mesg(fnd_log.level_unexpected, 'testsf133'||'.exception','-- get_bal_type');
     END;


PROCEDURE process_total_line
IS
  l_module_name VARCHAR2(200) := g_module_name || 'process_total_line';

CURSOR fv_sf133_calc_cur IS
SELECT calc_sequence_number, line_low, line_high, line_low_type, line_high_type,
    operator
FROM fv_sf133_rep_line_calc
WHERE line_id = c_sf133_line_id
ORDER BY calc_sequence_number;

CURSOR fv_sf133_temp_cur (p_line_id NUMBER) IS
SELECT sf133_column_amount, sf133_column_2_amount, sf133_column_3_amount, sf133_column_4_amount, sf133_column_5_amount,
sf133_column_6_amount
FROM fv_sf133_definitions_cols_temp
WHERE sf133_line_id = p_line_id and
treasury_symbol_id = c_sf133_treasury_symbol_id;

-- Bug 9183877
CURSOR fv_cfs_lines_cur(p_lineid_1 NUMBER, p_lineid_2 NUMBER) IS
SELECT sf133_line_id
FROM fv_sf133_definitions_lines
WHERE sf133_line_number >=
    (SELECT sf133_line_number FROM fv_sf133_definitions_lines
     WHERE sf133_line_id = p_lineid_1 )
AND sf133_line_number <=
    (SELECT sf133_line_number FROM fv_sf133_definitions_lines
     WHERE sf133_line_id = p_lineid_2 );

l_line_id       fv_cfs_rep_lines.line_id%TYPE;
temp_amt_low   fv_sf133_definitions_cols_temp.sf133_column_amount%TYPE DEFAULT 0;
temp_amt_high  fv_sf133_definitions_cols_temp.sf133_column_amount%TYPE DEFAULT 0;
temp_amt_low_2   fv_sf133_definitions_cols_temp.sf133_column_2_amount%TYPE DEFAULT 0;
temp_amt_high_2  fv_sf133_definitions_cols_temp.sf133_column_2_amount%TYPE DEFAULT 0;
temp_amt_low_3   fv_sf133_definitions_cols_temp.sf133_column_3_amount%TYPE DEFAULT 0;
temp_amt_high_3 fv_sf133_definitions_cols_temp.sf133_column_3_amount%TYPE DEFAULT 0;
temp_amt_low_4   fv_sf133_definitions_cols_temp.sf133_column_4_amount%TYPE DEFAULT 0;
temp_amt_high_4  fv_sf133_definitions_cols_temp.sf133_column_4_amount%TYPE DEFAULT 0;
temp_amt_low_5   fv_sf133_definitions_cols_temp.sf133_column_5_amount%TYPE DEFAULT 0;
temp_amt_high_5  fv_sf133_definitions_cols_temp.sf133_column_5_amount%TYPE DEFAULT 0;
temp_amt_low_6   fv_sf133_definitions_cols_temp.sf133_column_6_amount%TYPE DEFAULT 0;
temp_amt_high_6  fv_sf133_definitions_cols_temp.sf133_column_6_amount%TYPE DEFAULT 0;
/*
    c_sf133_amt2_not_shown      Number ;
    c_sf133_amt3_not_shown      Number ;
    c_sf133_amt4_not_shown      Number ;
    c_sf133_amt5_not_shown      Number ;
    c_sf133_amt6_not_shown      Number ;

    c_sf133_column_amount2      Number ;
    c_sf133_column_amount3      Number ;
    c_sf133_column_amount4      Number ;
    c_sf133_column_amount5      Number ;
    c_sf133_column_amount6      Number ;
*/
TYPE amt_rec IS RECORD (
calc_sequence   fv_sf133_rep_line_calc.calc_sequence_number%TYPE,
col_1_amt       fv_sf133_definitions_cols_temp.sf133_column_amount%TYPE DEFAULT 0,
col_2_amt       fv_sf133_definitions_cols_temp.sf133_column_2_amount%TYPE DEFAULT 0,
col_3_amt       fv_sf133_definitions_cols_temp.sf133_column_3_amount%TYPE DEFAULT 0,
col_4_amt       fv_sf133_definitions_cols_temp.sf133_column_4_amount%TYPE DEFAULT 0,
col_5_amt       fv_sf133_definitions_cols_temp.sf133_column_5_amount%TYPE DEFAULT 0,
col_6_amt       fv_sf133_definitions_cols_temp.sf133_column_6_amount%TYPE DEFAULT 0);

TYPE amt_table IS TABLE OF amt_rec
INDEX BY BINARY_INTEGER;

amt_array       amt_table;
amt_array_cnt   BINARY_INTEGER DEFAULT 1;
v_col_1_amt fv_sf133_definitions_cols_temp.sf133_column_amount%TYPE;
v_col_2_amt fv_sf133_definitions_cols_temp.sf133_column_2_amount%TYPE;
v_col_3_amt fv_sf133_definitions_cols_temp.sf133_column_3_amount%TYPE;
v_col_4_amt fv_sf133_definitions_cols_temp.sf133_column_4_amount%TYPE;
v_col_5_amt fv_sf133_definitions_cols_temp.sf133_column_5_amount%TYPE;
v_col_6_amt fv_sf133_definitions_cols_temp.sf133_column_6_amount%TYPE;


BEGIN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,'Inside process_total_line');
    FOR calc_rec IN fv_sf133_calc_cur
    LOOP
        amt_array(amt_array_cnt).calc_sequence := calc_rec.calc_sequence_number;

        IF calc_rec.line_low_type = 'L' AND calc_rec.operator IN ('+','-') THEN
            l_line_id := calc_rec.line_low;
            OPEN fv_sf133_temp_cur(l_line_id);
            FETCH fv_sf133_temp_cur
            INTO temp_amt_low,temp_amt_low_2,temp_amt_low_3,temp_amt_low_4,temp_amt_low_5,temp_amt_low_6;
            CLOSE fv_sf133_temp_cur;
         ELSIF calc_rec.line_low_type = 'C' AND calc_rec.operator IN ('+','-') THEN
            FOR i IN 1..amt_array_cnt
            LOOP
                IF amt_array(i).calc_sequence = calc_rec.line_low THEN
                    temp_amt_low   := amt_array(i).col_1_amt;
                    temp_amt_low_2 := amt_array(i).col_2_amt;
                    temp_amt_low_3 := amt_array(i).col_3_amt;
                    temp_amt_low_4 := amt_array(i).col_4_amt;
                    temp_amt_low_5 := amt_array(i).col_5_amt;
                    temp_amt_low_6 := amt_array(i).col_6_amt;

                END IF;
            END LOOP;
        END IF;

        IF calc_rec.line_high_type = 'L' AND calc_rec.operator IN ('+','-') THEN
            l_line_id := calc_rec.line_high;
            OPEN fv_sf133_temp_cur(l_line_id);
            FETCH fv_sf133_temp_cur
             INTO temp_amt_high,temp_amt_high_2,temp_amt_high_3,temp_amt_high_4,temp_amt_high_5,temp_amt_high_6;
            CLOSE fv_sf133_temp_cur;
         ELSIF calc_rec.line_high_type = 'C' AND calc_rec.operator IN ('+','-') THEN
            FOR i IN 1..amt_array_cnt - 1
            LOOP
                IF amt_array(i).calc_sequence = calc_rec.line_high THEN
                    temp_amt_high   := amt_array(i).col_1_amt;
                    temp_amt_high_2 := amt_array(i).col_2_amt;
                    temp_amt_high_3 := amt_array(i).col_3_amt;
                    temp_amt_high_4 := amt_array(i).col_4_amt;
                    temp_amt_high_5 := amt_array(i).col_5_amt;
                    temp_amt_high_6 := amt_array(i).col_6_amt;
                END IF;
            END LOOP;
        END IF;

       IF calc_rec.operator = '+' THEN
            amt_array(amt_array_cnt).col_1_amt := NVL(temp_amt_low, 0) + NVL(temp_amt_high, 0);
            amt_array(amt_array_cnt).col_2_amt := NVL(temp_amt_low_2, 0) + NVL(temp_amt_high_2, 0);
            amt_array(amt_array_cnt).col_3_amt := NVL(temp_amt_low_3, 0) + NVL(temp_amt_high_3, 0);
            amt_array(amt_array_cnt).col_4_amt := NVL(temp_amt_low_4, 0) + NVL(temp_amt_high_4, 0);
            amt_array(amt_array_cnt).col_5_amt := NVL(temp_amt_low_5, 0) + NVL(temp_amt_high_5, 0);
            amt_array(amt_array_cnt).col_6_amt := NVL(temp_amt_low_6, 0) + NVL(temp_amt_high_6, 0);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,calc_rec.operator||amt_array(amt_array_cnt).col_1_amt);

        ELSIF calc_rec.operator = '-' THEN
            amt_array(amt_array_cnt).col_1_amt := NVL(temp_amt_low, 0) - NVL(temp_amt_high, 0);
            amt_array(amt_array_cnt).col_2_amt := NVL(temp_amt_low_2, 0) - NVL(temp_amt_high_2, 0);
            amt_array(amt_array_cnt).col_3_amt := NVL(temp_amt_low_3, 0) - NVL(temp_amt_high_3, 0);
            amt_array(amt_array_cnt).col_4_amt := NVL(temp_amt_low_4, 0) - NVL(temp_amt_high_4, 0);
            amt_array(amt_array_cnt).col_5_amt := NVL(temp_amt_low_5, 0) - NVL(temp_amt_high_5, 0);
            amt_array(amt_array_cnt).col_6_amt := NVL(temp_amt_low_6, 0) - NVL(temp_amt_high_6, 0);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,calc_rec.operator||amt_array(amt_array_cnt).col_1_amt);
        ELSE
            IF calc_rec.line_low_type = 'L' THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,'inside for loop, range:'||calc_rec.line_low||calc_rec.line_high);
                FOR lines_rec IN fv_cfs_lines_cur(calc_rec.line_low, calc_rec.line_high)
                LOOP
                    FOR fv_sf133_temp_cur_rec IN fv_sf133_temp_cur(lines_rec.sf133_line_id)
                    LOOP
                        amt_array(amt_array_cnt).col_1_amt := amt_array(amt_array_cnt).col_1_amt + NVL(fv_sf133_temp_cur_rec.sf133_column_amount, 0);
                        amt_array(amt_array_cnt).col_2_amt := amt_array(amt_array_cnt).col_2_amt + NVL(fv_sf133_temp_cur_rec.sf133_column_2_amount, 0);
                        amt_array(amt_array_cnt).col_3_amt := amt_array(amt_array_cnt).col_3_amt + NVL(fv_sf133_temp_cur_rec.sf133_column_3_amount, 0);
                        amt_array(amt_array_cnt).col_4_amt := amt_array(amt_array_cnt).col_4_amt + NVL(fv_sf133_temp_cur_rec.sf133_column_4_amount, 0);
                        amt_array(amt_array_cnt).col_5_amt := amt_array(amt_array_cnt).col_5_amt + NVL(fv_sf133_temp_cur_rec.sf133_column_5_amount, 0);
                        amt_array(amt_array_cnt).col_6_amt := amt_array(amt_array_cnt).col_6_amt + NVL(fv_sf133_temp_cur_rec.sf133_column_6_amount, 0);
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,'inside for loop, value for line'||amt_array(amt_array_cnt).col_1_amt);
                    END LOOP;
                END LOOP;
            ELSIF calc_rec.line_low_type = 'C' THEN
                FOR i IN 1..amt_array_cnt - 1
                LOOP
                    IF amt_array(i).calc_sequence >= calc_rec.line_low
                        AND amt_array(i).calc_sequence <= calc_rec.line_high THEN
                        amt_array(amt_array_cnt).col_1_amt := amt_array(amt_array_cnt).col_1_amt + NVL(amt_array(i).col_1_amt, 0);
                        amt_array(amt_array_cnt).col_2_amt := amt_array(amt_array_cnt).col_2_amt + NVL(amt_array(i).col_2_amt, 0);
                        amt_array(amt_array_cnt).col_3_amt := amt_array(amt_array_cnt).col_3_amt + NVL(amt_array(i).col_3_amt, 0);
                        amt_array(amt_array_cnt).col_4_amt := amt_array(amt_array_cnt).col_4_amt + NVL(amt_array(i).col_4_amt, 0);
                        amt_array(amt_array_cnt).col_5_amt := amt_array(amt_array_cnt).col_5_amt + NVL(amt_array(i).col_5_amt, 0);
                        amt_array(amt_array_cnt).col_6_amt := amt_array(amt_array_cnt).col_6_amt + NVL(amt_array(i).col_6_amt, 0);
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,'inside for loop, value for calc sequence'||amt_array(amt_array_cnt).col_1_amt);
                    END IF;
                END LOOP;
            END IF;
        END IF;

        amt_array_cnt := amt_array_cnt + 1;
    END LOOP;

        v_col_1_amt := amt_array(amt_array_cnt - 1).col_1_amt;
        v_col_2_amt := amt_array(amt_array_cnt - 1).col_2_amt;
        v_col_3_amt := amt_array(amt_array_cnt - 1).col_3_amt;
        v_col_4_amt := amt_array(amt_array_cnt - 1).col_4_amt;
        v_col_5_amt := amt_array(amt_array_cnt - 1).col_5_amt;
        v_col_6_amt := amt_array(amt_array_cnt - 1).col_6_amt;

        o_sf133_ts_value      := c_sf133_ts_value;
        o_sf133_line_id       := c_sf133_line_id;
        o_sf133_column_number := g_column_number;
        o_sf133_column_amount := v_col_1_amt;
        o_sf133_amt_not_shown := v_col_1_amt;
        c_sf133_column_amount2 := v_col_2_amt;
        c_sf133_amt2_not_shown := v_col_2_amt;
        c_sf133_column_amount3 := v_col_3_amt;
        c_sf133_amt3_not_shown := v_col_3_amt;
        c_sf133_column_amount4 := v_col_4_amt;
        c_sf133_amt4_not_shown := v_col_4_amt;
        c_sf133_column_amount5 := v_col_5_amt;
        c_sf133_amt5_not_shown := v_col_5_amt;
        c_sf133_column_amount6 := v_col_6_amt;
        c_sf133_amt6_not_shown := v_col_6_amt;
        o_sf133_treasury_symbol_id := c_sf133_treasury_symbol_id; --added for 1575992
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'end of process_total_line: '||o_sf133_ts_value||o_sf133_column_amount);

        populate_temp_table;

    -- Bug 9183877
    UPDATE FV_SF133_DEFINITIONS_COLS_TEMP
        SET
            SF133_AMT_TOTAL_NOT_SHOWN =
            o_sf133_amt_not_shown  + c_sf133_amt2_not_shown +
            c_sf133_amt3_not_shown + c_sf133_amt4_not_shown +
            c_sf133_amt5_not_shown + c_sf133_amt6_not_shown ,
            SF133_COLUMN_TOTAL_AMT    =
            o_sf133_column_amount  + c_sf133_column_amount2   +
            c_sf133_column_amount3 + c_sf133_column_amount4   +
            c_sf133_column_amount5 + c_sf133_column_amount6
          WHERE
            SF133_LINE_ID       = c_sf133_line_id  and
            SF133_FUND_VALUE    = o_sf133_ts_value ;

    if fv_sf133_calc_cur%ISOPEN then
      close fv_sf133_calc_cur;
    end if;

EXCEPTION
    WHEN OTHERS THEN
        g_error_code := SQLCODE ;
        g_error_message := SQLERRM || ' [PROCESS_TOTAL_LINE] ' ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_message);
        RETURN;
END process_total_line;
-- + Global Varibale Declaration +
BEGIN
	 g_module_name := 'fv.plsql.fv_sf133_oneyear.';
END fv_sf133_oneyear;




/
