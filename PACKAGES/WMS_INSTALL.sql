--------------------------------------------------------
--  DDL for Package WMS_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_INSTALL" AUTHID CURRENT_USER AS
/* $Header: WMSINSTS.pls 120.1 2005/06/15 13:41:30 appldev  $ */
/*#
 * This package provides routine to verify that Oracle Warehouse Management
 * (WMS) is installed in the system and to determine whether or not an
 * organization is WMS enabled.
 * @rep:scope public
 * @rep:product WMS
 * @rep:lifecycle active
 * @rep:displayname WMS Install
 * @rep:category BUSINESS_ENTITY WMS_INSTALL
 */
/*
** -------------------------------------------------------------------------
** To prevent requery of database as much as possible within the same session,
** the following global variables are cached and used suitably:
**
** g_wms_installation_status :
** 	If 'I', indicates product WMS is installed
** g_organization_id:
**	The last organization that was checked if WMS enabled
** g_wms_enabled_flag :
**	Indicates if the last organization checked is WMS enabled or not
** -------------------------------------------------------------------------
*/
g_wms_installation_status varchar2(10);
g_organization_id         number;
g_wms_enabled_flag        varchar2(1);

/*
** -------------------------------------------------------------------------
** Function:    check_install
** Description: Checks to see if WMS is installed
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_organization_id
**	       -specific organization to be checked if WMS enabled.
**
**	       -if NULL, the check is just made at site level
**              and not for any specific organization.This is more relaxed than
**              passing a specific organization.
** Returns:
**      TRUE if WMS installed, else FALSE
**
**      Please use return value to determine if WMS is installed or not.
**      Do not use x_return_status for this purpose as
**      . x_return_status could be success and yet WMS not be installed.
**      . x_return_status is set to error when an error(such as SQL error)
**        occurs.
** --------------------------------------------------------------------------
*/

/*#
 * This routine can be used to check if Warehouse Management System is installed
 * and if an organization is WMS enabled.
 * @param x_return_status return variable holding the status of the procedure call
 * @param x_msg_count return variable holding the number of error messages returned
 * @param x_msg_data return variable holding the error message
 * @param p_organization_id specific organization to be checked if WMS enabled. if NULL, the check is just made at site level
 * @return if wms is installed or if the organization is wms enabled
 * @rep:displayname Check Install
*/
function check_install (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_organization_id             IN         NUMBER ) return boolean;

end WMS_INSTALL;

 

/
