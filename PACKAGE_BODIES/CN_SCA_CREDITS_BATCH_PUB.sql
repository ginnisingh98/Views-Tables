--------------------------------------------------------
--  DDL for Package Body CN_SCA_CREDITS_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_CREDITS_BATCH_PUB" AS
  -- $Header: cnpscabb.pls 120.5.12010000.22 2010/02/10 11:40:44 rajukum ship $
  -- +======================================================================+
  -- |                Copyright (c) 1994 Oracle Corporation                 |
  -- |                   Redwood Shores, California, USA                    |
  -- |                        All rights reserved.                          |
  -- +======================================================================+
  --
  -- Package Name
  --   CN_SCA_CREDITS_BATCH_PUB
  -- Purpose
  --   Package Body to process the Sales Credit Allocations
  --   Add the flow diagram here.
  -- History
    --   06/26/03   Rao.Chenna         Created
    -- Nov 17, 2005    vensrini        Added org_id to insert into
    --                                 CN_SCA_PROCESS_BATCHES stmt
    --
    --                                 Added fnd_request.set_org_id
    --                                 call in conc_submit proc
    --
  g_pkg_name    CONSTANT VARCHAR2(30)                 := 'CN_SCA_CREDITS_BATCH_PUB';
  g_file_name   CONSTANT VARCHAR2(12)                 := 'cnpscabb.pls';
  no_trx                 EXCEPTION;
  conc_fail              EXCEPTION;
  api_call_failed        EXCEPTION;
  g_cn_debug             VARCHAR2(1)                  := fnd_profile.VALUE('CN_DEBUG');
  g_login_id             NUMBER                       := fnd_global.conc_login_id;
  g_sysdate              DATE                         := SYSDATE;
  g_program_id           NUMBER                       := fnd_global.conc_program_id;
  g_user_id              NUMBER                       := fnd_global.user_id;
  g_request_id           NUMBER                       := fnd_global.conc_request_id;
  g_fetch_limit          NUMBER                       := 10000;


  TYPE g_rowid_tbl_type IS TABLE OF ROWID;

  TYPE g_comm_lines_api_id_tbl_type IS TABLE OF cn_comm_lines_api_all.comm_lines_api_id%TYPE;

  TYPE g_trans_object_id_tbl_type IS TABLE OF jtf_tae_1001_sc_winners.trans_object_id%TYPE;

  TYPE g_terr_id_tbl_type IS TABLE OF jtf_tae_1001_sc_winners.terr_id%TYPE;

  TYPE g_salesrep_id_tbl_type IS TABLE OF cn_salesreps.salesrep_id%TYPE;

  TYPE g_emp_no_tbl_type IS TABLE OF cn_salesreps.employee_number%TYPE;

  TYPE g_role_id_tbl_type IS TABLE OF jtf_tae_1001_sc_winners.role_id%TYPE;

  TYPE g_split_pctg_tbl_type IS TABLE OF jtf_terr_rsc_all.attribute1%TYPE;

  TYPE g_rev_type_tbl_type IS TABLE OF jtf_terr_rsc_all.attribute1%TYPE;

  TYPE g_terr_name_tbl_type IS TABLE OF jtf_terr_all.NAME%TYPE;

  TYPE g_del_flag_tbl_type IS TABLE OF VARCHAR2(1);

  g_unloaded_txn_tbl     g_rowid_tbl_type;
  g_loaded_txn_rowid_tbl g_rowid_tbl_type;
  g_loaded_txn_comid_tbl g_comm_lines_api_id_tbl_type;
  g_sca_insert_tbl_type  cn_sca_insert_tbl_type;

  --
  PROCEDURE debugmsg(msg VARCHAR2) IS
  BEGIN
    IF g_cn_debug = 'Y' THEN
      cn_message_pkg.DEBUG(SUBSTR(msg, 1, 254));
      fnd_file.put_line(fnd_file.LOG, msg);
    END IF;
  END debugmsg;

  PROCEDURE parent_conc_wait(
         l_child_program_id_tbl IN  OUT NOCOPY    sub_program_id_type
       , retcode                OUT     NOCOPY    VARCHAR2
       , errbuf                 OUT     NOCOPY    VARCHAR2

                    )
IS

    call_status                  BOOLEAN;

    l_req_id                     NUMBER;

    l_phase                      VARCHAR2(100);
    l_status                     VARCHAR2(100);
    l_dev_phase                  VARCHAR2(100);
    l_dev_status                 VARCHAR2(100);
    l_message                    VARCHAR2(2000);

    child_proc_fail_exception    EXCEPTION;
BEGIN
     debugmsg('SCA : CN_SCATM_TAE_PUB.Parent Process starts Waiting For Child
     Processes to complete');

     FOR l_child_program_id IN l_child_program_id_tbl.FIRST..l_child_program_id_tbl.LAST
     LOOP

            call_status :=
            FND_CONCURRENT.get_request_status(
            l_child_program_id_tbl(l_child_program_id), '', '',
 			    l_phase, l_status, l_dev_phase,
                            l_dev_status, l_message);

           debugmsg('SCA : CN_SCATM_TAE_PUB. Request '||l_child_program_id_tbl(l_child_program_id)
           ||' l_dev_phase '||l_dev_phase||' l_dev_status ');

           WHILE l_dev_phase <> 'COMPLETE'
           LOOP

            call_status :=
            FND_CONCURRENT.get_request_status(
            l_child_program_id_tbl(l_child_program_id), '', '',
 			    l_phase, l_status, l_dev_phase,
                            l_dev_status, l_message);

           debugmsg('SCA : CN_SCATM_TAE_PUB. Request '||l_child_program_id_tbl(l_child_program_id)
           ||' l_dev_phase '||l_dev_phase||' l_dev_status. Parent Process going to sleep for 10 seconds. ');

               dbms_lock.sleep(10);

           END LOOP;


            IF l_dev_status = 'ERROR'
            THEN
               retcode := 2;
               errbuf := l_message;
               raise child_proc_fail_exception;
            END IF;

     END LOOP;
EXCEPTION
WHEN child_proc_fail_exception
THEN
retcode := 2;
debugmsg('SCA : CN_SCATM_TAE_PUB.get_credited_txns.Child Proc Failed exception');
debugmsg('SCA : SQLCODE : ' || SQLCODE);
debugmsg('SCA : SQLERRM : ' || SQLERRM);
WHEN OTHERS THEN
debugmsg('SCA : Unexpected exception in get_credited_txns');
debugmsg('SCA : SQLCODE : ' || SQLCODE);
debugmsg('SCA : SQLERRM : ' || SQLERRM);
retcode  := 2;
errbuf   := 'CN_SCATM_TAE_PUB.get_credited_txns.others';

END parent_conc_wait;

  --
  PROCEDURE conc_submit(
    x_conc_program         IN            VARCHAR2
  , x_parent_proc_audit_id IN            NUMBER
  , x_physical_batch_id    IN            NUMBER
  , x_start_date           IN            DATE
  , x_end_date             IN            DATE
  , p_transaction_source   IN            VARCHAR2
  , p_org_id               IN            NUMBER
  , x_request_id           IN OUT NOCOPY NUMBER
  ) IS
  BEGIN
    debugmsg('Conc_Submit : p_transaction_source = ' || p_transaction_source);
    debugmsg('Conc_Submit : x_start_date = ' || x_start_date);
    debugmsg('Conc_Submit : x_end_date = ' || x_end_date);
    debugmsg('Conc_Submit : x_physical_batch_id = ' || x_physical_batch_id);
    fnd_request.set_org_id(p_org_id);   -- vensrini Nov 17, 2005
    x_request_id  :=
      fnd_request.submit_request(
        application                  => 'CN'
      , program                      => x_conc_program
      , argument1                    => x_parent_proc_audit_id
      , argument2                    => x_physical_batch_id
      , argument3                    => p_transaction_source
      , argument4                    => x_start_date
      , argument5                    => x_end_date
      , argument6                    => p_org_id
      );
    debugmsg('Conc_Submit : x_request_id = ' || x_request_id);

    IF x_request_id = 0 THEN
      debugmsg('Loader : Conc_Submit : Submit failure for phys batch ' || x_physical_batch_id);
      debugmsg('Loader : Conc_Submit: ' || fnd_message.get);
      debugmsg('Loader : Conc_Submit : Submit failure for phys batch ' || x_physical_batch_id);
    ELSE
      cn_message_pkg.FLUSH;
      COMMIT;   -- Commit for each concurrent program i.e. runner
    END IF;

    debugmsg('Conc_Submit : End Procedure');
  END conc_submit;

  --
  PROCEDURE conc_dispatch(
    x_parent_proc_audit_id IN NUMBER
  , x_start_date           IN DATE
  , x_end_date             IN DATE
  , x_logical_batch_id     IN NUMBER
  , x_transaction_source   IN VARCHAR2
  , p_org_id               IN NUMBER
  ) IS
    TYPE requests IS TABLE OF NUMBER(15)
      INDEX BY BINARY_INTEGER;

    TYPE batches IS TABLE OF NUMBER(15)
      INDEX BY BINARY_INTEGER;

    l_primary_request_stack requests;
    l_primary_batch_stack   batches;
    l_empty_request_stack   requests;
    l_empty_batch_stack     batches;
    x_batch_total           NUMBER                     := 0;
    l_temp_id               NUMBER                     := 0;
    l_temp_phys_batch_id    NUMBER;
    primary_ptr             NUMBER                     := 1;   -- Must start at 1
    l_dev_phase             VARCHAR2(80);
    l_dev_status            VARCHAR2(80);
    l_request_id            NUMBER;
    l_completed_batch_count NUMBER                     := 0;
    l_call_status           BOOLEAN;
    l_next_process          VARCHAR2(30);
    l_dummy                 VARCHAR2(500);
    unfinished              BOOLEAN                    := TRUE;
    l_user_id               NUMBER(15)                 := fnd_global.user_id;
    l_resp_id               NUMBER(15)                 := fnd_global.resp_id;
    l_login_id              NUMBER(15)                 := fnd_global.login_id;
    l_conc_prog_id          NUMBER(15)                 := fnd_global.conc_program_id;
    l_conc_request_id       NUMBER(15)                 := fnd_global.conc_request_id;
    l_prog_appl_id          NUMBER(15)                 := fnd_global.prog_appl_id;
    x_debug                 NUMBER;
    debug_v                 NUMBER;
    conc_status             BOOLEAN;
    l_sleep_time            NUMBER                     := 180;
    l_sleep_time_char       VARCHAR2(30);
    l_errbuf                VARCHAR2(1000);
    l_retcode               NUMBER;

    -- Get individual physical batch id's for the entire logical batch
    CURSOR physical_batches IS
      SELECT DISTINCT sca_process_batch_id
                 FROM cn_sca_process_batches
                WHERE logical_batch_id = x_logical_batch_id;

    physical_rec            physical_batches%ROWTYPE;
  BEGIN
    debugmsg('SCA : Conc_Dispatch : Start of Conc_Dispatch');
    debugmsg('SCA : Conc_Dispatch : Logical Batch ID = ' || x_logical_batch_id);

    WHILE unfinished LOOP
      l_primary_request_stack  := l_empty_request_stack;
      l_primary_batch_stack    := l_empty_batch_stack;
      primary_ptr              := 1;   -- Start at element one not element zero
      l_completed_batch_count  := 0;
      x_batch_total            := 0;

      FOR physical_rec IN physical_batches LOOP
        debugmsg(
             'Conc_Dispatch : Calling conc_submit. '
          || 'physical_rec.sca_process_batch_id = '
          || physical_rec.sca_process_batch_id
        );
        debugmsg('SCA : Conc_Dispatch : call SCA_BATCH_RUNNER');
        cn_sca_credits_batch_pub.conc_submit
                                          (
          x_conc_program               => 'CN_SCA_PROCESS_BATCH_RULES'
        , x_parent_proc_audit_id       => x_parent_proc_audit_id
        , x_physical_batch_id          => physical_rec.sca_process_batch_id
        , x_start_date                 => x_start_date
        , x_end_date                   => x_end_date
        , p_transaction_source         => x_transaction_source
        , p_org_id                     => p_org_id
        , x_request_id                 => l_temp_id
        );
        debugmsg('SCA : Conc_Dispatch : done SCA_BATCH_RUNNER');
        x_batch_total                           := x_batch_total + 1;
        l_primary_request_stack(x_batch_total)  := l_temp_id;
        l_primary_batch_stack(x_batch_total)    := physical_rec.sca_process_batch_id;

        -- If submission failed update the batch record and bail
        IF l_temp_id = 0 THEN
          --cn_debug.print_msg('conc disp submit failed',1);
          l_temp_phys_batch_id  := physical_rec.sca_process_batch_id;
          RAISE conc_fail;
        END IF;
      END LOOP;

      debugmsg('SCA : Conc_Dispatch : Total conc requests submitted : ' || x_batch_total);
      debugmsg('Total conc requests submitted : ' || x_batch_total);
      --cn_message_pkg.flush;
      debug_v                  := l_primary_request_stack(primary_ptr);
      l_sleep_time_char        := fnd_profile.VALUE('CN_SLEEP_TIME');

      IF l_sleep_time_char IS NOT NULL THEN
        l_sleep_time  := TO_NUMBER(l_sleep_time_char);
      END IF;

      DBMS_LOCK.sleep(l_sleep_time);

      WHILE l_completed_batch_count <= x_batch_total LOOP
        IF l_primary_request_stack(primary_ptr) IS NOT NULL THEN
          l_call_status  :=
            fnd_concurrent.get_request_status(
              request_id                   => l_primary_request_stack(primary_ptr)
            , phase                        => l_dummy
            , status                       => l_dummy
            , dev_phase                    => l_dev_phase
            , dev_status                   => l_dev_status
            , MESSAGE                      => l_dummy
            );

          IF (NOT l_call_status) THEN
            debugmsg('SCA : Conc_Dispatch : request_id is ' || l_primary_request_stack(primary_ptr));
            RAISE conc_fail;
          END IF;

          IF (l_dev_phase = 'COMPLETE') THEN
            debug_v                               := l_primary_request_stack(primary_ptr);
            l_temp_phys_batch_id                  := l_primary_batch_stack(primary_ptr);
            l_primary_batch_stack(primary_ptr)    := NULL;
            l_primary_request_stack(primary_ptr)  := NULL;
            l_completed_batch_count               := l_completed_batch_count + 1;

            IF (l_dev_status = 'ERROR') THEN
              debugmsg('SCA : Conc_Dispatch : ' || 'Request completed with error for ' || debug_v);
              RAISE conc_fail;
            ELSIF l_dev_status = 'NORMAL' THEN
              x_debug  := l_primary_batch_stack(primary_ptr);
            END IF;   -- If error
          END IF;   -- If complete
        END IF;   -- If null ptr

        primary_ptr  := primary_ptr + 1;

        IF (l_completed_batch_count = x_batch_total) THEN
          debugmsg(
               'SCA : Conc_Dispatch :  All requests complete for physical '
            || 'transaction_source : '
            || x_transaction_source
          );
          -- Get out of the loop by adding 1
          l_completed_batch_count  := l_completed_batch_count + 1;
          debugmsg(
               'SCA : Conc_Dispatch :  All requests complete for '
            || 'logical process : '
            || x_transaction_source
          );
          unfinished               := FALSE;
        ELSE
          -- Made a complete pass through the srp_periods in this physical
          -- batch and some conc requests have not completed.
          -- Give the conc requests a few minutes to run before
          -- checking their status
          IF (primary_ptr > x_batch_total) THEN
            DBMS_LOCK.sleep(l_sleep_time);
            primary_ptr  := 1;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debugmsg('SCA : Conc_Dispatch : no rows for process ' || x_transaction_source);
    WHEN conc_fail THEN
      debugmsg('SCA : Conc_Dispatch : Exception conc_fail');
      conc_status  := fnd_concurrent.set_completion_status(status => 'ERROR', MESSAGE => '');
      RAISE;
    WHEN OTHERS THEN
      debugmsg('SCA : Conc_Dispatch : Unexpected Exception');
      RAISE;
  END conc_dispatch;

  --
  PROCEDURE split_batches(
    p_logical_batch_id   IN            NUMBER
  , p_start_date         IN            DATE
  , p_end_date           IN            DATE
  , p_transaction_source IN            VARCHAR2
  , p_org_id             IN            NUMBER
  , x_size               OUT NOCOPY    NUMBER
  ) IS
    l_sql_stmt             VARCHAR2(10000);
    l_sql_stmt_count       VARCHAR2(10000);
    l_sql_stmt_id          VARCHAR2(10000);
    l_sql_stmt_divider     VARCHAR2(10000);
    l_sql_stmt_resource    VARCHAR2(10000);
    l_no_trx               BOOLEAN;
    l_sca_process_batch_id cn_sca_process_batches.sca_process_batch_id%TYPE;

    TYPE rc IS REF CURSOR;

    TYPE divider_type IS TABLE OF NUMBER;

    query_cur              rc;
    i                      NUMBER;
    l_header_rec           cn_comm_lines_api%ROWTYPE;
    l_lines_output_id      cn_sca_lines_output.sca_lines_output_id%TYPE;
    l_header_interface_id  cn_sca_headers_interface.sca_headers_interface_id%TYPE;
    l_comm_lines_api_id    cn_comm_lines_api.comm_lines_api_id%TYPE;
    l_source_id            cn_sca_headers_interface.source_id%TYPE;
    l_order_number         cn_comm_lines_api.order_number%TYPE;
    l_invoice_number       cn_comm_lines_api.invoice_number%TYPE;
    l_id                   NUMBER;
    l_logical_batch_size   NUMBER;
    l_worker_num           NUMBER;
    l_physical_batch_size  NUMBER;
    l_divider_size         NUMBER;
    divider                divider_type                                           := divider_type
                                                                                                 ();
    loop_count             NUMBER;
    l_start_id             cn_sca_process_batches.start_id%TYPE;
    l_end_id               cn_sca_process_batches.end_id%TYPE;
    l_user_id              NUMBER(15)                                         := fnd_global.user_id;
    l_login_id             NUMBER(15)                                        := fnd_global.login_id;
  BEGIN
    debugmsg('Allocation Process : Split Batches Start ');
    debugmsg('Allocation Process : p_start_date = ' || p_start_date);
    debugmsg('Allocation Process : p_end_date = ' || p_end_date);
    -- Get the number of transactions that needs to be processed,
    -- i.e. the logical batch size
    l_sql_stmt_count  := 'SELECT count(1) FROM cn_sca_headers_interface cshi ';
    l_sql_stmt        :=
         'WHERE cshi.processed_date BETWEEN :p_start_date AND :p_end_date '
      || 'AND cshi.transaction_source = :p_transaction_source '
      || 'AND cshi.process_status = ''SCA_UNPROCESSED'' '
      || 'AND cshi.org_id = :p_org_id '
      || 'ORDER BY cshi.sca_headers_interface_id ';
    l_sql_stmt_count  := l_sql_stmt_count || l_sql_stmt;

    OPEN query_cur
     FOR l_sql_stmt_count USING p_start_date, p_end_date, p_transaction_source, p_org_id;

    FETCH query_cur
     INTO l_logical_batch_size;

    x_size            := l_logical_batch_size;
    l_worker_num      := NVL(fnd_profile.VALUE('CN_NUMBER_OF_WORKERS'), 1);

    IF (l_worker_num < 1) THEN
      l_worker_num  := 1;
    END IF;

    debugmsg(p_transaction_source || ': Assign : Logical Batch Size = '
      || TO_CHAR(l_logical_batch_size));
    debugmsg(p_transaction_source || ': Assign : Number of Workers = ' || TO_CHAR(l_worker_num));

    -- calculate the minimas and maximas of the physical batches
    IF (l_logical_batch_size > l_worker_num) THEN
      l_physical_batch_size    := FLOOR(l_logical_batch_size / l_worker_num);
      l_divider_size           := l_worker_num * 2;
      divider.EXTEND;
      divider(1)               := 1;
      divider.EXTEND;
      divider(2)               := divider(1) + l_physical_batch_size - 1;

      FOR counter IN 2 .. l_worker_num LOOP
        divider.EXTEND;
        divider(2 * counter - 1)  := divider(2 * counter - 2) + 1;
        divider.EXTEND;
        divider(2 * counter)      := divider(2 * counter - 1) + l_physical_batch_size - 1;

        IF (counter <> l_worker_num) THEN
          debugmsg(
               p_transaction_source
            || ': Assign : Maxima'
            || counter
            || ' = '
            || TO_CHAR(divider(2 * counter))
          );
        END IF;
      END LOOP;

      divider(l_divider_size)  := l_logical_batch_size;
    ELSE
      l_physical_batch_size  := 0;

      FOR counter IN 1 .. l_logical_batch_size LOOP
        divider.EXTEND;
        divider(2 * counter - 1)  := counter;
        divider.EXTEND;
        divider(2 * counter)      := counter;
      END LOOP;
    END IF;

    --
    IF (divider.COUNT = 0) THEN
      l_no_trx  := TRUE;
      RAISE no_trx;
    ELSE
      l_no_trx            := FALSE;
      l_sql_stmt_divider  := '(''' || divider(divider.FIRST) || '''';
      i                   := divider.NEXT(divider.FIRST);

      WHILE i IS NOT NULL LOOP
        l_sql_stmt_divider  := l_sql_stmt_divider || ', ''' || divider(i) || '''';
        i                   := divider.NEXT(i);
      END LOOP;

      l_sql_stmt_divider  := l_sql_stmt_divider || ')';
    END IF;

    IF (NOT l_no_trx) THEN
      l_sql_stmt_id  :=
                   'SELECT cshi.sca_headers_interface_id ' || 'FROM cn_sca_headers_interface CSHI ';
      l_sql_stmt_id  := l_sql_stmt_id || l_sql_stmt;
      l_sql_stmt_id  :=
           'SELECT sca_headers_interface_id FROM '
        || '(SELECT rownum row_number, sca_headers_interface_id FROM '
        || '('
        || l_sql_stmt_id
        || ')) sca_headers_table '
        || 'WHERE sca_headers_table.row_number IN '
        || l_sql_stmt_divider;

      OPEN query_cur
       FOR l_sql_stmt_id USING p_start_date, p_end_date, p_transaction_source, p_org_id;

      loop_count     := 1;
      debugmsg(p_transaction_source || ': Assign : Insert into CN_SCA_PROCESS_BATCHES ');

      IF (l_physical_batch_size >= 2) THEN
        LOOP
          FETCH query_cur
           INTO l_id;

          EXIT WHEN query_cur%NOTFOUND;

          IF ((loop_count MOD 2) = 1) THEN
            l_start_id  := l_id;
          END IF;

          IF ((loop_count MOD 2) = 0) THEN
            l_end_id  := l_id;

            SELECT cn_sca_process_batches_s.NEXTVAL
              INTO l_sca_process_batch_id
              FROM SYS.DUAL;

            INSERT INTO cn_sca_process_batches
                        (
                         sca_process_batch_id
                       , start_id
                       , end_id
                       , TYPE
                       , logical_batch_id
                       , creation_date
                       , created_by
                       , last_update_date
                       , last_updated_by
                       , last_update_login
                       , org_id
                        )
                 VALUES (
                         l_sca_process_batch_id
                       , l_start_id
                       , l_end_id
                       , p_transaction_source
                       , p_logical_batch_id
                       , SYSDATE
                       , l_user_id
                       , SYSDATE
                       , l_user_id
                       , l_login_id
                       , p_org_id
                        );

            debugmsg(
                 p_transaction_source
              || ': Assign : sca_process_batch_id = '
              || TO_CHAR(l_sca_process_batch_id)
            );
            debugmsg(p_transaction_source || ': Assign : start_id = ' || l_start_id);
            debugmsg(p_transaction_source || ': Assign : end_id = ' || l_end_id);
            debugmsg(
              p_transaction_source || ': Assign : logical_batch_id = '
              || TO_CHAR(p_logical_batch_id)
            );
            debugmsg(p_transaction_source || ': Assign : batch_type = ' || p_transaction_source);
          END IF;

          loop_count  := loop_count + 1;
        END LOOP;
      ELSE
        LOOP
          FETCH query_cur
           INTO l_id;

          EXIT WHEN query_cur%NOTFOUND;

          IF (loop_count = l_worker_num AND l_physical_batch_size = 1) THEN
            l_start_id  := l_id;
          END IF;

          IF (loop_count > l_worker_num AND l_physical_batch_size = 1) THEN
            l_end_id  := l_id;

            SELECT cn_sca_process_batches_s.NEXTVAL
              INTO l_sca_process_batch_id
              FROM SYS.DUAL;

            INSERT INTO cn_sca_process_batches
                        (
                         sca_process_batch_id
                       , start_id
                       , end_id
                       , TYPE
                       , logical_batch_id
                       , creation_date
                       , created_by
                       , last_update_date
                       , last_updated_by
                       , last_update_login
                       , org_id
                        )
                 VALUES (
                         l_sca_process_batch_id
                       , l_start_id
                       , l_end_id
                       , p_transaction_source
                       , p_logical_batch_id
                       , SYSDATE
                       , l_user_id
                       , SYSDATE
                       , l_user_id
                       , l_login_id
                       , p_org_id
                        );

            debugmsg(
                 p_transaction_source
              || ': Assign : sca_process_batch_id = '
              || TO_CHAR(l_sca_process_batch_id)
            );
            debugmsg(p_transaction_source || ': Assign : start_id = ' || l_start_id);
            debugmsg(p_transaction_source || ': Assign : end_id = ' || l_end_id);
            debugmsg(
              p_transaction_source || ': Assign : logical_batch_id = '
              || TO_CHAR(p_logical_batch_id)
            );
            debugmsg(p_transaction_source || ': Assign : batch_type = ' || p_transaction_source);
          END IF;

          IF (
              loop_count < l_worker_num OR(loop_count = l_worker_num AND l_physical_batch_size < 1)
             ) THEN
            SELECT cn_sca_process_batches_s.NEXTVAL
              INTO l_sca_process_batch_id
              FROM SYS.DUAL;

            INSERT INTO cn_sca_process_batches
                        (
                         sca_process_batch_id
                       , start_id
                       , end_id
                       , TYPE
                       , logical_batch_id
                       , creation_date
                       , created_by
                       , last_update_date
                       , last_updated_by
                       , last_update_login
                       , org_id
                        )
                 VALUES (
                         l_sca_process_batch_id
                       , l_id
                       , l_id
                       , p_transaction_source
                       , p_logical_batch_id
                       , SYSDATE
                       , l_user_id
                       , SYSDATE
                       , l_user_id
                       , l_login_id
                       , p_org_id
                        );

            debugmsg(
                 p_transaction_source
              || ': Assign : sca_process_batch_id = '
              || TO_CHAR(l_sca_process_batch_id)
            );
            debugmsg(p_transaction_source || ': Assign : start_id = ' || l_id);
            debugmsg(p_transaction_source || ': Assign : end_id = ' || l_id);
            debugmsg(
              p_transaction_source || ': Assign : logical_batch_id = '
              || TO_CHAR(p_logical_batch_id)
            );
            debugmsg(p_transaction_source || ': Assign : batch_type = ' || p_transaction_source);
          END IF;

          loop_count  := loop_count + 1;
        END LOOP;
      END IF;
    END IF;
  EXCEPTION
    WHEN no_trx THEN
      debugmsg(p_transaction_source || ': Assign : No transactions to process ');
    WHEN OTHERS THEN
      debugmsg(p_transaction_source || ': Assign : Unexpected Error');
      RAISE;
  END split_batches;

  --
  PROCEDURE get_sales_credits(
    errbuf               OUT NOCOPY    VARCHAR2
  , retcode              OUT NOCOPY    NUMBER
  , p_transaction_source IN            VARCHAR2
  , p_start_date         IN            VARCHAR2
  , p_end_date           IN            VARCHAR2
  ) IS
    --+
    --+ Variable Declaration
    --+
    l_start_date       DATE;
    l_end_date         DATE;
    l_process_audit_id NUMBER;
    l_logical_batch_id NUMBER;
    x_size_inv         NUMBER;
    x_size_ord         NUMBER;
    x_size             NUMBER;
    conc_status        BOOLEAN;
    l_wf_item_key      VARCHAR2(240);
    l_return_status    VARCHAR2(1);
    l_rule_count       NUMBER        := 0;
    l_status           VARCHAR2(1);
    l_industry         VARCHAR2(1);
    l_oracle_schema    VARCHAR2(30);
    l_return           BOOLEAN;
    p_org_id           NUMBER;
    --+
    --+ Exceptions Declaration
    --+
    index_ex           EXCEPTION;
    no_rule_ex         EXCEPTION;
  BEGIN
    p_org_id      := mo_global.get_current_org_id();
    cn_message_pkg.begin_batch(
      x_process_type               => 'ALLOCATION_PROCESS'
    , x_parent_proc_audit_id       => NULL
    , x_process_audit_id           => l_process_audit_id
    , x_request_id                 => fnd_global.conc_request_id
    , p_org_id                     => p_org_id
    );
    -- Convert the dates for the varchar2 parameters passed in from
    -- concurrent program
    l_start_date  := fnd_date.canonical_to_date(p_start_date);
    l_end_date    := fnd_date.canonical_to_date(p_end_date);

    --+
    --+ Call begin_batch to get process_audit_id for debug log file
    --+
    SELECT cn_sca_logical_batches_s.NEXTVAL
      INTO l_logical_batch_id
      FROM SYS.DUAL;

    debugmsg('Allocation Process : Start of Transfer');
    debugmsg('Allocation Process : process_audit_id is ' || l_process_audit_id);
    --dbms_output.put_line('Allocation Process : process_audit_id is ' || l_process_audit_id );
    debugmsg('Allocation Process : logical_batch_id is ' || l_logical_batch_id);
    debugmsg('Allocation Process : p_start_date is ' || p_start_date);
    debugmsg('Allocation Process : p_end_date is ' || p_end_date);
    debugmsg('Allocation Process : mo_global.get_current_org_id is - ' || p_org_id);

    --+
    --+ Check whether credit rules existing for a given transaction source and
    --+ operating unit
    --+
    SELECT COUNT(1)
      INTO l_rule_count
      FROM cn_sca_denorm_rules a
     WHERE a.transaction_source = p_transaction_source AND a.org_id = p_org_id;

    IF (l_rule_count = 0) THEN
      RAISE no_rule_ex;
    END IF;

    --+
    --+ Call this procedure to to find out the number of records and split
    --+ them into multiple physical batches.
    --+
    cn_sca_credits_batch_pub.split_batches(l_logical_batch_id, l_start_date, l_end_date
    , p_transaction_source, p_org_id, x_size);
    COMMIT;

    IF (x_size = 0) THEN
      RAISE no_trx;
    END IF;

    --+
    --+ Getting the schema name and use it as a parameter in DDL statements.
    --+ to fix bug# 3537330 (04/23/04)
    --+
    l_return      :=
      fnd_installation.get_app_info(
        application_short_name       => 'CN'
      , status                       => l_status
      , industry                     => l_industry
      , oracle_schema                => l_oracle_schema
      );
    debugmsg('Allocation Process : Schema Name: ' || l_oracle_schema);
    --+
    --+ Removing data from intermediate tables
    --+
    debugmsg('Allocation Process : Removing data from intermediate tables');

    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_oracle_schema || '.cn_sca_matches_all REUSE STORAGE';
    EXCEPTION
      WHEN OTHERS THEN
        debugmsg('Allocation Process : Unable to trancate cn_sca_matches' || SQLERRM);
        RAISE;
    END;

    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_oracle_schema || '.cn_sca_winners_all REUSE STORAGE';
    EXCEPTION
      WHEN OTHERS THEN
        debugmsg('Allocation Process : Unable to trancate cn_sca_winners' || SQLERRM);
        RAISE;
    END;

    COMMIT;
    --+
    --+ Setting the tables in NOLOGGING mode
    --+
    debugmsg('Allocation Process : Set the tables to NOLOGGING Mode');

    BEGIN
      EXECUTE IMMEDIATE 'ALTER TABLE ' || l_oracle_schema || '.cn_sca_matches_all NOLOGGING';
    EXCEPTION
      WHEN OTHERS THEN
        debugmsg('Allocation Process : Unable to set NOLOGGING for cn_sca_matches' || SQLERRM);
        RAISE;
    END;

    BEGIN
      EXECUTE IMMEDIATE 'ALTER TABLE ' || l_oracle_schema || '.cn_sca_winners_all NOLOGGING';
    EXCEPTION
      WHEN OTHERS THEN
        debugmsg('Allocation Process : Unable to set NOLOGGING for cn_sca_winners' || SQLERRM);
        RAISE;
    END;

    --+
    --+ Delete existing indexes and create indexes on ATTRIBUTE columns of
    --+ input interface table.
    --+
    cn_sca_utl_pvt.manage_indexes(
      p_transaction_source         => p_transaction_source
    , p_org_id                     => p_org_id
    , x_return_status              => l_return_status
    );

    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE index_ex;
    END IF;

    COMMIT;
    --+
    --+ Once physical batches are created, this procedure assign each physical
    --+ batch as a concurrent program
    --+
    cn_sca_credits_batch_pub.conc_dispatch(
      x_parent_proc_audit_id       => l_process_audit_id
    , x_start_date                 => l_start_date
    , x_end_date                   => l_end_date
    , x_transaction_source         => p_transaction_source
    , p_org_id                     => p_org_id
    , x_logical_batch_id           => l_logical_batch_id
    );
    --+
    --+ Once processing is done, call workflow process to execute the calling
    --+ module's procedure to populate data from SCA tables to their tables.
    --+
    debugmsg('Allocation Process : Calling WF to execute Calling Module Procedure');

    BEGIN
      cn_sca_wf_pkg.start_process(
        p_start_date                 => l_start_date
      , p_end_date                   => l_end_date
      , p_trx_source                 => p_transaction_source
      , p_org_id                     => p_org_id
      , p_wf_process                 => 'CN_SCA_TRX_LOAD_PR'
      , p_wf_item_type               => 'CNSCARPR'
      , x_wf_item_key                => l_wf_item_key
      );
      debugmsg('Allocation Process : Executed Calling Module Procedure');
    EXCEPTION
      WHEN OTHERS THEN
        debugmsg('Allocation Process : Error while processing Calling Module Procedure');
    END;

    COMMIT WORK;
    debugmsg('Allocation Process : Ending: get_sales_credits ');
    cn_message_pkg.end_batch(l_process_audit_id);
  EXCEPTION
    WHEN no_trx THEN
      debugmsg('Get Sales Credits : No input transactions found for Rules Engine Processing');
      debugmsg('Get Sales Credits : Rules Engine Processing ended with errors');
      conc_status  := fnd_concurrent.set_completion_status(status => 'ERROR', MESSAGE => '');
      cn_message_pkg.end_batch(l_process_audit_id);
    WHEN no_rule_ex THEN
      debugmsg('Get Sales Credits : No Credit Rules found for Rules Engine Processing');
      debugmsg('Get Sales Credits : Rules Engine Processing ended with errors');
      conc_status  := fnd_concurrent.set_completion_status(status => 'ERROR', MESSAGE => '');
      cn_message_pkg.end_batch(l_process_audit_id);
    WHEN index_ex THEN
      debugmsg('Get Sales Credits : Error occured while creating indexes dynamically');
      debugmsg('Get Sales Credits : Rules Engine Processing ended with errors');
      conc_status  := fnd_concurrent.set_completion_status(status => 'ERROR', MESSAGE => '');
      cn_message_pkg.end_batch(l_process_audit_id);
    WHEN OTHERS THEN
      debugmsg('Get Sales Credits : Unexpected exception');
      debugmsg('Get Sales Credits : Oracle Error: ' || SQLERRM);
      debugmsg('Get Sales Credits : Rules Engine Processing ended with errors');
      conc_status  := fnd_concurrent.set_completion_status(status => 'ERROR', MESSAGE => '');
      cn_message_pkg.end_batch(l_process_audit_id);
  END get_sales_credits;

  --

  /**************************************/
  /* Start of the new crediting process */
  /**************************************/

  /* This procedure returns the appropiate where clause to select    */
  /* data from the table cn_comm_lines_api_all depending on run mode */
  PROCEDURE get_where_clause(
    p_start_date   IN            DATE
  , p_end_date     IN            DATE
  , p_org_id       IN            NUMBER
  , p_run_mode     IN            VARCHAR2
  , x_where_clause OUT NOCOPY    VARCHAR2
  , errbuf         IN OUT NOCOPY VARCHAR2
  , retcode        IN OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    debugmsg('SCA : Start of get_where_clause');
    errbuf          := NULL;
    retcode         := 0;
    x_where_clause  := 'WHERE org_id = ' || p_org_id || ' ';
    x_where_clause  :=
         x_where_clause
      || 'AND txn_date between '
      || 'to_date('''
      || TO_CHAR(p_start_date, 'dd/mm/yyyy')
      || ''',''dd/mm/yyyy:hh24:mi:ss'')'
      || ' and to_date('''
      || TO_CHAR(p_end_date, 'dd/mm/yyyy')||':23:59:59'
      || ''',''dd/mm/yyyy:hh24:mi:ss'')'
      || ' ';
    /* only the collected txns are selected and not the ones generated by this process */
    x_where_clause  := x_where_clause || 'AND terr_id IS NULL ';


   IF (p_run_mode <> 'ALL') THEN
      /* loaded txns are not considered for crediting in NEW mode */
      /* commented this code and changed code to consider only the not credited transactions */
      /* x_where_clause  :=
               x_where_clause || 'AND load_status  IN (''ERROR - PRIOR ADJUSTMENT'', ''ERROR - TRX_TYPE'', ''ERROR - REVENUE_CLASS''
                                                       ,''ERROR - NO EXCH RATE GIVEN'', ''ERROR - INCORRECT CONV GIVEN'', ''ERROR - CANNOT CONV/DEFAULT''
                                                       ,''SALESREP ERROR'', ''PERIOD ERROR'', ''UNLOADED''
                                                       ,''CREDITED'', ''SCA_ALLOCATED'' ) '; */

        x_where_clause  := x_where_clause || 'AND load_status NOT IN ( ''CREDITED'' ) ';

    END IF;

    x_where_clause  :=
         x_where_clause
      || 'AND (adjust_status NOT IN (''FROZEN'', ''REVERSAL'')) ';
    /* donot select txns for which user has checked the "preserve credit override flag" to bypass crediting process */
    x_where_clause  :=
         x_where_clause
      || 'AND (preserve_credit_override_flag = ''N'') ';

    debugmsg('SCA : where clause : ' || x_where_clause);
    debugmsg('SCA : End of get_where_clause');
  EXCEPTION
    WHEN OTHERS THEN
      debugmsg('SCA : Unexpected exception in get_where_clause');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      retcode  := 2;
      errbuf   := 'CN_SCATM_TAE_PUB.get_where_clause.others';
  END get_where_clause;

  /* This procedure returns the flex field names that are used */
  /* in TM to store the split percentage and revenue type      */
  PROCEDURE get_flex_field_names(
    p_ffname_split_pctg OUT NOCOPY    VARCHAR2
  , p_ffname_rev_type   OUT NOCOPY    VARCHAR2
  , errbuf              IN OUT NOCOPY VARCHAR2
  , retcode             IN OUT NOCOPY VARCHAR2
  ) IS
    l_invalid_ffnames EXCEPTION;
  BEGIN
    debugmsg('SCA : Start of get_flex_field_names');
    errbuf   := NULL;
    retcode  := 0;

    /* Get the flex field name corresponding to split percentage */
    IF (fnd_profile.defined('CN_FFNAME_SPLIT_PCTG')) THEN
      p_ffname_split_pctg  := fnd_profile.VALUE('CN_FFNAME_SPLIT_PCTG');
    END IF;

    /* Get the flex field name corresponding to revenue type */
    IF (fnd_profile.defined('CN_FFNAME_REV_TYPE')) THEN
      p_ffname_rev_type  := fnd_profile.VALUE('CN_FFNAME_REV_TYPE');
    END IF;

    /* the two flex field names should not be same and they should one of the fields attribute1 .. 15 */
    IF (
           (
            p_ffname_split_pctg NOT IN
              (
               'ATTRIBUTE1'
             , 'ATTRIBUTE2'
             , 'ATTRIBUTE3'
             , 'ATTRIBUTE4'
             , 'ATTRIBUTE5'
             , 'ATTRIBUTE6'
             , 'ATTRIBUTE7'
             , 'ATTRIBUTE8'
             , 'ATTRIBUTE9'
             , 'ATTRIBUTE10'
             , 'ATTRIBUTE11'
             , 'ATTRIBUTE12'
             , 'ATTRIBUTE13'
             , 'ATTRIBUTE14'
             , 'ATTRIBUTE15'
              )
           )
        OR (
            p_ffname_rev_type NOT IN
              (
               'ATTRIBUTE1'
             , 'ATTRIBUTE2'
             , 'ATTRIBUTE3'
             , 'ATTRIBUTE4'
             , 'ATTRIBUTE5'
             , 'ATTRIBUTE6'
             , 'ATTRIBUTE7'
             , 'ATTRIBUTE8'
             , 'ATTRIBUTE9'
             , 'ATTRIBUTE10'
             , 'ATTRIBUTE11'
             , 'ATTRIBUTE12'
             , 'ATTRIBUTE13'
             , 'ATTRIBUTE14'
             , 'ATTRIBUTE15'
              )
           )
        OR (p_ffname_split_pctg = p_ffname_rev_type)
       ) THEN
      RAISE l_invalid_ffnames;
    END IF;

    debugmsg('SCA : Flex field name for split pctg : ' || p_ffname_split_pctg);
    debugmsg('SCA : Flex field name for revenue type : ' || p_ffname_rev_type);
    debugmsg('SCA : End of get_flex_field_names');
  EXCEPTION
    WHEN l_invalid_ffnames THEN
      debugmsg('SCA : Invalid flex field name specification');
      retcode  := 2;
      errbuf   := 'Invalid flex field name specification';
    WHEN OTHERS THEN
      debugmsg('SCA : Unexpected exception in get_flex_field_names');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      retcode  := 2;
      errbuf   := 'CN_SCATM_TAE_PUB.get_flex_field_names.others';
  END get_flex_field_names;

  /* This procedure marks the txns processed as CREDITED */
  PROCEDURE update_txns_processed(errbuf IN OUT NOCOPY VARCHAR2, retcode IN OUT NOCOPY VARCHAR2
  , p_worker_id IN NUMBER) IS
    l_no_of_records NUMBER;
  BEGIN
    debugmsg('SCA : Start of update_txns_processed');
    errbuf   := NULL;
    retcode  := 0;

    /* mark the transactions in the api table as CREDITED            */
    /* for which territory manager has returned a valid credited txn */

    UPDATE CN_COMM_LINES_API_ALL CLA
    SET LOAD_STATUS = 'CREDITED', ADJUST_STATUS = 'SCA_ALLOCATED'
    WHERE COMM_LINES_API_ID IN
     ( SELECT /*+ cardinality(a,1) */ TRANS_OBJECT_ID
       FROM   (
               select /*+ no_merge */ DISTINCT TRANS_OBJECT_ID
               from   JTF_TAE_1001_SC_WINNERS A
               where  A.WORKER_ID = p_worker_id
              ) A
       WHERE  EXISTS
             (
               select /*+ no_unest */ 1
               from   CN_COMM_LINES_API_ALL B
               where  B.ADJ_COMM_LINES_API_ID = A.TRANS_OBJECT_ID
               AND    B.TERR_ID IS NOT NULL
              )
     );


    debugmsg('SCA : End of update_txns_processed');
  EXCEPTION
    WHEN OTHERS THEN
      debugmsg('SCA : Unexpected exception in update_txns_processed');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      retcode  := 2;
      errbuf   := 'CN_SCATM_TAE_PUB.update_txns_processed.others';
  END update_txns_processed;

  /* This procedure inserts credited txns into api table */
  PROCEDURE insert_api_txns(
    p_org_id              IN            NUMBER
  , p_trans_object_id_tbl IN OUT NOCOPY g_trans_object_id_tbl_type
  , p_salesrep_id_tbl     IN OUT NOCOPY g_salesrep_id_tbl_type
  , p_emp_no_tbl          IN OUT NOCOPY g_emp_no_tbl_type
  , p_role_id_tbl         IN OUT NOCOPY g_role_id_tbl_type
  , p_split_pctg_tbl      IN OUT NOCOPY g_split_pctg_tbl_type
  , p_rev_type_tbl        IN OUT NOCOPY g_rev_type_tbl_type
  , p_terr_id_tbl         IN OUT NOCOPY g_terr_id_tbl_type
  , p_terr_name_tbl       IN OUT NOCOPY g_terr_name_tbl_type
  , p_del_flag_tbl        IN OUT NOCOPY g_del_flag_tbl_type
  , errbuf                IN OUT NOCOPY VARCHAR2
  , retcode               IN OUT NOCOPY VARCHAR2
  ) IS
    l_no_of_records NUMBER;
    l_error_index   NUMBER;
    ERRORS          NUMBER;
    dml_errors      EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
  BEGIN
    debugmsg('SCA : Start of insert_api_txns');
    errbuf           := NULL;
    retcode          := 0;
    l_no_of_records  := p_trans_object_id_tbl.COUNT;

    debugmsg('SCA : Number of rows to be inserted : ' || l_no_of_records);
    debugmsg('SCA : Start of insert_api_txns '||to_char(sysdate,'dd-mm-rrrr hh24:mi:ss'));
    IF (l_no_of_records > 0) THEN
      /* insert the credited transactions into api table */
      /* process all the rows even if some of them fail  */

    --     g_sca_insert_tbl_type := cn_sca_insert_tbl_type(cn_sca_insert_rec_type(1,1,1,1,1,1,1,1,1));
    --      FOR i IN p_trans_object_id_tbl.FIRST .. p_trans_object_id_tbl.LAST
    --      LOOP
    --         g_sca_insert_tbl_type.EXTEND;
    --         g_sca_insert_tbl_type(i) := cn_sca_insert_rec_type(p_trans_object_id_tbl(i)
    --                                                     , p_salesrep_id_tbl(i)
    --                                                     , p_emp_no_tbl(i)
    --                                                     , p_role_id_tbl(i)
    --                                                     , p_split_pctg_tbl(i)
    --                                                     , p_rev_type_tbl(i)
    --                                                     , p_terr_id_tbl(i)
    --                                                     , p_terr_name_tbl(i)
    --                                                     , p_del_flag_tbl(i));
    --      END LOOP;

        FORALL i IN p_trans_object_id_tbl.FIRST .. p_trans_object_id_tbl.LAST SAVE EXCEPTIONS
        INSERT INTO cn_comm_lines_api_all
                    (
                     salesrep_id
                   , processed_date
                   , processed_period_id
                   , transaction_amount
                   , trx_type
                   , revenue_class_id
                   , load_status
                   , attribute_category
                   , attribute1
                   , attribute2
                   , attribute3
                   , attribute4
                   , attribute5
                   , attribute6
                   , attribute7
                   , attribute8
                   , attribute9
                   , attribute10
                   , attribute11
                   , attribute12
                   , attribute13
                   , attribute14
                   , attribute15
                   , attribute16
                   , attribute17
                   , attribute18
                   , attribute19
                   , attribute20
                   , attribute21
                   , attribute22
                   , attribute23
                   , attribute24
                   , attribute25
                   , attribute26
                   , attribute27
                   , attribute28
                   , attribute29
                   , attribute30
                   , attribute31
                   , attribute32
                   , attribute33
                   , attribute34
                   , attribute35
                   , attribute36
                   , attribute37
                   , attribute38
                   , attribute39
                   , attribute40
                   , attribute41
                   , attribute42
                   , attribute43
                   , attribute44
                   , attribute45
                   , attribute46
                   , attribute47
                   , attribute48
                   , attribute49
                   , attribute50
                   , attribute51
                   , attribute52
                   , attribute53
                   , attribute54
                   , attribute55
                   , attribute56
                   , attribute57
                   , attribute58
                   , attribute59
                   , attribute60
                   , attribute61
                   , attribute62
                   , attribute63
                   , attribute64
                   , attribute65
                   , attribute66
                   , attribute67
                   , attribute68
                   , attribute69
                   , attribute70
                   , attribute71
                   , attribute72
                   , attribute73
                   , attribute74
                   , attribute75
                   , attribute76
                   , attribute77
                   , attribute78
                   , attribute79
                   , attribute80
                   , attribute81
                   , attribute82
                   , attribute83
                   , attribute84
                   , attribute85
                   , attribute86
                   , attribute87
                   , attribute88
                   , attribute89
                   , attribute90
                   , attribute91
                   , attribute92
                   , attribute93
                   , attribute94
                   , attribute95
                   , attribute96
                   , attribute97
                   , attribute98
                   , attribute99
                   , attribute100
                   , comm_lines_api_id
                   , conc_batch_id
                   , process_batch_id
                   , salesrep_number
                   , rollup_date
                   , source_doc_id
                   , source_doc_type
                   , created_by
                   , creation_date
                   , last_updated_by
                   , last_update_date
                   , last_update_login
                   , transaction_currency_code
                   , exchange_rate
                   , acctd_transaction_amount
                   , trx_id
                   , trx_line_id
                   , trx_sales_line_id
                   , quantity
                   , source_trx_number
                   , discount_percentage
                   , margin_percentage
                   , source_trx_id
                   , source_trx_line_id
                   , source_trx_sales_line_id
                   , negated_flag
                   , customer_id
                   , inventory_item_id
                   , order_number
                   , booked_date
                   , invoice_number
                   , invoice_date
                   , adjust_date
                   , adjusted_by
                   , revenue_type
                   , adjust_rollup_flag
                   , adjust_comments
                   , adjust_status
                   , line_number
                   , bill_to_address_id
                   , ship_to_address_id
                   , bill_to_contact_id
                   , ship_to_contact_id
                   , adj_comm_lines_api_id
                   , pre_defined_rc_flag
                   , rollup_flag
                   , forecast_id
                   , upside_quantity
                   , upside_amount
                   , uom_code
                   , reason_code
                   , TYPE
                   , pre_processed_code
                   , quota_id
                   , srp_plan_assign_id
                   , role_id
                   , comp_group_id
                   , commission_amount
                   , employee_number
                   , reversal_flag
                   , reversal_header_id
                   , sales_channel
                   , object_version_number
                   , split_pct
                   , split_status
                   , org_id
                   , terr_id
                   , terr_name
                   , preserve_credit_override_flag -- to ensure this is not null
                    )
          SELECT p_salesrep_id_tbl(i) -- parent.salesrep_id
               , ccla.processed_date
               , ccla.processed_period_id
               , ROUND(NVL((ccla.transaction_amount * p_split_pctg_tbl(i)) / 100, 0), 2)  -- parent.split_percentage
               , ccla.trx_type
               , ccla.revenue_class_id
               , 'UNLOADED'
               , ccla.attribute_category
               , ccla.attribute1
               , ccla.attribute2
               , ccla.attribute3
               , ccla.attribute4
               , ccla.attribute5
               , ccla.attribute6
               , ccla.attribute7
               , ccla.attribute8
               , ccla.attribute9
               , ccla.attribute10
               , ccla.attribute11
               , ccla.attribute12
               , ccla.attribute13
               , ccla.attribute14
               , ccla.attribute15
               , ccla.attribute16
               , ccla.attribute17
               , ccla.attribute18
               , ccla.attribute19
               , ccla.attribute20
               , ccla.attribute21
               , ccla.attribute22
               , ccla.attribute23
               , ccla.attribute24
               , ccla.attribute25
               , ccla.attribute26
               , ccla.attribute27
               , ccla.attribute28
               , ccla.attribute29
               , ccla.attribute30
               , ccla.attribute31
               , ccla.attribute32
               , ccla.attribute33
               , ccla.attribute34
               , ccla.attribute35
               , ccla.attribute36
               , ccla.attribute37
               , ccla.attribute38
               , ccla.attribute39
               , ccla.attribute40
               , ccla.attribute41
               , ccla.attribute42
               , ccla.attribute43
               , ccla.attribute44
               , ccla.attribute45
               , ccla.attribute46
               , ccla.attribute47
               , ccla.attribute48
               , ccla.attribute49
               , ccla.attribute50
               , ccla.attribute51
               , ccla.attribute52
               , ccla.attribute53
               , ccla.attribute54
               , ccla.attribute55
               , ccla.attribute56
               , ccla.attribute57
               , ccla.attribute58
               , ccla.attribute59
               , ccla.attribute60
               , ccla.attribute61
               , ccla.attribute62
               , ccla.attribute63
               , ccla.attribute64
               , ccla.attribute65
               , ccla.attribute66
               , ccla.attribute67
               , ccla.attribute68
               , ccla.attribute69
               , ccla.attribute70
               , ccla.attribute71
               , ccla.attribute72
               , ccla.attribute73
               , ccla.attribute74
               , ccla.attribute75
               , ccla.attribute76
               , ccla.attribute77
               , ccla.attribute78
               , ccla.attribute79
               , ccla.attribute80
               , ccla.attribute81
               , ccla.attribute82
               , ccla.attribute83
               , ccla.attribute84
               , ccla.attribute85
               , ccla.attribute86
               , ccla.attribute87
               , ccla.attribute88
               , ccla.attribute89
               , ccla.attribute90
               , ccla.attribute91
               , ccla.attribute92
               , ccla.attribute93
               , ccla.attribute94
               , ccla.attribute95
               , ccla.attribute96
               , ccla.attribute97
               , ccla.attribute98
               , ccla.attribute99
               , ccla.attribute100
               , cn_comm_lines_api_s.NEXTVAL
               , ccla.conc_batch_id
               , ccla.process_batch_id
               , NULL
               , ccla.rollup_date
               , ccla.source_doc_id
               , ccla.source_doc_type
               , g_user_id
               , g_sysdate
               , g_user_id
               , g_sysdate
               , g_login_id
               , ccla.transaction_currency_code
               , ccla.exchange_rate
               , NULL
               , ccla.trx_id
               , ccla.trx_line_id
               , ccla.trx_sales_line_id
               , ccla.quantity
               , ccla.source_trx_number
               , ccla.discount_percentage
               , ccla.margin_percentage
               , ccla.source_trx_id
               , ccla.source_trx_line_id
               , ccla.source_trx_sales_line_id
               , ccla.negated_flag
               , ccla.customer_id
               , ccla.inventory_item_id
               , ccla.order_number
               , ccla.booked_date
               , ccla.invoice_number
               , ccla.invoice_date
               , g_sysdate
               , g_user_id
               , p_rev_type_tbl(i)  -- parent.revenue_type
               , ccla.adjust_rollup_flag
               , 'Created by TAE'
               , ccla.adjust_status
               , ccla.line_number
               , ccla.bill_to_address_id
               , ccla.ship_to_address_id
               , ccla.bill_to_contact_id
               , ccla.ship_to_contact_id
               , ccla.comm_lines_api_id
               , ccla.pre_defined_rc_flag
               , ccla.rollup_flag
               , ccla.forecast_id
               , ccla.upside_quantity
               , ccla.upside_amount
               , ccla.uom_code
               , ccla.reason_code
               , ccla.TYPE
               , ccla.pre_processed_code
               , ccla.quota_id
               , ccla.srp_plan_assign_id
               , p_role_id_tbl(i)  -- parent.role_id
               , ccla.comp_group_id
               , ccla.commission_amount
               , p_emp_no_tbl(i) -- parent.employee_number
               , ccla.reversal_flag
               , ccla.reversal_header_id
               , ccla.sales_channel
               , ccla.object_version_number
               , p_split_pctg_tbl(i) -- parent.split_percentage
               , ccla.split_status
               , ccla.org_id
               , p_terr_id_tbl(i) -- parent.terr_id
               , p_terr_name_tbl(i) -- parent.terr_name
               , 'N'  -- to ensure preserve_credit_override_flag is not null
            FROM cn_comm_lines_api_all ccla
           WHERE ccla.comm_lines_api_id = p_trans_object_id_tbl(i)
             AND ccla.org_id = p_org_id
             AND p_del_flag_tbl(i) <> 'Y';

 --, table ( cast ( cn_sca_credits_batch_pub.convert_to_table()
--                                                            as cn_sca_insert_tbl_type)) parent
  --         WHERE ccla.comm_lines_api_id = parent.trans_object_id
    --         AND ccla.org_id = p_org_id
      --       AND parent.del_flag <> 'Y';

    END IF;
    debugmsg('SCA : End of insert_api_txns '||to_char(sysdate,'dd-mm-rrrr hh24:mi:ss'));
    debugmsg('SCA : End of insert_api_txns');
  EXCEPTION
    WHEN dml_errors THEN
      ERRORS  := SQL%BULK_EXCEPTIONS.COUNT;
      debugmsg('SCA : Number of transactions that failed : ' || ERRORS);

      /* Log the erroneous txns to log file */
      FOR i IN 1 .. ERRORS LOOP
        l_error_index  := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
        debugmsg(
             'SCA : Error #'
          || i
          || ' occurred during comm_lines_api_id : '
          || p_trans_object_id_tbl(l_error_index)
        );
        debugmsg('SCA : Error message is ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
      END LOOP;
    WHEN OTHERS THEN
      debugmsg('SCA : Unexpected exception in insert_api_txns');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      retcode  := 2;
      errbuf   := 'CN_SCATM_TAE_PUB.insert_api_txns.others';
  END insert_api_txns;

  /* This procedure calls the territory APIs and get the winning */
  /* salesreps and split percentages for each transaction        */
  PROCEDURE get_credited_txns(
    p_where_clause IN            VARCHAR2
  , p_request_id   IN            NUMBER
  , errbuf         IN OUT NOCOPY VARCHAR2
  , retcode        IN OUT NOCOPY VARCHAR2
  , p_start_date   IN            DATE
  , p_end_date     IN            DATE
  , p_org_id       IN            NUMBER
  , p_run_mode     IN            VARCHAR2
  , p_terr_id      IN            NUMBER
  ) IS
    l_return_status              VARCHAR2(30);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(3000);
    lp_start_date                DATE;
    lp_end_date                  DATE;
    l_child_program_id_tbl       sub_program_id_type;
    l_collect_txn_num_workers    NUMBER;
    l_num_of_days                NUMBER;
    l_date_span                  NUMBER;
    l_where_clause               VARCHAR2(1000);
    child_proc_fail_exception    EXCEPTION;

    l_req_id                     NUMBER;

  BEGIN
    debugmsg('SCA : Start of get_credited_txns');
    errbuf   := NULL;
    retcode  := 0;
    l_collect_txn_num_workers := 0;

    debugmsg('SCA : Populating data to TRANS table');

    get_where_clause(
      p_start_date                 => p_start_date
    , p_end_date                   => p_end_date
    , p_org_id                     => p_org_id
    , p_run_mode                   => p_run_mode
    , x_where_clause               => l_where_clause
    , errbuf                       => errbuf
    , retcode                      => retcode
    );

    /* insert the selected transactions from cn_comm_lines_api_all table */
    /* to the interface table jtf_tae_1001_sc_dea_trans                  */
    jty_assign_bulk_pub.collect_trans_data(
      p_api_version_number         => 1.0
    , p_init_msg_list              => fnd_api.g_false
    , p_source_id                  => -1001
    , p_trans_id                   => -1002
    , p_program_name               => 'SALES/INCENTIVE COMPENSATION PROGRAM'
    , p_mode                       => 'DATE EFFECTIVE'
    , p_where                      => l_where_clause
    , p_no_of_workers              => g_num_workers
    , p_percent_analyzed           => 20
    ,   -- this value can be either a profile option or a parameter to conc program
      p_request_id                 => p_request_id
    ,   -- request id of the concurrent program
      x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , errbuf                       => errbuf
    , retcode                      => retcode
    , p_oic_mode                   => 'CLEAR'
    );

    IF (retcode <> 0) THEN
      debugmsg('SCA : jty_assign_bulk_pub.collect_trans_data has failed');
      RAISE fnd_api.g_exc_error;
    END IF;

    debugmsg('SCA : jty_assign_bulk_pub.collect_trans_data with mode CLEAR '||
    ' completed successfully. ');

    lp_start_date := p_start_date;
    lp_end_date   := p_end_date;

    l_child_program_id_tbl := sub_program_id_type();
    l_date_span   :=   (p_end_date - p_start_date);

    if(l_date_span <=  g_num_workers) then
        l_num_of_days := 1;
    else
        l_num_of_days :=  round(l_date_span/g_num_workers);
    end if;

    WHILE trunc(lp_start_date) < ( p_end_date + 1)
    LOOP
       l_collect_txn_num_workers := l_collect_txn_num_workers +1;

       if(l_collect_txn_num_workers > g_num_workers) Then
         exit;
       end if;

       lp_end_date := trunc(lp_start_date) + (l_num_of_days-1);

       IF ((lp_end_date > p_end_date) or (l_collect_txn_num_workers = g_num_workers))
       THEN
          lp_end_date :=p_end_date;
       END IF;

       IF g_num_workers = 1
       THEN
          lp_end_date :=p_end_date;
       END IF;

       debugmsg('SCA:lp_start_date  ' || to_char(lp_start_date, 'DD-MON-YY:hh:mm:ss'));
       debugmsg('SCA:lp_end_date ' || to_char(lp_end_date, 'DD-MON-YY:hh:mm:ss'));
       debugmsg('SCA : Submitting Child Request '|| l_collect_txn_num_workers ||
                 ' for start date = '||lp_start_date ||' and end_date = '||lp_end_date);


       l_req_id := FND_REQUEST.SUBMIT_REQUEST('CN', -- Application
                                       'CN_SCATM_COLLECT_TRANS_BATCH'	  , -- Concurrent Program
                                       '', -- description
                                       '', -- start time
                                       FALSE -- sub request flag
                                      ,lp_start_date
                                      ,lp_end_date
                                      , p_org_id
                                      , p_run_mode
                                      ,g_num_workers
                                      ,p_request_id
                                        );
       COMMIT;

       lp_start_date := lp_end_date  + 1;

       IF  l_req_id = 0 THEN
          retcode := 2;
          errbuf := fnd_message.get;
          raise child_proc_fail_exception;
       ELSE
          -- storing the request ids in an array
          l_child_program_id_tbl.EXTEND;
          l_child_program_id_tbl(l_child_program_id_tbl.LAST):=l_req_id;
       END IF;
     END LOOP;

     debugmsg('SCA : CN_SCATM_TAE_PUB.Parent Process starts Waiting For Collect Transaction
     Child Processes to complete');

     parent_conc_wait(l_child_program_id_tbl,retcode,errbuf);

     COMMIT;

     IF retcode = 2
     THEN
        raise fnd_api.g_exc_error;
     END IF;

    /* insert the selected transactions from cn_comm_lines_api_all table */
    /* to the interface table jtf_tae_1001_sc_dea_trans                  */
    jty_assign_bulk_pub.collect_trans_data(
      p_api_version_number         => 1.0
    , p_init_msg_list              => fnd_api.g_false
    , p_source_id                  => -1001
    , p_trans_id                   => -1002
    , p_program_name               => 'SALES/INCENTIVE COMPENSATION PROGRAM'
    , p_mode                       => 'DATE EFFECTIVE'
    , p_where                      => l_where_clause
    , p_no_of_workers              => g_num_workers
    , p_percent_analyzed           => 20
    ,   -- this value can be either a profile option or a parameter to conc program
      p_request_id                 => p_request_id
    ,   -- request id of the concurrent program
      x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , errbuf                       => errbuf
    , retcode                      => retcode
    , p_oic_mode                   => 'POST'
    );

    IF (retcode <> 0) THEN
      debugmsg('SCA : jty_assign_bulk_pub.collect_trans_data has failed');
      RAISE fnd_api.g_exc_error;
    END IF;

    debugmsg('SCA : jty_assign_bulk_pub.collect_trans_data with oic_mode '||
    'POST completed successfully');
    debugmsg('SCA : Populating data to WINNERS table');
    /* this api will apply the rules to the transactions present in jtf_tae_1001_sc_dea_trans       */
    /* and populate the winning salesreps for each transaction in the table jtf_tae_1001_sc_winners */
    FOR l_worker_id IN 1..g_num_workers
    LOOP

       debugmsg('SCA : Submitting Child Request for worker id '|| l_worker_id
       ||' with p_oic_mode as MATCH/POPULATE' );

       l_req_id := FND_REQUEST.SUBMIT_REQUEST('CN', -- Application
                                       'CN_SCATM_PROCESS_WINNERS_BATCH'	  , -- Concurrent Program
                                       '', -- description
                                       '', -- start time
                                       FALSE -- sub request flag
                                      , l_worker_id
                                      , 'MATCH/POPULATE' -- p_oic_mode
									  , p_terr_id);

       COMMIT;

       IF  l_req_id = 0 THEN
          retcode := 2;
          errbuf := fnd_message.get;
          raise child_proc_fail_exception;
       ELSE
          -- storing the request ids in an array
          l_child_program_id_tbl.EXTEND;
          l_child_program_id_tbl(l_child_program_id_tbl.LAST):=l_req_id;
       END IF;

    debugmsg('SCA : CN_SCATM_TAE_PUB.Parent Process starts Waiting For Child Get Winners
    Processes to complete');

    END LOOP;

    parent_conc_wait(l_child_program_id_tbl,retcode,errbuf);
    COMMIT;

    IF retcode = 2
    THEN
       raise fnd_api.g_exc_error;
    END IF;

   debugmsg('SCA : CN_SCATM_TAE_PUB. Process_Match successful, now will generate stats ');

    batch_process_winners(
     errbuf       => errbuf
   , retcode      => retcode
   , p_worker_id  =>  0
   , p_oic_mode   => 'MATCH/POST'
   , p_terr_id    => p_terr_id
   );

   IF (retcode <> 0) THEN
      debugmsg('SCA : jty_assign_bulk_pub.collect_trans_data has failed while '||
      ' trying to generate stats on matches table ');
      RAISE fnd_api.g_exc_error;
    END IF;

  debugmsg('SCA : CN_SCATM_TAE_PUB. Generate stats on matches table successful');

    --Code added here to handle process_match and process_winners index stats
    -- in parallel
        debugmsg('SCA : Populating data to WINNERS table');
    /* this api will apply the rules to the transactions present in jtf_tae_1001_sc_dea_trans       */
    /* and populate the winning salesreps for each transaction in the table jtf_tae_1001_sc_winners */
    FOR l_worker_id IN 1..g_num_workers
    LOOP

       debugmsg('SCA : Submitting Child Request for worker id '|| l_worker_id);

       l_req_id := FND_REQUEST.SUBMIT_REQUEST('CN', -- Application
                                       'CN_SCATM_PROCESS_WINNERS_BATCH'	  , -- Concurrent Program
                                       '', -- description
                                       '', -- start time
                                       FALSE -- sub request flag
                                      ,l_worker_id
                                      , 'WINNER/POPULATE' -- p_oic_mode
									  , p_terr_id);
       COMMIT;

       IF  l_req_id = 0 THEN
          retcode := 2;
          errbuf := fnd_message.get;
          raise child_proc_fail_exception;
       ELSE
          -- storing the request ids in an array
          l_child_program_id_tbl.EXTEND;
          l_child_program_id_tbl(l_child_program_id_tbl.LAST):=l_req_id;
       END IF;

     debugmsg('SCA : CN_SCATM_TAE_PUB.Parent Process starts Waiting For Child Get Winners
     Processes to complete');

    END LOOP;

    parent_conc_wait(l_child_program_id_tbl,retcode,errbuf);
    COMMIT;

    IF retcode = 2
    THEN
       raise fnd_api.g_exc_error;
    END IF;


    debugmsg('SCA : CN_SCATM_TAE_PUB. Process_winners successful, now will generate stats ');

    batch_process_winners(
     errbuf       => errbuf
   , retcode      => retcode
   , p_worker_id  =>  0
   , p_oic_mode   => 'WINNER/POST'
   , p_terr_id	  => p_terr_id
   );


   IF (retcode <> 0) THEN
      debugmsg('SCA : jty_assign_bulk_pub.collect_trans_data has failed while '||
      ' trying to generate stats on winners table ');
      RAISE fnd_api.g_exc_error;
    END IF;
    -- End of Addition
    debugmsg('SCA : jty_assign_bulk_pub.generate stats on winners successful');
    debugmsg('SCA : jty_assign_bulk_pub.get_winners completed successfully');
    debugmsg('SCA : End of get_credited_txns');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.get_credited_txns.g_exc_error');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
    WHEN child_proc_fail_exception THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.get_credited_txns.Child Proc Failed exception');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
    WHEN OTHERS THEN
      debugmsg('SCA : Unexpected exception in get_credited_txns');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      retcode  := 2;
      errbuf   := 'CN_SCATM_TAE_PUB.get_credited_txns.others';
  END get_credited_txns;

  /* This procedure gets the winning salesreps, split percentages and revenue types from the           */
  /* table jtf_tae_1001_sc_winners and create credited transactions in the table cn_comm_lines_api_all */
  PROCEDURE process_new_txns(
    p_org_id IN            NUMBER
  , p_worker_id IN NUMBER
  , errbuf   IN OUT NOCOPY VARCHAR2
  , retcode  IN OUT NOCOPY VARCHAR2
  ) IS
    TYPE l_credited_txn_curtyp IS REF CURSOR;

    c_credited_txn_cur    l_credited_txn_curtyp;
    l_ffname_split_pctg   VARCHAR2(15);
    l_ffname_rev_type     VARCHAR2(15);
    l_no_of_errors        NUMBER;
    l_trans_object_id_tbl g_trans_object_id_tbl_type;
    l_terr_id_tbl         g_terr_id_tbl_type;
    l_terr_name_tbl       g_terr_name_tbl_type;
    l_salesrep_id_tbl     g_salesrep_id_tbl_type;
    l_emp_no_tbl          g_emp_no_tbl_type;
    l_role_id_tbl         g_role_id_tbl_type;
    l_split_pctg_tbl      g_split_pctg_tbl_type;
    l_rev_type_tbl        g_rev_type_tbl_type;
    l_del_flag_tbl        g_del_flag_tbl_type;
  BEGIN
    debugmsg('SCA : Start of process_new_txns');
    errbuf   := NULL;
    retcode  := 0;
    /* Get name of the flex fields used in TM */
    /* to store split pctg and revenue type   */
    get_flex_field_names(
      p_ffname_split_pctg          => l_ffname_split_pctg
    , p_ffname_rev_type            => l_ffname_rev_type
    , errbuf                       => errbuf
    , retcode                      => retcode
    );

    IF (retcode <> 0) THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.get_flex_field_names has failed');
      RAISE fnd_api.g_exc_error;
    END IF;

    debugmsg('SCA :  CN_SCATM_TAE_PUB.get_flex_field_names completed successfully');

    /* Cursor definition to select all winning resources from winners table */
    OPEN c_credited_txn_cur
     FOR    'SELECT /*+ leading(a) cardinality(a,100) */ a.trans_object_id, '
         || '       a.terr_id,         '
         || '       c.name,            '
         || '       d.salesrep_id,     '
         || '       d.employee_number, '
         || '       a.role_id,         '
         || '       ''N'',             '
         || '       b.'
         || l_ffname_split_pctg
         || ', '
         || '       b.'
         || l_ffname_rev_type
         || ' '
         || 'FROM   jtf_tae_1001_sc_winners a, '
         || '       jtf_terr_rsc_all        b, '
         || '       jtf_terr_all            c, '
         || '       cn_salesreps            d  '
         || 'WHERE  a.terr_rsc_id = b.terr_rsc_id '
         || 'AND    a.terr_id     = c.terr_id '
         || 'AND    a.resource_id = d.resource_id '
         || 'AND    a.worker_id = '||p_worker_id;

    /* loop through the winning resources in batches , "g_fetch_limit" records per batch, */
    /* and insert the records in the table cn_comm_lines_api_all                          */
    LOOP
      FETCH c_credited_txn_cur
      BULK COLLECT INTO l_trans_object_id_tbl
           , l_terr_id_tbl
           , l_terr_name_tbl
           , l_salesrep_id_tbl
           , l_emp_no_tbl
           , l_role_id_tbl
           , l_del_flag_tbl
           , l_split_pctg_tbl
           , l_rev_type_tbl LIMIT g_fetch_limit;

      EXIT WHEN l_trans_object_id_tbl.COUNT <= 0;
      debugmsg('SCA : Number of winning rows returned : ' || l_trans_object_id_tbl.COUNT);
      /* insert the credited txns into api table */
      insert_api_txns(
        p_org_id                     => p_org_id
      , p_trans_object_id_tbl        => l_trans_object_id_tbl
      , p_salesrep_id_tbl            => l_salesrep_id_tbl
      , p_emp_no_tbl                 => l_emp_no_tbl
      , p_role_id_tbl                => l_role_id_tbl
      , p_split_pctg_tbl             => l_split_pctg_tbl
      , p_rev_type_tbl               => l_rev_type_tbl
      , p_terr_id_tbl                => l_terr_id_tbl
      , p_terr_name_tbl              => l_terr_name_tbl
      , p_del_flag_tbl               => l_del_flag_tbl
      , errbuf                       => errbuf
      , retcode                      => retcode
      );

      IF (retcode <> 0) THEN
        debugmsg('SCA : CN_SCATM_TAE_PUB.insert_api_txns has failed');
        RAISE fnd_api.g_exc_error;
      END IF;

      debugmsg('SCA : CN_SCATM_TAE_PUB.insert_api_txns completed successfully');
    END LOOP;

    CLOSE c_credited_txn_cur;

    debugmsg('SCA : End of process_new_txns');
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF c_credited_txn_cur%ISOPEN THEN
        CLOSE c_credited_txn_cur;
      END IF;

      debugmsg('SCA : CN_SCATM_TAE_PUB.process_new_txns.g_exc_error');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
    WHEN OTHERS THEN
      IF c_credited_txn_cur%ISOPEN THEN
        CLOSE c_credited_txn_cur;
      END IF;

      debugmsg('SCA : Unexpected exception in process_new_txns');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      retcode  := 2;
      errbuf   := 'CN_SCATM_TAE_PUB.process_new_txns.others';
  END process_new_txns;

  /* This procedure does the following for txns that have been loaded for calc */
  /*         -- obsolete the corresponding record in cn_commission_headers_all */
  /*         -- create a reversal entry in cn_comm_lines_api_all               */
  PROCEDURE api_negate_record(
    p_api_id_tbl IN OUT NOCOPY g_comm_lines_api_id_tbl_type
  , p_rowid_tbl  IN OUT NOCOPY g_rowid_tbl_type
  , errbuf       IN OUT NOCOPY VARCHAR2
  , retcode      IN OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    debugmsg('SCA : Start of api_negate_record');
    errbuf   := NULL;
    retcode  := 0;

    IF (p_api_id_tbl.COUNT <= 0) THEN
      RETURN;
    END IF;

    /* create the reversal entry in api table */
    FORALL i IN p_rowid_tbl.FIRST .. p_rowid_tbl.LAST
      INSERT INTO cn_comm_lines_api_all
                  (
                   salesrep_id
                 , processed_date
                 , processed_period_id
                 , transaction_amount
                 , trx_type
                 , revenue_class_id
                 , load_status
                 , attribute_category
                 , attribute1
                 , attribute2
                 , attribute3
                 , attribute4
                 , attribute5
                 , attribute6
                 , attribute7
                 , attribute8
                 , attribute9
                 , attribute10
                 , attribute11
                 , attribute12
                 , attribute13
                 , attribute14
                 , attribute15
                 , attribute16
                 , attribute17
                 , attribute18
                 , attribute19
                 , attribute20
                 , attribute21
                 , attribute22
                 , attribute23
                 , attribute24
                 , attribute25
                 , attribute26
                 , attribute27
                 , attribute28
                 , attribute29
                 , attribute30
                 , attribute31
                 , attribute32
                 , attribute33
                 , attribute34
                 , attribute35
                 , attribute36
                 , attribute37
                 , attribute38
                 , attribute39
                 , attribute40
                 , attribute41
                 , attribute42
                 , attribute43
                 , attribute44
                 , attribute45
                 , attribute46
                 , attribute47
                 , attribute48
                 , attribute49
                 , attribute50
                 , attribute51
                 , attribute52
                 , attribute53
                 , attribute54
                 , attribute55
                 , attribute56
                 , attribute57
                 , attribute58
                 , attribute59
                 , attribute60
                 , attribute61
                 , attribute62
                 , attribute63
                 , attribute64
                 , attribute65
                 , attribute66
                 , attribute67
                 , attribute68
                 , attribute69
                 , attribute70
                 , attribute71
                 , attribute72
                 , attribute73
                 , attribute74
                 , attribute75
                 , attribute76
                 , attribute77
                 , attribute78
                 , attribute79
                 , attribute80
                 , attribute81
                 , attribute82
                 , attribute83
                 , attribute84
                 , attribute85
                 , attribute86
                 , attribute87
                 , attribute88
                 , attribute89
                 , attribute90
                 , attribute91
                 , attribute92
                 , attribute93
                 , attribute94
                 , attribute95
                 , attribute96
                 , attribute97
                 , attribute98
                 , attribute99
                 , attribute100
                 , comm_lines_api_id
                 , conc_batch_id
                 , process_batch_id
                 , salesrep_number
                 , rollup_date
                 , source_doc_id
                 , source_doc_type
                 , created_by
                 , creation_date
                 , last_updated_by
                 , last_update_date
                 , last_update_login
                 , transaction_currency_code
                 , exchange_rate
                 , acctd_transaction_amount
                 , trx_id
                 , trx_line_id
                 , trx_sales_line_id
                 , quantity
                 , source_trx_number
                 , discount_percentage
                 , margin_percentage
                 , source_trx_id
                 , source_trx_line_id
                 , source_trx_sales_line_id
                 , negated_flag
                 , customer_id
                 , inventory_item_id
                 , order_number
                 , booked_date
                 , invoice_number
                 , invoice_date
                 , adjust_date
                 , adjusted_by
                 , revenue_type
                 , adjust_rollup_flag
                 , adjust_comments
                 , adjust_status
                 , line_number
                 , bill_to_address_id
                 , ship_to_address_id
                 , bill_to_contact_id
                 , ship_to_contact_id
                 , adj_comm_lines_api_id
                 , pre_defined_rc_flag
                 , rollup_flag
                 , forecast_id
                 , upside_quantity
                 , upside_amount
                 , uom_code
                 , reason_code
                 , TYPE
                 , pre_processed_code
                 , quota_id
                 , srp_plan_assign_id
                 , role_id
                 , comp_group_id
                 , commission_amount
                 , employee_number
                 , reversal_flag
                 , reversal_header_id
                 , sales_channel
                 , object_version_number
                 , split_pct
                 , split_status
                 , org_id
                 , terr_id
                 , terr_name
                  )
        SELECT ccla.salesrep_id
             , ccla.processed_date
             , ccla.processed_period_id
             , -1 * NVL(ccla.transaction_amount, 0)
             , ccla.trx_type
             , ccla.revenue_class_id
             , 'UNLOADED'
             , ccla.attribute_category
             , ccla.attribute1
             , ccla.attribute2
             , ccla.attribute3
             , ccla.attribute4
             , ccla.attribute5
             , ccla.attribute6
             , ccla.attribute7
             , ccla.attribute8
             , ccla.attribute9
             , ccla.attribute10
             , ccla.attribute11
             , ccla.attribute12
             , ccla.attribute13
             , ccla.attribute14
             , ccla.attribute15
             , ccla.attribute16
             , ccla.attribute17
             , ccla.attribute18
             , ccla.attribute19
             , ccla.attribute20
             , ccla.attribute21
             , ccla.attribute22
             , ccla.attribute23
             , ccla.attribute24
             , ccla.attribute25
             , ccla.attribute26
             , ccla.attribute27
             , ccla.attribute28
             , ccla.attribute29
             , ccla.attribute30
             , ccla.attribute31
             , ccla.attribute32
             , ccla.attribute33
             , ccla.attribute34
             , ccla.attribute35
             , ccla.attribute36
             , ccla.attribute37
             , ccla.attribute38
             , ccla.attribute39
             , ccla.attribute40
             , ccla.attribute41
             , ccla.attribute42
             , ccla.attribute43
             , ccla.attribute44
             , ccla.attribute45
             , ccla.attribute46
             , ccla.attribute47
             , ccla.attribute48
             , ccla.attribute49
             , ccla.attribute50
             , ccla.attribute51
             , ccla.attribute52
             , ccla.attribute53
             , ccla.attribute54
             , ccla.attribute55
             , ccla.attribute56
             , ccla.attribute57
             , ccla.attribute58
             , ccla.attribute59
             , ccla.attribute60
             , ccla.attribute61
             , ccla.attribute62
             , ccla.attribute63
             , ccla.attribute64
             , ccla.attribute65
             , ccla.attribute66
             , ccla.attribute67
             , ccla.attribute68
             , ccla.attribute69
             , ccla.attribute70
             , ccla.attribute71
             , ccla.attribute72
             , ccla.attribute73
             , ccla.attribute74
             , ccla.attribute75
             , ccla.attribute76
             , ccla.attribute77
             , ccla.attribute78
             , ccla.attribute79
             , ccla.attribute80
             , ccla.attribute81
             , ccla.attribute82
             , ccla.attribute83
             , ccla.attribute84
             , ccla.attribute85
             , ccla.attribute86
             , ccla.attribute87
             , ccla.attribute88
             , ccla.attribute89
             , ccla.attribute90
             , ccla.attribute91
             , ccla.attribute92
             , ccla.attribute93
             , ccla.attribute94
             , ccla.attribute95
             , ccla.attribute96
             , ccla.attribute97
             , ccla.attribute98
             , ccla.attribute99
             , ccla.attribute100
             , cn_comm_lines_api_s.NEXTVAL
             , NULL
             , NULL
             , NULL
             , ccla.rollup_date
             , NULL
             , ccla.source_doc_type
             , g_user_id
             , g_sysdate
             , g_user_id
             , g_sysdate
             , g_login_id
             , ccla.transaction_currency_code
             , ccla.exchange_rate
             , -1 * NVL(ccla.acctd_transaction_amount, 0)
             , NULL
             , NULL
             , NULL
             , -1 * ccla.quantity
             , ccla.source_trx_number
             , ccla.discount_percentage
             , ccla.margin_percentage
             , ccla.source_trx_id
             , ccla.source_trx_line_id
             , ccla.source_trx_sales_line_id
             , 'Y'
             , ccla.customer_id
             , ccla.inventory_item_id
             , ccla.order_number
             , ccla.booked_date
             , ccla.invoice_number
             , ccla.invoice_date
             , g_sysdate
             , g_user_id
             , ccla.revenue_type
             , ccla.adjust_rollup_flag
             , 'Created by TAE'
             , 'REVERSAL'
             , ccla.line_number
             , ccla.bill_to_address_id
             , ccla.ship_to_address_id
             , ccla.bill_to_contact_id
             , ccla.ship_to_contact_id
             , ccla.comm_lines_api_id
             , ccla.pre_defined_rc_flag
             , ccla.rollup_flag
             , ccla.forecast_id
             , ccla.upside_quantity
             , ccla.upside_amount
             , ccla.uom_code
             , ccla.reason_code
             , ccla.TYPE
             , ccla.pre_processed_code
             , ccla.quota_id
             , ccla.srp_plan_assign_id
             , ccla.role_id
             , ccla.comp_group_id
             , ccla.commission_amount
             , ccla.employee_number
             , 'Y'
             , ccha.commission_header_id
             , ccla.sales_channel
             , ccla.object_version_number
             , ccla.split_pct
             , ccla.split_status
             , ccla.org_id
             , ccla.terr_id
             , ccla.terr_name
          FROM cn_comm_lines_api ccla, cn_commission_headers_all ccha
         WHERE ccla.ROWID = p_rowid_tbl(i)
           AND ccha.comm_lines_api_id = ccla.comm_lines_api_id
           AND (ccha.adjust_status NOT IN('FROZEN', 'REVERSAL')) --OR(adjust_status IS NULL))
           AND ccha.trx_type NOT IN('ITD', 'GRP', 'THR');
    /* update the corresponding records in commission_headers */
    FORALL i IN p_api_id_tbl.FIRST .. p_api_id_tbl.LAST
      UPDATE cn_commission_headers
         SET adjust_status = 'FROZEN'
           , reversal_header_id =
               (SELECT commission_header_id
                  FROM cn_commission_headers_all
                 WHERE comm_lines_api_id = p_api_id_tbl(i)
                   AND (adjust_status NOT IN('FROZEN', 'REVERSAL'))-- OR(adjust_status IS NULL))
                   AND trx_type NOT IN('ITD', 'GRP', 'THR'))
           , reversal_flag = 'Y'
           , adjust_date = g_sysdate
           , adjusted_by = g_user_id
           , adjust_comments = 'Created by SCA'
           , last_update_date = g_sysdate
           , last_updated_by = g_user_id
           , last_update_login = g_login_id
       WHERE comm_lines_api_id = p_api_id_tbl(i);
    debugmsg('SCA : End of api_negate_record');
  EXCEPTION
    WHEN OTHERS THEN
      debugmsg('SCA : Unexpected exception in api_negate_record');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      retcode  := 2;
      errbuf   := 'CN_SCATM_TAE_PUB.api_negate_record.others';
  END api_negate_record;

  /* This procedure deletes the child transaction records      */
  /* from api table which have not been loaded for calculation */
  PROCEDURE handle_unloaded_txns(
    l_unloaded_txn_tbl IN OUT NOCOPY g_rowid_tbl_type
  , p_rowid       IN            ROWID
  , p_update_flag IN            BOOLEAN
  , errbuf        IN OUT NOCOPY VARCHAR2
  , retcode       IN OUT NOCOPY VARCHAR2
  ) IS
    l_no_of_records NUMBER;
  BEGIN
    debugmsg('SCA : Start of handle_unloaded_txns');
    errbuf           := NULL;
    retcode          := 0;

    /* Store the txn in the global pl/sql table if a valid txn is passed */
    IF (p_rowid IS NOT NULL) THEN
      l_unloaded_txn_tbl.EXTEND;
      l_unloaded_txn_tbl(l_unloaded_txn_tbl.LAST)  := p_rowid;
    END IF;

    l_no_of_records  := l_unloaded_txn_tbl.COUNT;

    /* change DB if the # of records in the pl/sql table becomes greater than        */
    /* "g_fetch_limit" or if the procedure is called exclusively to update the table */
    IF (l_no_of_records > 0) THEN
      IF ((l_no_of_records >= g_fetch_limit) OR(p_update_flag)) THEN
        FORALL i IN l_unloaded_txn_tbl.FIRST .. l_unloaded_txn_tbl.LAST
          DELETE      cn_comm_lines_api_all
                WHERE ROWID = l_unloaded_txn_tbl(i);
        l_unloaded_txn_tbl.TRIM(l_no_of_records);
      END IF;
    END IF;

    debugmsg('SCA : End of handle_unloaded_txns');
  EXCEPTION
    WHEN OTHERS THEN
      debugmsg('SCA : Unexpected exception in handle_unloaded_txns');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      retcode  := 2;
      errbuf   := 'CN_SCATM_TAE_PUB.handle_unloaded_txns.others';
  END handle_unloaded_txns;

  /* This procedure processes the child transactions that have been loaded for calc */
  PROCEDURE handle_loaded_txns(
    l_loaded_txn_rowid_tbl IN OUT NOCOPY g_rowid_tbl_type
  , l_loaded_txn_comid_tbl IN OUT NOCOPY g_comm_lines_api_id_tbl_type
  , p_rowid       IN            ROWID
  , p_api_id      IN            NUMBER
  , p_update_flag IN            BOOLEAN
  , errbuf        IN OUT NOCOPY VARCHAR2
  , retcode       IN OUT NOCOPY VARCHAR2
  ) IS
    l_no_of_records NUMBER;
  BEGIN
    debugmsg('SCA : Start of handle_loaded_txns');
    errbuf           := NULL;
    retcode          := 0;

    /* Store the txn in the global pl/sql table if a valid txn is passed */
    IF (p_rowid IS NOT NULL) THEN
      l_loaded_txn_rowid_tbl.EXTEND;
      l_loaded_txn_rowid_tbl(l_loaded_txn_rowid_tbl.LAST)  := p_rowid;
      l_loaded_txn_comid_tbl.EXTEND;
      l_loaded_txn_comid_tbl(l_loaded_txn_comid_tbl.LAST)  := p_api_id;
    END IF;

    l_no_of_records  := l_loaded_txn_rowid_tbl.COUNT;

    /* change DB if the # of records in the pl/sql table becomes greater than        */
    /* "g_fetch_limit" or if the procedure is called exclusively to update the table */
    IF (l_no_of_records > 0) THEN
      IF ((l_no_of_records >= g_fetch_limit) OR(p_update_flag)) THEN
        api_negate_record(
          p_api_id_tbl                 => l_loaded_txn_comid_tbl
        , p_rowid_tbl                  => l_loaded_txn_rowid_tbl
        , errbuf                       => errbuf
        , retcode                      => retcode
        );

        IF (retcode <> 0) THEN
          debugmsg('SCA : CN_SCATM_TAE_PUB.api_negate_record has failed');
          RAISE fnd_api.g_exc_error;
        END IF;

        debugmsg('SCA : CN_SCATM_TAE_PUB.api_negate_record completed successfully');
        l_loaded_txn_rowid_tbl.TRIM(l_no_of_records);
        l_loaded_txn_comid_tbl.TRIM(l_no_of_records);
      END IF;
    END IF;

    debugmsg('SCA : End of handle_loaded_txns');
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.handle_loaded_txns.g_exc_error');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
    WHEN OTHERS THEN
      debugmsg('SCA : Unexpected exception in handle_loaded_txns');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      retcode  := 2;
      errbuf   := 'CN_SCATM_TAE_PUB.handle_loaded_txns.others';
  END handle_loaded_txns;

  /* This procedure gets the winning salesreps, split percentages and revenue types from the           */
  /* table jtf_tae_1001_sc_winners and create credited transactions in the table cn_comm_lines_api_all */
  PROCEDURE process_all_txns(
    p_org_id IN            NUMBER
  , p_worker_id IN NUMBER
  , errbuf   IN OUT NOCOPY VARCHAR2
  , retcode  IN OUT NOCOPY VARCHAR2
  ) IS
    TYPE l_credited_txn_curtyp IS REF CURSOR;

    TYPE l_txn_amt_tbl_type IS TABLE OF cn_comm_lines_api_all.transaction_amount%TYPE;

    TYPE l_no_of_credits_tbl_type IS TABLE OF NUMBER;

    TYPE l_child_load_status_tbl_type IS TABLE OF cn_comm_lines_api_all.load_status%TYPE;

    c_credited_txn_cur      l_credited_txn_curtyp;
    l_ffname_split_pctg     VARCHAR2(15);
    l_ffname_rev_type       VARCHAR2(15);
    l_error_index           NUMBER;
    l_table_index           NUMBER;
    l_no_of_credits         NUMBER;
    l_api_id                NUMBER;
    l_rows_fetched          NUMBER;
    l_match_found           BOOLEAN;
    l_txn_amt               NUMBER;
    l_temp_index            NUMBER;
    l_no_of_errors          NUMBER;
    l_rowid_tbl             g_rowid_tbl_type;
    l_api_id_tbl            g_trans_object_id_tbl_type;
    l_terr_id_tbl           g_terr_id_tbl_type;
    l_terr_name_tbl         g_terr_name_tbl_type;
    l_salesrep_id_tbl       g_salesrep_id_tbl_type;
    l_emp_no_tbl            g_emp_no_tbl_type;
    l_role_id_tbl           g_role_id_tbl_type;
    l_txn_amt_tbl           l_txn_amt_tbl_type;
    l_split_pctg_tbl        g_split_pctg_tbl_type;
    l_rev_type_tbl          g_rev_type_tbl_type;
    l_del_flag_tbl          g_del_flag_tbl_type;
    l_no_of_credits_tbl     l_no_of_credits_tbl_type;
    l_child_rowid_tbl       g_rowid_tbl_type;
    l_child_api_id_tbl      g_trans_object_id_tbl_type;
    l_child_salesrep_id_tbl g_salesrep_id_tbl_type;
    l_child_txn_amt_tbl     l_txn_amt_tbl_type;
    l_child_role_id_tbl     g_role_id_tbl_type;
    l_child_terr_id_tbl     g_terr_id_tbl_type;
    l_child_split_pctg_tbl  g_split_pctg_tbl_type;
    l_child_rev_type_tbl    g_rev_type_tbl_type;
    l_child_load_status_tbl l_child_load_status_tbl_type;

    l_unloaded_txn_tbl     g_rowid_tbl_type;
    l_loaded_txn_rowid_tbl  g_rowid_tbl_type;
    l_loaded_txn_comid_tbl g_comm_lines_api_id_tbl_type;

    l_count NUMBER; -- Added for bug 8538923

    CURSOR get_child_records (p_api_id NUMBER) IS
    --     SELECT     ROWID
    --                 , comm_lines_api_id
    --                 , load_status
    --                 , salesrep_id
    --                 , transaction_amount
    --                 , role_id
    --                 , terr_id
    --                 , split_pct
    --                 , revenue_type
    --              FROM cn_comm_lines_api_all
    --             WHERE load_status NOT IN('OBSOLETE', 'FILTERED')
    --               AND adjust_status NOT IN('FROZEN', 'REVERSAL')
    --               AND comm_lines_api_id = p_api_id
    --      UNION ALL
      SELECT     ROWID
                 , comm_lines_api_id
                 , load_status
                 , salesrep_id
                 , transaction_amount
                 , role_id
                 , terr_id
                 , split_pct
                 , revenue_type
              FROM cn_comm_lines_api_all
             WHERE load_status NOT IN('OBSOLETE', 'FILTERED')
               AND adjust_status NOT IN('FROZEN', 'REVERSAL')
               START WITH COMM_LINES_API_ID = p_api_id
               CONNECT BY PRIOR COMM_LINES_API_ID = ADJ_COMM_LINES_API_ID;

    --Added the cursor below for bug 	8538923
    CURSOR get_child_records_for_rev_txns (
    p_api_id NUMBER,
    p_revenue_type cn_comm_lines_api_all.REVENUE_TYPE%TYPE,
    p_split_pct  cn_comm_lines_api_all.SPLIT_PCT%TYPE,
    p_terr_id  cn_comm_lines_api_all.TERR_ID%TYPE,
    p_role_id  cn_comm_lines_api_all.ROLE_ID%TYPE,
    p_transaction_amount  cn_comm_lines_api_all.TRANSACTION_AMOUNT%TYPE,
    p_salesrep_id  cn_comm_lines_api_all.SALESREP_ID%TYPE
    ) IS
      SELECT  count(*)
              FROM cn_comm_lines_api_all
             WHERE load_status NOT IN('OBSOLETE', 'FILTERED')
               AND salesrep_id= p_salesrep_id
               AND transaction_amount = -1*p_transaction_amount
               AND NVL(role_id, -1) = p_role_id
               AND terr_id = p_terr_id
               AND split_pct= p_split_pct
               AND revenue_type =p_revenue_type
               START WITH COMM_LINES_API_ID = p_api_id
               CONNECT BY PRIOR COMM_LINES_API_ID = ADJ_COMM_LINES_API_ID;

  BEGIN
    debugmsg('SCA : Start of process_all_txns');

    -- initialise the tables
    l_unloaded_txn_tbl     := g_rowid_tbl_type();
    l_loaded_txn_rowid_tbl := g_rowid_tbl_type();
    l_loaded_txn_comid_tbl := g_comm_lines_api_id_tbl_type();

    errbuf   := NULL;
    retcode  := 0;
    /* Get name of the flex fields used in TM */
    /* to store split pctg and revenue type   */
    get_flex_field_names(
      p_ffname_split_pctg          => l_ffname_split_pctg
    , p_ffname_rev_type            => l_ffname_rev_type
    , errbuf                       => errbuf
    , retcode                      => retcode
    );

    IF (retcode <> 0) THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.get_flex_field_names has failed');
      RAISE fnd_api.g_exc_error;
    END IF;

    debugmsg('SCA :  CN_SCATM_TAE_PUB.get_flex_field_names completed successfully');

    /* Cursor definition to get all the winning resources returned by TAE */
    OPEN c_credited_txn_cur
     FOR    'SELECT /*+ leading ( a ) cardinality ( a , 100 ) use_nl(a e.s e.re.b) */  d.rowid,                                        '
         || '       d.comm_lines_api_id,                            '
         || '       a.terr_id,                                      '
         || '       c.name,                                         '
         || '       e.salesrep_id,                                  '
         || '       e.employee_number,                              '
         || '       a.role_id,                                      '
         || '       d.transaction_amount,                           '
         || '       b.'
         || l_ffname_split_pctg
         || ',                '
         || '       b.'
         || l_ffname_rev_type
         || ',                  '
         || '       ''N'',                                          '
         || '       count(*) over(partition by d.comm_lines_api_id) '
         || 'FROM   jtf_tae_1001_sc_winners a, '
         || '       jtf_terr_rsc_all        b, '
         || '       jtf_terr_all            c, '
         || '       cn_comm_lines_api_all   d, '
         || '       cn_salesreps            e  '
         || 'WHERE  a.terr_rsc_id = b.terr_rsc_id           '
         || 'AND    a.terr_id = c.terr_id                   '
         || 'AND    a.trans_object_id = d.comm_lines_api_id '
         || 'AND    a.resource_id = e.resource_id '
         || 'AND    a.worker_id = '||p_worker_id
         || 'ORDER BY d.comm_lines_api_id ';

    /* loop through the winning resources in batches , "g_fetch_limit" records per batch, */
    /* and insert the records in the table cn_comm_lines_api_all                          */
    LOOP
      FETCH c_credited_txn_cur
      BULK COLLECT INTO l_rowid_tbl
           , l_api_id_tbl
           , l_terr_id_tbl
           , l_terr_name_tbl
           , l_salesrep_id_tbl
           , l_emp_no_tbl
           , l_role_id_tbl
           , l_txn_amt_tbl
           , l_split_pctg_tbl
           , l_rev_type_tbl
           , l_del_flag_tbl
           , l_no_of_credits_tbl LIMIT g_fetch_limit;

      EXIT WHEN l_rowid_tbl.COUNT <= 0;
      debugmsg('SCA : Number of winning rows returned : ' || l_rowid_tbl.COUNT);
      /* Start Code to make sure that the winning records of a  */
      /* particular transactions are not fetched across batches */
      debugmsg('SCA : Start of fetching remaining winning records for last txn');
      l_table_index    := l_rowid_tbl.LAST;
      l_no_of_credits  := l_no_of_credits_tbl(l_table_index);
      l_api_id         := l_api_id_tbl(l_table_index);
      l_rows_fetched   := 0;

      /* Get the number of rows fetched for the last transaction */
      LOOP
        l_rows_fetched  := l_rows_fetched + 1;

        IF (
               (l_rows_fetched = l_no_of_credits)
            OR (l_table_index = l_rowid_tbl.FIRST)
            OR (l_api_id <> l_api_id_tbl(l_table_index - 1))
           ) THEN
          EXIT;
        END IF;

        /* go to previous row */
        l_table_index   := l_table_index - 1;
      END LOOP;

      /* fetch the remaining winning records for the last transaction */
      FOR i IN 1 ..(l_no_of_credits - l_rows_fetched) LOOP
        l_rowid_tbl.EXTEND;
        l_api_id_tbl.EXTEND;
        l_terr_id_tbl.EXTEND;
        l_terr_name_tbl.EXTEND;
        l_salesrep_id_tbl.EXTEND;
        l_emp_no_tbl.EXTEND;
        l_role_id_tbl.EXTEND;
        l_txn_amt_tbl.EXTEND;
        l_split_pctg_tbl.EXTEND;
        l_rev_type_tbl.EXTEND;
        l_del_flag_tbl.EXTEND;
        l_no_of_credits_tbl.EXTEND;

        FETCH c_credited_txn_cur
         INTO l_rowid_tbl(l_rowid_tbl.LAST)
            , l_api_id_tbl(l_api_id_tbl.LAST)
            , l_terr_id_tbl(l_terr_id_tbl.LAST)
            , l_terr_name_tbl(l_terr_name_tbl.LAST)
            , l_salesrep_id_tbl(l_salesrep_id_tbl.LAST)
            , l_emp_no_tbl(l_emp_no_tbl.LAST)
            , l_role_id_tbl(l_role_id_tbl.LAST)
            , l_txn_amt_tbl(l_txn_amt_tbl.LAST)
            , l_split_pctg_tbl(l_split_pctg_tbl.LAST)
            , l_rev_type_tbl(l_rev_type_tbl.LAST)
            , l_del_flag_tbl(l_del_flag_tbl.LAST)
            , l_no_of_credits_tbl(l_no_of_credits_tbl.LAST);
      END LOOP;   /* end loop for */

      debugmsg('SCA : End of fetching remaining winning records for last txn');
      /* End Code to make sure that the winning records of a  */
      /* particular transactions are not fetched across batches */

      /* Process all the winning records row by row */
      l_table_index    := l_rowid_tbl.FIRST;

      LOOP
        /* exit after we have processed the last row */
        IF (l_table_index > l_rowid_tbl.LAST) THEN
          EXIT;
        END IF;

        -- debugmsg('SCA : Now processing transaction with id : ' || l_api_id_tbl(l_table_index));

        /* Get all children of the transaction which are  */
        /* active and generated by this crediting process */
             OPEN get_child_records (l_api_id_tbl(l_table_index));
             FETCH get_child_records  BULK COLLECT INTO
                    l_child_rowid_tbl
                  , l_child_api_id_tbl
                  , l_child_load_status_tbl
                  , l_child_salesrep_id_tbl
                  , l_child_txn_amt_tbl
                  , l_child_role_id_tbl
                  , l_child_terr_id_tbl
                  , l_child_split_pctg_tbl
                  , l_child_rev_type_tbl;
             CLOSE get_child_records;

        IF (l_child_rowid_tbl.COUNT > 0) THEN
          FOR i IN l_child_rowid_tbl.FIRST .. l_child_rowid_tbl.LAST LOOP
            --debugmsg('SCA : Now processing child transaction with id : ' || l_child_api_id_tbl(i));

            /* if the child has not been loaded for calculation   */
            /* delete the child record from cn_comm_lines_api_all */
            IF (l_child_load_status_tbl(i) <> 'LOADED') THEN
              /* delete the row if it is not the same txn that we have processed */
              IF (
                      (l_child_api_id_tbl(i) <> l_api_id_tbl(l_table_index))
                  AND (l_child_terr_id_tbl(i) IS NOT NULL) --IS NOT NULL
                 ) THEN



                  /* start of code : logic used here is  similar to used  for loaded tansaction. Reference bug 7589796    */
                  l_match_found  := FALSE;

                  /* check to see if the child matches with any of the credited transaction              */
                  /* if so, donot obsolete the child instead donot insert the new credited txn generated */
                  FOR j IN 1 .. l_no_of_credits_tbl(l_table_index) LOOP
                    l_temp_index  := l_table_index +(j - 1);

					IF( l_temp_index > l_rowid_tbl.LAST) THEN
					 EXIT;
					END IF;

                    /* update txn amt to -1 if user either has not specified anything for split pctg */
                    /* or has specified an invalid chaaracter (anything other than numbers) for it   */
                    BEGIN
                      IF (l_split_pctg_tbl(l_temp_index) IS NULL) THEN
                        l_txn_amt  := -1;
                      ELSE
                        l_txn_amt  :=
                          ROUND(
                            NVL((l_txn_amt_tbl(l_temp_index) * l_split_pctg_tbl(l_temp_index)) / 100, 0)
                          , 2
                          );
                      END IF;
                    EXCEPTION
                      WHEN VALUE_ERROR THEN
                        l_txn_amt  := -1;
                      WHEN OTHERS THEN
                        RAISE;
                    END;

                    IF (
                            (l_child_salesrep_id_tbl(i) = l_salesrep_id_tbl(l_temp_index))
                        AND (l_child_txn_amt_tbl(i) = l_txn_amt)
                       -- AND (l_child_role_id_tbl(i) = l_role_id_tbl(l_temp_index))
                        AND (nvl(l_child_role_id_tbl(i),-1) = nvl(l_role_id_tbl(l_temp_index),-1))  -- Fix for bug 7298004
                        AND (l_child_terr_id_tbl(i) = l_terr_id_tbl(l_temp_index))
                        AND (l_child_split_pctg_tbl(i) = l_split_pctg_tbl(l_temp_index))
                        AND (l_child_rev_type_tbl(i) = l_rev_type_tbl(l_temp_index))
                        AND (l_del_flag_tbl(l_temp_index) = 'N')
                       ) THEN
                      /* if a match is found then exit the loop after marking the newly generated */
                      /* credited txn not to be inserted in the api table                         */

                        l_del_flag_tbl(l_temp_index)  := 'Y';
                        l_match_found                 := TRUE;
                        EXIT;
                    END IF;
                  END LOOP;

                  IF (NOT l_match_found) THEN
                 /*   debugmsg
                      (
                         'SCA : Calling CN_SCATM_TAE_PUB.handle_unloaded_txns for child transaction : '
                      || l_child_api_id_tbl(i)
                    ); */
                    handle_unloaded_txns(
                     l_unloaded_txn_tbl
                    , p_rowid                      => l_child_rowid_tbl(i)
                    , p_update_flag                => FALSE
                    , errbuf                       => errbuf
                    , retcode                      => retcode
                    );

                    IF (retcode <> 0) THEN
                      --debugmsg('SCA : CN_SCATM_TAE_PUB.handle_unloaded_txns has failed');
                      RAISE fnd_api.g_exc_error;
                    END IF;

                    --debugmsg('SCA : CN_SCATM_TAE_PUB.handle_unloaded_txns completed successfully');
                  END IF;
                 /* end of code : logic used here is  similar to  used  for loaded tansactions. Reference bug 7589796    */
              END IF;
            ELSE
              /* if the child has been loaded for calculation */
              l_match_found  := FALSE;

              /* check to see if the child matches with any of the credited transaction              */
              /* if so, donot obsolete the child instead donot insert the new credited txn generated */
              FOR j IN 1 .. l_no_of_credits_tbl(l_table_index) LOOP
                l_temp_index  := l_table_index +(j - 1);

				  IF( l_temp_index > l_rowid_tbl.LAST) THEN
					 EXIT;
				  END IF;

                /* update txn amt to -1 if user either has not specified anything for split pctg */
                /* or has specified an invalid chaaracter (anything other than numbers) for it   */
                BEGIN
                  IF (l_split_pctg_tbl(l_temp_index) IS NULL) THEN
                    l_txn_amt  := -1;
                  ELSE
                    l_txn_amt  :=
                      ROUND(
                        NVL((l_txn_amt_tbl(l_temp_index) * l_split_pctg_tbl(l_temp_index)) / 100, 0)
                      , 2
                      );
                  END IF;
                EXCEPTION
                  WHEN VALUE_ERROR THEN
                    l_txn_amt  := -1;
                  WHEN OTHERS THEN
                    RAISE;
                END;

                IF (
                        (l_child_salesrep_id_tbl(i) = l_salesrep_id_tbl(l_temp_index))
                    AND (l_child_txn_amt_tbl(i) = l_txn_amt)
                   -- AND (l_child_role_id_tbl(i) = l_role_id_tbl(l_temp_index))
                    AND (nvl(l_child_role_id_tbl(i),-1) = nvl(l_role_id_tbl(l_temp_index),-1))  -- Fix for bug 7298004
                    AND (l_child_terr_id_tbl(i) = l_terr_id_tbl(l_temp_index))
                    AND (l_child_split_pctg_tbl(i) = l_split_pctg_tbl(l_temp_index))
                    AND (l_child_rev_type_tbl(i) = l_rev_type_tbl(l_temp_index))
                    AND (l_del_flag_tbl(l_temp_index) = 'N')
                   ) THEN
                  /* if a match is found then exit the loop after marking the newly generated */
                  /* credited txn not to be inserted in the api table                         */

                  --Modified the flow for  bug 	8538923
                   OPEN get_child_records_for_rev_txns (
                   l_child_api_id_tbl(i) ,
                   l_child_rev_type_tbl(i),
                   l_child_split_pctg_tbl(i),
                   l_child_terr_id_tbl(i),
                   nvl(l_child_role_id_tbl(i),-1),
                   l_child_txn_amt_tbl(i),
                   l_child_salesrep_id_tbl(i));

                   FETCH get_child_records_for_rev_txns INTO l_count;

                   IF l_count = 0
                   THEN

                     l_del_flag_tbl(l_temp_index)  := 'Y';
                     l_match_found                 := TRUE;
                     CLOSE get_child_records_for_rev_txns;
                     EXIT;

                   END IF;

                 CLOSE get_child_records_for_rev_txns;

                END IF;
              END LOOP;

              IF (NOT l_match_found) THEN
                /* if no match is found then create reversal entry */
              /*  debugmsg
                   (
                     'SCA : Calling CN_SCATM_TAE_PUB.handle_loaded_txns for child transaction : '
                  || l_child_api_id_tbl(i)
                ); */
                handle_loaded_txns(
                   l_loaded_txn_rowid_tbl => l_loaded_txn_rowid_tbl
                , l_loaded_txn_comid_tbl => l_loaded_txn_comid_tbl
                , p_rowid                      => l_child_rowid_tbl(i)
                , p_api_id                     => l_child_api_id_tbl(i)
                , p_update_flag                => FALSE
                , errbuf                       => errbuf
                , retcode                      => retcode
                );

                IF (retcode <> 0) THEN
                  debugmsg('SCA : CN_SCATM_TAE_PUB.handle_loaded_txns has failed');
                  RAISE fnd_api.g_exc_error;
                END IF;

                debugmsg('SCA : CN_SCATM_TAE_PUB.handle_loaded_txns completed successfully');
              END IF;
            END IF;   /* end if load_status <> 'LOADED' */
          END LOOP;   /* end processing all the children */
        END IF;   /* end if l_child_rowid_tbl.COUNT > 0 */

        /* increase the table index to point to the next transaction */
        l_table_index  := l_table_index + l_no_of_credits_tbl(l_table_index);
      END LOOP;   /* end loop processing winning records row by row */

      /* Make changes to DB for unloaded txns present in the PL/SQL table */
      debugmsg('SCA : Calling CN_SCATM_TAE_PUB.handle_unloaded_txns');
      handle_unloaded_txns(l_unloaded_txn_tbl => l_unloaded_txn_tbl,
      p_rowid   => NULL, p_update_flag => TRUE, errbuf => errbuf
      , retcode                      => retcode);

      IF (retcode <> 0) THEN
        debugmsg('SCA : CN_SCATM_TAE_PUB.handle_unloaded_txns has failed');
        RAISE fnd_api.g_exc_error;
      END IF;

      debugmsg('SCA : CN_SCATM_TAE_PUB.handle_unloaded_txns completed successfully');
      /* Make changes to DB for loaded txns present in the PL/SQL table */
      debugmsg('SCA : Calling CN_SCATM_TAE_PUB.handle_loaded_txns');
      handle_loaded_txns(
        l_loaded_txn_rowid_tbl => l_loaded_txn_rowid_tbl
      , l_loaded_txn_comid_tbl => l_loaded_txn_comid_tbl
      , p_rowid                      => NULL
      , p_api_id                     => NULL
      , p_update_flag                => TRUE
      , errbuf                       => errbuf
      , retcode                      => retcode
      );

      IF (retcode <> 0) THEN
        debugmsg('SCA : CN_SCATM_TAE_PUB.handle_loaded_txns has failed');
        RAISE fnd_api.g_exc_error;
      END IF;

      debugmsg('SCA : CN_SCATM_TAE_PUB.handle_loaded_txns completed successfully');
      /* insert the credited txns into api table */
      insert_api_txns(
        p_org_id                     => p_org_id
      , p_trans_object_id_tbl        => l_api_id_tbl
      , p_salesrep_id_tbl            => l_salesrep_id_tbl
      , p_emp_no_tbl                 => l_emp_no_tbl
      , p_role_id_tbl                => l_role_id_tbl
      , p_split_pctg_tbl             => l_split_pctg_tbl
      , p_rev_type_tbl               => l_rev_type_tbl
      , p_terr_id_tbl                => l_terr_id_tbl
      , p_terr_name_tbl              => l_terr_name_tbl
      , p_del_flag_tbl               => l_del_flag_tbl
      , errbuf                       => errbuf
      , retcode                      => retcode
      );

      IF (retcode <> 0) THEN
        debugmsg('SCA : CN_SCATM_TAE_PUB.insert_api_txns has failed');
        RAISE fnd_api.g_exc_error;
      END IF;

      debugmsg('SCA : CN_SCATM_TAE_PUB.insert_api_txns completed successfully');
    END LOOP;   /* end loop fetch winning records */

    CLOSE c_credited_txn_cur;

    debugmsg('SCA : End of process_all_txns');
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF c_credited_txn_cur%ISOPEN THEN
        CLOSE c_credited_txn_cur;
      END IF;

      debugmsg('SCA : CN_SCATM_TAE_PUB.process_all_txns.g_exc_error');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
    WHEN OTHERS THEN
      IF c_credited_txn_cur%ISOPEN THEN
        CLOSE c_credited_txn_cur;
      END IF;

      debugmsg('SCA : Unexpected exception in process_all_txns');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      retcode  := 2;
      errbuf   := 'CN_SCATM_TAE_PUB.process_all_txns.others';
  END process_all_txns;

  /* Entry point of credit allocation process */
  PROCEDURE get_assignments(
    errbuf       OUT NOCOPY    VARCHAR2
  , retcode      OUT NOCOPY    VARCHAR2
  , p_org_id     IN            NUMBER
  , p_start_date IN            VARCHAR2
  , p_end_date   IN            VARCHAR2
  , p_run_mode   IN            VARCHAR2
  , p_terr_id    IN            NUMBER DEFAULT NULL
  ) IS
    l_start_date         DATE;
    l_end_date           DATE;
    l_process_audit_id   NUMBER;
    l_where_clause       VARCHAR2(1000);
    l_skip_credit_flag   VARCHAR2(1);
    l_count              NUMBER;
    l_invalid_run_mode   EXCEPTION;
    l_skip_crediting     EXCEPTION;
    l_invalid_date_range EXCEPTION;

    l_req_id NUMBER;

    l_child_program_id_tbl sub_program_id_type;

    l_phase  VARCHAR2(100);
    l_status VARCHAR2(100);
    l_dev_phase VARCHAR2(100);
    l_dev_status VARCHAR2(100);
    l_message VARCHAR2(1000);
    call_status boolean;

    child_proc_fail_exception exception;

  BEGIN
    retcode                 := 0;
    errbuf                  := NULL;
    /* Convert the dates for the varchar2 parameters passed in from concurrent program */
    l_start_date            := fnd_date.canonical_to_date(p_start_date);
    l_end_date              := fnd_date.canonical_to_date(p_end_date);
    /* Call begin_batch to get process_audit_id for debug log file */
    cn_message_pkg.begin_batch(
      x_process_type               => 'SCATM'
    , x_parent_proc_audit_id       => NULL
    , x_process_audit_id           => l_process_audit_id
    , x_request_id                 => fnd_global.conc_request_id
    , p_org_id                     => p_org_id
    );
    debugmsg('SCA : Start of Credit Allocation using TM');
    debugmsg('SCA : process_audit_id is ' || l_process_audit_id);
    /* Continue only if the profile "OIC: Skip Credit Allocation" is set to No */
    l_skip_credit_flag      := 'Y';

    IF (fnd_profile.defined('CN_SKIP_CREDIT_ALLOCATION')) THEN
      l_skip_credit_flag  := fnd_profile.VALUE('CN_SKIP_CREDIT_ALLOCATION');
    END IF;

    IF (l_skip_credit_flag <> 'N') THEN
      debugmsg('SCA : Profile OIC: Skip Credit Allocation is set to Yes');
      retcode  := 1;
      errbuf   := 'SCA : Profile OIC: Skip Credit Allocation is set to Yes';
      RAISE l_skip_crediting;
    END IF;

    /* run mode should be either NEW or ALL */
    IF ((p_run_mode <> 'NEW') AND(p_run_mode <> 'ALL')) THEN
      debugmsg('SCA : Invalid Run Mode');
      retcode  := 2;
      errbuf   := 'Inavlid Run Mode parameter value';
      RAISE l_invalid_run_mode;
    END IF;

    /* Verify that the start date is within open period */
    l_count                 := 0;

    SELECT COUNT(*)
      INTO l_count
      FROM cn_acc_period_statuses_v acc
     WHERE TRUNC(l_start_date) BETWEEN TRUNC(acc.start_date) AND TRUNC(acc.end_date)
       AND acc.period_status = 'O'
       AND acc.org_id = p_org_id
       AND ROWNUM = 1;

    IF (l_count = 0) THEN
      debugmsg('SCA : Start Date is not within open period');
      retcode  := 2;
      errbuf   := 'Start Date is not within open period';
      RAISE l_invalid_date_range;
    END IF;

    /* Verify that the end date is within open period */
    l_count                 := 0;

    SELECT COUNT(*)
      INTO l_count
      FROM cn_acc_period_statuses_v acc
     WHERE TRUNC(l_end_date) BETWEEN TRUNC(acc.start_date) AND TRUNC(acc.end_date)
       AND acc.period_status = 'O'
       AND acc.org_id = p_org_id
       AND ROWNUM = 1;

    IF (l_count = 0) THEN
      debugmsg('SCA : End Date is not within open period');
      retcode  := 2;
      errbuf   := 'End Date is not within open period';
      RAISE l_invalid_date_range;
    END IF;

    /* Initialize global pl/sql tables */
    g_unloaded_txn_tbl      := g_rowid_tbl_type();
    g_loaded_txn_rowid_tbl  := g_rowid_tbl_type();
    g_loaded_txn_comid_tbl  := g_comm_lines_api_id_tbl_type();

    SELECT TO_NUMBER(NVL(fnd_profile.value('CN_NUMBER_OF_WORKERS'),1)) INTO g_num_workers
    FROM dual;

    IF g_num_workers < 1
    THEN
      g_num_workers := 1;
   /* ELSIF g_num_workers > 10
    THEN
      g_num_workers :=10;*/
    END IF;

    debugmsg('SCA : CN_SCATM_TAE_PUB.Number of Workers '||g_num_workers);

    debugmsg('SCA : CN_SCATM_TAE_PUB.get_where_clause completed successfully');
    /* Call the territory APIs and get the winning salesreps */
    /* and split percentages for each transaction            */
    get_credited_txns(
      p_where_clause               => l_where_clause
    , p_request_id                 => g_request_id
    , errbuf                       => errbuf
    , retcode                      => retcode
    , p_start_date                 => l_start_date
    , p_end_date                   => l_end_date
    , p_org_id                     => p_org_id
    , p_run_mode                   => p_run_mode
	, p_terr_id					   => p_terr_id
    );

    IF (retcode <> 0) THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.get_credited_txns has failed');
      RAISE fnd_api.g_exc_error;
    END IF;

    debugmsg('SCA : CN_SCATM_TAE_PUB.get_credited_txns completed successfully');

    l_child_program_id_tbl := sub_program_id_type();

    FOR l_worker_id IN 1..g_num_workers
    LOOP

    l_req_id := FND_REQUEST.SUBMIT_REQUEST('CN', -- Application
  				     'CN_SCATM_CRED_ALLOC_TXN_BATCH'	  , -- Concurrent Program
				     '', -- description
				     '', -- start time
                                     FALSE, -- sub request flag
                                     p_org_id, -- Parameters Org Id
                                     p_run_mode, --Parameter Run Mode
                                     l_worker_id -- parameter worker id
                                      );
     COMMIT;

     IF  l_req_id =0
     THEN

        retcode := 2;
        errbuf := fnd_message.get;
        raise child_proc_fail_exception;

     ELSE
        -- storing the request ids in an array
        l_child_program_id_tbl.EXTEND;
        l_child_program_id_tbl(l_child_program_id_tbl.LAST):=l_req_id;

     END IF;


     END LOOP;

     debugmsg('SCA : CN_SCATM_TAE_PUB.Parent Process starts Waiting For Child
     Processes to complete');

     parent_conc_wait(l_child_program_id_tbl,retcode,errbuf);

     COMMIT;

     IF retcode = 2
     THEN
        debugmsg('SCA : CN_SCATM_TAE_PUB.update_txns_processed has failed');
        raise fnd_api.g_exc_error;
     END IF;

/* update the txns processed in api table */
  --  update_txns_processed(errbuf => errbuf, retcode => retcode);

    IF (retcode <> 0) THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.update_txns_processed has failed');
      RAISE fnd_api.g_exc_error;
    END IF;

    debugmsg('SCA : CN_SCATM_TAE_PUB.update_txns_processed completed successfully');
    -- Call end_batch to end debug log file
    debugmsg('SCA : CN_SCATM_TAE_PUB. Parent Process Complete Successfully at '||CURRENT_TIMESTAMP);
    debugmsg('SCA : End of SCATM');
    cn_message_pkg.end_batch(l_process_audit_id);
    COMMIT;
  EXCEPTION
    WHEN l_invalid_date_range THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.get_assignments.l_invalid_date_range');
      debugmsg('SCA : End of SCATM');
      cn_message_pkg.end_batch(l_process_audit_id);
    WHEN l_skip_crediting THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.get_assignments.l_skip_crediting');
      debugmsg('SCA : End of SCATM');
      cn_message_pkg.end_batch(l_process_audit_id);
    WHEN l_invalid_run_mode THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.get_assignments.l_invalid_run_mode');
      debugmsg('SCA : End of SCATM');
      cn_message_pkg.end_batch(l_process_audit_id);
    WHEN fnd_api.g_exc_error THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.get_assignments.g_exc_error');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      debugmsg('SCA : End of SCATM');
      cn_message_pkg.end_batch(l_process_audit_id);
    WHEN child_proc_fail_exception THEN
      debugmsg('SCA : Unexpected exception');
      debugmsg('SCA : Child Process Failed  ');
      debugmsg('SCA : Check Log of Child Process ');
    WHEN OTHERS THEN
      debugmsg('SCA : Unexpected exception');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      -- Call end_batch to end debug log file
      debugmsg('SCA : End of SCATM');
      cn_message_pkg.end_batch(l_process_audit_id);
      retcode  := 2;
      errbuf   := 'Unexpected Error : ' || SQLERRM;
  END get_assignments;

PROCEDURE batch_process_txns(
   errbuf       OUT NOCOPY    VARCHAR2
  ,retcode      OUT NOCOPY    VARCHAR2
  ,p_org_id NUMBER
  ,p_run_mode VARCHAR2
  ,p_worker_id NUMBER)
  IS

  BEGIN

    IF (p_run_mode = 'NEW') THEN
      /* Process new and adjusted transactions */
      process_new_txns(p_org_id => p_org_id, p_worker_id => p_worker_id,
      errbuf => errbuf, retcode => retcode);


      IF (retcode <> 0) THEN
        debugmsg('SCA : CN_SCATM_TAE_PUB.process_new_txns has failed');
        RAISE fnd_api.g_exc_error;
      END IF;


      debugmsg('SCA : CN_SCATM_TAE_PUB.process_new_txns completed successfully');
    ELSIF(p_run_mode = 'ALL') THEN
      /* Process all transactions */
      process_all_txns(p_org_id => p_org_id, p_worker_id => p_worker_id,
      errbuf => errbuf, retcode => retcode);


      IF (retcode <> 0) THEN
        debugmsg('SCA : CN_SCATM_TAE_PUB.process_all_txns has failed');
        RAISE fnd_api.g_exc_error;
      END IF;

        debugmsg('SCA : CN_SCATM_TAE_PUB.process_all_txns completed successfully');
    END IF;

     update_txns_processed(errbuf => errbuf, retcode => retcode,
     p_worker_id  => p_worker_id);

    debugmsg('SCA : Child Process '||p_worker_id ||' complete successfully at '||
    CURRENT_TIMESTAMP);

    COMMIT;

 EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.get_assignments.g_exc_error');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      debugmsg('SCA : End of SCATM');
      -- cn_message_pkg.end_batch(l_process_audit_id);
    WHEN OTHERS THEN
      debugmsg('SCA : Unexpected exception');
      debugmsg('SCA : SQLCODE : ' || SQLCODE);
      debugmsg('SCA : SQLERRM : ' || SQLERRM);
      -- Call end_batch to end debug log file
      debugmsg('SCA : End of SCATM');
      --cn_message_pkg.end_batch(l_process_audit_id);
      retcode  := 2;
      errbuf   := 'Unexpected Error : ' || SQLERRM;

 END batch_process_txns;

 PROCEDURE batch_collect_txns(
     errbuf       OUT NOCOPY    VARCHAR2
   , retcode      OUT NOCOPY    VARCHAR2
   , lp_start_date IN DATE
   , lp_end_date IN DATE
   , p_org_id IN NUMBER
   , p_run_mode IN VARCHAR2
   , l_num_workers IN  NUMBER
   , p_request_id IN NUMBER
   )
 IS
   l_where_clause VARCHAR2(2000);
   l_return_status VARCHAR2(30);
   l_msg_count     NUMBER;
   l_msg_data      VARCHAR2(3000);
 BEGIN

   retcode := 0;
   /* Get the criterion to select transactions from api table */

   get_where_clause(
       p_start_date                 => lp_start_date
     , p_end_date                   => lp_end_date
     , p_org_id                     => p_org_id
     , p_run_mode                   => p_run_mode
     , x_where_clause               => l_where_clause
     , errbuf                       => errbuf
     , retcode                      => retcode
     );

   IF (retcode <> 0) THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.get_where_clause has failed');
      RAISE fnd_api.g_exc_error;
   END IF;

   debugmsg('SCA : CN_SCATM_TAE_PUB.get_where_clause completed successfully');

    /* insert the selected transactions from cn_comm_lines_api_all table */
    /* to the interface table jtf_tae_1001_sc_dea_trans                  */
    jty_assign_bulk_pub.collect_trans_data(
      p_api_version_number         => 1.0
    , p_init_msg_list              => fnd_api.g_false
    , p_source_id                  => -1001
    , p_trans_id                   => -1002
    , p_program_name               => 'SALES/INCENTIVE COMPENSATION PROGRAM'
    , p_mode                       => 'DATE EFFECTIVE'
    , p_where                      => l_where_clause
    , p_no_of_workers              => l_num_workers
    , p_percent_analyzed           => 20
    ,   -- this value can be either a profile option or a parameter to conc program
      p_request_id                 => p_request_id
    ,   -- request id of the concurrent program
      x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , errbuf                       => errbuf
    , retcode                      => retcode
    , p_oic_mode                   => 'INSERT'
    );

   IF (retcode <> 0) THEN
      debugmsg('SCA : CN_SCATM_TAE_PUB.get_credited_txns for INSERT has failed');
      RAISE fnd_api.g_exc_error;
    END IF;

    debugmsg('SCA : CN_SCATM_TAE_PUB.batch_collect_txns with oic_mode INSERT completed successfully');

  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
        debugmsg('SCA : CN_SCATM_TAE_PUB.get_assignments.g_exc_error');
        debugmsg('SCA : SQLCODE : ' || SQLCODE);
        debugmsg('SCA : SQLERRM : ' || SQLERRM);
        debugmsg('SCA : End of SCATM');
     WHEN OTHERS THEN
        debugmsg('SCA : Unexpected exception');
        debugmsg('SCA : SQLCODE : ' || SQLCODE);
        debugmsg('SCA : SQLERRM : ' || SQLERRM);
        debugmsg('SCA : End of SCATM');
        retcode  := 2;
        errbuf   := 'Unexpected Error : ' || SQLERRM;
END batch_collect_txns;


PROCEDURE batch_process_winners(
     errbuf       OUT NOCOPY    VARCHAR2
   , retcode      OUT NOCOPY    VARCHAR2
   , p_worker_id  IN NUMBER
   , p_oic_mode   IN VARCHAR2
   , p_terr_id    IN NUMBER
   )
 IS
   l_where_clause VARCHAR2(2000);
   l_return_status VARCHAR2(30);
   l_msg_count     NUMBER;
   l_msg_data      VARCHAR2(3000);
 BEGIN

   retcode := 0;
   /* Get the criterion to select transactions from api table */
    debugmsg('SCA : Populating data to WINNERS table for worker_id '||p_worker_id ||' and mode '||
    p_oic_mode);
    /* this api will apply the rules to the transactions present in jtf_tae_1001_sc_dea_trans       */
    /* and populate the winning salesreps for each transaction in the table jtf_tae_1001_sc_winners */

       jty_assign_bulk_pub.get_winners(
          p_api_version_number         => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_source_id                  => -1001
        , p_trans_id                   => -1002
        , p_program_name               => 'SALES/INCENTIVE COMPENSATION PROGRAM'
        , p_mode                       => 'DATE EFFECTIVE'
        , p_percent_analyzed           => 20
        ,   --  this value can be either a profile option or a parameter to conc program
          p_worker_id                  => p_worker_id
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , errbuf                       => errbuf
        , retcode                      => retcode
        , p_oic_mode                   => p_oic_mode
		, p_terr_id                    => p_terr_id
        );

        debugmsg('SCA : CN_SCATM_TAE_PUB.batch_process_winners status '||l_return_status
        ||' data '||l_msg_data);

        IF (retcode <> 0) THEN
          debugmsg('SCA : jty_assign_bulk_pub.get_winners has failed');
          RAISE fnd_api.g_exc_error;
        END IF;


    debugmsg('SCA : CN_SCATM_TAE_PUB.batch_process_winners completed successfully');
  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
        debugmsg('SCA : CN_SCATM_TAE_PUB.get_assignments.g_exc_error');
        debugmsg('SCA : SQLCODE : ' || SQLCODE);
        debugmsg('SCA : SQLERRM : ' || SQLERRM);
        debugmsg('SCA : End of SCATM');
     WHEN OTHERS THEN
        debugmsg('SCA : Unexpected exception');
        debugmsg('SCA : SQLCODE : ' || SQLCODE);
        debugmsg('SCA : SQLERRM : ' || SQLERRM);
        debugmsg('SCA : End of SCATM');
        retcode  := 2;
        errbuf   := 'Unexpected Error : ' || SQLERRM;
END batch_process_winners;

FUNCTION convert_to_table
RETURN cn_sca_insert_tbl_type IS

BEGIN

 RETURN g_sca_insert_tbl_type;

END convert_to_table;

END cn_sca_credits_batch_pub;

/
