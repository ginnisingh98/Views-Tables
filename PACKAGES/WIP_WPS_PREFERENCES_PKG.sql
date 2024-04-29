--------------------------------------------------------
--  DDL for Package WIP_WPS_PREFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WPS_PREFERENCES_PKG" AUTHID CURRENT_USER AS
/* $Header: wipzprfs.pls 120.0 2005/05/25 12:49:57 appldev noship $ */

    /**
     * This will remove all the saved preferences for the given application/user
     * combination.
     */
     PROCEDURE delete_user_preferences(x_application_id NUMBER,
				       x_organization_id NUMBER,
				       x_user_id NUMBER);

     /**
      * Same as above, but will look at the module as well. added 11.5.10
      */
     PROCEDURE delete_user_preferences(x_application_id NUMBER,
				       x_organization_id NUMBER,
				       x_user_id NUMBER,
				       x_module_id NUMBER);

     /**
      * Same as above, but will look at the module and preference type as well.
      * Added 11.5.11
      */
     PROCEDURE delete_user_preferences(x_application_id NUMBER,
				       x_organization_id NUMBER,
				       x_user_id NUMBER,
				       x_module_id NUMBER,
                                       x_preference_type NUMBER);

    /**
     * This will insert a record into the preference table.
     */
     PROCEDURE insert_preference(x_application_id NUMBER,
				 x_organization_id NUMBER,
				 x_user_id NUMBER,
				 x_preference_type NUMBER,
				 x_value VARCHAR2,
				 x_value_index NUMBER);

      PROCEDURE insert_preference(x_application_id NUMBER,
				 x_organization_id NUMBER,
				 x_user_id NUMBER,
				 x_preference_type NUMBER,
				 x_value VARCHAR2,
				  x_value_index NUMBER,
				  x_module_id NUMBER);



END WIP_WPS_PREFERENCES_PKG;

 

/
