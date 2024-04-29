--------------------------------------------------------
--  DDL for Package Body IBY_ACCTTYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_ACCTTYPE_PKG" as
/*$Header: ibyactpb.pls 115.8 2002/11/15 23:50:06 jleybovi ship $*/

/*
** Function: createAcctType.
** Purpose:  creates the acct type information, if it is not already
**           there in the database.
**           and passes back the corresponding accttypeid id.
*/
procedure createAcctType( i_accttype in iby_accttype.accttype%type,
                        i_instrtype in iby_accttype.instrtype%type,
                        io_accttypeid  in out nocopy iby_accttype.accttypeid%type)
is
l_accttypeid iby_accttype.accttypeid%type;
cursor c_accttypeid is
select iby_accttype_s.nextval
from dual;
cursor c_get_accttypeid(ci_accttype in iby_accttype.accttype%type,
                        ci_instrtype in iby_accttype.instrtype%type)
is
 SELECT accttypeid
 FROM iby_accttype
 WHERE accttype = ci_accttype
 AND instrtype = ci_instrtype;
begin
/*
** close the cursor if it is already open.
*/
    if ( c_get_accttypeid%isopen ) then
        close c_get_accttypeid;
    end if;
/*
** open the cursor and check if the corresponding name exists in the
** database.
*/
    open c_get_accttypeid(i_accttype, i_instrtype);
    fetch c_get_accttypeid into l_accttypeid;


    if ( c_get_accttypeid%notfound ) then
/*
**  if the finame is not there in the database then create the entry
**  in the database.
*/
        if ( c_accttypeid%isopen ) then
            close c_accttypeid;
        end if;
        open c_accttypeid;
        fetch c_accttypeid into l_accttypeid;
/*
** insert name in the database.
*/
        INSERT INTO iby_accttype ( accttypeid, accttype, instrtype,
				last_update_date, last_updated_by,
				creation_date, created_by,
				last_update_login, object_version_number)
        VALUES ( l_accttypeid, i_accttype, i_instrtype,
		 sysdate, fnd_global.user_id,
		 sysdate, fnd_global.user_id,
		fnd_global.login_id, 1);

        close c_accttypeid;
    end if;

    io_accttypeid := l_accttypeid;
    close c_get_accttypeid;
    --commit;
end createaccttype;
end iby_accttype_pkg;

/
