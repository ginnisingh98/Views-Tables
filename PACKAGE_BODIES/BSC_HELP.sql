--------------------------------------------------------
--  DDL for Package Body BSC_HELP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_HELP" AS
/* $Header: BSCUHLPB.pls 115.6 2003/02/12 14:30:04 adeulgao ship $ */


/*===========================================================================+
| FUNCTION Get_Help_Url
+============================================================================*/

FUNCTION Get_Help_Url(
	x_apps_name	IN VARCHAR2,
	x_target	IN VARCHAR2,
	x_help_system	IN NUMBER DEFAULT 1,
        x_target_type	IN VARCHAR2 DEFAULT 'TARGET',
	x_ret_status	OUT NOCOPY NUMBER
        ) RETURN VARCHAR2 IS
    l_help_system BOOLEAN;
    l_url	VARCHAR2(2000);	-- URL string.
    HELPERR	VARCHAR2(2000) := 'BSC_IHELP_FAIL'; -- generic error message.
    errmesg	VARCHAR2(2000);
BEGIN

    IF x_help_system = 1 THEN
	l_help_system := TRUE;
    ELSE
	l_help_system := FALSE;
    END IF;

    -- Call FND_HELP.Get_Url.
    l_url := FND_HELP.Get_Url(
		appsname	=> x_apps_name,
		target		=> x_target,
		HELPSYSTEM	=> l_help_system,
		TARGETTYPE	=> x_target_type);

    -- The FND method above may complete without exception,
    -- but could contain error message.  Signal failure and return
    -- error message instead.
    errmesg := fnd_message.get;
    IF errmesg IS NOT NULL THEN
	x_ret_status := -1;
	RETURN errmesg;
    END IF;

    -- The FND method above may return a null URL.  Signal failure
    -- and return a genric error message.
    IF l_url IS NULL THEN
	x_ret_status := -1;
	fnd_message.set_name('BSC', HELPERR);
	errmesg := fnd_message.get;
	RETURN errmesg;
    END IF;

    x_ret_status := 0;
    RETURN l_url;

EXCEPTION
    WHEN OTHERS THEN
	x_ret_status := -1;
	errmesg := fnd_message.get;
        -- Give a generic error message, if one does not yet exist.
        IF errmesg IS NULL THEN
	    fnd_message.set_name('BSC', HELPERR);
	    errmesg := fnd_message.get;
	END IF;
	RETURN errmesg;
END Get_Help_Url;


END BSC_HELP;

/
