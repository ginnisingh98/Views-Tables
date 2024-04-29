--------------------------------------------------------
--  DDL for Package Body WSH_UTIL_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_UTIL_CORE" as
/* $Header: WSHUTCOB.pls 120.21.12010000.7 2009/12/03 10:35:42 mvudugul ship $ */

  /* H projects: pricing integration csun
	 add global variable to cache the value so in the same session
	 the call to fnd to check if fte is installed is called only once */

  G_OTM_PROFILE_VALUE VARCHAR2(1) := NULL; -- OTM R12
  G_FTE_IS_INSTALLED  VARCHAR2(1) := NULL;
  G_TP_IS_INSTALLED   VARCHAR2(1) := NULL;
  G_WMS_IS_INSTALLED  VARCHAR2(1) := NULL;
  c_wms_code_present  VARCHAR2(1) := 'Y';

  -- used by procedure Get_Currency_Conversion_Type
  G_CURRENCY_CONVERSION_TYPE VARCHAR2(30) := NULL;
  --
  -- PACKAGE VARIABLES
  --

  -- Description:	Variable to suppress printing of messages to
  --			file. This should be set to 'Y' by concurrent
  --			programs before they use the println and print
  --			procedures
  G_ALLOW_PRINT	VARCHAR2(1) := 'N';

  -- Description:	Variable to count the number of records in the
  --			PL/SQL table-g_loc_desc_Tab.This helps in maintaining
  --				the latest record in the table and deleting the
  --					oldest record.
  G_COUNT_RECORDS  NUMBER := 0;

  -- Description:	Variable to set the debug level.
  --			This should be set greater than 0 by concurrent
  --			programs before they can use the println and print
  --			procedures

  G_LOG_LEVEL	NUMBER := 0;
  --

  -- PACKAGE CONSTANTS
  --

  -- Description:	Constant used to control maximum number of characters
  --					that a debug string can take
  G_MAX_LENGTH		CONSTANT	NUMBER := 239;

  G_STORE_MSG_IN_TABLE   BOOLEAN default FALSE ;

  g_cust_Id_Tab Id_Tab_Type;
  g_org_Id_Tab Id_Tab_Type;
  g_master_org_tab Id_Tab_Type;


 --  Description:	  Generic tab of records for passing column information
  g_loc_desc_Tab Loc_Info_Tab;
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_UTIL_CORE';

    --Cache size constant
    g_cache_max_size		NUMBER := power(2,31);
    --

    --Cache for retriving Customer/Supplier/Carrier/Organization from locations.
    g_customer_from_location            WSH_UTIL_CORE.tbl_varchar;
    g_organization_from_location	WSH_UTIL_CORE.tbl_varchar;

    --

  --
  -- FUNCTION:		Get_Location_Description
  -- Purpose:		Function gives a description of the location
  --			based on the location_id
  -- Arguments:		p_location_id - Location identifier
  --			p_format - Format for description
  -- Return Values:	 Returns a description of the location in VARCHAR2
  -- Notes:		p_format supports the following:
  --			'CSZ' - City, State, Zip
  --			'CSZC' - City, State, Zip, Country
  --			'CODE' - Location Code (Should be called for DSNO
  --                      ONLY
  --			'NEW UI CODE' - Location Code generated for UI display
  --			'NEW UI CODE INFO' - Detailed Loc for UI (bug 1516290)
  --

  FUNCTION Get_Location_Description (
		p_location_id	IN	NUMBER,
		p_format	IN	VARCHAR2
		) RETURN VARCHAR2 IS


  l_loc_string	VARCHAR2(1000);
  l_exists_flag VARCHAR2(1):= 'N';
  l_counter NUMBER := 0;

  CURSOR Loc_Info_Cur (v_location_id NUMBER) IS
    SELECT                       wsh_location_id
                               ,source_location_id
                               ,location_source_code
                               ,location_code
                               ,address1
                               ,city
                               ,state
                               ,country
                               ,postal_code
                               ,ui_location_code
                               , NULL -- hr_location_code
    FROM            wsh_locations
    where           wsh_location_id = v_location_id;

    CURSOR c_hr_locs (v_location_id NUMBER) IS
      SELECT b.location_code
      FROM hr_locations_all a,
           hr_locations_all_tl b
      WHERE  a.location_id = v_location_id
      AND   a.location_id = b.location_id
      AND   b.language=USERENV('LANG');

l_index		NUMBER;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_LOCATION_DESCRIPTION';

  --
  BEGIN
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
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_FORMAT',P_FORMAT);
	END IF;
	--
	IF p_location_id IS NULL THEN
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN NULL;
	END IF;

	IF g_loc_desc_Tab.count > 0 THEN
          l_index := g_loc_desc_Tab.FIRST;
          WHILE l_index IS NOT NULL LOOP
		IF g_loc_desc_Tab(l_index).wsh_location_id = p_location_id THEN
		  l_exists_flag := 'Y';
		  /* index of the current record */
		  l_counter := l_index;
		  EXIT;
		END IF;

                l_index := g_loc_desc_Tab.NEXT(l_index);
	  END LOOP;
	END IF;

	IF l_exists_flag = 'N' THEN
	  G_COUNT_RECORDS := MOD(G_COUNT_RECORDS + 1,10);
	  OPEN Loc_Info_Cur (p_location_id);
	  FETCH Loc_Info_Cur INTO g_loc_desc_Tab(G_COUNT_RECORDS);
	  IF Loc_Info_Cur%NOTFOUND THEN
		IF Loc_Info_Cur%ISOPEN THEN
			CLOSE Loc_Info_Cur;
		END IF;
		IF l_debug_on THEN
	            WSH_DEBUG_SV.log(l_module_name,'Loc_Info_Cur%NOTFOUND');
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
                RETURN NULL;
	  END IF;
          CLOSE Loc_Info_Cur;
	  /* index of the current record, afterincrementing */
	  l_counter := G_COUNT_RECORDS;

	END IF;

	IF p_format = 'CODE' THEN
          IF g_loc_desc_Tab(l_counter).location_source_code = 'HZ' THEN
	     l_loc_string
                       := to_char(g_loc_desc_Tab(l_counter).source_location_id);
          ELSE
             IF g_loc_desc_Tab(l_counter).hr_location_code IS NULL THEN
                OPEN c_hr_locs(g_loc_desc_Tab(l_counter).source_location_id) ;
                FETCH c_hr_locs INTO g_loc_desc_Tab(l_counter).hr_location_code;
                  IF c_hr_locs%NOTFOUND THEN
                    CLOSE c_hr_locs;
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'c_hr_locs%NOTFOUND');
                    END IF;
                  END IF;
                CLOSE c_hr_locs;
             END IF;
             l_loc_string := g_loc_desc_Tab(l_counter).hr_location_code;
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'hr_location_code',l_loc_string);
             END IF;
          END IF;

	ELSIF p_format = 'NEW UI CODE' THEN
	   l_loc_string := g_loc_desc_Tab(l_counter).location_code ||
           ':' || NVL(g_loc_desc_Tab(l_counter).city,
                         substrb(g_loc_desc_Tab(l_counter).address1,1,60)) ;



	ELSIF p_format = 'NEW UI CODE INFO' THEN
	   l_loc_string := g_loc_desc_Tab(l_counter).ui_location_code;

	ELSIF	(p_format = 'CSZ' OR p_format = 'CSZC') THEN

	  IF g_loc_desc_Tab(l_counter).city IS NOT NULL THEN
		l_loc_string := l_loc_string || g_loc_desc_Tab(l_counter).city;
	  END IF;
	  IF g_loc_desc_Tab(l_counter).state IS NOT NULL THEN
		l_loc_string := l_loc_string || ', ' || g_loc_desc_Tab(l_counter).state;
	  END IF;
	  IF g_loc_desc_Tab(l_counter).postal_code IS NOT NULL THEN
		l_loc_string := l_loc_string || ', ' || g_loc_desc_Tab(l_counter).postal_code;
	  END IF;
	  IF	 g_loc_desc_Tab(l_counter).country IS NOT NULL
		 AND p_format <> 'CSZ' THEN
		l_loc_string := l_loc_string || ', ' || g_loc_desc_Tab(l_counter).country;
	  END IF;
        ELSE -- bad format_code
           FND_MESSAGE.SET_NAME('WSH','WSH_PUB_INVALID_PARAMETER');
           FND_MESSAGE.Set_Token('PARAMETER',p_format);
           wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,
                                                           l_module_name);
           IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
/*
l_loc_string := 'WRONG'|| g_loc_desc_Tab(l_counter).location_code;
*/
	END IF;
	IF Loc_Info_Cur%ISOPEN THEN
	  CLOSE Loc_Info_Cur;
	END IF;

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN l_loc_string;

  EXCEPTION
   WHEN others THEN
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      raise;
   END IF;

  END Get_Location_Description;
 --
 -- PROCEDURE: Site_Code_to_Site_id
 -- PURPOSE  : Maps site_code to site_id
 -- ARGUMENTS : p_site_code - site code that needs to be mapped
 --			 p_site_id - site id for the code
 --			 x_return_status - WSH_UTIL_CORE.G_RET_STS_SUCCESS or NOT
 --

  PROCEDURE Site_Code_to_Site_id(p_site_code		 IN	  VARCHAR2,
								 p_site_id		   OUT NOCOPY 	 NUMBER,
								 x_return_status	 OUT NOCOPY 	 VARCHAR2) IS

  CURSOR get_id (c_site_code VARCHAR2) IS
  select SITE_USE_ID from HZ_CUST_SITE_USES_ALL
  where SITE_USE_CODE = c_site_code;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SITE_CODE_TO_SITE_ID';
--
  BEGIN

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
      --
      WSH_DEBUG_SV.log(l_module_name,'P_SITE_CODE',P_SITE_CODE);
  END IF;
  --
  p_site_id := NULL;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  OPEN get_id(p_site_code);
  FETCH get_id INTO p_site_id;
  CLOSE get_id;

  IF (p_site_id IS NULL) THEN
		  FND_MESSAGE.Set_Name('WSH','WSH_SITE_LOCATION_UNDEFINED');
		  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		  IF get_id%ISOPEN THEN
			CLOSE get_id;
		  END IF;
  END IF;

 --
 -- Debug Statements
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
 END IF;
 --
  Exception
  when others then
   IF get_id%ISOPEN THEN
			CLOSE get_id;
   END IF;
   wsh_util_core.default_handler('WSH_UTIL_CORE.Site_Code_to_Site_id');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Site_Code_to_Site_id;




  --
  -- PROCEDURE:		Get_Location_Id
  -- Purpose:		Convert Organization_id or ship_to_site_id to
  --			a location_id
  -- Arguments:		p_mode - 'CUSTOMER SITE', 'VENDOR SITE' or 'ORG'
  --			p_source_id - organization_id or site_id to convert
  --					  based on p_mode
  --			x_location_id - Converted to location_id
  --			x_api_status -	WSH_UTIL_CORE.G_RET_STS_SUCCESS
  --					WSH_UTIL_CORE.G_RET_STS_ERROR
  --			If Error message can be retrieved using FND_MESSAGE.GET
  -- Description:	Gets location information for a particular inventory
  --			organization using hr_locations view
  --

  PROCEDURE Get_Location_Id (
		p_mode		IN	VARCHAR2,
		p_source_id	IN	NUMBER,
		x_location_id	OUT NOCOPY 	NUMBER,
		x_api_status	OUT NOCOPY  VARCHAR2,
                p_transfer_location IN BOOLEAN DEFAULT TRUE
		) IS

  l_loc_rec    WSH_MAP_LOCATION_REGION_PKG.loc_rec_type;
  l_return_status VARCHAR2(10);
  l_location_id  NUMBER;
  l_num_warnings  NUMBER default 0;
  l_num_errors    NUMBER default 0;

  l_source_id_mod number; -- bug 8514165

  CURSOR org_to_loc (v_org_id NUMBER) IS
  SELECT location_id
  FROM	 wsh_ship_from_orgs_v
  WHERE  organization_id = v_org_id;


  CURSOR site_to_loc (v_site_id NUMBER) IS
  SELECT ps.location_id
  FROM   hz_party_sites ps,
	 hz_cust_acct_sites_all ca,
	 hz_cust_site_uses_all su
  WHERE  su.site_use_id = v_site_id
  AND	su.cust_acct_site_id = ca.cust_acct_site_id
  AND	ca.party_site_id = ps.party_site_id;

  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
                                                            'GET_LOCATION_ID';
   --
   BEGIN

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
      --
      WSH_DEBUG_SV.log(l_module_name,'P_MODE',P_MODE);
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_ID',P_SOURCE_ID);
      WSH_DEBUG_SV.log(l_module_name,'p_transfer_location',p_transfer_location);
   END IF;
   --
   x_api_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   x_location_id := null;

   l_source_id_mod := MOD(p_source_id,C_INDEX_LIMIT); -- bug 8514165

   IF p_mode = 'ORG' THEN

      IF ( g_org_Id_Tab.EXISTS(l_source_id_mod) ) THEN   -- bug 8514165   replaced p_source_id with l_source_id_mod

         x_location_id := g_org_Id_Tab(l_source_id_mod); -- bug 8514165   replaced p_source_id with l_source_id_mod

      ELSE

         OPEN org_to_loc (p_source_id);
         FETCH org_to_loc
            INTO  l_location_id;
         CLOSE org_to_loc;

         IF l_debug_on	THEN
            WSH_DEBUG_SV.log(l_module_name,'l_location_id',l_location_id);
         END IF;

         IF (l_location_id IS NULL) THEN
	 --Bug 4891887 and 4891881 If call is made from Constraints then ignore the warning
	    IF WSH_FTE_CONSTRAINT_FRAMEWORK.G_CALLING_API IS NULL THEN
            --The following message is modified as part of bug # 4256319
            FND_MESSAGE.Set_Name('WSH','WSH_DET_NO_LOCATION_FOR_ORG');
            x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_api_status,l_module_name);
	    ELSE
		WSH_FTE_CONSTRAINT_FRAMEWORK.G_CALLING_API :=NULL;
		x_location_id :=l_location_id;
	    END IF;
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
         ELSE

            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Calling Transfer_Location');
            END IF;

            WSH_MAP_LOCATION_REGION_PKG.Transfer_Location(
                     p_source_type            => 'HR',
                     p_source_location_id     => l_location_id,
                     p_transfer_location      => p_transfer_location,
                     p_online_region_mapping  => FALSE,
                     x_loc_rec                => l_loc_rec,
                     x_return_status          => l_return_status
            );
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Transfer_Location returns ',
                                                           l_return_status);
                WSH_DEBUG_SV.log(l_module_name,'location_id returned ',
                                                     l_loc_rec.wsh_location_id);
            END IF;
            wsh_util_core.api_post_call(
                                   p_return_status => l_return_status,
                                   x_num_warnings  => l_num_warnings,
                                   x_num_errors    => l_num_errors);

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS)
             OR (l_loc_rec.WSH_LOCATION_ID IS NULL)  THEN
                RAISE WSH_UTIL_CORE.G_EXC_WARNING;
            END IF;
            g_org_Id_Tab(l_source_id_mod) := l_loc_rec.WSH_LOCATION_ID;  --bug 8514165   replaced p_source_id with l_source_id_mod
            x_location_id := l_loc_rec.WSH_LOCATION_ID;
         END IF;
      END IF;

   ELSIF p_mode in ('CUSTOMER SITE', 'SITE') THEN

      IF ( g_cust_Id_Tab.EXISTS(l_source_id_mod) ) THEN    --bug 8514165   replaced p_source_id with l_source_id_mod

         x_location_id := g_cust_Id_Tab(l_source_id_mod);  --bug 8514165   replaced p_source_id with l_source_id_mod

      ELSE

         OPEN site_to_loc (p_source_id);
         FETCH site_to_loc
            INTO l_location_id;
         CLOSE site_to_loc;

         IF (l_location_id IS NULL) THEN
            FND_MESSAGE.Set_Name('WSH','WSH_SITE_LOCATION_UNDEFINED');
            x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_api_status,l_module_name);
            IF site_to_loc%ISOPEN THEN
               CLOSE site_to_loc;
            END IF;
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
         ELSE
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Calling Transfer_Location');
            END IF;

            WSH_MAP_LOCATION_REGION_PKG.Transfer_Location(
                     p_source_type            => 'HZ',
                     p_source_location_id     => l_location_id,
                     p_transfer_location      => p_transfer_location,
                     p_online_region_mapping  => FALSE,
                     x_loc_rec                => l_loc_rec,
                     x_return_status          => l_return_status
            );
            wsh_util_core.api_post_call(
                                   p_return_status => l_return_status,
                                   x_num_warnings  => l_num_warnings,
                                   x_num_errors    => l_num_errors);

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS )
             OR (l_loc_rec.WSH_LOCATION_ID IS NULL) THEN
                RAISE WSH_UTIL_CORE.G_EXC_WARNING;
            END IF;
            g_cust_Id_Tab(l_source_id_mod) := l_loc_rec.WSH_LOCATION_ID;  --bug 8514165   replaced p_source_id with l_source_id_mod
            x_location_id := l_loc_rec.WSH_LOCATION_ID;

         END IF;

      END IF;

   ELSIF p_mode = 'VENDOR SITE' THEN
      x_location_id := p_source_id;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   ELSE
      FND_MESSAGE.Set_Name('WSH','WSH_API_INVALID_PARAM_VALUE');
      x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;

   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
  EXCEPTION
  WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
	x_api_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        fnd_message.set_name('WSH','WSH_XC_INVALID_LOCATION');
        wsh_util_core.add_message(x_api_status,l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:G_RET_STS_WARNING');
        END IF;
        --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_api_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:G_EXC_UNEXPECTED_ERROR');
        END IF;
        --
  WHEN FND_API.G_EXC_ERROR THEN
        IF (NOT p_transfer_location)
         AND (l_loc_rec.WSH_LOCATION_ID IS NULL) THEN
           x_api_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
        ELSE
	   x_api_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'x_api_status ',x_api_status);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:G_EXC_ERROR');
        END IF;
        --
  WHEN OTHERS THEN
        WSH_FTE_CONSTRAINT_FRAMEWORK.G_CALLING_API :=NULL;
	IF org_to_loc%ISOPEN THEN
	  CLOSE org_to_loc;
	END IF;
	IF site_to_loc%ISOPEN THEN
	  CLOSE site_to_loc;
	END IF;
	FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
	x_api_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
  END Get_Location_Id;


  --
  -- PROCEDURE:		get_master_from_org
  -- PURPOSE:		Obtain master organization id for an organization_id
  -- Arguments:		p_org_id - organization_id
  --			x_master_org_id - Master organization id for input organization_id
  --			x_return_status -
  --                    WSH_UTIL_CORE.G_RET_STS_SUCCESS
  --                    WSH_UTIL_CORE.G_RET_STS_ERROR
  -- Notes:		Throws exception when fails
  --

PROCEDURE get_master_from_org(
              p_org_id         IN  NUMBER,
              x_master_org_id  OUT NOCOPY NUMBER,
              x_return_status  OUT NOCOPY VARCHAR2)
IS

    CURSOR c_get_master_from_org(c_org_id IN NUMBER) IS
    SELECT master_organization_id
    FROM   mtl_parameters
    WHERE  organization_id = c_org_id;

    org_not_found       EXCEPTION;

    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_master_from_org';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
    END IF;
    --

    IF g_master_org_tab.EXISTS(p_org_id) THEN

         x_master_org_id := g_master_org_tab(p_org_id);

    ELSE

      OPEN c_get_master_from_org(p_org_id);
      FETCH c_get_master_from_org INTO x_master_org_id;
      IF c_get_master_from_org%NOTFOUND THEN
         CLOSE c_get_master_from_org;
         RAISE org_not_found;
      END IF;
      CLOSE c_get_master_from_org;

      g_master_org_tab(p_org_id) := x_master_org_id;

    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN org_not_found THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:org in mtl_parameters not found');
      END IF;
      --
    WHEN others THEN
      IF c_get_master_from_org%ISOPEN THEN
         CLOSE c_get_master_from_org;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_UTIL_CORE.get_master_from_org');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

END get_master_from_org;


  --
  -- FUNCTION:		Org_To_Location
  -- PURPOSE:		Convert organization_id to location_id
  -- Arguments:		p_org_id - organization_id
  -- Return Values:	Location_id
  -- Notes:		Throws exception when failing to convert
  --

  FUNCTION Org_To_Location (
		p_org_id	IN	NUMBER,
                p_transfer_location IN BOOLEAN DEFAULT FALSE
		) RETURN NUMBER IS
  l_api_status	VARCHAR2(1);
  l_location_id NUMBER;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ORG_TO_LOCATION';
  --
  BEGIN

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
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_ORG_ID',P_ORG_ID);
	    WSH_DEBUG_SV.logmsg(l_module_name,'Call Get_Location_id');
	END IF;
	--
	l_location_id := -1;

	Get_Location_Id (
	'ORG',
	p_org_id,
	l_location_id,
	l_api_status,
        p_transfer_location);

	IF l_api_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          IF l_api_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             l_location_id := NULL;
          ELSE
	    RAISE NO_DATA_FOUND;
          END IF;
	END IF;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'LOCATION ID',l_location_id);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN l_location_id;

  END Org_To_Location;


  --
  -- FUNCTION:		Cust_Site_To_Location
  -- PURPOSE:		Convert site_id to location_id
  -- Arguments:		p_site_id - site_id
  -- Return Values:	Location_id
  -- Notes:		Throws exception when failing to convert
  --

  FUNCTION Cust_Site_To_Location (
		p_site_id	IN	NUMBER,
                p_transfer_location IN BOOLEAN DEFAULT TRUE
		) RETURN NUMBER IS
  l_api_status	VARCHAR2(1);
  l_location_id NUMBER;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CUST_SITE_TO_LOCATION';
  --
  BEGIN

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
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_SITE_ID',P_SITE_ID);
	    WSH_DEBUG_SV.logmsg(l_module_name,'Call Get_Location_id');
	END IF;
	--
	l_location_id := -1;

	Get_Location_Id (
	'CUSTOMER SITE',
	p_site_id,
	l_location_id,
	l_api_status,
        p_transfer_location);

	IF l_api_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          IF l_api_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             l_location_id := NULL;
          ELSE
	     RAISE NO_DATA_FOUND;
          END IF;
	END IF;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'LOCATION ID',l_location_id);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN l_location_id;

  END Cust_Site_To_Location;

  --
  -- FUNCTION:		Vendor_Site_To_Location
  -- PURPOSE:		Convert vendor site_id to location_id
  -- Arguments:		p_site_id - site_id
  -- Return Values:	Location_id
  -- Notes:		Throws exception when failing to convert
  --

  FUNCTION Vendor_Site_To_Location (
		p_site_id	IN	NUMBER,
                p_transfer_location IN BOOLEAN DEFAULT TRUE
		) RETURN NUMBER IS
  l_api_status	VARCHAR2(1);
  l_location_id NUMBER;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VENDOR_SITE_TO_LOCATION';
  --
  BEGIN

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
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_SITE_ID',P_SITE_ID);
	    WSH_DEBUG_SV.logmsg(l_module_name,'Call Get_Location_id');
	END IF;
	--
	l_location_id := -1;

	Get_Location_Id (
	'VENDOR SITE',
	p_site_id,
	l_location_id,
	l_api_status,
        p_transfer_location);

	IF l_api_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          IF l_api_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             l_location_id := NULL;
          ELSE
             RAISE NO_DATA_FOUND;
          END IF;
	END IF;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'LOCATION ID',l_location_id);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN l_location_id;

  END Vendor_Site_To_Location;

  --
  -- FUNCTION:		Ship_Method_To_Freight
  -- PURPOSE:		Convert Ship_Method_Code to Freight_Code
  -- Arguments:	p_ship_method_code, p_organization_id
  -- Return Values:	Freight_Code
  -- Notes:		Throws exception when failing to convert
  --

  FUNCTION Ship_Method_To_Freight (
		p_ship_method_code	IN	VARCHAR2,
		p_organization_id   IN   NUMBER
		) RETURN VARCHAR2 IS

  ---BUG No:4241880.Cursor changed
  CURSOR get_freight IS
  SELECT freight_code
  FROM   wsh_carriers wc,wsh_carrier_services wcs,wsh_org_carrier_services wocs
  WHERE  wc.carrier_id=wcs.carrier_id AND
	 wcs.carrier_service_id=wocs.carrier_service_id AND
	 wcs.ship_method_code = p_ship_method_code AND
	 wocs.organization_id = p_organization_id;
---BUG No:4241880.Cursor changed ends.

 /*
 CURSOR get_freight IS
  SELECT freight_code
  FROM   wsh_carrier_ship_methods_v
  WHERE  ship_method_code = p_ship_method_code AND
		organization_id = p_organization_id;
*/

  l_freight_code VARCHAR2(30);

  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SHIP_METHOD_TO_FREIGHT';
  --
  BEGIN

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
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_CODE',P_SHIP_METHOD_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
	END IF;
	--
	IF (p_ship_method_code IS NULL) THEN
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN NULL;
	END IF;

	OPEN  get_freight;
	FETCH get_freight INTO l_freight_code;

	IF (get_freight%NOTFOUND) THEN
	   CLOSE get_freight;
	  fnd_message.set_name('WSH','WSH_FREIGHT_CODE_NOT_FOUND');
	  wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	  RAISE NO_DATA_FOUND;
	END IF;

	CLOSE get_freight;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN l_freight_code;

  END Ship_Method_To_Freight;

  --
  -- This set of functions and procedures can be used by the concurrent
  -- programs to print messages to the log file. The following are
  -- supported:
  --

  --
  -- Procedure:	Enable_Concurrent_Log_Print
  -- Purpose:		Enable printing of log messages to concurrent
  --				 program log files
  -- Arguments:	None
  --

  PROCEDURE Enable_Concurrent_Log_Print IS
  --
--l_debug_on BOOLEAN;
  --
  --l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ENABLE_CONCURRENT_LOG_PRINT';
  --
  BEGIN

	--
	--l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	--IF l_debug_on IS NULL
	--THEN
	    --l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	--END IF;
	--
	G_ALLOW_PRINT := 'Y';

  END Enable_Concurrent_Log_Print;

  --
  -- Procedure:	Set_Log_Level
  -- Purpose:		Set Appropriate log level to print
  --			   debug messages to the concurrent program log file
  -- Arguments:	p_log_level  -- Log level to set
  --

  PROCEDURE Set_Log_Level(
	p_log_level   IN  NUMBER
  )  IS
  --
  l_file_name VARCHAR2(32767);
  l_return_status VARCHAR2(32767);
  l_msg_data VARCHAR2(32767);
  l_msg_count NUMBER;
--l_debug_on BOOLEAN;
  --
  --l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SET_LOG_LEVEL';
  --
  BEGIN
	--
	-- Debug Statements
	--
	--
	--l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	--IF l_debug_on IS NULL
	--THEN
	    --l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	--END IF;
	--
	--IF l_debug_on THEN
	    --WSH_DEBUG_SV.push(l_module_name);
	    --
	    --WSH_DEBUG_SV.log(l_module_name,'P_LOG_LEVEL',P_LOG_LEVEL);
	--END IF;
	--
	--
	-- Added to turn on/off the WSH debugger depending on log level
	--
	BEGIN
	     IF p_log_level > 0
	     THEN
                 --fnd_profile.put('WSH_DEBUG_MODE','T');
                 fnd_profile.put('WSH_DEBUG_MODULE','%');
                 fnd_profile.put('WSH_DEBUG_LEVEL',WSH_DEBUG_SV.C_STMT_LEVEL);
		 wsh_debug_sv.start_debugger(l_file_name,l_return_status,l_msg_count,l_msg_data);
		 --wsh_debug_sv.start_debugger(l_file_name,l_return_status,l_msg_data,l_msg_count);
		 -- Ignore errors;
	     ELSE
                 --fnd_profile.put('WSH_DEBUG_MODE','F');
		 wsh_debug_sv.stop_debugger;
	     END IF;
	EXCEPTION
	   WHEN OTHERS THEN
	      NULL;
	END;
	--
	G_LOG_LEVEL := p_log_level;
	--
	-- Debug Statements
	--
	--IF l_debug_on THEN
	    --WSH_DEBUG_SV.pop(l_module_name);
	--END IF;
	--
  END Set_Log_Level;

  --
  -- Procedure:	Print
  -- Purpose:		Prints a line of message text to the log file
  --				 and does not insert a new line at the end
  --				 program log files
  -- Arguments:	p_msg - message text to print
  --

  PROCEDURE Print(
	p_msg	IN	VARCHAR2
  ) IS
  l_insert_text		VARCHAR2(80);
  l_remainder_text	VARCHAR2(2000);
  i			NUMBER := 0;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINT';
  --
  BEGIN
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF G_ALLOW_PRINT = 'Y' AND G_LOG_LEVEL > 0 THEN
	  IF LENGTH(p_msg) > G_MAX_LENGTH THEN
		l_remainder_text := SUBSTRB(p_msg,1,G_MAX_LENGTH);
	  ELSE
	l_remainder_text := p_msg;
	  END IF;

	  LOOP
		l_insert_text := SUBSTRB(l_remainder_text,1,80);
	l_remainder_text := SUBSTRB(l_remainder_text,81);
		fnd_file.put(FND_FILE.LOG, l_insert_text);

		IF l_remainder_text IS NOT NULL THEN
	  fnd_file.new_line(FND_FILE.LOG);
		END IF;

		EXIT WHEN l_remainder_text IS NULL;
		i := i + 1;
	EXIT WHEN i = 25;
	  END LOOP;
	END IF;
  END Print;

  --
  -- Procedure:	Println
  -- Purpose:		Prints a line of message text to the log file
  --				 and inserts a new line at the end
  --				 program log files
  -- Arguments:	p_msg - message text to print
  --

  PROCEDURE Println(
	p_msg	IN	VARCHAR2
  ) IS
  l_insert_text		VARCHAR2(80);
  l_remainder_text	VARCHAR2(2000);
  i			NUMBER := 0;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINTLN';
  --
  BEGIN
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF G_ALLOW_PRINT = 'Y' AND G_LOG_LEVEL > 0 THEN
	  IF LENGTH(p_msg) > G_MAX_LENGTH THEN
		l_remainder_text := SUBSTRB(p_msg,1,G_MAX_LENGTH);
	  ELSE
	l_remainder_text := p_msg;
	  END IF;

	  LOOP
		l_insert_text := SUBSTRB(l_remainder_text,1,80);
	l_remainder_text := SUBSTRB(l_remainder_text,81);
		fnd_file.put_line(FND_FILE.LOG, l_insert_text);

		EXIT WHEN l_remainder_text IS NULL;
		i := i + 1;
	EXIT WHEN i = 25;
	  END LOOP;
	END IF;

  END Println;

  --
  -- Procedure:	Println
  -- Purpose:		Prints a new line character to the log file
  --				 program log files
  -- Arguments:	None
  --

  PROCEDURE Println IS
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINTLN';
  --
  BEGIN
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF G_ALLOW_PRINT = 'Y'  AND G_LOG_LEVEL > 0 THEN
	  fnd_file.new_line(FND_FILE.LOG);
	END IF;
	--
  END Println;


  --
  -- Procedure:	PrintMsg
  -- Purpose:		Prints a line of message text to the log file
  --				 and inserts a new line at the end
  --				 program log files irrespective of the log level
  --				Should be used for the debug messages which need to
  --				printed always
  -- Arguments:	p_msg - message text to print
  --

  PROCEDURE PrintMsg(
	p_msg	IN	VARCHAR2
  ) IS
  l_insert_text		VARCHAR2(80);
  l_remainder_text	VARCHAR2(2000);
  i			NUMBER := 0;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINTMSG';
  --
  BEGIN
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF G_ALLOW_PRINT = 'Y'THEN
	  IF LENGTH(p_msg) > G_MAX_LENGTH THEN
		l_remainder_text := SUBSTRB(p_msg,1,G_MAX_LENGTH);
	  ELSE
	l_remainder_text := p_msg;
	  END IF;

	  LOOP
		l_insert_text := SUBSTRB(l_remainder_text,1,80);
	l_remainder_text := SUBSTRB(l_remainder_text,81);
		fnd_file.put_line(FND_FILE.LOG, l_insert_text);

		EXIT WHEN l_remainder_text IS NULL;
		i := i + 1;
	EXIT WHEN i = 25;
	  END LOOP;
	END IF;

  END PrintMsg;

  --
  -- Procedure:	PrintMsg
  -- Purpose:		Prints a new line character to the log file
  --				 program log files irrespective of the log Level
  -- Arguments:	 None
  --

  PROCEDURE PrintMsg IS
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINTMSG';
  --
  BEGIN
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF G_ALLOW_PRINT = 'Y' THEN
	  fnd_file.new_line(FND_FILE.LOG);
	END IF;
	--
  END PrintMsg;


  --
  --
  -- Procedure:		PrintDateTime
  -- Purpose:		Prints system date and time to the log file
  -- Arguments:		None
  --

  PROCEDURE PrintDateTime IS
	l_date_time	DATE;
	--
l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINTDATETIME';
	--
  BEGIN

	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	SELECT SYSDATE INTO l_date_time FROM dual;
	Println('Current Time: ' || to_char(l_date_time, 'DD-MON-YYYY HH24:MI:SS'));

  END;


  FUNCTION Construct_Query(old_query VARCHAR2,
			   pkey VARCHAR2,
			   pkey_value VARCHAR2)
			RETURN VARCHAR2 IS
    new_query VARCHAR2(500);
  BEGIN
    IF (pkey_value IS NULL) THEN
      new_query := old_query||pkey||' IS NULL';
    ELSE
      new_query := old_query||pkey||' = '||pkey_value;
    END IF;
    RETURN new_query;
  END Construct_Query;




  -- Name
  --   Gen_Check_Unique
  -- Purpose
  --   Checks for duplicates in database
  -- Arguments
  --   query_text			   query to execute to test for uniqueness
  --   prod_name		product name to send message for
  --   msg_name			message to print if duplicate found
  --
  -- Notes
  --   uses DBMS_SQL package to create and execute cursor for given query


  PROCEDURE Gen_Check_Unique(p_table_name IN VARCHAR2,
			     p_pkey1 IN VARCHAR2 ,
			     p_pkey1_value IN VARCHAR2 ,
                             p_is_1_char   IN VARCHAR2,
			     p_pkey2 IN VARCHAR2 ,
			     p_pkey2_value IN VARCHAR2 ,
                             p_is_2_char   IN VARCHAR2,
			     p_pkey3 IN VARCHAR2 ,
			     p_pkey3_value IN VARCHAR2 ,
                             p_is_3_char   IN VARCHAR2,
			     p_pkey4 IN VARCHAR2 ,
			     p_pkey4_value IN VARCHAR2 ,
                             p_is_4_char   IN VARCHAR2,
			     p_pkey5 IN VARCHAR2 ,
			     p_pkey5_value IN VARCHAR2 ,
                             p_is_5_char   IN VARCHAR2,
			     p_pkey6 IN VARCHAR2 ,
			     p_pkey6_value IN VARCHAR2 ,
                             p_is_6_char   IN VARCHAR2,
			     p_pkey7 IN VARCHAR2 ,
			     p_pkey7_value IN VARCHAR2 ,
                             p_is_7_char   IN VARCHAR2,
			     p_pkey8 IN VARCHAR2 ,
			     p_pkey8_value IN VARCHAR2 ,
                             p_is_8_char   IN VARCHAR2,
			     p_row_id IN VARCHAR2 ,
			     p_prod_name IN VARCHAR2,
			     p_msg_name IN VARCHAR2) IS
	rec_cursor INTEGER;
	any_found INTEGER;

    query_string VARCHAR2(500);
    query_param VARCHAR2(500);
    new_value VARCHAR2(80);
    pkey_value VARCHAR2(80);

	--
l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GEN_CHECK_UNIQUE';
	--
BEGIN
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
	    --
	    WSH_DEBUG_SV.log(l_module_name,'PROD_NAME',P_PROD_NAME);
	    WSH_DEBUG_SV.log(l_module_name,'MSG_NAME',P_MSG_NAME);
	END IF;

     query_string := 'SELECT '||p_pkey1||' FROM '||p_table_name||' WHERE ';
     query_param := query_string;

     IF  p_pkey1_value IS NULL THEN
         pkey_value := NULL;
     ELSE
         pkey_value := ':x_pkey1_value';
     END IF;
     query_string := Construct_Query(query_param,p_pkey1,pkey_value);
     IF (p_pkey2 IS NOT NULL) THEN
       query_param :=  query_string||' AND ';
       IF  p_pkey2_value IS NULL THEN
         pkey_value := NULL;
       ELSE
         pkey_value := ':x_pkey2_value';
       END IF;
       query_string := Construct_Query(query_param,p_pkey2,pkey_value);
     END IF;
     IF (p_pkey3 IS NOT NULL) THEN
       query_param :=  query_string||' AND ';
       IF  p_pkey3_value IS NULL THEN
         pkey_value := NULL;
       ELSE
         pkey_value := ':x_pkey3_value';
       END IF;
       query_string := Construct_Query(query_param,p_pkey3,pkey_value);
     END IF;
     IF (p_pkey4 IS NOT NULL) THEN
       query_param :=  query_string||' AND ';
       IF  p_pkey4_value IS NULL THEN
         pkey_value := NULL;
       ELSE
         pkey_value := ':x_pkey4_value';
       END IF;
       query_string := Construct_Query(query_param,p_pkey4,pkey_value);
     END IF;
     IF (p_pkey5 IS NOT NULL) THEN
       query_param :=  query_string||' AND ';
       IF  p_pkey5_value IS NULL THEN
         pkey_value := NULL;
       ELSE
         pkey_value := ':x_pkey5_value';
       END IF;
       query_string := Construct_Query(query_param,p_pkey5,pkey_value);
     END IF;
     IF (p_pkey6 IS NOT NULL) THEN
       query_param :=  query_string||' AND ';
       IF  p_pkey6_value IS NULL THEN
         pkey_value := NULL;
       ELSE
         pkey_value := ':x_pkey6_value';
       END IF;
       query_string := Construct_Query(query_param,p_pkey6,pkey_value);
     END IF;
     IF (p_pkey7 IS NOT NULL) THEN
       query_param :=  query_string||' AND ';
       IF  p_pkey7_value IS NULL THEN
         pkey_value := NULL;
       ELSE
         pkey_value := ':x_pkey7_value';
       END IF;
       query_string := Construct_Query(query_param,p_pkey7,pkey_value);
     END IF;
     IF (p_pkey8 IS NOT NULL) THEN
       query_param :=  query_string||' AND ';
       IF  p_pkey8_value IS NULL THEN
         pkey_value := NULL;
       ELSE
         pkey_value := ':x_pkey8_value';
       END IF;
       query_string := Construct_Query(query_param,p_pkey8,pkey_value);
     END IF;
     IF (p_row_id IS NOT NULL) THEN
       query_string := query_string||' AND ROWID <> '||':x_row_id';
     END IF;

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'query_string',query_string);
        END IF;

     rec_cursor := dbms_sql.open_cursor;
     dbms_sql.parse(rec_cursor,query_string,dbms_sql.v7);

     IF p_pkey1 IS NOT NULL AND p_pkey1_value IS NOT NULL THEN
        IF (p_is_1_char = 'Y') THEN
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey1_value', p_pkey1_value);
        ELSE
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey1_value', TO_NUMBER(p_pkey1_value));
        END IF;
     END IF;
     IF p_pkey2 IS NOT NULL AND p_pkey2_value IS NOT NULL THEN
        IF (p_is_2_char = 'Y') THEN
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey2_value', p_pkey2_value);
        ELSE
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey2_value', TO_NUMBER(p_pkey2_value));
        END IF;
     END IF;
     IF p_pkey3 IS NOT NULL AND p_pkey3_value IS NOT NULL THEN
        IF (p_is_3_char = 'Y') THEN
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey3_value', p_pkey3_value);
        ELSE
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey3_value', TO_NUMBER(p_pkey3_value));
        END IF;
     END IF;
     IF p_pkey4 IS NOT NULL AND p_pkey4_value IS NOT NULL THEN
        IF (p_is_4_char = 'Y') THEN
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey4_value', p_pkey4_value);
        ELSE
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey4_value', TO_NUMBER(p_pkey4_value));
        END IF;
     END IF;
     IF p_pkey5 IS NOT NULL AND p_pkey5_value IS NOT NULL THEN
        IF (p_is_5_char = 'Y') THEN
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey5_value', p_pkey5_value);
        ELSE
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey5_value', TO_NUMBER(p_pkey5_value));
        END IF;
     END IF;
     IF p_pkey6 IS NOT NULL AND p_pkey6_value IS NOT NULL THEN
        IF (p_is_6_char = 'Y') THEN
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey6_value', p_pkey6_value);
        ELSE
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey6_value', TO_NUMBER(p_pkey6_value));
        END IF;
     END IF;
     IF p_pkey7 IS NOT NULL AND p_pkey7_value IS NOT NULL THEN
        IF (p_is_7_char = 'Y') THEN
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey7_value', p_pkey7_value);
        ELSE
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey7_value', TO_NUMBER(p_pkey7_value));
        END IF;
     END IF;
     IF p_pkey8 IS NOT NULL AND p_pkey8_value IS NOT NULL THEN
        IF (p_is_8_char = 'Y') THEN
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey8_value', p_pkey8_value);
        ELSE
          DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_pkey8_value', TO_NUMBER(p_pkey8_value));
        END IF;
     END IF;
     IF p_row_id IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_row_id', CHARTOROWID(p_row_id));
     END IF;


     any_found := dbms_sql.execute_and_fetch(rec_cursor);
     IF (any_found > 0) THEN
       FND_MESSAGE.SET_NAME(p_prod_name,p_msg_name);
       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
--
-- Debug Statements
--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
END;


PROCEDURE GET_ACTIVE_DATE(P_TABLE_NAME  IN       varchar2,
                          P_COLUMN_NAME  IN        varchar2,
                          P_ROW_ID       IN       varchar2,
                          X_DATE_FETCHED OUT NOCOPY DATE)
IS

  query_text VARCHAR2(500);
  rec_cursor			 INTEGER;
  row_processed		 INTEGER;
  error_out			EXCEPTION;
  date_in_table		DATE;
	--
  l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ACTIVE_DATE';
	--
BEGIN
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
        query_text := 'SELECT '|| P_COLUMN_NAME || ' FROM ' ||
                       P_TABLE_NAME || ' WHERE ROWID = :x_row_id';
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'QUERY_TEXT',QUERY_TEXT);
	END IF;

	--
	rec_cursor := dbms_sql.open_cursor;
	dbms_sql.parse(rec_cursor,query_text,dbms_sql.v7);
	dbms_sql.define_column(rec_cursor, 1, date_in_table);

        DBMS_SQL.BIND_VARIABLE(rec_cursor,':x_row_id', CHARTOROWID(p_row_id));
	row_processed := dbms_sql.execute(rec_cursor);

	IF ( dbms_sql.fetch_rows(rec_cursor) > 0) THEN
	  dbms_sql.column_value( rec_cursor, 1, date_in_table);
	ELSE
	  RAISE error_out;
	END IF;

	dbms_sql.close_cursor(rec_cursor);

	x_date_fetched := date_in_table;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
	WHEN OTHERS THEN
		dbms_sql.close_cursor(rec_cursor);
		FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
		FND_MESSAGE.Set_Token('PACKAGE','WSH_UTIL_CORE');
		FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
		FND_MESSAGE.Set_Token('ORA_TEXT',query_text);
		APP_EXCEPTION.Raise_Exception;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		END IF;
		--
END Get_Active_Date;

PROCEDURE Get_Active_Date(query_text		 IN	VARCHAR2,
				   date_fetched	 OUT NOCOPY 	DATE) IS
	rec_cursor			 INTEGER;
	row_processed		 INTEGER;
	error_out			EXCEPTION;
	date_in_table		DATE;
	--
l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ACTIVE_DATE';
	--
BEGIN
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
	    --
	    WSH_DEBUG_SV.log(l_module_name,'QUERY_TEXT',QUERY_TEXT);
	END IF;
	--
	rec_cursor := dbms_sql.open_cursor;
	dbms_sql.parse(rec_cursor,query_text,dbms_sql.v7);
	dbms_sql.define_column(rec_cursor, 1, date_in_table);
	row_processed := dbms_sql.execute(rec_cursor);

	IF ( dbms_sql.fetch_rows(rec_cursor) > 0) THEN
	  dbms_sql.column_value( rec_cursor, 1, date_in_table);
	ELSE
	  RAISE error_out;
	END IF;

	dbms_sql.close_cursor(rec_cursor);

	date_fetched := date_in_table;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
	WHEN OTHERS THEN
		dbms_sql.close_cursor(rec_cursor);
		FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
		FND_MESSAGE.Set_Token('PACKAGE','WSH_UTIL_CORE');
		FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
		FND_MESSAGE.Set_Token('ORA_TEXT',query_text);
		APP_EXCEPTION.Raise_Exception;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		END IF;
		--
END Get_Active_Date;



-- Overloaded the procedure to log messages to debug file as well.
PROCEDURE Add_Message ( p_message_type IN VARCHAR2,
		        p_module_name IN VARCHAR2
		       )
IS

msg_buffer varchar2(2000);
l_encoded_msg varchar2(2000);
l_message_type    VARCHAR2(1) := NULL;
l_app_short_name  VARCHAR2(10) := NULL;
l_message_name    VARCHAR2(30) := NULL;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADD_MESSAGE';
l_exception_level NUMBER;
--
BEGIN

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
       --
       WSH_DEBUG_SV.log(l_module_name,'P_MESSAGE_TYPE',P_MESSAGE_TYPE);
       WSH_DEBUG_SV.log(l_module_name,'P_MODULE_NAME',P_MODULE_NAME);
   END IF;
   --
   IF (p_message_type = 'E') THEN
	 l_message_type := 'E';
	 l_exception_level := WSH_DEBUG_SV.C_ERR_LEVEL;
   ELSIF (p_message_type = 'U') THEN
	 l_message_type := 'U';
	 l_exception_level := WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL;
   ELSIF (p_message_type = 'W') THEN
	 l_message_type := 'W';
	 l_exception_level := WSH_DEBUG_SV.C_ERR_LEVEL;
   END IF;

   --IF WSH_UTIL_CORE.G_STORE_MSG_IN_TABLE = FALSE THEN
   IF G_STORE_MSG_IN_TABLE = FALSE THEN
      IF (l_message_type IS NOT NULL) THEN
        msg_buffer := fnd_message.get;
        IF msg_buffer is not null THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'msg_buffer',msg_buffer);
          END IF;
           fnd_message.set_name('WSH','WSH_UTIL_MESSAGE_'||l_message_type);
           fnd_message.set_token('MSG_TEXT',msg_buffer);
        END IF;
         --
         -- Log the message in debug file as well.
         --
         IF p_module_name IS NOT NULL
         AND l_debug_on
         THEN
            wsh_debug_sv.logmsg
	       (
		 p_module_name,
		 l_message_type || ':' || msg_buffer,
		 l_exception_level
	        );
         END IF;
      END IF;

     IF msg_buffer is not null
     OR p_message_type = 'S' THEN
       fnd_msg_pub.add;
     END IF;
   ELSE
      l_encoded_msg := fnd_message.get_encoded  ;
      fnd_message.parse_encoded(l_encoded_msg, l_app_short_name , l_message_name );
      fnd_message.set_encoded(l_encoded_msg);
      msg_buffer := fnd_message.get;
      WSH_INTEGRATION.G_MSG_TABLE(WSH_INTEGRATION.G_MSG_TABLE.COUNT + 1 ).message_name := l_message_name ;
      WSH_INTEGRATION.G_MSG_TABLE(WSH_INTEGRATION.G_MSG_TABLE.COUNT ).message_text := msg_buffer ;
      WSH_INTEGRATION.G_MSG_TABLE(WSH_INTEGRATION.G_MSG_TABLE.COUNT ).message_type := p_message_type ;
      --
      -- Log the message in debug file as well.
      --
      IF p_module_name IS NOT NULL
      AND l_debug_on
      THEN
          wsh_debug_sv.logmsg
           (
             p_module_name,
             l_message_type || ':' || msg_buffer,
             l_exception_level
            );
      END IF;
   END IF ;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Add_Message;

PROCEDURE Add_Message ( p_message_type IN VARCHAR2 := NULL
		       )
IS
BEGIN
    --
    --
    add_message(p_message_type, NULL);
END Add_Message;

-- Overloaded the procedure to log messages to debug file as well.

-- Overloaded the procedure to set message and tokens
-- Harmonization Project I **heali
PROCEDURE Add_Message (
        p_message_type IN     VARCHAR2,
        p_module_name IN      VARCHAR2,
        p_error_name  IN      VARCHAR2,
        p_token1      IN      VARCHAR2 DEFAULT NULL,
        p_value1      IN      VARCHAR2 DEFAULT NULL,
        p_token2      IN      VARCHAR2 DEFAULT NULL,
        p_value2      IN      VARCHAR2 DEFAULT NULL,
        p_token3      IN      VARCHAR2 DEFAULT NULL,
        p_value3      IN      VARCHAR2 DEFAULT NULL,
        p_token4      IN      VARCHAR2 DEFAULT NULL,
        p_value4      IN      VARCHAR2 DEFAULT NULL,
        p_token5      IN      VARCHAR2 DEFAULT NULL,
        p_value5      IN      VARCHAR2 DEFAULT NULL,
        p_token6      IN      VARCHAR2 DEFAULT NULL,
        p_value6      IN      VARCHAR2 DEFAULT NULL,
        p_token7      IN      VARCHAR2 DEFAULT NULL,
        p_value7      IN      VARCHAR2 DEFAULT NULL,
        p_token8      IN      VARCHAR2 DEFAULT NULL,
        p_value8      IN      VARCHAR2 DEFAULT NULL) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADD_MESSAGE';
BEGIN
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
    WSH_DEBUG_SV.log(l_module_name,'P_MESSAGE_TYPE',P_MESSAGE_TYPE);
    WSH_DEBUG_SV.log(l_module_name,'P_MODULE_NAME',P_MODULE_NAME);
    WSH_DEBUG_SV.log(l_module_name,'p_error_name',p_error_name);
    WSH_DEBUG_SV.log(l_module_name,'p_token1',p_token1);
    WSH_DEBUG_SV.log(l_module_name,'p_value1',p_value1);
 END IF;

 IF p_error_name IS NOT NULL THEN
    FND_MESSAGE.SET_NAME('WSH',p_error_name);

    IF  p_token1 IS NOT NULL AND p_value1 IS NOT NULL THEN
       FND_MESSAGE.SET_TOKEN(p_token1, p_value1);
    END IF;

--Bugfix 6816437 Start
    IF  p_token2 IS NOT NULL AND p_value2 IS NOT NULL THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'p_token2',p_token2);
        WSH_DEBUG_SV.log(l_module_name,'p_value2',p_value2);
      END IF;
       FND_MESSAGE.SET_TOKEN(p_token2, p_value2);
    END IF;

    IF  p_token3 IS NOT NULL AND p_value3 IS NOT NULL THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'p_token3',p_token3);
        WSH_DEBUG_SV.log(l_module_name,'p_value3',p_value3);
      END IF;
       FND_MESSAGE.SET_TOKEN(p_token3, p_value3);
    END IF;

    IF  p_token4 IS NOT NULL AND p_value4 IS NOT NULL THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'p_token4',p_token4);
        WSH_DEBUG_SV.log(l_module_name,'p_value4',p_value4);
      END IF;
       FND_MESSAGE.SET_TOKEN(p_token4, p_value4);
    END IF;

    IF  p_token5 IS NOT NULL AND p_value5 IS NOT NULL THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'p_token5',p_token5);
        WSH_DEBUG_SV.log(l_module_name,'p_value5',p_value5);
      END IF;
       FND_MESSAGE.SET_TOKEN(p_token5, p_value5);
    END IF;

    IF  p_token6 IS NOT NULL AND p_value6 IS NOT NULL THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'p_token6',p_token6);
        WSH_DEBUG_SV.log(l_module_name,'p_value6',p_value6);
      END IF;
       FND_MESSAGE.SET_TOKEN(p_token6, p_value6);
    END IF;

    IF  p_token7 IS NOT NULL AND p_value7 IS NOT NULL THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'p_token7',p_token7);
        WSH_DEBUG_SV.log(l_module_name,'p_value7',p_value7);
      END IF;
       FND_MESSAGE.SET_TOKEN(p_token7, p_value7);
    END IF;

    IF  p_token8 IS NOT NULL AND p_value8 IS NOT NULL THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'p_token8',p_token8);
        WSH_DEBUG_SV.log(l_module_name,'p_value8',p_value8);
      END IF;
       FND_MESSAGE.SET_TOKEN(p_token8, p_value8);
    END IF;
--Bugfix 6816437 End
 END IF;

 add_message(p_message_type, p_module_name);

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
 WHEN OTHERS THEN
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                             SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END Add_Message;
-- Harmonization Project I **heali

PROCEDURE Add_Summary_Message(
	p_message		  fnd_new_messages.message_name%type,
	p_total			  number,
	p_warnings		  number,
	p_errors		  number,
	p_return_status		  out NOCOPY  varchar2,
	p_module_name       in varchar2 )
is
	l_total		  number;
	l_warnings		  number;
	l_errors		  number;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADD_SUMMARY_MESSAGE';
--
begin

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
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_TOTAL',P_TOTAL);
	    WSH_DEBUG_SV.log(l_module_name,'P_WARNINGS',P_WARNINGS);
	    WSH_DEBUG_SV.log(l_module_name,'P_ERRORS',P_ERRORS);
            WSH_DEBUG_SV.log(l_module_name,'P_MODULE_NAME',P_MODULE_NAME);
	END IF;
	--
	l_total		  := nvl(p_total, 0);
	l_warnings		  := nvl(p_warnings, 0);
	l_errors		  := nvl(p_errors, 0);

	IF (l_errors > 0) OR (l_warnings > 0) THEN
	IF (l_total > 1) THEN
		FND_MESSAGE.SET_NAME('WSH', p_message);
		FND_MESSAGE.SET_TOKEN('NUM_ERROR', l_errors);
		FND_MESSAGE.SET_TOKEN('NUM_WARN', l_warnings);
		FND_MESSAGE.SET_TOKEN('NUM_SUCCESS', l_total - l_errors - l_warnings);

		wsh_util_core.add_message(p_return_status, p_module_name);
	END IF;

	IF (l_total = l_errors) THEN
	   p_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSE
	   p_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
	ELSE
	p_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'P_RETURN_STATUS',p_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Add_Summary_Message;

PROCEDURE Add_Summary_Message(
	p_message		  fnd_new_messages.message_name%type,
	p_total			  number,
	p_warnings		  number,
	p_errors		  number,
	p_return_status		  out NOCOPY  varchar2)
is
begin

    --
    add_summary_message
      (
	p_message,
	p_total,
	p_warnings,
	p_errors,
	p_return_status,
	NULL
      );
END Add_Summary_Message;


PROCEDURE Get_Messages ( p_init_msg_list IN VARCHAR2,
					x_summary OUT NOCOPY  VARCHAR2,
					x_details OUT NOCOPY  VARCHAR2,
					x_count   OUT NOCOPY  NUMBER) IS

l_tmp_out NUMBER;
l_tmp_buffer VARCHAR2(4000);
details_len   NUMBER;
str_len	   NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_MESSAGES';
--
BEGIN
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
      --
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
  END IF;
  --
  x_count := FND_MSG_PUB.count_msg;

  FND_MSG_PUB.get( p_encoded => FND_API.G_FALSE,
			p_msg_index => x_count,
			p_data => x_summary,
			p_msg_index_out => l_tmp_out);

  FND_MSG_PUB.get( p_encoded => FND_API.G_FALSE,
				p_msg_index => 1,
				p_data => l_tmp_buffer,
				p_msg_index_out => l_tmp_out);

  x_details := l_tmp_buffer;

  FOR i IN 2..x_count-1 LOOP

	 FND_MSG_PUB.get( p_encoded => FND_API.G_FALSE,
				p_msg_index => i,
				p_data => l_tmp_buffer,
				p_msg_index_out => l_tmp_out);

	 str_len := lengthb(x_details);

	IF (str_len > 3900) THEN
	   EXIT;
	 END IF;

	 IF (str_len+lengthb(l_tmp_buffer)> 3900) THEN
	   x_details := x_details||'
------------------------------------
'||substrb(l_tmp_buffer,1,3900-str_len);
		EXIT;
	 ELSE
	   x_details := x_details||'
------------------------------------
'||l_tmp_buffer;
	 END IF;

  END LOOP;

  IF (p_init_msg_list = 'Y') THEN
	FND_MSG_PUB.initialize;
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END;


-- Overloaded the procedure to log messages to debug file as well.
PROCEDURE default_handler ( p_routine_name IN VARCHAR2 ,
		            p_module_name IN VARCHAR2
                          )
IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DEFAULT_HANDLER';
--
BEGIN

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
       --
       WSH_DEBUG_SV.log(l_module_name,'P_ROUTINE_NAME',P_ROUTINE_NAME);
       WSH_DEBUG_SV.log(l_module_name,'P_MODULE_NAME',P_MODULE_NAME);
   END IF;
   --
   FND_MESSAGE.SET_NAME('WSH','WSH_UNEXP_ERROR');
   FND_MESSAGE.Set_Token('PACKAGE',p_routine_name);
   FND_MESSAGE.Set_Token('ORA_ERROR',sqlcode);
   FND_MESSAGE.Set_Token('ORA_TEXT',sqlerrm);
   WSH_UTIL_CORE.ADD_MESSAGE(FND_API.G_RET_STS_UNEXP_ERROR, p_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END default_handler;

PROCEDURE default_handler ( p_routine_name IN VARCHAR2
                          )
IS

BEGIN

    --
    default_handler( p_routine_name, NULL );
END default_handler;

PROCEDURE Clear_FND_Messages IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CLEAR_FND_MESSAGES';
--
BEGIN

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
   fnd_message.clear;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Clear_FND_Messages;

FUNCTION Get_Org_Name
		(p_organization_id		IN	NUMBER
		 ) RETURN VARCHAR2 IS

  CURSOR	org_info IS
   SELECT  HOU.NAME organization_name
   FROM  HR_ORGANIZATION_UNITS HOU
   WHERE  HOU.ORGANIZATION_ID = p_organization_id;

  org_name  VARCHAR2(240);

  others EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ORG_NAME';
--
  BEGIN

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
	     --
	     WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
	 END IF;
	 --
	 IF (p_organization_id IS NULL) THEN
		raise others;
	 END IF;

	 OPEN  org_info;
	 FETCH org_info INTO org_name;
	 CLOSE org_info;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'ORGANIZATION_NAME',org_name);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN org_name;

	 EXCEPTION
		WHEN others THEN
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
		 RETURN null;

END Get_Org_Name;

--
-- LSP PROJECT : Added new parameter p_remove_client_code which specify
--          whether client code value from item name should be removed or not.
--          Parameter value 'Y' means remove and 'N' means not.
--          This parameter value is being considered only when the deployment mode
--          is LSP.
--          This parameter is required as the this API is being called from
--          many reports out of which some needs client code some or not.
--
FUNCTION Get_Item_Name
		(p_item_id		IN	NUMBER,
		 p_organization_id	  IN	  NUMBER,
		 p_flex_code		IN   VARCHAR2 := 'MSTK',
		 p_struct_num	   IN   NUMBER := 101,
                 p_remove_client_code IN VARCHAR2 DEFAULT 'N'
		 ) RETURN VARCHAR2 IS

  item_name  VARCHAR2(2000);
  result	 BOOLEAN	   := TRUE;

  others EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ITEM_NAME';
--
  BEGIN

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
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_ITEM_ID',P_ITEM_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_FLEX_CODE',P_FLEX_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_STRUCT_NUM',P_STRUCT_NUM);
        WSH_DEBUG_SV.log(l_module_name,'P_REMOVE_CLIENT_CODE',P_REMOVE_CLIENT_CODE);
    END IF;
	--
	IF (p_item_id IS NULL) THEN
		raise others;
	END IF;
    -- LSP PROJECT :
    IF WMS_DEPLOY.wms_deployment_mode = 'L' AND  p_remove_client_code = 'Y' THEN
    --{
        -- Call wms api to get the item name after stripping out client code semment value if exists.
        IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_DEPLOY.GET_CLIENT_ITEM',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        item_name := wms_deploy.get_client_item(
                         p_org_id	   => p_organization_id,
                         p_item_id 	   => p_item_id);
       IF l_debug_on THEN
	        WSH_DEBUG_SV.log(l_module_name,'item_name',item_name);
       END IF;
    --}
    ELSE
    --{
	    result := FND_FLEX_KEYVAL.validate_ccid(
			appl_short_name=>'INV',
			key_flex_code=>p_flex_code,
			structure_number=>p_struct_num,
			combination_id=>p_item_id,
			data_set=>p_organization_id);

	    IF result THEN
	        item_name := FND_FLEX_KEYVAL.concatenated_values;
	    END IF;
    --}
    END IF;
    -- LSP PROJECT : end
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN item_name;

	 EXCEPTION
		WHEN others THEN

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
		 RETURN null;

END Get_Item_Name;


-- Name  generic_flex_name
-- Purpose	converts entity_id into its name
-- Arguments
--	  entity_id
--	  warehouse_id
--	  app_name  (short app name; e.g. 'INV')
--	  k_flex_code	(key flexfield code; e.g., 'MSTK')
--	  struct_num	 (structure number; e.g., 101)
-- Assumption  The parameters are valid.
--	   RETURN VARCHAR2	if name not found, NULL will be returned.

FUNCTION generic_flex_name
  (entity_id	IN NUMBER,
   warehouse_id IN NUMBER,
   app_name	 IN VARCHAR2,
   k_flex_code  IN VARCHAR2,
   struct_num   IN NUMBER)
  RETURN VARCHAR2
  IS
	 name   VARCHAR(2000) := NULL;
	 result BOOLEAN	   := TRUE;
	 --
l_debug_on BOOLEAN;
	 --
	 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GENERIC_FLEX_NAME';
	 --
BEGIN
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
       --
       WSH_DEBUG_SV.log(l_module_name,'ENTITY_ID',ENTITY_ID);
       WSH_DEBUG_SV.log(l_module_name,'WAREHOUSE_ID',WAREHOUSE_ID);
       WSH_DEBUG_SV.log(l_module_name,'APP_NAME',APP_NAME);
       WSH_DEBUG_SV.log(l_module_name,'K_FLEX_CODE',K_FLEX_CODE);
       WSH_DEBUG_SV.log(l_module_name,'STRUCT_NUM',STRUCT_NUM);
   END IF;
   --
   result := fnd_flex_keyval.validate_ccid
	 (appl_short_name  => 'INV',
	  key_flex_code	=> k_flex_code,
	  structure_number => struct_num,
	  combination_id   => entity_id,
	  data_set		 => warehouse_id);
   IF result THEN
	  name := fnd_flex_keyval.concatenated_values;
   END IF;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN name;
END generic_flex_name;


--
-- Procedure:	Delete
--
-- Parameters:  p_type - type of entities to delete
--		p_del_rows   - ids to be deleted
--		  When returned, id is negated if the delete failed
--		x_return_status - status of procedure call
--
-- Description: Deletes multiple entities
--
--tkt
PROCEDURE Delete(
	p_type				wsh_saved_queries_vl.entity_type%type,
	p_rows		  IN OUT NOCOPY 	wsh_util_core.id_tab_type,
        p_caller          IN VARCHAR2,
	x_return_status	  OUT NOCOPY 		VARCHAR2)
is

  cur_return_status		varchar2(1);
  num_errors			number;
  num_warnings			number;
  l_message			fnd_new_messages.message_name%type;
--new variable
  l_fte_flag					VARCHAR2(1) := 'N';
  l_return_status			   VARCHAR2(30);
  l_stop_rec					WSH_TRIP_STOPS_PVT.trip_stop_rec_type;
  l_trip_rec					WSH_TRIPS_PVT.trip_rec_type;
-- bmso
  l_lpn_ids                  WMS_Data_Type_Definitions_PUB.LPNPurgeRecordType;
  l_lpn_id_tab               wsh_util_core.id_tab_type;

  l_purged_lpns              WMS_Data_Type_Definitions_PUB.LPNPurgeRecordType;

  l_validate_mode   VARCHAR2(100) := wms_container_grp.G_LPN_PURGE_ACTION_VALIDATE;
  l_delete_mode   VARCHAR2(100) := wms_container_grp.G_LPN_PURGE_ACTION_DELETE;
  l_rows_lpns                        wsh_util_core.id_tab_type;
  l_cached_lpns              WSH_UTIL_CORE.Id_Tab_Type;
  l_msg_data			VARCHAR2(32000);
  l_msg_count		   NUMBER;
  l_index                  NUMBER;
  l_count                  NUMBER;
  l_lpn_id                 NUMBER;
  l_delivery_detail_id     NUMBER;

  CURSOR c_get_lpns (v_delivery_detail_id number) IS
  SELECT lpn_id
  FROM wsh_delivery_details
  WHERE delivery_detail_id = v_delivery_detail_id;

  CURSOR c_get_valid_lpns (v_delivery_detail_id NUMBER) IS
  select lpn_id, delivery_detail_id FROM
  wsh_lpn_purge_tmp
  WHERE delivery_detail_id = v_delivery_detail_id
  AND eligible_flag = 'Y';

  CURSOR c_get_valid_lpns_for_wms  IS
  select lpn_id  FROM
  wsh_lpn_purge_tmp
  WHERE lpn_id IS NOT NULL
  AND eligible_flag = 'Y';

  -- K LPN CONV. rv
  l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
  l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
  e_return_excp EXCEPTION;
  -- K LPN CONV. rv
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE';
--
begin

	--
	-- Debug Statements
	--
	--
        --lpn conc
        SAVEPOINT s_delete_savepoint;

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
	num_errors := 0;
	num_warnings := 0;
/* added this check for FTE */
/* so we will not do this for each record */
x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y'
	AND p_type IN ('TRIP','STOP'))THEN
  l_fte_flag := 'Y';

END IF;

  --lpn conv
    IF p_type = 'DLVB' THEN
       IF c_wms_code_present = 'Y' THEN --{
       BEGIN
          SELECT 1
          INTO l_count
          FROM  wsh_lpn_purge_tmp;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             l_count := 0;
       END;

       IF l_count > 0 THEN
          DELETE FROM wsh_lpn_purge_tmp;
       END IF;

       FOR i IN 1..p_rows.count LOOP
          OPEN c_get_lpns(p_rows(i));
          FETCH c_get_lpns INTO l_rows_lpns(i);
          CLOSE c_get_lpns;

          IF l_rows_lpns(i) IS NOT NULL THEN
             l_lpn_ids.lpn_ids(l_lpn_ids.lpn_ids.COUNT + 1) := l_rows_lpns(i);
          END IF;
       END LOOP;

       FORALL i IN 1..p_rows.count
       INSERT INTO wsh_lpn_purge_tmp(
          lpn_id,
          delivery_detail_id,
          eligible_flag
       ) VALUES (
          l_rows_lpns(i),
          p_rows(i),
          decode(l_rows_lpns(i), NULL,'Y','N')
       );

       wms_container_grp.LPN_Purge_Actions (
                  p_api_version           => 1.0
                , p_init_msg_list         => fnd_api.g_false
                , p_commit                => fnd_api.g_false
                , x_return_status         => l_return_status
                , x_msg_count             => l_msg_count
                , x_msg_data              => l_msg_data
                , p_caller                => 'WSH_DELETE'
                , p_action                => l_validate_mode
                , p_lpn_purge_rec         => l_lpn_ids

       );
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       IF l_lpn_ids.lpn_ids.COUNT > 0 THEN

          FORALL i IN l_lpn_ids.lpn_ids.FIRST..l_lpn_ids.lpn_ids.LAST
          UPDATE wsh_lpn_purge_tmp
          SET eligible_flag = 'Y'
          WHERE lpn_id = l_lpn_ids.lpn_ids(i);

       END IF;
       END IF; --}
    END IF;
	for i in 1..p_rows.count loop

  IF l_fte_flag = 'Y' THEN

	IF p_type = 'TRIP' THEN
 -- Get pvt type record structure for trip
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_GRP.GET_TRIP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  wsh_trips_grp.get_trip_details_pvt
		 (p_trip_id => p_rows(i),
		  x_trip_rec => l_trip_rec,
		  x_return_status => l_return_status);
	  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              num_warnings := num_warnings + 1;
            ELSE
	      x_return_status := l_return_status;
	      --
	      -- Debug Statements
	      --
	      --IF l_debug_on THEN
	          --WSH_DEBUG_SV.pop(l_module_name);
	      --END IF;
	      --
	      --RETURN;
              raise e_return_excp; -- LPN CONV. rv
            END IF;
	  END IF;

	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  wsh_fte_integration.trip_stop_validations
		(p_stop_rec => l_stop_rec,
		 p_trip_rec => l_trip_rec,
		 p_action => 'DELETE',
		 x_return_status => l_return_status);

	  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              num_warnings := num_warnings + 1;
            ELSE
	      x_return_status := l_return_status;
	      --
	      -- Debug Statements
	      --
	      --IF l_debug_on THEN
	          --WSH_DEBUG_SV.pop(l_module_name);
	      --END IF;
	      --
	      --RETURN;
              raise e_return_excp; -- LPN CONV. rv
            END IF;
	  END IF;
	ELSIF p_type = 'STOP' THEN

		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.GET_STOP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		wsh_trip_stops_grp.get_stop_details_pvt
			(p_stop_id => p_rows(i),
			 x_stop_rec => l_stop_rec,
			 x_return_status => l_return_status);
	  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              num_warnings := num_warnings + 1;
            ELSE
	      x_return_status := l_return_status;
	      --
	      -- Debug Statements
	      --
	      --IF l_debug_on THEN
	          --WSH_DEBUG_SV.pop(l_module_name);
	      --END IF;
	      --
	      --RETURN;
              raise e_return_excp; -- LPN CONV. rv
            END IF;
	  END IF;

	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  wsh_fte_integration.trip_stop_validations
		(p_stop_rec => l_stop_rec,
		 p_trip_rec => l_trip_rec,
		 p_action => 'DELETE',
		 x_return_status => l_return_status);
	  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              num_warnings := num_warnings + 1;
            ELSE
	      x_return_status := l_return_status;
	      --
	      -- Debug Statements
	      --
	      --IF l_debug_on THEN
	          --WSH_DEBUG_SV.pop(l_module_name);
	      --END IF;
	      --
	      --RETURN;
              raise e_return_excp; -- LPN CONV. rv
            END IF;
	  END IF;

  END IF;
END IF;


	  if (p_type = 'TRIP') then
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.DELETE_TRIP',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wsh_trips_pvt.delete_trip(p_rowid        => null,
                                  p_trip_id       => p_rows(i),
                                  x_return_status => cur_return_status,
                                  p_validate_flag => 'Y',
                                  p_caller        => p_caller);
	  elsif (p_type = 'STOP') then
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.DELETE_TRIP_STOP',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
--tkt
	wsh_trip_stops_pvt.delete_trip_stop(p_rowid        => null,
                                            p_stop_id       => p_rows(i),
                                            x_return_status => cur_return_status,
                                            p_validate_flag => 'Y',
                                            p_caller        => p_caller);
	  elsif (p_type = 'DLVY') then
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.DELETE_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wsh_new_deliveries_pvt.delete_delivery(null, p_rows(i), cur_return_status);
	  elsif (p_type = 'DLEG') then

--	wsh_delivery_legs_pvt.delete_delivery_leg(null, p_rows(i), cur_return_status);

	fnd_message.set_name('WSH','DEL_DLEG_NOT_IMPLEMENTED_YET');
	cur_return_status := wsh_util_core.g_ret_sts_error;
	wsh_util_core.add_message(cur_return_status);

	  elsif (p_type = 'DLVB') then
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.DELETE_CONTAINERS',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
                --lpn conv
                IF c_wms_code_present = 'Y' THEN --{bmso
                   OPEN c_get_valid_lpns(p_rows(i));
                   FETCH c_get_valid_lpns INTO l_lpn_id, l_delivery_detail_id;
                   CLOSE c_get_valid_lpns;
                ELSE --}{
                   l_delivery_detail_id := 1;
                END IF; --}

                IF l_delivery_detail_id IS NOT NULL THEN
		   WSH_CONTAINER_ACTIONS.delete_containers(p_rows(i), cur_return_status);
                   IF cur_return_status NOT IN (wsh_util_core.g_ret_sts_success,
                                            wsh_util_core.g_ret_sts_warning)
                   THEN
                         update wsh_lpn_purge_tmp
                         SET eligible_flag = 'N'
                         WHERE delivery_detail_id = p_rows(i);
                   END IF;
                ELSE
                   cur_return_status :=  wsh_util_core.g_ret_sts_error;
                END IF;

	  end if;

	  if (cur_return_status <> wsh_util_core.g_ret_sts_success) then

		if (cur_return_status = wsh_util_core.g_ret_sts_error) OR (cur_return_status = wsh_util_core.g_ret_sts_unexp_error) then
			p_rows(i) := -p_rows(i);
		end if;


		if (cur_return_status = wsh_util_core.g_ret_sts_warning) then
		  num_warnings := num_warnings + 1;
		else
	  	  num_errors := num_errors + 1;
		end if;

	  end if;
	end loop;

        IF  p_type = 'DLVB' THEN
           IF c_wms_code_present = 'Y' THEN --{ bmso

           OPEN c_get_valid_lpns_for_wms;
           FETCH c_get_valid_lpns_for_wms
           BULK COLLECT INTO l_purged_lpns.lpn_ids;
           CLOSE c_get_valid_lpns_for_wms;

           IF l_purged_lpns.lpn_ids.COUNT > 0 THEN
              wms_container_grp.LPN_Purge_Actions (
                     p_api_version           => 1.0
                   , p_init_msg_list         => fnd_api.g_false
                   , p_commit                => fnd_api.g_false
                   , x_return_status         => l_return_status
                   , x_msg_count             => l_msg_count
                   , x_msg_data              => l_msg_data
                   , p_caller                => 'WSH_DELETE'
                   , p_action                => l_delete_mode
                   , p_lpn_purge_rec         => l_purged_lpns

              );
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;
           END IF; --}
        END IF;
        --
        -- K LPN CONV. rv
        --
        IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
        THEN
        --{
            IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
              (
                p_in_rec             => l_lpn_in_sync_comm_rec,
                x_return_status      => l_return_status,
                x_out_rec            => l_lpn_out_sync_comm_rec
              );
            --
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
            END IF;
            --
            --
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  num_warnings := num_warnings + 1;
              ELSE
                x_return_status := l_return_status;
                --
                -- Debug Statements
                --
                ROLLBACK TO s_delete_savepoint;
                --
	  	num_errors := num_errors + 1;
              END IF;
            END IF;
        --}
        END IF;
        --
        -- K LPN CONV. rv
        --

	if (num_errors > 0) then
		x_return_status := wsh_util_core.g_ret_sts_error;
	elsif (num_warnings >0) then
		x_return_status := wsh_util_core.g_ret_sts_warning;
	end if;

	if (p_type = 'TRIP') then
	  l_message := 'WSH_TRIP_DELETE_SUMMARY';
	elsif (p_type = 'STOP') then
	  l_message := 'WSH_STOP_DELETE_SUMMARY';
	elsif (p_type = 'DLVY') then
	  l_message := 'WSH_DLVY_DELETE_SUMMARY';
	elsif (p_type = 'DLEG') then
	  l_message := 'WSH_DLEG_DELETE_SUMMARY';
	elsif (p_type = 'DLVB') then
	  l_message := 'WSH_DLVB_DELETE_SUMMARY';
	end if;

	wsh_util_core.add_summary_message(
	  l_message,
	  p_rows.count,
	  num_warnings,
	  num_errors,
	  x_return_status);

/* H integration - added exception block */
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
exception
      --
      -- LPN CONV. rv
      WHEN e_return_excp THEN
        --
        IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
        THEN
        --{
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
              (
                p_in_rec             => l_lpn_in_sync_comm_rec,
                x_return_status      => l_return_status,
                x_out_rec            => l_lpn_out_sync_comm_rec
              );
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
            END IF;
            IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
            END IF;
        --}
        END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_RETURN_EXCP');
        END IF;
        -- LPN CONV. rv
        --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO s_delete_savepoint;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle
error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
  WHEN OTHERS THEN
        ROLLBACK TO s_delete_savepoint;
	wsh_util_core.default_handler('WSH_UTIL_CORE.DELETE');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
end delete;


  -- Name	 city_region_postal
  -- Purpose	 concatenates the three fields for the reports
  -- Input Arguments
  --			 p_city
  --			 p_region (state)
  --			 p_postal_code (zip)
  -- RETURN VARCHAR2
  --

  FUNCTION  city_region_postal(
			   p_city		in varchar2,
			   p_region	  in varchar2,
			   p_postal_code in varchar2)
  RETURN VARCHAR2
  IS
   c_r_p VARCHAR2(190); --Bug 4622054 (Increased width from 100 to 190)
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CITY_REGION_POSTAL';
   --
  BEGIN

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
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
	    WSH_DEBUG_SV.log(l_module_name,'P_REGION',P_REGION);
	    WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE',P_POSTAL_CODE);
	END IF;
	--
	IF p_city IS NOT NULL AND p_region IS NOT NULL THEN
	  c_r_p := p_city || ', ' || p_region || ' ' || p_postal_code;
	ELSIF p_city IS NOT NULL AND p_region IS NULL THEN
	  c_r_p := p_city || ' ' || p_postal_code;
	  -- we should concatnate p_city instead of c_r_p.
	ELSIF p_city IS NULL AND p_region IS NOT NULL THEN
	  c_r_p :=				 p_region || ' ' || p_postal_code;
	ELSIF p_city IS NULL AND p_region IS NULL THEN
	  c_r_p := p_postal_code;
	END IF;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN c_r_p;

  END;


/* ==================================================================
   Function: Evaluate shipment priority code.
   ================================================================== */

  FUNCTION  derive_shipment_priority(p_delivery_id IN NUMBER)
  RETURN VARCHAR2 IS

  v_first_code	   wsh_delivery_details.shipment_priority_code%TYPE;
  v_ship_code		wsh_delivery_details.shipment_priority_code%TYPE;

  CURSOR get_ship_codes IS
  SELECT wdd.shipment_priority_code ship_priority_code
	FROM wsh_delivery_details wdd,
		 wsh_delivery_assignments_v wda
   WHERE wda.delivery_detail_id = wdd.delivery_detail_id
         AND nvl(wdd.LINE_DIRECTION , 'O') IN ('O', 'IO')   -- J Inbound Logistics jckwok
	 AND wda.delivery_id = p_delivery_id
	 AND wda.delivery_id is not null
         AND wdd.container_flag = 'N'
	 AND rownum = 1;

  CURSOR get_ship_codes1(p_ship_code IN VARCHAR2) IS
  SELECT wdd.shipment_priority_code ship_priority_code
	FROM wsh_delivery_details wdd,
		 wsh_delivery_assignments_v wda
   WHERE wda.delivery_detail_id = wdd.delivery_detail_id
         AND nvl(wdd.LINE_DIRECTION , 'O') IN ('O', 'IO')   -- J Inbound Logistics jckwok
	 AND wda.delivery_id = p_delivery_id
	 AND wda.delivery_id is not null
         AND wdd.container_flag = 'N'
	 AND (wdd.shipment_priority_code <> p_ship_code
		 OR wdd.shipment_priority_code IS NULL)
	 AND rownum = 1;

  CURSOR get_ship_codes2 IS
  SELECT wdd.shipment_priority_code ship_priority_code
	FROM wsh_delivery_details wdd,
		 wsh_delivery_assignments_v wda
   WHERE wda.delivery_detail_id = wdd.delivery_detail_id
         AND nvl(wdd.LINE_DIRECTION , 'O') IN ('O', 'IO')   -- J Inbound Logistics jckwok
	 AND wda.delivery_id = p_delivery_id
         AND wdd.container_flag = 'N'
	 AND wda.delivery_id is not null
	 AND wdd.shipment_priority_code IS NOT NULL
	 AND rownum = 1;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DERIVE_SHIPMENT_PRIORITY';
--
  BEGIN

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
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
	END IF;
	--
	OPEN get_ship_codes;
	FETCH get_ship_codes
	 INTO v_first_code;
	IF get_ship_codes%NOTFOUND THEN
	  CLOSE get_ship_codes;
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN null;
	END IF;
	CLOSE get_ship_codes;

	IF v_first_code IS NULL THEN
	  OPEN get_ship_codes2;
	  FETCH get_ship_codes2
	   INTO v_ship_code;
	  IF get_ship_codes2%NOTFOUND THEN
		CLOSE get_ship_codes2;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		RETURN null;
	  END IF;
	  CLOSE get_ship_codes2;
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN 'Mixed';
	ELSE
	  OPEN get_ship_codes1(v_first_code);
	  FETCH get_ship_codes1
	   INTO v_ship_code;
	  IF get_ship_codes1%NOTFOUND THEN
		CLOSE get_ship_codes1;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		RETURN v_first_code;
	  END IF;
	  CLOSE get_ship_codes1;
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN 'Mixed';
	END IF;

  EXCEPTION
	WHEN OTHERS THEN
	  IF get_ship_codes%ISOPEN THEN
		CLOSE get_ship_codes;
	  END IF;
	  IF get_ship_codes1%ISOPEN THEN
		CLOSE get_ship_codes1;
	  END IF;
	  IF get_ship_codes2%ISOPEN THEN
		CLOSE get_ship_codes2;
	  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
	  RETURN null;

  END DERIVE_SHIPMENT_PRIORITY;

--
-- Procedure:	Get_Ledger_id_Func_Currency
--
-- Parameters:  p_org_id - operating unit org id, this parameter is now
--                         mandatory.
--		x_ledger_id - ledger id
--		x_func_currency - currency code for the Ledger
--		x_return_status - status of procedure call
--
-- Description: Deletes multiple entities
--


  PROCEDURE Get_Ledger_id_Func_Currency(
			   p_org_id		  IN	  NUMBER ,
			   x_ledger_id		  OUT NOCOPY 	 NUMBER ,
			   x_func_currency   OUT NOCOPY 	 VARCHAR2 ,
			   x_return_status   OUT NOCOPY 	 VARCHAR2)
  IS
  l_ledger_id				NUMBER;
  l_functional_currency   GL_LEDGERS_PUBLIC_V.currency_code%type;
  l_org_id                 NUMBER;
--

-- this cursor is copied from OEXVSPMB.pls, function Get_AR_Sys_Params
-- to get ledger id from org_id
-- LE Uptake
CURSOR	c_ledger_and_func_curr (v_org_id NUMBER) IS
  SELECT	ar.org_id, ar.set_of_books_id, glpv.currency_code
  FROM	  ar_system_parameters_all ar, gl_ledgers_public_v  glpv
  WHERE  ar.ORG_ID      = p_org_id
  AND	 glpv.ledger_id = ar.set_of_books_id;

--
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_LEDGER_ID_FUNC_CURRENCY';

WSH_GET_LEDGER_ERROR exception; -- LE Uptake
--
  BEGIN
 /* In LE Uptake, changed all occurances of set_of_books to ledger in this API.*/
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
    WSH_DEBUG_SV.log(l_module_name,'P_ORG_ID',P_ORG_ID);
    WSH_DEBUG_SV.log(l_module_name,'G_OPERATING_UNIT_INFO.org_id',
                                    G_OPERATING_UNIT_INFO.org_id);
  END IF;
  --
  x_ledger_id		:=  NULL;
  x_func_currency	:=  NULL;
  x_return_status	:=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  IF p_org_id = G_OPERATING_UNIT_INFO.org_id THEN
    x_ledger_id	    := G_OPERATING_UNIT_INFO.ledger_id;
    x_func_currency := G_OPERATING_UNIT_INFO.currency_code;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Return cached value for p_org = G_OPERATING_UNIT_INFO.org_id');
    END IF;
  ELSE
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Get Ledger id from p_org_id');
    END IF;
    OPEN  c_ledger_and_func_curr( p_org_id);
    FETCH c_ledger_and_func_curr
    INTO  l_org_id, x_ledger_id, x_func_currency;
    IF (c_ledger_and_func_curr%NOTFOUND) THEN
      raise WSH_GET_LEDGER_ERROR;
    END IF;
    -- populate the cache
    G_OPERATING_UNIT_INFO.org_id        := p_org_id;
    G_OPERATING_UNIT_INFO.ledger_id     := x_ledger_id;
    G_OPERATING_UNIT_INFO.currency_code := x_func_currency;
    CLOSE c_ledger_and_func_curr;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'LEDGER ID',x_ledger_id);
    WSH_DEBUG_SV.log(l_module_name,'FUNC CURRENCY',x_func_currency);
    WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
--
EXCEPTION
   WHEN WSH_GET_LEDGER_ERROR THEN
     IF c_ledger_and_func_curr%ISOPEN THEN
       CLOSE c_ledger_and_func_curr;
     END IF;
     x_ledger_id       :=  NULL;
     x_func_currency   :=  NULL;
     x_return_status   :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
     fnd_message.set_name('WSH', 'WSH_LEDGER_ID_NOT_FOUND');
     WSH_UTIL_CORE.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);

     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;

   WHEN others THEN
     x_ledger_id     :=  NULL;
     x_func_currency :=  NULL;
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     IF c_ledger_and_func_curr%ISOPEN THEN
 	CLOSE c_ledger_and_func_curr;
     END IF;
     wsh_util_core.default_handler('WSH_UTIL_CORE.Get_Ledger_id_Func_Currency');
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
--
--
  END Get_Ledger_id_Func_Currency;



  --
  -- Name	 Print_Label
  -- Purpose
  --
  -- Input Arguments
  --
  --
  PROCEDURE Print_Label(
			   p_delivery_ids	IN	 WSH_UTIL_CORE.Id_Tab_Type,
			   p_stop_ids		IN	 WSH_UTIL_CORE.Id_Tab_Type,
			   x_return_status   OUT NOCOPY 	VARCHAR2)
  IS

  CURSOR get_delivery_wms(x_delivery_id NUMBER) IS
  SELECT mp.wms_enabled_flag,
		 wnd.delivery_id
  FROM   wsh_new_deliveries wnd,
		 mtl_parameters	 mp
  WHERE  wnd.delivery_id = x_delivery_id AND
		 mp.organization_id = wnd.organization_id AND
		 mp.wms_enabled_flag = 'Y';


  CURSOR pickup_deliveries_wms (l_stop_id NUMBER) IS
  SELECT dg.delivery_id,
		 st.trip_id,
		 dl.organization_id,
		 mp.wms_enabled_flag
  FROM   wsh_new_deliveries dl,
		  wsh_delivery_legs dg,
		  wsh_trip_stops st,
		  mtl_parameters mp
  WHERE  dg.delivery_id = dl.delivery_id AND
                  nvl(dl.SHIPMENT_DIRECTION, 'O') IN ('O', 'IO') AND  -- J Inbound Logistics jckwok
		  st.stop_location_id = dl.initial_pickup_location_id AND
		  st.stop_id = dg.pick_up_stop_id AND
		  st.stop_id = l_stop_id AND
		  dl.organization_id = mp.organization_id AND
		  mp.wms_enabled_flag = 'Y';


  j				NUMBER;
  l_label_return_status VARCHAR2(1);
  l_label_status		VARCHAR2(1);
  l_msg_data			VARCHAR2(2000);
  l_msg_count		   NUMBER;
  l_del_tab INV_LABEL_PUB.transaction_id_rec_type;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINT_LABEL';
--
  BEGIN
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
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID.COUNT',p_delivery_ids.count);
	    WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID.COUNT',p_stop_ids.count);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;
	l_del_tab.delete;
	j := 0;
	IF p_delivery_ids.count > 0 THEN
				 FOR i in 1..p_delivery_ids.count LOOP
					  FOR del IN get_delivery_wms(p_delivery_ids(i)) LOOP
						 j := j+1;
						 l_del_tab(j) := del.delivery_id;
					  END LOOP;
				 END LOOP;
	ELSIF p_stop_ids.count > 0 THEN
				 FOR i in 1..p_stop_ids.count LOOP
				  FOR del IN pickup_deliveries_wms (p_stop_ids(i)) LOOP
						 j := j+1;
						 l_del_tab(j) := del.delivery_id;
					  END LOOP;
				 END LOOP;
	END IF;

	IF get_delivery_wms%ISOPEN THEN
		CLOSE get_delivery_wms;
	END IF;
	IF pickup_deliveries_wms%ISOPEN THEN
		CLOSE pickup_deliveries_wms;
	END IF;
	IF l_del_tab.count > 0 THEN
						 /* call print_label API */
						 --
						 -- Debug Statements
						 --
						 IF l_debug_on THEN
						     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_LABEL_PUB.PRINT_LABEL',WSH_DEBUG_SV.C_PROC_LEVEL);
						 END IF;
						 --
						 INV_LABEL_PUB.print_label (
							x_return_status	  => l_label_return_status,
							x_msg_count		  => l_msg_count,
							x_msg_data		   => l_msg_data,
							x_label_status	   => l_label_status,
							p_api_version		=> 1.0,
							p_init_msg_list	  => 'F',
							p_commit			 => 'F',
							p_business_flow_code => 21,
							p_transaction_id	 => l_del_tab);

						 IF (l_label_return_status <> 'S') THEN
								FND_MESSAGE.SET_NAME('WSH','WSH_PRINT_LABEL_ERROR');
							x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
								wsh_util_core.add_message(x_return_status);
						 END IF;
	  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
	 EXCEPTION
		WHEN others THEN
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   IF get_delivery_wms%ISOPEN THEN
			  CLOSE get_delivery_wms;
		   END IF;

	           IF pickup_deliveries_wms%ISOPEN THEN
			  CLOSE pickup_deliveries_wms;
		   END IF;
		   wsh_util_core.default_handler('WSH_UTIL_CORE.Print_Label');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END  Print_Label;

  /*  H integration: Pricing integration csun
   */
  --
  -- Name	FTE_Is_Installed
  -- Purpose	To check if FTE is installed, it return 'Y' if
  --			FTE is installed, 'N' otherwise.
  -- History:
  --    Added by Suresh on Jun-14-2002
  --    Added validation to check FTE is enabled or not by calling
  --    wsh_fte_enabled.check_status function
  --    Initially FTE is always disabled for ONT.H
  --
  -- Input Arguments: No input arguments
  --
  --
  FUNCTION FTE_Is_Installed RETURN VARCHAR2 IS

  l_fte_install_status  VARCHAR2(30);
  l_industry			VARCHAR2(30);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FTE_IS_INSTALLED';
--
  BEGIN
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
        IF (wsh_fte_enabled.check_status = 'Y' AND
            Get_Otm_Install_Profile_Value = 'N') THEN -- OTM R12
            IF G_FTE_IS_INSTALLED is NULL THEN
		IF (fnd_installation.get(716, 716,l_fte_install_status,l_industry)) THEN
			IF (l_fte_install_status = 'I') THEN
			   G_FTE_IS_INSTALLED := 'Y';

                           -- User customization starts (FP bug 4688529--bug 4602901)
                           IF  (fnd_profile.value('WSH_FTE_INSTALLATION_STATUS') = 'N') THEN
                             G_FTE_IS_INSTALLED := 'N';
                           END IF;
                           -- User customization ends
			ELSE
			   G_FTE_IS_INSTALLED := 'N';
			END IF;
		ELSE
		   /* this happens only when invalid application id is passed */
		   G_FTE_IS_INSTALLED := 'N';
		END IF;

	    END IF;
        ELSE
            G_FTE_IS_INSTALLED := 'N';
        END IF;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'G_FTE_IS_INSTALLED',G_FTE_IS_INSTALLED);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return G_FTE_IS_INSTALLED;
  END FTE_Is_Installed;

  --
  -- Name	TP_Is_Installed
  -- Purpose	To check if TP is installed, it return 'Y' if
  --		TP is installed, 'N' otherwise.
  -- History:
  --            Added by Arindam on May-13-2003
  --
  -- Input Arguments: No input arguments
  --
  --
  FUNCTION TP_Is_Installed RETURN VARCHAR2 IS

  l_tp_install_status  VARCHAR2(30);
  l_industry			VARCHAR2(30);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TP_IS_INSTALLED';
--
  BEGIN
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
        IF G_TP_IS_INSTALLED is NULL THEN
              -- OTM R12
              IF Get_Otm_Install_Profile_Value = 'N' THEN
		IF fnd_installation.get(390, 390,l_tp_install_status,l_industry) THEN
			IF (l_tp_install_status = 'I') THEN
			   G_TP_IS_INSTALLED := 'Y';
			ELSE
			   G_TP_IS_INSTALLED := 'N';
			END IF;

	                --User customization starts
	                IF fnd_profile.value('WSH_TP_INSTALLATION_STATUS') IN ('Y','N') THEN
		            G_TP_IS_INSTALLED := fnd_profile.value('WSH_TP_INSTALLATION_STATUS');
	                END IF;
	                -- User customization ends
		ELSE
		   /* this happens only when invalid application id is passed */
		   G_TP_IS_INSTALLED := 'N';
		END IF;
              ELSE
                G_TP_IS_INSTALLED := 'N';
              END IF;
	END IF;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'G_TP_IS_INSTALLED',G_TP_IS_INSTALLED);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return G_TP_IS_INSTALLED;
  EXCEPTION
	WHEN OTHERS THEN

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
        RETURN 'N';
  END TP_Is_Installed;
-- ------------------------------------------------------------------------
-- Name		Get_Trip_Name
-- Purpose	 This procedure gets the trip name from a delivery leg id
-- Input Arguments
--	   delivery_leg_id
-- ------------------------------------------------------------------------

  PROCEDURE Get_Trip_Name_by_Leg(
               p_delivery_leg_id    IN     NUMBER,
               x_trip_name          OUT NOCOPY     VARCHAR2,
               x_reprice_required   OUT NOCOPY     VARCHAR2,
               x_return_status      OUT NOCOPY     VARCHAR2) IS

   CURSOR c_get_trip_name IS
      SELECT TP.Name, DLG.reprice_required
      FROM WSH_DELIVERY_LEGS DLG,
           WSH_TRIP_STOPS    TS,
           WSH_TRIPS         TP
      WHERE DLG.delivery_leg_id = p_delivery_leg_id AND
            DLG.pick_up_stop_id = TS.stop_id AND
            TS.trip_id = TP.trip_id;

  l_trip_name VARCHAR2(30) := NULL;
  l_reprice_required  VARCHAR2(1) := NULL;

  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_TRIP_NAME_BY_LEG';
  --
  BEGIN

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
         --
         WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_LEG_ID',P_DELIVERY_LEG_ID);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;
     OPEN c_get_trip_name;
     FETCH c_get_trip_name INTO l_trip_name, l_reprice_required;
     IF c_get_trip_name%NOTFOUND THEN
        x_trip_name := NULL;
        x_reprice_required := NULL;
     ELSE
        x_trip_name := l_trip_name;
        x_reprice_required := l_reprice_required;
     END IF;
     CLOSE c_get_trip_name;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'TRIP NAME',x_trip_name);
         WSH_DEBUG_SV.log(l_module_name,'Reprice Required',x_reprice_required);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
  EXCEPTION
     WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.default_handler('WSH_UTIL_CORE.Print_Label');

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
   --
  END Get_Trip_Name_by_Leg;


--Harmonization Project I **heali
  PROCEDURE api_post_call(
              p_return_status IN VARCHAR2,
              x_num_warnings  IN OUT NOCOPY NUMBER,
              x_num_errors    IN OUT NOCOPY NUMBER,
              p_msg_data      IN  VARCHAR2,
              p_raise_error_flag IN BOOLEAN
              )
              -- p_msg_data is defaulted to NULL.
              -- p_raise_error_flag is defaulted to TRUE
  IS
  --
  --
  --l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
  --
  --l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'API_POST_CALL';
  --
  --
  BEGIN
    --
    --
    /*
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'p_msg_data',p_msg_data);
      WSH_DEBUG_SV.log(l_module_name,'p_return_status',p_return_status);
      WSH_DEBUG_SV.log(l_module_name,'x_num_warnings',x_num_warnings);
      WSH_DEBUG_SV.log(l_module_name,'x_num_errors',x_num_errors);
    END IF;
    */

    --
    IF p_msg_data IS NOT NULL THEN
      fnd_message.set_name('WSH','WSH_MESSAGE_DATA');
      fnd_message.set_token('MESSAGE_DATA',p_msg_data);
    END IF;
    --
    --
    IF p_return_status IS NULL THEN
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF p_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
       x_num_errors := nvl(x_num_errors,0) + 1;
       IF p_raise_error_flag THEN
         raise FND_API.G_EXC_ERROR;
       END IF;
    ELSIF p_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
       x_num_errors := nvl(x_num_errors,0) + 1;
       IF p_raise_error_flag THEN
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    ELSIF p_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
       x_num_warnings := nvl(x_num_warnings,0) + 1;
    END IF;
    --
    --
    --
    /*
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_num_warnings',x_num_warnings);
       WSH_DEBUG_SV.log(l_module_name,'x_num_errors',x_num_errors);
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    */
    --
    --
  EXCEPTION
    --
    --
    WHEN FND_API.G_EXC_ERROR THEN
      --
      raise FND_API.G_EXC_ERROR;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
      --
    WHEN OTHERS THEN
      --
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
      --
      /*
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      */
    --
    --
  END api_post_call;

--Harmonization Project I **heali
PROCEDURE api_post_call(
        p_return_status IN VARCHAR2,
        x_num_warnings  IN OUT NOCOPY NUMBER,
        x_num_errors    IN OUT NOCOPY NUMBER,
        p_module_name   IN VARCHAR2,
        p_msg_data      IN VARCHAR2,
	p_token1        IN VARCHAR2 DEFAULT NULL,
	p_value1        IN VARCHAR2 DEFAULT NULL,
	p_token2        IN VARCHAR2 DEFAULT NULL,
	p_value2        IN VARCHAR2 DEFAULT NULL,
	p_token3        IN VARCHAR2 DEFAULT NULL,
	p_value3        IN VARCHAR2 DEFAULT NULL,
	p_token4        IN VARCHAR2 DEFAULT NULL,
	p_value4        IN VARCHAR2 DEFAULT NULL,
	p_token5        IN VARCHAR2 DEFAULT NULL,
	p_value5        IN VARCHAR2 DEFAULT NULL,
	p_token6        IN VARCHAR2 DEFAULT NULL,
	p_value6        IN VARCHAR2 DEFAULT NULL,
	p_token7        IN VARCHAR2 DEFAULT NULL,
	p_value7        IN VARCHAR2 DEFAULT NULL,
	p_token8        IN VARCHAR2 DEFAULT NULL,
	p_value8        IN VARCHAR2 DEFAULT NULL,
        p_raise_error_flag IN BOOLEAN DEFAULT TRUE )
IS
  --l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
  --
  --l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'API_POST_CALL';
  --
  --
BEGIN
    /*
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'p_msg_data',p_msg_data);
      WSH_DEBUG_SV.log(l_module_name,'p_return_status',p_return_status);
      WSH_DEBUG_SV.log(l_module_name,'x_num_warnings',x_num_warnings);
      WSH_DEBUG_SV.log(l_module_name,'x_num_errors',x_num_errors);
    END IF;
    */

    --
    IF (p_msg_data IS NOT NULL AND p_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)THEN
      add_message(
        p_message_type => p_return_status,
        p_module_name  => p_module_name,
        p_error_name   => p_msg_data,
        p_token1       => p_token1,
        p_value1       => p_value1,
        p_token2       => p_token2,
        p_value2       => p_value2,
        p_token3       => p_token3,
        p_value3       => p_value3,
        p_token4       => p_token4,
        p_value4       => p_value4,
        p_token5       => p_token5,
        p_value5       => p_value5,
        p_token6       => p_token6,
        p_value6       => p_value6,
        p_value7       => p_value7,
        p_token7       => p_token7,
        p_value8       => p_value8,
        p_token8       => p_token8);
    END IF;

    api_post_call(
    	p_return_status 	=> p_return_status,
        x_num_warnings 		=> x_num_warnings,
        x_num_errors   		=> x_num_errors,
        p_msg_data     		=> NULL,
        p_raise_error_flag	=> p_raise_error_flag);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      raise FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
END api_post_call;
--Harmonization Project I **heali

  FUNCTION get_operatingUnit_id ( p_delivery_id      IN   NUMBER )
  RETURN  NUMBER
  IS
  l_cnt      NUMBER;
  l_org_id   NUMBER DEFAULT 0;
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
                                                        'get_operatingUnit_id';
  CURSOR c_orgs (v_delivery_id NUMBER) IS
    SELECT wdd.org_id org_id , count(*) cnt
    FROM wsh_delivery_assignments_v wda,
        wsh_delivery_details wdd
    WHERE wdd.delivery_detail_id = wda.delivery_detail_id
    AND   wda.delivery_id        =  v_delivery_id
    AND   wdd.container_flag     = 'N'
    GROUP BY org_id
    ORDER BY cnt DESC;

  BEGIN
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
         --
         WSH_DEBUG_SV.log(l_module_name,'p_delivery_id',p_delivery_id);
     END IF;

     OPEN c_orgs(p_delivery_id) ;
        FETCH c_orgs INTO l_org_id, l_cnt;
        IF c_orgs%NOTFOUND THEN
           l_org_id := -1;
        END IF;
     CLOSE c_orgs;

     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_org_id',l_org_id);
        WSH_DEBUG_SV.log(l_module_name,'l_cnt',l_cnt);
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;

     RETURN l_org_id;
  EXCEPTION
    WHEN OTHERS THEN
     wsh_util_core.default_handler('WSH_UTIL_CORE.GET_OPERATINGUNIT_ID',
                                                               l_module_name);
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END get_operatingUnit_id;

  --
  -- Name        Store_Msg_In_Table
  -- Purpose     This procedure takes a table of messages and push
  --             them to the FND stack and also returns number of errors,
  --             warns, unexpected errors, and successes.
  --
  -- Input Arguments
  --   p_store_flag
  --
  PROCEDURE Store_Msg_In_Table (
               p_store_flag     IN     Boolean,
               x_msg_rec_count   OUT NOCOPY     WSH_UTIL_CORE.MsgCountType,
               x_return_status   OUT NOCOPY     VARCHAR2) IS
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'STORE_MSG_IN_TABLE';
  --

  BEGIN

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
         --
         WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_LEG_ID',P_STORE_FLAG);
     END IF;
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;
     IF (p_store_flag = FALSE) THEN
        x_msg_rec_count.e_count := 0;
        x_msg_rec_count.w_count := 0;
        x_msg_rec_count.u_count := 0;
        x_msg_rec_count.s_count := 0;
        FOR i IN 1..WSH_INTEGRATION.G_MSG_TABLE.COUNT  LOOP
           fnd_message.set_name('WSH','WSH_UTIL_MESSAGE_'||WSH_INTEGRATION.G_MSG_TABLE(i).MESSAGE_TYPE);
           fnd_message.set_token('MSG_TEXT',WSH_INTEGRATION.G_MSG_TABLE(i).MESSAGE_TEXT);
           fnd_msg_pub.add;
           IF ( WSH_INTEGRATION.G_MSG_TABLE(i).MESSAGE_TYPE = 'E' ) THEN
              x_msg_rec_count.e_count  := x_msg_rec_count.e_count  + 1 ;
           ELSIF ( WSH_INTEGRATION.G_MSG_TABLE(i).MESSAGE_TYPE = 'W' ) THEN
              x_msg_rec_count.w_count   := x_msg_rec_count.w_count + 1 ;
           ELSIF ( WSH_INTEGRATION.G_MSG_TABLE(i).MESSAGE_TYPE = 'U' ) THEN
              x_msg_rec_count.u_count   := x_msg_rec_count.u_count + 1 ;
           ELSIF ( WSH_INTEGRATION.G_MSG_TABLE(i).MESSAGE_TYPE = 'S' ) THEN
              x_msg_rec_count.s_count   := x_msg_rec_count.s_count + 1 ;
           END IF ;
        END LOOP ;
        G_STORE_MSG_IN_TABLE := FALSE ;
        WSH_INTEGRATION.G_MSG_TABLE.delete ;
     ELSE
        G_STORE_MSG_IN_TABLE := TRUE;
     END IF;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Error Count', x_msg_rec_count.e_count);
         WSH_DEBUG_SV.log(l_module_name,'Warning Count', x_msg_rec_count.w_count);
         WSH_DEBUG_SV.log(l_module_name,'Unexpected Error Count', x_msg_rec_count.u_count);
         WSH_DEBUG_SV.log(l_module_name,'Success Count', x_msg_rec_count.s_count);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
  EXCEPTION
     WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        WSH_UTIL_CORE.Println('Unexpected Error in WSH_UTIL_CORE.Store_Msg_In_Table');
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
   --

  END Store_Msg_In_Table;



--========================================================================
-- PROCEDURE : get_cached_value
--
-- PARAMETERS: p_cache_tbl             this table is used to  hold the cache
--                                     values, which key is less than 2^31
--             p_cache_ext_tbl         This  table is used to  hold the cache
--                                     values, which key is more then 2^31
--             p_value                 This the value to be either inserted
--                                     or reterived from the cache.
--             p_key                   This is the key that we use to access
--                                     the cache table.
--             p_action                if 'PUT' is passed, then the p_value
--                                     is put into the cache.  If 'GET'is passed
--                                     then the value will be retrieved from
--                                     cache.
--             x_return_status         return status
--
-- COMMENT   : This table will manage a cache (storing integer values)
--             IF value 'PUT' is passed to p_action, then p_value will be set
--             into the cache, where p_key is used to access the cache table.
--             IF value 'GET' is passed to p_action, then the information
--             on the cache is retrieved.  The p_key is used to access the
--             cache table.
--             If the get operation is a miss, then a warning will be
--             returned.
--========================================================================



  PROCEDURE get_cached_value(
                             p_cache_tbl IN OUT NOCOPY key_value_tab_type,
                             p_cache_ext_tbl IN OUT NOCOPY key_value_tab_type,
                             p_value IN OUT NOCOPY NUMBER,
                             p_key IN NUMBER,
                             p_action IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2
                           )
  IS
    l_debug_on BOOLEAN;
    --
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'GET_CACHED_VALUE';
    l_index      NUMBER;
    l_found      BOOLEAN := FALSE;
    l_exist      BOOLEAN := FALSE;
    j            NUMBER;

  BEGIN
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       WSH_DEBUG_SV.log(l_module_name, 'p_value', p_value);
       WSH_DEBUG_SV.log(l_module_name, 'p_key', p_key);
       WSH_DEBUG_SV.log(l_module_name, 'p_action', p_action);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF p_action = 'PUT' THEN --{
        IF p_key IS NULL THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'p_key cannot be null', p_key);
           END IF;
           RAISE FND_API.G_EXC_ERROR ;
        END IF;
        IF p_key < C_INDEX_LIMIT THEN
           p_cache_tbl(p_key).value := p_value;
           p_cache_tbl(p_key).key := p_key;
        ELSE
           j:= p_cache_ext_tbl.FIRST;
           WHILE j IS NOT NULL LOOP
              IF p_cache_ext_tbl(j).key = p_key THEN
                 p_cache_ext_tbl(j).value := p_value;
                 l_exist := TRUE;
                 EXIT;
              END IF;
              j := p_cache_ext_tbl.NEXT(j);
           END LOOP;
           IF NOT l_exist THEN
              p_cache_ext_tbl(p_cache_ext_tbl.COUNT + 1).key := p_key;
              p_cache_ext_tbl(p_cache_ext_tbl.COUNT).value := p_value;
           END IF;
        END IF;
     ELSE --}{
        IF p_key < C_INDEX_LIMIT THEN --{
           IF p_cache_tbl.EXISTS(p_key) THEN
              p_value := p_cache_tbl(p_key).value;
           ELSE
              RAISE WSH_UTIL_CORE.G_EXC_WARNING;
           END IF;
        ELSE --}{
           l_index := p_cache_ext_tbl.FIRST;
           WHILE l_index IS NOT NULL LOOP
              IF p_cache_ext_tbl(l_index).key = p_key THEN
                 p_value := p_cache_ext_tbl(l_index).value;
                 l_found := TRUE;
                 EXIT;
              END IF;
              l_index := p_cache_ext_tbl.NEXT(l_index);
           END LOOP;
           IF NOT l_found THEN
              RAISE WSH_UTIL_CORE.G_EXC_WARNING;
           END IF;
        END IF; --}
     END IF;--}
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
  EXCEPTION
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Cache is missed',
                                                    WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has '
          || 'occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_UTIL_CORE.GET_CACHED_VALUE');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
          'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,
                                 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

  END get_cached_value;



--========================================================================
-- PROCEDURE : get_cached_value
--
-- PARAMETERS: p_cache_tbl             this table is used to  hold the cache
--                                     values, which key is less than 2^31
--             p_cache_ext_tbl         This  table is used to  hold the cache
--                                     values, which key is more then 2^31
--             p_value                 This the value to be either inserted
--                                     or reterived from the cache.
--             p_key                   This is the key that we use to access
--                                     the cache table.
--             p_action                if 'PUT' is passed, then the p_value
--                                     is put into the cache.  If 'GET'is passed
--                                     then the value will be retrieved from
--                                     cache.
--             x_return_status         return status
--
-- COMMENT   : This table will manage a cache (storing varchar2(500) values)
--             IF value 'PUT' is passed to p_action, then p_value will be set
--             into the cache, where p_key is used to access the cache table.
--             IF value 'GET' is passed to p_action, then the information
--             on the cache is retrieved.  The p_key is used to access the
--             cache table.
--             If the get operation is a miss, then a warning will be
--             returned.
--========================================================================



  PROCEDURE get_cached_value(
                             p_cache_tbl IN OUT NOCOPY char500_tab_type,
                             p_cache_ext_tbl IN OUT NOCOPY char500_tab_type,
                             p_value IN OUT NOCOPY VARCHAR2,
                             p_key IN NUMBER,
                             p_action IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2
                           )
  IS
    l_debug_on BOOLEAN;
    --
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'GET_CACHED_VALUE';

    l_index      NUMBER;
    l_found      BOOLEAN := FALSE;
    l_exist      BOOLEAN := FALSE;
    j            NUMBER;

  BEGIN
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       WSH_DEBUG_SV.log(l_module_name, 'p_value', p_value);
       WSH_DEBUG_SV.log(l_module_name, 'p_key', p_key);
       WSH_DEBUG_SV.log(l_module_name, 'p_action', p_action);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF p_action = 'PUT' THEN --{
        IF p_key IS NULL THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'p_key cannot be null', p_key);
           END IF;
           RAISE FND_API.G_EXC_ERROR ;
        END IF;
        IF p_key < C_INDEX_LIMIT THEN
           p_cache_tbl(p_key).value := p_value;
           p_cache_tbl(p_key).key := p_key;
        ELSE
           j:= p_cache_ext_tbl.FIRST;
           WHILE j IS NOT NULL LOOP
              IF p_cache_ext_tbl(j).key = p_key THEN
                 p_cache_ext_tbl(j).value := p_value;
                 l_exist := TRUE;
                 EXIT;
              END IF;
              j := p_cache_ext_tbl.NEXT(j);
           END LOOP;
           IF NOT l_exist THEN
              p_cache_ext_tbl(p_cache_ext_tbl.COUNT + 1).key := p_key;
              p_cache_ext_tbl(p_cache_ext_tbl.COUNT).value := p_value;
           END IF;
        END IF;
     ELSE --}{
        IF p_key < C_INDEX_LIMIT THEN --{
           IF p_cache_tbl.EXISTS(p_key) THEN
              p_value := p_cache_tbl(p_key).value;
           ELSE
              RAISE WSH_UTIL_CORE.G_EXC_WARNING;
           END IF;
        ELSE --}{
           l_index := p_cache_ext_tbl.FIRST;
           WHILE l_index IS NOT NULL LOOP
              IF p_cache_ext_tbl(l_index).key = p_key THEN
                 p_value := p_cache_ext_tbl(l_index).value;
                 l_found := TRUE;
                 EXIT;
              END IF;
              l_index := p_cache_ext_tbl.NEXT(l_index);
           END LOOP;
           IF NOT l_found THEN
              RAISE WSH_UTIL_CORE.G_EXC_WARNING;
           END IF;
        END IF; --}
     END IF;--}
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;

  EXCEPTION
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Cache is missed',
                                                    WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has '
          || 'occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_UTIL_CORE.GET_CACHED_VALUE');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
          'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,
                                 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

  END get_cached_value;

--========================================================================
-- PROCEDURE : get_cached_value
--
-- PARAMETERS: p_cache_tbl             this table is used to  hold the cache
--                                     values, which key is less than 2^31
--             p_cache_ext_tbl         This  table is used to  hold the cache
--                                     values, which key is more then 2^31
--             p_value                 This the value to be either inserted
--                                     or reterived from the cache.
--             p_key                   This is the key that we use to access
--                                     the cache table.
--             p_action                if 'PUT' is passed, then the p_value
--                                     is put into the cache.  If 'GET'is passed
--                                     then the value will be retrieved from
--                                     cache.
--             x_return_status         return status
--
-- COMMENT   : This table will manage a cache (storing BOOLEAN) values)
--             IF value 'PUT' is passed to p_action, then p_value will be set
--             into the cache, where p_key is used to access the cache table.
--             IF value 'GET' is passed to p_action, then the information
--             on the cache is retrieved.  The p_key is used to access the
--             cache table.
--             If the get operation is a miss, then a warning will be
--             returned.
--========================================================================



  PROCEDURE get_cached_value(
                             p_cache_tbl IN OUT NOCOPY boolean_tab_type,
                             p_cache_ext_tbl IN OUT NOCOPY boolean_tab_type,
                             p_value IN OUT NOCOPY BOOLEAN,
                             p_key IN NUMBER,
                             p_action IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2
                           )
  IS
    l_debug_on BOOLEAN;
    --
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'GET_CACHED_VALUE';

    l_index      NUMBER;
    l_found      BOOLEAN := FALSE;
    l_exist      BOOLEAN := FALSE;
    j            NUMBER;

  BEGIN
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       WSH_DEBUG_SV.log(l_module_name, 'p_value', p_value);
       WSH_DEBUG_SV.log(l_module_name, 'p_key', p_key);
       WSH_DEBUG_SV.log(l_module_name, 'p_action', p_action);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF p_action = 'PUT' THEN --{
        IF p_key IS NULL THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'p_key cannot be null', p_key);
           END IF;
           RAISE FND_API.G_EXC_ERROR ;
        END IF;
        IF p_key < C_INDEX_LIMIT THEN
           p_cache_tbl(p_key).value := p_value;
           p_cache_tbl(p_key).key := p_key;
        ELSE
           j:= p_cache_ext_tbl.FIRST;
           WHILE j IS NOT NULL LOOP
              IF p_cache_ext_tbl(j).key = p_key THEN
                 p_cache_ext_tbl(j).value := p_value;
                 l_exist := TRUE;
                 EXIT;
              END IF;
              j := p_cache_ext_tbl.NEXT(j);
           END LOOP;
           IF NOT l_exist THEN
              p_cache_ext_tbl(p_cache_ext_tbl.COUNT + 1).key := p_key;
              p_cache_ext_tbl(p_cache_ext_tbl.COUNT).value := p_value;
           END IF;
        END IF;
     ELSE --}{
        IF p_key < C_INDEX_LIMIT THEN --{
           IF p_cache_tbl.EXISTS(p_key) THEN
              p_value := p_cache_tbl(p_key).value;
           ELSE
              RAISE WSH_UTIL_CORE.G_EXC_WARNING;
           END IF;
        ELSE --}{
           l_index := p_cache_ext_tbl.FIRST;
           WHILE l_index IS NOT NULL LOOP
              IF p_cache_ext_tbl(l_index).key = p_key THEN
                 p_value := p_cache_ext_tbl(l_index).value;
                 l_found := TRUE;
                 EXIT;
              END IF;
              l_index := p_cache_ext_tbl.NEXT(l_index);
           END LOOP;
           IF NOT l_found THEN
              RAISE WSH_UTIL_CORE.G_EXC_WARNING;
           END IF;
        END IF; --}
     END IF;--}
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;

  EXCEPTION
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Cache is missed',
                                                    WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has '
          || 'occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_UTIL_CORE.GET_CACHED_VALUE');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
          'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,
                                 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

  END get_cached_value;

--HVOP heali
PROCEDURE OpenDynamicCursor(
       p_cursor         IN OUT NOCOPY RefCurType,
       p_statement      IN VARCHAR2,
       p_dynamic_tab    IN tbl_varchar) IS
  --
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'OpenDynamicCursor';
  --
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
   wsh_debug_sv.push(l_module_name);
   wsh_debug_sv.log(l_module_name, 'p_dynamic_tab.COUNT', p_dynamic_tab.COUNT);
  END IF;
  --

  IF (p_dynamic_tab.COUNT > 50 ) THEN
    IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'p_dynamic_tab.COUNT should not be grater than 50');
      wsh_debug_sv.pop(l_module_name);
      RETURN;
    END IF;
  END IF;


  IF (p_dynamic_tab.COUNT =  0) THEN
     OPEN p_cursor FOR p_statement;
  END IF;

  IF (p_dynamic_tab.COUNT =  1) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1);
  END IF;

  IF (p_dynamic_tab.COUNT =  2) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2);
  END IF;

  IF (p_dynamic_tab.COUNT =  3) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3);
  END IF;

  IF (p_dynamic_tab.COUNT =  4) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4);
  END IF;

  IF (p_dynamic_tab.COUNT =  5) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5);
  END IF;

  IF (p_dynamic_tab.COUNT =  6) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6);
  END IF;

  IF (p_dynamic_tab.COUNT =  7) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7);
  END IF;

  IF (p_dynamic_tab.COUNT =  8) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8);
  END IF;

  IF (p_dynamic_tab.COUNT =  9) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9);
  END IF;

  IF (p_dynamic_tab.COUNT =  10) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10);
  END IF;

  IF (p_dynamic_tab.COUNT =  11) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11);
  END IF;

  IF (p_dynamic_tab.COUNT =  12) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12);
  END IF;

  IF (p_dynamic_tab.COUNT =  13) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13);
  END IF;

  IF (p_dynamic_tab.COUNT =  14) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14);
  END IF;

  IF (p_dynamic_tab.COUNT =  15) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15);
  END IF;

  IF (p_dynamic_tab.COUNT =  16) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16);
  END IF;

  IF (p_dynamic_tab.COUNT =  17) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17);
  END IF;

  IF (p_dynamic_tab.COUNT =  18) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18);
  END IF;

  IF (p_dynamic_tab.COUNT =  19) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19);
  END IF;

  IF (p_dynamic_tab.COUNT =  20) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20);
  END IF;

  IF (p_dynamic_tab.COUNT =  21) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21);
  END IF;

  IF (p_dynamic_tab.COUNT =  22) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22);
  END IF;

  IF (p_dynamic_tab.COUNT =  23) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23);
  END IF;

  IF (p_dynamic_tab.COUNT =  24) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24);
  END IF;

  IF (p_dynamic_tab.COUNT =  25) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25);
  END IF;

  IF (p_dynamic_tab.COUNT =  26) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26);
  END IF;

  IF (p_dynamic_tab.COUNT =  27) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27);
  END IF;

  IF (p_dynamic_tab.COUNT =  28) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28);
  END IF;

  IF (p_dynamic_tab.COUNT =  29) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29);
  END IF;

  IF (p_dynamic_tab.COUNT =  30) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30);
  END IF;

  IF (p_dynamic_tab.COUNT =  31) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31);
  END IF;

  IF (p_dynamic_tab.COUNT =  32) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32);
  END IF;

  IF (p_dynamic_tab.COUNT =  33) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33);
  END IF;

  IF (p_dynamic_tab.COUNT =  34) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34);
  END IF;

  IF (p_dynamic_tab.COUNT =  35) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35);
  END IF;

  IF (p_dynamic_tab.COUNT =  36) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36);
  END IF;

  IF (p_dynamic_tab.COUNT =  37) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37);
  END IF;

  IF (p_dynamic_tab.COUNT =  38) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38);
  END IF;

  IF (p_dynamic_tab.COUNT =  39) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38),
         p_dynamic_tab(39);
  END IF;

  IF (p_dynamic_tab.COUNT =  40) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38),
         p_dynamic_tab(39),
         p_dynamic_tab(40);
  END IF;

  IF (p_dynamic_tab.COUNT =  41) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38),
         p_dynamic_tab(39),
         p_dynamic_tab(40),
         p_dynamic_tab(41);
  END IF;

  IF (p_dynamic_tab.COUNT =  42) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38),
         p_dynamic_tab(39),
         p_dynamic_tab(40),
         p_dynamic_tab(41),
         p_dynamic_tab(42);
  END IF;

  IF (p_dynamic_tab.COUNT =  43) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38),
         p_dynamic_tab(39),
         p_dynamic_tab(40),
         p_dynamic_tab(41),
         p_dynamic_tab(42),
         p_dynamic_tab(43);
  END IF;

  IF (p_dynamic_tab.COUNT =  44) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38),
         p_dynamic_tab(39),
         p_dynamic_tab(40),
         p_dynamic_tab(41),
         p_dynamic_tab(42),
         p_dynamic_tab(43),
         p_dynamic_tab(44);
  END IF;

  IF (p_dynamic_tab.COUNT =  45) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38),
         p_dynamic_tab(39),
         p_dynamic_tab(40),
         p_dynamic_tab(41),
         p_dynamic_tab(42),
         p_dynamic_tab(43),
         p_dynamic_tab(44),
         p_dynamic_tab(45);
  END IF;

  IF (p_dynamic_tab.COUNT =  46) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38),
         p_dynamic_tab(39),
         p_dynamic_tab(40),
         p_dynamic_tab(41),
         p_dynamic_tab(42),
         p_dynamic_tab(43),
         p_dynamic_tab(44),
         p_dynamic_tab(45),
         p_dynamic_tab(46);
  END IF;

  IF (p_dynamic_tab.COUNT =  47) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38),
         p_dynamic_tab(39),
         p_dynamic_tab(40),
         p_dynamic_tab(41),
         p_dynamic_tab(42),
         p_dynamic_tab(43),
         p_dynamic_tab(44),
         p_dynamic_tab(45),
         p_dynamic_tab(46),
         p_dynamic_tab(47);
  END IF;

  IF (p_dynamic_tab.COUNT =  48) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38),
         p_dynamic_tab(39),
         p_dynamic_tab(40),
         p_dynamic_tab(41),
         p_dynamic_tab(42),
         p_dynamic_tab(43),
         p_dynamic_tab(44),
         p_dynamic_tab(45),
         p_dynamic_tab(46),
         p_dynamic_tab(47),
         p_dynamic_tab(48);
  END IF;

  IF (p_dynamic_tab.COUNT =  49) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38),
         p_dynamic_tab(39),
         p_dynamic_tab(40),
         p_dynamic_tab(41),
         p_dynamic_tab(42),
         p_dynamic_tab(43),
         p_dynamic_tab(44),
         p_dynamic_tab(45),
         p_dynamic_tab(46),
         p_dynamic_tab(47),
         p_dynamic_tab(48),
         p_dynamic_tab(49);
  END IF;

  IF (p_dynamic_tab.COUNT =  50) THEN
     OPEN p_cursor FOR p_statement USING
         p_dynamic_tab(1),
         p_dynamic_tab(2),
         p_dynamic_tab(3),
         p_dynamic_tab(4),
         p_dynamic_tab(5),
         p_dynamic_tab(6),
         p_dynamic_tab(7),
         p_dynamic_tab(8),
         p_dynamic_tab(9),
         p_dynamic_tab(10),
         p_dynamic_tab(11),
         p_dynamic_tab(12),
         p_dynamic_tab(13),
         p_dynamic_tab(14),
         p_dynamic_tab(15),
         p_dynamic_tab(16),
         p_dynamic_tab(17),
         p_dynamic_tab(18),
         p_dynamic_tab(19),
         p_dynamic_tab(20),
         p_dynamic_tab(21),
         p_dynamic_tab(22),
         p_dynamic_tab(23),
         p_dynamic_tab(24),
         p_dynamic_tab(25),
         p_dynamic_tab(26),
         p_dynamic_tab(27),
         p_dynamic_tab(28),
         p_dynamic_tab(29),
         p_dynamic_tab(30),
         p_dynamic_tab(31),
         p_dynamic_tab(32),
         p_dynamic_tab(33),
         p_dynamic_tab(34),
         p_dynamic_tab(35),
         p_dynamic_tab(36),
         p_dynamic_tab(37),
         p_dynamic_tab(38),
         p_dynamic_tab(39),
         p_dynamic_tab(40),
         p_dynamic_tab(41),
         p_dynamic_tab(42),
         p_dynamic_tab(43),
         p_dynamic_tab(44),
         p_dynamic_tab(45),
         p_dynamic_tab(46),
         p_dynamic_tab(47),
         p_dynamic_tab(48),
         p_dynamic_tab(49),
         p_dynamic_tab(50);
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
   --
   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
   --
END OpenDynamicCursor;
--HVOP heali


-- Start of comments
-- API name : Get_Lookup_Meaning
-- Type     : Public
-- Pre-reqs : None.
-- Function : API to get meaning for lookup code and type.
-- Parameters :
-- IN:
--        p_lookup_type               IN      Lookup Type.
--        P_lookup_code               IN      Lookup Code.
-- OUT:
--        Api return meaning for lookup code and type.
-- End of comments
FUNCTION Get_Lookup_Meaning(p_lookup_type       IN      VARCHAR2,
                            P_lookup_code       IN      VARCHAR2)
return VARCHAR2 IS

CURSOR get_meaning IS
  SELECT meaning
  FROM WSH_LOOKUPS
  WHERE LOOKUP_TYPE = p_lookup_type
  AND LOOKUP_CODE = P_lookup_code;

l_meaning			VARCHAR2(80);

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_LOOKUP_MEANING';
--
BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_lookup_type',p_lookup_type);
      WSH_DEBUG_SV.log(l_module_name,'P_lookup_code',P_lookup_code);
   END IF;

   OPEN get_meaning;
   FETCH get_meaning INTO l_meaning;
   CLOSE get_meaning;


   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_meaning',l_meaning);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

   IF (l_meaning IS NULL) THEN
      return P_lookup_code;
   ELSE
      return l_meaning;
   END IF;

EXCEPTION
  WHEN others THEN
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   return P_lookup_code;
END Get_Lookup_Meaning;


-- Start of comments
-- API name : Get_Action_Meaning
-- Type     : Public
-- Pre-reqs : None.
-- Function : API to get meaning for Action code and type.
-- Parameters :
-- IN:
--        p_entity                    IN      Entity DLVB/DLVY/STOP/TRIP.
--        P_action_code               IN      Action Code.
-- OUT:
--        Api return meaning for lookup code and type.
-- End of comments
FUNCTION Get_Action_Meaning(p_entity       	IN      VARCHAR2,
                            p_action_code       IN      VARCHAR2)
return VARCHAR2 IS

l_meaning                       VARCHAR2(80);
l_lookup_type                   VARCHAR2(30);
l_lookup_code                   VARCHAR2(30);

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ACTION_MEANING';
--
BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_entity',p_entity);
      WSH_DEBUG_SV.log(l_module_name,'p_action_code',p_action_code);
   END IF;

   IF (p_entity ='DLVB') THEN
      l_lookup_type :='DLVB_PRIVILEGE';

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Inside DLVB l_lookup_type',l_lookup_type);
      END IF;

      IF (p_action_code = 'PICK-RELEASE' ) THEN
         l_lookup_code:= 'DLVB_LAUNCH_PR';

      ELSIF (p_action_code = 'SPLIT_DELIVERY') THEN
         l_lookup_code:= 'DLVB_SPLIT_DELIVERY'; --??

      ELSIF (p_action_code = 'UNASSIGN') THEN
         l_lookup_code:= 'DLVB_UNASSIGN_DLVY';

      ELSIF (p_action_code = 'ASSIGN') THEN
         l_lookup_code:= 'DLVB_ASSIGN_DLVY';

      ELSIF (p_action_code = 'AUTOCREATE-DEL') THEN
         l_lookup_code:= 'DLVB_AUTOCREATE_DLVY';

      ELSIF (p_action_code = 'PACK') THEN
         l_lookup_code:= 'DLVB_PACK';

      ELSIF (p_action_code = 'SPLIT-LINE') THEN
         l_lookup_code:= 'DLVB_SPLIT_LINE';

      ELSIF (p_action_code = 'CYCLE-COUNT') THEN
         l_lookup_code:= 'DLVB_CYCLE_COUNT';

      ELSIF (p_action_code = 'PICK-RELEASE-UI') THEN
         l_lookup_code:= 'DLVB_PR_FORM';

      ELSIF (p_action_code = 'RESOLVE-EXCEPTIONS-UI') THEN
         l_lookup_code:= 'DLVB_RESOLVE_EXC';

      ELSIF (p_action_code = 'AUTOCREATE-TRIP') THEN
         l_lookup_code:= 'DLVB_AUTOCREATE_TRIP';

      ELSIF (p_action_code = 'IGNORE_PLAN') THEN
         l_lookup_code:= 'DLVB_IGNORE_PLAN';

      ELSIF (p_action_code = 'INCLUDE_PLAN') THEN
         l_lookup_code:= 'DLVB_INCLUDE_PLAN';

      ELSIF (p_action_code = 'PICK-PACK-SHIP') THEN
         l_lookup_code:= 'DLVB_PICK_PACK_SHIP';

      ELSIF (p_action_code = 'PICK-SHIP') THEN
         l_lookup_code:= 'DLVB_PICK_SHIP';

      ELSIF (p_action_code = 'WT-VOL') THEN
         l_lookup_code:= 'DLVB_CALC_WV';

      ELSIF (p_action_code = 'AUTO-PACK') THEN
         l_lookup_code:= 'DLVB_AUTOPACK';

      ELSIF (p_action_code = 'AUTO-PACK-MASTER') THEN
         l_lookup_code:= 'DLVB_AUTOPACK_M';

      ELSIF (p_action_code = 'PACKING-WORKBENCH') THEN
         l_lookup_code:= 'DLVB_PACKING_WB';

      ELSIF (p_action_code = 'FREIGHT-COSTS-UI') THEN
         l_lookup_code:= 'DLVB_FREIGHT_COSTS';

      ELSIF (p_action_code = 'RATE_WITH_UPS') THEN
         l_lookup_code:= 'DLVB_UPS_RS';

      ELSIF (p_action_code = 'UPS_TRACKING') THEN
         l_lookup_code:= 'DLVB_UPS_TR';

      ELSIF (p_action_code = 'UPS_TIME_IN_TRANSIT') THEN
         l_lookup_code:= 'DLVB_UPS_TT';

      ELSIF (p_action_code = 'UPS_ADDRESS_VALIDATION') THEN
         l_lookup_code:= 'DLVB_UPS_AV';

      ELSIF (p_action_code = 'CREATE') THEN
         l_lookup_code:= 'DLVB_CREATE';

      ELSIF (p_action_code = 'DELETE') THEN
         l_lookup_code:= 'DLVB_DELETE';

      ELSIF (p_action_code = 'UPDATE') THEN
         l_lookup_code:= 'DLVB_UPDATE';

      ELSIF (p_action_code = 'CANCEL') THEN
         l_lookup_code:= 'DLVB_CANCEL';
      END IF;

   ELSIF (p_entity ='DLVY') THEN

      l_lookup_type :='DLVY_PRIVILEGE';

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Inside DLVY l_lookup_type',l_lookup_type);
      END IF;

      IF (p_action_code = 'CONFIRM') THEN
         l_lookup_code:= 'DLVY_SHIP_CONFIRM';

      ELSIF (p_action_code = 'PICK-SHIP') THEN
         l_lookup_code:= 'DLVY_PICK_SHIP';

      ELSIF (p_action_code = 'PICK-RELEASE') THEN
         l_lookup_code:= 'DLVY_LAUNCH_PR';

      ELSIF (p_action_code = 'PICK-PACK-SHIP') THEN
         l_lookup_code:= 'DLVY_PICK_PACK_SHIP';

      ELSIF (p_action_code = 'UNASSIGN-TRIP') THEN
         l_lookup_code:= 'DLVY_UNASSIGN_TRIP';

      ELSIF (p_action_code = 'ASSIGN-TRIP') THEN
         l_lookup_code:= 'DLVY_ASSIGN_TRIP';

      ELSIF (p_action_code = 'AUTOCREATE-TRIP') THEN
         l_lookup_code:= 'DLVY_AUTOCREATE_TRIP';

      ELSIF (p_action_code = 'OUTBOUND-DOCUMENT') THEN
         l_lookup_code:= 'DLVY_OUTBOUND_DOCUMENT';

      ELSIF (p_action_code = 'PRINT-DOC-SETS') THEN
         l_lookup_code:= 'DLVY_PRINT_DS';

      ELSIF (p_action_code = 'GENERATE-ROUTING-RESPONSE') THEN
         l_lookup_code:= 'DLVY_GENERATE_ROUTING_RESPONSE'; --??

      ELSIF (p_action_code = 'PLAN') THEN
         l_lookup_code:= 'DLVY_PLAN';

      ELSIF (p_action_code = 'UNPLAN') THEN
         l_lookup_code:= 'DLVY_UNPLAN';

      ELSIF (p_action_code = 'FIRM') THEN
         l_lookup_code:= 'DLVY_FIRM';

      ELSIF (p_action_code = 'IGNORE_PLAN') THEN
         l_lookup_code:= 'DLVY_IGNORE_PLAN';

      ELSIF (p_action_code = 'INCLUDE_PLAN') THEN
         l_lookup_code:= 'DLVY_INCLUDE_PLAN';

      ELSIF (p_action_code = 'WT-VOL') THEN
         l_lookup_code:= 'DLVY_CALC_WV';

      ELSIF (p_action_code = 'AUTO-PACK') THEN
         l_lookup_code:= 'DLVY_AUTOPACK';

      ELSIF (p_action_code = 'AUTO-PACK-MASTER') THEN
         l_lookup_code:= 'DLVY_AUTOPACK_M';

      ELSIF (p_action_code = 'GEN-LOAD-SEQ') THEN
         l_lookup_code:= 'DLVY_GENERATE_LS';

      ELSIF (p_action_code = 'RE-OPEN') THEN
         l_lookup_code:= 'DLVY_REOPEN';

      ELSIF (p_action_code = 'CLOSE') THEN
         l_lookup_code:= 'DLVY_CLOSE';

      ELSIF (p_action_code = 'TRIP-CONSOLIDATION') THEN
         l_lookup_code:= 'DLVY_TRIP_CONSOLIDATION'; --??

      ELSIF (p_action_code = 'SELECT-CARRIER') THEN
         l_lookup_code:= 'DLVY_SELECT_CARRIER';

      ELSIF (p_action_code = 'GENERATE-PACK-SLIP') THEN
         l_lookup_code:= 'DLVY_GENERATE_PS';

      ELSIF (p_action_code = 'PICK-RELEASE-UI') THEN
         l_lookup_code:= 'DLVY_PR_FORM';

      ELSIF (p_action_code = 'RESOLVE-EXCEPTIONS-UI') THEN
         l_lookup_code:= 'DLVY_RESOLVE_EXC';

      ELSIF (p_action_code = 'TRANSACTION-HISTORY-UI') THEN
         l_lookup_code:= 'DLVY_VW_TRANS_HISTORY';

      ELSIF (p_action_code = 'FREIGHT-COSTS-UI') THEN
         l_lookup_code:= 'DLVY_FREIGHT_COSTS';

      ELSIF (p_action_code = 'CANCEL-SHIP-METHOD') THEN
         l_lookup_code:= 'DLVY_CANCEL_SHIP_METHOD';

      ELSIF (p_action_code = 'ADJUST-PLANNED-FLAG') THEN
         l_lookup_code:= 'DLVY_ADJUST_PLANNED_FLAG'; --??

      ELSIF (p_action_code = 'PRINT-PACK-SLIP') THEN
         l_lookup_code:= 'DLVY_GENERATE_PS';

      ELSIF (p_action_code = 'PRINT-BOL') THEN
         l_lookup_code:= 'DLVY_GENERATE_BOL';

      ELSIF (p_action_code = 'DLVY_LOG_EXCEP') THEN
         l_lookup_code:= 'DLVY-LOG-EXCEP';

      ELSIF (p_action_code = 'RATE_WITH_UPS') THEN
         l_lookup_code:= 'DLVY_UPS_RS';

      ELSIF (p_action_code = 'UPS_ADDRESS_VALIDATION') THEN
         l_lookup_code:= 'DLVY_UPS_AV';

      ELSIF (p_action_code = 'UPS_TIME_IN_TRANSIT') THEN
         l_lookup_code:= 'DLVY_UPS_TT';

      ELSIF (p_action_code = 'CREATE') THEN
         l_lookup_code:= 'DLVY_CREATE';

      ELSIF (p_action_code = 'DELETE') THEN
         l_lookup_code:= 'DLVY_DELETE';

      ELSIF (p_action_code = 'UPDATE') THEN
         l_lookup_code:= 'DLVY_UPDATE';

      ELSIF (p_action_code = 'CANCEL') THEN
         l_lookup_code:= 'DLVY_CANCEL';
      END IF;

   ELSIF (p_entity ='STOP') THEN

      l_lookup_type :='STOP_PRIVILEGE';

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Inside STOP l_lookup_type',l_lookup_type);
      END IF;

      IF (p_action_code = 'UPDATE-STATUS') THEN
         l_lookup_code:= 'STOP_UPDATE_STATUS';

      ELSIF (p_action_code = 'PLAN') THEN
         l_lookup_code:= 'STOP_PLAN';

      ELSIF (p_action_code = 'UNPLAN') THEN
         l_lookup_code:= 'STOP_UNPLAN';

      ELSIF (p_action_code = 'PICK-RELEASE') THEN
         l_lookup_code:= 'STOP_LAUNCH_PR';

      ELSIF (p_action_code = 'PRINT-DOC-SETS') THEN
         l_lookup_code:= 'STOP_PRINT_DS';

      ELSIF (p_action_code = 'WT-VOL') THEN
         l_lookup_code:= 'STOP_CALC_WV';

      ELSIF (p_action_code = 'PICK-RELEASE-UI') THEN
         l_lookup_code:= 'STOP_PR_FORM';

      ELSIF (p_action_code = 'RESOLVE-EXCEPTIONS-UI') THEN
         l_lookup_code:= 'STOP_RESOLVE_EXC';

      ELSIF (p_action_code = 'FREIGHT-COSTS-UI') THEN
         l_lookup_code:= 'STOP_FREIGHT_COSTS';

      ELSIF (p_action_code = 'STOP_LOG_EXCEP') THEN
         l_lookup_code:= 'STOP-LOG-EXCEP';

      ELSIF (p_action_code = 'CREATE') THEN
         l_lookup_code:= 'STOP_CREATE';

      ELSIF (p_action_code = 'DELETE') THEN
         l_lookup_code:= 'STOP_DELETE';

      ELSIF (p_action_code = 'UPDATE') THEN
         l_lookup_code:= 'STOP_UPDATE';

      ELSIF (p_action_code = 'CANCEL') THEN
         l_lookup_code:= 'STOP_CANCEL';
      END IF;

   ELSIF (p_entity ='TRIP') THEN

      l_lookup_type :='TRIP_PRIVILEGE';

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Inside TRIP l_lookup_type',l_lookup_type);
      END IF;

      IF (p_action_code = 'GENERATE-ROUTING-RESPONSE') THEN
         l_lookup_code:= 'TRIP_GENERATE_ROUTING_RESPONSE'; --??

      ELSIF (p_action_code = 'PRINT-DOC-SETS') THEN
         l_lookup_code:= 'TRIP_PRINT_DS';

      ELSIF (p_action_code = 'TRIP-CONFIRM') THEN
         l_lookup_code:= 'TRIP_SHIP_CONFIRM';

      ELSIF (p_action_code = 'FIRM') THEN
         l_lookup_code:= 'TRIP_FIRM';

      ELSIF (p_action_code = 'PLAN') THEN
         l_lookup_code:= 'TRIP_PLAN';

      ELSIF (p_action_code = 'UNPLAN') THEN
         l_lookup_code:= 'UNPLAN';

      ELSIF (p_action_code = 'PICK-RELEASE') THEN
         l_lookup_code:= 'TRIP_LAUNCH_PR';

      ELSIF (p_action_code = 'WT-VOL') THEN
         l_lookup_code:= 'TRIP_CALC_WV';

      ELSIF (p_action_code = 'PICK-RELEASE-UI') THEN
         l_lookup_code:= 'TRIP_PR_FORM';

      ELSIF (p_action_code = 'RESOLVE-EXCEPTIONS-UI') THEN
         l_lookup_code:= 'TRIP_RESOLVE_EXC';

      ELSIF (p_action_code = 'FREIGHT-COSTS-UI') THEN
         l_lookup_code:= 'TRIP_FREIGHT_COSTS';

      ELSIF (p_action_code = 'PRINT-PACK-SLIP') THEN
         l_lookup_code:= 'DLVY_GENERATE_PS';

      ELSIF (p_action_code = 'PRINT-BOL') THEN
         l_lookup_code:= 'DLVY_GENERATE_BOL';

      ELSIF (p_action_code = 'PRINT-MBOL') THEN
         l_lookup_code:= 'TRIP_PRINT_MBOL';

      ELSIF (p_action_code = 'TRIP_LOG_EXCEP') THEN
         l_lookup_code:= 'TRIP-LOG-EXCEP';

      ELSIF (p_action_code = 'FTE_LOAD_TENDER') THEN
         l_lookup_code:= 'TRIP_LOAD_TENDER'; --??

      ELSIF (p_action_code = 'CREATE') THEN
         l_lookup_code:= 'TRIP_CREATE';

      ELSIF (p_action_code = 'DELETE') THEN
         l_lookup_code:= 'TRIP_DELETE';

      ELSIF (p_action_code = 'UPDATE') THEN
         l_lookup_code:= 'TRIP_UPDATE';

      ELSIF (p_action_code = 'CANCEL') THEN
         l_lookup_code:= 'TRIP_CANCEL';
      END IF;

   END IF;


   l_meaning:= Get_Lookup_Meaning(l_lookup_type,l_lookup_code);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_meaning',l_meaning);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

   IF (l_meaning IS NULL) THEN
      return p_action_code;
   ELSE
      return l_meaning;
   END IF;

EXCEPTION
  WHEN others THEN
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   return p_action_code;
END Get_action_Meaning;


--
--Procedure    : Get_idtab_from_string
--Purpose      : Is used to Convert a comma-separated list of Ids of form '1,2,3,4'to
--		 a PL/SQL table numbers;
--
PROCEDURE get_idtab_from_string(
	p_string	 IN	VARCHAR2,
	x_id_tab	 OUT	NOCOPY  WSH_UTIL_CORE.Id_Tab_Type,
	x_return_status  OUT	NOCOPY  VARCHAR2) IS

	l_new_pos	NUMBER;
	l_old_pos	NUMBER;
	l_id_len	NUMBER;
	l_idx		NUMBER:=0;

	l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
        l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_idtab_from_string';
BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	END IF;
	--

	IF (p_string IS NOT NULL) THEN
	   l_old_pos:= 1;
	   LOOP
		l_idx	  := l_idx +1;
		l_new_pos :=INSTR(p_string,',',l_old_pos,1);
		EXIT WHEN (l_new_pos=0);
		l_id_len  := l_new_pos-l_old_pos;
		x_id_tab(l_idx):=TO_NUMBER(SUBSTR(p_string,l_old_pos,l_id_len));
		l_old_pos := l_new_pos +1;
	    END LOOP;
	    x_id_tab(l_idx):= TO_NUMBER(SUBSTR(p_string,l_old_pos,(LENGTH(p_string)-l_old_pos+1)));
	END IF;

	--
	IF l_debug_on THEN
	      wsh_debug_sv.pop (l_module_name);
	END IF;
	--

EXCEPTION
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_UTIL_CORE.GET_IDTAB_FROM_STRING');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_idtab_from_string;


--
-- Procedure : Get_string_from_idtab
-- Purpose   : Used to convert a PL/SQL table of numbers to comma-separated list of form '1,2,3,4'
--

PROCEDURE get_string_from_idtab(
	p_id_tab	 IN 	WSH_UTIL_CORE.Id_Tab_Type,
	x_string	 OUT 	NOCOPY  VARCHAR2,
	x_return_status  OUT	NOCOPY  VARCHAR2) IS

	l_string	    VARCHAR2(32767);
	l_itr		    NUMBER;
	l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
        l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_string_from_idtab';
BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	END IF;
	--

	l_itr := p_id_tab.FIRST;

	IF (l_itr IS NOT NULL) THEN

	     l_string := p_id_tab(l_itr);

	     LOOP

		  EXIT WHEN l_itr = p_id_tab.LAST;
		  l_itr := p_id_tab.NEXT(l_itr);
		  l_string := l_string||','||p_id_tab(l_itr);

	     END LOOP;

	END IF;
	x_string := l_string;

	--
	IF l_debug_on THEN
	      wsh_debug_sv.pop (l_module_name);
	END IF;
	--

EXCEPTION
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_UTIL_CORE.GET_STRING_FROM_IDTAB');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_string_from_idtab;

-- Bug#3947506: Adding a new procedure Get_Entity_name
--========================================================================
-- PROCEDURE : Get_entity_name
--
-- COMMENT   : This procedure will return the entity name for Trip, Stop,
--             Delivery. For Line, Line_id will be returned.
--========================================================================

PROCEDURE Get_Entity_Name
        (p_in_entity_id         in  NUMBER,
         p_in_entity_name       in  VARCHAR2,
         p_out_entity_id        out NOCOPY VARCHAR2,
         p_out_entity_name      out NOCOPY VARCHAR2,
         p_return_status        out NOCOPY VARCHAR2
        ) IS
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ACTION_MEANING';
--
BEGIN
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

        p_return_status := null;

        IF l_debug_on IS NULL THEN
                l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;

        IF l_debug_on THEN
                WSH_DEBUG_SV.push(l_module_name);
        END IF;

        IF p_in_entity_name = 'TRIP'
        THEN
                 p_out_entity_name := 'Trip';
                 p_out_entity_id   := nvl(wsh_trips_pvt.get_name(p_in_entity_id), p_in_entity_id);
        ELSIF p_in_entity_name = 'STOP'
        THEN
                 p_out_entity_name := 'Stop';
                 p_out_entity_id   := nvl(wsh_trip_stops_pvt.get_name(p_in_entity_id), p_in_entity_id);
        ELSIF p_in_entity_name = 'DELIVERY'
        THEN
                 p_out_entity_name := 'Delivery';
                 p_out_entity_id   := nvl(wsh_new_deliveries_pvt.get_name(p_in_entity_id), p_in_entity_id);
        ELSIF p_in_entity_name = 'LINE'
        THEN
                 p_out_entity_name := 'Line';
                 p_out_entity_id   := p_in_entity_id;
        END IF;

        p_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF l_debug_on THEN
                WSH_DEBUG_SV.push(l_module_name);
        END IF;
EXCEPTION
        WHEN    OTHERS
        THEN
                p_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                --
                IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Error has occured. Oracle error message is '|| SQLERRM);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                END IF;
                --
END Get_Entity_Name;


--Bug 4070732 : The following two prcoedures added for this Bugfix

--========================================================================
-- PROCEDURE : Process_stops_for_load_tender
--
-- COMMENT   : This procedure will call the WSH_TRIPS_ACTIONS.Fte_Load_Tender
--             for the Stop ID's present in the global cache table
--             G_STOP_IDS_STOP_IDS_CACHE and G_STOP_IDS_STOP_IDS_EXT_CACHE.
--             Once processed, this will call the API Reset_stops_for_load_tender
--             to reset the global variables.
--========================================================================

  PROCEDURE Process_stops_for_load_tender (p_reset_flags IN BOOLEAN,x_return_status OUT NOCOPY VARCHAR2)
  IS
 -- added stop id for bug 5923014.
      cursor c_get_stop_info (c_stop_id NUMBER ) IS
      select stop_id,
             departure_gross_weight,
             departure_net_weight,
	     departure_volume,
	     departure_fill_percent
      from   wsh_trip_stops
      where  stop_id = c_stop_id;

      l_debug_on           BOOLEAN;
      l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||'.' || 'PROCESS_STOPS_FOR_LOAD_TENDER';

      l_stop_id            NUMBER;
      l_gross_weight       NUMBER;
      l_net_weight         NUMBER;
      l_volume             NUMBER;
      l_fill_percent       NUMBER;

      j                    NUMBER;
      l_ind                NUMBER;
      l_return_status      VARCHAR2(30);
      l_num_warnings       NUMBER;
      l_num_errors         NUMBER;
      l_db_stop_id         NUMBER;


  BEGIN
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       wsh_debug_sv.log(l_module_name,'p_reset_flags',p_reset_flags);
       wsh_debug_sv.log(l_module_name,'count of stops  : ',G_STOP_IDS_STOP_IDS_CACHE.count);
       wsh_debug_sv.log(l_module_name,'count of stops2 : ',G_STOP_IDS_STOP_IDS_EXT_CACHE.count);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     l_num_warnings := 0;
     l_num_errors   := 0;
     --l_stop_ids_tab.delete;

     --unbundling into a contiguous table
     j := 1;
     l_ind := G_STOP_IDS_STOP_IDS_CACHE.FIRST;
     WHILE l_ind IS NOT NULL
     LOOP
       l_db_stop_id:= NULL; -- bug 5923014: reset stop id
       l_stop_id := G_STOP_IDS_STOP_IDS_CACHE(l_ind).value;
       --
       IF l_debug_on THEN
	      WSH_DEBUG_SV.log(l_module_name,'Stop ID for FTE_LOAD_TENDER:',l_stop_id);
       END IF;
       --
       --

       open  c_get_stop_info(l_stop_id);
	   fetch c_get_stop_info into l_db_stop_id,l_gross_weight,l_net_weight,l_volume,l_fill_percent;
       close c_get_stop_info;

       /* bug 5923014: Do actions only when stop exists in the database so that stop id's maintained in cache are not
          validated in Fte_Load_Tender to prevent error message that 'stop has been deleted'. */
       IF (l_db_stop_id is not NULL) THEN
       --{

          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Stop ID',l_stop_id);
              WSH_DEBUG_SV.log(l_module_name,'l_gross_weight',l_gross_weight);
              WSH_DEBUG_SV.log(l_module_name,'l_net_weight',l_net_weight);
              WSH_DEBUG_SV.log(l_module_name,'l_volume',l_volume);
              WSH_DEBUG_SV.log(l_module_name,'l_fill_percent',l_fill_percent);
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.Fte_Load_Tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

	      WSH_TRIPS_ACTIONS.Fte_Load_Tender(
                       p_stop_id       => l_stop_id ,
                       p_gross_weight  => l_gross_weight ,
                       p_net_weight    => l_net_weight ,
                       p_volume        => l_volume ,
                       p_fill_percent  => l_fill_percent ,
                       x_return_status => l_return_status);

	      IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

	       wsh_util_core.api_post_call
            (
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors
            );
       --}
       END IF; -- End of If for bug 5923014;
       --
       --
       l_ind := G_STOP_IDS_STOP_IDS_CACHE.NEXT(l_ind);
     END LOOP;
     --
     --
     l_ind := G_STOP_IDS_STOP_IDS_EXT_CACHE.FIRST;
     WHILE l_ind IS NOT NULL
     LOOP
       l_db_stop_id:= NULL; -- bug 5923014: reset stop id
       l_stop_id := G_STOP_IDS_STOP_IDS_EXT_CACHE(l_ind).value;
       --
       IF l_debug_on THEN
	      WSH_DEBUG_SV.log(l_module_name,'Stop ID for FTE_LOAD_TENDER:',l_stop_id);
       END IF;
       --
       --
       open  c_get_stop_info(l_stop_id);
	   fetch c_get_stop_info into l_db_stop_id,l_gross_weight,l_net_weight,l_volume,l_fill_percent;
	   close c_get_stop_info;

      /* bug 5923014: Do actions only when stop exists in the database so that stop id's maintained in cache are not
          validated in Fte_Load_Tender to prevent error message that 'stop has been deleted'. */
      IF (l_db_stop_id is not NULL) THEN
       --{

         IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Stop ID',l_stop_id);
              WSH_DEBUG_SV.log(l_module_name,'l_gross_weight',l_gross_weight);
              WSH_DEBUG_SV.log(l_module_name,'l_net_weight',l_net_weight);
              WSH_DEBUG_SV.log(l_module_name,'l_volume',l_volume);
              WSH_DEBUG_SV.log(l_module_name,'l_fill_percent',l_fill_percent);
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.Fte_Load_Tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

	      WSH_TRIPS_ACTIONS.Fte_Load_Tender(
                       p_stop_id       => l_stop_id ,
                       p_gross_weight  => l_gross_weight ,
                       p_net_weight    => l_net_weight ,
                       p_volume        => l_volume ,
                       p_fill_percent  => l_fill_percent ,
                       x_return_status => l_return_status);

	      IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

	      wsh_util_core.api_post_call
            (
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors
            );
          --
          --
       --}
       END IF; -- End If for bug 5923014
       l_ind := G_STOP_IDS_STOP_IDS_EXT_CACHE.NEXT(l_ind);
     END LOOP;

     IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;


     --call to reset the global cache tables
     WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags,x_return_status => l_return_status);

     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     wsh_util_core.api_post_call
       (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
       );


     IF l_num_warnings > 0
     THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     ELSE
        x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     END IF;

     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
        --call to reset the global cache tables
        WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags,x_return_status => l_return_status);

        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	END IF;
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
       END IF;


     WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
        --call to reset the global cache tables
        WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags,x_return_status => l_return_status);

        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --

  END Process_stops_for_load_tender;


--========================================================================
-- PROCEDURE : Reset_stops_for_load_tender
--
-- COMMENT   : This procedure will delete the contents of the gloabal cache
--             tables  G_STOP_IDS_STOP_IDS_CACHE and G_STOP_IDS_STOP_IDS_EXT_CACHE
--             and also set the Boolean Global Variable G_CALL_FTE_LOAD_TENDER_API
--             to TRUE.
--========================================================================

  PROCEDURE Reset_stops_for_load_tender (p_reset_flags IN BOOLEAN,x_return_status OUT NOCOPY VARCHAR2)
  IS


      l_debug_on BOOLEAN;
      l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||'.' || 'RESET_STOPS_FOR_LOAD_TENDER';


  BEGIN
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       wsh_debug_sv.log(l_module_name,'p_reset_flags',p_reset_flags);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     --
     G_STOP_IDS_STOP_IDS_CACHE.delete;
     G_STOP_IDS_STOP_IDS_EXT_CACHE.delete;
     --
     IF p_reset_flags THEN
       G_CALL_FTE_LOAD_TENDER_API := TRUE;
       G_START_OF_SESSION_API := null;
     END IF;

     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;


  EXCEPTION


     WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --WSH_UTIL_CORE.Println('Unexpected Error in WSH_UTIL_CORE.Reset_stops_for_load_tender');
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --

  END Reset_stops_for_load_tender;



/*======================================================================
FUNCTION : ValidateActualDepartureDate

COMMENT : This function is called from the following places
          - WSHASCSRS concurrent program
          - WSHPSRS concurrent program
          - WSHPRREL library

          This function checks whether users can enter a future date for
          the Actual Departure Date parameter/field.
          This function returns
          - FALSE : if Global parameter Allow Future Ship Date = 'N'
                and Ship Confirm Rule indicates Set Delivery Intransit
                and Actual Departure Date is > SYSDATE
          - TRUE : under all other conditions

HISTORY : rlanka    03/01/2005    Created
=======================================================================*/
FUNCTION ValidateActualDepartureDate(p_ship_confirm_rule_id IN NUMBER,
                                     p_actual_departure_date IN DATE)
RETURN BOOLEAN IS
  --
  l_global_params   WSH_SHIPPING_PARAMS_GRP.Global_Params_Rec;
  l_return_status   VARCHAR2(1);
  v_ACIntransitFlag VARCHAR2(1);
  --
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ValidateActualDepartureDate';
  --
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.push(l_module_name);
   WSH_DEBUG_SV.log(l_module_name,'Ship Confirm Rule', p_ship_confirm_rule_id);
   WSH_DEBUG_SV.log(l_module_name,'Actual Departure Date',  to_char(p_actual_departure_date,'DD/MM/YYYY HH24:MI:SS'));
  END IF;
  --

  -- Bug 4712256

  IF p_ship_confirm_rule_id IS NULL THEN

    IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name, 'Returning TRUE');
    END IF;

     return TRUE;

  END IF;

  SELECT ac_intransit_flag
  INTO v_ACIntransitFlag
  FROM WSH_SHIP_CONFIRM_RULES
  WHERE ship_confirm_rule_id = p_ship_confirm_rule_id;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name, 'AC Intransit Flag', v_ACIntransitFlag);
  END IF;
  --
  IF v_ACIntransitFlag = 'Y' THEN
   --{
   WSH_SHIPPING_PARAMS_GRP.get_global_parameters(l_global_params,
                                                l_return_status);
   --
   IF l_global_params.allow_future_ship_date = 'N' AND p_actual_departure_date > SYSDATE
   THEN
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name, 'Returning FALSE');
    END IF;
    --
    RETURN FALSE;
    --
   ELSE
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name, 'Returning TRUE');
    END IF;
    --
    RETURN TRUE;
    --
   END IF;
   --}
  ELSE
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name, 'Returning TRUE');
    END IF;
    --
    RETURN TRUE;
    --
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
    --
    WSH_UTIL_CORE.default_handler('ValidateActualDepartureDate');
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name, 'Exception: WHEN OTHERS');
    END IF;
    --
    RETURN FALSE;
    --
END ValidateActualDepartureDate;




/*=====================================================================
FUNCTION : GetShipConfirmRule

COMMENT : This function is called from
          - WSHPSRS concurrent program

          This function is used to obtain the Ship Confirm Rule tied
          to a particular picking rule.  This function is used to
          populate a hidden parameter "Ship Confirm Rule ID" in WSHPSRS
          concurrent program.

HISTORY : rlanka    03/01/2005    Created
=======================================================================*/
FUNCTION GetShipConfirmRule(p_picking_rule_id IN NUMBER) RETURN NUMBER IS
  --
  v_SCRuleID wsh_picking_rules.ship_confirm_rule_id%TYPE;
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GetShipConfirmRule';
  --
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.push(l_module_name);
   WSH_DEBUG_SV.log(l_module_name,'p_picking_rule_id', p_picking_rule_id);
  END IF;
  --
  SELECT ship_confirm_rule_id
  INTO v_SCRuleID
  FROM wsh_picking_rules
  WHERE picking_rule_id = p_picking_rule_id;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name, 'Ship Confirm Rule', v_SCRuleID);
  END IF;
  --
  IF v_SCRuleID is NOT NULL THEN
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN v_SCRuleID;
   --
  ELSE
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN NULL;
   --
  END IF;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
    --
    WSH_UTIL_CORE.default_handler('GetShipConfirmRule');
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name, 'Exception: WHEN OTHERS');
    END IF;
    --
    RETURN NULL;
    --
END GetShipConfirmRule;

FUNCTION WMS_Is_Installed
  RETURN VARCHAR2
IS
  l_wms_application_id constant number := 385;
  l_wms_install_status  VARCHAR2(30);
  l_industry            VARCHAR2(30);
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'WMS_IS_INSTALLED';
  --
BEGIN

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
        IF G_WMS_IS_INSTALLED is NULL THEN
           IF (fnd_installation.get(l_wms_application_id, l_wms_application_id,l_wms_install_status,l_industry)) THEN
               IF (l_wms_install_status = 'I') THEN
                   G_WMS_IS_INSTALLED := 'Y';
               ELSE
                   G_WMS_IS_INSTALLED := 'N';
               END IF;
            ELSE
		   /* this happens only when invalid application id is passed */
               G_WMS_IS_INSTALLED := 'N';
	    END IF;
        END IF;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'G_WMS_IS_INSTALLED',G_WMS_IS_INSTALLED);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return G_WMS_IS_INSTALLED;

  EXCEPTION
    WHEN OTHERS THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
        RETURN 'N';

END WMS_Is_Installed;

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_customer_from_loc      PRIVATE
--
-- PARAMETERS: p_location_id              Input Location id
--             x_customer_id              Carrier at the input location
--             x_return_status            Return status
-- COMMENT   :
-- Returns the customer id of the customer
-- having a location at input wsh location id
--========================================================================

PROCEDURE get_customer_from_loc(
              p_location_id    IN  NUMBER,
              --x_customer_id     OUT NOCOPY  NUMBER,
              x_customer_id_tab     OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
              x_return_status  OUT NOCOPY  VARCHAR2)
IS

    CURSOR c_get_customer(c_location_id IN NUMBER) IS
    SELECT hcas.cust_account_id
    FROM   wsh_locations wl,
           hz_party_sites hps,
           hz_cust_acct_sites_all hcas
    WHERE  wl.wsh_location_id = c_location_id
    AND    wl.location_source_code = 'HZ'
    AND    wl.source_location_id = hps.location_id
    AND    hps.party_site_id = hcas.party_site_id;

    l_customer_id_tab   WSH_UTIL_CORE.id_tab_type;
    itr                    NUMBER := 0;
    i                      NUMBER := 0;
    l_return_status        VARCHAR2(1);
    l_cust_string          VARCHAR2(2000);

    l_debug_on    CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_customer_from_loc';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;

    IF ( p_location_id < g_cache_max_size  and g_customer_from_location.EXISTS(p_location_id)) THEN

	wsh_util_core.get_idtab_from_string(
        	p_string	 => g_customer_from_location(p_location_id),
		x_id_tab	 => l_customer_id_tab,
		x_return_status  => l_return_status);

	IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
  	    raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	itr := l_customer_id_tab.FIRST;

	IF (l_customer_id_tab(itr) <> -1) THEN

	   x_customer_id_tab:=l_customer_id_tab;

	END IF;

	/*IF l_debug_on THEN
	   wsh_debug_sv.push(l_module_name);
	END IF;*/

/*
	x_customer_id := g_customer_from_location(p_location_id);

	IF (x_customer_id = -1) THEN
		x_customer_id := NULL;
	END IF;
*/
    ELSE

	--Does not exist in the cache.
	OPEN c_get_customer(p_location_id);
	FETCH c_get_customer BULK COLLECT INTO l_customer_id_tab;
/*
	IF c_get_customer%NOTFOUND THEN
		 x_customer_id := NULL;
	END IF;
*/
	CLOSE c_get_customer;

	x_customer_id_tab := l_customer_id_tab;

	IF (p_location_id < g_cache_max_size ) THEN

	  itr:=l_customer_id_tab.FIRST;

	  IF (itr) IS NULL THEN
	        l_cust_string := '-1';
	  ELSE

	     wsh_util_core.get_string_from_idtab(
	    	p_id_tab	 => l_customer_id_tab,
		x_string	 => l_cust_string,
		x_return_status  => l_return_status);

	     IF l_debug_on THEN
		 WSH_DEBUG_SV.logmsg(l_module_name,'Org String '||l_cust_string);
	     END IF;

	     IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
  		 raise FND_API.G_EXC_UNEXPECTED_ERROR;
  	     END IF;

	  END IF;

	  g_customer_from_location(p_location_id) := l_cust_string;

	END IF;

/*
	IF (p_location_id < g_cache_max_size ) THEN
	   g_customer_from_location(p_location_id) := nvl(x_customer_id,-1);
	END IF;
*/

    END IF;

    --
    IF l_debug_on THEN
	i := x_customer_id_tab.FIRST;
	IF (i IS NOT NULL) THEN

	    WSH_DEBUG_SV.logmsg(l_module_name,'Number of Customers for the location '||p_location_id||'is :'|| x_customer_id_tab.COUNT);
	    LOOP
	       WSH_DEBUG_SV.logmsg(l_module_name,'Customer_id :'||x_customer_id_tab(i));
               EXIT WHEN i = x_customer_id_tab.LAST;
	       i  := x_customer_id_tab.NEXT(i);
	    END LOOP;

	ELSE
	    WSH_DEBUG_SV.logmsg(l_module_name,'No Organization assocaited with location '||p_location_id);

	END IF;

      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'FND_API.EXCEPTION:G_EXC_UNEXPECTED_ERROR');
        END IF;
    WHEN others THEN
      IF c_get_customer%ISOPEN THEN
         CLOSE c_get_customer;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_UTIL_CORE.get_customer_from_loc');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_customer_from_loc;

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_org_from_location      PRIVATE
--
-- PARAMETERS: p_location_id              Input Location id
--             x_organization_tab         Organizations for the input location
--             x_return_status            Return status
-- COMMENT   :
--	       Returns table of organizations for location.
--========================================================================
PROCEDURE get_org_from_location(
         p_location_id	       IN  NUMBER,
         x_organization_tab    OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
         x_return_status       OUT NOCOPY  VARCHAR2)
IS
/*
	CURSOR c_get_org_from_loc(c_location_id IN NUMBER) IS
	SELECT owner_party_id
	FROM   wsh_location_owners
	WHERE  owner_type = 1
        AND    wsh_location_id = c_location_id
	AND    owner_party_id <> -1 ;
*/
	CURSOR c_get_org_from_loc(c_location_id IN NUMBER) IS
        SELECT organization_id
        FROM   wsh_ship_from_orgs_v
        WHERE  location_id = c_location_id;

	l_organization_tab	WSH_UTIL_CORE.id_tab_type;

	itr			NUMBER;
	i			NUMBER;
	l_return_status		VARCHAR2(1);
	l_org_string		VARCHAR2(32767);

	l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
        l_module_name		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_org_from_location';

BEGIN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
   END IF;

   IF (p_location_id < g_cache_max_size and g_organization_from_location.EXISTS(p_location_id)) THEN

	wsh_util_core.get_idtab_from_string(
        	p_string	 => g_organization_from_location(p_location_id),
		x_id_tab	 => l_organization_tab,
		x_return_status  => l_return_status);

	IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
  	    raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	itr := l_organization_tab.FIRST;

	IF (l_organization_tab(itr) <> -1) THEN

	   x_organization_tab:=l_organization_tab;

	END IF;

	/*IF l_debug_on THEN
	   wsh_debug_sv.push(l_module_name);
	END IF;*/

    ELSE

	--Does not exist in the cache.
	OPEN  c_get_org_from_loc(p_location_id);
	FETCH c_get_org_from_loc BULK COLLECT INTO l_organization_tab;
	CLOSE c_get_org_from_loc;

	x_organization_tab := l_organization_tab;

	IF (p_location_id < g_cache_max_size ) THEN

	  itr:=l_organization_tab.FIRST;

	  IF (itr) IS NULL THEN
	        l_org_string := '-1';
	  ELSE

	     wsh_util_core.get_string_from_idtab(
	    	p_id_tab	 => l_organization_tab,
		x_string	 => l_org_string,
		x_return_status  => l_return_status);

	     IF l_debug_on THEN
		 WSH_DEBUG_SV.logmsg(l_module_name,'Org String '||l_org_string);
	     END IF;

	     IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
  		 raise FND_API.G_EXC_UNEXPECTED_ERROR;
  	     END IF;

	  END IF;

	  g_organization_from_location(p_location_id) := l_org_string;

	END IF;

      END IF;

      -- BUG 4120043 : Replaced FOR loop by iteration using NEXT.
      IF l_debug_on THEN

	i := x_organization_tab.FIRST;
	IF (i IS NOT NULL) THEN

	    WSH_DEBUG_SV.logmsg(l_module_name,'Number of Organizations for the location '||p_location_id||'is :'|| x_organization_tab.COUNT);
	    LOOP
	       WSH_DEBUG_SV.logmsg(l_module_name,'Organization_id :'||x_organization_tab(i));
               EXIT WHEN i = x_organization_tab.LAST;
	       i  := x_organization_tab.NEXT(i);
	    END LOOP;

	ELSE
	    WSH_DEBUG_SV.logmsg(l_module_name,'No Organization assocaited with location '||p_location_id);

	END IF;

	WSH_DEBUG_SV.pop(l_module_name);

      END IF;
      --

EXCEPTION
    WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF c_get_org_from_loc%ISOPEN THEN
         CLOSE c_get_org_from_loc;
      END IF;

      WSH_UTIL_CORE.default_handler('WSH_UTIL_CORE.get_org_from_loc');

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_org_from_location;

--========================================================================
-- PROCEDURE : Get_Delivery_Status    PRIVATE
--
-- PARAMETERS:
--     p_entity_type         either DELIVERY/DELIVERY DETAIL/LPN
--     p_entity_id           either delivery_id/delivery_detail_id/lpn_id
--     x_status_code         Status of delivery for the entity_type and
--                           entity id passed
--     x_return_status       return status
--========================================================================
PROCEDURE Get_Delivery_Status (
          p_entity_type    IN   VARCHAR2,
          p_entity_id      IN   NUMBER,
          x_status_code    OUT NOCOPY VARCHAR2,
          x_return_status  OUT NOCOPY VARCHAR2 )
IS
    --
    -- Entity Type => Delivery
    cursor c_get_delivery_status( c_delivery_id NUMBER) is
    select status_code
    from   wsh_new_deliveries
    where  delivery_id = c_delivery_id;

    -- Entity Type => Delivery Detail
    cursor c_get_detail_status( c_delivery_detail_id NUMBER) is
    select status_code
    from   wsh_new_deliveries       wnd,
           wsh_delivery_assignments_v wda
    where  wnd.delivery_id (+) = wda.delivery_id
    and    wda.delivery_detail_id = c_delivery_detail_id;

    -- Entity Type => LPN
    -- Modified query for bug 4990527 as per WMS requirement
    cursor c_get_lpn_delivery_status( c_lpn_id NUMBER) is
    select distinct wnd.delivery_id, wnd.status_code
    from   wsh_new_deliveries       wnd,
           wsh_delivery_assignments_v wda,
           wsh_delivery_details     wdd
    where  wnd.delivery_id (+) = wda.delivery_id
    and    wda.delivery_detail_id = wdd.delivery_detail_id
    --LPN Reuse project
    and    wdd.released_status = 'X'
    and    wdd.lpn_id in
           ( select wlpn.lpn_id
               from wms_license_plate_numbers wlpn
              where wlpn.outermost_lpn_id = c_lpn_id );
    --

    l_delivery_id  WSH_NEW_DELIVERIES.Delivery_Id%TYPE;
    l_status_code  WSH_NEW_DELIVERIES.Status_Code%TYPE;
    l_error_flag   BOOLEAN := FALSE;

    --
    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DELIVERY_STATUS';
    --
BEGIN
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
        --
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name, 'p_entity_type', p_entity_type);
        WSH_DEBUG_SV.log(l_module_name, 'p_entity_id', p_entity_id);
        --
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --

    IF ( p_entity_type = 'DELIVERY' ) THEN
        --
        open c_get_delivery_status(p_entity_id);
        fetch c_get_delivery_status into l_status_code;

        IF ( c_get_delivery_status%NOTFOUND ) THEN
            --
            l_error_flag := TRUE;
            --
        END IF;

        close c_get_delivery_status;
        --
    ELSIF ( p_entity_type = 'DELIVERY DETAIL' ) then
        --
        open c_get_detail_status(p_entity_id);
        fetch c_get_detail_status into l_status_code;

        IF ( c_get_detail_status%NOTFOUND ) then
            --
            l_error_flag := TRUE;
            --
        END IF;
        close c_get_detail_status;
        --
    ELSIF ( p_entity_type = 'LPN' ) then
        --
        open c_get_lpn_delivery_status(p_entity_id);
        fetch c_get_lpn_delivery_status into l_delivery_id, l_status_code;

        IF ( c_get_lpn_delivery_status%NOTFOUND ) then
            --
            l_error_flag := TRUE;
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Error: Delivery line not found for LPN_ID', p_entity_id);
            END IF;
            --
        END IF;

        IF ( NOT l_error_flag ) THEN
            fetch c_get_lpn_delivery_status into l_delivery_id, l_status_code;
            IF ( c_get_lpn_delivery_status%FOUND ) THEN
                --
                l_error_flag := TRUE;
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'Error: There exists more than one delivery for LPN_ID', p_entity_id);
                END IF;
                --
             END IF;
        END IF;

        close c_get_lpn_delivery_status;
        --
    ELSE
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Invalid Entity Type Passed');
        END IF;
        --
        FND_MESSAGE.SET_NAME ( 'WSH', 'WSH_INVALID_ENTITY_TYPE' );
        FND_MESSAGE.SET_TOKEN ('ENT_TYPE', p_entity_type );
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.add_message(x_return_status);
        --
    END IF;

    --
    x_status_code := l_status_code;
    --

    IF ( l_error_flag ) THEN
        --
        FND_MESSAGE.SET_NAME ( 'WSH', 'WSH_DET_INVALID_DEL' );
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.add_message(x_return_status);
        --
    END IF;

    --
    IF l_debug_on THEN
        --
        WSH_DEBUG_SV.pop(l_module_name);
        --
    END IF;
    --

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.Get_Delivery_Status');
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:OTHERS');
        END IF;
        --
        IF ( c_get_delivery_status%ISOPEN ) THEN
            close c_get_delivery_status;
        END IF;
        --
        IF ( c_get_detail_status%ISOPEN ) THEN
            close c_get_detail_status;
        END IF;
        --
        IF ( c_get_lpn_delivery_status%ISOPEN ) THEN
            close c_get_lpn_delivery_status;
        END IF;
        --
END Get_Delivery_Status;

-- OTM R12

--***************************************************************************--
--
-- Name         Get_Otm_Install_Profile_Value
-- Purpose      This function returns the value of
--                            profile WSH_OTM_INSTALLED
--              It returns 'P' if OTM is integrated for Inbound Purchasing
--                         'O' if OTM is integrated for Outbound Sales Order
--                         'Y' if OTM is integrated for both of the above
--                         'N' if OTM is integrated for non of the above
--                             or if the profile value is NULL
--
-- Input Arguments
--              No input argument
--
--***************************************************************************--

FUNCTION Get_Otm_Install_Profile_Value RETURN VARCHAR2 IS

  l_debug_on      BOOLEAN;
  l_module_name   CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Otm_Install_Profile_Value';
  --
BEGIN
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

  IF G_OTM_PROFILE_VALUE IS NULL THEN
    -- profile value can be 'Y','N','O','P' or NULL
    G_OTM_PROFILE_VALUE := NVL(fnd_profile.value('WSH_OTM_INSTALLED'), 'N');
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'G_OTM_PROFILE_VALUE',G_OTM_PROFILE_VALUE);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  return G_OTM_PROFILE_VALUE;
END Get_Otm_Install_Profile_Value;

--***************************************************************************--
--
-- Name         GC3_Is_Installed
-- Purpose      This function returns whether OTM is integrated for
--                            Outbound Sales Order flow by looking at the
--                            value of profile WSH_OTM_INSTALLED
--              It returns 'Y' if OTM is integrated for Outbound Sales Order
--                         'N' otherwise
--
-- Input Arguments
--              No input argument
--
--***************************************************************************--

FUNCTION GC3_Is_Installed RETURN VARCHAR2 IS

  l_debug_on      BOOLEAN;
  l_module_name   CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GC3_IS_INSTALLED';
  --
BEGIN
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --

  IF G_GC3_IS_INSTALLED IS NULL THEN
    -- G_OTM_PROFILE_VALUE might be set in Get_Otm_Install_Profile_Value
    IF G_OTM_PROFILE_VALUE IS NULL THEN
      G_OTM_PROFILE_VALUE := NVL(fnd_profile.value('WSH_OTM_INSTALLED'), 'N');
    END IF;

    IF G_OTM_PROFILE_VALUE in ('Y','O') THEN
      G_GC3_IS_INSTALLED := 'Y';
    ELSE -- G_OTM_PROFILE_VALUE can be 'P' or 'N'
      G_GC3_IS_INSTALLED := 'N';
    END IF;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'G_GC3_IS_INSTALLED',G_GC3_IS_INSTALLED);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return G_GC3_IS_INSTALLED;
END GC3_Is_Installed;

--=======================================================================

--***************************************************************************--
--
  --========================================================================
  -- PROCEDURE : GET_CURRENCY_CONVERSION_TYPE
  --
  --             API added for R12 Glog Integration Currency Conversion ECO
  --
  -- PURPOSE :   To get the value for profile option WSH_OTM_CURR_CONV_TYPE
  --             (WSH: Currency Conversion Type for OTM)
  --             It returns the cached value if it is avaiable, otherwise
  --             fnd_profile.value api is called to get the profile value
  -- PARAMETERS:
  --     x_curr_conv_type      currency conversion type
  --     x_return_status       return status
  --========================================================================

  PROCEDURE Get_Currency_Conversion_Type (
            x_curr_conv_type OUT NOCOPY VARCHAR2,
            x_return_status  OUT NOCOPY VARCHAR2 ) IS

    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Currency_Conversion_Type';
    l_debug_on    BOOLEAN;

    CURR_CONV_TYPE_UNDEFINED_EXP  EXCEPTION;

  BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
    END IF;

    x_curr_conv_type := NULL;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    -- no cached value, call fnd_profile.value
    IF G_CURRENCY_CONVERSION_TYPE IS NULL then
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'calling fnd_profile.value');
      END IF;
      G_CURRENCY_CONVERSION_TYPE := fnd_profile.value
                                        (name => 'WSH_OTM_CURR_CONV_TYPE');
      -- no value is defined for the profile option
      IF G_CURRENCY_CONVERSION_TYPE IS NULL then
        Raise CURR_CONV_TYPE_UNDEFINED_EXP;
      END IF;
    END IF;
    x_curr_conv_type := G_CURRENCY_CONVERSION_TYPE;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.log(l_module_name, 'currency_conversion_type', x_curr_conv_type);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  EXCEPTION
    when CURR_CONV_TYPE_UNDEFINED_EXP then
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      fnd_message.set_name('WSH', 'WSH_CURR_CONV_TYPE_UNDEFINED');
      wsh_util_core.add_message(x_return_status);
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name, 'WSH: Currency Conversion Type for OTM profile value is not defined.');
        WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION');
      END IF;

    when OTHERS then
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_UTIL_CORE.get_currency_conversion_type', l_module_name);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name, 'Unexpected error has occured. Oracle error message is '||     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:OTHERS');
      END IF;
  END Get_Currency_Conversion_Type;

/* OTM - R12 - o/b BPEL */

--========================================================================
-- PROCEDURE : GET_TRIP_ORGANIZATION_ID
--
-- COMMENT   : Return back organization id that is associated with the trip..
-- MODIFIED :
-- DESC:       This procedure returns back organiation id that is associated with the trip.
--              Steps
--              For Outbound and Mixed trip's see if there is a organization at the location of first stop
--              For inbound see if there is a organization at the location of the last stop.
--              If there are no organizations associated then get the organization id of the delivery with
--              least delivery id
--========================================================================

FUNCTION GET_TRIP_ORGANIZATION_ID (p_trip_id    NUMBER)
RETURN NUMBER
IS

--{

l_api_name              CONSTANT VARCHAR2(30)   := 'GET_TRIP_ORGANIZATION_ID';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_first_stop_loc_id     NUMBER;
l_last_stop_loc_id      NUMBER;
l_first_stop_id         NUMBER;
l_last_stop_id          NUMBER;
l_arrival_date          DATE;
l_dept_date             DATE;

l_typeflag              VARCHAR2(1);
l_organization_id       NUMBER;

l_return_status         VARCHAR2(1);

l_msg_count     NUMBER;
l_msg_data      VARCHAR2(30000);
l_number_of_warnings    NUMBER;
l_number_of_errors      NUMBER;

BEGIN


        IF l_debug_on THEN
              WSH_DEBUG_SV.push(l_module_name);
        END IF;

        l_return_status         := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        l_number_of_warnings    := 0;
        l_number_of_errors      := 0;


        l_organization_id := null;


        -- First get the type of trip. Depending on this we can get the
        -- location, Org Id and the there by carrier site.

        IF l_debug_on
        THEN
              WSH_DEBUG_SV.logmsg(l_module_name,' Getting trip stop information ',
                                WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        GET_FIRST_LAST_STOP_INFO(x_return_status          => l_return_status,
                            x_arrival_date           => l_arrival_date,
                            x_departure_date         => l_dept_date,
                            x_first_stop_id          => l_first_stop_id,
                            x_last_stop_id           => l_last_stop_id,
                            x_first_stop_loc_id      => l_first_stop_loc_id,
                            x_last_stop_loc_id       => l_last_stop_loc_id,
                            p_trip_id                => p_trip_id);

        wsh_util_core.api_post_call(
              p_return_status    =>l_return_status,
              x_num_warnings     =>l_number_of_warnings,
              x_num_errors       =>l_number_of_errors,
              p_msg_data         =>l_msg_data);

        IF ( (l_return_status = 'E')
        OR   (l_return_status = 'U') )
        THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        SELECT shipments_type_flag  INTO l_typeflag
        FROM WSH_TRIPS
        WHERE TRIP_ID = p_trip_id;

	-- Bug 6633529: Handling OTHERS EXCEPTION
	BEGIN
        IF (l_typeflag = 'O' OR l_typeflag = 'M')
        THEN
                -- outbound or mixed use first stop location id
                SELECT mp. organization_id
                INTO l_organization_id
                FROM   hr_organization_units hou,mtl_parameters mp
                WHERE  hou.organization_id = mp.organization_id
                AND  hou.location_id  = l_first_stop_loc_id
                AND  trunc(sysdate) <= nvl( hou.date_to, trunc(sysdate));
        ELSE
                 -- inbound so use last stop
                SELECT mp. organization_id
                INTO l_organization_id
                FROM   hr_organization_units hou,mtl_parameters mp
                WHERE  hou.organization_id = mp.organization_id
                AND  hou.location_id  = l_last_stop_loc_id
                AND  trunc(sysdate) <= nvl( hou.date_to, trunc(sysdate));
        END IF;
        EXCEPTION
	         WHEN OTHERS THEN
	           IF l_debug_on THEN
	             WSH_DEBUG_SV.logmsg(l_module_name,'In WHEN OTHERS',WSH_DEBUG_SV.C_PROC_LEVEL);
	             WSH_DEBUG_SV.logmsg(l_module_name,'Getting organization from the corresponding delivery',WSH_DEBUG_SV.C_PROC_LEVEL);
	           END IF;
	        -- Bug 6633529: Adding Rownum = 1 for Trips having more than 1 delivery for the same organization
	               SELECT 	dlvy.ORGANIZATION_ID
	               INTO 	l_organization_id
	               FROM 	WSH_TRIP_STOPS 		stops,
	               		WSH_DELIVERY_LEGS 	leg,
	                       	WSH_NEW_DELIVERIES 	dlvy
	               WHERE 	stops.stop_id 		= leg.pick_up_stop_id
	               AND 	leg.delivery_id 	= dlvy.delivery_id
	               AND 	stops.stop_id 		= l_first_stop_id
		       AND ROWNUM = 1;
	END;
        -- Bug 6633529: End of fix

        --
        --

        -- if organiaztion id is null then we should get org id from the
        -- delivery that is getting picked up at the first stop

        IF (l_organization_id IS NULL
            AND l_first_stop_id IS NOT NULL)
        THEN
                -- Bug 6633529: Adding Rownum = 1 for Trips having more than 1 delivery for the same organization
                SELECT dlvy.ORGANIZATION_ID
                INTO l_organization_id
                FROM WSH_TRIP_STOPS stops, WSH_DELIVERY_LEGS leg,
                        WSH_NEW_DELIVERIES dlvy
                WHERE stops.stop_id = leg.pick_up_stop_id
                AND leg.delivery_id = dlvy.delivery_id
                AND stops.stop_id = l_first_stop_id
                AND ROWNUM = 1;
        END IF;


        IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
        END IF;

        return l_organization_id;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return null;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return null;

WHEN OTHERS THEN
        IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return null;

END GET_TRIP_ORGANIZATION_ID;

--{
--========================================================================
-- PROCEDURE : GET_FIRST_LAST_STOP_INFO
--
-- COMMENT   : Return back first stop and last stop information..
-- MODIFIED :  OTM specific API use to get the pickup and drop off by Seq. No.

--========================================================================

PROCEDURE GET_FIRST_LAST_STOP_INFO(x_return_status          OUT NOCOPY  VARCHAR2,
                            x_arrival_date           OUT NOCOPY         DATE,
                            x_departure_date         OUT NOCOPY         DATE,
                            x_first_stop_id          OUT NOCOPY         NUMBER,
                            x_last_stop_id           OUT NOCOPY         NUMBER,
                            x_first_stop_loc_id      OUT NOCOPY         NUMBER,
                            x_last_stop_loc_id       OUT NOCOPY         NUMBER,
                            p_trip_id                NUMBER)
IS
--{
/* Replaced this query to get pickup and drop off
CURSOR GET_TRIP_STOPS IS
SELECT stop_location_id, planned_arrival_date, planned_departure_date ,
        stops.stop_id
FROM wsh_trip_stops stops, wsh_trips trips
WHERE trips.trip_id = p_trip_id
        and trips.trip_id = stops.trip_id
ORDER BY PLANNED_ARRIVAL_DATE,
         STOP_SEQUENCE_NUMBER;
*/
--}
  CURSOR GET_TRIP_STOPS_PICKUP
  IS
  SELECT stop_location_id, planned_arrival_date, planned_departure_date,
  stops.stop_id,stops.tms_interface_flag
  FROM wsh_trip_stops stops,
       wsh_trips trips,
       wsh_delivery_legs wdg
  WHERE trips.trip_id = p_trip_id
  and trips.trip_id = stops.trip_id
  and wdg.pick_up_stop_id = stops.stop_id
  ORDER BY STOP_SEQUENCE_NUMBER;


  CURSOR GET_TRIP_STOPS_DROP
  IS
  SELECT stop_location_id, planned_arrival_date, planned_departure_date,
  stops.stop_id,stops.tms_interface_flag
  FROM wsh_trip_stops stops,
       wsh_trips trips,
       wsh_delivery_legs wdg
  WHERE trips.trip_id = p_trip_id
  and trips.trip_id = stops.trip_id
  and wdg.drop_off_stop_id = stops.stop_id
  ORDER BY STOP_SEQUENCE_NUMBER DESC;

--{

l_api_name              CONSTANT VARCHAR2(30)   := 'GET_FIRST_LAST_STOP_INFO';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || l_api_name;

--l_stop_loc_id_tbl       FTE_ID_TAB_TYPE;     -- removed since is not used
--l_stop_id_tbl           FTE_ID_TAB_TYPE;     -- removed since is not used

l_typeflag              VARCHAR2(1);
l_first_stop            NUMBER;
l_idx                   NUMBER;

BEGIN

        IF l_debug_on THEN
              WSH_DEBUG_SV.push(l_module_name);
        END IF;

        x_return_status         := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF l_debug_on
        THEN
              WSH_DEBUG_SV.logmsg(l_module_name,' Getting trip stop information ',
                                WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        l_idx := 0;

        /*
        FOR GET_TRIP_STOPS_REC IN GET_TRIP_STOPS
        LOOP
                IF (l_idx = 0)
                THEN
                        -- This is first stop
                        x_first_stop_id := GET_TRIP_STOPS_REC.STOP_ID;
                        x_first_stop_loc_id := GET_TRIP_STOPS_REC.STOP_LOCATION_ID;
                        x_departure_date := GET_TRIP_STOPS_REC.PLANNED_DEPARTURE_DATE;
                ELSE
                        -- Need to find out if there is a way to go to last stop directly
                        x_last_stop_id := GET_TRIP_STOPS_REC.STOP_ID;
                        x_last_stop_loc_id := GET_TRIP_STOPS_REC.STOP_LOCATION_ID;
                        x_arrival_date := GET_TRIP_STOPS_REC.PLANNED_ARRIVAL_DATE;
                END IF;
                l_idx := l_idx+1;

        END LOOP;
        */
        -- Get 1st pickup Stop
        FOR GET_TRIP_STOPS_REC1 IN GET_TRIP_STOPS_PICKUP
        LOOP
            -- This is first stop
            x_first_stop_id := GET_TRIP_STOPS_REC1.STOP_ID;
            x_first_stop_loc_id := GET_TRIP_STOPS_REC1.STOP_LOCATION_ID;
            x_departure_date := GET_TRIP_STOPS_REC1.PLANNED_DEPARTURE_DATE;
            EXIT;
        END LOOP;
        -- Get Drop off Stop
        FOR GET_TRIP_STOPS_REC2 IN GET_TRIP_STOPS_DROP
        LOOP
            x_last_stop_id := GET_TRIP_STOPS_REC2.STOP_ID;
            x_last_stop_loc_id := GET_TRIP_STOPS_REC2.STOP_LOCATION_ID;
            x_arrival_date := GET_TRIP_STOPS_REC2.PLANNED_ARRIVAL_DATE;
            EXIT;
        END LOOP;
        --
        IF l_debug_on
        THEN
              WSH_DEBUG_SV.logmsg(l_module_name,' First stop STOP_ID ' || x_first_stop_id,
                                WSH_DEBUG_SV.C_PROC_LEVEL);
              WSH_DEBUG_SV.logmsg(l_module_name,' First stop Stop Loc Id ' || x_first_stop_loc_id,
                                WSH_DEBUG_SV.C_PROC_LEVEL);
              WSH_DEBUG_SV.logmsg(l_module_name,' First stop departure date ' || x_departure_date,
                                WSH_DEBUG_SV.C_PROC_LEVEL);
              WSH_DEBUG_SV.logmsg(l_module_name,' Last stop STOP_ID ' || x_last_stop_id,
                                WSH_DEBUG_SV.C_PROC_LEVEL);
              WSH_DEBUG_SV.logmsg(l_module_name,' Last stop Stop loc id ' || x_last_stop_loc_id,
                                WSH_DEBUG_SV.C_PROC_LEVEL);
              WSH_DEBUG_SV.logmsg(l_module_name,' Last stop arrival date ' || x_arrival_date,
                                WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;



        IF GET_TRIP_STOPS_PICKUP%ISOPEN THEN
          CLOSE GET_TRIP_STOPS_PICKUP;
        END IF;


        IF GET_TRIP_STOPS_DROP%ISOPEN THEN
          CLOSE GET_TRIP_STOPS_DROP;
        END IF;

        IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
        END IF;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
        END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
        END IF;
WHEN OTHERS THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;

        IF GET_TRIP_STOPS_PICKUP%ISOPEN THEN
          CLOSE GET_TRIP_STOPS_PICKUP;
        END IF;


        IF GET_TRIP_STOPS_DROP%ISOPEN THEN
          CLOSE GET_TRIP_STOPS_DROP;
        END IF;

        IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
        END IF;

END GET_FIRST_LAST_STOP_INFO;

/* End of OTM R12 - O/B BPEL */

-- Standalone Project - Start
--
--=============================================================================
-- PUBLIC FUNCTION :
--       Get_Operating_Unit
--
-- PARAMETERS:
--       p_organization_id => Organization Id
--
-- COMMENT:
--       Function to return Operating Unit corresponding to organization passed.
-- HISTORY :
--       ueshanka    10/Feb/2009    Created
--=============================================================================
--
FUNCTION Get_Operating_Unit( p_organization_id NUMBER)
RETURN NUMBER
IS
   l_org_id   NUMBER := -1;
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Operating_Unit';
   --
BEGIN
   --Debug Push
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_organization_id', p_organization_id );
   END IF;
   --

   BEGIN
      select operating_unit
      into   l_org_id
      from   org_organization_definitions
      where  organization_id = p_organization_id;

      l_org_id := nvl(l_org_id, -1);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Inside No_Data_Found');
      END IF;
      --
      l_org_id := -1;
   WHEN OTHERS THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Inside Others Exception', sqlerrm);
      END IF;
      --
      l_org_id := -1;
   END;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Operating Unit(org_id)', l_org_id);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN l_org_id;
EXCEPTION
WHEN OTHERS THEN
      WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Get_Operating_Unit');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      RETURN -1;
END Get_Operating_Unit;
-- Standalone Project - End

--Added for bug 9011125
--========================================================================
-- PROCEDURE : SET_FND_PROFILE
--
-- COMMENT   : This will set the FND_PROFILE for the DB cache.
-- PARAMATERS: p_name   - Name of the profile to be set.
--             p_value  - Value for the profile to be set.
-- MODIFIED  :
-- DESC      : This will set the FND_PROFILE for the DB cache.This API will only be called from
--             Oracle Forms.From plsql we can call the FND API FND_PROFILE.PUT directly to set
--             the same profile.
--========================================================================

PROCEDURE SET_FND_PROFILE(
                            p_name IN VARCHAR2,
                            p_value IN VARCHAR2)
IS
--
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SET_FND_PROFILE';
--
BEGIN
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
           WSH_DEBUG_SV.log(l_module_name,'P_NAME',p_name);
           WSH_DEBUG_SV.log(l_module_name,'P_VALUE',p_value);
        END IF;
        --
        FND_PROFILE.PUT(NAME=>p_name,
                        VAL =>p_value);
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
EXCEPTION
        WHEN others THEN
           --
           IF l_debug_on THEN
              --
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                 SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
              --
           END IF;
           --
           RAISE;
END SET_FND_PROFILE;

END WSH_UTIL_CORE;

/
