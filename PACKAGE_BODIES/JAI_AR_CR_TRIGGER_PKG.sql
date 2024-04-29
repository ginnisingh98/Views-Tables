--------------------------------------------------------
--  DDL for Package Body JAI_AR_CR_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_CR_TRIGGER_PKG" AS
/* $Header: jai_arcr_trg_pkg.plb 120.1.12000000.1 2007/07/24 06:55:35 rallamse noship $ */

	PROCEDURE ARI_T1 	(pr_old 	IN	t_rec%type ,
				 pr_new 	IN	t_rec%type ,
				 pv_action 	IN	VARCHAR2 ,
				 pv_return_code OUT NOCOPY VARCHAR2 ,
				 pv_return_message OUT NOCOPY VARCHAR2 )
	IS

	CURSOR C_CURRENT_SID
	IS
	SELECT	JAI_AR_CASH_RECEIPTS_S1.CURRVAL
	FROM DUAL;

	CURSOR C_CHECK_TMP_DATA(PN_TEMP_SEQUENCE_ID	NUMBER)
	IS
	SELECT	LOC_CASH_RECEIPT_ID,
		RECEIPT_AMOUNT,
		CUSTOMER_ID,
		CONFIRM_FLAG,
		CURRENCY_CODE,
		EXCHANGE_RATE
	FROM 	JAI_AR_CASH_RECEIPTS_ALL
	WHERE 	TEMP_SEQUENCE_ID = PN_TEMP_SEQUENCE_ID
	AND 	CASH_RECEIPT_ID IS NULL;

	r_check_tmp_data	c_check_tmp_data%ROWTYPE;
	ln_session_id		NUMBER;
	lv_process_flag		VARCHAR2(2);
	lv_process_message 	VARCHAR2(1000);

	BEGIN
		pv_return_code := jai_constants.successful;

		BEGIN
			OPEN c_current_sid;
			FETCH c_current_sid INTO ln_session_id;
			CLOSE c_current_sid;
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;

		OPEN c_check_tmp_data(ln_session_id);
		FETCH c_check_tmp_data INTO r_check_tmp_data;
		CLOSE c_check_tmp_data;

		IF r_check_tmp_data.loc_cash_receipt_id IS NOT NULL THEN

			IF r_check_tmp_data.receipt_amount <> pr_new.amount OR
					r_check_tmp_data.customer_id <> pr_new.pay_from_customer OR
					r_check_tmp_data.currency_code <> pr_new.currency_code OR
					r_check_tmp_data.exchange_rate <> pr_new.exchange_rate
			THEN
				--raise_application_error(-20010,'Either of Receipt Amount or customer details or currency details are changed. Delete the record using Zoom function');
				pv_return_code 		:= jai_constants.expected_error;
				pv_return_message := 'Either of Receipt Amount or customer details or currency details are changed. Delete the record using Tools Menu';
				return;
			END IF;

			UPDATE	jai_ar_cash_receipts_all
			SET 		cash_receipt_id = pr_new.cash_receipt_id,
							temp_sequence_id = NULL
			WHERE 	loc_cash_receipt_id = r_check_tmp_data.loc_cash_receipt_id;

			UPDATE	jai_cmn_document_taxes
			SET 		source_doc_id = pr_new.cash_receipt_id,
							source_doc_line_id = NULL
			WHERE 	source_doc_line_id = r_check_tmp_data.loc_cash_receipt_id
			AND 		source_table_name = 'JAI_AR_CASH_RECEIPTS_ALL';

			IF r_check_tmp_data.confirm_flag = 'Y' THEN

				jai_ar_cr_pkg.process_cm_dm(
												p_event							=>	jai_constants.ar_cash_tax_confirmed,
												p_new								=>	pr_new,
												p_old								=> 	pr_old,
												p_process_flag			=> 	lv_process_flag,
												p_process_message 	=> 	lv_process_message);

				IF NVL(lv_process_flag,'XX') <> jai_constants.successful THEN
					--raise_application_error(-20011,	lv_process_message);
					pv_return_code 		:= jai_constants.expected_error;
					pv_return_message := lv_process_message;
					return;
				END IF;


			END IF;

		ELSE
			--raise_application_error(-20010,'First process the taxes using Zoom function and then save the form');
			pv_return_code 		:= jai_constants.expected_error;
			pv_return_message := 'First process the taxes using Tools Menu and then save the form';
			return;
		END IF;
	EXCEPTION
	   WHEN OTHERS THEN
	     pv_return_code     :=  jai_constants.unexpected_error;
	     pv_return_message  := 'Encountered an error in jai_ar_cash_receipts_trg_pkg.ARI_T1 '  || substr(sqlerrm,1,1900);

	END ARI_T1;


	PROCEDURE ARU_T1 (pr_old		IN	t_rec%type ,
			  pr_new 		IN	t_rec%type ,
			  pv_action 		IN	VARCHAR2 ,
			  pv_return_code 	OUT NOCOPY VARCHAR2 ,
			  pv_return_message 	OUT NOCOPY VARCHAR2 )
	IS

	CURSOR c_ar_cash_receipts(cp_cash_receipt_id	NUMBER)
	IS
	SELECT	confirm_flag
	FROM 		jai_ar_cash_receipts_all
	WHERE 	cash_receipt_id = cp_cash_receipt_id;

	r_ar_cash_receipts	c_ar_cash_receipts%ROWTYPE;
	lv_process_flag			VARCHAR2(2);
	lv_process_message 	VARCHAR2(1000);

	BEGIN
		OPEN c_ar_cash_receipts(pr_old.cash_receipt_id);
		FETCH c_ar_cash_receipts INTO r_ar_cash_receipts;
		CLOSE c_ar_cash_receipts;

		IF pr_old.amount <> pr_new.amount OR
			 pr_old.pay_from_customer <> pr_new.pay_from_customer OR
			 pr_old.reversal_date IS NULL AND pr_new.reversal_date is NOT NULL THEN

			IF NVL(r_ar_cash_receipts.confirm_flag,'N') IN ('N','I') THEN

				DELETE 	jai_cmn_document_taxes
				WHERE 	source_table_name = 'JAI_AR_CASH_RECEIPTS_ALL'
				AND 		source_doc_id = pr_old.cash_receipt_id;

				DELETE 	jai_ar_cash_receipts_all
				WHERE 	cash_receipt_id = pr_old.cash_receipt_id;
			ELSE
				IF pr_old.reversal_date IS NULL AND pr_new.reversal_date is NOT NULL THEN
					jai_ar_cr_pkg.process_cm_dm(
										p_event		=>	jai_constants.trx_type_rct_rvs,
										p_new		=>	pr_new,
										p_old		=> 	pr_old,
										p_process_flag	=> 	lv_process_flag,
										p_process_message => 	lv_process_message);

					IF NVL(lv_process_flag,'XX') <> jai_constants.successful THEN
						--raise_application_error(-20011,	lv_process_message);
						pv_return_code 		:= jai_constants.expected_error;
						pv_return_message := lv_process_message;
						return;
					END IF;
				ELSE
					--raise_application_error(-20011, 'Either receipt amount or customer details are changed. You can''t change these details. Reverse the receipt');
					pv_return_code 		:= jai_constants.expected_error;
					pv_return_message := 'Either receipt amount or customer details are changed. You can''t change these details. Reverse the receipt';
					return;
				END IF;
			END IF;

		ELSE
			NULL;
		END IF;
	EXCEPTION
	   WHEN OTHERS THEN
	     pv_return_code     :=  jai_constants.unexpected_error;
	     pv_return_message  := 'Encountered an error in jai_ar_cash_receipts_trg_pkg.ARU_T1 '  || substr(sqlerrm,1,1900);
	END ARU_T1;

	PROCEDURE ARD_T1 			 (pr_old 							IN	t_rec%type ,
													pr_new 							IN	t_rec%type ,
													pv_action 					IN	VARCHAR2 ,
													pv_return_code 			OUT NOCOPY VARCHAR2 ,
													pv_return_message 	OUT NOCOPY VARCHAR2 )
	IS

	CURSOR c_ar_cash_receipts(cp_cash_receipt_id	NUMBER)
	IS
	SELECT	confirm_flag
	FROM 		jai_ar_cash_receipts_all
	WHERE 	cash_receipt_id = cp_cash_receipt_id;

	r_ar_cash_receipts	c_ar_cash_receipts%ROWTYPE;
	lv_process_flag			VARCHAR2(2);
	lv_process_message 	VARCHAR2(1000);

	BEGIN
		OPEN c_ar_cash_receipts(pr_old.cash_receipt_id);
		FETCH c_ar_cash_receipts INTO r_ar_cash_receipts;
		CLOSE c_ar_cash_receipts;

		IF NVL(r_ar_cash_receipts.confirm_flag,'N') IN ('N','I') THEN
			DELETE 	jai_cmn_document_taxes
			WHERE 	source_table_name = 'JAI_AR_CASH_RECEIPTS_ALL'
			AND 		source_doc_id = pr_old.cash_receipt_id;

			DELETE 	jai_ar_cash_receipts_all
			WHERE 	cash_receipt_id = pr_old.cash_receipt_id;
		ELSE
			--raise_application_error(-20011, 'You can''t delete this receipt. Reverse the receipt');
			pv_return_code 		:= jai_constants.expected_error;
			pv_return_message := 'You can''t delete this receipt. Reverse the receipt';
			return;
		END IF;
	EXCEPTION
	   WHEN OTHERS THEN
	     pv_return_code     :=  jai_constants.unexpected_error;
	     pv_return_message  := 'Encountered an error in jai_ar_cash_receipts_trg_pkg.ARD_T1 '  || substr(sqlerrm,1,1900);
	END ARD_T1;

END;

/
