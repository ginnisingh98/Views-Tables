--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_ADJUSTMENT_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_ADJUSTMENT_PROC" AS
--$Header: JMFRSKDB.pls 120.26 2006/08/18 11:06:08 shu noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|  FILENAME :           JMFRSKDB.pls                                        |
--|                                                                           |
--|  DESCRIPTION:         Body file for the private package containing        |
--|                       the logic of Component Consumption Adjustments.     |
--|                       It includes the main procedures to be invoked       |
--|                       by the Consumption Adjusments Concurrent Program.   |
--|                                                                           |
--|  FUNCTION/PROCEDURE:  adjustments_manager                                 |
--|                       check_workers_status                                |
--|                       adjustments_worker                                  |
--|                       adjust_consumption                                  |
--|                       adjust_positive                                     |
--|                       adjust_negative                                     |
--|                                                                           |
--|  HISTORY:                                                                 |
--|    28-MAY-2005        shu   Created.                                      |
--|    12-JUL-2005        vchu  Fixed GSCC errors (File.Sql.46).              |
--|                             Removed the init procedure.                   |
--|    22-JUL-2005        vchu  The transaction_id column has been removed    |
--|                             from the JMF_SHIKYU_ADJUSTMENTS table since   |
--|                             it is redundant of the request_id column.     |
--|                             All references to transaction_id have been    |
--|                             replaced by request_id in this package.       |
--|    03-OCT-2005        shu   Added calls to JMF_SHIKYU_UTIL.debug_output.  |
--|    05-OCT-2005        shu   Added Open cursor statement before fetch.     |
--|                             Replaced the condition cursor%FOUND with      |
--|                             cursor%ROWCOUNT > 0.                          |
--|    06-OCT-2005        shu   Added x_chr_errbuff,x_chr_retcode parameters  |
--|                             to adjustments_worker.                        |
--|    11-OCT-2005        shu   Added validation and error handle for         |
--|                             adjustments_manager IN parameters             |
--|    13-OCT-2005        shu   added process for the batch_id,request_id     |
--|    21-OCT-2005        shu   fixed index Null Exception in                 |
--|                             adjustments_manager                           |
--|    14-Nov-2005        shu   added debug info for exception handle         |
--|                             in adjust_positive and adjust_negative        |
--|    18-NOV-2005        shu   added code for setting request completed with |
--|                             warning if SHIKYU profile is disable          |
--|    21-NOV-2005        shu   added code for setting request completed with |
--|                             warning if exception raised                   |
--|    12-DEC-2005        shu   added check_workers_status procedure for      |
--|                             checking the status of adjustment workers     |
--|    12-DEC-2005        vchu  Modified the queries in the adjust_negative   |
--|                             procedure for getting the WIP consumed qty    |
--|                             and total allocated qty for the               |
--|                             Subcontracting Component being adjusted       |
--|   16-JAN-2006          shu  using FND_LOG.STRING for logging standard     |
--|   27-JAN-2006          shu  update the message according to seed data file|
--|   13-MAR-2006          the  remove Commented code                         |
--|   13-MAR-2006          the  added code for update the last_update_date    |
--|                             column with sysdate.                          |
--|   17-MAR-2006          the  fixed code to handle WIP transaction errors   |
--|   22-MAR-2006          the  added code for update the LAST_UPDATED_BY     |
--|                             column and column LAST_UPDATE_LOGIN           |                           |
--|   21-JUN-2006       nesoni  added get_total_adjustments function for      |
--|                             getting total adjustments corresponding to    |
--|                             poShipmentId and ShikyuComponentId.           |
--|   22-JUN-2006          the  Fixed bug #5234426: keep adjustment records   |
--|                             When adjust worker failed.                    |
--|   22-JUN-2006          the  Fixed bug #5471813: Set warning message when  |
--|                             not enough replenishment so.                  |                         |
--+===========================================================================+

  --=============================================
  -- CONSTANTS
  --=============================================
  G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'jmf.plsql.' || g_pkg_name || '.';
  G_DEFAULT_BATCH_SIZE CONSTANT NUMBER  := 100;
  G_DEFAULT_MAX_WORKERS CONSTANT NUMBER := 1;

  --=============================================
  -- GLOBAL VARIABLES
  --=============================================
  g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');

  TYPE g_cons_adj_id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  g_not_enough_replen_exc EXCEPTION;
  g_wip_issued_less_alloc_exc EXCEPTION;
  g_allocation_exc EXCEPTION;

  --========================================================================
  -- PROCEDURE : adjustments_manager    PUBLIC
  -- PARAMETERS: x_chr_errbuff          varchar out parameter for current program
  --             x_chr_retcode          varchar out parameter for current program
  --             p_batch_size           Number of records in a batch
  --             p_max_workers          Maximum number of workers allowed
  -- COMMENT   : for submit adjustment concurrent manually , the group_id is ignored
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE adjustments_manager
  ( x_chr_errbuff OUT NOCOPY VARCHAR2 /*to store error msg*/ --errbuf??
  , x_chr_retcode OUT NOCOPY VARCHAR2 /*to store return code*/ --retcode ??
  , p_batch_size  IN NUMBER
  , p_max_workers IN NUMBER
  )
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'adjustments_manager';

    l_p_batch_size  NUMBER;
    l_p_max_workers NUMBER;

    CURSOR c_negative_adj IS
      SELECT DISTINCT adjustment_id
        FROM jmf_shikyu_adjustments --JMF_SUBCONTRACT_ORDERS
       WHERE request_id IS NULL
         AND batch_id IS NULL
         AND adjustment < 0
      --AND group_id = NVL(p_group_id,group_id)   --group_id is for future use
       ORDER BY adjustment_id;

    CURSOR c_positive_adj IS
      SELECT DISTINCT adjustment_id
        FROM jmf_shikyu_adjustments --JMF_SUBCONTRACT_ORDERS
       WHERE request_id IS NULL
         AND batch_id IS NULL
         AND adjustment > 0
      --AND group_id = NVL(p_group_id,group_id)   --group_id is for future use
       ORDER BY adjustment_id;

    l_cons_adj_id_tbl       g_cons_adj_id_tbl_type;
    l_cur_cons_adj_id_index NUMBER;

    l_batch_request_id_tbl  g_cons_adj_id_tbl_type;
    l_cur_batch_id_index    NUMBER;

    l_cur_batch_min_adj_id  NUMBER;
    l_cur_batch_max_adj_id  NUMBER;
    l_counter               NUMBER;

    l_batch_id    NUMBER;
    l_workers     jmf_shikyu_util.g_request_tbl_type;
    l_adjust_rows NUMBER; -- the number of adjustments records with group_id = NVL(p_group_id,group_id)

    l_request_id    NUMBER; --the request id for the worker
    l_return_status VARCHAR2(1); --FND_API.G_RET_STS_SUCCESS or other status

    l_Manager_return_status  VARCHAR2(30);  --the status for adjustment manager.

    --for checking SHIKYU enable profile.
    l_jmf_shk_not_enabled VARCHAR2(240);
    l_conc_succ           BOOLEAN;

  BEGIN

    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name || '.begin'
           ,p_message   => '========(p_batch_size: ' || p_batch_size ||
                           ' , p_max_workers: ' || p_max_workers || ' ) ========'
          );
    -- **** for debug information in readonly UT environment.--- end ****

    --check if the SHIKYU enable profile is set to Yes. if no then return one error and stop.
    IF (NVL(FND_PROFILE.VALUE('JMF_SHK_CHARGE_BASED_ENABLED'), 'N') = 'N')
    THEN
      FND_MESSAGE.SET_NAME('JMF', 'JMF_SHK_NOT_ENABLE');
      l_jmf_shk_not_enabled := FND_MESSAGE.GET;

      fnd_file.PUT_LINE(fnd_file.LOG, l_jmf_shk_not_enabled);

      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                      ,g_module_prefix || l_api_name || '.warning'
                      ,l_jmf_shk_not_enabled);
      END IF;

      l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                         ,message => l_jmf_shk_not_enabled);
      /*l_conc_succ := fnd_concurrent.set_completion_status(status  => 'ERROR'
                                                         ,message => l_jmf_shk_not_enabled);*/
      IF l_conc_succ
      THEN
        x_chr_errbuff := 'complete concurrent successfully';
        x_chr_retcode := 'S';
      ELSE
        x_chr_errbuff := l_jmf_shk_not_enabled;
        x_chr_retcode := 'W';
      END IF;

      RETURN;
    END IF;

    -- verify the input parameters
    IF p_batch_size IS NULL OR p_batch_size <= 0 THEN
       l_p_batch_size := G_DEFAULT_BATCH_SIZE;
    ELSE
       l_p_batch_size := p_batch_size;
    END IF;
    IF p_max_workers IS NULL OR p_max_workers <= 0 THEN
       l_p_max_workers := G_DEFAULT_MAX_WORKERS;
    ELSE
       l_p_max_workers := p_max_workers;
    END IF;
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'begin, l_p_batch_size:' || l_p_batch_size ||
                           ',l_p_max_workers:' || l_p_max_workers
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.begin'
                    ,NULL);
    END IF;

    -- get the rows that need to be adjusted
    SELECT COUNT(adjustment_id)
      INTO l_adjust_rows
      FROM jmf_shikyu_adjustments
     WHERE request_id IS NULL
       AND batch_id IS NULL
       AND adjustment <> 0
    --AND group_id = NVL(p_group_id,group_id)   --group_id is for future use
    ;
    IF l_adjust_rows = 0
    THEN
      --No adjustment row.
      --fnd_message.set_name('JMF', 'JMF_SHIKYU_ADJ_MGR_NO_DATA');
      fnd_message.set_name('JMF', 'JMF_RPT_NO_DATA');
      fnd_msg_pub.add;
      RETURN;
    END IF;

      -- Process the negative adjustment data
      OPEN c_negative_adj;
      FETCH c_negative_adj BULK COLLECT
        INTO l_cons_adj_id_tbl;

      --deleted EXIT WHEN c_negative_adj %NOTFOUND; because need to do following steps
      --IF c_negative_adj %FOUND  -- seems although c_negative_adj.ROWCOUNT >0 it is %NOTFOUND
      IF c_negative_adj%ROWCOUNT > 0
      THEN
        -- begin of c_negative_adj %FOUND

        l_cur_cons_adj_id_index := l_cons_adj_id_tbl.FIRST;
        l_counter               := 0;

        LOOP

          IF l_counter = 0
          THEN
            --begin of l_counter = 0
            l_cur_batch_min_adj_id := l_cons_adj_id_tbl(l_cur_cons_adj_id_index);
            -- Get the next batch_id using the sequence for Consumption Adjustment
            SELECT jmf_shikyu_adj_batch_s.NEXTVAL
              INTO l_batch_id
              FROM dual;
          END IF; --end of l_counter = 0

          l_counter := l_counter + 1;
          -- **** for debug information in readonly UT environment.--- begin ****
          JMF_SHIKYU_RPT_UTIL.debug_output
                (
                  p_output_to => 'FND_LOG.STRING'
                 ,p_api_name  => G_MODULE_PREFIX || l_api_name
                 ,p_message   => 'c_negative_adj%ROWCOUNT:' || c_negative_adj%ROWCOUNT ||
                                 ' l_counter:' || l_counter || ',l_cur_cons_adj_id_index:' ||
                                 l_cur_cons_adj_id_index
                );
          -- **** for debug information in readonly UT environment.--- end ****

          IF (l_counter = l_p_batch_size OR l_cons_adj_id_tbl.NEXT(l_cur_cons_adj_id_index) IS NULL)
          THEN

            l_counter              := 0;
            l_cur_batch_max_adj_id := l_cons_adj_id_tbl(l_cur_cons_adj_id_index);

            UPDATE jmf_shikyu_adjustments
               SET batch_id = l_batch_id,
                   last_update_date = sysdate,
                   last_updated_by = FND_GLOBAL.user_id,
                   last_update_login = FND_GLOBAL.login_id
             WHERE adjustment_id >= l_cur_batch_min_adj_id
               AND adjustment_id <= l_cur_batch_max_adj_id
               AND request_id IS NULL
               AND batch_id IS NULL
               AND adjustment < 0
            --AND group_id = NVL(p_group_id,group_id)                  --for group--group_id is for future use
            ;

            -- Submit concurrent request for a Consumption Adjustments worker, which would
            -- check if the count of workers has reached max_workers count; if it has, wait
            -- until a worker finishes and then invoke the worker to process the batch

            jmf_shikyu_util.submit_worker(p_batch_id        => l_batch_id
                                         ,p_request_count   => l_p_max_workers
                                         ,p_cp_short_name   => 'JMFSKADW'
                                         ,p_cp_product_code => 'JMF'
                                         ,x_workers         => l_workers
                                         ,x_request_id      => l_request_id
                                         ,x_return_status   => l_return_status);
            --post actions after the worker request.
            x_chr_retcode := l_return_status;
            x_chr_errbuff := 'Submit_Worker negative request_id: ' || l_request_id || ', Return Status: ' || l_return_status;

            -- **** for debug information in readonly UT environment.--- begin ****
            JMF_SHIKYU_RPT_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => G_MODULE_PREFIX || l_api_name
                   ,p_message   => 'c_negative_adj%ROWCOUNT:' || c_negative_adj%ROWCOUNT ||
                                   'jmf_shikyu_util.submit_worker, l_return_status:' ||
                                   l_return_status || ',l_request_id:' || l_request_id
                  );
            -- **** for debug information in readonly UT environment.--- end ****


            IF l_return_status = fnd_api.g_ret_sts_success
            THEN
              /*UPDATE jmf_shikyu_adjustments
                 SET request_id = l_request_id,
                     last_update_date = sysdate,
                     last_updated_by = FND_GLOBAL.user_id,
                     last_update_login = FND_GLOBAL.login_id
               WHERE batch_id = l_batch_id
              --AND request_id IS NULL
              ;*/
              l_batch_request_id_tbl(l_batch_id) := l_request_id;

            -- **** for debug information in readonly UT environment.--- begin ****
            JMF_SHIKYU_RPT_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => G_MODULE_PREFIX || l_api_name
                   ,p_message   => 'Negative Adjustment: l_batch_id: ' || l_batch_id ||
                                   ' ,l_batch_request_id_tbl.COUNT: ' || l_batch_request_id_tbl.COUNT ||
                                   ' ,l_request_id: ' || l_request_id
                  );
            -- **** for debug information in readonly UT environment.--- end ****
            ELSE
              UPDATE jmf_shikyu_adjustments
                 SET batch_id = NULL,
                     last_update_date = sysdate,
                     last_updated_by = FND_GLOBAL.user_id,
                     last_update_login = FND_GLOBAL.login_id
               WHERE batch_id = l_batch_id
              --AND request_id IS NULL
              ;
            END IF;

          END IF; --end of (l_counter = l_p_batch_size OR l_cur_cons_adj_id_index IS NULL)

          -- deleted l_cur_cons_adj_id_index := l_cons_adj_id_tbl.next(l_cur_cons_adj_id_index)
          l_cur_cons_adj_id_index := l_cons_adj_id_tbl.NEXT(l_cur_cons_adj_id_index);
          EXIT WHEN l_cur_cons_adj_id_index IS NULL;

        END LOOP; --end of loop c_negative_adj

      END IF; -- IF c_negative_adj%ROWCOUNT > 0; end of c_negative_adj %FOUND
      CLOSE c_negative_adj;

      --Wait for all the workers submitted for the negative adjustmemt data to complete;
      jmf_shikyu_util.wait_for_all_workers(p_workers => l_workers);

      -- Process the positive adjustment data
      OPEN c_positive_adj;
      FETCH c_positive_adj BULK COLLECT
        INTO l_cons_adj_id_tbl;

      --deleted  EXIT WHEN c_positive_adj %NOTFOUND; because need to do following steps
      --IF c_positive_adj %FOUND  -- seems although c_positive_adj.ROWCOUNT >0 it is %NOTFOUND
      IF c_positive_adj%ROWCOUNT > 0
      THEN
        -- begin of c_positive_adj %FOUND

        l_cur_cons_adj_id_index := l_cons_adj_id_tbl.FIRST;
        l_counter               := 0;

        LOOP

          IF l_counter = 0
          THEN
            l_cur_batch_min_adj_id := l_cons_adj_id_tbl(l_cur_cons_adj_id_index);
            -- Get the next batch_id using the sequence for Consumption Adjustment
            SELECT jmf_shikyu_adj_batch_s.NEXTVAL
              INTO l_batch_id
              FROM dual;
          END IF;

          l_counter := l_counter + 1;
          -- **** for debug information in readonly UT environment.--- begin ****
          JMF_SHIKYU_RPT_UTIL.debug_output
                (
                  p_output_to => 'FND_LOG.STRING'
                 ,p_api_name  => G_MODULE_PREFIX || l_api_name
                 ,p_message   => 'c_positive_adj%ROWCOUNT:' || c_positive_adj%ROWCOUNT ||
                                 ' l_counter:' || l_counter || ',l_cur_cons_adj_id_index:' ||
                                 l_cur_cons_adj_id_index
                );
          -- **** for debug information in readonly UT environment.--- end ****

          IF (l_counter = l_p_batch_size OR l_cons_adj_id_tbl.NEXT(l_cur_cons_adj_id_index) IS NULL)
          THEN
            l_counter              := 0;
            l_cur_batch_max_adj_id := l_cons_adj_id_tbl(l_cur_cons_adj_id_index);

            UPDATE jmf_shikyu_adjustments
               SET batch_id = l_batch_id,
                   last_update_date = sysdate,
                   last_updated_by = FND_GLOBAL.user_id,
                   last_update_login = FND_GLOBAL.login_id
             WHERE adjustment_id >= l_cur_batch_min_adj_id
               AND adjustment_id <= l_cur_batch_max_adj_id
               AND request_id IS NULL
               AND batch_id IS NULL
               AND adjustment > 0
            --AND group_id = NVL(p_group_id,group_id)                  --for group --group_id is for future use
            ;

            -- Submit concurrent request for a Consumption Adjustments worker, which would
            -- check if the count of workers has reached max_workers count; if it has, wait
            -- until a worker finishes and then invoke the worker to process the batch

            jmf_shikyu_util.submit_worker(p_batch_id        => l_batch_id
                                         ,p_request_count   => l_p_max_workers
                                         ,p_cp_short_name   => 'JMFSKADW'
                                         ,p_cp_product_code => 'JMF'
                                         ,x_workers         => l_workers
                                         ,x_request_id      => l_request_id
                                         ,x_return_status   => l_return_status);

            --post actions after the worker request.
            x_chr_retcode := l_return_status;
            x_chr_errbuff := 'Submit_Worker positive request_id: ' || l_request_id || ', Return Status: ' || l_return_status;

            -- **** for debug information in readonly UT environment.--- begin ****
            JMF_SHIKYU_RPT_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => G_MODULE_PREFIX || l_api_name
                   ,p_message   => 'c_positive_adj%ROWCOUNT:' || c_positive_adj%ROWCOUNT ||
                                   'jmf_shikyu_util.submit_worker, l_return_status:' ||
                                   l_return_status || ',l_request_id:' || l_request_id
                  );
            -- **** for debug information in readonly UT environment.--- end ****

            IF l_return_status = fnd_api.g_ret_sts_success
            THEN
              /*UPDATE jmf_shikyu_adjustments
                 SET request_id = l_request_id,
                     last_update_date = sysdate,
                     last_updated_by = FND_GLOBAL.user_id,
                     last_update_login = FND_GLOBAL.login_id
               WHERE batch_id = l_batch_id*/
              --AND request_id IS NULL
              l_batch_request_id_tbl(l_batch_id) := l_request_id
              ;
              -- **** for debug information in readonly UT environment.--- begin ****
              JMF_SHIKYU_RPT_UTIL.debug_output
                    (
                      p_output_to => 'FND_LOG.STRING'
                     ,p_api_name  => G_MODULE_PREFIX || l_api_name
                     ,p_message   => 'Positive Adjustment: l_batch_id: ' || l_batch_id ||
                                     ' ,l_batch_request_id_tbl.COUNT: ' || l_batch_request_id_tbl.COUNT ||
                                     ' ,l_request_id: ' || l_request_id
                    );
              -- **** for debug information in readonly UT environment.--- end ****
            ELSE
              UPDATE jmf_shikyu_adjustments
                 SET batch_id = NULL,
                     last_update_date = sysdate,
                     last_updated_by = FND_GLOBAL.user_id,
                     last_update_login = FND_GLOBAL.login_id
               WHERE batch_id = l_batch_id
              --AND request_id IS NULL
              ;
            END IF;

          END IF; --end of (l_counter = l_p_batch_size OR l_cur_cons_adj_id_index IS NULL)

          l_cur_cons_adj_id_index := l_cons_adj_id_tbl.NEXT(l_cur_cons_adj_id_index);
          EXIT WHEN l_cur_cons_adj_id_index IS NULL;

        END LOOP;

      END IF; -- IF c_positive_adj%ROWCOUNT > 0 ;end of c_positive_adj %FOUND

      CLOSE c_positive_adj;

    --20051212 add wait the submit workers, and check the workers' status to set the return manager status.
      --Wait for all the workers submitted for the positive adjustmemt data to complete;
      jmf_shikyu_util.wait_for_all_workers(p_workers => l_workers);

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.end'
                    ,NULL);
    END IF;

    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'Update jmf_shikyu_adjustments'
          );
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'l_batch_request_id_tbl.COUNT: ' || l_batch_request_id_tbl.COUNT
          );
    -- **** for debug information in readonly UT environment.--- end ****

    l_cur_batch_id_index := l_batch_request_id_tbl.FIRST;

    LOOP
      EXIT WHEN l_cur_batch_id_index IS NULL;

      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'l_cur_batch_id_index: ' || l_cur_batch_id_index ||
                             ' ,l_batch_request_id_tbl(' || l_cur_batch_id_index || ': ' || l_batch_request_id_tbl(l_cur_batch_id_index) ||
                             ' ,l_request_id: ' || l_request_id
            );
      -- **** for debug information in readonly UT environment.--- end ****

      UPDATE jmf_shikyu_adjustments
         SET request_id = l_batch_request_id_tbl(l_cur_batch_id_index),
             last_update_date = sysdate,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE batch_id = l_cur_batch_id_index
         AND request_id IS NULL
      ;
      UPDATE jmf_shikyu_adjustments
         SET request_id = NULL,
             batch_id = NULL,
             last_update_date = sysdate,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE batch_id = l_cur_batch_id_index
         AND request_id = -1
      ;

      l_cur_batch_id_index := l_batch_request_id_tbl.NEXT(l_cur_batch_id_index);

    END LOOP; --end of loop c_negative_adj

    --20051013 add to update the batch_id that without request rows to be process again.
    UPDATE jmf_shikyu_adjustments
       SET batch_id = NULL,
           last_update_date = sysdate,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
     WHERE request_id IS NULL
       AND batch_id IS NOT NULL;

    -- commit the data
    COMMIT;

    --check the submit workers status, and then set print the worker status into logfile, set the manager status
    --if one of the worker status FND_API.G_RET_STS_UNEXP_ERROR, then set Warning.
    check_workers_status(p_workers       =>  l_workers
                        ,x_return_status =>  l_Manager_return_status);

    IF l_Manager_return_status <> 'NORMAL'
    THEN
        -- set the adjustment manager concurrent completed with Warning
      l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                         ,message => 'Not all Workers complete with NORMAL');
    END IF;

    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name || '.end'
           ,p_message   => 'Adjustment Manager End at'
                           || to_char(SYSDATE,'YYYY-MM-DD HH:MM:SS')
          );
    -- **** for debug information in readonly UT environment.--- end ****

  EXCEPTION
    WHEN no_data_found THEN
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'no_data_found.EXCEPTION:' || SQLERRM
            );
      -- **** for debug information in readonly UT environment.--- end ****
      fnd_message.set_name('JMF', 'JMF_SHK_ADJ_MGR_ERROR');
      fnd_msg_pub.add;

      -- rollback
      ROLLBACK;

    WHEN OTHERS THEN
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => ' WHEN OTHERS.EXCEPTION:' || SQLERRM
            );
      -- **** for debug information in readonly UT environment.--- end ****

      --fnd_message.set_name('JMF', 'JMF_SHIKYU_ADJ_MGR_ERROR');
      fnd_message.set_name('JMF', 'JMF_SHK_ADJ_MGR_ERROR');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;

      -- rollback
      ROLLBACK;

  END adjustments_manager;

  --========================================================================
  -- PROCEDURE : check_workers_status    PUBLIC
  -- PARAMETERS: p_workers            Identifier of the submitted requests
  --             x_return_status      the status of worker request, if not 'NORMAL'
  -- COMMENT   :
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE check_workers_status
  (p_workers	      IN  jmf_shikyu_util.g_request_tbl_type
  ,x_return_status  OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'check_workers_status';

    l_request_id         fnd_concurrent_requests.request_id%TYPE;
    l_parent_request_id  fnd_concurrent_requests.parent_request_id%TYPE;

    CURSOR l_cur_workers_request(
             lp_parent_request_id fnd_concurrent_requests.parent_request_id%TYPE)
      IS
      SELECT request_id
        FROM fnd_concurrent_requests
       WHERE parent_request_id = lp_parent_request_id
       ORDER BY request_id;

    -- for FND_CONCURRENT.get_request_status
    l_get_request_status BOOLEAN;
    l_phase          VARCHAR2(30);
    l_status         VARCHAR2(30);
    l_dev_phase      VARCHAR2(30);
    l_dev_status     VARCHAR2(30);
    l_message        VARCHAR2(240);

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'Begin'
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.begin'
                    ,NULL);
    END IF;

    -- check the request status
    IF p_workers.COUNT >0 THEN
      l_request_id := p_workers(1);

      SELECT parent_request_id
        INTO l_parent_request_id
        FROM fnd_concurrent_requests
       WHERE request_id = l_request_id;
        -- **** for debug information in readonly UT environment.--- begin ****
        JMF_SHIKYU_RPT_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => G_MODULE_PREFIX || l_api_name
               ,p_message   => '***-------------Consumption adjustment request:' ||
                               ' l_parent_request_id' || '--------------***.'
              );
        -- **** for debug information in readonly UT environment.--- end ****

        -- **** for debug information in readonly UT environment.--- begin ****
        JMF_SHIKYU_RPT_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => G_MODULE_PREFIX || l_api_name
               ,p_message   => '***-------------Begin of worker request information--------------***.'
              );
        -- **** for debug information in readonly UT environment.--- end ****

        OPEN l_cur_workers_request(l_parent_request_id);
        LOOP
          --find the tp organizations
          FETCH l_cur_workers_request
            INTO l_request_id;

          EXIT WHEN l_cur_workers_request%NOTFOUND; -- no more tp organiztions

          l_get_request_status := FND_CONCURRENT.get_request_status(
                                    request_id     => l_request_id
                                   ,appl_shortname => NULL --l_appl_shortname
                                   ,program        => NULL --l_program
                                   ,phase          => l_phase
                                   ,status         => l_status
                                   ,dev_phase      => l_dev_phase
                                   ,dev_status     => l_dev_status
                                   ,message        => l_message);

          IF l_dev_status <> 'NORMAL'
          THEN
              x_return_status := l_dev_status;
          END IF;
          -- **** for debug information in readonly UT environment.--- begin ****
          JMF_SHIKYU_RPT_UTIL.debug_output
                (
                  p_output_to => 'FND_LOG.STRING'
                 ,p_api_name  => G_MODULE_PREFIX || l_api_name
                 ,p_message   => 'Worker status, request_id:' || l_request_id
                                 || ',phase:' || l_phase
                                 || ',status:' || l_status
                                 || ',dev_phase:' || l_dev_phase
                                 || ',dev_status:' || l_dev_status
                                 || ',message:' || l_message
                );
          -- **** for debug information in readonly UT environment.--- end ****

        END LOOP; --end loop of finding the tp organizations
        CLOSE l_cur_workers_request;

        -- **** for debug information in readonly UT environment.--- begin ****
        JMF_SHIKYU_RPT_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => G_MODULE_PREFIX || l_api_name
               ,p_message   => '***-------------End of worker request information--------------***.'
              );
        -- **** for debug information in readonly UT environment.--- end ****

    ELSE
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'No workers submit.'
            );
      -- **** for debug information in readonly UT environment.--- end ****
    END IF;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.end'
                    ,NULL);
    END IF;
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'End'
          );
    -- **** for debug information in readonly UT environment.--- end ****

  END check_workers_status;

  --========================================================================
  -- PROCEDURE : adjustments_worker    PUBLIC
  -- PARAMETERS: x_chr_errbuff         varchar out parameter for current program
  --             x_chr_retcode         varchar out parameter for current program
  --             p_batch_id            Identifier of the batch of rows to be processed
  -- COMMENT   :
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE adjustments_worker
  (
    x_chr_errbuff   OUT NOCOPY VARCHAR2 /*to store error msg*/ --errbuf??
   ,x_chr_retcode   OUT NOCOPY VARCHAR2 /*to store return code*/ --retcode ??
   ,p_batch_id      IN NUMBER
  )
  IS
    l_return_status  VARCHAR2(30);
    l_api_name CONSTANT VARCHAR2(30) := 'adjustments_worker';

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'Begin, p_batch_id:' || p_batch_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.begin'
                    ,NULL);
    END IF;

    -- Invoke Adjust_Consumption which does the processing of the batch
    adjust_consumption(p_batch_id      => p_batch_id
                      ,x_return_status => l_return_status);

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.end'
                    ,l_return_status);
    END IF;
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'End, p_batch_id:' || p_batch_id
                           || ',x_chr_errbuff:' || x_chr_errbuff
                           || ',x_chr_retcode:' || x_chr_retcode
                           || ',l_return_status:' || l_return_status
          );
    -- **** for debug information in readonly UT environment.--- end ****

  END adjustments_worker;

  --========================================================================
  -- PROCEDURE : adjust_consumption    PUBLIC
  -- PARAMETERS: p_batch_id            Identifier of the batch of rows to be processed
  --           : x_return_status       return status
  -- COMMENT   :  This is the main procedure to be kicked off by the Consumptioin Adjustments
  --              Concurrent Program.  It sorts the adjustment records in ascending order of
  --              the adjustment amount and then processes each record by calling either the
  --              Adjust_Positive or the Adjust_Negative procedure.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE adjust_consumption
  ( p_batch_id      IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  )
  IS

    l_api_name CONSTANT VARCHAR2(30) := 'adjust_consumption';

    CURSOR c_adj IS
      SELECT adjustment_id
            ,subcontract_po_shipment_id
            ,shikyu_component_id
            ,adjustment
            ,uom
        FROM jmf_shikyu_adjustments
       WHERE batch_id = p_batch_id
       ORDER BY adjustment;

    l_adjustment_id              jmf_shikyu_adjustments.adjustment_id%TYPE;
    l_subcontract_po_shipment_id jmf_shikyu_adjustments.subcontract_po_shipment_id%TYPE;
    l_shikyu_component_id        jmf_shikyu_adjustments.shikyu_component_id%TYPE;
    l_adjustment                 jmf_shikyu_adjustments.adjustment%TYPE;
    l_uom                        jmf_shikyu_adjustments.uom%TYPE;

  BEGIN
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'Begin, p_batch_id:' || p_batch_id
          );
    -- **** for debug information in readonly UT environment.--- end ****

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.begin'
                    ,NULL);
    END IF;

    OPEN c_adj;
    LOOP

      FETCH c_adj
        INTO l_adjustment_id, l_subcontract_po_shipment_id, l_shikyu_component_id, l_adjustment, l_uom;

      EXIT WHEN c_adj%NOTFOUND;

      IF l_adjustment < 0
      THEN
        adjust_negative(p_subcontract_po_shipment_id => l_subcontract_po_shipment_id
                       ,p_component_id               => l_shikyu_component_id
                       ,p_adjustment_amount          => l_adjustment * -1
                       ,p_uom                        => l_uom
                       ,x_return_status              => x_return_status);
      ELSE
        adjust_positive(p_subcontract_po_shipment_id => l_subcontract_po_shipment_id
                       ,p_component_id               => l_shikyu_component_id
                       ,p_adjustment_amount          => l_adjustment
                       ,p_uom                        => l_uom
                       ,x_return_status              => x_return_status);
      END IF; -- end of l_adjustment < 0

      --need to do ******update the request_id column in jmf_shikyu_adjustment table if the adjustment is successful.
      --set request_id = ????

      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'x_return_status: ' || x_return_status
            );
      -- **** for debug information in readonly UT environment.--- end ****
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        -- **** for debug information in readonly UT environment.--- begin ****
        JMF_SHIKYU_RPT_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => G_MODULE_PREFIX || l_api_name
               ,p_message   => 'l_adjustment_id: ' || l_adjustment_id
              );
        -- **** for debug information in readonly UT environment.--- end ****
        UPDATE jmf_shikyu_adjustments
        SET request_id = -1,
            last_update_date = sysdate,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
        WHERE adjustment_id = l_adjustment_id;
      END IF;

    END LOOP;
    CLOSE c_adj;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.end'
                    ,NULL);
    END IF;
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'End, p_batch_id:' || p_batch_id
          );
    -- **** for debug information in readonly UT environment.--- end ****


  EXCEPTION
    WHEN no_data_found THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

        --Set message name;
        fnd_message.set_name('JMF', 'JMF_SHK_ADJ_MGR_ERROR');
        fnd_log.MESSAGE(LOG_LEVEL   => FND_LOG.LEVEL_EXCEPTION
                       ,MODULE      => g_module_prefix || l_api_name ||
                                     '.no_data_found'
                       ,POP_MESSAGE => FALSE);
      END IF;
      --FND_MSG_PUB.add;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      x_return_status := fnd_api.g_ret_sts_error;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'no_data_found.EXCEPTION:' || SQLERRM
            );
      -- **** for debug information in readonly UT environment.--- end ****

    WHEN OTHERS THEN
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        --Set message name;
        fnd_message.set_name('JMF', 'JMF_SHK_ADJ_MGR_ERROR');
        fnd_log.MESSAGE(LOG_LEVEL   => FND_LOG.LEVEL_UNEXPECTED
                       ,MODULE      => g_module_prefix || l_api_name || '.others'
                       ,POP_MESSAGE => FALSE);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS.EXCEPTION:'  || SQLERRM
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END adjust_consumption;

  --========================================================================
  -- PROCEDURE : adjust_positive       PUBLIC
  -- PARAMETERS: p_subcontract_po_shipment_id    Unique Identifier of the Subcontracting
  --                                             Order Shipment whose component consumption is to be adjusted.
  --             p_component_id                  p_component_id Identifier of the SHIKYU Component
  --                                             for which the consumption is to be adjusted.
  --             p_adjustment_amount             Amount to adjust the component consumtion by.
  --             p_uom                           Unit of Measure of the adjustment amount.
  --             x_return_status                 return status.
  -- COMMENT   :  This procedure processes an adjustment record with a positive adjustment amount,
  --              meaning that the Manufacturing Partner has over-utilized the SHIKYU Component.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE adjust_positive
  ( p_subcontract_po_shipment_id IN NUMBER
  , p_component_id               IN NUMBER
  , p_adjustment_amount          IN NUMBER
  , p_uom                        IN VARCHAR2
  , x_return_status              OUT NOCOPY VARCHAR2
  )
  IS

    l_api_name CONSTANT VARCHAR2(30) := 'adjust_positive';

    l_available_replen_so_qty_tbl jmf_shikyu_allocation_pvt.g_replen_so_qty_tbl_type;
    l_deallocated_rep_so_qty_tbl jmf_shikyu_allocation_pvt.g_allocation_qty_tbl_type;
    l_remaining_qty               NUMBER;

    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(240);
    l_qty_allocated NUMBER;
    l_actual_reduced_qty NUMBER;

    l_component     mtl_system_items_b_kfv.concatenated_segments%TYPE;
    l_po_num        po_headers_all.segment1%TYPE;
    l_po_line_num   po_lines_all.line_num%TYPE;
    l_shipment_num  po_line_locations.SHIPMENT_NUM%TYPE;
    l_allocable_qty NUMBER;

    --for message log.
    l_jmf_shk_exception   VARCHAR2(240);
    l_conc_succ           BOOLEAN;

  BEGIN

    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'Begin, p_subcontract_po_shipment_id:' || p_subcontract_po_shipment_id
                           || ',p_component_id:' || p_component_id
                           || ',p_adjustment_amount:' || p_adjustment_amount
                           || ',p_uom:' || p_uom
          );
    -- **** for debug information in readonly UT environment.--- end ****
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.begin'
                    ,NULL);
    END IF;

    jmf_shikyu_allocation_pvt.get_available_replenishment_so(p_api_version                => 1.0
                                                            ,p_init_msg_list              => NULL
                                                            ,x_return_status              => x_return_status
                                                            ,x_msg_count                  => l_msg_count
                                                            ,x_msg_data                   => l_msg_data
                                                            ,p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
                                                            ,p_component_id               => p_component_id
                                                             --, p_uom                     => p_uom
                                                            ,p_qty                       => p_adjustment_amount
                                                            ,p_include_additional_supply => 'Y'
                                                            ,p_arrived_so_lines_only     => 'Y' --to search for Replenishment SO Lines for allocations based on the condition that
                                                             --the Replenishment SO Line's ship date + in-transit lead time (i.e. expected arrival time) <= SYSDATE.
                                                            ,x_available_replen_tbl => l_available_replen_so_qty_tbl
                                                            ,x_remaining_qty        => l_remaining_qty);
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'end of jmf_shikyu_allocation_pvt.get_available_replenishment_so, x_return_status:' || x_return_status
                             || ',x_remaining_qty:' || l_remaining_qty
                             || ',x_msg_data:' || l_msg_data
            );
      -- **** for debug information in readonly UT environment.--- end ****

    -- Raise an exception if there is not enough existing replenishments
    IF l_remaining_qty > 0
    THEN
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'RAISE g_not_enough_replen_exc:'
                             || 'l_remaining_qty:' || l_remaining_qty
            );
      -- **** for debug information in readonly UT environment.--- end ****
      RAISE g_not_enough_replen_exc;
      -- Allocate if there is not enough existing replenishments
    ELSE
      jmf_shikyu_allocation_pvt.allocate_quantity(p_api_version                => 1.0
                                                 ,p_init_msg_list              => NULL
                                                 ,x_return_status              => x_return_status
                                                 ,x_msg_count                  => l_msg_count
                                                 ,x_msg_data                   => l_msg_data
                                                 ,p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
                                                 ,p_component_id               => p_component_id
                                                 ,p_qty_to_allocate            => p_adjustment_amount
                                                 ,p_available_replen_tbl       => l_available_replen_so_qty_tbl
                                                 ,x_qty_allocated              => l_qty_allocated);
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'end of jmf_shikyu_allocation_pvt.allocate_quantity, x_return_status:' || x_return_status
                             || ',x_qty_allocated:' || l_qty_allocated
                             || ',x_msg_data:' || l_msg_data
            );
      -- **** for debug information in readonly UT environment.--- end ****

      IF x_return_status = FND_API.G_RET_STS_SUCCESS
      THEN
        -- only when the allocated action is ok, the WIP will issue component, or the data will be in inconsistent
        jmf_shikyu_inv_pvt.process_wip_component_issue(p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
                                                      ,p_quantity                   => p_adjustment_amount --p_adjustment
                                                      ,p_component_id               => p_component_id
                                                      ,p_uom                        => p_uom
                                                      ,x_return_status              => x_return_status);
        -- **** for debug information in readonly UT environment.--- begin ****
        JMF_SHIKYU_RPT_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => G_MODULE_PREFIX || l_api_name
               ,p_message   => 'end of jmf_shikyu_inv_pvt.process_wip_component_issue, x_return_status:' || x_return_status
                               || ',p_subcontract_po_shipment_id:' || p_subcontract_po_shipment_id
                               || ',p_component_id:' || p_component_id
                               || ',p_quantity:' || p_adjustment_amount
              );
        -- **** for debug information in readonly UT environment.--- end ****
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
          --first reduce the allocation
          jmf_shikyu_allocation_pvt.reduce_allocations(p_api_version                => 1.0
                                                      ,p_init_msg_list              => NULL
                                                      ,x_return_status              => x_return_status
                                                      ,x_msg_count                  => l_msg_count --'x_msg_count'
                                                      ,x_msg_data                   => l_msg_data --x_msg_data
                                                      ,p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
                                                      ,p_component_id               => p_component_id
                                                      ,p_replen_so_line_id          => NULL -- pass in NULL would deallocate in LIFO order of ship date and order
                                                      ,p_qty_to_reduce           => p_adjustment_amount
                                                      ,x_actual_reduced_qty      => l_actual_reduced_qty
                                                      ,x_reduced_allocations_tbl => l_deallocated_rep_so_qty_tbl);
          -- **** for debug information in readonly UT environment.--- begin ****
          JMF_SHIKYU_RPT_UTIL.debug_output
                (
                  p_output_to => 'FND_LOG.STRING'
                 ,p_api_name  => G_MODULE_PREFIX || l_api_name
                 ,p_message   => 'end of reduce the allocation, x_return_status:' || x_return_status
                                 || ',x_actual_reduced_qty:' || l_actual_reduced_qty
                                 || ',x_msg_data:' || l_msg_data
                );
          -- **** for debug information in readonly UT environment.--- end ****
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
            -- **** for debug information in readonly UT environment.--- begin ****
            JMF_SHIKYU_RPT_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => G_MODULE_PREFIX || l_api_name
                   ,p_message   => 'RAISE g_allocation_exc:'
                                   || 'reduce_allocations failed '
                                   || 'when the return status of '
                                   ||'process_wip_component_issue is not Success.'
                  );
            -- **** for debug information in readonly UT environment.--- end ****
            -- raise exception
            RAISE g_allocation_exc;
          END IF; -- end of x_return_status <> FND_API.G_RET_STS_SUCCESS for reduce_allocations
        END IF; -- end of x_return_status <> FND_API.G_RET_STS_SUCCESS for process_wip_component_issue
      END IF; -- end of x_return_status = FND_API.G_RET_STS_SUCCESS for allocate_quantity
    END IF; -- end of l_remaining_qty > 0

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.end'
                    ,NULL);
    END IF;
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'End, p_subcontract_po_shipment_id:' || p_subcontract_po_shipment_id
                           || ',p_component_id:' || p_component_id
                           || ',p_adjustment_amount:' || p_adjustment_amount
                           || ',p_uom:' || p_uom
          );
    -- **** for debug information in readonly UT environment.--- end ****

  EXCEPTION
    WHEN no_data_found THEN

      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN

        --Set message name;
        fnd_message.set_name('JMF', 'JMF_SHK_ADJ_MGR_ERROR');
        fnd_log.MESSAGE(LOG_LEVEL   => FND_LOG.LEVEL_EXCEPTION
                       ,MODULE      => g_module_prefix || l_api_name ||
                                       '.no_data_found'
                       ,POP_MESSAGE => FALSE);
        --Call FND_LOG.string;
        fnd_log.STRING(FND_LOG.LEVEL_EXCEPTION
                      ,g_module_prefix || l_api_name || '.no_data_found'
                      ,'JMF_SHIKYU_ADJ_MGR_ERROR');
      END IF;

      --fnd_message.set_name('JMF', 'JMF_SHIKYU_ADJ_MGR_ERROR');
      fnd_message.set_name('JMF', 'JMF_SHK_ADJ_MGR_ERROR');
      FND_MSG_PUB.Add;

      x_return_status := fnd_api.g_ret_sts_error;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'no_data_found Exception:' || SQLERRM
            );
      -- **** for debug information in readonly UT environment.--- end ****

    WHEN g_not_enough_replen_exc THEN

      --Set message name;
    	fnd_message.set_name('JMF', 'JMF_SHK_POS_ADJ_ERROR');

      SELECT ph.segment1                    po_number
            ,pl.line_num                    po_line_num
            ,pll.shipment_num               po_shipment_num
            ,item_kfv.concatenated_segments Item_num
        INTO l_po_num
            ,l_po_line_num
            ,l_shipment_num
            ,l_component
       FROM po_headers_all         ph
           ,po_lines_all           pl
           ,po_line_locations_all  pll
           ,mtl_system_items_b_kfv item_kfv
           ,jmf_shikyu_components  jsc
      WHERE pl.po_line_id = pll.po_line_id
        AND ph.po_header_id = pll.po_header_id
        AND pll.ship_to_organization_id = item_kfv.organization_id
        AND jsc.shikyu_component_id = item_kfv.inventory_item_id
        AND jsc.subcontract_po_shipment_id = pll.line_location_id
        AND pll.line_location_id = p_subcontract_po_shipment_id
        AND item_kfv.inventory_item_id = p_component_id;

      l_allocable_qty := p_adjustment_amount - l_remaining_qty;

      FND_MESSAGE.SET_TOKEN('COMPONENT', l_component);
      FND_MESSAGE.SET_TOKEN('PONUM', l_po_num);
      FND_MESSAGE.SET_TOKEN('POLINENUM', l_po_line_num);
      FND_MESSAGE.SET_TOKEN('PO_SHIPMENTNUM', l_shipment_num);
      FND_MESSAGE.SET_TOKEN('ALOQTY', l_allocable_qty);
      FND_MESSAGE.SET_TOKEN('ADJQTY', p_adjustment_amount);

      --FND_MSG_PUB.Add;

      l_jmf_shk_exception := FND_MESSAGE.GET;

      fnd_file.put_line(fnd_file.LOG
                       ,l_jmf_shk_exception);

      l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                         ,message => l_jmf_shk_exception);

      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'g_not_enough_replen_exc: message: ' || l_jmf_shk_exception
            );
      -- **** for debug information in readonly UT environment.--- end ****

      x_return_status := fnd_api.g_ret_sts_error;

      --Call FND_LOG.string;
      --Print the FND Error Message 'JMF_SHIKYU_POS_ADJ_ERROR' to the concurrent request log file;
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        fnd_log.STRING(FND_LOG.LEVEL_EXCEPTION
                      ,g_module_prefix || l_api_name || '.g_excep_level'
                      ,'g_not_enough_replen_exc');
      END IF;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'EXCEPTION:g_not_enough_replen_exc ,l_po_num' || l_po_num
                             || ',l_po_line_num:' || l_po_line_num
                             || ',l_allocable_qty:' || l_allocable_qty
                             || ',p_adjustment_amount:' || p_adjustment_amount
                             || '.SQLERRM:'  || SQLERRM
            );
      -- **** for debug information in readonly UT environment.--- end ****

    WHEN OTHERS THEN
      --Set message name;
      fnd_message.set_name('JMF', 'JMF_SHK_ADJ_MGR_ERROR');
      --Call FND_LOG.string;
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        fnd_log.STRING(FND_LOG.LEVEL_UNEXPECTED
                      ,g_module_prefix || l_api_name ||
                       '.JMF_SHIKYU_ADJ_MGR_ERROR'
                      ,'JMF_SHIKYU_ADJ_MGR_ERROR');
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS:'  || SQLERRM
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END adjust_positive;

  --========================================================================
  -- PROCEDURE : adjust_negative       PUBLIC
  -- PARAMETERS: p_subcontract_po_shipment_id    Unique Identifier of the Subcontracting
  --                                             Order Shipment whose component consumption is to be adjusted.
  --             p_component_id                  p_component_id Identifier of the SHIKYU Component
  --                                             for which the consumption is to be adjusted.
  --             p_adjustment_amount             Amount to adjust the component consumtion by.
  --             p_uom                           Unit of Measure of the adjustment amount.
  --             x_return_status                 return status.
  -- COMMENT   :    This procedure processes an adjustment record with a negative adjustment amount,
  --                meaning that the Manufacturing Partner has under-utilized the SHIKYU Component.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE adjust_negative
  ( p_subcontract_po_shipment_id IN NUMBER
  , p_component_id               IN NUMBER
  , p_adjustment_amount          IN NUMBER
  , p_uom                        IN VARCHAR2
  , x_return_status              OUT NOCOPY VARCHAR2
  )
  IS

    l_api_name CONSTANT VARCHAR2(30) := 'adjust_negative';

    l_deallocated_rep_so_qty_tbl jmf_shikyu_allocation_pvt.g_allocation_qty_tbl_type;
    l_available_replen_so_qty_tbl jmf_shikyu_allocation_pvt.g_replen_so_qty_tbl_type;

    l_qty_allocated NUMBER;
    l_actual_reduced_qty  NUMBER;
    l_wip_consumed_qty    NUMBER;
    l_wip_consumed_uom    VARCHAR2(3);
    l_total_allocated_qty NUMBER;
    l_total_allocated_uom VARCHAR2(3);

    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(240);

    --for message log.
    l_jmf_shk_exception   VARCHAR2(240);
    l_conc_succ           BOOLEAN;
    l_remaining_qty       NUMBER;

  BEGIN

    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'Begin, p_subcontract_po_shipment_id:' || p_subcontract_po_shipment_id
                           || ',p_component_id:' || p_component_id
                           || ',p_adjustment_amount:' || p_adjustment_amount
                           || ',p_uom:' || p_uom
          );
    -- **** for debug information in readonly UT environment.--- end ****
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.begin'
                    ,NULL);
    END IF;

    --get the WIP consumed qty
    SELECT wro.quantity_issued
          ,jsc.primary_uom
      INTO l_wip_consumed_qty
          ,l_wip_consumed_uom
      FROM wip_requirement_operations wro
          ,jmf_subcontract_orders     jso
          ,jmf_shikyu_components      jsc
     WHERE wro.wip_entity_id = jso.wip_entity_id
       AND wro.organization_id = jso.tp_organization_id
       AND wro.inventory_item_id = jsc.shikyu_component_id
       AND wro.repetitive_schedule_id IS NULL
       AND wro.operation_seq_num = 1
       AND jso.subcontract_po_shipment_id = jsc.subcontract_po_shipment_id
       AND jsc.subcontract_po_shipment_id = p_subcontract_po_shipment_id
       AND jsc.shikyu_component_id = p_component_id;

    --get the total allocated qty
    SELECT SUM(jsa.allocated_quantity)   --this meam the jsa.allocated_quantity is under Primary UOM
          ,MAX(jsa.uom)
      INTO l_total_allocated_qty
          ,l_total_allocated_uom
      FROM jmf_shikyu_allocations jsa
     WHERE jsa.subcontract_po_shipment_id = p_subcontract_po_shipment_id
       AND jsa.shikyu_component_id = p_component_id;

    IF l_wip_consumed_qty > l_total_allocated_qty
    THEN
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'RAISE g_wip_issued_less_alloc_exc:'
                             || 'l_wip_consumed_qty:' || l_wip_consumed_qty
                             || '> l_total_allocated_qty:' || l_total_allocated_qty
                             || 'in Primary UOM' || l_wip_consumed_uom
            );
      -- **** for debug information in readonly UT environment.--- end ****

      -- raise exception
      RAISE g_wip_issued_less_alloc_exc;
    ELSE
      --first reduce the allocation
      jmf_shikyu_allocation_pvt.reduce_allocations(p_api_version                => 1.0
                                                  ,p_init_msg_list              => NULL
                                                  ,x_return_status              => x_return_status
                                                  ,x_msg_count                  => l_msg_count --'x_msg_count'
                                                  ,x_msg_data                   => l_msg_data --x_msg_data
                                                  ,p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
                                                  ,p_component_id               => p_component_id
                                                  ,p_replen_so_line_id          => NULL -- pass in NULL would deallocate in LIFO order of ship date and order                  => p_uom
                                                  ,p_qty_to_reduce           => p_adjustment_amount
                                                  ,x_actual_reduced_qty      => l_actual_reduced_qty
                                                  ,x_reduced_allocations_tbl => l_deallocated_rep_so_qty_tbl);
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'end of reduce the allocation, x_return_status:' || x_return_status
                             || ',x_actual_reduced_qty:' || l_actual_reduced_qty
                             || ',x_msg_data:' || l_msg_data
            );
      -- **** for debug information in readonly UT environment.--- end ****


      IF x_return_status = FND_API.G_RET_STS_SUCCESS
      THEN
        --return component for the WIP
        jmf_shikyu_inv_pvt.process_wip_component_return(p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
                                                       ,p_quantity                   => l_actual_reduced_qty --not p_adjustment_amount
                                                       ,p_component_id               => p_component_id
                                                       ,p_uom                        => p_uom
                                                       ,x_return_status              => x_return_status);
        -- **** for debug information in readonly UT environment.--- begin ****
        JMF_SHIKYU_RPT_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => G_MODULE_PREFIX || l_api_name
               ,p_message   => 'end of component for the WIP, x_return_status:' || x_return_status
              );
        -- **** for debug information in readonly UT environment.--- end ****
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
          jmf_shikyu_allocation_pvt.get_available_replenishment_so(p_api_version                => 1.0
                                                                  ,p_init_msg_list              => NULL
                                                                  ,x_return_status              => x_return_status
                                                                  ,x_msg_count                  => l_msg_count
                                                                  ,x_msg_data                   => l_msg_data
                                                                  ,p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
                                                                  ,p_component_id               => p_component_id
                                                                  ,p_qty                       => p_adjustment_amount
                                                                  ,p_include_additional_supply => 'Y'
                                                                  ,p_arrived_so_lines_only     => 'Y' --to search for Replenishment SO Lines for allocations based on the condition that
                                                                   --the Replenishment SO Line's ship date + in-transit lead time (i.e. expected arrival time) <= SYSDATE.
                                                                  ,x_available_replen_tbl => l_available_replen_so_qty_tbl
                                                                  ,x_remaining_qty        => l_remaining_qty);
            -- **** for debug information in readonly UT environment.--- begin ****
            JMF_SHIKYU_RPT_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => G_MODULE_PREFIX || l_api_name
                   ,p_message   => 'end of jmf_shikyu_allocation_pvt.get_available_replenishment_so, x_return_status:' || x_return_status
                                   || ',x_remaining_qty:' || l_remaining_qty
                                   || ',x_msg_data:' || l_msg_data
                  );
            -- **** for debug information in readonly UT environment.--- end ****

          -- Raise an exception if there is not enough existing replenishments
          IF l_remaining_qty > 0
          THEN
            -- **** for debug information in readonly UT environment.--- begin ****
            JMF_SHIKYU_RPT_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => G_MODULE_PREFIX || l_api_name
                   ,p_message   => 'RAISE g_not_enough_replen_exc:'
                                   || 'l_remaining_qty:' || l_remaining_qty
                  );
            -- **** for debug information in readonly UT environment.--- end ****
            RAISE g_not_enough_replen_exc;
            -- Allocate if there is not enough existing replenishments
          ELSE
            jmf_shikyu_allocation_pvt.allocate_quantity(p_api_version                => 1.0
                                                       ,p_init_msg_list              => NULL
                                                       ,x_return_status              => x_return_status
                                                       ,x_msg_count                  => l_msg_count
                                                       ,x_msg_data                   => l_msg_data
                                                       ,p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
                                                       ,p_component_id               => p_component_id
                                                       ,p_qty_to_allocate            => p_adjustment_amount
                                                       ,p_available_replen_tbl       => l_available_replen_so_qty_tbl
                                                       ,x_qty_allocated              => l_qty_allocated);
            -- **** for debug information in readonly UT environment.--- begin ****
            JMF_SHIKYU_RPT_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => G_MODULE_PREFIX || l_api_name
                   ,p_message   => 'end of jmf_shikyu_allocation_pvt.allocate_quantity, x_return_status:' || x_return_status
                                   || ',x_qty_allocated:' || l_qty_allocated
                                   || ',x_msg_data:' || l_msg_data
                  );
            -- **** for debug information in readonly UT environment.--- end ****
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
              -- **** for debug information in readonly UT environment.--- begin ****
              JMF_SHIKYU_RPT_UTIL.debug_output
                    (
                      p_output_to => 'FND_LOG.STRING'
                     ,p_api_name  => G_MODULE_PREFIX || l_api_name
                     ,p_message   => 'RAISE g_allocation_exc:'
                                     || 'allocate_quantity failed '
                                     || 'when the return status of '
                                     || 'process_wip_component_return is not Success.'
                    );
              -- **** for debug information in readonly UT environment.--- end ****
              -- raise exception
              RAISE g_allocation_exc;
            END IF; -- end of x_return_status <> FND_API.G_RET_STS_SUCCESS for allocate_quantity
          END IF; -- end of l_remaining_qty > 0
        END IF; -- end of x_return_status <> FND_API.G_RET_STS_SUCCESS for process_wip_component_return
      END IF; -- end of x_return_status = FND_API.G_RET_STS_SUCCESS for reduce_allocations
    END IF; --end of  l_WIP_consumed_qty > l_total_allocated_qty

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                    ,g_module_prefix || l_api_name || '.end'
                    ,NULL);
    END IF;
    -- **** for debug information in readonly UT environment.--- begin ****
    JMF_SHIKYU_RPT_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => G_MODULE_PREFIX || l_api_name
           ,p_message   => 'End, p_subcontract_po_shipment_id:' || p_subcontract_po_shipment_id
                           || ',p_component_id:' || p_component_id
                           || ',p_adjustment_amount:' || p_adjustment_amount
                           || ',p_uom:' || p_uom
          );
    -- **** for debug information in readonly UT environment.--- end ****

  EXCEPTION
    WHEN no_data_found THEN
      --Call FND_LOG.string;
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        fnd_log.STRING(FND_LOG.LEVEL_EXCEPTION
                      ,g_module_prefix || l_api_name || '.no_data_found'
                      ,'NO_DATA_FOUND:'  || SQLERRM);
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'NO_DATA.'  || SQLERRM
            );
      -- **** for debug information in readonly UT environment.--- end ****

    WHEN g_wip_issued_less_alloc_exc THEN
      /*--WIP consumed more than allocated qty, exception log
      FND_MESSAGE.SET_NAME('JMF', 'JMF_SHK_WIP_MORE');
      l_jmf_shk_exception := FND_MESSAGE.GET;
      */
      l_jmf_shk_exception := 'Exception: WIP job consumed qty(' || l_wip_consumed_qty ||
                             ') is more than total allocated qty(' ||
                              l_total_allocated_qty || '), UOM :'
                              || l_wip_consumed_uom;
      --Call FND_LOG.string;
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        fnd_log.STRING(FND_LOG.LEVEL_EXCEPTION
                      ,g_module_prefix || l_api_name ||
                       '.g_wip_issued_less_alloc_exc'
                      ,l_jmf_shk_exception);
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => l_jmf_shk_exception || '.' || SQLERRM
            );
      -- **** for debug information in readonly UT environment.--- end ****

      fnd_file.put_line(fnd_file.LOG
                       ,l_jmf_shk_exception);

      l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                         ,message => l_jmf_shk_exception);

    WHEN OTHERS THEN
      --Call FND_LOG.string;
      IF g_fnd_debug = 'Y' AND
         FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL

      THEN
        fnd_log.STRING(FND_LOG.LEVEL_UNEXPECTED
                      ,g_module_prefix || l_api_name || '.unexp_error'
                      ,'unexpected error'  || SQLERRM);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      -- **** for debug information in readonly UT environment.--- begin ****
      JMF_SHIKYU_RPT_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => G_MODULE_PREFIX || l_api_name
             ,p_message   => 'WHEN OTHERS: ' || SQLERRM
            );
      -- **** for debug information in readonly UT environment.--- end ****

  END adjust_negative;

  --========================================================================
  -- FUNCTION  : get_total_adjustments  PUBLIC ,
  -- PARAMETERS: p_po_shipment_id       Subcontracting Purchase Order Shipment Id
  --             p_component_id         component Id of OSA item
  -- COMMENT   : Function for getting total adjustments corresponding to
  --             poShipmentId and ShikyuComponentId.
  -- RETURN   : NUMBER                 Returns total adjusted value
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_total_adjustments
  ( p_po_shipment_id      IN NUMBER
  , p_component_id IN NUMBER
  ) RETURN NUMBER IS
  l_adjustment_total NUMBER;
  BEGIN
     SELECT nvl(SUM(adjustment), 0)
     INTO l_adjustment_total
     FROM jmf_shikyu_adjustments
     WHERE subcontract_po_shipment_id = p_po_shipment_id
     AND shikyu_component_id = p_component_id
     AND request_id IS NOT NULL;

     RETURN l_adjustment_total;
 EXCEPTION
  WHEN no_data_found THEN
   RETURN 0;
 END;


END jmf_shikyu_adjustment_proc;

/
