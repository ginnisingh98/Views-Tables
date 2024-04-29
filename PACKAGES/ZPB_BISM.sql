--------------------------------------------------------
--  DDL for Package ZPB_BISM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_BISM" AUTHID CURRENT_USER AS
/* $Header: zpbbism.pls 120.2.12010.2 2006/08/03 12:14:56 appldev noship $  */

PKG_NAME  CONSTANT VARCHAR2(8) := 'zpb_bism';

-- The privileges
LIST_PRIV CONSTANT       INTEGER := 10;
READ_PRIV CONSTANT       INTEGER := 20;
ADD_FOLDER_PRIV CONSTANT INTEGER := 30;
WRITE_PRIV CONSTANT      INTEGER := 40;
LIST_PRIV CONSTANT       INTEGER := 50;

LIST CONSTANT            VARCHAR2(4)  := 'LIST';
READ CONSTANT            VARCHAR2(4)  := 'READ';
ADD_FOLDER CONSTANT      VARCHAR2(10) := 'ADD FOLDER';
WRITE CONSTANT           VARCHAR2(5)  := 'WRITE';
LIST_PRIV CONSTANT       VARCHAR2(12) := 'FULL CONTROL';

-- The responsibilities and users.
ANALYST             CONSTANT VARCHAR2(16):= 'ZPB_ANALYST_RESP';
MANAGER             CONSTANT VARCHAR2(16):= 'ZPB_MANAGER_RESP';
CONTROLLER          CONSTANT VARCHAR2(19):= 'ZPB_CONTROLLER_RESP';
SUPER_CONTROLLER    CONSTANT VARCHAR2(25):= 'ZPB_SUPER_CONTROLLER_RESP';
BIBEANS_ROOT_USER   CONSTANT VARCHAR2(4) := 'APPS';
BIBEANS_ROOT_FOLDER CONSTANT VARCHAR2(1) := '1';

-------------------------------------------------------------------------------
-- GET_BISM_SUBJECT_ID - Given a user_id eg. 1008187, returns the
--                       bism subject id
--
-- IN:  p_user_id       - FND User id, integer
-- OUT: l_subject_id    - bism_subjects.subject_id, raw
-------------------------------------------------------------------------------

FUNCTION get_bism_subject_id (
  p_user_id      IN fnd_user.user_id%TYPE)
  return bism_subjects.subject_id%TYPE;

-------------------------------------------------------------------------------
-- GET_BISM_SUBJECT_ID - Given a varchar2  user_id eg. '1008187',
--                       returns the raw bism subject id.
--                       calls.
--
-- IN:  p_user_id       - FND User id, varchar2
-- OUT: l_subject_id    - bism_subjects.subject_id, raw
-------------------------------------------------------------------------------

FUNCTION get_bism_subject_id (
  p_user_id IN varchar2)
  return bism_subjects.subject_id%TYPE;

-------------------------------------------------------------------------------
-- GET_BISM_SUBJECT_ID_FROM_NAME - Given a user_name eg. 'JSMITH', returns the
--                                 bism subject id
--
-- IN:  p_user_name     - FND User name e.g. JSMITH
-- OUT: l_subject_id    - bism_subjects.subject_id, raw
-------------------------------------------------------------------------------

FUNCTION get_bism_subject_id_from_name (
  p_user_name      IN fnd_user.user_name%TYPE)
  return bism_subjects.subject_id%TYPE;

-------------------------------------------------------------------------------
-- GET_BISM_SUBJECT_ID_FROM_RESP - Given a responsibility key eg. 'ZPB_MANAGER_RESP',
--                                 returns the bism subject id
--
-- IN:  p_resp_key   - FND responsibility key e.g. ZPB_MANAGER_RESP, varchar2
-- OUT: l_subject_id - bism_subjects.subject_id, raw
-------------------------------------------------------------------------------

FUNCTION get_bism_subject_id_from_resp (
  p_resp_key IN fnd_responsibility.responsibility_key%TYPE)
  return bism_subjects.subject_id%TYPE;

-------------------------------------------------------------------------------
-- GET_BISM_OBJECT_ID - Given an object path, returns the bism object id
--
-- IN: p_object_path     - path 'oracle/apps/zpb/BusArea...'
-- IN: p_bism_subject_id - raw subject_id
-- OUT: l_folder_id        - bism_subjects.folder_id, raw
-------------------------------------------------------------------------------

FUNCTION get_bism_object_id (
  p_object_path IN varchar2,
  p_bism_subject_id IN bism_subjects.subject_id%TYPE)
  return bism_objects.folder_id%TYPE;

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
  return BISM_OBJECTS.DESCRIPTION%TYPE;

-------------------------------------------------------------------------------
-- DELETE_BISM_OBJECT - Given a folder path, object_name and apps numeric
--                      userid, deletes the BISM object
--
-- IN: p_folder_path   - path 'oracle/apps/zpb/BusArea...', varchar2
-- IN: p_object_name   - object name 'USERDIR',  varchar2
-- IN: p_user_id       - fnd_user.user_id, varchar2
-------------------------------------------------------------------------------

PROCEDURE delete_bism_object (
  p_folder_path  varchar2,
  p_object_name BISM_OBJECTS.OBJECT_NAME%TYPE,
  p_user_id varchar2 default NULL);


-------------------------------------------------------------------------------
-- DELETE_BISM_FOLDER - Given an folder path and user id,
--                      deletes the BISM folder
--
-- IN: p_folder_path   - path 'oracle/apps/zpb/BusArea25/...', varchar2
-- IN: p_user_id       - fnd_user.user_id, number
-------------------------------------------------------------------------------

PROCEDURE delete_bism_folder (
  p_folder_path  varchar2,
  p_user_id IN fnd_user.user_id%TYPE);

-------------------------------------------------------------------------------
-- DELETE_BISM_FOLDER_WO_SECURITY - Given an folder path and apps userid
--                                  deletes the BISM object using APPS id,
--                                  id has to be valid bibeans user but does
--                                  not require write access to folder for deletion.
--
-- IN: p_folder_path   - path 'oracle/apps/zpb/BusArea25/...', varchar2
-- IN: p_user_id       - fnd_user.user_id, integer
-------------------------------------------------------------------------------

PROCEDURE delete_bism_folder_wo_security (
  p_folder_path  varchar2,
  p_user_id IN fnd_user.user_id%TYPE);

END ZPB_BISM;

 

/
