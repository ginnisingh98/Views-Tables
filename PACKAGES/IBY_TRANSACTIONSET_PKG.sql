--------------------------------------------------------
--  DDL for Package IBY_TRANSACTIONSET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_TRANSACTIONSET_PKG" AUTHID CURRENT_USER AS
/*$Header: ibytxsts.pls 120.2 2005/10/30 05:51:19 appldev ship $ */

  /* This procedure would be used every time a SET INIT transaction     */
  /* occurred.  Since INIT is not idempotent, this procedure only       */
  /* inserts a new row into the transactions table after the vendor     */
  /* application has returned.  It does not perform any error checking  */
  /* to make sure that the row already exists since the programmer      */
  /* should have called queryset.listvendor to check beforehand.        */
  PROCEDURE insert_init_txn
        (ecapp_id_in         IN     iby_trxn_summaries_all.ECAPPID%TYPE,
         req_type_in         IN     iby_trxn_summaries_all.ReqType%TYPE,
         order_id_in         IN     iby_trxn_summaries_all.TangibleID%TYPE,
         merchant_id_in      IN     iby_trxn_summaries_all.PayeeID%TYPE,
         vendor_id_in        IN     iby_trxn_summaries_all.BEPID%TYPE,
         trxn_type_in        IN OUT NOCOPY iby_trxn_summaries_all.TrxntypeID%TYPE,
         payment_name_in     IN     iby_trxn_core.InstrName%TYPE,
         price_in            IN     iby_trxn_summaries_all.Amount%TYPE,
         currency_in         IN     iby_trxn_summaries_all.CurrencyNameCode%TYPE,
         time_in             IN     iby_trxn_summaries_all.UpdateDate%TYPE,
         status_in           IN     iby_trxn_summaries_all.Status%TYPE,
         transaction_id_in_out IN OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE,
         vendor_code_in      IN     iby_trxn_summaries_all.BEPCode%TYPE
                                      DEFAULT NULL,
         vendor_message_in   IN     iby_trxn_summaries_all.BEPMessage%TYPE
                                      DEFAULT NULL,
         error_location_in   IN     iby_trxn_summaries_all.ErrorLocation%TYPE
                                      DEFAULT NULL,
         billeracct_in       IN     iby_tangible.acctno%type,
         refinfo_in          IN     iby_tangible.refinfo%type,
         memo_in             IN     iby_tangible.memo%type,
         order_medium_in     IN     iby_tangible.order_medium%TYPE,
         eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	 org_id_in 	IN 	iby_trxn_summaries_all.org_id%TYPE,
	 payerinstrid_in	IN	iby_trxn_summaries_all.payerinstrid%type,
   	 instrnum_in	IN  iby_trxn_summaries_all.instrnumber%type);

  /* This procedure would be used every time a SET SET                 */
  /* transaction occurred.  Since SET is idempotent, the procedure     */
  /* checks to see if the row already exists based upon order_id,      */
  /* merchant_id, trxn_type, and request_type.                         */
  PROCEDURE insert_set_txn
        (ecapp_id_in         IN     iby_trxn_summaries_all.ECAPPID%TYPE,
         req_type_in         IN     iby_trxn_summaries_all.ReqType%TYPE,
         order_id_in         IN     iby_trxn_summaries_all.TangibleID%TYPE,
         merchant_id_in      IN     iby_trxn_summaries_all.PayeeID%TYPE,
         vendor_id_in        IN     iby_trxn_summaries_all.BEPID%TYPE,
         trxn_type_in        IN     iby_trxn_summaries_all.TrxntypeID%TYPE,
         split_id_in         IN     iby_trxn_extended.SplitID%TYPE,
         payment_name_in     IN     iby_trxn_core.InstrName%TYPE,
         price_in            IN     iby_trxn_summaries_all.Amount%TYPE,
         currency_in         IN     iby_trxn_summaries_all.CurrencyNameCode%TYPE,
         time_in             IN     iby_trxn_summaries_all.UpdateDate%TYPE,
         status_in           IN     iby_trxn_summaries_all.Status%TYPE,
         authcode_in         IN     iby_trxn_core.AuthCode%TYPE,
         capcode_in          IN     iby_trxn_core.OperationCode%TYPE,
         completion_code_in  IN     iby_trxn_extended.CompletionCode%TYPE,
         set_trxn_id_in      IN     iby_trxn_extended.SETTrxnID%TYPE,
         batch_id_in         IN     iby_trxn_summaries_all.batchID%TYPE,
         batch_seq_num_in    IN     iby_trxn_extended.BatchSeqNum%TYPE,
         AVS_result_in       IN     iby_trxn_core.AVSCode%TYPE,
         ret_ref_num_in      IN     iby_trxn_core.ReferenceCode%TYPE,
         card_BIN_in         IN     iby_trxn_extended.Cardbin%TYPE,
         terminal_id_in      IN     iby_trxn_extended.TerminalID%TYPE,
         request_type_in     IN     iby_trxn_extended.SETReqType%TYPE,
         subseq_auth_ind_in  IN     iby_trxn_extended.SubAuthInd%TYPE,
         transaction_id_in_out IN OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE,
         payment_method_in    IN    iby_trxn_summaries_all.PAYMENTMETHODNAME%TYPE,
         vendor_code_in      IN     iby_trxn_summaries_all.BEPCode%TYPE
                                      DEFAULT NULL,
         vendor_message_in   IN     iby_trxn_summaries_all.BEPMessage%TYPE
                                      DEFAULT NULL,
         error_location_in   IN     iby_trxn_summaries_all.ErrorLocation%TYPE
                                      DEFAULT NULL,
         billeracct_in       IN     iby_tangible.acctno%type ,
         refinfo_in          IN     iby_tangible.refinfo%type,
         memo_in             IN     iby_tangible.memo%type ,
         order_medium_in     IN     iby_tangible.order_medium%TYPE,
         eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
 	 org_id_in 	     IN     iby_trxn_summaries_all.org_id%TYPE,
 	 payerinstrid_in     IN	    iby_trxn_summaries_all.payerinstrid%type,
	 instrnum_in	IN  iby_trxn_summaries_all.instrnumber%type);


  /* This procedure would be used every time a SET AUTH or AUTHREV     */
  /* transaction occurred.  Since AUTH and AUTHREV are idempotent, the */
  /* procedure checks to see if the row already exists based upon      */
  /* order_id, merchant_id, and split_id.                              */
  PROCEDURE insert_auth_txn
        (ecapp_id_in         IN     iby_trxn_summaries_all.ECAPPID%TYPE,
         req_type_in         IN     iby_trxn_summaries_all.ReqType%TYPE,
         order_id_in         IN     iby_trxn_summaries_all.TangibleID%TYPE,
         merchant_id_in      IN     iby_trxn_summaries_all.PayeeID%TYPE,
         vendor_id_in        IN     iby_trxn_summaries_all.BEPID%TYPE,
         trxn_type_in        IN     iby_trxn_summaries_all.TrxntypeID%TYPE,
         split_id_in         IN     iby_trxn_extended.SplitID%TYPE,
         payment_name_in     IN     iby_trxn_summaries_all.PaymentMethodName%TYPE,
         price_in            IN     iby_trxn_summaries_all.Amount%TYPE,
         currency_in         IN     iby_trxn_summaries_all.CurrencyNameCode%TYPE,
         time_in             IN     iby_trxn_summaries_all.UpdateDate%TYPE,
         status_in           IN     iby_trxn_summaries_all.Status%TYPE,
         authcode_in         IN     iby_trxn_core.AuthCode%TYPE,
         capcode_in          IN     iby_trxn_core.OperationCode%TYPE,
         completion_code_in  IN     iby_trxn_extended.CompletionCode%TYPE,
         set_trxn_id_in      IN     iby_trxn_extended.SETTrxnID%TYPE,
         batch_id_in         IN OUT NOCOPY iby_trxn_summaries_all.batchID%TYPE,
         batch_seq_num_in    IN OUT NOCOPY iby_trxn_extended.BatchSeqNum%TYPE,
         AVS_result_in       IN OUT NOCOPY iby_trxn_core.AVSCode%TYPE,
         ret_ref_num_in      IN     iby_trxn_core.ReferenceCode%TYPE,
         card_BIN_in         IN OUT NOCOPY iby_trxn_extended.Cardbin%TYPE,
         terminal_id_in      IN OUT NOCOPY iby_trxn_extended.TerminalID%TYPE,
         subseq_auth_ind_in  IN     iby_trxn_extended.SubAuthInd%TYPE,
         vendor_code_in      IN OUT NOCOPY iby_trxn_summaries_all.BEPCode%TYPE,
         vendor_message_in   IN OUT NOCOPY iby_trxn_summaries_all.BEPMessage%TYPE,
         error_location_in   IN OUT NOCOPY iby_trxn_summaries_all.ErrorLocation%TYPE,
         transaction_id_in_out IN OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE,
	payment_method_in	IN
		iby_trxn_summaries_all.PAYMENTMETHODNAME%TYPE,
         billeracct_in       IN     iby_tangible.acctno%type,
         refinfo_in          IN     iby_tangible.refinfo%type,
         memo_in             IN     iby_tangible.memo%type,
         order_medium_in     IN     iby_tangible.order_medium%TYPE,
         eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	org_id_in 	IN 	iby_trxn_summaries_all.org_id%TYPE,
	payerinstrid_in	IN	iby_trxn_summaries_all.payerinstrid%type,
	instrnum_in	IN  iby_trxn_summaries_all.instrnumber%type);


  /* Inserts a new row into the PS_TRANSACTIONS table.  This method     */
  /* would be called every time a SET CAPTURE, CAPTUREREV, CREDIT, or   */
  /* CREDITREV operation is performed.                                  */

  PROCEDURE insert_other_txn
        (ecapp_id_in         IN     iby_trxn_summaries_all.ECAPPID%TYPE,
         req_type_in         IN     iby_trxn_summaries_all.ReqType%TYPE,
         order_id_in         IN     iby_trxn_summaries_all.TangibleID%TYPE,
         merchant_id_in      IN     iby_trxn_summaries_all.PayeeID%TYPE,
         vendor_id_in        IN     iby_trxn_summaries_all.BEPID%TYPE,
         trxn_type_in        IN     iby_trxn_summaries_all.TrxntypeID%TYPE,
         split_id_in         IN     iby_trxn_extended.SplitID%TYPE,
         payment_name_in     IN     iby_trxn_summaries_all.PAYMENTMETHODNAME%TYPE,
         price_in            IN     iby_trxn_summaries_all.Amount%TYPE,
         currency_in         IN     iby_trxn_summaries_all.CurrencyNameCode%TYPE,
         time_in             IN     iby_trxn_summaries_all.UpdateDate%TYPE,
         status_in           IN     iby_trxn_summaries_all.Status%TYPE,
         operation_code_in   IN     iby_trxn_core.OperationCode%TYPE,
         set_trxn_id_in      IN     iby_trxn_extended.SETTrxnID%TYPE,
         batch_id_in         IN OUT NOCOPY iby_trxn_summaries_all.batchID%TYPE,
         batch_seq_num_in    IN OUT NOCOPY iby_trxn_extended.BatchSeqNum%TYPE,
         terminal_id_in      IN OUT NOCOPY iby_trxn_extended.TerminalID%TYPE,
         subseq_auth_ind_in  IN     iby_trxn_extended.SubAuthInd%TYPE,
         vendor_code_in      IN OUT NOCOPY iby_trxn_summaries_all.BEPCode%TYPE,
         vendor_message_in   IN OUT NOCOPY iby_trxn_summaries_all.BEPMessage%TYPE,
         error_location_in   IN OUT NOCOPY iby_trxn_summaries_all.ErrorLocation%TYPE,
         transaction_id_in_out IN OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE,
         billeracct_in       IN     iby_tangible.acctno%type,
         refinfo_in          IN     iby_tangible.refinfo%type,
         memo_in             IN     iby_tangible.memo%type,
         order_medium_in     IN     iby_tangible.order_medium%TYPE,
         eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	org_id_in 	IN 	iby_trxn_summaries_all.org_id%TYPE,
	payerinstrid_in	IN	iby_trxn_summaries_all.payerinstrid%type,
	instrnum_in	IN  iby_trxn_summaries_all.instrnumber%type);


  /* Inserts or updates a row in the PS_TRXN_TABLE if the  */
  /* operation timed out from calling the vendor.                  */
  PROCEDURE insert_timeout_txn
        (ecapp_id_in         IN     iby_trxn_summaries_all.ECAPPID%TYPE,
         req_type_in         IN     iby_trxn_summaries_all.ReqType%TYPE,
         order_id_in         IN     iby_trxn_summaries_all.TangibleID%TYPE,
         merchant_id_in      IN     iby_trxn_summaries_all.PayeeID%TYPE,
         vendor_id_in        IN     iby_trxn_summaries_all.BEPID%TYPE,
         trxn_type_in        IN     iby_trxn_summaries_all.TrxntypeID%TYPE,
         split_id_in         IN     iby_trxn_extended.SplitID%TYPE,
         payment_name_in     IN     iby_trxn_core.InstrName%TYPE,
         time_in             IN     iby_trxn_summaries_all.UpdateDate%TYPE,
         status_in           IN     iby_trxn_summaries_all.Status%TYPE,
         transaction_id_in_out IN OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE,
         currency_in         IN     iby_tangible.currencynamecode%type,
         amount_in           IN     iby_transactions_v.amount%TYPE,
         billeracct_in       IN     iby_tangible.acctno%type,
         refinfo_in          IN     iby_tangible.refinfo%type,
         memo_in             IN     iby_tangible.memo%type,
         order_medium_in     IN     iby_tangible.order_medium%TYPE,
         eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	org_id_in 	IN 	iby_trxn_summaries_all.org_id%TYPE,
	payerinstrid_in	IN	iby_trxn_summaries_all.payerinstrid%type,
	instrnum_in	IN  iby_trxn_summaries_all.instrnumber%type);


  /* Inserts or updates a batch summary row into the PS_BATCH_SET    */
  /* table.  This should happen for open or close batch operations.  */
  PROCEDURE insert_batch_status
    (batch_id_in           IN     iby_batches_all.BatchID%TYPE,
     merchant_id_in        IN     iby_batches_all.PayeeID%TYPE,
     bep_id_in		   IN     iby_batches_all.BEPID%TYPE,
     /* vendor_suffix_in      IN     iby_batches_all.vendor_suffix%TYPE, */
     /* close_status_in       IN     iby_batches_all.BatchCloseStatus%TYPE, */
     currency_in           IN     iby_batches_all.CurrencyNameCode%TYPE,
     sale_price_in         IN     iby_batches_all.BatchSales%TYPE,
     credit_price_in       IN     iby_batches_all.BatchCredit%TYPE,
     trxn_count_in	   IN     iby_batches_all.NumTrxns%TYPE,
     sale_trxn_count_in    IN     iby_batches_all.NumTrxns%TYPE,
     credit_trxn_count_in  IN     iby_batches_all.NumTrxns%TYPE,
     open_date_in          IN     iby_batches_all.BatchOpenDate%TYPE,
     close_date_in         IN     iby_batches_all.BatchCloseDate%TYPE,
     status_in             IN     iby_batches_all.BatchStatus%TYPE,
     vendor_code_in        IN     iby_batches_all.BEPCode%TYPE,
     vendor_message_in     IN     iby_batches_all.BEPMessage%TYPE,
     error_location_in     IN     iby_batches_all.ErrorLocation%TYPE,
	org_id_in 	IN 	iby_batches_all.org_id%TYPE,
	 req_type_in IN iby_batches_all.reqtype%type);


  /* Inserts or updates the batch detail record upon the         */
  /* closebatch or querybatch operations.                        */
  PROCEDURE insert_batch_txn
        (ecapp_id_in         IN     iby_trxn_summaries_all.ECAPPID%TYPE,
         order_id_in         IN     iby_trxn_summaries_all.TangibleID%TYPE,
         merchant_id_in      IN     iby_trxn_summaries_all.PayeeID%TYPE,
         vendor_id_in        IN     iby_trxn_summaries_all.BEPID%TYPE,
         trxn_type_in        IN     iby_trxn_summaries_all.TrxntypeID%TYPE,
         split_id_in         IN     iby_trxn_extended.SplitID%TYPE,
         payment_name_in     IN     iby_trxn_core.InstrName%TYPE,
         price_in            IN     iby_trxn_summaries_all.Amount%TYPE,
         currency_in         IN     iby_trxn_summaries_all.CurrencyNameCode%TYPE,
         time_in             IN     iby_trxn_summaries_all.UpdateDate%TYPE,
         status_in           IN     iby_trxn_summaries_all.Status%TYPE,
         set_trxn_id_in      IN     iby_trxn_extended.SETTrxnID%TYPE,
         prev_set_trxn_id_in IN     iby_trxn_extended.SETTrxnID%TYPE,
         batch_id_in         IN     iby_trxn_summaries_all.batchID%TYPE,
         batch_seq_num_in    IN     iby_trxn_extended.BatchSeqNum%TYPE,
         batch_trxn_status_in IN    iby_trxn_extended.BatchTrxnStatus%TYPE,
         card_BIN_in         IN     iby_trxn_extended.Cardbin%TYPE,
         terminal_id_in      IN     iby_trxn_extended.TerminalID%TYPE,
         vendor_code_in      IN     iby_trxn_summaries_all.BEPCode%TYPE,
         vendor_message_in   IN     iby_trxn_summaries_all.BEPMessage%TYPE,
         error_location_in   IN     iby_trxn_summaries_all.ErrorLocation%TYPE,
         split_id_in_out     IN OUT NOCOPY iby_trxn_extended.SplitID%TYPE,
	org_id_in 	IN 	iby_trxn_summaries_all.org_id%TYPE);
  /* Inserts transaction record for transaction query operation */
  PROCEDURE insert_query_txn
        (ecapp_id_in         IN     iby_trxn_summaries_all.ECAPPID%TYPE,
         order_id_in         IN     iby_trxn_summaries_all.TangibleID%TYPE,
         merchant_id_in      IN     iby_trxn_summaries_all.PayeeID%TYPE,
         vendor_id_in        IN     iby_trxn_summaries_all.BEPID%TYPE,
         trxn_type_in        IN     iby_trxn_summaries_all.TrxntypeID%TYPE,
         price_in            IN     iby_trxn_summaries_all.Amount%TYPE,
         currency_in         IN     iby_trxn_summaries_all.CurrencyNameCode%TYPE,
         time_in             IN     iby_trxn_summaries_all.UpdateDate%TYPE,
         status_in           IN     iby_trxn_summaries_all.Status%TYPE,
         set_trxn_id_in      IN     iby_trxn_extended.SETTrxnID%TYPE,
         prev_set_trxn_id_in IN     iby_trxn_extended.SETTrxnID%TYPE,
         ret_ref_num_in      IN     iby_trxn_core.ReferenceCode%TYPE,
         card_BIN_in         IN OUT NOCOPY iby_trxn_extended.Cardbin%TYPE,
         terminal_id_in      IN OUT NOCOPY iby_trxn_extended.TerminalID%TYPE,
         vendor_code_in      IN OUT NOCOPY iby_trxn_summaries_all.BEPCode%TYPE,
         vendor_message_in   IN OUT NOCOPY iby_trxn_summaries_all.BEPMessage%TYPE,
         error_location_in   IN OUT NOCOPY iby_trxn_summaries_all.ErrorLocation%TYPE,
         split_id_in_out     IN OUT NOCOPY iby_trxn_extended.SplitID%TYPE,
         transaction_id_in   IN     iby_trxn_summaries_all.TransactionID%TYPE,
	payment_method_in      IN   iby_trxn_summaries_all.PaymentMethodName%TYPE,
 	org_id_in 	IN 	iby_trxn_summaries_all.org_id%TYPE,
	req_type_in IN iby_trxn_summaries_all.reqtype%type);

  /* Internal procedure to get the split_id of the parent  */
  /* transaction. */
  PROCEDURE find_parent_splitid
        (order_id_in         IN     iby_trxn_summaries_all.TangibleID%TYPE,
         merchant_id_in      IN     iby_trxn_summaries_all.PayeeID%TYPE,
         vendor_id_in        IN     iby_trxn_summaries_all.BEPID%TYPE,
         trxn_type_in        IN     iby_trxn_summaries_all.TrxntypeID%TYPE,
         prev_set_trxn_id_in IN     iby_trxn_extended.SETTrxnID%TYPE,
         split_id_in_out     IN OUT NOCOPY iby_trxn_extended.SplitID%TYPE);
END iby_transactionSET_pkg;

/
