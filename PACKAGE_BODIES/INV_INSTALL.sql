--------------------------------------------------------
--  DDL for Package Body INV_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INSTALL" AS
/* $Header: INVCKIB.pls 115.4 2002/02/12 17:54:00 pkm ship     $ */
/*
** -------------------------------------------------------------------------
** Function:    adv_inv_installed
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
  FUNCTION adv_inv_installed (p_organization_id IN NUMBER)
  RETURN BOOLEAN
  IS
  l_install boolean := TRUE;


g_pkg_name constant varchar2(50) := 'INV_CHECK_INSTALL';
l_msg_count    number;
l_msg_data     varchar2(10);
l_api_name		constant varchar(30) := 'inv_app_install';
l_return_status  varchar2(10);
begin
l_install := WMS_INSTALL.check_install
         (x_return_status => l_return_status
	, x_msg_count             => l_msg_count
	, x_msg_data              => l_msg_data
	,p_organization_id        => p_organization_id );

return l_install;

EXCEPTION
     WHEN OTHERS THEN
     if (fnd_msg_pub.check_msg_level
       	    (fnd_msg_pub.g_msg_lvl_unexp_error)) then
	    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
     end if;
     RETURN false;

END adv_inv_installed;


END INV_INSTALL;

/
