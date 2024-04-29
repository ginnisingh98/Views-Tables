--------------------------------------------------------
--  DDL for Package Body WSH_UTIL_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_UTIL_VALIDATE" as
/* $Header: WSHUTVLB.pls 120.12.12010000.4 2010/04/22 12:15:19 selsubra ship $ */
--===================
-- PROCEDURES
--===================

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_UTIL_VALIDATE';
  G_ITEM_INFO_TAB                     Item_Info_Tab_Type;
  G_DEF_CONT_INF_TAB                  cont_def_info_tab_type;
  G_DEF_CONT_INFO_EXT_TAB             cont_def_info_tab_type;
  G_IGNORE_PLAN_TAB                   ignore_plan_tab_type;

  -- LPN CONV. rv
  g_orgn_id_tbl                       WSH_UTIL_CORE.char500_tab_type;
  g_orgn_id_ext_tbl                   WSH_UTIL_CORE.char500_tab_type;
  g_organization_id                   NUMBER;
  g_is_wms_org                        VARCHAR2(1);

  -- LPN CONV. rv


  -- Bug 3821688
  -- The parameters can be populated as required, to make it generic
  -- Output Variables store the results
  -- Valid_Flag indicates the combination is valid or not with values = Y/N
  TYPE Generic_Cache_Rec_Typ IS RECORD(
    INPUT_PARAM1           VARCHAR2(500),
    INPUT_PARAM2           VARCHAR2(500),
    INPUT_PARAM3           VARCHAR2(500),
    INPUT_PARAM4           VARCHAR2(500),
    OUTPUT_PARAM1           VARCHAR2(500),
    OUTPUT_PARAM2           VARCHAR2(500),
    OUTPUT_PARAM3           VARCHAR2(500),
    OUTPUT_PARAM4           VARCHAR2(500),
    VALID_FLAG             VARCHAR2(1)
    );

  TYPE Generic_Cache_Tab_Typ IS TABLE OF Generic_Cache_Rec_Typ INDEX BY BINARY_INTEGER;

  -- Parameters will be Ship Method Code and Ship Method Name
  g_ship_method_tab Generic_Cache_Tab_Typ;

  -- Parameters will be Lookup Type,Lookup Code, Meaning
  g_lookup_tab Generic_Cache_Tab_Typ;

  -- Parameters will be organization_id,weight_uom class,volume_uom class
  g_org_uom_class_tab Generic_Cache_Tab_Typ;

  -- Parameters will be UOM Code, UOM description,type,class
  g_uom_tab Generic_Cache_Tab_Typ;

  --Standalone Project -- Start
  --Input Parameter   : Organization Id
  --Output Parameters : WMS Enabled Flag, OPM Enabled Flag
  g_sr_org_tab   Generic_Cache_Tab_Typ;

  --Input Parameter   : Locator Code, Organization Id
  --Output Parameters : Locator Id
  g_locator_code_tab   Generic_Cache_Tab_Typ;

  --Input Parameter   : Item Number, Organization Id
  --Output Parameters : Inventory Item Id
  g_inventory_item_tab   Generic_Cache_Tab_Typ;

  --Input Parameter   : Item Number, Customer Id, Address Id
  --Output Parameters : Customer Item Id
  g_customer_item_tab    Generic_Cache_Tab_Typ;

  --Input Parameter   : Carrier Code, Service Level, Mode of Transport, Organization Id
  --Output Parameters : Ship Method Code
  g_shipping_method_tab  Generic_Cache_Tab_Typ;
  --Standalone Project -- End

  -- Forward Declaration of an Internal procedure
  -- OTM R12, glog project
  PROCEDURE Validate_Lookup_Upper
        (p_lookup_type               IN             VARCHAR2,
         p_lookup_code               IN OUT NOCOPY  VARCHAR2,
         p_meaning                   IN             VARCHAR2,
         x_return_status                OUT NOCOPY  VARCHAR2);
  -- End of Forward Declaration




-- Bug 3821688
--========================================================================
-- PROCEDURE : get_table_index
--
-- COMMENT   : Validate using Hash (internal API)
--             uses Hash and avoids linear scans while using PL/SQL tables
--             Currently available for 4 parameters (VARCHAR2 datatype)
-- PARAMETERS:
-- p_validate_rec   -- Input Key to be validated
-- x_generic_tab  -- populated for existing cached records
-- x_index       -- New index which can be used for x_flag = U
-- x_return_status     -- S,E,U,W
-- x_flag    -- U to use this index,D to indicate valid record
--
-- HISTORY   : Bug 3821688
-- NOTE      : For performance reasons, no debug calls are added
--========================================================================
PROCEDURE get_table_index
  (p_validate_rec  IN Generic_Cache_Rec_Typ,
   p_generic_tab   IN Generic_Cache_Tab_Typ,
   x_index         OUT NOCOPY NUMBER,
   x_return_status OUT NOCOPY VARCHAR2,
   x_flag          OUT NOCOPY VARCHAR2
  )IS

  c_hash_base CONSTANT NUMBER := 1;
  c_hash_size CONSTANT NUMBER := power(2, 25);

  l_hash_string      VARCHAR2(4000) := NULL;
  l_index            NUMBER;
  l_hash_exists      BOOLEAN := FALSE;

  l_flag             VARCHAR2(1);
  l_generic_tab    Generic_Cache_Tab_Typ;

BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_hash_exists   := FALSE;
  l_generic_tab := p_generic_tab;
    -- need to hash this index
    -- Key (for hash) : param1+param2+param3
    l_hash_string := p_validate_rec.input_param1||p_validate_rec.input_param2||p_validate_rec.input_param3||p_validate_rec.input_param4;

    -- Hash returns a common index if l_hash_string is identical
    l_index := dbms_utility.get_hash_value (
                 name => l_hash_string,
                 base => c_hash_base,
                 hash_size => c_hash_size);
    WHILE NOT l_hash_exists LOOP
      IF l_generic_tab.EXISTS(l_index) THEN
          -- Check for all attributes match
          -- Check for Input Stored(Table) vs Input given(Record)
          -- There can be cases like
          --   Param1    Param2     Key
          --    AB        XY        ABXY
          --    A        BXY        ABXY
          --    Null     ABXY       ABXY
          --    ABXY     Null       ABXY
        IF (
            ((l_generic_tab(l_index).input_param1 = p_validate_rec.input_param1)
              OR
             (l_generic_tab(l_index).input_param1 IS NULL AND
              p_validate_rec.input_param1 IS NULL)
            ) AND
            ((l_generic_tab(l_index).input_param2 = p_validate_rec.input_param2)
              OR
             (l_generic_tab(l_index).input_param2 IS NULL AND
              p_validate_rec.input_param2 IS NULL)
            ) AND
            ((l_generic_tab(l_index).input_param3 = p_validate_rec.input_param3)
              OR
             (l_generic_tab(l_index).input_param3 IS NULL AND
              p_validate_rec.input_param3 IS NULL)
            ) AND
            ((l_generic_tab(l_index).input_param4 = p_validate_rec.input_param4)
              OR
             (l_generic_tab(l_index).input_param4 IS NULL AND
              p_validate_rec.input_param4 IS NULL)
            )
           ) THEN
            -- exact match found at this index
            l_flag := 'D';
            EXIT;
        ELSE

          -- Index exists but key does not match this table element
          -- Bump l_index till key matches or table element does not exist
          l_index := l_index + 1;
        END IF;
      ELSE
        -- Index is not used in the table, can be used to create a new record
        l_hash_exists := TRUE; -- to exit from the loop
        l_flag := 'U';
      END IF;
    END LOOP;

  x_index := l_index;
  x_flag := l_flag;

END get_table_index;
--
-- End of Bug 3821688

--========================================================================
-- PROCEDURE : Validate_Org
--
-- COMMENT   : Validates Organization_id and Organization_code against view
--             org_organization_definitions. If both values are
--             specified then only Org_Id is used
--
-- HISTORY   : Bug# 1924574, hr_locations changes(8/15/01)
--========================================================================
  PROCEDURE Validate_Org
	(p_org_id          IN OUT NOCOPY  NUMBER,
      p_org_code        IN VARCHAR2,
      x_return_status   OUT NOCOPY  VARCHAR2) IS

  -- BUG 4329611.
  CURSOR check_org_id IS
  SELECT mp.organization_id
  FROM   hr_organization_units hou,
         mtl_parameters mp
  WHERE  hou.organization_id = mp.organization_id
    AND  mp.organization_id = p_org_id
    AND  trunc(sysdate) <= nvl( hou.date_to, trunc(sysdate));

  CURSOR check_org_code IS
  SELECT mp.organization_id
  FROM hr_organization_units hou, mtl_parameters mp
  WHERE hou.organization_id = mp.organization_id
    and mp.organization_code = p_org_code
    AND trunc(sysdate) <= nvl( hou.date_to, trunc(sysdate));

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_ORG';
--
l_failed BOOLEAN;
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
	    WSH_DEBUG_SV.log(l_module_name,'P_ORG_CODE',P_ORG_CODE);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        l_failed := FALSE;

        IF p_org_id <> FND_API.G_MISS_NUM THEN
           OPEN check_org_id;
           FETCH check_org_id INTO p_org_id;
           l_failed := check_org_id%NOTFOUND;
           CLOSE check_org_id;
        ELSIF p_org_code <> FND_API.G_MISS_CHAR THEN
           OPEN check_org_code;
           FETCH check_org_code INTO p_org_id;
           l_failed := check_org_code%NOTFOUND;
           CLOSE check_org_code;
	END IF;
        --
        IF l_failed THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ORG');
          wsh_util_core.add_message(x_return_status,l_module_name);
        END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'p_org_id',p_org_id);
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
  EXCEPTION
     WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         wsh_util_core.default_handler('WSH_UTIL_VALIDATE.VALIDATE_ORG');
         IF check_org_id%ISOPEN THEN
            CLOSE check_org_id;
         END IF;
         IF check_org_code%ISOPEN THEN
            CLOSE check_org_code;
         END IF;
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'ERROR:',SUBSTR(SQLERRM,1,200));
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;

  END Validate_Org;


--========================================================================
-- PROCEDURE : Validate_Location
--
-- COMMENT   : Validates Location_id and Location_code against view
--             hr_locations. If both values are specified then only
--             Location_id is used
--========================================================================
-- vms default p_Location_code as NULL  in the spec.
  PROCEDURE Validate_Location
	(p_location_id      IN OUT NOCOPY  NUMBER,
      p_location_code    IN VARCHAR2 ,
      x_return_status    OUT NOCOPY  VARCHAR2,
      p_isWshLocation    IN  BOOLEAN DEFAULT FALSE,
      p_caller           IN  VARCHAR2 DEFAULT NULL) IS


   l_source_loc_type     VARCHAR2(10);
   l_return_status       VARCHAR2(1);
   l_loc_rec             WSH_MAP_LOCATION_REGION_PKG.loc_rec_type;
   l_sysdate             DATE DEFAULT SYSDATE;
   l_num_errors          NUMBER;
   l_num_warnings        NUMBER;
   l_location_id         NUMBER;
   l_location_id2        NUMBER;

  CURSOR check_location IS
  SELECT hrtl.location_id
  FROM   hr_locations_all_tl  hrtl,
         hr_locations_all     hr
  WHERE  hrtl.location_code = p_location_code
  AND    hrtl.language = USERENV('LANG')
  AND    hrtl.location_id = hr.location_id
  AND    trunc(sysdate) <= nvl( hr.inactive_date, trunc(sysdate) ) ;



--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_LOCATION';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_CODE',P_LOCATION_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'p_isWshLocation',p_isWshLocation);
	    WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        IF p_isWshLocation THEN
           l_source_loc_type := 'WSH';
        ELSE
           l_source_loc_type := 'HR_HZ';
        END IF;

        IF (p_location_id = FND_API.G_MISS_NUM ) THEN
           p_location_id := NULL;
        END IF;

        IF p_location_id IS NOT NULL THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Calling Transfer_Location');
           END IF;

           WSH_MAP_LOCATION_REGION_PKG.Transfer_Location (
                                p_source_type           => l_source_loc_type,
                                p_source_location_id    => p_location_id,
                                p_transfer_location     => TRUE,
                                p_caller                => p_caller,
                                p_online_region_mapping => FALSE,
                                x_loc_rec               => l_loc_rec,
                                x_return_status         => l_return_status);

           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           END IF;

           wsh_util_core.api_post_call(
                                   p_return_status => l_return_status,
                                   x_num_warnings  => l_num_warnings,
                                   x_num_errors    => l_num_errors);
           IF l_loc_rec.wsh_location_id IS NULL THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF  TRUNC(l_sysdate) <= NVL(l_loc_rec.inactive_date,TRUNC(l_sysdate))
           THEN
              p_location_id := l_loc_rec.wsh_location_id;
           ELSE
              RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'inactive_date',
                                               l_loc_rec.inactive_date);
                 WSH_DEBUG_SV.log(l_module_name,'l_sysdate',l_sysdate);
                 WSH_DEBUG_SV.log(l_module_name,'p_location_id',p_location_id);
                 WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
        ELSIF NVL(p_location_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
         AND p_location_id IS NULL
        THEN
           BEGIN
              SELECT wsh_location_id
              INTO l_location_id
              FROM wsh_locations
              WHERE location_code = p_location_code
              AND    TRUNC(l_sysdate)
                               <= NVL(inactive_date ,TRUNC(l_sysdate));
              IF l_debug_on THEN
	         WSH_DEBUG_SV.log(l_module_name,'l_location_id',l_location_id);
              END IF;
              --
              p_location_id := l_location_id;
              IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'p_location_id',p_location_id);
                    WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              RETURN;

           EXCEPTION
              WHEN TOO_MANY_ROWS THEN
                 RAISE FND_API.G_EXC_ERROR;
              WHEN NO_DATA_FOUND THEN
                 OPEN check_location;
                    FETCH check_location
                    INTO l_location_id;
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'cursor l_location_id',
                                                            l_location_id);
                    END IF;
                    IF check_location%NOTFOUND THEN
                       RAISE FND_API.G_EXC_ERROR;
                    ELSE
                       FETCH check_location
                       INTO l_location_id2;
                       IF l_location_id2 IS NOT NULL THEN
                         IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'Too Many ROws',
                                                              l_location_id2);
                         END IF;
                         RAISE FND_API.G_EXC_ERROR;
                       END IF;
                    END IF;
           END;

           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Calling Transfer_Location');
           END IF;

           WSH_MAP_LOCATION_REGION_PKG.Transfer_Location (
                                p_source_type           => 'HR',
                                p_source_location_id    => l_location_id,
                                p_caller                => p_caller,
                                p_transfer_location     => TRUE,
                                p_online_region_mapping => FALSE,
                                x_loc_rec               => l_loc_rec,
                                x_return_status         => l_return_status);
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           END IF;

           wsh_util_core.api_post_call(
                                   p_return_status => l_return_status,
                                   x_num_warnings  => l_num_warnings,
                                   x_num_errors    => l_num_errors);

           IF l_loc_rec.wsh_location_id IS NULL THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
           p_location_id := l_loc_rec.wsh_location_id;

        ELSE
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Both parameters are null');
           END IF;
           --x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           --bug 2648157
        END IF;

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'p_location_id',p_location_id);
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_LOCATION');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         wsh_util_core.add_message(x_return_status,l_module_name);
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION G_EXC_ERROR');
         END IF;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_LOCATION');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         wsh_util_core.add_message(x_return_status,l_module_name);
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION G_EXC_UNEXPECTED_ERROR');
         END IF;
     WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
         wsh_util_core.default_handler('WSH_UTIL_VALIDATE.VALIDATE_LOCATION');
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'ERROR:',SUBSTR(SQLERRM,1,200));
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;

  END Validate_Location;

--========================================================================
-- PROCEDURE : Validate_Lookup
--
-- COMMENT   : Validates Lookup_code and Meaning against view fnd_lookups.
--             If both values are specified then only Lookup_code is used
--========================================================================

  PROCEDURE Validate_Lookup
	(p_lookup_type                  IN  VARCHAR2,
	 p_lookup_code                  IN OUT NOCOPY  VARCHAR2,
      p_meaning                      IN  VARCHAR2,
	 x_return_status                OUT NOCOPY  VARCHAR2) IS

  -- Bug 3821688 Split Cursor
  CURSOR check_lookup_code IS
  SELECT lookup_code
  FROM   fnd_lookup_values_vl
  WHERE  lookup_code = p_lookup_code AND
	 lookup_type = p_lookup_type AND
	 nvl(start_date_active,sysdate)<=sysdate AND nvl(end_date_active,sysdate)>=sysdate AND
	 enabled_flag = 'Y';

  CURSOR check_lookup_meaning IS
  SELECT lookup_code
  FROM   fnd_lookup_values_vl
  WHERE  meaning = p_meaning AND
	 lookup_type = p_lookup_type AND
	 nvl(start_date_active,sysdate)<=sysdate AND nvl(end_date_active,sysdate)>=sysdate AND
	 enabled_flag = 'Y';

  -- Bug 3821688
  l_index NUMBER;
  l_flag VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_cache_rec Generic_Cache_Rec_Typ;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_LOOKUP';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_LOOKUP_TYPE',P_LOOKUP_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'P_LOOKUP_CODE',P_LOOKUP_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_MEANING',P_MEANING);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (p_lookup_code IS NOT NULL) OR (p_meaning IS NOT NULL) THEN
           -- Bug 3821688
            l_cache_rec.input_param1 := p_lookup_code;
            l_cache_rec.input_param2 := p_meaning;
            l_cache_rec.input_param3 := p_lookup_type;
            -- Always Call get_table_index to check if value exists in cache
            -- If no record exists,then we can insert new record with the output index
            get_table_index
              (p_validate_rec => l_cache_rec,
               p_generic_tab => g_lookup_tab,
               x_index      => l_index,
               x_return_status => l_return_status,
               x_flag        => l_flag
              );
             -- l_flag = U means use this index value to insert record in table
            IF l_flag = 'U' AND l_index IS NOT NULL THEN
              IF p_lookup_code IS NOT NULL THEN
                OPEN  check_lookup_code;
                FETCH check_lookup_code INTO l_cache_rec.output_param1;
                IF (check_lookup_code%NOTFOUND) THEN
                  l_cache_rec.valid_flag := 'N';
                ELSE
                  l_cache_rec.valid_flag := 'Y';
                END IF;
                CLOSE check_lookup_code;
              ELSIF p_meaning IS NOT NULL THEN
                OPEN  check_lookup_meaning;
                FETCH check_lookup_meaning INTO l_cache_rec.output_param1;
                IF (check_lookup_meaning%NOTFOUND) THEN
                  l_cache_rec.valid_flag := 'N';
                ELSE
                  l_cache_rec.valid_flag := 'Y';
                END IF;
                CLOSE check_lookup_meaning;
              END IF;

              g_lookup_tab(l_index) := l_cache_rec;
            END IF;
            -- Always check if input is valid or not
            IF g_lookup_tab(l_index).valid_flag = 'N' THEN
              --OTM R12 bug fix. Added the if condition for service level and
              --mode of transport to display more specific message to user.
              IF p_lookup_type = 'WSH_SERVICE_LEVELS' THEN
	        FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_SERVICE_LEVEL');
              ELSIF p_lookup_type = 'WSH_MODE_OF_TRANSPORT' THEN
	        FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_MODE_OF_TRANSPORT');
              ELSE
	        FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_LOOKUP');
              END IF;
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status,l_module_name);
            END IF;
            -- Always Populate return variables
            p_lookup_code  := g_lookup_tab(l_index).output_param1;
            -- End of Bug 3821688

     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_lookup_code',p_lookup_code);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
  END Validate_Lookup;

--========================================================================
-- PROCEDURE : Validate_Customer
--
-- COMMENT   : Validates Customer_id/Customer_number against
--             hz_cust_accounts. If both values are specified then only
--             Customer_Id is used
--========================================================================

  PROCEDURE Validate_Customer
	(p_customer_id     IN OUT NOCOPY  NUMBER,
      p_customer_number IN VARCHAR2,
      x_return_status   OUT NOCOPY  VARCHAR2) IS

  CURSOR check_customer IS		--Removal of TCA View Starts
  SELECT cust_account_id /*customer_id */
  FROM   hz_cust_accounts
  WHERE  cust_account_id = p_customer_id AND
	    status = 'A' AND
	    NVL(p_customer_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
  UNION
  SELECT Cust_account_id/*customer_id */
  FROM   hz_cust_accounts
  WHERE  account_number /* customer number */  = p_customer_number AND
	    status = 'A' AND
	    NVL(p_customer_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM;
						--Removal of TCA View Ends


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_CUSTOMER';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_ID',P_CUSTOMER_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_NUMBER',P_CUSTOMER_NUMBER);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF nvl(p_customer_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
        OR nvl(p_customer_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char
        THEN

	   OPEN  check_customer;
	   FETCH check_customer INTO p_customer_id;

	   IF (check_customer%NOTFOUND) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_CUSTOMER');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status,l_module_name);

	   END IF;

	   CLOSE check_customer;

	END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'p_customer_id',p_customer_id);
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
  END Validate_Customer;


--========================================================================
-- PROCEDURE : Validate_Contact
--
-- COMMENT   : Validates Contact_id against hz_cust_account_roles
--========================================================================

  PROCEDURE Validate_Contact
	(p_contact_id     IN OUT NOCOPY  NUMBER,
      x_return_status   OUT NOCOPY  VARCHAR2) IS

  CURSOR check_contact IS  --TCA View removal Starts
  SELECT Cust_account_role_id /*contact id*/
  FROM   hz_cust_account_roles
  WHERE  cust_account_role_id = p_contact_id AND
	    p_contact_id IS NOT NULL;    --TCA View removal  Ends


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_CONTACT';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_CONTACT_ID',P_CONTACT_ID);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (p_contact_id IS NOT NULL) THEN

	   OPEN  check_contact;
	   FETCH check_contact INTO p_contact_id;

	   IF (check_contact%NOTFOUND) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_CONTACT');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status,l_module_name);

	   END IF;

	   CLOSE check_contact;

	END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'p_contact_id',p_contact_id);
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
  END Validate_Contact;


--========================================================================
--========================================================================
-- PROCEDURE : Validate_Quantity
--
-- COMMENT   : Validates if quantity is non-negative and an integer.
--========================================================================

  PROCEDURE Validate_Quantity
	(p_quantity        IN  NUMBER ,
      x_return_status   OUT NOCOPY  VARCHAR2 ) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_QUANTITY';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY',P_QUANTITY);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (p_quantity IS NOT NULL) THEN

	   IF (p_quantity < 0) OR (p_quantity <> trunc(p_quantity)) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_QUANTITY_NOT_WHOLE');
		 FND_MESSAGE.SET_TOKEN('QTY',p_quantity);
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status,l_module_name);

        END IF;

	END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
  END Validate_Quantity;

--========================================================================
-- PROCEDURE : Validate_Negative
--
-- COMMENT   : Validates if value is non-negative
--========================================================================
/*
-- Overloaded the procedure with extra parameter
  PROCEDURE Validate_Negative
	(p_value         IN     NUMBER,
      x_return_status OUT NOCOPY  VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_NEGATIVE';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_VALUE',P_VALUE);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (p_value IS NOT NULL) THEN

	   IF (p_value < 0) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_VALUE_NEGATIVE');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status,l_module_name);

        END IF;

	END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
  END Validate_Negative;
*/

--overloaded procedure added for Bug # 3266333
--========================================================================
-- PROCEDURE : Validate_Negative
--
-- COMMENT   : Validates if value is non-negative and shows a message
--             along with the attribute/field name which has a negative value.
--========================================================================

PROCEDURE Validate_Negative
	(p_value         IN     NUMBER,
	 p_field_name    IN     VARCHAR2 DEFAULT NULL,
         x_return_status OUT NOCOPY  VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_NEGATIVE';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_VALUE',P_VALUE);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (p_value IS NOT NULL) THEN

	   IF (p_value < 0) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_VALUE_NEGATIVE');
                 FND_MESSAGE.SET_TOKEN('FIELD_NAME',p_field_name);
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status,l_module_name);

           END IF;

	END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
END Validate_Negative;



--========================================================================
-- PROCEDURE : Validate_Currency
--
-- COMMENT   : Validates Currency_code and Currency_Name against
--             table fnd_currencies_vl. If both values are specified then
--             only Currency_code is used. p_amount if specified is
--             checked for correct precision
--             If p_otm_enabled is 'Y', rounds p_amount using FND precision
--             for the input currency
--========================================================================

  PROCEDURE Validate_Currency
	(p_currency_code                IN OUT NOCOPY  VARCHAR2,
	 p_currency_name                IN  VARCHAR2,
         p_amount                       IN  NUMBER,
         p_otm_enabled                  IN  VARCHAR2 DEFAULT NULL, -- OTM R12
	 x_return_status                OUT NOCOPY  VARCHAR2,
         x_adjusted_amount              OUT NOCOPY  NUMBER) IS  -- OTM R12

  CURSOR currency_cursor(c_currency_code IN VARCHAR2, c_currency_name IN VARCHAR2) IS
    SELECT currency_code,
           NVL(precision,0),
           DECODE(INSTR(TO_CHAR(NVL(p_amount,0)),'.'),0,0,
                        LENGTH(TO_CHAR(NVL(p_amount,0)))-
                        INSTR(TO_CHAR(NVL(p_amount,0)),'.'))
    FROM fnd_currencies_vl
    WHERE enabled_flag = 'Y'
    AND name = decode( c_currency_code, null, c_currency_name, name)
    AND currency_code = nvl( c_currency_code, currency_code)
    AND trunc(sysdate) between nvl( start_date_active, trunc(sysdate) )
		        and nvl( end_date_active, trunc(sysdate) );

    l_precision     number;
    l_in_precision  number;
    error_code      VARCHAR2(50);

    l_invalid_currency  EXCEPTION; -- OTM R12

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_CURRENCY';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CODE',P_CURRENCY_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_NAME',P_CURRENCY_NAME);
	    WSH_DEBUG_SV.log(l_module_name,'P_AMOUNT',P_AMOUNT);
	    WSH_DEBUG_SV.log(l_module_name,'P_OTM_ENABLED',P_OTM_ENABLED); -- OTM R12
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF nvl(p_currency_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char
        OR nvl(p_currency_name, fnd_api.g_miss_char) <> fnd_api.g_miss_char
        THEN
          -- OTM R12
          OPEN  currency_cursor(p_currency_code,p_currency_name);
          -- OTM R12
          FETCH currency_cursor INTO  p_currency_code, l_precision, l_in_precision;

          IF (currency_cursor%NOTFOUND) THEN

             IF p_currency_code IS NOT NULL THEN
               error_code := 'CURR-Invalid code';
               FND_MESSAGE.SET_NAME('FND', error_code);
               FND_MESSAGE.SET_TOKEN('CODE',p_currency_code);
             ELSE
               error_code := 'CURR-Invalid currency value';
               FND_MESSAGE.set_name('FND', error_code);
             END IF;

             -- OTM R12
             CLOSE currency_cursor;
             RAISE l_invalid_currency;

          END IF;

          CLOSE currency_cursor;

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_in_precision',l_in_precision);
            WSH_DEBUG_SV.log(l_module_name,'l_precision',l_precision);
          END IF;

          x_adjusted_amount := p_amount;

          IF l_in_precision > l_precision THEN
            --IF WSH_UTIL_CORE.GC3_IS_INSTALLED = 'Y' THEN
            -- OTM R12
            IF p_otm_enabled = 'Y' THEN
              -- truncate the amount to the precision specified in setup
              x_adjusted_amount := ROUND(p_amount,l_precision);
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Adjusted amount:',x_adjusted_amount);
              END IF;
            ELSE
              -- existing code
              error_code := 'CURR-Precision';
              FND_MESSAGE.SET_NAME('FND', error_code);
              FND_MESSAGE.SET_TOKEN('PRECISON',TO_CHAR(l_precision));
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status,l_module_name);
            END IF;
          END IF;

       -- OTM R12
       ELSE
          RAISE l_invalid_currency;
       END IF;
     --
     IF l_debug_on THEN
         -- OTM R12
         WSH_DEBUG_SV.log(l_module_name,'x_adjusted_amount ',x_adjusted_amount);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
  EXCEPTION
    -- OTM R12
    WHEN l_invalid_currency THEN
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 WSH_UTIL_CORE.add_message(x_return_status,l_module_name);
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Invalid or NULL currency exception ');
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
    WHEN OTHERS THEN
         IF currency_cursor%ISOPEN THEN
            CLOSE currency_cursor;
         END IF;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.default_handler('WSH_UTIL_VALIDATE.Validate_Currency');
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;

  END Validate_Currency;

--========================================================================
-- PROCEDURE : Validate_Uom
--
-- COMMENT   : Validates UOM_Code and UOM Description against table
--             mtl_units_of_measure. If both values are specified then
--             only UOM_Code is used. Type and Organization are required
--             p_type = 'WEIGHT', 'VOLUME'
--========================================================================

  PROCEDURE  Validate_Uom
	(p_type                         IN  VARCHAR2,
	 p_organization_id              IN  NUMBER,
	 p_uom_code                     IN  OUT NOCOPY  VARCHAR2,
      p_uom_desc                     IN  VARCHAR2,
	 x_return_status                OUT NOCOPY  VARCHAR2) IS

  CURSOR get_classes IS
  SELECT weight_uom_class, volume_uom_class
  FROM   wsh_shipping_parameters
  WHERE  organization_id = p_organization_id;

  -- Bug 3821688 Split Cursor
  CURSOR check_uom_code (l_class VARCHAR2) IS
  SELECT uom_code
  FROM   mtl_units_of_measure
  WHERE  uom_code = p_uom_code AND
	 uom_class = NVL(l_class, uom_class) AND
	 nvl(disable_date, sysdate) >= sysdate;

  CURSOR check_uom_desc (l_class VARCHAR2) IS
  SELECT uom_code
  FROM   mtl_units_of_measure
  WHERE  unit_of_measure = p_uom_desc AND
	 uom_class = NVL(l_class, uom_class) AND
	 nvl(disable_date, sysdate) >= sysdate;

  l_weight_uom_class VARCHAR2(10);
  l_volume_uom_class VARCHAR2(10);
  l_input_class VARCHAR2(10);

  -- Bug 3821688
  -- 1st cursor
  l_index NUMBER;
  l_flag VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_cache_rec Generic_Cache_Rec_Typ;
  -- 2nd cursor
  l_uom_index NUMBER;
  l_uom_flag VARCHAR2(1);
  l_uom_return_status VARCHAR2(1);
  l_cache_uom_rec Generic_Cache_Rec_Typ;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_UOM';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_TYPE',P_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_UOM_CODE',P_UOM_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_UOM_DESC',P_UOM_DESC);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF nvl(p_uom_code, fnd_api.g_miss_char) = fnd_api.g_miss_char
        AND nvl(p_uom_desc, fnd_api.g_miss_char) = fnd_api.g_miss_char
        THEN
          RETURN;
        END IF;
	IF (p_uom_code IS NOT NULL) OR (p_uom_desc IS NOT NULL) THEN
	  IF (p_organization_id IS NOT NULL) THEN
            -- Bug 3821688
            l_cache_rec.input_param1 := to_char(p_organization_id);
            -- Always Call get_table_index to check if value exists in cache
            -- If no record exists,then we can insert new record with the output index
            get_table_index
              (p_validate_rec => l_cache_rec,
               p_generic_tab => g_org_uom_class_tab,
               x_index      => l_index,
               x_return_status => l_return_status,
               x_flag        => l_flag
              );
             -- l_flag = U means use this index value to insert record in table
            IF l_flag = 'U' AND l_index IS NOT NULL THEN
              OPEN  get_classes;
              -- Fetching into param2 and param3 because corresponsing param1 is used
              -- for organization id(this will keep logic clear)
              FETCH get_classes INTO l_cache_rec.output_param2,l_cache_rec.output_param3;
              IF (get_classes%NOTFOUND) THEN
                l_cache_rec.valid_flag := 'N';
              ELSE
                l_cache_rec.valid_flag := 'Y';
              END IF;
              CLOSE get_classes;
              g_org_uom_class_tab(l_index) := l_cache_rec;
            END IF;
            -- Always check if input is valid or not
            IF g_org_uom_class_tab(l_index).valid_flag = 'N' THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ORG');
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status,l_module_name);
              RETURN;
            END IF;
            -- Always Populate return variables
            l_weight_uom_class := g_org_uom_class_tab(l_index).output_param2;
            l_volume_uom_class := g_org_uom_class_tab(l_index).output_param3;
            -- End of Bug 3821688
          END IF;

          -- Bug 3821688 for 2nd Cursor
          IF p_type IN ('WEIGHT','VOLUME') THEN
            IF p_type = 'WEIGHT' THEN
              l_input_class := l_weight_uom_class;
            ELSIF p_type = 'VOLUME' THEN
              l_input_class := l_volume_uom_class;
            END IF;
            -- Bug 3821688
            l_cache_uom_rec.input_param1 := p_type;
            l_cache_uom_rec.input_param2 := p_uom_code;
            l_cache_uom_rec.input_param3 := p_uom_desc;
            l_cache_uom_rec.input_param4 := l_input_class;

            -- Always Call get_table_index to check if value exists in cache
            -- If no record exists,then we can insert new record with the output index
            get_table_index
              (p_validate_rec => l_cache_uom_rec,
               p_generic_tab => g_uom_tab,
               x_index      => l_uom_index,
               x_return_status => l_uom_return_status,
               x_flag        => l_uom_flag
              );
             -- flag = U means use this index value to insert record in table
            IF l_uom_flag = 'U' AND l_uom_index IS NOT NULL THEN
              IF NVL(p_uom_code, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
                OPEN  check_uom_code (l_input_class);
	        FETCH check_uom_code INTO l_cache_uom_rec.output_param2;
   	        IF (check_uom_code%NOTFOUND) THEN
                  l_cache_uom_rec.valid_flag := 'N';
                ELSE
                  l_cache_uom_rec.valid_flag := 'Y';
	        END IF;
                CLOSE  check_uom_code;
              ELSIF NVL(p_uom_code, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
                OPEN  check_uom_desc (l_input_class);
	        FETCH check_uom_desc INTO l_cache_uom_rec.output_param2;
   	        IF (check_uom_desc%NOTFOUND) THEN
                  l_cache_uom_rec.valid_flag := 'N';
                ELSE
                  l_cache_uom_rec.valid_flag := 'Y';
	        END IF;
                CLOSE  check_uom_desc;

              END IF;
              g_uom_tab(l_uom_index) := l_cache_uom_rec;
            END IF;
            -- Always check if input is valid or not
            IF g_uom_tab(l_uom_index).valid_flag = 'N' THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_UOM');
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status,l_module_name);
            END IF;
            -- Always Populate return variables
            p_uom_code := g_uom_tab(l_uom_index).output_param2;

          ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    --
	    IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name,x_return_status);
	    END IF;
	    --
	    RETURN;
          END IF;
          -- End of Bug 3821688 for 2nd Cursor
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_uom_code',p_uom_code);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
  END Validate_Uom;

--========================================================================
-- PROCEDURE : Validate_User
--
-- COMMENT   : Validates User_id and User_name against table fnd_user
--             If both values are specified then only User_id is used
--========================================================================

  PROCEDURE  Validate_User
	(p_user_id                      IN OUT NOCOPY  NUMBER,
	 p_user_name                    IN VARCHAR2,
	 x_return_status                OUT NOCOPY  VARCHAR2) IS

  CURSOR check_user IS
  SELECT user_id
  FROM   fnd_user
  WHERE  p_user_id IS NOT NULL AND
	    user_id = p_user_id AND
         trunc(sysdate) between nvl( start_date, trunc(sysdate) )
		        and nvl( end_date, trunc(sysdate) )
  UNION ALL
  SELECT user_id
  FROM   fnd_user
  WHERE  p_user_id IS NULL AND
	    user_name = p_user_name AND
         trunc(sysdate) between nvl( start_date, trunc(sysdate) )
		        and nvl( end_date, trunc(sysdate) );

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_USER';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_USER_ID',P_USER_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_USER_NAME',P_USER_NAME);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (p_user_id IS NOT NULL) OR (p_user_name IS NOT NULL) THEN

        OPEN  check_user;
        FETCH check_user  INTO  p_user_id;

        IF (check_user%NOTFOUND) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_USER');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status,l_module_name);

        END IF;

        CLOSE check_user;

     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_user_id',p_user_id);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
  END Validate_User;

--========================================================================
-- PROCEDURE : Validate_Ship_Method
--
-- COMMENT   : Validates Ship_Method_Code/Name against fnd_lookup_values_vl.
--             If both values are specified then only Ship_Method_Code is used
--========================================================================

  PROCEDURE Validate_Ship_Method
        (p_ship_method_code     IN OUT NOCOPY VARCHAR2,
         p_ship_method_name     IN OUT NOCOPY VARCHAR2,
         x_return_status        OUT    NOCOPY VARCHAR2) IS

  -- Bug 3821688 Split Cursor
  CURSOR check_ship_method_code IS
  SELECT lookup_code, meaning
  FROM   fnd_lookup_values_vl
  WHERE  lookup_code = p_ship_method_code AND
	 lookup_type = 'SHIP_METHOD' AND
	 view_application_id = 3;

  CURSOR check_ship_method_name IS
  SELECT lookup_code, meaning
  FROM   fnd_lookup_values_vl
  WHERE  meaning = p_ship_method_name AND
	 lookup_type = 'SHIP_METHOD' AND
	 view_application_id = 3;

  -- Bug 3821688
  l_index NUMBER;
  l_flag VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_cache_rec Generic_Cache_Rec_Typ;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_SHIP_METHOD';
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
      WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_CODE',P_SHIP_METHOD_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_NAME',P_SHIP_METHOD_NAME);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    IF nvl(p_ship_method_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char
    OR nvl(p_ship_method_name, fnd_api.g_miss_char) <> fnd_api.g_miss_char
    THEN
      --

      -- Bug 3821688
      l_cache_rec.input_param1 := p_ship_method_code;
      l_cache_rec.input_param2 := p_ship_method_name;

      -- Always Call get_table_index to check if value exists in cache
      -- If no record exists,then we can insert new record with the output index
      get_table_index
        (p_validate_rec => l_cache_rec,
         p_generic_tab => g_ship_method_tab,
         x_index      => l_index,
         x_return_status => l_return_status,
         x_flag        => l_flag
        );
      -- l_flag = U means use this index value to insert record in table
      -- l_flag = D means valid record found
      IF l_flag = 'U' AND l_index IS NOT NULL THEN
        IF p_ship_method_code <> fnd_api.g_miss_char THEN
          OPEN  check_ship_method_code;
          FETCH check_ship_method_code
           INTO l_cache_rec.output_param1,l_cache_rec.output_param2;
          --
          IF (check_ship_method_code%NOTFOUND) THEN
            l_cache_rec.valid_flag := 'N';
          ELSE
            l_cache_rec.valid_flag := 'Y';
          END IF;
          --
          CLOSE check_ship_method_code;
        ELSIF p_ship_method_name <> fnd_api.g_miss_char THEN
          OPEN  check_ship_method_name;
          FETCH check_ship_method_name
           INTO l_cache_rec.output_param1,l_cache_rec.output_param2;
          --
          IF (check_ship_method_name%NOTFOUND) THEN
            l_cache_rec.valid_flag := 'N';
          ELSE
            l_cache_rec.valid_flag := 'Y';
          END IF;
          --
          CLOSE check_ship_method_name;
        END IF;
        g_ship_method_tab(l_index) := l_cache_rec;

      END IF;

      -- Always check if input is valid or not
      IF g_ship_method_tab(l_index).valid_flag = 'N' THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_SHIP_METHOD');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status,l_module_name);
      END IF;

      -- Always Populate return variables
      p_ship_method_code := g_ship_method_tab(l_index).output_param1;
      p_ship_method_name := g_ship_method_tab(l_index).output_param2;
      -- End of Bug 3821688
      --
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'p_ship_method_code',p_ship_method_code);
      WSH_DEBUG_SV.log(l_module_name,'p_ship_method_name',p_ship_method_name);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_UTIL_VALIDATE.Validate_Ship_Method');
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
  END Validate_Ship_Method;

--========================================================================
-- PROCEDURE : Validate_Freight_Terms
--
-- COMMENT   : Validates Freight_Terms_Code by calling the
--             Validate_Lookup_Code procedure.
--========================================================================

  PROCEDURE Validate_Freight_Terms
	(p_freight_terms_code IN OUT NOCOPY  VARCHAR2 ,
	 p_freight_terms_name IN  VARCHAR2,
         x_return_status      OUT NOCOPY  VARCHAR2 ) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_FREIGHT_TERMS';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_TERMS_CODE',P_FREIGHT_TERMS_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_TERMS_NAME',P_FREIGHT_TERMS_NAME);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


        IF nvl(p_freight_terms_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char
        OR nvl(p_freight_terms_name, fnd_api.g_miss_char) <> fnd_api.g_miss_char
        THEN
          -- OTM R12, glog project changes
          validate_lookup_UPPER(
            p_lookup_type   => 'FREIGHT_TERMS',
            p_lookup_code   => p_freight_terms_code,
            p_meaning       => p_freight_terms_name,
            x_return_status => x_return_status);
        END IF;

     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_FREIGHT_TERMS');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status,l_module_name);

	END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
  END Validate_Freight_Terms;

--========================================================================
-- PROCEDURE : Validate_FOB
--
-- COMMENT   : Validates FOB_Code by calling Validate_Lookup_Code
--========================================================================

  PROCEDURE Validate_FOB
	(p_fob_code      IN OUT NOCOPY  VARCHAR2,
	 p_fob_name      IN  VARCHAR2,
      x_return_status OUT NOCOPY  VARCHAR2 ) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_FOB';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_FOB_CODE',P_FOB_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_FOB_NAME',P_FOB_NAME);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF nvl(p_fob_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char
        OR nvl(p_fob_name, fnd_api.g_miss_char) <> fnd_api.g_miss_char
        THEN
	  validate_lookup(
	    p_lookup_type   => 'FOB',
	    p_lookup_code   => p_fob_code,
	    p_meaning       => p_fob_name,
	    x_return_status => x_return_status);
        END IF;

     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_FOB');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status,l_module_name);

	END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  END Validate_FOB;

--========================================================================
-- PROCEDURE : Validate_Flexfields
--
-- COMMENT   : Validates Flexfield id and concatenated segments
--   Logic used :
--	  if id is not null
--        validate id
--     else
--       if id is null
-- 	       begin
--            get delimeter
--            concatenate segments
--            validate concatenated segments
--          exception
--            handle exception
--          end
--          if item is not null
--             validate item
--          end if;
--        end if;
--     end if;
--========================================================================

  PROCEDURE Validate_Flexfields(
			p_id                IN OUT NOCOPY  NUMBER,
			p_concat_segs       IN 	VARCHAR2,
			p_app_short_name    IN   VARCHAR2,
			p_key_flx_code      IN   VARCHAR2,
   		     p_struct_number 	IN   NUMBER,
			p_org_id            IN   NUMBER,
			p_seg_array         IN   FND_FLEX_EXT.SegmentArray,
			p_val_or_ids        IN   VARCHAR2,
               p_wh_clause         IN   VARCHAR2 DEFAULT NULL,
               x_flag              OUT NOCOPY  BOOLEAN) IS

	 valid_flag 	boolean := NULL;

      delimiter	varchar2(1);
      concat_string	varchar2(2000);
      error_flag 	boolean := NULL;

      delimiter_null	exception;
      wrong_combination exception;

      ffield 		FND_FLEX_KEY_API.FLEXFIELD_TYPE;
      fstruct 		FND_FLEX_KEY_API.STRUCTURE_TYPE;
      slist 		FND_FLEX_KEY_API.SEGMENT_LIST;
      fsegment 	FND_FLEX_KEY_API.SEGMENT_TYPE;

      nsegs 		NUMBER;
      charcol		VARCHAR2(70);
      numbcol 		NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_FLEXFIELDS';
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
         WSH_DEBUG_SV.log(l_module_name,'P_ID',P_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_CONCAT_SEGS',P_CONCAT_SEGS);
         WSH_DEBUG_SV.log(l_module_name,'P_APP_SHORT_NAME',P_APP_SHORT_NAME);
         WSH_DEBUG_SV.log(l_module_name,'P_KEY_FLX_CODE',P_KEY_FLX_CODE);
         WSH_DEBUG_SV.log(l_module_name,'P_STRUCT_NUMBER',P_STRUCT_NUMBER);
         WSH_DEBUG_SV.log(l_module_name,'P_ORG_ID',P_ORG_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_VAL_OR_IDS',P_VAL_OR_IDS);
         WSH_DEBUG_SV.log(l_module_name,'P_WH_CLAUSE',P_WH_CLAUSE);
     END IF;
     --
     --IF p_id IS NOT NULL THEN
     IF NVL(p_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM  THEN

         x_flag := fnd_flex_keyval.validate_ccid(
                     appl_short_name => p_app_short_name,
                     key_flex_code   => p_key_flx_code,
   		           structure_number=> p_struct_number,
       		      combination_id  => p_id,
                     data_set        => p_org_id);

	    p_id := fnd_flex_keyval.combination_id;
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'x_flag',x_flag);
               WSH_DEBUG_SV.log(l_module_name,'p_id',p_id);
            END IF;
     ELSIF p_id IS NULL OR p_id = FND_API.G_MISS_NUM THEN
          If l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name, 'Calling set session mode');
          END IF;

           fnd_flex_key_api.set_session_mode(session_mode =>'seed_data');

          If l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name, 'Calling find flexfield');
          END IF;


	    ffield  := fnd_flex_key_api.find_flexfield(p_app_short_name, p_key_flx_code);
	    fstruct := fnd_flex_key_api.find_structure(ffield, p_struct_number);
         fnd_flex_key_api.get_segments(ffield, fstruct, TRUE, nsegs, slist);

         delimiter := fnd_flex_ext.get_delimiter(
				     application_short_name 	=> p_app_short_name,
                       	key_flex_code   	=> p_key_flx_code,
   		       		structure_number 	=> p_struct_number);

          If l_debug_on THEN
             wsh_debug_sv.log(l_module_name, 'delimiter', delimiter);
             wsh_debug_sv.log(l_module_name, 'nsegs', nsegs);
          END IF;

         IF (delimiter IS NOT NULL) THEN
	       concat_string := '';

            FOR i IN 1..nsegs LOOP
	          fsegment := fnd_flex_key_api.find_segment(ffield, fstruct, slist(i));
            	charcol := fsegment.column_name;
                if l_debug_on then
                   wsh_debug_sv.log(l_module_name, 'charcol', charcol);
                end if;
		     charcol := substr(charcol, 8, length(fsegment.column_name));
		     numbcol := to_number(charcol);
                if l_debug_on then
                   wsh_debug_sv.log(l_module_name, 'numcol', numbcol);
                end if;
	    	     concat_string := concat_string||p_seg_array(numbcol);
	       END LOOP;

          If l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name, 'Calling validate_segs');
          END IF;

	       x_flag    := fnd_flex_keyval.validate_segs(
		   			operation	=>'CHECK_COMBINATION',
	  	   			appl_short_name	=> p_app_short_name,
		   			key_flex_code	=> p_key_flx_code,
		   			structure_number=> p_struct_number,
		   			concat_segments	=> concat_string,
              			data_set	=> p_org_id,
                         values_or_ids   => p_val_or_ids,
                         where_clause    => p_wh_clause );

             If l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'x_flag', x_flag);
             END IF;

	       p_id := fnd_flex_keyval.combination_id;

	       IF x_flag = FALSE THEN
		     RAISE wrong_combination;
	       END IF;
         ELSE
		  x_flag := FALSE;
		  RAISE delimiter_null;
	    end if;

         IF p_concat_segs IS NOT NULL THEN
            x_flag:= fnd_flex_keyval.validate_segs(
		   	operation	=> 'CHECK_COMBINATION',
	  	   	appl_short_name	=> p_app_short_name,
		   	key_flex_code	=> p_key_flx_code,
		   	structure_number=> p_struct_number,
		   	concat_segments	=> p_concat_segs,
               data_set	=> p_org_id);
         END IF;

     END IF; -- id is null
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     EXCEPTION
        WHEN delimiter_null THEN
		  FND_MESSAGE.SET_NAME('WSH','WSH_OI_FLEX_DELIMITER_NULL');
		  wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
		  --
		  IF l_debug_on THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,'DELIMITER_NULL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DELIMITER_NULL');
		  END IF;
		  --
        WHEN wrong_combination THEN
		  FND_MESSAGE.SET_NAME('WSH','WSH_OI_FLEX_INV_COMB_ERROR');
		  wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'WRONG_COMBINATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WRONG_COMBINATION');
                  END IF;
                  --
         WHEN others THEN
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'Exception:', fnd_flex_key_api.message);
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
           END IF;
  END Validate_Flexfields;

--========================================================================
-- PROCEDURE : Validate_Item
--
-- COMMENT   : Validates Inventory_Item_id/Concatenated name/Segment array
--             using FND APIs. Item id takes precedence over the other validations.
--========================================================================

   PROCEDURE Validate_Item(
	  p_inventory_item_id IN OUT NOCOPY  NUMBER,
	  p_inventory_item    IN     VARCHAR2,
       p_organization_id   IN     NUMBER,
	  p_seg_array         IN     FND_FLEX_EXT.SegmentArray,
       x_return_status     OUT NOCOPY  VARCHAR2,
          p_item_type      IN  VARCHAR2 --Defaulted to Null in Spec
         )
   IS

   valid_flag 	boolean := NULL;
   -- Patchset I Harmonization project KVENKATE
   l_item_type     VARCHAR2(100);
   l_return_status VARCHAR2(100);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_ITEM';
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
          WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM',P_INVENTORY_ITEM);
          WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      IF nvl(p_inventory_item_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
      AND nvl(p_inventory_item, fnd_api.g_miss_char) = fnd_api.g_miss_char
        AND p_seg_array.count = 0
      THEN

        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;
      --
      validate_flexfields(
				 p_id		      => p_inventory_item_id,
				 p_concat_segs		 => p_inventory_item,
				 p_app_short_name => 'INV',
                     p_key_flx_code   => 'MSTK',
   		       	 p_struct_number  => 101,
				 p_org_id		 => p_organization_id,
			      p_seg_array      => p_seg_array,
				 p_val_or_ids	 => 'I',
				 x_flag		 => valid_flag);

      IF valid_flag = FALSE  THEN

         FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ITEM');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status,l_module_name);
            IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;

      END IF;
      --
      -- harmonization project begin KVENKATE
      IF(p_item_type IN ('VEH_ITEM', 'CONT_ITEM')) THEN
          Find_Item_Type(
          p_inventory_item_id => p_inventory_item_id,
          p_organization_id   => p_organization_id,
          x_item_type         => l_item_type,
          x_return_status     => l_return_status);

          IF nvl(l_item_type, FND_API.G_MISS_CHAR) <> p_item_type THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ITEM');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status,l_module_name);
          END IF;
      END IF;
      -- harmonization project end KVENKATE
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
   END Validate_Item;

-- LINE SPECIFIC VALIDATIONS BELOW --
PROCEDURE Validate_Boolean(
	p_flag           IN   VARCHAR2,
	x_return_status     OUT NOCOPY  VARCHAR2)
IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_BOOLEAN';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_FLAG',P_FLAG);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (NVL(p_flag, 'N') NOT IN ('Y', 'N')) THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
END;

PROCEDURE Validate_Released_Status(
	p_released_status  IN     VARCHAR2,
	x_return_status       OUT NOCOPY  VARCHAR2)
IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_RELEASED_STATUS';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_RELEASED_STATUS',P_RELEASED_STATUS);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (NVL(p_released_status, 'N') NOT IN ('N', 'Y', 'R', 'X')) THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
END;

PROCEDURE Validate_Order_uom(
   p_organization_id  IN     NUMBER,
	p_inventory_item_id IN    NUMBER,
	p_unit_of_measure  IN     VARCHAR2,
	x_uom_code         IN OUT NOCOPY  VARCHAR2,
	x_return_status       OUT NOCOPY  VARCHAR2)
IS
CURSOR check_order_uom IS
SELECT uom_code
FROM   mtl_item_uoms_view
WHERE  organization_id = p_organization_id AND
	inventory_item_id = p_inventory_item_id AND
	uom_code = x_uom_code
UNION ALL
SELECT uom_code
FROM   mtl_item_uoms_view
WHERE  organization_id = p_organization_id AND
	inventory_item_id = p_inventory_item_id AND
	unit_of_measure = p_unit_of_measure;
	--
l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_ORDER_UOM';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_UNIT_OF_MEASURE',P_UNIT_OF_MEASURE);
	    WSH_DEBUG_SV.log(l_module_name,'X_UOM_CODE',X_UOM_CODE);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (p_unit_of_measure IS NOT NULL OR x_uom_code IS NOT NULL) THEN
		OPEN  check_order_uom;
                FETCH check_order_uom  INTO  x_uom_code;

		IF (check_order_uom%NOTFOUND) THEN

	  		FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_UOM');
	      FND_MESSAGE.SET_TOKEN('UOM_TYPE','ordered quantity uom');
	      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	      wsh_util_core.add_message(x_return_status,l_module_name);

		END IF;
		CLOSE check_order_uom;

	END IF;
	--
	IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'x_uom_code',x_uom_code);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
END;

-- CONTAINER SPECIFIC VALIDATIONS BELOW --

-- DELIVERY SPECIFIC VALIDATIONS BELOW --

--========================================================================
-- PROCEDURE : Validate_Delivery_Name
--
-- COMMENT   : Validates Delivery_id/Delivery_Name against table
--             wsh_new_deliveries. If both values are specified then only
--             delivery_id is used
--========================================================================

  PROCEDURE Validate_Delivery_Name
        (p_delivery_id    IN OUT NOCOPY  NUMBER ,
         p_delivery_name  IN     VARCHAR2 ,
         x_return_status  OUT NOCOPY     VARCHAR2 ) IS

  CURSOR check_delivery_name IS
  SELECT delivery_id
  FROM   wsh_new_deliveries
  WHERE  NVL(p_delivery_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
	    delivery_id = p_delivery_id
  UNION ALL
  SELECT delivery_id
  FROM   wsh_new_deliveries
  WHERE  NVL(p_delivery_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM AND
	    name = p_delivery_name;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DELIVERY_NAME';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_NAME',P_DELIVERY_NAME);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF (p_delivery_id IS NOT NULL) OR (p_delivery_name IS NOT NULL) THEN

        OPEN  check_delivery_name;
        FETCH check_delivery_name  INTO  p_delivery_id;

        IF (check_delivery_name%NOTFOUND) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_DEL_NAME');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status,l_module_name);

        END IF;

        CLOSE check_delivery_name;

	END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_name',p_delivery_name);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_id',p_delivery_id);
            WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
  END Validate_Delivery_Name;


--========================================================================
-- PROCEDURE : Validate_Report_Set
--
-- COMMENT   : Validates Report_set_id/Report_set name against table
--             wsh_report_sets. If both values are specified then only
--             report_set_id is used
--========================================================================

  PROCEDURE Validate_Report_Set
	(p_report_set_id   IN OUT NOCOPY  NUMBER ,
      p_report_set_name IN     VARCHAR2 ,
      x_return_status   OUT NOCOPY   VARCHAR2 ) IS

  CURSOR check_report_set IS
  SELECT report_set_id
  FROM   wsh_report_sets
  WHERE  p_report_set_id IS NOT NULL AND
	    report_set_id = p_report_set_id AND
      start_date_active <= sysdate AND
      nvl(end_date_active,sysdate) >= sysdate
  UNION ALL
  SELECT report_set_id
  FROM   wsh_report_sets
  WHERE  p_report_set_id IS NULL AND
	    name = p_report_set_name AND
      start_date_active <= sysdate AND
      nvl(end_date_active,sysdate) >= sysdate;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_REPORT_SET';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_REPORT_SET_ID',P_REPORT_SET_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_REPORT_SET_NAME',P_REPORT_SET_NAME);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF (p_report_set_id IS NOT NULL) OR (p_report_set_name IS NOT NULL) THEN

        OPEN  check_report_set;
        FETCH check_report_set  INTO  p_report_set_id;

        IF (check_report_set%NOTFOUND) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_REPORT_SET');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status,l_module_name);

        END IF;

        CLOSE check_report_set;

     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_report_set_id',p_report_set_id);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
  END Validate_Report_Set;

--========================================================================
-- PROCEDURE : Validate_Loading_Order
--
-- COMMENT   : Validates Loading_Order_Flag/Loading_order_desc by
--             calling Validate_lookup_code. If both values are
--             specified then only Loading_order_desc is used
--========================================================================

  PROCEDURE Validate_Loading_Order(
    p_loading_order_flag IN OUT NOCOPY  VARCHAR2 ,
    p_loading_order_desc IN     VARCHAR2 ,
    x_return_status      OUT NOCOPY  VARCHAR2 )
  IS
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_LOADING_ORDER';
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
      WSH_DEBUG_SV.log(l_module_name,'P_LOADING_ORDER_FLAG',P_LOADING_ORDER_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_LOADING_ORDER_DESC',P_LOADING_ORDER_DESC);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    IF nvl(p_loading_order_flag,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
    OR nvl(p_loading_order_desc,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
    THEN
      --
      IF nvl(p_loading_order_flag,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
	--
        IF upper(p_loading_order_desc) ='FORWARD' THEN
          p_loading_order_flag := 'F';
        ELSIF upper(p_loading_order_desc) ='FORWARD INVERTED'THEN
          p_loading_order_flag := 'FI';
        ELSIF upper(p_loading_order_desc) ='REVERSE' THEN
          p_loading_order_flag := 'R';
        ELSIF upper(p_loading_order_desc) ='REVERSE INVERTED' THEN
          p_loading_order_flag := 'RI';
        ELSE
          --
	  FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_LOADING_ORDER');
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  wsh_util_core.add_message(x_return_status,l_module_name);
          --
        END IF;
	    --
      ELSIF p_loading_order_flag NOT IN ('F','FI', 'R','RI') THEN
	--
	FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_LOADING_ORDER');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	wsh_util_core.add_message(x_return_status,l_module_name);
	--
      END IF;
      --
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_UTIL_VALIDATE.VALIDATE_LOADING_ORDER');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  END Validate_Loading_Order;

-- STOP SPECIFIC VALIDATIONS BELOW --

--========================================================================
-- PROCEDURE : Validate_Stop_Name
--
-- COMMENT   : Validates Stop_id OR
--             Trip_id+Stop_Location_id+Planned_Departure_date against table
--             wsh_trips. If both validations are possible then only
--             stop_id is validated
--========================================================================

  PROCEDURE Validate_Stop_Name
        (p_stop_id        IN OUT NOCOPY  NUMBER ,
         p_trip_id        IN     NUMBER ,
	    p_stop_location_id IN   NUMBER ,
	    p_planned_dep_date IN   DATE,
         x_return_status  OUT NOCOPY     VARCHAR2 ) IS

  CURSOR check_stop_name IS
  SELECT stop_id
  FROM   wsh_trip_stops
  WHERE  NVL(p_stop_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
	    stop_id = p_stop_id
  UNION ALL
  SELECT stop_id
  FROM   wsh_trip_stops
  WHERE  NVL(p_stop_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM AND
	    trip_id = p_trip_id AND
	    stop_location_id = p_stop_location_id AND
	    planned_departure_date = nvl(p_planned_dep_date, planned_departure_date)
  ;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_STOP_NAME';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_STOP_LOCATION_ID',P_STOP_LOCATION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_PLANNED_DEP_DATE',P_PLANNED_DEP_DATE);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF (p_stop_id IS NOT NULL) OR (p_trip_id IS NOT NULL) THEN

        OPEN  check_stop_name;
        FETCH check_stop_name  INTO  p_stop_id;

        IF (check_stop_name%NOTFOUND) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_STOP_NAME');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status,l_module_name);

        END IF;

        CLOSE check_stop_name;

	END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'p_stop_id',p_stop_id);
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
  END Validate_Stop_Name;


-- TRIP SPECIFIC VALIDATIONS BELOW --

--========================================================================
-- PROCEDURE : Validate_Trip_Name
--
-- COMMENT   : Validates Trip_id/Trip_Name against table
--             wsh_trips. If both values are specified then only
--             trip_id is used
--========================================================================

  PROCEDURE Validate_Trip_Name
        (p_trip_id        IN OUT NOCOPY  NUMBER ,
         p_trip_name      IN     VARCHAR2 ,
         x_return_status  OUT NOCOPY     VARCHAR2 ) IS

  CURSOR check_trip_name IS
  SELECT trip_id
  FROM   wsh_trips
  WHERE  NVL(p_trip_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
	    trip_id = p_trip_id
  UNION ALL
  SELECT trip_id
  FROM   wsh_trips
  WHERE  NVL(p_trip_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM AND
	    name = p_trip_name;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_TRIP_NAME';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_NAME',P_TRIP_NAME);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF (p_trip_id IS NOT NULL) OR (p_trip_name IS NOT NULL) THEN

        OPEN  check_trip_name;
        FETCH check_trip_name  INTO  p_trip_id;

        IF (check_trip_name%NOTFOUND) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_TRIP_NAME');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status,l_module_name);

        END IF;

        CLOSE check_trip_name;

	END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
  END Validate_Trip_Name;

--========================================================================
-- PROCEDURE : Validate_Trip_MultiStops
-- 4106444 -skattama
-- COMMENT   : Validates for Trip_id if mode is other then
--             'TRUCK', the number of stops should not be more
--             than 2.
--========================================================================

  PROCEDURE Validate_Trip_MultiStops
          (p_trip_id        IN  NUMBER ,
           p_mode_of_transport    IN     VARCHAR2 ,
           x_return_status  OUT NOCOPY     VARCHAR2 ) IS

  CURSOR check_stop_count is
  select count(*)
  from  wsh_trip_stops s
  where s.trip_id = p_trip_id
  and s.physical_stop_id is null
  and rownum < 4;

  l_stop_count NUMBER;
  l_trip_name  VARCHAR2(100);
--
  l_debug_on BOOLEAN;
--
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Trip_MultiStops';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF ((p_trip_id IS NOT NULL) AND (p_mode_of_transport <> 'TRUCK')) THEN

    OPEN  check_stop_count;
    FETCH check_stop_count  INTO  l_stop_count;

    IF l_stop_count = 3 THEN

       l_trip_name := WSH_TRIPS_PVT.Get_Name(p_trip_id);
       FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_MOT_STOP_COUNT');
       FND_MESSAGE.SET_TOKEN('TRIP_NAME', l_trip_name);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       wsh_util_core.add_message(x_return_status,l_module_name);

    END IF;

    CLOSE check_stop_count;

	END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  END Validate_Trip_MultiStops;


--========================================================================
-- FUNCTION : Check_Wms_Org
--
-- COMMENT   : Check if the Organization is WMS enabled.
--             If Yes, Return 'Y'. Otherwise 'N'
--========================================================================

  FUNCTION Check_Wms_Org
		  (p_organization_id        IN  NUMBER) RETURN VARCHAR2  IS

  l_return_status VARCHAR2(1) := 'N';
  l_proc_status   VARCHAR2(1000) ;
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);

  -- LPN CONV. rv
  l_return_value  boolean;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_WMS_ORG';
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
        WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
    END IF;

    -- bug 5161801, if p_organization_id is NULL return 'N';
    IF (p_organization_id is NULL) THEN
    --{
       l_return_status := 'N';
    --}
    -- LPN CONV. rv
    ELSIF (p_organization_id = g_organization_id) THEN
    --{
        l_return_status :=  g_is_wms_org;
    --}
    ELSE
    --{
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-x_dlvyTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.get_cached_value
          (
            p_cache_tbl         => g_orgn_id_tbl,
            p_cache_ext_tbl     => g_orgn_id_ext_tbl,
            p_value             => l_return_status,
            p_key               => p_organization_id,
            p_action            => 'GET',
            x_return_status     => l_proc_status
          );
        --
        --
        IF l_proc_status = WSH_UTIL_CORE.G_RET_STS_ERROR
        THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_proc_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
        THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_proc_status = WSH_UTIL_CORE.G_RET_STS_WARNING
        THEN
        --{

            l_return_value := wms_install.check_install(
                                p_organization_id => p_organization_id,
                                x_return_status   => l_proc_status,
                                x_msg_count       => l_msg_count,
                                x_msg_data        => l_msg_data);


            IF l_proc_status = WSH_UTIL_CORE.G_RET_STS_ERROR
            THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_proc_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
            THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF l_return_value THEN
               l_return_status := 'Y';
            ELSE
               l_return_status := 'N';
            END IF;

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-x_dlvyTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.get_cached_value
              (
                p_cache_tbl         => g_orgn_id_tbl,
                p_cache_ext_tbl     => g_orgn_id_ext_tbl,
                p_value             => l_return_status,
                p_key               => p_organization_id,
                p_action            => 'PUT',
                x_return_status     => l_proc_status
              );
            --
            --
            IF l_proc_status = WSH_UTIL_CORE.G_RET_STS_ERROR
            THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF l_proc_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
            THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            --
        --}
        END IF;
        --
        g_organization_id := p_organization_id;
        g_is_wms_org := l_return_status;
        --
    --}
    END IF;
    -- LPN CONV. rv



    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Returns ',l_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN l_return_status ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
         END IF;
         --
         -- bug 5161801, return 'N' when it encounters any exception
         l_return_status := 'N';
	 RETURN l_return_status ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
         END IF;
         --
         -- bug 5161801, return 'N' when it encounters any exception
         l_return_status := 'N';
	 RETURN l_return_status ;
    WHEN OTHERS THEN
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	 END IF;
	 --
         -- bug 5161801, return 'N' when it encounters any exception
         l_return_status := 'N';
	 RETURN l_return_status ;
  END Check_Wms_Org ;

--Harmonizing Project I --heali
PROCEDURE validate_from_to_dates (
        p_from_date     IN DATE,
        p_to_date       IN DATE,
        x_return_status OUT NOCOPY  VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_FROM_TO_DATES';

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
    WSH_DEBUG_SV.log(l_module_name,'p_from_date',p_from_date);
    WSH_DEBUG_SV.log(l_module_name,'p_to_date',p_to_date);
 END IF;
 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 IF nvl(p_from_date, fnd_api.g_miss_date) <> fnd_api.g_miss_date
 OR nvl(p_to_date, fnd_api.g_miss_date) <> fnd_api.g_miss_date
 THEN
    IF (p_from_date > p_to_date) THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('WSH','WSH_XC_INVALID_DATE_RANGE');
       wsh_util_core.add_message(x_return_status,l_module_name);
    END IF;
 END IF;


 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
 WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    wsh_util_core.default_handler('WSH_UTIL_VALIDATE.validate_from_to_dates');
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END validate_from_to_dates;


PROCEDURE Validate_Trip_status (
        p_trip_id       IN NUMBER,
        p_action        IN VARCHAR2,
        x_return_status OUT NOCOPY  VARCHAR2) IS

/* J TP Release : If assigning del to trip doesn't introduce new stops, ok to assign to planned trips */
CURSOR get_trip_status_1(l_trip_id NUMBER) IS
  select 'X', name
  from wsh_trips
  where trip_id = p_trip_id
  and
      (
          (     status_code IN ( 'OP','IT' )
            and nvl(shipments_type_flag,'O') = 'O'   -- J-IB-NPARIKH
          )
          OR nvl(shipments_type_flag,'O') <> 'O'   -- J-IB-NPARIKH
      )
  and nvl(planned_flag,'N') ='N'
  and rownum = 1;
CURSOR get_trip_status_2(l_trip_id NUMBER) IS
  select 'X', name
  from wsh_trips
  where trip_id = p_trip_id
  and
      (
          (     status_code IN ( 'OP' )
            and nvl(shipments_type_flag,'O') = 'O'   -- J-IB-NPARIKH
          )
          OR nvl(shipments_type_flag,'O') <> 'O'   -- J-IB-NPARIKH
      )
  and nvl(planned_flag,'N') IN ('N', 'Y')
  and rownum = 1;

l_valid_trip	VARCHAR2(30);
l_trip_name	VARCHAR2(100);
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_TRIP_STATUS';
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
    WSH_DEBUG_SV.log(l_module_name,'p_trip_id',p_trip_id);
    WSH_DEBUG_SV.log(l_module_name,'p_action',p_action);
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 IF (p_trip_id IS NOT NULL) THEN
    IF p_action = 'CREATE' THEN
      OPEN get_trip_status_1(p_trip_id);
      FETCH get_trip_status_1 INTO l_valid_trip,l_trip_name;
      CLOSE get_trip_status_1;
    ELSE
      OPEN get_trip_status_2(p_trip_id);
      FETCH get_trip_status_2 INTO l_valid_trip,l_trip_name;
      CLOSE get_trip_status_2;
    END IF;

    IF ( nvl(l_valid_trip, FND_API.G_MISS_CHAR) <> 'X' ) THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_STATUS_NO_ACTION');
       FND_MESSAGE.SET_TOKEN('TRIP_NAME', l_trip_name);
       wsh_util_core.add_message(x_return_status,l_module_name);
    END IF;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
 WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    wsh_util_core.default_handler('WSH_UTIL_VALIDATE.validate_trip_status');
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END validate_trip_status;

-- I Harmonization: rvishnuv *******

--========================================================================
-- PROCEDURE : Validate_Carrier
--
-- COMMENT   : Check if the Carrier is a valid carrier or not.
--========================================================================
PROCEDURE Validate_Carrier(
            p_carrier_name  IN VARCHAR2,
            x_carrier_id    IN OUT NOCOPY NUMBER,
            x_return_status OUT NOCOPY VARCHAR2)
IS
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_CARRIER';
  --
  cursor l_carrier_csr is
  select carrier_id
  from   wsh_carriers_v
  where  nvl(x_carrier_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
  and    carrier_id = x_carrier_id
  and    nvl(generic_flag, 'N') = 'N'
  and    active = 'A'
  union all
  select carrier_id
  from   wsh_carriers_v
  where  nvl(x_carrier_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
  and    carrier_name = p_carrier_name
  and    nvl(generic_flag, 'N') = 'N'
  and    active = 'A';


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
    --
    WSH_DEBUG_SV.log(l_module_name,'p_carrier_name', p_carrier_name);
    WSH_DEBUG_SV.log(l_module_name,'x_carrier_id', x_carrier_id);
    --
  END IF;
  --
  x_return_status := wsh_util_core.g_ret_sts_success;
  --
  IF nvl(x_carrier_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
  OR nvl(p_carrier_name, fnd_api.g_miss_char) <> fnd_api.g_miss_char
  THEN
    --
    open l_carrier_csr;
    fetch l_carrier_csr into x_carrier_id;
    --
    IF l_carrier_csr%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_NOT_FOUND');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status,l_module_name);
    END IF;
    close l_carrier_csr;
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
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
      wsh_util_core.default_handler('WSH_UTIL_VALIDATE.VALIDATE_CARRIER');
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Validate_Carrier;

--========================================================================
-- PROCEDURE : Validate_Freight_Carrier
--
-- COMMENT   : This API checks if the inputs ship method, carrier, and service level
--             are valid values.
--             Also if ship method is a valid input, then, based on the organization,
--             it derives the carrier, service level and mode of transport.
--             Also, if the ship method is null and if all the remaining three
--             components are defined, then based on the organization, it derives
--             the ship method.
--             Organization_id is a mandatory parameter if the entity is DLVY.
--             p_entity_type can have values of 'TRIP' or 'DLVY'.
--             p_entity_id should contain either trip_id or delivery_id
--             depending on the p_entity_type.
--========================================================================
PROCEDURE Validate_Freight_Carrier(
            p_ship_method_name     IN OUT NOCOPY VARCHAR2,
            x_ship_method_code     IN OUT NOCOPY VARCHAR2,
            p_carrier_name         IN     VARCHAR2,
            x_carrier_id           IN OUT NOCOPY NUMBER,
            x_service_level        IN OUT NOCOPY VARCHAR2,
            x_mode_of_transport    IN OUT NOCOPY VARCHAR2,
            p_entity_type          IN     VARCHAR2,
            p_entity_id            IN     NUMBER,
            p_organization_id      IN     NUMBER, -- defaulted to NULL
            x_return_status        OUT    NOCOPY VARCHAR2,
            p_caller               IN     VARCHAR2)
IS
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_FREIGHT_CARRIER';
  --
  l_return_status VARCHAR2(1);
  l_dummy_meaning VARCHAR2(4000);
  l_num_errors    NUMBER;
  l_num_warnings  NUMBER;
  l_sm_is_null    BOOLEAN := FALSE;
  --
  l_new_carrier VARCHAR2(1);
  l_ship_method_code_backup       wsh_new_deliveries.ship_method_code%TYPE;

  -- Below cursors are used if the entity is a delivery.
  --TP does not honor WSH's org assignment for ship method, so if caller is TP,
  --p_organization_id need not be considered

  cursor l_dlvy_ship_method_code_csr is
-- Bug 2757672
  select wcs.carrier_id,
         wcs.service_level,
         wcs.mode_of_transport
  from   wsh_carrier_services wcs,
         wsh_org_carrier_services wocs,
         wsh_carriers_v wcv
  where  wcs.carrier_service_id     = wocs.carrier_service_id
  and    wcs.carrier_id             = wcv.carrier_id
  and    wcv.active                 = 'A'
  and    NVL(wcv.generic_flag, 'N') = 'N'
  and    nvl(wcs.enabled_flag, 'N') = 'Y'
  and    nvl(wocs.enabled_flag, 'N')= 'Y'
  and    wcs.ship_method_code       = x_ship_method_code
  and    wocs.organization_id       = p_organization_id;

  --if caller is TP use below cursor (no org check)
  cursor l_dlvy_ship_method_code_csr_tp is
-- Bug 2757672
  select wcs.carrier_id,
         wcs.service_level,
         wcs.mode_of_transport
  from   wsh_carrier_services wcs,
         wsh_org_carrier_services wocs,
         wsh_carriers_v wcv
  where  wcs.carrier_service_id     = wocs.carrier_service_id
  and    wcs.carrier_id             = wcv.carrier_id
  and    wcv.active                 = 'A'
  and    NVL(wcv.generic_flag, 'N') = 'N'
  and    nvl(wcs.enabled_flag, 'N') = 'Y'
  and    nvl(wocs.enabled_flag, 'N')= 'Y'
  and    wcs.ship_method_code       = x_ship_method_code
  and rownum=1;

  --
  cursor l_dlvy_carrier_services_csr is
-- Bug 2757672
  select wcs.ship_method_code
  from   wsh_carrier_services wcs,
         wsh_org_carrier_services wocs,
         wsh_carriers_v wcv
  where  wcs.carrier_service_id = wocs.carrier_service_id
  and    wcs.carrier_id             = wcv.carrier_id
  and    wcv.active                 = 'A'
  and    NVL(wcv.generic_flag, 'N') = 'N'
  and    nvl(wcs.enabled_flag, 'N') = 'Y'
  and    nvl(wocs.enabled_flag, 'N')= 'Y'
  and    wcs.carrier_id         = x_carrier_id
  and    ( (wcs.service_level is null
            and x_service_level is null )
           or
           ( wcs.service_level is not null
             and wcs.service_level = x_service_level )
         )
  and    ( (wcs.mode_of_transport is null
            and x_mode_of_transport is null )
           or
           ( wcs.mode_of_transport is not null
             and wcs.mode_of_transport = x_mode_of_transport )
         )
  and    wocs.organization_id   = p_organization_id;

  --if caller is TP use below cursor (no org check)
  cursor l_dlvy_carrier_services_csr_tp is
-- Bug 2757672
  select wcs.ship_method_code
  from   wsh_carrier_services wcs,
         wsh_org_carrier_services wocs,
         wsh_carriers_v wcv
  where  wcs.carrier_service_id = wocs.carrier_service_id
  and    wcs.carrier_id             = wcv.carrier_id
  and    wcv.active                 = 'A'
  and    NVL(wcv.generic_flag, 'N') = 'N'
  and    nvl(wcs.enabled_flag, 'N') = 'Y'
  and    nvl(wocs.enabled_flag, 'N')= 'Y'
  and    wcs.carrier_id         = x_carrier_id
  and    ( (wcs.service_level is null
            and x_service_level is null )
           or
           ( wcs.service_level is not null
             and wcs.service_level = x_service_level )
         )
  and    ( (wcs.mode_of_transport is null
            and x_mode_of_transport is null )
           or
           ( wcs.mode_of_transport is not null
             and wcs.mode_of_transport = x_mode_of_transport )
         )
  and rownum=1;

  --
  cursor l_dlvy_car_shp_mthd_csr(p_delivery_id IN NUMBER) is
  select carrier_id,
         service_level,
         mode_of_transport,
         ship_method_code
  from   wsh_new_deliveries
  where  delivery_id = p_delivery_id;
  --
  -- Below cursors are used if the entity is a trip.
  --
  cursor l_trip_ship_method_code_csr is
-- Bug 2757672
  select wcs.carrier_id,
         wcs.service_level,
         wcs.mode_of_transport
  from   wsh_carrier_services wcs,
         wsh_carriers_v wcv
  where  wcs.ship_method_code       = x_ship_method_code
  and    wcs.carrier_id             = wcv.carrier_id
  and    nvl(wcs.enabled_flag, 'N') = 'Y'
  and    wcv.active                 = 'A'
  and    NVL(wcv.generic_flag, 'N') = 'N';
  --
  cursor l_trip_carrier_services_csr is
-- Bug 2757672
  select distinct wcs.ship_method_code
  from   wsh_carrier_services wcs,
         wsh_carriers_v wcv
  where  wcs.carrier_id         = x_carrier_id
  and    wcs.carrier_id         = wcv.carrier_id
  and    nvl(wcs.enabled_flag, 'N') = 'Y'
  and    wcv.active                 = 'A'
  and    NVL(wcv.generic_flag, 'N') = 'N'
  and    ( (wcs.service_level is null
            and x_service_level is null )
           or
           ( wcs.service_level is not null
             and wcs.service_level = x_service_level )
         )
  and    ( (wcs.mode_of_transport is null
            and x_mode_of_transport is null )
           or
           ( wcs.mode_of_transport is not null
             and wcs.mode_of_transport = x_mode_of_transport )
         );
  --
  cursor l_trip_car_shp_mthd_csr(p_trip_id IN NUMBER) is
  select carrier_id,
         service_level,
         mode_of_transport,
         ship_method_code
  from   wsh_trips
  where  trip_id = p_trip_id;


  -- Bug 4086855
  -- If the trip's mode is PARCEL or LTL, the trip can have at most two
  -- stops (linked stops are counted as one stop in this case).

  cursor l_trip_stop_count(p_trip_id in number) is
  select count(*)
  from  wsh_trip_stops s
  where s.trip_id = p_trip_id
  and s.physical_stop_id is null
  and rownum < 4;

  --
  l_carrier_id        NUMBER;
  l_service_level     VARCHAR2(32767);
  l_mode_of_transport VARCHAR2(32767);
  l_ship_method_code  VARCHAR2(32767);
  l_stop_count        NUMBER;
  l_trip_name         VARCHAR2(30);
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
    --
    WSH_DEBUG_SV.log(l_module_name,'p_caller', p_caller);
    WSH_DEBUG_SV.log(l_module_name,'p_ship_method_name', p_ship_method_name);
    WSH_DEBUG_SV.log(l_module_name,'x_ship_method_code', x_ship_method_code);
    WSH_DEBUG_SV.log(l_module_name,'p_carrier_name', p_carrier_name);
    WSH_DEBUG_SV.log(l_module_name,'x_carrier_id', x_carrier_id);
    WSH_DEBUG_SV.log(l_module_name,'x_service_level', x_service_level);
    WSH_DEBUG_SV.log(l_module_name,'x_mode_of_transport', x_mode_of_transport);
    WSH_DEBUG_SV.log(l_module_name,'p_organization_id', p_organization_id);
    WSH_DEBUG_SV.log(l_module_name,'p_entity_id', p_entity_id);
    WSH_DEBUG_SV.log(l_module_name,'p_entity_type', p_entity_type);
    --
  END IF;
  --
  IF p_entity_type IS NULL
  OR p_entity_type NOT IN ( 'TRIP','DLVY')
  THEN
    --
    FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_ENTITY_TYPE');
    FND_MESSAGE.SET_TOKEN('ENT_TYPE', p_entity_type);
    x_return_status := wsh_util_core.g_ret_sts_error;
    wsh_util_core.add_message(x_return_status,l_module_name);
    RAISE FND_API.G_EXC_ERROR;
    --
  END IF;
  --
  --
  --bug 3616738 if caller is TP Release look it up
  IF (p_caller IN ('WSH_FSTRX', 'WSH_TP_RELEASE', 'FTE_ROUTING_GUIDE')) AND (p_ship_method_name IS NULL) THEN
     IF p_entity_type = 'DLVY' THEN
        OPEN l_dlvy_carrier_services_csr;
        FETCH l_dlvy_carrier_services_csr INTO x_ship_method_code;
        CLOSE l_dlvy_carrier_services_csr;
     ELSE
        OPEN l_trip_carrier_services_csr;
        FETCH l_trip_carrier_services_csr INTO x_ship_method_code;
        CLOSE l_trip_carrier_services_csr;
     END IF;
  END IF;

  IF p_entity_type = 'DLVY' THEN
    --
    open  l_dlvy_car_shp_mthd_csr(p_entity_id);
    fetch l_dlvy_car_shp_mthd_csr into l_carrier_id,
                                       l_service_level,
                                       l_mode_of_transport,
                                       l_ship_method_code;
    close l_dlvy_car_shp_mthd_csr;
    --
  ELSE -- p_entity_type = 'TRIP' THEN
    --
    open  l_trip_car_shp_mthd_csr(p_entity_id);
    fetch l_trip_car_shp_mthd_csr into l_carrier_id,
                                       l_service_level,
                                       l_mode_of_transport,
                                       l_ship_method_code;
    close l_trip_car_shp_mthd_csr;
    --
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.log(l_module_name,'l_carrier_id', l_carrier_id);
    WSH_DEBUG_SV.log(l_module_name,'l_service_level', l_service_level);
    WSH_DEBUG_SV.log(l_module_name,'l_mode_of_transport', l_mode_of_transport);
    --
  END IF;
  --
  validate_ship_method(
    p_ship_method_code   => x_ship_method_code,
    p_ship_method_name   => p_ship_method_name,
    x_return_status      => l_return_status);
  --
  IF (x_ship_method_code IS NULL ) THEN
    l_sm_is_null := TRUE;
  END IF;
  l_ship_method_code_backup := x_ship_method_code;
  --
  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_ship_method',l_return_status);
  END IF;
  --
  WSH_UTIL_CORE.api_post_call(
    p_return_status     => l_return_status,
    x_num_warnings      => l_num_warnings,
    x_num_errors        => l_num_errors);
  --
  validate_carrier(
    p_carrier_name      => p_carrier_name,
    x_carrier_id        => x_carrier_id,
    x_return_status     => l_return_status);
  --
  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_carrier',l_return_status);
  END IF;
  --
  WSH_UTIL_CORE.api_post_call(
    p_return_status     => l_return_status,
    x_num_warnings      => l_num_warnings,
    x_num_errors        => l_num_errors);
  --
  -- If the either one of carrier, service level or mode of transport is changed
  -- we need to nullify the Ship Method to keep the Pubic API behaviour
  -- in SYNC with the STF.
  IF nvl(l_carrier_id,fnd_api.g_miss_num)         <> nvl(x_carrier_id,fnd_api.g_miss_num)
  or nvl(l_service_level,fnd_api.g_miss_char)     <> nvl(x_service_level,fnd_api.g_miss_char)
  or nvl(l_mode_of_transport,fnd_api.g_miss_char) <> nvl(x_mode_of_transport,fnd_api.g_miss_char)
  THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Ship Method is being Nullified 1');
    END IF;
    x_ship_method_code := NULL;
    p_ship_method_name := NULL;
  END IF;

  IF nvl(x_service_level, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
    --
    validate_lookup(
      p_lookup_type   => 'WSH_SERVICE_LEVELS',
      p_lookup_code   => x_service_level,
      p_meaning       => l_dummy_meaning,
      x_return_status => l_return_status);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_lookup for service_level',l_return_status);
    END IF;
    --
    WSH_UTIL_CORE.api_post_call(
      p_return_status     => l_return_status,
      x_num_warnings      => l_num_warnings,
      x_num_errors        => l_num_errors);
    --
    --
  END IF;
  --
  --
  IF nvl(x_mode_of_transport, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
    --
    validate_lookup(
      p_lookup_type   => 'WSH_MODE_OF_TRANSPORT',
      p_lookup_code   => x_mode_of_transport,
      p_meaning       => l_dummy_meaning,
      x_return_status => l_return_status);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_lookup for mode_of_transport',l_return_status);
    END IF;
    --
    WSH_UTIL_CORE.api_post_call(
      p_return_status     => l_return_status,
      x_num_warnings      => l_num_warnings,
      x_num_errors        => l_num_errors);
    --
    --
  END IF;
  --
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.log(l_module_name,'x_ship_method_code', x_ship_method_code);
    WSH_DEBUG_SV.log(l_module_name,'x_carrier_id', x_carrier_id);
    WSH_DEBUG_SV.log(l_module_name,'x_service_level', x_service_level);
    WSH_DEBUG_SV.log(l_module_name,'x_mode_of_transport', x_mode_of_transport);
    --
  END IF;
  --
  IF l_sm_is_null = TRUE
   AND NVL(l_carrier_id,fnd_api.G_MISS_NUM) =
                                      NVL(x_carrier_id,fnd_api.G_MISS_NUM)
   AND NVL(l_service_level,fnd_api.G_MISS_CHAR) =
                                      NVL(x_service_level,fnd_api.G_MISS_CHAR)
   AND NVL(l_mode_of_transport,fnd_api.G_MISS_CHAR) =
                                    NVL(x_mode_of_transport,fnd_api.G_MISS_CHAR)
  THEN
     IF l_ship_method_code IS NOT NULL THEN
        p_ship_method_name := NULL;
        x_ship_method_code := NULL;
        x_carrier_id := NULL;
        x_service_level := NULL;
        x_mode_of_transport := NULL;
     END IF;
-- Following Code is Commented for Bug 4000931
-- Start of Comment for Bug 4000931
/******
  ELSIF l_sm_is_null = FALSE
   AND NVL(l_carrier_id,fnd_api.G_MISS_NUM) =
                                      NVL(x_carrier_id,fnd_api.G_MISS_NUM)
   AND NVL(l_service_level,fnd_api.G_MISS_CHAR) =
                                      NVL(x_service_level,fnd_api.G_MISS_CHAR)
   AND NVL(l_mode_of_transport,fnd_api.G_MISS_CHAR) =
                                    NVL(x_mode_of_transport,fnd_api.G_MISS_CHAR)
   AND (WSH_UTIL_CORE.FTE_IS_INSTALLED <> 'Y') THEN
     --
     x_return_status := wsh_util_core.g_ret_sts_success;
     IF l_debug_on THEN
        --
        WSH_DEBUG_SV.logmsg(l_module_name,'FTE not installed' );
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN;
******/
-- End of Comment for Bug 4000931
  ELSIF  nvl(x_ship_method_code,fnd_api.g_miss_char) <> fnd_api.g_miss_char
  AND nvl(l_ship_method_code,fnd_api.g_miss_char) <>
      nvl(x_ship_method_code,fnd_api.g_miss_char)
  THEN
    --
    IF p_entity_type = 'DLVY' THEN
      --
      IF p_caller='WSH_TP_RELEASE' THEN
        open  l_dlvy_ship_method_code_csr_tp;
        fetch l_dlvy_ship_method_code_csr_tp into x_carrier_id,
                                             x_service_level,
                                             x_mode_of_transport;
        --
        IF l_dlvy_ship_method_code_csr_tp%NOTFOUND THEN
          close l_dlvy_ship_method_code_csr_tp;
          FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_SHIP_METHOD');
          x_return_status := wsh_util_core.g_ret_sts_error;
          wsh_util_core.add_message(x_return_status,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        close l_dlvy_ship_method_code_csr_tp;
      ELSE
        open  l_dlvy_ship_method_code_csr;
        fetch l_dlvy_ship_method_code_csr into x_carrier_id,
                                             x_service_level,
                                             x_mode_of_transport;
        --
        IF l_dlvy_ship_method_code_csr%NOTFOUND THEN
          close l_dlvy_ship_method_code_csr;
          FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_SHIP_METHOD');
          x_return_status := wsh_util_core.g_ret_sts_error;
          wsh_util_core.add_message(x_return_status,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        close l_dlvy_ship_method_code_csr;
      END IF;
      --
    ELSE  -- p_entity_type = 'TRIP'
      --
      open  l_trip_ship_method_code_csr;
      fetch l_trip_ship_method_code_csr into x_carrier_id,
                                             x_service_level,
                                             x_mode_of_transport;
      --
      IF l_trip_ship_method_code_csr%NOTFOUND THEN
        close l_trip_ship_method_code_csr;
        FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_SHIP_METHOD');
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status,l_module_name);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      close l_trip_ship_method_code_csr;
      --
    END IF;
    --
  ELSIF nvl(x_carrier_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
  AND nvl(x_service_level,fnd_api.g_miss_char) <> fnd_api.g_miss_char
  AND nvl(x_mode_of_transport,fnd_api.g_miss_char) <> fnd_api.g_miss_char
  THEN
    --
    IF p_entity_type = 'DLVY' THEN
      --
      IF p_caller='WSH_TP_RELEASE' THEN
        open  l_dlvy_carrier_services_csr_tp;
        fetch l_dlvy_carrier_services_csr_tp into x_ship_method_code;
        IF l_dlvy_carrier_services_csr_tp%NOTFOUND THEN
          close l_dlvy_carrier_services_csr_tp;
          FND_MESSAGE.SET_NAME('WSH','WSH_NO_SHIP_METHOD_FOR_CS');
          x_return_status := wsh_util_core.g_ret_sts_warning;
          wsh_util_core.add_message(x_return_status,l_module_name);
          RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        END IF;
        --
        close l_dlvy_carrier_services_csr_tp;
      ELSE
        open  l_dlvy_carrier_services_csr;
        fetch l_dlvy_carrier_services_csr into x_ship_method_code;
        IF l_dlvy_carrier_services_csr%NOTFOUND THEN
          close l_dlvy_carrier_services_csr;
          FND_MESSAGE.SET_NAME('WSH','WSH_NO_SHIP_METHOD_FOR_CS');
          x_return_status := wsh_util_core.g_ret_sts_warning;
          wsh_util_core.add_message(x_return_status,l_module_name);
          RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        END IF;
        --
        close l_dlvy_carrier_services_csr;
      END IF;
      --
    ELSE  -- p_entity_type = 'TRIP'
      --
      open  l_trip_carrier_services_csr;
      fetch l_trip_carrier_services_csr into x_ship_method_code;
      IF l_trip_carrier_services_csr%NOTFOUND THEN
        close l_trip_carrier_services_csr;
        FND_MESSAGE.SET_NAME('WSH','WSH_NO_SHIP_METHOD_FOR_CS');
        x_return_status := wsh_util_core.g_ret_sts_warning;
        wsh_util_core.add_message(x_return_status,l_module_name);
        RAISE WSH_UTIL_CORE.G_EXC_WARNING;
      END IF;
      --
      close l_trip_carrier_services_csr;
      --
    END IF;
    --
    validate_ship_method(
      p_ship_method_code   => x_ship_method_code,
      p_ship_method_name   => p_ship_method_name,
      x_return_status      => l_return_status);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_ship_method Name',l_return_status);
    END IF;
    --
    WSH_UTIL_CORE.api_post_call(
      p_return_status     => l_return_status,
      x_num_warnings      => l_num_warnings,
      x_num_errors        => l_num_errors);
    --
  ELSIF nvl(x_carrier_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
  THEN
    --
    IF p_entity_type = 'DLVY' THEN
      --
      open  l_dlvy_carrier_services_csr;
      fetch l_dlvy_carrier_services_csr into x_ship_method_code;
      close l_dlvy_carrier_services_csr;
      --
    ELSE  -- p_entity_type = 'TRIP'
      --
      open  l_trip_carrier_services_csr;
      fetch l_trip_carrier_services_csr into x_ship_method_code;
      close l_trip_carrier_services_csr;
      --
    END IF;
    --
    validate_ship_method(
      p_ship_method_code   => x_ship_method_code,
      p_ship_method_name   => p_ship_method_name,
      x_return_status      => l_return_status);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_ship_method Name',l_return_status);
    END IF;
    --
    WSH_UTIL_CORE.api_post_call(
      p_return_status     => l_return_status,
      x_num_warnings      => l_num_warnings,
      x_num_errors        => l_num_errors);
    --
  END IF;

  -- Bug 4086855
  -- If the trip's mode is PARCEL or LTL, the trip can have at most two
  -- stops (linked stops are counted as one stop in this case).

  IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y')
  AND (p_entity_type = 'TRIP') AND (x_mode_of_transport in ('LTL', 'PARCEL')) THEN

      OPEN l_trip_stop_count(p_entity_id);
      FETCH l_trip_stop_count INTO l_stop_count;
      CLOSE l_trip_stop_count;

      IF l_stop_count = 3 THEN

         l_trip_name := WSH_TRIPS_PVT.Get_Name(p_entity_id);
         FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_MOT_STOP_COUNT');
         FND_MESSAGE.SET_TOKEN('TRIP_NAME', l_trip_name);
         x_return_status := wsh_util_core.g_ret_sts_error;
         wsh_util_core.add_message(x_return_status,l_module_name);
         RAISE FND_API.G_EXC_ERROR;

      END IF;
  END IF;
  --

  --
  --
  -- Fix for bug 4310011(OTM R12, glog proj)
  -- Do not show this warning message for FTE
  IF p_caller NOT LIKE 'FTE%' THEN

    IF NVL(l_ship_method_code_backup,fnd_api.G_MISS_CHAR) <>
      NVL(x_ship_method_code,fnd_api.G_MISS_CHAR) THEN
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,'Ship method calculated is different');
      END IF;
      FND_MESSAGE.SET_NAME('WSH','WSH_SHIP_METHOD_CHANGE');
      FND_MESSAGE.SET_TOKEN('ORIG_SM', l_ship_method_code_backup);
      FND_MESSAGE.SET_TOKEN('CALC_SM', x_ship_method_code);
      x_return_status := wsh_util_core.g_ret_sts_warning;
      wsh_util_core.add_message(x_return_status,l_module_name);
     END IF;

  END IF;

  x_return_status := wsh_util_core.g_ret_sts_success;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    wsh_util_core.default_handler('WSH_UTIL_VALIDATE.VALIDATE_FREIGHT_CARRIER');
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
    --
  WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNIN
G');
    END IF;
    --
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_UTIL_VALIDATE.VALIDATE_FREIGHT_CARRIER');
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END Validate_Freight_Carrier;
-- I Harmonization: rvishnuv *******

    -- ---------------------------------------------------------------------
    -- Procedure:	Find_Item_Type
    --
    -- Parameters:
    --
    -- Description:  This procedure gives the item type (either container_item or vehicle_item) for the given
    --                 inventory item id and organization id.
    -- Created:   Harmonization Project. Patchset I. KVENKATE
    -- -----------------------------------------------------------------------
PROCEDURE Find_Item_Type(
          p_inventory_item_id  IN  NUMBER,
          p_organization_id    IN  NUMBER,
          x_item_type          OUT NOCOPY VARCHAR2,
          x_return_status      OUT NOCOPY VARCHAR2)

IS

   l_container_item_flag   VARCHAR2(1);
   l_shippable_flag        VARCHAR2(1);
   l_vehicle_item_flag     VARCHAR2(1);
   l_wms_org               VARCHAR2(1) := 'N';

   CURSOR veh_cont_item_cur(l_item_id NUMBER, l_organization_id NUMBER) IS
      SELECT container_item_flag, shippable_item_flag, vehicle_item_flag
      FROM   mtl_system_items
      WHERE inventory_item_id = l_item_id AND
            organization_id = l_organization_id;

   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FIND_ITEM_TYPE';
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
          --
          WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     OPEN veh_cont_item_cur(p_inventory_item_id, p_organization_id);
     FETCH veh_cont_item_cur INTO
           l_container_item_flag, l_shippable_flag, l_vehicle_item_flag;
          IF veh_cont_item_cur%NOTFOUND THEN
             CLOSE veh_cont_item_cur;
             FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ITEM');
             RAISE FND_API.G_EXC_ERROR;
          END IF;
     CLOSE veh_cont_item_cur;

     l_wms_org := wsh_util_validate.Check_Wms_Org(p_organization_id);

     IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_wms_org',l_wms_org);
     END IF;

     IF(nvl(l_vehicle_item_flag, 'N') = 'Y') THEN
        x_item_type := 'VEH_ITEM';
     ELSIF (    l_container_item_flag = 'Y'
            AND NVL(l_vehicle_item_flag, 'N') = 'N'
            AND (( l_shippable_flag = 'Y' AND l_wms_org = 'N' )
                OR (l_wms_org = 'Y'))) THEN
        x_item_type := 'CONT_ITEM';
     END IF;

      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status,l_module_name);
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;

  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_UTIL_VALIDATE.FIND_ITEM_TYPE');
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Find_Item_Type;
-- I Harmonization: KVENKATE

  FUNCTION Get_Org_Type (
             p_organization_id   IN   NUMBER,
             p_event_key         IN   VARCHAR2 DEFAULT NULL,
             p_delivery_id       IN   NUMBER DEFAULT NULL,
             p_delivery_detail_id IN  NUMBER DEFAULT NULL,
             p_msg_display        IN  VARCHAR2 DEFAULT 'Y',
             x_return_status     OUT NOCOPY   VARCHAR2
	     ) RETURN VARCHAR2
  IS
    --
    l_return_status VARCHAR2(1);
    l_wms_installed VARCHAR2(10);
    l_org_type VARCHAR2(32767);
    l_org_type_wms VARCHAR2(32767);
    --
    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ORG_TYPE';
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
      wsh_debug_sv.push(l_module_name, 'Get_Org_Type');
      wsh_debug_sv.log (l_module_name,'Organization id', p_organization_id);
    END IF;

    l_org_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type (
                    p_organization_id    => p_organization_id,
                    p_event_key          => p_event_key,
                    x_return_status      => l_return_status,
                    p_delivery_id        => p_delivery_id,
                    p_delivery_detail_id => p_delivery_detail_id,
                    p_msg_display        => p_msg_display);

    IF l_return_status = wsh_util_core.g_ret_sts_error THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF l_return_status = wsh_util_core.g_ret_sts_unexp_error THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_wms_installed := wsh_util_validate.Check_Wms_Org(p_organization_id);

    IF l_wms_installed = 'Y' THEN
      l_org_type_wms := 'WMS';
    END IF;

    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'l_org_type', l_org_type);
      wsh_debug_sv.log (l_module_name,'l_org_type_wms', l_org_type_wms);
    END IF;

    IF l_org_type IS NULL THEN
      l_org_type := l_org_type_wms;
    ELSIF l_org_type_wms IS NOT NULL THEN
      l_org_type := l_org_type || '.' || l_org_type_wms;
    END IF;

    x_return_status := wsh_util_core.g_ret_sts_success;

    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name, 'Get_Org_Type');
    END IF;

    RETURN l_org_type;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      RETURN l_org_type;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      RETURN l_org_type;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      RETURN l_org_type;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_UTIL_VALIDATE.GET_ORG_TYPE');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      RETURN l_org_type;
      --
  END Get_Org_Type;


--========================================================================
-- PROCEDURE : get_item_info
--
-- PARAMETERS: p_organization_id       Item's Organization Id
--             p_inventory_item_id     Inventory Item Id
--             x_Item_info_rec         stores the item information
--             x_return_status         return status
-- COMMENT   : This API manages a cache, which contains item information
--             The information on the cached is retrieved based on the
--             organization id and inventory id.  If this information does not
--             exist in the cache, it will be queried and added to it.
--             If there is a collision in the cache, then the new information
--             will be retrieved and will replace the old ones
--========================================================================


  PROCEDURE get_item_info (
                                 p_organization_id IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
                                 x_Item_info_rec OUT NOCOPY
                                                          item_info_rec_type,
                                 x_return_status OUT NOCOPY VARCHAR2)
  IS

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
                'GET_ITEM_INFO';
  --
   l_hash_string VARCHAR2(1000);
   l_hash_value  NUMBER;
   l_Item_info_rec  item_info_rec_type;
   l_cache_hit      BOOLEAN := FALSE;

   CURSOR c_inventory_item_info(v_inventory_item_id number,
                                v_organization_id number) is
      SELECT  primary_uom_code,
         description,
         hazard_class_id,
         weight_uom_code,
         unit_weight,
         volume_uom_code,
         unit_volume
      FROM mtl_system_items
      WHERE inventory_item_id = v_inventory_item_id
      AND   organization_id  = v_organization_id;

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
        --
        WSH_DEBUG_SV.log(l_module_name,'p_organization_id',p_organization_id);
        WSH_DEBUG_SV.log(l_module_name,'p_inventory_item_id',
                                                         p_inventory_item_id);
     END IF;
     --
     IF (p_organization_id IS NULL ) OR (p_inventory_item_id IS NULL )THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     l_hash_string := p_organization_id || '-'||p_inventory_item_id;
     l_hash_value := dbms_utility.get_hash_value(
                                  name => l_hash_string,
                                  base => c_hash_base,
                                  hash_size =>c_hash_size );

     IF  G_ITEM_INFO_TAB.exists(l_hash_value) THEN --{
       IF G_ITEM_INFO_TAB(l_hash_value).organization_id = p_organization_id
         AND G_ITEM_INFO_TAB(l_hash_value).inventory_item_id
                                                      = p_inventory_item_id
       THEN --{
          x_Item_info_rec := G_ITEM_INFO_TAB(l_hash_value);
          l_cache_hit := TRUE;

          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'hit ');
          END IF;

       END IF; --}

     END IF; --}

     IF NOT l_cache_hit THEN --{
        OPEN c_inventory_item_info(p_inventory_item_id, p_organization_id);
        FETCH c_inventory_item_info INTO
          l_Item_info_rec.primary_uom_code,
          l_Item_info_rec.description,
          l_Item_info_rec.hazard_class_id,
          l_Item_info_rec.weight_uom_code,
          l_Item_info_rec.unit_weight,
          l_Item_info_rec.volume_uom_code,
          l_Item_info_rec.unit_volume;

          IF c_inventory_item_info%NOTFOUND THEN
             CLOSE c_inventory_item_info;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          CLOSE c_inventory_item_info;

          l_Item_info_rec.organization_id := p_organization_id;
          l_Item_info_rec.inventory_item_id := p_inventory_item_id;

          x_Item_info_rec := l_Item_info_rec;
          G_ITEM_INFO_TAB(l_hash_value) := l_Item_info_rec;

     END IF; --}

     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'primary_uom_code',
                                      x_Item_info_rec.primary_uom_code);
        WSH_DEBUG_SV.log(l_module_name, 'description',
                                      x_Item_info_rec.description);
        WSH_DEBUG_SV.log(l_module_name, 'hazard_class_id',
                                      x_Item_info_rec.hazard_class_id);
        WSH_DEBUG_SV.log(l_module_name, 'weight_uom_code',
                                      x_Item_info_rec.weight_uom_code);
        WSH_DEBUG_SV.log(l_module_name, 'unit_weight',
                                      x_Item_info_rec.unit_weight);
        WSH_DEBUG_SV.log(l_module_name, 'volume_uom_code',
                                            x_Item_info_rec.volume_uom_code);
        WSH_DEBUG_SV.log(l_module_name, 'unit_volume',
                                            x_Item_info_rec.unit_volume);
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
  EXCEPTION

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
      wsh_util_core.default_handler('WSH_UTIL_CORE.GET_ITEM_INFO');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
           'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;


  END get_item_info;

--========================================================================
-- PROCEDURE : Default_container
--
-- PARAMETERS: p_item_id                  Item's Organization Id
--             x_master_container_item_id default value for master container
--             x_detail_container_item_id default value for detail container
--             x_return_status         return status
-- COMMENT   : This API calculates the default value for the fields
--             detail_container_item_id and master_container_item_id.  It then
--             caches these values for future calls.
--========================================================================

  PROCEDURE Default_container (
                                 p_item_id                  IN NUMBER,
                                 x_master_container_item_id OUT NOCOPY NUMBER,
                                 x_detail_container_item_id OUT NOCOPY NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2)
  IS
     l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                 || 'DEFAULT_CONTAINER';
     l_cache_hit      BOOLEAN := FALSE;
     i                NUMBER;

     CURSOR c_default_container(l_customer_item_id NUMBER) IS
       SELECT master_container_item_id,
              detail_container_item_id
       FROM  mtl_customer_items
       WHERE customer_item_id = l_customer_item_id;
  --

  BEGIN
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'p_item_id',p_item_id);
     END IF;
     --
     IF p_item_id IS NULL THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF p_item_id < C_IDX_LIMT THEN --{

        IF G_DEF_CONT_INF_TAB.EXISTS(p_item_id) THEN
           x_master_container_item_id :=
                 G_DEF_CONT_INF_TAB(p_item_id).master_container_item_id;
           x_detail_container_item_id :=
                G_DEF_CONT_INF_TAB(p_item_id).detail_container_item_id;
           l_cache_hit := TRUE;

        END IF;
     ELSE --}{

        i := G_DEF_CONT_INFO_EXT_TAB.FIRST;
        WHILE i IS NOT NULL LOOP
           IF G_DEF_CONT_INFO_EXT_TAB(i).key = p_item_id THEN
              l_cache_hit := TRUE;
              x_master_container_item_id :=
                          G_DEF_CONT_INFO_EXT_TAB(i).master_container_item_id;
              x_detail_container_item_id :=
                          G_DEF_CONT_INFO_EXT_TAB(i).detail_container_item_id;
              EXIT;
           END IF;
           i := G_DEF_CONT_INFO_EXT_TAB.NEXT(i);
        END LOOP;

      END IF; --}
      IF NOT l_cache_hit THEN --{

         OPEN c_default_container(p_item_id);
         FETCH c_default_container INTO x_master_container_item_id,
                                        x_detail_container_item_id;
         CLOSE c_default_container;

         IF p_item_id < C_IDX_LIMT THEN
           G_DEF_CONT_INF_TAB(p_item_id).master_container_item_id :=
                                                    x_master_container_item_id;
           G_DEF_CONT_INF_TAB(p_item_id).detail_container_item_id :=
                                                    x_detail_container_item_id;
         ELSE
           i := G_DEF_CONT_INFO_EXT_TAB.COUNT;
           G_DEF_CONT_INFO_EXT_TAB(i+1).master_container_item_id :=
                                                   x_master_container_item_id;
           G_DEF_CONT_INFO_EXT_TAB(i+1).detail_container_item_id :=
                                                   x_detail_container_item_id;
           G_DEF_CONT_INFO_EXT_TAB(i+1).key := p_item_id;
         END IF;
      ELSE --}{
         IF l_debug_on THEN
            --
            WSH_DEBUG_SV.logmsg(l_module_name,'hit ');
            --
         END IF;
      END IF; --}


     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'x_master_container_item_id',
                                       x_master_container_item_id);
         WSH_DEBUG_SV.log(l_module_name, 'x_detail_container_item_id',
                                       x_detail_container_item_id);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;

  EXCEPTION
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
        wsh_util_core.default_handler('WSH_UTIL_CORE.DEFAULT_CONTAINER');
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
             'Oracle error message is '||
             SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
        END IF;

  END Default_container;


--========================================================================
-- PROCEDURE : Calc_ignore_for_planning
--
-- PARAMETERS: p_organization_id
--             p_carrier_id
--             p_ship_method_code
--             p_tp_installed
--             x_return_status         return status
--             p_otm_installed         optional parameter to pass shipping
--                                     parameter OTM_INSTALLED
--             p_client_id             clientId value. Consider OTM enabled value on Client.
--
-- COMMENT   : This procedure calulates the value for the field
--             ignore_for_planning_flag
--           : Added the new parameter p_otm_installed.
--========================================================================

  PROCEDURE Calc_ignore_for_planning(
                        p_organization_id IN NUMBER,
                        p_carrier_id   IN  NUMBER,
                        p_ship_method_code    IN  VARCHAR2,
                        p_tp_installed        IN  VARCHAR2,
                        p_caller              IN  VARCHAR2,
                        x_ignore_for_planning OUT NOCOPY VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2,
                        p_otm_installed       IN  VARCHAR2,  --OTM R12 Org-Specific
                        p_client_id           IN  NUMBER DEFAULT NULL)  -- LSP PROJECT
  IS
    l_debug_on BOOLEAN;
    --
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'CALC_IGNORE_FOR_PLANNING';
    l_hash_string  VARCHAR2(1000);
    l_hash_value   NUMBER;
    l_wh_type      VARCHAR2(100);
    l_return_status  VARCHAR2(1);
    l_hit           boolean := FALSE;
    --OTM R12 Org-Specific
    l_shipping_param_info  WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

  BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_organization_id',p_organization_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_carrier_id',p_carrier_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_ship_method_code',p_ship_method_code);
      WSH_DEBUG_SV.log(l_module_name, 'p_ship_method_code',p_ship_method_code);
      WSH_DEBUG_SV.log(l_module_name, 'p_caller',p_caller);
      WSH_DEBUG_SV.log(l_module_name, 'p_tp_installed',p_tp_installed);
      WSH_DEBUG_SV.log(l_module_name, 'p_otm_installed',p_otm_installed);  --OTM R12 Org-Specific
      WSH_DEBUG_SV.log(l_module_name, 'p_client_id',p_client_id);  -- LSP PROJECT
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     IF p_caller = 'PO' THEN --{
       x_ignore_for_planning := 'Y';
     ELSIF p_otm_installed = 'Y' then --{ --OTM R12 Start Org-Specific
     --{
         WSH_SHIPPING_PARAMS_PVT.Get(
             p_organization_id => p_organization_id,
             p_client_id       => p_client_id, -- LSP PROJECT
             x_param_info      => l_shipping_param_info,
             x_return_status   => l_return_status);
             IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'After call to WSH_SHIPPING_PARAMS_PVT.Get l_return_status '
                           ,l_return_status);
                 WSH_DEBUG_SV.log(l_module_name,'l_shipping_param_info.otm_enabled '
                           ,l_shipping_param_info.otm_enabled);
             END IF;
             IF (l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,
                               WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                  Raise FND_API.G_EXC_ERROR;
             END IF;
             IF l_shipping_param_info.otm_enabled = 'Y' THEN
                 x_ignore_for_planning := 'N';
             ELSE
                 x_ignore_for_planning := 'Y';
             END IF;

     --} --OTM R12 End
     ELSIF p_tp_installed = 'Y'THEN --}{
       l_hash_string := p_organization_id ||'-'|| p_carrier_id||
                             '-'|| p_ship_method_code  ;
       l_hash_value := dbms_utility.get_hash_value(
                                  name => l_hash_string,
                                  base => c_hash_base,
                                  hash_size =>c_hash_size );

       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_hash_value ',l_hash_value);
       END IF;
       IF G_IGNORE_PLAN_TAB.EXISTS(l_hash_value) THEN --{
          IF G_IGNORE_PLAN_TAB(l_hash_value).organization_id = p_organization_id
           AND NVL(G_IGNORE_PLAN_TAB(l_hash_value).carrier_id,-22) =
                  NVL(p_carrier_id, -22)
           AND NVL(G_IGNORE_PLAN_TAB(l_hash_value).ship_method_code, -22) =
                  NVL(p_ship_method_code,-22)
          THEN  --{
             x_ignore_for_planning :=
                          G_IGNORE_PLAN_TAB(l_hash_value).ignore_for_planning;
             l_hit := TRUE;
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'hit ',x_ignore_for_planning);
             END IF;
          END IF; --}
        END IF; --}
       IF (NOT l_hit) THEN --{
          l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
                      (p_organization_id  => p_organization_id,
                       x_return_status    => l_return_status,
                       p_carrier_id         => p_carrier_id,
                       p_ship_method_code   => p_ship_method_code,
                       p_msg_display        => 'N'
                       );
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_wh_type,l_return_status',
                                                    l_wh_type||l_return_status);
          END IF;
          IF (nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS')) THEN
             x_ignore_for_planning:='Y';
          ELSE
             x_ignore_for_planning:='N';
          END IF;
          G_IGNORE_PLAN_TAB(l_hash_value).ignore_for_planning :=
                                                    x_ignore_for_planning;
          G_IGNORE_PLAN_TAB(l_hash_value).organization_id :=
                                                    p_organization_id;
          G_IGNORE_PLAN_TAB(l_hash_value).carrier_id := p_carrier_id;
          G_IGNORE_PLAN_TAB(l_hash_value).ship_method_code :=
                                                    p_ship_method_code;

       END IF; --}
     ELSE --}{
        x_ignore_for_planning := 'N';
     END IF; --}
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name,x_ignore_for_planning);
     END IF;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN --{ --OTM R12 Start
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has '
                             || 'occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF; --} --OTM R12 End
      WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
         wsh_util_core.default_handler('WSH_UTIL_CORE.DEFAULT_CONTAINER');
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
              'Oracle error message is '||
              SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
         END IF;
  END Calc_ignore_for_planning;

-- Added for Inbound Logistics
-- Start of comments
-- API name : VALIDATE_FOB
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API is used to check whether the FOB supplied as the
--	       parameter is present in the AR lookups.If it is not present
--	       it creates the FOB under AR lookups.
--             Lookup type is 'FOB' in AR_LOOKUPS
-- Parameters :
-- IN:
--    p_fob 		IN	   VARCHAR2
-- IN OUT:
-- OUT:
--    x_return_status	OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

  PROCEDURE validate_fob(
    p_fob 		IN	   VARCHAR2,
    x_return_status	OUT NOCOPY VARCHAR2) IS

  --Cursor to determine whether the given look up code is present in ar lookups.
  Cursor c_fob(p_lookup_code VARCHAR2) IS
  SELECT 1
  FROM
  ar_lookups
  WHERE
  lookup_type = 'FOB'          AND
  lookup_code =  p_lookup_code AND
  nvl(start_date_active,SYSDATE)  <=  SYSDATE  AND
  nvl(end_date_active,SYSDATE)    >=  SYSDATE  AND
  enabled_flag = 'Y';

  --Cursor to get the meaning and description of a look up code.
  Cursor c_po_fob (p_lookup_code VARCHAR2) IS
  SELECT meaning,description
  from FND_LOOKUP_VALUES_VL
  where lookup_code = p_lookup_code AND
  lookup_type = 'FOB'               AND
  nvl(start_date_active,SYSDATE)  <= SYSDATE  AND
  nvl(end_date_active,SYSDATE)    >= SYSDATE  AND
  enabled_flag = 'Y'AND
  view_application_id = 201;

  l_fob 		NUMBER;
  l_meaning 	VARCHAR2(80);
  l_desc   	VARCHAR2(240);
  l_rowid   	VARCHAR2(30);

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_FOB';
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
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
  --
     WSH_DEBUG_SV.log(l_module_name,'P_FOB',P_FOB);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  OPEN  c_fob(p_fob);
  FETCH c_fob INTO l_fob;

  -- If True -> the given FOB is not in AR lokups. Then it gets the details of the FOB
  -- from FND lookups and inserts the same into AR lookups.
  IF c_fob%NOTFOUND THEN
    OPEN  c_po_fob(p_fob);
    FETCH c_po_fob INTO l_meaning,l_desc;
    CLOSE c_po_fob;

    FND_LOOKUP_VALUES_PKG.INSERT_ROW(
       X_ROWID 		=> l_rowid,
       X_LOOKUP_TYPE 		=> 'FOB',
       X_SECURITY_GROUP_ID	=> 0,
       X_VIEW_APPLICATION_ID	=> 222,
       X_LOOKUP_CODE 		=> p_fob,
       X_TAG 			=> NULL,
       X_ATTRIBUTE_CATEGORY    => NULL,
       X_ATTRIBUTE1 		=> NULL,
       X_ATTRIBUTE2 		=> NULL,
       X_ATTRIBUTE3 		=> NULL,
       X_ATTRIBUTE4 		=> NULL,
       X_ENABLED_FLAG 		=> 'Y',
       X_START_DATE_ACTIVE     => SYSDATE,
       X_END_DATE_ACTIVE 	=> NULL,
       X_TERRITORY_CODE 	=> NULL,
       X_ATTRIBUTE5 		=> NULL,
       X_ATTRIBUTE6		=> NULL,
       X_ATTRIBUTE7 		=> NULL,
       X_ATTRIBUTE8 		=> NULL,
       X_ATTRIBUTE9		=> NULL,
       X_ATTRIBUTE10 		=> NULL,
       X_ATTRIBUTE11 		=> NULL,
       X_ATTRIBUTE12 		=> NULL,
       X_ATTRIBUTE13 		=> NULL,
       X_ATTRIBUTE14 		=> NULL,
       X_ATTRIBUTE15 		=> NULL,
       X_MEANING 		=> l_meaning,
       X_DESCRIPTION 		=> l_desc,
       X_CREATION_DATE 	=> SYSDATE,
       X_CREATED_BY 		=> FND_GLOBAL.USER_ID,
       X_LAST_UPDATE_DATE 	=> SYSDATE,
       X_LAST_UPDATED_BY 	=> FND_GLOBAL.USER_ID,
       X_LAST_UPDATE_LOGIN 	=> FND_GLOBAL.LOGIN_ID);
  END IF;
  CLOSE c_fob;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      WSH_UTIL_CORE.Default_Handler('WSH_UTIL_VALIDATE.VALIDATE_FOB',l_module_name);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
     --
  END validate_fob;

-- Start of comments
-- API name : VALIDATE_FREIGHT_TERMS
-- Type     : Public
-- Pre-reqs : None.
-- Function :  This API is used to check whether the freight terms supplied
--	       in the parameters is present in the ONT lookups.If it is not
--	       present it creates the same under ONT lookups and allow the
--	       delivery details to be updated.
--             Lookup type is 'FREIGHT_TERMS' in ONT_LOOKUPS
-- Parameters :
-- IN:
--    p_freight_terms_code IN VARCHAR2
-- IN OUT:
-- OUT:
--    x_return_status OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

  PROCEDURE validate_freight_terms(
    p_freight_terms_code IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2 ) IS

  --Cursor to determine whether the given look up code is present in oe lookups.
  Cursor c_freight(p_lookup_code VARCHAR2) IS
  SELECT '1'
  FROM oe_lookups
  WHERE
  lookup_type                          = 'FREIGHT_TERMS' AND
  lookup_code                          = p_lookup_code AND
  nvl(start_date_active,SYSDATE)      <= SYSDATE
  AND nvl(end_date_active,SYSDATE)    >= SYSDATE
  AND enabled_flag 		     = 'Y';

  --Cursor to get the meaning and description of a look up code.
  Cursor c_po_freight (p_lookup_code VARCHAR2) IS
  SELECT meaning,description
  FROM FND_LOOKUP_VALUES_VL
  WHERE
  lookup_type                         = 'FREIGHT TERMS' AND
  lookup_code 			    = p_lookup_code
  AND nvl(start_date_active,SYSDATE) <= SYSDATE
  AND nvl(end_date_active,SYSDATE)   >= SYSDATE
  AND enabled_flag 		    = 'Y'
  AND view_application_id 	    = 201;

  l_fgt 		NUMBER;
  l_meaning 	VARCHAR2(80);
  l_rowid 	VARCHAR2(30);
  l_desc 	VARCHAR2(240);

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_FREIGHT_TERMS';
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
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_TERMS_CODE',P_FREIGHT_TERMS_CODE);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN  c_freight(p_freight_terms_code);
   FETCH c_freight INTO l_fgt;

   -- If true -> the given Freight Term  is not in OE lokups. Then it gets the details of the Freight Term
   -- from FND lookups and inserts the same into OE lookups.
   IF  c_freight%NOTFOUND THEN
     OPEN  c_po_freight(p_freight_terms_code);
     FETCH c_po_freight into l_meaning,l_desc;
     CLOSE c_po_freight;

     FND_LOOKUP_VALUES_PKG.INSERT_ROW(
	X_ROWID 		=> l_rowid,
	X_LOOKUP_TYPE 		=> 'FREIGHT_TERMS',
	X_SECURITY_GROUP_ID	=> 0,
	X_VIEW_APPLICATION_ID 	=> 660,
	X_LOOKUP_CODE 		=> p_freight_terms_code,
	X_TAG 			=> NULL,
	X_ATTRIBUTE_CATEGORY 	=> NULL,
	X_ATTRIBUTE1 		=> NULL,
	X_ATTRIBUTE2 		=> NULL,
	X_ATTRIBUTE3 		=> NULL,
	X_ATTRIBUTE4 		=> NULL,
	X_ENABLED_FLAG 		=> 'Y',
	X_START_DATE_ACTIVE 	=> SYSDATE,
	X_END_DATE_ACTIVE 	=> NULL,
	X_TERRITORY_CODE 	=> NULL,
	X_ATTRIBUTE5 		=> NULL,
	X_ATTRIBUTE6 		=> NULL,
	X_ATTRIBUTE7 		=> NULL,
	X_ATTRIBUTE8 		=> NULL,
	X_ATTRIBUTE9 		=> NULL,
	X_ATTRIBUTE10 		=> NULL,
	X_ATTRIBUTE11 		=> NULL,
	X_ATTRIBUTE12 		=> NULL,
	X_ATTRIBUTE13 		=> NULL,
	X_ATTRIBUTE14 		=> NULL,
	X_ATTRIBUTE15 		=> NULL,
	X_MEANING 		=> l_meaning,
	X_DESCRIPTION 		=> l_desc,
	X_CREATION_DATE 	=> SYSDATE,
	X_CREATED_BY 		=> FND_GLOBAL.USER_ID,
	X_LAST_UPDATE_DATE 	=> SYSDATE,
	X_LAST_UPDATED_BY 	=> FND_GLOBAL.USER_ID,
	X_LAST_UPDATE_LOGIN 	=> FND_GLOBAL.LOGIN_ID);
  END IF;
  CLOSE c_freight;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       WSH_UTIL_CORE.Default_Handler('WSH_UTIL_VALIDATE.VALIDATE_FREIGHT_TERMS',l_module_name);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
 	  WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
  END Validate_freight_terms;

-- J-IB-NPARIKH-{
--
-- ----------------------------------------------------------------------
-- Procedure:   validate_supplier_location
-- Parameters:  p_vendor_id in  number    -- Vendor ID
--              p_party_id  in number     -- Vendor Party ID
--              p_location_id in number   -- Ship from location ID(New value)
--              x_return_status out varchar2 -- Return status of API
--
-- Description: This procedure validates that input location is a valid
--              ship-from location for the input supplier.
--
--  ----------------------------------------------------------------------
PROCEDURE validate_supplier_location
            (
               p_vendor_id      IN           NUMBER,
               p_party_id       IN           NUMBER,
               p_location_id    IN           NUMBER,
               x_return_status  OUT NOCOPY   VARCHAR2
            )
IS
--{
    --
    -- Check that for vendor party, a party site is defined
    -- with usage as SUPPLIER_SHIP_FROM and location same as the input.
    --
    CURSOR locn_csr (p_location_id IN NUMBER, p_party_id IN NUMBER)
    IS
        SELECT 1
        FROM   hz_party_sites hps,
               hz_party_site_uses hpsu
        WHERE  hps.party_id         = p_party_id
        AND    hps.location_id      = p_location_id
        AND    hpsu.party_site_id   = hps.party_site_id
        AND    hpsu.site_use_type   = 'SUPPLIER_SHIP_FROM';
    --
    l_dummy                       NUMBER;
    l_location_name               VARCHAR2(60);
    --
    l_debug_on                    BOOLEAN;
    --
    l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'validate_supplier_location';
    --
--}
BEGIN
--{
    --
    l_debug_on := wsh_debug_interface.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'p_vendor_id', p_vendor_id);
      wsh_debug_sv.LOG(l_module_name, 'p_party_id', p_party_id);
      wsh_debug_sv.LOG(l_module_name, 'p_location_id', p_location_id);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    --
    OPEN locn_csr (p_location_id, p_party_id);
    --
    FETCH locn_csr
    INTO l_dummy;
    --
    IF locn_csr%NOTFOUND
    THEN
    --{

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.get_location_description',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        l_location_name := SUBSTRB(
                                    WSH_UTIL_CORE.get_location_description
                                      (
                                        p_location_id,
                                        'NEW UI CODE'
                                      ),
                                    1,
                                    60
                                  );
        --
        fnd_message.SET_name('WSH', 'WSH_SUPP_LOCN_ERROR');
        FND_MESSAGE.SET_TOKEN('LOCATION_NAME',l_location_name);
        --
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    CLOSE locn_csr;
    --
    --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
    END IF;
    --
--}
EXCEPTION
--{
      --
    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('WSH_UTIL_VALIDATE.validate_supplier_location', l_module_name);
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
--}
END validate_supplier_location;
-- J-IB-NPARIKH-}


--===============================================================================================
-- START Bug #3266659:  PICK RELEASE BATCH PUBLIC API
--==============================================================================================

--========================================================================
-- PROCEDURE : Validate_Pick_Group_Rule_Name
--
-- COMMENT   : Validates Pick_Grouping_Rule_Id/Pick_Grouping_Rule_Name against table
--             wsh_pick_grouping_rules. If both values are specified then only
--             Pick_Grouping_Rule_Id is used
--========================================================================

PROCEDURE Validate_Pick_Group_Rule_Name
        (p_pick_grouping_rule_id      IN   OUT NOCOPY  NUMBER ,
         p_pick_grouping_rule_name    IN   VARCHAR2 ,
         x_return_status        OUT  NOCOPY  VARCHAR2 ) IS

  CURSOR check_pick_grouping_rule_name IS
  SELECT pick_grouping_rule_id
  FROM   wsh_pick_grouping_rules
  WHERE  p_pick_grouping_rule_id IS NOT NULL
  AND    pick_grouping_rule_id = p_pick_grouping_rule_id
  AND trunc(sysdate) BETWEEN nvl(start_date_active,trunc(sysdate)) AND nvl(end_date_active,trunc(sysdate) + 1)
  UNION ALL
  SELECT pick_grouping_rule_id
  FROM   wsh_pick_grouping_rules
  WHERE  p_pick_grouping_rule_id IS  NULL
  AND    name = p_pick_grouping_rule_name
  AND trunc(sysdate) BETWEEN nvl(start_date_active,trunc(sysdate)) AND nvl(end_date_active,trunc(sysdate) + 1);

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_PICK_GROUP_RULE_NAME';
  --
  BEGIN
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL 	THEN
	--{
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	--}
	END IF;
	--
	IF l_debug_on THEN
	--{
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_PICK_GROUPING_RULE_ID',p_pick_grouping_rule_id);
	    WSH_DEBUG_SV.log(l_module_name,'P_PICK_GROUPING_RULE_NAME',p_pick_grouping_rule_name);
        --}
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       IF (p_pick_grouping_rule_id IS NOT NULL) OR (p_pick_grouping_rule_name IS NOT NULL) THEN
       --{
          OPEN  check_pick_grouping_rule_name;
          FETCH check_pick_grouping_rule_name  INTO  p_pick_grouping_rule_id;
          IF (check_pick_grouping_rule_name%NOTFOUND) THEN
	  --{
	     FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Pick Grouping Rule');
	     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	     wsh_util_core.add_message(x_return_status,l_module_name);
          --}
	  END IF;
          CLOSE check_pick_grouping_rule_name;
       --}
       END IF;
       --
       IF l_debug_on THEN
       --{
           WSH_DEBUG_SV.pop(l_module_name);
       --}
       END IF;
       --
  END Validate_Pick_Group_Rule_Name;

--========================================================================
-- PROCEDURE : Validate_Pick_Seq_Rule_Name
--
-- COMMENT   : Validates Pick_Sequence_Rule_Id/Pick_Sequence_Rule_Name against table
--             wsh_pick_sequence_rules. If both values are specified then only
--             Pick_Sequence_Rule_Id is used
--========================================================================

PROCEDURE  Validate_Pick_Seq_Rule_Name
        (p_Pick_Sequence_Rule_Id      IN OUT NOCOPY  NUMBER ,
         p_Pick_Sequence_Rule_Name    IN     VARCHAR2 ,
         x_return_status              OUT NOCOPY     VARCHAR2 ) IS

  CURSOR check_pick_sequence_rule_name IS
  SELECT pick_sequence_rule_id
  FROM   wsh_pick_sequence_rules
  WHERE  p_pick_sequence_rule_id IS NOT NULL
  AND     pick_sequence_rule_id = p_pick_sequence_rule_id
  AND trunc(sysdate) BETWEEN nvl(start_date_active,trunc(sysdate)) AND nvl(end_date_active,trunc(sysdate) + 1)
  UNION ALL
  SELECT pick_sequence_rule_id
  FROM   wsh_pick_sequence_rules
  WHERE  p_pick_sequence_rule_id IS NULL
  AND    name = p_pick_sequence_rule_name
  AND trunc(sysdate) BETWEEN nvl(start_date_active,trunc(sysdate)) AND nvl(end_date_active,trunc(sysdate) + 1);

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_PICK_SEQ_RULE_NAME';
  --
  BEGIN
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL 	THEN
	--{
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	--}
	END IF;
	--
	IF l_debug_on THEN
	--{
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_PICK_SEQUENCE_RULE_ID',p_pick_sequence_rule_id);
	    WSH_DEBUG_SV.log(l_module_name,'P_PICK_SEQUENCE_RULE_NAME',p_pick_sequence_rule_NAME);
	--}
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       IF (p_pick_sequence_rule_id IS NOT NULL) OR (p_pick_sequence_rule_name IS NOT NULL) THEN
       --{
          OPEN  check_pick_sequence_rule_name;
          FETCH check_pick_sequence_rule_name  INTO  p_pick_sequence_rule_id;
          IF (check_pick_sequence_rule_name%NOTFOUND) THEN
	  --{
             FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Pick Sequence Rule');
	     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	     wsh_util_core.add_message(x_return_status,l_module_name);
          --}
          END IF;
          CLOSE check_pick_sequence_rule_name;
       --}
       END IF;
       --
       IF l_debug_on THEN
       --{
           WSH_DEBUG_SV.pop(l_module_name);
       --}
       END IF;
       --
  END Validate_Pick_Seq_Rule_Name;

--========================================================================
-- PROCEDURE : Validate_Ship_Con_Rule_Name
--
-- COMMENT   : Validates Ship_Confirm_Rule_Id/Ship_Confirm_Rule_Name against table
--             wsh_ship_confirm_rules. If both values are specified then only
--             Ship_Confirm_Rule_Id is used
--========================================================================

PROCEDURE  Validate_Ship_Con_Rule_Name
        (p_ship_confirm_rule_id      IN OUT NOCOPY  NUMBER ,
         p_ship_confirm_rule_name    IN     VARCHAR2 ,
         x_return_status              OUT NOCOPY     VARCHAR2 ) IS

  CURSOR check_Ship_Confirm_rule_name IS
  SELECT Ship_Confirm_rule_id
  FROM   wsh_Ship_Confirm_rules
  WHERE  p_Ship_Confirm_rule_id IS NOT NULL
  AND    Ship_Confirm_rule_id = p_Ship_Confirm_rule_id
  AND trunc(sysdate) BETWEEN nvl(effective_start_date,trunc(sysdate)) AND nvl(effective_end_date,trunc(sysdate) + 1)
  UNION ALL
  SELECT Ship_Confirm_rule_id
  FROM   wsh_Ship_Confirm_rules
  WHERE  p_Ship_Confirm_rule_id IS NULL
  AND    name = p_Ship_Confirm_rule_name
  AND trunc(sysdate) BETWEEN nvl(effective_start_date,trunc(sysdate)) AND nvl(effective_end_date,trunc(sysdate) + 1);

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_SHIP_CON_RULE_NAME';
  --
  BEGIN
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL 	THEN
	--{
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	--}
	END IF;
	--
	IF l_debug_on THEN
	--{
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_CONFIRM_RULE_ID',p_ship_confirm_rule_id);
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_CONFIRM_RULE_NAME',p_ship_confirm_rule_name);
	--}
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       IF (p_ship_confirm_rule_id IS NOT NULL) OR (p_ship_confirm_rule_name IS NOT NULL) THEN
       --{
          OPEN  check_ship_confirm_rule_name;
          FETCH check_ship_confirm_rule_name  INTO  p_ship_confirm_rule_id;
          IF (check_ship_confirm_rule_name%NOTFOUND) THEN
	  --{
             FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ship Confirm Rule');
	     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	     wsh_util_core.add_message(x_return_status,l_module_name);
          --}
	  END IF;
          CLOSE check_ship_confirm_rule_name;
       --}
       END IF;
       --
       IF l_debug_on THEN
       --{
           WSH_DEBUG_SV.pop(l_module_name);
       --}
       END IF;
       --
  END Validate_Ship_Con_Rule_Name;


--========================================================================
-- PROCEDURE : Validate_Picking_Batch_Name
--
-- COMMENT   : Validates picking_Batch_Id/Picking_Batch_Name against table
--             wsh_picking_Batches. If both values are specified then only
--             picking_Batch_Id is used
--========================================================================

PROCEDURE  Validate_Picking_Batch_Name
        (p_picking_batch_id      IN OUT NOCOPY  NUMBER ,
         p_picking_batch_name    IN     VARCHAR2 ,
         x_return_status              OUT NOCOPY     VARCHAR2 ) IS

  CURSOR check_picking_batch_name IS
  SELECT batch_id
  FROM   wsh_picking_Batches
  WHERE  p_picking_batch_id IS NOT NULL
  AND    batch_id = p_picking_batch_id
  UNION ALL
  SELECT batch_id
  FROM   wsh_picking_batches
  WHERE  p_picking_batch_id IS NULL
  AND    name = p_picking_batch_name;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_PICKING_BATCH_NAME';
  --
  BEGIN
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL 	THEN
	--{
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	--}
	END IF;
	--
	IF l_debug_on THEN
	--{
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_PICKING_BATCH_ID',p_Picking_Batch_id);
	    WSH_DEBUG_SV.log(l_module_name,'P_PICKING_BATCH_NAME',p_Picking_Batch_name);
	--}
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       IF (p_Picking_Batch_id IS NOT NULL) OR (p_Picking_Batch_name IS NOT NULL) THEN
       --{
          OPEN  check_Picking_Batch_name;
          FETCH check_Picking_Batch_name  INTO  p_Picking_Batch_id;
          IF (check_Picking_Batch_name%NOTFOUND) THEN
	  --{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Picking Batch Name');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status,l_module_name);
          --}
	  END IF;
          CLOSE check_Picking_Batch_name;
       --}
       END IF;
       --
       IF l_debug_on THEN
       --{
           WSH_DEBUG_SV.pop(l_module_name);
       --}
       END IF;
       --
  END Validate_Picking_Batch_Name;
  -- END Bug #3266659

-- Bug#3880569: Adding a new procedure Validate_Active_SM
--========================================================================
-- PROCEDURE : Validate_Active_SM
--
-- COMMENT   : Validates Active Ship_Method_Code/Name against wsh_carrier_services.
--             If both values are specified then only Ship_Method_Code is used
--========================================================================

  PROCEDURE Validate_Active_SM
        (p_ship_method_code     IN OUT NOCOPY VARCHAR2,
         p_ship_method_name     IN OUT NOCOPY VARCHAR2,
         x_return_status        OUT    NOCOPY VARCHAR2) IS

  CURSOR check_ship_method IS
  select flv.lookup_code ship_method_code,
         flv.meaning
  from fnd_lookup_values_vl flv, wsh_carrier_services wcs
  where flv.lookup_code = wcs.ship_method_code
  and wcs.ship_method_code = p_ship_method_code
  and flv.lookup_type = 'SHIP_METHOD'
  and flv.view_application_id = 3
  and wcs.enabled_flag='Y'
  UNION ALL
  select flv.lookup_code ship_method_code,
         flv.meaning
  from fnd_lookup_values_vl flv, wsh_carrier_services wcs
  where flv.lookup_code = wcs.ship_method_code
  and NVL(p_ship_method_code,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
  and flv.lookup_type = 'SHIP_METHOD'
  and flv.view_application_id = 3
  and flv.meaning = p_ship_method_name
  and wcs.enabled_flag='Y' ;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_ACTIVE_SM';
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
      WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_CODE',P_SHIP_METHOD_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_NAME',P_SHIP_METHOD_NAME);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    IF nvl(p_ship_method_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char
    OR nvl(p_ship_method_name, fnd_api.g_miss_char) <> fnd_api.g_miss_char
    THEN
      --
      OPEN  check_ship_method;
      FETCH check_ship_method  INTO  p_ship_method_code, p_ship_method_name;
      --
      IF (check_ship_method%NOTFOUND) THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_OI_INACTIVE_SHIP_METHOD');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status,l_module_name);
      END IF;
      --
      CLOSE check_ship_method;
      --
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'p_ship_method_code',p_ship_method_code);
      WSH_DEBUG_SV.log(l_module_name,'p_ship_method_name',p_ship_method_name);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_UTIL_VALIDATE.Validate_Active_SM');
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
  END Validate_Active_SM;

-- Added new internal procedure for OTM R12, glog project
--========================================================================
-- PROCEDURE : Validate_Lookup_Upper
--
-- COMMENT   : Validates Lookup_code and Meaning against view fnd_lookups.
--             If both values are specified then only Lookup_code is used
--             For glog project, Validate lookup_code in UPPER CASE
--
-- NOTE      : For old data, it is possible that the cursor might fetch
--             multiple rows when using UPPER CASE CONVERSION
--             If more than 1 record is found, raise an error requesting
--             fix for the data.
--========================================================================

  PROCEDURE Validate_Lookup_Upper
        (p_lookup_type                  IN             VARCHAR2,
         p_lookup_code                  IN OUT NOCOPY  VARCHAR2,
         p_meaning                      IN             VARCHAR2,
         x_return_status                   OUT NOCOPY  VARCHAR2) IS

  -- Bug 3821688 Split Cursor
  CURSOR check_lookup_code IS
  SELECT lookup_code
  FROM   fnd_lookup_values_vl
  WHERE  UPPER(lookup_code) = UPPER(p_lookup_code) AND
         lookup_type = p_lookup_type AND
         nvl(start_date_active,sysdate)<=sysdate AND nvl(end_date_active,sysdate)>=sysdate AND
         view_application_id = 660 AND
         enabled_flag = 'Y';

  CURSOR check_lookup_meaning IS
  SELECT lookup_code
  FROM   fnd_lookup_values_vl
  WHERE  meaning = p_meaning AND
         lookup_type = p_lookup_type AND
         nvl(start_date_active,sysdate)<=sysdate AND nvl(end_date_active,sysdate)>=sysdate AND
         view_application_id = 660 AND
         enabled_flag = 'Y';

  -- Bug 3821688
  l_index NUMBER;
  l_flag VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_cache_rec Generic_Cache_Rec_Typ;
  l_count     NUMBER;

  --
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_LOOKUP_UPPER';
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
            WSH_DEBUG_SV.log(l_module_name,'P_LOOKUP_TYPE',P_LOOKUP_TYPE);
            WSH_DEBUG_SV.log(l_module_name,'P_LOOKUP_CODE',P_LOOKUP_CODE);
            WSH_DEBUG_SV.log(l_module_name,'P_MEANING',P_MEANING);
        END IF;
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF (p_lookup_code IS NOT NULL) OR (p_meaning IS NOT NULL) THEN
           -- Bug 3821688
            l_cache_rec.input_param1 := p_lookup_code;
            l_cache_rec.input_param2 := p_meaning;
            l_cache_rec.input_param3 := p_lookup_type;
            -- Always Call get_table_index to check if value exists in cache
            -- If no record exists,then we can insert new record with the output index
            get_table_index
              (p_validate_rec => l_cache_rec,
               p_generic_tab => g_lookup_tab,
               x_index      => l_index,
               x_return_status => l_return_status,
               x_flag        => l_flag
              );
             -- l_flag = U means use this index value to insert record in table
            IF l_flag = 'U' AND l_index IS NOT NULL THEN--{
              IF p_lookup_code IS NOT NULL THEN --{
                l_count := 0;
                l_cache_rec.valid_flag := 'N';
                FOR rec in check_lookup_code
                LOOP
                  l_cache_rec.output_param1 := rec.lookup_code;
                  l_count := l_count + 1;
                END LOOP;

                IF l_count = 1 THEN
                  l_cache_rec.valid_flag := 'Y';
                ELSIF l_count > 1 THEN -- more than 1 record found
                  -- Add this Message to the one at the end
                  FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_LOOKUP_CODE');
                  FND_MESSAGE.SET_TOKEN('LOOKUP_TYPE',p_lookup_type);
                  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  wsh_util_core.add_message(x_return_status,l_module_name);
                END IF;

              ELSIF p_meaning IS NOT NULL THEN
                OPEN  check_lookup_meaning;
                FETCH check_lookup_meaning INTO l_cache_rec.output_param1;
                IF (check_lookup_meaning%NOTFOUND) THEN
                  l_cache_rec.valid_flag := 'N';
                ELSE
                  l_cache_rec.valid_flag := 'Y';
                END IF;
                CLOSE check_lookup_meaning;
              END IF;--}

              g_lookup_tab(l_index) := l_cache_rec;
            END IF;--}

            -- Always check if input is valid or not
            IF g_lookup_tab(l_index).valid_flag = 'N' THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_LOOKUP');
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status,l_module_name);
            END IF;
            -- Always Populate return variables
            p_lookup_code  := g_lookup_tab(l_index).output_param1;

     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_lookup_code',p_lookup_code);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;

     --
  EXCEPTION
    --
    WHEN OTHERS THEN
    --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_UTIL_VALIDATE.Validate_Lookup_Upper');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
   --
  END Validate_Lookup_Upper;


/*======================================================================
PROCEDURE : ValidateActualDepartureDate

COMMENT : This is just a wrapper around the function
          WSH_UITL_CORE.ValidateActualDepartureDate

          This procedure calls a similar function in WSH_UTIL_CORE
          and logs an error message if the actual departure date is
          not valid.

HISTORY : rlanka    03/08/2005    Created
=======================================================================*/
PROCEDURE ValidateActualDepartureDate
        (p_ship_confirm_rule_id IN NUMBER,
         p_actual_departure_date IN DATE,
         x_return_status OUT NOCOPY VARCHAR2) IS
  --
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                  || 'ValidateActualDepartureDate';
  --
  v_ValidDate BOOLEAN;
  --
BEGIN
  --
  v_ValidDate := FALSE;
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_ship_confirm_rule_id',
                     p_ship_confirm_rule_id);
    WSH_DEBUG_SV.log(l_module_name,'p_actual_departure_date',
                     p_actual_departure_date);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  v_ValidDate := WSH_UTIL_CORE.ValidateActualDepartureDate(
             p_ship_confirm_rule_id => p_ship_confirm_rule_id,
             p_actual_departure_date => p_actual_departure_date);
  --
  IF NOT v_ValidDate THEN
   --
   IF l_debug_on THEN
    wsh_debug_sv.logmsg(l_module_name, 'Future ship date is not allowed');
   END IF;
   --
   FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_FUTURE_SHIP_DATE');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   wsh_util_core.add_message(x_return_status);
   --
  END IF;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
   WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
   wsh_util_core.default_handler('WSH_UTIL_VALIDATE.ValidateActualDepartureDate');
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle
error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
   --
END ValidateActualDepartureDate;
--
-- Standalone Project - Start
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_SR_Organization
--
-- PARAMETERS:
--       p_organization_id => Organization Id
--       x_return_status   => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to validate whether Organization is WMS enabled and NOT Process
--       manufacturing enabled.
-- HISTORY :
--       ueshanka    19/Nov/2008    Created
--=============================================================================
--
PROCEDURE Validate_SR_Organization(
          p_organization_id  IN NUMBER,
          x_return_status    OUT NOCOPY VARCHAR2)
IS
   l_org_cache_rec            Generic_Cache_Rec_Typ;
   l_index                    NUMBER;
   l_return_status            VARCHAR2(1);
   l_flag                     VARCHAR2(1);
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_SR_Organization';
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
      WSH_DEBUG_SV.log(l_module_name, 'p_organization_id', p_organization_id);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_org_cache_rec.input_param1  := p_organization_id;

   Get_Table_Index(
          p_validate_rec  => l_org_cache_rec,
          p_generic_tab   => g_sr_org_tab,
          x_index         => l_index,
          x_return_status => l_return_status,
          x_flag          => l_flag );

   IF l_index is not null THEN
      IF l_flag = 'U' THEN --Not Found in Cache, so use this index to add in Cache
         g_sr_org_tab(l_index).input_param1  := p_organization_id;
         g_sr_org_tab(l_index).output_param1 :=
                       WSH_UTIL_VALIDATE.Check_Wms_Org (
                                p_organization_id => p_organization_id );

         IF INV_GMI_RSV_BRANCH.PROCESS_BRANCH(p_organization_id) THEN
            g_sr_org_tab(l_index).output_param2 := 'Y' ;
         ELSE
            g_sr_org_tab(l_index).output_param2 := 'N' ;
         END IF;

         IF g_sr_org_tab(l_index).output_param1 = 'N' or
            g_sr_org_tab(l_index).output_param2 = 'Y'
         THEN
            g_sr_org_tab(l_index).valid_flag := 'N';
         ELSE
            g_sr_org_tab(l_index).valid_flag := 'Y';
         END IF;
      END IF;

      IF g_sr_org_tab(l_index).valid_flag = 'N' THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         --WMS Enabled Check
         IF g_sr_org_tab(l_index).output_param1 = 'N' THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Organization is NOT WMS Enabled');
            END IF;
            --
            FND_MESSAGE.SET_NAME('WSH','WSH_STND_WMS_NOT_INSTALLED');
            WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name );
         END IF;

         --OPM Enabled Check
         IF g_sr_org_tab(l_index).output_param2 = 'Y' THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Organization is OPM Enabled');
            END IF;
            --
            FND_MESSAGE.SET_NAME('WSH','WSH_STND_OPM_INSTALLED');
            WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name );
         END IF;
      END IF;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_UTIL_VALIDATE.Validate_SR_Organization');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Validate_SR_Organization;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Locator_Code
--
-- PARAMETERS:
--       p_locator_code    => Locator Code
--       p_organization_id => Organization Id
--       x_locator_id      => Locator Id
--       x_return_status   => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to derive Locator Id based on Locator Code and Organization passed
-- HISTORY :
--       ueshanka    19/Nov/2008    Created
--=============================================================================
--
PROCEDURE Validate_Locator_Code(
          p_locator_code     IN VARCHAR2,
          p_organization_id  IN NUMBER,
          x_locator_id       OUT NOCOPY NUMBER,
          x_return_status    OUT NOCOPY VARCHAR2)
IS
   l_locator_cache_rec        Generic_Cache_Rec_Typ;
   l_index                    NUMBER;
   l_return_status            VARCHAR2(1);
   l_flag                     VARCHAR2(1);
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Locator_Code';
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
      WSH_DEBUG_SV.log(l_module_name, 'p_locator_code', p_locator_code);
      WSH_DEBUG_SV.log(l_module_name, 'p_organization_id', p_organization_id);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_locator_cache_rec.input_param1  := p_locator_code;
   l_locator_cache_rec.input_param2  := p_organization_id;

   Get_Table_Index(
          p_validate_rec  => l_locator_cache_rec,
          p_generic_tab   => g_locator_code_tab,
          x_index         => l_index,
          x_return_status => l_return_status,
          x_flag          => l_flag );

   IF l_index is not null THEN
      IF l_flag = 'U' THEN --Not Found in Cache, so use this index to add in Cache
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Locator not found in cache');
         END IF;
         --
         g_locator_code_tab(l_index).input_param1  := p_locator_code;
         g_locator_code_tab(l_index).input_param2  := p_organization_id;
         BEGIN
            select inventory_location_id
            into   x_locator_id
            from   mtl_item_locations_kfv
            where  concatenated_segments = p_locator_code
            and    organization_id = p_organization_id
            and    rownum = 1;

            g_locator_code_tab(l_index).valid_flag := 'Y';
            g_locator_code_tab(l_index).output_param1 := x_locator_id;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            g_locator_code_tab(l_index).valid_flag := 'N';
         END;
      END IF;

      IF g_locator_code_tab(l_index).valid_flag = 'N' THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Invalid Locator Code');
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('WSH','WSH_STND_INVALID_LOCATOR');
         FND_MESSAGE.SET_TOKEN('LOCATOR_CODE', p_locator_code);
         WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name );
      ELSE
         x_locator_id := to_number(g_locator_code_tab(l_index).output_param1);
      END IF;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_locator_id', x_locator_id);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_UTIL_VALIDATE.Validate_Locator_Code');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Validate_Locator_Code;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Item
--
-- PARAMETERS:
--       p_item_number       => Inventory Item Name
--       p_organization_id   => Organization Id
--       x_inventory_item_id => Inventory Item Id
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to derive Inventory Item Id based on Item Number and Organization
--       passed
-- HISTORY :
--       ueshanka    19/Nov/2008    Created
--=============================================================================
--
PROCEDURE Validate_Item(
          p_item_number       IN VARCHAR2,
          p_organization_id   IN NUMBER,
          x_inventory_item_id OUT NOCOPY NUMBER,
          x_return_status     OUT NOCOPY VARCHAR2)
IS
   l_item_cache_rec           Generic_Cache_Rec_Typ;
   l_index                    NUMBER;
   l_return_status            VARCHAR2(1);
   l_flag                     VARCHAR2(1);
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Item';
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
      WSH_DEBUG_SV.log(l_module_name, 'p_item_number', p_item_number);
      WSH_DEBUG_SV.log(l_module_name, 'p_organization_id', p_organization_id);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_item_cache_rec.input_param1  := p_item_number;
   l_item_cache_rec.input_param2  := p_organization_id;

   Get_Table_Index(
          p_validate_rec  => l_item_cache_rec,
          p_generic_tab   => g_inventory_item_tab,
          x_index         => l_index,
          x_return_status => l_return_status,
          x_flag          => l_flag );

   IF l_index is not null THEN
      IF l_flag = 'U' THEN --Not Found in Cache, so use this index to add in Cache
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Inventory item not found in cache');
         END IF;
         --
         g_inventory_item_tab(l_index).input_param1  := p_item_number;
         g_inventory_item_tab(l_index).input_param2  := p_organization_id;

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_EXTERNAL_INTERFACE_SV.Validate_Item', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         WSH_EXTERNAL_INTERFACE_SV.Validate_Item(
                  p_concatenated_segments => p_item_number,
                  p_organization_id       => p_organization_id,
                  x_inventory_item_id     => x_inventory_item_id,
                  x_return_status         => l_return_status );

         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS and
            x_inventory_item_id is not null
         THEN
            g_inventory_item_tab(l_index).valid_flag := 'Y';
            g_inventory_item_tab(l_index).output_param1 := x_inventory_item_id;
         ELSE
            g_inventory_item_tab(l_index).valid_flag := 'N';
         END IF;
      END IF;

      IF g_inventory_item_tab(l_index).valid_flag = 'N' THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Invalid Inventory Item');
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_INV_ITEM');
         FND_MESSAGE.Set_Token('ITEM_NAME', p_item_number);
         WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name );
      ELSE
         x_inventory_item_id := to_number(g_inventory_item_tab(l_index).output_param1);
      END IF;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_inventory_item_id', x_inventory_item_id);
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_UTIL_VALIDATE.Validate_Item');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Validate_Item;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Customer_Item
--
-- PARAMETERS:
--       p_item_number       => Inventory Item Name
--       p_customer_id       => SoldTo Customer Id
--       p_address_id        => ShipTo Customer Address Id
--       x_customer_item_id  => Customer Item Id
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to derive Customer Item Id based on Item Number, Customer Id and
--       Customer Address Id passed.
-- HISTORY :
--       ueshanka    19/Nov/2008    Created
--=============================================================================
--
PROCEDURE Validate_Customer_Item(
          p_item_number      IN VARCHAR2,
          p_customer_id      IN NUMBER,
          p_address_id       IN VARCHAR2,
          x_customer_item_id OUT NOCOPY NUMBER,
          x_return_status    OUT NOCOPY VARCHAR2)
IS
   l_cust_item_cache_rec      Generic_Cache_Rec_Typ;
   l_index                    NUMBER;
   l_return_status            VARCHAR2(1);
   l_flag                     VARCHAR2(1);
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Customer_Item';
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
      WSH_DEBUG_SV.log(l_module_name, 'p_item_number', p_item_number);
      WSH_DEBUG_SV.log(l_module_name, 'p_customer_id', p_customer_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_address_id', p_address_id);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_cust_item_cache_rec.input_param1  := p_item_number;
   l_cust_item_cache_rec.input_param2  := p_customer_id;
   l_cust_item_cache_rec.input_param3  := p_address_id;

   Get_Table_Index(
          p_validate_rec  => l_cust_item_cache_rec,
          p_generic_tab   => g_customer_item_tab,
          x_index         => l_index,
          x_return_status => l_return_status,
          x_flag          => l_flag );

   IF l_index is not null THEN
      IF l_flag = 'U' THEN --Not Found in Cache, so use this index to add in Cache
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Customer item not found in cache');
         END IF;
         --
         g_customer_item_tab(l_index).input_param1  := p_item_number;
         g_customer_item_tab(l_index).input_param2  := p_customer_id;
         g_customer_item_tab(l_index).input_param3  := p_address_id;

         BEGIN

            select cust_items.customer_item_id
            into   x_customer_item_id
            from
                 ( select mci.customer_item_id, mci.item_definition_level
                   from   mtl_customer_items mci
                   where  mci.customer_item_number = p_item_number
                   and    mci.customer_id = p_customer_id
                   and    mci.item_definition_level = 1
                   union
                   select mci1.customer_item_id, mci1.item_definition_level
                   from   mtl_customer_items mci1
                   where  mci1.customer_item_number = p_item_number
                   and    mci1.customer_id = p_customer_id
                   and    mci1.address_id = p_address_id
                   and    mci1.item_definition_level = 3
                   order by 2 desc ) cust_items
            where rownum = 1;

            g_customer_item_tab(l_index).valid_flag := 'Y';
            g_customer_item_tab(l_index).output_param1 := x_customer_item_id;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Inside No-Data-Found Exception');
            END IF;
            --
            g_customer_item_tab(l_index).valid_flag := 'N';
         END;
      END IF;

      IF g_customer_item_tab(l_index).valid_flag = 'N' THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Invalid Customer Item');
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CUST_ITEM');
         FND_MESSAGE.Set_Token('CUST_ITEM', p_item_number);
         WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name );
      ELSE
         x_customer_item_id := to_number(g_customer_item_tab(l_index).output_param1);
      END IF;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_customer_item_id', x_customer_item_id);
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_UTIL_VALIDATE.Validate_Customer_Item');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Validate_Customer_Item;
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Ship_Method
--
-- PARAMETERS:
--       p_organization_id   => Organization Id
--       p_carrier_code      => Carrier Code
--       p_service_level     => Service Level
--       p_mode_of_transport => Mode of Transport
--       x_ship_method_code  => Ship Method Code
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to derive Ship Method Code based on Carrier, Service Level, Mode
--       of Transport and Organization passed.
-- HISTORY :
--       ueshanka    19/Nov/2008    Created
--=============================================================================
--
PROCEDURE Validate_Ship_Method(
          p_organization_id   IN NUMBER,
          p_carrier_code      IN VARCHAR2,
          p_service_level     IN VARCHAR2,
          p_mode_of_transport IN VARCHAR2,
          x_ship_method_code  OUT NOCOPY VARCHAR2,
          x_return_status     OUT NOCOPY VARCHAR2)
IS
   l_ship_method_cache_rec    Generic_Cache_Rec_Typ;
   l_index                    NUMBER;
   l_return_status            VARCHAR2(1);
   l_flag                     VARCHAR2(1);
   l_service_level            VARCHAR2(30);
   l_mode_of_transport        VARCHAR2(30);
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Ship_Method';
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
      WSH_DEBUG_SV.log(l_module_name, 'p_organization_id', p_organization_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_carrier_code', p_carrier_code);
      WSH_DEBUG_SV.log(l_module_name, 'p_service_level', p_service_level);
      WSH_DEBUG_SV.log(l_module_name, 'p_mode_of_transport', p_mode_of_transport);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_ship_method_cache_rec.input_param1  := p_organization_id;
   l_ship_method_cache_rec.input_param2  := p_carrier_code;
   l_ship_method_cache_rec.input_param3  := p_service_level;
   l_ship_method_cache_rec.input_param4  := p_mode_of_transport;

   Get_Table_Index(
          p_validate_rec  => l_ship_method_cache_rec,
          p_generic_tab   => g_shipping_method_tab,
          x_index         => l_index,
          x_return_status => l_return_status,
          x_flag          => l_flag );

   IF l_index is not null THEN
      IF l_flag = 'U' THEN --Not Found in Cache, so use this index to add in Cache
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Ship Method Code not found in cache');
         END IF;
         --
         g_shipping_method_tab(l_index).input_param1  := p_organization_id;
         g_shipping_method_tab(l_index).input_param2  := p_carrier_code;
         g_shipping_method_tab(l_index).input_param3  := p_service_level;
         g_shipping_method_tab(l_index).input_param4  := p_mode_of_transport;

         BEGIN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Querying Ship Method Code from table');
            END IF;
            --
            select ship_method_code
            into   x_ship_method_code
            from   wsh_carriers wc,
                   wsh_carrier_services wcs,
                   wsh_org_carrier_services wocs
            where  wocs.organization_id = p_organization_id
            and    wocs.carrier_service_id = wcs.carrier_service_id
            and    wcs.mode_of_transport = p_mode_of_transport
            and    wcs.service_level = p_service_level
            and    wcs.carrier_id = wc.carrier_id
            and    wc.freight_code = p_carrier_code;

            g_shipping_method_tab(l_index).valid_flag := 'Y';
            g_shipping_method_tab(l_index).output_param1 := x_ship_method_code;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Inside No-Data-Found Exception');
            END IF;
            --
            g_shipping_method_tab(l_index).valid_flag := 'N';
         END;
      END IF;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Valid Flag => ' || g_shipping_method_tab(l_index).valid_flag);
      END IF;
      --

      IF g_shipping_method_tab(l_index).valid_flag = 'N' THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Ship Method does not exists');
         END IF;
         --
         FND_MESSAGE.SET_NAME('WSH','WSH_STND_INVALID_SM');
         FND_MESSAGE.SET_TOKEN('CARRIER', p_carrier_code);
         FND_MESSAGE.SET_TOKEN('SERVICE_LEVEL', p_service_level);
         FND_MESSAGE.SET_TOKEN('MODE_OF_TRANS', p_mode_of_transport);
         FND_MESSAGE.SET_TOKEN('WAREHOUSE', WSH_UTIL_CORE.Get_Org_Name(p_organization_id));
         WSH_UTIL_CORE.Add_Message(x_return_status, l_module_name );
      ELSIF g_shipping_method_tab(l_index).valid_flag = 'Y' THEN
         x_ship_method_code := g_shipping_method_tab(l_index).output_param1;
      END IF;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_ship_method_code', x_ship_method_code);
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_UTIL_VALIDATE.Validate_Ship_Method');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Validate_Ship_Method;
--
-- Standalone Project - End

--========================================================================
-- PROCEDURE : Validate_Freight_Code        Private
--
-- PARAMETERS: p_freight_code          Freight Code
--             x_carrier_id            In / Out Carrier id
--             x_return_status         return status
--
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to validate carrier_id and freight_code
--========================================================================
PROCEDURE Validate_Freight_Code(
         p_freight_code  IN VARCHAR2,
         x_carrier_id    IN OUT NOCOPY NUMBER,
         x_return_status OUT NOCOPY VARCHAR2)
IS
     --
     l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Freight_Code';
     --
     CURSOR  l_carrier_csr is
       SELECT  carrier_id
       FROM    wsh_carriers_v
       WHERE   nvl(x_carrier_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
       AND     carrier_id = x_carrier_id
       AND     nvl(generic_flag, 'N') = 'N'
       AND     active = 'A'
       UNION ALL
       SELECT  carrier_id
       FROM    wsh_carriers_v
       WHERE   nvl(x_carrier_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
       AND     freight_code = p_freight_code
       AND     nvl(generic_flag, 'N') = 'N'
       AND     active = 'A';

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
      WSH_DEBUG_SV.log(l_module_name,'p_freight_code', p_freight_code);
      WSH_DEBUG_SV.log(l_module_name,'x_carrier_id', x_carrier_id);
    END IF;

    x_return_status := wsh_util_core.g_ret_sts_success;

    IF (nvl(x_carrier_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num  OR NVL(p_freight_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char) THEN
    --{
         OPEN  l_carrier_csr;
         FETCH l_carrier_csr INTO x_carrier_id;
         IF l_carrier_csr%NOTFOUND THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_NOT_FOUND');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_return_status,l_module_name);
         END IF;
         CLOSE l_carrier_csr;
    --}
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION

  WHEN OTHERS THEN
  --{
       IF l_carrier_csr%ISOPEN THEN
         CLOSE l_carrier_csr;
       END IF;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

       wsh_util_core.default_handler('WSH_UTIL_VALIDATE.Validate_Freight_Code');
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
  --}
END Validate_Freight_Code;

END WSH_UTIL_VALIDATE;

/
