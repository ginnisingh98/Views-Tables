--------------------------------------------------------
--  DDL for Package Body CCT_RESOURCE_ASSIGNMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_RESOURCE_ASSIGNMENT" as
/* $Header: cctrsasb.pls 120.0 2005/06/02 09:30:56 appldev noship $ */

MODULE_NAME  CONSTANT VARCHAR2(50) := 'CCT_RESOURCE_ASSIGNMENT';




PROCEDURE REVOKE_RESPONSIBILITY
          (
	   X_USER_ID           NUMBER,
	   X_RESPONSIBILITY_ID NUMBER,
	   X_APPLICATION_ID    NUMBER
	  )
IS
l_def_resp_id           NUMBER;
l_def_app_id            NUMBER;
l_def_resp_key          FND_RESPONSIBILITY_VL.RESPONSIBILITY_KEY%TYPE;
l_def_resp_name         FND_RESPONSIBILITY_VL.RESPONSIBILITY_NAME%TYPE;

BEGIN
IF Fnd_User_Resp_Groups_Api.Assignment_Exists(
  user_id => X_USER_ID,
  responsibility_id => X_RESPONSIBILITY_ID,
  responsibility_application_id => X_APPLICATION_ID
  ) THEN

UPDATE FND_USER_RESP_GROUPS SET END_DATE = SYSDATE
WHERE USER_ID = X_USER_ID
AND   RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
AND   RESPONSIBILITY_APPLICATION_ID = X_APPLICATION_ID;



END IF;

END REVOKE_RESPONSIBILITY;

PROCEDURE ASSIGN_RESPONSIBILITY
          (
	   X_USER_ID           NUMBER,
	   X_RESPONSIBILITY_ID NUMBER,
	   X_APPLICATION_ID    NUMBER
	  )
IS
BEGIN

Fnd_User_Resp_Groups_Api.UPLOAD_ASSIGNMENT(
  user_id => X_USER_ID,
  responsibility_id => X_RESPONSIBILITY_ID,
  responsibility_application_id => X_APPLICATION_ID,
  start_date => sysdate,
  end_date => null,
  description => null );

END ASSIGN_RESPONSIBILITY;


PROCEDURE ASSIGN_RESPONSIBILITY
          (
	   X_USER_ID           NUMBER,
	   X_RESPONSIBILITY_KEY VARCHAR2
	  )
IS

p_responsibility_id NUMBER;
p_application_id NUMBER;
CURSOR RESP_KEY
IS
SELECT RESPONSIBILITY_ID, APPLICATION_ID
FROM FND_RESPONSIBILITY_VL
WHERE RESPONSIBILITY_KEY = X_RESPONSIBILITY_KEY;
BEGIN

OPEN RESP_KEY;

FETCH RESP_KEY INTO p_responsibility_id, p_application_id;

CLOSE RESP_KEY;

IF NVL(p_responsibility_id,0) <> 0 THEN

          ASSIGN_RESPONSIBILITY
          (
	   X_USER_ID           => X_USER_ID,
	   X_RESPONSIBILITY_ID => p_responsibility_id,
	   X_APPLICATION_ID    => p_application_id  );
END IF;

END ASSIGN_RESPONSIBILITY;

PROCEDURE REVOKE_RESPONSIBILITY
          (
	   X_USER_ID            NUMBER,
	   X_RESPONSIBILITY_KEY VARCHAR2
	  )
IS

p_responsibility_id NUMBER;
p_application_id NUMBER;
CURSOR RESP_KEY_ID IS
SELECT RESPONSIBILITY_ID, APPLICATION_ID
FROM FND_RESPONSIBILITY_VL
WHERE RESPONSIBILITY_KEY = X_RESPONSIBILITY_KEY;
BEGIN

OPEN RESP_KEY_ID;

FETCH RESP_KEY_ID INTO p_responsibility_id, p_application_id;

CLOSE RESP_KEY_ID;

IF NVL(p_responsibility_id,0) <> 0 THEN

	  REVOKE_RESPONSIBILITY
          (
	   X_USER_ID           => X_USER_ID,
	   X_RESPONSIBILITY_ID => p_responsibility_id,
	   X_APPLICATION_ID    => p_application_id
	  );
END IF;

END REVOKE_RESPONSIBILITY;


END CCT_RESOURCE_ASSIGNMENT;


/
