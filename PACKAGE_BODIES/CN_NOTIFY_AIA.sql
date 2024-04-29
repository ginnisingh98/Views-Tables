--------------------------------------------------------
--  DDL for Package Body CN_NOTIFY_AIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_NOTIFY_AIA" AS
-- $Header: CNNOAIAB.pls 120.0.12010000.3 2009/09/03 07:06:45 rajukum noship $




-- Procedure Name
--   notify_aia
-- Purpose
--   This procedure collects data for aia records for cn_not_trx
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
    cn_debug.print_msg('>>notify_aia', 1);
    -- who.set_program_name('notify_aia');

  cn_message_pkg.debug('notify_aia>>');
  fnd_file.put_line(fnd_file.Log, 'notify_aia>>');

    x_proc_audit_id := NULL;	-- Will get a value in the call below
    cn_process_audits_pkg.insert_row(x_rowid, x_proc_audit_id, NULL,
      'NOT', 'Notification run', NULL, NULL, NULL, NULL, NULL, SYSDATE, NULL, x_org_id);

    cn_periods_api.set_dates(x_start_period, x_end_period, x_org_id,
			     x_start_date, x_end_date);

 cn_message_pkg.debug('notify_aia: Is collecting aia records for CN_NOT_TRX from period '||x_start_date ||' to period '||x_end_date ||'.');
 fnd_file.put_line(fnd_file.Log, 'notify_aia: Is collecting aia records for CN_NOT_TRX from period '||x_start_date ||' to period '||x_end_date ||'.');

    OPEN batch_size;
    FETCH batch_size INTO l_sys_batch_size;
    CLOSE batch_size;


    INSERT INTO  cn_not_trx (
        not_trx_id,
        batch_id,
        processed_date,
        notified_date,
        notification_run_id,
        collected_flag,
        event_id,
        source_trx_id,
        source_trx_line_id,
        source_doc_type,
        org_id)
      SELECT
        cn_not_trx_s.NEXTVAL,
        x_proc_audit_id,
        cco10143.processed_date,
        SYSDATE,
        x_proc_audit_id,
        'N',
        -1020,
        NULL,
        cco10143.trans_seq_id,     --*** Line Table Key Column
        'AIA',     --*** Source Type
        x_org_id
      FROM
        cn_collection_aia cco10143
      WHERE     --*** Header.Primary_Key = Line.Foreign_Key
        1 = 1
        AND TRUNC(processed_date) BETWEEN x_start_date AND x_end_date
          AND NOT EXISTS (
            SELECT 1
            FROM  cn_not_trx
            WHERE source_trx_line_id = cco10143.trans_seq_id     --*** Line.Primary_Key
            AND   event_id = -1020
            AND   org_id = x_org_id);
      --END Notification Insert Block


    x_trx_count := SQL%ROWCOUNT;

    cn_process_audits_pkg.update_row(x_proc_audit_id, NULL, SYSDATE, 0,
      'Finished notification run: Notified ' || x_trx_count || ' aia records.');

  IF  ( x_trx_count = 0 ) THEN

      cn_message_pkg.debug('notify_aia: No rows inserted into CN_NOT_TRX. Possible reason: Transactions have not been posted to AIA Interface table and processed date is null.');
      fnd_file.put_line(fnd_file.Log, 'notify_aia: No rows inserted into CN_NOT_TRX. Possible reason: Transactions have not been posted to AIA Interface table and processed date is null.');


    END IF;

    COMMIT;

    cn_message_pkg.debug('notify_aia: Finished notification run: Notified ' || x_trx_count || ' aia records.');
    fnd_file.put_line(fnd_file.Log, 'notify_aia: Finished notification run: Notified ' || x_trx_count || ' aia records.');

    cn_debug.print_msg('<<notify_aia', 1);

    cn_message_pkg.debug('notify_aia<<');
    fnd_file.put_line(fnd_file.Log, 'notify_aia<<');

    cn_message_pkg.end_batch (x_proc_audit_id);

  EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
    cn_debug.print_msg('notify_aia: in exception handler', 1);
    cn_process_audits_pkg.update_row(X_proc_audit_id, NULL, SYSDATE, SQLCODE,
      SQLERRM);

    cn_message_pkg.debug('notify_aia: in exception handler');
    fnd_file.put_line(fnd_file.Log, 'notify_aia: in exception handler');

    cn_message_pkg.debug(SQLCODE||' '||SQLERRM);
    fnd_file.put_line(fnd_file.Log, SQLCODE||' '||SQLERRM);

    cn_message_pkg.end_batch (x_proc_audit_id);

    app_exception.raise_exception;

  END notify;

END cn_notify_aia;



/
