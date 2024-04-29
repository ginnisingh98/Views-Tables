--------------------------------------------------------
--  DDL for Package Body POR_LOAD_FND_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_LOAD_FND_USER" as
/* $Header: PORFNDUB.pls 115.5 2004/07/02 23:27:57 rwidjaja ship $ */

PROCEDURE insert_update_user_info (
        x_employee_number IN VARCHAR2,
	x_user_name  IN VARCHAR2,
        x_password IN VARCHAR2,
        x_email_address IN VARCHAR2)
IS

 l_return_status VARCHAR2(20);
 l_msg_data VARCHAR2(2000);
 l_user_id NUMBER;
 l_msg_count NUMBER;
 l_api_version_number NUMBER := 1.0;
 l_ssp_resp_id NUMBER;
 l_employee_id NUMBER;

 BEGIN


   l_employee_id := get_employee_exists(x_employee_number);


   IF (NOT get_fnd_user_exists(x_user_name)) THEN

	   FND_User_PVT.Create_User(
	   p_api_version_number => l_api_version_number
	  ,p_return_status => l_return_status
	  ,p_msg_count => l_msg_count
	  ,p_msg_data => l_msg_data
	  ,p_email_address => x_email_address
	  ,p_language   => 'US'
	  ,p_host_port => NULL
	  ,p_password => x_password
	  ,p_username => x_user_name
	  ,p_created_by => 0
	  ,p_creation_date => sysdate
	  ,p_last_updated_by => 0
	  ,p_last_update_date => sysdate
	  ,p_user_id => l_user_id
	);

          update_employee_id(l_employee_id, l_user_id);

	  get_default_resp_id('SELF_SERVICE_PURCHASING_5',l_ssp_resp_id);

	  IF l_user_id > 0 and
	      l_ssp_resp_id > 0 THEN


         FND_USER_RESP_GROUPS_API.INSERT_ASSIGNMENT (
            USER_ID  => l_user_id,
            RESPONSIBILITY_ID => l_ssp_resp_id,
            RESPONSIBILITY_APPLICATION_ID => 178,
            START_DATE => sysdate,
            END_DATE => NULL,
            DESCRIPTION	=> 'Default'
         );

        END IF;

   ELSE


   	FND_User_PVT.Update_user(
	   p_api_version_number => l_api_version_number
	  ,p_return_status => l_return_status
	  ,p_msg_count => l_msg_count
	  ,p_msg_data => l_msg_data
	  ,p_email_address => x_email_address
	  ,p_language   => 'US'
	  ,p_host_port => NULL
	  ,p_last_updated_by => 0
	  ,p_last_update_date => sysdate
	  ,p_user_id => l_user_id
	);


   END IF;

   EXCEPTION

   WHEN NO_DATA_FOUND THEN
        RETURN;

   WHEN OTHERS THEN

        RAISE;

END insert_update_user_info;


PROCEDURE get_default_resp_id (p_resp_key IN VARCHAR2, p_resp_id OUT NOCOPY NUMBER)
IS
BEGIN

   SELECT responsibility_id INTO p_resp_id
   FROM fnd_responsibility
   WHERE responsibility_key = p_resp_key
   AND application_id = 178;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN;

END get_default_resp_id;

FUNCTION get_fnd_user_exists(p_user_name IN VARCHAR2) RETURN BOOLEAN IS
   l_fnd_user_exists NUMBER;
BEGIN

   SELECT 1 INTO l_fnd_user_exists FROM fnd_user
   WHERE user_name = upper(p_user_name);

   RETURN true;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN

      RETURN false;

END get_fnd_user_exists;

FUNCTION get_employee_exists (p_employee_number IN VARCHAR2) RETURN NUMBER IS
  l_person_id NUMBER;

BEGIN

  SELECT person_id INTO l_person_id
  FROM per_all_people_f
  WHERE employee_number = p_employee_number;

  RETURN l_person_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END get_employee_exists;

PROCEDURE update_employee_id(p_employee_id IN NUMBER,p_user_id IN NUMBER)
IS
BEGIN


  UPDATE fnd_user
  SET employee_id = p_employee_id
  WHERE user_id = p_user_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN;

END update_employee_id;

END POR_LOAD_FND_USER;

/
