--------------------------------------------------------
--  DDL for Package Body INV_TXN_PURGE_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TXN_PURGE_MAIN" AS
  /* $Header: INVTPGMB.pls 120.0.12000000.2 2007/02/21 23:06:18 yssingh ship $ */
  PROCEDURE txn_purge_main(x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NOCOPY NUMBER, p_orgid IN NUMBER, p_purge_date IN DATE) IS
    l_debug                   NUMBER            := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_max_workers             NUMBER            := NVL(fnd_profile.VALUE('INV_MAX_TXN_PG_PROCESSES'), 20);
    l_num_of_periods          NUMBER;
    l_min_mmt_date            DATE;
    l_min_period_id           NUMBER;
    l_min_date                DATE;
    l_max_date                DATE;
    l_min_log_date            DATE;
    l_period_per_worker       NUMBER;
    l_num_of_workers          NUMBER;
    l_num_of_periods_fetched  NUMBER;
    l_num_of_workers_launched NUMBER;
    l_purge_req_id            NUMBER;
    l_req_id                  NUMBER;
    l_result                  BOOLEAN;
    l_count                   NUMBER;
    l_sleep_time              NUMBER            := 5;

    v_min_dt VARCHAR2(20); -- For bug 4055865.
    v_max_dt VARCHAR2(20); -- For bug 4055865.


    TYPE l_reqstatus_table IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

    l_reqstatus_tbl_type      l_reqstatus_table;

    TYPE l_status_code_table IS TABLE OF VARCHAR2(10)
      INDEX BY BINARY_INTEGER;

    l_status_code_tbl_type    l_status_code_table;
    l_completion_status       VARCHAR2(1);

    success                   BOOLEAN;
    submission_error_except   EXCEPTION;

    TYPE min_max_dates IS RECORD(
      min_date  DATE
    , max_date  DATE
    , period_id NUMBER
    );

    CURSOR c_oap IS
      SELECT   period_start_date
             , schedule_close_date
             , acct_period_id
          FROM org_acct_periods
         WHERE period_start_date <= p_purge_date
           AND open_flag = 'N'
           AND organization_id = p_orgid
           AND acct_period_id >= l_min_period_id
      ORDER BY acct_period_id;

    period_rec_type           min_max_dates;
  BEGIN
    IF (l_debug = 1) THEN
          inv_log_util.TRACE('OrgId = ' || p_orgid || ', Purge Date= ' || p_purge_date, 'PURGE_MAIN', 9);
    END IF;

    IF l_max_workers > 20 THEN
      l_max_workers  := 20;
    END IF;

    IF (l_debug = 1) THEN
          inv_log_util.TRACE('Max # of txn purge processes = ' || l_max_workers, 'PURGE_MAIN', 9);
    END IF;

    SELECT MIN(transaction_date)
      INTO l_min_mmt_date
      FROM mtl_material_transactions
     WHERE organization_id = p_orgid
       AND transaction_date <= p_purge_date;

    IF (l_debug = 1) THEN
          inv_log_util.TRACE('MMT Min Date = ' || l_min_mmt_date, 'PURGE_MAIN', 9);
    END IF;

    IF l_min_mmt_date IS NOT NULL THEN
      SELECT acct_period_id
        INTO l_min_period_id
        FROM org_acct_periods
       WHERE organization_id = p_orgid
         AND TRUNC(period_start_date) <= TRUNC(l_min_mmt_date)
         AND TRUNC(schedule_close_date) >= TRUNC(l_min_mmt_date)
         AND open_flag = 'N';

      SELECT COUNT(acct_period_id)
        INTO l_num_of_periods
        FROM org_acct_periods
       WHERE organization_id = p_orgid
         AND acct_period_id >= l_min_period_id
         AND TRUNC(period_start_date) <= TRUNC(p_purge_date)
         AND open_flag = 'N';
    ELSE
      l_num_of_periods  := 0;
      IF (l_debug = 1) THEN
          inv_log_util.TRACE('No Records in MMT to purge', 'PURGE_MAIN', 9);
      END IF;
      x_retcode         := 0;
      fnd_message.set_name('INV', 'INV_PURGE_TXN_ERR');
   	x_errbuf := fnd_message.get;
      RETURN;
    END IF;

    IF (l_debug = 1) THEN
          inv_log_util.TRACE('No of Periods = ' || l_num_of_periods, 'PURGE_MAIN', 9);
          inv_log_util.TRACE('Min period id = ' || l_min_period_id, 'PURGE_MAIN', 9);
    END IF;

    IF l_num_of_periods > 0 THEN
      l_period_per_worker  := CEIL(l_num_of_periods / l_max_workers);
      l_num_of_workers     := CEIL(l_num_of_periods / l_period_per_worker);
    END IF;

    IF (l_debug = 1) THEN
       inv_log_util.TRACE('Period(s) per worker = ' || l_period_per_worker, 'PURGE_MAIN', 9);
       inv_log_util.TRACE('No. of workers = ' || l_num_of_workers, 'PURGE_MAIN', 9);
    END IF;

    l_num_of_workers_launched  := 0;
    l_num_of_periods_fetched   := 0;

    IF l_period_per_worker > 0 THEN
      OPEN c_oap;

      LOOP
        FETCH c_oap INTO period_rec_type;
        EXIT WHEN c_oap%NOTFOUND;

        -- l_min_date should only be set when l_num_of_periods_fetched = 0
        IF l_num_of_periods_fetched = 0 THEN
          --Bug 5894075, Adding trunc
          l_min_date  := TRUNC(period_rec_type.min_date);
        END IF;
        --Bug 5894075, Adding trunc
        l_min_log_date  := TRUNC(period_rec_type.min_date);

        --Bug 5894075, removing + 1
        l_max_date      := TRUNC(period_rec_type.max_date);

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Min period Date= ' || l_min_log_date || ' Max period Date= ' || (l_max_date), 'PURGE_MAIN', 9);
        END IF;

        l_num_of_periods_fetched  := l_num_of_periods_fetched + 1;

        -- For the last worker we purge by p_purge_date
        IF (l_num_of_workers_launched = l_num_of_workers - 1) THEN
           IF (l_debug = 1) THEN
             inv_log_util.TRACE('Launching last Purge worker with Min period Date= ' || l_min_date || ' and Max period Date= ' || p_purge_date, 'PURGE_MAIN', 9);
           END IF;


          -- For bug 4055865. Converting the date into Varchar based on the date format on user preference tab.
          v_min_dt := fnd_date.date_to_displaydate(l_min_date);
          v_max_dt := fnd_date.date_to_displaydate(p_purge_date);


          l_purge_req_id                                   :=
            fnd_request.submit_request(application => 'INV'
                                     , program => 'INVTPGWB'
                                     , argument1 => p_orgid
                                     , argument2 => v_min_dt	-- For bug 4055865.
                                     , argument3 => v_max_dt);	-- For bug 4055865.

          IF (l_purge_req_id = 0) THEN
            -- Handle submission error --
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Error launching last Purge Worker', 'PURGE_MAIN', 9);
            END IF;

            RAISE submission_error_except;
          ELSE
            COMMIT;
          END IF;

          IF (l_debug = 1) THEN
              inv_log_util.TRACE('Concurrent Request_id is ' || l_purge_req_id, 'PURGE_MAIN', 9);
          END IF;

          l_num_of_workers_launched                        := l_num_of_workers_launched + 1;
          l_reqstatus_tbl_type(l_num_of_workers_launched)  := l_purge_req_id;
          EXIT; --Exit the loop, since all workers have been launched
        END IF;

        IF l_num_of_periods_fetched = l_period_per_worker THEN
           IF (l_debug = 1) THEN
             inv_log_util.TRACE('Launching Purge worker with Min period Date= ' || l_min_date || ' and Max period Date= ' || (l_max_date-1), 'PURGE_MAIN', 9);
           END IF;


	   -- For bug 4055865. Converting the date into Varchar based on the date format on user preference tab.
           v_min_dt := fnd_date.date_to_displaydate(l_min_date);
           v_max_dt := fnd_date.date_to_displaydate(l_max_date);


           l_purge_req_id                                   :=
            fnd_request.submit_request(application => 'INV'
                                     , program => 'INVTPGWB'
                                     , argument1 => p_orgid
                                     , argument2 => v_min_dt	-- For bug 4055865.
                                     , argument3 => v_max_dt);	-- For bug 4055865.

          IF (l_purge_req_id = 0) THEN
            -- Handle submission error --
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Error launching Purge Worker', 'PURGE_MAIN', 9);
            END IF;

            RAISE submission_error_except;
          ELSE
            COMMIT;
          END IF;

          IF (l_debug = 1) THEN
              inv_log_util.TRACE('Concurrent Request_id is ' || l_purge_req_id, 'PURGE_MAIN', 9);
          END IF;

          l_num_of_workers_launched                        := l_num_of_workers_launched + 1;
          l_num_of_periods_fetched                         := 0; --resetting l_num_of_periods_fetched
          l_reqstatus_tbl_type(l_num_of_workers_launched)  := l_purge_req_id;
        END IF;
      END LOOP;

      CLOSE c_oap;
      /**** Set the request to Pause status if all the Purge workers have not finished ****/
      l_result   := FALSE;

      WHILE(NOT l_result) LOOP
        FOR idx IN 1 .. l_reqstatus_tbl_type.COUNT LOOP
          l_req_id  := l_reqstatus_tbl_type(idx);

          SELECT COUNT(*)
            INTO l_count
            FROM fnd_concurrent_requests
           WHERE request_id = l_req_id
             AND phase_code = 'C';

          IF l_count = 1 THEN
            l_result  := TRUE;
          ELSE
            l_result  := FALSE;
          END IF;

          IF (NOT l_result) THEN
            EXIT;
          END IF;
        END LOOP; -- end for loop

        DBMS_LOCK.sleep(l_sleep_time);
      END LOOP; -- end while loop

      --Print the completed status for the requests in the log
      --Bug 3687369, need to print the errored status of the child requests in the log.

      FOR idx IN 1 .. l_reqstatus_tbl_type.COUNT LOOP
         SELECT STATUS_CODE INTO l_status_code_tbl_type(idx)
         FROM  fnd_concurrent_requests
         WHERE request_id = l_reqstatus_tbl_type(idx) AND phase_code = 'C';

         IF (l_status_code_tbl_type(idx) = 'E') then
            l_status_code_tbl_type(idx) := 'error';
            l_completion_status := 'E';
         ELSIF (l_status_code_tbl_type(idx) = 'C') then
            l_status_code_tbl_type(idx) := 'success';
         ELSIF (l_status_code_tbl_type(idx) = 'G') then
            l_status_code_tbl_type(idx) := 'warning';
         END IF;

         IF (l_debug = 1) THEN
              inv_log_util.TRACE('Concurrent Request_id ' || l_reqstatus_tbl_type(idx) || ' has completed with ' ||l_status_code_tbl_type(idx), 'PURGE_MAIN', 9);
         END IF;
      END LOOP;

      --Bug 3687369, if any of the child requests errors out, then main program should complete with a warning.
      if (l_completion_status = 'E') then
          	x_retcode  := 1;
      		fnd_message.set_name('INV', 'INV_PURGE_TXN_ERR');
        	x_errbuf := fnd_message.get;
                return;
      end if;

      x_retcode  := 0;
      x_errbuf   := 'Success';
    ELSE --l_period_per_worker = 0
       IF (l_debug = 1) THEN
         inv_log_util.TRACE('No periods to purge','PURGE_MAIN', 1);
       END IF;
      x_retcode  := 0;
      fnd_message.set_name('INV', 'INV_PURGE_TXN_ERR');
   	x_errbuf := fnd_message.get;
    END IF;
  EXCEPTION
    WHEN submission_error_except THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('submission_error_except :' || SQLCODE, 'PURGE_MAIN', 1);
        inv_log_util.TRACE('submission_error_except :' || SUBSTR(SQLERRM, 1, 100), 'PURGE_MAIN', 1);
      END IF;

      IF c_oap%ISOPEN THEN
        CLOSE c_oap;
      END IF;

      x_retcode  := 2;
      fnd_message.set_name('INV', 'INV_PURGE_TXN_ERR');
   	x_errbuf := fnd_message.get;
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('Error :' || SUBSTR(SQLERRM, 1, 100), 'PURGE_MAIN', 1);
      END IF;

      IF c_oap%ISOPEN THEN
        CLOSE c_oap;
      END IF;

      x_retcode  := 2;
      fnd_message.set_name('INV', 'INV_PURGE_TXN_ERR');
   	x_errbuf := fnd_message.get;
   END txn_purge_main;
END inv_txn_purge_main;

/
