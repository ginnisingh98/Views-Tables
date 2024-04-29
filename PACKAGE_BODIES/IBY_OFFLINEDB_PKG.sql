--------------------------------------------------------
--  DDL for Package Body IBY_OFFLINEDB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_OFFLINEDB_PKG" AS
/*$Header: ibyofflb.pls 120.2.12010000.4 2009/04/15 19:03:29 svinjamu ship $ */

/*
** Function Name : isPayeeRegistered
** Purpose : Checks if payee has specified bep key with the specified bep.
**
** Parameters:
**
**    In  : i_payeeid, i_bepid, i_bepkey
**
*/
Function isPayeeRegistered(i_payeeid iby_bepkeys.ownerid%type, i_bepid iby_bepkeys.bepid%type, i_bepkey iby_bepkeys.key%type )
return boolean
is
l_cnt integer;
begin

    select count(*) into l_cnt
    from iby_bepkeys
    where bepid = i_bepid
    and ownerid = i_payeeid
    and ownertype = 'PAYEE'
    and key = i_bepkey;

    return (l_cnt <> 0);
end;


/*
** Procedure Name : schedulePC
** Purpose : creates an entry for scheduling the CreditCard payments
**	     in the iby_trxn_summaries_all and iby_trxn_core
**	     tables.  Returns the transactionid created
**           by the system.
*/
procedure schedulePC( i_ecappid  iby_trxn_summaries_all.ecappid%type,
		      i_payeeid	 iby_trxn_summaries_all.payeeid%type,
		      i_bepid    iby_trxn_summaries_all.bepid%type,
		      i_bepkey   iby_trxn_summaries_all.bepkey%type,
		      i_tangibleid iby_trxn_summaries_all.tangibleid%type,
                      i_reqtype iby_trxn_summaries_all.reqtype%type,
                      i_reqdate iby_trxn_summaries_all.reqdate%type,
                      i_pmtmethod iby_trxn_summaries_all.paymentmethodname%type,
		      i_desturl iby_trxn_summaries_all.desturl%type,
                      io_transactionid in out nocopy iby_trxn_summaries_all.transactionid%type,
                      i_amount iby_trxn_summaries_all.amount%type,
                      i_currency iby_trxn_summaries_all.currencynamecode%type,
		      i_trxntypeid iby_trxn_summaries_all.trxntypeid%type,
		      i_nlslang iby_trxn_summaries_all.Nlslang%type,
                      i_settledate iby_trxn_summaries_all.settledate%type,
		      i_authtype iby_trxn_core.authtype%type,
                      i_instrid iby_trxn_summaries_all.payerinstrid%type,
		      i_payerid iby_trxn_summaries_all.payerid%type,
			i_org_id iby_trxn_summaries_all.org_id%type,

			i_instrtype iby_trxn_summaries_all.instrtype%type,
                      i_billeracct iby_tangible.acctno%type,
                      i_refinfo iby_tangible.refinfo%type,
                      i_memo iby_tangible.memo%type,
                      i_voiceauthflag iby_trxn_core.voiceauthflag%type,
                      i_authcode iby_trxn_core.authcode%type,
		      i_ponum iby_trxn_core.ponumber%type,
		      i_taxamt iby_trxn_core.taxamount%type,
		      i_shipfromzip iby_trxn_core.shipfromzip%type,
		      i_shiptozip iby_trxn_core.shiptozip%type,
                      i_OrderMedium IN iby_tangible.Order_Medium%TYPE,
                      i_EftAuthMethod IN iby_tangible.Eft_Auth_Method%TYPE
                      )
IS
  l_mid	     NUMBER;
  l_tid	     NUMBER;
  l_org_id   NUMBER;
  -- 0011 indicates PENDING status
  l_status   NUMBER := 0011;
  l_tmid iby_trxn_summaries_all.mtangibleid%type;

  l_instrid iby_trxn_summaries_all.payerinstrid%type;

  l_mpayeeid iby_payee.mpayeeid%type;

BEGIN

   -- First check if this request is not duplicate
   if (requestExists(i_payeeid,i_tangibleid, i_reqtype, i_bepid )) then
           raise_application_error(-20000, 'IBY_20604#', FALSE);
		-- duplicated request
   end if;

   if (UPPER(i_reqtype) = 'ORAPMTREQ' OR
	UPPER(i_reqtype) = 'ORAPMTCREDIT') then

       if ( isPayeeRegistered(i_payeeid, i_bepid, i_bepkey ) = false ) then
	   -- make sure payee id is valid
           raise_application_error(-20000, 'IBY_20605#', FALSE);
       end if;

        if (i_instrid IS NULL or (NOT instrExists(i_instrid, i_instrtype))) THEN
	   --reject invalid instrid
		raise_application_error(-20000, 'IBY_20512#', FALSE);
	END IF;

	-- Get new transaction id
	io_transactionid := iby_transactioncc_pkg.getTID(
					i_payeeid, i_tangibleid);

        iby_bill_pkg.createBill(i_tangibleid, i_amount, i_currency,
                   i_billeracct, i_refinfo, i_memo,
                   i_OrderMedium, i_EftAuthMethod, l_tmid);

	l_instrid := i_instrid;
	l_org_id := i_org_id;
   ELSE
        SELECT DISTINCT mtangibleid, payerinstrid into l_tmid, l_instrid
        from iby_trxn_summaries_all
        where transactionid = io_transactionid
        --and status <> -99 and status <> 14;
	and (status = 11 or status = 0);

	-- getOrgId
	l_org_id := iby_transactioncc_pkg.getOrgId(io_transactionid);
   END IF;

   -- Get the master transaction id sequence for all requests
    SELECT iby_trxnsumm_mid_s.NEXTVAL
    INTO l_mid
    FROM dual;

   -- insert the scheduled request in the summary and core tables
   iby_accppmtmthd_pkg.getMPayeeId(i_payeeid, l_mpayeeid);
   INSERT INTO iby_trxn_summaries_all
     (TrxnMID, TransactionID, TangibleID,
      MPayeeID, PayeeID,BEPID, bepkey, ECAppID, PaymentMethodName,
      PayerID, PayerInstrID, Amount,CurrencyNameCode,
      Status, TrxntypeID, SettleDate, ReqDate, ReqType, DestUrl, Nlslang,
      mtangibleid, org_id, instrtype,
	last_update_date, updatedate, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number,needsupdt)
   VALUES
     (l_mid, io_transactionid, i_tangibleid,
      l_mpayeeid, i_payeeid, i_bepid, i_bepkey, i_ecappid, i_pmtmethod,
      i_payerid, l_instrid, i_amount, i_currency,
      l_status, i_trxntypeid, i_settledate, sysdate, i_reqtype, i_desturl,
i_nlslang, l_tmid, l_org_id, i_instrtype,
	 sysdate, sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id, fnd_global.login_id, 1,'Y');

   -- insert the authtype into core table
   INSERT INTO iby_trxn_core
     (TrxnMID, Authtype, PONumber, TaxAmount, ShipFromZip, ShipToZip,
	last_update_date, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number, AuthCode, VoiceAuthFlag)
   VALUES
     (l_mid, i_authtype, i_ponum, i_taxamt, i_shipfromzip, i_shiptozip,
	 sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1, i_authcode, i_voiceauthflag);

	commit;
  END schedulePC;

/*
** Procedure Name : scheduleCC
** Purpose : creates an entry for scheduling the PurchaseCard payments
**	     in the iby_trxn_summaries_all and iby_trxn_core
**	     tables.  Returns the transactionid created
**           by the system.
*/
procedure scheduleCC( i_ecappid  iby_trxn_summaries_all.ecappid%type,
		      i_payeeid	 iby_trxn_summaries_all.payeeid%type,
		      i_bepid    iby_trxn_summaries_all.bepid%type,
		      i_bepkey   iby_trxn_summaries_all.bepkey%type,
		      i_tangibleid iby_trxn_summaries_all.tangibleid%type,
                      i_reqtype iby_trxn_summaries_all.reqtype%type,
                      i_reqdate iby_trxn_summaries_all.reqdate%type,
                      i_pmtmethod iby_trxn_summaries_all.paymentmethodname%type,
		      i_desturl iby_trxn_summaries_all.desturl%type,
                      io_transactionid in out nocopy iby_trxn_summaries_all.transactionid%type,
                      i_amount iby_trxn_summaries_all.amount%type,
                      i_currency iby_trxn_summaries_all.currencynamecode%type,
		      i_trxntypeid iby_trxn_summaries_all.trxntypeid%type,
		      i_nlslang iby_trxn_summaries_all.Nlslang%type,
                      i_settledate iby_trxn_summaries_all.settledate%type,
		      i_authtype iby_trxn_core.authtype%type,
                      i_instrid iby_trxn_summaries_all.payerinstrid%type,
		      i_payerid iby_trxn_summaries_all.payerid%type,
			i_org_id iby_trxn_summaries_all.org_id%type,

			i_instrtype iby_trxn_summaries_all.instrtype%type,

                      i_billeracct iby_tangible.acctno%type,
                      i_refinfo iby_tangible.refinfo%type,
                      i_memo iby_tangible.memo%type,
                      i_voiceauthflag iby_trxn_core.voiceauthflag%type,
                      i_authcode iby_trxn_core.authcode%type,
                      i_OrderMedium IN iby_tangible.Order_Medium%TYPE,
                      i_EftAuthMethod IN iby_tangible.Eft_Auth_Method%TYPE
                      )
IS
BEGIN

SchedulePC(i_ecappid, i_payeeid, i_bepid, i_bepkey, i_tangibleid, i_reqtype,
	i_reqdate, i_pmtmethod, i_desturl, io_transactionid, i_amount,
	i_currency, i_trxntypeid, i_nlslang, i_settledate, i_authtype,
	i_instrid, i_payerid, i_org_id, i_instrtype, i_billeracct,
	i_refinfo, i_memo, i_voiceauthflag, i_authcode, null, null, null,
	null, i_OrderMedium, i_EftAuthMethod);

END ScheduleCC;


/*
**  Procedure Name : scheduleCCCancel
**    Purpose : creates an entry for a CreditCard cancel request in the
**   iby_trxn_summaries_all table
*/
procedure scheduleCCCancel(i_ecappid iby_batches_all.ecappid%type,
		 	   i_payeeid iby_batches_all.payeeid%type,
			   i_bepid iby_batches_all.bepid%type,
			   i_bepkey iby_batches_all.bepkey%type,
			  i_tangibleid iby_trxn_summaries_all.tangibleid%type,
			   i_reqtype iby_trxn_summaries_all.reqtype%type,
			   i_reqdate iby_trxn_summaries_all.reqdate%type,
			   i_pmtmethod iby_trxn_summaries_all.paymentmethodname%type,
			   i_transactionid in
				iby_trxn_summaries_all.transactionid%type
,
			  i_reqtype_tocancel iby_trxn_summaries_all.reqtype%type,
			  i_trxntypeid_tocancel in iby_trxn_summaries_all.trxntypeid%type)
  IS
    l_mid	     NUMBER;
    l_status   NUMBER := 0014;
    l_tmid iby_trxn_summaries_all.mtangibleid%type;
  l_instrid iby_trxn_summaries_all.payerinstrid%type;
	l_mpayeeid iby_payee.mpayeeid%type;
  BEGIN
 -- Get the master transaction id sequence for all requests

    SELECT iby_trxnsumm_mid_s.NEXTVAL
    INTO l_mid
    FROM dual;

        select mtangibleid, payerinstrid into l_tmid, l_instrid
        from iby_trxn_summaries_all
        where transactionid = i_transactionid
	and reqtype = i_reqtype_tocancel
        and rownum < 2;

	iby_accppmtmthd_pkg.getMPayeeId(i_payeeid, l_mpayeeid);

      INSERT INTO iby_trxn_summaries_all
     (TrxnMID, TransactionID, TangibleID,
      MPayeeID, PayeeID,BEPID, bepkey, ECAppID, PaymentMethodName,
	status, mtangibleid, trxntypeid,
	reqtype, reqdate, payerinstrid,
	last_update_date, updatedate, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number,needsupdt)
      VALUES
        (l_mid, i_transactionid, i_tangibleid,
      	l_mpayeeid, i_payeeid, i_bepid, i_bepkey, i_ecappid, i_pmtmethod,
	l_status, l_tmid, i_trxntypeid_tocancel,
	i_reqtype, sysdate, l_instrid,
	 sysdate, sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1,'Y');

	commit;

     EXCEPTION
    WHEN NO_DATA_FOUND THEN
           raise_application_error(-20000, 'IBY_20300#', FALSE);
     --raise_application_error(-20300,'Cannot insert cancel trxn into iby_trxn_summaries_all');

    END scheduleCCCancel;


/*
** Procedure Name : scheduleCCbatch
** Purpose : creates an entry for scheduling the CreditCard batch requests
**           in the iby_batches_all table.
**
** Parameters:
**
**    In  : i_ecappid, i_payeeid, i_bepid, i_batchid,
**          i_reqtype, i_reqdate, i_pmtmethod, i_desturl,
**          i_nlslang, i_terminalid
**
*/
procedure scheduleCCbatch(i_ecappid iby_batches_all.ecappid%type,
                          i_payeeid iby_batches_all.payeeid%type,
                          i_bepid iby_batches_all.bepid%type,
                          i_bepkey iby_batches_all.bepkey%type,
                          i_batchid iby_batches_all.batchid%type,
                          i_reqtype iby_batches_all.reqtype%type,
                          i_reqdate iby_batches_all.reqdate%type,
                          i_pmtmethod iby_batches_all.paymentmethodname%type,
			  i_desturl iby_batches_all.desturl%type,
                          i_nlslang iby_batches_all.nlslang%type,
                          i_terminalid iby_batches_all.terminalid%type,
			  i_schedDate iby_batches_all.batchopendate%type)
  IS
    -- 0011 indicates PENDING status
  l_status   NUMBER := 0011;
  l_mpayeeid iby_payee.mpayeeid%type;
  l_mbatchid iby_batches_all.mbatchid%type;

  BEGIN
  -- call procedure to check if this is duplicate request
   if (batchExists(i_payeeid, i_batchid, i_reqtype)) then
           raise_application_error(-20000, 'IBY_20604#', FALSE);
	--raise_application_error(-20604, 'Duplicate Request ' , FALSE);
   end if;
  -- insert the request into the batch table

       SELECT iby_batches_s.NEXTVAL
        INTO l_mbatchid
        FROM dual;

  iby_accppmtmthd_pkg.getMPayeeId(i_payeeid, l_mpayeeid);
  -- Bug:8363526. : Inserting value for new column iby_batches_all
  -- Inserted column settledate value will be sysdate.
   INSERT INTO iby_batches_all
   (MBatchID, BatchID, MPayeeID, PayeeID, BEPID, bepkey, ECAppID,
    PaymentMethodName, BatchStatus,
    ReqType, ReqDate, DestUrl,
    Nlslang, TerminalID, BatchOpenDate,
	last_update_date, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number,settledate)

  VALUES
   (l_mbatchid, i_batchid, l_mpayeeid, i_payeeid, i_bepid, i_bepkey, i_ecappid,
    i_pmtmethod, l_status,
    i_reqtype, sysdate, i_desturl,
    i_nlslang, i_terminalid, i_schedDate,
	 sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1,sysdate);

	commit;
  END scheduleCCbatch;


/*
** Procedure Name : scheduleSET
** Purpose : creates an entry for scheduling the SET CreditCard payments
**	     in the iby_trxn_summaries_all and iby_trxn_extended
**	     tables.  Returns the transactionid created
**           by the system.
**
** Parameters:
**
**    In  : i_ecappid, io_transactionid i_amount, i_currency, i_reqdate,
**          i_reqtype, i_settledate, i_tangibleid, i_payeeid,
**          i_bepid, i_pmtmethod,  i_desturl, i_instrid, i_payerid
**    Out : io_transactionid.
**
*/
procedure scheduleSET( i_ecappid  iby_trxn_summaries_all.ecappid%type,
                      i_payeeid  iby_trxn_summaries_all.payeeid%type,
                      i_bepid    iby_trxn_summaries_all.bepid%type,
                      i_tangibleid iby_trxn_summaries_all.tangibleid%type,
                      i_reqtype iby_trxn_summaries_all.reqtype%type,
                      i_reqdate iby_trxn_summaries_all.reqdate%type,
                      i_reqseq iby_trxn_summaries_all.reqseq%type,
                      i_pmtmethod iby_trxn_summaries_all.paymentmethodname%type,
		      i_desturl iby_trxn_summaries_all.desturl%type,
                      io_transactionid in out nocopy iby_trxn_summaries_all.transactionid%type,
                      i_amount iby_trxn_summaries_all.amount%type,
                      i_currency iby_trxn_summaries_all.currencynamecode%type,
                      i_trxntypeid iby_trxn_summaries_all.trxntypeid%type,
                      i_nlslang iby_trxn_summaries_all.Nlslang%type,
                      i_settledate iby_trxn_summaries_all.settledate%type,
                      i_authtype iby_trxn_core.authtype%type,
                      i_instrid iby_trxn_summaries_all.payerinstrid%type,
		      i_payerid iby_trxn_summaries_all.payerid%type,
                  recurringfreq   iby_trxn_extended.RecurringFreq%type,
                  recurringexpdate iby_trxn_extended.RecurringExpDate%type,
                  destpostalcode  iby_trxn_extended.DestPostalCode%type,
                  custrefnum      iby_trxn_extended.CustRefNum%type,
                  localtaxprice   iby_trxn_extended.LocalTaxPrice%type,
                  localtaxcurrency iby_trxn_extended.LocalTaxCurrency%type,
                  authprice       iby_trxn_extended.AuthPrice%type,
                  authcurrency    iby_trxn_extended.AuthCurrency%type,
                  splitshipment   iby_trxn_extended.SplitShipment%type,
                  installtotaltrxns iby_trxn_extended.InstallTotalTrxns%type,
                  splitid         iby_trxn_extended.SplitId%type,
                  batchid         iby_trxn_summaries_all.BatchId%type,
                  batchseqnum     iby_trxn_extended.BatchSeqNum%type,
                  terminalid      iby_trxn_extended.TerminalId%type)
IS

  l_mid	     NUMBER;
  l_tid	     NUMBER;
  -- 0011 indicates PENDING status
  l_status   NUMBER := 0011;

l_mpayeeid iby_payee.mpayeeid%type;
l_mbatchid iby_batches_all.mbatchid%type;
BEGIN
   --if (upper(i_reqtype) = 'ORAPMTREQ') then
       --if ( isPayeeRegistered(i_payeeid, i_bepid ) = false ) then
           --raise_application_error(-20000, 'IBY_20605#', FALSE);
           --raise_application_error(-20605,
             --    'Can not make Payment, Payee Not Registered With BEP',
              --   FALSE);
       --end if;
   --end if;
-- First check if this request is not duplicate
   if (requestExists(i_payeeid,i_tangibleid, i_reqtype,i_bepid)) then
           raise_application_error(-20000, 'IBY_20604#', FALSE);
        --raise_application_error(-20604, 'Duplicate Request ' , FALSE);
   end if;

   IF ((UPPER(i_reqtype) = 'ORAPMTREQ') OR
      ( UPPER(i_reqtype) = 'ORAPMTCREDIT'))
   THEN

        if (i_instrid IS NULL or (NOT instrExists(i_instrid, 'CREDITCARD'))) THEN
	   --reject invalid instrid
		raise_application_error(-20000, 'IBY_20512#', FALSE);
	END IF;

   -- Get the transaction id sequence also

       l_tid := iby_transactioncc_pkg.getTID(i_payeeid, i_tangibleid);
	--SELECT iby_trxnsumm_trxnid_s.NEXTVAL
        --INTO l_tid
        --FROM dual;
         io_transactionid := l_tid;
   END IF;
   -- Get the master transaction id sequence for all requests

    SELECT iby_trxnsumm_mid_s.NEXTVAL
    INTO l_mid
    FROM dual;

   -- insert the scheduled request in the summary and core tables
	iby_accppmtmthd_pkg.getMPayeeId(i_payeeid, l_mpayeeid);
	iby_transactioncc_pkg.getMBatchId(batchid, i_payeeid, l_mbatchid);
   INSERT INTO iby_trxn_summaries_all
     (TrxnMID, TransactionID, TangibleID,
      MPayeeID, PayeeID,BEPID, ECAppID, PaymentMethodName,
      PayerID, PayerInstrID, Amount,CurrencyNameCode,
      Status, TrxntypeID, SettleDate, ReqDate, ReqType, ReqSeq, DestUrl,
      Nlslang, MBatchID, BatchId,
	last_update_date, updatedate, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number,needsupdt)
   VALUES
     (l_mid, io_transactionid, i_tangibleid,
      l_mpayeeid, i_payeeid, i_bepid, i_ecappid, i_pmtmethod,
      i_payerid, i_instrid, i_amount, i_currency,
      l_status, i_trxntypeid, i_settledate, sysdate, i_reqtype,
	i_reqseq,i_desturl,
      i_nlslang, l_mbatchid, batchid,
	 sysdate, sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1,'Y');

   INSERT INTO iby_trxn_extended
      (TRXNMID, RecurringFreq, RecurringExpDate, DestPostalCode,
       CustRefNum, LocalTaxPrice, LocalTaxCurrency,
       AuthPrice, AuthCurrency, InstallTotalTrxns, SplitShipment, SplitId,
       BatchSeqNum, TerminalId,
	last_update_date, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number)
   VALUES
      (l_mid, recurringfreq,recurringexpdate,destpostalcode,
       custrefnum, localtaxprice, localtaxcurrency,
       authprice, authcurrency, installtotaltrxns, splitshipment, splitid,
       batchseqnum, terminalid,
	 sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1);

   -- insert the authtype into core table
   INSERT INTO iby_trxn_core
     (TrxnMID, Authtype,
	last_update_date, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number)
   VALUES
     (l_mid, i_authtype,
	 sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1);

	commit;
  END scheduleSET;


/*
**  Procedure Name : scheduleSETCancel
**    Purpose : creates an entry for a SET CreditCard cancel request in the
**   iby_trxn_summaries_all table
*/
/*********should no longer be used
procedure scheduleSETCancel(i_ecappid iby_batches_all.ecappid%type,
		 	   i_payeeid iby_batches_all.payeeid%type,
			   i_bepid iby_batches_all.bepid%type,
			  i_tangibleid iby_trxn_summaries_all.tangibleid%type,
			   i_reqtype iby_trxn_summaries_all.reqtype%type,
			   i_reqdate iby_trxn_summaries_all.reqdate%type,
			   i_pmtmethod iby_trxn_summaries_all.paymentmethodname%type,
			   i_transactionid in out nocopy iby_trxn_summaries_all.transactionid%type
			   )
  IS
    l_mid	     NUMBER;
    l_status   NUMBER := 0011;

l_mpayeeid iby_payee.mpayeeid%type;
  BEGIN
 -- Get the master transaction id sequence for all requests

    SELECT iby_trxnsumm_mid_s.NEXTVAL
    INTO l_mid
    FROM dual;

	iby_accppmtmthd_pkg.getMPayeeId(i_payeeid, l_mpayeeid);
      INSERT INTO iby_trxn_summaries_all
     (TrxnMID, TransactionID, TangibleID,
      MPayeeID, PayeeID,BEPID, ECAppID, PaymentMethodName, status,
	last_update_date, updatedate, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number,needsupdt)
        VALUES
        (l_mid, i_transactionid, i_tangibleid,
      	l_mpayeeid, i_payeeid, i_bepid, i_ecappid, i_pmtmethod, l_status,
	 sysdate, sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1,'Y');

	commit;
     EXCEPTION
    WHEN NO_DATA_FOUND THEN
           raise_application_error(-20000, 'IBY_20300#', FALSE);
     	--raise_application_error(-20300,'Cannot insert cancel trxn into iby_trxn_summaries_all');


    END scheduleSETCancel;
*********/


/*
** Procedure Name : scheduleSETOther
** Purpose : creates an entry for scheduling the SET payments
**           in the iby_trxn_summaries_all and iby_trxn_core and extended
**           tables.  Returns the transactionid created
**           by the system.
**
**           This procedure is used by follow-on transactions (other than cancel) such as
**           capture, credit and subsequent auth
*/
procedure scheduleSETOther( i_ecappid  iby_trxn_summaries_all.ecappid%type,
                      i_payeeid  iby_trxn_summaries_all.payeeid%type,
                      i_bepid    iby_trxn_summaries_all.bepid%type,
                      i_tangibleid iby_trxn_summaries_all.tangibleid%type,
                      i_reqtype iby_trxn_summaries_all.reqtype%type,
                      i_reqdate iby_trxn_summaries_all.reqdate%type,
                      i_reqseq iby_trxn_summaries_all.reqseq%type,
                      i_pmtmethod iby_trxn_summaries_all.paymentmethodname%type,
		      i_desturl iby_trxn_summaries_all.desturl%type,
                      io_transactionid in out nocopy iby_trxn_summaries_all.transactionid%type,
                      i_amount iby_trxn_summaries_all.amount%type,
                      i_currency iby_trxn_summaries_all.currencynamecode%type,
                      i_trxntypeid iby_trxn_summaries_all.trxntypeid%type,
                      i_nlslang iby_trxn_summaries_all.Nlslang%type,
                      i_settledate iby_trxn_summaries_all.settledate%type,
                      i_authtype iby_trxn_core.authtype%type,
                      i_instrid iby_trxn_summaries_all.payerinstrid%type,
		      i_payerid iby_trxn_summaries_all.payerid%type,
                  splitid         iby_trxn_extended.SplitId%type,
                  prevsplitid     iby_trxn_extended.PrevSplitId%type,
                  subauthind      iby_trxn_extended.SubAuthInd%type,
                  batchid         iby_trxn_summaries_all.BatchId%type,
                  batchseqnum     iby_trxn_extended.BatchSeqNum%type,
                  terminalid      iby_trxn_extended.TerminalId%type)
IS

  l_mid	     NUMBER;
  l_tid	     NUMBER;
  -- 0011 indicates PENDING status
  l_status   NUMBER := 0011;

l_mpayeeid iby_payee.mpayeeid%type;
l_mbatchid iby_batches_all.mbatchid%type;
BEGIN
-- First check if this request is not duplicate
   if (requestExists(i_payeeid,i_tangibleid, i_reqtype,i_bepid)) then
           raise_application_error(-20000, 'IBY_20604#', FALSE);
        --raise_application_error(-20604, 'Duplicate Request ' , FALSE);
   end if;

   IF ((UPPER(i_reqtype) = 'ORAPMTREQ') OR
      ( UPPER(i_reqtype) = 'ORAPMTCREDIT'))
   THEN

        if (i_instrid IS NULL or (NOT instrExists(i_instrid, 'CREDITCARD'))) THEN
	   --reject invalid instrid
		raise_application_error(-20000, 'IBY_20512#', FALSE);
	END IF;


   -- Get the transaction id sequence also

       l_tid := iby_transactioncc_pkg.getTID(i_payeeid, i_tangibleid);
	--SELECT iby_trxnsumm_trxnid_s.NEXTVAL
        --INTO l_tid
        --FROM dual;
         io_transactionid := l_tid;
   END IF;
   -- Get the master transaction id sequence for all requests

    SELECT iby_trxnsumm_mid_s.NEXTVAL
    INTO l_mid
    FROM dual;
   -- insert the scheduled request in the summary and core tables
	iby_transactioncc_pkg.getMBatchId(batchid, i_payeeid, l_mbatchid);
	iby_accppmtmthd_pkg.getMPayeeId(i_payeeid, l_mpayeeid);
   INSERT INTO iby_trxn_summaries_all
     (TrxnMID, TransactionID, TangibleID,
      MPayeeID, PayeeID,BEPID, ECAppID, PaymentMethodName,
      PayerID, PayerInstrID, Amount,CurrencyNameCode,
      Status, TrxntypeID, SettleDate, ReqDate, ReqType, ReqSeq, DestUrl,
      Nlslang, MBatchId, BatchId,
	last_update_date, updatedate, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number,needsupdt)
   VALUES
     (l_mid, io_transactionid, i_tangibleid,
      l_mpayeeid, i_payeeid, i_bepid, i_ecappid, i_pmtmethod,
      i_payerid, i_instrid, i_amount, i_currency,
      l_status, i_trxntypeid, i_settledate, sysdate, i_reqtype,
	i_reqseq,i_desturl,
      i_nlslang, l_mbatchid, batchid,
	 sysdate, sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1,'Y');

   INSERT INTO iby_trxn_extended
      (TRXNMID, SplitId, PrevSplitId, SubAuthInd,
       BatchSeqNum, TerminalId,
	last_update_date, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number)
   VALUES
      (l_mid, splitid, prevsplitid, subauthind,
       batchseqnum, terminalid,
	 sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1);

   -- insert the authtype into core table
   INSERT INTO iby_trxn_core
     (TrxnMID, Authtype,
	last_update_date, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number)
   VALUES
     (l_mid, i_authtype,
	 sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1);

	commit;
  END scheduleSETOther;
/*
** Procedure Name : scheduleSETbatch
** Purpose : creates an entry for scheduling the CreditCard batch requests
**           in the iby_batches_all table.
**
** Parameters:
**
**    In  : i_ecappid, i_payeeid, i_bepid, i_batchid,
**          i_reqtype, i_reqdate, i_pmtmethod,
**          i_nlslang, i_terminalid
**
*/
procedure scheduleSETbatch(i_ecappid iby_batches_all.ecappid%type,
                          i_payeeid iby_batches_all.payeeid%type,
                          i_bepid iby_batches_all.bepid%type,
                          i_batchid iby_batches_all.batchid%type,
                          i_reqtype iby_batches_all.reqtype%type,
                          i_reqdate iby_batches_all.reqdate%type,
                          i_pmtmethod iby_batches_all.paymentmethodname%type,
			  i_desturl iby_batches_all.desturl%type,
                          i_nlslang iby_batches_all.nlslang%type,
                          i_terminalid iby_batches_all.terminalid%type)
  IS

  l_mpayeeid iby_payee.mpayeeid%type;
  l_mbatchid iby_batches_all.mbatchid%type;
  BEGIN
  -- call procedure to check if this is duplicate request
   if (batchExists(i_payeeid, i_batchid, i_reqtype)) then
           raise_application_error(-20000, 'IBY_20604#', FALSE);
        --raise_application_error(-20604, 'Duplicate Request ' , FALSE);
   end if;

  -- insert the request into the batch table
     SELECT iby_batches_s.NEXTVAL
     INTO l_mbatchid
     FROM dual;
  iby_accppmtmthd_pkg.getMPayeeId(i_payeeid, l_mpayeeid);
 -- Bug: 8363526: Inserted new column settledate for tableiby_batches_all
  INSERT INTO iby_batches_all
   (MBatchID, BatchID, MPayeeID, PayeeID, BEPID, ECAppID,
    ReqType, ReqDate, DestUrl, PaymentMethodName,
    Nlslang, TerminalID,
	last_update_date, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number,settledate)
  VALUES
   (l_mbatchid, i_batchid, l_mpayeeid, i_payeeid, i_bepid, i_ecappid,
    i_reqtype, sysdate, i_desturl, i_pmtmethod,
    i_nlslang, i_terminalid,
	 sysdate, fnd_global.user_id,  sysdate, fnd_global.user_id,
	fnd_global.login_id, 1,sysdate);


	commit;
END scheduleSETbatch;



FUNCTION requestExists(i_payeeid iby_trxn_summaries_all.payeeid%type,
          i_tangibleid iby_trxn_summaries_all.tangibleid%type,
          i_reqtype iby_trxn_summaries_all.reqtype%type,
          i_bepid iby_trxn_summaries_all.bepid%type)
return boolean
is
l_cnt int;
BEGIN
/*
** get the count of the rows with same request type, tangibleid and
** payeeid. If count is more than 0, it means, request already exists
** otherwise does not exist.
*/
    SELECT count(*)
    INTO l_cnt
    FROM iby_trxn_summaries_all
    WHERE payeeId = i_payeeid
    AND tangibleid = i_tangibleid
    AND UPPER(reqType) = UPPER(i_reqtype)
    AND bepid = i_bepid
    --AND ( status = 11 or status = 0 );
    AND STATUS IN ( 0, 11, 12, 13, 18);

    if (l_cnt > 0) then
	return true;
    end if;

    -- count is 0
    -- check for capture case

    if (i_reqtype = 'ORAPMTCAPTURE') then
	SELECT count(*)
	INTO l_cnt
	FROM iby_trxn_summaries_all a, iby_trxn_core b
    	WHERE payeeId = i_payeeid
    	AND tangibleid = i_tangibleid
    	AND UPPER(reqType) = 'ORAPMTREQ'
    	AND bepid = i_bepid
	AND a.trxnmid = b.trxnmid
	AND b.authtype = 'AUTHANDCAPTURE'
    	AND ( status = 11);  -- didn't need status 0

	if (l_cnt > 0) then
		return true;
	end if;
    end if;

    return false;

END requestExists;


FUNCTION batchExists(i_payeeid iby_batches_all.payeeid%type,
          i_batchid iby_batches_all.batchid%type,
          i_reqtype iby_batches_all.reqtype%type)
return boolean
is
l_cnt int;
BEGIN
/*
** get the count of the rows with same request type, tangibleid and
** payeeid. If count is more than 0, it means, request already exists
** otherwise does not exist.
*/
    SELECT count(*)
    INTO l_cnt
    FROM iby_batches_all
    WHERE payeeId = i_payeeId
    AND batchId = i_batchid
    AND UPPER(reqType) = UPPER(i_reqType)
    AND (batchstatus = 11 or batchstatus = 0);
    if ( l_cnt = 0 ) then
        return false;
    else
        return true;
    end if;
END batchExists;


/*
** Function: instrExists.
** Purpose: Check if the specified instrid exists or not.
*/
function instrExists(i_instrid in
		iby_trxn_summaries_all.payerinstrid%type,
		i_instrtype in iby_trxn_summaries_all.instrtype%type)

return boolean

IS
l_instrid iby_creditcard.instrid%type;
l_flag boolean := false;

cursor c_cc
(ci_instrid iby_creditcard.instrid%type)
is
  SELECT instrid
  FROM iby_creditcard_v
  WHERE instrid = ci_instrid;


cursor c_pc
(ci_instrid iby_creditcard.instrid%type)
is
  SELECT instrid
  FROM iby_purchasecard_v
  WHERE instrid = ci_instrid;

begin
    if ( c_pc%isopen) then
        close c_pc;
    end if;

    IF i_instrtype = 'CREDITCARD' THEN
	    if ( c_cc%isopen) then
        	close c_cc;
	    end if;
	    open c_cc( i_instrid);
	    fetch c_cc into l_instrid;
	    l_flag := c_cc%found;

	    close c_cc;
    ELSE
	    if ( c_pc%isopen) then
        	close c_pc;
	    end if;
	    open c_pc( i_instrid);

	    fetch c_pc into l_instrid;
	    l_flag := c_pc%found;

	    close c_pc;
    END IF;

	return l_flag;
end instrExists;


END iby_offlinedb_pkg;

/
