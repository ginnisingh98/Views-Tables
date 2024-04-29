--------------------------------------------------------
--  DDL for Package Body IBY_PAYMENT_FORMAT_VAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PAYMENT_FORMAT_VAL_PUB" AS
/* $Header: ibyfvvsb.pls 120.14.12010000.3 2009/07/16 12:47:07 bkjain ship $ */
----------------------------------------------------------------------------------------------------------

-- Declaring Global Variables

	g_EXCEPTION	NUMBER;
	g_FAILURE	NUMBER;
	g_SUCCESS	NUMBER;

----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVBLCCDP

Bulk Data CCDP Payment Format Report

*/

        PROCEDURE FVBLCCDP
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%type,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS
		-- Initialising Payment Record
		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id
				FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
                        -- Pick up Tax Payer Id/SSN from here -- Bug 5468203
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
                               payee_party_id,
                               payee_le_registration_num,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code,
                               external_bank_account_id,
                               ext_bank_account_name,
                               ext_bank_account_number,
                               ext_branch_number,
                               ext_bank_account_type
			FROM iby_payments_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT 	calling_app_doc_unique_ref2
			FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');



			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;



		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid		NUMBER;

	BEGIN
		l_format_name := 'FVBLCCDP';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;


		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data


		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                        -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

                        -- Do validation of the Federal Identification Number
                        IBY_PAYMENT_FORMAT_VAL_PVT.FEDERAL_ID_NUMBER(
       	       							l_format_name,
               							p_instruction_id,
	       							l_docErrorTab,
	       							l_docErrorRec,
	       							l_valid,
								l_error_message);

                        IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

                        -- Do validation of Agency Id Abbreviation
                        IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ID_ABBREVIATION(
       	       							l_format_name,
               							p_instruction_id,
	       							l_docErrorTab,
	       							l_docErrorRec,
	       							l_valid,
								l_error_message);

                        IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL

				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;

                                IBY_PAYMENT_FORMAT_VAL_PVT.RFC_ID(l_format_name,
							  l_iby_pmt_rec.payment_id,
							  l_docErrorTab,
							  l_docErrorRec,
							  l_valid,
							  l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
				RETURN;
				END IF;



				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL

					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;

					-- validate internal bank account parameters
					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
		     								        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					-- validate external bank account parameters
                                        -- validate external bank account id
                                        IBY_PAYMENT_FORMAT_VAL_PVT.EXTERNAL_BANK_ACCOUNT_ID(l_format_name,
											 	l_iby_pmt_rec.external_bank_account_id,
		     								         	l_docErrorTab,
									                 	l_docErrorRec,
									                 	l_valid,
									                 	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
							x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
							x_result:=1;
							RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.ACCOUNT_TYPE(l_format_name,
										l_iby_pmt_rec.ext_bank_account_type,
                                                                                l_iby_pmt_rec.ext_bank_account_name,
                                                                                TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     								                l_docErrorTab,
							                        l_docErrorRec,
							                  	l_valid,
							                        l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.DEPOSITER_ACC_NUM(l_format_name,
				    					             l_iby_pmt_rec.ext_bank_account_number,
     								                     l_docErrorTab,
							                             l_docErrorRec,
							                             l_valid,
							                             l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.RTN_NUMBER(l_format_name,
		  							      l_iby_pmt_rec.ext_branch_number,
     							           	      l_docErrorTab,
						                  	      l_docErrorRec,
						                 	      l_valid,
						                 	      l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;



					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_ALONE_OPTION(l_format_name,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                    p_instruction_id,
                                                                                    l_iby_pmt_rec.payment_id,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;



					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
									l_iby_pmt_rec.payee_le_registration_num,
                                                                        l_iby_pmt_rec.payee_party_id,
								        l_docErrorTab,
							                l_docErrorRec,
							                l_valid,
							                l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;




				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.MAX_TREASURY_SYMBOLS(l_format_name,
									p_instruction_id,
									l_docErrorTab,
									l_docErrorRec,
									l_valid,
									l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
						                   p_instruction_id,
							           l_docErrorTab,
							           l_docErrorRec,
							           l_valid,
						    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;



		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	END FVBLCCDP; -- End of Procedure FVBLCCDP

----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVBLNCR

Bulk Data NCR Payment Format Report

*/

        PROCEDURE FVBLNCR
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id,
				payment_reason_code
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;
			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
                               payee_party_id,
                               payee_le_registration_num,
			       payment_instruction_id,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code
		FROM  iby_payments_all
		WHERE payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
			FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');


			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;
		l_org_id		NUMBER;

		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid		NUMBER;


	BEGIN
		l_format_name := 'FVBLNCR';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                        -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_Id

                         -- Do validation of Agency Id Abbreviation
                        IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ID_ABBREVIATION(
       	       							l_format_name,
               							p_instruction_id,
	       							l_docErrorTab,
	       							l_docErrorRec,
	       							l_valid,
								l_error_message);

                        IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;

                                IBY_PAYMENT_FORMAT_VAL_PVT.RFC_ID(l_format_name,
							  l_iby_pmt_rec.payment_id,
							  l_docErrorTab,
							  l_docErrorRec,
							  l_valid,
							  l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
				RETURN;
				END IF;

				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT at Payment Level
				IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT(l_format_name,
									   l_iby_pmt_rec.payment_instruction_id,
								           l_iby_pmt_rec.payment_amount,
     								           l_docErrorTab,
							                   l_docErrorRec,
							                   l_valid,
						        	           l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;



				IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS(l_format_name,
									  l_org_id,
      								          l_docErrorTab,
							                  l_docErrorRec,
							                  l_valid,
							                  l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_ADDRESS(l_format_name,
									 l_iby_pmt_rec.payment_id,
      								         l_docErrorTab,
							                 l_docErrorRec,
							                 l_valid,
							                 l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;




				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;

				        -- validate internal bank account parameters
					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
			     							        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


                                        -- Do Validation by IBY_PAYMENT_FORMAT_VAL_PVT.PAY_TAX_BENEFIT at Instruction Level
					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_TAX_BENEFIT(l_format_name,
                                                                   		   l_iby_pmt_rec.payment_id,
		 						   		   to_number(l_iby_docs_rec.calling_app_doc_unique_ref2),
							   	   		   l_docErrorTab,
							  	   		   l_docErrorRec,
							           		   l_valid,
							           		   l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                            p_instruction_id,
                                                                                            l_iby_pmt_rec.payment_id,
			   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     								         	            l_docErrorTab,
							                 		    l_docErrorRec,
							                 		    l_valid,
							                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;



					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
									l_iby_pmt_rec.payee_le_registration_num,
                                                                        l_iby_pmt_rec.payee_party_id,
								        l_docErrorTab,
							                l_docErrorRec,
						        	        l_valid,
						                	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
					RETURN;
					END IF;



				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.MAX_TREASURY_SYMBOLS(l_format_name,
									p_instruction_id,
									l_docErrorTab,
									l_docErrorRec,
									l_valid,
									l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
						                   p_instruction_id,
							           l_docErrorTab,
							           l_docErrorRec,
							           l_valid,
						    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);



	END FVBLNCR;-- End of Procedure FVBLNCR
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVBLPPDP

Bulk Data PPDP Payment Format Report

*/

        PROCEDURE FVBLPPDP(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id,
				payment_reason_code
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
			       payment_instruction_id,
                               payee_party_id,
                               payee_le_registration_num,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code,
                               external_bank_account_id,
                               ext_bank_account_name,
                               ext_bank_account_number,
                               ext_branch_number,
                               ext_bank_account_type
			FROM   iby_payments_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
			FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');



			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;
		l_format_name   	VARCHAR2(50);
		l_error_message		VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVBLPPDP';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                        -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

                        -- Do validation of the Federal Identification Number
                        IBY_PAYMENT_FORMAT_VAL_PVT.FEDERAL_ID_NUMBER(
       	       							l_format_name,
               							p_instruction_id,
	       							l_docErrorTab,
	       							l_docErrorRec,
	       							l_valid,
								l_error_message);

                        IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

                         -- Do validation of Agency Id Abbreviation
                        IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ID_ABBREVIATION(
       	       							l_format_name,
               							p_instruction_id,
	       							l_docErrorTab,
	       							l_docErrorRec,
	       							l_valid,
								l_error_message);

                        IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor

			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;

			        IBY_PAYMENT_FORMAT_VAL_PVT.RFC_ID(l_format_name,
							  l_iby_pmt_rec.payment_id,
							  l_docErrorTab,
							  l_docErrorRec,
							  l_valid,
							  l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
				RETURN;
				END IF;

				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT_2 at Payment Level
				IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT_2(l_format_name,
									   l_iby_pmt_rec.payment_instruction_id,
								           l_iby_pmt_rec.payment_amount,
	     							           l_docErrorTab,
							                   l_docErrorRec,
							                   l_valid,
							                   l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;

					-- validate internal bank account parameters
                                        IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
			     							        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
					RETURN;
					END IF;

                                        -- validate external bank account parameters
                                         -- validate external bank account id
                                        IBY_PAYMENT_FORMAT_VAL_PVT.EXTERNAL_BANK_ACCOUNT_ID(l_format_name,
											    l_iby_pmt_rec.external_bank_account_id,
		     								            l_docErrorTab,
									                    l_docErrorRec,
									                    l_valid,
									                    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
							x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
							x_result:=1;
							RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.ACCOUNT_TYPE(l_format_name,
										l_iby_pmt_rec.ext_bank_account_type,
                                                                                l_iby_pmt_rec.ext_bank_account_name,
                                                                                TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     								                l_docErrorTab,
							                        l_docErrorRec,
							                  	l_valid,
							                 	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
					RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.DEPOSITER_ACC_NUM(l_format_name,
				    						     l_iby_pmt_rec.ext_bank_account_number,
     								                     l_docErrorTab,
							                             l_docErrorRec,
							                             l_valid,
							                             l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
					RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.RTN_NUMBER(l_format_name,
			   						      l_iby_pmt_rec.ext_branch_number,
     								              l_docErrorTab,
							                      l_docErrorRec,
							                      l_valid,
							                      l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
					RETURN;
					END IF;




					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_ALONE_OPTION(l_format_name,
	   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
   						         	            l_docErrorTab,
					                 		    l_docErrorRec,
					                 		    l_valid,
					                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                            			p_instruction_id,
                                                                            			l_iby_pmt_rec.payment_id,
	   								    			TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     						         	            			l_docErrorTab,
					                 		    			l_docErrorRec,
					                 		    			l_valid,
					                 		    			l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
										l_iby_pmt_rec.payee_le_registration_num,
                                                                		l_iby_pmt_rec.payee_party_id,
										l_docErrorTab,
							        		l_docErrorRec,
							        		l_valid,
							        		l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.MAX_TREASURY_SYMBOLS(l_format_name,
									p_instruction_id,
									l_docErrorTab,
									l_docErrorRec,
									l_valid,
									l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
						                   p_instruction_id,
							           l_docErrorTab,
							           l_docErrorRec,
							           l_valid,
						    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			IBY_PAYMENT_FORMAT_VAL_PVT.MANDATORY_PPD_PPDP_REASON_CODE(l_format_name,
						 				  l_pay_instr_rec.payment_reason_code,
							           		  l_docErrorTab,
							                  	  l_docErrorRec,
							           		  l_valid,
						    	            		  l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVBLPPDP;-- End of Procedure FVBLPPDP
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVBLSLTR

Bulk Data Salary Travel NCR Payment Format

*/

        PROCEDURE FVBLSLTR
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id,payment_reason_code
				FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
                               payment_instruction_id,
                               payee_party_id,
                               payee_le_registration_num,
                               payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code
			FROM iby_payments_all
			WHERE
				payment_instruction_id = p_instruction_id;
			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
			FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');



			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;

		l_org_id		NUMBER;
		l_format_name   	VARCHAR2(50);
		l_error_message		VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVBLSLTR';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                        -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_ID

                         -- Do validation of Agency Id Abbreviation
                        IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ID_ABBREVIATION(
       	       							l_format_name,
               							p_instruction_id,
	       							l_docErrorTab,
	       							l_docErrorRec,
	       							l_valid,
								l_error_message);

                        IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			-- Do Validation by IBY_PAYMENT_FORMAT_VAL_PVT.PAY_SALARY_TRAVEL at Instruction Level
			IBY_PAYMENT_FORMAT_VAL_PVT.PAY_SALARY_TRAVEL(l_format_name,
		 						     l_pay_instr_rec.payment_reason_code,
							   	     l_docErrorTab,
							  	     l_docErrorRec,
							             l_valid,
							             l_error_message);
			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;

                                IBY_PAYMENT_FORMAT_VAL_PVT.RFC_ID(l_format_name,
							  l_iby_pmt_rec.payment_id,
							  l_docErrorTab,
							  l_docErrorRec,
							  l_valid,
							  l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
				RETURN;
				END IF;

				IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS(l_format_name,
									  l_org_id,
	      							          l_docErrorTab,
							                  l_docErrorRec,
							                  l_valid,
							                  l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;

				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT_2 at Payment Level
				IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT_2(l_format_name,
									     l_iby_pmt_rec.payment_instruction_id,
								             l_iby_pmt_rec.payment_amount,
	     							             l_docErrorTab,
							                     l_docErrorRec,
							                     l_valid,
							                     l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;


					-- validate internal bank account parameters
					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
				     							l_docErrorTab,
										        l_docErrorRec,
										        l_valid,
										        l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN		-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
					RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                    p_instruction_id,
                                                                                    l_iby_pmt_rec.payment_id,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
									l_iby_pmt_rec.payee_le_registration_num,
                                                                        l_iby_pmt_rec.payee_party_id,
								        l_docErrorTab,
							                l_docErrorRec,
							                l_valid,
							                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;



				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.MAX_TREASURY_SYMBOLS(l_format_name,
									p_instruction_id,
									l_docErrorTab,
									l_docErrorRec,
									l_valid,
									l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
						                   p_instruction_id,
							           l_docErrorTab,
							           l_docErrorRec,
							           l_valid,
						    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN

        x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVBLSLTR;-- End of Procedure FVBLSLTR
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVTICTX

CTX ACH Vendor Payment Format Report

*/

        PROCEDURE FVTICTX
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
			       payment_instruction_id,
                               payee_party_id,
                               payee_le_registration_num,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code,
                               external_bank_account_id,
                               ext_bank_account_name,
                               ext_bank_account_number,
                               ext_branch_number,
                               ext_bank_account_type
			FROM iby_payments_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
			FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');



			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;
		l_org_id		NUMBER;

		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVTICTX';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                        -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_ID

                         -- Do validation of Agency Id Abbreviation
                        IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ID_ABBREVIATION(
       	       							l_format_name,
               							p_instruction_id,
	       							l_docErrorTab,
	       							l_docErrorRec,
	       							l_valid,
								l_error_message);

                        IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;

                                IBY_PAYMENT_FORMAT_VAL_PVT.RFC_ID(l_format_name,
							  l_iby_pmt_rec.payment_id,
							  l_docErrorTab,
							  l_docErrorRec,
							  l_valid,
							  l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
				RETURN;
				END IF;

				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT at Payment Level
				IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT(l_format_name,
									   l_iby_pmt_rec.payment_instruction_id,
								           l_iby_pmt_rec.payment_amount,
     								           l_docErrorTab,
							                   l_docErrorRec,
							                   l_valid,
							                   l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS
				IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS(l_format_name,
									  l_org_id,
     								          l_docErrorTab,
							                  l_docErrorRec,
							                  l_valid,
							                  l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;

				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;


 					-- validate internal bank account parameters
                                        IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
			     							        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					-- validate external bank account parameters
                                        -- validate external bank account id
                                        IBY_PAYMENT_FORMAT_VAL_PVT.EXTERNAL_BANK_ACCOUNT_ID(l_format_name,
											 	l_iby_pmt_rec.external_bank_account_id,
		     								         	l_docErrorTab,
									                 	l_docErrorRec,
									                 	l_valid,
									                 	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.ACCOUNT_TYPE(l_format_name,
										l_iby_pmt_rec.ext_bank_account_type,
                                                                                l_iby_pmt_rec.ext_bank_account_name,
                                                                                TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     								                l_docErrorTab,
							                        l_docErrorRec,
							                  	l_valid,
							                 	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.DEPOSITER_ACC_NUM(l_format_name,
				    						     l_iby_pmt_rec.ext_bank_account_number,
     								                     l_docErrorTab,
							                             l_docErrorRec,
							                             l_valid,
							                             l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.RTN_NUMBER(l_format_name,
			   						      l_iby_pmt_rec.ext_branch_number,
	     							              l_docErrorTab,
							                      l_docErrorRec,
							                      l_valid,
							                      l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					-- bug 8577262
					/*
					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_ALONE_OPTION(l_format_name,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;
					*/

					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                    p_instruction_id,
                                                                                    l_iby_pmt_rec.payment_id,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
									     l_iby_pmt_rec.payee_le_registration_num,
                                                                             l_iby_pmt_rec.payee_party_id,
							         	     l_docErrorTab,
						                 	     l_docErrorRec,
						                 	     l_valid,
						                 	     l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;




				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
						                   p_instruction_id,
							           l_docErrorTab,
							           l_docErrorRec,
							           l_valid,
						    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVTICTX;-- End of Procedure FVTICTX
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVTPCCD

ECS CCD Vendor Payment Format Report

*/

        PROCEDURE FVTPCCD
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
			       payment_instruction_id,
                               payee_party_id,
                               payee_le_registration_num,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code,
                               external_bank_account_id,
                               ext_bank_account_name,
                               ext_bank_account_number,
                               ext_branch_number,
                               ext_bank_account_type
			FROM iby_payments_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
			FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');



			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;
		l_org_id		NUMBER;

		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVTPCCD';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                         -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_ID

                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;


                                IBY_PAYMENT_FORMAT_VAL_PVT.RFC_ID(l_format_name,
							  l_iby_pmt_rec.payment_id,
							  l_docErrorTab,
							  l_docErrorRec,
							  l_valid,
							  l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
				RETURN;
				END IF;

				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS
				IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS(l_format_name,
									 l_org_id,
     								         l_docErrorTab,
							                 l_docErrorRec,
							                 l_valid,
							                 l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;

					-- validate internal bank account parameters
					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
			     							        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

 					-- validate external bank account parameters
                                        -- validate external bank account id
                                        IBY_PAYMENT_FORMAT_VAL_PVT.EXTERNAL_BANK_ACCOUNT_ID(l_format_name,
											    l_iby_pmt_rec.external_bank_account_id,
		     								            l_docErrorTab,
									                    l_docErrorRec,
									                    l_valid,
									                    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
							x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
							x_result:=1;
							RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.ACCOUNT_TYPE(l_format_name,
										l_iby_pmt_rec.ext_bank_account_type,
                                                                                l_iby_pmt_rec.ext_bank_account_name,
                                                                                TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
	     							                l_docErrorTab,
							                        l_docErrorRec,
							                  	l_valid,
							                 	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.DEPOSITER_ACC_NUM(l_format_name,
				    						     l_iby_pmt_rec.ext_bank_account_number,
	     							                     l_docErrorTab,
							                             l_docErrorRec,
							                             l_valid,
							                             l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.RTN_NUMBER(l_format_name,
			   						      l_iby_pmt_rec.ext_branch_number,
	     							              l_docErrorTab,
							                      l_docErrorRec,
							                      l_valid,
							                      l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_ALONE_OPTION(l_format_name,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                    p_instruction_id,
                                                                                    l_iby_pmt_rec.payment_id,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;



					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
									l_iby_pmt_rec.payee_le_registration_num,
                                                                        l_iby_pmt_rec.payee_party_id,
								        l_docErrorTab,
							                l_docErrorRec,
							                l_valid,
							                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;




				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
						                   p_instruction_id,
							           l_docErrorTab,
							           l_docErrorRec,
							           l_valid,
						    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVTPCCD;-- End of Procedure FVTPCCD
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVTIACHP

ECS CCDP Vendor Payment Format Report

*/

        PROCEDURE FVTIACHP
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
			       payment_instruction_id,
                               payee_party_id,
                               payee_le_registration_num,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code,
                               external_bank_account_id,
                               ext_bank_account_name,
                               ext_bank_account_number,
                               ext_branch_number,
                               ext_bank_account_type
			FROM iby_payments_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
			FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');


			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;
		l_org_id		NUMBER;

		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVTIACHP';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                         -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_ID


                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;

                                IBY_PAYMENT_FORMAT_VAL_PVT.RFC_ID(l_format_name,
							  l_iby_pmt_rec.payment_id,
							  l_docErrorTab,
							  l_docErrorRec,
							  l_valid,
							  l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
				RETURN;
				END IF;

				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS
				IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS(l_format_name,
									 l_org_id,
     								         l_docErrorTab,
							                 l_docErrorRec,
							                 l_valid,
							                 l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;



				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;

					-- validate internal bank account parameters
					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
			     							        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

                                        -- validate external bank account parameters
                                        -- validate external bank account id
                                        IBY_PAYMENT_FORMAT_VAL_PVT.EXTERNAL_BANK_ACCOUNT_ID(l_format_name,
											 	l_iby_pmt_rec.external_bank_account_id,
		     								         	l_docErrorTab,
									                 	l_docErrorRec,
									                 	l_valid,
									                 	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
							x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
							x_result:=1;
							RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.ACCOUNT_TYPE(l_format_name,
										l_iby_pmt_rec.ext_bank_account_type,
                                                                                l_iby_pmt_rec.ext_bank_account_name,
                                                                                TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     								                l_docErrorTab,
							                        l_docErrorRec,
							                  	l_valid,
							                        l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.DEPOSITER_ACC_NUM(l_format_name,
				    						     l_iby_pmt_rec.ext_bank_account_number,
     								                     l_docErrorTab,
							                             l_docErrorRec,
							                             l_valid,
							                             l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.RTN_NUMBER(l_format_name,
			   						      l_iby_pmt_rec.ext_branch_number,
     								              l_docErrorTab,
							                      l_docErrorRec,
							                      l_valid,
							                      l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_ALONE_OPTION(l_format_name,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                    p_instruction_id,
                                                                                    l_iby_pmt_rec.payment_id,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;



					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
									l_iby_pmt_rec.payee_le_registration_num,
                                                                        l_iby_pmt_rec.payee_party_id,
								        l_docErrorTab,
							                l_docErrorRec,
							                l_valid,
							                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;




				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
						                   p_instruction_id,
							           l_docErrorTab,
							           l_docErrorRec,
							           l_valid,
						    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVTIACHP;-- End of Procedure FVTIACHP
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVTIACHB

ECS Check NCR Payment Format

*/

        PROCEDURE FVTIACHB
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id,
				payment_reason_code
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
			       payment_instruction_id,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code
		FROM  iby_payments_all
		WHERE payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
				FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');


			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;
		l_org_id		NUMBER;

		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVTIACHB';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                         -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_ID


                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;

                                IBY_PAYMENT_FORMAT_VAL_PVT.RFC_ID(l_format_name,
							  l_iby_pmt_rec.payment_id,
							  l_docErrorTab,
							  l_docErrorRec,
							  l_valid,
							  l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
				RETURN;
				END IF;

				IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT(l_format_name,
									   l_iby_pmt_rec.payment_instruction_id,
								           l_iby_pmt_rec.payment_amount,
     								           l_docErrorTab,
							                   l_docErrorRec,
							                   l_valid,
							                   l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS
				IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS(l_format_name,
									 l_org_id,
     								         l_docErrorTab,
							                 l_docErrorRec,
							                 l_valid,
							                 l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_ADDRESS
				IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_ADDRESS(l_format_name,
									 l_iby_pmt_rec.payment_id,
     								         l_docErrorTab,
							                 l_docErrorRec,
							                 l_valid,
							                 l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;



				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;

					-- validate internal bank account parameters
					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
			     							        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


                                         -- Do Validation by IBY_PAYMENT_FORMAT_VAL_PVT.PAY_TAX_BENEFIT at Instruction Level
					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_TAX_BENEFIT(l_format_name,
                                                                   		   l_iby_pmt_rec.payment_id,
		 						   		   to_number(l_iby_docs_rec.calling_app_doc_unique_ref2),
							   	   		   l_docErrorTab,
							  	   		   l_docErrorRec,
							           		   l_valid,
							           		   l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                            p_instruction_id,
                                                                                            l_iby_pmt_rec.payment_id,
			   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
	     							         	            l_docErrorTab,
							                 		    l_docErrorRec,
							                 		    l_valid,
							                 		    l_error_message);

						IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
							x_result:=1;
						ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
							x_result:=1;
							RETURN;
						END IF;

				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
						                   p_instruction_id,
							           l_docErrorTab,
							           l_docErrorRec,
							           l_valid,
						    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVTIACHB;-- End of Procedure FVTIACHB
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVTPPPD

ECS PPD Vendor Payment Format

*/

        PROCEDURE FVTPPPD
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id,
				payment_reason_code
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
                               payee_party_id,
                               payee_le_registration_num,
			       payment_instruction_id,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code,
                               external_bank_account_id,
                               ext_bank_account_name,
                               ext_bank_account_number,
                               ext_branch_number,
                               ext_bank_account_type
			FROM iby_payments_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
			FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');



			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;
		l_org_id		NUMBER;

		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVTPPPD';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                         -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_ID

                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;

			        IBY_PAYMENT_FORMAT_VAL_PVT.RFC_ID(l_format_name,
							  l_iby_pmt_rec.payment_id,
							  l_docErrorTab,
							  l_docErrorRec,
							  l_valid,
							  l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
				RETURN;
				END IF;

				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS
				IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS(l_format_name,
									 l_org_id,
     								         l_docErrorTab,
							                 l_docErrorRec,
							                 l_valid,
							                 l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT_2 at Payment Level
				IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT_2(l_format_name,
									   l_iby_pmt_rec.payment_instruction_id,
								           l_iby_pmt_rec.payment_amount,
     								           l_docErrorTab,
							                   l_docErrorRec,
							                   l_valid,
							                   l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;

					-- validate internal bank account parameters
					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
			     							        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					-- validate external bank account parameters
                                        -- validate external bank account id
                                        IBY_PAYMENT_FORMAT_VAL_PVT.EXTERNAL_BANK_ACCOUNT_ID(l_format_name,
											 	l_iby_pmt_rec.external_bank_account_id,
		     								         	l_docErrorTab,
									                 	l_docErrorRec,
									                 	l_valid,
									                 	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
							x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
							x_result:=1;
							RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.ACCOUNT_TYPE(l_format_name,
										l_iby_pmt_rec.ext_bank_account_type,
                                                                                l_iby_pmt_rec.ext_bank_account_name,
                                                                                TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     								                l_docErrorTab,
							                        l_docErrorRec,
							                  	l_valid,
							                 	l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
							x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
							x_result:=1;
							RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.DEPOSITER_ACC_NUM(l_format_name,
				    						     l_iby_pmt_rec.ext_bank_account_number,
     								                     l_docErrorTab,
							                             l_docErrorRec,
							                             l_valid,
							                             l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;



					IBY_PAYMENT_FORMAT_VAL_PVT.RTN_NUMBER(l_format_name,
			   						      l_iby_pmt_rec.ext_branch_number,
     								              l_docErrorTab,
							                      l_docErrorRec,
							                      l_valid,
							                      l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_ALONE_OPTION(l_format_name,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                    p_instruction_id,
                                                                                    l_iby_pmt_rec.payment_id,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;



					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
									l_iby_pmt_rec.payee_le_registration_num,
                                                                        l_iby_pmt_rec.payee_party_id,
								        l_docErrorTab,
							                l_docErrorRec,
							                l_valid,
							                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;




				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
						                   p_instruction_id,
							           l_docErrorTab,
							           l_docErrorRec,
							           l_valid,
						    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			IBY_PAYMENT_FORMAT_VAL_PVT.MANDATORY_PPD_PPDP_REASON_CODE(l_format_name,
						 				  l_pay_instr_rec.payment_reason_code,
							           		  l_docErrorTab,
							                  	  l_docErrorRec,
							           		  l_valid,
						    	            		  l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;



		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVTPPPD;-- End of Procedure FVTPPPD
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVTPPPDP

ECS PPDP Vendor Payment Format

*/

        PROCEDURE FVTPPPDP
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id,
				payment_reason_code
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
			       payment_instruction_id,
                               payee_party_id,
                               payee_le_registration_num,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code,
                               external_bank_account_id,
                               ext_bank_account_name,
                               ext_bank_account_number,
                               ext_branch_number,
                               ext_bank_account_type
			FROM iby_payments_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
				FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');



			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;
		l_org_id		NUMBER;

		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVTPPPDP';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                         -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_ID


                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;


                                IBY_PAYMENT_FORMAT_VAL_PVT.RFC_ID(l_format_name,
							  l_iby_pmt_rec.payment_id,
							  l_docErrorTab,
							  l_docErrorRec,
							  l_valid,
							  l_error_message);

				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
				RETURN;
				END IF;

				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS
				IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_ADDRESS(l_format_name,
									 l_org_id,
     								         l_docErrorTab,
							                 l_docErrorRec,
							                 l_valid,
							                 l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;

				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT_2 at Payment Level
				IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT_2(l_format_name,
									   l_iby_pmt_rec.payment_instruction_id,
								           l_iby_pmt_rec.payment_amount,
     								           l_docErrorTab,
							                   l_docErrorRec,
							                   l_valid,
							                   l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;

					-- validate internal bank account parameters
					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
			     							        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					-- validate external bank account parameters
                                        -- validate external bank account id
                                        IBY_PAYMENT_FORMAT_VAL_PVT.EXTERNAL_BANK_ACCOUNT_ID(l_format_name,
											 	l_iby_pmt_rec.external_bank_account_id,
		     								         	l_docErrorTab,
									                 	l_docErrorRec,
									                 	l_valid,
									                 	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
							x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
							x_result:=1;
							RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.ACCOUNT_TYPE(l_format_name,
										l_iby_pmt_rec.ext_bank_account_type,
                                                                                l_iby_pmt_rec.ext_bank_account_name,
                                                                                TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     								                l_docErrorTab,
							                        l_docErrorRec,
							                  	l_valid,
							                 	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.DEPOSITER_ACC_NUM(l_format_name,
				    						     l_iby_pmt_rec.ext_bank_account_number,
     								                     l_docErrorTab,
							                             l_docErrorRec,
							                             l_valid,
							                             l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.RTN_NUMBER(l_format_name,
			   						      l_iby_pmt_rec.ext_branch_number,
     								              l_docErrorTab,
							                      l_docErrorRec,
							                      l_valid,
							                      l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;



					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_ALONE_OPTION(l_format_name,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                    p_instruction_id,
                                                                                    l_iby_pmt_rec.payment_id,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;



					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
									l_iby_pmt_rec.payee_le_registration_num,
                                                                        l_iby_pmt_rec.payee_party_id,
								        l_docErrorTab,
							                l_docErrorRec,
							                l_valid,
							                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;




				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
						                   p_instruction_id,
							           l_docErrorTab,
							           l_docErrorRec,
							           l_valid,
						    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			IBY_PAYMENT_FORMAT_VAL_PVT.MANDATORY_PPD_PPDP_REASON_CODE(l_format_name,
						 				  l_pay_instr_rec.payment_reason_code,
							           		  l_docErrorTab,
							                  	  l_docErrorRec,
							           		  l_valid,
						    	            		  l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVTPPPDP;-- End of Procedure FVTPPPDP
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVSPCCD

SPS CCD Vendor Payment Format

*/

        PROCEDURE FVSPCCD
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
			       payment_instruction_id,
                               payee_party_id,
                               payee_le_registration_num,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code,
                               external_bank_account_id,
                               ext_bank_account_name,
                               ext_bank_account_number,
                               ext_branch_number,
                               ext_bank_account_type
			FROM iby_payments_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
			FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');



			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;
		l_org_id		NUMBER;

		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVSPCCD';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                         -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_ID

                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;


				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;

					-- validate internal bank account parameters
					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
			     							        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

 					-- validate external bank account parameters
                                        -- validate external bank account id
                                        IBY_PAYMENT_FORMAT_VAL_PVT.EXTERNAL_BANK_ACCOUNT_ID(l_format_name,
											    l_iby_pmt_rec.external_bank_account_id,
		     								            l_docErrorTab,
									                    l_docErrorRec,
									                    l_valid,
									                    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
							x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
							x_result:=1;
							RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.ACCOUNT_TYPE(l_format_name,
										l_iby_pmt_rec.ext_bank_account_type,
                                                                                l_iby_pmt_rec.ext_bank_account_name,
                                                                                TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     								                l_docErrorTab,
							                        l_docErrorRec,
							                  	l_valid,
							                 	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.DEPOSITER_ACC_NUM(l_format_name,
				    							     l_iby_pmt_rec.ext_bank_account_number,
     								                             l_docErrorTab,
							                                     l_docErrorRec,
							                                     l_valid,
							                                     l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.RTN_NUMBER(l_format_name,
			   						      l_iby_pmt_rec.ext_branch_number,
     								              l_docErrorTab,
							                      l_docErrorRec,
							                      l_valid,
							                      l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_ALONE_OPTION(l_format_name,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                    p_instruction_id,
                                                                                    l_iby_pmt_rec.payment_id,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

--IBY_PAYMENT_FORMAT_VAL_PVT.TAS_VALIDATION Is Directly Called From IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS



					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
									l_iby_pmt_rec.payee_le_registration_num,
                                                                        l_iby_pmt_rec.payee_party_id,
								        l_docErrorTab,
							                l_docErrorRec,
							                l_valid,
							                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;




				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.MAX_TREASURY_SYMBOLS(l_format_name,
									p_instruction_id,
									l_docErrorTab,
									l_docErrorRec,
									l_valid,
									l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

		IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
					                   p_instruction_id,
						           l_docErrorTab,
						           l_docErrorRec,
						           l_valid,
					    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;



		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVSPCCD;-- End of Procedure FVSPCCD
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVSPCCDP

SPS CCDP Vendor Payment Format

*/

        PROCEDURE FVSPCCDP
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
			       payment_instruction_id,
                               payee_party_id,
                               payee_le_registration_num,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code,
                               external_bank_account_id,
                               ext_bank_account_name,
                               ext_bank_account_number,
                               ext_branch_number,
                               ext_bank_account_type
			FROM iby_payments_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
				FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');



			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;
		l_org_id		NUMBER;

		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVSPCCDP';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                         -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_ID

                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;

				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;

					-- validate internal bank account parameters
					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
			     							        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					-- validate external bank account parameters
                                         -- validate external bank account id
                                        IBY_PAYMENT_FORMAT_VAL_PVT.EXTERNAL_BANK_ACCOUNT_ID(l_format_name,
											    l_iby_pmt_rec.external_bank_account_id,
		     								            l_docErrorTab,
									                    l_docErrorRec,
									                    l_valid,
									                    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
							x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
							x_result:=1;
							RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.ACCOUNT_TYPE(l_format_name,
										l_iby_pmt_rec.ext_bank_account_type,
                                                                                l_iby_pmt_rec.ext_bank_account_name,
                                                                                TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     								                l_docErrorTab,
							                        l_docErrorRec,
							                  	l_valid,
							                 	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.DEPOSITER_ACC_NUM(l_format_name,
				    						     l_iby_pmt_rec.ext_bank_account_number,
     								                     l_docErrorTab,
							                             l_docErrorRec,
							                             l_valid,
							                             l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.RTN_NUMBER(l_format_name,
			   						      l_iby_pmt_rec.ext_branch_number,
     								              l_docErrorTab,
							                      l_docErrorRec,
							                      l_valid,
							                      l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_ALONE_OPTION(l_format_name,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                    p_instruction_id,
                                                                                    l_iby_pmt_rec.payment_id,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

--IBY_PAYMENT_FORMAT_VAL_PVT.TAS_VALIDATION Is Directly Called From IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS



					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
									l_iby_pmt_rec.payee_le_registration_num,
                                                                        l_iby_pmt_rec.payee_party_id,
								        l_docErrorTab,
							                l_docErrorRec,
							                l_valid,
							                l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;




				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.MAX_TREASURY_SYMBOLS(l_format_name,
									p_instruction_id,
									l_docErrorTab,
									l_docErrorRec,
									l_valid,
									l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


		IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
					                   p_instruction_id,
						           l_docErrorTab,
						           l_docErrorRec,
						           l_valid,
					    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
		END IF;


		END IF; -- End of IF pay_instr_data_csr%FOUND


		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVSPCCDP;-- End of Procedure FVSPCCDP
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVSPNCR

SPS NCR Vendor Payment Format

*/

        PROCEDURE FVSPNCR
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id,
				payment_reason_code
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
			       payment_instruction_id,
                               payee_party_id,
                               payee_le_registration_num,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code
			FROM  iby_payments_all
			WHERE payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
				FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');



			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;
		l_org_id		NUMBER;

		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVSPNCR';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                         -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_ID

                         -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;

				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT at Payment Level
				IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT(l_format_name,
									   l_iby_pmt_rec.payment_instruction_id,
								           l_iby_pmt_rec.payment_amount,
     								           l_docErrorTab,
							                   l_docErrorRec,
							                   l_valid,
							                   l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_ADDRESS
				IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_ADDRESS(l_format_name,
									 l_iby_pmt_rec.payment_id,
     								         l_docErrorTab,
							                 l_docErrorRec,
							                 l_valid,
							                 l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;




				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;


					-- validate internal bank account parameters
					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
		     								        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                 l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;



                                         -- Do Validation by IBY_PAYMENT_FORMAT_VAL_PVT.PAY_TAX_BENEFIT at Instruction Level
					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_TAX_BENEFIT(l_format_name,
                                                                   		   l_iby_pmt_rec.payment_id,
		 						   		   to_number(l_iby_docs_rec.calling_app_doc_unique_ref2),
							   	   		   l_docErrorTab,
							  	   		   l_docErrorRec,
							           		   l_valid,
							           		   l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                            p_instruction_id,
                                                                                            l_iby_pmt_rec.payment_id,
		   									    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     								         	            l_docErrorTab,
							                 		    l_docErrorRec,
							                 		    l_valid,
							                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

--IBY_PAYMENT_FORMAT_VAL_PVT.TAS_VALIDATION Is Directly Called From IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS


				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor



			IBY_PAYMENT_FORMAT_VAL_PVT.MAX_TREASURY_SYMBOLS(l_format_name,
									p_instruction_id,
									l_docErrorTab,
									l_docErrorRec,
									l_valid,
									l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

		IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
					                   p_instruction_id,
						           l_docErrorTab,
						           l_docErrorRec,
						           l_valid,
					    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVSPNCR;-- End of Procedure FVSPNCR
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVSPPPD

SPS PPD Vendor Payment Format

*/

        PROCEDURE FVSPPPD
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id,
				payment_reason_code
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
			       payment_instruction_id,
                               payee_party_id,
                               payee_le_registration_num,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code,
                               external_bank_account_id,
                               ext_bank_account_name,
                               ext_bank_account_number,
                               ext_branch_number,
                               ext_bank_account_type
			FROM iby_payments_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
				FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');


			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;

		l_org_id		NUMBER;

		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVSPPPD';
		x_result:=g_SUCCESS;
		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                         -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_ID

                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;

				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT_2 at Payment Level
				IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT_2(l_format_name,
									     l_iby_pmt_rec.payment_instruction_id,
								             l_iby_pmt_rec.payment_amount,
     								             l_docErrorTab,
						                   	     l_docErrorRec,
						                   	     l_valid,
						                             l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;

					-- validate internal bank account parameters
 					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
			     							        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					-- validate external bank account parameters
                                        -- validate external bank account id
                                        IBY_PAYMENT_FORMAT_VAL_PVT.EXTERNAL_BANK_ACCOUNT_ID(l_format_name,
											    l_iby_pmt_rec.external_bank_account_id,
		     								            l_docErrorTab,
									                    l_docErrorRec,
									                    l_valid,
									                    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.ACCOUNT_TYPE(l_format_name,
										l_iby_pmt_rec.ext_bank_account_type,
                                                                                l_iby_pmt_rec.ext_bank_account_name,
                                                                                TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     								                l_docErrorTab,
							                        l_docErrorRec,
							                  	l_valid,
							                        l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.DEPOSITER_ACC_NUM(l_format_name,
				    						     l_iby_pmt_rec.ext_bank_account_number,
     								                     l_docErrorTab,
							                             l_docErrorRec,
							                             l_valid,
							                             l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.RTN_NUMBER(l_format_name,
			   						      l_iby_pmt_rec.ext_branch_number,
     								              l_docErrorTab,
							                      l_docErrorRec,
							                      l_valid,
							                      l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_ALONE_OPTION(l_format_name,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                    p_instruction_id,
                                                                                    l_iby_pmt_rec.payment_id,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

--IBY_PAYMENT_FORMAT_VAL_PVT.TAS_VALIDATION Is Directly Called From IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS



					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
									l_iby_pmt_rec.payee_le_registration_num,
                                                                        l_iby_pmt_rec.payee_party_id,
								        l_docErrorTab,
							                l_docErrorRec,
							                l_valid,
							                l_error_message);
						IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
							x_result:=1;
						ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
							x_result:=1;
							RETURN;
						END IF;


				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.MAX_TREASURY_SYMBOLS(l_format_name,
									p_instruction_id,
									l_docErrorTab,
									l_docErrorRec,
									l_valid,
									l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

		IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
					                   p_instruction_id,
						           l_docErrorTab,
						           l_docErrorRec,
						           l_valid,
					    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			IBY_PAYMENT_FORMAT_VAL_PVT.MANDATORY_PPD_PPDP_REASON_CODE(l_format_name,
						 				  l_pay_instr_rec.payment_reason_code,
							           		  l_docErrorTab,
							                  	  l_docErrorRec,
							           		  l_valid,
						    	            		  l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVSPPPD;-- End of Procedure FVSPPPD
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVSPPPDP

SPS PPDP Vendor Payment Format

*/

        PROCEDURE FVSPPPDP
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	)IS

		l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
		l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
		l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

			-- Pick Up The Required Data From Instructions (IBY_PAY_INSTRUCTIONS_ALL) using payemnt_instruction_id
		CURSOR pay_instr_data_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT  org_id,
				payment_reason_code
				  FROM  iby_pay_instructions_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payments (IBY_PAYMENTS_ALL) using payment_instruction_id
		CURSOR iby_pmt_csr(p_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE) IS
			SELECT payment_id,
			       payment_instruction_id,
                               payee_party_id,
                               payee_le_registration_num,
			       payment_amount,
                               internal_bank_account_id,
                               int_bank_account_name,
                               int_bank_acct_agency_loc_code,
                               external_bank_account_id,
                               ext_bank_account_name,
                               ext_bank_account_number,
                               ext_branch_number,
                               ext_bank_account_type
			FROM iby_payments_all
			WHERE
				payment_instruction_id = p_instruction_id;

			-- Pick Up Required Data From Payable Documents (IBY_DOCS_PAYABLE_ALL) Using Payment Id From Payment Data
		CURSOR iby_docs_csr(p_pmt_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE) IS
			SELECT calling_app_doc_unique_ref2
				FROM iby_docs_payable_all
			WHERE
				payment_id = p_pmt_id
				AND
				calling_app_id=200
				AND
				UPPER(payment_function) IN ('PAYABLES_DISB','EMPLOYEE_EXP');


			-- Declaring Record Types Of Various Cursors
		l_pay_instr_rec		pay_instr_data_csr%ROWTYPE;
		l_iby_pmt_rec		iby_pmt_csr%ROWTYPE;
		l_iby_docs_rec		iby_docs_csr%ROWTYPE;
		l_org_id		NUMBER;

		l_format_name   VARCHAR2(50);
		l_error_message	VARCHAR2(1000);
		l_valid			NUMBER;

	BEGIN
		l_format_name := 'FVSPPPDP';
		x_result:=g_SUCCESS;

		-- Initializing the payment record
		IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     	        l_docErrorRec.validation_set_code := p_validation_set_code;
	        l_docErrorRec.transaction_id := p_instruction_id;
	        l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
	        l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

		OPEN pay_instr_data_csr(p_instruction_id); 		-- Opening Instruction Data Cursor
		FETCH pay_instr_data_csr INTO l_pay_instr_rec;          -- Getting Instruction Data

		IF pay_instr_data_csr%FOUND THEN 		 	-- If Row Found Then Only Process Further

                         -- delete from FV_TP_TS_AMT_DATA to refresh data
                        delete from FV_TP_TS_AMT_DATA where payment_instruction_id = p_instruction_id;

			l_org_id:=l_pay_instr_rec.org_id;-- Extracting Org_ID

                        -- Do IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE at Payment Instruction Level
                        -- Moved this to instruction level (Bug 5526640)
			IBY_PAYMENT_FORMAT_VAL_PVT.SUPPLIER_TYPE(l_format_name,
								 p_instruction_id,
     								 l_docErrorTab,
							         l_docErrorRec,
							         l_valid,
							         l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			OPEN iby_pmt_csr(p_instruction_id);	-- Opening Payment Data Cursor
			LOOP	-- Perform Validation For Each Of record in IBY_PAYMENTS_ALL
				FETCH iby_pmt_csr INTO l_iby_pmt_rec;	-- Getting Payment Data
				EXIT WHEN iby_pmt_csr%NOTFOUND;

				-- Do IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT_2 at Payment Level
				IBY_PAYMENT_FORMAT_VAL_PVT.MAX_PAYMENT_AMT_2(l_format_name,
									   l_iby_pmt_rec.payment_instruction_id,
								           l_iby_pmt_rec.payment_amount,
     								           l_docErrorTab,
							                   l_docErrorRec,
							                   l_valid,
							                   l_error_message);
				IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
					x_result:=1;
				ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
					x_result:=1;
					RETURN;
				END IF;


				OPEN iby_docs_csr(l_iby_pmt_rec.payment_id);	-- Opening Payable Documents Data
				LOOP	-- Perform Validation For Each Of record in IBY_DOCS_PAYABLE_ALL
					FETCH iby_docs_csr INTO l_iby_docs_rec;	-- Getting Payable Documents Data
					EXIT WHEN iby_docs_csr%NOTFOUND;

					-- validate internal bank account parameters
					IBY_PAYMENT_FORMAT_VAL_PVT.AGENCY_LOCATION_CODE(l_format_name,
											l_iby_pmt_rec.int_bank_acct_agency_loc_code,
                                                                                        l_iby_pmt_rec.int_bank_account_name,
			     							        l_docErrorTab,
									                l_docErrorRec,
									                l_valid,
									                l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					-- validate external bank account parameters
                                        -- validate external bank account id
                                        IBY_PAYMENT_FORMAT_VAL_PVT.EXTERNAL_BANK_ACCOUNT_ID(l_format_name,
											    l_iby_pmt_rec.external_bank_account_id,
		     								            l_docErrorTab,
									                    l_docErrorRec,
									                    l_valid,
									                    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
							x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
							x_result:=1;
							RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.ACCOUNT_TYPE(l_format_name,
										l_iby_pmt_rec.ext_bank_account_type,
                                                                                l_iby_pmt_rec.ext_bank_account_name,
                                                                                TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     								                l_docErrorTab,
							                        l_docErrorRec,
							                  	l_valid,
							                 	l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.DEPOSITER_ACC_NUM(l_format_name,
				    						     l_iby_pmt_rec.ext_bank_account_number,
     								                     l_docErrorTab,
							                             l_docErrorRec,
							                             l_valid,
							                             l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

					IBY_PAYMENT_FORMAT_VAL_PVT.RTN_NUMBER(l_format_name,
		   							      l_iby_pmt_rec.ext_branch_number,
     								              l_docErrorTab,
							                      l_docErrorRec,
							                      l_valid,
							                      l_error_message);

					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.PAY_ALONE_OPTION(l_format_name,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;


					IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS(l_format_name,
                                                                                    p_instruction_id,
                                                                                    l_iby_pmt_rec.payment_id,
		   								    TO_NUMBER(l_iby_docs_rec.calling_app_doc_unique_ref2),
     							         	            l_docErrorTab,
						                 		    l_docErrorRec,
						                 		    l_valid,
						                 		    l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;

--IBY_PAYMENT_FORMAT_VAL_PVT.TAS_VALIDATION Is Directly Called From IBY_PAYMENT_FORMAT_VAL_PVT.TREASURY_SYMBOLS_PROCESS



					IBY_PAYMENT_FORMAT_VAL_PVT.PAYEE_SSN(l_format_name,
									l_iby_pmt_rec.payee_le_registration_num,
                                                                        l_iby_pmt_rec.payee_party_id,
								        l_docErrorTab,
							                l_docErrorRec,
							                l_valid,
							                l_error_message);
					IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
						x_result:=1;
					ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
						x_result:=1;
						RETURN;
					END IF;



				END LOOP;-- End Of Documents Cursor Loop
				CLOSE iby_docs_csr;-- Closing Payable Documents Cursor

			END LOOP;-- End Of Payments Cursor Loop
			CLOSE iby_pmt_csr; -- Closing Payments Cursor

			IBY_PAYMENT_FORMAT_VAL_PVT.MAX_TREASURY_SYMBOLS(l_format_name,
									p_instruction_id,
									l_docErrorTab,
									l_docErrorRec,
									l_valid,
									l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

		IBY_PAYMENT_FORMAT_VAL_PVT.SCHEDULE_NUMBER(l_format_name,
					                   p_instruction_id,
						           l_docErrorTab,
						           l_docErrorRec,
						           l_valid,
					    	           l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;

			IBY_PAYMENT_FORMAT_VAL_PVT.MANDATORY_PPD_PPDP_REASON_CODE(l_format_name,
						 				  l_pay_instr_rec.payment_reason_code,
							           		  l_docErrorTab,
							                  	  l_docErrorRec,
							           		  l_valid,
						    	            		  l_error_message);

			IF(l_valid=g_FAILURE) THEN	-- If Validation Error Comes Set x_result and Catch Other Validation Erros
				x_result:=1;
			ELSIF(l_valid=g_EXCEPTION) THEN	-- If Some Unexpected Error Comes Set x_result and Return.
				x_result:=1;
				RETURN;
			END IF;


		END IF; -- End of IF pay_instr_data_csr%FOUND
		CLOSE pay_instr_data_csr; -- Closing Instruction Data Cursor

                IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);

	EXCEPTION
	WHEN OTHERS THEN
	 x_result := 1;
	l_docErrorRec.transaction_error_id := null;
        l_docErrorRec.error_code := 'UNEXPECTED_ERROR';
	l_docErrorRec.error_message := SQLERRM;
	IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        iby_payment_format_val_pvt.log_error_messages(FND_LOG.LEVEL_STATEMENT, l_format_name, SQLERRM);
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);


	END FVSPPPDP;-- End of Procedure FVSPPPDP





----------------------------------------------------------------------------------------------------------

-- Initialising Global Variables
	BEGIN
		g_FAILURE	:= -1; -- Corresponds To g_ERROR OF IBY_PAYMENT_FORMAT_VAL_PVT Package.
		g_EXCEPTION	:= -2; -- Corresponds To g_FAILURE OF IBY_PAYMENT_FORMAT_VAL_PVT Package.
		g_SUCCESS	:=  0;

----------------------------------------------------------------------------------------------------------

END IBY_PAYMENT_FORMAT_VAL_PUB ;

/
