--------------------------------------------------------
--  DDL for Package Body CN_TRANSACTION_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TRANSACTION_LOAD_PKG" AS
  -- $Header: cnloadb.pls 120.8.12010000.12 2009/12/01 07:38:53 sseshaiy ship $
  -- +======================================================================+
  -- |                Copyright (c) 1994 Oracle Corporation                 |
  -- |                   Redwood Shores, California, USA                    |
  -- |                        All rights reserved.                          |
  -- +======================================================================+

  -- Package Name
  --   cn_transaction_load_pkg
  -- Purpose
  --   Procedures TO load trx FROM cn_comm_lines_api TO cn_commission_headers
  -- History
  --   10/21/99   Harlen Chen   Created
  --   08/28/01 Rao Chenna  acctd_transaction_amount column update logic
  --        is modified.
  --   03/31/03   Hithanki        Modified Procedure Assign For bug Fix 2781346
  --                              Added Exception Handler For No-Trx-Lines Error.
    --
    -- Nov 22, 2005  vensrini     Added org_id joins to the subqueries in
    --                            check_api_data procedure
    --
    --                            Fixes for transaction load thru concurrent request

  -- Global Variable
  g_logical_process     VARCHAR2(30) := 'LOAD';
  g_physical_process    VARCHAR2(30) := 'LOAD';
  no_trx_lines          EXCEPTION;
  fail_validate_ruleset EXCEPTION;
  conc_fail             EXCEPTION;
  invalid_date          EXCEPTION;

  -- Local Procedure for showing debug msg
  PROCEDURE debugmsg(msg VARCHAR2) IS
  BEGIN
    cn_message_pkg.DEBUG(SUBSTR(msg, 1, 254));
  -- comment out dbms_output before checking in file
  -- dbms_output.put_line(substr(msg,1,254));
  END debugmsg;

  -- Procedure Name
  --   get_physical_batch_id
  -- Purpose : get the unique physical batch id
  FUNCTION get_physical_batch_id
    RETURN NUMBER IS
    x_physical_batch_id NUMBER;
  BEGIN
    -- sequence s3 is for physical batch id
    SELECT cn_process_batches_s3.NEXTVAL
      INTO x_physical_batch_id
      FROM SYS.DUAL;

    RETURN x_physical_batch_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NO_DATA_FOUND;
  END get_physical_batch_id;

  -- Procedure Name
  --   void_batches
  -- Purpose
  --   VOID the batches that have successfully moved to the required status
  --   to prevent them being picked up in any retries.
  --   Unlockable batches will remain for the requred number of retries
  --   Called just before program completes to purge the table of any remaining
  --   unprocessed records that were not procesed during retries.
  PROCEDURE void_batches(p_physical_batch_id NUMBER, p_logical_batch_id NUMBER) IS
    l_user_id         NUMBER(15) := fnd_global.user_id;
    l_resp_id         NUMBER(15) := fnd_global.resp_id;
    l_login_id        NUMBER(15) := fnd_global.login_id;
    l_conc_prog_id    NUMBER(15) := fnd_global.conc_program_id;
    l_conc_request_id NUMBER(15) := fnd_global.conc_request_id;
    l_prog_appl_id    NUMBER(15) := fnd_global.prog_appl_id;
  BEGIN
    debugmsg(
         'Void_batches : For physical batch : '
      || p_physical_batch_id
      || ' Logical batch '
      || p_logical_batch_id
    );

    IF p_physical_batch_id IS NULL THEN
      UPDATE cn_process_batches
         SET status_code = 'VOID'
           , last_update_date = SYSDATE
           , last_update_login = l_login_id
           , last_updated_by = l_user_id
           , request_id = l_conc_request_id
           , program_application_id = l_prog_appl_id
           , program_id = l_conc_prog_id
           , program_update_date = SYSDATE
       WHERE logical_batch_id = p_logical_batch_id;
    ELSE
      UPDATE cn_process_batches
         SET status_code = 'VOID'
           , last_update_date = SYSDATE
           , last_update_login = l_login_id
           , last_updated_by = l_user_id
           , request_id = l_conc_request_id
           , program_application_id = l_prog_appl_id
           , program_id = l_conc_prog_id
           , program_update_date = SYSDATE
       WHERE physical_batch_id = p_physical_batch_id;
    END IF;

    IF SQL%FOUND THEN
      debugmsg('Void_batches : found ');
    ELSIF SQL%NOTFOUND THEN
      debugmsg('Void_batches : not found');
    END IF;
  END void_batches;

  --+ Procedure Name
  --+   Assign
  --+ Purpose : Split the logical batch into smaller physical batches
  --+           populate the physical_batch_id in cn_process_batches
  PROCEDURE assign(p_logical_batch_id NUMBER, p_org_id NUMBER) IS
    x_physical_batch_id NUMBER;
    l_srp_trx_count     NUMBER                    := 0;
    l_trx_count         NUMBER                    := 0;   -- number of trx in current physical batch
    l_srp_count         NUMBER                    := 0;   -- number of srp in current physical batch
    l_user_id           NUMBER(15)                := fnd_global.user_id;
    l_resp_id           NUMBER(15)                := fnd_global.resp_id;
    l_login_id          NUMBER(15)                := fnd_global.login_id;
    l_conc_prog_id      NUMBER(15)                := fnd_global.conc_program_id;
    l_conc_request_id   NUMBER(15)                := fnd_global.conc_request_id;
    l_prog_appl_id      NUMBER(15)                := fnd_global.prog_appl_id;

    CURSOR logical_batches IS
      SELECT   salesrep_id
             , SUM(sales_lines_total) srp_trx_count
          FROM cn_process_batches
         WHERE logical_batch_id = p_logical_batch_id AND status_code = 'IN_USE'
      GROUP BY salesrep_id
      ORDER BY salesrep_id DESC;

    logical_rec         logical_batches%ROWTYPE;
  BEGIN
    -- Get the first physical batch id
    x_physical_batch_id  := get_physical_batch_id;
    cn_global_var.initialize_instance_info(p_org_id);


    OPEN logical_batches;

    LOOP
      FETCH logical_batches INTO logical_rec;

      IF (logical_batches%FOUND) THEN
        l_srp_count      := l_srp_count + 1;
        l_srp_trx_count  := logical_rec.srp_trx_count;

        IF ((l_trx_count + l_srp_trx_count) >= cn_global_var.g_system_batch_size) THEN
          IF (l_srp_count > 1) THEN
            -- This case, done with current batch.
            debugmsg(
                 'Loader : Assign : Case1 Physical batch id : '
              || x_physical_batch_id
              || ' Total trx lines : '
              || l_trx_count
              || ' Total salesrep : '
              || TO_CHAR(l_srp_count - 1)
            );
            -- This salesrep should go into next batch.
            l_trx_count          := l_srp_trx_count;
            l_srp_count          := 1;
            x_physical_batch_id  := get_physical_batch_id;
          ELSE
            -- This is the first salerep in this batch, this salesrep
            -- has to be in this batch.
            l_trx_count  := l_srp_trx_count;
          END IF;
        ELSIF(l_srp_count > cn_global_var.get_salesrep_batch_size(p_org_id)) THEN
          -- too many salesreps in this physical batch.
          -- this salesrep should go into next batch.
          debugmsg(
               'Loader : Assign : Case 2 Physical batch id : '
            || x_physical_batch_id
            || ' Total trx lines : '
            || l_trx_count
            || ' Total salesrep : '
            || TO_CHAR(l_srp_count - 1)
          );
          l_trx_count          := l_srp_trx_count;
          l_srp_count          := 1;
          x_physical_batch_id  := get_physical_batch_id;
        ELSE
          -- continue with current batch
          l_trx_count  := l_trx_count + l_srp_trx_count;
        END IF;

        debugmsg(
             'Loader : Assign : Physical batch id : '
          || x_physical_batch_id
          || ' Salesrep ID : '
          || logical_rec.salesrep_id
          || ' and  # of trx : '
          || l_srp_trx_count
        );

        UPDATE cn_process_batches
           SET physical_batch_id = x_physical_batch_id
             , last_update_date = SYSDATE
             , last_update_login = l_login_id
             , last_updated_by = l_user_id
             , request_id = l_conc_request_id
             , program_application_id = l_prog_appl_id
             , program_id = l_conc_prog_id
             , program_update_date = SYSDATE
         WHERE salesrep_id = logical_rec.salesrep_id
           AND logical_batch_id = p_logical_batch_id
           AND status_code = 'IN_USE';
      ELSE   --  logical_batches not FOUND
        IF (logical_batches%ROWCOUNT = 0) THEN
          -- Added By HITHANKI Start
                -- On 03/31/03  For Bug Fix 2781346
          -- Replaced this RAISE call with standard way of handling User Defined Exceptions
          -- RAISE no_trx_lines;

          -- IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name('CN', 'CN_NO_TRX_LINES');
          fnd_msg_pub.ADD;
          -- END IF;
          EXIT;
          RAISE fnd_api.g_exc_error;
        -- Added By HITHANKI End
        ELSE
          -- assign is completed
          debugmsg(
               'Loader : Assign : Case 3 Physical batch id : '
            || x_physical_batch_id
            || ' Total trx lines : '
            || l_trx_count
            || ' Total salesrep : '
            || l_srp_count
          );
          debugmsg('Loader : Assign : successfully completed');
        END IF;

        EXIT;
      END IF;
    END LOOP;

    CLOSE logical_batches;

    cn_message_pkg.FLUSH;
    COMMIT;
    debugmsg('Loader : Assign : Assignment commit complete.');
  EXCEPTION
    WHEN OTHERS THEN
      debugmsg('Loader : Assign : Unexpected exception.');
      RAISE;
  --  Commented Out
  --  Hithanki 05/03/03  For Bug Fix 2781346
  --  WHEN no_trx_lines THEN
  --  debugmsg('Loader : Assign : No transactions found.');
  --  RAISE;
  END assign;

  PROCEDURE update_error(x_physical_batch_id NUMBER) IS
    l_user_id         NUMBER(15) := fnd_global.user_id;
    l_resp_id         NUMBER(15) := fnd_global.resp_id;
    l_login_id        NUMBER(15) := fnd_global.login_id;
    l_conc_prog_id    NUMBER(15) := fnd_global.conc_program_id;
    l_conc_request_id NUMBER(15) := fnd_global.conc_request_id;
    l_prog_appl_id    NUMBER(15) := fnd_global.prog_appl_id;
  BEGIN
    -- Giving the batch an 'ERROR' status prevents subsequent
    -- physical processes picking it up.
    UPDATE cn_process_batches
       SET status_code = 'ERROR'
         , last_update_date = SYSDATE
         , last_update_login = l_login_id
         , last_updated_by = l_user_id
         , request_id = l_conc_request_id
         , program_application_id = l_prog_appl_id
         , program_id = l_conc_prog_id
         , program_update_date = SYSDATE
     WHERE physical_batch_id = x_physical_batch_id;
  END update_error;

  -- Procedure Name
  --   Conc_Submit
  -- Purpose
  PROCEDURE conc_submit(
    x_conc_program                       VARCHAR2
  , x_parent_proc_audit_id               NUMBER
  , x_logical_process                    VARCHAR2
  , x_physical_process                   VARCHAR2
  , x_physical_batch_id                  NUMBER
  , x_salesrep_id                        NUMBER
  , x_start_date                         DATE
  , x_end_date                           DATE
  , x_cls_rol_flag                       VARCHAR2
  , x_request_id           IN OUT NOCOPY NUMBER
  ) IS
    l_org_id NUMBER;   -- vensrini transaction load fix
  BEGIN
    debugmsg('Conc_Submit : x_logical_process = ' || x_logical_process);
    debugmsg('Conc_Submit : x_salesrep_id = ' || x_salesrep_id);
    debugmsg('Conc_Submit : x_start_date = ' || x_start_date);
    debugmsg('Conc_Submit : x_end_date = ' || x_end_date);
    debugmsg('Conc_Submit : x_cls_rol_flag = ' || x_cls_rol_flag);

    -- transaction load
    SELECT org_id INTO l_org_id
      FROM cn_process_batches
     WHERE physical_batch_id = x_physical_batch_id AND ROWNUM = 1;

    fnd_request.set_org_id(l_org_id);
    -- transaction load
    x_request_id  :=
      fnd_request.submit_request(
        application                  => 'CN'
      , program                      => x_conc_program
      , description                  => NULL
      , start_time                   => NULL
      , sub_request                  => NULL
      , argument1                    => x_parent_proc_audit_id
      , argument2                    => x_logical_process
      , argument3                    => x_physical_process
      , argument4                    => x_physical_batch_id
      , argument5                    => x_salesrep_id
      , argument6                    => x_start_date
      , argument7                    => x_end_date
      , argument8                    => x_cls_rol_flag
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
  END conc_submit;

  -- Procedure Name
  --   Conc_Dispatch
  -- Purpose
  --   Submits independent concurrent programs for each physical batch.
  --   These physical batches will be executed in parallel.
  --   A subsequent physical process cannot begin until all physical
  --   batches in its prerequisite process have completed.
  PROCEDURE conc_dispatch(
    x_parent_proc_audit_id NUMBER
  , x_salesrep_id          NUMBER
  , x_start_date           DATE
  , x_end_date             DATE
  , x_cls_rol_flag         VARCHAR2
  , x_logical_batch_id     NUMBER
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

    -- Get individual physical batch id's for the entire logical batch
    CURSOR physical_batches IS
      SELECT DISTINCT physical_batch_id
                 FROM cn_process_batches
                WHERE logical_batch_id = x_logical_batch_id AND status_code = 'IN_USE';

    physical_rec            physical_batches%ROWTYPE;
  BEGIN
    debugmsg('Loader : Conc_Dispatch : Start of Conc_Dispatch');

    WHILE unfinished LOOP
      l_primary_request_stack  := l_empty_request_stack;
      l_primary_batch_stack    := l_empty_batch_stack;
      primary_ptr              := 1;   -- Start at element one not element zero
      l_completed_batch_count  := 0;
      x_batch_total            := 0;

      FOR physical_rec IN physical_batches LOOP
        debugmsg(
             'Loader : Conc_Dispatch : Calling conc_submit. '
          || 'physical_rec.physical_batch_id = '
          || physical_rec.physical_batch_id
        );
        debugmsg('conc_dispatch : call BATCH_RUNNER');
        conc_submit(
          x_conc_program               => 'BATCH_RUNNER'
        , x_parent_proc_audit_id       => x_parent_proc_audit_id
        , x_logical_process            => g_logical_process   -- = 'LOAD'
        , x_physical_process           => g_physical_process   -- = 'LOAD'
        , x_physical_batch_id          => physical_rec.physical_batch_id
        , x_salesrep_id                => x_salesrep_id
        , x_start_date                 => x_start_date
        , x_end_date                   => x_end_date
        , x_cls_rol_flag               => x_cls_rol_flag
        , x_request_id                 => l_temp_id
        );
        debugmsg('conc_dispatch : done BATCH_RUNNER');
        x_batch_total                           := x_batch_total + 1;
        l_primary_request_stack(x_batch_total)  := l_temp_id;
        l_primary_batch_stack(x_batch_total)    := physical_rec.physical_batch_id;

        -- If submission failed update the batch record and bail
        IF l_temp_id = 0 THEN
          --cn_debug.print_msg('conc disp submit failed',1);
          l_temp_phys_batch_id  := physical_rec.physical_batch_id;
          RAISE conc_fail;
        END IF;
      END LOOP;

      debugmsg('Loader : Conc_Dispatch : Total conc requests submitted : ' || x_batch_total);
      debugmsg('Total conc requests submitted : ' || x_batch_total);
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
            debugmsg('Loader : Conc_Dispatch : request_id is '
              || l_primary_request_stack(primary_ptr));
            RAISE conc_fail;
          END IF;

          IF l_dev_phase = 'COMPLETE' THEN
            debug_v                               := l_primary_request_stack(primary_ptr);
            l_temp_phys_batch_id                  := l_primary_batch_stack(primary_ptr);
            l_primary_batch_stack(primary_ptr)    := NULL;
            l_primary_request_stack(primary_ptr)  := NULL;
            l_completed_batch_count               := l_completed_batch_count + 1;

            IF l_dev_status = 'ERROR' THEN
              debugmsg('Loader : Conc_Dispatch : ' || 'Request completed with error for '
                || debug_v);
              RAISE conc_fail;
            ELSIF l_dev_status = 'NORMAL' THEN
              x_debug  := l_primary_batch_stack(primary_ptr);
            END IF;   -- If error
          END IF;   -- If complete
        END IF;   -- If null ptr

        primary_ptr  := primary_ptr + 1;

        IF l_completed_batch_count = x_batch_total THEN
          debugmsg(
               'Loade : Conc_Dispatch :  All requests complete for physical '
            || 'process : '
            || g_physical_process
          );
          -- Get out of the loop by adding 1
          l_completed_batch_count  := l_completed_batch_count + 1;
          debugmsg(
               'Loader : Conc_Dispatch :  All requests complete for '
            || 'logical process : '
            || g_logical_process
          );
          unfinished               := FALSE;
        ELSE
          -- Made a complete pass through the srp_periods in this physical
          -- batch and some conc requests have not completed.
          -- Give the conc requests a few minutes to run before
          -- checking their status
          IF primary_ptr > x_batch_total THEN
            DBMS_LOCK.sleep(l_sleep_time);
            primary_ptr  := 1;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debugmsg('Loader : Conc_Dispatch : no rows for process ' || g_physical_process);
      cn_message_pkg.end_batch(x_parent_proc_audit_id);
    WHEN conc_fail THEN
      update_error(l_temp_phys_batch_id);
      debugmsg('Loader : Conc_Dispatch : Exception conc_fail');
      cn_message_pkg.end_batch(x_parent_proc_audit_id);
      conc_status  := fnd_concurrent.set_completion_status(status => 'ERROR', MESSAGE => '');
    WHEN OTHERS THEN
      debugmsg('Loader : Conc_Dispatch : Unexpected Exception');
      RAISE;
  END conc_dispatch;

  -- Procedure Name
  --   Pre_Conc_Dispatch
  -- Purpose
  PROCEDURE pre_conc_dispatch(
    p_salesrep_id NUMBER
  , p_start_date  DATE
  , p_end_date    DATE
  , p_org_id      NUMBER
  ) IS
    x_trx_batch        NUMBER(15);
    user_id            NUMBER;
    functionalcurrency VARCHAR2(15);
  BEGIN
    /*****************************************/
    /* The following Updates do a check for  */
    /* no prior adjustment if profile option set to 'Y'*/
    /*****************************************/
    IF (cn_system_parameters.VALUE('CN_PRIOR_ADJUSTMENT', p_org_id) = 'N') THEN
      DECLARE
        x_latest_processed_date DATE;
      BEGIN
        SELECT NVL(latest_processed_date, TO_DATE('01/01/1900', 'DD/MM/YYYY'))
          INTO x_latest_processed_date
          FROM cn_repositories_all
         WHERE org_id = p_org_id;

        -- Commented this query to fix bug# 1772128
              /*
        UPDATE cn_comm_lines_api_all
          SET load_status = 'ERROR - PRIOR ADJUSTMENT'
          WHERE load_status  = 'UNLOADED'
          AND Trunc(processed_date) >= Trunc(p_start_date)
          AND Trunc(processed_date) <= Trunc(p_end_date)
          AND ((p_salesrep_id IS NULL) OR (salesrep_id = p_salesrep_id))
          AND trx_type <> 'FORECAST'
            AND processed_date < x_latest_processed_date; */
        IF (p_salesrep_id IS NULL) THEN
          UPDATE cn_comm_lines_api_all
             SET load_status = 'ERROR - PRIOR ADJUSTMENT'
           WHERE load_status = 'UNLOADED'
             AND processed_date >= TRUNC(p_start_date)
             AND processed_date <(TRUNC(p_end_date) + 1)
             AND trx_type <> 'FORECAST'
             AND (adjust_status <> 'SCA_PENDING') -- OR adjust_status IS NULL)
             AND processed_date < x_latest_processed_date
             AND org_id = p_org_id;
        ELSE
          UPDATE cn_comm_lines_api_all
             SET load_status = 'ERROR - PRIOR ADJUSTMENT'
           WHERE load_status = 'UNLOADED'
             AND processed_date >= TRUNC(p_start_date)
             AND processed_date <(TRUNC(p_end_date) + 1)
             AND salesrep_id = p_salesrep_id
             AND trx_type <> 'FORECAST'
             AND (adjust_status <> 'SCA_PENDING') -- OR adjust_status IS NULL)
             AND processed_date < x_latest_processed_date
             AND org_id = p_org_id;
        END IF;
      END;

      NULL;
    END IF;

    /*****************************************/
    /* The following Updates do a check for  */
    /* failures in the foreign key references*/
    /*****************************************/

    -- Commented this query to fix bug# 1772128
       /*
       UPDATE cn_comm_lines_api SET load_status = 'ERROR - TRX_TYPE'
         WHERE load_status  = 'UNLOADED'
         AND Trunc(processed_date) >= Trunc(p_start_date)
         AND Trunc(processed_date) <= Trunc(p_end_date)
         AND ((p_salesrep_id IS NULL) OR (salesrep_id = p_salesrep_id))
         AND trx_type <> 'FORECAST'
         AND NOT EXISTS
         (SELECT 1 FROM cn_lookups WHERE lookup_type = 'TRX TYPES'
    AND lookup_code =
    cn_comm_lines_api.trx_type); */
        -- Added by rchenna on 06/12/01
    IF (p_salesrep_id IS NULL) THEN
      UPDATE cn_comm_lines_api_all
         SET load_status = 'ERROR - TRX_TYPE'
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING') --OR adjust_status IS NULL)
         AND org_id = p_org_id
         AND NOT EXISTS(
                    SELECT 1
                      FROM cn_lookups
                     WHERE lookup_type = 'TRX TYPES'
                           AND lookup_code = cn_comm_lines_api_all.trx_type);
    ELSE
      UPDATE cn_comm_lines_api_all
         SET load_status = 'ERROR - TRX_TYPE'
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND salesrep_id = p_salesrep_id
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING') -- OR adjust_status IS NULL)
         AND org_id = p_org_id
         AND NOT EXISTS(
                    SELECT 1
                      FROM cn_lookups
                     WHERE lookup_type = 'TRX TYPES'
                           AND lookup_code = cn_comm_lines_api_all.trx_type);
    END IF;

       --
       -- Commented this query to fix bug# 1772128
       /*
       UPDATE cn_comm_lines_api SET load_status = 'ERROR - REVENUE_CLASS'
        WHERE load_status  = 'UNLOADED'
          AND Trunc(processed_date) >= Trunc(p_start_date)
          AND Trunc(processed_date) <= Trunc(p_end_date)
          AND ((p_salesrep_id IS NULL) OR (salesrep_id = p_salesrep_id))
          AND trx_type <> 'FORECAST'
          AND revenue_class_id IS NOT NULL
    AND NOT EXISTS
    (SELECT 1 FROM cn_revenue_classes
     WHERE cn_revenue_classes.revenue_class_id =
     cn_comm_lines_api.revenue_class_id); */
       -- Added by rchenna on 06/12/01
    IF (p_salesrep_id IS NULL) THEN
      UPDATE cn_comm_lines_api_all
         SET load_status = 'ERROR - REVENUE_CLASS'
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')--OR adjust_status IS NULL)
         AND revenue_class_id IS NOT NULL
         AND org_id = p_org_id
         AND NOT EXISTS(
                  SELECT 1
                    FROM cn_revenue_classes
                   WHERE cn_revenue_classes.revenue_class_id =
                                                              cn_comm_lines_api_all.revenue_class_id);
    ELSE
      UPDATE cn_comm_lines_api_all
         SET load_status = 'ERROR - REVENUE_CLASS'
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND salesrep_id = p_salesrep_id
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
         AND revenue_class_id IS NOT NULL
         AND org_id = p_org_id
         AND NOT EXISTS(
                  SELECT 1
                    FROM cn_revenue_classes
                   WHERE cn_revenue_classes.revenue_class_id =
                                                              cn_comm_lines_api_all.revenue_class_id);
    END IF;

    --

    /*****************************************/
    /* Validation for multi-currency       */
    /*****************************************/
    functionalcurrency  := cn_general_utils.get_currency(p_org_id);

      -- If transaction currency = functional currency, then OK
      -- if exch rate is NULL, fill in before rate check
      -- Commented this query to fix bug# 1772128
      /*
      UPDATE cn_comm_lines_api
        SET acctd_transaction_amount = transaction_amount,
        exchange_rate = 1
        WHERE load_status  = 'UNLOADED'
        AND Trunc(processed_date) >= Trunc(p_start_date)
        AND Trunc(processed_date) <= Trunc(p_end_date)
        AND ((p_salesrep_id IS NULL) OR (salesrep_id = p_salesrep_id))
        AND ((acctd_transaction_amount IS NULL) OR
       (acctd_transaction_amount = transaction_amount))
    AND exchange_rate IS NULL
      AND trx_type <> 'FORECAST'
      AND transaction_currency_code IS NOT NULL
        AND transaction_currency_code = FunctionalCurrency;  */
    IF (p_salesrep_id IS NULL) THEN
      UPDATE cn_comm_lines_api_all
         SET acctd_transaction_amount = transaction_amount * NVL(exchange_rate, 1)
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND acctd_transaction_amount IS NULL
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
         AND org_id = p_org_id
         AND transaction_currency_code = functionalcurrency;
    ELSE
      UPDATE cn_comm_lines_api_all
         SET acctd_transaction_amount = transaction_amount * NVL(exchange_rate, 1)
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND salesrep_id = p_salesrep_id
         AND acctd_transaction_amount IS NULL
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
         AND org_id = p_org_id
         AND transaction_currency_code = functionalcurrency;
    END IF;

    debugmsg(
         'Loader : Pre_Conc_Dispatch : Multi-currency:  '
      || TO_CHAR(SQL%ROWCOUNT)
      || ' records given in same currency as functional.'
    );

    /* Error when conversion needed but no rate given */
    -- Commented this query to fix bug# 1772128
    /*
    UPDATE cn_comm_lines_api SET load_status = 'ERROR - NO EXCH RATE GIVEN'
      WHERE load_status  = 'UNLOADED'
      AND Trunc(processed_date) >= Trunc(p_start_date)
      AND Trunc(processed_date) <= Trunc(p_end_date)
      AND ((p_salesrep_id IS NULL) OR (salesrep_id = p_salesrep_id))
      AND trx_type <> 'FORECAST'
      AND transaction_currency_code IS NOT NULL
      AND exchange_rate IS NULL; */
    IF (p_salesrep_id IS NULL) THEN
      UPDATE cn_comm_lines_api_all
         SET load_status = 'ERROR - NO EXCH RATE GIVEN'
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
         AND transaction_currency_code IS NOT NULL
         AND exchange_rate IS NULL
         -- Added to fix the above problem.
         AND acctd_transaction_amount IS NULL
         AND org_id = p_org_id;
    ELSE
      UPDATE cn_comm_lines_api_all
         SET load_status = 'ERROR - NO EXCH RATE GIVEN'
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND salesrep_id = p_salesrep_id
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
         AND transaction_currency_code IS NOT NULL
         AND exchange_rate IS NULL
         -- Added to fix the above problem.
         AND acctd_transaction_amount IS NULL
         AND org_id = p_org_id;
    END IF;

    /* Error when no rate and code given but functional <> foreign */
    -- Commented this query to fix bug# 1772128
    /*
    UPDATE cn_comm_lines_api SET load_status = 'ERROR - INCORRECT CONV GIVEN'
      WHERE load_status  = 'UNLOADED'
      AND Trunc(processed_date) >= Trunc(p_start_date)
      AND Trunc(processed_date) <= Trunc(p_end_date)
      AND ((p_salesrep_id IS NULL) OR (salesrep_id = p_salesrep_id))
      AND trx_type <> 'FORECAST'
      AND transaction_currency_code IS NULL
      AND exchange_rate IS NULL
      AND acctd_transaction_amount IS NOT NULL
      AND acctd_transaction_amount <> transaction_amount;  */
    IF (p_salesrep_id IS NULL) THEN
      UPDATE cn_comm_lines_api_all
         SET load_status = 'ERROR - INCORRECT CONV GIVEN'
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
         AND transaction_currency_code IS NULL
         AND exchange_rate IS NULL
         AND acctd_transaction_amount IS NOT NULL
         AND acctd_transaction_amount <> transaction_amount
         AND org_id = p_org_id;
    ELSE
      UPDATE cn_comm_lines_api_all
         SET load_status = 'ERROR - INCORRECT CONV GIVEN'
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND salesrep_id = p_salesrep_id
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
         AND transaction_currency_code IS NULL
         AND exchange_rate IS NULL
         AND acctd_transaction_amount IS NOT NULL
         AND acctd_transaction_amount <> transaction_amount
         AND org_id = p_org_id;
    END IF;

    /* Do foreign-to-functional currency conversion */
    -- Commented this query to fix bug# 1772128
    /*
    UPDATE cn_comm_lines_api
      SET acctd_transaction_amount = (transaction_amount * exchange_rate)
      WHERE load_status  = 'UNLOADED'
      AND Trunc(processed_date) >= Trunc(p_start_date)
      AND Trunc(processed_date) <= Trunc(p_end_date)
      AND ((p_salesrep_id IS NULL) OR (salesrep_id = p_salesrep_id))
      AND trx_type <> 'FORECAST'
      AND acctd_transaction_amount IS NULL
      AND exchange_rate IS NOT NULL
      AND transaction_currency_code IS NOT NULL; */
    IF (p_salesrep_id IS NULL) THEN
      UPDATE cn_comm_lines_api_all
         SET acctd_transaction_amount =(transaction_amount * exchange_rate)
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING') -- OR adjust_status IS NULL)
         AND acctd_transaction_amount IS NULL
         AND exchange_rate IS NOT NULL
         AND transaction_currency_code IS NOT NULL
         AND org_id = p_org_id;
    ELSE
      UPDATE cn_comm_lines_api_all
         SET acctd_transaction_amount =(transaction_amount * exchange_rate)
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND salesrep_id = p_salesrep_id
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING') -- OR adjust_status IS NULL)
         AND acctd_transaction_amount IS NULL
         AND exchange_rate IS NOT NULL
         AND transaction_currency_code IS NOT NULL
         AND org_id = p_org_id;
    END IF;

    debugmsg(
         'Loader : Pre_Conc_Dispatch : Multi-currency:  '
      || TO_CHAR(SQL%ROWCOUNT)
      || ' records transaction-to-functional currency conversion performed.'
    );

      /* Default lines w/o both curr code and exch rate to functional currency */
      -- Commented this query to fix bug# 1772128
      /*
    UPDATE cn_comm_lines_api SET acctd_transaction_amount = transaction_amount,
      transaction_currency_code = FunctionalCurrency, exchange_rate = 1
      WHERE load_status  = 'UNLOADED'
      AND Trunc(processed_date) >= Trunc(p_start_date)
      AND Trunc(processed_date) <= Trunc(p_end_date)
      AND ((p_salesrep_id IS NULL) OR (salesrep_id = p_salesrep_id))
      AND trx_type <> 'FORECAST'
      AND acctd_transaction_amount IS NULL
      AND exchange_rate IS NULL
      AND transaction_currency_code IS NULL;   */
    IF (p_salesrep_id IS NULL) THEN
      UPDATE cn_comm_lines_api_all
         SET acctd_transaction_amount = transaction_amount
           , transaction_currency_code = functionalcurrency
           , exchange_rate = 1
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
         AND acctd_transaction_amount IS NULL
         AND exchange_rate IS NULL
         AND transaction_currency_code IS NULL
         AND org_id = p_org_id;
    ELSE
      UPDATE cn_comm_lines_api_all
         SET acctd_transaction_amount = transaction_amount
           , transaction_currency_code = functionalcurrency
           , exchange_rate = 1
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND salesrep_id = p_salesrep_id
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING') -- OR adjust_status IS NULL)
         AND acctd_transaction_amount IS NULL
         AND exchange_rate IS NULL
         AND transaction_currency_code IS NULL
         AND org_id = p_org_id;
    END IF;

    debugmsg(
         'Loader : Pre_Conc_Dispatch : Multi-currency:  '
      || TO_CHAR(SQL%ROWCOUNT)
      || ' records defaulted to functional currency.'
    );

    /* Catch any lines that couldn't be converted, last ditch */
    -- Commented this query to fix bug# 1772128
    /*
    UPDATE cn_comm_lines_api SET load_status = 'ERROR - CANNOT CONV/DEFAULT'
      WHERE load_status  = 'UNLOADED'
      AND Trunc(processed_date) >= Trunc(p_start_date)
      AND Trunc(processed_date) <= Trunc(p_end_date)
      AND ((p_salesrep_id IS NULL) OR (salesrep_id = p_salesrep_id))
      AND trx_type <> 'FORECAST'
      AND acctd_transaction_amount IS NULL; */
    IF (p_salesrep_id IS NULL) THEN
      UPDATE cn_comm_lines_api_all
         SET load_status = 'ERROR - CANNOT CONV/DEFAULT'
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
         AND acctd_transaction_amount IS NULL
         AND org_id = p_org_id;
    ELSE
      UPDATE cn_comm_lines_api_all
         SET load_status = 'ERROR - CANNOT CONV/DEFAULT'
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND salesrep_id = p_salesrep_id
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
         AND acctd_transaction_amount IS NULL
         AND org_id = p_org_id;
    END IF;

    debugmsg(
         'Loader : Pre_Conc_Dispatch : Multi-currency:  '
      || TO_CHAR(SQL%ROWCOUNT)
      || ' records could not be converted nor defaulted.'
    );
  /*****************************************/
  /* End of multi-currency validation      */
  /*****************************************/
  END pre_conc_dispatch;

  -- Procedure Name
  --   Post_Conc_Dispatch
  -- Purpose
  PROCEDURE post_conc_dispatch(
    p_salesrep_id NUMBER
  , p_start_date  DATE
  , p_end_date    DATE
  , p_org_id      NUMBER
  ) IS
  BEGIN
    -- Commented this query to fix bug# 1772128
    /*
    UPDATE cn_comm_lines_api SET load_status = 'SALESREP ERROR'
      WHERE load_Status  = 'UNLOADED'
      AND Trunc(processed_date) >= Trunc(p_start_date)
      AND Trunc(processed_date) <= Trunc(p_end_date)
      AND ((p_salesrep_id IS NULL) OR (salesrep_id = p_salesrep_id))
      AND trx_type <> 'FORECAST'
      AND NOT EXISTS (SELECT 1 FROM cn_salesreps
          WHERE employee_number =
          cn_comm_lines_api.employee_number); */
    IF (p_salesrep_id IS NULL) THEN
      UPDATE cn_comm_lines_api_all
         SET load_status = 'SALESREP ERROR'
       WHERE load_status = 'UNLOADED'
         AND (adjust_status <> 'SCA_PENDING') -- OR adjust_status IS NULL)
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND trx_type <> 'FORECAST'
         AND org_id = p_org_id
         AND NOT EXISTS(SELECT 1
                          FROM cn_salesreps
                         WHERE employee_number = cn_comm_lines_api_all.employee_number);
    ELSE
      UPDATE cn_comm_lines_api_all
         SET load_status = 'SALESREP ERROR'
       WHERE load_status = 'UNLOADED'
         AND (adjust_status <> 'SCA_PENDING') -- OR adjust_status IS NULL)
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND salesrep_id = p_salesrep_id
         AND trx_type <> 'FORECAST'
         AND org_id = p_org_id
         AND NOT EXISTS(SELECT 1
                          FROM cn_salesreps
                         WHERE employee_number = cn_comm_lines_api_all.employee_number);
    END IF;

    debugmsg('Loader : Post_Conc_Dispatch : # of SALESREP ERROR = ' || TO_CHAR(SQL%ROWCOUNT));

    -- Commented this query to fix bug# 1772128
    /*
    UPDATE cn_comm_lines_api SET load_status = 'PERIOD ERROR'
      WHERE load_Status  = 'UNLOADED'
      AND Trunc(processed_date) >= Trunc(p_start_date)
      AND Trunc(processed_date) <= Trunc(p_end_date)
      AND ((p_salesrep_id IS NULL) OR (salesrep_id = p_salesrep_id))
      AND trx_type <> 'FORECAST';*/
    IF (p_salesrep_id IS NULL) THEN
      UPDATE cn_comm_lines_api_all
         SET load_status = 'PERIOD ERROR'
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
         AND org_id = p_org_id;
    ELSE
      UPDATE cn_comm_lines_api_all
         SET load_status = 'PERIOD ERROR'
       WHERE load_status = 'UNLOADED'
         AND processed_date >= TRUNC(p_start_date)
         AND processed_date <(TRUNC(p_end_date) + 1)
         AND salesrep_id = p_salesrep_id
         AND trx_type <> 'FORECAST'
         AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
         AND org_id = p_org_id;
    END IF;

    debugmsg('Loader : Post_Conc_Dispatch : # of PERIOD ERROR = ' || TO_CHAR(SQL%ROWCOUNT));
  END post_conc_dispatch;

  -- Procedure Name
  --   Check_Api_Data
  -- Purpose
  PROCEDURE check_api_data(p_start_date DATE, p_end_date DATE, p_org_id NUMBER) IS
    l_cn_reset_error_trx VARCHAR2(1);
  BEGIN
    --+
    --+ Reset the error transactions
    --+

    -- performance bug 1690393 : full table scan
    -- original statement
    -- UPDATE /* index (api, mis_cn_comm_lines_api_n1) */ cn_comm_lines_api api
    --  SET api.load_status  = 'UNLOADED'
    --  WHERE api.load_status <> 'UNLOADED'
    --  AND api.trx_type <> 'FORECAST'
    --  AND api.load_status <> 'OBSOLETE'
    --  AND api.load_status <> 'FILTERED' -- for v1152
    --  AND api.load_status <> 'LOADED'
    --  AND Trunc(api.processed_date) >= Trunc(p_start_date)
    --  AND Trunc(api.processed_date) <= Trunc(p_end_date);

    -- new statment

    -- performance bug 2035228
    l_cn_reset_error_trx  := cn_system_parameters.VALUE('CN_RESET_ERROR_TRX', p_org_id);
    debugmsg('Loader : OSC Profile - Reset Error Transaction is ' || l_cn_reset_error_trx);

    IF l_cn_reset_error_trx = 'Y' THEN
      debugmsg('Reset load status of error transactions to UNLOADED');

      -- UPDATE /* index (api, mis_cn_comm_lines_api_n1) */ cn_comm_lines_api api
      UPDATE cn_comm_lines_api_all api
         SET api.load_status = 'UNLOADED'
       WHERE api.trx_type <> 'FORECAST'
         AND api.load_status IN(
                'ERROR - PRIOR ADJUSTMENT'
              , 'ERROR - TRX_TYPE'
              , 'ERROR - REVENUE_CLASS'
              , 'ERROR - NO EXCH RATE GIVEN'
              , 'ERROR - INCORRECT CONV GIVEN'
              , 'ERROR - CANNOT CONV/DEFAULT'
              , 'SALESREP ERROR'
              , 'PERIOD ERROR'
              )
         AND api.processed_date >= TRUNC(p_start_date)
         AND api.processed_date <(TRUNC(p_end_date) + 1)
         AND api.org_id = p_org_id;
    ELSE
      debugmsg('Loader : Skip the process of reseting error transactions.');
    END IF;

    --+
    --+ Update null salerep_id based on the given employee_number
    --+
    UPDATE /*+ index(api, cn_comm_lines_api_f2)*/ cn_comm_lines_api_all api
       SET api.salesrep_id =
             (SELECT cs1.salesrep_id
                FROM cn_salesreps cs1
               WHERE cs1.employee_number = api.employee_number
                 AND cs1.org_id = api.org_id   -- vensrini
                 AND cs1.org_id = p_org_id)   -- vensrini
     WHERE api.salesrep_id IS NULL
       AND api.load_status = 'UNLOADED'
       AND api.trx_type <> 'FORECAST'
       AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
       AND EXISTS(
             SELECT /*+ NO_UNNEST */ employee_number
               FROM cn_salesreps cs
              WHERE api.employee_number = cs.employee_number
                AND cs.org_id = api.org_id   -- vensrini
                AND cs.org_id = p_org_id)   -- vensrini
       AND api.processed_date >= TRUNC(p_start_date)
       AND api.processed_date <(TRUNC(p_end_date) + 1)
       AND api.org_id = p_org_id;

    --+
    --+ Update null employee_number based on the given salesrep_id
    --+
    -- UPDATE /*+ index(api, cn_comm_lines_api_n1)*/   cn_comm_lines_api_all api
    UPDATE cn_comm_lines_api_all api
       SET employee_number =
             (SELECT employee_number
                FROM cn_salesreps cs1
               WHERE cs1.salesrep_id = api.salesrep_id
                 AND cs1.org_id = api.org_id   -- vensrini
                 AND cs1.org_id = p_org_id)   -- vensrini
     WHERE employee_number IS NULL
       AND load_status = 'UNLOADED'
       AND trx_type <> 'FORECAST'
       AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
       AND EXISTS(
             SELECT /*+ NO_UNNEST*/ salesrep_id
               FROM cn_salesreps cs
              WHERE api.salesrep_id = cs.salesrep_id
                AND cs.org_id = api.org_id   -- vensrini
                AND cs.org_id = p_org_id)   -- vensrini
       AND api.processed_date >= TRUNC(p_start_date)
       AND api.processed_date <(TRUNC(p_end_date) + 1)
       AND org_id = p_org_id;

    --+
    --+ IF both salesrep_id and employee_number are null,
    --+ set load_status to SALESREP ERROR
    --+
    UPDATE /*+ index(api, cn_comm_lines_api_f2)*/  cn_comm_lines_api_all api
       SET api.load_status = 'SALESREP ERROR'
     WHERE api.load_status = 'UNLOADED'
       AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
       AND api.salesrep_id IS NULL
       AND api.employee_number IS NULL
       AND api.processed_date >= TRUNC(p_start_date)
       AND api.processed_date <(TRUNC(p_end_date) + 1)
       AND api.org_id = p_org_id;
  END check_api_data;

  -- Name:
  --   Load
  -- Purpose:
  --   This procedure loads trx from CN_COMM_LINES_API to CN_COMMISSION_HEADERS,
  --   update cn_process_batches, and perform classification, and rollup phases
  PROCEDURE load(
    errbuf         OUT NOCOPY    VARCHAR2
  , retcode        OUT NOCOPY    NUMBER
  , p_salesrep_id  IN            NUMBER
  , pp_start_date  IN            VARCHAR2
  , pp_end_date    IN            VARCHAR2
  , p_cls_rol_flag IN            VARCHAR2
  , p_org_id       IN            NUMBER
  ) IS
    l_skip_credit_flag    VARCHAR2(1);
    l_logical_batch_id    NUMBER;
    l_process_audit_id    NUMBER;

    l_start_date          DATE;
    l_end_date            DATE;
    l_open_period         NUMBER;
  BEGIN
    -- Convert the dates for the varchar2 parameters passed in from concurrent program
    l_start_date           := fnd_date.canonical_to_date(pp_start_date);
    l_end_date             := fnd_date.canonical_to_date(pp_end_date);

    --+
    --+ Call begin_batch to get process_audit_id for debug log file
    --+
    cn_message_pkg.begin_batch(
      x_process_type               => 'LOADER'
    , x_parent_proc_audit_id       => NULL
    , x_process_audit_id           => l_process_audit_id
    , x_request_id                 => fnd_global.conc_request_id
    , p_org_id                     => p_org_id
    );

    debugmsg('Loader : Start of Loader');
    debugmsg('Loader : process_audit_id is ' || l_process_audit_id);

    /* verify that parameter end date is within an open acc period */
    l_open_period := 0;
    SELECT COUNT(*) INTO l_open_period
      FROM cn_period_statuses_all
     WHERE period_status = 'O'
       AND org_id = p_org_id
       AND (period_set_id, period_type_id) =
               (SELECT period_set_id, period_type_id
                  FROM cn_repositories_all
                 WHERE org_id = p_org_id)
       AND l_end_date BETWEEN start_date AND end_date;

    IF (l_open_period = 0) THEN
      debugmsg('Loader : Parameter End Date is not within an open acc period');
      RAISE invalid_date;
    END IF;

    /* Get the value of the profile "OIC: Skip Credit Allocation" */
    l_skip_credit_flag     := 'Y';
    IF (fnd_profile.defined('CN_SKIP_CREDIT_ALLOCATION')) THEN
      l_skip_credit_flag  := NVL(fnd_profile.VALUE('CN_SKIP_CREDIT_ALLOCATION'), 'Y');
    END IF;

    --+
    --+ Check Data in API table
    --+
    check_api_data(p_start_date => l_start_date, p_end_date => l_end_date, p_org_id => p_org_id);

    --+
    --+ Validate ruleset status if the classification and
    --+ rollup option is checked.
    --+
    IF (p_cls_rol_flag = 'Y') THEN
      debugmsg('Loader : validate ruleset status : p_start_date = ' || l_start_date);
      debugmsg('Loader : validate ruleset status : p_end_date = ' || l_end_date);

      IF NOT cn_proc_batches_pkg.validate_ruleset_status(l_start_date, l_end_date, p_org_id) THEN
        debugmsg('Loader : validate ruleset fails.');
        RAISE fail_validate_ruleset;
      END IF;
    END IF;

    SELECT cn_process_batches_s2.NEXTVAL INTO l_logical_batch_id FROM dual;

    INSERT INTO cn_process_batches(
                 process_batch_id
               , logical_batch_id
               , srp_period_id
               , period_id
               , end_period_id
               , start_date
               , end_date
               , salesrep_id
               , sales_lines_total
               , status_code
               , process_batch_type
               , creation_date
               , created_by
               , last_update_date
               , last_updated_by
               , last_update_login
               , request_id
               , program_application_id
               , program_id
               , program_update_date
               , org_id
               )
        ( SELECT cn_process_batches_s1.NEXTVAL
               , l_logical_batch_id
               , 1                            -- a dummy value for a not null column
               , batch.period_id              -- Start Period Id
               , batch.period_id              -- End Period Id
               , batch.start_date
               , batch.end_date
               , batch.salesrep_id
               , batch.trx_count
               , 'IN_USE'                     -- Status Code
               , 'CREATED_BY_LOADER'          -- Process Batch Type
               , SYSDATE
               , fnd_global.user_id
               , SYSDATE
               , fnd_global.user_id
               , fnd_global.login_id
               , fnd_global.conc_request_id
               , fnd_global.prog_appl_id
               , fnd_global.conc_program_id
               , SYSDATE
               , p_org_id
              FROM (
                     SELECT api.employee_number employee_number
                          , api.salesrep_id salesrep_id
                          , acc.period_id period_id
                          , acc.start_date start_date
                          , acc.end_date end_date
                          , COUNT(*) trx_count
                       FROM cn_comm_lines_api api, cn_acc_period_statuses_v acc
                      WHERE api.load_status = 'UNLOADED'
                        AND api.trx_type <> 'FORECAST'
                        AND (adjust_status <> 'SCA_PENDING' )-- OR adjust_status IS NULL)
                        AND api.processed_date >= TRUNC(l_start_date)
                        AND api.processed_date <(TRUNC(l_end_date) + 1)
                        AND ((p_salesrep_id IS NULL) OR(api.salesrep_id = p_salesrep_id))
                        AND api.processed_date >= acc.start_date
                        AND api.processed_date <(acc.end_date + 1)
                        AND ( l_skip_credit_flag = 'Y'
                              OR (api.terr_id IS NOT NULL OR api.preserve_credit_override_flag = 'Y') )
                      GROUP BY api.employee_number, api.salesrep_id, acc.period_id, acc.start_date, acc.end_date
                   ) batch );

    --+
    --+ If no trx to load, raise exception
    --+
    IF (SQL%ROWCOUNT = 0) THEN
      debugmsg('Loader : No transactions to load.');
      RAISE no_trx_lines;
    END IF;

    -- Split the logical batch into smaller physical batches
    -- populate the physical_batch_id in cn_process_batches
    assign(p_logical_batch_id => l_logical_batch_id, p_org_id => p_org_id);

    -- Submit independent concurrent programs for each physical batch
    -- These physical batches will be executed in parallel
    pre_conc_dispatch(
      p_salesrep_id                => p_salesrep_id
    , p_start_date                 => l_start_date
    , p_end_date                   => l_end_date
    , p_org_id                     => p_org_id
    );

    conc_dispatch(
      x_parent_proc_audit_id       => l_process_audit_id
    , x_salesrep_id                => p_salesrep_id
    , x_start_date                 => l_start_date
    , x_end_date                   => l_end_date
    , x_cls_rol_flag               => p_cls_rol_flag
    , x_logical_batch_id           => l_logical_batch_id
    );

    post_conc_dispatch(
      p_salesrep_id                => p_salesrep_id
    , p_start_date                 => l_start_date
    , p_end_date                   => l_end_date
    , p_org_id                     => p_org_id
    );

    -- Mark the processed batches for deletion
    void_batches(p_physical_batch_id => NULL, p_logical_batch_id => l_logical_batch_id);

    -- Call end_batch to end debug log file
    debugmsg('Loader : End of Loader');
    cn_message_pkg.end_batch(l_process_audit_id);

  EXCEPTION
    WHEN invalid_date THEN
      -- Call end_batch to end debug log file
	  errbuf := 'Parameter End Date is not within an open acc period';
      retcode := 1;
      debugmsg('Loader : End of Loader');
      cn_message_pkg.end_batch(l_process_audit_id);
    WHEN no_trx_lines THEN
      -- Call end_batch to end debug log file
	  errbuf := 'No transactions to load';
      retcode := 1;
      debugmsg('Loader : End of Loader');
      cn_message_pkg.end_batch(l_process_audit_id);
    WHEN fail_validate_ruleset THEN
	  errbuf := 'Ruleset validation failed';
      retcode := 1;
      debugmsg('Loader : validate ruleset fails.');
      debugmsg('Loader : End of Loader');
      cn_message_pkg.end_batch(l_process_audit_id);
    WHEN OTHERS THEN
      debugmsg('Loader : Unexpected exception.');
      -- Call end_batch to end debug log file
	  errbuf := SQLERRM;
      retcode := 2;
      debugmsg('Loader : End of Loader');
      cn_message_pkg.end_batch(l_process_audit_id);
  END LOAD;

  -- Procedure Name
  --   Assign
  -- Purpose
  PROCEDURE load_worker(
    p_physical_batch_id NUMBER
  , p_salesrep_id       NUMBER
  , p_start_date        DATE
  , p_end_date          DATE
  , p_cls_rol_flag      VARCHAR2
  ) IS
    CURSOR batches IS
      SELECT salesrep_id
           , period_id
           , start_date
           , end_date
           , sales_lines_total trx_count
        FROM cn_process_batches
       WHERE physical_batch_id = p_physical_batch_id AND status_code = 'IN_USE';

    counter                     NUMBER;
    l_counter                   NUMBER;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_return_status             VARCHAR2(30);
    l_init_commission_header_id NUMBER;
    l_skip_credit_flag          VARCHAR2(1);
  BEGIN
    counter             := 0;
    /* Get the value of the profile "OIC: Skip Credit Allocation" */
    l_skip_credit_flag  := 'Y';

    IF (fnd_profile.defined('CN_SKIP_CREDIT_ALLOCATION')) THEN
      l_skip_credit_flag  := NVL(fnd_profile.VALUE('CN_SKIP_CREDIT_ALLOCATION'), 'Y');
    END IF;

    -- this is used to make it more restrict for handling reversal trx later on
    SELECT cn_commission_headers_s.NEXTVAL
      INTO l_init_commission_header_id
      FROM DUAL;

    FOR batch IN batches LOOP
      debugmsg(
           'Loader : Load_Worker : Load '
        || TO_CHAR(batch.trx_count)
        || ' lines for physical batch = '
        || p_physical_batch_id
        || ' salesrep id = '
        || batch.salesrep_id
        || ' period_id = '
        || batch.period_id
        || ' p_salesrep_id = '
        || p_salesrep_id
        || ' p_start_date = '
        || p_start_date
        || ' p_end_date = '
        || p_end_date
        || ' p_cls_rol_flag = '
        || p_cls_rol_flag
      );
      counter  := counter + batch.trx_count;

      IF (l_skip_credit_flag = 'Y') THEN
        INSERT INTO cn_commission_headers
                    (
                     commission_header_id
                   , direct_salesrep_id
                   , processed_date
                   , processed_period_id
                   , rollup_date
                   , transaction_amount
                   , quantity
                   , discount_percentage
                   , margin_percentage
                   , orig_currency_code
                   , transaction_amount_orig
                   , trx_type
                   , status
                   , pre_processed_code
                   , comm_lines_api_id
                   , source_doc_type
                   , source_trx_number
                   , quota_id
                   , srp_plan_assign_id
                   , revenue_class_id
                   , role_id
                   , comp_group_id
                   , commission_amount
                   , reversal_flag
                   , reversal_header_id
                   , reason_code
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
                   , last_update_date
                   , last_updated_by
                   , last_update_login
                   , creation_date
                   , created_by
                   , exchange_rate
                   , forecast_id
                   , upside_quantity
                   , upside_amount
                   , uom_code
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
                   , bill_to_address_id
                   , ship_to_address_id
                   , bill_to_contact_id
                   , ship_to_contact_id
                   , adj_comm_lines_api_id
                   , adjust_date
                   , adjusted_by
                   , revenue_type
                   , adjust_rollup_flag
                   , adjust_comments
                   , adjust_status
                   , line_number
                   , TYPE
                   , sales_channel
                   , split_pct
                   , split_status
                   , org_id
                    )   -- vensrini transaction load fix
          (SELECT cn_commission_headers_s.NEXTVAL
                , batch.salesrep_id
                , TRUNC(api.processed_date)
                , batch.period_id
                , TRUNC(api.rollup_date)
                , api.acctd_transaction_amount
                , api.quantity
                , api.discount_percentage
                , api.margin_percentage
                , api.transaction_currency_code
                , api.transaction_amount
                , api.trx_type
                , 'COL'
                , NVL(api.pre_processed_code, 'CRPC')
                , api.comm_lines_api_id
                , api.source_doc_type
                , api.source_trx_number
                , api.quota_id
                , api.srp_plan_assign_id
                , api.revenue_class_id
                , api.role_id
                , api.comp_group_id
                , api.commission_amount
                , api.reversal_flag
                , api.reversal_header_id
                , api.reason_code
                , api.attribute_category
                , api.attribute1
                , api.attribute2
                , api.attribute3
                , api.attribute4
                , api.attribute5
                , api.attribute6
                , api.attribute7
                , api.attribute8
                , api.attribute9
                , api.attribute10
                , api.attribute11
                , api.attribute12
                , api.attribute13
                , api.attribute14
                , api.attribute15
                , api.attribute16
                , api.attribute17
                , api.attribute18
                , api.attribute19
                , api.attribute20
                , api.attribute21
                , api.attribute22
                , api.attribute23
                , api.attribute24
                , api.attribute25
                , api.attribute26
                , api.attribute27
                , api.attribute28
                , api.attribute29
                , api.attribute30
                , api.attribute31
                , api.attribute32
                , api.attribute33
                , api.attribute34
                , api.attribute35
                , api.attribute36
                , api.attribute37
                , api.attribute38
                , api.attribute39
                , api.attribute40
                , api.attribute41
                , api.attribute42
                , api.attribute43
                , api.attribute44
                , api.attribute45
                , api.attribute46
                , api.attribute47
                , api.attribute48
                , api.attribute49
                , api.attribute50
                , api.attribute51
                , api.attribute52
                , api.attribute53
                , api.attribute54
                , api.attribute55
                , api.attribute56
                , api.attribute57
                , api.attribute58
                , api.attribute59
                , api.attribute60
                , api.attribute61
                , api.attribute62
                , api.attribute63
                , api.attribute64
                , api.attribute65
                , api.attribute66
                , api.attribute67
                , api.attribute68
                , api.attribute69
                , api.attribute70
                , api.attribute71
                , api.attribute72
                , api.attribute73
                , api.attribute74
                , api.attribute75
                , api.attribute76
                , api.attribute77
                , api.attribute78
                , api.attribute79
                , api.attribute80
                , api.attribute81
                , api.attribute82
                , api.attribute83
                , api.attribute84
                , api.attribute85
                , api.attribute86
                , api.attribute87
                , api.attribute88
                , api.attribute89
                , api.attribute90
                , api.attribute91
                , api.attribute92
                , api.attribute93
                , api.attribute94
                , api.attribute95
                , api.attribute96
                , api.attribute97
                , api.attribute98
                , api.attribute99
                , api.attribute100
                , SYSDATE
                , api.last_updated_by
                , api.last_update_login
                , SYSDATE
                , api.created_by
                , api.exchange_rate
                , api.forecast_id
                , api.upside_quantity
                , api.upside_amount
                , api.uom_code
                , api.source_trx_id
                , api.source_trx_line_id
                , api.source_trx_sales_line_id
                , api.negated_flag
                , api.customer_id
                , api.inventory_item_id
                , api.order_number
                , api.booked_date
                , api.invoice_number
                , api.invoice_date
                , api.bill_to_address_id
                , api.ship_to_address_id
                , api.bill_to_contact_id
                , api.ship_to_contact_id
                , api.adj_comm_lines_api_id
                , api.adjust_date
                , api.adjusted_by
                , api.revenue_type
                , api.adjust_rollup_flag
                , api.adjust_comments
                , NVL(api.adjust_status,'NEW')
                , api.line_number
                , api.TYPE
                , api.sales_channel
                , api.split_pct
                , api.split_status
                , api.org_id   -- vensrini transaction load fix
             FROM cn_comm_lines_api api
            WHERE api.load_status = 'UNLOADED'
              AND api.processed_date >= TRUNC(p_start_date)
              AND api.processed_date <(TRUNC(p_end_date) + 1)
              AND api.trx_type <> 'FORECAST'
              AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
              AND api.salesrep_id = batch.salesrep_id
              AND api.processed_date >= TRUNC(batch.start_date)
              AND api.processed_date <(TRUNC(batch.end_date) + 1)
              AND NOT EXISTS(SELECT 'this transaction has already been loaded'
                               FROM cn_commission_headers_all cmh
                              WHERE cmh.comm_lines_api_id = api.comm_lines_api_id));
      ELSE
        INSERT INTO cn_commission_headers
                    (
                     commission_header_id
                   , direct_salesrep_id
                   , processed_date
                   , processed_period_id
                   , rollup_date
                   , transaction_amount
                   , quantity
                   , discount_percentage
                   , margin_percentage
                   , orig_currency_code
                   , transaction_amount_orig
                   , trx_type
                   , status
                   , pre_processed_code
                   , comm_lines_api_id
                   , source_doc_type
                   , source_trx_number
                   , quota_id
                   , srp_plan_assign_id
                   , revenue_class_id
                   , role_id
                   , comp_group_id
                   , commission_amount
                   , reversal_flag
                   , reversal_header_id
                   , reason_code
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
                   , last_update_date
                   , last_updated_by
                   , last_update_login
                   , creation_date
                   , created_by
                   , exchange_rate
                   , forecast_id
                   , upside_quantity
                   , upside_amount
                   , uom_code
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
                   , bill_to_address_id
                   , ship_to_address_id
                   , bill_to_contact_id
                   , ship_to_contact_id
                   , adj_comm_lines_api_id
                   , adjust_date
                   , adjusted_by
                   , revenue_type
                   , adjust_rollup_flag
                   , adjust_comments
                   , adjust_status
                   , line_number
                   , TYPE
                   , sales_channel
                   , split_pct
                   , split_status
                   , org_id
                    )   -- vensrini transaction load fix
          (SELECT cn_commission_headers_s.NEXTVAL
                , batch.salesrep_id
                , TRUNC(api.processed_date)
                , batch.period_id
                , TRUNC(api.rollup_date)
                , api.acctd_transaction_amount
                , api.quantity
                , api.discount_percentage
                , api.margin_percentage
                , api.transaction_currency_code
                , api.transaction_amount
                , api.trx_type
                , 'COL'
                , NVL(api.pre_processed_code, 'CRPC')
                , api.comm_lines_api_id
                , api.source_doc_type
                , api.source_trx_number
                , api.quota_id
                , api.srp_plan_assign_id
                , api.revenue_class_id
                , api.role_id
                , api.comp_group_id
                , api.commission_amount
                , api.reversal_flag
                , api.reversal_header_id
                , api.reason_code
                , api.attribute_category
                , api.attribute1
                , api.attribute2
                , api.attribute3
                , api.attribute4
                , api.attribute5
                , api.attribute6
                , api.attribute7
                , api.attribute8
                , api.attribute9
                , api.attribute10
                , api.attribute11
                , api.attribute12
                , api.attribute13
                , api.attribute14
                , api.attribute15
                , api.attribute16
                , api.attribute17
                , api.attribute18
                , api.attribute19
                , api.attribute20
                , api.attribute21
                , api.attribute22
                , api.attribute23
                , api.attribute24
                , api.attribute25
                , api.attribute26
                , api.attribute27
                , api.attribute28
                , api.attribute29
                , api.attribute30
                , api.attribute31
                , api.attribute32
                , api.attribute33
                , api.attribute34
                , api.attribute35
                , api.attribute36
                , api.attribute37
                , api.attribute38
                , api.attribute39
                , api.attribute40
                , api.attribute41
                , api.attribute42
                , api.attribute43
                , api.attribute44
                , api.attribute45
                , api.attribute46
                , api.attribute47
                , api.attribute48
                , api.attribute49
                , api.attribute50
                , api.attribute51
                , api.attribute52
                , api.attribute53
                , api.attribute54
                , api.attribute55
                , api.attribute56
                , api.attribute57
                , api.attribute58
                , api.attribute59
                , api.attribute60
                , api.attribute61
                , api.attribute62
                , api.attribute63
                , api.attribute64
                , api.attribute65
                , api.attribute66
                , api.attribute67
                , api.attribute68
                , api.attribute69
                , api.attribute70
                , api.attribute71
                , api.attribute72
                , api.attribute73
                , api.attribute74
                , api.attribute75
                , api.attribute76
                , api.attribute77
                , api.attribute78
                , api.attribute79
                , api.attribute80
                , api.attribute81
                , api.attribute82
                , api.attribute83
                , api.attribute84
                , api.attribute85
                , api.attribute86
                , api.attribute87
                , api.attribute88
                , api.attribute89
                , api.attribute90
                , api.attribute91
                , api.attribute92
                , api.attribute93
                , api.attribute94
                , api.attribute95
                , api.attribute96
                , api.attribute97
                , api.attribute98
                , api.attribute99
                , api.attribute100
                , SYSDATE
                , api.last_updated_by
                , api.last_update_login
                , SYSDATE
                , api.created_by
                , api.exchange_rate
                , api.forecast_id
                , api.upside_quantity
                , api.upside_amount
                , api.uom_code
                , api.source_trx_id
                , api.source_trx_line_id
                , api.source_trx_sales_line_id
                , api.negated_flag
                , api.customer_id
                , api.inventory_item_id
                , api.order_number
                , api.booked_date
                , api.invoice_number
                , api.invoice_date
                , api.bill_to_address_id
                , api.ship_to_address_id
                , api.bill_to_contact_id
                , api.ship_to_contact_id
                , api.adj_comm_lines_api_id
                , api.adjust_date
                , api.adjusted_by
                , api.revenue_type
                , api.adjust_rollup_flag
                , api.adjust_comments
                , NVL(api.adjust_status,'NEW')
                , api.line_number
                , api.TYPE
                , api.sales_channel
                , api.split_pct
                , api.split_status
                , api.org_id   -- vensrini transaction load fix
             FROM cn_comm_lines_api api
            WHERE api.load_status = 'UNLOADED'
              AND api.processed_date >= TRUNC(p_start_date)
              AND api.processed_date <(TRUNC(p_end_date) + 1)
              AND api.trx_type <> 'FORECAST'
              AND (adjust_status <> 'SCA_PENDING')-- OR adjust_status IS NULL)
              AND api.salesrep_id = batch.salesrep_id
              AND api.processed_date >= TRUNC(batch.start_date)
              AND api.processed_date <(TRUNC(batch.end_date) + 1)
              AND (api.terr_id IS NOT NULL OR api.preserve_credit_override_flag = 'Y')
              AND NOT EXISTS(SELECT 'this transaction has already been loaded'
                               FROM cn_commission_headers_all cmh
                              WHERE cmh.comm_lines_api_id = api.comm_lines_api_id));
      END IF;   /* end if l_skip_credit_flag */

      debugmsg('Loader : number of loaded trx = ' || TO_CHAR(SQL%ROWCOUNT));

            -- Commented this query to fix bug# 1772128
      /*
      UPDATE cn_comm_lines_api api
        SET load_Status = 'LOADED'
        WHERE
        api.load_status  = 'UNLOADED' AND
        Trunc(api.processed_date) >= Trunc(p_start_date) AND
        Trunc(api.processed_date) <= Trunc(p_end_date) AND
        ((p_salesrep_id IS NULL) OR (api.salesrep_id = p_salesrep_id)) AND
        api.trx_type <> 'FORECAST' AND
        api.salesrep_id = batch.salesrep_id AND
        Trunc(api.processed_date) >= Trunc(batch.start_date) AND
        Trunc(api.processed_date) <= Trunc(batch.end_date);  */
      IF (l_skip_credit_flag = 'Y') THEN
        UPDATE cn_comm_lines_api api
           SET load_status = 'LOADED'
         WHERE api.load_status = 'UNLOADED'
           AND api.processed_date >= TRUNC(p_start_date)
           AND api.processed_date <(TRUNC(p_end_date) + 1)
           AND api.trx_type <> 'FORECAST'
           AND (adjust_status <> 'SCA_PENDING' )-- OR adjust_status IS NULL)
           AND api.salesrep_id = batch.salesrep_id
           AND api.processed_date >= TRUNC(batch.start_date)
           AND api.processed_date <(TRUNC(batch.end_date) + 1);
      ELSE
        UPDATE cn_comm_lines_api api
           SET load_status = 'LOADED'
         WHERE api.load_status = 'UNLOADED'
           AND api.processed_date >= TRUNC(p_start_date)
           AND api.processed_date <(TRUNC(p_end_date) + 1)
           AND api.trx_type <> 'FORECAST'
           AND (adjust_status <> 'SCA_PENDING' )-- OR adjust_status IS NULL)
           AND api.salesrep_id = batch.salesrep_id
           AND api.processed_date >= TRUNC(batch.start_date)
           AND api.processed_date <(TRUNC(batch.end_date) + 1)
           AND (api.terr_id IS NOT NULL OR api.preserve_credit_override_flag = 'Y');
      END IF;
    END LOOP;

    -- Handle reversal transaction add on 10/15/99
    DECLARE
      CURSOR l_headers IS
        SELECT cch.commission_header_id
             , cch.reversal_flag
             , cch.reversal_header_id
          FROM cn_commission_headers cch
             , (SELECT DISTINCT salesrep_id
                           FROM cn_process_batches
                          WHERE physical_batch_id = p_physical_batch_id AND status_code = 'IN_USE') pb
         WHERE cch.direct_salesrep_id = pb.salesrep_id
           AND cch.commission_header_id > l_init_commission_header_id;
    BEGIN
      FOR l_header IN l_headers LOOP
        -- Only pass in the "reversal" trx into handle_reversal_trx
        -- Do not pass in the original trx eventhough its reversal_flag = 'Y'
        IF     (l_header.reversal_flag = 'Y')
           AND (l_header.commission_header_id <> l_header.reversal_header_id) THEN
          cn_formula_common_pkg.handle_reversal_trx(l_header.commission_header_id);
        END IF;
      END LOOP;
    END;

    IF (p_cls_rol_flag = 'Y') THEN
      debugmsg('Loader : Load_Worker : Classify : p_physical_batch_id = ' || p_physical_batch_id);
      debugmsg('Loader : Load_Worker : Classify : calling cn_calc_classify_pvt.classify_batch');
      cn_calc_classify_pvt.classify_batch(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_true
      , p_commit                     => fnd_api.g_true
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_physical_batch_id          => p_physical_batch_id
      , p_mode                       => 'NEW'
      );
      debugmsg('Loader : Load_Worker : Classify : return status is ' || l_return_status);
      debugmsg('Loader : Load_Worker : Classify : l_msg_count is ' || l_msg_count);
      debugmsg('Loader : Load_Worker : Classify : l_msg_data is ' || l_msg_data);

      FOR l_counter IN 1 .. l_msg_count LOOP
        debugmsg(fnd_msg_pub.get(p_msg_index => l_counter, p_encoded => fnd_api.g_false));
      END LOOP;

      debugmsg('Loader : Load_Worker : Rollup : p_physical_batch_id = ' || p_physical_batch_id);
      debugmsg('Loader : Load_Worker : Rollup : calling cn_calc_classify_pvt.classify_batch');
      cn_calc_rollup_pvt.rollup_batch(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_true
      , p_commit                     => fnd_api.g_true
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_physical_batch_id          => p_physical_batch_id
      , p_mode                       => 'NEW'
      );
      debugmsg('Loader : Load_Worker : Rollup : return status is ' || l_return_status);
      debugmsg('Loader : Load_Worker : Rollup : l_msg_count is ' || l_msg_count);
      debugmsg('Loader : Load_Worker : Rollup : l_msg_data is ' || l_msg_data);

      FOR l_counter IN 1 .. l_msg_count LOOP
        debugmsg(fnd_msg_pub.get(p_msg_index => l_counter, p_encoded => fnd_api.g_false));
      END LOOP;
    ELSE
      debugmsg
        ('Loader : Load_Worker : classification/rollup flag is NO. Skip Classification and Rollup.');
    END IF;
  END load_worker;
END cn_transaction_load_pkg;

/
