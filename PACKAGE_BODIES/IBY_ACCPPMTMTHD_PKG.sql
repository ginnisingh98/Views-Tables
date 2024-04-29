--------------------------------------------------------
--  DDL for Package Body IBY_ACCPPMTMTHD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_ACCPPMTMTHD_PKG" as
/*$Header: ibyacpmb.pls 115.7 2002/11/15 23:45:00 jleybovi ship $*/

/*
** Procedure: getMPayeeId
** Purpose: retrieve mpayeeid from iby_payee table based on payeeid
*/
Procedure getMPayeeId(i_payeeid in iby_payee.payeeid%type,
			o_mpayeeid out nocopy iby_payee.mpayeeid%type)
is
  cursor  c_get_mpayeeid(ci_payeeid iby_payee.payeeid%type) is
  SELECT mpayeeid from iby_payee
  WHERE payeeid = ci_payeeid;
BEGIN
  open c_get_mpayeeid(i_payeeid);
  fetch c_get_mpayeeid into o_mpayeeid;
    if ( c_get_mpayeeid%notfound ) then
        --raise_application_error(-20305, 'Payee not registered', FALSE);
	raise_application_error(-20000, 'IBY_20305#', FALSE);
    end if;
END;

/*
** Function: pmtMthdExists.
** Purpose: Check if the specified payeeid and pmtmethod  exists or not.
*/
function pmtMthdExists(i_ecappid in iby_accppmtmthd.ecappid%type,
		     i_payeeid in iby_accppmtmthd.payeeid%type,
		     i_instrtype in iby_accttype.instrtype%type,
                     i_accttype  in iby_accttype.accttype%type,
		     o_status out nocopy iby_accppmtmthd.status%type)
return boolean
is
l_flag boolean := false;
cursor c_pmtmthd (ci_ecappid in iby_accppmtmthd.ecappid%type,
		  ci_payeeid in iby_accppmtmthd.payeeid%type,
		  ci_instrtype iby_accttype.instrtype%type,
                  ci_accttype  iby_accttype.accttype%type)
is
SELECT status
FROM iby_accppmtmthd accp, iby_accttype acct
WHERE accp.payeeid = ci_payeeid
AND   accp.ecappid = ci_ecappid
AND   accp.accttypeid = acct.accttypeid
AND   acct.instrtype = ci_instrtype
AND   acct.accttype = ci_accttype;
begin
    if ( c_pmtmthd%isopen) then
        close c_pmtmthd;
    end if;
/*
** open the cursor, which retrieves all the rows that match the ecappid and
** payeeid, instrtype, and accttype.
*/
    open c_pmtmthd(i_ecappid, i_payeeid, i_instrtype, i_accttype);
    fetch c_pmtmthd into o_status;
/*
**  if payeeid and ecappid already exist then return true otherwise flase.
*/
    l_flag := c_pmtmthd%found;

    close c_pmtmthd;
    return l_flag;
end pmtMthdExists;


/*
** Procedure: Creats an  accepted payment method for the payee specified
** Parameters:
**     i_ecappid :  Ec Application's id.
**     i_payeetype : Type of the payee class. This identifies the table to
**                   accessed.
**     i_payeeid   : id of the payee.
**     i_instrtype : type of the instrument. Ex, BANKACCT, CREDITCARD etc.
**     i_accttype  : Type of the account. Example, Checking, SAVINGS, VISA, MATERCARD.
*/
procedure createAccpPmtMthd(i_ecappid in   iby_accppmtmthd.ecappid%type,
                            i_payeeid in   iby_accppmtmthd.payeeid%type,
                            i_instrtype in iby_accttype.instrtype%type,
                            i_accttype in iby_accttype.accttype%type )
is

l_accttypeid iby_accttype.accttypeid%type;
l_mpayeeid iby_accppmtmthd.mpayeeid%type;
l_status iby_accppmtmthd.status%type;

begin

    -- check to make sure input ecappid is valid
    if (not iby_ecapp_pkg.ecappExists(i_ecappid)) then
	    --raise_application_error(-20550, 'ECApp id not registered',FALSE);
	    raise_application_error(-20000, 'IBY_20550#', FALSE);
    end if;

    -- check to make sure input payeeid is valid, and obtain mpayeeid
    getMPayeeId(i_payeeid, l_mpayeeid);

    -- for preexisted pmtMthd, just set it to active, otherwise, create an
    -- entry
    if (pmtMthdExists(i_ecappid, i_payeeid, i_instrtype, i_accttype,
			l_status)) then
	if (l_status = 1) then
	    -- already added
	    raise_application_error(-20000, 'IBY_20500#', FALSE);
            --raise_application_error(-20500, 'Accepted Pmt Mthd Already Exists.', FALSE);
	else
	    UPDATE iby_accppmtmthd
	    SET status = 1,
    	    last_update_date = sysdate,
    	    last_updated_by = fnd_global.user_id,
    	    last_update_login = fnd_global.login_id
    	    WHERE payeeid = i_payeeid
    	    AND   ecappid = i_ecappid
    	    AND   status = 0
    	    AND   accttypeid in ( SELECT accttypeid
                          FROM iby_accttype acct
                          WHERE acct.instrtype = i_instrtype
                          AND   acct.accttype = i_accttype );
	end if;
    else

    	-- brand new, add it in
	-- create an acct type as needed
    iby_accttype_pkg.createAccttype(i_accttype, i_instrtype,
			l_accttypeid);
    INSERT INTO iby_accppmtmthd ( ecappid, mpayeeid, payeeid,
			accttypeid, status,
			last_update_date, last_updated_by,
			creation_date, created_by,
			last_update_login, object_version_number)
        VALUES ( i_ecappid, l_mpayeeid, i_payeeid, l_accttypeid , 1,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);
    end if;

    commit;
end;


/*
**  Procedure:  Deletes an  accepted payment method by a payeeid.
**     i_ecappid :  Ec Application's id.
**     i_payeetype : Type of the payee class. This identifies the table to
**                   accessed.
**     i_payeeid   : id of the payee.
**     i_instrtype : type of the instrument. Ex, BANKACCT, CREDITCARD etc.
**     i_accttype  : Type of the account. Example, Checking, SAVINGS, VISA, MATERCARD.
*/
procedure deleteAccpPmtMthd(i_ecappid   iby_accppmtmthd.ecappid%type,
                            i_payeeid   iby_accppmtmthd.payeeid%type,
                            i_instrtype iby_accttype.instrtype%type,
                            i_accttype  iby_accttype.accttype%type)
is
begin
/*
** Update the iby_accppmtmthd table to mark the row as inactive.
** If there are no rows present, then raise an exception.
*/
    UPDATE iby_accppmtmthd
    SET status = 0,
    	last_update_date = sysdate,
    	last_updated_by = fnd_global.user_id,
    	last_update_login = fnd_global.login_id
    WHERE payeeid = i_payeeid
    AND   ecappid = i_ecappid
    AND   status = 1
    AND   accttypeid in ( SELECT accttypeid
                          FROM iby_accttype acct
                          WHERE acct.instrtype = i_instrtype
                          AND   acct.accttype = i_accttype );
    if ( sql%notfound ) then
    	raise_application_error(-20000, 'IBY_20501#', FALSE);
        --raise_application_error(-20501, 'NO Accepted Pmt Mthd Objects matched ', FALSE);

    -- multiple row match will NEVER happen
    --elsif ( sql%rowcount <> 1 ) then
        --raise_application_error(-20000, ' Rows ' || sql%rowcount || ' matched, so not deleting ', FALSE);

    end if;
    commit;
end;
end iby_accppmtmthd_pkg;

/
