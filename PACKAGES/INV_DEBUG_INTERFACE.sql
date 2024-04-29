--------------------------------------------------------
--  DDL for Package INV_DEBUG_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DEBUG_INTERFACE" AUTHID CURRENT_USER as
/* $Header: INVDBGIS.pls 115.2 2002/11/23 00:17:27 mdevassy noship $ */
g_file_handle utl_file.file_type;

/*===========================================================================

PROCEDURE NAME: start_inv_debugger

DESCRIPTION    This procedure is used to turn on the Inventory Debugger by other
               products

                All parameters are mandatory.

============================================================================*/
PROCEDURE start_inv_debugger
            (
              p_dir_name IN VARCHAR2,
              p_file_name IN VARCHAR2,
              p_file_handle IN utl_file.file_type
            );


/*===========================================================================

PROCEDURE NAME: stop_inv_debugger

DESCRIPTION   This procedure is used to turn off the Inventory Debugger by other
              products

============================================================================*/
PROCEDURE stop_inv_debugger;

END INV_DEBUG_INTERFACE;

 

/
