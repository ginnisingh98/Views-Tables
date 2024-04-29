--------------------------------------------------------
--  DDL for Package BSC_LAUNCH_PAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_LAUNCH_PAD_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCLPADS.pls 115.6 2003/12/17 05:26:09 ashankar ship $ */

/* --------------------------APPS MENUS -------------------------*/
/*===========================================================================+
|
|   Name:          INSERT_APP_MENU_VB
|
|   Description:   it is a wrapper for FND_MENUS_PKG.INSERT_ROW function
|		   This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:	 x_menu_id - Menu id
|		 x_menu_name  - Menu Name
|		 x_user_menu_name - User Menu Name
|		 x_menu_type	  - Menu Type
|		 x_description    - Description
|		 x_user id 	  -User Id
|
|   Notes:
|
+============================================================================*/
PROCEDURE INSERT_APP_MENU_VB(X_MENU_ID in NUMBER,
	  X_MENU_NAME in VARCHAR2,
	  X_USER_MENU_NAME in VARCHAR2,
	  X_MENU_TYPE    in VARCHAR2,
	  X_DESCRIPTION in VARCHAR2,
	  X_USER_ID in NUMBER
	);
/*===========================================================================+
|
|   Name:          UPDATE_APP_MENU_VB
|
|   Description:   it is a wrapper for FND_MENUS_PKG.UPDATE_ROW function
|		   This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:	 x_menu_id - Menu id
|		 x_menu_name  - Menu Name
|		 x_user_menu_name - User Menu Name
|		 x_menu_type	  - Menu Type
|		 x_description    - Description
|		 x_user id 	  -User Id
|
|   Notes:
|
+============================================================================*/
PROCEDURE UPDATE_APP_MENU_VB(X_MENU_ID in NUMBER,
	  X_MENU_NAME in VARCHAR2,
	  X_USER_MENU_NAME in VARCHAR2,
	  X_MENU_TYPE    in VARCHAR2,
	  X_DESCRIPTION in VARCHAR2,
	  X_USER_ID in NUMBER
	);
/*===========================================================================+
|
|   Name:          DELETE_APP_MENU_VB
|
|   Description:   it is a wrapper for FND_MENUS_PKG.DELETE_ROW function
|		   This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:	 x_menu_id - Menu id
|
|   Notes:
|
+============================================================================*/
PROCEDURE DELETE_APP_MENU_VB(X_MENU_ID in NUMBER
	);

/*===========================================================================+
|
|   Name:          CHECK_MENU_NAMES
|
|   Description:   Check if the menu name and User name are unique to
|		   insert as a new menu.
|   Return :       'N' : Name Invalid, The name alreday exist
|                  'U' : User Name Invalid, The user name alreday exist
|                  'T' : True , The names don't exist. It can be added
|   Parameters:    X_MENU_ID 		Menu Id that will be inserted
| 	   	   X_MENU_NAME  	Menu Name
|      		   X_USER_MENU_NAME 	User Menu Name
+============================================================================*/
FUNCTION  CHECK_MENU_NAMES(X_MENU_ID in NUMBER,
	  X_MENU_NAME in VARCHAR2,
	  X_USER_MENU_NAME in VARCHAR2
	) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(CHECK_MENU_NAMES, WNDS);
/* --------------------------FORM FUNCTIONS -------------------------*/
/*===========================================================================+
|
|   Name:          INSERT_FORM_FUNCTION_VB
|
|   Description:   it is a wrapper for FND_FORM_FUNCTIONS_PKG.INSERT_ROW function
|		   This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
PROCEDURE INSERT_FORM_FUNCTION_VB(X_FUNCTION_ID in NUMBER,
	  X_WEB_HOST_NAME in VARCHAR2,
	  X_WEB_AGENT_NAME in VARCHAR2,
	  X_WEB_HTML_CALL in VARCHAR2,
	  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
	  X_WEB_SECURED in  VARCHAR2,
	  X_WEB_ICON  in VARCHAR2,
	  X_OBJECT_ID  in NUMBER,
	  X_REGION_APPLICATION_ID in NUMBER,
	  X_REGION_CODE  in VARCHAR2,
	  X_FUNCTION_NAME in VARCHAR2,
	  X_APPLICATION_ID in NUMBER,
	  X_FORM_ID  in NUMBER,
	  X_PARAMETERS in VARCHAR2,
	  X_TYPE    in VARCHAR2,
	  X_USER_FUNCTION_NAME in VARCHAR2,
	  X_DESCRIPTION in VARCHAR2,
	  X_USER_ID in NUMBER
	);
/*===========================================================================+
|
|   Name:          UPDATE_FORM_FUNCTION_VB
|
|   Description:   it is a wrapper for FND_FORM_FUNCTIONS_PKG.UPDATE_ROW function
|		   This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
PROCEDURE UPDATE_FORM_FUNCTION_VB(X_FUNCTION_ID in NUMBER,
	  X_WEB_HOST_NAME in VARCHAR2,
	  X_WEB_AGENT_NAME in VARCHAR2,
	  X_WEB_HTML_CALL in VARCHAR2,
	  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
	  X_WEB_SECURED in  VARCHAR2,
	  X_WEB_ICON  in VARCHAR2,
	  X_OBJECT_ID  in NUMBER,
	  X_REGION_APPLICATION_ID in NUMBER,
	  X_REGION_CODE  in VARCHAR2,
	  X_FUNCTION_NAME in VARCHAR2,
	  X_APPLICATION_ID in NUMBER,
	  X_FORM_ID  in NUMBER,
	  X_PARAMETERS in VARCHAR2,
	  X_TYPE    in VARCHAR2,
	  X_USER_FUNCTION_NAME in VARCHAR2,
	  X_DESCRIPTION in VARCHAR2,
	  X_USER_ID in NUMBER
	);
/*===========================================================================+
|
|   Name:          DELETE_FORM_FUNCTION_VB
|
|   Description:   it is a wrapper for FND_FORM_FUNCTIONS_PKG.DELETE_ROW function
|		   This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
PROCEDURE DELETE_FORM_FUNCTION_VB(X_FUNCTION_ID in NUMBER
	);
/*===========================================================================+
| FUNCTION CHECK_FUNCTION_NAMES
|
|   Name:          CHECK_FUNCTION_NAMES
|
|   Description:   Check if the fucntion name and User name are unique to
|		   insert as a new function.
|   Return :       'N' : Name Invalid, The name alreday exist
|                  'U' : User Name Invalid, The user name alreday exist
|                  'T' : True , The names don't exist. It can be added
|   Parameters:    X_FUNCTION_ID 		Menu Id that will be inserted
| 	   	   X_FUNCTION_NAME  	Menu Name
|      		   X_USER_FUNCTION_NAME	User Menu Name
+============================================================================*/

FUNCTION  CHECK_FUNCTION_NAMES(X_FUNCTION_ID in NUMBER,
	  X_FUNCTION_NAME in VARCHAR2,
	  X_USER_FUNCTION_NAME in VARCHAR2
	) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(CHECK_FUNCTION_NAMES, WNDS);

/* --------------------------APPS MENU-ENTRIES -------------------------*/
/*===========================================================================+
|
|   Name:          INSERT_APP_MENU_ENTRIES_VB
|
|   Description:   it is a wrapper for FND_MENU_ENTRIES_PKG.INSERT_ROW  function
|		   This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
PROCEDURE INSERT_APP_MENU_ENTRIES_VB(X_MENU_ID in NUMBER,
	  X_ENTRY_SEQUENCE in NUMBER,
	  X_SUB_MENU_ID  in NUMBER,
	  X_FUNCTION_ID in NUMBER,
	  X_GRANT_FLAG  in VARCHAR2,
	  X_PROMPT      in VARCHAR2,
	  X_DESCRIPTION in VARCHAR2,
	  X_USER_ID in NUMBER
	);
/*===========================================================================+
|
|   Name:          UPDATE_APP_MENU_ENTRIES_VB
|
|   Description:   it is a wrapper for FND_MENU_ENTRIES_PKG.UPDATE_ROW  function
|		   This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
PROCEDURE UPDATE_APP_MENU_ENTRIES_VB(X_MENU_ID in NUMBER,
	  X_ENTRY_SEQUENCE in NUMBER,
	  X_SUB_MENU_ID  in NUMBER,
	  X_FUNCTION_ID in NUMBER,
	  X_GRANT_FLAG  in VARCHAR2,
	  X_PROMPT      in VARCHAR2,
	  X_DESCRIPTION in VARCHAR2,
	  X_USER_ID in NUMBER
	);
/*===========================================================================+
|
|   Name:          DELETE_APP_MENU_ENTRIES_VB
|
|   Description:   it is a wrapper for FND_MENU_ENTRIES_PKG.DELETE_ROW  function
|		   This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
PROCEDURE DELETE_APP_MENU_ENTRIES_VB(X_MENU_ID in NUMBER,
	  X_ENTRY_SEQUENCE in NUMBER
	);

/* --------------------------APPS SECURITY -------------------------*/
/*===========================================================================+
|
|   Name:          SECURITY_RULE_EXISTS_VB
|
|   Description:   it is a wrapper for FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS function
|		   This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:
+============================================================================*/
FUNCTION SECURITY_RULE_EXISTS_VB(responsibility_key in varchar2,
	  rule_type in varchar2 default 'F',  -- F = Function, M = Menu
	  rule_name in varchar2
	) RETURN VARCHAR2;
/*===========================================================================+
| FUNCTION SECURITY_ACCESS_MENU
|
|   Name:          SECURITY_ACCESS_MENU
|
|   Description:   It verifies if a Responsibility has acces to a menu or not
|   Return :       'T' : It has access
|                  'F' : It doesn't have access
|   Parameters:    X_RESPO 		Responsibility
| 	   	   X_MENU_ID 		Menu Id
+============================================================================*/

FUNCTION  SECURITY_ACCESS_MENU(X_RESPO in NUMBER,
	  X_MENU_ID  in NUMBER
	) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(SECURITY_ACCESS_MENU, WNDS);


/*===========================================================================+
| FUNCTION Migrate_Custom_Links
|
|   Description:   Migrate custom links from the source system.
|                  It creates the menu in the target system in case it does
|                  not exist and it is a BSC menu.
|                  It creates unexisting BSC functions inside the menus.
|                  It never update or delete an existing menu or function.
|
|   Return :       TRUE : no errors
|                  FALSE : error
|
|   Parameters:    x_src_db_link	source db link.
+============================================================================*/
FUNCTION Migrate_Custom_Links(
	x_src_db_link IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
| FUNCTION Migrate_Custom_Links_Security
|
|   Description:   Assing the custom links (menus) to the target responsibility
|                  according to the source responsibility.
|                  Only add BSC menus to the target responsibility.
|
|   Return :       TRUE : no errors
|                  FALSE : error
|
+============================================================================*/
FUNCTION Migrate_Custom_Links_Security(
	x_trg_resp IN NUMBER,
	x_src_resp IN NUMBER,
	x_src_db_link IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
| FUNCTION is_Launch_Pad_Attached
|
|   Description:   This fucntion will validate whether the launchpad is attached
|                  to the root application menu or not
|   Return :       TRUE  : launchpad is attached
|                  FALSE : not attached
|
+============================================================================*/
FUNCTION is_Launch_Pad_Attached
(
     p_Menu_Id        IN   FND_MENUS.menu_id%TYPE
   , p_Sub_Menu_Id    IN   FND_MENUS.menu_id%TYPE

) RETURN BOOLEAN;

/*===========================================================================+
| FUNCTION is_Launch_Pad_Attached
|
|   Description:   This function will return the entry sequence of the launchpad
|                  in the root application menu
|   Return :       entry sequence
|
+============================================================================*/

FUNCTION get_entry_sequence
(
     p_Menu_Id        IN  FND_MENUS.menu_id%TYPE
   , p_Sub_Menu_Id    IN  FND_MENUS.menu_id%TYPE
) RETURN NUMBER;

END BSC_LAUNCH_PAD_PVT;

 

/
