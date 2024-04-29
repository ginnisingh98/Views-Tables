--------------------------------------------------------
--  DDL for Package Body INV_CHECK_PRODUCT_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CHECK_PRODUCT_INSTALL" AS
/* $Header: INVNLINB.pls 120.0 2005/05/25 05:45:13 appldev noship $ */

-- Global constant holding package name
g_pkg_name constant varchar2(50) := 'INV_CHECK_PRODUCT_INSTALL';

/*
** -------------------------------------------------------------------------
** Function:    check_cse_install
** Description: Checks to see if CSE is installed
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
** Returns:
**	'Y' if CSE installed, else 'N'
**
**      Please use return value to determine if WMS is installed or not.
**      Do not use x_return_status for this purpose as
**      . x_return_status could be success and yet WMS not be installed.
**      . x_return_status is set to error when an error(such as SQL error)
**        occurs.
** --------------------------------------------------------------------------
*/

PROCEDURE check_install
         (p_application_id              IN  VARCHAR2
        , p_dep_application_id          IN  VARCHAR2
        , x_product_installed           OUT NOCOPY VARCHAR2
        , x_industry                    OUT NOCOPY VARCHAR2
        , x_return_status               OUT NOCOPY VARCHAR2
        , x_msg_count                   OUT NOCOPY NUMBER
        , x_msg_data                    OUT NOCOPY VARCHAR2) IS
l_installed	    BOOLEAN;
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS ;
      l_installed := fnd_installation.get(appl_id     => p_application_id,
                                          dep_appl_id => p_dep_application_id,
                                          status      => x_product_installed,
                                          industry    => x_industry);

      IF NOT l_installed  THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_product_installed := 'N';
      END IF;
EXCEPTION
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END check_install;

FUNCTION check_cse_install (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
 ) RETURN BOOLEAN IS

-- constants
c_api_name		constant varchar(30) := 'check_cse_install';

l_return_val         boolean := FALSE;
l_status VARCHAR2(1);
l_industry VARCHAR2(30);
l_schema VARCHAR2(30);

begin
    x_return_status := fnd_api.g_ret_sts_success ;

    if (g_cse_installation_status is not null) then
        l_status := INV_CHECK_PRODUCT_INSTALL.g_cse_installation_status;
    else
        l_return_val := fnd_installation.get_app_info(application_short_name => 'CSE',
						status  => l_status,
						Industry => l_industry,
						oracle_schema => l_schema);
    end if;
    if (l_status='I') then return TRUE;
    else return FALSE;
    end if;
    exception
      when others then
     	x_return_status := fnd_api.g_ret_sts_unexp_error ;

      	if (fnd_msg_pub.check_msg_level
       	    (fnd_msg_pub.g_msg_lvl_unexp_error)) then
	    fnd_msg_pub.add_exc_msg(g_pkg_name, c_api_name);
      	end if;

	return FALSE;
end check_cse_install;

FUNCTION check_cse_install return varchar2 is
l_return_val         boolean := FALSE;
l_status VARCHAR2(1);
l_industry VARCHAR2(30);
l_schema VARCHAR2(30);

BEGIN
if (g_cse_installation_status is not null) then
    l_status := inv_check_product_install.g_cse_installation_status;
else
    l_return_val := fnd_installation.get_app_info(application_short_name => 'CSE',
                                                status  => l_status,
                                                Industry => l_industry,
                                                oracle_schema => l_schema);
    INV_CHECK_PRODUCT_INSTALL.g_cse_installation_status := l_status;
end if;
    if (l_status='I') then return 'Y';
    else return 'N';
    end if;
EXCEPTION
      when others then
          return 'N';
END check_cse_install;

PROCEDURE check_eam_installed
         (x_eam_installed               OUT NOCOPY VARCHAR2
        , x_industry                    OUT NOCOPY VARCHAR2
        , x_return_status               OUT NOCOPY VARCHAR2
        , x_msg_count                   OUT NOCOPY NUMBER
        , x_msg_data                    OUT NOCOPY VARCHAR2) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS ;
   IF inv_check_product_install.g_eam_installed is NULL THEN
      check_install
                      (p_application_id              => 426
                     , p_dep_application_id          => 426
                     , x_product_installed           => x_eam_installed
                     , x_industry                    => x_industry
                     , x_return_status               => x_return_status
                     , x_msg_count                   => x_msg_count
                     , x_msg_data                    => x_msg_data ) ;
      g_eam_installed := x_eam_installed;
   ELSE
      x_eam_installed := g_eam_installed;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END check_eam_installed;

PROCEDURE check_fte_installed
         (x_fte_installed               OUT NOCOPY VARCHAR2
        , x_industry                    OUT NOCOPY VARCHAR2
        , x_return_status               OUT NOCOPY VARCHAR2
        , x_msg_count                   OUT NOCOPY NUMBER
        , x_msg_data                    OUT NOCOPY VARCHAR2) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS ;
   IF inv_check_product_install.g_fte_installed is NULL THEN
      check_install(p_application_id              => 716
		    , p_dep_application_id          => 716
		    , x_product_installed           => x_fte_installed
		    , x_industry                    => x_industry
		    , x_return_status               => x_return_status
		    , x_msg_count                   => x_msg_count
		    , x_msg_data                    => x_msg_data ) ;
      g_fte_installed := x_fte_installed;
   ELSE
      x_fte_installed := g_fte_installed;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END check_fte_installed;

END INV_CHECK_PRODUCT_INSTALL;

/
