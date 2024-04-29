--------------------------------------------------------
--  DDL for Package IBY_BANKPAYMENT_UPDT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_BANKPAYMENT_UPDT_PUB" AUTHID CURRENT_USER AS
/*$Header: ibypbpups.pls 115.7 2003/08/02 02:42:20 fxzhang noship $ */

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

PROCEDURE updateBatchStatus(

            p_batch_id        IN    iby_pay_batches_all.batch_id%TYPE,
            p_new_status      IN    iby_pay_batches_all.batch_status%TYPE,
            p_error_code      IN    iby_pay_batches_all.bep_code%TYPE,
            p_error_message   IN    iby_pay_batches_all.bep_message%TYPE
 );

/* ========================================================================
-- Procedure Name:   updateECBatches
--
-- Purpose:         This procedure will update all EC batches associated with
--                  an iPayment batch to a new status.
--  =======================================================================*/

PROCEDURE updateECBatches
(
	payerid_in     IN iby_pay_batches_all.payer_id%TYPE,
	bepid_in       IN	iby_pay_batches_all.bepid%TYPE,
	bepkey_in      IN	iby_pay_batches_all.bepkey%TYPE,
	oldstatus_in   IN	iby_pay_batches_all.batch_status%TYPE,
	newstatus_in   IN	iby_pay_batches_all.batch_status%TYPE,
	oldbatchid_in  IN	iby_pay_batches_all.iby_batch_id%TYPE,
	newbatchid_in  IN	iby_pay_batches_all.iby_batch_id%TYPE
);


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
-- IN                1) p_batch_id      NUMBER
--                   The batch id.
--
--                   2) p_trxn_id       NUMBER
--                   The transaction id.
--
--                   3)p_new_status     NUMBER
--                   The new transaction status.
--
--                   4)p_error_code     VARCHAR2
--                   The error code if any.
--
--                   5)p_error_message  VARCHAR2
--                   The error message if any.
--
--  =======================================================================*/

PROCEDURE updateTrxnStatus(

            p_batch_id        IN    iby_pay_payments_all.batch_id%TYPE,
            p_trxn_id         IN    iby_pay_payments_all.pmt_trxn_id%TYPE,
            p_new_status      IN    iby_pay_payments_all.pmt_status%TYPE,
            p_error_code      IN    iby_pay_payments_all.bep_code%TYPE,
            p_error_message   IN    iby_pay_payments_all.bep_message%TYPE
 );


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
);



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
);


END IBY_BANKPAYMENT_UPDT_PUB;

 

/
