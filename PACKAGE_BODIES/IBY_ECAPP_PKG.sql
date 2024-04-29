--------------------------------------------------------
--  DDL for Package Body IBY_ECAPP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_ECAPP_PKG" as
/*$Header: ibyecapb.pls 115.11 2002/11/18 22:04:50 jleybovi ship $*/


/*
** Function: ecappShortNameExists.
** Purpose: Check if the specified application short name exists.
** 		ecappid of the existing one is outputted  for modification
**		purpose in case this short name is not updated
**
**		not case sensitive
*/
function ecappShortNameExists(i_app_short_name
				iby_ecapp.application_short_name%type,
				o_ecappid out nocopy iby_ecapp.ecappid%type)
return boolean

is
l_app_short_name iby_ecapp.application_short_name%type;
l_flag boolean := false;

cursor c_app_short_name (ci_app_short_name
			iby_ecapp.application_short_name%type)
is
  SELECT application_short_name, ecappid
  FROM iby_ecapp_v
  WHERE UPPER(application_short_name) = UPPER(ci_app_short_name);

begin

    o_ecappid := -1;

    if ( c_app_short_name%isopen) then
        close c_app_short_name;
    end if;

    open c_app_short_name( i_app_short_name);
    fetch c_app_short_name into l_app_short_name, o_ecappid;

    l_flag := c_app_short_name%found;

    close c_app_short_name;
    return l_flag;
end ecappShortNameExists;


/*
** Function: ecappExists.
** Purpose: Check if the specified ecappid exists or not.
*/
function ecappExists(i_ecappid in iby_ecapp.ecappid%type)
return boolean
is
l_ecappid iby_ecapp.ecappid%type;
l_flag boolean := false;

cursor c_ecappid
(ci_ecappid iby_ecapp.ecappid%type)
is
  SELECT ecappid
  FROM iby_ecapp_v
  WHERE ecappid = ci_ecappid;
begin
    if ( c_ecappid%isopen) then
        close c_ecappid;
    end if;

    open c_ecappid( i_ecappid);
    fetch c_ecappid into l_ecappid;

    l_flag := c_ecappid%found;

    close c_ecappid;
    return l_flag;
end ecappExists;

/*
** Procedure Name : createEcApp
** Purpose : creates an entry in the ecapp table. Returns the id created
**           by the system.
**
** Parameters:
**
**    In  : i_ecappname
**    Out : io_ecappid.
**
*/
procedure createEcApp(i_ecappname iby_ecapp.name%type,
		i_app_short_name iby_ecapp.application_short_name%type,
                      io_ecappid in out nocopy iby_ecapp.ecappid%type)
is
NO_SEQUENCE_FOUND EXCEPTION;
cursor c_ecappid is
select iby_ecapp_s.nextval from dual;

l_dummy iby_ecapp.ecappid%type;

begin
    if ( c_ecappid%isopen ) then
        close c_ecappid;
    end if;
    open c_ecappid;
    fetch c_ecappid into io_ecappid;

    -- check to make sure short name is unique
    if (ecappShortNameExists(i_app_short_name, l_dummy)) then
        raise_application_error(-20000,
				'IBY_20551#',
				FALSE);
    end if;

    INSERT into iby_ecapp (ecappid, name, application_short_name,
	last_update_date, last_updated_by, creation_date, created_by,
	last_update_login, object_version_number)
    VALUES ( io_ecappid, i_ecappname, i_app_short_name,
	sysdate, fnd_global.user_id, sysdate, fnd_global.user_id,
	fnd_global.login_id, 1);
    close c_ecappid;
    commit;
end createEcApp;

/*
** Procedure Name : modEcApp
** Purpose : modifies an entry in the ecapp table corresponding to id.
**
** Parameters:
**
**    In  : i_ecappid, i_ecappname
**    Out : None
**
*/
procedure    modEcApp(i_ecappid iby_ecapp.ecappid%type,
                      i_ecappname iby_ecapp.name%type,
			i_app_short_name iby_ecapp.application_short_name%type,
			i_object_version iby_ecapp.object_version_number%type)
is

l_ecappid iby_ecapp.ecappid%type;

begin

    -- check the uniqueness of the application short name
    if (ecappShortNameExists(i_app_short_name, l_ecappid)) then
	if (l_ecappid <> i_ecappid) then
	        raise_application_error(-20000,	'IBY_20551#',
					FALSE);
	end if;
    end if;

/*
** update the row corresponding to the ecappid.
*/
    --- update only if the object_version_number is correct
    if (i_object_version < 0) then
	-- no check in object version number in this case
    	UPDATE iby_ecapp
    	SET name = i_ecappname, application_short_name = i_app_short_name,
		last_update_date = sysdate,
		last_update_login = fnd_global.login_id,
		object_version_number = object_version_number + 1
    	WHERE ecappid = i_ecappid ;
    else
    	UPDATE iby_ecapp
    	SET name = i_ecappname, application_short_name = i_app_short_name,
		last_update_date = sysdate,
		last_update_login = fnd_global.login_id,
		object_version_number = object_version_number + 1
    	WHERE ecappid = i_ecappid
		AND object_version_number = i_object_version;
    end if;


    if ( sql%notfound ) then
	-- no row match
        raise_application_error(-20550,
				'Invalid ecappid or object version number',
				FALSE);
	-- don't need worry about multiple row match case
	-- since ecappid is unique
    end if;

    commit;
end modecapp;
end iby_ecapp_pkg;

/
