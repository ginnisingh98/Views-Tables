--------------------------------------------------------
--  DDL for Package Body FV_FACTS_EDIT_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FACTS_EDIT_CHECK" AS
--$Header: FVFCCHKB.pls 120.14.12010000.24 2009/12/04 20:25:18 snama ship $
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_FACTS_EDIT_CHECK.';

g_error_flag         NUMBER(1);
g_treasury_symbol_id NUMBER(15);

-- Addded on 07/13/2000 By Supadman
-- Variable to hold log text.
v_log_text	Varchar2(416) ;
v_log_counter	Number := 0 ;


	v_edit_check_number  	NUMBER;
	v_edit_check_status 	VARCHAR2(25);
	v_amount	 	NUMBER := 0;
	v_amount1	 	NUMBER := 0;
	v_amount2	 	NUMBER := 0;
	v_sgl_acct_number	fv_facts_temp.sgl_acct_number%TYPE;
  v_closing_grp fv_facts_temp.closing_grp%TYPE;
	v_dummy_var		VARCHAR2(3);
	v_row_count		NUMBER := 0;
  g_ledger_id   NUMBER(15);
  g_period_num  NUMBER(15);
  g_period_year NUMBER(15);
  v_beg_bal_sggl_acc fv_facts_temp.SGL_BEG_BAL_ACCT_NUM%type;


PROCEDURE populate_bal_ret_tbl ;
PROCEDURE Create_log_record(text varchar2) ;

PROCEDURE create_status_record(p_edit_check_number number,
			       p_edit_check_status varchar2) ;

-- Procedure to initialize variables
PROCEDURE init_vars IS
  l_module_name VARCHAR2(200) := g_module_name || 'init_vars';

   BEGIN
	v_edit_check_number  	:= NULL;
	v_edit_check_status	:= NULL;
	v_amount	  	:= 0   ;
	v_amount1		:= 0   ;
	v_amount2		:= 0   ;
	v_sgl_acct_number 	:= NULL;
  v_closing_grp       := NULL;
	v_log_text	  	:= ' ' ;
	v_dummy_var		:= NULL;
	v_row_count 		:= 0   ;
  v_beg_bal_sggl_acc  := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      v_log_text := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
      RAISE;

   END init_vars;

PROCEDURE edit_check_1 IS
  l_module_name VARCHAR2(200) := g_module_name || 'edit_check_1';

  l_total_credit	NUMBER	:= 0;
  l_total_debit		NUMBER  := 0;

  -- Cursor to fetch Credit/Debit Ending balance
  -- from FV_FACTS_TEMP for budgetary accounts
  CURSOR check1 IS
  	SELECT 	nvl(amount,0) amount, debit_credit,
		sgl_acct_number
    	FROM  	fv_facts_temp
   	WHERE	treasury_symbol_id = g_treasury_symbol_id
     	  AND 	fct_int_record_category = 'REPORTED_NEW'
     	  AND 	fct_int_record_type = 'BLK_DTL'
          AND 	sgl_acct_number like '4%'
          AND 	begin_end = 'E'
	  AND   amount <> 0
	ORDER BY sgl_acct_number;

  BEGIN
	  init_vars;
	  v_edit_check_number := 1;

  	FOR check1_rec IN check1
  	    LOOP
		IF check1_rec.debit_credit = 'C' THEN
		    l_total_credit	  := l_total_credit + check1_rec.amount;
		  ELSE
		    l_total_debit	  := l_total_debit  + check1_rec.amount;
		END IF;

    /* Added space in from of account number to order the edit check 8 report information*/
		v_sgl_acct_number := ' '||check1_rec.sgl_acct_number;
                v_amount	  := check1_rec.amount;
		create_log_record(v_log_text);

	    END LOOP;

	IF -1*(l_total_credit) = l_total_debit THEN
	    v_edit_check_status := 'Passed';
	  ELSE
    	    g_error_flag := 2;
	    v_edit_check_status := 'Failed';
	END IF;

	create_status_record(v_edit_check_number, v_edit_check_status) ;

  EXCEPTION WHEN OTHERS THEN
      v_log_text := SQLERRM;
      g_error_flag := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
END; --edit_check_1


PROCEDURE edit_check_2 IS
  l_module_name VARCHAR2(200) := g_module_name || 'edit_check_2';

  -- Cursor to fetch SGL account and associated attributes from
  -- FV_FACTS_USSGL_ACCOUNTS for all budgetary accounts
  -- existing in FV_FACTS_TEMP
  CURSOR fv_facts_ussgl_accounts_c IS
  SELECT ffa.ussgl_account,
         ffa.total_resource_be_flag, ffa.total_resource_dc_flag,
         ffa.resource_status_be_flag, ffa.resource_status_dc_flag
    FROM fv_facts_ussgl_accounts ffa
   WHERE ffa.ussgl_account like '4%'
   AND   EXISTS
	 (SELECT 'x'
	  FROM    fv_facts_temp fft
	  WHERE   fft.treasury_symbol_id = g_treasury_symbol_id
	  AND     fft.sgl_acct_number = ffa.ussgl_account);

  l_ussgl_account            varchar2(30);
  l_total_resource_be_flag   varchar2(1);
  l_total_resource_dc_flag   varchar2(1);
  l_resource_status_be_flag  varchar2(1);
  l_resource_status_dc_flag  varchar2(1);
  l_begin_bal                number;
  l_begin_bal_dc_ind         varchar2(1);
  l_end_bal                  number;
  l_end_bal_dc_ind           varchar2(1);
  l_balance                  number;
  l_dc_ind                   varchar2(1);
  l_to_total                 number := 0;
  l_st_total                 number := 0;

  l_to_amount		     NUMBER := 0;
  l_st_amount		     NUMBER := 0;

BEGIN
	  init_vars;
	  v_edit_check_number := 2;

  OPEN fv_facts_ussgl_accounts_c;

  LOOP

    FETCH fv_facts_ussgl_accounts_c
     INTO l_ussgl_account,
          l_total_resource_be_flag,
          l_total_resource_dc_flag,
          l_resource_status_be_flag,
          l_resource_status_dc_flag;

    EXIT WHEN fv_facts_ussgl_accounts_c%NOTFOUND
	OR fv_facts_ussgl_accounts_c%NOTFOUND IS NULL;

    -- Fetch beginning balance and set debit_credit
    -- indicator for the SGL account

    BEGIN

       SELECT nvl(sum(amount),0)
         INTO l_begin_bal
         FROM fv_facts_temp
        WHERE treasury_symbol_id = g_treasury_symbol_id
          AND fct_int_record_category = 'REPORTED_NEW'
          AND fct_int_record_type = 'BLK_DTL'
          AND sgl_acct_number = l_ussgl_account
          AND begin_end = 'B';

        IF (l_begin_bal > 0) THEN
		l_begin_bal_dc_ind := 'D';
        ELSE
		l_begin_bal_dc_ind := 'C';
        END IF;

      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_begin_bal := 0;

    END;

    -- Fetch Ending Balance and set debit_credit
    -- indicator for the SGL account

    BEGIN

       SELECT nvl(sum(amount),0)
         INTO l_end_bal
         FROM fv_facts_temp
     	WHERE treasury_symbol_id = g_treasury_symbol_id
          AND fct_int_record_category = 'REPORTED_NEW'
          AND fct_int_record_type = 'BLK_DTL'
       	  AND sgl_acct_number = l_ussgl_account
          AND begin_end = 'E';

        IF (l_end_bal > 0) THEN
		l_end_bal_dc_ind := 'D';
        ELSE
		l_end_bal_dc_ind := 'C';
        END IF;

       EXCEPTION WHEN NO_DATA_FOUND THEN
          l_end_bal := 0;

    END;

	v_amount1 := 0;
	v_amount2 := 0;

    IF (l_total_resource_be_flag = 'E') THEN

	v_amount1 := l_end_bal;

        IF (l_total_resource_dc_flag = 'D' and l_end_bal_dc_ind = 'D')   THEN
		l_to_total := l_to_total + l_end_bal;
          ELSIF (l_total_resource_dc_flag = 'C' and l_end_bal_dc_ind = 'C') THEN
		l_to_total := l_to_total + l_end_bal;
          ELSIF (l_total_resource_dc_flag = 'E') THEN
		l_to_total := l_to_total + l_end_bal;
        END IF;
    ELSIF (l_total_resource_be_flag = 'B' ) THEN

 	v_amount1 := l_begin_bal;

        IF (l_total_resource_dc_flag = 'D' and l_begin_bal_dc_ind = 'D')   THEN
		l_to_total := l_to_total + l_begin_bal;
        ELSIF (l_total_resource_dc_flag = 'C' and l_begin_bal_dc_ind = 'C') THEN
		l_to_total := l_to_total + l_begin_bal;
        ELSIF (l_total_resource_dc_flag = 'E') THEN
		l_to_total := l_to_total + l_begin_bal;
        END IF;
    END IF;

    IF (l_resource_status_be_flag = 'E') THEN

	v_amount2 := l_end_bal;

        IF (l_resource_status_dc_flag = 'D' and l_end_bal_dc_ind = 'D')   THEN
		l_st_total := l_st_total + l_end_bal;
        ELSIF (l_resource_status_dc_flag = 'C' and l_end_bal_dc_ind = 'C') THEN
		l_st_total := l_st_total + l_end_bal;
        ELSIF (l_resource_status_dc_flag = 'E') THEN
		l_st_total := l_st_total + l_end_bal;
        END IF;
    ELSIF (l_resource_status_be_flag = 'B' ) THEN

	v_amount2 := l_begin_bal;

        IF (l_resource_status_dc_flag = 'D' and l_begin_bal_dc_ind = 'D')   THEN
		l_st_total := l_st_total + l_begin_bal;
        ELSIF (l_resource_status_dc_flag = 'C' and l_begin_bal_dc_ind = 'C') THEN
		l_st_total := l_st_total + l_begin_bal;
        ELSIF (l_resource_status_dc_flag = 'E') THEN
		l_st_total := l_st_total + l_begin_bal;
        END IF;
    ELSIF (l_resource_status_be_flag = 'S' ) THEN

        l_balance := l_end_bal - l_begin_bal;
        IF ( l_balance > 0) THEN
		l_dc_ind := 'D';
         ELSE
		l_dc_ind := 'C';
        END IF;
        IF (l_resource_status_dc_flag = 'D' and l_dc_ind = 'D')   THEN
		l_st_total := l_st_total + l_balance;
        ELSIF (l_resource_status_dc_flag = 'C' and l_dc_ind = 'C') THEN
		l_st_total := l_st_total + l_balance;
        ELSIF (l_resource_status_dc_flag = 'E') THEN
		l_st_total := l_st_total + l_balance;
        END IF;

	v_amount2 := l_balance;

    END IF;


           IF (l_total_resource_be_flag = 'E') AND (l_resource_status_be_flag = 'E') THEN
             IF l_end_bal_dc_ind = 'D' THEN
		v_amount2 := 0;
	      ELSE
		v_amount1 := 0;
	     END IF;
           END IF;

  /* Added space in from of account number to order the edit check 8 report information*/
	v_sgl_acct_number := ' '||l_ussgl_account;
	create_log_record(v_log_text);

  END LOOP;

  CLOSE fv_facts_ussgl_accounts_c;

  l_st_total := -1*l_st_total;

  IF (l_to_total = l_st_total) THEN
	v_edit_check_status := 'Passed';
   ELSE
        g_error_flag := 2;
	v_edit_check_status := 'Failed';
  END IF;

	create_status_record(v_edit_check_number, v_edit_check_status) ;


  EXCEPTION WHEN OTHERS THEN
      v_log_text := SQLERRM;
      g_error_flag := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
END; --edit_check_2


PROCEDURE edit_check_3 IS
  l_module_name VARCHAR2(200) := g_module_name || 'edit_check_3';

  l_budget_credit NUMBER  := 0;
  l_budget_debit  NUMBER  := 0;

  -- Cursor to fetch Credit and Debit Beginning balance
  -- from FV_FACTS_TEMP for budgetary accounts
  CURSOR check3 IS
        SELECT 	nvl(amount,0) amount, debit_credit, sgl_acct_number
    	FROM	fv_facts_temp
   	WHERE   treasury_symbol_id = g_treasury_symbol_id
   	AND   	fct_int_record_category = 'REPORTED_NEW'
     	AND   	fct_int_record_type = 'BLK_DTL'
     	AND	sgl_acct_number like '4%'
     	AND	begin_end = 'B';


 BEGIN
	init_vars;
	v_edit_check_number := 3;

	FOR check3_rec in check3
	   LOOP
		v_amount 	  := check3_rec.amount;
    /* Added space in from of account number to order the edit check 8 report information*/
		v_sgl_acct_number := ' '||check3_rec.sgl_acct_number;

		create_log_record(v_log_text);

		IF check3_rec.debit_credit = 'C' THEN
		   l_budget_credit := l_budget_credit + v_amount;
		 ELSE
		   l_budget_debit  := l_budget_debit  + v_amount;
	        END IF;

	   END LOOP;

	  IF l_budget_debit = -1*(l_budget_credit) THEN
		v_edit_check_status := 'Passed';
	   ELSE
	        g_error_flag := 2;
		v_edit_check_status := 'Failed';
	  END IF;

	create_status_record(v_edit_check_number, v_edit_check_status) ;


  EXCEPTION WHEN OTHERS THEN
      v_log_text := SQLERRM;
      g_error_flag := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
END; --edit_check_3


PROCEDURE edit_check_4 IS
  l_module_name VARCHAR2(200) := g_module_name || 'edit_check_4';

  -- Cursor to fetch ending balance, account number for all accounts
  -- where YE_ANTICIPATED_FLAG = 'Y'
  CURSOR anticipated_items_c is
  	SELECT 	nvl(sum(fft.amount),0), fft.sgl_acct_number
    	FROM 	fv_facts_temp fft,
         	fv_facts_ussgl_accounts ffa
   	WHERE   treasury_symbol_id = g_treasury_symbol_id
     	AND	fct_int_record_category = 'REPORTED_NEW'
     	AND	fct_int_record_type = 'BLK_DTL'
     	AND	ffa.ussgl_account = fft.sgl_acct_number
     	AND	ffa.ye_anticipated_flag = 'Y'
     	AND	fft.begin_end = 'E'
   	GROUP BY fft.sgl_acct_number;

  l_count           number;
  l_amount          NUMBER := 0;
  l_sgl_acct_number varchar2(30);


 BEGIN

	init_vars;

  l_count := 0;
  v_edit_check_number := 4;

  OPEN anticipated_items_c;
  LOOP

    FETCH anticipated_items_c
     INTO l_amount, l_sgl_acct_number;

    EXIT WHEN anticipated_items_c%NOTFOUND OR anticipated_items_c%NOTFOUND IS NULL;

    IF (l_amount <> 0) THEN
        l_count := l_count +1;

	v_amount := l_amount;
  /* Added space in from of account number to order the edit check 8 report information*/
	v_sgl_acct_number := ' '||l_sgl_acct_number;
	create_log_record(v_log_text);
    END IF;

  END LOOP;

    IF 	(l_count > 0) THEN
       	g_error_flag := 2;
       	v_edit_check_status := 'Failed';
     ELSE
	v_edit_check_status := 'Passed';
	v_amount := NULL;
--	create_log_record(v_log_text);
    END IF;

	create_status_record(v_edit_check_number, v_edit_check_status) ;

  CLOSE anticipated_items_c;

  EXCEPTION WHEN OTHERS THEN
      v_log_text := SQLERRM;
      g_error_flag := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
END;  --edit_check_4

PROCEDURE edit_check_5 IS
  l_module_name VARCHAR2(200) := g_module_name || 'edit_check_5';

  --Cursor to fetch Resource and Equity flags and amounts
	CURSOR check5 IS
  		SELECT 	fft.sgl_acct_number, nvl(amount,0) amount,
	 		ffa.ye_resource_equity_flag
    		FROM 	fv_facts_temp fft,
         		fv_facts_ussgl_accounts ffa
   		WHERE 	fft.treasury_symbol_id = g_treasury_symbol_id
     		AND 	fft.fct_int_record_category = 'REPORTED_NEW'
     		AND 	fft.fct_int_record_type = 'BLK_DTL'
     		AND 	ffa.ussgl_account = fft.sgl_acct_number
     		AND 	ffa.ye_resource_equity_flag in ('R','E')
     		AND 	fft.begin_end = ffa.ye_resource_equity_be_flag;

  l_total_resources NUMBER := 0;
  l_total_equity    NUMBER := 0;

BEGIN

  init_vars;
  v_edit_check_number	:= 5;

	FOR check5_rec IN check5
	  LOOP

	    v_amount1 := 0;
	    v_amount2 := 0;

      /* Added space in from of account number to order the edit check 8 report information*/
	    v_sgl_acct_number := ' '||check5_rec.sgl_acct_number;

	    IF check5_rec.ye_resource_equity_flag = 'R' THEN
		v_amount1 := check5_rec.amount;
		l_total_resources := l_total_resources + check5_rec.amount;
		create_log_record(v_log_text);
	     ELSE
		v_amount2 := check5_rec.amount;
		l_total_equity := l_total_equity + check5_rec.amount;
		create_log_record(v_log_text);
	    END IF;

	 END LOOP;

  	IF l_total_resources = -1*(l_total_equity) THEN
    		v_edit_check_status := 'Passed' ;
	  ELSE
        	g_error_flag := 2;
    		v_edit_check_status := 'Failed' ;
	END IF;

	create_status_record(v_edit_check_number, v_edit_check_status) ;

  EXCEPTION WHEN OTHERS THEN
      v_log_text := SQLERRM;
      g_error_flag := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
END; --edit_check_5


PROCEDURE edit_check_6 (p_ledger_id NUMBER) IS
  l_module_name VARCHAR2(200) := g_module_name || 'edit_check_6';

--  l_set_of_books_id  NUMBER;

  CURSOR rt7_codes_c IS
  SELECT ffa.rt7_code_id,
         ffc.rt7_code,
         ffa.preclosing_unexpended_amt
    FROM fv_facts_authorizations ffa,
	 fv_facts_rt7_codes ffc
   WHERE ffa.treasury_symbol_id = g_treasury_symbol_id
     AND ffa.rt7_code_id = ffc.rt7_code_id
     AND ffa.set_of_books_id = p_ledger_id;

  l_rt7_code_id      number(15);
  l_rt7_code         varchar2(3);
  l_accounts_balance number;
  l_unexp_amount     number;
  l_count            number;

BEGIN

  init_vars;
  v_edit_check_number := 6;

--  l_set_of_books_id  := TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID'));
  --Fetch the authorization code for the treasury symbol

  OPEN rt7_codes_c;
  l_count := 0;
  LOOP

    FETCH rt7_codes_c
     INTO l_rt7_code_id,
          l_rt7_code,
          l_unexp_amount;

    EXIT WHEN rt7_codes_c%NOTFOUND OR rt7_codes_c%NOTFOUND IS NULL;

    --Fetch sum of account balances for the authorization code

    BEGIN

      SELECT NVL(sum(fft.amount),0)
        INTO l_accounts_balance
        FROM fv_facts_temp fft,
    	     fv_facts_rt7_accounts rta
       WHERE rta.rt7_code_id = l_rt7_code_id
         AND rta.rt7_ussgl_account = fft.sgl_acct_number
         AND fft.treasury_symbol_id = g_treasury_symbol_id
         AND fft.fct_int_record_category = 'REPORTED_NEW'
         AND fft.fct_int_record_type = 'BLK_DTL'
         AND fft.begin_end = decode(rta.rt7_ussgl_account, '4139','B','4149','B','E');

    END;
	v_dummy_var	  := l_rt7_code;

  /* Added space in from of account number to order the edit check 8 report information*/
	v_sgl_acct_number := ' 1. Preclosing Unexp Amt';
	v_amount	  := l_unexp_amount;
	create_log_record(v_log_text);

  /* Added space in from of account number to order the edit check 8 report information*/
	v_sgl_acct_number := ' 2. Sum of Account Balance';
	v_amount	  := l_accounts_balance;
	create_log_record(v_log_text);

  /* Added space in from of account number to order the edit check 8 report information*/
	v_sgl_acct_number := ' Difference (1-2)';
	v_amount	  := (l_unexp_amount - l_accounts_balance);
	create_log_record(v_log_text);

    	IF (l_accounts_balance <> l_unexp_amount) THEN
      		l_count := l_count + 1;
    	END IF;

  END LOOP;
  CLOSE rt7_codes_c;

      	IF (l_count > 0) THEN
  		v_edit_check_status := 'Failed' ;
        	g_error_flag := 2;
	  ELSE
  		v_edit_check_status := 'Passed' ;
   	END IF;

	create_status_record(v_edit_check_number, v_edit_check_status) ;

  EXCEPTION WHEN OTHERS THEN
      v_log_text := SQLERRM;
      g_error_flag := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
END; --edit_check_6


PROCEDURE edit_check_7 IS
  l_module_name VARCHAR2(200) := g_module_name || 'edit_check_7';

  -- Cursor to fetch ending balance for accounts where
  -- fund_balance_account_flag is 'Y'
	CURSOR check7 IS
  		SELECT nvl(fft.amount,0) amount, fft.sgl_acct_number
    		FROM fv_facts_temp fft,
         	     fv_facts_ussgl_accounts ffa
   		WHERE ffa.fund_balance_account_flag = 'Y'
     		AND fft.sgl_acct_number = ffa.ussgl_account
     		AND fft.treasury_symbol_id = g_treasury_symbol_id
     		AND fft.fct_int_record_category = 'REPORTED_NEW'
     		AND fft.fct_int_record_type = 'BLK_DTL'
     		AND fft.begin_end = 'E';

l_unexp_amount  NUMBER;
l_end_balance   NUMBER := 0;

BEGIN

	init_vars;
	v_edit_check_number := 7;

  --Fetch preclosing ending balance for the treasury symbol
   SELECT preclosing_unexpended_amt
     INTO l_unexp_amount
     FROM fv_treasury_symbols
    WHERE treasury_symbol_id = g_treasury_symbol_id;

	v_amount2	    := l_unexp_amount;
	create_log_record(v_log_text);

		-- reset v_amount --> l_unexp_amount to NULL
		-- since it needs to be printed only once
		v_amount2 := NULL;

	FOR check7_rec in check7
	  LOOP
    /* Added space in from of account number to order the edit check 8 report information*/
		v_sgl_acct_number := ' '||check7_rec.sgl_acct_number;
		v_amount1 := check7_rec.amount;
		create_log_record(v_log_text);

		l_end_balance := l_end_balance + check7_rec.amount;

	  END LOOP;

  IF (l_unexp_amount is NULL ) THEN
      v_edit_check_status := 'Failed' ;
   ELSIF (l_unexp_amount = l_end_balance) THEN
      v_edit_check_status := 'Passed' ;
   ELSE
      v_edit_check_status := 'Failed' ;
      g_error_flag := 2;
  END IF;

	create_status_record(v_edit_check_number, v_edit_check_status) ;

  EXCEPTION WHEN OTHERS THEN
      v_log_text := SQLERRM;
      g_error_flag := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
END; -- edit_check_7

PROCEDURE edit_check_8 IS
  l_module_name VARCHAR2(200) := g_module_name || 'edit_check_8';


  -- Cursor to fetch amounts for Obligations Incurred
  -- This cursor fetches only if the account is End-Begin.

  CURSOR check8_col1b_cur
  (
    p_treasury_symbol_id NUMBER
  )
  IS
  SELECT NVL(SUM(DECODE(fft.begin_end, 'B', -1*NVL(fft.amount,0), NVL(fft.amount,0))), 0) obligations_incurred_s_amt
    FROM fv_facts_temp fft,
         fv_facts_ussgl_accounts ffa
   WHERE ffa.obligations_incurred_flag = 'Y'
     AND ffa.ussgl_account = fft.sgl_acct_number
     AND fft.treasury_symbol_id = p_treasury_symbol_id
     AND fft.fct_int_record_category = 'REPORTED_NEW'
     AND fft.fct_int_record_type = 'BLK_DTL';
 --  AND ffa.resource_status_be_flag IN ('S');


  -- Cursor to fetch amounts for Spending from Collections and PYA
  -- This cursor fetches only if the account is End-Begin.
  CURSOR check8_col2b_cur
  (
    p_treasury_symbol_id NUMBER
  )
  IS
  SELECT NVL(SUM(DECODE(fft.begin_end, 'B', -1*NVL(fft.amount,0), NVL(fft.amount,0))), 0) spndng_from_coll_and_pya_s_amt
    FROM fv_facts_temp fft,
         fv_facts_ussgl_accounts ffa
   WHERE ffa.spndng_from_coll_and_pya_flag = 'Y'
     AND ffa.ussgl_account = fft.sgl_acct_number
     AND fft.treasury_symbol_id = p_treasury_symbol_id
     AND fft.fct_int_record_category = 'REPORTED_NEW'
     AND fft.fct_int_record_type = 'BLK_DTL';
  --   AND ffa.total_resource_be_flag IN ('S');

  -- Cursor to fetch amounts for Obligations as of 10/1
  -- Column 3 always use beginning balance
  CURSOR check8_col3_cur
  (
    p_treasury_symbol_id NUMBER
  )
  IS
  SELECT SUM(NVL(amount,0)) obligations_as_of_10_1_amt
    FROM fv_facts_temp fft,
         fv_facts_ussgl_accounts ffa
   WHERE ffa.obligations_as_of_10_1_flag = 'Y'
     AND ffa.ussgl_account = fft.sgl_acct_number
     AND fft.treasury_symbol_id = p_treasury_symbol_id
     AND fft.fct_int_record_category = 'REPORTED_NEW'
     AND fft.fct_int_record_type = 'BLK_DTL'
     AND fft.begin_end = 'B';

  -- Cursor to fetch amounts for Obligations Transferred and Obligations Period/End
  -- Column 4 and 5 always use ending balance
  CURSOR check8_col4_and_5_cur
  (
    p_treasury_symbol_id NUMBER
  )
  IS
  SELECT NVL(SUM(DECODE(ffa.obligations_transferred_flag, 'Y', NVL(amount,0), 0)),0) obligations_transferred_amt,
         NVL(SUM(DECODE(ffa.obligations_period_end_flag, 'Y', NVL(amount,0), 0)),0) obligations_period_end_amt
    FROM fv_facts_temp fft,
         fv_facts_ussgl_accounts ffa
   WHERE (
           ffa.obligations_transferred_flag = 'Y' OR
           ffa.obligations_period_end_flag = 'Y'
         )
     AND ffa.ussgl_account = fft.sgl_acct_number
     AND fft.treasury_symbol_id = p_treasury_symbol_id
     AND fft.fct_int_record_category = 'REPORTED_NEW'
     AND fft.fct_int_record_type = 'BLK_DTL'
     AND fft.begin_end = 'E';

  -- Cursor to fetch amounts
  -- for Disbursements and Collections (only Ending balance type)
  CURSOR check8_disb_colla_cur
  (
    p_treasury_symbol_id NUMBER
  )
  IS
  SELECT NVL(SUM(DECODE(ffa.disbursements_flag, 'Y', NVL(amount,0), 0)),0) disbursements_amt,
         NVL(SUM(DECODE(ffa.collections_flag, 'Y', NVL(amount,0), 0)),0) collections_amt
    FROM fv_facts_temp fft,
         fv_facts_ussgl_accounts ffa
   WHERE (
          ffa.disbursements_flag = 'Y' OR
          ffa.collections_flag = 'Y'
         )
     AND ffa.ussgl_account = fft.sgl_acct_number
     AND fft.treasury_symbol_id = p_treasury_symbol_id
     AND fft.fct_int_record_category = 'REPORTED_NEW'
     AND fft.fct_int_record_type = 'BLK_DTL'
     AND fft.begin_end = 'E'
     AND ffa.edck12_balance_type IN ('E' ,'S');--  by ks for bug bug 5328107

  -- Cursor to fetch amounts
  -- for Disbursements (only Ending - Beginning balance type)
  CURSOR check8_disbb_cur
  (
    p_treasury_symbol_id NUMBER
  )
  IS
  --SELECT NVL(SUM(DECODE(fft.begin_end, 'B', -1*NVL(fft.amount,0), NVL(fft.amount,0))), 0) beg_disbursements_amt
 -- above line commnted out by ks for bug bug 5328107
  SELECT NVL(SUM(DECODE(fft.begin_end, 'B', -1*NVL(fft.amount,0),0)), 0) beg_disbursements_amt
    FROM fv_facts_temp fft,
         fv_facts_ussgl_accounts ffa
   WHERE ffa.disbursements_flag = 'Y'
     AND ffa.ussgl_account = fft.sgl_acct_number
     AND fft.treasury_symbol_id = p_treasury_symbol_id
     AND fft.fct_int_record_category = 'REPORTED_NEW'
     AND fft.fct_int_record_type = 'BLK_DTL'
     AND ffa.edck12_balance_type = 'S';

  -- Cursor to fetch amounts
  -- for Collections (only Ending - Beginning balance type)
  CURSOR check8_collb_cur
  (
    p_treasury_symbol_id NUMBER
  )
  IS
  --  ks for bug bug 5328107
  SELECT NVL(SUM(DECODE(fft.begin_end, 'B', -1*NVL(fft.amount,0), 0)), 0) beg_collections_amt
    FROM fv_facts_temp fft,
         fv_facts_ussgl_accounts ffa
   WHERE ffa.collections_flag = 'Y'
     AND ffa.ussgl_account = fft.sgl_acct_number
     AND fft.treasury_symbol_id = p_treasury_symbol_id
     AND fft.fct_int_record_category = 'REPORTED_NEW'
     AND fft.fct_int_record_type = 'BLK_DTL'
     AND ffa.edck12_balance_type = 'S';

  l_obligations_incurred_amt     NUMBER;
  l_spndng_from_coll_and_pya_amt NUMBER;
  l_obligations_as_of_10_1_amt   NUMBER;
  l_obligations_transferred_amt  NUMBER;
  l_obligations_period_end_amt   NUMBER;
  l_disbursements_amt            NUMBER;
  l_collections_amt              NUMBER;
  l_beg_disbursements_amt        NUMBER;
  l_beg_collections_amt          NUMBER;

BEGIN
  init_vars;

  l_obligations_incurred_amt     := 0;
  l_spndng_from_coll_and_pya_amt := 0;
  l_obligations_as_of_10_1_amt   := 0;
  l_obligations_transferred_amt  := 0;
  l_obligations_period_end_amt   := 0;
  l_disbursements_amt            := 0;
  l_collections_amt              := 0;
  l_beg_disbursements_amt        := 0;
  l_beg_collections_amt          := 0;

  /*FOR check8_col1a_rec IN check8_col1a_cur (g_treasury_symbol_id) LOOP
    l_obligations_incurred_amt     := NVL(l_obligations_incurred_amt, 0) + NVL(check8_col1a_rec.obligations_incurred_be_amt, 0);
  END LOOP;*/

  FOR check8_col1b_rec IN check8_col1b_cur (g_treasury_symbol_id) LOOP
    l_obligations_incurred_amt     := NVL(l_obligations_incurred_amt, 0) + NVL(check8_col1b_rec.obligations_incurred_s_amt, 0);
  END LOOP;

/*  FOR check8_col2a_rec IN check8_col2a_cur (g_treasury_symbol_id) LOOP
    l_spndng_from_coll_and_pya_amt := NVL(l_spndng_from_coll_and_pya_amt, 0) + NVL(check8_col2a_rec.spndng_frm_coll_and_pya_be_amt, 0);
  END LOOP;*/

  FOR check8_col2b_rec IN check8_col2b_cur (g_treasury_symbol_id) LOOP
    l_spndng_from_coll_and_pya_amt := NVL(l_spndng_from_coll_and_pya_amt, 0) + NVL(check8_col2b_rec.spndng_from_coll_and_pya_s_amt, 0);
  END LOOP;

  FOR check8_col3_rec IN check8_col3_cur (g_treasury_symbol_id) LOOP
    l_obligations_as_of_10_1_amt   := NVL(l_obligations_as_of_10_1_amt, 0) + NVL(check8_col3_rec.obligations_as_of_10_1_amt, 0);
  END LOOP;

  FOR check8_col4_and_5_rec IN check8_col4_and_5_cur (g_treasury_symbol_id) LOOP
    l_obligations_transferred_amt  := NVL(l_obligations_transferred_amt, 0) + NVL(check8_col4_and_5_rec.obligations_transferred_amt, 0);
    l_obligations_period_end_amt   := NVL(l_obligations_period_end_amt, 0) + NVL(check8_col4_and_5_rec.obligations_period_end_amt, 0);
  END LOOP;


  FOR check8_disb_colla_rec IN check8_disb_colla_cur (g_treasury_symbol_id) LOOP
    l_disbursements_amt     := NVL(l_disbursements_amt, 0) + NVL(check8_disb_colla_rec.disbursements_amt, 0);
    l_collections_amt       := NVL(l_collections_amt, 0) + NVL(check8_disb_colla_rec.collections_amt, 0);
  END LOOP;

  fnd_file.put_line(fnd_file.log , 'Ending disbursement  ' || l_disbursements_amt);
  fnd_file.put_line(fnd_file.log , 'Ending collection    ' || l_collections_amt);

  FOR check8_disbb_rec IN check8_disbb_cur (g_treasury_symbol_id) LOOP
    l_beg_disbursements_amt     := NVL(check8_disbb_rec.beg_disbursements_amt, 0);
  END LOOP;

  FOR check8_collb_rec IN check8_collb_cur (g_treasury_symbol_id) LOOP
    l_beg_collections_amt       := NVL(check8_collb_rec.beg_collections_amt, 0);
  END LOOP;

  --- since we want to get only the acvity or ending_balances , we need to
  --  substract any begining disbursement or collection from ending_balaces;

  fnd_file.put_line(fnd_file.log , 'beg disbursement  ' || l_beg_disbursements_amt);
  fnd_file.put_line(fnd_file.log , 'beg collection    ' || l_beg_collections_amt);
  l_disbursements_amt := NVL(l_disbursements_amt, 0) + NVL(l_beg_disbursements_amt, 0);
  l_collections_amt :=   NVL(l_collections_amt, 0) + NVL(l_beg_collections_amt, 0);

  l_obligations_incurred_amt := -1*l_obligations_incurred_amt; --Cr balance report as + and Dr balance report as -
  l_obligations_as_of_10_1_amt := -1*l_obligations_as_of_10_1_amt; --Cr balance report as + and Dr balance report as -
  l_obligations_transferred_amt := -1*l_obligations_transferred_amt; --Cr balance report as + and Dr balance report as -
  l_obligations_period_end_amt := -1*l_obligations_period_end_amt;  --Cr balance report as + and Dr balance report as -

  IF ((NVL(l_obligations_incurred_amt, 0) -
       NVL(l_spndng_from_coll_and_pya_amt, 0) +
       NVL(l_obligations_as_of_10_1_amt, 0) +
       NVL(l_obligations_transferred_amt, 0) -
       NVL(l_obligations_period_end_amt, 0))
                    =
      (-1*(NVL(l_disbursements_amt, 0) +
       NVL(l_collections_amt, 0)))) THEN
    v_edit_check_status := 'Passed' ;
  ELSE
    v_edit_check_status := 'Failed' ;
    g_error_flag := 2;
  END IF;

  v_edit_check_number := 8;

  v_sgl_acct_number := '1Obligations Incurred';
  v_amount	  := l_obligations_incurred_amt;
  v_amount1	  := l_obligations_incurred_amt;
  create_log_record(v_log_text);

  v_sgl_acct_number := '2-   Spending from Collections and PYA';
  v_amount	  := l_spndng_from_coll_and_pya_amt;
  v_amount1	  := -1*l_spndng_from_coll_and_pya_amt;
  create_log_record(v_log_text);

  v_sgl_acct_number := '3+   Obligations as of 10/1';
  v_amount	  := l_obligations_as_of_10_1_amt;
  v_amount1	  := l_obligations_as_of_10_1_amt;
  create_log_record(v_log_text);

  v_sgl_acct_number := '4+/- Obligations Transferred';
  v_amount	  := l_obligations_transferred_amt;
  v_amount1	  := l_obligations_transferred_amt;
  create_log_record(v_log_text);

  v_sgl_acct_number := '5- Obligations Period End';
  v_amount	  := l_obligations_period_end_amt;
  v_amount1	  := -1*l_obligations_period_end_amt;
  create_log_record(v_log_text);

  v_edit_check_number := 9;
  v_sgl_acct_number := '6Disbursements (+)';
  v_amount	  := l_disbursements_amt;
  v_amount1	  := -1*l_disbursements_amt;
  create_log_record(v_log_text);

  v_sgl_acct_number := '7Collections (-)';
  v_amount	  := l_collections_amt;
  v_amount1	  := -1*l_collections_amt;
  create_log_record(v_log_text);

  v_edit_check_number := 8;
  create_status_record(v_edit_check_number, v_edit_check_status);
  -- Inserting dummy record for edit check 9
  v_edit_check_number := 9;
  create_status_record(v_edit_check_number, v_edit_check_status);

EXCEPTION
  WHEN OTHERS THEN
      v_log_text := SQLERRM;
      g_error_flag := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
END; --edit_check_8

-- Added the foll to fix bug 1974485
PROCEDURE edit_check_10 IS
  l_module_name VARCHAR2(200) := g_module_name || 'edit_check_10';

    l_total_amount        NUMBER := 0;

  CURSOR check10 IS
  SELECT fft.sgl_acct_number,
         SUM(NVL(fft.amount,0)) amount
    FROM fv_facts_temp fft,
	 fv_facts_ussgl_accounts ffacc
   WHERE ffacc.ussgl_account = fft.sgl_acct_number
     AND fft.treasury_symbol_id = g_treasury_symbol_id
     AND fft.fct_int_record_category = 'REPORTED_NEW'
     AND fft.fct_int_record_type = 'BLK_DTL'
     AND fft.begin_end = 'E'
     AND ffacc.cancelled_flag = 'Y'
   GROUP BY fft.sgl_acct_number;

BEGIN
        init_vars;
	v_edit_check_number := 10;

	   FOR check10_rec IN check10
	    LOOP
    /* Added space in from of account number to order the edit check 8 report information*/
		v_sgl_acct_number := ' '||check10_rec.sgl_acct_number;
		v_amount	  := check10_rec.amount;
		create_log_record(v_log_text);
	        l_total_amount := l_total_amount + check10_rec.amount;

	    END LOOP;

	IF l_total_amount = 0 THEN
  	   v_edit_check_status := 'Passed' ;
	 ELSE
  	   v_edit_check_status := 'Failed' ;
        END IF;

	create_status_record(v_edit_check_number, v_edit_check_status) ;

   EXCEPTION WHEN OTHERS THEN
      v_log_text := SQLERRM;
      g_error_flag := 2;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
END; --edit_check_10

PROCEDURE edit_check_11 IS
  l_module_name VARCHAR2(200) := g_module_name || 'edit_check_11';

  CURSOR neg_rec_pay_c IS
  SELECT ffacc.ussgl_account,
         NVL(sum(fft.amount),0),
         ffacc.ye_neg_receivables_flag,
         ffacc.natural_balance
    FROM fv_facts_temp fft,
	 fv_facts_ussgl_accounts ffacc
   WHERE (ffacc.ye_neg_receivables_flag = 'Y'
          OR ffacc.ye_neg_payables_flag = 'Y')
     AND ffacc.ussgl_account = fft.sgl_acct_number
     AND fft.treasury_symbol_id = g_treasury_symbol_id
     AND fft.fct_int_record_category = 'REPORTED_NEW'
     AND fft.fct_int_record_type = 'BLK_DTL'
     AND fft.begin_end = 'E'
  GROUP BY ffacc.ussgl_account, ffacc.ye_neg_receivables_flag, ffacc.natural_balance;

  CURSOR general_acc_c IS
  SELECT ffacc.ussgl_account, nvl(sum(fft.amount),0),
	 ffacc.natural_balance
    FROM fv_facts_temp fft,
         fv_facts_ussgl_accounts ffacc
   WHERE ffacc.ye_general_flag = 'Y'
     AND ffacc.ussgl_account = fft.sgl_acct_number
     AND fft.treasury_symbol_id = g_treasury_symbol_id
     AND fft.fct_int_record_category = 'REPORTED_NEW'
     AND fft.fct_int_record_type = 'BLK_DTL'
     AND fft.begin_end = 'E'
   GROUP BY ffacc.ussgl_account, ffacc.natural_balance;

  l_ussgl_account varchar2(30);
  l_amount        number;
  l_acc_type      varchar2(25);
  l_count         number;
  l_neg_receivables_flag varchar2(1);
  l_natural_balance FV_FACTS_USSGL_ACCOUNTS.NATURAL_BALANCE%TYPE;
  l_dc_ind        varchar2(1);

BEGIN

  init_vars;

  l_count := 0;
  v_edit_check_number := 11;

  --Fetch accounts with negative receivable and negative payables balances
  OPEN neg_rec_pay_c;

  LOOP
    FETCH neg_rec_pay_c
     INTO l_ussgl_account,
          l_amount,
          l_neg_receivables_flag,
          l_natural_balance;

    EXIT WHEN neg_rec_pay_c%NOTFOUND OR neg_rec_pay_c%NOTFOUND IS NULL;

      SELECT DECODE (l_neg_receivables_flag,'Y','NR','NP')
      INTO l_acc_type
      FROM DUAL;

      /* Added space in from of account number to order the edit check 8 report information*/
      v_sgl_acct_number := ' '||l_ussgl_account;
      v_amount		:= l_amount;
      v_dummy_var	:= l_acc_type;
--      create_log_record(v_log_text);

    IF (l_amount > 0) THEN
      l_dc_ind := 'D';
     ELSE
      l_dc_ind := 'C';
    END IF;

    IF (l_amount <> 0 AND l_dc_ind <> l_natural_balance) THEN

      create_log_record(v_log_text);

      l_count := l_count +1;

      --LGOEL: Update temp table if Edit check 11 failed
      update fv_facts_temp
      set    document_number = 'Y'
      where sgl_acct_number = l_ussgl_account
      and treasury_symbol_id = g_treasury_symbol_id
      and fct_int_record_category = 'REPORTED_NEW'
      and fct_int_record_type = 'BLK_DTL';

	-- Enable the foot note flag for this failed
	-- edit check
	UPDATE fv_facts_submission
	SET    foot_note_flag = 'Y'
	WHERE  treasury_symbol_id = g_treasury_symbol_id;

   END IF;

  END LOOP;

  CLOSE neg_rec_pay_c;

-- Initialize variables
	l_ussgl_account := NULL;
	l_amount 	:= 0;
	l_natural_balance := NULL;

  --Fetch General accounts which have a balance
  OPEN general_acc_c;

  LOOP

    FETCH general_acc_c
     INTO l_ussgl_account,
          l_amount,
          l_natural_balance;

    EXIT WHEN general_acc_c%NOTFOUND OR general_acc_c%NOTFOUND IS NULL;

  /* Added space in from of account number to order the edit check 8 report information*/
	v_sgl_acct_number := ' '||l_ussgl_account;
	v_amount	  := l_amount;
	v_dummy_var	  := 'GL';
--	create_log_record(v_log_text);

    IF (l_amount > 0) THEN
      l_dc_ind := 'D';
     ELSE
      l_dc_ind := 'C';
    END IF;

    IF (l_amount <> 0 ) THEN

	create_log_record(v_log_text);

      l_count := l_count +1;

      --LGOEL: Update temp table if Edit check 11 failed
      update fv_facts_temp
      set    document_number = 'Y'
      where sgl_acct_number = l_ussgl_account
      and treasury_symbol_id = g_treasury_symbol_id
      and fct_int_record_category = 'REPORTED_NEW'
      and fct_int_record_type = 'BLK_DTL';

	-- Enable the foot note flag for this failed
	-- edit check
	UPDATE fv_facts_submission
	SET    foot_note_flag = 'Y'
	WHERE  treasury_symbol_id = g_treasury_symbol_id;

   END IF;
  END LOOP;
  CLOSE general_acc_c;

  IF (l_count = 0) THEN
        v_edit_check_status := 'Passed' ;

	-- Disable the foot note flag for this passed
	-- edit check in case it has failed earlier
	UPDATE fv_facts_submission
	SET    foot_note_flag = 'N'
	WHERE  treasury_symbol_id = g_treasury_symbol_id;

   ELSE
	v_edit_check_status := 'Failed' ;
        IF (g_error_flag = 0) THEN
            g_error_flag := 1;
        END IF;
  END IF;

	create_status_record(v_edit_check_number, v_edit_check_status) ;

  EXCEPTION WHEN OTHERS THEN
    v_log_text := SQLERRM;
    IF (g_error_flag = 0) THEN
      g_error_flag := 1;
    END IF;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
END; --edit_check_11


PROCEDURE edit_check_12(p_facts_run_quarter number) IS
  l_module_name VARCHAR2(200) := g_module_name || 'edit_check_12';

  -- Cursor to fetch amounts
  -- for disbursement and collection accounts
  CURSOR check12 IS
  SELECT fft.sgl_acct_number,
	 ffa.disbursements_flag,
         ffa.collections_flag,
         ffa.edck12_balance_type,
	 sum(nvl(amount,0)) amount
    FROM fv_facts_temp fft,
	 fv_facts_ussgl_accounts ffa
   WHERE (ffa.disbursements_flag = 'Y' or ffa.collections_flag = 'Y')
     AND ffa.ussgl_account = fft.sgl_acct_number
     AND fft.treasury_symbol_id = g_treasury_symbol_id
     AND fft.fct_int_record_category = 'REPORTED_NEW'
     AND fft.fct_int_record_type = 'BLK_DTL'
     AND fft.begin_end = 'E'
    group by
          fft.sgl_acct_number,
	 ffa.disbursements_flag,
         ffa.collections_flag,
         ffa.edck12_balance_type;
  l_disbursements number := 0;
  l_collections   number := 0;
  l_net_outlays   number := 0;
  l_224_outlays   number := 0;
  v_begin_amount  number := 0;

BEGIN
	init_vars;
	v_edit_check_number := 12;

  --Fetch 224 Outlays
    select decode(p_facts_run_quarter,1,sf224_qtr1_outlay,
		  2,sf224_qtr2_outlay,3,sf224_qtr3_outlay,sf224_qtr4_outlay)
      into l_224_outlays
      from fv_treasury_symbols
     where treasury_symbol_id = g_treasury_symbol_id;

  IF (l_224_outlays is NULL) THEN

	v_amount := NULL;
	v_amount1 := NULL;
	v_amount2 := NULL;

	create_log_record(v_log_text);
        v_edit_check_status := 'Not Applicable' ;

	create_status_record(v_edit_check_number, v_edit_check_status) ;

    IF (g_error_flag = 0) then
      g_error_flag := 1;
    END IF;

   ELSE

      FOR check12_rec IN check12
	LOOP
     /* Added space in from of account number to order the edit check 8 report information*/
	    v_sgl_acct_number := ' '||check12_rec.sgl_acct_number;
	    v_begin_amount    := 0;

	    IF check12_rec.edck12_balance_type = 'S' THEN
                   SELECT sum(nvl(fft.amount,0))
		   INTO   v_begin_amount
    		   FROM   fv_facts_temp fft
   	 	   WHERE  fft.sgl_acct_number = check12_rec.sgl_acct_number
     		   AND fft.treasury_symbol_id = g_treasury_symbol_id
     		   AND fft.fct_int_record_category = 'REPORTED_NEW'
     		   AND fft.fct_int_record_type = 'BLK_DTL'
     		   AND fft.begin_end = 'B';
	    END IF;

	    IF 	check12_rec.collections_flag = 'Y' THEN

		v_amount1 	:= NVL(check12_rec.amount,0) - NVL(v_begin_amount,0);
		v_amount2	:= NULL;

		create_log_record(v_log_text);
		l_collections 	:= l_collections + v_amount1;
	     ELSIF
		check12_rec.disbursements_flag = 'Y' THEN
		v_amount2	:= NVL(check12_rec.amount,0) - NVL(v_begin_amount,0);
		v_amount1	:= NULL;

		create_log_record(v_log_text);
		l_disbursements := NVL(l_disbursements,0) + NVL(v_amount2,0);
	    END IF;

	END LOOP;

        l_net_outlays := -1*(NVL(l_disbursements,0) + NVL(l_collections,0));

	v_edit_check_number := 12.1;

  /* Added space in from of account number to order the edit check 8 report information*/
	v_sgl_acct_number := ' 1. Net Outlays';
	v_amount	  := l_net_outlays;
	create_log_record(v_log_text);

  /* Added space in from of account number to order the edit check 8 report information*/
	v_sgl_acct_number := ' 2. 224 Outlays';
	v_amount	  := l_224_outlays;
	create_log_record(v_log_text);

  /* Added space in from of account number to order the edit check 8 report information*/
	v_sgl_acct_number := ' Difference (1-2)';
	v_amount	  := (l_net_outlays - l_224_outlays);
	create_log_record(v_log_text);

        IF (l_net_outlays = l_224_outlays) THEN
        	v_edit_check_status := 'Passed' ;
  	  ELSE
    		v_edit_check_status := 'Failed' ;
      			g_error_flag := 2;
	END IF;

	v_edit_check_number := 12;
	create_status_record(v_edit_check_number, v_edit_check_status) ;
-- Inserting dummy record for edit check 12 Net outlays printing
	v_edit_check_number := 12.1;
	create_status_record(v_edit_check_number, v_edit_check_status) ;
  END IF;

  EXCEPTION WHEN OTHERS THEN
    v_log_text := SQLERRM;
    g_error_flag := 2;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);

END; --edit_check_12

PROCEDURE edit_check_13
IS
  l_control_acct_num VARCHAR2(30);
  l_auth_type        VARCHAR2(1);
  l_unexp_exp        VARCHAR2(1);
  l_beg_bal          NUMBER:=0;
  l_module_name VARCHAR2(200) := g_module_name || 'edit_check_13';
  l_closing_gp       VARCHAR2(2);
  l_edit_check_status VARCHAR2(1):='Y';
  exp_date DATE;
  whether_Exp VARCHAR2(1);
  beg_date DATE;
  close_date DATE;
  flg            VARCHAR2(1);
  sum_ending_bal NUMBER;
  l_temp_count   NUMBER;
  l_facts_insert_flg VARCHAR2(1);
  l_has_data_count NUMBER;
  l_prior_year NUMBER(15) := g_period_year-1;

  CURSOR closing_acct_c(p_closing_grp VARCHAR2)
  IS
     SELECT  SUM(tmp.amount) amt,
      clos.authority_code auth_type
      FROM fv_facts_temp tmp,
      fv_facts2_closing_validation clos
      WHERE tmp.treasury_symbol_id = g_treasury_symbol_id
      and tmp.fct_int_record_category='REPORTED_NEW'
      and tmp.fct_int_record_type='BLK_DTL'
      AND tmp.sgl_acct_number    = clos.ussgl_account
      AND clos.closing_grp  = p_closing_grp
      AND clos.closing_acct_flag ='Y'
      AND tmp.begin_end          = 'B'
      group by clos.authority_code;

 CURSOR end_bal_cur(p_whether_exp VARCHAR2,p_closing_grp VARCHAR2)
  IS
    SELECT bal.ending_bal,
    bal.ussgl_account   ,
    bal.authority_type
    FROM fv_facts2_retain_bal bal,
    fv_facts2_closing_validation clos
    WHERE bal.treasury_symbol_id = g_treasury_symbol_id
    AND clos.closing_grp           = p_closing_grp
    AND bal.closing_grp           = p_closing_grp
    AND bal.period_year            = l_prior_year
    --AND bal.period_num             =  p_period_num
    AND clos.ussgl_account         = bal.ussgl_account
    AND (clos.authority_code is null or bal.authority_type=clos.authority_code)
    AND (clos.expired_unexpired   IS NULL
    OR clos.expired_unexpired      = p_whether_exp);


  CURSOR get_all_closing_acct
  IS
   SELECT closing_grp, ussgl_account
   FROM fv_facts2_closing_validation
   WHERE closing_acct_flag='Y'
   ORDER BY closing_grp;

BEGIN
IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Entering Edit Check 13');
END IF;
--fnd_file.put_line(fnd_file.log , '********************** EDIT CHEK 13 BEGIN ************');
  init_vars;
  v_edit_check_number :=13;

  v_edit_check_status := 'Failed';
  l_auth_type :=NULL;
  -- check if treasury symbol has expired
   SELECT expiration_date
     INTO exp_date
     FROM fv_treasury_symbols
    WHERE treasury_symbol_id = g_treasury_symbol_id;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Expiration date for treasury id '||g_treasury_symbol_id||' is '||exp_date);
  END IF;
  -- fnd_file.put_line(fnd_file.log , 'exp_date ::' || exp_date);

  IF (exp_date IS NOT NULL) THEN
    SELECT start_date,
    end_date
    INTO beg_date,
    close_date
    FROM gl_period_statuses
    WHERE period_year = g_period_year
    AND period_num      = g_period_num
    AND application_id  =101
    AND set_of_books_id = g_ledger_id;

  IF(exp_date        <= close_date) THEN
      whether_Exp      := 'E';
    ELSE
      whether_Exp := 'U';
    END IF;

  ELSE
    whether_Exp := 'U';
  END IF;
 --  fnd_file.put_line(fnd_file.log , 'whether_Exp ::' || whether_Exp);

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,' Expired / Unexpired  -'||whether_Exp);
  END IF;

  SELECT COUNT(*)
     INTO l_temp_count
     FROM fv_facts_temp tmp,
    fv_facts2_closing_validation clos
    WHERE tmp.treasury_symbol_id = g_treasury_symbol_id
  AND tmp.fct_int_record_category='REPORTED_NEW'
  AND tmp.fct_int_record_type    ='BLK_DTL'
  AND tmp.sgl_acct_number        = clos.ussgl_account
  AND clos.closing_grp          IS NOT NULL
  AND clos.closing_acct_flag     ='Y'
  AND tmp.begin_end              = 'B';

  --FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_temp_count ::'||l_temp_count) ;
  -- Check whether the  hard edit check 13 checkbox selected in Federal Financial options
  -- Form
  BEGIN
    SELECT hard_edit_13_flag
     INTO flg
     FROM fv_facts2_Edit_params
    WHERE  set_of_books_id = g_ledger_id;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'No data found for hard edit check flag for period year-'||g_period_year,v_log_text);
     flg:='N';
  END;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,' Is  hard edit 13 flag on Federal financial options form selected ?  '||flg);
  END IF;
  --fnd_file.put_line(fnd_file.log , 'flg  ::' || flg);
  /* Iterating over the closing_act_c and calculating the begining bal and end balance
  * Also populating the FV_FACTS_TEMP table.
  * Report will use this table to show data.
  */
  FOR get_all_closing_rec IN get_all_closing_acct
  LOOP

    l_beg_bal          := 0;
    v_amount1          := l_beg_bal;
    l_control_acct_num := get_all_closing_rec.ussgl_account;
    l_closing_gp       := get_all_closing_rec.closing_grp;
    v_beg_bal_sggl_acc :=l_control_acct_num;
    v_closing_grp      := l_closing_gp;

    --fnd_file.put_line(fnd_file.log , 'beginning sgl account number  ::Begining balance ::l_auth_type::l_closing_gp' || l_control_acct_num||
     --'::'||l_beg_bal||'::'||l_auth_type||'::'||l_closing_gp);

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,' l_control_acct_num  ::l_closing_gp -- '|| l_control_acct_num||
     '::'||l_closing_gp);
    END IF;

    -- Retreiving the values for a beginning balances for the current year
    -- For a closing group
    OPEN closing_acct_c(l_closing_gp);
      IF closing_acct_c%NOTFOUND then
       l_beg_bal          :=0;
       v_amount1          :=l_beg_bal;
       l_auth_type        :=null;
       l_unexp_exp        :=null;
     ELSE
	LOOP
	  FETCH closing_acct_c INTO l_beg_bal,l_auth_type;
	  v_amount1       :=l_beg_bal;
	  EXIT WHEN  closing_acct_c%NOTFOUND;
	END LOOP;
     END IF;
     CLOSE closing_acct_c;

    v_sgl_acct_number:='';
    sum_ending_bal   :=0;
    FOR end_bal_rec  IN end_bal_cur(whether_Exp,l_closing_gp)
    LOOP
      l_facts_insert_flg:='N';
      IF (l_auth_type IS NOT NULL) THEN
        IF(l_auth_type   =end_bal_rec.authority_type) THEN
          sum_ending_bal:=sum_ending_bal + end_bal_rec.ending_bal;
          l_facts_insert_flg:='Y';
          -- fnd_file.put_line(fnd_file.log ,'sum_ending_bal ::l_auth_type ::end_bal_rec.authority_type ::'||sum_ending_bal||'::'||l_auth_type||'::'||end_bal_rec.authority_type);
        END IF;
      ELSE
        sum_ending_bal:=sum_ending_bal + end_bal_rec.ending_bal;
        l_facts_insert_flg:='Y';
        --fnd_file.put_line(fnd_file.log ,'sum_ending_bal ::l_auth_type ::'||sum_ending_bal||':: null');
      END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,' l_facts_insert_flg  :: Total Ending Balance  -- '|| l_facts_insert_flg||
     '::'||sum_ending_bal);
    END IF;

      IF l_facts_insert_flg = 'Y' THEN
          v_sgl_acct_number:=end_bal_rec.ussgl_account;
          v_amount         :=end_bal_rec.ending_bal;
         -- fnd_file.put_line(fnd_file.log ,'v_sgl_acct_number ::v_amount::'||v_sgl_acct_number||'::'||v_amount);
          create_log_record(v_log_text);
      END IF ;
    END LOOP;

    /*
     * Comparing the ending balances of prior year and beginning balances of current year.
     * If the balances are not equal then status on FACTS II Submission form can be either
     * option edit checks failed or Required edit checks failed.It depends on the Hard edit
     * check flag selected on Federal Financial options forms
     */
   IF (sum_ending_bal <> l_beg_bal) THEN
     l_edit_check_status:='N';
      IF (flg ='Y' or g_error_flag = 2) THEN
        g_error_flag      := 2; -- Hard edit failed, so bulk file cannot be generated
      ELSE
        g_error_flag :=1; -- Not a hard edit, so bulk file can be generated
      END IF;
    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,' Error flag(1- optional edit fail,2- failed,3-passed)   :: Total Ending Balance  -- '|| g_error_flag||
     '::'||sum_ending_bal);
    END IF;
    -- To display layout when no value inserted
    -- in to fv_facts_temp table.
      SELECT count(*) into l_has_data_count
      FROM fv_facts_temp
      WHERE treasury_symbol_id =g_treasury_symbol_id
      AND edit_check_number=13
      AND closing_grp =l_closing_gp;

      IF (l_has_data_count=0) THEN
         v_sgl_acct_number:='';
         v_amount:=0;
         create_log_record(v_log_text);
      END IF;

   -- fnd_file.put_line(fnd_file.log ,'v_edit_check_status ::g_error_flag::'||v_edit_check_status||'::'||g_error_flag);
  END LOOP;

  IF l_edit_check_status='N' THEN
      v_edit_check_status := 'Failed';
  ELSE
      v_edit_check_status := 'Passed';
  END IF;

  create_status_record(v_edit_check_number, v_edit_check_status);
  --fnd_file.put_line(fnd_file.log , '********************** EDIT CHEK 13 END ************');
EXCEPTION
WHEN OTHERS THEN
  v_log_text := 'Exception when others in Edit Check 13. SQLCODE: '|| SQLCODE ;
  FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;
  v_log_text := 'SQLERRM: '|| SQLERRM ;
  FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,' Error flag(1- optional edit fail,2- failed,3-passed)   :: Total Ending Balance  -- '|| g_error_flag||
     '::'||sum_ending_bal);
  END IF;
  g_error_flag := 2;
END edit_check_13;

PROCEDURE edit_check_14 IS
l_control_acct_amt	NUMBER	:= 0;
control_sum NUMBER :=0;
l_summation_acct_amt NUMBER  := 0;
summation_sum NUMBER :=0;
flg varchar2(1);

CURSOR control_check1 IS
SELECT nvl(amount,0) amt, facts.sgl_acct_number control_acct
FROM  	fv_facts_temp facts, fv_facts_ussgl_accounts uss
WHERE	facts.treasury_symbol_id = g_treasury_symbol_id
AND uss.ussgl_account = facts.sgl_acct_number
AND uss.reclassification_ctrl_flag = 'Y'  AND begin_end = 'E'
AND   amount <> 0 and facts.fct_int_record_category = 'REPORTED_NEW'
AND   	facts.fct_int_record_type = 'BLK_DTL'	ORDER BY sgl_acct_number;

CURSOR sum_check1 IS
SELECT nvl(amount,0) amt, facts.sgl_acct_number summation_acct
FROM  	fv_facts_temp facts, fv_facts_ussgl_accounts uss
WHERE	facts.treasury_symbol_id = g_treasury_symbol_id
AND uss.ussgl_account = facts.sgl_acct_number
AND uss.reclassification_sum_acc_flag = 'Y'     AND  begin_end = 'E'
AND   amount <> 0 and facts.fct_int_record_category = 'REPORTED_NEW'
AND   	facts.fct_int_record_type = 'BLK_DTL'	ORDER BY sgl_acct_number;

BEGIN
init_vars;
v_edit_check_number := 14;
v_edit_check_number := 14.1;
v_sgl_acct_number := null;
for check1_rec in control_check1
loop
v_amount1:= check1_rec.amt;
l_control_acct_amt := check1_rec.amt;
v_sgl_acct_number :=  ' '||check1_rec.control_acct;
control_sum := control_sum + l_control_acct_amt;

create_log_record(v_log_text);
end loop;
v_edit_check_number := 14;
v_sgl_acct_number := null;

IF (control_sum <> 0) THEN
for check2_rec in sum_check1
loop
v_amount1:= check2_rec.amt;
l_summation_acct_amt := check2_rec.amt;
v_sgl_acct_number := ' '||check2_rec.summation_acct;
summation_sum := summation_sum + l_summation_acct_amt;

create_log_record(v_log_text);
end loop;
IF (abs(summation_sum) < abs(control_sum)) THEN
v_edit_check_status := 'Failed';

select hard_edit_14_flag into flg from fv_facts2_Edit_params where set_of_books_id = g_ledger_id ;


IF (flg ='Y' or g_error_flag = 2) THEN
g_error_flag := 2; -- Hard edit failed, so bulk file cannot be generated
ELSE
g_error_flag :=1; -- Not a hard edit, so bulk file can be generated
END IF;
ELSE
v_edit_check_status := 'Passed';
END IF;

ELSE
if(g_error_flag <> 2) then
g_error_flag := 1; -- Need not perform edit check 14 if control account is 0
end if;
v_edit_check_status := 'Not Needed';
END IF;

create_status_record(v_edit_check_number, v_edit_check_status) ;
v_edit_check_number := 14.1;
create_status_record(v_edit_check_number, v_edit_check_status) ;

EXCEPTION WHEN OTHERS THEN
v_log_text := 'Exception when others in Edit Check 14. SQLCODE: '|| SQLCODE ;
FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

v_log_text := 'SQLERRM: '|| SQLERRM ;
FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

g_error_flag := 2;
END; --edit_check_14
-- This is the main procedure which calls all the edit check procedures

procedure perform_edit_checks (errbuf OUT NOCOPY varchar2,
			       retcode OUT NOCOPY number,
                               p_treasury_symbol_id IN number,
			       p_facts_run_quarter  IN number,
			       p_rep_fiscal_yr    IN NUMBER,
             p_period_num              IN NUMBER,
             p_ledger_id   IN NUMBER)
is
  l_module_name VARCHAR2(200) := g_module_name || 'perform_edit_checks';
-- Added to fix 1974485
	l_cancel_date  NUMBER(4);
  no_rec        NUMBER;

begin

    fnd_file.put_line(FND_file.LOG,'Running 7/24 debug version');
  g_error_flag := 0;
  g_treasury_symbol_id := p_treasury_symbol_id;
  g_ledger_id          := p_ledger_id;
  g_period_num         := p_period_num;
  g_period_year        :=p_rep_fiscal_yr;

    SELECT to_number(to_char(cancellation_date,'YYYY'))
    INTO   l_cancel_date
    FROM   fv_treasury_symbols
    WHERE  treasury_symbol_id = g_treasury_symbol_id;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      v_log_text := 'Edit Check process start...' ;
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message1',v_log_text);
      v_log_text := ' ' ;
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message1',v_log_text);
    END IF;

  edit_check_1;
  edit_check_2;
  edit_check_3;
  edit_check_8;
  if (p_facts_run_quarter = 4) then
    edit_check_4;
    edit_check_5;
    edit_check_6 (p_ledger_id);
    edit_check_7;

-- Added to fix 1974485

	IF l_cancel_date = p_rep_fiscal_yr
	  THEN edit_check_10;
	 ELSE
	   init_vars;

	   v_edit_check_number := 10;
 	   v_edit_check_status := 'Not Applicable' ;

	create_status_record(v_edit_check_number, v_edit_check_status) ;
--	create_log_record(v_log_text);

	END IF;

    edit_check_11;

 else

-- Changed log text for bug 2053780

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    v_log_text := 'Edit Checks 4,5,6,7,10 and 11 are not needed' ;
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message2',v_log_text);
  END IF;

	v_log_text := ' ';
	v_edit_check_status := 'Not Needed';

	v_edit_check_number := 4;
	create_status_record(v_edit_check_number, v_edit_check_status) ;

	v_edit_check_number := 5;
	create_status_record(v_edit_check_number, v_edit_check_status) ;

	v_edit_check_number := 6;
	create_status_record(v_edit_check_number, v_edit_check_status) ;

	v_edit_check_number := 7;
	create_status_record(v_edit_check_number, v_edit_check_status) ;

	v_edit_check_number := 10;
	create_status_record(v_edit_check_number, v_edit_check_status) ;

	v_edit_check_number := 11;
	create_status_record(v_edit_check_number, v_edit_check_status) ;

  end if;

  edit_check_12(p_facts_run_quarter);

  SELECT COUNT(*)
  INTO no_rec
  FROM fv_facts2_edit_params
  WHERE set_of_books_id = p_ledger_id
  AND period_year         = p_rep_fiscal_yr
  AND period_num          = p_period_num;

  edit_check_13;

  IF(no_rec = 1) THEN
    edit_check_14;
  ELSE
    v_edit_check_status := 'Not Needed';
    v_edit_check_number := 14;
    create_status_record(v_edit_check_number, v_edit_check_status) ;
    v_edit_check_number := 14.1;
    create_status_record(v_edit_check_number, v_edit_check_status) ;
  END IF;

  retcode := g_error_flag;
  if (retcode = 1) then
    errbuf := 'Soft Edit Check Failed.' ;
    v_log_text := 'Soft Edit Check Failed.' ;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',errbuf);

  elsif (retcode = 2) then
    errbuf := 'Hard Edit Check Failed';
    v_log_text := 'Hard Edit Check Failed.' ;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error2',errbuf);

  else
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      v_log_text := 'Edit Check Passed.' ;
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message4',v_log_text);
    END IF;
  end if;
  -- SF133 enhancement
  if (fv_sf133_noyear.sf133_runmode = 'NO' and fv_sf133_oneyear.sf133_runmode = 'NO')then
  populate_bal_ret_tbl;
  end if;
EXCEPTION
  WHEN OTHERS THEN
    v_log_text := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
    RAISE;
end; --perform_edit_checks

-------------------------------------------------------------------------
--		Procedure CREATE_STATUS_RECORD
-------------------------------------------------------------------------
--	This Procedure inserts the status information into
--	 fv_facts_edit_check_status
-------------------------------------------------------------------------

PROCEDURE create_status_record (p_edit_check_number NUMBER,
				p_edit_check_status VARCHAR2)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'create_status_record';

BEGIN
	INSERT INTO fv_facts_edit_check_status
		(treasury_symbol_id,
		 edit_check_number,
		 edit_check_status)
 	 VALUES (g_treasury_symbol_id,
		 p_edit_check_number,
		 p_edit_check_status) ;
EXCEPTION
    when others then
        v_log_text := SQLERRM;
        g_error_flag    :=      sqlcode ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
        return;
END; -- create_status_record
-------------------------------------------------------------------------
--		Procedure CREATE_LOG_RECORD
-------------------------------------------------------------------------
--	This Procedure inserts the log information into the FACTS temp
-- table under the record category 'EDIT_CHECK_LOG_INFO'
-------------------------------------------------------------------------
Procedure CREATE_LOG_RECORD (text varchar2)
is
  l_module_name VARCHAR2(200) := g_module_name || 'CREATE_LOG_RECORD';
Begin
    v_log_counter := v_log_counter + 1 ;

    Insert into FV_FACTS_TEMP
        (FCT_INT_RECORD_CATEGORY	,
	 TREASURY_SYMBOL_ID		,
	 TBAL_ACCT_NUM			,
	 FACTS_REPORT_INFO		,
	 edit_check_number		,
	 amount				,
	 amount1			,
	 amount2			,
	 sgl_acct_number		,
	 budget_function,
   closing_grp    ,
   SGL_BEG_BAL_ACCT_NUM)
    Values
	('FACTS2_EDIT_CHECK_LOG'	,
	 g_treasury_symbol_id		,
	 v_log_counter			,
	 text				,
	 v_edit_check_number		,
	 v_amount			,
	 v_amount1			,
	 v_amount2			,
	 v_sgl_acct_number		,
	 v_dummy_var             ,
   v_closing_grp ,
   v_beg_bal_sggl_acc
   ) ;
EXCEPTION
    When Others Then
        v_log_text := SQLERRM;
        g_error_flag    :=      sqlcode ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',v_log_text);
        return;
END CREATE_LOG_RECORD ;
------------------------------------------

PROCEDURE populate_bal_ret_tbl
IS
  /* Commented for bug 8768896
  CURSOR ret_bal_c
  IS
    SELECT tmp.amount      ,
      tmp.sgl_acct_number   ,
      tmp.treasury_symbol_id,
      att.authority_type,
      clos.closing_grp
    FROM fv_facts_temp tmp,
    fv_facts_attributes att,
    fv_facts2_closing_validation clos
    WHERE tmp.treasury_symbol_id = g_treasury_symbol_id
    AND tmp.begin_end              = 'E'
    AND tmp.fct_int_record_category='REPORTED_NEW'
    AND tmp.fct_int_record_type='BLK_DTL'
    AND tmp.sgl_acct_number        = att.ussgl_acct_number
    AND clos.ussgl_Account        = att.ussgl_acct_number
    AND att.authority_type        = tmp.authority_type
    AND att.set_of_books_id = g_ledger_id
    AND clos.closing_grp          IS NOT NULL
    AND (clos.authority_code is null or tmp.authority_type  = clos.authority_code) ;


   CURSOR ret_bal_c
  IS
    SELECT tmp.amount      ,
      tmp.sgl_acct_number   ,
      tmp.treasury_symbol_id,
      att.authority_type,
      clos.closing_grp
    FROM fv_facts_temp tmp,
    fv_facts_attributes att,
    fv_facts2_closing_validation clos
    WHERE tmp.treasury_symbol_id = g_treasury_symbol_id
    AND tmp.begin_end              = 'E'
    AND tmp.fct_int_record_category='REPORTED_NEW'
    AND tmp.fct_int_record_type='BLK_DTL'
    AND tmp.sgl_acct_number        = att.facts_acct_number
    AND clos.ussgl_Account        = att.facts_acct_number
    AND att.set_of_books_id = g_ledger_id
    AND clos.closing_grp          IS NOT NULL
    AND (nvl(clos.authority_code,'N')='N' or tmp.authority_type  = clos.authority_code)
    AND (nvl(att.authority_type,'N')='N' or att.authority_type  = tmp.authority_type);
*/

   CURSOR ret_bal_c IS
      SELECT tmp.amount      ,
       tmp.sgl_acct_number   ,
       tmp.treasury_symbol_id,
       tmp.authority_type,
      clos.closing_grp
     FROM fv_facts_temp tmp,
          fv_facts2_closing_validation clos
     WHERE tmp.treasury_symbol_id = g_treasury_symbol_id
     AND tmp.begin_end              = 'E'
     AND tmp.fct_int_record_category='REPORTED_NEW'
     AND tmp.fct_int_record_type='BLK_DTL'
     and clos.ussgl_Account = tmp.sgl_acct_number
     -- Added by Vijay
     AND ( nvl(tmp.authority_type,'N')='N' or nvl(clos.authority_code,'N')='N'
            or tmp.authority_type=clos.authority_code)
     AND clos.closing_grp IS NOT NULL;


  l_rec_exists    NUMBER :=0;
  l_module_name   VARCHAR2(200);
  l_end_bal       NUMBER:=0;
  l_ussgl_account VARCHAR2(30);
  l_treasury_symb NUMBER;
  l_auth_type     VARCHAR2(1);
  l_period_name   VARCHAR2(15);
  l_count         NUMBER;
  l_test          NUMBER    :=0;
  l_user_id       NUMBER(15):=FND_GLOBAL.USER_ID;
  l_closing_grp   VARCHAR2(2);
BEGIN
  l_module_name := g_module_name || 'populate_bal_ret_tbl';
  -- Checking for the period entry in fv_Facts2_edit_params table
  -- If there is an entry then empty the FV_FACTS2_RETAIN_BAL table
  --fnd_file.put_line(fnd_file.log , '**********************POPULATE RETAIN BAL 13 BEGIN ************');
   SELECT COUNT(*)
     INTO l_rec_exists
     FROM fv_Facts2_edit_params
    WHERE set_of_books_id = g_ledger_id
  AND period_year         = g_period_year
  AND period_num          = g_period_num;
  -- Getting the
  /*select period_name into l_period_name  from gl_period_statuses
  where period_name = p_rep_fiscal_yr  and  period_num = p_period_num
  and application_id=101 and set_of_books_id = p_ledger_id;*/
  --fnd_file.put_line(fnd_file.log , '**********************l_rec_exists ::'||l_rec_exists);
  IF (l_rec_exists = 1) THEN
    BEGIN
       DELETE
       FROM FV_FACTS2_RETAIN_BAL
       WHERE treasury_symbol_id = g_treasury_symbol_id
       AND period_year <> g_period_year-1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'No data found for treasury symbol id '||g_treasury_symbol_id,v_log_text);
    END;
/*    SELECT COUNT(*)
    INTO l_count
    FROM fv_facts_temp tmp,
    fv_facts_attributes att,
    fv_facts2_closing_validation clos
    WHERE tmp.treasury_symbol_id = g_treasury_symbol_id
    AND tmp.begin_end              = 'E'
    AND tmp.sgl_acct_number        = att.ussgl_acct_number
    AND tmp.sgl_acct_number        = clos.ussgl_Account
    AND clos.closing_grp          IS NOT NULL;*/
    --fnd_file.put_line(fnd_file.log , l_module_name||'l_count ::'||l_count);
    -- Using cursor ret_bal_c to populate the fv_facts2_retain_bal table
    FOR ret_bal_rec IN ret_bal_c
    LOOP
      l_end_bal      :=ret_bal_rec.amount;
      l_ussgl_account:=ret_bal_rec.sgl_acct_number;
      l_treasury_symb:=ret_bal_rec.treasury_symbol_id;
      l_auth_type    :=ret_bal_rec.authority_type;
      l_closing_grp :=ret_bal_rec.closing_grp;

      /*fnd_file.put_line(fnd_file.log , l_module_name||'l_end_bal ::'||l_end_bal);
      fnd_file.put_line(fnd_file.log , l_module_name||'l_ussgl_account ::'||l_ussgl_account);
      fnd_file.put_line(fnd_file.log , l_module_name||'l_treasury_symb ::'||l_treasury_symb);
      fnd_file.put_line(fnd_file.log , l_module_name||'l_auth_type ::'||l_auth_type);*/
      -- Inserting the ending balance values to FV_FACTS2_RETAIN_BAL table
       INSERT
         INTO FV_FACTS2_RETAIN_BAL
        (
          USSGL_ACCOUNT     ,
          TREASURY_SYMBOL_ID,
          AUTHORITY_TYPE    ,
          ENDING_BAL        ,
          period_num,
	  closing_grp,
          period_year,
          LAST_UPDATE_DATE  ,
          CREATION_DATE     ,
          CREATED_BY        ,
          last_updated_by
        )
        VALUES
        (
          l_ussgl_account,
          l_treasury_symb,
          l_auth_type    ,
          l_end_bal      ,
          g_period_num   ,
	  l_closing_grp,
          g_period_year  ,
          sysdate        ,
          sysdate        ,
          l_user_id      ,
          l_user_id
        );
    END LOOP;
  END IF;
END populate_bal_ret_tbl;
end fv_facts_edit_check; -- Package body


/