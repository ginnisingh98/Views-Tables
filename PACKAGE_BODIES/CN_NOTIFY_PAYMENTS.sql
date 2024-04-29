--------------------------------------------------------
--  DDL for Package Body CN_NOTIFY_PAYMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_NOTIFY_PAYMENTS" AS
-- $Header: cnnopmtb.pls 120.7 2006/02/01 02:52:55 rramakri noship $




-- Procedure Name
--   notify_payments
-- Purpose
--   This procedure collects data for payments for cn_not_trx
-- History
--   01-05-96	A. Erickson	Created


  PROCEDURE notify (
	x_start_period	cn_periods.period_id%TYPE,
	x_end_period	cn_periods.period_id%TYPE,
	debug_pipe	VARCHAR2 DEFAULT NULL,
	debug_level	NUMBER	 DEFAULT NULL,
    x_org_id NUMBER ) IS

    x_trx_count 	NUMBER;
    x_proc_audit_id	NUMBER;
    x_start_date	DATE;
    x_end_date		DATE;
    x_rowid		ROWID;
    l_sys_batch_size NUMBER;

    CURSOR batch_size IS SELECT system_batch_size FROM cn_repositories WHERE org_id = x_org_id;


  BEGIN
    IF (debug_pipe IS NOT NULL) THEN
      cn_debug.init_pipe(debug_pipe, debug_level);
    END IF;
    cn_debug.print_msg('>>notify_payments', 1);
    -- who.set_program_name('notify_payments');

  cn_message_pkg.debug('notify_payments>>');
  fnd_file.put_line(fnd_file.Log, 'notify_payments>>');

    x_proc_audit_id := NULL;	-- Will get a value in the call below
    cn_process_audits_pkg.insert_row(x_rowid, x_proc_audit_id, NULL,
      'NOT', 'Notification run', NULL, NULL, NULL, NULL, NULL, SYSDATE, NULL, x_org_id);

    cn_periods_api.set_dates(x_start_period, x_end_period, x_org_id,
			     x_start_date, x_end_date);

 cn_message_pkg.debug('notify_payments: Is collecting payments for CN_NOT_TRX from period '||x_start_date ||' to period '||x_end_date ||'.');
 fnd_file.put_line(fnd_file.Log, 'notify_payments: Is collecting payments for CN_NOT_TRX from period '||x_start_date ||' to period '||x_end_date ||'.');

    OPEN batch_size;
    FETCH batch_size INTO l_sys_batch_size;
    CLOSE batch_size;


    INSERT INTO cn_not_trx (
	   not_trx_id,
	   batch_id,
	   notified_date,
	   processed_date,
	   notification_run_id,
	   collected_flag,
	   row_id,
	   source_trx_id,
	   source_doc_type,
	   event_id,
       org_id)
    SELECT
	   cn_not_trx_s.NEXTVAL,
	   FLOOR(cn_not_trx_s.CURRVAL/l_sys_batch_size),
	   SYSDATE,
	   ara.gl_date, 				--AE 02-22-96
	   x_proc_audit_id,
	   'N',
	   ara.rowid,
	   ara.receivable_application_id,
	   'AR',
	   cn_global.pmt_event_id,
	   x_org_id
      FROM ar_receivable_applications  ara,
	   cn_repositories  cr
     WHERE ara.application_type = 'CASH'
       AND ara.status = 'APP'
       AND ara.gl_date BETWEEN x_start_date AND x_end_date
       AND ara.posting_control_id <> -3		--AE 02-22-96
       AND ara.set_of_books_id = cr.set_of_books_id	--AE 02-21-96
       AND cr.repository_id = 100			--AE 02-21-96
       AND ara.org_id = x_org_id
       AND cr.org_id = ara.org_id
       AND NOT EXISTS (
	       SELECT 1
		 FROM cn_not_trx
		WHERE source_trx_id = ara.receivable_application_id
		  AND event_id= cn_global.pmt_event_id
          AND org_id = x_org_id) ;


    x_trx_count := SQL%ROWCOUNT;

    cn_process_audits_pkg.update_row(x_proc_audit_id, NULL, SYSDATE, 0,
      'Finished notification run: Notified ' || x_trx_count || ' payments.');

  IF  ( x_trx_count = 0 ) THEN

      cn_message_pkg.debug('notify_payments: No rows inserted into CN_NOT_TRX. Possible reason: Transactions have not been posted to GL and gl_date is null.');
      fnd_file.put_line(fnd_file.Log, 'notify_payments: No rows inserted into CN_NOT_TRX. Possible reason: Transactions have not been posted to GL and gl_date is null.');


    END IF;

    COMMIT;

    cn_message_pkg.debug('notify_payments: Finished notification run: Notified ' || x_trx_count || ' payments.');
    fnd_file.put_line(fnd_file.Log, 'notify_payments: Finished notification run: Notified ' || x_trx_count || ' payments.');

    cn_debug.print_msg('<<notify_payments', 1);

    cn_message_pkg.debug('notify_payments<<');
    fnd_file.put_line(fnd_file.Log, 'notify_payments<<');

    cn_message_pkg.end_batch (x_proc_audit_id);

  EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
    cn_debug.print_msg('notify_payments: in exception handler', 1);
    cn_process_audits_pkg.update_row(X_proc_audit_id, NULL, SYSDATE, SQLCODE,
      SQLERRM);

    cn_message_pkg.debug('notify_payments: in exception handler');
    fnd_file.put_line(fnd_file.Log, 'notify_payments: in exception handler');

    cn_message_pkg.debug(SQLCODE||' '||SQLERRM);
    fnd_file.put_line(fnd_file.Log, SQLCODE||' '||SQLERRM);

    cn_message_pkg.end_batch (x_proc_audit_id);

    app_exception.raise_exception;

  END notify;

END cn_notify_payments;



/
