--------------------------------------------------------
--  DDL for Package Body INV_DEBUG_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DEBUG_INTERFACE" as
/* $Header: INVDBGIB.pls 115.2 2002/11/23 00:18:11 mdevassy noship $ */

/*===========================================================================

PROCEDURE NAME: start_inv_debugger

DESCRIPTION This procedure is used to turn on the Inventory Debugger by other
            products
============================================================================*/
PROCEDURE start_inv_debugger
            (
              p_dir_name IN VARCHAR2,
              p_file_name IN VARCHAR2,
              p_file_handle IN utl_file.file_type
            )
is
l_dir_file_name varchar2(256) ;
l_dir_separator  varchar2(1);
l_ndx            number;

BEGIN

  IF ( nvl(fnd_global.conc_request_id, -1)  > 0 )
  THEN
    fnd_profile.put('INV_DEBUG_LEVEL','10');
    fnd_profile.put('INV_DEBUG_TRACE',1);
    fnd_profile.put('INV_DEBUG_FILE','Dummy');
  RETURN;
  END IF;

  IF  p_dir_name  IS NOT NULL
  AND p_file_name IS NOT NULL
  AND  utl_file.is_open(p_file_handle)
  THEN
    fnd_profile.put('INV_DEBUG_LEVEL','10');
    fnd_profile.put('INV_DEBUG_TRACE',1);

    --- Concatenate directory and file name based on OS
    l_dir_separator := '/';
    l_ndx := instr(p_dir_name,l_dir_separator);
    if (l_ndx = 0) then
       l_dir_separator := '\';
    end if;
    l_dir_file_name := p_dir_name||l_dir_separator||p_file_name;

    fnd_profile.put('INV_DEBUG_FILE',l_dir_file_name);
       g_file_handle := p_file_handle;
    --
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END start_inv_debugger;


/*===========================================================================

PROCEDURE NAME: stop_inv_debugger

DESCRIPTION   This procedure is used to turn off the Inventory Debugger by other
              products

============================================================================*/
PROCEDURE stop_inv_debugger
IS
BEGIN

    fnd_profile.put('INV_DEBUG_LEVEL','NULL');
    fnd_profile.put('INV_DEBUG_TRACE',2);
    fnd_profile.put('INV_DEBUG_FILE',NULL);
    g_file_handle := NULL;

EXCEPTION
  WHEN OTHERS THEN
     NULL;
END stop_inv_debugger;

END INV_DEBUG_INTERFACE;

/
