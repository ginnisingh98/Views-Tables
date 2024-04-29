--------------------------------------------------------
--  DDL for Package Body JAI_AR_CR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_CR_PKG" AS
/* $Header: jai_ar_cr_pkg.plb 120.1.12000000.1 2007/07/24 06:55:21 rallamse noship $ */
	PROCEDURE process_cm_dm(p_event		IN	VARCHAR2,
				p_new		IN	ar_cash_receipts_all%ROWTYPE,
				p_old		IN	ar_cash_receipts_all%ROWTYPE,
				p_process_flag	OUT NOCOPY	VARCHAR2,
				p_process_message OUT NOCOPY	VARCHAR2)
	IS
		lv_process_flag		VARCHAR2(2);
		lv_process_message 	VARCHAR2(1000);

	BEGIN

		p_process_flag := jai_constants.successful;
		jai_ar_tcs_rep_pkg.process_transactions(
				p_acra						=> p_new,
				p_event 					=> p_event,
				p_process_flag		=> lv_process_flag,
				p_process_message	=> lv_process_message);

		IF NVL(lv_process_flag,'XX') <> jai_constants.successful THEN
			raise_application_error(-20011,	lv_process_message);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_process_flag := jai_constants.unexpected_error;
			p_process_message := SUBSTR(SQLERRM,1,100);
	END process_cm_dm;

END;

/
