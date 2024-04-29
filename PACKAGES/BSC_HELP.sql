--------------------------------------------------------
--  DDL for Package BSC_HELP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_HELP" AUTHID CURRENT_USER AS
/* $Header: BSCUHLPS.pls 115.6 2003/02/12 14:30:06 adeulgao ship $ */


/*===========================================================================+
|
|   Name:          Get_Help_Url
|
|   Description:   This function creates the URL to launch the help system
|		   with help document based on the specified target.
|
|   Parameters:    x_apps_name - Application short name for the application
|			that owns the help documen.
|                  x_target - Name of the help target.
|                  x_help_system - Indicates whether user wants to launch
|			full help system.  If 0, means they just want
|			to fetch the document.
|		   x_target_type - Specifies whether the target is a help
|			target or file name.  Valid values are 'TARGET'
|			or 'FILE'.
|		   x_ret_status - OUT NOCOPY parameter.  Return status.
|			If 0, means this function completed successfully.
|			If -1, means error occurred.
|
|   Returns:       If any error occurs, returns error message.  Otherwise,
|		   returns the URL.
|
|   Notes:
|
+============================================================================*/

FUNCTION Get_Help_Url(
	x_apps_name	IN VARCHAR2,
	x_target	IN VARCHAR2,
	x_help_system	IN NUMBER DEFAULT 1,
        x_target_type	IN VARCHAR2 DEFAULT 'TARGET',
	x_ret_status	OUT NOCOPY NUMBER
        ) RETURN VARCHAR2;


END BSC_HELP;

 

/
