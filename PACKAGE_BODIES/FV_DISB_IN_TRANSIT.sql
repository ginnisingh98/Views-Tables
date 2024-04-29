--------------------------------------------------------
--  DDL for Package Body FV_DISB_IN_TRANSIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_DISB_IN_TRANSIT" AS
--$Header: FVAPDITB.pls 120.30.12000000.2 2007/10/03 10:37:01 nisgupta ship $
  g_module_name VARCHAR2(100);
  g_errmsg  VARCHAR2(200);

--  v_set_of_books_id           	gl_sets_of_books.set_of_books_id%TYPE;

  v_set_of_books_id		gl_ledgers_public_v.ledger_id%TYPE;
  v_org_id			fv_operating_units.org_id%TYPE;
  c_gl_appl_id                	gl_period_statuses.application_id%TYPE;
  g_treasury_confirmation_id  	NUMBER;
  v_treasury_doc_date		fv_treasury_confirmations.treasury_doc_date%TYPE;
  c_application_short_name    	VARCHAR2(10);
  c_key_flex_code	      	VARCHAR2(4);
--  v_flex_num			gl_sets_of_books.chart_of_accounts_id%TYPE;
  v_flux_num			gl_ledgers_public_v.chart_of_accounts_id%TYPE;
  v_segment_value   		VARCHAR2(25);
  a_segments             	fnd_flex_ext.SegmentArray;
  gl_seg_name			VARCHAR2(30);

-- AKA, 8/10/99, moved declaration globally
  v_treasury_confirmation_id	NUMBER;
  v_rowid			VARCHAR2(25);

-- select all lines for the checks for the treasury confirmation that are not voided
-- AKA, 8/10/99, is cursor for backout, moved globally to be used for main and backout,
-- also more restrictive, also selecting rowid
  CURSOR	c_je_lines IS
  SELECT	ac.check_id,gjh.currency_code,gjh.currency_conversion_type,
		gjh.currency_conversion_rate,ac.exchange_date,
		gjl.accounted_dr,gjl.accounted_cr,
		gjl.entered_dr, gjl.entered_cr, gjl.code_combination_id,
  		gjl.ROWID,
                gjl.reference_4
  FROM 		ap_checks ac, gl_je_lines gjl, gl_je_headers gjh
  WHERE		ac.void_date IS NULL
  AND		gjl.reference_1 = TO_CHAR(v_treasury_confirmation_id)
  AND           ac.check_id     =  gjl.reference_3
  AND		gjh.je_header_id = gjl.je_header_id
  AND		gjh.je_category = 'Treasury Confirmation'
  AND		gjh.je_source = 'Payables';
----------------------------------------------------------------------------------------------------------------------------

PROCEDURE process_clean_up IS

BEGIN

   ROLLBACK;

   UPDATE fv_treasury_confirmations
   SET confirmation_status_flag = 'N'
   WHERE treasury_confirmation_id =  g_treasury_confirmation_id;

   COMMIT;

   RETURN;


EXCEPTION
    WHEN OTHERS THEN
     NULL;

END Process_clean_up;

----------------------------------------------------------------------------------------------------------------------------

PROCEDURE confirm_treas_payment(
	X_treasury_confirmation_id 	IN 		NUMBER,
	X_err_code 			IN OUT NOCOPY 		NUMBER,
	X_err_stage 			IN OUT NOCOPY 		VARCHAR2,
	v_period		 OUT NOCOPY 	VARCHAR2)
	IS
        l_module_name   VARCHAR2(200);
	v_doc_ctr		NUMBER(15);
	v_chk_ctr		NUMBER(15);
	v_begin_doc		fv_treasury_confirmations.begin_doc_num%TYPE;
	v_end_doc		fv_treasury_confirmations.end_doc_num%TYPE;
	v_payment_instruction_id iby_pay_instructions_all.payment_instruction_id%TYPE;
	v_confirm_date	fv_treasury_confirmations.treasury_doc_date%TYPE;
        v_diff                  NUMBER;
        v_check_num             NUMBER;
	v_delta	 		NUMBER(15);
	v_treasury_pay_number	ap_checks.treasury_pay_number%TYPE;

	-- AKA declare variables for offsets
	v_corr_treas_pay_num fv_tc_offsets.corrected_treasury_pay_number%TYPE;
	v_offset_check_id	fv_tc_offsets.check_id%TYPE;
        v_pay_fmt_program_name  ap_payment_programs.program_name%TYPE;

        -- declare array to store check_ids
        TYPE l_check_row IS RECORD ( CHECK_ID NUMBER(15)) ;
        TYPE l_check_tbl_type IS TABLE OF l_check_row INDEX BY BINARY_INTEGER;
        l_check_tbl  l_check_tbl_type ;
        TYPE t_refcur IS REF CURSOR;
        vl_check_id_cur  t_refcur;
        l_row_num NUMBER := 1;
        L_SELECT_STR VARCHAR2(1000) ;

	-- AKA, declare cursor to select
	-- corrected treasury pay number and check id from offsets table
	-- need to join to ap_checks on check id to get the correct batch name

	CURSOR	cur_corr_treas_pay_num IS
	SELECT	fto.corrected_treasury_pay_number, fto.check_id
	FROM	fv_tc_offsets	fto,
		ap_checks	ac,
                iby_payments_all ipa
	WHERE 	ac.check_id = fto.check_id
	AND	ac.payment_id = ipa.payment_id
        AND     ipa.payment_instruction_id = v_payment_instruction_id
	AND	ipa.org_id = v_org_id;

        CURSOR c_check_ranges IS
          SELECT ftcr.range_from, ftcr.range_to, ftc.payment_instruction_id,ftc.treasury_doc_date
          FROM   fv_treasury_confirmations ftc,
                 fv_treasury_check_ranges ftcr
          WHERE  ftc.treasury_confirmation_id = g_treasury_confirmation_id
            AND  ftc.treasury_confirmation_id = ftcr.treasury_confirmation_id;

BEGIN
    l_module_name  :=  g_module_name || 'confirm_treas_payment ';

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'x_treasury_confirmation_id is ' ||
                                   x_treasury_confirmation_id);
     	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'starting confirm_treas_payment');
      END IF;
        g_treasury_confirmation_id := x_treasury_confirmation_id;
        x_err_code := 0;

        -- Getting the name of the Payment Instruction
        SELECT   ftc.payment_instruction_id
        INTO     v_payment_instruction_id
        FROM     fv_treasury_confirmations ftc
        WHERE    ftc.treasury_confirmation_id = g_treasury_confirmation_id;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'v_payment_instruction_id is ' || v_payment_instruction_id);
      END IF;

-- initializing table with check_ids

OPEN vl_check_id_cur FOR l_select_str USING  v_payment_instruction_id;
LOOP
FETCH vl_check_id_cur INTO l_check_tbl(l_row_num).check_id;

      l_row_num := l_row_num + 1;

      EXIT WHEN vl_check_id_cur %NOTFOUND;
END LOOP;

l_row_num := 1;

-- Assigning the treasury Pay number to the respective checks
FOR c_check_range_rec IN c_check_ranges LOOP
  v_begin_doc := c_check_range_rec.range_from;
  v_end_doc   := c_check_range_rec.range_to;
  v_confirm_date := c_check_range_rec.treasury_doc_date;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'v_payment_instruction_id is ' || v_payment_instruction_id);
  END IF;

  IF (v_begin_doc IS NULL) OR (v_end_doc IS NULL) OR (v_payment_instruction_id IS NULL)  OR ( v_confirm_date IS NULL) THEN
               x_err_code := 20;
               x_err_stage :=  'Data in treasury confirmation table is missing';
      RETURN;
  END IF;

  v_diff  := v_end_doc - v_begin_doc + 1;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'v_diff is ' || v_diff);
 END IF;

 FOR i IN 1.. v_diff
 LOOP

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_row_num:'||l_row_num);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_check_tbl(l_row_num).check_id:'||
                           l_check_tbl(l_row_num).check_id);
 END IF;

        UPDATE ap_checks c
                SET treasury_pay_number = v_begin_doc,
                treasury_pay_date = v_confirm_date,
                last_update_date = SYSDATE,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
                WHERE c.check_id = l_check_tbl(l_row_num).check_id;
      l_row_num := l_row_num+1;
      v_begin_doc :=  v_begin_doc +1;
 END LOOP;

END LOOP;

	-- AKA, need to update ap_checks if a corrected treasury pay number
	-- for a payment within the batch being processed has been entered
	OPEN	cur_corr_treas_pay_num;

	LOOP
	FETCH	cur_corr_treas_pay_num INTO v_corr_treas_pay_num, v_offset_check_id;
		EXIT WHEN cur_corr_treas_pay_num%NOTFOUND;

                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'in corrected treasury pay number loop');
                END IF;

		IF v_corr_treas_pay_num IS NOT NULL THEN
			UPDATE	ap_checks
			SET	treasury_pay_number = v_corr_treas_pay_num
			WHERE	check_id = v_offset_check_id;
		END IF;
	END LOOP;
	CLOSE cur_corr_treas_pay_num;


        -- get name of open period that treasury doc date is in
        BEGIN
	   SELECT period_name
	   INTO   v_period
	   FROM   gl_period_statuses g
	   WHERE  g.application_id = c_gl_appl_id
	   AND    g.set_of_books_id = v_set_of_books_id
	   AND    g.closing_status IN ('O', 'F')
	   AND    v_confirm_date BETWEEN
		    g.start_date AND g.end_date
	   AND    g.adjustment_period_flag = 'N';
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
           -- if treasury doc date was not in an open period, then
           -- get name of next open period
	   BEGIN
	      SELECT period_name
	      INTO   v_period
	      FROM   gl_period_statuses g
              WHERE  g.application_id = c_gl_appl_id
	      AND    g.set_of_books_id = v_set_of_books_id
	      AND    g.adjustment_period_flag = 'N'
	      AND    g.start_date = (SELECT MIN(start_date)
	   		          FROM   gl_period_statuses g2
			          WHERE  g2.application_id = c_gl_appl_id
			          AND    g2.set_of_books_id = v_set_of_books_id
			          AND    g2.end_date > v_confirm_date
				  AND    g2.closing_status IN ('O', 'F')
				  AND    g2.adjustment_period_flag = 'N');
           EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		  x_err_code := 30;
		  x_err_stage :=
		   'No open or future period after treasury documentation date';
		  RETURN;
	   END;
        END;


EXCEPTION
	WHEN OTHERS THEN
	x_err_code := SQLCODE;
	x_err_stage := SQLERRM;
       g_errmsg := SQLERRM;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,G_errmsg);
            RAISE;



END confirm_treas_payment;

----------------------------------------------------------------------------------------


PROCEDURE get_interface_data
          (v_chart_of_accounts_id 	 OUT NOCOPY 		gl_ledgers_public_v.chart_of_accounts_id%TYPE,
	     v_currency_code        	 OUT NOCOPY 		gl_ledgers_public_v.currency_code%TYPE,
	     x_err_code             		IN OUT NOCOPY 	NUMBER,
	     x_err_stage            		IN OUT NOCOPY 	VARCHAR2)
IS
   l_module_name         VARCHAR2(200);
BEGIN
   l_module_name         :=  g_module_name || 'get_interface_data ';
	-- Get chart of accounts id, and currency code
  	SELECT chart_of_accounts_id, currency_code
    	INTO v_chart_of_accounts_id, v_currency_code
    	FROM gl_ledgers_public_v
   	WHERE ledger_id = v_set_of_books_id;

EXCEPTION
	WHEN OTHERS THEN
		x_err_code := SQLCODE;
		x_err_stage := SQLERRM;

            g_errmsg := SQLERRM;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_errmsg);
            RAISE;
END get_interface_data;

----------------------------------------------------------------------------------------------------------------------------

PROCEDURE populate_gl_interface(	x_treasury_confirmation_id 	IN     	NUMBER,
					x_group_id                 	IN   	NUMBER,
					v_period			IN	VARCHAR2,
                			x_err_code 		   	IN OUT NOCOPY 	NUMBER,
					x_err_stage 		   	IN OUT NOCOPY 	VARCHAR2)
IS
l_module_name         VARCHAR2(200);
v_structure_number		NUMBER;
v_segment_number		NUMBER;
v_segment_name          VARCHAR2(30);
v_chart_of_accounts_id		gl_ledgers_public_v.chart_of_accounts_id%TYPE;
c_flex_qual_name		VARCHAR2(10);
v_n_segments			NUMBER;
--a_segments			fnd_flex_ext.SegmentArray;
--LGOEL: Change the declaration for these two variables
/*
v_amount			ap_payment_distributions.amount%TYPE;
v_combination_id		ap_payment_distributions.dist_code_combination_id%TYPE;
*/
v_amount_acct                   ap_ae_lines_all.accounted_dr%TYPE;
v_amount			ap_ae_lines_all.entered_dr%TYPE;
v_combination_id		ap_ae_lines_all.code_combination_id%TYPE;
--LGOEL: Define the following new variables
v_cr_amount			ap_ae_lines_all.entered_cr%TYPE;
v_dr_amount			ap_ae_lines_all.entered_dr%TYPE;
v_line_type_code		ap_ae_lines_all.ae_line_type_code%TYPE;
v_functional_curr_code          gl_ledgers_public_v.currency_code%TYPE;

v_accounting_date		gl_interface.accounting_date%TYPE;
v_boolean			BOOLEAN;
c_reference1			gl_interface.reference1%TYPE;
v_reference21			gl_interface.reference21%TYPE;
v_reference3			gl_interface.reference3%TYPE;
v_currency_code			gl_ledgers_public_v.currency_code%TYPE;
v_dr_account_segment_value	gl_ussgl_account_pairs.dr_account_segment_value%TYPE;
v_cr_account_segment_value	gl_ussgl_account_pairs.cr_account_segment_value%TYPE;
v_checkrun_name			fv_treasury_confirmations.checkrun_name%TYPE ;
v_check_id			ap_checks.check_id%TYPE;
v_vendor_id			po_vendors.vendor_id%TYPE;
v_period_start_date		gl_period_statuses.start_date%TYPE;
v_period_end_date		gl_period_statuses.end_date%TYPE;
v_invoice_id			ap_invoice_payments.invoice_id%TYPE;
v_cr_acct_amt                   ap_ae_lines.accounted_cr%TYPE;
v_dr_acct_amt                   ap_ae_lines.accounted_dr%TYPE;
v_curr_conv_type                ap_ae_lines.currency_conversion_type%TYPE;
v_curr_conv_date                ap_ae_lines.currency_conversion_date%TYPE;
v_curr_conv_rate                 ap_ae_lines.currency_conversion_rate%TYPE;

  	seg_app_name         VARCHAR2(40);
  	seg_prompt           VARCHAR2(25);
  	seg_value_set_name   VARCHAR2(40);

-- cursor to select all payment distributions that belong to this payment batch that are not voided

CURSOR payment_dists_cur IS
	SELECT 	apd.code_combination_id,
		apd.entered_cr,  -- transaction currency amt
                apd.entered_dr,
                apd.accounted_cr,  -- functional currency amt
                apd.accounted_dr,
                apd.currency_code,   -- transction currency
                apd.currency_conversion_type,
		apd.currency_conversion_date,
		apd.currency_conversion_rate,
	        apd.ae_line_type_code,
		aip.invoice_id,
       		ac.check_id
     	FROM 	fv_treasury_confirmations ftc,
	 	ap_checks ac,
	 	ap_invoice_payments aip,
       		ap_ae_lines apd,
                iby_payments_all ipa
   	WHERE	ftc.treasury_confirmation_id = x_treasury_confirmation_id
   	AND 	ftc.payment_instruction_id = ipa.payment_instruction_id
        AND     ipa.payment_id = ac.payment_id
	AND 	ac.check_id = aip.check_id
        AND    (( aip.invoice_payment_id = apd.source_id
            AND     apd.source_table ='AP_INVOICE_PAYMENTS')
        OR
          (     aip.check_id = apd.source_id
             AND apd.source_table = 'AP_CHECKS'))
	AND 	apd.ae_line_type_code IN ('CASH','CASH CLEARING','FUTURE PAYMENT')
	AND 	ac.void_date IS NULL;

BEGIN

  l_module_name         :=  g_module_name || 'populate_gl_interface ';
  c_flex_qual_name      := 'GL_ACCOUNT';
  c_reference1          := 'Treasury';

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'starting populate_gl_interface');
  END IF;
  x_err_code := 0;

  -- get the data needed to populate the gl_interface table
  get_interface_data(v_chart_of_accounts_id,
                     v_functional_curr_code,  -- base currency
                     x_err_code,
                     x_err_stage);
	IF x_err_code <> 0 THEN
		RETURN;
	END IF;

  -- Set structure number variable
  v_structure_number := v_chart_of_accounts_id;


v_boolean:=FND_FLEX_APIS.GET_segment_column(c_gl_appl_id,
                                             c_key_flex_code,
                                             v_structure_number ,
                                             'GL_ACCOUNT',
                                             v_segment_name);

  v_segment_number := SUBSTR(RTRIM(v_segment_name),8);

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'v_segment_number = '||v_segment_number);
  END IF;

  IF v_boolean = FALSE THEN
    x_err_code := 20;
    x_err_stage := 'Get qualifier segment number failed';
    RETURN;
  END IF;


  -- Obtain DR/CR account segment values pertaining to transaction code
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'v_period is = ' || v_period);
  END IF;

  SELECT t.treasury_doc_date
  INTO   v_treasury_doc_date
  FROM   fv_treasury_confirmations t
  WHERE  treasury_confirmation_id = x_treasury_confirmation_id;

  SELECT p.start_date, p.end_date
  INTO   v_period_start_date, v_period_end_date
  FROM   gl_period_statuses p
  WHERE  p.period_name = v_period
  AND    p.application_id = c_gl_appl_id
  AND    p.set_of_books_id = v_set_of_books_id
  AND    p.adjustment_period_flag = 'N';

  -- if treasury doc date is in an open period then use that date,
  -- otherwise, use the end date of the next open period
  IF (v_treasury_doc_date
		BETWEEN v_period_start_date AND v_period_end_date) THEN
      v_accounting_date := v_treasury_doc_date;
  ELSE
      v_accounting_date := v_period_end_date;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTilitY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'v_chart_of_accounts_id = '||v_chart_of_accounts_id);
  END IF;

  OPEN payment_dists_cur;
  LOOP
    FETCH payment_dists_cur
     INTO v_combination_id, v_cr_amount,
	  v_dr_amount,
          v_cr_acct_amt,
          v_dr_acct_amt,
          v_currency_code,
          v_curr_conv_type,
          v_curr_conv_date,
          v_curr_conv_rate,
          v_line_type_code,
	  v_invoice_id, v_check_id;
    EXIT WHEN payment_dists_cur%NOTFOUND;

    IF (v_line_type_code = 'CASH CLEARING') THEN
        x_err_code := 1;
        x_err_stage := 'Perform Payment Reconciliation or Cash Management before running Treasury Confirmation';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,l_module_name||'.cash_clearing',x_err_stage);
	EXIT;
    ELSIF (v_line_type_code = 'FUTURE PAYMENT') THEN
        x_err_code := 1;
        x_err_stage := 'Create the accounting entries once the payment has matured';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,l_module_name||'.future_payment', 'The accounting entries have not been created for payment maturity');
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,l_module_name||'.future_payment', 'Create the accounting entries once the payment has matured');
	EXIT;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'in payment_dists_cur cursor loop');
    END IF;


    get_segment_values(v_combination_id);

    -- Set reference21 to be the treasury confirmation id to be stored in
    -- gl_interface table
    v_reference21 := x_treasury_confirmation_id;

   -- set reference3 to be the check id to be stored in the gl_interface table
    v_reference3 := v_check_id;

    -- Overlay natural account segment of the array with the DR account
    -- segment value and insert into gl_interface
    IF (v_cr_amount <> 0) THEN
        a_segments(v_segment_number) := v_dr_account_segment_value;
	v_amount := v_cr_amount;
        v_amount_acct := v_cr_acct_amt;  -- capture functional amount
    ELSE
        a_segments(v_segment_number) := v_cr_account_segment_value;
	v_amount := v_dr_amount;
        v_amount_acct := v_dr_acct_amt; -- capture functional amount
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'inserting into gl_interface');
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Amount is '||TO_CHAR(v_amount));
    END IF;

    INSERT INTO gl_interface(status, set_of_books_id,
				accounting_date, currency_code,
                                functional_currency_code,
				user_currency_conversion_type,
				currency_conversion_date,
                                currency_conversion_rate,
				date_created, created_by,
				actual_flag, user_je_category_name,
				user_je_source_name, segment1,
				segment2, segment3,
				segment4, segment5,
				segment6, segment7,
				segment8, segment9,
				segment10, segment11,
				segment12, segment13,
				segment14, segment15,
				segment16, segment17,
				segment18, segment19,
				segment20, segment21,
				segment22, segment23,
				segment24, segment25,
				segment26, segment27,
				segment28, segment29,
				segment30, entered_dr,
				accounted_dr,
				reference1, reference21,
				reference23, reference24,
				reference25, reference26,
				group_id)
			VALUES('NEW', v_set_of_books_id,
				v_accounting_date, v_currency_code,
				v_functional_curr_code,
				v_curr_conv_type,
				v_curr_conv_date,
				v_curr_conv_rate,
				SYSDATE, fnd_global.user_id,
				'A', 'Treasury Confirmation',
				'Payables', a_segments(1),
				a_segments(2), a_segments(3),
				a_segments(4), a_segments(5),
				a_segments(6), a_segments(7),
				a_segments(8), a_segments(9),
				a_segments(10), a_segments(11),
				a_segments(12), a_segments(13),
				a_segments(14), a_segments(15),
				a_segments(16), a_segments(17),
				a_segments(18), a_segments(19),
				a_segments(20), a_segments(21),
				a_segments(22), a_segments(23),
				a_segments(24), a_segments(25),
				a_segments(26), a_segments(27),
				a_segments(28), a_segments(29),
				a_segments(30), v_amount, -- transaction amt
				v_amount_acct, -- functional amt
				c_reference1, v_reference21,
				v_reference3, v_invoice_id,
				v_org_id, v_treasury_doc_date,
				x_group_id);

    -- Overlay natural account segment of the array with the CR account
    -- segment value and insert into gl_interface
    --a_segments(v_segment_number) := v_cr_account_segment_value;
    IF (v_cr_amount <> 0) THEN
        a_segments(v_segment_number) := v_cr_account_segment_value;
    ELSE
        a_segments(v_segment_number) := v_dr_account_segment_value;
    END IF;
    INSERT INTO gl_interface(status, set_of_books_id,
				accounting_date, currency_code,
				functional_currency_code,
				user_currency_conversion_type,
				currency_conversion_date,
				currency_conversion_rate,
				date_created, created_by,
				actual_flag, user_je_category_name,
				user_je_source_name, segment1,
				segment2, segment3,
				segment4, segment5,
				segment6, segment7,
				segment8, segment9,
				segment10, segment11,
				segment12, segment13,
				segment14, segment15,
				segment16, segment17,
				segment18, segment19,
				segment20, segment21,
				segment22, segment23,
				segment24, segment25,
				segment26, segment27,
				segment28, segment29,
				segment30, entered_cr,  -- transaction amt
				accounted_cr, -- functional amt
				reference1, reference21,
				reference23, reference24,
				reference25, reference26,
				group_id)
			VALUES('NEW', v_set_of_books_id,
				v_accounting_date, v_currency_code,
				v_functional_curr_code,
				v_curr_conv_type,
				v_curr_conv_date,
				v_curr_conv_rate,
				SYSDATE, fnd_global.user_id,
				'A', 'Treasury Confirmation',
				'Payables', a_segments(1),
				a_segments(2), a_segments(3),
				a_segments(4), a_segments(5),
				a_segments(6), a_segments(7),
				a_segments(8), a_segments(9),
				a_segments(10), a_segments(11),
				a_segments(12), a_segments(13),
	 			a_segments(14), a_segments(15),
				a_segments(16), a_segments(17),
				a_segments(18), a_segments(19),
				a_segments(20), a_segments(21),
				a_segments(22), a_segments(23),
				a_segments(24), a_segments(25),
				a_segments(26), a_segments(27),
				a_segments(28), a_segments(29),
				a_segments(30), v_amount,-- transaction amt
				v_amount_acct,  -- functional amt
				c_reference1, v_reference21,
				v_reference3, v_invoice_id,
				v_org_id, v_treasury_doc_date,
				x_group_id);
  END LOOP;
  CLOSE payment_dists_cur;

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'insert into gl_interface');
END IF;
EXCEPTION
       WHEN OTHERS THEN
            g_errmsg := SQLERRM;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_errmsg);
            RAISE;
END populate_gl_interface;

----------------------------------------------------------------------------------------------------------------------------
PROCEDURE cleanup_gl_interface(	X_treasury_confirmation_id 	IN 		NUMBER,
						v_process_job			IN 		VARCHAR2,
						x_group_id				IN 		NUMBER,
						X_err_code 				IN OUT NOCOPY 	NUMBER,
						X_err_stage 			IN OUT NOCOPY 	VARCHAR2)
IS
l_module_name         VARCHAR2(200);
BEGIN
  l_module_name         :=  g_module_name || 'cleanup_gl_interface ';
        x_err_code := 0;

   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'An error has occurred during Journal Import.  Please review Journal Import Execution Report.');
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'The journal has been removed from the Interface table.');
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'After correcting error please reselect Confirm or Back OUT NOCOPY from Treasury Confirmation or resubmit Disbursements in Transit Voided Checks.');
-- Delete records from GL-INTERFACE for a particular group id
-- and update the  confirmation status flag to 'N'
	DELETE FROM GL_INTERFACE
		WHERE user_je_source_name = 'Payables'
		AND set_of_books_id = v_set_of_books_id
		AND group_id = x_group_id;

-- if the button that is called is either confirm or backout, not void
  IF v_process_job IN ('C', 'B') THEN
	UPDATE fv_treasury_confirmations
-- if the process is confirm, status is Not Confirmed,
-- if the process is backout, status is Confirmed
	SET    confirmation_status_flag = DECODE(v_process_job, 'C', 'N', 'B', 'Y'),
	       gl_period = NULL,
	       last_update_date = SYSDATE,
	       last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.login_id
	WHERE treasury_confirmation_id = x_treasury_confirmation_id;
  END IF;

   x_err_code := 2;
   X_err_stage := 'There was an error importing GL Interface records. Look at the GL Import Log File.';

EXCEPTION
    WHEN OTHERS THEN
	x_err_code := SQLCODE;
	x_err_stage := SQLERRM;
END cleanup_gl_interface;

----------------------------------------------------------------------------------------------------------------------------

PROCEDURE do_confirm_process(	v_treasury_confirmation_id 	IN     	NUMBER,
			     		x_group_id				IN OUT NOCOPY 	NUMBER,
                             	x_err_code                 	IN OUT NOCOPY 	NUMBER,
                             	x_err_stage  			IN OUT NOCOPY 	VARCHAR2,
					v_period				IN OUT NOCOPY VARCHAR2)
IS
        l_module_name         VARCHAR2(200);
        v_dit_flag  fv_operating_units.dit_flag%TYPE;
BEGIN
        l_module_name         :=  g_module_name || 'do_confirm_process ';
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'starting do_confirm_process');
        END IF;

	-- initialize variables
	x_err_code  	:= 0;
	x_group_id    	:= 0;


	-- Call first program to update treasury payments FV_DISB_IN_TRANSIT.
	fv_disb_in_transit.confirm_treas_payment (
		v_treasury_confirmation_id,
		x_err_code,
		x_err_stage,
		v_period);

	  	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   	  	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'x_err_code is ' || x_err_code);
	  	END IF;

	IF (x_err_code <> 0) THEN
	    RETURN;
	END IF;

	-- Assign the group id to be a sequence number from the gl_interface_control seq
	SELECT  gl_interface_control_s.NEXTVAL
	INTO    x_group_id
	FROM    dual;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'x_group_id = '||x_group_id);
        END IF;

	-- Assign the dit_flag from fv_operating_units_all table
	SELECT dit_flag
	INTO   v_dit_flag
	FROM   fv_operating_units;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'dit flag = '||v_dit_flag);
        END IF;
	IF v_dit_flag = 'Y' THEN
	    -- If dit_flag = 'Y' then populate the gl_interface table
            -- otherwise do not do anything.

	   fv_disb_in_transit.populate_gl_interface(
			v_treasury_confirmation_id,
			x_group_id, v_period, x_err_code,x_err_stage);

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'called populate gl_interface from do confirm process');
	END IF;

            IF x_err_code <> 0 THEN
	     	    RETURN;
		END IF;

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		x_err_code := SQLCODE;
 		x_err_stage := SQLERRM;
        g_errmsg := SQLERRM;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_errmsg);
            RAISE;
END do_confirm_process;

----------------------------------------------------------------------------------------------------------------------------

PROCEDURE do_back_out_process
-- AKA, 8/10/99, removed passing of v_treasury_confirmation_id
			(x_group_id		IN OUT NOCOPY 	NUMBER,
	     		x_err_code              IN OUT NOCOPY 	NUMBER,
             		x_err_stage	 	IN OUT NOCOPY 	VARCHAR2)
IS
    l_module_name     VARCHAR2(200);
	v_checkrun_name        	fv_treasury_confirmations.checkrun_name%TYPE;
	v_chart_of_accounts_id 	gl_ledgers_public_v.chart_of_accounts_id%TYPE;
	v_currency_code         	gl_ledgers_public_v.currency_code%TYPE;
	v_func_currency_code            gl_ledgers_public_v.currency_code%TYPE;
	v_credit_amount			gl_je_lines.entered_dr%TYPE;
	v_debit_amount			gl_je_lines.entered_cr%TYPE;
	v_cc_id				gl_je_lines.code_combination_id%TYPE;
	v_n_segments			NUMBER;
--	a_segments			fnd_flex_ext.SegmentArray;
	v_boolean			BOOLEAN;
	c_reference1		gl_interface.reference1%TYPE;
      	v_tc_id                		gl_interface.reference1%TYPE;
      	v_check_id			ap_checks.check_id%TYPE;
        v_invoice_id                    gl_je_lines.reference_4%TYPE;
        v_period                        gl_period_statuses.period_name%TYPE;
        v_period_start_date		gl_period_statuses.start_date%TYPE;
        v_period_end_date		gl_period_statuses.end_date%TYPE;
        v_accounting_date               gl_interface.accounting_date%TYPE;
        v_cr_acct_amt			gl_je_lines.accounted_cr%TYPE;
	v_dr_acct_amt                   gl_je_lines.accounted_dr%TYPE;
        v_curr_con_type         gl_je_headers.currency_conversion_type%TYPE;
        v_curr_con_rate		gl_je_headers.currency_conversion_rate%TYPE;
        v_curr_con_date         ap_checks.exchange_date%TYPE;

BEGIN
	-- Initialize variables
        l_module_name :=  g_module_name || 'do_back_out_process ';
	c_reference1  := 'Treasury';
	x_err_code    := 0;
	x_group_id    := NULL;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
			'starting do_back_out_process');
	END IF;

	SELECT treasury_doc_date
  	INTO   v_treasury_doc_date
  	FROM   fv_treasury_confirmations
  	WHERE  treasury_confirmation_id = v_treasury_confirmation_id;


    -- get name of open period that treasury doc date is in
        BEGIN
	   SELECT period_name,g.start_date,g.end_date
	   INTO   v_period,v_period_start_date,v_period_end_date
	   FROM   gl_period_statuses g
	   WHERE  g.application_id = c_gl_appl_id
	   AND    g.set_of_books_id = v_set_of_books_id
	   AND    g.closing_status IN ('O', 'F')
	   AND    v_treasury_doc_date BETWEEN
		    g.start_date AND g.end_date
	   AND    g.adjustment_period_flag = 'N';
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
           -- if treasury doc date was not in an open period, then
           -- get name of next open period
	   BEGIN
              SELECT period_name,g.end_date,g.start_date
              INTO   v_period,v_period_end_date,v_period_start_date
              FROM   gl_period_statuses g
              WHERE  g.application_id = c_gl_appl_id
	      AND    g.set_of_books_id = v_set_of_books_id
              AND    g.adjustment_period_flag = 'N'
              AND    g.start_date = (SELECT MIN(start_date)
				   FROM   gl_period_statuses g2
       			          WHERE  g2.application_id = c_gl_appl_id
       			          AND    g2.set_of_books_id = v_set_of_books_id
       			          AND    g2.end_date > v_treasury_doc_date
                                  AND    g2.closing_status IN ('O', 'F')
                                  AND    g2.adjustment_period_flag = 'N');
           EXCEPTION
	      WHEN NO_DATA_FOUND THEN
       		  x_err_code := 30;
       		  x_err_stage :=
       		   'No open or future period after treasury documentation date';       		  RETURN;
           END;
        END;

  -- if treasury doc date is in an open period then use that date,
  -- otherwise, use the end date of the next open period
  IF (v_treasury_doc_date
	  	BETWEEN v_period_start_date AND v_period_end_date) THEN
      v_accounting_date := v_treasury_doc_date;
  ELSE
      v_accounting_date := v_period_end_date;
  END IF;



      -- get data to populate the gl_interface table.
	get_interface_data(v_chart_of_accounts_id, v_func_currency_code,
	  x_err_code, x_err_stage);

	IF x_err_code <> 0 THEN
		RETURN;
	END IF;

	-- Assign the group id to be a sequence number
	--from the gl_interface_control seq

	SELECT	gl_interface_control_s.NEXTVAL
	INTO 	x_group_id
	FROM    dual;

	-- Find the gl_je_lines records that are associated with the
	-- treasury_confirmation_id that is being backed out.

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
			'starting je_lines loop for backout');
        END IF;

 	v_credit_amount := NULL;
	v_debit_amount  := NULL;
        v_cr_acct_amt   := NULL;
        v_dr_acct_amt   := NULL;
	FOR c_je_lines_rec IN c_je_lines LOOP
		-- Initialize variables

		-- back out what occurred by setting the debit amount =
                -- original credit
		-- amount and the credit amount = original debit amount.
		v_credit_amount 		:= c_je_lines_rec.entered_dr;
		v_debit_amount  		:= c_je_lines_rec.entered_cr;
		v_cc_id	        		:= c_je_lines_rec.code_combination_id;
		v_check_id			:= c_je_lines_rec.check_id;
                v_invoice_id                    := c_je_lines_rec.reference_4;
                v_currency_code			:= c_je_lines_rec.currency_code;
		v_cr_acct_amt 			:= c_je_lines_rec.accounted_dr;
		v_dr_acct_amt			:= c_je_lines_rec.accounted_cr;
                v_curr_con_type      := c_je_lines_rec.currency_conversion_type;
		v_curr_con_rate      := c_je_lines_rec.currency_conversion_rate;
                v_curr_con_date      :=  c_je_lines_rec.exchange_date;
		get_segment_values(v_cc_id);

                v_tc_id := TO_CHAR(v_treasury_confirmation_id);

                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'starting insert');
                END IF;



		INSERT INTO gl_interface(status, set_of_books_id,
				accounting_date, currency_code,
				user_currency_conversion_type,
				currency_conversion_rate,
				currency_conversion_date,
  				functional_currency_code,
				date_created, created_by,
				actual_flag, user_je_category_name,
				user_je_source_name, segment1,
				segment2, segment3,
				segment4, segment5,
				segment6, segment7,
				segment8, segment9,
				segment10, segment11,
				segment12, segment13,
				segment14, segment15,
				segment16, segment17,
				segment18, segment19,
				segment20, segment21,
				segment22, segment23,
				segment24, segment25,
				segment26, segment27,
				segment28, segment29,
				segment30,
				entered_dr, entered_cr,
				accounted_dr,accounted_cr,
				reference1,
  				reference21,
  				reference23,
                                reference24,
				reference25,
				reference26,
				group_id)
			VALUES('NEW', v_set_of_books_id,
				v_accounting_date, v_currency_code,
				v_curr_con_type,v_curr_con_rate,
				v_curr_con_date,
				v_func_currency_code,
				SYSDATE, fnd_global.user_id,
				'A', 'Treasury Confirmation',
				'Payables', a_segments(1),
				a_segments(2), a_segments(3),
				a_segments(4), a_segments(5),
				a_segments(6), a_segments(7),
				a_segments(8), a_segments(9),
				a_segments(10), a_segments(11),
				a_segments(12), a_segments(13),
				a_segments(14), a_segments(15),
				a_segments(16), a_segments(17),
				a_segments(18), a_segments(19),
				a_segments(20), a_segments(21),
				a_segments(22), a_segments(23),
				a_segments(24), a_segments(25),
				a_segments(26), a_segments(27),
				a_segments(28), a_segments(29),
				a_segments(30),
				v_debit_amount, v_credit_amount,
				v_dr_acct_amt,v_cr_acct_amt,
				c_reference1,
  				v_tc_id,
  				v_check_id,
                                v_invoice_id,
				v_org_id,
				v_treasury_doc_date,
				x_group_id);

        		v_credit_amount := NULL;
			v_debit_amount  := NULL;
			v_cr_acct_amt   := NULL;
			v_dr_acct_amt   := NULL;
	END LOOP;

EXCEPTION
       WHEN OTHERS THEN
            g_errmsg := SQLERRM;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_errmsg);
            RAISE;
END do_back_out_process;
----------------------------------------------------------------------------------------------------------------------------
PROCEDURE void
(
  errbuf  OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2
)
IS
  l_module_name          VARCHAR2(200);
  l_group_id             NUMBER;
  l_err_code             NUMBER;
  l_err_stage            VARCHAR2(2000);
  l_chart_of_accounts_id gl_ledgers_public_v.chart_of_accounts_id%TYPE;
  l_org_id               NUMBER;
  l_func_currency_code   gl_ledgers_public_v.currency_code%TYPE;
  l_reference1           gl_interface.reference1%TYPE;
  l_insert_required      BOOLEAN := FALSE;
  l_count_void           NUMBER := 0;
  l_interface_run_id     NUMBER;
  l_req_id               NUMBER;
  l_call_status          BOOLEAN;
  l_rphase               VARCHAR2(30);
  l_rstatus              VARCHAR2(30);
  l_dphase               VARCHAR2(30);
  l_dstatus              VARCHAR2(30);
  l_message              VARCHAR2(240);
  l_dummy                NUMBER;
--  l_je_exists_for_check  BOOLEAN := FALSE;
  l_processed_flag       fv_voided_checks.processed_flag%TYPE;
  l_treasury_conf_id1    NUMBER;
  l_insert_je_line       BOOLEAN := FALSE;
  l_treasury_conf_id     NUMBER;
  v_accounting_date      gl_period_statuses.end_date%TYPE;
  l_set_of_books_name    VARCHAR2(200);

  CURSOR  voided_checks_list_cursor
  (
    p_set_of_books_id NUMBER,
    p_org_id          NUMBER
  ) IS
  SELECT /*+ ordered */ DISTINCT
         fvt.check_id,
         fvt.rowid,
         ftc.treasury_confirmation_id,
         fvt.processed_flag,
         ac.exchange_date,
         ac.void_date
    FROM fv_treasury_confirmations_all ftc,
         fv_voided_checks fvt,
         ap_checks_all ac ,
         ap_invoice_payments_all apip,
         iby_payments_all ipa
   WHERE ac.check_id = fvt.check_id
     AND ac.payment_id = ipa.payment_id
     AND ipa.payment_instruction_id = ftc.payment_instruction_id
     AND ftc.checkrun_name IS NULL
     AND NVL(fvt.processed_flag,'U')  IN ('U', 'S')
     AND ftc.set_of_books_id = p_set_of_books_id
     AND ftc.org_id = p_org_id
     AND ac.org_id = p_org_id
     AND fvt.org_id = p_org_id
     AND apip.check_id = ac.check_id
     AND apip.reversal_flag = 'Y'
     AND apip.reversal_inv_pmt_id is not null
     AND ac.last_update_date < fvt.creation_date
     AND  ac.status_lookup_code = 'VOIDED'
      AND (
                 (ftc.confirmation_status_flag = 'Y'
                 AND apip.creation_date > ftc.creation_date)
                OR
                 (ftc.confirmation_status_flag in ('B','N')
                 AND apip.creation_date BETWEEN ftc.creation_date and ftc.last_update_date)
            )
     AND EXISTS	(SELECT	null
                   FROM	gl_ledgers_public_v glpv,
                        gl_je_headers gjh,
                        gl_je_lines gjl
                  WHERE glpv.ledger_id = p_set_of_books_id
                    --AND gjh.set_of_books_id = gsob.set_of_books_id
                    AND gjh.ledger_id = glpv.ledger_id
                    AND gjh.je_category = 'Treasury Confirmation'
                    AND gjh.je_source = 'Payables'
                    AND gjh.je_header_id = gjl.je_header_id
                    --AND gjl.set_of_books_id = gsob.set_of_books_id
                    AND gjl.ledger_id = glpv.ledger_id
                    AND gjl.reference_3 = to_char(ac.check_id)
                    AND	gjl.reference_1 = to_char(ftc.treasury_confirmation_id)
                    AND gjl.reference_4 = to_char(apip.invoice_id)
                );


  CURSOR cur_process_void_check
  (
    p_set_of_books_id    NUMBER,
    p_check_id           NUMBER,
    p_treas_conf_id      NUMBER
  ) IS
  SELECT /*+ choose*/
         gjl.entered_dr,
         gjl.entered_cr,
         gjh.currency_conversion_type,
         gjh.currency_conversion_rate,
         gjl.code_combination_id,
         gjl.accounted_cr,
         gjl.accounted_dr,
         gjh.currency_code,
         gjl.reference_4 invoice_id,
         gjl.rowid gl_rowid
    FROM gl_ledgers_public_v glpv,
         gl_je_lines      gjl,
         gl_je_headers    gjh
   WHERE glpv.ledger_id            = p_set_of_books_id
     AND gjh.ledger_id             = glpv.ledger_id
     AND gjl.ledger_id             = glpv.ledger_id
     AND gjh.je_category           = 'Treasury Confirmation'
     AND gjh.je_source             = 'Payables'
     AND gjl.reference_3           = p_check_id
     AND gjl.reference_1           = p_treas_conf_id
     AND gjh.je_header_id          = gjl.je_header_id;


BEGIN
  l_module_name := g_module_name || 'void';
  l_reference1  := 'Void';
  errbuf := NULL;
  retcode := '0';

  l_org_id :=  mo_global.get_current_org_id;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fv_utility.debug_mesg(fnd_log.level_statement,l_module_name,'org id = '|| l_org_id);
  END IF;

  mo_utils.get_ledger_info(l_org_id,v_set_of_books_id,l_set_of_books_name);
  -- v_set_of_books_id := TO_NUMBER(fnd_profile.value('GL_SET_OF_BKS_ID')); --;>--

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fv_utility.debug_mesg(fnd_log.level_statement,l_module_name,'set of books id = '||v_set_of_books_id);
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fv_utility.debug_mesg(fnd_log.level_statement,l_module_name,'INSERT INTO fv_voided_checks');
  END IF;

  BEGIN
    INSERT INTO fv_voided_checks
    (
      void_id,
      checkrun_name,
      check_id,
      processed_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id
    )
    SELECT fv_voided_checks_s.nextval,
           checkrun_name,
           check_id,
           'U',
           SYSDATE,
           fnd_global.user_id,
           SYSDATE,
           fnd_global.user_id,
           fnd_global.login_id,
           org_id
      FROM ap_checks_all ac
     WHERE org_id = l_org_id
       AND void_date IS NOT NULL
       AND (ac.checkrun_name IS NOT NULL OR ac.payment_id IS NOT NULL)
       AND NOT EXISTS (SELECT 1
                        FROM fv_voided_checks fvc
                       WHERE fvc.check_id = ac.check_id
                         AND fvc.org_id = ac.org_id);

  EXCEPTION
    WHEN OTHERS THEN
      l_err_code := SQLCODE;
      l_err_stage := SQLERRM;
      retcode := '2';
      fv_utility.log_mesg(fnd_log.level_exception,l_module_name||'insert fv_voided_checks1',l_err_stage);
  END;


  IF (retcode = '0') THEN
    get_interface_data
    (
      v_chart_of_accounts_id => l_chart_of_accounts_id,
      v_currency_code        => l_func_currency_code,
      x_err_code             => l_err_code,
      x_err_stage            => l_err_stage
    );

    IF l_err_code <> 0 THEN
      fv_utility.debug_mesg(fnd_log.level_error,l_module_name,'Error '||l_err_code||' at '||l_err_stage);
      retcode := '2';
      errbuf := 'Error in get_interface_data';
    END IF;
  END IF;

  IF (retcode = '0') THEN
    SELECT gl_interface_control_s.NEXTVAL
      INTO l_group_id
      FROM dual;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement,l_module_name,'l_group_id is ' || l_group_id);
    END IF;
  END IF;

  -- Find the gl_je_lines records that are associated with the
  -- check_id that is being backed out.

  IF (retcode = '0') THEN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement,l_module_name,'starting je_lines loop for voided checks');
    END IF;

    FOR voided_checks_list_rec IN voided_checks_list_cursor (v_set_of_books_id, l_org_id) LOOP
      FOR cur_process_void_check_rec IN cur_process_void_check (v_set_of_books_id,
                                                                voided_checks_list_rec.check_id,
                                                                voided_checks_list_rec.treasury_confirmation_id) LOOP

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement,l_module_name, 'Fetched check id is = '||voided_checks_list_rec.check_id);
        END IF;

           	select accounting_date  into v_accounting_date
		from ap_invoice_payments_all
		where check_id =voided_checks_list_rec.check_id
		and   REVERSAL_INV_PMT_ID is not null
		and  REVERSAL_FLAG = 'Y'
		and rownum =1;

                -- get name of open period that void gl date of check  is in
           BEGIN
	   SELECT end_date
	   INTO   v_accounting_date
	   FROM   gl_period_statuses g
	   WHERE  g.application_id = c_gl_appl_id
	   AND    g.set_of_books_id = v_set_of_books_id
	   AND    g.closing_status IN ('O', 'F')
	   AND    v_accounting_date BETWEEN
		    g.start_date AND g.end_date
	   AND    g.adjustment_period_flag = 'N';
	   EXCEPTION
	 	 WHEN NO_DATA_FOUND THEN

         	     -- if void gl date was not in an open period, then
                     -- get name of next open period
	   		BEGIN
	      			SELECT end_date
	      			INTO   v_accounting_date
	      			FROM   gl_period_statuses g
             			WHERE  g.application_id = c_gl_appl_id
	      			AND    g.set_of_books_id = v_set_of_books_id
	      			AND    g.adjustment_period_flag = 'N'
	      			AND    g.start_date = (SELECT MIN(start_date)
	   		          FROM   gl_period_statuses g2
			          WHERE  g2.application_id = c_gl_appl_id
			          AND    g2.set_of_books_id = v_set_of_books_id
			          AND    g2.end_date > v_accounting_date
				  AND    g2.closing_status IN ('O', 'F')
				  AND    g2.adjustment_period_flag = 'N');


          		 EXCEPTION
	      				WHEN NO_DATA_FOUND THEN

					 l_err_code := SQLCODE;
         		   		 l_err_stage := SQLERRM;
          				 retcode := '2';
          			     errbuf := l_err_stage;
 	                    fv_utility.log_mesg(fnd_log.level_exception,l_module_name||'No open or future period after voiding check  date',l_err_stage);

 	          			--fnd_file.put_line (fnd_file.log ,'No open or future period after voiding check  date');

	 	  			EXIT;
		    END;

        	END;



        BEGIN
          INSERT INTO gl_interface
          (
            status,
            set_of_books_id,
            accounting_date,
            currency_code,
            user_currency_conversion_type,
            currency_conversion_date,
            currency_conversion_rate,
            functional_currency_code,
            date_created,
            created_by,
            actual_flag,
            user_je_category_name,
            user_je_source_name,
            entered_dr,
            entered_cr,
            accounted_dr,
            accounted_cr,
            reference1,
            reference24,
            reference21,
            reference23,
            reference25,
            reference26,
            group_id,
            code_combination_id
          )
          VALUES
          (
            'NEW',
            v_set_of_books_id,
            v_accounting_date,
            cur_process_void_check_rec.currency_code,
            cur_process_void_check_rec.currency_conversion_type,
            voided_checks_list_rec.exchange_date,
            cur_process_void_check_rec.currency_conversion_rate,
            l_func_currency_code,
            SYSDATE,
            fnd_global.user_id,
            'A',
            'Treasury Confirmation',
            'Payables',
            cur_process_void_check_rec.entered_cr,
            cur_process_void_check_rec.entered_dr,
            cur_process_void_check_rec.accounted_cr,
            cur_process_void_check_rec.accounted_dr,
            l_reference1,
            cur_process_void_check_rec.invoice_id,
            voided_checks_list_rec.treasury_confirmation_id,
            voided_checks_list_rec.check_id,
            l_org_id,
            voided_checks_list_rec.void_date,
            l_group_id,
            cur_process_void_check_rec.code_combination_id
          );

          l_count_void := l_count_void + 1;
        EXCEPTION
          WHEN OTHERS THEN
            l_err_code := SQLCODE;
            l_err_stage := SQLERRM;
            retcode := '2';
            fv_utility.log_mesg(fnd_log.level_exception,l_module_name||'insert gl_interface',l_err_stage);
            EXIT;
        END;

        IF (retcode = '0') THEN
          BEGIN

            UPDATE fv_voided_checks
               SET processed_flag = 'S'
             WHERE check_id = voided_checks_list_rec.check_id
               AND org_id = l_org_id;

          EXCEPTION
            WHEN OTHERS THEN
              l_err_code := SQLCODE;
              l_err_stage := SQLERRM;
              retcode := '2';
              fv_utility.log_mesg(fnd_log.level_exception,l_module_name||'update fv_voided_checks1',l_err_stage);
              EXIT;
          END;
        END IF;
        IF (retcode <> '0') THEN
          EXIT;
        END IF;
      END LOOP;
    END LOOP;
  END IF;


  IF ((retcode = '0') AND (l_count_void > 0)) THEN
    -- Obtain the interface run id
    l_interface_run_id := gl_interface_control_pkg.get_unique_run_id;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement,l_module_name,'interface_run_id = '||l_interface_run_id);
    END IF;
  END IF;


  IF ((retcode = '0') AND (l_count_void > 0)) THEN
    -- Insert a control record in Gl_INTERFACE record for the Gl
    -- Import to work
    BEGIN
      INSERT INTO gl_interface_control
      (
        je_source_name,
        status,
        interface_run_id,
        group_id,
        set_of_books_id
      )
      VALUES
      (
        'Payables',
        'S',
        l_interface_run_id,
        l_group_id,
        v_set_of_books_id
      );
    EXCEPTION
      WHEN OTHERS THEN
        l_err_code := SQLCODE;
        l_err_stage := SQLERRM;
        retcode := '2';
        fv_utility.log_mesg(fnd_log.level_exception,l_module_name||'insert gl_interface_control',l_err_stage);
    END;
  END IF;

  IF ((retcode = '0') AND (l_count_void > 0)) THEN

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement,l_module_name,'submitting a request');
    END IF;

    l_req_id := fnd_request.submit_request
                (
                  'SQLGL',
                  'GLLEZL',
                  '',
                  '',
                  FALSE,
                  TO_CHAR(l_interface_run_id),
                  TO_CHAR(v_set_of_books_id),
                  'N', '', '', 'N', 'N');

    -- if concurrent request submission failed then abort process
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement,l_module_name,'req_id = '||l_req_id);
    END IF;

    IF (l_req_id = 0) THEN
      errbuf := 'Can not submit journal import program';
      retcode := '2';
      fv_utility.log_mesg(fnd_log.level_statement,l_module_name,errbuf);
    END IF;
  END IF;

  IF (retcode = '0') THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;

  IF ((retcode = '0') AND (l_count_void > 0)) THEN
    -- Check status of completed concurrent program
    --  and if complete exit
    l_call_status := fnd_concurrent.wait_for_request
                     (
                        l_req_id,
                        20,
                        0,
                        l_rphase,
                        l_rstatus,
                        l_dphase,
                        l_dstatus,
                        l_message
                      );

    IF (l_call_status = FALSE) THEN
      errbuf := 'Can not wait for the status of journal import';
      retcode := '2';
      fv_utility.log_mesg(fnd_log.level_exception,l_module_name,errbuf);
    END IF;
  END IF;

  IF ((retcode = '0') AND (l_count_void > 0)) THEN
    -- Do rows exist in the GL_INTERFACE table ?

    SELECT COUNT(*)
      INTO l_dummy
      FROM gl_interface
     WHERE group_id = l_group_id
       AND set_of_books_id = v_set_of_books_id
       AND user_je_source_name = 'Payables';

    -- If any records exist in GL_INTERFACE then clean them up
    IF (l_dummy > 0) THEN
      cleanup_gl_interface
      (
        NULL,
        NULL,
        l_group_id,
        l_err_code,
        l_err_stage
      );
      retcode := l_err_code;
      errbuf := l_err_stage;
    ELSE
      BEGIN
         UPDATE fv_voided_checks
            SET processed_flag = 'P'
          WHERE processed_flag = 'S'
            AND org_id = l_org_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_err_code := SQLCODE;
          l_err_stage := SQLERRM;
          retcode := '2';
          errbuf := l_err_stage;
          fv_utility.log_mesg(fnd_log.level_exception,l_module_name||'update fv_voided_checks2',l_err_stage);
      END;
      BEGIN
         UPDATE fv_voided_checks
            SET processed_flag = 'X'
          WHERE processed_flag = 'U'
            AND org_id = l_org_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_err_code := SQLCODE;
          l_err_stage := SQLERRM;
          retcode := '2';
          errbuf := l_err_stage;
          fv_utility.log_mesg(fnd_log.level_exception,l_module_name||'update fv_voided_checks2',l_err_stage);
      END;
    END IF;
  END IF;

  IF ((retcode = '0') AND (l_count_void = 0)) THEN
    retcode := '1';
    errbuf := 'There are no void transactions to be submitted for DIT';
    fv_utility.log_mesg(fnd_log.level_exception,l_module_name,errbuf);
  END IF;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := '2';
    fv_utility.log_mesg(fnd_log.level_unexpected, l_module_name||'.final_exception',errbuf);
END;

---------------------------------------------------------------------------------------------------------------------------
PROCEDURE get_segment_values
(
  v_gs_ccid NUMBER
) IS
  l_module_name VARCHAR2(200);
BEGIN
  l_module_name :=  g_module_name || 'get_segment_values ';
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'in get_segment_values proc with v_gs_ccid'||v_gs_ccid);
  END IF;

  FOR i IN 1..30 LOOP
    a_segments(i) := NULL;
  END LOOP;

  BEGIN
    SELECT segment1,
           segment2,
           segment3,
           segment4,
           segment5,
           segment6,
           segment7,
           segment8,
           segment9,
           segment10,
           segment11,
           segment12,
           segment13,
           segment14,
           segment15,
           segment16,
           segment17,
           segment18,
           segment19,
           segment20,
           segment21,
           segment22,
           segment23,
           segment24,
           segment25,
           segment26,
           segment27,
           segment28,
           segment29,
           segment30
      INTO a_segments(1),
           a_segments(2),
           a_segments(3),
           a_segments(4),
           a_segments(5),
           a_segments(6),
           a_segments(7),
           a_segments(8),
           a_segments(9),
           a_segments(10),
           a_segments(11),
           a_segments(12),
           a_segments(13),
           a_segments(14),
           a_segments(15),
           a_segments(16),
           a_segments(17),
           a_segments(18),
           a_segments(19),
           a_segments(20),
           a_segments(21),
           a_segments(22),
           a_segments(23),
           a_segments(24),
           a_segments(25),
           a_segments(26),
           a_segments(27),
           a_segments(28),
           a_segments(29),
           a_segments(30)
      FROM gl_code_combinations
     WHERE code_combination_id = v_gs_ccid;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;
EXCEPTION
  WHEN OTHERS THEN
    g_errmsg := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_errmsg);
    RAISE;
END get_segment_values;

----------------------------------------------------------------------------------------------------------------------------
PROCEDURE main (	errbuf 	 		  OUT NOCOPY  		VARCHAR2,
			retcode 		  OUT NOCOPY  		VARCHAR2,
                	x_char_treas_conf_id      	IN 		VARCHAR2,
                	v_button_name             	IN 		VARCHAR2)

IS
        l_module_name                   VARCHAR2(200);
	x_group_id			NUMBER(15);
	x_interface_run_id 	  	NUMBER(15);
	x_err_code      		NUMBER;
	x_err_stage     		VARCHAR2(2000);
	v_boolean			BOOLEAN;
	req_id				NUMBER;
	call_status			BOOLEAN;
	rphase				VARCHAR2(30);
	rstatus				VARCHAR2(30);
	dphase				VARCHAR2(30);
	dstatus				VARCHAR2(30);
	message				VARCHAR2(240);
	v_dummy				NUMBER;
	v_process_job			VARCHAR2(1);
	v_period			fv_treasury_confirmations.gl_period%TYPE;
	l_set_of_books_name		VARCHAR2(200);

BEGIN

    l_module_name         :=  g_module_name || 'main ';
	-- initialise variables
  	x_err_code := 0;

  	-- AKA, 8/10/99, moved from declare section to body, so don't need to pass value
  	v_treasury_confirmation_id := TO_NUMBER(x_char_treas_conf_id);

	-- Obtain the org id

	---      v_org_id := TO_NUMBER(FND_PROFILE.VALUE('ORG_ID'));
        v_org_id := mo_global.get_current_org_id;

	-- Obtain the set of books id

	mo_utils.get_ledger_info(v_org_id,v_set_of_books_id,l_set_of_books_name);
        -- v_set_of_books_id := TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID'));--;>--



      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'set of books id = '||v_set_of_books_id);
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'org id = '||v_org_id);
      END IF;

      --Fix for bug 1715321: LG
      BEGIN

	SELECT 1
	INTO   v_dummy
	FROM   gl_je_categories
	WHERE  je_category_name = 'Treasury Confirmation';

	EXCEPTION WHEN NO_DATA_FOUND THEN
	  v_dummy := 0;

      END;

      IF (v_dummy = 0) THEN
	retcode := 2;
        errbuf := 'The Treasury Confirmation journal category has not been seeded';
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'v_button_name = '||v_button_name);
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'v_treasury_confirmation_id = '||TO_CHAR(v_treasury_confirmation_id));
        END IF;
        UPDATE fv_treasury_confirmations
	SET    confirmation_status_flag = DECODE(v_button_name, 'TREASURY_CONFIRMATION.CONFIRM', 'N', 'TREASURY_CONFIRMATION.BACK_OUT', 'Y')
	WHERE treasury_confirmation_id = v_treasury_confirmation_id;
	RETURN;
      END IF;


	IF v_button_name = 'TREASURY_CONFIRMATION.CONFIRM' THEN
		-- if the user pressed the confirm button do the confirm

		v_process_job := 'C'; -- this is so main will know a concurrent
					    -- process needs to be submitted for the confirm process

		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'v_process_job is = ' || v_process_job);
		END IF;

		fv_disb_in_transit.do_confirm_process
   				(		v_treasury_confirmation_id,
 						x_group_id,
                                x_err_code,
                                x_err_stage,
						v_period);


		IF x_err_code <> 0 THEN
		     errbuf := x_err_stage;
                     IF (x_err_code = 1) THEN
			retcode := '1';
		     ELSE
		        retcode := '2';
		     END IF;
		     process_clean_up;
		     RETURN;
		END IF;


	ELSIF v_button_name = 'TREASURY_CONFIRMATION.BACK_OUT' THEN
		-- do the back_out process.

		v_process_job := 'B'; -- this is so main will know a concurrent
					    -- process needs to be submitted for the backout process

-- AKA, 8/10/99, removed passing of v_treasury_confirmation_id
		fv_disb_in_transit.do_back_out_process
                      	(		x_group_id,
		       			x_err_code,
		       			x_err_stage);

		IF x_err_code <> 0 THEN
			errbuf := x_err_stage;
			retcode := '2';
			ROLLBACK;
			COMMIT;
			RETURN;

		END IF;
	END IF;

		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'v_process_job is = ' || v_process_job);
		END IF;

	IF v_process_job IN ('C','B') THEN
		-- if the v_process_job is 'C' or 'B' then there is a concurrent process
		-- to be submitted (c = confirm, b = back out)

		-- Obtain the interface run id
		x_interface_run_id :=gl_interface_control_pkg.get_unique_run_id;
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'interface_run_id = '||x_interface_run_id);
                END IF;

		-- Insert a control record in Gl_INTERFACE record for the Gl
		-- Import to work
		INSERT INTO gl_interface_control(je_source_name,status,
			interface_run_id,group_id,set_of_books_id)
		VALUES ('Payables', 'S', x_interface_run_id, x_group_id,
			v_set_of_books_id);

		-- Submit a Concurrent request to invoke journal import
		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'submitting a request');
		END IF;
		req_id := FND_REQUEST.SUBMIT_REQUEST(	'SQLGL',
									'GLLEZL',
									'',
									'',
									FALSE,
									TO_CHAR(x_interface_run_id),
									TO_CHAR(v_set_of_books_id),
									'N', '', '', 'N', 'N');

		-- if concurrent request submission failed then abort process
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'req_id = '||req_id);
                END IF;

		IF req_id = 0 THEN
			errbuf := 'Can not submit journal import program';
			retcode := '2';

			IF v_Process_job = 'C' THEN
				process_clean_up;
                  -- if the process is a backout, want to rollback and set status to Y for the treasury confirmation id
			ELSIF v_process_job = 'B' THEN
				ROLLBACK;
				UPDATE	fv_treasury_confirmations
				SET		confirmation_status_flag = 'Y'
				WHERE		treasury_confirmation_id = v_treasury_confirmation_id;
				COMMIT;
			END IF;
			RETURN;
	 	ELSE
			COMMIT;
       	END IF;

		-- Check status of completed concurrent program
		--   and if complete exit
            call_status := fnd_concurrent.wait_for_request(
			req_id, 20, 0, rphase, rstatus,
			dphase, dstatus, message);

		IF call_status = FALSE THEN
			errbuf := 'Can not wait for the status of journal import';
			retcode := '2';
		END IF;

	      v_dummy := 0;


		-- Do rows exist in the GL_INTERFACE table ?

			SELECT COUNT(*)
			INTO v_dummy
			FROM gl_interface
				WHERE group_id = x_group_id
				AND   set_of_books_id = v_set_of_books_id
				AND   user_je_source_name = 'Payables';

		-- If any records exist in GL_INTERFACE then clean them up
		IF v_dummy > 0 THEN
			fv_disb_in_transit.cleanup_gl_interface(
					     v_treasury_confirmation_id,
					     v_process_job,
					     x_group_id,
					     x_err_code,
					     x_err_stage);
-- if no interface records..everything is ok
	      ELSE

			IF v_button_name = 'TREASURY_CONFIRMATION.BACK_OUT' THEN

                           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Cleaning up Back OUT NOCOPY data');
                           END IF;

				-- back_out the info in ap_checks
		          UPDATE AP_CHECKS
			      SET 	treasury_pay_number = NULL,
         			 	treasury_pay_date = NULL,
         			 	last_update_date = SYSDATE,
   	    				last_updated_by = fnd_global.user_id,
          				last_update_login = fnd_global.login_id
				WHERE payment_id IN
					(SELECT	payment_id
	    			     FROM	fv_treasury_confirmations ftca,
                                    iby_payments_all ipa
				     WHERE  ftca.treasury_confirmation_id = v_treasury_confirmation_id
                             AND    ftca.payment_instruction_id   = ipa.payment_instruction_id);

                         UPDATE fv_treasury_confirmations
                         SET confirmation_status_flag = 'B',
		    	last_update_date = SYSDATE,
		    	last_updated_by = fnd_global.user_id,
		    	last_update_login = fnd_global.login_id
       		WHERE treasury_confirmation_id = v_treasury_confirmation_id;

                        --delete the offset record related to this payment
		        --batch.

                        DELETE FROM fv_tc_offsets
                        WHERE check_id IN (SELECT check_id
                             FROM ap_checks ac,
                                  fv_treasury_confirmations ftc,
                                  iby_payments_all ipa
                             WHERE ftc.treasury_confirmation_id = v_treasury_confirmation_id
                             AND   ftc.payment_instruction_id   = ipa.payment_instruction_id
                             AND   ipa.payment_id               = ac.payment_id);


		ELSIF v_button_name = 'TREASURY_CONFIRMATION.CONFIRM' THEN

                   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Updating confirm status');
                   END IF;
    					UPDATE fv_treasury_confirmations
					SET 	confirmation_status_flag = 'Y',
	            			    gl_period = v_period,
		    				last_update_date = SYSDATE,
		    				last_updated_by = fnd_global.user_id,
		    				last_update_login = fnd_global.login_id
					WHERE treasury_confirmation_id = v_treasury_confirmation_id;
			END IF;

		END IF;

		IF x_err_code <> 0 THEN
		     errbuf := x_err_stage;
                     IF (x_err_code = 1) THEN
			retcode := '1';
		     ELSE
		        retcode := '2';
		     END IF;
		END IF;
       END IF;

  COMMIT;

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Process Complete');
 END IF;
EXCEPTION
       WHEN OTHERS THEN
            g_errmsg := SQLERRM;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,g_errmsg);
            RAISE;
END main;
BEGIN
  g_module_name            := 'fv.plsql.fv_disb_in_transit.';
  c_gl_appl_id             := 101;
  c_application_short_name := 'SQLGL';
  c_key_flex_code	   := 'GL#';
END fv_disb_in_transit;

/
