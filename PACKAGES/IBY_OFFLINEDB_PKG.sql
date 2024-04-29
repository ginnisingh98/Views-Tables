--------------------------------------------------------
--  DDL for Package IBY_OFFLINEDB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_OFFLINEDB_PKG" AUTHID CURRENT_USER as
/*$Header: ibyoffls.pls 120.2 2005/10/30 05:48:46 appldev ship $*/
/*
** Procedure Name : scheduleCC
** Purpose : creates an entry for scheduling the CreditCard payments
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
                      i_amount iby_trxn_summaries_all.amount%type DEFAULT NULL,
                      i_currency iby_trxn_summaries_all.currencynamecode%type DEFAULT NULL,
		      i_trxntypeid iby_trxn_summaries_all.trxntypeid%type DEFAULT NULL,
		      i_nlslang iby_trxn_summaries_all.Nlslang%type DEFAULT NULL,
                      i_settledate iby_trxn_summaries_all.settledate%type DEFAULT NULL,
		      i_authtype iby_trxn_core.authtype%type DEFAULT NULL,
                      i_instrid iby_trxn_summaries_all.payerinstrid%type
							DEFAULT NULL,
		      i_payerid iby_trxn_summaries_all.payerid%type
							DEFAULT NULL,
			i_org_id iby_trxn_summaries_all.org_id%type
			DEFAULT NULL ,

			i_instrtype iby_trxn_summaries_all.instrtype%type,

                      i_billeracct iby_tangible.acctno%type,
                      i_refinfo iby_tangible.refinfo%type,
                      i_memo iby_tangible.memo%type,
                      i_voiceauthflag iby_trxn_core.voiceauthflag%type DEFAULT NULL,
                      i_authcode iby_trxn_core.authcode%type DEFAULT NULL,
                      i_OrderMedium IN iby_tangible.Order_Medium%TYPE,
                      i_EftAuthMethod IN iby_tangible.Eft_Auth_Method%TYPE
                      );


/*
** Procedure Name : schedulePC
** Purpose : creates an entry for scheduling the PurchaseCard payments
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
                      i_amount iby_trxn_summaries_all.amount%type DEFAULT NULL,
                      i_currency iby_trxn_summaries_all.currencynamecode%type DEFAULT NULL,
		      i_trxntypeid iby_trxn_summaries_all.trxntypeid%type DEFAULT NULL,
		      i_nlslang iby_trxn_summaries_all.Nlslang%type DEFAULT NULL,
                      i_settledate iby_trxn_summaries_all.settledate%type DEFAULT NULL,
		      i_authtype iby_trxn_core.authtype%type DEFAULT NULL,
                      i_instrid iby_trxn_summaries_all.payerinstrid%type
							DEFAULT NULL,
		      i_payerid iby_trxn_summaries_all.payerid%type
							DEFAULT NULL,
			i_org_id iby_trxn_summaries_all.org_id%type
			DEFAULT NULL ,

			i_instrtype iby_trxn_summaries_all.instrtype%type,

                      i_billeracct iby_tangible.acctno%type,
                      i_refinfo iby_tangible.refinfo%type,
                      i_memo iby_tangible.memo%type,
                      i_voiceauthflag iby_trxn_core.voiceauthflag%type DEFAULT NULL,
                      i_authcode iby_trxn_core.authcode%type DEFAULT NULL,
		      i_ponum iby_trxn_core.ponumber%type,
		      i_taxamt iby_trxn_core.taxamount%type,
		      i_shipfromzip iby_trxn_core.shipfromzip%type,
		      i_shiptozip iby_trxn_core.shiptozip%type,
                      i_OrderMedium IN iby_tangible.Order_Medium%TYPE,
                      i_EftAuthMethod IN iby_tangible.Eft_Auth_Method%TYPE
                      );

/*
** Procedure Name : scheduleCCCancel
**   Purpose : creates an entry for a CreditCard cancel request in the
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
				iby_trxn_summaries_all.transactionid%type,
			  i_reqtype_tocancel in iby_trxn_summaries_all.reqtype%type,
			  i_trxntypeid_tocancel in iby_trxn_summaries_all.trxntypeid%type
			   );
/*
** Procedure Name : scheduleCCbatch
** Purpose : creates an entry for scheduling the CreditCard batch requests
**           in the iby_batches_all table.
**
** Parameters:
**
**    In  : i_ecappid, i_payeeid, i_bepid, i_batchid,
**          i_reqtype, i_reqdate, i_pmtmethod,
**	    i_nlslang, i_terminalid
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
			  i_nlslang iby_batches_all.nlslang%type DEFAULT NULL,
			  i_terminalid iby_batches_all.terminalid%type
				DEFAULT NULL,
			  i_schedDate iby_batches_all.batchopendate%type);
/*
** Procedure Name : scheduleSET
** Purpose : creates an entry for scheduling the CreditCard payments
**	     in the iby_trxn_summaries_all and iby_trxn_core
**	     tables.  Returns the transactionid created
**           by the system.
**
** Parameters:
**
**    In  : i_ecappid, i_payeeid, i_bepid, i_tangibleid,
**	    i_reqtype, i_reqdate, i_pmtmethod,
**	    i_amount, i_currency, i_authtype, i_trxntypeid,
**	    i_instrid, i_payerid, i_settledate
**    Out : io_transactionid.
**
*/
procedure scheduleSET( i_ecappid  iby_trxn_summaries_all.ecappid%type,
		      i_payeeid	 iby_trxn_summaries_all.payeeid%type,
		      i_bepid    iby_trxn_summaries_all.bepid%type,
		      i_tangibleid iby_trxn_summaries_all.tangibleid%type,
                      i_reqtype iby_trxn_summaries_all.reqtype%type,
                      i_reqdate iby_trxn_summaries_all.reqdate%type,
                      i_reqseq iby_trxn_summaries_all.reqseq%type,
                      i_pmtmethod iby_trxn_summaries_all.paymentmethodname%type,
		      i_desturl iby_trxn_summaries_all.desturl%type,
                      io_transactionid in out nocopy iby_trxn_summaries_all.transactionid%type,
                      i_amount iby_trxn_summaries_all.amount%type DEFAULT NULL,
                      i_currency iby_trxn_summaries_all.currencynamecode%type DEFAULT NULL,
		      i_trxntypeid iby_trxn_summaries_all.trxntypeid%type DEFAULT NULL,
		      i_nlslang iby_trxn_summaries_all.Nlslang%type DEFAULT NULL,
                      i_settledate iby_trxn_summaries_all.settledate%type DEFAULT NULL,
		      i_authtype iby_trxn_core.authtype%type DEFAULT NULL,
                      i_instrid iby_trxn_summaries_all.payerinstrid%type
							DEFAULT NULL,
		      i_payerid iby_trxn_summaries_all.payerid%type
							DEFAULT NULL,
                  recurringfreq   iby_trxn_extended.RecurringFreq%type DEFAULT NULL,
                  recurringexpdate iby_trxn_extended.RecurringExpDate%type DEFAULT NULL,
                  destpostalcode  iby_trxn_extended.DestPostalCode%type DEFAULT NULL,
                  custrefnum      iby_trxn_extended.CustRefNum%type DEFAULT NULL,
                  localtaxprice   iby_trxn_extended.LocalTaxPrice%type DEFAULT NULL,
                  localtaxcurrency iby_trxn_extended.LocalTaxCurrency%type DEFAULT NULL,
                  authprice       iby_trxn_extended.AuthPrice%type DEFAULT NULL,
                  authcurrency    iby_trxn_extended.AuthCurrency%type DEFAULT NULL,
                  splitshipment   iby_trxn_extended.SplitShipment%type DEFAULT NULL,
                  installtotaltrxns iby_trxn_extended.InstallTotalTrxns%type DEFAULT NULL,
                  splitid         iby_trxn_extended.SplitId%type DEFAULT NULL,
                  batchid         iby_trxn_summaries_all.BatchId%type DEFAULT NULL,
                  batchseqnum     iby_trxn_extended.BatchSeqNum%type DEFAULT NULL,
                  terminalid      iby_trxn_extended.TerminalId%type DEFAULT NULL);
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
                      i_amount iby_trxn_summaries_all.amount%type DEFAULT NULL,
                      i_currency iby_trxn_summaries_all.currencynamecode%type DEFAULT NULL,
                      i_trxntypeid iby_trxn_summaries_all.trxntypeid%type DEFAULT NULL,
                      i_nlslang iby_trxn_summaries_all.Nlslang%type DEFAULT NULL,
                      i_settledate iby_trxn_summaries_all.settledate%type DEFAULT NULL,
                      i_authtype iby_trxn_core.authtype%type DEFAULT NULL,
                      i_instrid iby_trxn_summaries_all.payerinstrid%type
							DEFAULT NULL,
		      i_payerid iby_trxn_summaries_all.payerid%type
							DEFAULT NULL,
                  splitid         iby_trxn_extended.SplitId%type DEFAULT NULL,
                  prevsplitid     iby_trxn_extended.PrevSplitId%type DEFAULT NULL,
                  subauthind      iby_trxn_extended.SubAuthInd%type DEFAULT NULL,
                  batchid         iby_trxn_summaries_all.BatchId%type DEFAULT NULL,
                  batchseqnum     iby_trxn_extended.BatchSeqNum%type DEFAULT NULL,
                  terminalid      iby_trxn_extended.TerminalId%type DEFAULT NULL);


/*
** Procedure Name : scheduleSETCancel
**   Purpose : creates an entry for a CreditCard cancel request in the
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
			   );

*********/


/*
** Procedure Name : scheduleCCbatch
** Purpose : creates an entry for scheduling the CreditCard batch requests
**           in the iby_batches_all table.
**
** Parameters:
**
**    In  : i_ecappid, i_payeeid, i_bepid, i_batchid,
**          i_reqtype, i_reqdate, i_pmtmethod,
**	    i_nlslang, i_terminalid
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
			  i_nlslang iby_batches_all.nlslang%type DEFAULT NULL,
			  i_terminalid iby_batches_all.terminalid%type DEFAULT NULL);
/*
** Function Name: requestExists
** Purpose:  This is a function to check if a particular payment
**	     request such as orapmtreq, oracapture, orareturn etc.
**	     exists for offline transactions
** In	:  i_payeeid, i_tangibleid, i_reqtype
** Out  : boolean to indicate if request exists
*/
function requestExists(i_payeeid iby_trxn_summaries_all.payeeid%type,
          i_tangibleid iby_trxn_summaries_all.tangibleid%type,
          i_reqtype iby_trxn_summaries_all.reqtype%type,
          i_bepid iby_trxn_summaries_all.bepid%type)
return boolean;

/*
** Function Name: batchExists
** Purpose:  This is similar to requestExists above but checks
**	     for duplicate batch requests.
** In   :  i_payeeid, i_batchid, i_reqtype
** Out  : boolean to indicate if request exists
*/
function batchExists(i_payeeid iby_batches_all.payeeid%type,
          i_batchid iby_batches_all.batchid%type,
          i_reqtype iby_batches_all.reqtype%type)
return boolean;


/*
** Function: instrExists.
** Purpose: Check if the specified instrid exists or not.
*/
function instrExists(i_instrid in
		iby_trxn_summaries_all.payerinstrid%type,
			i_instrtype in
		iby_trxn_summaries_all.instrtype%type)

return boolean;


end iby_offlinedb_pkg;

/
