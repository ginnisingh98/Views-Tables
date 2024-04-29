--------------------------------------------------------
--  DDL for Package Body IBY_BANKPAYMENT_UPDT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_BANKPAYMENT_UPDT_PUB" as
/*$Header: ibypbpupb.pls 115.9 2003/08/05 04:50:49 fxzhang noship $ */

-- package global variables
-- status codes used in this package
G_STATUS_SUCCESS           CONSTANT NUMBER := IBY_UTILITY_PVT.STATUS_SUCCESS;
G_STATUS_BEP_ERROR         CONSTANT NUMBER := IBY_UTILITY_PVT.STATUS_BEP_ERROR;
G_STATUS_BATCH_PARTIAL     CONSTANT NUMBER := IBY_UTILITY_PVT.STATUS_BATCH_PARTIAL;
G_STATUS_QRY_BATCH_PARTIAL CONSTANT NUMBER := IBY_UTILITY_PVT.STATUS_QRY_BATCH_PARTIAL;
G_STATUS_QRY_BATCH_FAIL    CONSTANT NUMBER := IBY_UTILITY_PVT.STATUS_QRY_BATCH_FAIL;
G_STATUS_QRY_BATCH_PENDING CONSTANT NUMBER := IBY_UTILITY_PVT.STATUS_QRY_BATCH_PENDING;
G_STATUS_QRY_TRXN_FAIL     CONSTANT NUMBER := IBY_UTILITY_PVT.STATUS_QRY_TRXN_FAIL;

/* ========================================================================
-- Procedure Name:   updateBatchStatus
--
-- Purpose:         This procedure will update the iby_pay_batches_all table
--                  with the new batch status value.
--                  The possible batch status values considered at present
--                  includes  -
--                  1)  18 - Submitted to Processor
--                  2)   8 - Request not supported
--                  3)  12 - Scheduler in progess
--                  4) 101 - Communication error
--                  5) 301 - Formatted
--                  6) 302 - Confirmed
--                  7) 303 - Canceled
--                  8)   7 - Batch Failure
-- Parameters:
-- IN               1) p_batch_id      NUMBER
--                  The batch id.
--
--                  2)p_new_status     NUMBER
--                  The new batch status.
--
--                  2)p_error_code     VARCHAR2
--                  The error code if any.
--
--                  2)p_error_message  VARCHAR2
--                  The error message if any.
--
--  =======================================================================*/

procedure updateBatchStatus(
    p_batch_id         IN   iby_pay_batches_all.batch_id%TYPE,
    p_new_status       IN   iby_pay_batches_all.batch_status%TYPE,
    p_error_code       IN   iby_pay_batches_all.bep_code%TYPE,
    p_error_message    IN   iby_pay_batches_all.bep_message%TYPE
)
IS

 begin

  update iby_pay_batches_all
  set batch_status = p_new_status,
  bep_code = p_error_code,
  bep_message = p_error_message,
  last_update_date = sysdate,
  last_updated_by = fnd_global.user_id,
  object_version_number = object_version_number + 1
  where batch_id = p_batch_id;

  commit;

end updateBatchStatus;

/* ========================================================================
-- Procedure Name:   updateECBatches
--
-- Purpose:         This procedure will update all EC batches associated with
--                  an iPayment batch to a new status.
--  =======================================================================*/

PROCEDURE updateECBatches
(
      payerid_in		IN	iby_pay_batches_all.payer_id%TYPE,
      bepid_in		IN	iby_pay_batches_all.bepid%TYPE,
      bepkey_in		IN	iby_pay_batches_all.bepkey%TYPE,
      oldstatus_in	IN	iby_pay_batches_all.batch_status%TYPE,
      newstatus_in	IN	iby_pay_batches_all.batch_status%TYPE,
      oldbatchid_in	IN	iby_pay_batches_all.iby_batch_id%TYPE,
      newbatchid_in	IN	iby_pay_batches_all.iby_batch_id%TYPE
)
IS

BEGIN
      UPDATE iby_pay_batches_all
      SET
            batch_status = newstatus_in,
            iby_batch_id = newbatchid_in,
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            object_version_number = object_version_number + 1

      WHERE bepid = bepid_in
      AND bepkey = bepkey_in
      AND payer_id = payerid_in
      AND batch_status = oldstatus_in
      AND ((iby_batch_id IS NULL AND oldbatchid_in IS NULL) OR (iby_batch_id = oldbatchid_in));

      COMMIT;

END updateECBatches;


/* ========================================================================
-- Procedure Name:  updateTrxnStatus
--
-- Purpose:          This procedure updates the transaction status field
--                   in the iby_pay_payments_all table with the new transaction
--                   status value. For a particular batch, all the
--                   transactions will be updated with the same status value.
--                   Since the batch acknowledgment is not considered at
--                   present this condition is sufficient.
--                   The possible transaction status values considered at
--                   present includes
--                   1) 18 - Submitted to Processor
--                   2)  8 - Request not supported
--                   3) 11 - Pending
--                   4) 20 - Invalid Transaction
--                   5) 21 - Transaction Stopped
-- Parameters:
-- IN                1) p_batch_id       NUMBER
--                   The batch id.
--
--                   2) p_trxn_id        NUMBER
--                   The transaction id.
--
--                   3) p_new_status     NUMBER
--                   The new transaction status.
--
--                   4) p_error_code     VARCHAR2
--                   The error code if any.
--
--                   5) p_error_message  VARCHAR2
--                   The error message if any.
--
--  =======================================================================*/

PROCEDURE updateTrxnStatus(

            p_batch_id        IN    iby_pay_payments_all.batch_id%TYPE,
            p_trxn_id         IN    iby_pay_payments_all.pmt_trxn_id%TYPE,
            p_new_status      IN    iby_pay_payments_all.pmt_status%TYPE,
            p_error_code      IN    iby_pay_payments_all.bep_code%TYPE,
            p_error_message   IN    iby_pay_payments_all.bep_message%TYPE
 )
IS

begin

IF (p_trxn_id <> 0) THEN

     update iby_pay_payments_all
     set pmt_status = p_new_status,
     bep_code = p_error_code,
     bep_message = p_error_message,
     last_update_date = sysdate,
     last_updated_by = fnd_global.user_id,
     object_version_number = object_version_number + 1
     where batch_id = p_batch_id and pmt_trxn_id = p_trxn_id;

ELSE

     update iby_pay_payments_all
     set pmt_status = p_new_status,
     bep_code = p_error_code,
     bep_message = p_error_message,
     last_update_date = sysdate,
     last_updated_by = fnd_global.user_id,
     object_version_number = object_version_number + 1
     where batch_id = p_batch_id;

END IF;

commit;

end updateTrxnStatus;





/* ========================================================================
-- Procedure Name:  setBatchFail
--
-- Purpose:          This procedure updates the iPayment batch and all
--                   its child EC batches and trxns to fail based
--                   on the batch query result returned from the servlet.
--                   1) 207 - Batch failed at Bank. for iby merged batch
--                            and EC batch
--                   2) 220 - Transaction failed at Bank. for trxn
--
-- Parameters:
-- IN
--                   1) p_payerid       VARCHAR2
--                   The payerid for the iby batch
--                   iby_batches_all.payeeid
--
--                   2) p_iby_batchid      VARCHAR2
--                   The iby merged batch (message) id
--                   iby_batches_all.batchid
--
--                   3)p_error_code     VARCHAR2
--                   The error code if any.
--
--                   4)p_error_message  VARCHAR2
--                   The error message if any.
--
--  =======================================================================*/
PROCEDURE setBatchFail (
            p_payerid          IN    VARCHAR2,
            p_iby_batchid      IN    VARCHAR2,
            p_error_code       IN    VARCHAR2,
            p_error_message    IN    VARCHAR2
)
IS

  CURSOR l_ec_batch_csr (p_payerid IN VARCHAR2, p_iby_batchid IN VARCHAR2) IS
  SELECT pb.batch_id
    FROM IBY_PAY_BATCHES_ALL pb,
         IBY_BATCHES_ALL   ibyb
   WHERE ibyb.batchid = p_iby_batchid
     AND ibyb.payeeid = p_payerid;

BEGIN

  FOR l_ec_batch_rec IN l_ec_batch_csr(p_payerid, p_iby_batchid) LOOP

    -- update child trxns
    -- of the EC batch
    UPDATE iby_pay_payments_all
    SET
           pmt_status = G_STATUS_QRY_TRXN_FAIL,
           bep_code = p_error_code,
           bep_message = p_error_message,
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.conc_login_id,
           object_version_number = object_version_number + 1
    WHERE batch_id = l_ec_batch_rec.batch_id;

    -- update the EC batch
    UPDATE iby_pay_batches_all
    SET
           batch_status = G_STATUS_QRY_BATCH_FAIL,
           bep_code = p_error_code,
           bep_message = p_error_message,
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.conc_login_id,
           object_version_number = object_version_number + 1
    WHERE batch_id = l_ec_batch_rec.batch_id;

  END LOOP;

  -- update the iby merged batch
  UPDATE iby_batches_all
  SET
         batchstatus = G_STATUS_QRY_BATCH_FAIL,
         bepcode = p_error_code,
         bepmessage = p_error_message,
         last_update_date = sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.conc_login_id,
         object_version_number = object_version_number + 1
   WHERE batchid = p_iby_batchid
     AND payeeid = p_payerid;

END;



/* ========================================================================
-- Procedure Name:  updateQueryStatus
--
-- Purpose:          This procedure updates the iPayment batch and all
--                   its child EC batches - those do not have a finished
--                   status based on the trxn statuses returned from
--                   the servlet. Note the applicable trxn statuses updates
--                   must have been done before this procedure is called.
--                   It's not an error if this procedure is called for
--                   a iby merged batch that has a final status. In that
--                   case nothing will be done. Same goes for an EC batch
--                   with a final status.
--                   Statuses considered to be final:
--                   iby batch:
--                   1) 0 - success
--                   2) 206 - partial sucess -
--                            all child batch and trxn status known
--                   3) 207 - Batch failed at Bank.
--                   EC batch:
--                   1) 0 - success
--                   2) 206 - partial sucess -
--                            all child trxn status known
--                   3) 207 - Batch failed at Bank.
--                   Trxn:
--                   1) 0 - success
--                   2) 5 - BEP specific error
--                   3) 220 - Transaction failed at Bank
--
-- Parameters:
-- IN
--                   1) p_payerid       VARCHAR2
--                   The payerid for the iby batch
--                   iby_batches_all.payeeid
--
--                   2) p_iby_batchid      VARCHAR2
--                   The iby merged batch (message) id
--                   iby_batches_all.batchid
--
--  =======================================================================*/
PROCEDURE updateQueryStatus (
            p_payerid          IN    VARCHAR2,
            p_iby_batchid      IN    VARCHAR2
)

IS

  l_unfinished_ecbatch_notfound   BOOLEAN := TRUE;
  l_finished_ecbatch_found        BOOLEAN := FALSE;
  --l_unsuccess_ecbatch_notfound    BOOLEAN := FALSE;
  l_unfinished_trxn_notfound      BOOLEAN := FALSE;
  l_finished_trxn_found           BOOLEAN := FALSE;
  --l_unsuccess_trxn_notfound       BOOLEAN := FALSE;
  l_ecbatch_id                    NUMBER;
  l_pmt_trxn_id                   NUMBER;
  l_batch_status                  NUMBER;
  l_trxn_count                    NUMBER;
  l_failed_trxn_count             NUMBER;
  l_ecbatch_count                 NUMBER;
  l_failed_ecbatch_count          NUMBER;


  CURSOR l_ec_batch_csr (p_payerid IN VARCHAR2, p_iby_batchid IN VARCHAR2) IS
  SELECT pb.batch_id, pb.batch_status
    FROM IBY_PAY_BATCHES_ALL pb,
         IBY_BATCHES_ALL   ibyb
   WHERE ibyb.batchid   = p_iby_batchid
     AND ibyb.payeeid   = p_payerid
     AND pb.batch_status not in (G_STATUS_SUCCESS, G_STATUS_QRY_BATCH_PARTIAL, G_STATUS_QRY_BATCH_FAIL);

  CURSOR l_finished_ecbatch_csr (p_payerid IN VARCHAR2, p_iby_batchid IN VARCHAR2) IS
  SELECT pb.batch_id
    FROM IBY_PAY_BATCHES_ALL pb,
         IBY_BATCHES_ALL   ibyb
   WHERE ibyb.batchid   = p_iby_batchid
     AND ibyb.payeeid   = p_payerid
     AND pb.batch_status in (G_STATUS_SUCCESS, G_STATUS_QRY_BATCH_PARTIAL, G_STATUS_QRY_BATCH_FAIL);

  -- count of all EC batches in an iby merged batch
  CURSOR l_ecbatch_cnt_csr (p_payerid IN VARCHAR2, p_iby_batchid IN VARCHAR2) IS
  SELECT count(pb.batch_id)
    FROM IBY_PAY_BATCHES_ALL pb,
         IBY_BATCHES_ALL   ibyb
   WHERE ibyb.batchid   = p_iby_batchid
     AND ibyb.payeeid   = p_payerid;

  -- count of all unsuccessful EC batches in an iby merged batch
  CURSOR l_failed_ecbatch_cnt_csr (p_payerid IN VARCHAR2, p_iby_batchid IN VARCHAR2) IS
  SELECT count(pb.batch_id)
    FROM IBY_PAY_BATCHES_ALL pb,
         IBY_BATCHES_ALL   ibyb
   WHERE ibyb.batchid   = p_iby_batchid
     AND ibyb.payeeid   = p_payerid
     AND pb.batch_status in (G_STATUS_QRY_BATCH_PARTIAL, G_STATUS_QRY_BATCH_FAIL);

  CURSOR l_unfinished_trxn_csr (p_batch_id IN NUMBER) IS
  SELECT pt.pmt_trxn_id
    FROM IBY_PAY_PAYMENTS_ALL pt
   WHERE pt.batch_id    = p_batch_id
     AND pt.pmt_status not in (G_STATUS_SUCCESS, G_STATUS_BEP_ERROR, G_STATUS_QRY_TRXN_FAIL);

  CURSOR l_finished_trxn_csr (p_batch_id IN NUMBER) IS
  SELECT pt.pmt_trxn_id
    FROM IBY_PAY_PAYMENTS_ALL pt
   WHERE pt.batch_id    = p_batch_id
     AND pt.pmt_status in (G_STATUS_SUCCESS, G_STATUS_BEP_ERROR, G_STATUS_QRY_TRXN_FAIL);

  -- all trxns of an EC batch
  CURSOR l_trxn_cnt_csr (p_batch_id IN NUMBER) IS
  SELECT count(pt.pmt_trxn_id)
    FROM IBY_PAY_PAYMENTS_ALL pt
   WHERE pt.batch_id    = p_batch_id;

  -- unsuccessful trxns of an EC batch
  CURSOR l_failed_trxn_cnt_csr (p_batch_id IN NUMBER) IS
  SELECT count(pt.pmt_trxn_id)
    FROM IBY_PAY_PAYMENTS_ALL pt
   WHERE pt.batch_id    = p_batch_id
   --AND pt.pmt_status <> G_STATUS_SUCCESS;
     AND pt.pmt_status in (G_STATUS_BEP_ERROR, G_STATUS_QRY_TRXN_FAIL);

BEGIN

  FOR l_ec_batch_rec IN l_ec_batch_csr(p_payerid, p_iby_batchid) LOOP

    l_batch_status := l_ec_batch_rec.batch_status;
    l_unfinished_ecbatch_notfound := false;

    OPEN l_unfinished_trxn_csr(l_ec_batch_rec.batch_id);
    FETCH l_unfinished_trxn_csr INTO l_pmt_trxn_id;
    l_unfinished_trxn_notfound := l_unfinished_trxn_csr%NOTFOUND;
    CLOSE l_unfinished_trxn_csr;

    -- if no unfinished trxn for the EC batch
    IF l_unfinished_trxn_notfound THEN

      OPEN l_trxn_cnt_csr(l_ec_batch_rec.batch_id);
      FETCH l_trxn_cnt_csr INTO l_trxn_count;
      CLOSE l_trxn_cnt_csr;

      OPEN l_failed_trxn_cnt_csr(l_ec_batch_rec.batch_id);
      FETCH l_failed_trxn_cnt_csr INTO l_failed_trxn_count;
      CLOSE l_failed_trxn_cnt_csr;

      -- all child trxns are sucessful
      IF l_failed_trxn_count = 0 THEN
        l_batch_status := G_STATUS_SUCCESS;
      ELSIF l_failed_trxn_count < l_trxn_count THEN
        l_batch_status := G_STATUS_QRY_BATCH_PARTIAL;
      ELSE
        l_batch_status := G_STATUS_QRY_BATCH_FAIL;
      END IF;

    -- exists unfinished trxn
    -- see if any finished trxn
    -- if so change batch status to G_STATUS_QRY_BATCH_PENDING
    ELSE

      OPEN l_finished_trxn_csr(l_ec_batch_rec.batch_id);
      FETCH l_finished_trxn_csr INTO l_pmt_trxn_id;
      l_finished_trxn_found := l_finished_trxn_csr%FOUND;
      CLOSE l_finished_trxn_csr;

      -- found some finished trxns
      IF l_finished_trxn_found THEN
        l_batch_status := G_STATUS_QRY_BATCH_PENDING;
      END IF;

    END IF;

    -- check to see if we have computed a new status
    IF l_batch_status <> l_ec_batch_rec.batch_status THEN

      -- update the EC batch
      -- note as the status is synthesized
      -- we don't have bep_code and message
      UPDATE iby_pay_batches_all
      SET
             batch_status = l_batch_status,
             bep_code = null,
             bep_message = null,
             last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.conc_login_id,
             object_version_number = object_version_number + 1
      WHERE batch_id = l_ec_batch_rec.batch_id;

    END IF;

  END LOOP;

  -- no unfinished EC batches
  IF l_unfinished_ecbatch_notfound THEN

    OPEN l_ecbatch_cnt_csr(p_payerid, p_iby_batchid);
    FETCH l_ecbatch_cnt_csr INTO l_ecbatch_count;
    CLOSE l_ecbatch_cnt_csr;

    OPEN l_failed_ecbatch_cnt_csr(p_payerid, p_iby_batchid);
    FETCH l_failed_ecbatch_cnt_csr INTO l_failed_ecbatch_count;
    CLOSE l_failed_ecbatch_cnt_csr;

    -- all child EC batches are sucessful
    IF l_failed_ecbatch_count = 0 THEN
      l_batch_status := G_STATUS_SUCCESS;
    ELSIF l_failed_ecbatch_count < l_ecbatch_count THEN
      l_batch_status := G_STATUS_QRY_BATCH_PARTIAL;
    ELSE
      l_batch_status := G_STATUS_QRY_BATCH_FAIL;
    END IF;

    -- update the iby merged batch
    UPDATE iby_batches_all
    SET
           batchstatus = l_batch_status,
           bepcode = null,
           bepmessage = null,
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.conc_login_id,
           object_version_number = object_version_number + 1
    WHERE batchid = p_iby_batchid
      AND payeeid = p_payerid;

  -- exists unfinished EC batches
  -- see if any finished EC batches
  ELSE

    OPEN l_finished_ecbatch_csr(p_payerid, p_iby_batchid);
    FETCH l_finished_ecbatch_csr INTO l_ecbatch_id;
    l_finished_ecbatch_found := l_finished_ecbatch_csr%FOUND;
    CLOSE l_finished_ecbatch_csr;

    -- found some finished EC batches
    IF l_finished_ecbatch_found THEN
      l_batch_status := G_STATUS_QRY_BATCH_PENDING;
    END IF;

    -- update the iby merged batch
    UPDATE iby_batches_all
    SET
           batchstatus = l_batch_status,
           bepcode = null,
           bepmessage = null,
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.conc_login_id,
           object_version_number = object_version_number + 1
    WHERE batchid = p_iby_batchid
      AND payeeid = p_payerid;

  END IF;

END;



end IBY_BANKPAYMENT_UPDT_PUB;

/
