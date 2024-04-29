--------------------------------------------------------
--  DDL for Package Body IBY_TRANSACTIONSET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_TRANSACTIONSET_PKG" AS
/*$Header: ibytxstb.pls 120.2.12010000.3 2009/04/04 00:44:55 svinjamu ship $*/

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
         vendor_code_in      IN     iby_trxn_summaries_all.BEPCode%TYPE,
         vendor_message_in   IN     iby_trxn_summaries_all.BEPMessage%TYPE,
         error_location_in   IN     iby_trxn_summaries_all.ErrorLocation%TYPE,
         billeracct_in       IN     iby_tangible.acctno%type,
         refinfo_in          IN     iby_tangible.refinfo%type,
         memo_in             IN     iby_tangible.memo%type,
         order_medium_in     IN     iby_tangible.order_medium%TYPE,
         eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	org_id_in 	IN 	iby_trxn_summaries_all.org_id%TYPE,
	payerinstrid_in	IN	iby_trxn_summaries_all.payerinstrid%type,
	instrnum_in	IN  iby_trxn_summaries_all.instrnumber%type)
  IS
    num_trxns      NUMBER          := 0;
    err_msg        VARCHAR2(100);
    trxn_mid       NUMBER;
    transaction_id NUMBER;
    l_tmid iby_trxn_summaries_all.mtangibleid%type;
    l_mpayeeid iby_payee.mpayeeid%type;

  BEGIN
    -- Check trxn_type
    IF ((trxn_type_in = '') OR
        (trxn_type_in IS NULL))
    THEN
      trxn_type_in := 0;
    END IF;
    -- Count number of previous transactions
    SELECT count(*)
      INTO num_trxns
      FROM iby_trxn_summaries_all
     WHERE TangibleID = order_id_in
       AND UPPER(ReqType) = UPPER(req_type_in)
       AND PayeeID = merchant_id_in;
    IF (num_trxns = 0)
    THEN
      -- Everything is fine, insert into table
      SELECT iby_trxnsumm_mid_s.NEXTVAL
        INTO trxn_mid
        FROM dual;
      IF ((transaction_id_in_out = '') OR
          (transaction_id_in_out = -1) OR
         (transaction_id_in_out IS NULL))
      THEN
         SELECT iby_trxnsumm_trxnid_s.NEXTVAL
           INTO transaction_id
           FROM dual;
         transaction_id_in_out := transaction_id;
      ELSE
         transaction_id := transaction_id_in_out;
      END IF;


	iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);


      -- Create a new entry in iby_tangible table
      iby_bill_pkg.createBill(order_id_in,price_in,currency_in,
                   billeracct_in,refinfo_in, memo_in,
                   order_medium_in, eft_auth_method_in,
                   l_tmid);

      INSERT INTO iby_trxn_summaries_all
        (TrxnMID, TransactionID,TrxntypeID, ECAPPID, org_id,
	ReqType, ReqDate,
         Amount,CurrencyNameCode, UpdateDate,Status,
         TangibleID,MPayeeID, PayeeID,BEPID,MtangibleId,
         BEPCode,BEPMessage,Errorlocation,
	payerinstrid, instrnumber,
	last_update_date, last_updated_by,
	creation_date, created_by,
	last_update_login, object_version_number,needsupdt)

      VALUES (trxn_mid, transaction_id, trxn_type_in, ecapp_id_in,
		org_id_in,
		req_type_in, time_in,
              price_in, currency_in, time_in, status_in,
              order_id_in, l_mpayeeid, merchant_id_in, vendor_id_in,l_tmid,
              vendor_code_in, vendor_message_in, error_location_in,
		payerinstrid_in, instrnum_in,
 		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1,'Y');

      INSERT INTO iby_trxn_extended
        (TrxnMID, SplitID,
	last_update_date, last_updated_by,
	creation_date, created_by,
	last_update_login, object_version_number)
      VALUES (trxn_mid, '1',
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);

    ELSIF (num_trxns = 1)
    THEN
      -- One previous transaction, so update previous row
       SELECT TrxnMID, TransactionID,MtangibleId
         INTO trxn_mid, transaction_id_in_out,l_tmid
      	 FROM iby_trxn_summaries_all
        WHERE TangibleID = order_id_in
          AND UPPER(ReqType) = UPPER(req_type_in)
          AND PayeeID = merchant_id_in;

     --Update iby_tangible table
      iby_bill_pkg.modBill(l_tmid,order_id_in,price_in,currency_in,
                           billeracct_in,refinfo_in,memo_in,
                           order_medium_in, eft_auth_method_in);

      UPDATE iby_trxn_summaries_all
         SET Amount = price_in,
             CurrencyNameCode = currency_in,
             --ReqDate = time_in,
		updatedate = time_in,
             Status = status_in,
             ErrorLocation = error_location_in,
             BEPCode = vendor_code_in,
             BEPMessage = vendor_message_in,

		payerinstrid = payerinstrid_in,
		instrnumber = instrnum_in,

	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

      UPDATE iby_trxn_extended
         SET SplitID = '1',
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

    ELSE
       	raise_application_error(-20000, 'IBY_20401#', FALSE);
      --raise_application_error(-20401,'Duplicate invoice transactions for this order_id');
    END IF;
    COMMIT;
  EXCEPTION

    WHEN OTHERS THEN
      err_msg := SUBSTR(SQLERRM, 1, 100);
       	raise_application_error(-20000, 'IBY_20400#', FALSE);
      --raise_application_error(-20400,'Error while inserting/updating invoice transaction: '||err_msg);
  END insert_init_txn;



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
         transaction_id_in_out   IN OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE,
         payment_method_in               IN      iby_trxn_summaries_all.PAYMENTMETHODNAME%TYPE,
         vendor_code_in      IN     iby_trxn_summaries_all.BEPCode%TYPE,
         vendor_message_in   IN     iby_trxn_summaries_all.BEPMessage%TYPE,
         error_location_in   IN     iby_trxn_summaries_all.ErrorLocation%TYPE,
         billeracct_in       IN     iby_tangible.acctno%type ,
         refinfo_in          IN     iby_tangible.refinfo%type,
         memo_in             IN     iby_tangible.memo%type ,
         order_medium_in     IN     iby_tangible.order_medium%TYPE,
         eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	org_id_in 	IN 	iby_trxn_summaries_all.org_id%TYPE,
	payerinstrid_in	IN	iby_trxn_summaries_all.payerinstrid%type,
	instrnum_in	IN  iby_trxn_summaries_all.instrnumber%type)
  IS

    num_trxns      NUMBER;
    counter         NUMBER;
    oper_code      iby_trxn_core.OperationCode%TYPE;
    err_msg        VARCHAR2(100);
    trxn_mid       NUMBER;
    transaction_id NUMBER;
    l_tmid iby_trxn_summaries_all.mtangibleid%type;
    l_order_id iby_trxn_summaries_all.tangibleid%type;

	l_mpayeeid iby_payee.mpayeeid%type;
	l_mbatchid iby_batches_all.mbatchid%type;
  BEGIN
    -- Initialize variables
    num_trxns := 0;

    -- Check request type values.  We don't store Error PDU,
    -- PINQ in database.
    --  0 = Error PDU, 1 = PINIT, 2 = PREQ, 3 = PINQ, 4 = SSL
    IF ((request_type_in <> 0) AND
        (request_type_in <> 1) AND
        (request_type_in <> 2) AND
        (request_type_in <> 3) AND
        (request_type_in <> 4))
    THEN
       	raise_application_error(-20000, 'IBY_20411#', FALSE);
      --raise_application_error(-20411,'Invalid request type value returned from the payment system: '||request_type_in);
    END IF;
    -- Check transaction type to set operation_code
    IF (trxn_type_in = 2)
    THEN
      -- Trxn is an AUTHONLY, so authcode is operation code
      -- and there is no capcode
      oper_code := authcode_in;
    ELSIF (trxn_type_in = 3)
    THEN
      -- Trxn is an AUTHCAPTURE, so capcode is the operation_code.
      -- If authcode is present, concatenate them so that the value
      -- of operation_code is CAPCODE-AUTHCODE.
      IF ((authcode_in = '') OR (authcode_in IS NULL))
      THEN
        oper_code := capcode_in;
      ELSE
        oper_code := capcode_in||'-'||authcode_in;
      END IF;
    ELSE
      -- Incorrect transaction type
       	raise_application_error(-20000, 'IBY_20412#', FALSE);
      --raise_application_error(-20412,'Invalid authorization type -- must be AUTHONLY 2 or AUTHCAPTURE 3');
    END IF;
    -- Check value of subseq_auth_ind
    IF ((subseq_auth_ind_in <> 0) AND
        (subseq_auth_ind_in <> 1))
    THEN
       	raise_application_error(-20000, 'IBY_20413#', FALSE);
      --raise_application_error(-20413,'Missing follow-on indicator');
    END IF;
    --Check for idempotency:  see if transaction already
    -- exists
    SELECT count(*)
      INTO num_trxns
      FROM iby_trxn_summaries_all
     WHERE TangibleID = order_id_in
       AND UPPER(ReqType) = UPPER(req_type_in)
       AND PayeeID = merchant_id_in;
    IF (num_trxns = 0)
    THEN


       -- No previous transaction, so insert new row
       -- generate trxn_mid, TransactionID
       SELECT iby_trxnsumm_mid_s.NEXTVAL
         INTO trxn_mid
         FROM dual;


      IF ((transaction_id_in_out = '') OR
         (transaction_id_in_out IS NULL) OR
	 (transaction_id_in_out = '-1'))
      THEN

         SELECT count(*)
           INTO counter
           FROM iby_trxn_summaries_all
          WHERE TangibleID = order_id_in
            AND PayeeID = merchant_id_in;


         IF (counter = 0)
         THEN

           SELECT iby_trxnsumm_trxnid_s.NEXTVAL
             INTO transaction_id
             FROM dual;

         ELSE
           SELECT DISTINCT TransactionId
             INTO transaction_id
             FROM iby_trxn_summaries_all
            WHERE TangibleID = order_id_in
              AND PayeeID = merchant_id_in;

         END IF;

         transaction_id_in_out := transaction_id;

	 -- create new tangible in such cases
      	 iby_bill_pkg.createBill(order_id_in,price_in,currency_in,
                   billeracct_in,refinfo_in, memo_in,
                   order_medium_in, eft_auth_method_in,
                   l_tmid);
	 l_order_id := order_id_in;

      ELSE
	--tangible info should already exist, get them based on
	--transactionid
	SELECT DISTINCT mtangibleid, tangibleid
	INTO l_tmid, l_order_id
	FROM iby_trxn_summaries_all
	WHERE transactionid = transaction_id_in_out;

         transaction_id := transaction_id_in_out;
      END IF;
	iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);

      INSERT INTO iby_trxn_summaries_all
        (TrxnMID, TransactionID,TrxntypeID,
         ECAPPID, org_id, ReqType, ReqDate, MtangibleId,
         Amount,CurrencyNameCode, TangibleID,MPayeeID, PayeeID,BEPID,
         BEPCode, BEPMessage,Errorlocation,PAYMENTMETHODNAME,status,
	payerinstrid, instrnumber,
	last_update_date, updatedate, last_updated_by,
	creation_date, created_by,
	last_update_login, object_version_number,needsupdt)
      VALUES (trxn_mid, transaction_id, trxn_type_in,
              ecapp_id_in, org_id_in, req_type_in, sysdate, l_tmid,
              price_in, currency_in, l_order_id, l_mpayeeid,
		merchant_id_in, vendor_id_in,
              vendor_code_in, vendor_message_in, error_location_in,
		payment_method_in,status_in,
	payerinstrid_in, instrnum_in,
		 sysdate, sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1,'Y');

      INSERT INTO iby_trxn_core
        (TrxnMID, OperationCode, AVSCode, ReferenceCode,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number)
      VALUES (trxn_mid, oper_code, avs_result_in, ret_ref_num_in,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);

      INSERT INTO iby_trxn_extended
        (TrxnMID, SplitID, CompletionCode, SETTrxnID,
         BatchSeqNum,
         Cardbin, TerminalID, SETReqType, SubAuthInd,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number)
      VALUES
        (trxn_mid, '1', completion_code_in, set_trxn_id_in,
         batch_seq_num_in,
         card_bin_in, terminal_id_in, request_type_in, subseq_auth_ind_in,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);

    ELSIF (num_trxns = 1)
    THEN
      -- One previous transaction, so update previous row
       SELECT TrxnMID, TransactionID,MtangibleId
         INTO trxn_mid, transaction_id_in_out,l_tmid
         FROM iby_trxn_summaries_all
        WHERE TangibleID = order_id_in
          AND UPPER(ReqType) = UPPER(req_type_in)
          AND PayeeID = merchant_id_in;

	iby_transactioncc_pkg.getMBatchID(batch_id_in, merchant_id_in,
					l_mbatchid);


	IF (UPPER(req_type_in) = 'ORAPMTCREDIT') THEN
	     -- Update iby_tangible table
	     iby_bill_pkg.modBill(l_tmid,order_id_in,price_in,currency_in,
                           billeracct_in,refinfo_in,memo_in,
                           order_medium_in, eft_auth_method_in);
	END IF;

      UPDATE iby_trxn_summaries_all
         SET Amount = price_in,
             CurrencyNameCode = currency_in,
             UpdateDate = time_in,
             Status = status_in,
             ErrorLocation = error_location_in,
             BEPCode = vendor_code_in,
             BEPMessage = vendor_message_in,
             BatchID = batch_id_in,
	     MBatchID = l_mbatchid,
		payerinstrid = payerinstrid_in,
		instrnumber = instrnum_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

      UPDATE iby_trxn_core
         SET OperationCode = oper_code,
             AvsCode = avs_result_in,
             ReferenceCode = ret_ref_num_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

      UPDATE iby_trxn_extended
         SET SplitID = '1',
             CompletionCode = completion_code_in,
             SETTrxnID = set_trxn_id_in,
             BatchSeqNum = batch_seq_num_in,
             Cardbin = card_bin_in,
             TerminalID = terminal_id_in,
             SETReqType = request_type_in,
             SubAuthInd = subseq_auth_ind_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

    ELSE
      -- More than one previous transaction, which is an
      -- error
       	raise_application_error(-20000, 'IBY_20414#', FALSE);
      --raise_application_error(-20414, 'Multiple matching authorization transactions');
    END IF;

    COMMIT;
  EXCEPTION

    WHEN OTHERS THEN
      err_msg := SUBSTR(SQLERRM, 1, 100);
       	raise_application_error(-20000, 'IBY_20410#', FALSE);
      --raise_application_error(-20410,'Error while inserting/updating authorization transaction: '||err_msg);

  END insert_set_txn;

  /* This procedure would be used every time a SET AUTH or AUTHREV     */
  /* transaction occurred.  Since AUTH and AUTHREV are idempotent, the */
  /* procedure checks to see if the row already exists based upon      */
  /* order_id, merchant_id, and split_id.                         */
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
	instrnum_in	IN  iby_trxn_summaries_all.instrnumber%type)
  IS
    num_trxns      NUMBER    := 0;
    oper_code      iby_trxn_core.OperationCode%TYPE;
    err_msg        VARCHAR2(100);
    trxn_mid       NUMBER;
    transaction_id NUMBER;
    l_tmid iby_trxn_summaries_all.mtangibleid%type;
  	l_mpayeeid iby_payee.mpayeeid%type;
  	l_mbatchid iby_batches_all.mbatchid%type;
  BEGIN
    -- NULL optional parameters if they are empty string
    IF (batch_id_in = '')
    THEN
      batch_id_in := null;
    END IF;
    IF (batch_seq_num_in = '')
    THEN
      batch_seq_num_in := null;
    END IF;
    IF (card_BIN_in = '')
    THEN
      card_BIN_in := null;
    END IF;
    IF (terminal_id_in = '')
    THEN
      terminal_id_in := null;
    END IF;
    IF (error_location_in = '')
    THEN
      error_location_in := null;
    END IF;
    IF (vendor_code_in = '')
    THEN
      vendor_code_in := null;
    END IF;
    -- Set operation_code
    IF ((capcode_in = '') OR (capcode_in IS NULL))
    THEN
      -- Since there is no capcode, trxn must be an AUTHONLY
      oper_code := authcode_in;
    ELSIF ((authcode_in = '') OR (authcode_in IS NULL))
    THEN
      -- There is capcode but no authcode, trxn is an
      -- AUTHCAPTURE
      oper_code := capcode_in;
    ELSE
      -- Both authcode and capcode exists, trxn is an
      -- AUTHCAPTURE, so operation code must be CAPCODE-AUTHCODE
      oper_code := capcode_in||'-'||authcode_in;
    END IF;
    -- Check value of subseq_auth_ind
    IF ((subseq_auth_ind_in <> 0) AND
        (subseq_auth_ind_in <> 1))
    THEN
       	raise_application_error(-20000, 'IBY_20421#', FALSE);
      --raise_application_error(-20421,'Invalid subsequent authorization indicator: '|| subseq_auth_ind_in);
    END IF;
    -- Check for idempotency:  see if transaction already
    -- exists
    SELECT count(*)
      INTO num_trxns
      FROM iby_trxn_summaries_all
     WHERE TangibleID = order_id_in
       AND UPPER(ReqType) = UPPER(req_type_in)
       AND PayeeID = merchant_id_in;
    IF (num_trxns = 0)
    THEN
      -- No previous transaction, so insert new row
     -- generate trxn_id and transaction_id
      SELECT iby_trxnsumm_mid_s.NEXTVAL
        INTO trxn_mid
        FROM dual;
      IF ((transaction_id_in_out = '') OR
         (transaction_id_in_out IS NULL))
      THEN
         SELECT iby_trxnsumm_trxnid_s.NEXTVAL
           INTO transaction_id
           FROM dual;
         transaction_id_in_out := transaction_id;
      ELSE
         transaction_id := transaction_id_in_out;
      END IF;

	iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);
	iby_transactioncc_pkg.getMBatchID(batch_id_in, merchant_id_in,
						l_mbatchid);
     /*
      ** Create an entry in iby_tangible table
      */
      iby_bill_pkg.createBill(order_id_in,price_in,currency_in,
                   billeracct_in,refinfo_in, memo_in,
                   order_medium_in, eft_auth_method_in,
                   l_tmid);

      INSERT INTO iby_trxn_summaries_all
        (TrxnMID, TangibleID,MPayeeID, PayeeID,BEPID, PaymentMethodName,
         TransactionID,TrxntypeID, ECAPPID, org_id,
	ReqType, ReqDate, MtangibleId,
         Amount,CurrencyNameCode,
         UpdateDate,Status,MBatchID, BatchID,
         BEPCode, BEPMessage,Errorlocation,
	payerinstrid, instrnumber,
	last_update_date, last_updated_by,
	creation_date, created_by,
	last_update_login, object_version_number,needsupdt)
      VALUES (trxn_mid, order_id_in, l_mpayeeid, merchant_id_in, vendor_id_in,
		payment_method_in,
              transaction_id, trxn_type_in, ecapp_id_in, org_id_in,
		req_type_in, time_in, l_tmid,
              price_in, currency_in, time_in, status_in, l_mbatchid,
		batch_id_in,
              vendor_code_in, vendor_message_in, error_location_in,
	payerinstrid_in, instrnum_in,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1,'Y');

      INSERT INTO iby_trxn_core
        (TrxnMID, OperationCode, AVSCode, ReferenceCode,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number)
      VALUES (trxn_mid, oper_code, avs_result_in, ret_ref_num_in,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);

      INSERT INTO iby_trxn_extended
        (TrxnMID, SplitID, CompletionCode, SETTrxnID,
         BatchSeqNum,
         Cardbin, TerminalID, SubAuthInd,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number)
      VALUES
        (trxn_mid, split_id_in, completion_code_in, set_trxn_id_in,
         batch_seq_num_in,
         card_bin_in, terminal_id_in, subseq_auth_ind_in,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);

    ELSIF (num_trxns = 1)
    THEN
      -- One previous transaction, so update previous row
       SELECT TrxnMID, TransactionID,MtangibleId
         INTO trxn_mid, transaction_id_in_out, l_tmid
         FROM iby_trxn_summaries_all
        WHERE TangibleID = order_id_in
          AND UPPER(ReqType) = UPPER(req_type_in)
          AND PayeeID = merchant_id_in;

	iby_transactioncc_pkg.getMBatchID(batch_id_in, merchant_id_in,
					l_mbatchid);

     --Update iby_tangible table
     iby_bill_pkg.modBill(l_tmid,order_id_in,price_in,currency_in,
                           billeracct_in,refinfo_in,memo_in,
                           order_medium_in, eft_auth_method_in);


      UPDATE iby_trxn_summaries_all
         SET Amount = price_in,
             CurrencyNameCode = currency_in,
             UpdateDate = time_in,
             Status = status_in,
             ErrorLocation = error_location_in,
             BEPCode = vendor_code_in,
             BEPMessage = vendor_message_in,
             BatchID = batch_id_in,
		MBatchID = l_mbatchid,
		payerinstrid = payerinstrid_in,
		instrnumber = instrnum_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

      UPDATE iby_trxn_core
         SET OperationCode = oper_code,
             AvsCode = avs_result_in,
             ReferenceCode = ret_ref_num_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

      UPDATE iby_trxn_extended
         SET SplitID = split_id_in,
             CompletionCode = completion_code_in,
             SETTrxnID = set_trxn_id_in,
             BatchSeqNum = batch_seq_num_in,
             Cardbin = card_bin_in,
             TerminalID = terminal_id_in,
             SubAuthInd = subseq_auth_ind_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

    ELSE
      -- More than one previous transaction, which is an
      -- error
       	raise_application_error(-20000, 'IBY_20422#', FALSE);
      --raise_application_error(-20422, 'Multiple matching subsequent auth transactions');
    END IF;
    COMMIT;
  EXCEPTION

    WHEN OTHERS THEN
      err_msg := SUBSTR(SQLERRM, 1, 100);
       	raise_application_error(-20000, 'IBY_20420#', FALSE);
      --raise_application_error(-20420,'Error while inserting/updating subsequent auth transaction: '||err_msg);
  END insert_auth_txn;


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
	instrnum_in	IN  iby_trxn_summaries_all.instrnumber%type)
  IS
    num_trxns      NUMBER         := 0;
    counter        NUMBER         := 0;
    err_msg        VARCHAR2(100);
    trxn_mid       NUMBER;
    transaction_id NUMBER;
  	l_tmid iby_trxn_summaries_all.mtangibleid%type;
	l_order_id iby_trxn_summaries_all.tangibleid%type;
  l_mpayeeid iby_payee.mpayeeid%type;
  l_mbatchid iby_batches_all.mbatchid%type;
  BEGIN
    -- NULL optional parameters if they are empty string
    IF (batch_id_in = '')
    THEN
      batch_id_in := null;
    END IF;
    IF (batch_seq_num_in = '')
    THEN
      batch_seq_num_in := null;
    END IF;
    IF (terminal_id_in = '')
    THEN
      terminal_id_in := null;
    END IF;
    IF (error_location_in = '')
    THEN
      error_location_in := null;
    END IF;
    IF (vendor_code_in = '')
    THEN
      vendor_code_in := null;
    END IF;
    -- Check for idempotency:  see if transaction already
    -- exists
    SELECT count(*)
      INTO num_trxns
      FROM iby_trxn_summaries_all summary, iby_trxn_extended extended
     WHERE summary.TangibleID = order_id_in
       AND summary.PayeeID = merchant_id_in
       AND extended.SplitID = split_id_in
       AND UPPER(summary.ReqType) = UPPER(req_type_in)
       AND summary.TrxnMID = extended.TrxnMID;
    IF (num_trxns = 0)
    THEN
      -- No previous transaction, so insert new row
      -- generate trxn_id and transaction_id
      SELECT iby_trxnsumm_mid_s.NEXTVAL
        INTO trxn_mid
        FROM dual;
      IF ((transaction_id_in_out = '') OR
         (transaction_id_in_out IS NULL))
      THEN

        SELECT count(*)
           INTO counter
           FROM iby_trxn_summaries_all
          WHERE TangibleID = order_id_in
            AND PayeeID = merchant_id_in;

         IF (counter = 0)
         THEN

           SELECT iby_trxnsumm_trxnid_s.NEXTVAL
             INTO transaction_id
             FROM dual;

         ELSE
           SELECT DISTINCT TransactionId
             INTO transaction_id
             FROM iby_trxn_summaries_all
            WHERE TangibleID = order_id_in
              AND PayeeID = merchant_id_in;

         END IF;

         transaction_id_in_out := transaction_id;
	-- I suppose we need a new transactionid only for ORAPMTCREDIT
       	--Create an entry in iby_tangible table
	 iby_bill_pkg.createBill(order_id_in,price_in,currency_in,
                   billeracct_in,refinfo_in, memo_in,
                   order_medium_in, eft_auth_method_in,
                   l_tmid);
	l_order_id := order_id_in;
      ELSE
	--tangible info should already exist, get them based on
	--transactionid
	SELECT DISTINCT mtangibleid, tangibleid
	INTO l_tmid, l_order_id
	FROM iby_trxn_summaries_all
	WHERE transactionid = transaction_id_in_out;

        transaction_id := transaction_id_in_out;
      END IF;

	iby_transactioncc_pkg.getMBatchID(batch_id_in, merchant_id_in,
				l_mbatchid);
	iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);



      INSERT INTO iby_trxn_summaries_all
        (TrxnMID, TangibleID,MPayeeID, PayeeID,BEPID,
         TransactionID,TrxntypeID, ECAPPID, org_id, ReqType, ReqDate,
	MtangibleId,
         Amount,CurrencyNameCode, UpdateDate,Status,MBatchID, BatchID,
         BEPCode, BEPMessage,Errorlocation,PaymentMethodName,

	payerinstrid, instrnumber,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number,needsupdt)
       VALUES (trxn_mid, l_order_id, l_mpayeeid, merchant_id_in, vendor_id_in,
              transaction_id, trxn_type_in, ecapp_id_in, org_id_in,
		req_type_in, time_in, l_tmid,
              price_in, currency_in, time_in, status_in,
		l_mbatchid, batch_id_in,
              vendor_code_in, vendor_message_in, error_location_in,
	      payment_name_in,
	payerinstrid_in, instrnum_in,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1,'Y');

      INSERT INTO iby_trxn_core
        (TrxnMID, OperationCode,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number)

      VALUES (trxn_mid, operation_code_in,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);


      INSERT INTO iby_trxn_extended
        (TrxnMID, SplitID, SETTrxnID,
         BatchSeqNum,
         TerminalID, SubAuthInd,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number)
      VALUES
        (trxn_mid, split_id_in, set_trxn_id_in,
         batch_seq_num_in,
         terminal_id_in, subseq_auth_ind_in,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);


    ELSIF (num_trxns = 1)
    THEN
      -- One previous transaction, so update previous row
       SELECT summary.TrxnMID, summary.TransactionID,MtangibleId
         INTO trxn_mid, transaction_id_in_out,l_tmid
          FROM iby_trxn_summaries_all summary, iby_trxn_extended extended
         WHERE summary.TangibleID = order_id_in
           AND summary.PayeeID = merchant_id_in
           AND extended.SplitID = split_id_in
           AND UPPER(summary.ReqType) = UPPER(req_type_in)
           AND summary.TrxnMID = extended.TrxnMID;

      iby_transactioncc_pkg.getMBatchID(batch_id_in, merchant_id_in,
					l_mbatchid);

	IF (UPPER(req_type_in) = 'ORAPMTCREDIT') THEN
	      -- Update iby_tangible table
	      iby_bill_pkg.modBill(l_tmid,order_id_in,price_in,currency_in,
                           billeracct_in,refinfo_in,memo_in,
                           order_medium_in, eft_auth_method_in);
	END IF;

      UPDATE iby_trxn_summaries_all
         SET Amount = price_in,
             CurrencyNameCode = currency_in,
             UpdateDate = time_in,
             Status = status_in,
             ErrorLocation = error_location_in,
             BEPCode = vendor_code_in,
             BEPMessage = vendor_message_in,
             BatchID = batch_id_in,
		MBatchID = l_mbatchid,
		payerinstrid = payerinstrid_in,
		instrnumber = instrnum_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

      UPDATE iby_trxn_core
         SET OperationCode = operation_code_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

      UPDATE iby_trxn_extended
         SET SplitID = split_id_in,
             SETTrxnID = set_trxn_id_in,
             BatchSeqNum = batch_seq_num_in,
             TerminalID = terminal_id_in,
             SubAuthInd = subseq_auth_ind_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

    ELSE
      -- More than one previous transaction, which is an
      -- error
       	raise_application_error(-20000, 'IBY_20431#', FALSE);
      --raise_application_error(-20431, 'Multiple matching transactions of this transaction type: '||trxn_type_in);
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      err_msg := SUBSTR(SQLERRM, 1, 100);
       	raise_application_error(-20000, 'IBY_20430#', FALSE);
      --raise_application_error(-20430,'Error while inserting/updating transaction: '||err_msg);
  END insert_other_txn;


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
         currency_in         IN	    iby_tangible.currencynamecode%type,
         amount_in           IN     iby_transactions_v.amount%TYPE,
         billeracct_in       IN     iby_tangible.acctno%type,
         refinfo_in          IN     iby_tangible.refinfo%type,
         memo_in             IN     iby_tangible.memo%type,
         order_medium_in     IN     iby_tangible.order_medium%TYPE,
         eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	org_id_in 	IN 	iby_trxn_summaries_all.org_id%TYPE,
	payerinstrid_in	IN	iby_trxn_summaries_all.payerinstrid%type,
	instrnum_in	IN  iby_trxn_summaries_all.instrnumber%type)
  IS
    num_trxns      NUMBER          := 0;
    err_msg        VARCHAR2(100);
    trxn_mid       NUMBER;
    transaction_id NUMBER;
    l_tmid iby_trxn_summaries_all.mtangibleid%type;
    l_order_id iby_trxn_summaries_all.tangibleid%type;
	l_mpayeeid iby_payee.mpayeeid%type;
 BEGIN
    -- Count number of previous transactions
    SELECT count(*)
      INTO num_trxns
      FROM iby_trxn_summaries_all
     WHERE TangibleID = order_id_in
       AND UPPER(ReqType) = UPPER(req_type_in)
       AND PayeeID = merchant_id_in;
    IF (num_trxns = 0)
    THEN
    -- Insert transaction row
     -- generate trxn_id and transaction_id
      SELECT iby_trxnsumm_mid_s.NEXTVAL
        INTO trxn_mid
        FROM dual;
     SELECT iby_trxnsumm_trxnid_s.NEXTVAL
       INTO transaction_id
       FROM dual;
      transaction_id_in_out := transaction_id;



	iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);

	IF (UPPER(req_type_in) = 'ORAPMTREQ' or
	    UPPER(req_type_in) = 'ORAPMTCREDIT') THEN
	      -- Create an entry in iby_tangible table
	      iby_bill_pkg.createBill(order_id_in,amount_in,currency_in,
        	           billeracct_in,refinfo_in, memo_in,
                           order_medium_in, eft_auth_method_in,
                           l_tmid);
		l_order_id := order_id_in;
	ELSE
		SELECT DISTINCT mtangibleid, tangibleid
		INTO l_tmid, l_order_id
		FROM iby_trxn_summaries_all
		WHERE transactionid = transaction_id_in_out;

	        transaction_id := transaction_id_in_out;
	END IF;

      INSERT INTO iby_trxn_summaries_all
        (TrxnMID,  TransactionID, ECAPPID, org_id,
         TangibleID, MPayeeID, PayeeID, BEPID, PaymentMethodName,
         TrxntypeID, ReqType, ReqDate, MtangibleId,
         UpdateDate,Status,

	payerinstrid, instrnumber,
	last_update_date, last_updated_by,
	creation_date, created_by,
	last_update_login, object_version_number,needsupdt)

      VALUES (trxn_mid, transaction_id, ecapp_id_in, org_id_in,
              l_order_id, l_mpayeeid, merchant_id_in, vendor_id_in,
		payment_name_in,
               trxn_type_in, req_type_in, time_in, l_tmid,
               time_in, status_in,
		payerinstrid_in, instrnum_in,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1,'Y');

      INSERT INTO iby_trxn_extended
        (TrxnMID, SplitID,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number)
      VALUES (trxn_mid, '1',
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);

     INSERT INTO iby_trxn_core
        (TrxnMID, InstrName,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number)
      VALUES (trxn_mid, payment_name_in,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);

    ELSIF (num_trxns = 1)
    THEN
      -- One previous transaction, so update previous row
       SELECT TrxnMID, MtangibleId
         INTO trxn_mid, l_tmid
         FROM iby_trxn_summaries_all
        WHERE TangibleID = order_id_in
          AND UPPER(ReqType) = UPPER(req_type_in)
          AND PayeeID = merchant_id_in;

	IF (UPPER(req_type_in) = 'ORAPMTREQ' or
		UPPER(req_type_in) = 'ORAPMTCREDIT') THEN
		-- Update iby_tangible table
	      iby_bill_pkg.modBill(l_tmid,order_id_in,amount_in,currency_in,
                           billeracct_in,refinfo_in,memo_in,
                           order_medium_in, eft_auth_method_in);
	END IF;


      UPDATE iby_trxn_summaries_all
         SET
		UpdateDate = time_in,
		--ReqDate = time_in,
             Status = status_in,

		payerinstrid = payerinstrid_in,
		instrnumber = instrnum_in,

	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

      UPDATE iby_trxn_extended
         SET SplitID = '1',
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;
    ELSE
       	raise_application_error(-20000, 'IBY_20401#', FALSE);
      --raise_application_error(-20401,'Duplicate transactions for this order_id');
    END IF;

    commit;
  EXCEPTION
    WHEN OTHERS THEN
      err_msg := SUBSTR(SQLERRM, 1, 100);
       	raise_application_error(-20000, 'IBY_20440#', FALSE);
      --raise_application_error(-20440,'Error while inserting/updating timeout transaction: '||err_msg);

  END insert_timeout_txn;
  /* Inserts or updates a batch summary row into the PS_BATCH    */
  /* table.  This should happen for open or close batch operations.  */

  PROCEDURE insert_batch_status
    (batch_id_in           IN     iby_batches_all.BatchID%TYPE,
     merchant_id_in        IN     iby_batches_all.PayeeID%TYPE,
     bep_id_in             IN     iby_batches_all.BEPID%TYPE,
     /* vendor_suffix_in      IN     iby_batches_all.vendor_suffix%TYPE, */
     /* close_status_in       IN     iby_batches_all.BatchCloseStatus%TYPE, */
     currency_in           IN     iby_batches_all.CurrencyNameCode%TYPE,
     sale_price_in         IN     iby_batches_all.BatchSales%TYPE,
     credit_price_in       IN     iby_batches_all.BatchCredit%TYPE,
     trxn_count_in         IN     iby_batches_all.NumTrxns%TYPE,
     sale_trxn_count_in    IN     iby_batches_all.NumTrxns%TYPE,
     credit_trxn_count_in  IN     iby_batches_all.NumTrxns%TYPE,
     open_date_in          IN     iby_batches_all.BatchOpenDate%TYPE,
     close_date_in         IN     iby_batches_all.BatchCloseDate%TYPE,
     status_in             IN     iby_batches_all.BatchStatus%TYPE,
     vendor_code_in        IN     iby_batches_all.BEPCode%TYPE,
     vendor_message_in     IN     iby_batches_all.BEPMessage%TYPE,
     error_location_in     IN     iby_batches_all.ErrorLocation%TYPE,
	org_id_in 	IN 	iby_batches_all.org_id%TYPE,
	 req_type_in IN iby_batches_all.reqtype%type)
  IS
    num_trxns   NUMBER;
    err_msg     VARCHAR2(100);

	 l_mbatchid iby_batches_all.mbatchid%type;
	l_mpayeeid iby_payee.mpayeeid%type;
  BEGIN

   num_trxns := 0;
   -- Get number of existing batches that match
   SELECT count(*)
     INTO num_trxns
     FROM iby_batches_all
    WHERE BatchId = batch_id_in
      AND PayeeID = merchant_id_in;
   IF (num_trxns = 0)
   THEN
     -- Insert new batch status row

	iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);

       SELECT iby_batches_s.NEXTVAL
        INTO l_mbatchid
        FROM dual;
     --Bug:8363526
     --Inserting new column settledate VALUE:sysdate
     INSERT INTO iby_batches_all
       (MBatchID, BatchID, org_id, MPayeeID, PayeeID,  /* BatchCloseStatus,*/
        CURRENCYNameCode, BatchSales, BatchCredit, BatchTotal,
        NumTrxns, BatchOpenDate, BatchCloseDate, BatchStatus,
        BEPCode, BEPMessage, ErrorLocation, reqtype, reqdate,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number,settledate)
       VALUES
       (l_mbatchid, batch_id_in, org_id_in, l_mpayeeid,
	merchant_id_in, /*close_status_in, */
        currency_in, sale_price_in, credit_price_in, sale_price_in - credit_price_in,
        sale_trxn_count_in + credit_trxn_count_in,
        open_date_in, close_date_in, status_in,
        vendor_code_in, vendor_message_in, error_location_in,
	req_type_in, sysdate,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1,sysdate);

   ELSIF (num_trxns = 1)
   THEN
     -- Update batch status row
     UPDATE iby_batches_all
        SET /* BatchCloseStatus = close_status_in, */

		reqtype = req_type_in,
		reqdate = sysdate,
            CurrencyNameCode = currency_in,
            BatchSales = sale_price_in,
            BatchCredit = credit_price_in,
            BatchTotal = sale_price_in - credit_price_in,
            NumTrxns = sale_trxn_count_in + credit_trxn_count_in,
            BatchOpenDate = open_date_in,
            BatchCloseDate = close_date_in,
            BatchStatus = status_in,
            BEPCode = vendor_code_in,
            BEPMessage = vendor_message_in,
            ErrorLocation = error_location_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
      WHERE BatchID = batch_id_in
        AND PayeeID = merchant_id_in;

   ELSE
     -- More than 1 trxn matched, so give error
       	raise_application_error(-20000, 'IBY_20451#', FALSE);
     --raise_application_error(-20451,'Duplicate batch summaries match batch_id '||batch_id_in||' and merchant_id '||merchant_id_in);
   END IF;
   COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      err_msg := SUBSTR(SQLERRM, 1, 100);
       	raise_application_error(-20000, 'IBY_20450#', FALSE);
      --raise_application_error(-20450,'Error while inserting/updating batch summary: '||err_msg);
  END insert_batch_status;

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
	org_id_in 	IN 	iby_trxn_summaries_all.org_id%TYPE)

  IS
    num_trxns    NUMBER            := 0;
    err_msg      VARCHAR2(100);
    trxn_mid	 NUMBER;

	l_mpayeeid iby_payee.mpayeeid%type;
	l_mbatchid iby_batches_all.mbatchid%type;
  BEGIN
    -- Check for idempotency:  see if transaction already
    -- exists
    SELECT count(*)
      INTO num_trxns
      FROM iby_trxn_extended extended, iby_trxn_summaries_all summary
     WHERE extended.SETTrxnID = set_trxn_id_in
       AND summary.BEPID = vendor_id_in
       AND extended.TrxnMID = summary.TrxnMID;
    IF (num_trxns = 0)
    THEN
     -- generate trxn_id and transaction_id
      SELECT iby_trxnsumm_mid_s.NEXTVAL
        INTO trxn_mid
        FROM dual;
     -- SELECT iby_trxnsumm_trxnid_s.NEXTVAL
     --   INTO transaction_id
     --   FROM dual;
     -- transaction_id_in_out := transaction_id;
      -- No previous transaction, so get parent split_id
      find_parent_splitid(order_id_in, merchant_id_in,
                          vendor_id_in, trxn_type_in,
                          prev_set_trxn_id_in, split_id_in_out);
      -- Temporarily hardcoding since find_parent_splitid
      -- isn't working!  Need TO FIX!
      IF (split_id_in_out IS NULL)
      THEN
       	raise_application_error(-20000, 'IBY_20461#', FALSE);
        --raise_application_error(-20461,'Parent split_id of trxn in batch could not be found');
        -- split_id_in_out := '1';
      END IF;
      -- Insert new row
     -- generate TransactionID

	iby_transactioncc_pkg.getMBatchID(batch_id_in, merchant_id_in,
					l_mbatchid);
	iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);
      INSERT INTO iby_trxn_summaries_all
        (TrxnMID, TangibleID,MPayeeID, PayeeID,BEPID,
         TrxntypeID, ECAPPID,  org_id,
         Amount,CurrencyNameCode, UpdateDate,Status,MBatchID, BatchID,
         BEPCode, BEPMessage,Errorlocation,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number,needsupdt)
       VALUES (trxn_mid, order_id_in, l_mpayeeid, merchant_id_in, vendor_id_in,
              trxn_type_in, ecapp_id_in,org_id_in,
              price_in, currency_in, time_in, status_in,
		l_mbatchid, batch_id_in,
              vendor_code_in, vendor_message_in, error_location_in,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1,'Y');

      INSERT INTO iby_trxn_extended
        (TrxnMID, SplitID, SETTrxnID,
         BatchSeqNum, BatchTrxnStatus,
         Cardbin, TerminalID,
	last_update_date, last_updated_by, creation_date,
	created_by, last_update_login, object_version_number)
      VALUES
        (trxn_mid, '1',  set_trxn_id_in,
         batch_seq_num_in, batch_trxn_status_in,
         card_bin_in, terminal_id_in,
	 sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1);

    ELSIF (num_trxns = 1)
    THEN
      -- Update current row
       SELECT summary.TrxnMID
         INTO trxn_mid
         FROM iby_trxn_extended extended, iby_trxn_summaries_all summary
        WHERE extended.SETTrxnID = set_trxn_id_in
          AND summary.BEPID = vendor_id_in
          AND extended.TrxnMID = summary.TrxnMID;

      UPDATE iby_trxn_extended
         SET BatchSeqNum = batch_seq_num_in,
             BatchTrxnStatus = batch_trxn_status_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
       WHERE TrxnMID = trxn_mid;

      -- Get split_id for output
      SELECT extended.SplitID
        INTO split_id_in_out
        FROM iby_trxn_extended extended, iby_trxn_summaries_all summary
       WHERE extended.SETTrxnID = set_trxn_id_in
         AND summary.BEPID = vendor_id_in
         AND extended.TrxnMID = summary.TrxnMID;
      -- Update card BIN only if it's not null
      IF ((card_BIN_in <> '') AND
          (card_BIN_in IS NOT NULL))
      THEN
         SELECT summary.TrxnMID
           INTO trxn_mid
           FROM iby_trxn_extended extended, iby_trxn_summaries_all summary
          WHERE extended.SETTrxnID = set_trxn_id_in
            AND summary.BEPID = vendor_id_in
            AND extended.TrxnMID = summary.TrxnMID;

        UPDATE iby_trxn_extended
           SET Cardbin = card_BIN_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
         WHERE TrxnMID = trxn_mid;
      END IF;
      -- Update terminal id only if it's not null
      IF ((terminal_id_in <> '') AND
          (terminal_id_in IS NOT NULL))
      THEN
         SELECT summary.TrxnMID
           INTO trxn_mid
           FROM iby_trxn_extended extended, iby_trxn_summaries_all summary
          WHERE extended.SETTrxnID = set_trxn_id_in
            AND summary.BEPID = vendor_id_in
            AND extended.TrxnMID = summary.TrxnMID;
        UPDATE iby_trxn_extended
           SET TerminalID = terminal_id_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
         WHERE TrxnMID = trxn_mid;
      END IF;
      -- Update error location only if it's not null
      IF ((error_location_in <> '') AND
          (error_location_in IS NOT NULL))
      THEN
         SELECT summary.TrxnMID
           INTO trxn_mid
           FROM iby_trxn_extended extended, iby_trxn_summaries_all summary
          WHERE extended.SETTrxnID = set_trxn_id_in
            AND summary.BEPID = vendor_id_in
            AND extended.TrxnMID = summary.TrxnMID;
         UPDATE iby_trxn_summaries_all
           SET ErrorLocation = error_location_in,
	    last_update_date = sysdate,
     updatedate = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
         WHERE TrxnMID = trxn_mid;
      END IF;
      -- Update vendor code only if it's not null
      IF ((vendor_code_in <> '') AND
          (vendor_code_in IS NOT NULL))
      THEN
         SELECT summary.TrxnMID
           INTO trxn_mid
           FROM iby_trxn_extended extended, iby_trxn_summaries_all summary
          WHERE extended.SETTrxnID = set_trxn_id_in
            AND summary.BEPID = vendor_id_in
            AND extended.TrxnMID = summary.TrxnMID;
        UPDATE iby_trxn_summaries_all
           SET BEPCode = vendor_code_in,
	    last_update_date = sysdate,
     updatedate = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
         WHERE TrxnMID = trxn_mid;
      END IF;
      -- Update vendor message only if it's not null
      IF ((vendor_message_in <> '') AND
          (vendor_message_in IS NOT NULL))
      THEN
         SELECT summary.TrxnMID
           INTO trxn_mid
           FROM iby_trxn_extended extended, iby_trxn_summaries_all summary
          WHERE extended.SETTrxnID = set_trxn_id_in
            AND summary.BEPID = vendor_id_in
            AND extended.TrxnMID = summary.TrxnMID;
        UPDATE iby_trxn_summaries_all
           SET BEPMessage = vendor_message_in,
	    last_update_date = sysdate,
     updatedate = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
         WHERE TrxnMID = trxn_mid;
      END IF;

    ELSE
      -- Error since too many matching rows
       	raise_application_error(-20000, 'IBY_20201#', FALSE);
      --raise_application_error(-20201,'Duplicate rows in transactions_set table to update for batch information');
    END IF;
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      err_msg := SUBSTR(SQLERRM, 1, 100);
       	raise_application_error(-20000, 'IBY_20460#', FALSE);
      --raise_application_error(-20460,'Error while inserting/updating batch item: '||err_msg);

  END insert_batch_txn;


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
	req_type_in IN iby_trxn_summaries_all.reqtype%type)
  IS
    num_trxns      NUMBER             := 0;
    mid          iby_trxn_extended.SplitID%TYPE;
    err_msg        VARCHAR2(100);
    trxn_mid     NUMBER;

	l_mpayeeid iby_payee.mpayeeid%type;
  BEGIN
    -- NULL optional parameters
    IF (card_BIN_in = '')
    THEN
      card_BIN_in := null;
    END IF;
    IF (terminal_id_in = '')
    THEN
      terminal_id_in := null;
    END IF;
    IF (error_location_in = '')
    THEN
       error_location_in := null;
    END IF;
    IF (vendor_code_in = '')
    THEN
      vendor_code_in := null;
    END IF;
    IF (vendor_message_in = '')
    THEN
      vendor_message_in := null;
    END IF;
   -- Check if row is already in table using unique
   -- key of set_trxn_id and vendor_id
    SELECT COUNT(*)
      INTO num_trxns
      FROM iby_trxn_extended extended, iby_trxn_summaries_all summary
     WHERE extended.SETTrxnID = set_trxn_id_in
       AND summary.BEPID = vendor_id_in
       AND extended.TrxnMID = summary.TrxnMID;
    IF (num_trxns = 0)
    THEN
      -- No previous transaction, so get
      -- split_id from parent, if
      -- it's there
      find_parent_splitid(order_id_in, merchant_id_in,
                          vendor_id_in, trxn_type_in,
                          prev_set_trxn_id_in, split_id_in_out);
     -- generate trxn_id and transaction_id
      SELECT iby_trxnsumm_mid_s.NEXTVAL
        INTO trxn_mid
        FROM dual;
      --SELECT iby_trxnsumm_trxnid_s.NEXTVAL
      --  INTO transaction_id
      --  FROM dual;
      --transaction_id_in_out := transaction_id;


	iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);
      INSERT INTO iby_trxn_summaries_all
        (TrxnMID, TransactionID, paymentMethodName,
         TangibleID,MPayeeID, PayeeID,BEPID,
         TrxntypeID, ECAPPID, org_id, ReqDate, ReqType,
         Amount,CurrencyNameCode, UpdateDate,Status,
         BEPCode, BEPMessage,Errorlocation,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number,needsupdt)
       VALUES (trxn_mid, transaction_id_in, payment_method_in,
              order_id_in, l_mpayeeid, merchant_id_in, vendor_id_in,
              trxn_type_in, ecapp_id_in, org_id_in, time_in,req_type_in,
              price_in, currency_in, time_in, status_in,
              vendor_code_in, vendor_message_in, error_location_in,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1,'Y');

      INSERT INTO iby_trxn_core
        (TrxnMID, ReferenceCode,
	last_update_date, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number)
      VALUES (trxn_mid, ret_ref_num_in,
	 sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1);

      INSERT INTO iby_trxn_extended
        (TrxnMID, SplitID,  SETTrxnID,
         -- BatchSeqNum,
         Cardbin, TerminalID,
	last_update_date, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number)
      VALUES
        (trxn_mid,split_id_in_out,  set_trxn_id_in,
         -- batch_seq_num_in,
         card_bin_in, terminal_id_in,
	 sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1);
    ELSIF (num_trxns = 1)
    THEN
      -- Count number of successful transactions
      SELECT count(*)
       INTO num_trxns
      FROM iby_trxn_summaries_all summary, iby_trxn_extended extended
      WHERE extended.SETTrxnID = set_trxn_id_in
        AND summary.BEPID = vendor_id_in
        AND summary.Status = 0
        AND summary.TrxnMID = extended.TrxnMID;
      -- If transaction was successful, do nothing,
      -- else update the row if it was not successful.
      IF (num_trxns = 0)
      THEN
        SELECT summary.TrxnMID
          INTO trxn_mid
          FROM iby_trxn_summaries_all summary, iby_trxn_extended extended
         WHERE extended.SETTrxnID = set_trxn_id_in
           AND summary.BEPID = vendor_id_in
           AND summary.TrxnMID = extended.TrxnMID;
        UPDATE iby_trxn_summaries_all
           SET Amount = price_in,
               CurrencyNameCode = currency_in,
               UpdateDate = time_in,
               Status = status_in,
               ErrorLocation = error_location_in,
               BEPCode = vendor_code_in,
               BEPMessage = vendor_message_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
         WHERE TrxnMID = trxn_mid;

        UPDATE iby_trxn_core
           SET ReferenceCode = ret_ref_num_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
         WHERE TrxnMID = trxn_mid;

        UPDATE iby_trxn_extended
           SET Cardbin = card_bin_in,
               TerminalID = terminal_id_in,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
         WHERE TrxnMID = trxn_mid;
      END IF;
    END IF;

    commit;
  EXCEPTION
    WHEN OTHERS THEN
      err_msg := SUBSTR(SQLERRM, 1, 100);
       	raise_application_error(-20000, 'IBY_20470#', FALSE);
      --raise_application_error(-20470,'Error while inserting/updating queried order: '||err_msg);
  END insert_query_txn;


  /* Internal procedure to get the split_id of the parent  */
  /* transaction. */
  PROCEDURE find_parent_splitid
        (order_id_in         IN     iby_trxn_summaries_all.TangibleID%TYPE,
         merchant_id_in      IN     iby_trxn_summaries_all.PayeeID%TYPE,
         vendor_id_in        IN     iby_trxn_summaries_all.BEPID%TYPE,
         trxn_type_in        IN     iby_trxn_summaries_all.TrxntypeID%TYPE,
         prev_set_trxn_id_in IN     iby_trxn_extended.SETTrxnID%TYPE,
         split_id_in_out     IN OUT NOCOPY iby_trxn_extended.SplitID%TYPE)
  IS

    num_trxns      NUMBER             := 0;
    mid            iby_trxn_extended.SplitID%TYPE;
    err_msg        VARCHAR2(100);

  BEGIN
    split_id_in_out := null;
    -- Find number of parents
    SELECT count(distinct extended.SplitID)
      INTO num_trxns
      FROM iby_trxn_extended extended, iby_trxn_summaries_all summary
      WHERE extended.SETTrxnID = prev_set_trxn_id_in
        AND summary.BEPID = vendor_id_in
        AND extended.TrxnMID = summary.TrxnMID;
    IF (num_trxns = 0)
    THEN
      -- No parent found.  Hard-code value to 1 (default value)
      split_id_in_out := '1';
    ELSIF (num_trxns = 1)
    THEN
      -- Even tho value is probably 1 (default), we'll make
      -- sure by getting it anyways
      SELECT distinct extended.SplitID
        INTO mid
        FROM iby_trxn_extended extended, iby_trxn_summaries_all summary
       WHERE extended.SETTrxnID = prev_set_trxn_id_in
         AND summary.BEPID = vendor_id_in
         AND extended.TrxnMID = summary.TrxnMID;
        split_id_in_out := mid;
    ELSE
      -- This shouldn't happen, so raise an error
       	raise_application_error(-20000, 'IBY_20481#', FALSE);
      --raise_application_error(-20481,'More than one split_id for the parent transaction with SET_ID: '||prev_set_trxn_id_in);
    END IF;
  EXCEPTION

    WHEN OTHERS THEN
      err_msg := SUBSTR(SQLERRM, 1, 100);
       	raise_application_error(-20000, 'IBY_20480#', FALSE);
      --raise_application_error(-20480,'Error while finding the split_id of the parent transaction: '||err_msg);
  END find_parent_splitid;


END iby_transactionSET_pkg;


/
