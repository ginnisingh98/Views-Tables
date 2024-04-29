--------------------------------------------------------
--  DDL for Package Body GLF02220_BJE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GLF02220_BJE_PKG" AS
/* $Header: glfbdejb.pls 120.5 2005/07/29 16:57:39 djogg ship $ */

  --
  -- PUBLIC PROCEDURES
  --

  FUNCTION bje_trans_exists( X_status_number	IN NUMBER,
			     X_ledger_id	IN NUMBER,
                             X_period_year	IN NUMBER,
                             X_start_period_num IN NUMBER,
                             X_end_period_num	IN NUMBER ) RETURN BOOLEAN IS
    CURSOR bte IS
      SELECT
	     'Budget Journals Transactions exist'
      FROM
	     DUAL
      WHERE
	EXISTS
	(SELECT
	        'Budget Journals Transactions exist'
    	 FROM
	        GL_BUDGET_RANGE_INTERIM BI,
	        GL_PERIOD_STATUSES PS
    	 WHERE
                BI.ledger_id = X_ledger_id
    	 AND 	BI.status_number = X_status_number
    	 AND 	PS.application_id = 101
    	 AND 	PS.ledger_id = X_ledger_id
    	 AND 	PS.period_year = X_period_year
    	 AND 	PS.period_num BETWEEN X_start_period_num
	          	      AND     X_end_period_num
    	 AND    PS.period_num =
	  decode(mod(PS.period_num - 1, 13) + 1,
	    1, decode(nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0),
		 0, -1, PS.period_num),
	    2, decode(nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0),
		 0, -1, PS.period_num),
	    3, decode(nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0),
		 0, -1, PS.period_num),
	    4, decode(nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0),
		 0, -1, PS.period_num),
	    5, decode(nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0),
		 0, -1, PS.period_num),
	    6, decode(nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0),
		 0, -1, PS.period_num),
	    7, decode(nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0),
		 0, -1, PS.period_num),
	    8, decode(nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0),
		 0, -1, PS.period_num),
	    9, decode(nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0),
		 0, -1, PS.period_num),
	   10, decode(nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0),
		 0, -1, PS.period_num),
	   11, decode(nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0),
		 0, -1, PS.period_num),
	   12, decode(nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0),
		 0, -1, PS.period_num),
	   13, decode(nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0),
		 0, -1, PS.period_num)));

    dummy VARCHAR2(100);

  BEGIN

    OPEN bte;
    FETCH bte INTO dummy;

    IF bte%FOUND THEN
      CLOSE bte;
      return(TRUE);
    ELSE
      CLOSE bte;
      return(FALSE);
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'glf02220_bje_pkg.bje_trans_exists');
      RAISE;

  END bje_trans_exists;


  PROCEDURE insert_bc_packet( X_packet_id		IN OUT NOCOPY NUMBER,
			      X_status_number		IN NUMBER,
			      X_ledger_id		IN NUMBER,
			      X_je_category_name	IN VARCHAR2,
			      X_fc_mode			IN VARCHAR2,
			      X_je_batch_name		IN VARCHAR2,
                              X_period_year		IN NUMBER,
                              X_start_period_num 	IN NUMBER,
                              X_end_period_num		IN NUMBER,
                              X_session_id              IN NUMBER,
                              X_serial_id               IN NUMBER) IS
  BEGIN

    -- Get packet id for this check/reserve process
    X_packet_id := gl_bc_packets_pkg.get_unique_id;

    INSERT INTO GL_BC_PACKETS
       (packet_id,
	ledger_id,
	je_source_name,
	je_category_name,
	code_combination_id,
	actual_flag,
	period_name,
	period_year,
	period_num,
	quarter_num,
	currency_code,
	status_code,
	last_update_date,
	last_updated_by,
	budget_version_id,
	entered_dr,
	entered_cr,
	accounted_dr,
	accounted_cr,
	je_batch_name,
	je_line_description,
        application_id,
        session_id,
        serial_id)
    SELECT
	X_packet_id,
	X_ledger_id,
	'Budget Journal',
	X_je_category_name,
	BI.code_combination_id,
	'B',
	PS.period_name,
	PS.period_year,
	PS.period_num,
	PS.quarter_num,
	BI.currency_code,
	decode(X_fc_mode, 'R', 'P', 'C'),
	sysdate,
	BI.last_updated_by,
	BI.budget_version_id,
	decode(mod(PS.period_num - 1, 13) + 1,
	  1, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0),
	       'N0', -1 * (nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
	       NULL),
	  2, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0),
	       'N0', -1 * (nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
	       NULL),
	  3, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0),
	       'N0', -1 * (nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
	       NULL),
	  4, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0),
	       'N0', -1 * (nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
	       NULL),
	  5, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0),
	       'N0', -1 * (nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
	       NULL),
	  6, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0),
	       'N0', -1 * (nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
	       NULL),
	  7, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0),
	       'N0', -1 * (nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
	       NULL),
	  8, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0),
	       'N0', -1 * (nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
	       NULL),
	  9, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0),
	       'N0', -1 * (nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
	       NULL),
	 10, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0),
	       'N0', -1 * (nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
	       NULL),
	 11, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0),
	       'N0', -1 * (nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
	       NULL),
	 12, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0),
	       'N0', -1 * (nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
	       NULL),
	 13, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0),
	       'N0', -1 * (nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
	       NULL)),
	decode(mod(PS.period_num - 1, 13) + 1,
	  1, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0),
	       'Y0', -1 * (nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
	       NULL),
	  2, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0),
	       'Y0', -1 * (nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
	       NULL),
	  3, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0),
	       'Y0', -1 * (nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
	       NULL),
	  4, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0),
	       'Y0', -1 * (nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
	       NULL),
	  5, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0),
	       'Y0', -1 * (nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
	       NULL),
	  6, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0),
	       'Y0', -1 * (nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
	       NULL),
	  7, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0),
	       'Y0', -1 * (nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
	       NULL),
	  8, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0),
	       'Y0', -1 * (nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
	       NULL),
	  9, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0),
	       'Y0', -1 * (nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
	       NULL),
	 10, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0),
	       'Y0', -1 * (nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
	       NULL),
	 11, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0),
	       'Y0', -1 * (nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
	       NULL),
	 12, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0),
	       'Y0', -1 * (nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
	       NULL),
	 13, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0),
	       'Y0', -1 * (nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
	       NULL)),
	decode(mod(PS.period_num - 1, 13) + 1,
	  1, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0),
	       'N0', -1 * (nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
	       NULL),
	  2, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0),
	       'N0', -1 * (nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
	       NULL),
	  3, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0),
	       'N0', -1 * (nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
	       NULL),
	  4, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0),
	       'N0', -1 * (nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
	       NULL),
	  5, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0),
	       'N0', -1 * (nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
	       NULL),
	  6, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0),
	       'N0', -1 * (nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
	       NULL),
	  7, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0),
	       'N0', -1 * (nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
	       NULL),
	  8, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0),
	       'N0', -1 * (nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
	       NULL),
	  9, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0),
	       'N0', -1 * (nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
	       NULL),
	 10, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0),
	       'N0', -1 * (nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
	       NULL),
	 11, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0),
	       'N0', -1 * (nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
	       NULL),
	 12, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0),
	       'N0', -1 * (nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
	       NULL),
	 13, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0),
	       'N0', -1 * (nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
	       NULL)),
	decode(mod(PS.period_num - 1, 13) + 1,
	  1, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0),
	       'Y0', -1 * (nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
	       NULL),
	  2, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0),
	       'Y0', -1 * (nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
	       NULL),
	  3, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0),
	       'Y0', -1 * (nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
	       NULL),
	  4, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0),
	       'Y0', -1 * (nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
	       NULL),
	  5, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0),
	       'Y0', -1 * (nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
	       NULL),
	  6, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0),
	       'Y0', -1 * (nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
	       NULL),
	  7, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0),
	       'Y0', -1 * (nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
	       NULL),
	  8, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0),
	       'Y0', -1 * (nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
	       NULL),
	  9, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0),
	       'Y0', -1 * (nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
	       NULL),
	 10, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0),
	       'Y0', -1 * (nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
	       NULL),
	 11, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0),
	       'Y0', -1 * (nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
	       NULL),
	 12, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0),
	       'Y0', -1 * (nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
	       NULL),
	 13, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0),
	       'Y0', -1 * (nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
	       NULL)),
	X_je_batch_name,
	decode( mod(PS.period_num - 1, 13) + 1,
	  1,  BI.je_line_description1,
	  2,  BI.je_line_description2,
	  3,  BI.je_line_description3,
	  4,  BI.je_line_description4,
	  5,  BI.je_line_description5,
	  6,  BI.je_line_description6,
	  7,  BI.je_line_description7,
	  8,  BI.je_line_description8,
	  9,  BI.je_line_description9,
	  10, BI.je_line_description10,
	  11, BI.je_line_description11,
	  12, BI.je_line_description12,
	  13, BI.je_line_description13 ),
        101,
        X_Session_Id,
        X_Serial_Id
    FROM
	GL_BUDGET_RANGE_INTERIM BI,
	GL_PERIOD_STATUSES PS
    WHERE
        BI.ledger_id = X_ledger_id
    AND BI.status_number = X_status_number
    AND PS.application_id = 101
    AND PS.ledger_id = X_ledger_id
    AND PS.period_year = X_period_year
    AND PS.period_num BETWEEN X_start_period_num
		      AND     X_end_period_num
    AND PS.period_num =
	  decode(mod(PS.period_num - 1, 13) + 1,
	    1, decode(nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0),
		 0, -1, PS.period_num),
	    2, decode(nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0),
		 0, -1, PS.period_num),
	    3, decode(nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0),
		 0, -1, PS.period_num),
	    4, decode(nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0),
		 0, -1, PS.period_num),
	    5, decode(nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0),
		 0, -1, PS.period_num),
	    6, decode(nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0),
		 0, -1, PS.period_num),
	    7, decode(nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0),
		 0, -1, PS.period_num),
	    8, decode(nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0),
		 0, -1, PS.period_num),
	    9, decode(nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0),
		 0, -1, PS.period_num),
	   10, decode(nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0),
		 0, -1, PS.period_num),
	   11, decode(nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0),
		 0, -1, PS.period_num),
	   12, decode(nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0),
		 0, -1, PS.period_num),
	   13, decode(nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0),
		 0, -1, PS.period_num));

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'glf02220_bje_pkg.insert_bc_packet');
      RAISE;

  END insert_bc_packet;


  PROCEDURE insert_interface_rows( X_group_id			IN OUT NOCOPY NUMBER,
			      	   X_status_number		IN NUMBER,
			     	   X_ledger_id			IN NUMBER,
			      	   X_user_je_category_name	IN VARCHAR2,
			      	   X_je_batch_name		IN VARCHAR2,
                              	   X_period_year		IN NUMBER,
                              	   X_start_period_num 		IN NUMBER,
                              	   X_end_period_num		IN NUMBER) IS
    X_je_source_name	    	VARCHAR2(25) := 'Budget Journal';
    X_user_je_source_name   	VARCHAR2(25);
    X_effective_date_rule_code	VARCHAR2(1);
    X_override_edits_flag	VARCHAR2(1);
    X_Journal_Approval_Flag     VARCHAR2(1);
  BEGIN

    -- Get group_id for this Budget Journals process
    X_group_id := gl_interface_control_pkg.get_unique_id;

    -- Get translation for je_source_name 'Budget Journal'
    gl_je_sources_pkg.select_columns( X_je_source_name,
				      X_user_je_source_name,
				      X_effective_date_rule_code,
				      X_override_edits_flag,
                                      x_journal_approval_flag);

    INSERT INTO GL_INTERFACE
       (status,
	ledger_id,
	code_combination_id,
	user_je_source_name,
	user_je_category_name,
	accounting_date,
	currency_code,
	date_created,
	created_by,
	actual_flag,
	budget_version_id,
	period_name,
	group_id,
	entered_dr,
	entered_cr,
	reference1,
	reference10,
	stat_amount)
    SELECT
	'NEW',
	X_ledger_id,
	BI.code_combination_id,
	X_user_je_source_name,
	X_user_je_category_name,
	PS.start_date,
	BI.currency_code,
	sysdate,
	BI.last_updated_by,
	'B',
	BI.budget_version_id,
	PS.period_name,
	X_group_id,
	decode(mod(PS.period_num - 1, 13) + 1,
	  1, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0),
	       'N0', -1 * (nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
	       NULL),
	  2, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0),
	       'N0', -1 * (nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
	       NULL),
	  3, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0),
	       'N0', -1 * (nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
	       NULL),
	  4, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0),
	       'N0', -1 * (nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
	       NULL),
	  5, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0),
	       'N0', -1 * (nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
	       NULL),
	  6, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0),
	       'N0', -1 * (nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
	       NULL),
	  7, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0),
	       'N0', -1 * (nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
	       NULL),
	  8, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0),
	       'N0', -1 * (nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
	       NULL),
	  9, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0),
	       'N0', -1 * (nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
	       NULL),
	 10, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0),
	       'N0', -1 * (nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
	       NULL),
	 11, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0),
	       'N0', -1 * (nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
	       NULL),
	 12, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0),
	       'N0', -1 * (nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
	       NULL),
	 13, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'Y1', nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0),
	       'N0', -1 * (nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
	       NULL)),
	decode(mod(PS.period_num - 1, 13) + 1,
	  1, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0),
	       'Y0', -1 * (nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
	       NULL),
	  2, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0),
	       'Y0', -1 * (nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
	       NULL),
	  3, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0),
	       'Y0', -1 * (nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
	       NULL),
	  4, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0),
	       'Y0', -1 * (nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
	       NULL),
	  5, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0),
	       'Y0', -1 * (nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
	       NULL),
	  6, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0),
	       'Y0', -1 * (nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
	       NULL),
	  7, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0),
	       'Y0', -1 * (nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
	       NULL),
	  8, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0),
	       'Y0', -1 * (nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
	       NULL),
	  9, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0),
	       'Y0', -1 * (nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
	       NULL),
	 10, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0),
	       'Y0', -1 * (nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
	       NULL),
	 11, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0),
	       'Y0', -1 * (nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
	       NULL),
	 12, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0),
	       'Y0', -1 * (nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
	       NULL),
	 13, decode(BI.dr_flag ||
	       decode(sign(nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
		 decode(substr(BI.je_drcr_sign_reference, mod(PS.period_num-1,13)+1, 1),
		   1, 1, -1), '1', 0, NULL, '0'),
	       'N1', nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0),
	       'Y0', -1 * (nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
	       NULL)),
	X_je_batch_name,
	decode( mod(PS.period_num - 1, 13) + 1,
	  1,  BI.je_line_description1,
	  2,  BI.je_line_description2,
	  3,  BI.je_line_description3,
	  4,  BI.je_line_description4,
	  5,  BI.je_line_description5,
	  6,  BI.je_line_description6,
	  7,  BI.je_line_description7,
	  8,  BI.je_line_description8,
	  9,  BI.je_line_description9,
	  10, BI.je_line_description10,
	  11, BI.je_line_description11,
	  12, BI.je_line_description12,
	  13, BI.je_line_description13 ),
	decode( mod(PS.period_num - 1, 13) + 1,
	  1,  BI.stat_amount1,
	  2,  BI.stat_amount2,
	  3,  BI.stat_amount3,
	  4,  BI.stat_amount4,
	  5,  BI.stat_amount5,
	  6,  BI.stat_amount6,
	  7,  BI.stat_amount7,
	  8,  BI.stat_amount8,
	  9,  BI.stat_amount9,
	  10, BI.stat_amount10,
	  11, BI.stat_amount11,
	  12, BI.stat_amount12,
	  13, BI.stat_amount13 )
    FROM
	GL_BUDGET_RANGE_INTERIM BI,
	GL_PERIOD_STATUSES PS
    WHERE
        BI.ledger_id = X_ledger_id
    AND BI.status_number = X_status_number
    AND PS.application_id = 101
    AND PS.ledger_id = X_ledger_id
    AND PS.period_year = X_period_year
    AND PS.period_num BETWEEN X_start_period_num
		      AND     X_end_period_num
    AND PS.period_num =
	  decode(mod(PS.period_num - 1, 13) + 1,
	    1, decode(nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0),
		 0, -1, PS.period_num),
	    2, decode(nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0),
		 0, -1, PS.period_num),
	    3, decode(nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0),
		 0, -1, PS.period_num),
	    4, decode(nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0),
		 0, -1, PS.period_num),
	    5, decode(nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0),
		 0, -1, PS.period_num),
	    6, decode(nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0),
		 0, -1, PS.period_num),
	    7, decode(nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0),
		 0, -1, PS.period_num),
	    8, decode(nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0),
		 0, -1, PS.period_num),
	    9, decode(nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0),
		 0, -1, PS.period_num),
	   10, decode(nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0),
		 0, -1, PS.period_num),
	   11, decode(nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0),
		 0, -1, PS.period_num),
	   12, decode(nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0),
		 0, -1, PS.period_num),
	   13, decode(nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0),
		 0, -1, PS.period_num));

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'glf02220_bje_pkg.insert_interface_rows');
      RAISE;

  END insert_interface_rows;


  PROCEDURE delete_range_interim_records( X_status_number  IN NUMBER ) IS
  BEGIN

    DELETE FROM GL_BUDGET_RANGE_INTERIM
    WHERE
	    status_number = X_status_number;

  END delete_range_interim_records;


END glf02220_bje_pkg;

/
