--------------------------------------------------------
--  DDL for Package WSH_DEBUG_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DEBUG_INTERFACE" AUTHID CURRENT_USER as
/* $Header: WSHDBGIS.pls 115.3 2002/11/12 22:11:39 nparikh noship $ */

g_file VARCHAR2(32767);
g_file_handle utl_file.file_type;
g_debug BOOLEAN := NULL;

/*===========================================================================

PROCEDURE NAME:	start_debugger

DESCRIPTION	This procedure is used to turn on the Shipping Debugger by other
	        products

		Both parameters are mandatory.

============================================================================*/
PROCEDURE start_debugger
	    (
	      p_dir_name IN VARCHAR2,
	      p_file_name IN VARCHAR2,
	      p_file_handle IN utl_file.file_type
	    );


/*===========================================================================

PROCEDURE NAME:	stop_debugger

DESCRIPTION	This procedure is used to turn off the Shipping Debugger by other
	        products

============================================================================*/
PROCEDURE stop_debugger;

END WSH_DEBUG_INTERFACE;

 

/
