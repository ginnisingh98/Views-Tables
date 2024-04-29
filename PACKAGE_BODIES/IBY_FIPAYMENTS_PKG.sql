--------------------------------------------------------
--  DDL for Package Body IBY_FIPAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FIPAYMENTS_PKG" as
/*$Header: ibyfipmb.pls 120.17.12010000.3 2008/12/18 00:28:22 svinjamu ship $*/


/*
* Procedure: checkInstrId
* Purpose: raise exception if instrid doesn't exist
*
*
*/
procedure checkInstrId(i_instrid in  iby_ext_bank_accounts_v.ext_bank_account_id%TYPE)
is
  l_instrid iby_ext_bank_accounts_v.ext_bank_account_id%TYPE;

  cursor c_bk(ci_instrid iby_ext_bank_accounts_v.ext_bank_account_id%TYPE)
	is
         SELECT ext_bank_account_id
          FROM iby_ext_bank_accounts
          WHERE ext_bank_account_id = ci_instrid;

begin
    if ( c_bk%isopen) then
        close c_bk;
    end if;

    open c_bk( i_instrid);
    fetch c_bk into l_instrid;

    if (c_bk%notfound) then
	raise_application_error(-20000, 'IBY_20512#', FALSE);
    end if;
    close c_bk;

end checkInstrId;


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
            i_splitId in iby_trxn_fi.splitId%type,
            i_org_id in iby_trxn_summaries_all.org_id%type,
            i_org_type in iby_trxn_summaries_all.org_type%type,
            i_bnfcryinstrid in iby_trxn_summaries_all.payeeinstrid%type,
            i_custacctid in iby_trxn_summaries_all.cust_account_id%type,
            i_acctsiteid in iby_trxn_summaries_all.acct_site_id%type,
            i_acctsiteuseid in iby_trxn_summaries_all.acct_site_use_id%type,
            i_profilecode in iby_trxn_summaries_all.process_profile_code%type,
            io_tid in out nocopy iby_trxn_summaries_all.transactionid%type)
is

l_mtangibleid iby_tangible.mtangibleid%type;
l_tmid iby_trxn_summaries_all.trxnmid%type;
l_old_tmid iby_trxn_summaries_all.trxnmid%type;
l_tid iby_trxn_summaries_all.transactionId%type;
l_mpayeeid iby_payee.mpayeeid%type;
l_reference_code  iby_trxn_summaries_all.proc_reference_code%type;
l_reference_amount iby_trxn_summaries_all.amount%type;
l_status   iby_trxn_summaries_all.status%type;
l_beptype  iby_bepinfo.bep_type%type;
l_trxntypeid iby_trxn_summaries_all.trxntypeid%TYPE;
l_reqtype iby_trxn_summaries_all.reqtype%TYPE;

l_settle_cust_ref iby_trxn_summaries_all.
                      settlement_customer_reference%TYPE;
l_first_trx_flag  iby_trxn_summaries_all.first_trxn_flag%TYPE;

l_cnt NUMBER := 0;

cursor c_tmid is
select iby_trxnsumm_mid_s.nextval
from dual;

cursor c_reference(ci_tangible_id iby_trxn_summaries_all.tangibleid%type) is
select proc_reference_code, amount
from iby_trxn_summaries_all
where tangibleid= ci_tangible_id
--and  trxntypeid=20
--and  status=0
order by trxnmid desc;

cursor c_settle_exists  is
select trxnmid, mtangibleid
from iby_trxn_summaries_all
where tangibleid=i_tangibleid
and payeeid=i_payeeid
and bepid=i_bepid
and bepkey=i_bepkey
and trxntypeid is null
order by trxnmid desc;

begin

   l_reqtype := i_reqtype;

   -- for bills receivable
   IF (NVL(i_instrid,0) <> 0) THEN
     checkInstrId(i_instrid);
   END IF;
   if(i_bnfcryinstrid <> NULL) then
      checkInstrId(i_bnfcryinstrid);
   end if;

/*
** call requestExist method to check whether request already exists
** or not. if exists, then raise an application error.
*/
    if ( not requestExists(i_payeeid, i_tangibleid, i_splitId, i_reqtype) ) then
        --open c_tid;
        --fetch c_tid into l_tid;
        --close c_tid;
       l_tid := iby_transactioncc_pkg.getTID(i_payeeid, i_tangibleid);


/*
** if cursor is already open then close it.
*/
        if ( c_tmid%isopen ) then
             close c_tmid;
        end if;
        --if ( c_tid%isopen ) then
             --close c_tid;
        --end if;
/*
** open the cursor to get the next available transaction id.
*/
        open c_tmid;
        fetch c_tmid into l_tmid;
        close c_tmid;
        --open c_tid;
        --fetch c_tid into l_tid;
        --close c_tid;
/*
** Make entry in the payments table.
*/


	iby_accppmtmthd_pkg.getMPayeeId(i_payeeid, l_mpayeeid);

        /*
         * Get the bep type based on the bep id.
         * This is used to determine what value to
         * insert for transaction status.
         */
        SELECT NVL(bep_type,iby_bepinfo_pkg.C_BEPTYPE_GATEWAY)
        INTO   l_beptype
        FROM   IBY_BEPINFO
        WHERE  (bepid=i_bepid);

        IF (l_beptype = iby_bepinfo_pkg.C_BEPTYPE_GATEWAY) THEN
            /*
             * For gateways, pending = status 11
             */
            l_status := 11;
        ELSE
            /*
             * For processors, pending = status 100
             */
            l_status := 100;
            -- expected by new batch grouping program- bug # 6125789
            l_trxntypeid := 100;
            l_reqtype := 'ORAPMTEFTCLOSEBATCH';
        END IF;

 /* now get the reference code*/

 if ( c_reference%isopen ) then
             close c_reference;
        end if;

     open c_reference(i_tangibleid);
     fetch c_reference into l_reference_code, l_reference_amount;
     close c_reference;

        /*
         * Some direct debit formats require the debtors
         * reference on the transaction. The debtors reference
         * is the mandate signed between the merchant and the
         * customer.
         *
         * AR does not hat a source for this field in FP.G.
         * In order to minimize the impact, this field is picked
         * up from HZ_CUST_ACCOUNTS.ACCOUNT_NAME.
         */
        BEGIN

            IF (i_custacctid IS NOT NULL) THEN

                SELECT
                    hz.account_name
                INTO
                    l_settle_cust_ref
                FROM
                    HZ_CUST_ACCOUNTS hz
                WHERE
                    hz.cust_account_id = i_custacctid
                ;

            END IF;

        EXCEPTION
            WHEN OTHERS THEN

            /*
             * If no rows or found or if multiple rows
             * are found, we will not be able to get the
             * settlement reference.
             *
             * This is ok. This will be caught during the
             * validation of the payment message, and the
             * transaction will be failed.
             *
             * Handle the exception gracefully here.
             */

            NULL;

        END;

        /*
         * Some payment systems (e.g., Citibank) need to
         * know whether a transaction is a first direct debit
         * for a particular payer.
         *
         * Determining whether this is the first direct debit
         * by looking up the trxns table for this (payee, payer)
         * combination and checking whether any direct debit
         * transactions exist.
         */
        BEGIN

            SELECT
                COUNT(*)
            INTO
                l_cnt
            FROM
                IBY_TRXN_SUMMARIES_ALL trxn
            WHERE
                trxn.mpayeeid     = l_mpayeeid    AND
                trxn.instrtype    = 'BANKACCOUNT' AND
                trxn.instrsubtype = 'ACH'         AND
                trxn.payerid      = i_payerid
            ;

            /*
             * If count of existing transactions for this
             * payer is 0, this is the first direct debit
             * for this payer.
             */
            IF (l_cnt = 0) THEN
                l_first_trx_flag := 'Y';
            ELSE
                l_first_trx_flag := 'N';
            END IF;

        EXCEPTION
            WHEN OTHERS THEN

            /*
             * Handle error situations gracefully.
             * Assume that this is not the first debit
             * for this payer.
             */
            l_first_trx_flag := 'N';

        END;



/*
** if cursor is already open then close it.
*/
        if ( c_settle_exists%isopen ) then
             close c_settle_exists;
        end if;

/*
** open the cursor to get the next available transaction id.
*/
        open c_settle_exists;
        fetch c_settle_exists into l_old_tmid, l_mtangibleid;


    if(c_settle_exists%NOTFOUND)  then

/*
** call createBill procedure in iby_bill_pkg to create tangible in the
** database.
*/
-- the order_medium and eftauthmethod are not relevant for fi payments


        iby_bill_pkg.createBill(i_tangibleid, i_billAmount,
                                i_billCurDef, i_billAcct,i_billRefInfo,
                                i_billMemo, i_billOrderMedium, i_billEftAuthMethod, l_mtangibleid);


        insert into iby_trxn_summaries_all
                             ( trxnMId, transactionId, tangibleid,
                               mpayeeid, payeeid, payeeinstrid,
                               bepid, bepkey, ecappid, org_id, org_type,
                               paymentMethodname, payerid, payerinstrid,
                               amount, currencyNameCode, reqdate,
                               reqtype, status, settledate,
                               mtangibleId, nlslang, instrtype, instrsubtype,
                               last_update_date, updatedate, last_updated_by,
                               creation_date, created_by,
                               last_update_login, object_version_number,
                               proc_reference_code, proc_reference_amount,
                               cust_account_id, acct_site_id, acct_site_use_id,
                               settlement_customer_reference, first_trxn_flag,
                               process_profile_code, trxntypeid,needsupdt
                             )

        values ( l_tmid, l_tid, i_tangibleid, l_mpayeeid,
                 i_payeeid, i_bnfcryinstrid, i_bepid,
                 i_bepkey, i_ecappid, i_org_id, i_org_type, i_pmtMethod,
                 i_payerid, i_instrid, i_billamount,
                 i_billcurDef, i_reqdate, l_reqtype,
                 l_status, i_scheddate, l_mtangibleid, i_nlslang,
                 'BANKACCOUNT', 'ACH',
                 sysdate, sysdate, fnd_global.user_id,
                 sysdate, fnd_global.user_id,
                 fnd_global.login_id, 1, l_reference_code, l_reference_amount,
                 i_custacctid, i_acctsiteid, i_acctsiteuseid,
                 l_settle_cust_ref, l_first_trx_flag, i_profilecode,
                 l_trxntypeid,'Y'
                );

/*
** After everything is successful then create an entry in the
** iby_request table.
*/
        insert into iby_trxn_fi
                    (trxnMid, psreqid, splitId,
		last_update_date, last_updated_by,
		creation_date, created_by,
		last_update_login, object_version_number)
        values ( l_tmid, i_psreqid, i_splitId,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);
        io_tid := l_tid;

else
   -- Update iby_tangible table

      iby_bill_pkg.modBill(
           l_mtangibleid,               -- IN i_mtangibleid
           i_tangibleid,                -- IN i_billId
           i_billamount,                    -- IN i_billAmount
           i_billCurDef,                  -- IN i_billCurDef
           i_billAcct,                    -- IN i_billAcct
           i_billRefInfo,                   -- IN i_billRefInfo
           i_billMemo,                      -- IN i_billMemo
           i_billOrderMedium,               -- IN i_billOrderMedium
           i_billEftAuthMethod);            -- IN i_billEftAuthMethod


     UPDATE iby_trxn_summaries_all
          SET
              org_id                = i_org_id,
              ecappid               = i_ecappid,
              payeeid               = i_payeeid,
              bepid                 = i_bepid,
              bepkey                = i_bepkey,
              paymentMethodname     = i_pmtmethod,
              payerid               = i_payerid,
              payerinstrid          = i_instrid,
              amount                = i_billamount,
              currencyNameCode      = i_billcurDef,
              status                = l_status,
              cust_account_id       = i_custacctid,
              acct_site_id          = i_acctsiteid,
              acct_site_use_id      = i_acctsiteuseid,
              last_update_date      = sysdate,
              updatedate            = sysdate,
              last_updated_by       = fnd_global.user_id,
              creation_date         = sysdate,
              created_by            = fnd_global.user_id,
              last_update_login     = fnd_global.user_id,
              object_version_number = object_version_number+1,
              settlement_customer_reference = l_settle_cust_ref,
              first_trxn_flag       = l_first_trx_flag
        WHERE trxnmid               = l_old_tmid;
end if;

     close c_settle_exists;
     io_tid := l_tid;
    else
        raise_application_error(-20000, 'IBY_20560#', FALSE);
        --raise_application_error(-20560, 'Duplicate Request ' , FALSE);
    end if;
    commit;
end createPayment;


Function requestExists(i_tid iby_trxn_summaries_all.transactionId%type,
          i_reqtype iby_trxn_summaries_all.reqtype%type)
return boolean
is
l_cnt int;
begin
/*
** get the count of the rows with same request type, tangibleid and
** payeeid. If count is more than 0, it means, request already exists
** otherwise does not exist.
*/
    select count(*) into l_cnt
    from iby_trxn_summaries_all s
    where transactionId = i_tid
    and reqType = i_reqType;

    -- and status = 0

    if ( l_cnt = 0 ) then
        return false;
    else
        return true;
    end if;
end requestExists;


Function requestExists(i_payeeid iby_trxn_summaries_all.payeeid%type,
          i_tangibleid iby_trxn_summaries_all.tangibleid%type,
          i_splitId in iby_trxn_fi.splitId%type,
          i_reqtype iby_trxn_summaries_all.reqtype%type)
return boolean
is
l_cnt int;
begin
/*
** get the count of the rows with same request type, tangibleid and
** payeeid. If count is more than 0, it means, request already exists
** otherwise does not exist.
*/
    select count(*)  into l_cnt
    from iby_trxn_summaries_all s
    where payeeId = i_payeeId
    and tangibleid = i_tangibleId
    and UPPER(reqType) = UPPER(i_reqType)
    and trxntypeid not in (20);
    --and i_splitId in ( select splitId
                     --from iby_trxn_fi f
                     --where f.trxnmid = s.trxnmid);
    -- The 'AND' condition for the splitId is removed as we do not use
    -- splitId anymore.

    if ( l_cnt = 0 ) then
        return false;
    else
        return true;
    end if;
end requestExists;
/*
**  Procedure: CanModify.
**  Purpose:   Checks whether particular transaction specified
**             can be modified or not.
**  In Params: i_tid, transaction id.
**  out Params: boolean , true if it can be modified otherwise false.
*/
function canModifyorCancel(i_tid in iby_trxn_summaries_all.transactionId%type)
return boolean
is
l_cnt int;
begin
    select count(*) into l_cnt
    from iby_trxn_summaries_all s
    where transactionId = i_tid
    and (( (reqtype = 'ORAPMTREQ' or reqtype = 'ORAPMTCREDIT') and (status <> -99 and status <> 100)) or
          (reqtype = 'ORAPMTCANC'));
    if ( l_cnt = 0 ) then
        return true;
    else
        return false;
    end if;
end canModifyOrCancel;

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
            i_tid in iby_trxn_summaries_all.transactionid%type,
	    i_org_id in iby_trxn_summaries_all.org_id%type)
is
l_mtangibleid iby_tangible.mtangibleid%type;
l_tmid iby_trxn_summaries_all.trxnmid%type;
l_tangibleid iby_trxn_summaries_all.tangibleid%type;
l_reqtype iby_trxn_summaries_all.reqtype%type;

l_mpayeeid iby_payee.mpayeeid%type;

cursor c_tmid is
select iby_trxnsumm_mid_s.nextval
from dual;

cursor c_mtangibleid(ci_tid in iby_trxn_summaries_all.transactionid%type)
is
select mtangibleid , tangibleid
from iby_trxn_summaries_all
where transactionId = ci_tid
group by mtangibleid , tangibleid;
l_splitId iby_trxn_fi.splitId%type;
begin

   IF (NVL(i_instrid,0) <> 0) THEN
     checkInstrId(i_instrid);
   END IF;
/*
** call requestExist method to check whether request already exists
** or not. if exists, then raise an application error.
*/
    if ( canModifyOrCancel(i_tid) ) then
/*
** if payee account does not exists then raise an exception.
*/
        if ( not iby_payee_pkg.payeeExists( i_ecappid, i_payeeid) ) then
	        raise_application_error(-20000, 'IBY_20305#', FALSE);
            --raise_application_error(-20305, 'Payee Not Found ', FALSE);
        end if;
/*
** call createBill procedure in iby_bill_pkg to create tangible in the
** database.
*/
        if ( c_mtangibleid%isopen ) then
            close c_mtangibleid;
        end if;
        open c_mtangibleid(i_tid);
        fetch c_mtangibleid into l_mtangibleid, l_tangibleid;
        close c_mtangibleid;
        if ( l_tangibleid <> i_tangibleid ) then
	        raise_application_error(-20000, 'IBY_20561#', FALSE);
            --raise_application_error(-20561, 'Tangible Id should Match',
                                    --TRUE);
        end if;
        iby_bill_pkg.createBill(i_tangibleid, i_billAmount,
                                i_billCurDef, i_billAcct,i_billRefInfo,
                                i_billMemo, i_billOrdermedium,
                                i_billEftAuthMethod, l_mtangibleid);

/*
** open the cursor to get the next available transaction id.
*/
        open c_tmid;
        fetch c_tmid into l_tmid;
        close c_tmid;

/*
** get the reqtype
*/
   select reqtype into l_reqtype from iby_trxn_summaries_all
   WHERE transactionId = i_tid and status = 100
   and (reqtype = 'ORAPMTREQ' or reqtype = 'ORAPMTCREDIT');


/*
** update the transactions table with the new data.
*/
        update iby_trxn_summaries_all
        set status  = -99,
	    last_update_date = sysdate,
     updatedate = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
        where transactionId = i_tid
        and (reqtype = 'ORAPMTREQ' or reqtype = 'ORAPMTCREDIT')
        and status = 100;


-- // pending requests...

        select splitId  into l_splitId
        from iby_trxn_fi
        where trxnmid in ( select trxnmid
                           from iby_trxn_summaries_all
                           where transactionId =  i_tid)
        and rownum < 2;
/*
** Make entry in the payments table.
*/
	iby_accppmtmthd_pkg.getMPayeeId(i_payeeid, l_mpayeeid);
        insert into iby_trxn_summaries_all
                             ( trxnMId, transactionId, tangibleid,
                                  mpayeeid, payeeid,  bepid, bepkey, ecappid,
				  org_id, paymentMethodname,
                                  payerid, payerinstrid, amount,
                                  currencyNameCode,
                                  reqdate, reqtype, status, settledate,
                                  mtangibleId, nlslang, instrtype,
				last_update_date, updatedate, last_updated_by,
				creation_date, created_by,
				last_update_login, object_version_number,needsupdt)

        values ( l_tmid, i_tid, i_tangibleid, l_mpayeeid, i_payeeid,
                 i_bepid, i_bepkey, i_ecappid, i_org_id, i_pmtMethod,
		 i_payerid, i_instrid,
                 i_billamount, i_billcurDef, i_reqdate,
                 l_reqtype, 100, i_scheddate, l_mtangibleid, i_nlslang,
		'BANKACCOUNT',
		 sysdate, sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1,'Y');

/*
** After inserting an entry in transactions_summaries_all table,
** make an entry in the iby_trxn_fi table, corresponding to
** the transaction master id.
*/
        insert into iby_trxn_fi
                    (trxnMid, psreqid, splitId,
			last_update_date, last_updated_by,
			creation_date, created_by,
			last_update_login, object_version_number)
        values ( l_tmid, i_psreqid, l_splitId,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);
    else
/*
** if modification is not allowed then raise an exception.
*/
	--can't modify/cancel when request not pending
	  raise_application_error(-20000, 'IBY_41516#', FALSE);
	        --raise_application_error(-20000, 'IBY_20562#', FALSE);
        --raise_application_error(-20562,'Modification can not be done', FALSE);
    end if;

    commit;
end modifyPayment;
/*
** Procedure: deletePayment.
** Purpose: Marks the payment whose id matches the tid passed as
**          'CANCELLED'.
*/
-- procedure deletePayment(i_ecappid in iby_ecapp.ecappid%type,
procedure deletePayment( i_tid in iby_trxn_summaries_all.transactionId%type )
is
l_old_tmid iby_trxn_summaries_all.trxnmid%type;
l_new_tmid iby_trxn_summaries_all.trxnmid%type;
l_tid iby_trxn_summaries_all.transactionId%type;
l_status iby_trxn_summaries_all.status%type;

cursor c_tmid is
select iby_trxnsumm_mid_s.nextval
from dual;

cursor getLatestTMID(ci_tid in iby_trxn_summaries_all.transactionId%type) is
select trxnmid , status
from iby_trxn_summaries_all s
where transactionid=ci_tid
and status = 100
-- // status for pending.
and (reqtype = 'ORAPMTREQ' or reqtype = 'ORAPMTCREDIT');

begin
/*
** if request already exists, then raise an Exception.
*/
    --if ( requestExists(i_tid, 'ORAPMTCANC') ) then
	--  raise_application_error(-20000, 'IBY_20563#', FALSE);
        --raise_application_error(-20563, 'Payment is already cancelled', FALSE);
    --end if;
/*
** Check if the request can be cancelled or not. If not raise
** error.
*/
    if ( canModifyOrCancel(i_tid) ) then
/*
** make the earlier transaction entry as invlid, create another
** entry with same information, but cahnge status to -1.
*/
        open getLatestTMID(i_tid);
        fetch getLatestTMID into l_old_tmid, l_status;
        if ( getLatestTMID%notfound ) then
            close getLatestTMID;
	  	raise_application_error(-20000, 'IBY_20564#', FALSE);
            --raise_application_error(-20564,'No PmtReq request before.', FALSE);
        end if;
        close getLatestTMID;
/*
** Get Master transaction Id, if cursor is already open then close it.
*/
        if ( c_tmid%isopen ) then
             close c_tmid;
        end if;
        open c_tmid;
        fetch c_tmid into l_new_tmid;
        close c_tmid;
/*
** update the transactions table with the new data.
*/
        update iby_trxn_summaries_all
        set status  = -99,
	    last_update_date = sysdate,
     updatedate = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = 1
        where transactionId = i_tid
        and (reqtype = 'ORAPMTREQ' or reqtype = 'ORAPMTCREDIT');

/*
** Insert record, with values that of latest record and increment the
** tid value by 1.
*/
        insert into iby_trxn_summaries_all
                             ( trxnMId, transactionId, tangibleid,
                                  mpayeeid, payeeid,  bepid, ecappid,
				  org_id, paymentMethodname,
                                  payerid, payerinstrid,
				  amount, currencyNameCode,
                                  reqdate, reqtype, status,
                                  mtangibleId, nlslang, instrtype,
				last_update_date, updatedate, last_updated_by,
				creation_date, created_by,
				last_update_login, object_version_number,needsupdt)

        select l_new_tmid, transactionId, tangibleid,
                                  mpayeeid, payeeid,  bepid, ecappid,
				  org_id, paymentMethodname,
				  payerid, payerinstrid,
                                  amount, currencyNameCode,
                                  sysdate, 'ORAPMTCANC', 14,
                                  mtangibleId, nlslang, 'BANKACCOUNT',
		 		 sysdate, sysdate, fnd_global.user_id,
				 sysdate, fnd_global.user_id,
				fnd_global.login_id, 1,'Y'
        from iby_trxn_summaries_all
        where trxnmid = l_old_tmid;


        insert into iby_trxn_fi
                    (trxnMid, psreqid, splitId,
				last_update_date, last_updated_by,
				creation_date, created_by,
				last_update_login, object_version_number)

        select l_new_tmid, psreqid, splitId,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1
        from iby_trxn_fi
        where trxnmid = l_old_tmid;

    else
	-- can't modify/cancel when not pending
	  raise_application_error(-20000, 'IBY_41516#', FALSE);
	  --raise_application_error(-20000, 'IBY_20560#', FALSE);
        --raise_application_error(-20560, 'Duplicate Request ', FALSE);
    end if;
    commit;
end deletePayment;


/*
* Procedure: setTrxnStatus
* Purpose: Modify the status of the transaction
*
*/

procedure setTrxnStatus(i_tmid in iby_trxn_summaries_all.trxnmid%type,
                        i_status in iby_trxn_summaries_all.status%type)
is

begin

     update iby_trxn_summaries_all
     set status=i_status
     where trxnmid=i_tmid;

     commit;

exception
     when others then
     raise_application_error(-20000, 'IBY_20400#', FALSE);

end setTrxnStatus;

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
 )
is
l_old_tmid iby_trxn_summaries_all.trxnmid%type;
l_new_tmid iby_trxn_summaries_all.trxnmid%type;
l_tid iby_trxn_summaries_all.transactionId%type;
l_status iby_trxn_summaries_all.status%type;
l_reference_code iby_trxn_summaries_all.proc_reference_code%type;
l_trxn_exists     VARCHAR2(1);
cursor c_tmid is
select iby_trxnsumm_mid_s.nextval
from dual;

 CURSOR trxn_exists IS
  SELECT 'Y', trxnmid
    FROM iby_trxn_summaries_all s
   WHERE transactionid=i_tid
   AND  trxntypeid=5
    AND status <> '0'
     ORDER BY reqdate desc;

cursor getLatestTMID(ci_tid in iby_trxn_summaries_all.transactionId%type) is
select trxnmid , status, proc_reference_code
from iby_trxn_summaries_all s
where transactionid=ci_tid
and status in ( 0, 100)
-- // status for pending or success.
and (reqtype = 'ORAPMTREQ')
and trxntypeid is null;

begin

    open getLatestTMID(i_tid);
        fetch getLatestTMID into l_old_tmid, l_status, l_reference_code;
        if ( getLatestTMID%notfound ) then
            close getLatestTMID;
	  	raise_application_error(-20000, 'IBY_20564#', FALSE);

        end if;
        close getLatestTMID;

/*
** check return request exists or not
*/
  if ( trxn_exists%isopen ) then
             close trxn_exists;
        end if;
  OPEN trxn_exists;
    FETCH trxn_exists INTO l_trxn_exists, l_new_tmid;
    CLOSE trxn_exists;


      IF (NVL(l_trxn_exists, 'N') = 'Y') THEN

       update iby_trxn_summaries_all
       set   currencynamecode=i_currencycode,
             amount=i_amount,
             proc_reference_code=l_reference_code,
             last_update_date      = sysdate,
             updatedate            = sysdate,
             last_updated_by       = fnd_global.user_id,
             last_update_login     = fnd_global.user_id,
              object_version_number = 1
      where trxnmid=l_new_tmid;
else

/*
** Get Master transaction Id, if cursor is already open then close it.
*/
        if ( c_tmid%isopen ) then
             close c_tmid;
        end if;
        open c_tmid;
        fetch c_tmid into l_new_tmid;
        close c_tmid;

/*
** Insert record, with values that of latest record and increment the
** tid value by 1.
*/
        insert into iby_trxn_summaries_all
                             ( trxnMId, transactionId, tangibleid,
                                  mpayeeid, payeeid,  bepid, ecappid,
				  org_id, paymentMethodname,
                                  payerid, payerinstrid,
				  amount, currencyNameCode,
                                  reqdate, reqtype, status,
                                  mtangibleId, nlslang, instrtype,
				last_update_date, updatedate, last_updated_by,
				creation_date, created_by,
				last_update_login, object_version_number,
                                proc_reference_code, proc_reference_amount, trxntypeid, bepkey,needsupdt
                                 ,payment_channel_code,settledate,settlement_due_date)

        select l_new_tmid, transactionId, tangibleid,
                                  mpayeeid, payeeid,  bepid, ecappid,
				  org_id, paymentMethodname,
				  payerid, payerinstrid,
                                  i_amount, i_currencycode,
                                  sysdate, 'ORAPMTRETURN', 9,
                                  mtangibleId, nlslang, 'BANKACCOUNT',
		 		 sysdate, sysdate, fnd_global.user_id,
				 sysdate, fnd_global.user_id,
				fnd_global.login_id, 1,
                                 proc_reference_code, amount, 5, bepkey,'Y'
                              , payment_channel_code,settledate,settlement_due_date
        from iby_trxn_summaries_all
        where trxnmid = l_old_tmid;


        insert into iby_trxn_fi
                    (trxnMid, psreqid, splitId,
				last_update_date, last_updated_by,
				creation_date, created_by,
				last_update_login, object_version_number)

        select l_new_tmid, psreqid, splitId,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1
        from iby_trxn_fi
        where trxnmid = l_old_tmid;

end if;
     io_trxnmid:=l_new_tmid;

    commit;
end createReturnPayment;


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
            i_referenceCode  IN iby_trxn_summaries_all.proc_reference_code%TYPE)
is

begin

    UPDATE iby_trxn_summaries_all
          SET
              status                = i_status,
              bepcode               = i_bepcode,
              bepmessage            = i_bepmessage,
              errorlocation         = i_errorlocation,
              last_update_date      = sysdate,
              last_updated_by       = fnd_global.user_id,
              last_update_login     = fnd_global.user_id,
              object_version_number = 1,
              proc_reference_code   = i_referencecode
        WHERE trxnmid               = i_trxnmid;

     commit;

exception
     when others then
     raise_application_error(-20000, 'IBY_20400#', FALSE);

end updateTrxn;

end iby_fipayments_pkg;

/
