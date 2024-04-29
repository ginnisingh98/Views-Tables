--------------------------------------------------------
--  DDL for Package Body IBY_QUERYSET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_QUERYSET_PKG" as
/*$Header: ibyqsetb.pls 115.11 2002/11/19 23:50:17 jleybovi ship $*/

  /* This procedure gets the trxn info for this particular     */
  /* trxn.  Given a merchant_id, order_id, split_id,           */
  /* payment_operation, and vendor_id, it returns              */
  /* the status (if the operation occurred before -- useful for*/
  /* determining retries) and the set_trxn_id to indicate the  */
  /* parent SET trxn to the vendor.                            */

  PROCEDURE get_settrxninfo
        (merchant_id_in          IN     IBY_Payee.PayeeID%TYPE,
         order_id_in             IN     iby_trxn_summaries_all.TangibleID%TYPE,
         split_id_in             IN     iby_trxn_extended.SplitID%TYPE,
         payment_operation_in    IN     iby_trxn_summaries_all.PaymentMethodName%TYPE,
         vendor_id_in            IN     IBY_BEPInfo.BEPID%TYPE,
         status_out              OUT NOCOPY iby_trxn_summaries_all.Status%TYPE,
         prev_set_trxn_id_in_out IN OUT NOCOPY iby_trxn_extended.SETTrxnID%TYPE,
         price_out               OUT NOCOPY iby_trxn_summaries_all.Amount%TYPE,
         currency_out            OUT NOCOPY iby_trxn_summaries_all.CurrencyNameCode%TYPE,
         previous_price_out      OUT NOCOPY iby_trxn_summaries_all.Amount%TYPE,
         previous_currency_out   OUT NOCOPY iby_trxn_summaries_all.CurrencyNameCode%TYPE)
  IS
    in_trxn_type 	   NUMBER;
    num_trxns              NUMBER;
    num_succ_trxns         NUMBER;
    max_time               DATE;
  BEGIN
    -- NULL or make zero output parameters just in case
    status_out := NULL;
    price_out := NULL;
    currency_out := NULL;
    previous_price_out := NULL;
    previous_currency_out := NULL;
    in_trxn_type := NULL;
    -- If not a query operation, get status of current trxn, if it's
    -- already in database
    IF (UPPER(payment_operation_in) = 'ORASET_BATCHADMIN')
    THEN
      -- Trxn is a batch operation, so look into the batch
      -- table to get the status of the previous operation,
      -- if any, to help set the RETRY flag
      SELECT count(*)
        INTO num_trxns
        FROM iby_batches_all
       WHERE BatchID = order_id_in;
      IF (num_trxns > 0)
      THEN
        SELECT BatchStatus
          INTO status_out
          FROM iby_batches_all
         WHERE BatchID = order_id_in;
      END IF;
    ELSIF ((UPPER(payment_operation_in) <> 'ORASET_QRYBATCHSTATUS') AND
           (UPPER(payment_operation_in) <> 'ORASET_TRXNSTATUSQUERY'))
    THEN
      -- Not a batch or query operation, so get the status from
      -- the SET table
      getStatus_SET(order_id_in, merchant_id_in, UPPER(payment_operation_in), split_id_in, status_out);
      -- get previous price information
      getAmount_SET(order_id_in, merchant_id_in, UPPER(payment_operation_in), split_id_in, previous_price_out,previous_currency_out);
      -- Do additional processing per operation to get previous SET trxn id
      IF (UPPER(payment_operation_in) = 'ORASET_AUTH')
      THEN
        -- It's a subsequent auth, so raise an error since this
        -- procedure is not to be used for this case

       	raise_application_error(-20000, 'IBY_20311#', FALSE);
        --raise_application_error(-20311,'GET_SETTRXNID: This procedure does not handle split auths, use processSplitAuth instead');
      ELSIF (UPPER(payment_operation_in) = 'ORASET_AUTHREV')
      THEN
        -- It's an auth reversal, so parent will be
        -- an auth (VeriFone doesn't support authrev of subsequentauth)
        -- dbms_output.put_line('In ORASET_AUTHREV, m_id, o_id, m_tx_id: '||merchant_id_in||' '||order_id_in||' '||split_id_in);

        -- See how many trxns of type SET (PREQ=2) or AUTH
        -- of this order_id, trxn_id occurred before
        SELECT count(*)
          INTO num_trxns
          FROM iby_transactions_set_v
         WHERE order_id = order_id_in
           AND merchant_id = merchant_id_in
           AND trxn_type IN (2)
           AND split_id = split_id_in
           AND (request_type IN (2,4)
                OR
                request_type IS NULL)
           AND status = 0;
        -- dbms_output.put_line('Num m_trx_ids found for oid,mid,mtxid combo: '||num_trxns);
        IF (num_trxns = 1)
        THEN
          -- Only one matching trxn, so get the SET trxn id
          -- dbms_output.put_line('Getting SET Trxn ID');
          SELECT TRX.set_trxn_id, TRX.amount, TRX.currency
            INTO prev_set_trxn_id_in_out,price_out,currency_out
            FROM iby_transactions_set_v TRX
           WHERE order_id = order_id_in
             AND merchant_id = merchant_id_in
             AND trxn_type IN (2)
             AND split_id = split_id_in
             AND (request_type IN (2,4)
                  OR
                  request_type IS NULL)
             AND status = 0;
          -- dbms_output.put_line('SET trxn id: '||prev_set_trxn_id_in_out);
        ELSIF (num_trxns = 0)
        THEN
          -- No matching trxns, so return error
       	  raise_application_error(-20000, 'IBY_20312#', FALSE);
          --raise_application_error(-20312,'No authorization matching given order_id '||order_id_in||', split_id '||split_id_in||' to be voided');
        ELSE
          -- Too many transactions match
       	  raise_application_error(-20000, 'IBY_20313#', FALSE);
          --raise_application_error(-20313,num_trxns || ' duplicate transactions matching given order_id, split_id: '||order_id_in||' '||split_id_in||' to be voided');
        END IF;
      ELSIF  (UPPER(payment_operation_in) = 'ORASET_CAPTURE')
      THEN
        -- It's a capture, so parent will be
        -- an auth, authrev or subsequentauth
        -- dbms_output.put_line('In ORASET_CAPTURE, m_id, o_id, m_tx_id: '||merchant_id_in||' '||order_id_in||' '||split_id_in);
        -- See how many trxns of type SET (PREQ=2) or AUTH
        -- of this order_id, trxn_id occurred before
        SELECT count(*)
          INTO num_trxns
          FROM iby_transactions_set_v
         WHERE order_id = order_id_in
           AND merchant_id = merchant_id_in
           AND trxn_type IN (2,4,101) -- auth, authrev, or subsequentauth
           AND split_id = split_id_in
           AND (request_type IN (2,4)
                OR
                request_type IS NULL)
           AND status = 0;
        -- dbms_output.put_line('Num m_trx_ids found for oid,mid,mtxid combo: '||num_trxns);
        IF (num_trxns = 2)
        THEN
          -- If two transactions match, then get the authrev, which will be
          -- later than the auth or the subsequentauth
          SELECT count(*)
            INTO num_trxns
            FROM iby_transactions_set_v
           WHERE order_id = order_id_in
             AND merchant_id = merchant_id_in
             AND trxn_type = 4 		-- authrev
             AND split_id = split_id_in
             AND (request_type IN (2,4)
                  OR
                  request_type IS NULL)
             AND status = 0;
          IF (num_trxns = 1)
          THEN
            -- Only one matching trxn, so get the SET trxn id
            -- dbms_output.put_line('Getting SET Trxn ID');
            SELECT TRX.set_trxn_id, TRX.amount, TRX.currency
              INTO prev_set_trxn_id_in_out,price_out,currency_out
              FROM iby_transactions_set_v TRX
             WHERE order_id = order_id_in
               AND merchant_id = merchant_id_in
               AND trxn_type = 4         --authrev
               AND split_id = split_id_in
               AND (request_type IN (2,4)
                    OR
                    request_type IS NULL)
               AND status = 0;

               -- dbms_output.put_line('SET trxn id: '||prev_set_trxn_id_in_out);

          ELSIF (num_trxns = 0)
          THEN
            -- No matching trxns, so return error
	    raise_application_error(-20000, 'IBY_20314#', FALSE);
            --raise_application_error(-20314,'No void (of authorization) matching given order_id '||order_id_in||', split_id '||split_id_in||' to capture');
          ELSE
            -- Too many transactions match
       		raise_application_error(-20000, 'IBY_20315#', FALSE);
            --raise_application_error(-20315,num_trxns||' duplicate void of auth transactions matching given order_id, split_id: '||order_id_in||' '||split_id_in||' to capture');
          END IF;
        ELSIF (num_trxns = 1)
        THEN
          -- Only one matching trxn, so get the SET trxn id
          -- dbms_output.put_line('Getting SET Trxn ID');

          SELECT TRX.set_trxn_id, TRX.amount, TRX.currency
            INTO prev_set_trxn_id_in_out,price_out,currency_out
            FROM iby_transactions_set_v TRX
           WHERE order_id = order_id_in
             AND merchant_id = merchant_id_in
             AND trxn_type IN (2, 4, 101)
             AND split_id = split_id_in
             AND (request_type IN (2,4)
                  OR
                  request_type IS NULL)
             AND status = 0;
          -- dbms_output.put_line('SET trxn id: '||prev_set_trxn_id_in_out);
        ELSIF (num_trxns = 0)
        THEN
          -- No matching trxns, so return error
       	raise_application_error(-20000, 'IBY_20316#', FALSE);
          --raise_application_error(-20316,'No authorization matching given order_id '||order_id_in||', split_id '||split_id_in||'merchant_id_in'||merchant_id_in||' to capture');
        ELSE
          -- Too many transactions match
       	raise_application_error(-20000, 'IBY_20317#', FALSE);
          --raise_application_error(-20317,num_trxns||' duplicate transactions matching given order_id, split_id: '||order_id_in||' '||split_id_in);
        END IF;
      ELSIF ((UPPER(payment_operation_in) = 'ORASET_CAPREV') OR
             (UPPER(payment_operation_in) = 'ORASET_CREDIT'))
      THEN
        -- It's a capture reversal or credit operation, so parent
        -- trxn will be a capture or an auth capture
        -- dbms_output.put_line('In ORASET_CAPREV or CREDIT, m_id, o_id, m_tx_id: '||merchant_id_in||' '||order_id_in||' '||split_id_in);
        -- See if trxn is duplicate
        SELECT count(*)
          INTO num_trxns
          FROM iby_transactions_set_v
         WHERE order_id = order_id_in
           AND merchant_id = merchant_id_in
           AND ( trxn_type IN (8, 9)
                 OR
                 (trxn_type = 3 AND request_type IN (2,4)))
           AND split_id = split_id_in;
        -- dbms_output.put_line('Num m_trx_ids found for oid,mid,mtxid combo: '||num_trxns);
        IF (num_trxns = 1)
        THEN
          -- dbms_output.put_line('Getting SET Trxn ID');

          SELECT TRX.set_trxn_id, TRX.amount, TRX.currency
            INTO prev_set_trxn_id_in_out,price_out,currency_out
            FROM iby_transactions_set_v TRX
           WHERE order_id = order_id_in
             AND merchant_id = merchant_id_in
             AND  ( trxn_type IN (8, 9)
                    OR
                  (trxn_type = 3 AND request_type IN (2,4)))
             AND split_id = split_id_in;
          -- dbms_output.put_line('SET trxn id: '||prev_set_trxn_id_in_out);
        ELSIF (num_trxns = 0)
        THEN
           	raise_application_error(-20000, 'IBY_20318#', FALSE);
          --raise_application_error(-20318,'No CAPTURE trxn matching given order_id '||order_id_in||', split_id '||split_id_in||' to to void or credit');
        ELSE
          -- Too many transactions match
       	raise_application_error(-20000, 'IBY_20319#', FALSE);
          --raise_application_error(-20319,num_trxns||' duplicate transactions '||num_trxns||' matching given order_id, split_id: '||order_id_in||' '||split_id_in);
        END IF;
      ELSIF (UPPER(payment_operation_in) = 'ORASET_CREDITREV')
      THEN
        -- It's a credit reversal, so parent will be a credit
        -- dbms_output.put_line('In ORASET_CREDITREV, m_id, o_id, m_tx_id: '||merchant_id_in||' '||order_id_in||' '||split_id_in);
        -- See if trxn is duplicate
        SELECT count(*)
          INTO num_trxns
          FROM iby_transactions_set_v
         WHERE order_id = order_id_in
           AND merchant_id = merchant_id_in
           AND trxn_type = 5
           AND split_id = split_id_in;
        -- dbms_output.put_line('Num m_trx_ids found for oid,mid,mtxid combo: '||num_trxns);
        IF (num_trxns = 1)
        THEN
          -- dbms_output.put_line('Getting SET Trxn ID');

          SELECT TRX.set_trxn_id, TRX.amount, TRX.currency
            INTO prev_set_trxn_id_in_out,price_out,currency_out
            FROM iby_transactions_set_v TRX
           WHERE order_id = order_id_in
             AND merchant_id = merchant_id_in
             AND trxn_type = 5
             AND split_id = split_id_in;
          -- dbms_output.put_line('SET trxn id: '||prev_set_trxn_id_in_out);
        ELSIF (num_trxns = 0)
        THEN
       	raise_application_error(-20000, 'IBY_20320#', FALSE);
          --raise_application_error(-20320,'No RETURN/CREDIT trxn matching given order_id '||order_id_in||', split_id '||split_id_in||' to be voided');
        ELSE
          -- Too many transactions match
       	raise_application_error(-20000, 'IBY_20321#', FALSE);
          --raise_application_error(-20321,num_trxns||' duplicate RETURN/CREDIT transactions matching given order_id, split_id: '||order_id_in||' '||split_id_in);
        END IF;
      END IF;
    END IF;
  END get_settrxninfo;


  /* Internal procedure to get the vendor configuration by the */
  /* payment name.                                             */
 /** was this procedure used any where??? --jjwu*/

/*	-- no longer supported
  PROCEDURE getVendorByPmtName
       (payment_name_in   IN     iby_routinginfo.PaymentMethodName%TYPE,
         p_id              IN OUT NOCOPY iby_routinginfo.PaymentMethodID%TYPE,
         v_id              IN OUT NOCOPY IBY_BEPInfo.BEPID%TYPE,
         v_suffix          OUT NOCOPY IBY_BEPInfo.suffix%TYPE,
         v_base_url        OUT NOCOPY IBY_BEPInfo.BaseURL%TYPE,
         v_pmtscheme       IN OUT NOCOPY iby_pmtschemes.PmtSchemeName%TYPE)
  IS
  BEGIN

     -- Get bep info based on paymentmethod name
     SELECT ROUT.bepid , BEP.baseurl, BEP.suffix
       INTO v_id, v_base_url, v_suffix
       FROM iby_bepinfo BEP, iby_routinginfo ROUT
      WHERE UPPER(ROUT.paymentmethodname) = UPPER(payment_name_in)
        AND BEP.bepid = ROUT.bepid
        AND ROUT.configured = 1;


	iby_pmtschemes_pkg.getPmtSchemeName(v_id, v_pmtscheme);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

      IF p_id IS NULL
      THEN
       	raise_application_error(-20000, 'IBY_20331#', FALSE);
        --raise_application_error(-20331,'Invalid payment method (OapfPmtType).' || UPPER(payment_name_in));
      END IF;

       	raise_application_error(-20000, 'IBY_20330#', FALSE);
      --raise_application_error(-20330,'NO DATA FOUND error in getVendorByPmtName.');

  END getVendorByPmtName;
*/


  /* Procedure used to get the status for a particular SET     */
  /* trxn.  The status_out will be set to some value if the    */
  /* order occurred previously, else it'll be null.            */
  PROCEDURE getStatus_SET
       (order_id_in           IN   iby_trxn_summaries_all.TangibleID%TYPE,
        merchant_id_in        IN   IBY_Payee.PayeeID%TYPE,
        payment_operation_in  IN   VARCHAR2,
        split_id_in           IN   iby_trxn_extended.SplitID%TYPE,
        status_out            OUT NOCOPY iby_trxn_summaries_all.Status%TYPE)
  IS
    loc_status  iby_transactions_set_v.status%TYPE;
    num_trxns   NUMBER;
    max_time    DATE;
    CURSOR s1(tx1 NUMBER,
              tx2 NUMBER DEFAULT NULL) IS
         SELECT status
           FROM iby_transactions_set_v
           WHERE order_id = order_id_in
           AND merchant_id = merchant_id_in
           AND trxn_type IN (tx1, tx2)
           AND split_id = split_id_in
           ORDER BY time DESC;
   BEGIN

     -- Depending on the payment operation the trxn_type varies
     -- So we need to select based on this set
     -- For an explanation of various trxn_types refer the design doc

     IF (payment_operation_in <> 'ORASET_SET')
     THEN
       -- Handle normally
       IF payment_operation_in = 'ORASET_INIT' THEN
         OPEN s1(0);
       ELSIF payment_operation_in = 'ORASET_AUTHREV' THEN
         OPEN s1(4,7);
       ELSIF payment_operation_in = 'ORASET_CAPTURE' THEN
         OPEN s1(8);
       ELSIF payment_operation_in = 'ORASET_CAPREV' THEN
         OPEN s1(13);
       ELSIF payment_operation_in = 'ORASET_CREDIT' THEN
         OPEN s1(5);
       ELSIF payment_operation_in = 'ORASET_CREDITREV' THEN
         OPEN s1(17);
       END IF;

       -- Fetch the first row to check the status
       FETCH s1 INTO loc_status;
       IF s1%FOUND THEN
         -- Make sure it's not an empty status
         IF (loc_status IS NULL)
         THEN
           status_out := 9999;
         ELSE
           status_out := loc_status;
         END IF;

       ELSE
         -- No rows found
         status_out := NULL;
       END IF;

       CLOSE s1;
     ELSE
       -- oraset_set requires special handling because in the SET protocol,
       -- TWO oraset_set trxns are logged into the DB:  one for
       -- PInitReq (request_type=1) and one for PReq (request_type=2)
       -- Get number of PReq trxns
       SELECT count(*)
         INTO num_trxns
         FROM iby_transactions_set_v
         WHERE order_id = order_id_in
         AND merchant_id = merchant_id_in
         AND trxn_type in (2,3)
         AND request_type = 2;
       -- dbms_output.put_line('Num PREQ trxns: '||num_trxns);
       IF (num_trxns = 0)
       THEN
         status_out := null;

       ELSE
         -- A previous PReq was found
         SELECT status
           INTO loc_status
           FROM iby_transactions_set_v
           WHERE order_id = order_id_in
           AND merchant_id = merchant_id_in
           AND trxn_type in (2,3)
           AND request_type = 2
           ORDER BY TIME DESC;
           IF (loc_status IS NULL)
           THEN
             status_out := 9999;
           ELSE
             status_out := loc_status;
           END IF;
       END IF;
     END IF;
   END getStatus_SET;


  /* Procedure used to get the status for a particular SET     */
  /* trxn.  The status_out will be set to some value if the    */
  /* order occurred previously, else it'll be null.            */
  PROCEDURE getAmount_SET
      (order_id_in           IN   iby_trxn_summaries_all.TangibleID%TYPE,
        merchant_id_in        IN   IBY_Payee.PayeeID%TYPE,
        payment_operation_in  IN   VARCHAR2,
        split_id_in           IN   iby_trxn_extended.SplitID%TYPE,
        price_out             OUT NOCOPY iby_trxn_summaries_all.Amount%TYPE,
        currency_out          OUT NOCOPY iby_trxn_summaries_all.CurrencyNameCode%TYPE)
  IS
    num_trxns   NUMBER;
    max_time    DATE;
    CURSOR s1(tx1 NUMBER,
              tx2 NUMBER DEFAULT NULL) IS
         SELECT amount,currency
           FROM iby_transactions_set_v
           WHERE order_id = order_id_in
           AND merchant_id = merchant_id_in
           AND trxn_type IN (tx1, tx2)
           AND split_id = split_id_in
           ORDER BY time DESC;
   BEGIN

     -- Depending on the payment operation the trxn_type varies
     -- So we need to select based on this set
     -- For an explanation of various trxn_types refer the design doc
     price_out := NULL;
     currency_out := NULL;

     IF (payment_operation_in <> 'ORASET_SET')
     THEN
       -- Handle normally
       IF payment_operation_in = 'ORASET_INIT' THEN
         OPEN s1(0);
       ELSIF payment_operation_in = 'ORASET_AUTH' THEN
         OPEN s1(101);
       ELSIF payment_operation_in = 'ORASET_AUTHREV' THEN
         OPEN s1(4,7);
       ELSIF payment_operation_in = 'ORASET_CAPTURE' THEN
         OPEN s1(8);
       ELSIF payment_operation_in = 'ORASET_CAPREV' THEN
         OPEN s1(13);
       ELSIF payment_operation_in = 'ORASET_CREDIT' THEN
         OPEN s1(5);
       ELSIF payment_operation_in = 'ORASET_CREDITREV' THEN
         OPEN s1(17);
       END IF;

       -- Fetch the first row to check the status
       FETCH s1 INTO price_out,currency_out;
       CLOSE s1;
     ELSE
       -- oraset_set requires special handling because in the SET protocol,
       -- TWO oraset_set trxns are logged into the DB:  one for
       -- PInitReq (request_type=1) and one for PReq (request_type=2)
       -- Get number of PReq trxns
       SELECT count(*)
         INTO num_trxns
         FROM iby_transactions_set_v
         WHERE order_id = order_id_in
         AND merchant_id = merchant_id_in
         AND trxn_type in (2,3)
         AND request_type = 2;
       -- dbms_output.put_line('Num PREQ trxns: '||num_trxns);
       IF (num_trxns > 0)
       THEN
         -- A previous PReq was found
         SELECT amount,currency
           INTO price_out, currency_out
           FROM iby_transactions_set_v
           WHERE order_id = order_id_in
           AND merchant_id = merchant_id_in
           AND trxn_type in (2,3)
           AND request_type = 2
           ORDER BY TIME DESC;
       END IF;
     END IF;
   END getAmount_SET;


  /* Procedure used for orasubsequentauth instead of the       */
  /* getStatus_SET procedure.  It performs some special        */
  /* processing.                                               */

  PROCEDURE processsplitauth
        (merchant_id_in        IN     IBY_Payee.PayeeID%TYPE,
         order_id_in           IN     iby_trxn_summaries_all.TangibleID%TYPE,
         prev_split_id_in      IN     iby_trxn_extended.SPlitID%TYPE,
         split_id_in           IN     iby_trxn_extended.SPlitID%TYPE,
         vendor_id_in          IN     IBY_Payee.PayeeID%TYPE,
         status_out            OUT NOCOPY iby_trxn_summaries_all.Status%TYPE,
         set_trxn_id_out       IN OUT NOCOPY iby_trxn_extended.SETTrxnID%TYPE,
         previous_price_out    OUT NOCOPY iby_trxn_summaries_all.Amount%TYPE,
         previous_currency_out OUT NOCOPY iby_trxn_summaries_all.CurrencyNameCode%TYPE)
  IS
    num_trxns        NUMBER;
    max_time         DATE;
    num_succ_trxns   NUMBER;
    auth_ind         NUMBER;
  BEGIN
    num_trxns := NULL;
    max_time := NULL;
    num_succ_trxns := NULL;
    -- get previous price information
    getAmount_SET(order_id_in, merchant_id_in,'ORASET_AUTH', split_id_in, previous_price_out,previous_currency_out);
    -- See if trxn is duplicate
    SELECT count(*)
      INTO num_trxns
      FROM iby_transactions_set_v
     WHERE order_id = order_id_in
       AND merchant_id = merchant_id_in
       AND split_id = split_id_in
       AND trxn_type = 101;
    -- dbms_output.put_line('Num m_trx_ids found for oid,mid,mtxid combo: '||num_trxns);

    IF (num_trxns > 0)
    THEN
      -- Duplicate transaction found, so return status of that
      -- transaction
      -- dbms_output.put_line('Dup txn id');
      SELECT status
        INTO status_out
        FROM iby_transactions_set_v
       WHERE order_id = order_id_in
         AND merchant_id = merchant_id_in
         AND split_id = split_id_in
         AND trxn_type = 101;
    END IF;

    -- Get count number of successful parent set trxn ids
    SELECT count(*)
      INTO num_trxns
      FROM iby_transactions_set_v
     WHERE order_id = order_id_in
       AND merchant_id = merchant_id_in
       AND split_id = prev_split_id_in
       AND trxn_type IN (2, 101)
       AND (request_type IN (2,4)
            OR
            request_type IS NULL)
       AND status = 0;
    IF (num_trxns = 0)
    THEN
       	raise_application_error(-20000, 'IBY_20391#', FALSE);
      --raise_application_error(-20391,'processSplitAuth: Either parent not found or parent not successful.  Please check parameters and perhaps query trxn status');
    ELSE
      -- dbms_output.put_line('found # of parents: '||num_trxns);
      -- Get previous SET transaction id and
      -- subsequent authorization indicator
      SELECT set_trxn_id, subseq_auth_ind
        INTO set_trxn_id_out, auth_ind
        FROM iby_transactions_set_v
       WHERE order_id = order_id_in
         AND merchant_id = merchant_id_in
         AND split_id = prev_split_id_in
         AND trxn_type IN (2,101)
         AND (request_type IN (2,4)
              OR
              request_type IS NULL)
         AND status = 0;

      -- dbms_output.put_line('Prev SET trxn id: '||set_trxn_id_out);
      -- Check to see if the previous transaction allows a split.
      -- If not, return an error.
      IF (auth_ind <> 1)
      THEN
       	raise_application_error(-20000, 'IBY_20392#', FALSE);
        --raise_application_error(-20392,'Previous transaction does not allow a subsequent authorization - subseq_auth_ind is not 1');
      END IF;
    END IF;
  END processSplitAuth;

END iby_queryset_pkg;

/
