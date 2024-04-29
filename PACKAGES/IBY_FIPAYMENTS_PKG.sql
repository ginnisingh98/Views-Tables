--------------------------------------------------------
--  DDL for Package IBY_FIPAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FIPAYMENTS_PKG" AUTHID CURRENT_USER as
/*$Header: ibyfipms.pls 120.4.12000000.2 2007/06/13 21:02:47 jleybovi ship $*/

/*
**  Procedure: createPayment.
**  Purpose: creates a payment for schedule.
**  Description: Check whether the payment request id is already sent or
**               not. if yes raise an error. Otherwise, check whether
**               user holds the specified instrument or not.
**               Check whether specified payee id exists or not.
**               If all the check are validated then create the
**               tangible, payment and request objects. Status of the payment
**               is marked as PENDING.
**               return the tid of the payments object.
*/
procedure createPayment(i_ecappid in iby_trxn_summaries_all.ecappid%type,
            i_payeeid in iby_trxn_summaries_all.payeeid%type,
            i_instrid in iby_trxn_summaries_all.payerinstrid%type,
            i_payerid in iby_trxn_summaries_all.payerid%type,
            i_tangibleid in iby_trxn_summaries_all.tangibleid%type,
            i_billamount in iby_trxn_summaries_all.amount%type,
            i_billcurDef in iby_trxn_summaries_all.currencynamecode%type,
            i_billAcct in iby_tangible.acctno%type,
            i_billRefInfo in iby_tangible.refinfo%type,
            i_billMemo in iby_tangible.memo%type,
            i_billOrdermedium in iby_tangible.order_medium%TYPE,
            i_billEftAuthMethod in iby_tangible.eft_auth_method%TYPE,
            i_scheddate in iby_trxn_summaries_all.settledate%type,
            i_reqtype in iby_trxn_summaries_all.reqtype%type,
            i_reqdate in iby_trxn_summaries_all.reqdate%type,
            i_bepid    in iby_trxn_summaries_all.bepid%type,
            i_bepkey   in iby_trxn_summaries_all.bepkey%type,
            i_pmtmethod in iby_trxn_summaries_all.paymentmethodname%type,
            i_psreqId in iby_trxn_fi.psreqid%type,
            i_nlslang in iby_trxn_summaries_all.nlslang%type,
            i_splitId in iby_trxn_fi.splitId%type
			DEFAULT 0,
	    i_org_id in iby_trxn_summaries_all.org_id%type,
            i_org_type in iby_trxn_summaries_all.org_type%type,
            i_bnfcryinstrid in iby_trxn_summaries_all.payeeinstrid%type,
            i_custacctid in iby_trxn_summaries_all.cust_account_id%type,
            i_acctsiteid in iby_trxn_summaries_all.acct_site_id%type,
            i_acctsiteuseid in iby_trxn_summaries_all.acct_site_use_id%type,
            i_profilecode in iby_trxn_summaries_all.process_profile_code%type,
            io_tid in out nocopy iby_trxn_summaries_all.transactionid%type);
/*
**  Procedure: modifyPayment.
**  Purpose: modify the payment that matches the tid passed.
**  Description: Check whether the payment request id is already sent or
**               not. if yes raise an error. Otherwise, check whether
**               user holds the specified instrument or not.
**               Check whether specified payee id exists or not.
**               If all the check are validated then create the
**               tangible. Modify the  payment object that payment id matched,
**               then create the request object.
*/
procedure modifyPayment(i_ecappid in iby_ecapp.ecappid%type,
            i_payeeid in iby_trxn_summaries_all.payeeid%type,
            i_instrid in iby_trxn_summaries_all.payerinstrid%type,
            i_payerid in iby_trxn_summaries_all.payerid%type,
            i_tangibleid in iby_trxn_summaries_all.tangibleid%type,
            i_billAmount in iby_trxn_summaries_all.amount%type,
            i_billcurDef in iby_trxn_summaries_all.currencynamecode%type,
            i_billAcct in iby_tangible.acctno%type,
            i_billRefInfo in iby_tangible.refinfo%type,
            i_billMemo in iby_tangible.memo%type,
            i_billOrdermedium in iby_tangible.order_medium%TYPE,
            i_billEftAuthMethod in iby_tangible.eft_auth_method%TYPE,
            i_scheddate in iby_trxn_summaries_all.settledate%type,
            i_reqtype in iby_trxn_summaries_all.reqtype%type,
            i_reqdate in iby_trxn_summaries_all.reqdate%type,
            i_bepid    in iby_trxn_summaries_all.bepid%type,
            i_bepkey   in iby_trxn_summaries_all.bepkey%type,
            i_pmtmethod in iby_trxn_summaries_all.paymentmethodname%type,
            i_psreqId in iby_trxn_fi.psreqid%type,
            i_nlslang in iby_trxn_summaries_all.nlslang%type,
            i_tid in iby_trxn_summaries_all.transactionid%type,
	    i_org_id in iby_trxn_summaries_all.org_id%type);
/*
** Procedure: deletePayment.
** Purpose: Marks the payment whose id matches the tid passed as
**          'CANCELLED'.
*/
-- procedure deletePayment(i_ecappid in iby_ecapp.ecappid%type,
procedure deletePayment(i_tid in iby_trxn_summaries_all.transactionId%type);
/*
** Procedure: requestExists..
** Purpose: check if there is already arequest with same payeeid, tagible
**          id and request type. If it is already there then returns
**          true otherwise returns false.
*/
Function requestExists(i_payeeid iby_trxn_summaries_all.payeeid%type,
          i_tangibleid iby_trxn_summaries_all.tangibleid%type,
          i_splitId in iby_trxn_fi.splitId%type,
          i_reqtype iby_trxn_summaries_all.reqtype%type)
return boolean;
/*
** Procedure: requestExists..
** Purpose: check if there is already arequest with same tid
**          and request type. If it is already there then returns
**          true otherwise returns false.
*/
Function requestExists(i_tid iby_trxn_summaries_all.transactionId%type,
          i_reqtype iby_trxn_summaries_all.reqtype%type)
return boolean;

/*
* Procedure: checkInstrId
* Purpose: raise exception if instrid doesn't exist
*
*
*/
procedure checkInstrId(i_instrid in iby_ext_bank_accounts_v.ext_bank_account_id%TYPE);

/*
* Procedure: setTrxnStatus
* Purpose: Modify the status of the transaction
*
*/

procedure setTrxnStatus(i_tmid in iby_trxn_summaries_all.trxnmid%type,
                        i_status in iby_trxn_summaries_all.status%type);

/*
** Procedure: createReturnPayment.
** Purpose: Create the payment whose id matches the tid passed as
**          'ORAPMTRETURN'.
*/

procedure createReturnPayment(
                 i_tid in iby_trxn_summaries_all.transactionId%type,
                 i_currencycode in iby_trxn_summaries_all.currencynamecode%type,
                 i_amount in iby_trxn_summaries_all.amount%type,
                 io_trxnmid in out nocopy iby_trxn_summaries_all.trxnmid%type
 );

/*
* Procedure: updateTrxn
* Purpose: Update the transaction status with the return results
*
*/

procedure updateTrxn(
            i_trxnmid in iby_trxn_summaries_all.trxnmid%type,
            i_status in iby_trxn_summaries_all.status%type,
            i_bepcode        IN iby_trxn_summaries_all.BEPCode%TYPE,
            i_bepmessage     IN iby_trxn_summaries_all.BEPMessage%TYPE,
            i_errorlocation  IN iby_trxn_summaries_all.errorlocation%TYPE,
            i_referenceCode  IN iby_trxn_summaries_all.proc_reference_code%TYPE);
end iby_fipayments_pkg;

 

/
