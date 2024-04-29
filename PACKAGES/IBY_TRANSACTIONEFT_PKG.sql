--------------------------------------------------------
--  DDL for Package IBY_TRANSACTIONEFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_TRANSACTIONEFT_PKG" AUTHID CURRENT_USER AS
/*$Header: ibytefts.pls 120.11.12010000.4 2009/10/22 11:28:29 sgogula ship $ */

/*
 * The purpose of this procedure is to check if there is any open
 * transaction which are due.
 * If there is, it will insert a row into the iby_batches_all table
 * to keep track of the batch status, and change the transactions status
 * to other status. So, the open transactions will be sent as part of
 * future batch close. Also, it will not allow any modification and
 * cancellation to these transactions.
 */
PROCEDURE createBatchCloseTrxns(
            merch_batchid_in     IN    VARCHAR2,
            merchant_id_in       IN    VARCHAR2,
            vendor_id_in         IN    NUMBER,
            vendor_key_in        IN    VARCHAR2,
            newstatus_in         IN    NUMBER,
            oldstatus_in         IN    NUMBER,
            batchstate_in        IN    NUMBER DEFAULT null,
            settlement_date_in   IN    DATE DEFAULT sysdate,
            req_type_in          IN    VARCHAR2 DEFAULT null,
            numtrxns_out         OUT NOCOPY NUMBER
            );

/*
 * The purpose of this procedure is to check if there is any open
 * transaction which are due.
 * If there is, it will insert a row into the iby_batches_all table
 * to keep track of the batch status, and change the transactions status
 * to other status. So, the open transactions will be sent as part of
 * future batch close. Also, it will not allow any modification and
 * cancellation to these transactions.
 */
PROCEDURE createBatchCloseTrxnsNew(
            merch_batchid_in     IN    VARCHAR2,
            profile_code_in      IN    iby_batches_all.
                                           process_profile_code%TYPE,
            merchant_id_in       IN    VARCHAR2,
            vendor_id_in         IN    NUMBER,
            vendor_key_in        IN    VARCHAR2,
            newstatus_in         IN    NUMBER,
            oldstatus_in         IN    NUMBER,
            batchstate_in        IN    NUMBER DEFAULT null,
            settlement_date_in   IN    DATE DEFAULT sysdate,
            req_type_in          IN    VARCHAR2 DEFAULT null,
            instr_type_in        IN    iby_batches_all.
                                           instrument_type%TYPE,
            br_disputed_flag_in  IN    iby_batches_all.
                                           br_disputed_flag%TYPE,
            f_pmt_channel_in     IN    iby_trxn_summaries_all.
                                           payment_channel_code%TYPE,
            f_curr_in            IN    iby_trxn_summaries_all.
                                           currencynamecode%TYPE,
            f_settle_date        IN    iby_trxn_summaries_all.
                                           settledate%TYPE,
            f_due_date           IN    iby_trxn_summaries_all.
                                           settlement_due_date%TYPE,
            f_maturity_date      IN    iby_trxn_summaries_all.
                                           br_maturity_date%TYPE,
            f_instr_type         IN    iby_trxn_summaries_all.
                                           instrtype%TYPE,
            numtrxns_out         OUT   NOCOPY NUMBER,
            mbatch_ids_out       OUT   NOCOPY JTF_NUMBER_TABLE,
            batch_ids_out        OUT   NOCOPY JTF_VARCHAR2_TABLE_100
            );

/*
 * This is the overloaded form of the previous API. This takes an array of
 * profile codes as input parameter (instead of a single one)
 * The purpose of this procedure is to check if there is any open
 * transaction which are due.  If there is, it will insert a row into
 * the iby_batches_all table to keep track of the batch status, and
 * change the transactions status to other status. So, the open
 * transactions will be sent as part of future batch close. Also, it
 * will not allow any modification and cancellation to these transactions.
 */
PROCEDURE createBatchCloseTrxnsNew(
            merch_batchid_in     IN    VARCHAR2,
            profile_code_array   IN    JTF_VARCHAR2_TABLE_100,
            merchant_id_in       IN    VARCHAR2,
            vendor_id_in         IN    NUMBER,
            vendor_key_in        IN    VARCHAR2,
            newstatus_in         IN    NUMBER,
            oldstatus_in         IN    NUMBER,
            batchstate_in        IN    NUMBER,
            settlement_date_in   IN    DATE,
            req_type_in          IN    VARCHAR2,
            instr_type_in        IN    iby_batches_all.
                                           instrument_type%TYPE,
            br_disputed_flag_in  IN    iby_batches_all.
                                           br_disputed_flag%TYPE,
            f_pmt_channel_in     IN    iby_trxn_summaries_all.
                                           payment_channel_code%TYPE,
            f_curr_in            IN    iby_trxn_summaries_all.
                                           currencynamecode%TYPE,
            f_settle_date        IN    iby_trxn_summaries_all.
                                           settledate%TYPE,
            f_due_date           IN    iby_trxn_summaries_all.
                                           settlement_due_date%TYPE,
            f_maturity_date      IN    iby_trxn_summaries_all.
                                           br_maturity_date%TYPE,
            f_instr_type         IN    iby_trxn_summaries_all.
                                           instrtype%TYPE,
            numtrxns_out         OUT   NOCOPY NUMBER,
            mbatch_ids_out       OUT   NOCOPY JTF_NUMBER_TABLE,
            batch_ids_out        OUT   NOCOPY JTF_VARCHAR2_TABLE_100
            );

/*Update the batch and transactions status and other infomations based on the
  payeeid and batchid */
PROCEDURE updateBatchCloseTrxns(
            merch_batchid_in     IN    VARCHAR2,
            merchant_id_in       IN    VARCHAR2,
            newstatus_in         IN    NUMBER,
            batchstate_in        IN    NUMBER DEFAULT null,
            numtrxns_in          IN    NUMBER DEFAULT null,
            batchtotal_in        IN    NUMBER DEFAULT null,
            salestotal_in        IN    NUMBER DEFAULT null,
            credittotal_in       IN    NUMBER DEFAULT null,
            time_in              IN    DATE DEFAULT sysdate,
            vendor_code_in       IN    VARCHAR2 DEFAULT null,
            vendor_message_in    IN    VARCHAR2 DEFAULT null
            );

/*Update the transactions status and other informations by passed the data in as array.*/
PROCEDURE updateTrxnResultStatus(
            i_merch_batchid      IN    VARCHAR2,
            i_merchant_id        IN    VARCHAR2,
            i_status_arr         IN    JTF_NUMBER_TABLE,
            i_errCode_arr        IN    JTF_VARCHAR2_TABLE_100,
            i_errMsg_arr         IN    JTF_VARCHAR2_TABLE_300,
            i_tangibleId_arr     IN    JTF_VARCHAR2_TABLE_100,
            o_status_arr         OUT NOCOPY JTF_NUMBER_TABLE,
            o_error_code         OUT NOCOPY NUMBER,
            o_error_msg          OUT NOCOPY VARCHAR2
            );

/** Insert bulk EFT transactions **/
PROCEDURE insertEFTBatchTrxns(
            i_ecappid        IN iby_trxn_summaries_all.ecappid%TYPE,
            i_payeeid        IN iby_trxn_summaries_all.payeeid%TYPE,
            i_ecbatchid      IN iby_trxn_summaries_all.ecbatchid%TYPE,
            i_bepid          IN iby_trxn_summaries_all.bepid%TYPE,
            i_bepkey         IN iby_trxn_summaries_all.bepkey%TYPE,
            i_pmtmethod      IN iby_trxn_summaries_all.paymentmethodname%TYPE,
            i_reqtype        IN iby_trxn_summaries_all.reqtype%TYPE,
            i_reqdate        IN iby_trxn_summaries_all.reqdate%TYPE,
            i_payeeinstrid   IN iby_trxn_summaries_all.payeeinstrid%TYPE,
            i_orgid          IN iby_trxn_summaries_all.org_id%TYPE,

            i_payerinstrid   IN JTF_NUMBER_TABLE,
            i_amount         IN JTF_NUMBER_TABLE,
            i_payerid        IN JTF_VARCHAR2_TABLE_100,
            i_tangibleid     IN JTF_VARCHAR2_TABLE_100,
            i_currency       IN JTF_VARCHAR2_TABLE_100,
            i_refinfo        IN JTF_VARCHAR2_TABLE_100,
            i_memo           IN JTF_VARCHAR2_TABLE_100,
            i_OrderMedium    IN JTF_VARCHAR2_TABLE_100,
            i_EftAuthMethod  IN JTF_VARCHAR2_TABLE_100,
            i_instrsubtype   IN JTF_VARCHAR2_TABLE_100,
            i_settledate     IN JTF_DATE_TABLE,
            i_issuedate      IN JTF_DATE_TABLE,
            i_customerref    IN JTF_VARCHAR2_TABLE_100,
            o_trxnId         OUT NOCOPY JTF_NUMBER_TABLE
            );

/** Insert verify EFT transaction **/
  PROCEDURE createEFTVerifyTrxn(
            i_ecappid        IN iby_trxn_summaries_all.ecappid%TYPE,
            i_reqtype        IN iby_trxn_summaries_all.reqtype%TYPE,
            i_bepid          IN iby_trxn_summaries_all.bepid%TYPE,
            i_bepkey         IN iby_trxn_summaries_all.bepkey%TYPE,
            i_payeeid        IN iby_trxn_summaries_all.payeeid%TYPE,
            i_payeeinstrid   IN iby_trxn_summaries_all.payeeinstrid%TYPE,
            i_tangibleid     IN iby_trxn_summaries_all.tangibleid%TYPE,
            i_amount         IN iby_trxn_summaries_all.amount%TYPE,
            i_currency       IN iby_trxn_summaries_all.currencynamecode%TYPE,
            i_status         IN iby_trxn_summaries_all.status%TYPE,
            i_refinfo        IN iby_tangible.refinfo%TYPE,
            i_memo           IN iby_tangible.memo%TYPE,
            i_acctno         IN iby_tangible.acctno%TYPE,
            i_OrderMedium    IN iby_tangible.order_medium%TYPE,
            i_EftAuthMethod  IN iby_tangible.eft_auth_method%TYPE,
            i_orgid          IN iby_trxn_summaries_all.org_id%TYPE,
            i_pmtmethod      IN iby_trxn_summaries_all.paymentmethodname%TYPE,
    	    i_payerid        IN iby_trxn_summaries_all.payerid%TYPE,
            i_instrtype      IN iby_trxn_summaries_all.instrtype%TYPE,
            i_instrsubtype   IN iby_trxn_summaries_all.instrsubtype%TYPE,
            i_payerinstrid   IN iby_trxn_summaries_all.payerinstrid%TYPE,
            i_trxndate       IN iby_trxn_summaries_all.updatedate%TYPE,
            i_trxntypeid     IN iby_trxn_summaries_all.TrxntypeID%TYPE,
            i_bepcode        IN iby_trxn_summaries_all.BEPCode%TYPE,
            i_bepmessage     IN iby_trxn_summaries_all.BEPMessage%TYPE,
            i_errorlocation  IN iby_trxn_summaries_all.errorlocation%TYPE,
            i_referenceCode  IN iby_trxn_summaries_all.proc_reference_code%TYPE,
            o_trxnid         OUT NOCOPY iby_trxn_summaries_all.transactionid%TYPE,
            i_orgtype        IN iby_trxn_summaries_all.org_type%TYPE,
            i_pmtchannelcode IN iby_trxn_summaries_all.payment_channel_code%TYPE,
            i_factoredflag   IN iby_trxn_summaries_all.factored_flag%TYPE,
            i_pmtinstrassignmentId IN iby_trxn_summaries_all.payer_instr_assignment_id%TYPE,
            i_process_profile_code IN iby_trxn_summaries_all.process_profile_code%TYPE,
            o_trxnmid        OUT NOCOPY iby_trxn_summaries_all.trxnmid%TYPE
            );

  PROCEDURE validate_open_batch
  (
  p_bep_id           IN     iby_trxn_summaries_all.bepid%TYPE,
  p_mbatch_id        IN     iby_batches_all.mbatchid%TYPE
  );


/*--------------------------------------------------------------------
 | NAME:
 |     print_debuginfo
 |
 | PURPOSE:
 |     This procedure prints the debug message to the concurrent manager
 |     log file.
 |
 | PARAMETERS:
 |     IN
 |      p_debug_text - The debug message to be printed
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_debuginfo(
     p_module     IN VARCHAR2,
     p_debug_text IN VARCHAR2
     );

END iby_transactioneft_pkg;


/
