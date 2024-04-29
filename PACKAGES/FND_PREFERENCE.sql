--------------------------------------------------------
--  DDL for Package FND_PREFERENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PREFERENCE" AUTHID CURRENT_USER AS
/* $Header: AFTCPRFS.pls 115.9 2002/04/15 14:28:49 pkm ship      $ */



-- Each row of the record contains the name of the preference, value and action
-- to be performed it e.g. I- insert, U-update, D-delete.

 TYPE prefs_rec_type IS RECORD(name VARCHAR2(30),value VARCHAR2(240),
			       action VARCHAR2(1));

 TYPE prefs_tab_type IS TABLE OF prefs_rec_type INDEX BY BINARY_INTEGER;

 -- Get the value of the given preference.

 FUNCTION get(p_user_name IN VARCHAR2,
	      p_module_name IN VARCHAR2,
	      p_pref_name IN VARCHAR2) RETURN VARCHAR2;


 -- Get the value of the given encrypted preference.
 --    Note: length of p_key value must be an exact multiple of 8.

 FUNCTION eget(p_user_name   IN VARCHAR2,
	       p_module_name IN VARCHAR2,
	       p_pref_name   IN VARCHAR2,
               p_key         IN VARCHAR2) RETURN VARCHAR2;


 -- Get the value of a preference.
 --    Note: Returns *NULL* for blank preferences
 --                  *UNKNOWN* for missing preferences

 FUNCTION GetDefined(p_user_name   IN VARCHAR2,
                     p_module_name IN VARCHAR2,
                     p_pref_name   IN VARCHAR2) RETURN VARCHAR2;


 -- Updates the value of the preference if it exists, otherwise creates it.

 PROCEDURE put(p_user_name IN VARCHAR2,
	       p_module_name IN VARCHAR2,
	       p_pref_name IN VARCHAR2,
	       p_pref_value IN VARCHAR2);


 -- Updates the value of the encrypted preference if it exists,
 -- otherwise creates it.
 --    Note: length of p_key value must be an exact multiple of 8.

 PROCEDURE eput(p_user_name   IN VARCHAR2,
	        p_module_name IN VARCHAR2,
	        p_pref_name   IN VARCHAR2,
	        p_pref_value  IN VARCHAR2,
                p_key         IN VARCHAR2);


 -- Updates the value of the preference if it exists, otherwise creates it
 --    If pref_value is *NULL*, blanks out value
 --    If pref_value is *UNKNOWN*, does nothing

 PROCEDURE putDefined(p_user_name   IN VARCHAR2,
                      p_module_name IN VARCHAR2,
                      p_pref_name   IN VARCHAR2,
                      p_pref_value  IN VARCHAR2);


 -- Returns true or false depending on whether the prefernce exits in the
 -- table or not.

 FUNCTION exists(p_user_name IN VARCHAR2,
		 p_module_name IN VARCHAR2,
		 p_pref_name IN VARCHAR2) RETURN BOOLEAN ;


 -- Deletes the preference from the table.

 PROCEDURE remove(p_user_name IN VARCHAR2,
		  p_module_name IN VARCHAR2,
		  p_pref_name IN VARCHAR2);


 -- Removes all preference information for one user and module.

 PROCEDURE delete_all(p_user_name IN VARCHAR2,
		      p_module_name IN VARCHAR2);


 -- Saves information for many preferences belonging to one user and module.

 PROCEDURE save_changes(p_user_name IN VARCHAR2,
			p_module_name IN VARCHAR2,
			p_prefs_tab IN prefs_tab_type);


END;

 

/

  GRANT EXECUTE ON "APPS"."FND_PREFERENCE" TO "EM_OAM_MONITOR_ROLE";
