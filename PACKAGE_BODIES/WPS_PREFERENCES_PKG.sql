--------------------------------------------------------
--  DDL for Package Body WPS_PREFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WPS_PREFERENCES_PKG" AS
/* $Header: WPSPREFB.pls 120.1 2005/07/26 15:16:35 sjchen noship $ */


  /**
   * This will remove all the saved preferences for the given application/user
   * combination.
   */
  PROCEDURE delete_user_preferences(x_application_id NUMBER, x_organization_id NUMBER,
				    x_user_id NUMBER) IS

     PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

     delete from wps_preferences
     where application_id = x_application_id
       and user_id = x_user_id
       and organization_id = x_organization_id;

     COMMIT;

  END delete_user_preferences;


  /**
   * This will insert a record into the preference table.
     */
   PROCEDURE insert_preference(x_application_id NUMBER,
			       x_organization_id NUMBER,
			       x_user_id NUMBER,
			       x_preference_type NUMBER,
			       x_value VARCHAR2,
			       x_value_index NUMBER) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN

      insert into wps_preferences (preference_id,
				   application_id,
				   organization_id,
				   user_id,
				   preference_type,
				   value,
				   value_index,
				   last_update_date,
				   last_updated_by,
				   creation_date,
				   created_by)
      values (wps_preferences_seq.nextval,
	      x_application_id,
	      x_organization_id,
	      x_user_id,
	      x_preference_type,
	      x_value,
	      x_value_index,
	      sysdate,
	      x_user_id,
	      sysdate,
	      x_user_id);

      COMMIT;


   END insert_preference;


END WPS_PREFERENCES_PKG;

/
