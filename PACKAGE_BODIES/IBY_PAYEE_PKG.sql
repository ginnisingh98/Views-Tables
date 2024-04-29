--------------------------------------------------------
--  DDL for Package Body IBY_PAYEE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PAYEE_PKG" as
/*$Header: ibypyeeb.pls 120.1 2005/07/26 17:26:59 rameshsh ship $*/


/*
** Function: payeeNameExists.
** Purpose: Check if any payee Name already exists in the system.
*/
function payeeNameExists (i_name in iby_payee.name%type,
			i_payeeid in iby_payee.payeeid%type )
			-- when payeeid is '', we are adding a new one
			-- otherwise it's update for an existing one
return boolean
is
l_flag boolean := false;
l_name iby_payee.name%type;

-- for modify
cursor c_payee(ci_name in iby_payee.name%type,
		ci_payeeid in iby_payee.payeeid%type) is
SELECT name
FROM  iby_payee
WHERE name = ci_name AND
	payeeid <> ci_payeeid;

-- for create
cursor c_payee2(ci_name in iby_payee.name%type) is

SELECT name
FROM  iby_payee
WHERE name = ci_name;

begin
    if ( c_payee%isopen) then
        close c_payee;
    end if;

    if ( c_payee2%isopen) then
        close c_payee2;
    end if;


    if (i_payeeid is null or i_payeeid = '') then
	-- create
	open c_payee2(i_name);
	fetch c_payee2 into l_name;
	l_flag := c_payee2%found;
        close c_payee2;
    else
	-- modify
	open c_payee(i_name, i_payeeid);
	fetch c_payee into l_name;
        l_flag := c_payee%found;
        close c_payee;
    end if;

/*
**  if payee name already exist then return true otherwise flase.
*/
    return l_flag;
end payeeNameExists;


/*
** Function: payeeExists.
** Purpose: Check if the specified payeeid and ecappid  exists or not.
*/
function payeeExists(i_ecappid in iby_payee.ecappid%type,
                     i_payeeid in iby_payee.payeeid%type)
return boolean
is
l_payeeid iby_payee.payeeid%type;
l_flag boolean := false;
cursor c_payeeid
(ci_payeeid iby_payee.payeeid%type)
is
  SELECT payeeid
  FROM iby_payee
  WHERE payeeid = ci_payeeid;   -- no longer touches ecappid
begin
    if ( c_payeeid%isopen) then
        close c_payeeid;
    end if;
/*
** open the cursor, which retrieves all the rows that match the ecappid and
** payeeid.
*/
    open c_payeeid( i_payeeid);
    fetch c_payeeid into l_payeeid;
/*
**  if payeeid already exist then return true otherwise flase.
*/
   l_flag := c_payeeid%found;

    close c_payeeid;
    return l_flag;
end payeeExists;


/*
** Function: payeeActive.
** Purpose: Check if the specified payeeid and ecappid  is active or not.
*/
function payeeActive(i_ecappid in iby_payee.ecappid%type,
                     i_payeeid in iby_payee.payeeid%type)
return boolean
is
l_payeeid iby_payee.payeeid%type;
l_flag boolean := false;
cursor c_payeeid (
                   ci_payeeid iby_payee.payeeid%type)
is
select payeeid from iby_payee
where payeeid = ci_payeeid
and upper(activestatus) = 'Y';
begin
    if ( c_payeeid%isopen) then
        close c_payeeid;
    end if;
/*
** open the cursor, which retrieves all the rows that match the ecappid and
** payeeid.
*/
    open c_payeeid( i_payeeid);
    fetch c_payeeid into l_payeeid;
/*
**  if payeeid and ecappid already exist then return true otherwise flase.
*/
    l_flag := c_payeeid%found;

    close c_payeeid;
    return l_flag;
end payeeActive;


/*
** Procedure: createPayee.
** Purpose: creates a payee object in iby_payee.
** parameters: i_payeeid, id of the payee that is passed by ec application.
**             ecappid, id of the ecapplication.
*/
procedure createPayee(i_ecappid in iby_ecapp.ecappid%type,
                      i_payeeid in iby_payee.payeeid%type,
                      i_payeename in iby_payee.name%type,
                      i_supportedOp in iby_payee.supportedOp%type,
                      i_username in iby_payee.username%type,
                      i_password in iby_payee.password%type,
                      i_activestatus in iby_payee.activeStatus%type,
		      i_threshold in iby_payee.threshold%type,
		      i_risk_enabled in iby_payee.risk_enabled%type,
                      i_bepids in JTF_NUMBER_TABLE,
                      i_bepkeys in varchar2,
                      i_bepdefaults in varchar2,
                      i_mcc in number,
		      i_secenable IN iby_payee.security_enabled%TYPE
		      )

is
l_bepid_tab number_tab;
l_bepkey_tab varchar_tab;
l_bepdefaults_tab varchar_tab;
l_id_cnt integer;
l_key_cnt integer;
l_default_cnt integer;

mpayeeid		number;


BEGIN

-- check to make sure ecappid is valid
if (not iby_ecapp_pkg.ecappExists(i_ecappid)) then
     raise_application_error(-20000, 'IBY_20550#', FALSE);
end if;

IF (payeeNameExists(i_payeename, '')) THEN
	raise_application_error(-20000, 'IBY_20514#', FALSE);
END IF;

/*
** call payeeExists to verfify if payee already exists or not. if not
** make an entry into iby_payee table.
*/

if (not payeeExists( i_ecappid,i_payeeid) ) then

       select iby_payee_s.NEXTVAL
       into mpayeeid
       from dual;

        INSERT INTO iby_payee ( mpayeeid,ecappid, payeeid, name, supportedop,
                               username, password, activestatus,
				threshold, risk_enabled, mcc_code, security_enabled,
				last_update_date, last_updated_by,
				creation_date, created_by,
			last_update_login, object_version_number)
        VALUES (mpayeeid, i_ecappid, i_payeeid, i_payeename, i_supportedop,
                 i_username, i_password, i_activestatus,
		 i_threshold, i_risk_enabled, i_mcc, i_secenable,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);

        getNumberTables(i_bepids, l_bepid_tab, l_id_cnt);
        getTables(i_bepkeys,l_bepkey_tab, l_key_cnt);
        getTables(i_bepdefaults, l_bepdefaults_tab, l_default_cnt);

        for i in 1..l_id_cnt loop
            iby_bepkeys_pkg.createBEPKey(l_bepid_tab(i), 'PAYEE', i_payeeid, l_bepkey_tab(i), l_bepdefaults_tab(i));
        end loop;

 else
            /*DEBUGGING THIS SECTION*/
	    --raise_application_error(-20514, 'Payee Exists', FALSE);
	    raise_application_error(-20000, 'IBY_20514', FALSE);
 end if;
-- end if;

     commit;
end createPayee;


/*
** Procedure activatePayee
** Change the active status of the payee
**
** ecappid is no longer used
*/
procedure setPayeeStatus(i_ecappid in iby_payee.ecappid%type,
			i_payeeid in iby_payee.payeeid%type,
			i_activestatus in iby_payee.activeStatus%type)
is

begin
    if (payeeExists(i_ecappid, i_payeeid) ) then
        UPDATE iby_payee
        SET activestatus = i_activestatus,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id
        WHERE  payeeid = i_payeeid;
    else
            /*DEBUGGING THIS SECTION*/
   	raise_application_error(-20000, 'IBY_20515#', FALSE);
    end if;

end setPayeeStatus;



/*
** Procedure: modifyPayee.
** Purpose: creates a payee object in iby_payee.
** parameters: i_payeeid, id of the payee that is passed by ec application.
**             ecappid, id of the ecapplication.
** ecappid is no longer used
*/
procedure modifyPayee(i_ecappid in iby_ecapp.ecappid%type,
                      i_payeeid in iby_payee.payeeid%type,
                      i_payeename in iby_payee.name%type,
                      i_supportedOp in iby_payee.supportedOp%type,
                      i_username in iby_payee.username%type,
                      i_password in iby_payee.password%type,
                      i_activestatus in iby_payee.activeStatus%type,
		      i_threshold in iby_payee.threshold%type,
		      i_risk_enabled in iby_payee.risk_enabled%type,
                      i_bepids in JTF_NUMBER_TABLE,
                      i_bepkeys in varchar2,
                      i_bepdefaults in varchar2,
                      i_mcc in number,
		      i_secenable IN iby_payee.security_enabled%TYPE,
		      i_object_version in iby_payee.object_version_number%type
                      )
is
l_bepid_tab number_tab;
l_bepkey_tab varchar_tab;
l_bepdefaults_tab varchar_tab;
l_id_cnt integer;
l_key_cnt integer;
l_default_cnt integer;


begin
/*
** can only modify existing, active payee
*/

     if (payeeExists(i_ecappid,i_payeeid)) then

	IF (payeeNameExists(i_payeename, i_payeeid)) THEN
		raise_application_error(-20000, 'IBY_20514#', FALSE);
	END IF;

        UPDATE iby_payee
        SET name= i_payeename,
            supportedOp = i_supportedOp,
            username = i_username,
            password = i_password,
            activestatus = i_activestatus,
	    threshold = i_threshold,
	    risk_enabled = i_risk_enabled,
            mcc_code = i_mcc,
	    security_enabled = i_secenable,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
	    object_version_number = object_version_number + 1
        WHERE payeeid = i_payeeid
	 AND object_version_number = i_object_version;

    else
        raise_application_error(-20000, 'IBY_20515#', FALSE);
    end if;
    --dbms_output.put_line('Update to payee complete');

    getNumberTables(i_bepids, l_bepid_tab, l_id_cnt);
    getTables(i_bepkeys,l_bepkey_tab, l_key_cnt);
    getTables(i_bepdefaults, l_bepdefaults_tab, l_default_cnt);

    iby_bepkeys_pkg.deleteBEPKeys(i_payeeid, 'PAYEE');
    for i in 1..l_id_cnt loop
        iby_bepkeys_pkg.createBEPKey(l_bepid_tab(i), 'PAYEE', i_payeeid, l_bepkey_tab(i), l_bepdefaults_tab(i));
    end loop;
    commit;
end modifyPayee;


/*
** getTables
** looks like it parse an input string delimited with ',' to a table structure
*/
procedure getTables(tableString varchar2, pltable out NOCOPY varchar_tab, counter out NOCOPY integer)
is
loopindex int := 1;
index1 int := 1;
index2 int := 1;
str varchar2(100);
begin
    if ( length(tableString) is null  ) then
        counter := 0;
        return;
    end if;
    index2 := instrb(tableString,',',index1);
    while ( index2 <> 0 ) loop
        pltable(loopindex) := substr(tableString, index1, (index2 - index1 ));
        index1 := index2 + 1;
        index2 := instr(tableString,',',index1);
        loopindex := loopindex + 1;
    end loop;
    pltable(loopindex) := substr(tableString, index1);
    counter := loopindex;
end getTables;

/*
** getNumberTables
** Parses an input JTF_NUMBER_TABLE to a table structure
*/
procedure getNumberTables(tableNumber JTF_NUMBER_TABLE, pltable out NOCOPY number_tab, counter out NOCOPY integer)
is

  ddindx binary_integer; indx binary_integer;

begin

  if (tableNumber is null) then
	counter := 0;
	return;
  end if;

  indx := tableNumber.first;
  ddindx := 0;

  while true loop

    ddindx := ddindx+1;

    plTable(ddindx) := tableNumber(indx);

    if tableNumber.last = indx
      then exit;
    end if;
    indx := tableNumber.next(indx);

  end loop;

  counter := ddindx;

end getNumberTables;

end iby_payee_pkg;

/
