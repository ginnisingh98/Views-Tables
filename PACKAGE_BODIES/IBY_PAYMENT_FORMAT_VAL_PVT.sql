--------------------------------------------------------
--  DDL for Package Body IBY_PAYMENT_FORMAT_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PAYMENT_FORMAT_VAL_PVT" AS
/* $Header: ibyfvvlb.pls 120.18.12010000.4 2009/12/08 06:45:13 pschalla ship $ */
-------------------------------------------------------------------------------------------------------------------

	g_FAILURE     		NUMBER;
	g_ERROR       		NUMBER;
	g_SUCCESS     		NUMBER;
	g_module_name 		VARCHAR2(100);
        g_current_level   	NUMBER;


-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: SCHEDULE_NUMBER

This procedure is responsible for validating Schedule Number

*/

        PROCEDURE SCHEDULE_NUMBER
          (
                p_format_name IN VARCHAR2,
                p_pinstr_id IN NUMBER,
                p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
                p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
                x_error_code  OUT NOCOPY NUMBER,
                x_error_mesg  OUT NOCOPY VARCHAR2
         )    IS

                  CURSOR sch_num_csr(p_pinstr_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE)
                  IS
                  SELECT pay_admin_assigned_ref_code
			FROM IBY_PAY_INSTRUCTIONS_ALL
                  WHERE  payment_instruction_id = p_pinstr_id;


                  l_constant 	NUMBER := 1;
                  l_incre	NUMBER  := 1;
                  l_char	VARCHAR2(1);
                  l_position	NUMBER;
                  l_sch_num_rec	sch_num_csr%ROWTYPE;
		  l_char_string VARCHAR2(40);
                  l_module_name VARCHAR2(200) := g_module_name || 'SCHEDULE_NUMBER';
                  l_message     VARCHAR2(1000);


                  BEGIN
                        x_error_code := g_SUCCESS;
                        l_message := 'Validating schedule number, Parameters: p_format_name = ' || p_format_name || ', p_instruction_id = ' || p_pinstr_id ;
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);


			OPEN sch_num_csr(p_pinstr_id);
			FETCH sch_num_csr into l_sch_num_rec;


			IF (sch_num_csr%FOUND) AND (l_sch_num_rec.pay_admin_assigned_ref_code IS NOT NULL) THEN -- If pay_admin_assigned_ref_code  is not null then only perform validation
                        	-- Handling Of Schedule Number For these two formats 			--
				IF p_format_name IN ('FVCONCTX','FVTICTX') THEN
					-- Only alpha numeric characters are allowed.
					l_char_string := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';

					FOR l_incre in 1..least(11, length(l_sch_num_rec.pay_admin_assigned_ref_code))
					LOOP
						l_position := INSTR(l_char_string,SUBSTR(upper(l_sch_num_rec.pay_admin_assigned_ref_code),l_incre,1)) ;
						EXIT WHEN l_position=0;
					END LOOP;

					IF l_position=0 THEN
                                                        l_message := 'pay_admin_assigned_ref_code = ' || l_sch_num_rec.pay_admin_assigned_ref_code;
					 		log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);
                                                        x_error_mesg := 'The Reference Assigned by Administrator number must contain only valid characters of "0-9" or "A-Z" ';
							p_docErrorRec.transaction_error_id := null;
                                                        p_docErrorRec.error_code := 'INVALID_SCHEDULE_NUMBER';
							p_docErrorRec.error_message := x_error_mesg;
                					x_error_code := g_ERROR;
							IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec,p_docErrorTab);
                                                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
							RETURN;
					END IF;

				ELSE
					FOR l_incre in 1..least(10, length(l_sch_num_rec.pay_admin_assigned_ref_code))
					LOOP
						l_position := INSTR(l_sch_num_rec.pay_admin_assigned_ref_code,'0',l_incre);
						l_char := substr(l_sch_num_rec.pay_admin_assigned_ref_code,l_incre,l_constant);

						IF (l_position = 1) AND (l_char = '0') THEN
                                                        l_message := 'pay_admin_assigned_ref_code = ' || l_sch_num_rec.pay_admin_assigned_ref_code;
					 		log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);
					 		x_error_mesg := 'The Reference Assigned by Administrator number must contain only valid characters of "0-9", "A-Z" or "-" and the first character must not be a zero.';
                                                        p_docErrorRec.transaction_error_id := null;
                                                        p_docErrorRec.error_code := 'INVALID_SCHEDULE_NUMBER';
							p_docErrorRec.error_message := x_error_mesg;
                					x_error_code := g_ERROR;
							IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec,p_docErrorTab);
                                                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
							RETURN;

						END IF; -- if first position of schedulenum is zero

						IF NOT ((UPPER(l_char) BETWEEN 'A' and 'Z') OR (l_char between '0' and '9') OR (l_char = '-')) THEN
							l_message := 'pay_admin_assigned_ref_code = ' || l_sch_num_rec.pay_admin_assigned_ref_code;
					 		log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);
                                                        x_error_mesg := 'The Reference Assigned by Administrator number must contain only valid characters of "0-9", "A-Z" or "-" and the first character must not be a zero.';
	                				p_docErrorRec.transaction_error_id := null;
                                                        p_docErrorRec.error_code := 'INVALID_SCHEDULE_NUMBER';
                					p_docErrorRec.error_message := x_error_mesg;
                					x_error_code := g_ERROR;
                					IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec,p_docErrorTab);
                                                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
							RETURN;
						END IF;	-- schedulenum has characters other than A-Z 1-0 -

					END LOOP;
				END IF;

			END IF; -- sch_num_csr%FOUND
        	CLOSE sch_num_csr;

        EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

        END SCHEDULE_NUMBER;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE 	: SUPPLIER_TYPE

This procedure is responsible for Validating Supplier Type .

If Format Name Is In ('FVTPCCD','FVTIACHP','FVSPCCD', 'FVSPCCDP', 'FVTICTX' ,'FVBLCCDP')  ONLY NON-EMPLOYEES ARE ALLOWED.

If Format Name Is In ('FVTPPPD','FVTPPPDP','FVSPPPDP','FVSPPPD', 'FVBLPPDP','FVBLSLTR') ONLY EMPLYEES ARE ALLOWED
If Format Name Is In ('FVTIACHB','FVBLNCR','FVSPNCR') EITHER ALL EMPLOYEES OR ALL NON EMPLOYEES ARE ALLOWED.

*/

    PROCEDURE SUPPLIER_TYPE
	(
	   p_format_name IN VARCHAR2,
	   p_instruction_id  IN NUMBER,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
           x_error_code  OUT NOCOPY NUMBER,
           x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

	-- Get Inovice ID From IBY_DOCS_PAYABLE_ALL
	CURSOR all_invoices_csr(p_instruction_id NUMBER)
	IS
	SELECT calling_app_doc_unique_ref2
		FROM IBY_DOCS_PAYABLE_ALL     -- added all
	WHERE	upper(document_type)='STANDARD'
	AND     calling_app_id=200
	AND     UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP')
        AND     payment_id in (select payment_id
                               from iby_payments_all
                               where payment_instruction_id = p_instruction_id);



	-- Get Vendor Id From AP_INVOICES
	CURSOR all_vendors_csr(p_invoice_id NUMBER)
	IS
		SELECT vendor_id, invoice_num
			FROM AP_INVOICES
		WHERE
			invoice_id=p_invoice_id;

	-- Get Vendor Type
	CURSOR vendor_type_csr(p_vendor_id NUMBER)
	IS
           SELECT nvl(vendor_type_lookup_code, 'XXX')  -- Bug 6398944
             FROM AP_SUPPLIERS
            WHERE vendor_id = p_vendor_id;


	l_invoice_id		NUMBER(15,0);
	l_vendor_id		NUMBER(15,0);
	l_vendor_type		VARCHAR2(30);
	l_emp			boolean;	-- If Employee
	l_non_emp		boolean;	-- If Other Than Employee
	l_inv_str		VARCHAR2(30);
        l_module_name VARCHAR2(200) := g_module_name || 'SUPPLIER_TYPE';
        l_message     VARCHAR2(1000);
        l_invoice_num           ap_invoices_all.invoice_num%TYPE;


	BEGIN
                  x_error_code := g_SUCCESS;
                  l_message := 'Validating Supplier Type, Parameters: p_format_name = ' || p_format_name || ', p_payment_instruction_id = ' || p_instruction_id ;
                  log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

		  IF p_format_name IN ('FVTPCCD','FVTIACHP','FVSPCCD','FVSPCCDP', 'FVTICTX' ,'FVBLCCDP') THEN


		  OPEN all_invoices_csr(p_instruction_id);	-- Opening all invocies cursor

		  LOOP -- Reading All Invoices

			 FETCH all_invoices_csr INTO  l_inv_str;	-- Getting Data
		  	 EXIT WHEN all_invoices_csr%NOTFOUND;
			 l_invoice_id := TO_NUMBER(l_inv_str);

                         l_message := 'Inside all_invoices_csr, l_invoice_id = ' || l_inv_str;

		  	 OPEN all_vendors_csr(l_invoice_id);
		  	 FETCH all_vendors_csr INTO l_vendor_id, l_invoice_num;
		  	 CLOSE all_vendors_csr;

			 OPEN vendor_type_csr(l_vendor_id);
		  	 FETCH vendor_type_csr INTO l_vendor_type;
		  	 CLOSE vendor_type_csr;
		  	 -- All Vendors Should Be Non-Employee
		  	 IF UPPER(l_vendor_type) = 'EMPLOYEE' THEN
                                 l_message := 'invoice_id = ' || l_inv_str || ' vendor_id = ' || l_vendor_id || ' vendor_type = ' || l_vendor_type;
				 log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);
		  		 x_error_mesg :=  'The vendor for invoice '|| l_invoice_num || ' cannot be of type EMPLOYEE.';
                                 p_docErrorRec.transaction_error_id := null;
                                 p_docErrorRec.error_code := 'INV_IS_EMPLOYEE';
				 p_docErrorRec.error_message := x_error_mesg;
				 x_error_code := g_ERROR;
				 IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                 log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
		  	 END IF;


		  END LOOP; -- End of For Each Invoice Loop
                  CLOSE all_invoices_csr; -- Closing Invoices Cursor

		  ELSIF p_format_name IN ('FVTPPPD','FVTPPPDP','FVSPPPDP','FVSPPPD','FVBLPPDP','FVBLSLTR') THEN

	  		  OPEN all_invoices_csr(p_instruction_id); -- Opening All Invoice Cursor

		  LOOP -- Reading All Invoices

		     FETCH all_invoices_csr INTO  l_inv_str;
		  	 EXIT WHEN all_invoices_csr%NOTFOUND;

			 l_invoice_id := TO_NUMBER(l_inv_str);

		  	 OPEN all_vendors_csr(l_invoice_id); -- Opeing Vendors Cursor
		  	 FETCH all_vendors_csr INTO l_vendor_id, l_invoice_num;
		  	 CLOSE all_vendors_csr;
		  	 OPEN vendor_type_csr(l_vendor_id);

			 FETCH vendor_type_csr INTO l_vendor_type;
		  	 CLOSE vendor_type_csr;

		  	 -- All Vendors Should Be Employee
		  	 IF UPPER(l_vendor_type) <> 'EMPLOYEE' THEN
                                  l_message := 'invoice_id = ' || l_inv_str || ' vendor_id = ' || l_vendor_id || 'vendor_type = ' || l_vendor_type;
				  log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);
		  		  x_error_mesg :=  'The vendor for invoice '|| l_invoice_num || ' must be of type EMPLOYEE.';
				  p_docErrorRec.transaction_error_id := null;
                                  p_docErrorRec.error_code := 'INV_IS_NOT_EMPLOYEE';
				  p_docErrorRec.error_message := x_error_mesg;
				  x_error_code := g_ERROR;
				  IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                  log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
		  	 END IF;


		  END LOOP; -- Ending For Each Invoice Loop
                  CLOSE all_invoices_csr; -- Closing Invoice Cursor

		  ELSIF	p_format_name IN ('FVTIACHB','FVBLNCR','FVSPNCR') THEN

	          OPEN all_invoices_csr(p_instruction_id);
                  l_emp:=false;
     	          l_non_emp:=false;

		  LOOP -- Reading All Invoices

		         FETCH all_invoices_csr INTO  l_inv_str;
		  	 EXIT WHEN all_invoices_csr%NOTFOUND;

			 l_invoice_id := TO_NUMBER(l_inv_str);

		  	 OPEN all_vendors_csr(l_invoice_id);
		  	 FETCH all_vendors_csr INTO l_vendor_id, l_invoice_num;
                         CLOSE all_vendors_csr;

		  	 OPEN vendor_type_csr(l_vendor_id);
			 FETCH vendor_type_csr INTO l_vendor_type;
		  	 CLOSE vendor_type_csr;

		  	 IF UPPER(l_vendor_type) = 'EMPLOYEE' THEN
				 l_emp:=TRUE;
			 ELSE
				 l_non_emp:=TRUE;
			 END IF;
		         -- Vendor Type Cannot Be a Mix Of Employee And Non Employee. Either All Employees Or All Non-Employees.
			IF (l_emp=true AND l_non_emp=TRUE) THEN
                                 l_message := 'invoice_id = ' || l_inv_str || ' vendor_id = ' || l_vendor_id || ' vendor_type = ' || l_vendor_type;
			         log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);
 		  	 	 x_error_mesg :=  'All selected invoices must have one vendor type, either EMPLOYEE or NON-EMPLOYEE.';
				 p_docErrorRec.transaction_error_id := null;
                                 p_docErrorRec.error_code := 'INV_IS_MIXED_VENDOR_TYPE';
				 p_docErrorRec.error_message := x_error_mesg;
				 x_error_code := g_ERROR;
				 IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                 log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                 CLOSE all_invoices_csr;
				 RETURN;
			END IF;


		  END LOOP; -- Ending Of For Each Invoice Loop
                  CLOSE all_invoices_csr; -- Closing Invoice Cursor

		  END IF;


	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END SUPPLIER_TYPE;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE 	: TREASURY_SYMBOLS_PROCESS

This procedure is responsible to insert the treasury symbol into the table FV_TP_TS_AMT_DATA along with the amount.
This table will later be used for the maximum treasury symbol validations.

*/


	PROCEDURE TREASURY_SYMBOLS_PROCESS
	(
	       p_format_name IN VARCHAR2,
               p_instruction_id   IN  NUMBER,
               p_payment_id  IN NUMBER,
	       p_invoice_id IN NUMBER,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	)IS


	-- Get Distribution Code Combination Id And SOB
	CURSOR dist_sob_csr(p_invoice_id NUMBER)
	IS
		SELECT apid.dist_code_combination_id,
		       apid.set_of_books_id,
		       apid.org_id,
                       apid.amount,  -- added this for 5466103
                       glpv.chart_of_accounts_id
		   FROM ap_invoice_distributions_all apid,
                        gl_ledgers_public_v glpv
		WHERE apid.invoice_id      = p_invoice_id
                AND   apid.set_of_books_id = glpv.ledger_id;

	-- Get Treasury Symbol For Given Fund Value And Ledger Id
	CURSOR treasury_symbol_csr(p_fund_value VARCHAR2 , p_ledger_id NUMBER)
        IS
		SELECT fvfp.fund_value fund_value,
	               fvts.treasury_symbol treasury_symbol
                   FROM fv_fund_parameters fvfp ,
		        fv_treasury_symbols fvts
		WHERE fvfp.treasury_symbol_id = fvts.treasury_symbol_id
		      AND
		      fvfp.set_of_books_id    = fvts.set_of_books_id
		      AND
		      fvfp.fund_value         = p_fund_value
		      AND
		      fvfp.set_of_books_id    = p_ledger_id ;

/*  comment this out since we need amounts at the distribution level, not header level -- bug 5466103
	-- Get Payment Amount And Instruction id Corresponding To Invoice Id
	CURSOR payid_amt_csr(p_invoice_id VARCHAR2, p_payment_id number)
	IS
		SELECT ibypmt.payment_amount
		   FROM iby_docs_payable_all ibydocpay,
			iby_payments_all ibypmt
		WHERE ibydocpay.payment_id = p_payment_id
                AND   ibydocpay.calling_app_doc_unique_ref2 = p_invoice_id
		AND   ibydocpay.payment_id=ibypmt.payment_id
		AND   ibydocpay.calling_app_id=200
		AND   UPPER(ibydocpay.document_type)='STANDARD'
		AND   UPPER(ibydocpay.payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');
*/





	l_dist_sob_rec		dist_sob_csr%ROWTYPE;
	l_tas_rec		treasury_symbol_csr%ROWTYPE;
	-- l_amt_id_rec		payid_amt_csr%ROWTYPE;

	l_dist_ccid		AP_INVOICE_DISTRIBUTIONS.dist_code_combination_id%TYPE;
	l_segment_column	BOOLEAN;
	apps_id 		NUMBER(10) := 101;
	l_flex_code  		VARCHAR2(20) := 'GL#';
	l_seg_name 		VARCHAR2(30);
	l_fund_val		VARCHAR2(100);
	l_row_exist		NUMBER;

	l_valid			NUMBER;
        l_message               VARCHAR2(1000);
        l_module_name 		VARCHAR2(200) := g_module_name || 'TREASURY_SYMBOLS_PROCESS';

	BEGIN
                x_error_code := g_SUCCESS;

                l_message := 'Running Treasury Symbols Process, Parameters: p_format_name = ' || p_format_name || ', p_invoice_id = ' || p_invoice_id || ' p_payment_id = ' || p_payment_id;
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);


		-- Get Distribution Code Combination Id For The Invoice Id

		OPEN dist_sob_csr(p_invoice_id); 	-- Opening Distribution And SOB Cursor

		LOOP


		FETCH dist_sob_csr INTO l_dist_sob_rec; 	-- Fetching Data From Distribution And SOB Cursor
		EXIT WHEN dist_sob_csr%NOTFOUND;

			-- Finding The Balancing Segment For SOB
			 l_segment_column := FND_FLEX_APIS.GET_SEGMENT_COLUMN(apps_id,
									      l_flex_code,
								              l_dist_sob_rec.chart_of_accounts_id,
									      'GL_BALANCING',
								              l_seg_name);

			IF l_segment_column THEN 	-- If Exists

				EXECUTE IMMEDIATE 'Select ' || l_seg_name || ' from GL_CODE_COMBINATIONS where code_combination_id= :ccid' INTO l_fund_val USING l_dist_sob_rec.dist_code_combination_id;

				OPEN treasury_symbol_csr(l_fund_val,l_dist_sob_rec.set_of_books_id);
				FETCH treasury_symbol_csr INTO l_tas_rec;

				IF treasury_symbol_csr%NOTFOUND THEN
					x_error_mesg :=  'Payment Format Program Aborts as the Funds are not associated with Treasury Symbols.  Please associate the fund value ' || l_fund_val ||' to a Treasury Symbol in Federal Administrator.';
					p_docErrorRec.transaction_error_id := null;
                                        p_docErrorRec.error_code := 'NO_TREASURY_SYMBOL';
					p_docErrorRec.error_message := x_error_mesg;
					x_error_code := g_ERROR;
					IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);

				ELSE
                                        l_valid := g_SUCCESS;  -- initialize l_valid
					IF p_format_name IN ('FVSPCCD','FVSPCCDP','FVSPNCR','FVSPPPD','FVSPPPDP', 'FVBLCCDP', 'FVBLPPDP') THEN


						TAS_VALIDATION(p_format_name,
							       l_tas_rec.treasury_symbol,
							       p_docErrorTab ,
							       p_docErrorRec ,
							       l_valid,
							       x_error_mesg );

                                         END IF; --add this end if, we want to do TAS validation for above formats, but we want
                                                 --to do the insert below for all formats

						IF(l_valid = g_SUCCESS) THEN

                                                        /* -- Bug 5466103
			    		                OPEN payid_amt_csr(TO_CHAR(p_invoice_id), p_payment_id);
					                FETCH payid_amt_csr INTO l_amt_id_rec;
                                                        CLOSE payid_amt_csr;
                                                        */


							SELECT count(*) INTO l_row_exist
								FROM FV_TP_TS_AMT_DATA
							WHERE
								treasury_symbol=l_tas_rec.treasury_symbol
								AND
								payment_instruction_id= p_instruction_id;



							IF l_row_exist=0 THEN

								INSERT INTO
									FV_TP_TS_AMT_DATA(treasury_symbol,
											  amount,
											  payment_instruction_id,
											  org_id,
											  set_of_books_id)
									VALUES(l_tas_rec.treasury_symbol,
									      l_dist_sob_rec.amount,    --changed from  l_amt_id_rec.payment_amount (bug 5466103)
										p_instruction_id,
										l_dist_sob_rec.org_id,
								                l_dist_sob_rec.set_of_books_id);



							ELSE
								UPDATE
							                FV_TP_TS_AMT_DATA
            							SET
							                amount = amount + l_dist_sob_rec.amount
							        WHERE
									treasury_symbol=l_tas_rec.treasury_symbol
									AND
									payment_instruction_id= p_instruction_id;



							END IF;
						  ELSIF(l_valid=g_ERROR) THEN
							x_error_code := g_ERROR;
						  ELSIF(l_valid=g_FAILURE) THEN
							x_error_code := g_FAILURE;
							RETURN;

						END IF;

					CLOSE treasury_symbol_csr;
					END IF;

				--  END IF; comment this out and move it to the top

			END IF; --End Of IF l_segment_column THEN


		END LOOP;	-- End Of Distribution Id and SOB Cursor Loop

		CLOSE dist_sob_csr; -- Closing Distribution Id and SOB Cursor



	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END TREASURY_SYMBOLS_PROCESS;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	:  MAX_TREASURY_SYMBOLS

This procedure is responsible to validate for maximum number of treasury symbols in a payment batch.

*/


	PROCEDURE MAX_TREASURY_SYMBOLS
	(
           p_format_name IN VARCHAR2,
	   p_instruction_id IN NUMBER,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

	l_lmt_blk_fmt_val 		VARCHAR2(10);
	l_count_tas			NUMBER;
        l_message               	VARCHAR2(1000);
        l_module_name 			VARCHAR2(200) := g_module_name || 'MAX_TREASURY_SYMBOLS';

	BEGIN
                x_error_code := g_SUCCESS;

                l_message := 'Validating Max Treasury Symbols, Parameters: p_format_name = ' || p_format_name || ', p_instruction_id = ' || p_instruction_id ;
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);


		IF p_format_name IN ('FVBLNCR','FVBLSLTR','FVBLCCDP','FVBLPPDP','FVCOCCDP','FVCOPPDP') THEN

			l_lmt_blk_fmt_val:=FND_PROFILE.VALUE('FV_BULK_FORMAT_LIMIT');

			IF UPPER(l_lmt_blk_fmt_val)= 'Y' THEN

			    SELECT COUNT(*) INTO l_count_tas
					FROM FV_TP_TS_AMT_DATA
				WHERE payment_instruction_id = p_instruction_id;

				IF l_count_tas > 10 THEN
		  			x_error_mesg :=  'Payment format aborts as it contains more than 10 Treasury symbols';
					p_docErrorRec.transaction_error_id := null;
                                        p_docErrorRec.error_code := 'TREASURY_SYMBOL_LIMIT';
					p_docErrorRec.error_message := x_error_mesg;
					x_error_code := g_ERROR;
					IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
				END IF;

			END IF;

		ELSIF p_format_name IN('FVSPCCD','FVSPCCDP','FVSPNCR','FVSPPPD','FVSPPPDP') THEN

			    SELECT COUNT(*) INTO l_count_tas
					FROM FV_TP_TS_AMT_DATA
				WHERE payment_instruction_id = p_instruction_id;

				IF l_count_tas > 10 THEN
		  			x_error_mesg :=  'Payment format aborts as it contains more than 10 Treasury symbols';
					p_docErrorRec.transaction_error_id := null;
                                        p_docErrorRec.error_code := 'TREASURY_SYMBOLS_LIMIT';
					p_docErrorRec.error_message := x_error_mesg;
					x_error_code := g_ERROR;
					IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
				END IF;
		END IF;


	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END MAX_TREASURY_SYMBOLS;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: AGENCY_ADDRESS

This procedure is respnosible for Validation of Agency Address.

Agency Address should not be NULL.

*/


	PROCEDURE AGENCY_ADDRESS
	(
           p_format_name IN VARCHAR2,
	   p_org_id IN NUMBER,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

	CURSOR get_agency_address_csr(p_org_id NUMBER)
	IS
	SELECT address_line_1, address_line_2, town_or_city, region_2, postal_code
		FROM fv_system_parameters_v
	WHERE
	 	ou_org_id=p_org_id;

	l_agencyadd_rec get_agency_address_csr%ROWTYPE ;
        l_message               VARCHAR2(1000);
        l_module_name 		VARCHAR2(200) := g_module_name || 'AGENCY_ADDRESS';

	BEGIN
		x_error_code := g_SUCCESS;

                l_message := 'Validating Agency Address, Parameters: p_format_name = ' || p_format_name || ', p_org_id = ' || p_org_id ;
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

		OPEN get_agency_address_csr(p_org_id);
		FETCH get_agency_address_csr INTO l_agencyadd_rec;
		CLOSE get_agency_address_csr;

		--	If all are blank
		IF (l_agencyadd_rec.address_line_1 IS NULL ) AND
		   (l_agencyadd_rec.address_line_2 IS NULL ) AND
		   (l_agencyadd_rec.town_or_city IS NULL ) AND
		   (l_agencyadd_rec.region_2 IS NULL ) AND
		   (l_agencyadd_rec.postal_code IS NULL )
		THEN
			x_error_mesg :=  'Invalid address for Agency';
			p_docErrorRec.transaction_error_id := null;
                        p_docErrorRec.error_code := 'INVALID_AGENCY_ADDRESS';
			p_docErrorRec.error_message := x_error_mesg;
			x_error_code := g_ERROR;
			IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
		END IF;


	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END AGENCY_ADDRESS;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: PAYEE_ADDRESS

This procedure is responsible for Validation of Payee Address

Payee Address should not be NULL.

*/


	PROCEDURE PAYEE_ADDRESS
	(
           p_format_name IN VARCHAR2,
	   p_payment_id IN NUMBER,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

	CURSOR get_payee_address_csr(p_payment_id NUMBER)
	IS
	 SELECT payee_address1,  payee_address2,  payee_address3, payee_address4, payee_city, payee_postal_code, payee_state
	 	FROM iby_payments_all
	 WHERE
	 	PAYMENT_ID=p_payment_id;

	l_payeeadd_rec get_payee_address_csr%ROWTYPE ;
        l_message               VARCHAR2(1000);
        l_module_name 		VARCHAR2(200) := g_module_name || 'PAYEE_ADDRESS';

	BEGIN
		x_error_code := g_SUCCESS;

                l_message := 'Validating Payee Address, Parameters: p_format_name = ' || p_format_name || ', p_payment_id = ' || p_payment_id ;
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

		OPEN get_payee_address_csr(p_payment_id);
		FETCH get_payee_address_csr INTO l_payeeadd_rec;
		CLOSE get_payee_address_csr;

		-- If Any Of The Address Field Is Blank
		IF ((l_payeeadd_rec.payee_address1 IS NULL ) AND
		   (l_payeeadd_rec.payee_address2 IS NULL ) AND
		   (l_payeeadd_rec.payee_address3 IS NULL ) AND
		   (l_payeeadd_rec.payee_address4 IS NULL )) OR
		   (l_payeeadd_rec.payee_city IS NULL ) OR
		   (l_payeeadd_rec.payee_postal_code IS NULL ) OR
		   (l_payeeadd_rec.payee_state IS NULL )
		THEN
			x_error_mesg :=  'Invalid address for Vendor';
			p_docErrorRec.transaction_error_id := null;
                        p_docErrorRec.error_code := 'INVALID_PAYEE_ADDRESS';
			p_docErrorRec.error_message := x_error_mesg;
			x_error_code := g_ERROR;
			IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
		END IF;


	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END PAYEE_ADDRESS;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: MAX_PAYMENT_AMT

This procedure is responsible for Validation of Payment Amount Exceeding the limit of 9,999,999.99

*/


	PROCEDURE MAX_PAYMENT_AMT
	(
           p_format_name IN VARCHAR2,
	   p_instruction_id IN NUMBER,
	   p_payment_amount IN NUMBER,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

        l_message               VARCHAR2(1000);
        l_module_name 		VARCHAR2(200) := g_module_name || 'MAX_PAYMENT_AMT';

	BEGIN
			x_error_code := g_SUCCESS;

                        l_message := 'Validating Max Payment Amount, Parameters: p_format_name = ' || p_format_name || ', p_instruction_id = ' || p_instruction_id ;
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

			IF p_payment_amount > 9999999.99 THEN
				x_error_mesg :=  'Payment Amount Exceeds the limit of $9,999,999.99';
				p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'INVALID_BULK_NCR_CHK_PAY';
				p_docErrorRec.error_message := x_error_mesg;
				x_error_code := g_ERROR;
				IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
			END IF;

	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END MAX_PAYMENT_AMT;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: MAX_PAYMENT_AMT_2

This procedure is responsible for Validation of Payment Amount Exceeding the limit of 999,999.99

*/


	PROCEDURE MAX_PAYMENT_AMT_2
	(
           p_format_name IN VARCHAR2,
	   p_instruction_id IN NUMBER,
	   p_payment_amount IN NUMBER,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

        l_message               VARCHAR2(1000);
        l_module_name 		VARCHAR2(200) := g_module_name || 'MAX_PAYMENT_AMT_2';

	BEGIN

		x_error_code := g_SUCCESS;

                l_message := 'Validating Max Payment Amount 2, Parameters: p_format_name = ' || p_format_name || ', p_instruction_id = ' || p_instruction_id ;
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

		IF p_payment_amount > 999999.99 THEN
			x_error_mesg :=  'Payment Amount Exceeds the limit of $999,999.99';
			p_docErrorRec.transaction_error_id := null;
                        p_docErrorRec.error_code := 'INVALID_INVOICE_AMOUNT';
			p_docErrorRec.error_message := x_error_mesg;
			x_error_code := g_ERROR;
			IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
		END IF;


	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END MAX_PAYMENT_AMT_2;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: PAY_TAX_BENEFIT

This procedure is responsible such that Payments should pertain to Tax / Benefit only.

*/


	PROCEDURE PAY_TAX_BENEFIT
	(
           p_format_name IN VARCHAR2,
           p_payment_id  IN NUMBER,
           p_invoice_id  IN NUMBER,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

        l_message               	VARCHAR2(1000);
        l_payment_reason_code           iby_docs_payable_all.payment_reason_code%TYPE;
        l_vendor_type_lookup_code       ap_suppliers.vendor_type_lookup_code%TYPE;
        l_module_name 			VARCHAR2(200) := g_module_name || 'PAY_TAX_BENEFIT';

	BEGIN
			x_error_code := g_SUCCESS;

                        l_message := 'Validating Pay Tax Benefit, Parameters: p_format_name = ' || p_format_name || ', p_invoice_id = ' || p_invoice_id ;
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

			SELECT idpa.payment_reason_code,
                               asup.vendor_type_lookup_code
                        INTO   l_payment_reason_code,
                               l_vendor_type_lookup_code
			FROM IBY_DOCS_PAYABLE_ALL idpa,     -- added all
                             ap_invoices_all aia,
                             ap_suppliers asup
			WHERE idpa.payment_id=p_payment_id
			AND   idpa.calling_app_doc_unique_ref2 = p_invoice_id
                        AND   aia.invoice_id = p_invoice_id
                        AND   asup.vendor_id = aia.vendor_id;

                        /* Validation rule: Bug 5457879: The validation set must look at the type of supplier.  If the supplier is
                           a type of Employee then the only type of reason codes that the invoice can have is 'US_FV_B','US_FV_C',
                           'US_FV_D','US_FV_O','US_FV_R', 'US_FV_X'. For the Supplier type of Organization (Standard Supplier),
                           the reason code can only be 'US_FV_V'.
                        */

                        IF (l_vendor_type_lookup_code = 'EMPLOYEE') THEN
                             IF (l_payment_reason_code NOT IN ('US_FV_B','US_FV_C','US_FV_D','US_FV_O','US_FV_R', 'US_FV_X')) THEN
				   x_error_mesg :=  'Payments to an Internal Employee can only have the following payment reason codes: SSA, VA, SSI, OPM, or RRB Benefit or Tax';
				   p_docErrorRec.transaction_error_id := null;
                                   p_docErrorRec.error_code := 'INVALID_PAY_TAX_BENEFIT';
				   p_docErrorRec.error_message := x_error_mesg;
				   x_error_code := g_ERROR;
				   IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                   l_message := 'Invalid reason code for type of vendor, reason_code = ' || l_payment_reason_code || ', vendor_type_code = ' || l_vendor_type_lookup_code;
                                   log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);
			     END IF;
                        ELSE -- vendor is of type organization
                             IF   (l_payment_reason_code <> 'US_FV_V') THEN
				   x_error_mesg :=  'Payments to a Standard Supplier can only have a payment reason code of ''Vendor Payment Sub-Type'' ';
				   p_docErrorRec.transaction_error_id := null;
                                   p_docErrorRec.error_code := 'INVALID_PAY_TAX_BENEFIT';
				   p_docErrorRec.error_message := x_error_mesg;
				   x_error_code := g_ERROR;
				   IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                   l_message := 'Invalid reason code for type of vendor, reason_code = ' || l_payment_reason_code || ', vendor_type_code = ' || l_vendor_type_lookup_code;
                                   log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);
			     END IF;
                        END IF;

	EXCEPTION
	WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                            	x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);


	END PAY_TAX_BENEFIT;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: PAY_SALARY_TRAVEL

This procedure is responsible such that Payments should pertain to Salary / Travel only.

*/


	PROCEDURE PAY_SALARY_TRAVEL
	(
           p_format_name IN VARCHAR2,
	   p_reason_code IN VARCHAR2,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

        l_message               VARCHAR2(1000);
        l_module_name 		VARCHAR2(200) := g_module_name || 'PAY_SALARY_TRAVEL';

	BEGIN
		x_error_code := g_SUCCESS;

                l_message := 'Validating Pay Salary Travel, Parameters: p_format_name = ' || p_format_name || ', p_reason_code = ' || p_reason_code ;
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

		IF p_reason_code IS NULL OR p_reason_code NOT IN ('US_FV_S','US_FV_T') THEN
			x_error_mesg :=  'The Check Salary / Travel NCR payments can only be generated for Salary or Travel payments. The Reason Code must be related to Salary  or  Travel';
			p_docErrorRec.transaction_error_id := null;
                        p_docErrorRec.error_code := 'INVALID_PAY_SALARY_TRAVEL';
			p_docErrorRec.error_message := x_error_mesg;
			x_error_code := g_ERROR;
			IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);


	END PAY_SALARY_TRAVEL;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: PAYEE_SSN

This procedure is responsible for Validation of Payee Social Security Number.

Payee Social Security Number should not be NULL.

*/


	PROCEDURE PAYEE_SSN
	(
           p_format_name IN VARCHAR2,
           p_ssn_tin IN VARCHAR2,
           p_payee_party_id   IN  VARCHAR2,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	) AS

        l_party_name            hz_parties.party_name%TYPE;
        l_message               VARCHAR2(1000);
        l_module_name 		VARCHAR2(200) := g_module_name || 'PAYEE_SSN';

	BEGIN

		x_error_code := g_SUCCESS;

                l_message := 'Validating Payee SSN, Parameters: p_format_name = ' || p_format_name || ', p_ssn_tin = ' || p_ssn_tin ;
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

                begin
                    select party_name
                    into l_party_name
                    from hz_parties
                    where party_id = p_payee_party_id;
                exception
                    when others then
                       l_party_name := null;
                end;


		IF p_ssn_tin IS NULL THEN
			x_error_mesg :=  'SSN / TIN must be supplied for payee ' || l_party_name;
			p_docErrorRec.transaction_error_id := null;
                        p_docErrorRec.error_code := 'NO_SSN_TIN';
			p_docErrorRec.error_message := x_error_mesg;
			x_error_code := g_ERROR;
			IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
		END IF;


	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END PAYEE_SSN;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: TAS_VALIDATION

This procedure is responsible for validation of Treasury account symbol (TAS) in Payment record .

TAS should me of minimum 7 characters and  can only be "0-9", "A-Z", ".", "(", ")", or "/"'.

*/


	PROCEDURE TAS_VALIDATION
	(
           p_format_name IN VARCHAR2,
	   p_treasury_symbol IN VARCHAR2,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

		l_length 		NUMBER;
	 	l_string		VARCHAR2(100);
    		l_char_string 	        VARCHAR2(50);
    		l_ans 			NUMBER;
                l_message               VARCHAR2(1000);
                l_module_name 		VARCHAR2(200) := g_module_name || 'TAS_VALIDATION';


	BEGIN
                x_error_code := g_SUCCESS;
		l_string := UPPER(p_treasury_symbol);
	  	l_length := LENGTH(l_string);

                l_message := 'TAS Validation, Parameters: p_format_name = ' || p_format_name || ', p_treasury_symbol = ' || p_treasury_symbol ;
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);


		IF l_length < 4 THEN
			x_error_mesg :=  'The Treasury Symbol ' || p_treasury_symbol || ' must contain a minimum of 4 characters';
			p_docErrorRec.transaction_error_id := null;
                        p_docErrorRec.error_code := 'TREASURY_SYMBOL_LENGTH';
			p_docErrorRec.error_message := x_error_mesg;
			x_error_code := g_ERROR;
			IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
		ELSE
			l_char_string := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/.()';

			FOR i in 1..l_length
			LOOP
				l_ans := INSTR(l_char_string,SUBSTR(l_string,i,1)) ;
				EXIT WHEN l_ans=0;
			END LOOP;

			IF l_ans=0 THEN
				x_error_mesg :=  'The Treasury Symbol  ' || p_treasury_symbol || ' should only contain the following characters:  "0-9", "A-Z", ".", "(", ")", or "/"';
				p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'INVALID_TREASURY_SYMBOL';
				p_docErrorRec.error_message := x_error_mesg;
				x_error_code := g_ERROR;
				IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
			END IF;


		END IF;

	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END TAS_VALIDATION;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: AGENCY_LOCATION_CODE

This procedure is responisble for Validation of Agency Location Code.

Agency Location Code should not be NULL.

*/


	PROCEDURE AGENCY_LOCATION_CODE
	(
           p_format_name IN VARCHAR2,
           p_agency_location_code 	IN ce_bank_accounts.agency_location_code%TYPE,
           p_bank_account_name		IN ce_bank_accounts.bank_account_name%TYPE,
	   p_docErrorTab 		IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec 		IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  		OUT NOCOPY NUMBER,
	   x_error_mesg  		OUT NOCOPY VARCHAR2
	)IS

         l_message               VARCHAR2(1000);
         l_module_name 		 VARCHAR2(200) := g_module_name || 'AGENCY_LOCATION_CODE';

		BEGIN
			x_error_code := g_SUCCESS;

                        l_message := 'Validating Agency Location Code, Parameters: p_format_name = ' || p_format_name || ', p_agency_location_code = ' || p_agency_location_code ;
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

			IF p_agency_location_code IS NULL THEN -- Agency Location Code Should Not Be Empty.
				x_error_mesg :=  'Agency Location Code captured in Bank Account Details window, is not defined for Bank Account ' || p_bank_account_name;
				x_error_mesg := x_error_mesg || '. Please correct the error, terminate this request and submit a new request';
				p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'NO_AGENCY_LOCATION_CODE';
				p_docErrorRec.error_message := x_error_mesg;
				x_error_code := g_ERROR;
				IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
			END IF;


	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END AGENCY_LOCATION_CODE;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: RTN_NUMBER

This procedure is responsible for validation of RTN Number.

It must a nine-digit numeric-only field.  Prohibit fewer or more than nine characters, allow for only numeric characters,
and prohibit the entry of all zeroes in this field. The ninth digit is the Check Digit which is validated using the Modulus formula.

*/


	PROCEDURE RTN_NUMBER
	(
           p_format_name IN VARCHAR2,
	   p_rtn_number IN VARCHAR2,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

	    l_counter     NUMBER;
	    l_digit       NUMBER;
	    l_sub_total   NUMBER;
	    l_total       NUMBER;
	    l_last_digit  NUMBER;
	    l_correct_cdg NUMBER;
	    l_target_cdg  NUMBER;
            l_message                    VARCHAR2(1000);
            l_module_name 		 VARCHAR2(200) := g_module_name || 'RTN_NUMBER';
            l_length      NUMBER;
            l_char_string VARCHAR2(50);
            l_ans 	  NUMBER;


	BEGIN
	    x_error_code  := g_SUCCESS;

            l_message := 'Validating RTN Number, Parameters: p_format_name = ' || p_format_name || ', p_rtn_number = ' || p_rtn_number ;
            log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);


            if (p_rtn_number is null) then
                        x_error_mesg :=  'Invalid Routing Number';
			x_error_mesg := x_error_mesg || '. Please correct the error, terminate this request and submit a new request';
        		p_docErrorRec.transaction_error_id := null;
                        p_docErrorRec.error_code := 'INVALID_RTN';
        		p_docErrorRec.error_message := x_error_mesg;
	        	x_error_code := g_ERROR;
	        	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                        RETURN;
             end if;



	    l_sub_total   := 0;
	    l_total       := 0;
	    l_counter     := 1;
            l_length := LENGTH(p_rtn_number);


	    /*
	    IF ((INSTR(TO_CHAR(TO_NUMBER(p_rtn_number)),'.')=0)
			AND
	       (LENGTH(p_rtn_number)=9)
			AND
	       (TO_NUMBER(p_rtn_number)>0)
			AND
	       (INSTR(p_rtn_number,'.') = 0)) THEN
            */
             -- The above code is causing problems, you need to just check if that each digit is a number between 0 and 9
             -- replace with the following code

             l_char_string := '0123456789';

             FOR i in 1..l_length
	     LOOP
		l_ans := INSTR(l_char_string,SUBSTR(p_rtn_number,i,1)) ;
		EXIT WHEN l_ans=0;
	     END LOOP;


             IF ((l_length = 9) AND (l_ans <> 0)) THEN
	      -- the value is 9 digit number value only now verify the check digit,
	      -- which is the 9th digit.

	      	FOR l_counter IN 1..8
		LOOP
	              	l_digit := SUBSTR(p_rtn_number, l_counter,1);

	        	IF l_counter IN (1,4,7) THEN
	          		l_sub_total := TO_NUMBER(l_digit) * 3;
	        		ELSIF l_counter IN (2,5,8) THEN
	          			l_sub_total := TO_NUMBER(l_digit) * 7;
	        		ELSIF l_counter IN (3,6) THEN
	          			l_sub_total := TO_NUMBER(l_digit) * 1;
	        	END IF;

	        	l_total := l_total + l_sub_total;
	        	l_sub_total := 0;
	        END LOOP;

	        l_last_digit := TO_NUMBER(SUBSTR(TO_CHAR(l_total),LENGTH(TO_CHAR(l_total))));

	        l_correct_cdg := 10 - l_last_digit;

	        IF l_correct_cdg = 10 THEN
	     	   l_correct_cdg := 0;
	     	END IF;

	        l_target_cdg := TO_NUMBER(SUBSTR(p_rtn_number,9));

	        IF l_correct_cdg = l_target_cdg THEN
	        	x_error_code := g_SUCCESS;
	      	ELSE
        		x_error_mesg :=  'Invalid Routing Number';
        		p_docErrorRec.transaction_error_id := null;
                        p_docErrorRec.error_code := 'INVALID_RTN';
        		p_docErrorRec.error_message := x_error_mesg;
	        	x_error_code := g_ERROR;
	        	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
	        END IF;

	    ELSE
	      -- failed, not a 9 digit numeric value
	        x_error_mesg :=  'Invalid Routing Number';
        	p_docErrorRec.transaction_error_id := null;
                p_docErrorRec.error_code := 'INVALID_RTN';
        	p_docErrorRec.error_message := x_error_mesg;
		x_error_code := g_ERROR;
	        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
	        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
	   END IF;


		EXCEPTION
			WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END RTN_NUMBER;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: PAY_ALONE_OPTION

This procedure is responsible for validation of Pay ALone.

"Pay Alone" for each invoice should not be 'NO' or NULL.


*/


	PROCEDURE PAY_ALONE_OPTION
	(
           p_format_name IN VARCHAR2,
	   p_invoice_id IN NUMBER,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS


	CURSOR get_pay_alone_flag_csr(p_invoice_id NUMBER)
	IS
	SELECT exclusive_payment_flag,
               invoice_num
	FROM ap_invoices_all
	WHERE
		invoice_id = p_invoice_id;

	l_pay_alone_flag        VARCHAR2(1);
        l_invoice_num 		ap_invoices_all.invoice_num%TYPE;
        l_message                    VARCHAR2(1000);
        l_module_name 		 VARCHAR2(200) := g_module_name || 'PAY_ALONE_OPTION';

	BEGIN
			x_error_code := g_SUCCESS;

                        l_message := 'Validating Pay Alone Option, Parameters: p_format_name = ' || p_format_name || ', p_invoice_id = ' || p_invoice_id ;
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

			OPEN get_pay_alone_flag_csr(p_invoice_id);
			FETCH get_pay_alone_flag_csr into l_pay_alone_flag, l_invoice_num; -- Getting Pay ALone Flag From AP_INVOICES_ALL using invoice_id
			CLOSE get_pay_alone_flag_csr;

			IF (l_pay_alone_flag IS NULL ) or ( UPPER(l_pay_alone_flag) ='N') THEN
					x_error_mesg :=  'Invoices for this payment format must be have the Pay Alone flag checked on the invoice ' || l_invoice_num || '.';
					p_docErrorRec.transaction_error_id := null;
                                        p_docErrorRec.error_code := 'INVALID_PAY_ALONE_FLAG';
					p_docErrorRec.error_message := x_error_mesg;
					x_error_code := g_ERROR;
					IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
			END IF;

	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END PAY_ALONE_OPTION;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: DEPOSITER_ACC_NUM

This procedure is responsible for Validation of Depositor Account number.

Account number should not be NULL.

*/

	PROCEDURE DEPOSITER_ACC_NUM
	(
           p_format_name IN VARCHAR2,
	   p_dep_account_no IN iby_ext_bank_accounts.bank_account_num%TYPE,
	   p_docErrorTab IN   OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN   OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

        l_message                VARCHAR2(1000);
        l_module_name 		 VARCHAR2(200) := g_module_name || 'DEPOSITER_ACC_NUM';
	l_char_string 	         VARCHAR2(50);
        l_length 		 NUMBER;
	l_ans 			 NUMBER;
	l_string		 VARCHAR2(100);

	BEGIN
		x_error_code := g_SUCCESS;

                l_message := 'Validating Depositor Account Number, Parameters: p_format_name = ' || p_format_name || ', p_dep_account_no = ' || p_dep_account_no ;
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

		IF p_dep_account_no IS NULL THEN --Account Number Should Not Be Empty
			x_error_mesg :=  'Bank account number missing for vendor';
			x_error_mesg := x_error_mesg || '. Please correct the error, terminate this request and submit a new request';
			p_docErrorRec.transaction_error_id := null;
                        p_docErrorRec.error_code := 'DEPOSITER_ACCOUNT_NO_MISSING';
			p_docErrorRec.error_message := x_error_mesg;
			x_error_code := g_ERROR;
			IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                ELSE
			l_string := rtrim(p_dep_account_no);
                        l_length := length(l_string);
     	                l_char_string := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-';

			FOR i in 1..l_length
			LOOP
				l_ans := INSTR(l_char_string,SUBSTR(l_string,i,1)) ;
				EXIT WHEN l_ans=0;
			END LOOP;

			IF ((l_ans=0) OR (l_length > 17)) THEN
				x_error_mesg :=  'The Depositor Account Number ' || p_dep_account_no || ' should be less or equal to 17 characters and should only contain the following characters:  "0-9", "A-Z" or "-"';
				p_docErrorRec.transaction_error_id := null;
                		p_docErrorRec.error_code := 'INVALID_DEPOSITER_ACCOUNT_NO';
				p_docErrorRec.error_message := x_error_mesg;
				x_error_code := g_ERROR;
				IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                		log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
			END IF;

		END IF;

	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);


	END DEPOSITER_ACC_NUM;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: ACCOUNT_TYPE

This procedure is responsible for Validation of Account type.

Valid values for bank account type are "CHECKING" - Checking account; "SAVINGS" - Savings account.

*/


	PROCEDURE ACCOUNT_TYPE
	(
           p_format_name IN VARCHAR2,
	   p_bank_account_type IN iby_ext_bank_accounts.bank_account_type%TYPE,
           p_bank_account_name IN iby_ext_bank_accounts.bank_account_name%TYPE,
           p_invoice_id        IN NUMBER,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

        l_message                VARCHAR2(1000);
        l_module_name 		 VARCHAR2(200) := g_module_name || 'ACCOUNT_TYPE';
        l_invoice_num            ap_invoices_all.invoice_num%TYPE;

	BEGIN

			x_error_code := g_SUCCESS;

                        l_message := 'Validating Account Type, Parameters: p_format_name = ' || p_format_name || ', p_bank_account_type = ' || p_bank_account_type ;
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

                        select invoice_num
                        into   l_invoice_num
                        from   ap_invoices_all
                        where  invoice_id = p_invoice_id;


--			Valid values for bank account type are "CHECKINGS" - Checking account; "SAVINGS" - Savings account.
			IF (p_bank_account_type IS NULL ) OR UPPER(p_bank_account_type) NOT IN ('CHECKING','SAVINGS') THEN
				x_error_mesg :=  'For the invoice ' || l_invoice_num || ', the payee bank account ' || p_bank_account_name || ' must have a bank account type of either ''Checking'' or "Savings''';
				x_error_mesg := x_error_mesg || '. Please correct the error, terminate this request and submit a new request';
				p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'INVALID_BANK_ACCOUNT_TYPE';
				p_docErrorRec.error_message := x_error_mesg;
				x_error_code := g_ERROR;
				IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
			END IF;


	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END ACCOUNT_TYPE;

-------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: RFC_ID

This procedure is responsible for validation of RFC_ID

RFC_ID should not be NULL.

*/

PROCEDURE RFC_ID
	(
           p_format_name 	IN VARCHAR2,
  	   p_payment_id 	IN NUMBER,
	   p_docErrorTab 	IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec 	IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  	OUT NOCOPY NUMBER,
	   x_error_mesg  	OUT NOCOPY VARCHAR2
	)IS

        l_message                VARCHAR2(1000);
        l_module_name 		 VARCHAR2(200) := g_module_name || 'RFC_ID';
        l_rfc_id		 iby_pay_instructions_all.rfc_identifier%TYPE;
        l_bank_account_id        iby_pay_instructions_all.internal_bank_account_id%TYPE;
        l_bank_branch_id         ce_bank_accounts.bank_branch_id%TYPE;
        l_bank_account_name      ce_bank_accounts.bank_account_name%TYPE;




	BEGIN
			x_error_code := g_SUCCESS;

                        l_message := 'Validating RFC Id, Parameters: p_format_name = ' || p_format_name || ', p_payment_id = ' || p_payment_id;
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

                        select hca.class_code,
                               ipa.internal_bank_account_id,
                               cba.bank_branch_id,
                               cba.bank_account_name
                        into   l_rfc_id,
                               l_bank_account_id,
                               l_bank_branch_id,
                               l_bank_account_name
                        from iby_payments_all ipa,
                             ce_bank_accounts cba,
                             hz_code_assignments  hca
                        where ipa.payment_id = p_payment_id
                        and   ipa.internal_bank_account_id = cba.bank_account_id(+)
                        and   hca.owner_table_name(+) = 'HZ_PARTIES'
                        and   hca.class_category(+)     = 'RFC_IDENTIFIER'
                        and   hca.owner_table_id(+) = cba.bank_branch_id;

			IF l_rfc_id IS NULL THEN -- p_rfc_identifier should not be Empty

                                 x_error_mesg :=  'RFC Identifier is not defined on the bank branch for bank account ' || l_bank_account_name;
                                 l_message := x_error_mesg || ' l_bank_account_id = ' || l_bank_account_id || ', l_bank_branch_id = ' || l_bank_branch_id;
			         p_docErrorRec.transaction_error_id := null;
                                 p_docErrorRec.error_code := 'INVALID_RFC_ID';
				 p_docErrorRec.error_message := x_error_mesg;
				 x_error_code := g_ERROR;
				 IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                 log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

			END IF;


	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END RFC_ID;



-------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: MANDATORY_PPD_PPDP_REASON_CODE

This procedure is responsible for validation of following formats

Bulk Data PPDP Payment Format Report   'FVBLPPDP'

ECS PPD Vendor Payment Format Program   'FVTPPPD'

ECS PPDP Vendor Payment Format Program  'FVTPPPDP'

SPS PPD Vendor Payment Format Program	'FVSPPPD'

SPS PPDP Vendor Payment Format Program 	'FVSPPPDP'

to have a payment with a specified Federal payment reason.

*/
	PROCEDURE MANDATORY_PPD_PPDP_REASON_CODE
	(
       	       p_format_name IN VARCHAR2,
	       p_reason_code IN VARCHAR2,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

        l_message                VARCHAR2(1000);
        l_module_name 		 VARCHAR2(200) := g_module_name || 'MANDATORY_PPD_PPDP_REASON_CODE';

	BEGIN
			x_error_code := g_SUCCESS;

                        l_message := 'Validating Reason Code Id, Parameters: p_format_name = ' || p_format_name || ', p_reason_code = ' || p_reason_code ;
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);


			IF (p_reason_code IS NULL) OR p_reason_code NOT IN('US_FV_A','US_FV_B','US_FV_C','US_FV_D',
										'US_FV_I','US_FV_M','US_FV_O','US_FV_R',
										'US_FV_S','US_FV_T','US_FV_X') THEN
					x_error_mesg :=  'This payment format can must have a Federal payment reason defined for each payment.  The following are valid payment reasons: Allotments,
							SSA Benefits, VA Benefits, VAINS, Miscellaneous PPD, OPM Benefits, RRB Benefits, Salary, Travel and Tax.';
					p_docErrorRec.transaction_error_id := null;
                                        p_docErrorRec.error_code := 'INVALID_PAYMENT_REASON';
					p_docErrorRec.error_message := x_error_mesg;
					x_error_code := g_ERROR;
					IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);

			END IF;

	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END MANDATORY_PPD_PPDP_REASON_CODE;
-----------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: EXTERNAL_BANK_ACCOUNT_ID

This procedure is responsible for validation of EXTERNAL_BANK_ACCOUNT_ID

EXTERNAL_BANK_ACCOUNT_ID should not be NULL.

*/


	PROCEDURE EXTERNAL_BANK_ACCOUNT_ID
	(
           p_format_name 		IN VARCHAR2,
  	   p_external_bank_account_id 	IN NUMBER,
	   p_docErrorTab 		IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec 		IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  		OUT NOCOPY NUMBER,
	   x_error_mesg  		OUT NOCOPY VARCHAR2
	)IS

        l_message                	VARCHAR2(1000);
        l_module_name 		 	VARCHAR2(200) := g_module_name || 'EXTERNAL_BANK_ACCOUNT_ID';



	BEGIN
			x_error_code := g_SUCCESS;

                        l_message := 'Validating External Bank Account Id, Parameters: p_format_name = ' || p_format_name || ', p_external_bank_account_id = ' || p_external_bank_account_id;
                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

			IF p_external_bank_account_id IS NULL THEN -- p_external_bank_account_id  should not be Empty

				x_error_mesg :=  'This is an electronic format and requires a remit-to bank account to be entered on the invoice.';
				x_error_mesg := x_error_mesg || '. Please correct the error, terminate this request and submit a new request';
				p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'INVALID_EXTERNAL_BANK_ACCOUNT';
				p_docErrorRec.error_message := x_error_mesg;
				x_error_code := g_ERROR;
				IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);

			END IF;

	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END EXTERNAL_BANK_ACCOUNT_ID;
-----------------------------------------------------------------------------------------------------------------
      PROCEDURE FEDERAL_ID_NUMBER
	(
       	       p_format_name IN VARCHAR2,
               p_pay_instruction_id IN NUMBER,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	)IS
           l_message                	VARCHAR2(1000);
           l_module_name 		VARCHAR2(200) := g_module_name || 'FEDERAL_ID_NUMBER';
           l_org_id 			number;
           l_org_name                   hr_all_organization_units.name%TYPE;
           l_fed_employer_id_number 	fv_operating_units_all.fed_employer_id_number%TYPE;

      BEGIN
           x_error_code := g_SUCCESS;

           IF (p_format_name IN ('FVBLCCDP','FVBLPPDP')) THEN
                l_message := 'Validating Federal Id Number Id, Parameters: p_format_name = ' || p_format_name;
           	log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);

           	select ipia.org_id, haou.name
           	into l_org_id, l_org_name
           	from 	iby_pay_instructions_all ipia,
                	hr_all_organization_units haou
           	where ipia.payment_instruction_id = p_pay_instruction_id
           	and   ipia.org_id = haou.organization_id;


          	select fed_employer_id_number
           	into l_fed_employer_id_number
           	from fv_operating_units_all
           	where org_id = l_org_id;

           	IF l_fed_employer_id_number IS NULL THEN -- l_fed_employer_id_number  should not be null

			x_error_mesg :=  'The FederalEmployer ID Number(FEIN) must be defined on the Define Federal Options ' ||
                                  	'window in Federal Administrator for the operating unit ' || l_org_name;
			p_docErrorRec.transaction_error_id := null;
                	p_docErrorRec.error_code := 'INVALID_FEDERAL_ID_NUMBER';
			p_docErrorRec.error_message := x_error_mesg;
			x_error_code := g_ERROR;
			IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                	log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);

	   	END IF;
 	  END IF;
       EXCEPTION
               WHEN NO_DATA_FOUND THEN
                       	x_error_mesg :=  'The FederalEmployer ID Number(FEIN) must be defined on the Define Federal Options ' ||
                                         'window in Federal Administrator for the operating unit ' || l_org_name;
			p_docErrorRec.transaction_error_id := null;
                	p_docErrorRec.error_code := 'INVALID_FEDERAL_ID_NUMBER';
			p_docErrorRec.error_message := x_error_mesg;
			x_error_code := g_ERROR;
			IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                	log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);

		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

       END FEDERAL_ID_NUMBER;

------------------------------------------------------------------------------------------------------------------
PROCEDURE AGENCY_ID_ABBREVIATION
	(
           p_format_name IN VARCHAR2,
	   p_instruction_id IN NUMBER,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	)IS

        l_message               	VARCHAR2(1000);
        l_module_name 			VARCHAR2(200) := g_module_name || 'AGENCY_ID_ABBREVIATION';

	BEGIN
                x_error_code := g_SUCCESS;

                l_message := 'Validating Agency Id Abbreviation, Parameters: p_format_name = ' || p_format_name || ', p_instruction_id = ' || p_instruction_id ;
                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, l_message);


		IF p_format_name IN ('FVBLNCR','FVBLSLTR','FVBLCCDP','FVBLPPDP','FVTICTX') THEN

			IF FND_PROFILE.VALUE('FV_AGENCY_ID_ABBREVIATION') IS NULL THEN

		  			x_error_mesg :=  'Profile FV:FV_AGENCY_ID_ABBREVIATION must be defined.';
					p_docErrorRec.transaction_error_id := null;
                                        p_docErrorRec.error_code := 'AGENCY_ABBREV_UNDEFINED';
					p_docErrorRec.error_message := x_error_mesg;
					x_error_code := g_ERROR;
					IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                        log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);

			END IF;

		END IF;


	EXCEPTION
		WHEN OTHERS THEN
				x_error_code := g_FAILURE;
                                x_error_mesg := SQLERRM;
                                log_error_messages(FND_LOG.LEVEL_STATEMENT, l_module_name, x_error_mesg);
                                p_docErrorRec.transaction_error_id := null;
                                p_docErrorRec.error_code := 'UNEXPECTED_ERROR';
                                p_docErrorRec.error_message := x_error_mesg;
                                IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(p_docErrorRec, p_docErrorTab);
                                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',p_docErrorTab);

	END AGENCY_ID_ABBREVIATION;




-------------------------------------------------------------------------------------------------------------------
      /*
      * Write immediate validation messages to the common
      * application logs. Write deferred validation messages
      * to the concurrent manager log file.
      *
      * If FND_GLOBAL.conc_request_id is -1, it implies that
      * this method has not been invoked via the concurrent
      * manager (online validation case; write to apps log).
      */

        PROCEDURE LOG_ERROR_MESSAGES
        (
            p_level   IN NUMBER,
            p_module  IN VARCHAR2,
            p_message IN VARCHAR2
        ) IS

        BEGIN

             IF (p_level >= g_current_level) THEN
                      fnd_log.string (p_level, p_module, p_message);
             END IF;

             -- log messages only if concurrent program
             IF (FND_GLOBAL.conc_request_id <> -1) THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG, p_module || ': ' || p_message);
             END IF;

        END LOG_ERROR_MESSAGES;


-----------------------------------------------------------------------------------------------------------------
	BEGIN
			g_module_name := 'fv.plsql.IBY_PAYMENT_FORMAT_VAL_PVT.';
			g_ERROR := -1;
			g_FAILURE := -2;
			g_SUCCESS := 0;
                        g_current_level := fnd_log.g_current_runtime_level;


END IBY_PAYMENT_FORMAT_VAL_PVT;

/
