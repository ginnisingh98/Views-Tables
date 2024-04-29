--------------------------------------------------------
--  DDL for Package Body WSH_DEBUG_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DEBUG_INTERFACE" as
/* $Header: WSHDBGIB.pls 115.5 2003/09/11 23:07:24 nparikh ship $ */

/*===========================================================================

PROCEDURE NAME:	start_debugger

DESCRIPTION	This procedure is used to turn on the Shipping Debugger by other
	        products

============================================================================*/
PROCEDURE start_debugger
	    (
	      p_dir_name IN VARCHAR2,
	      p_file_name IN VARCHAR2,
	      p_file_handle IN utl_file.file_type
	    )
IS
l_code_release_level VARCHAR2(30);
BEGIN

  l_code_release_level := WSH_CODE_CONTROL.Get_Code_Release_Level;
  --
  IF ( nvl(fnd_global.conc_request_id, -1)  > 0 )
  THEN
    If l_code_release_level >= '110509'
    THEN
        fnd_profile.put('WSH_DEBUG_MODE','T');
    ELSE
        fnd_profile.put('WSH_DEBUG_MODE','1');
    END IF;
    --
    g_debug := TRUE;
    g_file := NVL(p_file_name,'Dummy');
    --RETURN;
  END IF;
  --
  IF  p_dir_name  IS NOT NULL
  AND p_file_name IS NOT NULL
  AND utl_file.is_open(p_file_handle)
  THEN
    If l_code_release_level >= '110509'
    THEN
        fnd_profile.put('WSH_DEBUG_MODE','T');
    ELSE
        fnd_profile.put('WSH_DEBUG_MODE','1');
    END IF;
    fnd_profile.put('WSH_DEBUG_DIR',p_dir_name);
    g_file := p_file_name;
    g_file_handle := p_file_handle;
    g_debug := TRUE;
    --
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END start_debugger;


/*===========================================================================

PROCEDURE NAME:	stop_debugger

DESCRIPTION	This procedure is used to turn off the Shipping Debugger by other
	        products

============================================================================*/
PROCEDURE stop_debugger
IS
l_code_release_level VARCHAR2(30);
BEGIN

  l_code_release_level := WSH_CODE_CONTROL.Get_Code_Release_Level;
  --
  /*
  IF ( nvl(fnd_global.conc_request_id, -1)  > 0 )
  THEN
    fnd_profile.put('WSH_DEBUG_MODE','F');
    g_debug := FALSE;
    g_file := NULL;
    RETURN;
  END IF;
  --
  */

    If l_code_release_level >= '110509'
    THEN
        fnd_profile.put('WSH_DEBUG_MODE','F');
    ELSE
        fnd_profile.put('WSH_DEBUG_MODE','0');
    END IF;
    --fnd_profile.put('WSH_DEBUG_MODE','F');
    g_file := NULL;
    g_file_handle := NULL;
    g_debug := FALSE;

EXCEPTION
  WHEN OTHERS THEN
     NULL;
END stop_debugger;

END WSH_DEBUG_INTERFACE;

/
