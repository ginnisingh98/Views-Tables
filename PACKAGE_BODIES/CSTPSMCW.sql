--------------------------------------------------------
--  DDL for Package Body CSTPSMCW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPSMCW" AS
/* $Header: CSTSMCWB.pls 120.2 2006/06/14 10:26:28 sikhanna noship $ */

G_PKG_NAME VARCHAR2(240) := 'CSTPSMCW';
l_debug_flag VARCHAR2(1) := FND_PROFILE.VALUE('MRP_DEBUG');

----------------------------------------------------------------------------
-- PROCEDURE
-- LOT_TXN_COST_PROCESSOR
--                                                                        --
-- DESCRIPTION                                                            --
--  This procedure was called by the Lot Based Transaction Cost Worker
--  to cost WSM Txns prior to BOM patchset I(11.5.9). This is obseleted.
--  The procedure is retained for future release to allow the program to
--  exit cleanly in the event that it is launched by a user.
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--  Changes for Pre-Req patch for Pre 11i.9 customers
--  In 11.5.9, two important changes have been done:
--  1. OSFM updates Quantity Issued Columns
--  2. OSFM inserts transactions in MMT that are picked by the
--     cost processor
--  For customers, that are Pre 11i9 and need to use the new lot
--  transaction costing code, the above has to be done.
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--
-- PURPOSE:                                                               --
--  OSFM Lot Transactions Costing for Oracle Applications Rel 11i.9
--                                                                        --
-- HISTORY:                                                               --
--  August-2002         Vinit                       Obsoleted             --
----------------------------------------------------------------------------
PROCEDURE LOT_TXN_COST_PROCESSOR (RETCODE OUT NOCOPY number,
                                  ERRBUF OUT NOCOPY varchar2,
                                  p_org_id in number,
                                  p_group_id in number)IS

-- Flag indicating if the transaction is already inserted into MMT
l_txn_mmt_flag		NUMBER := 0;
l_req_id		NUMBER := -1;
l_user_id               NUMBER ;
l_login_id              NUMBER;
l_request_id            NUMBER ;
l_prog_appl_id          NUMBER ;
l_program_id            NUMBER ;
l_cmcicu_prog_id        NUMBER;
l_interval              NUMBER := 5;
l_maxwait               NUMBER := 120;

l_phase                 varchar(300);
l_status                varchar(300);
l_dev_phase             varchar(300);
l_dev_status            varchar(300);
l_message               varchar(300);
l_cmcicu_status         boolean;

conc_status             BOOLEAN;
l_err_code              VARCHAR2(8000);
l_err_msg               VARCHAR2(8000);

l_error_code            NUMBER := 0;
l_error_buf             VARCHAR2(240) := '';
l_txn_type_id           NUMBER;
l_stmt_num              NUMBER := 0;

CST_CSTPSMCW_RUNNING    EXCEPTION;
CST_CMCCCU_ORG_RUNNING  EXCEPTION;
INSERT_MMT_FAILURE      EXCEPTION;
UPDATE_QUANTITY_ISSUE_FAILURE EXCEPTION;


CURSOR c_uncost_sm_txn IS
  SELECT transaction_id,
         transaction_type_id,
         organization_id,
         transaction_date
  FROM   wsm_split_merge_transactions
  WHERE  costed = WIP_CONSTANTS.PENDING
  AND    status = WIP_CONSTANTS.COMPLETED
  AND    organization_id = p_org_id
  AND    group_id = p_group_id
  ORDER BY transaction_date,transaction_id;


BEGIN

  /* For 11i9 and above, return */
  IF WSMPVERS.GET_OSFM_RELEASE_VERSION >= '110509' THEN
    FND_FILE.put_line(fnd_file.log, 'This program is no longer supported');
    RETURN;
  ELSE
    /* Pre 11i.9 Processor */
    IF l_debug_flag = 'Y' THEN
      FND_FILE.put_line(fnd_file.log, 'Pre 11i.9 OSFM');
    END IF;

    l_user_id              := FND_GLOBAL.USER_ID;
    l_login_id             := FND_GLOBAL.LOGIN_ID;
    l_request_id           := FND_GLOBAL.CONC_REQUEST_ID;
    l_prog_appl_id         := FND_GLOBAL.PROG_APPL_ID;
    l_program_id           := FND_GLOBAL.CONC_PROGRAM_ID;

    l_err_msg              := '';
    l_err_code             := '';

    /* Check if another Lot based Cost Manager is Running */
    l_stmt_num := 10;

    SELECT nvl(max(fcr.request_id), -1)
    INTO   l_req_id
    FROM   fnd_concurrent_requests fcr
    WHERE  program_application_id = 702
    AND    concurrent_program_id = l_program_id
    AND    argument1 = TO_CHAR(p_org_id)
    AND    phase_code <> 'C'
    AND    fcr.request_id <> l_request_id;

    IF (l_req_id <> -1) THEN
      RAISE CST_CSTPSMCW_RUNNING;
    END IF;

    /* Check if a Standard Cost Update is Running */
    l_stmt_num := 20;
    SELECT concurrent_program_id
    INTO   l_cmcicu_prog_id
    FROM   fnd_concurrent_programs fcp
    WHERE  fcp.application_id = 702
    AND    fcp.concurrent_program_name = 'CMCICU';

    l_req_id := -1;

    l_stmt_num := 30;
    SELECT nvl(max(fcr.request_id), -1)
    INTO   l_req_id
    FROM   fnd_concurrent_requests fcr
    WHERE  program_application_id = 702
    AND    concurrent_program_id = l_cmcicu_prog_id
    AND    argument1 = TO_CHAR(p_org_id)
    AND    phase_code = 'R';

    l_stmt_num := 40;

    IF (l_req_id <> -1) THEN
      l_cmcicu_status := FND_CONCURRENT.WAIT_FOR_REQUEST(l_req_id,
                                                         l_interval,
                                                         l_maxwait,
                                                         l_phase,
                                                         l_status,
                                                         l_dev_phase,
                                                         l_dev_status,
                                                         l_message);
      IF (NOT (l_dev_phase = 'COMPLETE') and (l_dev_status = 'NORMAL')) THEN
        RAISE CST_CMCCCU_ORG_RUNNING;
      END IF;
    END IF;

    /* All transactions of type update_assembly,update_routing must
       be set to costed for the given organization and group
       These have no costing impact */

    l_stmt_num := 50;

    UPDATE wsm_split_merge_transactions
    SET    costed = WIP_CONSTANTS.COMPLETED
    WHERE  transaction_type_id in (3,5,7)
    AND    costed = WIP_CONSTANTS.PENDING
    AND    status = WIP_CONSTANTS.COMPLETED
    AND    organization_id = p_org_id
    AND    group_id        = p_group_id;

    l_stmt_num := 60;

    FOR c_uncost_rec in c_uncost_sm_txn LOOP
      SAVEPOINT START_OF_LOOP;
      /* Check if the transaction is not already in MMT */
      /* There is no index on source_line_id in MMT
         Hence this query is used to utilize existing index range
         scans */
        SELECT count(*)
        INTO   l_txn_mmt_flag
        FROM   mtl_material_transactions mmt,
               wsm_split_merge_transactions wsmt
        WHERE
        (transaction_source_id in
                 (select wip_entity_id
                  from   wsm_sm_resulting_jobs wsrj
                  where  wsrj.transaction_id = wsmt.transaction_id)
         or
         transaction_source_id in
                 (select wip_entity_id
                  from   wsm_sm_starting_jobs wssj
                  where  wssj.transaction_id = wsmt.transaction_id))
        AND mmt.organization_id = wsmt.organization_id
        AND mmt.source_line_id  = wsmt.transaction_id
        AND wsmt.transaction_id = c_uncost_rec.transaction_id;

      /* If it doesn't, call API's to insert transaction into MMT
         and update quantity */
      IF l_txn_mmt_flag = 0 THEN
        IF ( l_debug_flag = 'Y' ) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserting Transaction into MMT');
        END IF;

        -- Insert
        WSM_JobCosting_GRP.Insert_MaterialTxn (
                                  c_uncost_rec.transaction_id,
                                  l_error_code,
                                  l_error_buf );
        IF l_error_code <> 0 THEN
          RAISE INSERT_MMT_FAILURE;
        END IF;

        -- FIND TRANSACTION_TYPE
        SELECT TRANSACTION_TYPE_ID
        INTO   l_txn_type_id
        FROM   WSM_SPLIT_MERGE_TRANSACTIONS
        WHERE  transaction_id = c_uncost_rec.transaction_id;

        -- Update
        IF ( l_debug_flag = 'Y' ) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updating Quantities');
        END IF;
        WSM_JobCosting_GRP.Update_QtyIssued (
                                    c_uncost_rec.transaction_id,
                                    l_txn_type_id,
                                    l_error_code,
                                    l_error_buf );
        IF l_error_code <> 0 THEN
          RAISE UPDATE_QUANTITY_ISSUE_FAILURE;
        END IF;
        IF ( l_debug_flag = 'Y' ) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Check Material Transactions form to find if the transaction is costed');
        END IF;
      END IF;

    END LOOP;

  END IF;

EXCEPTION
  WHEN CST_CMCCCU_ORG_RUNNING THEN
    ROLLBACK;
    l_err_code := SUBSTR('CSTPSMCW.lot_txn_cost_processor('
                                || to_char(l_stmt_num)
                                || '): - 24003 '
                                || 'Req_id: '
                                || TO_CHAR(l_req_id)
                                || ' . ',1,240);

    fnd_message.set_name('BOM', 'CST_CMCCCU_ORG_RUNNING');
    l_err_msg := fnd_message.get;
    l_err_msg := SUBSTR(l_err_msg,1,240);
    FND_FILE.PUT_LINE(fnd_file.log,SUBSTR(l_err_code
                                                ||' '
                                                ||l_err_msg,1,240));

  WHEN CST_CSTPSMCW_RUNNING THEN
    ROLLBACK;
    l_err_code := SUBSTR('CSTPSMCW.lot_txn_cost_processor('
                                || to_char(l_stmt_num)
                                || '): - 24143 '
                                || 'Req_id: '
                                || TO_CHAR(l_req_id)
                                || ' . ',1,240);

    fnd_message.set_name('BOM', 'CST_CSTPSMCW_RUNNING');
    l_err_msg := fnd_message.get;
    l_err_msg := SUBSTR(l_err_msg,1,240);
    FND_FILE.PUT_LINE(fnd_file.log,SUBSTR(l_err_code
                                                   ||' '
                                                   ||l_err_msg,1,240));

    CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);

   WHEN UPDATE_QUANTITY_ISSUE_FAILURE THEN
     ROLLBACK;
     l_err_msg := SUBSTR('CSTPSMCW.LOT_COST_TXN_PROCESSOR('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240
                                ||': '||l_error_buf);
     FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);

     CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);

   WHEN INSERT_MMT_FAILURE THEN
     ROLLBACK;
     l_err_msg := SUBSTR('CSTPSMCW.LOT_COST_TXN_PROCESSOR('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240
                                ||': '||l_error_buf);
     FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);

     CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);

   WHEN OTHERS THEN
     ROLLBACK;
     l_err_code := NULL;
     l_err_msg := SUBSTR('CSTPSMCW.lot_txn_cost_processor('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);

     FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);

     CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);

END lot_txn_cost_processor;

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--    UPDATE_WSMT_TXN_STATUS                                              --
--                                                                        --
-- DESCRIPTION                                                            --
--  This function updates WSM_SPLIT_MERGE_TRANSACTIONS with the  status   --
--  of the costed column (COSTED/ERROR)                                   --
-- PURPOSE:                                                               --
--  OSFM Lot Transactions Costing for Oracle Applications Rel 11i.8
--                                                                        --
-- PARAMETERS:                                                            --
--  p_txn_id   - Transaction to be updated                                --
--  p_costed   - costed flag (COSTED/ERROR)
--  p_request_id
--  p_prog_appl_id
--  p_prog_id  - Concurrent WHO parameters.
-- HISTORY:                                                               --
--  August-2002         Vinit                       Creation              --
----------------------------------------------------------------------------

FUNCTION UPDATE_WSMT_TXN_STATUS
                  ( p_txn_id        IN NUMBER,
                    p_costed        IN NUMBER,
                    p_error_message IN VARCHAR2,
                    p_request_id    IN NUMBER,
                    p_prog_appl_id  IN NUMBER,
                    p_prog_id       IN NUMBER )
                  RETURN BOOLEAN IS
BEGIN

  UPDATE wsm_split_merge_transactions
	            SET    costed                 = p_costed,
                           error_message          = p_error_message,
                           request_id             = p_request_id,
                           program_application_id = p_prog_appl_id,
                           program_id             = p_prog_id,
                           program_update_date    = sysdate
  	            WHERE  transaction_id         = p_txn_id;
  RETURN TRUE;
END UPDATE_WSMT_TXN_STATUS;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  COST_LOT_TXN                                                          --
--                                                                        --
-- DESCRIPTION                                                            --
--  This procedure is called by the Standard Cost Worker to Cost
--  Lot Transactions (Split, Merge, Bonus and Update Quantity)            --
--                                                                        --
-- PURPOSE:                                                               --
--  OSFM Lot Transactions Costing for Oracle Applications Rel 11i.8
--                                                                        --
-- PARAMETERS:                                                            --
--  p_api_version 	API version
--  p_transaction_id	Transaction ID from MMT
--  p_request_id        Request ID of calling worker
--  o_err_num           Error Number
--  o_err_code          Error Code                                        --
--  o_err_msg           Error Message                                     --

-- HISTORY:                                                               --
--  August-2002         Vinit                       Creation              --
----------------------------------------------------------------------------

PROCEDURE COST_LOT_TXN ( p_api_version  	IN  NUMBER,
                         p_transaction_id	IN  NUMBER,
                         p_request_id           IN  NUMBER,
                         x_err_num              IN OUT NOCOPY NUMBER,
                         x_err_code             IN OUT NOCOPY VARCHAR2,
                         x_err_msg              IN OUT NOCOPY VARCHAR2) IS

  l_api_name  	CONSTANT  VARCHAR2(80)  := 'COST_LOT_TXN';
  l_api_version CONSTANT  NUMBER      := 1.0;

  l_stmt_num              NUMBER      := 0;

  /* Transaction Specific Information */
  l_wsmt_transaction_id    NUMBER;  -- Source Line ID in MMT
  l_mmt_txn_type_id        NUMBER;  -- From MMT
  l_wsmt_txn_type_id       NUMBER;
  l_transaction_type_id    NUMBER;  -- Txn Type in MMT
  l_txn_source_type_id     NUMBER;
  l_txn_action_id          NUMBER;
  l_wip_entity_id          NUMBER;
  l_transaction_date       DATE;
  l_organization_id        NUMBER;

  /* Program Information */
  l_prog_application_id   NUMBER;
  l_program_id            NUMBER;
  l_login_id              NUMBER;
  l_user_id               NUMBER;

  /* Return Codes */
  l_op_yield_ret_code     NUMBER;
  l_ret_update            BOOLEAN;

  /* Bonus Txn specific Information */
  l_resulting_wip_id	  NUMBER;
  l_starting_op_seq	  NUMBER;

  /* Error Msg */
  l_err_msg              VARCHAR2(2000) := NULL;

  /* Above is due to fact that MMT has a width of
     240 for its error_explanation column. We
     need some details here.  */

  /* Exceptions */
  NO_WSMT_TRANSACTION             EXCEPTION;
  UPDATE_JOB_QUANTITY_FAILURE     EXCEPTION;
  COST_TXN_FAILURE                EXCEPTION;
  PROCESS_SM_OP_YIELD_FAILURE     EXCEPTION;
  PROCESS_OP_YIELD_FAILURE        EXCEPTION;
  UNKNOWN_TXN_ERROR               EXCEPTION;

BEGIN

  l_stmt_num := 10;

  /* Initialize Error Codes */
  x_err_num  := 0;
  x_err_code := NULL;
  x_err_msg  := NULL;

  IF NOT FND_API.COMPATIBLE_API_CALL (
                               l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  /* Get Transaction Information from MMT */

   l_stmt_num := 20;

   SELECT transaction_source_id,
          transaction_date,
          organization_id,
          transaction_type_id,
          transaction_action_id,
          transaction_source_type_id,
          nvl(source_line_id, -1)
   INTO  l_wip_entity_id,
         l_transaction_date,
         l_organization_id,
         l_transaction_type_id,
         l_txn_action_id,
         l_txn_source_type_id,
         l_wsmt_transaction_id
   FROM MTL_MATERIAL_TRANSACTIONS
   WHERE transaction_id = p_transaction_id;

   IF (l_wsmt_transaction_id = -1) THEN
     RAISE NO_WSMT_TRANSACTION;
   END IF;


  /* Get Concurrent Program Information  */

  l_stmt_num := 30;

  SELECT program_application_id,
         concurrent_program_id,
         conc_login_id,
         requested_by
  INTO   l_prog_application_id,
         l_program_id,
         l_login_id,
         l_user_id
  FROM FND_CONCURRENT_REQUESTS
  WHERE request_id = p_request_id;


  /* If Transaction is BONUS at First Operation and Queue Introperation
     Step, Set it as COSTED */
  /* Note the additional join to BOS and WO in the inner SQL remains
     since we could have pre 11i.8 jobs that do not have
     JOB_OPERATION_SEQ_NUM populated */

  l_stmt_num := 40;

  UPDATE wsm_split_merge_transactions txn
  SET    costed = WIP_CONSTANTS.COMPLETED
  WHERE  transaction_type_id = 4
  AND    transaction_id = l_wsmt_transaction_id /* Added for bug 5008413 */
  AND    costed = WIP_CONSTANTS.PENDING
  AND    status = WIP_CONSTANTS.COMPLETED
  AND    EXISTS ( SELECT 	'Queue Intraop'
		  FROM	wsm_sm_resulting_jobs rj,
                        bom_operation_sequences bos,
                        wip_operations wo
		  WHERE	rj.transaction_id = txn.transaction_id
		  AND	rj.starting_intraoperation_step = 1
		  AND	(nvl(rj.job_operation_seq_num,
                            wo.operation_seq_num), wo.organization_id) =
				(SELECT min(operation_seq_num), wo2.organization_id
				 FROM	wip_operations wo2
				 WHERE	wo2.wip_entity_id = rj.wip_entity_id
                                 AND    wo2.organization_id = rj.organization_id
                                 GROUP BY wo2.organization_id)
                  AND   rj.transaction_id = txn.transaction_id
                  AND   rj.starting_intraoperation_step = 1
                  AND   rj.common_routing_sequence_id = bos.routing_sequence_id
                  AND   rj.starting_operation_seq_num = bos.operation_seq_num
                  AND   bos.operation_sequence_id = wo.operation_sequence_id
                  AND   bos.EFFECTIVITY_DATE <= txn.transaction_date
                  AND   NVL( bos.DISABLE_DATE, txn.transaction_date + 1
) > txn.transaction_date
                  AND   wo.wip_entity_id = rj.wip_entity_id
                  );
  /* Call specific procedures to cost different lot transactions */

  l_stmt_num := 50;

  IF (l_txn_source_type_id = 5 AND l_txn_action_id = 40) THEN
     l_wsmt_txn_type_id := 1;
     CSTPSMUT.COST_SPLIT_TXN
                ( p_api_version         => 1.0,
                  p_transaction_id      => l_wsmt_transaction_id,
                  p_mmt_transaction_id  => p_transaction_id,
                  p_transaction_date    => l_transaction_date,
                  p_prog_application_id => l_prog_application_id,
                  p_program_id          => l_program_id,
                  p_request_id          => p_request_id,
                  p_login_id            => l_login_id,
                  p_user_id             => l_user_id,
                  x_err_num             => x_err_num,
                  x_err_code            => x_err_code,
                  x_err_msg             => l_err_msg );
  ELSIF (l_txn_source_type_id = 5 AND l_txn_action_id = 41) THEN
     l_wsmt_txn_type_id := 2;
     CSTPSMUT.COST_MERGE_TXN
                ( p_api_version         => 1.0,
                  p_transaction_id      => l_wsmt_transaction_id,
                  p_mmt_transaction_id  => p_transaction_id,
                  p_transaction_date    => l_transaction_date,
                  p_prog_application_id => l_prog_application_id,
                  p_program_id          => l_program_id,
                  p_request_id          => p_request_id,
                  p_login_id            => l_login_id,
                  p_user_id             => l_user_id,
                  x_err_num             => x_err_num,
                  x_err_code            => x_err_code,
                  x_err_msg             => l_err_msg );
  ELSIF (l_txn_source_type_id = 5 AND l_txn_action_id = 42) THEN
     l_wsmt_txn_type_id := 4;
     CSTPSMUT.COST_BONUS_TXN
                ( p_api_version         => 1.0,
                  p_transaction_id      => l_wsmt_transaction_id,
                  p_mmt_transaction_id  => p_transaction_id,
                  p_transaction_date    => l_transaction_date,
                  p_prog_application_id => l_prog_application_id,
                  p_program_id          => l_program_id,
                  p_request_id          => p_request_id,
                  p_login_id            => l_login_id,
                  p_user_id             => l_user_id,
                  x_err_num             => x_err_num,
                  x_err_code            => x_err_code,
                  x_err_msg             => l_err_msg );
  ELSIF (l_txn_source_type_id = 5 AND l_txn_action_id = 43) THEN
     l_wsmt_txn_type_id := 6;
     CSTPSMUT.COST_UPDATE_QTY_TXN
                ( p_api_version         => 1.0,
                  p_transaction_id      => l_wsmt_transaction_id,
                  p_mmt_transaction_id  => p_transaction_id,
                  p_transaction_date    => l_transaction_date,
                  p_prog_application_id => l_prog_application_id,
                  p_program_id          => l_program_id,
                  p_request_id          => p_request_id,
                  p_login_id            => l_login_id,
                  p_user_id             => l_user_id,
                  x_err_num             => x_err_num,
                  x_err_code            => x_err_code,
                  x_err_msg             => l_err_msg );
  ELSE
    RAISE UNKNOWN_TXN_ERROR;
  END IF;

  /* If Error, Exception and Return */
  IF ( x_err_num <> 0 ) THEN
    RAISE COST_TXN_FAILURE;
  END IF;


  /* Transaction Costing is Successful.
     Update WRO, WOR for the jobs involved in the transaction.
  */
  l_stmt_num := 60;

  CSTPSMUT.UPDATE_JOB_QUANTITY
                ( p_api_version => 1.0,
                  p_txn_id      => l_wsmt_transaction_id,
                  x_err_num     => x_err_num,
                  x_err_code    => x_err_code,
                  x_err_msg     => l_err_msg );
  IF ( x_err_num <> 0 ) THEN
    RAISE UPDATE_JOB_QUANTITY_FAILURE;
  END IF;

  /* Update Successful, Do Operation Yield Costing.
     Call CSTPOYLD.process_sm_op_yld to populate WOY for the jobs.
     The Operation Yield Processor then picks it up separately for
     calculating the yielded costs.
     For Bonus and Update Qty Txns call CSTPOYLD.process_op_yield
     online to calculate the yielded costs since the accounting for
     these transactions is different.
     (They use the Bonus account specified on the transaction)
   */


  l_stmt_num := 70;

  l_op_yield_ret_code :=  CSTPOYLD.process_sm_op_yld
                                    ( l_wsmt_transaction_id,
                                      l_user_id,
                                      l_login_id,
                                      l_prog_application_id,
                                      l_program_id,
                                      p_request_id,
                                      x_err_num,
                                      x_err_code,
                                      l_err_msg );
  IF ( l_op_yield_ret_code = 0 ) THEN
    RAISE PROCESS_SM_OP_YIELD_FAILURE;
  END IF;


  IF (( l_wsmt_txn_type_id = 4) OR ( l_wsmt_txn_type_id = 6 )) THEN
    l_stmt_num := 80;
    IF ( l_wsmt_txn_type_id = 6) THEN
      SELECT wip_entity_id,
             operation_seq_num
      INTO   l_resulting_wip_id,
             l_starting_op_seq
      FROM   wsm_sm_starting_jobs
      WHERE  transaction_id = l_wsmt_transaction_id;

    ELSE

      SELECT wip_entity_id,
             job_operation_seq_num
      INTO   l_resulting_wip_id,
             l_starting_op_seq
      FROM   WSM_SM_RESULTING_JOBS WSRJ
      WHERE  transaction_id = l_wsmt_transaction_id;

      /* For Pre 11i.8 jobs, JOB_OPERATION_SEQ_NUM is NULL,
         Use Bom_operation_sequences and wsrj.starting_op_seq_num to
         obtain this information */
      IF l_starting_op_seq IS NULL THEN
        SELECT wo.operation_seq_num
        INTO   l_starting_op_seq
        FROM   WIP_OPERATIONS WO,
               WSM_SM_RESULTING_JOBS WSRJ,
               BOM_OPERATION_SEQUENCES BOS
        WHERE  WSRJ.transaction_id                       = l_wsmt_transaction_id
        AND    nvl(wsrj.starting_intraoperation_step, 1) = 1
        AND    wsrj.common_routing_sequence_id           = bos.routing_sequence_id
        AND    wsrj.starting_operation_seq_num           = bos.operation_seq_num
        AND    bos.operation_sequence_id                 = wo.operation_sequence_id
        AND    bos.EFFECTIVITY_DATE                      <= l_transaction_date
        AND    NVL( bos.DISABLE_DATE, l_transaction_date + 1) > l_transaction_date
        AND    wo.wip_entity_id                          = wsrj.wip_entity_id
        AND    wo.organization_id                        = l_organization_id;
      END IF;

    END IF;

    l_stmt_num := 90;

    l_err_msg := NULL;
    CSTPOYLD.process_op_yield
                     ( l_err_msg,
                       x_err_code,
                       2,    -- Range:  WIP
                       l_resulting_wip_id,
                       3,    -- Run_Option (Look in CSTOYLDB.pls)
                       l_starting_op_seq,
                       null,
                       l_wsmt_transaction_id );

    IF (l_err_msg IS NOT NULL) THEN
      RAISE PROCESS_OP_YIELD_FAILURE;
    END IF;

  END IF;

  /* l_err_msg is populated if the Op Yield Process fails */
  l_stmt_num := 100;
  l_ret_update := UPDATE_WSMT_TXN_STATUS ( l_wsmt_transaction_id,
                                           WIP_CONSTANTS.COMPLETED,
                                           NULL,  -- Error Message
                                           p_request_id,
                                           l_prog_application_id,
                                           l_program_id );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_err_num  := -1;
    x_err_code := 'Inconsistent API Version';--FND_API.G_RET_SYS_ERROR;
    l_err_msg  := 'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num)||'):' || l_err_msg || substr(SQLERRM, 1, 200);
    FND_FILE.put_line(fnd_file.log, 'API Version Obsoleted'|| l_err_msg );
    x_err_msg :=  'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num);
    l_ret_update := UPDATE_WSMT_TXN_STATUS ( l_wsmt_transaction_id,
                             WIP_CONSTANTS.ERROR,
                             l_err_msg,
                             p_request_id,
                             l_prog_application_id,
                             l_program_id );
  WHEN UNKNOWN_TXN_ERROR THEN
    x_err_num  := -1;
    x_err_code := 'Unknown Transaction Type passed... Catastrophic Failure';
    l_err_msg  := 'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num)||'):' || l_err_msg;
    FND_FILE.put_line(fnd_file.log, 'Unknown Transaction Type passed... Catastrophic Failure'|| l_err_msg );
    x_err_msg  := 'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num);

    l_ret_update := UPDATE_WSMT_TXN_STATUS ( l_wsmt_transaction_id,
                             WIP_CONSTANTS.ERROR,
                             l_err_msg,
                             p_request_id,
                             l_prog_application_id,
                             l_program_id );

  WHEN NO_WSMT_TRANSACTION THEN
    x_err_num  := -1;
    x_err_code := 'MMT not populated with Transaction ID from WSMT';
    l_err_msg  := 'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num)||'): ' || l_err_msg;
    x_err_msg  := 'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num)||'):';
    FND_FILE.put_line(fnd_file.log, 'MMT not populated with Transaction ID from WSMT'|| l_err_msg );
    l_ret_update := UPDATE_WSMT_TXN_STATUS ( l_wsmt_transaction_id,
                             WIP_CONSTANTS.ERROR,
                             l_err_msg,
                             p_request_id,
                             l_prog_application_id,
                             l_program_id );
  WHEN COST_TXN_FAILURE THEN
    x_err_num  := -1;
    x_err_code := 'Transaction Costing Failed';
    l_err_msg  := 'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num)||'): ' || l_err_msg;
    FND_FILE.put_line(fnd_file.log, 'Transaction Costing Failed'|| l_err_msg );
    l_ret_update := UPDATE_WSMT_TXN_STATUS ( l_wsmt_transaction_id,
                             WIP_CONSTANTS.ERROR,
                             l_err_msg,
                             p_request_id,
                             l_prog_application_id,
                             l_program_id );
  WHEN UPDATE_JOB_QUANTITY_FAILURE THEN
    x_err_num  := -1;
    x_err_code := 'Failed to Update Job Info: Transaction Costing Failed';
    l_err_msg  := 'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num)||'): ' || l_err_msg;
    x_err_msg  := 'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num)||'):';
    FND_FILE.put_line(fnd_file.log, 'Failed to Update Job Info: Transaction Costing Failed'|| l_err_msg );
    l_ret_update := UPDATE_WSMT_TXN_STATUS ( l_wsmt_transaction_id,
                             WIP_CONSTANTS.ERROR,
                             l_err_msg,
                             p_request_id,
                             l_prog_application_id,
                             l_program_id );
  WHEN PROCESS_SM_OP_YIELD_FAILURE THEN
    x_err_num  := -1;
    x_err_code := 'Update of Wip Operation Yields Failed';
    l_err_msg  := 'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num)||'): ' || l_err_msg;
    x_err_msg  := 'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num)||'):';
    FND_FILE.put_line(fnd_file.log, 'Update of Wip Operation Yields Failed'|| l_err_msg );
    l_ret_update := UPDATE_WSMT_TXN_STATUS ( l_wsmt_transaction_id,
                             WIP_CONSTANTS.ERROR,
                             l_err_msg,
                             p_request_id,
                             l_prog_application_id,
                             l_program_id );
   WHEN PROCESS_OP_YIELD_FAILURE THEN
    x_err_num  := -1;
    x_err_code := 'Operation Yield Costing Failed';
    l_err_msg  := 'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num)||'): ' || l_err_msg;
    x_err_msg  := 'CSTPSMCW.COST_LOT_TXN('||to_char(l_stmt_num)||'):';
    FND_FILE.put_line(fnd_file.log, 'Operation Yield Costing Failed'|| l_err_msg );
    l_ret_update := UPDATE_WSMT_TXN_STATUS ( l_wsmt_transaction_id,
                             WIP_CONSTANTS.ERROR,
                             l_err_msg,
                             p_request_id,
                             l_prog_application_id,
                             l_program_id );
END COST_LOT_TXN;


END CSTPSMCW;

/
