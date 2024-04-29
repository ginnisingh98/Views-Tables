--------------------------------------------------------
--  DDL for Package Body FV_AP_CASH_POS_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_AP_CASH_POS_DTL_PKG" AS
--$Header: FVAPCPDB.pls 120.14 2006/12/12 09:27:37 bnarang ship $

  g_module_name VARCHAR2(100) ;

  /********** Global Variable Definitions **********/
  g_bal_segment_num       NUMBER(15);
  g_acct_segment_num      NUMBER(15);
  g_bal_segment_name      VARCHAR2(30);
  g_acct_segment_name     VARCHAR2(30);
  g_check_date            DATE;
  g_set_of_books_id       gl_ledgers_public_v.ledger_id %TYPE;
  g_set_of_books_name     gl_ledgers_public_v.name%type;
  g_flex_num              gl_code_combinations.chart_of_accounts_id%TYPE;
  g_segment_value         gl_code_combinations.segment1%TYPE;
  g_error_code            NUMBER(15);
  g_error_buf             VARCHAR2(500);
  g_error_stage           NUMBER(15);
  g_checkrun_name         ap_selected_invoices_all.checkrun_name%TYPE;
  g_checkrun_id           ap_selected_invoices_all.checkrun_id%TYPE;
  g_apps_id               NUMBER       := 101;
  g_flex_code             VARCHAR2(25) ;
  g_org_id                NUMBER(15);
  Invalid_segment         EXCEPTION;
/*------------------------------------------------------------------
--  g_pooled_flag           ap_bank_accounts.pooled_flag%TYPE;
  g_pooled_flag           ce_bank_accounts.pooled_flag%TYPE;
--  g_bank_acct_name        ap_bank_accounts.bank_account_name%TYPE;
  g_bank_acct_name        ce_bank_accounts.bank_account_name%TYPE;
--------------------------------------------------------------------*/
  g_value_set_id          fnd_flex_values.flex_value_set_id%TYPE;
  g_auto_offset_method    ap_system_parameters.liability_post_lookup_code%TYPE;

/**********                                                       ********/
/**********                PROCEDURE: MAIN                        ********/
/**********                                                       ********/
/**    This Procedure calls the  remaining procedures             ********/

PROCEDURE MAIN (errbuf OUT NOCOPY VARCHAR2,
	            retcode OUT NOCOPY NUMBER,
                p_payment_batch IN NUMBER,
                p_org_id		IN		NUMBER) IS
  l_module_name VARCHAR2(200) ;
  req_id                        NUMBER;

BEGIN

   g_checkrun_id := p_payment_batch;
/*------Commented out as org_id is passed in as parameter-----------------
   g_set_of_books_id := TO_NUMBER(fnd_profile.value('GL_SET_OF_BKS_ID'));
   g_org_id    := TO_NUMBER(fnd_profile.value('ORG_ID'));
------------End of comments---------------------------------------------*/
   if (p_org_id is not null) then
           g_org_id := p_org_id;
   else
      select org_id
      into g_org_id
      from ap_selected_invoices_all
      where checkrun_id = g_checkrun_id
      and rownum < 2;
   end if;

   mo_utils.Get_Ledger_Info
  (  p_operating_unit         =>	g_org_id
   , p_ledger_id                =>	g_set_of_books_id
   , p_ledger_name            =>	g_set_of_books_name);

   l_module_name := g_module_name || 'MAIN';

      DELETE FROM fv_ap_cash_pos_temp
      WHERE  checkrun_id = g_checkrun_id
        AND  set_of_books_id = g_set_of_books_id
        AND org_id = g_org_id;

   INITIALIZE_PROCESS;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'INITIALIZED PROCESS');
   END IF;

    IF g_error_code <> 0 THEN
      retcode := g_error_code;
      errbuf := g_error_buf;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',g_error_buf);
      RETURN;
    END IF;

  CREATE_CASH_POSITION_RECORD;
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CREATE_CASH_POSITION_RECORD');
  END IF;

  IF g_error_code <> 0 THEN
      retcode := g_error_code;
      errbuf := g_error_buf;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error2',g_error_buf);
      RETURN;
    END IF;
COMMIT;

-- Added the below IF for the Bug # 2521634

IF g_auto_offset_method = 'None' THEN
  retcode := 1;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,' ');
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'The Automatic Offset option is set to None.');
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'It should be either Balancing or Account.');
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'Please note that the report'||''''||'s G/L Cash Balance is determined by the');
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'funds of the invoices, while journal entries for the payments will be posted');
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'to the cash account as defined for the bank account.');
/*---------------------------comments begin-------------------------------------
ELSIF g_pooled_flag = 'Y' THEN
  retcode := 0;
  errbuf := '** Cash Position Detail Process completed successfully  ** ';
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,errbuf);
  END IF;
------------------------------------------------------------------------------*/
END IF;

/*-------------------------------comments start---------------------------------
IF g_pooled_flag = 'N' THEN
    retcode := 1;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,' ');
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'The pooled flag is not selected on the bank account '||g_bank_acct_name||'.');
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'The G/L Cash Balance is determined by the funds of the invoices.');
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'Please note that the journal entry for the payments will be posted');
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'to the fund of the cash account as defined on the bank account.');
END IF;
-------------------------------end of comments--------------------------------*/

FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,' ');
FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'Please Note: It is assumed that payments are made using pooled bank accounts.');
FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'If pooled accounts are not used, liabilities and payments are not properly distrubuted across multiple funds.');

-- make sure to pass g_org_id (not p_org_id) - p_org_id will most probably be NULL
 req_id := FND_REQUEST.SUBMIT_REQUEST('FV', 'FVAPCPDR',NULL,
                                       NULL, FALSE,p_payment_batch,g_org_id);

  IF (req_id = 0) THEN
    retcode := 2;
    errbuf := 'Failed to submit request for Cash Position Detail Report .';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,errbuf);
  END IF;
  IF (retcode <> 0 AND retcode = -1) THEN
--changed checkrun_name to checkrun_id
      DELETE FROM fv_ap_cash_pos_temp
      WHERE  checkrun_id = g_checkrun_id
        AND  set_of_books_id = g_set_of_books_id
        AND org_id = g_org_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    retcode := 2;
    errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
END MAIN;

/**********                                                       **********/
/**********     PROCEDURE: Initialize_Process                     **********/
/**********                                                       **********/
/**********  This procedure validates all the validations         **********/

PROCEDURE Initialize_Process IS

  l_module_name VARCHAR2(200) ;

CURSOR  flex_value_set_cur(p_acct_segment_num NUMBER,
                           p_apps_id NUMBER,
                           p_flex_code VARCHAR2,
                           p_flex_num  NUMBER  ) IS
 SELECT flex_value_set_id
   FROM fnd_id_flex_segments
  WHERE application_id = p_apps_id
    AND id_flex_code   = p_flex_code
    AND id_flex_num    = p_flex_num
    AND segment_num    = p_acct_segment_num ;

CURSOR cash_position_accounts_cur IS
SELECT ussgl_account
 FROM  fv_facts_ussgl_accounts
WHERE  cash_position_flag = 'Y'
  AND  ussgl_enabled_flag = 'Y';

CURSOR  parent_child_rollups_cur(p_acct VARCHAR2,p_value_set_id NUMBER) IS
    SELECT 1
      FROM  fnd_flex_values
     WHERE  flex_value_set_id = p_value_set_id
       AND  flex_value = p_acct ;
--changed checkrun_name to checkrun_id
CURSOR check_date_cur(p_checkrun_id NUMBER) IS
SELECT check_date,checkrun_name
 FROM ap_inv_selection_criteria_all
WHERE checkrun_id = p_checkrun_id;

--changed checkrun_name to checkrun_id
CURSOR invoice_count_cur(p_checkrun_id NUMBER) IS
SELECT count(asi.invoice_num||asi.vendor_id||asi.vendor_site_id) count
FROM ap_selected_invoices_all asi
WHERE asi.checkrun_id = p_checkrun_id;

/*---------comments-----------------------------------------------
CURSOR bank_acct_cur(p_checkrun_id NUMBER) IS
SELECT cba.pooled_flag, cba.bank_account_name
FROM ce_bank_accounts cba ,
            Ce_bank_acct_uses_all cbaua,
            ap_inv_selection_criteria_all apis
WHERE  apis.checkrun_id = p_checkrun_id
---;)--  AND       apis.bank_account_id = cbaua.bank_account_id
AND       apis.ce_bank_acount_use_id = cbaua.bank_account_id
AND       cbaua.bank_account_id = cba.bank_account_id;
----------------end of comments---------------------------------*/

-- Added the below cursor for the Bug # 2521634

CURSOR automatic_offset_method_cur IS
SELECT NVL(liability_post_lookup_code ,'None')
  FROM ap_system_parameters;

  l_record_count       NUMBER;
  l_count              NUMBER;
  l_cash_ussgl_acct    fv_facts_ussgl_accounts.ussgl_account%TYPE;
  l_parent_rollups     VARCHAR2(1);

BEGIN
  l_module_name := g_module_name || 'Initialize_Process';
  g_error_stage := 1;
  g_error_code := 0;
  g_error_buf  := Null;


 -- get the check date for the payment batch

  OPEN check_date_cur(g_checkrun_id);
  FETCH check_date_cur INTO g_check_date,g_checkrun_name;
  CLOSE check_date_cur;

 -- get the count of the invoices selected for the payment batch

  OPEN invoice_count_cur(g_checkrun_id);
  FETCH invoice_count_cur INTO l_record_count;
  CLOSE invoice_count_cur;

  IF l_record_count = 0 THEN
    g_error_code := -1;
    g_error_buf := 'No Invoices were selected for this Payment Batch.';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
    RETURN;
  END IF;

 -- get the GL BALANCING and GL ACCOUNT segment numbers

   get_segment_num;

 -- get Automatic offset method from AP

  OPEN automatic_offset_method_cur;
  FETCH automatic_offset_method_cur INTO g_auto_offset_method;
  CLOSE automatic_offset_method_cur;

/*----------------start comments---------------------------------
 -- get the bank account details
  OPEN bank_acct_cur(g_checkrun_id);
  FETCH bank_acct_cur INTO g_pooled_flag, g_bank_acct_name;
  CLOSE bank_acct_cur;
-------------------end comments---------------------------------*/

  --  Get the value set attached to the accounting segment

  OPEN flex_value_set_cur(g_acct_segment_num,
                           g_apps_id ,
                           g_flex_code,
                           g_flex_num);
  FETCH flex_value_set_cur INTO  g_value_set_id;
  CLOSE flex_value_set_cur;

  l_record_count := 0;
  l_count := 0;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'The USSGL Accounts identified as Cash Accounts are :');
  END IF;


  OPEN cash_position_accounts_cur ;
LOOP
  FETCH cash_position_accounts_cur INTO l_cash_ussgl_acct ;
  EXIT WHEN cash_position_accounts_cur%NOTFOUND;

    -- get parent/child roll ups

    OPEN parent_child_rollups_cur(l_cash_ussgl_acct,
                                  g_value_set_id);
    FETCH parent_child_rollups_cur INTO  l_record_count;
    CLOSE parent_child_rollups_cur;

   IF l_record_count = 1 THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_cash_ussgl_acct);
      END IF;
      l_record_count := 2 ;
   END IF;
    l_count := 1;

END LOOP;

CLOSE cash_position_accounts_cur ;

  IF ( l_record_count = 0 ) THEN
      g_error_code := -1;
      g_error_buf := 'Please define US SGL Cash Position Accounts in General Ledger.';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
      RETURN;
  END IF ;

 IF l_count = 0 THEN
     g_error_code := -1;
     g_error_buf := 'Please define Cash Position Accounts in Define USSGL Accounts screen. ';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,g_error_buf);
     RETURN;
 END IF ;


  EXCEPTION

     WHEN OTHERS THEN
      g_error_code := -1;
      g_error_buf := to_char(sqlcode) ||' '|| sqlerrm||' [Intialize Process]';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
      ROLLBACK;
      RETURN;

END Initialize_Process;

/**********                                                       **********/
/**********     PROCEDURE: Create_Cash_Position_Record            **********/
/**********                                                       **********/
/**********  This procedure pulls all the invoice distributions   **********/
/**********  and caluculates the gl balances for the funds.       **********/
/**********                                                       **********/

PROCEDURE Create_Cash_Position_Record IS

  l_module_name VARCHAR2(200) ;

CURSOR period_detail_cur(p_checkrun_date DATE,
                         p_apps_id NUMBER,
                         p_set_of_books_id NUMBER) IS
SELECT gps.period_num,gps.period_year,glpv.currency_CODE
  FROM gl_period_statuses gps ,gl_ledgers_public_v glpv
 WHERE Start_date <= p_checkrun_date
   AND end_date >=  p_checkrun_date
   AND gps.application_id = p_apps_id
   AND gps.set_of_books_id =p_set_of_books_id
   AND gps.set_of_books_id = glpv.ledger_id
   AND gps.adjustment_period_flag='N';


CURSOR cash_position_acct_cur(p_value_set NUMBER) IS
SELECT ussgl_account
 FROM  fv_facts_ussgl_accounts,fnd_flex_values
WHERE  flex_value_set_id = p_value_set
  AND  flex_value = ussgl_account
  AND  cash_position_flag = 'Y'
  AND  ussgl_enabled_flag = 'Y';

--Modified the invoice cursor to include vendor_id,vendor_site_id and amount
-- formula to fix 2498036 Bug.
CURSOR invoice_cursor(p_checkrun_id NUMBER) IS
    SELECT asi.invoice_num,
                   asi.invoice_date,
                   apd.distribution_line_number,
                   apd.dist_code_combination_id   dist_code_combination_id,
                   ((asi.payment_amount) *(apd.amount/asi.invoice_amount)) amount,
                   asi.vendor_id,
                   asi.vendor_site_id
      FROM ap_selected_invoices asi,
                  ap_invoice_distributions apd
     WHERE asi.checkrun_id = p_checkrun_id
      AND apd.invoice_id  = asi.invoice_id
     ORDER by asi.invoice_num;


CURSOR fund_exist_cur(p_fund VARCHAR2,p_checkrun_id NUMBER,
                      p_sob_id NUMBER,p_org_id NUMBER)  IS
 SELECT  fund,gl_cash_balance
   FROM fv_ap_cash_pos_temp
 WHERE checkrun_id = p_checkrun_id
  AND  fund = p_fund
  AND  set_of_books_id = p_sob_id
  AND  org_id         = p_org_id
  AND  rownum = 1;


  vcheck_rec            invoice_cursor%ROWTYPE;
  l_acct_dist_tbl       Fnd_Flex_Ext.segmentarray ;
  l_get_segments_flag   BOOLEAN;
  l_period_num          gl_balances.period_num%TYPE;
  l_currency_code       gl_balances.currency_code%TYPE;
  l_period_year         gl_balances.period_year%TYPE ;
  l_boolean             BOOLEAN;
  l_num_segments        NUMBER;
  l_value_set_id        fnd_flex_values.flex_value_set_id%TYPE;
  l_gl_cash_balance     NUMBER;
  l_cash_ussgl_acct     fv_facts_ussgl_accounts.ussgl_account%TYPE;
  l_bal_cursor     	INTEGER ;
  l_bal_select   	VARCHAR2(5000) ;
  l_exec_ret            INTEGER ;
  l_tot_cash_balance    NUMBER;
  l_fund_exist          VARCHAR2(80);
  l_fund_gl_balance     NUMBER;
  l_counter             NUMBER :=0;

 BEGIN
  l_module_name := g_module_name || 'Create_Cash_Position_Record';

  g_error_stage := 2;

  OPEN period_detail_cur(g_check_date,
                        g_apps_id,
			g_set_of_books_id);
  FETCH period_detail_cur INTO l_period_num,l_period_year,l_currency_code;
  CLOSE period_detail_cur;

  OPEN invoice_cursor(g_checkrun_id);
  LOOP
    FETCH invoice_cursor INTO vcheck_rec;
      EXIT WHEN invoice_cursor%NOTFOUND;

      l_get_segments_flag :=
                 fnd_flex_ext.get_segments
                        (application_short_name => 'SQLGL',
		       key_flex_code    => g_flex_code,
		       structure_number => g_flex_num,
		   	 combination_id => vcheck_rec.dist_code_combination_id,
                         n_segments     => l_num_segments,
			 segments       => l_acct_dist_tbl) ;


      l_tot_cash_balance :=0;
      l_fund_exist := NULL;

      OPEN fund_exist_cur(l_acct_dist_tbl(g_bal_segment_num),
                          g_checkrun_id,
                          g_set_of_books_id,
                          g_org_id);
      FETCH fund_exist_cur INTO l_fund_exist,l_fund_gl_balance;
      CLOSE fund_exist_cur;


IF l_fund_exist IS NULL THEN


      OPEN cash_position_acct_cur(g_value_set_id);
      LOOP
        FETCH cash_position_acct_cur INTO l_cash_ussgl_acct ;
        EXIT WHEN cash_position_acct_cur%NOTFOUND;

        BEGIN
         l_bal_cursor := DBMS_SQL.OPEN_CURSOR;

        EXCEPTION
        WHEN OTHERS THEN
           g_error_code := sqlcode ;
           g_error_buf := sqlerrm || ' [CALC_BALANCE - Open Cursor] ' ;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception2',g_error_buf);
           RETURN;
        END ;

        l_bal_select :=
        	'SELECT SUM((GLB.BEGIN_BALANCE_DR -
          GLB.BEGIN_BALANCE_CR) + (GLB.PERIOD_NET_DR - PERIOD_NET_CR )) '||
                 ' FROM GL_BALANCES  GLB,' ||
         	' GL_CODE_COMBINATIONS GLCC' ||
        ' WHERE   GLB.code_combination_id  = GLCC.code_combination_id ' ||
        ' AND '||'glb.actual_flag = '|| '''' || 'A' || '''' ||
         ' AND  GLCC.'|| g_bal_segment_name ||' = '||'''' || l_acct_dist_tbl(g_bal_segment_num) ||''''||
         ' AND ((GLCC.' ||g_acct_segment_name ||' =  :l_cash_ussgl_acct ' ||
        ' ) OR GLCC.'||g_acct_segment_name ||' IN (SELECT flex_value '||
                     'FROM fnd_flex_values ffv, fnd_flex_value_hierarchies ffvh '||
                     'WHERE ffv.flex_value BETWEEN  ffvh.child_flex_value_low
                                         AND  ffvh.child_flex_value_high
		        AND ffv.flex_value_set_id =  :g_value_set_id AND ffv.flex_value_set_id = ffvh.flex_value_set_id'||
     ' AND parent_flex_value = :l_cash_ussgl_acct)) AND GLB.period_year = :l_period_year AND GLB.period_num = :l_period_num AND  GLB.LEDGER_ID = :g_set_of_books_id AND glb.currency_code = :l_currency_code';

       IBY_PAYMENT_FORMAT_VAL_PVT.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Dynamic SQL Statement');
       IBY_PAYMENT_FORMAT_VAL_PVT.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_bal_select);
       IBY_PAYMENT_FORMAT_VAL_PVT.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, ':l_cash_ussgl_acct = ' || l_cash_ussgl_acct);
       IBY_PAYMENT_FORMAT_VAL_PVT.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, ':l_period_year = ' || l_period_year);
       IBY_PAYMENT_FORMAT_VAL_PVT.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, ':l_period_num = ' || l_period_num);
       IBY_PAYMENT_FORMAT_VAL_PVT.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, ':g_set_of_books_id = ' || g_set_of_books_id);
       IBY_PAYMENT_FORMAT_VAL_PVT.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, ':l_currency_code = ' || l_currency_code);
       IBY_PAYMENT_FORMAT_VAL_PVT.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, ':g_value_set_id = ' || g_value_set_id);




       BEGIN
          DBMS_SQL.PARSE(l_bal_cursor, l_bal_select, DBMS_SQL.V7) ;
          DBMS_SQL.BIND_VARIABLE(l_bal_cursor,':l_cash_ussgl_acct',l_cash_ussgl_acct);
          DBMS_SQL.BIND_VARIABLE(l_bal_cursor,':l_period_year',l_period_year);
          DBMS_SQL.BIND_VARIABLE(l_bal_cursor,':l_period_num',l_period_num);
          DBMS_SQL.BIND_VARIABLE(l_bal_cursor,':g_set_of_books_id',g_set_of_books_id);
          DBMS_SQL.BIND_VARIABLE(l_bal_cursor,':l_currency_code',l_currency_code);
          DBMS_SQL.BIND_VARIABLE(l_bal_cursor,':g_value_set_id',g_value_set_id);

          DBMS_SQL.DEFINE_COLUMN(l_bal_cursor, 1, l_gl_cash_balance);

        BEGIN
          l_exec_ret := DBMS_SQL.EXECUTE(l_bal_cursor);

        EXCEPTION
        WHEN OTHERS THEN
          g_error_code := sqlcode ;
          g_error_buf := sqlerrm || 'Create_cash_position - Execute Cursor]' ;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_error_buf);
          RETURN ;
        END ;

        IF dbms_sql.fetch_rows(l_bal_cursor) = 0 THEN
            EXIT;
        ELSE
            -- Fetch the Records into Variables
          DBMS_SQL.COLUMN_VALUE(l_bal_cursor, 1, l_gl_cash_balance);
          l_tot_cash_balance := NVL(l_gl_cash_balance,0) + l_tot_cash_balance;
        END IF;


        -- Close the SQL Cursor
       BEGIN
        DBMS_SQL.CLOSE_CURSOR(l_bal_cursor);
       EXCEPTION
        WHEN OTHERS THEN
            g_error_code := sqlcode ;
            g_error_buf := sqlerrm ||' Create_cash_position - Close Cursor]' ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception_A',g_error_buf);
            RETURN ;
       END ;

      EXCEPTION
        WHEN OTHERS THEN
            g_error_code := sqlcode ;
            g_error_buf := sqlerrm ||' Create_cash_position';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception_B',g_error_buf);
	    RETURN ;
      END ;
   END LOOP;

  CLOSE cash_position_acct_cur;
ELSE
  l_tot_cash_balance := l_fund_gl_balance;
END IF;
--Modified the following statement to include vendor_id ,vendor_site_id
--and amount formula to fix 2498036 bug.
       INSERT INTO fv_ap_cash_pos_temp
          (checkrun_id,
           checkrun_name, --bug 5564904
           check_date,
           fund,
           invoice_num,
           invoice_date,
           distribution_line_number,
           amount,
           vendor_id,
	   vendor_site_id,
           gl_cash_balance,
           set_of_books_id,
           org_id )
      VALUES
          (g_checkrun_id,
          g_checkrun_name,  --bug 5564904
	  g_check_date,
	  l_acct_dist_tbl(g_bal_segment_num),
	  vcheck_rec.invoice_num,
	  vcheck_rec.invoice_date,
	  vcheck_rec.distribution_line_number,
	  vcheck_rec.amount,
	  vcheck_rec.vendor_id,
	  vcheck_rec.vendor_site_id,
          l_tot_cash_balance,
          g_set_of_books_id,
          g_org_id);
  l_counter := l_counter + 1;
 IF l_counter > 100 THEN
   COMMIT;
   l_counter := 0;
 END IF;

  END LOOP ; /* VCheck */
  CLOSE invoice_cursor;
COMMIT;
 EXCEPTION
  WHEN invalid_segment THEN
   g_error_code := -1;
   g_error_buf := 'Unable to determine the segments [Create_Cash_Position_Record] ';
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
   ROLLBACK;
   RETURN;
  WHEN OTHERS THEN
   g_error_code := -1;
   g_error_buf  := to_char(sqlcode)||' '||sqlerrm||' [Create_Cash_Position_Record]';
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
   ROLLBACK;
   RETURN;
END Create_Cash_Position_Record;

/**********                                                       **********/
/**********             PROCEDURE: get_segment_num                **********/
/**********                                                       **********/
/**********   This procedure gets the balancing segment and       **********/
/**********   accounting segment numbers of the flex field        **********/

Procedure get_segment_num is

  l_module_name VARCHAR2(200) ;

 CURSOR chart_acct_id_cur(p_set_of_books_id NUMBER) IS
   SELECT chart_of_accounts_id
     FROM gl_ledgers_public_v
    WHERE ledger_id = p_set_of_books_id;

  l_num_boolean           boolean;
  l_seg_number           Number			;
  l_seg_app_name         Varchar2(40)		;
  l_seg_prompt           Varchar2(25)		;
  l_seg_value_set_name   fnd_flex_value_sets.flex_value_set_name%TYPE;

BEGIN
   l_module_name  := g_module_name || 'get_segment_num';

  OPEN chart_acct_id_cur(g_set_of_books_id);
  FETCH   chart_acct_id_cur INTO g_flex_num ;
  CLOSE chart_acct_id_cur;
  l_num_boolean := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM
  			(g_apps_id,
       			 g_flex_code,
			 g_flex_num ,
                         'GL_BALANCING',
			 g_bal_segment_num);

  IF(l_num_boolean) THEN
      	l_num_boolean := FND_FLEX_APIS.GET_SEGMENT_INFO
              	(g_apps_id,
		g_flex_code,
		g_flex_num,
		g_bal_segment_num,
		g_bal_segment_name,
                l_seg_app_name,
		l_seg_prompt,
		l_seg_value_set_name);
   ELSE
      	RAISE invalid_segment;
   END IF;



  IF l_num_boolean = FALSE THEN
	RAISE invalid_segment;
  END IF ;

  l_num_boolean := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM
  			(g_apps_id,
			g_flex_code,
			g_flex_num,
			'GL_ACCOUNT',
			g_acct_segment_num) ;


  IF(l_num_boolean) then
      l_num_boolean := FND_FLEX_APIS.GET_SEGMENT_INFO
              	(g_apps_id,
		g_flex_code,
		g_flex_num,
		g_acct_segment_num,
		g_acct_segment_name,
                l_seg_app_name,
		l_seg_prompt,
		l_seg_value_set_name);
    ELSE
      	RAISE invalid_segment;

   END IF;


  IF l_num_boolean = FALSE THEN
	RAISE invalid_segment;
  END IF;

EXCEPTION
  WHEN invalid_segment THEN
    g_error_code := -1;
    g_error_buf := 'Unable to determine the Segment Information [get_segment_num]';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception1',g_error_buf);
    ROLLBACK;
    RETURN;
  WHEN OTHERS THEN
    g_error_code := -1;
    g_error_buf  := to_char(sqlcode)||' '||sqlerrm||' [get_segment_num]';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_error_buf);
    ROLLBACK;
    RETURN;
END get_segment_num;
Begin
g_flex_code      := 'GL#';
g_module_name    := 'fv.plsql.FV_AP_CASH_POS_DTL_PKG.';


END fv_ap_cash_pos_dtl_pkg;

/
