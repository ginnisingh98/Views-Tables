--------------------------------------------------------
--  DDL for Package Body CN_NOTIFY_INVOICES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_NOTIFY_INVOICES" AS
-- $Header: cnnoinvb.pls 120.8 2006/02/01 10:17:28 rramakri noship $




-- Procedure Name
--   notify_invoices
-- Purpose
--   This procedure collects data for invoices for cn_not_trx
-- History
--   01-05-96	A. Erickson	Created


  PROCEDURE notify (
	x_start_period	cn_periods.period_id%TYPE,
	x_end_period	cn_periods.period_id%TYPE,
	debug_pipe	VARCHAR2 DEFAULT NULL,
	debug_level	NUMBER	 DEFAULT NULL,
    x_org_id NUMBER   ) IS

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
    cn_debug.print_msg('>>notify_invoices', 1);
    -- who.set_program_name('notify_invoices');


    cn_message_pkg.debug('notify_invoices>>');
    fnd_file.put_line(fnd_file.Log, 'notify_invoices>>');


    x_proc_audit_id := NULL;	-- Will get a value in the call below
    cn_process_audits_pkg.insert_row(x_rowid, x_proc_audit_id, NULL,  'NOT', 'Notification run', NULL, NULL, NULL, NULL, NULL, SYSDATE, NULL, x_org_id);

    cn_periods_api.set_dates(x_start_period, x_end_period, x_org_id,
			     x_start_date, x_end_date);

    cn_message_pkg.debug('notify_invoices: Is collecting invoices for CN_NOT_TRX from period '||x_start_date ||' to period '||x_end_date ||'.');
    fnd_file.put_line(fnd_file.Log, 'notify_invoices: Is collecting invoices for CN_NOT_TRX from period '||x_start_date ||' to period '||x_end_date ||'.');


    -- Check if the profile option CN_COLLECT_ON_ACCT_CREDITS is turned on
    -- or not
    OPEN batch_size;
    FETCH batch_size INTO l_sys_batch_size;
    CLOSE batch_size;

    IF CN_SYSTEM_PARAMETERS.value('CN_COLLECT_ON_ACCT_CREDITS', x_org_id) = 'Y' THEN

    -- We removed the constraint of "prev_cust_trx_id IS NOT NULL" for
    -- collecting On Account Credits purpose.  So basicly, we do not
    -- distinguish among INV, CM or On Account Credits here.  We will be
    -- collecting all of these three when we collect invoices.

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
	   rctlgd.gl_date,				--AE 02-22-96
	   x_proc_audit_id,
	   'N',
	   rct.rowid,
	   rct.customer_trx_id,
	   'AR',
	   cn_global.inv_event_id,
	   x_org_id
      FROM ra_customer_trx rct,
	   ra_cust_trx_types rctt,
	   ra_cust_trx_line_gl_dist rctlgd,
	   cn_repositories cr
      WHERE rct.customer_trx_id = rctlgd.customer_trx_id
        AND rct.cust_trx_type_id = rctt.cust_trx_type_id
        AND rct.complete_flag = 'Y'
        AND rctt.type in ('INV', 'CM','DM')
        AND rctlgd.account_class = 'REC'
        AND rctlgd.latest_rec_flag = 'Y'
        AND rctlgd.gl_date BETWEEN x_start_date AND x_end_date
        AND rctlgd.posting_control_id <> -3		--AE 02-22-96
        AND rct.set_of_books_id = cr.set_of_books_id	--AE 02-21-96
        AND cr.repository_id = 100			--AE 02-21-96
        AND rct.org_id = x_org_id
        AND rctt.org_id = rct.org_id
        AND rctlgd.org_id = rctt.org_id
        AND cr.org_id = rctlgd.org_id
        AND NOT EXISTS (
	       SELECT 1
		 FROM cn_not_trx
		WHERE source_trx_id = rct.customer_trx_id
		  AND event_id= cn_global.inv_event_id
          AND org_id = x_org_id) ;

    ELSE   -- CN_COLLECT_ON_ACCT_CREDITS = 'N'

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
	   rctlgd.gl_date,				--AE 02-22-96
	   x_proc_audit_id,
	   'N',
	   rct.rowid,
	   rct.customer_trx_id,
	   'AR',
	   cn_global.inv_event_id,
	   x_org_id
      FROM ra_customer_trx rct,
	   ra_cust_trx_types rctt,
	   ra_cust_trx_line_gl_dist rctlgd,
	   cn_repositories cr
      WHERE rct.customer_trx_id = rctlgd.customer_trx_id
        AND rct.cust_trx_type_id = rctt.cust_trx_type_id
        AND rct.complete_flag = 'Y'
--AE    AND rctt.type in ('INV', 'CM','DM')
        AND ((rctt.type IN ('INV','DM')) OR                      --AE 07-29-96
	    (rctt.type = 'CM' AND                       --AE
	     rct.previous_customer_trx_id IS NOT NULL)) --AE
        AND rctlgd.account_class = 'REC'
        AND rctlgd.latest_rec_flag = 'Y'
        AND rctlgd.gl_date BETWEEN x_start_date AND x_end_date
        AND rctlgd.posting_control_id <> -3		--AE 02-22-96
        AND rct.set_of_books_id = cr.set_of_books_id	--AE 02-21-96
        AND cr.repository_id = 100			--AE 02-21-96
        AND rct.org_id = x_org_id
        AND rctt.org_id = rct.org_id
        AND rctlgd.org_id = rctt.org_id
        AND cr.org_id = rctlgd.org_id
        AND NOT EXISTS (
	       SELECT 1
		 FROM cn_not_trx
		WHERE source_trx_id = rct.customer_trx_id
		  AND event_id= cn_global.inv_event_id
          AND org_id = x_org_id) ;

    END IF;

    x_trx_count := SQL%ROWCOUNT;

    cn_process_audits_pkg.update_row(x_proc_audit_id, NULL, SYSDATE, 0,
      'Finished notification run: Notified ' || x_trx_count || ' invoices.');



    IF  ( x_trx_count = 0 ) THEN

      cn_message_pkg.debug('notify_invoices: No rows inserted into CN_NOT_TRX. Possible reason: Transactions have not been posted to GL or they have already been collected.');
      fnd_file.put_line(fnd_file.Log, 'notify_invoices: No rows inserted into CN_NOT_TRX. Possible reason: Transactions have not been posted to GL or they have already been collected.');

    END IF;

    COMMIT;

    cn_message_pkg.debug('notify_invoices: Finished notification run: Notified ' || x_trx_count || ' invoices.');
    fnd_file.put_line(fnd_file.Log, 'notify_invoices: Finished notification run: Notified ' || x_trx_count || ' invoices.');

    cn_debug.print_msg('<<notify_invoices', 1);
    cn_message_pkg.debug('notify_invoices<<');
    fnd_file.put_line(fnd_file.Log, 'notify_invoices<<');

--    cn_message_pkg.end_batch (x_proc_audit_id);


  EXCEPTION
    WHEN OTHERS THEN ROLLBACK;

    cn_message_pkg.debug('notify_invoices: in exception handler');
    fnd_file.put_line(fnd_file.Log, 'notify_invoices: in exception handler');

    cn_message_pkg.debug(SQLCODE||' '||SQLERRM);
    fnd_file.put_line(fnd_file.Log, SQLCODE||' '||SQLERRM);

    cn_debug.print_msg('notify_invoices: in exception handler', 1);
    cn_process_audits_pkg.update_row(X_proc_audit_id, NULL, SYSDATE, SQLCODE,
      SQLERRM);
--    cn_message_pkg.end_batch (x_proc_audit_id);

    app_exception.raise_exception;

  END notify;

END cn_notify_invoices;




/
