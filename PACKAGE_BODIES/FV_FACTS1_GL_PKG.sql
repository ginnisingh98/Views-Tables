--------------------------------------------------------
--  DDL for Package Body FV_FACTS1_GL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FACTS1_GL_PKG" AS
/* $Header: FVFCJCRB.pls 120.19.12010000.4 2009/12/10 12:41:54 snama ship $ */

g_module_name VARCHAR2(100);

gbl_bal_segment VARCHAR2(10);
gbl_acc_segment VARCHAR2(10);
gbl_jrnl_attribute VARCHAR2(15);
gbl_vend_attribute VARCHAR2(15);
gbl_cust_attribute VARCHAR2(15);
gbl_currency_code  gl_ledgers_public_v.currency_code%TYPE;
gbl_period_name      gl_period_statuses.period_name%TYPE;
gbl_sob_id  gl_ledgers_public_v.ledger_id%TYPE;
gbl_coa_id gl_ledgers_public_v.chart_of_accounts_id%TYPE;
gbl_err_code NUMBER := 0;
gbl_err_buff  VARCHAR2(250);
gbl_period_num_low  gl_period_statuses.period_num%TYPE;
gbl_period_num_high  gl_period_statuses.period_num%TYPE;
gbl_period_year gl_period_statuses.period_year%TYPE;
gbl_exception_rec_count NUMBER;
gbl_called_from_main    VARCHAR2(1);
gbl_header_id  gl_je_headers.je_header_id%type := 0;
gbl_trading_partner_att fv_be_trx_dtls.attribute1%TYPE;
gbl_manual_source_flag VARCHAR2(1) := 'N';



TYPE party_info_rec IS RECORD (
           party_id    fv_facts1_line_balances.Party_Id%TYPE,
           cust_vend_type    fv_facts1_line_balances.party_type%TYPE,
           vendor_type   fv_facts1_line_balances.party_classification%TYPE,
           elim_dept     fv_facts1_line_balances.eliminations_dept%TYPE,
           recipient_name fv_facts1_line_balances.recipient_name%TYPE,
           reported_status VARCHAR2(1),
           record_category fv_facts1_line_balances.record_category%TYPE,
           feeder_flag   fv_facts1_line_balances.feeder_flag%TYPE,
           g_ng_indicator fv_facts1_line_balances.g_ng_indicator%TYPE,
           party_line_amount NUMBER);
TYPE party_info_table IS TABLE OF party_info_rec
  INDEX BY BINARY_INTEGER;


--------------------------------------------------------------------------------
PROCEDURE CLEANUP;
PROCEDURE GET_SEGMENT_NAMES;
PROCEDURE GET_SYSTEM_ATTRIBUTES;
PROCEDURE GET_PROCESS_DATES;
PROCEDURE PROCESS_GL_LINES;
PROCEDURE GET_PARTY_INFO(p_category     IN VARCHAR2,
                         p_source        IN VARCHAR2,
                         p_reference_1   IN VARCHAR2,
                         p_reference_2   IN VARCHAR2,
                         p_reference_3   IN VARCHAR2,
                         p_reference_5   IN VARCHAR2,
                         p_reference_7   IN VARCHAR2,
		                     p_jrnl_attribute IN VARCHAR2,
                         p_fed_nonfed    IN VARCHAR2,
                         p_je_from_sla_flag IN VARCHAR2,
                         p_je_batch_id   IN NUMBER,
                         p_je_header_id  IN NUMBER,
                         p_je_line_num   IN NUMBER,
                         p_jrnl_dc_ind   IN VARCHAR2,
                         p_party_info_tab OUT NOCOPY party_info_table);
PROCEDURE INSERT_EXCEPTION_RECS;
PROCEDURE SUBMIT_EXCEPTION_REPORT;
PROCEDURE UPDATE_FACTS1_RUN;
PROCEDURE get_reference_column (p_entity_code IN VARCHAR2,
                                p_je_batch_id IN NUMBER,
                                p_je_header_id IN NUMBER,
                                p_je_line_num IN NUMBER,
                                p_application_id IN NUMBER,
                                p_jrnl_dc_indicator IN VARCHAR2,
                                p_party_info_tab OUT NOCOPY party_info_table);
PROCEDURE log(module IN VARCHAR2,
              message_line IN VARCHAR2);
--------------------------------------------------------------------------------
PROCEDURE MAIN(p_err_buff OUT NOCOPY VARCHAR2,
               p_err_code OUT NOCOPY NUMBER,
               p_sob_id IN NUMBER,
               p_period_name IN VARCHAR2,
               p_called_from_main IN VARCHAR2,
               p_trading_partner_att IN VARCHAR2)
IS

l_period_year number(15);
l_no_fed_account number(15);
l_module_name VARCHAR2(200);

BEGIN

    l_module_name := g_module_name || 'MAIN';
    FV_UTILITY.LOG_MESG('In '||l_module_name);

    FV_UTILITY.LOG_MESG('Parameters:');
    FV_UTILITY.LOG_MESG('p_sob_id: '||p_sob_id);
    FV_UTILITY.LOG_MESG('p_period_name: '||p_period_name);
    FV_UTILITY.LOG_MESG('p_called_from_main: '||p_called_from_main);
    FV_UTILITY.LOG_MESG('p_trading_partner_att: '||p_trading_partner_att);

    gbl_trading_partner_att := upper(p_trading_partner_att);

    gbl_called_from_main := p_called_from_main;
    if (gbl_called_from_main = 'I') then
      gbl_called_from_main := 'N';
    End if;

     p_err_code := 0;
     gbl_err_code := 0;

    IF gbl_err_code <> 0 THEN
      p_err_code := gbl_err_code;
      p_err_buff := gbl_err_buff;
      RETURN;
    END IF;

    SELECT period_year
    INTO l_period_year
    FROM gl_period_statuses
    WHERE application_id = 101
    AND  ledger_id = p_sob_id
    AND  period_name = p_period_name;



        SELECT count(*)
        INTO l_no_fed_account
        FROM fv_facts1_fed_accounts
        WHERE set_of_books_id = p_sob_id
        AND fiscal_year = l_period_year;


   if l_no_fed_account = 0 then
       p_err_buff := 'Please run the FACTS-1 Federal Accounts Creation process for this SOB
        and period  ' || p_period_name;
       p_err_code := -1;
       commit;
       return;
     End if;

    gbl_sob_id := p_sob_id;
    gbl_period_name := p_period_name;
    gbl_err_code := 0;



    IF gbl_err_code = 0 THEN
       get_system_attributes;
    END IF;

    IF gbl_err_code = 0 THEN
       get_segment_names;
    END IF;

    IF gbl_err_code = 0 THEN
       get_process_dates;
    END IF;

    IF gbl_err_code = 0 THEN
       process_gl_lines;
    END IF;

    IF gbl_err_code = 0 THEN
       insert_exception_recs;
    END IF;

    IF gbl_err_code = 0 THEN
         update_facts1_run;
    END IF;

    IF gbl_err_code <> 0 THEN
      p_err_code := gbl_err_code;
      p_err_buff := gbl_err_buff;
      ROLLBACK;
      RETURN;
    END IF;

    COMMIT;

    FV_UTILITY.LOG_MESG('Facts I Journal Process completed successfully.');

 EXCEPTION WHEN OTHERS THEN
    p_err_code := SQLCODE;
    p_err_buff := 'When others exception in Main - '||SQLERRM;
    ROLLBACK;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_err_buff);

END main;
--------------------------------------------------------------------------------
PROCEDURE CLEANUP
IS

l_module_name VARCHAR2(200);

BEGIN

  l_module_name := g_module_name || 'CLEANUP';
  FV_UTILITY.LOG_MESG('In '||l_module_name);

  DELETE FROM   fv_facts_report_t2
  WHERE  set_of_books_id = gbl_sob_id;

 EXCEPTION WHEN OTHERS THEN
    gbl_err_code := SQLCODE;
    gbl_err_buff := l_module_name||' - When others exception - '||SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_err_buff);

END CLEANUP;

--------------------------------------------------------------------------------
-- Get balancing and accounting segments
--------------------------------------------------------------------------------
PROCEDURE GET_SEGMENT_NAMES
IS

l_module_name VARCHAR2(200);
l_app_id   NUMBER := 101;
l_flex_code VARCHAR2(10) := 'GL#';
l_segment_found BOOLEAN := FALSE;
invalid_bal_segment EXCEPTION;
invalid_acc_segment EXCEPTION;

BEGIN

  l_module_name := g_module_name || 'GET_SEGMENT_NAMES';
  FV_UTILITY.LOG_MESG('In '||l_module_name);


  FV_UTILITY.LOG_MESG('COA ID: '||gbl_coa_id);

   -- Get Balancing Segment Name
  -----------------------------
  l_segment_found := FND_FLEX_APIS.get_segment_column
                             (l_app_id,
                              l_flex_code,
                              gbl_coa_id,
                              'GL_BALANCING',
                              gbl_bal_segment) ;

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
                         gbl_acc_segment);
  IF NOT l_segment_found THEN
     RAISE invalid_acc_segment;
  END IF;

  IF (gbl_bal_segment IS NULL OR
      gbl_acc_segment IS NULL) THEN
     RAISE NO_DATA_FOUND;
  END IF;

  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
          'Balancing Segment: '||gbl_bal_segment);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
          'Accounting Segment: '||gbl_acc_segment);

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
       gbl_err_code := -1 ;
       gbl_err_buff := 'Balancing or Accounting segment not found.';
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_err_buff);
   WHEN invalid_bal_segment THEN
       gbl_err_code := -1 ;
       gbl_err_buff := 'Error while fetching balancing segment.';
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_err_buff);
   WHEN invalid_acc_segment THEN
       gbl_err_code := -1 ;
       gbl_err_buff := 'Error while fetching accounting segment.';
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_err_buff);
   WHEN OTHERS THEN
       gbl_err_code := -1 ;
       gbl_err_buff := 'When others error while getting
                        Balancing or Accounting segment - '||SQLERRM;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_err_buff);
END get_segment_names;
--------------------------------------------------------------------------------
-- Get the period num for the parameter period and also the first period num
-- for the year.
--------------------------------------------------------------------------------
PROCEDURE GET_PROCESS_DATES
IS

l_module_name VARCHAR2(200);
l_temp_mesg VARCHAR2(250);

BEGIN

    l_module_name := g_module_name || 'GET_PROCESS_DATES';
    FV_UTILITY.LOG_MESG('In '||l_module_name);

    -- Get the period year for the period parameter passed.
    l_temp_mesg := 'getting period year.';
    SELECT period_year
    INTO   gbl_period_year
    FROM   gl_period_statuses p
    WHERE  p.application_id = 101
    AND    p.ledger_id = gbl_sob_id
    AND    p.period_name = gbl_period_name;

    -- Get the first period of the year
    l_temp_mesg := 'getting first period number of the year.';
    SELECT MIN(period_num)
    INTO  gbl_period_num_low
    FROM  gl_period_statuses
    WHERE period_year = gbl_period_year
    AND   application_id = 101
    AND   closing_status <> 'F'
    AND   closing_status <> 'N'
    AND   adjustment_period_flag = 'N'
    AND   ledger_id = gbl_sob_id;

    -- Get the period num for the parameter period
    l_temp_mesg := 'getting period number of the parameter period.';
    SELECT period_num
    INTO   gbl_period_num_high
    FROM   gl_period_statuses p
    WHERE  period_name = gbl_period_name
    AND    p.application_id = 101
    AND    p.ledger_id = gbl_sob_id
    AND    p.period_year = gbl_period_year;

    IF (gbl_period_num_low = 0 OR
         gbl_period_num_high = 0) THEN
      gbl_err_code := 2 ;
      gbl_err_buff  := l_module_name||' Period number '||
                        'found zero for the passed fiscal year.' ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_err_buff);
      RETURN;
    END IF;

       FV_UTILITY.LOG_MESG('Period Year: '||gbl_period_year);
       FV_UTILITY.LOG_MESG('Period Number Low: '||gbl_period_num_low);
       FV_UTILITY.LOG_MESG('Period Number High: '||gbl_period_num_high);

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
         gbl_err_code := 2;
         gbl_err_buff := l_module_name||' - No data found when '||l_temp_mesg;
         FV_UTILITY.LOG_MESG(gbl_err_buff);

    WHEN OTHERS THEN
         gbl_err_code := 2;
         gbl_err_buff := l_module_name||' - When others error when '||l_temp_mesg;
         FV_UTILITY.LOG_MESG(gbl_err_buff);
END get_process_dates;
--------------------------------------------------------------------------------
-- Get Facts I Journal, Vendor and Customer attributes
--------------------------------------------------------------------------------
PROCEDURE GET_SYSTEM_ATTRIBUTES
IS
l_module_name VARCHAR2(200);

l_temp_mesg VARCHAR2(50);
BEGIN

      l_module_name := g_module_name || 'GET_SYSTEM_ATTRIBUTES';
      FV_UTILITY.LOG_MESG('In '||l_module_name);

      l_temp_mesg := 'getting Journal Attribute.';
      SELECT factsI_journal_attribute
      INTO   gbl_jrnl_attribute
      FROM   fv_system_parameters;

      l_temp_mesg := 'getting Vendor/Customer Attribute.';
      SELECT factsI_vendor_attribute, factsI_customer_attribute
      INTO   gbl_vend_attribute, gbl_cust_attribute
      FROM   fv_system_parameters;

      IF (gbl_jrnl_attribute IS NULL OR
         gbl_vend_attribute IS NULL OR
         gbl_cust_attribute IS NULL) THEN
         RAISE NO_DATA_FOUND;
      END IF;

      l_temp_mesg := 'getting Currency Code/Chart of Accounts Id.';
      SELECT currency_code, chart_of_accounts_id
      INTO   gbl_currency_code, gbl_coa_id
      FROM   gl_ledgers_public_v
      WHERE  ledger_id = gbl_sob_id;


      FV_UTILITY.LOG_MESG('Journal Attribute: '||gbl_jrnl_attribute);
      FV_UTILITY.LOG_MESG('Vendor Attribute: '||gbl_vend_attribute);
      FV_UTILITY.LOG_MESG('Customer Attribute: '||gbl_cust_attribute);
      FV_UTILITY.LOG_MESG('Currency: '||gbl_currency_code);
      FV_UTILITY.LOG_MESG('Chart of Accounts Id: '||gbl_coa_id);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
           gbl_err_code := 2;
           gbl_err_buff  := l_module_name||' - Null values/No data found when '||
                             l_temp_mesg;
           FV_UTILITY.LOG_MESG(l_module_name,gbl_err_buff);

      WHEN OTHERS THEN
           gbl_err_code := SQLCODE;
           gbl_err_buff := l_module_name||' - When others error '||l_temp_mesg||
                         ' - '||SQLERRM;
           FV_UTILITY.LOG_MESG(l_module_name,gbl_err_buff);

END get_system_attributes;
--------------------------------------------------------------------------------
PROCEDURE log(module IN VARCHAR2,
              message_line IN VARCHAR2) IS
--------------------------------------------------------------------------------
l_module_name VARCHAR2(1000);
BEGIN

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
             module, message_line);

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      FV_UTILITY.LOG_MESG('When others error in module: log: '||sqlerrm);
END log;
--------------------------------------------------------------------------------
-- Select all journal lines from gl_je_lines from the beginning of the year upto
-- the period being run, for all accounts existing in fv_facts1_fed_accounts and
-- all journal lines not existing in fv_facts1_line_balances.
-- Retreives party info like party type, eliminations dept, etc and insert into
-- fv_facts1_line_balances.
--------------------------------------------------------------------------------
PROCEDURE PROCESS_GL_LINES
IS
l_module_name VARCHAR2(200);

TYPE t_ref_cur IS REF CURSOR ;
l_gl_lines_cur  t_ref_cur ;

TYPE je_header_id_t IS TABLE OF gl_je_headers.je_header_id%TYPE;
TYPE je_category_t IS TABLE OF gl_je_headers.je_category%TYPE;
TYPE je_source_t IS TABLE OF gl_je_headers.je_source%TYPE;
TYPE je_line_num_t IS TABLE OF gl_je_lines.je_line_num%TYPE;
TYPE sob_id_t IS TABLE OF gl_je_lines.ledger_id%TYPE;
TYPE ccid_t IS TABLE OF gl_je_lines.code_combination_id%TYPE;
TYPE attribute_val_t IS TABLE OF gl_je_lines.attribute1%TYPE;
TYPE amount_t IS TABLE OF fv_facts1_line_balances.amount%TYPE;
TYPE d_c_indicator_t IS TABLE OF fv_facts1_line_balances.d_c_indicator%TYPE;
TYPE gl_period_t IS TABLE OF gl_je_lines.period_name%TYPE;
TYPE party_id_t IS TABLE OF fv_facts1_line_balances.party_id%TYPE;
TYPE party_type_t IS TABLE OF fv_facts1_line_balances.party_type%TYPE;
TYPE vendor_type_t IS TABLE OF fv_facts1_line_balances.party_classification%TYPE;
TYPE recipient_name_t IS TABLE OF fv_facts1_line_balances.recipient_name%TYPE;
TYPE eliminations_dept_t IS TABLE OF fv_facts1_line_balances.eliminations_dept%TYPE;
TYPE reference_t IS TABLE OF gl_je_lines.reference_1%TYPE;
TYPE fund_value_t IS TABLE OF fv_fund_parameters.fund_value%TYPE;
TYPE account_number_t IS TABLE OF fv_facts1_line_balances.account_number%TYPE;
TYPE fed_nonfed_t IS TABLE OF fv_facts1_fed_accounts.fed_non_fed%TYPE;
TYPE g_ng_indicator_t IS TABLE OF fv_facts1_line_balances.g_ng_indicator%TYPE;
TYPE record_category_t IS TABLE OF fv_facts1_line_balances.record_category%TYPE;
TYPE varchar_1_t IS TABLE OF VARCHAR2(1);
TYPE period_num_t IS TABLE OF gl_period_statuses.period_num%TYPE;
TYPE je_from_sla_flag_t IS TABLE OF VARCHAR2(1);
TYPE je_batch_id_t IS TABLE OF gl_je_headers.je_batch_id%TYPE;

je_header_id_list_new je_header_id_t;
je_header_id_list je_header_id_t;
je_category_list je_category_t;
je_source_list je_source_t;
je_line_num_list je_line_num_t;
sob_id_list sob_id_t;
ccid_list ccid_t;
attribute_value_list attribute_val_t;
amount_list amount_t;
d_c_indicator_list d_c_indicator_t;
gl_period_list gl_period_t;
party_id_list party_id_t;
party_type_list party_type_t;
vendor_type_list vendor_type_t;
recipient_name_list recipient_name_t;
eliminations_dept_list eliminations_dept_t;
reference_1_list reference_t;
reference_2_list reference_t;
reference_3_list reference_t;
reference_5_list reference_t;
reference_7_list reference_t;
fund_value_list fund_value_t;
account_number_list account_number_t;
fed_nonfed_list fed_nonfed_t;
g_ng_indicator_list g_ng_indicator_t;
reported_status_list varchar_1_t;
record_category_list record_category_t;
feeder_flag_list varchar_1_t;
period_num_list period_num_t;
je_from_sla_flag_list je_from_sla_flag_t;
je_batch_id_list je_batch_id_t;


ccid_list_2 ccid_t;
period_num_list_2 period_num_t;
account_number_list_2 account_number_t;
fund_value_list_2 fund_value_t;
amount_list_2 amount_t;
d_c_indicator_list_2  d_c_indicator_t;
g_ng_indicator_list_2 g_ng_indicator_t;
eliminations_dept_list_2 eliminations_dept_t;
record_category_list_2 record_category_t;
recipient_name_list_2 recipient_name_t;
je_header_id_list_2 je_header_id_t;
je_line_num_list_2 je_line_num_t;
je_category_list_2  je_category_t;
je_source_list_2 je_source_t;
party_id_list_2 party_id_t;
party_type_list_2 party_type_t;
vendor_type_list_2 vendor_type_t;
attribute_value_list_2 attribute_val_t;
feeder_flag_list_2 varchar_1_t;
gl_period_list_2 gl_period_t;


l_select_stmt VARCHAR2(20000);
l_last_fetch BOOLEAN;

l_party_info_tab party_info_table;

flg boolean;

k BINARY_INTEGER := 1;

BEGIN

    l_module_name := g_module_name || 'PROCESS_GL_LINES';
    FV_UTILITY.LOG_MESG('In '||l_module_name);


  FV_UTILITY.LOG_MESG('Inserting into fv_facts1_header_id_gt');

if gbl_called_from_main = 'N'  then

 INSERT INTO fv_facts1_header_id_gt(je_header_id,set_of_books_id)
  select gjh.je_header_id , gjh.ledger_id
  from
  (SELECT period_num, period_name
       FROM  gl_period_statuses
       WHERE application_id = 101
       AND  ledger_id = gbl_sob_id
      AND  period_num BETWEEN  gbl_period_num_low AND gbl_period_num_high
      AND  period_year = gbl_period_year)  gps,
      gl_je_headers gjh
      where    gjh.period_name = gps.period_name
      and      gjh.ledger_id = gbl_sob_id
      AND     gjh.status = 'P'
      AND     gjh.actual_flag = 'A'
      and not exists (select 'x' from fv_facts1_processed_je_hdrs e
		      where e.set_of_books_id = gjh.ledger_id
		      and   e.je_header_id    = gjh.je_header_id) ;


   FV_UTILITY.LOG_MESG('Inserted ' || SQL%ROWCOUNT);

     COMMIT;
     Fnd_Stats.GATHER_TABLE_STATS(ownname=>'FV',tabname=>'FV_FACTS1_HEADER_ID_GT');

  End if;

  l_select_stmt :=
 '   gjl.code_combination_id,
         gjh.ledger_id,
         glcc.'||gbl_acc_segment|| ',
         (NVL(gjl.accounted_dr,0) - NVL(gjl.accounted_cr,0) )  amount,
         DECODE( SIGN (NVL(gjl.accounted_dr,0) - NVL(gjl.accounted_cr,0)) , -1, ''C'', ''D'') d_c_indicator,
         gjh.je_header_id,
         gjl.je_line_num,
         gjh.je_category,
         gjh.je_source,
         gjl.reference_1,
         gjl.reference_2,
         gjl.reference_3,
         gjl.reference_5,
         gjl.reference_7,
         gjl.'||gbl_jrnl_attribute|| ',
         glcc.'||gbl_bal_segment|| ',
         gjl.period_name,
         NULL party_id,
         NULL party_type,
         NULL party_classification,
         NULL recipient_name,
         NULL eliminations_dept,
         fff.fed_non_fed,
         NULL reported_status,
         NULL record_category,
         NULL feeder_flag,
         gps.period_num,
         NULL g_ng_indicator,
         NVL(gjh.je_from_sla_flag, ''N''),
         gjh.je_batch_id ';

   if gbl_called_from_main = 'Y' then

     l_select_stmt := 'SELECT '  || l_select_stmt ||
            ' FROM
              fv_facts1_fed_accounts fff,
              gl_code_combinations glcc,
             ( SELECT period_num, period_name
               FROM  gl_period_statuses
               WHERE application_id = 101
               AND   ledger_id = :gbl_sob_id
               AND   period_num BETWEEN  :gbl_period_num_low AND :gbl_period_num_high
               AND   period_year = :gbl_period_year )  gps,
              gl_je_lines gjl,
              gl_je_headers gjh
      WHERE  fff.jc_flag = ''N''
      AND    fff.set_of_books_id = :gbl_sob_id
      AND    fff.fiscal_year     = :gbl_period_year
      AND    glcc.'||gbl_acc_segment  || ' =  fff.account_number
      AND    glcc.chart_of_accounts_id  =  :gbl_coa_id
      AND     gjl.code_combination_id = glcc.code_combination_id
      AND     gjl.period_name = gps.period_name
      AND     gjl.ledger_id = :gbl_sob_id
      AND     gjl.je_header_id = gjh.je_header_id
      AND     gjh.currency_code <> ''STAT''
      AND     gjh.ledger_id = :gbl_sob_id
      AND     gjh.status = ''P''
      AND     gjh.actual_flag = ''A'' ' ;


      OPEN l_gl_lines_cur FOR l_select_stmt using
      gbl_sob_id,gbl_period_num_low ,gbl_period_num_high,gbl_period_year,
      gbl_sob_id,gbl_period_year ,gbl_coa_id,gbl_sob_id,gbl_sob_id;

       fv_utility.log_mesg('Running in full mode');
       fv_utility.log_mesg(l_select_stmt);

     else


     l_select_stmt := 'SELECT /*+ ORDERED INDEX(gjh GL_JE_HEADERS_U1, ftt
                       FV_FACTS1_HEADER_ID_GT_U1, gjl GL_JE_LINES_U1,
                       glcc GL_CODE_COMBINATIONS_U1,
                       fff FV_FACTS1_FED_ACCOUNTS_U1) */ ' ||l_select_stmt ||
           ' FROM   fv_facts1_header_id_gt ftt
                  , gl_je_headers gjh
                  , gl_je_lines gjl
                  , (SELECT period_num
                          , period_name
                     FROM   gl_period_statuses ps
                     WHERE  application_id = 101
                       AND  ledger_id = :gbl_sob_id
                       AND  period_num BETWEEN  :gbl_period_num_low AND :gbl_period_num_high
                       AND  period_year = :gbl_period_year) gps
                  , gl_code_combinations glcc
                  , fv_facts1_fed_accounts fff
      WHERE   gjh.period_name = gps.period_name
      AND     gjl.ledger_id = :gbl_sob_id
      AND     gjl.je_header_id = ftt.je_header_id
      AND     gjh.currency_code <> ''STAT''
      AND     gjh.status = ''P''
      AND     gjh.actual_flag = ''A''
      and     gjh.je_header_id = ftt.je_header_id
      and     ftt.set_of_books_id = :gbl_sob_id
      AND     gjh.ledger_id = :gbl_sob_id
      AND     glcc.code_combination_id = gjl.code_combination_id
      AND     glcc.chart_of_accounts_id = :gbl_coa_id
      AND     fff.account_number = glcc.'  ||gbl_acc_segment || '
      AND     fff.set_of_books_id = :gbl_sob_id
      AND     fff.fiscal_year = :gbl_period_year' ;


     fv_utility.log_mesg('Running in cumulative mode');
     fv_utility.log_mesg(l_select_stmt);
     fv_utility.log_mesg('gbl_sob_id: '||gbl_sob_id);
     fv_utility.log_mesg('gbl_coa_id: '||gbl_coa_id);
     fv_utility.log_mesg('gbl_period_num_low: '||gbl_period_num_low);
     fv_utility.log_mesg('gbl_period_num_high: '||gbl_period_num_high);
     fv_utility.log_mesg('gbl_period_year: '||gbl_period_year);
     fv_utility.log_mesg('gbl_currency_code: '||gbl_currency_code);


    OPEN l_gl_lines_cur FOR l_select_stmt using
      gbl_sob_id,gbl_period_num_low ,gbl_period_num_high,gbl_period_year,
      gbl_sob_id,gbl_sob_id, gbl_sob_id, gbl_coa_id,
      gbl_sob_id, gbl_period_year;

 END If;
log(l_module_name,'Before intializing the lists');
ccid_list_2 :=  ccid_t();
period_num_list_2 :=  period_num_t();
account_number_list_2 :=  account_number_t();
fund_value_list_2 :=  fund_value_t();
amount_list_2 :=  amount_t();
d_c_indicator_list_2 :=   d_c_indicator_t();
g_ng_indicator_list_2 :=  g_ng_indicator_t();
eliminations_dept_list_2 :=  eliminations_dept_t();
record_category_list_2 :=  record_category_t();
recipient_name_list_2 :=  recipient_name_t();
je_header_id_list_2 :=  je_header_id_t();
je_line_num_list_2 :=  je_line_num_t();
je_category_list_2 :=   je_category_t();
je_source_list_2 :=  je_source_t();
party_id_list_2 :=  party_id_t();
party_type_list_2 :=  party_type_t();
vendor_type_list_2 :=  vendor_type_t();
attribute_value_list_2 :=  attribute_val_t();
feeder_flag_list_2 :=  varchar_1_t();
gl_period_list_2 :=  gl_period_t();
log(l_module_name,'After intializing the lists');


  LOOP

    FETCH l_gl_lines_cur BULK COLLECT INTO
                ccid_list,
                sob_id_list,
                account_number_list,
                amount_list,
                d_c_indicator_list,
                je_header_id_list,
                je_line_num_list,
                je_category_list,
                je_source_list,
                reference_1_list,
                reference_2_list,
                reference_3_list,
                reference_5_list,
                reference_7_list,
                attribute_value_list,
                fund_value_list,
                gl_period_list,
                party_id_list,
                party_type_list,
                vendor_type_list,
                recipient_name_list,
                eliminations_dept_list,
                fed_nonfed_list,
                reported_status_list,
                record_category_list,
                feeder_flag_list,
                period_num_list,
                g_ng_indicator_list,
                je_from_sla_flag_list,
                je_batch_id_list
                LIMIT 10000;

     IF l_gl_lines_cur%NOTFOUND THEN
        l_last_fetch := TRUE;
     END IF;

     IF (je_header_id_list.count = 0 AND
            l_last_fetch) THEN
       EXIT;
     END IF;

/*log(l_module_name,'Before intializing the lists');
ccid_list_2 :=  ccid_t();
period_num_list_2 :=  period_num_t();
account_number_list_2 :=  account_number_t();
fund_value_list_2 :=  fund_value_t();
amount_list_2 :=  amount_t();
d_c_indicator_list_2 :=   d_c_indicator_t();
g_ng_indicator_list_2 :=  g_ng_indicator_t();
eliminations_dept_list_2 :=  eliminations_dept_t();
record_category_list_2 :=  record_category_t();
recipient_name_list_2 :=  recipient_name_t();
je_header_id_list_2 :=  je_header_id_t();
je_line_num_list_2 :=  je_line_num_t();
je_category_list_2 :=   je_category_t();
je_source_list_2 :=  je_source_t();
party_id_list_2 :=  party_id_t();
party_type_list_2 :=  party_type_t();
vendor_type_list_2 :=  vendor_type_t();
attribute_value_list_2 :=  attribute_val_t();
feeder_flag_list_2 :=  varchar_1_t();
gl_period_list_2 :=  gl_period_t();
log(l_module_name,'After intializing the lists');*/

     FOR i IN je_header_id_list.first .. je_header_id_list.last
        LOOP
              log(l_module_name,'----------------------------');
              log(l_module_name, 'Calling get_party_info with....');
              log(l_module_name, 'source: '||je_source_list(i));
              log(l_module_name, 'cat: '||je_category_list(i));
	            log(l_module_name, 'reference1: '||reference_1_list(i));
	            log(l_module_name, 'reference2: '||reference_2_list(i));
	            log(l_module_name, 'reference3: '||reference_3_list(i));
	            log(l_module_name, 'reference5: '||reference_5_list(i));
	            log(l_module_name, 'reference7: '||reference_7_list(i));
	            log(l_module_name, 'g ng ind: '||g_ng_indicator_list(i));
              log(l_module_name, 'je batch id '||je_batch_id_list(i));
              log(l_module_name, 'je header id '||je_header_id_list(i));
              log(l_module_name, 'je line num '||je_line_num_list(i));
              log(l_module_name, 'je from sla flag '||je_from_sla_flag_list(i));

           IF gbl_header_id < je_header_id_list(i) THEN
              gbl_header_id := je_header_id_list(i);
           END IF;

          get_party_info(
              je_category_list(i), je_source_list(i),
			        reference_1_list(i), reference_2_list(i),
			        reference_3_list(i), reference_5_list(i),
			        reference_7_list(i),
              substr(attribute_value_list(i),1,6), -- bug 5505974
              fed_nonfed_list(i),
              je_from_sla_flag_list(i),
              je_batch_id_list(i),
              je_header_id_list(i),
              je_line_num_list(i),
              d_c_indicator_list(i),
              l_party_info_tab);

             -- log(l_module_name,'records in party_info_tab: '||l_party_info_tab.COUNT);

              ccid_list_2.extend(l_party_info_tab.COUNT);
              period_num_list_2.extend(l_party_info_tab.COUNT);
              account_number_list_2.extend(l_party_info_tab.COUNT);
              fund_value_list_2.extend(l_party_info_tab.COUNT);
              amount_list_2.extend(l_party_info_tab.COUNT);
              d_c_indicator_list_2 .extend(l_party_info_tab.COUNT);
              g_ng_indicator_list_2.extend(l_party_info_tab.COUNT);
              eliminations_dept_list_2.extend(l_party_info_tab.COUNT);
              record_category_list_2.extend(l_party_info_tab.COUNT);
              recipient_name_list_2.extend(l_party_info_tab.COUNT);
              je_header_id_list_2.extend(l_party_info_tab.COUNT);
              je_line_num_list_2.extend(l_party_info_tab.COUNT);
              je_category_list_2 .extend(l_party_info_tab.COUNT);
              je_source_list_2.extend(l_party_info_tab.COUNT);
              party_id_list_2.extend(l_party_info_tab.COUNT);
              party_type_list_2.extend(l_party_info_tab.COUNT);
              vendor_type_list_2.extend(l_party_info_tab.COUNT);
              attribute_value_list_2.extend(l_party_info_tab.COUNT);
              feeder_flag_list_2.extend(l_party_info_tab.COUNT);
              gl_period_list_2.extend(l_party_info_tab.COUNT);

              FOR j IN l_party_info_tab.FIRST .. l_party_info_tab.LAST LOOP
              --FOR j IN 1 .. party_info_tab.COUNT LOOP
                  ccid_list_2(k) := ccid_list(i);
                  period_num_list_2(k) := period_num_list(i);
                  account_number_list_2(k) := account_number_list(i);
                  fund_value_list_2(k) := fund_value_list(i);

                  IF (NVL(je_from_sla_flag_list(i),'N') <> 'Y' OR
                         gbl_manual_source_flag = 'Y') THEN
                     amount_list_2(k) := amount_list(i);
                   ELSE
                     amount_list_2(k) := l_party_info_tab(j).party_line_amount;
                  END IF;

                  d_c_indicator_list_2(k) := d_c_indicator_list(i);
                  g_ng_indicator_list_2(k) := l_party_info_tab(j).g_ng_indicator;
                  eliminations_dept_list_2(k) := l_party_info_tab(j).elim_dept;
                  record_category_list_2(k) := l_party_info_tab(j).record_category;
                  recipient_name_list_2(k) := l_party_info_tab(j).recipient_name;
                  je_header_id_list_2(k) := je_header_id_list(i);

fv_utility.log_mesg('je_header_id_list(i): '||je_header_id_list(i));

                  je_line_num_list_2(k) := je_line_num_list(i);
                  je_category_list_2(k) := je_category_list(i);
                  je_source_list_2(k) := je_source_list(i);
                  party_id_list_2(k) := l_party_info_tab(j).party_id;
                  party_type_list_2(k) := l_party_info_tab(j).cust_vend_type;
                  vendor_type_list_2(k) := l_party_info_tab(j).vendor_type;
                  attribute_value_list_2(k) := attribute_value_list(i);
                  feeder_flag_list_2(k) := l_party_info_tab(j).feeder_flag;
                  gl_period_list_2(k) := gl_period_list(i);

                  k := k+1;


              END LOOP;

          IF gbl_err_code <> 0 THEN
              RETURN;
          END IF;
        END LOOP;

     FORALL i IN je_header_id_list_2.first .. je_header_id_list_2.last


        INSERT INTO fv_facts1_line_balances
            (   ccid,
                period_num,
                set_of_books_id,
                period_year,
                account_number,
                fund_value,
                amount,
                d_c_indicator,
                g_ng_indicator,
                eliminations_dept,
                record_category,
                recipient_name,
                period_name,
                je_header_id,
                je_line_num,
                je_category,
                je_source,
                party_id,
                party_type,
                party_classification,
                attribute_value,
                balance_type,
                feeder_flag,
                gl_period,
                creation_date)
         VALUES (
                ccid_list_2(i),
                period_num_list_2(i),
                gbl_sob_id,
                gbl_period_year,
                account_number_list_2(i),
                fund_value_list_2(i),
                amount_list_2(i),
                d_c_indicator_list_2(i),
                g_ng_indicator_list_2(i),
                eliminations_dept_list_2(i),
                record_category_list_2(i),
                recipient_name_list_2(i),
                gbl_period_name,
                je_header_id_list_2(i),
                je_line_num_list_2(i),
                je_category_list_2(i),
                je_source_list_2(i),
                party_id_list_2(i),
                party_type_list_2(i),
                vendor_type_list_2(i),
                attribute_value_list_2(i),
                'L',
                feeder_flag_list_2(i),
                gl_period_list_2(i),
                sysdate);


   IF gbl_called_from_main = 'Y'  THEN
-- Eliminating the duplicate JE_HEADER_IDs
	je_header_id_list_new := je_header_id_t();
    for i in je_header_id_list_2.first .. je_header_id_list_2.last loop
        flg := false;
        for j in 1 .. je_header_id_list_new.count loop
            if je_header_id_list_2(i) =je_header_id_list_new(j) then
                 flg := true;
            end if;
        end loop;
        if flg  <> true then
           je_header_id_list_new.extend;
           je_header_id_list_new(je_header_id_list_new.count) := je_header_id_list_2(i);
        end if;
    end loop;

    FORALL i IN je_header_id_list_new.first .. je_header_id_list_new.last
        INSERT INTO fv_facts1_header_id_gt
            (   je_header_id,
                set_of_books_id)
         VALUES
            (je_header_id_list_new(i),
             gbl_sob_id);
   END IF;

 END LOOP;

     close l_gl_lines_cur ;


 EXCEPTION
      WHEN OTHERS THEN
           gbl_err_code := SQLCODE;
           gbl_err_buff := l_module_name||' - When others error: '||SQLERRM;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_err_buff);
END process_gl_lines;
--------------------------------------------------------------------------------
PROCEDURE GET_PARTY_INFO(p_category     IN VARCHAR2,
         	         p_source        IN VARCHAR2,
         	         p_reference_1   IN VARCHAR2,
         	         p_reference_2   IN VARCHAR2,
         	         p_reference_3   IN VARCHAR2,
         	         p_reference_5   IN VARCHAR2,
         	         p_reference_7   IN VARCHAR2,
                   p_jrnl_attribute IN VARCHAR2,
                   p_fed_nonfed    IN VARCHAR2,
                   p_je_from_sla_flag IN VARCHAR2,
                   p_je_batch_id   IN NUMBER,
                   p_je_header_id  IN NUMBER,
                   p_je_line_num   IN NUMBER,
                   p_jrnl_dc_ind   IN VARCHAR2,
                   p_party_info_tab OUT NOCOPY party_info_table)
IS

l_module_name VARCHAR2(200);
ln_jrnl_att          Varchar2(240);

i                    Integer;
l_vendor_id          Number;
l_appl_id            Number(15);
l_vendor_type        Varchar2(30);
l_reported_status    Varchar2(2);
l_record_category    Varchar2(25);

l_valid_flag         Varchar2(2);
l_feeder_flag        Varchar2(1);



-- Variables for Dynamic Cursor


l_recipient_name       po_vendors.vendor_name%type ;
l_elim_dept            VARCHAR2(6);

l_govt_non_govt_ind VARCHAR2(1);

--l_reference_2 gl_je_lines.reference_1%TYPE;
--l_reference_5 gl_je_lines.reference_1%TYPE;
--l_reference_7 gl_je_lines.reference_1%TYPE;

l_be_trx_id NUMBER;

party_info_tab party_info_table;
l_cust_vend_type VARCHAR2(1);

BEGIN

   l_module_name := g_module_name || 'GET_PARTY_INFO';

   log(l_module_name,'IN: '||l_module_name);

   log(l_module_name,'***Parameters*** ');
   log(l_module_name,'p_source: '||p_source);
   log(l_module_name,'p_reference_1: '||p_reference_1);
   log(l_module_name,'p_reference_2: '||p_reference_2);
   log(l_module_name,'p_reference_3: '||p_reference_3);
   log(l_module_name,'p_reference_5: '||p_reference_5);
   log(l_module_name,'p_reference_7: '||p_reference_7);
   log(l_module_name,'p_jrnl_attribute: '||p_jrnl_attribute);
   log(l_module_name,'p_fed_nonfed: '||p_fed_nonfed);
   log(l_module_name,'p_je_from_sla_flag: '||p_je_from_sla_flag);
   log(l_module_name,'p_je_batch_id: '||p_je_batch_id);
   log(l_module_name,'p_je_header_id: '||p_je_header_id);
   log(l_module_name,'p_je_line_num: '||p_je_line_num);
   log(l_module_name,'p_jrnl_dc_ind: '||p_jrnl_dc_ind);


   ln_jrnl_att := p_jrnl_attribute;
   l_govt_non_govt_ind := p_fed_nonfed;
   l_reported_status := 'R';
   l_valid_flag := 'Y';
   l_feeder_flag := 'Y';
   gbl_manual_source_flag := 'N';

   BEGIN

      -------------------------------------------------------------------
      -- get the vendor id from Payables (Includes invoice and Payments)
      ------------------------------------------------------------------
      IF (p_source = 'Payables' ) THEN
         --AND p_category <> 'Treasury Confirmation') THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,P_SOURCE);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'REFERENCE 2: '|| P_REFERENCE_2);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                  'p_je_from_sla_flag: '||p_je_from_sla_flag);
         END IF;

         BEGIN

            IF p_je_from_sla_flag = 'Y' THEN
               get_reference_column ('AP_PAYMENTS',
                                   p_je_batch_id ,
                                   p_je_header_id ,
                                   p_je_line_num ,
                                   200,
                                   p_jrnl_dc_ind,
                                   party_info_tab);

                IF gbl_err_code <> 0 THEN
                   RETURN;
                END IF;

              ELSIF (p_reference_2 IS NOT NULL) THEN
                    SELECT v.vendor_id, v.vendor_type_lookup_code,
                       DECODE(gbl_vend_attribute, 'ATTRIBUTE1', V.ATTRIBUTE1,
                       'ATTRIBUTE2', V.ATTRIBUTE2, 'ATTRIBUTE3', V.ATTRIBUTE3,
                       'ATTRIBUTE4', V.ATTRIBUTE4, 'ATTRIBUTE5', V.ATTRIBUTE5,
                       'ATTRIBUTE6', V.ATTRIBUTE6, 'ATTRIBUTE7', V.ATTRIBUTE7,
                       'ATTRIBUTE8', V.ATTRIBUTE8, 'ATTRIBUTE9', V.ATTRIBUTE9,
                       'ATTRIBUTE10', V.ATTRIBUTE10, 'ATTRIBUTE11', V.ATTRIBUTE11,
                       'ATTRIBUTE12', V.ATTRIBUTE12, 'ATTRIBUTE13', V.ATTRIBUTE13,
                       'ATTRIBUTE14', V.ATTRIBUTE14, 'ATTRIBUTE15', V.ATTRIBUTE15)
                       eliminations_id,
 		                   v.vendor_name
                    INTO   l_vendor_id, l_vendor_type,
                           l_elim_dept,
                           l_recipient_name
                    FROM   ap_invoices_all i,
                           po_vendors v
                    WHERE  i.invoice_id  = to_number(p_reference_2)
                    AND    i.vendor_id   = v.vendor_id;

                   l_cust_vend_type := 'V';

           ELSE
               l_recipient_name := 'Other';
               IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                  'REFERENCE_2 I.E. INVOICE_ID IS NULL');
               END IF;


          END IF;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
                'NO DATA FOUND FOR SOURCE = PAYABLES !!');
                            l_recipient_name := 'Other';

         END;

     -------------------------------------------------------------------
     -- Get the Vendor ID for Purchasing Inventory Records
     ------------------------------------------------------------------
      ELSIF (p_source in ('Purchasing' , 'Cost Management') AND p_category <> 'Requisitions') THEN
         IF (p_category = 'Receiving') THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'REFERENCE 2: '|| P_REFERENCE_2);
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'REFERENCE 5: '|| P_REFERENCE_5);
            END IF;
            BEGIN

                 IF p_je_from_sla_flag = 'Y' THEN
                     l_appl_id := 201;
                      if (p_source = 'Cost Management') then
                       l_appl_id := 707;
                      End if;
                    get_reference_column ('PURCHASE_ORDER',
                                      p_je_batch_id ,
                                      p_je_header_id ,
                                      p_je_line_num ,
                                      l_appl_id,
                                      p_jrnl_dc_ind,
                                      party_info_tab);
                    IF gbl_err_code <> 0 THEN
                       RETURN;
                    END IF;

                  ELSIF (p_reference_2 IS NOT NULL AND p_reference_5 IS NOT NULL) THEN
                       SELECT v.vendor_id,
                              v.vendor_type_lookup_code,
                              DECODE(gbl_vend_attribute, 'ATTRIBUTE1', V.ATTRIBUTE1,
                              'ATTRIBUTE2', V.ATTRIBUTE2, 'ATTRIBUTE3', V.ATTRIBUTE3,
                              'ATTRIBUTE4', V.ATTRIBUTE4, 'ATTRIBUTE5', V.ATTRIBUTE5,
                              'ATTRIBUTE6', V.ATTRIBUTE6, 'ATTRIBUTE7', V.ATTRIBUTE7,
                              'ATTRIBUTE8', V.ATTRIBUTE8, 'ATTRIBUTE9', V.ATTRIBUTE9,
                              'ATTRIBUTE10', V.ATTRIBUTE10, 'ATTRIBUTE11', V.ATTRIBUTE11,
                              'ATTRIBUTE12', V.ATTRIBUTE12, 'ATTRIBUTE13', V.ATTRIBUTE13,
                              'ATTRIBUTE14', V.ATTRIBUTE14, 'ATTRIBUTE15', V.ATTRIBUTE15)
                              eliminations_id, v.vendor_name
                         INTO   l_vendor_id, l_vendor_type, l_elim_dept,
                                l_recipient_name
                         FROM   rcv_transactions rt,
                                po_vendors v,
                                po_headers_all ph
                         WHERE rt.po_header_id   = to_number(p_reference_2)
                         AND   rt.transaction_id = to_number(p_reference_5)
                         AND   rt.po_header_id   = ph.po_header_id
                         AND   v.vendor_id       = ph.vendor_id;

                         l_cust_vend_type := 'V';

                  ELSE
                         IF (p_reference_2 IS NULL) THEN
                            l_recipient_name := 'Other';
                            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                               'REFERENCE_2 I.E. PO_HEADER_ID IS NULL');
                            END IF;
                          ELSE
                            l_recipient_name := 'Other';
                            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                              'REFERENCE_5 I.E. TRANSACTION_ID IS NULL');
                            END IF;
                         END IF;

                 END IF;
             EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
                       'NO DATA FOUND WHEN SOURCE IS PURCHASING AND CATEGORY IS RECEIVING!!');

                     l_recipient_name := 'Other';
            END;

          ELSIF (p_category in ('Purchases', 'Release')) THEN
              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'REFERENCE 2: '|| P_REFERENCE_2);
              END IF;
              BEGIN
                   IF p_je_from_sla_flag = 'Y' THEN
                      get_reference_column ('PURCHASE_ORDER',
                                      p_je_batch_id ,
                                      p_je_header_id ,
                                      p_je_line_num ,
                                      201,
                                      p_jrnl_dc_ind,
                                      party_info_tab);
                       IF gbl_err_code <> 0 THEN
                          RETURN;
                       END IF;

                    ELSIF (p_reference_2 IS NOT NULL) THEN
                       SELECT v.vendor_id,
                              v.vendor_type_lookup_code,
                              DECODE(gbl_vend_attribute, 'ATTRIBUTE1', V.ATTRIBUTE1,
                              'ATTRIBUTE2', V.ATTRIBUTE2, 'ATTRIBUTE3', V.ATTRIBUTE3,
                              'ATTRIBUTE4', V.ATTRIBUTE4, 'ATTRIBUTE5', V.ATTRIBUTE5,
                              'ATTRIBUTE6', V.ATTRIBUTE6, 'ATTRIBUTE7', V.ATTRIBUTE7,
                              'ATTRIBUTE8', V.ATTRIBUTE8, 'ATTRIBUTE9', V.ATTRIBUTE9,
                              'ATTRIBUTE10', V.ATTRIBUTE10, 'ATTRIBUTE11', V.ATTRIBUTE11,
                              'ATTRIBUTE12', V.ATTRIBUTE12, 'ATTRIBUTE13', V.ATTRIBUTE13,
                              'ATTRIBUTE14', V.ATTRIBUTE14,
                              'ATTRIBUTE15', V.ATTRIBUTE15) eliminations_id,
                              v.vendor_name
                       INTO   l_vendor_id,
                              l_vendor_type,
                              l_elim_dept,
                              l_recipient_name
                       FROM   po_vendors v, po_headers_all poh
                       WHERE poh.po_header_id = to_number(p_reference_2)
                       AND   v.vendor_id = poh.vendor_id;

                       l_cust_vend_type := 'V';

                    ELSE
                       l_recipient_name := 'Other';

                       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                          'REFERENCE_2 I.E. PO HEADER ID IS NULL');
                       END IF;

                   END IF;

                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
                       'NO DATA FOUND WHEN SOURCE IS PURCHASING AND CATEGORY IS PURCHASES!!');

                       l_recipient_name := 'Other';
              END;

            end if;
      -----------------------------------------------------------
      -- Customer id for Receivables transactions
      -----------------------------------------------------------
      ELSIF (p_source = 'Receivables') THEN
         log(l_module_name, 'REFERENCE 7: '|| P_REFERENCE_7);
         BEGIN
              IF p_je_from_sla_flag = 'Y' THEN
                get_reference_column ('RECEIPTS',
                                      p_je_batch_id ,
                                      p_je_header_id ,
                                      p_je_line_num ,
                                      222,
                                      p_jrnl_dc_ind,
                                      party_info_tab);
                       IF gbl_err_code <> 0 THEN
                          RETURN;
                       END IF;

               ELSIF (p_reference_7 IS NOT NULL) THEN
                     l_vendor_id := p_reference_7;
                     SELECT c.customer_class_code,
                       DECODE(gbl_cust_attribute, 'ATTRIBUTE1', C.ATTRIBUTE1,
                       'ATTRIBUTE2', C.ATTRIBUTE2, 'ATTRIBUTE3', C.ATTRIBUTE3,
                       'ATTRIBUTE4', C.ATTRIBUTE4, 'ATTRIBUTE5', C.ATTRIBUTE5,
                       'ATTRIBUTE6', C.ATTRIBUTE6, 'ATTRIBUTE7', C.ATTRIBUTE7,
                       'ATTRIBUTE8', C.ATTRIBUTE8, 'ATTRIBUTE9', C.ATTRIBUTE9,
                       'ATTRIBUTE10', C.ATTRIBUTE10, 'ATTRIBUTE11', C.ATTRIBUTE11,
                       'ATTRIBUTE12', C.ATTRIBUTE12, 'ATTRIBUTE13', C.ATTRIBUTE13,
                       'ATTRIBUTE14', C.ATTRIBUTE14,
                       'ATTRIBUTE15', C.ATTRIBUTE15) eliminations_id,
                      c.account_name
                    INTO l_vendor_type, l_elim_dept, l_recipient_name
                    FROM hz_cust_accounts_all c
                    WHERE c.cust_account_id = to_number(p_reference_7);

                     l_cust_vend_type := 'C';
               ELSE
                     l_recipient_name := 'Other';
                     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'REFERENCE_7 I.E. CUSTOMER_ID IS NULL');
                     END IF;
              END IF;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   l_recipient_name := 'Other';
                   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,
                        l_module_name,'NO DATA FOUND WHEN SOURCE IS RECEIVABLES!!');
         END;
      --------------------------------------------------------------------
      -- Vendor id for TC transactions
      --------------------------------------------------------------------
      ELSIF (p_source = 'Budgetary Transaction' AND
             p_category = 'Treasury Confirmation') THEN

         log(l_module_name, 'Source: '||P_SOURCE);
         log(l_module_name, 'REFERENCE 3: '|| P_REFERENCE_3);
         BEGIN
           IF p_je_from_sla_flag = 'Y' THEN
              get_reference_column ('TR_CONFIRM',
                                      p_je_batch_id ,
                                      p_je_header_id ,
                                      p_je_line_num ,
                                      8901,
                                      p_jrnl_dc_ind,
                                      party_info_tab);
                       IF gbl_err_code <> 0 THEN
                          RETURN;
                       END IF;
             ELSIF (p_reference_3 IS NOT NULL) THEN
               l_feeder_flag := 'Y';
               SELECT v.vendor_id,
                      v.vendor_type_lookup_code,
                       DECODE(gbl_vend_attribute, 'ATTRIBUTE1', V.ATTRIBUTE1,
                       'ATTRIBUTE2', V.ATTRIBUTE2, 'ATTRIBUTE3', V.ATTRIBUTE3,
                       'ATTRIBUTE4', V.ATTRIBUTE4, 'ATTRIBUTE5', V.ATTRIBUTE5,
                       'ATTRIBUTE6', V.ATTRIBUTE6, 'ATTRIBUTE7', V.ATTRIBUTE7,
                       'ATTRIBUTE8', V.ATTRIBUTE8, 'ATTRIBUTE9', V.ATTRIBUTE9,
                       'ATTRIBUTE10', V.ATTRIBUTE10, 'ATTRIBUTE11', V.ATTRIBUTE11,
                       'ATTRIBUTE12', V.ATTRIBUTE12, 'ATTRIBUTE13', V.ATTRIBUTE13,
                       'ATTRIBUTE14', V.ATTRIBUTE14,
                       'ATTRIBUTE15', V.ATTRIBUTE15) eliminations_id,
                       v.vendor_name
               INTO l_vendor_id, l_vendor_type, l_elim_dept,
                    l_recipient_name
               FROM ap_checks_all apc,
                    po_vendors v
               WHERE  apc.vendor_id = v.vendor_id
               AND    apc.check_id  = to_number(p_reference_3);

               l_cust_vend_type := 'V';

             ELSE
               l_recipient_name := 'Other';
               IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                 'REFERENCE_3 I.E. CHECK_ID IS NULL');
               END IF;
           END IF;

          EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  l_recipient_name := 'Other';
                 log(l_module_name,
                     'NO DATA FOUND WHEN SOURCE = PAYABLES AND
                      CATEGORY = TREASURY CONFIRMATION !!');
         END;
      --------------------------------------------------------------------
      -- Vendor id for Budgetary transactions
      --------------------------------------------------------------------
      ELSIF (p_source = 'Budgetary Transaction' AND
             p_category <> 'Treasury Confirmation') THEN
          log(l_module_name,'Source: '||p_source);
         BEGIN
            l_feeder_flag := 'Y';
            IF p_je_from_sla_flag = 'Y' THEN
                get_reference_column ('BE_TRANSACTIONS',
                                      p_je_batch_id ,
                                      p_je_header_id ,
                                      p_je_line_num ,
                                      8901,
                                      p_jrnl_dc_ind,
                                      party_info_tab);
                  IF gbl_err_code <> 0 THEN
                     RETURN;
                  END IF;

            ELSE
                SELECT decode(gbl_trading_partner_att,
                      null , dept_id|| main_account,
                                     SUBSTR(DECODE(upper(gbl_trading_partner_att),
                                           'ATTRIBUTE1', attribute1,
                                           'ATTRIBUTE2', attribute2,
                                           'ATTRIBUTE3', attribute3,
                                           'ATTRIBUTE4', attribute4,
                                           'ATTRIBUTE5', attribute5,
                                           'ATTRIBUTE6', attribute6,
                                           'ATTRIBUTE7', attribute7,
                                           'ATTRIBUTE8', attribute8,
                                           'ATTRIBUTE9', attribute9,
                                           'ATTRIBUTE10', attribute10,
                                           'ATTRIBUTE11', attribute11,
                                           'ATTRIBUTE12', attribute12,
                                           'ATTRIBUTE13', attribute13,
                                           'ATTRIBUTE14', attribute14,
                                           'ATTRIBUTE15', attribute15),1,6))
                INTO l_elim_dept
                FROM fv_be_trx_dtls
                WHERE transaction_id = l_be_trx_id;

                IF (l_elim_dept IS NOT NULL) THEN
                   l_vendor_id := l_elim_dept;
                   l_vendor_type := 'FEDERAL';
                END IF;

                l_recipient_name := 'Other';
          END IF;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
                'NO DATA FOUND WHEN SOURCE = BUDGETARY TRANSACTION');
        END;

      ELSIF (l_govt_non_govt_ind = 'Y') THEN
       log(l_module_name , 'Falls on Manual source as govt non govt = Y');
         IF (ln_jrnl_att is NOT NULL) THEN
            l_elim_dept := ln_jrnl_att;
         ELSE
            l_elim_dept := NULL;
         END IF;
         l_feeder_flag := 'N';
         gbl_manual_source_flag := 'Y';

      ELSIF (l_govt_non_govt_ind = 'F') THEN
       log(l_module_name , 'Falls on Manual source as govt non govt = F');
         IF (ln_jrnl_att is NOT NULL) THEN
            l_elim_dept := ln_jrnl_att;
         ELSE
            l_elim_dept := '00';
         END IF;
         l_feeder_flag := 'N';
         gbl_manual_source_flag := 'Y';

      ELSE
        l_valid_flag := 'N'; --  all the process ends here
      END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_valid_flag := 'Y';
     WHEN Invalid_Number OR Value_Error THEN
        l_valid_flag := 'Y';
   END;

   IF l_recipient_name IS NULL THEN
      l_recipient_name := 'Other';
   END IF;

       -- If the record is not from sla (ie. upgraded records)
       -- OR if the record is from a manual journal source -- for bug 6782416
   IF (NVL(p_je_from_sla_flag,'N') <> 'Y' OR
      gbl_manual_source_flag = 'Y') THEN
       log(l_module_name, 'Not sla journal or it is a manual journal - creating 1 record');
       party_info_tab.delete;
       party_info_tab(1).party_id        := l_vendor_id;
       party_info_tab(1).vendor_type     := l_vendor_type;
       party_info_tab(1).recipient_name  := l_recipient_name;
       if (l_elim_dept is not null) then
         party_info_tab(1).elim_dept       := substr(l_elim_dept,1,6);
       else
         party_info_tab(1).elim_dept       := null;
       End if;
       party_info_tab(1).feeder_flag     := l_feeder_flag;
       party_info_tab(1).cust_vend_type  := l_cust_vend_type;
   END IF;

   IF l_valid_flag = 'Y' THEN -- valid Flag

      FOR i IN party_info_tab.FIRST..party_info_tab.LAST LOOP

         -- If there is a standard journal and we don't find the vendor/customer and
         -- therefore cannot determine the eliminations id, we should use the journal
         -- trading partner descriptive flexfield value.
         IF (party_info_tab(i).feeder_flag = 'Y') THEN
            IF (party_info_tab(i).party_id IS NULL) THEN
               IF (gbl_jrnl_attribute IS NOT NULL) THEN
                  party_info_tab(i).elim_dept := ln_jrnl_att;
               END IF;
            END IF;
         END IF;

     IF (party_info_tab(i).party_id IS NULL) THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
            l_module_name, 'VENDOR ID IS NULL');
        END IF;
        IF ((l_govt_non_govt_ind = 'F' AND l_feeder_flag = 'Y') OR
             (l_govt_non_govt_ind = 'F' AND l_feeder_flag = 'N'
                AND party_info_tab(i).elim_dept = '00')) THEN
            IF (party_info_tab(i).elim_dept IS NULL OR
                party_info_tab(i).elim_dept = '00') THEN
                   party_info_tab(i).reported_status := 'W';
                   party_info_tab(i).record_category := 'NO_VENDOR';
                   party_info_tab(i).elim_dept := '00';
             ELSE
                   party_info_tab(i).record_category := 'REPORTED';
            END IF;

            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'Recipient Name: ' || party_info_tab(i).recipient_name);
            END IF;

         --  Govt Non Govt Indicator = Y
         ELSIF ((l_govt_non_govt_ind = 'Y' AND l_feeder_flag = 'Y') OR
                (l_govt_non_govt_ind = 'Y' AND l_feeder_flag = 'N')) THEN
            IF (party_info_tab(i).elim_dept IS NULL) THEN
                   party_info_tab(i).reported_status := 'W';
                   party_info_tab(i).record_category := 'NO_VENDOR';
                   party_info_tab(i).elim_dept := '  ';
                   party_info_tab(i).g_ng_indicator   := 'N';
             ELSE
                   party_info_tab(i).reported_status := 'R';
                   party_info_tab(i).record_category := 'REPORTED';
                   party_info_tab(i).g_ng_indicator   := 'F';
            END IF;

            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'Recipient Name: ' || party_info_tab(i).recipient_name);
            END IF;

        END IF;  -- Govt Non Govt = F or Y

     ELSE  -- l_vendor_id IS NOT NULL

        IF (l_feeder_flag = 'Y') THEN
           IF (l_govt_non_govt_ind = 'F' AND
               (UPPER(party_info_tab(i).vendor_type) <> 'FEDERAL' OR
                 party_info_tab(i).vendor_type IS NULL)) THEN
              IF (party_info_tab(i).elim_dept IS NULL) THEN
                    party_info_tab(i).reported_status := 'W';
 		                party_info_tab(i).record_category := 'G_NONFED_VENDOR';
                    party_info_tab(i).elim_dept := '00';
               ELSE
                    party_info_tab(i).reported_status := 'W';
 		                party_info_tab(i).record_category := 'G_NONFED_VENDOR';
              END IF;

              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                  '                        RECIPIENT NAME: ' || party_info_tab(i).RECIPIENT_NAME);
              END IF;

            ELSIF (l_govt_non_govt_ind = 'F' and party_info_tab(i).elim_dept IS NULL) THEN

                 party_info_tab(i).reported_status := 'R';
                 party_info_tab(i).elim_dept := '00';
                 --l_govt_non_govt_ind   := 'F';
                 party_info_tab(i).g_ng_indicator := 'F';
                 party_info_tab(i).record_category := 'REPORTED';

              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     '                        RECIPIENT NAME: ' || party_info_tab(i).RECIPIENT_NAME);
              END IF;

            ELSIF (l_govt_non_govt_ind = 'F' and party_info_tab(i).elim_dept IS NOT NULL) THEN
                  party_info_tab(i).reported_status := 'R';
                  party_info_tab(i).record_category := 'REPORTED';
                  --l_govt_non_govt_ind   := 'F';
                  party_info_tab(i).g_ng_indicator := 'F';
              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       '                        GNG: F');
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                      '                        RECIPIENT NAME: ' || party_info_tab(i).RECIPIENT_NAME);
              END IF;

            ELSIF (l_govt_non_govt_ind = 'Y' AND
                  (UPPER(party_info_tab(i).vendor_type) <> 'FEDERAL' OR
                   party_info_tab(i).vendor_type IS NULL)) THEN
                     party_info_tab(i).reported_status := 'R';
                     party_info_tab(i).record_category := 'REPORTED';
                     --l_govt_non_govt_ind   := 'N';
                     party_info_tab(i).g_ng_indicator := 'N';
                     party_info_tab(i).elim_dept := '  ';

               IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                '                        RECIPIENT NAME: ' || party_info_tab(i).RECIPIENT_NAME);
               END IF;

            ELSIF (l_govt_non_govt_ind = 'Y' and party_info_tab(i).elim_dept IS NULL) THEN

               party_info_tab(i).reported_status := 'R';
               party_info_tab(i).record_category := 'REPORTED';
               --l_govt_non_govt_ind   := 'F';
               party_info_tab(i).g_ng_indicator := 'F';
               party_info_tab(i).elim_dept := '00';

               IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   '                         RECIPIENT NAME: ' || party_info_tab(i).RECIPIENT_NAME);
               END IF;

            ELSIF (l_govt_non_govt_ind = 'Y' and party_info_tab(i).elim_dept IS NOT NULL) THEN

               party_info_tab(i).reported_status := 'R';
               party_info_tab(i).record_category := 'REPORTED';
               --l_govt_non_govt_ind   := 'F';
               party_info_tab(i).g_ng_indicator := 'F';

               IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                           '                     IN VIEW');
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                           '                        VENDOR ID IS NOT NULL (' || party_info_tab(i).party_ID || ')');
                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                              '                        ELIMINATIONS ID IS NOT NULL');
                END IF;

           END IF; -- l_govt_non_govt_ind
        END IF; -- l_feeder_flag
    END IF; -- l_vendor_id

      IF (l_feeder_flag = 'N') THEN
         IF (l_govt_non_govt_ind = 'F' AND
             party_info_tab(i).elim_dept <> '00' AND
             party_info_tab(i).elim_dept IS NOT NULL)
         THEN
             party_info_tab(i).reported_status := 'R';
             --l_govt_non_govt_ind   := 'F';
             party_info_tab(i).g_ng_indicator := 'F';
             party_info_tab(i).record_category := 'REPORTED';

             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                      '                     IN VIEW');
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                      '                        ELIMINATIONS ID IS NOT NULL');
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                      '                        RECIPIENT NAME: ' || party_info_tab(i).RECIPIENT_NAME);
             END IF;

        END IF; -- l_govt_non_govt_ind
      END IF; -- l_feeder_system

        log(l_module_name, 'Ending get_party_info with....');
        log(l_module_name, 'party_id        :'|| party_info_tab(i).party_id);
        log(l_module_name, 'p_vendor_type     :'||party_info_tab(i).vendor_type);
        log(l_module_name, 'p_recipient_name  :'||party_info_tab(i).recipient_name);
        log(l_module_name, 'p_elim :'||party_info_tab(i).elim_dept);
        log(l_module_name, 'p_reported_status :'||party_info_tab(i).reported_status);
        log(l_module_name, 'p_record_category :'||party_info_tab(i).record_category);
        log(l_module_name, 'p_feeder_flag :'||party_info_tab(i).feeder_flag);



    END LOOP;
        p_party_info_tab := party_info_tab;
   END IF;   -- l_valid_flag
/*
  p_party_id        := l_vendor_id;
  p_vendor_type     := l_vendor_type;
  p_recipient_name  := l_recipient_name;
  p_elim_dept       := substr(l_elim_dept,1,6);
  p_reported_status := l_reported_status;
  p_record_category := l_record_category;
  p_feeder_flag     := l_feeder_flag;
  p_g_ng_indicator  := l_govt_non_govt_ind;
*/

 EXCEPTION
  WHEN OTHERS THEN
    gbl_err_code := 2 ;
    gbl_err_buff := 'GET_PARTY_INFO - Exception (Others) - ' ||
                     to_char(SQLCODE) || ' - ' || SQLERRM;

    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
         '.final_exception',gbl_err_buff);

END get_party_info;
--------------------------------------------------------------------------------
PROCEDURE INSERT_EXCEPTION_RECS
IS

l_module_name VARCHAR2(100);
l_stmt varchar2(5000);
BEGIN

    l_module_name :=  g_module_name||'INSERT_EXCEPTION_RECS';
    FV_UTILITY.LOG_MESG('In '||l_module_name);
    gbl_exception_rec_count := 0;

   fnd_file.put_line(fnd_file.output , 'Set of books id ' || gbl_sob_id || rpad(' ', 70)  || ' Period : ' ||  gbl_period_name);

   fnd_file.put_line(fnd_file.output , ' Fact-1 Journals that do not have Vendor/Supplier information or Vendor/Customer type is NON FEDERAL  ');
   fnd_file.put_line(fnd_file.output , '---------------------------------------- ----------------------------------------------------------');
   fnd_file.put_line(fnd_file.output ,rpad('Exception' , 15) || rpad('Batch Name', 41) || rpad('Category' , 16) || rpad('Account',10) || rpad('Fund ', 21) || '               Amount' );

fnd_file.put_line(fnd_file.output,' ');

l_stmt := ' select substr(rpad(l.record_category, 14,'' ''),1,14) || '' '' ||
               substr(rpad(b.name, 40,  '' ''),1,40) || '' '' ||
               substr(rpad(h.je_category, 15,  '' ''),1,15) || '' '' ||
               substr(rpad(l.account_number, 9,  '' ''),1,9) || '' '' ||
               substr(rpad(l.fund_value, 20,  '' ''),1,20) || '' '' ||
              to_char( amount,''99,999,999,999,999,999.99'') ' ||
                  ' FROM   fv_facts1_header_id_gt f ,
                           gl_je_headers h,
                           fv_facts1_line_balances  l,
                           gl_je_batches b
        where h.je_header_id = f.je_header_id
        and    l.je_header_id = h.je_header_id
        and    l.record_category IN (''NO_VENDOR'', ''G_NONFED_VENDOR'')
         AND   l.set_of_books_id = ' || gbl_sob_id  || '
         AND   l.period_year = ' || gbl_period_year || '
         and   b.je_batch_id = h.je_batch_id
      ORDER BY l.record_category, h.je_category ';

     fv_flatfiles.create_flat_file(l_stmt);

 EXCEPTION WHEN OTHERS THEN
     gbl_err_code := 2 ;
     gbl_err_buff := l_module_name||' - When others exception - ' ||
                     to_char(SQLCODE) || ' - ' || SQLERRM;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
         gbl_err_buff);

END insert_exception_recs;
--------------------------------------------------------------------------------
PROCEDURE SUBMIT_EXCEPTION_REPORT
IS
l_req_id 	      NUMBER(15);


call_status           BOOLEAN;

rphase                VARCHAR2(80);
rstatus               VARCHAR2(80);
dphase                VARCHAR2(80);
dstatus               VARCHAR2(80);
message               VARCHAR2(80);
l_module_name         VARCHAR2(80) ;
l_run_mode            VARCHAR2(80) ;

BEGIN

    l_module_name :=  g_module_name||'SUBMIT_EXCEPTION_REPORT';
    FV_UTILITY.LOG_MESG('In '||l_module_name);

    l_run_mode := 'Fiscal Year';



    FV_UTILITY.LOG_MESG(l_module_name|| ' Launching FACTS I exception report ...');
    FV_UTILITY.LOG_MESG(l_module_name|| ' l_run_mode: '||l_run_mode);
    FV_UTILITY.LOG_MESG(l_module_name|| ' gbl_period_year: '||gbl_period_year);
    FV_UTILITY.LOG_MESG(l_module_name|| ' gbl_sob_id: '||gbl_sob_id);
    FV_UTILITY.LOG_MESG(l_module_name|| ' gbl_period_name: '||gbl_period_name);

    l_req_id := FND_REQUEST.SUBMIT_REQUEST
                 ('FV','FVFACTSE','','',FALSE, l_run_mode, gbl_period_year,
                   gbl_sob_id, gbl_period_name);

    -- If concurrent request submission failed, abort process
    FV_UTILITY.LOG_MESG(l_module_name|| ' Request ID for exception report = '|| TO_CHAR(L_REQ_ID));

    IF (l_req_id = 0) THEN
          gbl_err_code := '2';
          gbl_err_buff := 'Cannot submit FACTS Exception report';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_err_buff);
          RETURN;
     ELSE
          COMMIT;
          call_status := Fnd_concurrent.Wait_for_request(l_req_id, 20, 0,
                                                rphase, rstatus,
                                                dphase, dstatus, message);
          IF call_status = FALSE THEN
             gbl_err_buff := 'Cannot wait for the status of FACTS Exception Report';
             gbl_err_code := -1;
             FV_UTILITY.LOG_MESG(l_module_name||'.error4', gbl_err_buff) ;
             RETURN;
          END IF;
    END IF;

END  submit_exception_report;
--------------------------------------------------------------------------------

PROCEDURE UPDATE_FACTS1_RUN IS
l_module_name VARCHAR2(200);


BEGIN

     l_module_name := g_module_name || 'UPDATE_FACTS1_RUN';
     FV_UTILITY.LOG_MESG('In '||l_module_name);

 fv_utility.log_mesg('Inserting processed headers  ' );

   IF gbl_called_from_main = 'Y'  THEN
    INSERT INTO fv_facts1_processed_je_hdrs(je_header_id,set_of_books_id)
     SELECT DISTINCT je_header_id,set_of_books_id
      FROM  fv_facts1_header_id_gt;

    ELSE
     Insert into fv_facts1_processed_je_hdrs(je_header_id,set_of_books_id)
     select je_header_id,set_of_books_id
     from fv_facts1_header_id_gt;

   END IF;

 fv_utility.log_mesg('Inserted ' || SQL%ROWCOUNT);


 fv_utility.log_mesg('Updating Facts1 run ' );

     UPDATE fv_facts1_run
     SET    process_date = sysdate,
            jc_run_month  = gbl_period_num_high,
            run_fed_flag  = 'J'
     WHERE  set_of_books_id = gbl_sob_id
     AND    fiscal_year     = gbl_period_year
     AND    table_indicator = 'N';


 --Update the fv_facts1_fed_account as processed as of date.

 fv_utility.log_mesg('Updating fv_facts1_fed_accounts ' );
     UPDATE fv_facts1_fed_accounts
     SET    jc_flag = 'Y'
     WHERE  set_of_books_id = gbl_sob_id
     AND    fiscal_year     = gbl_period_year;


  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          NULL;

     WHEN OTHERS THEN
        gbl_err_code := SQLCODE;
        gbl_err_buff  := SQLERRM ||
                      'When others error in UPDATE_FACTS1_RUN - '||SQLERRM;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, gbl_err_buff);

END UPDATE_FACTS1_RUN;
--------------------------------------------------------------------------------
PROCEDURE get_reference_column (p_entity_code IN VARCHAR2,
                                p_je_batch_id IN NUMBER,
                                p_je_header_id IN NUMBER,
                                p_je_line_num IN NUMBER,
                                p_application_id IN NUMBER,
                                p_jrnl_dc_indicator IN VARCHAR2,
                                p_party_info_tab OUT NOCOPY party_info_table) IS


CURSOR be_cursor IS
       SELECT  xd.source_distribution_id_num_1 transaction_id,
               (NVL(xd.unrounded_accounted_dr,0) -
                NVL(xd.unrounded_accounted_cr,0)) amount
       FROM gl_import_references gli,
            xla_ae_lines xl,
            xla_ae_headers xh,
            xla_distribution_links xd
       WHERE gli.je_batch_id = p_je_batch_id
       AND gli.je_header_id = p_je_header_id
       AND gli.je_line_num = p_je_line_num
       AND xl.gl_sl_link_id = gli.gl_sl_link_id
       AND xl.application_id = 8901
       AND xh.ae_header_id = xl.ae_header_id
       AND xl.ledger_id = gbl_sob_id
       AND xd.event_id = xh.event_id
       and xd.ae_header_id = xh.ae_header_id
       and xd.ae_line_num = xl.ae_line_num;


CURSOR other_source_cur IS
       SELECT ael.party_id,
              NVL(ael.accounted_dr,0) -
              NVL(ael.accounted_cr,0) amount
       FROM gl_import_references i,
                 xla_ae_lines ael
       WHERE i.je_batch_id = p_je_batch_id
       AND  i.je_header_id = p_je_header_id
       AND i.je_line_num = p_je_line_num
       AND i.gl_sl_link_id = ael.gl_sl_link_id
       AND ael.application_id = p_application_id
       AND ael.ledger_id = gbl_sob_id;

  	i INTEGER := 1;

    l_module_name VARCHAR2(200) := g_module_name || 'GET_REFERENCE_COLUMN';

BEGIN
      log(l_module_name, 'In '||l_module_name);
      log(l_module_name,'Source: '||p_entity_code);
      log(l_module_name,'Je Batch ID: '||p_je_batch_id);
      log(l_module_name,'Je Header ID: '||p_je_header_id);
      log(l_module_name,'Je Line Num: '||p_je_line_num);
      log(l_module_name,'Application ID: '||p_application_id);

      IF p_entity_code <> ('BE_TRANSACTIONS') THEN
         FOR other_source_rec IN other_source_cur
          LOOP

            --log(l_module_name,'p_party_id: '||other_source_rec.party_id);

            p_party_info_tab(i).feeder_flag := 'Y';

            IF other_source_rec.party_id IS NOT NULL THEN
               IF p_entity_code IN ('PURCHASE_ORDER', 'AP_PAYMENTS',
                                    'TR_CONFIRM') THEN
                 BEGIN
                   SELECT vendor_id, vendor_type_lookup_code,
                       DECODE(gbl_vend_attribute, 'ATTRIBUTE1', ATTRIBUTE1,
                       'ATTRIBUTE2', ATTRIBUTE2, 'ATTRIBUTE3', ATTRIBUTE3,
                       'ATTRIBUTE4', ATTRIBUTE4, 'ATTRIBUTE5', ATTRIBUTE5,
                       'ATTRIBUTE6', ATTRIBUTE6, 'ATTRIBUTE7', ATTRIBUTE7,
                       'ATTRIBUTE8', ATTRIBUTE8, 'ATTRIBUTE9', ATTRIBUTE9,
                       'ATTRIBUTE10', ATTRIBUTE10, 'ATTRIBUTE11', ATTRIBUTE11,
                       'ATTRIBUTE12', ATTRIBUTE12, 'ATTRIBUTE13', ATTRIBUTE13,
                       'ATTRIBUTE14', ATTRIBUTE14, 'ATTRIBUTE15', ATTRIBUTE15)
                        eliminations_id, vendor_name, other_source_rec.amount
                    INTO p_party_info_tab(i).party_id,  p_party_info_tab(i).vendor_type,
                         P_party_info_tab(i).elim_dept, p_party_info_tab(i).recipient_name,
                         P_party_info_tab(i).party_line_amount
                    FROM   ap_suppliers
                    WHERE  vendor_id = other_source_rec.party_id;

                    p_party_info_tab(i).cust_vend_type := 'V';

                 EXCEPTION WHEN NO_DATA_FOUND THEN
                    FV_UTILITY.LOG_MESG('No data found in ap_suppliers for vendor_id: '||
                                          other_source_rec.party_id);
                    p_party_info_tab(i).party_id := other_source_rec.party_id;
                    p_party_info_tab(i).cust_vend_type := 'V';
                    P_party_info_tab(i).party_line_amount := other_source_rec.amount;
                    p_party_info_tab(i).recipient_name := 'Other';
                 END;

                ELSIF  p_entity_code = 'RECEIPTS' THEN
                  BEGIN
                     SELECT c.party_id, c.customer_class_code,
                       DECODE(gbl_cust_attribute, 'ATTRIBUTE1', C.ATTRIBUTE1,
                       'ATTRIBUTE2', C.ATTRIBUTE2, 'ATTRIBUTE3', C.ATTRIBUTE3,
                       'ATTRIBUTE4', C.ATTRIBUTE4, 'ATTRIBUTE5', C.ATTRIBUTE5,
                       'ATTRIBUTE6', C.ATTRIBUTE6, 'ATTRIBUTE7', C.ATTRIBUTE7,
                       'ATTRIBUTE8', C.ATTRIBUTE8, 'ATTRIBUTE9', C.ATTRIBUTE9,
                       'ATTRIBUTE10', C.ATTRIBUTE10, 'ATTRIBUTE11', C.ATTRIBUTE11,
                       'ATTRIBUTE12', C.ATTRIBUTE12, 'ATTRIBUTE13', C.ATTRIBUTE13,
                       'ATTRIBUTE14', C.ATTRIBUTE14,
                       'ATTRIBUTE15', C.ATTRIBUTE15) eliminations_id,
                        c.account_name, other_source_rec.amount
                     INTO p_party_info_tab(i).party_id,  p_party_info_tab(i).vendor_type,
                          p_party_info_tab(i).elim_dept, p_party_info_tab(i).recipient_name,
                          P_party_info_tab(i).party_line_amount
                     FROM hz_cust_accounts_all c
                     WHERE c.cust_account_id = other_source_rec.party_id;

                     p_party_info_tab(i).cust_vend_type := 'C';
                  EXCEPTION WHEN NO_DATA_FOUND THEN
                    FV_UTILITY.LOG_MESG('No data found in hz_cust_accounts_all for party_id: '||
                                          other_source_rec.party_id);
                    p_party_info_tab(i).party_id := other_source_rec.party_id;
                    p_party_info_tab(i).cust_vend_type := 'C';
                    P_party_info_tab(i).party_line_amount := other_source_rec.amount;
                    p_party_info_tab(i).recipient_name := 'Other';
                  END;

               END IF;

               ELSE
                 p_party_info_tab(i).party_line_amount := other_source_rec.amount;

             END IF;

                log(l_module_name,'party_id: '||p_party_info_tab(i).party_id);
                log(l_module_name,'party_type: '||p_party_info_tab(i).vendor_type);
                log(l_module_name,'elim_dept: '|| p_party_info_tab(i).elim_dept);
                log(l_module_name,'party_name: '||p_party_info_tab(i).recipient_name);
                log(l_module_name,'cust or vend: '||p_party_info_tab(i).cust_vend_type);
                log(l_module_name,'line_amount: '||p_party_info_tab(i).party_line_amount);

              i := i + 1;
             END LOOP;

          ELSIF p_entity_code = 'BE_TRANSACTIONS' THEN
                -- using party_id for storing transaction id
                FOR be_rec IN be_cursor
                   LOOP

                     p_party_info_tab(i).feeder_flag := 'Y';
                     BEGIN
                       SELECT decode(gbl_trading_partner_att, null,
                                     dept_id|| main_account,
                                     SUBSTR(DECODE(UPPER(gbl_trading_partner_att),
                                           'ATTRIBUTE1', attribute1,
                                           'ATTRIBUTE2', attribute2,
                                           'ATTRIBUTE3', attribute3,
                                           'ATTRIBUTE4', attribute4,
                                           'ATTRIBUTE5', attribute5,
                                           'ATTRIBUTE6', attribute6,
                                           'ATTRIBUTE7', attribute7,
                                           'ATTRIBUTE8', attribute8,
                                           'ATTRIBUTE9', attribute9,
                                           'ATTRIBUTE10', attribute10,
                                           'ATTRIBUTE11', attribute11,
                                           'ATTRIBUTE12', attribute12,
                                           'ATTRIBUTE13', attribute13,
                                           'ATTRIBUTE14', attribute14,
                                           'ATTRIBUTE15', attribute15),1,6))
                       INTO p_party_info_tab(i).elim_dept
                       FROM fv_be_trx_dtls
                       WHERE transaction_id = be_rec.transaction_id;

                       p_party_info_tab(i).party_id := p_party_info_tab(i).elim_dept;
                       p_party_info_tab(i).party_line_amount := be_rec.amount;
                       p_party_info_tab(i).recipient_name := 'Other';

                       IF (p_party_info_tab(i).elim_dept IS NOT NULL) THEN
                           p_party_info_tab(i).party_id := p_party_info_tab(i).elim_dept;
                           p_party_info_tab(i).vendor_type := 'FEDERAL';
                       END IF;

                       log(l_module_name,'elim_dept: '||p_party_info_tab(i).elim_dept);
                       log(l_module_name,'party_id: '||p_party_info_tab(i).party_id);
                       log(l_module_name,'line_amount: '||p_party_info_tab(i).party_line_amount);
                       log(l_module_name,'vendor_type: '||p_party_info_tab(i).vendor_type);

                     EXCEPTION WHEN NO_DATA_FOUND THEN
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,
                         'NO DATA FOUND WHEN SOURCE = :'||p_entity_code);
                        p_party_info_tab(i).party_line_amount := be_rec.amount;
                        p_party_info_tab(i).recipient_name := 'Other';
                     END;
                     i := i + 1;
                   END LOOP;
         END IF;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
        gbl_err_code := SQLCODE;
        gbl_err_buff  :=
                      'No data found error in get_reference_column - '||SQLERRM;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, gbl_err_buff);
     WHEN OTHERS THEN
        gbl_err_code := SQLCODE;
        gbl_err_buff  :=
                      'When others error in get_reference_column - '||SQLERRM;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, gbl_err_buff);
END get_reference_column;
--------------------------------------------------------------------------------
BEGIN
g_module_name := 'fv.plsql.FV_FACTS1_GL_PKG.';
--------------------------------------------------------------------------------
END fv_facts1_gl_pkg;

/
