--------------------------------------------------------
--  DDL for Package Body FVFCCHKB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FVFCCHKB_PKG" AS
--$Header: FVFCCHKB.pls 115.37 2002/04/03 14:18:43 pkm ship   $

g_error_flag         NUMBER(1);
g_treasury_symbol_id NUMBER(15);

-- Addded on 07/13/2000 By Supadman
-- Variable to hold log text.
v_log_text	Varchar2(416) ;
v_log_counter	Number := 0 ;


	v_edit_check_number  	NUMBER(2);
	v_edit_check_status 	VARCHAR2(25);
	v_amount	 	NUMBER := 0;
	v_amount1	 	NUMBER := 0;
	v_amount2	 	NUMBER := 0;
	v_sgl_acct_number	fv_facts_temp.sgl_acct_number%TYPE;
	v_dummy_var		VARCHAR2(3);
	v_row_count		NUMBER := 0;



PROCEDURE Create_log_record(text varchar2) ;

PROCEDURE create_status_record(p_edit_check_number number,
			       p_edit_check_status varchar2) ;

-- Procedure to initialize variables
PROCEDURE init_vars IS

   BEGIN
	v_edit_check_number  	:= NULL;
	v_edit_check_status	:= NULL;
	v_amount	  	:= 0   ;
	v_amount1		:= 0   ;
	v_amount2		:= 0   ;
	v_sgl_acct_number 	:= NULL;
	v_log_text	  	:= ' ' ;
	v_dummy_var		:= NULL;
	v_row_count 		:= 0   ;

   END init_vars;

PROCEDURE edit_check_1 IS

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

		v_sgl_acct_number := check1_rec.sgl_acct_number;
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
    v_log_text := 'Exception when others in Edit Check 1. SQLCODE: '|| SQLCODE ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    v_log_text := 'SQLERRM: '|| SQLERRM ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    g_error_flag := 2;
END; --edit_check_1


PROCEDURE edit_check_2 IS

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

	v_sgl_acct_number := l_ussgl_account;
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
  v_log_text := 'Exception when others in Edit Check 2. SQLCODE: '|| SQLCODE ;
  FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

  v_log_text := 'SQLERRM: '|| SQLERRM ;
  FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    g_error_flag := 2;
END; --edit_check_2


PROCEDURE edit_check_3 IS

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
		v_sgl_acct_number := check3_rec.sgl_acct_number;

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
    v_log_text := 'Exception when others in Edit Check 3. SQLCODE: '|| SQLCODE ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    v_log_text := 'SQLERRM: '|| SQLERRM ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    g_error_flag := 2;
END; --edit_check_3


PROCEDURE edit_check_4 IS

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
	v_sgl_acct_number := l_sgl_acct_number;
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

    v_log_text := 'Exception when others in Edit Check 4. SQLCODE: '|| SQLCODE ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    v_log_text := 'SQLERRM: '|| SQLERRM ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    g_error_flag := 2;
END;  --edit_check_4

PROCEDURE edit_check_5 IS

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

	    v_sgl_acct_number := check5_rec.sgl_acct_number;

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

    v_log_text := 'Exception when others in Edit Check 5. SQLCODE: '|| SQLCODE ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    v_log_text := 'SQLERRM: '|| SQLERRM ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    g_error_flag := 2;
END; --edit_check_5


PROCEDURE edit_check_6 IS

  l_set_of_books_id  NUMBER;

  CURSOR rt7_codes_c IS
  SELECT ffa.rt7_code_id,
         ffc.rt7_code,
         ffa.preclosing_unexpended_amt
    FROM fv_facts_authorizations ffa,
	 fv_facts_rt7_codes ffc
   WHERE ffa.treasury_symbol_id = g_treasury_symbol_id
     AND ffa.rt7_code_id = ffc.rt7_code_id
     AND ffa.set_of_books_id = l_set_of_books_id;

  l_rt7_code_id      number(15);
  l_rt7_code         varchar2(3);
  l_accounts_balance number;
  l_unexp_amount     number;
  l_count            number;

BEGIN

  init_vars;
  v_edit_check_number := 6;

  l_set_of_books_id  := TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID'));
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

	v_sgl_acct_number := '1. Preclosing Unexp Amt';
	v_amount	  := l_unexp_amount;
	create_log_record(v_log_text);

	v_sgl_acct_number := '2. Sum of Account Balance';
	v_amount	  := l_accounts_balance;
	create_log_record(v_log_text);

	v_sgl_acct_number := 'Difference (1-2)';
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

    v_log_text := 'Exception when others in Edit Check 6. SQLCODE: '|| SQLCODE ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    v_log_text := 'SQLERRM: '|| SQLERRM ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    g_error_flag := 2;
END; --edit_check_6


PROCEDURE edit_check_7 IS

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
		v_sgl_acct_number := check7_rec.sgl_acct_number;
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

    v_log_text := 'Exception when others in Edit Check 7. SQLCODE: '|| SQLCODE ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    v_log_text := 'SQLERRM: '|| SQLERRM ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    g_error_flag := 2;
END; -- edit_check_7

-- Added the foll to fix bug 1974485
PROCEDURE edit_check_10 IS

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
		v_sgl_acct_number := check10_rec.sgl_acct_number;
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

  	      v_log_text := 'Exception when others in Edit Check 10. SQLCODE: '||SQLCODE ;
  	      FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

  	      v_log_text := 'SQLERRM: '||SQLERRM ;
  	      FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

	      g_error_flag := 2;
END; --edit_check_10

PROCEDURE edit_check_11 IS

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

      v_sgl_acct_number := l_ussgl_account;
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

	v_sgl_acct_number := l_ussgl_account;
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

    v_log_text := 'Exception when others in Edit Check 11. SQLCODE: '||SQLCODE ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    v_log_text := 'SQLERRM: '|| SQLERRM ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    IF (g_error_flag = 0) THEN
      g_error_flag := 1;
    END IF;
END; --edit_check_11


PROCEDURE edit_check_12(p_facts_run_quarter number) IS

  -- Cursor to fetch amounts
  -- for disbursement and collection accounts
  CURSOR check12 IS
  SELECT fft.sgl_acct_number,
	 ffa.disbursements_flag,
         ffa.collections_flag,
         ffa.edck12_balance_type,
	 nvl(amount,0) amount
    FROM fv_facts_temp fft,
	 fv_facts_ussgl_accounts ffa
   WHERE (ffa.disbursements_flag = 'Y' or ffa.collections_flag = 'Y')
     AND ffa.ussgl_account = fft.sgl_acct_number
     AND fft.treasury_symbol_id = g_treasury_symbol_id
     AND fft.fct_int_record_category = 'REPORTED_NEW'
     AND fft.fct_int_record_type = 'BLK_DTL'
     AND fft.begin_end = 'E';

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
	    v_sgl_acct_number := check12_rec.sgl_acct_number;
	    v_begin_amount    := 0;

	    IF check12_rec.edck12_balance_type = 'S' THEN
                   SELECT fft.amount
		   INTO   v_begin_amount
    		   FROM   fv_facts_temp fft
   	 	   WHERE  fft.sgl_acct_number = check12_rec.sgl_acct_number
     		   AND fft.treasury_symbol_id = g_treasury_symbol_id
     		   AND fft.fct_int_record_category = 'REPORTED_NEW'
     		   AND fft.fct_int_record_type = 'BLK_DTL'
     		   AND fft.begin_end = 'B';
	    END IF;

	    IF 	check12_rec.collections_flag = 'Y' THEN

		v_amount1 	:= check12_rec.amount - v_begin_amount;
		v_amount2	:= NULL;

		create_log_record(v_log_text);
		l_collections 	:= l_collections + v_amount1;
	     ELSIF
		check12_rec.disbursements_flag = 'Y' THEN
		v_amount2	:= check12_rec.amount - v_begin_amount;
		v_amount1	:= NULL;

		create_log_record(v_log_text);
		l_disbursements := l_disbursements + v_amount2;
	    END IF;

	END LOOP;

        l_net_outlays := -1*(l_disbursements + l_collections);

	v_edit_check_number := 13;

	v_sgl_acct_number := '1. Net Outlays';
	v_amount	  := l_net_outlays;
	create_log_record(v_log_text);

	v_sgl_acct_number := '2. 224 Outlays';
	v_amount	  := l_224_outlays;
	create_log_record(v_log_text);

	v_sgl_acct_number := 'Difference (1-2)';
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
	v_edit_check_number := 13;
	create_status_record(v_edit_check_number, v_edit_check_status) ;
  END IF;

  EXCEPTION WHEN OTHERS THEN

    v_log_text := 'Exception when others in Edit Check 12. SQLCODE: '||SQLCODE ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    v_log_text := 'SQLERRM: '|| SQLERRM ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

      g_error_flag := 2;
END; --edit_check_12


-- This is the main procedure which calls all the edit check procedures

procedure perform_edit_checks (errbuf out varchar2,
			       retcode out number,
                               p_treasury_symbol_id IN number,
			       p_facts_run_quarter  IN number,
			       p_rep_fiscal_yr    IN NUMBER)
is
-- Added to fix 1974485
	l_cancel_date  NUMBER(4);

begin

  g_error_flag := 0;
  g_treasury_symbol_id := p_treasury_symbol_id;

    SELECT to_number(to_char(cancellation_date,'YYYY'))
    INTO   l_cancel_date
    FROM   fv_treasury_symbols
    WHERE  treasury_symbol_id = g_treasury_symbol_id;

    v_log_text := 'Edit Check process start...' ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

    v_log_text := ' ' ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

  edit_check_1;
  edit_check_2;
  edit_check_3;
  if (p_facts_run_quarter = 4) then
    edit_check_4;
    edit_check_5;
    edit_check_6;
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

    v_log_text := 'Edit Checks 4,5,6,7,10 and 11 are not needed' ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

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

  retcode := g_error_flag;
  if (retcode = 1) then
    errbuf := 'Soft Edit Check Failed.' ;
    v_log_text := 'Soft Edit Check Failed.' ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

  elsif (retcode = 2) then
    errbuf := 'Hard Edit Check Failed';
    v_log_text := 'Hard Edit Check Failed.' ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;

  else
    v_log_text := 'Edit Check Passed.' ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, v_log_text) ;
  end if;

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
        g_error_flag    :=      sqlcode ;
        fnd_file.put_line(FND_FILE.LOG, sqlerrm || ' [CREATE_STATUS_RECORD] ') ;
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
	 budget_function		)
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
	 v_dummy_var			) ;
EXCEPTION
    When Others Then
        g_error_flag    :=      sqlcode ;
        fnd_file.put_line(FND_FILE.LOG, sqlerrm || ' [CREATE_LOG_RECORD] ') ;
        return;

END CREATE_LOG_RECORD ;

end FVFCCHKB_PKG; -- Package body

/
