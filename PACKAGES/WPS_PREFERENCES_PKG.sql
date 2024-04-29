--------------------------------------------------------
--  DDL for Package WPS_PREFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WPS_PREFERENCES_PKG" AUTHID CURRENT_USER AS
/* $Header: WPSPREFS.pls 120.1 2005/07/26 15:16:07 sjchen noship $ */

    /**
     * This will remove all the saved preferences for the given application/user
     * combination.
     */
     PROCEDURE delete_user_preferences(x_application_id NUMBER,
				       x_organization_id NUMBER,
				       x_user_id NUMBER);

    /**
     * This will insert a record into the preference table.
     */
     PROCEDURE insert_preference(x_application_id NUMBER,
				 x_organization_id NUMBER,
				 x_user_id NUMBER,
				 x_preference_type NUMBER,
				 x_value VARCHAR2,
				 x_value_index NUMBER);



END WPS_PREFERENCES_PKG;

 

/
