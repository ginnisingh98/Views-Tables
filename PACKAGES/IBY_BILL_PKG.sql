--------------------------------------------------------
--  DDL for Package IBY_BILL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_BILL_PKG" AUTHID CURRENT_USER as
/*$Header: ibybills.pls 120.2 2005/08/19 01:13:56 jleybovi ship $*/

G_MAX_TANGIBLEID_LEN CONSTANT NUMBER := 80;

/*
** Function: createBill
** Purpose: creates a tangible in iby_bill table.
**          billacct, corresponds to the account number of the payer
**          with payee, billAmount is the amount of the bill,
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
                     io_mtangibleid in out nocopy iby_tangible.Mtangibleid%type);
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
                     i_billEftAuthMethod IN iby_tangible.Eft_Auth_Method%TYPE);
end iby_bill_pkg;

 

/
