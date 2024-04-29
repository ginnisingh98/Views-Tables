--------------------------------------------------------
--  DDL for Package IBY_TRANSACTIONCC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_TRANSACTIONCC_PKG" AUTHID CURRENT_USER AS
/*$Header: ibytxccs.pls 120.26.12010000.9 2009/10/08 10:23:59 sugottum ship $ */

  --
  -- various trxn status constants
  --
  C_STATUS_SUCCESS CONSTANT NUMBER := 0;
  C_STATUS_COMMUNICATION_ERROR CONSTANT NUMBER := 1;
  C_STATUS_BEP_FAIL CONSTANT NUMBER := 5;
  C_STATUS_REQUEST_PENDING CONSTANT NUMBER := 11;
  C_STATUS_SCHED_IN_PROGRESS CONSTANT NUMBER := 12;
  C_STATUS_REQUEST_SCHEDULED CONSTANT NUMBER := 13;
  C_STATUS_VOICE_AUTH_REQD CONSTANT NUMBER := 21;
  C_STATUS_OPEN_BATCHED CONSTANT NUMBER := 100;
  C_STATUS_BATCH_TRANSITIONAL CONSTANT NUMBER := 109;
  C_STATUS_BATCH_PENDING CONSTANT NUMBER := 111;

  --
  -- credit card req types
  --
  C_REQTYPE_BATCHCLOSE CONSTANT VARCHAR2(100)     := 'ORAPMTCLOSEBATCH';
  C_REQTYPE_PDC_BATCHCLOSE CONSTANT VARCHAR2(100) := 'ORAPMTPDCCLOSEBATCH';
  C_REQTYPE_EFT_BATCHCLOSE CONSTANT VARCHAR2(100) := 'ORAPMTEFTCLOSEBATCH';

  C_REQTYPE_CAPTURE  CONSTANT VARCHAR2(100) := 'ORAPMTCAPTURE';
  C_REQTYPE_CREDIT   CONSTANT VARCHAR2(100) := 'ORAPMTCREDIT';
  C_REQTYPE_RETURN   CONSTANT VARCHAR2(100) := 'ORAPMTRETURN';
  C_REQTYPE_REQUEST  CONSTANT VARCHAR2(100) := 'ORAPMTREQ';
  C_REQTYPE_BATCHREQ CONSTANT VARCHAR2(100) := 'ORAPMTBATCHREQ';

  /*
   * Record that stores the transaction attributes that are
   * used as criteria for grouping.
   */
  TYPE trxnGroupCriteriaType IS RECORD (
      trxn_id
          IBY_TRXN_SUMMARIES_ALL.transactionid%TYPE,
      process_profile_code
          IBY_TRXN_SUMMARIES_ALL.process_profile_code%TYPE,
      bep_key
          IBY_TRXN_SUMMARIES_ALL.bepkey%TYPE,
      org_id
          IBY_TRXN_SUMMARIES_ALL.org_id%TYPE,
      org_type
          IBY_TRXN_SUMMARIES_ALL.org_type%TYPE,
      curr_code
          IBY_TRXN_SUMMARIES_ALL.currencynamecode%TYPE,
      amount
          IBY_TRXN_SUMMARIES_ALL.amount%TYPE,
      legal_entity_id
          IBY_TRXN_SUMMARIES_ALL.legal_entity_id%TYPE,
      int_bank_acct_id
          IBY_TRXN_SUMMARIES_ALL.payeeinstrid%TYPE,
      settle_date
          IBY_TRXN_SUMMARIES_ALL.settledate%TYPE,
      group_by_org
          IBY_FNDCPT_SYS_CC_PF_B.group_by_org%TYPE,
      group_by_le
          IBY_FNDCPT_SYS_CC_PF_B.group_by_legal_entity%TYPE,
      group_by_int_bank_acct
          IBY_FNDCPT_SYS_CC_PF_B.group_by_int_bank_account%TYPE,
      group_by_curr
          IBY_FNDCPT_SYS_CC_PF_B.group_by_settlement_curr%TYPE,
      group_by_settle_date
          IBY_FNDCPT_SYS_CC_PF_B.group_by_settlement_date%TYPE,
      max_amt_curr
          IBY_FNDCPT_SYS_CC_PF_B.limit_by_amt_curr%TYPE,
      fx_rate_type
          IBY_FNDCPT_SYS_CC_PF_B.limit_by_exch_rate_type%TYPE,
      max_amt_limit
          IBY_FNDCPT_SYS_CC_PF_B.limit_by_total_amt%TYPE,
      num_trxns_limit
          IBY_FNDCPT_SYS_CC_PF_B.limit_by_settlement_num%TYPE
      );

  /*
   * Table of transaction grouping criteria.
   */
  TYPE trxnGroupCriteriaTabType IS TABLE OF trxnGroupCriteriaType
      INDEX BY BINARY_INTEGER;

  /*
   * Record to store attributes of a batch that
   * are influenced by transaction grouping rules.
   *
   * The IBY_BATCHES_ALL table will be updated with
   * these attributes after transaction grouping.
   */
  TYPE batchAttrRecType IS RECORD (
      mbatch_id
          IBY_BATCHES_ALL.mbatchid%TYPE,
      batch_id
          IBY_BATCHES_ALL.batchid%TYPE,
      profile_code
          IBY_BATCHES_ALL.process_profile_code%TYPE,
      bep_key
          IBY_BATCHES_ALL.bepkey%TYPE,
      org_id
          IBY_BATCHES_ALL.org_id%TYPE,
      org_type
          IBY_BATCHES_ALL.org_type%TYPE,
      le_id
          IBY_BATCHES_ALL.legal_entity_id%TYPE,
      int_bank_acct_id
          IBY_BATCHES_ALL.payeeinstrid%TYPE,
      curr_code
          IBY_BATCHES_ALL.currencynamecode%TYPE,
      settle_date
          IBY_BATCHES_ALL.settledate%TYPE
      );

  /*
   * Table of grouping based batch attributes.
   */
  TYPE batchAttrTabType IS TABLE OF batchAttrRecType
      INDEX BY BINARY_INTEGER;


  /*
   * Record that holds the relationship between
   * a batch and transaction.
   */
  TYPE trxnsInBatchRecType IS RECORD (
      trxn_id
          IBY_TRXN_SUMMARIES_ALL.transactionid%TYPE,
      mbatch_id
          IBY_TRXN_SUMMARIES_ALL.mbatchid%TYPE,
      batch_id
          IBY_TRXN_SUMMARIES_ALL.batchid%TYPE
  );

  /*
   * Table of trxn-batch relationships.
   */
  TYPE trxnsInBatchTabType IS TABLE OF trxnsInBatchRecType
      INDEX BY BINARY_INTEGER;

 /*
  * Table of mbatch ids.
  *
  * Maps to IBY_BATCHES_ALL.MBATCHID.
  */
 TYPE mBatchIdsTab IS TABLE OF IBY_BATCHES_ALL.mbatchid%TYPE
     INDEX BY BINARY_INTEGER;

-- Changes for bug# 8889709
  TYPE t_mbatchid IS TABLE OF
     IBY_BATCHES_ALL.mbatchid%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_batchid IS TABLE OF
     IBY_BATCHES_ALL.batchid%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_profcode IS TABLE OF
     IBY_BATCHES_ALL.process_profile_code%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_bepkey IS TABLE OF
     IBY_BATCHES_ALL.bepkey%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_org_id IS TABLE OF
     IBY_BATCHES_ALL.org_id%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_org_type IS TABLE OF
     IBY_BATCHES_ALL.org_type%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_legal_entity_id IS TABLE OF
     IBY_BATCHES_ALL.legal_entity_id%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_payeeinstrid IS TABLE OF
     IBY_BATCHES_ALL.payeeinstrid%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_currencynamecode IS TABLE OF
     IBY_BATCHES_ALL.currencynamecode%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_settledate IS TABLE OF
     IBY_BATCHES_ALL.settledate%TYPE
     INDEX BY BINARY_INTEGER;

 TYPE batch_tab_type IS RECORD
 (
    mbatchid t_mbatchid,
    batchid  t_batchid,
    profCode t_profcode,
    bepkey   t_bepkey,
    orgid    t_org_id,
    orgtype  t_org_type,
    legalentityid t_legal_entity_id,
    payeeinstrid t_payeeinstrid,
    currencycode t_currencynamecode,
    settledate   t_settledate
 );
 batchTab batch_tab_type;

-- Bug# 8889709 - Transaction Tab
  TYPE t_transactionid IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.transactionid%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_mbatch_id IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.mbatchid%TYPE
     INDEX BY BINARY_INTEGER;

  TYPE t_batch_id IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.batchid%TYPE
     INDEX BY BINARY_INTEGER;
  TYPE transaction_tab_type IS RECORD
  (
     transactionid t_transactionid,
     mbatchid t_mbatch_id,
     batchid t_batch_id
  );
  trxnTab transaction_tab_type;
  -- End bug# 8889709

  PROCEDURE validate_open_batch
  (
  p_bep_id           IN     iby_trxn_summaries_all.bepid%TYPE,
  p_mbatch_id        IN     iby_batches_all.mbatchid%TYPE,
  p_sec_key_on       IN     VARCHAR2,
  x_trxn_count       OUT NOCOPY iby_batches_all.numtrxns%TYPE,
  x_batch_currency   OUT NOCOPY iby_batches_all.currencynamecode%TYPE
  );

  PROCEDURE prepare_instr_data
  (p_commit   IN  VARCHAR2,
   p_sys_key  IN  iby_security_pkg.DES3_KEY_TYPE,
   p_instrnum IN  iby_trxn_summaries_all.instrnumber%TYPE,
   p_instrtype IN  iby_trxn_summaries_all.instrtype%TYPE,
   x_instrnum OUT NOCOPY iby_trxn_summaries_all.instrnumber%TYPE,
   x_instr_subtype OUT NOCOPY iby_trxn_summaries_all.instrsubtype%TYPE,
   x_instr_hash    OUT NOCOPY iby_trxn_summaries_all.instrnum_hash%TYPE,
   x_range_id OUT NOCOPY iby_trxn_summaries_all.instrnum_sec_segment_id%TYPE,
   x_instr_len OUT NOCOPY iby_trxn_summaries_all.instrnum_length%TYPE,
   x_segment_id OUT NOCOPY iby_trxn_summaries_all.instrnum_sec_segment_id%TYPE
  );

  PROCEDURE insert_extensibility
  (
  p_trxnmid           IN     iby_trxn_summaries_all.trxnmid%TYPE,
  p_commit            IN     VARCHAR2,
  p_extend_names      IN     JTF_VARCHAR2_TABLE_100,
  p_extend_vals       IN     JTF_VARCHAR2_TABLE_200
  );

  /* Inserts a new row into the IBY_TRANSACTIONS table.  This method     */
  /* would be called every time a MIPP authorize operation is performed. */

  PROCEDURE insert_auth_txn
	(
	 ecapp_id_in         IN     iby_trxn_summaries_all.ecappid%TYPE,
         req_type_in         IN     iby_trxn_summaries_all.ReqType%TYPE,
         order_id_in         IN     iby_transactions_v.order_id%TYPE,
         merchant_id_in      IN     iby_transactions_v.merchant_id%TYPE,
         vendor_id_in        IN     iby_transactions_v.vendor_id%TYPE,
         vendor_key_in       IN     iby_transactions_v.bepkey%TYPE,
         amount_in           IN     iby_transactions_v.amount%TYPE,
         currency_in         IN     iby_transactions_v.currency%TYPE,
         status_in           IN     iby_transactions_v.status%TYPE,
         time_in             IN     iby_transactions_v.time%TYPE DEFAULT sysdate,
         payment_name_in     IN     iby_transactions_v.payment_name%TYPE,
	 payment_type_in     IN	    iby_transactions_v.payment_type%TYPE,
         trxn_type_in        IN     iby_transactions_v.trxn_type%TYPE DEFAULT NULL,
	 authcode_in         IN     iby_transactions_v.authcode%TYPE DEFAULT NULL,
	 referencecode_in    IN     iby_transactions_v.referencecode%TYPE DEFAULT NULL,
         AVScode_in          IN     iby_transactions_v.AVScode%TYPE DEFAULT NULL,
         acquirer_in         IN     iby_transactions_v.acquirer%TYPE DEFAULT NULL,
         Auxmsg_in           IN     iby_transactions_v.Auxmsg%TYPE DEFAULT NULL,
         vendor_code_in      IN     iby_transactions_v.vendor_code%TYPE DEFAULT NULL,
         vendor_message_in   IN     iby_transactions_v.vendor_message%TYPE DEFAULT NULL,
         error_location_in   IN     iby_transactions_v.error_location%TYPE DEFAULT NULL,
         trace_number_in     IN	    iby_transactions_v.TraceNumber%TYPE DEFAULT NULL,
	 org_id_in           IN     iby_trxn_summaries_all.org_id%type DEFAULT NULL,
         billeracct_in       IN     iby_tangible.acctno%type,
         refinfo_in          IN     iby_tangible.refinfo%type,
         memo_in             IN     iby_tangible.memo%type,
         order_medium_in     IN     iby_tangible.order_medium%TYPE,
         eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	 payerinstrid_in     IN	    iby_trxn_summaries_all.payerinstrid%type,
	 instrnum_in	     IN     iby_trxn_summaries_all.instrnumber%type,
	 payerid_in          IN     iby_trxn_summaries_all.payerid%type,
	 instrtype_in        IN     iby_trxn_summaries_all.instrType%type,
         cvv2result_in       IN     iby_trxn_core.CVV2Result%type,
	 master_key_in       IN     iby_security_pkg.DES3_KEY_TYPE,
	 subkey_seed_in	     IN     RAW,
         trxnref_in          IN     iby_trxn_summaries_all.trxnref%TYPE,
         dateofvoiceauth_in  IN     iby_trxn_core.date_of_voice_authorization%TYPE,
         instr_expirydate_in IN     iby_trxn_core.instr_expirydate%TYPE,
         instr_sec_val_in    IN     VARCHAR2,
         card_subtype_in     IN     iby_trxn_core.card_subtype_code%TYPE,
         card_data_level_in  IN     iby_trxn_core.card_data_level%TYPE,
         instr_owner_name_in IN     iby_trxn_core.instr_owner_name%TYPE,
         instr_address_line1_in IN  iby_trxn_core.instr_owner_address_line1%TYPE,
         instr_address_line2_in IN  iby_trxn_core.instr_owner_address_line2%TYPE,
         instr_address_line3_in IN  iby_trxn_core.instr_owner_address_line3%TYPE,
         instr_city_in       IN     iby_trxn_core.instr_owner_city%TYPE,
         instr_state_in      IN     iby_trxn_core.instr_owner_state_province%TYPE,
         instr_country_in    IN     iby_trxn_core.instr_owner_country%TYPE,
         instr_postalcode_in IN     iby_trxn_core.instr_owner_postalcode%TYPE,
         instr_phonenumber_in IN    iby_trxn_core.instr_owner_phone%TYPE,
         instr_email_in      IN     iby_trxn_core.instr_owner_email%TYPE,
         pos_reader_cap_in   IN     iby_trxn_core.pos_reader_capability_code%TYPE,
         pos_entry_method_in IN     iby_trxn_core.pos_entry_method_code%TYPE,
         pos_card_id_method_in IN   iby_trxn_core.pos_id_method_code%TYPE,
         pos_auth_source_in  IN     iby_trxn_core.pos_auth_source_code%TYPE,
         reader_data_in      IN     iby_trxn_core.reader_data%TYPE,
         extend_names_in     IN     JTF_VARCHAR2_TABLE_100,
         extend_vals_in      IN     JTF_VARCHAR2_TABLE_200,
         debit_network_code_in IN   iby_trxn_core.debit_network_code%TYPE,
         surcharge_amount_in  IN    iby_trxn_core.surcharge_amount%TYPE,
         proc_tracenumber_in  IN    iby_trxn_core.proc_tracenumber%TYPE,
         transaction_id_out  OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE,
         transaction_mid_out OUT NOCOPY iby_trxn_summaries_all.trxnmid%TYPE,
         org_type_in         IN      iby_trxn_summaries_all.org_type%TYPE,
         payment_channel_code_in  IN iby_trxn_summaries_all.payment_channel_code%TYPE,
         factored_flag_in         IN iby_trxn_summaries_all.factored_flag%TYPE,
         process_profile_code_in     IN iby_trxn_summaries_all.process_profile_code%TYPE,
	 sub_key_id_in       IN     iby_trxn_summaries_all.sub_key_id%TYPE,
	 voiceAuthFlag_in    IN     iby_trxn_core.voiceauthflag%TYPE
	);


  /* Inserts a new row into the IBY_TRANSACTIONS table.  This method     */
  /* would be called every time a MIPP capture, credit, return, or void */
  /* operation is performed.                                            */


  PROCEDURE insert_other_txn
	(
	ecapp_id_in             IN     iby_trxn_summaries_all.ECAPPID%TYPE,
	req_type_in		IN     iby_trxn_summaries_all.ReqType%TYPE,
	order_id_in		IN     iby_transactions_v.order_id%TYPE,
	merchant_id_in		IN     iby_transactions_v.merchant_id%TYPE,
	vendor_id_in		IN     iby_transactions_v.vendor_id%TYPE,
	vendor_key_in		IN     iby_transactions_v.bepkey%TYPE,
	status_in		IN     iby_transactions_v.status%TYPE,
	time_in			IN     iby_transactions_v.time%TYPE DEFAULT sysdate,
	payment_type_in		IN     iby_transactions_v.payment_type%TYPE,
	payment_name_in		IN     iby_transactions_v.payment_name%TYPE DEFAULT NULL,
	trxn_type_in		IN     iby_transactions_v.trxn_type%TYPE DEFAULT NULL,
        amount_in		IN     iby_transactions_v.amount%TYPE DEFAULT NULL,
	currency_in		IN     iby_transactions_v.currency%TYPE DEFAULT NULL,
	referencecode_in	IN     iby_transactions_v.referencecode%TYPE DEFAULT NULL,
	vendor_code_in		IN     iby_transactions_v.vendor_code%TYPE DEFAULT NULL,
	vendor_message_in	IN     iby_transactions_v.vendor_message%TYPE DEFAULT NULL,
	error_location_in	IN     iby_transactions_v.error_location%TYPE DEFAULT NULL,
	trace_number_in		IN     iby_transactions_v.TraceNumber%TYPE DEFAULT NULL,
	org_id_in		IN     iby_trxn_summaries_all.org_id%type DEFAULT NULL,
	billeracct_in		IN     iby_tangible.acctno%type,
	refinfo_in		IN     iby_tangible.refinfo%type,
	memo_in			IN     iby_tangible.memo%type,
        order_medium_in     IN     iby_tangible.order_medium%TYPE,
        eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	payerinstrid_in		IN     iby_trxn_summaries_all.payerinstrid%type,
	instrnum_in		IN     iby_trxn_summaries_all.instrnumber%type,
	payerid_in		IN     iby_trxn_summaries_all.payerid%type,
	master_key_in		IN     iby_security_pkg.DES3_KEY_TYPE,
	subkey_seed_in	        IN     RAW,
        trxnref_in              IN     iby_trxn_summaries_all.trxnref%TYPE,
        instr_expirydate_in     IN     iby_trxn_core.instr_expirydate%TYPE,
        card_subtype_in         IN     iby_trxn_core.card_subtype_code%TYPE,
        instr_owner_name_in     IN     iby_trxn_core.instr_owner_name%TYPE,
        instr_address_line1_in  IN     iby_trxn_core.instr_owner_address_line1%TYPE,
        instr_address_line2_in  IN     iby_trxn_core.instr_owner_address_line2%TYPE,
        instr_address_line3_in  IN     iby_trxn_core.instr_owner_address_line3%TYPE,
        instr_city_in           IN     iby_trxn_core.instr_owner_city%TYPE,
        instr_state_in          IN     iby_trxn_core.instr_owner_state_province%TYPE,
        instr_country_in        IN     iby_trxn_core.instr_owner_country%TYPE,
        instr_postalcode_in     IN     iby_trxn_core.instr_owner_postalcode%TYPE,
        instr_phonenumber_in    IN     iby_trxn_core.instr_owner_phone%TYPE,
        instr_email_in          IN     iby_trxn_core.instr_owner_email%TYPE,
        extend_names_in         IN     JTF_VARCHAR2_TABLE_100,
        extend_vals_in          IN     JTF_VARCHAR2_TABLE_200,
	transaction_id_in_out   IN OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE,
        transaction_mid_out OUT NOCOPY iby_trxn_summaries_all.trxnmid%TYPE,
        org_type_in         IN      iby_trxn_summaries_all.org_type%TYPE,
        payment_channel_code_in  IN iby_trxn_summaries_all.payment_channel_code%TYPE,
        factored_flag_in         IN iby_trxn_summaries_all.factored_flag%TYPE,
	settlement_date_in       IN iby_trxn_summaries_all.settledate%TYPE,
 	settlement_due_date_in   IN iby_trxn_summaries_all.settlement_due_date%TYPE,
        process_profile_code_in   IN iby_trxn_summaries_all.process_profile_code%TYPE,
        instrtype_in              IN iby_trxn_summaries_all.instrtype%TYPE
        );


  /* Inserts a row into the iby_transaction table if auth, capture, */
  /* return, credit, and void timeout				   */

  PROCEDURE insert_timeout_txn
        (
	req_type_in         IN     iby_trxn_summaries_all.ReqType%TYPE,
	order_id_in         IN     iby_transactions_v.order_id%TYPE,
	merchant_id_in      IN     iby_transactions_v.merchant_id%TYPE,
	vendor_id_in        IN     iby_transactions_v.vendor_id%TYPE,
	vendor_key_in       IN     iby_transactions_v.bepkey%TYPE,
	ecapp_id_in	    IN	   iby_trxn_summaries_all.ecappid%TYPE,
        time_in             IN     iby_transactions_v.time%TYPE DEFAULT sysdate,
	status_in           IN     iby_transactions_v.status%TYPE,
	org_id_in           IN     iby_trxn_summaries_all.org_id%type DEFAULT NULL,
	amount_in	    IN     iby_tangible.amount%type,
        currency_in	    IN     iby_tangible.currencynamecode%type,
        billeracct_in       IN     iby_tangible.acctno%type,
        refinfo_in          IN     iby_tangible.refinfo%type,
        memo_in             IN     iby_tangible.memo%type,
        order_medium_in     IN     iby_tangible.order_medium%TYPE,
        eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	payerinstrid_in	    IN	   iby_trxn_summaries_all.payerinstrid%type,
	instrnum_in	    IN     iby_trxn_summaries_all.instrnumber%type,
	payerid_in          IN     iby_trxn_summaries_all.payerid%type,
	instrtype_in        IN     iby_trxn_summaries_all.instrType%type,
	master_key_in       IN     iby_security_pkg.DES3_KEY_TYPE,
	subkey_seed_in	    IN     RAW,
        trxnref_in          IN     iby_trxn_summaries_all.trxnref%TYPE,
        transaction_id_out  OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE,
        transaction_mid_out OUT NOCOPY iby_trxn_summaries_all.trxnmid%TYPE,
        trxntypeid_in       IN     iby_trxn_summaries_all.trxntypeid%TYPE,
         org_type_in         IN      iby_trxn_summaries_all.org_type%TYPE,
         payment_channel_code_in  IN iby_trxn_summaries_all.payment_channel_code%TYPE,
         factored_flag_in         IN iby_trxn_summaries_all.factored_flag%TYPE
	);


  /* Checks if a row exists for a set of parameters	         */
  /* This function is used by querybatch and query transaction   */
  /* procedures before inserting a new row into the transactions */
  /* table							 */

  FUNCTION checkrows
        (order_id_in         IN     iby_transactions_v.order_id%TYPE,
         merchant_id_in      IN     iby_transactions_v.merchant_id%TYPE,
         vendor_id_in        IN     iby_transactions_v.vendor_id%TYPE,
         status_in           IN     iby_transactions_v.status%TYPE,
         trxn_type_in        IN     iby_transactions_v.trxn_type%TYPE)
   RETURN number;



  /*
  * Inserts a row about batch status into iby_batches_all.  This will
  * be called for link error, timeout error or other batch status with
  * gateway payment systems.  For processor payment systems, this will
  * create a new batch and associate all trxns in the current, unnamed
  * open batch with it.
  */
  PROCEDURE insert_batch_status
    (merch_batchid_in    IN     iby_batches_all.batchid%TYPE,
     merchant_id_in      IN     iby_batches_all.payeeid%TYPE,
     vendor_id_in        IN     iby_batches_all.bepid%TYPE,
     vendor_key_in       IN     iby_batches_all.bepkey%TYPE,
     pmt_type_in         IN     iby_batches_all.paymentmethodname%TYPE,
     status_in           IN     iby_batches_all.batchstatus%TYPE,
     time_in             IN     iby_batches_all.batchclosedate%TYPE DEFAULT SYSDATE,
     viby_batchid_in     IN     iby_batches_all.vpsbatchid%TYPE,
     currency_in         IN     iby_batches_all.currencynamecode%TYPE DEFAULT NULL,
     numtrxns_in         IN     iby_batches_all.NumTrxns%TYPE DEFAULT NULL,
     batchstate_in       IN     iby_batches_all.BatchStateid%TYPE DEFAULT NULL,
     batchtotal_in       IN     iby_batches_all.BatchTotal%TYPE DEFAULT NULL,
     saleamount_in       IN     iby_batches_all.BatchSales%TYPE DEFAULT NULL,
     cramount_in         IN     iby_batches_all.BatchCredit%TYPE DEFAULT NULL,
     gwid_in             IN     iby_batches_all.GWBatchID%TYPE DEFAULT NULL,
     vendor_code_in      IN     iby_batches_all.bepcode%TYPE DEFAULT NULL,
     vendor_message_in   IN     iby_batches_all.bepmessage%TYPE DEFAULT NULL,
     error_location_in   IN     iby_batches_all.errorlocation%TYPE DEFAULT NULL,
     terminal_id_in      IN     iby_batches_all.TerminalId%TYPE DEFAULT NULL,
     acquirer_id_in      IN     iby_batches_all.Acquirer%TYPE DEFAULT NULL,
     org_id_in           IN     iby_trxn_summaries_all.org_id%type DEFAULT NULL,
     req_type_in         IN     iby_batches_all.reqtype%type,
     sec_key_present_in  IN     VARCHAR2,
     mbatchid_out        OUT NOCOPY iby_batches_all.mbatchid%type
    );

  /*
   * Performs batch close operation by grouping pending transactions.
   * This method can generate multiple mbatchids for a single
   * batch close call depending upon how many batches are
   * generated by applying grouping rules.
   */
  PROCEDURE insert_batch_status_new
    (merch_batchid_in    IN     iby_batches_all.batchid%TYPE,
     profile_code_in     IN     iby_batches_all.process_profile_code%TYPE,
     merchant_id_in      IN     iby_batches_all.payeeid%TYPE,
     vendor_id_in        IN     iby_batches_all.bepid%TYPE,
     vendor_key_in       IN     iby_batches_all.bepkey%TYPE,
     pmt_type_in         IN     iby_batches_all.paymentmethodname%TYPE,
     status_in           IN     iby_batches_all.batchstatus%TYPE,
     time_in             IN     iby_batches_all.batchclosedate%TYPE,
     viby_batchid_in     IN     iby_batches_all.vpsbatchid%TYPE ,
     currency_in         IN     iby_batches_all.currencynamecode%TYPE,
     numtrxns_in         IN     iby_batches_all.NumTrxns%TYPE,
     batchstate_in       IN     iby_batches_all.BatchStateid%TYPE,
     batchtotal_in       IN     iby_batches_all.BatchTotal%TYPE,
     saleamount_in       IN     iby_batches_all.BatchSales%TYPE,
     cramount_in         IN     iby_batches_all.BatchCredit%TYPE,
     gwid_in             IN     iby_batches_all.GWBatchID%TYPE,
     vendor_code_in      IN     iby_batches_all.BEPcode%TYPE,
     vendor_message_in   IN     iby_batches_all.BEPmessage%TYPE,
     error_location_in   IN     iby_batches_all.errorlocation%TYPE,
     terminal_id_in      IN     iby_batches_all.TerminalId%TYPE,
     acquirer_id_in      IN     iby_batches_all.Acquirer%TYPE,
     org_id_in           IN     iby_trxn_summaries_all.org_id%TYPE,
     req_type_in         IN     iby_batches_all.reqtype%TYPE,
     sec_key_present_in  IN     VARCHAR2,
     acct_profile_in     IN     iby_batches_all.process_profile_code%TYPE,
     instr_type_in       IN     iby_batches_all.instrument_type%TYPE,
     br_disputed_flag_in IN     iby_batches_all.br_disputed_flag%TYPE,
     f_pmt_channel_in    IN     iby_trxn_summaries_all.
                                    payment_channel_code%TYPE,
     f_curr_in           IN     iby_trxn_summaries_all.
                                    currencynamecode%TYPE,
     f_settle_date       IN     iby_trxn_summaries_all.
                                    settledate%TYPE,
     f_due_date          IN     iby_trxn_summaries_all.
                                    settlement_due_date%TYPE,
     f_maturity_date     IN     iby_trxn_summaries_all.
                                    br_maturity_date%TYPE,
     f_instr_type        IN     iby_trxn_summaries_all.
                                    instrtype%TYPE,
     mbatch_ids_out      OUT    NOCOPY JTF_NUMBER_TABLE,
     batch_ids_out       OUT    NOCOPY JTF_VARCHAR2_TABLE_100
     );

/* Overloaded form of the above API. This one takes an
   Array of user profiles instead of a single one.
*/
PROCEDURE insert_batch_status_new
    (merch_batchid_in    IN     iby_batches_all.batchid%TYPE,
     profile_code_array  IN     JTF_VARCHAR2_TABLE_100,
     merchant_id_in      IN     iby_batches_all.payeeid%TYPE,
     vendor_id_in        IN     iby_batches_all.bepid%TYPE,
     vendor_key_in       IN     iby_batches_all.bepkey%TYPE,
     pmt_type_in         IN     iby_batches_all.paymentmethodname%TYPE,
     status_in           IN     iby_batches_all.batchstatus%TYPE,
     time_in             IN     iby_batches_all.batchclosedate%TYPE,
     viby_batchid_in     IN     iby_batches_all.vpsbatchid%TYPE ,
     currency_in         IN     iby_batches_all.currencynamecode%TYPE,
     numtrxns_in         IN     iby_batches_all.NumTrxns%TYPE,
     batchstate_in       IN     iby_batches_all.BatchStateid%TYPE,
     batchtotal_in       IN     iby_batches_all.BatchTotal%TYPE,
     saleamount_in       IN     iby_batches_all.BatchSales%TYPE,
     cramount_in         IN     iby_batches_all.BatchCredit%TYPE,
     gwid_in             IN     iby_batches_all.GWBatchID%TYPE,
     vendor_code_in      IN     iby_batches_all.BEPcode%TYPE,
     vendor_message_in   IN     iby_batches_all.BEPmessage%TYPE,
     error_location_in   IN     iby_batches_all.errorlocation%TYPE,
     terminal_id_in      IN     iby_batches_all.TerminalId%TYPE,
     acquirer_id_in      IN     iby_batches_all.Acquirer%TYPE,
     org_id_in           IN     iby_trxn_summaries_all.org_id%TYPE,
     req_type_in         IN     iby_batches_all.reqtype%TYPE,
     sec_key_present_in  IN     VARCHAR2,
     acct_profile_in     IN     iby_batches_all.process_profile_code%TYPE,
     instr_type_in       IN     iby_batches_all.instrument_type%TYPE,
     br_disputed_flag_in IN     iby_batches_all.br_disputed_flag%TYPE,
     f_pmt_channel_in    IN     iby_trxn_summaries_all.
                                    payment_channel_code%TYPE,
     f_curr_in           IN     iby_trxn_summaries_all.
                                    currencynamecode%TYPE,
     f_settle_date       IN     iby_trxn_summaries_all.
                                    settledate%TYPE,
     f_due_date          IN     iby_trxn_summaries_all.
                                    settlement_due_date%TYPE,
     f_maturity_date     IN     iby_trxn_summaries_all.
                                    br_maturity_date%TYPE,
     f_instr_type        IN     iby_trxn_summaries_all.
                                    instrtype%TYPE,
     mbatch_ids_out      OUT    NOCOPY JTF_NUMBER_TABLE,
     batch_ids_out       OUT    NOCOPY JTF_VARCHAR2_TABLE_100
     );



  /* Inserts the transaction record for the closebatch operation */

  PROCEDURE insert_batch_txn
    (ecapp_id_in         IN     iby_trxn_summaries_all.ECAPPID%TYPE,
     order_id_in      IN     iby_transactions_v.order_id%TYPE,
     merchant_id_in   IN     iby_transactions_v.merchant_id%TYPE,
     merch_batchid_in    IN      iby_transactions_v.MerchBatchID%TYPE,
     vendor_id_in     IN     iby_transactions_v.vendor_id%TYPE,
     vendor_key_in     IN     iby_transactions_v.bepkey%TYPE,
     status_in           IN     iby_transactions_v.status%TYPE,
     time_in             IN     iby_transactions_v.time%TYPE
				   DEFAULT sysdate,
     trxn_type_in	      IN     iby_transactions_v.trxn_type%TYPE,
     vendor_code_in      IN     iby_transactions_v.vendor_code%TYPE
                                   DEFAULT NULL,
     vendor_message_in   IN     iby_transactions_v.vendor_message%TYPE
                                   DEFAULT NULL,
     error_location_in   IN     iby_transactions_v.error_location%TYPE
                                   DEFAULT NULL,
     trace_number_in        IN    iby_transactions_v.TraceNumber%TYPE
                                   DEFAULT NULL,

	 org_id_in IN iby_trxn_summaries_all.org_id%type
				   DEFAULT NULL,
     transaction_id_out  OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE);


  /* Inserts transaction record for transaction query operation */


  PROCEDURE insert_query_txn
    (transaction_id_in   IN     iby_trxn_summaries_all.TransactionID%TYPE,
     order_id_in         IN     iby_transactions_v.order_id%TYPE,
     merchant_id_in      IN     iby_transactions_v.merchant_id%TYPE,
     vendor_id_in        IN     iby_transactions_v.vendor_id%TYPE,
     vendor_key_in       IN     iby_transactions_v.bepkey%TYPE,
     status_in           IN     iby_transactions_v.status%TYPE,
     time_in             IN     iby_transactions_v.time%TYPE DEFAULT sysdate,
     trxn_type_in        IN     iby_transactions_v.trxn_type%TYPE,
     amount_in           IN     iby_transactions_v.amount%TYPE DEFAULT NULL,
     currency_in         IN     iby_transactions_v.currency%TYPE DEFAULT NULL,
     payment_name_in     IN     iby_transactions_v.payment_name%TYPE DEFAULT NULL,
     authcode_in         IN     iby_transactions_v.authcode%TYPE DEFAULT NULL,
     referencecode_in    IN     iby_transactions_v.referencecode%TYPE DEFAULT NULL,
     avscode_in          IN     iby_transactions_v.AVScode%TYPE DEFAULT NULL,
     acquirer_in         IN     iby_transactions_v.acquirer%TYPE DEFAULT NULL,
     auxmsg_in           IN     iby_transactions_v.Auxmsg%TYPE DEFAULT NULL,
     vendor_code_in      IN     iby_transactions_v.vendor_code%TYPE DEFAULT NULL,
     vendor_message_in   IN     iby_transactions_v.vendor_message%TYPE DEFAULT NULL,
     error_location_in   IN     iby_transactions_v.error_location%TYPE DEFAULT NULL,
     trace_number_in     IN     iby_transactions_v.TraceNumber%TYPE DEFAULT NULL,
     org_id_in           IN     iby_trxn_summaries_all.org_id%type DEFAULT NULL,
     ecappid_in          IN     iby_ecapp.ecappid%type,
     req_type_in         IN     iby_trxn_summaries_all.reqtype%type);



/*
** Procedure: getMBatchId
** Purpose: retrieve mBatchid from iby_Batch table based on Batchid
*/
Procedure getMBatchId(i_Batchid in iby_Batches_all.Batchid%type,
			i_Payeeid in iby_Batches_all.Payeeid%type,
                        o_mBatchid out nocopy iby_Batches_all.mBatchid%type);

/*
** Function: getTID
** Purpose: get the next trxnid availabe, make sure there is only one TID
**          per tangibleid, payeeid combination
*/
Function getTID(i_payeeid in iby_payee.payeeid%type,
		i_tangibleid in iby_tangible.tangibleid%type)
return number;


/*
** Function: getTIDUniqueCheck
** Purpose: If there is already a trxnid available for a
**          tangibleid, payeeid combination this method
**          returns -1, else it returns a unique trxnid.
*/
Function getTIDUniqueCheck(i_payeeid in iby_payee.payeeid%type,
             i_tangibleid in iby_tangible.tangibleid%type)
return number;


Function getNumPendingTrxns(i_payeeid in iby_payee.payeeid%type,
			i_tangibleid in iby_tangible.tangibleid%type,
			i_reqtype in iby_trxn_summaries_all.reqtype%type)
return number;

Function getOrgId(i_tid in iby_trxn_summaries_all.transactionid%type)
return number;

  /*
   * USE: Updates the status of trxns stored in an iPayment internal batch.
   *      This must be done after a batch close so that they are not sent
   *      multiple times.
   *
   * ARGS:
   *      1. the merchant/payee id
   *      2. the bep/payment system id
   *      3. the bep key
   *      4. the old status; used to filter which trxns are in a batch
   *      5. the new status to which all trxns should be set
   *      6. the id of the batch to which the trxns will belong
   */
  PROCEDURE updateBatchedTrxns
	(
	payeeid_in	IN	iby_trxn_summaries_all.payeeid%TYPE,
	bepid_in	IN	iby_trxn_summaries_all.bepid%TYPE,
	bepkey_in	IN	iby_trxn_summaries_all.bepkey%TYPE,
	oldstatus_in	IN	iby_trxn_summaries_all.status%TYPE,
	newstatus_in	IN	iby_trxn_summaries_all.status%TYPE,
	oldbatchid_in	IN	iby_trxn_summaries_all.batchid%TYPE,
	newbatchid_in	IN      iby_trxn_summaries_all.batchid%TYPE
	);

  /*
   * USE: Updates a batched trxn based on batch query values.
   *
   * ARGS:
   *      1. the merchant/payee id
   *      2. the order tangible id of the trxn
   *      3. the trxn type id of the trxn
   *      4. the id of the batch to which the trxn belongs
   *      5. the new status of the trxn
   *      6. the final BEP code for the trxn
   *      7. the final BEP message for the trxn
   *      8. error location for the trxn
   *
   * OUTS:
   *	  9. the trxnid of the given transaction
   *
   * NOTES:
   *      For all parameters that default to null- if not
   *      set then the applicable row in the table will not be updated
   */
  PROCEDURE updateBatchQueryTrxn
	(
	payeeid_in	IN	iby_trxn_summaries_all.payeeid%TYPE,
	orderid_in	IN	iby_trxn_summaries_all.batchid%TYPE,
	trxn_type_in	IN      iby_trxn_summaries_all.trxntypeid%TYPE,
	batchid_in	IN	iby_trxn_summaries_all.batchid%TYPE,
	status_in	IN	iby_trxn_summaries_all.status%TYPE,
	bep_code_in     IN      iby_trxn_summaries_all.bepcode%TYPE DEFAULT NULL,
	bep_msg_in      IN      iby_trxn_summaries_all.bepmessage%TYPE DEFAULT NULL,
	error_loc_in    IN      iby_trxn_summaries_all.errorlocation%TYPE DEFAULT NULL,
	trxnid_out      OUT NOCOPY iby_trxn_summaries_all.transactionid%TYPE
	);

  /*
   * USE: Overloaded version of the above method used for batched
   *      authorizations; passes extra fields such as auth code, cvv2
   *      result, etc.
   *
   * ARGS:
   *     9. the auth code
   *     10. the avs code
   *     11. the cvv2 result
   *
   * OUTS:
   *	 12. the trxnid of the given transaction
   *
   * NOTES:
   *      For all parameters that default to null- if not
   *      set then the applicable row in the table will not be updated
   */
  PROCEDURE updateBatchQueryTrxn
	(
	payeeid_in	IN	iby_trxn_summaries_all.payeeid%TYPE,
	orderid_in	IN	iby_trxn_summaries_all.batchid%TYPE,
	trxn_type_in	IN      iby_trxn_summaries_all.trxntypeid%TYPE,
	batchid_in	IN	iby_trxn_summaries_all.batchid%TYPE,
	status_in	IN	iby_trxn_summaries_all.status%TYPE,
	bep_code_in     IN      iby_trxn_summaries_all.bepcode%TYPE DEFAULT NULL,
	bep_msg_in      IN      iby_trxn_summaries_all.bepmessage%TYPE DEFAULT NULL,
	error_loc_in    IN      iby_trxn_summaries_all.errorlocation%TYPE DEFAULT NULL,
	authcode_in     IN      iby_trxn_core.authcode%TYPE DEFAULT NULL,
	avscode_in      IN      iby_trxn_core.avscode%TYPE DEFAULT NULL,
	cvv2result_in   IN      iby_trxn_core.cvv2result%TYPE DEFAULT NULL,
	trxnid_out      OUT NOCOPY iby_trxn_summaries_all.transactionid%TYPE
	);

  PROCEDURE Update_Batch
  (
   ecapp_id_in          IN      iby_batches_all.ecappid%TYPE,
   payeeid_in	        IN      iby_trxn_summaries_all.payeeid%TYPE,
   batchid_in           IN      iby_trxn_summaries_all.batchid%TYPE,
   batch_status_in      IN      iby_batches_all.batchstatus%TYPE,
   batch_total_in       IN      iby_batches_all.batchtotal%TYPE,
   sale_amount_in       IN      iby_batches_all.batchsales%TYPE,
   credit_amount_in     IN      iby_batches_all.batchcredit%TYPE,
   bep_code_in          IN      iby_batches_all.bepcode%TYPE,
   bep_message_in       IN      iby_batches_all.bepmessage%TYPE,
   error_location_in    IN      iby_batches_all.errorlocation%TYPE,
   ack_type_in          IN      VARCHAR2,
   trxn_orderid_in	IN	JTF_VARCHAR2_TABLE_100,
   trxn_reqtype_in      IN      JTF_VARCHAR2_TABLE_100,
   trxn_status_in	IN	JTF_VARCHAR2_TABLE_100,
   trxn_bep_code_in     IN      JTF_VARCHAR2_TABLE_100,
   trxn_bep_msg_in      IN      JTF_VARCHAR2_TABLE_100,
   trxn_error_loc_in    IN      JTF_VARCHAR2_TABLE_100,
   trxn_authcode_in     IN      JTF_VARCHAR2_TABLE_100,
   trxn_avscode_in      IN      JTF_VARCHAR2_TABLE_100,
   trxn_cvv2result_in   IN      JTF_VARCHAR2_TABLE_100,
   trxn_tracenumber     IN      JTF_VARCHAR2_TABLE_100
  );


  FUNCTION unencrypt_instr_num
  (p_instrnum    IN iby_trxn_summaries_all.instrnumber%TYPE,
   p_payee_key   IN iby_security_pkg.des3_key_type,
   p_payee_subkey_cipher IN iby_payee_subkeys.subkey_cipher_text%TYPE,
   p_sys_key     IN RAW,
   p_sys_subkey_cipher IN iby_sys_security_subkeys.subkey_cipher_text%TYPE,
   p_segment_id  IN iby_security_segments.sec_segment_id%TYPE,
   p_segment_cipher IN iby_security_segments.segment_cipher_text%TYPE,
   p_card_prefix IN iby_cc_issuer_ranges.card_number_prefix%TYPE,
   p_card_len    IN iby_cc_issuer_ranges.card_number_length%TYPE,
   p_digit_check IN iby_creditcard_issuers_b.digit_check_flag%TYPE
  )
  RETURN iby_trxn_summaries_all.instrnumber%TYPE;

  /*
   * USE: Unencrypts the instrument number associated with the given trxn
   *      master id.
   *
   * ARGS:
   *     1. trxn master id
   *     2. the payee master key for that trxn
   *
   * OUTS:
   *	 3. unencrypted instrument number
   *
   * NOTES:
   *      For all parameters that default to null- if not
   *      set then the applicable row in the table will not be updated
   */
  PROCEDURE unencrypt_instr_num
  (trxnmid_in    IN iby_trxn_summaries_all.trxnmid%TYPE,
   master_key_in IN iby_security_pkg.DES3_KEY_TYPE,
   instr_num_out OUT NOCOPY iby_trxn_summaries_all.instrnumber%TYPE
  );

  /* Functional version of above procedure so that it can be used
   * 'in-line' in SQL statements.
   */
  FUNCTION unencrypt_instr_num
  (trxnmid_in    IN iby_trxn_summaries_all.trxnmid%TYPE,
   master_key_in IN iby_security_pkg.DES3_KEY_TYPE
  )
  RETURN iby_trxn_summaries_all.instrnumber%TYPE;

  /* Wrapper of above function for UI. In the UI the
   * SQL is executed by the framework. We can not catch
   * the exception thrown from the function call.
   * It will cause unacceptable error in the UI.
   * In case of exceptions this wrapper function will
   * simply swallow it and return null.
   * The UI will display empty instrument number
   * for this case.
   */
  FUNCTION unencrypt_instr_num_ui_wrp
	(
	trxnmid_in	IN	iby_trxn_summaries_all.trxnmid%TYPE,
	master_key_in	IN	iby_security_pkg.DES3_KEY_TYPE
	)
  RETURN iby_trxn_summaries_all.instrnumber%TYPE;

  -- USE
  --   Encrypts (historical) transactional credit card data
  --
  PROCEDURE Encrypt_CC_Data
  (p_sys_key IN IBY_SECURITY_PKG.DES3_KEY_TYPE,x_err_code OUT NOCOPY VARCHAR2);

  -- USE
  --   Decrypts (historical) transactional credit card data
  --
  PROCEDURE Decrypt_CC_Data
  (p_sys_key IN IBY_SECURITY_PKG.DES3_KEY_TYPE,x_err_code OUT NOCOPY VARCHAR2);

  /*
   * USE: Checks if the number of transactions in the current open
   *      batch exceeds the max batch size.
   * ARGS:
   *	1. the ecapp id - used to scope the payee id
   *    2. the payee id - specifies the owning payee of the batch
   *    3. bep id - specifies the bep associated with the batch
   *    4. bep key - the account number for the associated batch
   *
   * OUTS:
   *    5. trxn count - number of trxns in the open batch
   *    6. batch id - the next value from the batch id sequence if the
   *                  batch size exceeds its specifified limit; if within
   *                  its limits then NULL
   *
   */
  PROCEDURE check_batch_size
        (
	ecappid_in      IN      iby_trxn_summaries_all.ecappid%TYPE,
	payeeid_in      IN      iby_trxn_summaries_all.payeeid%TYPE,
	bepid_in        IN      iby_trxn_summaries_all.bepid%TYPE,
	bepkey_in       IN      iby_trxn_summaries_all.bepkey%TYPE,
        orgid_in        IN      iby_batches_all.org_id%TYPE,
        seckey_present_in IN    VARCHAR2,
        trxncount_out   OUT NOCOPY NUMBER,
        batchid_out     OUT NOCOPY iby_batches_all.batchid%TYPE
        );

/*--------------------------------------------------------------------
 | NAME:
 |     performTransactionGrouping
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performTransactionGrouping(
     p_profile_code       IN IBY_FNDCPT_USER_CC_PF_B.
                                 user_cc_profile_code%TYPE,
     instr_type           IN IBY_TRXN_SUMMARIES_ALL.
                                 instrtype%TYPE,
     req_type             IN IBY_BATCHES_ALL.
                                 reqtype%TYPE,
     f_pmt_channel_in     IN IBY_TRXN_SUMMARIES_ALL.
                                 payment_channel_code%TYPE,
     f_curr_in            IN IBY_TRXN_SUMMARIES_ALL.
                                 currencynamecode%TYPE,
     f_settle_date        IN IBY_TRXN_SUMMARIES_ALL.
                                 settledate%TYPE,
     f_due_date           IN IBY_TRXN_SUMMARIES_ALL.
                                 settlement_due_date%TYPE,
     f_maturity_date      IN IBY_TRXN_SUMMARIES_ALL.
                                 br_maturity_date%TYPE,
     f_instr_type         IN IBY_TRXN_SUMMARIES_ALL.
                                 instrtype%TYPE,
     x_batchTab           IN OUT NOCOPY IBY_TRANSACTIONCC_PKG.
                                            batchAttrTabType,
     x_trxnsInBatchTab    IN OUT NOCOPY IBY_TRANSACTIONCC_PKG.
                                            trxnsInBatchTabType
     );


/*--------------------------------------------------------------------
 | NAME:
 |     performTransactionGrouping
 |
 | PURPOSE:
 |     Overloaded form of the earlier API.
 |     Takes an array of user profiles as input
 |     instead of a single one.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performTransactionGrouping(
     profile_code_array   IN JTF_VARCHAR2_TABLE_100,
     instr_type           IN IBY_TRXN_SUMMARIES_ALL.
                                 instrtype%TYPE,
     req_type             IN IBY_BATCHES_ALL.
                                 reqtype%TYPE,
     f_pmt_channel_in     IN IBY_TRXN_SUMMARIES_ALL.
                                 payment_channel_code%TYPE,
     f_curr_in            IN IBY_TRXN_SUMMARIES_ALL.
                                 currencynamecode%TYPE,
     f_settle_date        IN IBY_TRXN_SUMMARIES_ALL.
                                 settledate%TYPE,
     f_due_date           IN IBY_TRXN_SUMMARIES_ALL.
                                 settlement_due_date%TYPE,
     f_maturity_date      IN IBY_TRXN_SUMMARIES_ALL.
                                 br_maturity_date%TYPE,
     f_instr_type         IN IBY_TRXN_SUMMARIES_ALL.
                                 instrtype%TYPE,
     merch_batchid_in     IN iby_batches_all.batchid%TYPE,

     x_batchTab           IN OUT NOCOPY IBY_TRANSACTIONCC_PKG.
                                            batchAttrTabType,
     x_trxnsInBatchTab    IN OUT NOCOPY IBY_TRANSACTIONCC_PKG.
                                            trxnsInBatchTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     insertTrxnIntoBatch
 |
 | PURPOSE:
 |     Inserts a given transaction into a currently running batch
 |     or into a new batch as per given flag.
 |
 |     This method is called by every grouping rule to add
 |     a given transaction into a current batch/new batch.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE insertTrxnIntoBatch(
     x_batchRec            IN OUT NOCOPY batchAttrRecType,
     x_batchTab            IN OUT NOCOPY batchAttrTabType,
     p_newBatchFlag        IN            BOOLEAN,
     x_currentBatchId      IN OUT NOCOPY IBY_BATCHES_ALL.batchid%TYPE,
     x_trxnsInBatchTab     IN OUT NOCOPY trxnsInBatchTabType,
     x_trxnsInBatchRec     IN OUT NOCOPY trxnsInBatchRecType,
     x_trxnsInBatchCount   IN OUT NOCOPY NUMBER
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getNextBatchId
 |
 | PURPOSE:
 |     Returns the next batch id from a sequence. These ids are
 |     used to uniquely number batches.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getNextBatchId(
     x_batchID IN OUT NOCOPY IBY_BATCHES_ALL.batchid%TYPE
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

/*--------------------------------------------------------------------
 | NAME:
 |   Update_Payer_Notif_Batch
 |
 | PURPOSE:
 |     This procedure updates the payer_notification_required flag for
 |     all the transactions in a batch.
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
 PROCEDURE Update_Payer_Notif_Batch(
     mbatchid_in  IN iby_batches_all.mbatchid%TYPE
 );

/*--------------------------------------------------------------------
 | NAME:
 |
 | PURPOSE:
 |     This procedure is used to free up the memory used by
 |     global memory structure [trxnTab]
 |
 | PARAMETERS:
 |
 |     NONE
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE delete_trxnTable;

END iby_transactioncc_pkg;



/
