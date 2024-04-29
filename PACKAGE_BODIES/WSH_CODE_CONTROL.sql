--------------------------------------------------------
--  DDL for Package Body WSH_CODE_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CODE_CONTROL" as
/* $Header: WSHCRCNB.pls 120.0 2005/05/26 17:41:47 appldev noship $ */

   --
   G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_CODE_CONTROL';
   --
   Function Get_Code_Release_Level
   return varchar2
   is
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CODE_RELEASE_LEVEL';
   --
   Begin
      -- Bug#3772380: Removing the debug statements in the function
      /*
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
      */
      return WSH_CODE_CONTROL.CODE_RELEASE_LEVEL;
   End Get_Code_Release_Level;

End WSH_CODE_CONTROL;

/
