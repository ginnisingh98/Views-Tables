--------------------------------------------------------
--  DDL for Package Body WMS_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_INSTALL" AS
/* $Header: WMSINSTB.pls 120.1 2005/06/15 13:45:22 appldev  $ */

-- Global constant holding package name
g_pkg_name constant varchar2(50) := 'WMS_INSTALL';

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
**             -specific organization to be checked if WMS enabled.
**
**             -if NULL, the check is just made at site level
**              and not for any specific organization.This is more relaxed than
**              passing a specific organization.
** Returns:
**	TRUE if WMS installed, else FALSE
**
**      Please use return value to determine if WMS is installed or not.
**      Do not use x_return_status for this purpose as
**      . x_return_status could be success and yet WMS not be installed.
**      . x_return_status is set to error when an error(such as SQL error)
**        occurs.
** --------------------------------------------------------------------------
*/

function check_install (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_organization_id             IN         NUMBER    ) return boolean is

-- constants
c_api_name		constant varchar(30) := 'check_install';

l_return_val         boolean := FALSE;

-- WMS has an application id of 385 in fnd_application table
l_wms_application_id constant number := 385;

l_status             varchar2(10);
l_industry           varchar2(10);
l_wms_enabled_flag   varchar2(1);

begin
    x_return_status := fnd_api.g_ret_sts_success ;

    /*
    ** Check if WMS is installed. Use cached value if available
    */

    if (g_wms_installation_status is not null) then
	l_status := WMS_INSTALL.g_wms_installation_status;
    else
    	l_return_val := fnd_installation.get(
			appl_id         => l_wms_application_id,
                        dep_appl_id 	=> l_wms_application_id,
                      	status      	=> l_status,
                        industry    	=> l_industry);

        WMS_INSTALL.g_wms_installation_status := l_status;
    end if;

    /*
    ** If WMS installed, proceed
    */
    if (l_status = 'I') then
	if p_organization_id is NULL then
		return TRUE;
	else
		/*
		** If the previous org checked for WMS enable is same as this org
		** reuse the cached value
		*/
		if (p_organization_id = WMS_INSTALL.g_organization_id) then
			l_wms_enabled_flag := WMS_INSTALL.g_wms_enabled_flag;
	        else
			select wms_enabled_flag
			into l_wms_enabled_flag
			from mtl_parameters
			where organization_id = p_organization_id;

			WMS_INSTALL.g_organization_id  := p_organization_id;
			WMS_INSTALL.g_wms_enabled_flag := l_wms_enabled_flag;
		end if;

		if (l_wms_enabled_flag in ('Y','y')) then
			return TRUE;
		else
			return FALSE;
		end if;
	end if;
    else
	return FALSE;
    end if;

    exception
      when others then
     	x_return_status := fnd_api.g_ret_sts_unexp_error ;

      	if (fnd_msg_pub.check_msg_level
       	    (fnd_msg_pub.g_msg_lvl_unexp_error)) then
	    fnd_msg_pub.add_exc_msg(g_pkg_name, c_api_name);
      	end if;

	return FALSE;
end check_install;
end WMS_INSTALL;

/
