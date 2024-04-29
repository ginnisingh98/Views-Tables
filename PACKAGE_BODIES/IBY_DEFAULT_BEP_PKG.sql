--------------------------------------------------------
--  DDL for Package Body IBY_DEFAULT_BEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_DEFAULT_BEP_PKG" as
/*$Header: ibydbepb.pls 115.9 2002/10/04 20:08:15 jleybovi ship $*/

/*
** Function: modifyBep.
** Purpose:  modifies rule condition information in the database.
*/
procedure modifyBep (
               i_instrtype in iby_default_bep.instrtype%type,
               i_bepid in iby_default_bep.bepid%type,
               i_version in iby_default_bep.object_version_number%type)
is

CURSOR c_defaultBep IS
  SELECT *
    FROM iby_default_bep  a
    WHERE
      i_version = a.object_version_number AND
      i_instrtype = a.instrtype
    FOR UPDATE;
BEGIN

-- Check whether this method name is already being used
-- if not create a new row.
  IF c_defaultBep%ISOPEN
  THEN
      CLOSE c_defaultBep;
      OPEN c_defaultBep;
  ELSE
      OPEN c_defaultBep;
  END IF;

  IF c_defaultBep%NOTFOUND
  THEN
    CLOSE c_defaultBep;
	  raise_application_error(-20000, 'IBY_204557#', FALSE);
  END IF;

  CLOSE c_defaultBep;

  FOR v_bepInfo  IN c_defaultBep LOOP
  UPDATE iby_default_bep
    SET
      instrtype = i_instrtype,
      bepid = i_bepid,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id,
      object_version_number = object_version_number+1
    WHERE CURRENT OF c_defaultBep;

  END LOOP;

  IF c_defaultBep%ISOPEN
  THEN
      CLOSE c_defaultBep;
  END IF;

  COMMIT;

END;

end iby_default_bep_pkg;

/
