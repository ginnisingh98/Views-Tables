--------------------------------------------------------
--  DDL for Package Body IBY_BEPLANGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_BEPLANGS_PKG" as
/*$Header: ibybeplb.pls 115.8 2002/10/02 22:23:38 jleybovi ship $*/

/*
** Procedure: createBEPLangs
** Purpose:  creates the beplang information,
**           replace previous entries, if any
**
*/
procedure createBEPLangs( i_bepid in iby_beplangs.bepid%type,
                          i_preNLSLang in iby_beplangs.beplang%type,
                          i_opt1NLSLang in iby_beplangs.beplang%type,
                          i_opt2NLSLang in iby_beplangs.beplang%type)
is
begin
/*
** delete all the rows that blong to this bep.
*/
    delete from iby_beplangs
    where bepid = i_bepid;
/*
** insert preferred language entry in the table.
*/
    insert into iby_beplangs( bepid, beplang, preferred,
	last_update_date, last_updated_by,
	creation_date, created_by,
	last_update_login, object_version_number)
    values (i_bepid, i_preNLSLang, 0,
	 sysdate, fnd_global.user_id,
	 sysdate, fnd_global.user_id,
	fnd_global.login_id, 1);

/*
** insert optional language 1 entry in the table.
*/
    insert into iby_beplangs( bepid, beplang, preferred,
	last_update_date, last_updated_by,
	creation_date, created_by,
	last_update_login, object_version_number)
    values (i_bepid, i_opt1NLSLang, 1,
	 sysdate, fnd_global.user_id,
	 sysdate, fnd_global.user_id,
	fnd_global.login_id, 1);
/*
** insert optional language 2 entry in the table.
*/
    insert into iby_beplangs( bepid, beplang, preferred,
	last_update_date, last_updated_by,
	creation_date, created_by,
	last_update_login, object_version_number)
    values (i_bepid, i_opt2NLSLang, 2,
	 sysdate, fnd_global.user_id,
	 sysdate, fnd_global.user_id,
	fnd_global.login_id, 1);

    commit;
end createBEPLangs;

end iby_beplangs_pkg;

/
