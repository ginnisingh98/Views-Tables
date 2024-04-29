--------------------------------------------------------
--  DDL for Package Body WSH_FACILITIES_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FACILITIES_INTEGRATION" as
/* $Header: WSHFACIB.pls 115.1 2003/09/05 01:38:21 arguha noship $ */

 --
 G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_FACILITIES_INTEGRATION';
 --

 ---------------------------------------------------------
 -- Start of comments
 -- API name : Create_Facilities
 -- Type     : Private
 -- Pre-reqs : None.
 -- Function : 1. Create a new facility (row in FTE_LOCATION_PARAMETERS) for each
 --               location id specified in the input table p_location_ids.
 --            NOTE: It is recommended, but not required to pass in the corresponding
 --                  <p_company_names> and <p_site_names>.
 --                  (a). If both <p_company_names> and <p_site_names> are not null,
 --                       the facility codes are generated from a combination of
 --                       the location's company_name and site_name. (See function
 --                       Create_Description)
 --                  (b). If the <p_company_names> is NOT null but <p_site_names> is
 --                       null, the facility codes are derived from the company names.
 --                  (c). If both <p_company_names> AND <p_site_names> are null,
 --                       a query is used to obtain the company_name and site_name for
 --                       each location_id (See Fetch_Facility_Descriptions). Caching
 --                       is used to make more efficient.
 --
 -- PARAMETERS :
 -- IN Parameters:
 --   1.  p_location_ids   WSH_LOCATIONS_PKG.ID_Tbl_Type            (Required)
 --                        The location ids for the facilities.
 --
 --   2.  p_company_names  WSH_LOCATIONS_PKG.Address_Tbl_Type       (Not Required)
 --                        Corresponding company names for each
 --                        location ID.
 --   3.  p_site_names     WSH_LOCATIONS_PKG.LocationCode_Tbl_Type  (Not Required)
 --                        Corresponding site names for the
 --                        location ids, if applicable.
 --
 -- OUT Parameters :  x_return_status    VARCHAR2
 --                   The return status is one of the following:
 --                   i.   WSH_UTIL_CORE.G_RET_STS_SUCCESS: All facilities created.
 --                   iv.  WSH_UTIL_CORE.G_RET_STS_WARNING: If some of the location_ids
 --                        already had facilities created.
 --                   iv.  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
 -- Version : 1.0
 -- Previous version 1.0
 -- Initial version 1.0
 -- End of comments
 -----------------------------------------------------------------------------------
PROCEDURE Create_Facilities (p_location_ids   IN   WSH_LOCATIONS_PKG.ID_Tbl_Type,
                             p_company_names  IN   WSH_LOCATIONS_PKG.Address_Tbl_Type,
                             p_site_names     IN   WSH_LOCATIONS_PKG.LocationCode_Tbl_Type,
                             x_return_status  OUT  NOCOPY  VARCHAR2,
                             x_error_msg      OUT  NOCOPY  VARCHAR2) IS

--
-- Variables used for debugging
--
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Facilities';

BEGIN
  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
  END IF;

  IF WSH_UTIL_CORE.FTE_Is_Installed = 'Y' THEN
     FTE_LOCATION_PARAMETERS_PKG.Create_Facilities( p_location_ids  => p_location_ids,
                                                    p_company_names => p_company_names,
                                                    p_site_names    => p_site_names,
                                                    x_return_status => x_return_status,
                                                    x_error_msg     => x_error_msg);
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_error_msg := SQLERRM;
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,
                             'UNEXP. ERROR IN WSH_FACILITIES_INTEGRATION.Create_Facilities: '|| x_error_msg);
         WSH_DEBUG_SV.logmsg(l_module_name,
                             'Error message is '|| SQLERRM, WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
END Create_Facilities;
 ------------------------------------------------------------------

END WSH_FACILITIES_INTEGRATION;

/
