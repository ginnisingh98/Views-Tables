--------------------------------------------------------
--  DDL for Package Body FV_FACTS_TBAL_TRX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FACTS_TBAL_TRX" AS
    /* $Header: FVFCTBPB.pls 120.8.12010000.6 2009/10/19 11:52:01 amaddula ship $ */
    --  ======================================================================
    --          Variable Naming Conventions
    --  ======================================================================
    --  Parameter variables have the format         "vp_<Variable Name>"
    --  FACTS Attribute Flags have the format       "va_<Variable Name>_flag"
    --  FACTS Attribute values have the format      "va_<Variable Name>_val"
    --  Constant values for the FACTS record
    --  have the format                     "vc_<Variable Name>"
    --  Other Global Variables have the format      "v_<Variable_Name>"
    --  Procedure Level local variables have
    --  the format                  "vl_<Variable_Name>"
    --
    --  ======================================================================
    --              Parameters
    --  ======================================================================
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_FACTS_TBAL_TRX.';
    vp_errbuf       Varchar2(1000)      ;
    vp_retcode      number          ;
   /*
    Commented by 7324248
    vp_preparer_id  Varchar2(8)         ;
    vp_certifier_id Varchar2(8)         ;
    vp_report_qtr   number(1);
    vp_treasury_symbol_id fv_treasury_symbols.treasury_symbol_id%TYPE ;
    vp_summary_type     varchar2(1)             ;
    */

    vp_report_fiscal_yr number(4)       ;

    vp_currency_code    Varchar2(15)        ;
    vp_treasury_symbol    fv_treasury_symbols.treasury_symbol%TYPE ;

    vp_set_of_books_id    gl_sets_of_books.set_of_books_id%TYPE  ;
    vp_coa_id       gl_sets_of_books.chart_of_accounts_id%TYPE   ;

    vp_fund_low         fv_fund_parameters.fund_value%type      ;
    vp_fund_high        fv_fund_parameters.fund_value%type      ;
    vp_period_name      gl_period_statuses.period_name%type     ;
    vp_report_id  number;
    vp_output_format varchar2(30);
    vp_attribute_set  varchar2(80);

    --  ======================================================================
    --              FACTS Attributes
    --  ======================================================================
    va_balance_type_flag    Varchar2(1) ;
    va_public_law_code_flag     Varchar2(1) ;
    va_reimburseable_flag   Varchar2(1) ;
    va_bea_category_flag        Varchar2(1) ;
    va_appor_cat_flag       Varchar2(1) ;
    va_borrowing_source_flag    Varchar2(1) ;
    va_def_indef_flag       Varchar2(1) ;
    va_legis_ind_flag           Varchar2(1) ;
    va_pya_flag             Varchar2(1) ;
    va_authority_type_flag  Varchar2(1) ;
    va_function_flag        Varchar2(1) ;
    va_availability_flag    Varchar2(1) ;
    va_def_liquid_flag      Varchar2(1) ;
    va_deficiency_flag      Varchar2(1) ;
    va_transaction_partner_val  Varchar2(1) ;
    va_cohort           Varchar2(2) ;
    va_def_indef_val        Varchar2(1) ;
    va_appor_cat_b_dtl      Varchar2(3)     ;
    va_appor_cat_b_txt      Varchar2(25)    ;
    va_public_law_code_val  Varchar2(7) ;
    va_appor_cat_val        Varchar2(1) ;
    va_authority_type_val   Varchar2(1) ;
    va_reimburseable_val    Varchar2(1) ;
    va_bea_category_val         Varchar2(5) ;
    va_borrowing_source_val Varchar2(6) ;
    va_deficiency_val       Varchar2(1) ;
    va_legis_ind_val        Varchar2(1) ;
    va_pya_val              Varchar2(1) ;
    va_balance_type_val     Varchar2(1) ;
    va_budget_function      VARCHAR2(3) ;
    va_advance_flag     VARCHAR2(1) ;
    va_transfer_ind         VARCHAR2(1) ;
    va_advance_type_val     VARCHAR2(1) ;
    va_transfer_dept_id         VARCHAR2(2) ;
    va_transfer_main_acct   VARCHAR2(4) ;
    va_account_ctr              NUMBER:=0;

    va_pl_code_col              VARCHAR2(25);
    va_advance_type_col         VARCHAR2(25);
    va_tr_dept_id_col           VARCHAR2(25);
    va_tr_main_acct_col         VARCHAR2(25);

    va_prn_num             VARCHAR2(3);
    va_prn_txt             VARCHAR2(25);

    --  ======================================================================
    --              FACTS File Constants
    --  ======================================================================
    vc_fiscal_yr        Varchar2(4)         ;
    vc_dept_regular         Varchar2(2)         ;
    vc_dept_transfer        Varchar2(2) := '  ' ;
    vc_main_account         Varchar2(4)         ;
    vc_sub_acct_symbol      Varchar2(3)         ;
    vc_acct_split_seq_num   Varchar2(3)         ;
    /*
     Commented by 7324248
    vc_maf_seq_num      Varchar2(3)         ;
     vc_atb_seq_num      Varchar2(3) := '000'    ;
     vc_record_indicator     Varchar2(1) := 'D'  ;
    vc_transfer_to_from     Varchar2(1) := ' '  ;
    vc_current_permanent_flag   Varchar2(1) := ' '  ;
    */

    vc_rpt_fiscal_yr        Varchar2(4)     ;
    vc_rpt_fiscal_month     Varchar2(2)     ;

    --  ======================================================================
    --              Other GLOBAL Variables
    --  ======================================================================
    --  ------------------------------
    --  Period Declarations
    --  -----------------------------
    v_begin_period_name     gl_period_statuses.period_name%TYPE ;
    v_begin_period_start_dt     date        ;
    v_begin_period_end_dt   date        ;
    v_begin_period_num      gl_period_statuses.period_num%TYPE ;
    v_period_name       gl_period_statuses.period_name%TYPE ;
    v_period_start_dt       date        ;
    v_period_end_dt     date        ;
    v_period_num        gl_period_statuses.period_num%TYPE  ;
    v_bal_seg_name      Varchar2(20)    ;
    v_acc_seg_name      Varchar2(20)    ;
    v_catb_prg_seg_name      Varchar2(20)    ;
    v_prn_prg_seg_name      Varchar2(20)    ;
    v_cohort_seg_name       Varchar2(20)    ;
    v_fyr_segment_name          varchar2(20);
    v_acc_val_set_id        fnd_flex_value_sets.flex_value_set_id%TYPE ;
    v_catb_prg_val_set_id        fnd_flex_value_sets.flex_value_set_id%TYPE ;
    v_prn_prg_val_set_id        fnd_flex_value_sets.flex_value_set_id%TYPE ;
    v_cohort_select     Varchar2(20)    ;
    v_cohort_where      Varchar2(120)   ;
    v_chart_of_accounts_id  gl_code_combinations.chart_of_accounts_id%TYPE ;
    /*
     Commented by 7324248
     v_acct_num          fv_Facts_attributes.facts_acct_number%TYPE ;
     v_g_edit_check_code     number(15);
     v_acct_attr_flag        Varchar2(1) ;
    */
    v_sgl_acct_num      fv_facts_ussgl_accounts.ussgl_account%TYPE ;
    v_ccid                      number;
    vl_ccid                     number;

    v_amount                Number      ;
    v_period_cr                Number      ;
    v_period_dr                Number      ;
    vl_retcode                Number      ;
    v_begin_amount          number      ;
    v_treasury_symbol_id    fv_treasury_symbols.treasury_symbol_id%TYPE ;
    v_record_category       fv_facts_temp.fct_int_record_category%TYPE  ;
    v_fiscal_yr              Varchar2(25);
    v_segment               varchar2(30);
    v_year_gtn2001          BOOLEAN ;
    v_time_frame            fv_treasury_symbols.time_frame%TYPE ;
    v_financing_acct        fv_facts_federal_accounts.financing_account%TYPE ;
    v_year_budget_auth      VARCHAR2(3);

    /*
    Commented as not used
    v_tbal_run_flag         Varchar2(1) ;
    v_tbal_indicator        FV_FACTS_TEMP.TBAL_INDICATOR%TYPE  ;
     v_edit_check_code       Number ;
     v_debug varchar2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
     v_vl_main_cursor_found varchar2(1) := 'N' ;
    v_code_combination_id    gl_code_combinations.code_combination_id%TYPE;
    */

    v_tbal_fund_value       FV_FUND_PARAMETERS.FUND_VALUE%TYPE ;
    v_tbal_acct_num         varchar2(25);

    v_fund_value            FV_FUND_PARAMETERS.FUND_VALUE%TYPE ;
    v_rec_count             number(3);
    vl_pagebreak              varchar2(30);
    v_fund_count            number(3);
    vg_amount               NUMBER;
    v_dummy_cohort          VARCHAR2(25);

    v_period_activity        NUMBER;

    v_facts_attributes_setup BOOLEAN ;

    v_catb_rc_flag VARCHAR2(1);
    v_catb_rc_header_id NUMBER;
    v_prn_rc_flag VARCHAR2(1);
    v_prn_rc_header_id NUMBER;

   /*
    * Added for 7324248
   */
    g_reimb_agree_seg_name VARCHAR2(25);
    v_reimb_agree_select   VARCHAR2(25);


    error_code           BOOLEAN;
    error_message        VARCHAR2(600);

-- PROCEDURE process_cat_b_seq(reported_type IN VARCHAR2);
PROCEDURE get_prc_val(p_catb_program_val IN VARCHAR2,
                      p_catb_rc_val OUT NOCOPY VARCHAR2,
                      p_catb_rc_desc OUT NOCOPY VARCHAR2,
		      p_prn_program_val IN VARCHAR2,
                      p_prn_rc_val OUT NOCOPY VARCHAR2,
                      p_prn_rc_desc OUT NOCOPY VARCHAR2);

 /*
    * Added by 7324248
   */
PROCEDURE get_trx_part_from_reimb
                      (p_reimb_agree_seg_val IN VARCHAR2);

 -- ====================================================================================================
PROCEDURE select_group_by_columns(x_report_id IN number,
                                  x_attribute_set  IN VARCHAR2,
			          x_group_by out NOCOPY varchar2)
is
  l_module_name VARCHAR2(200) := g_module_name || 'select_group_by_columns';

     cursor c_group IS SELECT COLUMN_NAME
     from fa_rx_rep_columns_b
     WHERE REPORT_id = x_report_id
     and attribute_set = x_attribute_set
     AND BREAK = 'Y';
begin

   for crec in c_group
   Loop
    if crec.column_name like 'SEGMENT%'
     then
          if x_group_by is not null
           then
             x_group_by := x_group_by || ',' ;
           End if;
       x_group_by := x_group_by || 'glcc.' || crec.column_name;
    End if;

   end loop;

      if x_group_by is not null
       then
         x_group_by := ',' || x_group_by;
       end if;

EXCEPTION
  WHEN OTHERS THEN
    vp_retcode := sqlcode ;
    vp_errbuf  := sqlerrm ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
    RAISE;

End;


-- -----------------------------------------------------------------------------------
-- Procedure Definitions
-- -----------------------------------------------------------------------------------

    Procedure GET_SGL_PARENT(
                        Acct_num                Varchar2,
                        parent_ac       OUT NOCOPY  Varchar2,
                        sgl_acct_num       OUT NOCOPY  Varchar2) ;

    -- Gets all information related to the current and beginning period.
    -- (Period Number, Start Date, End Date and Year Start Date Etc.
    Procedure GET_PERIOD_INFO ;

    -- Gets all values that remain constant throughout the FACTS output file.
    Procedure GET_TREASURY_SYMBOL_INFO ;

    -- Processes FACTS Transactions
    Procedure PROCESS_FACTS_TRANSACTIONS ;


    -- Gets all the FACTS attributes and direct pull up values for the passed
    -- account number
    Procedure LOAD_FACTS_ATTRIBUTES (Acct_num Varchar2,
				     Fund_val Varchar2,
				     v_retcode  out NOCOPY number) ;

    -- Creates a FACTS Temp table record with the current values from the
    -- variables, based on the balance type.(B-Beginning, E-Ending)
    Procedure CREATE_FACTS_RECORD ;

    -- Get the Program segment name for the current fund value
    Procedure GET_PROGRAM_SEGMENT (v_fund_value Varchar2) ;

    -- Get the Apportionment Category B Information
    -- PROCEDURE  GET_APPOR_CAT_B_TEXT(program   	Varchar2) ;

       PROCEDURE  get_segment_text(p_program IN   VARCHAR2,
                                p_prg_val_set_id IN  NUMBER,
                                p_seg_txt OUT NOCOPY VARCHAR2);

    -- Calculates the Balance of the passed period for the current account
    -- number and Fund Value and cohort segment (if required) combinations.

    Procedure CALC_BALANCE (ccid NUMBER,
		 Fund_value  Varchar2,
		 acct_num 		Varchar2,
		 period_num 		Number,
		 period_year		NUMBER,
		 Balance_Type 		Varchar2,
		 fiscal_year		VARCHAR2,
		 amount          OUT NOCOPY Number,
		 period_activity OUT NOCOPY NUMBER,
		 pagebreak		VARCHAR2 DEFAULT NULL);

    -- Build the Select stmt for Apportionment Category Processing
    -- based on the values in the varuables
    Procedure Build_Appor_select (ccid NUMBER,
			        Acct_number	Varchar2,
				Fund_Value 	Varchar2,
				fiscal_year 	Varchar2,
				Appor_period	Varchar2,
				select_stmt OUT NOCOPY Varchar2) ;

    --Loads the Treasury Symbol_id into the global variable
    Procedure Load_Treasury_Symbol_Id ;

   --- Rolling up the records
    Procedure FACTS_ROLLUP_RECORDS ;
    -- This procedure is called to execute the trial balance process
    -- based on the range of funds (fund_low and fund_high parameters)
    -- that are passed.
    Procedure PROCESS_BY_FUND_RANGE ;

    -- This procedure does the processing for each fund within the
    -- the range of funds (fund_low and fund_high parameters)
    -- that are passed.
    Procedure PROCESS_EACH_FUND ;


-- ==================================================================================================
procedure DEFAULT_PROCESSING(vl_ccid  number,
                             vl_fund_value varchar2,
                             vl_acct_num varchar2,
                             rec_cat varchar2 := 'R',
                             pagebreak  varchar2 := '')
is
  l_module_name VARCHAR2(200) := g_module_name || 'DEFAULT_PROCESSING';
     vl_amount            number(25,2);
     vl_period_activity   number(25,2);
begin
    -------------- Normal Processing ----------------
    -- Only done on the following conditions
    -- IF FACTS is run and no Apportionment category B Processing or
    --  Legislation Indicator processing is done.
    -- If FACTS is run and program segment cannot be found for Apportionment
    --  Category B Processing

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Normal Processing ') ;
        End If ;
        va_balance_type_val := 'B'  ;
        v_record_category := 'REPORTED' ;
                CALC_BALANCE (vl_ccid,
                        vl_fund_value,
                        vl_acct_num,
                        v_period_num,
          	        vp_report_fiscal_yr,
                        'B',
                        v_fiscal_yr,
                        vl_amount,
                        vl_period_activity,
                        pagebreak) ;
          v_amount        := vl_amount    ;
          v_period_activity       := vl_period_activity;
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Ending Balance(Normal) -> '||v_amount);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'period_activity       --> '||v_period_activity);
          END IF;
            v_record_category :=  'REPORTED';
            v_tbal_fund_value := vl_fund_value ;
            Create_Facts_Record ;
            If vp_retcode <> 0 Then
                Return ;
            End If ;
EXCEPTION
  WHEN OTHERS THEN
    vp_retcode := sqlcode ;
    vp_errbuf  := sqlerrm ;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
    RAISE;

    End;
-- ------------------------------------------------------------------
--                      PROCEDURE MAIN
-- ----------------------------------------------------------------------------
--    Main procedure that is called to execute Trial Balance  process.This calls
--    all subsequent procedures that are part of the Trial balance process.
-- ----------------------------------------------------------------------------
    Procedure MAIN(
                Errbuf          OUT NOCOPY     Varchar2,
                retcode         OUT NOCOPY     Varchar2,
                Set_Of_Books_Id         Number,
                COA_Id                  Number,
                Fund_Low                Varchar2,
                Fund_High               Varchar2,
                currency_code           Varchar2,
                Period                  Varchar2,
	        report_id               number,
	        attribute_set          varchar2,
	        output_format          varchar2)

IS
  l_module_name VARCHAR2(200) := g_module_name || 'MAIN';
BEGIN
    -- Modified the code for the bug 1399282
    -- Load FACTS Parameters into Global Variables
    vp_set_of_books_id  :=  set_of_books_id                 ;
    vp_coa_id       	:=  coa_id                          ;
    vp_fund_low    	:=  fund_low            ;
    vp_fund_high    	:=  fund_high           ;
    vp_period_name  	:=  period              ;
    vp_currency_code    :=  currency_code           ;
    vp_report_id        := report_id;
    vp_attribute_set     := attribute_set;
    vp_output_format    := output_format;
    vp_retcode          :=      0                               ;
   /*
    * Added by 7324248
    */

    fv_utility.log_mesg('Parameters:');
    fv_utility.log_mesg('Set_Of_Books_Id:'||Set_Of_Books_Id);
    fv_utility.log_mesg('COA_Id:'||COA_Id);
    fv_utility.log_mesg('Fund_Low:'||Fund_Low);
    fv_utility.log_mesg('Fund_High:'||Fund_High);
    fv_utility.log_mesg('currency_code:'||currency_code);
    fv_utility.log_mesg('Period:'||Period);


    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
         'Running Trial balance by fund  fund range ' ||
           vp_fund_low || '  ' || vp_fund_high) ;
    End If ;

 fv_utility.log_mesg('Before deleting from FV_FACTS_TEMP ');
    DELETE FROM fv_facts_temp
    WHERE fct_int_record_type = 'TB';
    COMMIT;
fv_utility.log_mesg('After deleting from FV_FACTS_TEMP AND BEFORE PROCESS_BY_FUND_RANGE ');
    PROCESS_BY_FUND_RANGE ;
fv_utility.log_mesg('After PROCESS_BY_FUND_RANGE ');
 fv_utility.log_mesg('vp_retcode :: '||vp_retcode);

    If vp_retcode = 0 Then

       IF NOT v_facts_attributes_setup THEN
          retcode := 1 ;
          errbuf :=
            'Trial Balance by Fund Range Process completed with warning because
             the Public Law, Advance, and Transfer attribute columns are not
             established on the Define System Parameters Form.';
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'Trial Balance by Fund Range Process completed with warning because
            the Public Law, Advance, and Transfer attribute columns are not
            established on the Define System Parameters Form.');
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, errbuf);
        ELSE
          errbuf := 'Trial Balance By Fund Range  Process Completed Successfully' ;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, errbuf);
          END IF ;
       END IF;
          fv_utility.log_mesg('errbuf :: '||errbuf);
     COMMIT ;
    ELSE
        retcode := vp_retcode ;
        errbuf := vp_errbuf ;
        fv_utility.log_mesg('retcode :: errbuf :: '||retcode||'::'||errbuf);
        Rollback ;
    End If ;
EXCEPTION
    -- Exception Processing
    When Others Then
      vp_retcode := sqlcode ;
      vp_errbuf  := sqlerrm || ' [TRIAL_BALANCE_MAIN] ' ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
       '.final_exception',vp_errbuf);
END MAIN ;

-- -------------------------------------------------------------------
--           PROCEDURE GET_PERIOD_INFO
-- -------------------------------------------------------------------
--    Gets the Period infomation like Period Number, Period_year,
-- quarter number and other corresponding period information based on
-- the quarter number passed to the Main Procedure
-- ------------------------------------------------------------------
Procedure GET_PERIOD_INFO
IS
  l_module_name VARCHAR2(200) := g_module_name || 'GET_PERIOD_INFO';
BEGIN
  -- Modified the code for the bug 1399282
    -- When called from Trial Balance process, the parameter passed is period name.
    v_period_name := vp_period_name;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
          'period name '||vp_period_name) ;
    END IF;
    Begin
        Select  period_year,period_num,start_date,end_date
        Into    vp_report_fiscal_yr,v_period_num,v_period_start_dt,v_period_end_dt
        From    gl_period_statuses
        Where   ledger_id = vp_set_of_books_id
        And     application_id = 101
        And     period_name = vp_period_name;
    Exception
        When OTHERS then
            vp_retcode := -1 ;
            vp_errbuf := 'Error Getting Period Year and Period Number for the passed
                           Period [GET_PERIOD_INFO]'  ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
                '.select1', vp_errbuf) ;
    End;
   Begin
        -- Select Period Information for Beginning Period
        Select  period_name,
                start_date,
                end_date,
                period_num
        Into    v_begin_period_name,
                v_begin_period_start_dt,
                v_begin_period_end_dt,
                v_begin_period_num
        from gl_period_statuses
        where (start_date,period_num) IN (Select MIN(year_start_date),MIN(period_num)
                            from gl_period_statuses
                            where period_year = vp_report_fiscal_yr
                            and ledger_id = vp_set_of_books_id)
        and application_id = 101
        and ledger_id = vp_set_of_books_id ;
    Exception
        When NO_DATA_FOUND Then
            vp_retcode := -1 ;
            vp_errbuf := 'Error Getting Beginning Period Information
                         [GET_PERIOD_INFO]'  ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
            Return ;
        When TOO_MANY_ROWS Then
            vp_retcode := -1 ;
            vp_errbuf := 'More than one Beginning Period Returned !!
                         [GET_PERIOD_INFO]'  ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, vp_errbuf) ;
            Return ;
    End ;
EXCEPTION
    -- Exception Processing
    When Others Then
        vp_retcode := sqlcode ;
        vp_errbuf  := sqlerrm || ' [GET_PERIOD_INFO] ' ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
        Return ;
END GET_PERIOD_INFO ;
-- -------------------------------------------------------------------
--       PROCEDURE GET_TREASURY_SYMBOL_INFO
-- -------------------------------------------------------------------
--    Gets all the information that remains contant throughout the
-- FACTS output file. These Information include :
--
-- DEPT_REGULAR         DEPT_TRANSFER,      FISCAL_YEAR,
-- MAIN_ACCOUNT         SUB_ACCT_SYMBOL     ACCT_SPLIT_SEQ_NUM
-- MAF_SPLIT_SEQ_NUM        ATB_SEQ_NUM     PREPARER_ID,
-- CERTIFIER_ID         RPT_FISCAL_YEAR     RPT_FISCAL_MONTH
-- RECORD_INDICATOR     TRANSFER_AGENCY     TRANSFER_ACCT
-- TRANSFER_TO_FROM     YEAR_BUDGET_AUTH    ADVANCE_FLAG
-- CURRENT_PERMANENT_FLAG               FUNCTION
--
-- ------------------------------------------------------------------
Procedure GET_TREASURY_SYMBOL_INFO
IS
  l_module_name VARCHAR2(200) := g_module_name || 'GET_TREASURY_SYMBOL_INFO';
    -- Commented bY 7324248
    --vl_fund_category    Varchar2(1)     ;
    vl_resource_type    Varchar2(80)    ;
    vl_time_frame   Varchar2(25)    ;
    vl_established_fy   Number      ;
    vl_financing_acct   Varchar2(1) ;
    vl_years_available  Number      ;
    vl_fiscal_month_count NUMBER    ;
BEGIN
    Select
    FTS.resource_type,
    RPAD(FFFA.Treasury_dept_code, 2),
    FTS.Time_Frame,
    FTS.Established_Fiscal_yr,
    FFFA.financing_account,
    FFFA.cohort_segment_name,
    RPAD(FFFA.Treasury_acct_code, 4),
    NVL(LPAD(FTS.Tafs_sub_acct,3, '0'),'000'),
    NVL(LPAD(FTS.Tafs_split_code, 3, '0'),'000'),
    FTS.years_available,
    fts.dept_transfer
    Into
    vl_resource_type,
    vc_dept_regular,
    vl_time_frame,
    vl_established_fy,
    vl_financing_acct,
    v_cohort_seg_name,
    vc_main_account,
    vc_sub_acct_symbol,
    vc_acct_split_seq_num,
    vl_years_available,
    vc_dept_transfer
    From
    FV_FACTS_FEDERAL_ACCOUNTS   FFFA,
    FV_TREASURY_SYMBOLS         FTS
    Where  FFFA.Federal_acct_symbol_id  = FTS.Federal_acct_symbol_id
    AND    FTS.treasury_symbol      = vp_treasury_symbol
    AND    FTS.set_of_books_id      = vp_set_of_books_id
    AND    FFFA.set_of_books_id     = vp_set_of_books_id ;
       --
       v_time_frame     := vl_time_frame;
       v_financing_acct := vl_financing_acct;
       IF v_year_gtn2001 THEN
      vc_acct_split_seq_num := '000';
       END IF;
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Financing Acct >>> - ' ||
        vl_financing_acct || ' >>>> - Cohort Seg Name - ' ||
        v_cohort_seg_name) ;
    End If ;
    ------------------------------------------------
    --  Deriving COHORT Value
    ------------------------------------------------
    If vl_financing_acct NOT IN ('D', 'G') Then
    -- Consider COHORT value only for 'D' and 'G' financing Accounts
    v_cohort_seg_name := NULL   ;
    End If ;
    -- Deriving FISCAL_YEAR
    If vl_time_frame = 'SINGLE' Then
    vc_fiscal_yr := '  ' || substr(to_char(vl_established_fy), 3, 2) ;
    ElsIf vl_time_frame IN ('NO_YEAR', 'REVOLVING')  Then
    vc_fiscal_yr := '   X' ;
    ElsIf vl_time_frame IN ('MULTIPLE')  Then
    vc_fiscal_yr := substr(to_char(vl_established_fy), 3,2) ||
        substr(to_char(vl_established_fy + vl_years_available - 1),3,2) ;
    End If ;
    -- Preparer Id and Certifier Id and rpt_fiscal_yr
    -- are derived from Parameters
    vc_rpt_fiscal_yr    := LPAD(to_char(vp_report_fiscal_yr), 4) ;
    -- vc_rpt_fiscal_month := ltrim(to_char(v_period_num,'09')) ;
    -- Bug 2774542

    SELECT to_char(count(*) , '09')
    INTO   vl_fiscal_month_count
    FROM   gl_period_statuses
    WHERE  ledger_id = vp_set_of_books_id
    AND    application_id = 101
    AND    period_year = vp_report_fiscal_yr
    AND    adjustment_period_flag = 'N'
    AND    period_num <= v_period_num  ;

    vc_rpt_fiscal_month := ltrim(to_char(vl_fiscal_month_count,'09')) ;

    -- Year Budget Auth is derived from the parameters
    --
    --    vc_year_budget_auth := vc_rpt_fiscal_yr ;
EXCEPTION
    When NO_DATA_FOUND Then
        vp_retcode := -1 ;
        vp_errbuf := 'Error Getting Treasury Symbol related Information
        for the passed Treasury Symbol [GET_TREASURY_SYMBOL_INFO] ' ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception1', vp_errbuf) ;
    When TOO_MANY_ROWS Then
        vp_retcode := -1 ;
        vp_errbuf := 'More than one set of information returned for the
        passed Treasury Symbol [GET_TREASURY_SYMBOL_INFO]'  ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception2', vp_errbuf) ;
    WHEN OTHERS THEN
      vp_retcode := sqlcode ;
      vp_errbuf  := sqlerrm ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
      RAISE;
END GET_TREASURY_SYMBOL_INFO ;
-- -------------------------------------------------------------------
--       PROCEDURE PROCESS_FACTS_TRANSACTIONS
-- -------------------------------------------------------------------
--    This procedure selets all the transactions that needs to be
-- analyzed for reporting in the FACTS output file. After getting the
-- list of trasnactions that needs to be reported, it applies all the
-- FACTS attributes for the account number and perform further
-- processing for Legislative Indicator and Apportionment Category.
-- It populates the table FV_FACTS_TEMP for edit check process to
-- perform edit checks.
-- ------------------------------------------------------------------
PROCEDURE PROCESS_FACTS_TRANSACTIONS
IS
  l_module_name VARCHAR2(200) := g_module_name || 'PROCESS_FACTS_TRANSACTIONS';
   /*
    * Commented by 7324248
    vl_ret_val  Boolean := TRUE ;
    vl_appor_ctr    Number      ;
     vl_sgl_acct_num Varchar2(25)   ;
    vl_sgl_acct_num_bak Varchar2(25);
     vl_period_net   Number      ;
    -- vl_count    Varchar2(10)    ;
    vl_old_exception Varchar2(30) := ' '    ;
    vl_old_acct_num  Varchar2(25) := ' '    ;
    vl_tran_type    Varchar2(25)    ;
    vl_exception    Varchar2(30)    ;
    vl_cohort_select Varchar2(25)   ;
    vl_cohort_group  Varchar2(25)   ;
    vl_req_id   Number      ;
      vl_exists   Varchar2(1) ;
    vl_type   Varchar2(3) ;
    vl_code_combination_id  VARCHAR2(25);
     vl_pub_ctrl            NUMBER(15):=0;
     vl_segment      varchar2(30);
   */

    vl_exec_ret Integer     ;
    vl_main_cursor  Integer     ;
    vl_main_select  Varchar2(6000)  ;
    vl_main_fetch   Integer     ;
    vl_legis_cursor Integer         ;
    vl_legis_select Varchar2(6000)  ;
    vl_legis_ref    Varchar2(240)   ;
    vl_legis_amount Number := 0 ;
    vl_effective_date DATE;
    vl_appor_cursor Integer         ;
    vl_appor_select Varchar2(6000)  ;
    vl_appor_period varchar2(100)   ;

    vl_fund_value   Varchar2(25)    ;
    vl_acct_num Varchar2(25)    ;

    vl_catb_program  Varchar2(25) ;
    vl_prn_program   varchar2(25) ;

    vl_cohort_yr    Varchar2(25)   ;

    vl_amount   Number      ;

    vl_row_count    Number := 0 ;

    vl_period_name  gl_je_lines.period_name%TYPE;
    vl_adj_flag     VARCHAR2(1);
    vl_adj_num     NUMBER;
    vl_attributes_found varchar2(1) ;
    vl_period_activity  NUMBER;

    vl_parent_ac           varchar2(60);


    vl_exception_cat    NUMBER := 0;

    vl_je_source        gl_je_headers.je_source%TYPE;
    vl_pl_code          VARCHAR2(150);
    vl_tr_main_acct     VARCHAR2(150);
    vl_tr_dept_id       VARCHAR2(150);
    vl_advance_type     VARCHAR2(150);
    vl_count            NUMBER;

    vl_catb_rc_val          VARCHAR2(3);
    vl_catb_pgm_desc	 	VARCHAR2(25);
    vl_prn_rc_val          VARCHAR2(3);
    vl_prn_pgm_desc         VARCHAR2(25);
    vl_counter              NUMBER;
    vb_balance_amount       NUMBER;
    das_id              NUMBER;
    das_where           VARCHAR2(600);
    vl_je_batch_id    number(15);
    vl_je_header_id    number(15);
    vl_je_line_num    number(15);
    vl_je_sla_flag    varchar2(1);
    /*
     * Added by 7324248
    */
    vl_reimb_agree_val VARCHAR2(25);
    l_counter          NUMBER;

--- added for bug 6409180
cursor be_cur is
       select  vl_legis_ref  transaction_id, vl_legis_amount amount
       from dual
       where nvl(vl_je_sla_flag ,'N') = 'N'
       union all
       SELECT  to_char(xd.source_distribution_id_num_1) transaction_id,
               (NVL(xd.unrounded_accounted_dr,0) -
                NVL(xd.unrounded_accounted_cr,0)) amount
       FROM gl_import_references gli,
            xla_ae_lines xl,
            xla_ae_headers xh,
            xla_distribution_links xd
       WHERE gli.je_batch_id = vl_je_batch_id
       AND gli.je_header_id = vl_je_header_id
       AND gli.je_line_num = vl_je_line_num
       AND xl.gl_sl_link_id = gli.gl_sl_link_id
       AND xl.application_id = 8901
       AND xh.ae_header_id = xl.ae_header_id
       AND xl.ledger_id = vp_set_of_books_id
       AND xd.event_id = xh.event_id
       and xd.ae_header_id = xh.ae_header_id
       and xd.ae_line_num = xl.ae_line_num
       and  nvl(vl_je_sla_flag ,'N') = 'Y';
BEGIN
    -- Get all the transaction balances for the combinations that have
    -- fund values which are associated with the passed Treasury
    -- Symbol. Sum all the amounts and group the data by Account Number
    -- and Fund Value.
    -- Dynamic SQL is used for declaring the following cursor and to
    -- fetch the values.
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Selecting FACTS Transactions.....') ;
    END IF;
    Begin
        vl_main_cursor := DBMS_SQL.OPEN_CURSOR  ;
    Exception
        When Others Then
            vp_retcode := sqlcode ;
            VP_ERRBUF  := sqlerrm ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.open_vl_main_cursor', vp_errbuf) ;
        Return ;
    End ;
    If v_cohort_seg_name IS NOT NULL Then
      v_cohort_select := ', GLCC.' || v_cohort_seg_name ;
     Else
      v_cohort_select := ' ' ;
    End If ;

    v_segment := ' ';

    vl_main_select :=
     'Select
        GLCC.code_combination_id , GLCC.' || v_acc_seg_name ||
        ', GLCC.' || v_bal_seg_name ||
        ', GLCC.' || v_fyr_segment_name ||
        ', SUM((glb.begin_balance_dr - glb.begin_balance_cr) +
                   (glb.period_net_dr - period_net_cr)) '||
             v_segment  ||
             v_cohort_select ||
            v_reimb_agree_select ||
        ' From    GL_BALANCES                   GLB,
                GL_CODE_COMBINATIONS            GLCC
        WHERE   GLB.code_combination_id = GLCC.code_combination_id ';

     fv_utility.log_mesg('v_reimb_agree_select ::'||v_reimb_agree_select);

     -- Data Access Security
     das_id := fnd_profile.value('GL_ACCESS_SET_ID');
     das_where := gl_access_set_security_pkg.get_security_clause
                              (das_id,
                               gl_access_set_security_pkg.READ_ONLY_ACCESS,
                               gl_access_set_security_pkg.CHECK_LEDGER_ID,
                               to_char(vp_set_of_books_id), 'GLB',
                               gl_access_set_security_pkg.CHECK_SEGVALS,
                               null, 'GLCC', null);
     IF (das_where IS NOT NULL) THEN
             vl_main_select := vl_main_select || 'AND ' || das_where;
     END IF;


    vl_main_select := vl_main_select ||
	 ' AND glb.actual_flag = :actual_flag
	   AND GLB.TEMPLATE_ID IS NULL
	   AND GLCC.' || v_bal_seg_name || ' = :fund_value
           AND  GLB.ledger_id =  :set_of_books_id
           AND   GLB.PERIOD_YEAR = :report_fiscal_yr
           AND  glb.currency_code = :currency_code
           GROUP BY  GLCC.code_combination_id ,
		     GLCC.' || v_acc_seg_name ||
		  ', GLCC.' || v_bal_seg_name ||
		  ', GLCC.' || v_fyr_segment_name
               || v_segment ||v_cohort_select ||
       		   '  ORDER BY GLCC.' || v_acc_seg_name  ;

    Begin
        dbms_sql.parse(vl_main_cursor, vl_main_select, DBMS_SQL.V7) ;
    Exception
        When Others Then
            vp_retcode := sqlcode ;
            VP_ERRBUF  := sqlerrm ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
                 '.parse_vl_main_cursor', vp_errbuf) ;
        Return ;
    End ;

    -- Bind the variables
    dbms_sql.bind_variable(vl_main_cursor,':actual_flag', 'A');
    dbms_sql.bind_variable(vl_main_cursor,':fund_value', v_fund_value);
    dbms_sql.bind_variable(vl_main_cursor,':set_of_books_id', vp_set_of_books_id);
    dbms_sql.bind_variable(vl_main_cursor,':report_fiscal_yr', vp_report_fiscal_yr);
    dbms_sql.bind_variable(vl_main_cursor,':currency_code', vp_currency_code);

   fv_utility.log_mesg('fund_value :: vp_set_of_books_id::vp_report_fiscal_yr::'||v_fund_value||'|'||vp_set_of_books_id||'|'||vp_report_fiscal_yr);
    dbms_sql.define_column(vl_main_cursor, 1, vl_ccid);
    dbms_sql.define_column(vl_main_cursor, 2, vl_acct_num, 25);
    dbms_sql.define_column(vl_main_cursor, 3, vl_fund_value, 25);
    dbms_sql.define_column(vl_main_cursor, 4, v_fiscal_yr, 25);
    dbms_sql.define_column(vl_main_cursor, 5, vg_amount);
    -- Added by 7324248
    l_counter := 6;

    IF v_cohort_seg_name IS NOT NULL THEN
       dbms_sql.define_column(vl_main_cursor, l_counter, vl_cohort_yr, 25);
       l_counter:=l_counter+1;
    END IF;

    Begin
        vl_exec_ret := dbms_sql.execute(vl_main_cursor);
    Exception
        When Others Then
            vp_retcode := sqlcode ;
            VP_ERRBUF  := sqlerrm ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
                 '.execute_vl_main_cursor', vp_errbuf) ;
            Return ;
    End ;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'Processing FACTS Transactions starts.....');
    END IF;
    LOOP
      -- This is a Dummy Loop since we have no command in PL/SQL to skip
      -- the Loop in the middle and continue with the next iteration.
      LOOP    /* Dummy */
        -- Reseting all the Variables before fetching the Next Row
        va_transaction_partner_val  := ' '      ;
        va_cohort                   := '  '     ;
        va_def_indef_val            := ' '      ;
        va_appor_cat_b_dtl          := '   '        ;
        va_appor_cat_b_txt          := LPAD(' ',25)     ;
        va_prn_num                  := '   '        ;
        va_prn_txt                  := LPAD(' ',25)     ;
        va_public_law_code_val      := '       '        ;
        va_appor_cat_val            := ' '          ;
        va_authority_type_val       := ' '          ;
        va_reimburseable_val        := ' '          ;
        va_bea_category_val         := '     '      ;
        va_borrowing_source_val     := '      '         ;
        va_legis_ind_val            := ' '          ;
        va_pya_val                  := ' '          ;
        va_balance_type_val         := ' '          ;
        va_availability_flag        := ' ';
        va_function_flag        := ' ';
        va_budget_function          := '   ';
        va_advance_type_val     := ' ';
        va_transfer_dept_id     := '  ';
        va_transfer_main_acct       := '    ';
        va_account_ctr := 0;
        vl_ccid := NULL;
        vg_amount := 0;
        v_dummy_cohort := NULL;
        vl_pagebreak := NULL;
        vl_cohort_yr := NULL;
        v_cohort_where := NULL;

        v_period_dr := 0;
        v_period_cr := 0;

        vl_main_fetch :=  dbms_sql.fetch_rows(vl_main_cursor) ;

        IF  (VL_MAIN_FETCH = 0) then
	 exit;
        End if;


        -- Increase the counter for number of records
        vl_row_count := vl_row_count + 1  ;

        -- Fetch the Records into Variables
       dbms_sql.column_value(vl_main_cursor, 1, vl_ccid);
       dbms_sql.column_value(vl_main_cursor, 2, vl_acct_num);
       dbms_sql.column_value(vl_main_cursor, 3, vl_fund_value);
       dbms_sql.column_value(vl_main_cursor, 4, v_fiscal_yr);
       dbms_sql.column_value(vl_main_cursor, 5, vg_amount);

	-- Added by 7324248
	 l_counter := 6;

       IF v_cohort_seg_name IS NOT NULL THEN
          dbms_sql.column_value(vl_main_cursor, l_counter, vl_cohort_yr);
	  l_counter:=l_counter+1;
       END IF;

       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
        '==========================================================');
       END IF;

       -- Fix for bug 2798371
       IF vl_cohort_yr IS NOT NULL THEN
         BEGIN
           SELECT TO_NUMBER(vl_cohort_yr)
           INTO   v_dummy_cohort
           FROM DUAL;

            IF LENGTH(v_dummy_cohort) = 1 THEN
              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                 'Cohort value: '||vl_cohort_yr||' is a single digit!');
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                 'Taking Cohort value from report parameter.');
              END IF;
              v_dummy_cohort := vp_report_fiscal_yr;
            END if;

          EXCEPTION WHEN INVALID_NUMBER THEN
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
              l_module_name, 'Cohort value: '||vl_cohort_yr
               ||' is non-numeric!');
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
              l_module_name, 'Taking Cohort value from report parameter.');
           END IF;
              v_dummy_cohort := vp_report_fiscal_yr;
         END;
       END IF;

     -- va_cohort := NVL(LPAD(substr(vl_cohort_yr, 3, 2), 2, ' '), '  ') ;
     va_cohort := NVL(LPAD(substr(v_dummy_cohort,
                    LENGTH(v_dummy_cohort)-1, 2), 2, ' '), '  ') ;

    -- Acct Number Validation based on type of Processing(FACTSII or TBal)

     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'Processing  for >>>> Acct -> '||vl_acct_num||
           ' >>>> Fund -> '||vl_fund_value||
           ' Cohort >>>> -> ' ||vl_cohort_yr||
           ' >>>> Amt -> ' ||
              to_char(vl_amount) );
     End If ;

     -- Set the global variables
     v_ccid := vl_ccid;
     v_record_category   := 'REPORTED'       ;
     v_tbal_fund_value   := vl_fund_value    ;
     v_tbal_acct_num   := vl_acct_num    ;

	 /* Getting parent a/c */

     vl_attributes_found := 'N' ;

     GET_SGL_PARENT(vl_acct_num, vl_parent_ac , v_sgl_acct_num) ;

     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                 l_module_name, 'Parent A/c : '||vl_parent_ac||
                                ' USSGL : '||v_sgl_acct_num);
     END IF;

     LOAD_FACTS_ATTRIBUTES (vl_acct_num, vl_fund_value,vl_retcode)  ;

     IF vl_retcode = -1 then
       IF vl_parent_ac is not null then
         LOAD_FACTS_ATTRIBUTES(vl_parent_ac, vl_fund_value,vl_retcode) ;
       End if;
      ELSE
	vl_attributes_found := 'Y';
     END IF;

     if vl_retcode = -1  then
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
         'No attributes defined '||vl_acct_num||' and '||vl_parent_ac);
      else
        vl_attributes_found := 'Y' ;
     End if;

     -- In case no attributes are found then insert beginning and ending
     -- balance records

    If vl_attributes_found = 'N' then
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, 'Attributes not found ') ;

        -- Get the Beginning Balance
       CALC_BALANCE (
                        vl_ccid,
                        vl_fund_value,
                        vl_acct_num,
                        v_period_num,
                        vp_report_fiscal_yr,
                        'B',
                        v_fiscal_yr,
                        v_begin_amount,
                        vl_period_activity,
                        vl_pagebreak) ;

        v_amount        := v_begin_amount   ;
        v_period_activity       := vl_period_activity   ;
        va_balance_type_val     := 'B'          ;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'begin Balance  for >>>>  - ' || v_begin_amount);
        END IF;
        v_tbal_fund_value   := vl_fund_value    ;
        create_facts_record     ;
        If vp_retcode <> 0 Then
          Return ;
        End If ;
        -- Exit the Loop to continue with the next Acct Number
        Exit ;

    End If ; /* attributes not found */


 /*     ----------------------------------------------------------------
      --Bug 7324248
      --Derive Transaction Partner attribute
      --using the Reimbursable Agreement segment value,
      --if the segment has been setup or has a value,
      --else default to 0.
      ----------------------------------------------------------------

fv_utility.log_mesg('va_transaction_partner_val:'||va_transaction_partner_val);
fv_utility.log_mesg('vl_reimb_agree_val:'||vl_reimb_agree_val);
fv_utility.log_mesg('vl_acct_num:'||vl_acct_num);

      IF va_transaction_partner_val <> 'N' THEN
         IF g_reimb_agree_seg_name IS NOT NULL THEN
            IF vl_reimb_agree_val IS NOT NULL THEN
               get_trx_part_from_reimb(vl_reimb_agree_val);
              ELSE
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
               'Reimbursable Agreement value is null!!' ||
               ' Setting transaction partner value to 0.');
             END IF;
           ELSE
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
               'Reimbursable Agreement segment is not defined!!' ||
               ' Setting transaction partner value to 0.');
            END IF;
       END IF;

*/

    -- Cohort where clause is set to a global variable to use in
    -- CALC_BALANCE Procedure and futher in the process
    If v_cohort_seg_name IS NOT NULL Then
            v_cohort_where := ' AND GLCC.' || v_cohort_seg_name || ' = ' ||
                            '''' || vl_cohort_yr || '''' ;
     Else
            v_cohort_where := ' ' ;
    End If ;


    -------------- Legislation Indicator Processing Starts ----------------
    If  va_public_law_code_flag = 'Y' OR va_advance_flag = 'Y' OR va_transfer_ind = 'Y' Then
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        If va_legis_ind_flag = 'Y' and
                va_public_law_code_flag = 'N' then
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    ' ++++++++ Leg Ind Processing   ++++++++') ;
                END IF;
         Elsif va_legis_ind_flag = 'N' and
                va_public_law_code_flag = 'Y' then
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    ' ++++++++ Pub Law Processing   ++++++++') ;
                END IF;
        End If ;
        --
        IF va_advance_flag = 'Y' THEN
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
             ' ++++++++ Advance Type Processing   ++++++++') ;
          END IF;
        END IF;
        IF va_transfer_ind = 'Y' THEN
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            ' ++++++++ Transfer Acct Processing   ++++++++') ;
          END IF;
        END IF;

      End If ;

      BEGIN
        -- Calculate the Beginning balance for the current account
        -- and fund value combination and create record in temp
        -- table for Legislative Indicator 'A' and Balance Type 'B'
        -- Default Public Law Code values for beginning and
        -- ending balances
        If va_public_law_code_flag = 'Y' then
            --Bug#3219532
            --va_public_law_code_val := '000-000' ;
            va_public_law_code_val := '       ' ;
        End If ;

        --
        -- Advance Type values for beginning and ending balances
        If va_advance_flag = 'Y' then
                va_advance_type_val  := 'X'         ;
        End If ;
        -- Transfer values for beginning and ending balances
        IF  va_transfer_ind       = 'Y' THEN
                va_transfer_dept_id   := '  '       ;
            va_transfer_main_acct := '    '     ;
        END IF ;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Period number '||v_begin_period_num) ;
        END IF;
        CALC_BALANCE (
                        vl_ccid,
                        vl_fund_value,
                        vl_acct_num,
                        v_begin_period_num,
                        vp_report_fiscal_yr,
                        'B',
                        v_fiscal_yr,
                        v_begin_amount,
                        vl_period_activity,
                        vl_pagebreak) ;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                ' Legis Ind Begin Balance -> ' || v_begin_amount) ;
        End If ;
        If vp_retcode <> 0 Then
                    Return ;
        End If ;

        vb_balance_amount := v_begin_amount;
        FOR begin_balance_rec IN (SELECT SUM(NVL(f.ending_balance_dr, 0) - NVL(f.ending_balance_cr, 0)) amount,
                                         f.public_law,
                                         f.advance_flag,
                                         f.transfer_dept_id,
                                         f.transfer_main_acct
                                    FROM fv_factsii_ending_balances f
                                   WHERE f.set_of_books_id = vp_set_of_books_id
                                     AND f.fiscal_year = vp_report_fiscal_yr-1
                                     AND f.ccid = vl_ccid
                                   GROUP BY f.public_law,
                                            f.advance_flag,
                                            f.transfer_dept_id,
                                            f.transfer_main_acct) LOOP
          v_amount := begin_balance_rec.amount;
          vb_balance_amount := vb_balance_amount - v_amount;
          v_record_category := 'REPORTED';
          va_public_law_code_val := RTRIM(begin_balance_rec.public_law);
          va_advance_type_val := begin_balance_rec.advance_flag;
          va_transfer_dept_id := begin_balance_rec.transfer_dept_id;
          va_transfer_main_acct := begin_balance_rec.transfer_main_acct;
          v_period_activity := 0;
          va_balance_type_val  := 'B';
          v_period_dr := 0;
          v_period_cr := 0;
          create_facts_record;
        END LOOP;

        IF (vb_balance_amount <> 0) THEN
          va_public_law_code_val := NULL;
          va_advance_type_val := NULL;
          va_transfer_dept_id := NULL;
          va_transfer_main_acct := NULL;

          If va_public_law_code_flag = 'Y' then
            va_public_law_code_val := '       ' ;
          End If ;
          If va_advance_flag = 'Y' then
            va_advance_type_val  := 'X'         ;
          End If ;
          IF  va_transfer_ind       = 'Y' THEN
            va_transfer_dept_id   := '  '       ;
            va_transfer_main_acct := '    '     ;
          END IF ;

          va_balance_type_val     := 'B'          ;
          v_record_category   := 'REPORTED'       ;
          v_amount        := vb_balance_amount   ;
           v_period_activity       := 0   ;     --Bug 2577862
           v_period_dr := 0;
           v_period_cr := 0;
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
             'begin Balance  >>>>  - ' || to_char(v_begin_amount)) ;
           END IF;
           if v_amount > 0 then
              CREATE_FACTS_RECORD                 ;
                  If vp_retcode <> 0 Then
                      Return ;
                  End If ;
           End if;
         END IF;
            -- Select the records for other Legislative Indicator values,

            -- derived from Budget Execution tables and store them in a
            -- cursor. Then roll them up and insert the summarized record
            -- into the temp table. Dynamic SQL used for implementation.
           Begin
                vl_legis_cursor := DBMS_SQL.OPEN_CURSOR  ;
            Exception
                When Others Then
                    vp_retcode := sqlcode ;
                    VP_ERRBUF  := sqlerrm ;
                      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
                      '.open_vl_legis_cursor', vp_errbuf) ;
                    Return ;
            End ;


            IF va_pl_code_col IS NOT NULL THEN
               va_pl_code_col :=  ', gjl.'||va_pl_code_col;
            END IF;

            IF va_tr_main_acct_col IS NOT NULL THEN
               va_tr_main_acct_col := ', gjl.'||va_tr_main_acct_col;
            END IF;

            IF va_tr_dept_id_col IS NOT NULL THEN
               va_tr_dept_id_col := ', gjl.'||va_tr_dept_id_col;
            END IF;

            IF va_advance_type_col IS NOT NULL THEN
               va_advance_type_col := ', gjl.'||va_advance_type_col;
            END IF;


        -- Get the transactions for the account Number and Fund (and
        -- cohort segment, if required)

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'vl_legis_Select') ;
        END IF;

            vl_legis_select :=
            'Select gjl.reference_1,
                    Nvl(gjl.entered_dr, 0) - Nvl(gjl.entered_cr, 0),
                    gjl.effective_date , gjl.period_name,
                    Nvl(gjl.entered_dr, 0) period_dr , Nvl(gjl.entered_cr, 0) period_cr,
		    gjh.je_source ,gjh.je_header_id , gjl.je_line_num , gjh.je_batch_id,je_from_sla_flag '||
                    va_pl_code_col || va_tr_main_acct_col || va_tr_dept_id_col ||
                    va_advance_type_col ||
          '  From   gl_je_lines         gjl,
                    gl_code_combinations    glcc,
                    gl_je_headers       gjh
             Where   gjl.code_combination_id = glcc.code_combination_id
             AND     glcc.code_combination_id = :ccid ';

            vl_legis_select := vl_legis_select ||
	    ' AND   gjl.status = :je_status
              AND (gjl.effective_date between
                   :begin_period_start_dt
	      AND :period_end_dt)
	      AND  gjl.ledger_id = :set_of_books_id
              AND   glcc.' || v_acc_seg_name || ' = :acct_num
              AND   Nvl(gjl.entered_dr, 0) - Nvl(gjl.entered_cr, 0) <> 0
              AND   glcc.' || v_bal_seg_name || ' = :fund_value ' ||
		    v_cohort_where ||
            ' AND   glcc.'||v_fyr_segment_name || ' = :fiscal_yr
              AND   gjh.je_header_id = gjl.je_header_id
              AND   gjh.currency_code = :currency_code
              AND   NOT EXISTS
                (SELECT ''x''
                 FROM   gl_period_statuses glp
                 WHERE  glp.ledger_id = :set_of_books_id
                 AND   glp.application_id = 101
                 AND   glp.period_name    = gjl.period_name
                 AND   glp.period_year    = :report_fiscal_yr
                 AND   glp.period_num     > :period_num) ';


        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, vl_legis_select) ;
        END IF;


        Begin
              dbms_sql.parse(vl_legis_cursor,vl_legis_select,DBMS_SQL.V7);
         Exception
           When Others Then
             vp_retcode := sqlcode ;
             VP_ERRBUF  := sqlerrm ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
              '.parse_vl_legis_cursor', vp_errbuf) ;
             Return ;
        End ;

             -- Bind the variables
             dbms_sql.bind_variable(vl_legis_cursor,':ccid', vl_ccid);
             dbms_sql.bind_variable(vl_legis_cursor,':je_status', 'P');
             dbms_sql.bind_variable(vl_legis_cursor,':begin_period_start_dt',
                                                      v_begin_period_start_dt);
             dbms_sql.bind_variable(vl_legis_cursor,':period_end_dt',
                                                      v_period_end_dt);
             dbms_sql.bind_variable(vl_legis_cursor,':set_of_books_id',
                                                          vp_set_of_books_id);
             dbms_sql.bind_variable(vl_legis_cursor,':acct_num', vl_acct_num);
             dbms_sql.bind_variable(vl_legis_cursor,':fund_value', vl_fund_value);
             dbms_sql.bind_variable(vl_legis_cursor,':fiscal_yr', v_fiscal_yr);
             dbms_sql.bind_variable(vl_legis_cursor,':currency_code', vp_currency_code);
             dbms_sql.bind_variable(vl_legis_cursor,':set_of_books_id',
                                                          vp_set_of_books_id);
             dbms_sql.bind_variable(vl_legis_cursor,':report_fiscal_yr',
                                                            vp_report_fiscal_yr);
             dbms_sql.bind_variable(vl_legis_cursor,':period_num', v_period_num);


            dbms_sql.define_column(vl_legis_cursor, 1, vl_legis_ref, 240);
            dbms_sql.define_column(vl_legis_cursor, 2, vl_legis_amount   );
            dbms_sql.define_column(vl_legis_cursor, 3, vl_effective_date   );
            dbms_sql.define_column(vl_legis_cursor, 4, vl_period_name, 15  );
            dbms_sql.define_column(vl_legis_cursor, 5, v_period_dr );
            dbms_sql.define_column(vl_legis_cursor, 6, v_period_cr );
            dbms_sql.define_column(vl_legis_cursor, 7, vl_je_source, 25 );
            dbms_sql.define_column(vl_legis_cursor, 8, vl_je_header_id );
            dbms_sql.define_column(vl_legis_cursor, 9, vl_je_line_num );
            dbms_sql.define_column(vl_legis_cursor, 10, vl_je_batch_id );
            dbms_sql.define_column(vl_legis_cursor, 11, vl_je_sla_flag,1 );

	    vl_count := 12;

             IF va_pl_code_col IS NOT NULL THEN
                dbms_sql.define_column(vl_legis_cursor, vl_count, vl_pl_code, 150);
                vl_count := vl_count + 1;
             END IF;

             IF va_tr_main_acct_col IS NOT NULL THEN
                dbms_sql.define_column(vl_legis_cursor, vl_count, vl_tr_main_acct, 150);
                vl_count := vl_count + 1;
             END IF;

             IF va_tr_dept_id_col IS NOT NULL THEN
                dbms_sql.define_column(vl_legis_cursor, vl_count, vl_tr_dept_id, 150);
                vl_count := vl_count + 1;
             END IF;

             IF va_advance_type_col IS NOT NULL THEN
                dbms_sql.define_column(vl_legis_cursor, vl_count, vl_advance_type, 150);
             END IF;

            Begin
                vl_exec_ret := dbms_sql.execute(vl_legis_cursor);
             Exception
                When Others Then
                    vp_retcode := sqlcode ;
                    VP_ERRBUF  := sqlerrm ;
                      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
                      '.execute_vl_legis_cursor', vp_errbuf) ;
                    Return ;
            End ;
                va_account_ctr := 0;
      Loop
                    vl_exception_cat   := 0;
           if dbms_sql.fetch_rows(vl_legis_cursor) = 0 then
                   exit;
           End if;

           -- Fetch the Records into Variables
           dbms_sql.column_value(vl_legis_cursor,1,vl_legis_ref);
           dbms_sql.column_value(vl_legis_cursor,2,vl_legis_amount);
           dbms_sql.column_value(vl_legis_cursor,3,vl_effective_date);
           dbms_sql.column_value(vl_legis_cursor,4,vl_period_name);
           dbms_sql.column_value(vl_legis_cursor,5,v_period_dr);
           dbms_sql.column_value(vl_legis_cursor,6,v_period_cr);
           dbms_sql.column_value(vl_legis_cursor,7,vl_je_source);

            dbms_sql.column_value(vl_legis_cursor, 8, vl_je_header_id );
            dbms_sql.column_value(vl_legis_cursor, 9, vl_je_line_num );
            dbms_sql.column_value(vl_legis_cursor, 10, vl_je_batch_id );
            dbms_sql.column_value(vl_legis_cursor, 11, vl_je_sla_flag );

           vl_count := 12;

           IF va_pl_code_col IS NOT NULL THEN
              dbms_sql.column_value(vl_legis_cursor, vl_count, vl_pl_code);
              vl_count := vl_count + 1;
           END IF;

           IF va_tr_main_acct_col IS NOT NULL THEN
              dbms_sql.column_value(vl_legis_cursor, vl_count, vl_tr_main_acct);
              vl_count := vl_count + 1;
           END IF;

           IF va_tr_dept_id_col IS NOT NULL THEN
              dbms_sql.column_value(vl_legis_cursor, vl_count, vl_tr_dept_id);
              vl_count := vl_count + 1;
           END IF;

           IF va_advance_type_col IS NOT NULL THEN
              dbms_sql.column_value(vl_legis_cursor, vl_count, vl_advance_type);
           END IF;

              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                 'Ref 1 - '||nvl(vl_legis_ref,'Ref Null'));
               	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                 'Amt - '|| nvl(to_char(vl_legis_amount),
			            'Amt Null')) ;
              End If ;


            SELECT  adjustment_period_flag, period_num
            INTO    vl_adj_flag , vl_adj_num
            FROM    gl_period_statuses
                WHERE   ledger_id = vp_set_of_books_id
                AND     application_id = 101
                AND     period_name = vl_period_name;

             va_balance_type_val := 'C';
            IF  vl_adj_num < v_period_num THEN
                va_balance_type_val := 'P';
            END IF;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'vl_period ' || vl_period_name);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'vl_adj_flag ' || vl_adj_flag);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'vl_balance_flag ' || va_balance_type_val);
        END IF;

  -----------------------------------------------------------------------
      -- Public Law Processing
      -- If the public law code is required then check the journal source.
      -- If the journal source is YE Close and Budgetary Transaction then
      -- get the public law code from BE details table.  If the journal
      -- source is not these two, then get the public law code from the
      -- corresponding attribute field on the je line.

  -----------------------------------------------------------------------

     --CURSOR be_cursor IS
   for be_rec in  be_cur

    loop
        vl_legis_amount := be_rec.amount;
        vl_legis_ref := be_rec.transaction_id;

  IF va_public_law_code_flag = 'N' then
       va_public_law_code_val := '       ' ;
  Else
      IF vl_legis_ref IS NOT NULL THEN

           BEGIN
                    SELECT  public_law_code
                    INTO    va_public_law_code_val
                    FROM    fv_be_trx_dtls
                    WHERE   transaction_id  = vl_legis_ref
                    AND     set_of_books_id = vp_set_of_books_id ;
             If va_public_law_code_val is NULL Then
                -- Create Exception
                 v_ccid := vl_ccid;
                 --Bug#3219532
                 --va_public_law_code_val := '000-000' ;
                 va_public_law_code_val := '       ' ;
                v_record_category :=  'REPORTED';
            End If ;

            EXCEPTION
                   WHEN NO_DATA_FOUND THEN
               	    v_ccid := vl_ccid;
                    --Bug#3219532
               	    --va_public_law_code_val := '000-000' ;
               	    va_public_law_code_val := '       ' ;
                    v_record_category :=  'REPORTED';
                 WHEN INVALID_NUMBER THEN
                v_record_category :=  'REPORTED';
                --Bug#3219532
                --va_public_law_code_val := '000-000' ;
                va_public_law_code_val := '       ' ;
          END ;

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'P Law-'||
        			nvl(va_public_law_code_val,'P Law Null'));
          END IF;

	ELSE -- vl_legis_ref is null
	   IF  va_pl_code_col IS NULL THEN
               va_public_law_code_val := '       ' ;
            ELSE
	       va_public_law_code_val := SUBSTR(vl_pl_code,1,7);
	   END IF;

        END IF;

     End If ; /* va_public_law_code */

           -- Advance Type specific processing
        IF va_advance_flag = 'Y' THEN
           IF vl_legis_ref IS NOT NULL THEN
                BEGIN
                    SELECT  advance_type
                    INTO    va_advance_type_val
                    FROM    fv_be_trx_dtls
                    WHERE   transaction_id  = vl_legis_ref
                    AND     set_of_books_id = vp_set_of_books_id ;
                    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                      'Advance Type - '||
                      nvl(va_advance_type_val, 'Advance Type Null')) ;
                    END IF ;
                    -- If the advance_type value is null then set it to 'X'
                    IF va_advance_type_val IS NULL THEN
                       va_advance_type_val := 'X';
                    END IF;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        va_advance_type_val := 'X';
                        vl_exception_cat := 1;
                     WHEN INVALID_NUMBER THEN
                        va_advance_type_val := 'X';
		END;
            ELSE -- vl_legis_ref is null
                IF  va_advance_type_col IS NULL THEN
                    --Bug#3219532
                    va_advance_type_val := 'X';
                    --va_advance_type_val := ' ';
                 ELSE
                    va_advance_type_val := SUBSTR(NVL(vl_advance_type, 'X'),1,1);
                END IF;
           END IF;
        END IF;

            -- Transfer Acct specific processing
            IF va_transfer_ind = 'Y' THEN
               IF vl_legis_ref IS NOT NULL THEN
                   BEGIN
                       SELECT  dept_id, main_account
                       INTO    va_transfer_dept_id, va_transfer_main_acct
                       FROM    fv_be_trx_dtls
                       WHERE   transaction_id  = vl_legis_ref
                       AND     set_of_books_id = vp_set_of_books_id ;
                       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                               'Transfer Dept ID - '||
                               nvl(va_transfer_dept_id, 'Transfer Dept ID Null')) ;
                           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                               'Transfer Main Acct - '||
                               nvl(va_transfer_main_acct, 'Transfer Main Acct Null')) ;
                       END IF ;

                       -- If the Transfer values are null then set default values
                       -- Since both dept_id and main_acct are null or both have
                       IF va_transfer_dept_id IS NULL THEN
                           va_transfer_dept_id   := '  ';
                           va_transfer_main_acct := '    ';
                       END IF;
                   EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            va_transfer_dept_id   := '  ';
                            va_transfer_main_acct := '    ';
                       WHEN INVALID_NUMBER THEN
                            va_transfer_dept_id   := '  ';
                            va_transfer_main_acct := '    ';
                   END;
                ELSE -- vl_legis_ref is null
                   IF  va_tr_main_acct_col IS NULL THEN
                       va_transfer_main_acct := '    ';
                       va_transfer_dept_id   := '  ';
                    ELSE
                       va_transfer_main_acct := SUBSTR(vl_tr_main_acct,1,4);
                       va_transfer_dept_id   := SUBSTR(vl_tr_dept_id,1,2);
		   END IF;
	        END IF;
        END IF;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
               ' Acct - '||vl_acct_num) ;
        END IF;
        v_amount      := 0;
        v_period_activity := 0;
	if va_balance_type_val = 'P' then
           v_amount        := vl_legis_amount   ;
           v_period_dr     := 0;
           v_period_cr     := 0;
	 else
           v_period_activity := vl_legis_amount;
	End if;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
               'period_net_dr - '|| v_period_dr) ;
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
               'period_net_cr - '|| v_period_cr) ;
        END IF;
        CREATE_FACTS_RECORD             ;
        If vp_retcode <> 0 Then
          Return ;
        End If ;
    End Loop;  --sla cursor;
    End Loop;  -- legis cur ;

    -- Close the Legislative Indicator Cursor
    Begin
      dbms_sql.Close_Cursor(vl_legis_cursor);
     Exception
      When Others Then
       vp_retcode := sqlcode ;
       VP_ERRBUF  := sqlerrm ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
              '.close_vl_legis_cursor', vp_errbuf) ;
       Return ;
    End ;

    -- Once the Legislative Indicator or Public Law code
    -- is processesed, no need to proceed further for this
    -- acct/fund combination. Going to the Next Account
    Exit ;
       EXCEPTION
        -- Process any Exceptions in Legislative Indicator
        -- Processing
        When Others Then
            vp_retcode := sqlcode ;
            vp_errbuf := sqlerrm ||
            ' [ PROCESS_FACTS_TRANSCTIONS-LEGIS IND  ] ' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
              '.exception_1', vp_errbuf) ;
            Return ;
       END ;
    -------------- Apportionment Category Processing Starts ----------------
 Elsif (va_appor_cat_flag = 'Y' ) then
        -- Derive the Apportionment Category
        -- Apportionment Category Processing done only for FACTS II
        --Bug#3376230 to include va_appor_cat_val = 'A' too
      /*      -- 2005 FACTS II Enhancemnt to include category C

            IF va_appor_cat_val = 'C'  THEN
                    va_appor_cat_b_dtl := '000';
                    va_appor_cat_b_txt :=  'Default Cat B Code';
                    va_prn_num         := '000';
                    va_prn_txt         := 'Default PRN Code';

            END IF;  */

    If va_appor_cat_val IN ('A', 'B') then
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	   ' ++++++++ Apportionment Category Processing ++++++++++') ;
       End If ;
       -- Get the Program segment name for the current fund value
       GET_PROGRAM_SEGMENT (vl_fund_value) ;

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	    'Fund - '||vl_fund_value||' > CAT B Prog Seg - '||v_catb_prg_seg_name|| ' > PRN Prog Seg - '||v_prn_prg_seg_name);
       End If ;

       If v_catb_prg_seg_name IS NOT NULL OR
              v_prn_prg_seg_name IS NOT NULL Then
         Begin
           vl_appor_cursor := DBMS_SQL.OPEN_CURSOR  ;
          Exception
           When Others Then
            vp_retcode := sqlcode ;
            VP_ERRBUF  := sqlerrm ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
		'.open_vl_appor_cursor', vp_errbuf) ;
            Return ;
         End ;
         -- Dynamic SQL to group the amount by Fund, Acct
         -- and Program for the Beginning Balance
         -- Processing Apportionment Category for Beginning Balance

         va_balance_type_val := 'B' ;
         vl_appor_period := ' AND GLB.PERIOD_NUM = :period_num
                     AND GLB.PERIOD_YEAR = :report_fiscal_yr ';
         Build_Appor_Select(vl_ccid,
                               vl_acct_num,
                               vl_fund_value,
                               v_fiscal_yr,
                               vl_appor_period,
                               vl_appor_select) ;
         Begin
           dbms_sql.parse(vl_appor_cursor,vl_appor_select,
             DBMS_SQL.V7);
          Exception
           When Others Then
             vp_retcode := sqlcode              ;
             vp_errbuf  := sqlerrm || ' [MAIN - APPOR]' ;
             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
                '.parse_vl_appor_cursor', vp_errbuf) ;
             Return ;
         End ;

	 -- Bind the variables
         dbms_sql.bind_variable(vl_appor_cursor, ':ccid', vl_ccid);
         dbms_sql.bind_variable(vl_appor_cursor, ':actual_flag', 'A');
         dbms_sql.bind_variable(vl_appor_cursor, ':fund_value', vl_fund_value);
         dbms_sql.bind_variable(vl_appor_cursor, ':acct_number', vl_acct_num);
         dbms_sql.bind_variable(vl_appor_cursor, ':fiscal_year', v_fiscal_yr);
         dbms_sql.bind_variable(vl_appor_cursor, ':period_num', v_period_num);
         dbms_sql.bind_variable(vl_appor_cursor, ':report_fiscal_yr',
							vp_report_fiscal_yr);
         dbms_sql.bind_variable(vl_appor_cursor, ':set_of_books_id',
                                                        vp_set_of_books_id);
         dbms_sql.bind_variable(vl_appor_cursor, ':currency_code',
                                                        vp_currency_code);


         dbms_sql.define_column(vl_appor_cursor,1,vl_acct_num,25);
         dbms_sql.define_column(vl_appor_cursor,2,vl_fund_value,25);
            vl_counter := 3;

         IF v_catb_prg_seg_name IS NOT NULL THEN
          dbms_sql.define_column(vl_appor_cursor,vl_counter,vl_catb_program,25);
          vl_counter := vl_counter + 1;
         END IF;

         IF v_prn_prg_seg_name IS NOT NULL THEN
           dbms_sql.define_column(vl_appor_cursor,vl_counter,vl_prn_program,25);
           vl_counter := vl_counter + 1;
         END IF;

         dbms_sql.define_column(vl_appor_cursor,vl_counter,v_amount);
                vl_counter := vl_counter + 1;
         dbms_sql.define_column(vl_appor_cursor,vl_counter,vl_period_activity);
                  vl_counter := vl_counter + 1;
         dbms_sql.define_column(vl_appor_cursor,vl_counter,v_period_dr);
              vl_counter := vl_counter + 1;
         dbms_sql.define_column(vl_appor_cursor,vl_counter,v_period_cr);
                 vl_counter := vl_counter + 1;

         If v_cohort_Seg_name is not null Then
          dbms_sql.define_column(vl_appor_cursor, vl_counter, vl_cohort_yr, 25);
         end If ;

         Begin
            vl_exec_ret := dbms_sql.execute(vl_appor_cursor);
          Exception
            When Others Then
              vp_retcode := sqlcode ;
              vp_errbuf  := sqlerrm||'[execute_vl_appor_cursor]' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
                          '.execute_vl_appor_cursor', vp_errbuf) ;
              Return ;
         End ;

	  --------------------------------------------------------------------------
          -- Reset the counter for apportionment cat b Dtl
          -- vl_appor_ctr := 0 ;
          LOOP
             if dbms_sql.fetch_rows(vl_appor_cursor) = 0 then
                        exit;
              else
                -- Fetch the Records into Variables
                dbms_sql.column_value(vl_appor_cursor,1,vl_acct_num);
                dbms_sql.column_value(vl_appor_cursor,2,vl_fund_value);

            vl_counter := 3;
           IF v_catb_prg_seg_name IS NOT NULL THEN
             dbms_sql.column_value(vl_appor_cursor,vl_counter,vl_catb_program);
              vl_counter := vl_counter + 1;
            END IF;

           IF v_prn_prg_seg_name IS NOT NULL THEN
               dbms_sql.column_value(vl_appor_cursor,vl_counter,vl_prn_program);
               vl_counter := vl_counter + 1;
            END IF;

             dbms_sql.column_value(vl_appor_cursor,vl_counter,v_amount);
             vl_counter := vl_counter + 1;

            dbms_sql.column_value(vl_appor_cursor,vl_counter,v_period_activity);
             vl_counter := vl_counter + 1;

              dbms_sql.column_value(vl_appor_cursor,vl_counter,v_period_dr);
              vl_counter := vl_counter + 1;

              dbms_sql.column_value(vl_appor_cursor,vl_counter,v_period_cr);
                vl_counter := vl_counter + 1;

             If v_cohort_Seg_name is not null Then
              --  vl_counter := vl_counter + 1;
                dbms_sql.column_value(vl_appor_cursor,vl_counter, vl_cohort_yr);
             end If ;
                -- vl_appor_ctr := vl_appor_ctr + 1 ;
                -- Get_Appor_Cat_B_Text(vl_program) ;

 		get_prc_val(vl_catb_program, vl_catb_rc_val, vl_catb_pgm_desc,
                            vl_prn_program, vl_prn_rc_val, vl_prn_pgm_desc);
                IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'Appor Beg --> Acct - '||vl_acct_num||
                    ' Fund >>>> - '||vl_fund_value ||
                    ' CAT B Prgm >>>> - '||vl_catb_program ||
                    ' PRN Prgm >>>> - '||vl_prn_program ||
                    ' Amt >>>> - '||v_amount ||
                    ' Text >>>> - ' ||va_appor_cat_b_txt) ;
                End If ;

                If vp_retcode <> 0 Then
                   Return ;
                End If ;

                va_appor_cat_b_dtl := vl_catb_rc_val;
	        va_appor_cat_b_txt := vl_catb_pgm_desc;
                 va_prn_num        := vl_prn_rc_val;
                 va_prn_txt        := vl_prn_pgm_desc;


                --Bug#3376230
/*
                IF va_appor_cat_val = 'A' THEN
                      va_appor_cat_b_dtl := LPAD(SUBSTR(vl_program, 1, 3), 3, '0');
                 ELSE
                      va_appor_cat_b_dtl := LPAD(to_char(vl_appor_ctr), 3, '0') ;
                END IF;
*/
                v_record_category := 'REPORTED' ;

                -- added the foll line to populate fund value
                -- to facilitate getting cat b sequence values
                v_tbal_fund_value := vl_fund_value;

                    CREATE_FACTS_RECORD     ;
                        If vp_retcode <> 0 Then
                            Return ;
                        End If ;
             End If ;
          End Loop ;
	-------------------------------------------------------------------

          -- Close the Apportionment Category Cursor
          Begin
            dbms_sql.Close_Cursor(vl_appor_cursor);
           Exception
            When Others Then
              vp_retcode := sqlcode ;
              VP_ERRBUF  := sqlerrm||'[vl_appor_cursor]' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
			'.close_vl_appor_cursor', vp_errbuf) ;
              Return ;
          End ;

          -- Apportionment Category B processing completed
          -- successfully, no need to proceed further for this
          -- acct/fund combination. Going to the Next Account
          Exit ;

        End If ; /* Program segment not null */
      END IF;  /* va_appor_cat_val = 'B' */
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, 'Apportion category is not B or
                              Program Segment Not defined Or Null');
      v_amount        := vl_amount ;
      v_ccid := vl_ccid;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_EXCEPTION, l_module_name,
		' So calling the default processing') ;
      END IF;
      DEFAULT_PROCESSING (vl_ccid,vl_fund_value,vl_acct_num,'E');
      EXIT; -- continue with the next account
   Else
     --- Default processing
     IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_EXCEPTION, l_module_name,
               'No special attributes defined , doing Normal processing');
     END IF;
     DEFAULT_PROCESSING (vl_ccid,vl_fund_value,vl_acct_num,'R',vl_pagebreak);
     -- Exit to end the Dummy Loop
     Exit ;
  End If ; /* va_apportionment_category_flag */
 End Loop ; /* for dummy Loop */


     -- Exit the Main loop in case no end of the cursor is reached
      If vl_main_fetch = 0  Then
        Exit ;
      End If ;
    END LOOP ; /* For the Main Cursor */


    -- Close the Main Cursor
    Begin
        dbms_sql.Close_Cursor(vl_main_cursor);
    Exception
        When Others Then
            vp_retcode := sqlcode ;
            VP_ERRBUF  := sqlerrm||'[vl_main_cursor]' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
		'.close_vl_main_cursor', vp_errbuf) ;
            Return ;
    End ;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	'Calling Rollup process '|| v_tbal_fund_value);
    END IF;

    IF (vl_row_count > 0) then
         FACTS_ROLLUP_RECORDS;
         -- process_cat_b_seq('REPORTED');
	 v_fund_count := v_fund_count + 1;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    vp_retcode := sqlcode ;
    vp_errbuf  := sqlerrm ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
    RAISE;
END PROCESS_FACTS_TRANSACTIONS ;
-- -------------------------------------------------------------------
--       PROCEDURE LOAD_FACTS_ATTRIBUTES
-- -------------------------------------------------------------------
--    This procedure selects the attributes for the Account number
-- segment from FV_FACTS_ATTRIBUTES table and load them into global
-- variables for usage in the FACTS Main process. It also calculates
-- one time pull up values for the account number that does not
-- require drill down into GL transactions.
-- ------------------------------------------------------------------
PROCEDURE LOAD_FACTS_ATTRIBUTES (acct_num Varchar2,
                                 fund_val Varchar2,
		                  v_retcode OUT NOCOPY number)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'LOAD_FACTS_ATTRIBUTES';
  /*
   Commented by 7324248
   vl_financing_acct_flag  Varchar2(1)     ;
    vl_established_fy   number      ;
    */
    vl_resource_type    Varchar2(80)    ;
    vl_fund_category    Varchar2(1) ;
BEGIN

  Begin
           v_retcode := 0;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'LOAD - Acct Num -> ' || acct_num || ' sob -> '
          || vp_set_of_books_id ) ;
        END IF;
      SELECT  balance_type,
        public_law_code,
        reimburseable_flag,
        Decode(availability_time, 'N', ' ', availability_time),
        bea_category,
        apportionment_category,
        -- Decode(substr(transaction_partner,1,1),'N',' ',
         --   substr(transaction_partner,1,1)),
        substr(transaction_partner,1,1),
        borrowing_source,
        definite_indefinite_flag,
        legislative_indicator,
        pya_flag,
        authority_type,
        deficiency_flag,
        function_flag,
        advance_flag,
        transfer_flag
      INTO
        va_balance_type_flag,
        va_public_law_code_flag,
        va_reimburseable_flag,
        va_availability_flag,
        va_bea_category_flag,
        va_appor_cat_flag,
        va_transaction_partner_val,
        va_borrowing_source_flag,
        va_def_indef_flag,
        va_legis_ind_flag,
        va_pya_flag,
        va_authority_type_flag,
        va_deficiency_flag,
        va_function_flag,
        va_advance_flag,
        va_transfer_ind
      FROM    FV_FACTS_ATTRIBUTES
      WHERE   Facts_Acct_Number = acct_num
      and set_of_books_id = vp_set_of_books_id ;

        IF NOT v_year_gtn2001 THEN
            va_advance_flag  := ' ';
            va_transfer_ind  := ' ';
        END IF;

    Exception
    When NO_DATA_FOUND Then
        v_retcode := -1 ;
            return;
    When Others Then
        vp_retcode := sqlcode ;
        vp_errbuf  := sqlerrm ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception_1', vp_errbuf) ;
            return;
    End ;
--------------------------------------------------------------------------------
    -- Get the attribute column names for public_law_code and other
    -- attributes
    BEGIN

       SELECT  factsII_pub_law_code_attribute,
               factsII_advance_type_attribute,
               factsII_tr_main_acct_attribute,
               factsII_tr_dept_id_attribute
       INTO    va_pl_code_col, va_advance_type_col,
               va_tr_main_acct_col, va_tr_dept_id_col
       FROM    fv_system_parameters;

       -- Set this global variable to true if facts attribute columns
       -- have been defined in Federal System Parameters form. If it is false
       -- then it means that the columns have not been setup, in which case
       -- process should end with a warning
       IF (va_pl_code_col IS NULL OR
           va_advance_type_col IS NULL OR
           va_tr_main_acct_col IS NULL OR
           va_tr_dept_id_col IS NULL)
         THEN
          v_facts_attributes_setup := FALSE ;
        ELSE
          v_facts_attributes_setup := TRUE ;
       END IF;

     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
               WHEN OTHERS THEN
                    vp_retcode := sqlcode ;
                    vp_errbuf  := sqlerrm ;
                      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.no_data_found', vp_errbuf) ;
                    RETURN;
    END;
--------------------------------------------------------------------------------
    -- Getting the One time Pull up Values
    Begin
        Select  UPPER(fts.resource_type),
        def_indef_flag,
        ffp.fund_category,
        RPAD(substr(bea_category,1,5), 5)
        INTO    vl_resource_type,
        va_def_indef_val,
        vl_fund_category,
        va_bea_category_val
        From    fv_treasury_symbols   fts,
        fv_fund_parameters    ffp
        WHERE   ffp.treasury_symbol_id  = fts.treasury_symbol_id
        AND     ffp.fund_value      = fund_val
    AND fts.treasury_symbol = vp_treasury_symbol
        AND     fts.set_of_books_id     = vp_set_of_books_id
        AND     ffp.set_of_books_id     = vp_set_of_books_id  ;
    Exception
    When NO_DATA_FOUND Then
        vp_retcode := -1 ;
        vp_errbuf := 'Error getting Fund Category value for the fund - '||
              fund_val || ' [LOAD_FACTS_ATTRIBURES]' ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.no_data_found1', vp_errbuf) ;
            return;
    When Others Then
        vp_retcode := sqlcode ;
        vp_errbuf  := sqlerrm  || ' [LOAD_FACTS_ATTRIBURES]' ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception_2', vp_errbuf) ;
            return;
    End ;
    ------------------------------------------------
    -- Deriving Indefinite Definite Flag
    ------------------------------------------------
    If va_def_indef_flag <> 'Y' Then
    va_def_indef_val := ' ' ;
   End if;

    ------------------------------------------------
    -- Deriving Public Law Code Flag
    ------------------------------------------------
    If va_public_law_code_flag = 'N' Then
    va_public_law_code_val := '       ' ;
    End If ;
    ------------------------------------------------
    -- Deriving Apportionment Category Code
    ------------------------------------------------
    If va_appor_cat_flag = 'Y' Then
    If vl_fund_category IN ('A','S') Then
        va_appor_cat_val := 'A' ;
    ElsIf vl_fund_category IN ('B','T') Then
        va_appor_cat_val := 'B' ;
    ElsIf vl_fund_category IN ('C','R') Then
        va_appor_cat_val := 'C' ;
    Else
        va_appor_cat_val := ' ' ;
    End If ;
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Acct - ' || acct_num ||
        ' Fund cat - ' || vl_fund_category || ' Appr Cat - ' ||
        va_appor_cat_val || ' Flag - ' || va_appor_cat_flag)  ;
    End If ;
    Else
        va_appor_cat_val := ' ' ;
    End If ;

/*    ----------------------------------------
    -- Default the Reporting Codes when the
    -- Apportionment Category is unchecked
    ----------------------------------------

    IF NVL(va_appor_cat_flag,'N') = 'N' THEN
       IF vl_fund_category IN ('A','B','C','R','S','T') THEN
            va_appor_cat_b_dtl := '000';
            va_appor_cat_b_txt :=  'Default Cat B Code';
            va_prn_num         := '000';
            va_prn_txt         := 'Default PRN Code';

       END IF;

       IF ( FND_LOG.LEVEL_STATEMENT >=
         FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                    l_module_name, 'Defaulting the Reporting'
                               ||'codes as the apportionment '
                                   ||'Category flag is N ') ;
       End If ;
    END IF;  */

    ------------------------------------------------
    -- Deriving Authority Type
    ------------------------------------------------
    If va_authority_type_flag = 'N' then
    va_authority_type_val := ' ' ;
    Else
    va_authority_type_val := va_authority_type_flag  ;
    End If ;
    --------------------------------------------------------------------
    -- Transaction Partner Value derived from FV_FACTS_ATTRIBUTES table
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- Deriving Reimburseable Flag Value
    --------------------------------------------------------------------
    If va_reimburseable_flag = 'Y' Then
        If vl_fund_category IN ('A', 'B', 'C') Then
        va_reimburseable_val := 'D' ;
        ElsIf vl_fund_category IN ('R', 'S', 'T') Then
        va_reimburseable_val := 'R' ;
    Else
        va_reimburseable_val := ' ' ;
    End If ;
    Else
    va_reimburseable_val := ' ' ;
    End If ;
    --------------------------------------------------------------------
    -- Deriving BEA Category
    --------------------------------------------------------------------
    If va_bea_category_flag <> 'Y'  then

/* -- now bea category deived from fv_fund_parameters
    Begin
        Select RPAD(substr(ffba.bea_category,1,5), 5)
        Into   va_bea_category_val
        from fv_fund_parameters_all
        where fund_value = vl_fund_value
        and  set_of_books_id = vp_set_of_books_id;

        From   fv_facts_budget_accounts ffba,

           fv_facts_federal_accounts    fffa,
           fv_treasury_symbols      fts ,
           fv_facts_bud_fed_accts   ffbfa
        Where  fts.federal_acct_symbol_id  = fffa.federal_acct_symbol_id
        AND    fffa.federal_acct_symbol_id = ffbfa.federal_acct_symbol_id
        AND    ffbfa.budget_acct_code_id   = ffba.budget_acct_code_id
        AND    fts.treasury_symbol         = vp_treasury_symbol
        AND    fts.set_of_books_id         = vp_set_of_books_id
        AND    fffa.set_of_books_id        = vp_set_of_books_id
        AND    ffbfa.set_of_books_id       = vp_set_of_books_id
        AND    ffba.set_of_books_id        = vp_set_of_books_id ;
    Exception
        When NO_DATA_FOUND then
        va_bea_category_val     := RPAD(' ', 5);
    End ;

  Else
  */
   va_bea_category_val     := RPAD(' ', 5);
 End If ;

    --------------------------------------------------------------------
    -- Deriving Budget Function
    --------------------------------------------------------------------
    If va_function_flag = 'Y'  then
    Begin
        Select RPAD(substr(ffba.budget_function,1,3), 3)
        Into   va_budget_function
        From   fv_facts_budget_accounts ffba,
           fv_facts_federal_accounts    fffa,
           fv_treasury_symbols      fts ,
           fv_facts_bud_fed_accts   ffbfa
        Where  fts.federal_acct_symbol_id  = fffa.federal_acct_symbol_id
        AND    fffa.federal_acct_symbol_id = ffbfa.federal_acct_symbol_id
        AND    ffbfa.budget_acct_code_id   = ffba.budget_acct_code_id
        AND    fts.treasury_symbol         = vp_treasury_symbol
        AND    fts.set_of_books_id         = vp_set_of_books_id
        AND    fffa.set_of_books_id        = vp_set_of_books_id
        AND    ffbfa.set_of_books_id       = vp_set_of_books_id
        AND    ffba.set_of_books_id        = vp_set_of_books_id ;
        -- Check the value of Budget Function
    Exception
        When NO_DATA_FOUND then
        va_budget_function  := RPAD(' ', 3);
    End ;
  Else
    va_budget_function  := RPAD(' ', 3);
  End If ;
    --------------------------------------------------------------------
    -- Deriving  Borrowing Source
    --------------------------------------------------------------------
    If va_borrowing_source_flag = 'Y' then
        Begin
            Select RPAD(substr(ffba.borrowing_source,1,6), 6)
            Into   va_borrowing_source_val
            From   fv_facts_budget_accounts     ffba,
                   fv_facts_federal_accounts    fffa,
                   fv_treasury_symbols          fts ,
                   fv_facts_bud_fed_accts       ffbfa
            Where  fts.federal_acct_symbol_id  = fffa.federal_acct_symbol_id
            AND    fffa.federal_acct_symbol_id = ffbfa.federal_acct_symbol_id
            AND    ffbfa.budget_acct_code_id   = ffba.budget_acct_code_id
            AND    fts.treasury_symbol         = vp_treasury_symbol
            AND    fts.set_of_books_id         = vp_set_of_books_id
            AND    fffa.set_of_books_id        = vp_set_of_books_id
            AND    ffbfa.set_of_books_id       = vp_set_of_books_id
            AND    ffba.set_of_books_id        = vp_set_of_books_id ;
            -- Check the value of Borrowing Source
        Exception
            When NO_DATA_FOUND then
            va_borrowing_source_val := RPAD(' ', 6);
        End ;
    Else
        va_borrowing_source_val := RPAD(' ', 6);
    End If ;

    va_def_liquid_flag := ' ' ;
    va_deficiency_val := ' ' ;
EXCEPTION
    When Others Then
    vp_retcode := sqlcode ;
    vp_errbuf := sqlerrm || ' [LOAD_FACTS_ATTRIBUTES]' ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
END LOAD_FACTS_ATTRIBUTES ;
-- -------------------------------------------------------------------
--           PROCEDURE CALC_BALANCE
-- -------------------------------------------------------------------
--    This procedure Calculates the balance for the passed
--  Acct_segment, Fund Value and Period Nnumber .
-- ------------------------------------------------------------------
    Procedure CALC_BALANCE (ccid number,
                  Fund_value  Varchar2,
         acct_num       Varchar2,
         period_num         Number,
         period_year        NUMBER,
         Balance_Type       Varchar2,
         fiscal_year        VARCHAR2,
         amount           OUT NOCOPY    Number,
         period_activity  OUT NOCOPY NUMBER,
         pagebreak      varchar2 )
IS
  l_module_name VARCHAR2(200) := g_module_name || 'CALC_BALANCE';
    -- Variables for Dynamic SQL
    --vl_ret_val          Boolean := TRUE ;
    vl_exec_ret     Integer     ;
    vl_bal_cursor   Integer         ;
    vl_bal_select   Varchar2(2000)  ;
    -- for data access security
    das_id          NUMBER;
    das_where       VARCHAR2(600);

BEGIN
    Begin
        vl_bal_cursor := DBMS_SQL.OPEN_CURSOR  ;
    Exception
        When Others Then
            vp_retcode := sqlcode ;
            vp_errbuf  := sqlerrm || ' [CALC_BALANCE - Open Cursor] ' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.open_vl_bal_cursor', vp_errbuf) ;
            return;
    End ;
    -- Get the Balance
    vl_bal_select :=
    'Select Nvl(Decode(' || '''' || Balance_type || '''' ||
        ',' || '''' || 'B' || '''' ||
            ', SUM(GLB.BEGIN_BALANCE_DR - GLB.BEGIN_BALANCE_CR), ' ||
        '''' || 'E' || '''' || ', SUM((GLB.BEGIN_BALANCE_DR -
        GLB.BEGIN_BALANCE_CR) + (GLB.PERIOD_NET_DR - PERIOD_NET_CR ))),0),
            SUM(glb.period_net_dr - glb.period_net_cr) ,
            SUM(glb.period_net_dr) , sum(glb.period_net_cr)
        From    GL_BALANCES             GLB,
                GL_CODE_COMBINATIONS    GLCC
        WHERE   GLB.code_combination_id = GLCC.code_combination_id  ';

     -- Data Access Security
     das_id := fnd_profile.value('GL_ACCESS_SET_ID');
     das_where := gl_access_set_security_pkg.get_security_clause
                              (das_id,
                               gl_access_set_security_pkg.READ_ONLY_ACCESS,
                               gl_access_set_security_pkg.CHECK_LEDGER_ID,
                               to_char(vp_set_of_books_id), 'GLB',
                               gl_access_set_security_pkg.CHECK_SEGVALS,
                               null, 'GLCC', null);
     IF (das_where IS NOT NULL) THEN
             vl_bal_select := vl_bal_select || 'AND ' || das_where;
     END IF;


        vl_bal_select := vl_bal_select || 'AND glcc.code_combination_id = to_char(:ccid) ';

        vl_bal_select := vl_bal_select ||' AND glb.actual_flag =:actual_flag
          AND     GLCC.' || v_bal_seg_name || ' = :fund_value
          AND   GLCC.' || v_acc_seg_name || ' = :acct_num
          AND   GLCC.' || v_fyr_segment_name || ' =  :fiscal_year '||
          v_cohort_where ||
	' AND GLB.ledger_id  = :set_of_books_id
          AND   GLB.PERIOD_NUM =  :period_num
          AND   GLB.PERIOD_YEAR = :period_year
          AND   glb.currency_code = :currency_code '  ;

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'mg calc '||vl_bal_select) ;
          END IF;

    Begin
        dbms_sql.parse(vl_bal_cursor, vl_bal_select, DBMS_SQL.V7) ;
    Exception
        When Others Then
            vp_retcode := sqlcode ;
            vp_errbuf  := sqlerrm || ' [CALC_BALANCE - Parse] ' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.parse_vl_bal_cursor', vp_errbuf) ;
            return;
    End ;

     -- Bind the variables
     dbms_sql.bind_variable(vl_bal_cursor,':ccid', ccid);
     dbms_sql.bind_variable(vl_bal_cursor,':actual_flag', 'A');
     dbms_sql.bind_variable(vl_bal_cursor,':fund_value', fund_value);
     dbms_sql.bind_variable(vl_bal_cursor,':acct_num', acct_num);
     dbms_sql.bind_variable(vl_bal_cursor,':fiscal_year', fiscal_year);
     dbms_sql.bind_variable(vl_bal_cursor,':set_of_books_id', vp_set_of_books_id);
     dbms_sql.bind_variable(vl_bal_cursor,':period_num', period_num);
     dbms_sql.bind_variable(vl_bal_cursor,':period_year', period_year);
     dbms_sql.bind_variable(vl_bal_cursor,':currency_code', vp_currency_code);



        dbms_sql.define_column(vl_bal_cursor, 1, amount);
        dbms_sql.define_column(vl_bal_cursor, 2, period_activity);
        dbms_sql.define_column(vl_bal_cursor, 3, v_period_dr);
        dbms_sql.define_column(vl_bal_cursor, 4, v_period_cr);
    Begin
        vl_exec_ret := dbms_sql.execute(vl_bal_cursor);
    Exception
        When Others Then
            vp_retcode := sqlcode ;
            vp_errbuf  := sqlerrm || ' [CALC_BALANCE - Execute Cursor] ' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.execute_vl_bal_cursor', vp_errbuf) ;
    End ;
    Loop
        if dbms_sql.fetch_rows(vl_bal_cursor) = 0 then
            exit;
        else
            -- Fetch the Records into Variables
            dbms_sql.column_value(vl_bal_cursor, 1, amount);
            dbms_sql.column_value(vl_bal_cursor, 2, period_activity);
            dbms_sql.column_value(vl_bal_cursor, 3, v_period_dr);
            dbms_sql.column_value(vl_bal_cursor, 4, v_period_cr);
        end if;
    End Loop ;
    -- Close the Balance Cursor
    Begin
        dbms_sql.Close_Cursor(vl_bal_cursor);
    Exception
        When Others Then
            vp_retcode := sqlcode ;
            VP_ERRBUF  := sqlerrm ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.close_vl_bal_cursor', vp_errbuf) ;
            Return ;
    End ;
EXCEPTION
    When Others Then
        vp_retcode := sqlcode ;
        vp_errbuf  := sqlerrm || ' [CALC_BALANCE - Others]' ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
        return;
END CALC_BALANCE ;
-- -------------------------------------------------------------------
--       PROCEDURE CREATE_FACTS_RECORD
-- -------------------------------------------------------------------
--    Inserts a new record into FV_FACTS_TEMP table with the current
--  values from the  global variables.
-- ------------------------------------------------------------------
PROCEDURE   CREATE_FACTS_RECORD
IS
--
  l_module_name VARCHAR2(200) := g_module_name || 'CREATE_FACTS_RECORD';
   vl_disbursements_flag    VARCHAR2(1);
   /*
   * Commented bY 7324248
   vl_exists                Varchar2(1)     ;
   v_ussgl_acct             fv_facts_ussgl_accounts.ussgl_account%TYPE;
   v_excptn_cat             fv_facts_temp.fct_int_record_category%TYPE;
   vl_enabled_flag          fv_facts_ussgl_accounts.ussgl_enabled_flag%TYPE;
   vl_reporting_type        fv_facts_ussgl_accounts.reporting_type%TYPE;
    */
   vl_fyr_segment_value     fv_pya_fiscalyear_map.fyr_segment_value%type;
   vl_parent_sgl_acct_num   fv_facts_temp.parent_sgl_acct_number%TYPE;
   vl_reimb_agree_sel          VARCHAR2(250);
   vl_reimb_agree_seg_val      VARCHAR2(30);

--Modifed for FV ER bug 8760767

/*  cursor vl_pya_cursor is SELECT decode(pya_flag,'Y','X',' ')
        FROM   fv_facts_attributes
        WHERE  ussgl_acct_number = v_sgl_acct_num;
*/

 cursor vl_pya_cursor is SELECT decode(pya_flag,'Y','X',' ')
        FROM   fv_facts_attributes
        WHERE  ussgl_acct_number = v_sgl_acct_num
        AND set_of_books_id=vp_set_of_books_id;

BEGIN
        va_legis_ind_val    := ' ';
        va_pya_val    := ' ';
        v_year_budget_auth  := '   ';

      Begin
        open vl_pya_cursor;
        fetch vl_pya_cursor into va_pya_val;
        close vl_pya_cursor;
      exception
         when no_data_found then
        null;
      End ;

      Begin
        SELECT disbursements_flag INTO   vl_disbursements_flag
         FROM   fv_facts_ussgl_accounts
        WHERE  ussgl_account = v_sgl_acct_num;
      exception
       when no_data_found then
       null;
      End ;

   IF  (v_time_frame    = 'NO_YEAR' AND v_financing_acct      = 'N'
       AND vl_disbursements_flag = 'Y' AND (v_amount <> 0 OR
					    v_period_dr <> 0 OR
                                            v_period_cr <> 0 ))  THEN

       SELECT fyr_segment_value INTO   vl_fyr_segment_value
       FROM   fv_pya_fiscalyear_map
       WHERE  period_year = vp_report_fiscal_yr
       AND    set_of_books_id = vp_set_of_books_id;

      IF vl_fyr_segment_value IS NOT NULL THEN
        IF vl_fyr_segment_value = v_fiscal_yr THEN
           v_year_budget_auth := 'NEW';
        ELSE
           v_year_budget_auth := 'BAL';
        END IF;
      END IF;
   END IF;
/*
Commented for bug 8824283
   ----------------------------------------------------------------
      --Bug 7324248
      --Derive Transaction Partner attribute
      --using the Reimbursable Agreement segment value,
      --if the segment has been setup or has a value,
      --else default to 0.
   ----------------------------------------------------------------
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                 'va_transaction_partner_val ::g_reimb_agree_seg_name ::'
                 ||va_transaction_partner_val||'::'||g_reimb_agree_seg_name);

   IF va_transaction_partner_val <> 'N' THEN
       IF g_reimb_agree_seg_name IS NOT NULL THEN

          --get the reimb agree seg value from the ccid
          vl_reimb_agree_sel :=
          ' SELECT glcc.'||g_reimb_agree_seg_name||
          ' FROM gl_code_combinations glcc
            WHERE glcc.code_combination_id = :ccid
            AND   chart_of_accounts_id = '||vp_coa_id;

            EXECUTE IMMEDIATE vl_reimb_agree_sel INTO
              vl_reimb_agree_seg_val USING vl_ccid;

              IF vl_reimb_agree_seg_val IS NOT NULL THEN
                 get_trx_part_from_reimb(vl_reimb_agree_seg_val);
                 IF vp_retcode <> 0 THEN
                    RETURN;
                 END IF;
               ELSE
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                 'Reimbursable Agreement value is null!!' ||
                 ' Setting transaction partner value to 0.');
                 va_transaction_partner_val := 0;
               END IF;
        ELSE
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
               'Reimbursable Agreement segment is not defined!!' ||
               ' Setting transaction partner value to 0.');
               va_transaction_partner_val := 0;
       END IF;
   END IF;
*/

    INSERT INTO FV_FACTS_TEMP
        (code_combination_id,
         SGL_ACCT_NUMBER ,
        COHORT          ,
        BEGIN_END           ,
        INDEF_DEF_FLAG      ,
        APPOR_CAT_B_DTL     ,
        APPOR_CAT_B_TXT     ,
        PUBLIC_LAW          ,
        APPOR_CAT_CODE      ,
        AUTHORITY_TYPE      ,
        TRANSACTION_PARTNER     ,
        REIMBURSEABLE_FLAG      ,
        BEA_CATEGORY            ,
        BORROWING_SOURCE    ,
        DEF_LIQUID_FLAG     ,
        DEFICIENCY_FLAG     ,
        AVAILABILITY_FLAG   ,
        LEGISLATION_FLAG    ,
        PYA_FLAG            ,
        AMOUNT              ,
        DEBIT_CREDIT        ,
        TREASURY_SYMBOL_ID      ,
        FCT_INT_RECORD_CATEGORY ,
        FCT_INT_RECORD_TYPE ,
        TBAL_FUND_VALUE     ,
        TBAL_ACCT_NUM      ,
        BUDGET_FUNCTION     ,
        ADVANCE_FLAG        ,
        TRANSFER_DEPT_ID    ,
        TRANSFER_MAIN_ACCT  ,
        YEAR_BUDGET_AUTH    ,
        period_activity     ,
        amount1     ,
        amount2     ,
        parent_sgl_acct_number ,
        PROGRAM_RPT_CAT_NUM,
	PROGRAM_RPT_CAT_TXT)
    Values (vl_ccid                  ,
            v_sgl_acct_num      ,
            va_cohort       ,
            va_balance_type_val ,
            va_def_indef_val    ,
            va_appor_cat_b_dtl  ,
            va_appor_cat_b_txt      ,
            va_public_law_code_val  ,
            va_appor_cat_val    ,
            va_authority_type_val   ,
          --va_transaction_partner_val,
            DECODE(va_transaction_partner_val,'N',NULL,
                   va_transaction_partner_val),
          va_reimburseable_val    ,
            va_bea_category_val     ,
            va_borrowing_source_val ,
            va_def_liquid_flag  ,
            va_deficiency_val   ,
            va_availability_flag    ,
            va_legis_ind_val    ,
            va_pya_val    ,
            v_amount        ,
            NULL            ,
            v_treasury_symbol_id    ,
            v_record_category   ,
            'TB'       ,
            v_tbal_fund_value   ,
            v_tbal_acct_num,
            va_budget_function  ,
            va_advance_type_val ,
            va_transfer_dept_id ,
            va_transfer_main_acct   ,
            v_year_budget_auth  ,
            v_period_activity   ,
            v_period_dr     ,
            v_period_cr     ,
            vl_parent_sgl_acct_num,
	    va_prn_num,
            va_prn_txt) ;


    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Created FACTS Record') ;
    End If ;
EXCEPTION
    When Others Then
    vp_retcode  :=  sqlcode ;
    vp_errbuf   :=  sqlerrm || ' [CREATE_FACTS_RECORD] ' ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
        return;
END CREATE_FACTS_RECORD ;
-- -------------------------------------------------------------------
--       PROCEDURE GET_PROGRAM_SEGMENT
-- -------------------------------------------------------------------
-- Gets the Program segment name from FV_FACTS_PRC_HDR table
-- -------------------------------------------------------------------
PROCEDURE  GET_PROGRAM_SEGMENT(v_fund_value Varchar2)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'GET_PROGRAM_SEGMENT';
  vl_seg_found  VARCHAR2(1) := 'N';
vl_prg_seg_name   fv_facts_prc_hdr.program_segment%TYPE;
vl_prc_header_id    NUMBER(15);
vl_prc_flag   fv_facts_prc_hdr.prc_mapping_flag%TYPE;
vl_code_type fv_facts_prc_hdr.code_type%TYPE;
vl_prg_val_set_id NUMBER(15);

BEGIN

 -- INITIALIZE ALL VARIABLES

         v_prn_prg_seg_name := NULL ;
         v_catb_prg_seg_name := NULL;

  FOR type in 1..2
  LOOP
        IF type = 1 THEN
         vl_code_type := 'B';
        ELSE
         vl_code_type := 'N';
        END IF;
       vl_prg_seg_name := NULL;
       vl_prc_flag := NULL;
       vl_prc_header_id := NULL;
       vl_seg_found := 'N';


  BEGIN

    SELECT program_segment, prc_mapping_flag,
           prc_header_id
    INTO   vl_prg_seg_name, vl_prc_flag,
           vl_prc_header_id
    FROM   fv_facts_prc_hdr
    WHERE  treasury_symbol_id = v_treasury_symbol_id
    AND    code_type = vl_code_type
    AND    fund_value = v_fund_value
    AND    set_of_books_id = vp_set_of_books_id;

    vl_seg_found := 'Y';
   EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
  END;

  IF vl_seg_found = 'N' THEN
    BEGIN

      SELECT program_segment, prc_mapping_flag,
             prc_header_id
      INTO   vl_prg_seg_name, vl_prc_flag,
             vl_prc_header_id
      FROM   fv_facts_prc_hdr
      WHERE  treasury_symbol_id = v_treasury_symbol_id
      AND    fund_value = 'ALL-A'
      AND    code_type = vl_code_type
      AND    va_appor_cat_val = 'A'
      AND    set_of_books_id = vp_set_of_books_id;

      vl_seg_found := 'Y';
     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
  END IF;

  IF vl_seg_found = 'N' THEN
    BEGIN

      SELECT program_segment, prc_mapping_flag,
             prc_header_id
      INTO   vl_prg_seg_name, vl_prc_flag,
             vl_prc_header_id
      FROM   fv_facts_prc_hdr
      WHERE  treasury_symbol_id = v_treasury_symbol_id
      AND    fund_value = 'ALL-B'
      AND    code_type = vl_code_type
      AND    va_appor_cat_val = 'B'
      AND    set_of_books_id = vp_set_of_books_id;

      vl_seg_found := 'Y';
     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
  END IF;

  IF vl_seg_found = 'N' THEN
    BEGIN

      SELECT program_segment, prc_mapping_flag,
             prc_header_id
      INTO   vl_prg_seg_name, vl_prc_flag,
             vl_prc_header_id
      FROM   fv_facts_prc_hdr
      WHERE  treasury_symbol_id = v_treasury_symbol_id
      AND    code_type = vl_code_type
      AND    fund_value = 'ALL-FUNDS'
      AND    set_of_books_id = vp_set_of_books_id;

      vl_seg_found := 'Y';
     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
  END IF;

  IF vl_seg_found = 'N' THEN
    BEGIN

      SELECT program_segment, prc_mapping_flag,
             prc_header_id
      INTO   vl_prg_seg_name, vl_prc_flag,
             vl_prc_header_id
      FROM   fv_facts_prc_hdr
      WHERE  treasury_symbol_id = -1
      AND    code_type = vl_code_type
      AND    fund_value = 'ALL-A'
      AND    va_appor_cat_val = 'A'
      AND    set_of_books_id = vp_set_of_books_id;

      vl_seg_found := 'Y';
     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
  END IF;

  IF vl_seg_found = 'N' THEN
    BEGIN

      SELECT program_segment, prc_mapping_flag,
             prc_header_id
      INTO   vl_prg_seg_name, vl_prc_flag,
             vl_prc_header_id
      FROM   fv_facts_prc_hdr
      WHERE  treasury_symbol_id = -1
      AND    fund_value = 'ALL-B'
      AND    code_type = vl_code_type
      AND    va_appor_cat_val = 'B'
      AND    set_of_books_id = vp_set_of_books_id;

      vl_seg_found := 'Y';
     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
  END IF;


  IF vl_seg_found = 'N' THEN
    BEGIN

      SELECT program_segment, prc_mapping_flag,
             prc_header_id
      INTO   vl_prg_seg_name, vl_prc_flag,
             vl_prc_header_id
      FROM   fv_facts_prc_hdr
      WHERE  treasury_symbol_id = -1
      AND    fund_value = 'ALL-FUNDS'
      AND    code_type = vl_code_type
      AND    set_of_books_id = vp_set_of_books_id;

     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
  END IF;

    If vl_prg_seg_name is NOT NULL AND  vl_prc_flag = 'N' THEN

    -- Get the value set id for the program segment
    Begin
        -- Getting the Value set Id for finding hierarchies
        select  flex_value_set_id
        into    vl_prg_val_set_id
        from    fnd_id_flex_segments
        where   application_column_name = vl_prg_seg_name
        and application_id      = 101
        and     id_flex_code            = 'GL#'
        and     id_flex_num             = vp_coa_id ;
    Exception
        When NO_DATA_FOUND Then
            vp_retcode := -1 ;
            vp_errbuf := 'Error getting Value Set Id for segment'
                            ||vl_prg_seg_name||' [GET_PROGRAM_SEGMENT]' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||
                       '.no_data_found', vp_errbuf) ;
        When TOO_MANY_ROWS Then
            -- Too many value set ids returned for the program segment.
            vp_retcode  := -1 ;
            vp_errbuf   := 'Program Segment - '||vl_prg_seg_name||
                              ' returned
                more than one Value Set !! '||'[ GET_PROGRAM_SEGMENT ]' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
               '.exception_1', vp_errbuf) ;
    End ;
END IF;

IF type = 1 THEN
 IF va_appor_cat_val = 'B' THEN
  v_catb_prg_seg_name := vl_prg_seg_name;
  v_catb_rc_flag   :=  vl_prc_flag;
  v_catb_rc_header_id := vl_prc_header_id;
 v_catb_prg_val_set_id := vl_prg_val_set_id;
 ELSIF va_appor_cat_val = 'A' THEN
    v_catb_prg_seg_name := NULL;
    v_catb_rc_flag   := NULL;

 END IF;
ELSE
  v_prn_prg_seg_name := vl_prg_seg_name;
  v_prn_rc_flag   :=  vl_prc_flag;
  v_prn_rc_header_id := vl_prc_header_id;
  v_prn_prg_val_set_id := vl_prg_val_set_id;
END IF;

END LOOP;
EXCEPTION
    When TOO_MANY_ROWS Then
    -- Fund Value not found in FV_BUDGET_DISTRIBUTION_HDR table.
    vp_retcode  := -1 ;
    vp_errbuf   := 'Fund Value - ' || v_fund_value || '  returned more
               than one program segment value !! ' ||
               '[ GET_PROGRAM_SEGMENT ]' ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
        return;
    WHEN OTHERS THEN
      vp_retcode := sqlcode ;
      vp_errbuf  := sqlerrm ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
      RAISE;
END GET_PROGRAM_SEGMENT ;
-- -------------------------------------------------------------------
--       PROCEDURE GET_APPOR_CAT_B_TEXT
-- -------------------------------------------------------------------
-- Gets the Apportionment Category B Detail and Text Information. Program
-- segment value is passed to get the Text information and Counter value
-- passed to get the converted text value (For Example when the appor_cnt
-- value passed is 3 then the value returned is '003'
-- -------------------------------------------------------------------
PROCEDURE  get_segment_text(p_program IN   VARCHAR2,
                                p_prg_val_set_id IN  NUMBER,
                                p_seg_txt OUT NOCOPY VARCHAR2)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'GET_APPOR_CAT_B_TEXT';
  --vl_prg_val_set_id NUMBER(15);
Begin
    -- Get the Apportionment Category B Text
    Select Decode(ffvl.Description,
        NULL, RPAD(' ',25,' '), RPAD(ffvl.Description,25,' '))
    Into p_seg_txt
    From fnd_flex_values_tl ffvl,
    fnd_flex_values    ffv
    where ffvl.flex_value_id    = ffv.flex_value_id
    AND   ffv.flex_value_set_id = p_prg_val_set_id
    AND   ffv.flex_value        = p_program
    AND   ffvl.language         = userenv('LANG');
Exception
    When NO_DATA_FOUND Then
        vp_retcode := -1 ;
        vp_errbuf  := 'Cannot Find Apportionment Category B Text for
               the Program ' || p_program||' [GET_SEGMENT_TEXT] ';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
        return;
    When TOO_MANY_ROWS Then
        vp_retcode := -1 ;
        vp_errbuf  := 'More then one Apportionment Category B Text found for
               the Program '||p_program||' [GET_SEGMENT_TEXT]';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
        return;
    WHEN OTHERS THEN
      vp_retcode := sqlcode ;
      vp_errbuf  := sqlerrm ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
      RAISE;
End ;
-- -------------------------------------------------------------------
--               PROCEDURE GET_ACCOUNT_TYPE
-- -------------------------------------------------------------------
-- Gets the Account Type Value for the passed Account Number.
-- -------------------------------------------------------------------
PROCEDURE  GET_ACCOUNT_TYPE (acct_num       Varchar2,
                             acct_type OUT NOCOPY Varchar2)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'GET_ACCOUNT_TYPE';
Begin

    -- Get the Account Type from fnd Tables
    Select substr(compiled_value_attributes, 5, 1)
    Into acct_type
    From fnd_flex_values
    where flex_value_set_id = v_acc_val_set_id
    and   flex_value = acct_num ;

    If acct_type IS NULL Then
    -- Process Null Account Types
      vp_retcode := -1 ;
      vp_errbuf := 'Account Type found null for the for the
            Account Number - ' || acct_num ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1', vp_errbuf) ;
      Return ;
    End If ;
Exception
    When No_Data_Found Then
    vp_retcode := -1 ;
    vp_errbuf := 'Account Type Cannot be derived for the Account Number - '
            || acct_num ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
    Return ;
    WHEN OTHERS THEN
      vp_retcode := sqlcode ;
      vp_errbuf  := sqlerrm ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
      RAISE;
End GET_ACCOUNT_TYPE ;
-- -------------------------------------------------------------------
--               PROCEDURE GET_SGL_PARENT
-- -------------------------------------------------------------------
--    Gets the SGL Parent Account for the passed account number
-- ------------------------------------------------------------------
Procedure GET_SGL_PARENT(
                        Acct_num        Varchar2,
                        parent_ac       OUT NOCOPY  Varchar2,
                        sgl_acct_num    OUT NOCOPY  Varchar2)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'GET_SGL_PARENT';
  --vl_exists     varchar2(1)             ;

BEGIN

	/* Check the a/c itself a USSGL a/c */

      BEGIN

        SELECT parent_flex_value
        INTO   parent_ac
        FROM   fnd_flex_value_hierarchies
        WHERE   (acct_num Between child_flex_value_low
                and child_flex_value_high)
        AND    flex_value_set_id = v_acc_val_set_id
        AND parent_flex_value <> 'T'
        AND parent_flex_value IN
                    (SELECT ussgl_account
                     FROM   fv_facts_ussgl_accounts
                     WHERE  ussgl_account = parent_flex_value);

       EXCEPTION
	WHEN NO_DATA_FOUND THEN
         parent_ac := NULL;

        WHEN OTHERS THEN
         vp_retcode := sqlcode ;
         vp_errbuf  := sqlerrm ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
              '.first_exception',vp_errbuf);
         RETURN;
      END;

      SELECT  ussgl_account
      INTO sgl_acct_num
      FROM fv_facts_ussgl_accounts
      WHERE ussgl_account =  acct_num ;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         BEGIN
            SELECT  ussgl_account
            INTO sgl_acct_num
            FROM fv_facts_ussgl_accounts
            WHERE ussgl_account =  parent_ac ;
	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
            sgl_acct_num := NULL    ;
	 END;

         RETURN ;
      WHEN OTHERS THEN
         vp_retcode := sqlcode ;
         vp_errbuf  := sqlerrm ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
              '.final_exception',vp_errbuf);
         RAISE;
END GET_SGL_PARENT ;
-- -------------------------------------------------------------------
--               PROCEDURE BUILD_APPOR_SELECT
-- -------------------------------------------------------------------
-- Builds the SQL Statement for the apportionment Category B Processing.
-- -------------------------------------------------------------------
Procedure Build_Appor_select ( ccid            number,
                               Acct_number  Varchar2,
                		Fund_Value  Varchar2,
                		fiscal_year     Varchar2,
                		appor_period    Varchar2,
                		select_stmt OUT NOCOPY Varchar2)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'Build_Appor_select';
  -- for data access security
  das_id              NUMBER;
  das_where           VARCHAR2(600);
Begin
    select_stmt :=
    'Select GLCC.' || v_acc_seg_name ||
          ', GLCC.' || v_bal_seg_name;

    IF v_catb_prg_seg_name IS NOT NULL THEN
       select_stmt := select_stmt ||
          ', GLCC.' || v_catb_prg_seg_name ;
    END IF;

    IF v_prn_prg_seg_name IS NOT NULL THEN
       select_stmt := select_stmt ||
          ', GLCC.' || v_prn_prg_seg_name ;
    END IF;

          select_stmt := select_stmt  ||
          ', SUM(GLB.BEGIN_BALANCE_DR - GLB.BEGIN_BALANCE_CR), ' ||
          ' SUM(GLB.PERIOD_NET_DR - PERIOD_NET_CR ), '||
          ' SUM(GLB.PERIOD_NET_DR) period_dr , sum( PERIOD_NET_CR ) period_cr '||
          v_cohort_select ||
         ' From GL_BALANCES             GLB,
            GL_CODE_COMBINATIONS    GLCC
         WHERE   GLB.code_combination_id  = GLCC.code_combination_id
         AND glcc.code_combination_id = :ccid
         AND glb.actual_flag = :actual_flag
         AND  GLCC.'|| v_bal_seg_name ||' = :Fund_Value
         AND GLCC.' || v_acc_seg_name ||' = :acct_number
         AND GLCC.' || v_fyr_segment_name ||' = :fiscal_year '||
         appor_period || v_cohort_where ||
       ' AND GLB.ledger_id = :set_of_books_id
         AND   glb.currency_code = :currency_code ';

     -- Data Access Security
     das_id := fnd_profile.value('GL_ACCESS_SET_ID');
     das_where := gl_access_set_security_pkg.get_security_clause
                              (das_id,
                               gl_access_set_security_pkg.READ_ONLY_ACCESS,
                               gl_access_set_security_pkg.CHECK_LEDGER_ID,
                               to_char(vp_set_of_books_id), 'GLB',
                               gl_access_set_security_pkg.CHECK_SEGVALS,
                               null, 'GLCC', null);
     IF (das_where IS NOT NULL) THEN
             select_stmt := select_stmt || 'AND ' || das_where;
     END IF;


     select_stmt := select_stmt || 'GROUP BY GLCC.' || v_acc_seg_name ||
         ', GLCC.' || v_bal_seg_name;


    IF v_prn_prg_seg_name IS NOT NULL THEN
       select_stmt := select_stmt ||
          ', GLCC.' || v_prn_prg_seg_name ;
    END IF;

        select_stmt := select_stmt ||
             ', GLCC.' || v_fyr_segment_name || v_cohort_select;

EXCEPTION
  WHEN OTHERS THEN
    vp_retcode := sqlcode ;
    vp_errbuf  := sqlerrm ||'[ build_appor_select]';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
        '.final_exception',vp_errbuf);
    RAISE;

End build_appor_select ;
-- -------------------------------------------------------------------
--               PROCEDURE LOAD_TREASURY_SYMBOL_ID
-- -------------------------------------------------------------------
-- Gets Treasury Symbol Id for the passed Treasury Symbol.
-- -------------------------------------------------------------------
Procedure Load_Treasury_Symbol_Id
IS
  l_module_name VARCHAR2(200) := g_module_name || 'Load_Treasury_Symbol_Id';
Begin
        Select Treasury_Symbol_id
        Into v_treasury_symbol_id
        From fv_treasury_symbols
        where treasury_symbol = vp_treasury_symbol
        and set_of_books_id = vp_set_of_books_id ;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'Treas Symb id:'||v_treasury_symbol_id);
        END IF;

Exception
    WHEN NO_DATA_FOUND Then
        vp_retcode := -1 ;
        vp_errbuf := 'Treasury Symbol Id cannot be found for the Treasury
            Symbol - '||vp_treasury_symbol||' [ GET_TREASURY_SYMBOL_ID ] ' ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
        Return ;
    WHEN TOO_MANY_ROWS Then
        vp_retcode := -1 ;
        vp_errbuf := 'More than one Treasury Symbol Id found for the Treasury
            Symbol - '||vp_treasury_symbol||' [ GET_TREASURY_SYMBOL_ID ] ' ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
    WHEN OTHERS THEN
      vp_retcode := sqlcode ;
      vp_errbuf  := sqlerrm ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
            '.final_exception',vp_errbuf);
      RAISE;
End Load_Treasury_symbol_id ;
-------------------------------------------------------------------
--------------------------------------------------------------------------------
procedure FACTS_ROLLUP_RECORDS is
  l_module_name VARCHAR2(200) := g_module_name || 'FACTS_ROLLUP_RECORDS';
 vl_group_by varchar2(5000);
 vl_rollup varchar2(15000);
 vl_rollup_cursor  Integer     ;
 vl_exec_ret Integer     ;

BEGIN
select_group_by_columns(vp_report_id,vp_attribute_set,vl_group_by);
IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
   'Group by ' || vl_group_by);
END IF;

vl_rollup_cursor := DBMS_SQL.OPEN_CURSOR;

vl_rollup := '
     INSERT INTO FV_FACTS_TEMP
    (TREASURY_SYMBOL_ID ,
    SGL_ACCT_NUMBER     ,
    COHORT              ,
    INDEF_DEF_FLAG      ,
    APPOR_CAT_B_DTL     ,
    APPOR_CAT_B_TXT     ,
    PROGRAM_RPT_CAT_NUM,
    PROGRAM_RPT_CAT_TXT,
    PUBLIC_LAW          ,
    APPOR_CAT_CODE      ,
    AUTHORITY_TYPE      ,
    TRANSACTION_PARTNER     ,
    REIMBURSEABLE_FLAG      ,
    BEA_CATEGORY            ,
    BORROWING_SOURCE        ,
    DEF_LIQUID_FLAG         ,
    DEFICIENCY_FLAG         ,
    AVAILABILITY_FLAG       ,
    LEGISLATION_FLAG        ,
    PYA_FLAG                ,
    AMOUNT                  ,
    TBAL_FUND_VALUE         ,
    TBAL_ACCT_NUM           ,
    fct_int_record_category,
    fct_int_record_type,
    YEAR_BUDGET_AUTH    ,
    BUDGET_FUNCTION     ,
    ADVANCE_FLAG        ,
    TRANSFER_DEPT_ID    ,
    TRANSFER_MAIN_ACCT  ,
    AMOUNT1,
    AMOUNT2,
    period_activity ' ||
    replace(vl_group_by ,'glcc.' ) ||  ')' ||
    '  SELECT
    TREASURY_SYMBOL_ID,
    SGL_ACCT_NUMBER,
    COHORT,
    INDEF_DEF_FLAG,
    APPOR_CAT_B_DTL,
    APPOR_CAT_B_TXT,
    PROGRAM_RPT_CAT_NUM,
    PROGRAM_RPT_CAT_TXT,
    PUBLIC_LAW,
    APPOR_CAT_CODE,
    AUTHORITY_TYPE,
    TRANSACTION_PARTNER,
    REIMBURSEABLE_FLAG,
    BEA_CATEGORY,
    BORROWING_SOURCE,
    DEF_LIQUID_FLAG,
    DEFICIENCY_FLAG,
    AVAILABILITY_FLAG,
    LEGISLATION_FLAG,
    PYA_FLAG,
    SUM(decode(begin_end , ''P'', AMOUNT+PERIOD_ACTIVITY , AMOUNT)),
    tbal_fund_value,
    tbal_acct_num,
     ''REPORTED_NEW'',
     ''TB'',
    YEAR_BUDGET_AUTH,
    BUDGET_FUNCTION ,
    ADVANCE_FLAG    ,
    TRANSFER_DEPT_ID,
    TRANSFER_MAIN_ACCT,
    SUM(AMOUNT1),
    SUM(AMOUNT2),
     SUM(decode(begin_end , ''P'' , 0 , period_activity )) '
    || vl_group_by ||
    ' From  FV_FACTS_TEMP fvt, gl_code_combinations glcc
   WHERE fct_int_record_category    = ''REPORTED''
   AND   fct_int_record_type        = ''TB''
   AND   tbal_fund_value =  ' || '''' ||  v_fund_value  || ''''
   || ' and   glcc.code_combination_id = fvt.code_combination_id
   GROUP BY     TREASURY_SYMBOL_ID,
                SGL_ACCT_NUMBER,
                COHORT,
                INDEF_DEF_FLAG,
                APPOR_CAT_B_DTL,
                APPOR_CAT_B_TXT,
                PROGRAM_RPT_CAT_NUM,
                PROGRAM_RPT_CAT_TXT,
                PUBLIC_LAW,
                APPOR_CAT_CODE,
                AUTHORITY_TYPE,
                TRANSACTION_PARTNER,
                REIMBURSEABLE_FLAG,
                BEA_CATEGORY,
                BORROWING_SOURCE,
                DEF_LIQUID_FLAG,
                DEFICIENCY_FLAG,
                AVAILABILITY_FLAG,
                LEGISLATION_FLAG ,
                PYA_FLAG ,
                TBAL_FUND_VALUE ,
                TBAL_ACCT_NUM,
                YEAR_BUDGET_AUTH,
                BUDGET_FUNCTION ,
                ADVANCE_FLAG    ,
                TRANSFER_DEPT_ID,
                TRANSFER_MAIN_ACCT ' || vl_group_by ;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, vl_rollup);
        END IF;
        dbms_sql.parse(vl_rollup_cursor, vl_rollup, DBMS_SQL.V7) ;
        vl_exec_ret := dbms_sql.execute(vl_rollup_cursor);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' No of records rolled up '
          || vl_exec_ret);
        END IF;

    -- Delete the Detail Records that are used in rollup process
/*
    DELETE FROM FV_FACTS_TEMP
      WHERE (fct_int_record_category = 'REPORTED'
        --     OR fct_int_record_category = 'REPORTED_NEW' )
      AND AMOUNT = 0 AND NVL(PERIOD_ACTIVITY,0) = 0
      AND    treasury_symbol_id = v_treasury_symbol_id ) ;
*/

    --Bug 7324248
    --Delete rows which contain no amounts or 0 amounts
     DELETE FROM FV_FACTS_TEMP
      WHERE fct_int_record_category = 'REPORTED_NEW'
      AND (NVL(amount,0) = 0 AND
           NVL(period_activity,0) = 0 AND
           NVL(amount1,0) = 0 AND
           NVL(amount2,0) = 0)
      AND  treasury_symbol_id = v_treasury_symbol_id;

FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'NO OF ROWS DELETED FROM FV_FACTS_TEMP '||SQL%ROWCOUNT) ;

    --  Set up Debit/Credit Indicator
 EXCEPTION
  WHEN OTHERS THEN
    vp_retcode := sqlcode ;
    vp_errbuf  := sqlerrm ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
      '.final_exception',vp_errbuf);
    RAISE;
 END FACTS_ROLLUP_RECORDS;

---------------------------------------------------------------------------
--               PROCEDURE PROCESS_BY_FUND_RANGE
-- -------------------------------------------------------------------
-- This procedure is called to execute the trial balance process
-- based on the range of funds (fund_low and fund_high parameters)
-- that are passed. This calls all the subsequent procedures
-- required for trial balance process.
-- Added this procedure for the bug 1399282.
-- ------------------------------------------------------------------
Procedure PROCESS_BY_FUND_RANGE
IS
  l_module_name VARCHAR2(200) := g_module_name || 'PROCESS_BY_FUND_RANGE';
BEGIN
    fv_utility.log_mesg('PROCESS_BY_FUND_RANGE :: ');
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
        'Within the process_by_fund_range...') ;
    END IF;

    If vp_retcode = 0 Then
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Deriving Qualifier Segments.....') ;
      END IF;

    -- Getting the Chart of Accounts Id
    BEGIN
      SELECT chart_of_accounts_id
      INTO   v_chart_of_accounts_id
      FROM   gl_ledgers_public_v
      WHERE  ledger_id = vp_set_of_books_id;

      fv_utility.log_mesg('v_chart_of_accounts_id :: '||v_chart_of_accounts_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vp_retcode := -1 ;
        vp_errbuf := 'Error getting Chart of Accounts Id for ledger id '
                        ||vp_set_of_books_id;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf);
        RETURN;
    END;
    -- Getting the Account and Balancing segments' application column names
    BEGIN
      FV_UTILITY.get_segment_col_names(v_chart_of_accounts_id,
                                       v_acc_seg_name,
                                       v_bal_seg_name,
                                       error_code,
                                       error_message);
    fv_utility.log_mesg('v_acc_seg_name :: v_bal_seg_name::error_code::'||v_acc_seg_name||'|'||v_bal_seg_name||
                        '|'||error_message);
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Acc segment:'||v_acc_seg_name||' Bal Segment: '||v_bal_seg_name);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        vp_retcode := -1;
        vp_errbuf := error_message;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf);
        RETURN;
    END;

/*
Commented for bug 8824283
    BEGIN
      -- Added for Bug 7324248. Get the Reimbursable Agreement segment
      SELECT application_column_name
      INTO   g_reimb_agree_seg_name
      FROM   FND_ID_FLEX_SEGMENTS_VL
      WHERE  application_id         = 101
      AND    id_flex_code           = 'GL#'
      AND    id_flex_num            = vp_coa_id
      AND    enabled_flag           = 'Y'
      AND    segment_name like 'Reimbursable Agreement';

     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
              '      Reimbursable Agreement SEGMENT IS'||
                                 to_char(g_reimb_agree_seg_name));
      END IF;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               vp_retcode := 2 ;
               vp_errbuf  := 'GET QUALIFIER SEGMENTS - Reimbursable Agreement SEGMENT IS NOT FOUND';
               FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf);
             RETURN;
           WHEN TOO_MANY_ROWS THEN
             vp_retcode := 2 ;
             vp_errbuf  := 'GET QUALIFIER SEGMENTS - More than one ' ||
                         'row returned while getting Reimbursable Agreement SEGMENT';
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf);
              RETURN;
            WHEN OTHERS THEN
               vp_retcode := SQLCODE;
               vp_errbuf  := SQLERRM ||
                         '-- GET QUALIFIER SEGMENTS Error '||
                         'when getting Reimbursable Agreement SEGMENT';
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                         vp_errbuf);
               RETURN;
    END;
   */


      /* Get fiscal year, account,balance  segment names , Value set_id,  */

      BEGIN

         SELECT application_column_name
         INTO v_fyr_segment_name
         FROM fv_pya_fiscalyear_segment
         WHERE set_of_books_id = vp_set_of_books_id;


         SELECT  flex_value_set_id
         INTO    v_acc_val_set_id
         FROM    fnd_id_flex_segments
         WHERE   application_column_name = v_acc_seg_name
         AND     application_id      = 101
         AND     id_flex_code        = 'GL#'
         AND     id_flex_num         = vp_coa_id;

fv_utility.log_mesg('v_fyr_segment_name :: v_acc_val_set_id::'||v_fyr_segment_name||'|'||v_acc_val_set_id);
       EXCEPTION
           when no_data_found then
            vp_retcode := -1 ;
            vp_errbuf := 'Error getting acc_value_set_id or
                          coa or Fiscal year segment name';
    	    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf);
            RETURN;
      END;

    End If ;

    If vp_retcode = 0 Then
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
             l_module_name, 'Deriving Period information.....') ;
        END IF;

        GET_PERIOD_INFO ;
    End If ;
    If vp_retcode = 0 Then
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                           'Processing for each Fund.....');
        END IF;
        PROCESS_EACH_FUND ;
    End If ;
EXCEPTION
        -- Exception Processing
  WHEN OTHERS THEN
    vp_retcode := sqlcode ;
    vp_errbuf  := sqlerrm ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
       '.final_exception',vp_errbuf);
    RETURN;
END PROCESS_BY_FUND_RANGE;
-- -------------------------------------------------------------------
--               PROCEDURE PROCESS_EACH_FUND
-- -------------------------------------------------------------------
-- This procedure does the processing for each fund within the
-- the range of funds (fund_low and fund_high parameters)
-- that are passed. This calls all the subsequent procedures
-- required for trial balance process.
-- Added this procedure for the bug 1399282.
-- ------------------------------------------------------------------
Procedure PROCESS_EACH_FUND
IS
  l_module_name VARCHAR2(200) := g_module_name || 'PROCESS_EACH_FUND';
  vl_bal_flex_id  fnd_id_flex_segments.flex_value_set_id%type;
  CURSOR C_Get_Fund_Values
   IS
    SELECT  flex_value
    FROM    fnd_flex_values_vl
    WHERE   flex_value_set_id = vl_bal_flex_id
    AND     flex_value between vp_fund_low and vp_fund_high
    AND     summary_flag = 'N';

  CURSOR C_Get_Rec_Count
   IS
    SELECT  count(*) cnt
    FROM    fnd_flex_values_vl
    WHERE   flex_value_set_id = vl_bal_flex_id
    AND     flex_value between vp_fund_low and vp_fund_high
    AND     summary_flag = 'N';

  vl_req_id number;
  l_sob_name gl_ledgers.name%TYPE;


BEGIN

   BEGIN
      -- Getting the value set id for the Balancing Segment
      Select   flex_value_set_id
      Into    vl_bal_flex_id
      From    fnd_id_flex_segments
      Where   application_id = 101
      And application_column_name = v_bal_seg_name
      And id_flex_code = 'GL#'
      And id_flex_num  = vp_coa_id;
     EXCEPTION
      When NO_DATA_FOUND Then
            vp_retcode := -1 ;
            vp_errbuf := 'Error getting Value Set Id for balancing segment'
                            ||v_bal_seg_name||' [PROCESS_EACH_FUND]' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
            return;
   END;
   -- Get the maximum number of records within the fund range.
   -- This is useful in submitting the ATB report.
   open C_Get_Rec_Count;
   fetch C_Get_Rec_Count into v_rec_count;
   close C_Get_Rec_Count;


   if v_rec_count = 0 then
       vp_retcode := -1 ;
       fnd_message.set_name('FV','FV_FACTS_FVALUE_NOT_FOUND');
       vp_errbuf :=fnd_message.get ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf);
       return ;
   end if;


   v_fund_count := 0;
   FOR C_Get_Fund_Values_Rec IN C_Get_Fund_Values
     LOOP
       vp_retcode := 0;
       v_fund_value := C_Get_Fund_Values_Rec.flex_value;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
             'Purging FACTS Temp....') ;
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
             'Fund Vlaue : ' || v_fund_value) ;
        END IF;
        -- Increment the counter for fund

       BEGIN
          --Getting the Treasury Symbol value
          Select treasury_symbol
          Into  vp_treasury_symbol
          From  fv_treasury_symbols
          Where treasury_symbol_id = (Select    treasury_symbol_id
                        From  fv_fund_parameters
                        Where fund_value = C_Get_Fund_Values_Rec.flex_value
                        And   set_of_books_id = vp_set_of_books_id);

         -- Getting the treasury_symbol_id
         Load_Treasury_Symbol_Id;

         -- Getting the Treasury Symbol information
         If vp_retcode = 0 Then
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'Deriving Treasury Symbol information.....');
          END IF;
          GET_TREASURY_SYMBOL_INFO ;
         End if;


        EXCEPTION
         When NO_DATA_FOUND Then
            vp_errbuf := 'No treasury symbol found for the fund '
                ||C_Get_Fund_Values_Rec.flex_value||' [PROCESS_EACH_FUND]' ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
         When OTHERS then
            vp_errbuf := 'Error populating the treasury symbol for the fund '
                ||C_Get_Fund_Values_Rec.flex_value||' [PROCESS_EACH_FUND]'||SQLERRM ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name, vp_errbuf) ;
       END;

       --Bug No # 2450918
       If vp_retcode = 0 Then
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'Starting TB Main Process.....') ;
         END IF;
         PROCESS_FACTS_TRANSACTIONS ;
       End If ;

     END LOOP;

     --Added to get sob name since
     --profile was getting the inappropriate name
     SELECT name
     INTO   l_sob_name
     FROM   gl_ledgers
     WHERE  ledger_id = vp_set_of_books_id
     AND    currency_code = 'USD';


     -- Submitting TB Report
     -----------------------------------------------------------------
     -- Bug 9031886
     vl_req_id :=
                    FND_REQUEST.SUBMIT_REQUEST ('FV','RXFVFCTB','','',FALSE,
                     'DIRECT',
                      vp_report_id,
                      vp_attribute_set,
		      vp_output_format,
	              vp_set_of_books_id,
		      vp_fund_low,
                      vp_fund_high,
	              vp_currency_code,
	              vp_period_name);
     COMMIT;

     if vl_req_id = 0 then
            vp_errbuf := 'Error submitting RX Report ';
            vp_retcode := -1 ;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, vp_errbuf) ;
         return;
      Else
         -- if concurrent request submission failed then abort process
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                  'Concurrent Request Id for RX Report - ' ||vl_req_id);
         END IF;
     end if;

   ---------------------------------------------------------------
EXCEPTION
  WHEN OTHERS THEN
    vp_retcode := sqlcode ;
    vp_errbuf  := sqlerrm ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
       '.final_exception',vp_errbuf);
    RETURN;
END PROCESS_EACH_FUND;
--------------------------------------------------------------------------------
PROCEDURE get_prc_val(p_catb_program_val IN VARCHAR2,
                      p_catb_rc_val OUT NOCOPY VARCHAR2,
                      p_catb_rc_desc OUT NOCOPY VARCHAR2,
		      p_prn_program_val IN VARCHAR2,
                      p_prn_rc_val OUT NOCOPY VARCHAR2,
                      p_prn_rc_desc OUT NOCOPY VARCHAR2)
IS

l_module_name VARCHAR2(200) := g_module_name || 'get_prc_val';
vl_prc_found VARCHAR2(1) := 'N';
vl_prc_header_id NUMBER(15);
vl_prc_val VARCHAR2(10);
vl_prc_desc VARCHAR2(100);
vl_program_val VARCHAR2(50);
vl_prc_flag  VARCHAR2(1);
vl_prc_count NUMBER;
vl_prg_val_set_id NUMBER(15);
vl_seg_txt  VARCHAR2(100);
vl_segment VARCHAR2(50);
BEGIN
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'get_prc_val:'||p_catb_program_val);
     For I in 1..2
      Loop
        IF I = 1        THEN
                vl_prc_header_id := v_catb_rc_header_id ;
                vl_program_val   := p_catb_program_val;
                vl_prc_flag      := v_catb_rc_flag;
                vl_prg_val_set_id := v_catb_prg_val_set_id;
                vl_segment      := v_catb_prg_seg_name;

        ELSE
                vl_prc_header_id := v_prn_rc_header_id ;
                vl_program_val   := p_prn_program_val;
                vl_prc_flag      := v_prn_rc_flag;
                vl_prg_val_set_id := v_prn_prg_val_set_id;
                vl_segment     := v_prn_prg_seg_name;
       END IF;

  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'vl_prc_header_id:vl_program_val:vl_prc_flag:vl_prg_val_set_id:vl_segment:'||vl_prc_header_id
           ||'|'||vl_program_val||'|'||vl_prc_flag||'|'||vl_prg_val_set_id||'|'||vl_segment);

        vl_prc_found := 'N';

      IF vl_prc_flag = 'Y' THEN

         BEGIN
	    SELECT reporting_code, reporting_desc
            INTO   vl_prc_val, vl_prc_desc
            FROM   fv_facts_prc_dtl
            WHERE  prc_header_id = vl_prc_header_id
            AND    program_value = vl_program_val
            AND    set_of_books_id = vp_set_of_books_id;

            vl_prc_found := 'Y';

          EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
    	    WHEN OTHERS THEN
      	      vp_errbuf := SQLERRM;
      	      vp_retcode := -1;
      	      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                l_module_name||'.exception1',vp_errbuf);

         END;

         IF vl_prc_found = 'N' THEN
           BEGIN
	     SELECT reporting_code, reporting_desc
             INTO   vl_prc_val, vl_prc_desc
             FROM   fv_facts_prc_dtl
             WHERE  prc_header_id = vl_prc_header_id
             AND    program_value = 'ALL'
             AND    set_of_books_id = vp_set_of_books_id;

             vl_prc_found := 'Y';

            EXCEPTION
             WHEN NO_DATA_FOUND THEN NULL;
             WHEN OTHERS THEN
              vp_errbuf := SQLERRM;
              vp_retcode := -1;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                l_module_name||'.exception2',vp_errbuf);
           END;
         END IF;

      END IF;


      IF (vl_prc_flag = 'N' )
           THEN
            BEGIN
              vl_prc_val := LPAD(TO_CHAR(TO_NUMBER(vl_program_val)),3,'0');
              EXCEPTION
                WHEN OTHERS THEN
                  vp_errbuf := 'The Reporting Code mapping segment value '||
                               'should '||
                               'be a Numeric Value.';
                  vp_retcode := -1;
                         vl_prc_val := NULL;
                            vl_prc_desc := NULL;

                   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                l_module_name||'.exceptionx3',vp_errbuf);

            END;
              get_segment_text(vl_program_val,
                                    vl_prg_val_set_id,
                                    vl_seg_txt  ) ;
              IF vp_retcode <> 0 THEN
                RETURN ;
              END IF ;
              vl_prc_desc := vl_seg_txt;


      ELSIF vl_prc_flag = 'Y' AND vl_prc_found = 'N'  THEN

	   vl_prc_val := NULL;
           vl_prc_desc := NULL;

           IF I = 2 THEN
              vl_prc_val := '099';
              vl_prc_desc := 'PRC not Assigned';
           END IF;

      ELSIF vl_prc_found = 'Y'  THEN
          vl_prc_val := LPAD(TO_CHAR(TO_NUMBER(vl_prc_val)),3,'0');
      END IF;


IF I = 1 THEN
  IF va_appor_cat_val = 'A' THEN
      p_catb_rc_desc := 'Default CAT B Code';
      --p_catb_rc_val := '000';


  ELSE
      p_catb_rc_desc := vl_prc_desc;
      p_catb_rc_val := vl_prc_val;
  END IF;
ELSE
      p_prn_rc_desc := vl_prc_desc;
      p_prn_rc_val := vl_prc_val;

END IF;
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'p_catb_rc_val:p_catb_rc_desc:p_prn_rc_desc:p_prn_rc_val:reporting_code:vl_prc_desc::'
           ||p_catb_rc_val||'|'||p_catb_rc_desc||'|'||p_prn_rc_desc||'|'||p_prn_rc_val||'|'||vl_prc_val||'|'||vl_prc_desc);

END LOOP;

  IF va_appor_cat_val = 'A' THEN

      p_catb_rc_desc := 'Default Cat B Code';
     -- p_catb_rc_val := '000';


  END IF;

 EXCEPTION
    WHEN OTHERS THEN
      vp_errbuf := SQLERRM ||'[GET_PRC_VAL]';
      vp_retcode := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
          l_module_name||'.final_exception',vp_errbuf);
      RAISE;

END get_prc_val;
--------------------------------------------------------------------------------
/*
PROCEDURE process_cat_b_seq(reported_type IN VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'process_cat_b_seq';

   CURSOR cat_b_cur(reported_type VARCHAR2) IS
      SELECT rowid, tbal_fund_value, sgl_acct_number, appor_cat_b_txt
      FROM   fv_facts_temp
      WHERE  fct_int_record_category = reported_type
      AND    appor_cat_code = 'B'
      AND    TRIM(appor_cat_b_txt) IS NOT NULL
      ORDER BY tbal_fund_value, sgl_acct_number, appor_cat_b_txt ;

   l_seq NUMBER;
   l_old_fund fv_facts_temp.tbal_fund_value%TYPE := '***';
   l_old_account fv_facts_temp.sgl_acct_number%TYPE := -99;
   l_old_cat_b_txt fv_facts_temp.appor_cat_b_txt%TYPE := '~~~';
   l_count NUMBER;

   BEGIN

    l_count := 1;

    FOR cat_b_rec IN cat_b_cur(reported_type)
        LOOP
           IF l_count = 1 THEN
              l_seq := 1;
         ELSIF
              (l_old_fund = cat_b_rec.tbal_fund_value
              AND l_old_account = cat_b_rec.sgl_acct_number
              AND l_old_cat_b_txt = cat_b_rec.appor_cat_b_txt)
              THEN NULL;
         ELSIF
              (l_old_fund = cat_b_rec.tbal_fund_value
              AND l_old_account = cat_b_rec.sgl_acct_number
              AND l_old_cat_b_txt <> cat_b_rec.appor_cat_b_txt)
              THEN l_seq := l_seq + 1;
             ELSE
              l_seq := 1;
       END IF;

           UPDATE fv_facts_temp
           SET    appor_cat_b_dtl = LPAD(to_char(l_seq), 3, '0')
           WHERE  rowid = cat_b_rec.rowid;

           l_old_fund := cat_b_rec.tbal_fund_value;
           l_old_account := cat_b_rec.sgl_acct_number;
           l_old_cat_b_txt := cat_b_rec.appor_cat_b_txt;

       l_count := 99;
        END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    vp_errbuf := SQLERRM;
    vp_retcode := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',vp_errbuf);
    RAISE;

END process_cat_b_seq;
*/

-- -------------------------------------------------------------------
PROCEDURE get_trx_part_from_reimb
                  (p_reimb_agree_seg_val IN VARCHAR2) IS

l_module_name VARCHAR2(200) := g_module_name || 'get_trx_part_from_reimb';
l_cust_class_code VARCHAR2(25);
BEGIN
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'p_reimb_agree_seg_val:'||p_reimb_agree_seg_val);
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
          'BEGIN '||l_module_name);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'p_reimb_agree_seg_val:'||p_reimb_agree_seg_val);
   END IF;
   SELECT hzca.customer_class_code
   INTO   l_cust_class_code
   FROM   ra_customer_trx_all rct,
          hz_cust_accounts_all hzca
   WHERE  rct.trx_number =  p_reimb_agree_seg_val
   AND    rct.set_of_books_id = vp_set_of_books_id
   AND    hzca.cust_account_id = rct.bill_to_customer_id;

   IF l_cust_class_code = 'FEDERAL' THEN
      va_transaction_partner_val := 'F';
     ELSIF l_cust_class_code <> 'FEDERAL' THEN
      va_transaction_partner_val := 'X';
   END IF;

  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'va_transaction_partner_val:'||va_transaction_partner_val);

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
     'g_transaction_partner_val:'||va_transaction_partner_val);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
     'END '||l_module_name);
   END IF;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
           'No record found for trx number: '||p_reimb_agree_seg_val);
       END IF;
    WHEN OTHERS THEN
      vp_retcode := -1;
      vp_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
          l_module_name||'.final_exception',vp_errbuf);
END get_trx_part_from_reimb;
--------------------------------------------------------------------------------
BEGIN
  g_module_name  := 'fv.plsql.FV_FACTS_TBAL_TRX.';
-- -------------------------------------------------------------------

-- -------------------------------------------------------------------
-- End Of the Package Body
-- -------------------------------------------------------------------
END FV_FACTS_TBAL_TRX;

/
