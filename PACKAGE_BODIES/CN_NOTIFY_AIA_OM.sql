--------------------------------------------------------
--  DDL for Package Body CN_NOTIFY_AIA_OM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_NOTIFY_AIA_OM" AS
-- $Header: CNNOAIAOMB.pls 120.0.12010000.6 2009/08/20 04:43:27 rajukum noship $




-- Procedure Name
--   notify_aia_om
-- Purpose
--   This procedure collects data for aia order records for cn_not_trx
-- History
--


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
    cn_debug.print_msg('>>notify_aia_om', 1);
    -- who.set_program_name('notify_aia_om');

     cn_message_pkg.debug('notify_aia_om>>');
     fnd_file.put_line(fnd_file.Log, 'notify_aia_om>>');
   --
     x_proc_audit_id := NULL;	-- Will get a value in the call below
     cn_process_audits_pkg.insert_row(x_rowid,
                                       x_proc_audit_id,
                                       NULL,
                                      'NOT',
                                      'Notification run',
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      SYSDATE,
                                      NULL,
                                      x_org_id);
    --
    cn_periods_api.set_dates(x_start_period,
                             x_end_period,
                             x_org_id,
                             x_start_date,
                             x_end_date);
    --
    cn_message_pkg.debug('notify_aia_om: Is collecting aia order records for CN_NOT_TRX from period '||x_start_date ||' to period '||x_end_date ||'.');
    fnd_file.put_line(fnd_file.Log, 'notify_aia_om: Is collecting aia order records for CN_NOT_TRX from period '||x_start_date ||' to period '||x_end_date ||'.');
    --
    cn_message_pkg.debug('notify_aia_om: Is collecting aia order records for notification batch id '|| x_proc_audit_id ||'.');
    fnd_file.put_line(fnd_file.Log, 'notify_aia_om: Is collecting aia order records for notification batch id '|| x_proc_audit_id ||'.');


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
        cnot.t_batch_id,
        cnot.t_processed_date,
        cnot.t_notified_date,
        cnot.t_notification_run_id,
        cnot.t_collected_flag,
        cnot.t_event_id,
        cnot.t_source_trx_id,   --*** Header.Primary_Key
        cnot.t_source_trx_line_id,     --*** Line Table Key Column
        cnot.t_source_doc_type,     --*** Source Type
        cnot.t_org_id
    FROM
     (SELECT
        distinct
        x_proc_audit_id t_batch_id,
        processed_date t_processed_date,
        SYSDATE t_notified_date,
        x_proc_audit_id t_notification_run_id,
        'N' t_collected_flag,
        -1030 t_event_id,
        null t_source_trx_id,   --*** Header.Primary_Key
        cco10145.trans_seq_id t_source_trx_line_id,     --*** Line Table Key Column
        'AIA_OM' t_source_doc_type,     --*** Source Type
        x_org_id t_org_id
      FROM
        cn_aia_order_capture cco10145
      WHERE     --*** Header.Primary_Key = Line.Foreign_Key
        1 = 1
        AND TRUNC(processed_date) BETWEEN x_start_date AND x_end_date
        AND preprocess_flag  = FND_API.G_FALSE
        AND   org_id = x_org_id
          AND NOT EXISTS (
            SELECT 1
            FROM  cn_not_trx
            WHERE source_trx_line_id = cco10145.trans_seq_id      --*** Line.Primary_Key
            AND   event_id = -1030
            AND   org_id = x_org_id)
            ) cnot;
      --END Notification Insert Block


    x_trx_count := SQL%ROWCOUNT;

    cn_process_audits_pkg.update_row(x_proc_audit_id,
                                      NULL,
                                      SYSDATE,
                                      0,
                                      'Finished notification run: Notified ' || x_trx_count || ' aia order records.');

    IF  ( x_trx_count = 0 ) THEN

      cn_message_pkg.debug('notify_aia_om: No rows inserted into CN_NOT_TRX. Possible reason: Transactions have not been posted to AIA Interface table and processed date is null.');
      fnd_file.put_line(fnd_file.Log, 'notify_aia_om: No rows inserted into CN_NOT_TRX. Possible reason: Transactions have not been posted to AIA Interface table and processed date is null.');


    END IF;

    COMMIT;

    cn_message_pkg.debug('notify_aia_om: Finished notification run: Notified ' || x_trx_count || ' aia order records.');
    fnd_file.put_line(fnd_file.Log, 'notify_aia_om: Finished notification run: Notified ' || x_trx_count || ' aia order records.');

    cn_debug.print_msg('<<notify_aia_om', 1);

    cn_message_pkg.debug('notify_aia_om<<');
    fnd_file.put_line(fnd_file.Log, 'notify_aia_om<<');

    cn_message_pkg.end_batch (x_proc_audit_id);

  EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
    cn_debug.print_msg('notify_aia_om: in exception handler', 1);
    cn_process_audits_pkg.update_row(X_proc_audit_id, NULL, SYSDATE, SQLCODE,
      SQLERRM);

    cn_message_pkg.debug('notify_aia_om: in exception handler');
    fnd_file.put_line(fnd_file.Log, 'notify_aia_om: in exception handler');

    cn_message_pkg.debug(SQLCODE||' '||SQLERRM);
    fnd_file.put_line(fnd_file.Log, SQLCODE||' '||SQLERRM);

    cn_message_pkg.end_batch (x_proc_audit_id);

    app_exception.raise_exception;

  END notify;

-- Procedure Name
--   notify_failed_trx
-- Purpose
--   This procedure collects failed records  for aia order  for cn_not_trx
-- History
--

  PROCEDURE notify_failed_trx (
	p_batch_id	cn_not_trx_all.batch_id%TYPE,
	x_start_period	cn_periods.period_id%TYPE,
	x_end_period	cn_periods.period_id%TYPE,
	debug_pipe	VARCHAR2 DEFAULT NULL,
	debug_level	NUMBER	 DEFAULT 1,
    x_org_id NUMBER ) IS

    CURSOR get_failed_trx_cr(p_start_date Date, p_end_date Date) IS
      SELECT distinct original_order_number, ln_num
      FROM CN_AIA_ORDER_CAPTURE
      WHERE org_id  = x_org_id and trans_seq_id in
      ( SELECT source_trx_line_id
        FROM cn_not_trx_all
        WHERE batch_id = p_batch_id and org_id = x_org_id and source_trx_line_id not in
        (SELECT source_trx_line_id
         FROM cn_comm_lines_api_all
         WHERE process_batch_id =  p_batch_id and org_id = x_org_id)
      ) AND TRUNC(processed_date) BETWEEN p_start_date AND p_end_date;

    type fl_trx_Ord_tbl_type IS TABLE OF get_failed_trx_cr % rowtype INDEX BY pls_integer;
    fl_trx_Ord_tbl fl_trx_Ord_tbl_type;

    x_trx_count 	NUMBER;
    x_start_date	DATE;
    x_end_date		DATE;


  BEGIN
    IF (debug_pipe IS NOT NULL) THEN
      cn_debug.init_pipe(debug_pipe, debug_level);
    END IF;
    cn_debug.print_msg('>>notify_aia_om : notify_failed_trx', 1);

   cn_message_pkg.debug('notify_aia_om : notify_failed_trx>>');
   fnd_file.put_line(fnd_file.Log, 'notify_aia_om : notify_failed_trx>>');

    --
   cn_periods_api.set_dates(x_start_period,
                           x_end_period,
                           x_org_id,
                           x_start_date,
                           x_end_date);

    --
    cn_message_pkg.debug('notify_aia_om: Is collecting failed aia orders records which exist in CN_NOT_TRX but not collected
             in CN_COMM_LINES_API from period '||x_start_date ||' to period '||x_end_date ||'.');
    fnd_file.put_line(fnd_file.Log, 'notify_aia_om: Is collecting failed aia orders records which exist in CN_NOT_TRX but not collected
             in CN_COMM_LINES_API from period '||x_start_date ||' to period '||x_end_date ||'.');

    --

    cn_message_pkg.debug('notify_aia_om: Is collecting failed aia order records for notification batch id '|| p_batch_id ||'.');
    fnd_file.put_line(fnd_file.Log, 'notify_aia_om: Is collecting failed aia order records for notification batch id '|| p_batch_id ||'.');


    OPEN get_failed_trx_cr(x_start_date,x_end_date);

    LOOP
      FETCH get_failed_trx_cr bulk collect
      INTO fl_trx_Ord_tbl limit 1000;

      FOR indx IN 1 .. fl_trx_Ord_tbl.COUNT
      LOOP

           cn_message_pkg.debug('notify_aia_om : notify_failed_trx : Original_order_number : ' || fl_trx_Ord_tbl(indx).original_order_number ||
                                ' : Line Number : ' || fl_trx_Ord_tbl(indx).ln_num);
          fnd_file.put_line(fnd_file.Log, 'notify_aia_om :notify_failed_trx : Original_order_number : ' || fl_trx_Ord_tbl(indx).original_order_number ||
                            ' : Line Number : ' || fl_trx_Ord_tbl(indx).ln_num);

      END LOOP;

      EXIT
      WHEN get_failed_trx_cr % NOTFOUND;
    END LOOP;

    CLOSE get_failed_trx_cr;


   cn_message_pkg.debug('notify_aia_om : notify_failed_trx<<');
   fnd_file.put_line(fnd_file.Log, 'notify_aia_om : notify_failed_trx<<');


  EXCEPTION
    WHEN OTHERS THEN
    cn_debug.print_msg('notify_aia_om: notify_failed_trx : in exception handler', 1);

    cn_message_pkg.debug('notify_aia_om: notify_failed_trx : in exception handler');
    fnd_file.put_line(fnd_file.Log, 'notify_aia_om: notify_failed_trx : in exception handler');

    cn_message_pkg.debug(SQLCODE||' '||SQLERRM);
    fnd_file.put_line(fnd_file.Log, SQLCODE||' '||SQLERRM);

    app_exception.raise_exception;

  END notify_failed_trx;

END cn_notify_aia_om;



/
