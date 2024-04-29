--------------------------------------------------------
--  DDL for Package Body IBY_QUERYCC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_QUERYCC_PKG" as
/*$Header: ibyqrccb.pls 115.35 2003/04/29 18:30:58 jleybovi ship $*/

PROCEDURE listvpsid (merchant_id_in   IN  VARCHAR2,
		     batch_id_in      IN  VARCHAR2,
                     vendor_id_in     IN  NUMBER,
                     vendor_key_in    IN  VARCHAR2,
		     viby_id	      OUT NOCOPY VARCHAR2)

IS

  loc_vpsid   iby_batches_all.VPSBatchID%TYPE;
BEGIN

	loc_vpsid := NULL;

	SELECT distinct VPSBatchID
	INTO loc_vpsid
	FROM iby_batches_all
	WHERE payeeid = merchant_id_in AND
	      BatchID = batch_id_in AND
	      bepid = vendor_id_in AND
	      bepkey = vendor_key_in;

	viby_id := loc_vpsid;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF loc_vpsid IS NULL
	THEN
	       	raise_application_error(-20000, 'IBY_20209#', FALSE);
	  --raise_application_error(-20209,'No VPSBatchID for MerchBatchID');
	END IF;

END listvpsid;


 PROCEDURE checkunqorder
        (order_id_in       IN    VARCHAR2,
         merchant_id_in    IN    VARCHAR2,
         payment_operation IN    VARCHAR2,
         trxn_type_in      IN    NUMBER,
         check_status_out  OUT NOCOPY NUMBER,
         parent_trace_number_out OUT NOCOPY VARCHAR2,
	 bepid_out OUT NOCOPY NUMBER,
         bepkey_out OUT NOCOPY VARCHAR2,
         trxnid_out OUT NOCOPY NUMBER,
         trxnref_out OUT NOCOPY VARCHAR2
        )

  IS

   loc_status iby_transactions_v.status%TYPE;

	CURSOR s1(i_reqtype1 iby_trxn_summaries_all.reqtype%type,
		i_reqtype2 iby_trxn_summaries_all.reqtype%type DEFAULT
		NULL)
	IS
	   SELECT status, bepid, bepkey, transactionid, trxnref
	   FROM iby_trxn_summaries_all
	   WHERE tangibleid = order_id_in
	   	AND payeeid = merchant_id_in
		AND reqtype IN (i_reqtype1, i_reqtype2)
		AND reqtype IS NOT NULL -- to ignore the 2nd arg
		ORDER BY reqdate DESC;
		-- first one is always the latest

      CURSOR s2(tx1 NUMBER,
             tx2 NUMBER DEFAULT NULL) IS
           SELECT tracenumber
           FROM iby_transactions_v
           WHERE order_Id = order_id_in
           AND merchant_id = merchant_id_in
           AND trxn_type IN (tx1, tx2)
           ORDER BY time DESC;

   BEGIN

	-- Depending on the payment operation the trxn_type varies
	-- So we need to select based on this set
	-- For an explanation of various trxn_types refer the design doc

	IF (s1%ISOPEN) THEN
	  CLOSE s1;
	END IF;

	IF (s2%ISOPEN) THEN
	  CLOSE s2;
	END IF;

	IF (SUBSTR(payment_operation,1,4)='AUTH') OR (payment_operation='ORAPMTREQ') THEN
	  OPEN s1('ORAPMTREQ');
	ELSIF (payment_operation = 'CAPTURE') OR (payment_operation='ORAPMTCAPTURE') THEN
	  OPEN s1('ORAPMTCAPTURE');
	ELSIF (payment_operation = 'RETURN' OR
		payment_operation = 'CREDIT') OR (payment_operation='ORAPMTRETURN' OR payment_operation='ORAPMTCREDIT') THEN
	  OPEN s1('ORAPMTRETURN', 'ORAPMTCREDIT');
	ELSIF (payment_operation = 'VOID') OR (payment_operation='ORAPMTVOID') THEN
          -- can't use this as offline void
	  -- will put the trxntypeid to be void
	  OPEN s1('ORAPMTVOID');
	END IF;

	-- Fetch the first row to check the status
	FETCH s1 INTO loc_status, bepid_out, bepkey_out, trxnid_out, trxnref_out;

	IF s1%FOUND THEN
	 IF (loc_status = 0 OR -- previous successful ops, duplicate
		loc_status = 1 OR  -- communication error, retry
	 	 loc_status = 9999 OR 	-- timeout during ICX
		 loc_status = 2 OR	-- If duplicate already
                 loc_status = 9 OR   -- gateway transitional
		 loc_status = 14 OR  -- cancelled, gateway
		 loc_status = 100 OR -- in an open batch
--loc_status = 101 OR -- batch comm error ;
-- enable when we have more time for regression testing
		 loc_status = 114 OR -- cancelled in an open batch
		 loc_status = 111 OR -- in a pending batch
		 loc_status = 109 OR -- in the midst of a patch close
		 loc_status = 11) THEN	-- already scheduled offline
	    check_status_out := loc_status;
	 ELSE
	  check_status_out := -1;    -- For any other error resubmit operation
	 END IF;
        ELSE
          check_status_out := -1;	-- new order
          bepid_out := -1;
          bepkey_out := NULL;
	END IF;

	CLOSE s1;

	-- get parent trace number for Concord gateway
	IF payment_operation = 'CAPTURE' THEN
		OPEN s2(2);		-- authonly
	ELSIF payment_operation = 'RETURN' THEN
		OPEN s2(3, 8);		-- authcapture/capture
	ELSIF payment_operation = 'VOID' THEN
		OPEN s2(trxn_type_in);	-- trxn type to be void
	ELSE
		parent_trace_number_out := '';
		RETURN;
	END IF;

	-- Fetch the first row to check the status
	FETCH s2 INTO parent_trace_number_out;

	IF s2%NOTFOUND THEN
		parent_trace_number_out := NULL;
	END IF;

	CLOSE s2;

   END checkunqorder;



PROCEDURE checkunqbatch (batch_id_in    IN  VARCHAR2,
			merchant_id_in  IN  VARCHAR2,
			stat	   OUT NOCOPY NUMBER,
			viby_bid   OUT NOCOPY VARCHAR2)


AS

  loc_stat	iby_batches_all.BatchStatus%TYPE;
  loc_viby_bid	iby_batches_all.VPSBatchID%TYPE;

  CURSOR b1 IS
	SELECT BatchStatus, VPSBatchID
	FROM iby_batches_all
	WHERE BatchID = batch_id_in
	AND payeeid = merchant_id_in
	ORDER BY BatchCloseDate DESC;


BEGIN

   IF b1%ISOPEN THEN
	CLOSE b1;
   END IF;

   OPEN b1;
   FETCH b1 INTO loc_stat, loc_viby_bid;

   IF b1%FOUND THEN
     IF (loc_stat = 0 or loc_stat = 3 or loc_stat = 11) THEN
	-- Batch successful,
        -- Duplicate already marked.  Return Duplicate batch id
	-- already scheduled offline
	stat := loc_stat;
	CLOSE b1;
        return;
     ELSIF (loc_stat = 1 or loc_stat = 9999
		or loc_stat = 6 or loc_stat = 7) THEN
     	-- communication error.
	-- time out at Payment Server during ICX.
	-- batch partial succeed
	-- batch fail
        --pass the VPSBatchID to payment systems in oraclosebatch
	stat := loc_stat;
	viby_bid := loc_viby_bid;
	CLOSE b1;
        return;
     END IF;
   END IF;

   --  Batch not found
   CLOSE b1;
   stat := -1;

END checkunqbatch;



PROCEDURE getorderid (merchant_id_in    IN	VARCHAR2,
		      vendor_suffix	IN	VARCHAR2,
		      order_id_out	OUT NOCOPY VARCHAR2)

AS

  loc_order_id		iby_trxn_summaries_all.Tangibleid%TYPE;

  CURSOR o1 IS
   SELECT order_Id
   FROM iby_transactions_v trn, iby_bepinfo ven
   WHERE merchant_id = merchant_id_in
   AND UPPER(ven.suffix) = UPPER(vendor_suffix)
   AND ven.bepid = trn.vendor_id
   AND status = 0
   AND trxn_type IN (8, 9, 5, 10)  -- only looking at capture/return
   AND merchbatchid IS NULL

   ORDER BY time ASC;



BEGIN

   OPEN o1;

   -- Fetch the first row to get oldest order_id not settled
   FETCH o1 INTO loc_order_id;

   IF o1%FOUND THEN
    order_id_out := loc_order_id;
    CLOSE o1;
    return;
   END IF;

   CLOSE o1;
   order_id_out := -1;


END getorderid;

  PROCEDURE getTrxnInfo
  (
  trxnid_in	IN	iby_trxn_summaries_all.transactionid%TYPE,
  trxntypeid_in IN	iby_trxn_summaries_all.trxntypeid%TYPE,
  trxntypeid_aux_in IN	iby_trxn_summaries_all.trxntypeid%TYPE,
  status_in     IN      iby_trxn_summaries_all.status%TYPE,
  status_aux_in IN      iby_trxn_summaries_all.status%TYPE,
  amount_out	OUT NOCOPY iby_trxn_summaries_all.amount%TYPE,
  currency_out	OUT NOCOPY iby_trxn_summaries_all.currencynamecode%TYPE,
  status_out	OUT NOCOPY iby_trxn_summaries_all.status%TYPE
  )
  IS
  BEGIN
	SELECT amount, currencynamecode, status
	INTO amount_out,currency_out, status_out
	FROM iby_trxn_summaries_all
	WHERE (transactionid=trxnid_in) AND (trxntypeid IN (trxntypeid_in,trxntypeid_aux_in))
	  AND (status in (status_in,status_aux_in));
  EXCEPTION

	WHEN no_data_found THEN
	  raise_application_error(-20000, 'IBY_20534#ID='||trxnid_in||'#TYPE='||trxntypeid_in||'/'||trxntypeid_aux_in||'#STATUS='||status_in||'/'||status_aux_in, FALSE);

  END getTrxnInfo;

END iby_querycc_pkg;

/
