--------------------------------------------------------
--  DDL for Package Body IBY_BEPKEYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_BEPKEYS_PKG" as
/*$Header: ibybepkb.pls 120.2 2005/10/30 05:49:46 appldev ship $*/

/*
** Function: bepKeyExists.
** Purpose: Check if the specified payeeid, bepid exists or not.
** Unique constraints on 'bepid', 'key'
**
** Previously, we require Unique constraints on 'bepid', 'key' and
**	'payeeid'
** This is giving problem w/ closebatch as each BEP will associate 'key'
** with one payee only
**
** It will fail at the following case:
**	bepid	key	payeeid
**	1	oracle	payee1
**	1	oracle	payee2
**
**	Given key 'oracle' it won't know which payee it comes from
**
** Now we require uniqueness on 'bepid', 'key' alone
**
** The output parameters 'o_ownerid, o_bepname' are for error message
** only.
*/

function bepKeyExists(i_bepid in iby_bepinfo.bepid%type,
                     i_ownertype in iby_bepkeys.ownertype%type,
			i_bepkey in iby_bepkeys.key%type,
                     o_ownerid out nocopy iby_bepkeys.ownerid%type,
			o_bepname out nocopy iby_bepinfo.name%type)

return boolean

IS

l_flag boolean := false;

-- to check if this key has already been used for given bep
-- i.e., all bep keys has to be distinct across all payees for a given bep
cursor c_owner (     ci_bepid iby_bepkeys.bepid%type,
                   ci_ownertype iby_bepkeys.ownertype%type,
		ci_bepkey iby_bepkeys.key%type)
is
select ownerid, name
from iby_bepkeys a, iby_bepinfo b
where a.key = ci_bepkey
and a.ownertype = ci_ownertype
and a.bepid = ci_bepid
AND a.bepid = b.bepid;

BEGIN
    o_ownerid := NULL;
    o_bepname := NULL;

    if ( c_owner%isopen) then
        close c_owner;
    end if;

    open c_owner(i_bepid, i_ownertype, i_bepkey);
    fetch c_owner into o_ownerid, o_bepname;

    l_flag := (c_owner%found);

    close c_owner;

    return l_flag;
END bepKeyExists;

/*
** Precedure: deleteBEPKeys
** Purpose: delete ALL bepkeys associated with a payee
**
**
*/
procedure deleteBEPKeys(i_ownerid in iby_bepkeys.ownerid%type,
			i_ownertype in iby_bepkeys.ownertype%type)
is
begin
	DELETE FROM iby_bepkeys
	WHERE ownerid = i_ownerid
	AND ownertype = i_ownertype;
end deleteBEPKeys;


/*
** Procedure: createBEPKey.
** Purpose: creates a SINGLE bep key entry in iby_bepkeys table
** parameters: i_ownerid, i_ownertype identifies the owner of the key.
**             i_bepid, id of the back end payment systems.
*/
procedure createBEPKey(i_bepid in iby_bepinfo.bepid%type,
                      i_ownertype in iby_bepkeys.ownertype%type,
                      i_ownerid in iby_bepkeys.ownerid%type,
                      i_key in iby_bepkeys.key%type,
                      i_default in iby_bepkeys.defaults%type)
is
l_bepid iby_bepkeys.bepid%type;
l_ownerid iby_bepkeys.ownerid%type;
l_bepname iby_bepinfo.name%type;
l_bep_account_id iby_bepkeys.bep_account_id%TYPE;

begin

   --get the bepid based on name of the bep.

    l_bepid := i_bepid;
    if ( l_bepid = -99 ) then
       	raise_application_error(-20000, 'IBY_20521#', FALSE);
        --raise_application_error(-20521, 'NO BEP Info matched ', FALSE);
    end if;

    IF ( bepKeyExists(l_bepid, i_ownertype, i_key, l_ownerid, l_bepname)) THEN
	---uniqueness constraints violated
       	raise_application_error(-20000,
				'IBY_20526#KEY=' || i_key ||
				'#BEP=' || l_bepname || '#PAYEEID='
				|| l_ownerid, FALSE);
    END IF;

    SELECT iby_bepkeys_s.NEXTVAL
    INTO l_bep_account_id
    FROM dual;

    -- create new keys
        INSERT INTO iby_bepkeys ( bep_account_id, bepid, ownertype,
                                ownerid, key, defaults,
				last_update_date, last_updated_by,
				creation_date, created_by,
				last_update_login, object_version_number)
        VALUES ( l_bep_account_id, l_bepid, i_ownertype,
                 i_ownerid, i_key, i_default,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);
end createBEPKey;

end iby_bepkeys_pkg;

/
