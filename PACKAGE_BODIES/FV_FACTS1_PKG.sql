--------------------------------------------------------
--  DDL for Package Body FV_FACTS1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FACTS1_PKG" AS
/* $Header: FVFCFIPB.pls 120.6.12010000.5 2010/04/23 16:17:04 snama ship $ */
--------------------------------------------------------------------------------
g_module_name VARCHAR2(200);
gbl_set_of_books_id gl_ledgers_public_v.ledger_id%TYPE;
gbl_period_name gl_period_statuses.period_name%TYPE;
gbl_coa_id gl_sets_of_books.chart_of_accounts_id%TYPE;
gbl_error_code NUMBER;
gbl_error_buf VARCHAR2(300);
gbl_run_type VARCHAR2(1);
gbl_fiscal_year gl_period_statuses.period_year%TYPE;
gbl_upd_begin_bal VARCHAR2(1);
gbl_period_num_low gl_period_statuses.period_num%TYPE;
gbl_period_num_high gl_period_statuses.period_num%TYPE;
gbl_bal_segment_name VARCHAR2(10);
gbl_acc_segment_name VARCHAR2(10);
gbl_acc_value_set_id NUMBER;
gbl_update_end_balance VARCHAR2(1);
gbl_currency_code      gl_sets_of_books.currency_code%TYPE;
gbl_low_period_name    gl_period_statuses.period_name%TYPE;
gbl_prev_acct          fv_facts_report_t2.account_number%TYPE;
gbl_bal_segment        fv_facts_report_t2.fund_value%TYPE;
gbl_sgl_acct_num       VARCHAR2(4);
gbl_govt_non_govt_ind  fv_facts1_period_attributes.g_ng_indicator%TYPE;
gbl_exch_non_exch      fv_facts1_period_attributes.exch_non_exch%TYPE;
gbl_cust_non_cust      fv_facts1_period_attributes.cust_non_cust%TYPE;
gbl_budget_subfunction fv_facts1_period_attributes.budget_subfunction%TYPE;
gbl_ene_exception      VARCHAR2(25);
gbl_cnc_exception      VARCHAR2(25);
gbl_bsf_exception      VARCHAR2(25);
gbl_exception_category VARCHAR2(25);
gbl_dbr_flag           NUMBER(1);
gbl_exception_exists   varchar2(1) := 'N';
gbl_header_printed     BOOLEAN := FALSE;

vg_acct_number  VARCHAR2(30);
vg_fed_nonfed   VARCHAR2(1);
vg_sgl_acct_number VARCHAR2(30);

--------------------------------------------------------------------------------
PROCEDURE get_segment_names;
PROCEDURE submit_exception_report;
PROCEDURE process_input_parameters;
PROCEDURE fund_group_info_setup;
PROCEDURE process_t1_records;
PROCEDURE get_fund_group_info
           (p_fund_value IN         VARCHAR2,
            p_exists     OUT NOCOPY VARCHAR2,
            p_fg_null    OUT NOCOPY VARCHAR2,
            p_fund_group OUT NOCOPY VARCHAR2,
            p_dept_id    OUT NOCOPY VARCHAR2,
            p_bureau_id  OUT NOCOPY VARCHAR2);
PROCEDURE populate_temp2
          ( p_fund_group          IN Number,
            p_account_number      IN Varchar2,
            p_dept_id             IN Varchar2,
            p_bureau_id           IN Varchar2,
            p_eliminations_dept   IN Varchar2,
            p_g_ng_indicator      IN Varchar2,
            p_amount              IN Number,
            p_d_c_indicator       IN Varchar2,
            p_fiscal_year         IN Number,
            p_record_category     IN Varchar2,
            p_ussgl_account       IN Varchar2,
            p_set_of_books_id     IN Number,
            p_reported_status     IN Varchar2,
            p_exch_non_exch       IN Varchar2,
            p_cust_non_cust       IN Varchar2,
            p_budget_subfunction  IN Varchar2,
            p_fund_value          IN Varchar2,
            p_beginning_bal       IN Number,
            p_ccid                IN Number,
            p_account_type        IN Varchar2,
            p_recipient_name      IN Varchar2,
            p_dr_amount           IN Number,
            p_cr_amount           IN Number);
PROCEDURE cleanup_process;
PROCEDURE get_ussgl_acct_num
           (p_acct_num            IN  Varchar2,
            p_fund_value          IN  Varchar2,
            p_sgl_acct_num        OUT NOCOPY Number,
            p_govt_non_govt       OUT NOCOPY Varchar2,
            p_exch_non_exch       OUT NOCOPY Varchar2,
            p_cust_non_cust       OUT NOCOPY Varchar2,
            p_budget_subfunction  OUT NOCOPY Varchar2,
            p_ene_exception       OUT NOCOPY Varchar2,
            p_cnc_exception       OUT NOCOPY Varchar2,
            p_bsf_exception       OUT NOCOPY Varchar2,
            p_exception_category  OUT NOCOPY Varchar2);
FUNCTION get_account_type
           (p_account_number VARCHAR2) RETURN VARCHAR2;
PROCEDURE get_ussgl_info
           (p_ussgl_acct_num IN            Varchar2,
            p_enabled_flag   IN OUT NOCOPY Varchar2,
            p_reporting_type IN OUT NOCOPY Varchar2);
PROCEDURE edit_check(p_period_num      in VARCHAR2,
                     p_period_year     in VARCHAR2,
                     p_set_of_books_id in VARCHAR2,
                     p_status          out nocopy varchar2);
PROCEDURE create_end_bal_record;

PROCEDURE update_facts1_run(p_period_year     in VARCHAR2,
                            p_set_of_books_id in VARCHAR2);
PROCEDURE  POPULATE_FV_FACTS_FED_ACCOUNTS;
-----addded for TB report --------------------------------------
PROCEDURE journal_processes;
PROCEDURE rollup_process;
-- Global Variables for Trial Balance processing
gbl_trial_balance_type  Varchar2(1) := NULL;
gbl_treasury_symbol_id  FV_Treasury_Symbols.treasury_symbol_id%TYPE;
gbl_fund_range_low      FV_Fund_Parameters.fund_value%TYPE;
gbl_fund_range_high     FV_Fund_Parameters.fund_value%TYPE;
gbl_period_num          Gl_Balances.period_num%TYPE;
gbl_period_year         gl_period_statuses.period_year%TYPE;

-- Global Variable for RXi
gbl_report_id          FA_RX_Reports_V.report_id%TYPE;
gbl_attribute_set      FA_RX_Rep_Columns_B.attribute_set%TYPE;
gbl_output_format      Varchar2(30);
gbl_run_mode           VARCHAR2(1);

gbl_parent_flag        VARCHAR2(1);

--------------------------------------------------------------------------------
PROCEDURE MAIN(p_err_buff        OUT NOCOPY VARCHAR2,
               p_err_code        OUT NOCOPY NUMBER,
               p_sob_id          IN NUMBER,
               p_coa_id          IN NUMBER,
               p_run_type        IN VARCHAR2,
               p_period_name     IN VARCHAR2,
               p_fiscal_year     IN NUMBER,
               p_run_journal     IN VARCHAR2,
               p_run_reports     IN VARCHAR2,
	       p_trading_partner_att IN VARCHAR2
              )

IS

l_module_name         VARCHAR2(200);
l_edit_check_status   VARCHAR2(1);
l_run_mode            VARCHAR2(25);
l_req_id              NUMBER;
l_print_option 	      BOOLEAN;
l_printer_name        VARCHAR2(240);
call_status           BOOLEAN;
l_copies              NUMBER;
rphase                VARCHAR2(80);
rstatus 	      VARCHAR2(80);
dphase 		      VARCHAR2(80);
dstatus 	      VARCHAR2(80);
message 	      VARCHAR2(80);
l_exception_count     NUMBER;
l_exception_count2     NUMBER;
l_error_buf           varchar2(2000);
l_error_code          Number(15);
l_run_status          varchar2(1);
l_row_exists          NUMBER;

BEGIN

    l_module_name := g_module_name || 'MAIN';
    FV_UTILITY.LOG_MESG('In '||l_module_name);

    l_edit_check_status := 'N';
    l_run_mode          := NULL;
    l_printer_name      := FND_PROFILE.VALUE('PRINTER');
    l_copies            := FND_PROFILE.VALUE('CONC_COPIES');

    gbl_error_code := 0;
    gbl_error_buf := NULL;
    gbl_set_of_books_id := p_sob_id;
    gbl_coa_id := p_coa_id;
    gbl_run_type  := p_run_type;
    gbl_period_name := p_period_name;
    gbl_fiscal_year := p_fiscal_year;
    gbl_period_year := p_fiscal_year;

    FV_UTILITY.LOG_MESG('Parameters ');
    FV_UTILITY.LOG_MESG('---------- ');
    FV_UTILITY.LOG_MESG('SOB ID:      '||gbl_set_of_books_id);
    FV_UTILITY.LOG_MESG('COA ID:      '||gbl_coa_id);
    FV_UTILITY.LOG_MESG('Run Type:    '||gbl_run_type);
    FV_UTILITY.LOG_MESG('Period:      '||gbl_period_name);
    FV_UTILITY.LOG_MESG('Fiscal Year: '||gbl_fiscal_year);
    FV_UTILITY.LOG_MESG('Run Journal creation  :    '||p_run_journal);
    FV_UTILITY.LOG_MESG('Trading Partner Attribute: '||p_trading_partner_att);

    get_segment_names;

    IF gbl_error_code = 0 THEN
       process_input_parameters;
    END IF;

    IF gbl_error_code = 0 THEN
       cleanup_process;
    END IF;

     gbl_exception_exists := 'N';

    IF (gbl_run_type = 'Y') THEN
       l_run_mode := 'Fiscal Year';
     ELSIF (gbl_run_type = 'R') THEN
       l_run_mode := 'Period';
    END IF;

    IF  p_run_journal = 'Y' THEN

      fv_utility.log_mesg('Calling Journal Creation process.');
       l_req_id := FND_REQUEST.SUBMIT_REQUEST
                      ('FV','FVFC1JCR','','',FALSE, gbl_set_of_books_id, gbl_period_name,'I',
				p_trading_partner_att);
      FV_UTILITY.LOG_MESG(l_module_name||
                        ' REQUEST ID FOR JOURNAL CREATION PROCESS  = '|| TO_CHAR(L_REQ_ID));
          IF (l_req_id = 0) THEN
             gbl_error_code := -1;
             gbl_error_buf := ' Cannot submit FACTS Journal Creation process';
             fv_utility.log_mesg(gbl_error_buf);
             p_err_code := -1;
             p_err_buff := gbl_error_buf;
             RETURN;
           ELSE
             COMMIT;
             call_status := Fnd_concurrent.Wait_for_request(l_req_id, 20, 0,
                                                  rphase, rstatus,
                                                  dphase, dstatus, message);
             IF call_status = FALSE THEN
               gbl_error_buf := 'Cannot wait for the status of Journal Creation Process';
                gbl_error_code := -1;
                FV_UTILITY.LOG_MESG(l_module_name|| '.error4', gbl_error_buf) ;
                p_err_code := -1;
                p_err_buff := gbl_error_buf;
                RETURN;
             END IF;
          END IF;
    END IF;


    IF gbl_error_code = 0 THEN
      fv_utility.log_mesg('Calling Facts Attributes Creation process.');
     SET_UP_FACTS_ATTRIBUTES(l_error_buf ,
                             l_error_code ,
                             gbl_set_of_books_id ,
                             gbl_fiscal_year);
     gbl_error_code := l_error_code;
     gbl_error_buf := l_error_buf;
    END IF;


    IF gbl_error_code = 0 THEN
       FV_UTILITY.LOG_MESG('Calling Exception report');
       submit_exception_report;
    End if;


  -- Peforming Edit check process
    IF gbl_error_code = 0 THEN
       FV_UTILITY.LOG_MESG('Calling Edit check');
       EDIT_CHECK(GBL_PERIOD_NUM_HIGH , GBL_FISCAL_YEAR, GBL_SET_OF_BOOKS_ID, L_EDIT_CHECK_STATUS);
    FV_UTILITY.LOG_MESG('Edit check status: '||l_edit_check_status);

    End if;

    -- Submit reports only if edit check is passed.
   IF (gbl_error_code = 0 AND l_edit_check_status = 'Y' and p_run_reports = 'Y' ) then

           --Populate ending balances only if it is run in year mode or
           --if it is run by period then, only if period_num_high is the
           --last period num of the the year.
           --IF (gbl_update_end_balance = 'Y' OR gbl_run_type = 'Y') THEN
           IF (gbl_run_type = 'Y') THEN

     		SELECT count(*)
     		INTO l_row_exists
     		FROM fv_facts_ending_balances
     		WHERE fiscal_year = gbl_period_year
     		AND set_of_books_id = gbl_set_of_books_id
                AND rownum = 1;

     		IF (l_row_exists > 0) THEN
        		IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          	        	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_EVENT, l_module_name,
                                '    DELETING RECORDS FROM FV_FACTS_ENDING_BALANCES FOR
                                     THE YEAR = '|| GBL_PERIOD_YEAR);
        		END IF;
		  fv_utility.log_mesg('Deleting recs from fv_facts_ending_balances
                                          for Period Year: '||gbl_period_year);

                  DELETE FROM fv_facts_ending_balances
                  WHERE set_of_books_id = gbl_set_of_books_id
                  AND fiscal_year = gbl_period_year;
		  fv_utility.log_mesg('Deleted '||SQL%ROWCOUNT ||' recs from fv_facts_ending_balances.');
                  COMMIT;
                END IF;
                create_end_bal_record;
           END IF;

          l_print_option := FND_REQUEST.SET_PRINT_OPTIONS(
                            printer    => l_printer_name,
                            copies     => l_copies);

          FV_UTILITY.LOG_MESG(l_module_name|| ' LAUNCHING FACTS I ATB FILE GENERATION PROCESS ...');

          -- Submit ATB file process
          l_req_id := FND_REQUEST.SUBMIT_REQUEST
                      ('FV','FVFACTSR','','',FALSE, 'FVFC1ATB', gbl_fiscal_year,
                       gbl_set_of_books_id, gbl_period_num_high);

          FV_UTILITY.LOG_MESG(l_module_name|| ' REQUEST ID FOR ATB FILE  = '|| TO_CHAR(L_REQ_ID));

          -- if concurrent request submission failed then abort process
          IF (l_req_id = 0) THEN
             p_err_code := '-1';
             p_err_buff := ' Cannot submit FACTS report ATB file process';
             RETURN;
             FV_UTILITY.LOG_MESG(l_module_name||gbl_error_buf);
           ELSE
             COMMIT;
             call_status := Fnd_concurrent.Wait_for_request(l_req_id, 20, 0,
                                                  rphase, rstatus,
                                                  dphase, dstatus, message);
             IF call_status = FALSE THEN
                p_err_buff := 'Cannot wait for the status of FACTS ATB Report';
                p_err_code := -1;
                FV_UTILITY.LOG_MESG(l_module_name||
                   '.error4', gbl_error_buf) ;
                RETURN;
             END IF;
          END IF;

       END IF; /*EDIT CHECK PASSED */

     if (p_run_reports = 'Y' or l_edit_check_status = 'N') then
          -- Print the FACTS I Detail Report
          IF (gbl_error_code = 0)  THEN
             l_print_option := FND_REQUEST.SET_PRINT_OPTIONS(
                            printer    => l_printer_name,
                            copies     => l_copies);

             -- Submit FACTS I Detail Report concurrent program
             FV_UTILITY.LOG_MESG(l_module_name||
                        ' LAUNCHING FACTS I DETAIL REPORT ...');

             l_req_id := FND_REQUEST.SUBMIT_REQUEST
                   ('FV','FVFACTDR','','',FALSE, gbl_set_of_books_id, l_run_mode, gbl_fiscal_year,
                   p_period_name, gbl_period_num_high);

             FV_UTILITY.LOG_MESG(l_module_name||
                 ' REQUEST ID FOR DETAIL REPORT = '|| TO_CHAR(L_REQ_ID));

             -- If concurrent request submission failed then abort process
             IF (l_req_id = 0) THEN
                p_err_code := '-1';
                p_err_buff := ' Cannot submit FACTS Detail report';
                FV_UTILITY.LOG_MESG(l_module_name||gbl_error_buf);
                RETURN;
              ELSE
                COMMIT;
                call_status := Fnd_concurrent.Wait_for_request(l_req_id, 20, 0,
                                                  rphase, rstatus,
                                                  dphase, dstatus, message);
                IF call_status = FALSE THEN
                   p_err_buff := 'Cannot wait for the status of FACTS Detail Report';
                   p_err_code := -1;
                   FV_UTILITY.LOG_MESG(l_module_name||'.error4', gbl_error_buf) ;
                   RETURN;
                END IF;
             END IF;
          END IF;

    END IF; -- /* run reports */

    IF gbl_error_code <> 0 THEN
       p_err_code := gbl_error_code;
       p_err_buff := gbl_error_buf;
       ROLLBACK;
       RETURN;
    END IF;

    --IF l_edit_check_status = 'Y' THEN
       --UPDATE_FACTS1_RUN(GBL_PERIOD_NUM_HIGH, GBL_FISCAL_YEAR, GBL_SET_OF_BOOKS_ID, 'S');

     UPDATE fv_facts1_run
     SET    status =  decode(l_edit_check_status , 'Y', 'S' , 'F'),
            run_fed_flag =  'I',
            process_date = sysdate,
            begin_bal_diff_flag = 'Y',
            period_num  = gbl_period_num_high
     WHERE  set_of_books_id = gbl_set_of_books_id
     AND    fiscal_year     = gbl_fiscal_year
     AND    table_indicator = 'N';


   -- END IF;

    COMMIT;

        FV_UTILITY.LOG_MESG('Facts I Main Process completed successfully.');
        p_err_buff := 'Facts I Main Process completed successfully.';


 EXCEPTION WHEN OTHERS THEN
    p_err_code := SQLCODE;
    p_err_buff := 'When others exception in Main - '||SQLERRM;
    ROLLBACK;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_error_buf);

END main;
--------------------------------------------------------------------------------
-- Get balancing and accounting segments
--------------------------------------------------------------------------------
PROCEDURE GET_SEGMENT_NAMES
IS

l_module_name VARCHAR2(200);
l_temp_mesg VARCHAR2(100);
l_app_id NUMBER := 101;
l_flex_code VARCHAR2(10) := 'GL#';
l_segment_found BOOLEAN;
invalid_bal_segment EXCEPTION;
invalid_acc_segment EXCEPTION;

BEGIN

  l_module_name := g_module_name || 'GET_SEGMENT_NAMES';
  FV_UTILITY.LOG_MESG('In '||l_module_name);

  l_temp_mesg := ' getting balancing/accounting segment. ';


  SELECT chart_of_accounts_id
  INTO gbl_coa_id
  FROM gl_ledgers_public_v
  WHERE ledger_id = gbl_set_of_books_id;

  FV_UTILITY.LOG_MESG('COA ID: '||gbl_coa_id);

   -- Get Balancing Segment Name
  -----------------------------
  l_segment_found := FND_FLEX_APIS.get_segment_column
                             (l_app_id,
                              l_flex_code,
                              gbl_coa_id,
                              'GL_BALANCING',
                              gbl_bal_segment_name) ;

  IF NOT l_segment_found THEN
     RAISE invalid_bal_segment;
  END IF;

  -- Get Accounting Segment Name
  ------------------------------
  l_segment_found := FND_FLEX_APIS.get_segment_column
                             (l_app_id,
                          l_flex_code,
                          gbl_coa_id,
                          'GL_ACCOUNT',
                         gbl_acc_segment_name);
  IF NOT l_segment_found THEN
     RAISE invalid_acc_segment;
  END IF;

  -- Get the value set id
  l_temp_mesg := ' getting account value set id. ';
  SELECT flex_value_set_id
  INTO   gbl_acc_value_set_id
  FROM   fnd_id_flex_segments
  WHERE  application_column_name = gbl_acc_segment_name
  AND    id_flex_code = 'GL#'
  AND    id_flex_num = gbl_coa_id;

  FV_UTILITY.LOG_MESG('Balancing Segment: '||gbl_bal_segment_name);
  FV_UTILITY.LOG_MESG('Accounting Segment: '||gbl_acc_segment_name);
  FV_UTILITY.LOG_MESG('Accounting value set id: '||gbl_acc_value_set_id);

 EXCEPTION
   WHEN invalid_bal_segment THEN
       gbl_error_code := -1 ;
       gbl_error_buf := 'Error while fetching balancing segment.';
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_error_buf);
   WHEN invalid_acc_segment THEN
       gbl_error_code := -1 ;
       gbl_error_buf := 'Error while fetching accounting segment.';
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_error_buf);
   WHEN NO_DATA_FOUND THEN
       gbl_error_code := -1 ;
       gbl_error_buf := l_module_name||' - No data found when'||l_temp_mesg;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_error_buf);
   WHEN OTHERS THEN
       gbl_error_code := -1 ;
       gbl_error_buf := l_module_name||' - When others error when'||
                       l_temp_mesg||SQLERRM;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_error_buf);

END get_segment_names;
--------------------------------------------------------------------------------
--		PROCEDURE PROCESS_INPUT_PARAMETERS
--------------------------------------------------------------------------------
-- Identify the type of input parameters passed, whether fiscal year is passed
-- or period is passed. p_run_type determines the parameter passed. Valid
-- parameter type values are 'Y', indicating year and 'R', indicating period.
-- Global variables 'gbl_period_num_low' and 'gbl_period_num_high'
-- are loaded with the derived period number range.
--------------------------------------------------------------------------------
PROCEDURE PROCESS_INPUT_PARAMETERS

IS
  l_module_name VARCHAR2(200);
  l_temp_mesg VARCHAR2(100);
  l_year NUMBER;
  l_closing_status VARCHAR2(1);
  l_end_period_num NUMBER;

BEGIN

  l_module_name := g_module_name || 'PROCESS_INPUT_PARAMETERS';
  FV_UTILITY.LOG_MESG('In '||l_module_name);

     -- Error out if the required parameters are null.
     IF (gbl_run_type = 'Y' AND gbl_fiscal_year IS NULL) OR
        (gbl_run_type = 'R' AND gbl_period_name IS NULL) THEN
         gbl_error_code := -1;
         gbl_error_buf := 'Period Name is required if Run Type is R or '||
                       'Fiscal Year is required if Run Type is Y.';
         FV_UTILITY.LOG_MESG(gbl_error_buf);
         RETURN;
     END IF;

     -- Parameter type will be Y if year is passed and R
     -- if period is passed.
     IF gbl_run_type = 'Y' THEN

       l_temp_mesg := ' getting first period of the year. ';
       SELECT MIN(period_num)
       INTO  gbl_period_num_low
       FROM  gl_period_statuses
       WHERE period_year = gbl_fiscal_year
       AND   application_id = 101
       AND   closing_status <> 'F'
       AND   closing_status <> 'N'
       AND   adjustment_period_flag = 'N'
       AND   ledger_id = gbl_set_of_books_id;

       IF gbl_period_num_low = 0 THEN
          RAISE NO_DATA_FOUND;
       END IF;

       l_temp_mesg := ' getting last period of the year. ';
       SELECT MAX(period_num)
       INTO   gbl_period_num_high
       FROM  gl_period_statuses
       WHERE period_year = gbl_fiscal_year
       AND   application_id = 101
       AND   closing_status <> 'F'
       AND   closing_status <> 'N'
       AND   ledger_id = gbl_set_of_books_id;

       IF gbl_period_num_high = 0 THEN
          RAISE NO_DATA_FOUND;
       END IF;

       l_temp_mesg := ' getting period name for last period of the year. ';
       SELECT period_name
       INTO gbl_period_name
       FROM gl_period_statuses
       WHERE period_num = gbl_period_num_high
       AND period_year = gbl_fiscal_year
       AND application_id = 101
       AND ledger_id = gbl_set_of_books_id;

     ELSE  -- p_parameter_type = 'P'

       -- Period name is passed, get the fiscal year and
       -- the period number.
       l_temp_mesg := ' getting period num/fiscal year for the period passed. ';
       SELECT period_num, period_year, closing_status
       INTO   gbl_period_num_high, gbl_fiscal_year, l_closing_status
       FROM   gl_period_statuses
       WHERE  period_name = gbl_period_name
       AND    application_id = 101
       AND    ledger_id = gbl_set_of_books_id;

   gbl_period_year := gbl_fiscal_year;


       -- If the passed period status is F or N then get the period
       -- number of the next lower period whose status is not F or N.
       IF l_closing_status IN ('F' , 'N') THEN
              l_temp_mesg := ' getting lower period number for the period passed. ';
           SELECT Max(period_num)
           INTO   gbl_period_num_high
           FROM   gl_period_statuses
           WHERE  period_year = gbl_fiscal_year
           AND    application_id = 101
           AND    closing_status <> 'F'
           AND    closing_status <> 'N'
           AND    period_num <= gbl_period_num_high
           AND    ledger_id = gbl_set_of_books_id;
       END IF;

       l_temp_mesg := ' getting first period of the year. ';
       SELECT MIN(period_num)
       INTO  gbl_period_num_low
       FROM  gl_period_statuses
       WHERE period_year = gbl_fiscal_year
       AND application_id = 101
       AND adjustment_period_flag = 'N'
       AND ledger_id = gbl_set_of_books_id;

       IF gbl_period_num_low IS NULL THEN
          RAISE NO_DATA_FOUND;
       END IF;

       l_temp_mesg := ' getting last period of the year. ';
       SELECT MAX(period_num)
       INTO   l_end_period_num
       FROM  gl_period_statuses
       WHERE period_year = gbl_fiscal_year
       AND application_id = 101
       AND ledger_id = gbl_set_of_books_id;

       IF gbl_period_num_high IS NULL THEN
          RAISE NO_DATA_FOUND;
       END IF;

       -- If the period being run for is the end period of the fiscal year
       IF l_end_period_num = gbl_period_num_high THEN
            gbl_update_end_balance := 'Y';
       END IF;

     END IF; -- p_parameter_type

     IF gbl_period_num_low > gbl_period_num_high THEN
        gbl_error_code := -1;
        gbl_error_buf  := 'PROCESS INPUT PARAMETERS - Period Number for ' ||
		       'Lower Period of the Range is greater than the ' ||
		       'Higher period.';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_error_buf);
        RETURN;
     END IF;

     l_temp_mesg := ' getting period name of first period of the year. ';
     SELECT period_name
     INTO   gbl_low_period_name
     FROM  gl_period_statuses
     WHERE period_num = gbl_period_num_low
     AND period_year = gbl_fiscal_year
     AND application_id = 101
     AND ledger_id = gbl_set_of_books_id;

     l_temp_mesg := ' getting currency code. ';
     SELECT currency_code
     INTO   gbl_currency_code
     FROM   gl_ledgers_public_v
     WHERE  ledger_id = gbl_set_of_books_id;

     IF gbl_currency_code IS NULL THEN
        RAISE NO_DATA_FOUND;
     END IF;

     FV_UTILITY.LOG_MESG('Period low: '||gbl_period_num_low);
     FV_UTILITY.LOG_MESG('Period high: '||gbl_period_num_high);
     FV_UTILITY.LOG_MESG('Fiscal year: '||gbl_fiscal_year);
     FV_UTILITY.LOG_MESG('Currency Code: '||gbl_currency_code);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        gbl_error_code := -1 ;
        gbl_error_buf  := l_module_name||' - No data found when '||l_temp_mesg;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_error_buf);

   WHEN OTHERS THEN
        gbl_error_code := SQLCODE ;
        gbl_error_buf  := ' - When others error when '||l_temp_mesg||SQLERRM;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);
END process_input_parameters;
--------------------------------------------------------------------------------
--                      FUND_GROUP_INFO_SETUP
--  Update fv_fund_parameters table with the required info.
--------------------------------------------------------------------------------
PROCEDURE FUND_GROUP_INFO_SETUP
IS
  l_module_name VARCHAR2(200);
  cnt BINARY_INTEGER := 0;
  l_hash BINARY_INTEGER := 0;
  l_fund_group       fv_treasury_symbols.fund_group_code%type;
  l_fund_val         fv_fund_parameters.fund_value%TYPE;
  l_dept_id          fv_treasury_symbols.department_id%TYPE;
  l_bureau_id        fv_treasury_symbols.bureau_id%TYPE;
  ln_fund_group_type fv_fund_groups.type%type ;
  ln_facts1_rollup   fv_fund_groups.fund_group_code%TYPE;

  CURSOR fund_cur IS
     SELECT ffp.fund_value fund_val, fts.fund_group_code fund_grp,
            fts.department_id dep_id, fts.bureau_id bu_id
     FROM fv_treasury_symbols fts, fv_fund_parameters ffp
     WHERE ffp.set_of_books_id = gbl_set_of_books_id
     AND fts.treasury_symbol_id = ffp.treasury_symbol_id;

BEGIN

  l_module_name := g_module_name || 'FUND_GROUP_INFO_SETUP';
FV_UTILITY.LOG_MESG('In '||l_module_name);

  gbl_error_code := 0;
  gbl_error_buf  := Null;

  FOR fund_rec IN fund_cur
  LOOP

     l_fund_group := fund_rec.fund_grp;
     l_dept_id := fund_rec.dep_id;
     l_bureau_id := fund_rec.bu_id;

     IF (l_fund_group IS NULL) THEN
       l_fund_group := NULL;
       l_dept_id := NULL;
       l_bureau_id := NULL;
     ELSE

        -- Set the Fund Group
        DECLARE
          CURSOR facts1_rollup_cur IS
            SELECT facts1_rollup
            FROM fv_fund_groups
            WHERE fund_group_code = l_fund_group
            AND set_of_books_id = gbl_set_of_books_id;
        BEGIN
          ln_facts1_rollup := NULL;

          OPEN facts1_rollup_cur;
          FETCH facts1_rollup_cur INTO ln_facts1_rollup;
          CLOSE facts1_rollup_cur;

          IF ln_facts1_rollup IS NOT NULL THEN
            l_fund_group := ln_facts1_rollup;
          END IF;
        END;
     END IF;

     IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_EVENT, l_module_name,
           ' Fund Group: '||l_fund_group);
    END IF;

 --fv_utility.log_mesg('**********fund_value: '||fund_rec.fund_val);
 --fv_utility.log_mesg('**********fund_group_code: '||l_fund_group);

    UPDATE fv_fund_parameters
    SET department_id = fund_rec.dep_id,
            bureau_id = fund_rec.bu_id,
            fund_group_code = l_fund_group
    WHERE fund_value = fund_rec.fund_val
    AND set_of_books_id = gbl_set_of_books_id;

  END LOOP;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_EVENT, l_module_name,
           ' No Data Found for fund group.');
    END IF;

  WHEN Others THEN
   gbl_error_code := -1 ;
   gbl_error_buf := l_module_name||' - When others exception - ' ||
         to_char(sqlcode) || ' - ' || sqlerrm ;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);

END fund_group_info_setup;
--------------------------------------------------------------------------------
--              PROCEDURE  PROCESS_T1_RECORDS
--------------------------------------------------------------------------------
PROCEDURE PROCESS_T1_RECORDS
IS

l_module_name VARCHAR2(100);
l_bal_segment     VARCHAR2(30);
l_bal_segment_prv  VARCHAR2(30);
l_diff_flag         varchar2(1);
l_ending_amount   NUMBER := 0;
l_t2_detail_amount   NUMBER := 0;
l_stage           varchar2(20);


/** moved the code to SET_UP_FACTS_ATTRIUTES */
begin

null;


END process_t1_records;
--------------------------------------------------------------------------------
--              PROCEDURE GET_FUND_GROUP_INFO
--------------------------------------------------------------------------------
-- Get the Fund Group, Dept Id, Bureau Id and from the fv_fund_parameters
-- table for the passed fund value.
--------------------------------------------------------------------------------
PROCEDURE GET_FUND_GROUP_INFO
( p_fund_value IN         VARCHAR2,
  p_exists     OUT NOCOPY VARCHAR2,
  p_fg_null    OUT NOCOPY VARCHAR2,
  p_fund_group OUT NOCOPY VARCHAR2,
  p_dept_id    OUT NOCOPY VARCHAR2,
  p_bureau_id  OUT NOCOPY VARCHAR2)

IS

  l_module_name VARCHAR2(200);

BEGIN

   l_module_name := g_module_name || 'GET_FUND_GROUP_INFO';
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'In '||l_module_name);
   END IF;
      --FV_UTILITY.LOG_MESG('In '||l_module_name);

   BEGIN
     SELECT department_id,
            bureau_id,
            fund_group_code
       INTO p_dept_id,
            p_bureau_id,
            p_fund_group
       FROM fv_fund_parameters
      WHERE fund_value = p_fund_value
        AND set_of_books_id = gbl_set_of_books_id;
      p_exists := 'Y';
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       p_exists     := 'N';
   END;

   IF (p_fund_group IS NULL) THEN
     p_fg_null := 'Y';
   ELSE
     p_fg_null := 'N';
   END IF;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Fund Value: '||p_fund_value);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Dept Id: '||p_dept_id);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Bureau Id: '||p_bureau_id);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Fund Group: '||p_fund_group);
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   gbl_error_buf  := l_module_name||' No fund group data found for fund : ' || p_fund_value;
   IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_EVENT, l_module_name,gbl_error_buf);
   END IF;

  WHEN OTHERS THEN
   gbl_error_code := -1 ;
   gbl_error_buf  := l_module_name||' - When others exception - '||
         to_char(SQLCODE) || ' - ' || SQLERRM ;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);

END get_fund_group_info;
--------------------------------------------------------------------------------
--                     PROCEDURE POPULATE_TEMP2
--------------------------------------------------------------------------------
PROCEDURE POPULATE_TEMP2
( p_fund_group          IN Number,
  p_account_number      IN Varchar2,
  p_dept_id             IN Varchar2,
  p_bureau_id           IN Varchar2,
  p_eliminations_dept   IN Varchar2,
  p_g_ng_indicator      IN Varchar2,
  p_amount              IN Number,
  p_d_c_indicator       IN Varchar2,
  p_fiscal_year         IN Number,
  p_record_category     IN Varchar2,
  p_ussgl_account       IN Varchar2,
  p_set_of_books_id     IN Number,
  p_reported_status     IN Varchar2,
  p_exch_non_exch       IN Varchar2,
  p_cust_non_cust       IN Varchar2,
  p_budget_subfunction  IN Varchar2,
  p_fund_value          IN Varchar2,
  p_beginning_bal       IN Number,
  p_ccid                IN Number,
  p_account_type        IN Varchar2,
  p_recipient_name      IN Varchar2,
  p_dr_amount           IN Number,
  p_cr_amount           IN Number
)
IS
  l_module_name VARCHAR2(200);
BEGIN

  l_module_name := g_module_name||' POPULATE_TEMP2';

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'Inserting a record in T2 for record_category :'||p_record_category||' for ccid: '||p_ccid);
  END IF;

      INSERT INTO fv_facts_report_t2
      ( fund_group,
        account_number,
        dept_id,
        bureau_id,
        eliminations_dept,
        g_ng_indicator,
        amount,
        d_c_indicator,
        fiscal_year,
        record_category,
        ussgl_account,
        set_of_books_id,
        reported_status,
        exch_non_exch,
        cust_non_cust,
        budget_subfunction,
        fund_value,
        beginning_balance,
        ccid,
        account_type,
        recipient_name,
        dr_amount,
        cr_amount)
      VALUES
      ( p_fund_group,
        p_account_number,
        p_dept_id,
        p_bureau_id,
        p_eliminations_dept,
        p_g_ng_indicator,
        nvl(p_amount, 0),
        DECODE(SIGN(nvl(p_amount, 0)), 0 ,'D', 1, 'D', -1, 'C'),
        p_fiscal_year,
        p_record_category,
        p_ussgl_account,
        p_set_of_books_id,
        p_reported_status,
        p_exch_non_exch,
        p_cust_non_cust,
        p_budget_subfunction,
        p_fund_value,
        p_beginning_bal,
        p_ccid,
        p_account_type,
        p_recipient_name,
        p_dr_amount,
        p_cr_amount);

EXCEPTION
  WHEN OTHERS THEN
    gbl_error_code := -1;
    gbl_error_buf := l_module_name||' - When others exception -'||
                      to_char(SQLCODE) || ' - ' || SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);

END populate_temp2;
--------------------------------------------------------------------------------
--                 PROCEDURE GET_USSGL_ACCT_NUM
--------------------------------------------------------------------------------
--  Process the records to find exceptions and return the cust_non_cust,
--  exch_non_exch and no_val_subfunction exceptions individually
--------------------------------------------------------------------------------
PROCEDURE GET_USSGL_ACCT_NUM (p_acct_num	    IN  Varchar2,
			      p_fund_value	    IN  Varchar2,
       		              p_sgl_acct_num   	    OUT NOCOPY Number,
	 		      p_govt_non_govt       OUT NOCOPY Varchar2,
		 	      p_exch_non_exch	    OUT NOCOPY Varchar2,
		      	      p_cust_non_cust	    OUT NOCOPY Varchar2,
		              p_budget_subfunction  OUT NOCOPY Varchar2,
	 	   	      p_ene_exception	    OUT NOCOPY Varchar2,
			      p_cnc_exception	    OUT NOCOPY Varchar2,
			      p_bsf_exception  	    OUT NOCOPY Varchar2,
               		      p_exception_category  OUT NOCOPY Varchar2)


IS

  l_module_name VARCHAR2(200);
  l_ussgl_acct_num        VARCHAR2(4);
  l_ussgl_enabled         VARCHAR2(1);
  l_reporting_type        VARCHAR2(1);

  l_exists                VARCHAR2(1);
  l_row_exists            VARCHAR2(1);
  l_g_ng_ind  		  Fv_Facts_Report_T2.g_ng_indicator%TYPE;
  l_e_ne_ind  		  Fv_Facts_Attributes.exch_non_exch%TYPE;
  l_c_nc_ind 		  Fv_Facts_Attributes.cust_non_cust%TYPE;
  l_c_nc 		  Fv_Facts_Report_T2.cust_non_cust%TYPE;
  l_budget_sub_ind	  Fv_Facts_Attributes.budget_subfunction%TYPE;
  l_budget_sub		  Fv_Facts_Report_T2.budget_subfunction%TYPE;

BEGIN

  l_module_name := g_module_name || 'GET_USSGL_ACCT_NUM';
  --FV_UTILITY.LOG_MESG('In '||l_module_name);

  l_exists          := NULL;
  l_ussgl_enabled   := NULL;
  l_reporting_type  := NULL;

  p_sgl_acct_num      := NULL;
  p_govt_non_govt     := NULL;
  p_exch_non_exch     := NULL;
  p_cust_non_cust     := NULL;
  p_budget_subfunction:= NULL;

  p_exception_category:= NULL;
  p_bsf_exception     := NULL;
  p_cnc_exception     := NULL;
  p_ene_exception     := NULL;

  -- Validate the Account number and return the corresponding SGL
  -- number or parent for getting attributes.
  -- Verify whether the account number exists in FV_FACTS_ATTRIBUTES table
  -- Validate the USSGL Account Number
  gbl_error_code := 0;

  GET_USSGL_INFO(p_acct_num, l_ussgl_enabled, l_reporting_type);

  IF gbl_error_code <> 0 THEN
    RETURN;
  END IF;

  IF l_ussgl_enabled IS NOT NULL THEN    -- Account is USSGL_ACCOUNT

     p_sgl_acct_num      := p_acct_num;

     IF l_ussgl_enabled = 'N' THEN
        p_exception_category:= 'USSGL_DISABLED';
        RETURN;
     END IF;

    IF l_reporting_type = '2'  THEN
      -- Account Number is not a valid FACTS I Account
      p_exception_category:= 'PROP_ACCT_FACTSII';
      RETURN;
    END IF;

    BEGIN

      SELECT 'X', govt_non_govt, exch_non_exch, cust_non_cust, budget_subfunction
      INTO   l_exists, l_g_ng_ind, l_e_ne_ind, l_c_nc_ind, l_budget_sub_ind
      FROM   fv_facts_attributes
      WHERE  facts_acct_number = p_acct_num
      AND    set_of_books_id = gbl_set_of_books_id;

      p_govt_non_govt  	   := l_g_ng_ind;

      -- Account Number Valid
      -- If Budget_Subfunction is Checked 'Y' in FV_FACTS_ATTRIBUTES
      -- but Budget_Subfunction is empty in FV_FUND_PARAMETERS then
      -- the account gets reported to exception report

      IF (l_budget_sub_ind = 'Y') THEN
         SELECT 'X', budget_subfunction
         INTO   l_row_exists, l_budget_sub
         FROM   fv_fund_parameters
         WHERE  fund_value = P_FUND_VALUE
         AND    set_of_books_id = gbl_set_of_books_id;
     END IF;

     IF (l_budget_sub_ind = 'Y') THEN
	IF (l_budget_sub IS NULL) THEN
      	   p_bsf_exception	:= 'NO_VAL_SUBFUNCTION';
	 ELSE
      	   p_budget_subfunction	:= l_budget_sub;
        END IF;
      ELSE
	p_budget_subfunction	:= NULL;
     END IF;

      -- If the value in EXCH_NON_EXCH is 'Either Exchange or Non-exchange'
      -- the account does not get reported on the file, it instead gets
      -- reported on the Exception Report

     IF (l_e_ne_ind = 'Y') THEN
      	 p_ene_exception	:= 'EXCH_NON_EXCH';
      ELSE
	IF (l_e_ne_ind = 'N') THEN
	   p_exch_non_exch 	:= NULL;
	 ELSE
      	   p_exch_non_exch  	:= l_e_ne_ind;
	END IF;
     END IF;

     IF (l_c_nc_ind = 'Y') THEN
        SELECT 'X', fts.cust_non_cust
        INTO   l_row_exists, l_c_nc
        FROM   fv_treasury_symbols fts, fv_fund_parameters ffp
        WHERE  fts.treasury_symbol_id = ffp.treasury_symbol_id
        AND    ffp.set_of_books_id = gbl_set_of_books_id
	AND    ffp.fund_value = P_FUND_VALUE;
     END IF;

     IF (l_c_nc_ind = 'Y') THEN
	IF (l_c_nc IS  NULL) THEN
      	   p_cnc_exception   := 'CUST_NON_CUST';
         ELSE
      	   p_cust_non_cust := l_c_nc ;
        END IF;
      ELSE
        p_cust_non_cust  := NULL;
     END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_sgl_acct_num      := p_acct_num;
        p_govt_non_govt     := NULL;
	p_budget_subfunction:= NULL;
      	p_exch_non_exch	    := NULL;
      	p_cust_non_cust	    := NULL;

	p_bsf_exception     := NULL;
	p_cnc_exception     := NULL;
	p_ene_exception     := NULL;
        p_exception_category:= 'PROP_ACCT_NOT_SETUP';
        return;

      WHEN OTHERS THEN
  	gbl_error_code := -1;
        gbl_error_buf := l_module_name||' - When others error: '||SQLERRM;
        --fnd_file.put_line(fnd_file.log , 'first other error raised due to check in
        -- fv_facts_attributs or fund_parameter in [GET_USSGL_ACCOUNT_NUM]');
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);
        RETURN;
     END;

  ELSE  -- account is not a ussgl_account
    -- Reset the holder variable
    l_exists := NULL;

    --fnd_file.put_line(fnd_file.log , 'Account is not USSGL ,
    --so checking facts_attributes for a/c itself') ;
    BEGIN
      SELECT 'X', govt_non_govt, exch_non_exch, cust_non_cust, budget_subfunction
      INTO   l_exists, l_g_ng_ind, l_e_ne_ind, l_c_nc_ind, l_budget_sub_ind
      FROM   fv_facts_attributes
      WHERE  facts_acct_number = p_acct_num
      AND    set_of_books_id = gbl_set_of_books_id;

     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    BEGIN
      SELECT parent_flex_value
      INTO  l_ussgl_acct_num
      FROM  fnd_flex_value_hierarchies
      WHERE (p_acct_num BETWEEN child_flex_value_low
                AND child_flex_value_high)
      AND flex_value_set_id = gbl_acc_value_set_id
      AND parent_flex_value <> 'T'
      AND parent_flex_value IN
        	(SELECT ussgl_account
                 FROM fv_facts_ussgl_accounts
                 WHERE ussgl_account = parent_flex_value);

     --  fnd_file.put_line(fnd_file.log , 'Parent and USSGL found  for ' || p_acct_num || ' as ' || l_ussgl_acct_num);
     -- Parent Found. Perform Validations
      -- fnd_file.put_line(fnd_file.log , 'checking whether USSGL enabled for ' || l_ussgl_acct_num);
     GET_USSGL_INFO (l_ussgl_acct_num, l_ussgl_enabled, l_reporting_type);

     IF gbl_error_code <> 0 THEN
       return;
     END IF;

     IF l_ussgl_enabled IS NOT NULL THEN
        p_sgl_acct_num      := l_ussgl_acct_num;

       IF l_ussgl_enabled = 'N' THEN
          p_exception_category:= 'USSGL_DISABLED';
          RETURN;
       END IF;

       IF l_reporting_type = '2' THEN
          -- Account Number is not a valid candidate for FACTS II
          -- reporting. Transaction is skipped with no Exception
          p_exception_category  := 'PROP_ACCT_FACTSII' ;
          RETURN;
       END IF;

       IF l_exists IS NOT NULL THEN
          --fnd_file.put_line(fnd_file.log , 'USSGL exists and facts
          --attributes found for' || p_acct_num );
	  -- Parent is Valid USSGL Acct. Child exists on FV_FACTS_ATTRIBUTES
          p_govt_non_govt    := l_g_ng_ind;

          -- If Budget_Subfunction is Checked 'Y' in FV_FACTS_ATTRIBUTES
          -- but Budget_Subfunction is empty in FV_FUND_PARAMETERS then
          -- the account gets reported to exception report
      	  IF (l_budget_sub_ind = 'Y') THEN
               SELECT 'X', budget_subfunction
               INTO   l_row_exists, l_budget_sub
               FROM   fv_fund_parameters
               WHERE  fund_value = P_FUND_VALUE
               AND    set_of_books_id = gbl_set_of_books_id;
      	  END IF;

      	  IF (l_budget_sub_ind = 'Y') THEN
               IF (l_budget_sub IS NULL) THEN
                  p_bsf_exception      := 'NO_VAL_SUBFUNCTION';
                ELSE
                  p_budget_subfunction := l_budget_sub;
               END IF;
           ELSE
               p_budget_subfunction   := NULL;
          END IF;

	  -- If the value in EXCH_NON_EXCH is 'Either Exchange or Non-exchange'
          -- the account does not get reported on the file, it instead gets
          -- reported on the Exception Report
          IF (l_e_ne_ind = 'Y') THEN
      	     p_ene_exception  := 'EXCH_NON_EXCH';
	   ELSE
	     IF (l_e_ne_ind = 'N') THEN
                  P_EXCH_NON_EXCH   := NULL;
              ELSE
                  P_EXCH_NON_EXCH   := l_e_ne_ind;
	     END IF;
	  END IF;

          IF (l_c_nc_ind = 'Y') THEN
              SELECT 'X', fts.cust_non_cust
              INTO   l_row_exists, l_c_nc
              FROM   fv_treasury_symbols fts, fv_fund_parameters ffp
              WHERE  fts.treasury_symbol_id = ffp.treasury_symbol_id
              AND    ffp.set_of_books_id = gbl_set_of_books_id
              AND    ffp.fund_value = P_FUND_VALUE;
          END IF;

          IF (l_c_nc_ind = 'Y') THEN
              IF (l_c_nc IS  NULL) THEN
                 p_cnc_exception   := 'CUST_NON_CUST';
               ELSE
                 p_cust_non_cust := l_c_nc ;
              END IF;
           ELSE
              p_cust_non_cust  := NULL;
          END IF;

       ELSE  -- Else of l_exists

           -- Account Type for further Validation
           BEGIN
              --USSGL exists but no facts attributes found for the acct num.
              --So check facts attribuetes from its USSGL acct.
              SELECT 'X', govt_non_govt, exch_non_exch, cust_non_cust, budget_subfunction
              INTO l_exists, l_g_ng_ind, l_e_ne_ind, l_c_nc_ind, l_budget_sub_ind
              FROM fv_facts_attributes
              WHERE facts_acct_number = l_ussgl_acct_num
              AND set_of_books_id = gbl_set_of_books_id;

              --fnd_file.put_line(fnd_file.log , 'facts-attibutes found  for' || p_acct_num );
              -- Parent is Valid USSGL Acct. Return Values
              p_sgl_acct_num 	  := l_ussgl_acct_num ;
	      p_govt_non_govt 	  := l_g_ng_ind;

      	      IF (l_budget_sub_ind = 'Y') THEN
         	 SELECT 'X', budget_subfunction
         	 INTO   l_row_exists, l_budget_sub
         	 FROM   fv_fund_parameters
         	 WHERE  fund_value = p_fund_value
         	 AND    set_of_books_id = gbl_set_of_books_id;
       	      END IF;

      	      IF (l_budget_sub_ind = 'Y') THEN
                 IF (l_budget_sub IS NULL) THEN
        	    p_bsf_exception      := 'NO_VAL_SUBFUNCTION';
                  ELSE
        	    P_BUDGET_SUBFUNCTION := l_budget_sub;
                 END IF;
               ELSE
                 p_budget_subfunction   := NULL;
              END IF;

	      -- If the value in EXCH_NON_EXCH is 'Either Exchange or Non-exchange'
              -- the account does not get reported on the file, it instead gets
              -- reported on the Exception Report
              IF (l_e_ne_ind = 'Y') THEN
        	 p_ene_exception  	:= 'EXCH_NON_EXCH';
	       ELSE
	         IF (l_e_ne_ind = 'N') THEN
           	    p_exch_non_exch   := NULL;
                  ELSE
        	    p_exch_non_exch   := l_e_ne_ind;
	         END IF;
	      END IF;

              IF (l_c_nc_ind = 'Y') THEN
                 SELECT 'X', fts.cust_non_cust
       		 INTO   l_row_exists, l_c_nc
            	 FROM   fv_treasury_symbols fts, fv_fund_parameters ffp
            	 WHERE  fts.treasury_symbol_id = ffp.treasury_symbol_id
            	 AND    ffp.set_of_books_id = gbl_set_of_books_id
            	 AND    ffp.fund_value = P_FUND_VALUE;
             END IF;

    	     IF (l_c_nc_ind = 'Y') THEN
                IF (l_c_nc IS  NULL) THEN
	           p_cnc_exception   := 'CUST_NON_CUST';
	         ELSE
	           p_cust_non_cust := l_c_nc;
	       	END IF;
	      ELSE
        	p_cust_non_cust  := NULL;
	     END IF;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              -- Budgetary Acct for which attributes are not set
              P_SGL_ACCT_NUM 	:= l_ussgl_acct_num;
	      P_GOVT_NON_GOVT 	:= NULL;
      	      P_EXCH_NON_EXCH 	:= NULL;
      	      P_CUST_NON_CUST 	:= NULL;
              P_BUDGET_SUBFUNCTION:= NULL;

	      P_BSF_EXCEPTION 	:= NULL;
	      P_ENE_EXCEPTION	:= NULL;
	      P_CNC_EXCEPTION 	:= NULL;
              P_EXCEPTION_CATEGORY:= 'PROP_ACCT_NOT_SETUP';
              --fnd_file.put_line(fnd_file.log , 'NO facts-attibutes found  for'
              --|| p_acct_num  || 'So returning with prop_acct_not_setup');
              RETURN;

            WHEN INVALID_NUMBER THEN
              -- Budgetary Acct for which attributes are not set
              P_SGL_ACCT_NUM 	:= l_ussgl_acct_num;
	      P_GOVT_NON_GOVT 	:= NULL;
      	      P_EXCH_NON_EXCH 	:= NULL;
      	      P_CUST_NON_CUST 	:= NULL;
              P_BUDGET_SUBFUNCTION:= NULL;

	      P_BSF_EXCEPTION 	:= NULL;
	      P_ENE_EXCEPTION	:= NULL;
	      P_CNC_EXCEPTION 	:= NULL;
              P_EXCEPTION_CATEGORY:= 'PROP_ACCT_NOT_SETUP';
    --          FV_UTILITY.LOG_MESG('WHEN invalid number during facts-attibutes
               --found  for'||p_acct_num||' So returning with prop_acct_not_setup');
              RETURN;
          END;
       END IF; -- End IF of l_exists

    ELSE -- Else for l_ussgl_enabled IS NOT NULL
        -- Parent not exist in FV_FACTS_USSGL_ACCOUNTS table.
        -- Raise the Exception NON_USSGL_ACCT
       --fnd_file.put_line(fnd_file.log , 'NO USSGL FOUND  found  for'
          --||p_acct_num||' So returning with NON_USSGL_ACCT');

        P_SGL_ACCT_NUM 		:= NULL;
	P_GOVT_NON_GOVT		:= NULL;
      	P_EXCH_NON_EXCH		:= NULL;
      	P_CUST_NON_CUST 	:= NULL;
        P_BUDGET_SUBFUNCTION  	:= NULL;

	P_BSF_EXCEPTION 	:= NULL;
	P_ENE_EXCEPTION 	:= NULL;
	P_CNC_EXCEPTION 	:= NULL;
        P_EXCEPTION_CATEGORY 	:= 'NON_USSGL_ACCT';
        RETURN;
    END IF; -- Else for l_ussgl_enabled IS NOT NULL

    EXCEPTION       -- Finding Parent From GL
      WHEN NO_DATA_FOUND THEN
       --fnd_file.put_line(fnd_file.log , 'NO parent found  found  for'
          --||p_acct_num||' So returning with NON_USSGL_ACCT');
        -- No Parent found. Raise the Exception NON_USSGL_ACCT
        P_SGL_ACCT_NUM 		:= NULL;
	P_GOVT_NON_GOVT 	:= NULL;
      	P_EXCH_NON_EXCH 	:= NULL;
      	P_CUST_NON_CUST		:= NULL;
        P_BUDGET_SUBFUNCTION  	:= NULL;

	P_BSF_EXCEPTION		:= NULL;
	P_ENE_EXCEPTION 	:= NULL;
	P_CNC_EXCEPTION		:= NULL;
        P_EXCEPTION_CATEGORY 	:= 'NON_USSGL_ACCT';
        return;

      WHEN TOO_MANY_ROWS THEN
        -- Too Many Parents. Process Exception
        P_SGL_ACCT_NUM 		:= NULL;
	P_GOVT_NON_GOVT 	:= NULL;
      	P_EXCH_NON_EXCH		:= NULL;
      	P_CUST_NON_CUST 	:= NULL;
        P_BUDGET_SUBFUNCTION  	:= NULL;

	P_BSF_EXCEPTION 	:= NULL;
	P_ENE_EXCEPTION 	:= NULL;
	P_CNC_EXCEPTION		:= NULL;
        P_EXCEPTION_CATEGORY  	:= 'USSGL_MULTIPLE_PARENTS';
        --fnd_file.put_line(fnd_file.log , 'MULTIPLE USSGL parent found  found  for'
         --||p_acct_num||' So returning with MULTIPLE_USSGL');
        RETURN;

      WHEN INVALID_NUMBER THEN
        -- No Parent found. Raise the Exception NON_USSGL_ACCT
        P_SGL_ACCT_NUM 		:= NULL;
	P_GOVT_NON_GOVT 	:= NULL;
      	P_EXCH_NON_EXCH 	:= NULL;
      	P_CUST_NON_CUST		:= NULL;
        P_BUDGET_SUBFUNCTION  	:= NULL;

	P_BSF_EXCEPTION		:= NULL;
	P_ENE_EXCEPTION 	:= NULL;
	P_CNC_EXCEPTION		:= NULL;
        P_EXCEPTION_CATEGORY 	:= 'NON_USSGL_ACCT';
       -- fnd_file.put_line(fnd_file.log , 'INVALID NUMBER error
        -- 0for account :'||p_acct_num||' returing with NON_USSGL_ACCOUNT');
        RETURN;
    END;   -- Finding Parent From GL
  END IF; -- Main acct No Validation

EXCEPTION
  WHEN OTHERS THEN
        -- No Parent found. Raise the Exception NON_USSGL_ACCT
        P_SGL_ACCT_NUM 		:= NULL;
	P_GOVT_NON_GOVT 	:= NULL;
      	P_EXCH_NON_EXCH 	:= NULL;
      	P_CUST_NON_CUST		:= NULL;
        P_BUDGET_SUBFUNCTION  	:= NULL;

	P_BSF_EXCEPTION		:= NULL;
	P_ENE_EXCEPTION 	:= NULL;
	P_CNC_EXCEPTION		:= NULL;
        P_EXCEPTION_CATEGORY 	:= 'NON_USSGL_ACCT';
        fnd_file.put_line(fnd_file.log , 'FINAL WHEN OTHERS FIRED
            so will exit the process:'  || p_acct_num  );
        gbl_error_code := -1;
        gbl_error_buf := l_module_name||' - Final when others '||SQLERRM;
        RETURN;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);

END GET_USSGL_ACCT_NUM ;
--------------------------------------------------------------------------------
--                 FUNCTION GET_ACCOUNT_TYPE
--------------------------------------------------------------------------------
FUNCTION GET_ACCOUNT_TYPE(p_account_number VARCHAR2) RETURN VARCHAR2
IS

  l_module_name VARCHAR2(200);
  l_account_type varchar2(1);
  l_found        varchar2(1) := 'N';
  cnt            binary_integer := 0;

BEGIN

     l_module_name := g_module_name||'GET_ACCOUNT_TYPE';
     --FV_UTILITY.LOG_MESG('In '||l_module_name);

     SELECT SUBSTR(compiled_value_attributes, 5, 1)
     INTO l_account_type
     FROM fnd_flex_values
     WHERE flex_value = p_account_number
     AND flex_value_set_id = gbl_acc_value_set_id;

  RETURN (l_account_type);

EXCEPTION
  WHEN Others THEN
    gbl_error_code := -1 ;
    gbl_error_buf := l_module_name||' - When others exception - ' ||
                        TO_CHAR(SQLCODE) || ' - ' ||SQLERRM ;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);
END get_account_type;
--------------------------------------------------------------------------------
--               PROCEDURE GET_USSGL_INFO
--------------------------------------------------------------------------------
--  Gets the information like enabled flag and reporting type
--  for the passed account number.
--------------------------------------------------------------------------------
PROCEDURE  GET_USSGL_INFO (p_ussgl_acct_num IN            Varchar2,
                           p_enabled_flag   IN OUT NOCOPY Varchar2,
                           p_reporting_type IN OUT NOCOPY Varchar2)
IS
 l_module_name VARCHAR2(200);

BEGIN
 l_module_name := g_module_name || 'GET_USSGL_INFO';
 --FV_UTILITY.LOG_MESG('In '||l_module_name);

  SELECT ussgl_enabled_flag, reporting_type
  INTO   p_enabled_flag, p_reporting_type
  FROM   fv_facts_ussgl_accounts
  WHERE  ussgl_account = p_ussgl_acct_num;

EXCEPTION
  WHEN NO_DATA_FOUND THEN NULL;

  WHEN OTHERS THEN
    gbl_error_code := -1;
    gbl_error_buf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);
    RETURN;
END get_ussgl_info;
--------------------------------------------------------------------------------
--              FUNCTION EDIT_CHECK
--------------------------------------------------------------------------------
procedure EDIT_CHECK(p_period_num      in VARCHAR2,
                     p_period_year     in VARCHAR2,
                     p_set_of_books_id in VARCHAR2,
                     p_status          out nocopy varchar2)
IS
  l_module_name VARCHAR2(200);
  l_debit_amount number;
  l_credit_amount number;
  l_edit_check_passed varchar2(1);
  l_ledger_name gl_ledgers_public_v.name%TYPE;

  CURSOR edit_check_c IS
    SELECT fund_group, dept_id, bureau_id,
           SUM(DECODE(d_c_indicator, 'D', 0, NVL(amount, 0))) credit_amount,
           SUM(DECODE(d_c_indicator, 'C', 0, NVL(amount, 0))) debit_amount
    FROM FV_FACTS1_PERIOD_BALANCES_V
    WHERE set_of_books_id = p_set_of_books_id
    AND  period_year = p_period_year
    and  period_num <= p_period_num
    GROUP BY fund_group, dept_id, bureau_id;



BEGIN

  l_module_name := g_module_name || 'EDIT_CHECK';
  FV_UTILITY.LOG_MESG('In '||l_module_name);

  BEGIN
       select name into  l_ledger_name
       from gl_ledgers_public_v where ledger_id=p_set_of_books_id;
   EXCEPTION
    WHEN OTHERS THEN
          l_ledger_name:= FND_PROFILE.VALUE('GL_SET_OF_BKS_NAME');

  END;
 FV_UTILITY.LOG_MESG('EDIT_CHECK : l_ledger_name-> '||l_ledger_name);
  l_edit_check_passed := 'Y';

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'FACTS I Edit Checks');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Set of Books: ' || l_ledger_name);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Date: ' ||
                                to_char(SYSDATE,'YYYY/MM/DD HH24:MI'));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

  FOR v_t2_record in edit_check_c
  LOOP
    l_debit_amount := v_t2_record.debit_amount;
    l_credit_amount := v_t2_record.credit_amount;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Treasury Account Code: ' ||
                                    to_char(v_t2_record.fund_group, '0999') ||
                                    '     Dept. Id.: ' || v_t2_record.dept_id ||
                                    '      Bureau Id.: ' ||
                                    v_t2_record.bureau_id);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '                      Debit Amount: ' ||
                                        to_char(NVL(l_debit_amount, 0),
                                                     '999,999,999,999,999,999,999,990.99'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '                     Credit Amount: ' ||
                                        to_char(NVL((-1 * l_credit_amount), 0),
                                                     '999,999,999,999,999,999,999,990.99'));

    IF (NVL(l_debit_amount ,0) = (-1 * NVL(l_credit_amount, 0)))
    THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '               Edit Check Status: PASSED');
    ELSE
      l_edit_check_passed := 'N';
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '               Edit Check Status: FAILED');
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

  END LOOP;

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'FACTS I Edit Checks Completed');

  IF (l_edit_check_passed = 'N')
  THEN
    p_status :=  'N';
  ELSE
    p_status :=  'Y';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    gbl_error_code := -1;
    gbl_error_buf := l_module_name||' - When others error '||SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);
    RAISE;

END EDIT_CHECK;
--------------------------------------------------------------------------------
--              PROCEDURE CREATE_END_BAL_RECORD
--------------------------------------------------------------------------------
PROCEDURE CREATE_END_BAL_RECORD
IS

  l_module_name VARCHAR2(200);

BEGIN

    l_module_name := g_module_name || 'CREATE_END_BAL_RECORD';
    FV_UTILITY.LOG_MESG('In '||l_module_name);

    INSERT INTO FV_FACTS_ENDING_BALANCES
    (fund_group,
     account_number,
     dept_id,
     bureau_id,
     eliminations_dept,
     g_ng_indicator,
     exch_non_exch,
     cust_non_cust,
     budget_subfunction,
     amount,
     d_c_indicator,
     fiscal_year,
     record_category,
     ussgl_account,
     set_of_books_id,
     reported_status,
     fund_value,
     beginning_balance,
     ccid,
     account_type,
     recipient_name)
     (SELECT /*+ PARALLEL(T2) */
            t2.fund_group,
            t2.account_number,
            t2.dept_id,
            t2.bureau_id,
            t2.eliminations_dept,
            t2.g_ng_indicator,
            t2.exch_non_exch,
            t2.cust_non_cust,
            t2.budget_subfunction,
            SUM(NVL(amount,0)),
            t2.d_c_indicator,
            gbl_fiscal_year,
            'ENDING_BAL',
            '',
            gbl_set_of_books_id,
            '',
            t2.fund_value,
            0,
            t2.ccid,
            t2.account_type,
            t2.recipient_name
     FROM fv_facts1_period_balances_v t2
     WHERE t2.set_of_books_id = gbl_set_of_books_id
       AND t2.end_bal_ind = 'Y'
       AND nvl(t2.amount,0) <> 0
       and period_year = gbl_fiscal_year
           and (period_num <= gbl_period_num_high)
     GROUP BY t2.fund_group, t2.account_number, t2.dept_id, t2.bureau_id,
              t2.eliminations_dept, t2.g_ng_indicator, t2.exch_non_exch,
              t2.cust_non_cust, t2.budget_subfunction, t2.d_c_indicator,
              t2.fund_value, t2.ccid, t2.account_type, t2.recipient_name
     HAVING SUM(NVL(amount,0)) <> 0) ;

     fv_utility.log_mesg('Inserted '||SQL%ROWCOUNT ||' recs into fv_facts_ending_balances.');

EXCEPTION
  WHEN OTHERS THEN
    gbl_error_code := -1;
    gbl_error_buf := l_module_name||' - When others error '||SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, gbl_error_buf);
    RAISE;

END create_end_bal_record;
--------------------------------------------------------------------------------
--              PROCEDURE CLEANUP_PROCESS
--------------------------------------------------------------------------------
PROCEDURE CLEANUP_PROCESS IS

  l_module_name VARCHAR2(200);

BEGIN

     l_module_name := g_module_name || 'CLEANUP_PROCESS';
     FV_UTILITY.LOG_MESG('In '||l_module_name);


     DELETE FROM fv_facts_report_t2
     WHERE set_of_books_id = gbl_set_of_books_id;

    /** cleanup the  line balance differrence records */
     FV_UTILITY.LOG_MESG('Deleting from fv_facts1_diff_balances for Period Year: '||
                             gbl_period_year);

     DELETE FROM fv_facts1_diff_balances
     WHERE set_of_books_id = gbl_set_of_books_id
     and  period_year = gbl_period_year
     and balance_type IN ('B', 'D');
     --and balance_type = 'D';

      FV_UTILITY.LOG_MESG('Deleted '||SQL%ROWCOUNT||
                            ' records from fv_facts1_diff_balances.');

EXCEPTION
    WHEN OTHERS THEN
      gbl_error_code := -1 ;
      gbl_error_buf := l_module_name||' - When others exception - '||SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,gbl_error_buf);
END;
--------------------------------------------------------------------------------
PROCEDURE JOURNAL_PROCESSES
IS
 l_module_name VARCHAR2(200) := g_module_name || 'JOURNAL_PROCESSES';
l_jrnl_select	     Varchar2(5000);


BEGIN


   fnd_file.put_line(fnd_file.log , 'Inserting records into FV_FACTS_REPORT_T2');

     INSERT INTO fv_facts_report_t2
        (fund_group,
         account_number,
         dept_id,
         bureau_id,
         eliminations_dept,
         g_ng_indicator,
         amount,
         d_c_indicator,
         fiscal_year,
         record_category,
         ussgl_account,
         set_of_books_id,
         reported_status,
         exch_non_exch,
         cust_non_cust,
         budget_subfunction,
         fund_value,
         ccid,
         account_type,
         beginning_balance,
         dr_amount,
         cr_amount)
   SELECT
	fund_group,
	account_number,
	dept_id,
	bureau_id,
        eliminations_dept,
	g_ng_indicator,
        0,
        'N',
	gbl_period_year,
         'TRIAL_BALANCE',
	ussgl_account,
	gbl_set_of_books_id,
         'R',
	exch_non_exch,
	cust_non_cust,
	budget_subfunction,
	fund_value,
        ccid,
        account_type,
         sum(decode(balance_type,'G',period_begin_bal,
                                     decode(period_num, gbl_period_num_high,0,amount) ) ) begin_balance,
         sum(decode(balance_type, 'G' , period_dr,
                                      decode(period_num , gbl_period_num_high,
                                            decode(sign(amount) , 1 , amount , 0),0) ) ) period_dr,
         sum(decode(balance_type, 'G' , period_cr,
                                       decode(period_num , gbl_period_num_high,
                                                     decode(sign(amount) , 1 , 0 , amount),0) ) ) period_dr
      from
      fv_facts1_period_balances_v fpb
      where   fpb.set_of_books_id = gbl_set_of_books_id
      and     fpb.period_year  = gbl_fiscal_year
      and    period_num  <=  gbl_period_num_high
      and   fund_value between gbl_fund_range_low and gbl_fund_range_high
   GROUP BY fund_group,
            account_number,
            dept_id,
            bureau_id,
            eliminations_dept,
            g_ng_indicator,
            ussgl_account,
            exch_non_exch,
            cust_non_cust,
            budget_subfunction,
            fund_value,
            ccid,
            account_type,
            period_num;

  fnd_file.put_line(fnd_file.log , 'Completed inserting records into FV_FACTS_REPORT_T2 ' || SQL%ROWCOUNT);

  commit;

  EXCEPTION

      WHEN OTHERS THEN
      gbl_error_code := SQLCODE;
      gbl_error_buf := SQLERRM || '-- [JOURNAL_PROCESS]';
      fnd_file.put_line(fnd_file.log , gbl_error_buf);
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',gbl_error_buf);
 END JOURNAL_PROCESSES;

--------------------------------------------------------------------------------------------------------
PROCEDURE TRIAL_BALANCE_MAIN (p_errbuf	       OUT NOCOPY Varchar2,
			      p_retcode        OUT NOCOPY Number,
			      p_sob	    	   Gl_ledgers_public_v.ledger_id%TYPE,
			      p_coa	    	   Gl_Code_Combinations.chart_of_accounts_id%TYPE,
			      p_fund_range_low	   Fv_Fund_Parameters.fund_value%TYPE,
			      p_fund_range_high	   Fv_Fund_Parameters.fund_value%TYPE,
			      p_currency_code	   Varchar2,
			      p_period_name 	   Varchar2,
			      p_report_id 	   Number,
			      p_attribute_set	   Varchar2,
			      p_output_format	   Varchar2)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'TRIAL_BALANCE_MAIN';
  l_printer_name    Varchar2(240) := Fnd_Profile.value('PRINTER');
  l_copies          Number        := Fnd_Profile.value('CONC_COPIES');
  l_print_option    Boolean;
  l_report_type     Varchar2(100);
  l_req_id          Number;
  l_jrnl_exists   Varchar2(1);
  l_errbuf varchar2(500);
  l_retcode varchar2(50);
  l_sob_name        gl_ledgers.name%TYPE;
BEGIN
   p_errbuf  := NULL;
   p_retcode := 0;
   gbl_error_code := 0;

   -- Store the passed set of books id and chart of accounts id
   -- in the global variables
   gbl_set_of_books_id       := p_sob;
   gbl_coa_id                := p_coa;
   gbl_trial_balance_type    := 'F';
   gbl_fund_range_low        := p_fund_range_low;
   gbl_fund_range_high       := p_fund_range_high;
   gbl_currency_code	     := p_currency_code;
   gbl_report_id	     := p_report_id;
   gbl_attribute_set	     := p_attribute_set;
   gbl_output_format	     := p_output_format;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SET OF BOOKS ID - '|| GBL_SET_OF_BOOKS_ID);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CURRENCY CODE - '|| GBL_CURRENCY_CODE);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'PERIOD NAME - '|| P_PERIOD_NAME);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRIAL BALANCE TYPE - '|| GBL_TRIAL_BALANCE_TYPE);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FUND RANGE LOW - '|| GBL_FUND_RANGE_LOW);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FUND RANGE HIGH - '|| GBL_FUND_RANGE_HIGH);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'REPORT ID - '|| GBL_REPORT_ID);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ATTRIBUTE SET - '|| GBL_ATTRIBUTE_SET);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'OUTPUT FORMAT - '|| GBL_OUTPUT_FORMAT);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
    END IF;

    --Getting the period number
    BEGIN
         SELECT period_num, period_year
         INTO   gbl_period_num_high, gbl_fiscal_year
         FROM   gl_period_statuses
         WHERE  period_name = p_period_name
         AND    application_id = 101
         AND    closing_status NOT IN ('F','N')
         AND    ledger_id = gbl_set_of_books_id;

         gbl_period_name := p_period_name;
         gbl_period_year := gbl_fiscal_year;

         SELECT MIN(period_num)
         INTO  gbl_period_num_low
         FROM  gl_period_statuses
         WHERE period_year = gbl_fiscal_year
         AND   application_id = 101
         AND   closing_status <> 'F'
         AND   closing_status <> 'N'
         AND   adjustment_period_flag = 'N'
         AND   ledger_id = gbl_set_of_books_id;


     EXCEPTION
         WHEN NO_DATA_FOUND THEN
   	    gbl_error_code := -1;
            gbl_error_buf  := l_module_name||' No data found getting period num/year.';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_error_buf);

         WHEN OTHERS THEN
            gbl_error_code := -1;
            gbl_error_buf  := l_module_name||' When others error getting period num/year.';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);
    END;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Period Num - '||gbl_period_num);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Period Year - '||gbl_period_year);
    END IF;

   -- Purge Temp tables
   CLEANUP_PROCESS;

--   get_segment_names;

    IF gbl_error_code = 0 THEN
      fv_utility.log_mesg('Calling Facts Attributes Creation process.');
     SET_UP_FACTS_ATTRIBUTES(l_errbuf ,
                             l_retcode ,
                             gbl_set_of_books_id ,
                             gbl_fiscal_year);
     gbl_error_code := l_retcode;
     gbl_error_buf := l_errbuf;
    END IF;


 ------------------------------------
/*
   IF (gbl_error_code = 0)
   THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ENTERING JOURNAL_PROCESS ...');
      END IF;
     JOURNAL_PROCESSES;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'LEAVING JOURNAL_PROCESS ...');
      END IF;
 END IF;
*/
-------------------------

   IF (gbl_error_code = 0)
   THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ENTERING ROLLUP_PROCESS ...');
      END IF;
      ROLLUP_PROCESS;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'LEAVING ROLLUP_PROCESS ...');
      END IF;
   END IF;

   IF (gbl_error_code = 0)
   THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' ');
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'LAUNCHING THE FACTS I TRIAL BALANCE RXI REPORT ...');
      END IF;
      --Get the ledger name to be printed
      --on the rxi report, using this select
      --since teh profile was getting a different
      --sob name.
      SELECT name
      INTO   l_sob_name
      FROM   gl_ledgers
      WHERE  ledger_id = gbl_set_of_books_id
      AND    currency_code = 'USD';

      l_print_option := FND_REQUEST.SET_PRINT_OPTIONS (printer    => l_printer_name,
                                                       copies     => l_copies);

      l_req_id := FND_REQUEST.SUBMIT_REQUEST
                    ('FV','RXFVF1TB','','',FALSE,
                     'DIRECT', gbl_report_id, gbl_attribute_set, gbl_output_format,
		     --FND_PROFILE.VALUE('GL_SET_OF_BKS_NAME'),
         l_sob_name,
         gbl_currency_code,
		     gbl_fund_range_low, gbl_fund_range_high, p_period_name );

      IF (l_req_id = 0)
      THEN
         gbl_error_buf := '** Cannot submit FACTS I Trial Balance RXi report **';
         gbl_error_code := '-1';
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error4',gbl_error_buf);
      ELSE
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'REPORT REQUEST ID = '||L_REQ_ID);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'');
        END IF;
      END IF;
   END IF;

   IF (gbl_error_code <> 0)
   THEN
      p_errbuf := gbl_error_buf;
      p_retcode := -1;
      ROLLBACK;
   ELSE
      COMMIT;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      p_retcode   := '-1' ;
      p_errbuf    := SQLERRM ||
		     ' -- Error in Trial_Balance_Main';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',p_errbuf);
END TRIAL_BALANCE_MAIN;
--------------------------------------------------------------------------------
--                 PROCEDURE ROLLUP_PROCESS
--------------------------------------------------------------------------------
-- Rollup_Process get called from Trial_Balance_Main procedure.
-- The purpose of this procedure is to build a 'group by' clause using
-- segments chosen in an attribute set of RXi. This procedure also does
-- rollup of the trial balance records in fv_facts_report_t2 table by
-- the SEGMENTS.
-- ---------------------------------------------------------------------
PROCEDURE ROLLUP_PROCESS
IS
  l_module_name VARCHAR2(200) := g_module_name || 'ROLLUP_PROCESS';
   l_group_by VARCHAR2(1000);
   l_statement VARCHAR2(5000);

   CURSOR c_group IS
	SELECT column_name
        FROM   fa_rx_rep_columns_b
        WHERE  report_id = gbl_report_id
        AND    attribute_set = gbl_attribute_set
        AND    break = 'Y';
BEGIN
   FOR crec IN c_group
   LOOP
      IF crec.column_name like 'SEGMENT%'
      THEN
         l_group_by := l_group_by || ',' || 'gcc.' || crec.column_name;
      END IF;
   END LOOP;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'  GROUP BY CLAUSE IS: '|| L_GROUP_BY);
 END IF;

fv_utility.log_mesg('GROUP BY CLAUSE IS: '|| L_GROUP_BY);

   l_statement := '
   INSERT INTO fv_facts_report_t2
      ( fund_group,
	account_number,
	dept_id,
	bureau_id,
	d_c_indicator,
        eliminations_dept,
        g_ng_indicator,
        amount,
        record_category,
        ussgl_account,
        set_of_books_id,
        exch_non_exch,
        cust_non_cust,
        budget_subfunction,
        fund_value,
        beginning_balance,
	dr_amount,
	cr_amount '||replace(l_group_by,'gcc.','')||')
    (SELECT 0,
	    account_number,
	    '||''''||'0'||''''||',
	    '||''''||'0'||''''||',
	    '||''''||'N'||''''||',
            eliminations_dept,
            g_ng_indicator,
            0,
            '||''''||'TRIAL_BAL'||''''||',
            ussgl_account,
            :gbl_set_of_books_id,
            exch_non_exch,
            cust_non_cust,
            budget_subfunction,
            fund_value,
            --SUM(beginning_balance),
            SUM(period_begin_bal),
	    SUM(nvl(period_dr,0)),
	    SUM(nvl(period_cr,0)) '|| l_group_by ||'
     FROM fv_facts_period_balances_tb_v t2, gl_code_combinations gcc
     WHERE t2.set_of_books_id = :gbl_set_of_books_id
      AND t2.ccid = gcc.code_combination_id
      AND t2.period_num <= :gbl_period_num_high
      AND t2.period_year = :gbl_fiscal_year
     AND (period_begin_bal <> 0 OR
           period_dr <> 0 OR
           period_cr <> 0)
     AND   fund_value BETWEEN :gbl_fund_range_low AND :gbl_fund_range_high
     GROUP BY account_number, eliminations_dept,
	      g_ng_indicator, ussgl_account, exch_non_exch, cust_non_cust, budget_subfunction,
              --period_num, bug 8498455
              fund_value'|| l_group_by ||')';

fv_utility.log_mesg(l_statement);
fv_utility.log_mesg('l_group_by: '||l_group_by);
fv_utility.log_mesg('gbl_period_num_high: '||gbl_period_num_high);
fv_utility.log_mesg('gbl_fiscal_year: '||gbl_fiscal_year);
fv_utility.log_mesg('gbl_fund_range_low: '||gbl_fund_range_low);
fv_utility.log_mesg('gbl_fund_range_high: '||gbl_fund_range_high);

     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'
         EXECUTING FOLLOWING STATEMENT IN THE ROLLUP PROCESS, STATMENT LENGTH IS ... '||LENGTH(L_STATEMENT));
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,L_STATEMENT);
     END IF;

     EXECUTE IMMEDIATE l_statement USING gbl_set_of_books_id, gbl_set_of_books_id, gbl_period_num_high, gbl_fiscal_year, gbl_fund_range_low, gbl_fund_range_high;

     DELETE FROM fv_facts_report_t2
     WHERE record_category <> 'TRIAL_BAL'
     AND set_of_books_id = gbl_set_of_books_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      gbl_error_code := -1;
      gbl_error_buf  := SQLERRM ||
                        ' -- Error in Rollup_Process';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_error_buf);

   WHEN OTHERS THEN
      gbl_error_code := -1 ;
      gbl_error_buf  := SQLERRM ||
                        ' -- Error in Rollup_Process';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
            '.final_exception',gbl_error_buf);
END ROLLUP_PROCESS;
--------------------------------------------------------------------------------
PROCEDURE SET_UP_FACTS_ATTRIBUTES(p_err_buf OUT NOCOPY VARCHAR2,
	                          p_err_code OUT NOCOPY NUMBER,
                                  p_set_of_books_id IN NUMBER,
                                  p_period_year IN NUMBER)
IS

l_module_name VARCHAR2(200);
l_acct_type_condition VARCHAR2(2500);

l_bal_segment     VARCHAR2(30);
l_bal_segment_prv  VARCHAR2(30);
l_period_begin_bal fv_facts_report_t2.amount%TYPE;
l_period_cy_bal    fv_facts_report_t2.amount%TYPE;
l_period_cy_cr_bal fv_facts_report_t2.amount%TYPE;
l_begin_bal        fv_facts_report_t2.amount%TYPE;
l_curr_year_balance    fv_facts_report_t2.amount%TYPE;
l_t2_deail_amount    fv_facts_report_t2.amount%TYPE;
l_ending_amount    fv_facts_report_t2.amount%TYPE;

l_exists      VARCHAR2(1);
l_stage      VARCHAR2(25);
l_fg_null     VARCHAR2(1);

TYPE t_ref_cur IS REF CURSOR ;
t1_record_c  t_ref_cur ;

TYPE l_account_number_t is table of  VARCHAR2(30);
TYPE l_fund_value_t is table of     VARCHAR2(30);
TYPE l_fund_group_t is table of  fv_treasury_symbols.fund_group_code%TYPE;
TYPE l_dept_id_t is table of     fv_treasury_symbols.department_id%TYPE;
TYPE l_bureau_id_t is table of   fv_treasury_symbols.bureau_id%TYPE;
TYPE l_sgl_acct_num_t is table of        VARCHAR2(4);
TYPE l_govt_non_govt_ind_t is table of   VARCHAR2(1);
TYPE l_exch_non_exch_t is table of       VARCHAR2(1);
TYPE l_cust_non_cust_t is table of       VARCHAR2(1);
TYPE l_exception_status_t is table of    VARCHAR2(1);
TYPE l_budget_subfunction_t is table of  VARCHAR2(3);
TYPE l_ene_exception_t is table of       VARCHAR2(25);
TYPE l_cnc_exception_t is table of       VARCHAR2(25);
TYPE l_bsf_exception_t is table of       VARCHAR2(25);
TYPE l_exception_category_t is table of  VARCHAR2(25);
TYPE l_account_type_t is table of        VARCHAR2(1);
TYPE l_balance_amoun_t is table of      number;
TYPE l_ccid_t is table of               number(15);
TYPE l_rowid_t is table of              ROWID;

l_account_number_L l_account_number_t ;
l_fund_value_l l_fund_value_t;
l_fund_group_l l_fund_group_t;
l_dept_id_l l_dept_id_t;
l_bureau_id_l l_bureau_id_t;
l_sgl_acct_num_l l_sgl_acct_num_t;
l_govt_non_govt_ind_l l_govt_non_govt_ind_t;
l_exch_non_exch_l     l_exch_non_exch_t;
l_cust_non_cust_l    l_cust_non_cust_t;
l_exception_status_l   l_exception_status_t;
l_budget_subfunction_l l_ene_exception_t;
l_exception_category_l l_exception_category_t;
l_account_type_l       l_account_type_t;
l_new_record_l         l_account_type_t;
l_balance_amoun_l      l_balance_amoun_t;
l_begin_bal_l          l_balance_amoun_t;
l_per_begin_bal_l      l_balance_amoun_t;
l_cy_dr_bal_l          l_balance_amoun_t;
l_cy_cr_bal_l          l_balance_amoun_t;
l_ccid_l 	       l_ccid_t;
l_rowid_l	       l_rowid_t;

--l_ene_exception_l      l_cnc_exception_t;
--l_cnc_exception_l      l_bsf_exception_t;
--l_bsf_exception_l      l_bsf_exception_t;

l_account_number_n l_account_number_t ;
l_fund_value_n 	   l_fund_value_t;
l_fund_group_n     l_fund_group_t;
l_dept_id_n 	   l_dept_id_t;
l_bureau_id_n       l_bureau_id_t;
l_sgl_acct_num_n       l_sgl_acct_num_t;
l_govt_non_govt_ind_n l_govt_non_govt_ind_t;
l_exch_non_exch_n     l_exch_non_exch_t;
l_cust_non_cust_n     l_cust_non_cust_t;
l_exception_status_n   l_exception_status_t;
l_budget_subfunction_n l_budget_subfunction_t;
l_exception_category_n l_exception_category_t;
l_account_type_n       l_account_type_t;
l_new_record_n         l_account_type_t;
l_balance_amoun_n      l_balance_amoun_t;
l_begin_bal_n          l_balance_amoun_t;
l_per_begin_bal_n      l_balance_amoun_t;
l_cy_dr_bal_n          l_balance_amoun_t;
l_cy_cr_bal_n          l_balance_amoun_t;
l_ccid_n               l_ccid_t;
l_indx   binary_integer;



l_account_number  VARCHAR2(30);
l_fund_value      VARCHAR2(30);
l_fund_group      fv_treasury_symbols.fund_group_code%TYPE;
l_dept_id        fv_treasury_symbols.department_id%TYPE;
l_bureau_id       fv_treasury_symbols.bureau_id%TYPE;
l_sgl_acct_num    VARCHAR2(4);
l_govt_non_gov    VARCHAR2(1);
l_exch_non_exch       VARCHAR2(1);
l_cust_non_cust       VARCHAR2(1);
l_exception_status    VARCHAR2(1);
l_budget_subfunction  VARCHAR2(3);
l_ene_exception       VARCHAR2(25);
l_cnc_exception       VARCHAR2(25);
l_bsf_exception       VARCHAR2(25);
l_exception_category  VARCHAR2(25);
l_account_type     VARCHAR2(1);
l_balance_amount   number;
l_curr_year_bal   number;
l_ccid              number(15);
l_govt_non_govt_ind  varchar2(1);

l_account_number_prv  VARCHAR2(30);
l_t2_detail_amount    NUMBER;
l_fed_account         VARCHAR2(1);
l_amount              NUMBER;
l_jrnl_run_flag       VARCHAR2(1);
l_select_stmt VARCHAR2(10000);
l_select_stmt2 VARCHAR2(10000);
l_last_fetch BOOLEAN;

l_int_run_month NUMBER;
l_period_num_high NUMBER;
l_period_num_low NUMBER;
l_rec_count       NUMBER;
l_run_status VARCHAR2(1);
l_populate_flag VARCHAR2(1);
l_parameters VARCHAR2(500);
l_exception_count NUMBER;
l_diff_flag varchar2(1);


BEGIN

    p_err_code := 0;
    p_err_buf := null;
    l_module_name := g_module_name||'SET_UP_FACTS_ATTRIBUTES';
    FV_UTILITY.LOG_MESG('In '||l_module_name);

    gbl_set_of_books_id := p_set_of_books_id;
    gbl_fiscal_year := p_period_year;


  begin
    select decode(period_num,null,'Y',0,'Y','N'),period_num into
    l_populate_flag, l_int_run_month
  from  fv_facts1_run
    WHERE  set_of_books_id = gbl_set_of_books_id
    AND    fiscal_year = p_period_year;
   exception
   when no_data_found then
    l_populate_flag := 'Y';
  End;

    FV_UTILITY.LOG_MESG('Deleting records from fv_facts_report_t2.');
    DELETE FROM fv_facts_report_t2
    WHERE  set_of_books_id = gbl_set_of_books_id;


    GET_SEGMENT_NAMES;

/*
  IF gbl_trial_balance_type = 'F' then
    SELECT MAX(period_num)
    INTO   l_period_num_high
    FROM  gl_period_statuses
    WHERE period_year = p_period_year
    AND   application_id = 101
    AND   closing_status <> 'F'
    AND   closing_status <> 'N'
    AND   ledger_id = gbl_set_of_books_id;

    SELECT MIN(period_num)
    INTO   l_period_num_low
    FROM  gl_period_statuses
    WHERE period_year = p_period_year
    AND   application_id = 101
    AND   closing_status <> 'F'
    AND   closing_status <> 'N'
    AND   adjustment_period_flag = 'N'
    AND   ledger_id = gbl_set_of_books_id;

    SELECT period_name
    INTO   gbl_period_name
    FROM  gl_period_statuses
    WHERE period_year = p_period_year
    AND   application_id = 101
    AND   period_num = l_period_num_high
    AND   ledger_id = gbl_set_of_books_id;

     else
	l_period_num_high := gbl_period_num_high;
	l_period_num_low := gbl_period_num_low;
    END IF;
*/


        l_period_num_high := gbl_period_num_high;
        l_period_num_low := gbl_period_num_low;


    FV_UTILITY.LOG_MESG('Period Num Low: '||l_period_num_low);
    FV_UTILITY.LOG_MESG('Period Num High: '||l_period_num_high);
    FV_UTILITY.LOG_MESG('High Period Name:  '||gbl_period_name);


    SELECT currency_code
    INTO   gbl_currency_code
    FROM   gl_ledgers_public_v
    WHERE  ledger_id  = gbl_set_of_books_id;
    FV_UTILITY.LOG_MESG('Currency Code:  '||gbl_currency_code);

    l_acct_type_condition := ' AND glc.account_type NOT IN ('||''''||'D'||''''||', '||''''||'C'||''''||')';
    --Bug 8498455
    --Bug 9649419
    --l_acct_type_condition := ' ';

     l_parameters :=  p_period_year||', '|| l_period_num_high||', '||''''||gbl_period_name||''''||', '||
                  gbl_set_of_books_id||', ';
    l_select_stmt2 := '  glb.code_combination_id, ' ||
                  ' glc.' || gbl_bal_segment_name || ' , glc.' || gbl_acc_segment_name ||
                  ', ''NO'', ''#'', ''#'', ''#'', ''#'', ''#'', ''#'', ''#'', ''E'', -99 ,''N'',
                    SUM (DECODE (period_num, :gbl_period_num_high,
                            (begin_balance_dr - begin_balance_cr + NVL(period_net_dr,0)
                                  - NVL(period_net_cr,0)),0)) curr_year_bal,
                   SUM (DECODE (period_num, :gbl_period_num_low,
                               (begin_balance_dr - begin_balance_cr),0)) begin_bal,
                   SUM (DECODE (period_num, :gbl_period_num_high,
                                  (NVL(period_net_dr,0)),0)) period_cy_bal,
                   SUM (DECODE (period_num, :gbl_period_num_high,
                                  (NVL(period_net_cr,0)),0)) period_cy_cr_bal,
                   SUM (DECODE (period_num, :gbl_period_num_high,
                               (begin_balance_dr - begin_balance_cr),0)) period_begin_bal '||
            ' FROM  gl_balances glb,gl_code_combinations GLC
           WHERE glb.actual_flag = '||''''||'A'||''''||'
           AND   period_year = :gbl_fiscal_year
           AND   period_num IN (:gbl_period_num_low, :gbl_period_num_high)
           AND   glb.ledger_id = :gbl_set_of_books_id
           AND   glb.template_id is NULL
           AND   glb.currency_code = :gbl_currency_code
           AND   glc.code_combination_id = glb.code_combination_id '
           || l_acct_type_condition
           ||' GROUP BY glb.code_combination_id ,'||'glc.'||gbl_bal_segment_name
           ||', glc.' || gbl_acc_segment_name
           ||'  ORDER BY '||'glc.'||gbl_bal_segment_name ||', glc.' || gbl_acc_segment_name;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'l_select_stmt: '||l_select_stmt);
    END IF;


        l_account_number_n := l_account_number_t(null);
        l_fund_value_n     :=  l_fund_value_t(null);
        l_fund_group_n     :=  l_fund_group_t(null);
        l_dept_id_n       := l_dept_id_t(null);
        l_bureau_id_n     :=  l_bureau_id_t(null);
        l_sgl_acct_num_n    :=  l_sgl_acct_num_t(null);
        l_govt_non_govt_ind_n :=  l_govt_non_govt_ind_t(null);
        l_exch_non_exch_n     :=  l_exch_non_exch_t(null);
        l_cust_non_cust_n :=  l_cust_non_cust_t(null);
        l_exception_status_n :=  l_exception_status_t(null);
        l_budget_subfunction_n :=  l_budget_subfunction_t(null);
        l_exception_category_n:=  l_exception_category_t(null);
        l_account_type_n    :=  l_account_type_t(null);
        l_balance_amoun_n    :=  l_balance_amoun_t(null);
        l_begin_bal_n    :=  l_balance_amoun_t(null);
        l_per_begin_bal_n    :=  l_balance_amoun_t(null);
        l_cy_dr_bal_n    :=  l_balance_amoun_t(null);
        l_cy_cr_bal_n    :=  l_balance_amoun_t(null);
        l_ccid_n:=  l_ccid_t(null);

	l_account_number_n.extend(10000);
	l_fund_value_n.extend(10000);
	l_fund_group_n.extend(10000);
	l_dept_id_n.extend(10000);
	l_bureau_id_n.extend(10000);
	l_sgl_acct_num_n.extend(10000);
	l_govt_non_govt_ind_n.extend(10000);
	l_exch_non_exch_n.extend(10000);
	l_cust_non_cust_n.extend(10000);
	l_exception_status_n.extend(10000);
	l_budget_subfunction_n.extend(10000);
	l_exception_category_n.extend(10000);
	l_account_type_n.extend(10000);
	l_balance_amoun_n.extend(10000);
	l_begin_bal_n.extend(10000);
	l_per_begin_bal_n.extend(10000);
	l_cy_dr_bal_n.extend(10000);
	l_cy_cr_bal_n.extend(10000);
	l_ccid_n.extend(10000);

  l_select_stmt2 := ' SELECT  ' || l_select_stmt2;
   fnd_file.put_line(fnd_file.log, l_select_stmt2);
  l_bal_segment_prv := '####';
  gbl_prev_acct     := '####';
  gbl_bal_segment   := '####';
  gbl_error_code   := 0;
  gbl_error_buf   := NULL;
  l_jrnl_run_flag := 'N';
  l_rec_count := 0;


  --------------------------------------------------


 /* check already being_bal differnce processed */

        l_diff_flag := 'N';

       begin
         select NVL(begin_bal_diff_flag , 'N')  into l_diff_flag
         from fv_facts1_run
         where set_of_books_id = gbl_set_of_books_id
         and   fiscal_year = gbl_fiscal_year;

         -- To delete the erroneous record
         fnd_file.put_line(fnd_file.log,
          'Deleting the begin balance difference records from fv_facts1_diff_balances.');

         if l_diff_flag = 'N' then
	   DELETE FROM fv_facts1_diff_balances
	   WHERE  set_of_books_id = gbl_set_of_books_id
           and   period_year = gbl_fiscal_year
           and balance_type = 'B';
         end if;

      exception
       when no_data_found then
       l_diff_flag := 'N';
      End;

  --------------------------------------------------
  fund_group_info_setup;


  IF gbl_error_code <> 0 THEN
     ROLLBACK;
     RETURN;
  END IF;

-----------------------------------------------

  OPEN t1_record_c for l_select_stmt2 USING
              l_period_num_high,
              l_period_num_low,
              l_period_num_high, l_period_num_high, l_period_num_high,
              gbl_fiscal_year, l_period_num_low, l_period_num_high,gbl_set_of_books_id,
              gbl_currency_code;

     l_last_fetch := FALSE;

  LOOP

  FETCH t1_record_c BULK COLLECT INTO  l_ccid_l, l_fund_value_l,l_account_number_l,
          l_sgl_acct_num_l,
          l_exch_non_exch_l,
          l_cust_non_cust_l,
          l_account_type_l,
          l_budget_subfunction_l,
          l_dept_id_l,
          l_bureau_id_l,
          l_govt_non_govt_ind_l,
          l_exception_status_l,
          l_fund_group_l,
          l_new_record_l,
          l_balance_amoun_l,
          l_begin_bal_l ,
          l_cy_dr_bal_l ,
          l_cy_cr_bal_l,
          l_per_begin_bal_l    LIMIT 10000;


     IF t1_record_c%NOTFOUND THEN
        l_last_fetch := TRUE;
     END IF;

    l_indx := 0;

   fv_utility.log_mesg('in Deriving attributes ');
     IF (l_ccid_l.count = 0 AND l_last_fetch) THEN
       EXIT;
     END IF;

   FOR i IN l_ccid_l.first .. l_ccid_l.last

   LOOP

   begin
   select  'N' into l_new_record_l(i)
   from fv_facts1_period_attributes
   where ccid = l_ccid_l(i)
   and   period_year = gbl_fiscal_year
   and   set_of_books_id = gbl_set_of_books_id;
   exception
    when no_data_found then
   l_new_record_l(i) := 'Y';
   End;


     l_exception_status      := NULL;
     l_exception_status_l(i) := NULL;

     l_account_number := l_account_number_l(i);
     l_fund_value     := l_fund_value_l(i);
     l_ccid           := l_ccid_l(i);
     l_balance_amount := l_balance_amoun_l(i);
     l_exception_status := 'E';
     l_exception_status_l(i) := 'E';

     l_bal_segment    := l_fund_value;


     IF (l_bal_segment  <> l_bal_segment_prv) THEN
        GET_FUND_GROUP_INFO(l_fund_value, l_exists, l_fg_null,
                            l_fund_group, l_dept_id, l_bureau_id);
        --l_bal_segment_prv  := l_bal_segment;
     END IF;

     IF gbl_error_code <> 0 THEN
        RETURN;
     END IF;


     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            '---------------------------------');
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Fund Value: '||l_fund_value);
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Account Number: '|| l_account_number);
    END IF;

     IF  (l_exists = 'N') THEN
          l_fg_null := 'Y';
          l_fund_group := NULL;
          l_dept_id := NULL;
          l_bureau_id := NULL;
          l_fund_group_l(i) := NULL;
          l_dept_id_l(i) := NULL;
          l_bureau_id_l(i) := NULL;
      ELSIF (l_bureau_id IS NULL) THEN
          l_bureau_id := '00';
          l_bureau_id_l(i) := '00';
     END IF;

     IF (l_fg_null = 'Y') THEN


        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Fund group is null.');
        END IF;

        POPULATE_TEMP2(0000, ' ', '0', '0', '', '',  l_balance_amount, 'D',
                       p_period_year, 'NO_FUND_GROUP', '',
                       gbl_set_of_books_id, 'E',
                       '', '', '', l_bal_segment, 0, '',
                       '', '', 0, 0);

        IF gbl_error_code <> 0 THEN
           p_err_code := gbl_error_code;
           p_err_buf := gbl_error_buf ;
           RETURN ;
        END IF;
        l_exception_status := 'E';
        l_exception_status_l(i) := 'E';

     END IF;

     IF (l_fg_null = 'N') THEN -- 0

          l_bureau_id_l(i) := l_bureau_id;
          l_fund_group_l(i):= l_fund_group;
          l_dept_id_l(i)   := l_dept_id;

        IF  (gbl_prev_acct <> l_account_number  or l_bal_segment  <> l_bal_segment_prv)  then

           GET_USSGL_ACCT_NUM(l_account_number,
                          l_fund_value, l_sgl_acct_num,
                          l_govt_non_govt_ind, l_exch_non_exch,
                          l_cust_non_cust, l_budget_subfunction,
                          l_ene_exception, l_cnc_exception,
                          l_bsf_exception, l_exception_category);

            IF (gbl_error_code <> 0) THEN
                 p_err_code := gbl_error_code;
                 p_err_buf := gbl_error_buf ;
                 FV_UTILITY.LOG_MESG('An error occurred in GET_USSGL_ACCT_NUM.
                   No further processing of FACTS 1  will be done.');
                 RETURN;
            END IF;

             -- Get the Account Type
            l_account_type := GET_ACCOUNT_TYPE(l_account_number);
            l_account_type_l(I) := l_account_type;

            gbl_prev_acct   := l_account_number;
            gbl_bal_segment := l_fund_value;
       END IF;


              l_govt_non_govt_ind_l(i) :=  l_govt_non_govt_ind;
              l_exch_non_exch_l(i)     :=  l_exch_non_exch;
              l_cust_non_cust_l(i)     :=  l_cust_non_cust;
              l_budget_subfunction_l(i):=  l_budget_subfunction;
              l_account_type_l(I)      := l_account_type;
              l_sgl_acct_num_l(I)      := l_sgl_acct_num;

       IF (l_exception_category IN ('PROP_ACCT_NOT_SETUP',    --1
            'PROP_ACCT_FACTSII', 'USSGL_DISABLED',
            'NON_USSGL_ACCT', 'USSGL_MULTIPLE_PARENTS')) THEN

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Exception: '||l_exception_category);
          END IF;

          -- Account segment did not pass SGL validation.
          -- Insert into T2 as an exception
          POPULATE_TEMP2(l_fund_group, l_account_number, l_dept_id,
                     l_bureau_id , '', '', l_balance_amount,
                     'D', p_period_year, l_exception_category,
                     l_sgl_acct_num, gbl_set_of_books_id, 'E',
                     '', '', '', l_fund_value, 0, l_ccid,
                     l_account_type, '', 0, 0);

          IF gbl_error_code <> 0 THEN
             p_err_code := gbl_error_code;
             p_err_buf := gbl_error_buf ;
             RETURN;
          END IF;

          l_exception_status := 'E';
          l_exception_status_l(i) := 'E';

        ELSIF ((l_ene_exception IS NOT NULL) OR   --1
               (l_cnc_exception IS NOT NULL) OR
               (l_bsf_exception IS NOT NULL)) THEN
          IF (l_ene_exception IS NOT NULL) THEN
             POPULATE_TEMP2(l_fund_group, l_account_number,
                   l_dept_id, l_bureau_id, '', '', l_balance_amount,
                   'N', p_period_year, l_ene_exception, l_sgl_acct_num,
                   gbl_set_of_books_id, 'E', '', '', '',
                   l_fund_value, 0, l_ccid, l_account_type, '', 0, 0);

             IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
               'Exception: '||l_ene_exception);
             END IF;

          END IF;

          IF (l_cnc_exception IS NOT NULL) THEN
               POPULATE_TEMP2(l_fund_group, l_account_number,
                   l_dept_id, l_bureau_id, '', '', l_balance_amount,
                   'N', p_period_year, l_cnc_exception, l_sgl_acct_num,
                   gbl_set_of_books_id, 'E', '', '', '',
                   l_fund_value, 0, l_ccid, l_account_type, '', 0, 0);

               IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                 'Exception: '||l_cnc_exception);
               END IF;

          END IF;

          IF (l_bsf_exception IS NOT NULL) THEN
             POPULATE_TEMP2(l_fund_group, l_account_number,
                   l_dept_id, l_bureau_id, '', '', l_balance_amount,
                   'N', p_period_year, l_bsf_exception, l_sgl_acct_num,
                   gbl_set_of_books_id, 'E', '', '', '',
                   l_fund_value, 0, l_ccid, l_account_type, '', 0, 0);

             IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                 'Exception: '||l_bsf_exception);
             END IF;

          END IF;

          IF gbl_error_code <> 0 THEN
             p_err_code := gbl_error_code;
             p_err_buf := gbl_error_buf ;
             RETURN;
          END IF;

          l_exception_status      := 'E';
          l_exception_status_l(i) := 'E';

       ELSE   --1
fv_utility.log_mesg('*****no exception');
fv_utility.log_mesg('*****l_govt_non_govt_ind:'||l_govt_non_govt_ind);


           IF l_govt_non_govt_ind IN ('N', 'X') THEN
                l_exception_status := '1' ;
                l_exception_status_l(i) := '1' ;
             ELSE
                l_exception_status     := '2' ;
                l_exception_status_l(i) := '2' ;
           END IF;
     END IF; --  1 exception_cateogry
    END IF; --  0 l_fg_null = 'N'

     l_bal_segment_prv  := l_bal_segment;
    l_rec_count := l_rec_count + 1;

   /* Insert the new ccid  */

    If l_new_record_l(i) = 'Y' then
        l_indx := l_indx + 1;
	l_account_number_n(l_indx) := l_account_number_l(i);
	l_fund_value_n(l_indx)     :=  l_fund_value_l(i);
	l_fund_group_n(l_indx)     :=  l_fund_group_l(i);
	l_dept_id_n(l_indx)       := l_dept_id_l(i);
	l_bureau_id_n(l_indx)     :=  l_bureau_id_l(i);
	l_sgl_acct_num_n(l_indx)    :=  l_sgl_acct_num_l(i);
	l_govt_non_govt_ind_n(l_indx) :=  l_govt_non_govt_ind_l(i);
	l_exch_non_exch_n(l_indx)     :=  l_exch_non_exch_l(i);
	l_cust_non_cust_n(l_indx) :=  l_cust_non_cust_l(i);
	l_exception_status_n(l_indx) :=  l_exception_status_l(i);
	l_budget_subfunction_n(l_indx) :=  l_budget_subfunction_l(i);
	l_account_type_n(l_indx)    :=  l_account_type_l(i);
	l_balance_amoun_n(l_indx)    :=  l_balance_amoun_l(i);
	l_begin_bal_n(l_indx)    :=  l_begin_bal_l(i);
	l_per_begin_bal_n(l_indx)    :=  l_per_begin_bal_l(i);
	l_cy_dr_bal_n(l_indx)    :=  l_cy_dr_bal_l(i);
	l_cy_cr_bal_n(l_indx)    :=  l_cy_cr_bal_l(i);
	l_ccid_n(l_indx):=  l_ccid_l(i);
     End if;

 -------------------------------------------------------

     -- create a difference record.

    if (l_exception_status = '2' and  l_govt_non_govt_ind IN ('F', 'Y') ) then

      l_curr_year_balance := l_balance_amoun_l(i) - l_begin_bal_l(i);

         l_stage      := 'Detail difference';

         l_t2_detail_amount   := 0;

             SELECT NVL(SUM(NVL(t2.amount, 0)), 0)
             INTO l_t2_detail_amount
             FROM fv_facts1_line_balances t2
             WHERE t2.ccid = l_ccid_l(i)
             AND   t2.set_of_books_id = gbl_set_of_books_id
             AND   period_num <= gbl_period_num_high
             AND   period_year = gbl_fiscal_year;

             IF (l_curr_year_balance <> l_t2_detail_amount) THEN
fv_utility.log_mesg('*****inserting detail difference record');

                  -- Insert an exception record if there is a difference in the amount
                  POPULATE_TEMP2(l_fund_group,
                               l_account_number,
                               l_dept_id, l_bureau_id,
                               '', '', (l_curr_year_balance - l_t2_detail_amount),
                               '', gbl_period_year, 'LINE_BAL_DIFF',
                               l_sgl_acct_num, gbl_set_of_books_id, 'E',
                               l_exch_non_exch, l_cust_non_cust,
                               l_budget_subfunction, l_fund_value,
                               0, l_ccid_l(i), l_account_type,
                               'Other', 0, 0);

                  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,  'Inserting into fv_facts1_diff_balances values: ');
                     fv_utility.log_mesg('l_ccid_l(i): '||l_ccid_l(i));
                     fv_utility.log_mesg('gbl_period_num_low: '||gbl_period_num_low);
                     fv_utility.log_mesg('gbl_fiscal_year: '||gbl_fiscal_year);
                     fv_utility.log_mesg('gbl_set_of_books_id: '||gbl_set_of_books_id);
                     fv_utility.log_mesg('balance_type: D');
                  END IF;

                     INSERT INTO fv_facts1_diff_balances
                          (
			                     ccid,period_num,period_year,set_of_books_id,
                           eliminations_dept,
                           g_ng_indicator,
                           amount,
                           d_c_indicator,
                           balance_type,
			                      recipient_name,
			                      account_number,
                           fund_value)
                      VALUES
                           (l_ccid_l(i),gbl_period_num_high,gbl_fiscal_year,gbl_set_of_books_id,
                           DECODE(l_govt_non_govt_ind, 'F', '00', '  '),
                           DECODE(l_govt_non_govt_ind, 'F', l_govt_non_govt_ind, 'N'),
                           (l_curr_year_balance - l_t2_detail_amount),
		                        DECODE(SIGN(l_curr_year_balance - l_t2_detail_amount),
                                         0, 'D', 1, 'D', -1, 'C'),
                           'D','Other', l_account_number, l_fund_value);
             END IF;

        -------------------------------------------------------------------------
         -- Populate fv_facts1_diff_balances with previous year's ending balance
         -- and create a difference record

         /* check the begin_balance record been created , if not run it  */

         IF (l_diff_flag = 'N' AND l_account_type IN ('A','L','O')) THEN

             l_ending_amount := 0 ;
             l_stage      := 'Ending balance diff';

                 SELECT NVL(SUM(amount), 0)
                 INTO l_ending_amount
                 FROM fv_facts_ending_balances
                 WHERE ccid = l_ccid_l(i)
                 AND   set_of_books_id = gbl_set_of_books_id
                 AND fiscal_year = (gbl_fiscal_year - 1)
                 AND record_category = 'ENDING_BAL'
                 AND account_number = l_account_number
                 AND dept_id = l_dept_id
                 AND bureau_id = l_bureau_id
                 AND fund_value = l_fund_value
                 AND account_type IN ('A','L','O');

               IF l_begin_bal_l(i) <> l_ending_amount THEN
fv_utility.log_mesg('*****inserting end bal difference record');
                  -- Insert an exception record if there is a difference in the amount
                  POPULATE_TEMP2(l_fund_group,
                               l_account_number,
                               l_dept_id, l_bureau_id,
                               '', '', l_begin_bal_l(i),
                               '', gbl_period_year, 'BEG_BAL_DIFF',
                               l_sgl_acct_num, gbl_set_of_books_id, 'E',
                               l_exch_non_exch, l_cust_non_cust,
                               l_budget_subfunction, l_fund_value,
                               0, l_ccid_l(i), l_account_type,
                               'Other', 0, 0);
                  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,  'Inserting into fv_facts1_diff_balances values: ');
                     fv_utility.log_mesg('l_ccid_l(i): '||l_ccid_l(i));
                     fv_utility.log_mesg('gbl_period_num_low: '||gbl_period_num_low);
                     fv_utility.log_mesg('gbl_fiscal_year: '||gbl_fiscal_year);
                     fv_utility.log_mesg('gbl_set_of_books_id: '||gbl_set_of_books_id);
                     fv_utility.log_mesg('balance_type: B');
                  END IF;

 			             INSERT INTO fv_facts1_diff_balances
                          (ccid,period_num,period_year,set_of_books_id,
                           eliminations_dept,
                           g_ng_indicator,
                           amount,
                           d_c_indicator,
                           balance_type,
                           recipient_name,
                           account_number,
                           fund_value)
                           VALUES
                          (l_ccid_l(i),gbl_period_num_low,gbl_fiscal_year,gbl_set_of_books_id,
                          DECODE(l_govt_non_govt_ind, 'F', '00', '  '),
                          DECODE(l_govt_non_govt_ind, 'F', l_govt_non_govt_ind, 'N'),
                          l_begin_bal_l(i) - l_ending_amount,
                          DECODE(SIGN(l_begin_bal_l(i) - l_ending_amount), 0, 'D', 1, 'D', -1, 'C'),
                          'B', 'Other', l_account_number, l_fund_value);

                END IF; --  Populate Temp2 with previous year's ending bal

          End if; /* diff_flag = 'N' */

     End if; /* excpetion_status =2 and 'G_NG = 'Y' */
----------------------------------------------------
  END LOOP;  /* for i loop */


   FV_UTILITY.log_MESG('Inserting no of new records ' || l_indx);
   FORALL i IN 1 .. l_indx
        INSERT INTO fv_facts1_period_attributes
         ( period_year,
         period_num,
         period_name,
         set_of_books_id,
         ccid,
         fund_value,
         account_number,
         ussgl_account,
         exch_non_exch ,
         cust_non_cust,
         account_type ,
         budget_subfunction,
         dept_id,
         bureau_id,
         g_ng_indicator,
         reported_group,
         fund_group,
        new_rec_flag,
        BALANCE_AMOUNT,
        BEGIN_BALANCE,
        PERIOD_CY_DR_BAL,
        PERIOD_CY_CR_BAL ,
        PERIOD_BEGIN_BAL,
        end_bal_ind
        )
     values (
       gbl_fiscal_year,
       l_period_num_high,
       gbl_period_name,
       gbl_set_of_books_id,
       l_ccid_n(i),
       l_fund_value_n(i),
       l_account_number_n(i),
       l_sgl_acct_num_n(i),
       l_exch_non_exch_n(i),
       l_cust_non_cust_n(i),
       l_account_type_n(i),
       l_budget_subfunction_n(i),
       decode(l_dept_id_n(i) ,NULL, '#', l_dept_id_n(i)),
       decode(l_bureau_id_n(i),NULL, '#' , l_bureau_id_n(i)),
       DECODE(l_govt_non_govt_ind_n(i), 'X', ' ', l_govt_non_govt_ind_n(i)),
       l_exception_status_n(i),
       decode(l_fund_group_n(i), NULL, -99 ,l_fund_group_n(i)),
       'Y',
       l_balance_amoun_n(i),
       l_begin_bal_n(i),
       l_cy_dr_bal_n(i),
       l_cy_cr_bal_n(i),
       l_per_begin_bal_n(i),
       DECODE(l_govt_non_govt_ind_n(i), 'F', 'Y', 'Y', 'Y', 'N')
       );


       -- Update facts attributes in fv_facts1_period_attributes

        FV_UTILITY.log_MESG( 'Updating records ' || (l_ccid_l.count - l_indx));

        FORALL i IN l_ccid_l.first .. l_ccid_l.last
           UPDATE fv_facts1_period_attributes
           SET ussgl_account = l_sgl_acct_num_l(i),
              exch_non_exch = l_exch_non_exch_l(i),
              cust_non_cust = l_cust_non_cust_l(i),
              account_type = l_account_type_l(i),
              budget_subfunction = l_budget_subfunction_l(i),
              fund_group = decode(l_fund_group_l(i), NULL, -99 ,l_fund_group_l(i)),
              dept_id = decode(l_dept_id_l(i) ,NULL, '#', l_dept_id_l(i)),
              bureau_id = decode(l_bureau_id_l(i),NULL, '#' , l_bureau_id_l(i)),
              g_ng_indicator = DECODE(l_govt_non_govt_ind_l(i), 'X', ' ', l_govt_non_govt_ind_l(i)),
	            reported_group = l_exception_status_l(i),
 		          BALANCE_AMOUNT = l_balance_amoun_l(i),
                BEGIN_BALANCE  = l_begin_bal_l(i),
                PERIOD_CY_DR_BAL = l_cy_dr_bal_l(i),
                PERIOD_CY_CR_BAL  = l_cy_cr_bal_l(i),
                PERIOD_BEGIN_BAL =  l_per_begin_bal_l(i),
                period_num       = l_period_num_high,
                period_name      = gbl_period_name,
                end_bal_ind      = DECODE(l_govt_non_govt_ind_l(i), 'F', 'Y', 'Y', 'Y', 'N')
    	      WHERE  ccid = l_ccid_l(i)
              and    period_year = gbl_fiscal_year
              and   set_of_books_id = gbl_set_of_books_id
	      and l_new_record_l(i) = 'N';
  END LOOP;

  FV_UTILITY.LOG_MESG('No of CCID processed ' || l_rec_count);

  IF l_rec_count <> 0 THEN

    l_exception_count := 0;

    -- Count the exception records
    SELECT COUNT(*)
    INTO l_exception_count
    FROM fv_facts_report_t2
    WHERE set_of_books_id = gbl_set_of_books_id
    AND reported_status = 'E'
    and record_category NOT IN ('PROP_ACCT_NOT_SETUP',  'PROP_ACCT_FACTSII',
    'USSGL_DISABLED', 'NO_FUND_GROUP' )
    AND amount <> 0 ;


    if l_exception_count > 0 then
        FV_UTILITY.LOG_MESG('Set up Facts Attributes completed wth exceptions');
        p_err_code := 0;
        p_err_buf := 'Set up Facts Attributes completed with exceptions.';
        l_run_status := 'E';
        --gbl_exception_exists := 'Y';
        --submit_exception_report;
      else
        l_run_status := 'U';
        FV_UTILITY.LOG_MESG('Set up Facts Attributes completed successfully');
        p_err_buf := 'Set up Facts Attributes completed successfully.';
      END IF;

   ELSE -- l_rec_count
     l_run_status := 'U';
     FV_UTILITY.LOG_MESG('No data found for this period year.');
   END IF;


   -- Update fv_facts1_run only if there were records
   -- found for the attribute creation process.
   IF l_rec_count > 0 THEN
      FV_UTILITY.LOG_MESG('Updating facts1 run status.');
     UPDATE fv_facts1_run
     SET    status =  l_run_status,
            process_date = sysdate,
            run_fed_flag = 'I',
            begin_bal_diff_flag = 'Y',
            period_num  = l_period_num_high
     WHERE  set_of_books_id = gbl_set_of_books_id
     AND    fiscal_year     = p_period_year
     AND    table_indicator = 'N';

        IF gbl_error_code <> 0 THEN
          p_err_code := gbl_error_code;
          p_err_buf := gbl_error_buf;
          ROLLBACK;
          RETURN;
        END IF;
   END IF;

  COMMIT;

 EXCEPTION
    WHEN OTHERS THEN
         p_err_code := -1;
         p_err_buf := l_module_name||' When others exception: '
                          ||to_char(SQLCODE) || ' - ' || SQLERRM;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);

END set_up_facts_attributes;
--------------------------------------------------------------------------------
PROCEDURE update_facts1_run(p_period_year     in VARCHAR2,
                            p_set_of_books_id in VARCHAR2)
is
l_module_name VARCHAR2(200);
l_je_header_id   number(15);
l_stage          number(15);
l_posted_date date;

BEGIN

     l_module_name := g_module_name || 'UPDATE_FACTS1_RUN';
     FV_UTILITY.LOG_MESG('In '||l_module_name);

     UPDATE fv_facts1_run
     SET    run_fed_flag = 'A',
            process_date = sysdate
     WHERE  set_of_books_id = p_set_of_books_id
     AND    fiscal_year     = p_period_year
     AND    table_indicator = 'N';

   IF SQL%ROWCOUNT = 0 THEN

   /* Get the je_header_id for the sob and year */

     l_stage := 1;

    select nvl(min(je_header_id),0)
    into l_je_header_id
    from gl_je_headers h
    WHERE  ledger_id = gbl_set_of_books_id
    and    exists (select'x'
    FROM  gl_period_statuses g2
    WHERE g2.period_year = p_period_year
    AND   g2.ledger_id = p_set_of_books_id
    AND   g2.application_id = 101
   and    g2.period_name = h.period_name);

    l_stage := 2;

  if l_je_header_id > 0 then

    select nvl(posted_date,creation_date)
    into l_posted_date
    from gl_je_headers h
    WHERE  je_header_id = l_je_header_id ;

    l_stage := 3;


     SELECT currency_code
     INTO   gbl_currency_code
     FROM   gl_ledgers_public_v
     WHERE  ledger_id = gbl_set_of_books_id;

      if l_posted_date is not null   then

       FV_UTILITY.LOG_MESG('Initialzied fv_facts1_run with ' );
       FV_UTILITY.LOG_MESG(' from period ' || gbl_period_name);
       FV_UTILITY.LOG_MESG(' Header_id    ' || l_je_header_id);
       FV_UTILITY.LOG_MESG(' posted_date ' || l_posted_date );

        INSERT INTO fv_facts1_run(set_of_books_id, fiscal_year, status, table_indicator,process_date,
        run_fed_flag ,je_header_id,posted_date)
        values(gbl_set_of_books_id, p_period_year, 'A', 'N',sysdate,'A' ,
        l_je_header_id ,l_posted_date);
     else
	gbl_error_code := -1;
        gbl_error_buf  := 'Cannot determine the inital header_id';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, gbl_error_buf);
     END IF;
  Else
	gbl_error_code := -1;
        gbl_error_buf  := 'No Journals exist for year '||p_period_year||' for ledger '||p_set_of_books_id;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, gbl_error_buf);
  End if;
  END IF;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        gbl_error_code := -1;
        gbl_error_buf  := SQLERRM || 'In UPDATE_FACTS1_RUN - '|| l_stage  ;
     WHEN OTHERS THEN
        gbl_error_code := -1;
        gbl_error_buf  := SQLERRM || 'When others error in UPDATE_FACTS1_RUN - '||SQLERRM;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, gbl_error_buf);

END update_facts1_run;
--------------------------------------------------------------------------------
PROCEDURE submit_exception_report
IS
l_req_id number(15);
l_print_option        BOOLEAN;
l_printer_name        VARCHAR2(240);
call_status           BOOLEAN;
l_copies              NUMBER;
rphase                VARCHAR2(80);
rstatus               VARCHAR2(80);
dphase                VARCHAR2(80);
dstatus               VARCHAR2(80);
message               VARCHAR2(80);
l_module_name        varchar2(80) ;
l_run_mode        varchar2(80) ;

BEGIN
    l_module_name    := 'submit_exception_report';

    l_run_mode := 'Fiscal Year';
    l_printer_name      := FND_PROFILE.VALUE('PRINTER');
    l_copies            := FND_PROFILE.VALUE('CONC_COPIES');
    l_print_option := FND_REQUEST.SET_PRINT_OPTIONS(
                             printer    => l_printer_name,
                             copies     => l_copies);

       FV_UTILITY.LOG_MESG(l_module_name|| ' Launching FACTS I exception report ...');

       l_req_id := FND_REQUEST.SUBMIT_REQUEST
                 ('FV','FVFACTSE','','',FALSE, l_run_mode, gbl_fiscal_year,
                   gbl_set_of_books_id, gbl_period_name);

       -- If concurrent request submission failed, abort process
       FV_UTILITY.LOG_MESG(l_module_name|| ' Request ID for exception report = '|| TO_CHAR(L_REQ_ID));

       IF (l_req_id = 0) THEN
          gbl_error_code := '-1';
          gbl_error_buf  := 'Cannot submit FACTS Exception report';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_error_buf);
          RETURN;
        ELSE
          COMMIT;
          call_status := Fnd_concurrent.Wait_for_request(l_req_id, 20, 0,
                                                rphase, rstatus,
                                                dphase, dstatus, message);
          IF call_status = FALSE THEN
             gbl_error_buf := 'Cannot wait for the status of FACTS Exception Report';
             gbl_error_code := -1;
             FV_UTILITY.LOG_MESG(l_module_name||'.error4', gbl_error_buf) ;
             RETURN;
          END IF;
       END IF;

End  submit_exception_report;
--------------------------------------------------------------------------------
-- Purpose of this procedure is to process all Federal or
-- Federal/Non-Federal accounts in FV_FACTS_ATTRIBUTES Table.
--
-- For each such account, find if its a child account. If yes, insert
-- this account along with its parent and fed_nonfed attribute into
-- FV_FACTS_FED_ACCOUNTS table.
-- Otherwise, if the account is a Parent Account, find all the child
-- accounts and insert them into FV_FACTS_FED_ACCOUNTS table along
-- with fed_nonfed attribute.
-- ------------------------------------------------------------------
PROCEDURE GET_FEDERAL_ACCOUNTS (p_err_buff OUT NOCOPY VARCHAR2,
                                p_err_code OUT NOCOPY NUMBER,
                                p_sob_id   IN NUMBER,
                                p_run_year IN NUMBER)
IS
l_module_name 		VARCHAR2(200);
e_invalid_acc_segment 	EXCEPTION;
vl_segment_status	BOOLEAN;
vl_apps_id              NUMBER := 101;
vl_flex_code            VARCHAR2(25) := 'GL#';
vl_child_flex_value_low Fnd_Flex_Value_Hierarchies.child_flex_value_low%TYPE;
vl_child_flex_value_high Fnd_Flex_Value_Hierarchies.child_flex_value_high%TYPE;
l_je_header_id number(15);
l_no_new_accounts number(15);
l_period_num number(15);
l_error_code varchar2(25);
l_error_buf varchar2(500);

l_req_id              NUMBER;
call_status           BOOLEAN;
l_copies              NUMBER;
rphase                VARCHAR2(80);
rstatus               VARCHAR2(80);
dphase                VARCHAR2(80);
dstatus               VARCHAR2(80);
message               VARCHAR2(80);

CURSOR facts_attributes_cur IS
   SELECT facts_acct_number, govt_non_govt
   FROM fv_facts_attributes
   WHERE set_of_books_id = p_sob_id --vg_sob_id
   AND govt_non_govt in ('F', 'Y');

CURSOR fnd_flex_value_hierarchies_cur IS
   SELECT child_flex_value_low, child_flex_value_high
   FROM fnd_flex_value_hierarchies
   WHERE flex_value_set_id = gbl_acc_value_set_id
   AND parent_flex_value = vg_sgl_acct_number;

CURSOR fnd_flex_values_cur IS
   SELECT flex_value
   FROM fnd_flex_values
   WHERE flex_value_set_id = gbl_acc_value_set_id
   AND flex_value BETWEEN vl_child_flex_value_low AND vl_child_flex_value_high;


BEGIN
   l_module_name := g_module_name || 'Get_Federal_Accounts';

   gbl_set_of_books_id := p_sob_id;
   gbl_fiscal_year  := p_run_year;
   FV_UTILITY.LOG_MESG('In '||l_module_name);

   gbl_error_code := 0;

  GET_SEGMENT_NAMES;

  IF gbl_error_code <> 0 THEN
     p_err_code := gbl_error_code;
     p_err_buff := gbl_error_buf;
     FV_UTILITY.LOG_MESG('Error in get_segment_names procedure: '||gbl_error_buf);
     RETURN;
  END IF;

  FV_UTILITY.LOG_MESG('Balancing Segment: '||gbl_bal_segment_name);
  FV_UTILITY.LOG_MESG('Accounting Segment: '||gbl_acc_segment_name);
  FV_UTILITY.LOG_MESG('Chart of Account ID: '||gbl_coa_id);
  FV_UTILITY.LOG_MESG('Account Value Set ID: '||gbl_acc_value_set_id);

   -- Loop through records in FV_FACTS_ATTRIBUTES table with F/Y as Fed_NonFed Attribute
   FOR facts_attributes_rec IN facts_attributes_cur
   LOOP
      vg_acct_number  := NULL;
      vg_fed_nonfed   := NULL;
      vg_acct_number  := facts_attributes_rec.facts_acct_number;

      vg_fed_nonfed   := facts_attributes_rec.govt_non_govt;
      vg_sgl_acct_number := NULL;

      BEGIN
         SELECT parent_flex_value
         INTO  vg_sgl_acct_number
         FROM  fnd_flex_value_hierarchies
         WHERE vg_acct_number
               BETWEEN child_flex_value_low AND child_flex_value_high
         AND flex_value_set_id = gbl_acc_value_set_id
         AND parent_flex_value <> 'T'
         AND parent_flex_value IN
                (SELECT ussgl_account
                 FROM fv_facts_ussgl_accounts
                 WHERE ussgl_account = parent_flex_value);

	 gbl_parent_flag := 'N';

	 POPULATE_FV_FACTS_FED_ACCOUNTS;


         IF gbl_error_code <> 0 THEN
            p_err_code := gbl_error_code;
            p_err_buff := gbl_error_buf;
            FV_UTILITY.LOG_MESG('Error in populate_fv_facts_fed_accounts procedure: '||gbl_error_buf);
            RETURN;
         END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
	   -- If parent not found, then account itself is the parent.
	   -- Insert it into FV_FACTS_FED_ACCOUNTS if not already present.
           gbl_parent_flag := 'Y';
	   vg_sgl_acct_number := vg_acct_number;

         -- If parent not found, then account itself is parent, find all its child accounts
         -- and insert them into FV_FACTS_FED_ACCOUNTS table if not already present.

 	 FOR fnd_flex_value_hierarchies_rec IN fnd_flex_value_hierarchies_cur
         LOOP
	   vl_child_flex_value_low  := NULL;
	   vl_child_flex_value_high := NULL;
	   vl_child_flex_value_low  := fnd_flex_value_hierarchies_rec.child_flex_value_low;
	   vl_child_flex_value_high := fnd_flex_value_hierarchies_rec.child_flex_value_high;

	   FOR fnd_flex_values_rec IN fnd_flex_values_cur
	   LOOP
	      vg_acct_number := fnd_flex_values_rec.flex_value;
	      POPULATE_FV_FACTS_FED_ACCOUNTS;

              IF gbl_error_code <> 0 THEN
                 p_err_code := gbl_error_code;
                 p_err_buff := gbl_error_buf;
                 FV_UTILITY.LOG_MESG('Error in populate_fv_facts_fed_accounts procedure: '||gbl_error_buf);
                 RETURN;
              END IF;


	   END LOOP;	-- fnd_flex_values_cur
         END LOOP; 	-- fnd_flex_value_hierarchies_cur
      END; 		-- Exception
   END LOOP;		-- facts_attributes_cur

    UPDATE_FACTS1_RUN(P_RUN_YEAR, GBL_SET_OF_BOOKS_ID);

 if gbl_error_code = 0 then

  COMMIT;

    Fnd_Stats.GATHER_TABLE_STATS(ownname=>'FV',tabname=>'FV_FACTS1_FED_ACCOUNTS');

/* check whether to call the Journal creation automatically
  if there are new accounts created , then call the journal creation process
  until the last period the journal creation process ran for that sob and year */

  l_je_header_id := 0;

 select nvl(je_header_id,0),nvl(jc_run_month,0) into l_je_header_id,l_period_num
  from fv_facts1_RUN
  where   set_of_books_id = gbl_set_of_books_id
  AND fiscal_year = gbl_fiscal_year;


 if (l_period_num > 0) then

   /* Journal creation process already ran , so need to pikc journals for new a/c */

     select count(*) into l_no_new_accounts from  fv_facts1_fed_accounts
     where   set_of_books_id = gbl_set_of_books_id
     AND fiscal_year = gbl_fiscal_year
     and jc_flag = 'N';

      fv_utility.log_mesg('The Re run of Federal Account Creation Process , found  ' ||
                              l_no_new_accounts || '  new accounts');

    if l_no_new_accounts > 0 then

      select period_name into gbl_period_name
      from gl_period_statuses
      where   ledger_id = gbl_set_of_books_id
      AND period_year = gbl_fiscal_year
      and application_id = 101
      and period_num = l_period_num;

      fv_utility.log_mesg('Calling Journal Creation process.');
       l_req_id := FND_REQUEST.SUBMIT_REQUEST
                      ('FV','FVFC1JCR','','',FALSE, gbl_set_of_books_id, gbl_period_name,'Y');
      FV_UTILITY.LOG_MESG(l_module_name||
                        ' REQUEST ID FOR JOURNAL CREATION PROCESS  = '|| TO_CHAR(L_REQ_ID));
          IF (l_req_id = 0) THEN
             gbl_error_code := -1;
             gbl_error_buf := ' Cannot submit FACTS Journal Creation process';
             fv_utility.log_mesg(gbl_error_buf);
             p_err_code := -1;
             p_err_buff := gbl_error_buf;
             RETURN;
           ELSE
             COMMIT;
             call_status := Fnd_concurrent.Wait_for_request(l_req_id, 20, 0,
                                                  rphase, rstatus,
                                                  dphase, dstatus, message);
             IF call_status = FALSE THEN
               gbl_error_buf := 'Cannot wait for the status of Journal Creation Process';
                gbl_error_code := -1;
                FV_UTILITY.LOG_MESG(l_module_name|| '.error4', gbl_error_buf) ;
                p_err_code := -1;
                p_err_buff := gbl_error_buf;
                RETURN;
             END IF;
          END IF;

      -- FV_FACTS1_GL_PKG.MAIN(l_error_buf, l_error_code, gbl_set_of_books_id, gbl_period_name, 'Y');
      --  p_err_code := l_error_code;
      --  p_err_buff := l_error_buf;
   End if;

End if;


 ELSE
   p_err_code := gbl_error_code;
   p_err_buff  := gbl_error_buf;
End if;
EXCEPTION
   WHEN e_Invalid_Acc_segment THEN
      p_err_code := 2 ;
      p_err_buff  := 'GET_FEDERAL_ACCOUNTS -- Error Reading Accounting Segments' ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, p_err_buff);
      RETURN;

   WHEN OTHERS THEN
      p_err_code := SQLCODE;
      p_err_buff  := SQLERRM ||
                    ' -- Error in Get_Federal_Accounts procedure';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
             l_module_name||'.exception1',p_err_buff);
      RETURN;
END GET_FEDERAL_ACCOUNTS;
-- ------------------------------------------------------------------
--             Procedure Populate_Fv_Facts_Fed_Accounts
-- ------------------------------------------------------------------
-- This procedure gets called from Get_Federal_Accounts procedure.
-- Purpose of this procedure is insert rows into fv_facts_fed_accounts
-- table.
-- ------------------------------------------------------------------
PROCEDURE POPULATE_FV_FACTS_FED_ACCOUNTS IS
l_module_name           VARCHAR2(200);
vl_dummy                VARCHAR2(1);
l_fed_non_fed VARCHAR2(50);
l_dummy_fed_non_fed VARCHAR2(50);

BEGIN
   l_module_name := g_module_name || 'Populate_Fv_Facts_Fed_Accounts';

   l_fed_non_fed := NULL;
   l_dummy_fed_non_fed := NULL;

   IF NOT gbl_header_printed THEN
      fnd_file.put_line(fnd_file.output,'Account Number '||rpad(' ', 16)||'Identified as/           Moved to');
      fnd_file.put_line(fnd_file.output,lpad(' ', 31)||'Moved from ');
      fnd_file.put_line(fnd_file.output,'------------------------------ '||'------------------------ ------------------------');
      gbl_header_printed := TRUE;
   END IF;

   BEGIN
      SELECT fed_non_fed
      INTO vl_dummy
      FROM fv_facts1_fed_accounts
      WHERE account_number = vg_acct_number
      AND   set_of_books_id = gbl_set_of_books_id
      AND fiscal_year = gbl_fiscal_year; --vg_sob_id;


    if (vl_dummy <> vg_fed_nonfed) then

      -- To handle if the child is already processed
      -- before parent.
      IF gbl_parent_flag = 'N' THEN
        UPDATE fv_facts1_fed_accounts
        SET fed_non_fed = vg_fed_nonfed
        WHERE account_number = vg_acct_number
        AND   set_of_books_id = gbl_set_of_books_id
        AND fiscal_year = gbl_fiscal_year;
      END IF;

      l_dummy_fed_non_fed :=
        CASE vl_dummy
           WHEN 'F' THEN RPAD('Federal', 25)
           WHEN 'Y' THEN RPAD('Federal or Non-Federal', 25)
        END;

      l_fed_non_fed :=
        CASE vg_fed_nonfed
           WHEN 'F' THEN 'Federal'
           WHEN 'Y' THEN 'Federal or Non-Federal'
        END;

       -- fv_utility.log_mesg('Account Flag for  ' || vg_acct_number
       --         ||  '  moved from ' || vl_dummy || ' To ' || vg_fed_nonfed);
       fnd_file.put_line(fnd_file.output, RPAD(vg_acct_number, 31) ||
                            l_dummy_fed_non_fed || l_fed_non_fed );
    End if;


   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO fv_facts1_fed_accounts
            (account_number,
             sgl_account_number,
             set_of_books_id,
             fed_non_fed,
             last_run_date,
             jc_flag,
             fiscal_year
             )
        VALUES
            (vg_acct_number,
             vg_sgl_acct_number,
             gbl_set_of_books_id,
             vg_fed_nonfed,
             sysdate,
             'N',
             gbl_fiscal_year
             );

        --fv_utility.log_mesg('Account  ' || vg_acct_number  ||  ' Identified as  ' ||  vg_fed_nonfed);

        l_fed_non_fed :=
          CASE vg_fed_nonfed
             WHEN 'F' THEN RPAD('Federal', 25)
             WHEN 'Y' THEN RPAD('Federal or Non-Federal', 25)
          END;

        fnd_file.put_line(fnd_file.output, RPAD(vg_acct_number,31) || l_fed_non_fed);


        gbl_error_code := 0;
   END;

 --COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      gbl_error_code := SQLCODE;
      gbl_error_buf  := SQLERRM ||
                    ' -- Error in Populate_Fv_Facts_Fed_Accounts procedure';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||
            '.exception1',gbl_error_buf);
END POPULATE_FV_FACTS_FED_ACCOUNTS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BEGIN
g_module_name := 'fv.plsql.FV_FACTS1_PKG.';



END fv_facts1_pkg;

/
