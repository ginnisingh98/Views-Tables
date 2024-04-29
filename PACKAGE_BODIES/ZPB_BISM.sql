--------------------------------------------------------
--  DDL for Package Body ZPB_BISM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_BISM" AS
/* $Header: zpbbism.plb 120.3.12010.2 2006/08/03 12:14:32 appldev noship $  */

/*
 * Public  */

-------------------------------------------------------------------------------
-- GET_BISM_SUBJECT_ID - Given a user_id eg. 1008187, returns the
--                       bism subject id
--
-- IN:  p_user_id       - FND User id, integer
-- OUT: l_subject_id    - bism_subjects.subject_id, raw
-------------------------------------------------------------------------------

FUNCTION get_bism_subject_id (
  p_user_id IN fnd_user.user_id%TYPE)
  return bism_subjects.subject_id%TYPE

IS
  l_subject_id   bism_subjects.subject_id%TYPE;
BEGIN

  SELECT subject_id
    INTO l_subject_id
  FROM
    bism_subjects
  WHERE
    subject_type = 'u' and
    subject_name = (SELECT user_name FROM fnd_user WHERE user_id = p_user_id);

return l_subject_id;

END;

-------------------------------------------------------------------------------
-- GET_BISM_SUBJECT_ID - Given a varchar2 user_id eg. '1008187',
--                       returns the raw bism subject id.
--                       calls.
--
-- IN:  p_user_id       - FND User id, varchar2
-- OUT: l_subject_id    - bism_subjects.subject_id, raw
-------------------------------------------------------------------------------


FUNCTION get_bism_subject_id (
  p_user_id IN varchar2)
  return bism_subjects.subject_id%TYPE

IS
  l_subject_id   bism_subjects.subject_id%TYPE;

BEGIN

  SELECT subject_id
    INTO l_subject_id
  FROM
    bism_subjects
  WHERE
    subject_type = 'u' and
    subject_name = (SELECT user_name FROM fnd_user WHERE user_id = p_user_id);

return l_subject_id;

END;


-------------------------------------------------------------------------------
-- GET_BISM_SUBJECT_ID_FROM_NAME - Given a user_name eg. 'JSMITH', returns the
--                                 bism subject id
--
-- IN:  p_user_name     - FND User name e.g. JSMITH
-- OUT: l_subject_id    - bism_subjects.subject_id, raw
-------------------------------------------------------------------------------

FUNCTION get_bism_subject_id_from_name (
  p_user_name      IN fnd_user.user_name%TYPE)
  return bism_subjects.subject_id%TYPE

IS
  l_subject_id  bism_subjects.subject_id%TYPE;
BEGIN

  SELECT subject_id
    INTO l_subject_id
  FROM
    bism_subjects
  WHERE
    subject_name = upper(p_user_name) and
    subject_type = 'u';

return l_subject_id;

END;

-------------------------------------------------------------------------------
-- GET_BISM_SUBJECT_ID_FROM_RESP - Given a responsibility key eg.' ZPB_MANAGER_RESP',
--                                 returns the bism subject id
--
-- IN:  p_resp_key   - FND responsibility key e.g. ZPB_MANAGER_RESP, varchar2
-- OUT: l_subject_id - bism_subjects.subject_id, raw
-------------------------------------------------------------------------------

FUNCTION get_bism_subject_id_from_resp (
  p_resp_key IN fnd_responsibility.responsibility_key%TYPE)
  return bism_subjects.subject_id%TYPE

IS
  l_user_name fnd_user.user_name%TYPE;
  subject_id   bism_subjects.subject_id%TYPE;
BEGIN

  SELECT
    subject_id into subject_id
  FROM
    bism_subjects
  WHERE subject_name = p_resp_key AND
    subject_type = 'g';

 return subject_id;

END;

-------------------------------------------------------------------------------
-- GET_BISM_OBJECT_ID - Given an object path, returns the bism object id
--
-- IN:  p_object_path      - path 'oracle/apps/zpb/BusArea...', varchar2
-- IN:  p_bism_subject_id  - bism_subjects.subject_id, raw
-- OUT: l_folder_id        - bism_subjects.folder_id, raw
-------------------------------------------------------------------------------

FUNCTION get_bism_object_id (
  p_object_path IN varchar2,
  p_bism_subject_id IN bism_subjects.subject_id%TYPE)
  return bism_objects.folder_id%TYPE

IS

  l_folder_id bism_objects.object_id%TYPE;
  v_objid_out BISM_OBJECTS.OBJECT_ID%TYPE;
  v_typeid_out BISM_OBJECTS.OBJECT_TYPE_ID%TYPE;
  v_objname_out BISM_OBJECTS.OBJECT_NAME%TYPE;

BEGIN

  bism_core.lookuphelper(UTL_RAW.CAST_TO_RAW (BIBEANS_ROOT_FOLDER),
                         p_object_path,
                         v_objname_out,
                         v_objid_out,
                         v_typeid_out,
                         p_bism_subject_id);

  return v_objid_out;

END;

-------------------------------------------------------------------------------
-- GET_BISM_OBJECT_DESC - Given an object path, and apps numeric, returns the
--                        object description.
--
-- IN:  p_object_path      - path 'oracle/apps/zpb/BusArea...'
-- IN:  p_user_id          - apps numeric id
-- OUT: l_bism_object_desc - varchar2
-------------------------------------------------------------------------------

FUNCTION get_bism_object_desc (
  p_object_path IN varchar2,
  p_user_id IN FND_USER.USER_ID%TYPE default NULL)
  return BISM_OBJECTS.DESCRIPTION%TYPE

IS

  l_bism_object_id BISM_OBJECTS.OBJECT_ID%TYPE;
  l_bism_object_desc BISM_OBJECTS.DESCRIPTION%TYPE;
  l_bism_subject_id BISM_SUBJECTS.subject_id%TYPE;

BEGIN

  -- use apps id if null passed in.
  if (p_user_id is null) then
    l_bism_subject_id := get_bism_subject_id_from_name(BIBEANS_ROOT_USER);
  else
    l_bism_subject_id := get_bism_subject_id(p_user_id);
  end if;

  l_bism_object_id  := get_bism_object_id(p_object_path, l_bism_subject_id);

  select description
  into l_bism_object_desc
  from bism_objects
  where object_id = l_bism_object_id;

  return l_bism_object_desc;

END;

-------------------------------------------------------------------------------
-- DELETE_BISM_OBJECT - Given a folder path, object_name and apps numeric
--                      userid, deletes the object
--
-- IN: p_folder_path   - path 'oracle/apps/zpb/BusArea...', varchar2
-- IN: p_object_name   - object name 'USERDIR',  varchar2
-- IN: p_user_id       - fnd_user.user_id, varchar2
-------------------------------------------------------------------------------

PROCEDURE delete_bism_object (
  p_folder_path  varchar2,
  p_object_name BISM_OBJECTS.OBJECT_NAME%TYPE,
  p_user_id varchar2 default NULL)

IS

  l_bism_folder_id BISM_OBJECTS.OBJECT_ID%TYPE;
  l_bism_subject_id bism_subjects.subject_id%TYPE;

BEGIN
  BEGIN

    -- use apps id if null passed in.
    if (p_user_id is null) then
      l_bism_subject_id := get_bism_subject_id_from_name(BIBEANS_ROOT_USER);
    else
      l_bism_subject_id := get_bism_subject_id(p_user_id);
    end if;

    l_bism_folder_id  := get_bism_object_id(p_folder_path, l_bism_subject_id);

    bism_core.delete_object(l_bism_folder_id, p_object_name, l_bism_subject_id);
    exception
      when others then
        ZPB_ERROR_HANDLER.HANDLE_EXCEPTION (PKG_NAME,
                                            'delete_bism_object');

        raise;

  END;
END;

-------------------------------------------------------------------------------
-- DELETE_BISM_FOLDER - Given an folder path and user id,
--                      deletes the BISM folder
--
-- IN: p_folder_path   - path 'oracle/apps/zpb/BusArea25/...', varchar2
-- IN: p_user_id       - fnd_user.user_id, number
-------------------------------------------------------------------------------

PROCEDURE delete_bism_folder (
  p_folder_path  varchar2,
  p_user_id IN fnd_user.user_id%TYPE)

IS

  l_bism_folder_id BISM_OBJECTS.OBJECT_ID%TYPE;
  l_bism_subject_id bism_subjects.subject_id%TYPE;

BEGIN
  BEGIN

    l_bism_subject_id := zpb_bism.get_bism_subject_id( p_user_id);
    l_bism_folder_id  := get_bism_object_id(p_folder_path, l_bism_subject_id);

    bism_core.delete_folder(l_bism_folder_id, l_bism_subject_id);
    exception
      when others then
        ZPB_ERROR_HANDLER.HANDLE_EXCEPTION (PKG_NAME,
                                            'delete_bism_folder');

        raise;

  END;
END;

-------------------------------------------------------------------------------
-- DELETE_BISM_FOLDER_WO_SECURITY - Given an folder path and apps userid
--                                  deletes the BISM object using APPS id.
--                                  user_id must be valid bibeans id, but does
--                                  not require write access to folder for deletion.
--
-- IN: p_folder_path   - path 'oracle/apps/zpb/BusArea25/...', varchar2
-- IN: p_user_id       - fnd_user.user_id, integer
-------------------------------------------------------------------------------

PROCEDURE delete_bism_folder_wo_security (
  p_folder_path  varchar2,
  p_user_id IN fnd_user.user_id%TYPE)

IS

  l_bism_folder_id BISM_OBJECTS.OBJECT_ID%TYPE;
  l_bism_subject_id bism_subjects.subject_id%TYPE;

BEGIN
  BEGIN
    l_bism_subject_id := zpb_bism.get_bism_subject_id(p_user_id);
    l_bism_folder_id  := get_bism_object_id(p_folder_path, l_bism_subject_id);

    bism_core.delete_folder_wo_security(l_bism_folder_id, l_bism_subject_id);
    exception
      when others then
        ZPB_ERROR_HANDLER.HANDLE_EXCEPTION (PKG_NAME,
                                            'delete_bism_object_wo_security');

        raise;

  END;
END;

END ZPB_BISM;

/
