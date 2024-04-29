--------------------------------------------------------
--  DDL for Package Body FV_CFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_CFS_PKG" AS
  /* $Header: FVXCFSPB.pls 120.82.12010000.28 2010/03/31 12:07:44 yanasing ship $ */
  ------------Global Variables---------------
  g_module_name VARCHAR2(100);
  v_cursor_id   INTEGER;
  v_sob gl_ledgers_public_v.ledger_id%TYPE;
  v_period_name gl_period_statuses.period_name%TYPE;
  v_units       NUMBER;
  v_report_type VARCHAR2(30);
  v_table_ind   VARCHAR2(1);
  v_end_date DATE;
  v_retcode     NUMBER DEFAULT 0;
  v_errbuf      VARCHAR2(2000);
  v_sequence_id NUMBER;
  v_facts_rep_show  VARCHAR2(2);
  v_chart_of_accounts_id gl_sets_of_books.chart_of_accounts_id%TYPE;
  v_currency_code gl_sets_of_books.currency_code%TYPE;
  v_bal_seg_name VARCHAR2(20);
  v_acc_seg_name VARCHAR2(20);
  v_acct_flex_value_set_id fnd_id_flex_segments_vl.flex_value_set_id%TYPE;
  v_bal_flex_value_set_id fnd_id_flex_segments_vl.flex_value_set_id%TYPE;
  v_line_id fv_cfs_rep_lines.line_id%TYPE;
  v_line_details_id fv_cfs_rep_line_dtl.line_detail_id%TYPE;
  v_line_type fv_cfs_rep_lines.line_type%TYPE;
  v_line_label fv_cfs_rep_lines.line_label%TYPE;
  v_by_recipient fv_cfs_rep_lines.by_recipient%TYPE;
  v_natural_balance_type fv_cfs_rep_lines.natural_balance_type%TYPE;
  v_amount fv_cfs_rep_temp.col_1_amt%TYPE;
  v_exception_amount fv_cfs_rep_temp.col_1_amt%TYPE;
  v_recipient_name fv_facts_report_t2.recipient_name%TYPE;
  v_code_combination_id gl_code_combinations.code_combination_id%TYPE;
  v_account gl_code_combinations.segment1%TYPE;
  v_fund gl_code_combinations.segment1%TYPE;
  v_col_1_amt fv_cfs_rep_temp.col_1_amt%TYPE;
  v_col_2_amt fv_cfs_rep_temp.col_1_amt%TYPE;
  v_col_3_amt fv_cfs_rep_temp.col_1_amt%TYPE;
  v_col_4_amt fv_cfs_rep_temp.col_1_amt%TYPE;
  v_col_5_amt fv_cfs_rep_temp.col_1_amt%TYPE;
  v_col_6_amt fv_cfs_rep_temp.col_1_amt%TYPE;
  v_col_7_amt fv_cfs_rep_temp.col_1_amt%TYPE;
  v_col_8_amt fv_cfs_rep_temp.col_1_amt%TYPE;
  v_sequence_number fv_cfs_rep_lines.sequence_number%TYPE;
  v_line_number fv_cfs_rep_lines.line_number%TYPE;
  v_period_fiscal_year gl_period_statuses.period_year%TYPE;
  v_period_num gl_period_statuses.period_num%TYPE;
  v_purge_ts_id fv_treasury_symbols.TREASURY_SYMBOL_ID%TYPE;
  v_select1           VARCHAR2(32000);
  v_select2           VARCHAR2(32000);
  v_select3           VARCHAR2(32000);
  v_select4           VARCHAR2(32000);
  v_select5           VARCHAR2(32000);
  v_cursor_id1        INTEGER;
  v_cursor_id2        INTEGER;
  v_cursor_id3        INTEGER;
  v_cursor_id4        INTEGER;
  v_cursor_id5        INTEGER;
  v_cursor_id6        INTEGER;
  v_cursor_id7        INTEGER;
  v_cursor_id8        INTEGER;
  gbl_units           VARCHAR2(25);
  v_bud_col           VARCHAR2(1);
  V_nbfa_col          VARCHAR2(1);
  v_glbal_select      VARCHAR2(32000);
  v_glbal_grpby_sel   VARCHAR2(32000);
  v_glbal_curid       INTEGER;
  v_glbal_grpby_curid INTEGER;
  v_begin_period      NUMBER;
  v_begin_period_name gl_period_statuses.period_name%TYPE;
  v_begin_period_end_date DATE;
  v_end_period NUMBER;
  v_end_period_end_date DATE;
  v_begin_period_1 NUMBER;
  v_begin_period_name_1 gl_period_statuses.period_name%TYPE;
  v_begin_period_1_end_date DATE;
  v_end_period_1_end_date DATE;
  v_cy_gl_beg_bal        NUMBER;
  v_cy_gl_end_bal        NUMBER;
  v_py_gl_beg_bal        NUMBER;
  v_py_gl_end_bal        NUMBER;
  v_fct1_attr_select     VARCHAR2(32000);
  v_fct1_sel             VARCHAR2(32000);
  v_fct1_sel_curid       INTEGER;
  v_fct1_rcpt_sel        VARCHAR2(32000);
  v_fct1_rcpt_sel_curid  INTEGER;
  v_fct1_rcpt_sel2       VARCHAR2(32000);
  v_fct1_rcpt_sel2_curid INTEGER;
  v_sbr_curid            INTEGER;
  v_cy_fct1_begbal       NUMBER;
  v_cy_fct1_endbal       NUMBER;
  v_py_fct1_begbal       NUMBER;
  v_py_fct1_endbal       NUMBER;
  v_cy_begbal_diff       NUMBER;
  v_py_begbal_diff       NUMBER;
  v_cy_sbr_beg_bal       NUMBER;
  v_cy_sbr_end_bal       NUMBER;
  v_py_sbr_beg_bal       NUMBER;
  v_py_sbr_end_bal       NUMBER;
  v_year_flag		 VARCHAR2(1):='P'; /* It represent current year(C) or previous year(P)*/
  v_balance_type fv_sbr_definitions_accts.SBR_BALANCE_TYPE%TYPE;
  istotal_cal NUMBER;
  /* ADDED FOR sbr ER */
  /* START*/
  g_chart_of_accounts_id gl_ledgers.chart_of_accounts_id%TYPE;
  g_fund_segment_name VARCHAR2(10);
  --
  -- ------------------------------------
  -- Stored Global Variables
  -- ------------------------------------
  g_insert_count NUMBER;
  --
  g_error_code    NUMBER;
  g_error_message VARCHAR2(80);
  --
  g_period_num                 NUMBER;
  g_ts_value_in_process        VARCHAR2(25);
  g_total_start_line_number    NUMBER;
  g_subtotal_start_line_number NUMBER;
  g_column_number              NUMBER;
  --Added for bug No. 1553099
  g_currency_code VARCHAR2(15);
  --
  c_total_balance      NUMBER;
  c_total_balance_bud  NUMBER;
  c_total_balance_nbfa NUMBER;
  c_ending_balance     NUMBER;
  c_begin_balance      NUMBER;
  c_begin_select       VARCHAR2(200);
  c_end_select         VARCHAR2(200);
  c_begin_period       VARCHAR2(40);
  c_end_period         VARCHAR2(40);
  -- New Variables declared by Narsimha Balakkari.
  c_resource_type fv_treasury_symbols.resource_type%TYPE;
  c_rescission_flag VARCHAR2(10);
  -- ---------- Flex Segment Name Cursor Variables ---------
  c_segment_name fnd_id_flex_segments.segment_name%TYPE;
  c_flex_column_name fnd_id_flex_segments.application_column_name%TYPE;
  --
  v_balance_column_name fnd_id_flex_segments.application_column_name%TYPE;
  g_seg_value_set_id FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_ID%TYPE;
  -- ---------- Treasury Symbol Report Line Cursor Vaiables -----------
  c_sbr_ts_value gl_code_combinations.segment1%TYPE;
  c_sbr_line_id fv_sbr_definitions_lines.sbr_line_id%TYPE;
  c_sbr_line_number fv_sbr_definitions_lines.sbr_line_number%TYPE;
  c_sbr_prev_line_number fv_sbr_definitions_lines.sbr_line_number%TYPE;
  c_sbr_line_type_code fv_sbr_definitions_lines.sbr_line_type_code%TYPE;
  c_sbr_natural_bal_type fv_sbr_definitions_lines.sbr_natural_balance_type%TYPE;
  c_sbr_line_category fv_sbr_definitions_lines.sbr_fund_category%TYPE;
  --  New variable declared by pkpatel to fix Bug 1575992
  c_sbr_treasury_symbol_id fv_treasury_symbols.treasury_symbol_id%TYPE;
  --
  --  New variable declared by Narsimha.
  c_sbr_report_line_number fv_sbr_definitions_lines.sbr_report_line_number%TYPE;
  c_sbr_gl_balance fv_sbr_definitions_lines.SBR_GL_BALANCE%TYPE;

  -- ---------- Balance Type Cursor Vaiables ---------
  c_sbr_line_acct_id fv_sbr_definitions_accts.sbr_line_acct_id%TYPE;
  c_sbr_balance_type fv_sbr_definitions_accts.sbr_balance_type%TYPE;
  c_acct_number fv_sbr_definitions_accts.acct_number%TYPE;
  c_direct_or_reimb_code fv_sbr_definitions_accts.direct_or_reimb_code%TYPE;
  c_apportionment_category_code fv_sbr_definitions_accts.apportionment_category_code%TYPE;
  c_category_b_code fv_sbr_definitions_accts.category_b_code%TYPE;
  c_prc_code fv_sbr_definitions_accts. prc_code%TYPE;
  c_advance_code fv_sbr_definitions_accts.advance_code%TYPE;
  c_availability_time fv_sbr_definitions_accts.availability_time%TYPE;
  c_bea_category_code fv_sbr_definitions_accts.bea_category_code%TYPE;
  c_borrowing_source_code fv_sbr_definitions_accts.borrowing_source_code%TYPE;
  c_transaction_partner fv_sbr_definitions_accts.transaction_partner%TYPE;
  c_year_of_budget_authority fv_sbr_definitions_accts.year_of_budget_authority%TYPE;
  c_prior_year_adjustment fv_sbr_definitions_accts.prior_year_adjustment%TYPE;
  c_authority_type fv_sbr_definitions_accts.authority_type%TYPE;
  c_tafs_status fv_sbr_definitions_accts.tafs_status%TYPE;
  c_availability_type fv_sbr_definitions_accts.availability_type%TYPE;
  c_expiration_flag fv_sbr_definitions_accts.expiration_flag%TYPE;
  c_fund_type fv_sbr_definitions_accts.fund_type%TYPE;
  c_financing_account_code fv_sbr_definitions_accts.financing_account_code%TYPE;
  exp_date DATE;
  beg_date DATE;
  close_date DATE;
  whether_Exp          VARCHAR2(1);
  report_period_num    NUMBER ;
  parm_tsymbol_id      NUMBER;
  whether_Exp_SameYear VARCHAR2(1);
  expiring_year        NUMBER;
  -- New variables declared by Narsimha.
  c_sbr_apportion_amt NUMBER;
  c_sbr_additional_info fv_sbr_definitions_accts .sbr_additional_info%TYPE;
  -- ---------- Treasury Symbol Accummulation Cursor Vaiables ---------
  /*  c_sbr_column_amount NUMBER;
  c_sbr_amount_not_shown fv_sbr_definitions_cols_temp.sbr_amount_not_shown%TYPE;
  -- ---------- Output Report Line Column Data -------------
  o_sbr_ts_value    fv_sbr_definitions_cols_temp.sbr_fund_value%TYPE;
  o_sbr_line_id       fv_sbr_definitions_cols_temp.sbr_line_id%TYPE;
  o_sbr_column_number fv_sbr_definitions_cols_temp.sbr_column_number%TYPE;
  o_sbr_column_amount fv_sbr_definitions_cols_temp.sbr_column_amount%TYPE;
  o_sbr_amt_not_shown fv_sbr_definitions_cols_temp.sbr_amount_not_shown%TYPE;
  */
  errbuf_facts     VARCHAR2(1000);
  retcode_facts    NUMBER;
  run_mode_fact    VARCHAR2(15);
  contact_fname    VARCHAR2(15) ;
  contact_lname    VARCHAR2(15);
  contact_phone    NUMBER ;
  contact_extn     NUMBER ;
  contact_email    VARCHAR2(15);
  contact_fax      NUMBER;
  contact_maiden   VARCHAR2(15);
  supervisor_name  VARCHAR2(15);
  supervisor_phone NUMBER ;
  supervisor_extn  NUMBER ;
  agency_name_1    VARCHAR2(15);
  agency_name_2    VARCHAR2(15);
  address_1        VARCHAR2(15);
  address_2        VARCHAR2(15);
  city             VARCHAR2(15);
  state            VARCHAR2(15);
  zip              VARCHAR2(15);
  -- ------------------------------------
  -- Stored Input Parameters
  -- ------------------------------------
  parm_application_id NUMBER;
  --p_set_of_books_id          NUMBER;
  parm_gl_period_num  NUMBER;
  parm_treasury_value VARCHAR2(35);
  parm_run_mode       VARCHAR2(10);
  DSum_E              NUMBER;
  CSum_E              NUMBER;
  DSum_B              NUMBER;
  CSum_B              NUMBER;
  e_bal_indicator     VARCHAR2(1);
  b_bal_indicator     VARCHAR2(1);
  CURSOR sbr_report_line_cursor
  IS
    SELECT DISTINCT line.sbr_line_id sbr_line_id            ,
      line.sbr_line_number sbr_line_number                  ,
      line.sbr_line_type_code sbr_line_type_code            ,
      line.sbr_natural_balance_type sbr_natural_balance_type,
      line.sbr_fund_category sbr_line_category              ,
      line.sbr_report_line_number sbr_report_line_number    ,
      line.sbr_line_label sbr_line_label		,
      line.sbr_gl_balance sbr_gl_balance
      FROM fv_sbr_definitions_lines line
      WHERE line.set_of_books_id   = v_sob
    AND (line.sbr_line_type_code) IN ('T', 'D', 'D2')
   ORDER BY line.sbr_line_number;
  --
  -- ---------- Determine Balance Type of Acct   -------------
  --
  CURSOR balance_type_cursor
  IS
     SELECT sbr_line_acct_id     ,
      sbr_balance_type           ,
      acct_number                ,
      direct_or_reimb_code       ,
      apportionment_category_code,
      category_b_code            ,
      prc_code                   ,
      advance_code               ,
      availability_time          ,
      bea_category_code          ,
      borrowing_source_code      ,
      transaction_partner        ,
      year_of_budget_authority   ,
      prior_year_adjustment      ,
      authority_type             ,
      tafs_status                ,
      availability_type          ,
      expiration_flag            ,
      fund_type                  ,
      financing_account_code     ,
      sbr_treasury_symbol_id
       FROM fv_sbr_definitions_accts
      WHERE sbr_line_id = c_sbr_line_id
      and set_of_books_id   = v_sob;

  /* TREASURY SYMBOLS  CURSOR */
  CURSOR ts_cursor(p_sob NUMBER)
  IS
     SELECT treasury_symbol,
      treasury_symbol_id
       FROM fv_treasury_symbols
      WHERE TIME_FRAME IN ('SINGLE','NO_YEAR','MULTIPLE','REVOLVING')
    AND (FUND_GROUP_CODE NOT BETWEEN '3800' AND '3899')
    AND (FUND_GROUP_CODE NOT BETWEEN '6001' AND '6999')
   -- AND treasury_symbol IN ('33-X-3333','11-08-0110','11-04-0100','03-X-0366','03-06-0333')
    AND set_of_books_id = p_sob
   ORDER BY treasury_symbol;

   CURSOR get_ts_id_cur (p_acc_num VARCHAR2)
   IS
   select distinct fft.treasury_symbol_id from fv_facts_temp fft,
   fv_treasury_symbols fts
   where sgl_acct_number like  p_acc_num||'%'
   and fft.treasury_symbol_id= fts.treasury_symbol_id
   and fft.fct_int_record_type='BLK_DTL'
   and fts.set_of_books_id=v_sob;

PROCEDURE build_report_lines;
PROCEDURE build_fiscal_line_columns
  (
    p_fiscal_year NUMBER);
  --PROCEDURE build_total_line_columns;
  /*END OF sbr ER */
  -- =============================================================
PROCEDURE get_qualifier_segments;
PROCEDURE build_dynamic_query;
PROCEDURE get_one_time_values;
PROCEDURE process_report_line;
PROCEDURE process_detail_line;
PROCEDURE process_total_line;
PROCEDURE process_sbr_total_line;
PROCEDURE populate_temp_table;
PROCEDURE populate_ccid;
PROCEDURE purge_csf_temp_table;
PROCEDURE get_sbr_py_bal_details(p_fiscal_year NUMBER);
PROCEDURE build_sbr_dynamic_query;
PROCEDURE purge_facts_transactions;
  FUNCTION get_bal_type_amt
    (
      p_balance_type     VARCHAR,
      p_natural_bal_type VARCHAR,
      p_beg_bal          NUMBER,
      p_end_bal          NUMBER)
    RETURN NUMBER;
    --p_bal_type_amt OUT NUMBER);
    -- =============================================================
  PROCEDURE main
    (
      errbuf OUT NOCOPY  VARCHAR2,
      retcode OUT NOCOPY NUMBER,
      p_set_of_books_id         IN NUMBER,
      p_report_type             IN VARCHAR2,
      p_units                   IN VARCHAR2,
      p_period_name             IN VARCHAR2,
      p_facts_rep_show		      IN VARCHAR2,
      p_table_indicator         IN VARCHAR2
      )
                                IS
    l_module_name    VARCHAR2(200) := g_module_name || 'MAIN.';
    l_request_id     NUMBER;
    l_facts_edit_cnt NUMBER;
    l_count          NUMBER;
    l_count_acct     NUMBER;
    l_sub_sbr        NUMBER:=2;
    l_one_edit_pass  NUMBER:=0;
  BEGIN
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Sob ID: '||p_set_of_books_id);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Period: '||p_period_name);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Units: '||p_units);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Report type: '||p_report_type);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Table Ind: '||p_table_indicator);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_facts_rep_show : '||p_facts_rep_show);

    v_sob               := p_set_of_books_id;
    v_period_name       := p_period_name;
    v_report_type       := p_report_type;
    v_facts_rep_show    := p_facts_rep_show;


    parm_application_id := '101';
    gbl_units           := p_units;
    g_error_code        :=0;
    IF p_units           = 'Dollars' THEN
      v_units           := 1;
    ELSIF p_units        = 'Thousands' THEN
      v_units           := 1000;
    ELSIF p_units        = 'Millions' THEN
      v_units           := 1000000;
    END IF;
     SELECT chart_of_accounts_id,
      currency_code
       INTO v_chart_of_accounts_id,
      v_currency_code
       FROM gl_ledgers_public_v
      WHERE ledger_id = v_sob ;

    get_one_time_values;
    IF v_retcode <> 0 THEN
      retcode    := v_retcode;
      errbuf     := v_errbuf;
      RETURN;
    END IF;
     SELECT TRUNC(end_date),
      period_num           ,
      period_year
       INTO v_end_date,
      v_period_num    ,
      v_period_fiscal_year
       FROM gl_period_statuses
      WHERE ledger_id  = v_sob
    AND application_id = parm_application_id
    AND period_name    = v_period_name;
    /*Sequence for fv_cfs_rep_temp table  */
     SELECT fv_cfs_rep_temp_s.NEXTVAL
       INTO v_sequence_id
       FROM DUAL;

    get_qualifier_segments;

    -- Checking whether processing SBR or other report types

    IF UPPER(v_report_type)='SBR' THEN

      -- Check whether the SBR  setup is done or not
      SELECT count(*) into l_count
      FROM fv_sbr_definitions_lines
      WHERE set_of_books_id   = p_set_of_books_id;

      SELECT count(*) into l_count_acct
      FROM fv_sbr_definitions_accts
      WHERE set_of_books_id   = p_set_of_books_id;

      if l_count=0 or l_count_acct=0 then
          errbuf       := 'No Setup data for Statement of Budgetary Resources';
          retcode      := 1;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',errbuf);
          RETURN;
      end if;

      -- Processing SBR report line definitions
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'BEFORE ts_rec CURSOR->'||p_set_of_books_id);
      purge_csf_temp_table;

      build_sbr_dynamic_query;

      FOR ts_rec IN ts_cursor(p_set_of_books_id)
      LOOP
        --fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'in cursor loop');
        parm_treasury_value          := ts_rec.treasury_symbol;
        parm_tsymbol_id              := ts_rec.treasury_symbol_id;
        v_purge_ts_id                := ts_rec.treasury_symbol_id;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SUBMITTING FACTS II process FOR TS.....'||parm_treasury_value);
        END IF;
         SELECT period_num
           INTO report_period_num
           FROM gl_period_statuses
          WHERE application_id = parm_application_id
        AND set_of_books_id    = v_sob
        AND period_name        = v_period_name
        AND period_year        = v_period_fiscal_year;

	retcode_facts:=0;

	/*Purging old data from fv_facts_temp tables*/
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Purging old data before triggers facts process for Treasury Symbol-> '||parm_treasury_value);
        purge_facts_transactions;


        FV_FACTS_TRANSACTIONS.main(errbuf_facts, retcode_facts, v_sob, parm_treasury_value,
	v_period_fiscal_year, report_period_num, run_mode_fact, contact_fname, contact_lname,
	contact_phone, contact_extn, contact_email, contact_fax, contact_maiden, supervisor_name,
	supervisor_phone, supervisor_extn, agency_name_1, agency_name_2, address_1, address_2,
	city, state, zip, v_currency_code,v_facts_rep_show);

        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'retcode_facts is '||retcode_facts|| '  FV_FACTS_TRANSACTIONS.v_g_edit_check_code' || FV_FACTS_TRANSACTIONS.v_g_edit_check_code);

  -- Commenting out the code which checks if required edit checks passed
  /*Checking whether atleast one treasury symbol passed required edit checks successfully*/
      /*  l_sub_sbr:=FV_FACTS_TRANSACTIONS.v_g_edit_check_code;
        IF l_sub_sbr <> 2 AND l_one_edit_pass=0 THEN
         l_one_edit_pass:=1;
        END IF;*/

        IF (retcode_facts <> 0 )THEN
          IF (retcode_facts =1 )THEN

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Unable to process FACTS II in sbr for retcode_facts= 1 and  TS ...'|| parm_treasury_value||errbuf_facts);
          END IF;
          -- Commenting out the code which checks if required edit checks passed
          /*  IF (FV_FACTS_TRANSACTIONS.v_g_edit_check_code = 2)THEN
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Purging old data  as Required Edits failed for the Treasury Symbol...'|| parm_treasury_value||errbuf_facts);
              retcode :=1;
              --Purging old data from fv_facts_temp table
              purge_facts_transactions;
              --return; bug 9191060; if edits fail for one process, the other processes should continue
          END IF;*/

          END IF;
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Unable to process FACTS II in sbr for TS ...'|| parm_treasury_value||errbuf_facts);
          END IF;

        END IF;
      END LOOP;
      -- end for if retcode_facts <> 0
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'FV_FACTS_TRANSACTIONS.v_g_edit_check_code ->'||FV_FACTS_TRANSACTIONS.v_g_edit_check_code);

     -- Commentd out code which checks if required edit checks  passedd

       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'CALLING BUILD REPORT LINES.....');
        END IF;
        build_report_lines;

        IF g_error_code <> 0 THEN
          errbuf        := errbuf || 'Processing for Treasury Symbol '|| parm_treasury_value||' FAILED '|| g_error_message;
        ELSE
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'SUBMITTING sbr  REPORT FOR TS.....'||parm_treasury_value);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'BEFORE CALLING REPORT -> v_retcode :'||v_retcode);
          END IF;

          IF v_retcode     IN (0, 1) THEN
            l_request_id   := FND_REQUEST.SUBMIT_REQUEST ('FV', 'FVSBRCMR', '', '', FALSE, v_sequence_id, v_sob, v_period_name, p_units, v_report_type, v_end_date,v_period_fiscal_year);
            IF l_request_id = 0 THEN
              errbuf       := 'Error submitting Consolidated Financial Statements Report';
              retcode      := -1;
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',errbuf);
              RETURN;
            ELSE
              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'CONCURRENT REQUEST ID FOR CONSOLIDATED FINANCIAL STATEMENTS REPORT - ' || l_request_id);
              END IF;
            END IF;
          END IF;
        END IF;

        COMMIT;

        if errbuf_facts is not null then
          errbuf := errbuf_facts|| ' -- Due to Error unable to submit of FACTS II Process ';
        else
           errbuf := errbuf|| 'Unable to submit FACSTS II Process due to unknow error';
        end if ;
         retcode :=1;
     -- END IF;
    ELSE
      -- Processing NON-SBR report line definitions
      populate_ccid;
      build_dynamic_query;
      IF v_retcode IN (0, 1) THEN
        process_report_line;
      END IF;
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'BEFORE CALLING REPORT -> v_retcode :'||v_retcode);
       END IF;
      IF v_retcode     IN (0, 1) THEN
        l_request_id   := FND_REQUEST.SUBMIT_REQUEST ('FV', 'FVCFSCMR', '', '', FALSE, v_sequence_id, v_sob, v_period_name, p_units, v_report_type, v_end_date );
        IF l_request_id = 0 THEN
          errbuf       := 'Error submitting Consolidated Financial Statements Report';
          retcode      := -1;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',errbuf);
          RETURN;
        ELSE

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'CONCURRENT REQUEST ID FOR CONSOLIDATED FINANCIAL STATEMENTS REPORT - ' || l_request_id);
        END IF;
        COMMIT;
        END IF;
      END IF;
     retcode := v_retcode;
     errbuf  := v_errbuf;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    retcode := SQLCODE ;
    errbuf  := SQLERRM || ' [MAIN] ' ;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_errbuf);
    ROLLBACK;
    COMMIT ;
  END main;
  -- =============================================================
PROCEDURE get_qualifier_segments
                              IS
  l_module_name      VARCHAR2(200) := g_module_name || 'get_qualifier_segments';
  num_boolean        BOOLEAN ;
  apps_id            NUMBER DEFAULT 101 ;
  flex_code          VARCHAR2(25) DEFAULT 'GL#' ;
  seg_number         NUMBER ;
  seg_app_name       VARCHAR2(40) ;
  seg_prompt         VARCHAR2(25) ;
  seg_value_set_name VARCHAR2(40) ;
  invalid_segment    EXCEPTION ;
BEGIN
  -- Get Accounting Segment
  num_boolean := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM (apps_id, flex_code, v_chart_of_accounts_id, 'GL_ACCOUNT', seg_number);
  IF(num_boolean) THEN
    num_boolean := FND_FLEX_APIS.GET_SEGMENT_INFO (apps_id, flex_code, v_chart_of_accounts_id, seg_number, v_acc_seg_name, seg_app_name, seg_prompt, seg_value_set_name);
     SELECT flex_value_set_id
       INTO v_acct_flex_value_set_id
       FROM fnd_id_flex_segments_vl
      WHERE application_id = 101
    AND id_flex_code       = 'GL#'
    AND id_flex_num        = v_chart_of_accounts_id
    AND enabled_flag       = 'Y'
    AND segment_num        = seg_number;
  ELSE
    RAISE invalid_segment;
  END IF;
  -- Get Balancing Segment
  num_boolean := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM (apps_id, flex_code, v_chart_of_accounts_id, 'GL_BALANCING', seg_number);
  IF(num_boolean) THEN
    num_boolean := FND_FLEX_APIS.GET_SEGMENT_INFO (apps_id, flex_code, v_chart_of_accounts_id, seg_number, v_bal_seg_name, seg_app_name, seg_prompt, seg_value_set_name);
     SELECT flex_value_set_id
       INTO v_bal_flex_value_set_id
       FROM fnd_id_flex_segments_vl
      WHERE application_id = 101
    AND id_flex_code       = 'GL#'
    AND id_flex_num        = v_chart_of_accounts_id
    AND enabled_flag       = 'Y'
    AND segment_num        = seg_number;
  ELSE
    RAISE invalid_segment;
  END IF;
  v_acc_seg_name := UPPER(v_acc_seg_name) ;
  v_bal_seg_name := UPPER(v_bal_seg_name) ;
EXCEPTION
WHEN invalid_segment THEN
  v_retcode := -1;
  v_errbuf  := 'Error getting Balancing and Accounting segments.';
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.invalid_segment',v_errbuf);
  ROLLBACK;
  RETURN;
WHEN OTHERS THEN
  v_retcode := SQLCODE;
  v_errbuf  := sqlerrm ;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_errbuf);
  RETURN;
END get_qualifier_segments ;
-- =============================================================
PROCEDURE populate_ccid
                              IS
  l_module_name VARCHAR2(200) := g_module_name || 'populate_ccid';
TYPE t_seg_name_table
IS
  TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_seg_str_table
IS
  TABLE OF VARCHAR2(10000) INDEX BY BINARY_INTEGER;
  v_seg t_seg_name_table;
  v_statement        VARCHAR2(25000);
  v_insert_statement VARCHAR2(25000);
  v_seg_str t_seg_str_table;
  CURSOR flex
  IS
     SELECT application_column_name ,
      flex_value_set_id
       FROM fnd_id_flex_segments
      WHERE id_flex_code = 'GL#'
    AND application_id   = 101
    AND id_flex_num      = v_chart_of_accounts_id;
  CURSOR child_value(seg VARCHAR2,sid NUMBER)
  IS
     SELECT child_flex_value_low,
      child_flex_value_high
       FROM fnd_flex_value_hierarchies
      WHERE parent_FLEX_value = seg
    AND flex_value_set_id     = sid;

  child_rec child_value%ROWTYPE;
  CURSOR CREC
  IS
     SELECT d.line_id ,
      d.line_detail_id,
      segment1        ,
      segment2        ,
      segment3        ,
      segment4        ,
      segment5        ,
      segment6        ,
      segment7        ,
      segment8        ,
      segment9        ,
      segment10       ,
      segment11       ,
      segment12       ,
      segment13       ,
      segment14       ,
      segment15       ,
      segment16       ,
      segment17       ,
      segment18       ,
      segment19       ,
      segment20       ,
      segment21       ,
      segment22       ,
      segment23       ,
      segment24       ,
      segment25       ,
      segment26       ,
      segment27       ,
      segment28       ,
      segment29       ,
      segment30
       FROM fv_cfs_rep_line_dtl d,
      fv_cfs_rep_lines L
      WHERE l.report_type = v_report_type
    AND d.line_id         = l.line_id
    AND l.set_of_books_id = v_sob
   ORDER BY 2;
  CURSOR SBR_CREC
  IS
     SELECT d.sbr_line_id ,
      d.sbr_line_acct_id  ,
      segment1            ,
      segment2            ,
      segment3            ,
      segment4            ,
      segment5            ,
      segment6            ,
      segment7            ,
      segment8            ,
      segment9            ,
      segment10           ,
      segment11           ,
      segment12           ,
      segment13           ,
      segment14           ,
      segment15           ,
      segment16           ,
      segment17           ,
      segment18           ,
      segment19           ,
      segment20           ,
      segment21           ,
      segment22           ,
      segment23           ,
      segment24           ,
      segment25           ,
      segment26           ,
      segment27           ,
      segment28           ,
      segment29           ,
      segment30
       FROM fv_sbr_definitions_accts d,
      fv_sbr_definitions_lines l
      WHERE d.sbr_line_id = l.sbr_line_id
    AND l.set_of_books_id = v_sob
   ORDER BY 2;

  l_and         VARCHAR2(5);
  l_child       VARCHAR2(32000);
  l_no_of_child NUMBER;
  l_no_of_seg   NUMBER;
  l_segno       NUMBER;
  l_cnt         NUMBER;
BEGIN


  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Ccid process starts');
 IF upper(v_report_type)=upper('SBR') THEN
    FOR sbr_crec_rec    IN SBR_CREC
    LOOP
      v_seg(1)    := sbr_crec_rec.segment1;
      v_seg(2)    := sbr_crec_rec.segment2;
      v_seg(3)    := sbr_crec_rec.segment3;
      v_seg(4)    := sbr_crec_rec.segment4;
      v_seg(5)    := sbr_crec_rec.segment5;
      v_seg(6)    := sbr_crec_rec.segment6;
      v_seg(7)    := sbr_crec_rec.segment7;
      v_seg(8)    := sbr_crec_rec.segment8;
      v_seg(9)    := sbr_crec_rec.segment9;
      v_seg(10)   := sbr_crec_rec.segment10;
      v_seg(11)   := sbr_crec_rec.segment11;
      v_seg(12)   := sbr_crec_rec.segment12;
      v_seg(13)   := sbr_crec_rec.segment13;
      v_seg(14)   := sbr_crec_rec.segment14;
      v_seg(15)   := sbr_crec_rec.segment15;
      v_seg(16)   := sbr_crec_rec.segment16;
      v_seg(17)   := sbr_crec_rec.segment17;
      v_seg(18)   := sbr_crec_rec.segment18;
      v_seg(19)   := sbr_crec_rec.segment19;
      v_seg(20)   := sbr_crec_rec.segment20;
      v_seg(21)   := sbr_crec_rec.segment21;
      v_seg(22)   := sbr_crec_rec.segment22;
      v_seg(23)   := sbr_crec_rec.segment23;
      v_seg(24)   := sbr_crec_rec.segment24;
      v_seg(25)   := sbr_crec_rec.segment25;
      v_seg(26)   := sbr_crec_rec.segment26;
      v_seg(27)   := sbr_crec_rec.segment27;
      v_seg(28)   := sbr_crec_rec.segment28;
      v_seg(29)   := sbr_crec_rec.segment29;
      v_seg(30)   := sbr_crec_rec.segment30;
      v_statement := NULL;
      FOR i       IN 1 ..30
      LOOP
        v_seg_str(i) := NULL;
      END LOOP;
      l_no_of_seg  := 0;
      FOR flex_rec IN flex
      LOOP
        l_no_of_child := 0;
        l_and         := NULL;
        -- Check if the segment value is a parent
        l_segno           := SUBSTR(flex_rec.application_column_name,8,2);
        IF v_seg(l_segno) IS NOT NULL THEN
         --1
           SELECT COUNT(*)
             INTO l_cnt
             FROM fnd_flex_value_hierarchies
            WHERE parent_FLEX_value = v_seg(l_segno)
          AND flex_value_set_id     = flex_rec.flex_value_set_id;
          IF (l_cnt                 > 0) THEN
           -- 2
            OPEN child_value(v_seg(l_segno) , flex_rec.flex_value_set_id);
            l_and          := NULL;
            IF (l_no_of_seg > 0) THEN
              l_and        := ' AND ';
            END IF;
            l_child := l_and || ' ( ';
            LOOP
              FETCH child_value INTO child_rec;
              EXIT
            WHEN child_value%NOTFOUND ;
              IF l_no_of_child > 0 THEN
                l_child       := l_child || ' OR ';
              END IF;
              l_child       := l_child || flex_rec.application_column_name || ' between '|| '''' || child_rec.child_flex_value_low || '''  and  ''' || child_rec.child_flex_value_high || '''' || fnd_global.local_chr(10);
              l_no_of_child := l_no_of_child + 1;
            END LOOP;
            l_child     := l_child || ' )' ;
            l_and       := NULL;
            v_statement := v_statement || l_and || L_CHILD || fnd_global.local_chr(10);
            CLOSE CHILD_VALUE;
          ELSE
            -- 2
            IF (l_no_of_seg > 0) THEN
              l_and        := ' AND ';
            END IF;
            v_statement := v_statement || l_and || flex_rec.application_column_name || ' = ''' || v_seg(l_segno) || ''' ' || fnd_global.local_chr(10);
          END IF;
          -- cnt > 0
          l_no_of_seg := l_no_of_seg + 1;
        END IF;
      END LOOP;
      --crec_rec
      IF (v_statement      IS NOT NULL) THEN
        v_insert_statement := 'insert into fv_sbr_ccids_gt(
              sbr_line_acct_id,
              ccid)
              select  ' || sbr_crec_rec.sbr_line_acct_id || ', code_combination_id  ' ||
              '  from gl_code_combinations WHERE ' ||v_acc_seg_name  || 'like '':b_account_number%''''   and template_id is null  and '
              || ' chart_of_accounts_id  = :B_CHART_OF_ACCOUNTS_ID
              and not exists (select code_combination_id
              from fv_sbr_ccids_gt FCT ' || 'where fct.detail_id =  :b_line_detail_id '|| ')';
        EXECUTE immediate v_insert_statement USING V_CHART_OF_ACCOUNTS_ID,
        sbr_crec_rec.sbr_line_acct_id;
        COMMIT;
      END IF;
    END LOOP;
    --SBR POPULATE CCID
  ELSE
    /*NON SBR data*/
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Ccid process starts');
    FOR crec_rec IN crec
    LOOP
      v_seg(1)    := crec_rec.segment1;
      v_seg(2)    := crec_rec.segment2;
      v_seg(3)    := crec_rec.segment3;
      v_seg(4)    := crec_rec.segment4;
      v_seg(5)    := crec_rec.segment5;
      v_seg(6)    := crec_rec.segment6;
      v_seg(7)    := crec_rec.segment7;
      v_seg(8)    := crec_rec.segment8;
      v_seg(9)    := crec_rec.segment9;
      v_seg(10)   := crec_rec.segment10;
      v_seg(11)   := crec_rec.segment11;
      v_seg(12)   := crec_rec.segment12;
      v_seg(13)   := crec_rec.segment13;
      v_seg(14)   := crec_rec.segment14;
      v_seg(15)   := crec_rec.segment15;
      v_seg(16)   := crec_rec.segment16;
      v_seg(17)   := crec_rec.segment17;
      v_seg(18)   := crec_rec.segment18;
      v_seg(19)   := crec_rec.segment19;
      v_seg(20)   := crec_rec.segment20;
      v_seg(21)   := crec_rec.segment21;
      v_seg(22)   := crec_rec.segment22;
      v_seg(23)   := crec_rec.segment23;
      v_seg(24)   := crec_rec.segment24;
      v_seg(25)   := crec_rec.segment25;
      v_seg(26)   := crec_rec.segment26;
      v_seg(27)   := crec_rec.segment27;
      v_seg(28)   := crec_rec.segment28;
      v_seg(29)   := crec_rec.segment29;
      v_seg(30)   := crec_rec.segment30;
      v_statement := NULL;
      FOR i       IN 1 ..30
      LOOP
        v_seg_str(i) := NULL;
      END LOOP;
      l_no_of_seg  := 0;
      FOR flex_rec IN flex
      LOOP
        l_no_of_child := 0;
        l_and         := NULL;
        -- Check if the segment value is a parent
        l_segno           := SUBSTR(flex_rec.application_column_name,8,2);
        IF v_seg(l_segno) IS NOT NULL THEN
          /* 1 */
           SELECT COUNT(*)
             INTO l_cnt
             FROM fnd_flex_value_hierarchies
            WHERE parent_FLEX_value = v_seg(l_segno)
          AND flex_value_set_id     = flex_rec.flex_value_set_id;
          IF (l_cnt                 > 0) THEN
            /* 2 */
            OPEN child_value(v_seg(l_segno) , flex_rec.flex_value_set_id);
            l_and          := NULL;
            IF (l_no_of_seg > 0) THEN
              l_and        := ' AND ';
            END IF;
            l_child := l_and || ' ( ';
            LOOP
              FETCH child_value INTO child_rec;
              EXIT
            WHEN child_value%NOTFOUND ;
              IF l_no_of_child > 0 THEN
                l_child       := l_child || ' OR ';
              END IF;
              l_child       := l_child || flex_rec.application_column_name || ' between '|| '''' || child_rec.child_flex_value_low || '''  and  ''' || child_rec.child_flex_value_high || '''' || fnd_global.local_chr(10);
              l_no_of_child := l_no_of_child + 1;
            END LOOP;
            l_child     := l_child || ' )' ;
            l_and       := NULL;
            v_statement := v_statement || l_and || L_CHILD || fnd_global.local_chr(10);
            CLOSE CHILD_VALUE;
          ELSE
            /* 2 */
            IF (l_no_of_seg > 0) THEN
              l_and        := ' AND ';
            END IF;
            v_statement := v_statement || l_and || flex_rec.application_column_name || ' = ''' || v_seg(l_segno) || ''' ' || fnd_global.local_chr(10);
          END IF;
          /* cnt > 0 */
          l_no_of_seg := l_no_of_seg + 1;
        END IF;
      END LOOP;
      /* crec_rec */
      IF (v_statement      IS NOT NULL) THEN
        v_insert_statement := 'insert into FV_CCID_CFS_GT(
detail_id,
ccid)
select  ' || crec_rec.line_detail_id || ',  code_combination_id  '
|| '  from gl_code_combinations WHERE ' || v_statement || '   and
 template_id is null  and ' || ' chart_of_accounts_id  = :B_CHART_OF_ACCOUNTS_ID
and not exists (select code_combination_id
from fv_ccid_CFS_GT FCT ' || 'where fct.detail_id =  :b_line_detail_id '|| ')';

        EXECUTE immediate v_insert_statement USING V_CHART_OF_ACCOUNTS_ID,
        crec_rec.line_detail_id;
        COMMIT;
      END IF;
    END LOOP;
 END IF;
  /* flex_crec */
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Popualte CCID  Completed');
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_retcode := -1;
  v_errbuf  := '[POPULATE-CCID]' || sqlerrm;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_errbuf);
  RETURN;
END populate_ccid;
-- =============================================================
PROCEDURE build_dynamic_query
                              IS
  l_module_name VARCHAR2(200) := g_module_name || 'build_dynamic_query';
  CURSOR flex_columns_cursor
  IS
     SELECT UPPER(glflex.application_column_name) column_name,
      flex_value_set_id
       FROM fnd_id_flex_segments glflex
      WHERE glflex.application_id = 101
    AND glflex.id_flex_num        = v_chart_of_accounts_id
    AND glflex.id_flex_code       = 'GL#'
   ORDER BY glflex.application_column_name;

  l_flex_column_name fnd_id_flex_segments.application_column_name%TYPE;
  l_flex_value_set_id fnd_id_flex_segments.flex_value_set_id%TYPE;
  l_temp1             VARCHAR2(8000) DEFAULT '';
  l_temp2             VARCHAR2(8000) DEFAULT '';
  l_table_name        VARCHAR2(50);
  l_period_name_where VARCHAR2(500);
  l_stage             NUMBER;
  l_out               VARCHAR2(32000);
  l_column_name       VARCHAR2(30);
  l_glbal_temp        VARCHAR2(32000);
BEGIN
  v_fct1_attr_select :=
  ' SELECT SUM(NVL(DECODE(:cv_balance_type,
''B'', ROUND(NVL(fctbal.begin_balance,0),2),
''E'', ROUND(NVL(fctbal.balance_amount,0))),0) )
FROM  fv_cfs_rep_line_dtl        dets,
fv_ccid_cfs_gt               fvcc,
fv_facts1_period_attributes  fctbal
WHERE dets.line_id           = :cv_line_id
AND dets.line_detail_id    = :cv_line_detail_id
AND dets.line_detail_id           = fvcc.detail_id
AND fctbal.ccid  = fvcc.ccid
AND fctbal.set_of_books_id =       :b_sob
AND fctbal.period_year          =  :cv_period_fiscal_year
AND nvl(dets.cust_non_cust, nvl(fctbal.cust_non_cust, 1)) = nvl(fctbal.cust_non_cust, 1)
AND nvl(dets.exch_non_exch, nvl(fctbal.exch_non_exch, 1)) = nvl(fctbal.exch_non_exch, 1)
AND EXISTS
(SELECT 1
FROM fv_fund_parameters ffp
WHERE set_of_books_id = :b_sob
AND fund_category like nvl(dets.fund_category, ''%'')
AND ffp.fund_value = fctbal.fund_value
AND ( (dets.fund_status = ''E'' and trunc(fund_expire_date)  <= :cv_end_date )
OR (dets.fund_status = ''U''
and (trunc(fund_expire_date) >= :cv_end_date or fund_expire_date is null)
and (trunc(fund_cancel_date) > :cv_end_date  or fund_cancel_date is null))
OR (nvl(dets.fund_status,''B'')  = ''B'' )))  '
  ;
  l_stage       := 1;
  l_out         := v_fct1_attr_select;
  v_glbal_curid := dbms_sql.open_cursor;
  dbms_sql.parse(v_glbal_curid, v_fct1_attr_select, dbms_sql.v7);
  dbms_sql.define_column(v_glbal_curid, 1, v_amount);
  dbms_sql.bind_variable(v_glbal_curid,':b_sob',v_sob);
  v_fct1_sel      := 'SELECT ROUND(SUM(NVL(ffrt.amount,0) ),2) ';
  v_fct1_rcpt_sel := v_fct1_sel || ' , ffrt.recipient_name ';
  l_temp1         := '
FROM  fv_ccid_cfs_gt    fvcc,
fv_cfs_rep_line_dtl    dets,
fv_facts1_period_balances_v ffrt
WHERE dets.line_id         = :cv_line_id
AND dets.line_detail_id    = :cv_line_detail_id
AND dets.line_detail_id    = fvcc.detail_id
AND ffrt.ccid              = fvcc.ccid
AND ffrt.period_year = :cv_period_fiscal_year
AND ffrt.set_of_books_id  = :b_sob
AND ffrt.period_num <= :cv_period_num
AND ffrt.balance_type = NVL(:cv_balance_type, ffrt.balance_type)
AND nvl(dets.fed_non_fed, nvl(ffrt.g_ng_indicator, 1)) =
REPLACE(nvl(ffrt.g_ng_indicator, nvl(dets.fed_non_fed, 1)), ' || '''' || ' ' || '''' ||
  ',
nvl(dets.fed_non_fed, nvl(ffrt.g_ng_indicator, 1)))
AND nvl(dets.cust_non_cust, nvl(ffrt.cust_non_cust, 1)) = nvl(ffrt.cust_non_cust, 1)
AND nvl(dets.exch_non_exch, nvl(ffrt.exch_non_exch, 1)) = nvl(ffrt.exch_non_exch, 1)' ;
  v_fct1_sel            := v_fct1_sel || l_temp1;
  v_fct1_rcpt_sel       := v_fct1_rcpt_sel || l_temp1 || ' GROUP BY ffrt.recipient_name ';
  l_stage               := 3;
  l_out                 := v_fct1_rcpt_sel;
  v_fct1_rcpt_sel_curid := dbms_sql.open_cursor;
  dbms_sql.parse(v_fct1_rcpt_sel_curid, v_fct1_rcpt_sel, dbms_sql.v7);
  dbms_sql.define_column(v_fct1_rcpt_sel_curid, 1, v_amount);
  dbms_sql.define_column(v_fct1_rcpt_sel_curid, 2, v_recipient_name, 240);
  dbms_sql.bind_variable(v_fct1_rcpt_sel_curid,':b_sob',v_sob);
  v_fct1_rcpt_sel2       := REPLACE(v_fct1_rcpt_sel, 'GROUP BY ffrt.recipient_name', 'AND ffrt.recipient_name = :cv_recipient_name');
  v_fct1_rcpt_sel2       := REPLACE(v_fct1_rcpt_sel2, ', ffrt.recipient_name', ', 1');
  l_stage                := 4;
  l_out                  := v_fct1_rcpt_sel2;
  v_fct1_rcpt_sel2_curid := dbms_sql.open_cursor;
  dbms_sql.parse(v_fct1_rcpt_sel2_curid, v_fct1_rcpt_sel2, dbms_sql.v7);
  dbms_sql.define_column(v_fct1_rcpt_sel2_curid, 1, v_amount);
  dbms_sql.define_column(v_fct1_rcpt_sel2_curid, 2, v_recipient_name, 240);
  dbms_sql.bind_variable(v_fct1_rcpt_sel2_curid,':b_sob',v_sob);
  l_stage          := 5;
  l_out            := v_fct1_sel;
  v_fct1_sel_curid := dbms_sql.open_cursor;
  dbms_sql.parse(v_fct1_sel_curid, v_fct1_sel, dbms_sql.v7);
  dbms_sql.define_column(v_fct1_sel_curid, 1, v_amount);
  dbms_sql.bind_variable(v_fct1_sel_curid,':b_sob',v_sob);
  v_glbal_select :=
  ' SELECT /*+ USE_HASH (glbal) */
NVL(DECODE(:cv_balance_type,
''B'', ROUND(NVL(SUM(NVL(glbal.begin_balance_dr,0) -
NVL(glbal.begin_balance_cr,0)),0),2),
''E'', ROUND(NVL(SUM((NVL(glbal.begin_balance_dr,0) -
NVL(glbal.begin_balance_cr,0)) +
(NVL(glbal.period_net_dr,0) -
NVL(glbal.period_net_cr,0))),0),2)),0)
FROM  fv_cfs_rep_line_dtl        dets,
fv_ccid_cfs_gt               fvcc,
gl_code_combinations       glc,
gl_balances                glbal
WHERE dets.line_id           = :cv_line_id
AND dets.line_detail_id    = :cv_line_detail_id
AND dets.line_detail_id           = fvcc.detail_id
AND glc.code_combination_id  = fvcc.ccid
AND glc.chart_of_accounts_id  =  :b_chart_of_accounts_id
AND glbal.code_combination_id  = glc.code_combination_id
AND glbal.ledger_id =       :b_sob
AND glbal.period_year          =  :cv_period_fiscal_year
AND glbal.period_num           =  :cv_period_num
--AND glbal.currency_code        <> ''STAT''
AND glbal.currency_code        = :v_currency_code
AND glbal.actual_flag          = ''A''
AND EXISTS
(SELECT 1
FROM fv_fund_parameters ffp
WHERE set_of_books_id = :b_sob
AND fund_category like nvl(dets.fund_category, ''%'')
AND ffp.fund_value = glc.'
  ||v_bal_seg_name||'
AND ( (dets.fund_status = ''E'' and trunc(fund_expire_date)  <= :cv_end_date )
OR (dets.fund_status = ''U''
and (trunc(fund_expire_date) >= :cv_end_date or fund_expire_date is null)
and (trunc(fund_cancel_date) > :cv_end_date  or fund_cancel_date is null))
OR (nvl(dets.fund_status,''B'')  = ''B'' )))  ';
  l_stage     := 6;
  l_out       := v_glbal_select;
  v_sbr_curid := dbms_sql.open_cursor;
  dbms_sql.parse(v_sbr_curid, v_glbal_select, dbms_sql.v7);
  dbms_sql.define_column(v_sbr_curid, 1, v_amount);
  dbms_sql.bind_variable(v_sbr_curid,':b_chart_of_accounts_id', v_chart_of_accounts_id);
  dbms_sql.bind_variable(v_sbr_curid,':b_sob',v_sob);
  dbms_sql.bind_variable(v_sbr_curid,':v_currency_code',v_currency_code);
EXCEPTION
WHEN OTHERS THEN
  v_retcode := SQLCODE ;
  v_errbuf  := SQLERRM || ' [BUILD_DYNAMIC_QUERY] ' ;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_errbuf);
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception','Stage it errors ' || l_stage);
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_out);
  RETURN;
END build_dynamic_query;
-- =============================================================
PROCEDURE process_report_line
                              IS
  l_module_name VARCHAR2(200) := g_module_name || 'process_report_line';
  CURSOR fv_cfs_lines_cur
  IS
     SELECT line_id       ,
      line_label          ,
      sequence_number     ,
      line_number         ,
      line_type           ,
      natural_balance_type,
      by_recipient
       FROM fv_cfs_rep_lines
      WHERE set_of_books_id = v_sob
    AND report_type         = v_report_type
   ORDER BY sequence_number;

  l_line_cnt NUMBER;
BEGIN
  istotal_cal   :=0;
  FOR lines_rec IN fv_cfs_lines_cur
  LOOP
    IF v_retcode             IN (0, 1) THEN
      v_line_id              := lines_rec.line_id;
      v_line_label           := lines_rec.line_label;
      v_line_type            := lines_rec.line_type;
      v_sequence_number      := lines_rec.sequence_number;
      v_line_number          := lines_rec.line_number;
      v_natural_balance_type := lines_rec.natural_balance_type;
      v_by_recipient         := lines_rec.by_recipient;
      v_col_1_amt            := 0;
      v_col_2_amt            := 0;
      v_col_3_amt            := 0;
      v_col_4_amt            := 0;
      -- SCNP ER 9479298
      v_col_5_amt            := 0;
      v_col_6_amt            := 0;
      v_col_7_amt            := 0;
      v_col_8_amt            := 0;
      IF lines_rec.line_type IN ('D', 'D2') THEN
        -- $$$dbms_sql.bind_variable(v_cursor_id1,':cv_line_id',v_line_id);
         SELECT COUNT(*)
           INTO l_line_cnt
           FROM fv_cfs_rep_line_dtl
          WHERE line_id = v_line_id;
        IF l_line_cnt   = 0 THEN
          NULL;
          populate_temp_table;
        ELSE
          process_detail_line;
        END IF;
        IF lines_rec.line_type = 'D2' THEN
          v_col_1_amt         := ABS(v_col_1_amt);
          v_col_2_amt         := ABS(v_col_1_amt);
          v_col_3_amt         := ABS(v_col_1_amt);
          v_col_4_amt         := ABS(v_col_1_amt);
        END IF;
      ELSIF lines_rec.line_type IN ('S', 'T') THEN
         SELECT COUNT(           *)
           INTO l_line_cnt
           FROM fv_cfs_rep_line_calc
          WHERE line_id = v_line_id;
        IF l_line_cnt   = 0 THEN
          v_retcode    := -1;
          v_errbuf     := 'SEED Data not properly Loaded. Please Verify and reinvoke the Process.';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',v_errbuf);
          RETURN;
        END IF;
        -- $$$dbms_sql.bind_variable(v_cursor_id1,':cv_line_id',v_line_id);
        process_total_line;
        istotal_cal:=1;
        populate_temp_table;
        istotal_cal             :=0;
      ELSIF lines_rec.line_type IN ('L', 'F') THEN
        v_col_1_amt             := NULL;
        v_col_2_amt             := NULL;
        v_col_3_amt             := NULL;
        v_col_4_amt             := NULL;
        -- SCNP ER 9479298
        v_col_5_amt             := NULL;
        v_col_6_amt             := NULL;
        v_col_7_amt             := NULL;
        v_col_8_amt             := NULL;
        populate_temp_table;
      END IF;
    END IF;
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  v_retcode := SQLCODE ;
  v_errbuf  := SQLERRM || ' [PROCESS_REPORT_LINE] ' ;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_errbuf);
  RETURN;
END process_report_line;
-- =============================================================
PROCEDURE get_one_time_values
                              IS
  l_module_name VARCHAR2(200) := g_module_name || 'get_one_time_values';
  l_stage       NUMBER;
BEGIN
  fv_utility.log_mesg('IN: '||l_module_name);
  l_stage := 1;
   SELECT chart_of_accounts_id,
    currency_code
     INTO v_chart_of_accounts_id,
    v_currency_code
     FROM gl_ledgers_public_v
    WHERE ledger_id = v_sob ;

  fv_utility.log_mesg('After  gl_ledgers_public_v: '||l_module_name);
  -- Get period number and fiscal year being run for
  l_stage := 2;
   SELECT TRUNC(end_date),
    period_num           ,
    period_year          ,
    end_date
     INTO v_end_date    ,
    v_period_num        ,
    v_period_fiscal_year,
    v_end_period_end_date
     FROM gl_period_statuses
    WHERE ledger_id  = v_sob
  AND application_id = '101'
  AND period_name    = v_period_name;

  v_end_period := v_period_num;
  -- Get begin period num, name and end date of the
  -- first non adjusting period of the current year
  l_stage := 3;
   SELECT period_num,
    period_name     ,
    end_date
     INTO v_begin_period,
    v_begin_period_name ,
    v_begin_period_end_date
     FROM gl_period_statuses
    WHERE ledger_id          = v_sob
  AND period_year            = v_period_fiscal_year
  AND adjustment_period_flag = 'N'
  AND application_id         = '101'
  AND period_num             =
    (SELECT MIN(period_num)
       FROM gl_period_statuses
      WHERE ledger_id          = v_sob
    AND period_year            = v_period_fiscal_year
    AND adjustment_period_flag = 'N'
    AND application_id         = '101'
    );
  -- Get begin period num, name and end date of the
  -- first non adjusting period of the prior year
  l_stage := 4;
   SELECT period_num,
    period_name     ,
    end_date
     INTO v_begin_period_1,
    v_begin_period_name_1 ,
    v_begin_period_1_end_date
     FROM gl_period_statuses
    WHERE ledger_id          = v_sob
  AND period_year            = v_period_fiscal_year-1
  AND adjustment_period_flag = 'N'
  AND application_id         = '101'
  AND period_num             =
    (SELECT MIN(period_num)
       FROM gl_period_statuses
      WHERE ledger_id          = v_sob
    AND period_year            = v_period_fiscal_year-1
    AND adjustment_period_flag = 'N'
    AND application_id         = '101'
    ) ;
  -- Get py period end date for the period being run
  l_stage := 5;
   SELECT end_date
     INTO v_end_period_1_end_date
     FROM gl_period_statuses
    WHERE ledger_id  = v_sob
  AND period_year    = v_period_fiscal_year-1
  AND application_id = '101'
  AND period_num     = v_period_num;

  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Chart of accounts id: '||v_chart_of_accounts_id);
  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Fiscal year: '||v_period_fiscal_year);
  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_period_name: '||v_period_name);
  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_period_num: '||v_period_num);
  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_end_date: '||v_end_date);
  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_begin_period: '||v_begin_period);
  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_begin_period_end_date: '||v_begin_period_end_date);
  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_begin_period_1: '||v_begin_period_1);
  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_begin_period_1_end_date: '||v_begin_period_1_end_date);
  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_end_period_1_end_date: '||v_end_period_1_end_date);
EXCEPTION
WHEN NO_DATA_FOUND THEN
  IF l_stage = 4 OR l_stage = 5 THEN
    fv_utility.log_mesg('No calendar has been setup for the year: '||TO_CHAR(v_period_fiscal_year-1));
    fv_utility.log_mesg('The Prior Year column will have zero amounts.');
    v_begin_period_1          := 0;
    v_begin_period_name_1     := 'XXX';
    v_begin_period_1_end_date := to_date('01/01/1900', 'mm/dd/yyyy');
    v_end_period_1_end_date   := to_date('01/01/1900', 'mm/dd/yyyy');
  ELSE
    v_retcode := -1;
    v_errbuf  := 'When no data found error in get_one_time_values, at stage: '||l_stage;
    fnd_file.put_line(fnd_file.log, v_errbuf);
    RETURN;
  END IF;
WHEN OTHERS THEN
  v_retcode := -1;
  v_errbuf  := 'When others error in get_one_time_values, at stage: '||l_stage;
  fnd_file.put_line(fnd_file.log, v_errbuf);
END get_one_time_values;
-- =============================================================
PROCEDURE process_detail_line
                              IS
  l_module_name VARCHAR2(200) := g_module_name || 'process_detail_line';
  CURSOR fv_cfs_detail_cur
  IS
     SELECT line_detail_id,
      balance_type,
      cum_res,
      unexp_approp,
      budget_col,
      nbfa_col,
      flex_further_def,
      fed_non_fed,
      exch_non_exch,
      cust_non_cust,
      scnp_elim,
      DECODE(v_acc_seg_name, 'SEGMENT1', SEGMENT1, 'SEGMENT11',
      SEGMENT11, 'SEGMENT21', SEGMENT21, 'SEGMENT2', SEGMENT2, 'SEGMENT12',
      SEGMENT12, 'SEGMENT22', SEGMENT22, 'SEGMENT3', SEGMENT3, 'SEGMENT13',
      SEGMENT13, 'SEGMENT23', SEGMENT23, 'SEGMENT4', SEGMENT4, 'SEGMENT14',
      SEGMENT14, 'SEGMENT24', SEGMENT24, 'SEGMENT5', SEGMENT5, 'SEGMENT15',
      SEGMENT15, 'SEGMENT25', SEGMENT25, 'SEGMENT6', SEGMENT6, 'SEGMENT16', SEGMENT16,
      'SEGMENT26', SEGMENT26, 'SEGMENT7', SEGMENT7, 'SEGMENT17', SEGMENT17, 'SEGMENT27',
      SEGMENT27, 'SEGMENT8', SEGMENT8, 'SEGMENT18', SEGMENT18, 'SEGMENT28', SEGMENT28,
      'SEGMENT9', SEGMENT9, 'SEGMENT19', SEGMENT19, 'SEGMENT29', SEGMENT29, 'SEGMENT10',
      SEGMENT10, 'SEGMENT20', SEGMENT20, 'SEGMENT30', SEGMENT30) account_number,
      segment1
      || '.'
      || segment2
      || '.'
      || segment3
      || '.'
      || segment4
      || '.'
      || segment5
      || '.'
      || segment6
      || '.'
      || segment7
      || '.'
      || segment8
      || '.'
      || segment9
      || '.'
      || segment10
      || '.'
      || segment11
      || '.'
      || segment12
      || '.'
      || segment13
      || '.'
      || segment14
      || '.'
      || segment15
      || '.'
      || segment16
      || '.'
      || segment17
      || '.'
      || segment18
      || '.'
      || segment19
      || '.'
      || segment20
      || '.'
      || segment21
      || '.'
      || segment22
      || '.'
      || segment23
      || '.'
      || segment24
      || '.'
      || segment25
      || '.'
      || segment26
      || '.'
      || segment27
      || '.'
      || segment28
      || '.'
      || segment29
      || '.'
      || segment30 concatenated_segments
       FROM fv_cfs_rep_line_dtl
      WHERE line_id = v_line_id;

TYPE l_recipient_rec_type
IS
  RECORD
  (
    recipient_name fv_facts_report_t2.recipient_name%TYPE,
    col_1_amt fv_cfs_rep_temp.col_1_amt%TYPE := 0,
    col_2_amt fv_cfs_rep_temp.col_1_amt%TYPE := 0,
    col_3_amt fv_cfs_rep_temp.col_1_amt%TYPE := 0,
    col_4_amt fv_cfs_rep_temp.col_1_amt%TYPE := 0);
TYPE l_recipient_table
IS
  TABLE OF l_recipient_rec_type INDEX BY BINARY_INTEGER;
  l_recipient_rec l_recipient_table;
  l_recipient_cnt BINARY_INTEGER := 1;
  l_found BOOLEAN;
  l_temp_str fv_cfs_rep_lines.line_label%TYPE;
  l_ignore INTEGER;
  l_prev_year_amount fv_cfs_rep_temp.col_1_amt%TYPE := 0;
  l_begin_balance NUMBER;
  l_end_balance   NUMBER;
  l_period_name_1 gl_period_statuses.period_name%TYPE;
  l_period_name_2 gl_period_statuses.period_name%TYPE;
  l_begin_period_name gl_period_statuses.period_name%TYPE;
  l_begin_period_name_1 gl_period_statuses.period_name%TYPE;
  l_begin_period_name_2 gl_period_statuses.period_name%TYPE;
  l_period_fiscal_year NUMBER;
  l_begin_period       NUMBER;
  l_end_period         NUMBER := v_period_num;
  l_end_period_1       NUMBER ;
  l_end_period_name_1 gl_period_statuses.period_name%TYPE;
  l_begin_period_1 NUMBER;
  l_begin_period_end_date DATE;
  l_end_period_end_date DATE := v_end_date;
  l_begin_period_1_end_date DATE;
  l_end_period_1_end_date DATE;
  l_log_mesg  VARCHAR2(32000) := '';
  l_conc_segs VARCHAR2(32000);
  l_delimiter fnd_id_flex_structures.concatenated_segment_delimiter%TYPE;
  l_account_type VARCHAR2(1) := '';
  l_account_number gl_code_combinations.segment1%TYPE;
  l_balance_determined   NUMBER;
  l_prev_year_gl_balance NUMBER;
  l_curr_year_gl_balance NUMBER;
  l_e_ne_ind fv_facts_attributes.exch_non_exch%TYPE := NULL;
  l_c_nc_ind fv_facts_attributes.cust_non_cust%TYPE := NULL;
  l_diff_amt       NUMBER;
  l_diff_amt_tot   NUMBER := 0;
  l_temp_amount    NUMBER;
  l_ussgl_acct_num NUMBER;
  l_period_year gl_period_statuses.period_name%TYPE;
  l_amount          NUMBER;
  l_end_period_num1 NUMBER;
  l_end_period_num2 NUMBER;
  l_ccid_gl_amt     NUMBER;
  l_gl_tot_amt      NUMBER;
  l_bal_type_amt    NUMBER;
BEGIN
   SELECT concatenated_segment_delimiter
     INTO l_delimiter
     FROM fnd_id_flex_structures
    WHERE application_id = 101
  AND id_flex_code       = 'GL#'
  AND id_flex_num        = v_chart_of_accounts_id;

  l_log_mesg := '***** Line Number' || v_line_number || ':  ' || '*****';
  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,l_log_mesg);
  FOR detail_rec IN fv_cfs_detail_cur
  LOOP ---- L1
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '########');
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Account Num: '||detail_rec.account_number);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'line id: '||v_line_id);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'line detail id: '||detail_rec.line_detail_id);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'balance type: '||detail_rec.balance_type);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Fed Non Fed: '||detail_rec.fed_non_fed);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'By Recipient: '||v_by_recipient);
    v_balance_type         := detail_rec.balance_type;
    l_balance_determined   := 0;
    l_prev_year_gl_balance := 0;
    l_curr_year_gl_balance := 0;
    l_diff_amt_tot         := 0;
     SELECT RTRIM(REPLACE(detail_rec.concatenated_segments, '.', l_delimiter),l_delimiter)
       INTO l_conc_segs
       FROM dual;
    IF detail_rec.flex_further_def = 'Y' THEN --- 1
      l_log_mesg                  := 'Accounting Flexfield -1' || l_conc_segs || '     ' || 'Flexfield Needs Further Definition.' ;
      fnd_file.put_line(fnd_file.log, 'Warning: Accounting Flexfield - '||l_conc_segs||' needs further definition.');
      v_retcode := 1;
    ELSE                           --- 1
      IF v_by_recipient = 'Y' THEN --- 2
        dbms_sql.bind_variable(v_fct1_rcpt_sel_curid,':cv_line_id',v_line_id);
        dbms_sql.bind_variable(v_fct1_rcpt_sel_curid,':cv_line_detail_id',detail_rec.line_detail_id);
        dbms_sql.bind_variable(v_fct1_rcpt_sel_curid,':cv_balance_type',detail_rec.balance_type);
        dbms_sql.bind_variable(v_fct1_rcpt_sel_curid,':cv_period_fiscal_year',v_period_fiscal_year);
        dbms_sql.bind_variable(v_fct1_rcpt_sel_curid,':cv_period_num', v_end_period);
        l_ignore := dbms_sql.execute(v_fct1_rcpt_sel_curid);
        dbms_sql.bind_variable(v_fct1_rcpt_sel2_curid,':cv_line_id',v_line_id);
        dbms_sql.bind_variable(v_fct1_rcpt_sel2_curid,':cv_line_detail_id',detail_rec.line_detail_id);
        dbms_sql.bind_variable(v_fct1_rcpt_sel2_curid,':cv_balance_type',detail_rec.balance_type);
        dbms_sql.bind_variable(v_fct1_rcpt_sel2_curid,':cv_period_fiscal_year',v_period_fiscal_year-1);
        dbms_sql.bind_variable(v_fct1_rcpt_sel2_curid,':cv_period_num', v_end_period);
        LOOP
          l_ignore := dbms_sql.fetch_rows(v_fct1_rcpt_sel_curid);
          EXIT
        WHEN l_ignore= 0;
          dbms_sql.column_value(v_fct1_rcpt_sel_curid, 1, v_amount);
          dbms_sql.column_value(v_fct1_rcpt_sel_curid, 2, v_recipient_name);
          v_col_1_amt := NVL(v_amount, 0);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Recipient name: '||v_recipient_name);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Recipient amount: '||v_amount);
          dbms_sql.bind_variable(v_fct1_rcpt_sel2_curid,':cv_recipient_name',v_recipient_name);
          l_ignore := dbms_sql.execute_and_fetch(v_fct1_rcpt_sel2_curid);
          dbms_sql.column_value(v_fct1_rcpt_sel2_curid, 1, v_amount);
          v_col_2_amt := NVL(v_amount, 0);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Recipient group by amount: '||v_amount);
          l_found := FALSE;
          FOR i   IN 1..l_recipient_cnt - 1
          LOOP
            IF l_recipient_rec(i).recipient_name = v_recipient_name THEN
              l_recipient_rec(i).col_1_amt      := l_recipient_rec(i).col_1_amt + v_col_1_amt;
              l_recipient_rec(i).col_2_amt      := l_recipient_rec(i).col_2_amt + v_col_2_amt;
              l_found                           := TRUE;
            END IF;
          END LOOP;
          IF NOT l_found THEN
            l_recipient_rec(l_recipient_cnt).recipient_name := v_recipient_name;
            l_recipient_rec(l_recipient_cnt).col_1_amt      := v_col_1_amt;
            l_recipient_rec(l_recipient_cnt).col_2_amt      := v_col_2_amt;
            l_recipient_cnt                                 := l_recipient_cnt + 1;
          END IF;
        END LOOP;
      ELSE --- 2
        IF detail_rec.account_number IS NOT NULL THEN
          BEGIN
             SELECT SUBSTR(compiled_value_attributes, 5, 1)
               INTO l_account_type
               FROM fnd_flex_values
              WHERE flex_value    = detail_rec.account_number
            AND flex_value_set_id = v_acct_flex_value_set_id;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT parent_flex_value
                 INTO l_account_number
                 FROM fnd_flex_value_hierarchies
                WHERE detail_rec.account_number BETWEEN child_flex_value_low AND child_flex_value_high
              AND flex_value_set_id = v_acct_flex_value_set_id
              AND ROWNUM            = 1;
               SELECT SUBSTR(compiled_value_attributes, 5, 1)
                 INTO l_account_type
                 FROM fnd_flex_values
                WHERE flex_value    = l_account_number
              AND flex_value_set_id = v_acct_flex_value_set_id;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
            END;
          END;
        END IF;
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Account Type: '||l_account_type);
        -- ===================================================================
        v_py_gl_beg_bal := 0;
        v_py_gl_end_bal := 0;
        v_cy_gl_beg_bal := 0;
        v_cy_gl_end_bal := 0;
        -- Get beginning balances for current and prior years from
        -- facts1 attributes.
        dbms_sql.bind_variable(v_glbal_curid,':cv_line_id',v_line_id);
        dbms_sql.bind_variable(v_glbal_curid,':cv_line_detail_id',detail_rec.line_detail_id);
        -- Get prior year beginning balance
        dbms_sql.bind_variable(v_glbal_curid,':cv_period_fiscal_year',v_period_fiscal_year-1);
        dbms_sql.bind_variable(v_glbal_curid,':cv_balance_type','B');
        dbms_sql.bind_variable(v_glbal_curid,':cv_end_date', v_begin_period_1_end_date);
        l_ignore := dbms_sql.execute_and_fetch(v_glbal_curid);
        dbms_sql.column_value(v_glbal_curid, 1, v_py_gl_beg_bal);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Prior year begin gl bal: '||v_py_gl_beg_bal);
        -- Get current year beginning balance
        dbms_sql.bind_variable(v_glbal_curid,':cv_period_fiscal_year',v_period_fiscal_year);
        dbms_sql.bind_variable(v_glbal_curid,':cv_end_date', v_begin_period_end_date);
        dbms_sql.bind_variable(v_glbal_curid,':cv_balance_type','B');
        l_ignore := dbms_sql.execute_and_fetch(v_glbal_curid);
        dbms_sql.column_value(v_glbal_curid, 1, v_cy_gl_beg_bal);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Current year begin gl bal: '||v_cy_gl_beg_bal);
        -- ===================================================================
        IF v_report_type   <> 'sbr' AND l_account_type NOT IN ('D','C') THEN --- 3
          v_py_fct1_begbal := 0;
          v_py_fct1_endbal := 0;
          v_cy_fct1_begbal := 0;
          v_cy_fct1_endbal := 0;
          -- If the balance type is Net Increase or Net Decrease
          -- and the natural balance is blank in the set up form
          -- then abort process and return error.
          IF ( detail_rec.balance_type IN ('I','J') AND v_natural_balance_type IS NULL ) THEN
            l_log_mesg                 := 'Line Number: '||v_line_number||' has an account
with balance type Net Increase or Net Decrease but
has a blank Natural Balance in the Report Definitions form.
Please select Natural Balance for any line with a Balance Type
of Net Increase or Net Decrease.';
            fnd_file.put_line(fnd_file.log, l_log_mesg);
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, l_log_mesg);
            v_retcode := -1 ;
            v_errbuf  := l_log_mesg;
            ROLLBACK;
            RETURN;
          END IF;
          --=======   PRIOR YEAR CALCULATION ===========
          -- Get facts1 beginning balance for prior year
          IF detail_rec.balance_type IN ('B','G','I','J') THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Prior year begin bal: '||v_py_gl_beg_bal);
            IF detail_rec.balance_type = 'B' THEN
              v_amount                := v_py_gl_beg_bal;
            END IF;
          END IF;
          -- Get facts1 ending balance for prior year
          IF detail_rec.balance_type IN ('C', 'D', 'E', 'G', 'I', 'J') THEN
            dbms_sql.bind_variable(v_fct1_sel_curid,':cv_line_id',v_line_id);
            dbms_sql.bind_variable(v_fct1_sel_curid,':cv_line_detail_id',detail_rec.line_detail_id);
            dbms_sql.bind_variable(v_fct1_sel_curid,':cv_period_fiscal_year',v_period_fiscal_year-1);
            dbms_sql.bind_variable(v_fct1_sel_curid,':cv_balance_type','');
            dbms_sql.bind_variable(v_fct1_sel_curid,':cv_period_num',v_end_period);
            l_ignore := dbms_sql.execute_and_fetch(v_fct1_sel_curid);
            dbms_sql.column_value(v_fct1_sel_curid, 1, v_py_fct1_endbal);
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Prior year end facts1 bal: '||v_py_fct1_endbal);
            v_amount := get_bal_type_amt(detail_rec.balance_type, v_natural_balance_type, NVL(v_py_gl_beg_bal,0), NVL(v_py_fct1_endbal,0));
          END IF;
          -- Set prior year amounts for reporting
          -- Bug 9479298
          IF v_report_type = 'SCNP' THEN
            IF detail_rec.cum_res     = 'Y'  THEN
              v_col_5_amt            := v_col_5_amt + NVL(v_amount, 0);
            ELSIF detail_rec.cum_res IS NULL AND detail_rec.budget_col IS NULL THEN
              v_col_2_amt            := v_col_2_amt + NVL(v_amount, 0);
            END IF;
            IF detail_rec.unexp_approp = 'Y' THEN
              v_col_6_amt             := v_col_6_amt + NVL(v_amount, 0);
            END IF;
            IF detail_rec.scnp_elim = 'Y' THEN
              v_col_7_amt             := v_col_7_amt + NVL(v_amount, 0);
            END IF;
          ELSE
            IF detail_rec.cum_res     = 'Y' OR detail_rec.budget_col = 'Y' THEN
            v_col_3_amt            := v_col_3_amt + NVL(v_amount, 0);
            ELSIF detail_rec.cum_res IS NULL AND detail_rec.budget_col IS NULL THEN
              v_col_2_amt            := v_col_2_amt + NVL(v_amount, 0);
            END IF;
            IF detail_rec.unexp_approp = 'Y' OR detail_rec.nbfa_col = 'Y' THEN
              v_col_4_amt             := v_col_4_amt + NVL(v_amount, 0);
            END IF;

          END IF;
          --=======   CURRENT YEAR CALCULATION ===========
          -- Get facts1 beginning balance for current year
          v_amount                   := 0;
          IF detail_rec.balance_type IN ('B','G','I','J') THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Current year begin bal: '||v_cy_gl_beg_bal);
            IF detail_rec.balance_type = 'B' THEN
              v_amount                := v_cy_gl_beg_bal;
            END IF;
          END IF;
          -- Get facts1 ending balance for current year
          IF detail_rec.balance_type IN ('C', 'D', 'E', 'G', 'I', 'J') THEN
            dbms_sql.bind_variable(v_fct1_sel_curid,':cv_line_id',v_line_id);
            dbms_sql.bind_variable(v_fct1_sel_curid,':cv_line_detail_id',detail_rec.line_detail_id);
            dbms_sql.bind_variable(v_fct1_sel_curid,':cv_period_fiscal_year',v_period_fiscal_year);
            dbms_sql.bind_variable(v_fct1_sel_curid,':cv_balance_type','');
            dbms_sql.bind_variable(v_fct1_sel_curid,':cv_period_num',v_end_period);
            l_ignore := dbms_sql.execute_and_fetch(v_fct1_sel_curid);
            dbms_sql.column_value(v_fct1_sel_curid, 1, v_cy_fct1_endbal);
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Current year end facsts1 bal: '||v_cy_fct1_endbal);
            v_amount := get_bal_type_amt(detail_rec.balance_type, v_natural_balance_type, NVL(v_cy_gl_beg_bal,0), NVL(v_cy_fct1_endbal,0));
          END IF;
          -- Set current year amounts for reporting
          IF detail_rec.cum_res = 'Y' OR detail_rec.budget_col = 'Y' OR (detail_rec.cum_res IS NULL AND detail_rec.budget_col IS NULL) THEN
            v_col_1_amt        := v_col_1_amt + NVL(v_amount, 0);
          END IF;
          IF detail_rec.unexp_approp = 'Y' OR detail_rec.nbfa_col = 'Y' THEN
            v_col_2_amt             := v_col_2_amt + NVL(v_amount, 0);
          END IF;

           -- Bug 9479298
           IF v_report_type = 'SCNP' THEN
            IF detail_rec.scnp_elim = 'Y'  THEN
              v_col_3_amt             := v_col_3_amt + NVL(v_amount, 0);
            END IF;
          END IF;

          l_log_mesg := ' Accounting Flexfield -2' || l_conc_segs || '     ' || NVL(v_amount, 0);
        END IF; --- 3
        IF ((v_report_type  = 'sbr' ) OR l_account_type IN ('D','C')) THEN
          v_cy_sbr_beg_bal := 0;
          v_cy_sbr_end_bal := 0;
          v_py_sbr_beg_bal := 0;
          v_py_sbr_end_bal := 0;
          dbms_sql.bind_variable(v_sbr_curid,':cv_line_id',v_line_id);
          dbms_sql.bind_variable(v_sbr_curid,':cv_line_detail_id',detail_rec.line_detail_id);
          -- Get Current Year balances --
          -------------------------------
          IF detail_rec.balance_type = 'B' THEN
            -- IF balance type is begin
            dbms_sql.bind_variable(v_sbr_curid,':cv_balance_type','B');
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_num',v_begin_period);
            dbms_sql.bind_variable(v_sbr_curid,':cv_end_date', v_begin_period_end_date);
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_fiscal_year',v_period_fiscal_year);
            l_ignore := dbms_sql.execute_and_fetch(v_sbr_curid);
            dbms_sql.column_value(v_sbr_curid, 1, v_cy_sbr_beg_bal);
            v_amount := v_cy_sbr_beg_bal;
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Current year begin bal: '||v_cy_sbr_beg_bal);
          ELSIF detail_rec.balance_type IN ('C','D','E','G','I','J') THEN
            -- IF balance type is ending, ending cr only or ending dr only
            -- Get the begin balance
            dbms_sql.bind_variable(v_sbr_curid,':cv_balance_type','B');
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_num',v_begin_period);
            dbms_sql.bind_variable(v_sbr_curid,':cv_end_date', v_begin_period_end_date);
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_fiscal_year',v_period_fiscal_year);
            l_ignore := dbms_sql.execute_and_fetch(v_sbr_curid);
            dbms_sql.column_value(v_sbr_curid, 1, v_cy_sbr_beg_bal);
            -- Get the end balance
            dbms_sql.bind_variable(v_sbr_curid,':cv_balance_type','E');
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_num',v_end_period);
            dbms_sql.bind_variable(v_sbr_curid,':cv_end_date', v_end_period_end_date);
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_fiscal_year',v_period_fiscal_year);
            l_ignore := dbms_sql.execute_and_fetch(v_sbr_curid);
            dbms_sql.column_value(v_sbr_curid, 1, v_cy_sbr_end_bal);
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Current year end bal: '||v_cy_sbr_end_bal);
            v_amount := get_bal_type_amt(detail_rec.balance_type, v_natural_balance_type, NVL(v_cy_sbr_beg_bal,0), NVL(v_cy_sbr_end_bal,0));
          END IF;
          -- Set current year amounts for reporting
          IF detail_rec.cum_res = 'Y' OR detail_rec.budget_col = 'Y' OR (detail_rec.cum_res IS NULL AND detail_rec.budget_col IS NULL) THEN
            v_col_1_amt        := v_col_1_amt + NVL(v_amount, 0);
          END IF;
          IF detail_rec.unexp_approp = 'Y' OR detail_rec.nbfa_col = 'Y' THEN
            v_col_2_amt             := v_col_2_amt + NVL(v_amount, 0);
          END IF;

           --Bug 9479298
          IF v_report_type = 'SCNP' THEN
            IF detail_rec.scnp_elim = 'Y'  THEN
              v_col_3_amt             := v_col_3_amt + NVL(v_amount, 0);
            END IF;
          END IF;
          ---- Get Prior year balances ----
          ---------------------------------
          IF detail_rec.balance_type = 'B' THEN
            -- If balance type is begin
            dbms_sql.bind_variable(v_sbr_curid,':cv_balance_type','B');
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_num',v_begin_period_1);
            dbms_sql.bind_variable(v_sbr_curid,':cv_end_date', v_begin_period_1_end_date);
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_fiscal_year',v_period_fiscal_year-1);
            l_ignore := dbms_sql.execute_and_fetch(v_sbr_curid);
            dbms_sql.column_value(v_sbr_curid, 1, v_py_sbr_beg_bal);
            v_amount := v_py_sbr_beg_bal;
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Prior year begin bal: '||v_py_sbr_beg_bal);
            -- IF balance type is ending, ending cr only or ending dr only
          ELSIF detail_rec.balance_type IN ('C', 'D','E','G','I','J') THEN
            -- Get the begin balance
            dbms_sql.bind_variable(v_sbr_curid,':cv_balance_type','B');
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_num',v_begin_period_1);
            dbms_sql.bind_variable(v_sbr_curid,':cv_end_date', v_begin_period_1_end_date);
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_fiscal_year',v_period_fiscal_year-1);
            l_ignore := dbms_sql.execute_and_fetch(v_sbr_curid);
            dbms_sql.column_value(v_sbr_curid, 1, v_py_sbr_beg_bal);
            -- Get the end balance
            dbms_sql.bind_variable(v_sbr_curid,':cv_balance_type','E');
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_num',v_period_num);
            dbms_sql.bind_variable(v_sbr_curid,':cv_end_date', v_end_period_1_end_date);
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_fiscal_year',v_period_fiscal_year-1);
            l_ignore := dbms_sql.execute_and_fetch(v_sbr_curid);
            dbms_sql.column_value(v_sbr_curid, 1, v_py_sbr_end_bal);
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Prior year end bal: '||v_py_sbr_end_bal);
            v_amount := get_bal_type_amt(detail_rec.balance_type, v_natural_balance_type, NVL(v_py_sbr_beg_bal,0), NVL(v_py_sbr_end_bal,0));
          END IF;
          l_log_mesg               := ', ' || NVL(v_amount, 0);


          --Bug 9479298
          IF v_report_type = 'SCNP' THEN
            IF detail_rec.cum_res     = 'Y' OR detail_rec.budget_col = 'Y' THEN
              v_col_5_amt            := v_col_5_amt + NVL(v_amount, 0);
            ELSIF detail_rec.cum_res IS NULL AND detail_rec.budget_col IS NULL THEN
              v_col_2_amt            := v_col_2_amt + NVL(v_amount, 0);
            END IF;
            IF detail_rec.unexp_approp = 'Y' OR detail_rec.nbfa_col = 'Y' THEN
              v_col_6_amt             := v_col_6_amt + NVL(v_amount, 0);
            END IF;
            IF detail_rec.scnp_elim = 'Y'  THEN
              v_col_7_amt             := v_col_7_amt + NVL(v_amount, 0);
            END IF;
          ELSE
            IF detail_rec.cum_res     = 'Y' OR detail_rec.budget_col = 'Y' THEN
              v_col_3_amt            := v_col_3_amt + NVL(v_amount, 0);
            ELSIF detail_rec.cum_res IS NULL AND detail_rec.budget_col IS NULL THEN
              v_col_2_amt            := v_col_2_amt + NVL(v_amount, 0);
            END IF;
            IF detail_rec.unexp_approp = 'Y' OR detail_rec.nbfa_col = 'Y' THEN
              v_col_4_amt             := v_col_4_amt + NVL(v_amount, 0);
            END IF;

          END IF;
        END IF; --- 10
      END IF;   --- 2
    END IF;     --- 1
  END LOOP;     --- L1
  IF v_by_recipient = 'Y' THEN
    v_col_1_amt    := NULL;
    v_col_2_amt    := NULL;
    populate_temp_table;
    l_temp_str := SUBSTR(v_line_label,1,LENGTH(v_line_label) - LENGTH(ltrim(v_line_label))) || '     ';
    FOR i                                                   IN 1..l_recipient_cnt - 1
    LOOP
      v_line_label := l_temp_str || l_recipient_rec(i).recipient_name;
      v_col_1_amt  := l_recipient_rec(i).col_1_amt;
      v_col_2_amt  := l_recipient_rec(i).col_2_amt;
      populate_temp_table;
    END LOOP;
  ELSE
     SELECT REPLACE(l_log_mesg, '*****', v_col_1_amt
      || ', '
      || v_col_2_amt
      || ', '
      || v_col_3_amt
      || ', '
      || v_col_4_amt
      || ', '
      || v_col_5_amt
      || ', '
      || v_col_6_amt)
       INTO l_log_mesg
       FROM dual;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,L_LOG_MESG);
    END IF;
    populate_temp_table;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_retcode := SQLCODE ;
  v_errbuf  := SQLERRM || ' [PROCESS_DETAIL_LINE] ' ;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_errbuf);
  RETURN;
END process_detail_line;

-- =============================================================
PROCEDURE process_total_line
                              IS
  l_module_name VARCHAR2(200) := g_module_name || 'process_total_line';
  CURSOR fv_cfs_calc_cur
  IS
     SELECT calc_sequence_number,
      line_low                  ,
      line_high                 ,
      line_low_type             ,
      line_high_type            ,
      operator                  ,
      cum_res                   ,
      unexp_approp              ,
      budget_col                ,
      nbfa_col                  ,
      scnp_elim
       FROM fv_cfs_rep_line_calc
      WHERE line_id = v_line_id
   ORDER BY calc_sequence_number;
  CURSOR fv_cfs_temp_cur (p_line_id NUMBER)
  IS
     SELECT col_1_amt,
      col_2_amt      ,
      col_3_amt      ,
      col_4_amt      ,
      col_5_amt      ,
      col_6_amt      ,
      col_7_amt      ,
      col_8_amt
       FROM fv_cfs_rep_temp
      WHERE line_id = p_line_id
    AND sequence_id = v_sequence_id;
  CURSOR fv_cfs_lines_cur(p_lineid_1 NUMBER, p_lineid_2 NUMBER)
  IS
     SELECT line_id
       FROM fv_cfs_rep_lines
      WHERE sequence_number >=
      (SELECT sequence_number FROM fv_cfs_rep_lines WHERE line_id = p_lineid_1
      )
  AND sequence_number <=
    (SELECT sequence_number FROM fv_cfs_rep_lines WHERE line_id = p_lineid_2
    )
  AND report_type = v_report_type;

  l_line_id fv_cfs_rep_lines.line_id%TYPE;
  temp_amt_low1 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_low2 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_low3 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_low4 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_low5 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_low6 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_low7 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_low8 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_high1 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_high2 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_high3 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_high4 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_high5 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_high6 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_high7 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_high8 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
TYPE amt_rec
IS
  RECORD
  (
    calc_sequence fv_cfs_rep_line_calc.calc_sequence_number%TYPE,
    col_1_amt fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0,
    col_2_amt fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0,
    col_3_amt fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0,
    col_4_amt fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0,
    col_5_amt fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0,
    col_6_amt fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0,
    col_7_amt fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0,
    col_8_amt fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0,
    cum_res fv_cfs_rep_line_calc.cum_res%TYPE ,
    unexp_approp fv_cfs_rep_line_calc.unexp_approp%TYPE ,
    budget_col fv_cfs_rep_line_calc.budget_col%TYPE ,
    nbfa_col fv_cfs_rep_line_calc.nbfa_col%TYPE ,
    scnp_elim fv_cfs_rep_line_calc.scnp_elim%TYPE);
TYPE amt_table
IS
  TABLE OF amt_rec INDEX BY BINARY_INTEGER;
  amt_array amt_table;
  amt_array_cnt BINARY_INTEGER DEFAULT 1;
BEGIN
  FOR calc_rec IN fv_cfs_calc_cur
  LOOP
    amt_array(amt_array_cnt).calc_sequence := calc_rec.calc_sequence_number;
    amt_array(amt_array_cnt).cum_res       := calc_rec.cum_res;
    amt_array(amt_array_cnt).unexp_approp  := calc_rec.unexp_approp;
    amt_array(amt_array_cnt).budget_col    := calc_rec.budget_col;
    amt_array(amt_array_cnt).nbfa_col      := calc_rec.nbfa_col;
    amt_array(amt_array_cnt).scnp_elim     := calc_rec.scnp_elim;
    IF calc_rec.line_low_type               = 'L' AND calc_rec.operator IN ('+','-') THEN
      l_line_id                            := calc_rec.line_low;
      OPEN fv_cfs_temp_cur(l_line_id);
      FETCH fv_cfs_temp_cur
         INTO temp_amt_low1,
        temp_amt_low2      ,
        temp_amt_low3      ,
        temp_amt_low4      ,
        temp_amt_low5      ,
        temp_amt_low6      ,
        temp_amt_low7      ,
        temp_amt_low8;

      CLOSE fv_cfs_temp_cur;
    ELSIF calc_rec.line_low_type = 'C' AND calc_rec.operator IN ('+','-') THEN
      FOR i                                                  IN 1..amt_array_cnt
      LOOP
        IF amt_array(i).calc_sequence = calc_rec.line_low THEN
          temp_amt_low1              := amt_array(i).col_1_amt;
          temp_amt_low1              := temp_amt_low1*v_units;
          temp_amt_low2              := amt_array(i).col_2_amt;
          temp_amt_low3              := amt_array(i).col_3_amt;
          temp_amt_low4              := amt_array(i).col_4_amt;
          temp_amt_low5              := amt_array(i).col_5_amt;
          temp_amt_low6              := amt_array(i).col_6_amt;
          temp_amt_low7              := amt_array(i).col_7_amt;
          temp_amt_low8              := amt_array(i).col_8_amt;
        END IF;
      END LOOP;
    END IF;
    IF calc_rec.line_high_type = 'L' AND calc_rec.operator IN ('+','-') THEN
      l_line_id               := calc_rec.line_high;
      OPEN fv_cfs_temp_cur(l_line_id);
      FETCH fv_cfs_temp_cur
         INTO temp_amt_high1,
        temp_amt_high2      ,
        temp_amt_high3      ,
        temp_amt_high4      ,
        temp_amt_high5      ,
        temp_amt_high6      ,
        temp_amt_high7      ,
        temp_amt_high8;

      CLOSE fv_cfs_temp_cur;
    ELSIF calc_rec.line_high_type = 'C' AND calc_rec.operator IN ('+','-') THEN
      FOR i                                                   IN 1..amt_array_cnt - 1
      LOOP
        IF amt_array(i).calc_sequence = calc_rec.line_high THEN
          temp_amt_high1             := amt_array(i).col_1_amt;
          temp_amt_high2             := amt_array(i).col_2_amt;
          temp_amt_high3             := amt_array(i).col_3_amt;
          temp_amt_high4             := amt_array(i).col_4_amt;
          temp_amt_high5             := amt_array(i).col_5_amt;
          temp_amt_high6             := amt_array(i).col_6_amt;
          temp_amt_high7             := amt_array(i).col_7_amt;
          temp_amt_high8             := amt_array(i).col_8_amt;
        END IF;
      END LOOP;
    END IF;
    IF calc_rec.operator                  = '+' THEN
      amt_array(amt_array_cnt).col_1_amt := NVL(temp_amt_low1, 0) + NVL(temp_amt_high1, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_1_amt);
      amt_array(amt_array_cnt).col_2_amt := NVL(temp_amt_low2, 0) + NVL(temp_amt_high2, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_2_amt);
      amt_array(amt_array_cnt).col_3_amt := NVL(temp_amt_low3, 0) + NVL(temp_amt_high3, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_3_amt);
      amt_array(amt_array_cnt).col_4_amt := NVL(temp_amt_low4, 0) + NVL(temp_amt_high4, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_4_amt);
      amt_array(amt_array_cnt).col_5_amt := NVL(temp_amt_low5, 0) + NVL(temp_amt_high5, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_5_amt);
      amt_array(amt_array_cnt).col_6_amt := NVL(temp_amt_low6, 0) + NVL(temp_amt_high6, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_6_amt);
      amt_array(amt_array_cnt).col_7_amt := NVL(temp_amt_low7, 0) + NVL(temp_amt_high7, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_7_amt);
      amt_array(amt_array_cnt).col_8_amt := NVL(temp_amt_low8, 0) + NVL(temp_amt_high8, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_8_amt);

    ELSIF calc_rec.operator               = '-' THEN
     amt_array(amt_array_cnt).col_1_amt := NVL(temp_amt_low1, 0) - NVL(temp_amt_high1, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_1_amt);
      amt_array(amt_array_cnt).col_2_amt := NVL(temp_amt_low2, 0) - NVL(temp_amt_high2, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_2_amt);
      amt_array(amt_array_cnt).col_3_amt := NVL(temp_amt_low3, 0) - NVL(temp_amt_high3, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_3_amt);
      amt_array(amt_array_cnt).col_4_amt := NVL(temp_amt_low4, 0) - NVL(temp_amt_high4, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_4_amt);
      amt_array(amt_array_cnt).col_5_amt := NVL(temp_amt_low5, 0) - NVL(temp_amt_high5, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_5_amt);
      amt_array(amt_array_cnt).col_6_amt := NVL(temp_amt_low6, 0) - NVL(temp_amt_high6, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_6_amt);
      amt_array(amt_array_cnt).col_7_amt := NVL(temp_amt_low7, 0) - NVL(temp_amt_high7, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_7_amt);
      amt_array(amt_array_cnt).col_8_amt := NVL(temp_amt_low8, 0) - NVL(temp_amt_high8, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod'||'Begin '|| amt_array(amt_array_cnt).col_8_amt);

    ELSE
      IF calc_rec.line_low_type = 'L' THEN
        FOR lines_rec          IN fv_cfs_lines_cur(calc_rec.line_low, calc_rec.line_high)
        LOOP
          FOR fv_cfs_temp_cur_rec IN fv_cfs_temp_cur(lines_rec.line_id)
          LOOP
            amt_array(amt_array_cnt).col_1_amt := amt_array(amt_array_cnt).col_1_amt + NVL(fv_cfs_temp_cur_rec.col_1_amt, 0);
            amt_array(amt_array_cnt).col_2_amt := amt_array(amt_array_cnt).col_2_amt + NVL(fv_cfs_temp_cur_rec.col_2_amt, 0);
            amt_array(amt_array_cnt).col_3_amt := amt_array(amt_array_cnt).col_3_amt + NVL(fv_cfs_temp_cur_rec.col_3_amt, 0);
            amt_array(amt_array_cnt).col_4_amt := amt_array(amt_array_cnt).col_4_amt + NVL(fv_cfs_temp_cur_rec.col_4_amt, 0);
            amt_array(amt_array_cnt).col_5_amt := amt_array(amt_array_cnt).col_5_amt + NVL(fv_cfs_temp_cur_rec.col_5_amt, 0);
            amt_array(amt_array_cnt).col_6_amt := amt_array(amt_array_cnt).col_6_amt + NVL(fv_cfs_temp_cur_rec.col_6_amt, 0);
            amt_array(amt_array_cnt).col_7_amt := amt_array(amt_array_cnt).col_7_amt + NVL(fv_cfs_temp_cur_rec.col_7_amt, 0);
            amt_array(amt_array_cnt).col_8_amt := amt_array(amt_array_cnt).col_8_amt + NVL(fv_cfs_temp_cur_rec.col_8_amt, 0);
          END LOOP;
        END LOOP;
      ELSIF calc_rec.line_low_type = 'C' THEN
        FOR i   IN 1..amt_array_cnt - 1
        LOOP
          IF amt_array(i).calc_sequence        >= calc_rec.line_low AND amt_array(i).calc_sequence <= calc_rec.line_high THEN
            amt_array(amt_array_cnt).col_1_amt := amt_array(amt_array_cnt).col_1_amt + NVL(amt_array(i).col_1_amt, 0);
            amt_array(amt_array_cnt).col_2_amt := amt_array(amt_array_cnt).col_2_amt + NVL(amt_array(i).col_2_amt, 0);
            amt_array(amt_array_cnt).col_3_amt := amt_array(amt_array_cnt).col_3_amt + NVL(amt_array(i).col_3_amt, 0);
            amt_array(amt_array_cnt).col_4_amt := amt_array(amt_array_cnt).col_4_amt + NVL(amt_array(i).col_4_amt, 0);
            amt_array(amt_array_cnt).col_5_amt := amt_array(amt_array_cnt).col_5_amt + NVL(amt_array(i).col_5_amt, 0);
            amt_array(amt_array_cnt).col_6_amt := amt_array(amt_array_cnt).col_6_amt + NVL(amt_array(i).col_6_amt, 0);
            amt_array(amt_array_cnt).col_7_amt := amt_array(amt_array_cnt).col_7_amt + NVL(amt_array(i).col_7_amt, 0);
            amt_array(amt_array_cnt).col_8_amt := amt_array(amt_array_cnt).col_8_amt + NVL(amt_array(i).col_8_amt, 0);
          END IF;
        END LOOP;
      END IF;
    END IF;
   IF v_report_type = 'SCNP' THEN
        IF calc_rec.cum_res                   = 'N' THEN
          amt_array(amt_array_cnt).col_1_amt := 0;
          amt_array(amt_array_cnt).col_5_amt := 0;
        END IF;
        IF calc_rec.unexp_approp              = 'N' THEN
          amt_array(amt_array_cnt).col_2_amt := 0;
          amt_array(amt_array_cnt).col_6_amt := 0;
       END IF;
       IF calc_rec.scnp_elim              = 'N' OR calc_rec.scnp_elim IS NULL THEN
          amt_array(amt_array_cnt).col_3_amt := 0;
          amt_array(amt_array_cnt).col_7_amt := 0;
       END IF;
    ELSE
      IF calc_rec.cum_res                   = 'N' OR calc_rec.budget_col = 'N' THEN
        amt_array(amt_array_cnt).col_1_amt := 0;
        amt_array(amt_array_cnt).col_3_amt := 0;
      END IF;
      IF calc_rec.unexp_approp              = 'N' OR calc_rec.nbfa_col = 'N' THEN
        amt_array(amt_array_cnt).col_2_amt := 0;
        amt_array(amt_array_cnt).col_4_amt := 0;
      END IF;
    END IF;

    amt_array_cnt := amt_array_cnt + 1;
  END LOOP;

  -- As SBR report does not use this procedure, removed SBR from the if clause
  IF v_report_type ='SCNP' THEN
    FOR i          IN 1..amt_array_cnt - 1
    LOOP
       IF amt_array(i).cum_res = 'Y'  THEN
          v_col_1_amt := amt_array(i).col_1_amt;
          v_col_5_amt := amt_array(i).col_5_amt;
        END IF;
        IF amt_array(i).unexp_approp = 'Y'   THEN
          v_col_2_amt := amt_array(i).col_2_amt;
          v_col_6_amt := amt_array(i).col_6_amt;
       END IF;
       IF amt_array(i).scnp_elim  = 'Y'  THEN
          v_col_3_amt := amt_array(i).col_3_amt;
          v_col_7_amt := amt_array(i).col_7_amt;
       END IF;

          v_col_4_amt := nvl(v_col_1_amt,0) + nvl(v_col_2_amt,0) - nvl(v_col_3_amt,0);
          v_col_8_amt := nvl(v_col_5_amt,0) + nvl(v_col_6_amt,0) - nvl(v_col_7_amt,0);
    END LOOP;
  ELSE
    v_col_1_amt := amt_array(amt_array_cnt - 1).col_1_amt;
    v_col_2_amt := amt_array(amt_array_cnt - 1).col_2_amt;
    v_col_3_amt := amt_array(amt_array_cnt - 1).col_3_amt;
    v_col_4_amt := amt_array(amt_array_cnt - 1).col_4_amt;
    v_col_5_amt := amt_array(amt_array_cnt - 1).col_5_amt;
    v_col_6_amt := amt_array(amt_array_cnt - 1).col_6_amt;
    v_col_7_amt := amt_array(amt_array_cnt - 1).col_7_amt;
    v_col_8_amt := amt_array(amt_array_cnt - 1).col_8_amt;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_retcode := SQLCODE ;
  v_errbuf  := SQLERRM || ' [PROCESS_TOTAL_LINE] ' ;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_errbuf);
  RETURN;
END process_total_line;
/* SBR developement*/
/*Processing the SBR line totals*/
PROCEDURE process_sbr_total_line
                              IS
  l_module_name VARCHAR2(200) := g_module_name || 'process_sbr_total_line';
  CURSOR fv_sbr_calc_cur
  IS
     SELECT calc_sequence_number,
      line_low                  ,
      line_high                 ,
      line_low_type             ,
      line_high_type            ,
      operator
       FROM fv_sbr_rep_line_calc
      WHERE line_id = c_sbr_line_id
   ORDER BY calc_sequence_number;
  CURSOR fv_cfs_temp_cur (p_line_id NUMBER)
  IS
     SELECT col_1_amt,
      col_2_amt      ,
      col_3_amt      ,
      col_4_amt
       FROM fv_cfs_rep_temp
      WHERE line_id = p_line_id
    AND sequence_id = v_sequence_id;
  -- Bug 9191098
  CURSOR fv_sbr_lines_cur(p_lineid_1 NUMBER, p_lineid_2 NUMBER)
  IS
     SELECT sbr_line_id
       FROM fv_sbr_definitions_lines
      WHERE sbr_line_number >=
      (SELECT sbr_line_number
         FROM fv_sbr_definitions_lines
        WHERE sbr_line_id = p_lineid_1
      )
  AND sbr_line_number <=
    (SELECT sbr_line_number
       FROM fv_sbr_definitions_lines
      WHERE sbr_line_id = p_lineid_2
    );

  l_line_id fv_sbr_definitions_lines.sbr_line_id%TYPE;
  temp_amt_low1 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_low2 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_low3 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_low4 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_high1 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_high2 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_high3 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
  temp_amt_high4 fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0;
TYPE amt_rec
IS
  RECORD
  (
    calc_sequence fv_cfs_rep_line_calc.calc_sequence_number%TYPE,
    col_1_amt fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0,
    col_2_amt fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0,
    col_3_amt fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0,
    col_4_amt fv_cfs_rep_temp.col_1_amt%TYPE DEFAULT 0,
    cum_res fv_cfs_rep_line_calc.cum_res%TYPE ,
    unexp_approp fv_cfs_rep_line_calc.unexp_approp%TYPE ,
    budget_col fv_cfs_rep_line_calc.budget_col%TYPE ,
    nbfa_col fv_cfs_rep_line_calc.nbfa_col%TYPE );
TYPE amt_table
IS
  TABLE OF amt_rec INDEX BY BINARY_INTEGER;
  amt_array amt_table;
  amt_array_cnt BINARY_INTEGER DEFAULT 1;
  --v_col_1_amt fv_sbr_definitions_cols_temp.sf133_column_amount%TYPE;
BEGIN
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,'Inside process_sbr_total_line');
  FOR calc_rec IN fv_sbr_calc_cur
  LOOP
    amt_array(amt_array_cnt).calc_sequence := calc_rec.calc_sequence_number;
    IF calc_rec.line_low_type               = 'L' AND calc_rec.operator IN ('+','-') THEN
      l_line_id                            := calc_rec.line_low;
      OPEN fv_cfs_temp_cur(l_line_id);
      FETCH fv_cfs_temp_cur
         INTO temp_amt_low1,
        temp_amt_low2      ,
        temp_amt_low3      ,
        temp_amt_low4;

      CLOSE fv_cfs_temp_cur;
    ELSIF calc_rec.line_low_type = 'C' AND calc_rec.operator IN ('+','-') THEN
      FOR i                                                  IN 1..amt_array_cnt
      LOOP
        IF amt_array(i).calc_sequence = calc_rec.line_low THEN
          temp_amt_low1              := amt_array(i).col_1_amt;
          temp_amt_low1              := temp_amt_low1*v_units;
          temp_amt_low2              := amt_array(i).col_2_amt;
          temp_amt_low3              := amt_array(i).col_3_amt;
          temp_amt_low4              := amt_array(i).col_4_amt;
        END IF;
      END LOOP;
    END IF;
    IF calc_rec.line_high_type = 'L' AND calc_rec.operator IN ('+','-') THEN
      l_line_id               := calc_rec.line_high;
      OPEN fv_cfs_temp_cur(l_line_id);
      FETCH fv_cfs_temp_cur
         INTO temp_amt_high1,
        temp_amt_high2      ,
        temp_amt_high3      ,
        temp_amt_high4;

      CLOSE fv_cfs_temp_cur;
    ELSIF calc_rec.line_high_type = 'C' AND calc_rec.operator IN ('+','-') THEN
      FOR i                                                   IN 1..amt_array_cnt - 1
      LOOP
        IF amt_array(i).calc_sequence = calc_rec.line_high THEN
          temp_amt_high1             := amt_array(i).col_1_amt;
          temp_amt_high2             := amt_array(i).col_2_amt;
          temp_amt_high3             := amt_array(i).col_3_amt;
          temp_amt_high4             := amt_array(i).col_4_amt;
        END IF;
      END LOOP;
    END IF;
    IF calc_rec.operator                  = '+' THEN
      amt_array(amt_array_cnt).col_1_amt := NVL(temp_amt_low1, 0) + NVL(temp_amt_high1, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod col_1_amt '||'Begin '|| amt_array(amt_array_cnt).col_1_amt);
      amt_array(amt_array_cnt).col_2_amt := NVL(temp_amt_low2, 0) + NVL(temp_amt_high2, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod col_2_amt '||'Begin '|| amt_array(amt_array_cnt).col_2_amt);
      amt_array(amt_array_cnt).col_3_amt := NVL(temp_amt_low3, 0) + NVL(temp_amt_high3, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod col_3_amt'||'Begin '|| amt_array(amt_array_cnt).col_3_amt);
      amt_array(amt_array_cnt).col_4_amt := NVL(temp_amt_low4, 0) + NVL(temp_amt_high4, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod col_4_amt'||'Begin '|| amt_array(amt_array_cnt).col_4_amt);
    ELSIF calc_rec.operator               = '-' THEN
      amt_array(amt_array_cnt).col_1_amt := NVL(temp_amt_low1, 0) - NVL(temp_amt_high1, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod col_1_amt'||'Begin '|| amt_array(amt_array_cnt).col_1_amt);
      amt_array(amt_array_cnt).col_2_amt := NVL(temp_amt_low2, 0) - NVL(temp_amt_high2, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod col_2_amt'||'Begin '|| amt_array(amt_array_cnt).col_2_amt);
      amt_array(amt_array_cnt).col_3_amt := NVL(temp_amt_low3, 0) - NVL(temp_amt_high3, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod col_3_amt'||'Begin '|| amt_array(amt_array_cnt).col_3_amt);
      amt_array(amt_array_cnt).col_4_amt := NVL(temp_amt_low4, 0) - NVL(temp_amt_high4, 0);
      fnd_file.put_line(fnd_file.log, 'TestMod col_4_amt'||'Begin '|| amt_array(amt_array_cnt).col_4_amt);
    ELSE
      IF calc_rec.line_low_type = 'L' THEN
        FOR lines_rec          IN fv_sbr_lines_cur(calc_rec.line_low, calc_rec.line_high)
        LOOP
          FOR fv_cfs_temp_cur_rec IN fv_cfs_temp_cur(lines_rec.sbr_line_id)
          LOOP
            amt_array(amt_array_cnt).col_1_amt := amt_array(amt_array_cnt).col_1_amt + NVL(fv_cfs_temp_cur_rec.col_1_amt, 0);
            amt_array(amt_array_cnt).col_2_amt := amt_array(amt_array_cnt).col_2_amt + NVL(fv_cfs_temp_cur_rec.col_2_amt, 0);
            amt_array(amt_array_cnt).col_3_amt := amt_array(amt_array_cnt).col_3_amt + NVL(fv_cfs_temp_cur_rec.col_3_amt, 0);
            amt_array(amt_array_cnt).col_4_amt := amt_array(amt_array_cnt).col_4_amt + NVL(fv_cfs_temp_cur_rec.col_4_amt, 0);
          END LOOP;
        END LOOP;
      ELSIF calc_rec.line_low_type = 'C' THEN
        FOR i                     IN 1..amt_array_cnt - 1
        LOOP
          IF amt_array(i).calc_sequence        >= calc_rec.line_low AND amt_array(i).calc_sequence <= calc_rec.line_high THEN
            amt_array(amt_array_cnt).col_1_amt := amt_array(amt_array_cnt).col_1_amt + NVL(amt_array(i).col_1_amt, 0);
            amt_array(amt_array_cnt).col_2_amt := amt_array(amt_array_cnt).col_2_amt + NVL(amt_array(i).col_2_amt, 0);
            amt_array(amt_array_cnt).col_3_amt := amt_array(amt_array_cnt).col_3_amt + NVL(amt_array(i).col_3_amt, 0);
            amt_array(amt_array_cnt).col_4_amt := amt_array(amt_array_cnt).col_4_amt + NVL(amt_array(i).col_4_amt, 0);
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
  fnd_file.put_line(fnd_file.log, 'Before populate tables -> '||'v_col_1_amt->  '|| v_col_1_amt);
  fnd_file.put_line(fnd_file.log, 'Before populate tables -> '||'v_col_2_amt->  '|| v_col_2_amt);
  fnd_file.put_line(fnd_file.log, 'Before populate tables -> '||'v_col_3_amt->  '|| v_col_3_amt);
  fnd_file.put_line(fnd_file.log, 'Before populate tables -> '||'v_col_4_amt->  '|| v_col_4_amt);
  populate_temp_table;
EXCEPTION
WHEN OTHERS THEN
  v_retcode := SQLCODE ;
  v_errbuf  := SQLERRM || ' [PROCESS_TOTAL_LINE] ' ;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_errbuf);
  RETURN;
END process_sbr_total_line;
/*SBR */
-- =============================================================
PROCEDURE populate_temp_table
                              IS
  l_module_name VARCHAR2(200) := g_module_name || 'populate_temp_table';
BEGIN
  -- Bug 4927632. If units are 'Dollars and Cents'
  -- then do not round off the amounts
  -- Bug 5491457. If the report type is SF and natural balance type is Net Increase or
  -- Net Decrease, then drop the sign from the amounts.

  IF (v_report_type = 'SF' AND v_balance_type IN ('I', 'J')) THEN
    IF gbl_units   <> 'Dollars and Cents' THEN
      IF istotal_cal=0 THEN
         INSERT
           INTO fv_cfs_rep_temp
          (
            sequence_id,
            line_id    ,
            line_label ,
            col_1_amt  ,
            col_2_amt  ,
            col_3_amt  ,
            col_4_amt,
	    PERIOD_YEAR,
	    PERIOD_NUM,
	    REPORTY_TYPE,
	    LEDGER_ID
          )
          VALUES
          (
            v_sequence_id                  ,
            v_line_id                      ,
            v_line_label                   ,
            ABS(ROUND(v_col_1_amt/v_units)),
            ABS(ROUND(v_col_2_amt/v_units)),
            ABS(ROUND(v_col_3_amt/v_units)),
            ABS(ROUND(v_col_4_amt/v_units)),
	    v_period_fiscal_year,
	    v_period_num ,
	    v_report_type,
	    v_sob
          );
      ELSE
         INSERT
           INTO fv_cfs_rep_temp
          (
            sequence_id,
            line_id    ,
            line_label ,
            col_1_amt  ,
            col_2_amt  ,
            col_3_amt  ,
            col_4_amt,
    	    PERIOD_YEAR,
	    PERIOD_NUM,
	    REPORTY_TYPE,
	    LEDGER_ID
          )
          VALUES
          (
            v_sequence_id          ,
            v_line_id              ,
            v_line_label           ,
            ABS(ROUND(v_col_1_amt)),
            ABS(ROUND(v_col_2_amt)),
            ABS(ROUND(v_col_3_amt)),
            ABS(ROUND(v_col_4_amt)),
	    v_period_fiscal_year,
	    v_period_num ,
	    v_report_type,
	    v_sob
          );
      END IF;
    ELSE
       INSERT
         INTO fv_cfs_rep_temp
        (
          sequence_id,
          line_id    ,
          line_label ,
          col_1_amt  ,
          col_2_amt  ,
          col_3_amt  ,
          col_4_amt,
	  PERIOD_YEAR,
	  PERIOD_NUM,
	  REPORTY_TYPE,
	  LEDGER_ID
        )
        VALUES
        (
          v_sequence_id   ,
          v_line_id       ,
          v_line_label    ,
          ABS(v_col_1_amt),
          ABS(v_col_2_amt),
          ABS(v_col_3_amt),
          ABS(v_col_4_amt),
	  v_period_fiscal_year,
	  v_period_num ,
	  v_report_type,
	  v_sob
        );
    END IF;
  ELSE
    IF gbl_units   <> 'Dollars and Cents' THEN
      IF istotal_cal=0 THEN
         INSERT
           INTO fv_cfs_rep_temp
          (
            sequence_id,
            line_id    ,
            line_label ,
            col_1_amt  ,
            col_2_amt  ,
            col_3_amt  ,
            col_4_amt  ,
            col_5_amt  ,
            col_6_amt  ,
            col_7_amt  ,
            col_8_amt,
	    PERIOD_YEAR,
	    PERIOD_NUM,
	    REPORTY_TYPE,
	    LEDGER_ID
          )
          VALUES
          (
            v_sequence_id                                                                                   ,
            v_line_id                                                                                       ,
            v_line_label                                                                                    ,
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_1_amt/v_units) * -1, ROUND(v_col_1_amt/v_units)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_2_amt/v_units) * -1, ROUND(v_col_2_amt/v_units)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_3_amt/v_units) * -1, ROUND(v_col_3_amt/v_units)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_4_amt/v_units) * -1, ROUND(v_col_4_amt/v_units)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_5_amt/v_units) * -1, ROUND(v_col_5_amt/v_units)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_6_amt/v_units) * -1, ROUND(v_col_6_amt/v_units)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_7_amt/v_units) * -1, ROUND(v_col_7_amt/v_units)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_8_amt/v_units) * -1, ROUND(v_col_8_amt/v_units)),
	    v_period_fiscal_year,
	    v_period_num ,
	    v_report_type,
	    v_sob
          );
      ELSE
         INSERT
           INTO fv_cfs_rep_temp
          (
            sequence_id,
            line_id    ,
            line_label ,
            col_1_amt  ,
            col_2_amt  ,
            col_3_amt  ,
            col_4_amt  ,
            col_5_amt  ,
            col_6_amt  ,
            col_7_amt  ,
            col_8_amt,
	    PERIOD_YEAR,
	    PERIOD_NUM,
	    REPORTY_TYPE,
	    LEDGER_ID
          )
          VALUES
          (
            v_sequence_id                                                                   ,
            v_line_id                                                                       ,
            v_line_label                                                                    ,
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_1_amt) * -1, ROUND(v_col_1_amt)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_2_amt) * -1, ROUND(v_col_2_amt)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_3_amt) * -1, ROUND(v_col_3_amt)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_4_amt) * -1, ROUND(v_col_4_amt)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_5_amt) * -1, ROUND(v_col_5_amt)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_6_amt) * -1, ROUND(v_col_6_amt)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_7_amt) * -1, ROUND(v_col_7_amt)),
            DECODE(v_natural_balance_type, 'C', ROUND(v_col_8_amt) * -1, ROUND(v_col_8_amt)),
	    v_period_fiscal_year,
	    v_period_num ,
	    v_report_type,
	    v_sob
          );
      END IF;
      fnd_file.put_line
      (
        fnd_file.log, 'TestMod'||'insert '|| ROUND(v_col_1_amt/v_units) ||' '|| ROUND(v_col_2_amt/v_units) ||' ' || ROUND(v_col_3_amt/v_units) ||' '|| ROUND(v_col_4_amt/v_units)
        ||' '||ROUND(v_col_5_amt/v_units) ||' '|| ROUND(v_col_6_amt/v_units) ||' ' || ROUND(v_col_7_amt/v_units) ||' '|| ROUND(v_col_8_amt/v_units)
      )
      ;
    ELSE
       INSERT
         INTO fv_cfs_rep_temp
        (
          sequence_id,
          line_id    ,
          line_label ,
          col_1_amt  ,
          col_2_amt  ,
          col_3_amt  ,
          col_4_amt  ,
          col_5_amt  ,
          col_6_amt  ,
          col_7_amt  ,
          col_8_amt,
	  PERIOD_YEAR,
	  PERIOD_NUM,
	  REPORTY_TYPE,
	  LEDGER_ID
        )
        VALUES
        (
          v_sequence_id                                                     ,
          v_line_id                                                         ,
          v_line_label                                                      ,
          DECODE(v_natural_balance_type, 'C', v_col_1_amt * -1, v_col_1_amt),
          DECODE(v_natural_balance_type, 'C', v_col_2_amt * -1, v_col_2_amt),
          DECODE(v_natural_balance_type, 'C', v_col_3_amt * -1, v_col_3_amt),
          DECODE(v_natural_balance_type, 'C', v_col_4_amt * -1, v_col_4_amt),
          DECODE(v_natural_balance_type, 'C', v_col_5_amt * -1, v_col_5_amt),
          DECODE(v_natural_balance_type, 'C', v_col_6_amt * -1, v_col_6_amt),
          DECODE(v_natural_balance_type, 'C', v_col_7_amt * -1, v_col_7_amt),
          DECODE(v_natural_balance_type, 'C', v_col_8_amt * -1, v_col_8_amt),
	  v_period_fiscal_year,
	  v_period_num ,
	  v_report_type,
	  v_sob
        );

      fnd_file.put_line
      (
        fnd_file.log, 'TestMod'||'insert '|| v_col_1_amt ||' '|| v_col_2_amt ||' ' || v_col_3_amt||' '|| v_col_4_amt
          || v_col_5_amt ||' '|| v_col_6_amt ||' ' || v_col_7_amt||' '|| v_col_8_amt
      )
      ;
    END IF;
  END IF;

  IF v_report_type = 'SCNP' THEN
    UPDATE fv_cfs_rep_temp SET col_4_amt = NVL(col_1_amt,0) + NVL(col_2_amt,0) -  NVL(col_3_amt,0),
      col_8_amt = NVL(col_5_amt,0) + NVL(col_6_amt,0) -  NVL(col_7_amt,0)
      WHERE sequence_id = v_sequence_id AND line_id = v_line_id;

      fnd_file.put_line
      (
        fnd_file.log, 'TestMod'||'UPDATE STATEMENT TO SET CONSOLIDATED TOTAL FOR SCNP '|| v_col_1_amt ||' '|| v_col_2_amt ||' ' || v_col_3_amt||' '|| v_col_4_amt
        || v_col_5_amt ||' '|| v_col_6_amt ||' ' || v_col_7_amt||' '|| v_col_8_amt
      );
  END IF;

EXCEPTION
WHEN OTHERS THEN
  v_retcode := -1;
  v_errbuf  := SQLERRM;
  FV_UTILITY.LOG_MESG
  (
    FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_errbuf
  )
  ;
  RAISE;
END populate_temp_table;
-- =============================================================
FUNCTION get_bal_type_amt
  (
    p_balance_type     VARCHAR,
    p_natural_bal_type VARCHAR,
    p_beg_bal          NUMBER,
    p_end_bal          NUMBER
  )
  RETURN NUMBER
IS
  l_module_name VARCHAR2
  (
    200
  )
  := g_module_name || 'get_bal_type_amt';
  l_end_minus_beg_amt NUMBER;
BEGIN
  fv_utility.debug_mesg
  (
    fnd_log.level_statement, l_module_name, 'IN get_bal_type_amt function'
  )
  ;
  fv_utility.debug_mesg
  (
    fnd_log.level_statement, l_module_name, 'Natural balance: '||p_natural_bal_type
  )
  ;
  fv_utility.debug_mesg
  (
    fnd_log.level_statement, l_module_name, 'p_beg_bal: '||p_beg_bal
  )
  ;
  fv_utility.debug_mesg
  (
    fnd_log.level_statement, l_module_name, 'p_end_bal: '||p_end_bal
  )
  ;
  IF p_balance_type = 'E' THEN
    RETURN p_end_bal;
  END IF;
  -- If balance type is Ending (Cr only) or
  -- Ending (DR only)
  IF p_balance_type = 'C' THEN
    IF p_end_bal   >= 0 THEN
      RETURN 0;
    ELSE
      RETURN p_end_bal;
    END IF;
  ELSIF p_balance_type = 'D' THEN
    IF p_end_bal      <= 0 THEN
      RETURN 0;
    ELSE
      RETURN p_end_bal;
    END IF;
  END IF;
  -- If balance type is End minus Begin, Net Increase or
  -- Net Decrease then report amount depending on the
  -- natural balance type
  l_end_minus_beg_amt := p_end_bal - p_beg_bal;
  fv_utility.debug_mesg
  (
    fnd_log.level_statement, l_module_name, 'end minus begin: '||l_end_minus_beg_amt
  )
  ;
  IF p_balance_type = 'G' THEN
    RETURN l_end_minus_beg_amt;
  END IF;
  IF p_balance_type           = 'I' THEN
    IF p_natural_bal_type     = 'C' THEN
      IF l_end_minus_beg_amt <= 0 THEN
        RETURN l_end_minus_beg_amt;
      ELSE
        RETURN 0;
      END IF;
    ELSIF p_natural_bal_type = 'D' THEN
      IF l_end_minus_beg_amt > 0 THEN
        RETURN l_end_minus_beg_amt;
      ELSE
        RETURN 0;
      END IF;
    END IF;
  ELSIF p_balance_type        = 'J' THEN
    IF p_natural_bal_type     = 'C' THEN
      IF l_end_minus_beg_amt >= 0 THEN
        RETURN l_end_minus_beg_amt;
      ELSE
        RETURN 0;
      END IF;
    ELSIF p_natural_bal_type = 'D' THEN
      IF l_end_minus_beg_amt < 0 THEN
        RETURN l_end_minus_beg_amt;
      ELSE
        RETURN 0;
      END IF;
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_retcode := -1;
  v_errbuf  := SQLERRM;
  FV_UTILITY.LOG_MESG
  (
    FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_errbuf
  )
  ;
END get_bal_type_amt;


PROCEDURE build_report_lines
  --
AS
  l_module_name VARCHAR2
  (
    200
  )
  ;
  l_line_cnt NUMBER;
  --
  -- ----------------------------------------
BEGIN
  l_module_name := g_module_name || 'build_report_lines';
  --
  IF
    (
      FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    )
    THEN
    FV_UTILITY.DEBUG_MESG
    (
      FND_LOG.LEVEL_STATEMENT, l_module_name,'START BUILD_REPORT_LINES'
    )
    ;
  END IF;
  --
  -- ----------------------------------------
  -- Find first period_number that is not an adjusting period
  -- ----------------------------------------
  --
  --
   SELECT MIN(period_num)
     INTO g_period_num
     FROM gl_period_statuses
    WHERE ledger_id          = v_sob
  AND period_year            = v_period_fiscal_year
  AND adjustment_period_flag = 'N'
  AND application_id         = '101' ;
  --  Added on 4/28/98 by Surya Padmanabhan
  --  Get the Period Number For the Quarter
   SELECT PERIOD_NUM
     INTO parm_gl_period_num
     FROM GL_PERIOD_STATUSES
    WHERE LEDGER_ID             = v_sob
  AND PERIOD_YEAR               = v_period_fiscal_year
  AND APPLICATION_ID            = '101'
  AND CLOSING_STATUS           IN ('O','C')
  AND PERIOD_NAME               = v_period_name;
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Min Period num->'||g_period_num);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Period Number for quarter->'||parm_gl_period_num);
  END IF;
  -- ----------------------------------------------------
  -- Get Next sbr Treasury Symbol Line from Cursor
  -- ----------------------------------------------------
  --
  g_ts_value_in_process := NULL;
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Before cursor.....sbr_report_line_cursor');
  END IF;
  /*INSERTING ALL LABELS TO Report table*/
   INSERT
     INTO fv_cfs_rep_temp
    (
      SEQUENCE_ID,
      LINE_ID    ,
      LINE_LABEL,
      PERIOD_YEAR ,
      PERIOD_NUM ,
      REPORTY_TYPE,
      LEDGER_ID
    )
  SELECT DISTINCT line.sbr_line_number sbr_line_number,
    line.sbr_line_id sbr_line_id                      ,
    line.sbr_line_label sbr_line_label,
    v_period_fiscal_year,
    v_period_num ,
    v_report_type,
    v_sob
     FROM fv_sbr_definitions_lines line
    WHERE line.set_of_books_id = v_sob
  AND line.sbr_line_type_code  IN ('L','F')
 ORDER BY line.sbr_line_number;

  FOR sbr_report_line_entry IN sbr_report_line_cursor
  LOOP
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'In cursor.....sbr_report_line_cursor');
    END IF;
    c_sbr_line_id                := sbr_report_line_entry.sbr_line_id;
    c_sbr_line_number            := sbr_report_line_entry.sbr_line_number;
    c_sbr_line_type_code         := sbr_report_line_entry.sbr_line_type_code;
    c_sbr_natural_bal_type       := sbr_report_line_entry.sbr_natural_balance_type;
    c_sbr_report_line_number     := sbr_report_line_entry.sbr_report_line_number;
    c_sbr_gl_balance		 := sbr_report_line_entry.sbr_gl_balance;
    v_line_id                    := c_sbr_line_id;
    v_line_label                 := sbr_report_line_entry.sbr_line_label;
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_line_id:'||c_sbr_line_id);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_line_number:'||c_sbr_line_number);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_line_type_code:'||c_sbr_line_type_code);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_natural_bal_type:'||c_sbr_natural_bal_type);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_report_line_number:'||c_sbr_report_line_number);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_line_label:'||v_line_label);
    END IF;
    IF g_error_code           = 0 THEN
      IF c_sbr_line_type_code = 'D' OR c_sbr_line_type_code = 'D2' THEN
        g_column_number      := 1;
    IF ( UPPER(NVL(c_sbr_gl_balance,'N')) = 'N' ) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Calling build_fiscal_line_columns :'||v_period_fiscal_year);
      	build_fiscal_line_columns(v_period_fiscal_year);
     END IF;
	/*Pulling data for current year from GL BALANCES tables directly with out FV_FACT_TEMP*/
    IF ( UPPER(NVL(c_sbr_gl_balance,'N')) = 'Y' ) THEN
	-- As get_sbr_py_bal_details pulls data for previous year
	-- increasing fiscal year by one
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Calling get_sbr_py_bal_details :'||v_period_fiscal_year);
	     v_year_flag:='C';
	     get_sbr_py_bal_details(v_period_fiscal_year+1);

	     /*Populating  previous fiscal year amount */
		v_col_3_amt:=0;
		v_col_4_amt:=0;
		BEGIN
			SELECT col_1_amt, col_2_amt
			INTO v_col_3_amt,v_col_4_amt
			FROM fv_cfs_rep_temp
			WHERE line_id=v_line_id
			AND ledger_id=v_sob
			AND reporty_type='SBR'
			AND period_num=v_period_num
			AND period_year=v_period_fiscal_year-1;
		EXCEPTION
    WHEN OTHERS THEN
			FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception','BUILD_REPORT_LINES:Either fv_cfs_rep_temp table does not have data or some unknown error');
			FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception',SQLERRM);
		END;

	     populate_temp_table;
    END IF;

      ELSIF c_sbr_line_type_code = 'T' THEN
         SELECT COUNT(*)
           INTO l_line_cnt
           FROM fv_sbr_rep_line_calc
          WHERE line_id = c_sbr_line_id;
        IF l_line_cnt   = 0 THEN
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error','Total line does not contain calculations. SEED Data not properly Loaded. Please Verify and reinvoke the Process.');
          RETURN;
        END IF;
        process_sbr_total_line;
      END IF; -- end of IF c_sbr_line_type_code = 'D' or c_sbr_line_type_code = 'D2' THEN
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
  IF sbr_report_line_cursor%ISOPEN THEN
    CLOSE sbr_report_line_cursor;
  END IF;
  g_error_code    := SQLCODE;
  g_error_message := SQLERRM;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception','BUILD_REPORT_LINES');
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception',g_error_message);
  --
END build_report_lines;
-- --------------------------------------------------------
-- ----------------------------------------------
PROCEDURE build_fiscal_line_columns
  (
    p_fiscal_year NUMBER)
  --
IS
  l_module_name VARCHAR2(200);
  --
  -- ----------------------------------------------
  l_ignore             INTEGER;
  query_fetch_bal_bud  VARCHAR2(8600);
  query_fetch_bal_nbfa VARCHAR2(8600);
  where_clause         VARCHAR2(8600);
  financing_account_treas FV_FACTS_FEDERAL_ACCOUNTS.financing_account%TYPE;
  availability_type_treas fv_sbr_definitions_accts.availability_type%TYPE;
  fund_type_treas fv_treasury_symbols.fund_group_code%TYPE;
  group_by_clause VARCHAR2(50):= 'group by bud_col,nbfa_col';


BEGIN
  l_module_name := g_module_name || 'build_fiscal_line_columns';
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'START BUILD_FISCAL_LINE_COLUMNS');
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, '-- LINE('||C_sbr_LINE_NUMBER||')' || ' Tresury Symbol('||c_sbr_ts_value ||')' || ' '||TO_CHAR(SYSDATE,'mm/dd/yyyy hh:mi:ss'));
  END IF;
  --
  -- ----------------------------------------
  -- Get Fund Accummulation
  -- ----------------------------------------
  c_total_balance      := 0;
  c_total_balance_bud  :=0;
  c_total_balance_nbfa :=0;
  -- c_sbr_amount_not_shown := 0;
  c_begin_balance  := 0;
  c_ending_balance := 0;
  c_begin_period   := g_period_num;
  c_end_period     := parm_gl_period_num;
  CSum_E           :=0;
  DSum_E           :=0;
  CSum_B           :=0;
  CSum_B           :=0;
  /* Mofified SBR ER Bug 9445574*/
  v_col_1_amt:=0;
  v_col_2_amt:=0;
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Before balance_type_cursor :');
  -- for the line find all accounts and sum
  FOR balance_type_rec IN balance_type_cursor
  LOOP
    c_sbr_line_acct_id            := balance_type_rec.sbr_line_acct_id;
    c_sbr_balance_type            := balance_type_rec.sbr_balance_type;
    c_acct_number                 := balance_type_rec.acct_number;
    c_direct_or_reimb_code        := balance_type_rec.direct_or_reimb_code;
    c_apportionment_category_code := balance_type_rec.apportionment_category_code;
    c_category_b_code             := balance_type_rec.category_b_code;
    c_prc_code                    := balance_type_rec. prc_code;
    c_advance_code                := balance_type_rec.advance_code;
    c_availability_time           := balance_type_rec.availability_time;
    c_bea_category_code           := balance_type_rec.bea_category_code;
    c_borrowing_source_code       := balance_type_rec.borrowing_source_code;
    c_transaction_partner         := balance_type_rec.transaction_partner;
    c_year_of_budget_authority    := balance_type_rec.year_of_budget_authority;
    c_prior_year_adjustment       := balance_type_rec.prior_year_adjustment;
    c_authority_type              := balance_type_rec.authority_type;
    c_tafs_status                 := balance_type_rec.tafs_status;
    c_availability_type           := balance_type_rec.availability_type;
    c_expiration_flag             := balance_type_rec.expiration_flag;
    c_fund_type                   := balance_type_rec.fund_type;
    c_financing_account_code      := balance_type_rec.financing_account_code;
    c_sbr_treasury_symbol_id      := balance_type_rec.sbr_treasury_symbol_id;
    /* Initializing for each account amount Bug 9453402*/
    c_total_balance      := 0;
    c_total_balance_bud  :=0;
    c_total_balance_nbfa :=0;
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'in balance_type_cursor :c_acct_number->'||c_acct_number);

  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Before gl_period_statuses ');

	SELECT start_date,
	end_date
	 INTO beg_date,
	close_date
	 FROM gl_period_statuses
	WHERE period_year = p_fiscal_year
	AND period_num    = report_period_num
	AND application_id  = 101
	AND set_of_books_id = v_sob;


    FOR get_ts_id_rec IN get_ts_id_cur(c_acct_number)
    LOOP
    --Initializing for each account amount Bug 9453402
    c_total_balance      :=0;
    c_total_balance_bud  :=0;
    c_total_balance_nbfa :=0;

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'in get_ts_id_rec :get_ts_id_rec.treasury_symbol_id ->'||get_ts_id_rec.treasury_symbol_id);
/*
 * If Treasury symbol is defined on SBR Definitions form for an account then amount for that
 * Treasury symbol is only considered on report
*/
    if (c_sbr_treasury_symbol_id is null or c_sbr_treasury_symbol_id=get_ts_id_rec.treasury_symbol_id) then
       c_rescission_flag              := 'FALSE';
    IF upper(c_sbr_additional_info) = 'RESCISSION' THEN
       SELECT upper(resource_type)
         INTO c_resource_type
         FROM fv_treasury_symbols
        WHERE treasury_symbol_id = get_ts_id_rec.treasury_symbol_id
      AND set_of_books_id        = v_sob;
      IF c_resource_type LIKE '%APPROPRIATION%' THEN
        IF ltrim(rtrim(c_sbr_report_line_number)) = '1A' THEN
          c_rescission_flag                      := 'TRUE';
        ELSE
          c_rescission_flag := 'FALSE';
        END IF;
      ELSIF c_resource_type LIKE '%BORROWING%' THEN
        IF ltrim(rtrim(c_sbr_report_line_number)) = '1B' THEN
          c_rescission_flag                      := 'TRUE';
        ELSE
          c_rescission_flag := 'FALSE';
        END IF;
      ELSIF c_resource_type LIKE '%CONTRACT%' THEN
        IF ltrim(rtrim(c_sbr_report_line_number)) = '1C' THEN
          c_rescission_flag                      := 'TRUE';
        ELSE
          c_rescission_flag := 'FALSE';
        END IF;
      END IF;
    ELSE
      c_rescission_flag := 'TRUE';
    END IF;

      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Before c_rescission_flag = TRUE ');

    IF c_rescission_flag = 'TRUE' THEN

     /*Avialability type and Treasury symbol */
    BEGIN

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'before  fv_treasury_symbols');

    SELECT DECODE(time_frame,'NO_YEAR','X',NULL) ,
      ffg.fund_type                               ,
      expiration_Date
      INTO availability_type_treas,
      fund_type_treas              ,
      exp_date
      FROM fv_treasury_symbols fts,
      fv_fund_groups ffg
      WHERE fts.treasury_symbol_id=get_ts_id_rec.treasury_symbol_id
      AND fts.set_of_books_id       = v_sob
      AND fts.set_of_books_id       = ffg.set_of_books_id
      AND ffg.fund_group_code       = fts.fund_group_code;

      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'After fv_treasury_symbols/fv_fund_groups');
      -- Extract expiration date of treasury symbol and determine if the TS expired
      -- or will it expire in the year for which the process is run
      IF(exp_date   < close_date ) THEN
      whether_Exp := 'E';
      ELSE
      whether_Exp := 'U';
      END IF;

      IF (exp_date  IS NULL) THEN
      whether_Exp          := 'U';
      whether_Exp_SameYear := 'N';
      END IF;

      IF (exp_date IS NOT NULL) THEN
	      SELECT extract ( YEAR FROM expiration_date)
	      INTO expiring_year
	      FROM fv_treasury_symbols
	      WHERE treasury_symbol_id=get_ts_id_rec.treasury_symbol_id
        AND set_of_books_id=v_sob;

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'After expiring_year');

       IF (expiring_year        IS NOT NULL AND expiring_year = v_period_fiscal_year) THEN
  	      whether_Exp_SameYear   := 'Y';
       elsif ( expiring_year     > v_period_fiscal_year) THEN
	      whether_Exp_SameYear   := 'N';
        END IF;
      END IF;

      SELECT fed.financing_account
      INTO financing_account_treas
      FROM FV_FACTS_FEDERAL_ACCOUNTS fed,
      fv_treasury_symbols treas
      WHERE fed.federal_acct_symbol_id = treas.federal_acct_symbol_id
      AND treas.treasury_symbol_id       =get_ts_id_rec.treasury_symbol_id
      AND treas.set_of_books_id          = v_sob;

   EXCEPTION
     WHEN OTHERS THEN
    g_error_code    := SQLCODE;
    g_error_message := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, '.exception','For Treasury symbol '||get_ts_id_rec.treasury_symbol_id||' '||G_ERROR_MESSAGE);

   END;
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'After FV_FACTS_FEDERAL_ACCOUNTS');
      query_fetch_bal_bud        :=NULL;
      query_fetch_bal_nbfa       :=NULL;
      where_clause               := ' ';


      IF (c_direct_or_reimb_code IS NOT NULL) THEN
        where_clause             := where_clause||' '||' and trim(reimburseable_flag) = '''||c_direct_or_reimb_code|| '''  ';
      END IF;
      IF (c_apportionment_category_code IS NOT NULL) THEN
        where_clause                    := where_clause||' '||' and trim(appor_cat_code) = '''||c_apportionment_category_code|| '''  ';
      END IF;
      IF (c_category_b_code IS NOT NULL) THEN
        where_clause        := where_clause||' '||' and trim(appor_cat_b_dtl) = '''||c_category_b_code|| '''  ';
      END IF;
      IF (c_advance_code IS NOT NULL) THEN
        where_clause     := where_clause||' '||' and trim(advance_flag) = '''||c_advance_code|| '''  ';
      END IF;
      IF (c_availability_time IS NOT NULL) THEN
        where_clause          := where_clause||' '||' and trim(availability_flag) = '''||c_availability_time|| '''  ';
      END IF;
      IF (c_bea_category_code IS NOT NULL) THEN
        where_clause          := where_clause||' '||' and trim(bea_category) = '''||c_bea_category_code|| '''  ';
      END IF;
      IF (c_borrowing_source_code IS NOT NULL) THEN
        where_clause              := where_clause||' '||' and trim(borrowing_source) = '''||c_borrowing_source_code|| '''  ';
      END IF;
      IF (c_transaction_partner IS NOT NULL) THEN
        where_clause            := where_clause||' '||' and trim(fac.transaction_partner) = '''||c_transaction_partner|| '''  ';
      END IF;
      IF (c_year_of_budget_authority IS NOT NULL) THEN
        where_clause                 := where_clause||' '||' and trim(year_budget_auth) = '''||c_year_of_budget_authority|| '''  ';
      END IF;
      IF (c_prior_year_adjustment IS NOT NULL) THEN
        where_clause              := where_clause||' '||' and trim(pya_flag) = '''||c_prior_year_adjustment|| '''  ';
      END IF;
      IF (c_prc_code IS NOT NULL) THEN
        where_clause := where_clause||' '||' and trim(PROGRAM_RPT_CAT_NUM) = '''||c_prc_code|| '''  ';
      END IF;
      IF (c_authority_type IS NOT NULL) THEN
        where_clause       := where_clause||' '||' and trim(fac.authority_type) = '''||c_authority_type|| '''  ';
      END IF;
     -- Modified code for SBR ER bug 9466381
     -- Undo the changes to fix the bug 9506794

      IF (c_expiration_flag IS NOT NULL ) THEN
        where_clause        := where_clause||' '||'and expiration_flag = '''||whether_Exp_SameYear||''' ';
      END IF;
      IF (c_tafs_status IS NOT NULL) THEN
        where_clause    := where_clause||' '||'and trim(tafs_status) = '''||whether_Exp|| '''  ';
      END IF;
      --IF (c_availability_type IS NOT NULL AND c_availability_type ='X' ) THEN
      IF (c_availability_type IS NOT NULL ) THEN
       where_clause          := where_clause||' '||'and trim(availability_type) = '''||availability_type_treas||''' ';
      END IF;
      IF (c_fund_type IS NOT NULL ) THEN
        where_clause  := where_clause||' '||'and trim(fund_type) = '''||fund_type_treas||''' ';
      END IF;

      IF (c_financing_account_code IS NOT NULL ) THEN
      where_clause               := where_clause||' '||'and trim(financing_account_code) = '''||financing_account_treas||''' ';
      END IF;

FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'After FV_FACTS_FEDERAL_ACCOUNTS');


      IF( c_sbr_balance_type      = 'B' OR c_sbr_balance_type = 'E') THEN
        IF(( c_sbr_line_type_code = 'D' AND c_sbr_natural_bal_type ='D') OR ( c_sbr_line_type_code = 'D2' AND c_sbr_natural_bal_type ='C'))THEN
          query_fetch_bal_bud    := 'select  sum(nvl(amount,0)),acct.bud_col,acct.nbfa_col from fv_facts_temp fac, fv_sbr_definitions_accts   acct
            where  (acct.sbr_treasury_symbol_id is null or acct.sbr_treasury_symbol_id = :cv_treasury_symbol_id)
            AND acct.sbr_line_id         = :cv_sbr_line_id
            AND acct.sbr_line_acct_id    = :cv_sbr_line_acct_id
            AND acct_number like fac.sgl_acct_number||''%'' and fac.sgl_acct_number is not null
            AND fac.fct_int_record_category =  ''REPORTED_NEW'' and fac.fct_int_record_tYPE = ''BLK_DTL''
            AND fac.treasury_symbol_id = (select treasury_symbol_id from fv_treasury_symbols
                                           where set_of_books_id='||v_sob||' AND treasury_symbol_id='||get_ts_id_rec.treasury_symbol_id||')
            AND begin_end =  '''||c_sbr_balance_type||'''';


        elsif (( c_sbr_line_type_code = 'D' AND c_sbr_natural_bal_type ='C') OR ( c_sbr_line_type_code = 'D2' AND c_sbr_natural_bal_type ='D') ) THEN
          query_fetch_bal_bud        := 'select  sum(nvl(amount,0)*(-1)),acct.bud_col,acct.nbfa_col  from fv_facts_temp fac, fv_sbr_definitions_accts   acct
          where (acct.sbr_treasury_symbol_id is null or acct.sbr_treasury_symbol_id = :cv_treasury_symbol_id)
          AND acct.sbr_line_id         = :cv_sbr_line_id
          AND acct.sbr_line_acct_id    = :cv_sbr_line_acct_id
          and acct_number like fac.sgl_acct_number||''%'' and fac.sgl_acct_number is not null
          and fac.fct_int_record_category =  ''REPORTED_NEW'' and fac.fct_int_record_tYPE = ''BLK_DTL''
          AND fac.treasury_symbol_id = (select treasury_symbol_id from fv_treasury_symbols
                                           where set_of_books_id='||v_sob||' AND treasury_symbol_id='||get_ts_id_rec.treasury_symbol_id||')
          AND begin_end =  '''||c_sbr_balance_type||'''';


        END IF;
        /*Executing the query_fetch_bud dynamic query to get the sum of amounts that has to be displayed under bud_col*/
        IF (query_fetch_bal_bud IS NOT NULL) THEN
          v_cursor_id           := dbms_sql.open_cursor;
          query_fetch_bal_bud   := query_fetch_bal_bud ||' '|| where_clause||' '||group_by_clause;
          -- print query
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,query_fetch_bal_bud);
          dbms_sql.parse(v_cursor_id, query_fetch_bal_bud, dbms_sql.v7);
          dbms_sql.define_column(v_cursor_id, 1, c_total_balance);
          dbms_sql.define_column(v_cursor_id, 2, v_bud_col,1);
          dbms_sql.define_column(v_cursor_id, 3, v_nbfa_col,1);
          dbms_sql.bind_variable(v_cursor_id,':cv_sbr_line_acct_id',c_sbr_line_acct_id);
          dbms_sql.bind_variable(v_cursor_id,':cv_treasury_symbol_id',c_sbr_treasury_symbol_id);
          dbms_sql.bind_variable(v_cursor_id,':cv_sbr_line_id',c_sbr_line_id);
          --print bind variables
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_balance_type:'||c_sbr_balance_type);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_treasury_symbol_id:'||c_sbr_treasury_symbol_id);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_sbr_line_acct_id:'||c_sbr_line_acct_id);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_line_id:'||c_sbr_line_id);
          l_ignore                     := dbms_sql.execute_and_fetch(v_cursor_id);
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_ignore := '||l_ignore);
          END IF;
          dbms_sql.column_value(v_cursor_id, 1, c_total_balance);
          dbms_sql.column_value(v_cursor_id, 2, v_bud_col);
          dbms_sql.column_value(v_cursor_id, 3, v_nbfa_col);
          dbms_sql.close_cursor(v_cursor_id);

          v_bud_col:=nvl(v_bud_col,'Y');
          v_nbfa_col:=nvl(v_nbfa_col,'N');
          IF UPPER(v_nbfa_col)          ='Y' THEN
            c_total_balance_nbfa:=c_total_balance_nbfa+c_total_balance;
          ELSIF UPPER(v_bud_col)        ='Y' THEN
            c_total_balance_bud :=c_total_balance_bud+c_total_balance;
          END IF;
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance:'||c_total_balance);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance_nbfa:'||c_total_balance_bud);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance_bud:'||c_total_balance_bud);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_bud_col:'||v_bud_col);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_nbfa_col:'||v_nbfa_col);
        END IF;

      elsif c_sbr_balance_type    = 'E-B' THEN -- balance type is end-begin
        IF(( c_sbr_line_type_code = 'D' AND c_sbr_natural_bal_type ='D') OR ( c_sbr_line_type_code = 'D2' AND c_sbr_natural_bal_type ='C') ) THEN

          query_fetch_bal_bud := ' select
          SUM(DECODE (begin_end,''E'',nvl(AMOUNT,0),''B'',nvl(AMOUNT,0)*(-1)) ),
          acct.bud_col,acct.nbfa_col
          from fv_facts_temp fac, fv_sbr_definitions_accts   acct
          where (acct.sbr_treasury_symbol_id is null or acct.sbr_treasury_symbol_id = :cv_treasury_symbol_id)
          AND acct.sbr_line_id         = :cv_sbr_line_id
          AND acct.sbr_line_acct_id    = :cv_sbr_line_acct_id
          and acct_number like fac.sgl_acct_number||''%'' and fac.sgl_acct_number is not null
          AND fac.treasury_symbol_id = (select treasury_symbol_id from fv_treasury_symbols
                                           where set_of_books_id='||v_sob||' AND treasury_symbol_id='||get_ts_id_rec.treasury_symbol_id||')
          and fac.fct_int_record_category =  ''REPORTED_NEW'' and fac.fct_int_record_tYPE = ''BLK_DTL''';

          v_cursor_id         := dbms_sql.open_cursor;
          query_fetch_bal_bud := query_fetch_bal_bud ||' '|| where_clause||' '||group_by_clause;
          dbms_sql.parse(v_cursor_id, query_fetch_bal_bud, dbms_sql.v7);
          dbms_sql.define_column(v_cursor_id, 1, c_total_balance);
          dbms_sql.define_column(v_cursor_id, 2, v_bud_col,1);
          dbms_sql.define_column(v_cursor_id, 3, v_nbfa_col,1);
          dbms_sql.bind_variable(v_cursor_id,':cv_sbr_line_acct_id',c_sbr_line_acct_id);
          dbms_sql.bind_variable(v_cursor_id,':cv_treasury_symbol_id',c_sbr_treasury_symbol_id);
          dbms_sql.bind_variable(v_cursor_id,':cv_sbr_line_id',c_sbr_line_id);
          -- print query
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,query_fetch_bal_bud);
          --print bind variables
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_balance_type:'||c_sbr_balance_type);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_treasury_symbol_id:'||c_sbr_treasury_symbol_id);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_sbr_line_acct_id:'||c_sbr_line_acct_id);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_line_id:'||c_sbr_line_id);
          l_ignore                     := dbms_sql.execute_and_fetch(v_cursor_id);
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_ignore := '||l_ignore);
          END IF;
          dbms_sql.column_value(v_cursor_id, 1, c_total_balance);
          dbms_sql.column_value(v_cursor_id, 2, v_bud_col);
          dbms_sql.column_value(v_cursor_id, 3, v_nbfa_col);
          dbms_sql.close_cursor(v_cursor_id);
          v_bud_col:=nvl(v_bud_col,'Y');
          v_nbfa_col:=nvl(v_nbfa_col,'N');
          IF UPPER(v_nbfa_col)          ='Y' THEN
            c_total_balance_nbfa:=c_total_balance_nbfa+c_total_balance;
          ELSIF  UPPER(v_bud_col)        ='Y' THEN
            c_total_balance_bud :=c_total_balance_bud+c_total_balance;
          END IF;
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance:'||c_total_balance);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance_bud:'||c_total_balance_bud);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance_nbfa:'||c_total_balance_nbfa);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_bud_col:'||v_bud_col);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_nbfa_col:'||v_nbfa_col);

        elsif (( c_sbr_line_type_code = 'D' AND c_sbr_natural_bal_type ='C') OR ( c_sbr_line_type_code = 'D2' AND c_sbr_natural_bal_type ='D'))THEN
          /*FOR BUD_COL*/
          query_fetch_bal_bud := ' select
          SUM(DECODE (begin_end,''E'',nvl(AMOUNT,0),''B'',nvl(AMOUNT,0)*(-1)) )*(-1),acct.bud_col,acct.nbfa_col
          from fv_facts_temp fac, fv_sbr_definitions_accts   acct
          where (acct.sbr_treasury_symbol_id is null or acct.sbr_treasury_symbol_id = :cv_treasury_symbol_id)
          AND acct.sbr_line_id         = :cv_sbr_line_id
          AND acct.sbr_line_acct_id    = :cv_sbr_line_acct_id
          and acct_number like fac.sgl_acct_number||''%'' and fac.sgl_acct_number is not null
          AND fac.treasury_symbol_id = (select treasury_symbol_id from fv_treasury_symbols
                                           where set_of_books_id='||v_sob||' AND treasury_symbol_id='||get_ts_id_rec.treasury_symbol_id||')
          and fac.fct_int_record_category =  ''REPORTED_NEW'' and fac.fct_int_record_tYPE = ''BLK_DTL''';

          v_cursor_id         := dbms_sql.open_cursor;
          query_fetch_bal_bud := query_fetch_bal_bud ||' '|| where_clause ||' '||group_by_clause;
          dbms_sql.parse(v_cursor_id, query_fetch_bal_bud, dbms_sql.v7);
          dbms_sql.define_column(v_cursor_id, 1, c_total_balance);
          dbms_sql.define_column(v_cursor_id, 2, v_bud_col,1);
          dbms_sql.define_column(v_cursor_id, 3, v_nbfa_col,1);
          dbms_sql.bind_variable(v_cursor_id,':cv_sbr_line_acct_id',c_sbr_line_acct_id);
          dbms_sql.bind_variable(v_cursor_id,':cv_treasury_symbol_id',c_sbr_treasury_symbol_id);
          dbms_sql.bind_variable(v_cursor_id,':cv_sbr_line_id',c_sbr_line_id);
          -- print query
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,query_fetch_bal_bud);
          --print bind variables
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_balance_type:'||c_sbr_balance_type);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_treasury_symbol_id:'||c_sbr_treasury_symbol_id);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_sbr_line_acct_id:'||c_sbr_line_acct_id);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_line_id:'||c_sbr_line_id);
          l_ignore                     := dbms_sql.execute_and_fetch(v_cursor_id);
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_ignore := '||l_ignore);
          END IF;
          dbms_sql.column_value(v_cursor_id, 1, c_total_balance);
          dbms_sql.column_value(v_cursor_id, 2, v_bud_col);
          dbms_sql.column_value(v_cursor_id, 3, v_nbfa_col);
          dbms_sql.close_cursor(v_cursor_id);
          v_bud_col:=nvl(v_bud_col,'Y');
          v_nbfa_col:=nvl(v_nbfa_col,'N');
          IF  UPPER(v_nbfa_col)          ='Y' THEN
            c_total_balance_nbfa:=c_total_balance_nbfa+c_total_balance;
          ELSIF  UPPER(v_bud_col)        ='Y' THEN
            c_total_balance_bud :=c_total_balance_bud+c_total_balance;
          END IF;
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance:'||c_total_balance);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance_nbfa:'||c_total_balance_nbfa);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance_bud:'||c_total_balance_bud);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_bud_col:'||v_bud_col);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_nbfa_col:'||v_nbfa_col);

        elsif (( c_sbr_balance_type= 'ED') OR( c_sbr_balance_type= 'EC')) THEN -- bal type is ending debit or ending credit only
          /*FOR BUD COL */
          query_fetch_bal_bud     := 'select  sum(nvl(amount,0)),acct.bud_col,acct.nbfa_col
          from fv_facts_temp fac, fv_sbr_definitions_accts   acct
          where (acct.sbr_treasury_symbol_id is null or acct.sbr_treasury_symbol_id = :cv_treasury_symbol_id)
          AND acct.sbr_line_id         = :cv_sbr_line_id
          AND acct.sbr_line_acct_id    = :cv_sbr_line_acct_id
          and acct_number like fac.sgl_acct_number||''%'' and fac.sgl_acct_number is not null
          AND fac.treasury_symbol_id = (select treasury_symbol_id from fv_treasury_symbols
                                           where set_of_books_id='||v_sob||' AND treasury_symbol_id='||get_ts_id_rec.treasury_symbol_id||')
          and fac.fct_int_record_category =  ''REPORTED_NEW'' and fac.fct_int_record_tYPE = ''BLK_DTL''
          AND begin_end = ''E''';

          IF (query_fetch_bal_bud IS NOT NULL) THEN
            v_cursor_id           := dbms_sql.open_cursor;
            query_fetch_bal_bud   := query_fetch_bal_bud ||' '|| where_clause||' '||group_by_clause;
            dbms_sql.parse(v_cursor_id, query_fetch_bal_bud, dbms_sql.v7);
            dbms_sql.define_column(v_cursor_id, 1, c_total_balance);
            dbms_sql.define_column(v_cursor_id, 2, v_bud_col,1);
            dbms_sql.define_column(v_cursor_id, 3, v_nbfa_col,1);
            dbms_sql.bind_variable(v_cursor_id,':cv_sbr_line_acct_id',c_sbr_line_acct_id);
            dbms_sql.bind_variable(v_cursor_id,':cv_treasury_symbol_id',c_sbr_treasury_symbol_id);
            dbms_sql.bind_variable(v_cursor_id,':cv_sbr_line_id',c_sbr_line_id);
            -- print query
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,query_fetch_bal_bud);
            --print bind variables
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_balance_type:'||c_sbr_balance_type);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'parm_tsymbol_id:'||c_sbr_treasury_symbol_id);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_sbr_line_acct_id:'||c_sbr_line_acct_id);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_line_id:'||c_sbr_line_id);
            l_ignore                     := dbms_sql.execute_and_fetch(v_cursor_id);
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_ignore := '||l_ignore);
            END IF;
            dbms_sql.column_value(v_cursor_id, 1, c_total_balance);
            dbms_sql.column_value(v_cursor_id, 2, v_bud_col);
            dbms_sql.column_value(v_cursor_id, 3, v_nbfa_col);
            dbms_sql.close_cursor(v_cursor_id);
          v_bud_col:=nvl(v_bud_col,'Y');
          v_nbfa_col:=nvl(v_nbfa_col,'N');
            IF ( c_sbr_balance_type = 'ED')THEN
              IF (c_total_balance   < 0) THEN
                c_total_balance    := 0;
              END IF;
            elsif ( c_sbr_balance_type = 'EC')THEN
              IF (c_total_balance      > 0) THEN
                c_total_balance       := 0;
              END IF;
            END IF;
            IF(( c_sbr_line_type_code = 'D' AND c_sbr_natural_bal_type ='D') OR ( c_sbr_line_type_code = 'D2' AND c_sbr_natural_bal_type ='C'))THEN
              c_total_balance        := c_total_balance;
            END IF;
            IF (( c_sbr_line_type_code = 'D' AND c_sbr_natural_bal_type ='C') OR ( c_sbr_line_type_code = 'D2' AND c_sbr_natural_bal_type ='D')) THEN
              c_total_balance         := c_total_balance*(-1);
            END IF;
            IF  UPPER(v_nbfa_col)         ='Y' THEN
              c_total_balance_nbfa:=c_total_balance_nbfa+c_total_balance;
            ELSIF  UPPER(v_bud_col)        ='Y' THEN
              c_total_balance_bud :=c_total_balance_nbfa+c_total_balance;
            END IF;
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance:'||c_total_balance);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance_bud:'||c_total_balance_bud);
            fV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance_nbfa:'||c_total_balance_nbfa);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_bud_col:'||v_bud_col);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_nbfa_col:'||v_nbfa_col);
          END IF;

        elsif( (c_sbr_balance_type= 'E-BD') OR (c_sbr_balance_type='E-BC')) THEN -- bal type is end begin debit only
          /*FOR BUD_COL*/
          query_fetch_bal_bud := ' select
          SUM(DECODE (begin_end,''E'',nvl(AMOUNT,0),''B'',nvl(AMOUNT,0)*(-1)) ),acct.bud_col,acct.nbfa_col
          from fv_facts_temp fac, fv_sbr_definitions_accts   acct
          where (acct.sbr_treasury_symbol_id is null or acct.sbr_treasury_symbol_id = :cv_treasury_symbol_id)
          AND acct.sbr_line_id         = :cv_sbr_line_id
          AND acct.sbr_line_acct_id    = :cv_sbr_line_acct_id
          and acct_number like fac.sgl_acct_number||''%'' and fac.sgl_acct_number is not null
          AND fac.treasury_symbol_id = (select treasury_symbol_id from fv_treasury_symbols
                                           where set_of_books_id='||v_sob||' AND treasury_symbol_id='||get_ts_id_rec.treasury_symbol_id||')
          and fac.fct_int_record_category =  ''REPORTED_NEW'' and fac.fct_int_record_tYPE = ''BLK_DTL''';

          v_cursor_id         := dbms_sql.open_cursor;
          query_fetch_bal_bud := query_fetch_bal_bud ||' '|| where_clause||' '||group_by_clause;
          dbms_sql.parse(v_cursor_id, query_fetch_bal_bud, dbms_sql.v7);
          dbms_sql.define_column(v_cursor_id, 1, c_total_balance);
          dbms_sql.define_column(v_cursor_id, 2, v_bud_col,1);
          dbms_sql.define_column(v_cursor_id, 3, v_nbfa_col,1);
          dbms_sql.bind_variable(v_cursor_id,':cv_sbr_line_acct_id',c_sbr_line_acct_id);
          dbms_sql.bind_variable(v_cursor_id,':cv_treasury_symbol_id',c_sbr_treasury_symbol_id);
          dbms_sql.bind_variable(v_cursor_id,':cv_sbr_line_id',c_sbr_line_id);
          -- print query
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,query_fetch_bal_bud);
          --print bind variables
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_balance_type:'||c_sbr_balance_type);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_treasury_symbol_id:'||c_sbr_treasury_symbol_id);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'cv_sbr_line_acct_id:'||c_sbr_line_acct_id);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_sbr_line_id:'||c_sbr_line_id);
          l_ignore := dbms_sql.execute_and_fetch(v_cursor_id);


          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'l_ignore := '||l_ignore);
          END IF;
          dbms_sql.column_value(v_cursor_id, 1, c_total_balance);
          dbms_sql.column_value(v_cursor_id, 2, v_bud_col);
          dbms_sql.column_value(v_cursor_id, 3, v_nbfa_col);
          dbms_sql.close_cursor(v_cursor_id);


          IF (c_sbr_balance_type        = 'E-BD') THEN
            IF (c_total_balance         > 0) THEN
              IF(( c_sbr_line_type_code = 'D' AND c_sbr_natural_bal_type ='D') OR ( c_sbr_line_type_code = 'D2' AND c_sbr_natural_bal_type ='C') ) THEN
                c_total_balance        := c_total_balance;
              END IF;
              IF(( c_sbr_line_type_code = 'D' AND c_sbr_natural_bal_type ='C') OR ( c_sbr_line_type_code = 'D2' AND c_sbr_natural_bal_type ='D') ) THEN
                c_total_balance        := c_total_balance*-1;
              END IF;
            ELSE
              c_total_balance :=0; -- consider the balance only if E-B is positive
            END IF;
          END IF; -- end for if (c_sbr_balance_type= 'E-BD') then
          IF (c_sbr_balance_type        = 'E-BC') THEN
            IF (c_total_balance         < 0) THEN
              IF(( c_sbr_line_type_code = 'D' AND c_sbr_natural_bal_type ='D') OR ( c_sbr_line_type_code = 'D2' AND c_sbr_natural_bal_type ='C') ) THEN
                c_total_balance        :=c_total_balance;
              END IF;
              IF(( c_sbr_line_type_code = 'D' AND c_sbr_natural_bal_type ='C') OR ( c_sbr_line_type_code = 'D2' AND c_sbr_natural_bal_type ='D') ) THEN
                c_total_balance        :=c_total_balance*-1;
              END IF;
            ELSE
              c_total_balance :=0; -- consider the balance only if E-B is negative
            END IF;
            v_bud_col:=nvl(v_bud_col,'Y');
            v_nbfa_col:=nvl(v_nbfa_col,'N');

            IF  UPPER(v_nbfa_col)          ='Y' THEN
              c_total_balance_nbfa:=c_total_balance_nbfa + c_total_balance;
            ELSIF  UPPER(v_bud_col)        ='Y' THEN
              c_total_balance_bud :=c_total_balance_bud + c_total_balance;
            END IF;
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance:'||c_total_balance);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance_nbfa:'||c_total_balance_nbfa);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance_bud:'||c_total_balance_bud);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_bud_col:'||v_bud_col);
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_nbfa_col:'||v_nbfa_col);
          END IF;

          END IF;
        END IF; -- end checking for balance types
      END IF;   -- end for if rescission condition
      -- sum the line amount
      IF (c_total_balance_bud IS NULL) THEN
        c_total_balance_bud   :=0;
      END IF;
      IF (c_total_balance_nbfa IS NULL) THEN
        c_total_balance_nbfa   :=0;
      END IF;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance_bud = '||c_total_balance_bud);
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'c_total_balance_nbfa = '||c_total_balance_nbfa);
      END IF;

    end if;
      -- Added for SBR ER bug 9439646
      v_col_1_amt                  := v_col_1_amt + c_total_balance_bud;
      v_col_2_amt                  := v_col_2_amt + c_total_balance_nbfa;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_col_1_amt ='||v_col_1_amt);
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_col_2_amt ='||v_col_2_amt);
      END IF;


    END LOOP;

  END LOOP;
    --
    -- set up correct display sign
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NATURAL BAL TYPE = '||C_sbr_NATURAL_BAL_TYPE);
    END IF;

     /*
      Commented for SBR ER bug 9439646
      v_col_1_amt                  := c_total_balance_bud;
      v_col_2_amt                  := c_total_balance_nbfa;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_col_1_amt ='||v_col_1_amt);
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_col_2_amt ='||v_col_2_amt);
      END IF;*/

    v_col_3_amt:=0;
    v_col_4_amt:=0;

     /*Populating  previous fiscal year amount */
   BEGIN
     SELECT col_1_amt, col_2_amt
	INTO v_col_3_amt,v_col_4_amt
	FROM fv_cfs_rep_temp
	WHERE line_id=v_line_id
	AND ledger_id=v_sob
	AND reporty_type='SBR'
	AND period_num=v_period_num
	AND period_year=v_period_fiscal_year-1;
    EXCEPTION
    WHEN OTHERS THEN
      --g_error_code    := SQLCODE;
      g_error_message := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception','BUILD_FISCAL_LINE_COLUMNS:Either fv_cfs_rep_temp table does not have data or some unknown error');
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception',G_ERROR_MESSAGE);
    END;

     populate_temp_table;



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
      CLOSE balance_type_cursor;
    ELSIF dbms_sql.is_open(v_cursor_id) THEN
      dbms_sql.close_cursor(v_cursor_id);
    END IF;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception','BUILD_FISCAL_LINE_COLUMNS:'||G_ERROR_MESSAGE);
    --
END build_fiscal_line_columns;

PROCEDURE purge_csf_temp_table
  --
IS
  l_module_name VARCHAR2(200) ;
  --
BEGIN
  l_module_name := g_module_name || 'purge_csf_temp_table';
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'START PURGE_TEMP_TABLE');
  END IF;
  --

   DELETE
     FROM fv_cfs_rep_temp
    WHERE (line_id) IN
    (SELECT sbr_line_id
       FROM fv_sbr_definitions_lines
      WHERE set_of_books_id = v_sob
    )
    and upper(reporty_type) <> 'SBR';
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
  g_error_message := 'purge_temp_table/'||SQLERRM;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception',g_error_message);
  --
END purge_csf_temp_table;


/*
  build_sbr_dynamic_query procedure will build a dynamic
  to pull data from GL_BALANCES table
*/

PROCEDURE build_sbr_dynamic_query
 IS
  l_module_name VARCHAR2(200) := g_module_name || 'build_sbr_dynamic_query';
  CURSOR flex_columns_cursor
  IS
     SELECT UPPER(glflex.application_column_name) column_name,
      flex_value_set_id
       FROM fnd_id_flex_segments glflex
      WHERE glflex.application_id = 101
    AND glflex.id_flex_num        = v_chart_of_accounts_id
    AND glflex.id_flex_code       = 'GL#'
   ORDER BY glflex.application_column_name;

  l_flex_column_name fnd_id_flex_segments.application_column_name%TYPE;
  l_flex_value_set_id fnd_id_flex_segments.flex_value_set_id%TYPE;
  l_temp1             VARCHAR2(8000) DEFAULT '';
  l_temp2             VARCHAR2(8000) DEFAULT '';
  l_table_name        VARCHAR2(50);
  l_period_name_where VARCHAR2(500);
  l_stage             NUMBER;
  l_out               VARCHAR2(32000);
  l_column_name       VARCHAR2(30);
  l_glbal_temp        VARCHAR2(32000);
BEGIN
/*  v_fct1_attr_select :=
  ' SELECT SUM(NVL(DECODE(:cv_balance_type,
''B'', ROUND(NVL(fctbal.begin_balance,0),2),
''E'', ROUND(NVL(fctbal.balance_amount,0))),0) )
FROM  fv_sbr_definitions_accts        dets,
fv_sbr_definitions_lines fsdl ,
fv_sbr_ccids_gt fvcc,
fv_facts1_period_attributes  fctbal
WHERE dets.sbr_line_id           = :cv_line_id
AND fsdl.sbr_line_id=dets.sbr_line_id
AND dets.sbr_line_acct_id    = :cv_line_detail_id
AND dets.sbr_line_acct_id           = fvcc.sbr_line_acct_id
AND fctbal.ccid  = fvcc.ccid
AND fctbal.set_of_books_id =       :b_sob
AND fctbal.period_year          =  :cv_period_fiscal_year
AND EXISTS
(SELECT 1
FROM fv_fund_parameters ffp
WHERE set_of_books_id = :b_sob
AND fund_category like nvl(fsdl.sbr_fund_category, ''%'')
AND ffp.fund_value = fctbal.fund_value )';

AND ( trunc(fund_expire_date)  <= :cv_end_date
OR ((trunc(fund_expire_date) >= :cv_end_date or fund_expire_date is null)
and (trunc(fund_cancel_date) > :cv_end_date  or fund_cancel_date is null)))';

  l_stage       := 1;
  l_out         := v_fct1_attr_select;
  v_glbal_curid := dbms_sql.open_cursor;
  dbms_sql.parse(v_glbal_curid, v_fct1_attr_select, dbms_sql.v7);
  dbms_sql.define_column(v_glbal_curid, 1, v_amount);
  dbms_sql.bind_variable(v_glbal_curid,':b_sob',v_sob);

  v_fct1_sel      := 'SELECT ROUND(SUM(NVL(ffrt.amount,0) ),2) ';
  v_fct1_rcpt_sel := v_fct1_sel || ' , ffrt.recipient_name ';
  l_temp1         := '
FROM fv_sbr_definitions_accts        dets,
  fv_sbr_ccids_gt               fvcc,
fv_facts1_period_balances_v ffrt
WHERE dets.sbr_line_id         = :cv_line_id
AND dets.sbr_line_acct_id    = :cv_line_detail_id
AND dets.sbr_line_acct_id    =  fvcc.sbr_line_acct_id
AND ffrt.ccid              = fvcc.ccid
AND ffrt.period_year = :cv_period_fiscal_year
AND ffrt.set_of_books_id  = :b_sob
AND ffrt.period_num <= :cv_period_num
AND ffrt.balance_type = NVL(:cv_balance_type, ffrt.balance_type)'   ;


  v_fct1_sel            := v_fct1_sel || l_temp1;
  v_fct1_rcpt_sel       := v_fct1_rcpt_sel || l_temp1 || ' GROUP BY ffrt.recipient_name ';
  l_stage               := 3;
  l_out                 := v_fct1_rcpt_sel;

  v_fct1_rcpt_sel_curid := dbms_sql.open_cursor;
  dbms_sql.parse(v_fct1_rcpt_sel_curid, v_fct1_rcpt_sel, dbms_sql.v7);
  dbms_sql.define_column(v_fct1_rcpt_sel_curid, 1, v_amount);
  dbms_sql.define_column(v_fct1_rcpt_sel_curid, 2, v_recipient_name, 240);
  dbms_sql.bind_variable(v_fct1_rcpt_sel_curid,':b_sob',v_sob);
  v_fct1_rcpt_sel2       := REPLACE(v_fct1_rcpt_sel, 'GROUP BY ffrt.recipient_name', 'AND ffrt.recipient_name = :cv_recipient_name');
  v_fct1_rcpt_sel2       := REPLACE(v_fct1_rcpt_sel2, ', ffrt.recipient_name', ', 1');
  l_stage                := 4;
  l_out                  := v_fct1_rcpt_sel2;
  v_fct1_rcpt_sel2_curid := dbms_sql.open_cursor;
  dbms_sql.parse(v_fct1_rcpt_sel2_curid, v_fct1_rcpt_sel2, dbms_sql.v7);
  dbms_sql.define_column(v_fct1_rcpt_sel2_curid, 1, v_amount);
  dbms_sql.define_column(v_fct1_rcpt_sel2_curid, 2, v_recipient_name, 240);
  dbms_sql.bind_variable(v_fct1_rcpt_sel2_curid,':b_sob',v_sob);
  l_stage          := 5;
  l_out            := v_fct1_sel;
  v_fct1_sel_curid := dbms_sql.open_cursor;
  dbms_sql.parse(v_fct1_sel_curid, v_fct1_sel, dbms_sql.v7);
  dbms_sql.define_column(v_fct1_sel_curid, 1, v_amount);
  dbms_sql.bind_variable(v_fct1_sel_curid,':b_sob',v_sob);
  */

  v_glbal_select :=
  ' SELECT
NVL(DECODE(:cv_balance_type,
''B'', ROUND(NVL(SUM(NVL(glbal.begin_balance_dr,0) -
NVL(glbal.begin_balance_cr,0)),0),2),
''E'', ROUND(NVL(SUM((NVL(glbal.begin_balance_dr,0) -
NVL(glbal.begin_balance_cr,0)) +
(NVL(glbal.period_net_dr,0) -
NVL(glbal.period_net_cr,0))),0),2)),0)
FROM  fv_sbr_definitions_accts        dets,
fv_sbr_definitions_lines fsdl ,
gl_code_combinations       glc,
gl_code_combinations       glc1,
gl_balances                glbal
WHERE dets.sbr_line_id           = :cv_line_id
AND dets.sbr_line_acct_id    = :cv_line_detail_id
AND dets.sbr_line_id = fsdl.sbr_line_id
AND glc1.'||v_acc_seg_name|| ' like :cv_acc_num
AND glc.code_combination_id=glc1.code_combination_id
AND glc1.chart_of_accounts_id  =  :b_chart_of_accounts_id
AND glc.chart_of_accounts_id  =  :b_chart_of_accounts_id
AND glbal.code_combination_id  = glc.code_combination_id
AND glbal.code_combination_id  = glc1.code_combination_id
AND glbal.ledger_id =       :b_sob
AND glbal.period_year          =  :cv_period_fiscal_year
AND glbal.period_num           =  :cv_period_num
--AND glbal.currency_code        <> ''STAT''
AND glbal.currency_code        = :v_currency_code
AND glbal.actual_flag          = ''A''
AND EXISTS
(SELECT 1
FROM fv_fund_parameters ffp
WHERE set_of_books_id = :b_sob
AND fund_category like nvl(fsdl.sbr_fund_category, ''%'')
AND ffp.fund_value = glc.'||v_bal_seg_name||')';
/*AND ( trunc(fund_expire_date)  <= :cv_end_date
OR ((trunc(fund_expire_date) >= :cv_end_date or fund_expire_date is null)
and (trunc(fund_cancel_date) > :cv_end_date  or fund_cancel_date is null))))  ';*/
  l_stage     := 6;
  l_out       := v_glbal_select;
  v_sbr_curid := dbms_sql.open_cursor;
  dbms_sql.parse(v_sbr_curid, v_glbal_select, dbms_sql.v7);

  dbms_sql.bind_variable(v_sbr_curid,':b_chart_of_accounts_id', v_chart_of_accounts_id);
  dbms_sql.bind_variable(v_sbr_curid,':b_sob',v_sob);
  dbms_sql.bind_variable(v_sbr_curid,':v_currency_code',v_currency_code);

EXCEPTION
WHEN OTHERS THEN
  v_retcode := SQLCODE ;
  v_errbuf  := SQLERRM || ' [build_sbr_dynamic_query] ' ;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_errbuf);
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception','Stage it errors ' || l_stage);
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_out);
  RETURN;
END build_sbr_dynamic_query;

PROCEDURE get_sbr_py_bal_details(p_fiscal_year NUMBER)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'get_sbr_py_bal_details';
  CURSOR fv_sbr_detail_cur
  IS
     SELECT
      sbr_line_acct_id,
      sbr_balance_type,
      bud_col,
      nbfa_col,
      acct_number
      FROM fv_sbr_definitions_accts
      WHERE sbr_line_id = v_line_id
      and set_of_books_id = v_sob;

  l_ignore INTEGER;
  l_prev_year_amount fv_cfs_rep_temp.col_1_amt%TYPE := 0;
  l_begin_balance NUMBER;
  l_end_balance   NUMBER;
  l_period_name_1 gl_period_statuses.period_name%TYPE;
  l_period_name_2 gl_period_statuses.period_name%TYPE;
  l_begin_period_name gl_period_statuses.period_name%TYPE;
  l_begin_period_name_1 gl_period_statuses.period_name%TYPE;
  l_begin_period_name_2 gl_period_statuses.period_name%TYPE;
  l_period_fiscal_year NUMBER;
  l_begin_period       NUMBER;
  l_end_period         NUMBER := v_period_num;
  l_end_period_1       NUMBER ;
  l_end_period_name_1 gl_period_statuses.period_name%TYPE;
  l_begin_period_1 NUMBER;
  l_begin_period_end_date DATE;
  l_end_period_end_date DATE := v_end_date;
  l_begin_period_1_end_date DATE;
  l_end_period_1_end_date DATE;
  l_log_mesg  VARCHAR2(32000) := '';
  l_conc_segs VARCHAR2(32000);
  l_delimiter fnd_id_flex_structures.concatenated_segment_delimiter%TYPE;
  l_account_type VARCHAR2(1) := '';
  l_account_number gl_code_combinations.segment1%TYPE;
  l_balance_determined   NUMBER;
  l_prev_year_gl_balance NUMBER;
  l_curr_year_gl_balance NUMBER;
  l_e_ne_ind fv_facts_attributes.exch_non_exch%TYPE := NULL;
  l_c_nc_ind fv_facts_attributes.cust_non_cust%TYPE := NULL;
  l_diff_amt       NUMBER;
  l_diff_amt_tot   NUMBER := 0;
  l_temp_amount    NUMBER;
  l_ussgl_acct_num NUMBER;
  l_period_year gl_period_statuses.period_name%TYPE;
  l_amount          NUMBER;
  l_end_period_num1 NUMBER;
  l_end_period_num2 NUMBER;
  l_ccid_gl_amt     NUMBER;
  l_gl_tot_amt      NUMBER;
  l_bal_type_amt    NUMBER;
BEGIN
   SELECT concatenated_segment_delimiter
     INTO l_delimiter
     FROM fnd_id_flex_structures
    WHERE application_id = 101
  AND id_flex_code       = 'GL#'
  AND id_flex_num        = v_chart_of_accounts_id;

  IF ( UPPER(v_year_flag) = 'P') THEN
	  v_col_3_amt:=0;
	  v_col_4_amt:=0;
  END IF;

  IF ( UPPER(v_year_flag) = 'C') THEN
	  v_col_1_amt:=0;
	  v_col_2_amt:=0;
  END IF;

  l_log_mesg := '***** Line Number' || v_line_number || ':  ' || '*****';
  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,l_log_mesg);
  FOR detail_rec IN fv_sbr_detail_cur
  LOOP ---- L1
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '########');
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Account Num: '||detail_rec.acct_number);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'line id: '||v_line_id);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'line detail id: '||detail_rec.sbr_line_acct_id);
    fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'balance type: '||detail_rec.sbr_balance_type);

    v_balance_type         := detail_rec.sbr_balance_type;
    l_balance_determined   := 0;
    l_prev_year_gl_balance := 0;
    l_curr_year_gl_balance := 0;
    l_diff_amt_tot         := 0;
                           --- 1
      IF detail_rec.acct_number IS NOT NULL THEN
          BEGIN
             SELECT SUBSTR(compiled_value_attributes, 5, 1)
               INTO l_account_type
               FROM fnd_flex_values
              WHERE flex_value    = detail_rec.acct_number
            AND flex_value_set_id = v_acct_flex_value_set_id;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT parent_flex_value
                 INTO l_account_number
                 FROM fnd_flex_value_hierarchies
                WHERE detail_rec.acct_number BETWEEN child_flex_value_low AND child_flex_value_high
              AND flex_value_set_id = v_acct_flex_value_set_id
              AND ROWNUM            = 1;
               SELECT SUBSTR(compiled_value_attributes, 5, 1)
                 INTO l_account_type
                 FROM fnd_flex_values
                WHERE flex_value    = l_account_number
              AND flex_value_set_id = v_acct_flex_value_set_id;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
            END;
          END;
        END IF;
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Account Type: '||l_account_type);
        -- ===================================================================
        v_py_gl_beg_bal := 0;
        v_py_gl_end_bal := 0;
        v_cy_gl_beg_bal := 0;
        v_cy_gl_end_bal := 0;
       /* -- Get beginning balances for current and prior years from
        -- facts1 attributes.
        dbms_sql.bind_variable(v_glbal_curid,':cv_line_id',v_line_id);
        dbms_sql.bind_variable(v_glbal_curid,':cv_line_detail_id',detail_rec.sbr_line_acct_id);
        -- Get prior year beginning balance
        dbms_sql.bind_variable(v_glbal_curid,':cv_period_fiscal_year',p_fiscal_year-1);
        dbms_sql.bind_variable(v_glbal_curid,':cv_balance_type','B');
        --dbms_sql.bind_variable(v_glbal_curid,':cv_end_date', v_begin_period_1_end_date);
        l_ignore := dbms_sql.execute_and_fetch(v_glbal_curid);
        dbms_sql.column_value(v_glbal_curid, 1, v_py_gl_beg_bal);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Prior year begin gl bal: '||v_py_gl_beg_bal);
*/
   fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_report_type: '||v_report_type);
        IF UPPER(v_report_type) = 'SBR' THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'IN SIDE IF : ');
          v_cy_sbr_beg_bal := 0;
          v_cy_sbr_end_bal := 0;
          v_py_sbr_beg_bal := 0;
          v_py_sbr_end_bal := 0;
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'bEFORE IF detail_rec.sbr_balance_type:detail_rec.acct_number-> '||detail_rec.sbr_balance_type||'::'||detail_rec.acct_number);
          dbms_sql.bind_variable(v_sbr_curid,':cv_line_id',v_line_id);
          dbms_sql.bind_variable(v_sbr_curid,':cv_line_detail_id',detail_rec.sbr_line_acct_id);
          --dbms_sql.bind_variable(v_sbr_curid,':cv_account_number',detail_rec.acct_number);
          dbms_sql.bind_variable(v_sbr_curid,':cv_acc_num',detail_rec.acct_number||'%');


             ---- Get Prior year balances ----
          ---------------------------------

          IF detail_rec.sbr_balance_type = 'B' THEN
            -- If balance type is begin
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'inside  IF detail_rec.sbr_balance_type: '||detail_rec.sbr_balance_type);
            dbms_sql.define_column(v_sbr_curid, 1, v_py_sbr_beg_bal);
            dbms_sql.bind_variable(v_sbr_curid,':cv_balance_type','B');
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_num',v_begin_period_1);


            ---dbms_sql.bind_variable(v_sbr_curid,':cv_end_date', v_begin_period_1_end_date);
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_fiscal_year',p_fiscal_year-1);
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_sbr_curid : ');
            l_ignore := dbms_sql.execute_and_fetch(v_sbr_curid);

            dbms_sql.column_value(v_sbr_curid, 1, v_py_sbr_beg_bal);
            v_amount := v_py_sbr_beg_bal;
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Prior year begin bal: '||v_amount);
            -- IF balance type is ending, ending cr only or ending dr only
          ELSIF detail_rec.sbr_balance_type IN ('C', 'D','E','G','I','J') THEN
            -- Get the begin balance
            dbms_sql.define_column(v_sbr_curid, 1, v_py_sbr_beg_bal);
            dbms_sql.bind_variable(v_sbr_curid,':cv_balance_type','B');
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_num',v_begin_period_1);
            --dbms_sql.bind_variable(v_sbr_curid,':cv_end_date', v_begin_period_1_end_date);
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_fiscal_year',p_fiscal_year-1);
            l_ignore := dbms_sql.execute_and_fetch(v_sbr_curid);
            dbms_sql.column_value(v_sbr_curid, 1, v_py_sbr_beg_bal);

            -- Get the end balance
            dbms_sql.define_column(v_sbr_curid, 1, v_py_sbr_beg_bal);
            dbms_sql.bind_variable(v_sbr_curid,':cv_balance_type','E');
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_num',v_period_num);
            --dbms_sql.bind_variable(v_sbr_curid,':cv_end_date', v_end_period_1_end_date);
            dbms_sql.bind_variable(v_sbr_curid,':cv_period_fiscal_year',p_fiscal_year-1);
            l_ignore := dbms_sql.execute_and_fetch(v_sbr_curid);
            dbms_sql.column_value(v_sbr_curid, 1, v_py_sbr_end_bal);

            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Prior year end bal: '||v_py_sbr_end_bal);
            v_amount := get_bal_type_amt(detail_rec.sbr_balance_type, v_natural_balance_type, NVL(v_py_sbr_beg_bal,0), NVL(v_py_sbr_end_bal,0));
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_amount: '||v_amount);
          END IF;
          l_log_mesg               := ', ' || NVL(v_amount, 0);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'detail_rec.bud_col: '||detail_rec.bud_col);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'detail_rec.nbfa_col: '||detail_rec.nbfa_col);

          -- Added upper function for bug 9453175
	   /*Summing previous years amount*/
	  IF ( UPPER(v_year_flag) = 'P') THEN
	    IF UPPER(nvl(detail_rec.bud_col,'Y')) = 'Y' THEN
		v_col_3_amt            := v_col_3_amt + NVL(v_amount, 0);
	    ELSIF UPPER(nvl(detail_rec.nbfa_col,'N')) = 'Y' THEN
		v_col_4_amt             := v_col_4_amt + NVL(v_amount, 0);
           END IF;
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_col_3_amt: '||v_col_3_amt);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_col_4_amt: '||v_col_4_amt);
	  END IF;
	  /*Summing current years amount*/
	  IF ( UPPER(v_year_flag) = 'C') THEN
	    IF UPPER(nvl(detail_rec.bud_col,'Y')) = 'Y' THEN
		v_col_1_amt            := v_col_1_amt + NVL(v_amount, 0);
	    ELSIF UPPER(nvl(detail_rec.nbfa_col,'N')) = 'Y' THEN
		v_col_2_amt             := v_col_2_amt + NVL(v_amount, 0);
           END IF;
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_col_1_amt: '||v_col_1_amt);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'v_col_2_amt: '||v_col_2_amt);
	  END IF;

         END IF; --- 10

  END LOOP;     --- L1
EXCEPTION
WHEN OTHERS THEN
  v_retcode := SQLCODE ;
  v_errbuf  := SQLERRM || ' [get_sbr_py_bal_details] ' ;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_errbuf);
  RETURN;
END get_sbr_py_bal_details;

PROCEDURE purge_facts_transactions
IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name := g_module_name || 'purge_facts_transactions';

		DELETE FROM fv_facts_temp
		WHERE treasury_symbol_id = v_purge_ts_id;

		DELETE FROM fv_facts_edit_check_status
		WHERE treasury_symbol_id = v_purge_ts_id;

		DELETE FROM fv_cfs_rep_temp
		WHERE ledger_id=v_sob
		AND reporty_type='SBR'
		AND period_num=v_period_num
		AND period_year=v_period_fiscal_year;


		COMMIT ;

EXCEPTION
-- Exception Processing
When NO_DATA_FOUND Then
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'NO DATA FOUND IN FV_FACTS_TEMP / FV_FACTS_EDIT_CHECK_STATUS tables ');
When Others Then
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.final_exception',SQLERRM);
END purge_facts_transactions ;



-- =============================================================
BEGIN
  g_module_name := 'fv.plsql.FV_CFS_PKG.';
END fv_cfs_pkg;
-- =============================================================


/
