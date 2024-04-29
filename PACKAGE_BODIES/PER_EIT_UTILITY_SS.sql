--------------------------------------------------------
--  DDL for Package Body PER_EIT_UTILITY_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EIT_UTILITY_SS" AS
/* $Header: hreitutl.pkb 120.0 2005/05/31 00:04:30 appldev noship $ */

 -- ----------------------------------------------------------------------------
-- |-----------------------< EIT_NOT_EXIST >--------------------------|
-- ----------------------------------------------------------------------------


FUNCTION EIT_NOT_EXIST   (P_APPLICATION_SHORT_NAME      VARCHAR2,
                           P_RESPONSIBILITY_NAME        VARCHAR2,
                           P_INFO_TYPE_TABLE_NAME       VARCHAR2,
                           P_INFORMATION_TYPE           VARCHAR2,
                           P_ROWID                      VARCHAR2) RETURN BOOLEAN
IS
L_DUMMY1  number;

l_appl_id number;
l_resp_id number;
CURSOR C_APPL IS
        select application_id
        from fnd_application
        where application_short_name = upper(P_APPLICATION_SHORT_NAME);
CURSOR C_RESP IS
        select responsibility_id
        from fnd_responsibility_vl
        where responsibility_name = P_RESPONSIBILITY_NAME
        and application_id = l_appl_id;

CURSOR C1 (c1_p_appl_id number, c1_p_resp_id number) IS

        select  1
        from    PER_INFO_TYPE_SECURITY t
        where   t.application_id = c1_p_appl_id
        and     t.responsibility_id = c1_p_resp_id
        and     t.info_type_table_name = P_INFO_TYPE_TABLE_NAME
        and     t.information_type = P_INFORMATION_TYPE
        and     (P_ROWID        is null
                 or P_ROWID    <> t.rowid);
BEGIN
 OPEN C_APPL;
 FETCH C_APPL INTO l_appl_id;
 CLOSE C_APPL;
 OPEN C_RESP;
 FETCH C_RESP INTO l_resp_id;
 CLOSE C_RESP;
 OPEN C1(l_appl_id, l_resp_id);
 FETCH C1 INTO L_DUMMY1;
 IF C1%NOTFOUND THEN
  CLOSE C1;
  return true;
 ELSE
  CLOSE C1;
  return false;
 END IF;

end EIT_NOT_EXIST;


-- ----------------------------------------------------------------------------
-- |-----------------------< GET_RESP_KEY >--------------------------|
-- ----------------------------------------------------------------------------


FUNCTION GET_RESP_KEY   (P_APPLICATION_SHORT_NAME     VARCHAR2,
                         P_RESPONSIBILITY_NAME        VARCHAR2) RETURN VARCHAR2
IS
l_resp_key  varchar2(30) := null;
l_appl_id number;
CURSOR C_APPL IS
        select application_id
        from fnd_application
        where application_short_name = upper(P_APPLICATION_SHORT_NAME);
CURSOR RESP_KEY (resp_appl_id number, resp_resp_name varchar2)IS
        select responsibility_key
        from fnd_responsibility_vl
        where responsibility_name = resp_resp_name
        and   application_id = resp_appl_id;
BEGIN
 OPEN C_APPL;
 FETCH C_APPL INTO l_appl_id;
 CLOSE C_APPL;
 OPEN RESP_KEY(l_appl_id, P_RESPONSIBILITY_NAME);
 FETCH RESP_KEY INTO l_resp_key;
 IF RESP_KEY%NOTFOUND THEN
  CLOSE RESP_KEY;
  return l_resp_key;
 ELSE
  CLOSE RESP_KEY;
  return l_resp_key;
 END IF;

end GET_RESP_KEY;



 -- ----------------------------------------------------------------------------
-- |-----------------------< create_eit_resp_security >--------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE create_eit_resp_security (P_RESPONSIBILITY_NAME       IN VARCHAR2)
IS

cursor c_person_types is
select information_type
from per_people_info_types
where information_type not like 'GHR%';

cursor c_job_types is
select information_type
from per_job_info_types
where information_type not like 'GHR%';

cursor c_assignment_types is
select information_type
from per_assignment_info_types
where information_type not like 'GHR%';

cursor c_position_types is
select information_type
from per_position_info_types
where information_type not like 'GHR%';

cursor c_location_types is
select information_type
from hr_location_info_types
where information_type not like 'GHR%';

l_row_id varchar2(80) := null;

begin

-----------------------------------------
--------------PERSON		---------
-----------------------------------------
FOR person_type IN c_person_types LOOP

if eit_not_exist(P_APPLICATION_SHORT_NAME	=> 'PER',
                 P_RESPONSIBILITY_NAME		=> P_RESPONSIBILITY_NAME,
                 P_INFO_TYPE_TABLE_NAME       	=> 'PER_PEOPLE_INFO_TYPES',
                 P_INFORMATION_TYPE		=> person_type.information_type,
                 P_ROWID                      	=> l_row_id)
              THEN

PER_PEOPLE_INFO_TYPES_SEC_PKG.INSERT_ROW
(x_rowid 			=> l_row_id,
 x_application_short_name 	=> 'PER',
 --X_RESPONSIBILITY_NAME 		=> P_RESPONSIBILITY_NAME,
 X_RESPONSIBILITY_KEY           => GET_RESP_KEY('PER', P_RESPONSIBILITY_NAME),
 X_INFO_TYPE_TABLE_NAME 	=> 'PER_PEOPLE_INFO_TYPES',
 X_INFORMATION_TYPE		=> person_type.information_type,
 X_OBJECT_VERSION_NUMBER 	=> 1,
 X_CREATION_DATE		=> sysdate,
 X_CREATED_BY			=> -1,
 X_LAST_UPDATE_DATE 		=> sysdate,
 X_LAST_UPDATED_BY		=> -1,
 X_LAST_UPDATE_LOGIN		=> -1);

END IF;
END LOOP;

-----------------------------------------
--------------JOB		---------
-----------------------------------------
FOR job_type IN c_job_types LOOP

if eit_not_exist(P_APPLICATION_SHORT_NAME	=> 'PER',
                 P_RESPONSIBILITY_NAME		=> P_RESPONSIBILITY_NAME,
                 P_INFO_TYPE_TABLE_NAME       	=> 'PER_JOB_INFO_TYPES',
                 P_INFORMATION_TYPE		=> job_type.information_type,
                 P_ROWID                      	=> l_row_id)
              THEN

PER_PEOPLE_INFO_TYPES_SEC_PKG.INSERT_ROW
(x_rowid 			=> l_row_id,
 x_application_short_name 	=> 'PER',
 --X_RESPONSIBILITY_NAME                => P_RESPONSIBILITY_NAME,
 X_RESPONSIBILITY_KEY           => GET_RESP_KEY('PER', P_RESPONSIBILITY_NAME),
 X_INFO_TYPE_TABLE_NAME 	=> 'PER_JOB_INFO_TYPES',
 X_INFORMATION_TYPE		=> job_type.information_type,
 X_OBJECT_VERSION_NUMBER 	=> 1,
 X_CREATION_DATE		=> sysdate,
 X_CREATED_BY			=> -1,
 X_LAST_UPDATE_DATE 		=> sysdate,
 X_LAST_UPDATED_BY		=> -1,
 X_LAST_UPDATE_LOGIN		=> -1);

END IF;

END LOOP;

-----------------------------------------
--------------ASSIGNMENT	---------
-----------------------------------------

FOR assignment_type IN c_assignment_types LOOP

if eit_not_exist(P_APPLICATION_SHORT_NAME	=> 'PER',
                 P_RESPONSIBILITY_NAME		=> P_RESPONSIBILITY_NAME,
                 P_INFO_TYPE_TABLE_NAME       	=> 'PER_ASSIGNMENT_INFO_TYPES',
                 P_INFORMATION_TYPE		=> assignment_type.information_type,
                 P_ROWID                      	=> l_row_id)
              THEN

PER_PEOPLE_INFO_TYPES_SEC_PKG.INSERT_ROW
(x_rowid 			=> l_row_id,
 x_application_short_name 	=> 'PER',
 --X_RESPONSIBILITY_NAME                => P_RESPONSIBILITY_NAME,
 X_RESPONSIBILITY_KEY           => GET_RESP_KEY('PER', P_RESPONSIBILITY_NAME),
 X_INFO_TYPE_TABLE_NAME 	=> 'PER_ASSIGNMENT_INFO_TYPES',
 X_INFORMATION_TYPE		=> assignment_type.information_type,
 X_OBJECT_VERSION_NUMBER 	=> 1,
 X_CREATION_DATE		=> sysdate,
 X_CREATED_BY			=> -1,
 X_LAST_UPDATE_DATE 		=> sysdate,
 X_LAST_UPDATED_BY		=> -1,
 X_LAST_UPDATE_LOGIN		=> -1);

END IF;

END LOOP;

-----------------------------------------
--------------POSITION		---------
-----------------------------------------

FOR position_type IN c_position_types LOOP

if eit_not_exist(P_APPLICATION_SHORT_NAME	=> 'PER',
                 P_RESPONSIBILITY_NAME		=> P_RESPONSIBILITY_NAME,
                 P_INFO_TYPE_TABLE_NAME       	=> 'PER_POSITION_INFO_TYPES',
                 P_INFORMATION_TYPE		=> position_type.information_type,
                 P_ROWID                      	=> l_row_id)
              THEN

PER_PEOPLE_INFO_TYPES_SEC_PKG.INSERT_ROW
(x_rowid 			=> l_row_id,
 x_application_short_name 	=> 'PER',
 --X_RESPONSIBILITY_NAME                => P_RESPONSIBILITY_NAME,
 X_RESPONSIBILITY_KEY           => GET_RESP_KEY('PER', P_RESPONSIBILITY_NAME),
 X_INFO_TYPE_TABLE_NAME 	=> 'PER_POSITION_INFO_TYPES',
 X_INFORMATION_TYPE		=> position_type.information_type,
 X_OBJECT_VERSION_NUMBER 	=> 1,
 X_CREATION_DATE		=> sysdate,
 X_CREATED_BY			=> -1,
 X_LAST_UPDATE_DATE 		=> sysdate,
 X_LAST_UPDATED_BY		=> -1,
 X_LAST_UPDATE_LOGIN		=> -1);

END IF;

END LOOP;

-----------------------------------------
--------------LOCATION		---------
-----------------------------------------

FOR location_type IN c_location_types LOOP

if eit_not_exist(P_APPLICATION_SHORT_NAME	=> 'PER',
                 P_RESPONSIBILITY_NAME		=> P_RESPONSIBILITY_NAME,
                 P_INFO_TYPE_TABLE_NAME       	=> 'HR_LOCATION_NINFO_TYPES',
                 P_INFORMATION_TYPE		=> location_type.information_type,
                 P_ROWID                      	=> l_row_id)
              THEN

PER_PEOPLE_INFO_TYPES_SEC_PKG.INSERT_ROW
(x_rowid 			=> l_row_id,
 x_application_short_name 	=> 'PER',
 --X_RESPONSIBILITY_NAME                => P_RESPONSIBILITY_NAME,
 X_RESPONSIBILITY_KEY           => GET_RESP_KEY('PER', P_RESPONSIBILITY_NAME),
 X_INFO_TYPE_TABLE_NAME 	=> 'HR_LOCATION_INFO_TYPES',
 X_INFORMATION_TYPE		=> location_type.information_type,
 X_OBJECT_VERSION_NUMBER 	=> 1,
 X_CREATION_DATE		=> sysdate,
 X_CREATED_BY			=> -1,
 X_LAST_UPDATE_DATE 		=> sysdate,
 X_LAST_UPDATED_BY		=> -1,
 X_LAST_UPDATE_LOGIN		=> -1);

END IF;

END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
	null;

end create_eit_resp_security;

END;

/
