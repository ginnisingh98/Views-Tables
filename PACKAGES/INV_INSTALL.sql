--------------------------------------------------------
--  DDL for Package INV_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INSTALL" AUTHID CURRENT_USER AS
/* $Header: INVCKIS.pls 115.3 2002/02/12 17:54:02 pkm ship     $ */

g_pkg_name constant varchar2(50) := 'INV_INSTALL';

/*
** -------------------------------------------------------------------------
** Function:    adv_inv_install
** Description: Checks to see if WMS is installed
** Input:       None
** Output:
**      none
** Returns:
**      TRUE if WMS installed, else FALSE
**
**
** --------------------------------------------------------------------------
*/
  FUNCTION ADV_INV_INSTALLED (p_organization_id NUMBER)
  RETURN BOOLEAN;

END INV_INSTALL;

 

/
