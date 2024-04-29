--------------------------------------------------------
--  DDL for Package Body CN_NOTIFY_CLAWBACKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_NOTIFY_CLAWBACKS" AS
-- $Header: cnnocbkb.pls 120.9 2006/02/16 21:23:21 rramakri noship $



-- Procedure Name
--   notify_clawbacks
-- Purpose
--   This procedure collects data for clawbacks for cn_not_trx
-- History
--   01-05-96	A. Erickson	Created


  PROCEDURE notify (
	x_start_period	cn_periods.period_id%TYPE,
	x_end_period	cn_periods.period_id%TYPE,
	debug_pipe	VARCHAR2 DEFAULT NULL,
	debug_level	NUMBER	 DEFAULT NULL,
    x_org_id NUMBER) IS

    x_trx_count 	NUMBER;
    x_proc_audit_id	NUMBER;
    x_start_date	DATE;
    x_end_date		DATE;
    x_clb_grace_period  NUMBER;
    x_start_due_date	DATE;
    x_end_due_date	DATE;
    x_rowid		ROWID;
    l_sys_batch_size NUMBER;

    CURSOR batch_size IS SELECT system_batch_size FROM cn_repositories WHERE org_id = x_org_id;

  BEGIN
    IF (debug_pipe IS NOT NULL) THEN
      cn_debug.init_pipe(debug_pipe, debug_level);
    END IF;
    cn_debug.print_msg('>>notify_clawbacks', 1);
    -- who.set_program_name('notify_clawbacks');

    cn_message_pkg.debug('notify_clawbacks>>');
    fnd_file.put_line(fnd_file.Log, '>>notify_clawbacks');

    x_proc_audit_id := NULL;	-- Will get a value in the call below
    cn_process_audits_pkg.insert_row(x_rowid, x_proc_audit_id, NULL,
      'NOT', 'Notification run', NULL, NULL, NULL, NULL, NULL, SYSDATE, NULL, x_org_id);

    cn_periods_api.set_dates(x_start_period, x_end_period, x_org_id,
			     x_start_date, x_end_date);

    -- Set end_due_date for clawbacks.	  02-26-96
    -- This is the end_date minus the clawback grace period.

    --bug 513940 -J.C
    SELECT  r.clawback_grace_days
    INTO    x_clb_grace_period
    FROM	 cn_periods	  p
  		,cn_repositories  r
    	        ,gl_sets_of_books s
    WHERE	r.current_period_id  = p.period_id(+)
    AND	 	r.application_id     = 283
    AND		r.set_of_books_id    = s.set_of_books_id
    AND     r.org_id = x_org_id
    AND     r.org_id=p.org_id(+);

    x_start_due_date := x_start_date - nvl(x_clb_grace_period, cn_global.cbk_grace_period);
    x_end_due_date   := x_end_date - nvl(x_clb_grace_period,cn_global.cbk_grace_period);


    -- Insert notification records for clawbacks for those payment schedules
    -- that went past due between the start date of the start period and the
    -- end date of the end period.
    cn_debug.print_msg('notify_clawbacks: Collecting from ar_payment_schedules', 1);
    fnd_file.put_line(fnd_file.Log, 'notify_clawbacks: Collecting from ar_payment_schedules');

    -- Note: Here we are looking for payment schedules against transactions
    -- that would have initially been picked up by the invoice notification
    -- code= cnnoinvb.pls.

    cn_message_pkg.debug('notify_clawbacks: Is collecting clawbacks for CN_NOT_TRX from period '||x_start_date ||' to period '||x_end_date ||'.');
    fnd_file.put_line(fnd_file.Log, 'notify_clawbacks: Is collecting clawbacks for CN_NOT_TRX from period '||x_start_date ||' to period '||x_end_date ||'.');

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
	   x_end_date,
	   x_proc_audit_id,
	   'N',
	   aps.rowid,
	   aps.payment_schedule_id,
	   'AR',
	   cn_global.cbk_event_id,
	   x_org_id
      FROM ar_payment_schedules aps,
	   ra_customer_trx rct,
	   ra_cust_trx_types rctt,
	   ra_cust_trx_line_gl_dist rctlgd,
	   cn_repositories cr
     WHERE aps.due_date BETWEEN x_start_due_date AND x_end_due_date
       AND aps.amount_line_items_remaining > 0
--AE   AND aps.class in ('INV', 'CM')                   --AE 02-06-96
       AND aps.customer_trx_id = rct.customer_trx_id	--AE 02-07-96
       AND rct.customer_trx_id = rctlgd.customer_trx_id
       AND rct.cust_trx_type_id = rctt.cust_trx_type_id
       AND rct.complete_flag = 'Y'
       AND rctt.type in ('INV', 'CM')
       AND rctlgd.account_class = 'REC'
       AND rctlgd.latest_rec_flag = 'Y'
       AND rctlgd.posting_control_id <> -3
       AND rct.set_of_books_id = cr.set_of_books_id	--AE 02-21-96
       AND cr.repository_id = 100			--AE 02-21-96
       AND aps.org_id = x_org_id
       AND rct.org_id = aps.org_id
       AND rctt.org_id = rct.org_id
       AND rctlgd.org_id = rctt.org_id
       AND cr.org_id = rctlgd.org_id
       AND NOT EXISTS (
	       SELECT 1
		 FROM cn_not_trx
		WHERE source_trx_id = aps.payment_schedule_id
		  AND event_id= cn_global.cbk_event_id
          AND org_id = x_org_id) ;


    x_trx_count := SQL%ROWCOUNT;

    cn_process_audits_pkg.update_row(x_proc_audit_id, NULL, SYSDATE, 0,
      'Finished notification run: Notified ' || x_trx_count || ' clawbacks.');

    IF  ( x_trx_count = 0 ) THEN

      cn_message_pkg.debug('notify_clawbacks: No rows inserted into CN_NOT_TRX. Possible reason: Transactions have not been posted to GL or they have already been collected.');
      fnd_file.put_line(fnd_file.Log, 'notify_clawbacks: No rows inserted into CN_NOT_TRX. Possible reason: Transactions have not been posted to GL or they have already been collected.');

    END IF;

    COMMIT;

    cn_message_pkg.debug('notify_clawbacks: Finished notification run: Notified ' || x_trx_count || ' clawbacks.');
    fnd_file.put_line(fnd_file.Log, 'notify_clawbacks: Finished notification run: Notified ' || x_trx_count || ' clawbacks.');

    cn_debug.print_msg('<<notify_clawbacks', 1);

    cn_message_pkg.debug('notify_clawbacks<<');
    fnd_file.put_line(fnd_file.Log, 'notify_clawbacks<<');

    cn_message_pkg.end_batch (x_proc_audit_id);

  EXCEPTION
    WHEN OTHERS THEN ROLLBACK;

    cn_message_pkg.debug('notify_clawbacks: in exception handler');
    fnd_file.put_line(fnd_file.Log, 'notify_clawbacks: in exception handler');

    cn_message_pkg.debug(SQLCODE||' '||SQLERRM);
    fnd_file.put_line(fnd_file.Log, SQLCODE||' '||SQLERRM);

    cn_debug.print_msg('notify_clawbacks: in exception handler', 1);
    cn_process_audits_pkg.update_row(X_proc_audit_id, NULL, SYSDATE, SQLCODE,
      SQLERRM);
    cn_message_pkg.end_batch (x_proc_audit_id);

    app_exception.raise_exception;

  END notify;

END cn_notify_clawbacks;




/
