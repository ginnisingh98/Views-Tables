--------------------------------------------------------
--  DDL for Package Body WSH_FTE_ENABLED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FTE_ENABLED" AS
/* $Header: WSHENBLB.pls 115.5 2002/11/12 01:33:30 nparikh noship $ */

-- Global constant for package name
g_pkg_name constant varchar2(50) := 'FTE_ENABLED';

/*
** -------------------------------------------------------------------------
** Function:    check_status
** Description: Checks to see if FTE is installed
** Output:
** Input:
**      There is no input parameter.
** Returns:
**	'Y' if FTE enabled, else 'N'
**
** --------------------------------------------------------------------------
*/

FUNCTION check_status return varchar2 is

-- constants
c_api_name		constant varchar2(30) := 'check_status';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_STATUS';
--
BEGIN
/* return "Y" since FTE is always enabled as of now
   to disable please replace Y with N in the return statement
   */
   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
   END IF;
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return 'Y';
EXCEPTION
      when others then

      	if (fnd_msg_pub.check_msg_level
       	    (fnd_msg_pub.g_msg_lvl_unexp_error)) then
	    fnd_msg_pub.add_exc_msg(g_pkg_name, c_api_name);
      	end if;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return 'N';
	--
END check_status;

END WSH_FTE_ENABLED;

/
