--------------------------------------------------------
--  DDL for Package Body WSH_OTM_REF_DATA_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_OTM_REF_DATA_GEN_PKG" as
/* $Header: WSHTMRGB.pls 120.5.12010000.3 2008/08/11 10:21:19 mvudugul ship $ */

  --

  TYPE IN_REC_TYPE IS RECORD(
    dummy1 NUMBER
  );
  --

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_OTM_REF_DATA_GEN_PKG';
--
PROCEDURE INSERT_ROW_IN_LOC_GTMP
            (
              p_location_id IN NUMBER,
              p_corporation_id IN NUMBER,
              p_location_type IN VARCHAR2,
              x_return_status OUT NOCOPY VARCHAR2
            )
IS
--{
--}
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW_IN_LOC_GTMP';
--
BEGIN
--{
    --
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
        WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_CORPORATION_ID',P_CORPORATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_TYPE',P_LOCATION_TYPE);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    insert into WSH_OTM_LOCATIONS_GTMP
    (location_id, corporation_id, location_type)
    values( p_location_id,p_corporation_id,p_location_type);
    --
--}
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
--{
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
--}
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END INSERT_ROW_IN_LOC_GTMP;

function GET_STOP_CORP_ID
            (
              p_stop_id          IN  NUMBER,
              p_loc_type         IN VARCHAR2
            ) RETURN NUMBER
IS
    cursor l_stop_dd_org_csr(p_stop_id IN NUMBER) is
    SELECT HOU.ORGANIZATION_ID
    FROM   HR_ALL_ORGANIZATION_UNITS HOU,
           WSH_LOCATIONS WL,
           WSH_NEW_DELIVERIES WND,
           WSH_DELIVERY_LEGS WDL,
           WSH_TRIP_STOPS WTS
    WHERE  WTS.STOP_ID = p_stop_id
    AND    HOU.LOCATION_ID = WL.SOURCE_LOCATION_ID
    AND    WL.LOCATION_SOURCE_CODE = 'HR'
    AND    WL.WSH_LOCATION_ID = nvl(WTS.PHYSICAL_LOCATION_ID,WTS.STOP_LOCATION_ID)
    AND    (WTS.STOP_ID = WDL.PICK_UP_STOP_ID
            OR WTS.STOP_ID = WDL.DROP_OFF_STOP_ID
           )
    AND    WDL.DELIVERY_ID = WND.DELIVERY_ID
    AND    HOU.ORGANIZATION_ID = WND.ORGANIZATION_ID;

    --bug 6770323: modified cursor to join with hr_locations_all table
    cursor l_stop_org_csr(p_stop_id IN NUMBER) is
    SELECT HL.INVENTORY_ORGANIZATION_ID
    FROM   HR_LOCATIONS_ALL HL,
           WSH_LOCATIONS WL,
           WSH_TRIP_STOPS WTS
    WHERE  WTS.STOP_ID = p_stop_id
    AND    HL.LOCATION_ID = WL.SOURCE_LOCATION_ID
    AND    WL.LOCATION_SOURCE_CODE = 'HR'
    AND    WL.WSH_LOCATION_ID = nvl(WTS.PHYSICAL_LOCATION_ID,WTS.STOP_LOCATION_ID);

    cursor l_stop_dd_cust_csr(p_stop_id IN NUMBER) is
    SELECT HCA.CUST_ACCOUNT_ID
    FROM   HZ_CUST_ACCOUNTS HCA,
           HZ_PARTIES HP,
           HZ_PARTY_SITES HPS,
           WSH_LOCATIONS WL,
           WSH_NEW_DELIVERIES WND,
           WSH_DELIVERY_LEGS WDL,
           WSH_TRIP_STOPS WTS,
           WSH_DELIVERY_ASSIGNMENTS WDA,
           WSH_DELIVERY_DETAILS WDD
    WHERE  WTS.STOP_ID = p_stop_id
    AND    HPS.LOCATION_ID = WL.SOURCE_LOCATION_ID
    AND    WL.LOCATION_SOURCE_CODE = 'HZ'
    AND    WL.WSH_LOCATION_ID = nvl(WTS.PHYSICAL_LOCATION_ID,WTS.STOP_LOCATION_ID)
    AND    HPS.PARTY_ID = HP.PARTY_ID
    AND    HP.PARTY_ID = HCA.PARTY_ID
    AND    (WTS.STOP_ID = WDL.PICK_UP_STOP_ID
            OR WTS.STOP_ID = WDL.DROP_OFF_STOP_ID
           )
    AND    WDL.DELIVERY_ID = WND.DELIVERY_ID
    AND    WND.DELIVERY_ID = WDA.DELIVERY_ID
    AND    WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
    AND    HCA.CUST_ACCOUNT_ID = WDD.CUSTOMER_ID;

    cursor l_stop_cust_csr(p_stop_id IN NUMBER) is
    SELECT HCA.CUST_ACCOUNT_ID
    FROM   HZ_CUST_ACCOUNTS HCA,
           HZ_PARTIES HP,
           HZ_PARTY_SITES HPS,
           WSH_LOCATIONS WL,
           WSH_TRIP_STOPS WTS
    WHERE  WTS.STOP_ID = p_stop_id
    AND    HPS.LOCATION_ID = WL.SOURCE_LOCATION_ID
    AND    WL.LOCATION_SOURCE_CODE = 'HZ'
    AND    WL.WSH_LOCATION_ID = nvl(WTS.PHYSICAL_LOCATION_ID,WTS.STOP_LOCATION_ID)
    AND    HPS.PARTY_ID = HP.PARTY_ID
    AND    HP.PARTY_ID = HCA.PARTY_ID;

    l_corporation_id NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_STOP_CORP_ID';
--
BEGIN
--{
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
        WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_LOC_TYPE',P_LOC_TYPE);
    END IF;
    --
    IF (p_loc_type = 'HR') THEN
      open  l_stop_dd_org_csr(p_stop_id);
      fetch l_stop_dd_org_csr into l_corporation_id;
      close l_stop_dd_org_csr;

      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_corporation_id after l_pickup_stop_org_csr',l_corporation_id);
      END IF;

      IF (l_corporation_id is null) THEN
        open  l_stop_org_csr(p_stop_id);
        fetch l_stop_org_csr into l_corporation_id;
        close l_stop_org_csr;

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_corporation_id after l_dropoff_stop_org_csr',l_corporation_id);
        END IF;
      END IF;
    ELSIF (p_loc_type = 'HZ') THEN
      open  l_stop_dd_cust_csr(p_stop_id);
      fetch l_stop_dd_cust_csr into l_corporation_id;
      close l_stop_dd_cust_csr;

      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_corporation_id after l_pickup_stop_cust_csr',l_corporation_id);
      END IF;


      IF (l_corporation_id is null) THEN
        open  l_stop_cust_csr(p_stop_id);
        fetch l_stop_cust_csr into l_corporation_id;
        close l_stop_cust_csr;

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_corporation_id after l_dropoff_stop_cust_csr',l_corporation_id);
        END IF;
      END IF;

    ELSE
      l_corporation_id := null;
    END IF;
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
        --
    END IF;
    return l_corporation_id;
    --
--}
END GET_STOP_CORP_ID;

PROCEDURE EXTRACT_DLVY_INFO
            (
              p_entity_in_rec IN WSH_OTM_ENTITY_REC_TYPE,
              p_transmission_id IN NUMBER,
              x_return_status OUT NOCOPY VARCHAR2
            )
IS
--{
    -- local variables
    l_return_status VARCHAR2(1);
    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;
    i NUMBER;

    l_customer_id NUMBER;
    l_st_loc_id   NUMBER;
    l_contact_id  NUMBER;
    l_site_use_id  NUMBER;
    l_prev_contact_id  NUMBER;
    l_cnt         NUMBER;
    l_contact_exists VARCHAR2(1);

    l_internal_loc_exists VARCHAR2(1);
    l_internal_org_id     NUMBER;
    l_internal_loc_id     NUMBER;

    -- cursors
    cursor l_get_del_loc_info_csr(p_delivery_id IN NUMBER) is
    SELECT WND.ULTIMATE_DROPOFF_LOCATION_ID SHIP_TO_LOCATION_ID,
           WND.CUSTOMER_ID,
           WND.INITIAL_PICKUP_LOCATION_ID SHIP_FROM_LOCATION_ID,
           WND.ORGANIZATION_ID,
           WLT1.LOCATION_ID WLT1_ST_LOC_ID,
           WLT1.CORPORATION_ID WLT1_CUST_ID,
           WLT2.LOCATION_ID WLT2_SF_LOC_ID,
           WLT2.CORPORATION_ID WLT2_ORG_ID
    FROM   WSH_NEW_DELIVERIES WND,
           WSH_OTM_LOCATIONS_GTMP WLT1,
           WSH_OTM_LOCATIONS_GTMP WLT2
    WHERE  WND.DELIVERY_ID = p_delivery_id
    AND    WND.ULTIMATE_DROPOFF_LOCATION_ID   = WLT1.LOCATION_ID (+)
    AND    WND.CUSTOMER_ID                    = WLT1.CORPORATION_ID (+)
    AND    WND.INITIAL_PICKUP_LOCATION_ID     = WLT2.LOCATION_ID (+)
    AND    WND.ORGANIZATION_ID                = WLT2.CORPORATION_ID (+)
    AND    WLT1.LOCATION_TYPE (+)             = 'CUST_LOC'
    AND    WLT2.LOCATION_TYPE (+)             = 'ORG_LOC';

    cursor l_get_dd_loc_info_csr(p_delivery_id IN NUMBER) is
    SELECT DISTINCT WDD.SHIP_TO_LOCATION_ID,
           WDD.CUSTOMER_ID
    FROM   WSH_DELIVERY_DETAILS WDD,
           WSH_DELIVERY_ASSIGNMENTS WDA
    WHERE  WDA.DELIVERY_ID = p_delivery_id
    AND    WDD.DELIVERY_DETAIL_ID    = WDA.DELIVERY_DETAIL_ID
    AND    WDD.container_flag = 'N'
    AND    NOT EXISTS (
                        SELECT 'X'
                        FROM   WSH_OTM_LOCATIONS_GTMP
                        WHERE  LOCATION_TYPE = 'CUST_LOC'
                        AND    LOCATION_ID = WDD.SHIP_TO_LOCATION_ID
                        AND    CORPORATION_ID = WDD.CUSTOMER_ID
                      );


    cursor l_ship_site_use_csr (p_delivery_id IN NUMBER) is
    SELECT WDD.SHIP_TO_SITE_USE_ID, COUNT(*) CNT
    FROM   WSH_DELIVERY_ASSIGNMENTS WDA,
           WSH_DELIVERY_DETAILS WDD
    WHERE  WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
    AND    WDA.DELIVERY_ID        =  P_DELIVERY_ID
    AND    WDD.CONTAINER_FLAG     = 'N'
    GROUP  BY WDD.SHIP_TO_SITE_USE_ID
    ORDER  BY CNT desc;

    -- OTM R12, glog project
    -- Remove the join condition between HCAR.CUST_ACCOUNT_ID
    -- and WDD.CUSTOMER_ID
    cursor l_del_contact_csr(p_delivery_id IN NUMBER) is
    SELECT DISTINCT HCAR.CUST_ACCOUNT_ROLE_ID CONTACT_ID,
           WDD.CUSTOMER_ID CUSTOMER_ID
    FROM   WSH_DELIVERY_DETAILS WDD,
           WSH_DELIVERY_ASSIGNMENTS WDA,
           HZ_PARTY_SITES HPS,
           WSH_LOCATIONS WSL,
           HZ_CUST_ACCT_SITES_ALL HCAS,
           HZ_CUST_ACCOUNT_ROLES HCAR
    WHERE  WDA.delivery_id = p_delivery_id
    AND    WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
    AND    WDD.SHIP_TO_LOCATION_ID = WSL.WSH_LOCATION_ID
    AND    WSL.SOURCE_LOCATION_ID = HPS.LOCATION_ID
    AND    HPS.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
    AND    HCAS.CUST_ACCT_SITE_ID = HCAR.CUST_ACCT_SITE_ID
    AND    HCAR.STATUS = 'A';

    cursor l_check_contacts_exists_csr (p_contact_id IN NUMBER,
                                        p_location_id IN NUMBER,
                                        p_corporation_id IN NUMBER
                                       ) is
    SELECT 'X'
    FROM   WSH_OTM_LOC_CONTACTS_GTMP
    WHERE  CONTACT_ID = p_contact_id
    AND    LOCATION_ID = p_location_id
    AND    CORPORATION_ID = p_corporation_id
    AND    LOCATION_TYPE = 'CUST_LOC';

    --bug 6770323: modified cursor to join with hr_locations_all table
    cursor l_loc_to_org_csr (p_loc_id NUMBER) IS
    SELECT inventory_organization_id
    FROM   hr_locations_all
    WHERE  location_id = p_loc_id;

    cursor l_check_loc_exists_csr (p_location_id IN NUMBER,
                                   p_corporation_id IN NUMBER
                                  ) is
    SELECT 'X'
    FROM   WSH_OTM_LOCATIONS_GTMP
    WHERE  LOCATION_ID = p_location_id
    AND    (p_corporation_id is NULL OR CORPORATION_ID = p_corporation_id)
    AND    LOCATION_TYPE = 'ORG_LOC';



--}
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'EXTRACT_DLVY_INFO';
--
BEGIN
--{
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
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSMISSION_ID',P_TRANSMISSION_ID);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    IF ( p_entity_in_rec.entity_id_tbl.count > 0
         AND p_entity_in_rec.ENTITY_TYPE = 'DELIVERY'
       )
    THEN
    --{
        FOR i in p_entity_in_rec.entity_id_tbl.first..p_entity_in_rec.entity_id_tbl.last LOOP
        --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Delivery_Id('||i||')',p_entity_in_rec.entity_id_tbl(i));
            END IF;
            l_internal_loc_id := NULL;
            l_internal_org_id := NULL;
            FOR l_del_loc_info_rec in l_get_del_loc_info_csr(p_entity_in_rec.entity_id_tbl(i)) LOOP
            --{
                WSH_LOCATIONS_PKG.Convert_internal_cust_location(
                  p_internal_cust_location_id   => l_del_loc_info_rec.SHIP_TO_LOCATION_ID,
                  x_internal_org_location_id    => l_internal_loc_id,
                  x_return_status               => l_return_status);
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_return_status after calling Convert_internal_cust_location',l_return_status);
                  WSH_DEBUG_SV.log(l_module_name,'l_internal_loc_id',l_internal_loc_id);
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                wsh_util_core.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors);


                --
                -- Ship To
                l_st_loc_id   := l_del_loc_info_rec.SHIP_TO_LOCATION_ID;
                l_customer_id := l_del_loc_info_rec.CUSTOMER_ID;
                IF  (l_del_loc_info_rec.CUSTOMER_ID IS NOT NULL
                     and l_del_loc_info_rec.WLT1_ST_LOC_ID IS NULL
                     and l_internal_loc_id IS NULL )
                THEN
                --{

                    INSERT_ROW_IN_LOC_GTMP
                      (
                        p_location_id => l_del_loc_info_rec.SHIP_TO_LOCATION_ID,
                        p_corporation_id => l_del_loc_info_rec.CUSTOMER_ID,
                        p_location_type => 'CUST_LOC',
                        x_return_status => l_return_status
                      );

                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.api_post_call(
                      p_return_status    => l_return_status,
                      x_num_warnings     => l_num_warnings,
                      x_num_errors       => l_num_errors);

                --}
                ELSIF (l_internal_loc_id is not null) THEN
                --{
                    open  l_loc_to_org_csr(l_internal_loc_id);
                    fetch l_loc_to_org_csr into l_internal_org_id;
                    close l_loc_to_org_csr;

                    open  l_check_loc_exists_csr(l_internal_loc_id,l_internal_org_id);
                    fetch l_check_loc_exists_csr into l_internal_loc_exists;
                    close l_check_loc_exists_csr;

                    IF (l_internal_loc_exists IS NULL) THEN
                    --{
                        INSERT_ROW_IN_LOC_GTMP
                          (
                            p_location_id => l_internal_loc_id,
                            p_corporation_id => l_internal_org_id,
                            p_location_type => 'ORG_LOC',
                            x_return_status => l_return_status
                          );
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'Return Status after calling INSERT_ROW_IN_LOC_GTMP is', l_return_status);
                          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        wsh_util_core.api_post_call(
                          p_return_status    => l_return_status,
                          x_num_warnings     => l_num_warnings,
                          x_num_errors       => l_num_errors);
                    --}
                    END IF;

                    l_internal_loc_exists := NULL;

                --}
                END IF;
                --
                -- Ship From
                IF (l_del_loc_info_rec.ORGANIZATION_ID IS NOT NULL
                    AND  l_del_loc_info_rec.WLT2_SF_LOC_ID IS NULL
                    AND nvl(l_internal_loc_id,-99999) <> l_del_loc_info_rec.SHIP_FROM_LOCATION_ID
                   )
                THEN
                --{

                    INSERT_ROW_IN_LOC_GTMP
                      (
                        p_location_id => l_del_loc_info_rec.SHIP_FROM_LOCATION_ID,
                        p_corporation_id => l_del_loc_info_rec.ORGANIZATION_ID,
                        p_location_type => 'ORG_LOC',
                        x_return_status => l_return_status
                      );

                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'Return Status after calling INSERT_ROW_IN_LOC_GTMP is', l_return_status);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.api_post_call(
                      p_return_status    => l_return_status,
                      x_num_warnings     => l_num_warnings,
                      x_num_errors       => l_num_errors);
                --}
                END IF;
            --}
            END LOOP;
            --
            --
            IF (l_customer_id is NULL and l_internal_loc_id IS NULL) THEN
            --{
                FOR dd_loc_info_rec in l_get_dd_loc_info_csr(p_entity_in_rec.entity_id_tbl(i)) LOOP
                --{
                    INSERT_ROW_IN_LOC_GTMP
                      (
                        p_location_id => dd_loc_info_rec.SHIP_TO_LOCATION_ID,
                        p_corporation_id => dd_loc_info_rec.CUSTOMER_ID,
                        p_location_type => 'CUST_LOC',
                        x_return_status => l_return_status
                      );

                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'Return Status after calling INSERT_ROW_IN_LOC_GTMP is', l_return_status);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.api_post_call(
                      p_return_status    => l_return_status,
                      x_num_warnings     => l_num_warnings,
                      x_num_errors       => l_num_errors);
                --}
                END LOOP;
            --}
            END IF;

            -- Nullifying it so that it does not hold any values,
            -- if the cursor below does not fetch anything
            l_customer_id := NULL;
            l_prev_contact_id := -999;
            l_site_use_id := NULL;
            IF (l_internal_loc_id IS NULL) THEN
            --{
                -- bug 5124820
                -- Now, we will be sending all the contacts for a given
                -- Customer Site.
                for del_contact_rec in l_del_contact_csr(p_entity_in_rec.entity_id_tbl(i)) loop
                --{
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'ContactId for delivery is', del_contact_rec.contact_id);
                      WSH_DEBUG_SV.log(l_module_name,'Prev Contact Id for delivery is', l_prev_contact_id);
                      WSH_DEBUG_SV.log(l_module_name,'location_id',l_st_loc_id);
                      WSH_DEBUG_SV.log(l_module_name,'customer_id',del_contact_rec.customer_id);
                    END IF;

                    l_contact_exists := null;

                    IF (l_prev_contact_id <> del_contact_rec.contact_id) THEN
                    --{
                        open  l_check_contacts_exists_csr(del_contact_rec.contact_id, l_st_loc_id,del_contact_rec.customer_id);
                        fetch l_check_contacts_exists_csr into l_contact_exists;
                        close l_check_contacts_exists_csr;
                        IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'contact exists',l_contact_exists);
                        END IF;
                        IF (l_contact_exists IS NULL) THEN
                        --{
                            insert into WSH_OTM_LOC_CONTACTS_GTMP
                            (contact_id, location_id, corporation_id, location_type)
                            values(del_contact_rec.contact_id, l_st_loc_id,del_contact_rec.customer_id, 'CUST_LOC');
                        --}
                        END IF;
                    --}
                    END IF;
                    l_prev_contact_id := del_contact_rec.contact_id;
                --}
                END LOOP;
            --}
            END IF;
        --}
        END LOOP;
    --}
    END IF;
    --
    IF (l_num_warnings > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        --
    ELSE
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        --
    END IF;
--}
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END EXTRACT_DLVY_INFO;

PROCEDURE EXTRACT_TRIP_INFO
            (
              p_entity_in_rec IN WSH_OTM_ENTITY_REC_TYPE,
              p_transmission_id IN NUMBER,
              x_return_status OUT NOCOPY VARCHAR2
            )
IS
--{
    -- Local Variables
    l_entity_rec WSH_OTM_ENTITY_REC_TYPE := WSH_OTM_ENTITY_REC_TYPE(NULL,NULL,NULL,NULL,WSH_OTM_RD_NUM_TBL_TYPE(),
                                                                         WSH_OTM_RD_NUM_TBL_TYPE());
    l_return_status VARCHAR2(1);
    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;
    l_corporation_id NUMBER;
    l_location_type  VARCHAR2(50);
    l_loc_exists     VARCHAR2(1);
    -- cursors
    cursor l_get_del_csr is
    SELECT DISTINCT WDL.DELIVERY_ID
    FROM   WSH_DELIVERY_LEGS WDL,
           WSH_TRIP_STOPS WTS,
           WSH_OTM_LOCATIONS_GTMP WLT
    WHERE  WTS.TRIP_ID = WLT.LOCATION_ID
    AND    WLT.LOCATION_TYPE = 'TRIP'
    AND    (WTS.STOP_ID = WDL.PICK_UP_STOP_ID
            OR WTS.STOP_ID = WDL.DROP_OFF_STOP_ID
           );
    --AND    WTS.TMS_INTERFACE_FLAG ='ASP';

    -- We cannot add the join to WSH_OTM_LOCATIONS_GTMP for 'CUST_LOC' or 'ORG_LOC'
    -- because we don't know the corporation_id
    cursor l_get_stops_csr is
    SELECT WL.LOCATION_SOURCE_CODE LOC_TYPE,
           WTS.STOP_LOCATION_ID LOCATION_ID,
           WTS.STOP_ID
    FROM   WSH_TRIP_STOPS WTS,
           WSH_OTM_LOCATIONS_GTMP WLT,
           WSH_LOCATIONS WL
    WHERE  WTS.TRIP_ID = WLT.LOCATION_ID
    AND    WLT.LOCATION_TYPE = 'TRIP'
    --bug 6770323: Modified AND condition
    AND    WL.WSH_LOCATION_ID = NVL(WTS.PHYSICAL_LOCATION_ID, WTS.STOP_LOCATION_ID);
    --AND    WTS.TMS_INTERFACE_FLAG ='ASP';

    cursor l_check_loc_exists_csr(
              p_location_id IN NUMBER,
              p_corp_id IN NUMBER,
              p_loc_type IN VARCHAR2) is
    select 'X'
    from   WSH_OTM_LOCATIONS_GTMP
    where location_id = p_location_id
    AND    (p_corp_id is NULL OR corporation_id = p_corp_id)
    and   location_type = p_loc_type;


--}
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'EXTRACT_TRIP_INFO';
--
BEGIN
--{
    --
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
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSMISSION_ID',P_TRANSMISSION_ID);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    IF ( p_entity_in_rec.entity_id_tbl.count > 0
         AND p_entity_in_rec.entity_type = 'TRIP'
       )
    THEN
    --{
        FORALL i in p_entity_in_rec.entity_id_tbl.first..p_entity_in_rec.entity_id_tbl.last
          insert into wsh_otm_locations_gtmp
            (location_id,
             location_type
            )
          values
            (
              p_entity_in_rec.entity_id_tbl(i),
              'TRIP'
            );

        open  l_get_del_csr;
        fetch l_get_del_csr bulk collect into l_entity_rec.entity_id_tbl;
        close l_get_del_csr;

        l_entity_rec.entity_type := 'DELIVERY';

        IF (l_entity_rec.entity_id_tbl.count > 0) THEN
        --{
            EXTRACT_DLVY_INFO
              (
                p_entity_in_rec   => l_entity_rec,
                p_transmission_id => p_transmission_id,
                x_return_status   => l_return_status
              );

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call(
              p_return_status    => l_return_status,
              x_num_warnings     => l_num_warnings,
              x_num_errors       => l_num_errors);
        --}
        END IF;

        -- Now, loop through all the stops in the trip to fetch the corresponding locatioins
        FOR l_stop_rec in l_get_stops_csr LOOP
        --{
            l_corporation_id := NULL;
            l_location_type := NULL;
            l_loc_exists := NULL;

            IF (l_stop_rec.loc_type = 'HR') THEN
              l_location_type := 'ORG_LOC';
            ELSIF (l_stop_rec.loc_type = 'HZ') THEN
              l_location_type := 'CUST_LOC';
            END IF;
            --
            l_corporation_id := get_stop_corp_id(l_stop_rec.stop_id, l_stop_rec.loc_type);
            --

            open l_check_loc_exists_csr(l_stop_rec.location_id, l_corporation_id,l_location_type);
            fetch l_check_loc_exists_csr into l_loc_exists;
            close l_check_loc_exists_csr;

            IF (l_loc_exists IS NULL) THEN
            --{
                INSERT_ROW_IN_LOC_GTMP
                  (
                    p_location_id    => l_stop_rec.location_id,
                    p_corporation_id => l_corporation_id,
                    p_location_type  => l_location_type,
                    x_return_status  => l_return_status
                  );

                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                wsh_util_core.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors);

            --}
            END IF;
        --}
        END LOOP;
    --}
    END IF;
    --
    IF (l_num_warnings > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        --
    ELSE
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        --
    END IF;
    --
--}
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
--}
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END EXTRACT_TRIP_INFO;

PROCEDURE EXTRACT_CARRIER_INFO
            (
              p_entity_in_rec IN WSH_OTM_ENTITY_REC_TYPE,
              p_transmission_id IN NUMBER,
              x_return_status OUT NOCOPY VARCHAR2
            )
IS
--{
    i NUMBER := 0;

    -- bug 5118375
    l_location_id     NUMBER;
    l_return_status   VARCHAR2(1);
    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;

    cursor l_get_loc_id_csr (p_party_id IN NUMBER, p_party_site_id IN NUMBER) IS
    select location_id
    from   hz_party_sites
    where  party_site_id = p_party_site_id
    and    party_id      = p_party_id;
    -- bug 5118375

--}
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'EXTRACT_CARRIER_INFO';
--
BEGIN
--{
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
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSMISSION_ID',P_TRANSMISSION_ID);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    IF ( p_entity_in_rec.entity_id_tbl.count > 0
         AND p_entity_in_rec.entity_id_tbl.count = p_entity_in_rec.parent_entity_id_tbl.count
       )
    THEN
    --{
        FORALL i in p_entity_in_rec.entity_id_tbl.first..p_entity_in_rec.entity_id_tbl.last
          insert into wsh_otm_locations_gtmp
            (location_id,
             corporation_id,
             location_type
            )
          values
            (
              p_entity_in_rec.entity_id_tbl(i),
              p_entity_in_rec.parent_entity_id_tbl(i),
              'CAR_LOC'
            );

        -- bug 5118375
        -- For every Carrier Site created,
        -- we need to check if the location is created in
        -- wsh_locations or not.  This is required
        -- the location may or may not be inserted into into wsh_locations
        -- by the time this conc. program is run.
        l_location_id := null;
        FOR i in p_entity_in_rec.entity_id_tbl.first..p_entity_in_rec.entity_id_tbl.last LOOP
        --{
            --
            --
            l_location_id := null;
            --
            open l_get_loc_id_csr(p_entity_in_rec.parent_entity_id_tbl(i),p_entity_in_rec.entity_id_tbl(i));
            fetch l_get_loc_id_csr into l_location_id;
            close l_get_loc_id_csr;
            --
            IF l_debug_on THEN
              --
              WSH_DEBUG_SV.log(l_module_name,'party_site_id ('||i||')',p_entity_in_rec.entity_id_tbl(i));
              WSH_DEBUG_SV.log(l_module_name,'party_id ('||i||')',p_entity_in_rec.parent_entity_id_tbl(i));
              WSH_DEBUG_SV.log(l_module_name,'l_location_id',l_location_id);
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOCATION',WSH_DEBUG_SV.C_PROC_LEVEL);
              --
            END IF;
            --
            wsh_util_validate.validate_location
              (
                p_location_id      => l_location_id,
                p_location_code    => NULL,
                x_return_status    => l_return_status
              );

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status', l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call(
              p_return_status    => l_return_status,
              x_num_warnings     => l_num_warnings,
              x_num_errors       => l_num_errors);
            --
            --
        --}
        END LOOP;
        -- bug 5118375
    --}
    END IF;
--}
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
--{
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
--}
END EXTRACT_CARRIER_INFO;

--- wms-otm-proj
PROCEDURE EXTRACT_ORG_INFO
            (
              p_entity_in_rec IN WSH_OTM_ENTITY_REC_TYPE,
              p_transmission_id IN NUMBER,
              x_return_status OUT NOCOPY VARCHAR2
            )
IS
--{
    i NUMBER := 0;

    l_location_id          NUMBER;
    l_gtmp_location_id     NUMBER;
    l_return_status   VARCHAR2(1);
    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;

    cursor l_get_org_loc_id_csr (c_organization_id IN NUMBER) IS
    select SFOV.location_id FROM_LOCATION_ID, WLT.LOCATION_ID GTMP_LOCATION_ID
    from   WSH_SHIP_FROM_ORGS_V SFOV,
           WSH_OTM_LOCATIONS_GTMP WLT
    WHERE  SFOV.organization_id              = c_organization_id
    AND    SFOV.ORGANIZATION_ID              = WLT.CORPORATION_ID (+)
    AND    WLT.LOCATION_TYPE (+)             = 'ORG_LOC';

--}
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'EXTRACT_ORG_INFO';
--
BEGIN
--{
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
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSMISSION_ID',P_TRANSMISSION_ID);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    IF ( p_entity_in_rec.entity_id_tbl.count > 0)
    THEN
    --{
        FOR i in p_entity_in_rec.entity_id_tbl.first..p_entity_in_rec.entity_id_tbl.last LOOP
        --{
            --
            l_location_id      := null;
            l_gtmp_location_id := null;
            --
            open l_get_org_loc_id_csr(p_entity_in_rec.entity_id_tbl(i));
            fetch l_get_org_loc_id_csr into l_location_id, l_gtmp_location_id;
            close l_get_org_loc_id_csr;
            --
             -- gtmp should be Null for a New Insert since it is from GTmp table
                IF  (l_location_id IS NOT NULL and l_gtmp_location_id IS NULL )
                THEN
                --{

                    INSERT_ROW_IN_LOC_GTMP
                      (
                        p_location_id    => l_location_id,
                        p_corporation_id => p_entity_in_rec.entity_id_tbl(i),
                        p_location_type => 'ORG_LOC',
                        x_return_status => l_return_status
                      );
                    --
                 --}
                 END IF;
                  --
                  --  Debug Statements
                  --
                  IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'return status from insert into locGtmp ', l_return_status);
                        WSH_DEBUG_SV.log(l_module_name,'org_id ('||i||')',p_entity_in_rec.entity_id_tbl(i));
                        WSH_DEBUG_SV.log(l_module_name,'from_location_id', l_location_id);
                        WSH_DEBUG_SV.log(l_module_name,'gtmp_location_id',  l_gtmp_location_id);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                   --
                  END IF;
                    --
                    --
                    wsh_util_core.api_post_call(
                      p_return_status    => l_return_status,
                      x_num_warnings     => l_num_warnings,
                      x_num_errors       => l_num_errors);

            --}
            END LOOP;
       --}
    END IF;
--}
x_return_status := l_return_status;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
--{
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_get_org_loc_id_csr%ISOPEN THEN
         CLOSE l_get_org_loc_id_csr;
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
--}
END EXTRACT_ORG_INFO;
--
--
FUNCTION GET_STATE_CODE
            (
              p_location_id IN NUMBER,
              p_state       IN VARCHAR2
            ) RETURN VARCHAR2
IS
--{
    l_state_code VARCHAR2(100);

    cursor l_get_state_code_csr(p_location_id IN NUMBER) is
    select wr.state_code
    from   wsh_regions wr,
           wsh_region_locations wrl,
           wsh_locations wl
    where  wl.wsh_location_id = p_location_id
    and    wl.wsh_location_id = wrl.location_id
    and    wrl.region_type = 1
    and    wrl.region_id = wr.region_id;
--}
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_STATE_CODE';
--
BEGIN
--{
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
        WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
    END IF;
    --
    open  l_get_state_code_csr(p_location_id);
    fetch l_get_state_code_csr into l_state_code;
    close l_get_state_code_csr;

    IF (l_state_code is null and length(p_state) = 2 ) THEN
      l_state_code := p_state;
    END IF;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_state_code',l_state_code);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return l_state_code;
--}
EXCEPTION
--{
    WHEN OTHERS THEN
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return NULL;
--
--}
END GET_STATE_CODE;

PROCEDURE EXTEND_LOCATIONS_TBL
            (
              p_tbl_extend_index  IN NUMBER,
              x_locations_tbl IN OUT NOCOPY WSH_OTM_LOCATIONS_TBL_TYPE
            )
IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'EXTEND_LOCATIONS_TBL';
--
BEGIN
--{
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
        WSH_DEBUG_SV.log(l_module_name,'P_TBL_EXTEND_INDEX',P_TBL_EXTEND_INDEX);
    END IF;
    --
    x_locations_tbl.extend;
    x_locations_tbl(p_tbl_extend_index) := WSH_OTM_LOCATIONS_REC_TYPE
                                           (NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            WSH_OTM_SERVICE_PROV_TBL_TYPE(),
                                            WSH_OTM_LOC_ADDR_TBL_TYPE(),
                                            WSH_OTM_LOC_REF_NUM_TBL_TYPE(),
                                            WSH_OTM_LOC_CONTACT_TBL_TYPE()
                                           );
--}
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END EXTEND_LOCATIONS_TBL;


PROCEDURE EXTND_ASSIGN_LOC_REF_NUM_TBL
            (
              p_domain_name IN VARCHAR2,
              p_qualifier   IN VARCHAR2,
              p_value       IN VARCHAR2,
              x_ref_num_tbl IN OUT NOCOPY WSH_OTM_LOC_REF_NUM_TBL_TYPE
            )
IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'EXTND_ASSIGN_LOC_REF_NUM_TBL';

    l_count NUMBER;
--
BEGIN
--{
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
        WSH_DEBUG_SV.log(l_module_name,'p_qualifier',p_qualifier);
        WSH_DEBUG_SV.log(l_module_name,'p_domain_name',p_domain_name);
        WSH_DEBUG_SV.log(l_module_name,'p_value',p_value);
    END IF;
    --
    l_count := x_ref_num_tbl.count + 1;
    --
    --
    IF l_debug_on THEN
        --
        WSH_DEBUG_SV.log(l_module_name,'l_count',l_count);
        --
    END IF;
    --
    IF (p_value IS NOT NULL AND p_domain_name IS NOT NULL AND p_qualifier IS NOT NULL) THEN
      x_ref_num_tbl.extend;
      x_ref_num_tbl(l_count):= WSH_OTM_LOC_REF_NUM_REC_TYPE(NULL,NULL,NULL);
      x_ref_num_tbl(l_count).LOC_REF_NUM_QUALIFIER_XID := p_qualifier;
      x_ref_num_tbl(l_count).LOC_REF_NUM_VALUE := p_value;
      x_ref_num_tbl(l_count).LOC_REF_NUM_QUALIFIER_DN := p_domain_name;
    END IF;
--}
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END EXTND_ASSIGN_LOC_REF_NUM_TBL;

PROCEDURE EXTRACT_LOCATION_INFO
            (
              p_in_rec IN IN_REC_TYPE,
              p_transmission_id IN NUMBER,
              p_entity_type   IN VARCHAR2,
              x_loc_xmission_rec OUT NOCOPY WSH_OTM_LOC_XMISSION_REC_TYPE,
              x_return_status OUT NOCOPY VARCHAR2
            )
IS
--{
    -- local variables
    i NUMBER;
    j NUMBER;
    k NUMBER;
    l_return_status VARCHAR2(1);
    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;

    l_state_code   VARCHAR2(2);
    l_country_code VARCHAR2(3);
    l_domain_name  VARCHAR2(50);
    l_pub_dn_name  CONSTANT VARCHAR2(50) := 'PUBLIC';
    l_username     VARCHAR2(100);
    l_password     VARCHAR2(100);
    l_org_cust_loc_role VARCHAR2(20) := 'SHIPFROM/SHIPTO';
    l_car_loc_role VARCHAR2(20) := 'CARRIER';
    l_substitute_entity VARCHAR2(50);
    l_last_update_date DATE;
    l_send_allowed BOOLEAN := true;
    l_contact_ph VARCHAR2(4000);

    l_ref_num_value   VARCHAR2(101);
    l_ref_num_dn_name VARCHAR2(50);
    l_ref_num_qual   VARCHAR2(50);

    l_customer_id NUMBER;
    l_prev_customer_id NUMBER;
    l_carrier_id NUMBER;
    l_prev_carrier_id NUMBER;

    l_profile_queried BOOLEAN := false;

    l_address_line  VARCHAR2(32767);

    --contact related variables
    TYPE char500_tab_type IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
    l_contact_first_name_tbl char500_tab_type;
    l_contact_last_name_tbl char500_tab_type;
    l_contact_ph_cntr_code_tbl wsh_util_core.Column_Tab_Type;
    l_contact_ph_area_code_tbl wsh_util_core.Column_Tab_Type;
    l_contact_ph_number_tbl wsh_util_core.Column_Tab_Type;
    l_contact_email_addr_tbl char500_tab_type;
    l_contact_job_title_tbl char500_tab_type;
    l_contact_id_tbl wsh_util_core.id_tab_type;
    l_contact_last_upd_date_tbl wsh_util_core.Date_Tab_Type;

    -- eco 5381528
    l_dispatch_loc CONSTANT VARCHAR2(20) := 'DISPATCH LOCATION';
    l_supplier_site_ref_value VARCHAR2(1000);

    -- cursors

    --  Cursor to get the Org Location
    cursor l_org_loc_csr is
    select 'ORG-'|| decode(ORG.ORGANIZATION_ID,NULL,'000',ORG.ORGANIZATION_ID)||'-'|| HRL.LOCATION_ID LOCATION_XID,
           ORG.NAME LOCATION_NAME,
           HRL.ADDRESS_LINE_1,
           HRL.ADDRESS_LINE_2,
           HRL.ADDRESS_LINE_3,
           HRL.TOWN_OR_CITY,
           nvl(HRL.REGION_2,HRL.REGION_1) PROVINCE,
           --nvl(HRL.REGION_2,HRL.REGION_1) PROVINCE_CODE,
           HRL.POSTAL_CODE,
           FNDTR.ISO_TERRITORY_CODE COUNTRY,
           HRL.TELEPHONE_NUMBER_1 PHONE1,
           HRL.TELEPHONE_NUMBER_2 PHONE2,
           HRL.TELEPHONE_NUMBER_3 FAX,
           ORG.NAME,
           MP.ORGANIZATION_CODE,
           WL.WSH_LOCATION_ID,
           HRL.LOCATION_ID,
           ORG.ORGANIZATION_ID,
           GREATEST(HRL.LAST_UPDATE_DATE,
                     nvl(ORG.LAST_UPDATE_DATE, to_date('1900/01/01 00:00:01', 'YYYY/MM/DD HH24:MI:SS'))
                   ) LAST_UPDATE_DATE
    from   HR_LOCATIONS_ALL HRL,
           HR_ALL_ORGANIZATION_UNITS ORG,
           --HR_ALL_ORGANIZATION_UNITS_TL ORGL,
           --FND_LANGUAGES FNDL,
           FND_TERRITORIES FNDTR,
           WSH_OTM_LOCATIONS_GTMP WLT, -- global temp table
           MTL_PARAMETERS MP,
           WSH_LOCATIONS WL
    WHERE  WLT.LOCATION_ID = WL.WSH_LOCATION_ID
    AND    WLT.LOCATION_TYPE = 'ORG_LOC'
    AND    WL.LOCATION_SOURCE_CODE = 'HR'
    AND    WL.SOURCE_LOCATION_ID = HRL.LOCATION_ID
    AND    WLT.CORPORATION_ID = ORG.ORGANIZATION_ID (+)
    AND    ORG.ORGANIZATION_ID = MP.ORGANIZATION_ID (+)
    --AND    WLT.CORPORATION_ID = ORGL.ORGANIZATION_ID (+)
    --AND    ORGL.LANGUAGE = FNDL.LANGUAGE_CODE (+)
    --AND    FNDL.INSTALLED_FLAG (+) = 'B'
    AND    HRL.COUNTRY = FNDTR.TERRITORY_CODE(+);

    --  Cursor to get the Customer Location
    cursor l_cust_loc_csr is
    SELECT HZL.LOCATION_ID,
           HZL.ADDRESS1,
           HZL.ADDRESS2,
           HZL.ADDRESS3,
           HZL.ADDRESS4,
           HZL.CITY,
           nvl(HZL.STATE,HZL.PROVINCE) PROVINCE,
           HZL.STATE,
           HZL.POSTAL_CODE POSTAL_CODE,
           FNDTR.ISO_TERRITORY_CODE COUNTRY,
           HP.PARTY_NAME,
           HCA.CUST_ACCOUNT_ID,
           HCA.ACCOUNT_NUMBER,
           WL.WSH_LOCATION_ID,
           GREATEST(HZL.LAST_UPDATE_DATE,
                    nvl(GREATEST(HP.LAST_UPDATE_DATE,HCA.LAST_UPDATE_DATE),
                        to_date('1900/01/01 00:00:01', 'YYYY/MM/DD HH24:MI:SS')
                       )
                   ) LAST_UPDATE_DATE
    FROM   HZ_LOCATIONS HZL,
           WSH_LOCATIONS WL,
           FND_TERRITORIES FNDTR,
           WSH_OTM_LOCATIONS_GTMP WLT,
           HZ_PARTIES HP,
           HZ_CUST_ACCOUNTS HCA
    WHERE  HZL.LOCATION_ID = WL.SOURCE_LOCATION_ID
    AND    WL.LOCATION_SOURCE_CODE = 'HZ'
    AND    FNDTR.TERRITORY_CODE (+) = HZL.COUNTRY
    AND    WL.WSH_LOCATION_ID = WLT.LOCATION_ID
    AND    WLT.LOCATION_TYPE = 'CUST_LOC'
    AND    WLT.CORPORATION_ID = HCA.CUST_ACCOUNT_ID (+)
    AND    HCA.PARTY_ID = HP.PARTY_ID (+);

    -- Cursor to get the Customer Location Contact Information
    cursor l_ship_to_contact_csr (p_location_id IN NUMBER,
                                  p_corp_id IN NUMBER) is
    SELECT PER_CONTACT.PERSON_FIRST_NAME,
           PER_CONTACT.PERSON_LAST_NAME,
           PHONE_CONTACT.PHONE_COUNTRY_CODE,
           PHONE_CONTACT.PHONE_AREA_CODE,
           PHONE_CONTACT.PHONE_NUMBER,
           PER_CONTACT. EMAIL_ADDRESS,
           HOC.JOB_TITLE,
           HCAR.CUST_ACCOUNT_ROLE_ID,
           GREATEST(
                      GREATEST(
                                PHONE_CONTACT.LAST_UPDATE_DATE,
                                GREATEST(
                                      HREL.LAST_UPDATE_DATE,
                                      GREATEST(
                                              HOC.LAST_UPDATE_DATE,
                                              HCAR.LAST_UPDATE_DATE
                                              )
                                      )
                                ),
                      PER_CONTACT.LAST_UPDATE_DATE
                      ) LAST_UPDATE_DATE
    FROM   HZ_CUST_ACCOUNT_ROLES HCAR,
           HZ_RELATIONSHIPS HREL,
           HZ_ORG_CONTACTS HOC,
           HZ_CONTACT_POINTS   PHONE_CONTACT,
           HZ_PARTIES PER_CONTACT,
           WSH_OTM_LOC_CONTACTS_GTMP WLCT
    WHERE  HREL.PARTY_ID                      = HCAR.PARTY_ID
    AND    HCAR.ROLE_TYPE                      = 'CONTACT'
    AND    HREL.RELATIONSHIP_ID          = HOC.PARTY_RELATIONSHIP_ID
    AND    HREL.SUBJECT_TABLE_NAME             = 'HZ_PARTIES'
    AND    HREL.OBJECT_TABLE_NAME              = 'HZ_PARTIES'
    AND    HREL.SUBJECT_TYPE                   = 'PERSON'
    AND    HREL.DIRECTIONAL_FLAG               = 'F'
    AND    HREL.SUBJECT_ID                     = PER_CONTACT.PARTY_ID
    AND    PHONE_CONTACT.OWNER_TABLE_NAME(+)   = 'HZ_PARTIES'
    AND    PHONE_CONTACT.OWNER_TABLE_ID(+)     = HREL.PARTY_ID
    AND    PHONE_CONTACT.CONTACT_POINT_TYPE(+) = 'PHONE'
    AND    PHONE_CONTACT.PHONE_LINE_TYPE(+)    = 'GEN'
    AND    PHONE_CONTACT.PRIMARY_FLAG(+)       = 'Y'
    AND    HCAR.CUST_ACCOUNT_ROLE_ID           = WLCT.CONTACT_ID
    AND    WLCT.LOCATION_TYPE = 'CUST_LOC'
    AND    WLCT.LOCATION_ID  = p_location_id
    AND    (WLCT.CORPORATION_ID = p_corp_id or p_corp_id is NULL)
    ORDER  BY LAST_UPDATE_DATE DESC;

    --  Cursor to get the Carrier Location

    cursor l_carrier_loc_csr is
    SELECT WCV.CARRIER_ID,
           HPS.PARTY_SITE_ID CARRIER_SITE_ID,
           HP.PARTY_NAME CARRIER_NAME,
           substrb(HP.PARTY_NAME,1,10)||','||substrb(HZL.CITY,1,10)||','|| substrb(HZL.STATE,1,4)||','||substrb(HZL.COUNTRY,1,2) LOCATION_NAME,
           HZL.ADDRESS1,
           HZL.ADDRESS2,
           HZL.ADDRESS3,
           HZL.ADDRESS4,
           HZL.CITY CITY,
           nvl(HZL.STATE,HZL.PROVINCE) PROVINCE,
           --nvl(HZL.STATE,HZL.PROVINCE) PROVINCE_CODE,
           HZL.POSTAL_CODE POSTAL_CODE,
           FNDTR.ISO_TERRITORY_CODE COUNTRY,
           nvl(WCS.SUPPLIER_SITE_ID,WCV.SUPPLIER_SITE_ID) SUPPLIER_SITE_ID,
           WCV.SUPPLIER_ID,
           WCV.SUPPLIER_SITE_ID  CAR_SUPPLIER_SITE_ID, -- bug#7218387: needs to pass supplier_site_id at carrier level.
           WCV.SCAC_CODE,
           HZL.LOCATION_ID,
           WSL.WSH_LOCATION_ID,
           HPS.PARTY_SITE_NUMBER,
           HPS.PARTY_SITE_NUMBER CARRIER_SITE_NUMBER,
           HZL.LAST_UPDATE_DATE HZL_LAST_UPD_DATE,
           WCV.LAST_UPDATE_DATE WCV_LAST_UPD_DATE,
           HPS.LAST_UPDATE_DATE HPS_LAST_UPD_DATE,
           HP.LAST_UPDATE_DATE HP_LAST_UPD_DATE
    FROM   HZ_LOCATIONS HZL,
           FND_TERRITORIES FNDTR,
           WSH_OTM_LOCATIONS_GTMP wlt,
           WSH_CARRIERS WCV,
           WSH_CARRIER_SITES WCS,
           HZ_PARTY_SITES HPS,
           HZ_PARTIES HP,
           WSH_LOCATIONS WSL
    WHERE  WCV.CARRIER_ID = HPS.PARTY_ID
    AND    HPS.LOCATION_ID = HZL.LOCATION_ID
    AND    WSL.SOURCE_LOCATION_ID = HZL.LOCATION_ID
    AND    WSL.LOCATION_SOURCE_CODE = 'HZ'
    AND    FNDTR.TERRITORY_CODE (+) = HZL.COUNTRY
    AND    HPS.PARTY_SITE_ID = WLT.LOCATION_ID
    AND    WLT.LOCATION_TYPE = 'CAR_LOC'
    AND    WCV.CARRIER_ID = WLT.CORPORATION_ID
    AND    WCV.CARRIER_ID = HP.PARTY_ID
    AND    HPS.PARTY_SITE_ID = WCS.CARRIER_SITE_ID(+);
    --
    --Bug #7274527 :get the operating unit associated to supplier site
    CURSOR c_get_ou(p_supplier_site_id NUMBER)IS
    SELECT org_id
    FROM   ap_supplier_sites_all
    WHERE  vendor_site_id = p_supplier_site_id
    AND    ROWNUM =1;

    l_opertaing_unit_id NUMBER;
    --
    --Bug #7274527 : end


--}
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'EXTRACT_LOCATION_INFO';
--
BEGIN
--{
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
         WSH_DEBUG_SV.log(l_module_name,'P_TRANSMISSION_ID',P_TRANSMISSION_ID);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     x_loc_xmission_rec := WSH_OTM_LOC_XMISSION_REC_TYPE(NULL, NULL,WSH_OTM_LOCATIONS_TBL_TYPE());
     --x_loc_xmission_rec.LOCATIONS_TBL := WSH_OTM_LOCATIONS_TBL_TYPE();

     i := x_loc_xmission_rec.LOCATIONS_TBL.count+1;

     -- Get the profile values

     FND_PROFILE.Get('WSH_OTM_DOMAIN_NAME',l_domain_name);
     FND_PROFILE.Get('WSH_OTM_CORP_COUNTRY_CODE',l_country_code);

     IF (l_domain_name is null) THEN
     --{
         FND_MESSAGE.SET_NAME('WSH','WSH_OTM_DOMAIN_NOT_SET_ERR');
         x_return_status := wsh_util_core.G_RET_STS_UNEXP_ERROR;
         wsh_util_core.add_message(x_return_status, l_module_name);
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Error: The profile WSH_OTM_DOMAIN_NAME is set to NULL.  Please correct the profile value');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     --}
     END IF;

     IF (l_country_code is null) THEN
     --{
         FND_MESSAGE.SET_NAME('WSH','WSH_OTM_CNTR_CODE_NOT_SET_ERR');
         x_return_status := wsh_util_core.G_RET_STS_UNEXP_ERROR;
         wsh_util_core.add_message(x_return_status, l_module_name);
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Error: The profile WSH_OTM_CORP_COUNTRY_CODE is set to NULL.  Please correct the profile value');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     --}
     END IF;

     -- Extracting the Org Location Information
     FOR org_loc_rec in l_org_loc_csr LOOP
     --{

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
           --
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.LOCATION_XID',org_loc_rec.LOCATION_XID);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.LOCATION_NAME',org_loc_rec.LOCATION_NAME);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.ADDRESS_LINE_1',org_loc_rec.ADDRESS_LINE_1);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.ADDRESS_LINE_2',org_loc_rec.ADDRESS_LINE_2);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.ADDRESS_LINE_3',org_loc_rec.ADDRESS_LINE_3);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.TOWN_OR_CITY',org_loc_rec.TOWN_OR_CITY);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.PROVINCE',org_loc_rec.PROVINCE);
           --WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.PROVINCE_CODE',org_loc_rec.PROVINCE_CODE);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.POSTAL_CODE',org_loc_rec.POSTAL_CODE);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.COUNTRY',org_loc_rec.COUNTRY);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.PHONE1',org_loc_rec.PHONE1);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.PHONE2',org_loc_rec.PHONE2);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.FAX',org_loc_rec.FAX);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.NAME',org_loc_rec.NAME);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.ORGANIZATION_CODE',org_loc_rec.ORGANIZATION_CODE);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.WSH_LOCATION_ID',org_loc_rec.WSH_LOCATION_ID);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.LOCATION_ID',org_loc_rec.LOCATION_ID);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.ORGANIZATION_ID',org_loc_rec.ORGANIZATION_ID);
           WSH_DEBUG_SV.log(l_module_name,'org_loc_rec.LAST_UPDATE_DATE',org_loc_rec.LAST_UPDATE_DATE);
           --
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_OTM_SYNC_REF_DATA_PKG.IS_REF_DATA_SEND_REQD',WSH_DEBUG_SV.C_PROC_LEVEL);
           --
         END IF;
         --
         WSH_OTM_SYNC_REF_DATA_PKG.IS_REF_DATA_SEND_REQD
           (
             P_ENTITY_ID                    => org_loc_rec.location_id,
             P_PARENT_ENTITY_ID             => org_loc_rec.organization_id,
             P_ENTITY_TYPE                  => 'ORG_LOC',
             P_ENTITY_UPDATED_DATE          => org_loc_rec.last_update_date,
             X_SUBSTITUTE_ENTITY            => l_substitute_entity,
             P_TRANSMISSION_ID              => P_TRANSMISSION_ID,
             X_SEND_ALLOWED                 => l_send_allowed,
             X_RETURN_STATUS                => l_return_status
           );

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_send_allowed', l_send_allowed);
             WSH_DEBUG_SV.log(l_module_name,'Calling Entity Type from Send_LOcations', p_entity_type);
             WSH_DEBUG_SV.log(l_module_name,'l_return_status', l_return_status);
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         wsh_util_core.api_post_call(
           p_return_status    => l_return_status,
           x_num_warnings     => l_num_warnings,
           x_num_errors       => l_num_errors);
         -- wms-otm-proj  if the Call to Send_LOCATIONs is from Entity_type 'ORG_LOC' then
         -- we need to Send it despite the l_send_allowed being FALSE
         IF ( (l_send_allowed)  OR (p_entity_type = 'ORG_LOC') )  THEN
         --{

             -- Initially we need extend the locations table for every record.
             EXTEND_LOCATIONS_TBL
                (
                  p_tbl_extend_index => i,
                  x_locations_tbl    => x_loc_xmission_rec.LOCATIONS_TBL
                );


             x_loc_xmission_rec.LOCATIONS_TBL(i).TXN_CODE := 'IU';
             x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_XID := org_loc_rec.LOCATION_XID;
             IF (x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_XID IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_DN := l_domain_name;
             END IF;
             x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_NAME :=  substrb(org_loc_rec.LOCATION_NAME,1,120);
             x_loc_xmission_rec.LOCATIONS_TBL(i).CITY := substrb(org_loc_rec.TOWN_OR_CITY,1,30);
             x_loc_xmission_rec.LOCATIONS_TBL(i).PROVINCE_CODE := GET_STATE_CODE(org_loc_rec.WSH_LOCATION_ID,org_loc_rec.province);
             -- eco 5192928
             IF (x_loc_xmission_rec.LOCATIONS_TBL(i).PROVINCE_CODE IS NULL)
             THEN
             --{
                 x_loc_xmission_rec.LOCATIONS_TBL(i).PROVINCE := substrb(org_loc_rec.province,1,30);
             --}
             END IF;
             -- eco 5192928
             x_loc_xmission_rec.LOCATIONS_TBL(i).POSTAL_CODE := substrb(org_loc_rec.POSTAL_CODE,1,15);
             x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_XID := substrb(org_loc_rec.COUNTRY,1,3);
             IF (x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_XID IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_DN := l_pub_dn_name;
             END IF;

             x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_XID := l_org_cust_loc_role;

             IF (x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_XID IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_DN := l_pub_dn_name;
             END IF;

             x_loc_xmission_rec.LOCATIONS_TBL(i).CORPORATION := substrb(org_loc_rec.NAME,1,30);

             IF (l_substitute_entity IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).SUBSTITUTE_LOCATION_XID := l_substitute_entity;
               x_loc_xmission_rec.LOCATIONS_TBL(i).SUBSTITUTE_LOCATION_DN := l_domain_name;
             END IF;

             k := 0;
             FOR j in 1..3 LOOP
             --{
                 IF (j = 1)
                    OR
                    (j = 2 AND org_loc_rec.ORGANIZATION_CODE IS NOT NULL)
                    OR
                    (j = 3 AND org_loc_rec.NAME IS NOT NULL)
                 THEN
                   k := k + 1;
                   x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL.extend;
                   x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL(k) := WSH_OTM_LOC_REF_NUM_REC_TYPE(NULL,NULL,NULL);
                 END IF;

                 IF ( j = 1 ) THEN
                   x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL(k).LOC_REF_NUM_QUALIFIER_XID := 'ORIGIN';
                   x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL(k).LOC_REF_NUM_VALUE := 'ORGANIZATION';
                 ELSIF (j = 2 AND org_loc_rec.ORGANIZATION_CODE IS NOT NULL) THEN
                   x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL(k).LOC_REF_NUM_QUALIFIER_XID := 'ORGID';
                   x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL(k).LOC_REF_NUM_VALUE := org_loc_rec.ORGANIZATION_CODE;
                 ELSIF (j=3 AND org_loc_rec.NAME IS NOT NULL) THEN
                   x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL(k).LOC_REF_NUM_QUALIFIER_XID := 'ORGNM';
                   x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL(k).LOC_REF_NUM_VALUE :=substrb(org_loc_rec.NAME,1,101);
                 END IF;

                 IF (x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL(k).LOC_REF_NUM_QUALIFIER_XID IS NOT NULL) THEN
                   x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL(k).LOC_REF_NUM_QUALIFIER_DN := l_pub_dn_name;
                 END IF;
             --}
             END LOOP;

             l_address_line := org_loc_rec.ADDRESS_LINE_1 || ' ' || org_loc_rec.ADDRESS_LINE_2 || ' ' || org_loc_rec.ADDRESS_LINE_3;

             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_address_line', l_address_line);
             END IF;

             j := lengthb(l_address_line);
             k := 1;
             WHILE (j > 0) LOOP
             --{
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_ADDR_TBL.extend;
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_ADDR_TBL(k) := WSH_OTM_LOC_ADDR_REC_TYPE(NULL,NULL);
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_ADDR_TBL(k).SEQ_NUMBER := k;
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_ADDR_TBL(k).ADRESS_LINE := substrb(l_address_line,1,55);
               l_address_line := substrb(l_address_line,56);
               j := j - 55;
               k := k + 1;
             --}
             END LOOP;

             IF ( org_loc_rec.PHONE1 IS NOT NULL OR org_loc_rec.PHONE2 IS NOT NULL OR org_loc_rec.FAX IS NOT NULL) THEN
             --{
                 x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL.extend;
                 x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(1) := WSH_OTM_LOC_CONTACT_REC_TYPE
                                                            (NULL,
                                                             NULL,
                                                             NULL,
                                                             NULL,
                                                             NULL,
                                                             NULL,
                                                             NULL,
                                                             NULL,
                                                             NULL,
                                                             NULL
                                                             );
                 x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(1).CONTACT_XID :=  org_loc_rec.LOCATION_XID;
                 x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(1).CONTACT_DN  :=  l_domain_name;
                 x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(1).PHONE1      :=  substrb(org_loc_rec.PHONE1,1,80);
                 x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(1).PHONE2      :=  substrb(org_loc_rec.PHONE2,1,80);
                 x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(1).FAX         :=  substrb(org_loc_rec.FAX,1,80);
             --}
             END IF;

             i := i + 1;
         --}
         END IF;
     --}
     END LOOP;

     i := x_loc_xmission_rec.LOCATIONS_TBL.count+1;
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'i is ', i);
     END IF;
     -- Extracting the Cust Location Information
     FOR cust_loc_rec in l_cust_loc_csr LOOP
     --{

         -- Initially we need extend the locations table for every record.
         l_substitute_entity := NULL;
         l_customer_id := cust_loc_rec.cust_account_id;

         IF (l_contact_id_tbl.count > 0) THEN
         --{
                 l_contact_first_name_tbl.delete;
                 l_contact_last_name_tbl.delete;
                 l_contact_ph_cntr_code_tbl.delete;
                 l_contact_ph_area_code_tbl.delete;
                 l_contact_ph_number_tbl.delete;
                 l_contact_email_addr_tbl.delete;
                 l_contact_job_title_tbl.delete;
                 l_contact_id_tbl.delete;
                 l_contact_last_upd_date_tbl.delete;
         --}
         END IF;

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'location_id', cust_loc_rec.wsh_location_id);
           WSH_DEBUG_SV.log(l_module_name,'customer_id', cust_loc_rec.CUST_ACCOUNT_ID);
         END IF;
         open l_ship_to_contact_csr(cust_loc_rec.wsh_location_id, cust_loc_rec.CUST_ACCOUNT_ID);
         fetch l_ship_to_contact_csr bulk collect into
                  l_contact_first_name_tbl,
                  l_contact_last_name_tbl,
                  l_contact_ph_cntr_code_tbl,
                  l_contact_ph_area_code_tbl,
                  l_contact_ph_number_tbl,
                  l_contact_email_addr_tbl,
                  l_contact_job_title_tbl,
                  l_contact_id_tbl,
                  l_contact_last_upd_date_tbl;
         close l_ship_to_contact_csr;

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'count of contact table', l_contact_id_tbl.count);
         END IF;
         IF (l_contact_id_tbl.count > 0 ) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_contact_last_upd_date_tbl(1)', l_contact_last_upd_date_tbl(1));
           END IF;
           l_last_update_date := greatest(nvl(l_contact_last_upd_date_tbl(1),cust_loc_rec.last_update_date),cust_loc_rec.last_update_date);
         ELSE
           l_last_update_date := cust_loc_rec.last_update_date;
         END IF;

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_OTM_SYNC_REF_DATA_PKG.IS_REF_DATA_SEND_REQD',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         WSH_OTM_SYNC_REF_DATA_PKG.IS_REF_DATA_SEND_REQD
           (
             P_ENTITY_ID                    => cust_loc_rec.wsh_location_id,
             P_PARENT_ENTITY_ID             => cust_loc_rec.cust_account_id,
             P_ENTITY_TYPE                  => 'CUST_LOC',
             P_ENTITY_UPDATED_DATE          => l_last_update_date,
             X_SUBSTITUTE_ENTITY            => l_substitute_entity,
             P_TRANSMISSION_ID              => P_TRANSMISSION_ID,
             X_SEND_ALLOWED                 => l_send_allowed,
             X_RETURN_STATUS                => l_return_status
           );

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_send_allowed', l_send_allowed);
             WSH_DEBUG_SV.log(l_module_name,'l_return_status', l_return_status);
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         wsh_util_core.api_post_call(
           p_return_status    => l_return_status,
           x_num_warnings     => l_num_warnings,
           x_num_errors       => l_num_errors);

         IF l_debug_on THEN
           --
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.LOCATION_ID',cust_loc_rec.LOCATION_ID);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.ADDRESS1',cust_loc_rec.ADDRESS1);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.ADDRESS2',cust_loc_rec.ADDRESS2);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.ADDRESS3',cust_loc_rec.ADDRESS3);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.ADDRESS4',cust_loc_rec.ADDRESS4);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.CITY',cust_loc_rec.CITY);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.PROVINCE',cust_loc_rec.PROVINCE);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.STATE',cust_loc_rec.STATE);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.POSTAL_CODE',cust_loc_rec.POSTAL_CODE);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.COUNTRY',cust_loc_rec.COUNTRY);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.PARTY_NAME',cust_loc_rec.PARTY_NAME);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.CUST_ACCOUNT_ID',cust_loc_rec.CUST_ACCOUNT_ID);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.ACCOUNT_NUMBER',cust_loc_rec.ACCOUNT_NUMBER);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.WSH_LOCATION_ID',cust_loc_rec.WSH_LOCATION_ID);
           WSH_DEBUG_SV.log(l_module_name,'cust_loc_rec.LAST_UPDATE_DATE',cust_loc_rec.LAST_UPDATE_DATE);
           WSH_DEBUG_SV.log(l_module_name,'l_last_update_date', l_last_update_date);
           WSH_DEBUG_SV.log(l_module_name,'l_send_allowed', l_send_allowed);
           --
         END IF;
         --
         IF (l_send_allowed) THEN
         --{
             --
             --
             IF (cust_loc_rec.CUST_ACCOUNT_ID IS NOT NULL and (nvl(l_prev_customer_id,-999) <> nvl(l_customer_id,-998))) THEN
             --{
                 EXTEND_LOCATIONS_TBL
                    (
                      p_tbl_extend_index => i,
                      x_locations_tbl => x_loc_xmission_rec.LOCATIONS_TBL
                    );

                 x_loc_xmission_rec.LOCATIONS_TBL(i).TXN_CODE := 'IU';
                 x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_XID := 'CUS-' || cust_loc_rec.CUST_ACCOUNT_ID;

                 IF (x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_XID IS NOT NULL) THEN
                   x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_DN := l_domain_name;
                 END IF;

                 x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_NAME := substrb(cust_loc_rec.PARTY_NAME,1,120);
                 x_loc_xmission_rec.LOCATIONS_TBL(i).CORPORATION := substrb(cust_loc_rec.PARTY_NAME,1,30);
                 x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_XID := substrb(l_country_code,1,3);

                 IF (x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_XID IS NOT NULL) THEN
                   x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_DN := l_pub_dn_name;
                 END IF;

                 x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_XID := 'CUSTOMER';

                 IF (x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_XID IS NOT NULL) THEN
                   x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_DN := l_pub_dn_name;
                 END IF;

                 FOR j in 1..3 LOOP
                 --{
                     --
                     l_ref_num_dn_name := l_pub_dn_name;
                     l_ref_num_value := NULL;
                     l_ref_num_qual := NULL;
                     IF ( j = 1 ) THEN
                       l_ref_num_qual := 'ORIGIN';
                       l_ref_num_value := 'CUSTOMER';
                     ELSIF (j = 2) THEN
                       l_ref_num_qual := 'CUSID';
                       l_ref_num_value := substrb(cust_loc_rec.ACCOUNT_NUMBER,1,101);
                     ELSIF (j=3) THEN
                       l_ref_num_qual := 'CUSNM';
                       l_ref_num_value := substrb(cust_loc_rec.PARTY_NAME,1,101);
                     END IF;
                     --
                     EXTND_ASSIGN_LOC_REF_NUM_TBL
                       (
                         p_domain_name => l_ref_num_dn_name,
                         p_qualifier   => l_ref_num_qual,
                         p_value       => l_ref_num_value,
                         x_ref_num_tbl => x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL
                       );
                     --
                 --}
                 END LOOP;

                 i := i + 1;

             --}
             END IF;
             -- Initially we need extend the locations table for every record.
             EXTEND_LOCATIONS_TBL
                (
                  p_tbl_extend_index => i,
                  x_locations_tbl => x_loc_xmission_rec.LOCATIONS_TBL
                );


             x_loc_xmission_rec.LOCATIONS_TBL(i).TXN_CODE := 'IU';

             IF (cust_loc_rec.CUST_ACCOUNT_ID IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_XID := 'CUS-'||cust_loc_rec.CUST_ACCOUNT_ID ||'-' || cust_loc_rec.LOCATION_ID;
             ELSE
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_XID := 'CUS-000-' || cust_loc_rec.LOCATION_ID;
             END IF;

             IF (x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_XID IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_DN := l_domain_name;
             END IF;
             x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_NAME :=  substrb(cust_loc_rec.PARTY_NAME,1,10) ||','||substrb(cust_loc_rec.CITY,1,10)||','||substrb(cust_loc_rec.PROVINCE,1,4)||','||cust_loc_rec.COUNTRY;
             x_loc_xmission_rec.LOCATIONS_TBL(i).CITY := substrb(cust_loc_rec.CITY,1,30);
             x_loc_xmission_rec.LOCATIONS_TBL(i).PROVINCE_CODE := GET_STATE_CODE(cust_loc_rec.WSH_LOCATION_ID,cust_loc_rec.PROVINCE);

             -- eco 5192928
             IF (x_loc_xmission_rec.LOCATIONS_TBL(i).PROVINCE_CODE IS NULL)
             THEN
             --{
                 x_loc_xmission_rec.LOCATIONS_TBL(i).PROVINCE := substrb(cust_loc_rec.PROVINCE,1,30);
             --}
             END IF;
             -- eco 5192928
             x_loc_xmission_rec.LOCATIONS_TBL(i).POSTAL_CODE := substrb(cust_loc_rec.POSTAL_CODE,1,15);
             x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_XID := substrb(cust_loc_rec.COUNTRY,1,3);
             IF (x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_XID IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_DN := l_pub_dn_name;
             END IF;

             x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_XID := l_org_cust_loc_role;

             IF (x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_XID IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_DN := l_pub_dn_name;
             END IF;

             IF (cust_loc_rec.CUST_ACCOUNT_ID IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).PARENT_LOCATION_XID := 'CUS-' || cust_loc_rec.CUST_ACCOUNT_ID;
               x_loc_xmission_rec.LOCATIONS_TBL(i).PARENT_LOCATION_DN := l_domain_name;
             END IF;

             IF (l_substitute_entity IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).SUBSTITUTE_LOCATION_XID := l_substitute_entity;
               x_loc_xmission_rec.LOCATIONS_TBL(i).SUBSTITUTE_LOCATION_DN  := l_domain_name;
             END IF;


             FOR j in 1..3 LOOP
             --{
                 --
                 l_ref_num_dn_name := l_pub_dn_name;
                 l_ref_num_value := NULL;
                 l_ref_num_qual := NULL;
                 IF ( j = 1 ) THEN
                   l_ref_num_qual := 'ORIGIN';
                   l_ref_num_value := 'CUSTOMER';
                 ELSIF (j = 2) THEN
                   l_ref_num_qual := 'CUSID';
                   l_ref_num_value := substrb(cust_loc_rec.ACCOUNT_NUMBER,1,101);
                 ELSIF (j=3) THEN
                   l_ref_num_qual := 'CUSNM';
                   l_ref_num_value := substrb(cust_loc_rec.PARTY_NAME,1,101);
                 END IF;
                 --
                 EXTND_ASSIGN_LOC_REF_NUM_TBL
                   (
                     p_domain_name => l_ref_num_dn_name,
                     p_qualifier   => l_ref_num_qual,
                     p_value       => l_ref_num_value,
                     x_ref_num_tbl => x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL
                   );
                 --
             --}
             END LOOP;

             l_address_line := cust_loc_rec.ADDRESS1 || ' ' || cust_loc_rec.ADDRESS2 || ' ' || cust_loc_rec.ADDRESS3|| ' ' || cust_loc_rec.ADDRESS4;

             j := lengthb(l_address_line);
             k := 1;
             WHILE (j > 0) LOOP
             --{
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_ADDR_TBL.extend;
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_ADDR_TBL(k) := WSH_OTM_LOC_ADDR_REC_TYPE(NULL,NULL);
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_ADDR_TBL(k).SEQ_NUMBER := k;
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_ADDR_TBL(k).ADRESS_LINE := substrb(l_address_line,1,55);
               l_address_line := substrb(l_address_line,56);
               j := j - 55;
               k := k + 1;
             --}
             END LOOP;

             IF ( l_contact_id_tbl.count > 0 ) THEN
             --{
                 FOR k in l_contact_id_tbl.first..l_contact_id_tbl.last LOOP
                 --{
                     x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL.extend;
                     x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(k) := WSH_OTM_LOC_CONTACT_REC_TYPE
                                                                (NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 NULL
                                                                 );
                     x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(k).CONTACT_XID   :=  l_contact_id_tbl(k);
                     x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(k).CONTACT_DN    :=  l_domain_name;
                     x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(k).TXN_CODE      :=  'IU';

                     IF l_debug_on THEN
                       --
                       WSH_DEBUG_SV.log(l_module_name,'l_contact_ph_cntr_code_tbl('||k||')',l_contact_ph_cntr_code_tbl(k));
                       WSH_DEBUG_SV.log(l_module_name,'l_contact_ph_area_code_tbl('||k||')',l_contact_ph_area_code_tbl(k));
                       WSH_DEBUG_SV.log(l_module_name,'l_contact_ph_number_tbl('||k||')',l_contact_ph_number_tbl(k));
                       WSH_DEBUG_SV.log(l_module_name,'l_contact_email_addr_tbl('||k||')',l_contact_email_addr_tbl(k));
                       WSH_DEBUG_SV.log(l_module_name,'l_contact_first_name_tbl('||k||')',l_contact_first_name_tbl(k));
                       WSH_DEBUG_SV.log(l_module_name,'l_contact_last_name_tbl('||k||')',l_contact_last_name_tbl(k));
                       WSH_DEBUG_SV.log(l_module_name,'l_contact_job_title_tbl('||k||')',l_contact_job_title_tbl(k));
                       --
                     END IF;
                     l_contact_ph := NULL;

                     IF (l_contact_ph_cntr_code_tbl(k) IS NOT NULL) THEN
                       l_contact_ph      :=  l_contact_ph_cntr_code_tbl(k) || '-';
                     END IF;
                     IF (l_contact_ph_area_code_tbl(k) IS NOT NULL) THEN
                       l_contact_ph      :=  l_contact_ph || l_contact_ph_area_code_tbl(k) || '-';
                     END IF;
                     IF (l_contact_ph_number_tbl(k) IS NOT NULL) THEN
                       l_contact_ph      :=  l_contact_ph || l_contact_ph_number_tbl(k);
                     END IF;

                     x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(k).PHONE1      :=  substrb(l_contact_ph,1,80);
                     x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(k).EMAIL_ADDRESS := substrb(l_contact_email_addr_tbl(k),1,60);
                     x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(k).FIRST_NAME    := substrb(l_contact_first_name_tbl(k),1,20);
                     x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(k).LAST_NAME     := substrb(l_contact_last_name_tbl(k),1,30);
                     x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_CONTACT_TBL(k).JOB_TITLE     := substrb(l_contact_job_title_tbl(k),1,60);
                 --}
                 END LOOP;
             --}
             END IF;
             i := i + 1;
         --}
         END IF;
         --
         l_prev_customer_id := l_customer_id;
         --
     --}
     END LOOP;

     i := x_loc_xmission_rec.LOCATIONS_TBL.count+1;
     --
     FOR carrier_loc_rec in l_carrier_loc_csr LOOP
     --{

         l_carrier_id := carrier_loc_rec.carrier_id;

         IF NOT (l_profile_queried) THEN
         --{

             FND_PROFILE.Get('WSH_OTM_USER_ID',x_loc_xmission_rec.username);
             FND_PROFILE.Get('WSH_OTM_PASSWORD',x_loc_xmission_rec.password);

             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'x_loc_xmission_rec.username', x_loc_xmission_rec.username);
               WSH_DEBUG_SV.log(l_module_name,'x_loc_xmission_rec.password', x_loc_xmission_rec.password);
             END IF;

             IF (x_loc_xmission_rec.username is null) THEN
             --{
                 FND_MESSAGE.SET_NAME('WSH','WSH_PROFILE_NOT_SET_ERR');
                 FND_MESSAGE.SET_TOKEN('PRF_NAME','WSH_OTM_USER_ID');
                 x_return_status := wsh_util_core.G_RET_STS_UNEXP_ERROR;
                 wsh_util_core.add_message(x_return_status, l_module_name);
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Error: The profile WSH_OTM_USER_ID is set to NULL.  Please correct the profile value');
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             --}
             END IF;

             IF (x_loc_xmission_rec.password is null) THEN
             --{
                 FND_MESSAGE.SET_NAME('WSH','WSH_PROFILE_NOT_SET_ERR');
                 FND_MESSAGE.SET_TOKEN('PRF_NAME','WSH_OTM_PASSWORD');
                 x_return_status := wsh_util_core.G_RET_STS_UNEXP_ERROR;
                 wsh_util_core.add_message(x_return_status, l_module_name);
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Error: The profile WSH_OTM_PASSWORD is set to NULL.  Please correct the profile value');
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             --}
             END IF;
             --
             l_profile_queried := true;
         --}
         END IF;
         l_last_update_date := GREATEST (carrier_loc_rec.HZL_LAST_UPD_DATE, GREATEST (carrier_loc_rec.WCV_LAST_UPD_DATE, GREATEST (carrier_loc_rec.HPS_LAST_UPD_DATE, carrier_loc_rec.HP_LAST_UPD_DATE)));
         /*
         -- commented out this code because for Carriers we are not implementing the logic
         -- of storing already sent carriers
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_OTM_SYNC_REF_DATA_PKG.IS_REF_DATA_SEND_REQD',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

         WSH_OTM_SYNC_REF_DATA_PKG.IS_REF_DATA_SEND_REQD
           (
             P_ENTITY_ID                    => carrier_loc_rec.location_id,
             P_PARENT_ENTITY_ID             => carrier_loc_rec.carrier_id,
             P_ENTITY_TYPE                  => 'CAR_LOC',
             P_ENTITY_UPDATED_DATE          => l_last_update_date,
             X_SUBSTITUTE_ENTITY            => l_substitute_entity,
             P_TRANSMISSION_ID              => P_TRANSMISSION_ID,
             X_SEND_ALLOWED                 => l_send_allowed,
             X_RETURN_STATUS                => l_return_status
           );

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Return Status after calling IS_REF_DATA_SEND_REQD is', l_return_status);
             WSH_DEBUG_SV.log(l_module_name,'l_send_allowed', l_send_allowed);
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         wsh_util_core.api_post_call(
           p_return_status    => l_return_status,
           x_num_warnings     => l_num_warnings,
           x_num_errors       => l_num_errors);
        */

         IF l_debug_on THEN
           --
           WSH_DEBUG_SV.log(l_module_name,'Current carrier_id',carrier_loc_rec.CARRIER_ID);
           WSH_DEBUG_SV.log(l_module_name,'Previous carrier_id', l_prev_carrier_id);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.CARRIER_SITE_ID',carrier_loc_rec.CARRIER_SITE_ID);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.CARRIER_NAME',carrier_loc_rec.CARRIER_NAME);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.LOCATION_NAME',carrier_loc_rec.LOCATION_NAME);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.ADDRESS1',carrier_loc_rec.ADDRESS1);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.ADDRESS2',carrier_loc_rec.ADDRESS2);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.ADDRESS3',carrier_loc_rec.ADDRESS3);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.ADDRESS4',carrier_loc_rec.ADDRESS4);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.CITY',carrier_loc_rec.CITY);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.PROVINCE',carrier_loc_rec.PROVINCE);
           --WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.PROVINCE_CODE',carrier_loc_rec.PROVINCE_CODE);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.POSTAL_CODE',carrier_loc_rec.POSTAL_CODE);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.COUNTRY',carrier_loc_rec.COUNTRY);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.SUPPLIER_ID',carrier_loc_rec.SUPPLIER_ID);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.SCAC_CODE',carrier_loc_rec.SCAC_CODE);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.LOCATION_ID',carrier_loc_rec.LOCATION_ID);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.WSH_LOCATION_ID',carrier_loc_rec.WSH_LOCATION_ID);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.HZL_LAST_UPD_DATE',carrier_loc_rec.HZL_LAST_UPD_DATE);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.WCV_LAST_UPD_DATE',carrier_loc_rec.WCV_LAST_UPD_DATE);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.HPS_LAST_UPD_DATE',carrier_loc_rec.HPS_LAST_UPD_DATE);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.HP_LAST_UPD_DATE',carrier_loc_rec.HP_LAST_UPD_DATE);
           WSH_DEBUG_SV.log(l_module_name,'carrier_loc_rec.SUPPLIER_SITE_ID',carrier_loc_rec.SUPPLIER_SITE_ID);
           WSH_DEBUG_SV.log(l_module_name,'l_last_update_date', l_last_update_date);
           --
         END IF;

         IF (nvl(l_prev_carrier_id,-999) <> nvl(l_carrier_id,-998)) THEN
         --{
             -- Initially we need extend the locations table for every record.
             EXTEND_LOCATIONS_TBL
                (
                  p_tbl_extend_index => i,
                  x_locations_tbl => x_loc_xmission_rec.LOCATIONS_TBL
                );


             x_loc_xmission_rec.LOCATIONS_TBL(i).TXN_CODE := 'IU';
             x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_XID := 'CAR-' || carrier_loc_rec.CARRIER_ID;

             IF (x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_XID IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_DN := l_domain_name;
             END IF;

             x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_NAME := substrb(carrier_loc_rec.CARRIER_NAME,1,120);
             x_loc_xmission_rec.LOCATIONS_TBL(i).CORPORATION := substrb(carrier_loc_rec.CARRIER_NAME,1,30);
             x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_XID := l_country_code;

             IF (x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_XID IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_DN := l_pub_dn_name;
             END IF;

             x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_XID := 'CARRIER';

             IF (x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_XID IS NOT NULL) THEN
               x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_DN := l_pub_dn_name;
             END IF;

             IF (carrier_loc_rec.SUPPLIER_ID IS NOT NULL) THEN
             --{
                 x_loc_xmission_rec.LOCATIONS_TBL(i).SERVICE_PROV_TBL.extend;
                 x_loc_xmission_rec.LOCATIONS_TBL(i).SERVICE_PROV_TBL(1) := WSH_OTM_SERVICE_PROV_REC_TYPE(NULL,NULL,NULL);
                 x_loc_xmission_rec.LOCATIONS_TBL(i).SERVICE_PROV_TBL(1).SERVICE_PROV_QUALIFIER_XID := 'SUPPLIER_ID';
                 x_loc_xmission_rec.LOCATIONS_TBL(i).SERVICE_PROV_TBL(1).SERVICE_PROV_QUALIFIER_DN := l_pub_dn_name;
                 x_loc_xmission_rec.LOCATIONS_TBL(i).SERVICE_PROV_TBL(1).SERVICE_PROV_ALIAS_VALUE := 'SUP-' || carrier_loc_rec.SUPPLIER_ID;
             --}
             END IF;

             FOR j in 1..3 LOOP
             --{
                 l_ref_num_dn_name := l_pub_dn_name;
                 l_ref_num_value := NULL;
                 l_ref_num_qual := NULL;
                 IF ( j = 1 ) THEN
                   l_ref_num_qual := 'ORIGIN';
                   l_ref_num_value := 'CARRIER';
                 ELSIF (j = 2) THEN
                   l_ref_num_qual := 'CARID';
                   l_ref_num_value := substrb(carrier_loc_rec.CARRIER_ID,1,101);
                 ELSIF (j=3 AND carrier_loc_rec.SCAC_CODE IS NOT NULL) THEN
                   l_ref_num_qual := 'CARNM';
                   l_ref_num_value := substrb(carrier_loc_rec.SCAC_CODE,1,101);
                 END IF;
                 --
                 EXTND_ASSIGN_LOC_REF_NUM_TBL
                   (
                     p_domain_name => l_ref_num_dn_name,
                     p_qualifier   => l_ref_num_qual,
                     p_value       => l_ref_num_value,
                     x_ref_num_tbl => x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL
                   );
                 --
             --}
             END LOOP;
             -- Bug#7218387: Needs to pass supplier_id and supplier_site_id at carrier level
             -- as a reference numbers to OTM.
             IF (carrier_loc_rec.SUPPLIER_ID IS NOT NULL) THEN
             --{
                 --
                 --
                 EXTND_ASSIGN_LOC_REF_NUM_TBL(
                     p_domain_name => l_pub_dn_name,
                     p_qualifier   => 'SUPPLIER_ID',
                     p_value       => 'SUP-' || carrier_loc_rec.SUPPLIER_ID,
                     x_ref_num_tbl => x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL
                     );
                 --
                 --
             --}
             END IF;
             IF (carrier_loc_rec.car_supplier_site_id IS NOT NULL) THEN
                 --{
                 IF (carrier_loc_rec.SUPPLIER_ID IS NOT NULL) THEN
                     l_supplier_site_ref_value := 'SUP-'||carrier_loc_rec.SUPPLIER_ID || '-' ||carrier_loc_rec.CAR_SUPPLIER_SITE_ID;
                 ELSE
                     l_supplier_site_ref_value := 'SUP-000-'||carrier_loc_rec.CAR_SUPPLIER_SITE_ID;
                 END IF;
                 --
                 EXTND_ASSIGN_LOC_REF_NUM_TBL(
                     p_domain_name => l_pub_dn_name,
                     p_qualifier   => 'SUPPLIER_SITE_ID',
                     p_value       => l_supplier_site_ref_value,
                     x_ref_num_tbl => x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL
                     );
                 --
                 --
                 -- Bug# 7274527: Needs to pass operating Unit Id associated to supplier site
                 --               to OTM as carrier service provider reference number.
                 OPEN  c_get_ou(carrier_loc_rec.CAR_SUPPLIER_SITE_ID);
                 FETCH c_get_ou INTO l_opertaing_unit_id;
                 CLOSE c_get_ou;
                 IF (l_opertaing_unit_id IS NOT NULL) THEN
                     EXTND_ASSIGN_LOC_REF_NUM_TBL(
                         p_domain_name => l_pub_dn_name,
                         p_qualifier   => 'ORGID',
                         p_value       => l_opertaing_unit_id,
                         x_ref_num_tbl => x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL
                         );
                 END IF;
                 -- Bug# 7274527: end
             --}
             END IF;
             -- Bug#7218387: End

             i := i + 1;
         --}
         END IF;

         -- We need extend the locations table for every record.
         EXTEND_LOCATIONS_TBL
            (
              p_tbl_extend_index => i,
              x_locations_tbl => x_loc_xmission_rec.LOCATIONS_TBL
            );


         x_loc_xmission_rec.LOCATIONS_TBL(i).TXN_CODE := 'IU';
         x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_XID := 'CAR-' || carrier_loc_rec.CARRIER_ID || '-'|| carrier_loc_rec.LOCATION_ID;
         IF (x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_XID IS NOT NULL) THEN
           x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_DN := l_domain_name;
         END IF;
         x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_NAME :=  substrb(carrier_loc_rec.LOCATION_NAME,1,120);
         x_loc_xmission_rec.LOCATIONS_TBL(i).CITY := substrb(carrier_loc_rec.CITY,1,30);
         x_loc_xmission_rec.LOCATIONS_TBL(i).PROVINCE_CODE := GET_STATE_CODE(carrier_loc_rec.WSH_LOCATION_ID,carrier_loc_rec.province);
             -- eco 5192928
             IF (x_loc_xmission_rec.LOCATIONS_TBL(i).PROVINCE_CODE IS NULL)
             THEN
             --{
                 x_loc_xmission_rec.LOCATIONS_TBL(i).PROVINCE := substrb(carrier_loc_rec.province,1,30);
             --}
             END IF;
             -- eco 5192928
         x_loc_xmission_rec.LOCATIONS_TBL(i).POSTAL_CODE := substrb(carrier_loc_rec.POSTAL_CODE,1,15);
         x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_XID := substrb(carrier_loc_rec.COUNTRY,1,3);
         IF (x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_XID IS NOT NULL) THEN
           x_loc_xmission_rec.LOCATIONS_TBL(i).COUNTRY_CODE_DN := l_pub_dn_name;
         END IF;
         x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_XID := l_dispatch_loc; -- eco 5381528
         IF (x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_XID IS NOT NULL) THEN
           x_loc_xmission_rec.LOCATIONS_TBL(i).LOCATION_ROLE_DN := l_pub_dn_name;
         END IF;
         x_loc_xmission_rec.LOCATIONS_TBL(i).PARENT_LOCATION_XID := 'CAR-' || carrier_loc_rec.CARRIER_ID;
         IF (x_loc_xmission_rec.LOCATIONS_TBL(i).PARENT_LOCATION_XID IS NOT NULL) THEN
           x_loc_xmission_rec.LOCATIONS_TBL(i).PARENT_LOCATION_DN := l_domain_name;
         END IF;
         --
         --
         FOR j in 1..4 LOOP
         --{
             l_ref_num_dn_name := l_pub_dn_name;
             l_ref_num_value := NULL;
             l_ref_num_qual := NULL;

             IF ( j = 1 ) THEN
               l_ref_num_qual := 'ORIGIN';
               l_ref_num_value := 'CARRIER';
             ELSIF (j = 2) THEN
               l_ref_num_qual := 'CARID';
               l_ref_num_value := substrb(carrier_loc_rec.CARRIER_ID,1,101);
             ELSIF (j=3 AND carrier_loc_rec.SCAC_CODE IS NOT NULL) THEN
               l_ref_num_qual := 'CARNM';
               l_ref_num_value := substrb(carrier_loc_rec.SCAC_CODE,1,101);
             ELSIF (j=4) THEN
               l_ref_num_qual := 'LOCID';
               l_ref_num_value := substrb(carrier_loc_rec.CARRIER_SITE_NUMBER,1,101);
             END IF;
             --
             EXTND_ASSIGN_LOC_REF_NUM_TBL
               (
                 p_domain_name => l_ref_num_dn_name,
                 p_qualifier   => l_ref_num_qual,
                 p_value       => l_ref_num_value,
                 x_ref_num_tbl => x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL
               );
             --
         --}
         END LOOP;
         --

         -- eco 5381528
         IF (carrier_loc_rec.SUPPLIER_ID IS NOT NULL) THEN
         --{
             --
             --
             EXTND_ASSIGN_LOC_REF_NUM_TBL
               (
                 p_domain_name => l_pub_dn_name,
                 p_qualifier   => 'SUPPLIER_ID',
                 p_value       => 'SUP-' || carrier_loc_rec.SUPPLIER_ID,
                 x_ref_num_tbl => x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL
               );
             --
             --
         --}
         END IF;

         IF (carrier_loc_rec.SUPPLIER_SITE_ID IS NOT NULL) THEN
         --{

             IF (carrier_loc_rec.SUPPLIER_ID IS NOT NULL) THEN
               l_supplier_site_ref_value := 'SUP-'||carrier_loc_rec.SUPPLIER_ID || '-' ||carrier_loc_rec.SUPPLIER_SITE_ID;
             ELSE
               l_supplier_site_ref_value := 'SUP-000-'||carrier_loc_rec.SUPPLIER_SITE_ID;
             END IF;
             --
             EXTND_ASSIGN_LOC_REF_NUM_TBL
               (
                 p_domain_name => l_pub_dn_name,
                 p_qualifier   => 'SUPPLIER_SITE_ID',
                 p_value       => l_supplier_site_ref_value,
                 x_ref_num_tbl => x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL
               );
             --
             -- Bug# 7274527: Needs to pass operating Unit Id associated to supplier site
             --               to OTM as carrier service provider reference number.
             OPEN  c_get_ou(carrier_loc_rec.SUPPLIER_SITE_ID);
             FETCH c_get_ou INTO l_opertaing_unit_id;
             CLOSE c_get_ou;
             IF (l_opertaing_unit_id IS NOT NULL) THEN
                 EXTND_ASSIGN_LOC_REF_NUM_TBL(
                     p_domain_name => l_pub_dn_name,
                     p_qualifier   => 'ORGID',
                     p_value       => l_opertaing_unit_id,
                     x_ref_num_tbl => x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_REF_NUM_TBL
                     );
             END IF;
             -- Bug# 7274527: end
         --}
         END IF;
         -- eco 5381528

         l_address_line := carrier_loc_rec.ADDRESS1 || ' ' || carrier_loc_rec.ADDRESS2 || ' ' || carrier_loc_rec.ADDRESS3 || ' ' || carrier_loc_rec.ADDRESS4;

         j := lengthb(l_address_line);
         k := 1;
         WHILE (j > 0) LOOP
         --{
           x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_ADDR_TBL.extend;
           x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_ADDR_TBL(k) := WSH_OTM_LOC_ADDR_REC_TYPE(NULL,NULL);
           x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_ADDR_TBL(k).SEQ_NUMBER := k;
           x_loc_xmission_rec.LOCATIONS_TBL(i).LOC_ADDR_TBL(k).ADRESS_LINE := substrb(l_address_line,1,55);
           l_address_line := substrb(l_address_line,56);
           j := j - 55;
           k := k + 1;
         --}
         END LOOP;

         l_prev_carrier_id := l_carrier_id;

         i := i + 1;
     --}
     END LOOP;
     --
     IF (l_num_warnings > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
         --
     ELSE
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
         --
     END IF;
     --
--}
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
--{
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
--}
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END EXTRACT_LOCATION_INFO;

PROCEDURE SEND_LOCATIONS
            (
              p_entity_in_rec   IN WSH_OTM_ENTITY_REC_TYPE,
              x_loc_xmission_rec OUT NOCOPY WSH_OTM_LOC_XMISSION_REC_TYPE,
              x_transmission_id OUT NOCOPY NUMBER,
              x_return_status   OUT NOCOPY VARCHAR2,
              x_msg_data        OUT NOCOPY VARCHAR2
            )
IS
--{
    --local variables
    l_return_status VARCHAR2(1);
    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;
    l_details         VARCHAR2(32767);
    l_summary         VARCHAR2(32767);
    l_tkt_valid       VARCHAR2(1);
    l_msg_count       NUMBER;

    l_transmission_id NUMBER;
    l_entity_rec WSH_OTM_ENTITY_REC_TYPE := WSH_OTM_ENTITY_REC_TYPE(NULL,NULL,NULL,NULL,WSH_OTM_RD_NUM_TBL_TYPE(),
                                                                         WSH_OTM_RD_NUM_TBL_TYPE());
    l_in_rec      IN_REC_TYPE;

    -- cursors
--}
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SEND_LOCATIONS';
--
BEGIN
--{
    --
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
        WSH_DEBUG_SV.log(l_module_name,'entity type is ', p_entity_in_rec.entity_type);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;

    select WSH_OTM_SYNC_REF_DATA_LOG_S.nextval into l_transmission_id from dual;
    --
    IF (p_entity_in_rec.entity_type = 'TRIP') THEN
    --{
        EXTRACT_TRIP_INFO
          (
            p_entity_in_rec   => p_entity_in_rec,
            p_transmission_id => l_transmission_id,
            x_return_status   => l_return_status
          );

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            WSH_DEBUG_SV.log(l_module_name,'Return Status after calling EXTRACT_TRIP_INFO is', l_return_status);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);

    --}
    ELSIF (p_entity_in_rec.entity_type = 'DELIVERY') THEN
    --{

        EXTRACT_DLVY_INFO
          (
            p_entity_in_rec   => p_entity_in_rec,
            p_transmission_id => l_transmission_id,
            x_return_status   => l_return_status
          );

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            WSH_DEBUG_SV.log(l_module_name,'Return Status after calling EXTRACT_TRIP_INFO is', l_return_status);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);

    --}
    ELSIF (p_entity_in_rec.entity_type = 'CARRIER') THEN
    --{
        VALIDATE_TKT
            (
              p_operation          =>  p_entity_in_rec.operation,
              p_argument           =>  p_entity_in_rec.argument,
              p_ticket             =>  p_entity_in_rec.ticket,
              x_tkt_valid          =>  l_tkt_valid,
              x_return_status      =>  l_return_status,
              x_msg_data           =>  x_msg_data
            );

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status after calling VALIDATE_TKT is', l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);


        EXTRACT_CARRIER_INFO
          (
            p_entity_in_rec   => p_entity_in_rec,
            p_transmission_id => l_transmission_id,
            x_return_status   => l_return_status
          );

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            WSH_DEBUG_SV.log(l_module_name,'Return Status after calling EXTRACT_CARRIER_INFO is', l_return_status);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);

    --}
    -- wms-otm , for creating Locations for the Orgs. involved in WMS DockDoor syncronization
    ELSIF (p_entity_in_rec.entity_type = 'ORG_LOC') THEN
    --{
        VALIDATE_TKT
            (
              p_operation          =>  p_entity_in_rec.operation,
              p_argument           =>  p_entity_in_rec.argument,
              p_ticket             =>  p_entity_in_rec.ticket,
              x_tkt_valid          =>  l_tkt_valid,
              x_return_status      =>  l_return_status,
              x_msg_data           =>  x_msg_data
            );

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status after calling VALIDATE_TKT is', l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);

        --wms-otm-proj  New Procedure to Extract Locations for the Org
        EXTRACT_ORG_INFO
          (
            p_entity_in_rec   => p_entity_in_rec,
            p_transmission_id => l_transmission_id,
            x_return_status   => l_return_status
          );

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'OrgAfterCalling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            WSH_DEBUG_SV.log(l_module_name,'Return Status after calling EXTRACT_ORG_INFO is', l_return_status);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);

    --}  -- wms-otm for ORG_LOC
    ELSE
    --{
        FND_MESSAGE.SET_NAME('WSH','WSH_OTM_INVALID_ENTITY');
        FND_MESSAGE.SET_TOKEN('ENTITY',p_entity_in_rec.entity_type);
        x_return_status := wsh_util_core.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.add_message(x_return_status, l_module_name);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    --}
    END IF;

    -- wms-otm-proj : Added p_entity_type to Distinguish  ORG_LOC separately
    --                since ORG_LOC would require a to send Location XML everytime Unlike Other Entity Types
    EXTRACT_LOCATION_INFO
      (
        p_in_rec           => l_in_rec,
        p_transmission_id  => l_transmission_id,
        p_entity_type      => p_entity_in_rec.entity_type,
        x_loc_xmission_rec => x_loc_xmission_rec,
        x_return_status    => l_return_status
      );

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status after calling EXTRACT_LOCATION_INFO is', l_return_status);
        WSH_DEBUG_SV.log(l_module_name,'Number of records finally being sent to GC3 is',x_loc_xmission_rec.LOCATIONS_TBL.count);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status    => l_return_status,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);

    WSH_UTIL_CORE.Get_Messages
      (
        p_init_msg_list   => 'T',
        x_summary         => l_summary,
        x_details         => l_details,
        x_count           => l_msg_count
      );

    x_msg_data := l_summary || ' ' || l_details;

    IF (x_loc_xmission_rec.LOCATIONS_TBL.count >0) THEN
      x_transmission_id := l_transmission_id;
    END IF;


    IF (l_num_warnings > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        --
    ELSE
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        --
    END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
--}
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      WSH_UTIL_CORE.Get_Messages
        (
          p_init_msg_list   => 'T',
          x_summary         => l_summary,
          x_details         => l_details,
          x_count           => l_msg_count
        );

      x_msg_data := x_msg_data || l_summary || ' ' || l_details;

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      WSH_UTIL_CORE.Get_Messages
        (
          p_init_msg_list   => 'T',
          x_summary         => l_summary,
          x_details         => l_details,
          x_count           => l_msg_count
        );

      x_msg_data := l_summary || ' ' || l_details;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      WSH_UTIL_CORE.Get_Messages
        (
          p_init_msg_list   => 'T',
          x_summary         => l_summary,
          x_details         => l_details,
          x_count           => l_msg_count
        );

      x_msg_data := l_summary || ' ' || l_details || SQLERRM;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
--
--}
END SEND_LOCATIONS;

function GET_STOP_LOCATION_XID
            (
              p_stop_id          IN  NUMBER
            ) RETURN VARCHAR2
IS
    cursor l_get_stop_loc_csr is
    SELECT WL.LOCATION_SOURCE_CODE LOC_TYPE,
           WL.SOURCE_LOCATION_ID LOCATION_ID
    FROM   WSH_TRIP_STOPS WTS,
           WSH_LOCATIONS WL
    WHERE  WTS.STOP_ID = p_stop_id
    AND    WL.WSH_LOCATION_ID = nvl(WTS.PHYSICAL_LOCATION_ID,WTS.STOP_LOCATION_ID);
    --AND    WTS.TMS_INTERFACE_FLAG ='ASP';

    l_corporation_id NUMBER;
    l_location_id NUMBER;
    l_location_xid VARCHAR2(100);
    l_corp_type VARCHAR2(100);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_STOP_LOCATION_XID';
--
BEGIN
--{
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
        WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
    END IF;
    --
    FOR l_stop_loc_rec in l_get_stop_loc_csr LOOP
    --{
        l_corporation_id := get_stop_corp_id(p_stop_id,l_stop_loc_rec.loc_type);
        l_location_id := l_stop_loc_rec.location_id;
        IF (l_stop_loc_rec.loc_type = 'HR') THEN
          l_corp_type := 'ORG';
        ELSE
          l_corp_type := 'CUS';
        END IF;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'location type',l_stop_loc_rec.loc_type);
          WSH_DEBUG_SV.log(l_module_name,'location id',l_stop_loc_rec.location_id);
          WSH_DEBUG_SV.log(l_module_name,'corporation id',l_corporation_id);
        END IF;
    --}
    END LOOP;

    IF (l_corporation_id is null) THEN
      l_location_xid := l_corp_type || '-000-' || l_location_id;
    ELSE
      l_location_xid := l_corp_type || '-' ||l_corporation_id||'-' || l_location_id;
    END IF;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
        --
    END IF;
    return l_location_xid;
    --

--}
END GET_STOP_LOCATION_XID;

PROCEDURE VALIDATE_TKT
            (
              p_operation          IN  VARCHAR2,
              p_argument           IN  VARCHAR2,
              p_ticket             IN  VARCHAR2,
              x_tkt_valid          OUT NOCOPY VARCHAR2,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_data           OUT NOCOPY VARCHAR2
            )
IS
--{
    -- Variables
    l_ticket VARCHAR2(500);
    l_end_date DATE;

    l_is_tkt_valid boolean := false;
    l_operation FND_HTTP_TICKETS.OPERATION%TYPE;
    l_argument FND_HTTP_TICKETS.ARGUMENT%TYPE;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_TKT';
--
--}
BEGIN
--{
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
        WSH_DEBUG_SV.log(l_module_name,'p_operation',p_operation);
        WSH_DEBUG_SV.log(l_module_name,'p_argument',p_argument);
        WSH_DEBUG_SV.log(l_module_name,'p_ticket',p_ticket);
    END IF;
    --
    x_tkt_valid := 'F';
    x_return_status := wsh_util_core.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FND_HTTP_TICKET.CHECK_TICKET',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    l_is_tkt_valid := FND_HTTP_TICKET.CHECK_TICKET
                        (
                          p_ticket    => p_ticket,
                          p_operation => l_operation,
                          p_argument  => l_argument
                        );

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_operation',l_operation);
      WSH_DEBUG_SV.log(l_module_name,'l_argument',l_argument);
    END IF;
    IF (
         l_is_tkt_valid
         and l_operation = p_operation
         and l_argument = p_argument
       ) THEN
    --{
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Tkt is valid');
        END IF;
        x_tkt_valid := 'T';
    --}
    ELSE
    --{
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Tkt is invalid');
        END IF;
        x_tkt_valid := 'F';
        FND_MESSAGE.SET_NAME('WSH','WSH_OTM_INVALID_TKT');
        FND_MESSAGE.SET_TOKEN('TICKET',p_ticket);
        x_return_status := wsh_util_core.G_RET_STS_ERROR;
        x_msg_data :=FND_MESSAGE.GET;
    --}
    END IF;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
        --
    END IF;
--}
EXCEPTION
--{
    WHEN OTHERS THEN
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_tkt_valid := 'F';
      x_msg_data := SQLERRM;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
--
--}
END VALIDATE_TKT;

procedure GET_INT_LOCATION_XID
            (
              p_location_id          IN  NUMBER,
              x_location_xid         OUT NOCOPY VARCHAR2,
              x_return_status        OUT NOCOPY VARCHAR2
            )
IS
    l_corporation_id NUMBER;
    l_int_location_id NUMBER;
    l_location_xid VARCHAR2(100);
    l_corp_type VARCHAR2(100) := 'ORG';
    l_return_status VARCHAR2(10);
    l_num_errors      NUMBER;
    l_num_warnings    NUMBER;

    --bug 6770323: modified cursor to join with hr_locations_all table
    cursor l_loc_to_org_csr (p_loc_id NUMBER) IS
    SELECT inventory_organization_id
    FROM   hr_locations_all
    WHERE  location_id = p_loc_id;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_INT_LOCATION_XID';
--
BEGIN
--{
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
        WSH_DEBUG_SV.log(l_module_name,'p_location_id',p_location_id);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    WSH_LOCATIONS_PKG.Convert_internal_cust_location(
      p_internal_cust_location_id => p_location_id,
      x_internal_org_location_id  => l_int_location_id,
      x_return_status =>l_return_status);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_return_status after calling Convert_internal_cust_location',l_return_status);
      WSH_DEBUG_SV.log(l_module_name,'l_int_location_id',l_int_location_id);
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status    => l_return_status,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);

    IF (l_int_location_id IS NOT NULL) THEN
    --{
        --
        open  l_loc_to_org_csr(l_int_location_id);
        fetch l_loc_to_org_csr into l_corporation_id;
        close l_loc_to_org_csr;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_corporation_id',l_corporation_id);
        END IF;
        --
        IF (l_corporation_id is null) THEN
          l_location_xid := l_corp_type || '-000-' || l_int_location_id;
        ELSE
          l_location_xid := l_corp_type || '-' ||l_corporation_id||'-' || l_int_location_id;
        END IF;
        --
        x_location_xid := l_location_xid;
    --}
    END IF;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_location_xid',x_location_xid);
        WSH_DEBUG_SV.pop(l_module_name);
        --
    END IF;
    --
--}
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
--}
END GET_INT_LOCATION_XID;


END WSH_OTM_REF_DATA_GEN_PKG;

/
