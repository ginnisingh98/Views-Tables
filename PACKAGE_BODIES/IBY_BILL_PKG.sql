--------------------------------------------------------
--  DDL for Package Body IBY_BILL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_BILL_PKG" as
/*$Header: ibybillb.pls 120.1 2004/12/15 16:48:12 syidner ship $*/

/*
** Function: createBill
** Purpose: creates a tangible in iby_bill table.
**          billacct, corresponds to the account number of the payer
**          with payee, billAmount is the amount of the bill,
**          billDtDue due date of the bill,
**          billRefInfo, reference information of the bill
**          Memo, some kind of note. CurDef, definition of the currency,
**          assings the id of the tangible to io_tangibleid.
*/
procedure createBill(i_billId in iby_tangible.tangibleid%type,
                     i_billAmount in iby_tangible.amount%type,
                     i_billCurDef in iby_tangible.currencyNameCode%type,
                     i_billAcct in iby_tangible.acctno%type,
                     i_billRefInfo in iby_tangible.refinfo%type,
                     i_billMemo in iby_tangible.memo%type,
                     i_billOrderMedium IN iby_tangible.Order_Medium%TYPE,
                     i_billEftAuthMethod IN iby_tangible.Eft_Auth_Method%TYPE,
                     io_mtangibleid in out nocopy iby_tangible.Mtangibleid%type)
is
cursor c_getMtangibleid is
select iby_tangible_s.nextval
from dual;
begin
/*
**  close the cursor if it is already open.
*/
    if ( c_getMtangibleid%isopen ) then
        close c_getMtangibleid;
    end if;
/*
** open the cursor. Get the tangible id.
*/
    open c_getMtangibleid;
    fetch c_getMtangibleid into io_mtangibleid;
    close c_getMtangibleid;
/*
**  insert tangible information in iby_bill table.
*/
    insert into iby_tangible( mtangibleId, tangibleid, amount,
                              currencyNameCode, acctno, refinfo, memo,issuedate,
                              Order_Medium, Eft_Auth_Method,
			      last_update_date, last_updated_by,
                              creation_date, created_by,
			      last_update_login, object_version_number)
    values ( io_Mtangibleid, i_billId, i_billAmount, i_billCurDef,
             i_billAcct, i_billRefInfo, i_billMemo, sysdate,
             i_billOrderMedium, i_billEftAuthMethod,
             sysdate, fnd_global.user_id,
	     sysdate, fnd_global.user_id,
	     fnd_global.login_id, 1);

end createBill;
/*
** Function: modBill
** Purpose: retrieves a tangible from iby_tangible table for a given mtangibleid.
**          billacct, corresponds to the account number of the payer
**          with payee, billAmount is the amount of the bill,
**          billRefInfo, reference information of the bill
**          Memo, note from biller. CurDef, definition of the currency,
*/
procedure modBill(   i_mtangibleid in iby_tangible.Mtangibleid%type,
                     i_billId in iby_tangible.tangibleid%type,
                     i_billAmount in iby_tangible.amount%type,
                     i_billCurDef in iby_tangible.currencyNameCode%type,
                     i_billAcct in iby_tangible.acctno%type,
                     i_billRefInfo in iby_tangible.refinfo%type,
                     i_billMemo in iby_tangible.memo%type,
                     i_billOrderMedium IN iby_tangible.Order_Medium%TYPE,
                     i_billEftAuthMethod IN iby_tangible.Eft_Auth_Method%TYPE)
is
begin
    update iby_tangible
    set amount                = i_billAmount,
        currencyNameCode      = i_billCurDef,
        acctno                = i_billAcct,
        refinfo               = i_billRefInfo,
        memo                  = i_billMemo,
        Order_Medium          = i_billOrderMedium,
        Eft_Auth_Method       = i_billEftAuthMethod,
	last_update_date      = sysdate,
	last_updated_by       = fnd_global.user_id,
	last_update_login     = fnd_global.login_id,
	object_version_number = 1
    where mtangibleId = i_mtangibleid
    and tangibleId = i_billId;

/*
**  if no data found then raise an exception.
*/
    if ( sql%notfound ) then
       	raise_application_error(-20000, 'IBY_20530#', FALSE);
        --raise_application_error(-20530, 'Id of the Tangible has not matched or Tangible not found ' , FALSE );
    end if;


end modBill;
end iby_bill_pkg;

/
